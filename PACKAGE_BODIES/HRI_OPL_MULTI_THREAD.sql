--------------------------------------------------------
--  DDL for Package Body HRI_OPL_MULTI_THREAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_MULTI_THREAD" AS
/* $Header: hriomthd.pkb 120.8 2007/01/18 07:24:56 anmajumd noship $ */
--
-- Main Entry Point from Concurren Manager
--
g_chunk                                NUMBER := 20;
g_slave_count                          NUMBER := 8;
g_errbuf                               VARCHAR2(2000);
g_retcode                              NUMBER;
--
-- Global variable used for caching mthd_range_id
--
g_mthd_range_id                        NUMBER;
--
-- Variable for setting the debug mode
--
g_debug_flag                           VARCHAR2(30) := NVL(fnd_profile.value('HRI_ENBL_DTL_LOG'),'N');
g_program                              VARCHAR2(30) ;
g_mode                                 VARCHAR2(30) := 'N';
g_mthd_action_id                       NUMBER;
g_error_request_id                     NUMBER;
--
-- Table Type for storing the request_id's for all child threads.
--
TYPE g_num_tab is table  of NUMBER INDEX BY BINARY_INTEGER;
--
-- Table for storing the concurrent request ID's
--
g_child_request_tab  g_num_tab;
--
-- EXCEPTIONS
--
error_launching_thread                 EXCEPTION;
no_sql_returned                        EXCEPTION;
no_ranges_to_process                   EXCEPTION;
invalid_program                        EXCEPTION;
--
PRAGMA EXCEPTION_INIT(invalid_program, -6550);
--
-- -----------------------------------------------------------------------------
-- Procedure Call Sequence (Forward Declaration)
-- The PROCESS rotine is invoked from the concurrent manager. The following
-- procedure are called sequence to multithreading the collection process
-- by the process routine
--
PROCEDURE process;
  --
  -- 1. Start Multithreading Process
  --
  PROCEDURE do_multithreading;
    --
    -- 1.1 Generate Multi Thread Action
    --
    PROCEDURE gen_multi_thread_action;
    --
    -- 1.2 Generate Object Ranges (public in package spec)
    --
    -- PROCEDURE gen_object_range(g_mthd_action_array.mthd_action_id);
    --
    -- 1.3 Start Threads
    --
    PROCEDURE start_threads;
  --
  -- 2. Process Range
  --
  PROCEDURE process_range(p_program                IN            VARCHAR2,
                          p_mthd_action_id         IN            NUMBER,
                          p_errbuf                    OUT NOCOPY VARCHAR2,
                          p_retcode                   OUT NOCOPY NUMBER );
  --
  -- 3. Wait for Child Threads to complete Processing
  --
  PROCEDURE watch_child_processes(p_slave_errored out nocopy boolean);
  --
  -- 4. End Multithreading Process
  --
  PROCEDURE end_multithreading;
    --
    -- 4.1 Run the post process
    --
    PROCEDURE run_program_post_process;
    --
    -- 4.2 Update Multithread Action Status
    --
    PROCEDURE set_action_status;
  --
  PROCEDURE set_range_error(p_mthd_action_id NUMBER);
  --
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log
-- -----------------------------------------------------------------------------
--
PROCEDURE output(p_text  VARCHAR2) IS
--
BEGIN
  --
  -- Bug 4105868: Collection Diagnostic
  --
  HRI_BPL_CONC_LOG.output(p_text);
  --
END output;
--
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log if debugging is enabled
-- -----------------------------------------------------------------------------
--
PROCEDURE dbg(p_text  VARCHAR2) IS
--
BEGIN
  --
  -- Bug 4105868: Collection Diagnostic
  --
  HRI_BPL_CONC_LOG.dbg(p_text);
  --
END dbg;
--
-- ----------------------------------------------------------------------------
-- Runs given sql statement dynamically
-- ----------------------------------------------------------------------------
--
PROCEDURE run_sql_stmt_noerr( p_sql_stmt   VARCHAR2 )
IS
--
BEGIN
  --
  dbg(p_sql_stmt);
  --
  EXECUTE IMMEDIATE p_sql_stmt;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    output('Error running sql:');
    output(SUBSTR(p_sql_stmt,1,230));
    --
  --
END run_sql_stmt_noerr;
--
-- ----------------------------------------------------------------------------
-- Procedure   : GET_NEXT_MTHD_RANGE_ID
-- Description : This procedure is used for classifying the object records into
--               a range. Based on this classification the object records are
--               grouped into ranges. This logic is that for every nth rownum
--               the function will get a new range id otherwise it will return
--               the value in cache. Here n is the chunk size option value.
-- ----------------------------------------------------------------------------
--
FUNCTION get_next_mthd_range_id
                 (p_rownum number
                 ,p_chunk  number
                 )
RETURN NUMBER IS
--
BEGIN
  --
  -- only when the rownum is a multiple of the chunk read a seqence
  -- otherwise return the previous range stored in the cache.
  --
  IF mod(p_rownum,p_chunk) = 0 OR
     g_mthd_range_id is null THEN
    --
    select hri_adm_mthd_ranges_s.nextval
    into   g_mthd_range_id
    from   dual;
    --
  END IF;
  --
  RETURN g_mthd_range_id;
  --
END get_next_mthd_range_id;
--
-- ----------------------------------------------------------------------------
-- Procedure   : GET_ERROR_REQUEST
-- Description : This procedure populate the global variable with the request_id
--               of the erroring thread
-- ----------------------------------------------------------------------------
--
FUNCTION get_error_request(p_mthd_action_id  NUMBER)
RETURN NUMBER IS
  --
  l_error_request_id NUMBER;
  --
  CURSOR c_error_request IS
  SELECT err_thread_request_id
  FROM   hri_adm_mthd_ranges
  WHERE  mthd_action_id = p_mthd_action_id
  AND    status = 'ERROR'
  AND    rownum = 1;
  --
BEGIN
  --
  IF g_error_request_id is null THEN
    --
    OPEN   c_error_request;
    FETCH  c_error_request INTO l_error_request_id;
    CLOSE  c_error_request;
    --
  END IF;
  --
  RETURN  l_error_request_id;
  --
END get_error_request;
--
-- ----------------------------------------------------------------------------
-- Waits for previously submitted multi-thread processes within same request
-- set to complete before continuing with the current one
-- ----------------------------------------------------------------------------
--
PROCEDURE wait_for_other_mthds IS

  -- Return count of unfinished multi-threading processes
  -- that have been submitted before the current process
  -- within the same request set
  CURSOR mtmasters_cur IS
  SELECT count(req.request_id) count
  FROM fnd_concurrent_programs cp
    ,fnd_executables ex
    ,fnd_concurrent_requests req
  WHERE ex.executable_id       = cp.executable_id
  AND cp.concurrent_program_id = req.concurrent_program_id
  AND ex.application_id        = cp.EXECUTABLE_APPLICATION_ID
  AND cp.application_id        = req.PROGRAM_APPLICATION_ID
-- Restrict to non-complete multi-threading processes
  AND ex.executable_name       = 'HRI_OPL_MULTI_THREAD'
  AND req.PHASE_CODE <> 'C'
-- Requests previously submitted within the same request set
  AND req.request_id IN
         (SELECT req1.request_id
          FROM fnd_concurrent_requests req1
          WHERE req1.priority_request_id =
-- Subquery for requests in request set
                   (SELECT req2.priority_request_id
                    FROM fnd_concurrent_requests req2
                    WHERE req2.request_id = fnd_global.conc_request_id)
-- Filter on previously submitted requests only
          AND req1.request_id < fnd_global.conc_request_id);

  l_priority_count  NUMBER;
  l_sleep           NUMBER;

BEGIN

   -- Take a count of the requests of higher priority at hand
   OPEN mtmasters_cur;
   FETCH mtmasters_cur INTO l_priority_count;
   CLOSE mtmasters_cur;

   -- Author  : SMOHAPAT
   -- IF there are requests of higher priority
   -- THEN Sleep and dont start the process at hand,
   -- A l_priority_count = 0 means this is the request to be run immediately.
   -- A l_priority_count > 0 means its not of higher priority.
   -- So wait for higher priority requests to run and hibernate the one at hand.
   WHILE (l_priority_count > 0) LOOP

       l_sleep := dbms_pipe.receive_message
                  (pipename => 'non-existant pipe to force timeout',
                   timeout  => 20);

   -- Is the higher priority req. count zero now, take a poll here.
       OPEN mtmasters_cur;
       FETCH mtmasters_cur INTO l_priority_count;
       CLOSE mtmasters_cur;

   END LOOP;

END wait_for_other_mthds;
--
--
-- ----------------------------------------------------------------------------
-- Procedure   : WAIT_FOR_LOWER_LEVELS
-- Description : Checks processing is complete for lower hierarchy levels
-- ----------------------------------------------------------------------------
--
PROCEDURE wait_for_lower_levels(p_mthd_action_id       IN NUMBER
                               ,p_mthd_range_lvl_order IN NUMBER) IS

  CURSOR lower_hrchy_req_cur IS
  SELECT count(*)
  FROM hri_adm_mthd_ranges
  WHERE mthd_action_id = p_mthd_action_id
  AND status IN ('UNPROCESSED','PROCESSING')
  AND mthd_range_lvl_order < p_mthd_range_lvl_order;

  l_lower_hrchy_count      NUMBER;
  l_sleep                  VARCHAR2(3000);

BEGIN

   -- Take a count of the requests for lower hierarchy levels still in progress
   OPEN lower_hrchy_req_cur;
   FETCH lower_hrchy_req_cur INTO l_lower_hrchy_count;
   CLOSE lower_hrchy_req_cur;

   -- If any are found, enter a wait loop until they are complete
   WHILE (l_lower_hrchy_count > 0) LOOP

       l_sleep := dbms_pipe.receive_message
                  (pipename => 'non-existant pipe to force timeout',
                   timeout  => 10);

   -- Recheck until the requests are completed
       OPEN lower_hrchy_req_cur;
       FETCH lower_hrchy_req_cur INTO l_lower_hrchy_count;
       CLOSE lower_hrchy_req_cur;

   END LOOP;

END wait_for_lower_levels;
--
-- ----------------------------------------------------------------------------
-- Procedure   : PROCESS
-- Description : Overloaded procedure which acts as the main controller for the
--               utility. It calls the various procedure for performing different
--               task.
-- ----------------------------------------------------------------------------
--
PROCEDURE process
IS
  --
  l_request_data           VARCHAR2(240);
  l_slave_errored          BOOLEAN;
  --
BEGIN
  --
  -- Wait for any other multi-threading processes previously submitted
  -- in the same request set to complete
  --
  wait_for_other_mthds;
  --
  -- Bug 5023754, removing the alter session statement
  --
  -- execute immediate 'ALTER SESSION ENABLE PARALLEL DML';
  --
  BEGIN
    --
    -- 1. Start Multithreading Process
    -- Start the multithreading process by performing the following tasks
    --    a. Invoke the program pre processor
    --    b. create the object ranges
    --    c. spawn the child threads
    --
    -- If there are no ranges created then the no_ranges_to_process
    -- exception will be raised. In that case no processing is required
    -- but the post_process should still be called
    -- if the pre-processor does not return any SQL, then no processing
    -- is required and also the post processor need not be called.
    --
    do_multithreading;
    dbg('done do_multithreading, calling process_range');
    --
    -- 2. Process Range
    --
    process_range(p_program                 => g_program
                  ,p_mthd_action_id         => g_mthd_action_id
                  ,p_errbuf                 => g_errbuf
                  ,p_retcode                => g_retcode) ;
    dbg('done process_range, calling watch_child_processes');
    --
    -- 3. Wait for Child Threads to complete Processing
    --
    watch_child_processes(l_slave_errored);
    --
  EXCEPTION
    --
    WHEN no_ranges_to_process THEN
      --
      -- There are no ranges to be processed, therefore only call the post_process
      --
      dbg('The program pre_processor returned a SQL, for which no range could be created.');
      null;
    WHEN no_sql_returned THEN
      --
      -- The pre processor may not return a SQL when the processing is done by it. This may be
      -- required in case of processes which have a special processing logic in Foundation HR
      -- mode. The following should happen in such a case
      -- 1. No error should be raised
      -- 2. the post processing routine should not be invoked.
      -- Raise an error which will be handled at the end of this procedure. This will prevent
      -- the call to post_processor and the process will not error out.
      --
      RAISE;
  END;
  --
  dbg('Finished processing ranges, determining how to end the process');
  --
  IF l_slave_errored THEN
    --
    -- One of the child thread encountered an error, an error should be raised
    --
    dbg('An error condition was encountered in one of the child process');
    --
    -- Get the request id of the erroring thread
    --
    g_error_request_id := GET_ERROR_REQUEST(p_mthd_action_id => g_mthd_action_id);
    --
    fnd_message.set_name('HRI','HRI_MLT_OTHER_THREAD_IN_ERR');
    fnd_message.set_token('REQUEST_ID',g_error_request_id);
    RAISE other_thread_in_error;
    --
  ELSE
    --
    -- 4. End Multithreading Process
    --
    dbg('calling end_multithreading');
    end_multithreading;
    --
  END IF;
  --
  dbg('Done processing exiting now');
  --
EXCEPTION
  WHEN no_sql_returned THEN
    --
    dbg('Inside no_sql_returned exceotion..Not doing anything');
    RETURN;
    --
    -- Any other exception should be handled the the calling routine
    --
END PROCESS;
--
-- ----------------------------------------------------------------------------
-- 1. Start Multithreading Process
-- Procedure   : DO_MULTITHREADING
-- Description : This procedure does the tast of starting the  Multithreading
--               Process. It invokes the process to call ther
--               Pre Processor
--               Create the Ranges based on the SQL returned by the the pre_process
--               Start the Child threads for processing the ranges
-- ----------------------------------------------------------------------------
--
PROCEDURE  do_multithreading
IS
  --
  l_process_action_id     NUMBER;
  l_from_date             DATE;
  l_to_date               DATE;
  l_sql                   VARCHAR2(1000);
  l_program               VARCHAR2(100);
  --
BEGIN
  --
  dbg('Inside do_multithreading');
  --
  -- 1.1 Generate Multi Thread Action
  --
  gen_multi_thread_action;
  --
  -- 1.2 Generate Object Ranges
  --
  gen_object_range(g_mthd_action_array.mthd_action_id);
  --
  -- 1.3 Start Threads
  --
  start_threads;
  --
  COMMIT;
  --
  dbg('Exiting do_multithreading');
  --
END do_multithreading;
--
-- ----------------------------------------------------------------------------
-- 1.1 Generate Multi Thread Action
-- Procedure   : GEN_MULTI_THREAD_ACTION
-- Description : This procedure inserts the parameters passed to the utility
--               by the concurrent request, into the action table.
-- ----------------------------------------------------------------------------
--
PROCEDURE gen_multi_thread_action IS
  --
  -- curosor to get the short name of the concurrent program
  -- which is being run
  --
  CURSOR c_process_name IS
    SELECT concurrent_program_name
    FROM   fnd_concurrent_programs prg,
           fnd_concurrent_requests req
    WHERE  prg.concurrent_program_id = req.concurrent_program_id
    AND    req.request_id = fnd_global.conc_request_id;
  --
  l_process_name    VARCHAR2(30);
  --
BEGIN
  --
  -- mthd_action_id for the current process is not defined. A new row will have to be created
  -- in hri_adm_mthd_action for this process
  --
  IF hr_general.chk_product_installed(800) = 'FALSE' THEN
    --
    g_mthd_action_array.foundation_hr_flag  :=  'Y';
    --
  ELSIF NVL(fnd_profile.value('HRI_DBI_FORCE_SHARED_HR'),'N') = 'Y' THEN
    --
    g_mthd_action_array.foundation_hr_flag  :=  'Y';
    --
  ELSE
    --
    g_mthd_action_array.foundation_hr_flag  :=  'N';
    --
  END IF;
  --
  -- Get the short name of the concurrent program that is running
  --
  OPEN  c_process_name;
  FETCH c_process_name INTO l_process_name;
  CLOSE c_process_name;
  --
  -- Initialize the record
  --
  g_mthd_action_array.request_id             :=  fnd_global.conc_request_id;
  g_mthd_action_array.debug_flag             :=  g_debug_flag;
  g_mthd_action_array.process_name           :=  l_process_name;
  --
  INSERT into HRI_ADM_MTHD_ACTIONS
    ( MTHD_ACTION_ID,
      PROGRAM,
      REQUEST_ID,
      COLLECT_FROM_DATE,
      COLLECT_TO_DATE,
      BUSINESS_GROUP_ID,
      FULL_REFRESH_FLAG,
      DEBUG_FLAG,
      FOUNDATION_HR_FLAG,
      HIERARCHICAL_PROCESS_FLAG,
      HIERARCHICAL_PROCESS_TYPE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      STATUS ,
      START_TIME ,
      END_TIME ,
      PROCESS_TYPE ,
      PROCESS_NAME)
VALUES
     (hri_adm_mthd_actions_s.nextval,
      g_mthd_action_array.PROGRAM,
      g_mthd_action_array.REQUEST_ID,
      g_mthd_action_array.COLLECT_FROM_DATE,
      g_mthd_action_array.COLLECT_TO_DATE,
      g_mthd_action_array.BUSINESS_GROUP_ID,
      g_mthd_action_array.FULL_REFRESH_FLAG,
      g_mthd_action_array.DEBUG_FLAG,
      g_mthd_action_array.FOUNDATION_HR_FLAG,
      g_mthd_action_array.HIERARCHICAL_PROCESS_FLAG,
      g_mthd_action_array.HIERARCHICAL_PROCESS_TYPE,
      g_mthd_action_array.ATTRIBUTE1,
      g_mthd_action_array.ATTRIBUTE2,
      g_mthd_action_array.ATTRIBUTE3,
      g_mthd_action_array.ATTRIBUTE4,
      g_mthd_action_array.ATTRIBUTE5,
      g_mthd_action_array.ATTRIBUTE6,
      g_mthd_action_array.ATTRIBUTE7,
      g_mthd_action_array.ATTRIBUTE8,
      g_mthd_action_array.ATTRIBUTE9,
      g_mthd_action_array.ATTRIBUTE10,
      g_mthd_action_array.ATTRIBUTE11,
      g_mthd_action_array.ATTRIBUTE12,
      g_mthd_action_array.ATTRIBUTE13,
      g_mthd_action_array.ATTRIBUTE14,
      g_mthd_action_array.ATTRIBUTE15,
      g_mthd_action_array.ATTRIBUTE16,
      g_mthd_action_array.ATTRIBUTE17,
      g_mthd_action_array.ATTRIBUTE18,
      g_mthd_action_array.ATTRIBUTE19,
      g_mthd_action_array.ATTRIBUTE20,
      g_mthd_action_array.STATUS ,
      g_mthd_action_array.START_TIME ,
      g_mthd_action_array.END_TIME ,
      g_mthd_action_array.PROCESS_TYPE ,
      g_mthd_action_array.PROCESS_NAME)
 RETURNING mthd_action_id INTO g_mthd_action_id;
 --
 g_mthd_action_array.mthd_action_id         :=  g_mthd_action_id;
 --
EXCEPTION
  WHEN others THEN
  RAISE;
END gen_multi_thread_action;
--
-- ----------------------------------------------------------------------------
-- 1.2 Generate Object Ranges
-- Procedure   : GEN_OBJECT_RANGE
-- Description : This procedure invokes the program pre_processor and generates
--               the object range based on the SQL returned by the pre-processor
-- ----------------------------------------------------------------------------
--
PROCEDURE gen_object_range (p_mthd_action_id  NUMBER)
IS
  --
  l_dyn_pre_process_sql varchar2(4000);
  l_dyn_range_sql varchar2(4000);
  l_sqlstr       varchar2(2000);
  l_mthd_action_id NUMBER;
  --
BEGIN
  dbg('inside gen_object_range');
  --
  --
  --
  l_mthd_action_id := nvl(p_mthd_action_id,
                          g_mthd_action_array.mthd_action_id);
  --
  -- Read the profile value HRI:Multithreading Chunk Size
  --
  g_chunk := NVL(fnd_profile.value('HRI_MTHD_CHUNK_SIZE'),20);
  dbg('chunk size = '||g_chunk);
  --
  -- Create the dynamic SQL for calling the pre_processor of the program.
  -- Based on the sql returned by the pre_process the ranges will be created.
  -- However, if no SQL is returned, the processing should be stopped without
  -- returning any error. This is for supporting cases when the program does
  -- not need to do any processing e.g. Assignment events in shared HR mode
  --
  l_dyn_pre_process_sql := 'BEGIN '||
                              g_program||'.PRE_PROCESS(:l_mthd_action_id, :l_sqlstr);
                            END;';
  --
  dbg('l_dyn_pre_process_sql='||l_dyn_pre_process_sql);
  --
  EXECUTE IMMEDIATE l_dyn_pre_process_sql
  USING   p_mthd_action_id,
          OUT l_sqlstr;
  --
  -- The pre_processor can update some of the action column so repopulate the
  -- action array
  --
  g_mthd_action_array := get_mthd_action_array(p_mthd_action_id => l_mthd_action_id);
  --
  IF l_sqlstr is null THEN
    --
    -- The program did not return any SQL. The processing has already be done therefore
    --   skip creating the ranges
    --   skip creating the Child threads for processing the ranges
    --   skip calling the process_range
    --   skip calling the post_process
    -- Raise an exception which will be handled in the calling procedure to gracefully
    -- skip all the above listed steps
    --
    raise_application_error(-20996,'Multi threading Pre Processor did not return any SQL');
    --
  END IF;
  --
  -- Create the dynamic sql for creating the multithread ranges.
  -- This SQL will create the ranges based on the SQL returned by the pre-processor
  --
  IF (g_mthd_action_array.hierarchical_process_flag = 'Y' AND
      g_mthd_action_array.hierarchical_process_type = 'TOP_DOWN') THEN

    l_dyn_range_sql :=
'INSERT /*+ append parallel(range, default,default) */ INTO
  hri_adm_mthd_ranges range
   (mthd_range_id
   ,mthd_range_lvl
   ,mthd_range_lvl_order
   ,mthd_action_id
   ,start_object_id
   ,end_object_id
   ,status)
   SELECT
    mthd_range_id
   ,object_lvl
   ,object_lvl
   ,:mthd_action_id
   ,min(object_id)
   ,max(object_id)
   ,''UNPROCESSED''
   FROM
    (SELECT
      object_lvl + CEIL(ROWNUM / :chunk_size)  mthd_range_id
     ,object_lvl
     ,object_id
     FROM
      (SELECT object_id, object_lvl
       FROM (' || l_sqlstr || ')
       ORDER BY object_lvl, object_id))
   GROUP BY
    mthd_range_id
   ,object_lvl';

  ELSIF (g_mthd_action_array.hierarchical_process_flag = 'Y' AND
         g_mthd_action_array.hierarchical_process_type = 'BOTTOM_UP') THEN

    l_dyn_range_sql :=
'INSERT /*+ append parallel(range, default,default) */ INTO
  hri_adm_mthd_ranges range
   (mthd_range_id
   ,mthd_range_lvl
   ,mthd_range_lvl_order
   ,mthd_action_id
   ,start_object_id
   ,end_object_id
   ,status)
   SELECT
    mthd_range_id
   ,object_lvl
   ,0 - object_lvl
   ,:mthd_action_id
   ,min(object_id)
   ,max(object_id)
   ,''UNPROCESSED''
   FROM
    (SELECT
      1000 - object_lvl + CEIL(ROWNUM / :chunk_size)  mthd_range_id
     ,object_lvl
     ,object_id
     FROM
      (' || l_sqlstr || ')
    )
   GROUP BY
    mthd_range_id
   ,object_lvl';

  ELSE

    l_dyn_range_sql :=
'INSERT /*+ append parallel(range, default,default) */ INTO
  hri_adm_mthd_ranges range
   (mthd_range_id
   ,mthd_range_lvl
   ,mthd_range_lvl_order
   ,mthd_action_id
   ,start_object_id
   ,end_object_id
   ,status)
   SELECT
    mthd_range_id
   ,1
   ,1
   ,:mthd_action_id
   ,min(object_id)
   ,max(object_id)
   ,''UNPROCESSED''
   FROM
    (SELECT
      CEIL(ROWNUM / :chunk_size)  mthd_range_id
     ,object_id
     FROM
      (' || l_sqlstr || ')
    )
   GROUP BY
    mthd_range_id';

  END IF;

  dbg('l_dyn_range_sql='||l_dyn_range_sql);
  --
  -- Bug 5023754
  --
  COMMIT;
  --
  -- Enable parallel session
  --
  EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
  --
  -- Run the dynamic SQL for creating the range
  --
  EXECUTE IMMEDIATE l_dyn_range_sql USING l_mthd_action_id, g_chunk;
  --
  COMMIT;
  --
  -- Disable parallel session
  --
  EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
  --
  dbg('exiting gen_object_range');
EXCEPTION
  --
  WHEN invalid_program THEN
    --
    dbg('Invalid program name passsed to the pre process='||g_program);
    fnd_message.set_name('HRI','HRI_MLT_INVALID_PGM_NAME');
    RAISE invalid_program;
    --
  WHEN OTHERS THEN
    IF SQLCODE = - 20997 THEN
      --
      dbg('Invalid SQL returned by the pre process='||SQLCODE);
      dbg(l_dyn_range_sql);
      fnd_message.set_name('HRI', 'HRI_MLT_INVALID_SQL');
      RAISE invalid_sql;
      --
    ELSIF SQLCODE = - 20996 THEN
      --
      dbg(fnd_message.get);
      dbg('No SQL returned by the pre process=');
      RAISE no_sql_returned;
      --
    ELSE
      --
      RAISE;
      --
    END IF;
    --
END gen_object_range;
--
-- ----------------------------------------------------------------------------
-- 1.3 Start Threads
-- Procedure   : START_THREAD
-- Description : This procedure spawns the child threads for processing the ranges
--               The number of threads to be spawned is controlled by the profile
--               HRI: Number of Threads to Launch. However, if the number of ranges
--               is less then the profile then only (no of ranges -1) threads will
--               be launched. -1 as the master thread also helps in processing
-- ----------------------------------------------------------------------------
--
PROCEDURE start_threads
IS
  --
  l_request_id  NUMBER;
  l_slave_count NUMBER;
  --
  CURSOR c_get_range_count IS
  SELECT count(*)
  FROM   hri_adm_mthd_ranges
  WHERE  mthd_action_id = g_mthd_action_id;
  --
BEGIN
  dbg('Inside start_threads');
  --
  -- Read the profile value HRI:Number of Threads to Launch
  --
  g_slave_count := NVL(fnd_profile.value('HRI_NO_THRDS_LAUNCH'),8);
  dbg('threads to launch = '||g_slave_count);
  --
  -- The number of threads to be launched is controlled by the profile option
  -- HRI: Number of Threads to Launch. However in case the total
  -- number of range records created is less than the value for this profile
  -- then only limited number of threads should be started. This will avoid
  -- situations where a thread doesn't get any ranges to process
  --
  OPEN  c_get_range_count;
  FETCH c_get_range_count into l_slave_count;
  CLOSE c_get_range_count;
  --
  IF l_slave_count is null THEN
    --
    -- No range records have been created, so raise an error
    --
    RAISE no_ranges_to_process;
    --
  ELSIF l_slave_count = 1 THEN
    --
    -- There is only one range to be processed, which will be processed by
    -- the master thread so do not launch any child threads.
    --
    RETURN;
    --
  ELSIF l_slave_count > g_slave_count THEN
    --
    -- There are a number of ranges to be processed, so start the threads
    --
    l_slave_count := g_slave_count;
    --
  ELSE
    --
    l_slave_count := l_slave_count - 1;
    --
  END IF;
  --
  -- Start the child processes
  --
  FOR l_count in 1..l_slave_count loop
    --
    l_request_id :=
      fnd_request.submit_request
        (
         application             => 'HRI'
        ,program                 => 'HRI_MTHD_CHILD_PROCESS'
        ,sub_request             => FALSE      -- Indicates that the request will not be
                                               -- executed as a sub process.
        ,argument1               => fnd_global.conc_request_id
        ,argument2               => g_program
        ,argument3               => g_mthd_action_id
        ,argument4               => l_count + 1  -- worker_id
      );
    --
    IF l_request_id = 0 then
      --
      -- If request submission failed, raise exception
      --
      dbg('Error launching thread.');
      RAISE error_launching_thread;
      --
    ELSE
      --
      -- Store the request_id of the submitted request in an array. This
      -- array is used in checking if all the child threads have finished
      -- processing the range.
      --
      g_child_request_tab(l_count) := l_request_id;
      --
    END IF;
    --
  END LOOP;
  --
  dbg('Exiting start_threads');
  --
EXCEPTION
  --
  WHEN others THEN
    --
    fnd_message.set_name('HRI', 'HRI_MLT_START_THREAD');
    dbg('Exception encountered in starting thread');
    dbg(sqlerrm);
    RAISE;
    --
END start_threads;
--
-- ----------------------------------------------------------------------------
-- 2. Process Range
-- Procedure   : PROCESS_RANGE
-- Description : This procedure dynamically invokes the entry point in the
--               collection programs package to process the ranges.
-- ----------------------------------------------------------------------------
--
PROCEDURE process_range(p_program                IN            VARCHAR2,
                        p_mthd_action_id         IN            NUMBER,
                        p_errbuf                    OUT NOCOPY VARCHAR2,
                        p_retcode                   OUT NOCOPY NUMBER )
IS
  --
  l_step        NUMBER;
  l_dyn_sql     VARCHAR2(4000);
  l_lvl_param   VARCHAR2(100);
  --
BEGIN
  --
  dbg('inside process_range');
  --
  l_step := 10;
  --
  IF (g_mthd_action_array.hierarchical_process_flag = 'Y') THEN
    l_lvl_param := '
                ,p_mthd_range_lvl           => l_mthd_range_lvl';
  END IF;
  --
  -- Construct the dynamic query to invoke the process_range procedure
  -- The dynamic SQL gets the next unprocessed range and invokes the
  -- process_range procedure to process the range. The allocation of
  -- next range is included in the dyn sql so that the session remains
  -- the same and the child thread does not have to re-initialize
  -- globals variables again.
  --
  dbg('processing p_mthd_action_id ='||p_mthd_action_id);
  l_dyn_sql :=
    'DECLARE
       l_errbuf                VARCHAR2(1000);
       l_retcode               NUMBER;
       l_mthd_range_id         NUMBER;
       l_mthd_range_lvl        NUMBER;
       l_mthd_range_lvl_nxt    NUMBER;
       l_mthd_range_lvl_order  NUMBER;
       l_start_object_id       NUMBER;
       l_end_object_id         NUMBER;
       l_mthd_action_id        NUMBER := '||p_mthd_action_id||';
     BEGIN
       LOOP
         hri_opl_multi_thread.get_next_range
                (p_mthd_action_id         => l_mthd_action_id
                ,p_mthd_range_id          => l_mthd_range_id
                ,p_mthd_range_lvl         => l_mthd_range_lvl_nxt
                ,p_mthd_range_lvl_order   => l_mthd_range_lvl_order
                ,p_start_object_id        => l_start_object_id
                ,p_end_object_id          => l_end_object_id);
         hri_opl_multi_thread.dbg(''l_mthd_range_id  =''||l_mthd_range_id );
         IF l_mthd_range_id is null THEN
           EXIT;
         ELSE
           IF (l_mthd_range_lvl <> l_mthd_range_lvl_nxt) THEN
             hri_opl_multi_thread.wait_for_lower_levels
              (p_mthd_action_id         => l_mthd_action_id
              ,p_mthd_range_lvl_order   => l_mthd_range_lvl_order);
           END IF;
           l_mthd_range_lvl := l_mthd_range_lvl_nxt;
           '||p_program||'.process_range(
                 errbuf                     => :l_errbuf
                ,retcode                    => :l_retcode
                ,p_mthd_action_id           => l_mthd_action_id
                ,p_mthd_range_id            => l_mthd_range_id' || l_lvl_param || '
                ,p_start_object_id          => l_start_object_id
                ,p_end_object_id            => l_end_object_id);
         END IF;
       END LOOP;
     EXCEPTION
       WHEN OTHERS THEN
         RAISE;
     END;';
  --
  l_step := 20;
  dbg('process_range sql ='||l_dyn_sql);
  --
  -- execute the dynamic sql to process the ranges.
  --
  BEGIN
    --
    EXECUTE IMMEDIATE l_dyn_sql
    USING   OUT p_errbuf,
            OUT p_retcode;
    --
    -- p_retcode = 0 means the process completed successfully
    -- p_retcode = 1 means that the process encountered a warning
    -- p_retcode > 2 means that the process encountered an ERROR.
    -- So if the retcode returned is is greater than 1 then raise an exception
    --
    dbg('finished processing the ranges');
    IF p_retcode >= 2 THEN
      --
      -- Store the error code in the global error buffer and raise the error
      --
      g_errbuf   := p_errbuf;
      g_retcode  := p_retcode;
      dbg('The process_range routine returned a error code of '||p_retcode);
      raise_application_error(-20998,'CHILD_PROCESS_FAILURE');
      --
    END IF;
    --
  EXCEPTION
    WHEN others THEN
      l_step := 30;
      --
      -- When an exception is raised, then the status of the ranges and the action
      -- records should changed to Error. However, this should not be done when
      -- the application error - 20999 is raised; done when a parallel thread
      -- encounters an error because of which the processing of this thread should stop.
      -- In such a case the set_range_error procedure should not be called.
      -- Why try to mark the ranges as error when it has already be done by
      -- the thread which encountered the error.
      --
      dbg('Error raised by the process, marking the ranges as error');
      IF SQLCODE <> - 20999 THEN
        --
        hri_opl_multi_thread.set_range_error(p_mthd_action_id);
        fnd_message.set_name('HRI','HRI_MLT_CHILD_THREAD_IN_ERR');
        --
        RAISE;
        -- raise_application_error(- 20998,'CHILD_PROCESS_FAILURE');
        --
      END IF;
      RAISE;
      --
  END;
  --
  dbg('exiting process_range');
  --
EXCEPTION
  --
  WHEN invalid_program THEN
    --
    -- Raised when the package or package.procedure does not exist
    --
    dbg('Invalid program name passsed to process_range='||g_program);
    fnd_message.set_name('HRI','HRI_MLT_INVALID_PGM_NAME');
    --
    RAISE invalid_program;
    --
  WHEN others THEN
    --
    dbg('error in process_range ='||sqlerrm);
    dbg('SQLCODE = '||SQLCODE);
    --
    IF SQLCODE = - 20999 THEN
      --
      -- An error was encountered by a parallel thread, so all the child threads
      -- should stop processing and be marked as errored
      --
      dbg('An error condition was encountered in one of the child process');
      --
      -- Get the request id of the erroring thread
      --
      g_error_request_id := GET_ERROR_REQUEST(p_mthd_action_id => p_mthd_action_id);
      --
      fnd_message.set_name('HRI','HRI_MLT_OTHER_THREAD_IN_ERR');
      fnd_message.set_token('REQUEST_ID',g_error_request_id);
      RAISE other_thread_in_error;
      --
    END IF;
    --
    -- If any other exception is encountered, stop processing.
    --
    RAISE;
    --
END process_range;
--
-- ----------------------------------------------------------------------------
-- 3. Wait for Child Threads to complete Processing
-- Procedure   : WATCH_CHILD_PROCESSES
-- Description : Wait for Child Threads to complete Processing (watch_child_processes)
--               The master thread should not finish processing until all the
--               child threads have finished processing. This procedure keeps a
--               watch on all the child threads that have launched for processing.
--               In case an error in encountered by any of the threads, the
--               p_slave_errored will be returned as TRUE. The procedure also
--               detects warnings raised by any child process, so that the master
--               process also reports a warning
-- ----------------------------------------------------------------------------
--
PROCEDURE watch_child_processes(p_slave_errored out nocopy boolean)
IS
  --
  l_no_slaves      boolean;
  l_poll_loops     pls_integer;
  l_sleep          NUMBER;
  --
  CURSOR c_slaves (c_request_id number) IS
  SELECT phase_code,
         status_code
  FROM   fnd_concurrent_requests fnd
  WHERE  fnd.request_id = c_request_id;
  --
  l_slaves c_slaves%rowtype;
  --
BEGIN
  --
  dbg('Inside watch_child_processes');
  dbg(g_child_request_tab.count||' threads to watch for');
  --
  -- watch the child threads only if the process has spawned threads
  -- otherwise return
  --
  IF g_child_request_tab.count > 0 then
    --
    l_no_slaves := TRUE;
    --
    WHILE l_no_slaves LOOP
      --
      l_no_slaves := false;
      --
      FOR elenum in 1..g_child_request_tab.count LOOP
        --
        -- Open the cursor to determine if the request has completed processing
        --
        OPEN  c_slaves (g_child_request_tab(elenum));
        FETCH c_slaves into l_slaves;
        CLOSE c_slaves;
        --
        IF l_slaves.phase_code <> 'C' THEN
          --
          l_no_slaves := TRUE;
          --
        END IF;
        --
        IF l_slaves.status_code = 'E' THEN
          --
          p_slave_errored    :=  TRUE;
          g_error_request_id :=  g_child_request_tab(elenum);
          --
        ELSIF l_slaves.status_code = 'G' THEN
          --
          dbg('Warning raised by request '||g_child_request_tab(elenum));
          --
          g_errbuf   := 'WARNING';
          g_retcode  := 1;
          --
        END IF;
        --
      END LOOP;
      --
      -- Pause to avoid over polling of fnd_concurrent_requests
      --
      l_sleep := dbms_pipe.receive_message
                  (pipename => 'non-existant pipe to force timeout',
                   timeout  => 10);
      --
    END LOOP;
    --
  END IF;
  --
  dbg('Exiting watch_child_processes');
  --
EXCEPTION
  WHEN OTHERS THEN
    dbg('error in watch_child_processes'||SQLERRM);
    RAISE;
END watch_child_processes;
--
-- ----------------------------------------------------------------------------
-- 4. End Multithreading Process
-- Procedure   : WATCH_CHILD_PROCESSES
-- Description : End Multithreading Process (end_multithreading) This procedure
--               calls the post-processor to wind up the collection processing
--               and updates status of the action record to PROCESSED
-- ----------------------------------------------------------------------------
--
PROCEDURE end_multithreading
IS
  --
  --
BEGIN
  --
  dbg('Inside end_multithreading');
  --
  -- 4.1 Run the post process
  --
  run_program_post_process;
  --
  -- 4.2 Update Multithread Action Status
  --
  set_action_status;
  --
  dbg('Exiting end_multithreading');
  --
EXCEPTION
  --
  WHEN invalid_program THEN
    --
    dbg('Invalid program name passsed to the post process='||g_program);
    fnd_message.set_name('HRI','HRI_MLT_INVALID_PGM_NAME');
    raise invalid_program;
    --
  WHEN others THEN
    --
    dbg('Exception encountered in running the post processing');
    dbg(sqlerrm);
    RAISE;
    --
END end_multithreading;
--
-- ----------------------------------------------------------------------------
-- 4.1 Run Program Post-Processor
-- Procedure   : RUN_PROGRAM_POST_PROCESS
-- Description : This procdure invokes the post_process of the collection
--               program
-- ----------------------------------------------------------------------------
--
PROCEDURE run_program_post_process
IS
  --
  l_sql               VARCHAR2(1000);
  --
BEGIN
  --
  dbg('inside run_program_post_process');
  --
  -- Build the dynamic SQL
  --
  l_sql := 'BEGIN '||g_program ||'.POST_PROCESS('||g_mthd_action_id||'); END;';
  --
  dbg('post processing sql is ='||l_sql );
  --
  EXECUTE IMMEDIATE l_sql;
  --
  dbg('exiting run_program_post_process');
  --
END run_program_post_process;
--
-- ----------------------------------------------------------------------------
-- 4.2 Update Multithread Action Status
-- Procedure   : SET_ACTION_STATUS
-- Description : This procdure marks the status of the action record to
--               processed
-- ----------------------------------------------------------------------------
--
PROCEDURE set_action_status
IS
BEGIN
  --
  dbg('inside set_action_status');
  --
  -- Update the status of the mulithread action as processed
  --
  UPDATE hri_adm_mthd_actions
  SET    end_time        = SYSDATE,
         status          = 'PROCESSED'
  WHERE  mthd_action_id  = g_mthd_action_id;
  --
  dbg('exiting set_action_status');
  --
END set_action_status;
--
-- ----------------------------------------------------------------------------
-- 7.1.1         PROCESS
-- Procedure   : PROCESS
-- Description : Main Entry Point for the Multithreading Utility. The concurrent
--               program will invoke this program for processing. The procedure
--               puts all the parameters passed to it into an array and calls the
--               overloaded PROCESS procedure
-- ----------------------------------------------------------------------------
--
PROCEDURE process  (errbuf                             OUT NOCOPY  VARCHAR2,
                    retcode                            OUT NOCOPY  NUMBER,
                    p_program                       IN             VARCHAR2,
                    p_business_group_id             IN             NUMBER,
                    p_collect_from_date             IN             VARCHAR2,
                    p_collect_to_date               IN             VARCHAR2,
                    p_full_refresh_flag             IN             VARCHAR2,
                    p_hierarchical_process          IN             VARCHAR2 DEFAULT 'N',
                    p_hierarchical_type             IN             VARCHAR2 DEFAULT NULL,
                    p_attribute1                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute2                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute3                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute4                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute5                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute6                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute7                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute8                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute9                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute10                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute11                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute12                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute13                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute14                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute15                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute16                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute17                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute18                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute19                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute20                   IN             VARCHAR2 DEFAULT NULL)
IS
  --
  l_slave_errored          BOOLEAN;
  l_hr_installed           VARCHAR2(30); -- Stores HR installed or not
  l_frc_shrd_hr_prfl_val   VARCHAR2(30); -- store Profile HRI:DBI Force Foundation HR Processes
  l_message                fnd_new_messages.message_text%type;
  --
BEGIN
  dbg('Starting HRI Multithreading Utility');
  --
  -- Debugging on the process is enabled by profile HRI:Enable Detailed Logging
  --
  g_program := p_program;
  --
  g_mthd_action_array.program                   :=  p_program;
  g_mthd_action_array.collect_from_date         :=  fnd_date.canonical_to_date(p_collect_from_date);
  g_mthd_action_array.collect_to_date           :=  fnd_date.canonical_to_date(p_collect_to_date);
  g_mthd_action_array.business_group_id         :=  p_business_group_id;
  g_mthd_action_array.full_refresh_flag         :=  p_full_refresh_flag;
  g_mthd_action_array.hierarchical_process_flag :=  p_hierarchical_process;
  g_mthd_action_array.hierarchical_process_type :=  p_hierarchical_type;
  g_mthd_action_array.attribute1                :=  p_attribute1;
  g_mthd_action_array.attribute2                :=  p_attribute2;
  g_mthd_action_array.attribute3                :=  p_attribute3;
  g_mthd_action_array.attribute4                :=  p_attribute4;
  g_mthd_action_array.attribute5                :=  p_attribute5;
  g_mthd_action_array.attribute6                :=  p_attribute6;
  g_mthd_action_array.attribute7                :=  p_attribute7;
  g_mthd_action_array.attribute8                :=  p_attribute8;
  g_mthd_action_array.attribute9                :=  p_attribute9;
  g_mthd_action_array.attribute10               :=  p_attribute10;
  g_mthd_action_array.attribute11               :=  p_attribute11;
  g_mthd_action_array.attribute12               :=  p_attribute12;
  g_mthd_action_array.attribute13               :=  p_attribute13;
  g_mthd_action_array.attribute14               :=  p_attribute14;
  g_mthd_action_array.attribute15               :=  p_attribute15;
  g_mthd_action_array.attribute16               :=  p_attribute16;
  g_mthd_action_array.attribute17               :=  p_attribute17;
  g_mthd_action_array.attribute18               :=  p_attribute18;
  g_mthd_action_array.attribute19               :=  p_attribute19;
  g_mthd_action_array.attribute20               :=  p_attribute20;
  g_mthd_action_array.status                    :=  'PROCESSING';
  g_mthd_action_array.start_time                :=  SYSDATE;
  --
  -- Call the overridden procedure to start the processing
  --
  process;
  --
  -- In case a child thread end with a warning or error, the
  -- master thread should end with a similiar note
  --
  IF (g_errbuf IS NOT NULL) THEN
    errbuf  := g_errbuf;
    retcode := NVL(g_retcode,0);
  END IF;
  --
  dbg('Exiting HRI Multithreading Utility');
  --
EXCEPTION
  WHEN invalid_program OR
       other_thread_in_error OR
       error_launching_thread OR
       invalid_sql
  THEN
    --
    -- These are standard errors so don't raise an exception
    --
    errbuf  := NVL(g_errbuf,'HRI_MTHD_THREAD_IN_ERR');
    retcode := 2;
    --
    -- The master process should not complete before the child process
    -- have finished
    --
    watch_child_processes(l_slave_errored);
    --
    l_message := nvl(fnd_message.get,sqlerrm);
    --
    output(l_message);
    --
    -- Bug 4105868: Collection Diagnostics
    --
    hri_bpl_conc_log.log_process_info
            (p_msg_type      => 'ERROR'
            ,p_package_name  => p_program
            ,p_msg_group     => 'MLTTHRDNG'
            ,p_msg_sub_group => 'PROCESS'
            ,p_sql_err_code  => SQLCODE
            ,p_note          => l_message
            );
    --
    hri_bpl_conc_log.log_process_end
            (p_status         => FALSE
            ,p_period_from    => hr_general.start_of_time
            ,p_period_to      => hr_general.end_of_time
            ,p_package_name   => p_program
            );
    --
  WHEN others THEN
    --
    -- Unknown exception encountered, so raise an error
    --
    errbuf  := NVL(g_errbuf,SQLERRM);
    retcode := 2;
    --
    -- The master process should not complete before the child process
    -- have finished
    --
    watch_child_processes(l_slave_errored);
    --
    l_message := nvl(fnd_message.get,sqlerrm);
    --
    output(l_message);
    --
    -- Bug 4105868: Collection Diagnostics
    --
    hri_bpl_conc_log.log_process_info
            (p_msg_type      => 'ERROR'
            ,p_package_name  => p_program
            ,p_msg_group     => 'MLTTHRDNG'
            ,p_msg_sub_group => 'PROCESS'
            ,p_sql_err_code  => SQLCODE
            ,p_note          => l_message
            );
    --
    hri_bpl_conc_log.log_process_end
            (p_status         => FALSE
            ,p_period_from    => hr_general.start_of_time
            ,p_period_to      => hr_general.end_of_time
            ,p_package_name   => p_program
            );
    --
END process;
--
-- ----------------------------------------------------------------------------
-- 7.1.2 Get Next Range
-- Procedure   : GET_NEXT_RANGE
-- Description : This process acts as an interface between the child process
--               and the range table. The process performs the following task
--               1) Provide the process with the next Unprocessed object range.
--               2) Maintain the status of object ranges that are currently being
--                  processed by the processes.
--               3) Update the status of the object range that has been processed
--                  by the child process.
--               4) In case a child process encounters an error, it returns the
--                  error code of 1 to the requesting process. The child process
--                  should then stop processing and error out.
-- ----------------------------------------------------------------------------
--
PROCEDURE get_next_range(p_mthd_action_id          IN            NUMBER
                        ,p_mthd_range_id           IN OUT NOCOPY NUMBER
                        ,p_mthd_range_lvl             OUT NOCOPY NUMBER
                        ,p_mthd_range_lvl_order       OUT NOCOPY NUMBER
                        ,p_start_object_id            OUT NOCOPY NUMBER
                        ,p_end_object_id              OUT NOCOPY NUMBER
                        ,p_mode                    IN            VARCHAR2 default 'N')
IS
  --
  l_error_status                       NUMBER;
  --
  CURSOR  c_error IS
  SELECT  -1
  FROM    hri_adm_mthd_ranges
  WHERE   status         = 'ERROR'
  AND     mthd_action_id = p_mthd_action_id
  AND     rownum = 1;
  --
BEGIN
  --
  -- If the p_mthd_range_id will store the previous range id, which has been processed
  -- by the child thread, so mark that range as PROCESSED
  --
  IF p_mthd_range_id is not null THEN
    --
    UPDATE hri_adm_mthd_ranges
    SET    status            = 'PROCESSED'
    WHERE  status            = 'PROCESSING'
    AND    mthd_action_id    = p_mthd_action_id
    AND    mthd_range_id     = p_mthd_range_id;
    --
    p_mthd_range_id := null;
    --
  END IF;
  --
  -- Get the next available range for processing
  --
  UPDATE hri_adm_mthd_ranges
  SET status = 'PROCESSING',
      request_id = fnd_global.conc_request_id
  WHERE status = 'UNPROCESSED'
  AND mthd_action_id = p_mthd_action_id
  AND mthd_range_id =
    (SELECT MIN(sub.mthd_range_id)
     FROM hri_adm_mthd_ranges sub
     WHERE sub.status = 'UNPROCESSED'
     AND sub.mthd_action_id = p_mthd_action_id)
  RETURNING
   mthd_range_id
  ,mthd_range_lvl
  ,mthd_range_lvl_order
  ,start_object_id
  ,end_object_id
  INTO
   p_mthd_range_id
  ,p_mthd_range_lvl
  ,p_mthd_range_lvl_order
  ,p_start_object_id
  ,p_end_object_id;
  --
  -- Commit the transactions here, this will ensure when a error is
  -- encountered by some other thread, the processesing done by
  -- the current thread are commited before an error is raised.
  --
  COMMIT;
  --
  --
  -- If no range is available for processing, then it could be that
  -- a child thread encountered an error. In which, case an
  -- exception should be raised and the processing should stop there.
  --
  IF p_mthd_range_id is null THEN
    --
    OPEN  c_error;
    FETCH c_error INTO l_error_status;
    CLOSE c_error;
    --
    IF l_error_status = -1 THEN
      --
       p_mthd_range_id := -1;
       p_start_object_id := -1;
       p_end_object_id   := -1;
       --
       -- raise an exception
       --
       dbg('error encountered in get_next_range, other_process_failure');
       raise_application_error(- 20999,'other_process_failure');
      --
    END IF;
    --
  END IF;
  --
END get_next_range;
--
-- ----------------------------------------------------------------------------
-- 7.1.3 Set Range in Error
-- Procedure   : SET_ERROR_STATUS
-- Description : This procedure will be invoked by the child thread that
--               encountered an error. It updates the marks the action and
--               unprocessed ranges as Error
-- ----------------------------------------------------------------------------
--
PROCEDURE set_range_error(p_mthd_action_id NUMBER)
IS
  --
  --
BEGIN
  dbg('Inside set_range_error');
  --
  -- Mark the object range as Error
  --
  UPDATE hri_adm_mthd_ranges
  SET    status    =  'ERROR',
         err_thread_request_id = fnd_global.conc_request_id
  WHERE  mthd_action_id = p_mthd_action_id
  --
  -- The records which have not been processed
  --
  AND    (status = 'UNPROCESSED' OR
  --
  -- The records which which was being processed by the thread, when the error
  -- was raised
  --
          (status = 'PROCESSING'
           AND request_id = fnd_global.conc_request_id));
  --
  dbg(sql%rowcount||' range records marked as Error');
  --
  -- Change the status action record to ERROR
  --
  UPDATE hri_adm_mthd_actions
  SET    status    =  'ERROR'
  WHERE  mthd_action_id = p_mthd_action_id;
  --
  commit;
  --
  dbg('exiting set_range_error');
  --
END set_range_error;
--
-- ----------------------------------------------------------------------------
-- 7.1.5 Process Range (Entry Point for Child thread processes)
-- Procedure   : PROCESS_RANGE
-- Description : This procedure is called by the concurrent manager. It control
--               the child thread processing. It invokes the overloaded
--               process_range procedure
-- ----------------------------------------------------------------------------
--
PROCEDURE process_range(
                        errbuf                        OUT NOCOPY VARCHAR2
                        ,retcode                      OUT NOCOPY NUMBER
                        ,p_master_request_id      IN             NUMBER
                        ,p_program                IN             VARCHAR2
                        ,p_mthd_action_id         IN             NUMBER
                        ,p_worker_id              IN             NUMBER)
IS
  --
  l_dyn_sql varchar2(4000);
  --
BEGIN
  --
  g_mthd_action_array := get_mthd_action_array(p_mthd_action_id);
  --
  process_range(p_program         => p_program
                ,p_mthd_action_id => p_mthd_action_id
                ,p_errbuf         => errbuf
                ,p_retcode        => retcode);
  --
EXCEPTION
  WHEN invalid_program OR other_thread_in_error THEN
    --
    -- These are standard errors so don't raise an exception
    --
    errbuf  := NVL(g_errbuf,SQLERRM);
    retcode := NVL(g_retcode,2);
    output(fnd_message.get);
    --
    -- Bug 4105868: Collection Diagnostics
    --
    hri_bpl_conc_log.log_process_end
            (p_status         => FALSE
            ,p_period_from    => hr_general.start_of_time
            ,p_period_to      => hr_general.end_of_time
            );
    --
  WHEN others THEN
    --
    -- Unknown exception encountered, so raise an error
    --
    dbg('An error encountered while processing');
    errbuf  := SQLERRM;
    retcode := 2;
    output(fnd_message.get);
    output(SQLERRM);
    --
    -- Collection Diagnostics
    --
    hri_bpl_conc_log.log_process_end
            (p_status         => FALSE
            ,p_period_from    => hr_general.start_of_time
            ,p_period_to      => hr_general.end_of_time
            );
    --
END process_range;
--
-- ----------------------------------------------------------------------------
-- 7.1.6 Get multithread action array
-- Procedure   : GET_MTHD_ACTION_ARRAY
-- This function can be called by the collection programs to populate
-- the multithreading action arrays
-- ----------------------------------------------------------------------------
--
FUNCTION get_mthd_action_array(p_mthd_action_id  IN NUMBER)
RETURN hri_adm_mthd_actions%rowtype
IS
  --
  CURSOR c_adm_mthd_action IS
  SELECT *
  FROM   HRI_ADM_MTHD_ACTIONS
  WHERE  mthd_action_id = p_mthd_action_id;
  --
BEGIN
  --
  OPEN   c_adm_mthd_action;
  FETCH  c_adm_mthd_action into g_mthd_action_array;
  CLOSE  c_adm_mthd_action;
  --
  -- Populate the method action id global variable.
  --
  g_mthd_action_id := g_mthd_action_array.mthd_action_id;
  --
  RETURN g_mthd_action_array;
  --
END get_mthd_action_array;
--
-- Fix for bug 4043240
-- ------------------------------------------------------------------------------
-- FUNCTION get_current_mthd_action_id fetches the mthd_action_id for the invoking
-- process. If it does not exist, a new mthd_action_id is created and returned
-- ------------------------------------------------------------------------------
--
FUNCTION get_mthd_action_id(p_program            IN    VARCHAR2,
                            p_start_time         IN    DATE)
RETURN NUMBER
IS
  --
  l_process_name    VARCHAR2(30);
  --
BEGIN
  --
  dbg('In get_mthd_action_id');
  --
  -- Return the mthd action id of the current process if it is already defined
  --
  IF g_mthd_action_id IS NOT NULL THEN
    --
    RETURN g_mthd_action_id;
    --
  END IF;
  --
  -- The mthd action id of the current process is not defined.
  -- A new record will be created in hri_adm_mthd_actions
  -- corresponding to this process
  --
  -- store the program name and start time of the process
  --
  g_mthd_action_array.status                 := 'PROCESSING';
  g_mthd_action_array.program                :=  p_program;
  g_mthd_action_array.start_time             :=  p_start_time;
  --
  -- Insert the record in the multi threading table
  --
  gen_multi_thread_action;
  --
  dbg('Now g_mthd_action_id='||g_mthd_action_id);
  --
  --
  RETURN g_mthd_action_id;
  --
END get_mthd_action_id;
--
-- Updates the multi-threading parameters
PROCEDURE update_parameters(p_mthd_action_id     IN NUMBER,
                            p_full_refresh       IN VARCHAR2,
                            p_global_start_date  IN DATE) IS

BEGIN

  -- If a full refresh then set the flag and update the
  -- collect from date
  IF (p_full_refresh = 'Y') THEN

    UPDATE hri_adm_mthd_actions
    SET full_refresh_flag = 'Y'
       ,collect_from_date = p_global_start_date
    WHERE mthd_action_id = p_mthd_action_id;

  -- Otherwise just set the full refresh flag
  ELSE

    UPDATE hri_adm_mthd_actions
    SET full_refresh_flag = 'N'
    WHERE mthd_action_id = p_mthd_action_id;

  END IF;

  -- Commit
  commit;

END update_parameters;
--
-- ------------------------------------------------------------------------------
-- Returns worker id
-- ------------------------------------------------------------------------------
FUNCTION get_worker_id RETURN NUMBER IS

  l_worker_id   NUMBER;
  l_argument4   VARCHAR2(240);

  CURSOR worker_csr IS
  SELECT
   req.argument4
  FROM
   fnd_concurrent_requests req
  ,fnd_concurrent_programs prg
  WHERE req.concurrent_program_id = prg.concurrent_program_id
  AND req.program_application_id = prg.application_id
  AND prg.concurrent_program_name = 'HRI_MTHD_CHILD_PROCESS'
  AND req.request_id = fnd_global.conc_request_id;

BEGIN

  OPEN worker_csr;
  FETCH worker_csr INTO l_argument4;
  CLOSE worker_csr;

  l_worker_id := to_number(l_argument4);

  RETURN NVL(l_worker_id, 1);

EXCEPTION WHEN OTHERS THEN

  RETURN 1;

END get_worker_id;
--
END HRI_OPL_MULTI_THREAD;

/
