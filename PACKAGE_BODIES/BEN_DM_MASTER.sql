--------------------------------------------------------
--  DDL for Package Body BEN_DM_MASTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_MASTER" AS
/* $Header: benfdmdmas.pkb 120.0 2006/05/04 04:47:39 nkkrishn noship $ */


g_delimiter           varchar2(1) := fnd_global.local_chr(01);
g_data_file_name      varchar2(30)  :=  'out_file.dat';
g_transfer_file_name  varchar2(30)  :=  'transfer_file.dat';
/*-------------------------- PRIVATE ROUTINES ----------------------------*/

-- ------------------------- controller_init ------------------------
-- Description: Various initialization processes are undertaken:
--  a) ensuring that data for the migration exists in ben_dm_migrations
--  b) entries in ben_dm_migration_requests are marked as inactive
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
                          r_migration_data IN OUT nocopy
                                             ben_dm_utility.r_migration_rec,
                          p_request_data IN VARCHAR2) IS
--

l_current_phase_status VARCHAR2(30);
l_migration_type VARCHAR2(30);
l_application_id NUMBER;
l_migration_id NUMBER;
l_migration_name VARCHAR2(80);
l_input_parameter_file_name VARCHAR2(30);
l_input_parameter_file_path VARCHAR2(60);
l_data_file_name VARCHAR2(30);
l_data_file_path VARCHAR2(60);
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
  SELECT MIGRATION_ID, MIGRATION_NAME,
         INPUT_PARAMATER_FILE_NAME,
         INPUT_PARAMETER_FILE_PATH,
         DATA_FILE_NAME,
         DATA_FILE_PATH,
         MIGRATION_COUNT,
         DATABASE_LOCATION,
         STATUS
    FROM ben_dm_migrations
    WHERE (migration_id = p_migration_id);

CURSOR csr_migration_request IS
  SELECT MAX(creation_date)
    FROM ben_dm_migration_requests
    WHERE (migration_id = p_migration_id);


--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_master.controller_init', 5);
ben_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id ||
                      ')(r_migration_data - record' ||
                      ')(p_request_data - ' || p_request_data || ')', 10);


-- identify the current migrations.
OPEN csr_migration;
LOOP
  FETCH csr_migration INTO l_migration_id, l_migration_name,
                           l_input_parameter_file_name,
                           l_input_parameter_file_path,
                           l_data_file_name,
                           l_data_file_path,
                           l_migration_count,
                           l_database_location,
                           l_status;
  EXIT WHEN csr_migration%NOTFOUND;
END LOOP;
CLOSE csr_migration;

-- raise error if no matching row in ben_dm_migrations
IF (l_migration_id IS NULL) THEN
  l_fatal_error_message := 'No row identified in ben_dm_migrations!';
  RAISE e_fatal_error;
END IF;


-- set all the enabled flags to N for the current migration_request_id
-- except for the current run of the migration
--  (non-paused)
IF (p_request_data IS NULL) THEN
  OPEN csr_migration_request;
  FETCH csr_migration_request INTO l_migration_date;
  CLOSE csr_migration_request;

  UPDATE ben_dm_migration_requests
    SET enabled_flag = 'N'
      WHERE ((migration_id = p_migration_id)
        AND (creation_date <> l_migration_date));

  COMMIT;

  END IF;

-- seed data into record
r_migration_data.migration_id := p_migration_id;
r_migration_data.migration_name  := l_migration_name;
r_migration_data.input_parameter_file_name  := l_input_parameter_file_name;
r_migration_data.input_parameter_file_path  := l_input_parameter_file_path;
r_migration_data.data_file_name  := l_data_file_name;
r_migration_data.data_file_path  := l_data_file_path;
r_migration_data.database_location := l_database_location;
r_migration_data.last_migration_date  :=
                           ben_dm_business.last_migration_date(
                                                    r_migration_data);

-- increment migration count in ben_dm_migrations (non-paused)
IF (p_request_data IS NULL) THEN
  UPDATE ben_dm_migrations
    SET migration_count = l_migration_count+1
    WHERE migration_id = p_migration_id;
  COMMIT;
END IF;

-- check if migration is valid / warning
-- (first run only)
IF (p_request_data IS NULL) THEN
  l_valid_migration := ben_dm_business.validate_migration(r_migration_data);
  IF (l_valid_migration = 'E') THEN
-- raise error
    l_fatal_error_message := 'Invalid migration - business rule broken';
    ben_dm_utility.update_migrations(p_new_status => 'E',
                                    p_id => p_migration_id);
    RAISE e_fatal_error;
  END IF;
END IF;

-- update status of migration to started (un-paused)
IF (NVL(p_request_data, '?') = '?') THEN
  ben_dm_utility.update_migrations(p_new_status => 'S',
                                  p_id => p_migration_id);
END IF;


ben_dm_utility.message('INFO','Main controller initialized', 15);
ben_dm_utility.message('SUMM','Main controller initialized', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_master.controller_init', 25);
ben_dm_utility.message('PARA','(none)', 30);



-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  ben_dm_utility.error(SQLCODE,'hr_dm_range.main_controller',
                      l_fatal_error_message,'R');
  report_error(l_phase_name, p_migration_id,
               l_fatal_error_message ||
               ' in ben_dm_master.main_controller', 'M');
  RAISE;
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_master.main_controller',
                      '(none)','R');
  report_error(l_phase_name, p_migration_id,
               'Untrapped error in ben_dm_master.main_controller', 'M');
  RAISE;


--
END controller_init;
--

-- ------------------------- getTableSchema ------------------------
-- Description: Gets the BEN schema name used.  This info
-- will be used when we truncate the tables for migrations.
--
--
--  Input Parameters
--        <none>
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

FUNCTION getTableSchema RETURN VARCHAR2 IS
l_status    VARCHAR2(100) := '';
l_industry  VARCHAR2(100) := '';
l_result    BOOLEAN;
l_schema_owner VARCHAR2(10) := '';
BEGIN
    l_result := FND_INSTALLATION.GET_APP_INFO(
                'BEN',
                 l_status,
                 l_industry,
                 l_schema_owner);

    IF l_result THEN
       RETURN l_schema_owner;
    ELSE
       RETURN 'BEN';
    END IF;
END getTableSchema;

-- ------------------------- insert_request ------------------------
-- Description: Inserts the details of a concurrent manager request into
-- the table ben_dm_migration_requests.
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

ben_dm_utility.message('ROUT','entry:ben_dm_master.insert_request', 5);
ben_dm_utility.message('PARA','(p_phase - ' || p_phase ||
                      ')(p_request_id - ' || p_request_id ||
                      ')(p_master_slave - ' || p_master_slave ||
                      ')(p_migration_id - ' || p_migration_id ||
                      ')(p_phase_id - ' || p_phase_id ||
                      ')(p_phase_item_id - ' || p_phase_item_id || ')', 10);


INSERT INTO ben_dm_migration_requests (migration_request_id,
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
  SELECT ben_dm_migration_requests_s.nextval,
         p_migration_id,
         nvl(p_phase_id,-1),
         nvl(p_phase_item_id,-1),
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
      (SELECT NULL FROM ben_dm_migration_requests
         WHERE request_id = p_request_id);

COMMIT;

ben_dm_utility.message('INFO','Inserted into ben_dm_migration_requests', 15);
ben_dm_utility.message('SUMM','Inserted into ben_dm_migration_requests', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_master.insert_request', 25);
ben_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_master.insert_request','(none)','R');
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
                       r_migration_data IN ben_dm_utility.r_migration_rec) IS
--

l_counter NUMBER;
l_request_id NUMBER;
e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);
l_slave_program VARCHAR2(30);
l_phase_id NUMBER;
l_threads NUMBER;
l_sub_request boolean := true;
l_no_of_files   number;
l_argument1     varchar2(255);
l_argument2     varchar2(255);
l_argument3     varchar2(255);
l_argument4     varchar2(255);
l_argument5     varchar2(255);
l_argument6     varchar2(255);
l_argument7     varchar2(255);
l_argument8     varchar2(255);

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_master.spawn_slaves', 5);
ben_dm_utility.message('PARA','(p_current_phase - ' || p_current_phase ||
                      ')(r_migration_data - record)', 10);


-- set up name for appropriate concurrent slave
l_slave_program := 'BENDMSLV' || p_current_phase;

-- get the current phase_id
if p_current_phase <> 'UF' then
  l_phase_id := ben_dm_utility.get_phase_id(p_current_phase,
                                         r_migration_data.migration_id);
else
  l_phase_id := -1;
end if;

-- find the number of threads to use
l_threads := ben_dm_utility.number_of_threads(fnd_profile.value('PER_BUSINESS_GROUP_ID'));

if l_threads is null then
   l_threads := 3;
end if;

-- only single thread for UF phase
IF (p_current_phase = 'UF') THEN
  l_argument1 := '1';
  l_argument2 := r_migration_data.input_parameter_file_path;
  l_argument3 := g_transfer_file_name;
  l_argument4 := g_data_file_name;

  ben_dm_create_control_files.get_no_of_inp_files
  (p_dir_name       => l_argument2,
   p_data_file      => g_data_file_name,
   p_no_of_files    => l_argument5);

  ben_dm_utility.message('INFO','p_no_of_files ' || l_argument5, 17);
  IF nvl(l_argument5,0) = 0 THEN
     l_fatal_error_message := 'Unable to find input data files';
     report_error(p_current_phase, r_migration_data.migration_id,
                  l_fatal_error_message, 'P');
     RAISE e_fatal_error;
  END IF;

  ben_dm_create_control_files.main
  (p_dir_name             => l_argument2,
   p_no_of_threads        => l_threads,
   p_transfer_file        => l_argument3,
   p_data_file            => l_argument4);

  l_threads := 1;
END IF;

-- only single thread for LF phase
IF (p_current_phase = 'LF') THEN
  l_threads := 1;
  l_slave_program := 'BENDMSLV' ||'UF';
  l_argument1 := '2';
  l_argument2 := r_migration_data.input_parameter_file_path;
  l_argument3 := g_transfer_file_name;
  l_argument4 := g_data_file_name;

  ben_dm_create_control_files.get_no_of_inp_files
  (p_dir_name       => l_argument2,
   p_data_file      => g_data_file_name,
   p_no_of_files    => l_argument5);

END IF;

IF (p_current_phase in ('G','DP','UP','DE')) THEN
  l_sub_request := true;
  l_argument1 := to_char(r_migration_data.migration_id);
  l_argument2 := 'Y';
  l_argument3 := to_char(r_migration_data.last_migration_date,'YYYY/MM/DD HH24:MI:SS');
  l_argument4 := null;
  l_argument5 := r_migration_data.input_parameter_file_path;
  l_argument6 := g_data_file_name;
  l_argument7 := g_delimiter;
  l_argument8 := fnd_profile.value('PER_BUSINESS_GROUP_ID');

  --
  --set UP phase threads same as number of files
  --
  if p_current_phase = 'DP' then

     ben_dm_create_control_files.touch_files
     (p_dir_name       => l_argument5,
      p_no_of_threads  => l_threads,
      p_data_file      => g_data_file_name,
      p_file_type      => 'in');

  elsif p_current_phase = 'UP' then
     ben_dm_create_control_files.get_no_of_inp_files
     (p_dir_name       => l_argument5,
      p_data_file      => g_data_file_name,
      p_no_of_files    => l_threads);

      l_threads := nvl(l_threads,0);
      ben_dm_utility.message('INFO','p_no_of_files ' || l_threads, 17);
      IF nvl(l_threads,0) = 0 THEN
         l_fatal_error_message := 'Unable to find input data files';
         report_error(p_current_phase, r_migration_data.migration_id,
                      l_fatal_error_message, 'P');
         RAISE e_fatal_error;
      END IF;

  end if;

END IF;


FOR l_counter IN 1..l_threads LOOP
  ben_dm_utility.message('INFO','Spawning slave #' || l_counter, 16);
  ben_dm_utility.message('INFO','submiting request for ' || l_slave_program , 5);

  l_request_id := fnd_request.submit_request(
                      application => 'BEN',
                      program     => l_slave_program,
                      sub_request => l_sub_request,
                      argument1 => l_argument1,
                      argument2 => l_argument2,
                      argument3 => l_argument3,
                      argument4 => nvl(l_argument4,to_char(l_counter)),
                      argument5 => l_argument5,
                      argument6 => l_argument6,
                      argument7 => l_argument7,
                      argument8 => l_argument8);


  -- update table ben_dm_migration_requests
  insert_request(p_phase => p_current_phase,
                 p_request_id => l_request_id,
                 p_master_slave => 'S',
                 p_migration_id => r_migration_data.migration_id,
                 p_phase_id => l_phase_id);

  COMMIT;

  ben_dm_utility.message('INFO','Slave request ID#' || l_request_id, 17);
  IF (l_request_id = 0) THEN
      l_fatal_error_message := 'Unable to start slave process';
      report_error(p_current_phase, r_migration_data.migration_id,
                   l_fatal_error_message, 'P');
      RAISE e_fatal_error;
  END IF;
END LOOP;

ben_dm_utility.message('INFO','Spawned slaves', 15);
ben_dm_utility.message('SUMM','Spawned slaves', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_master.spawn_slaves', 25);
ben_dm_utility.message('PARA','(none)', 30);

EXCEPTION
WHEN e_fatal_error THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_master.spawn_slaves',
                      l_fatal_error_message,'R');
  report_error(p_current_phase, r_migration_data.migration_id,
               'Error in ben_dm_master.spawn_slaves', 'P');
  RAISE;
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_master.spawn_slaves','(none)','R');
  report_error(p_current_phase, r_migration_data.migration_id,
               'Untrapped error in ben_dm_master.spawn_slaves', 'P');
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
                      r_migration_data IN ben_dm_utility.r_migration_rec)
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

CURSOR csr_requests(p_migration_id  number,
                    p_phase_id      number) IS
  SELECT request_id
    FROM ben_dm_migration_requests
   WHERE migration_id = p_migration_id
     AND phase_id = p_phase_id
     AND master_slave = 'S'
     AND enabled_flag = 'Y';
--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_master.slave_status', 5);
ben_dm_utility.message('PARA','(p_current_phase - ' || p_current_phase ||
                  ')(r_migration_data - record)', 10);

-- get the current phase_id
if p_current_phase <> 'UF' then
   l_phase_id := ben_dm_utility.get_phase_id(p_current_phase,
                                         r_migration_data.migration_id);
else
   l_phase_id := -1;
end if;

-- check if a slave has errored
OPEN csr_requests(r_migration_data.migration_id,
                  l_phase_id);
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


ben_dm_utility.message('INFO','Slave status request', 15);
ben_dm_utility.message('SUMM','Slave status request', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_master.spawn_slaves', 25);
ben_dm_utility.message('PARA','(l_slave_error - ' || l_slave_error ||
                      ')', 30);


RETURN(l_slave_error);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_master.slave_status','(none)','R');
  report_error(p_current_phase, r_migration_data.migration_id,
               'Untrapped error in ben_dm_master.slave_status', 'P');
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

ben_dm_utility.message('ROUT','entry:ben_dm_master.report_error', 5);
ben_dm_utility.message('PARA','(p_current_phase - ' || p_current_phase ||
                  ')(p_migration - ' || p_migration ||
                  ')(p_error_message - ' || p_error_message ||
                  ')(p_stage - ' || p_stage || ')', 10);


-- update status to show error (E)
-- update approriate phase, migration, etc.
IF (p_stage = 'P') THEN
  ben_dm_utility.update_phases(p_new_status => 'E',
                              p_id => ben_dm_utility.get_phase_id(
                                             p_current_phase, p_migration));
END IF;

IF (p_stage = 'M') THEN
  ben_dm_utility.update_migrations(p_new_status => 'E', p_id => p_migration);
END IF;


ben_dm_utility.message('INFO','Error reported', 15);
ben_dm_utility.message('SUMM','Error reported', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_master.report_error', 25);
ben_dm_utility.message('PARA','(none)', 30);


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
                       r_migration_data IN ben_dm_utility.r_migration_rec)
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
    FROM ben_dm_phase_items
    WHERE phase_id = l_phase_id
      AND status <> 'C';

CURSOR csr_ddp_pi IS
  SELECT phase_item_id, group_order
    FROM ben_dm_phase_items
    WHERE phase_id = l_phase_id;

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_master.work_required', 5);
ben_dm_utility.message('PARA','(p_current_phase - ' || p_current_phase ||
                      ')(r_migration_data - record)', 10);

 ben_dm_utility.message('INFO','Migration Id ' ||  r_migration_data.migration_id, 17);

-- get the current phase_id
l_phase_id := ben_dm_utility.get_phase_id(p_current_phase,
                                         r_migration_data.migration_id);

l_work := 'Y';

 ben_dm_utility.message('INFO','Phase Id ' ||  l_phase_id, 19);

-- check if any phase items to process
IF (p_current_phase IN ('G', 'DP', 'CF', 'UP','RC')) THEN
  OPEN csr_phase_items;
  FETCH csr_phase_items INTO l_required;
  IF (csr_phase_items%NOTFOUND) THEN
    ben_dm_utility.message('INFO','No work required for phase ' ||
                          p_current_phase, 11);
    l_work := 'N';
    ben_dm_utility.update_phases(p_new_status => 'C',
                                p_id => l_phase_id);
  END IF;
  CLOSE csr_phase_items;
END IF;

IF (ben_dm_utility.get_phase_status(p_current_phase,
                               r_migration_data.migration_id) = 'C') THEN
    l_work := 'N';
END IF;


ben_dm_utility.message('INFO','Check work required for phase', 15);
ben_dm_utility.message('SUMM','Check work required for phase', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_master.work_required', 25);
ben_dm_utility.message('PARA','(l_work - ' || l_work || ')', 30);


RETURN(l_work);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_master.work_required','(none)','R');
  report_error(p_current_phase, r_migration_data.migration_id,
               'Untrapped error in ben_dm_master.work_required', 'P');
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
                 r_migration_data IN ben_dm_utility.r_migration_rec) IS
--

l_current_phase_status VARCHAR2(30);
e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);
l_request_data VARCHAR2(30);
l_dummy VARCHAR2(1);
l_slave_errored varchar2(30) := 'N';

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_master.master', 5);
ben_dm_utility.message('PARA','(p_current_phase - ' || p_current_phase ||
                  ')(p_previous_phase - ' || p_previous_phase ||
                  ')(r_migration_data - record)', 10);

-- see if this is the first run? (l_request_data = NULL or '?')
-- or
-- is it a restart after slaves have finished? (l_request_data =
--                                                       paused phase code)
l_request_data := fnd_conc_global.request_data;

ben_dm_utility.message('INFO','l_request_data ' || l_request_data, 11);
IF (NVL(l_request_data, '?') = '?') THEN
-- first run processing...

ben_dm_utility.message('INFO','First run processing (pre-pause)', 12);

-- get status of previous phase, is previous phase completed?
-- for the first phase there is no previous phase, so check for
-- a NULL previous to bypass this check
  IF ((ben_dm_utility.get_phase_status(p_previous_phase,
                                      r_migration_data.migration_id) <> 'C')
       AND (p_previous_phase <> 'START') ) THEN
    l_fatal_error_message := 'Previous phase has not completed';
    report_error(p_current_phase, r_migration_data.migration_id,
                 l_fatal_error_message, 'P');
    RAISE e_fatal_error;
  END IF;

  -- get status of current phase
  l_current_phase_status := ben_dm_utility.get_phase_status(p_current_phase,
                              r_migration_data.migration_id);

  -- is phase complete?
  IF (l_current_phase_status <> 'C') THEN
     -- do we need to explicitly rollback using rollback utility?
    IF ( (l_current_phase_status IN('S', 'E')) AND
         (p_current_phase IN('I', 'G', 'DP',
                             'UP', 'CF', 'D','DE')) ) THEN
      ben_dm_utility.rollback(p_phase => p_current_phase,
                             p_masterslave => 'MASTER',
                             p_migration_id =>
                                          r_migration_data.migration_id);
    END IF;

-- update status to started
    ben_dm_utility.update_phases(p_new_status => 'S',
                              p_id => ben_dm_utility.get_phase_id(
                                            p_current_phase,
                                            r_migration_data.migration_id));
    COMMIT;

    -- call phase specific processing code
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
ben_dm_utility.message('INFO','Unpaused processing', 13);
-- set request data to indicate un-paused phase
  fnd_conc_global.set_req_globals(request_data => '?');


-- first force check for all required work
  l_dummy := work_required(p_current_phase, r_migration_data);

  l_slave_errored := slave_status(p_current_phase, r_migration_data);


  if p_current_phase in ('DE','LF','UF') then
     if l_slave_errored = 'Y' then
        l_current_phase_status := 'E';
     else
        l_current_phase_status := 'C';
     end if;
     ben_dm_utility.update_phases(p_new_status => l_current_phase_status,
                                   p_id => ben_dm_utility.get_phase_id(p_current_phase, r_migration_data.migration_id));
  else
     l_current_phase_status := ben_dm_utility.get_phase_status(p_current_phase,
                                             r_migration_data.migration_id);
  end if;

  -- is it completed?
  IF (l_current_phase_status <> 'C') THEN
      l_fatal_error_message := 'Current phase has not completed';
      report_error(p_current_phase, r_migration_data.migration_id,
                   l_fatal_error_message, 'P');
      RAISE e_fatal_error;
  END IF;

-- has any slave errored?
-- if so, add warning message to log
  IF (l_slave_errored = 'Y') THEN
    ben_dm_utility.message('INFO', 'Warning - ' || p_current_phase ||
                          ' phase slave process errored', 13);
  END IF;


  IF (p_current_phase = 'UP') THEN
-- Set the variable so as to disable the trigger on the table.
      hr_general.g_data_migrator_mode := 'Y';
  END IF;

END IF;

ben_dm_utility.message('INFO','Master concurrent program', 15);
ben_dm_utility.message('SUMM','Master concurrent program', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_master.master', 25);
ben_dm_utility.message('PARA','(none)', 30);



-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  ben_dm_utility.error(SQLCODE,'hr_dm_range.master',
                      l_fatal_error_message,'R');
  report_error(p_current_phase, r_migration_data.migration_id,
              'Untrapped error in ben_dm_master.master', 'P');
  RAISE;
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_master.master','(none)','R');
  report_error(p_current_phase, r_migration_data.migration_id,
              'Untrapped error in ben_dm_master.master', 'P');
  RAISE;
--
END master;
--

/*---------------------------- PUBLIC ROUTINES --------------------------*/

-- ------------------------- Start_Download ------------------------
-- Description: Start Download
--
--
--  Input Parameters
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

-- ------------------------- main_controller ------------------------
-- Description: This is the main controller for the PM which is called
-- from the SRS. It calls the required phases for the migration.
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
--        p_migration_name      - Migration Name
--        p_input_file_path
--        p_input_file_name
--        p_output_file_path
--        p_output_file_name
--        p_migration_type
--        p_restart_migration_id
--        p_disable_generation
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
PROCEDURE main_controller(errbuf OUT nocopy VARCHAR2,
                          retcode OUT nocopy NUMBER,
                          p_migration_id IN BINARY_INTEGER,
                          p_migration_name IN VARCHAR2,
                          p_input_file_path IN VARCHAR2,
                          p_input_file_name IN VARCHAR2,
                          p_output_file_path IN VARCHAR2,
                          p_output_file_name IN VARCHAR2,
                          p_migration_type IN VARCHAR2,
                          p_restart_migration_id IN NUMBER,
                          p_disable_generation IN VARCHAR2
) IS
--

l_search_phase VARCHAR2(30);
l_next_phase VARCHAR2(30);
l_phase_name VARCHAR2(30);
l_previous_phase VARCHAR2(30);
l_previous VARCHAR2(30);
e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);
r_migration_data ben_dm_utility.r_migration_rec;
l_database_location VARCHAR2(30);
l_request_data VARCHAR2(60);
l_mig_status VARCHAR2(30);
l_loader_lct_file VARCHAR2(100);
l_data_file VARCHAR2(100);
l_request_id NUMBER(15);
l_migration_id number(15);
l_db_loc VARCHAR2(30);

CURSOR csr_phase_rule IS
  SELECT phase_name, next_phase, database_location
    FROM hr_dm_phase_rules
    WHERE ((migration_type = 'SP')
      AND (previous_phase = l_search_phase))
        AND database_location like l_db_loc;

CURSOR csr_paused_phase_rule IS
  SELECT previous_phase, next_phase
    FROM hr_dm_phase_rules
    WHERE ((migration_type = 'SP')
      AND (phase_name = l_request_data));

CURSOR csr_mig_status IS
  SELECT status
    FROM ben_dm_migrations
    WHERE migration_id = r_migration_data.migration_id;

--
BEGIN
--

--
-- Set if the database_location to be used in the csr_phase_rule
-- cursor
--
IF p_migration_type = 'SU' or p_migration_type = 'RU' then
  l_db_loc := '%D%';
ELSE
  l_db_loc := '%S%';
END IF;

-- initialize messaging
 ben_dm_utility.message_init;
--
-- see if this is a migration run (l_request_data = NULL)
-- OR
-- is it a restart after slaves have finished? (l_request_data =
--                                                    paused phase code)
l_request_data := fnd_conc_global.request_data;
ben_dm_utility.message('INFO','Request data - ' || l_request_data, 12);
IF (l_request_data IS NULL) THEN

 If p_migration_type = 'SD' then
   ben_dm_utility.message('INFO','Start of Truncate from ben_dm_entity_results, ben_dm_resolve_mappings and ben_dm_input_file tables', 15);
   ben_dm_utility.message('SUMM','Start of Truncate from  ben_dm_entity_results, ben_dm_resolve_mappings and ben_dm_input_file tables', 20);

  -- Truncate From ben_dm_entity_results, ben_dm_resolve_mappings and ben_dm_input_file tables.

   execute immediate 'truncate table '||getTableSchema||'.ben_dm_entity_results';
   execute immediate 'truncate table '||getTableSchema||'.ben_dm_resolve_mappings';
   execute immediate 'truncate table '||getTableSchema||'.ben_dm_input_file';

  commit;

  ben_dm_utility.message('INFO','End Truncate of ben_dm_entity_results, ben_dm_resolve_mappings and ben_dm_input_file tables', 15);
  ben_dm_utility.message('SUMM','End Truncate of ben_dm_entity_results, ben_dm_resolve_mappings and ben_dm_input_file tables', 20);

   --
   -- We are ready to do the insert, so pull the next
   -- sequence number from ben_dm_migrations_s.
   --
   SELECT ben_dm_migrations_s.nextval
     INTO l_migration_id
     FROM dual;

   INSERT INTO ben_dm_migrations
      (migration_id
      ,migration_name
      ,source_migration_id
      ,input_parameter_file_path
      ,input_paramater_file_name
      ,Data_file_path
      ,Data_file_name
      ,migration_start_date
      ,migration_end_date
      ,status
      ,migration_type
      ,effective_date
      ,migration_count
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      ,creation_date
      ,created_by
      ,database_location
      )
   VALUES
      (l_migration_id
      ,p_migration_name
      ,NULL
      ,p_input_file_path
      ,nvl(p_input_file_name,'null')
      ,p_output_file_path
      ,p_output_file_name
      ,SYSDATE
      ,NULL
      ,'NS'
      ,NULL
      ,SYSDATE
      ,0
      ,fnd_global.user_id
      ,SYSDATE
      ,fnd_global.user_id
      ,SYSDATE
      ,fnd_global.user_id
      ,'S'
      );

  Commit;

  select fnd_global.conc_request_id
    into l_request_id
  from dual;

  IF l_request_id = 0 THEN
    ben_dm_utility.message('INFO','Problem with Inserting into BEN_DM_MIGRATION_REQUESTS', 15);
    ben_dm_utility.message('SUMM','Problem with Inserting into BEN_DM_MIGRATION_REQUESTS', 20);
  ELSE
   --
   -- The request submission was successful - insert
   -- a row into ben_dm_migration_requests so that
   -- the user can view the logfile later on.
   --
    INSERT INTO ben_dm_migration_requests
           (migration_request_id
           ,phase_id
           ,phase_item_id
           ,migration_id
           ,request_id
           ,master_slave
           ,enabled_flag
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,created_by
           ,creation_date
           )
        VALUES
           (ben_dm_migration_requests_s.nextval
           ,-1
           ,-1
           ,l_migration_id
           ,l_request_id
           ,'M'
           ,'Y'
           ,SYSDATE
           ,fnd_global.user_id
           ,fnd_global.login_id
           ,fnd_global.user_id
           ,SYSDATE
           );

  END IF;

  -- seed data into record
  r_migration_data.migration_id := l_migration_id;
  r_migration_data.migration_name  := p_migration_name;
  r_migration_data.input_parameter_file_name  := p_input_file_name;
  r_migration_data.input_parameter_file_path  := p_input_file_path;
  r_migration_data.data_file_name  := p_output_file_name;
  r_migration_data.data_file_path  := p_input_file_path;
  r_migration_data.database_location := 'S';

  --  p_migration_id := l_migration_id;

  -- Read the Input File and Process the Data
  ben_dm_utility.message('INFO','Start Of Process Input File', 15);
  ben_dm_utility.message('SUMM','Start Of Process Input File', 20);

  ben_dm_input_file_pkg.read_file(r_migration_data);

  ben_dm_utility.message('INFO','End Of Process Input File', 15);
  ben_dm_utility.message('SUMM','End Of Process Input File', 20);



  end if;

-- New code
 If p_migration_type = 'SU' then
   ben_dm_utility.message('INFO','Start of the SU Phase', 15);
   ben_dm_utility.message('SUMM','Start of the SU Phase', 20);
   ben_dm_utility.message('INFO','Start of Truncate from ben_dm_entity_results, ben_dm_resolve_mappings and ben_dm_input_file tables', 15);
   ben_dm_utility.message('SUMM','Start of Truncate from  ben_dm_entity_results, ben_dm_resolve_mappings and ben_dm_input_file tables', 20);

  -- Truncate From ben_dm_entity_results, ben_dm_resolve_mappings and ben_dm_input_file tables.

   execute immediate 'truncate table '||getTableSchema||'.ben_dm_entity_results';
   execute immediate 'truncate table '||getTableSchema||'.ben_dm_resolve_mappings';
   execute immediate 'truncate table '||getTableSchema||'.ben_dm_input_file';

  commit;

  ben_dm_utility.message('INFO','End Truncate of ben_dm_entity_results, ben_dm_resolve_mappings and ben_dm_input_file tables', 15);
  ben_dm_utility.message('SUMM','End Truncate of ben_dm_entity_results, ben_dm_resolve_mappings and ben_dm_input_file tables', 20);

   --
   -- We are ready to do the insert, so pull the next
   -- sequence number from ben_dm_migrations_s.
   --
   SELECT ben_dm_migrations_s.nextval
     INTO l_migration_id
     FROM dual;

   INSERT INTO ben_dm_migrations
      (migration_id
      ,migration_name
      ,source_migration_id
      ,input_parameter_file_path
      ,input_paramater_file_name
      ,Data_file_path
      ,Data_file_name
      ,migration_start_date
      ,migration_end_date
      ,status
      ,migration_type
      ,effective_date
      ,migration_count
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      ,creation_date
      ,created_by
      ,database_location
      )
   VALUES
      (l_migration_id
      ,p_migration_name
      ,NULL
      ,p_input_file_path
      ,nvl(p_input_file_name,'null')
      ,p_output_file_path
      ,p_output_file_name
      ,SYSDATE
      ,NULL
      ,'NS'
      ,NULL
      ,SYSDATE
      ,0
      ,fnd_global.user_id
      ,SYSDATE
      ,fnd_global.user_id
      ,SYSDATE
      ,fnd_global.user_id
      ,'D'
      );

  Commit;

  select fnd_global.conc_request_id
    into l_request_id
  from dual;

  IF l_request_id = 0 THEN
    ben_dm_utility.message('INFO','Problem with Inserting into BEN_DM_MIGRATION_REQUESTS', 15);
    ben_dm_utility.message('SUMM','Problem with Inserting into BEN_DM_MIGRATION_REQUESTS', 20);
  ELSE
   --
   -- The request submission was successful - insert
   -- a row into ben_dm_migration_requests so that
   -- the user can view the logfile later on.
   --
    INSERT INTO ben_dm_migration_requests
           (migration_request_id
           ,phase_id
           ,phase_item_id
           ,migration_id
           ,request_id
           ,master_slave
           ,enabled_flag
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,created_by
           ,creation_date
           )
        VALUES
           (ben_dm_migration_requests_s.nextval
           ,-1
           ,-1
           ,l_migration_id
           ,l_request_id
           ,'M'
           ,'Y'
           ,SYSDATE
           ,fnd_global.user_id
           ,fnd_global.login_id
           ,fnd_global.user_id
           ,SYSDATE
           );

  END IF;

  -- seed data into record
  r_migration_data.migration_id := l_migration_id;
  r_migration_data.migration_name  := p_migration_name;
  r_migration_data.input_parameter_file_name  := p_input_file_name;
  r_migration_data.input_parameter_file_path  := p_input_file_path;
  r_migration_data.data_file_name  := p_output_file_name;
  r_migration_data.data_file_path  := p_input_file_path;
  r_migration_data.database_location := 'D';

  --  p_migration_id := l_migration_id;

  end if;


-- New code


end if;


 If (p_migration_type = 'RD' or p_migration_type = 'RU') then
  ben_dm_utility.message('INFO','Migration Type detected'||p_migration_type, 15);
  ben_dm_utility.message('SUMM','Migration Type detected'||p_migration_type, 20);
  ben_dm_utility.message('SUMM','Re Start Migration ID : '||p_restart_migration_id, 20);

  l_migration_id := p_restart_migration_id;

  select fnd_global.conc_request_id
    into l_request_id
  from dual;

  if l_request_data IS NULL THEN
   -- The request submission was successful - insert
   -- a row into ben_dm_migration_requests so that
   -- the user can view the logfile later on.
   --
    INSERT INTO ben_dm_migration_requests
           (migration_request_id
           ,phase_id
           ,phase_item_id
           ,migration_id
           ,request_id
           ,master_slave
           ,enabled_flag
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,created_by
           ,creation_date
           )
        VALUES
           (ben_dm_migration_requests_s.nextval
           ,-1
           ,-1
           ,l_migration_id
           ,l_request_id
           ,'M'
           ,'Y'
           ,SYSDATE
           ,fnd_global.user_id
           ,fnd_global.login_id
           ,fnd_global.user_id
           ,SYSDATE
           );
  commit;
  end if;

 end if;

-- initialize messaging
ben_dm_utility.message_init;

  select migration_id
    into l_migration_id
    from ben_dm_migration_requests
   where request_id = fnd_global.conc_request_id;

  ben_dm_utility.message('INFO','l_migration_id : '||l_migration_id, 15);
  ben_dm_utility.message('SUMM','l_migration_id : '||l_migration_id, 15);

    -- p_migration_id := l_migration_id;

  ben_dm_utility.message('ROUT','entry:ben_dm_master.main_controller', 5);
  ben_dm_utility.message('PARA','(p_migration_id - ' ||
                      l_migration_id || ')', 10);


-- see if this is a migration run (l_request_data = NULL)
-- OR
-- is it a restart after slaves have finished? (l_request_data =
--                                                    paused phase code)
l_request_data := fnd_conc_global.request_data;
ben_dm_utility.message('INFO','Request data - ' || l_request_data, 12);

-- initialize main controller data
controller_init(l_migration_id,
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
  ben_dm_utility.message('INFO','Start of Main Loop 2', 11);
  ben_dm_utility.message('INFO','Start of Main Loop 2 - l_phase_name '|| l_phase_name, 11);
  ben_dm_utility.message('INFO','Start of Main Loop 2 - l_next_phase '|| l_next_phase, 11);
  ben_dm_utility.message('INFO','Start of Main Loop 2 - l_database_location '|| l_database_location, 11);

-- does it apply?
  IF (INSTR(l_database_location, r_migration_data.database_location) >0) THEN

  ben_dm_utility.message('INFO','Current phase is ' || l_phase_name, 11);
  ben_dm_utility.message('INFO','Request data - ' ||
                        NVL(l_request_data, '?'), 12);

-- store the previous phase that applies
  l_previous_phase := l_previous;
  ben_dm_utility.message('INFO','Previous phase is ' || l_previous_phase, 11);
  --
  -- is it completed or not awoken?
  -- if not, then run appropriate phase code
  --
    IF ((ben_dm_utility.get_phase_status(l_phase_name, l_migration_id) <> 'C')
       OR (NVL(l_request_data, '?') <> '?')) THEN

      -- call generic master code
      IF (l_phase_name IN ('G', 'DP', 'UP','DE','UF','LF')) THEN
      --
      -- Derive The Target ID from Developer Keys
      --
        If l_phase_name = 'UP' THEN
           ben_dm_utility.message('INFO','Start of Derive Target ID', 11);
           ben_dm_upload_dk.get_dk_frm_all;
           ben_dm_utility.message('INFO','End of Derive Target ID', 11);
        end if;

        master(l_phase_name, l_previous_phase, r_migration_data);
      ELSE
        -- call non-generic master code
        IF (l_phase_name = 'I') THEN
           ben_dm_init.main(r_migration_data);
        ELSIF (l_phase_name = 'CF') THEN
          ben_dm_utility.update_phases(p_new_status => 'S',
                                      p_id => ben_dm_utility.get_phase_id('CF'
                                        , r_migration_data.migration_id));
          ben_dm_create_transfer_file.main
          (p_dir_name         => r_migration_data.input_parameter_file_path,
           p_file_name        => g_transfer_file_name,
           p_delimiter        => g_delimiter);

          ben_dm_utility.update_phases(p_new_status => 'C',
                                      p_id => ben_dm_utility.get_phase_id('CF'
                                        , r_migration_data.migration_id));

        ELSIF (l_phase_name = 'RC') THEN
          ben_dm_utility.update_phases(p_new_status => 'S',
                                      p_id => ben_dm_utility.get_phase_id('RC'
                                        , r_migration_data.migration_id));

          ben_dm_utility.message('INFO','Start of Custom Code - RC', 11);
          ben_dm_custom_code.handle_custom_data(r_migration_data);
          ben_dm_utility.message('INFO','Start of Custom Code - RC', 11);

          ben_dm_utility.update_phases(p_new_status => 'C',
                                      p_id => ben_dm_utility.get_phase_id('RC'
                                     ,r_migration_data.migration_id));

          -- processing after being woken up
          ben_dm_utility.message('INFO','Unpaused processing', 13);
          -- set request data to indicate un-paused phase
          fnd_conc_global.set_req_globals(request_data => '?');

        END IF;

      END IF;

-- have we paused the main controller?
-- if so, exit loop
      l_request_data := fnd_conc_global.request_data;
      EXIT WHEN NVL(l_request_data, '?') <> '?';

-- did it complete? if not then update status and raise an error
      IF l_phase_name <> 'UF' and
         (ben_dm_utility.get_phase_status(l_phase_name, l_migration_id)
                                                               <> 'C') THEN
-- update status of migration to error
        ben_dm_utility.update_migrations(p_new_status => 'E',
                                        p_id => l_migration_id);
        COMMIT;
-- raise error
        l_fatal_error_message := 'Error in ' || l_phase_name || ' phase';
        report_error(l_phase_name, l_migration_id, l_fatal_error_message,
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

if p_migration_type = 'SU' and
   l_phase_name = 'LF' then
   ben_dm_create_control_files.rebuild_indexes;
end if;

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

ben_dm_utility.message('INFO','Main controller', 15);
ben_dm_utility.message('SUMM','Main controller', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_master.main_controller', 25);
ben_dm_utility.message('PARA','(retcode - ' || retcode ||
                             ')(errbuf - ' || errbuf || ')', 30);

EXCEPTION
WHEN e_fatal_error THEN
  retcode := 2;
  errbuf := 'An error occurred during the migration - examine logfiles' ||
            ' for detailed reports.';
  ben_dm_utility.error(SQLCODE,'hr_dm_range.main_controller',
                      l_fatal_error_message,'R');
  report_error(l_phase_name, l_migration_id,
               l_fatal_error_message || ' in ben_dm_master.main_controller',
               'M');
WHEN OTHERS THEN
  retcode := 2;
  errbuf := 'An error occurred during the migration - examine logfiles' ||
            ' for detailed reports.';
  ben_dm_utility.error(SQLCODE,'ben_dm_master.main_controller','(none)','R');
  report_error(l_phase_name, l_migration_id,
               'Untrapped error in ben_dm_master.main_controller', 'M');

--
END main_controller;
--

end ben_dm_master;

/
