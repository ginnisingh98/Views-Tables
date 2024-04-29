--------------------------------------------------------
--  DDL for Package Body HRI_BPL_PYUGEN_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_PYUGEN_WRAPPER" AS
/* $Header: hribpgw.pkb 115.4 2004/05/18 07:04:47 vsethi noship $ */
--
-- -------------------------------------------------------------------------
-- PACKAGE OVERVIEW
-- -------------------------------------------------------------------------
--
-- Purpose
-- -------
-- This package was created to detect if shared HR is installed for
-- processes that require PYUGEN. If shared HR is detected, then either
-- execute a shared HR process or put an appropriate unsupported
-- functionality message in the log and end.
-- Processes can be forced to run in Shared HR Mode by setting the value of
-- profile "HRI:DBI Force Foundation HR Processes" to Yes.
--
-- Requirements
-- ~~~~~~~~~~~~
-- A concurrent process (e.g. HRI_OPL_WMV_WRPR) that executes the executable
-- HRI_BPL_PYUGEN_WRAPPER passing in the parameters:
--      + p_collect_from_date
--      + p_collect_to_date
--      + p_full_refresh
--      + p_attribute1
--      + p_attribute2
--  It IS necessary to pass these parameters into this package from the
--  concurrent process that calls it. However they can be set to NULL,
--  and are not essential for this package to work
--
-- Foundation HR Processing
-- ~~~~~~~~~~~~~~~~~~~~~~~~
-- If shared HR is detected or if the profile value for "HRI:DBI Force
-- Foundation HR Processes" is set to Yes, the following steps will be followed:
--
-- 1. Try to find a concurrent that has the same name as p_collection_name
--    concatenated with '_SHRDHR' (p_collection_name||'_SHRDHR') (For
--    example HRI_MB_WMV_SHRDHR).
-- 2. If the concurrent process is not detected assume this is the intended
--    behaviour and end without error, put an appropriate message in the
--    log.
-- 3. If the concurrent process is detected then execute it passing in the
--    parameters passed into this process when it was called.
--
--    The called process should contain the following procedure to handle
--    default processing when shared HR is not present:
--
--      PROCEDURE shared_hrms_dflt_prcss
--        (
--         errbuf              OUT NOCOPY VARCHAR2
--        ,retcode             OUT NOCOPY NUMBER
--        ,p_collect_from_date IN VARCHAR2 DEFAULT NULL -- Optional Param
--        ,p_collect_to_date   IN VARCHAR2 DEFAULT NULL -- Optional Param
--        ,p_full_refresh      IN VARCHAR2 DEFAULT NULL -- Optional Param
--        ,p_attribute1        IN VARCHAR2 DEFAULT NULL -- Optional Param
--        ,p_attribute2        IN VARCHAR2 DEFAULT NULL -- Optional Param
--        );
--
-- 4. Submit the concurrent process p_collection_name||'_SHRDHR', and wait
--    for it to complete.
--
-- Full HR Processing
-- ~~~~~~~~~~~~~~~~~~
-- If full HR is detected, the following steps will be followed:
-- 3/ Execute the pre-seeded concurrent process 'HRI_PYUGEN_WRAPPER',
--    passing in the parameters:
--      + p_collect_from_date
--      + p_collect_to_date
--      + p_full_refresh
--      + p_attribute1
--      + p_attribute2
--    It is necessary to pass these parameters into this package from the
--    concurrent process that calls it. However they can be set to NULL,
--    and are not essential for this package to work. They only need to be
--    set to something useful if the PYUGEN process that we are
--    going to call needs them.
--
-- -------------------------------------------------------------------------
--
-- GLOBAL CONSTANTS
--
c_OUTPUT_LINE_LENGTH    CONSTANT NUMBER         := 255;
--
-- Global constants used by PEM (Payroll Events Model)
--
c_application         CONSTANT VARCHAR2(30) := 'HRI';
c_report_type         CONSTANT VARCHAR2(30) := 'HISTORIC_SUMMARY';
c_process_name        CONSTANT VARCHAR2(30) := 'ARCHIVE';
c_report_category     CONSTANT VARCHAR2(30) := 'PROCESS';
c_magnetic_file_name  CONSTANT VARCHAR2(30) := TO_CHAR(NULL);
c_report_file_name    CONSTANT VARCHAR2(30) := TO_CHAR(NULL);
c_cncrrnt_prcss_name  CONSTANT VARCHAR2(30) := 'HRI_PYUGEN_WRAPPER';
--
-- -------------------------------------------------------------------------
-- PRIVATE GLOBALS
--
-- Debug and logging globals
--
  g_debugging                  BOOLEAN := FALSE;
  g_concurrent_logging         BOOLEAN := FALSE;
--
-- ----------------------------------------------------------------------------
-- set_debugging
-- Switches debugging messages on or off.
-- ============================================================================
-- Setting to on will mean extra debugging information will be generated when
-- the process is run.
--
PROCEDURE set_debugging(p_on IN BOOLEAN) IS
BEGIN
  --
  g_debugging := p_on;
  --
END set_debugging;
--
-- ----------------------------------------------------------------------------
-- set_concurrent_logging
-- Turns concurrent logging on or off
-- ============================================================================
-- This procedure sets the global g_concurrent_logging to
-- the value passed in. If set log messages will be output
-- through fnd_file.put_line.
--
PROCEDURE set_concurrent_logging(p_on IN BOOLEAN) IS
BEGIN
  --
  g_concurrent_logging := p_on;
  --
END set_concurrent_logging;
--
-- ----------------------------------------------------------------------------
-- msg
-- logs a message, either using fnd_file, or hr_utility.trace
-- ============================================================================
--
PROCEDURE msg(p_text IN VARCHAR2)
IS
  l_pos   NUMBER := 1;
  l_txt   VARCHAR2(255);
BEGIN
  --
  IF g_concurrent_logging
  THEN
    --
    -- Chop up p_text string into 250 char chunks as we are
    -- writing to the concurrent manager log file.
    --
    LOOP
      --
      l_txt := SUBSTR(p_text,l_pos,c_OUTPUT_LINE_LENGTH);
      --
      fnd_file.put_line(fnd_file.LOG,l_txt);
      --
      l_pos := l_pos + c_OUTPUT_LINE_LENGTH;
      --
      EXIT WHEN l_pos > LENGTH(p_text);
      --
    END LOOP;
    --
  ELSE
    --
    -- Use HR trace
    --
    hr_utility.trace(p_text);
    --
  END IF;
  --
END msg;
--
-- ----------------------------------------------------------------------------
-- dbg
-- Decides whether to log the passed in message
-- ============================================================================
-- Depending on whether debug mode is set, decides whether to log the passed
-- in message
--
PROCEDURE dbg(p_text IN VARCHAR2)
IS
  --
BEGIN
  --
--  dbms_output.put_line(p_text);
 -- dbms_output.put_line(sqlerrm);
  IF g_debugging THEN
    --
    msg(p_text);
    --
  END IF;
  --
END dbg;
--
-- ----------------------------------------------------------------------------
-- check_cncrrnt_prcss_exists
-- Checks whether a given concurrent process exists.
-- ============================================================================
--
FUNCTION check_cncrrnt_prcss_exists(p_process_name IN VARCHAR2)
RETURN BOOLEAN IS
  --
  CURSOR c_cncrrnt_prcss(p_process_name IN VARCHAR2) IS
    SELECT 'x'
    FROM Fnd_Concurrent_Programs FCP
    WHERE Concurrent_Program_Name   = Upper (p_process_name)
    AND   application_id            = 453; -- HRI
  --
  l_result VARCHAR2(240);
  --
BEGIN
  --
  dbg('Checking concurrent process '||p_process_name||' exists.');
  --
  -- Check the concurrent process exists
  --
  OPEN c_cncrrnt_prcss(p_process_name);
  FETCH c_cncrrnt_prcss INTO l_result;
  IF c_cncrrnt_prcss%NOTFOUND
  THEN
    --
    dbg('Concurrent Process "'||p_process_name||'" not found.');
    --
    CLOSE c_cncrrnt_prcss;
    --
    -- Return FALSE to indicate that the concurrent process does not exist.
    --
    RETURN FALSE;
    --
  ELSE
    --
    dbg('Concurrent Process "'||p_process_name||'" found.');
    --
    CLOSE c_cncrrnt_prcss;
    --
    -- Return TRUE to indicate that the concurrent process exists.
    --
    RETURN TRUE;
    --
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    dbg('Exception raised in check_cncrrnt_prcss_exists ..');
    RAISE;
    --
END check_cncrrnt_prcss_exists;
--
-- ----------------------------------------------------------------------------
-- process_request
-- This is the main process in this package.
-- ============================================================================
-- This process will either call a PYUGEN concurrent process, a default
-- single threaded shared HR concurrent process (for the process we are
-- trying to execute, or if no process exists exit cleanly putting a suitable
-- message in the log.
--
PROCEDURE process_request
  (--
   -- p_collection_name:
   -- The meta data name of the the PYUGEN process to be executed.
   --
   p_collection_name     IN VARCHAR2
   --
   -- p_business_group_id:
   -- The value for this parameter will be set by the concurrent manager
   -- using default type 'Profile', and default value 'PER_BUSINESS_GROUP_ID'
   --
  ,p_business_group_id   IN VARCHAR2
   --
   -- p_collect_from_date:
   -- The date to start collection from. This is not mandatory, and can be
   -- defaulted to NULL.
   --
  ,p_collect_from_date   IN VARCHAR2 DEFAULT TO_CHAR(NULL)
   --
   -- p_collect_to_date:
   -- The date to run collection to. This is not mandatory, and can be
   -- defaulted to NULL.
   --
  ,p_collect_to_date     IN VARCHAR2 DEFAULT TO_CHAR(NULL)
   --
   -- p_full_refresh:
   -- Whether to run full refresh or not. This is not mandatory, and can be
   -- defaulted to NULL.
   --
  ,p_full_refresh        IN VARCHAR2 DEFAULT TO_CHAR(NULL)
   --
   -- p_attribute1:
   -- Spare attribute field 1. This is not mandatory, and can be
   -- defaulted to NULL.
   --
  ,p_attribute1          IN VARCHAR2 DEFAULT TO_CHAR(NULL)
   --
   -- p_attribute2:
   -- Spare attribute field 1. This is not mandatory, and can be
   -- defaulted to NULL.
   --
  ,p_attribute2          IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  )
IS
  --
  -- Used to store the return value of fnd_conc_global.request_data. If
  -- it is non null then this indicates that the process has returned
  -- from a paused state.
  --
  l_request_data VARCHAR2(240);
  --
  -- Store the request id of the sub process launched to run PYUGEN.
  --
  l_request_id   NUMBER;
  --
  -- Used later to generate the concurrent process name that we attempt to
  -- launch.
  --
  l_cncrrnt_prcss_name VARCHAR2(30);
  --
  -- Local variables used to store details of successfully completed
  -- sub processes.
  --
  l_phase       VARCHAR2(240); -- Dummy output variable that is ignored.
  l_status      VARCHAR2(240); -- Dummy output variable that is ignored.
  l_dev_phase   VARCHAR2(240); -- Dummy output variable that is ignored.
  l_dev_status  VARCHAR2(240); -- Set to NORMAL if the sub process ended
                               -- successfully.
  l_message     VARCHAR2(240); -- Dummy output variable that is ignored.
  l_success     BOOLEAN;
  --
  l_hr_installed         VARCHAR2(30); -- Stores HR installed or not
  l_frc_shrd_hr_prfl_val VARCHAR2(30); -- Variable to store value for
                                       -- Profile HRI:DBI Force Foundation HR Processes
  --
BEGIN
  --
  -- Call fnd_conc_global.request_data, to see if this program is re-entering
  -- after being paused, while the PYUGEN master process completes.
  --
  l_request_data := fnd_conc_global.request_data;
  --
  -- NOTE!!!  THE FOLLOWING CODE WITHIN THE CONDITION:
  -- 'IF l_request_data IS NOT NULL', is only run after re-entering the
  -- package when sub processes have completed.
  -- See the section titled 'INITIAL FLOW THROUGH', for the code that
  -- is run on intial execution.
  --
  -- If the process is re-entering at the end of being paused awaiting PYUGEN
  -- completion, then we have nothing left to do other than end.
  --
  IF l_request_data IS NOT NULL
  THEN
    --
    msg('Re-starting '||p_collection_name||'.');
    --
    -- Get the request_id of the sub process previously executed so that we
    -- can check it's status.
    --
    l_request_id := TO_NUMBER(l_request_data);
    --
    -- Check whether the sub process finished successfully.
    --
    l_success := fnd_concurrent.get_request_status
      (
       request_id      => l_request_id
      ,appl_shortname  => NULL
      ,program         => NULL
      ,phase           => l_phase
      ,status          => l_status
      ,dev_phase       => l_dev_phase
      ,dev_status      => l_dev_status
      ,message         => l_message
      );
    --
    -- Set Varchar2 equivalent (l_success_chr) of l_success
    --
    IF l_success
    THEN
      --
      -- Debug info
      --
      dbg('Sub process finished with status '||l_dev_status||'.');
      --
      -- If l_dev_status 'NORMAL', then that means the sub process was
      -- successful.
      --
      IF l_dev_status <> 'NORMAL'
      THEN
        --
        -- The sub process failed so raise an exception
        --
        msg('The sub process failed. Raising an exception.');
        --
        RAISE  sub_process_failed;
        --
      ELSE
        --
        -- The sub process completed successfully so end.
        --
        msg('All processes have ended successfully.');
        --
        RETURN;
        --
      END IF;
      --
    ELSE
      --
      -- Details of the sub process can not be found for some reason, so
      -- raise an exception.
      --
      msg('An un-expected error has occurred');
      --
      RAISE sub_process_not_found;
      --
    END IF;
    --
  END IF; -- End process re-entered logic.
  --
  -- INITIAL FLOW THROUGH
  -- --------------------
  -- This is the initial flow through this process for this executaion.
  -- If it had not been l_request_data would not have been NULL, and we would
  -- have exited.
  --
  --
  -- If we are in shared HR or if profile HRI:DBI Force Foundation HR Processes has been set
  -- then call the shared HR process (if it exists) or put a suitable message in
  -- the log and end with success.
  --
  --
  msg('Starting '||p_collection_name||'.');
  --
  l_frc_shrd_hr_prfl_val := NVL(fnd_profile.value('HRI_DBI_FORCE_SHARED_HR'),'N');
  l_hr_installed         := hr_general.chk_product_installed(800);
  --
  IF l_hr_installed = 'FALSE'
     OR l_frc_shrd_hr_prfl_val = 'Y'
  THEN
    --
    -- Insert the appropriate message in the log file
    --
    IF l_hr_installed = 'FALSE' THEN
      --
      msg('Foundation HR detected ...');
      --
    ELSIF l_frc_shrd_hr_prfl_val = 'Y' THEN
      --
      msg('Profile HRI:DBI Force Foundation HR Processes has been set. Forcing the Foundation HR version of the process');
      --
    END IF;
    --
    -- Generate concurrent process name to use for shared HR.
    --
    l_cncrrnt_prcss_name := p_collection_name||'_SHRDHR';
    --
    -- Check if the concurrent process we think we need to run exists
    --
    IF check_cncrrnt_prcss_exists(l_cncrrnt_prcss_name) = FALSE
    THEN
      --
      -- Output a message saying that this process is not supported in
      -- shared HR, and end.
      --      --
      msg ('The process '||l_cncrrnt_prcss_name||
           ' is not supported in HR Foundation.');
      --
      RETURN;
      --
    ELSE
      --
      -- execute simplified collection process for shared HRMS based on the
      -- the PYUGEN process being executed.
      --
      msg('Requesting single threaded foundation HR collection process.');
      --
      l_request_id :=
        fnd_request.submit_request
          (
           application => c_application
          ,program     => l_cncrrnt_prcss_name -- Name of concurrent process
          ,sub_request => TRUE -- Indicates that the request should be
                               -- executed as a sub process.
          ,argument1   => p_collect_from_date -- Optional Parameter defaulted
                                              -- to NULL
          ,argument2   => p_collect_to_date   -- Optional Parameter defaulted
                                              -- to NULL
          ,argument3  => p_full_refresh -- Optional Parameter defaulted
                                        -- to NULL
          ,argument4  => p_attribute1 -- Optional Parameter defaulted to NULL
          ,argument5  => p_attribute2 -- Optional Parameter defaulted to NULL
          );
      --
      dbg('Request Submitted for single threaded foundation HR collection '||
          'process.');
      --
      dbg('Telling concurrent manage to wait for sub processes to complete.');
      --
      -- Tell the process to pause awaiting sub process completion.
      --
      fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                      request_data=> TO_CHAR(l_request_id));
      --
      dbg('Waiting for sub processes to complete.');
      --
      RETURN;
      --
    END IF;
  --
  -- IF the following ELSE condition is entered then we have a full HRMS
  -- installation, so we can call the standard refresh process that uses
  --  PYUGEN.
  --
  ELSE
    --
    dbg('Full HR Installation detected ...');
    --
    msg('Requesting multi threaded full HR collection process.');
    --
    -- Call PYUGEN passing through the parameters that process_request was
    -- originally called with.
    --
    l_request_id :=
      fnd_request.submit_request
        (
         application => c_application
        ,program     => c_cncrrnt_prcss_name -- Name of concurrent process
        ,sub_request => TRUE -- Indicates that the request should be
                             -- executed as a sub process.
        ,argument1   => c_process_name -- The type of PYUGEN process. Fixed
                                       -- to 'ARCHIVE'.
        ,argument2   => c_report_type  -- PYUGEN Report type. Fixed to 'C'.
        ,argument3   => p_collection_name -- The seeded name of the PYUGEN
                                          -- process we have created.
        ,argument4   => p_collect_from_date -- PYUGEN Fixed parameter
        ,argument5   => p_collect_to_date -- PYUGEN Fixed parameter
        ,argument6   => c_report_category -- PYUGEN Fixed parameter
                                          -- 'PROCESS'
        ,argument7   => p_business_group_id -- PYUGEN parameter, based on
                                            -- profile option
                                            -- PER_BUSINESS_GROUP_ID
        ,argument8   => c_magnetic_file_name -- PYUGEN Fixed parameter
                                             -- (IGNORED)
        ,argument9   => c_report_file_name -- PYUGEN Fixed parameter
                                           -- (IGNORED)
        ,argument10  => p_full_refresh -- Optional Parameter defaulted
                                       -- to NULL
        ,argument11  => p_attribute1   -- Optional Parameter defaulted
                                       -- to NULL
        ,argument12  => p_attribute2   -- Optional Parameter defaulted
                                       -- to NULL
      );
    --
    dbg('Request Submitted for multi threaded full HR collection '||
        'process.');
    --
    dbg('Telling concurrent manager to wait for sub processes to complete.');
    --
    --
    -- Tell the process to pause awaiting sub process completion.
    --
    fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                    request_data=> TO_CHAR(l_request_id));
    --
    RETURN;
    --
  END IF; -- hr_general.chk_product_installed(800) = 'FALSE'
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    msg('Exception found in HRI PYUGEN Wrapper process ..');
    dbg(SQLERRM);
    --
    RAISE;
  --
END process_request;
--
-- ----------------------------------------------------------------------------
-- process_request
-- ============================================================================
-- Overloaded version of process_request to be called from the concurrent
-- manager.
--
PROCEDURE process_request
  (errbuf                OUT NOCOPY VARCHAR2
  ,retcode               OUT NOCOPY NUMBER
  ,p_collection_name     IN VARCHAR2
  ,p_business_group_id   IN VARCHAR2
  ,p_collect_from_date   IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  ,p_collect_to_date     IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  ,p_full_refresh        IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  ,p_attribute1          IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  ,p_attribute2          IN VARCHAR2 DEFAULT TO_CHAR(NULL)
  )
IS
  --
BEGIN
  --
  -- Set concurrent logging on.
  --
  set_concurrent_logging(TRUE);
  --
  process_request
            (p_collection_name    => p_collection_name
            ,p_business_group_id  => p_business_group_id
            ,p_collect_from_date  => p_collect_from_date
            ,p_collect_to_date    => p_collect_to_date
            ,p_full_refresh       => p_full_refresh
            ,p_attribute1         => p_attribute1
            ,p_attribute2         => p_attribute2
            );
  --
EXCEPTION
  WHEN OTHERS
  THEN
    --
    errbuf := SQLERRM;
    retcode := SQLCODE;
    RAISE;
    --
  --
END process_request;
--
END hri_bpl_pyugen_wrapper;

/
