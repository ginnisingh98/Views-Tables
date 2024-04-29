--------------------------------------------------------
--  DDL for Package Body PQP_GB_MANAGE_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_MANAGE_LIFE_EVENTS" AS
/* $Header: pqpgbmle.pkb 120.0.12010000.4 2009/05/18 11:40:26 vaibgupt ship $ */
--
--
--
  g_package_name  VARCHAR2(31):= 'pqp_gb_manage_life_events.';
  g_debug         BOOLEAN:= hr_utility.debug_enabled;
  g_nested_level  NUMBER:= 0;

  hr_application_error  EXCEPTION;
  PRAGMA EXCEPTION_INIT(hr_application_error, -20001);


  PROCEDURE debug
    (p_trace_message  IN     VARCHAR2
    ,p_trace_location IN     NUMBER   DEFAULT NULL
    )
  IS
     l_padding VARCHAR2(12);
     l_MAX_MESSAGE_LENGTH NUMBER:= 72;
  BEGIN

      IF p_trace_location IS NOT NULL THEN

--        l_padding := SUBSTR
--                      (RPAD(' ',LEAST(g_nested_level,5)*2,' ')
--                      ,1,l_MAX_MESSAGE_LENGTH
--                         - LEAST(LENGTH(p_trace_message)
--                                ,l_MAX_MESSAGE_LENGTH)
--                      );

       hr_utility.set_location
        (--l_padding||
         SUBSTR(p_trace_message
               ,GREATEST(-LENGTH(p_trace_message),-l_MAX_MESSAGE_LENGTH))
        ,p_trace_location);

      ELSE

       hr_utility.trace(SUBSTR(p_trace_message,1,250));

      END IF;

  END debug;
--
--
--
  PROCEDURE debug
    (p_trace_number IN     NUMBER )
  IS
  BEGIN
      debug(fnd_number.number_to_canonical(p_trace_number));
  END debug;
--
--
--
  PROCEDURE debug
    (p_trace_date IN     DATE )
  IS
  BEGIN
      debug(fnd_date.date_to_canonical(p_trace_date));
  END debug;
--
--
--
  PROCEDURE debug_enter
    (p_proc_name IN     VARCHAR2
    ,p_trace_on  IN     VARCHAR2 DEFAULT NULL
    )
  IS

  BEGIN

    g_nested_level :=  g_nested_level + 1;
    debug('Entering: '||NVL(p_proc_name,g_package_name),g_nested_level*100);

  END debug_enter;
--
--
--
  PROCEDURE debug_exit
    (p_proc_name               IN     VARCHAR2
    ,p_trace_off               IN     VARCHAR2 DEFAULT NULL
    )
  IS
  BEGIN

    debug('Leaving: '||NVL(p_proc_name,g_package_name),-g_nested_level*100);
    g_nested_level := g_nested_level - 1;

  END debug_exit;
--
--
--
PROCEDURE abse_process
  (p_business_group_id        IN     NUMBER
  ,p_person_id                IN     NUMBER
  ,p_effective_date           IN     DATE
  ,p_absence_attendance_id    IN     NUMBER  -- DEFAULT NULL
  ,p_absence_start_date       IN     DATE    -- DEFAULT NULL
  ,p_absence_end_date         IN     DATE    -- DEFAULT NULL
  ,p_errbuf                      OUT NOCOPY VARCHAR2
  ,p_retcode                     OUT NOCOPY NUMBER
  )
IS

  l_after_run_last_ben_report    csr_last_ben_report%ROWTYPE;
  l_before_run_last_ben_report   csr_last_ben_report%ROWTYPE;

  l_benmngle_batch_parameter     csr_benmngle_batch_parameter%ROWTYPE;
  l_ben_batch_parameter_exists   BOOLEAN;

  l_proc_step                    NUMBER(38,10):= 0;
  l_proc_name                    VARCHAR2(61):= g_package_name||'abse_process';

  l_plsql_block                  VARCHAR2(5000);

  l_commit_data                  VARCHAR2(10) := 'Y';
  l_mode                         VARCHAR2(10) := 'M'; -- Absences, Lookup Type BEN_BENMNGLE_MD

  l_audit_log_flag               VARCHAR2(10) := 'Y';

  l_effective_date_canonical     VARCHAR2(30);
  l_effective_date               DATE;


  l_error_code                   fnd_new_messages.message_number%TYPE;
  l_error_message                ben_reporting.text%TYPE;

  PROCEDURE del_or_upd_ben_batch_parameter
    (p_ben_batch_parameter_exists IN BOOLEAN
    ,p_batch_parameter_id         IN NUMBER
    ,p_max_err_num                IN NUMBER
    )
  IS

    l_proc_step  NUMBER(38,10);
    l_proc_name  VARCHAR2(61):=
      g_package_name||'del_or_upd_ben_batch_parameter';

  BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;

/*  --vaibgupt 8299459
    IF p_ben_batch_parameter_exists
    THEN -- update max_err_num to what it was before the run

      IF g_debug THEN
        l_proc_step := 10;
        debug(l_proc_name,l_proc_step);
      END IF;

      UPDATE ben_batch_parameter
         SET max_err_num = p_max_err_num
      WHERE  batch_parameter_id = p_batch_parameter_id;

      IF g_debug THEN
        debug(SQL%ROWCOUNT||' rows updated.');
        l_proc_step := 15;
        debug(l_proc_name,l_proc_step);
      END IF;

    ELSE -- did not exist before run so delete the one which was inserted

      IF g_debug THEN
        l_proc_step := 20;
        debug(l_proc_name,l_proc_step);
        debug('p_batch_parameter_id:'||p_batch_parameter_id);
      END IF;

      DELETE FROM ben_batch_parameter WHERE batch_parameter_id = p_batch_parameter_id;

      IF g_debug THEN
        debug(SQL%ROWCOUNT||' rows deleted.');
        l_proc_step := 25;
        debug(l_proc_name,l_proc_step);
      END IF;


    END IF;

    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;

*/
  END del_or_upd_ben_batch_parameter;



  PROCEDURE get_last_ben_report
    (p_person_id       IN     NUMBER
    ,p_process_date    IN     DATE
    ,p_last_ben_report    OUT NOCOPY csr_last_ben_report%ROWTYPE
    )
  IS

    l_last_ben_report csr_last_ben_report%ROWTYPE;

    l_proc_step       NUMBER(38,10);
    l_proc_name       VARCHAR2(61):=
      g_package_name||'get_last_ben_report';

  BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;

    OPEN csr_last_ben_report
      (p_person_id
      ,p_process_date
      );
    FETCH csr_last_ben_report INTO p_last_ben_report;
    CLOSE csr_last_ben_report;

    --p_last_ben_report := l_last_ben_report;

    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;

  END get_last_ben_report;

BEGIN -- main()

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
    debug_enter(l_proc_name);
  END IF;

  -- error handling improvements
  /*
    1. retrieve ben_batch_parameter for BENMNGLE
    2. set max error count to 1, insert if a row did not exist in ben_batch_param
    3. count the number of ben_reporting entries for this person
       -- to count try join with ben_benefit_actions
    4. set audit flag to Y
    5. do the usual call
    6. count the number of ben_erporting_entries for this person
    7. If it differs from the count before execution then raise exception
    8. or if an exception has occured and we are in the expcetion block
    then
    9. check for the latest ben_reporting entry
    10. if there is one retrive the text set that token for pqp dummy message
    11. and fnd raise error.
  */


/*  -- vaibgupt 8299459
  OPEN csr_benmngle_batch_parameter(p_business_group_id => p_business_group_id);
  FETCH csr_benmngle_batch_parameter INTO l_benmngle_batch_parameter;
  CLOSE csr_benmngle_batch_parameter;

  IF l_benmngle_batch_parameter.batch_parameter_id IS NOT NULL
  THEN

    IF g_debug THEN
      l_proc_step := 10;
      debug(l_proc_name,l_proc_step);
    END IF;

    l_ben_batch_parameter_exists := TRUE;

	  -- Begin Changes by Vaibgupt (Vaibhav Gupta) bug 8299459    (Commenting the Update statement )
		--    UPDATE ben_batch_parameter
		--       SET max_err_num = 1
		--    WHERE  batch_parameter_id = l_benmngle_batch_parameter.batch_parameter_id;
	  --End Changes by Vaibgupt (Vaibhav Gupta)   bug 8299459


  ELSE

    IF g_debug THEN
      l_proc_step := 20;
      debug(l_proc_name,l_proc_step);
    END IF;

    l_ben_batch_parameter_exists := FALSE;
    INSERT INTO ben_batch_parameter
     (batch_parameter_id       -- NOT NULL NUMBER(15)
     ,batch_exe_cd             --          VARCHAR2(30)
     ,business_group_id        -- NOT NULL NUMBER(15)
     ,thread_cnt_num           --          NUMBER(15)
     ,max_err_num              --          NUMBER(15)
     ,chunk_size               --          NUMBER(15)
     ,last_update_date         --          DATE
     ,last_updated_by          --          NUMBER(15)
     ,last_update_login        --          NUMBER(15)
     ,created_by               --          NUMBER(15)
     ,creation_date            --          DATE
     ,object_version_number    --          NUMBER(9)
     )
    SELECT ben_batch_parameter_s.NEXTVAL   --batch_parameter_id
          ,'BENMNGLE'                      --batch_exe_cd
          ,p_business_group_id             --business_group_id
          ,NULL                            --thread_cnt_num
          ,1                               --max_err_num
          ,NULL                            --chunk_size
          ,SYSDATE                         --last_update_date
          ,-1                              --last_updated_by
          ,-1                              --last_update_login
          ,-1                              --created_by
          ,SYSDATE                         --creation_date
          ,1                               --object_version_number
    FROM  DUAL;

    OPEN csr_benmngle_batch_parameter(p_business_group_id => p_business_group_id);
    FETCH csr_benmngle_batch_parameter INTO l_benmngle_batch_parameter;
    CLOSE csr_benmngle_batch_parameter;

  END IF;

  */


  l_audit_log_flag := 'Y';

  l_plsql_block :=
     'BEGIN
        ben_manage_life_events.abse_process
        (errbuf                     => :Out1
        ,retcode                    => :Out2
        ,p_effective_date           => :In1
        ,p_mode                     => :In2
        ,p_person_id                => :In3
        ,p_business_group_id        => :In4
        ,p_commit_data              => :In5
        ,p_audit_log_flag           => :In6
        );
      END;
     ';

  IF g_debug THEN
    l_proc_step := 30;
    debug(l_proc_name,l_proc_step);
  END IF;


  IF p_absence_end_date IS NOT NULL
  THEN

    IF g_debug THEN
      l_proc_step := 35;
      debug(l_proc_name,l_proc_step);
    END IF;

    l_effective_date_canonical := fnd_date.date_to_canonical(p_absence_end_date);

  ELSIF p_absence_start_date IS NOT NULL
  THEN

    IF g_debug THEN
      l_proc_step := 35;
      debug(l_proc_name,l_proc_step);
    END IF;

    l_effective_date_canonical := fnd_date.date_to_canonical(p_absence_start_date);

  ELSE

    IF g_debug THEN
      l_proc_step := 40;
      debug(l_proc_name,l_proc_step);
    END IF;

    -- Start and end date are NULL, either
    --  a) Absence has been deleted OR
    --  b) User pressed button on Absence in an empty new record.
    --
    -- setting p_effective_date as effective date
    l_effective_date_canonical := fnd_date.date_to_canonical(p_effective_date);

  END IF;

  IF g_debug THEN
    l_proc_step := 45;
    debug(l_proc_name,l_proc_step);
  END IF;

  l_effective_date :=
    fnd_date.canonical_to_date(l_effective_date_canonical);

  get_last_ben_report -- before run
   (p_person_id       => p_person_id
   ,p_process_date    => l_effective_date
   ,p_last_ben_report => l_before_run_last_ben_report
   );

  IF g_debug THEN
    l_proc_step := 50;
    debug(l_proc_name,l_proc_step);
    debug('l_effective_date_canonical:'||l_effective_date_canonical);
  END IF;

  EXECUTE IMMEDIATE l_plsql_block
  USING  OUT p_errbuf
        ,OUT p_retcode
        ,l_effective_date_canonical
        ,l_mode
        ,p_person_id
        ,p_business_group_id
        ,l_commit_data
        ,l_audit_log_flag;

  IF g_debug THEN
    l_proc_step := 60;
    debug(l_proc_name,l_proc_step);
  END IF;

-- Note a commit has been issue at this point

  get_last_ben_report -- after run
   (p_person_id       => p_person_id
   ,p_process_date    => l_effective_date
   ,p_last_ben_report => l_after_run_last_ben_report
   );

  IF g_debug THEN
    l_proc_step := 70;
    debug(l_proc_name,l_proc_step);
  END IF;

  IF ( NVL(l_after_run_last_ben_report.reporting_id,-1)
      <>
       NVL(l_before_run_last_ben_report.reporting_id,-1)
     )
     AND
     ( l_after_run_last_ben_report.rep_typ_cd IN ('FATAL')
      OR
       l_after_run_last_ben_report.rep_typ_cd LIKE 'ERROR%'
     )
  THEN
  -- there has been an error recorded
  -- but some how no exception was raised
  -- do so now.
    IF g_debug THEN
      l_proc_step := 75;
      debug(l_proc_name,l_proc_step);
    END IF;

    RAISE hr_application_error;
    -- it will be handled as WHEN OTHERS

  END IF; -- IF ( NVL(l_after_run_last_ben_report.reporting_id,-1)

  IF g_debug THEN
    l_proc_step := 80;
    debug(l_proc_name,l_proc_step);
  END IF;

/* --vaibgupt 8299459
  del_or_upd_ben_batch_parameter
   (l_ben_batch_parameter_exists
   ,l_benmngle_batch_parameter.batch_parameter_id
   ,l_benmngle_batch_parameter.max_err_num
   );
*/
  -- restore the effective date to what it was before the run
  -- as benmngle changes fnd_sessions row
  UPDATE fnd_sessions
  SET    effective_date = p_effective_date
  WHERE  session_id = USERENV('sessionid');

  COMMIT;

  IF g_debug THEN
    debug_exit(l_proc_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- Note a commit has been issue at this point whether or not
    -- benmgle raises an error. However just to be sure
    -- issue a ROLLBACK and then COMMIT any changes in this handler
    -- before issuing a fnd_message.raise_error

    l_error_code := SQLCODE;
    l_error_message := --l_proc_name||'{'||l_proc_step||'}:'||SUBSTR(SQLERRM,1,1930);
      SUBSTR(SQLERRM,1,2000);

    IF g_debug THEN
      debug(l_proc_name,-999);
      debug(l_proc_name||'{'||l_proc_step||'}:');
      debug(l_error_code);
      debug(l_error_message);
    END IF;

    IF l_error_code = hr_utility.hr_error_number
    THEN

      IF g_debug THEN
        l_proc_step := -998;
       debug(l_proc_name,l_proc_step);
      END IF;

      -- is an app exception
      -- dirty code need to examine if ben is passing back
      -- an exception name or an exception text
      -- if its the name get the string note we cannot
      -- report tokens like this
      --
      IF l_error_message LIKE 'ORA-20001: BEN_9%'
        OR
         l_error_message LIKE 'ORA-20001: PQP_2%'
      THEN

        IF g_debug THEN
          l_proc_step := -997;
          debug(l_proc_name,l_proc_step);
        END IF;

        l_error_message := -- extract the msg short name
          rtrim(ltrim(substr(l_error_message, instr(l_error_message,':')+1)),':');

        l_error_message :=
          fnd_message.get_string(SUBSTR(l_error_message,1,3),SUBSTR(l_error_message,1,30));

      ELSE
        IF g_debug THEN
          l_proc_step := -996;
          debug(l_proc_name,l_proc_step);
        END IF;

        l_error_message :=
          l_proc_name||'{'||l_proc_step||'}:'||SUBSTR(SQLERRM,1,1930);
      END IF;

    ELSE
        IF g_debug THEN
          l_proc_step := -995;
          debug(l_proc_name,l_proc_step);
        END IF;
      l_error_message := l_proc_name||'{'||l_proc_step||'}:'||SUBSTR(SQLERRM,1,1930);
    END IF;


    ROLLBACK;

    p_errbuf  := SUBSTR(l_error_message,1,1000);
    -- as the receiving size is max 1000
    p_retcode := l_error_code;

    IF g_debug THEN
      debug(l_proc_name,-990);
      debug('l_batch_parameter_id:'||l_benmngle_batch_parameter.batch_parameter_id);
    END IF;

    del_or_upd_ben_batch_parameter
     (l_ben_batch_parameter_exists
     ,l_benmngle_batch_parameter.batch_parameter_id
     ,l_benmngle_batch_parameter.max_err_num
     );

    IF g_debug THEN
      debug(l_proc_name,-980);
    END IF;

    IF l_after_run_last_ben_report.reporting_id IS NULL
    THEN
      -- exception raised from within BENMGLE

      IF g_debug THEN
        debug(l_proc_name,-970);
      END IF;

      get_last_ben_report
       (p_person_id       => p_person_id
       ,p_process_date    => l_effective_date
       ,p_last_ben_report => l_after_run_last_ben_report
       );

      IF g_debug THEN
        debug(l_proc_name,-960);
      END IF;

    END IF; -- IF l_after_run_last_ben_report.reporting_id IS NULL

    IF l_after_run_last_ben_report.reporting_id IS NOT NULL
      AND
       ( l_after_run_last_ben_report.reporting_id
        <> -- need to check again since this could be app an
           -- exception from within benmgle or one we raised
         NVL(l_before_run_last_ben_report.reporting_id,-1)
       )
      AND
       l_after_run_last_ben_report.text IS NOT NULL
    THEN
    -- if a after run ben report was found
    -- which was not the same as the one before the run
    -- and has a not null text then set the error message
    -- to be reported with that new text

      IF g_debug THEN
        debug(l_proc_name,-950);
      END IF;

      l_error_message := l_after_run_last_ben_report.text;

    END IF; --IF l_after_run_last_ben_report.reporting_id IS NOT NULL

    IF g_debug THEN
      debug(l_proc_name,-940);
    END IF;

    -- restore the effective date to what it was before the run
    UPDATE fnd_sessions
    SET    effective_date = p_effective_date
    WHERE  session_id = USERENV('sessionid');

    fnd_message.set_name('PQP', 'PQP_230661_OSP_DUMMY_MSG');
    fnd_message.set_token('TOKEN', l_error_message);
    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;

    COMMIT; -- why ??
    -- to ensure that the changes to ben_batch_parameters are applied.

    fnd_message.raise_error;

END abse_process;
--
--
--
END pqp_gb_manage_life_events;

/
