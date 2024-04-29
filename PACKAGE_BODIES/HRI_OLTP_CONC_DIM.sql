--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_CONC_DIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_CONC_DIM" AS
/* $Header: hriocdim.pkb 120.9 2006/10/06 17:47:11 smohapat noship $ */

g_msg_sub_group           VARCHAR2(400);

-- ----------------------------------------------------------
--  Loads Supervisor Hierarchy History table
-- ----------------------------------------------------------
PROCEDURE load_supervisor_history
        (errbuf          OUT NOCOPY  VARCHAR2
        ,retcode         OUT NOCOPY VARCHAR2) IS

  l_start_date             VARCHAR2(80);
  l_end_date               VARCHAR2(80);
  l_full_refresh           VARCHAR2(10);

BEGIN

  l_full_refresh := hri_oltp_conc_param.get_parameter_value
                     (p_parameter_name     => 'FULL_REFRESH',
                      p_process_table_name => 'HRI_CS_SUPH');

  l_end_date := fnd_date.date_to_displaydt(hr_general.end_of_time);

  -- Set the refresh start date for full refresh
  IF (l_full_refresh = 'Y') THEN
    l_start_date := hri_oltp_conc_param.get_parameter_value
                     (p_parameter_name     => 'FULL_REFRESH_FROM_DATE',
                      p_process_table_name => 'HRI_CS_SUPH');
  ELSE
    l_start_date := fnd_date.date_to_canonical
                     (fnd_date.displaydt_to_date
                       (hri_bpl_conc_log.get_last_collect_to_date
                         ('HRI_CS_SUPH','HRI_CS_SUPH')));
  END IF;

  hri_bpl_conc_log.dbg('Full refresh:   ' || l_full_refresh);
  hri_bpl_conc_log.dbg('Collect from:   ' || l_start_date);

  load_supervisor_history
   (errbuf         => errbuf,
    retcode        => retcode,
    p_chunk_size   => 1500,
    p_start_date   => l_start_date,
    p_end_date     => l_end_date,
    p_full_refresh => l_full_refresh,
    p_drop_mv_log  => 'N');
  --
END load_supervisor_history;

-- ----------------------------------------------------------
--  Loads Supervisor Hierarchy History table
-- ----------------------------------------------------------
PROCEDURE load_supervisor_history
        (errbuf          OUT NOCOPY  VARCHAR2
        ,retcode         OUT NOCOPY VARCHAR2
        ,p_start_date    IN VARCHAR2
        ,p_end_date      IN VARCHAR2
        ,p_full_refresh  IN VARCHAR2
        ,p_chunk_size    IN NUMBER
        ,p_drop_mv_log   IN VARCHAR2) IS

  l_start_date             DATE;
  l_end_date               DATE;
  l_is_hr_installed        VARCHAR2(10);
  l_full_refresh           VARCHAR2(10);
  l_frc_shrd_hr_prfl_val   VARCHAR2(30); -- Variable to store value for
                                         -- Profile HRI:DBI Force Foundation HR Processes
  --
BEGIN

  hri_oltp_conc_suph_master.load_all_managers
   (errbuf         => errbuf,
    retcode        => retcode,
    p_chunk_size   => p_chunk_size,
    p_start_date   => p_start_date,
    p_end_date     => p_end_date,
    p_full_refresh => p_full_refresh);

END load_supervisor_history;

-- ----------------------------------------------------------
--  Loads Position Hierarchy table
-- ----------------------------------------------------------
PROCEDURE load_all_positions
                  (errbuf          OUT NOCOPY  VARCHAR2
                  ,retcode         OUT NOCOPY  VARCHAR2
                  ,p_chunk_size    IN NUMBER
                  ) IS
--
BEGIN
  --
  hri_bpl_conc_log.record_process_start('HRI_CS_POSH');
  --
  hri_opl_posh.load_all_positions
          (errbuf       => errbuf
          ,retcode      => retcode
          ,p_chunk_size => p_chunk_size
          );
  --
  hri_bpl_conc_log.log_process_end
          (p_status         => TRUE
          ,p_attribute1     => p_chunk_size
          );
  --
  -- Bug 4105868: Collection Diagnostics
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    hri_bpl_conc_log.log_process_end
            (p_status         => FALSE
            ,p_attribute1     => p_chunk_size
            );
    --
END load_all_positions;
--
-- ----------------------------------------------------------
-- Loads Organization Hierarchy table
-- ----------------------------------------------------------
--
PROCEDURE load_all_organizations
                  (errbuf          OUT NOCOPY VARCHAR2
                  ,retcode         OUT NOCOPY VARCHAR2
                  ,p_chunk_size    IN NUMBER
                  ) IS
--
BEGIN
  --
  hri_bpl_conc_log.record_process_start('HRI_ORG_HRCHY_SUMMARY');
  --
  hri_opl_orgh.load
          (errbuf => errbuf
          ,retcode => retcode
          ,p_chunk_size => p_chunk_size
          );
  --
  hri_bpl_conc_log.log_process_end
          (p_status         => TRUE
          ,p_attribute1     => p_chunk_size
          );
  --
  -- Bug 4105868: Collection Diagnostics
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    hri_bpl_conc_log.log_process_end
            (p_status         => FALSE
            ,p_attribute1     => p_chunk_size
            );
    --
END load_all_organizations;

-- ----------------------------------------------------------
--   Loads Job Hierarchy table
-- ----------------------------------------------------------
PROCEDURE load_all_jobs
        (errbuf          OUT NOCOPY  VARCHAR2
        ,retcode         OUT NOCOPY  VARCHAR2
        ,p_full_refresh  IN VARCHAR2) IS

  l_full_refresh     VARCHAR2(30);

BEGIN

  -- Log process start
  hri_bpl_conc_log.record_process_start('HRI_CS_JOBH_CT');

  -- If the full refresh parameter is not provided, default it
  IF (p_full_refresh IS NULL) THEN
    l_full_refresh := hri_oltp_conc_param.get_parameter_value
                       (p_parameter_name     => 'FULL_REFRESH',
                        p_process_table_name => 'HRI_CS_JOBH_CT');
  ELSE
    l_full_refresh := p_full_refresh;
  END IF;

  hri_bpl_conc_log.dbg('Full refresh:   ' || l_full_refresh);
  hri_bpl_conc_log.dbg('Collect from:   N/A');

  IF (l_full_refresh = 'Y') THEN
    hri_opl_jobh.full_refresh;
  ELSE
    hri_opl_jobh.incr_refresh(p_refresh_flex => 'N');
  END IF;

  hri_bpl_conc_log.log_process_end
          (p_status         => TRUE
          ,p_period_from    => hr_general.start_of_time
          ,p_period_to      => hr_general.end_of_time
          ,p_attribute1     => p_full_refresh
          );

EXCEPTION WHEN OTHERS THEN

    hri_bpl_conc_log.log_process_end
            (p_status         => FALSE
            ,p_period_from    => hr_general.start_of_time
            ,p_period_to      => hr_general.end_of_time
            ,p_attribute1     => p_full_refresh);

END load_all_jobs;

-- ----------------------------------------------------------
--   Loads Person Type Hierarchy tables
-- ----------------------------------------------------------
PROCEDURE load_all_person_types(errbuf          OUT NOCOPY  VARCHAR2,
                                retcode         OUT NOCOPY  VARCHAR2,
                                p_full_refresh  IN VARCHAR2) IS

  l_full_refresh  VARCHAR2(30);

BEGIN

  -- As the process is being run from CM, enable output logging
  hri_bpl_conc_log.record_process_start('HRI_CS_PRSNTYP_CT');

  -- If the full refresh parameter is not provided, default it
  IF (p_full_refresh IS NULL) THEN
    l_full_refresh := hri_oltp_conc_param.get_parameter_value
                       (p_parameter_name     => 'FULL_REFRESH',
                        p_process_table_name => 'HRI_CS_PRSNTYP_CT');
  ELSE
    l_full_refresh := p_full_refresh;
  END IF;

  hri_bpl_conc_log.dbg('Full refresh:   ' || l_full_refresh);
  hri_bpl_conc_log.dbg('Collect from:   N/A');

  -- Set warning off (in case this session is re-used)
  hri_bpl_person_type.g_warning_flag := 'N';

  -- Call the appropriate function depending on full refresh parameter
  IF (l_full_refresh = 'Y') THEN
    hri_opl_person_type_ctgry.full_refresh;
  ELSE
    hri_opl_person_type_ctgry.incr_refresh;
  END IF;

  -- In case a warning was raised in the person type fast formula
  -- package, then process should be marked as warning
  IF hri_bpl_person_type.g_warning_flag = 'Y' THEN
    errbuf  := 'WARNING';
    retcode := 1;
  END IF;

  -- Log process end
  hri_bpl_conc_log.log_process_end
          (p_status         => TRUE
          ,p_period_from    => hr_general.start_of_time
          ,p_period_to      => hr_general.end_of_time
          ,p_attribute1     => 'N');

-- Bug 4105868: Collection Diagnostics
EXCEPTION WHEN OTHERS THEN

  g_msg_sub_group := NVL(g_msg_sub_group, 'INCR_REFRESH');

  hri_bpl_conc_log.log_process_info
   (p_package_name      => 'HRI_OPL_PERSON_TYPE_CTGRY'
   ,p_msg_type          => 'ERROR'
   ,p_msg_group         => 'PRSN_TYP_CNGS'
   ,p_msg_sub_group     => g_msg_sub_group
   ,p_sql_err_code      => SQLCODE
   ,p_note              => SQLERRM);

  hri_bpl_conc_log.log_process_end
   (p_status         => FALSE
   ,p_period_from    => hr_general.start_of_time
   ,p_period_to      => hr_general.end_of_time
   ,p_attribute1     => 'N');

  RAISE;

END load_all_person_types;

-- ----------------------------------------------------------
--   Loads Person Dimension CT
-- ----------------------------------------------------------
PROCEDURE load_all_persons(errbuf          OUT NOCOPY  VARCHAR2,
                                retcode         OUT NOCOPY  VARCHAR2,
                                p_full_refresh  IN VARCHAR2) IS

  l_full_refresh  VARCHAR2(30);

BEGIN

  -- As the process is being run from CM, enable output logging
  hri_bpl_conc_log.record_process_start('HRI_CS_PER_PERSON_CT');

  -- If the full refresh parameter is not provided, default it
  IF (p_full_refresh IS NULL) THEN
    l_full_refresh := hri_oltp_conc_param.get_parameter_value
                       (p_parameter_name     => 'FULL_REFRESH',
                        p_process_table_name => 'HRI_CS_PER_PERSON_CT');
  ELSE
    l_full_refresh := p_full_refresh;
  END IF;

  hri_bpl_conc_log.dbg('Full refresh:   ' || l_full_refresh);
  hri_bpl_conc_log.dbg('Collect from:   N/A');

  -- Call the appropriate function depending on full refresh parameter
  IF (l_full_refresh = 'Y') THEN
      hri_opl_per_person.load(1500,
                              to_char(hr_general.start_of_time, 'YYYY/MM/DD HH24:MI:SS'),
                              to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')
                              ,'Y');
  ELSE
      hri_opl_per_person.load(1500,
                              to_char(hr_general.start_of_time, 'YYYY/MM/DD HH24:MI:SS'),
                              to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')
                              ,'N');

  END IF;

  -- Log process end
  hri_bpl_conc_log.log_process_end
          (p_status         => TRUE
          ,p_period_from    => hr_general.start_of_time
          ,p_period_to      => hr_general.end_of_time
          ,p_attribute1     => 'N');

EXCEPTION WHEN OTHERS THEN

  g_msg_sub_group := NVL(g_msg_sub_group, 'INCR_REFRESH');

  hri_bpl_conc_log.log_process_info
   (p_package_name      => 'HRI_CS_PER_PERSON_CT'
   ,p_msg_type          => 'ERROR'
   ,p_msg_group         => 'PRSN_CNGS'
   ,p_msg_sub_group     => g_msg_sub_group
   ,p_sql_err_code      => SQLCODE
   ,p_note              => SQLERRM);

  hri_bpl_conc_log.log_process_end
   (p_status         => FALSE
   ,p_period_from    => hr_general.start_of_time
   ,p_period_to      => hr_general.end_of_time
   ,p_attribute1     => 'N');

  RAISE;

END load_all_persons;


-- ----------------------------------------------------------
-- Loads period of work band table
-- ----------------------------------------------------------
PROCEDURE load_all_pow_bands
       (errbuf         OUT NOCOPY VARCHAR2
       ,retcode        OUT NOCOPY VARCHAR2
       ,p_full_refresh  IN VARCHAR2) IS

  l_full_refresh     VARCHAR2(30);

BEGIN

  -- Log process start
  hri_bpl_conc_log.record_process_start('HRI_CS_POW_BAND_CT');

  -- If the full refresh parameter is not provided, default it
  IF (p_full_refresh IS NULL) THEN
    l_full_refresh := hri_oltp_conc_param.get_parameter_value
                       (p_parameter_name     => 'FULL_REFRESH',
                        p_process_table_name => 'HRI_CS_POW_BAND_CT');
  ELSE
    l_full_refresh := p_full_refresh;
  END IF;

  hri_bpl_conc_log.dbg('Full refresh:   ' || l_full_refresh);
  hri_bpl_conc_log.dbg('Collect from:   N/A');

  -- Set warning off - in case the session is reused
  hri_opl_period_of_work.g_warning_flag := 'N';

  -- Refresh only when the full refresh flag is set to 'Y'
  IF (l_full_refresh = 'Y') THEN

    -- Full refresh
    hri_opl_period_of_work.full_refresh;

  ELSE

    -- Period of work bands are not refreshed in incremental mode
    -- Log this into the concurrent program log
    hri_bpl_conc_log.output('Period of work bands are not ' ||
                            'refreshed in incremental mode');

  END IF;

  -- In case a warning is raised then the process should be marked as warning
  IF (hri_opl_period_of_work.g_warning_flag = 'Y') THEN
    errbuf:= 'WARNING';
    retcode:= 1;
  END IF;

  -- Log process end
  hri_bpl_conc_log.log_process_end
          (p_status         => TRUE
          ,p_period_from    => hr_general.start_of_time
          ,p_period_to      => hr_general.end_of_time
          ,p_attribute1     => 'N');

EXCEPTION WHEN OTHERS THEN

  hri_bpl_conc_log.log_process_end
   (p_status         => FALSE
   ,p_period_from    => hr_general.start_of_time
   ,p_period_to      => hr_general.end_of_time
   ,p_attribute1     => 'N');

  RAISE;

END load_all_pow_bands;

--
-- ----------------------------------------------------------
-- Loads job role table
-- ----------------------------------------------------------
--
PROCEDURE load_all_job_job_roles
       (errbuf         OUT NOCOPY VARCHAR2
       ,retcode        OUT NOCOPY VARCHAR2
       ,p_full_refresh IN VARCHAR2) IS

  l_full_refresh    VARCHAR2(30);

BEGIN

  -- Log process start
  hri_bpl_conc_log.record_process_start('HRI_CS_JOB_JOB_ROLE_CT');

  -- If the full refresh parameter is not provided, default it
  IF (p_full_refresh IS NULL) THEN
    l_full_refresh := hri_oltp_conc_param.get_parameter_value
                       (p_parameter_name     => 'FULL_REFRESH',
                        p_process_table_name => 'HRI_CS_JOB_JOB_ROLE_CT');
  ELSE
    l_full_refresh := p_full_refresh;
  END IF;

  hri_bpl_conc_log.dbg('Full refresh:   ' || l_full_refresh);
  hri_bpl_conc_log.dbg('Collect from:   N/A');

  -- Set warning off - in case the session is reused
  hri_bpl_job.g_warning_flag := 'N';

  IF (l_full_refresh = 'Y') THEN
    hri_opl_job_job_role.full_refresh;
  ELSE
    hri_opl_job_job_role.incr_refresh;
  END IF;

  -- In case a warning is raised then the process should be marked as warning
  IF (hri_bpl_job.g_warning_flag = 'Y') THEN
    errbuf:= 'WARNING';
    retcode:= 1;
  END IF;

  -- Log process end
  hri_bpl_conc_log.log_process_end
          (p_status         => TRUE
          ,p_period_from    => hr_general.start_of_time
          ,p_period_to      => SYSDATE
          ,p_attribute1     => 'N');

EXCEPTION WHEN OTHERS THEN

  hri_bpl_conc_log.log_process_end
   (p_status         => FALSE
   ,p_period_from    => hr_general.start_of_time
   ,p_period_to      => SYSDATE
   ,p_attribute1     => 'N');

  RAISE;

END load_all_job_job_roles;

END HRI_OLTP_CONC_DIM;

/
