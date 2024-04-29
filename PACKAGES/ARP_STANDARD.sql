--------------------------------------------------------
--  DDL for Package ARP_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_STANDARD" AUTHID CURRENT_USER AS
/* $Header: ARPLSTDS.pls 120.4.12010000.2 2008/12/05 15:43:01 nproddut ship $ */

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  CONSTANTS                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/

MAX_END_DATE date := to_date( '31-12-2199', 'DD-MM-YYYY');
MIN_START_DATE date := to_date( '01-01-1900', 'DD-MM-YYYY');
AR_ERROR_NUMBER constant number := -20000;

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  TYPES                                                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

    TYPE      PROFILE_TYPE IS RECORD
        (
              PROGRAM_APPLICATION_ID    NUMBER := 0,
              PROGRAM_ID                NUMBER := 0,
              REQUEST_ID                NUMBER := 0,
              USER_ID                   NUMBER := 0,
              LAST_UPDATE_LOGIN         NUMBER := 0,
              LANGUAGE_ID               NUMBER := 0,
              LANGUAGE_CODE             VARCHAR2(50) := NULL
         );

/*-------------------------------------------------------------------------+
 |                                                                         |
 | Data type: PRV_MESSAGE_TYPE,                                            |
 |   Procedure calls to fnd_message store each of the parameters passed so |
 |   that a calling PL/SQL block can access the same message and tokens    |
 |   and determine the processing steps required.                          |
 |                                                                         |
 +-------------------------------------------------------------------------*/

    TYPE 	PRV_MESSAGE_TYPE IS RECORD
	(
   		name varchar2(30),
   		t1   varchar2(240),
   		v1   varchar2(240),
   		t2   varchar2(240),
   		v2   varchar2(240),
   		t3   varchar2(240),
   		v3   varchar2(240),
   		t4   varchar2(240),
   		v4   varchar2(240)
	);

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  VARIABLES                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/


    sysparm   		AR_SYSTEM_PARAMETERS%ROWTYPE;

    profile   		PROFILE_TYPE;
    previous_msg 	PRV_MESSAGE_TYPE;

    application_id                      NUMBER;
    gl_application_id                   NUMBER;
    gl_chart_of_accounts_id             NUMBER;
    SEQUENCE_OFFSET                     NUMBER := 0;
    g_msg_module                        VARCHAR2(256);

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  FUNCTIONS                                                       |
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

function get_next_word( list in out NOCOPY varchar2, value in out NOCOPY varchar2 ) return boolean ;


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


function ceil( d in date ) return date;

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

function even( n in number ) return boolean ;
function odd( n in number ) return boolean ;
function check_flag( options in number, flag in number ) return boolean ;
procedure clear_flag( options in out NOCOPY number, flag in number ) ;
procedure set_flag( options in out NOCOPY number, flag in number ) ;



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
 |      2/11/93         Nigel Smith     Created                               |
 |                                                                            |
 *----------------------------------------------------------------------------*/


function fnd_message( md_options in number ) return varchar2;
function fnd_message return varchar2;

function previous_message( md_options in number ) return varchar2 ;
function previous_message return varchar2 ;

function fnd_message( msg_name in varchar2 ) return varchar2;

function fnd_message( msg_name in varchar2, T1 in varchar2, V1 in varchar2 )
         return varchar2;

function fnd_message( msg_name in varchar2, T1 in varchar2, V1 in varchar2,
                                            T2 in varchar2, V2 in varchar2  )
         return varchar2;

function fnd_message( msg_name in varchar2, T1 in varchar2, V1 in varchar2,
                                            T2 in varchar2, V2 in varchar2,
                                            T3 in varchar2, V3 in varchar2 )
        return varchar2;

function fnd_message( msg_name in varchar2, T1 in varchar2, V1 in varchar2,
                                            T2 in varchar2, V2 in varchar2,
                                            T3 in varchar2, V3 in varchar2,
                                            T4 in varchar2, V4 in varchar2 )
        return varchar2;

function fnd_message( md_options in number,
                      msg_name in varchar2 ) return varchar2;

function fnd_message( md_options in number,
                      msg_name in varchar2, T1 in varchar2, V1 in varchar2 )
         return varchar2;

function fnd_message( md_options in number,
                      msg_name in varchar2, T1 in varchar2, V1 in varchar2,
                                            T2 in varchar2, V2 in varchar2  )
         return varchar2;

function fnd_message( md_options in number,
                      msg_name in varchar2, T1 in varchar2, V1 in varchar2,
                                            T2 in varchar2, V2 in varchar2,
                                            T3 in varchar2, V3 in varchar2 )
        return varchar2;

function fnd_message( md_options in number,
                      msg_name in varchar2, T1 in varchar2, V1 in varchar2,
                                            T2 in varchar2, V2 in varchar2,
                                            T3 in varchar2, V3 in varchar2,
                                            T4 in varchar2, V4 in varchar2 )
        return varchar2;

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
 |                                                                            |
 *----------------------------------------------------------------------------*/

FUNCTION functional_amount(amount        IN NUMBER,
                           currency_code IN VARCHAR2,
                           exchange_rate IN NUMBER,
                           precision     IN NUMBER,
                           min_acc_unit  IN NUMBER) RETURN NUMBER ;


/*----------------------------------------------------------------------------*
 | gl_date_range_open - date format in YYYYMMDD                               |
 *----------------------------------------------------------------------------*/
function gl_date_range_open( pstart_date in varchar2,
                             pend_date   in varchar2 ) RETURN BOOLEAN ;


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
 |    NO_DATA_FOUND             If Lookup Type/Code cannot be found           |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |      2/11/93         Nigel Smith     Created                               |
 |                                                                            |
 *----------------------------------------------------------------------------*/

function ar_lookup( lookup_type in varchar2, lookup_code in varchar2 )
         return varchar2;


/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  FLAGS                                                           |
 |  Control flags are currently held in base 10.                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

function MD_MSG_NUMBER return number ;          -- Message Dictionary control
function MD_MSG_TEXT   return number ;          -- Options
function MD_MSG_NAME   return number ;          -- Show message name only
function MD_MSG_TOKENS return number ;          -- Return Tokens and Values
function MD_MSG_EXPLANATION return number ;     -- Not supported yet
function MD_MSG_FIND_NUMBER return number ;     -- Use Message Number not Name

procedure gl_period_info(    gl_date        in  date,
                             period_name    out NOCOPY varchar2,
                             start_date     out NOCOPY date,
                             end_date       out NOCOPY date,
                             closing_status out NOCOPY varchar2,
                             period_type    out NOCOPY varchar2,
                             period_year    out NOCOPY number,
                             period_num     out NOCOPY number,
                             quarter_num    out NOCOPY number
 );

function gl_period_name( gl_date in date ) return varchar2;
FUNCTION is_gl_date_valid(  p_gl_date                IN DATE,
                            p_trx_date               IN DATE,
                            p_validation_date1       IN DATE,
                            p_validation_date2       IN DATE,
                            p_validation_date3       IN DATE,
                            p_allow_not_open_flag    IN VARCHAR2,
                            p_set_of_books_id        IN NUMBER,
                            p_application_id         IN NUMBER,
                            p_check_period_status    IN BOOLEAN DEFAULT TRUE)
  RETURN BOOLEAN;

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
                                     ) return boolean;


/*1882597
  Added a new function default_gl_date_conc which returns the gl_date
  to be defaulted to the concurrent programs based on sysdate */

function default_gl_date_conc return date;

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  PROCEDURES                                                      |
 |                                                                         |
 +-------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    debug             - Display text message if in debug mode               |
 |    enable_debug      - Enable run time debugging                           |
 |    disable_debug     - Disable run time debugging                          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Generate standard debug information sending it to dbms_output so that   |
 |    the client tool can log it for the user.                                |
 |                                                                            |
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
 |    arp_standard.debug('ar_rounding.correct_other_receivables()+');
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
 |    07-OCT-03  M Raymond        added optional parameters to debug()        |
 *----------------------------------------------------------------------------*/

procedure debug( line in varchar2,
          msg_prefix  in varchar2 DEFAULT 'plsql',
          msg_module  in varchar2 DEFAULT NULL,
          msg_level   in number   DEFAULT NULL ) ;
procedure enable_debug;
procedure enable_debug( buffer_size NUMBER );
procedure disable_debug;
procedure enable_file_debug(path_name IN varchar2,
			file_name IN VARCHAR2);
procedure disable_file_debug;

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    set who information                                                     |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Set foundation who information so that all future packages and         |
 |    procedure can reference the correct value.                              |
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
                               last_update_login in number ) ;


PROCEDURE set_application_information( appl_id in number,
                                       language_id    in number );

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    fnd_message                                                             |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Interfaces with AOL's message dictionary                                |
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
 |      2/11/93         Nigel Smith     Created                               |
 |                                                                            |
 *----------------------------------------------------------------------------*/

procedure fnd_message;

procedure fnd_message( msg_name in varchar2 ) ;

procedure fnd_message( msg_name in varchar2, T1 in varchar2, V1 in varchar2 );

procedure fnd_message( msg_name in varchar2, T1 in varchar2, V1 in varchar2,
                                             T2 in varchar2, V2 in varchar2  );

procedure fnd_message( msg_name in varchar2, T1 in varchar2, V1 in varchar2,
                                             T2 in varchar2, V2 in varchar2,
                                             T3 in varchar2, V3 in varchar2);

procedure fnd_message( msg_name in varchar2, T1 in varchar2, V1 in varchar2,
                                             T2 in varchar2, V2 in varchar2,
                                             T3 in varchar2, V3 in varchar2,
                                             T4 in varchar2, V4 in varchar2 );

procedure fnd_message( md_options in number  );

procedure fnd_message( md_options in number,
                       msg_name in varchar2 ) ;

procedure fnd_message( md_options in number,
                       msg_name in varchar2, T1 in varchar2, V1 in varchar2 );

procedure fnd_message( md_options in number,
                       msg_name in varchar2, T1 in varchar2, V1 in varchar2,
                                             T2 in varchar2, V2 in varchar2  );

procedure fnd_message( md_options in number,
                       msg_name in varchar2, T1 in varchar2, V1 in varchar2,
                                             T2 in varchar2, V2 in varchar2,
                                             T3 in varchar2, V3 in varchar2);

procedure fnd_message( md_options in number,
                       msg_name in varchar2, T1 in varchar2, V1 in varchar2,
                                             T2 in varchar2, V2 in varchar2,
                                             T3 in varchar2, V3 in varchar2,
                                             T4 in varchar2, V4 in varchar2 );

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
                           ,P_PERIOD_NET_CR       OUT NOCOPY NUMBER) ;




/*===========================================================================+
 | PROCEDURE                                                                 |
 |    find_previous_trx_line_id                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    For a given invoice line and associated line number for tax, this      |
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
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-Nov-95  Nigel Smith         Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE find_previous_trx_line_id( p_customer_trx_line_id IN NUMBER,
                                    p_tax_line_number IN NUMBER,
				    p_vat_tax_id      IN NUMBER,
				    p_tax_customer_trx_id OUT NOCOPY NUMBER,
				    p_tax_customer_trx_line_id OUT NOCOPY NUMBER,
				    p_chk_applied_cm in BOOLEAN default FALSE );



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
PROCEDURE enable_sql_trace;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    init_standard                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 | New public procedure init_standard defined for initialization             |
 | of arp_standard. This procedure may be called from other modules to run   |
 | initialization whenever required.                                         |
 |                                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-Sep-02  Sahana Shetty       Created for Bug2538244.                |
 |                                                                           |
 +===========================================================================*/
--Begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
 PROCEDURE INIT_STANDARD(p_org_id number default null);
/* Multi-Org Access Control Changes for SSA;end;anukumar;11/01/2002*/
--end anuj


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
 |                                                                            |
 |     2 >  Activity/app performed earlier on given transaction with the      |
 |          above option left unchecked.                                      |
 |                                                                            |
 | REQUIRES                                                                   |
 |    p_org_id                                                                |
 |    p_customer_trx_id                                                       |
 |                                                                            |
 | HISTORY                                                                    |
 |      04/12/08         nproddut       Created                               |
 *----------------------------------------------------------------------------*/
FUNCTION is_llca_allowed( p_org_id          IN NUMBER DEFAULT NULL,
                          p_customer_trx_id IN NUMBER DEFAULT NULL ) RETURN BOOLEAN;


pg_prf_enable_debug	VARCHAR2(10) := 'N';


END ARP_STANDARD;

/
