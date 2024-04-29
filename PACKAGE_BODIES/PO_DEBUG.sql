--------------------------------------------------------
--  DDL for Package Body PO_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DEBUG" AS
-- $Header: POXDBUGB.pls 120.1 2005/06/29 19:29:55 shsiung noship $


/***************************************************************
 ***************************************************************

The logging routines in this package are obsolete.
They are replaced by routines in the PO_LOG package.

For more details on the PO logging strategy, see the document at
/podev/po/internal/standards/logging/logging.xml

 ***************************************************************
 ***************************************************************
 */

-----------------------------------------------------------------------------
-- Define public procedures.
-----------------------------------------------------------------------------



-- Obsolete.
-- See PO_LOG.
FUNCTION is_debug_stmt_on
RETURN BOOLEAN
IS
BEGIN

RETURN(PO_LOG.d_stmt);

END is_debug_stmt_on;


-- Obsolete.
-- See PO_LOG.
FUNCTION is_debug_unexp_on
RETURN BOOLEAN
IS
BEGIN

RETURN(PO_LOG.d_unexp);

END is_debug_unexp_on;




-- Obsolete.
-- See PO_LOG.
PROCEDURE debug_stmt(
   p_log_head                       IN             VARCHAR2
,  p_token                          IN             VARCHAR2
,  p_message                        IN             VARCHAR2
)
IS
BEGIN
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(p_log_head||'.'||p_token,NULL,p_message);
END IF;
END debug_stmt;



-- Obsolete.
-- See PO_LOG.
PROCEDURE debug_begin(
   p_log_head                       IN             VARCHAR2
)
IS
BEGIN
IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(p_log_head||'.');
END IF;
END debug_begin;


-- Obsolete.
-- See PO_LOG.
PROCEDURE debug_end(
   p_log_head                       IN             VARCHAR2
)
IS
BEGIN
IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(p_log_head||'.');
END IF;
END debug_end;



-- Obsolete.
-- See PO_LOG.
PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             VARCHAR2
)
IS
BEGIN
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(p_log_head||'.'||p_progress,NULL,p_name,p_value);
END IF;
END debug_var;




PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             NUMBER
)
IS
BEGIN
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(p_log_head||'.'||p_progress,NULL,p_name,p_value);
END IF;
END debug_var;




PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             DATE
)
IS
BEGIN
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(p_log_head||'.'||p_progress,NULL,p_name,p_value);
END IF;
END debug_var;




PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             BOOLEAN
)
IS
BEGIN
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(p_log_head||'.'||p_progress,NULL,p_name,p_value);
END IF;
END debug_var;




PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             po_tbl_number
)
IS
BEGIN
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(p_log_head||'.'||p_progress,NULL,p_name,p_value);
END IF;
END debug_var;




PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             po_tbl_date
)
IS
BEGIN
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(p_log_head||'.'||p_progress,NULL,p_name,p_value);
END IF;
END debug_var;




PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             po_tbl_varchar1
)
IS
BEGIN
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(p_log_head||'.'||p_progress,NULL,p_name,p_value);
END IF;
END debug_var;




PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             po_tbl_varchar5
)
IS
BEGIN
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(p_log_head||'.'||p_progress,NULL,p_name,p_value);
END IF;
END debug_var;




PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             po_tbl_varchar30
)
IS
BEGIN
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(p_log_head||'.'||p_progress,NULL,p_name,p_value);
END IF;
END debug_var;




PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             po_tbl_varchar100
)
IS
BEGIN
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(p_log_head||'.'||p_progress,NULL,p_name,p_value);
END IF;
END debug_var;




PROCEDURE debug_var(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_name                           IN             VARCHAR2
,  p_value                          IN             po_tbl_varchar2000
)
IS
BEGIN
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(p_log_head||'.'||p_progress,NULL,p_name,p_value);
END IF;
END debug_var;




-- Obsolete.
-- See PO_LOG.
PROCEDURE debug_exc(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
)
IS
BEGIN
IF PO_LOG.d_exc THEN
  PO_LOG.exc(p_log_head||'.'||p_progress,NULL,NULL);
END IF;
END debug_exc;



-- Obsolete.
-- See PO_LOG.
PROCEDURE debug_err(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
)
IS
BEGIN
IF PO_LOG.d_exc THEN
  PO_LOG.exc(p_log_head||'.'||p_progress,NULL,NULL);
END IF;
END debug_err;




-- Obsolete.
-- See PO_LOG.
PROCEDURE debug_unexp(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_message                        IN             VARCHAR2
      DEFAULT NULL
)
IS
BEGIN
IF PO_LOG.d_exc THEN
  PO_LOG.exc(p_log_head||'.'||p_progress,NULL,p_message);
END IF;

EXCEPTION
WHEN OTHERS THEN
   NULL;

END debug_unexp;




-- Obsolete.
-- See PO_LOG.
PROCEDURE debug_table(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_table_name                     IN             VARCHAR2
,  p_rowid_tbl                      IN             po_tbl_varchar2000
,  p_column_name_tbl                IN             po_tbl_varchar30
      DEFAULT NULL
,  p_table_owner                    IN             VARCHAR2
      DEFAULT NULL
)
IS
BEGIN
PO_LOG.stmt_table(p_log_head||'.'||p_progress,NULL,
  p_table_name,p_rowid_tbl,p_column_name_tbl);
END debug_table;




-- Obsolete.
-- See PO_LOG.
PROCEDURE debug_session_gt(
   p_log_head                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  p_key                            IN             NUMBER
,  p_column_name_tbl                IN             po_tbl_varchar30
      DEFAULT NULL
)
IS
BEGIN
PO_LOG.stmt_session_gt(p_log_head||'.'||p_progress,NULL,
  p_key,p_column_name_tbl);
END debug_session_gt;




-------------------------------------------------------------------------------
--Start of Comments
--Name: handle_unexp_error
--Pre-reqs:
--  None.
--Modifies:
--  API message list
--  FND_LOG_MESSAGES
--Locks:
--  None.
--Function:
--  Adds an exception message to the standard API message list
--  and to the FND log, when appropriate.
--Parameters:
--IN:
--p_pkg_name
--  Name of the PL/SQL package that encountered the error.
--p_proc_name
--  Name of the PL/SQL procedure that encountered the error.
--p_progress
--  Label indicating the location within the procedure.
--p_add_to_msg_list
--  Indicates whether or not an exception message should be added
--  to the API message list.
--    TRUE  -  add a message to the list
--    FALSE -  don't add a message to the list
--    NULL  -  use FND standard routines to determine whether or not
--                to add a message to the list
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE handle_unexp_error(
   p_pkg_name                       IN             VARCHAR2
,  p_proc_name                      IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
      DEFAULT NULL
,  p_add_to_msg_list                IN             BOOLEAN
      DEFAULT NULL
)
IS

l_add_to_msg_list    BOOLEAN := p_add_to_msg_list;

BEGIN

IF (l_add_to_msg_list IS NULL) THEN
   l_add_to_msg_list :=
      FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR);
END IF;

-- Add the unexpected error to the standard API message list.
IF l_add_to_msg_list THEN
   FND_MSG_PUB.add_exc_msg(
      p_pkg_name        => p_pkg_name
   ,  p_procedure_name  => p_proc_name
   );
END IF;

-- Log a debug message.
IF PO_LOG.d_unexp THEN
   debug_unexp(
      p_log_head => 'po.plsql.'||UPPER(p_pkg_name)||'.'||UPPER(p_proc_name)
   ,  p_progress => p_progress
   );
END IF;

EXCEPTION
WHEN OTHERS THEN
   NULL;

END handle_unexp_error;

-- Bug 3570793 START
-------------------------------------------------------------------------------
--Start of Comments
--Name: write_msg_list_to_file
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG_MESSAGES
--Locks:
--  None.
--Function:
--  Writes the messages on the API message list (FND_MSG_PUB) to the concurrent
--  program log file output, and to the FND log, if enabled.
--Parameters:
--IN:
--p_log_head
--  Module value to pass to FND_LOG, indicating the package, procedure, etc.
--p_progress
--  Label indicating the location within the procedure.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE write_msg_list_to_file (
  p_log_head                        IN             VARCHAR2
, p_progress                        IN             VARCHAR2
) IS
  l_msg VARCHAR2(2000);
  l_module VARCHAR2(200);
BEGIN
  l_module := p_log_head || '.' || p_progress;

  FOR i IN 1..FND_MSG_PUB.count_msg LOOP
    l_msg := substrb ( FND_MSG_PUB.get(p_msg_index => i,
                                       p_encoded   => FND_API.G_FALSE),
                       1, 2000 );

    -- Write the message to the concurrent program log file.
    FND_FILE.put_line ( FND_FILE.LOG,
                        substrb(l_module || ': ' || l_msg, 1, 2000) );

    -- Write the message to the FND log, if enabled.
    IF PO_LOG.d_unexp THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string ( log_level => FND_LOG.level_unexpected,
                       module    => l_module,
                       message   => l_msg );
      END IF;
    END IF;
  END LOOP;

EXCEPTION
WHEN OTHERS THEN
  NULL; -- ignore any exceptions
END write_msg_list_to_file;
-- Bug 3570793 END

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 8/20/03: The following procedures are non-standard comformant,
--          and should not be used.
--          They exist for legacy code.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


/*=========================================================================

  PROCEDURE NAME:	PUT_LINE()

===========================================================================*/

-- Write debug messages to file or standard out based on the value of package
-- variable PO_DEBUG.write_to_file.
--
-- Use PO_DEBUG.set_file_io( TRUE / FALSE ) to set this variable.

PROCEDURE PUT_LINE (v_line in varchar2) IS

x_temp varchar2(10) := 'NULL';

BEGIN

    if PO_DEBUG.write_to_file is NULL then

	-- Do nothing.
	null;

    elsif PO_DEBUG.write_to_file then

	-- write to system log file
      	-- Assuming all the rules for utl_file have been properly followed
      	-- the following call should write to a system generated log file.

	x_temp := 'FILE';
	FND_FILE.PUT_LINE(FND_FILE.LOG, v_line);

    else

	-- write to standard out
	x_temp := 'STD OUT';
    	--dbms_output.put_line(v_line);

    end if;

EXCEPTION

    when others then
	-- do not raise any exception
    	--dbms_output.put_line('***  ERROR WRITING TO FILE - Check UTL_FILE_DIR Parameter in init.ora *** : ' || x_temp);
	PO_DEBUG.write_to_file := NULL;	 -- Reset the file I/O flag so that the package is not invoked again
					 -- May run into rollback problems if the FND_FILE package is called again
					 -- because it performs an implicit commit.

END PUT_LINE;

-- Set flag for writing to file or standard out

PROCEDURE set_file_io(flag BOOLEAN) IS

BEGIN

    PO_DEBUG.write_to_file := flag;

/* Bug 1014430 : dbms_output should be enabled conditionally only if the
                      flag is false.
*/

   if (flag or flag is null) then
       dbms_output.disable;
   else
       dbms_output.enable(1000000);
   end if;

   EXCEPTION
	when others then null;

END set_file_io;




END PO_DEBUG;

/
