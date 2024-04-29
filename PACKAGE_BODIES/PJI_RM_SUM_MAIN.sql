--------------------------------------------------------
--  DDL for Package Body PJI_RM_SUM_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_RM_SUM_MAIN" as
  /* $Header: PJISR01B.pls 120.15 2006/03/23 04:02:24 appldev noship $ */

  -- The main procedure is procedure SUMMARIZE, it is invoked from a concurrent
  -- program.
  --
  -- Data extraction consists of several steps that are coded as individual
  -- program units. Procedure RUN_PROCESS invokes processing steps in the
  -- appropriate order. Before we call RUN_PROCESS we initialize the process,
  -- this is done in INIT_PROCESS. After process completes successfully we
  -- reset process status in WRAPUP_PROCESS. These are three main program
  -- units called from PUSH.
  --
  -- Each processing step listed in RUN_PROCESS  is implemented as separate
  -- database transaction. Extraction process supports error recovery, i.e.
  -- if the process fails it will continue from the same step next time it
  -- runs. In order to support error recovery we use tables
  -- PJI_SYSTEM_PROCESS_STATUS and PJI_SYSTEM_PARAMETERS that store current
  -- process status and process parameters such as batch id being processed.
  -- The package accesses status tables through API package PJI_PROCESS_UTIL.
  -- Scope of data extraction is defined by table PJI_ORG_EXTR_STATUS that
  -- contains list of organizations for which we extract data.
  -- We have to use persistent table, i.e. we cannot define scope dynamically
  -- each time we run extraction because Table PJI_ORG_EXTR_STATUS may be
  -- updated by multiple Project Intelligence data extraction processes running
  -- in parallel.
  -- In order to isolate the process from changes made to the table by
  -- other extraction programs we create a snapshot of this table in
  -- PJI_RM_ORG_BATCH_MAP. PJI_RM_ORG_BATCH_MAP is also used to partition
  -- processing scope into batches.
  --
  -- Processing itself consists of two major stages. First, we process orgs
  -- for which we never extracted fi information before. One of reasons to
  -- have this stage is to support initial data load. These orgs have
  -- STATUS in the scope table set to NULL.
  -- The second stage is to process orgs that have been
  -- extracted before. For these orgs STATUS is set to 'X'.

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
    from   PJI_RM_DNGL_RES;

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

    l_sum_fm_fail        varchar2(255) := 'The process has failed because process ''Update Project Financial Data'' failed.';

    l_sum_fm_running     varchar2(255) := 'The process has failed because process ''Update Project Financial Data'' is currently running';

    l_sum_rm_running     varchar2(255) := 'The process has failed because process ''Update Project Resource Management Data'' is currently running.';

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
            PJI_RM_SUM_EXTR.WORKER_STATUS(x, 'RUNNING')) then
          l_count := l_count + 1;
        end if;
      end loop;

    end if;

    if (l_count > 0) then
      pji_utils.write2log('Error: RM summarization is already running.');
      commit;
      dbms_standard.raise_application_error(-20010, l_sum_rm_running);
    end if;

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'PROCESS_RUNNING',
                                           'Y');

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           g_process,
                                           FND_GLOBAL.CONC_REQUEST_ID);

    commit;

    -- API call below check if table PJI_SYSTEM_PRC_STATUS has any
    -- records for this process. If records exist, this means that prior
    -- process did not complete successfully.

    return PJI_PROCESS_UTIL.PRIOR_ITERATION_SUCCESSFUL(g_process);

  end PRIOR_ITERATION_SUCCESSFUL;


  -- -----------------------------------------------------
  -- procedure INIT_PROCESS
  -- -----------------------------------------------------
  procedure INIT_PROCESS
  (
    p_run_mode        in         varchar2,
    p_prtl_schedule   in         varchar2 default null, -- RM
    p_organization_id in         number   default null, -- RM parameter
    p_include_sub_org in         varchar2 default 'N',  -- RM parameter
    p_prtl_financial  in         varchar2 default null, -- FM
    p_operating_unit  in         number   default null, -- FM parameter
    p_from_project    in         varchar2 default null, -- FM parameter
    p_to_project      in         varchar2 default null, -- FM parameter
    p_plan_type       in         varchar2 default null  -- FM parameter
  ) is

    l_process                  varchar2(30);

    l_org_count          number;
    l_organization_id    number;
    l_hierarchical       varchar2(1);
    l_global_start_date  date;
    l_extraction_type    varchar2(30);
    l_transition_flag    varchar2(1);
    l_errbuf             varchar2(2000);
    l_retcode            varchar2(2000);

    l_project_count      number;
    p_from_project_id    number;
    p_to_project_id      number;
    l_count              number;
    l_from_project_num   pa_projects_all.segment1%TYPE;
    l_to_project_num     pa_projects_all.segment1%TYPE;
    l_invalid_parameter  varchar2(255) := 'The specified range of projects is invalid, To Project should be greater than From Project ';
    l_no_work            varchar2(255) := 'There is no project to process for the specified parameters';

  begin

    l_process := PJI_RM_SUM_MAIN.g_process;

    if (p_run_mode = 'F') then
      l_extraction_type := 'FULL';
    elsif (p_run_mode = 'I') then
      l_extraction_type := 'INCREMENTAL';
    elsif (p_run_mode = 'P') then
      l_extraction_type := 'PARTIAL';
    end if;

    select count(*)
    into   l_org_count
    from   PJI_ORG_EXTR_STATUS
    where  ROWNUM = 1;

    select count(*)
    into   l_project_count
    from   PJI_PJI_PROJ_EXTR_STATUS
    where  ROWNUM = 1;

    if (l_org_count = 0 and l_project_count = 0) then
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,l_retcode,'All','?','Y');
    end if;

if (upper(nvl(FND_PROFILE.VALUE('PJI_USE_DBI_RSG'), 'N')) <> 'Y' ) then -- bug#5075209

    PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                                           l_retcode,
                                           'PJI_TIME_PA_RPT_STR_MV',
                                           'C',
                                           'N');
end if;

    l_transition_flag :=
          PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_RM_SUM_MAIN.g_process,
                                                 'TRANSITION');

    if ((l_org_count = 0 and
         l_project_count = 0) or l_transition_flag = 'Y') then
      l_extraction_type := 'FULL';
    elsif ((l_org_count > 0 or
            l_project_count > 0) and l_extraction_type = 'FULL') then
      l_extraction_type := 'INCREMENTAL';
    end if;

    PJI_PROCESS_UTIL.ADD_STEPS(g_process || 1, 'PJI_PJI', l_extraction_type);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(g_process || 1, 'PJI_RM_SUM_MAIN.INIT_PROCESS;')) then
      rollback;
      return;
    end if;

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                           'EXTRACTION_TYPE',
                                           l_extraction_type);

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
             p_prtl_schedule || ', ' ||
             to_char(p_organization_id) || ', ' ||
             p_include_sub_org || ', ' ||
             p_prtl_financial || ', ' ||
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

    -- ------------------------------------------------------------------------
    -- Initialize Resource Management portion of stage 2 PJI summarization.
    -- ------------------------------------------------------------------------

    PJI_UTILS.SET_PARAMETER('DANGLING_PJI_ROWS_EXIST', 'P');

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'ORGANIZATION_ID',
                                           p_organization_id);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'HIERARCHIAL',
                                           p_include_sub_org);

    -- Update list of organizations to be extracted in case
    -- users defined new organizations.
    -- List of organizations is stored in table
    -- PJI_ORG_EXTR_STATUS

    insert into PJI_ORG_EXTR_STATUS
    (
      ORGANIZATION_ID,
      STATUS,
      CREATION_DATE,
      LAST_UPDATE_DATE
    )
    select
      org.ORGANIZATION_ID,
      null,
      sysdate,
      sysdate
    from
      (
      select /*+ ordered full(stat) use_hash(stat) */
        distinct
        org.ORGANIZATION_ID
      from
        PA_ALL_ORGANIZATIONS org,
        PJI_ORG_EXTR_STATUS stat
      where
        org.ORGANIZATION_ID = stat.ORGANIZATION_ID (+) and
        stat.ORGANIZATION_ID is null
      ) org
    where
      exists (select /*+ index_ffs(fid, PA_FORECAST_ITEM_DETAILS_N2)
                         parallel_index(fid, PA_FORECAST_ITEM_DETAILS_N2) */ 1
              from   PA_FORECAST_ITEM_DETAILS fid
              where  fid.EXPENDITURE_ORGANIZATION_ID > 0 and
                     fid.EXPENDITURE_ORGANIZATION_ID = org.ORGANIZATION_ID);

    if (l_extraction_type = 'INCREMENTAL' ) then

       insert into pji_rm_org_batch_map (
           worker_id,
           organization_id,
           start_date,
           end_date,
           extraction_type,
           row_count)
        select
          1,
          sts.ORGANIZATION_ID,
          g_min_date,
          g_max_date,
          case when sts.STATUS is null
               then 'F'
               else 'I'
               end,
          null
        from
          PJI_ORG_EXTR_STATUS sts;

    elsif (l_extraction_type = 'PARTIAL') then

        if (p_include_sub_org = 'Y') then

          insert into PJI_RM_ORG_BATCH_MAP
          (
            WORKER_ID,
            ORGANIZATION_ID,
            START_DATE,
            END_DATE,
            EXTRACTION_TYPE,
            ROW_COUNT
          )
          select
            1,
            sts.ORGANIZATION_ID,
            g_min_date,
            g_max_date,
            'P',
            null
          from
            PJI_ORG_EXTR_STATUS sts,
            PJI_ORG_DENORM orgs
          where
            p_prtl_schedule      = 'Y'                      and
            orgs.ORGANIZATION_ID = p_organization_id        and
            sts.ORGANIZATION_ID  = orgs.SUB_ORGANIZATION_ID and
            sts.STATUS           = 'X';

        else

          insert into PJI_RM_ORG_BATCH_MAP
          (
            WORKER_ID,
            ORGANIZATION_ID,
            START_DATE,
            END_DATE,
            EXTRACTION_TYPE,
            ROW_COUNT
          )
          select
            1,
            sts.ORGANIZATION_ID,
            g_min_date,
            g_max_date,
            'P',
            null
          from
            PJI_ORG_EXTR_STATUS sts
          where
            p_prtl_schedule     = 'Y' and
            sts.ORGANIZATION_ID = p_organization_id and
            sts.STATUS          = 'X';

        end if;

    elsif (l_extraction_type = 'FULL') then

      insert into PJI_RM_ORG_BATCH_MAP
      (
        WORKER_ID,
        ORGANIZATION_ID,
        EXTRACTION_TYPE,
        ROW_COUNT,
        START_DATE,
        END_DATE
      )
      select
        1,
        extr.ORGANIZATION_ID,
        'F',
        null,
        g_min_date,
        g_max_date
      from
        PJI_ORG_EXTR_STATUS extr
      where
        extr.STATUS is null;

    end if;

    update PJI_ORG_EXTR_STATUS
    set    STATUS = 'X'
    where  l_extraction_type in ('FULL', 'INCREMENTAL') and
           ORGANIZATION_ID IN (select map.ORGANIZATION_ID
                               from   PJI_RM_ORG_BATCH_MAP map
                               where  map.WORKER_ID = 1) and
           STATUS is null;

    l_global_start_date := PJI_UTILS.GET_EXTRACTION_START_DATE;

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

    if (PJI_UTILS.GET_SETUP_PARAMETER('PA_PERIOD_FLAG') = 'Y' ) then
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,'PA_CALENDAR_FLAG','Y');
    else
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,'PA_CALENDAR_FLAG','N');
    end if;

    if (PJI_UTILS.GET_SETUP_PARAMETER('GL_PERIOD_FLAG') = 'Y' ) then
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,'GL_CALENDAR_FLAG','Y');
    else
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,'GL_CALENDAR_FLAG','N');
    end if;

    --Enable menu structure for Utilization
    PA_PJI_MENU_UTIL.ENABLE_MENUS;

    -- ------------------------------------------------------------------------
    -- Initialize Financial Management portion of stage 2 PJI summarization.
    -- ------------------------------------------------------------------------

    IF p_from_project > p_to_project then
       dbms_standard.raise_application_error(-20092, l_invalid_parameter);
    END IF;

    IF  (p_from_project is not null or
         p_to_project is not null) then

      select min(segment1),
             max(segment1)
      into   l_from_project_num,
             l_to_project_num
      from   pa_projects_all
      where  segment1 between nvl(p_from_project,segment1) and
             nvl(p_to_project,segment1);

    END if;

    IF (l_from_project_num is not null) THEN

      select project_id
      into   p_from_project_id
      from   pa_projects_all
      where  segment1= l_from_project_num;

    else

      p_from_project_id:=-1;

    END IF;

    IF l_to_project_num is not null THEN

      select project_id
      into   p_to_project_id
      from   pa_projects_all
      where  segment1= l_to_project_num;

    else

      p_to_project_id:=-1;

    END IF;

    PJI_PJI_EXTRACTION_UTILS.UPDATE_PJI_EXTR_SCOPE;

    l_global_start_date := PJI_UTILS.GET_EXTRACTION_START_DATE;

    insert into PJI_PJI_PROJ_BATCH_MAP
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
      decode(extr.EXTRACTION_STATUS, 'F', 'F',
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
      decode(extr.EXTRACTION_STATUS, 'I', extr.PROJECT_ORGANIZATION_ID,
             prj.CARRYING_OUT_ORGANIZATION_ID),
      decode(extr.EXTRACTION_STATUS, 'I', extr.CLOSED_DATE, prj.CLOSED_DATE),
      'N',
      'N'
    from
      PJI_PJI_PROJ_EXTR_STATUS extr,
      PA_PROJECTS_ALL prj
    where
      extr.project_id = prj.project_id                                and
      nvl(prj.org_id,-99) = nvl(p_operating_unit,nvl(prj.org_id,-99)) and
      (l_extraction_type = 'FULL' or
       (prj.segment1 between nvl(p_from_project,prj.segment1) and
                             nvl(p_to_project,prj.segment1)))         and
      not (l_extraction_type = 'PARTIAL' and
           extr.EXTRACTION_STATUS = 'F')                              and
      not (l_extraction_type = 'PARTIAL' and
           p_prtl_financial = 'N');

    if (SQL%ROWCOUNT = 0 and p_prtl_financial = 'Y') then
      rollback;
      dbms_standard.raise_application_error(-20041, l_no_work);
    end if;

    update PJI_PJI_PROJ_EXTR_STATUS
    set    EXTRACTION_STATUS = 'I',
           LAST_UPDATE_DATE = sysdate
    where  l_extraction_type in ('FULL', 'INCREMENTAL') and
           EXTRACTION_STATUS = 'F' and
           PROJECT_ID in (select PROJECT_ID
                          from   PJI_PJI_PROJ_BATCH_MAP
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

    PJI_FM_PLAN_EXTR.INIT_GLOBAL_PARAMETERS;

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                                 'PROJECT_OPERATING_UNIT',
              p_operating_unit);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'FROM_PROJECT_ID',
                                           p_from_project_id);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'TO_PROJECT_ID',
                                           p_to_project_id);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'FROM_PROJECT',
                                           p_from_project);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'TO_PROJECT',
                                           p_to_project);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'PLAN_TYPE_ID',
                                           p_plan_type);

    g_parallel_processes := PJI_EXTRACTION_UTIL.GET_PARALLEL_PROCESSES;

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                           'PARALLEL_PROCESSES',
                                           least(g_parallel_processes,
                                                 g_parallel_limit));

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(g_process || 1, 'PJI_RM_SUM_MAIN.INIT_PROCESS;');

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
      if (not PJI_RM_SUM_EXTR.WORKER_STATUS(x, 'OKAY')) then
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

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process, 'PROCESS_RUNNING','N');
    commit;

    for x in l_from_process .. l_parallel_processes loop
      PJI_RM_SUM_EXTR.WAIT_FOR_WORKER(x);
    end loop;

    return false;

  end PROCESS_RUNNING;


  -- -----------------------------------------------------
  -- procedure RUN_PROCESS
  -- -----------------------------------------------------
  procedure RUN_PROCESS is

    l_parallel_processes number;
    l_seq number;

  begin

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(g_process || 1, 'PJI_RM_SUM_MAIN.RUN_PROCESS;')) then
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

    for x in 2..l_parallel_processes loop
      PJI_RM_SUM_EXTR.START_HELPER(x);
    end loop;

    -- run extraction worker

    PJI_RM_SUM_EXTR.WORKER(1);

    -- sleep until process is complete

    while (PROCESS_RUNNING('WAIT')) loop
      PJI_PROCESS_UTIL.SLEEP(g_process_delay);
    end loop;

    -- process finished

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'PROCESS_RUNNING') = 'N') then

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(g_process || 1, 'PJI_RM_SUM_MAIN.RUN_PROCESS;');

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

    fnd_message.set_name('PJI','PJI_MISSING_CAL_HEADER');
    l_stmt1 := l_newline       ||
               l_newline       ||
               fnd_message.get ||
               l_newline       ||
               l_newline;

    fnd_message.set_name('PJI','PJI_CALENDAR_TEXT');
    l_temp  := fnd_message.get;
    l_stmt2 := my_pad(greatest(length(l_temp), l_min_width), '-') || ' ';
    l_temp  := l_temp || my_pad(greatest(l_min_width - length(l_temp), 0), ' ');
    l_stmt1 := l_stmt1 || l_temp || ' ';

    fnd_message.set_name('PJI','PJI_PERIOD_TYPE_TEXT');
    l_temp  := fnd_message.get;
    l_stmt2 := l_stmt2 || my_pad(greatest(length(l_temp), l_min_width), '-') || ' ';
    l_temp  := l_temp || my_pad(greatest(l_min_width - length(l_temp), 0), ' ');
    l_stmt1 := l_stmt1 || l_temp || ' ';

    fnd_message.set_name('PJI','PJI_FROM_DATE_TEXT');
    l_temp  := fnd_message.get;
    l_stmt2 := l_stmt2 || my_pad(greatest(length(l_temp), l_min_width), '-') || ' ';
    l_temp  := l_temp || my_pad(greatest(l_min_width - length(l_temp), 0), ' ');
    l_stmt1 := l_stmt1 || l_temp || ' ';

    fnd_message.set_name('PJI','PJI_TO_DATE_TEXT');
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
      decode(sign(bitand(to_number(log.RECORD_TYPE_CODE), 3)),
             1, to_date('1999/01/01', 'YYYY/MM/DD'),
                log.FROM_DATE)                               FROM_DATE,
      info.PF_CURRENCY_CODE                                  PF_CURRENCY_CODE,
      decode(invert.INVERT_ID,
             'G1', p_g1_currency_code,
             'G2', p_g2_currency_code)                       G_CURRENCY_CODE,
      decode(invert.INVERT_ID,
             'G1', PJI_UTILS.GET_RATE_TYPE,
             'G2', FND_PROFILE.VALUE('BIS_SECONDARY_RATE_TYPE')) RATE_TYPE
    from
      PJI_FM_EXTR_PLN_LOG log,
      PJI_ORG_EXTR_INFO info,
      (
        select 'G1' INVERT_ID from dual union all
        select 'G2' INVERT_ID from dual
      ) invert
    where
      bitand(to_number(log.RECORD_TYPE_CODE), 15) > 0 and
      log.PROJECT_ORG_ID = info.ORG_ID;

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
        info.CALENDAR_ID,
        to_date(info.CALENDAR_MIN_DATE, 'J')          CALENDAR_MIN_DATE,
        to_date(info.CALENDAR_MAX_DATE, 'J')          CALENDAR_MAX_DATE,
        min(log.FROM_DATE)                            FROM_DATE,
        max(log.TO_DATE)                              TO_DATE
      from
        PJI_FM_EXTR_PLN_LOG log,
        (
        select
          distinct
          decode(invert.INVERT_ID,
                 'EN', p_calendar_id,
                 'GL', info.GL_CALENDAR_ID,
                 'PA', info.PA_CALENDAR_ID)             CALENDAR_ID,
          decode(invert.INVERT_ID,
                 'EN', info.EN_CALENDAR_MIN_DATE,
                 'GL', info.GL_CALENDAR_MIN_DATE,
                 'PA', info.PA_CALENDAR_MIN_DATE)       CALENDAR_MIN_DATE,
          decode(invert.INVERT_ID,
                 'EN', info.EN_CALENDAR_MAX_DATE,
                 'GL', info.GL_CALENDAR_MAX_DATE,
                 'PA', info.PA_CALENDAR_MAX_DATE)       CALENDAR_MAX_DATE
        from
          PJI_ORG_EXTR_INFO info,
          (
          select 'EN' INVERT_ID from dual union all
          select 'GL' INVERT_ID from dual union all
          select 'PA' INVERT_ID from dual
          ) invert
        where
          info.ORG_ID <> -1
        ) info
      where
        bitand(to_number(log.RECORD_TYPE_CODE), 16) > 0 and
        nvl(log.CALENDAR_ID, -1) = info.CALENDAR_ID
      group by
        info.CALENDAR_ID,
        to_date(info.CALENDAR_MIN_DATE, 'J'),
        to_date(info.CALENDAR_MAX_DATE, 'J')
      union all
      select
        tmp1.CALENDAR_ID,
        to_date(tmp1.CALENDAR_MIN_DATE, 'J')          CALENDAR_MIN_DATE,
        to_date(tmp1.CALENDAR_MAX_DATE, 'J')          CALENDAR_MAX_DATE,
        min(tmp1.FROM_DATE)                           FROM_DATE,
        max(tmp1.TO_DATE)                             TO_DATE
      from
        (
        select
          case when tmp1.CALENDAR_TYPE = 'C'
               then p_calendar_id
               when tmp1.CALENDAR_TYPE = 'P'
               then info.PA_CALENDAR_ID
               when tmp1.CALENDAR_TYPE = 'G'
               then info.GL_CALENDAR_ID
               end                                      CALENDAR_ID,
          case when tmp1.CALENDAR_TYPE = 'C'
               then info.EN_CALENDAR_MIN_DATE
               when tmp1.CALENDAR_TYPE = 'P'
               then info.PA_CALENDAR_MIN_DATE
               when tmp1.CALENDAR_TYPE = 'G'
               then info.GL_CALENDAR_MIN_DATE
               end                                      CALENDAR_MIN_DATE,
          case when tmp1.CALENDAR_TYPE = 'C'
               then info.EN_CALENDAR_MAX_DATE
               when tmp1.CALENDAR_TYPE = 'P'
               then info.PA_CALENDAR_MAX_DATE
               when tmp1.CALENDAR_TYPE = 'G'
               then info.GL_CALENDAR_MAX_DATE
               end                                      CALENDAR_MAX_DATE,
          to_date(to_char(min(tmp1.FROM_TIME_ID)), 'J') FROM_DATE,
          to_date(to_char(max(tmp1.TO_TIME_ID)), 'J')   TO_DATE
        from
          PJI_ORG_EXTR_INFO info,
          (
          select
            distinct
            tmp1.EXPENDITURE_ORG_ID ORG_ID,
            tmp1.CALENDAR_TYPE,
            tmp1.TIME_ID FROM_TIME_ID,
            tmp1.TIME_ID TO_TIME_ID,
            tmp1.DANGLING_FLAG
          from
            PJI_RM_DNGL_RES tmp1
          where
            tmp1.WORKER_ID = 0
          ) tmp1
        where
          tmp1.DANGLING_FLAG = 'T' and
          tmp1.ORG_ID = info.ORG_ID
        group by
          case when tmp1.CALENDAR_TYPE = 'C'
               then p_calendar_id
               when tmp1.CALENDAR_TYPE = 'P'
               then info.PA_CALENDAR_ID
               when tmp1.CALENDAR_TYPE = 'G'
               then info.GL_CALENDAR_ID
               end,
          case when tmp1.CALENDAR_TYPE = 'C'
               then info.EN_CALENDAR_MIN_DATE
               when tmp1.CALENDAR_TYPE = 'P'
               then info.PA_CALENDAR_MIN_DATE
               when tmp1.CALENDAR_TYPE = 'G'
               then info.GL_CALENDAR_MIN_DATE
               end,
          case when tmp1.CALENDAR_TYPE = 'C'
               then info.EN_CALENDAR_MAX_DATE
               when tmp1.CALENDAR_TYPE = 'P'
               then info.PA_CALENDAR_MAX_DATE
               when tmp1.CALENDAR_TYPE = 'G'
               then info.GL_CALENDAR_MAX_DATE
               end
        ) tmp1
      group by
        tmp1.CALENDAR_ID,
        to_date(tmp1.CALENDAR_MIN_DATE, 'J'),
        to_date(tmp1.CALENDAR_MAX_DATE, 'J')
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

    PJI_UTILS.SET_PARAMETER('DANGLING_PJI_ROWS_EXIST', 'N');

    --
    -- Report dangling rates
    --

    l_header_flag := 'Y';

    for c in missing_rates(PJI_UTILS.GET_GLOBAL_PRIMARY_CURRENCY,
                           PJI_UTILS.GET_GLOBAL_SECONDARY_CURRENCY) loop

      if (l_header_flag = 'Y') then

        PJI_UTILS.SET_PARAMETER('DANGLING_PJI_ROWS_EXIST', 'Y');

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

        PJI_UTILS.SET_PARAMETER('DANGLING_PJI_ROWS_EXIST', 'Y');

        pji_utils.write2out(PJI_RM_SUM_MAIN.GET_MISSING_TIME_HEADER);
        l_header_flag := 'N';
      end if;

      if (c.FROM_DATE < c.CALENDAR_MIN_DATE and
          c.TO_DATE > c.CALENDAR_MAX_DATE) then

        pji_utils.write2out(
          PJI_RM_SUM_MAIN.GET_MISSING_TIME_TEXT(c.CALENDAR_NAME,
                                                c.USER_PERIOD_TYPE,
                                                c.FROM_DATE,
                                                c.CALENDAR_MIN_DATE));

        pji_utils.write2out(
          PJI_RM_SUM_MAIN.GET_MISSING_TIME_TEXT(c.CALENDAR_NAME,
                                                c.USER_PERIOD_TYPE,
                                                c.CALENDAR_MAX_DATE,
                                                c.TO_DATE));

      elsif (c.TO_DATE > c.CALENDAR_MAX_DATE) then

        pji_utils.write2out(
          PJI_RM_SUM_MAIN.GET_MISSING_TIME_TEXT(c.CALENDAR_NAME,
                                                c.USER_PERIOD_TYPE,
                                                c.CALENDAR_MAX_DATE,
                                                c.TO_DATE));

      elsif (c.FROM_DATE < c.CALENDAR_MIN_DATE) then

        pji_utils.write2out(
          PJI_RM_SUM_MAIN.GET_MISSING_TIME_TEXT(c.CALENDAR_NAME,
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
      set    END_DATE = sysdate
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
    l_extraction_type    varchar2(30);
    l_request_id         number;
    l_batch_count        number;
    l_schema             varchar2(30);

  begin

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(g_process || 1, 'PJI_RM_SUM_MAIN.WRAPUP_PROCESS;')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                        (g_process, 'EXTRACTION_TYPE');

    l_parallel_processes :=
    PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'PARALLEL_PROCESSES');

    for x in 2 .. l_parallel_processes loop
      PJI_RM_SUM_EXTR.WAIT_FOR_WORKER(x);
    end loop;

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'PROCESS_RUNNING') = 'A') then
      fnd_message.set_name('PJI','PJI_SUM_ABORT');
      dbms_standard.raise_application_error(-20000, fnd_message.get);
    elsif (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'PROCESS_RUNNING') = 'F') then
      fnd_message.set_name('PJI','PJI_SUM_FAIL');
      dbms_standard.raise_application_error(-20000, fnd_message.get);
    end if;

    DANGLING_REPORT;

    -- clean up worker tables
    PJI_FM_PLAN_EXTR.CLEANUP_LOG;

    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_RM_ORG_BATCH_MAP','NORMAL',null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_PJI_PROJ_BATCH_MAP','NORMAL',null);

    WRAPUP_SETUP;

    PJI_PROCESS_UTIL.WRAPUP_PROCESS(g_process || 1);
    PJI_PROCESS_UTIL.WRAPUP_PROCESS(g_process);

    update PJI_SYSTEM_CONFIG_HIST
    set    END_DATE = sysdate,
           COMPLETION_TEXT = 'Normal completion'
    where  PROCESS_NAME = g_process || 1 and
           END_DATE is null;

    PJI_UTILS.SET_PARAMETER('LAST_PJI_EXTR_DATE', to_char(sysdate, 'YYYY/MM/DD'));
    commit;

    -- calculate statistics on temporary tables used to retrieve fact data

    PJI_PMV_UTIL.SEED_PJI_STATS;

    commit;

  end WRAPUP_PROCESS;


  -- -----------------------------------------------------
  -- procedure WRAPUP_FAILURE
  -- -----------------------------------------------------
  procedure WRAPUP_FAILURE is

    l_sqlerrm varchar2(240);

  begin

    rollback;

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
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
  -- procedure SHUTDOWN_PROCESS
  -- -----------------------------------------------------
  procedure SHUTDOWN_PROCESS (errbuf  out nocopy varchar2,
                              retcode out nocopy varchar2) is

  begin

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(g_process, 'PROCESS_RUNNING') <> 'Y') then

      retcode := 1;

    else

      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process,
                                             'PROCESS_RUNNING',
                                             'A');
      commit;
      retcode := 0;

    end if;

  exception when others then

    retcode := 2;
    errbuf := sqlerrm;

  end SHUTDOWN_PROCESS;


  -- -----------------------------------------------------
  -- procedure SUMMARIZE
  --
  -- This the the main procedure, it is invoked from
  -- a concurrent program.
  -- -----------------------------------------------------
  procedure SUMMARIZE
  (
    errbuf            out nocopy varchar2,
    retcode           out nocopy varchar2,
    p_run_mode        in         varchar2,
    p_prtl_schedule   in         varchar2 default null, -- RM
    p_organization_id in         number   default null, -- RM parameter
    p_include_sub_org in         varchar2 default 'N',  -- RM parameter
    p_prtl_financial  in         varchar2 default null, -- FM
    p_operating_unit  in         number   default null, -- FM parameter
    p_from_project    in         varchar2 default null, -- FM parameter
    p_to_project      in         varchar2 default null, -- FM parameter
    p_plan_type       in         varchar2 default null  -- FM parameter
  ) is

  l_pji_not_licensed exception;
  pragma exception_init(l_pji_not_licensed, -20020);
  l_prior_iteration_successful boolean;
  l_transition_flag varchar2(1);
  --Bug 4892320.
  l_org_count        NUMBER;

  l_sum_running varchar2(255) := 'The process has failed due to a previously running process.';
  l_sum_fail varchar2(255) := 'The process has failed because process ''Update Project Intelligence Data'' is not complete.';
  l_sum_refresh_fail varchar2(255) := 'The process has failed because process ''Update Project Intelligence Data'' has not yet been run.';

  begin
  pa_debug.set_process('PLSQL');  /* start 4893117*/
  IF p_run_mode in ('P') then
      pa_debug.log_message('=======Concurrent Program Parameters Start =======', 1);
      pa_debug.log_message('Argument => Refresh Schedule ['||p_prtl_schedule||']', 1);
      pa_debug.log_message('Argument => Expenditure Organization (schedule) ['||p_organization_id||']', 1);
      pa_debug.log_message('Argument => Include Sub-Organizations (schedule) ['||p_include_sub_org||']', 1);
      pa_debug.log_message('Argument => Refresh Financial ['||p_prtl_financial||']', 1);
      pa_debug.log_message('Argument => Project Operating Unit (financial) ['||p_operating_unit||']', 1);
      pa_debug.log_message('Argument => From Project (financial) ['||p_from_project||']', 1);
      pa_debug.log_message('Argument => To Project (financial) ['||p_to_project||']', 1);
      pa_debug.log_message('=======Concurrent Program Parameters End =======', 1);
   END IF;    /* end 4893117*/

    PJI_FM_DEBUG.CONC_REQUEST_HOOK(g_process);

    /* this is removed as  for bug#5075209
    if (PA_INSTALL.is_pji_licensed = 'N') then
      pji_utils.write2log('Error: PJI is not licensed.');
      commit;
      raise l_pji_not_licensed;
    end if;*/

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

    /*

    Removing the fix for now.  Post interop we need to consider the project
    count, since all stage 2 concurrent programs have this procedure as
    their entry point.

    Customer can avoid this problem by, when they have no schedule data, not
    running schedule refresh.

    -- Bug 4892320. If pji_org_extr_status has 0 records then there is nothing to summarize and hence return.
    IF p_run_mode='R'  THEN

        SELECT count(*)
        INTO   l_org_count
        FROM   pji_org_extr_status;

        IF l_org_count=0 THEN

            pji_utils.write2log('Nothing to summarize since pji_org_extr_status has 0 records');
            RETURN;

        END IF;

    END IF;
    */

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
                   p_prtl_schedule,
                   p_organization_id,
                   p_include_sub_org,
                   p_prtl_financial,
                   p_operating_unit,
                   p_from_project,
                   p_to_project,
                   p_plan_type);

      -- Synchronize PJI_RM_WORK_TYPE_INFO with transaction system
      PJI_PJI_EXTRACTION_UTILS.UPDATE_PJI_RM_WORK_TYPE_INFO(g_process || 1);

      -- Determine if Jobs have become utilizable or non-utilizable
      PJI_PJI_EXTRACTION_UTILS.UPDATE_RESOURCE_DATA(g_process || 1);

      RUN_PROCESS;
      WRAPUP_PROCESS;

      if (PJI_UTILS.GET_PARAMETER('DANGLING_PJI_ROWS_EXIST') = 'Y') then
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
      retcode := 2;
      errbuf := sqlerrm;
      raise;

  end SUMMARIZE;

end PJI_RM_SUM_MAIN;

/
