--------------------------------------------------------
--  DDL for Package Body HR_DM_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_UPLOAD" AS
/* $Header: perdmup.pkb 120.0 2005/05/30 21:17:52 appldev noship $ */


/*---------------------------- PRIVATE ROUTINES -----------------------------*/

--
PROCEDURE spawn_slave(p_current_phase  IN VARCHAR2,
                      p_migration_id   IN NUMBER,
                      p_phase_id       IN NUMBER,
                      p_phase_item_id  IN NUMBER,
                      p_batch_id        IN NUMBER ) IS
--

l_request_id           NUMBER;
e_fatal_error          EXCEPTION;
l_fatal_error_message  VARCHAR2(200);
l_application          VARCHAR2(30);
l_program              VARCHAR2(30);


--
BEGIN
  --

  hr_dm_utility.message('ROUT','entry:hr_dm_upload.spawn_slave', 5);

  -- set up local data
  l_application := 'PER';
  l_program := 'DATAPUMP';

  -- spawn slave

  l_request_id := fnd_request.submit_request(
                                  application => l_application,
                                  program => l_program,
                                  sub_request => TRUE,
                                  argument1 => p_batch_id,
                                  argument2 => 'N' );


  -- update table hr_dm_migration_requests
  hr_dm_master.insert_request(p_phase         => p_current_phase,
                              p_request_id    => l_request_id,
                              p_master_slave  => 'S',
                              p_migration_id  => p_migration_id,
                              p_phase_id      => p_phase_id,
                              p_phase_item_id => p_phase_item_id);


  COMMIT;
  hr_dm_utility.message('INFO','Slave request ID#' || l_request_id, 15);
  IF (l_request_id = 0) THEN
      l_fatal_error_message := 'Unable to start slave process';
      hr_dm_master.report_error(p_current_phase, p_migration_id, l_fatal_error_message, 'P');
      RAISE e_fatal_error;
  END IF;


  hr_dm_utility.message('INFO','Spawned datapump as slave process', 15);
  hr_dm_utility.message('SUMM','Spawned datapump as slave process', 20);
  hr_dm_utility.message('ROUT','exit:hr_dm_upload.spawn_slave', 25);
  hr_dm_utility.message('PARA','(none)', 30);


  -- error handling
EXCEPTION
  WHEN e_fatal_error THEN
    hr_dm_utility.error(SQLCODE,'hr_dm_upload.spawn_slave',l_fatal_error_message,'R');
    hr_dm_master.report_error(p_current_phase, p_migration_id,
                             'Error in hr_dm_upload.spawn_slave', 'P');
    RAISE;
  WHEN OTHERS THEN
    hr_dm_utility.error(SQLCODE,'hr_dm_upload.spawn_slave','(none)','R');
    hr_dm_master.report_error(p_current_phase, p_migration_id,
                             'Untrapped error in hr_dm_upload.spawn_slave', 'P');
    RAISE;
  --
END spawn_slave;
--


/*---------------------------- PUBLIC ROUTINES ------------------------------*/

-- ------------------------- main ------------------------
-- Description: This is the upload phase slave. It reads an item from the
-- hr_dm_phase_items table for the upload phase. It spawns the slave process
-- to start data pump which in turns spawns multiple processes to process
-- a batch or group of table. If the group is uploaded succesfully, then the
-- above process is repeated for an unprocessed batch to be uploaded from
-- hr_dm_phase_items table. When all the upload batches are finished in
-- hr_dm_phase_items table then the processing is stopped.
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
--        p_process_number      - process number given to slave process by
--                                master process. The first process gets
--                                number 1, second gets number 2 and so on
--                                the maximum nuber being equal to the
--                                number of threads.
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
               p_process_number       IN   NUMBER
               ) IS
--
l_dummy   number;
l_current_phase_status VARCHAR2(30);
l_phase_id NUMBER;
e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);
e_slave_error EXCEPTION;
l_slave_error_message VARCHAR2(200);
l_status VARCHAR2(30);
l_batch_id NUMBER;
l_phase_item_id NUMBER;
l_request_data VARCHAR2(100);
l_request_id NUMBER;
l_call_status BOOLEAN;
l_phase VARCHAR2(30);
l_dev_phase VARCHAR2(30);
l_dev_status VARCHAR2(30);
l_message VARCHAR2(240);


-- get the unprocessed groups to upload
CURSOR csr_get_pi IS
  SELECT pi.phase_item_id,
         pi.status,
         pi.batch_id
  FROM  hr_dm_phase_items pi,
        hr_dm_application_groups apg
  WHERE pi.status = 'NS'
  AND pi.phase_id = l_phase_id
  AND pi.group_id = apg.group_id
  ORDER BY apg.group_order;


-- get the details of the last data pump process spawned by this slave process.
CURSOR csr_req_id IS
  SELECT req.request_id,
         pi.batch_id
  FROM hr_dm_migration_requests req,
       hr_dm_phase_items pi
  WHERE pi.phase_item_id = l_phase_item_id
  and   pi.phase_item_id = req.phase_item_id;


-- check whether all the child processes spawned by datapump has been completed.
-- This cursor checks is there any process which is still running.

CURSOR csr_chk_dp_child_proc_status (p_request_id  number) IS
  SELECT 1
  FROM fnd_concurrent_requests
  WHERE parent_request_id = p_request_id
  AND   phase_code <> 'C';

-- get info  of all the data pump processes which failed.
CURSOR csr_failed_dp_child_proc (p_request_id  number) IS
  SELECT request_id
  FROM fnd_concurrent_requests
  WHERE (parent_request_id = p_request_id OR
         request_id = p_request_id)
  AND   status_code <> 'C';

-- get the status of data pump process spawned by this slave process. Read the status
-- from hr_pump_batch_headers table.

CURSOR csr_dp_batch_status IS
  SELECT batch_status
  FROM hr_pump_batch_headers
  WHERE batch_id = l_batch_id;
--
BEGIN
  --

  -- initialize messaging (only for concurrent processing)
  IF (p_concurrent_process = 'Y') THEN
    hr_dm_utility.message_init;
  END IF;

  hr_dm_utility.message('ROUT','entry:hr_dm_upload.main', 5);
  hr_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id ||
                               ')(p_last_migration_date - ' || p_last_migration_date ||
                               ')', 10);


  -- Set the variable so as to disable the trigger on the table.
  hr_general.g_data_migrator_mode := 'Y';

  -- set the profile to disable the audit trigger
  fnd_profile.put (name => 'AUDITTRAIL:ACTIVATE'
                  ,val => 'N'
                  );

  -- get the current phase_id
  l_phase_id := hr_dm_utility.get_phase_id('UP', p_migration_id);


  -- see if this is the first run? (l_request_data = NULL or '?')
  -- or
  -- is it a restart after a slave has finished? (l_request_data = paused phase item code)

  l_request_data := fnd_conc_global.request_data;
  hr_dm_utility.message('INFO','l_request_data ' || l_request_data, 11);

  --
  -- l_request_data will be 'null' when the upload process is invoked by the
  -- concurrent manager. It then spawns the data pump and pauses until the datapump
  -- finsh processing. It is re-started automatically after data pump processing
  -- is completed. l_request_data will contain the value set before pausing this
  -- program.
  --

  IF l_request_data IS NOT NULL THEN

    -- It is a restart after a slave process has finished.

    -- get the phase_item_id stored in request_data i.e Upload group processed by the slave
    -- process.

    l_phase_item_id := TO_NUMBER(l_request_data);

    -- find details about the finished slave process like request_id and data pump batch
    -- which it processed.
    --

    OPEN csr_req_id;
    FETCH csr_req_id INTO l_request_id,
                          l_batch_id;
    IF csr_req_id%NOTFOUND THEN
      CLOSE csr_req_id;
      l_fatal_error_message := 'Could not find the details of phase by slave ' ||
                               'process. l_phase_item_id = ' || to_char(l_phase_item_id);
      RAISE e_fatal_error;
    END IF;
    CLOSE csr_req_id;

    -- check whether all the data pump slave processes have been completed, if not then
    -- sleep for 5 seconds. Sleep is implemented by reading from a non-existant pipe,
    -- using time out feature to give delay time.
    LOOP
       OPEN csr_chk_dp_child_proc_status (l_request_id);
       FETCH csr_chk_dp_child_proc_status INTO l_dummy;

       -- if no row found it means all child processes spawned by datapump have been
       -- completed hence exit this loop.

       IF csr_chk_dp_child_proc_status%NOTFOUND THEN
          EXIT;
       END IF;
       CLOSE csr_chk_dp_child_proc_status;

       -- some datapump child processes are still running. Pause this process
       -- for 5 seconds and check the status again after 5 seconds.

       l_dummy := DBMS_PIPE.RECEIVE_MESSAGE('temporary_unused_hrdm_pipe', 5);

    END LOOP;

    -- All the datapump child processes are completed. Get the status of data pump
    -- batch header.

    OPEN csr_dp_batch_status;
    FETCH csr_dp_batch_status INTO l_status;
    IF csr_dp_batch_status%NOTFOUND THEN
      CLOSE csr_dp_batch_status;
      l_fatal_error_message := 'Could not find the data pump batch for ' ||
                               'l_batch_id = ' || to_char(l_batch_id);
      RAISE e_fatal_error;
    END IF;
    CLOSE csr_dp_batch_status;

     hr_dm_utility.message('INFO','Data Pump batch status ' || l_status, 12);

    -- if l_status = 'C', it means the group has been uploaded successfully.
    --    - update the group status to complete in phase_items.
    --    - check the status of the child process so as if any has erred then
    --       write to log file for information purpose. This is for information
    --       only as it does not matter if one of the child process has error as
    --       far as group is uploaded successfully by other slave processes.
    -- if status is other than 'C', it means group has not been uploaded
    -- succesfully.

    IF l_status = 'C' then
      -- update status to completed
      hr_dm_utility.update_phase_items(p_new_status => 'C',
                                       p_id => l_phase_item_id);

      -- check if any data pump child process failed by checking status of
      -- all the data pump process status.

      FOR csr_failed_dp_child_proc_rec in csr_failed_dp_child_proc (l_request_id)
      LOOP

         -- write into log file about the failed child processes.
         hr_dm_utility.message('INFO','Warning :- Failed Data Pump process ' ||
                               'request_id =' || TO_CHAR(l_request_id), 13);
      END LOOP;

    ELSE
      l_fatal_error_message := 'Batch not uploaded successfully for phase_item_id = ' ||
                              to_char(l_phase_item_id) || ' - slave exiting.';
      RAISE e_fatal_error;
    END IF;

    -- set the concurrent process global var to null.
    l_request_data := NULL;
  END IF;


  -- get status of UP phase, is phase completed?
  -- if null returned, then assume it is NS.
  l_current_phase_status := NVL(hr_dm_utility.get_phase_status('UP', p_migration_id), 'NS');

  -- if status is error, then raise an exception
  IF (l_current_phase_status = 'E') THEN
    l_slave_error_message := 'Current phase in error - slave exiting';
    RAISE e_slave_error;
  END IF;

  --
  -- if it is first call to submit the data pump request then l_status value will be null.
  -- For subsequent calls it depends whether the group has been uploaded successfully by
  -- previous data pump procedure. If the previous process has failed then we have to stop
  -- the upload process.
  --

  IF NVL(l_status,'OK') <> 'E' then
    -- Get the unprocessed group to br uploaded from phase items table to upload.
    OPEN csr_get_pi;
    FETCH csr_get_pi INTO l_phase_item_id,
                          l_status,
                          l_batch_id;
    IF (csr_get_pi%FOUND) THEN

      close csr_get_pi;
      -- update status to started
      hr_dm_utility.update_phase_items(p_new_status => 'S',
                                       p_id => l_phase_item_id);

      -- send info on current table to logfile
      hr_dm_utility.message('INFO','Processing batch- ' || l_batch_id , 13);


      -- call code to trigger data pump to upload the data.

      spawn_slave(p_current_phase => 'UP',
                  p_migration_id  => p_migration_id,
                  p_phase_id      => l_phase_id,
                  p_phase_item_id => l_phase_item_id,
                  p_batch_id      => l_batch_id);


      -- pause master whilst slaves process data...
      -- set request data to indicate paused phase
      fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                      request_data => l_phase_item_id);

      errbuf := 'No errors - examine logfiles for detailed reports.';
    ELSE
      close csr_get_pi;
    END IF;
  END IF; --   NVL(l_status,'OK') <> 'E'


  -- set up return values to concurrent manager
  retcode := 0;
  IF (NVL(l_request_data, '?') <> '?') THEN
    errbuf := 'No errors - examine logfiles for detailed reports.';
  ELSE
    errbuf := 'Slave Controller is paused.';
  END IF;


  hr_dm_utility.message('INFO','UP - main controller', 15);
  hr_dm_utility.message('SUMM','UP - main controller', 20);
  hr_dm_utility.message('ROUT','exit:hr_dm_upload.main', 25);
  hr_dm_utility.message('PARA','(retcode - ' || retcode ||
                               ')(errbuf - ' || errbuf || ')', 30);

  -- error handling
EXCEPTION
  WHEN e_fatal_error THEN
    retcode := 2;
    errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
    hr_dm_utility.error(SQLCODE,'hr_dm_upload.main',l_fatal_error_message,'R');
    hr_dm_utility.update_phase_items(p_new_status => 'E',
                                     p_id => l_phase_item_id);
    hr_dm_utility.error(SQLCODE,'hr_dm_upload.main','(none)','R');
  WHEN e_slave_error THEN
    retcode := 0;
    errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
    hr_dm_utility.error(SQLCODE,'hr_dm_upload.main',l_fatal_error_message,'R');
    hr_dm_utility.error(SQLCODE,'hr_dm_upload.main','(none)','R');
  WHEN OTHERS THEN
    retcode := 2;
    errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
  -- update status to error
    hr_dm_utility.update_phase_items(p_new_status => 'E',
                                     p_id => l_phase_item_id);
    hr_dm_utility.error(SQLCODE,'hr_dm_upload.main','(none)','R');

--
END main;
--


-- ------------------------- set_globals ------------------------
-- Description: This function is called from the header of each TUPs package
-- to ensure that the global variables are set for the current session.
-- The return value is a dummy value (can be any number).
--
--
--  Input Parameters
--        <none>
--
--  Output Parameters
--        1  - dummy value
--
--
-- ------------------------------------------------------------------------
--
FUNCTION set_globals RETURN NUMBER IS
--

e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);


CURSOR csr_src_db IS
  SELECT source_database_instance
    FROM hr_dm_migrations
    WHERE status NOT IN ('F', 'A');

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_upload.set_globals', 5);
hr_dm_utility.message('PARA','(none)', 10);

-- Set the variable so as to disable the trigger on the table.
hr_general.g_data_migrator_mode := 'Y';

-- set the profile to disable the audit trigger
fnd_profile.put (name => 'AUDITTRAIL:ACTIVATE'
                ,val => 'N'
                );

-- store the current migration's source_database_name
-- for access from the TUPS
OPEN csr_src_db;
FETCH csr_src_db INTO hr_dm_upload.g_data_migrator_source_db;
CLOSE csr_src_db;

HR_DATA_PUMP.message('source db is - ' ||
                     NVL(hr_dm_upload.g_data_migrator_source_db, '<null>'));

IF hr_dm_upload.g_data_migrator_source_db IS NULL THEN
  l_fatal_error_message := 'No Started migration could be identified.';
  RAISE e_fatal_error;
END IF;



hr_dm_utility.message('INFO','UP - main controller', 15);
hr_dm_utility.message('SUMM','UP - main controller', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_upload.set_globals', 25);
hr_dm_utility.message('PARA','(1 - 1)', 30);


RETURN(1);

EXCEPTION
WHEN e_fatal_error THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_upload.set_globals',
                      l_fatal_error_message,'R');

WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_upload.set_globals','(none)','R');
  RAISE;

--
END set_globals;
--


END hr_dm_upload;

/
