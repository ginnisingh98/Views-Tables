--------------------------------------------------------
--  DDL for Package Body BEN_DM_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_UTILITY" AS
/* $Header: benfdmutil.pkb 120.0 2006/05/11 05:04:12 nkkrishn noship $ */

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
-- group id.  Fetch the first Thread count found and use that which will
-- be irrepective of a BG due to that fact the Person Migrator can work
-- across Business Groups and there is no way to change the threads which
-- are spawned during a Migrator processing.
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
    WHERE (batch_exe_cd = 'BENDM');

--
BEGIN
--

 message('ROUT','entry:ben_dm_utility.number_of_threads', 5);
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
message('ROUT','exit:ben_dm_utility.number_of_threads', 25);
message('PARA','(l_threads - ' || l_threads || ')', 30);


RETURN(l_threads);

-- error handling
EXCEPTION
WHEN OTHERS THEN
--  error(SQLCODE,'ben_dm_utility.number_of_threads','(none)','R');
  RAISE;

--
END number_of_threads;
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
    FROM ben_dm_phases
    WHERE ((migration_id = p_migration_id)
      AND (phase_name = p_phase));

--
BEGIN
--

message('ROUT','entry:ben_dm_utility.get_phase_status', 5);
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
message('ROUT','exit:ben_dm_utility.get_phase_status', 25);
message('PARA','(l_phase_status - ' || l_phase_status || ')', 30);

RETURN(l_phase_status);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'ben_dm_utility.get_phase_status','(none)','R');
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
    FROM ben_dm_phases
    WHERE ((migration_id = p_migration_id)
      AND (phase_name = p_phase));

--
BEGIN
--

message('ROUT','entry:ben_dm_utility.get_phase_id', 5);
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
message('ROUT','exit:ben_dm_utility.get_phase_id', 25);
message('PARA','(l_phase_id - ' || l_phase_id || ')', 30);

RETURN(l_phase_id);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'ben_dm_utility.get_phase_id','(none)','R');
  RAISE;

--
END get_phase_id;
--

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

message('ROUT','entry:ben_dm_utility.error', 5);
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
message('ROUT','exit:ben_dm_utility.error', 30);
message('PARA','(none)', 35);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'ben_dm_utility.error','(none)','R');
  RAISE;


--
END error;
--
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
  error(SQLCODE,'ben_dm_utility.message_init','(none)','R');
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
  error(SQLCODE,'ben_dm_utility.message','(none)','R');
  RAISE;

--
END message;
--
-- update status procedures
-- start

-- ------------------------- update_migrations ------------------------
-- Description: Updates the status of the migration in the ben_dm_migrations
-- table. If the status is to be set to C then all child entries in
-- ben_dm_phases are checked to ensure that they have completed.
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
-- table is ben_dm_migrations
-- parent of ben_dm_phases
-- child of (none)

l_parent_table_id NUMBER(9);
l_complete VARCHAR2(30);
l_start_date DATE;

-- search child table for all complete
CURSOR csr_child_table_complete IS
  SELECT status
    FROM ben_dm_phases
    WHERE ((migration_id = p_id)
      AND (status <> 'C'));

--
BEGIN
--

message('ROUT','entry:ben_dm_utility.update_migrations', 5);
message('PARA','(p_new_status - ' || p_new_status ||
                  ')(p_id - ' || p_id || ')', 10);

-- set start date for 'S'
IF (p_new_status = 'S') THEN
  l_start_date := sysdate;
END IF;


-- non-complete
IF (p_new_status IN('S', 'NS', 'E')) THEN
-- update the status for this row
  UPDATE ben_dm_migrations
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
    UPDATE ben_dm_migrations
    SET status = p_new_status,
        migration_end_date = sysdate
    WHERE migration_id = p_id;
    COMMIT;
  END IF;
  CLOSE csr_child_table_complete;
END IF;

message('INFO','Update status - update_migrations', 15);
message('SUMM','Update status - update_migrations', 20);
message('ROUT','exit:ben_dm_utility.update_migrations', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'ben_dm_utility.update_migrations','(none)','R');
  RAISE;

--
END update_migrations;
--
-- ------------------------- update_phase_items ----------------------
-- Description: Updates the status of the phase item in the
-- ben_dm_phase_items table. If the status is to be set to C or E then
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
    FROM ben_dm_phase_items
    WHERE phase_item_id = p_id;


--
BEGIN
--

message('ROUT','entry:ben_dm_utility.update_phase_items', 5);
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
UPDATE ben_dm_phase_items
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
message('ROUT','exit:ben_dm_utility.update_phase_items', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'ben_dm_utility.update_phase_items','(none)','R');
  RAISE;

--
END update_phase_items;
--
-- ------------------------- update_phases ----------------------
-- Description: Updates the status of the phase in the
-- ben_dm_phases table. If the status is to be set to C or E then
-- the update status is cascaded up to the parent phase. For a C,
-- the status of all the child rows in the ben_dm_phase_items is
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
-- table is ben_dm_phases
-- parent of ben_dm_phase_items
-- child of ben_dm_migrations

l_parent_table_id NUMBER(9);
l_complete VARCHAR2(30);
l_start_time DATE;
l_new_status VARCHAR2(30);

-- search child table for all complete
CURSOR csr_child_table_complete IS
  SELECT status
    FROM ben_dm_phase_items
    WHERE ((phase_id = p_id)
      AND (status <> 'C'));

-- find parent table id
CURSOR csr_parent_id IS
  SELECT migration_id
    FROM ben_dm_phases
    WHERE phase_id = p_id;


--
BEGIN
--

message('ROUT','entry:ben_dm_utility.update_phases', 5);
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
  UPDATE ben_dm_phases
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
    UPDATE ben_dm_phases
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
message('ROUT','exit:ben_dm_utility.update_phases', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'ben_dm_utility.update_phases','(none)','R');
  RAISE;

--
END update_phases;

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

message('ROUT','entry:ben_dm_utility.rollback', 5);
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

-- Download
IF (p_phase = 'DP') THEN
  IF ((p_masterslave = 'MASTER') AND (p_migration_id IS NOT NULL)) THEN
    rollback_download_master(p_migration_id);
  END IF;
END IF;

-- Upload
IF ((p_phase = 'UP') AND (p_migration_id IS NOT NULL)) THEN
  rollback_upload(p_migration_id);
END IF;


message('INFO','Rollback', 15);
message('SUMM','Rollback', 20);
message('ROUT','exit:ben_dm_utility.rollback', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'ben_dm_utility.rollback','(none)','R');
  RAISE;
--
END rollback;
--

-- ---------------------- rollback_download_master ------------------------
-- Description: Rows in the datapump for batches corresponding to the current
-- migration are deleted. All entries in the hr_dm_phase_items table for
-- the download phase which have a status of
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
l_group_order   NUMBER;
l_short_name VARCHAR2(30);
l_table_name VARCHAR2(30);
l_phase_id NUMBER;

CURSOR csr_c1 IS
  SELECT phi.phase_item_id, group_order
    FROM ben_dm_phase_items phi,
         ben_dm_phases ph
    WHERE (ph.migration_id = p_migration_id)
      AND (ph.phase_name = 'DP')
      AND (phi.phase_id = ph.phase_id)
      AND (phi.status IN ('S', 'E'));

--
BEGIN
--

message('ROUT','entry:ben_dm_utility.rollback_download_master', 5);
message('PARA','(p_migration_id - ' || p_migration_id || ')', 10);

-- find the DP phase id
l_phase_id := get_phase_id('DP', p_migration_id);

-- find all download phase items for this migration that are started or
-- in error
OPEN csr_c1;
LOOP
  FETCH csr_c1 INTO l_phase_item_id, l_group_order;
  EXIT WHEN csr_c1%NOTFOUND;
--
-- delete information from ben_dm_entity_results table.
--
    delete from ben_dm_entity_results
    where group_order = l_group_order;

    commit;
-- ??  Add EXCEPTIOn if no data found.
-- now update phase_item to avoid problem if no migration
-- ranges were in error
  update_phase_items('NS',l_phase_item_id);
END LOOP;
CLOSE csr_c1;

message('INFO','Rollback', 15);
message('SUMM','Rollback', 20);
message('ROUT','exit:ben_dm_utility.rollback_download_master', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'ben_dm_utility.rollback_download_master','(none)','R');
  RAISE;
--
END rollback_download_master;
--

-- ---------------------- rollback_init ------------------------
-- Description: All entries in the ben_dm_phases and the
-- ben_dm_phase_items table are deleted and the status of the
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
    FROM ben_dm_phases ph
    WHERE (ph.migration_id = p_migration_id)
      AND (ph.phase_name = 'I')
      AND (ph.status IN ('S', 'E'));

--
BEGIN
--

message('ROUT','entry:ben_dm_utility.rollback_init', 5);
message('PARA','(p_migration_id - ' || p_migration_id || ')', 10);

-- find all init phases for this migration that are started or in error
OPEN csr_c1;
LOOP
  FETCH csr_c1 INTO l_phase_id;
  EXIT WHEN csr_c1%NOTFOUND;
-- delete all entries in hr_dm_phase_items
  DELETE FROM ben_dm_phase_items
    WHERE phase_id = l_phase_id;

-- delete information from hr_dm_phases
    DELETE FROM ben_dm_phases
      WHERE phase_id = l_phase_id;

END LOOP;
CLOSE csr_c1;

-- update status to started
  update_migrations('S', p_migration_id);


message('INFO','Rollback - init', 15);
message('SUMM','Rollback - init', 20);
message('ROUT','exit:ben_dm_utility.rollback_init', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'ben_dm_utility.rollback_init','(none)','R');
  RAISE;
--
END rollback_init;
--

--
-- ---------------------------- rollback_generator -------------------------
-- Description: All entries in the ben_dm_phase_items table for the generator
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
    FROM ben_dm_phase_items phi,
         ben_dm_phases ph
    WHERE (ph.migration_id = p_migration_id)
      AND (ph.phase_name = 'G')
      AND (phi.phase_id = ph.phase_id)
      AND (phi.status IN ('S', 'E'));

l_phase_item_id NUMBER;

--
BEGIN
--

message('ROUT','entry:ben_dm_utility.rollback_generator', 5);
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
message('ROUT','exit:ben_dm_utility.rollback_generator', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'ben_dm_utility.rollback_generator','(none)','R');
  RAISE;
--
END rollback_generator;
--


-- ------------------------- get_table_id ------------------------
-- Description:     Get table_id from ben_dm_tables for a given table_name
--
--
--  Input Parameters
--        p_table_name - table_name
--
--
--  Output Parameters
--        <none>
--
--
--  Return Value
--        Table id
--
--
-- ------------------------------------------------------------------------

--
-- ---------------------------- rollback_upload -------------------------
-- Description: All entries in the ben_dm_phase_items table for the upload
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
    FROM ben_dm_phase_items phi,
         ben_dm_phases ph
    WHERE (ph.migration_id = p_migration_id)
      AND (ph.phase_name = 'UP')
      AND (phi.phase_id = ph.phase_id)
      AND (phi.status IN ('S', 'E'));

l_phase_item_id NUMBER;

--
BEGIN
--

message('ROUT','entry:ben_dm_utility.rollback_upload', 5);
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
message('ROUT','exit:ben_dm_utility.rollback_upload', 25);
message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  error(SQLCODE,'ben_dm_utility.rollback_upload','(none)','R');
  RAISE;
--
END rollback_upload;
--


--
FUNCTION get_table_id(p_table_name IN VARCHAR2) RETURN NUMBER IS
--

l_table_id NUMBER;

CURSOR csr_tables IS
  SELECT table_id
    FROM ben_dm_tables
    WHERE table_name = p_table_name;

--
BEGIN
--

-- message('ROUT','entry:ben_dm_utility.number_of_threads', 5);
-- message('PARA','(p_business_group_id - ' || p_business_group_id || ')', 10);
OPEN csr_tables;
FETCH csr_tables INTO l_table_id;
CLOSE csr_tables;

-- set default value if no entry exists for the current business group
IF (l_table_id IS NULL) THEN
 -- Raise an exception.
 null;
END IF;

-- message('INFO','Found Table ID', 15);
-- message('SUMM','Found Table ID', 20);
-- message('ROUT','exit:ben_dm_utility.get_table_id', 25);
-- message('PARA','(l_table_id - ' || ')', 30);

RETURN(l_table_id);

-- error handling
EXCEPTION
WHEN OTHERS THEN
 -- error(SQLCODE,'ben_dm_utility.get_table_id','(none)','R');
  RAISE;

--
END get_table_id;
--

-- ------------------------- seed_column_mapping --------------------
-- Description: Seeds Mapping into BEN_DM_COLUMN_MAPPINGS for given
-- table
--
--
--  Input Parameters
--        p_table_name - Table Name
--
--  Output Parameters
--        <none>
--
-- ------------------------------------------------------------------------

--
PROCEDURE seed_column_mapping (p_table_name IN VARCHAR2) IS
--
l_er_column_name VARCHAR2(30);
l_column_name VARCHAR2(30);
l_table_name VARCHAR2(30);
l_table_id NUMBER;

-- Get columns for seeding
CURSOR csr_get_columns IS
  SELECT column_name, data_type
    FROM sys.all_tab_columns cols1
   WHERE data_type in ('NUMBER','VARCHAR2','DATE')
     AND table_name = p_table_name
     AND column_name not in ('REQUEST_ID','PROGRAM_APPLICATION_ID','PROGRAM_ID','PROGRAM_UPDATE_DATE')
     AND data_length < 2001
     AND not exists (SELECT null
                      FROM BEN_DM_COLUMN_MAPPINGS d1
                     WHERE d1.table_id in (select table_id from ben_dm_tables where table_name = cols1.table_name)
                       AND column_name = cols1.column_name);


-- Find next available Entity Result column
CURSOR csr_get_er_columns (p_data_type VARCHAR2,
                           p_table_id  NUMBER,
                           p_column_name VARCHAR2) IS
  SELECT column_name
    FROM sys.all_tab_columns
    WHERE data_type = p_data_type
      AND table_name = 'BEN_DM_ENTITY_RESULTS'
      AND column_name not in ('ENTITY_RESULT_ID','MIGRATION_ID','TABLE_NAME','GROUP_ORDER')
      AND column_name not in (SELECT entity_result_column_name
                                FROM ben_dm_column_mappings
                               WHERE table_id = p_table_id)
   ORDER BY column_id asc;


--
BEGIN
--

-- message('ROUT','entry:ben_dm_utility.seed_column_mapping', 5);
-- message('PARA','(p_table_name - ' || p_table_name ||'), 10);
-- get_table_id

l_table_id := get_table_id(p_table_name);

-- Get Column Information for seeding into ben_dm_mappings if required


FOR column_list IN csr_get_columns LOOP

  OPEN csr_get_er_columns(column_list.data_type, l_table_id, column_list.column_name);
  FETCH csr_get_er_columns INTO l_er_column_name;
  CLOSE csr_get_er_columns;

    INSERT into ben_dm_column_mappings
    (column_mapping_id
    ,table_id
    ,column_name
    ,entity_result_column_name
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,created_by
    ,creation_date)
    VALUES
    (ben_dm_column_mappings_s.nextval
    ,l_table_id
    ,column_list.column_name
    ,l_er_column_name
    ,sysdate
    ,1
    ,1
    ,1
    ,sysdate);

END LOOP;

-- message('INFO','seed_column_maping', 15);
-- message('SUMM','seed_column_maping', 20);
-- message('ROUT','exit:ben_dm_utility.seed_column_maping', 25);
-- message('PARA','(p_table_name - ' || p_table_name ||'), 10);

-- error handling
EXCEPTION
WHEN OTHERS THEN
 -- error(SQLCODE,'ben_dm_utility.seed_column_maping','(none)','R');
  RAISE;
--
END seed_column_mapping;
--
-- ------------------------- seed_table_order --------------------
-- Description: Seeds table order into BEN_DM_TABLE_ORDER for given
-- table
--
--
--  Input Parameters
--        p_table_name - Table Name
--        p_order_no   - Order Number
--
--  Output Parameters
--        <none>
--
-- ------------------------------------------------------------------------

--
PROCEDURE seed_table_order (p_table_name IN VARCHAR2, p_order_no IN NUMBER) IS
--
l_table_id NUMBER;

--
BEGIN
--

-- message('ROUT','entry:ben_dm_utility.seed_table_order', 5);
-- message('PARA','(p_table_name - ' || p_table_name ||'), 10);
-- get_table_id

l_table_id := get_table_id(p_table_name);

-- Add some check to make sure there is no duplicate table entries
-- together with order no.

    INSERT into ben_dm_table_order
    (table_order_id
    ,table_id
    ,table_order
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,created_by
    ,creation_date)
    VALUES
    (ben_dm_table_order_s.nextval
    ,l_table_id
    ,p_order_no
    ,sysdate
    ,1
    ,1
    ,1
    ,sysdate);

-- message('INFO','seed_table_order', 15);
-- message('SUMM','seed_table_order', 20);
-- message('ROUT','exit:ben_dm_utility.seed_table_order', 25);
-- message('PARA','(p_table_name - ' || p_table_name ||'), 10);

-- error handling
EXCEPTION
WHEN OTHERS THEN
 -- error(SQLCODE,'ben_dm_utility.seed_column_maping','(none)','R');
  RAISE;
--
END seed_table_order;
--

-- ------------------------- ins_hir --------------------
-- Description: Seeds hierarchy information into
-- BEN_DM_HIERARCHY table.
--
--
--  Input Parameters
--        p_table_name            - Table Name
--        p_parent_table_name     - Parent Table
--        p_column_name           - Column Name
--        p_parent_column_name    - Parent Column Name
--        p_parent_id_column_name - Surrogate ID Column Name
--
--  Output Parameters
--        <none>
--
-- ------------------------------------------------------------------------
-- insert into hierarchy table
PROCEDURE ins_hir (p_table_name                   varchar2,
                    p_parent_table_name            varchar2 default null,
                    p_column_name                  varchar2 default null,
                    p_parent_column_name           varchar2 default null,
                    p_parent_id_column_name        varchar2 default null,
                    p_hierarchy_type               varchar2 default 'PC') is

  l_table_id               ben_dm_hierarchies.table_id%type;
  l_column_name            ben_dm_hierarchies.column_name%type;
  l_parent_table_name      ben_dm_hierarchies.parent_table_name%type;
  l_parent_column_name     ben_dm_hierarchies.parent_column_name%type;
  l_parent_id_column_name  ben_dm_hierarchies.parent_id_column_name%type;
  l_hierarchy_type         ben_dm_hierarchies.hierarchy_type%type;

 BEGIN

    l_table_id               := get_table_id(p_table_name );
    l_column_name            := p_column_name;
    l_parent_table_name      := p_parent_table_name;
    l_parent_column_name     := p_parent_column_name;
    l_hierarchy_type         := p_hierarchy_type;

    -- for table hierarchy if the joining column name is same in parent and
    -- child table then copy the child column name.
    if l_parent_column_name is null and  l_hierarchy_type = 'PC' then
       l_parent_column_name := p_column_name;
    end if;

    l_parent_id_column_name  := p_parent_id_column_name;

    -- insert into hr_dm_hierarchy table.
    insert into ben_dm_hierarchies
               ( hierarchy_id
                ,hierarchy_type
                ,table_id
                ,column_name
                ,parent_table_name
                ,parent_column_name
                ,parent_id_column_name
                ,last_update_date
                ,last_updated_by
                ,last_update_login
                ,created_by
                ,creation_date )
         select  ben_dm_hierarchies_s.nextval
                ,l_hierarchy_type
                ,l_table_id
                ,l_column_name
                ,l_parent_table_name
                ,l_parent_column_name
                ,l_parent_id_column_name
                ,sysdate
                ,1
                ,1
                ,1
                ,sysdate
         from  dual
         where not exists (select 'x'
                           from ben_dm_hierarchies hir
                           where hir.hierarchy_type = l_hierarchy_type
                           and hir.table_id = l_table_id
                           and nvl(hir.column_name,'X') =  nvl(l_column_name,
                                                              'X')
                           and nvl(hir.parent_table_name,-99) = nvl(l_parent_table_name,
                                                                  -99)
                           and nvl(hir.parent_column_name,'X') = nvl(l_parent_column_name,
                                                                    'X')
                           and nvl(hir.parent_id_column_name,'X') = nvl(l_parent_id_column_name,
                                                                       'X')
                          );
     if sql%rowcount = 0 then
       hr_utility.trace('''' || l_hierarchy_type || ''' - '  || p_table_name ||
                        ' - ' || l_column_name || ' - ' || p_column_name ||
                        '  (' || p_parent_table_name || ' - ' || p_parent_column_name ||
                            ')  ( Data not seeded as it already exists)');
     end if;
  exception

   when others then
           hr_utility.trace(sqlerrm(sqlcode) || '''' || l_hierarchy_type
                                || ''' - '  || p_table_name );
  END ins_hir;


end ben_dm_utility;

/
