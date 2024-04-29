--------------------------------------------------------
--  DDL for Package HR_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_UTILITY" AUTHID CURRENT_USER as
/* $Header: pyutilty.pkh 120.0.12010000.2 2008/12/12 10:52:39 sathkris ship $ */
/*
  Copyright (c) Oracle Corporation (UK) Ltd 1993.
  All rights reserved

  Name:   hr_utility

  Description:

     -- Cover routines for FND_MESSAGE
     -- HR trace routines
     -- Miscellaneous other things. See also HR_GENERAL

  NEW 8.x DEPENDENCIES

  Autonomous Transaction (8.1.x)
  DBMS_SYSTEM (8.0.x)


  Change List
  -----------
  dkerr          11-DEC-2002   Added NOCOPY hint to OUT and IN OUT parameters
  dkerr          03-DEC-2002   Added debug_enabled()
  nbristow       28-FEB-2002   Added dbdrv statements.
  nbristow       28-FEB-2002   Changed read_trace_table to have a smaller PL/SQL
                               table. NT could not support a large table.
  P.Walker       24-AUG-2001   Removed pragma restriction from set_location()
                               to enable AOL Process Logging
                               added following procedures:
                               log_at_statement_level()
                               log_at_procedure_level()
                               log_at_event_level()
                               log_at_exception_level()
                               log_at_error_level()
                               log_at_unexpected_level()
                               switch_logging_on()
                               switch_logging_off()
  N.Bristow      18-JUL-2001   Added read_trace_table to improve PYUPIP
                               performance.
  D Kerr         22-MAR-1999   Added set_trace_options
  T Habara       03-DEC-1998   Added pragma WNDS to all the procedures and
                               functions except for trace_on and fnd_insert.
  M Reid         06-NOV-1998   Added language parameter to chk_product_install
                               and created overloaded version.
  KKOH           08-SEP-1998   Added PRAGMA RESTRICT_REFERENCES command
                               to allow HR_DISCOVERER.GET_ACTUAL_BUDGET_VALUES
                               function to call a procedure HRGETACT.GET_ACTUALS
                               which references this package

  D Kerr         20-JUL-1998     - Changes to hr_trace to ensure compatibility
                                   with NT.
                                 - Added trace_udf to allow FastFormula to
                                   be traced.
  D Kerr         09-JAN-1997     Added WNDS purity assertions to
                                 set_location and trace.
                                 This depends on fnd_message.raise_error
                                 having the same (519748)
  K Mundair      02-JUN-1997     Added procedure chk_product_install
  D Kerr         22-DEC-1996     Added trace_on overloads,
                                 read_trace_pipe and get_trace_id.
  D Harris       14-SEP-1993     Changed the HR_ERROR_NUMBER number
                                 from -20000 to -20001 form forms 4 and
                                 10x.
  P Gowers       05-APR-1993     Add get_message_details, get_token_details
  P Gowers       02-MAR-1993     Add set_message_token which translates token
  P Gowers       20-JAN-1993     Big bang.
  C Carter       12-OCT-1999     Removed pragma restriction from SET_MESSAGE
                                 and ORACLE_ERROR for bug 1027169.
  Sathkris       12-DEC-2008     Added get_icx_val function
*/
--
-- Public Package variables
--

--
   type t_varchar180 is table of varchar2(180) index by binary_integer;
--
--  define HR error number
  HR_ERROR_NUMBER CONSTANT number := -20001;

--
-- PIPE timeout constants
--
PIPE_READ_TIMEOUT  constant number := 600 ;
PIPE_PUT_TIMEOUT   constant number := 300 ;

--
-- Note, pragma only accepts numeric literals for error number, but this
-- number MUST be the same as the package global constant HR_ERROR_NUMBER
--
  hr_error exception;
  pragma exception_init (hr_error, -20001);
--

  procedure trace (trace_data in varchar2);
  pragma restrict_references (trace , WNDS) ;
  -- The following overloads are used to overcome the forms PL/SQL v1
  -- limitation which prevents defaults from being used in stored
  -- procedures.
  -- See package body for details of calls
  procedure trace_on ;
  procedure trace_on (trace_mode         in varchar2 ) ;
  procedure trace_on (trace_mode         in varchar2,
		      session_identifier in varchar2 ) ;
  procedure trace_off;
  pragma restrict_references (trace_off , WNDS);

  -- UDF covers
  -- DK 26-MAR-98
  -- Added UDF to allow formulas to be traced.
  -- This performanes the same as trace() however it has to be
  -- a function as procedures are not yet supported from formula
  -- It returns 'TRUE' if tracing is enabled otherwise FALSE.
  --
  function  trace_udf (trace_data in varchar2) return varchar2 ;
  pragma restrict_references (trace_udf , WNDS);

---------------------------------- hr_error ----------------------------------
/*
  NAME
    hr_error  -  Returns the equivalent sqlcode of hr_error exception
  DESCRIPTION
    Needed because forms 3.0/4.0 cannot handle package exception 'hr_error'
  function hr_error return number;
*/
-------------------------------- clear_message ----------------------------
/*
  NAME
    clear_message
  DESCRIPTION
    clears current message text and number
*/
  procedure clear_message;
  pragma restrict_references (clear_message , WNDS);
-------------------------------- set_message --------------------------------
/*
  NAME
    set_message
  DESCRIPTION
    Calls fnd_dict package to set up the named error
*/
  procedure set_message (applid in number, l_message_name in varchar2);
  --pragma restrict_references (set_message , WNDS);
------------------------------ set_message_token ------------------------------
/*
  NAME
    set_message_token
  DESCRIPTION
    Calls fnd_dict set set up a message token value
*/
  procedure set_message_token (l_token_name in varchar2,
                               l_token_value in varchar2);
  pragma restrict_references (set_message_token , WNDS);
------------------------------ set_message_token ------------------------------
/*
  NAME
    set_message_token
  DESCRIPTION
    Overloaded: Sets up a translated message token
*/
  procedure set_message_token (l_applid in number,
                               l_token_name in varchar2,
                               l_token_message in varchar2);
  pragma restrict_references (set_message_token , WNDS);
-------------------------------- get_message --------------------------------
/*
  NAME
    get_message
  DESCRIPTION
    Calls fnd_dict to assemble the current message text and return it
*/
  function get_message return varchar2;
  pragma restrict_references (get_message , WNDS);
----------------------------- get_message_details -----------------------------
/*
  NAME
    get_message_details
  DESCRIPTION
    Gets the name and the application short name of the message last set
*/
  procedure get_message_details (msg_name in out nocopy varchar2,
                                 msg_appl in out nocopy varchar2);
  pragma restrict_references (get_message_details , WNDS);
-------------------------------- set_warning --------------------------------
/*
  NAME
    set_warning
  DESCRIPTION
    Sets the package warning flag to indicate that a warning has occurred
*/
  procedure set_warning;
  pragma restrict_references (set_warning , WNDS);
-------------------------------- check_warning --------------------------------
/*
  NAME
    check_warning
  DESCRIPTION
    Returns the value of the warning flag
*/
  function check_warning return boolean;
  pragma restrict_references (check_warning , WNDS);
-------------------------------- clear_warning --------------------------------
/*
  NAME
    clear_warning
  DESCRIPTION
    Resets the package warning flag
*/
  procedure clear_warning;
  pragma restrict_references (clear_warning , WNDS);
-------------------------------- set_location --------------------------------
/*
  NAME
    set_location
  DESCRIPTION
    Sets package variables to store location name and stage number which
    enables unexpected errors to be located more easily
*/
  procedure set_location (procedure_name in varchar2, stage in number);
  -- pragma restrict_references (set_location , WNDS) ;
-------------------------------- oracle_error --------------------------------
/*
  NAME
    oracle_error
  DESCRIPTION
    Sets generic oracle error message and passes the sqlcode, and error
    location information
*/
  procedure oracle_error (oracode in number);
  --pragma restrict_references (oracle_error , WNDS);
-------------------------------- raise_error --------------------------------
/*
  NAME
    raise_error
  DESCRIPTION
    Performs raise_application_error but always with the same error number
    HR_ERROR_NUMBER for consistency
*/
  procedure raise_error;
  pragma restrict_references (raise_error , WNDS);
-------------------------------- fnd_insert --------------------------------
/*
  NAME
    fnd_insert
  DESCRIPTION
    Inserts a row into FND_SESSIONS for the date passed for the current
    session id
*/
  procedure fnd_insert (l_effective_date in date);

-------------------------------- read_trace_pipe  ----------------------------
/*
  NAME
    read_trace_pipe
  DESCRIPTION
    Reads the next message from the pipe
    Bug ?????? Using a default parameter was causing problems on NT
    For now include an overload
*/
procedure read_trace_pipe(p_pipename in varchar2,
		 	  p_status   in out nocopy number,
		          p_retval   in out nocopy varchar2 ) ;
pragma restrict_references (read_trace_pipe , WNDS);

procedure read_trace_pipe(p_pipename in varchar2,
			  p_timeout  in number,
		 	  p_status   in out nocopy number,
		          p_retval   in out nocopy varchar2 ) ;
pragma restrict_references (read_trace_pipe , WNDS);
-------------------------------- read_trace_table -----------------------------
/*
  NAME
    read_trace_table
  DESCRIPTION
    Reads the next message from the named pipe into a PL/SQL table.

    If the pipename is PIPEnnnn then after the given timeout period.
    The routine will check whether the corresponding session still
    exists. Support for other types may be added later.

  PARAMETERS

       p_pipename      Name of the pipe
       p_status        The return status from DBMS_PIPE.RECEIEVE_MESSAGE
       p_retval        The text PL/SQL table containing the messages
       p_messages      The maximum number of entries that should be placed
                       in the PL/SQL table.
       p_cnt_mess      The number of entries actually created in PL/SQL
                       table.
*/
procedure read_trace_table(p_pipename in varchar2,
                           p_status   in out nocopy number,
                           p_retval   in out nocopy t_varchar180,
                           p_messages in number,
                           p_cnt_mess in out nocopy number );
-------------------------------- get_trace_id  -------------------------------
/*
  NAME
    get_trace_id
  DESCRIPTION
    Returns the name of the PIPE that HR trace statements are written
    to
*/
  function get_trace_id return varchar2 ;
  pragma restrict_references (get_trace_id , WNDS);
-------------------------------- chk_product_install -------------------------
/*
  NAME
    chk_product_install
  DESCRIPTION
    Checks whether the product specified is installed for the legislation
    specified
  PARAMETERS
    p_product      Name of the product in initcap
    p_legislation  Legislation code(US,GB...)
*/
function chk_product_install (
        p_product             VARCHAR2,
        p_legislation         VARCHAR2,
        p_language            VARCHAR2) return boolean;
pragma restrict_references (chk_product_install , WNDS);

function chk_product_install (
        p_product             VARCHAR2,
        p_legislation         VARCHAR2) return boolean;
pragma restrict_references (chk_product_install , WNDS);

----------------------------- log_at_statement_level -------------------------
/*
  NAME
      log_at_statement_level
  DESCRIPTION

      Used for low level logging messages giving maximum detail
      Example:  Copying string from buffer xyz to buffer zyx

  PARAMETERS

    p_product         Short name of the application e.g. 'pay', 'per',...

    p_procedure_name  name of calling procedure including package name
                      eg. package_name.procedure_name

    p_label A unique name for the part within the procedure.  The major
            reason for providing the label is to make a module name uniquely
            identify exactly one log call.   This will allow support analysts
            or programmers who look at logs to know exactly which piece of code
            produced your message, even without looking at the message (which
            may be translated).  So make labels for each log statement unique
            within a routine.
            If it is desired to group a number of log calls from different
            routines and files into a group that can be enabled or disabled
            atomically, this can be done with a two part label.  The first part
            would be the functional group name, and the second part would be
            the unique code location.  For instance, descriptive flexfield
            validation code might have several log calls in different places
            with labels desc_flex_val.check_value,
            desc_flex_val.display_window, and desc_flex_val.parse_code.  Those
            would all be enabled by enabling module fnd.%.desc_flex_val even
            though they all exist in different code locations.
            Examples: begin, lookup_app_id, parse_sql_failed,
                      myfeature.done_exec

    p_message This is the string that will actually be written to the log file.
              It will be crafted by the programmer to clearly tell the reader
              whatever information needs to be conveyed about the state of the
              code execution.
              if p_message is omitted the message will default to p_label
*/

procedure log_at_statement_level
                (p_product          IN VARCHAR2
                ,p_procedure_name   IN VARCHAR2
                ,p_label            IN VARCHAR2
                ,p_message          IN VARCHAR2 default null);

----------------------------- log_at_procedure_level -------------------------
/*
  NAME
      log_at_procedure_level

  DESCRIPTION

      Used to log messages called upon entry and/or exit from a routine
      Example:  Entering routine fdllov()

  PARAMETERS

    p_product         Short name of the application e.g. 'pay', 'per',...

    p_procedure_name  name of calling procedure including package name
                      eg. package_name.procedure_name

    p_label A unique name for the part within the procedure.  The major
            reason for providing the label is to make a module name uniquely
            identify exactly one log call.   This will allow support analysts
            or programmers who look at logs to know exactly which piece of code
            produced your message, even without looking at the message (which
            may be translated).  So make labels for each log statement unique
            within a routine.
            If it is desired to group a number of log calls from different
            routines and files into a group that can be enabled or disabled
            atomically, this can be done with a two part label.  The first part
            would be the functional group name, and the second part would be
            the unique code location.  For instance, descriptive flexfield
            validation code might have several log calls in different places
            with labels desc_flex_val.check_value,
            desc_flex_val.display_window, and desc_flex_val.parse_code.  Those
            would all be enabled by enabling module fnd.%.desc_flex_val even
            though they all exist in different code locations.
            Examples: begin, lookup_app_id, parse_sql_failed,
                      myfeature.done_exec

    p_message This is the string that will actually be written to the log file.
              It will be crafted by the programmer to clearly tell the reader
              whatever information needs to be conveyed about the state of the
              code execution.
              if p_message is omitted the message will default to p_label
*/

procedure log_at_procedure_level
                (p_product          IN VARCHAR2
                ,p_procedure_name   IN VARCHAR2
                ,p_label            IN VARCHAR2
                ,p_message          IN VARCHAR2 default null);

-------------------------------- log_at_event_level -------------------------
/*
  NAME
      log_at_event_level
  DESCRIPTION

      Used for high level logging message
      Examples: User pressed "Abort" button
                Beginning establishment of apps security session

  PARAMETERS

    p_product         Short name of the application e.g. 'pay', 'per',...

    p_procedure_name  name of calling procedure including package name
                      eg. package_name.procedure_name

    p_label A unique name for the part within the procedure.  The major
            reason for providing the label is to make a module name uniquely
            identify exactly one log call.   This will allow support analysts
            or programmers who look at logs to know exactly which piece of code
            produced your message, even without looking at the message (which
            may be translated).  So make labels for each log statement unique
            within a routine.
            If it is desired to group a number of log calls from different
            routines and files into a group that can be enabled or disabled
            atomically, this can be done with a two part label.  The first part
            would be the functional group name, and the second part would be
            the unique code location.  For instance, descriptive flexfield
            validation code might have several log calls in different places
            with labels desc_flex_val.check_value,
            desc_flex_val.display_window, and desc_flex_val.parse_code.  Those
            would all be enabled by enabling module fnd.%.desc_flex_val even
            though they all exist in different code locations.
            Examples: begin, lookup_app_id, parse_sql_failed,
                      myfeature.done_exec

    p_message This is the string that will actually be written to the log file.
              It will be crafted by the programmer to clearly tell the reader
              whatever information needs to be conveyed about the state of the
              code execution.
              if p_message is omitted the message will default to p_label
*/

procedure log_at_event_level
                (p_product          IN VARCHAR2
                ,p_procedure_name   IN VARCHAR2
                ,p_label            IN VARCHAR2
                ,p_message          IN VARCHAR2 default null);

----------------------------- log_at_exception_level -------------------------
/*
  NAME
      log_at_exception_level
  DESCRIPTION
      Used to to log a message when an internal routine is returning a failure
      code or exception, but the error does not necessarily indicate a problem
      at the user's level.

      Examples: Profile ABC not found,
                Networking routine XYZ could not connect; retrying.
                File not found (in a low-level file routine)
                Database error (in a low-level database routine like afupi)
  PARAMETERS

    p_product         Short name of the application e.g. 'pay', 'per',...

    p_procedure_name  name of calling procedure including package name
                      eg. package_name.procedure_name

    p_label A unique name for the part within the procedure.  The major
            reason for providing the label is to make a module name uniquely
            identify exactly one log call.   This will allow support analysts
            or programmers who look at logs to know exactly which piece of code
            produced your message, even without looking at the message (which
            may be translated).  So make labels for each log statement unique
            within a routine.
            If it is desired to group a number of log calls from different
            routines and files into a group that can be enabled or disabled
            atomically, this can be done with a two part label.  The first part
            would be the functional group name, and the second part would be
            the unique code location.  For instance, descriptive flexfield
            validation code might have several log calls in different places
            with labels desc_flex_val.check_value,
            desc_flex_val.display_window, and desc_flex_val.parse_code.  Those
            would all be enabled by enabling module fnd.%.desc_flex_val even
            though they all exist in different code locations.
            Examples: begin, lookup_app_id, parse_sql_failed,
                      myfeature.done_exec

    p_message This is the string that will actually be written to the log file.
              It will be crafted by the programmer to clearly tell the reader
              whatever information needs to be conveyed about the state of the
              code execution.
              if p_message is omitted the message will default to p_label
*/

procedure log_at_exception_level
                (p_product          IN VARCHAR2
                ,p_procedure_name   IN VARCHAR2
                ,p_label            IN VARCHAR2
                ,p_message          IN VARCHAR2 default null);

-------------------------------- log_at_error_level -------------------------
/*
  NAME
      log_at_error_level
  DESCRIPTION
      An error message to the user; logged automatically by Message
      Dict calls to "Error()" routines, but can also be logged
      by other code.

      Examples: User entered a duplicate value for field XYZ
                Invalid apps username or password at Signon screen.
                Function not available

  PARAMETERS

    p_product         Short name of the application e.g. 'pay', 'per',...

    p_procedure_name  name of calling procedure including package name
                      eg. package_name.procedure_name

    p_label A unique name for the part within the procedure.  The major
            reason for providing the label is to make a module name uniquely
            identify exactly one log call.   This will allow support analysts
            or programmers who look at logs to know exactly which piece of code
            produced your message, even without looking at the message (which
            may be translated).  So make labels for each log statement unique
            within a routine.
            If it is desired to group a number of log calls from different
            routines and files into a group that can be enabled or disabled
            atomically, this can be done with a two part label.  The first part
            would be the functional group name, and the second part would be
            the unique code location.  For instance, descriptive flexfield
            validation code might have several log calls in different places
            with labels desc_flex_val.check_value,
            desc_flex_val.display_window, and desc_flex_val.parse_code.  Those
            would all be enabled by enabling module fnd.%.desc_flex_val even
            though they all exist in different code locations.
            Examples: begin, lookup_app_id, parse_sql_failed,
                      myfeature.done_exec

    p_message This is the string that will actually be written to the log file.
              It will be crafted by the programmer to clearly tell the reader
              whatever information needs to be conveyed about the state of the
              code execution.
              if p_message is omitted the message will default to p_label
*/

procedure log_at_error_level
                (p_product          IN VARCHAR2
                ,p_procedure_name   IN VARCHAR2
                ,p_label            IN VARCHAR2
                ,p_message          IN VARCHAR2 default null);

--------------------------- log_at_unexpected_level -------------------------
/*
  NAME
      log_at_unexpected_level
  DESCRIPTION
      An unexpected situation occurred which is likely to indicate
      or cause instabilities in the runtime behavior, and which
      the System Administrator needs to take action on.
      Note to developers: Think very carefully before logging
      messages at this level; Administrators are going to get worried
      and file high priority bugs if your code logs at this level
      frequently.

      Examples: Out of memory, Required file not found, Data integrity error
                Network integrity error, Internal error, Fatal database error

  PARAMETERS

    p_product         Short name of the application e.g. 'pay', 'per',...

    p_procedure_name  name of calling procedure including package name
                      eg. package_name.procedure_name

    p_label A unique name for the part within the procedure.  The major
            reason for providing the label is to make a module name uniquely
            identify exactly one log call.   This will allow support analysts
            or programmers who look at logs to know exactly which piece of code
            produced your message, even without looking at the message (which
            may be translated).  So make labels for each log statement unique
            within a routine.
            If it is desired to group a number of log calls from different
            routines and files into a group that can be enabled or disabled
            atomically, this can be done with a two part label.  The first part
            would be the functional group name, and the second part would be
            the unique code location.  For instance, descriptive flexfield
            validation code might have several log calls in different places
            with labels desc_flex_val.check_value,
            desc_flex_val.display_window, and desc_flex_val.parse_code.  Those
            would all be enabled by enabling module fnd.%.desc_flex_val even
            though they all exist in different code locations.
            Examples: begin, lookup_app_id, parse_sql_failed,
                      myfeature.done_exec

    p_message This is the string that will actually be written to the log file.
              It will be crafted by the programmer to clearly tell the reader
              whatever information needs to be conveyed about the state of the
              code execution.
              if p_message is omitted the message will default to p_label
*/

procedure log_at_unexpected_level
                (p_product          IN VARCHAR2
                ,p_procedure_name   IN VARCHAR2
                ,p_label            IN VARCHAR2
                ,p_message          IN VARCHAR2 default null);

-------------------------------- switch_logging_on -------------------------
/*
  NAME
    switch_logging_on
  DESCRIPTION
    Turns on AOL debug message logging at specified level when not using
    standard applications login (eg sqlplus session). Logging is enabled
    for a user by setting user profile options. The user and responsibility
    can be specified with p_user_id and p_responsibility_id .If p_user_id
    is not specified the user will default to SYSADMIN. If p_responsibility_id
    is not specified the responsibility will default to the first
    responsibility in the list of responsibilities for the user ordered by
    responsibility_id.

  PARAMETERS

    p_logging_level:       possible values: FND_LOG.LEVEL_UNEXPECTED
                                        FND_LOG.LEVEL_ERROR
                                        FND_LOG.LEVEL_EXCEPTION
                                        FND_LOG.LEVEL_EVENT
                                        FND_LOG.LEVEL_PROCEDURE
                                        FND_LOG.LEVEL_STATEMENT
                           default is FND_LOG.LEVEL_STATEMENT
    p_user_id:             user id for which logging will be enabled
    p_responsibility_id:   responsibility id for which logging will be enabled
*/

procedure switch_logging_on
                (p_logging_level     in number default fnd_log.level_statement
                ,p_user_id           in number default null
                ,p_responsibility_id in number default null);


-------------------------------- switch_logging_off -------------------------
/*
  NAME
    switch_logging_off
  DESCRIPTION
    Turns off AOL debug messaging previously turned on by calling
    switch_logging_on. Logging is disabled by setting user profile
    options for the user defined in the prior call to switch_logging_on.
    If switch_logging_on is not called before calling
    switch_logging_off, the user is set to 'SYSADMIN'.

*/

procedure switch_logging_off;

-- DK 22-MAR-1999. Added to end of the package to avoid recompilations
procedure set_trace_options (p_options         in varchar2 ) ;
--
-------------------------------- debug_enabled -------------------------
/*
  NAME
    debug_enabled
  DESCRIPTION
    Returns TRUE if the logging function if either HR Trace is enabled
    or if AOL Logging has been enabled at procedure level.

    This is currently implemented as a function call. This may be changed
    to a public variable at some point. Don't use the empty argument list
    form eg. hr_utility.debug_enabled() when referring to this function.

    This is intended to be used a performance optimization to limit the
    number of package function calls made in code that is called _very_
    frequently.

    The typical usage will be like this :


    package body some_package is

         ...
         ...
         g_debug boolean := hr_utility.debug_enabled;

         ...
         ...


         procedure public_procedure(params,..) is
         l_proc   varchar2(72) ;
         begin

            g_debug := hr_utility.debug_enabled ;

            if (g_debug) then
              l_proc := g_package||'chk_type_id';
              hr_utility.set_location('Entering:'|| l_proc, 10);
            end if;

             ...
             ...

            if (g_debug) then
              hr_utility.trace('xyz')
            end if;

             ...
             ...


            if (g_debug) then
              fnd_log.string(parameters,...);
            end if;

             ...

        end public_procedure ;


        Note that in most cases it is sufficient to synchronize the
        value of g_debug only in the implementations of public procedures
        and functions.


  PARAMETERS
    *None*
*/
--
function debug_enabled return boolean;
--

PRAGMA RESTRICT_REFERENCES(hr_utility,WNDS);

  /*Function added to get the ICX Attribute values */
   FUNCTION get_icx_val(p_attribute_name varchar2,p_session_id number)
   RETURN VARCHAR2;

end hr_utility;

/

  GRANT EXECUTE ON "APPS"."HR_UTILITY" TO "HR";
