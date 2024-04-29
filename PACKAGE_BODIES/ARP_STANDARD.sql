--------------------------------------------------------
--  DDL for Package Body ARP_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_STANDARD" as
/* $Header: ARPLSTDB.pls 120.27.12010000.6 2009/04/03 09:58:47 nproddut ship $             */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE CURSORS                                                         |
 |                                                                         |
 | gl_periods_c      Returns the period status for non adjusted periods    |
 |                   for each period between pstart and pend_date or, if   |
 |                   the start and end are within the same period, then it |
 |                   returns just the enclosing period.                    |
 |                                                                         |
 +-------------------------------------------------------------------------*/

cursor gl_periods_c(      app_id in number,
                          sob_id in number,
                          pstart_date in varchar2,
                          pend_date in varchar2 ) IS
       select period_name, closing_status,
              period_type, period_year, period_num
       from   gl_period_statuses
       where  application_id = app_id
       and    set_of_books_id = sob_id
       and
       (
           start_date between to_date(pstart_date, 'YYYYMMDD') and
                              to_date(pend_date, 'YYYYMMDD')
           OR
           end_date between to_date(pstart_date, 'YYYYMMDD') and
                            to_date(pend_date, 'YYYYMMDD')
           OR
           to_date(pstart_date, 'YYYYMMDD') between start_date and end_date
           OR
           to_date(pend_date, 'YYYYMMDD')   between start_date and end_date
       )
       and    adjustment_period_flag = 'N'
       order by period_year, period_num;




/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE DATA TYPES                                                      |
 |                                                                         |
 +-------------------------------------------------------------------------*/
TYPE gl_date_type IS
    TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE FLAGS                                                           |
 |                                                                         |
 | Control flags are currently held in base 10.                            |
 | PUBLIC FUNCTIONS are declared to export each of these private flags     |
 | to a SQL*ReportWriter application.                                      |
 |                                                                         |
 +-------------------------------------------------------------------------*/

INT_MD_MSG_NUMBER constant number := 1;           -- Message Dictionary control
INT_MD_MSG_TEXT   constant number := 10;          -- Options
INT_MD_MSG_NAME   constant number := 100;         -- Show message name only
INT_MD_MSG_TOKENS constant number := 1000;        -- List Message Tokens and Values
INT_MD_MSG_EXPLANATION constant number := 10000;  -- Not supported yet
INT_MD_MSG_FIND_NUMBER constant number := 100000; -- Use Message Number not Name


/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE VARIABLES                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/

    debug_flag boolean := false;
    MD_OPTIONS NUMBER := INT_MD_MSG_NUMBER + INT_MD_MSG_TEXT;

pg_file_name	VARCHAR2(100) := NULL;
pg_path_name    VARCHAR2(100) := NULL;
pg_fp		utl_file.file_type;
pg_period       gl_date_type;
pg_period_open  gl_date_type;

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC FUNCTIONS                                                        |
 |                                                                         |
 +-------------------------------------------------------------------------*/



/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    get_next_word( list in out, value out NOCOPY ) return boolean                  |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Given an input list of 'words' this routine will extract the first      |
 |    word from the list and set the output parameter "value" to this word.   |
 |    Returns false when the list is empty.                                   |
 |                                                                            |
 | REQUIRES                                                                   |
 |    list of words, separated by space characters, eg:                       |
 |         COUNTY STATE COUNTY CITY                                           |
 |                                                                            |
 | MODIFIES                                                                   |
 |    list   - Each time a word is found, it is taken off this list.          |
 |    value  - Next word on list or null if list was empty.                   |
 |                                                                            |
 | RETURNS                                                                    |
 |    TRUE   - The output parameter value is not null                         |
 |    FALSE  - The input list was empty, and no word could be found.          |
 |                                                                            |
 | NOTES                                                                      |
 |    Was originally written as part of the package: arp_flex but has been    |
 |    moved to arp_standard( public function ) so that it can be used in      |
 |    all software.                                                           |
 |                                                                            |
 | HISTORY                                                                    |
 |      2/11/93         Nigel Smith     Created                               |
 |                                                                            |
 *----------------------------------------------------------------------------*/

function get_next_word( list in out NOCOPY varchar2, value in out NOCOPY varchar2 ) return boolean is
   end_pos number;
begin

   arp_standard.debug( 'arp_standard.get_next_word(' || list || ',' || value || ')+' );

   list := ltrim( list );
   /*** MB skip,  Get the character position with the first ' ' ***/
   end_pos := instr( list, ' ', 1 );

   if end_pos = 0
   then
    /*** MB skip  ***/
     end_pos := length( list );
   end if;

    /*** MB skip ***/
   value := rtrim(ltrim( substr( list, 1, end_pos )));
   list := substr( list, end_pos+1 );

   arp_standard.debug( 'arp_standard.get_next_word(' || list || ',' || value || ')-' );

   if ( value is null )
   then
      return( FALSE );
   else
      return( TRUE );
   end if;

end;



/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    ar_lookup                                                               |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Interfaces with AR lookups, returning meaning for message type and code |
 |                                                                            |
 | REQUIRES                                                                   |
 |    lookup_type                                                             |
 |    lookup_code                                                             |
 |                                                                            |
 | RETURNS                                                                    |
 |    Meaning                   Lookup meaning                                |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |    None                                                                    |
 |                                                                            |
 | ERRORS RAISED                                                              |
 |    AR_NO_LOOKUP              The Lookup Type and Code could not be found   |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |      2/11/93         Nigel Smith     Created                               |
 |                                                                            |
 *----------------------------------------------------------------------------*/

function ar_lookup ( lookup_type in varchar2, lookup_code in varchar2 )
         return varchar2 is

  cursor sel_lookup_meaning( t in varchar2, c in varchar2 ) is
         select meaning from ar_lookups where lookup_type = t
                                          and lookup_code = c;

  sel    sel_lookup_meaning%ROWTYPE;

begin

   open sel_lookup_meaning( lookup_type, lookup_code );
   fetch sel_lookup_meaning into sel.meaning;
   if sel_lookup_meaning%NOTFOUND
   then
      close sel_lookup_meaning;
      fnd_message( 'AR_NO_LOOKUP', 'TYPE', lookup_type, 'CODE', lookup_code );
   else
      close sel_lookup_meaning;
      return( sel.meaning );
   end if;
end;


/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    gl_date_range_open                                                      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function returns true if every General Ledger period is marked     |
 |    as open between the date range supplied. At least one period must be    |
 |    marked as open or future enterable, the function will return FALSE      |
 |    if no periods are open.                                                 |
 |                                                                            |
 | REQUIRES                                                                   |
 |    pstart_date         - Start date, typically trunc( date )               |
 |                          in format 'YYYYMMDD'                              |
 |    pend_date           - End date, typically, rounded up to just before    |
 |                          midnight using the ceil date function.            |
 |                          in format 'YYYYMMDD'                              |
 | RETURNS                                                                    |
 |    TRUE                - If at least one period, and all others were open  |
 |                          or future enterable                               |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |    <none>                                                                  |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |    15/02/93   Nigel Smith    Created                                       |
 |    08/07/96   Subash C       Modified data type to varchar2 (OSF issue)    |
 |                                                                            |
 *----------------------------------------------------------------------------*/

FUNCTION gl_date_range_open( pstart_date in varchar2,
                             pend_date  in varchar2 ) RETURN BOOLEAN IS
date_ok       BOOLEAN;
periods_found BOOLEAN;

BEGIN
    date_ok := TRUE;
    periods_found := FALSE;

    FOR status in gl_periods_c( application_id,
                                sysparm.set_of_books_id,
                                pstart_date, pend_date )
    LOOP
       periods_found := TRUE;
       IF status.closing_status not in ( 'O', 'F' )
       THEN                                    -- 'Open' or 'Future Enterable'
          date_ok := false;
          EXIT;
       END IF;
    END LOOP;

    IF periods_found and date_ok
    THEN
       return( TRUE );
    ELSE
       return( FALSE );
    END IF;

END;


/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    functional_amount                                                       |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function returns the functional amount for a given foreign amount. |
 |    THe functional amount is rounded to the correct precision.              |
 |                                                                            |
 | REQUIRES                                                                   |
 |    Amount - the foreign amount                                             |
 |    Exchange Rate - to use when converting to functional amount             |
 |   one of:                                                                  |
 |    Currency Code            - of the functional amount                     |
 |    Precision                - of the functional amount                     |
 |    minimum accountable unit - of the functional amount                     |
 |                                                                            |
 | RETURNS                                                                    |
 |    amount * exchange_rate to correct rounding for currency                 |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |    Oracle Error      If Currency Code, Precision and minimum accountable   |
 |                      are all NULL or if Amount or Exchange Rate ar NULL    |
 |                                                                            |
 |    Oracle Error      If can not find information for Currency Code         |
 |                      supplied                                              |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |    <none>                                                                  |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |      2/10/93         Martin Morris           Created                       |
 |      7/21/95         Martin Johnson          Replaced fnd_message with     |
 |                                              user-defined exception so that|
 |                                              pragma restrict_references    |
 |                                              does not fail                 |
 |                                                                            |
 *----------------------------------------------------------------------------*/


FUNCTION functional_amount(amount        IN NUMBER,
                           currency_code IN VARCHAR2,
                           exchange_rate IN NUMBER,
                           precision     IN NUMBER,
                           min_acc_unit  IN NUMBER) RETURN NUMBER IS

BEGIN

   RETURN(
            arpcurr.functional_amount(amount,
                                      currency_code,
                                      exchange_rate,
                                      precision,
                                      min_acc_unit)
         );

EXCEPTION
     WHEN OTHERS THEN
         RAISE;

END functional_amount;



/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  FLAGS                                                           |
 |  Since Public Constants are not supported yet betwen server and client  |
 |  applications in PL/SQL 1 and 2. The following public functions are     |
 |  declared so that application programmer can reference internal private |
 |  constants.                                                             |
 |                                                                         |
 +-------------------------------------------------------------------------*/


function MD_MSG_NUMBER return number is
begin
   return( INT_MD_MSG_NUMBER );      -- Show Message Number
end;

function MD_MSG_TEXT   return number is
begin
   return( INT_MD_MSG_TEXT );        -- Show Message Text
end;

function MD_MSG_NAME   return number is
begin
   return( INT_MD_MSG_NAME );        -- Show message Name
end;

function MD_MSG_TOKENS return number is
begin
   return( INT_MD_MSG_TOKENS );      -- Return Message Tokens and Numbers
end;

function MD_MSG_EXPLANATION return number is
begin
   return( INT_MD_MSG_EXPLANATION ); -- Not supported yet
end;

function MD_MSG_FIND_NUMBER return number is
begin
   return( INT_MD_MSG_FIND_NUMBER ); -- Use Message Number not Name
end;



/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    debug             - Display text message if in debug mode               |
 |    enable_debug      - Enable run time debugging                           |
 |    disable_debug     - Disable run time debugging                          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Generate standard debug information sending it to dbms_output so that   |
 |    the client tool can log it for the user.                                |
 |   NOTE:  As of 115.16 of this package, we no longer use dbms_output to
 |      route messages to log or screen.  As of version 115.36, we now use
 |      FND_LOG routines to record the messages in the FND_LOG_MESSAGES table.
 |
 |   The current version of the debug procedure works like this:
 |
 |    arp_standard.debug('arp_util_pkg.get_value()+',    --> msg text
 |                       'plsql',                        --> prefix (source)
 |                       'arp_util_pkg.get_value.begin', --> package name
 |                       FND_LOG_LEVEL.PROCEDURE);       --> FND constant
 |
 |   Now, in reality, only the first parameter is required and the others
 |   will be defaulted or determined based on content of the message.
 |
 |    arp_standard.debug('arp_util_pkg.get_value()+');
 |
 |   Both of the above examples will log the following message:
 |
 |     module := ar.plsql.arp_util_pkg.get_value.begin
 |     level  := 2 (this equates to FND_LOG.LEVEL_PROCEDURE)
 |     text   := 'arp_util_pkg.get_value()+'
 |
 |   Several rules you should keep in mind...
 |    (1) I never manipulate the message text (looks just like it did before)
 |    (2) I default the source as 'plsql' in most cases.
 |         Valid values include 'resource','reports','forms','src.<subdir>'
 |    (3) I use parentheses () and +/- signs to determine the module name
 |       and log level.  Only use parens to designate calls and put a +
 |       or - adjacent to the closing (right) paren to default
 |       FND_LOG.LEVEL_PROCEDURE and the '.begin' or '.end'
 |       DO NOT HAVE EXTRA SPACES WITHIN PARENS OR PROCEDURE NAMES
 |    (4) The word 'EXCEPTION' is interpreted as an
 |       FND_LOG.LEVEL_EXCEPTION message.
 |
 | Here are sample uses of arp_standard.debug:
 |
 | Typical entry/exit messages in plsql packages:
 |    arp_standard.debug('arp_rounding.correct_other_receivables()+');
 |
 | Inline in .pld library:
 |    arp_standard.debug('arxtwmai_folder.validate(EVENT)-','resource');
 |
 | Inline in pro*C:
 |    arp_standard.debug('raaiad()+', 'src.autoinv');
 |
 | Detail messages in plsql:
 |    arp_standard.debug('request_id = ' || l_request_id,
 |                       'plsql',
 |                       'arp_util.get_gl_date');
 |
 | Specific exception/error logging:
 |    arp_standard.debug('ERROR:  Processed has failed',
 |                       'plsql',
 |                       'arp_trx_validate.gl_date',
 |                       'FND_LOG.LEVEL_ERROR');
 |
 | For most logging messages, it is sufficient to just supply the message
 | text and maybe the prefix (source type).  As long as you follow the naming
 | convention and use of parens, I can get the procedure name for you.
 |
 | The valid FND_LOG LEVEL values are:
 |
 |     FND_LOG.LEVEL_STATEMENT - most detailed level - should be used
 |          for displaying values and other run-time specifics
 |     FND_LOG.LEVEL_PROCEDURE - Entry and exit points.  I determine
 |          this level in the algorythm logic by looking for )+, +),
 |          )-, and -). When using this level, you should include
 |          '.begin' or '.end' to the module_name
 |     FND_LOG.LEVEL_EVENT - A higher level message for indicating
 |          things like 'record added' or 'calling arp_whatever_api'
 |     FND_LOG.LEVEL_EXCEPTION - recording a handled exception in an
 |          exception block.  By default, I look for the word
 |          'exception' in the message text and set this level.
 |     FND_LOG.LEVEL_ERROR - An error message displayed to the end-user
 |     FND_LOG.LEVEL_UNEXPECTED - A failure that could result in
 |          the product becoming unstable.
 |
 |  In the database, the log level is reflected as a number from 1 to 6
 |  where LEVEL_STATEMENT = 1 and LEVEL_UNEXPECTED = 6
 |
 | REQUIRES                                                                   |
 |    line_of_text           The line of text that will be displayed.         |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |    26 Mar 93  Nigel Smith      Created                                     |
 |    12-NOV-97	 OSTEINME	  added file io debugging		      |
 |    24-SEP-03  M Raymond        Modified debug routine to parse message
 |                                for module name and assess message level
 |                                Also added parameters that map to the
 |                                prefix, module, and level.
 |                                                                            |
 *----------------------------------------------------------------------------*/

procedure file_debug(line in varchar2) IS
x number;
begin
  if (pg_file_name is not null) THEN
    utl_file.put_line(pg_fp, line);
    utl_file.fflush(pg_fp);
  end if;
end file_debug;

procedure enable_file_debug(path_name in varchar2,
			    file_name in varchar2) IS

x number;
begin

  if (pg_file_name is null) THEN
    pg_fp := utl_file.fopen(path_name, file_name, 'a');
    pg_file_name := file_name;
    pg_path_name := path_name;
  end if;

-- fnd_message does not compile here, since it is redefined in this scope.

    exception
     when utl_file.invalid_path then
--        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
--        fnd_message.set_token('GENERIC_TEXT', 'Invalid path: '||path_name);
--     x := 1/0;
        app_exception.raise_exception;
     when utl_file.invalid_mode then
--        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
--        fnd_message.set_token('GENERIC_TEXT', 'Cannot open file '||file_name||
--                        ' in write mode.');
        app_exception.raise_exception;

end ;

procedure disable_file_debug is
begin
  if (pg_file_name is not null) THEN
    utl_file.fclose(pg_fp);
  end if;
end;

procedure debug( line in varchar2,
                 msg_prefix in varchar2,
                 msg_module in varchar2,
                 msg_level in  number
                  ) is
  l_msg_prefix  varchar2(64);
  l_msg_level   number;
  l_msg_module  varchar2(256);
  l_beg_end_suffix varchar2(15);
  l_org_cnt number;
  l_line varchar2(32767);
begin
    l_line := line;

    IF (pg_file_name IS NOT NULL) THEN
      file_debug(l_line);
    ELSE
      /* Bug 3161609 - Implement FND debugging routines for all plsql
         and resourceareas of product.  Note that the prior version
         of debug logic would send
         strings of 255 bytes of message text.  The current version can take
         single strings of 4000 bytes or less so I have discarded the looping
         mechanism */

      l_msg_prefix := 'a' || 'r' || '.' || msg_prefix || '.';

      /* EXCEPTIONS:
         -  if length of message > 99
         -  if text contains (s)
      */
      IF lengthb(l_line) > 99 OR
         INSTRB(l_line, '(s)') <> 0
      THEN
         l_msg_level := FND_LOG.LEVEL_STATEMENT;
         l_msg_module := l_msg_prefix || NVL(g_msg_module, 'UNKNOWN');

         -- This logs the message
         /* Bug 4361955 */
	 IF ( l_msg_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
         THEN
        	 FND_LOG.STRING(l_msg_level, l_msg_module, substr(l_line,1,4000));
	 END IF;

         RETURN;
      END IF;

      -- set msg_level for this message
      IF (msg_level IS NULL)
      THEN
         IF (INSTRB(upper(l_line), 'EXCEPTION') <> 0)
         THEN
            l_msg_level := FND_LOG.LEVEL_EXCEPTION;
         ELSIF (INSTRB(l_line, ')+') <> 0 OR
                INSTRB(l_line, '+)') <> 0)
         THEN
            l_msg_level := FND_LOG.LEVEL_PROCEDURE;
            l_beg_end_suffix := '.begin';
         ELSIF (INSTRB(l_line, ')-') <> 0 OR
                INSTRB(l_line, '-)') <> 0)
         THEN
            l_msg_level := FND_LOG.LEVEL_PROCEDURE;
            l_beg_end_suffix := '.end';
         ELSE
            l_msg_level := FND_LOG.LEVEL_STATEMENT;
            l_beg_end_suffix := NULL;
         END IF;
      ELSE
         /* Verify that level is between 1 and 6 */
         IF msg_level >= 1 AND msg_level <= 6
         THEN
            l_msg_level := msg_level;
         ELSE
            /* Invalid message level, default 1 */
            l_msg_level := 1;
         END IF;
      END IF;

      -- set module for this message
      IF (msg_module IS NULL)
      THEN

         -- chop off extraneous stuff on right end of string
         l_msg_module := SUBSTRB(RTRIM(l_line), 1,
                                INSTRB(l_line, '(') - 1);

         -- chop off extraneous stuff on left
         l_msg_module := SUBSTRB(l_msg_module,
                             INSTRB(l_msg_module, ' ', -3 ) + 1);

            /* If we were unable to get a module name, use
               the global (previously stored)  one */
            IF l_msg_module IS NULL
            THEN
               l_msg_module := NVL(g_msg_module, 'UNKNOWN');
            ELSE
               g_msg_module := l_msg_module;
            END IF;

         l_msg_module := l_msg_prefix || l_msg_module || l_beg_end_suffix;
      ELSE
         l_msg_module := l_msg_prefix || msg_module;
      END IF;

      -- This actually logs the message
	  /* Bug 4361955 */
	 IF ( l_msg_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
         THEN
	      FND_LOG.STRING(l_msg_level, l_msg_module, l_line);
	 END IF;

    END IF;
exception
  when others then
      raise;
end;

procedure enable_debug is
begin
   debug_flag := true;
   -- dbms_output.enable;
end;

procedure enable_debug( buffer_size NUMBER ) is
begin
   debug_flag := true;
   -- dbms_output.enable( buffer_size );
end;

procedure disable_debug is
begin
   debug_flag := false;
end;

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    set who information                                                     |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Set foundation who information so that all future packages and          |
 |    procedures can reference the correct value.                             |
 |                                                                            |
 | REQUIRES                                                                   |
 |                                                                            |
 |    user_id                    Foundation User ID                           |
 |    request_id                 Concurrent Request ID                        |
 |    program_application_id                                                  |
 |    program_id                                                              |
 |    last_update_login                                                       |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |      2/11/93         Nigel Smith     Created                               |
 |                                                                            |
 *----------------------------------------------------------------------------*/

PROCEDURE set_who_information( user_id in number,
                               request_id in number,
                               program_application_id in number,
                               program_id in number,
                               last_update_login in number ) IS
BEGIN

    debug( '>> SET_WHO_INFORMATION( ' ||
	to_char(user_id) || ', ' ||
	to_char( request_id ) || ', ' ||
	to_char(program_application_id ) || ', ' ||
	to_char( program_id ) || ', ' ||
	to_char( last_update_login ) ||  ' )' );


/*
	BUGFIX: 226504, row who information not correct
	===============================================

*/

    profile.user_id := nvl(fnd_global.user_id, -1);
    profile.request_id := fnd_global.conc_request_id;
    profile.program_application_id := fnd_global.prog_appl_id;
    profile.program_id := fnd_global.conc_program_id;
    profile.last_update_login := fnd_global.conc_login_id;

    debug( '<< SET_WHO_INFORMATION' );

END;

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    set application information                                             |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Set foundation application id and language variables, so that all       |
 |    future calls to packaged procedures can reference the correct value.    |
 |                                                                            |
 | REQUIRES                                                                   |
 |    application_id                                                          |
 |    language_id                                                             |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |      2/11/93         Nigel Smith     Created                               |
 |     05/20/93         Nigel Smith     Checks that params are not null       |
 |                                                                            |
 *----------------------------------------------------------------------------*/

PROCEDURE set_application_information( appl_id in number,
                                       language_id in number ) is
          l_base_language varchar2(50);
BEGIN
    if appl_id is null
    then
       fnd_message( 'AR_PP_NULL_PARAMETER', 'OBJECT', 'SET_APPLICATION_INFORMATION',
                                            'PARAMETER', 'APPL_ID' );
    end if;
    if language_id is null
    then
       fnd_message( 'AR_PP_NULL_PARAMETER', 'OBJECT', 'SET_APPLICATION_INFORMATION',
                                            'PARAMETER', 'LANGUAGE_ID' );
    end if;

    application_id := 222;
    profile.language_id := 0;
    /* base_language  returns NLS Language */
    profile.language_code := fnd_global.base_language;

END ;

/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    ceil (in date ) return date                                             |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Rounds any given date to the last second before midnight of that night  |
 |    usefull in ensuring any given date is between trunc(start) and ceil(max)|
 |                                                                            |
 |                                                                            |
 | REQUIRES                                                                   |
 |    d                 - Any date and time value                             |
 |                                                                            |
 | RETURNS                                                                    |
 |    Date set to DD-MON-YYYY 23:59:59                                        |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |      2/11/93         Nigel Smith     Created                               |
 |                                                                            |
 *----------------------------------------------------------------------------*/


function ceil( d in date ) return date IS
begin
   return( trunc( d + 1 ) - 1/24/60/60 );
end;

/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTIONS                                                           |
 |    Bit Wise Operations                                                     |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Provides support for bitwise operations within PL/SQL, useful for       |
 |    control flags etc.                                                      |
 |                                                                            |
 |                                                                            |
 | FUNCTIONS                                                                  |
 |    even( n )         -- Returns true if n is even                          |
 |    odd( n )          -- Returns true if n is odd                           |
 |    set_flag          -- Sets a given flag in the options variable          |
 |    clear_flag        -- Clears a given flag from the options variable      |
 |    check_flag        -- Returns true if a given flag is set                |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |    All flags must be powers of 10.                                         |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |      2/11/93         Nigel Smith     Created                               |
 |                                                                            |
 *----------------------------------------------------------------------------*/

function even( n in number ) return boolean is
begin
   if ( trunc(n) / 2 ) = trunc( trunc(n) / 2 )
   then
      return( TRUE );
   else
      return( FALSE );
   end if;
end ;

function odd( n in number ) return boolean is
begin
   return( not even( n ) );
end ;


function check_flag( options in number, flag in number ) return boolean is
begin
   return( odd( options / flag ) );
end;


procedure clear_flag( options in out NOCOPY number, flag in number ) is
begin
   if check_flag( options, flag )
   then
      options := options - flag;
   end if;
end;

procedure set_flag( options in out NOCOPY number, flag in number ) is
begin
   if not check_flag( options, flag )
   then
      options := options + flag;
   end if;
end;


/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    fnd_message                                                             |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Interfaces with AOL's message dictionary                                |
 |                                                                            |
 |    Called as a function, it returns the message text with any tokens       |
 |    expanded to the passed token values.                                    |
 |                                                                            |
 |    Called as a procedure, it raises an oracle error ( -20000 ) and the     |
 |    message number, text with expanded tokens for the passed message name   |
 |                                                                            |
 | REQUIRES                                                                   |
 |    Message Name      - Message dictionary name                             |
 |    TOKEN, VALUE      - Up to four pairs of token, values                   |
 |                                                                            |
 | RETURNS                                                                    |
 |    Expanded message text, or if called as a procedure an oracle error      |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |    application_id is currently held in package ar, should be in AOL        |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |   2/11/93    Nigel Smith   Created                                         |
 |   03/23/93   Nigel Smith   Select from fnd_messages now uses application_id|
 |                            and language id from session profiles           |
 |   03/10/00   Tara Welby    Add substrb                                     |
 |                                                                            |
 *----------------------------------------------------------------------------*/


function fnd_message( md_options in number, msg_name in varchar2 ) return varchar2 is


/*----------------------------------------------------------------------------*
 | PRIVATE CURSOR                                                             |
 |      fnd_message_c                                                         |
 |                                                                            |
 | DESCRIPTION                                                                |
 |      Gets the message_number and message_text from fnd_messages            |
 |                                                                            |
 *----------------------------------------------------------------------------*/

    /* bug2995947 : Replaced profile.language_code with userenv('LANG')
                    in order to get proper language message text */
    cursor fnd_message_c( app_id in number, msg_name in varchar2 ) IS
       select message_number, message_text
       from  fnd_new_messages
       where application_id = app_id
       and   language_code = userenv('LANG')
       and   message_name = msg_name;

/*---------------------------------------------------------------------------*
 | PRIVATE DATATYPES                                                         |
 |                                                                           |
 *---------------------------------------------------------------------------*/

         rtn_msg        varchar2(2000) := '';
         message_number number;
         message_text   varchar2(2000);

begin


   if md_options = INT_MD_MSG_NAME
   then
      --- Only needs message name, dont check the database.
      return( msg_name );
   else
      --- Need information, held in the database.

        OPEN fnd_message_c( application_id, msg_name );
        FETCH fnd_message_c into message_number, message_text;

        if fnd_message_c%FOUND
        THEN

           if check_flag( MD_OPTIONS, INT_MD_MSG_NUMBER )
           then
              rtn_msg := 'APP-' || replace(to_char( message_number, '00000' ), ' ', null) ;
           end if;

           if check_flag( MD_OPTIONS, INT_MD_MSG_NAME )
           then
              rtn_msg := msg_name;
           end if;

           if check_flag( MD_OPTIONS, INT_MD_MSG_TEXT )
           then
              if rtn_msg is null
              then
                 rtn_msg := ltrim(message_text);
              else
-- TAW 1222450 PL/SQL Numeric or Value Error add substrb
                rtn_msg := substrb((rtn_msg || ': ' || message_text),1,2000)  ;
              end if;
           end if;

        ELSE
             rtn_msg := 'APP-00001: Unable to find message: ' || msg_name ;
        END IF;
        CLOSE fnd_message_c;
        return( rtn_msg );
   end if;
end;

function fnd_message( msg_name in varchar2 ) return varchar2 is
begin
        return( fnd_message( INT_MD_MSG_TEXT, msg_name ));
end;

function msg_tkn_expand( md_options in number, msg in varchar2, T1 in varchar2, V1 in varchar2 ) return varchar2 is
begin
   if md_options = md_msg_name -- User only want message names, no tokens!
   then
      return(msg);
   else
      if T1 is not null and instr( msg, '&' || T1 ) = 0
      then -- Token not found, append token to end of string with value.
         return( msg || ' '||T1 ||'='||V1 );
      else
         return( REPLACE( msg, '&' || T1, V1 ));
      end if;
   end if;
end;

function fnd_message( md_options in number, msg_name in varchar2, T1 in varchar2, V1 in varchar2 ) return varchar2 is
begin
         return( msg_tkn_expand( md_options, fnd_message( md_options, msg_name ), T1, V1 ) );
end;

function fnd_message( msg_name in varchar2, T1 in varchar2, V1 in varchar2 ) return varchar2 is
begin
         return( msg_tkn_expand( md_options, fnd_message( msg_name ), T1, V1 ) );
end;

function fnd_message( md_options in number, msg_name in varchar2,
                      T1 in varchar2, V1 in varchar2,
                      T2 in varchar2, V2 in varchar2  ) return varchar2 is
begin
   return( msg_tkn_expand( md_options, fnd_message( md_options, msg_name, T1, V1 ), T2, V2 ));
end;


function fnd_message( msg_name in varchar2,
                      T1 in varchar2, V1 in varchar2,
                      T2 in varchar2, V2 in varchar2  ) return varchar2 is
begin
   return( msg_tkn_expand( md_options, fnd_message( msg_name, T1, V1 ), T2, V2 ));
end;

function fnd_message( md_options in number, msg_name in varchar2, T1 in varchar2, V1 in varchar2, T2 in varchar2, V2 in varchar2,
                                            T3 in varchar2, V3 in varchar2 ) return varchar2 is
begin
        return( msg_tkn_expand( md_options, fnd_message( md_options, msg_name, T1, V1, T2, V2 ), T3, V3 ));
end;

function fnd_message( msg_name in varchar2, T1 in varchar2, V1 in varchar2, T2 in varchar2, V2 in varchar2,
                                            T3 in varchar2, V3 in varchar2 ) return varchar2 is
begin
   return( msg_tkn_expand( md_options, fnd_message( msg_name, T1, V1, T2, V2 ), T3, V3 ));
end;

function fnd_message( msg_name in varchar2, T1 in varchar2, V1 in varchar2, T2 in varchar2, V2 in varchar2,
                                            T3 in varchar2, V3 in varchar2, T4 in varchar2, V4 in varchar2 ) return varchar2 is
begin
   return( msg_tkn_expand( md_options, fnd_message( msg_name, T1, V1, T2, V2, T3, V3 ), T4, V4 ));
end;

function fnd_message( md_options in number, msg_name in varchar2, T1 in varchar2, V1 in varchar2, T2 in varchar2, V2 in varchar2,
                                            T3 in varchar2, V3 in varchar2, T4 in varchar2, V4 in varchar2 ) return varchar2 is
begin
   return( msg_tkn_expand( md_options, fnd_message( md_options, msg_name, T1, V1, T2, V2, T3, V3 ), T4, V4 ));
end;

procedure fnd_message is
begin
   raise_application_error( AR_ERROR_NUMBER, fnd_message( md_options ));
end;

procedure fnd_message(md_options in number ) is
begin
   raise_application_error( AR_ERROR_NUMBER, fnd_message( md_options ));
end;

procedure fnd_message( md_options in number, msg_name in varchar2 ) is
begin
        raise_application_error(AR_ERROR_NUMBER, fnd_message( md_options, msg_name ) );
end;

procedure fnd_message( md_options in number,
                       msg_name in varchar2, T1 in varchar2, V1 in VARCHAR2 ) is
begin
        raise_application_error(AR_ERROR_NUMBER, fnd_message( md_options, msg_name, T1, V1 ) );
end;

procedure fnd_message( md_options in number, msg_name in varchar2, T1 in varchar2, V1 in VARCHAR2,
                                             T2 in varchar2, V2 in VARCHAR2 ) is
begin
        raise_application_error(AR_ERROR_NUMBER, fnd_message( md_options, msg_name, T1, V1, T2, V2 ) );
end;

procedure fnd_message( md_options in number, msg_name in varchar2, T1 in varchar2, V1 in VARCHAR2,
                                             T2 in varchar2, V2 in VARCHAR2,
                                             T3 in varchar2, V3 in VARCHAR2 ) is
begin
   raise_application_error(AR_ERROR_NUMBER, fnd_message( md_options, msg_name, T1, V1, T2, V2, T3, V3 ) );
end;

procedure fnd_message( md_options in number, msg_name in varchar2, T1 in varchar2, V1 in VARCHAR2,
                                             T2 in varchar2, V2 in VARCHAR2,
                                             T3 in varchar2, V3 in VARCHAR2,
                                             T4 in varchar2, V4 in VARCHAR2 ) is
begin
   raise_application_error(AR_ERROR_NUMBER, fnd_message( md_options, msg_name, T1, V1, T2, V2, T3, V3, T4, V4 ) );
end;


/*---------------------------------------------------------------------------*
 |                                                                           |
 | PUBLIC FUNCTION: previous_message                                         |
 |                                                                           |
 |   These functions are required because PL/SQL does not return the user    |
 |   defined error message in sqlerrm. Optional message dictionary control   |
 |   flags are used to control token expansion, message lookup etc.          |
 |                                                                           |
 | EXAMPLES                                                                  |
 |                                                                           |
 |   str := previous_message;                                                |
 |   str := previous_message( md_msg_name + md_msg_tokens );                 |
 |                                                                           |
 *---------------------------------------------------------------------------*/

function fnd_message return varchar2 is
begin
   return( fnd_message( MD_MSG_NAME ) );
end;

function fnd_message( md_options in number )  return varchar2 is
begin
   return( previous_message( md_options ) );
end;

function previous_message( md_options in number ) return varchar2 is
   str varchar2(800);
begin
   str := fnd_message(  md_options,
                        previous_msg.name,
                        previous_msg.t1,
                        previous_msg.v1,
                        previous_msg.t2,
                        previous_msg.v2,
                        previous_msg.t3,
                        previous_msg.v3,
                        previous_msg.t4,
                        previous_msg.v4 );

   if check_flag( md_options, md_msg_tokens )
   then
      str := str || ' ' ||
          previous_msg.t1 || ' ' ||
          previous_msg.v1 || ' ' ||
          previous_msg.t2 || ' ' ||
          previous_msg.v2 || ' ' ||
          previous_msg.t3 || ' ' ||
          previous_msg.t3 || ' ' ||
          previous_msg.t4 || ' ' ||
          previous_msg.t4;
   end if;

  return(str);

end;



function previous_message return varchar2 is
begin
   return( fnd_message( MD_MSG_NAME,
                        previous_msg.name,
                        previous_msg.t1,
                        previous_msg.v1,
                        previous_msg.t2,
                        previous_msg.v2,
                        previous_msg.t3,
                        previous_msg.t3,
                        previous_msg.t4,
                        previous_msg.t4 ));

end;


procedure fnd_message( msg_name in varchar2 ) is
begin
   previous_msg.name := msg_name;
   previous_msg.t1 := null;
   previous_msg.v1 := null;
   previous_msg.t2 := null;
   previous_msg.v2 := null;
   previous_msg.t3 := null;
   previous_msg.v3 := null;
   previous_msg.t4 := null;
   previous_msg.v4 := null;
   raise_application_error(AR_ERROR_NUMBER, fnd_message( md_options, msg_name ) );
end;

procedure fnd_message( msg_name in varchar2, T1 in varchar2, V1 in VARCHAR2 ) is
begin
   previous_msg.name := msg_name;
   previous_msg.t1 := t1;
   previous_msg.v1 := v1;
   previous_msg.t2 := null;
   previous_msg.v2 := null;
   previous_msg.t3 := null;
   previous_msg.v3 := null;
   previous_msg.t4 := null;
   previous_msg.v4 := null;
   raise_application_error(AR_ERROR_NUMBER, fnd_message( md_options, msg_name, T1, V1 ) );
end;

procedure fnd_message( msg_name in varchar2, T1 in varchar2, V1 in VARCHAR2,
                                             T2 in varchar2, V2 in VARCHAR2 ) is
begin
   previous_msg.name := msg_name;
   previous_msg.t1 := t1;
   previous_msg.v1 := v1;
   previous_msg.t2 := t2;
   previous_msg.v2 := v2;
   previous_msg.t3 := null;
   previous_msg.v3 := null;
   previous_msg.t4 := null;
   previous_msg.v4 := null;
   raise_application_error(AR_ERROR_NUMBER, fnd_message( md_options, msg_name, T1, V1, T2, V2 ) );
end;

procedure fnd_message( msg_name in varchar2, T1 in varchar2, V1 in VARCHAR2,
                                             T2 in varchar2, V2 in VARCHAR2,
                                             T3 in varchar2, V3 in VARCHAR2 ) is
begin
   previous_msg.name := msg_name;
   previous_msg.t1 := t1;
   previous_msg.v1 := v1;
   previous_msg.t2 := t2;
   previous_msg.v2 := v2;
   previous_msg.t3 := t3;
   previous_msg.v3 := v3;
   previous_msg.t4 := null;
   previous_msg.v4 := null;
   raise_application_error(AR_ERROR_NUMBER, fnd_message( md_options, msg_name, T1, V1, T2, V2, T3, V3 ) );
end;

procedure fnd_message( msg_name in varchar2, T1 in varchar2, V1 in VARCHAR2,
                                             T2 in varchar2, V2 in VARCHAR2,
                                             T3 in varchar2, V3 in VARCHAR2,
                                             T4 in varchar2, V4 in VARCHAR2 ) is
begin
   previous_msg.name := msg_name;
   previous_msg.t1 := t1;
   previous_msg.v1 := v1;
   previous_msg.t2 := t2;
   previous_msg.v2 := v2;
   previous_msg.t3 := t3;
   previous_msg.v3 := v3;
   previous_msg.t4 := t4;
   previous_msg.v4 := v4;
   raise_application_error(AR_ERROR_NUMBER, fnd_message( md_options, msg_name, T1, V1, T2, V2, T3, V3, T4, V4 ) );
end;

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    gl_period_info()                                                        |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function returns information about the GL period that contains     |
 |      a given GL date.                                                      |
 |    It does not information about adjustment periods.                       |
 |    In the case of overlapping periods, the function chooses the period with|
 |    the lowest period num.                                                  |
 |                                                                            |
 | REQUIRES                                                                   |
 |    gl_date          - A date in the desired period                         |
 |    start_date       - Returned values                                      |
 |    end_date                      /                                         |
 |    closing_status               /                                          |
 |    period_type                 /                                           |
 |    period_year                /                                            |
 |    period_num                /                                             |
 |    quarter_num              /                                              |
 |    period_name             /                                               |
 |                                                                            |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |    None                                                                    |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |    Only the first record returned by the cursor is used. The others        |
 |    represent overlapping periods.                                          |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 *----------------------------------------------------------------------------*/


procedure gl_period_info(    gl_date        in  date,
                             period_name    out NOCOPY varchar2,
                             start_date     out NOCOPY date,
                             end_date       out NOCOPY date,
                             closing_status out NOCOPY varchar2,
                             period_type    out NOCOPY varchar2,
                             period_year    out NOCOPY number,
                             period_num     out NOCOPY number,
                             quarter_num    out NOCOPY number
 )  is


    cursor gl_periods_c( gl_date in date ) IS
    select  period_name,
            start_date,
            end_date,
            closing_status,
            period_type,
            period_year,
            period_num,
            quarter_num
      from gl_period_statuses ps
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;09/11/2002*/
      where   ps.set_of_books_id = sysparm.set_of_books_id
/* Multi-Org Access Control Changes for SSA;End;anukumar;09/11/2002*/
--end anuj
    and     application_id = 222
    and     adjustment_period_flag = 'N'
    and     trunc(gl_date) between start_date and end_date
    order by period_num
   ;

  /*  cursor gl_periods_c( gl_date in date ) IS
    select  period_name,
            start_date,
            end_date,
            closing_status,
            period_type,
            period_year,
            period_num,
            quarter_num
      from  gl_period_statuses ps,
            ar_system_parameters p
    where   ps.set_of_books_id = p.set_of_books_id
    and     application_id = 222
    and     adjustment_period_flag = 'N'
    and     trunc(gl_date) between start_date and end_date
    order by period_num
   ;
*/


/*---------------------------------------------------------------------------*
 | PRIVATE DATATYPES                                                         |
 |                                                                           |
 *---------------------------------------------------------------------------*/


begin

   period_name := '';
   start_date := '';
   end_date := '';
   closing_status := '';


   OPEN gl_periods_c(gl_date);

   FETCH gl_periods_c
    into period_name,
         start_date,
         end_date,
         closing_status,
         period_type,
         period_year,
         period_num,
         quarter_num;

   CLOSE gl_periods_c;


end;


/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    gl_period_name()                                                        |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Returns the name of the GL period that contains a given GL date.        |
 |    The function does not return the names of adjustment periods.           |
 |    In the case of overlapping periods, the function chooses the period with|
 |    the lowest period num.                                                  |
 |                                                                            |
 | REQUIRES                                                                   |
 |    gl_date  - A date in the desired period                                 |
 |                                                                            |
 | RETURNS                                                                    |
 |    The name of the peruod that contains gl_date.                           |
 |    If the gl_date is not in a period, null is returned.                    |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |    None                                                                    |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 *----------------------------------------------------------------------------*/

function gl_period_name( gl_date in date ) return varchar2 is

  period_name    varchar2(26);
  start_date     date;
  end_date       date;
  closing_status varchar(1);
  period_type    varchar2(15);
  period_year    number(15);
  period_num     number(15);
  quarter_num    number(15);


begin

     arp_standard.gl_period_info( gl_date,
                                  period_name,
                                  start_date,
                                  end_date,
                                  closing_status,
                                  period_type,
                                  period_year,
                                  period_num,
                                  quarter_num);

     return(period_name);


end;

/*----------------------------------------------------------------------------*
 | PRIVATE FUNCTION                                                           |
 |   is_gl_date_valid()                                                       |
 |                                                                            |
 | DESCRIPTION                                                                |
 |   This function determines if a given date is a valid GL date.             |
 |                                                                            |
 |   A GL date is considered valid if all of the following conditions are     |
 |   true.                                                                    |
 |                                                                            |
 |    1) The date is in an Open or Future period, or it is in a Never Opened  |
 |       period and the Allow Not Open Flag is set to Yes.                    |
 |                                                                            |
 |    2) The date is greater than or equal to the trx_date and the three      |
 |       validation dates if they are specified.                              |
 |                                                                            |
 |    3) The period cannot be an Adjustment period.                           |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 |                                                                            |
 | PARAMETERS                                                                 |
 |   p_gl_date               IN   Optional                                    |
 |   p_trx_date              IN   Optional                                    |
 |   p_validation_date1      IN   Optional                                    |
 |   p_validation_date2      IN   Optional                                    |
 |   p_validation_date3      IN   Optional                                    |
 |   p_allow_not_open_flag   IN   Optional  Default:  N                       |
 |   p_set_of_books_id       IN   Optional  Default:  AR's set of books       |
 |   p_application_id        IN   Optional  Default:  222                     |
 |   p_check_period_status   IN   Optional  Default:  TRUE                    |
 |                                                                            |
 |   If p_check_period_status is TRUE, the period status of the date is       |
 |   checked. Otherwise, it is not chacked.                                   |
 |                                                                            |
 | RETURNS                                                                    |
 |   TRUE if the date is valid, FALSE otherwise.                              |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |    None                                                                    |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | **** IMPORTANT NOTE ****************************************************** |
 | A direct copy of this function exists in the package ARP_VIEW_CONSTANTS.   |
 | Any modifications to this function MUST be made in this package also.      |
 | ************************************************************************** |
 |                                                                            |
 | HISTORY                                                                    |
 |    16-JUN-94  Charlie Tomberg    Created.                                  |
 |    20-SEP-96  Karen Lawrance     Added note about ARP_VIEW_CONSTANTS       |
 |       		            package.                                  |
 |    05-AUG-99	 Genneva Wang       955813 Truncate time stamp for input      |
 | 				    parameter 				      |
 |    26-Nov-01	 Ramakant Alat      Cached the gl_dates in a PL/SQL table     |
 | 				    to improve performance.                   |
 |                                                                            |
 *----------------------------------------------------------------------------*/

function is_gl_date_valid(
                            p_gl_date                in date,
                            p_trx_date               in date,
                            p_validation_date1       in date,
                            p_validation_date2       in date,
                            p_validation_date3       in date,
                            p_allow_not_open_flag    in varchar2,
                            p_set_of_books_id        in number,
                            p_application_id         in number,
                            p_check_period_status    in boolean default TRUE)
                        return boolean is

  return_value boolean;
  num_return_value number;
  l_gl_date 		date;
  l_trx_date		date;
  l_validation_date1	date;
  l_validation_date2	date;
  l_validation_date3	date;
  l_request_id          number; /*3264603*/

begin
  /* Bug fix: 955813 */
  /*------------------------------+
   |  Initialize input variables  |
   +------------------------------*/
   l_gl_date := trunc(p_gl_date);
   l_trx_date := trunc(p_trx_date);
   l_validation_date1 := trunc(p_validation_date1);
   l_validation_date2 := trunc(p_validation_date2);
   l_validation_date3 := trunc(p_validation_date3);
   l_request_id       := arp_global.request_id; /* bug fix 3264603*/

   if (l_gl_date is null)
   then return(FALSE);
   end if;

   if (l_gl_date < nvl(l_validation_date1, l_gl_date) )
   then return(FALSE);
   end if;

   if (l_gl_date < nvl(l_validation_date2, l_gl_date) )
   then return(FALSE);
   end if;

   if (l_gl_date < nvl(l_validation_date3, l_gl_date) )
   then return(FALSE);
   end if;

   if (p_check_period_status = TRUE)
   then

      -- Bug# 2123155 - Cached the gl_dates in a PL/SQL
      -- table to improve performance
    IF l_request_id IS NOT NULL THEN /* bug fix 3264603 */

      if p_allow_not_open_flag = 'Y' then
	 if pg_period.EXISTS(to_char(l_gl_date,'j')) then
	    null;
         else
            select decode(max(period_name),
                          '', 0,
                              1)
            into   pg_period(to_char(l_gl_date,'j'))
            from   gl_period_statuses
            where  application_id         = p_application_id
            and    set_of_books_id        = p_set_of_books_id
            and    adjustment_period_flag = 'N'
            and    l_gl_date between start_date and end_date
            and    closing_status in ('O', 'F', 'N') ;

         end if;

	 num_return_value := pg_period(to_char(l_gl_date,'j'));
      else
	 if pg_period_open.EXISTS(to_char(l_gl_date,'j')) then
	    null;
         else
            select decode(max(period_name),
                          '', 0,
                              1)
            into   pg_period_open(to_char(l_gl_date,'j'))
            from   gl_period_statuses
            where  application_id         = p_application_id
            and    set_of_books_id        = p_set_of_books_id
            and    adjustment_period_flag = 'N'
            and    l_gl_date between start_date and end_date
            and    closing_status in ('O', 'F');
         end if;

	 num_return_value := pg_period_open(to_char(l_gl_date,'j'));

      end if;
    ELSE /* Bug fix 3264603*/

      /* Bug 3839973/3828312 - Removed extra OR condition and
         set validation sql to execute based on value of
         p_allow_not_open_flag */
      IF (p_allow_not_open_flag = 'Y')
      THEN
        select decode(max(period_name),
                        '', 0,
                        1)
        into   num_return_value
        from   gl_period_statuses
        where  application_id         = p_application_id
        and    set_of_books_id        = p_set_of_books_id
        and    adjustment_period_flag = 'N'
        and    l_gl_date between start_date and end_date
        and    closing_status in ('O', 'F', 'N');
      ELSE
        select decode(max(period_name),
                        '', 0,
                        1)
        into   num_return_value
        from   gl_period_statuses
        where  application_id         = p_application_id
        and    set_of_books_id        = p_set_of_books_id
        and    adjustment_period_flag = 'N'
        and    l_gl_date between start_date and end_date
        and    closing_status in ('O', 'F');
      END IF;
    END IF;

      if (num_return_value = 1)
      then return_value := TRUE;
      else return_value := FALSE;
      end if;

   else return_value := TRUE;
   end if;

   return(return_value);

end;  /* function is_gl_date_valid() */


/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    Validate_And_Default_GL_Date()                                          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function returns a default GL date. If an invalid GL date is       |
 |   specifoed as a parameter, the function "bumps" it to a valid period.     |
 |   The defaulting and bumping algorithm is as follows:                      |
 |                                                                            |
 |   If any date violates any of the requirements listed above, the next      |
 |   defaulting method is used. If the date of the period to use is not       |
 |   specified, use the first day of the period if it is greater than         |
 |   nvl(trx_date, sysdate), otherwise use the last day of the period.        |
 |                                                                            |
 |   1) Use the passed in gl_date.                                            |
 |                                                                            |
 |   2) Use passed in default_date1.                                          |
 |                                                                            |
 |   3) Use passed in default_date2.                                          |
 |                                                                            |
 |   4) Use passed in default_date3.                                          |
 |                                                                            |
 |   5) If sysdate is in a Future period, use the last date of the last       |
 |      Open period that is less than sysdate.                                |
 |   5b) Bug 2824692 - if passed date is in closed period (for advanced rule
 |    transactions, use first day of next period
 |                                                                            |
 |   6) Use sysdate.                                                          |
 |                                                                            |
 |                                                                            |
 |   7) If the trx_date is known, use trx_date.                               |
 |                                                                            |
 |   8) If the trx_date is known, use the first date of the first Open period |
 |      that is greater than or equal to the trx_date.                        |
 |                                                                            |
 |   9) If the trx_date is not known, use the first date of the first Open    |
 |      period that is greater than or equal to sysdate.                      |
 |                                                                            |
 |  10) If the trx_date is not known, use the last open period.               |
 |                                                                            |
 |                                                                            |
 |  11) If the trx_date is known, use the first date of the first Future      |
 |      period that is greater than or equal to the trx_date.                 |
 |                                                                            |
 |  12) If the trx_date is not known, use the first date of the first Future  |
 |      period that is greater than or equal to sysdate.                      |
 |                                                                            |
 |  13) If the trx_date is not known, use the last Future period.             |
 |                                                                            |
 |  14) No default.                                                           |
 |                                                                            |
 |                                                                            |
 |   A GL date is considered valid if all of the following conditions are     |
 |   true.                                                                    |
 |                                                                            |
 |    1) The date is in an Open or Future period, or it is in a Never Opened  |
 |       period and the Allow Not Open Flag is set to Yes.                    |
 |                                                                            |
 |    2) The date is greater than or equal to the trx_date and the three      |
 |       validation dates if they are specified.                              |
 |                                                                            |
 |    3) The period cannot be an Adjustment period.                           |
 |                                                                            |
 | PARAMETERS                                                                 |
 |   gl_date                 IN   Optional                                    |
 |   trx_date                IN   Optional                                    |
 |   validation_date1        IN   Optional                                    |
 |   validation_date2        IN   Optional                                    |
 |   validation_date3        IN   Optional                                    |
 |   default_date1           IN   Optional                                    |
 |   default_date2           IN   Optional                                    |
 |   default_date3           IN   Optional                                    |
 |   p_allow_not_open_flag   IN   Optional  Default:  N                       |
 |   p_invoicing_rule_id     IN   Optional                                    |
 |   p_set_of_books_id       IN   Optional  Default:  AR's set of books       |
 |   p_application_id        IN   Optional  Default:  222                     |
 |   default_gl_date        OUT NOCOPY  Mandatory                                    |
 |   defaulting_rule_used   OUT NOCOPY  Optional                                     |
 |   error_message          OUT NOCOPY  Optional                                     |
 |                                                                            |
 | RETURNS                                                                    |
 |   FALSE if an Oracle error occurrs, TRUE otherwise.                        |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |    None                                                                    |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | **** IMPORTANT NOTE ****************************************************** |
 | A direct copy of this function exists in the package ARP_VIEW_CONSTANTS.   |
 | Any modifications to this function MUST be made in this package also.      |
 | ************************************************************************** |
 |                                                                            |
 | HISTORY                                                                    |
 |    16-JUN-94  Charlie Tomberg    Created.                                  |
 |    20-SEP-96  Karen Lawrance     Added note about ARP_VIEW_CONSTANTS       |
 |       		            package.                                  |
 |    27-MAR-03  Michael Raymond    Bug 2824692 - added piece of code to      |
 |                                  default gl_date for ADVANCED invoices     |
 |                                  to the first day of the next open period  |
 |                                  when the gl_date is in closed period.i    |
 |                                                                            |
 |    17-Nov-04  Debbie Jancis      Forward ported bug 3477990:  CM           |
 |                                  distribution getting created in a closed  |
 |                                  period.                                   |
 *----------------------------------------------------------------------------*/

function validate_and_default_gl_date(
                                       gl_date                in date,
                                       trx_date               in date,
                                       validation_date1       in date,
                                       validation_date2       in date,
                                       validation_date3       in date,
                                       default_date1          in date,
                                       default_date2          in date,
                                       default_date3          in date,
                                       p_allow_not_open_flag  in varchar2,
                                       p_invoicing_rule_id    in varchar2,
                                       p_set_of_books_id      in number,
                                       p_application_id       in number,
                                       default_gl_date       out NOCOPY date,
                                       defaulting_rule_used  out NOCOPY varchar2,
                                       error_message         out NOCOPY varchar2
                                     ) return boolean is


  allow_not_open_flag varchar2(2);
  h_application_id      number;
  h_set_of_books_id     number;
  candidate_gl_date date;
  candidate_start_gl_date date;
  candidate_end_gl_date date;

  l_gl_date             date;
  l_trx_date            date;
  l_validation_date1    date;
  l_validation_date2    date;
  l_validation_date3    date;
  l_default_date1       date;
  l_default_date2       date;
  l_default_date3       date;

begin
  /* Bug fix: 870945 */
  /*------------------------------+
   |  Initialize input variables  |
   +------------------------------*/

   l_gl_date := trunc(gl_date);
   l_trx_date := trunc(trx_date);
   l_validation_date1 := trunc(validation_date1);
   l_validation_date2 := trunc(validation_date2);
   l_validation_date3 := trunc(validation_date3);
   l_default_date1 := trunc(default_date1);
   l_default_date2 := trunc(default_date2);
   l_default_date3 := trunc(default_date3);

  /*------------------------------+
   |  Initialize output variables |
   +------------------------------*/

   defaulting_rule_used := '';
   error_message        := '';
   default_gl_date      := '';
   candidate_gl_date    := '';

  /*---------------------------+
   |  Populate default values  |
   +---------------------------*/


   if (p_allow_not_open_flag is null)
   then allow_not_open_flag := 'N';
   else allow_not_open_flag := p_allow_not_open_flag;
   end if;

   if (p_invoicing_rule_id = '-3')
   then allow_not_open_flag := 'Y';
   end if;

   if (p_application_id is null)
   then h_application_id := 222;
   else h_application_id := p_application_id;
   end if;

   if (p_set_of_books_id is null)
   then h_set_of_books_id := sysparm.set_of_books_id;
   else h_set_of_books_id := p_set_of_books_id;
   end if;


   /*--------------------------+
    |  Apply defaulting rules  |
    +--------------------------*/


   /* Try the gl_date that was passed in */

   if is_gl_date_valid(l_gl_date,
                       l_trx_date,
                       l_validation_date1,
                       l_validation_date2,
                       l_validation_date3,
                       allow_not_open_flag,
                       h_set_of_books_id,
                       h_application_id,
                       TRUE)
   then  default_gl_date  := l_gl_date;
         defaulting_rule_used := 'ORIGINAL GL_DATE';
         return(TRUE);
   end if;


   /* Try the default dates that were passed in */

   if is_gl_date_valid(l_default_date1,
                       l_trx_date,
                       l_validation_date1,
                       l_validation_date2,
                       l_validation_date3,
                       allow_not_open_flag,
                       h_set_of_books_id,
                       h_application_id,
                       TRUE)
   then  default_gl_date  := l_default_date1;
         defaulting_rule_used := 'DEFAULT_DATE1';
         return(TRUE);
   end if;

   if is_gl_date_valid(l_default_date2,
                       l_trx_date,
                       l_validation_date1,
                       l_validation_date2,
                       l_validation_date3,
                       allow_not_open_flag,
                       h_set_of_books_id,
                       h_application_id,
                       TRUE)
   then  default_gl_date  := l_default_date2;
         defaulting_rule_used := 'DEFAULT_DATE2';
         return(TRUE);
   end if;

   if is_gl_date_valid(l_default_date3,
                       l_trx_date,
                       l_validation_date1,
                       l_validation_date2,
                       l_validation_date3,
                       allow_not_open_flag,
                       h_set_of_books_id,
                       h_application_id,
                       TRUE)
   then  default_gl_date  := l_default_date3;
         defaulting_rule_used := 'DEFAULT_DATE3';
         return(TRUE);
   end if;

  /* Bug 3477990 - for invoices with rules, , if the passed date is in a closed
     period, go for the first day of the next open period.  This specifically
     activates when the user passes a gl_date on an invoice with rule
     and that gl_date falls in a closed period.  In theory, it should
     adjust to the next (first) open period after that date.  */
/* bug3672087 -- we were passing FALSE in check_period_status in is_gl_date_valid
  but we want to validate the period -- hence we should be  be passing TRUE */

/*bug3744833 -- the loop checking for invoicing_rule is not reqd.
  since its needed for all invoices */


      SELECT min(start_date)
      INTO   candidate_gl_date
      FROM   gl_period_statuses
      WHERE  application_id         = h_application_id
      AND    set_of_books_id        = h_set_of_books_id
      AND    adjustment_period_flag = 'N'
      AND    closing_status         IN ('O','F','N')
      AND    start_date >= l_gl_date;

      IF ( candidate_gl_date is not null )
      THEN
          IF is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              TRUE)
          THEN
             default_gl_date  := candidate_gl_date;
             defaulting_rule_used := 'FIRST OPEN PERIOD AFTER GL_DATE';

             RETURN(TRUE);
          END IF;
      END IF;
  /* End bug 3477990 */

  /*-----------------------------------------------------------------+
   |  If   sysdate is in a Future period,                            |
   |  Then use the last day of the last Open period before sysdate.  |
   +-----------------------------------------------------------------*/


   select max(d.end_date)
   into   candidate_gl_date
   from   gl_period_statuses d,
          gl_period_statuses s
   where  d.application_id         = s.application_id
   and    d.set_of_books_id        = s.set_of_books_id
   and    d.adjustment_period_flag = 'N'
   and    d.end_date < sysdate
   and    d.closing_status         = 'O'
   and    s.application_id         = h_application_id
   and    s.set_of_books_id        = h_set_of_books_id
   and    s.adjustment_period_flag = 'N'
   and    s.closing_status         = 'F'
   and    sysdate between s.start_date and s.end_date;

   if ( candidate_gl_date is not null )
   then
      if is_gl_date_valid(candidate_gl_date,
                          l_trx_date,
                          l_validation_date1,
                          l_validation_date2,
                          l_validation_date3,
                          allow_not_open_flag,
                          h_set_of_books_id,
                          h_application_id,
                          FALSE)
      then default_gl_date  := candidate_gl_date;
           defaulting_rule_used :=
                          'LAST DAY OF OPEN PERIOD BEFORE FUTURE PERIOD';
           return(TRUE);
      end if;
   end if;

   /* Try sysdate */
   if is_gl_date_valid(sysdate,
                       l_trx_date,
                       l_validation_date1,
                       l_validation_date2,
                       l_validation_date3,
                       allow_not_open_flag,
                       h_set_of_books_id,
                       h_application_id,
                       TRUE)
   then default_gl_date  := trunc(sysdate);
        defaulting_rule_used := 'SYSDATE';
        return(TRUE);
   end if;

   /* Try trx_date */
   if ( trx_date is not null )
   then

      /* Try trx_date */
      if is_gl_date_valid(l_trx_date,
                          l_trx_date,
                          l_validation_date1,
                          l_validation_date2,
                          l_validation_date3,
                          allow_not_open_flag,
                          h_set_of_books_id,
                          h_application_id,
                          TRUE)
      then default_gl_date  := l_trx_date;
           defaulting_rule_used := 'TRX_DATE';
           return(TRUE);
      end if;

     /* Bug 1882597
        Try the open period prior to the trx_date*/

      select  max(end_date)
      into   candidate_gl_date
      from   gl_period_statuses
      where  application_id         = h_application_id
      and    set_of_books_id        = h_set_of_books_id
      and    adjustment_period_flag = 'N'
      and    closing_status         = 'O'
      and    start_date < l_trx_date;

      arp_util.debug('Candidate GL DATE = '||to_char(candidate_gl_date,'dd/mm/yyyy'));
      if ( candidate_gl_date is not null )
      then
          if is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              FALSE)
          then default_gl_date  := candidate_gl_date;
               defaulting_rule_used :=
                              'LAST DATE OF THE PREVIOUS OPEN PERIOD';
               return(TRUE);
          else

      arp_util.debug('NOT VALID');
          end if;
      end if;

      /* Try first Open period after trx_date */

      select min(start_date)
      into   candidate_gl_date
      from   gl_period_statuses
      where  application_id         = h_application_id
      and    set_of_books_id        = h_set_of_books_id
      and    adjustment_period_flag = 'N'
      and    closing_status         = 'O'
      and    start_date >= l_trx_date;

      if ( candidate_gl_date is not null )
      then
          if is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              FALSE)
          then default_gl_date  := candidate_gl_date;
               defaulting_rule_used :=
                              'FIRST OPEN PERIOD AFTER TRX_DATE';
               return(TRUE);
          end if;
      end if;  /* candidate_gl_date is not null case */


     /* Try first Future period after trx_date */

      select min(start_date)
      into   candidate_gl_date
      from   gl_period_statuses
      where  application_id         = h_application_id
      and    set_of_books_id        = h_set_of_books_id
      and    adjustment_period_flag = 'N'
      and    closing_status         = 'F'
      and    start_date >= l_trx_date;

      if ( candidate_gl_date is not null )
      then
          if is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              FALSE)
          then default_gl_date  := candidate_gl_date;
               defaulting_rule_used :=
                              'FIRST FUTURE PERIOD AFTER TRX_DATE';
               return(TRUE);
          end if;
      end if;  /* candidate_gl_date is not null case */

   else    /* trx_date is not known case */

      /* Bug 1882597
         try the previous open period */

      select  max(end_date)
      into   candidate_gl_date
      from   gl_period_statuses
      where  application_id         = h_application_id
      and    set_of_books_id        = h_set_of_books_id
      and    adjustment_period_flag = 'N'
      and    closing_status         = 'O'
      and    start_date < sysdate;
      arp_util.debug('Candidate gl_date = '|| to_char(candidate_gl_date,'dd-mon-yyyy'));
      arp_util.debug('l_ gl_date = '|| to_char(l_gl_date,'dd-mon-yyyy'));

      if ( candidate_gl_date is not null )
      then
          if is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              FALSE)
          then default_gl_date  := candidate_gl_date;
               defaulting_rule_used :=
                              'LAST DATE OF THE PREVIOUS OPEN PERIOD';
               return(TRUE);
          end if;
      end if;  /* candidate_gl_date is not null case */


      /* try the first open period after sysdate */

     /* Bug 1882597
         Changed the function from max to min*/

      select min(start_date)
      into   candidate_gl_date
      from   gl_period_statuses
      where  application_id         = h_application_id
      and    set_of_books_id        = h_set_of_books_id
      and    adjustment_period_flag = 'N'
      and    closing_status         = 'O'
      and    start_date >= sysdate;

      if ( candidate_gl_date is not null )
      then
          if is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              FALSE)
          then default_gl_date  := candidate_gl_date;
               defaulting_rule_used :=
                              'FIRST OPEN PERIOD AFTER SYSDATE';
               return(TRUE);
          end if;
      end if;  /* candidate_gl_date is not null case */


      /* try the last open period */

      select max(start_date), max(end_date)
      into   candidate_start_gl_date,
             candidate_end_gl_date
      from   gl_period_statuses
      where  application_id         = h_application_id
      and    set_of_books_id        = h_set_of_books_id
      and    adjustment_period_flag = 'N'
      and    closing_status         = 'O';

      if (sysdate > candidate_start_gl_date)
      then candidate_gl_date := candidate_end_gl_date;
      else candidate_gl_date := candidate_start_gl_date;
      end if;

      if ( candidate_gl_date is not null )
      then
          if is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              FALSE)
          then default_gl_date  := candidate_gl_date;
               defaulting_rule_used :=
                              'LAST OPEN PERIOD';
               return(TRUE);
          end if;
      end if;  /* candidate_gl_date is not null case */


      /* try the first Future period >= sysdate */

      select min(start_date)
      into   candidate_gl_date
      from   gl_period_statuses
      where  application_id         = h_application_id
      and    set_of_books_id        = h_set_of_books_id
      and    adjustment_period_flag = 'N'
      and    closing_status         = 'F'
      and    start_date >= sysdate;


      if ( candidate_gl_date is not null )
      then
          if is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              FALSE)
          then default_gl_date  := candidate_gl_date;
               defaulting_rule_used :=
                              'FIRST FUTURE PERIOD AFTER SYSDATE';
               return(TRUE);
          end if;
      end if;  /* candidate_gl_date is not null case */


      /* try the last Future period */

      select max(start_date), max(end_date)
      into   candidate_start_gl_date,
             candidate_end_gl_date
      from   gl_period_statuses
      where  application_id         = h_application_id
      and    set_of_books_id        = h_set_of_books_id
      and    adjustment_period_flag = 'N'
      and    closing_status         = 'F';

      if (sysdate > candidate_start_gl_date)
      then candidate_gl_date := candidate_end_gl_date;
      else candidate_gl_date := candidate_start_gl_date;
      end if;

      if ( candidate_gl_date is not null )
      then
          if is_gl_date_valid(candidate_gl_date,
                              l_trx_date,
                              l_validation_date1,
                              l_validation_date2,
                              l_validation_date3,
                              allow_not_open_flag,
                              h_set_of_books_id,
                              h_application_id,
                              FALSE)
          then default_gl_date  := candidate_gl_date;
               defaulting_rule_used :=
                              'LAST FUTURE PERIOD';
               return(TRUE);
          end if;
      end if;  /* candidate_gl_date is not null case */


   end if;  /* trx_date is null or not null */


   return(TRUE);

   EXCEPTION
     WHEN OTHERS THEN
        error_message := 'arplbstd(): ' || sqlerrm;
        return(FALSE);

end;  /* function validate_and_default_gl_date() */

/* Bug 1882597 */
/*===========================================================================+
 | FUNCTION                                                                  |
 |    default_gl_date_conc                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the gl_date to be defaulted based on the         |
 |    sysdate. This function can be called for setting the default gl_date   |
 |    for concurrent requests                                                |
 |    Usage : arp_standard.default_gl_date_conc                              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN      :  None                                              |
 |              RETURNS : Date                                               |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     20-Feb-2002  Rahna Kader         Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION default_gl_date_conc RETURN date IS
l_default_gl_date DATE;
l_defaulting_rule_used VARCHAR2(50);
l_error_message VARCHAR2(100);
BEGIN
  IF (arp_util.validate_and_default_gl_date(
                sysdate,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                'N',
                NULL,
                sysparm.set_of_books_id,
                222,
                l_default_gl_date,
                l_defaulting_rule_used,
                l_error_message) = TRUE) THEN
       return l_default_gl_date;
  ELSE
       return sysdate;
  END IF;
        return sysdate;
END; /*default_gl_date_conc end*/



/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    gl_activity        ( P_PERIOD_FROM         IN                           |
 |                         ,P_PERIOD_TO           IN                          |
 |                         ,P_CODE_COMBINATION_ID IN                          |
 |                         ,P_SET_OF_BOOKS_ID     IN                          |
 |                         ,PERIOD_NET_DR         OUT NOCOPY                         |
 |                         ,PERIOD_NET_CR         OUT)                        |
 |                                                                            |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Given the parameter listed above and the procedure will return          |
 |    the Period Net Cr and the Period Net Dr                                 |
 |    or raise exception NO_DATA_FOUND                                        |
 |                                                                            |
 |    If the GL Server server package: GL_BALANCES is not installed, this     |
 |    function returns NO_DATA_FOUND.                                         |
 |                                                                            |
 | PARAMETERS                                                                 |
 |      PERIOD_FROM          VARCHAR2                                         |
 |      PERIOD_TO            VARCHAR2                                         |
 |      CODE_COMBINATION_ID  NUMBER                                           |
 |      SET_OF_BOOKS_ID      NUMBER                                           |
 |                                                                            |
 | RETURNS                                                                    |
 |    PERIOD_NET_DR                                                           |
 |    PERIOD_NET_CR                                                           |
 |    exception NO_DATA_FOUND                                                 |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |      3/16/95        Schirin Farzaneh  Created                              |
 |                                                                            |
 *----------------------------------------------------------------------------*/

procedure gl_activity     ( P_PERIOD_FROM         IN VARCHAR2
                           ,P_PERIOD_TO           IN VARCHAR2
                           ,P_CODE_COMBINATION_ID IN NUMBER
                           ,P_SET_OF_BOOKS_ID     IN NUMBER
                           ,P_PERIOD_NET_DR       OUT NOCOPY NUMBER
                           ,P_PERIOD_NET_CR       OUT NOCOPY NUMBER) IS

        c number;
statement varchar2(2000);
     rows number;

       dr number;
       cr number;
begin

   statement := 'begin gl_balances_PKG.gl_get_period_range_activity( :P_PERIOD_FROM ' ||
                           ',:P_PERIOD_TO           ' ||
                           ',:P_CODE_COMBINATION_ID ' ||
                           ',:P_SET_OF_BOOKS_ID     ' ||
                           ',:P_PERIOD_NET_DR       ' ||
                           ',:P_PERIOD_NET_CR       ); end; ';
   c := dbms_sql.open_cursor;

   /* Parse SQL Statement, returning the exception: NO_DATA_FOUND if the GL  */
   /* Server procedure: gl_balances.get_activity has not been installed      */
   /* Any other error, generated by this call will also return NO_DATA_FOUND */

   begin
      dbms_sql.parse(c, statement, dbms_sql.native);

      dbms_sql.bind_variable( c, 'p_period_from', p_period_from );
      dbms_sql.bind_variable( c, 'p_period_to', p_period_to );
      dbms_sql.bind_variable( c, 'p_code_combination_id', p_code_combination_id );
      dbms_sql.bind_variable( c, 'p_set_of_books_id', p_set_of_books_id  );
      dbms_sql.bind_variable( c, 'p_period_net_dr', dr );
      dbms_sql.bind_variable( c, 'p_period_net_cr', cr );
      rows := dbms_sql.execute(c);
      dbms_sql.variable_value( c, 'p_period_net_dr', dr );
      dbms_sql.variable_value( c, 'p_period_net_cr', cr );
      dbms_sql.close_cursor(c);
   exception
      when others then if dbms_sql.is_open(c) then dbms_sql.close_cursor(c); end if;
           raise no_data_found;
   end;
   p_period_net_dr := dr;
   p_period_net_cr := cr;

end;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    find_previous_trx_line_id                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    For a given credit memo line and associated line number for tax, this  |
 |    rountine will attempt to find the same tax line for that invoice line  |
 |    so that the accounting engine can build the autoaccounting for the     |
 |    credit memo line.                                                      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:  p_customer_trx_line_id                                  |
 |              IN:  p_tax_line_number                                       |
 |              IN:  p_vat_tax_id                                            |
 |             OUT:  p_tax_customer_trx_id                                   |
 |             OUT:  p_tax_customer_trx_line_id                              |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |    Before the invoice tax line can be found ALL of the following          |
 |    conditions must be meet.                                               |
 |                Same Tax Line Number                                       |
 |                Same Tax Code                                              |
 |                                                                           |
 |    If either of these conditions fails, the rountines continue the        |
 |    search, and attempts to find the matching record based on:             |
 |                Same Tax Code                                              |
 |                Only one original tax of that code.                        |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-Nov-95  Nigel Smith         Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE find_previous_trx_line_id( p_customer_trx_line_id      IN NUMBER,
                                     p_tax_line_number           IN NUMBER,
				     p_vat_tax_id		 IN NUMBER,
				     p_tax_customer_trx_id      OUT NOCOPY NUMBER,
				     p_tax_customer_trx_line_id OUT NOCOPY NUMBER,
				     p_chk_applied_cm            IN BOOLEAN default FALSE ) IS


CURSOR c_find_prev_trx_line_id( p_customer_trx_line_id IN NUMBER,
                                     p_tax_line_number IN NUMBER,
				          p_vat_tax_id IN NUMBER ) IS

       SELECT  tax.customer_trx_line_id,
               tax.customer_trx_id
       FROM    ra_customer_trx_lines tax,
	       ra_customer_trx_lines line,
	       ar_vat_tax v1,
	       ar_vat_tax v2
       WHERE   tax.link_to_cust_trx_line_id = line.previous_customer_trx_line_id
         AND   line.customer_trx_line_id    = p_customer_trx_line_id
         AND   tax.line_number              = p_tax_line_number
         AND   tax.vat_tax_id               = v1.vat_tax_id
         AND   v1.tax_code                  = v2.tax_code
         AND   v2.vat_tax_id                = p_vat_tax_id;


CURSOR c_find_prev_trx_line_id_nol( p_customer_trx_line_id IN NUMBER,
				                     p_vat_tax_id IN NUMBER ) IS

       SELECT  tax.customer_trx_line_id,
               tax.customer_trx_id
       FROM    ra_customer_trx_lines tax,
	       ra_customer_trx_lines line,
	       ar_vat_tax v1,
	       ar_vat_tax v2
       WHERE   tax.link_to_cust_trx_line_id = line.previous_customer_trx_line_id
         AND   line.customer_trx_line_id    = p_customer_trx_line_id
         AND   tax.vat_tax_id               = v1.vat_tax_id
         AND   v1.tax_code                  = v2.tax_code
         AND   v2.vat_tax_id                = p_vat_tax_id
         AND   not exists ( select 'x' from ra_customer_trx_lines v, ar_vat_tax v3
			    where v.link_to_cust_trx_line_id = line.previous_customer_trx_line_id
                             and  v.vat_tax_id = v3.vat_tax_id
			     and  v3.tax_code = v1.tax_code
                             and  v.customer_trx_line_id <> tax.customer_trx_line_id );

cursor c_chk_applied_cm( p_customer_trx_line_id in number ) is

        /* Applied Credit Memos interface through autoinvoice must have    */
	/* previous customer_trx_id and trx_line_id for tax records if     */
	/* autoaccounting is to work. Using 10SC the tax views will        */
	/* allways return a previous_customer_trx_line_id for applied trx  */

	SELECT  'x' from ra_customer_trx_lines line, ra_customer_trx hdr, ra_cust_trx_types type
	where    line.customer_trx_id = hdr.customer_trx_id
	  and    line.customer_trx_line_id = p_customer_trx_line_id
	  and    hdr.previous_customer_trx_id is not null
          and    hdr.cust_trx_type_id = type.cust_trx_type_id
	  and    type.type = 'CM';


   l_tax_customer_trx_line_id NUMBER;
   l_tax_customer_trx_id      NUMBER;
   l_dummy                    VARCHAR2(16);

BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug( 'arp_process_tax.find_previous_trx_line_id()+' );
      END IF;
      OPEN c_find_prev_trx_line_id( p_customer_trx_line_id, p_tax_line_number, p_vat_tax_id );
      FETCH c_find_prev_trx_line_id into l_tax_customer_trx_line_id, l_tax_customer_trx_id;

      IF c_find_prev_trx_line_id%NOTFOUND
      THEN
          OPEN c_find_prev_trx_line_id_nol( p_customer_trx_line_id, p_vat_tax_id );
          FETCH c_find_prev_trx_line_id_nol into l_tax_customer_trx_line_id, l_tax_customer_trx_id;

          IF c_find_prev_trx_line_id_nol%NOTFOUND
          THEN

              l_tax_customer_trx_line_id := null;
              l_tax_customer_trx_id := null;

	      IF p_chk_applied_cm
	      THEN
	      BEGIN

                 OPEN c_chk_applied_cm( p_customer_trx_line_id );
                 FETCH c_chk_applied_cm into l_dummy;
                 if c_chk_applied_cm%FOUND
                 THEN
                 BEGIN
                   close c_chk_applied_cm;
                   close c_find_prev_trx_line_id;
                   close c_find_prev_trx_line_id_nol;
                   raise NO_DATA_FOUND;
                 END;
	         END IF;
                 close c_chk_applied_cm;

	      END;
              END IF;
          END IF;
          CLOSE c_find_prev_trx_line_id_nol;

      END IF;
      CLOSE c_find_prev_trx_line_id;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug( 'arp_standard.find_previous_trx_line_id( ' ||
		to_char(l_tax_customer_trx_id ) || ', ' || to_char( l_tax_customer_trx_line_id ) || ' )-' );
      END IF;

      p_tax_customer_trx_line_id := l_tax_customer_trx_line_id ;
      p_tax_customer_trx_id      := l_tax_customer_trx_id;



EXCEPTION
    WHEN OTHERS
    THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug( 'EXCEPTION:  arp_standard.find_previous_trx_line_id( ' ||
                        to_char( p_customer_trx_line_id ) || ' )' );
       END IF;

       IF c_find_prev_trx_line_id%ISOPEN
       THEN
          CLOSE c_find_prev_trx_line_id;
       END IF;

       IF c_find_prev_trx_line_id_nol%ISOPEN
       THEN
          CLOSE c_find_prev_trx_line_id_nol;
       END IF;

       IF c_chk_applied_cm%ISOPEN
       THEN
          CLOSE c_chk_applied_cm;
       END IF;

       RAISE;
END find_previous_trx_line_id;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    enable_sql_trace                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Enable sql trace based on value (YES/NO) of profile AR_ENABLE_SQL_TRACE|
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-Sep-99  Govind Jayanth      Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE enable_sql_trace IS
BEGIN

   --ATG mandate remove sql trace related code from files
	--IF (fnd_profile.value('AR_ENABLE_SQL_TRACE') = 'Y') THEN
  	--	dbms_session.set_sql_trace(true);
	--END IF;

   NULL;


EXCEPTION
	WHEN OTHERS THEN
	      null;
END enable_sql_trace;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_enable_debug                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 | Set program global debug output flag based on value of profile            |
 | AFLOG_ENABLED						     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-NOV-99  Govind Jayanth      Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE set_enable_debug IS
BEGIN
	IF (fnd_profile.value('AFLOG_ENABLED') = 'Y') THEN
  		arp_standard.pg_prf_enable_debug := 'Y';
	END IF;
EXCEPTION
	WHEN OTHERS THEN
	      null;
END set_enable_debug;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    init_standard                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 | Procedure to initialize ARP_STANDARD public variables.                    |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     11-Sep-2002   Sahana Shetty    Created for Bug2538244.                |
 |                                                                           |
 +===========================================================================*/
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
 PROCEDURE INIT_STANDARD(p_org_id number default null) IS

  l_gr                 ar_mo_cache_utils.GlobalsRecord;
  l_count              PLS_INTEGER;
  l_default_org_id     NUMBER;
  l_default_ou_name    mo_glob_org_access_tmp.organization_name%type;       --Bug Fix 6814490

 BEGIN

        application_id := 222;
        gl_application_id := 101;
        previous_msg.name := 'AR_PP_NO_MESSAGE';

       /* --------------------------------------------------------------------------------
          If you pass p_org_id to INIT_STANDARD it will the set the current org to p_org_id
          else it will get the default org_id based on mo_utils.get_default_ou output
         ---------------------------------------------------------------------------------  */

        IF p_org_id is NOT NULL then
          ar_mo_global_cache.set_current_org_id(p_org_id);
        ELSE
           mo_utils.get_default_ou(l_default_org_id,l_default_ou_name,l_count);
          IF l_default_org_id is null then
            begin
             select min(org_id) into l_default_org_id from ar_system_parameters;
            end;
           end if;
        END IF;

       /* --------------------------------------------------------------------------------
          Get the cached attribute info for the org you pass p_org_id to INIT_STANDARD into
          Local Variable l_gr
         ---------------------------------------------------------------------------------  */

        l_gr := ar_mo_global_cache.get_org_attributes(nvl(p_org_id,l_default_org_id));

       /* --------------------------------------------------------------------------------
          Begin populate all attribute of global variable, sysparm of ar_system_parameters%rowtype
          from Local Variable, l_gr,  retieved from cache for the passed org
         ---------------------------------------------------------------------------------  */
   /* enable_debug;
   enable_file_debug('/sqlcom/out/modev116','artestlog'||userenv('SESSIONID')||'.log');
*/
         arp_standard.debug('SSA CACHE TEST BEGIN');
        ARP_STANDARD.sysparm.org_id			:= l_gr.org_id;
        ARP_STANDARD.sysparm.set_of_books_id			:= l_gr.set_of_books_id;
        ARP_STANDARD.sysparm.accounting_method		:= l_gr.accounting_method;
        ARP_STANDARD.sysparm.accrue_interest		:= l_gr.accrue_interest;
        ARP_STANDARD.sysparm.unearned_discount		:= l_gr.unearned_discount;
        ARP_STANDARD.sysparm.partial_discount_flag	:= l_gr.partial_discount_flag;
        ARP_STANDARD.sysparm.print_remit_to		:= l_gr.print_remit_to;
        ARP_STANDARD.sysparm.default_cb_due_date	:= l_gr.default_cb_due_date;
        ARP_STANDARD.sysparm.auto_site_numbering	:= l_gr.auto_site_numbering;
        ARP_STANDARD.sysparm.cash_basis_set_of_books_id	:= l_gr.cash_basis_set_of_books_id;
        ARP_STANDARD.sysparm.code_combination_id_gain	:= l_gr.code_combination_id_gain;
        ARP_STANDARD.sysparm.autocash_hierarchy_id	:= l_gr.autocash_hierarchy_id;
        ARP_STANDARD.sysparm.run_gl_journal_import_flag	:= l_gr.run_gl_journal_import_flag;
        ARP_STANDARD.sysparm.cer_split_amount		:= l_gr.cer_split_amount;
        ARP_STANDARD.sysparm.cer_dso_days		:= l_gr.cer_dso_days;

        ARP_STANDARD.sysparm.posting_days_per_cycle	:= l_gr.posting_days_per_cycle;
        ARP_STANDARD.sysparm.address_validation		:= l_gr.address_validation;
        ARP_STANDARD.sysparm.calc_discount_on_lines_flag:= l_gr.calc_discount_on_lines_flag;
        ARP_STANDARD.sysparm.change_printed_invoice_flag:= l_gr.change_printed_invoice_flag;
        ARP_STANDARD.sysparm.code_combination_id_loss	:= l_gr.code_combination_id_loss;
        ARP_STANDARD.sysparm.create_reciprocal_flag	:= l_gr.create_reciprocal_flag;
        ARP_STANDARD.sysparm.default_country		:= l_gr.default_country;
        ARP_STANDARD.sysparm.default_territory		:= l_gr.default_territory;

        ARP_STANDARD.sysparm.generate_customer_number	:= l_gr.generate_customer_number;
        ARP_STANDARD.sysparm.invoice_deletion_flag	:= l_gr.invoice_deletion_flag;
        ARP_STANDARD.sysparm.location_structure_id	:= l_gr.location_structure_id;
        ARP_STANDARD.sysparm.site_required_flag		:= l_gr.site_required_flag;
        ARP_STANDARD.sysparm.tax_allow_compound_flag	:= l_gr.tax_allow_compound_flag;
        ARP_STANDARD.sysparm.tax_header_level_flag	:= l_gr.tax_header_level_flag;
        ARP_STANDARD.sysparm.tax_rounding_allow_override:= l_gr.tax_rounding_allow_override;
        ARP_STANDARD.sysparm.tax_invoice_print		:= l_gr.tax_invoice_print;
        ARP_STANDARD.sysparm.tax_method			:= l_gr.tax_method;

        ARP_STANDARD.sysparm.tax_use_customer_exempt_flag:= l_gr.tax_use_customer_exempt_flag;
        ARP_STANDARD.sysparm.tax_use_cust_exc_rate_flag	:= l_gr.tax_use_cust_exc_rate_flag;
        ARP_STANDARD.sysparm.tax_use_loc_exc_rate_flag	:= l_gr.tax_use_loc_exc_rate_flag;
        ARP_STANDARD.sysparm.tax_use_product_exempt_flag:= l_gr.tax_use_product_exempt_flag;
        ARP_STANDARD.sysparm.tax_use_prod_exc_rate_flag	:= l_gr.tax_use_prod_exc_rate_flag;
        ARP_STANDARD.sysparm.tax_use_site_exc_rate_flag	:= l_gr.tax_use_site_exc_rate_flag;
        ARP_STANDARD.sysparm.ai_log_file_message_level	:= l_gr.ai_log_file_message_level;
        ARP_STANDARD.sysparm.ai_max_memory_in_bytes	:= l_gr.ai_max_memory_in_bytes;

        ARP_STANDARD.sysparm.ai_acct_flex_key_left_prompt:= l_gr.ai_acct_flex_key_left_prompt;
        ARP_STANDARD.sysparm.ai_mtl_items_key_left_prompt:= l_gr.ai_mtl_items_key_left_prompt;
        ARP_STANDARD.sysparm.ai_territory_key_left_prompt:= l_gr.ai_territory_key_left_prompt;
        ARP_STANDARD.sysparm.ai_purge_interface_tables_flag:= l_gr.ai_purge_int_tables_flag;
        ARP_STANDARD.sysparm.ai_activate_sql_trace_flag	:= l_gr.ai_activate_sql_trace_flag;
        ARP_STANDARD.sysparm.default_grouping_rule_id	:= l_gr.default_grouping_rule_id;
        ARP_STANDARD.sysparm.salesrep_required_flag	:= l_gr.salesrep_required_flag;

        ARP_STANDARD.sysparm.auto_rec_invoices_per_commit:= l_gr.auto_rec_invoices_per_commit;
        ARP_STANDARD.sysparm.auto_rec_receipts_per_commit:= l_gr.auto_rec_receipts_per_commit;
        ARP_STANDARD.sysparm.pay_unrelated_invoices_flag:= l_gr.pay_unrelated_invoices_flag;
        ARP_STANDARD.sysparm.print_home_country_flag	:= l_gr.print_home_country_flag;
        ARP_STANDARD.sysparm.location_tax_account	:= l_gr.location_tax_account;
        ARP_STANDARD.sysparm.from_postal_code		:= l_gr.from_postal_code;
        ARP_STANDARD.sysparm.to_postal_code		:= l_gr.to_postal_code;

        ARP_STANDARD.sysparm.tax_registration_number	:= l_gr.tax_registration_number;
        ARP_STANDARD.sysparm.populate_gl_segments_flag	:= l_gr.populate_gl_segments_flag;
        ARP_STANDARD.sysparm.unallocated_revenue_ccid	:= l_gr.unallocated_revenue_ccid;

        ARP_STANDARD.sysparm.inclusive_tax_used		:= l_gr.inclusive_tax_used;
        ARP_STANDARD.sysparm.tax_enforce_account_flag	:= l_gr.tax_enforce_account_flag;

        ARP_STANDARD.sysparm.ta_installed_flag		:= l_gr.ta_installed_flag;
        ARP_STANDARD.sysparm.bills_receivable_enabled_flag:= l_gr.br_enabled_flag;

        ARP_STANDARD.sysparm.attribute_category		:= l_gr.attribute_category;
        ARP_STANDARD.sysparm.attribute1			:= l_gr.attribute1;
        ARP_STANDARD.sysparm.attribute2			:= l_gr.attribute2;
        ARP_STANDARD.sysparm.attribute3			:= l_gr.attribute3;
        ARP_STANDARD.sysparm.attribute4			:= l_gr.attribute4;
        ARP_STANDARD.sysparm.attribute5			:= l_gr.attribute5;
        ARP_STANDARD.sysparm.attribute6			:= l_gr.attribute6;
        ARP_STANDARD.sysparm.attribute7			:= l_gr.attribute7;
        ARP_STANDARD.sysparm.attribute8			:= l_gr.attribute8;
        ARP_STANDARD.sysparm.attribute9			:= l_gr.attribute9;
        ARP_STANDARD.sysparm.attribute10		:= l_gr.attribute10;
        ARP_STANDARD.sysparm.attribute11		:= l_gr.attribute11;
        ARP_STANDARD.sysparm.attribute12		:= l_gr.attribute12;
        ARP_STANDARD.sysparm.attribute13		:= l_gr.attribute13;
        ARP_STANDARD.sysparm.attribute14		:= l_gr.attribute14;
        ARP_STANDARD.sysparm.attribute15		:= l_gr.attribute15;

        ARP_STANDARD.sysparm.created_by			:= l_gr.created_by;
        ARP_STANDARD.sysparm.creation_date		:= l_gr.creation_date;
        ARP_STANDARD.sysparm.last_updated_by		:= l_gr.last_updated_by;
        ARP_STANDARD.sysparm.last_update_date		:= l_gr.last_update_date;
        ARP_STANDARD.sysparm.last_update_login		:= l_gr.last_update_login;

        ARP_STANDARD.sysparm.tax_code			:= l_gr.tax_code;
        ARP_STANDARD.sysparm.tax_currency_code		:= l_gr.tax_currency_code;
        ARP_STANDARD.sysparm.tax_minimum_accountable_unit:= l_gr.tax_minimum_accountable_unit;
        ARP_STANDARD.sysparm.tax_precision		:= l_gr.tax_precision;
        ARP_STANDARD.sysparm.tax_rounding_rule		:= l_gr.tax_rounding_rule;
        ARP_STANDARD.sysparm.tax_use_account_exc_rate_flag:= l_gr.tax_use_acc_exc_rate_flag;
        ARP_STANDARD.sysparm.tax_use_system_exc_rate_flag:= l_gr.tax_use_system_exc_rate_flag;
        ARP_STANDARD.sysparm.tax_hier_site_exc_rate	:= l_gr.tax_hier_site_exc_rate;
        ARP_STANDARD.sysparm.tax_hier_cust_exc_rate	:= l_gr.tax_hier_cust_exc_rate;
        ARP_STANDARD.sysparm.tax_hier_prod_exc_rate	:= l_gr.tax_hier_prod_exc_rate;
        ARP_STANDARD.sysparm.tax_hier_account_exc_rate	:= l_gr.tax_hier_account_exc_rate;
        ARP_STANDARD.sysparm.tax_hier_system_exc_rate	:= l_gr.tax_hier_system_exc_rate;
        ARP_STANDARD.sysparm.tax_database_view_set	:= l_gr.tax_database_view_set;

        ARP_STANDARD.sysparm.global_attribute1		:= l_gr.global_attribute1;
        ARP_STANDARD.sysparm.global_attribute2		:= l_gr.global_attribute2;
        ARP_STANDARD.sysparm.global_attribute3		:= l_gr.global_attribute3;
        ARP_STANDARD.sysparm.global_attribute4		:= l_gr.global_attribute4;
        ARP_STANDARD.sysparm.global_attribute5		:= l_gr.global_attribute5;
        ARP_STANDARD.sysparm.global_attribute6		:= l_gr.global_attribute6;
        ARP_STANDARD.sysparm.global_attribute7		:= l_gr.global_attribute7;
        ARP_STANDARD.sysparm.global_attribute8		:= l_gr.global_attribute8;
        ARP_STANDARD.sysparm.global_attribute9		:= l_gr.global_attribute9;
        ARP_STANDARD.sysparm.global_attribute10		:= l_gr.global_attribute10;
        ARP_STANDARD.sysparm.global_attribute11		:= l_gr.global_attribute11;
        ARP_STANDARD.sysparm.global_attribute12		:= l_gr.global_attribute12;
        ARP_STANDARD.sysparm.global_attribute13		:= l_gr.global_attribute13;
        ARP_STANDARD.sysparm.global_attribute14		:= l_gr.global_attribute14;
        ARP_STANDARD.sysparm.global_attribute15		:= l_gr.global_attribute15;
        ARP_STANDARD.sysparm.global_attribute16		:= l_gr.global_attribute16;
        ARP_STANDARD.sysparm.global_attribute17		:= l_gr.global_attribute17;
        ARP_STANDARD.sysparm.global_attribute18		:= l_gr.global_attribute18;
        ARP_STANDARD.sysparm.global_attribute19		:= l_gr.global_attribute19;
        ARP_STANDARD.sysparm.global_attribute20		:= l_gr.global_attribute20;
        ARP_STANDARD.sysparm.global_attribute_category	:= l_gr.global_attribute_category;

        ARP_STANDARD.sysparm.rule_set_id		:= l_gr.rule_set_id;
        ARP_STANDARD.sysparm.code_combination_id_round	:= l_gr.code_combination_id_round;
        ARP_STANDARD.sysparm.trx_header_level_rounding	:= l_gr.trx_header_level_rounding;
        ARP_STANDARD.sysparm.trx_header_round_ccid	:= l_gr.trx_header_round_ccid;
        ARP_STANDARD.sysparm.finchrg_receivables_trx_id	:= l_gr.finchrg_receivables_trx_id;
        ARP_STANDARD.sysparm.sales_tax_geocode		:= l_gr.sales_tax_geocode;
        ARP_STANDARD.sysparm.rev_transfer_clear_ccid	:= l_gr.rev_transfer_clear_ccid;
        ARP_STANDARD.sysparm.sales_credit_pct_limit	:= l_gr.sales_credit_pct_limit;
        ARP_STANDARD.sysparm.max_wrtoff_amount		:= l_gr.max_wrtoff_amount;
        ARP_STANDARD.sysparm.irec_cc_receipt_method_id	:= l_gr.irec_cc_receipt_method_id;
        ARP_STANDARD.sysparm.show_billing_number_flag	:= l_gr.show_billing_number_flag;
        ARP_STANDARD.sysparm.cross_currency_rate_type	:= l_gr.cross_currency_rate_type;
        ARP_STANDARD.sysparm.document_seq_gen_level	:= l_gr.document_seq_gen_level;
        ARP_STANDARD.sysparm.calc_tax_on_credit_memo_flag:= l_gr.calc_tax_on_credit_memo_flag;
        ARP_STANDARD.sysparm.IREC_BA_RECEIPT_METHOD_ID  := l_gr.IREC_BA_RECEIPT_METHOD_ID;
        ARP_STANDARD.sysparm.payment_threshold          := l_gr.payment_threshold;
        ARP_STANDARD.sysparm.standard_refund            := l_gr.standard_refund;
        ARP_STANDARD.sysparm.credit_classification1     := l_gr.credit_classification1;
        ARP_STANDARD.sysparm.credit_classification2     := l_gr.credit_classification2;
        ARP_STANDARD.sysparm.credit_classification3     := l_gr.credit_classification3;
        ARP_STANDARD.sysparm.unmtch_claim_creation_flag := l_gr.unmtch_claim_creation_flag;
        ARP_STANDARD.sysparm.matched_claim_creation_flag := l_gr.matched_claim_creation_flag;
        ARP_STANDARD.sysparm.matched_claim_excl_cm_flag  := l_gr.matched_claim_excl_cm_flag;
        ARP_STANDARD.sysparm.min_wrtoff_amount           := l_gr.min_wrtoff_amount;
        ARP_STANDARD.sysparm.min_refund_amount           := l_gr.min_refund_amount;
        ARP_STANDARD.sysparm.create_detailed_dist_flag   := l_gr.create_detailed_dist_flag;

       /* --------------------------------------------------------------------------------
          End populate all attribute of global variable, sysparm of ar_system_parameters%rowtype
          from Local Variable, l_gr,  retieved from cache for the passed org
         ---------------------------------------------------------------------------------  */
        if ARP_STANDARD.sysparm.from_postal_code is null
        then
           ARP_STANDARD.sysparm.from_postal_code := '00000';
        end if;

        if ARP_STANDARD.sysparm.to_postal_code is null
        then
           ARP_STANDARD.sysparm.to_postal_code := '99999-9999';
        end if;

        ARP_STANDARD.gl_chart_of_accounts_id:= l_gr.chart_of_accounts_id;


	SET_WHO_INFORMATION(0,0,0,0,0);   -- Now uses AOL FND_GLOBAL package
	SET_APPLICATION_INFORMATION(0,0); -- Now uses AOL FND_GLOBAL package

	/* Enable sql trace based on profile */
        --ATG mandate there should not be any sql trace logic
	--enable_sql_trace;

	/* Set arp_standard package global variable, if profile is set */
	set_enable_debug;

 EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
        BEGIN
	--Bug Fix:1949618; added following two lines
	   SET_WHO_INFORMATION(0,0,0,0,0);   -- Now uses AOL FND_GLOBAL package
	   SET_APPLICATION_INFORMATION(0,0); -- Now uses AOL FND_GLOBAL package
           arp_standard.fnd_message( 'AR_NO_ROW_IN_SYSTEM_PARAMETERS' );
        END;
 END INIT_STANDARD;


/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    is_llca_allowed                                                         |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Check whether LLCA is allowed for given org/trxn.                       |
 |    Need to restrict LLCA activity/app both from UI and API if one of the   |
 |    following evaluates to true.                                            |
 |                                                                            |
 |     1 > "Create Detailed Distributions" is unchecked for the current org   |
 |         and the upgrade_method is null                                     |
 |     2 >  Activity/app performed earlier on given transaction with the      |
 |          above option left unchecked(i.e,upgrade_method on invoice set to  |
 |          R12_MERGE.                                                        |
 |                                                                            |
 | REQUIRES                                                                   |
 |    p_org_id                                                                |
 |    p_customer_trx_id                                                       |
 |                                                                            |
 | HISTORY                                                                    |
 |      04/12/08         nproddut       Created                               |
 *----------------------------------------------------------------------------*/
FUNCTION is_llca_allowed( p_org_id          IN NUMBER DEFAULT NULL,
                          p_customer_trx_id IN NUMBER DEFAULT NULL ) RETURN BOOLEAN IS

CURSOR trx_cur IS
SELECT upgrade_method
FROM ra_customer_trx
WHERE customer_trx_id = p_customer_trx_id;

l_upg_method       ra_customer_trx.upgrade_method%TYPE;
l_allowed_flag     BOOLEAN;
l_org_id           NUMBER;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug( 'arp_standard.is_llca_allowed()+');
    arp_util.debug( 'p_org_id           '||p_org_id);
    arp_util.debug( 'p_customer_trx_id  '||p_customer_trx_id);
  END IF;


  /*org_id id passed is other than the one initialized in arp_standard
    then reintialize it with this org_id */
  IF p_org_id IS NOT NULL AND
     p_org_id <> arp_standard.sysparm.org_id THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( 'arp_standard.sysparm.org_id '||arp_standard.sysparm.org_id);
      arp_util.debug( 'Calling arp_standard.init_standard');
    END IF;
    arp_standard.init_standard( p_org_id );
  END IF;

  IF p_customer_trx_id IS NULL THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( 'customer_trx_id passed is null');
    END IF;

    IF nvl(arp_standard.sysparm.create_detailed_dist_flag,'Y') = 'N' THEN
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_util.debug( 'returning false');
      END IF;
      return false;
    ELSE
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_util.debug( 'returning true');
      END IF;
      return true;
    END IF;
  END IF;

  OPEN trx_cur;
  FETCH trx_cur INTO l_upg_method;

  IF trx_cur%NOTFOUND THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug( 'raising no_data_found exception in is_llca_allowed..');
    END IF;
    RAISE NO_DATA_FOUND;
  END IF;

  CLOSE trx_cur;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug( 'l_upg_method '||l_upg_method);
  END IF;

  /* If create_detailed_dist_flag is enabled for the given org then verify
   whether there exist any activity/app on this invoice with summarized distributions
   flag set to N (making use of upgrade_method stamped on the invoice) */
  IF l_upg_method IS NULL AND
     nvl(arp_standard.sysparm.create_detailed_dist_flag,'Y') = 'N' THEN
     l_allowed_flag := false;
  ELSIF NVL(l_upg_method,'NONE') = 'R12_MERGE' THEN
    l_allowed_flag := false;
  ELSE
    l_allowed_flag := true;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug( 'arp_standard.is_llca_allowed()-');
  END IF;

  return l_allowed_flag;

END is_llca_allowed;


begin --- Initialisation section

 /* --------------------------------------------------------------------------------------------
     Calling  Procedure INIT_STANDARD in initialization section
    -------------------------------------------------------------------------------------------- */
  ar_mo_global_cache.populate;
/*Bug 4624926 API failing in R12-Starts*/
IF mo_global.get_current_org_id is null then
  ARP_STANDARD.INIT_STANDARD;
  ELSE
   ARP_STANDARD.INIT_STANDARD(mo_global.get_current_org_id);
END IF;
/* Bug 4624926 API failing in R12-Ends*/

/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
--end anuj

END ARP_STANDARD;

/
