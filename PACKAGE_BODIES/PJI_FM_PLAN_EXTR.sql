--------------------------------------------------------
--  DDL for Package Body PJI_FM_PLAN_EXTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_PLAN_EXTR" AS
/* $Header: PJISF07B.pls 120.7.12010000.2 2010/02/26 09:28:48 arbandyo ship $ */

  g_cost_budget_type_code       varchar2(30);
  g_cost_forecast_type_code     varchar2(30);
  g_revenue_budget_type_code    varchar2(30);
  g_revenue_forecast_type_code  varchar2(30);
  g_cost_budget_curr_rule       varchar2(1);
  g_cost_forecast_curr_rule     varchar2(1);
  g_revenue_budget_curr_rule    varchar2(1);
  g_revenue_forecast_curr_rule  varchar2(1);
  g_cost_fp_type_code           varchar2(30);
  g_rev_fp_type_code            varchar2(30);
  g_cost_forecast_fp_type_code  varchar2(30);
  g_rev_forecast_fp_type_code   varchar2(30);

  g_project_id                  number(15);
  g_project_org_id              number(15);
  g_project_organization_id     number(15);
  g_projfunc_currency_code      varchar2(15);
  g_projfunc_currency_mau       number;
  g_labor_mau                   number := 0.01;

  g_pa_period_flag              varchar2(1);
  g_gl_period_flag              varchar2(1);

       g_ent_start_period_id     number        := null;
       g_ent_start_period_name   varchar2(100) := null;
       g_entw_start_period_id    number        := null;
       g_entw_start_period_name  varchar2(100) := null;
       g_ent_start_date          date := null;
       g_entw_start_date         date := null;
       g_ent_end_date            date := null;
       g_entw_end_date           date := null;
       g_global_start_date       date := null;

       g_global_start_J          number := null;
       g_ent_start_J             number := null;
       g_entw_start_J            number := null;
       g_ent_end_J               number := null;
       g_entw_end_J              number := null;

-- -----------------------------------------------------
-- procedure GET_SYSTEM_SETTINGS
-- -----------------------------------------------------

procedure get_system_settings is

begin

  -- Cache setup settings in global variables.

  pji_utils.write2log('Entering PJI_FM_PLAN_EXTR.GET_SYSTEM_SETTINGS',TRUE,3);

  g_cost_budget_type_code      := pji_process_util.get_process_parameter(PJI_RM_SUM_MAIN.g_process,'COST_BUDGET_TYPE_CODE');
  g_cost_forecast_type_code    := pji_process_util.get_process_parameter(PJI_RM_SUM_MAIN.g_process,'COST_FORECAST_TYPE_CODE');
  g_revenue_budget_type_code   := pji_process_util.get_process_parameter(PJI_RM_SUM_MAIN.g_process,'REVENUE_BUDGET_TYPE_CODE');
  g_revenue_forecast_type_code := pji_process_util.get_process_parameter(PJI_RM_SUM_MAIN.g_process,'REVENUE_FORECAST_TYPE_CODE');
  g_cost_budget_curr_rule      := pji_process_util.get_process_parameter(PJI_RM_SUM_MAIN.g_process,'COST_BUDGET_CURR_RULE');
  g_cost_forecast_curr_rule    := pji_process_util.get_process_parameter(PJI_RM_SUM_MAIN.g_process,'COST_FORECAST_CURR_RULE');
  g_revenue_budget_curr_rule   := pji_process_util.get_process_parameter(PJI_RM_SUM_MAIN.g_process,'REVENUE_BUDGET_CURR_RULE');
  g_revenue_forecast_curr_rule := pji_process_util.get_process_parameter(PJI_RM_SUM_MAIN.g_process,'REVENUE_FORECAST_CURR_RULE');
  g_pa_period_flag             := pji_process_util.get_process_parameter(PJI_RM_SUM_MAIN.g_process,'PA_PERIOD_FLAG');
  g_gl_period_flag             := pji_process_util.get_process_parameter(PJI_RM_SUM_MAIN.g_process,'GL_PERIOD_FLAG');

  g_cost_fp_type_code          := pji_process_util.get_process_parameter(PJI_RM_SUM_MAIN.g_process, 'COST_FP_TYPE_ID');
  g_rev_fp_type_code           := pji_process_util.get_process_parameter(PJI_RM_SUM_MAIN.g_process, 'REVENUE_FP_TYPE_ID');
  g_cost_forecast_fp_type_code := pji_process_util.get_process_parameter(PJI_RM_SUM_MAIN.g_process, 'COST_FORECAST_FP_TYPE_ID');
  g_rev_forecast_fp_type_code  := pji_process_util.get_process_parameter(PJI_RM_SUM_MAIN.g_process, 'REVENUE_FORECAST_FP_TYPE_ID');

  pji_utils.write2log('Completed PJI_FM_PLAN_EXTR.GET_SYSTEM_SETTINGS',TRUE,3);

end get_system_settings;

-- -----------------------------------------------------
-- procedure INIT_GLOBAL_PARAMETERS
-- -----------------------------------------------------

procedure init_global_parameters is

begin

  -- This procedure is called from PJI_RM_SUM_MAIN.INIT_PROCESS.
  -- Since users may make changes in setup form at any given
  -- point in time we need to make sure that we do not
  -- pickup these changes in the middle of summarization run.
  -- We get plan settings once from PJI setup table and
  -- store them as process variables.

  pji_utils.write2log('Entering PJI_FM_PLAN_EXTR.INIT_GLOBAL_PARAMETERS',TRUE,3);

  pji_process_util.set_process_parameter(
    PJI_RM_SUM_MAIN.g_process,
    'COST_BUDGET_TYPE_CODE',
    pji_utils.get_setup_parameter('COST_BUDGET_TYPE_CODE')
  );

  pji_process_util.set_process_parameter(
    PJI_RM_SUM_MAIN.g_process,
    'COST_FORECAST_TYPE_CODE',
    pji_utils.get_setup_parameter('COST_FORECAST_TYPE_CODE')
  );

  pji_process_util.set_process_parameter(
    PJI_RM_SUM_MAIN.g_process,
    'REVENUE_BUDGET_TYPE_CODE',
    pji_utils.get_setup_parameter('REVENUE_BUDGET_TYPE_CODE')
  );

  pji_process_util.set_process_parameter(
    PJI_RM_SUM_MAIN.g_process,
    'REVENUE_FORECAST_TYPE_CODE',
    pji_utils.get_setup_parameter('REVENUE_FORECAST_TYPE_CODE')
  );

  pji_process_util.set_process_parameter(
    PJI_RM_SUM_MAIN.g_process,
    'COST_BUDGET_CURR_RULE',
    pji_utils.get_setup_parameter('COST_BUDGET_CONV_RULE')
  );

  pji_process_util.set_process_parameter(
    PJI_RM_SUM_MAIN.g_process,
    'COST_FORECAST_CURR_RULE',
    pji_utils.get_setup_parameter('COST_FORECAST_CONV_RULE')
  );

  pji_process_util.set_process_parameter(
    PJI_RM_SUM_MAIN.g_process,
    'REVENUE_BUDGET_CURR_RULE',
    pji_utils.get_setup_parameter('REVENUE_BUDGET_CONV_RULE')
  );

  pji_process_util.set_process_parameter(
    PJI_RM_SUM_MAIN.g_process,
    'REVENUE_FORECAST_CURR_RULE',
    pji_utils.get_setup_parameter('REVENUE_FORECAST_CONV_RULE')
  );

  pji_process_util.set_process_parameter(
    PJI_RM_SUM_MAIN.g_process,
    'PA_PERIOD_FLAG',
    pji_utils.get_setup_parameter('PA_PERIOD_FLAG')
  );

  pji_process_util.set_process_parameter(
    PJI_RM_SUM_MAIN.g_process,
    'GL_PERIOD_FLAG',
    pji_utils.get_setup_parameter('GL_PERIOD_FLAG')
  );

  pji_process_util.set_process_parameter(
    PJI_RM_SUM_MAIN.g_process,
    'COST_FP_TYPE_ID',
    pji_utils.get_setup_parameter('COST_FP_TYPE_ID')
  );

  pji_process_util.set_process_parameter(
    PJI_RM_SUM_MAIN.g_process,
    'REVENUE_FP_TYPE_ID',
    pji_utils.get_setup_parameter('REVENUE_FP_TYPE_ID')
  );

  pji_process_util.set_process_parameter(
    PJI_RM_SUM_MAIN.g_process,
    'COST_FORECAST_FP_TYPE_ID',
    pji_utils.get_setup_parameter('COST_FORECAST_FP_TYPE_ID')
  );

  pji_process_util.set_process_parameter(
    PJI_RM_SUM_MAIN.g_process,
    'REVENUE_FORECAST_FP_TYPE_ID',
    pji_utils.get_setup_parameter('REVENUE_FORECAST_FP_TYPE_ID')
  );


  pji_utils.write2log('Completed PJI_FM_PLAN_EXTR.INIT_GLOBAL_PARAMETERS',TRUE,3);

end init_global_parameters;


-- -----------------------------------------------------
-- procedure CLEANUP
-- -----------------------------------------------------

procedure cleanup(p_worker_id number) is

begin

  pji_utils.write2log('Entering PJI_FM_PLAN_EXTR.CLEANUP',TRUE, 3);


    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( pji_utils.get_pji_schema_name , 'PJI_FM_EXTR_PLNVER1', 'NORMAL',null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( pji_utils.get_pji_schema_name , 'PJI_FM_EXTR_PLAN', 'NORMAL',null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( pji_utils.get_pji_schema_name , 'PJI_FM_EXTR_PLNVER2', 'NORMAL',null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( pji_utils.get_pji_schema_name , 'PJI_FM_AGGR_PLN', 'NORMAL',null);


  pji_utils.write2log('Completed PJI_FM_PLAN_EXTR.CLEANUP',TRUE, 3);

end cleanup;

-- -----------------------------------------------------
-- procedure CLEANUP_LOG
-- -----------------------------------------------------

procedure cleanup_log is

begin

  pji_utils.write2log('Entering PJI_FM_PLAN_EXTR.CLEANUP_LOG',TRUE, 3);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( pji_utils.get_pji_schema_name , 'PJI_FM_EXTR_PLN_LOG', 'NORMAL',null);

  pji_utils.write2log('Completed PJI_FM_PLAN_EXTR.CLEANUP_LOG',TRUE, 3);

end cleanup_log;


-- -----------------------------------------------------
-- procedure UPDATE_PLAN_ORG_INFO
-- -----------------------------------------------------

procedure update_plan_org_info(p_worker_id number) is

  l_process varchar2(30);

begin

  l_process   := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
          (l_process,'PJI_FM_PLAN_EXTR.UPDATE_PLAN_ORG_INFO(p_worker_id);')) then
    return;
  end if;

get_system_settings;

Update PJI_ORG_EXTR_INFO  orginfo
set
( orginfo.PA_FIRST_PERIOD_ID
, orginfo.PA_FIRST_PERIOD_NAME
, orginfo.PA_FIRST_START_DATE
, orginfo.PA_FIRST_END_DATE
, orginfo.PROJFUNC_CURRENCY_MAU
) =
( select
  cal_pa.cal_period_id
  , cal_pa.name
  , to_number(to_char(cal_pa.start_date,'J'))
  , to_number(to_char(cal_pa.end_date,'J'))
  , nvl( curr.minimum_accountable_unit
     , power( 10, (-1 * curr.precision)))
  from  fii_time_cal_period   cal_pa
       , fnd_currencies        curr
  where cal_pa.calendar_id    = orginfo.pa_calendar_id
  and   DECODE(sign(g_global_start_J - orginfo.pa_calendar_min_date)
         , 1, g_global_start_date
         , to_char(to_date(orginfo.pa_calendar_min_date,'J'),'DD-MON-YYYY')
        )  between cal_pa.start_date and cal_pa.end_date
  and   orginfo.pf_currency_code = curr.currency_code
)
;


Update PJI_ORG_EXTR_INFO  orginfo
set
( orginfo.GL_FIRST_PERIOD_ID
, orginfo.GL_FIRST_PERIOD_NAME
, orginfo.GL_FIRST_START_DATE
, orginfo.GL_FIRST_END_DATE
) =
( select
  cal_gl.cal_period_id
  , cal_gl.name
  , to_number(to_char(cal_gl.start_date,'J'))
  , to_number(to_char(cal_gl.end_date,'J'))
  from  fii_time_cal_period   cal_gl
  where cal_gl.calendar_id    = orginfo.gl_calendar_id
  and   DECODE(sign(g_global_start_J - orginfo.gl_calendar_min_date)
         , 1, g_global_start_date
         , to_char(to_date(orginfo.gl_calendar_min_date,'J'),'DD-MON-YYYY')
        )  between cal_gl.start_date and cal_gl.end_date
)
;

          PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
          (l_process, 'PJI_FM_PLAN_EXTR.UPDATE_PLAN_ORG_INFO(p_worker_id);');

commit;

end update_plan_org_info;



-- -----------------------------------------------------
-- procedure EXTRACT_PLAN_VERSIONS
-- -----------------------------------------------------

procedure extract_plan_versions(p_worker_id number) is

  l_process varchar2(30);

begin

  l_process   := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
          (l_process,'PJI_FM_PLAN_EXTR.EXTRACT_PLAN_VERSIONS(p_worker_id);')) then
    return;
  end if;

-- Get Financial Plan versions

Insert into PJI_FM_EXTR_PLNVER1
( WORKER_ID
, PROJECT_ID
, PROJECT_ORGANIZATION_ID
, PROJECT_ORG_ID
, VERSION_ID
, PLAN_TYPE_CODE
, TIME_PHASED_TYPE_CODE
, CURRENT_FLAG
, CURRENT_ORIGINAL_FLAG
, DANGLING_FLAG
, PROJECT_TYPE_CLASS
)
Select  /*+  ORDERED
             full(bv)   use_hash(bv)  parallel(bv)
             full(fpo)  use_hash(fpo) swap_join_inputs(fpo)
         */
        map.WORKER_id                  worker_id
      , map.project_id                 project_id
      , map.project_organization_id    project_organization_id
      , map.project_org_id             project_org_id
      , bv.budget_version_id           version_id
      , to_char(fpo.fin_plan_type_id)  plan_type_code
          ,DECODE(bv.version_type
                  , 'ALL',     fpo.all_time_phased_code
                  , 'COST',    fpo.cost_time_phased_code
                  , 'REVENUE', fpo.revenue_time_phased_code
                 )                     time_phased_type_code
      , bv.current_flag                current_flag
      , bv.current_original_flag       current_original_flag
      , null                           dangling_flag
      , map.project_type_class         project_type_class
From
      PJI_PJI_PROJ_BATCH_MAP     map
      , pa_budget_versions       bv
      , pa_proj_fp_options       fpo
Where 1=1
      and map.worker_id = p_worker_id
      and map.project_id = bv.project_id
      and (
            (     bv.current_flag = 'Y'
              and to_char(fpo.fin_plan_type_id) in
                  (
                    g_cost_fp_type_code,
                    g_cost_forecast_fp_type_code,
                    g_rev_fp_type_code,
                    g_rev_forecast_fp_type_code
                  )
            )
            or
            (
                  bv.current_original_flag = 'Y'
              and to_char(fpo.fin_plan_type_id) in
                  (
                    g_cost_fp_type_code,
                    g_rev_fp_type_code
                  )
            )
          )
and bv.budget_version_id <> map.cost_budget_c_version
and bv.budget_version_id <> map.cost_budget_co_version
and bv.budget_version_id <> map.revenue_budget_c_version
and bv.budget_version_id <> map.revenue_budget_co_version
and bv.budget_version_id <> map.cost_forecast_c_version
and bv.budget_version_id <> map.revenue_forecast_c_version
and bv.version_type is not null
and bv.fin_plan_type_id is not null
and fpo.project_id = bv.project_id
and bv.fin_plan_type_id = fpo.fin_plan_type_id
and bv.budget_version_id = fpo.fin_plan_version_id
and fpo.fin_plan_option_level_code = 'PLAN_VERSION'
;

-- Get budget versions for those projects without Financial Plans

Insert /*+ APPEND */ into PJI_FM_EXTR_PLNVER1
( WORKER_ID
, PROJECT_ID
, PROJECT_ORGANIZATION_ID
, PROJECT_ORG_ID
, VERSION_ID
, PLAN_TYPE_CODE
, TIME_PHASED_TYPE_CODE
, CURRENT_FLAG
, CURRENT_ORIGINAL_FLAG
, DANGLING_FLAG
, PROJECT_TYPE_CLASS
)
Select  /*+  ORDERED
             full(bv)   use_hash(bv)     parallel(bv)
             full(bem)  use_hash(bem)    swap_join_inputs(bem)
             full(pln)  use_hash(pln)    swap_join_inputs(pln)
         */
        map.worker_id                  worker_id
      , map.project_id                 project_id
      , map.project_organization_id    project_organization_id
      , map.project_org_id             project_org_id
      , bv.budget_version_id           version_id
      , bv.budget_type_code            plan_type_code
      , decode(bem.time_phased_type_code
         , 'R', 'N'
         , bem.time_phased_type_code)  time_phased_type_code
      , bv.current_flag                current_flag
      , bv.current_original_flag       current_original_flag
      , null                           dangling_flag
      , map.project_type_class         project_type_class
From
      PJI_PJI_PROJ_BATCH_MAP     map
      , pa_budget_versions       bv
      , pa_budget_entry_methods  bem
      , (select distinct
                PROJECT_ID
         from   PJI_FM_EXTR_PLNVER1
         where  WORKER_ID = p_worker_id) pln
Where 1=1
      and map.worker_id = p_worker_id
      and map.project_id = bv.project_id
      and bem.budget_entry_method_code = bv.budget_entry_method_code
      and (
            (     bv.current_flag = 'Y'
              and bv.budget_type_code in
                  (
                    g_cost_budget_type_code,
                    g_cost_forecast_type_code,
                    g_revenue_budget_type_code,
                    g_revenue_forecast_type_code
                  )
            )
            or
            (
                  bv.current_original_flag = 'Y'
              and bv.budget_type_code in
                  (
                    g_cost_budget_type_code,
                    g_revenue_budget_type_code
                  )
            )
          )
and bv.budget_version_id <> map.cost_budget_c_version
and bv.budget_version_id <> map.cost_budget_co_version
and bv.budget_version_id <> map.revenue_budget_c_version
and bv.budget_version_id <> map.revenue_budget_co_version
and bv.budget_version_id <> map.cost_forecast_c_version
and bv.budget_version_id <> map.revenue_forecast_c_version
and bv.version_type is null
and bv.fin_plan_type_id is null
and map.project_id = pln.project_id (+)
and pln.project_id is null;

          PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
          (l_process, 'PJI_FM_PLAN_EXTR.EXTRACT_PLAN_VERSIONS(p_worker_id);');

commit;

end extract_plan_versions;



-- -----------------------------------------------------
-- procedure EXTRACT_BATCH_PLAN
-- -----------------------------------------------------

procedure extract_batch_plan(p_worker_id number) is

  l_process varchar2(30);
  l_degree number;

begin

  l_process   := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
          (l_process,'PJI_FM_PLAN_EXTR.EXTRACT_BATCH_PLAN(p_worker_id);')) then
    return;
  end if;

       l_degree :=  BIS_COMMON_PARAMETERS.GET_DEGREE_OF_PARALLELISM();

       if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                  'CURRENT_BATCH') = 1) then
       FND_STATS.GATHER_TABLE_STATS(
                 ownname    =>  pji_utils.get_pji_schema_name
                 , tabname  =>  'PJI_FM_EXTR_PLNVER1'
                 , percent  =>  10
                 , degree   =>  l_degree
                 );
       end if;


Insert /*+ APPEND PARALLEL(plan_i) */ into PJI_FM_EXTR_PLAN plan_i  --  for OF slice
(  LINE_TYPE
,  CALENDAR_TYPE_CODE
,  WORKER_ID
,  PROJECT_ID
,  PROJECT_ORG_ID
,  PF_CURRENCY_CODE
,  VERSION_ID
,  PLAN_TYPE_CODE
,  CURRENCY_TYPE
,  PERIOD_ID
,  PERIOD_NAME
,  START_DATE
,  END_DATE
,  REVENUE
,  RAW_COST
,  BURDENED_COST
,  LABOR_HRS
,  TIME_DANGLING_FLAG
,  RATE_DANGLING_FLAG
,  RATE2_DANGLING_FLAG
)
select  /*+  ORDERED
             full(orginfo)   use_hash(orginfo)     swap_join_inputs(orginfo)
             full(vers)      use_hash(vers)        parallel(vers)
             full(fii_time)  use_hash(fii_time)    swap_join_inputs(fii_time)
         */
        decode(vers.time_phased_type_code
         , 'P', 'OF'
         , 'G', 'OF'
         , 'F1')                     line_type
      , decode(vers.time_phased_type_code
             , 'P', 'PA'
             , 'G', 'GL'
             , 'ENT')                calendar_type_code
      , p_worker_id                  worker_id
      , vers.project_id              project_id
      , vers.project_org_id          project_org_id
      , orginfo.pf_currency_code     pf_currency_code
      , vers.version_id              version_id
      , vers.plan_type_code          plan_type_code
      , 'F'                          currency_type
      , decode(vers.time_phased_type_code
         , 'P', decode(sign(fii_time.end_date - to_date(orginfo.pa_first_end_date,'J'))
                 , -1, orginfo.pa_first_period_id
                 , fii_time.period_id)
         , 'G', decode(sign(fii_time.end_date - to_date(orginfo.gl_first_end_date,'J'))
                 , -1, orginfo.gl_first_period_id
                 , fii_time.period_id)
         , decode(sign(bl.end_date - g_ent_end_date)
                 , -1, g_ent_start_period_id
                 , -1)
         )                                      period_id
      , decode(vers.time_phased_type_code
         , 'P', decode(sign(fii_time.end_date - to_date(orginfo.pa_first_end_date,'J'))
                 , -1, orginfo.pa_first_period_name
                 , fii_time.period_name)
         , 'G', decode(sign(fii_time.end_date - to_date(orginfo.gl_first_end_date,'J'))
                 , -1, orginfo.gl_first_period_name
                 , fii_time.period_name)
         , decode(sign(bl.end_date - g_ent_start_date)
                 , -1, g_ent_start_period_name
                 , PJI_RM_SUM_MAIN.g_null)
         )                                      period_name
      , decode(vers.time_phased_type_code
         , 'P', decode(sign(fii_time.end_date - to_date(orginfo.pa_first_end_date,'J'))
                 , -1, to_date(orginfo.pa_first_start_date,'J')
                 , fii_time.start_date)
         , 'G', decode(sign(fii_time.end_date - to_date(orginfo.gl_first_end_date,'J'))
                 , -1, to_date(orginfo.gl_first_start_date,'J')
                 , fii_time.start_date)
         , decode(sign(bl.end_date - g_ent_start_date)
                 , -1, g_ent_start_date
                 , bl.start_date)
         )                                      start_date
      , decode(vers.time_phased_type_code
         , 'P', decode(sign(fii_time.end_date - to_date(orginfo.pa_first_end_date,'J'))
                 , -1, to_date(orginfo.pa_first_end_date,'J')
                 , fii_time.end_date)
         , 'G', decode(sign(fii_time.end_date - to_date(orginfo.gl_first_end_date,'J'))
                 , -1, to_date(orginfo.gl_first_end_date,'J')
                 , fii_time.end_date)
         , decode(sign(bl.end_date - g_ent_end_date)
                 , -1, g_ent_end_date
                 , bl.end_date)
         )                                      end_date
      , decode(vers.plan_type_code
         , g_revenue_budget_type_code   , nvl(bl.revenue,to_number(null))
         , g_revenue_forecast_type_code , nvl(bl.revenue,to_number(null))
         , g_rev_fp_type_code           , nvl(bl.revenue,to_number(null))
         , g_rev_forecast_fp_type_code  , nvl(bl.revenue,to_number(null))
         , to_number(null)
         )                              revenue
      , decode(vers.plan_type_code
         , g_cost_budget_type_code      , nvl(bl.raw_cost,to_number(null))
         , g_cost_forecast_type_code    , nvl(bl.raw_cost,to_number(null))
         , g_cost_fp_type_code          , nvl(bl.raw_cost,to_number(null))
         , g_cost_forecast_fp_type_code , nvl(bl.raw_cost,to_number(null))
         , to_number(null)
         )                              raw_cost
      , decode(vers.plan_type_code
         , g_cost_budget_type_code      , nvl(bl.burdened_cost,to_number(null))
         , g_cost_forecast_type_code    , nvl(bl.burdened_cost,to_number(null))
         , g_cost_fp_type_code          , nvl(bl.burdened_cost,to_number(null))
         , g_cost_forecast_fp_type_code , nvl(bl.burdened_cost,to_number(null))
         , to_number(null)
         )                              burdened_cost
      , decode(nvl(ra.track_as_labor_flag,'Y')
         , 'Y', nvl(bl.quantity,to_number(null))
         , to_number(null)
         )                              labor_hrs
      , decode(sign(to_date(orginfo.pa_calendar_max_date,'J') - fii_time.end_date)
         , -1, 'P'
         , null)||
           decode(sign(to_date(orginfo.gl_calendar_max_date,'J') - fii_time.end_date)
            , -1, 'G'
            , null)||
              decode(sign(to_date(orginfo.en_calendar_max_date,'J') - bl.end_date)
               , -1, 'E'
               , null)                  time_dangling_flag
      , null                            rate_dangling_flag
      , null                            rate2_dangling_flag
    from
            PJI_ORG_EXTR_INFO            orginfo
          , PJI_FM_EXTR_PLNVER1          vers
          , pa_resource_assignments      ra
          , pa_budget_lines              bl
          , ( select  -1               calendar_id
                      , -1             period_id
                      , PJI_RM_SUM_MAIN.g_null  period_name
                      , null           start_date
                      , null           end_date
              from    dual
            union all
              select  calendar_id      calendar_id
                      , cal_period_id  period_id
                      , name           period_name
                      , start_date     start_date
                      , end_date       end_date
              from    fii_time_cal_period
            ) fii_time
    where  1=1
    and    orginfo.projfunc_currency_mau is not null
    and    vers.worker_id            = p_worker_id
    and    vers.project_org_id       = orginfo.org_id
    and    ra.project_id             = vers.project_id
    and    ra.budget_version_id      = vers.version_id
    and    ra.resource_assignment_id = bl.resource_assignment_id
    and    decode(vers.time_phased_type_code
            , 'P', orginfo.pa_calendar_id
            , 'G', orginfo.gl_calendar_id
            , -1  )                      = fii_time.calendar_id
    and    decode(vers.time_phased_type_code
            , 'P', decode(sign(bl.end_date - to_date(orginfo.pa_first_end_date,'J'))
                    , -1, orginfo.pa_first_period_name
                    , bl.period_name)
            , 'G', decode(sign(bl.end_date - to_date(orginfo.gl_first_end_date,'J'))
                    , -1, orginfo.gl_first_period_name
                    , bl.period_name)
            , PJI_RM_SUM_MAIN.g_null
            )                            = fii_time.period_name
    and    decode(vers.time_phased_type_code
            , 'P', orginfo.pa_first_period_id
            , 'G', orginfo.gl_first_period_id
            , -1
            )                            <= fii_time.period_id
;

          PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
          (l_process, 'PJI_FM_PLAN_EXTR.EXTRACT_BATCH_PLAN(p_worker_id);');

commit;

end extract_batch_plan;



-- -----------------------------------------------------
-- procedure SPREAD_ENT_PLANS
-- -----------------------------------------------------

procedure spread_ent_plans(p_worker_id number) is

  l_process varchar2(30);

begin

  l_process   := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
          (l_process,'PJI_FM_PLAN_EXTR.SPREAD_ENT_PLANS(p_worker_id);')) then
    return;
  end if;

-- spread the ENT amounts
Insert /*+ APPEND PARALLEL(plan_i) */ into PJI_FM_EXTR_PLAN plan_i  --  OF slice for ENT
(  LINE_TYPE
,  CALENDAR_TYPE_CODE
,  WORKER_ID
,  PROJECT_ID
,  PROJECT_ORG_ID
,  PF_CURRENCY_CODE
,  VERSION_ID
,  PLAN_TYPE_CODE
,  CURRENCY_TYPE
,  PERIOD_ID
,  PERIOD_NAME
,  START_DATE
,  END_DATE
,  REVENUE
,  RAW_COST
,  BURDENED_COST
,  LABOR_HRS
,  TIME_DANGLING_FLAG
,  RATE_DANGLING_FLAG
,  RATE2_DANGLING_FLAG
)
select  /*+  ORDERED
             full(orginfo)   use_hash(orginfo) swap_join_inputs(orginfo)
             full(tmp)       use_hash(tmp)     parallel(tmp)
             full(ent)       use_hash(ent)     swap_join_inputs(ent)
         */
        'OF'                        line_type
      , tmp.calendar_type_code      calendar_type_code
      , tmp.worker_id
      , tmp.project_id
      , tmp.project_org_id
      , tmp.pf_currency_code
      , tmp.version_id
      , tmp.plan_type_code          plan_type_code
      , tmp.currency_type           currency_type
      , ent.ent_period_id           period_id
      , ent.name                    period_name
      , ent.start_date              start_date
      , ent.end_date                end_date
      , round(sum(nvl(case when (tmp.start_date <= ent.start_date) and
                                (tmp.end_date >= ent.end_date)
                           then (ent.end_date - ent.start_date + 1) *
                                tmp.revenue / (tmp.end_date - tmp.start_date+1)
                           when (ent.start_date <= tmp.start_date) and
                                (ent.end_date <= tmp.end_date )
                           then (ent.end_date - tmp.start_date + 1) *
                                tmp.revenue / (tmp.end_date - tmp.start_date+1)
                           when (ent.start_date >= tmp.start_date) and
                                (ent.end_date >= tmp.end_date)
                           then (tmp.end_date - ent.start_date + 1) *
                                tmp.revenue / (tmp.end_date - tmp.start_date+1)
                           when (ent.start_date <= tmp.start_date) and
                                (ent.end_date >= tmp.end_date)
                           then tmp.revenue
                           else to_number(null)
                           end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    revenue
      , round(sum(nvl(case when (tmp.start_date <= ent.start_date) and
                                (tmp.end_date >= ent.end_date)
                           then (ent.end_date - ent.start_date + 1) *
                                tmp.raw_cost /(tmp.end_date - tmp.start_date+1)
                           when (ent.start_date <= tmp.start_date) and
                                (ent.end_date <= tmp.end_date )
                           then (ent.end_date - tmp.start_date + 1) *
                                tmp.raw_cost /(tmp.end_date - tmp.start_date+1)
                           when (ent.start_date >= tmp.start_date) and
                                (ent.end_date >= tmp.end_date)
                           then (tmp.end_date - ent.start_date + 1) *
                                tmp.raw_cost /(tmp.end_date - tmp.start_date+1)
                           when (ent.start_date <= tmp.start_date) and
                                (ent.end_date >= tmp.end_date)
                           then tmp.raw_cost
                           else to_number(null)
                           end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    raw_cost
      , round(sum(nvl(case when (tmp.start_date <= ent.start_date) and
                                (tmp.end_date >= ent.end_date)
                           then (ent.end_date - ent.start_date + 1) *
                              tmp.burdened_cost/(tmp.end_date-tmp.start_date+1)
                           when (ent.start_date <= tmp.start_date) and
                                (ent.end_date <= tmp.end_date )
                           then (ent.end_date - tmp.start_date + 1) *
                              tmp.burdened_cost/(tmp.end_date-tmp.start_date+1)
                           when (ent.start_date >= tmp.start_date) and
                                (ent.end_date >= tmp.end_date)
                           then (tmp.end_date - ent.start_date + 1) *
                              tmp.burdened_cost/(tmp.end_date-tmp.start_date+1)
                           when (ent.start_date <= tmp.start_date) and
                                (ent.end_date >= tmp.end_date)
                           then tmp.burdened_cost
                           else to_number(null)
                           end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    burdened_cost
      , round(sum(nvl(case when (tmp.start_date <= ent.start_date) and
                                (tmp.end_date >= ent.end_date)
                           then (ent.end_date - ent.start_date + 1) *
                                tmp.labor_hrs/(tmp.end_date - tmp.start_date+1)
                           when (ent.start_date <= tmp.start_date) and
                                (ent.end_date <= tmp.end_date )
                           then (ent.end_date - tmp.start_date + 1) *
                                tmp.labor_hrs/(tmp.end_date - tmp.start_date+1)
                           when (ent.start_date >= tmp.start_date) and
                                (ent.end_date >= tmp.end_date)
                           then (tmp.end_date - ent.start_date + 1) *
                                tmp.labor_hrs/(tmp.end_date - tmp.start_date+1)
                           when (ent.start_date <= tmp.start_date) and
                                (ent.end_date >= tmp.end_date)
                           then tmp.labor_hrs
                           else to_number(null)
                           end,to_number(null)))/g_labor_mau
          )*g_labor_mau                  labor_hrs
      , decode(sign(to_date(orginfo.en_calendar_max_date,'J') - ent.end_date)
         , -1, 'E'
         , null
         )                              time_dangling_flag
      , tmp.rate_dangling_flag          rate_dangling_flag
      , tmp.rate2_dangling_flag         rate2_dangling_flag
    from
              PJI_ORG_EXTR_INFO      orginfo
            , PJI_FM_EXTR_PLAN           tmp
            , fii_time_ent_period        ent
where tmp.worker_id   =   p_worker_id
and   tmp.end_date    >=  ent.start_date
and   tmp.start_date  <=  ent.end_date
and   tmp.line_type = 'F1'
and   tmp.calendar_type_code = 'ENT'
and   tmp.project_org_id     = orginfo.org_id
and   tmp.time_dangling_flag is null
group by
      tmp.worker_id
      , tmp.project_id
      , tmp.project_org_id
      , tmp.pf_currency_code
      , tmp.version_id
      , tmp.plan_type_code
      , tmp.calendar_type_code
      , tmp.currency_type
      , ent.ent_period_id
      , ent.name
      , ent.start_date
      , ent.end_date
      , tmp.start_date
      , tmp.end_date
      , tmp.time_dangling_flag
      , tmp.rate_dangling_flag
      , tmp.rate2_dangling_flag
      , orginfo.projfunc_currency_mau
      , orginfo.en_calendar_max_date
;

          PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
          (l_process, 'PJI_FM_PLAN_EXTR.SPREAD_ENT_PLANS(p_worker_id);');

commit;

end spread_ent_plans;



-- -----------------------------------------------------
-- procedure PLAN_CURR_CONV_TABLE
-- -----------------------------------------------------

procedure plan_curr_conv_table(p_worker_id number) is

  l_process varchar2(30);
  l_mau     number;
  l_mau2    number;

begin

  l_process   := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
      (l_process, 'PJI_FM_PLAN_EXTR.PLAN_CURR_CONV_TABLE(p_worker_id);')) then
    return;
  end if;

  l_mau := PJI_UTILS.GET_MAU_PRIMARY;
  l_mau2 := PJI_UTILS.GET_MAU_SECONDARY;

  insert /*+ append */ into PJI_FM_AGGR_DLY_RATES  --  for curr conv
  (
    WORKER_ID,
    PF_CURRENCY_CODE,
    TIME_ID,
    RATE,
    MAU,
    RATE2,
    MAU2
  )
  select
    -1                                                        worker_id,
    tmp.pf_currency_code                                      pf_currency_code,
    to_char(tmp.curr_date,'J')                                time_id,
    PJI_UTILS.GET_GLOBAL_RATE_PRIMARY(tmp.pf_currency_code,
                                      tmp.curr_date)          rate,
    l_mau                                                     mau,
    PJI_UTILS.GET_GLOBAL_RATE_SECONDARY(tmp.pf_currency_code,
                                        tmp.curr_date)        rate,
    l_mau2                                                    mau2
  from
    (
    select
      distinct
      tmp.pf_currency_code        pf_currency_code,
      decode(invert.rule,
             'F', tmp.start_date,
             'L', tmp.end_date)   curr_date
    from
      PJI_FM_EXTR_PLAN tmp,
      (
      select 'F' rule from dual union all
      select 'L' rule from dual
      ) invert
    where
      worker_id = p_worker_id and
      time_dangling_flag is null
    ) tmp;

  PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
  (l_process, 'PJI_FM_PLAN_EXTR.PLAN_CURR_CONV_TABLE(p_worker_id);');

  commit;

end plan_curr_conv_table;



-- -----------------------------------------------------
-- procedure CONVERT_TO_GLOBAL_CURRENCY
-- -----------------------------------------------------

procedure convert_to_global_currency(p_worker_id number) is

  l_process varchar2(30);

begin

  l_process   := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
          (l_process,'PJI_FM_PLAN_EXTR.CONVERT_TO_GLOBAL_CURRENCY(p_worker_id);')) then
    return;
  end if;

-- convert to GLOBAL CURRENCY
Insert /*+ APPEND PARALLEL(plan_i) */ into PJI_FM_EXTR_PLAN plan_i  --  convert to GLOBAL CURRENCY
(  LINE_TYPE
,  CALENDAR_TYPE_CODE
,  WORKER_ID
,  PROJECT_ID
,  PROJECT_ORG_ID
,  PF_CURRENCY_CODE
,  VERSION_ID
,  PLAN_TYPE_CODE
,  CURRENCY_TYPE
,  PERIOD_ID
,  PERIOD_NAME
,  START_DATE
,  END_DATE
,  REVENUE
,  RAW_COST
,  BURDENED_COST
,  LABOR_HRS
,  TIME_DANGLING_FLAG
,  RATE_DANGLING_FLAG
,  RATE2_DANGLING_FLAG
)
SELECT /*+ ORDERED
           full(rates)   use_hash(rates)   swap_join_inputs(rates)
           full(tmp)     use_hash(tmp)     parallel(tmp)
        */
        'OG'                                              LINE_TYPE
      , tmp.calendar_type_code
      , tmp.worker_id
      , tmp.project_id
      , tmp.project_org_id
      , tmp.pf_currency_code
      , tmp.version_id
      , tmp.plan_type_code
      , 'G'                                               currency_type
      , tmp.period_id
      , tmp.period_name
      , tmp.start_date
      , tmp.end_date
      , round(rates.rate*tmp.revenue/rates.mau)*rates.mau         revenue
      , round(rates.rate*tmp.raw_cost/rates.mau)*rates.mau        raw_cost
      , round(rates.rate*tmp.burdened_cost/rates.mau)*rates.mau   burdened_cost
      , tmp.labor_hrs        labor_hrs
      , tmp.time_dangling_flag
      , case when rates.rate > 0
             then null
             when rates.rate = -3
             then 'U' -- EUR conversion rate for 01-JAN-1999 is missing
             else
           decode(tmp.plan_type_code
            , g_cost_budget_type_code,      decode(g_cost_budget_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            , g_cost_forecast_type_code,    decode(g_cost_forecast_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            , g_revenue_budget_type_code,   decode(g_revenue_budget_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            , g_revenue_forecast_type_code, decode(g_revenue_forecast_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            , g_cost_fp_type_code,          decode(g_cost_budget_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            , g_cost_forecast_fp_type_code, decode(g_cost_forecast_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            , g_rev_fp_type_code,           decode(g_revenue_budget_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            , g_rev_forecast_fp_type_code,  decode(g_revenue_forecast_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            ) end           rate_dangling_flag
      , null                rate2_dangling_flag
FROM
        PJI_FM_AGGR_DLY_RATES  rates
      , PJI_FM_EXTR_PLAN       tmp
where tmp.WORKER_ID = p_worker_id
and   tmp.LINE_TYPE = 'OF'
and   rates.worker_id = -1
and   tmp.pf_currency_code  = rates.pf_currency_code
and   decode(tmp.plan_type_code
       , g_cost_budget_type_code,      decode(g_cost_budget_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       , g_cost_forecast_type_code,    decode(g_cost_forecast_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       , g_revenue_budget_type_code,   decode(g_revenue_budget_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       , g_revenue_forecast_type_code, decode(g_revenue_forecast_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       , g_cost_fp_type_code,          decode(g_cost_budget_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       , g_cost_forecast_fp_type_code, decode(g_cost_forecast_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       , g_rev_fp_type_code,           decode(g_revenue_budget_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       , g_rev_forecast_fp_type_code,  decode(g_revenue_forecast_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       ) = to_date(rates.time_id,'J')
and   tmp.time_dangling_flag is null
and   rates.time_id > 0
;

          PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
          (l_process, 'PJI_FM_PLAN_EXTR.CONVERT_TO_GLOBAL_CURRENCY(p_worker_id);');

commit;

end convert_to_global_currency;



-- -----------------------------------------------------
-- procedure CONVERT_TO_GLOBAL2_CURRENCY
-- -----------------------------------------------------

procedure convert_to_global2_currency(p_worker_id number) is

  l_process varchar2(30);

begin

  l_process   := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
          (l_process,'PJI_FM_PLAN_EXTR.CONVERT_TO_GLOBAL2_CURRENCY(p_worker_id);')) then
    return;
  end if;

-- convert to GLOBAL CURRENCY
Insert /*+ APPEND PARALLEL(plan_i) */ into PJI_FM_EXTR_PLAN plan_i  --  convert to GLOBAL CURRENCY
(  LINE_TYPE
,  CALENDAR_TYPE_CODE
,  WORKER_ID
,  PROJECT_ID
,  PROJECT_ORG_ID
,  PF_CURRENCY_CODE
,  VERSION_ID
,  PLAN_TYPE_CODE
,  CURRENCY_TYPE
,  PERIOD_ID
,  PERIOD_NAME
,  START_DATE
,  END_DATE
,  REVENUE
,  RAW_COST
,  BURDENED_COST
,  LABOR_HRS
,  TIME_DANGLING_FLAG
,  RATE_DANGLING_FLAG
,  RATE2_DANGLING_FLAG
)
SELECT /*+ ORDERED
           full(rates)   use_hash(rates)   swap_join_inputs(rates)
           full(tmp)     use_hash(tmp)     parallel(tmp)
        */
        'OG'                                              LINE_TYPE
      , tmp.calendar_type_code
      , tmp.worker_id
      , tmp.project_id
      , tmp.project_org_id
      , tmp.pf_currency_code
      , tmp.version_id
      , tmp.plan_type_code
      , '2'                                               currency_type
      , tmp.period_id
      , tmp.period_name
      , tmp.start_date
      , tmp.end_date
      , round(rates.rate2*tmp.revenue/rates.mau2)*rates.mau2       revenue
      , round(rates.rate2*tmp.raw_cost/rates.mau2)*rates.mau2      raw_cost
      , round(rates.rate2*tmp.burdened_cost/rates.mau2)*rates.mau2 burdened_cost
      , tmp.labor_hrs        labor_hrs
      , tmp.time_dangling_flag
      , null                 rate_dangling_flag
      , case when rates.rate2 > 0
             then null
             when rates.rate2 = -3
             then 'U' -- EUR conversion rate for 01-JAN-1999 is missing
             else
           decode(tmp.plan_type_code
            , g_cost_budget_type_code,      decode(g_cost_budget_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            , g_cost_forecast_type_code,    decode(g_cost_forecast_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            , g_revenue_budget_type_code,   decode(g_revenue_budget_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            , g_revenue_forecast_type_code, decode(g_revenue_forecast_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            , g_cost_fp_type_code,          decode(g_cost_budget_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            , g_cost_forecast_fp_type_code, decode(g_cost_forecast_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            , g_rev_fp_type_code,           decode(g_revenue_budget_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            , g_rev_forecast_fp_type_code,  decode(g_revenue_forecast_curr_rule
                                              , 'F', 'F'
                                              , 'E')
            ) end           rate2_dangling_flag
FROM
        PJI_FM_AGGR_DLY_RATES  rates
      , PJI_FM_EXTR_PLAN       tmp
where tmp.WORKER_ID = p_worker_id
and   tmp.LINE_TYPE = 'OF'
and   rates.worker_id = -1
and   tmp.pf_currency_code  = rates.pf_currency_code
and   decode(tmp.plan_type_code
       , g_cost_budget_type_code,      decode(g_cost_budget_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       , g_cost_forecast_type_code,    decode(g_cost_forecast_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       , g_revenue_budget_type_code,   decode(g_revenue_budget_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       , g_revenue_forecast_type_code, decode(g_revenue_forecast_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       , g_cost_fp_type_code,          decode(g_cost_budget_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       , g_cost_forecast_fp_type_code, decode(g_cost_forecast_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       , g_rev_fp_type_code,           decode(g_revenue_budget_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       , g_rev_forecast_fp_type_code,  decode(g_revenue_forecast_curr_rule
                                         , 'F', tmp.start_date
                                         , tmp.end_date)
       ) = to_date(rates.time_id,'J')
and   tmp.time_dangling_flag is null
and   rates.time_id > 0
;

          PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
          (l_process, 'PJI_FM_PLAN_EXTR.CONVERT_TO_GLOBAL2_CURRENCY(p_worker_id);');

commit;

end convert_to_global2_currency;



-- -----------------------------------------------------
-- procedure CONVERT_TO_PA_PERIODS
-- -----------------------------------------------------

procedure convert_to_pa_periods(p_worker_id number) is

  l_process varchar2(30);

begin

  l_process   := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
          (l_process,'PJI_FM_PLAN_EXTR.CONVERT_TO_PA_PERIODS(p_worker_id);')) then
    return;
  end if;



if g_pa_period_flag = 'Y' then

-- convert to PA periods
Insert /*+ APPEND PARALLEL(plan_i) */ into PJI_FM_EXTR_PLAN plan_i  --  convert to PA periods
(  LINE_TYPE
,  CALENDAR_TYPE_CODE
,  WORKER_ID
,  PROJECT_ID
,  PROJECT_ORG_ID
,  PF_CURRENCY_CODE
,  VERSION_ID
,  PLAN_TYPE_CODE
,  CURRENCY_TYPE
,  PERIOD_ID
,  PERIOD_NAME
,  START_DATE
,  END_DATE
,  REVENUE
,  RAW_COST
,  BURDENED_COST
,  LABOR_HRS
,  TIME_DANGLING_FLAG
,  RATE_DANGLING_FLAG
,  RATE2_DANGLING_FLAG
)
select /*+ ORDERED
           full(orginfo)   use_hash(orginfo) swap_join_inputs(orginfo)
           full(tmp)       use_hash(tmp)     parallel(tmp)
           full(cal_pa)    use_hash(cal_pa)  swap_join_inputs(cal_pa)
           pq_distribute(cal_pa, none, broadcast)
           pq_distribute(tmp, broadcast, none)
        */
        decode(tmp.LINE_TYPE
         , 'OF', 'CF'
         , 'OG', 'CG'
         )                          LINE_TYPE
      , 'PA'                        calendar_type_code
      , tmp.worker_id
      , tmp.project_id
      , tmp.project_org_id          project_org_id
      , tmp.pf_currency_code        pf_currency_code
      , tmp.version_id
      , tmp.plan_type_code
      , tmp.currency_type           currency_type
      , cal_pa.cal_period_id        period_id
      , cal_pa.name                 period_name
      , cal_pa.start_date           start_date
      , cal_pa.end_date             end_date
      , round((nvl(case when (tmp.start_date <= cal_pa.start_date) and
                             (tmp.end_date >= cal_pa.end_date)
                        then (cal_pa.end_date - cal_pa.start_date + 1) *
                             tmp.revenue / (tmp.end_date - tmp.start_date + 1)
                        when (cal_pa.start_date <= tmp.start_date) and
                             (cal_pa.end_date <= tmp.end_date )
                        then (cal_pa.end_date - tmp.start_date + 1) *
                             tmp.revenue / (tmp.end_date - tmp.start_date + 1)
                        when (cal_pa.start_date >= tmp.start_date) and
                             (cal_pa.end_date >= tmp.end_date)
                        then (tmp.end_date - cal_pa.start_date + 1) *
                             tmp.revenue / (tmp.end_date - tmp.start_date + 1)
                        when (cal_pa.start_date <= tmp.start_date) and
                             (cal_pa.end_date >= tmp.end_date)
                        then tmp.revenue
                        else to_number(null)
                        end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    revenue
      , round((nvl(case when (tmp.start_date <= cal_pa.start_date) and
                             (tmp.end_date >= cal_pa.end_date)
                        then (cal_pa.end_date - cal_pa.start_date + 1) *
                             tmp.raw_cost / (tmp.end_date - tmp.start_date + 1)
                        when (cal_pa.start_date <= tmp.start_date) and
                             (cal_pa.end_date <= tmp.end_date )
                        then (cal_pa.end_date - tmp.start_date + 1) *
                             tmp.raw_cost / (tmp.end_date - tmp.start_date + 1)
                        when (cal_pa.start_date >= tmp.start_date) and
                             (cal_pa.end_date >= tmp.end_date)
                        then (tmp.end_date - cal_pa.start_date + 1) *
                             tmp.raw_cost / (tmp.end_date - tmp.start_date + 1)
                        when (cal_pa.start_date <= tmp.start_date) and
                             (cal_pa.end_date >= tmp.end_date)
                        then tmp.raw_cost
                        else to_number(null)
                        end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    raw_cost
      , round((nvl(case when (tmp.start_date <= cal_pa.start_date) and
                             (tmp.end_date >= cal_pa.end_date)
                        then (cal_pa.end_date - cal_pa.start_date + 1) *
                             tmp.burdened_cost/(tmp.end_date-tmp.start_date +1)
                        when (cal_pa.start_date <= tmp.start_date) and
                             (cal_pa.end_date <= tmp.end_date )
                        then (cal_pa.end_date - tmp.start_date + 1) *
                             tmp.burdened_cost/(tmp.end_date-tmp.start_date +1)
                        when (cal_pa.start_date >= tmp.start_date) and
                             (cal_pa.end_date >= tmp.end_date)
                        then (tmp.end_date - cal_pa.start_date + 1) *
                             tmp.burdened_cost/(tmp.end_date-tmp.start_date +1)
                        when (cal_pa.start_date <= tmp.start_date) and
                             (cal_pa.end_date >= tmp.end_date)
                        then tmp.burdened_cost
                        else to_number(null)
                        end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    burdened_cost
      , round((nvl(case when (tmp.start_date <= cal_pa.start_date) and
                             (tmp.end_date >= cal_pa.end_date)
                        then (cal_pa.end_date - cal_pa.start_date + 1) *
                             tmp.labor_hrs / (tmp.end_date - tmp.start_date +1)
                        when (cal_pa.start_date <= tmp.start_date) and
                             (cal_pa.end_date <= tmp.end_date )
                        then (cal_pa.end_date - tmp.start_date + 1) *
                             tmp.labor_hrs / (tmp.end_date - tmp.start_date +1)
                        when (cal_pa.start_date >= tmp.start_date) and
                             (cal_pa.end_date >= tmp.end_date)
                        then (tmp.end_date - cal_pa.start_date + 1) *
                             tmp.labor_hrs / (tmp.end_date - tmp.start_date +1)
                        when (cal_pa.start_date <= tmp.start_date) and
                             (cal_pa.end_date >= tmp.end_date)
                        then tmp.labor_hrs
                        else to_number(null)
                        end,to_number(null)))/g_labor_mau
          )*g_labor_mau                  labor_hrs
      , decode(sign(to_date(orginfo.pa_calendar_max_date,'J') - cal_pa.end_date)
         , -1, 'P'
         , tmp.time_dangling_flag
         )                              time_dangling_flag
      , tmp.rate_dangling_flag          rate_dangling_flag
      , tmp.rate2_dangling_flag         rate2_dangling_flag
    from
              PJI_ORG_EXTR_INFO      orginfo
            , PJI_FM_EXTR_PLAN           tmp
            , fii_time_cal_period        cal_pa
where tmp.worker_id   =   p_worker_id
and   tmp.end_date    >=  cal_pa.start_date
and   tmp.start_date  <=  cal_pa.end_date
and   tmp.calendar_type_code <> 'PA'
and   orginfo.pa_calendar_id = cal_pa.calendar_id
and   orginfo.org_id = tmp.project_org_id
and   tmp.LINE_TYPE in ( 'OF' , 'OG' )
and   tmp.time_dangling_flag is null
and   tmp.rate_dangling_flag is null
and   tmp.rate2_dangling_flag is null
;

end if;

          PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
          (l_process, 'PJI_FM_PLAN_EXTR.CONVERT_TO_PA_PERIODS(p_worker_id);');

commit;

end convert_to_pa_periods;



-- -----------------------------------------------------
-- procedure CONVERT_TO_GL_PERIODS
-- -----------------------------------------------------

procedure convert_to_gl_periods(p_worker_id number) is

  l_process varchar2(30);

begin

  l_process   := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
          (l_process,'PJI_FM_PLAN_EXTR.CONVERT_TO_GL_PERIODS(p_worker_id);')) then
    return;
  end if;



if g_gl_period_flag = 'Y' then

-- convert to GL periods
Insert /*+ APPEND PARALLEL(plan_i) */ into PJI_FM_EXTR_PLAN plan_i  --  convert to GL periods
(  LINE_TYPE
,  CALENDAR_TYPE_CODE
,  WORKER_ID
,  PROJECT_ID
,  PROJECT_ORG_ID
,  PF_CURRENCY_CODE
,  VERSION_ID
,  PLAN_TYPE_CODE
,  CURRENCY_TYPE
,  PERIOD_ID
,  PERIOD_NAME
,  START_DATE
,  END_DATE
,  REVENUE
,  RAW_COST
,  BURDENED_COST
,  LABOR_HRS
,  TIME_DANGLING_FLAG
,  RATE_DANGLING_FLAG
,  RATE2_DANGLING_FLAG
)
select /*+ ORDERED
           full(orginfo)   use_hash(orginfo) swap_join_inputs(orginfo)
           full(tmp)       use_hash(tmp)     parallel(tmp)
           full(cal_gl)    use_hash(cal_gl)  swap_join_inputs(cal_gl)
           pq_distribute(cal_gl, none, broadcast)
           pq_distribute(tmp, broadcast, none)
        */
        decode(tmp.LINE_TYPE
         , 'OF', 'CF'
         , 'OG', 'CG'
         )                          LINE_TYPE
      , 'GL'                        calendar_type_code
      , tmp.worker_id
      , tmp.project_id
      , tmp.project_org_id          project_org_id
      , tmp.pf_currency_code        pf_currency_code
      , tmp.version_id
      , tmp.plan_type_code
      , tmp.currency_type           currency_type
      , cal_gl.cal_period_id        period_id
      , cal_gl.name                 period_name
      , cal_gl.start_date           start_date
      , cal_gl.end_date             end_date
      , round((nvl(case when (tmp.start_date <= cal_gl.start_date) and
                             (tmp.end_date >= cal_gl.end_date)
                        then (cal_gl.end_date - cal_gl.start_date + 1) *
                             tmp.revenue / (tmp.end_date - tmp.start_date + 1)
                        when (cal_gl.start_date <= tmp.start_date) and
                             (cal_gl.end_date <= tmp.end_date )
                        then (cal_gl.end_date - tmp.start_date + 1) *
                             tmp.revenue / (tmp.end_date - tmp.start_date + 1)
                        when (cal_gl.start_date >= tmp.start_date) and
                             (cal_gl.end_date >= tmp.end_date)
                        then (tmp.end_date - cal_gl.start_date + 1) *
                             tmp.revenue / (tmp.end_date - tmp.start_date + 1)
                        when (cal_gl.start_date <= tmp.start_date) and
                             (cal_gl.end_date >= tmp.end_date)
                        then tmp.revenue
                        else to_number(null)
                        end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    revenue
      , round((nvl(case when (tmp.start_date <= cal_gl.start_date) and
                             (tmp.end_date >= cal_gl.end_date)
                        then (cal_gl.end_date - cal_gl.start_date + 1) *
                             tmp.raw_cost / (tmp.end_date - tmp.start_date + 1)
                        when (cal_gl.start_date <= tmp.start_date) and
                             (cal_gl.end_date <= tmp.end_date )
                        then (cal_gl.end_date - tmp.start_date + 1) *
                             tmp.raw_cost / (tmp.end_date - tmp.start_date + 1)
                        when (cal_gl.start_date >= tmp.start_date) and
                             (cal_gl.end_date >= tmp.end_date)
                        then (tmp.end_date - cal_gl.start_date + 1) *
                             tmp.raw_cost / (tmp.end_date - tmp.start_date + 1)
                        when (cal_gl.start_date <= tmp.start_date) and
                             (cal_gl.end_date >= tmp.end_date)
                        then tmp.raw_cost
                        else to_number(null)
                        end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    raw_cost
      , round((nvl(case when (tmp.start_date <= cal_gl.start_date) and
                             (tmp.end_date >= cal_gl.end_date)
                        then (cal_gl.end_date - cal_gl.start_date + 1) *
                             tmp.burdened_cost/(tmp.end_date-tmp.start_date +1)
                        when (cal_gl.start_date <= tmp.start_date) and
                             (cal_gl.end_date <= tmp.end_date )
                        then (cal_gl.end_date - tmp.start_date + 1) *
                             tmp.burdened_cost/(tmp.end_date-tmp.start_date +1)
                        when (cal_gl.start_date >= tmp.start_date) and
                             (cal_gl.end_date >= tmp.end_date)
                        then (tmp.end_date - cal_gl.start_date + 1) *
                             tmp.burdened_cost/(tmp.end_date-tmp.start_date +1)
                        when (cal_gl.start_date <= tmp.start_date) and
                             (cal_gl.end_date >= tmp.end_date)
                        then tmp.burdened_cost
                        else to_number(null)
                        end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    burdened_cost
      , round((nvl(case when (tmp.start_date <= cal_gl.start_date) and
                             (tmp.end_date >= cal_gl.end_date)
                        then (cal_gl.end_date - cal_gl.start_date + 1) *
                             tmp.labor_hrs / (tmp.end_date - tmp.start_date +1)
                        when (cal_gl.start_date <= tmp.start_date) and
                             (cal_gl.end_date <= tmp.end_date )
                        then (cal_gl.end_date - tmp.start_date + 1) *
                             tmp.labor_hrs / (tmp.end_date - tmp.start_date +1)
                        when (cal_gl.start_date >= tmp.start_date) and
                             (cal_gl.end_date >= tmp.end_date)
                        then (tmp.end_date - cal_gl.start_date + 1) *
                             tmp.labor_hrs / (tmp.end_date - tmp.start_date +1)
                        when (cal_gl.start_date <= tmp.start_date) and
                             (cal_gl.end_date >= tmp.end_date)
                        then tmp.labor_hrs
                        else to_number(null)
                        end,to_number(null)))/g_labor_mau
          )*g_labor_mau                  labor_hrs
      , decode(sign(to_date(orginfo.gl_calendar_max_date,'J') - cal_gl.end_date)
         , -1, 'G'
         , tmp.time_dangling_flag
         )                              time_dangling_flag
      , tmp.rate_dangling_flag          rate_dangling_flag
      , tmp.rate2_dangling_flag         rate2_dangling_flag
    from
              PJI_ORG_EXTR_INFO      orginfo
            , PJI_FM_EXTR_PLAN           tmp
            , fii_time_cal_period        cal_gl
where tmp.worker_id   =   p_worker_id
and   tmp.end_date    >=  cal_gl.start_date
and   tmp.start_date  <=  cal_gl.end_date
and   tmp.calendar_type_code <> 'GL'
and   orginfo.gl_calendar_id = cal_gl.calendar_id
and   orginfo.org_id = tmp.project_org_id
and   tmp.LINE_TYPE in ( 'OF' , 'OG' )
and   tmp.time_dangling_flag is null
and   tmp.rate_dangling_flag is null
and   tmp.rate2_dangling_flag is null
;

end if;

          PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
          (l_process, 'PJI_FM_PLAN_EXTR.CONVERT_TO_GL_PERIODS(p_worker_id);');

commit;

end convert_to_gl_periods;



-- -----------------------------------------------------
-- procedure CONVERT_TO_ENT_PERIODS
-- -----------------------------------------------------

procedure convert_to_ent_periods(p_worker_id number) is

  l_process varchar2(30);

begin

  l_process   := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
          (l_process,'PJI_FM_PLAN_EXTR.CONVERT_TO_ENT_PERIODS(p_worker_id);')) then
    return;
  end if;


-- convert to ENT periods
Insert /*+ APPEND PARALLEL(plan_i) */ into PJI_FM_EXTR_PLAN plan_i  --  convert to ENT periods
(  LINE_TYPE
,  CALENDAR_TYPE_CODE
,  WORKER_ID
,  PROJECT_ID
,  PROJECT_ORG_ID
,  PF_CURRENCY_CODE
,  VERSION_ID
,  PLAN_TYPE_CODE
,  CURRENCY_TYPE
,  PERIOD_ID
,  PERIOD_NAME
,  START_DATE
,  END_DATE
,  REVENUE
,  RAW_COST
,  BURDENED_COST
,  LABOR_HRS
,  TIME_DANGLING_FLAG
,  RATE_DANGLING_FLAG
,  RATE2_DANGLING_FLAG
)
select /*+ ORDERED
           full(orginfo)  use_hash(orginfo) swap_join_inputs(orginfo)
           full(tmp)      use_hash(tmp)     parallel(tmp)
           cache(ent)
           pq_distribute(tmp, broadcast, none)
        */
      decode(tmp.LINE_TYPE
         , 'OF', 'CF'
         , 'OG', 'CG'
         )                          LINE_TYPE
      , 'ENT'                       calendar_type_code
      , tmp.worker_id
      , tmp.project_id
      , tmp.project_org_id
      , tmp.pf_currency_code
      , tmp.version_id
      , tmp.plan_type_code
      , tmp.currency_type           currency_type
      , ent.ent_period_id           period_id
      , ent.name                    period_name
      , ent.start_date              start_date
      , ent.end_date                end_date
      , round((nvl(case when (tmp.start_date <= ent.start_date) and
                             (tmp.end_date >= ent.end_date)
                        then (ent.end_date - ent.start_date + 1) *
                             tmp.revenue / (tmp.end_date - tmp.start_date + 1)
                        when (ent.start_date <= tmp.start_date) and
                             (ent.end_date <= tmp.end_date )
                        then (ent.end_date - tmp.start_date + 1) *
                             tmp.revenue / (tmp.end_date - tmp.start_date + 1)
                        when (ent.start_date >= tmp.start_date) and
                             (ent.end_date >= tmp.end_date)
                        then (tmp.end_date - ent.start_date + 1) *
                             tmp.revenue / (tmp.end_date - tmp.start_date + 1)
                        when (ent.start_date <= tmp.start_date) and
                             (ent.end_date >= tmp.end_date)
                        then tmp.revenue
                        else to_number(null)
                        end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    revenue
      , round((nvl(case when (tmp.start_date <= ent.start_date) and
                             (tmp.end_date >= ent.end_date)
                        then (ent.end_date - ent.start_date + 1) *
                             tmp.raw_cost / (tmp.end_date - tmp.start_date + 1)
                        when (ent.start_date <= tmp.start_date) and
                             (ent.end_date <= tmp.end_date )
                        then (ent.end_date - tmp.start_date + 1) *
                             tmp.raw_cost / (tmp.end_date - tmp.start_date + 1)
                        when (ent.start_date >= tmp.start_date) and
                             (ent.end_date >= tmp.end_date)
                        then (tmp.end_date - ent.start_date + 1) *
                             tmp.raw_cost / (tmp.end_date - tmp.start_date + 1)
                        when (ent.start_date <= tmp.start_date) and
                             (ent.end_date >= tmp.end_date)
                        then tmp.raw_cost
                        else to_number(null)
                        end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    raw_cost
      , round((nvl(case when (tmp.start_date <= ent.start_date) and
                             (tmp.end_date >= ent.end_date)
                        then (ent.end_date - ent.start_date + 1) *
                             tmp.burdened_cost/(tmp.end_date-tmp.start_date +1)
                        when (ent.start_date <= tmp.start_date) and
                             (ent.end_date <= tmp.end_date )
                        then (ent.end_date - tmp.start_date + 1) *
                             tmp.burdened_cost/(tmp.end_date-tmp.start_date +1)
                        when (ent.start_date >= tmp.start_date) and
                             (ent.end_date >= tmp.end_date)
                        then (tmp.end_date - ent.start_date + 1) *
                             tmp.burdened_cost/(tmp.end_date-tmp.start_date +1)
                        when (ent.start_date <= tmp.start_date) and
                             (ent.end_date >= tmp.end_date)
                        then tmp.burdened_cost
                        else to_number(null)
                        end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    burdened_cost
      , round((nvl(case when (tmp.start_date <= ent.start_date) and
                             (tmp.end_date >= ent.end_date)
                        then (ent.end_date - ent.start_date + 1) *
                             tmp.labor_hrs / (tmp.end_date - tmp.start_date +1)
                        when (ent.start_date <= tmp.start_date) and
                             (ent.end_date <= tmp.end_date )
                        then (ent.end_date - tmp.start_date + 1) *
                             tmp.labor_hrs / (tmp.end_date - tmp.start_date +1)
                        when (ent.start_date >= tmp.start_date) and
                             (ent.end_date >= tmp.end_date)
                        then (tmp.end_date - ent.start_date + 1) *
                             tmp.labor_hrs / (tmp.end_date - tmp.start_date +1)
                        when (ent.start_date <= tmp.start_date) and
                             (ent.end_date >= tmp.end_date)
                        then tmp.labor_hrs
                        else to_number(null)
                        end,to_number(null)))/g_labor_mau
          )*g_labor_mau                  labor_hrs
      , decode(sign(to_date(orginfo.en_calendar_max_date,'J') - ent.end_date)
         , -1, 'G'
         , tmp.time_dangling_flag
         )                              time_dangling_flag
      , tmp.rate_dangling_flag          rate_dangling_flag
      , tmp.rate2_dangling_flag         rate2_dangling_flag
    from
              PJI_ORG_EXTR_INFO      orginfo
            , PJI_FM_EXTR_PLAN           tmp
            , fii_time_ent_period        ent
where tmp.worker_id   =   p_worker_id
and   tmp.end_date    >=  ent.start_date
and   tmp.start_date  <=  ent.end_date
and   tmp.calendar_type_code <> 'ENT'
and   tmp.LINE_TYPE in ( 'OF' , 'OG' )
and   tmp.project_org_id   =  orginfo.org_id
and   tmp.time_dangling_flag is null
and   tmp.rate_dangling_flag is null
and   tmp.rate2_dangling_flag is null
;

          PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
          (l_process, 'PJI_FM_PLAN_EXTR.CONVERT_TO_ENT_PERIODS(p_worker_id);');

commit;

end convert_to_ent_periods;



-- -----------------------------------------------------
-- procedure CONVERT_TO_ENTW_PERIODS
-- -----------------------------------------------------

procedure convert_to_entw_periods(p_worker_id number) is

  l_process varchar2(30);

begin

  l_process   := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
          (l_process,'PJI_FM_PLAN_EXTR.CONVERT_TO_ENTW_PERIODS(p_worker_id);')) then
    return;
  end if;


-- convert to ENTW periods
Insert /*+ APPEND PARALLEL(plan_i) */ into PJI_FM_EXTR_PLAN plan_i  --  convert to ENTW periods
(  LINE_TYPE
,  CALENDAR_TYPE_CODE
,  WORKER_ID
,  PROJECT_ID
,  PROJECT_ORG_ID
,  PF_CURRENCY_CODE
,  VERSION_ID
,  PLAN_TYPE_CODE
,  CURRENCY_TYPE
,  PERIOD_ID
,  PERIOD_NAME
,  START_DATE
,  END_DATE
,  REVENUE
,  RAW_COST
,  BURDENED_COST
,  LABOR_HRS
,  TIME_DANGLING_FLAG
,  RATE_DANGLING_FLAG
,  RATE2_DANGLING_FLAG
)
select /*+ ORDERED
           full(orginfo)  use_hash(orginfo)  swap_join_inputs(orginfo)
           full(tmp)      use_hash(tmp)      parallel(tmp)
           cache(entw)
           pq_distribute(tmp, broadcast, none)
        */
      decode(tmp.LINE_TYPE
         , 'OF', 'CF'
         , 'OG', 'CG'
         )                          LINE_TYPE
      , 'ENTW'                      calendar_type_code
      , tmp.worker_id
      , tmp.project_id
      , tmp.project_org_id
      , tmp.pf_currency_code
      , tmp.version_id
      , tmp.plan_type_code
      , tmp.currency_type           currency_type
      , entw.week_id                period_id
      , PJI_RM_SUM_MAIN.g_null      period_name
      , entw.start_date             start_date
      , entw.end_date               end_date
      , round((nvl(case when (tmp.start_date <= entw.start_date) and
                             (tmp.end_date >= entw.end_date)
                        then (entw.end_date - entw.start_date + 1) *
                             tmp.revenue / (tmp.end_date - tmp.start_date + 1)
                        when (entw.start_date <= tmp.start_date) and
                             (entw.end_date <= tmp.end_date )
                        then (entw.end_date - tmp.start_date + 1) *
                             tmp.revenue / (tmp.end_date - tmp.start_date + 1)
                        when (entw.start_date >= tmp.start_date) and
                             (entw.end_date >= tmp.end_date)
                        then (tmp.end_date - entw.start_date + 1) *
                             tmp.revenue / (tmp.end_date - tmp.start_date + 1)
                        when (entw.start_date <= tmp.start_date) and
                             (entw.end_date >= tmp.end_date)
                        then tmp.revenue
                        else to_number(null)
                        end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    revenue
      , round((nvl(case when (tmp.start_date <= entw.start_date) and
                             (tmp.end_date >= entw.end_date)
                        then (entw.end_date - entw.start_date + 1) *
                             tmp.raw_cost / (tmp.end_date - tmp.start_date + 1)
                        when (entw.start_date <= tmp.start_date) and
                             (entw.end_date <= tmp.end_date )
                        then (entw.end_date - tmp.start_date + 1) *
                             tmp.raw_cost / (tmp.end_date - tmp.start_date + 1)
                        when (entw.start_date >= tmp.start_date) and
                             (entw.end_date >= tmp.end_date)
                        then (tmp.end_date - entw.start_date + 1) *
                             tmp.raw_cost / (tmp.end_date - tmp.start_date + 1)
                        when (entw.start_date <= tmp.start_date) and
                             (entw.end_date >= tmp.end_date)
                        then tmp.raw_cost
                        else to_number(null)
                        end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    raw_cost
      , round((nvl(case when (tmp.start_date <= entw.start_date) and
                             (tmp.end_date >= entw.end_date)
                        then (entw.end_date - entw.start_date + 1) *
                             tmp.burdened_cost/(tmp.end_date-tmp.start_date +1)
                        when (entw.start_date <= tmp.start_date) and
                             (entw.end_date <= tmp.end_date )
                        then (entw.end_date - tmp.start_date + 1) *
                             tmp.burdened_cost/(tmp.end_date-tmp.start_date +1)
                        when (entw.start_date >= tmp.start_date) and
                             (entw.end_date >= tmp.end_date)
                        then (tmp.end_date - entw.start_date + 1) *
                             tmp.burdened_cost/(tmp.end_date-tmp.start_date +1)
                        when (entw.start_date <= tmp.start_date) and
                             (entw.end_date >= tmp.end_date)
                        then tmp.burdened_cost
                        else to_number(null)
                        end,to_number(null)))/orginfo.projfunc_currency_mau
          )*orginfo.projfunc_currency_mau    burdened_cost
      , round((nvl(case when (tmp.start_date <= entw.start_date) and
                             (tmp.end_date >= entw.end_date)
                        then (entw.end_date - entw.start_date + 1) *
                             tmp.labor_hrs / (tmp.end_date - tmp.start_date +1)
                        when (entw.start_date <= tmp.start_date) and
                             (entw.end_date <= tmp.end_date )
                        then (entw.end_date - tmp.start_date + 1) *
                             tmp.labor_hrs / (tmp.end_date - tmp.start_date +1)
                        when (entw.start_date >= tmp.start_date) and
                             (entw.end_date >= tmp.end_date)
                        then (tmp.end_date - entw.start_date + 1) *
                             tmp.labor_hrs / (tmp.end_date - tmp.start_date +1)
                        when (entw.start_date <= tmp.start_date) and
                             (entw.end_date >= tmp.end_date)
                        then tmp.labor_hrs
                        else to_number(null)
                        end,to_number(null)))/g_labor_mau
          )*g_labor_mau                  labor_hrs
      , decode(sign(to_date(orginfo.en_calendar_max_date,'J') - entw.end_date)
         , -1, 'G'
         , tmp.time_dangling_flag
         )                              time_dangling_flag
      , tmp.rate_dangling_flag          rate_dangling_flag
      , tmp.rate2_dangling_flag         rate2_dangling_flag
    from
              PJI_ORG_EXTR_INFO      orginfo
            , PJI_FM_EXTR_PLAN           tmp
            , fii_time_week              entw
where tmp.worker_id   =   p_worker_id
and   tmp.end_date    >=  entw.start_date
and   tmp.start_date  <=  entw.end_date
and   tmp.calendar_type_code <> 'ENTW'
and   tmp.LINE_TYPE in ( 'OF' , 'OG' )
and   tmp.project_org_id   =  orginfo.org_id
and   tmp.time_dangling_flag is null
and   tmp.rate_dangling_flag is null
and   tmp.rate2_dangling_flag is null
;

          PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
          (l_process, 'PJI_FM_PLAN_EXTR.CONVERT_TO_ENTW_PERIODS(p_worker_id);');

commit;

end convert_to_entw_periods;



-- -----------------------------------------------------
-- procedure DANGLING_PLAN_VERSIONS
-- -----------------------------------------------------

procedure dangling_plan_versions(p_worker_id number) is

  l_process varchar2(30);

begin

  l_process   := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
          (l_process,'PJI_FM_PLAN_EXTR.DANGLING_PLAN_VERSIONS(p_worker_id);')) then
    return;
  end if;


Insert /*+ APPEND */ into PJI_FM_EXTR_PLN_LOG
(PROJECT_ID
,PROJECT_ORG_ID
,PLAN_TYPE_CODE
,BUDGET_VERSION_ID
,RECORD_TYPE_CODE
,FROM_DATE
,TO_DATE
,CALENDAR_ID
)
select /*+  ORDERED
            full(orginfo)  use_hash(orginfo)  swap_join_inputs(orginfo)
            full(tmp)      use_hash(tmp)      parallel(tmp)
        */
  tmp.PROJECT_ID
, tmp.PROJECT_ORG_ID
, tmp.PLAN_TYPE_CODE
, tmp.VERSION_ID
, to_char(decode(tmp.RATE_DANGLING_FLAG,
                 'U',  1, 0) +              -- EUR rate for 01-JAN-1999 missing
          decode(tmp.RATE2_DANGLING_FLAG,
                 'U',  2, 0) +              -- EUR rate for 01-JAN-1999 missing
          decode(tmp.RATE_DANGLING_FLAG,
                 null, 0, 4) +              -- Global 1 rate missing
          decode(tmp.RATE2_DANGLING_FLAG,
                 null, 0, 8) +              -- Global 2 rate missing
          decode(tmp.TIME_DANGLING_FLAG,
                 null, 0, 16)               -- Calendar setup missing
         ) RECORD_TYPE_CODE
, tmp.START_DATE
, tmp.END_DATE
, decode(tmp.CALENDAR_TYPE_CODE
   , 'PA', orginfo.PA_CALENDAR_ID
   , 'GL', orginfo.GL_CALENDAR_ID
   , null)                         CALENDAR_ID
from    PJI_ORG_EXTR_INFO   orginfo
        , PJI_FM_EXTR_PLAN  tmp
where tmp.WORKER_ID = p_worker_id
and  (   tmp.TIME_DANGLING_FLAG is not null
         or tmp.RATE_DANGLING_FLAG is not null
         or tmp.RATE2_DANGLING_FLAG is not null)
and     tmp.project_org_id = orginfo.org_id
;

          PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
          (l_process, 'PJI_FM_PLAN_EXTR.DANGLING_PLAN_VERSIONS(p_worker_id);');

commit;

end dangling_plan_versions;



-- -----------------------------------------------------
-- procedure SUMMARIZE_EXTRACT
-- -----------------------------------------------------

procedure summarize_extract(p_worker_id number) is

  l_process           varchar2(30);

  l_txn_currency_flag varchar2(1);
  l_g2_currency_flag  varchar2(1);

  l_g1_currency_code  varchar2(30);
  l_g2_currency_code  varchar2(30);


begin

  l_process   := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
          (l_process,'PJI_FM_PLAN_EXTR.SUMMARIZE_EXTRACT(p_worker_id);')) then
    return;
  end if;

  select
    TXN_CURR_FLAG,
    GLOBAL_CURR2_FLAG
  into
    l_txn_currency_flag,
    l_g2_currency_flag
  from
    PJI_SYSTEM_SETTINGS;

  l_g1_currency_code := PJI_UTILS.GET_GLOBAL_PRIMARY_CURRENCY;
  l_g2_currency_code := PJI_UTILS.GET_GLOBAL_SECONDARY_CURRENCY;

  insert /*+ append parallel(pln_i) */ into PJI_FM_AGGR_PLN pln_i
  (
    WORKER_ID,
    PROJECT_ID,
    PROJECT_ORG_ID,
    PROJECT_ORGANIZATION_ID,
    PROJECT_TYPE_CLASS,
    CALENDAR_TYPE_CODE,
    CURR_RECORD_TYPE_ID,
    CURRENCY_CODE,
    TIME_PHASED_TYPE_CODE,
    TIME_ID,
    PERIOD_NAME,
    START_DATE,
    END_DATE,
    CURR_BGT_REVENUE,
    CURR_BGT_RAW_COST,
    CURR_BGT_BRDN_COST,
    CURR_BGT_LABOR_HRS,
    CURR_ORIG_BGT_REVENUE,
    CURR_ORIG_BGT_RAW_COST,
    CURR_ORIG_BGT_BRDN_COST,
    CURR_ORIG_BGT_LABOR_HRS,
    CURR_FORECAST_REVENUE,
    CURR_FORECAST_RAW_COST,
    CURR_FORECAST_BRDN_COST,
    CURR_FORECAST_LABOR_HRS
  )
  select
    tmp1.WORKER_ID,
    tmp1.PROJECT_ID,
    tmp1.PROJECT_ORG_ID,
    tmp1.PROJECT_ORGANIZATION_ID,
    tmp1.PROJECT_TYPE_CLASS,
    tmp1.CALENDAR_TYPE_CODE,
    sum(tmp1.CURR_RECORD_TYPE_ID)       CURR_RECORD_TYPE_ID,
    nvl(tmp1.CURRENCY_CODE, 'PJI$NULL') CURRENCY_CODE,
    tmp1.TIME_PHASED_TYPE_CODE,
    tmp1.PERIOD_ID,
    tmp1.PERIOD_NAME,
    tmp1.START_DATE,
    tmp1.END_DATE,
    max(tmp1.CURR_BGT_REVENUE)          CURR_BGT_REVENUE,
    max(tmp1.CURR_BGT_RAW_COST)         CURR_BGT_RAW_COST,
    max(tmp1.CURR_BGT_BRDN_COST)        CURR_BGT_BRDN_COST,
    max(tmp1.CURR_BGT_LABOR_HRS)        CURR_BGT_LABOR_HRS,
    max(tmp1.CURR_ORIG_BGT_REVENUE)     CURR_ORIG_BGT_REVENUE,
    max(tmp1.CURR_ORIG_BGT_RAW_COST)    CURR_ORIG_BGT_RAW_COST,
    max(tmp1.CURR_ORIG_BGT_BRDN_COST)   CURR_ORIG_BGT_BRDN_COST,
    max(tmp1.CURR_ORIG_BGT_LABOR_HRS)   CURR_ORIG_BGT_LABOR_HRS,
    max(tmp1.CURR_FORECAST_REVENUE)     CURR_FORECAST_REVENUE,
    max(tmp1.CURR_FORECAST_RAW_COST)    CURR_FORECAST_RAW_COST,
    max(tmp1.CURR_FORECAST_BRDN_COST)   CURR_FORECAST_BRDN_COST,
    max(tmp1.CURR_FORECAST_LABOR_HRS)   CURR_FORECAST_LABOR_HRS
  from
    (
    select /*+ ordered
               full(vers) use_hash(vers) swap_join_inputs(vers)
               full(tmp)  use_hash(tmp)  parallel(tmp) */
      tmp.worker_id,
      tmp.project_id,
      tmp.project_org_id,
      vers.project_organization_id,
      vers.project_type_class,
      tmp.calendar_type_code,
      decode(tmp.currency_type,
               'G', 1,
               '2', 2,
               'F', 4)                         curr_record_type_id,
      decode(tmp.currency_type,
               'G', l_g1_currency_code,
               '2', l_g2_currency_code,
               'F', tmp.pf_currency_code) currency_code,
      vers.time_phased_type_code,
      tmp.period_id,
      tmp.period_name,
      tmp.start_date,
      tmp.end_date,
      sum(decode(tmp.plan_type_code,
                 g_revenue_budget_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.revenue,
                             to_number(null)),
                 g_rev_fp_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.revenue,
                             to_number(null)),
                 to_number(null)))              curr_bgt_revenue,
      sum(decode(tmp.plan_type_code,
                 g_cost_budget_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.raw_cost,
                             to_number(null)),
                 g_cost_fp_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.raw_cost,
                             to_number(null)),
                 to_number(null)))              curr_bgt_raw_cost,
      sum(decode(tmp.plan_type_code,
                 g_cost_budget_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.burdened_cost,
                             to_number(null)),
                 g_cost_fp_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.burdened_cost,
                             to_number(null)),
                 to_number(null)))              curr_bgt_brdn_cost,
      sum(decode(tmp.plan_type_code,
                 g_cost_budget_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.labor_hrs,
                             to_number(null)),
                 g_cost_fp_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.labor_hrs,
                             to_number(null)),
                 to_number(null)))              curr_bgt_labor_hrs,
      sum(decode(tmp.plan_type_code,
                 g_revenue_budget_type_code,
                 decode(vers.current_original_flag,
                        'Y', tmp.revenue,
                             to_number(null)),
                 g_rev_fp_type_code,
                 decode(vers.current_original_flag,
                        'Y', tmp.revenue,
                             to_number(null)),
                 to_number(null)))              curr_orig_bgt_revenue,
      sum(decode(tmp.plan_type_code,
                 g_cost_budget_type_code,
                 decode(vers.current_original_flag,
                        'Y', tmp.raw_cost,
                             to_number(null)),
                 g_cost_fp_type_code,
                 decode(vers.current_original_flag,
                        'Y', tmp.raw_cost,
                             to_number(null)),
                 to_number(null)))              curr_orig_bgt_raw_cost,
      sum(decode(tmp.plan_type_code,
                 g_cost_budget_type_code,
                 decode(vers.current_original_flag,
                        'Y', tmp.burdened_cost,
                             to_number(null)),
                 g_cost_fp_type_code,
                 decode(vers.current_original_flag,
                        'Y', tmp.burdened_cost,
                             to_number(null)),
                 to_number(null)))              curr_orig_bgt_brdn_cost,
      sum(decode(tmp.plan_type_code,
                 g_cost_budget_type_code,
                 decode(vers.current_original_flag,
                        'Y', tmp.labor_hrs,
                             to_number(null)),
                 g_cost_fp_type_code,
                 decode(vers.current_original_flag,
                        'Y', tmp.labor_hrs,
                             to_number(null)),
                 to_number(null)))              curr_orig_bgt_labor_hrs,
      sum(decode(tmp.plan_type_code,
                 g_revenue_forecast_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.revenue,
                             to_number(null)),
                 g_rev_forecast_fp_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.revenue,
                             to_number(null)),
                 to_number(null)))              curr_forecast_revenue,
      sum(decode(tmp.plan_type_code,
                 g_cost_forecast_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.raw_cost,
                             to_number(null)),
                 g_cost_forecast_fp_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.raw_cost,
                             to_number(null)),
                 to_number(null)))              curr_forecast_raw_cost,
      sum(decode(tmp.plan_type_code,
                 g_cost_forecast_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.burdened_cost,
                             to_number(null)),
                 g_cost_forecast_fp_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.burdened_cost,
                             to_number(null)),
                 to_number(null)))              curr_forecast_brdn_cost,
      sum(decode(tmp.plan_type_code,
                 g_cost_forecast_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.labor_hrs,
                             to_number(null)),
                 g_cost_forecast_fp_type_code,
                 decode(vers.current_flag,
                        'Y', tmp.labor_hrs,
                             to_number(null)),
                 to_number(null)))              curr_forecast_labor_hrs
    from
      PJI_FM_EXTR_PLNVER1 vers,
      PJI_FM_EXTR_PLAN    tmp,
      PJI_FM_EXTR_PLN_LOG log
    where
      tmp.WORKER_ID                      =  p_worker_id               and
      tmp.LINE_TYPE                      <> 'F1'                      and
      vers.WORKER_ID                     =  p_worker_id               and
      tmp.project_id                     =  vers.project_id           and
      tmp.version_id                     =  vers.version_id           and
      decode(nvl(g_gl_period_flag, 'N'),
             'Y', 'ZZ', 'GL')            <> tmp.calendar_type_code    and
      decode(nvl(g_pa_period_flag, 'N'),
             'Y', 'ZZ', 'PA')            <> tmp.calendar_type_code    and
      tmp.version_id                     =  log.budget_version_id (+) and
      log.budget_version_id              is null
    group by
      tmp.worker_id,
      tmp.project_id,
      tmp.project_org_id,
      vers.project_organization_id,
      vers.project_type_class,
      tmp.calendar_type_code,
      decode(tmp.currency_type,
               'G', 1,
               '2', 2,
               'F', 4),
      decode(tmp.currency_type,
               'G', l_g1_currency_code,
               '2', l_g2_currency_code,
               'F', tmp.pf_currency_code),
      vers.time_phased_type_code,
      tmp.period_id,
      tmp.period_name,
      tmp.start_date,
      tmp.end_date
    ) tmp1
  group by
    tmp1.WORKER_ID,
    tmp1.PROJECT_ID,
    tmp1.PROJECT_ORG_ID,
    tmp1.PROJECT_ORGANIZATION_ID,
    tmp1.PROJECT_TYPE_CLASS,
    tmp1.CALENDAR_TYPE_CODE,
    nvl(tmp1.CURRENCY_CODE, 'PJI$NULL'),
    tmp1.TIME_PHASED_TYPE_CODE,
    tmp1.PERIOD_ID,
    tmp1.PERIOD_NAME,
    tmp1.START_DATE,
    tmp1.END_DATE;

  PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (l_process, 'PJI_FM_PLAN_EXTR.SUMMARIZE_EXTRACT(p_worker_id);');

  commit;

end summarize_extract;



-- -----------------------------------------------------
-- procedure EXTRACT_UPDATED_VERSIONS
-- -----------------------------------------------------

procedure extract_updated_versions(p_worker_id number) is

  l_process varchar2(30);

begin

  l_process   := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

  if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
          (l_process,'PJI_FM_PLAN_EXTR.EXTRACT_UPDATED_VERSIONS(p_worker_id);')) then
    return;
  end if;

    Insert /*+ APPEND */ into PJI_FM_EXTR_PLNVER2
    (
      WORKER_ID,
      BATCH_MAP_ROWID,
      PROJECT_ID,
      COST_BUDGET_C_VERSION,
      COST_BUDGET_CO_VERSION,
      REVENUE_BUDGET_C_VERSION,
      REVENUE_BUDGET_CO_VERSION,
      COST_FORECAST_C_VERSION,
      REVENUE_FORECAST_C_VERSION,
      BATCH_ID
    )
    select   p_worker_id
           , tmp.batch_map_rowid
           , tmp.project_id
           , tmp.COST_BUDGET_C_VERSION
           , tmp.COST_BUDGET_CO_VERSION
           , tmp.REVENUE_BUDGET_C_VERSION
           , tmp.REVENUE_BUDGET_CO_VERSION
           , tmp.COST_FORECAST_C_VERSION
           , tmp.REVENUE_FORECAST_C_VERSION
           , ceil(ROWNUM / PJI_RM_SUM_MAIN.g_commit_threshold)
    from
       (
        SELECT  tmp.BATCH_MAP_ROWID                   BATCH_MAP_ROWID
                , tmp.PROJECT_ID                      PROJECT_ID
                , max(tmp.COST_BUDGET_C_VERSION)      COST_BUDGET_C_VERSION
                , max(tmp.COST_BUDGET_CO_VERSION)     COST_BUDGET_CO_VERSION
                , max(tmp.REVENUE_BUDGET_C_VERSION)   REVENUE_BUDGET_C_VERSION
                , max(tmp.REVENUE_BUDGET_CO_VERSION)  REVENUE_BUDGET_CO_VERSION
                , max(tmp.COST_FORECAST_C_VERSION)    COST_FORECAST_C_VERSION
                , max(tmp.REVENUE_FORECAST_C_VERSION) REVENUE_FORECAST_C_VERSION
        FROM
            (
               select  /*+ ORDERED
                    full(bvs) use_hash(bvs) parallel(bvs) swap_join_inputs(bvs)
                    full(tmp) use_hash(tmp) parallel(tmp)
                        */
                     map.rowid                          batch_map_rowid
                     , tmp.project_id                   PROJECT_ID
                     , case
                       when (tmp.PLAN_TYPE_CODE = g_cost_budget_type_code or
                             tmp.PLAN_TYPE_CODE = g_cost_fp_type_code)
                       and  bvs.CURRENT_FLAG            = 'Y'
                       and  bv.version_type in ('COST','ALL')  /* Added for bug 9414176 */
                       then bvs.VERSION_ID
                       else 0
                       end       COST_BUDGET_C_VERSION
                     , case
                       when (tmp.PLAN_TYPE_CODE = g_cost_budget_type_code or
                             tmp.PLAN_TYPE_CODE = g_cost_fp_type_code)
                       and  bvs.CURRENT_ORIGINAL_FLAG   = 'Y'
                       and  bv.version_type in ('COST','ALL')  /* Added for bug 9414176 */
                       then bvs.VERSION_ID
                       else 0
                       end       COST_BUDGET_CO_VERSION
                     , case
                       when (tmp.PLAN_TYPE_CODE = g_revenue_budget_type_code or
                             tmp.PLAN_TYPE_CODE = g_rev_fp_type_code)
                       and  bvs.CURRENT_FLAG            = 'Y'
                       and  bv.version_type in ('REVENUE','ALL')  /* Added for bug 9414176 */
                       then bvs.VERSION_ID
                       else 0
                       end       REVENUE_BUDGET_C_VERSION
                     , case
                       when (tmp.PLAN_TYPE_CODE = g_revenue_budget_type_code or
                             tmp.PLAN_TYPE_CODE = g_rev_fp_type_code)
                       and  bvs.CURRENT_ORIGINAL_FLAG   = 'Y'
                       and  bv.version_type in ('REVENUE','ALL')  /* Added for bug 9414176 */
                       then bvs.VERSION_ID
                       else 0
                       end       REVENUE_BUDGET_CO_VERSION
                     , case
                       when (tmp.PLAN_TYPE_CODE = g_cost_forecast_type_code or
                             tmp.PLAN_TYPE_CODE = g_cost_forecast_fp_type_code)
                       and  bvs.CURRENT_FLAG            = 'Y'
                       and  bv.version_type in ('COST','ALL')  /* Added for bug 9414176 */
                       then bvs.VERSION_ID
                       else 0
                       end       COST_FORECAST_C_VERSION
                     , case
                       when (tmp.PLAN_TYPE_CODE =g_rev_forecast_fp_type_code or
                             tmp.PLAN_TYPE_CODE = g_revenue_forecast_type_code)
                       and  bvs.CURRENT_FLAG            = 'Y'
                       and  bv.version_type in ('REVENUE','ALL')  /* Added for bug 9414176 */
                       then bvs.VERSION_ID
                       else 0
                       end       REVENUE_FORECAST_C_VERSION
               from
                 PJI_PJI_PROJ_BATCH_MAP map,
                 PJI_FM_EXTR_PLNVER1    bvs,
                 PJI_FM_EXTR_PLAN       tmp,
                 PJI_FM_EXTR_PLN_LOG    log,
                 PA_BUDGET_VERSIONS     bv    /* Added for bug 9414176 */
               where
                       map.worker_id   = p_worker_id
               and     map.project_id = bvs.project_id
               and     bv.project_id = bvs.project_id         /* Added for bug 9414176 */
               and     bv.budget_version_id = bvs.version_id  /* Added for bug 9414176 */
               and     bvs.worker_id  = p_worker_id
               and     tmp.project_id = bvs.project_id
               and     tmp.version_id = bvs.version_id
               and     tmp.worker_id  = bvs.worker_id
               and     tmp.calendar_type_code = 'ENTW'
               and     tmp.LINE_TYPE          = 'CG'
               and     tmp.currency_type      = 'G'
               and     tmp.version_id = log.budget_version_id (+)
               and     log.budget_version_id is null
            )   tmp
        GROUP BY
                tmp.PROJECT_ID
                , tmp.BATCH_MAP_ROWID
       )    tmp
;

          PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
          (l_process, 'PJI_FM_PLAN_EXTR.EXTRACT_UPDATED_VERSIONS(p_worker_id);');

commit;

end extract_updated_versions;


  -- -----------------------------------------------------
  -- procedure UPDATE_BATCH_VERSIONS_PRE
  -- -----------------------------------------------------
  procedure update_batch_versions_pre(p_worker_id number) is

    l_process varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
              'PJI_FM_PLAN_EXTR.UPDATE_BATCH_VERSIONS_PRE(p_worker_id);')) then
      return;
    end if;

    insert /*+ append */ into PJI_HELPER_BATCH_MAP
    (
      BATCH_ID,
      WORKER_ID,
      STATUS
    )
    select
      distinct
      BATCH_ID,
      null,
      null
    from
      PJI_FM_EXTR_PLNVER2
    where
      WORKER_ID = p_worker_id;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
      'PJI_FM_PLAN_EXTR.UPDATE_BATCH_VERSIONS_PRE(p_worker_id);');

    commit;

  end update_batch_versions_pre;


  -- -----------------------------------------------------
  -- procedure UPDATE_BATCH_VERSIONS
  -- -----------------------------------------------------
  procedure update_batch_versions(p_worker_id number) is

    l_process            varchar2(30);
    l_leftover_batches   number;
    l_helper_batch_id    number;
    l_row_count          number;
    l_parallel_processes number;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
                                              'PJI_FM_PLAN_EXTR.UPDATE_BATCH_VERSIONS(p_worker_id);')) then
      return;
    end if;

    l_parallel_processes := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                            (PJI_RM_SUM_MAIN.g_process, 'PARALLEL_PROCESSES');

    select count(*)
    into   l_leftover_batches
    from   PJI_HELPER_BATCH_MAP
    where  WORKER_ID = p_worker_id and
           STATUS = 'P';

    l_helper_batch_id := 0;

    while (l_helper_batch_id >= 0) loop

      if (l_leftover_batches > 0) then

        l_leftover_batches := l_leftover_batches - 1;

        select  BATCH_ID
        into    l_helper_batch_id
        from    PJI_HELPER_BATCH_MAP
        where   WORKER_ID = p_worker_id and
                STATUS = 'P' and
                ROWNUM = 1;

      else

        update    PJI_HELPER_BATCH_MAP
        set       WORKER_ID = p_worker_id,
                  STATUS = 'P'
        where     WORKER_ID is null and
                  ROWNUM = 1
        returning BATCH_ID
        into      l_helper_batch_id;

      end if;

      if (sql%rowcount <> 0) then

        commit;

        update  pji_pji_proj_batch_map  map
        set     (map.COST_BUDGET_N_VERSION,
                 map.COST_BUDGET_NO_VERSION,
                 map.REVENUE_BUDGET_N_VERSION,
                 map.REVENUE_BUDGET_NO_VERSION,
                 map.COST_FORECAST_N_VERSION,
                 map.REVENUE_FORECAST_N_VERSION) =
            (select
               decode(sign(vrs.COST_BUDGET_C_VERSION)
                      , 0, decode(map.COST_BUDGET_C_VERSION,
                                  -1, -2, map.COST_BUDGET_C_VERSION)
                      ,    vrs.COST_BUDGET_C_VERSION
                     )         COST_BUDGET_C_VERSION
             , decode(sign(vrs.COST_BUDGET_CO_VERSION)
                      , 0, decode(map.COST_BUDGET_CO_VERSION,
                                  -1, -2, map.COST_BUDGET_CO_VERSION)
                      ,    vrs.COST_BUDGET_CO_VERSION
                     )         COST_BUDGET_CO_VERSION
             , decode(sign(vrs.REVENUE_BUDGET_C_VERSION)
                      , 0, decode(map.REVENUE_BUDGET_C_VERSION,
                                  -1, -2, map.REVENUE_BUDGET_C_VERSION)
                      ,    vrs.REVENUE_BUDGET_C_VERSION
                     )         REVENUE_BUDGET_C_VERSION
             , decode(sign(vrs.REVENUE_BUDGET_CO_VERSION)
                      , 0, decode(map.REVENUE_BUDGET_CO_VERSION,
                                  -1, -2, map.REVENUE_BUDGET_CO_VERSION)
                      ,    vrs.REVENUE_BUDGET_CO_VERSION
                     )         REVENUE_BUDGET_CO_VERSION
             , decode(sign(vrs.COST_FORECAST_C_VERSION)
                      , 0, decode(map.COST_FORECAST_C_VERSION,
                                  -1, -2, map.COST_FORECAST_C_VERSION)
                      ,    vrs.COST_FORECAST_C_VERSION
                     )         COST_FORECAST_C_VERSION
             , decode(sign(vrs.REVENUE_FORECAST_C_VERSION)
                      , 0, decode(map.REVENUE_FORECAST_C_VERSION,
                                  -1, -2, map.REVENUE_FORECAST_C_VERSION)
                      ,    vrs.REVENUE_FORECAST_C_VERSION
                     )         REVENUE_FORECAST_C_VERSION
             from    PJI_FM_EXTR_PLNVER2   vrs
             where  vrs.batch_map_rowid = map.rowid
            )
        where   map.project_id in (select project_id
                                   from   PJI_FM_EXTR_PLNVER2
                                   where  WORKER_ID = 1 and
                                          BATCH_ID = l_helper_batch_id)
        and     map.worker_id = 1;

        update PJI_HELPER_BATCH_MAP
        set    STATUS = 'C'
        where  WORKER_ID = p_worker_id and
               BATCH_ID = l_helper_batch_id;

        commit;

      else

        select count(*)
        into   l_row_count
        from   PJI_HELPER_BATCH_MAP
        where  nvl(STATUS, 'X') <> 'C';

        if (l_row_count = 0) then

          for x in 2 .. l_parallel_processes loop

            update PJI_SYSTEM_PRC_STATUS
            set    STEP_STATUS = 'C'
            where  PROCESS_NAME like PJI_RM_SUM_MAIN.g_process|| to_char(x) and
                   STEP_NAME =
                     'PJI_FM_PLAN_EXTR.UPDATE_BATCH_VERSIONS(p_worker_id);' and
                   START_DATE is null;

            commit;

          end loop;

          l_helper_batch_id := -1;

        else

          PJI_PROCESS_UTIL.SLEEP(1); -- so the CPU is not bombarded

        end if;

      end if;

      if (l_helper_batch_id >= 0) then

        for x in 2 .. l_parallel_processes loop
          if (not PJI_RM_SUM_EXTR.WORKER_STATUS(x, 'OKAY')) then
            l_helper_batch_id := -2;
          end if;
        end loop;

      end if;

    end loop;

    if (l_helper_batch_id <> -2) then

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
        'PJI_FM_PLAN_EXTR.UPDATE_BATCH_VERSIONS(p_worker_id);');

    end if;

    commit;

  end update_batch_versions;


  -- -----------------------------------------------------
  -- procedure UPDATE_BATCH_VERSIONS_POST
  -- -----------------------------------------------------
  procedure update_batch_versions_post(p_worker_id number) is

    l_process varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
             'PJI_FM_PLAN_EXTR.UPDATE_BATCH_VERSIONS_POST(p_worker_id);')) then
      return;
    end if;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE('PJI',
                                     'PJI_HELPER_BATCH_MAP',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
      'PJI_FM_PLAN_EXTR.UPDATE_BATCH_VERSIONS_POST(p_worker_id);');

    commit;

  end update_batch_versions_post;


  -- -----------------------------------------------------
  -- procedure UPDATE_BATCH_STATUSES
  -- -----------------------------------------------------
  procedure UPDATE_BATCH_STATUSES (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_PLAN_EXTR.UPDATE_BATCH_STATUSES(p_worker_id);'
            )) then
      return;
    end if;

    -- update project extraction status

    update /*+ index(status, PJI_PJI_PROJ_EXTR_STATUS_U1) */
           PJI_PJI_PROJ_EXTR_STATUS status
    set    (CLOSED_DATE,
            PROJECT_ORGANIZATION_ID,
            COST_BUDGET_C_VERSION,
            COST_BUDGET_CO_VERSION,
            REVENUE_BUDGET_C_VERSION,
            REVENUE_BUDGET_CO_VERSION,
            COST_FORECAST_C_VERSION,
            REVENUE_FORECAST_C_VERSION) =
           (select /*+ index(map, PJI_PJI_PROJ_BATCH_MAP_N1) */
                   map.NEW_CLOSED_DATE,
                   map.NEW_PROJECT_ORGANIZATION_ID,
                   nvl(map.COST_BUDGET_N_VERSION,status.COST_BUDGET_C_VERSION),
                   nvl(map.COST_BUDGET_NO_VERSION,status.COST_BUDGET_CO_VERSION),
                   nvl(map.REVENUE_BUDGET_N_VERSION,status.REVENUE_BUDGET_C_VERSION),
                   nvl(map.REVENUE_BUDGET_NO_VERSION,status.REVENUE_BUDGET_CO_VERSION),
                   nvl(map.COST_FORECAST_N_VERSION,status.COST_FORECAST_C_VERSION),
                   nvl(map.REVENUE_FORECAST_N_VERSION,status.REVENUE_FORECAST_C_VERSION)
            from   PJI_PJI_PROJ_BATCH_MAP map
            where  map.WORKER_ID = p_worker_id and
                   map.PROJECT_ID = status.PROJECT_ID)
    where  PROJECT_ID in (select /*+ index(map, PJI_PJI_PROJ_BATCH_MAP_N1) */
                                 PROJECT_ID
                          from   PJI_PJI_PROJ_BATCH_MAP
                          where  WORKER_ID = p_worker_id);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_PLAN_EXTR.UPDATE_BATCH_STATUSES(p_worker_id);'
    );

    commit;

  end UPDATE_BATCH_STATUSES;


begin   --  this protion is executed whenever the package is initialized
   g_global_start_date := to_date(PJI_UTILS.GET_PARAMETER('GLOBAL_START_DATE'),PJI_RM_SUM_MAIN.g_date_mask);


    begin
     select ent_period_id,name,start_date,end_date
     into   g_ent_start_period_id,g_ent_start_period_name,g_ent_start_date,g_ent_end_date
     from   fii_time_ent_period
     where  g_global_start_date between start_date AND end_date
     ;

     select week_id,PJI_RM_SUM_MAIN.g_null,start_date,end_date
     into   g_entw_start_period_id,g_entw_start_period_name,g_entw_start_date,g_entw_end_date
     from   fii_time_week
     where  g_global_start_date between start_date AND end_date
     ;
   exception
     when no_data_found then
     null;
   end;

   g_global_start_J    := to_char(g_global_start_date,'J');
   g_ent_start_J       := to_char(g_ent_start_date,'J');
   g_ent_end_J         := to_char(g_ent_end_date,'J');
   g_entw_start_J      := to_char(g_entw_start_date,'J');
   g_entw_end_J        := to_char(g_entw_end_date,'J');


end PJI_FM_PLAN_EXTR;

/
