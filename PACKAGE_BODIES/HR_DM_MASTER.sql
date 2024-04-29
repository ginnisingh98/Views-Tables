--------------------------------------------------------
--  DDL for Package Body HR_DM_MASTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_MASTER" AS
/* $Header: perdmmas.pkb 120.0 2005/05/31 17:11:52 appldev noship $ */


/*-------------------------- PRIVATE ROUTINES ----------------------------*/

-- ------------------------- controller_init ------------------------
-- Description: Various initialization processes are undertaken:
--  a) ensuring that data for the migration exists in hr_dm_migrations
--  b) entries in hr_dm_migration_requests are marked as inactive
--  c) r_migration_data is seeded with information about the migration
--  d) the migration count is incremented
--  e) the validity of the migration is checked
--  f) the migration status is set to started
--
--
--  Input Parameters
--        p_migration_id   - migration id
--
--        r_migration_data - record containing migration information
--
--        p_request_data   - concurrent request data (contains previous
--                           phase code - if it was a concurrent phase)
--
--
--  Output Parameters
--        r_migration_data - record containing migration information
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE controller_init(p_migration_id IN NUMBER,
                          r_migration_data IN OUT
                                             hr_dm_utility.r_migration_rec,
                          p_request_data IN VARCHAR2) IS
--

l_current_phase_status VARCHAR2(30);
l_migration_type VARCHAR2(30);
l_application_id NUMBER;
l_migration_id NUMBER;
l_database_name VARCHAR2(30);
l_source_database_name VARCHAR2(30);
l_destination_database_name VARCHAR2(30);
l_last_migrated_date DATE;
l_phase_flag VARCHAR2(1);
l_migration_count NUMBER;
l_business_group_id NUMBER;
l_valid_migration VARCHAR2(1);
e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);
l_database_location VARCHAR2(30);
l_phase_name VARCHAR2(30);
l_status VARCHAR2(30);
l_migration_date DATE;


CURSOR csr_migration IS
  SELECT MIGRATION_ID, UPPER(SOURCE_DATABASE_INSTANCE),
         UPPER(DESTINATION_DATABASE_INSTANCE),
         MIGRATION_TYPE, APPLICATION_ID, MIGRATION_COUNT, BUSINESS_GROUP_ID,
         STATUS
    FROM hr_dm_migrations
    WHERE (migration_id = p_migration_id);

CURSOR csr_migration_request IS
  SELECT MAX(creation_date)
    FROM hr_dm_migration_requests
    WHERE (migration_id = p_migration_id);


CURSOR csr_database IS
  SELECT UPPER(name)
    FROM v$database;

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_master.controller_init', 5);
hr_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id ||
                      ')(r_migration_data - record' ||
                      ')(p_request_data - ' || p_request_data || ')', 10);


-- identify the migration type, current database and application id
OPEN csr_migration;
LOOP
  FETCH csr_migration INTO l_migration_id, l_source_database_name,
                           l_destination_database_name,
                           l_migration_type, l_application_id,
                           l_migration_count,
                           l_business_group_id, l_status;
  EXIT WHEN csr_migration%NOTFOUND;
END LOOP;
CLOSE csr_migration;

-- raise error if no matching row in hr_dm_migrations
IF (l_migration_id IS NULL) THEN
  l_fatal_error_message := 'No row identified in HR_DM_MIGRATIONS!';
  RAISE e_fatal_error;
END IF;


-- set all the enabled flags to N for the current migration_request_id
-- except for the current run of the migration
--  (non-paused)
IF (p_request_data IS NULL) THEN
  OPEN csr_migration_request;
  FETCH csr_migration_request INTO l_migration_date;
  CLOSE csr_migration_request;

  UPDATE hr_dm_migration_requests
    SET enabled_flag = 'N'
      WHERE ((migration_id = p_migration_id)
        AND (creation_date <> l_migration_date));

  COMMIT;

  END IF;


OPEN csr_database;
LOOP
  FETCH csr_database INTO l_database_name;
  EXIT WHEN csr_database%NOTFOUND;
END LOOP;
CLOSE csr_database;

IF (l_database_name = l_destination_database_name) THEN
  l_database_location := 'D';
END IF;
IF (l_database_name = l_source_database_name) THEN
  l_database_location := 'S';
END IF;

-- seed data into record
r_migration_data.migration_id := p_migration_id;
r_migration_data.migration_type  := l_migration_type;
r_migration_data.database_location  := l_database_location;
r_migration_data.application_id  := l_application_id;
r_migration_data.business_group_id  := l_business_group_id;
r_migration_data.source_database_instance := l_source_database_name;
r_migration_data.destination_database_instance :=
                                        l_destination_database_name;
r_migration_data.last_migration_date  :=
                           hr_dm_business.last_migration_date(
                                                    r_migration_data);

-- increment migration count in hr_dm_migrations (non-paused)
IF (p_request_data IS NULL) THEN
  UPDATE hr_dm_migrations
    SET migration_count = l_migration_count+1
    WHERE migration_id = p_migration_id;
  COMMIT;
END IF;

-- check if migration is valid / warning
-- (first run only)
IF (p_request_data IS NULL) THEN
  l_valid_migration := hr_dm_business.validate_migration(r_migration_data);
  IF (l_valid_migration = 'E') THEN
-- raise error
    l_fatal_error_message := 'Invalid migration - business rule broken';
    hr_dm_utility.update_migrations(p_new_status => 'E',
                                    p_id => p_migration_id);
    RAISE e_fatal_error;
  END IF;
END IF;

-- update status of migration to started (un-paused)
IF (NVL(p_request_data, '?') = '?') THEN
  hr_dm_utility.update_migrations(p_new_status => 'S',
                                  p_id => p_migration_id);
END IF;


hr_dm_utility.message('INFO','Main controller initialized', 15);
hr_dm_utility.message('SUMM','Main controller initialized', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_master.controller_init', 25);
hr_dm_utility.message('PARA','(none)', 30);



-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_range.main_controller',
                      l_fatal_error_message,'R');
  report_error(l_phase_name, p_migration_id,
               l_fatal_error_message ||
               ' in hr_dm_master.main_controller', 'M');
  RAISE;
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_master.main_controller',
                      '(none)','R');
  report_error(l_phase_name, p_migration_id,
               'Untrapped error in hr_dm_master.main_controller', 'M');
  RAISE;


--
END controller_init;
--

-- ------------------------- insert_request ------------------------
-- Description: Inserts the details of a concurrent manager request into
-- the table hr_dm_migration_requests.
--
--
--  Input Parameters
--        p_phase          - phase code
--
--        p_request_id     - concurrent manager request id
--
--        p_migration_id   - migration id
--
--        p_phase_id       - for a slave request
--
--        p_phase_item_id  - for a slave request from a slave
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE insert_request(p_phase IN VARCHAR2,
                         p_request_id IN NUMBER,
                         p_master_slave IN VARCHAR2 DEFAULT 'S',
                         p_migration_id IN NUMBER,
                         p_phase_id IN NUMBER DEFAULT NULL,
                         p_phase_item_id IN NUMBER DEFAULT NULL) IS
--

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_master.insert_request', 5);
hr_dm_utility.message('PARA','(p_phase - ' || p_phase ||
                      ')(p_request_id - ' || p_request_id ||
                      ')(p_master_slave - ' || p_master_slave ||
                      ')(p_migration_id - ' || p_migration_id ||
                      ')(p_phase_id - ' || p_phase_id ||
                      ')(p_phase_item_id - ' || p_phase_item_id || ')', 10);


INSERT INTO hr_dm_migration_requests (migration_request_id,
                                      migration_id,
                                      phase_id,
                                      phase_item_id,
                                      request_id,
                                      enabled_flag,
                                      master_slave,
                                      last_updated_by,
                                      last_update_date,
                                      last_update_login,
                                      creation_date,
                                      created_by)
  SELECT hr_dm_migration_requests_s.nextval,
         p_migration_id,
         p_phase_id,
         p_phase_item_id,
         p_request_id,
         'Y',
         p_master_slave,
         1,
         sysdate,
         1,
         sysdate,
         1
    FROM sys.dual
    WHERE NOT EXISTS
      (SELECT NULL FROM hr_dm_migration_requests
         WHERE request_id = p_request_id);

COMMIT;

hr_dm_utility.message('INFO','Inserted into hr_dm_migration_requests', 15);
hr_dm_utility.message('SUMM','Inserted into hr_dm_migration_requests', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_master.insert_request', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_master.insert_request','(none)','R');
  RAISE;


--
END insert_request;
--


-- ------------------------- spawn_slaves ------------------------
-- Description: The appropriate concurrent program for the current phase
-- is spawned and details recorded (by calling insert_request).
--
--
--  Input Parameters
--        p_current_phase  - phase code
--
--        r_migration_data - record containing migration information
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE spawn_slaves(p_current_phase IN VARCHAR2,
                       r_migration_data IN hr_dm_utility.r_migration_rec) IS
--

l_counter NUMBER;
l_request_id NUMBER;
e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);
l_slave_program VARCHAR2(30);
l_phase_id NUMBER;
l_threads NUMBER;


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_master.spawn_slaves', 5);
hr_dm_utility.message('PARA','(p_current_phase - ' || p_current_phase ||
                      ')(r_migration_data - record)', 10);


-- set up name for appropriate concurrent slave
l_slave_program := 'HRDMSLV' || p_current_phase;

-- get the current phase_id
l_phase_id := hr_dm_utility.get_phase_id(p_current_phase,
                                         r_migration_data.migration_id);

-- find the number of threads to use
l_threads := hr_dm_utility.number_of_threads(
                                    r_migration_data.business_group_id);
-- only single thread for UP phase
IF (p_current_phase = 'UP') THEN
  l_threads := 1;
END IF;

-- only single thread for UA phase
IF (p_current_phase = 'UA') THEN
  l_threads := 1;
END IF;

-- only single thread for C phase
IF (p_current_phase = 'C') THEN
  l_threads := 1;
END IF;

-- set current processing
hr_dm_utility.set_process(l_threads || ' slaves',
                          p_current_phase,
                          r_migration_data.migration_id);


FOR l_counter IN 1..l_threads LOOP
  hr_dm_utility.message('INFO','Spawning slave #' || l_counter, 16);


  l_request_id := fnd_request.submit_request(
                      application => 'PER',
                      program     => l_slave_program,
                      sub_request => TRUE,
                      argument1 => TO_CHAR(r_migration_data.migration_id),
                      argument2 => 'Y',
                      argument3 =>
                            TO_CHAR(r_migration_data.last_migration_date),
                      argument4 => TO_CHAR(l_counter));


  -- update table hr_dm_migration_requests
  insert_request(p_phase => p_current_phase,
                 p_request_id => l_request_id,
                 p_master_slave => 'S',
                 p_migration_id => r_migration_data.migration_id,
                 p_phase_id => l_phase_id);

  COMMIT;
  hr_dm_utility.message('INFO','Slave request ID#' || l_request_id, 17);
  IF (l_request_id = 0) THEN
      l_fatal_error_message := 'Unable to start slave process';
      report_error(p_current_phase, r_migration_data.migration_id,
                   l_fatal_error_message, 'P');
      RAISE e_fatal_error;
  END IF;
END LOOP;

hr_dm_utility.message('INFO','Spawned slaves', 15);
hr_dm_utility.message('SUMM','Spawned slaves', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_master.spawn_slaves', 25);
hr_dm_utility.message('PARA','(none)', 30);



-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_master.spawn_slaves',
                      l_fatal_error_message,'R');
  report_error(p_current_phase, r_migration_data.migration_id,
               'Error in hr_dm_master.spawn_slaves', 'P');
  RAISE;
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_master.spawn_slaves','(none)','R');
  report_error(p_current_phase, r_migration_data.migration_id,
               'Untrapped error in hr_dm_master.spawn_slaves', 'P');
  RAISE;

--
END spawn_slaves;
--

-- ------------------------- slave_status ------------------------
-- Description: The status of all slaves submitted for the passed phase
-- are checked to ensure that all have completed normally, otherwise
-- the return value is set to Y.
--
--
--  Input Parameters
--        p_current_phase  - phase code
--
--        r_migration_data - record containing migration information
--
--
--  Return Values
--        slave status - Y = one or more slaves errored
--                       N = no slaves errored
--
--
-- ------------------------------------------------------------------------

--
FUNCTION slave_status(p_current_phase IN VARCHAR2,
                      r_migration_data IN hr_dm_utility.r_migration_rec)
                     RETURN VARCHAR2 IS
--

l_slave_status VARCHAR2(1);
l_slave_error VARCHAR2(1) := 'N';
l_call_status BOOLEAN;
l_phase VARCHAR2(30);
l_status VARCHAR2(30);
l_dev_phase VARCHAR2(30);
l_dev_status VARCHAR2(30);
l_message VARCHAR2(240);
l_request_id NUMBER;
l_phase_id NUMBER;

CURSOR csr_requests IS
  SELECT request_id
    FROM hr_dm_migration_requests
    WHERE ((phase_id = l_phase_id)
      AND (master_slave = 'S')
      AND (enabled_flag = 'Y'));


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_master.slave_status', 5);
hr_dm_utility.message('PARA','(p_current_phase - ' || p_current_phase ||
                  ')(r_migration_data - record)', 10);

-- get the current phase_id
l_phase_id := hr_dm_utility.get_phase_id(p_current_phase,
                                         r_migration_data.migration_id);

-- check if a slave has errored
OPEN csr_requests;
LOOP
  FETCH csr_requests INTO l_request_id;
  EXIT WHEN csr_requests%NOTFOUND;

  l_call_status := fnd_concurrent.get_request_status(l_request_id, '', '',
                                l_phase, l_status, l_dev_phase,
                                l_dev_status, l_message);
-- make sure that each slave is complete and normal, if not then log
  IF ( NOT( (l_dev_phase = 'COMPLETE') AND (l_dev_status = 'NORMAL') )) THEN
    l_slave_error := 'Y';
  END IF;

END LOOP;
CLOSE csr_requests;


hr_dm_utility.message('INFO','Slave status request', 15);
hr_dm_utility.message('SUMM','Slave status request', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_master.spawn_slaves', 25);
hr_dm_utility.message('PARA','(l_slave_error - ' || l_slave_error ||
                      ')', 30);


RETURN(l_slave_error);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_master.slave_status','(none)','R');
  report_error(p_current_phase, r_migration_data.migration_id,
               'Untrapped error in hr_dm_master.slave_status', 'P');
  RAISE;

--
END slave_status;
--

-- ------------------------- report_error ------------------------
-- Description: Reports the fact that an error has occurred and updates
-- the status of the phase / migration as appropriate.
--
--
--  Input Parameters
--        p_current_phase - phase code
--
--        p_migration     - migration id
--
--        p_error_message - error text
--
--        p_stage         - P = error occurred in a phase
--                          M = error occured in migration
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE report_error(p_current_phase IN VARCHAR2,
                       p_migration IN NUMBER,
                       p_error_message IN VARCHAR2,
                       p_stage IN VARCHAR2
                       ) IS
--

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_master.report_error', 5);
hr_dm_utility.message('PARA','(p_current_phase - ' || p_current_phase ||
                  ')(p_migration - ' || p_migration ||
                  ')(p_error_message - ' || p_error_message ||
                  ')(p_stage - ' || p_stage || ')', 10);


-- update status to show error (E)
-- update approriate phase, migration, etc.
IF (p_stage = 'P') THEN
  hr_dm_utility.update_phases(p_new_status => 'E',
                              p_id => hr_dm_utility.get_phase_id(
                                             p_current_phase, p_migration));
END IF;

IF (p_stage = 'M') THEN
  hr_dm_utility.update_migrations(p_new_status => 'E', p_id => p_migration);
END IF;


hr_dm_utility.message('INFO','Error reported', 15);
hr_dm_utility.message('SUMM','Error reported', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_master.report_error', 25);
hr_dm_utility.message('PARA','(none)', 30);


--
END report_error;
--

-- ------------------------- work_required ------------------------
-- Description: A check is made to see if for the phase passed if there
-- are any phase items which do not have a status of C. If all have the
-- status C then the phase is marked as completed. Where a phase links
-- to migration ranges then these are also checked to see if for a
-- phase item that there are ranges to process.
--
--
--  Input Parameters
--        p_current_phase  - phase code
--
--        r_migration_data - record containing migration information
--
--
--  Return Values
--        work required - Y = phase items to process
--                        N = phase items to process
--
--
-- ------------------------------------------------------------------------

--
FUNCTION work_required(p_current_phase IN VARCHAR2,
                       r_migration_data IN hr_dm_utility.r_migration_rec)
                      RETURN VARCHAR2 IS
--

l_work VARCHAR2(1);
l_phase_id NUMBER;
l_range_phase_id NUMBER;
l_required NUMBER;
l_phase_item_id NUMBER;
l_group_id NUMBER;

CURSOR csr_phase_items IS
  SELECT NULL
    FROM hr_dm_phase_items
    WHERE phase_id = l_phase_id
      AND status <> 'C';

CURSOR csr_ddp_pi IS
  SELECT phase_item_id, group_id
    FROM hr_dm_phase_items
    WHERE phase_id = l_phase_id;

CURSOR csr_mig_ranges IS
  SELECT rpi.phase_item_id
    FROM hr_dm_phase_items rpi,
         hr_dm_migration_ranges mr
    WHERE rpi.group_id = l_group_id
      AND rpi.phase_id = l_range_phase_id
      AND rpi.phase_item_id = mr.phase_item_id
      AND mr.status <> 'C';


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_master.work_required', 5);
hr_dm_utility.message('PARA','(p_current_phase - ' || p_current_phase ||
                      ')(r_migration_data - record)', 10);

-- get the current phase_id
l_phase_id := hr_dm_utility.get_phase_id(p_current_phase,
                                         r_migration_data.migration_id);

l_work := 'Y';

-- check if any phase items to process (not DP or D phases)
IF (p_current_phase IN ('G', 'R', 'DA', 'UA', 'UP', 'C')) THEN
  OPEN csr_phase_items;
  FETCH csr_phase_items INTO l_required;
  IF (csr_phase_items%NOTFOUND) THEN
    hr_dm_utility.message('INFO','No work required for phase ' ||
                          p_current_phase, 11);
    l_work := 'N';
    hr_dm_utility.update_phases(p_new_status => 'C',
                                p_id => l_phase_id);
  END IF;
  CLOSE csr_phase_items;
END IF;


-- check phase items for DP or D phases to see if any migration ranges
-- to process
IF (p_current_phase IN ('DP', 'D')) THEN
  hr_dm_utility.message('INFO','checking DP/D - ' || p_current_phase, 5);
-- get the range phase_id
  l_range_phase_id := hr_dm_utility.get_phase_id('R',
                                            r_migration_data.migration_id);
  hr_dm_utility.message('INFO','l_range_phase_id - ' || l_range_phase_id, 5);
-- find phase_item_id for D/DP phase
  OPEN csr_ddp_pi;
  LOOP
    FETCH csr_ddp_pi INTO l_phase_item_id, l_group_id;
hr_dm_utility.message('INFO','l_phase_item_id - ' || l_phase_item_id, 5);
hr_dm_utility.message('INFO','l_group_id - ' || l_group_id, 5);
    EXIT WHEN csr_ddp_pi%NOTFOUND;

-- see if any migration ranges to process for this phase_item_id
    OPEN csr_mig_ranges;
    FETCH csr_mig_ranges INTO l_required;
hr_dm_utility.message('INFO','l_required - ' || l_required, 5);
    IF (csr_mig_ranges%NOTFOUND) THEN
-- mark phase item as started and then complete to ensure that
-- the start and end times are set
    hr_dm_utility.message('INFO','No work required for group ' ||
                          l_group_id, 12);

      hr_dm_utility.update_phase_items(p_new_status => 'S',
                                       p_id => l_phase_item_id);
      hr_dm_utility.update_phase_items(p_new_status => 'C',
                                       p_id => l_phase_item_id);
    END IF;
    CLOSE csr_mig_ranges;

  END LOOP;
  CLOSE csr_ddp_pi;

-- see if any phase items to process
-- ie if csr_ddp_pi does not find any phase items
  IF (l_phase_item_id IS NULL) THEN
    hr_dm_utility.message('INFO','No work required for phase ' ||
                          p_current_phase, 13);
    l_work := 'N';
    hr_dm_utility.update_phases(p_new_status => 'C',
                                p_id => l_phase_id);
  END IF;

-- see if phase is complete
  IF (hr_dm_utility.get_phase_status(p_current_phase,
                                 r_migration_data.migration_id) = 'C') THEN
    l_work := 'N';
  END IF;

END IF;


hr_dm_utility.message('INFO','Check work required for phase', 15);
hr_dm_utility.message('SUMM','Check work required for phase', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_master.work_required', 25);
hr_dm_utility.message('PARA','(l_work - ' || l_work || ')', 30);

RETURN(l_work);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_master.work_required','(none)','R');
  report_error(p_current_phase, r_migration_data.migration_id,
               'Untrapped error in hr_dm_master.work_required', 'P');
  RAISE;

--
END work_required;
--



-- ------------------------------- master ------------------------------
-- Description: This procedure calls the code appropriate for a phase
-- which is processed by multiple threads. There are two paths through
-- the code, dependent upon if the procedure is called at the start of
-- a phase or after the main controller has been awoken after the slaves
-- have finished processing. This is determined by examining the
-- concurrent request data which will contain the phase code for a
-- re-awoken phase and null for a first run.
--
-- On a first run (l_request_data = null) the status of the previous phase
-- is checked to ensure that it has completed. If not then the migration
-- status is set to error and the procedure exits.
--
-- A check is made to see if the current phase has either started or errored
-- in which case a rollback of the phase (if applicable) is performed.
--
-- The status of the phase is set to started and any phase specific
-- pre-processing code is called.
--
-- A check is made to see if there is any work to be performed by the phase
-- if so, slaves are spawned to perform the work and the main controller
-- is paused.
--
--
--
-- On a non-first run (l_request_data <> null), the request data is first
-- set to ? (equivelent to null) the status of the current phase
-- is checked to ensure that it has completed. If not then the migration
-- status is set to error and the procedure exits.
--
-- A check is made of the status of each slave and if any have not completed
-- normally then a warning message is logged.
--
-- Any phase specific post-processing code is called.
--
--
--
--  Input Parameters
--        p_current_phase  - phase code
--
--        p_previous_phase - phase code
--
--        r_migration_data - migration record
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE master(p_current_phase IN VARCHAR2,
                 p_previous_phase IN VARCHAR2,
                 r_migration_data IN hr_dm_utility.r_migration_rec) IS
--

l_current_phase_status VARCHAR2(30);
e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);
l_request_data VARCHAR2(30);
l_dummy VARCHAR2(1);


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_master.master', 5);
hr_dm_utility.message('PARA','(p_current_phase - ' || p_current_phase ||
                  ')(p_previous_phase - ' || p_previous_phase ||
                  ')(r_migration_data - record)', 10);

-- see if this is the first run? (l_request_data = NULL or '?')
-- or
-- is it a restart after slaves have finished? (l_request_data =
--                                                       paused phase code)
l_request_data := fnd_conc_global.request_data;

hr_dm_utility.message('INFO','l_request_data ' || l_request_data, 11);
IF (NVL(l_request_data, '?') = '?') THEN
-- first run processing...

hr_dm_utility.message('INFO','First run processing (pre-pause)', 12);

-- get status of previous phase, is previous phase completed?
-- for the first phase there is no previous phase, so check for
-- a NULL previous to bypass this check
  IF ((hr_dm_utility.get_phase_status(p_previous_phase,
                                      r_migration_data.migration_id) <> 'C')
       AND (p_previous_phase IS NOT NULL) ) THEN
    l_fatal_error_message := 'Previous phase has not completed';
    report_error(p_current_phase, r_migration_data.migration_id,
                 l_fatal_error_message, 'P');
    RAISE e_fatal_error;
  END IF;

-- get status of current phase
  l_current_phase_status := hr_dm_utility.get_phase_status(p_current_phase,
                              r_migration_data.migration_id);

-- is phase complete?
  IF (l_current_phase_status <> 'C') THEN
-- do we need to explicitly rollback using rollback utility?
    IF ( (l_current_phase_status IN('S', 'E')) AND
         (p_current_phase IN('I', 'G', 'R', 'DP', 'DA', 'UA',
                             'UP', 'C', 'D')) ) THEN
      hr_dm_utility.rollback(p_phase => p_current_phase,
                             p_masterslave => 'MASTER',
                             p_migration_id =>
                                          r_migration_data.migration_id);
    END IF;

-- update status to started
    hr_dm_utility.update_phases(p_new_status => 'S',
                              p_id => hr_dm_utility.get_phase_id(
                                            p_current_phase,
                                            r_migration_data.migration_id));
    COMMIT;


-- call phase specific pre-processing code

-- generate phase
-- create dummy hr_dmv views to avoid compilation errors
  IF (p_current_phase = 'G') THEN
    hr_dm_utility.set_process('Pre-processing',
                              p_current_phase,
                              r_migration_data.migration_id);
    hr_dm_library.create_stub_views(r_migration_data.migration_id);
  END IF;



-- delete phase
-- set current processing
  IF (p_current_phase = 'D') THEN
    hr_dm_utility.set_process('Pre-processing',
                              p_current_phase,
                              r_migration_data.migration_id);
    hr_dm_delete.set_active(r_migration_data.migration_id);
    hr_dm_delete.pre_delete_process(r_migration_data);
  END IF;


-- spawn off slaves if work to be done
  IF (work_required(p_current_phase, r_migration_data) = 'Y') THEN
      spawn_slaves(p_current_phase, r_migration_data);

-- pause master whilst slaves process data...
-- set request data to indicate paused phase
      fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                      request_data => p_current_phase);

  END IF;




  END IF;

ELSE
-- processing after being woken up
hr_dm_utility.message('INFO','Unpaused processing', 13);
-- set request data to indicate un-paused phase
  fnd_conc_global.set_req_globals(request_data => '?');


-- first force check for all required work
  l_dummy := work_required(p_current_phase, r_migration_data);

-- get status of current phase
  l_current_phase_status := hr_dm_utility.get_phase_status(p_current_phase,
                                             r_migration_data.migration_id);

-- is it completed?
  IF (l_current_phase_status <> 'C') THEN
    l_fatal_error_message := 'Current phase has not completed';
    report_error(p_current_phase, r_migration_data.migration_id,
                 l_fatal_error_message, 'P');
    RAISE e_fatal_error;
  END IF;

-- has any slave errored?
-- if so, add warning message to log
  IF (slave_status(p_current_phase, r_migration_data) = 'Y') THEN
    hr_dm_utility.message('INFO', 'Warning - ' || p_current_phase ||
                          ' phase slave process errored', 13);
  END IF;

-- call phase specific post processing code
  IF (p_current_phase = 'G') THEN
-- set current processing
    hr_dm_utility.set_process('Post-processing',
                              p_current_phase,
                              r_migration_data.migration_id);
    hr_dm_gen_main.post_generate_validate(r_migration_data.migration_id);
  END IF;

  IF (p_current_phase = 'C') THEN
-- set current processing
    hr_dm_utility.set_process('Post-processing',
                              p_current_phase,
                              r_migration_data.migration_id);
    hr_dm_cleanup.post_cleanup_process(r_migration_data);
  END IF;



  IF (p_current_phase = 'UP') THEN
-- update flexfield information
-- for FW and A migrations only
    IF (r_migration_data.migration_type IN ('FW','A')) THEN
-- Set the variable so as to disable the trigger on the table.
      hr_general.g_data_migrator_mode := 'Y';
      hr_dm_aol_up.post_aol_process(r_migration_data.migration_id);
    END IF;
-- flush BEN_COMP_OBJ_CACHE
-- only for FW and A migrations for OAB product (id=805)
-- commented out - manual step
/*
    IF (r_migration_data.migration_type IN ('FW','A'))
      AND (r_migration_data.application_id = 805) THEN
-- Set the variable so as to disable the trigger on the table.
      ben_comp_object_list.flush_multi_session_cache
        (p_business_group_id => r_migration_data.business_group_id);
    END IF;
*/
  END IF;


END IF;

hr_dm_utility.message('INFO','Master concurrent program', 15);
hr_dm_utility.message('SUMM','Master concurrent program', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_master.master', 25);
hr_dm_utility.message('PARA','(none)', 30);



-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_range.master',
                      l_fatal_error_message,'R');
  report_error(p_current_phase, r_migration_data.migration_id,
              'Untrapped error in hr_dm_master.master', 'P');
  RAISE;
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_master.master','(none)','R');
  report_error(p_current_phase, r_migration_data.migration_id,
              'Untrapped error in hr_dm_master.master', 'P');
  RAISE;
--
END master;
--






/*---------------------------- PUBLIC ROUTINES --------------------------*/

-- ------------------------- main_controller ------------------------
-- Description: This is the main controller for the DM which is called
-- from the DM UI. It calls the required phases for the migration.
--
-- A check is made to see if the code is running for the first time or has
-- been re-awoken.
--
-- The initialization code is called to set up various details (see the
-- controller_init procedure).
--
-- The next phase to be process is found using the hr_dm_phase_rules table
-- and the appropriate single or multi-threaded code is called.
--
-- If a multi-threaded process has spawned slaves then the main controller
-- exits (to enable it to be awoken later). Otherwise it runs the next
-- phase until all phases have been completed.
--
--
--  Input Parameters
--        p_migration_id        - of current migration
--
--
--  Output Parameters
--        errbuf  - buffer for output message (for CM manager)
--
--        retcode - program return code (for CM manager)
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE main_controller(errbuf OUT NOCOPY VARCHAR2,
                          retcode OUT NOCOPY NUMBER,
                          p_migration_id IN BINARY_INTEGER) IS
--

l_search_phase VARCHAR2(30);
l_next_phase VARCHAR2(30);
l_phase_name VARCHAR2(30);
l_previous_phase VARCHAR2(30);
l_previous VARCHAR2(30);
e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);
r_migration_data hr_dm_utility.r_migration_rec;
l_database_location VARCHAR2(30);
l_request_data VARCHAR2(30);
l_mig_status VARCHAR2(30);


CURSOR csr_phase_rule IS
  SELECT phase_name, next_phase, database_location
    FROM hr_dm_phase_rules
    WHERE ((migration_type = r_migration_data.migration_type)
      AND (previous_phase = l_search_phase));

CURSOR csr_paused_phase_rule IS
  SELECT previous_phase, next_phase
    FROM hr_dm_phase_rules
    WHERE ((migration_type = r_migration_data.migration_type)
      AND (phase_name = l_request_data));

CURSOR csr_mig_status IS
  SELECT status
    FROM hr_dm_migrations
    WHERE migration_id = r_migration_data.migration_id;


--
BEGIN
--

-- initialize messaging
hr_dm_utility.message_init;

hr_dm_utility.message('ROUT','entry:hr_dm_master.main_controller', 5);
hr_dm_utility.message('PARA','(p_migration_id - ' ||
                      p_migration_id || ')', 10);


-- see if this is a migration run (l_request_data = NULL)
-- OR
-- is it a restart after slaves have finished? (l_request_data =
--                                                    paused phase code)
l_request_data := fnd_conc_global.request_data;
hr_dm_utility.message('INFO','Request data - ' || l_request_data, 12);

-- initialize main controller data
controller_init(p_migration_id,
                r_migration_data,
                l_request_data);

-- work out phases applicable to this migration
--
IF (l_request_data IS NULL) THEN
-- seed first phase
  l_search_phase := 'START';
  l_next_phase := '?';
ELSE
-- seed with data for paused phase
  OPEN csr_paused_phase_rule;
  LOOP
    FETCH csr_paused_phase_rule INTO l_search_phase, l_next_phase;
    EXIT WHEN csr_paused_phase_rule%NOTFOUND;
  END LOOP;
  CLOSE csr_paused_phase_rule;
END IF;

-- seed previous phase name
l_previous := 'START';

WHILE (l_next_phase <> 'END') LOOP
  OPEN csr_phase_rule;
  FETCH csr_phase_rule INTO l_phase_name, l_next_phase,
                            l_database_location;
  EXIT WHEN csr_phase_rule%NOTFOUND;

-- does it apply?
  IF (INSTR(l_database_location, r_migration_data.database_location) >0) THEN

  hr_dm_utility.message('INFO','Current phase is ' || l_phase_name, 11);
  hr_dm_utility.message('INFO','Request data - ' ||
                        NVL(l_request_data, '?'), 12);

-- store the previous phase that applies
  l_previous_phase := l_previous;
  hr_dm_utility.message('INFO','Previous phase is ' || l_previous_phase, 11);



-- is it completed or not awoken?
-- if not, then run appropriate phase code
    IF ((hr_dm_utility.get_phase_status(l_phase_name, p_migration_id) <> 'C')
       OR (NVL(l_request_data, '?') <> '?')) THEN

-- call generic master code
      IF (l_phase_name IN ('G', 'R', 'DA', 'DP', 'UA', 'UP', 'D', 'C')) THEN
        master(l_phase_name, l_previous_phase, r_migration_data);
      ELSE
-- call non-generic master code
        IF (l_phase_name = 'I') THEN
-- set current processing
          hr_dm_utility.set_process('Single threaded',
                                    l_phase_name,
                                    r_migration_data.migration_id);
          hr_dm_init.main(r_migration_data);
        ELSIF (l_phase_name = 'CP') THEN
-- mark copy as started
-- set current processing
          hr_dm_utility.set_process('Single threaded',
                                    l_phase_name,
                                    r_migration_data.migration_id);
          hr_dm_utility.update_phases(p_new_status => 'S',
                                      p_id => hr_dm_utility.get_phase_id('CP'
                                        , r_migration_data.migration_id));
-- perform source copy on source database only
          IF (r_migration_data.database_location = 'S') THEN
            hr_dm_copy.source_copy(r_migration_data.migration_id,
                                   r_migration_data.last_migration_date);
          END IF;
-- now let the user proceed with the manual copy,
-- so mark the current migration as complete (on source database)
            hr_dm_utility.update_phases(p_new_status => 'C',
                                     p_id => hr_dm_utility.get_phase_id('CP'
                                          , r_migration_data.migration_id));
-- and then the user must update the status to complete when manual copy
-- process has been completed
        END IF;

      END IF;

-- have we paused the main controller?
-- if so, exit loop
      l_request_data := fnd_conc_global.request_data;
      EXIT WHEN NVL(l_request_data, '?') <> '?';

-- did it complete? if not then update status and raise an error
      IF (hr_dm_utility.get_phase_status(l_phase_name, p_migration_id)
                                                               <> 'C') THEN
-- update status of migration to error
        hr_dm_utility.update_migrations(p_new_status => 'E',
                                        p_id => p_migration_id);
        COMMIT;
-- raise error
        l_fatal_error_message := 'Error in ' || l_phase_name || ' phase';
        report_error(l_phase_name, p_migration_id, l_fatal_error_message,
                     'M');
        RAISE e_fatal_error;
      END IF;

    END IF;

-- store current applicable phase name for next iteration
    l_previous := l_phase_name;
  END IF;
  l_search_phase := l_phase_name;
  CLOSE csr_phase_rule;
END LOOP;


-- set up return values to concurrent manager
retcode := 0;
IF (NVL(l_request_data, '?') <> '?') THEN
  errbuf := 'No errors - examine logfiles for detailed reports.';
ELSE
  errbuf := 'Master Controller is paused.';
END IF;

-- see the migration has errored
-- if so, error this conc. program
OPEN csr_mig_status;
FETCH csr_mig_status INTO l_mig_status;
CLOSE csr_mig_status;

IF l_mig_status = 'E' THEN
  l_fatal_error_message := 'The migration is in error.';
  RAISE e_fatal_error;
END IF;

-- if we are doing a delete migration
-- and the status is Complete
-- then mark the migration as Finished

IF r_migration_data.migration_type = 'D'
  AND l_mig_status = 'C' THEN
  UPDATE hr_dm_migrations
  SET status = 'F'
    WHERE migration_id = r_migration_data.migration_id;
  COMMIT;
END IF;


hr_dm_utility.message('INFO','Main controller', 15);
hr_dm_utility.message('SUMM','Main controller', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_master.main_controller', 25);
hr_dm_utility.message('PARA','(retcode - ' || retcode ||
                             ')(errbuf - ' || errbuf || ')', 30);


-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  retcode := 2;
  errbuf := 'An error occurred during the migration - examine logfiles' ||
            ' for detailed reports.';
  hr_dm_utility.error(SQLCODE,'hr_dm_range.main_controller',
                      l_fatal_error_message,'R');
  report_error(l_phase_name, p_migration_id,
               l_fatal_error_message || ' in hr_dm_master.main_controller',
               'M');
WHEN OTHERS THEN
  retcode := 2;
  errbuf := 'An error occurred during the migration - examine logfiles' ||
            ' for detailed reports.';
  hr_dm_utility.error(SQLCODE,'hr_dm_master.main_controller','(none)','R');
  report_error(l_phase_name, p_migration_id,
               'Untrapped error in hr_dm_master.main_controller', 'M');

--
END main_controller;
--



end hr_dm_master;

/
