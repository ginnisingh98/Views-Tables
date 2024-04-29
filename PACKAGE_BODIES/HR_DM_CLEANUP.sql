--------------------------------------------------------
--  DDL for Package Body HR_DM_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_CLEANUP" AS
/* $Header: perdmclu.pkb 120.0 2005/05/31 17:05:41 appldev noship $ */


/*--------------------------- PRIVATE ROUTINES ---------------------------*/

-- ------------------------- spawn_cleanup ------------------------
-- Description: The requested loader is spawned and details are entered into
-- the hr_dm_migration_requests table (via hr_dm_master.insert_request).
--
--
--  Input Parameters
--        p_migration   - migration id
--
--        p_phase_id    - of phase
--
--        p_phase_item  - of phase item
--
--        p_loader_name - loader to be spawned
--
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE spawn_cleanup(p_migration_id IN NUMBER,
                        p_phase_id IN NUMBER,
                        p_phase_item_id IN NUMBER
                        ) IS
--

e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);
l_phase_id NUMBER;
l_request_id NUMBER;
l_loader_name VARCHAR2(30);
l_loader_conc_program VARCHAR2(30);
l_loader_config_file VARCHAR2(30);
l_loader_application VARCHAR2(50);
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
l_application_id NUMBER;


CURSOR csr_data IS
  SELECT tbl.loader_name,
         tbl.loader_conc_program,
         tbl.loader_config_file,
         tbl.loader_application,
         lp.parameter1, lp.parameter2,
         lp.parameter3, lp.parameter4,
         lp.parameter4, lp.parameter6,
         lp.parameter5, lp.parameter8,
         lp.parameter7, lp.parameter10,
         lp.application_id
  FROM hr_dm_tables tbl,
       hr_dm_loader_params lp,
       hr_dm_phase_items pi
  WHERE (pi.phase_item_id = p_phase_item_id)
    AND (pi.loader_params_id = lp.loader_params_id)
    AND (lp.table_id = tbl.table_id);


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_cleanup.spawn_cleanup', 5);
hr_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id ||
                             '(p_phase_id - ' || p_phase_id ||
                             '(p_phase_item_id - ' || p_phase_item_id ||
                             ')', 10);


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
         l_application_id;
IF (csr_data%NOTFOUND) THEN
  l_fatal_error_message := 'Unable to find loader configuration data.';
  RAISE e_fatal_error;
END IF;
CLOSE csr_data;



hr_dm_utility.message('INFO','Spawning ' || l_loader_name, 15);

hr_dm_utility.message('INFO','application ' || l_loader_application, 115);
hr_dm_utility.message('INFO','program ' || l_loader_conc_program, 115);
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
                      program => l_loader_conc_program,
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



-- update table hr_dm_migration_requests
hr_dm_master.insert_request(p_phase => 'C',
                            p_request_id => l_request_id,
                            p_master_slave => 'S',
                            p_migration_id => p_migration_id,
                            p_phase_id => p_phase_id,
                            p_phase_item_id => p_phase_item_id);


COMMIT;

hr_dm_utility.message('INFO','Slave request ID#' || l_request_id, 15);
IF (l_request_id = 0) THEN
    l_fatal_error_message := 'Unable to start slave process';
    hr_dm_master.report_error('C', p_migration_id, l_fatal_error_message,
                              'P');
    RAISE e_fatal_error;
END IF;



hr_dm_utility.message('INFO','Spawned C slave', 115);
hr_dm_utility.message('SUMM','Spawned C slave', 120);
hr_dm_utility.message('ROUT','exit:hr_dm_cleanup.spawn_cleanup', 125);
hr_dm_utility.message('PARA','(none)', 130);


-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_cleanup.spawn_cleanup',
                      l_fatal_error_message,'R');
  hr_dm_master.report_error('C', p_migration_id,
                            'Error in hr_dm_cleanup.spawn_cleanup', 'P');
  RAISE;
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_cleanup.spawn_cleanup','(none)','R');
  hr_dm_master.report_error('C', p_migration_id,
                            'Untrapped error in hr_dm_cleanup.spawn_cleanup',
                            'P');
  RAISE;

--
END spawn_cleanup;
--





/*--------------------------- PUBLIC ROUTINES ----------------------------*/

-- ------------------------- main ------------------------
-- Description: This is the cleanup phase slave. It reads an item from the
-- hr_dm_phase_items table for the cleanup phase and calls the appropriate
-- code (spawn_cleanup) to spawn slaves to process each phase item.
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
      AND (pi.loader_name = tbl.loader_name);


CURSOR csr_req_id IS
  SELECT request_id
    FROM hr_dm_migration_requests
    WHERE phase_item_id = l_phase_item_id;

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

hr_dm_utility.message('ROUT','entry:hr_dm_cleanup.main', 5);
hr_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id ||
                             ')(p_last_migration_date - ' ||
                             p_last_migration_date ||
                             ')', 10);

-- get the current phase_id
l_phase_id := hr_dm_utility.get_phase_id('C', p_migration_id);


-- get the business_group_id
OPEN csr_migration_info;
FETCH csr_migration_info INTO l_business_group_id;
IF csr_migration_info%NOTFOUND THEN
  CLOSE csr_migration_info;
  l_fatal_error_message := 'hr_dm_cleanup.main :- Migration Id ' ||
                            TO_CHAR(p_migration_id) || ' not found.';
  RAISE e_fatal_error2;
END IF;
CLOSE csr_migration_info;

-- get the number of threads to enable modulus locking
l_no_of_threads := hr_dm_utility.number_of_threads(l_business_group_id);


-- get status of C phase, is phase completed?
-- if null returned, then assume it is NS.
l_current_phase_status := NVL(hr_dm_utility.get_phase_status('C',
                                                     p_migration_id), 'NS');

-- if status is error, then raise an exception
IF (l_current_phase_status = 'E') THEN
  l_fatal_error_message := 'Current phase in error - slave exiting';
  RAISE e_fatal_error2;
END IF;


-- see if this is the first run? (l_request_data = NULL or '?')
-- or
-- is it a restart after a slave has finished? (l_request_data = paused phase
-- item code)
l_request_data := fnd_conc_global.request_data;
hr_dm_utility.message('INFO','l_request_data ' || l_request_data, 11);
IF (NVL(l_request_data, '?') IS NOT NULL) THEN
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

END IF;


-- get status of C phase, is phase completed?
-- if null returned, then assume it is NS.
l_current_phase_status := NVL(hr_dm_utility.get_phase_status('C',
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


-- call code for cleanup item
  spawn_cleanup(p_migration_id => p_migration_id,
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


hr_dm_utility.message('INFO','C - main controller', 15);
hr_dm_utility.message('SUMM','C - main controller', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_cleanup.main', 25);
hr_dm_utility.message('PARA','(retcode - ' || retcode ||
                             ')(errbuf - ' || errbuf || ')', 30);

-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  retcode := 2;
  errbuf := 'An error occurred during the migration - examine logfiles ' ||
            'for detailed reports.';
  hr_dm_utility.error(SQLCODE,'hr_dm_cleanup.main',l_fatal_error_message,
                      'C');
  hr_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  hr_dm_utility.error(SQLCODE,'hr_dm_cleanup.main','(none)','R');
WHEN e_fatal_error2 THEN
  retcode := 0;
  errbuf := 'An error occurred during the migration - examine logfiles ' ||
            'for detailed reports.';
  hr_dm_utility.error(SQLCODE,'hr_dm_cleanup.main',l_fatal_error_message,
                      'C');
  hr_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  hr_dm_utility.error(SQLCODE,'hr_dm_cleanup.main','(none)','R');
WHEN OTHERS THEN
  retcode := 2;
  errbuf := 'An error occurred during the migration - examine logfiles ' ||
            'for detailed reports.';
-- update status to error
  hr_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  hr_dm_utility.error(SQLCODE,'hr_dm_cleanup.main','(none)','R');


--
END main;
--


-- ------------------------- post_cleanup_process ------------------------
-- Description: This procedure can be used to call any code for the cleanup
-- phase that is not multi-threaded.
--
--
--  Input Parameters
--        r_migration_data  - migration record
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE post_cleanup_process(r_migration_data IN
                                           hr_dm_utility.r_migration_rec) IS
--


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_cleanup.post_cleanup_process', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);


--
-- non-concurrent program code for clean up phase
--
-- to be added...
--               ...if required
--


hr_dm_utility.message('INFO','Clean Up - non CM', 15);
hr_dm_utility.message('SUMM','Clean Up - non CM', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_cleanup.post_cleanup_process', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_cleanup.post_cleanup_process',
                      '(none)','R');
  RAISE;

--
END post_cleanup_process;
--


END hr_dm_cleanup;

/
