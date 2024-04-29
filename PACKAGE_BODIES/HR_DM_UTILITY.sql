--------------------------------------------------------
--  DDL for Package Body HR_DM_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_UTILITY" AS
/* $Header: perdmutl.pkb 120.0 2005/05/31 17:15:29 appldev noship $ */

/*--------------------------- GLOBAL VARIABLES ----------------------------*/


-- message globals
-- start

g_debug_message_pipe VARCHAR2(50);
g_debug_message_log VARCHAR2(50);
g_debug_message_indent NUMBER;
g_debug_message_indent_size NUMBER := 2;

-- message globals
-- end


/*------------------------------- ROUTINES --------------------------------*/

-- general purpose procedures
-- start

-- ------------------------- number_of_threads ------------------------
-- Description:     Finds the number of threads for the concurrent manager
-- to use by looking at ben_batch_parameters which is striped by business
-- group id.
--
--
--  Input Parameters
--        p_business_group_id - for the current business group
--
--
--  Output Parameters
--        <none>
--
--
--  Return Value
--        number of threads
--
--
-- ------------------------------------------------------------------------

--
FUNCTION number_of_threads(p_business_group_id IN NUMBER) RETURN NUMBER IS
--

l_threads NUMBER;


CURSOR csr_threads IS
  SELECT thread_cnt_num
    FROM ben_batch_parameter
    WHERE (business_group_id = p_business_group_id)
      AND (batch_exe_cd = 'HRDM');


--
BEGIN
--

message('ROUT','entry:hr_dm_utility.number_of_threads', 5);
message('PARA','(p_business_group_id - ' || p_business_group_id || ')', 10);


OPEN csr_threads;
LOOP
  FETCH csr_threads INTO l_threads;
  EXIT when csr_threads%NOTFOUND;
END LOOP;
CLOSE csr_threads;

-- set default value if no entry exists for the current business group
IF (l_threads IS NULL) THEN
  l_threads := 3;
  message('INFO','No value for the number of threads found in ' ||
          'ben_batch_parameters - using default value', 12);
END IF;

-- make sure that we have at least one thread
IF (l_threads <1) THEN
  l_threads := 1;
  message('INFO','The number of threads has been set to one as this is' ||
          ' The minimum value permitted.', 13);
END IF;


message('INFO','Found number of threads', 15);
message('SUMM','Found number of threads', 20);
message('ROUT','exit:hr_dm_utility.number_of_threads', 25);
message('PARA','(l_threads - ' || l_threads || ')', 30);

RETURN(l_threads);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.number_of_threads','(none)','R');
  RAISE;

--
END number_of_threads;
--



-- ------------------------- chunk_size -----------------------------------
-- Description:     Finds the chunk size to use for the DP, UP and D phases
-- to use by looking at ben_batch_parameters which is striped by business
-- group id.
--
--
--  Input Parameters
--        p_business_group_id - for the current business group
--
--
--  Output Parameters
--        <none>
--
--
--  Return Value
--        chunk_size
--
--
-- ------------------------------------------------------------------------


--
FUNCTION chunk_size(p_business_group_id IN NUMBER) RETURN NUMBER IS
--

l_chunk_size NUMBER;


CURSOR csr_chunk_size IS
  SELECT chunk_size
    FROM ben_batch_parameter
    WHERE (business_group_id = p_business_group_id)
      AND (batch_exe_cd = 'HRDM');

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.chunk_size', 5);
message('PARA','(p_business_group_id - ' || p_business_group_id || ')', 10);


OPEN csr_chunk_size;
LOOP
  FETCH csr_chunk_size INTO l_chunk_size;
  EXIT when csr_chunk_size%NOTFOUND;
END LOOP;
CLOSE csr_chunk_size;

-- set default value if no entry exists for the current business group
IF (l_chunk_size IS NULL) THEN
  l_chunk_size := 10;
  message('INFO','No value for the number of chunk size found in ' ||
                 'ben_batch_parameters - using default value', 15);
END IF;

message('INFO','Found chunk size', 15);
message('SUMM','Found chunk size', 20);
message('ROUT','exit:hr_dm_utility.chunk_size', 25);
message('PARA','(l_chunk_size - ' || l_chunk_size || ')', 30);

RETURN(l_chunk_size);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.chunk_size','(none)','R');
  RAISE;

--
END chunk_size;
--


-- ------------------------- get_phase_status ------------------------
-- Description: Reads the status of the passed phase from the hr_dm_phases
-- table.
--
--
--  Input Parameters
--        p_phase        - code for phase to be reported on
--
--        p_migration_id - migration id of current migration
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
FUNCTION get_phase_status(p_phase IN VARCHAR2, p_migration_id IN NUMBER)
         RETURN VARCHAR2 IS
--

l_phase_status VARCHAR2(30);

CURSOR csr_status IS
  SELECT status
    FROM hr_dm_phases
    WHERE ((migration_id = p_migration_id)
      AND (phase_name = p_phase));

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.get_phase_status', 5);
message('PARA','(p_phase - ' || p_phase ||
               ')(p_migration_id - ' || p_migration_id || ')', 10);

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
message('ROUT','exit:hr_dm_utility.get_phase_status', 25);
message('PARA','(l_phase_status - ' || l_phase_status || ')', 30);

RETURN(l_phase_status);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.get_phase_status','(none)','R');
  RAISE;

--
END get_phase_status;
--

-- ------------------------- get_phase_id ------------------------
-- Description: Reads the phase id of the passed phase from the
-- hr_dm_phases table.
--
--
--  Input Parameters
--        p_phase        - code for phase to be reported on
--
--        p_migration_id - migration id of current migration
--
--
--  Output Parameters
--        <none>
--
--
--  Return Value
--        phase id
--
--
-- ------------------------------------------------------------------------


--
FUNCTION get_phase_id(p_phase IN VARCHAR2, p_migration_id IN NUMBER)
         RETURN NUMBER IS
--

l_phase_id NUMBER;

CURSOR csr_phase IS
  SELECT phase_id
    FROM hr_dm_phases
    WHERE ((migration_id = p_migration_id)
      AND (phase_name = p_phase));

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.get_phase_id', 5);
message('PARA','(p_phase - ' || p_phase ||
               ')(p_migration_id - ' || p_migration_id || ')', 10);


OPEN csr_phase;
LOOP
  FETCH csr_phase INTO l_phase_id;
  EXIT when csr_phase%NOTFOUND;
END LOOP;
CLOSE csr_phase;


message('INFO','Find Phase ID', 15);
message('SUMM','Find Phase ID', 20);
message('ROUT','exit:hr_dm_utility.get_phase_id', 25);
message('PARA','(l_phase_id - ' || l_phase_id || ')', 30);

RETURN(l_phase_id);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.get_phase_id','(none)','R');
  RAISE;

--
END get_phase_id;
--

-- ------------------------- set_process ------------------------
-- Description: Updates hr_dm_migrations with the current process
-- being undertaken by the DM
--
--
--  Input Parameters
--        p_process      - text describing the process
--
--        p_migration_id - migration id of current migration
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE set_process(p_process_text IN VARCHAR2,
                      p_phase IN VARCHAR2,
                      p_migration_id IN NUMBER) IS
--

l_text VARCHAR2(60);

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.set_process', 5);
message('PARA','(p_process_text - ' || p_process_text ||
               ')(p_phase - ' || p_phase ||
               ')(p_migration_id - ' || p_migration_id || ')', 10);

-- build up message
l_text := hr_general.decode_lookup('HR_DM_MIGRATION_PHASE', p_phase) ||
          ' - ' || p_process_text;

-- update table
UPDATE hr_dm_migrations
  SET migration_process = l_text
  WHERE migration_id = p_migration_id;
COMMIT;

message('INFO','Set process in hr_dm_migrations', 15);
message('SUMM','Set process in hr_dm_migrations', 20);
message('ROUT','exit:hr_dm_utility.set_process', 25);
message('PARA','(none)', 30);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.set_process','(none)','R');
  RAISE;

--
END set_process;
--



-- general purpose procedures
-- end

----------------------------------------------------------------------------



-- error procedures
-- start


-- ------------------------- error ------------------------
-- Description: When an error has occurred elsewhere, this procedure is
-- called to log the FAIL message which includes the failure code and
-- the failure message plus additional information supplied by the
-- function/procedure that errored. It can also do a commit or rollback
-- when called.
--
--
--  Input Parameters
--        p_sqlcode   - the sql error code
--
--        p_procedure - the procedure / function name where the error
--                      occurred, including the package name
--
--        p_extra     - any additional text to be appended to the
--                      FAIL message
--
--        p_rollback  - if a rollback (R) (default) or commit (C) is required
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE error (p_sqlcode IN NUMBER, p_procedure IN VARCHAR2,
                 p_extra IN VARCHAR2, p_rollback IN VARCHAR2 DEFAULT 'R') IS
--

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.error', 5);
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
message('ROUT','exit:hr_dm_utility.error', 30);
message('PARA','(none)', 35);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.error','(none)','R');
  RAISE;


--
END error;
--


-- error procedures
-- end

----------------------------------------------------------------------------



-- message procedures
-- start

-- ------------------------- message_init ------------------------
-- Description: Message logging for concurrent managers is initialized
-- by calling this procedure. It obtains the logging options from the
-- table pay_action_parameters. By default, SUMM and FAIL messages are
-- always enabled for sending to the log file.
--
--
--  Input Parameters
--        <none>
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE message_init IS
--
CURSOR csr_c1 IS
  SELECT parameter_value
    FROM pay_action_parameters
    WHERE parameter_name = 'HR_DM_DEBUG_PIPE';
CURSOR csr_c2 IS
  SELECT parameter_value
    FROM pay_action_parameters
    WHERE parameter_name = 'HR_DM_DEBUG_LOG';

--
BEGIN
--

-- read values from pay_action_parameters

OPEN csr_c1;
LOOP
  FETCH csr_c1 INTO g_debug_message_pipe;
  EXIT WHEN csr_c1%NOTFOUND;
END LOOP;
CLOSE csr_c1;

OPEN csr_c2;
LOOP
  FETCH csr_c2 INTO g_debug_message_log;
  EXIT WHEN csr_c2%NOTFOUND;
END LOOP;
CLOSE csr_c2;

-- ensure that summary and fail settings are set

IF ((INSTRB(g_debug_message_log, 'SUMM') IS NULL) OR
    (INSTRB(g_debug_message_log, 'SUMM') = 0)) THEN
  g_debug_message_log := g_debug_message_log || ':SUMM';
END IF;

IF ((INSTRB(g_debug_message_log, 'FAIL') IS NULL) OR
    (INSTRB(g_debug_message_log, 'FAIL') = 0)) THEN
  g_debug_message_log := g_debug_message_log || ':FAIL';
END IF;

-- start the indenting to zero indentation
g_debug_message_indent := 0;


-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.message_init','(none)','R');
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
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE message (p_type IN VARCHAR2, p_message IN VARCHAR2,
                   p_position IN NUMBER) IS
--

l_header VARCHAR2(30);
l_debug VARCHAR2(100);
l_message VARCHAR2(32767);

--
BEGIN
--

-- are we interested in this type of message?
l_debug := g_debug_message_pipe || ':' || g_debug_message_log;

IF (INSTRB(l_debug, p_type) <> 0) THEN
  l_message := p_message;
-- indent non-routing messages
--  IF (p_type <> 'ROUT') THEN
--    l_message := '     ' || l_message;
--  END IF;

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

-- send to pipe?
  IF (INSTRB(g_debug_message_pipe, p_type) <> 0) THEN
    hr_utility.set_location(l_header || ':-:' || l_message, p_position);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_header || ':-:' || l_message);
  END IF;

-- send to log file?
  IF (INSTRB(g_debug_message_log, p_type) <> 0) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_header || ':-:' || l_message);
  END IF;
END IF;


-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.message','(none)','R');
  RAISE;

--
END message;
--


-- message procedures
-- end

----------------------------------------------------------------------------



-- rollback procedures
-- start

-- ------------------------- rollback ------------------------
-- Description: The appropriate code (phase / phase item specific) for
-- the phase or phase item to be rolled back is called.
--
--
--  Input Parameters
--        p_phase         - code for the phase to be rolled back
--
--        p_masterslave   - MASTER indicates the rollback is for the phase
--                          SLAVE is for a single phase item
--
--        p_migration_id  - current migration id
--
--        p_phase_item_id - phase item to be rolled back
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE rollback (p_phase IN VARCHAR2,
                    p_masterslave IN VARCHAR2 DEFAULT NULL,
                    p_migration_id IN NUMBER DEFAULT NULL,
                    p_phase_item_id IN NUMBER DEFAULT NULL) IS
--

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.rollback', 5);
message('PARA','(p_phase - ' || p_phase ||
                  ')(p_masterslave - ' || p_masterslave || ')', 10);

-- what type of rollback?

-- Init
IF ((p_phase = 'I') AND (p_migration_id IS NOT NULL)) THEN
  rollback_init(p_migration_id);
END IF;

-- Generator
IF ((p_phase = 'G') AND (p_migration_id IS NOT NULL)) THEN
  rollback_generator(p_migration_id);
END IF;

-- Range
IF (p_phase = 'R') THEN
  IF ((p_masterslave = 'MASTER') AND (p_migration_id IS NOT NULL)) THEN
    rollback_range_master(p_migration_id);
  END IF;
END IF;

-- Download AOL
IF (p_phase = 'DA') THEN
  IF ((p_masterslave = 'MASTER') AND (p_migration_id IS NOT NULL)) THEN
    rollback_down_aol_master(p_migration_id);
  END IF;
END IF;

-- Download
IF (p_phase = 'DP') THEN
  IF ((p_masterslave = 'MASTER') AND (p_migration_id IS NOT NULL)) THEN
    rollback_download_master(p_migration_id);
  END IF;
END IF;

-- Copy
-- non-required

-- Upload
IF (p_phase = 'UP') THEN
  IF ((p_masterslave = 'MASTER') AND (p_migration_id IS NOT NULL)) THEN
    rollback_upload(p_migration_id);
  END IF;
END IF;

-- Upload AOL
IF (p_phase = 'UA') THEN
  IF ((p_masterslave = 'MASTER') AND (p_migration_id IS NOT NULL)) THEN
    rollback_up_aol_master(p_migration_id);
  END IF;
END IF;

-- Cleanup
IF ((p_phase = 'C') AND (p_migration_id IS NOT NULL)) THEN
  rollback_cleanup(p_migration_id);
END IF;

-- Delete
IF ((p_phase = 'D') AND (p_migration_id IS NOT NULL)) THEN
  rollback_delete(p_migration_id);
END IF;

message('INFO','Rollback', 15);
message('SUMM','Rollback', 20);
message('ROUT','exit:hr_dm_utility.rollback', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.rollback','(none)','R');
  RAISE;
--
END rollback;
--

/*-------------------------- PRIVATE ROUTINES ----------------------------*/


-- ------------------------- rollback_range_master ------------------------
-- Description: All entries in the hr_dm_migration_ranges table for the range
-- phase are deleted and the phase item status in hr_dm_phase_items is reset
-- to NS.
--
--
--  Input Parameters
--        p_migration_id  - current migration id
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE rollback_range_master (p_migration_id IN NUMBER) IS
--

CURSOR csr_c1 IS
  SELECT phi.phase_item_id
    FROM hr_dm_phase_items phi,
         hr_dm_phases ph
    WHERE (ph.migration_id = p_migration_id)
      AND (ph.phase_name = 'R')
      AND (phi.phase_id = ph.phase_id)
      AND (phi.status IN ('S', 'E'));

l_phase_item_id NUMBER;

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.rollback_range_master', 5);
message('PARA','(p_migration_id - ' || p_migration_id || ')', 10);

-- find all range phases for this migration that are started or in error
OPEN csr_c1;
LOOP
  FETCH csr_c1 INTO l_phase_item_id;
  EXIT WHEN csr_c1%NOTFOUND;
-- delete information from hr_dm_migration_ranges
    DELETE FROM hr_dm_migration_ranges
      WHERE phase_item_id = l_phase_item_id;
-- update status to not started
  update_phase_items('NS', l_phase_item_id);
END LOOP;
CLOSE csr_c1;

message('INFO','Rollback - range_master', 15);
message('SUMM','Rollback - range_master', 20);
message('ROUT','exit:hr_dm_utility.rollback_range_master', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.rollback_range_master','(none)','R');
  RAISE;
--
END rollback_range_master;
--


-- ---------------------- rollback_down_aol_master ------------------------
-- Description: All entries in the hr_dm_phase_items table for the download
-- aol phase which have a status of S or E are reset to NS.
--
--
--  Input Parameters
--        p_migration_id  - current migration id
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE rollback_down_aol_master (p_migration_id IN NUMBER) IS
--

CURSOR csr_c1 IS
  SELECT phi.phase_item_id
    FROM hr_dm_phase_items phi,
         hr_dm_phases ph
    WHERE (ph.migration_id = p_migration_id)
      AND (ph.phase_name = 'DA')
      AND (phi.phase_id = ph.phase_id)
      AND (phi.status IN ('S', 'E'));

l_phase_item_id NUMBER;

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.rollback_down_aol_master', 5);
message('PARA','(p_migration_id - ' || p_migration_id || ')', 10);

-- find all DA phases for this migration that are started or in error
OPEN csr_c1;
LOOP
  FETCH csr_c1 INTO l_phase_item_id;
  EXIT WHEN csr_c1%NOTFOUND;
-- update status to not started
  update_phase_items('NS', l_phase_item_id);
END LOOP;
CLOSE csr_c1;

message('INFO','Rollback - download_aol_master', 15);
message('SUMM','Rollback - download_aol_master', 20);
message('ROUT','exit:hr_dm_utility.rollback_down_aol_master', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.rollback_down_aol_master','(none)','R');
  RAISE;
--
END rollback_down_aol_master;
--

-- ---------------------- rollback_up_aol_master ------------------------
-- Description: All entries in the hr_dm_phase_items table for the upload
-- aol phase are reset to NS.
--
--
--  Input Parameters
--        p_migration_id  - current migration id
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE rollback_up_aol_master (p_migration_id IN NUMBER) IS
--

CURSOR csr_c1 IS
  SELECT phi.phase_item_id
    FROM hr_dm_phase_items phi,
         hr_dm_phases ph
    WHERE (ph.migration_id = p_migration_id)
      AND (ph.phase_name = 'UA')
      AND (phi.phase_id = ph.phase_id);

l_phase_item_id NUMBER;

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.rollback_up_aol_master', 5);
message('PARA','(p_migration_id - ' || p_migration_id || ')', 10);

-- find all UA phases for this migration
OPEN csr_c1;
LOOP
  FETCH csr_c1 INTO l_phase_item_id;
  EXIT WHEN csr_c1%NOTFOUND;
-- update status to not started
  update_phase_items('NS', l_phase_item_id);
END LOOP;
CLOSE csr_c1;

message('INFO','Rollback - upload_aol_master', 15);
message('SUMM','Rollback - upload_aol_master', 20);
message('ROUT','exit:hr_dm_utility.rollback_up_aol_master', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.rollback_up_aol_master','(none)','R');
  RAISE;
--
END rollback_up_aol_master;
--

-- ---------------------- rollback_download_master ------------------------
-- Description: Rows in the datapump for batches corresponding to the current
-- migration are deleted. All entries in the hr_dm_migration_ranges and the
-- hr_dm_phase_items table for the download phase which have a status of
-- S or E are reset to NS.
--
--
--  Input Parameters
--        p_migration_id  - current migration id
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE rollback_download_master (p_migration_id IN NUMBER) IS
--
l_phase_item_id NUMBER;
l_short_name VARCHAR2(30);
l_table_name VARCHAR2(30);
l_starting_process_sequence NUMBER;
l_ending_process_sequence NUMBER;
l_batch_id NUMBER;
l_range_id NUMBER;
l_call_delete VARCHAR2(200);
l_range_phase_id NUMBER;
l_phase_id NUMBER;

CURSOR csr_c1 IS
  SELECT phi.phase_item_id
    FROM hr_dm_phase_items phi,
         hr_dm_phases ph
    WHERE (ph.migration_id = p_migration_id)
      AND (ph.phase_name = 'DP')
      AND (phi.phase_id = ph.phase_id)
      AND (phi.status IN ('S', 'E'));

CURSOR csr_c2 IS
  SELECT tbl.table_name,
         tbl.short_name,
         mr.starting_process_sequence,
         mr.ending_process_sequence,
         mr.range_id
    FROM hr_dm_migration_ranges mr,
         hr_dm_tables tbl,
         hr_dm_phase_items pi
    WHERE (pi.phase_id = l_range_phase_id)
      AND (pi.phase_item_id = mr.phase_item_id)
      AND (pi.table_name = tbl.table_name)
      AND (mr.status IN ('S', 'E'));

CURSOR csr_c3 IS
  SELECT pi.batch_id
    FROM hr_dm_migration_ranges mr,
         hr_dm_tables tbl,
         hr_dm_phase_items pi,
         hr_dm_table_groupings tgp
    WHERE (pi.phase_id = l_phase_id)
      AND (pi.group_id = tgp.group_id)
      AND (tbl.table_name = l_table_name)
      AND (tbl.table_id = tgp.table_id);


--
BEGIN
--

message('ROUT','entry:hr_dm_utility.rollback_download_master', 5);
message('PARA','(p_migration_id - ' || p_migration_id || ')', 10);

-- find the range phase id
l_range_phase_id := get_phase_id('R', p_migration_id);

-- find the DP phase id
l_phase_id := get_phase_id('DP', p_migration_id);

-- find all download phase items for this migration that are started or
-- in error
OPEN csr_c1;
LOOP
  FETCH csr_c1 INTO l_phase_item_id;
  EXIT WHEN csr_c1%NOTFOUND;
-- delete information from batch_lines...
  OPEN csr_c2;
  LOOP
    FETCH csr_c2 INTO l_table_name,l_short_name,
                      l_starting_process_sequence,
                      l_ending_process_sequence, l_range_id;
    EXIT WHEN csr_c2%NOTFOUND;

-- get the batch_id
    OPEN csr_c3;
    FETCH csr_c3 INTO l_batch_id;
    CLOSE csr_c3;

-- now call the delete function
    l_call_delete := 'begin hrdmd_' || l_short_name || '.delete_datapump'
                     || '(p_batch_id => ' || l_batch_id
                     || ', p_start_id => ' || l_starting_process_sequence
                     || ', p_end_id => ' || l_ending_process_sequence
                     || ', p_chunk_size => 10'
                     || '); end;';
    hr_dm_library.run_sql(l_call_delete);


-- update status to not started
    update_migration_ranges('NS', l_range_id);
  END LOOP;
  CLOSE csr_c2;

-- now update phase_item to avoid problem if no migration
-- ranges were in error
  update_phase_items('NS',l_phase_item_id);
END LOOP;
CLOSE csr_c1;



message('INFO','Rollback', 15);
message('SUMM','Rollback', 20);
message('ROUT','exit:hr_dm_utility.rollback_download_master', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.rollback_download_master','(none)','R');
  RAISE;
--
END rollback_download_master;
--


-- ---------------------- rollback_init ------------------------
-- Description: All entries in the hr_dm_phases and the
-- hr_dm_phase_items table are deleted and the status of the
-- migration is reset to NS.
--
--
--  Input Parameters
--        p_phase_item_id  - current phase item id
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE rollback_init (p_migration_id IN NUMBER) IS
--

l_phase_id NUMBER;

CURSOR csr_c1 IS
  SELECT ph.phase_id
    FROM hr_dm_phases ph
    WHERE (ph.migration_id = p_migration_id)
      AND (ph.phase_name = 'I')
      AND (ph.status IN ('S', 'E'));

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.rollback_init', 5);
message('PARA','(p_migration_id - ' || p_migration_id || ')', 10);

-- find all init phases for this migration that are started or in error
OPEN csr_c1;
LOOP
  FETCH csr_c1 INTO l_phase_id;
  EXIT WHEN csr_c1%NOTFOUND;
-- delete all entries in hr_dm_phase_items
  DELETE FROM hr_dm_phase_items
    WHERE phase_id = l_phase_id;

-- delete information from hr_dm_phases
    DELETE FROM hr_dm_phases
      WHERE phase_id = l_phase_id;

END LOOP;
CLOSE csr_c1;

-- update status to started
  update_migrations('S', p_migration_id);


message('INFO','Rollback - init', 15);
message('SUMM','Rollback - init', 20);
message('ROUT','exit:hr_dm_utility.rollback_init', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.rollback_init','(none)','R');
  RAISE;
--
END rollback_init;
--

-- ---------------------------- rollback_generator -------------------------
-- Description: All entries in the hr_dm_phase_items table for the generator
-- phase are reset to NS.
--
--
--  Input Parameters
--        p_migration_id  - current migration id
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE rollback_generator (p_migration_id IN NUMBER) IS
--

CURSOR csr_c1 IS
  SELECT phi.phase_item_id
    FROM hr_dm_phase_items phi,
         hr_dm_phases ph
    WHERE (ph.migration_id = p_migration_id)
      AND (ph.phase_name = 'G')
      AND (phi.phase_id = ph.phase_id)
      AND (phi.status IN ('S', 'E'));

l_phase_item_id NUMBER;

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.rollback_generator', 5);
message('PARA','(p_migration_id - ' || p_migration_id || ')', 10);

-- find all generator phases for this migration that are started or in error
OPEN csr_c1;
LOOP
  FETCH csr_c1 INTO l_phase_item_id;
  EXIT WHEN csr_c1%NOTFOUND;
-- update status to not started
  update_phase_items('NS', l_phase_item_id);
END LOOP;
CLOSE csr_c1;

message('INFO','Rollback - generator', 15);
message('SUMM','Rollback - generator', 20);
message('ROUT','exit:hr_dm_utility.rollback_generator', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.rollback_generator','(none)','R');
  RAISE;
--
END rollback_generator;
--

-- ---------------------------- rollback_cleanup -------------------------
-- Description: All entries in the hr_dm_phase_items table for the cleanup
-- phase are reset to NS.
--
--
--  Input Parameters
--        p_migration_id  - current migration id
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE rollback_cleanup (p_migration_id IN NUMBER) IS
--

CURSOR csr_c1 IS
  SELECT phi.phase_item_id
    FROM hr_dm_phase_items phi,
         hr_dm_phases ph
    WHERE (ph.migration_id = p_migration_id)
      AND (ph.phase_name = 'C')
      AND (phi.phase_id = ph.phase_id)
      AND (phi.status IN ('S', 'E'));

l_phase_item_id NUMBER;

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.rollback_cleanup', 5);
message('PARA','(p_migration_id - ' || p_migration_id || ')', 10);

-- find all cleanup phases for this migration that are started or in error
OPEN csr_c1;
LOOP
  FETCH csr_c1 INTO l_phase_item_id;
  EXIT WHEN csr_c1%NOTFOUND;
-- update status to not started
  update_phase_items('NS', l_phase_item_id);
END LOOP;
CLOSE csr_c1;

message('INFO','Rollback - cleanup', 15);
message('SUMM','Rollback - cleanup', 20);
message('ROUT','exit:hr_dm_utility.rollback_cleanup', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.rollback_cleanup','(none)','R');
  RAISE;
--
END rollback_cleanup;
--

-- ------------------------- rollback_delete ------------------------
-- Description: All entries in the hr_dm_migration_ranges and the
-- hr_dm_phase_items tables for the delete phase are reset to NS.
--
--
--  Input Parameters
--        p_migration_id  - current migration id
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE rollback_delete (p_migration_id IN NUMBER) IS
--

l_phase_item_id NUMBER;
l_range_id NUMBER;
l_range_phase_id NUMBER;

CURSOR csr_c1 IS
  SELECT phi.phase_item_id
    FROM hr_dm_phase_items phi,
         hr_dm_phases ph
    WHERE (ph.migration_id = p_migration_id)
      AND (ph.phase_name = 'D')
      AND (phi.phase_id = ph.phase_id)
      AND (phi.status IN ('S', 'E'));

CURSOR csr_c2 IS
  SELECT mr.range_id
    FROM hr_dm_migration_ranges mr,
         hr_dm_phase_items pi
    WHERE (pi.phase_id = l_range_phase_id)
      AND (mr.phase_item_id = pi.phase_item_id)
      AND (mr.status IN ('S', 'E'));

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.rollback_delete', 5);
message('PARA','(p_migration_id - ' || p_migration_id || ')', 10);

-- find the range phase id
l_range_phase_id := get_phase_id('R', p_migration_id);

-- find all delete phases for this migration that are started or in error
OPEN csr_c1;
LOOP
  FETCH csr_c1 INTO l_phase_item_id;
  EXIT WHEN csr_c1%NOTFOUND;
-- update status to not started if required
  update_phase_items('NS', l_phase_item_id);
END LOOP;
CLOSE csr_c1;

-- reset all the migration ranges
OPEN csr_c2;
LOOP
  FETCH csr_c2 INTO l_range_id;
  EXIT WHEN csr_c2%NOTFOUND;
  IF csr_c2%FOUND THEN
-- update status to not started
    update_migration_ranges('NS', l_range_id);
  END IF;
END LOOP;
CLOSE csr_c2;

message('INFO','Rollback - delete', 15);
message('SUMM','Rollback - delete', 20);
message('ROUT','exit:hr_dm_utility.rollback_delete', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.rollback_delete','(none)','R');
  RAISE;
--
END rollback_delete;
--

-- ---------------------------- rollback_upload -------------------------
-- Description: All entries in the hr_dm_phase_items table for the upload
-- phase are reset to NS.
--
--
--  Input Parameters
--        p_migration_id  - current migration id
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE rollback_upload (p_migration_id IN NUMBER) IS
--

CURSOR csr_c1 IS
  SELECT phi.phase_item_id
    FROM hr_dm_phase_items phi,
         hr_dm_phases ph
    WHERE (ph.migration_id = p_migration_id)
      AND (ph.phase_name = 'UP')
      AND (phi.phase_id = ph.phase_id)
      AND (phi.status IN ('S', 'E'));

l_phase_item_id NUMBER;

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.rollback_upload', 5);
message('PARA','(p_migration_id - ' || p_migration_id || ')', 10);

-- find all upload phases for this migration that are started or in error
OPEN csr_c1;
LOOP
  FETCH csr_c1 INTO l_phase_item_id;
  EXIT WHEN csr_c1%NOTFOUND;
-- update status to not started
  update_phase_items('NS', l_phase_item_id);
END LOOP;
CLOSE csr_c1;

message('INFO','Rollback - upload', 15);
message('SUMM','Rollback - upload', 20);
message('ROUT','exit:hr_dm_utility.rollback_upload', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.rollback_upload','(none)','R');
  RAISE;
--
END rollback_upload;
--


-- rollback procedures
-- end

----------------------------------------------------------------------------


-- update status procedures
-- start

-- ------------------------- update_migrations ------------------------
-- Description: Updates the status of the migration in the hr_dm_migrations
-- table. If the status is to be set to C then all child entries in
-- hr_dm_phases are checked to ensure that they have completed.
--
--
--  Input Parameters
--        p_new_status - new status code
--
--        p_id         - migration id
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE update_migrations (p_new_status IN VARCHAR2, p_id IN NUMBER) IS
--
-- table is hr_dm_migrations
-- parent of hr_dm_phases
-- child of (none)

l_parent_table_id NUMBER(9);
l_complete VARCHAR2(30);
l_start_date DATE;

-- search child table for all complete
CURSOR csr_child_table_complete IS
  SELECT status
    FROM hr_dm_phases
    WHERE ((migration_id = p_id)
      AND (status <> 'C'));

--
BEGIN
--

message('ROUT','entry:hr_dm_utility.update_migrations', 5);
message('PARA','(p_new_status - ' || p_new_status ||
                  ')(p_id - ' || p_id || ')', 10);

-- set start date for 'S'
IF (p_new_status = 'S') THEN
  l_start_date := sysdate;
END IF;


-- non-complete
IF (p_new_status IN('S', 'NS', 'E')) THEN
-- update the status for this row
  UPDATE hr_dm_migrations
  SET status = p_new_status,
      migration_start_date = NVL(l_start_date, migration_start_date)
  WHERE migration_id = p_id;
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
    UPDATE hr_dm_migrations
    SET status = p_new_status,
        migration_end_date = sysdate
    WHERE migration_id = p_id;
    COMMIT;
-- set current processing
    set_process('Completed', NULL, p_id);
  END IF;
  CLOSE csr_child_table_complete;
END IF;

message('INFO','Update status - update_migrations', 15);
message('SUMM','Update status - update_migrations', 20);
message('ROUT','exit:hr_dm_utility.update_migrations', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.update_migrations','(none)','R');
  RAISE;

--
END update_migrations;
--


-- ------------------------- update_migrations_ranges ----------------------
-- Description: Updates the status of the migration range in the
-- hr_dm_migration_ranges table. If the status is to be set to C or E then
-- the update status is cascaded up to the parent phase.
--
--
--  Input Parameters
--        p_new_status - new status code
--
--        p_id         - migration range id
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE update_migration_ranges (p_new_status IN VARCHAR2,
                                   p_id IN NUMBER) IS
--
-- table is hr_dm_migration_ranges
-- parent of (none)
-- child of hr_dm_phase_items

l_parent_table_id NUMBER(9);
l_parent_table_status VARCHAR2(30);
l_start_time DATE;
l_end_time DATE;
l_phase_item_id NUMBER;
l_complete VARCHAR2(30);
l_phase_id NUMBER;
l_migration_id NUMBER;

-- find migration id
CURSOR csr_mig_id IS
  SELECT ph.migration_id
    FROM hr_dm_migration_ranges mr,
         hr_dm_phase_items pi,
         hr_dm_phases ph
    WHERE p_id = mr.range_id
      AND mr.phase_item_id = pi.phase_item_id
      AND pi.phase_id = ph.phase_id;

-- find parent phase item id
CURSOR csr_par_pi_id IS
  SELECT pi_par.phase_item_id
    FROM hr_dm_phase_items pi_par,
         hr_dm_tables tbl,
         hr_dm_migration_ranges mr,
         hr_dm_phase_items pi_rg,
         hr_dm_table_groupings tgp
    WHERE p_id = mr.range_id
      AND mr.phase_item_id = pi_rg.phase_item_id
      AND pi_rg.table_name = tbl.table_name
      AND tbl.table_id = tgp.table_id
      AND tgp.group_id = pi_par.group_id
      AND pi_par.phase_id = l_phase_id;


-- search 'child' table for all complete
CURSOR csr_child_table_complete IS
  SELECT mr.status
    FROM hr_dm_migration_ranges mr,
         hr_dm_phase_items  rg_pi
    WHERE (mr.phase_item_id = rg_pi.phase_item_id)
      AND (rg_pi.group_id = (SELECT rg_pi.group_id
                               FROM hr_dm_phase_items rg_pi,
                                    hr_dm_migration_ranges mr
                               WHERE p_id = mr.range_id
                                 AND mr.phase_item_id = rg_pi.phase_item_id))
      AND (mr.status <> 'C');


CURSOR csr_parent_status IS
  SELECT status
    FROM hr_dm_phase_items
    WHERE phase_item_id = l_parent_table_id;



--
BEGIN
--
message('ROUT','entry:hr_dm_utility.update_migration_ranges', 5);
message('PARA','(p_new_status - ' || p_new_status ||
               ')(p_id - ' || p_id || ')', 10);

-- get the parent phase_id
OPEN csr_mig_id;
FETCH csr_mig_id INTO l_migration_id;
CLOSE csr_mig_id;

-- first see if it is a delete migration
l_phase_id := hr_dm_utility.get_phase_id('D', l_migration_id);
-- if null returned then it must be a DP phase we are looking for
IF (l_phase_id IS NULL) THEN
  l_phase_id := hr_dm_utility.get_phase_id('DP', l_migration_id);
END IF;

-- set start time for 'S'
IF (p_new_status = 'S') THEN
  l_start_time := sysdate;
END IF;

-- set end time for 'C'
IF (p_new_status = 'C') THEN
  l_end_time := sysdate;
END IF;

-- update the status for this row
UPDATE hr_dm_migration_ranges
  SET status = p_new_status,
      start_time = NVL(l_start_time, start_time),
      end_time = NVL(l_end_time, end_time)
  WHERE range_id = p_id;
COMMIT;

-- update parent for error
IF (p_new_status = 'E') THEN
-- now cascade to parent table
  OPEN csr_par_pi_id;
  FETCH csr_par_pi_id INTO l_parent_table_id;
  CLOSE csr_par_pi_id;
  update_phase_items('E',l_parent_table_id);
END IF;

-- if all rows are complete, then update parent
IF (p_new_status = 'C') THEN
-- get parent phase item
  OPEN csr_par_pi_id;
  FETCH csr_par_pi_id INTO l_parent_table_id;
  CLOSE csr_par_pi_id;

  OPEN csr_child_table_complete;
  FETCH csr_child_table_complete INTO l_complete;
  IF (csr_child_table_complete%NOTFOUND) THEN
-- now cascade to parent table
    update_phase_items(p_new_status,l_parent_table_id);
  END IF;
  CLOSE csr_child_table_complete;
END IF;


-- update parent status to started if parent has a status of NS
IF (p_new_status = 'S') THEN
-- get parent phase item
  OPEN csr_par_pi_id;
  FETCH csr_par_pi_id INTO l_parent_table_id;
  CLOSE csr_par_pi_id;

  OPEN csr_parent_status;
  FETCH csr_parent_status INTO l_parent_table_status;
  CLOSE csr_parent_status;

  IF (l_parent_table_status = 'NS') THEN
    update_phase_items('S',l_parent_table_id);
  END IF;


END IF;


message('INFO','Update status - update_migration_ranges', 15);
message('SUMM','Update status - update_migration_ranges', 20);
message('ROUT','exit:hr_dm_utility.update_migration_ranges', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.update_migration_ranges','(none)','R');
  RAISE;

--
END update_migration_ranges;
--


-- ------------------------- update_phase_items ----------------------
-- Description: Updates the status of the phase item in the
-- hr_dm_phase_items table. If the status is to be set to C or E then
-- the update status is cascaded up to the parent phase.
--
--
--  Input Parameters
--        p_new_status - new status code
--
--        p_id         - phase_item id
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE update_phase_items (p_new_status IN VARCHAR2, p_id IN NUMBER) IS
--
-- table is hr_dm_phase_items
-- parent of n/a
-- child of hr_dm_phases

l_parent_table_id NUMBER(9);
l_start_time DATE;
l_end_time DATE;

-- find parent table id
CURSOR csr_parent_id IS
  SELECT phase_id
    FROM hr_dm_phase_items
    WHERE phase_item_id = p_id;


--
BEGIN
--

message('ROUT','entry:hr_dm_utility.update_phase_items', 5);
message('PARA','(p_new_status - ' || p_new_status ||
                  ')(p_id - ' || p_id || ')', 10);

-- set start time for 'S'
IF (p_new_status = 'S') THEN
  l_start_time := sysdate;
END IF;

-- set end time for 'C'
IF (p_new_status = 'C') THEN
  l_end_time := sysdate;
END IF;

-- update the status for this row
UPDATE hr_dm_phase_items
  SET status = p_new_status,
      start_time = NVL(l_start_time, start_time),
      end_time = NVL(l_end_time, end_time)
  WHERE phase_item_id = p_id;
COMMIT;

-- update parent?
IF (p_new_status IN('C', 'E')) THEN
  OPEN csr_parent_id;
  FETCH csr_parent_id INTO l_parent_table_id;
  CLOSE csr_parent_id;
  update_phases(p_new_status,l_parent_table_id);
END IF;

message('INFO','Update status - update_phase_items', 15);
message('SUMM','Update status - update_phase_items', 20);
message('ROUT','exit:hr_dm_utility.update_phase_items', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.update_phase_items','(none)','R');
  RAISE;

--
END update_phase_items;
--

-- ------------------------- update_phases ----------------------
-- Description: Updates the status of the phase in the
-- hr_dm_phases table. If the status is to be set to C or E then
-- the update status is cascaded up to the parent phase. For a C,
-- the status of all the child rows in the hr_dm_phase_items is
-- checked.
--
--
--  Input Parameters
--        p_new_status - new status code
--
--        p_id         - phase_item id
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE update_phases (p_new_status IN VARCHAR2, p_id IN NUMBER) IS
--
-- table is hr_dm_phases
-- parent of hr_dm_phase_items
-- child of hr_dm_migrations

l_parent_table_id NUMBER(9);
l_complete VARCHAR2(30);
l_start_time DATE;
l_new_status VARCHAR2(30);

-- search child table for all complete
CURSOR csr_child_table_complete IS
  SELECT status
    FROM hr_dm_phase_items
    WHERE ((phase_id = p_id)
      AND (status <> 'C'));

-- find parent table id
CURSOR csr_parent_id IS
  SELECT migration_id
    FROM hr_dm_phases
    WHERE phase_id = p_id;


--
BEGIN
--

message('ROUT','entry:hr_dm_utility.update_phases', 5);
message('PARA','(p_new_status - ' || p_new_status ||
                  ')(p_id - ' || p_id || ')', 10);

l_new_status := p_new_status;

-- set start time for 'S'
IF (l_new_status = 'S') THEN
  l_start_time := sysdate;
END IF;

-- non-complete
IF (l_new_status IN('S', 'NS', 'E')) THEN
-- update the status for this row
  UPDATE hr_dm_phases
  SET status = l_new_status,
      start_time = NVL(l_start_time, start_time)
  WHERE phase_id = p_id;
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
    UPDATE hr_dm_phases
    SET status = l_new_status,
        end_time = sysdate
    WHERE phase_id = p_id;
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
  update_migrations(l_new_status,l_parent_table_id);
END IF;


message('INFO','Update status - update_phases', 15);
message('SUMM','Update status - update_phases', 20);
message('ROUT','exit:hr_dm_utility.update_phases', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'hr_dm_utility.update_phases','(none)','R');
  RAISE;

--
END update_phases;
--


-- update status procedures
-- end



end hr_dm_utility;

/
