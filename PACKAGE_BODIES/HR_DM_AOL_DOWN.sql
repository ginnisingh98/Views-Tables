--------------------------------------------------------
--  DDL for Package Body HR_DM_AOL_DOWN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_AOL_DOWN" AS
/* $Header: perdmadl.pkb 120.0 2005/05/31 17:03:06 appldev noship $ */


/*--------------------------- PRIVATE ROUTINES --------------------------*/



-- ------------------------- spawn_down ------------------------
-- Description: The parameters for the requested loader are set up and a
-- slave is spawned via spawn_slave.
--
--
--  Input Parameters
--        p_migration_id - migration id
--
--        p_phase_id     - of phase
--
--        p_phase_item   - of phase item
--
--
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------



--
PROCEDURE spawn_down(p_migration_id IN NUMBER,
                     p_phase_id IN NUMBER,
                     p_phase_item_id IN NUMBER
                     ) IS
--

l_loader_name VARCHAR2(30);
l_loader_conc_program VARCHAR2(30);
l_loader_config_file VARCHAR2(30);
l_config VARCHAR2(100);
l_selective VARCHAR2(2000);
l_parameter1 VARCHAR2(100);
l_parameter2 VARCHAR2(100);
l_parameter3 VARCHAR2(100);
l_parameter4 VARCHAR2(100);
l_parameter5 VARCHAR2(100);
l_parameter6 VARCHAR2(100);
l_parameter7 VARCHAR2(100);
l_parameter8 VARCHAR2(100);
l_parameter9 VARCHAR2(100);
l_parameter10 VARCHAR2(100);
l_loader_application VARCHAR2(50);
l_application_id NUMBER;
l_program VARCHAR2(30);
e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);
l_filename VARCHAR2(50);
l_request_id NUMBER;
l_env_var VARCHAR2(30);
l_migration_type VARCHAR2(30);
l_selective_migration_criteria VARCHAR2(2000);
l_aol_command VARCHAR2(2000);
l_source_database VARCHAR2(30);
l_business_group_id NUMBER;
l_security_group VARCHAR2(30);

CURSOR csr_data IS
  SELECT lpi.loader_name,
         lpi.loader_conc_program,
         lpi.loader_config_file,
         lpi.loader_application,
         lpi.parameter_1, lpi.parameter_2,
         lpi.parameter_3, lpi.parameter_4,
         lpi.parameter_5, lpi.parameter_6,
         lpi.parameter_7, lpi.parameter_8,
         lpi.parameter_9, lpi.parameter_10,
         lpi.application_id,
         lpi.filename
  FROM hr_dm_loader_phase_items lpi,
       hr_dm_phase_items pi
  WHERE (pi.phase_item_id = p_phase_item_id)
    AND (lpi.da_phase_item_id = pi.phase_item_id);

CURSOR csr_migration_info IS
  SELECT dm.migration_type,
         dm.selective_migration_criteria,
         dm.business_group_id,
         sg.security_group_key
  FROM hr_dm_migrations dm,
       fnd_security_groups sg,
       per_business_groups pbg
  WHERE dm.migration_id = p_migration_id
    AND dm.business_group_id = pbg.business_group_id
    AND pbg.security_group_id = sg.security_group_id;


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_aol_down.spawn_down', 5);
hr_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id ||
                             '(p_phase_id - ' || p_phase_id ||
                             '(p_phase_item_id - ' || p_phase_item_id ||
                             ')',10);


-- get data for current phase_item_id
OPEN csr_data;
FETCH csr_data INTO l_loader_name,
         l_loader_conc_program,
         l_loader_config_file,
         l_loader_application,
         l_parameter1, l_parameter2,
         l_parameter3, l_parameter4,
         l_parameter5, l_parameter6,
         l_parameter7, l_parameter8,
         l_parameter9, l_parameter10,
         l_application_id,
         l_filename;
IF (csr_data%NOTFOUND) THEN
  l_fatal_error_message := 'Unable to find loader configuration data.';
  RAISE e_fatal_error;
END IF;
CLOSE csr_data;

COMMIT;


-- set up local data
l_program := 'HRDMSLVA';
IF (l_loader_conc_program = 'FNDLOAD') THEN
  l_program := l_program || 'G';
ELSIF (l_loader_conc_program = 'FNDSLOAD') THEN
  l_program := l_program || 'S';
END IF;


-- find the parameter with the :mode and replace with 'DOWNLOAD'
IF (l_parameter1 = ':mode') THEN l_parameter1 := 'DOWNLOAD';
ELSIF (l_parameter2 = ':mode') THEN l_parameter2 := 'DOWNLOAD';
ELSIF (l_parameter3 = ':mode') THEN l_parameter3 := 'DOWNLOAD';
ELSIF (l_parameter4 = ':mode') THEN l_parameter4 := 'DOWNLOAD';
ELSIF (l_parameter5 = ':mode') THEN l_parameter5 := 'DOWNLOAD';
ELSIF (l_parameter6 = ':mode') THEN l_parameter6 := 'DOWNLOAD';
ELSIF (l_parameter7 = ':mode') THEN l_parameter7 := 'DOWNLOAD';
ELSIF (l_parameter8 = ':mode') THEN l_parameter8 := 'DOWNLOAD';
ELSIF (l_parameter9 = ':mode') THEN l_parameter9 := 'DOWNLOAD';
ELSIF (l_parameter10 = ':mode') THEN l_parameter10 := 'DOWNLOAD';
END IF;

-- find the parameter with the :config and replace with the path
-- and config file filename
l_config := '@fnd:patch/115/import/' || l_loader_config_file;

IF (l_parameter1 = ':config') THEN l_parameter1 := l_config;
ELSIF (l_parameter2 = ':config') THEN l_parameter2 := l_config;
ELSIF (l_parameter3 = ':config') THEN l_parameter3 := l_config;
ELSIF (l_parameter4 = ':config') THEN l_parameter4 := l_config;
ELSIF (l_parameter5 = ':config') THEN l_parameter5 := l_config;
ELSIF (l_parameter6 = ':config') THEN l_parameter6 := l_config;
ELSIF (l_parameter7 = ':config') THEN l_parameter7 := l_config;
ELSIF (l_parameter8 = ':config') THEN l_parameter8 := l_config;
ELSIF (l_parameter9 = ':config') THEN l_parameter9 := l_config;
ELSIF (l_parameter10 = ':config') THEN l_parameter10 := l_config;
END IF;


-- find the data file and replace with the path and filename

IF (l_parameter1 = ':data') THEN l_parameter1 := l_filename;
ELSIF (l_parameter2 = ':data') THEN l_parameter2 := l_filename;
ELSIF (l_parameter3 = ':data') THEN l_parameter3 := l_filename;
ELSIF (l_parameter4 = ':data') THEN l_parameter4 := l_filename;
ELSIF (l_parameter5 = ':data') THEN l_parameter5 := l_filename;
ELSIF (l_parameter6 = ':data') THEN l_parameter6 := l_filename;
ELSIF (l_parameter7 = ':data') THEN l_parameter7 := l_filename;
ELSIF (l_parameter8 = ':data') THEN l_parameter8 := l_filename;
ELSIF (l_parameter9 = ':data') THEN l_parameter9 := l_filename;
ELSIF (l_parameter10 = ':data') THEN l_parameter10 := l_filename;
END IF;


-- find the parameter with the :selective and replace with the
-- selective migration details (if any), otherwise replace with
-- null

OPEN csr_migration_info;
FETCH csr_migration_info INTO l_migration_type,
                              l_selective_migration_criteria,
                              l_business_group_id,
                              l_security_group;
CLOSE csr_migration_info;

l_selective := null;
IF (l_migration_type = 'SD') THEN
  l_selective := 'DESCRIPTIVE_FLEXFIELD_NAME=' ||
                 l_selective_migration_criteria;
END IF;
IF (l_migration_type = 'SL') THEN
  l_selective := 'LOOKUP_TYPE=' ||
                 l_selective_migration_criteria;
END IF;


IF (l_parameter1 = ':selective') THEN l_parameter1 := l_selective;
ELSIF (l_parameter2 = ':selective') THEN l_parameter2 := l_selective;
ELSIF (l_parameter3 = ':selective') THEN l_parameter3 := l_selective;
ELSIF (l_parameter4 = ':selective') THEN l_parameter4 := l_selective;
ELSIF (l_parameter5 = ':selective') THEN l_parameter5 := l_selective;
ELSIF (l_parameter6 = ':selective') THEN l_parameter6 := l_selective;
ELSIF (l_parameter7 = ':selective') THEN l_parameter7 := l_selective;
ELSIF (l_parameter8 = ':selective') THEN l_parameter8 := l_selective;
ELSIF (l_parameter9 = ':selective') THEN l_parameter9 := l_selective;
ELSIF (l_parameter10 = ':selective') THEN l_parameter10 := l_selective;
END IF;



-- find the security group and replace :secgrp with the value
-- unless the security group is STANDARD, in this case, replace with null

IF (l_security_group = 'STANDARD') THEN
  l_security_group := NULL;
ELSE
  l_security_group := 'SECURITY_GROUP=' || l_security_group;
END IF;

IF (l_parameter1 = ':secgrp') THEN l_parameter1 := l_security_group;
ELSIF (l_parameter2 = ':secgrp') THEN l_parameter2 := l_security_group;
ELSIF (l_parameter3 = ':secgrp') THEN l_parameter3 := l_security_group;
ELSIF (l_parameter4 = ':secgrp') THEN l_parameter4 := l_security_group;
ELSIF (l_parameter5 = ':secgrp') THEN l_parameter5 := l_security_group;
ELSIF (l_parameter6 = ':secgrp') THEN l_parameter6 := l_security_group;
ELSIF (l_parameter7 = ':secgrp') THEN l_parameter7 := l_security_group;
ELSIF (l_parameter8 = ':secgrp') THEN l_parameter8 := l_security_group;
ELSIF (l_parameter9 = ':secgrp') THEN l_parameter9 := l_security_group;
ELSIF (l_parameter10 = ':secgrp') THEN l_parameter10 := l_security_group;
END IF;


hr_dm_utility.message('INFO','application ' || l_loader_application, 115);
hr_dm_utility.message('INFO','program ' || l_program, 115);
hr_dm_utility.message('INFO','sub_request TRUE', 115);
hr_dm_utility.message('INFO','argument1 ' || l_parameter1, 115);
hr_dm_utility.message('INFO','argument2 ' || l_parameter2, 115);
hr_dm_utility.message('INFO','argument3 ' || l_parameter3, 115);
hr_dm_utility.message('INFO','argument4 ' || l_parameter4, 115);
hr_dm_utility.message('INFO','argument5 ' || l_parameter5, 115);
hr_dm_utility.message('INFO','argument6 ' || l_parameter6, 115);
hr_dm_utility.message('INFO','argument7 ' || l_parameter7, 115);
hr_dm_utility.message('INFO','argument8 ' || l_parameter8, 115);
hr_dm_utility.message('INFO','argument9 ' || l_parameter9, 115);
hr_dm_utility.message('INFO','argument10 ' || l_parameter10, 115);



l_request_id := fnd_request.submit_request(
                              application => l_loader_application,
                              program => l_program,
                              sub_request => TRUE,
                              argument1 => l_parameter1,
                              argument2 => l_parameter2,
                              argument3 => l_parameter3,
                              argument4 => l_parameter4,
                              argument5 => l_parameter5,
                              argument6 => l_parameter6,
                              argument7 => l_parameter7,
                              argument8 => l_parameter8,
                              argument9 => l_parameter9,
                              argument10 => l_parameter10
                              );


COMMIT;

--
-- insert details into view HR_DM_AOL_DOWN_V
--

-- get the destination database name
SELECT source_database_instance
  INTO l_source_database
  FROM HR_DM_MIGRATIONS
  WHERE migration_id = p_migration_id;


l_aol_command := l_loader_conc_program || ' apps/apps@' ||
                 l_source_database || ' 0 Y ' ||
                 l_parameter1 || ' ' ||
                 l_parameter2 || ' ' ||
                 l_parameter3 || ' ' ||
                 l_parameter4 || ' ' ||
                 l_parameter5 || ' ' ||
                 l_parameter6 || ' ' ||
                 l_parameter7 || ' ' ||
                 l_parameter8 || ' ' ||
                 l_parameter9 || ' ' ||
                 l_parameter10;

INSERT INTO HR_DM_AOL_DOWN_V
  (
   exp_imp_id
  ,table_name
  ,migration_id
  ,phase_item_id
  ,code
  )
  SELECT
   hr_dm_exp_imps_s.nextval
  ,'HR_DM_AOL_DOWN_V'
  ,p_migration_id
  ,p_phase_item_id
  ,l_aol_command
  FROM dual;

--
--end insert details
--


-- update table hr_dm_migration_requests
hr_dm_master.insert_request(p_phase => 'DA',
                            p_request_id => l_request_id,
                            p_master_slave => 'S',
                            p_migration_id => p_migration_id,
                            p_phase_id => p_phase_id,
                            p_phase_item_id => p_phase_item_id);

COMMIT;

hr_dm_utility.message('INFO','Slave request ID#' || l_request_id, 15);
IF (l_request_id = 0) THEN
    l_fatal_error_message := 'Unable to start slave process';
    hr_dm_master.report_error('DA', p_migration_id,
                              l_fatal_error_message, 'P');
    RAISE e_fatal_error;
END IF;


hr_dm_utility.message('INFO','Spawned DA slave', 115);
hr_dm_utility.message('SUMM','Spawned DA slave', 120);
hr_dm_utility.message('ROUT','exit:hr_dm_aol_down.spawn_slaves', 125);
hr_dm_utility.message('PARA','(none)', 130);


-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_aol_down.spawn_down',
                      l_fatal_error_message,'R');
  hr_dm_master.report_error('DA', p_migration_id,
                           'Error in hr_dm_aol_down.spawn_down', 'P');
  RAISE;
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_aol_down.spawn_down','(none)','R');
  hr_dm_master.report_error('DA', p_migration_id,
                            'Untrapped error in hr_dm_aol_down.spawn_down',
                            'P');
  RAISE;

--
END spawn_down;
--





/*--------------------------- PUBLIC ROUTINES ---------------------------*/

-- ------------------------- main ------------------------
-- Description: This is the aol download phase slave. It reads an item from
-- the hr_dm_phase_items table for the aol download phase and calls the
-- appropriate aol loader.
--
-- There are two paths through the code, dependent upon if the procedure is
-- called at the start of a phase item or after the slave has been awoken
-- when the aol loader has finished processing. This is determined by
-- examining the concurrent request data which will contain the phase item
-- id for a re-awoken slave and null for a first run.
--
-- On a non-first run (l_request_data <> null), the status of the slave
-- is checked to ensure that it has completed. If not then the phase item
-- status is set to error and the slave exits. Otherwise the
-- phase item is marked as being completed.
--
--
-- The status of the phase is then checked to see if it has errored (by
-- another slave). If so, the slave exits.
--
-- A row is fetched from the phase_items table that has the status of NS.
-- If no rows are returned then the slave exits as there are no more rows
-- for it to process.
--
-- If a row is returned then the phase item is marked as being started and
-- the spawn_down procedure is used to spawn the aol loader and the slave
-- is paused whilst the aol loader is running.
--
--
--  Input Parameters
--        p_migration_id        - of current migration
--
--        p_concurrent_process  - Y if program called from CM, otherwise
--                                N prevents message logging
--
--        p_last_migration_date - date of last sucessful migration
--
--        p_process_number      - the slave number to allow implicit locking
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
PROCEDURE main(errbuf OUT NOCOPY VARCHAR2,
               retcode OUT NOCOPY NUMBER,
               p_migration_id IN NUMBER,
               p_concurrent_process IN VARCHAR2 DEFAULT 'Y',
               p_last_migration_date IN DATE,
               p_process_number IN NUMBER
               ) IS
--

l_current_phase_status VARCHAR2(30);
l_phase_id NUMBER;
e_fatal_error EXCEPTION;
e_fatal_error2 EXCEPTION;
l_fatal_error_message VARCHAR2(200);
l_loader_name VARCHAR2(30);
l_status VARCHAR2(30);
l_phase_item_id NUMBER;
l_request_data VARCHAR2(100);
l_request_id NUMBER;
l_call_status BOOLEAN;
l_phase VARCHAR2(30);
l_dev_phase VARCHAR2(30);
l_dev_status VARCHAR2(30);
l_message VARCHAR2(240);
l_no_of_threads NUMBER;
l_business_group_id NUMBER;

CURSOR csr_get_pi IS
  SELECT pi.phase_item_id, pi.loader_name, pi.status
    FROM hr_dm_phase_items pi,
         hr_dm_tables tbl
    WHERE (pi.status = 'NS')
      AND (pi.phase_id = l_phase_id)
      AND (pi.loader_name = tbl.loader_name)
      AND ((MOD(pi.phase_item_id, l_no_of_threads) + 1) = p_process_number);


CURSOR csr_req_id IS
  SELECT request_id
    FROM hr_dm_migration_requests
    WHERE phase_item_id = l_phase_item_id
      AND enabled_flag = 'Y';

-- get the migration details
CURSOR csr_migration_info IS
  SELECT business_group_id
    FROM hr_dm_migrations
    WHERE migration_id = p_migration_id;

--
BEGIN
--

-- initialize messaging (only for concurrent processing)
IF (p_concurrent_process = 'Y') THEN
  hr_dm_utility.message_init;
END IF;

hr_dm_utility.message('ROUT','entry:hr_dm_aol_down.main', 5);
hr_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id ||
                             ')(p_last_migration_date - ' ||
                             p_last_migration_date || ')', 10);

-- get the current phase_id
l_phase_id := hr_dm_utility.get_phase_id('DA', p_migration_id);

-- get the business_group_id
OPEN csr_migration_info;
FETCH csr_migration_info INTO l_business_group_id;
IF csr_migration_info%NOTFOUND THEN
  CLOSE csr_migration_info;
  l_fatal_error_message := 'hr_dm_aol_down.main :- Migration Id ' ||
                            TO_CHAR(p_migration_id) || ' not found.';
  RAISE e_fatal_error2;
END IF;
CLOSE csr_migration_info;

-- get the number of threads to enable modulus locking
l_no_of_threads := hr_dm_utility.number_of_threads(l_business_group_id);


-- see if this is the first run? (l_request_data = NULL or '?')
-- or
-- is it a restart after a slave has finished? (l_request_data =
-- paused phase item code)
l_request_data := fnd_conc_global.request_data;
hr_dm_utility.message('INFO','l_request_data ' || l_request_data, 11);
IF (l_request_data IS NOT NULL) THEN
-- unpaused processing...

-- check for error in slave
  l_phase_item_id := TO_NUMBER(l_request_data);

-- find request_id
  OPEN csr_req_id;
  FETCH csr_req_id INTO l_request_id;
  CLOSE csr_req_id;

  l_call_status := fnd_concurrent.get_request_status(l_request_id, '', '',
                                l_phase, l_status, l_dev_phase,
                                l_dev_status, l_message);
-- make sure that each slave is complete and normal, if not then log
  IF ( NOT( (l_dev_phase = 'COMPLETE') AND (l_dev_status = 'NORMAL') )) THEN

-- update status to error
    hr_dm_utility.update_phase_items(p_new_status => 'E',
                                     p_id => l_phase_item_id);
    l_fatal_error_message := 'Sub-slave process in error - slave exiting';
    RAISE e_fatal_error;
  ELSE
-- update status to completed
    hr_dm_utility.update_phase_items(p_new_status => 'C',
                                     p_id => l_phase_item_id);
  END IF;

-- reset request data flag
  l_request_data := '?';
END IF;


-- get status of DA phase, is phase completed?
-- if null returned, then assume it is NS.
l_current_phase_status := NVL(hr_dm_utility.get_phase_status('DA',
                                                     p_migration_id), 'NS');

-- if status is error, then raise an exception
IF (l_current_phase_status = 'E') THEN
  l_fatal_error_message := 'Current phase in error - slave exiting';
  RAISE e_fatal_error2;
END IF;


-- now process remaining rows...


-- fetch a row from the phase items table
OPEN csr_get_pi;
FETCH csr_get_pi INTO l_phase_item_id, l_loader_name,
                      l_status;
IF (csr_get_pi%FOUND) THEN

-- update status to started
  hr_dm_utility.update_phase_items(p_new_status => 'S',
                                   p_id => l_phase_item_id);

-- send info on current table to logfile
  hr_dm_utility.message('INFO','Processing - ' || l_loader_name, 13);


-- call code for AOL loader
  spawn_down(p_migration_id => p_migration_id,
             p_phase_id => l_phase_id,
             p_phase_item_id => l_phase_item_id);


-- pause master whilst slaves process data...
-- set request data to indicate paused phase
    fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                    request_data => l_phase_item_id);

  errbuf := 'No errors - examine logfiles for detailed reports.';
END IF;

IF (csr_get_pi%NOTFOUND) THEN
  errbuf := 'No errors - examine logfiles for detailed reports.';
END IF;

CLOSE csr_get_pi;


-- set up return values to concurrent manager
retcode := 0;
IF (NVL(l_request_data, '?') <> '?') THEN
  errbuf := 'No errors - examine logfiles for detailed reports.';
ELSE
  errbuf := 'Slave Controller is paused.';
END IF;


hr_dm_utility.message('INFO','DA - main controller', 15);
hr_dm_utility.message('SUMM','DA - main controller', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_aol_down.main', 25);
hr_dm_utility.message('PARA','(retcode - ' || retcode ||
                             ')(errbuf - ' || errbuf || ')', 30);

-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  retcode := 2;
  errbuf := 'An error occurred during the migration - ' ||
            'examine logfiles for detailed reports.';
  hr_dm_utility.error(SQLCODE,'hr_dm_aol_down.main',
                      l_fatal_error_message,'DA');
  hr_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  hr_dm_utility.error(SQLCODE,'hr_dm_aol_down.main','(none)','R');
WHEN e_fatal_error2 THEN
  retcode := 0;
  errbuf := 'An error occurred during the migration - ' ||
            'examine logfiles for detailed reports.';
  hr_dm_utility.error(SQLCODE,'hr_dm_aol_down.main',
                      l_fatal_error_message,'DA');
  hr_dm_utility.update_phases(p_new_status => 'E',
                              p_id => l_phase_id);
  hr_dm_utility.error(SQLCODE,'hr_dm_aol_down.main','(none)','R');
WHEN OTHERS THEN
  retcode := 2;
  errbuf := 'An error occurred during the migration - ' ||
            'examine logfiles for detailed reports.';
-- update status to error
  hr_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  hr_dm_utility.error(SQLCODE,'hr_dm_aol_down.main','(none)','R');


--
END main;
--


END hr_dm_aol_down;

/
