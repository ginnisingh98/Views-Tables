--------------------------------------------------------
--  DDL for Package Body HR_DU_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DU_UTILITY" AS
/* $Header: perdutil.pkb 115.6 2002/11/28 17:05:05 apholt noship $ */

/*--------------------------- GLOBAL VARIABLES ----------------------------*/

-- message globals
-- start

g_debug_message_log VARCHAR2(50);
g_debug_message_indent NUMBER;
g_debug_message_indent_size NUMBER := 2;

-- message globals
-- end

/*----------------------------------------------------------------------------*/


-- 11i / 11.0 specific code
-- start

-- ------------------------- local_chr ------------------------
-- Description: In 11i fnd_global.local_CHR(i) will return the local
-- equivelent of the ASCII character. This does not exit pre 11i.
--
--
--  Input Parameters
--        p_char_code     - character code to convert
--
--
--  Output Parameters
--                        - converted character
--
-- ------------------------------------------------------------------------

FUNCTION local_chr(p_char_code IN NUMBER) RETURN VARCHAR2 IS

l_char VARCHAR2(30);

--
BEGIN
--

-- uncomment appropriate version

-- 11i version
l_char := fnd_global.local_chr(p_char_code);

-- pre 11i version
-- l_char := CHR(p_char_code);


RETURN(l_char);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_du_utility.local_chr','(none)','R');
  RAISE;

--
END local_chr;
--

-- ------------------------- dynamic_sql ------------------------
-- Description: Perform dynamic SQL which returns no value
--
-- 11i 		- use EXECUTE IMMEDIATE
--
-- pre 11i	- use dmb_sql package
--
--  Input Parameters
--        p_string     - string to execute
--
--
--  Output Parameters
--                        - none
--
-- ------------------------------------------------------------------------

PROCEDURE dynamic_sql(p_string IN VARCHAR2) IS

-- pre 11i version
/*
l_cursor_handle		INT;
l_rows_processed	INT;
*/

--
BEGIN
--
message('PARA','(p_string - ' || p_string || ')', 10);

-- uncomment appropriate version

-- 11i version
EXECUTE IMMEDIATE p_string;

-- pre 11i version
/*
l_cursor_handle := dbms_sql.open_cursor;
dbms_sql.parse(l_cursor_handle,  p_string, dbms_sql.native);
l_rows_processed := dbms_sql.execute(l_cursor_handle);
dbms_sql.close_cursor(l_cursor_handle);
*/

message('INFO','Executed dynamic sql', 15);
message('SUMM','Executed dynamic sql', 20);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_du_utility.dynamic_sql','(none)','R');
  RAISE;

--
END dynamic_sql;
--

-- ------------------------- dynamic_sql_num ------------------------
-- Description: Perform dynamic SQL which returns a number
--
-- 11i 		- use EXECUTE IMMEDIATE
--
-- pre 11i	- use dmb_sql package
--
--
--  Input Parameters
--        p_string       - string to execute
-- 	  p_return_value - variable for return value
--
--
-- ------------------------------------------------------------------------

PROCEDURE dynamic_sql_num(p_string IN VARCHAR2,
                          p_return_value IN OUT NOCOPY NUMBER) IS


-- pre 11i version
/*
l_cursor_handle		INT;
l_rows_processed	INT;
*/

--
BEGIN
--

message('PARA','(p_string - ' || p_string ||
               ')(p_return_value - ' || p_return_value || ')', 10);


-- uncomment appropriate version

-- 11i version
EXECUTE IMMEDIATE p_string INTO p_return_value;

-- pre 11i version
/*
l_cursor_handle := dbms_sql.open_cursor;
dbms_sql.parse(l_cursor_handle,  p_string, DBMS_SQL.v7);
dbms_sql.define_column(l_cursor_handle, 1, p_return_value);
l_rows_processed := dbms_sql.execute(l_cursor_handle);

if dbms_sql.fetch_rows(l_cursor_handle) > 0  then
  dbms_sql.column_value(l_cursor_handle, 1, p_return_value);
end if;

dbms_sql.close_cursor(l_cursor_handle);
*/


message('INFO','p_return_value - ' || p_return_value, 12);


message('INFO','Executed dynamic sql', 15);
message('SUMM','Executed dynamic sql', 20);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_du_utility.dynamic_sql_num','(none)','R');
  RAISE;

--
END dynamic_sql_num;
--


-- ----------------------- DYNAMIC_SQL_NUM_USER_KEY -----------------------
-- Description: Perform dynamic SQL which returns a number. If the SQL
-- statement fails then there isn't a valid id that exists and a cursor
-- is run to give an error message
--
-- 11i 		- use EXECUTE IMMEDIATE
--
-- pre 11i	- use dmb_sql package
--
--
--  Input Parameters
--        p_string        - string to execute
--        p_api_module_id - Identifies the API
-- 	  p_return_value  - variable for return value
--        p_column_id     - Identifies the column in the flat file
--
--
-- ------------------------------------------------------------------------

PROCEDURE dynamic_sql_num_user_key(
                          p_string IN VARCHAR2,
		          p_api_module_id IN NUMBER,
        		  p_column_id IN NUMBER,
                          p_return_value IN OUT NOCOPY NUMBER) IS

CURSOR csr_module_name IS
  SELECT module_name
  FROM hr_api_modules
  WHERE api_module_id = p_api_module_id;


  l_api_module_name	VARCHAR2(200);

-- pre 11i version
/*
l_cursor_handle		INT;
l_rows_processed	INT;
*/

--
BEGIN
--

message('ROUT','(p_string - ' || p_string ||
               ')(p_return_value - ' || p_return_value || ')', 10);


-- uncomment appropriate version

-- 11i version
EXECUTE IMMEDIATE p_string INTO p_return_value;

-- pre 11i version
/*
l_cursor_handle := dbms_sql.open_cursor;
dbms_sql.parse(l_cursor_handle,  p_string, DBMS_SQL.v7);
dbms_sql.define_column(l_cursor_handle, 1, p_return_value);
l_rows_processed := dbms_sql.execute(l_cursor_handle);

if dbms_sql.fetch_rows(l_cursor_handle) > 0  then
  dbms_sql.column_value(l_cursor_handle, 1, p_return_value);
end if;

dbms_sql.close_cursor(l_cursor_handle);
*/


message('INFO','p_return_value - ' || p_return_value, 12);


message('INFO','Executed dynamic sql', 15);
message('SUMM','Executed dynamic sql', 20);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  --
  OPEN csr_module_name;
  --
    FETCH csr_module_name INTO l_api_module_name;
  --
  CLOSE csr_module_name;
  --
  error(SQLCODE,'hr_du_utility.dynamic_sql_num_user_key',' Unable to fine ID '
        || p_column_id || ' in API ' || l_api_module_name || '. Referencing '
        || 'column in other file has this invalid reference. ' ,'R');
  RAISE;

--
END DYNAMIC_SQL_NUM_USER_KEY;
--

-- ------------------------- dynamic_sql_str ------------------------
-- Description: Perform dynamic SQL which returns a string
--
-- 11i 		- use EXECUTE IMMEDIATE
--
-- pre 11i	- use dmb_sql package
--
--
--  Input Parameters
--        p_string        - string to execute
-- 	  p_return_value  - variable for return value
--        p_string_length - max size of return value
--
-- ------------------------------------------------------------------------

PROCEDURE dynamic_sql_str(p_string IN VARCHAR2,
                          p_return_value IN OUT NOCOPY VARCHAR2,
                          p_string_length IN NUMBER) IS


-- pre 11i version
/*
l_cursor_handle		INT;
l_rows_processed	INT;
*/

--
BEGIN
--

message('PARA','(p_string - ' || p_string ||
               ')(p_return_value - ' || p_return_value ||
               ')(p_string_length - ' || p_string_length || ')', 10);


-- uncomment appropriate version

-- 11i version
EXECUTE IMMEDIATE p_string INTO p_return_value;

-- pre 11i version
/*
l_cursor_handle := dbms_sql.open_cursor;
dbms_sql.parse(l_cursor_handle,  p_string, DBMS_SQL.v7);
dbms_sql.define_column(l_cursor_handle, 1, p_return_value, p_string_length);
l_rows_processed := dbms_sql.execute(l_cursor_handle);

if dbms_sql.fetch_rows(l_cursor_handle) > 0  then
  dbms_sql.column_value(l_cursor_handle, 1, p_return_value);
end if;

dbms_sql.close_cursor(l_cursor_handle);

*/

message('INFO','p_return_value - ' || p_return_value, 12);

message('INFO','Executed dynamic sql', 15);
message('SUMM','Executed dynamic sql', 20);
message('PARA','(none)', 30);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_du_utility.dynamic_sql_str','(none)','R');
  RAISE;

--
END dynamic_sql_str;
--



-- 11i / 11.0 specific code
-- end




--
PROCEDURE error (p_sqlcode IN NUMBER, p_procedure IN VARCHAR2,
                 p_extra IN VARCHAR2, p_rollback IN VARCHAR2 DEFAULT 'R') IS
--
--
BEGIN
--

message('ROUT','entry:hr_du_utility.error', 5);
message('PARA','(p_sqlcode - ' || p_sqlcode ||
               ')(p_procedure - ' || p_procedure || ')', 10);

message('FAIL',p_sqlcode || ':' || SQLERRM(p_sqlcode) || ':'
                   || p_extra, 15);

IF (p_rollback = 'R') THEN
  ROLLBACK;
END IF;
IF (p_rollback = 'C') THEN
  COMMIT;
END IF;

message('INFO','Error Handler - ' || p_procedure, 20);
message('SUMM','Error Handler - ' || p_procedure, 25);
message('ROUT','exit:hr_du_utility.error', 30);
message('PARA','(none)', 35);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_du_utility.error','(none)','R');
  RAISE;


--
END error;
--

-- error procedures
-- end

/*-------------------------------------------------------------------------------------------------------*/

PROCEDURE message_init IS
--

CURSOR csr_c2 IS
  SELECT parameter_value
    FROM pay_action_parameters
    WHERE parameter_name = 'HR_DU_DEBUG_LOG';
--
BEGIN
--

-- read values from pay_action_parameters

OPEN csr_c2;
LOOP
  FETCH csr_c2 INTO g_debug_message_log;
  EXIT WHEN csr_c2%NOTFOUND;
END LOOP;
CLOSE csr_c2;

-- ensure that summary and fail settings are set

IF ((INSTR(g_debug_message_log, 'SUMM') IS NULL) OR
    (INSTR(g_debug_message_log, 'SUMM') = 0)) THEN
  g_debug_message_log := g_debug_message_log || ':SUMM';
END IF;

IF ((INSTR(g_debug_message_log, 'FAIL') IS NULL) OR
    (INSTR(g_debug_message_log, 'FAIL') = 0)) THEN
  g_debug_message_log := g_debug_message_log || ':FAIL';
END IF;

-- start the indenting to zero indentation
g_debug_message_indent := 0;

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_du_utility.message_init','(none)','R');
  RAISE;

--
END message_init;
--



-- ------------------------- message ------------------------
-- Description: Logs the message to the log file and / or the
-- pipe for the options that have been configured by calling message_init.
--
--
--  Input Parameters
--        p_type     - message type
--
--        p_message  - text of message
--
--        p_position - position value for piped messages
--
--
--  Output Parameters
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE message (p_type IN VARCHAR2, p_message IN VARCHAR2,
                   p_position IN NUMBER) IS
--

l_header VARCHAR2(30);
l_message VARCHAR2(32767);

--
BEGIN
--

  l_message := p_message;

  l_header := p_type || ':' || TO_CHAR(sysdate,'HH24MISS');
--  hr_utility.trace( l_header || ':-:' || '     ' || l_message);



IF (INSTR(g_debug_message_log, p_type) <> 0) THEN
  l_message := p_message;
  IF (p_type <> 'ROUT') THEN
    l_message := '     ' || l_message;
  END IF;

-- for ROUT entry messages change indent
-- decrease for exit messages
  IF (p_type = 'ROUT') AND (substr(p_message,1,5) = 'exit:') THEN
    g_debug_message_indent := g_debug_message_indent -
                              g_debug_message_indent_size;
  END IF;


-- indent all messages to show nesting of functions
  l_message := rpad(' ', g_debug_message_indent) || l_message;

-- for ROUT entry messages change indent
-- increase for entry messages
  IF (p_type = 'ROUT') AND (substr(p_message,1,6) = 'entry:') THEN
    g_debug_message_indent := g_debug_message_indent +
                              g_debug_message_indent_size;
  END IF;

-- build header
  l_header := p_type || ':' || TO_CHAR(sysdate,'HH24MISS');

  FND_FILE.PUT_LINE(FND_FILE.LOG, l_header || ':-:' || l_message);
END IF;

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_du_utility.message','(none)','R');
  RAISE;

--
END message;
--
-- message procedures
-- end



-- ------------------------- get_uploads_status ------------------------
-- Description: Reads the status of the passed phase from the hr_du_uploads
-- table.
--
--  Input Parameters
--        p_upload_id 	 - upload id of current uploads
--
--  Output Parameters
--        <none>
--
--  Return Value
--        status of phase
--
-- ------------------------------------------------------------------------
--
FUNCTION get_uploads_status(p_upload_id IN NUMBER)
         RETURN VARCHAR2 IS
--

l_phase_status VARCHAR2(30);

CURSOR csr_status IS
  SELECT status
    FROM hr_du_uploads
    WHERE (upload_id = p_upload_id);

--
BEGIN
--

message('ROUT','entry:hr_du_utility.get_uploads_status', 5);
message('PARA','(p_upload_id - ' || p_upload_id || ')', 10);

OPEN csr_status;
LOOP
  FETCH csr_status INTO l_phase_status;
  EXIT when csr_status%NOTFOUND;
END LOOP;
CLOSE csr_status;

-- use a ? to represent a null value being returned
l_phase_status := NVL(l_phase_status, '?');


message('INFO','Find Phase Status', 15);
message('SUMM','Find Phase Status', 20);
message('ROUT','exit:hr_du_utility.get_phase_status', 25);
message('PARA','(l_phase_status - ' || l_phase_status || ')', 30);

RETURN(l_phase_status);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_du_utility.get_uploads_status','(none)','R');
  RAISE;

--
END get_uploads_status;
--


-- ------------------------- get_upload_headers_status ------------------------
-- Description: Reads the status of the passed phase from the hr_du_upload_headers
-- table.
--
--
--  Input Parameters
--        p_upload_header_id 	- upload_headers_id of current upload header
--
--
--  Output Parameters
--        <none>
--
--
--  Return Value
--        status of phase
--
--
-- ------------------------------------------------------------------------

--
FUNCTION get_upload_headers_status(p_upload_header_id IN NUMBER)
         RETURN VARCHAR2 IS
--

l_phase_status VARCHAR2(30);

CURSOR csr_status IS
  SELECT status
    FROM hr_du_upload_headers
    WHERE (upload_header_id = p_upload_header_id);

--
BEGIN
--

message('ROUT','entry:hr_du_utility.get_upload_headers_status', 5);
message('PARA','(p_upload_header_id - ' || p_upload_header_id || ')', 10);

OPEN csr_status;
LOOP
  FETCH csr_status INTO l_phase_status;
  EXIT when csr_status%NOTFOUND;
END LOOP;
CLOSE csr_status;

-- use a ? to represent a null value being returned
l_phase_status := NVL(l_phase_status, '?');


message('INFO','Find Phase Status', 15);
message('SUMM','Find Phase Status', 20);
message('ROUT','exit:hr_du_utility.get_upload_headers_status', 25);
message('PARA','(l_phase_status - ' || l_phase_status || ')', 30);

RETURN(l_phase_status);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_du_utility.get_upload_headers_status','(none)','R');
  RAISE;

--
END get_upload_headers_status;


-- ------------------------- get_upload_lines_status ------------------------
-- Description: Reads the status of the passed phase from the hr_du_upload_lines
-- table.
--
--
--  Input Parameters
--        p_upload_lines_id - upload_line_id of current upload_line
--
--  Output Parameters
--        <none>
--
--  Return Value
--        status of phase
--
-- ------------------------------------------------------------------------

--
FUNCTION get_upload_lines_status(p_upload_lines_id IN NUMBER)
         RETURN VARCHAR2 IS
--

l_phase_status VARCHAR2(30);

CURSOR csr_status IS
  SELECT status
    FROM hr_du_upload_lines
    WHERE (upload_line_id = p_upload_lines_id);

--
BEGIN
--

message('ROUT','entry:hr_du_utility.get_upload_lines_status', 5);
message('PARA','(p_upload_lines_id - ' || p_upload_lines_id || ')', 10);

OPEN csr_status;
LOOP
  FETCH csr_status INTO l_phase_status;
  EXIT when csr_status%NOTFOUND;
END LOOP;
CLOSE csr_status;

-- use a ? to represent a null value being returned
l_phase_status := NVL(l_phase_status, '?');


message('INFO','Find Phase Status', 15);
message('SUMM','Find Phase Status', 20);
message('ROUT','exit:hr_du_utility.get_upload_lines_status', 25);
message('PARA','(l_phase_status - ' || l_phase_status || ')', 30);

RETURN(l_phase_status);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_du_utility.get_upload_lines_status','(none)','R');
  RAISE;

--
END get_upload_lines_status;


-- update status procedures
-- start

-- ------------------------- update_uploads ------------------------
-- Description: Updates the status of the uploads in the hr_du_uploads
-- table. If the status is to be set to C then all child entries in
-- hr_du_headers are checked to ensure that they have completed.
--
--  Input Parameters
--        p_new_status - new status code
--
--        p_id         - uploads id
--
--  Output Parameters
--        <none>
--
-- ------------------------------------------------------------------------

--
PROCEDURE update_uploads (p_new_status IN VARCHAR2, p_id IN NUMBER) IS
--
-- table is hr_du_uploads
-- parent of hr_du_upload_headers
-- child of (none)

l_complete VARCHAR2(30);

-- search child table for all complete
CURSOR csr_child_table_complete IS
  SELECT status
    FROM hr_du_upload_headers
    WHERE ((upload_id = p_id)
      AND (status <> 'C'));

--
BEGIN
--
message('ROUT','entry:hr_du_utility.update_uploads', 5);
message('PARA','(p_new_status - ' || p_new_status ||
                  ')(p_id - ' || p_id || ')', 10);

-- non-complete
IF (p_new_status IN('S', 'NS', 'E')) THEN
-- update the status for this row
  UPDATE hr_du_uploads
  SET status = p_new_status
  WHERE upload_id = p_id;
  COMMIT;
END IF;

-- complete
IF (p_new_status = 'C') THEN
-- check if really complete
-- are any child rows not complete?
  OPEN csr_child_table_complete;
  FETCH csr_child_table_complete INTO l_complete;

  IF (csr_child_table_complete%NOTFOUND) THEN
-- update the status for this row since no child rows
-- are incomplete
    UPDATE hr_du_uploads
    SET status = p_new_status
    WHERE upload_id = p_id;
    COMMIT;
  END IF;
  CLOSE csr_child_table_complete;
END IF;

message('INFO','Update status - update_uploads', 15);
message('SUMM','Update status - update_uploads', 20);
message('ROUT','exit:hr_du_utility.update_uploads', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_du_utility.update_uploads','(none)','R');
  RAISE;

--
END update_uploads;
--


-- ------------------------- update_upload_lines ----------------------
-- Description: Updates the status of the upload lines in the
-- hr_du_upload_lines table. If the status is to be set to C or E then
-- the update status is cascaded up to the parent phase.
--
--
--  Input Parameters
--        p_new_status - new status code
--
--        p_id         - upload_line_id
--
--  Output Parameters
--        <none>
--
-- ------------------------------------------------------------------------

--
PROCEDURE update_upload_lines (p_new_status IN VARCHAR2, p_id IN NUMBER) IS
--
-- table is hr_du_upload_lines
-- parent of n/a
-- child of hr_du_upload_headers

l_parent_table_id NUMBER(9);

-- find parent table id
CURSOR csr_parent_id IS
  SELECT upload_header_id
    FROM hr_du_upload_lines
    WHERE upload_line_id = p_id;

--
BEGIN
--

message('ROUT','entry:hr_du_utility.update_upload_lines', 5);
message('PARA','(p_new_status - ' || p_new_status ||
                  ')(p_id - ' || p_id || ')', 10);

-- update the status for this row
UPDATE hr_du_upload_lines
  SET status = p_new_status
  WHERE upload_line_id = p_id;
COMMIT;

-- update parent?
IF (p_new_status IN('C', 'E')) THEN
  OPEN csr_parent_id;
  FETCH csr_parent_id INTO l_parent_table_id;
  CLOSE csr_parent_id;
  update_upload_headers(p_new_status,l_parent_table_id);
END IF;

message('INFO','Update status - update_upload_lines', 15);
message('SUMM','Update status - update_upload_lines', 20);
message('ROUT','exit:hr_du_utility.update_upload_lines', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_du_utility.update_upload_lines','(none)','R');
  RAISE;

--
END update_upload_lines;
--

-- ------------------------- update_upload_headers ----------------------
-- Description: Updates the status of the upload header in the
-- hr_du_upload_headers table. If the status is to be set to C or E then
-- the update status is cascaded up to the parent phase. For a C,
-- the status of all the child rows in the hr_du_upload_lines are
-- checked.
--
--
--  Input Parameters
--        p_new_status - new status code
--
--        p_id         - upload header id
--
--  Output Parameters
--        <none>
--
-- ------------------------------------------------------------------------

--
PROCEDURE update_upload_headers (p_new_status IN VARCHAR2, p_id IN NUMBER) IS
--
-- table is hr_du_upload_headers
-- parent of hr_du_upload_lines
-- child of hr_du_uploads

l_parent_table_id NUMBER(9);
l_complete VARCHAR2(30);
l_new_status VARCHAR2(30);

-- search child table for all complete
CURSOR csr_child_table_complete IS
  SELECT status
    FROM hr_du_upload_lines
    WHERE ((upload_header_id = p_id)
      AND (status <> 'C'));

-- find parent table id
CURSOR csr_parent_id IS
  SELECT upload_id
    FROM hr_du_upload_headers
    WHERE upload_header_id = p_id;

--
BEGIN
--

message('ROUT','entry:hr_du_utility.update_upload_headers', 5);
message('PARA','(p_new_status - ' || p_new_status ||
                  ')(p_id - ' || p_id || ')', 10);

l_new_status := p_new_status;

-- non-complete
IF (l_new_status IN('S', 'NS', 'E')) THEN
-- update the status for this row
  UPDATE hr_du_upload_headers
  SET status = l_new_status
  WHERE upload_header_id = p_id;
  COMMIT;
END IF;

-- complete
IF (l_new_status = 'C') THEN
-- check if really complete
-- are any child rows not complete?
  OPEN csr_child_table_complete;
  FETCH csr_child_table_complete INTO l_complete;

  IF (csr_child_table_complete%NOTFOUND) THEN
-- update the status for this row since no child rows
-- are incomplete
    UPDATE hr_du_upload_headers
    SET status = l_new_status
    WHERE upload_header_id = p_id;
    COMMIT;
  ELSE
-- unset status to preven cascade
    l_new_status := 'c';
  END IF;
  CLOSE csr_child_table_complete;
END IF;

-- update parent?
IF (l_new_status IN('C', 'E')) THEN
  OPEN csr_parent_id;
  FETCH csr_parent_id INTO l_parent_table_id;
  CLOSE csr_parent_id;
  update_uploads(l_new_status,l_parent_table_id);
END IF;


message('INFO','Update status - update_upload_headers', 15);
message('SUMM','Update status - update_upload_headers', 20);
message('ROUT','exit:hr_dm_utility.update_upload_headers', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.update_upload_headers','(none)','R');
  RAISE;

--
END update_upload_headers;
--

-- update status procedures
-- end



-- ------------------------- Return_Spreadsheet_row  ------------------------
-- Description: Takes in a number and returns the corresponding row letters
-- to point at the correct row cell in the spreadsheet
--
--  Input Parameters
--        p_upload_header_id 	- upload_headers_id of current upload header
--
--  Return Value
--        status of phase
--
--
-- ------------------------------------------------------------------------

--
FUNCTION Return_Spreadsheet_row(p_row_number IN NUMBER) RETURN VARCHAR2
IS
--

l_ASCII_1 	VARCHAR2(10)	:=null;
l_ASCII_2 	VARCHAR2(10)	:=null;
l_return 	VARCHAR2(10)	:=null;
l_divide	NUMBER;
l_mod		NUMBER;

BEGIN
--
  l_divide := TRUNC(p_row_number / 26);
  l_mod := p_row_number MOD 26;

--Statement catches the boundary values
  IF l_mod = 0  AND l_divide > 0 THEN
    l_mod := l_mod + 26;
    l_divide := l_divide - 1;
  END IF;

--Statement builds up the string to be glued together
  IF l_divide = 0 THEN
    l_ASCII_1 := ' ';
  ELSE
    l_divide := l_divide + 64;
    l_ASCII_1 := local_CHR(l_divide);
  END IF;

--
  IF l_mod = 0 THEN
    l_ASCII_2 := ' ';
  ELSE
    l_mod := l_mod + 64;
    l_ASCII_2 := local_CHR(l_mod);
  END IF;

--
  l_return := l_ASCII_1 || l_ASCII_2;
  RETURN l_return;


EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_utility.return_spreadsheet_row','(none)', 'R');
    RAISE;
--

END Return_Spreadsheet_row;


-- --------------------------- chunk_size ---------------------------------
-- Description: Finds the chunk size to use for the various phases
-- to use by looking at pay_action_parameters which is striped by business
-- group id.
--
--  Return Value
--        chunk_size
--
--------------------------------------------------------------------------
FUNCTION chunk_size RETURN NUMBER IS
--

l_chunk_size NUMBER;

CURSOR csr_chunk_size IS
  SELECT PARAMETER_VALUE
    FROM pay_action_parameters
    WHERE PARAMETER_NAME = 'CHUNK_SIZE';

--
BEGIN
--
  message('ROUT','entry:hr_du_utility.chunk_size', 5);

  OPEN csr_chunk_size;
    FETCH csr_chunk_size INTO l_chunk_size;
    IF csr_chunk_size%NOTFOUND THEN
      l_chunk_size := 10;
    END IF;
  CLOSE csr_chunk_size;

  message('INFO','Found chunk size', 15);
  message('SUMM','Found chunk size', 20);
  message('ROUT','exit:hr_dm_utility.chunk_size', 25);
  message('PARA','(l_chunk_size - ' || l_chunk_size || ')', 30);

  RETURN(l_chunk_size);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_du_utility.chunk_size','(none)','R');
  RAISE;

--
END CHUNK_SIZE;

end hr_du_utility;

/
