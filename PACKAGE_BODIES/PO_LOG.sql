--------------------------------------------------------
--  DDL for Package Body PO_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LOG" AS
-- $Header: PO_LOG.plb 120.0 2005/06/02 01:57:55 appldev noship $

--
-- For more details on the PO logging strategy,
-- see the document at
-- /podev/po/internal/standards/logging/logging.xml
--

/******************************************************************************
 ******************************************************************************

Quick example use reference
---------------------------

CREATE OR REPLACE PACKAGE BODY MY_PACKAGE AS

D_PACKAGE_BASE CONSTANT VARCHAR2(50) := PO_LOG.get_package_base('MY_PACKAGE');

D_my_proc CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'my_proc');

PROCEDURE my_proc(
  p_in    IN PO_TBL_NUMBER
, p_inout IN OUT NOCOPY NUMBER
, p_out   OUT NOCOPY VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_my_proc;
d_position NUMBER := 0;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_in',p_in);
  PO_LOG.proc_begin(d_mod,'p_inout',p_inout);
END IF;

d_position := 1;

-- do some stuff...

d_position := 123;
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,d_position,'did some stuff');
END IF;

-- do some more stuff...

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'p_inout',p_inout);
  PO_LOG.proc_end(d_mod,'p_out',p_out);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;

END my_proc;

END MY_PACKAGE;


Summary of how to use the logging routines
------------------------------------------

All logging routines take a module_base.  The module base should
be derived through calls to get_package_base and get_subprogram_base.
These should be stored in CONSTANT package variables instead of
being derived directly in the procedure, as the cost of invoking
another procedure for each procedure invocation can be avoided.

For the STATEMENT and PROCEDURE logging routines, signatures are provided
that take variable names and variable values.  These are convenient ways
to log several parameters or variables without having to concatenate
big log messages with name/value delimiters, converting variables into
strings, etc.

Use of the different levels of logging statements should follow the
following guidelines:

1-STATEMENT - PO_LOG.stmt()

  Use STATEMENT-level for general debugging messages within the body
  of a method / procedure.

  Dynamic SQL must be recorded with STATEMENT-level logging, as well
  as all bind variables that are used while executing the SQL.

2-PROCEDURE - PO_LOG.proc_xxx()

  At the very beginning of every method/procedure, and immediately
  before every exit point of the procedure (return statements, thrown
  exceptions, normal "fall of the end"), PROCEDURE-level logs should
  be written. PROCEDURE-level messages should also record all of the
  input and output of a procedure.

  At the beginning of a procedure/function, proc_begin() should be
  called for each IN or IN OUT parameter, or just for the module if it
  has no such parameters.

  At the end of a procedure/function, proc_end()/proc_return() should be
  called, again for each IN OUT or OUT parameter, return value, or just
  for the module if it has none of these.  Be sure to call these routines
  before each RETURN or normal RAISE statement in the procedure/function.

3-EVENT - PO_LOG.event()

  At the beginning and end of a "flow", EVENT-level messages should be
  logged. EVENT-level messages should be used at the beginning/end of
  APIs, user-initiated actions (Form submits), concurrent requests,
  workflows, and so on. EVENT-level logging should occur both before
  and after calling another product's API. EVENT-level messages should
  also be used to mark milestones within a larger flow, e.g. "document
  locked", "validations completed", "document updated". EVENT-level
  messages should surround all COMMITs, SAVEPOINTS, and ROLLBACKs.

4-EXCEPTION - PO_LOG.exc()

  An EXCEPTION-level message should be logged any time an "exception"
  occurs in the code. In PL/SQL, such a message should be logged at
  the beginning of every (EXCEPTION) WHEN xxx THEN block unless the
  exception is expected as part of the normal code flow, such as
  NO_DATA_FOUND queries that are expected. If the PL/SQL exception is
  expected, it should have a STATEMENT-level log message at the
  beginning of the block instead of an EXCEPTION-level message.

  EXCEPTION-level messages should also be recorded if the code
  encounters a condition that was not expected from a programming
  perspective. This may include the default section of a switch
  statement or the ELSE clause of a series of IF-ELSE IF
  conditions. Furthermore, an EXCEPTION-level message should be logged
  by any code that silently recovers from an unexpected
  condition. Examples of this include fixing API parameters, like
  setting the parameter to 'N' if it was NULL, or turning null into
  the empty String "" to make code more robust.

  EXCEPTION-level messages can be monitored and used to improve an
  application's performance and robustness.

 ******************************************************************************
 ******************************************************************************
 */

/******************************************************************************

Debug logging notes
(from Oracle Applications Logging Framework Guide, 8/21/03):

...
In some rare circumstances, for example, if you are debugging an
issue, you may need to manually initialize the PL/SQL layer logging
for the current session. From the SQL*Prompt, you could do this by
calling:

FND_GLOBAL.APPS_INITIALIZE(fnd_user_id, fnd_resp_id, fnd_appl_id);
fnd_profile.put('AFLOG_ENABLED', 'Y');
fnd_profile.put('AFLOG_MODULE', '%');
fnd_profile.put('AFLOG_LEVEL','1');
fnd_profile.put('AFLOG_FILENAME', '');
fnd_log_repository.init;

Do not ship any code with these calls! Shipping code that internally
hard codes Log Properties is a severe P1 bug.
...

-- Note:
-- The above calls do not modify the stored values in the database.
-- Instead, they update the cached runtime values.

...
Using Database Profile Options to Configure Logging

To enable logging using database profile options, set the following
profile options at the desired profile option level:

Profile Option Name     User Specified Name        Sample Value
AFLOG_ENABLED           FND: Debug Log Enabled     "Y"
AFLOG_MODULE            FND: Debug Log Module      "%"
AFLOG_LEVEL             FND: Debug Log Level       "ERROR"
AFLOG_FILENAME          FND: Debug Log Filename    "/path/to/apps.log"


******************************************************************************

Debugging example:

This method was used to debug PO_DOCUMENT_FUNDS_PVT.do_unreserve.

The following code was executed:


DECLARE
l_return_status VARCHAR2(2000);
l_po_return_code VARCHAR2(2000);
l_online_report_id NUMBER;

d_mod VARCHAR2(100);

BEGIN

FND_GLOBAL.APPS_INITIALIZE(1318, 50063, 201);  -- operations, vision services, purchasing

PO_LOG.enable_logging('po.plsql.SBULL%,po.plsql.%ENCUMBRANCE%,po.plsql.PO_DOCUMENT_FUNDS%');

d_mod := PO_LOG.get_subprogram_base(PO_LOG.get_package_base('SBULL'),'TEST');

PO_LOG.proc_begin(d_mod);

PO_DOCUMENT_FUNDS_PVT.do_unreserve(
   x_return_status      => l_return_status
,  p_doc_type           => PO_DOCUMENT_FUNDS_PVT.g_doc_type_PO
,  p_doc_subtype        => PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_STANDARD
,  p_doc_level          => PO_DOCUMENT_FUNDS_PVT.g_doc_level_HEADER
,  p_doc_level_id       => 20604
,  p_use_enc_gt_flag    => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
,  p_validate_document  => PO_DOCUMENT_FUNDS_PVT.g_parameter_YES
,  p_override_funds     => PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE
,  p_use_gl_date        => PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE
,  p_override_date      => SYSDATE
,  p_employee_id        => NULL
,  x_po_return_code     => l_po_return_code
,  x_online_report_id   => l_online_report_id
);

PO_LOG.proc_end(d_mod);

END;


After the code was executed, the messages were inspected like so:

select module,message_text,timestamp, log_sequence
from fnd_log_messages
where log_sequence
   between
      (  select max(log_sequence)
         from fnd_log_messages
         where module = 'po.plsql.SBULL.TEST.BEGIN'
      )
   and
      (  select max(log_sequence)
         from fnd_log_messages
         where module = 'po.plsql.SBULL.TEST.END'
      )
order by log_sequence
;

******************************************************************************/



---------------------------------------------------------------------------
-- CONSTANTS
---------------------------------------------------------------------------

-- Used to separate tokens in the module string.
D_MODULE_SEPARATOR CONSTANT VARCHAR2(1) := '.';

-- Contains the string that must prefix all
-- module names in log messages from PO PL/SQL procedures.
D_MODULE_PREFIX CONSTANT VARCHAR2(9) := 'po.plsql.';

-- Used in the message text of an array's count.
D_COUNT CONSTANT VARCHAR2(6) := '.COUNT';

-- Used in the message text of array elements.
L_PAREN CONSTANT VARCHAR2(1) := '(';

-- Used in the message text of array elements.
R_PAREN CONSTANT VARCHAR2(1) := ')';

-- Used in the module of procedure messages.
D_BEGIN CONSTANT VARCHAR2(5) := 'BEGIN';

-- Used in the module of procedure messages.
D_END CONSTANT VARCHAR2(3) := 'END';

-- Used in the module of procedure messages.
D_RETURN CONSTANT VARCHAR2(6) := 'RETURN';

-- Used in the module of procedure messages.
D_RAISE CONSTANT VARCHAR2(5) := 'RAISE';

-- Used in the text of procedure messages.
D_START_OF_SUBPROGRAM CONSTANT VARCHAR2(20) := 'Start of subprogram.';

-- Used in the text of procedure messages.
D_END_OF_SUBPROGRAM CONSTANT VARCHAR2(18) := 'End of subprogram.';

-- Used in the text of procedure messages.
D_RETURN_VALUE CONSTANT VARCHAR2(12) := 'Return value';


---------------------------------------------------------------------------
-- Modules for debugging.
---------------------------------------------------------------------------

-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) := get_package_base('PO_LOG');

-- The module base for the subprogram.
D_MOD_refresh_log_flags CONSTANT VARCHAR2(100) :=
  get_subprogram_base(D_PACKAGE_BASE,'refresh_log_flags');


---------------------------------------------------------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------------------------------------------------------


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: The AFLOG_xxx profile options and variables in this package.
--Locks: None.
--Function:
--
--  *** DO NOT USE IN PRODUCTION CODE! ***
--
--  This procedure updates the FND Logging profile options and the cached
--  values in this package to enable logging for the current responsibility
--  for the session.
--
--  This should only be used while trying to debug a problem, as a
--  substitute for setting the FND profile options.
--
--Parameters:
--IN:
--p_module
--  A comma-separated list of module criteria
--  for which logging should be enabled.
--  Example: 'po.plsql.PO_DOCUMENT_FUNDS%,po.plsql.PO_ENCUMBRANCE%'
--p_level
--  The lowest level for which logging should be enabled.
--  Use the following values:
--    1 - STATEMENT
--    2 - PROCEDURE
--    3 - EVENT
--    4 - EXCEPTION
--    5 - ERROR
--    6 - UNEXPECTED
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE enable_logging(
  p_module  IN VARCHAR2 DEFAULT 'p'||'o.%' -- GSCC File.Sql.6
, p_level   IN NUMBER DEFAULT 1
)
IS
BEGIN

-- Set the FND profile option values.
FND_PROFILE.put('AFLOG_ENABLED','Y');
FND_PROFILE.put('AFLOG_MODULE',p_module);
FND_PROFILE.put('AFLOG_LEVEL',TO_CHAR(p_level));
FND_PROFILE.put('AFLOG_FILENAME','');

-- Refresh the FND cache.
FND_LOG_REPOSITORY.init();

-- Refresh the PO cache.
refresh_log_flags();

END enable_logging;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: The d_xxx public package variables.
--Locks: None.
--Function:
--  Updates the d_xxx variables with indicators of whether or not
--  logging is enabled at the particular level.
--
--  This procedure should be called whenever the Apps context changes,
--  as the determination of whether or not logging is enabled depends
--  on profile values that can change with different responsibilities.
--  This can be accomplished by adding a hook into
--  FND_GLOBAL.APPS_INITIALIZE via the FND_PRODUCT_INITIALIZATION table.
--
--  This procedure will also be called during package intialization.
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE refresh_log_flags
IS
l_current_log_level NUMBER;
BEGIN

IF (FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y') THEN
  l_current_log_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  d_stmt := (l_current_log_level <= FND_LOG.LEVEL_STATEMENT);
  d_proc := (l_current_log_level <= FND_LOG.LEVEL_PROCEDURE);
  d_event := (l_current_log_level <= FND_LOG.LEVEL_EVENT);
  d_exc := (l_current_log_level <= FND_LOG.LEVEL_EXCEPTION);
  d_error := (l_current_log_level <= FND_LOG.LEVEL_ERROR);
  d_unexp := (l_current_log_level <= FND_LOG.LEVEL_UNEXPECTED);
ELSE
  d_stmt := FALSE;
  d_proc := FALSE;
  d_event := FALSE;
  d_exc := FALSE;
  d_error := FALSE;
  d_unexp := FALSE;
END IF;

IF d_proc THEN
  proc_end(D_MOD_refresh_log_flags);
END IF;

EXCEPTION
WHEN OTHERS THEN
  NULL;

END refresh_log_flags;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: None.
--Locks: None.
--Function:
--  Appends the package name to the PL/SQL base module and adds
--  module separators.
--Parameters:
--IN:
--p_package_name The name of the package, for example, "PO_LOG".
--Returns:
--  A string appropriate for passing into get_subprogram_base().
--  VARCHAR2(50).
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_package_base(
  p_package_name                  IN  VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
RETURN D_MODULE_PREFIX || UPPER(p_package_name) || D_MODULE_SEPARATOR;
END get_package_base;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: None.
--Locks: None.
--Function:
--  Appends the subprogram name to the package base and adds
--  module separators.
--Parameters:
--IN:
--p_package_base The module string up to the package name, as returned
--  by get_package_base().
--p_subprogram_name The name of the subprogram,
--  for example, "get_subprogram_base".
--Returns:
--  A string appropriate for use in any of the logging routines requiring
--  the module base.
--  VARCHAR2(100).
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_subprogram_base(
  p_package_base                  IN  VARCHAR2
, p_subprogram_name               IN  VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
RETURN p_package_base || UPPER(p_subprogram_name) || D_MODULE_SEPARATOR;
END get_subprogram_base;



-------------------------------------------------------------------------------
-- Generic logging routines.
-------------------------------------------------------------------------------

PROCEDURE log(
  p_log_level     IN NUMBER
, p_module_base   IN VARCHAR2
, p_module_suffix IN VARCHAR2
, p_message_text  IN VARCHAR2
)
IS
BEGIN
IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(p_log_level,p_module_base||p_module_suffix,p_message_text);
END IF;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END log;


FUNCTION var_to_string(
  p_variable_name   IN VARCHAR2
, p_variable_value  IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
IF (p_variable_value IS NULL) THEN
  RETURN p_variable_name || ' is null';
ELSE
  RETURN p_variable_name || ' = ' || p_variable_value;
END IF;
END var_to_string;


FUNCTION var_to_string(
  p_variable_name   IN VARCHAR2
, p_variable_value  IN NUMBER
)
RETURN VARCHAR2
IS
BEGIN
RETURN var_to_string(p_variable_name,TO_CHAR(p_variable_value));
END var_to_string;


FUNCTION var_to_string(
  p_variable_name   IN VARCHAR2
, p_variable_value  IN DATE
)
RETURN VARCHAR2
IS
BEGIN
RETURN var_to_string(p_variable_name,
        TO_CHAR(p_variable_value,'DD-MON-RRRR HH:MI:SSAM'));
END var_to_string;


FUNCTION var_to_string(
  p_variable_name   IN VARCHAR2
, p_variable_value  IN BOOLEAN
)
RETURN VARCHAR2
IS
l_varchar_value VARCHAR2(5);
BEGIN
IF (p_variable_value IS NULL) THEN
  l_varchar_value := TO_CHAR(NULL);
ELSIF p_variable_value THEN
  l_varchar_value := 'TRUE';
ELSE
  l_varchar_value := 'FALSE';
END IF;
RETURN var_to_string(p_variable_name,l_varchar_value);
END var_to_string;


PROCEDURE decode_level_suffix(
  x_log_level     IN OUT NOCOPY NUMBER
, x_module_suffix IN OUT NOCOPY VARCHAR2
)
IS
BEGIN
IF (x_log_level IN (c_PROC_BEGIN,c_PROC_END,c_PROC_RETURN,c_PROC_RAISE)) THEN
  x_module_suffix :=
    CASE x_log_level
    WHEN c_PROC_BEGIN THEN D_BEGIN||D_MODULE_SEPARATOR||x_module_suffix
    WHEN c_PROC_END THEN D_END||D_MODULE_SEPARATOR||x_module_suffix
    WHEN c_PROC_RETURN THEN D_RETURN||D_MODULE_SEPARATOR||x_module_suffix
    WHEN c_PROC_RAISE THEN D_RAISE||D_MODULE_SEPARATOR||x_module_suffix
    ELSE x_module_suffix
    END;
  x_log_level := FND_LOG.LEVEL_PROCEDURE;
END IF;
END decode_level_suffix;

----------------------------------------------------------------------
-- This routine can be used for any logging level,
-- so that different procedures do not need to be
-- created for each kind of logging
-- (stmt/proc_begin/proc_end/proc_return/...).
-- @param p_log_level Use one of the package constants:
--    c_STMT, c_PROC_BEGIN, c_PROC_END, c_PROC_RETURN, etc.
----------------------------------------------------------------------
PROCEDURE log(
  p_log_level       IN NUMBER
, p_module_base     IN VARCHAR2
, p_module_suffix   IN VARCHAR2
, p_variable_name   IN VARCHAR2
, p_variable_value  IN PO_VALIDATION_RESULTS_TYPE
)
IS
l_log_level NUMBER;
l_module_suffix VARCHAR2(4000);
BEGIN
l_log_level := p_log_level;
l_module_suffix := p_module_suffix;
decode_level_suffix(l_log_level,l_module_suffix);
IF (p_variable_value IS NULL) THEN
  log(l_log_level,p_module_base,l_module_suffix,
    var_to_string(p_variable_name,TO_CHAR(NULL)));
ELSE
  log(l_log_level,p_module_base,l_module_suffix,
    var_to_string(p_variable_name||D_COUNT,p_variable_value.result_type.COUNT));
END IF;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END log;


PROCEDURE log(
  p_log_level       IN NUMBER
, p_module_base     IN VARCHAR2
, p_module_suffix   IN VARCHAR2
, p_variable_name   IN VARCHAR2
, p_variable_value  IN PO_TBL_NUMBER
)
IS
BEGIN
IF (p_variable_value IS NULL) THEN
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name,TO_CHAR(NULL)));
ELSE
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name||D_COUNT,p_variable_value.COUNT));
  FOR i IN 1 .. p_variable_value.COUNT LOOP
    log(p_log_level,p_module_base,p_module_suffix,
      var_to_string(p_variable_name||L_PAREN||TO_CHAR(i)||R_PAREN,
        p_variable_value(i)));
  END LOOP;
END IF;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END log;


PROCEDURE log(
  p_log_level       IN NUMBER
, p_module_base     IN VARCHAR2
, p_module_suffix   IN VARCHAR2
, p_variable_name   IN VARCHAR2
, p_variable_value  IN PO_TBL_DATE
)
IS
BEGIN
IF (p_variable_value IS NULL) THEN
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name,TO_CHAR(NULL)));
ELSE
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name||D_COUNT,p_variable_value.COUNT));
  FOR i IN 1 .. p_variable_value.COUNT LOOP
    log(p_log_level,p_module_base,p_module_suffix,
      var_to_string(p_variable_name||L_PAREN||TO_CHAR(i)||R_PAREN,
        p_variable_value(i)));
  END LOOP;
END IF;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END log;


PROCEDURE log(
  p_log_level       IN NUMBER
, p_module_base     IN VARCHAR2
, p_module_suffix   IN VARCHAR2
, p_variable_name   IN VARCHAR2
, p_variable_value  IN PO_TBL_VARCHAR1
)
IS
BEGIN
IF (p_variable_value IS NULL) THEN
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name,TO_CHAR(NULL)));
ELSE
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name||D_COUNT,p_variable_value.COUNT));
  FOR i IN 1 .. p_variable_value.COUNT LOOP
    log(p_log_level,p_module_base,p_module_suffix,
      var_to_string(p_variable_name||L_PAREN||TO_CHAR(i)||R_PAREN,
        p_variable_value(i)));
  END LOOP;
END IF;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END log;


PROCEDURE log(
  p_log_level       IN NUMBER
, p_module_base     IN VARCHAR2
, p_module_suffix   IN VARCHAR2
, p_variable_name   IN VARCHAR2
, p_variable_value  IN PO_TBL_VARCHAR5
)
IS
BEGIN
IF (p_variable_value IS NULL) THEN
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name,TO_CHAR(NULL)));
ELSE
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name||D_COUNT,p_variable_value.COUNT));
  FOR i IN 1 .. p_variable_value.COUNT LOOP
    log(p_log_level,p_module_base,p_module_suffix,
      var_to_string(p_variable_name||L_PAREN||TO_CHAR(i)||R_PAREN,
        p_variable_value(i)));
  END LOOP;
END IF;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END log;


PROCEDURE log(
  p_log_level       IN NUMBER
, p_module_base     IN VARCHAR2
, p_module_suffix   IN VARCHAR2
, p_variable_name   IN VARCHAR2
, p_variable_value  IN PO_TBL_VARCHAR30
)
IS
BEGIN
IF (p_variable_value IS NULL) THEN
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name,TO_CHAR(NULL)));
ELSE
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name||D_COUNT,p_variable_value.COUNT));
  FOR i IN 1 .. p_variable_value.COUNT LOOP
    log(p_log_level,p_module_base,p_module_suffix,
      var_to_string(p_variable_name||L_PAREN||TO_CHAR(i)||R_PAREN,
        p_variable_value(i)));
  END LOOP;
END IF;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END log;


PROCEDURE log(
  p_log_level       IN NUMBER
, p_module_base     IN VARCHAR2
, p_module_suffix   IN VARCHAR2
, p_variable_name   IN VARCHAR2
, p_variable_value  IN PO_TBL_VARCHAR100
)
IS
BEGIN
IF (p_variable_value IS NULL) THEN
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name,TO_CHAR(NULL)));
ELSE
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name||D_COUNT,p_variable_value.COUNT));
  FOR i IN 1 .. p_variable_value.COUNT LOOP
    log(p_log_level,p_module_base,p_module_suffix,
      var_to_string(p_variable_name||L_PAREN||TO_CHAR(i)||R_PAREN,
        p_variable_value(i)));
  END LOOP;
END IF;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END log;


PROCEDURE log(
  p_log_level       IN NUMBER
, p_module_base     IN VARCHAR2
, p_module_suffix   IN VARCHAR2
, p_variable_name   IN VARCHAR2
, p_variable_value  IN PO_TBL_VARCHAR2000
)
IS
BEGIN
IF (p_variable_value IS NULL) THEN
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name,TO_CHAR(NULL)));
ELSE
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name||D_COUNT,p_variable_value.COUNT));
  FOR i IN 1 .. p_variable_value.COUNT LOOP
    log(p_log_level,p_module_base,p_module_suffix,
      var_to_string(p_variable_name||L_PAREN||TO_CHAR(i)||R_PAREN,
        p_variable_value(i)));
  END LOOP;
END IF;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END log;


PROCEDURE log(
  p_log_level       IN NUMBER
, p_module_base     IN VARCHAR2
, p_module_suffix   IN VARCHAR2
, p_variable_name   IN VARCHAR2
, p_variable_value  IN PO_TBL_VARCHAR4000
)
IS
BEGIN
IF (p_variable_value IS NULL) THEN
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name,TO_CHAR(NULL)));
ELSE
  log(p_log_level,p_module_base,p_module_suffix,
    var_to_string(p_variable_name||D_COUNT,p_variable_value.COUNT));
  FOR i IN 1 .. p_variable_value.COUNT LOOP
    log(p_log_level,p_module_base,p_module_suffix,
      var_to_string(p_variable_name||L_PAREN||TO_CHAR(i)||R_PAREN,
        p_variable_value(i)));
  END LOOP;
END IF;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END log;



-------------------------------------------------------------------------------
-- STATEMENT-level logging.
-------------------------------------------------------------------------------

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_message_text                  IN  VARCHAR2  DEFAULT NULL
)
IS
BEGIN
log(FND_LOG.LEVEL_STATEMENT,p_module_base,TO_CHAR(p_position),p_message_text);
END stmt;

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  VARCHAR2
)
IS
BEGIN
log(FND_LOG.LEVEL_STATEMENT,p_module_base,TO_CHAR(p_position),
  var_to_string(p_variable_name,p_variable_value));
END stmt;

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  NUMBER
)
IS
BEGIN
log(FND_LOG.LEVEL_STATEMENT,p_module_base,TO_CHAR(p_position),
  var_to_string(p_variable_name,p_variable_value));
END stmt;

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  DATE
)
IS
BEGIN
log(FND_LOG.LEVEL_STATEMENT,p_module_base,TO_CHAR(p_position),
  var_to_string(p_variable_name,p_variable_value));
END stmt;

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  BOOLEAN
)
IS
BEGIN
log(FND_LOG.LEVEL_STATEMENT,p_module_base,TO_CHAR(p_position),
  var_to_string(p_variable_name,p_variable_value));
END stmt;

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_NUMBER
)
IS
BEGIN
log(FND_LOG.LEVEL_STATEMENT,p_module_base,TO_CHAR(p_position),
  p_variable_name,p_variable_value);
END stmt;

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_DATE
)
IS
BEGIN
log(FND_LOG.LEVEL_STATEMENT,p_module_base,TO_CHAR(p_position),
  p_variable_name,p_variable_value);
END stmt;

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_VARCHAR1
)
IS
BEGIN
log(FND_LOG.LEVEL_STATEMENT,p_module_base,TO_CHAR(p_position),
  p_variable_name,p_variable_value);
END stmt;

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_VARCHAR5
)
IS
BEGIN
log(FND_LOG.LEVEL_STATEMENT,p_module_base,TO_CHAR(p_position),
  p_variable_name,p_variable_value);
END stmt;

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_VARCHAR30
)
IS
BEGIN
log(FND_LOG.LEVEL_STATEMENT,p_module_base,TO_CHAR(p_position),
  p_variable_name,p_variable_value);
END stmt;

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_VARCHAR100
)
IS
BEGIN
log(FND_LOG.LEVEL_STATEMENT,p_module_base,TO_CHAR(p_position),
  p_variable_name,p_variable_value);
END stmt;

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_VARCHAR2000
)
IS
BEGIN
log(FND_LOG.LEVEL_STATEMENT,p_module_base,TO_CHAR(p_position),
  p_variable_name,p_variable_value);
END stmt;

PROCEDURE stmt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_variable_name                 IN  VARCHAR2
, p_variable_value                IN  PO_TBL_VARCHAR4000
)
IS
BEGIN
log(FND_LOG.LEVEL_STATEMENT,p_module_base,TO_CHAR(p_position),
  p_variable_name,p_variable_value);
END stmt;

-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: FND_LOG_MESSAGES
--Locks: None.
--Function:
--  Logs STATEMENT-level messages containing data from PO_SESSION_GT.
--Parameters:
--IN:
--p_module_base
--  The log module base as obtained from get_subprogram_base().
--p_position
--  A location indicator for the calling subprogram.
--p_key
--  Indicates which rows from PO_SESSION_GT to report.
--  All rows WHERE PO_SESSION_GT.key = p_key will be reported.
--p_column_name_tbl
--  The column names whose values for the specified rows should be reported.
--  If all column values should be reported, use NULL.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE stmt_session_gt(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_key                           IN  NUMBER
, p_column_name_tbl               IN  PO_TBL_VARCHAR30    DEFAULT NULL
)
IS
l_rowid_tbl PO_TBL_VARCHAR2000;
BEGIN

IF d_stmt THEN

  SELECT rowid
  BULK COLLECT INTO l_rowid_tbl
  FROM PO_SESSION_GT
  WHERE key = p_key
  ;

  stmt_table(
    p_module_base     => p_module_base
  , p_position        => p_position
  , p_table_name      => 'PO_SESSION_GT'
  , p_rowid_tbl       => l_rowid_tbl
  , p_column_name_tbl => p_column_name_tbl
  );

END IF;

EXCEPTION
WHEN OTHERS THEN
  NULL;
END stmt_session_gt;

-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: FND_LOG_MESSAGES
--Locks: None.
--Function:
--  Logs STATEMENT-level messages containing data from the specified table.
--Parameters:
--IN:
--p_module_base
--  The log module base as obtained from get_subprogram_base().
--p_position
--  A location indicator for the calling subprogram.
--p_table_name
--  The name of the table about which to report.
--p_rowid_tbl
--  The rowids of the table about which to report.
--  To report all rows in the table, use c_all_rows.
--p_column_name_tbl
--  The column names whose values for the specified rows should be reported.
--  If all column values should be reported, use NULL.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE stmt_table(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_table_name                    IN  VARCHAR2
, p_rowid_tbl                     IN  PO_TBL_VARCHAR2000
, p_column_name_tbl               IN  PO_TBL_VARCHAR30    DEFAULT NULL
)
IS

TYPE t_tbl_data_type    IS TABLE OF ALL_TAB_COLUMNS.column_name%TYPE;
TYPE t_tbl_varchar      IS TABLE OF VARCHAR2(4000);
TYPE t_ref_csr          IS REF CURSOR;

l_column_name_tbl    po_tbl_varchar30;
l_data_type_tbl      t_tbl_data_type;

l_printable_column_tbl  po_tbl_varchar30;

l_value_rowid_tbl    po_tbl_varchar2000;
l_value_tbl          t_tbl_varchar;

l_sql    VARCHAR2(32767);
l_char   VARCHAR2(4000);

l_col_i  PLS_INTEGER;

l_table_name   VARCHAR2(30);
l_table_owner  VARCHAR2(30);
l_print_column_flag  BOOLEAN;

l_log_head     VARCHAR2(2000);

l_rowid_tbl    po_tbl_varchar2000;
l_rowid_csr    t_ref_csr;

BEGIN
-- TODO: Refactor this procedure.
-- It was copied from the PO_DEBUG.debug_table implementation,
-- and needs to be reworked a bit.
--
-- Ideas for refactoring:
-- Get the current schema via SYS_CONTEXT('USERENV','CURRENT_SCHEMA').
-- Use all_synonyms to find the base table / view.
-- (maybe just use user_synonyms, if login is always APPS, regardless of current_schema)
-- Use all_tab_columns to get column names.
--

IF d_stmt THEN

   l_printable_column_tbl := po_tbl_varchar30();
   l_value_rowid_tbl := po_tbl_varchar2000();
   l_value_tbl := t_tbl_varchar();

   l_table_name := UPPER(p_table_name);

  -- Use the refactoring ideas to get the real value for table_owner.
  l_table_owner := 'PO';

  l_log_head := p_module_base||TO_CHAR(p_position)|| '.DEBUG_TABLE.' || p_table_name||'.';

  stmt(l_log_head||'START',NULL,'Logging non-null columns only.  p_rowid_tbl.COUNT',p_rowid_tbl.COUNT);

   SELECT
      column_name
   ,  data_type
   BULK COLLECT INTO
      l_column_name_tbl
   ,  l_data_type_tbl
   FROM
      ALL_TAB_COLUMNS
   WHERE table_name = l_table_name
   AND owner = l_table_owner
   ORDER BY column_id
   ;

   IF (p_rowid_tbl.COUNT = 1 AND p_rowid_tbl(1) = c_all_rows(1)) THEN

      l_rowid_tbl := po_tbl_varchar2000();

      OPEN l_rowid_csr FOR 'SELECT rowid FROM '||l_table_name ;

      LOOP

         FETCH l_rowid_csr INTO l_char;
         EXIT WHEN l_rowid_csr%NOTFOUND;

         l_rowid_tbl.EXTEND;
         l_rowid_tbl(l_rowid_tbl.COUNT) := l_char;

      END LOOP;

      CLOSE l_rowid_csr;

   ELSE
      l_rowid_tbl := p_rowid_tbl;
   END IF;

   FOR i IN 1 .. l_column_name_tbl.COUNT LOOP

      IF (l_data_type_tbl(i) = 'NUMBER') THEN

         l_sql := 'TO_CHAR(' || l_column_name_tbl(i) || ')';

      ELSIF (l_data_type_tbl(i) = 'DATE') THEN

         l_sql := 'TO_CHAR(' || l_column_name_tbl(i) || ', ''DD-MON-RRRR HH:MI:SSAM'')';

      ELSIF (l_data_type_tbl(i) = 'VARCHAR2') THEN

         l_sql := l_column_name_tbl(i);

      END IF;

      IF (l_sql IS NULL AND p_column_name_tbl IS NULL) THEN

         stmt(l_log_head||'COLUMN',NULL,
            'Unprintable column: '|| l_column_name_tbl(i) || ' (' || l_data_type_tbl(i) || ')');

      ELSIF (l_sql IS NOT NULL) THEN

         IF (p_column_name_tbl IS NULL) THEN
            l_print_column_flag := TRUE;
         ELSE
            l_print_column_flag := FALSE;
            FOR j IN 1 .. p_column_name_tbl.COUNT LOOP
               IF (l_column_name_tbl(i) = UPPER(p_column_name_tbl(j))) THEN
                  l_print_column_flag := TRUE;
                  EXIT;
               END IF;
            END LOOP;
         END IF;

         IF l_print_column_flag THEN

            l_printable_column_tbl.EXTEND;
            l_printable_column_tbl(l_printable_column_tbl.COUNT) := l_column_name_tbl(i);

            l_sql := 'SELECT SUBSTR(' || l_sql || ',1,3900)'
                  ||' FROM ' || l_table_name
                  ||' WHERE rowid = :b_rowid';

            FOR j IN 1 .. l_rowid_tbl.COUNT LOOP

               BEGIN

                  EXECUTE IMMEDIATE l_sql INTO l_char USING l_rowid_tbl(j);

               EXCEPTION
                  WHEN OTHERS THEN
                     l_char := SQLERRM;
               END;

               l_value_rowid_tbl.EXTEND;
               l_value_rowid_tbl(l_value_rowid_tbl.COUNT) := l_rowid_tbl(j);

               l_value_tbl.EXTEND;
               l_value_tbl(l_value_tbl.COUNT) := l_char;

            END LOOP;

         END IF;

      END IF;

   END LOOP;


   -- Report input columns that don't exist / aren't printable.

   IF (p_column_name_tbl IS NOT NULL) THEN

      FOR i IN 1 .. p_column_name_tbl.COUNT LOOP

         l_print_column_flag := FALSE;

         FOR j IN 1 .. l_column_name_tbl.COUNT LOOP
            IF (UPPER(p_column_name_tbl(i)) = l_column_name_tbl(j)) THEN
               l_print_column_flag := TRUE;
               EXIT;
            END IF;
         END LOOP;

         IF (NOT l_print_column_flag) THEN
           stmt(l_log_head||'COLUMN',NULL,
               'Non-existent column: '|| p_column_name_tbl(i));
         ELSE

            l_print_column_flag := FALSE;

            FOR j IN 1 .. l_printable_column_tbl.COUNT LOOP
               IF (UPPER(p_column_name_tbl(i)) = l_printable_column_tbl(j)) THEN
                  l_print_column_flag := TRUE;
                  EXIT;
               END IF;
            END LOOP;

            IF (NOT l_print_column_flag) THEN
               stmt(l_log_head||'COLUMN',NULL,
                  'Unprintable column: '|| l_column_name_tbl(i) || ' (unprintable data type)');
            END IF;

         END IF;

      END LOOP;

   END IF;


   FOR i IN 1 .. l_rowid_tbl.COUNT LOOP

      l_col_i := 1;

      FOR j IN 1 .. l_value_rowid_tbl.COUNT LOOP

         IF (l_value_rowid_tbl(j) = l_rowid_tbl(i)) THEN

          IF (l_value_tbl(j) IS NOT NULL) THEN
            stmt(l_log_head||'ROW',NULL,
               l_rowid_tbl(i)||'.'||l_printable_column_tbl(l_col_i),
               l_value_tbl(j));
          END IF;

            l_col_i := l_col_i + 1;

         END IF;

      END LOOP;

   END LOOP;

END IF;

EXCEPTION
WHEN OTHERS THEN
  IF d_stmt THEN

    l_log_head := p_module_base||TO_CHAR(p_position)||'.DEBUG_TABLE.'||p_table_name||'.'||'EXCEPTION';

    stmt(l_log_head,NULL,SQLERRM);

    stmt(l_log_head,NULL,'p_rowid_tbl',p_rowid_tbl);
    stmt(l_log_head,NULL,'p_column_name_tbl',p_column_name_tbl);
    stmt(l_log_head,NULL,'l_table_owner',l_table_owner);
    stmt(l_log_head,NULL,'l_rowid_tbl',l_rowid_tbl);
    stmt(l_log_head,NULL,'l_column_name_tbl',l_column_name_tbl);
    stmt(l_log_head,NULL,'l_printable_column_tbl',l_printable_column_tbl);
    stmt(l_log_head,NULL,'l_sql',l_sql);
    stmt(l_log_head,NULL,'l_char',l_char);
    stmt(l_log_head,NULL,'l_table_name',l_table_name);
    stmt(l_log_head,NULL,'l_table_owner',l_table_owner);

  END IF;

END stmt_table;

-- PROCEDURE-level logging.

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_BEGIN,D_START_OF_SUBPROGRAM);
END proc_begin;

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  VARCHAR2
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_BEGIN,
  var_to_string(p_parameter_name,p_parameter_value));
END proc_begin;

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  NUMBER
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_BEGIN,
  var_to_string(p_parameter_name,p_parameter_value));
END proc_begin;

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  DATE
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_BEGIN,
  var_to_string(p_parameter_name,p_parameter_value));
END proc_begin;

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  BOOLEAN
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_BEGIN,
  var_to_string(p_parameter_name,p_parameter_value));
END proc_begin;

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_NUMBER
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_BEGIN,
  p_parameter_name,p_parameter_value);
END proc_begin;

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_DATE
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_BEGIN,
  p_parameter_name,p_parameter_value);
END proc_begin;

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR1
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_BEGIN,
  p_parameter_name,p_parameter_value);
END proc_begin;

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR5
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_BEGIN,
  p_parameter_name,p_parameter_value);
END proc_begin;

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR30
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_BEGIN,
  p_parameter_name,p_parameter_value);
END proc_begin;

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR100
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_BEGIN,
  p_parameter_name,p_parameter_value);
END proc_begin;

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR2000
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_BEGIN,
  p_parameter_name,p_parameter_value);
END proc_begin;

PROCEDURE proc_begin(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR4000
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_BEGIN,
  p_parameter_name,p_parameter_value);
END proc_begin;

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_END,D_END_OF_SUBPROGRAM);
END proc_end;

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  VARCHAR2
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_END,
  var_to_string(p_parameter_name,p_parameter_value));
END proc_end;

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  NUMBER
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_END,
  var_to_string(p_parameter_name,p_parameter_value));
END proc_end;

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  DATE
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_END,
  var_to_string(p_parameter_name,p_parameter_value));
END proc_end;

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  BOOLEAN
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_END,
  var_to_string(p_parameter_name,p_parameter_value));
END proc_end;

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_NUMBER
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_END,
  p_parameter_name,p_parameter_value);
END proc_end;

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_DATE
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_END,
  p_parameter_name,p_parameter_value);
END proc_end;

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR1
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_END,
  p_parameter_name,p_parameter_value);
END proc_end;

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR5
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_END,
  p_parameter_name,p_parameter_value);
END proc_end;

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR30
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_END,
  p_parameter_name,p_parameter_value);
END proc_end;

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR100
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_END,
  p_parameter_name,p_parameter_value);
END proc_end;

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR2000
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_END,
  p_parameter_name,p_parameter_value);
END proc_end;

PROCEDURE proc_end(
  p_module_base                   IN  VARCHAR2
, p_parameter_name                IN  VARCHAR2
, p_parameter_value               IN  PO_TBL_VARCHAR4000
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_END,
  p_parameter_name,p_parameter_value);
END proc_end;

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  VARCHAR2
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_RETURN,
  var_to_string(D_RETURN_VALUE,p_return_value));
END proc_return;

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  NUMBER
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_RETURN,
  var_to_string(D_RETURN_VALUE,p_return_value));
END proc_return;

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  DATE
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_RETURN,
  var_to_string(D_RETURN_VALUE,p_return_value));
END proc_return;

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  BOOLEAN
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_RETURN,
  var_to_string(D_RETURN_VALUE,p_return_value));
END proc_return;

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_NUMBER
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_RETURN,
  D_RETURN_VALUE,p_return_value);
END proc_return;

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_DATE
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_RETURN,
  D_RETURN_VALUE,p_return_value);
END proc_return;

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_VARCHAR1
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_RETURN,
  D_RETURN_VALUE,p_return_value);
END proc_return;

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_VARCHAR5
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_RETURN,
  D_RETURN_VALUE,p_return_value);
END proc_return;

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_VARCHAR30
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_RETURN,
  D_RETURN_VALUE,p_return_value);
END proc_return;

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_VARCHAR100
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_RETURN,
  D_RETURN_VALUE,p_return_value);
END proc_return;

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_VARCHAR2000
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_RETURN,
  D_RETURN_VALUE,p_return_value);
END proc_return;

PROCEDURE proc_return(
  p_module_base                   IN  VARCHAR2
, p_return_value                  IN  PO_TBL_VARCHAR4000
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_RETURN,
  D_RETURN_VALUE,p_return_value);
END proc_return;

PROCEDURE proc_raise(
  p_module_base                   IN  VARCHAR2
)
IS
BEGIN
log(FND_LOG.LEVEL_PROCEDURE,p_module_base,D_RAISE,
  'Raising exception: SQLERRM = '||SQLERRM);
END proc_raise;

-- EVENT-level logging.

PROCEDURE event(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_message_text                  IN  VARCHAR2
)
IS
BEGIN
log(FND_LOG.LEVEL_EVENT,p_module_base,TO_CHAR(p_position),p_message_text);
END event;

-- EXCEPTION-level logging.

PROCEDURE exc(
  p_module_base                   IN  VARCHAR2
, p_position                      IN  NUMBER
, p_message_text                  IN  VARCHAR2  DEFAULT NULL
)
IS
BEGIN
log(FND_LOG.LEVEL_EXCEPTION,p_module_base,TO_CHAR(p_position)||'.EXCEPTION',
  p_message_text||';SQLERRM = '||SQLERRM);
END exc;


-----------------------------------------------------------------------------
-- Package initialization.
-----------------------------------------------------------------------------

BEGIN

  refresh_log_flags();

END PO_LOG;

/
