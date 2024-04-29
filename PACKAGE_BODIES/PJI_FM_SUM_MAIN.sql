--------------------------------------------------------
--  DDL for Package Body PJI_FM_SUM_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_SUM_MAIN" as
  /* $Header: PJISF01B.pls 120.12 2007/07/11 14:21:02 rvelusam ship $ */

  -- -----------------------------------------------------
  -- procedure RUN_SETUP
  -- -----------------------------------------------------
  procedure RUN_SETUP is

    l_transition_flag         varchar2(1);

    l_settings_proj_perf_flag varchar2(1);
    l_settings_cost_flag      varchar2(1);
    l_settings_profit_flag    varchar2(1);
    l_settings_util_flag      varchar2(1);

    l_params_proj_perf_flag   varchar2(1);
    l_params_cost_flag        varchar2(1);
    l_params_profit_flag      varchar2(1);
    l_params_util_flag        varchar2(1);

    l_row_count            number;
    l_no_setup_error       varchar2(255) := 'Environment is not setup to run summarization.  Check PJI setup and BIS profiles.';
    l_setup_error          varchar2(255) := 'Turning off an active functional area is not allowed.';
    l_dangling_error       varchar2(255) := 'Cannot run a configuration transition when dangling rows exist.';

  begin

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'TRANSITION') is not null) then
      return;
    end if;

    select
      CONFIG_PROJ_PERF_FLAG,
      CONFIG_COST_FLAG,
      CONFIG_PROFIT_FLAG,
      CONFIG_UTIL_FLAG
    into
      l_settings_proj_perf_flag,
      l_settings_cost_flag,
      l_settings_profit_flag,
      l_settings_util_flag
    from
      PJI_SYSTEM_SETTINGS;

    if ((l_settings_proj_perf_flag is null and
         l_settings_cost_flag      is null and
         l_settings_profit_flag    is null and
         l_settings_util_flag      is null)                    or
        FND_PROFILE.VALUE('BIS_GLOBAL_START_DATE')     is null or
        FND_PROFILE.VALUE('BIS_PRIMARY_CURRENCY_CODE') is null or
        FND_PROFILE.VALUE('BIS_PRIMARY_RATE_TYPE')     is null or
        FND_PROFILE.VALUE('BIS_ENTERPRISE_CALENDAR')   is null or
        FND_PROFILE.VALUE('BIS_PERIOD_TYPE')           is null) then

      rollback;
      dbms_standard.raise_application_error(-20044, l_no_setup_error);

    end if;

    l_settings_proj_perf_flag := nvl(l_settings_proj_perf_flag, 'N');
    l_settings_cost_flag      := nvl(l_settings_cost_flag,      'N');
    l_settings_profit_flag    := nvl(l_settings_profit_flag,    'N');
    l_settings_util_flag      := nvl(l_settings_util_flag,      'N');

    l_params_proj_perf_flag :=
                    nvl(PJI_UTILS.GET_PARAMETER('CONFIG_PROJ_PERF_FLAG'), 'N');
    l_params_cost_flag :=
                    nvl(PJI_UTILS.GET_PARAMETER('CONFIG_COST_FLAG'), 'N');
    l_params_profit_flag :=
                    nvl(PJI_UTILS.GET_PARAMETER('CONFIG_PROFIT_FLAG'), 'N');
    l_params_util_flag :=
                    nvl(PJI_UTILS.GET_PARAMETER('CONFIG_UTIL_FLAG'), 'N');

    if (l_settings_profit_flag = 'Y' and l_settings_cost_flag = 'N') then
      update PJI_SYSTEM_SETTINGS
      set    CONFIG_COST_FLAG = 'Y';
      l_settings_cost_flag := 'Y';
    end if;

    if (l_settings_cost_flag = 'Y' and l_settings_proj_perf_flag = 'N') then
      update PJI_SYSTEM_SETTINGS
      set    CONFIG_PROJ_PERF_FLAG = 'Y';
      l_settings_proj_perf_flag := 'Y';
    end if;

    if ((l_settings_proj_perf_flag = 'N' and l_params_proj_perf_flag = 'Y') or
        (l_settings_cost_flag      = 'N' and l_params_cost_flag   = 'Y') or
        (l_settings_profit_flag    = 'N' and l_params_profit_flag = 'Y') or
        (l_settings_util_flag      = 'N' and l_params_util_flag   = 'Y')) then
      PJI_UTILS.WRITE2LOG('Error:  ' || l_setup_error);
      commit;
      dbms_standard.raise_application_error(-20040, l_setup_error);
    end if;

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process, 'TRANSITION', 'N');
    l_transition_flag := 'N';

    if (l_settings_proj_perf_flag = 'Y' and l_params_proj_perf_flag = 'N') then
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
        (g_process, 'TRANSITION', 'Y');
      l_transition_flag := 'Y';
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
        (g_process, 'CONFIG_PROJ_PERF_FLAG', 'Y');
    end if;

    if (l_settings_cost_flag = 'Y' and l_params_cost_flag = 'N') then
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
        (g_process, 'TRANSITION', 'Y');
      l_transition_flag := 'Y';
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
        (g_process, 'CONFIG_COST_FLAG', 'Y');
    end if;

    if (l_settings_profit_flag = 'Y' and l_params_profit_flag = 'N') then
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
        (g_process, 'TRANSITION', 'Y');
      l_transition_flag := 'Y';
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
        (g_process, 'CONFIG_PROFIT_FLAG', 'Y');
    end if;

    if (l_settings_util_flag = 'Y' and l_params_util_flag = 'N') then
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
        (g_process, 'TRANSITION', 'Y');
      l_transition_flag := 'Y';
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
        (g_process, 'CONFIG_UTIL_FLAG', 'Y');
    end if;

    select count(*)
    into   l_row_count
    from   PJI_FM_DNGL_FIN;

    select count(*) + l_row_count
    into   l_row_count
    from   PJI_FM_DNGL_ACT;

    if (l_row_count > 0 and l_transition_flag = 'Y') then

      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
        (g_process, 'TRANSITION', 'N');
      l_transition_flag := 'N';

      PJI_UTILS.WRITE2LOG('Error:  ' || l_dangling_error);
      PJI_UTILS.WRITE2OUT('Error:  ' || l_dangling_error);

    end if;

    if (l_transition_flag = 'Y') then

      insert into PJI_SYSTEM_CONFIG_HIST
      (
        REQUEST_ID,
        USER_NAME,
        PROCESS_NAME,
        RUN_TYPE,
        PARAMETERS,
        CONFIG_PROJ_PERF_FLAG,
        CONFIG_COST_FLAG,
        CONFIG_PROFIT_FLAG,
        CONFIG_UTIL_FLAG,
        START_DATE,
        END_DATE,
        COMPLETION_TEXT
      )
      select
        FND_GLOBAL.CONC_REQUEST_ID                       REQUEST_ID,
        substr(FND_GLOBAL.USER_NAME, 1, 10)              USER_NAME,
        g_process || 1                                   PROCESS_NAME,
        'TRANSITION'                                     RUN_TYPE,
        null                                             PARAMETERS,
        l_settings_proj_perf_flag                        CONFIG_PROJ_PERF_FLAG,
        l_settings_cost_flag                             CONFIG_COST_FLAG,
        l_settings_profit_flag                           CONFIG_PROFIT_FLAG,
        l_settings_util_flag                             CONFIG_UTIL_FLAG,
        sysdate                                          START_DATE,
        null                                             END_DATE,
        null                                             COMPLETION_TEXT
      from
        dual;

    end if;

  end RUN_SETUP;


  -- -----------------------------------------------------
  -- function PRIOR_ITERATION_SUCCESSFUL
  -- -----------------------------------------------------
  function PRIOR_ITERATION_SUCCESSFUL return boolean is

    l_parallel_processes number;
    l_count              number;

    l_sum_fm_running     varchar2(255) := 'The process has failed due to a previously running process.';

  begin

    l_count := 0;

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, g_process) <>
        FND_GLOBAL.CONC_REQUEST_ID and
        (PJI_PROCESS_UTIL.REQUEST_STATUS
         (
           'RUNNING',
           PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, g_process),
           g_full_disp_name
         ) or
         PJI_PROCESS_UTIL.REQUEST_STATUS
         (
           'RUNNING',
           PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, g_process),
           g_incr_disp_name
         ) or
         PJI_PROCESS_UTIL.REQUEST_STATUS
         (
           'RUNNING',
           PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, g_process),
           g_prtl_disp_name
         ))) then
      l_count := l_count + 1;
    end if;

    l_parallel_processes :=
    PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'PARALLEL_PROCESSES');

    if (l_parallel_processes is not null) then

      for x in 2 .. l_parallel_processes loop
        if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
            (
              g_process || to_char(x),
              g_process || to_char(x)
            ) < FND_GLOBAL.CONC_REQUEST_ID and
            PJI_FM_SUM_EXTR.WORKER_STATUS(x, 'RUNNING')) then
          l_count := l_count + 1;
        end if;
      end loop;

    end if;

    if (l_count > 0) then
      pji_utils.write2log('Error: FM summarization is already running.');
      commit;
      dbms_standard.raise_application_error(-20010, l_sum_fm_running);
    end if;

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'PROCESS_RUNNING',
                                           'Y');

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           g_process,
                                           FND_GLOBAL.CONC_REQUEST_ID);

    commit;

    -- The API call below checks if the table PJI_SYSTEM_PRC_STATUS
    -- has any records for this process.  If any records exist, the prior
    -- process did not complete successfully.

    return PJI_PROCESS_UTIL.PRIOR_ITERATION_SUCCESSFUL(g_process);

  end PRIOR_ITERATION_SUCCESSFUL;


  -- -----------------------------------------------------
  -- procedure INIT_PROCESS
  -- -----------------------------------------------------
  procedure INIT_PROCESS
  (
    p_run_mode            in         varchar2,
    p_extract_commitments in         varchar2 default 'N',
    p_organization_id     in         number   default null,
    p_include_sub_org     in         varchar2 default null,
    p_operating_unit      in         number   default null,
    p_from_project        in         varchar2 default null,
    p_to_project          in         varchar2 default null,
    p_plan_type           in         varchar2 default null,
    p_cmt_operating_unit  in         number   default null,
    p_cmt_from_project    in         varchar2 default null,
    p_cmt_to_project      in         varchar2 default null
  ) is

    l_project_count     number;
    l_global_start_date date;
    l_transition_flag   varchar2(1);
    l_errbuf            varchar2(255);
    l_retcode           varchar2(255);
    l_extraction_type   varchar2(30);
    p_from_project_id        number  ;
    p_to_project_id          number  ;
    l_count 		     number  ;
    l_from_project_num       pa_projects_all.segment1%TYPE;
    l_to_project_num         pa_projects_all.segment1%TYPE;
    l_invalid_parameter        varchar2(255) := 'The specified range of projects is invalid, To Project should be greater than From Project ';
    l_no_work 		       varchar2(255) := 'There is no project to process for the specified parameters';

  begin

    /*  bug#4109940 Changes starts here */
    IF p_extract_commitments = 'Y' and (p_cmt_from_project > p_cmt_to_project) then
      dbms_standard.raise_application_error(-20092, l_invalid_parameter);
    END IF;
    IF p_from_project > p_to_project then
       dbms_standard.raise_application_error(-20092, l_invalid_parameter);
    END IF;
    IF  p_from_project is not null
    or  p_to_project is not null then
	select min(segment1) ,max(segment1)
	into l_from_project_num, l_to_project_num
	from pa_projects_all
	where segment1 between nvl(p_from_project,segment1) and nvl(p_to_project,segment1);

     END if;
        /* Get the Project Ids ,this is required to keep the impact minimum , these values will be updated in pji_system_parameters Table */
     IF l_from_project_num is not null THEN
	select project_id
	into p_from_project_id
	from pa_projects_all
	where segment1= l_from_project_num;
     else
	p_from_project_id:=-1;
      END IF;
      IF l_to_project_num is not null THEN
	select project_id
	into p_to_project_id
	from pa_projects_all
	where segment1= l_to_project_num;
      else
	p_to_project_id:=-1;
      END IF;

    select count(*)
    into   l_project_count
    from   PJI_PROJ_EXTR_STATUS
    where  ROWNUM = 1;

    if (p_run_mode = 'F') then
      l_extraction_type := 'FULL';
    elsif (p_run_mode = 'I') then
      l_extraction_type := 'INCREMENTAL';
    elsif (p_run_mode = 'P') then
      l_extraction_type := 'PARTIAL';
    end if;

    l_transition_flag :=
          PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_FM_SUM_MAIN.g_process,
                                                 'TRANSITION');

    if (l_project_count = 0 or l_transition_flag = 'Y') then
      l_extraction_type := 'FULL';
    elsif (l_project_count > 0 and l_extraction_type = 'FULL') then
      l_extraction_type := 'INCREMENTAL';
    end if;

    PJI_PROCESS_UTIL.ADD_STEPS(g_process || 1, 'PJI_EXTR', l_extraction_type);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(g_process || 1, 'PJI_FM_SUM_MAIN.INIT_PROCESS;')) then
      rollback;
      return;
    end if;

    PJI_UTILS.SET_PARAMETER('EXTRACTION_TYPE', l_extraction_type);

    insert into PJI_SYSTEM_CONFIG_HIST
    (
      REQUEST_ID,
      USER_NAME,
      PROCESS_NAME,
      RUN_TYPE,
      PARAMETERS,
      CONFIG_PROJ_PERF_FLAG,
      CONFIG_COST_FLAG,
      CONFIG_PROFIT_FLAG,
      CONFIG_UTIL_FLAG,
      START_DATE,
      END_DATE,
      COMPLETION_TEXT
    )
    select
      FND_GLOBAL.CONC_REQUEST_ID                         REQUEST_ID,
      substr(FND_GLOBAL.USER_NAME, 1, 10)                USER_NAME,
      g_process || 1                                     PROCESS_NAME,
      l_extraction_type                                  RUN_TYPE,
      substr(p_run_mode || ', ' ||
             p_extract_commitments || ', ' ||
             to_char(p_organization_id) || ', ' ||
             to_char(p_include_sub_org) || ', ' ||
             to_char(p_operating_unit) || ', ' ||
             p_from_project || ', ' ||
             p_to_project || ', ' ||
             p_plan_type, 1, 240)                        PARAMETERS,
      null                                               CONFIG_PROJ_PERF_FLAG,
      null                                               CONFIG_COST_FLAG,
      null                                               CONFIG_PROFIT_FLAG,
      null                                               CONFIG_UTIL_FLAG,
      sysdate                                            START_DATE,
      null                                               END_DATE,
      null                                               COMPLETION_TEXT
    from
      dual;

    PJI_UTILS.SET_PARAMETER('DANGLING_ROWS_EXIST', 'P');

    -- Update list of organizations to be extracted in case
    -- users defined new organizations.
    -- List of organizations is stored in table
    -- PJI_PROJ_EXTR_STATUS
    --  at the end of processing a batch the summarization
    --  process should update the pji_project_status field. This
    --  should be done by the last extraction process for the
    --  batch.

    PJI_EXTRACTION_UTIL.UPDATE_EXTR_SCOPE;

    l_global_start_date := PJI_UTILS.GET_EXTRACTION_START_DATE;

    insert into PJI_FM_PROJ_BATCH_MAP
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_TYPE_CLASS,
      PJI_PROJECT_STATUS,
      ROW_COUNT,
      START_DATE,
      END_DATE,
      PROJECT_ORG_ID,
      NEW_PROJECT_ORGANIZATION_ID,
      NEW_CLOSED_DATE,
      EXTRACTION_TYPE,
      EXTRACTION_STATUS,
      COST_BUDGET_C_VERSION,
      COST_BUDGET_CO_VERSION,
      REVENUE_BUDGET_C_VERSION,
      REVENUE_BUDGET_CO_VERSION,
      COST_FORECAST_C_VERSION,
      REVENUE_FORECAST_C_VERSION,
      PROJECT_ORGANIZATION_ID,
      OLD_CLOSED_DATE,
      PLAN_EXTRACTION_STATUS,
      BACKLOG_EXTRACTION_STATUS
    )
    select /*+ ordered full(extr) use_hash(extr)
                       full(prj)  use_hash(prj)  parallel(prj) */
      1                                  WORKER_ID,
      extr.PROJECT_ID,
      extr.PROJECT_TYPE_CLASS,
      'O',
      0,
      null,
      null,
      prj.ORG_ID,
      prj.CARRYING_OUT_ORGANIZATION_ID,
      prj.CLOSED_DATE,
      decode(nvl(extr.EXTRACTION_STATUS, 'Z'), 'Z', 'F',
             decode(l_extraction_type, 'FULL', 'F',
                                       'INCREMENTAL', 'I',
                                       'PARTIAL', 'P')),
      extr.EXTRACTION_STATUS,
      decode(l_extraction_type, 'PARTIAL', -1,
             nvl(extr.COST_BUDGET_C_VERSION,-2)),
      decode(l_extraction_type, 'PARTIAL', -1,
             nvl(extr.COST_BUDGET_CO_VERSION,-2)),
      decode(l_extraction_type, 'PARTIAL', -1,
             nvl(extr.REVENUE_BUDGET_C_VERSION,-2)),
      decode(l_extraction_type, 'PARTIAL', -1,
             nvl(extr.REVENUE_BUDGET_CO_VERSION,-2)),
      decode(l_extraction_type, 'PARTIAL', -1,
             nvl(extr.COST_FORECAST_C_VERSION,-2)),
      decode(l_extraction_type, 'PARTIAL', -1,
             nvl(extr.REVENUE_FORECAST_C_VERSION,-2)),
      prj.CARRYING_OUT_ORGANIZATION_ID,
      prj.CLOSED_DATE,
      'N',
      'N'
    from
      PJI_PROJ_EXTR_STATUS extr,
      PA_PROJECTS_ALL prj
    where
      nvl(extr.PURGE_STATUS,'X') not in ('PARTIALLY_PURGED',
                                         'PURGED',
                                         'PENDING_PURGE') and
      extr.project_id = prj.project_id and
      nvl(prj.org_id,-99) = nvl(p_operating_unit,nvl(prj.org_id,-99)) and
      (l_extraction_type = 'FULL' or
       (prj.segment1 between nvl(p_from_project,prj.segment1) and
                             nvl(p_to_project,prj.segment1)
       )) and
      not (l_extraction_type = 'PARTIAL' and
           extr.EXTRACTION_STATUS is null);

	-- identify all projects in the same program groups as the above projects

	  if ( l_extraction_type='PARTIAL' ) then -- Bug#5099574  starts

    insert into PJI_FM_PROJ_BATCH_MAP
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_TYPE_CLASS,
      PJI_PROJECT_STATUS,
      ROW_COUNT,
      START_DATE,
      END_DATE,
      PROJECT_ORG_ID,
      NEW_PROJECT_ORGANIZATION_ID,
      NEW_CLOSED_DATE,
      EXTRACTION_TYPE,
      EXTRACTION_STATUS,
      COST_BUDGET_C_VERSION,
      COST_BUDGET_CO_VERSION,
      REVENUE_BUDGET_C_VERSION,
      REVENUE_BUDGET_CO_VERSION,
      COST_FORECAST_C_VERSION,
      REVENUE_FORECAST_C_VERSION,
      PROJECT_ORGANIZATION_ID,
      OLD_CLOSED_DATE,
      PLAN_EXTRACTION_STATUS,
      BACKLOG_EXTRACTION_STATUS
    )
    select /*+ ordered full(extr) use_hash(extr)
                       full(prj)  use_hash(prj)  parallel(prj) */
      1                                  WORKER_ID,
      status.PROJECT_ID,
      status.PROJECT_TYPE_CLASS,
      'O',
      0,
      null,
      null,
      prj.ORG_ID,
      prj.CARRYING_OUT_ORGANIZATION_ID,
      prj.CLOSED_DATE,
      decode(nvl(status.EXTRACTION_STATUS, 'Z'), 'Z', 'F',
             decode(l_extraction_type, 'FULL', 'F',
                                       'INCREMENTAL', 'I',
                                       'PARTIAL', 'P')),
      status.EXTRACTION_STATUS,
      decode(l_extraction_type, 'PARTIAL', -1,
             nvl(status.COST_BUDGET_C_VERSION,-2)),
      decode(l_extraction_type, 'PARTIAL', -1,
             nvl(status.COST_BUDGET_CO_VERSION,-2)),
      decode(l_extraction_type, 'PARTIAL', -1,
             nvl(status.REVENUE_BUDGET_C_VERSION,-2)),
      decode(l_extraction_type, 'PARTIAL', -1,
             nvl(status.REVENUE_BUDGET_CO_VERSION,-2)),
      decode(l_extraction_type, 'PARTIAL', -1,
             nvl(status.COST_FORECAST_C_VERSION,-2)),
      decode(l_extraction_type, 'PARTIAL', -1,
             nvl(status.REVENUE_FORECAST_C_VERSION,-2)),
      prj.CARRYING_OUT_ORGANIZATION_ID,
      prj.CLOSED_DATE,
      'N',
      'N'
    from
			PJI_PROJ_EXTR_STATUS status,
			PA_PROJECTS_ALL          prj,
			(
			  select /*+ ordered */
			    distinct
			    emt.PROJECT_ID
			  from
			    PA_PROJECT_STATUSES stat,
			    PA_PROJECTS_ALL     prj,
			    PA_XBS_DENORM       prg,
			    PA_PROJ_ELEMENTS    emt
			  where
			    stat.STATUS_TYPE                =  'PROJECT'                and
			    stat.PROJECT_SYSTEM_STATUS_CODE not in ('CLOSED',
								    'PENDING_CLOSE',
								    'PENDING_PURGE',
								    'PURGED')           and
			    prj.PROJECT_STATUS_CODE         =  stat.PROJECT_STATUS_CODE and
			    prg.STRUCT_TYPE                 =  'PRG'                    and
			    prg.SUP_PROJECT_ID              =  prj.PROJECT_ID           and
			    emt.PROJ_ELEMENT_ID             =  prg.SUB_EMT_ID
			) active_projects,
			PJI_FM_PROJ_BATCH_MAP existing_projects
		      where
			(
			(l_extraction_type = 'PARTIAL' and
			  status.EXTRACTION_STATUS Is not null)
			  ) and
			status.PROJECT_ID = prj.PROJECT_ID and
			status.PROJECT_ID in
			(		select
						ver1.PROJECT_ID
					      from
						PA_PROJ_ELEMENT_VERSIONS ver1
					      where
						ver1.OBJECT_TYPE = 'PA_STRUCTURES' and
						ver1.PRG_GROUP in
							(select
							   ver2.PRG_GROUP
							 from
							   PJI_FM_PROJ_BATCH_MAP map,
							   PA_PROJ_ELEMENT_VERSIONS ver2
							 where
							   ver2.PROJECT_ID = map.PROJECT_ID and
							   ver2.PRG_GROUP is not null
							   )
					      union
					      select /*+ index (prg, PJI_XBS_DENORM_N3) */
						prg.SUP_PROJECT_ID PROJECT_ID
					      from
						PJI_XBS_DENORM prg
					      where
						prg.STRUCT_TYPE = 'PRG' and
						prg.SUB_LEVEL = prg.SUP_LEVEL and
						prg.PRG_GROUP in
							(select /*+ ordered */
							   ver2.PRG_GROUP
							 from
							   PJI_FM_PROJ_BATCH_MAP map,
							   PA_PROJ_ELEMENT_VERSIONS ver2
							 where
							   ver2.PROJECT_ID = map.PROJECT_ID and
							   ver2.PRG_GROUP is not null
							   )
						   )
		   and
		status.PROJECT_ID = existing_projects.PROJECT_ID (+) and
		existing_projects.PROJECT_ID is null and
		status.PROJECT_ID = active_projects.PROJECT_ID (+);
		end if;

	select
        count(*)
      into
        l_count
      from
        PJI_FM_PROJ_BATCH_MAP ;

       if (l_count = 0) then

         rollback;
	 dbms_standard.raise_application_error(-20041, l_no_work);

       end if;
        -- Bug#5099574  ends



    update PJI_PROJ_EXTR_STATUS
    set    EXTRACTION_STATUS = 'X',
           LAST_UPDATE_DATE = sysdate
    where  l_extraction_type <> 'PARTIAL' and
           EXTRACTION_STATUS is null and
           PROJECT_ID in (select PROJECT_ID
                          from   PJI_FM_PROJ_BATCH_MAP
                          where  WORKER_ID = 1);

    -- Set global process parameters
    --
    -- PROCESS_RUNNING: Y = Yes
    --                  N = No
    --                  F = Failed
    --                  A = Aborted
    --
    -- batch statuses:  R = Ready
    --                  P = Processing
    --                  C = Completed
    --                  F = Failed
    --
    -- dangling flag:   R = Rate is missing
    --                  T = TIME_ID is outside a calendar range
    --                  null = not dangling

    if (PJI_UTILS.GET_PARAMETER('GLOBAL_START_DATE') is not null and
        trunc(l_global_start_date, 'J') <>
        trunc(to_date(PJI_UTILS.GET_PARAMETER('GLOBAL_START_DATE'),
                      g_date_mask), 'J')) then
      pji_utils.write2log('WARNING: Global start date has changed.');
    end if;

    PJI_UTILS.SET_PARAMETER('GLOBAL_START_DATE',
                            to_char
                            (
                              l_global_start_date,
                              g_date_mask
                            ));

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'EXTRACT_COMMITMENTS',
                                           p_extract_commitments);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'ORGANIZATION_ID',
                                           p_organization_id);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'INCLUDE_SUB_ORG',
                                           p_include_sub_org);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'PROJECT_OPERATING_UNIT',
                                           p_operating_unit);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'FROM_PROJECT',
                                           p_from_project);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'FROM_PROJECT_ID',
                                           p_from_project_id);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'TO_PROJECT',
                                           p_to_project);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'TO_PROJECT_ID',
                                           p_to_project_id);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'PLAN_TYPE_ID',
                                           p_plan_type);

    if (p_cmt_operating_unit is not null or
        p_cmt_from_project is not null or
        p_cmt_to_project is not null) then

      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                             'PROJECT_OPERATING_UNIT',
                                             p_cmt_operating_unit);

      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                             'FROM_PROJECT',
                                             p_cmt_from_project);

      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                             'TO_PROJECT',
                                             p_cmt_to_project);

    end if;

    g_parallel_processes := PJI_EXTRACTION_UTIL.GET_PARALLEL_PROCESSES;

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'PARALLEL_PROCESSES',
                                           g_parallel_processes);

    if (PJI_UTILS.GET_SETUP_PARAMETER('PA_PERIOD_FLAG') = 'N') then
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                             'PA_CALENDAR_FLAG',
                                             'N');
    else
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                             'PA_CALENDAR_FLAG',
                                              'Y');
    end if;

    if (PJI_UTILS.GET_SETUP_PARAMETER('GL_PERIOD_FLAG') = 'N') then
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                             'GL_CALENDAR_FLAG',
                                             'N');
    else
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                             'GL_CALENDAR_FLAG',
                                             'Y');
    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(g_process || 1, 'PJI_FM_SUM_MAIN.INIT_PROCESS;');

    commit;

  end INIT_PROCESS;


  -- -----------------------------------------------------
  -- function PROCESS_RUNNING
  -- -----------------------------------------------------
  function PROCESS_RUNNING (p_wait in varchar2) return boolean is

    l_parallel_processes number;
    l_batch_count        number;
    l_from_process       number;

  begin

    -- if process is determined to be over or any worker has failed then signal
    -- that workers should stop processing and wrapup

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'PROCESS_RUNNING') <> 'Y' and
        PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'PROCESS_RUNNING') <> 'N') then
      return false;
    end if;

    l_parallel_processes :=
    PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'PARALLEL_PROCESSES');

    if (p_wait = 'WAIT') then
      l_from_process := 2;
    elsif (p_wait = 'DO_NOT_WAIT') then
      l_from_process := 1;
    end if;

    l_batch_count := 0;

    for x in l_from_process .. l_parallel_processes loop
      if (not PJI_FM_SUM_EXTR.WORKER_STATUS(x, 'OKAY')) then
        l_batch_count := l_batch_count + 1;
      end if;
    end loop;

    if (l_batch_count > 0) then
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                             'PROCESS_RUNNING',
                                             'F');
      commit;
      return false;
    end if;

    if (p_wait = 'DO_NOT_WAIT') then
      return true;
    end if;

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'PROCESS_RUNNING',
                                           'N');
    commit;

    -- check that all workers have stopped

    for x in l_from_process .. l_parallel_processes loop
      PJI_FM_SUM_EXTR.WAIT_FOR_WORKER(x);
    end loop;

    return false;

  end PROCESS_RUNNING;


  -- -----------------------------------------------------
  -- procedure RUN_PROCESS
  -- -----------------------------------------------------
  procedure RUN_PROCESS is

    l_parallel_processes number;

  begin

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(g_process || 1, 'PJI_FM_SUM_MAIN.RUN_PROCESS;')) then
      return;
    end if;

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'PROCESS_RUNNING',
                                           'Y');

    -- ensure that worker and helpers can run concurrently
    FND_PROFILE.PUT('CONC_SINGLE_THREAD', 'N');
    commit;

    l_parallel_processes :=
    PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'PARALLEL_PROCESSES');

    -- start extraction helpers

    for x in 2 .. l_parallel_processes loop
      PJI_FM_SUM_EXTR.START_HELPER(x);
    end loop;

    -- run extraction worker

    PJI_FM_SUM_EXTR.WORKER(1);

    -- sleep until process is complete

    while PROCESS_RUNNING('WAIT') loop
      PJI_PROCESS_UTIL.SLEEP(g_process_delay);
    end loop;

    -- process finished

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'PROCESS_RUNNING') = 'N') then

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(g_process || 1, 'PJI_FM_SUM_MAIN.RUN_PROCESS;');

      commit;

    end if;

  end RUN_PROCESS;


  -- -----------------------------------------------------
  -- function MY_PAD
  -- -----------------------------------------------------
  function MY_PAD (p_length in number,
                   p_char   in varchar2) return varchar2 is

    l_stmt varchar2(2000) := '';

  begin

    for x in 1 .. p_length loop

      l_stmt := l_stmt || p_char;

    end loop;

    return l_stmt;

  end MY_PAD;


  -- -----------------------------------------------------
  -- function GET_MISSING_TIME_HEADER
  -- -----------------------------------------------------
  function GET_MISSING_TIME_HEADER return varchar2 is

    l_stmt1     varchar2(2000) := '';
    l_stmt2     varchar2(2000) := '';
    l_temp      varchar2(1000) := '';
    l_min_width number         := 20;
    l_newline   varchar2(10)   := '
';

  begin

    fnd_message.set_name('PJI', 'PJI_MISSING_CAL_HEADER');
    l_stmt1 := l_newline       ||
               l_newline       ||
               fnd_message.get ||
               l_newline       ||
               l_newline;

    fnd_message.set_name('PJI', 'PJI_CALENDAR_TEXT');
    l_temp  := fnd_message.get;
    l_stmt2 := my_pad(greatest(length(l_temp), l_min_width), '-') || ' ';
    l_temp  := l_temp || my_pad(greatest(l_min_width - length(l_temp), 0), ' ');
    l_stmt1 := l_stmt1 || l_temp || ' ';

    fnd_message.set_name('PJI', 'PJI_PERIOD_TYPE_TEXT');
    l_temp  := fnd_message.get;
    l_stmt2 := l_stmt2 || my_pad(greatest(length(l_temp), l_min_width), '-') || ' ';
    l_temp  := l_temp || my_pad(greatest(l_min_width - length(l_temp), 0), ' ');
    l_stmt1 := l_stmt1 || l_temp || ' ';

    fnd_message.set_name('PJI', 'PJI_FROM_DATE_TEXT');
    l_temp  := fnd_message.get;
    l_stmt2 := l_stmt2 || my_pad(greatest(length(l_temp), l_min_width), '-') || ' ';
    l_temp  := l_temp || my_pad(greatest(l_min_width - length(l_temp), 0), ' ');
    l_stmt1 := l_stmt1 || l_temp || ' ';

    fnd_message.set_name('PJI', 'PJI_TO_DATE_TEXT');
    l_temp  := fnd_message.get;
    l_stmt2 := l_stmt2 || my_pad(greatest(length(l_temp), l_min_width), '-');
    l_temp  := l_temp || my_pad(greatest(l_min_width - length(l_temp), 0), ' ');
    l_stmt1 := l_stmt1 || l_temp;

    return l_stmt1 || l_newline || l_stmt2 || l_newline;

  end GET_MISSING_TIME_HEADER;


  -- -----------------------------------------------------
  -- function GET_MISSING_TIME_TEXT
  -- -----------------------------------------------------
  function GET_MISSING_TIME_TEXT (p_calendar_name in varchar2,
                                  p_period_type   in varchar2,
                                  p_from_date     in date,
                                  p_to_date       in date) return varchar2 is

    l_stmt      varchar2(2000) := '';
    l_temp      varchar2(1000) := '';
    l_min_width number         := 20;
    l_newline   varchar2(10)   := '
';

  begin

    l_stmt := p_calendar_name
           || my_pad(greatest(l_min_width - length(p_calendar_name), 0), ' ')
           || ' ';

    l_stmt := l_stmt
           || p_period_type
           || my_pad(greatest(l_min_width - length(p_period_type), 0), ' ')
           || ' ';

    l_stmt := l_stmt
           || to_char(p_from_date, g_date_mask)
           || my_pad(greatest(l_min_width - length(to_char(p_from_date,
                                                           g_date_mask)), 0),
                     ' ')
           || ' ';

    l_stmt := l_stmt
           || to_char(p_to_date, g_date_mask)
           || my_pad(greatest(l_min_width - length(to_char(p_to_date,
                                                           g_date_mask)), 0),
                     ' ')
           || l_newline;

    return l_stmt;

  end GET_MISSING_TIME_TEXT;


  -- -----------------------------------------------------
  -- procedure DANGLING_REPORT
  -- -----------------------------------------------------
  procedure DANGLING_REPORT is

    cursor missing_rates (p_g1_currency_code in varchar2,
                          p_g2_currency_code in varchar2) is
    select
      distinct
      to_date(to_char(tmp2.TIME_ID), 'J') FROM_DATE,
      info.PF_CURRENCY_CODE,
      tmp2.G_CURRENCY_CODE,
      tmp2.RATE_TYPE
    from
      PJI_ORG_EXTR_INFO info,
      (
      select
        distinct
        tmp2.PROJECT_ORG_ID                                     ORG_ID,
        decode(invert.INVERT_ID,
               'RECVR_GL1', decode(tmp2.DANGLING_RECVR_GL_RATE_FLAG,
                                   'E', to_number(to_char(to_date('1999/01/01',
                                                                 'YYYY/MM/DD'),
                                                          'J')),
                                   tmp2.RECVR_GL_TIME_ID),
               'RECVR_GL2', decode(tmp2.DANGLING_RECVR_GL_RATE2_FLAG,
                                   'E', to_number(to_char(to_date('1999/01/01',
                                                                 'YYYY/MM/DD'),
                                                          'J')),
                                   tmp2.RECVR_GL_TIME_ID),
               'RECVR_PA1', decode(tmp2.DANGLING_RECVR_PA_RATE_FLAG,
                                   'E', to_number(to_char(to_date('1999/01/01',
                                                                 'YYYY/MM/DD'),
                                                          'J')),
                                   tmp2.RECVR_PA_TIME_ID),
               'RECVR_PA2', decode(tmp2.DANGLING_RECVR_PA_RATE2_FLAG,
                                   'E', to_number(to_char(to_date('1999/01/01',
                                                                 'YYYY/MM/DD'),
                                                          'J')),
                                   tmp2.RECVR_PA_TIME_ID))      TIME_ID,
        decode(invert.INVERT_ID,
               'RECVR_GL1', decode(tmp2.DANGLING_RECVR_GL_RATE_FLAG,
                                   'E', 'Y',
                                   tmp2.DANGLING_RECVR_GL_RATE_FLAG),
               'RECVR_GL2', decode(tmp2.DANGLING_RECVR_GL_RATE2_FLAG,
                                   'E', 'Y',
                                   tmp2.DANGLING_RECVR_GL_RATE2_FLAG),
               'RECVR_PA1', decode(tmp2.DANGLING_RECVR_PA_RATE_FLAG,
                                   'E', 'Y',
                                   tmp2.DANGLING_RECVR_PA_RATE_FLAG),
               'RECVR_PA2', decode(tmp2.DANGLING_RECVR_PA_RATE2_FLAG,
                                   'E', 'Y',
                                   tmp2.DANGLING_RECVR_PA_RATE2_FLAG))
                                                                DANGLING_FLAG,
        decode(invert.INVERT_ID,
               'RECVR_GL1', p_g1_currency_code,
               'RECVR_GL2', p_g2_currency_code,
               'RECVR_PA1', p_g1_currency_code,
               'RECVR_PA2', p_g2_currency_code)                G_CURRENCY_CODE,
        decode(invert.INVERT_ID,
               'RECVR_GL1', PJI_UTILS.GET_RATE_TYPE,
               'RECVR_GL2', FND_PROFILE.VALUE('BIS_SECONDARY_RATE_TYPE'),
               'RECVR_PA1', PJI_UTILS.GET_RATE_TYPE,
               'RECVR_PA2', FND_PROFILE.VALUE('BIS_SECONDARY_RATE_TYPE'))
                                                                RATE_TYPE
      from
        PJI_FM_DNGL_FIN tmp2,
        (
        select 'RECVR_GL1' INVERT_ID from dual union all
        select 'RECVR_GL2' INVERT_ID from dual union all
        select 'RECVR_PA1' INVERT_ID from dual union all
        select 'RECVR_PA2' INVERT_ID from dual
        ) invert
      where
        tmp2.WORKER_ID = 0
      union
      select
        distinct
        tmp2.PROJECT_ORG_ID                                     ORG_ID,
        decode(invert.INVERT_ID,
               'GL1', decode(tmp2.DANGLING_GL_RATE_FLAG,
                             'E', to_number(to_char(to_date('1999/01/01',
                                                            'YYYY/MM/DD'),
                                                    'J')),
                             tmp2.GL_TIME_ID),
               'GL2', decode(tmp2.DANGLING_GL_RATE2_FLAG,
                             'E', to_number(to_char(to_date('1999/01/01',
                                                            'YYYY/MM/DD'),
                                                    'J')),
                             tmp2.GL_TIME_ID),
               'PA1', decode(tmp2.DANGLING_PA_RATE_FLAG,
                             'E', to_number(to_char(to_date('1999/01/01',
                                                            'YYYY/MM/DD'),
                                                    'J')),
                             tmp2.PA_TIME_ID),
               'PA2', decode(tmp2.DANGLING_PA_RATE2_FLAG,
                             'E', to_number(to_char(to_date('1999/01/01',
                                                            'YYYY/MM/DD'),
                                                    'J')),
                             tmp2.PA_TIME_ID))                  TIME_ID,
        decode(invert.INVERT_ID,
               'GL1', decode(tmp2.DANGLING_GL_RATE_FLAG,
                             'E', 'Y', tmp2.DANGLING_GL_RATE_FLAG),
               'GL2', decode(tmp2.DANGLING_GL_RATE2_FLAG,
                             'E', 'Y', tmp2.DANGLING_GL_RATE2_FLAG),
               'PA1', decode(tmp2.DANGLING_PA_RATE_FLAG,
                             'E', 'Y', tmp2.DANGLING_PA_RATE_FLAG),
               'PA2', decode(tmp2.DANGLING_PA_RATE2_FLAG,
                             'E', 'Y', tmp2.DANGLING_PA_RATE2_FLAG))
                                                                DANGLING_FLAG,
        decode(invert.INVERT_ID,
               'GL1', p_g1_currency_code,
               'GL2', p_g2_currency_code,
               'PA1', p_g1_currency_code,
               'PA2', p_g2_currency_code)                      G_CURRENCY_CODE,
        decode(invert.INVERT_ID,
               'GL1', PJI_UTILS.GET_RATE_TYPE,
               'GL2', FND_PROFILE.VALUE('BIS_SECONDARY_RATE_TYPE'),
               'PA1', PJI_UTILS.GET_RATE_TYPE,
               'PA2', FND_PROFILE.VALUE('BIS_SECONDARY_RATE_TYPE'))
                                                                RATE_TYPE
      from
        PJI_FM_DNGL_ACT tmp2,
        (
        select 'GL1' INVERT_ID from dual union all
        select 'GL2' INVERT_ID from dual union all
        select 'PA1' INVERT_ID from dual union all
        select 'PA2' INVERT_ID from dual
        ) invert
      where
        tmp2.WORKER_ID = 0
      ) tmp2
    where
      tmp2.DANGLING_FLAG = 'Y' and
      tmp2.ORG_ID = info.ORG_ID;

    cursor missing_time (p_calendar_id in number) is
    select
      name.NAME                                         CALENDAR_NAME,
      pt.USER_PERIOD_TYPE,
      tmp2.CALENDAR_MIN_DATE,
      tmp2.CALENDAR_MAX_DATE,
      min(tmp2.FROM_DATE)                               FROM_DATE,
      max(tmp2.TO_DATE)                                 TO_DATE
    from
      (
      select
        decode(tmp2.CALENDAR_TYPE,
               'E', p_calendar_id,
               'G', info.GL_CALENDAR_ID,
               'P', info.PA_CALENDAR_ID)                CALENDAR_ID,
        to_date(decode(tmp2.CALENDAR_TYPE,
                       'E', info.EN_CALENDAR_MIN_DATE,
                       'G', info.GL_CALENDAR_MIN_DATE,
                       'P', info.PA_CALENDAR_MIN_DATE), 'J') CALENDAR_MIN_DATE,
        to_date(decode(tmp2.CALENDAR_TYPE,
                       'E', info.EN_CALENDAR_MAX_DATE,
                       'G', info.GL_CALENDAR_MAX_DATE,
                       'P', info.PA_CALENDAR_MAX_DATE), 'J') CALENDAR_MAX_DATE,
        to_date(to_char(min(tmp2.FROM_TIME_ID)), 'J')   FROM_DATE,
        to_date(to_char(max(tmp2.TO_TIME_ID)), 'J')     TO_DATE
      from
        PJI_ORG_EXTR_INFO info,
        (
        select
          distinct
          decode(invert.INVERT_ID,
                 'PRVDR_EN', tmp2.EXPENDITURE_ORG_ID,
                 'RECVR_EN', tmp2.PROJECT_ORG_ID,
                 'EXP_EN',   tmp2.EXPENDITURE_ORG_ID,
                 'PRVDR_GL', tmp2.EXPENDITURE_ORG_ID,
                 'RECVR_GL', tmp2.PROJECT_ORG_ID,
                 'EXP_GL',   tmp2.EXPENDITURE_ORG_ID,
                 'PRVDR_PA', tmp2.EXPENDITURE_ORG_ID,
                 'RECVR_PA', tmp2.PROJECT_ORG_ID,
                 'EXP_PA',   tmp2.EXPENDITURE_ORG_ID)        ORG_ID,
          decode(invert.INVERT_ID,
                 'PRVDR_EN', 'E',
                 'RECVR_EN', 'E',
                 'EXP_EN',   'E',
                 'PRVDR_GL', 'G',
                 'RECVR_GL', 'G',
                 'EXP_GL',   'G',
                 'PRVDR_PA', 'P',
                 'RECVR_PA', 'P',
                 'EXP_PA',   'P')                            CALENDAR_TYPE,
          decode(invert.INVERT_ID,
                 'PRVDR_EN', tmp2.PRVDR_GL_TIME_ID,
                 'RECVR_EN', tmp2.RECVR_GL_TIME_ID,
                 'EXP_EN',   tmp2.EXPENDITURE_ITEM_TIME_ID,
                 'PRVDR_GL', tmp2.PRVDR_GL_TIME_ID,
                 'RECVR_GL', tmp2.RECVR_GL_TIME_ID,
                 'EXP_GL',   tmp2.EXPENDITURE_ITEM_TIME_ID,
                 'PRVDR_PA', tmp2.PRVDR_PA_TIME_ID,
                 'RECVR_PA', tmp2.RECVR_PA_TIME_ID,
                 'EXP_PA',   tmp2.EXPENDITURE_ITEM_TIME_ID)  FROM_TIME_ID,
          decode(invert.INVERT_ID,
                 'PRVDR_EN', tmp2.PRVDR_GL_TIME_ID,
                 'RECVR_EN', tmp2.RECVR_GL_TIME_ID,
                 'EXP_EN',   tmp2.EXPENDITURE_ITEM_TIME_ID,
                 'PRVDR_GL', tmp2.PRVDR_GL_TIME_ID,
                 'RECVR_GL', tmp2.RECVR_GL_TIME_ID,
                 'EXP_GL',   tmp2.EXPENDITURE_ITEM_TIME_ID,
                 'PRVDR_PA', tmp2.PRVDR_PA_TIME_ID,
                 'RECVR_PA', tmp2.RECVR_PA_TIME_ID,
                 'EXP_PA',   tmp2.EXPENDITURE_ITEM_TIME_ID)  TO_TIME_ID,
          decode(invert.INVERT_ID,
                 'PRVDR_EN', tmp2.DANGLING_PRVDR_EN_TIME_FLAG,
                 'RECVR_EN', tmp2.DANGLING_RECVR_EN_TIME_FLAG,
                 'EXP_EN',   tmp2.DANGLING_EXP_EN_TIME_FLAG,
                 'PRVDR_GL', tmp2.DANGLING_PRVDR_GL_TIME_FLAG,
                 'RECVR_GL', tmp2.DANGLING_RECVR_GL_TIME_FLAG,
                 'EXP_GL',   tmp2.DANGLING_EXP_GL_TIME_FLAG,
                 'PRVDR_PA', tmp2.DANGLING_PRVDR_PA_TIME_FLAG,
                 'RECVR_PA', tmp2.DANGLING_RECVR_PA_TIME_FLAG,
                 'EXP_PA',   tmp2.DANGLING_EXP_PA_TIME_FLAG) DANGLING_FLAG
        from
          PJI_FM_DNGL_FIN tmp2,
          (
          select 'PRVDR_EN' INVERT_ID from dual union all
          select 'RECVR_EN' INVERT_ID from dual union all
          select 'EXP_EN'   INVERT_ID from dual union all
          select 'PRVDR_GL' INVERT_ID from dual union all
          select 'RECVR_GL' INVERT_ID from dual union all
          select 'EXP_GL'   INVERT_ID from dual union all
          select 'PRVDR_PA' INVERT_ID from dual union all
          select 'RECVR_PA' INVERT_ID from dual union all
          select 'EXP_PA'   INVERT_ID from dual
          ) invert
        where
          tmp2.WORKER_ID = 0
        union
        select
          distinct
          tmp2.PROJECT_ORG_ID ORG_ID,
          decode(invert.INVERT_ID,
                 'EN', 'E',
                 'GL', 'G',
                 'PA', 'P') CALENDAR_TYPE,
          decode(invert.INVERT_ID,
                 'EN', tmp2.GL_TIME_ID,
                 'GL', tmp2.GL_TIME_ID,
                 'PA', tmp2.PA_TIME_ID) FROM_TIME_ID,
          decode(invert.INVERT_ID,
                 'EN', tmp2.GL_TIME_ID,
                 'GL', tmp2.GL_TIME_ID,
                 'PA', tmp2.PA_TIME_ID) TO_TIME_ID,
          decode(invert.INVERT_ID,
                 'EN', tmp2.DANGLING_EN_TIME_FLAG,
                 'GL', tmp2.DANGLING_GL_TIME_FLAG,
                 'PA', tmp2.DANGLING_PA_TIME_FLAG) DANGLING_FLAG
        from
          PJI_FM_DNGL_ACT tmp2,
          (
          select 'EN' INVERT_ID from dual union all
          select 'GL' INVERT_ID from dual union all
          select 'PA' INVERT_ID from dual
          ) invert
        where
          tmp2.WORKER_ID = 0
        ) tmp2
      where
        tmp2.DANGLING_FLAG = 'Y' and
        tmp2.ORG_ID = info.ORG_ID
      group by
        decode(tmp2.CALENDAR_TYPE,
               'E', p_calendar_id,
               'G', info.GL_CALENDAR_ID,
               'P', info.PA_CALENDAR_ID),
        decode(tmp2.CALENDAR_TYPE,
               'E', info.EN_CALENDAR_MIN_DATE,
               'G', info.GL_CALENDAR_MIN_DATE,
               'P', info.PA_CALENDAR_MIN_DATE),
        decode(tmp2.CALENDAR_TYPE,
               'E', info.EN_CALENDAR_MAX_DATE,
               'G', info.GL_CALENDAR_MAX_DATE,
               'P', info.PA_CALENDAR_MAX_DATE)
      ) tmp2,
      FII_TIME_CAL_NAME name,
      GL_PERIOD_TYPES pt
    where
      name.CALENDAR_ID = tmp2.CALENDAR_ID and
      pt.PERIOD_TYPE = name.PERIOD_TYPE
    group by
      name.NAME,
      pt.USER_PERIOD_TYPE,
      tmp2.CALENDAR_MIN_DATE,
      tmp2.CALENDAR_MAX_DATE;

    l_calendar_id      varchar2(255);
    l_header_flag      varchar2(1);
    l_newline          varchar2(10) := '
';

  begin

    PJI_UTILS.SET_PARAMETER('DANGLING_ROWS_EXIST', 'N');

    --
    -- Report dangling rates
    --

    l_header_flag := 'Y';

    for c in missing_rates(PJI_UTILS.GET_GLOBAL_PRIMARY_CURRENCY,
                           PJI_UTILS.GET_GLOBAL_SECONDARY_CURRENCY) loop

      if (l_header_flag = 'Y') then

        PJI_UTILS.SET_PARAMETER('DANGLING_ROWS_EXIST', 'Y');

        pji_utils.write2out(l_newline || PJI_UTILS.getMissingRateHeader);

        l_header_flag := 'N';

      end if;

      pji_utils.write2out(
        PJI_UTILS.getMissingRateText(c.RATE_TYPE,
                                     c.PF_CURRENCY_CODE,
                                     c.G_CURRENCY_CODE,
                                     c.FROM_DATE,
                                     to_char(c.FROM_DATE, 'YYYY/MM/DD')) ||
        l_newline);

    end loop;

    --
    -- Report time dimension gaps
    --

    select CALENDAR_ID
    into   l_calendar_id
    from   FII_TIME_CAL_NAME
    where  PERIOD_SET_NAME = PJI_UTILS.GET_PERIOD_SET_NAME and
           PERIOD_TYPE = PJI_UTILS.GET_PERIOD_TYPE;

    l_header_flag := 'Y';

    for c in missing_time(l_calendar_id) loop

      if (l_header_flag = 'Y') then

        PJI_UTILS.SET_PARAMETER('DANGLING_ROWS_EXIST', 'Y');

        pji_utils.write2out(PJI_FM_SUM_MAIN.GET_MISSING_TIME_HEADER);
        l_header_flag := 'N';
      end if;

      if (c.FROM_DATE < c.CALENDAR_MIN_DATE and
          c.TO_DATE > c.CALENDAR_MAX_DATE) then

        pji_utils.write2out(
          PJI_FM_SUM_MAIN.GET_MISSING_TIME_TEXT(c.CALENDAR_NAME,
                                                c.USER_PERIOD_TYPE,
                                                c.FROM_DATE,
                                                c.CALENDAR_MIN_DATE));

        pji_utils.write2out(
          PJI_FM_SUM_MAIN.GET_MISSING_TIME_TEXT(c.CALENDAR_NAME,
                                                c.USER_PERIOD_TYPE,
                                                c.CALENDAR_MAX_DATE,
                                                c.TO_DATE));

      elsif (c.TO_DATE > c.CALENDAR_MAX_DATE) then

        pji_utils.write2out(
          PJI_FM_SUM_MAIN.GET_MISSING_TIME_TEXT(c.CALENDAR_NAME,
                                                c.USER_PERIOD_TYPE,
                                                c.CALENDAR_MAX_DATE,
                                                c.TO_DATE));

      elsif (c.FROM_DATE < c.CALENDAR_MIN_DATE) then

        pji_utils.write2out(
          PJI_FM_SUM_MAIN.GET_MISSING_TIME_TEXT(c.CALENDAR_NAME,
                                                c.USER_PERIOD_TYPE,
                                                c.FROM_DATE,
                                                c.CALENDAR_MIN_DATE));

      end if;

    end loop;

    pji_utils.write2out(l_newline);

    commit;

  end DANGLING_REPORT;


  -- -----------------------------------------------------
  -- procedure WRAPUP_SETUP
  -- -----------------------------------------------------
  procedure WRAPUP_SETUP is

    l_params_proj_perf_flag varchar2(1);
    l_params_cost_flag      varchar2(1);
    l_params_profit_flag    varchar2(1);
    l_params_util_flag      varchar2(1);

  begin

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process,
                                               'TRANSITION') = 'Y') then

      l_params_proj_perf_flag :=
     nvl(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process,
                                                'CONFIG_PROJ_PERF_FLAG'), 'N');
      l_params_cost_flag :=
     nvl(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process,
                                                'CONFIG_COST_FLAG'), 'N');
      l_params_profit_flag :=
     nvl(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process,
                                                'CONFIG_PROFIT_FLAG'), 'N');
      l_params_util_flag :=
     nvl(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process,
                                                'CONFIG_UTIL_FLAG'), 'N');

      if (l_params_proj_perf_flag = 'Y') then
        PJI_UTILS.SET_PARAMETER('CONFIG_PROJ_PERF_FLAG', 'Y');
      end if;

      if (l_params_cost_flag = 'Y') then
        PJI_UTILS.SET_PARAMETER('CONFIG_COST_FLAG', 'Y');
      end if;

      if (l_params_profit_flag = 'Y') then
        PJI_UTILS.SET_PARAMETER('CONFIG_PROFIT_FLAG', 'Y');
      end if;

      if (l_params_util_flag = 'Y') then
        PJI_UTILS.SET_PARAMETER('CONFIG_UTIL_FLAG', 'Y');
      end if;

      update PJI_SYSTEM_CONFIG_HIST
      set    END_DATE = sysdate,
             COMPLETION_TEXT = 'Normal completion'
      where  PROCESS_NAME = g_process || 1 and
             RUN_TYPE = 'TRANSITION' and
             END_DATE is null;

    end if;

  end WRAPUP_SETUP;


  -- -----------------------------------------------------
  -- procedure WRAPUP_PROCESS
  -- -----------------------------------------------------
  procedure WRAPUP_PROCESS is

    l_parallel_processes number;
    l_request_id         number;
    l_batch_count        number;
    l_schema             varchar2(30);

  begin

    PJI_FM_DEBUG.CLEANUP_HOOK(g_process);

    -- check that all workers have stopped

    l_parallel_processes :=
    PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'PARALLEL_PROCESSES');

    for x in 2 .. l_parallel_processes loop
      PJI_FM_SUM_EXTR.WAIT_FOR_WORKER(x);
    end loop;

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'PROCESS_RUNNING') = 'A') then
      fnd_message.set_name('PJI', 'PJI_SUM_ABORT');
      dbms_standard.raise_application_error(-20000, fnd_message.get);
    elsif (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'PROCESS_RUNNING') = 'F') then
      fnd_message.set_name('PJI', 'PJI_SUM_FAIL');
      dbms_standard.raise_application_error(-20000, fnd_message.get);
    end if;

    DANGLING_REPORT;

    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FM_PROJ_BATCH_MAP',
                                     'NORMAL',
                                     null);

    WRAPUP_SETUP;

    PJI_PROCESS_UTIL.WRAPUP_PROCESS(g_process || 1);
    PJI_PROCESS_UTIL.WRAPUP_PROCESS(g_process);

    update PJI_SYSTEM_CONFIG_HIST
    set    END_DATE = sysdate,
           COMPLETION_TEXT = 'Normal completion'
    where  PROCESS_NAME = g_process || 1 and
           END_DATE is null;

    -- update default report as-of date

    PJI_UTILS.SET_PARAMETER('LAST_FM_EXTR_DATE',
                            to_char(sysdate, PJI_FM_SUM_MAIN.g_date_mask));

    PJI_UTILS.SET_PARAMETER('LAST_EXTR_DATE',
                            to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'));

    commit;

  end WRAPUP_PROCESS;


  -- -----------------------------------------------------
  -- procedure WRAPUP_FAILURE
  -- -----------------------------------------------------
  procedure WRAPUP_FAILURE is

    l_sqlerrm varchar2(240);

  begin

    rollback;

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(PJI_FM_SUM_MAIN.g_process,
                                           'PROCESS_RUNNING',
                                           'F');

    commit;

    pji_utils.write2log(sqlerrm, true, 0);

    l_sqlerrm := substr(sqlerrm, 1, 240);

    update PJI_SYSTEM_CONFIG_HIST
    set    END_DATE = sysdate,
           COMPLETION_TEXT = l_sqlerrm
    where  PROCESS_NAME = g_process || 1 and
           END_DATE is null;

    commit;

  end WRAPUP_FAILURE;


  -- -----------------------------------------------------
  -- procedure SUMMARIZE
  --
  -- This the the main procedure, it is invoked from
  -- a concurrent program.
  -- -----------------------------------------------------
  procedure SUMMARIZE
  (
    errbuf                out nocopy varchar2,
    retcode               out nocopy varchar2,
    p_run_mode            in         varchar2,
    p_extract_commitments in         varchar2 default 'N',
    p_organization_id     in         number   default null,
    p_include_sub_org     in         varchar2 default null,
    p_operating_unit      in         number   default null,
    p_from_project 	  in	     varchar2 default null,
    p_to_project	  in 	     varchar2 default null,
    p_plan_type           in         varchar2 default null,
    p_cmt_operating_unit  in         number   default null,
    p_cmt_from_project    in         varchar2 default null,
    p_cmt_to_project      in         varchar2 default null
  ) is

    l_pji_not_licensed exception;
    pragma exception_init(l_pji_not_licensed, -20020);
    l_prior_iteration_successful boolean;
    l_transition_flag varchar2(1);

    l_sum_running varchar2(255) := 'The process has failed due to a previously running process.';

    l_sum_fail varchar2(255) := 'The process has failed because process ''Update Project Intelligence Data'' is not complete.';
  l_sum_refresh_fail varchar2(255) := 'The process has failed because process ''Update Project Intelligence Data'' has not yet been run.';
    l_rm_fm_running varchar2(255) := 'The process has failed because a Partial Refresh process is not complete.';

  begin
  pa_debug.set_process('PLSQL');  /* start	4893117*/
  IF p_run_mode IN ('I','F') then
      pa_debug.log_message('=======Concurrent Program Parameters Start =======', 1);
      pa_debug.log_message('Argument => Extract Commitments Data ['||p_extract_commitments||']', 1);
      pa_debug.log_message('=======Concurrent Program Parameters End =======', 1);
  ELSIF p_run_mode in ('P') then
      pa_debug.log_message('=======Concurrent Program Parameters Start =======', 1);
      pa_debug.log_message('Argument => Operating Unit ['||p_operating_unit||']', 1);
      pa_debug.log_message('Argument => From Project Number ['||p_from_project||']', 1);
      pa_debug.log_message('Argument => To Project Number ['||p_to_project||']', 1);
      pa_debug.log_message('=======Concurrent Program Parameters End =======', 1);
  ELSIF p_run_mode in ('R') then
      pa_debug.log_message('=======Concurrent Program Parameters Start =======', 1);
      pa_debug.log_message('Argument => From Project Number ['||p_from_project||']', 1);
      pa_debug.log_message('Argument => To Project Number ['||p_to_project||']', 1);
      pa_debug.log_message('=======Concurrent Program Parameters End =======', 1);
   END IF;   /*	end 4893117*/

    PJI_FM_DEBUG.CONC_REQUEST_HOOK(g_process);

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, g_process) <>
        FND_GLOBAL.CONC_REQUEST_ID and
        (PJI_PROCESS_UTIL.REQUEST_STATUS
         (
           'RUNNING',
           PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, g_process),
           g_full_disp_name
         ) or
         PJI_PROCESS_UTIL.REQUEST_STATUS
         (
           'RUNNING',
           PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, g_process),
           g_incr_disp_name
         ))) then
      pji_utils.write2log('Error: Summarization is already running.');
      commit;
      dbms_standard.raise_application_error(-20010, l_sum_running);
    end if;

    commit;
    execute immediate 'alter session enable parallel query';
    execute immediate 'alter session enable parallel dml';

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           g_process,
                                           FND_GLOBAL.CONC_REQUEST_ID);

    commit;

    PJI_PROCESS_UTIL.REFRESH_STEP_TABLE;

    -- determine if a transitional configuration is needed
    RUN_SETUP;

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
          (g_process, 'TRANSITION')             = 'N' and
        (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
           (g_process, 'CONFIG_PROJ_PERF_FLAG') = 'Y' or
         PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
           (g_process, 'CONFIG_COST_FLAG')      = 'Y' or
         PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
           (g_process, 'CONFIG_PROFIT_FLAG')    = 'Y' or
         PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
           (g_process, 'CONFIG_UTIL_FLAG')      = 'Y')) then
      retcode := 1;
    else
      retcode := 0;
    end if;

    l_prior_iteration_successful := PRIOR_ITERATION_SUCCESSFUL;

    begin

      INIT_PROCESS(p_run_mode,
                   p_extract_commitments,
                   p_organization_id,
                   p_include_sub_org,
		   p_operating_unit,
                   p_from_project,
                   p_to_project,
                   p_plan_type,
                   p_cmt_operating_unit,
                   p_cmt_from_project,
                   p_cmt_to_project);

      RUN_PROCESS;
      WRAPUP_PROCESS;

      if (PJI_UTILS.GET_PARAMETER('DANGLING_ROWS_EXIST') = 'Y') then
        retcode := 1;
      else
        retcode := 0;
      end if;

      commit;
      execute immediate 'alter session disable parallel dml';

      exception when others then

        WRAPUP_FAILURE;
        execute immediate 'alter session disable parallel dml';
        retcode := 2;
        errbuf := sqlerrm;
        raise;

    end;

    exception when others then
        rollback;
      IF SQLCODE = -20041 then
        retcode := 0;
      ELSE
        retcode := 2;
        errbuf := sqlerrm;
        -- raise; Commented for bug 6015217
      END IF;

  end SUMMARIZE;

end PJI_FM_SUM_MAIN;

/
