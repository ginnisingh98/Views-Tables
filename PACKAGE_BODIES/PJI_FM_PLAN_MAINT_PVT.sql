--------------------------------------------------------
--  DDL for Package Body PJI_FM_PLAN_MAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_PLAN_MAINT_PVT" AS
/* $Header: PJIPP02B.pls 120.52.12010000.14 2010/03/25 07:41:55 jngeorge ship $ */


  g_package_name VARCHAR2(100) := 'PJI_FM_PLAN_MAINT_PVT';

  g_prorating_format            VARCHAR2(30) := 'S';
                                -- S Start date, E End date, D (daily) Period.
                                -- Based on plan version.

  g_currency_conversion_rule   VARCHAR2(30) := 'S';
                                -- S Start date, E End date.
                                -- Based on plan version.

  g_global_curr_1_enabled       VARCHAR2(30) := 'T';
  g_global_curr_2_enabled       VARCHAR2(30) := 'T';

  g_global1_currency_code       VARCHAR2(30) := 'USD';
  g_global2_currency_code       VARCHAR2(30) := 'CAD';

  g_global1_currency_mau        NUMBER;
  g_global2_currency_mau        NUMBER;

  g_labor_mau                   NUMBER := 0.01;

  g_ent_start_period_id         NUMBER        := NULL;
  g_ent_start_period_name       VARCHAR2(100) := NULL;
  g_ent_start_date              date := NULL;
  g_ent_END_date                date := NULL;
  g_global_start_date           date := NULL;

  g_global_start_J              NUMBER := NULL;
  g_ent_start_J                 NUMBER := NULL;
  g_ent_END_J                   NUMBER := NULL;

  g_worker_id                    NUMBER := 1; -- NULL;
  g_default_prg_level           NUMBER := 0;

  g_people_resclass_code        VARCHAR2(20) := 'PEOPLE';
  g_equip_resclass_code         VARCHAR2(20) := 'EQUIPMENT';

  g_yes                         VARCHAR2(1) := 'Y';
  g_no                          VARCHAR2(1) := 'N';  -- Same as g_nontimeph_str.
  g_pa_cal_str                  VARCHAR2(1) := 'P';
  g_gl_cal_str                  VARCHAR2(1) := 'G';
  -- 'N'ntimeph_str               VARCHAR2(1) := 'N';
  g_ent_cal_str                 VARCHAR2(1) := 'E';
  g_all                         VARCHAR2(1) := 'A';
  g_start_str                   VARCHAR2(1) := 'S';
  g_end_str                     VARCHAR2(1) := 'E';
  g_lowest_level                VARCHAR2(1) := 'L';
  g_top_level                   VARCHAR2(1) := 'T';
  g_rolled_up                   VARCHAR2(1) := 'R';

  g_ntp_period_name             VARCHAR2(10) := 'XXX';

-- g_full                        VARCHAR2(4) := 'FULL';
-- g_incr                        VARCHAR2(4) := 'INCREMENTAL';
g_cb_plans	 constant NUMBER := 2;
g_co_plans	 constant NUMBER := 4;
g_lp_plans	 constant NUMBER := 8;
g_wk_plans	 constant NUMBER := 16;
g_latest_plans	 constant NUMBER := 30;
g_all_plans	 constant NUMBER := 62;


  -- 'P'            VARCHAR2(15) := 'P';
  -- 'G'            VARCHAR2(15) := 'G';
  -- 'N'       VARCHAR2(15) := 'N';
  -- 'R'         VARCHAR2(15) := 'R';
  -- 'X'       VARCHAR2(15) := 'X';


------------------------------------------------------------------
------------------------------------------------------------------
--              Helper  Apis Specification                      --
------------------------------------------------------------------
------------------------------------------------------------------

PROCEDURE log1
(p_msg IN VARCHAR2 ,
 p_module IN VARCHAR2 DEFAULT 'aritra')
IS
pragma autonomous_transaction;
BEGIN
        insert into FND_LOG_MESSAGES
      (MODULE, LOG_LEVEL, MESSAGE_TEXT
      , SESSION_ID, USER_ID, TIMESTAMP
      , LOG_SEQUENCE, ENCODED, NODE
      , NODE_IP_ADDRESS, PROCESS_ID, JVM_ID
      , THREAD_ID, AUDSID, DB_INSTANCE
      , TRANSACTION_CONTEXT_ID)
      values
      (p_module, 6, p_msg, -1, 0, sysdate
	  , FND_LOG_MESSAGES_S.NEXTVAL, 'Y', null
	  , null, NULL, NULL, NULL, NULL, 1, NULL);
      COMMIT;
END log1;

PROCEDURE PRINT_TIME (p_tag IN VARCHAR2);

PROCEDURE PRINT_NUM_WBSRLPRCDS_INPJP1;

PROCEDURE INSERT_NTP_CAL_RECORD ( x_max_project_id OUT NOCOPY NUMBER );

PROCEDURE DELETE_NTP_CAL_RECORD ( p_max_project_id IN NUMBER );

PROCEDURE UPDATE_LOCKS (
  p_context         IN VARCHAR2
, p_update_mode     IN VARCHAR2
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_code        OUT NOCOPY VARCHAR2 );

--
-- Populate ver3 for summarization programs.
--
PROCEDURE VALIDATE_SET_PR_PARAMS(
  p_rbs_version_id  IN NUMBER
, p_plan_type_id    IN NUMBER
, p_context         IN VARCHAR2      -- Valid values are 'RBS' or 'PLANTYPE'.
, x_num_rows        OUT NOCOPY NUMBER
, x_return_status   OUT NOCOPY  VARCHAR2
, x_msg_code        OUT NOCOPY  VARCHAR2 ) IS

  l_plan_type_id      NUMBER := NULL;
  l_rbs_version_id    NUMBER := NULL;
  l_rbs_header_id    NUMBER := NULL; --Added for bug#5728852
  -- l_count  NUMBER;
  l_return_status  VARCHAR2(1) := NULL;
  l_fp_version_ids SYSTEM.pa_num_tbl_type := pji_empty_num_tbl ;
  l_msg_code       VARCHAR2(10) := NULL;
  l_refresh_code NUMBER;		 --  Bug#5099574
  l_process           varchar2(30);		 --  Bug#5099574

  l_actual_ver NUMBER :=  -1;
  l_cb_ver NUMBER := -3;
  l_co_ver NUMBER := -4;
  l_num_rows NUMBER :=0;
    l_workplan_type_id number;

BEGIN

  print_time('VALIDATE_SET_PR_PARAMS : Begin.. ');

  PJI_PJP_FP_CURR_WRAP.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  x_num_rows := 0;

  g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;
  print_time ( ' Worker id is.. ' || g_worker_id );

  print_time(' VALIDATE_SET_PR_PARAMS : plan type id is ' || p_plan_type_id );
  print_time(' p_context is ' || p_context || ' and rbs ver id is ' || p_rbs_version_id );

  IF (p_context NOT IN ('RBS' , 'PLANTYPE', 'INCREMENTAL', 'FULL')) THEN
    print_time(' Invalid p_context.. exitting. ' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
  END IF;

/* Added for bug#5728852 - START */
  l_process := PJI_PJP_SUM_MAIN.g_process || to_char(g_worker_id);
  l_rbs_header_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,'RBS_HEADER_ID');
/* Added for bug#5728852 - END */

  IF (p_context = 'RBS' AND p_rbs_version_id IS NULL) THEN
    print_time('Context is RBS and rbs version id is NULL. Pl. provide a rbs version id. Exitting.' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
  END IF;

  IF (p_context = 'RBS') THEN

    l_plan_type_id  := NULL;
    l_rbs_version_id  := p_rbs_version_id;


    INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	CURRENT_FLAG             ,
	ORIGINAL_FLAG            ,
	CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG        	 ,
	SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
      SELECT
        DISTINCT
            g_worker_id worker_id
          , project_id
          , plan_version_id
          , wbs_struct_version_id
          , rbs_struct_version_id
          , plan_type_code
          , plan_type_id
          , time_phased_type_code
          , NULL time_dangling_flag
          , NULL rate_dangling_flag
          , NULL PROJECT_TYPE_CLASS
          , is_wp_flag
          , current_flag
          , original_flag
          , current_original_flag
          , baselined_flag
          , SECONDARY_RBS_FLAG
          , lp_flag
     FROM
     (
	 SELECT   -- RBS Push 1: This select for all primary RBSes that change from rbs version A to B.
            /*+ ORDERED */
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
          , fpo.rbs_version_id                 rbs_struct_version_id -- extract for this rbs version id
--          , to_char(fpo.fin_plan_type_id)      plan_type_code
           , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code
		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		  , 'N'  		                     SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
        pji_pjp_proj_batch_map map,
        pji_pjp_rbs_header     rhd,
        pa_budget_versions     bv,
        pa_proj_fp_options     fpo,
        pji_pa_proj_events_log pel,
        pa_projects_all        ppa,
	pa_rbs_versions_b	rvb --Added for bug#5728852
      WHERE 1=1
          AND ppa.project_id = map.project_id
          AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
          AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
          AND fpo.project_id = map.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
          AND rhd.rbs_version_id = rvb.rbs_version_id --Added for bug#5728852
	  AND rvb.rbs_header_id = l_rbs_header_id --Added for bug#5728852
	    AND rhd.plan_version_id = bv.budget_version_id
          AND rhd.project_id = map.project_id
          AND pel.WORKER_ID = g_worker_id
	    AND pel.event_type = 'RBS_PUSH'
	    AND pel.event_object = fpo.rbs_version_id -- event object is the new primary rbs_version.
  	    AND to_number(pel.attribute2) = p_rbs_version_id -- attribute2 is the old rbs_version.
          AND pel.ATTRIBUTE19 = map.PROJECT_ID
          AND map.project_id = bv.project_id
          AND map.worker_id = g_worker_id
          -- AND p_context = 'RBS'
      UNION ALL
      SELECT    -- RBS Push 2: This select for all secondary (reporting) RBSes that are changing from A to B.
            /*+ ORDERED */
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
          , rpa.rbs_version_id                 rbs_struct_version_id
--          , to_char(fpo.fin_plan_type_id)      plan_type_code
           , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code
		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		  , 'Y'  		                     SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
        PJI_PJP_PROJ_BATCH_MAP map,
        PJI_PJP_RBS_HEADER     rhd,
        PA_BUDGET_VERSIONS     bv,
        PA_PROJ_FP_OPTIONS     fpo,
        PJI_PA_PROJ_EVENTS_LOG pel,
        PA_RBS_PRJ_ASSIGNMENTS rpa,
        PA_PROJECTS_ALL        ppa,
	PA_RBS_VERSIONS_B	rvb --Added for bug#5728852
      WHERE 1=1
          AND ppa.project_id = map.project_id
          AND bv.project_id = map.project_id
          AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
          AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
          AND fpo.project_id = map.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
          AND bv.budget_status_code = 'B'
          AND NVL(bv.wp_version_flag, 'N') = 'N'
          AND rhd.project_id = map.project_id
	    AND rhd.plan_version_id = bv.budget_version_id
          AND rhd.rbs_version_id = rvb.rbs_version_id --Added for bug#5728852
	  AND rvb.rbs_header_id = l_rbs_header_id --Added for bug#5728852
          AND rpa.assignment_status = 'ACTIVE'
	    AND NVL(fpo.rbs_version_id, -1) <> rpa.rbs_version_id
	    AND rpa.project_id = map.project_id
          AND pel.WORKER_ID = g_worker_id
  	    AND to_number(pel.attribute2) = p_rbs_version_id
	    AND pel.event_type = 'RBS_PUSH'  -- When RBS version is 'frozen' from RBS definition screen.
	    AND pel.event_object = rpa.rbs_version_id
          AND pel.ATTRIBUTE19 = map.PROJECT_ID
          AND map.project_id = bv.project_id
          -- AND map.PROJECT_ACTIVE_FLAG = 'Y'
          AND map.worker_id = g_worker_id
          -- AND p_context = 'RBS'
       UNION ALL
      SELECT
        /*+ ORDERED */
            bv.project_id                      project_id
          , pln_ver.pvi                        plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
          , rpa.rbs_version_id                 rbs_struct_version_id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code
		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , DECODE(pln_ver.pvi, -3, 'Y', -4, 'N') current_flag
		  , 'X'                          original_flag
		  , DECODE(pln_ver.pvi, -3, 'N', -4, 'Y') current_original_flag
		  , DECODE(pln_ver.pvi, -3, 'Y', -4, 'N') baselined_flag
		  , 'N'  		                     SECONDARY_RBS_FLAG
		  , 'Y'                                lp_flag
      FROM
        PJI_PJP_PROJ_BATCH_MAP map,
        PJI_PJP_RBS_HEADER     rhd,
        PA_BUDGET_VERSIONS     bv,
        PA_PROJ_FP_OPTIONS     fpo,
        PJI_PA_PROJ_EVENTS_LOG pel,
        PA_RBS_PRJ_ASSIGNMENTS rpa,
        PA_PROJECTS_ALL        ppa,
	PA_RBS_VERSIONS_B	rvb,
        (
        SELECT -3 pvi FROM dual UNION ALL
        SELECT -4 pvi FROM dual
        ) pln_ver
      WHERE 1=1
          AND ppa.project_id = bv.project_id
          AND bv.version_type IS NOT NULL -- COST, REVENUE, etc. Should not be null.
          AND bv.fin_plan_type_id IS NOT NULL -- Old budgets model data is not picked up with this condition.
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
          AND bv.budget_status_code = 'B'
          AND NVL(bv.wp_version_flag, 'N') = 'N'
          AND pel.WORKER_ID = g_worker_id
          AND rhd.PROJECT_ID = map.PROJECT_ID
  	    AND rhd.rbs_version_id = TO_NUMBER(pel.attribute2)
	    AND rhd.plan_version_id = bv.budget_version_id
          AND rhd.rbs_version_id = rvb.rbs_version_id --Added for bug#5728852
	  AND rvb.rbs_header_id = l_rbs_header_id --Added for bug#5728852
          AND rpa.assignment_status = 'ACTIVE'
	    -- AND NVL(fpo.rbs_version_id, -1) <> rpa.rbs_version_id
	    AND rpa.project_id = bv.project_id
	    AND pel.event_type = 'RBS_PUSH'  -- When RBS version is 'frozen' from RBS definition screen.
	    AND pel.event_object = rpa.rbs_version_id
          AND pel.ATTRIBUTE19 = map.PROJECT_ID
          AND map.project_id = bv.project_id
          AND map.worker_id = g_worker_id
          -- AND p_context = 'RBS'
        ) ;

    l_num_rows := SQL%ROWCOUNT;

  print_time ( ' Number of plans with this rbs version id are.. x_num_rows = ' || l_num_rows);
  ELSIF (p_context = 'PLANTYPE') THEN

    l_plan_type_id  := p_plan_type_id;
    l_rbs_version_id  := NULL;
    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(g_worker_id);									  --  Bug#5099574
    l_refresh_code     :=  PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER (l_process, 'REFRESH_CODE');    --  Bug#5099574

    			--  Bug#	5208322  :  the workplan plan_type_id is stored in  l_workplan_type_id
			begin
			SELECT fin_plan_type_id into l_workplan_type_id
			FROM pa_fin_plan_types_b
			WHERE use_for_workplan_flag = 'Y';
			exception
			when no_data_found then
			l_workplan_type_id := NULL;
			end;



    INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	CURRENT_FLAG             ,
	ORIGINAL_FLAG            ,
	CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG        	 ,
	SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
      SELECT
            DISTINCT
            g_worker_id worker_id
          , project_id
          , plan_version_id
          , wbs_struct_version_id
          , rbs_struct_version_id
          , plan_type_code
          , plan_type_id
          , time_phased_type_code
          , NULL time_dangling_flag
          , NULL rate_dangling_flag
          , NULL PROJECT_TYPE_CLASS
          , is_wp_flag
          , current_flag
          , original_flag
          , current_original_flag
          , baselined_flag
          , SECONDARY_RBS_FLAG
          , lp_flag
     FROM
     (
	 SELECT   -- Partial refresh 1: This select for all plan versions with primary rbs and plan type id not null.
	     /*+ ORDERED */
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
          , fpo.rbs_version_id                 rbs_struct_version_id -- extract for this rbs version id
--          , to_char(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code
		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		  , 'N'  		                     SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
    FROM
       pji_pjp_proj_batch_map map
     , pa_projects_all  ppa
     ,  pa_budget_versions bv
     , pa_proj_fp_options  fpo
       WHERE 1=1
          AND ppa.project_id = bv.project_id
          AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
          AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
          AND map.project_id = bv.project_id
          AND map.worker_id = g_worker_id
          AND bv.fin_plan_type_id = nvl(l_plan_type_id,bv.fin_plan_type_id) and
			(
			    'Y' IN		-- Bug#5099574  Pull Reversals for CB / CO if refresh_code < 62 . Else pull for all plans ids >0 if refresh_code>=62
				(
						Select decode(
						  bitand(l_refresh_code,g_all_plans),g_all_plans,'Y',
							  decode(  bitand(l_refresh_code,g_cb_plans),g_cb_plans,
							  decode(decode(bv.baselined_date, NULL, 'N', 'Y')||bv.current_flag,'YY', 'Y', 'N'),'X')) from dual
					 UNION  ALL
						Select decode(
						  bitand(l_refresh_code,g_all_plans),g_all_plans,'Y',
						  decode( bitand(l_refresh_code,g_co_plans),g_co_plans,bv.current_original_flag,'X')) from dual
				)
			OR		-- Bug#5099574  Pull Reversals for Fin plan Working Versions when l_refresh_code=16,30. ignore if  l_refresh_code>=62
				(
				 bv.BUDGET_STATUS_CODE in ('W','S')	and
				 fpo.FIN_PLAN_TYPE_ID <> l_workplan_type_id 			and
				 DECODE(BITAND(l_refresh_code,g_all_plans),g_all_plans,'N',DECODE(BITAND(l_refresh_code,g_wk_plans),g_wk_plans,'Y','N'))='Y'
				 )
			OR 	 --Pull Reversals for Work plan Working Versions / LPub Vers / Baselined Versions when l_refresh_code=2,8,16,30. ignore if  l_refresh_code>=62
			EXISTS	 ( select 1 from PA_PROJ_ELEM_VER_STRUCTURE	ppevs where
				 bv.FIN_PLAN_TYPE_ID					=l_workplan_type_id				and
				 bv.PROJECT_STRUCTURE_VERSION_ID  = ppevs.ELEMENT_VERSION_ID	and
					(
					decode(BITAND(l_refresh_code,g_all_plans),g_all_plans,'N',
												decode(BITAND(l_refresh_code,g_lp_plans),g_lp_plans,LATEST_EFF_PUBLISHED_FLAG,'N'))='Y'
					or
					decode(BITAND(l_refresh_code,g_all_plans),g_all_plans,'N',
												decode(BITAND(l_refresh_code,g_wk_plans),g_wk_plans,STATUS_CODE,'N'))='STRUCTURE_WORKING'
					or
    					decode(BITAND(l_refresh_code,g_all_plans ),g_all_plans ,'N',
											 	decode(BITAND(l_refresh_code,g_cb_plans),g_cb_plans,NVL2(CURRENT_BASELINE_DATE,'Y','N'),'N')) ='Y'

					)
				)
			)
       UNION ALL
       SELECT    -- Partial refresh 2: This select for all secondary (reporting) RBSes .
         /*+ ORDERED */
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
          , rpa.rbs_version_id                 rbs_struct_version_id
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code
		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		  , 'Y'  		                     SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
          pji_pjp_proj_batch_map map
	 , pa_projects_all  ppa -- @pjdev115    ppa
         , pa_budget_versions bv -- @pjdev115  bv
         , pa_proj_fp_options  fpo -- @pjdev115  fpo
         , PA_RBS_PRJ_ASSIGNMENTS rpa
      WHERE 1=1
          AND ppa.project_id = bv.project_id
          AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
          AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
          AND bv.budget_status_code = 'B'
          AND NVL(bv.wp_version_flag, 'N') = 'N'
          AND rpa.assignment_status = 'ACTIVE'
	    AND NVL(fpo.rbs_version_id, -1) <> rpa.rbs_version_id
	    AND rpa.project_id = bv.project_id
          AND map.project_id = bv.project_id
          AND map.worker_id = g_worker_id
          AND bv.fin_plan_type_id = nvl(l_plan_type_id,bv.fin_plan_type_id) and
	   	 (
			 'Y' IN		-- Bug#5099574  Pull Reversals for CB / CO if refresh_code < 62 . Else pull for all plans ids >0 if refresh_code>=62
			(
							Select decode(
							  bitand(l_refresh_code,g_all_plans),g_all_plans,'Y',
								  decode(  bitand(l_refresh_code,g_cb_plans),g_cb_plans,
								  decode(decode(bv.baselined_date, NULL, 'N', 'Y')||bv.current_flag,'YY', 'Y', 'N'),'X')) from dual
						 UNION  ALL
							Select decode(
							  bitand(l_refresh_code,g_all_plans),g_all_plans,'Y',
							  decode( bitand(l_refresh_code,g_co_plans),g_co_plans,bv.current_original_flag,'X')) from dual
			)
		)
        ) ;

    l_num_rows := SQL%ROWCOUNT;




  ELSIF (p_context IN ( 'INCREMENTAL', 'FULL')) THEN -- Workplans only.


    INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	CURRENT_FLAG             ,
	ORIGINAL_FLAG            ,
	CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG        	 ,
	SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
      SELECT
        DISTINCT
            g_worker_id worker_id
          , project_id
          , plan_version_id
          , wbs_struct_version_id
          , rbs_struct_version_id
          , plan_type_code
          , plan_type_id
          , time_phased_type_code
          , NULL time_dangling_flag
          , NULL rate_dangling_flag
          , NULL PROJECT_TYPE_CLASS
          , is_wp_flag
          , current_flag
          , original_flag
          , current_original_flag
          , baselined_flag
          , SECONDARY_RBS_FLAG
          , lp_flag
     FROM
     (
	 SELECT   -- Incr 1 , Full 1: This select for all plan versions with primary rbs and plan type id not null.
	   /*+ ORDERED */
            pbv.project_id                      project_id
          , pbv.budget_version_id               plan_version_id
          , head.WBS_VERSION_ID               wbs_struct_version_id
          , fpo.rbs_version_id                 rbs_struct_version_id -- extract for this rbs version id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (pbv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(pbv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code
	    , NVL(pbv.wp_version_flag, 'N') is_wp_flag
	    , pbv.current_flag                  current_flag
	    , pbv.original_flag                 original_flag
	    , pbv.current_original_flag         current_original_flag
	    , DECODE(Pbv.baselined_date, NULL, 'N', 'Y') baselined_flag
	    , 'N'  		                     SECONDARY_RBS_FLAG
	    , 'Y'                              lp_flag
    FROM
            pji_pjp_proj_batch_map map,
	    PA_PROJECTS_ALL ppa,
	    PA_BUDGET_VERSIONS pbv,
	    pji_pjp_wbs_header head,
            PA_PROJ_ELEM_VER_STRUCTURE ppevs,
            PA_PROJ_FP_OPTIONS fpo
    WHERE
	      -- map.PROJECT_ACTIVE_FLAG         = 'Y'                    AND
	      map.PROJECT_ID                  = head.PROJECT_ID           AND
	      head.WP_FLAG                    = 'Y'                       AND
	      head.WBS_VERSION_ID             = ppevs.ELEMENT_VERSION_ID  AND
	      ppevs.STATUS_CODE               = 'STRUCTURE_PUBLISHED'     AND
	      ppevs.LATEST_EFF_PUBLISHED_FLAG = 'Y'                       AND
            head.project_id                 = ppevs.project_id          AND
            map.PROJECT_ID                  = ppa.PROJECT_ID            AND
            ppa.STRUCTURE_SHARING_CODE      = 'SHARE_FULL'              AND
            pbv.BUDGET_VERSION_ID           = head.PLAN_VERSION_ID      AND
            head.PLAN_VERSION_ID            = fpo.FIN_PLAN_VERSION_ID   AND
            ppa.project_id                  = pbv.project_id            AND
            pbv.version_type                IS NOT NULL                 AND
            pbv.fin_plan_type_id            IS NOT NULL                 AND
            fpo.project_id                  = pbv.project_id            AND
            pbv.fin_plan_type_id            = fpo.fin_plan_type_id      AND
            pbv.budget_version_id           = fpo.fin_plan_version_id   AND
            fpo.fin_plan_option_level_code  = 'PLAN_VERSION'            AND
            pbv.version_type                IN ('ALL','COST','REVENUE') AND
            map.worker_id                   = g_worker_id               AND
            p_context                       IN ('INCREMENTAL', 'FULL')
        ) ;

    l_num_rows := SQL%ROWCOUNT;

    print_time ( 'Context of summarization p_context is : ' || p_context );
    print_time ( 'GET_ACTUALS_SUMM : after insert to ver3 , # rows is  ' || l_num_rows );

  END IF;



  IF p_context = 'PLANTYPE' then
    select decode(l_plan_type_id,NULL,decode(bitand (l_refresh_code,1),1,-1,-999),-999),
    decode (bitand (l_refresh_code,2),2,-3,-999) ,
    decode (bitand (l_refresh_code,4),4,-4,-999)
    into l_actual_ver,l_cb_ver,l_co_ver from dual;
    ELSE
    l_actual_ver := -1;
    l_cb_ver     := -3;
    l_co_ver     := -4;
  END IF;

    INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	CURRENT_FLAG             ,
	ORIGINAL_FLAG            ,
	CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG        	 ,
	SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
      SELECT
        DISTINCT
            g_worker_id worker_id
          , project_id
          , plan_version_id
          , wbs_struct_version_id
          , rbs_struct_version_id
          , plan_type_code
          , plan_type_id
          , time_phased_type_code
          , NULL time_dangling_flag
          , NULL rate_dangling_flag
          , NULL PROJECT_TYPE_CLASS
          , is_wp_flag
          , current_flag
          , original_flag
          , current_original_flag
          , baselined_flag
          , SECONDARY_RBS_FLAG
          , lp_flag
     FROM
     (
	 SELECT   -- RBS push and Partial refresh: All RBSes for -3, -4 slices.
	   /*+ ORDERED */
            map.project_id                      project_id
          , whd.plan_version_id               plan_version_id
          , whd.wbs_version_id                 wbs_struct_version_id
          , rhd.rbs_version_id                 rbs_struct_version_id -- extract for this rbs version id
          , whd.plan_type_code                plan_type_code   /*4471527 */
          , DECODE( whd.plan_version_id
                  , -1
                  , TO_NUMBER(NULL)
                  , whd.plan_type_id)          plan_type_id
          , 'G'                                time_phased_type_code
		  , 'N'                              is_wp_flag
		  , DECODE(whd.plan_version_id, -3, 'Y', -4, 'N') current_flag
		  , 'X'                          original_flag
		  , DECODE(whd.plan_version_id, -3, 'N', -4, 'Y') current_original_flag
		  , DECODE(whd.plan_version_id, -3, 'Y', -4, 'N') baselined_flag
		  , 'N'  		                     SECONDARY_RBS_FLAG
		  , 'Y'                                lp_flag
      FROM
            pji_pjp_proj_batch_map map
          , PA_PROJECTS_ALL  ppa
	  , pji_pjp_wbs_header whd
          , pji_pjp_rbs_header rhd
      WHERE 1=1
          AND ppa.project_id = map.project_id
          -- AND map.PROJECT_ACTIVE_FLAG = 'Y'
          AND map.worker_id = g_worker_id
          AND p_context IN ( 'RBS', 'PLANTYPE')
		  AND whd.plan_version_id IN (l_cb_ver, l_co_ver)
		  AND rhd.plan_version_id IN (l_cb_ver, l_co_ver)
		  AND whd.plan_version_id = rhd.plan_version_id
		  AND whd.plan_type_code = rhd.plan_type_code   /*4471527 */
		  AND whd.project_id = map.project_id
		  AND rhd.project_id = map.project_id
       UNION ALL
	 SELECT   -- Incr 2 , Full 2, RBS push 3, Partial refresh 4: All RBSes for -1, -3, -4 slices.
	   /*+ ORDERED */
            map.project_id                      project_id
          , whd.plan_version_id               plan_version_id
          , whd.wbs_version_id                 wbs_struct_version_id
          , rhd.rbs_version_id                 rbs_struct_version_id -- extract for this rbs version id
          , whd.plan_type_code                 plan_type_code
          , DECODE( whd.plan_version_id
                  , -1
                  , TO_NUMBER(NULL)
                  , whd.plan_type_id)          plan_type_id
          , 'G'                                time_phased_type_code
		  , 'N'                              is_wp_flag
		  , NULL                         current_flag
		  , 'X'                          original_flag
		  , NULL                         current_original_flag
		  , NULL                         baselined_flag
		  , 'N'  		                     SECONDARY_RBS_FLAG
		  , 'Y'                                lp_flag
      FROM
                 pji_pjp_proj_batch_map map
               , PA_PROJECTS_ALL  ppa
	       , pji_pjp_wbs_header whd
               , pji_pjp_rbs_header rhd
      WHERE 1=1
          AND ppa.project_id = map.project_id
          -- AND map.PROJECT_ACTIVE_FLAG = 'Y'
          AND map.worker_id = g_worker_id
		  AND whd.plan_version_id = l_actual_ver
		  AND rhd.plan_version_id = l_actual_ver
		  AND whd.plan_version_id = rhd.plan_version_id
          AND whd.plan_type_code = rhd.plan_type_code
		  AND whd.project_id = map.project_id
		  AND rhd.project_id = map.project_id
        )
      WHERE (project_id, plan_version_id, NVL(plan_type_id, -1), plan_type_code, rbs_struct_version_id)
            NOT IN
            (SELECT project_id, plan_version_id, NVL(plan_type_id, -1), plan_type_code, rbs_struct_version_id
             FROM   pji_fm_extr_plnver4
             WHERE  worker_id = g_worker_id
               AND  plan_version_id in (-1, -3, -4));

   l_num_rows := l_num_rows + SQL%ROWCOUNT;  -- Bug#5208250

  print_time(' Number of ver4 records inserted for -1/-3/-4 plan versions is.. ' || SQL%ROWCOUNT );

   x_num_rows := l_num_rows;

     print_time (' Number of records inserted in Ver4 Table is : '||l_num_rows);

    if (l_num_rows=0) then
    return;
    end if;



  IF (p_context = 'RBS') THEN

    DELETE FROM pji_pjp_rbs_header -- Old RBS versions are to be replaced with new ones.
    WHERE 1=1
      AND rbs_version_id in (select rbs_version_id
			     from pa_rbs_versions_b
			     where rbs_header_id = l_rbs_header_id) --Modified for Bug#5728852 by VVJOSHI
      AND plan_version_id > 0;

    print_time ( ' Number of records in rbs hdr tbl that were deleted is.. = ' || SQL%ROWCOUNT );

    DELETE FROM pji_rbs_denorm
    WHERE struct_version_id = p_rbs_version_id; --Modified for Bug#6884573 by VVJOSHI

    print_time ( ' Number of rows in pji rbs denorm tbl that were deleted is.. = ' || SQL%ROWCOUNT );

    DELETE FROM pa_rbs_denorm
    WHERE struct_version_id = p_rbs_version_id; --Modified for Bug#6884573 by VVJOSHI

    print_time ( ' Number of rows in pa rbs denorm tbl that were deleted is.. = ' || SQL%ROWCOUNT );

    END IF;

  print_time('VALIDATE_SET_PR_PARAMS : end.. ');

EXCEPTION
  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => ' VALIDATE_SET_PR_PARAMS '
    , x_return_status  => l_return_status ) ;

    RAISE;
END;


--
-- bug 4863241
-- Lock mode: Lock during sumz='P', Unlock during sumz=NULL
--
PROCEDURE OBTAIN_RELEASE_LOCKS (
  p_context         IN          VARCHAR2
, p_lock_mode       IN          VARCHAR2 -- NULL or 'P'
, x_return_status   OUT NOCOPY  VARCHAR2
, x_msg_code        OUT NOCOPY  VARCHAR2 ) IS

  l_pl_exists          VARCHAR2(1) := 'N'; -- plan lines count.
  l_dangl_exists       VARCHAR2(1) := 'N'; -- dangling processing is happening.
  l_rbs_assoc_exists   NUMBER := 0; -- rbs assoc event exists.
  l_rbs_prg_exists     NUMBER := 0; -- rbs prg event exists.
  l_prg_change_exists  NUMBER := 0; -- prg change event exists.

  l_context            VARCHAR2(1000) := NULL;

BEGIN

  print_time (' OBTAIN_RELEASE_LOCKS start: p_context = ' || p_context || ' p_lock_mode ' || p_lock_mode || ' worker id = ' || g_worker_id );

  IF (p_context NOT IN ('RBS', 'PARTIAL', 'INCREMENTAL', 'FULL')) THEN -- , 'PULL_DANGLING') THEN
    print_time ( ' OBTAIN_RELEASE_LOCKS : Invalid p_context ' || p_context );
    RETURN;
  END IF;

  --
  -- RBS
  --    No program rollups, TN/TY slices does not change.
  --    New LNY data, so program rollup can happen.
  --    Only baselined fin plans/cb/co lock.
  -- PLANTYPE
  --    Actuals may have come in. LNN slice could have changed. Program rollups happen. New LNY data.
  --    All plans for this project, lat pub all the way up, one wpwv above, cb/co.
  -- INCR/FULL
  --   Only actuals change, if yes then do program rollup.
  --   lat pub all the way up.
  -- PULL_DANGLING
  --   Dangling baselined fin plan for this proj/cb/co, all cb/cos above striped by plan type.
  -- RBS_ASSOC
  --   TN/TY slices don't change. New LNY data for baselined fps.
  --   All baselined fin plan for this proj/cb/co.
  -- RBS_PRG
  --   TN/TY slices don't change. New LNY data for baselined fps.
  --   All baselined fin plan for this proj/cb/co *below* and above.
  -- PRG_CHANGE
  --   Lock all projects in new prg based on event.
  --


  BEGIN
    SELECT 'Y'
    INTO   l_pl_exists
    FROM   pji_fm_extr_plan_lines epl
    WHERE EXISTS (
      SELECT 1
      FROM   pji_pjp_proj_batch_map map
      WHERE  map.worker_id = g_worker_id
        AND  epl.project_id = map.project_id
                 )
     AND ROWNUM <= 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  SELECT NVL(SUM(DECODE(event_type, 'PRG_CHANGE', 1, 0)), 0)
       , NVL(SUM(DECODE(event_type, 'RBS_ASSOC', 1, 0)) , 0)
       , NVL(SUM(DECODE(event_type, 'RBS_PRG', 1, 0))   , 0)
  INTO   l_prg_change_exists
       , l_rbs_assoc_exists
       , l_rbs_prg_exists
  FROM pji_pa_proj_events_log
  WHERE 1=1
    AND worker_id = g_worker_id;

  BEGIN
    select /*+ ordered index(bv PA_BUDGET_VERSIONS_U2) */
      'Y'
    into
      l_dangl_exists
    from
      PJI_PJP_PROJ_BATCH_MAP map,
      PA_BUDGET_VERSIONS bv
    where
      map.WORKER_ID                = g_worker_id    and
      bv.PROJECT_ID                = map.PROJECT_ID and
      nvl(bv.WP_VERSION_FLAG, 'N') = 'N'            and
      bv.BUDGET_STATUS_CODE        = 'B'            and
      bv.PJI_SUMMARIZED_FLAG       = 'P'            and
	  bv.BUDGET_TYPE_CODE          is null          and        --Bug fix 6909152
	  bv.FIN_PLAN_TYPE_ID          is not null      and        --Bug fix 6909152
      rownum                       = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  print_time ( ' Do plan lines exist? ' || l_pl_exists );
  print_time ( ' Do prg_change events exist? ' || l_prg_change_exists );
  print_time ( ' Do rbs assoc events exist? ' || l_rbs_assoc_exists );
  print_time ( ' Do rbs prg events exist? ' || l_rbs_prg_exists );
  print_time ( ' Do dangling FP versions exist? ' || l_dangl_exists );


  IF (p_context = 'INCREMENTAL') THEN -- incr+rbsprg+rbsassoc+prgchange+dangling

    IF (l_pl_exists = 'Y') THEN

      --   Only actuals change, if yes then do program rollup.
      --   lat pub all the way up.

      l_context := l_context || 'c_incr_act_etc:';

    END IF;

    IF (l_rbs_assoc_exists > 0) THEN

      --   TN/TY slices don't change. New LNY data for baselined fps.
      --   All baselined fin plan for this proj/cb/co.

      l_context := l_context || 'c_all_baselined_fps_rbsassoc:' || 'c_all_cb_co_rbsassoc_above:';

    END IF;

    IF (l_rbs_prg_exists > 0) THEN

      --   TN/TY slices don't change. New LNY data for baselined fps.
      --   All baselined fin plan for this proj/cb/co *below* and above.

      l_context := l_context || 'c_all_bslnd_fps_rbsprg_below:'
                             || 'c_all_cb_co_rbsprg_above:' || 'c_all_cb_co_rbsprg_below:';

    END IF;

    IF (l_prg_change_exists > 0) THEN

      -- PRG_CHANGE
      --   Lock all projects in new prg based on event.

      l_context := l_context || 'c_all_plans_prg_chng:';

    END IF;

    IF (l_dangl_exists = 'Y') THEN

      -- PRG_CHANGE
      --   Lock all projects in new prg based on event.

      l_context := l_context || 'c_dangl_fps_self:' || 'c_dangl_cb_co_above:' ;

    END IF;

  ELSIF (p_context = 'FULL') THEN

    IF (l_pl_exists = 'Y') THEN

      --   Only actuals change, if yes then do program rollup.
      --   lat pub all the way up.

      l_context := l_context || 'c_incr_act_etc:';

    END IF;

  ELSIF (p_context = 'RBS') THEN

    --    No program rollups, TN/TY slices does not change.
    --    Act/etc can come in too.
    --    New LNY data, so program rollup can happen.
    --    Only baselined fin plans/cb/co lock. Also, lpv all the way up.

    IF (l_pl_exists = 'Y') THEN

      --   Only actuals change, if yes then do program rollup.
      --   lat pub all the way up.

      l_context := l_context || 'c_incr_act_etc:';

    END IF;


    l_context := l_context || 'c_all_baselined_fps_generic:' || 'c_all_cb_co_above:';


  ELSIF (p_context = 'PARTIAL') THEN

    --    Actuals may have come in. LNN slice could have changed. Program rollups happen. New LNY data.
    --    Act/etc can come in too.
    --    All plans for this project, lat pub all the way up, one wpwv above, cb/co.
    --    Only baselined fin plans/cb/co lock. Also, lpv all the way up.

    IF (l_pl_exists = 'Y') THEN

      --   Only actuals change, if yes then do program rollup.
      --   lat pub all the way up.

      l_context := l_context || 'c_incr_act_etc:';

    END IF;

    l_context := l_context || 'c_all_baselined_fps_generic:' || 'c_all_cb_co_above:' ;

  END IF;

  UPDATE_LOCKS (
    p_context       => l_context
  , p_update_mode   => p_lock_mode
  , x_return_status => x_return_status
  , x_msg_code      => x_msg_code );

  print_time(' Obtained lock flag in WBS header table. # rows is .. ' || SQL%ROWCOUNT );

EXCEPTION

  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => ' OBTAIN_RELEASE_LOCKS '
    , x_return_status  => x_return_status ) ;

    RAISE;
END;


--
-- bug 4863241
-- Lock mode: Lock during sumz='P', Unlock during sumz=NULL
--
PROCEDURE UPDATE_LOCKS (
  p_context         IN VARCHAR2
, p_update_mode     IN VARCHAR2 -- P => lock, NULL => unlock
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_code        OUT NOCOPY VARCHAR2 ) IS

  l_count_already_locked  NUMBER := 0;
  l_count_just_updated    NUMBER := 0;

  l_last_update_date     date   := SYSDATE;
  l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

  excp_resource_busy EXCEPTION;
  PRAGMA EXCEPTION_INIT(excp_resource_busy, -54);

  CURSOR c_get_hdrs_lock_ver3_t_cur IS
  SELECT 1
  FROM   pji_pjp_wbs_header
  WHERE (project_id, plan_type_id, plan_version_id) IN
        (SELECT DISTINCT project_id, plan_type_id, plan_version_id
         FROM   pji_fm_extr_plnver3_t)
  FOR UPDATE;

  CURSOR c_get_hdrs_lock_map_cur IS
  SELECT /*+ index(hd, pji_pjp_wbs_header_n1) */   1
  FROM   pji_pjp_wbs_header hd
  WHERE  (project_id, plan_version_id, plan_type_id) IN
  (  SELECT hd1.project_id, plan_version_id, plan_type_id
     FROM   pji_pjp_wbs_header hd1
          , pji_pjp_proj_batch_map map
     WHERE  hd1.project_id = map.project_id
       AND  map.worker_id = g_worker_id
       AND  (hd1.plan_version_id > 0 OR hd1.plan_version_id IN (-3, -4))
  )
  FOR UPDATE;

BEGIN

Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
( p_package_name   => g_package_name
, x_return_status  => x_return_status ) ;

print_time ( ' UPDATE_LOCKS: p_context = ' || p_context || ' p_update_mode = ' || NVL(p_update_mode, 'X'));

IF ( NVL(p_update_mode, 'X') NOT IN ( 'P', 'X') ) THEN
  print_time( ' Invalid context, returning: ' || p_update_mode);
  RETURN;
END IF;

IF (   p_context NOT LIKE '%c_incr_act_etc%'
   AND p_context NOT LIKE '%c_all_cb_co_above%'
   AND p_context NOT LIKE '%c_all_baselined_fps_generic%'
   AND p_context NOT LIKE '%c_all_plans_prg_chng%'
   AND p_context NOT LIKE '%c_all_cb_co_rbsprg_below%'
   AND p_context NOT LIKE '%c_all_cb_co_rbsprg_above%'
   AND p_context NOT LIKE '%c_all_bslnd_fps_rbsprg_below%'
   AND p_context NOT LIKE '%c_all_cb_co_rbsassoc_above%'
   AND p_context NOT LIKE '%c_all_baselined_fps_rbsassoc%'
   AND p_context NOT LIKE '%c_dangl_fps_self%'
   AND p_context NOT LIKE '%c_dangl_cb_co_above%'
) THEN
  print_time( ' Invalid p_context, returning: ' || p_context);
  RETURN;
END IF;

DELETE FROM pji_fm_extr_plnver3_t;

/*
IF (p_context LIKE '%c_incr_act_etc%' AND p_update_mode = 'P') THEN

  INSERT INTO pji_fm_extr_plnver3_t
  (project_id, plan_version_id, plan_type_id)
  SELECT / * + ORDERED * / -- INDEX(HD9, PJI_PJP_WBS_HEADER_N1)
        DISTINCT hd9.project_id, hd9.plan_version_id, hd9.plan_type_id
  FROM pji_pjp_proj_batch_map map
     , pji_fm_extr_plan_lines epl
     , pji_pjp_wbs_header hd2 -- SUB
     , pji_xbs_denorm den
     , pji_pjp_wbs_header hd9 -- SUP
     , PA_PROJ_ELEM_VER_STRUCTURE ppevs1
     , PA_PROJ_ELEM_VER_STRUCTURE ppevs2
  WHERE
        den.struct_version_id IS NULL
    AND hd2.plan_type_id = hd9.plan_type_id
    AND hd2.wbs_version_id = den.sub_id -- struct_version_id
    AND hd9.wbs_version_id = den.sup_id
    and hd9.project_id = den.sup_project_id
    -- AND den.sup_level < den.sub_level
    AND den.struct_type = 'PRG'
    AND NVL(den.relationship_type, 'WF') IN ('LW', 'WF') --  'LW',
    AND hd9.wp_flag = 'Y'
    AND ppevs1.project_id = hd9.project_id
    AND ppevs1.element_version_id = hd9.wbs_version_id
    AND ppevs1.latest_eff_published_flag = 'Y'
    AND hd2.wp_flag = 'Y'
    AND ppevs2.project_id = hd2.project_id
    AND ppevs2.element_version_id = hd2.wbs_version_id
    AND ppevs2.latest_eff_published_flag = 'Y'
    AND epl.project_id = hd2.project_id
    AND map.project_id = hd2.project_id
    AND map.worker_id = g_worker_id
    -- AND p_context LIKE '%c_incr_act_etc%'
   ;

END IF;
*/

IF (p_context LIKE '%c_all_cb_co_above%' AND p_update_mode = 'P') THEN

  INSERT INTO pji_fm_extr_plnver3_t
  (project_id, plan_version_id, plan_type_id)
  SELECT /*+ ORDERED */
        DISTINCT hd9.project_id, hd9.plan_version_id, hd9.plan_type_id
  FROM pji_pjp_proj_batch_map map
     , pji_pjp_wbs_header hd1 -- SUB
     , pji_xbs_denorm den
     , pji_pjp_wbs_header hd9 -- SUP
  WHERE
        den.struct_version_id IS NULL
    AND hd1.wbs_version_id = den.sub_id -- struct_version_id
    AND hd9.wbs_version_id = den.sup_id
    AND den.struct_type = 'PRG'
    AND hd9.project_id = den.sup_project_id
    AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF')  --  lf- sp.fp.str, wf/null- fsh.str, lw- sp.wp.str
    AND hd1.plan_version_id IN (-3, -4)
    AND hd9.plan_version_id IN (-3, -4)
    AND hd9.plan_type_id = hd1.plan_type_id
    AND map.worker_id = g_worker_id
    AND hd1.project_id = map.project_id
    -- AND p_context LIKE '%c_all_cb_co_above%'
    ;

END IF;

IF (p_context LIKE '%c_all_baselined_fps_generic%' AND p_update_mode = 'P') THEN

  INSERT INTO pji_fm_extr_plnver3_t
  (project_id, plan_version_id, plan_type_id)
  SELECT
        DISTINCT bv.project_id, bv.budget_version_id, bv.fin_plan_type_id
  FROM  pji_pjp_proj_batch_map map
      , PA_BUDGET_VERSIONS bv
  WHERE
         map.worker_id = g_worker_id
     AND bv.project_id = map.project_id
     AND NVL(bv.wp_version_flag, 'N') = 'N'
     AND bv.budget_status_code = 'B'
     -- AND p_context LIKE '%c_all_baselined_fps_generic%'
     ;

END IF;


IF (p_context LIKE '%c_all_plans_prg_chng%') THEN -- !! ONLY FOR PRG_CHANGE

  INSERT INTO pji_fm_extr_plnver3_t
  (project_id, plan_version_id, plan_type_id)
  SELECT DISTINCT hd9.project_id, hd9.plan_version_id, hd9.plan_type_id
  FROM -- pji_pjp_wbs_header hd2
       -- pa_proj_elem_ver_structure hd2
       pji_pa_proj_events_log ev
     , Pa_XBS_DENORM den
     , pji_pjp_wbs_header hd9 -- SUP
  WHERE
        den.struct_version_id IS NULL
    AND hd9.wbs_version_id = den.sup_id -- struct_version_id
    -- AND hd2.element_version_id = den.sub_id
	-- AND hd2.project_id > 0
	AND hd9.project_id = den.sup_project_id
    AND den.struct_type = 'PRG'
    AND den.prg_group IN ( TO_NUMBER(ev.event_object), TO_NUMBER(ev.attribute1))
    AND ev.worker_id = g_worker_id
    AND ev.event_type = 'PRG_CHANGE'
    AND (  hd9.plan_version_id > 0
        OR hd9.plan_version_id IN (-3, -4) )
    -- AND p_context LIKE '%c_all_plans_prg_chng%'
    ;

END IF;


IF (p_context LIKE '%c_all_cb_co_rbsprg_below%' AND p_update_mode = 'P') THEN

  INSERT INTO pji_fm_extr_plnver3_t
  (project_id, plan_version_id, plan_type_id)
  SELECT /*+ ordered */
       DISTINCT hd2.project_id, hd2.plan_version_id, hd2.plan_type_id
  FROM
       pji_pjp_proj_batch_map map
     , pji_pa_proj_events_log ev
     , pji_pjp_wbs_header hd9 -- SUP
     , pji_xbs_denorm den
     , pji_pjp_wbs_header hd2 -- SUB
  WHERE
        den.struct_version_id IS NULL
    AND hd9.wbs_version_id = den.sub_id -- struct_version_id
    AND hd2.wbs_version_id = den.sup_id
    AND hd9.project_id = den.sup_project_id
    AND den.struct_type = 'PRG'
    AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF') --  lf- sp.fp.str, wf/null- fsh.str, lw- sp.wp.str
    AND hd9.plan_version_id IN (-3, -4)
    AND hd2.plan_version_id IN (-3, -4)
    AND map.worker_id = g_worker_id
    AND ev.worker_id = g_worker_id
    AND ev.event_type = 'RBS_PRG'
    AND TO_NUMBER(ev.attribute1) = map.project_id
    AND hd9.project_id = map.project_id
    AND hd9.plan_type_id = hd2.plan_type_id
    -- AND p_context LIKE '%c_all_cb_co_rbsprg_below%'
    ;

END IF;


IF (p_context LIKE '%c_all_baselined_fps_rbsassoc%' AND p_update_mode = 'P') THEN

  INSERT INTO pji_fm_extr_plnver3_t
  (project_id, plan_version_id, plan_type_id)
  SELECT DISTINCT hd9.project_id, hd9.plan_version_id, hd9.plan_type_id
  FROM  pji_pjp_proj_batch_map map
      , pji_pa_proj_events_log ev
      , pji_pjp_wbs_header hd9 -- SUP
  WHERE
         map.worker_id = g_worker_id
     AND ev.worker_id = g_worker_id
     AND ev.event_type = 'RBS_ASSOC'
     AND TO_NUMBER(ev.attribute1) = map.project_id
     AND hd9.wp_flag = 'N'
     AND hd9.cb_flag || hd9.co_flag LIKE '%Y%'
     AND hd9.project_id = map.project_id
     AND not exists(select null
     				from pji_fp_xbs_accum_f fact
     				where fact.project_id = hd9.project_id
     				and fact.plan_version_id = hd9.plan_version_id
     				and fact.plan_type_id  = hd9.plan_type_id
     				and fact.rbs_version_id = ev.event_object)
     -- AND p_context LIKE '%c_all_baselined_fps_rbsassoc%'
   ;

END IF;


IF (p_context LIKE '%c_all_cb_co_rbsassoc_above_cur%' AND p_update_mode = 'P') THEN

  INSERT INTO pji_fm_extr_plnver3_t
  (project_id, plan_version_id, plan_type_id)
  SELECT DISTINCT hd9.project_id, hd9.plan_version_id, hd9.plan_type_id
  FROM pji_xbs_denorm den
     , pji_pjp_wbs_header hd1 -- SUB
     , pji_pjp_proj_batch_map map
     , pji_pa_proj_events_log ev
     , pji_pjp_wbs_header hd9 -- SUP
  WHERE
        den.struct_version_id IS NULL
    AND hd1.wbs_version_id = den.sub_id -- struct_version_id
    AND hd9.wbs_version_id = den.sup_id
    AND hd9.project_id = den.sup_project_id
    AND den.struct_type = 'PRG'
    AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF')
    --  lf- sp.fp.str, wf/null- fsh.str, lw- sp.wp.str
    AND hd1.plan_version_id IN (-3, -4)
    AND hd9.plan_version_id IN (-3, -4)
    AND map.worker_id = g_worker_id
    AND ev.worker_id = g_worker_id
    AND ev.event_type = 'RBS_ASSOC'
    AND TO_NUMBER(ev.attribute1) = map.project_id
    AND hd1.project_id = map.project_id
    AND hd9.plan_type_id = hd1.plan_type_id
    AND not exists(select null
     				from pji_fp_xbs_accum_f fact
     				where fact.project_id = hd9.project_id
     				and fact.plan_version_id = hd9.plan_version_id
     				and fact.plan_type_id  = hd9.plan_type_id
     				and fact.rbs_version_id = ev.event_object)
    -- AND p_context LIKE '%c_all_cb_co_rbsassoc_above%'
    ;

END IF;


IF (p_context LIKE '%c_all_bslnd_fps_rbsprg_below%' AND p_update_mode = 'P') THEN

  INSERT INTO pji_fm_extr_plnver3_t
  (project_id, plan_version_id, plan_type_id)
  SELECT /*+ ordered */
         DISTINCT hd9.project_id, hd9.plan_version_id, hd9.plan_type_id
  FROM   pji_pjp_proj_batch_map map
       , pji_pa_proj_events_log ev
       -- , PA_BUDGET_VERSIONS bv
       , pji_xbs_denorm den
       , pji_pjp_wbs_header wh1 -- sup
       , pji_pjp_wbs_header hd9 -- SUb!!
  WHERE
        den.struct_version_id IS NULL
    AND hd9.wbs_version_id = den.sub_id -- struct_version_id
    AND wh1.wbs_version_id = den.sup_id
	AND wh1.project_id = den.sup_project_id
    AND den.struct_type = 'PRG'
    AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF')
    AND map.worker_id = g_worker_id
    AND ev.worker_id = g_worker_id
    AND ev.event_type = 'RBS_PRG'
    AND TO_NUMBER(ev.attribute1) = map.project_id
    AND wh1.project_id = map.project_id
    AND hd9.wp_flag = 'N'
    AND wh1.wp_flag = 'N'
    AND hd9.plan_version_id > 0
    AND wh1.plan_version_id > 0
    AND hd9.plan_type_id = wh1.plan_type_id
    AND hd9.cb_flag || hd9.co_flag LIKE '%Y%'
    -- AND p_context LIKE '%c_all_bslnd_fps_rbsprg_below%'
    ;

END IF;


IF (p_context LIKE '%c_all_cb_co_rbsprg_above%' AND p_update_mode = 'P') THEN

  INSERT INTO pji_fm_extr_plnver3_t
  (project_id, plan_version_id, plan_type_id)
  SELECT DISTINCT hd9.project_id, hd9.plan_version_id, hd9.plan_type_id
  FROM pji_xbs_denorm den
     , pji_pjp_wbs_header hd2 -- SUB
     , pji_pjp_proj_batch_map map
     , pji_pa_proj_events_log ev
     , pji_pjp_wbs_header hd9 -- SUP
  WHERE
        den.struct_version_id IS NULL
    AND hd9.wbs_version_id = den.sup_id -- struct_version_id
    AND hd2.wbs_version_id = den.sub_id
    AND hd9.project_id = den.sup_project_id
    AND den.struct_type = 'PRG'
    AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF') --  lf- sp.fp.str, wf/null- fsh.str, lw- sp.wp.str
    AND hd9.plan_version_id IN (-3, -4)
    AND hd2.plan_version_id IN (-3, -4)
    AND map.worker_id = g_worker_id
    AND ev.worker_id = g_worker_id
    AND ev.event_type = 'RBS_PRG'
    AND TO_NUMBER(ev.attribute1) = map.project_id
    AND hd2.project_id = map.project_id
    AND hd9.plan_type_id = hd2.plan_type_id
    -- AND p_context LIKE '%c_all_cb_co_rbsprg_above%'
    ;

END IF;


IF (p_context LIKE '%c_dangl_fps_self%' AND p_update_mode = 'P') THEN

  INSERT INTO pji_fm_extr_plnver3_t
  (project_id, plan_version_id, plan_type_id)
  SELECT DISTINCT hd9.project_id, hd9.plan_version_id, hd9.plan_type_id
  FROM  pji_pjp_proj_batch_map map
      , PA_BUDGET_VERSIONS bv
      , pji_pjp_wbs_header hd9 -- SUP
  WHERE
         map.worker_id = g_worker_id
     AND hd9.project_id = map.project_id
     AND hd9.project_id = bv.project_id
     AND hd9.plan_version_id = bv.budget_version_id
     AND hd9.wp_flag = 'N'
     AND bv.budget_status_code = 'B'
     AND bv.pji_summarized_flag = 'P'
     -- AND hd.lock_flag IS NOT NULL
     -- AND p_context LIKE '%c_dangl_fps_self%'
     ;

END IF;


IF (p_context LIKE '%c_dangl_cb_co_above%' AND p_update_mode = 'P') THEN

  INSERT INTO pji_fm_extr_plnver3_t
  (project_id, plan_version_id, plan_type_id)
  SELECT DISTINCT hd9.project_id, hd9.plan_version_id, hd9.plan_type_id
  FROM pji_xbs_denorm den
     , pji_pjp_wbs_header hd1 -- SUB
     , pji_pjp_proj_batch_map map
     , pa_budget_versions bv
     , pji_pjp_wbs_header hd9 -- SUP
  WHERE
        den.struct_version_id IS NULL
    AND map.project_id = bv.project_id
	AND map.project_id = hd1.project_id
    AND hd1.wp_flag = 'N'
    AND hd1.plan_type_id = bv.fin_plan_type_id
    AND bv.budget_status_code = 'B'
    AND bv.pji_summarized_flag = 'P'
    AND hd1.wbs_version_id = den.sub_id -- struct_version_id
    AND hd9.wbs_version_id = den.sup_id
    AND hd9.project_id = den.sup_project_id
    AND den.struct_type = 'PRG'
    AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF')
    --  lf- sp.fp.str, wf/null- fsh.str, lw- sp.wp.str
    AND hd1.plan_version_id IN (-3, -4)
    AND hd9.plan_version_id IN (-3, -4)
    AND map.worker_id = g_worker_id
    AND hd1.project_id = map.project_id
    AND hd9.plan_type_id = bv.fin_plan_type_id
    AND hd9.plan_type_id = hd1.plan_type_id
    AND hd1.plan_version_id = hd9.plan_version_id
    -- AND p_context LIKE '%c_dangl_cb_co_above%'
    ;

END IF;


  OPEN   c_get_hdrs_lock_ver3_t_cur;
  CLOSE  c_get_hdrs_lock_ver3_t_cur;

  UPDATE pji_pjp_wbs_header hd9 -- SUP
  SET    lock_flag         = p_update_mode
       , LAST_UPDATE_DATE  = l_last_update_date
       , LAST_UPDATED_BY   = l_last_updated_by
       , LAST_UPDATE_LOGIN = l_last_update_login
  WHERE (project_id, plan_type_id, plan_version_id) IN
        (SELECT DISTINCT project_id, plan_type_id, plan_version_id
         FROM   pji_fm_extr_plnver3_t);

  print_time ( ' UPDATE_LOCKS # updated hdrs = ' || SQL%ROWCOUNT );

  DELETE FROM pji_fm_extr_plnver3_t;
  print_time ( ' # of records deleted in plnver3 = ' || SQL%ROWCOUNT );


  IF (p_update_mode IS NULL) THEN

    OPEN   c_get_hdrs_lock_map_cur;
    CLOSE  c_get_hdrs_lock_map_cur;

    update PJI_PJP_WBS_HEADER hd9
    set    LOCK_FLAG         = null,
           LAST_UPDATE_DATE  = l_last_update_date,
           LAST_UPDATED_BY   = l_last_updated_by,
           LAST_UPDATE_LOGIN = l_last_update_login
    where  (hd9.PLAN_VERSION_ID > 0 or
            hd9.PLAN_VERSION_ID in (-3, -4)) and
           exists
           (
           select
             1
           from
             PJI_PJP_PROJ_BATCH_MAP map
           where
             map.WORKER_ID = g_worker_id and
             hd9.PROJECT_ID = map.PROJECT_ID
           );

    print_time ( ' UPDATE_LOCKS # additional hdrs updated in unlock hdrs for prg change = ' || SQL%ROWCOUNT );

  END IF;


EXCEPTION

  WHEN excp_resource_busy THEN

    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    x_msg_code := Fnd_Message.GET_STRING(  APPIN => 'PJI'
                                        , NAMEIN => 'PJI_LOCK_NOT_OBTAINED');

    -- PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PJI'
    --                    , p_msg_name       => 'PJI_LOCK_NOT_OBTAINED');
    Fnd_Message.SET_NAME('PJI', 'PJI_LOCK_NOT_OBTAINED');
    Fnd_Msg_Pub.add_detail(p_message_type=>Fnd_Api.G_RET_STS_ERROR);

    print_time ( ' UPDATE_LOCKS exception ' || SQLERRM);

    Pji_Pjp_Fp_Curr_Wrap.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => ' UPDATE_LOCKS '
    , x_return_status => x_return_status ) ;

    RAISE;

  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => ' UPDATE_LOCKS '
    , x_return_status  => x_return_status ) ;

    RAISE;

END;


--
-- Get the budget versions that need to be extracted INTO a temp table.
-- This is to set scope for extraction as well as track time/curr dangling records
--  in the case of secondary slice creation.
--
-- !!!! Add event handler for RBS_PRG.
--
PROCEDURE EXTRACT_FIN_PLAN_VERS_BULK(
  p_slice_type        IN   VARCHAR2 := NULL  -- 'PRI' or 'SEC' or 'SECRBS'
) IS
  l_prg_exists varchar2(1) := 'N';
  /* Added for bug 8708651 */
  l_up_process_flag varchar2(1);
  l_profile_check varchar2(30);
  l_RBS_ASSOC_exists  varchar2(1) := 'Y' ;
  l_RBS_PRG_exists varchar2(1)    := 'Y' ;
  l_PRG_CHANGE_exists varchar2(1) := 'Y';
BEGIN

  print_time('EXTRACT_FIN_PLAN_VERS_BULK : Begin ' );

    /* Added for bug 8708651 starts */
    begin

       select 'Y'
       into l_RBS_ASSOC_exists
       from dual
       where exists
       ( select 'x'
         from pji_pa_proj_events_log
         where worker_id = g_worker_id
         and event_type = 'RBS_ASSOC'
       );

    exception

    when no_data_found then

    l_RBS_ASSOC_exists := 'N';

    end;


    begin

       select 'Y'
       into l_RBS_PRG_exists
       from dual
       where exists
       ( select 'x'
         from pji_pa_proj_events_log
         where worker_id = g_worker_id
         and event_type = 'RBS_PRG'
       );

    exception

    when no_data_found then

    l_RBS_PRG_exists := 'N';

    end;

    begin

       select 'Y'
       into l_PRG_CHANGE_exists
       from dual
       where exists
       ( select 'x'
         from pji_pa_proj_events_log
         where worker_id = g_worker_id
         and event_type = 'PRG_CHANGE'
       );

    exception

    when no_data_found then

    l_PRG_CHANGE_exists := 'N';

    end;
   /* Added for bug 8708651 ends */

  IF ( p_slice_type NOT IN ('PRI', 'SEC', 'SECRBS', 'SEC_PROJ', 'SECRBS_PROJ') ) THEN
    print_time('EXTRACT_FIN_PLAN_VERSIONS : Invalid slice type. Exitting. ' );
    RETURN;
  END IF;

   /* Added for bug 8708651 starts */
  l_profile_check := FND_PROFILE.VALUE('PJI_SUM_CLEANALL');
  l_up_process_flag := PJI_UTILS.GET_SETUP_PARAMETER('UP_PROCESS_FLAG');
  /* Added for bug 8708651 ends */

  --#bug 5356051
  begin
    select 'Y'
    into l_prg_exists
    from dual
    where exists (
      select null
      from
        pa_proj_element_versions proj
      where
        proj.prg_group is not null
        and rownum <=1
    );
  exception
    when no_data_found then
      l_prg_exists := 'N';
  end;
  --#bug 5356051

  IF ( p_slice_type = 'PRI') THEN

  if (l_up_process_flag = 'Y') then  /* Added for bug 8708651 */

    INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	CURRENT_FLAG             ,
	ORIGINAL_FLAG            ,
	CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG        	 ,
      SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
      SELECT
            g_worker_id
          , bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
          , fpo.rbs_version_id                 rbs_struct_version_id
 --         , to_char(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
	          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code
          , NULL                             time_dangling_flag   -- to be used for dangling check.
          , NULL                             rate_dangling_flag   -- to be used for dangling check.
          , NULL                             PROJECT_TYPE_CLASS
		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
  	        , 'N'  		                     SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
                                 -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
           pa_budget_versions bv -- @pjdev115  bv
         , pa_proj_fp_options  fpo -- @pjdev115  fpo
         , pa_projects_all  ppa -- @pjdev115    ppa
      WHERE 1=1
          AND ppa.project_id = bv.project_id
          AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
          AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
	  AND bv.fin_plan_type_id = 10  /* Added for bug 8708651*/
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
          UNION ALL
                SELECT
                g_worker_id
              , bv.project_id                      project_id
              , bv.budget_version_id               plan_version_id
              , DECODE ( NVL(bv.wp_version_flag, 'N')
    		           , 'Y', bv.project_structure_version_id
    		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
    				   )                           wbs_struct_version_id
              , fpo.rbs_version_id                 rbs_struct_version_id
     --         , to_char(fpo.fin_plan_type_id)      plan_type_code
              , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527 */
              , fpo.fin_plan_type_id               plan_type_id
    	          , DECODE(bv.version_type
                          , 'ALL',     fpo.all_time_phased_code
                          , 'COST',    fpo.cost_time_phased_code
                          , 'REVENUE', fpo.revenue_time_phased_code
                         )                       time_phased_type_code
              , NULL                             time_dangling_flag   -- to be used for dangling check.
              , NULL                             rate_dangling_flag   -- to be used for dangling check.
              , NULL                             PROJECT_TYPE_CLASS
    		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
    		  , bv.current_flag                  current_flag
    		  , bv.original_flag                 original_flag
    		  , bv.current_original_flag         current_original_flag
    		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
      	        , 'N'  		                     SECONDARY_RBS_FLAG
    		  , DECODE( NVL(bv.wp_version_flag, 'N')
    		          , 'Y'
    				  , DECODE(bv.project_structure_version_id
    				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
                                     -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
    						 , 'Y'
    						 , 'N')
    				  , 'N'
    				  ) lp_flag
          FROM
               pa_budget_versions bv -- @pjdev115  bv
             , pa_proj_fp_options  fpo -- @pjdev115  fpo
             , pa_projects_all  ppa -- @pjdev115    ppa
          WHERE 1=1
              AND ppa.project_id = bv.project_id
              AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
              AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
              AND fpo.project_id = bv.project_id
              AND bv.fin_plan_type_id = fpo.fin_plan_type_id
              AND bv.budget_version_id = fpo.fin_plan_version_id
              AND bv.fin_plan_type_id <> 10  /* Added for bug 8708651*/
              AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
              AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE')
              AND (bv.current_flag = 'Y' or bv.current_original_flag = 'Y')  /* Added for bug 8708651*/
          UNION ALL
                SELECT
                g_worker_id
              , bv.project_id                      project_id
              , bv.budget_version_id               plan_version_id
              , DECODE ( NVL(bv.wp_version_flag, 'N')
    		           , 'Y', bv.project_structure_version_id
    		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
    				   )                           wbs_struct_version_id
              , fpo.rbs_version_id                 rbs_struct_version_id
     --         , to_char(fpo.fin_plan_type_id)      plan_type_code
              , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527 */
              , fpo.fin_plan_type_id               plan_type_id
    	          , 'N'                            time_phased_type_code  /* Added for bug 8708651*/
              , NULL                             time_dangling_flag   -- to be used for dangling check.
              , NULL                             rate_dangling_flag   -- to be used for dangling check.
              , NULL                             PROJECT_TYPE_CLASS
    		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
    		  , bv.current_flag                  current_flag
    		  , bv.original_flag                 original_flag
    		  , bv.current_original_flag         current_original_flag
    		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
      	        , 'N'  		                     SECONDARY_RBS_FLAG
    		  , DECODE( NVL(bv.wp_version_flag, 'N')
    		          , 'Y'
    				  , DECODE(bv.project_structure_version_id
    				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
                                     -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
    						 , 'Y'
    						 , 'N')
    				  , 'N'
    				  ) lp_flag
          FROM
               pa_budget_versions bv -- @pjdev115  bv
             , pa_proj_fp_options  fpo -- @pjdev115  fpo
             , pa_projects_all  ppa -- @pjdev115    ppa
          WHERE 1=1
              AND ppa.project_id = bv.project_id
              AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
              AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
              AND fpo.project_id = bv.project_id
              AND bv.fin_plan_type_id <> 10  /* Added for bug 8708651*/
              AND bv.fin_plan_type_id = fpo.fin_plan_type_id
              AND bv.budget_version_id = fpo.fin_plan_version_id
              AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
              AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE')
              AND (bv.current_flag = 'N' and bv.current_original_flag = 'N')  /* Added for bug 8708651*/
              ;

    else

        INSERT INTO PJI_FM_EXTR_PLNVER4
        (
          WORKER_ID                ,
          PROJECT_ID               ,
          PLAN_VERSION_ID          ,
          WBS_STRUCT_VERSION_ID    ,
          RBS_STRUCT_VERSION_ID    ,
          PLAN_TYPE_CODE           ,
          PLAN_TYPE_ID             ,
          TIME_PHASED_TYPE_CODE    ,
          TIME_DANGLING_FLAG       ,
          RATE_DANGLING_FLAG       ,
          PROJECT_TYPE_CLASS       ,
          WP_FLAG                  ,
    	CURRENT_FLAG             ,
    	ORIGINAL_FLAG            ,
    	CURRENT_ORIGINAL_FLAG    ,
    	BASELINED_FLAG        	 ,
          SECONDARY_RBS_FLAG       ,
          LP_FLAG
        )
          SELECT
                g_worker_id
              , bv.project_id                      project_id
              , bv.budget_version_id               plan_version_id
              , DECODE ( NVL(bv.wp_version_flag, 'N')
    		           , 'Y', bv.project_structure_version_id
    		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
    				   )                           wbs_struct_version_id
              , fpo.rbs_version_id                 rbs_struct_version_id
     --         , to_char(fpo.fin_plan_type_id)      plan_type_code
              , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
              , fpo.fin_plan_type_id               plan_type_id
    	          , DECODE(bv.version_type
                          , 'ALL',     fpo.all_time_phased_code
                          , 'COST',    fpo.cost_time_phased_code
                          , 'REVENUE', fpo.revenue_time_phased_code
                         )                       time_phased_type_code
              , NULL                             time_dangling_flag   -- to be used for dangling check.
              , NULL                             rate_dangling_flag   -- to be used for dangling check.
              , NULL                             PROJECT_TYPE_CLASS
    		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
    		  , bv.current_flag                  current_flag
    		  , bv.original_flag                 original_flag
    		  , bv.current_original_flag         current_original_flag
    		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
      	        , 'N'  		                     SECONDARY_RBS_FLAG
    		  , DECODE( NVL(bv.wp_version_flag, 'N')
    		          , 'Y'
    				  , DECODE(bv.project_structure_version_id
    				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
                                     -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
    						 , 'Y'
    						 , 'N')
    				  , 'N'
    				  ) lp_flag
          FROM
               pa_budget_versions bv -- @pjdev115  bv
             , pa_proj_fp_options  fpo -- @pjdev115  fpo
             , pa_projects_all  ppa -- @pjdev115    ppa
          WHERE 1=1
              AND ppa.project_id = bv.project_id
              AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
              AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
              AND fpo.project_id = bv.project_id
              AND bv.fin_plan_type_id = fpo.fin_plan_type_id
              AND bv.budget_version_id = fpo.fin_plan_version_id
              AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
              AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
    ;
    end if;

  --#bug 5356051
  If l_prg_exists = 'Y' then --Programs exist, need to insert -3/-4 for programs as well


    INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	  CURRENT_FLAG             ,
	  ORIGINAL_FLAG            ,
	  CURRENT_ORIGINAL_FLAG    ,
	  BASELINED_FLAG        	 ,
      SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
      SELECT DISTINCT -- For insertion of -3/-4 header records.
            g_worker_id worker_id
          , den.sup_project_id                      project_id
          , cbco.plan_version_id               plan_version_id
          , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(den.sup_project_id) wbs_struct_version_id
          , hd2.rbs_struct_version_id        rbs_version_id
          , hd2.plan_type_code plan_type_code  /*4471527 */
          , hd2.plan_type_id                 plan_type_id
          , hd2.time_phased_type_code        time_phased_type_code
          , NULL                             TIME_DANGLING_FLAG
          , NULL                             RATE_DANGLING_FLAG
          , NULL                             PROJECT_TYPE_CLASS
		  , 'N'                              is_wp_flag
		  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') current_flag
		  , NULL                             original_flag
		  , DECODE(cbco.plan_version_id, -4, 'Y', 'N') current_original_flag
		  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , 'Y'                              lp_flag
	  FROM
           pji_fm_extr_plnver4 hd2 -- sub
         , pji_xbs_denorm den
         , ( SELECT -3 plan_version_id FROM dual
             UNION ALL
             SELECT -4 plan_version_id FROM dual ) cbco
      WHERE
              hd2.baselined_flag = 'Y'
	      AND hd2.wp_flag = 'N'
          AND hd2.worker_id = g_worker_id
          AND den.struct_version_id IS NULL
          AND hd2.wbs_struct_version_id = den.sub_id
          AND den.struct_type = 'PRG'
          AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF');

  elsif l_prg_exists = 'N' then

    INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
      CURRENT_FLAG             ,
      ORIGINAL_FLAG            ,
      CURRENT_ORIGINAL_FLAG    ,
      BASELINED_FLAG        	 ,
      SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
      SELECT DISTINCT -- For insertion of -3/-4 header records.
            g_worker_id worker_id
          , hd2.project_id                     project_id
          , cbco.plan_version_id               plan_version_id
          , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(hd2.project_id) wbs_struct_version_id
          , hd2.rbs_struct_version_id        rbs_version_id
          , hd2.plan_type_code plan_type_code  /*4471527 */
          , hd2.plan_type_id                 plan_type_id
          , hd2.time_phased_type_code        time_phased_type_code
          , NULL                             TIME_DANGLING_FLAG
          , NULL                             RATE_DANGLING_FLAG
          , NULL                             PROJECT_TYPE_CLASS
          , 'N'                              is_wp_flag
	  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') current_flag
	  , NULL                             original_flag
	  , DECODE(cbco.plan_version_id, -4, 'Y', 'N') current_original_flag
	  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') baselined_flag
	  , 'Y' 	  		                 SECONDARY_RBS_FLAG
          , 'Y'                              lp_flag
       FROM
           pji_fm_extr_plnver4 hd2 -- sub
         , ( SELECT -3 plan_version_id FROM dual
             UNION ALL
             SELECT -4 plan_version_id FROM dual ) cbco
      WHERE
              hd2.baselined_flag = 'Y'
	  AND hd2.wp_flag = 'N'
          AND hd2.worker_id = g_worker_id;

  end if;
  --#bug 5356051


  ELSIF ( p_slice_type = 'SEC') THEN

    INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	CURRENT_FLAG             ,
	ORIGINAL_FLAG            ,
	CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG        	 ,
      SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
      SELECT
            g_worker_id
          , bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
          , fpo.rbs_version_id                 rbs_struct_version_id
--          , to_char(fpo.fin_plan_type_id)      plan_type_code
              , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code
          , NULL                             time_dangling_flag   -- to be used for dangling check.
          , NULL                             rate_dangling_flag   -- to be used for dangling check.
          , NULL                             PROJECT_TYPE_CLASS
		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
  	      , 'N'  		                     SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
           pa_budget_versions bv -- @pjdev115  bv
         , pa_proj_fp_options  fpo -- @pjdev115  fpo
         , pa_projects_all  ppa -- @pjdev115    ppa
      WHERE 1=1
          AND ppa.project_id = bv.project_id
          AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
          AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
          AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
          AND bv.budget_status_code = 'B'
          AND NVL(bv.wp_version_flag, 'N') = 'N';


  ELSIF ( p_slice_type = 'SECRBS') THEN

    INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	CURRENT_FLAG             ,
	ORIGINAL_FLAG            ,
	CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG        	 ,
      SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
      SELECT
            g_worker_id
          , bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
		  , rpa.rbs_version_id                 rbs_struct_version_id
          -- , fpo.rbs_version_id                 rbs_struct_version_id
--          , to_char(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code
          , NULL                             time_dangling_flag   -- to be used for dangling check.
          , NULL                             rate_dangling_flag   -- to be used for dangling check.
          , NULL                             PROJECT_TYPE_CLASS
		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
           pa_budget_versions bv -- @pjdev115  bv
         , pa_proj_fp_options  fpo -- @pjdev115  fpo
         , pa_projects_all  ppa -- @pjdev115    ppa
		 , PA_RBS_PRJ_ASSIGNMENTS rpa
      WHERE 1=1
          AND ppa.project_id = bv.project_id
          AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
          AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
          AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
          AND bv.budget_status_code = 'B'
	    AND rpa.project_id = bv.project_id
	    -- AND DECODE ( rpa.wp_usage_flag, 'Y', 'Y', 'X') = NVL(bv.wp_version_flag, 'N')
	    -- AND DECODE ( rpa.fp_usage_flag, 'Y', 'N', 'X') = NVL(bv.wp_version_flag, 'N')
	    AND rpa.assignment_status = 'ACTIVE'
	    AND NVL(fpo.rbs_version_id, -1) <> rpa.rbs_version_id
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
	    AND rpa.reporting_usage_flag = 'Y';

/*Plans are restricted by the projects chosen by the user*/

  ELSIF ( p_slice_type = 'SEC_PROJ') THEN

  if (upper(nvl(l_profile_check, 'N')) = 'Y') then /* Added for bug 8708651 */

      INSERT INTO PJI_FM_EXTR_PLNVER4
      (
        WORKER_ID                ,
        PROJECT_ID               ,
        PLAN_VERSION_ID          ,
        WBS_STRUCT_VERSION_ID    ,
        RBS_STRUCT_VERSION_ID    ,
        PLAN_TYPE_CODE           ,
        PLAN_TYPE_ID             ,
        TIME_PHASED_TYPE_CODE    ,
        TIME_DANGLING_FLAG       ,
        RATE_DANGLING_FLAG       ,
        PROJECT_TYPE_CLASS       ,
        WP_FLAG                  ,
  	CURRENT_FLAG             ,
  	ORIGINAL_FLAG            ,
  	CURRENT_ORIGINAL_FLAG    ,
  	BASELINED_FLAG        	 ,
        SECONDARY_RBS_FLAG       ,
        LP_FLAG
      )
        SELECT /*+ ordered use_nl( map bv ppa fpo ) */
              g_worker_id
            , bv.project_id                      project_id
            , bv.budget_version_id               plan_version_id
            , DECODE ( NVL(bv.wp_version_flag, 'N')
  		           , 'Y', bv.project_structure_version_id
  		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
  				   )                           wbs_struct_version_id
            , fpo.rbs_version_id                 rbs_struct_version_id
  --          , to_char(fpo.fin_plan_type_id)      plan_type_code
            , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
            , fpo.fin_plan_type_id               plan_type_id
            , DECODE(bv.version_type
                        , 'ALL',     fpo.all_time_phased_code
                        , 'COST',    fpo.cost_time_phased_code
                        , 'REVENUE', fpo.revenue_time_phased_code
                       )                       time_phased_type_code
            , NULL                             time_dangling_flag   -- to be used for dangling check.
            , NULL                             rate_dangling_flag   -- to be used for dangling check.
            , NULL                             PROJECT_TYPE_CLASS
  		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
  		  , bv.current_flag                  current_flag
  		  , bv.original_flag                 original_flag
  		  , bv.current_original_flag         current_original_flag
  		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
    	      , 'N'  		                     SECONDARY_RBS_FLAG
  		  , DECODE( NVL(bv.wp_version_flag, 'N')
  		          , 'Y'
  				  , DECODE(bv.project_structure_version_id
  				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
  				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
  						 , 'Y'
  						 , 'N')
  				  , 'N'
  				  ) lp_flag
        FROM
             pji_pjp_proj_batch_map map
           , pa_budget_versions bv -- @pjdev115  bv
           , pa_projects_all  ppa -- @pjdev115    ppa
           , pa_proj_fp_options  fpo -- @pjdev115  fpo
        WHERE 1=1
            AND ppa.project_id = bv.project_id
            AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
            AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
            AND fpo.project_id = bv.project_id
            AND bv.fin_plan_type_id = fpo.fin_plan_type_id
            AND bv.budget_version_id = fpo.fin_plan_version_id
            AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
            AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
            AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
            AND bv.budget_status_code = 'B'
            AND NVL(bv.wp_version_flag, 'N') = 'N'
  		AND ppa.project_id = map.project_id
  		AND map.worker_id = g_worker_id
  		AND (bv.current_flag = 'Y' or bv.current_original_flag = 'Y')  /* Added for bug 8708651 */
        UNION ALL
        SELECT /*+ ordered use_nl( map bv ppa fpo ) */
              g_worker_id
            , bv.project_id                      project_id
            , bv.budget_version_id               plan_version_id
            , DECODE ( NVL(bv.wp_version_flag, 'N')
  		           , 'Y', bv.project_structure_version_id
  		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
  				   )                           wbs_struct_version_id
            , fpo.rbs_version_id                 rbs_struct_version_id
  --          , to_char(fpo.fin_plan_type_id)      plan_type_code
            , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
            , fpo.fin_plan_type_id               plan_type_id
            , 'N'                              time_phased_type_code
            , NULL                             time_dangling_flag   -- to be used for dangling check.
            , NULL                             rate_dangling_flag   -- to be used for dangling check.
            , NULL                             PROJECT_TYPE_CLASS
  		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
  		  , bv.current_flag                  current_flag
  		  , bv.original_flag                 original_flag
  		  , bv.current_original_flag         current_original_flag
  		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
    	      , 'N'  		                     SECONDARY_RBS_FLAG
  		  , DECODE( NVL(bv.wp_version_flag, 'N')
  		          , 'Y'
  				  , DECODE(bv.project_structure_version_id
  				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
  				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
  						 , 'Y'
  						 , 'N')
  				  , 'N'
  				  ) lp_flag
        FROM
             pji_pjp_proj_batch_map map
           , pa_budget_versions bv -- @pjdev115  bv
           , pa_projects_all  ppa -- @pjdev115    ppa
           , pa_proj_fp_options  fpo -- @pjdev115  fpo
        WHERE 1=1
            AND ppa.project_id = bv.project_id
            AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
            AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
            AND fpo.project_id = bv.project_id
            AND bv.fin_plan_type_id = fpo.fin_plan_type_id
            AND bv.budget_version_id = fpo.fin_plan_version_id
            AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
            AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
            AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
            AND bv.budget_status_code = 'B'
            AND NVL(bv.wp_version_flag, 'N') = 'N'
  		AND ppa.project_id = map.project_id
  		AND map.worker_id = g_worker_id
  		AND (bv.current_flag = 'N' AND bv.current_original_flag = 'N')  /* Added for bug 8708651 */
        UNION ALL
        SELECT /*+ ordered use_nl( map bv fpo ) */
              g_worker_id
            , bv.project_id                      project_id
            , cbco.plan_version_id               plan_version_id
            , DECODE ( NVL(bv.wp_version_flag, 'N')
  		           , 'Y', bv.project_structure_version_id
  		           , Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
  				   )                           wbs_struct_version_id
            , fpo.rbs_version_id                 rbs_struct_version_id
  --          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
            , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
            , fpo.fin_plan_type_id               plan_type_id
            , DECODE(bv.version_type
                        , 'ALL',     fpo.all_time_phased_code
                        , 'COST',    fpo.cost_time_phased_code
                        , 'REVENUE', fpo.revenue_time_phased_code
                       )                       time_phased_type_code
            , NULL                             time_dangling_flag   -- to be used for dangling check.
            , NULL                             rate_dangling_flag   -- to be used for dangling check.
            , NULL                             PROJECT_TYPE_CLASS
  		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
  		  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') current_flag
  		  , bv.original_flag                 original_flag
  		  , DECODE(cbco.plan_version_id, -4, 'Y', 'N') current_original_flag
  		  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') baselined_flag
    	      , 'N'  		                     SECONDARY_RBS_FLAG
  		  , DECODE( NVL(bv.wp_version_flag, 'N')
  		          , 'Y'
  				  , DECODE(bv.project_structure_version_id
  				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
  				         -- , Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(bv.project_id)
  						 , 'Y'
  						 , 'N')
  				  , 'N'
  				  ) lp_flag
        FROM
             pji_pjp_proj_batch_map map
           , pa_budget_versions bv
           , pa_proj_fp_options  fpo
  		 , ( SELECT -3 plan_version_id FROM dual
               UNION ALL
               SELECT -4 plan_version_id FROM dual ) cbco
        WHERE 1=1
  		AND bv.project_id = map.project_id
  		AND map.worker_id = g_worker_id
            AND bv.version_type IS NOT NULL -- COST, REVENUE, etc. Should not be null.
            AND bv.fin_plan_type_id IS NOT NULL -- Old budgets model data is not picked up with this condition.
            AND fpo.project_id = bv.project_id
            AND bv.fin_plan_type_id = fpo.fin_plan_type_id
            AND bv.budget_version_id = fpo.fin_plan_version_id
            AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
            AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
            AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
            AND bv.budget_status_code = 'B'
            AND NVL(bv.wp_version_flag, 'N') = 'N';

    else

      INSERT INTO PJI_FM_EXTR_PLNVER4
      (
        WORKER_ID                ,
        PROJECT_ID               ,
        PLAN_VERSION_ID          ,
        WBS_STRUCT_VERSION_ID    ,
        RBS_STRUCT_VERSION_ID    ,
        PLAN_TYPE_CODE           ,
        PLAN_TYPE_ID             ,
        TIME_PHASED_TYPE_CODE    ,
        TIME_DANGLING_FLAG       ,
        RATE_DANGLING_FLAG       ,
        PROJECT_TYPE_CLASS       ,
        WP_FLAG                  ,
  	CURRENT_FLAG             ,
  	ORIGINAL_FLAG            ,
  	CURRENT_ORIGINAL_FLAG    ,
  	BASELINED_FLAG        	 ,
        SECONDARY_RBS_FLAG       ,
        LP_FLAG
      )
        SELECT /*+ ordered use_nl( map bv ppa fpo ) */
              g_worker_id
            , bv.project_id                      project_id
            , bv.budget_version_id               plan_version_id
            , DECODE ( NVL(bv.wp_version_flag, 'N')
  		           , 'Y', bv.project_structure_version_id
  		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
  				   )                           wbs_struct_version_id
            , fpo.rbs_version_id                 rbs_struct_version_id
  --          , to_char(fpo.fin_plan_type_id)      plan_type_code
            , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
            , fpo.fin_plan_type_id               plan_type_id
            , DECODE(bv.version_type
                        , 'ALL',     fpo.all_time_phased_code
                        , 'COST',    fpo.cost_time_phased_code
                        , 'REVENUE', fpo.revenue_time_phased_code
                       )                       time_phased_type_code
            , NULL                             time_dangling_flag   -- to be used for dangling check.
            , NULL                             rate_dangling_flag   -- to be used for dangling check.
            , NULL                             PROJECT_TYPE_CLASS
  		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
  		  , bv.current_flag                  current_flag
  		  , bv.original_flag                 original_flag
  		  , bv.current_original_flag         current_original_flag
  		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
    	      , 'N'  		                     SECONDARY_RBS_FLAG
  		  , DECODE( NVL(bv.wp_version_flag, 'N')
  		          , 'Y'
  				  , DECODE(bv.project_structure_version_id
  				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
  				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
  						 , 'Y'
  						 , 'N')
  				  , 'N'
  				  ) lp_flag
        FROM
             pji_pjp_proj_batch_map map
           , pa_budget_versions bv -- @pjdev115  bv
           , pa_projects_all  ppa -- @pjdev115    ppa
           , pa_proj_fp_options  fpo -- @pjdev115  fpo
        WHERE 1=1
            AND ppa.project_id = bv.project_id
            AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
            AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
            AND fpo.project_id = bv.project_id
            AND bv.fin_plan_type_id = fpo.fin_plan_type_id
            AND bv.budget_version_id = fpo.fin_plan_version_id
            AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
            AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
            AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
            AND bv.budget_status_code = 'B'
            AND NVL(bv.wp_version_flag, 'N') = 'N'
  		AND ppa.project_id = map.project_id
  		AND map.worker_id = g_worker_id
        UNION ALL
        SELECT /*+ ordered use_nl( map bv fpo ) */
              g_worker_id
            , bv.project_id                      project_id
            , cbco.plan_version_id               plan_version_id
            , DECODE ( NVL(bv.wp_version_flag, 'N')
  		           , 'Y', bv.project_structure_version_id
  		           , Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
  				   )                           wbs_struct_version_id
            , fpo.rbs_version_id                 rbs_struct_version_id
  --          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
            , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
            , fpo.fin_plan_type_id               plan_type_id
            , DECODE(bv.version_type
                        , 'ALL',     fpo.all_time_phased_code
                        , 'COST',    fpo.cost_time_phased_code
                        , 'REVENUE', fpo.revenue_time_phased_code
                       )                       time_phased_type_code
            , NULL                             time_dangling_flag   -- to be used for dangling check.
            , NULL                             rate_dangling_flag   -- to be used for dangling check.
            , NULL                             PROJECT_TYPE_CLASS
  		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
  		  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') current_flag
  		  , bv.original_flag                 original_flag
  		  , DECODE(cbco.plan_version_id, -4, 'Y', 'N') current_original_flag
  		  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') baselined_flag
    	      , 'N'  		                     SECONDARY_RBS_FLAG
  		  , DECODE( NVL(bv.wp_version_flag, 'N')
  		          , 'Y'
  				  , DECODE(bv.project_structure_version_id
  				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
  				         -- , Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(bv.project_id)
  						 , 'Y'
  						 , 'N')
  				  , 'N'
  				  ) lp_flag
        FROM
             pji_pjp_proj_batch_map map
           , pa_budget_versions bv
           , pa_proj_fp_options  fpo
  		 , ( SELECT -3 plan_version_id FROM dual
               UNION ALL
               SELECT -4 plan_version_id FROM dual ) cbco
        WHERE 1=1
  		AND bv.project_id = map.project_id
  		AND map.worker_id = g_worker_id
            AND bv.version_type IS NOT NULL -- COST, REVENUE, etc. Should not be null.
            AND bv.fin_plan_type_id IS NOT NULL -- Old budgets model data is not picked up with this condition.
            AND fpo.project_id = bv.project_id
            AND bv.fin_plan_type_id = fpo.fin_plan_type_id
            AND bv.budget_version_id = fpo.fin_plan_version_id
            AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
            AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
            AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
            AND bv.budget_status_code = 'B'
            AND NVL(bv.wp_version_flag, 'N') = 'N';

    end if;

  ELSIF ( p_slice_type = 'SECRBS_PROJ') THEN

  if (upper(nvl(l_profile_check, 'N')) = 'Y') then /* Added for bug 8708651 */

     INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	CURRENT_FLAG             ,
	ORIGINAL_FLAG            ,
	CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG        	 ,
      SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
     SELECT DISTINCT
	g_worker_id              ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      NULL TIME_DANGLING_FLAG       ,
      NULL RATE_DANGLING_FLAG       ,
      NULL PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	CURRENT_FLAG             ,
	ORIGINAL_FLAG            ,
	CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG        	 ,
      SECONDARY_RBS_FLAG       ,
      LP_FLAG
	  FROM
	  (
      SELECT /*+ ordered use_nl( map bv ppa fpo rpa ) */
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
		  , rpa.rbs_version_id                 rbs_struct_version_id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code



		  , NVL(bv.wp_version_flag, 'N') wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
          pji_pjp_proj_batch_map map
         ,  pa_budget_versions bv -- @pjdev115  bv
         , pa_projects_all  ppa -- @pjdev115    ppa
         , pa_proj_fp_options  fpo -- @pjdev115  fpo
         , PA_RBS_PRJ_ASSIGNMENTS rpa
      WHERE   ppa.project_id = bv.project_id
          AND bv.version_type IS NOT NULL
          AND bv.fin_plan_type_id IS NOT NULL
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
          AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
          AND bv.budget_status_code = 'B'
	    AND rpa.project_id = bv.project_id
	    AND rpa.assignment_status = 'ACTIVE'
	    AND NVL(fpo.rbs_version_id, -1) <> rpa.rbs_version_id
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
	    AND rpa.reporting_usage_flag = 'Y'
		AND ppa.project_id = map.project_id
		AND map.worker_id = g_worker_id
		AND (bv.current_flag = 'Y' or bv.current_original_flag = 'Y')  /* Added for bug 8708651 */
		  UNION ALL
      SELECT  /*+ ordered use_nl( map bv ppa fpo rpa ) */
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
		  , rpa.rbs_version_id                 rbs_struct_version_id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , 'N'                          time_phased_type_code



		  , NVL(bv.wp_version_flag, 'N') wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
          pji_pjp_proj_batch_map map
         ,  pa_budget_versions bv -- @pjdev115  bv
         , pa_projects_all  ppa -- @pjdev115    ppa
         , pa_proj_fp_options  fpo -- @pjdev115  fpo
         , PA_RBS_PRJ_ASSIGNMENTS rpa
      WHERE   ppa.project_id = bv.project_id
          AND bv.version_type IS NOT NULL
          AND bv.fin_plan_type_id IS NOT NULL
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
          AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
          AND bv.budget_status_code = 'B'
	    AND rpa.project_id = bv.project_id
	    AND rpa.assignment_status = 'ACTIVE'
	    AND NVL(fpo.rbs_version_id, -1) <> rpa.rbs_version_id
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
	    AND rpa.reporting_usage_flag = 'Y'
		AND ppa.project_id = map.project_id
		AND map.worker_id = g_worker_id
		AND (bv.current_flag = 'N' AND bv.current_original_flag = 'N')  /* Added for bug 8708651 */
      UNION ALL
      SELECT   /*+ ordered use_nl( map bv fpo rpa ) */
            bv.project_id                      project_id
          , cbco.plan_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
		  , rpa.rbs_version_id                 rbs_struct_version_id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code
		  , NVL(bv.wp_version_flag, 'N') wp_flag
		  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') current_flag
		  , bv.original_flag                 original_flag
		  , DECODE(cbco.plan_version_id, -4, 'Y', 'N') current_original_flag
		  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
          pji_pjp_proj_batch_map map
          , pa_budget_versions bv -- @pjdev115  bv
         , pa_proj_fp_options  fpo -- @pjdev115  fpo
         -- , pa_projects_all  ppa -- @pjdev115    ppa
         , PA_RBS_PRJ_ASSIGNMENTS rpa
		 , ( SELECT -3 plan_version_id FROM dual
             UNION ALL
             SELECT -4 plan_version_id FROM dual ) cbco
      WHERE   map.project_id = bv.project_id
          AND bv.version_type IS NOT NULL
          AND bv.fin_plan_type_id IS NOT NULL
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
          AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
          AND bv.budget_status_code = 'B'
	    AND rpa.project_id = bv.project_id
	    AND rpa.assignment_status = 'ACTIVE'
	    AND NVL(fpo.rbs_version_id, -1) <> rpa.rbs_version_id
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
	    AND rpa.reporting_usage_flag = 'Y'
		AND map.worker_id = g_worker_id
      UNION ALL
      SELECT   /*+ ordered use_nl( ev rpa bv fpo ppa map ) */ -- 'RBS_ASSOC'
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
		  , rpa.rbs_version_id                 rbs_struct_version_id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code



		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
          pji_pa_proj_events_log ev
         , PA_RBS_PRJ_ASSIGNMENTS rpa
         , pa_budget_versions bv -- @pjdev115  bv
         , pa_proj_fp_options  fpo -- @pjdev115  fpo
         , pa_projects_all  ppa -- @pjdev115    ppa
         , pji_pjp_proj_batch_map map
      WHERE   l_RBS_ASSOC_exists = 'Y'  /* Added for bug 8708651 */
          AND ppa.project_id = bv.project_id
          AND bv.version_type IS NOT NULL
          AND bv.fin_plan_type_id IS NOT NULL
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE')
          AND bv.pji_summarized_flag = 'Y'
          AND bv.budget_status_code = 'B'
	    AND rpa.project_id = bv.project_id
	    AND rpa.assignment_status = 'ACTIVE'
	    AND NVL(fpo.rbs_version_id, -1) <> rpa.rbs_version_id
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
	    AND rpa.reporting_usage_flag = 'Y'
		AND ppa.project_id = map.project_id
		AND map.worker_id = g_worker_id
		AND ev.worker_id = g_worker_id
		AND ev.event_type = 'RBS_ASSOC'
		AND TO_NUMBER(ev.attribute1) = map.project_id
		AND rpa.rbs_version_id = TO_NUMBER(ev.event_object)
      UNION ALL
      SELECT /*+ ordered use_nl( ev bv fpo ) */  -- 'RBS_ASSOC'
            bv.project_id                      project_id
          , cbcov.plan_version_id              plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                   wbs_struct_version_id
          , TO_NUMBER(ev.event_object)         rbs_struct_version_id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
           , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code



		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , DECODE(cbcov.plan_version_id, -3, 'Y', 'N') current_flag
		  , bv.original_flag                 original_flag
		  , DECODE(cbcov.plan_version_id, -4, 'Y', 'N') current_original_flag
		  , DECODE(cbcov.plan_version_id, -3, 'Y', 'N') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
          PJI_PA_PROJ_EVENTS_LOG ev
         , pa_budget_versions bv
         , pa_proj_fp_options  fpo
         , (SELECT -3 plan_version_id FROM DUAL
            UNION ALL
            SELECT -4 plan_version_id FROM DUAL
           ) cbcov
      WHERE   l_RBS_ASSOC_exists = 'Y'    /* Added for bug 8708651 */ /*1=1*/
          AND bv.version_type IS NOT NULL
          AND bv.fin_plan_type_id IS NOT NULL
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE')
          AND bv.pji_summarized_flag = 'Y'
          AND bv.budget_status_code = 'B'
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
          AND ev.worker_id = g_worker_id
          AND ev.event_type = 'RBS_ASSOC'
          AND bv.project_id = TO_NUMBER(ev.attribute1)
          AND NOT EXISTS -- Exclude plan version/RBS version combo for which plan data has already been extracted.
              (  SELECT 1
                 FROM pji_pjp_rbs_header rh
                 WHERE rh.project_id = bv.project_id
                   AND rh.plan_version_id = cbcov.plan_version_id
                   AND rh.rbs_version_id = TO_NUMBER(ev.event_object)
              )
      UNION ALL
      SELECT /*+ ordered use_nl( ev hd1 den hd2 bv fpo ) */  -- 'RBS_PRG' event handling.
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
                   , 'Y', bv.project_structure_version_id
                   , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
                   )                           wbs_struct_version_id
          , TO_NUMBER(ev.event_object)         rbs_version_id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code



		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
	  FROM
          pji_pa_proj_events_log ev
         , pji_pjp_wbs_header hd1 -- sup
         , pji_xbs_denorm den
         , pji_pjp_wbs_header hd2 -- sub
         , pa_budget_versions bv
         , pa_proj_fp_options  fpo
      WHERE   l_RBS_PRG_exists = 'Y'  /* Added for bug 8708651 */
          AND bv.version_type IS NOT NULL
          AND bv.fin_plan_type_id IS NOT NULL
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE')
          AND bv.pji_summarized_flag = 'Y'
          AND bv.budget_status_code = 'B'
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
          AND NVL(fpo.rbs_version_id, -1) <> TO_NUMBER(ev.event_object) -- Non-pri RBSes.
          AND ev.worker_id = g_worker_id
          AND ev.event_type = 'RBS_PRG'
          AND den.struct_version_id IS NULL
          AND TO_NUMBER(ev.attribute1) = hd1.project_id
          AND hd1.project_id = den.sup_project_id
          AND hd2.wbs_version_id = den.sub_id -- struct_version_id
          AND hd1.wbs_version_id = den.sup_id
          AND den.struct_type = 'PRG'
          AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF')
          AND hd2.wp_flag = 'N'
          AND hd1.wp_flag = 'N'
          AND hd2.plan_version_id = bv.budget_version_id
          AND hd1.plan_version_id > 0
          -- AND hd2.plan_version_id > 0
          AND NOT EXISTS -- Exclude plan version/RBS version combo for which plan data has already been extracted.
          (  SELECT 1
             FROM pji_pjp_rbs_header rh
             WHERE rh.project_id = bv.project_id
               AND rh.plan_version_id = bv.budget_version_id
               AND rh.rbs_version_id = TO_NUMBER(ev.event_object)
          )
      UNION ALL
      SELECT /*+ ordered use_nl( ev hd1 den hd2 bv fpo ) */ -- 'RBS_PRG' event handling.
            bv.project_id                      project_id
          , cbcov.plan_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
                   , 'Y', bv.project_structure_version_id
                   , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
                   )                           wbs_struct_version_id
          , TO_NUMBER(ev.event_object)         rbs_version_id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code
		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , DECODE(cbcov.plan_version_id, -3, 'Y', 'N') current_flag
		  , bv.original_flag                 original_flag
		  , DECODE(cbcov.plan_version_id, -4, 'Y', 'N') current_original_flag
		  , DECODE(cbcov.plan_version_id, -3, 'Y', 'N') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
	  FROM
           PJI_PA_PROJ_EVENTS_LOG ev
         , pji_pjp_wbs_header hd1 -- sup
         , pji_xbs_denorm den
         , pji_pjp_wbs_header hd2 -- sub
         , pa_budget_versions bv
         , pa_proj_fp_options  fpo
         , (SELECT -3 plan_version_id FROM DUAL
            UNION ALL
            SELECT -4 plan_version_id FROM DUAL
           ) cbcov
      WHERE   l_RBS_PRG_exists = 'Y'  /* Added for bug 8708651 */
          AND bv.version_type IS NOT NULL
          AND bv.fin_plan_type_id IS NOT NULL
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE')
          AND bv.pji_summarized_flag = 'Y'
          AND bv.budget_status_code = 'B'
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
          AND NVL(fpo.rbs_version_id, -1) <> TO_NUMBER(ev.event_object) -- rpa.rbs_version_id
          AND ev.worker_id = g_worker_id
          AND ev.event_type = 'RBS_PRG'
		  AND den.struct_version_id IS NULL
		  AND TO_NUMBER(ev.attribute1) = hd1.project_id
		  AND hd1.project_id = den.sup_project_id
		  AND hd2.wbs_version_id = den.sub_id -- struct_version_id
		  AND hd1.wbs_version_id = den.sup_id
		  AND den.struct_type = 'PRG'
		  AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF')
		  AND hd2.wp_flag = 'N'
		  AND hd1.wp_flag = 'N'
		  AND hd2.plan_version_id = bv.budget_version_id
		  AND hd1.plan_version_id > 0
		  -- AND hd2.plan_version_id > 0
              AND NOT EXISTS -- Exclude plan version/RBS version combo for which plan data has already been extracted.
              (  SELECT 1
                 FROM pji_pjp_rbs_header rh
                 WHERE rh.project_id = bv.project_id
                   AND rh.plan_version_id = cbcov.plan_version_id
                   AND rh.rbs_version_id = TO_NUMBER(ev.event_object)
              )
      UNION ALL
   -- Added for Bug# 8838371
    SELECT
      project_id
    , plan_version_id
    , Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(project_id) wbs_version_id
    , rbs_version_id
    , plan_type_code
    , plan_type_id
    , time_phased_type_code
    , wp_flag
    , current_flag
    , original_flag
    , curr_original_flag
    , baselined_flag
    , SECONDARY_RBS_FLAG
    , lp_flag
    FROM
    (
       SELECT DISTINCT /*+ NO_MERGE(fpo)  use_nl(fpo map whsub den) index(den pji_xbs_denorm_n6) */  -- 'PRG_CHANGE' event.
	    den.sup_project_id                 project_id
          , cbco.plan_version_id               plan_version_id      -- -3/-4
--        , Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(den.sup_project_id) wbs_version_id
          , fpo.parvi                           rbs_version_id
--        , TO_CHAR(whsub.plan_type_id)        plan_type_code
          , whsub.plan_type_code plan_type_code   /*4471527 */
          , whsub.plan_type_id                 plan_type_id
          , fpo.tptc                           time_phased_type_code
          , 'N'                                wp_flag
          , DECODE(cbco.plan_version_id, -3, 'Y', 'N') current_flag
          , DECODE(cbco.plan_version_id, -4, 'Y', 'N') original_flag
          , DECODE(cbco.plan_version_id, -4, 'Y', 'N') curr_original_flag
          , 'Y' baselined_flag
          , DECODE(fpo.fprvi, NULL, 'Y', 'N') SECONDARY_RBS_FLAG
          , 'Y' lp_flag
	  FROM
          (
            SELECT  rpa.project_id rpi
                  , fpo.rbs_version_id fprvi
                  , rpa.rbs_version_id parvi
                  , fpo.fin_plan_option_level_code fpolc
                  , NVL( fpo.all_time_phased_code
                           || fpo.cost_time_phased_code
                           || fpo.revenue_time_phased_code
                           , 'G') tptc
            FROM pji_pjp_proj_batch_map map
	       , pa_budget_versions bv
               , pa_rbs_prj_assignments rpa
               , pa_proj_fp_options fpo
            WHERE 1=1
            AND fpo.project_id (+)= rpa.project_id
            AND fpo.rbs_version_id (+)= rpa.rbs_version_id
            AND bv.project_id = rpa.project_id
            AND NVL(bv.wp_version_flag, 'N') = 'N'
            AND bv.budget_status_code = 'B'		-- Don't care if dangling plan.
            AND map.worker_id = g_worker_id
            AND map.project_id = bv.project_id
          ) fpo
    	  , pji_pjp_proj_batch_map map
    	  , pji_pjp_wbs_header whsub
    	  , pa_xbs_denorm den
    	  , ( SELECT -3 plan_version_id FROM dual
                  UNION ALL
                  SELECT -4 plan_version_id FROM dual ) cbco
           WHERE l_PRG_CHANGE_exists = 'Y'   /* Added for bug 8708651 */
             AND map.worker_id = g_worker_id
    	     AND fpo.rpi = map.project_id
    	     AND NVL(fpolc, 'PLAN_VERSION') = 'PLAN_VERSION'
             AND map.project_id = whsub.project_id
    	     AND whsub.wp_flag = 'N'
    	     AND whsub.plan_version_id <> -1
             AND den.sub_id = whsub.wbs_version_id
             AND den.struct_version_id IS NULL
             AND den.struct_type = 'PRG'
             AND den.sup_level < den.sub_level
             AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF') --  Excluding 'LW'
    	     AND EXISTS ( SELECT DISTINCT 1
                          FROM pji_pa_proj_events_log
                          WHERE event_type = 'PRG_CHANGE'
                            AND worker_id = g_worker_id )
   )
   -- Added for Bug# 8838371 ends
    );

    else

        INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	CURRENT_FLAG             ,
	ORIGINAL_FLAG            ,
	CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG        	 ,
      SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
     SELECT DISTINCT
	g_worker_id              ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      NULL TIME_DANGLING_FLAG       ,
      NULL RATE_DANGLING_FLAG       ,
      NULL PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	CURRENT_FLAG             ,
	ORIGINAL_FLAG            ,
	CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG        	 ,
      SECONDARY_RBS_FLAG       ,
      LP_FLAG
	  FROM
	  (
      SELECT /*+ ordered use_nl( map bv ppa fpo rpa ) */
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
		  , rpa.rbs_version_id                 rbs_struct_version_id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code



		  , NVL(bv.wp_version_flag, 'N') wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
          pji_pjp_proj_batch_map map   -- CHANGE_01 Sridhar Carlson  6919766 changed order of the tables
         ,  pa_budget_versions bv -- @pjdev115  bv
         , pa_projects_all  ppa -- @pjdev115    ppa
         , pa_proj_fp_options  fpo -- @pjdev115  fpo
         , PA_RBS_PRJ_ASSIGNMENTS rpa
      WHERE   ppa.project_id = bv.project_id
          AND bv.version_type IS NOT NULL
          AND bv.fin_plan_type_id IS NOT NULL
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
          AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
          AND bv.budget_status_code = 'B'
	    AND rpa.project_id = bv.project_id
	    -- AND DECODE ( rpa.wp_usage_flag, 'Y', 'Y', 'X') = NVL(bv.wp_version_flag, 'N')
	    -- AND DECODE ( rpa.fp_usage_flag, 'Y', 'N', 'X') = NVL(bv.wp_version_flag, 'N')
	    AND rpa.assignment_status = 'ACTIVE'
	    AND NVL(fpo.rbs_version_id, -1) <> rpa.rbs_version_id
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
	    AND rpa.reporting_usage_flag = 'Y'
		AND ppa.project_id = map.project_id
		AND map.worker_id = g_worker_id
      UNION ALL
      SELECT   /*+ ordered use_nl( map bv fpo rpa ) */
            bv.project_id                      project_id
          , cbco.plan_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
		  , rpa.rbs_version_id                 rbs_struct_version_id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code
		  , NVL(bv.wp_version_flag, 'N') wp_flag
		  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') current_flag
		  , bv.original_flag                 original_flag
		  , DECODE(cbco.plan_version_id, -4, 'Y', 'N') current_original_flag
		  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
          pji_pjp_proj_batch_map map
          , pa_budget_versions bv -- @pjdev115  bv
         , pa_proj_fp_options  fpo -- @pjdev115  fpo
         -- , pa_projects_all  ppa -- @pjdev115    ppa
         , PA_RBS_PRJ_ASSIGNMENTS rpa
		 , ( SELECT -3 plan_version_id FROM dual
             UNION ALL
             SELECT -4 plan_version_id FROM dual ) cbco
      WHERE   map.project_id = bv.project_id
          AND bv.version_type IS NOT NULL
          AND bv.fin_plan_type_id IS NOT NULL
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
          AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
          AND bv.budget_status_code = 'B'
	    AND rpa.project_id = bv.project_id
	    AND rpa.assignment_status = 'ACTIVE'
	    AND NVL(fpo.rbs_version_id, -1) <> rpa.rbs_version_id
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
	    AND rpa.reporting_usage_flag = 'Y'
		AND map.worker_id = g_worker_id
      UNION ALL
      SELECT   /*+ ordered use_nl( ev rpa bv fpo ppa map ) */ -- 'RBS_ASSOC'
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                           wbs_struct_version_id
		  , rpa.rbs_version_id                 rbs_struct_version_id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code



		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
          pji_pa_proj_events_log ev
         , PA_RBS_PRJ_ASSIGNMENTS rpa
         , pa_budget_versions bv -- @pjdev115  bv
         , pa_proj_fp_options  fpo -- @pjdev115  fpo
         , pa_projects_all  ppa -- @pjdev115    ppa
         , pji_pjp_proj_batch_map map
      WHERE   l_RBS_ASSOC_exists = 'Y'  /* Added for bug 8708651 */
          AND ppa.project_id = bv.project_id
          AND bv.version_type IS NOT NULL
          AND bv.fin_plan_type_id IS NOT NULL
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE')
          AND bv.pji_summarized_flag = 'Y'
          AND bv.budget_status_code = 'B'
	    AND rpa.project_id = bv.project_id
	    AND rpa.assignment_status = 'ACTIVE'
	    AND NVL(fpo.rbs_version_id, -1) <> rpa.rbs_version_id
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
	    AND rpa.reporting_usage_flag = 'Y'
		AND ppa.project_id = map.project_id
		AND map.worker_id = g_worker_id
		AND ev.worker_id = g_worker_id
		AND ev.event_type = 'RBS_ASSOC'
		AND TO_NUMBER(ev.attribute1) = map.project_id
		AND rpa.rbs_version_id = TO_NUMBER(ev.event_object)
      UNION ALL
      SELECT /*+ ordered use_nl( ev bv fpo ) */  -- 'RBS_ASSOC'
            bv.project_id                      project_id
          , cbcov.plan_version_id              plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
				   )                   wbs_struct_version_id
          , TO_NUMBER(ev.event_object)         rbs_struct_version_id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
           , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code



		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , DECODE(cbcov.plan_version_id, -3, 'Y', 'N') current_flag
		  , bv.original_flag                 original_flag
		  , DECODE(cbcov.plan_version_id, -4, 'Y', 'N') current_original_flag
		  , DECODE(cbcov.plan_version_id, -3, 'Y', 'N') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
      FROM
          PJI_PA_PROJ_EVENTS_LOG ev
         , pa_budget_versions bv
         , pa_proj_fp_options  fpo
         , (SELECT -3 plan_version_id FROM DUAL
            UNION ALL
            SELECT -4 plan_version_id FROM DUAL
           ) cbcov
      WHERE   l_RBS_ASSOC_exists = 'Y'    /* Added for bug 8708651 */ /*1=1*/
          AND bv.version_type IS NOT NULL
          AND bv.fin_plan_type_id IS NOT NULL
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE')
          AND bv.pji_summarized_flag = 'Y'
          AND bv.budget_status_code = 'B'
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
          AND ev.worker_id = g_worker_id
          AND ev.event_type = 'RBS_ASSOC'
          AND bv.project_id = TO_NUMBER(ev.attribute1)
          AND NOT EXISTS -- Exclude plan version/RBS version combo for which plan data has already been extracted.
              (  SELECT 1
                 FROM pji_pjp_rbs_header rh
                 WHERE rh.project_id = bv.project_id
                   AND rh.plan_version_id = cbcov.plan_version_id
                   AND rh.rbs_version_id = TO_NUMBER(ev.event_object)
              )
      UNION ALL
      SELECT /*+ ordered use_nl( ev hd1 den hd2 bv fpo ) */  -- 'RBS_PRG' event handling.
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
                   , 'Y', bv.project_structure_version_id
                   , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
                   )                           wbs_struct_version_id
          , TO_NUMBER(ev.event_object)         rbs_version_id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code



		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
	  FROM
          pji_pa_proj_events_log ev
         , pji_pjp_wbs_header hd1 -- sup
         , pji_xbs_denorm den
         , pji_pjp_wbs_header hd2 -- sub
         , pa_budget_versions bv
         , pa_proj_fp_options  fpo
      WHERE   l_RBS_PRG_exists = 'Y'  /* Added for bug 8708651 */
          AND bv.version_type IS NOT NULL
          AND bv.fin_plan_type_id IS NOT NULL
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE')
          AND bv.pji_summarized_flag = 'Y'
          AND bv.budget_status_code = 'B'
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
          AND NVL(fpo.rbs_version_id, -1) <> TO_NUMBER(ev.event_object) -- Non-pri RBSes.
          AND ev.worker_id = g_worker_id
          AND ev.event_type = 'RBS_PRG'
          AND den.struct_version_id IS NULL
          AND TO_NUMBER(ev.attribute1) = hd1.project_id
          AND hd1.project_id = den.sup_project_id
          AND hd2.wbs_version_id = den.sub_id -- struct_version_id
          AND hd1.wbs_version_id = den.sup_id
          AND den.struct_type = 'PRG'
          AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF')
          AND hd2.wp_flag = 'N'
          AND hd1.wp_flag = 'N'
          AND hd2.plan_version_id = bv.budget_version_id
          AND hd1.plan_version_id > 0
          -- AND hd2.plan_version_id > 0
          AND NOT EXISTS -- Exclude plan version/RBS version combo for which plan data has already been extracted.
          (  SELECT 1
             FROM pji_pjp_rbs_header rh
             WHERE rh.project_id = bv.project_id
               AND rh.plan_version_id = bv.budget_version_id
               AND rh.rbs_version_id = TO_NUMBER(ev.event_object)
          )
      UNION ALL
      SELECT /*+ ordered use_nl( ev hd1 den hd2 bv fpo ) */ -- 'RBS_PRG' event handling.
            bv.project_id                      project_id
          , cbcov.plan_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
                   , 'Y', bv.project_structure_version_id
                   , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
                   )                           wbs_struct_version_id
          , TO_NUMBER(ev.event_object)         rbs_version_id
--          , TO_CHAR(fpo.fin_plan_type_id)      plan_type_code
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code
		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , DECODE(cbcov.plan_version_id, -3, 'Y', 'N') current_flag
		  , bv.original_flag                 original_flag
		  , DECODE(cbcov.plan_version_id, -4, 'Y', 'N') current_original_flag
		  , DECODE(cbcov.plan_version_id, -3, 'Y', 'N') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
	  FROM
           PJI_PA_PROJ_EVENTS_LOG ev
         , pji_pjp_wbs_header hd1 -- sup
         , pji_xbs_denorm den
         , pji_pjp_wbs_header hd2 -- sub
         , pa_budget_versions bv
         , pa_proj_fp_options  fpo
         , (SELECT -3 plan_version_id FROM DUAL
            UNION ALL
            SELECT -4 plan_version_id FROM DUAL
           ) cbcov
      WHERE   l_RBS_PRG_exists = 'Y'  /* Added for bug 8708651 */
          AND bv.version_type IS NOT NULL
          AND bv.fin_plan_type_id IS NOT NULL
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE')
          AND bv.pji_summarized_flag = 'Y'
          AND bv.budget_status_code = 'B'
          AND NVL(bv.wp_version_flag, 'N')  = 'N'
          AND NVL(fpo.rbs_version_id, -1) <> TO_NUMBER(ev.event_object) -- rpa.rbs_version_id
          AND ev.worker_id = g_worker_id
          AND ev.event_type = 'RBS_PRG'
		  AND den.struct_version_id IS NULL
		  AND TO_NUMBER(ev.attribute1) = hd1.project_id
		  AND hd1.project_id = den.sup_project_id
		  AND hd2.wbs_version_id = den.sub_id -- struct_version_id
		  AND hd1.wbs_version_id = den.sup_id
		  AND den.struct_type = 'PRG'
		  AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF')
		  AND hd2.wp_flag = 'N'
		  AND hd1.wp_flag = 'N'
		  AND hd2.plan_version_id = bv.budget_version_id
		  AND hd1.plan_version_id > 0
		  -- AND hd2.plan_version_id > 0
              AND NOT EXISTS -- Exclude plan version/RBS version combo for which plan data has already been extracted.
              (  SELECT 1
                 FROM pji_pjp_rbs_header rh
                 WHERE rh.project_id = bv.project_id
                   AND rh.plan_version_id = cbcov.plan_version_id
                   AND rh.rbs_version_id = TO_NUMBER(ev.event_object)
              )
      UNION ALL
   -- Added for Bug# 8838371
    SELECT
      project_id
    , plan_version_id
    , Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(project_id) wbs_struct_version_id
    , rbs_struct_version_id
    , plan_type_code
    , plan_type_id
    , time_phased_type_code
    , wp_flag
    , current_flag
    , original_flag
    , curr_original_flag
    , baselined_flag
    , SECONDARY_RBS_FLAG
    , lp_flag
    FROM
    (
       SELECT DISTINCT /*+ NO_MERGE(fpo)  use_nl(fpo map whsub den) index(den pji_xbs_denorm_n6) */  -- 'PRG_CHANGE' event.
	    den.sup_project_id                 project_id
          , cbco.plan_version_id               plan_version_id      -- -3/-4
--        , Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(den.sup_project_id) wbs_struct_version_id
          , fpo.parvi                           rbs_struct_version_id
--        , TO_CHAR(whsub.plan_type_id)        plan_type_code
          , whsub.plan_type_code plan_type_code   /*4471527 */
          , whsub.plan_type_id                 plan_type_id
          , fpo.tptc                           time_phased_type_code
          , 'N'                                wp_flag
          , DECODE(cbco.plan_version_id, -3, 'Y', 'N') current_flag
          , DECODE(cbco.plan_version_id, -4, 'Y', 'N') original_flag
          , DECODE(cbco.plan_version_id, -4, 'Y', 'N') curr_original_flag
          , 'Y' baselined_flag
          , DECODE(fpo.fprvi, NULL, 'Y', 'N') SECONDARY_RBS_FLAG
          , 'Y' lp_flag
	  FROM
          (
            SELECT  rpa.project_id rpi
                  , fpo.rbs_version_id fprvi
                  , rpa.rbs_version_id parvi
                  , fpo.fin_plan_option_level_code fpolc
                  , NVL( fpo.all_time_phased_code
                           || fpo.cost_time_phased_code
                           || fpo.revenue_time_phased_code
                           , 'G') tptc
            FROM pji_pjp_proj_batch_map map
	       , pa_budget_versions bv
               , pa_rbs_prj_assignments rpa
               , pa_proj_fp_options fpo
            WHERE 1=1
            AND fpo.project_id (+)= rpa.project_id
            AND fpo.rbs_version_id (+)= rpa.rbs_version_id
            AND bv.project_id = rpa.project_id
            AND NVL(bv.wp_version_flag, 'N') = 'N'
            AND bv.budget_status_code = 'B'		-- Don't care if dangling plan.
            AND map.worker_id = g_worker_id
            AND map.project_id = bv.project_id
          ) fpo
    	  , pji_pjp_proj_batch_map map
    	  , pji_pjp_wbs_header whsub
    	  , pa_xbs_denorm den
    	  , ( SELECT -3 plan_version_id FROM dual
                  UNION ALL
                  SELECT -4 plan_version_id FROM dual ) cbco
           WHERE l_PRG_CHANGE_exists = 'Y'   /* Added for bug 8708651 */
             AND map.worker_id = g_worker_id
    	     AND fpo.rpi = map.project_id
    	     AND NVL(fpolc, 'PLAN_VERSION') = 'PLAN_VERSION'
             AND map.project_id = whsub.project_id
    	     AND whsub.wp_flag = 'N'
    	     AND whsub.plan_version_id <> -1
             AND den.sub_id = whsub.wbs_version_id
             AND den.struct_version_id IS NULL
             AND den.struct_type = 'PRG'
             AND den.sup_level < den.sub_level
             AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF') --  Excluding 'LW'
    	     AND EXISTS ( SELECT DISTINCT 1
                          FROM pji_pa_proj_events_log
                          WHERE event_type = 'PRG_CHANGE'
                            AND worker_id = g_worker_id )
   )
   -- Added for Bug# 8838371 ends
    );

    end if;


    --#bug 5356051
    If l_prg_exists = 'Y' then --Programs exist, need to insert -3/-4 for programs as well

    INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	CURRENT_FLAG             ,
	ORIGINAL_FLAG            ,
	CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG        	 ,
      SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
      SELECT DISTINCT -- For insertion of -3/-4 header records.
            g_worker_id worker_id
          , den.sup_project_id                      project_id
          , cbco.plan_version_id               plan_version_id
          , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(den.sup_project_id) wbs_struct_version_id
          , hd2.rbs_struct_version_id        rbs_version_id
          ,hd2.plan_type_code plan_type_code   /*4471527 */
          , hd2.plan_type_id                 plan_type_id
          , hd2.time_phased_type_code        time_phased_type_code
          , NULL                             TIME_DANGLING_FLAG
          , NULL                             RATE_DANGLING_FLAG
          , NULL                             PROJECT_TYPE_CLASS
		  , 'N'                              is_wp_flag
		  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') current_flag
		  , NULL                             original_flag
		  , DECODE(cbco.plan_version_id, -4, 'Y', 'N') current_original_flag
		  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') baselined_flag
		  , 'Y' 	  		                 SECONDARY_RBS_FLAG
		  , 'Y'                              lp_flag
	  FROM
           pji_fm_extr_plnver4 hd2 -- sub
         , pji_xbs_denorm den
         , ( SELECT -3 plan_version_id FROM dual
             UNION ALL
             SELECT -4 plan_version_id FROM dual ) cbco
      WHERE   hd2.baselined_flag = 'Y'
	    AND hd2.wp_flag = 'N'
          AND hd2.plan_version_id > 0
          AND hd2.worker_id = g_worker_id
          AND den.struct_version_id IS NULL
          AND hd2.wbs_struct_version_id = den.sub_id -- struct_version_id
          AND den.struct_type = 'PRG'
          AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF')
          AND (den.sup_project_id, cbco.plan_version_id, hd2.plan_type_id,hd2.plan_type_code, hd2.rbs_struct_version_id) NOT IN
              ( SELECT project_id, plan_version_id, plan_type_id, plan_type_code,rbs_struct_version_id
                FROM   pji_fm_extr_plnver4 ver3
                WHERE  worker_id = g_worker_id );

  elsif l_prg_exists = 'N' then

    INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	CURRENT_FLAG             ,
	ORIGINAL_FLAG            ,
	CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG        	 ,
      SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
      SELECT DISTINCT -- For insertion of -3/-4 header records.
            g_worker_id worker_id
          , hd2.project_id                      project_id
          , cbco.plan_version_id               plan_version_id
          , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(hd2.project_id) wbs_struct_version_id
          , hd2.rbs_struct_version_id        rbs_version_id
          , hd2.plan_type_code plan_type_code   /*4471527 */
          , hd2.plan_type_id                 plan_type_id
          , hd2.time_phased_type_code        time_phased_type_code
          , NULL                             TIME_DANGLING_FLAG
          , NULL                             RATE_DANGLING_FLAG
          , NULL                             PROJECT_TYPE_CLASS
	  , 'N'                              is_wp_flag
	  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') current_flag
	  , NULL                             original_flag
	  , DECODE(cbco.plan_version_id, -4, 'Y', 'N') current_original_flag
	  , DECODE(cbco.plan_version_id, -3, 'Y', 'N') baselined_flag
	  , 'Y' 	  		                 SECONDARY_RBS_FLAG
	  , 'Y'                              lp_flag
	  FROM
           pji_fm_extr_plnver4 hd2 -- sub
         , ( SELECT -3 plan_version_id FROM dual
             UNION ALL
             SELECT -4 plan_version_id FROM dual ) cbco
      WHERE   hd2.baselined_flag = 'Y'
	  AND hd2.wp_flag = 'N'
          AND hd2.plan_version_id > 0
          AND hd2.worker_id = g_worker_id
          AND (hd2.project_id, cbco.plan_version_id, hd2.plan_type_id,hd2.plan_type_code, hd2.rbs_struct_version_id) NOT IN
              ( SELECT project_id, plan_version_id, plan_type_id, plan_type_code,rbs_struct_version_id
                FROM   pji_fm_extr_plnver4 ver3
                WHERE  worker_id = g_worker_id );

  end if;
  --#bug 5356051


  END IF;


  print_time('EXTRACT_FIN_PLAN_VERS_BULK : End .. rows processed ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN

    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'EXTRACT_FIN_PLAN_VERS_BULK');
    print_time('EXTRACT_FIN_PLAN_VERS_BULK : Exception: ' || sqlerrm );
    RAISE;
END;


--
-- Get the budget versions that need to be extracted INTO a temp table.
-- This is to set scope for extraction as well as track time/curr dangling records
--  in the case of secondary slice creation.
--
PROCEDURE EXTRACT_FIN_PLAN_VERSIONS(
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_slice_type        IN   VARCHAR2 := NULL -- 'PRI' or 'SEC' or 'SECRBS'
) IS
  l_count NUMBER;
BEGIN

  print_time('EXTRACT_FIN_PLAN_VERSIONS : Begin ' );

  IF (p_slice_type NOT IN ( 'PRI', 'SEC', 'SECRBS' )) THEN
    print_time('EXTRACT_FIN_PLAN_VERSIONS : Invalid slice type. Exitting. ' );
    RETURN;
  END IF;

  print_time('EXTRACT_FIN_PLAN_VERSIONS : l_count is ... ' || p_fp_version_ids.COUNT );

  IF (p_slice_type = 'PRI') THEN

    FOR I IN 1..p_fp_version_ids.COUNT LOOP

          INSERT INTO PJI_FM_EXTR_PLNVER4 ver3
          (
            WORKER_ID                ,
            PROJECT_ID               ,
            PLAN_VERSION_ID          ,
            WBS_STRUCT_VERSION_ID    ,
            RBS_STRUCT_VERSION_ID    ,
            PLAN_TYPE_CODE           ,
            PLAN_TYPE_ID             ,
            TIME_PHASED_TYPE_CODE    ,
            TIME_DANGLING_FLAG       ,
            RATE_DANGLING_FLAG       ,
            PROJECT_TYPE_CLASS       ,
            WP_FLAG                  ,
            CURRENT_FLAG             ,
            ORIGINAL_FLAG            ,
            CURRENT_ORIGINAL_FLAG    ,
            BASELINED_FLAG           ,
	      SECONDARY_RBS_FLAG       ,
            LP_FLAG
          )
            SELECT
                  g_worker_id
                , bv.project_id                      project_id
                , bv.budget_version_id               plan_version_id
                , DECODE ( NVL(bv.wp_version_flag, 'N')
      		           , 'Y', bv.project_structure_version_id
      		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
      				   )                           wbs_struct_version_id
                , fpo.rbs_version_id                 rbs_struct_version_id
--                , to_char(fpo.fin_plan_type_id)      plan_type_code
                , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
                , fpo.fin_plan_type_id               plan_type_id
                , DECODE(bv.version_type
                            , 'ALL',     fpo.all_time_phased_code
                            , 'COST',    fpo.cost_time_phased_code
                            , 'REVENUE', fpo.revenue_time_phased_code
                           )                       time_phased_type_code
                , NULL                             time_dangling_flag   -- to be used for dangling check.
                , NULL                             rate_dangling_flag   -- to be used for dangling check.
                , NULL                             PROJECT_TYPE_CLASS
                , NVL(bv.wp_version_flag, 'N') is_wp_flag
                , bv.current_flag                  current_flag
                , bv.original_flag                 original_flag
                , bv.current_original_flag         current_original_flag
                , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		    , 'N'  		                     SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
            FROM
                 pa_budget_versions bv -- @pjdev115  bv
               , pa_proj_fp_options  fpo -- @pjdev115  fpo
               , pa_projects_all  ppa -- @pjdev115    ppa
            WHERE 1=1
                AND ppa.project_id = bv.project_id
                AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
                AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
                                                    -- Ask VR: How about WP version.. are they picked up with this condition??
                AND fpo.project_id = bv.project_id
                AND bv.fin_plan_type_id = fpo.fin_plan_type_id
                AND bv.budget_version_id = fpo.fin_plan_version_id
                AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
                AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
                -- AND bv.pji_summarized_flag = 'N'
                AND bv.budget_version_id = p_fp_version_ids(i) ;

    END LOOP;

  ELSIF (p_slice_type = 'SEC') THEN

    FOR I IN 1..p_fp_version_ids.COUNT LOOP

          INSERT INTO PJI_FM_EXTR_PLNVER4 ver3
          (
            WORKER_ID                ,
            PROJECT_ID               ,
            PLAN_VERSION_ID          ,
            WBS_STRUCT_VERSION_ID    ,
            RBS_STRUCT_VERSION_ID    ,
            PLAN_TYPE_CODE           ,
            PLAN_TYPE_ID             ,
            TIME_PHASED_TYPE_CODE    ,
            TIME_DANGLING_FLAG       ,
            RATE_DANGLING_FLAG       ,
            PROJECT_TYPE_CLASS       ,
            WP_FLAG                  ,
            CURRENT_FLAG             ,
            ORIGINAL_FLAG            ,
            CURRENT_ORIGINAL_FLAG    ,
            BASELINED_FLAG           ,
  	      SECONDARY_RBS_FLAG       ,
            LP_FLAG
          )
            SELECT
                  g_worker_id
                , bv.project_id                      project_id
                , bv.budget_version_id               plan_version_id
                , DECODE ( NVL(bv.wp_version_flag, 'N')
      		           , 'Y', bv.project_structure_version_id
      		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
      				   )                           wbs_struct_version_id
                , fpo.rbs_version_id                 rbs_struct_version_id
--                , to_char(fpo.fin_plan_type_id)      plan_type_code
                , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
                , fpo.fin_plan_type_id               plan_type_id
                , DECODE(bv.version_type
                            , 'ALL',     fpo.all_time_phased_code
                            , 'COST',    fpo.cost_time_phased_code
                            , 'REVENUE', fpo.revenue_time_phased_code
                           )                       time_phased_type_code
                , NULL                             time_dangling_flag   -- to be used for dangling check.
                , NULL                             rate_dangling_flag   -- to be used for dangling check.
                , NULL                             PROJECT_TYPE_CLASS
                , NVL(bv.wp_version_flag, 'N') is_wp_flag
                , bv.current_flag                  current_flag
                , bv.original_flag                 original_flag
                , bv.current_original_flag         current_original_flag
                , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		    , 'N'  		                     SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
            FROM
                 pa_budget_versions bv -- @pjdev115  bv
               , pa_proj_fp_options  fpo -- @pjdev115  fpo
               , pa_projects_all  ppa -- @pjdev115    ppa
            WHERE 1=1
                AND ppa.project_id = bv.project_id
                AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
                AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
                AND fpo.project_id = bv.project_id
                AND bv.fin_plan_type_id = fpo.fin_plan_type_id
                AND bv.budget_version_id = fpo.fin_plan_version_id
                AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
                AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
                AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
                AND bv.budget_status_code = 'B'
                AND NVL(bv.wp_version_flag, 'N') = 'N'
                AND bv.budget_version_id = p_fp_version_ids(i) ;

    END LOOP;


  ELSIF (p_slice_type = 'SECRBS') THEN

    FOR I IN 1..p_fp_version_ids.COUNT LOOP

          INSERT INTO PJI_FM_EXTR_PLNVER4 ver3
          (
            WORKER_ID                ,
            PROJECT_ID               ,
            PLAN_VERSION_ID          ,
            WBS_STRUCT_VERSION_ID    ,
            RBS_STRUCT_VERSION_ID    ,
            PLAN_TYPE_CODE           ,
            PLAN_TYPE_ID             ,
            TIME_PHASED_TYPE_CODE    ,
            TIME_DANGLING_FLAG       ,
            RATE_DANGLING_FLAG       ,
            PROJECT_TYPE_CLASS       ,
            WP_FLAG                  ,
            CURRENT_FLAG             ,
            ORIGINAL_FLAG            ,
            CURRENT_ORIGINAL_FLAG    ,
            BASELINED_FLAG           ,
  	      SECONDARY_RBS_FLAG       ,
            LP_FLAG
          )
            SELECT
                  g_worker_id
                , bv.project_id                      project_id
                , bv.budget_version_id               plan_version_id
                , DECODE ( NVL(bv.wp_version_flag, 'N')
      		           , 'Y', bv.project_structure_version_id
      		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
      				   )                           wbs_struct_version_id
                , rpa.rbs_version_id                 rbs_struct_version_id
--                , to_char(fpo.fin_plan_type_id)      plan_type_code
                , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
                , fpo.fin_plan_type_id               plan_type_id
                , DECODE(bv.version_type
                            , 'ALL',     fpo.all_time_phased_code
                            , 'COST',    fpo.cost_time_phased_code
                            , 'REVENUE', fpo.revenue_time_phased_code
                           )                       time_phased_type_code
                , NULL                             time_dangling_flag   -- to be used for dangling check.
                , NULL                             rate_dangling_flag   -- to be used for dangling check.
                , NULL                             PROJECT_TYPE_CLASS
                , NVL(bv.wp_version_flag, 'N') is_wp_flag
                , bv.current_flag                  current_flag
                , bv.original_flag                 original_flag
                , bv.current_original_flag         current_original_flag
                , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		    , 'Y'  		                     SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  4682341
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
            FROM
                 pa_budget_versions bv -- @pjdev115  bv
               , pa_proj_fp_options  fpo -- @pjdev115  fpo
               , pa_projects_all  ppa -- @pjdev115    ppa
		 , PA_RBS_PRJ_ASSIGNMENTS rpa
            WHERE 1=1
                AND ppa.project_id = bv.project_id
                AND bv.version_type is not NULL -- COST, REVENUE, etc. Should not be null.
                AND bv.fin_plan_type_id is not NULL -- Old budgets model data is not picked up with this condition.
                AND fpo.project_id = bv.project_id
                AND bv.fin_plan_type_id = fpo.fin_plan_type_id
                AND bv.budget_version_id = fpo.fin_plan_version_id
                AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'  -- Other values are: plan type and project.
                AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE') -- Eg of other version type is ORG_FORECAST.
                AND bv.pji_summarized_flag = 'P' -- Pri slice created or dangling records exist.
                AND bv.budget_status_code = 'B'
	    AND rpa.project_id = bv.project_id
	    AND rpa.assignment_status = 'ACTIVE'
	    AND NVL(fpo.rbs_version_id, -1) <> rpa.rbs_version_id
	    AND rpa.reporting_usage_flag = 'Y'
                AND NVL(bv.wp_version_flag, 'N') = 'N'
                AND bv.budget_version_id = p_fp_version_ids(i)
	          AND bv.project_id = rpa.project_id;

    END LOOP;

  END IF;

  l_count := SQL%ROWCOUNT;

  print_time('EXTRACT_FIN_PLAN_VERSIONS : l_count is ... ' || l_count );

  print_time('EXTRACT_FIN_PLAN_VERSIONS : End' );

EXCEPTION
  WHEN OTHERS THEN
    print_time('EXTRACT_FIN_PLAN_VERSIONS : Exception: ' || sqlerrm );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'EXTRACT_FIN_PLAN_VERSIONS');
    RAISE;
END;


--
-- Extract the period level plan amounts for PA/GL/non time phased entries from budget lines
--  for the primary RBS for this plan version into pji_fp_aggr_pjp1.
-- EXTRACT_PLAN_AMOUNTS_PRIRBS
PROCEDURE EXTRACT_PLAN_AMOUNTS_PRIRBS IS
  l_count NUMBER;
  l_max_project_id  NUMBER := NULL;
BEGIN

    print_time('EXTRACT_PLAN_AMOUNTS_PRIRBS : Begin' );
    print_time('EXTRACT_PLAN_AMOUNTS_PRIRBS : Begin worker id is ... ' || 1);


  INSERT_NTP_CAL_RECORD ( x_max_project_id => l_max_project_id );

  IF (l_max_project_id IS NULL) THEN
    RETURN;
  END IF;




    INSERT INTO PJI_FP_AGGR_PJP1
    (
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , LINE_TYPE
       , RATE_DANGLING_FLAG
       , TIME_DANGLING_FLAG
       -- , START_DATE
       -- , END_DATE
       , PRG_LEVEL
       ,PLAN_TYPE_CODE
	)
       SELECT /*+ ordered no_merge(plr) */
         g_worker_id  WORKER_ID
       , plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , DECODE(plr.time_phased_type_code
              , 'N', -1
              , pji_time.cal_period_id)  time_id

       , DECODE(plr.time_phased_type_code
               , 'P', 32
               , 'G', 32
               , 'N', 2048
               , -1) period_type_id -- period type id...
       , DECODE(plr.time_phased_type_code
               , 'P', 'P'
               , 'G', 'G'
               , 'N', 'A'
               , 'X')     --   CALENDAR_TYPE
       , 'L' RBS_AGGR_LEVEL
       , 'N' WBS_ROLLUP_FLAG
       , 'N' PRG_ROLLUP_FLAG
       , plr.CURR_RECORD_TYPE  -- curr code missing.
       , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.BUDGET_VERSION_ID
       , plr.plan_type_id
       , SUM(plr.RAW_COST)
       , SUM(plr.BRDN_COST)
       , SUM(plr.REVENUE)
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )  BILL_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )   BILL_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YPEOPLE', plr.raw_cost, 0 ) )  BILL_LABOR_RAW_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YPEOPLE' , plr.BRDN_COST, 0 ) )   BILL_LABOR_BRDN_COST
       --, SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'YPEOPLE', plr.quantity, 0 ) )  BILL_LABOR_HRS  -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'YPEOPLE',
                                             DECODE ( plr.billable_flag , 'Y' , plr.quantity, 0 ) , 0 ) )  BILL_LABOR_HRS  -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.raw_cost, 0 ) )  EQUIPMENT_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.BRDN_COST, 0 ) )   EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )      CAPITALIZABLE_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )      CAPITALIZABLE_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.raw_cost, 0 ) )  LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.BRDN_COST, 0 ) )   LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.resource_class, g_people_resclass_code,
                                            DECODE ( plr.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
                                                    0 ) )   labor_hrs */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code,
                                            DECODE( plr.billable_flag , 'Y' ,
                                                    DECODE ( plr.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
					     0 ),
                                                    0 ) )   labor_hrs -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.revenue, 0 ) )  LABOR_REVENUE
       /* , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code,
                                            DECODE ( plr.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),

                                            0 ) )  EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code,
                                            DECODE( plr.billable_flag , 'Y' ,
                                                    DECODE ( plr.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
					     0 ),
                                                    0 ) )  EQUIPMENT_HOURS -- bug 6039785
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YEQUIPMENT', plr.quantity, 0 ) )  BILLABLE_EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YEQUIPMENT',
                                                                 DECODE ( plr.billable_flag , 'Y' , plr.quantity, 0 ) , 0 ) )  BILLABLE_EQUIPMENT_HOURS -- bug 6039785
       , NULL  SUP_INV_COMMITTED_COST
       , NULL  PO_COMMITTED_COST
       , NULL  PR_COMMITTED_COST
       , NULL  OTH_COMMITTED_COST
       /* , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                                0 ) ) ) ACT_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                              DECODE ( plr.billable_flag , 'Y',
                                                                                      DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
									        0 ),
                                                                                0 ) ) ) ACT_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                                0 ) ) ) ACT_EQUIP_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                              DECODE ( plr.billable_flag , 'Y',
                                                                                       DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
									        0 ),
                                                                                0 ) ) ) ACT_EQUIP_HOURS -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.actual_BRDN_COST, 0 ) ) ) ACT_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.actual_BRDN_COST, 0 ) ) ) ACT_EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.actual_brdn_cost ) ) ACT_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.actual_raw_cost ) ) ACT_RAW_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.actual_revenue ) ) ACT_REVENUE
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.actual_RAW_COST, 0 ) ) ) ACT_LABOR_RAW_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.actual_RAW_COST, 0 ) ) ) ACT_EQUIPMENT_RAW_COST
       /* , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ) ) ) ETC_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                             DECODE ( plr.billable_flag , 'Y',
                                                                                     DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
									        0 ),
                                                                                0 ) ) ) ETC_LABOR_HRS  -- bug 6039785
       /* , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ) ) ) ETC_EQUIP_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                             DECODE ( plr.billable_flag , 'Y',
                                                                                      DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
									        0 ),
                                                                                0 ) ) ) ETC_EQUIP_HOURS -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.etc_BRDN_COST, 0 ) ) ) ETC_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.etc_BRDN_COST, 0 ) ) ) ETC_EQUIP_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.etc_brdn_cost ) ) ETC_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.etc_raw_cost ) ) ETC_RAW_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.etc_raw_COST, 0 ) ) ) ETC_LABOR_raw_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.etc_raw_COST, 0 ) ) ) ETC_EQUIP_raw_COST
       , NULL CUSTOM1
       , NULL CUSTOM2
       , NULL CUSTOM3
       , NULL CUSTOM4
       , NULL CUSTOM5
       , NULL CUSTOM6
       , NULL CUSTOM7
       , NULL CUSTOM8
       , NULL CUSTOM9
       , NULL CUSTOM10
       , NULL CUSTOM11
       , NULL CUSTOM12
       , NULL CUSTOM13
       , NULL CUSTOM14
       , NULL CUSTOM15
       , DECODE(plr.time_phased_type_code, 'P', 'OF', 'G', 'OF', 'N', 'NTR', 'X') -- LINE_TYPE
       , NULL time_dangling_flag
       , NULL rate_dangling_flag
       -- , plr.start_date
  	 -- , plr.end_date
       , g_default_prg_level prg_level
       ,plr.PLAN_TYPE_CODE   PLAN_TYPE_CODE    /*4471527 */
       FROM
       (          ----- First inline view plr .............
            select /*+ no_merge(collapse_bl) */
              collapse_bl.PROJECT_ID      -- , 1 partition_id
            , collapse_bl.WBS_ELEMENT_ID  -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , SUM(collapse_bl.CURR_RECORD_TYPE_ID) CURR_RECORD_TYPE
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
		    , collapse_bl.plan_type_id
            , collapse_bl.BUDGET_VERSION_ID
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.RESOURCE_ASSIGNMENT_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS  -- , CALENDAR_TYPE -- , CALENDAR_ID
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , max(collapse_bl.raw_cost) raw_cost
            , max(collapse_bl.BRDN_COST) BRDN_COST
            , max(collapse_bl.revenue) revenue
            , max(collapse_bl.actual_raw_cost) actual_raw_cost
            , max(collapse_bl.actual_BRDN_COST) actual_BRDN_COST
            , max(collapse_bl.actual_revenue) actual_revenue
            , max(collapse_bl.etc_raw_cost) etc_raw_cost
            , max(collapse_bl.etc_BRDN_COST) etc_BRDN_COST
            , max(collapse_bl.etc_revenue) etc_revenue
            , max(collapse_bl.quantity) quantity
            , max(collapse_bl.actual_quantity) actual_quantity
            , max(collapse_bl.etc_quantity) etc_quantity
            , collapse_bl.start_date start_date
            , collapse_bl.end_date   end_date
            , collapse_bl.period_name period_name  -- , TRACK_AS_LABOR_FLAG track_as_labor_flag
            , collapse_bl.row_id
            , collapse_bl.plan_type_code
            , collapse_bl.WP_FLAG
            from
              (                  ----- Second inline view 'collapse_bl' begin .............
               select /*+ no_merge(spread_bl) */
                  spread_bl.row_id row_id
                , spread_bl.PROJECT_ID
                , spread_bl.BUDGET_VERSION_ID
                , spread_bl.RESOURCE_ASSIGNMENT_ID
                , spread_bl.WBS_ELEMENT_ID
                , spread_bl.RBS_ELEMENT_ID
                , spread_bl.WBS_STRUCT_VERSION_ID
                , spread_bl.RBS_STRUCT_VERSION_ID
  	 	        , spread_bl.plan_type_id
                , spread_bl.BILLABLE_FLAG
                , spread_bl.RESOURCE_CLASS  -- , spread_bl.CALENDAR_TYPE  -- , pji_time.CALENDAR_ID
                , spread_bl.PROJECT_ORGANIZATION_ID
                , spread_bl.PROJECT_ORG_ID
                , spread_bl.TIME_PHASED_TYPE_CODE
                , DECODE( invert.INVERT_ID
                        , 4, spread_bl.func_CURRENCY_CODE
                        , 8, spread_bl.PRJ_CURRENCY_CODE
                        , 16, spread_bl.TXN_CURRENCY_CODE ) CURRENCY_CODE
                , invert.INVERT_ID CURR_RECORD_TYPE_ID
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_raw_cost
                         , 8, spread_bl.PRJ_raw_cost
                         , 16, spread_bl.TXN_raw_cost) raw_cost
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_BRDN_COST
                         , 8, spread_bl.PRJ_BRDN_COST
                         , 16, spread_bl.TXN_BRDN_COST ) BRDN_COST
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_revenue
                         , 8, spread_bl.PRJ_revenue
                         , 16, spread_bl.TXN_revenue ) revenue
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_actual_raw_cost
						 , 8, spread_bl.prj_actual_raw_cost
						 , 16, spread_bl.txn_actual_raw_cost ) actual_raw_cost
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_actual_brdn_cost
						 , 8, spread_bl.prj_actual_brdn_cost
						 , 16, spread_bl.txn_actual_brdn_cost ) actual_brdn_cost
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_actual_revenue
						 , 8, spread_bl.prj_actual_revenue
						 , 16, spread_bl.txn_actual_revenue ) actual_revenue
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_etc_raw_cost
						 , 8, spread_bl.prj_etc_raw_cost
						 , 16, spread_bl.txn_etc_raw_cost ) etc_raw_cost
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_etc_brdn_cost
						 , 8, spread_bl.prj_etc_brdn_cost
						 , 16, spread_bl.txn_etc_brdn_cost ) etc_brdn_cost
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_etc_revenue
						 , 8, spread_bl.prj_etc_revenue
						 , 16, spread_bl.txn_etc_revenue ) etc_revenue
            	, spread_bl.quantity quantity
            	, spread_bl.actual_quantity actual_quantity
            	, spread_bl.etc_quantity etc_quantity
            	, spread_bl.start_date start_date
            	, spread_bl.end_date   end_date
            	, spread_bl.period_name period_name
            	-- , spread_bl.TRACK_AS_LABOR_FLAG track_as_labor_flag
                             , spread_bl.plan_type_code
                , spread_bl.WP_FLAG
                from
                  (     ----- Third inline view 'spread_bl'  .............
                    SELECT /*+ ordered */
                	  ra.project_id
                	, bl.rowid row_id
                	, ra.budget_version_id
                	, bl.resource_asSIGNment_id
                	, DECODE(ra.task_id, 0, pevs.proj_element_id, ra.task_id) wbs_element_id
                	, NVL(ra.rbs_element_id, -1)              rbs_element_id
                	, ver.wbs_struct_version_id      wbs_struct_version_id
                	, NVL(ver.rbs_struct_version_id, -1)      rbs_struct_version_id
			, ver.plan_type_id               plan_type_id
			, ra.rate_based_flag             billable_flag
			, ra.resource_class_code         resource_class
                	, bl.txn_currency_code           txn_currency_code
                	, bl.txn_raw_cost                txn_raw_cost
                	, bl.txn_burdened_COST           txn_brdn_COST
                	, bl.txn_revenue                 txn_revenue
			, DECODE(ver.wp_flag, 'N', bl.txn_init_raw_cost, NULL)                txn_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.txn_init_burdened_cost, NULL)             txn_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.txn_init_revenue, NULL)                   txn_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N', (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0)), NULL) txn_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0)), NULL) txn_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.txn_revenue - NVL(bl.txn_init_revenue, 0)), NULL) txn_etc_revenue     -- new
                	, bl.project_currency_code          prj_currency_code
                	, bl.project_raw_cost               prj_raw_cost
                	, bl.project_burdened_COST          prj_BRDN_COST
                	, bl.project_revenue                prj_revenue
			, DECODE(ver.wp_flag, 'N', bl.project_init_raw_cost, NULL)          prj_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.project_init_burdened_cost, NULL)     prj_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.project_init_revenue, NULL)           prj_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N', (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0)), NULL) prj_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0)), NULL) prj_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.project_revenue - NVL(bl.project_init_revenue, 0)), NULL) prj_etc_revenue     -- new
                	, bl.projfunc_currency_code         func_currency_code
                  , bl.raw_cost                       func_raw_cost
                	, bl.burdened_COST                  func_BRDN_COST
                	, bl.revenue                        func_revenue
			, DECODE(ver.wp_flag, 'N', bl.init_raw_cost , NULL)                 func_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.init_burdened_cost , NULL)            func_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.init_revenue , NULL)                  func_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N', (bl.raw_cost - NVL(bl.init_raw_cost, 0)), NULL) func_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)), NULL) func_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.revenue - NVL(bl.init_revenue, 0)), NULL) func_etc_revenue     -- new
                	, g_global1_currency_code        glb1_currency_code
                  , NULL                           glb1_raw_cost
                	, NULL                           glb1_BRDN_COST
                	, NULL                           glb1_revenue
                	, g_global2_currency_code        glb2_currency_code
                  , NULL                           glb2_raw_cost
                	, NULL                           glb1_BRDN_COST
                	, NULL                           glb1_revenue
                	, bl.quantity                       quantity
			, DECODE(ver.wp_flag, 'N', bl.init_quantity, NULL)                  actual_quantity  -- new
			, DECODE(ver.wp_flag, 'N', (bl.quantity - NVL(bl.init_quantity, 0)), NULL) etc_quantity  -- new
                	, bl.start_date
                	, bl.END_date
                	, NVL(bl.period_name, g_ntp_period_name)  period_name
                	, ver.time_phased_type_code time_phased_type_code
                	, ppa.org_id project_org_id
                	, ppa.carrying_out_organization_id project_organization_id
	, ver.plan_type_code   /*4471527 */
                        , ver.WP_FLAG
                 FROM
                     PJI_FM_EXTR_PLNVER4           ver
                   , pa_resource_asSIGNments       ra
                   , PA_BUDGET_LINES               bl
                   , pa_projects_all               ppa
                   , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                 WHERE
                         ra.resource_asSIGNment_id = bl.resource_asSIGNment_id
                     AND ra.project_id = ver.PROJECT_ID
                     AND ra.budget_version_id = ver.plan_version_id
                     AND ver.project_id = ppa.project_id
                     AND txn_currency_code IS NOT NULL
                     AND bl.project_currency_code IS NOT NULL
                     AND bl.projfunc_currency_code IS NOT NULL
			   AND pevs.element_version_id = ver.wbs_struct_version_id
			   AND pevs.project_id = ver.project_id
			   AND ver.worker_id = g_worker_id
                     AND    ver.time_phased_type_code IN ('P', 'G', 'N')
				  ) spread_bl
				   ---- end of third inline view 'spread_bl'...........
            	  ,
            	    (
                      select 4   INVERT_ID from dual union all
                      select 8   INVERT_ID from dual union all
                      select 16  INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('TXN_CURR_FLAG') = 'Y'
                    ) invert
				)  collapse_bl
				----  End of second inline view 'collapse_bl' ..........
			GROUP BY
              collapse_bl.PROJECT_ID
            , collapse_bl.WBS_ELEMENT_ID
            -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
			, collapse_bl.plan_type_id
            , collapse_bl.BUDGET_VERSION_ID
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.RESOURCE_ASSIGNMENT_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , collapse_bl.start_date
            , collapse_bl.end_date
            , collapse_bl.period_name
            , collapse_bl.row_id
           , collapse_bl.plan_type_code
            , collapse_bl.WP_FLAG
       ) plr
				----  End of first inline view plr ..........
       , PJI_ORG_EXTR_INFO            orginfo
       , pji_time_cal_period_v    pji_time
         WHERE  1=1
           -- AND    orginfo.projfunc_currency_mau is not NULL
           AND    plr.project_org_id         = orginfo.org_id
           AND    DECODE(plr.time_phased_type_code
                   , 'P', orginfo.pa_calendar_id
                   , 'G', orginfo.gl_calendar_id
                   , -l_max_project_id  ) = pji_time.calendar_id
           AND    plr.period_name = pji_time.name
       GROUP BY
         plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , DECODE(plr.time_phased_type_code
              , 'N', -1
              , pji_time.cal_period_id)
       , DECODE(plr.time_phased_type_code
               , 'P', 32
               , 'G', 32
               , 'N', 2048
               , -1) -- period type id...
       , DECODE(plr.time_phased_type_code
               , 'P', 'P'
               , 'G', 'G'
               , 'N', 'A'
               , 'X')     --   CALENDAR_TYPE
       , plr.CURR_RECORD_TYPE  -- curr code missing.
  	   , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.BUDGET_VERSION_ID
  	 , plr.plan_type_id
       --  , plr.start_date
  	 -- , plr.end_date
       , DECODE(plr.time_phased_type_code, 'P', 'OF', 'G', 'OF', 'N', 'NTR', 'X')
       ,plr.plan_type_code ;


    print_time('EXTRACT_PLAN_AMOUNTS_PRIRBS : l_count ' || SQL%ROWCOUNT );

    DELETE_NTP_CAL_RECORD ( p_max_project_id => l_max_project_id );


    print_time('EXTRACT_PLAN_AMOUNTS_PRIRBS : End' );

EXCEPTION
  WHEN OTHERS THEN
    print_time('EXTRACT_PLAN_AMOUNTS_PRIRBS : Exception ' || SQLERRM );
    print_time('EXTRACT_PLAN_AMOUNTS_PRIRBS : Begin worker id is ... ' || 1);
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'EXTRACT_PLAN_AMOUNTS_PRIRBS');
    RAISE;
END;




----------------------------------------------
--- Overridden ETC Pull apis.
----------------------------------------------

PROCEDURE RETRIEVE_OVERRIDDEN_WP_ETC IS

  l_return_status varchar2(1);
  l_msg_data varchar2(500);
  l_msg_count NUMBER;

  l_project_id NUMBER := 6842; -- 6976; -- 7185
  l_latest_pub_str_ver NUMBER := 34269; -- 34951; -- 34982
  l_count NUMBER := NULL;

  CURSOR c_lp_struct_ver IS
  SELECT ver.project_id, ver.wbs_struct_version_id
  FROM   pji_fm_extr_plnver4 ver
  WHERE  ver.wp_flag = 'Y'
    AND  ver.lp_flag = 'Y'
    AND  ver.worker_id = g_worker_id;

BEGIN

  -- dbms_output.put_line ( ' Begin.. ');

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => l_return_status ) ;

  --
  -- Why the following code:
  -- When RETRIEVE_OVERRIDDEN_WP_ETC is called, we intend to process only overridden ETC values.
  -- Currently there is no locking mechanism for either wbs header or the plan lines in this flow.
  --  One of the following alternative solutions are considered.
  -- a. Implement locking.
  -- b.
  DELETE FROM pji_fm_extr_plan_lines;
  -- c. call PJI_FM_XBS_ACCUM_MAINT.plan_update_pvt; and then call delete plan lines.
  -- Going with b for now, for simplicity.
  --


  FOR i IN c_lp_struct_ver LOOP

    BEGIN

      print_time ( ' i.project_id = ' || i.project_id || ' i.wbs_struct_version_id ' || i.wbs_struct_version_id );

      pa_progress_pub.COPY_PROGRESS_ACT_ETC(
        p_project_id               => i.project_id
      , p_src_str_ver_id           => i.wbs_struct_version_id
      , p_dst_str_ver_id           => i.wbs_struct_version_id
      , p_pji_conc_prog_context   => 'Y'
      , p_calling_context          => 'PJI' -- IN      VARCHAR2        := 'PUBLISH'
      -- ,p_copy_actuals_flag        IN      VARCHAR2        := 'Y' -- We want the default value.
      -- ,p_copy_ETC_flag            IN      VARCHAR2        := 'Y' -- We want the default value.
      , x_return_status            => l_return_status
      , x_msg_count                => l_msg_count
      , x_msg_data                 => l_msg_data
      );

    EXCEPTION
      WHEN OTHERS THEN
        print_time ( ' RETRIEVE_OVERRIDDEN_WP_ETC ' || SQLERRM );
    END;

  END LOOP;

  --
  -- Delete plan lines that have no relevant overridden ETC info to avoid unnecessary processing overhead.
  --
  DELETE FROM pji_fm_extr_plan_lines
  WHERE
    (PROJECT_ID, PLAN_VERSION_ID) IN
	 (SELECT DISTINCT project_id, plan_version_id
	  FROM pji_fm_extr_plnver4)          AND
    ETC_QUANTITY    IS NULL                AND
    ETC_TXN_BURDENED_COST IS NULL          AND
    ETC_PRJ_BURDENED_COST IS NULL          AND
    ETC_PFC_BURDENED_COST IS NULL          AND
    ETC_TXN_RAW_COST IS NULL               AND
    ETC_PRJ_RAW_COST IS NULL               AND
    ETC_PFC_RAW_COST IS NULL;


  /*
  dbms_output.put_line ( ' After call.. l_msg_code ' || l_msg_data || ' l_return_status ' || l_return_status );

  SELECT COUNT(1)
  INTO   l_count
  FROM   pji_fm_extr_plan_lines
  WHERE  project_id = l_project_id;

  dbms_output.put_line ( ' Count in plan lines is.. ' || l_count );
  */

EXCEPTION
  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'RETRIEVE_OVERRIDDEN_WP_ETC'
    , x_return_status  => l_return_status ) ;

    RAISE;
END;


PROCEDURE EXTRACT_PLAN_ETC_PRIRBS (
  p_slice_type      IN VARCHAR2 := 'PRI'
  -- Valid values are 'PRI' and 'SEC'.
  -- 'PRI' for RBS push and Partial refresh
  -- 'SEC' for Truncate
) IS

  l_max_project_id  NUMBER := NULL;
  l_sysdate         DATE := SYSDATE;
  l_return_status varchar2(1);
  l_msg_data varchar2(500);
  l_msg_count NUMBER;

BEGIN

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => l_return_status ) ;

  print_time('EXTRACT_PLAN_ETC_PRIRBS : Begin' );
  print_time('EXTRACT_PLAN_ETC_PRIRBS : Begin worker id is ... ' || g_worker_id);

  IF (p_slice_type NOT IN ('PRI','SEC')) THEN
    print_time('EXTRACT_PLAN_ETC_PRIRBS : invalid p_slice_type ' || p_slice_type );
    RETURN;
  END IF;


  INSERT_NTP_CAL_RECORD ( x_max_project_id => l_max_project_id );

  IF (l_max_project_id IS NULL) THEN
    RETURN;
  END IF;


     INSERT INTO PJI_FP_AGGR_PJP1
    (
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , LINE_TYPE
       , RATE_DANGLING_FLAG
       , TIME_DANGLING_FLAG
       , PRG_LEVEL
       , PLAN_TYPE_CODE
	)
	   SELECT /*+ ordered no_merge(plr) */
         g_worker_id  WORKER_ID
       , plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID project_element_id
       , DECODE(plr.time_phased_type_code
              , 'N', -1
              , pji_time.cal_period_id)  time_id
       , DECODE(plr.time_phased_type_code
               , 'P', 32
               , 'G', 32
               , 'N', 2048
               , -1) period_type_id -- period type id...
       , DECODE(plr.time_phased_type_code
               , 'P', 'P'
               , 'G', 'G'
               , 'N', 'A'
               , 'X')    CALENDAR_TYPE
       , 'L' RBS_AGGR_LEVEL
       , 'N' WBS_ROLLUP_FLAG
       , 'N' PRG_ROLLUP_FLAG
       , plr.CURR_RECORD_TYPE  CURR_RECORD_TYPE_id
       , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID  RBS_VERSION_ID
       , plr.BUDGET_VERSION_ID plan_version_id
       , plr.plan_type_id
       , SUM(plr.RAW_COST) RAW_COST
       , SUM(plr.BRDN_COST) BRDN_COST
       , SUM(plr.REVENUE) REVENUE
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )  BILL_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )   BILL_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YPEOPLE', plr.raw_cost, 0 ) )  BILL_LABOR_RAW_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YPEOPLE' , plr.BRDN_COST, 0 ) )   BILL_LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'YPEOPLE', plr.quantity, 0 ) )  BILL_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'YPEOPLE',
                                             DECODE ( plr.billable_flag , 'Y' , plr.quantity , 0 ) , 0 ) )  BILL_LABOR_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.raw_cost, 0 ) )  EQUIPMENT_RAW_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.BRDN_COST, 0 ) )   EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )      CAPITALIZABLE_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )      CAPITALIZABLE_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.raw_cost, 0 ) )  LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.BRDN_COST, 0 ) )   LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.quantity, 0 ) )   labor_hrs */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', DECODE(plr.billable_flag , 'Y', plr.quantity,0),
                                                    0 ) )   labor_hrs  -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.revenue, 0 ) )  LABOR_REVENUE
       /* , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', plr.quantity, 0 ) )  EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', DECODE(plr.billable_flag , 'Y', plr.quantity, 0),
                                                    0 ) )  EQUIPMENT_HOURS -- bug 6039785
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YEQUIPMENT', plr.quantity, 0 ) )  BILLABLE_EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YEQUIPMENT', DECODE(plr.billable_flag , 'Y', plr.quantity, 0),
                                                    0 ) )  BILLABLE_EQUIPMENT_HOURS -- bug 6039785
       , TO_NUMBER(NULL)                SUP_INV_COMMITTED_COST
       , TO_NUMBER(NULL)                PO_COMMITTED_COST
       , TO_NUMBER(NULL)                PR_COMMITTED_COST
       , TO_NUMBER(NULL)                OTH_COMMITTED_COST
       /* , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.actual_quantity, 0 ) ) ACT_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE' , DECODE (plr.billable_flag ,'Y', plr.actual_quantity,0),
                                                                                0 ) ) ACT_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', plr.actual_quantity, 0 ) ) ACT_EQUIP_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', DECODE (plr.billable_flag ,'Y', plr.actual_quantity, 0),
                                                                                0 ) ) ACT_EQUIP_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.actual_BRDN_COST, 0 ) ) ACT_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.actual_BRDN_COST, 0 ) ) ACT_EQUIP_BRDN_COST
       , SUM ( plr.actual_brdn_cost ) ACT_BRDN_COST
       , SUM ( plr.actual_raw_cost ) ACT_RAW_COST
       , SUM ( plr.actual_revenue ) ACT_REVENUE
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.actual_RAW_COST, 0 ) ) ACT_LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.actual_RAW_COST, 0 ) ) ACT_EQUIP_RAW_COST
       /* , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.etc_quantity, 0 ) ) ETC_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', DECODE (plr.billable_flag , 'Y' , plr.ETC_quantity,0),
                                                                                0 ) ) ETC_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', plr.etc_quantity, 0 ) ) ETC_EQUIP_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', DECODE (plr.billable_flag , 'Y' , plr.etc_quantity, 0) ,
                                                                                0 ) ) ETC_EQUIP_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.etc_BRDN_COST, 0 ) ) ETC_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.etc_BRDN_COST, 0 ) ) ETC_EQUIP_BRDN_COST
       , SUM(plr.etc_BRDN_COST) ETC_BRDN_COST
       , SUM(plr.etc_RAW_COST) ETC_RAW_COST
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.etc_raw_cost, 0 ) ) ETC_LABOR_raw_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', plr.etc_raw_cost, 0 ) ) ETC_EQUIP_raw_COST
       , NULL CUSTOM1
       , NULL CUSTOM2
       , NULL CUSTOM3
       , NULL CUSTOM4
       , NULL CUSTOM5
       , NULL CUSTOM6
       , NULL CUSTOM7
       , NULL CUSTOM8
       , NULL CUSTOM9
       , NULL CUSTOM10
       , NULL CUSTOM11
       , NULL CUSTOM12
       , NULL CUSTOM13
       , NULL CUSTOM14
       , NULL CUSTOM15
       , DECODE(plr.time_phased_type_code, 'P', 'OF', 'G', 'OF', 'N', 'NTR', 'X') LINE_TYPE
       , NULL time_dangling_flag
       , NULL rate_dangling_flag
       , g_default_prg_level prg_level
       , plr.PLAN_TYPE_CODE
       FROM
       (          ----- First inline view plr .............
            SELECT /*+ no_merge(collapse_bl) */
              collapse_bl.PROJECT_ID      -- , 1 partition_id
            , collapse_bl.WBS_ELEMENT_ID  -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , SUM(collapse_bl.CURR_RECORD_TYPE_ID) CURR_RECORD_TYPE
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
		    , collapse_bl.plan_type_id
            , collapse_bl.BUDGET_VERSION_ID
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS  -- , CALENDAR_TYPE -- , CALENDAR_ID
            , collapse_bl.CURRENCY_CODE
            , MAX(collapse_bl.raw_cost) raw_cost
            , MAX(collapse_bl.BRDN_COST) BRDN_COST
            , MAX(collapse_bl.revenue) revenue
            , MAX(collapse_bl.actual_raw_cost) actual_raw_cost
            , MAX(collapse_bl.actual_BRDN_COST) actual_BRDN_COST
            , MAX(collapse_bl.actual_revenue) actual_revenue
            , MAX(collapse_bl.etc_raw_cost) etc_raw_cost
            , MAX(collapse_bl.etc_BRDN_COST) etc_BRDN_COST
            , MAX(collapse_bl.quantity) quantity
            , MAX(collapse_bl.actual_quantity) actual_quantity
            , MAX(collapse_bl.etc_quantity) etc_quantity
            , collapse_bl.period_name period_name  -- , TRACK_AS_LABOR_FLAG track_as_labor_flag
            , collapse_bl.row_id
            , collapse_bl.plan_type_code
            , collapse_bl.time_phased_type_code
            FROM
              (                  ----- Second inline view 'collapse_bl' begin .............
               SELECT /*+ no_merge(spread_bl) */
                  spread_bl.row_id row_id
                , spread_bl.PROJECT_ID
                , spread_bl.BUDGET_VERSION_ID
                , spread_bl.WBS_ELEMENT_ID
                , spread_bl.RBS_ELEMENT_ID
                , spread_bl.WBS_STRUCT_VERSION_ID
                , spread_bl.RBS_STRUCT_VERSION_ID
  	 	        , spread_bl.plan_type_id
                , spread_bl.BILLABLE_FLAG
                , spread_bl.RESOURCE_CLASS  -- , spread_bl.CALENDAR_TYPE  -- , pji_time.CALENDAR_ID
                , spread_bl.PROJECT_ORGANIZATION_ID
                , spread_bl.PROJECT_ORG_ID
                , DECODE( invert.INVERT_ID
                        , 4, spread_bl.func_CURRENCY_CODE
                        , 8, spread_bl.PRJ_CURRENCY_CODE
                        , 16, spread_bl.TXN_CURRENCY_CODE ) CURRENCY_CODE
                , invert.INVERT_ID CURR_RECORD_TYPE_ID
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_raw_cost
                         , 8, spread_bl.PRJ_raw_cost
                         , 16, spread_bl.TXN_raw_cost) raw_cost
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_BRDN_COST
                         , 8, spread_bl.PRJ_BRDN_COST
                         , 16, spread_bl.TXN_BRDN_COST ) BRDN_COST
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_revenue
                         , 8, spread_bl.PRJ_revenue
                         , 16, spread_bl.TXN_revenue ) revenue
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_actual_raw_cost
                         , 8, spread_bl.prj_actual_raw_cost
                         , 16, spread_bl.txn_actual_raw_cost ) actual_raw_cost
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_actual_brdn_cost
						 , 8, spread_bl.prj_actual_brdn_cost
						 , 16, spread_bl.txn_actual_brdn_cost ) actual_brdn_cost
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_actual_revenue
						 , 8, spread_bl.prj_actual_revenue
						 , 16, spread_bl.txn_actual_revenue ) actual_revenue
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_etc_raw_cost
						 , 8, spread_bl.prj_etc_raw_cost
						 , 16, spread_bl.txn_etc_raw_cost ) etc_raw_cost
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_etc_brdn_cost
						 , 8, spread_bl.prj_etc_brdn_cost
						 , 16, spread_bl.txn_etc_brdn_cost ) etc_brdn_cost
            	, spread_bl.quantity quantity
            	, spread_bl.actual_quantity actual_quantity
            	, spread_bl.etc_quantity etc_quantity
            	, spread_bl.period_name period_name
                              ,spread_bl.plan_type_code
                , spread_bl.time_phased_type_code
                FROM
                  (     ----- Third inline view 'spread_bl'  .............
                    SELECT /*+ ordered */
                	  ra.project_id
                	, bl.ROWID row_id
                	, ra.budget_version_id
                	, DECODE(ra.task_id, 0, pevs.proj_element_id, ra.task_id) wbs_element_id
                	, NVL(ra.rbs_element_id, -1)              rbs_element_id
                	, ver.wbs_struct_version_id      wbs_struct_version_id
                	, NVL(ver.rbs_struct_version_id, -1)      rbs_struct_version_id
			, ver.plan_type_id               plan_type_id
			, ra.rate_based_flag             billable_flag
			, ra.resource_class_code         resource_class
                	, bl.txn_currency_code           txn_currency_code
                	, bl.txn_raw_cost                txn_raw_cost
                	, bl.txn_burdened_COST           txn_brdn_COST
                	, bl.txn_revenue                 txn_revenue
			, DECODE(p_slice_type||ver.wp_flag, 'SECY',
                             decode(ppa.structure_sharing_code, 'SHARE_FULL',TO_NUMBER(NULL),bl.txn_init_raw_cost),
                             bl.txn_init_raw_cost) txn_actual_raw_cost
			, DECODE(p_slice_type||ver.wp_flag, 'SECY',
                             decode(ppa.structure_sharing_code, 'SHARE_FULL',TO_NUMBER(NULL),bl.txn_init_burdened_cost),
                             bl.txn_init_burdened_cost) txn_actual_brdn_cost
			, DECODE(p_slice_type||ver.wp_flag, 'SECY', TO_NUMBER(NULL), bl.txn_init_revenue) txn_actual_revenue
			, DECODE(ver.wp_flag, 'N', bl.txn_raw_cost - bl.txn_init_raw_cost, bl.txn_raw_cost) txn_etc_raw_cost
			, DECODE(ver.wp_flag, 'N', bl.txn_burdened_cost - bl.txn_init_burdened_cost, bl.txn_burdened_cost) txn_etc_brdn_cost
                	, bl.project_currency_code          prj_currency_code
                	, bl.project_raw_cost               prj_raw_cost
                	, bl.project_burdened_COST          prj_BRDN_COST
                	, bl.project_revenue                prj_revenue
			, DECODE(p_slice_type||ver.wp_flag, 'SECY',
                             decode(ppa.structure_sharing_code, 'SHARE_FULL',TO_NUMBER(NULL),bl.project_init_raw_cost),
                             bl.project_init_raw_cost)          prj_actual_raw_cost
			, DECODE(p_slice_type||ver.wp_flag, 'SECY',
                             decode(ppa.structure_sharing_code, 'SHARE_FULL',TO_NUMBER(NULL),bl.project_init_burdened_cost),
                             bl.project_init_burdened_cost)     prj_actual_brdn_cost
			, DECODE(p_slice_type||ver.wp_flag, 'SECY', TO_NUMBER(NULL), bl.project_init_revenue)           prj_actual_revenue
			, DECODE(ver.wp_flag, 'N', bl.project_raw_cost - bl.project_init_raw_cost, bl.project_raw_cost) prj_etc_raw_cost
			, DECODE(ver.wp_flag, 'N', bl.project_burdened_cost - bl.project_init_burdened_cost, bl.project_burdened_cost) prj_etc_brdn_cost
                	, bl.projfunc_currency_code         func_currency_code
                  , bl.raw_cost                       func_raw_cost
                	, bl.burdened_COST                  func_BRDN_COST
                	, bl.revenue                        func_revenue
			, DECODE(p_slice_type||ver.wp_flag, 'SECY',
                             decode(ppa.structure_sharing_code, 'SHARE_FULL',TO_NUMBER(NULL),bl.init_raw_cost),
                             bl.init_raw_cost)                  func_actual_raw_cost
			, DECODE(p_slice_type||ver.wp_flag, 'SECY',
                             decode(ppa.structure_sharing_code, 'SHARE_FULL',TO_NUMBER(NULL),bl.init_burdened_cost),
                             bl.init_burdened_cost)             func_actual_brdn_cost
			, DECODE(p_slice_type||ver.wp_flag, 'SECY', TO_NUMBER(NULL), bl.init_revenue)                   func_actual_revenue
			, DECODE(ver.wp_flag, 'N', bl.raw_cost - bl.init_raw_cost, bl.raw_cost) func_etc_raw_cost
			, DECODE(ver.wp_flag, 'N', bl.burdened_cost - bl.init_burdened_cost, bl.burdened_cost) func_etc_brdn_cost
                  , bl.quantity                       quantity
			, DECODE(p_slice_type||ver.wp_flag, 'SECY',
                             decode(ppa.structure_sharing_code, 'SHARE_FULL',TO_NUMBER(NULL),bl.init_quantity),
                             bl.init_quantity)                  actual_quantity
			, DECODE(ver.wp_flag, 'N', bl.quantity - bl.init_quantity, bl.quantity) etc_quantity
                	, Decode(ver.time_phased_type_code,'N','XXX',NVL(bl.period_name, 'XXX'))    period_name /* Added for bug 8708651 */
                	, ppa.org_id project_org_id
                	, ppa.carrying_out_organization_id project_organization_id
                              , ver.plan_type_code
                        , ver.time_phased_type_code
                 FROM
                     PJI_FM_EXTR_PLNVER4           ver
                   , PA_RESOURCE_ASSIGNMENTS       ra
                   , PA_BUDGET_LINES               bl
                   , PA_PROJECTS_ALL               ppa
                   , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                 WHERE
                         ra.resource_asSIGNment_id = bl.resource_asSIGNment_id
					 AND (
                           (
                                 ( p_slice_type = 'PRI' )
                             AND ( ( ver.wp_flag = 'Y' ) OR ( ver.wp_flag = 'N' AND ver.baselined_flag = 'N' ) )
                           )
                           OR
                           ( p_slice_type = 'SEC' )
                         )
                     AND ra.project_id = ver.PROJECT_ID
                     AND ra.budget_version_id = ver.plan_version_id
                     AND ver.project_id = ppa.project_id
                     AND bl.txn_currency_code IS NOT NULL
                     AND bl.project_currency_code IS NOT NULL
                     AND bl.projfunc_currency_code IS NOT NULL
			   AND pevs.element_version_id = ver.wbs_struct_version_id
			   AND pevs.project_id = ver.project_id
			   AND ver.worker_id = g_worker_id
                     AND    ver.time_phased_type_code IN ('P', 'G', 'N')
			   UNION ALL
                    SELECT /*+ ordered */
                	  bl.project_id
                	, bl.ROWID row_id
                	, bl.plan_version_id budget_version_id
                	, DECODE(bl.project_element_id, 0, pevs.proj_element_id, bl.project_element_id) wbs_element_id
                	, NVL(bl.rbs_element_id, -1)   rbs_element_id
                	, bl.struct_ver_id             wbs_struct_version_id
                	, NVL(ver.rbs_struct_version_id, -1)   rbs_struct_version_id
			       , bl.plan_type_id               plan_type_id -- ver.plan_type_id
                  , bl.rate_based_flag              billable_flag -- ra.rate_based_flag             billable_flag
                  , bl.resource_class_code          resource_class -- ra.resource_class_code         resource_class
                	, bl.txn_currency_code               txn_currency_code
                	, bl.txn_raw_cost                    txn_raw_cost
                	, bl.txn_burdened_cost               txn_BRDN_COST
                	, bl.txn_revenue                   txn_revenue
			, bl.act_txn_raw_cost           act_txn_raw_cost
			, bl.act_txn_burdened_cost           act_txn_brdn_cost
			, bl.act_txn_revenue           act_txn_revenue
			, bl.etc_txn_raw_cost           etc_txn_raw_cost
			, bl.etc_txn_burdened_cost           etc_txn_brdn_cost
                	, bl.prj_currency_code               prj_currency_code
                	, bl.prj_raw_cost                    prj_raw_cost
                	, bl.prj_burdened_cost               prj_BRDN_COST
                	, bl.prj_revenue                   prj_revenue
			, bl.act_prj_raw_cost           act_prj_raw_cost
			, bl.act_prj_burdened_cost           act_prj_brdn_cost
			, bl.act_prj_revenue           act_prj_revenue
			, bl.etc_prj_raw_cost           etc_prj_raw_cost
			, bl.etc_prj_burdened_cost           act_prj_brdn_cost
                	, bl.pfc_currency_code               pfc_currency_code
                	, bl.pfc_raw_cost                    prj_raw_cost
                	, bl.pfc_burdened_cost               prj_BRDN_COST
                	, bl.pfc_revenue                   prj_revenue
			, bl.act_pfc_raw_cost           act_prj_raw_cost
			, bl.act_pfc_burdened_cost           act_prj_brdn_cost
			, bl.act_pfc_revenue           act_prj_revenue
			, bl.etc_pfc_raw_cost           etc_prj_raw_cost
			, bl.etc_pfc_burdened_cost           act_prj_brdn_cost
                	, bl.quantity                       quantity
			, bl.act_quantity                  act_quantity
			, bl.etc_quantity                  etc_quantity
                	, NVL(bl.period_name, 'XXX')         period_name
                	, bl.project_org_id                       project_org_id
                	, ppa.carrying_out_organization_id  project_organization_id
 	, ver.plan_type_code
                        , ver.time_phased_type_code
                FROM
                    PJI_FM_EXTR_PLNVER4           ver
                  , PJI_FM_EXTR_PLAN_LINES        bl
                  , PA_PROJECTS_ALL               ppa
                  , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                    WHERE 1=1
                               AND ver.wp_flag = 'Y'
                               AND bl.project_id = ver.project_id
                               AND bl.plan_version_id = ver.plan_version_id
                               AND bl.plan_type_id = ver.plan_type_id
                               AND ppa.project_id = ver.project_id
                               AND bl.project_id = ppa.project_id
                               AND bl.TXN_CURRENCY_CODE IS NOT NULL
                               AND bl.prj_currency_code IS NOT NULL
                               AND bl.pfc_currency_code IS NOT NULL
                               AND pevs.element_version_id = ver.wbs_struct_version_id
                               AND pevs.project_id = ver.project_id
                               AND ver.worker_id = g_worker_id
                               AND ver.time_phased_type_code IN ('P', 'G', 'N')
                               AND p_slice_type = 'SEC' -- 4682341
				  ) spread_bl
				   ---- end of third inline view 'spread_bl'...........
            	  ,
            	    (
                      SELECT 4   INVERT_ID FROM dual UNION ALL
                      SELECT 8   INVERT_ID FROM dual UNION ALL
                      SELECT 16  INVERT_ID FROM dual where PJI_UTILS.GET_SETUP_PARAMETER('TXN_CURR_FLAG') = 'Y'
                    ) invert
				)  collapse_bl
				----  End of second inline view 'collapse_bl' ..........
			GROUP BY
              collapse_bl.PROJECT_ID
            , collapse_bl.WBS_ELEMENT_ID
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
			, collapse_bl.plan_type_id
            , collapse_bl.BUDGET_VERSION_ID
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS
            , collapse_bl.CURRENCY_CODE
            , collapse_bl.period_name
            , collapse_bl.row_id
            , collapse_bl.plan_type_code
            , collapse_bl.time_phased_type_code
       ) plr
				----  End of first inline view plr ..........
       , PJI_ORG_EXTR_INFO            orginfo
       , pji_time_cal_period_v    pji_time
         WHERE  1=1
           -- AND    orginfo.projfunc_currency_mau is not NULL
           AND    plr.project_org_id         = orginfo.org_id
           AND    DECODE(plr.time_phased_type_code
                   , 'P', orginfo.pa_calendar_id
                   , 'G', orginfo.gl_calendar_id
                   , - l_max_project_id ) = pji_time.calendar_id
           AND    plr.period_name = pji_time.name
       GROUP BY
         plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , DECODE(plr.time_phased_type_code
              , 'N', -1
              , pji_time.cal_period_id)
       , DECODE(plr.time_phased_type_code
               , 'P', 32
               , 'G', 32
               , 'N', 2048
               , -1) -- period type id...
       , DECODE(plr.time_phased_type_code
               , 'P', 'P'
               , 'G', 'G'
               , 'N', 'A'
               , 'X')     --   CALENDAR_TYPE
       , plr.CURR_RECORD_TYPE  -- curr code missing.
  	   , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.BUDGET_VERSION_ID
  	 , plr.plan_type_id
       , DECODE(plr.time_phased_type_code, 'P', 'OF', 'G', 'OF', 'N', 'NTR', 'X')
       , plr.PLAN_TYPE_CODE;


    print_time('EXTRACT_PLAN_ETC_PRIRBS : Finished. # rows extracted is ' || SQL%ROWCOUNT);

    DELETE_NTP_CAL_RECORD ( p_max_project_id => l_max_project_id );


EXCEPTION
  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'EXTRACT_PLAN_ETC_PRIRBS'
    , x_return_status  => l_return_status ) ;

    RAISE;
END;


PROCEDURE DELETE_PLAN_LINES
( x_return_status OUT NOCOPY VARCHAR2 ) IS

--Bug 6047966
l_process                  varchar2(30);
l_plan_ver_type_code       varchar2(30);

BEGIN

  print_time ( 'DELETE_PLAN_LINES : begin ' );

  Pji_Pjp_Fp_Curr_Wrap.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status ) ;

 --Bug 6047966.
 l_process := PJI_PJP_SUM_MAIN.g_process || to_char(g_worker_id);
 l_plan_ver_type_code := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'PLAN_VERSION');

  DELETE FROM pji_fm_extr_plan_lines
  WHERE (project_id, plan_version_id) IN
    (SELECT ver.project_id, ver.plan_version_id
     FROM   pji_fm_extr_plnver4 ver
     WHERE ver.worker_id = g_worker_id)
       AND txn_currency_code IS NOT NULL
       AND prj_currency_code IS NOT NULL
       AND pfc_currency_code IS NOT NULL;

  --Bug 6047966. In case actuals alone are summarized, pji_fm_extr_plnver4
  --contains only -1 record. Hence that case should be handled.
   IF l_plan_ver_type_code ='ACTUAL' THEN

     DELETE FROM pji_fm_extr_plan_lines
     WHERE (project_id) IN
       (SELECT ver.project_id
        FROM   pji_fm_extr_plnver4 ver
        WHERE ver.worker_id = g_worker_id
        AND   ver.plan_version_id=-1)
          AND txn_currency_code IS NOT NULL
          AND prj_currency_code IS NOT NULL
          AND pfc_currency_code IS NOT NULL;

   END IF;

  print_time ( 'DELETE_PLAN_LINES : after deletion of plan lines , # rows deleted is  ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'DELETE_PLAN_LINES'
    , x_return_status  => x_return_status ) ;

    RAISE;
END;


--
-- Inserts into FP reporting lines fact the data in the interim pjp1 table.
--
PROCEDURE INSERT_INTO_FP_FACT ( p_slice_type IN VARCHAR2 := NULL) IS
    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

/*commenting for bug 7497672
-- Bug 7010864
	TYPE row_id_tab_type   IS TABLE OF rowid index by binary_integer;
    x_row_id               row_id_tab_type;

   cursor c1 is
      select rowid from pji_fp_aggr_pjp1
	   where worker_id = g_worker_id;
-- Bug 7010864
*/
BEGIN

  IF ( p_slice_type IS NULL ) THEN
/* commenting for bug 7497672
-- Bug 7010864
  open c1;
  loop

	 fetch c1 bulk collect into x_row_id limit 500000;

  If x_row_id.count > 0  then
    -- gather statistics for PJI metadata tables
    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_FP_AGGR_PJP1',
                                 percent => 5,
                                 degree  => PJI_UTILS.GET_DEGREE_OF_PARALLELISM());

    -- gather statistics for PJI metadata tables
    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_FP_XBS_ACCUM_F',
                                 percent => 5,
                                 degree  => PJI_UTILS.GET_DEGREE_OF_PARALLELISM());


Forall i in x_row_id.first..x_row_id.last
*/
    INSERT /*+ append parallel(rl) */ INTO pji_fp_xbs_accum_f rl
    (
       PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_LOGIN
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PLAN_TYPE_CODE
    )
     SELECT
       pjp1.PROJECT_ID
     , pjp1.PROJECT_ORG_ID
     , pjp1.PROJECT_ORGANIZATION_ID
     , pjp1.PROJECT_ELEMENT_ID
     , pjp1.TIME_ID
     , pjp1.PERIOD_TYPE_ID
     , pjp1.CALENDAR_TYPE
     , pjp1.RBS_AGGR_LEVEL
     , pjp1.WBS_ROLLUP_FLAG
     , pjp1.PRG_ROLLUP_FLAG
     , pjp1.CURR_RECORD_TYPE_ID
     , pjp1.CURRENCY_CODE
     , pjp1.RBS_ELEMENT_ID
     , pjp1.RBS_VERSION_ID
     , pjp1.PLAN_VERSION_ID
     , pjp1.PLAN_TYPE_ID
     , l_last_update_date -- sysdate --
     , l_last_updated_by  -- 1 --
     , l_creation_date  -- sysdate --
     , l_created_by  -- 1 --
     , l_last_update_login  -- 1 --
     , pjp1.RAW_COST
     , pjp1.BRDN_COST
     , pjp1.REVENUE
     , pjp1.BILL_RAW_COST
     , pjp1.BILL_BRDN_COST
     , pjp1.BILL_LABOR_RAW_COST
     , pjp1.BILL_LABOR_BRDN_COST
     , pjp1.BILL_LABOR_HRS
     , pjp1.EQUIPMENT_RAW_COST
     , pjp1.EQUIPMENT_BRDN_COST
     , pjp1.CAPITALIZABLE_RAW_COST
     , pjp1.CAPITALIZABLE_BRDN_COST
     , pjp1.LABOR_RAW_COST
     , pjp1.LABOR_BRDN_COST
     , pjp1.LABOR_HRS
     , pjp1.LABOR_REVENUE
     , pjp1.EQUIPMENT_HOURS
     , pjp1.BILLABLE_EQUIPMENT_HOURS
     , pjp1.SUP_INV_COMMITTED_COST
     , pjp1.PO_COMMITTED_COST
     , pjp1.PR_COMMITTED_COST
     , pjp1.OTH_COMMITTED_COST
       , pjp1.ACT_LABOR_HRS
	   , pjp1.ACT_EQUIP_HRS
	   , pjp1.ACT_LABOR_BRDN_COST
	   , pjp1.ACT_EQUIP_BRDN_COST
	   , pjp1.ACT_BRDN_COST
	   , pjp1.ACT_RAW_COST
	   , pjp1.ACT_REVENUE
         , pjp1.ACT_LABOR_RAW_COST
         , pjp1.ACT_EQUIP_RAW_COST
	   , DECODE(SIGN(pjp1.ETC_LABOR_HRS), -1, 0, pjp1.ETC_LABOR_HRS)  ETC_LABOR_HRS
	   , DECODE(SIGN(pjp1.ETC_EQUIP_HRS), -1, 0, pjp1.ETC_EQUIP_HRS)  ETC_EQUIP_HRS
	   , DECODE(SIGN(pjp1.ETC_LABOR_BRDN_COST), -1, 0, pjp1.ETC_LABOR_BRDN_COST)   ETC_LABOR_BRDN_COST
	   , DECODE(SIGN(pjp1.ETC_EQUIP_BRDN_COST), -1, 0, pjp1.ETC_EQUIP_BRDN_COST)   ETC_EQUIP_BRDN_COST
	   , DECODE(SIGN(pjp1.ETC_BRDN_COST), -1, 0, pjp1.ETC_BRDN_COST)   ETC_BRDN_COST
         , DECODE(SIGN(pjp1.ETC_RAW_COST), -1, 0, pjp1.ETC_RAW_COST)    ETC_RAW_COST
         , DECODE(SIGN(pjp1.ETC_LABOR_RAW_COST), -1, 0, pjp1.ETC_LABOR_RAW_COST)  ETC_LABOR_RAW_COST
         , DECODE(SIGN(pjp1.ETC_EQUIP_RAW_COST), -1, 0, pjp1.ETC_EQUIP_RAW_COST)  ETC_EQUIP_RAW_COST
     , pjp1.CUSTOM1
     , pjp1.CUSTOM2
     , pjp1.CUSTOM3
     , pjp1.CUSTOM4
     , pjp1.CUSTOM5
     , pjp1.CUSTOM6
     , pjp1.CUSTOM7
     , pjp1.CUSTOM8
     , pjp1.CUSTOM9
     , pjp1.CUSTOM10
     , pjp1.CUSTOM11
     , pjp1.CUSTOM12
     , pjp1.CUSTOM13
     , pjp1.CUSTOM14
     , pjp1.CUSTOM15
     , pjp1.PLAN_TYPE_CODE
    FROM
         pji_fp_aggr_pjp1 pjp1
    WHERE 1=1
      AND worker_id = g_worker_id
      --AND pjp1.rowid = x_row_id(i)   commented for bug 7497672
    ORDER BY
       pjp1.PROJECT_ID
     , pjp1.PLAN_VERSION_ID
     , pjp1.PROJECT_ELEMENT_ID
     , pjp1.TIME_ID
     , pjp1.RBS_VERSION_ID;
/*commenting for bug 7497672
-- Bug 7010864
 Forall j in x_row_id.first..x_row_id.last
   delete from pji_fp_aggr_pjp1
	  where worker_id = g_worker_id
	    and rowid = x_row_id(j);

	 commit;

	 x_row_id.delete;

     exit when c1%notfound;
	 Else
	   Exit;
	 End if;
	 end loop;

  close c1;
-- Bug 7010864
*/
  ELSIF (p_slice_type = 'PRI') THEN

    MERGE_INTO_FP_FACT;

  ELSIF (p_slice_type = 'SEC') THEN

    DELETE FROM pji_fp_aggr_pjp1
    WHERE line_type = 'OF'
      AND worker_id = g_worker_id;  -- Data in entered calendar should not be rolled up.

    MERGE_INTO_FP_FACT;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'INSERT_INTO_FP_FACT');
    RAISE;
END;


PROCEDURE GET_PRI_SLICE_DATA(
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_commit            IN   VARCHAR2 := 'F') IS
BEGIN

  FORALL I IN p_fp_version_ids.FIRST..p_fp_version_ids.LAST
    INSERT INTO pji_fp_aggr_pjp1
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PRG_LEVEL
     , PLAN_TYPE_CODE
    )
    (
     SELECT
       g_worker_id
     , rl.PROJECT_ID
     , rl.PROJECT_ORG_ID
     , rl.PROJECT_ORGANIZATION_ID
     -- , rl.PARTITION_ID
     , rl.PROJECT_ELEMENT_ID
     , rl.TIME_ID
     , rl.PERIOD_TYPE_ID
     , rl.CALENDAR_TYPE
     , rl.RBS_AGGR_LEVEL
     , rl.WBS_ROLLUP_FLAG
     , rl.PRG_ROLLUP_FLAG
     , rl.CURR_RECORD_TYPE_ID
     , rl.CURRENCY_CODE
     , rl.RBS_ELEMENT_ID
     , rl.RBS_VERSION_ID
     , rl.PLAN_VERSION_ID
     , rl.PLAN_TYPE_ID
     , rl.RAW_COST
     , rl.BRDN_COST
     , rl.REVENUE
     , rl.BILL_RAW_COST
     , rl.BILL_BRDN_COST
     , rl.BILL_LABOR_RAW_COST
     , rl.BILL_LABOR_BRDN_COST
     , rl.BILL_LABOR_HRS
     , rl.EQUIPMENT_RAW_COST
     , rl.EQUIPMENT_BRDN_COST
     , rl.CAPITALIZABLE_RAW_COST
     , rl.CAPITALIZABLE_BRDN_COST
     , rl.LABOR_RAW_COST
     , rl.LABOR_BRDN_COST
     , rl.LABOR_HRS
     , rl.LABOR_REVENUE
     , rl.EQUIPMENT_HOURS
     , rl.BILLABLE_EQUIPMENT_HOURS
     , rl.SUP_INV_COMMITTED_COST
     , rl.PO_COMMITTED_COST
     , rl.PR_COMMITTED_COST
     , rl.OTH_COMMITTED_COST
       , rl.ACT_LABOR_HRS
	   , rl.ACT_EQUIP_HRS
	   , rl.ACT_LABOR_BRDN_COST
	   , rl.ACT_EQUIP_BRDN_COST
	   , rl.ACT_BRDN_COST
	   , rl.ACT_RAW_COST
	   , rl.ACT_REVENUE
         , rl.ACT_LABOR_RAW_COST
         , rl.ACT_EQUIP_RAW_COST
	   , rl.ETC_LABOR_HRS
	   , rl.ETC_EQUIP_HRS
	   , rl.ETC_LABOR_BRDN_COST
	   , rl.ETC_EQUIP_BRDN_COST
	   , rl.ETC_BRDN_COST
         , rl.ETC_RAW_COST
         , rl.ETC_LABOR_RAW_COST
         , rl.ETC_EQUIP_RAW_COST
     , rl.CUSTOM1
     , rl.CUSTOM2
     , rl.CUSTOM3
     , rl.CUSTOM4
     , rl.CUSTOM5
     , rl.CUSTOM6
     , rl.CUSTOM7
     , rl.CUSTOM8
     , rl.CUSTOM9
     , rl.CUSTOM10
     , rl.CUSTOM11
     , rl.CUSTOM12
     , rl.CUSTOM13
     , rl.CUSTOM14
     , rl.CUSTOM15
     , g_default_prg_level
     , rl.PLAN_TYPE_CODE
    FROM
         pji_fp_xbs_accum_f rl
       , pa_budget_versions bv -- @pjdev115 bv
	 , pa_proj_fp_options fpo -- @pjdev115 fpo
    WHERE
         rl.project_id = bv.project_id
     AND bv.version_type IS NOT NULL
     AND bv.fin_plan_type_id IS NOT NULL
     AND fpo.project_id = bv.project_id
     AND bv.fin_plan_type_id = fpo.fin_plan_type_id
     AND bv.budget_version_id = fpo.fin_plan_version_id
     AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'
     AND rl.calendar_type =
                DECODE( bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )
     AND rl.plan_version_id = p_fp_version_ids(i));


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'GET_PRI_SLICE_DATA');
    RAISE;
END;



PROCEDURE POPULATE_PLN_VER_TABLE IS
  l_count NUMBER := 0;
BEGIN

  print_time('........POPULATE_PLN_VER_TABLE : Begin.' );

    INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
	CURRENT_FLAG             ,
	ORIGINAL_FLAG            ,
	CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG
    )
  SELECT DISTINCT
          g_worker_id
        , epl.project_id
	  , epl.plan_version_id
	  , DECODE ( NVL(bv.wp_version_flag, 'N')
	           , 'Y', bv.project_structure_version_id
		     , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id) -- -9999 --
		     )                           wbs_struct_version_id
	  -- , epl.struct_ver_id
	  , fpo.rbs_version_id -- epl.rbs_version_id
--	  , to_char(epl.plan_type_id) -- pln type code
               , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code       /* 4471527  */
	  , epl.plan_type_id
        , DECODE(bv.version_type
                  , 'ALL',     fpo.all_time_phased_code
                  , 'COST',    fpo.cost_time_phased_code
                  , 'REVENUE', fpo.revenue_time_phased_code
                 )                       time_phased_type_code
	  , null -- time dangling..
	  , null -- time dangling..
	  , null -- project type class is not used currently..
        , DECODE(bv.wp_version_flag, 'Y', 'Y', 'N') is_wp_flag
	  , bv.current_flag                  current_flag
	  , bv.original_flag                 original_flag
	  , bv.current_original_flag         current_original_flag
	  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
  FROM PJI_FM_EXTR_PLAN_LINES epl
     , pa_budget_versions bv
     , pa_proj_fp_options fpo
  WHERE
        epl.plan_version_id = bv.budget_version_id
    AND fpo.project_id = bv.project_id
    AND bv.fin_plan_type_id = fpo.fin_plan_type_id
    AND bv.budget_version_id = fpo.fin_plan_version_id
    AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'
    AND epl.rowid IN ( SELECT extr_lines_rowid FROM pji_fp_rmap_fpr_update_t);

  /*
  SELECT COUNT(1)
  INTO   l_count
  FROM   PJI_FM_EXTR_PLNVER4;
  */

  print_time('count is ... ' || SQL%ROWCOUNT );

  print_time('........POPULATE_PLN_VER_TABLE : End.' );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'POPULATE_PLN_VER_TABLE');
    print_time('........POPULATE_PLN_VER_TABLE : Exception: ' || sqlerrm );
    RAISE;
END;


PROCEDURE GET_GLOBAL_EXCHANGE_RATES IS

  l_gl1_cur_code  VARCHAR2(15) := g_global1_currency_code;
  l_gl2_cur_code  VARCHAR2(15) := g_global2_currency_code;
  l_gl1_mau       NUMBER := g_global1_currency_mau;
  l_gl2_mau       NUMBER := g_global2_currency_mau;

BEGIN

  print_time('........GET_GLOBAL_EXCHANGE_RATES: Begin. ' );

    PJI_PJP_FP_CURR_WRAP.get_global_currency_info (
      x_currency_conversion_rule => g_currency_conversion_rule
    , x_prorating_format         => g_prorating_format
    , x_global1_currency_code    => g_global1_currency_code
    , x_global2_currency_code    => g_global2_currency_code
    , x_global1_currency_mau     => g_global1_currency_mau
    , x_global2_currency_mau     => g_global2_currency_mau ) ;

  --
  -- Todo: Remove hardcoded currency codes after making code work if one of the global currencies is null.
  --

  l_gl1_cur_code  := g_global1_currency_code;
  l_gl2_cur_code  := g_global2_currency_code;
  l_gl1_mau       := g_global1_currency_mau;
  l_gl2_mau       := g_global2_currency_mau;

  print_time(' Got global currency settings. ');
  print_time(' g_currency_conversion_rule ' || g_currency_conversion_rule || ' g_prorating_format ' ||  g_prorating_format );
  print_time(' g_global1_currency_code ' || g_global1_currency_code || ' g_global2_currency_code ' || g_global2_currency_code );
  print_time(' g_global1_currency_mau ' || g_global1_currency_mau || ' g_global2_currency_mau ' || g_global2_currency_mau ) ;


      DELETE FROM PJI_FM_AGGR_DLY_RATES
      WHERE worker_id = g_worker_id;

      print_time('........GET_GLOBAL_EXCHANGE_RATES: # rows deleted is: ' || SQL%ROWCOUNT );

PJI_UTILS.g_max_roll_days := 1500;  /*5155692 */
    -- Removed pa_resource_assignments join and Added joins with pji_org_extr_info
    -- for bug 4149422
      -- SQL for getting rates for time phased budgets.
  INSERT INTO PJI_FM_AGGR_DLY_RATES (
                WORKER_ID	,
                PF_CURRENCY_CODE	,
                TIME_ID	,
                RATE	,
                MAU	,
                RATE2	,
                MAU2)
  select worker_id,
         projfunc_currency_code,
         time_id,
         PJI_UTILS.GET_GLOBAL_RATE_PRIMARY (temp.projfunc_currency_code
                      , DECODE ( g_currency_conversion_rule
                               , 'S'
                               , temp.start_date
                               , 'E'
                               , temp.end_date ))
       rate1,
       l_gl1_mau mau1,
       DECODE ( PJI_UTILS.GET_SETUP_PARAMETER('GLOBAL_CURR2_FLAG'),
                'Y',
                PJI_UTILS.GET_GLOBAL_RATE_SECONDARY(
		temp.projfunc_currency_code,
                DECODE ( g_currency_conversion_rule
                       , 'S'
                       , temp.start_date
                       , 'E'
                       , temp.end_date
		       )
	          ) ,
               NULL
              ) rate2,
       l_gl2_mau mau2
   FROM (
          SELECT DISTINCT
                 g_worker_id worker_id
               , ppa.projfunc_currency_code
               , cal_period_id time_id
               , DECODE( g_currency_conversion_rule
	               , 'S'
	               , prd.start_date
		       , TO_DATE(NULL)
		       ) start_date
	       , DECODE( g_currency_conversion_rule
	               , 'E'
		       , prd.end_date
		       , TO_DATE(NULL)
	               ) end_date
          FROM pa_budget_lines  bl
           , pji_time_cal_period_v  prd
           , PJI_FM_EXTR_PLNVER4  ver
           , pa_projects_all ppa
           ,PJI_ORG_EXTR_INFO inf
      WHERE 1=1
            AND bl.budget_version_id = ver.plan_version_id
            AND ver.time_phased_type_code IN ('P', 'G')
            AND bl.period_name = prd.name
            AND ver.wp_flag = 'N'
            AND ver.baselined_flag = 'Y'
            AND ver.project_id = ppa.project_id
            --  Fix for bug : 4149422
            AND ppa.org_id = inf.org_id
            AND DECODE ( ver.time_phased_type_code
	               , 'P'
		       , inf.pa_calendar_id
		       , 'G'
		       , inf.gl_calendar_id
		       ) = prd.calendar_id
            AND ver.worker_id = g_worker_id
          UNION ALL
          SELECT DISTINCT
                   g_worker_id worker_id
                 , ppa.projfunc_currency_code
                 , DECODE ( g_currency_conversion_rule
                          , 'S'
                          , TO_NUMBER(to_CHAR(ra.planning_start_date, 'J'))
                          , 'E'
                          , TO_NUMBER(to_CHAR(ra.planning_end_date, 'J')) ) time_id
		  , DECODE( g_currency_conversion_rule
	                  , 'S'
		          , ra.planning_start_date
		          , TO_DATE(NULL)
			  ) start_date
		  , DECODE( g_currency_conversion_rule
		          , 'E'
		          , ra.planning_end_date
                          , TO_DATE(NULL)
		          ) end_date
          FROM pa_resource_assignments ra
             , PJI_FM_EXTR_PLNVER4  ver
             , pa_projects_all ppa
      WHERE 1=1
            AND ra.budget_version_id = ver.plan_version_id
            AND ver.wp_flag = 'N'
            AND ver.baselined_flag = 'Y'
            AND ver.time_phased_type_code = 'N'
            AND ver.project_id = ppa.project_id
            AND ver.worker_id = g_worker_id
         ) temp;

PJI_UTILS.g_max_roll_days := NULL;  /*5155692 */

	UPDATE /*+ INDEX(prd,pji_time_cal_period_u1) index(rates, PJI_FM_AGGR_DLY_RATES_N1) */
	       PJI_FM_EXTR_PLNVER4 ver
	   SET rate_dangling_flag = 'Y'
	  WHERE (project_id,plan_version_id)  IN
			(    SELECT project_id,budget_version_id
			       FROM PA_BUDGET_LINES bl,
			   	        pji_time_cal_period_v  prd,
					    PJI_FM_AGGR_DLY_RATES rates
			      WHERE rates.time_id=prd.cal_period_id
			        AND bl.period_name = prd.name
				AND (sign(rates.rate)=-1 OR sign(rates.rate2) = -1)
				AND ver.time_phased_type_code IN ('P', 'G')
			        AND rates.worker_id=g_worker_id /* Added for bug 4083581 */
			  UNION ALL
			     SELECT project_id,budget_version_id
			       FROM pa_resource_assignments ra,
					    PJI_FM_AGGR_DLY_RATES rates
			      WHERE rates.time_id= DECODE ( g_currency_conversion_rule
                               		   		  	, 'S'
					 				, TO_NUMBER(to_CHAR(ra.planning_start_date, 'J'))
								 , 'E'
									 , TO_NUMBER(to_CHAR(ra.planning_end_date, 'J')) )
				AND (sign(rates.rate)=-1 OR sign(rates.rate2) = -1)
				AND ver.time_phased_type_code = 'N'
			        AND rates.worker_id=g_worker_id /* Added for bug 4083581 */
			)
            AND ver.wp_flag = 'N'
            AND ver.baselined_flag = 'Y'
            AND ver.worker_id = g_worker_id;

  print_time('........GET_GLOBAL_EXCHANGE_RATES: End. # rows inserted is: ' || SQL%ROWCOUNT );
    commit; -- Added for bug 9108728

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'GET_GLOBAL_EXCHANGE_RATES');
    print_time('........GET_GLOBAL_EXCHANGE_RATES: Exception: ' || sqlerrm );
    RAISE;
END;


PROCEDURE DELETE_GLOBAL_EXCHANGE_RATES IS
BEGIN

  print_time('........DELETE_GLOBAL_EXCHANGE_RATES: Begin. ' );

  DELETE FROM PJI_FM_AGGR_DLY_RATES
  WHERE  worker_id = g_worker_id;

  print_time('........DELETE_GLOBAL_EXCHANGE_RATES: End. # rows is.. ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'DELETE_GLOBAL_EXCHANGE_RATES');
    print_time('........DELETE_GLOBAL_EXCHANGE_RATES: Exception: ' || sqlerrm );
    RAISE;
END;




PROCEDURE CONV_TO_GLOBAL_CURRENCIES
IS BEGIN

  print_time('........CONV_TO_GLOBAL_CURRENCIES: Begin. ' );

  NULL; -- Pull dangling implemented is changed.


  print_time('........CONV_TO_GLOBAL_CURRENCIES: End. ' );

EXCEPTION
  WHEN OTHERS THEN
    print_time('........CONV_TO_GLOBAL_CURRENCIES: Exception ' || sqlerrm );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CONV_TO_GLOBAL_CURRENCIES');
    RAISE;
END;


PROCEDURE DELETE_DNGLRATE_PLNVER_DATA IS
BEGIN

  DELETE FROM pji_fp_aggr_pjp1
  WHERE plan_version_id IN
    (
	  SELECT DISTINCT plan_version_id
	  FROM pji_fp_aggr_pjp1
	  WHERE worker_id = g_worker_id
          AND rate_dangling_flag IS NOT NULL )
   AND worker_id = g_worker_id;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'DELETE_DNGLRATE_PLNVER_DATA');
    RAISE;
END;



PROCEDURE DO_CURRENCY_DANGLING_CHECK
IS BEGIN

  NULL; -- Rate dangling check already done in get global exchange rates.

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'DO_CURRENCY_DANGLING_CHECK');
    RAISE;
END;


PROCEDURE GET_PRORATE_FORMAT
IS BEGIN

  NULL;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'GET_PRORATE_FORMAT');
    RAISE;
END;


PROCEDURE GET_SPREAD_DATE_RANGE_AMOUNTS
IS BEGIN

  NULL;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'GET_SPREAD_DATE_RANGE_AMOUNTS');
    RAISE;
END;


PROCEDURE SPREAD_NON_TIME_PHASE_AMOUNTS
IS BEGIN

  NULL;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'SPREAD_NON_TIME_PHASE_AMOUNTS');
    RAISE;
END;




PROCEDURE PRORATE_TO_OTHER_CALENDAR(
  p_calENDar_type    IN   VARCHAR2 := NULL -- Values can be GL, PA, ENT, ENTW.
) IS
BEGIN

  --
  -- Logic to identify the records that are 'original'/'converted' format
  --   etc is similar to that for PJI. This is to make it easy for dev working
  --   on one module (PJI/PRP) to understand the other with minimum effort.
  --
  -- Logic is as follows:
  -------------------------------------------------------------------------
  -- 1. All 'entered' amounts (from pri slice) will have a line type *tag* 'OF'
  --     if calendar type is PA/GL. If no calendar type is mentioned,
  --     then, it will be 'F1'. Tag == line type column in tmp table.
  -- 2. Non time phased amounts if prorated to ENT cal will be tagged 'OF'.
  --     This has not been decided yet.
  -- 3. Amounts from PA/GL cal entries that have been converted to global will
  --     have a tag 'OG'.
  -- 4. Non PA calendar entries of OF/OG when converted to PA calendar will have
  --     a tag 'CF/CG' respectively.
  -- 5. Non GL calendar entries of OF/OG when converted to GL calendar will have
  --     a tag 'CF/CG' respectively.
  -- 6. Non ENT calendar entries of OF/OG when converted to ENT calendar will have
  --     a tag 'CF/CG' respectively.
  -- 7. Non ENTW calendar entries of OF/OG when converted to ENTW calendar will have
  --     a tag 'CF/CG' respectively.
  --

  IF (p_calENDar_type = 'PA') THEN
    PRORATE_TO_PA;
  ELSIF (p_calENDar_type = 'GL') THEN
    PRORATE_TO_GL;
  ELSIF (p_calENDar_type = 'ENT') THEN
    PRORATE_TO_ENT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_OTHER_CALENDAR');
    RAISE;
END;


PROCEDURE PRORATE_TO_PA IS
BEGIN

  -- Refer to prorating logic in 'PRORATE_TO_OTHER_CALENDAR' proc.
  PRORATE('PA');

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_PA');
    RAISE;
END;


PROCEDURE PRORATE_TO_GL IS
BEGIN

  -- Refer to prorating logic in 'PRORATE_TO_OTHER_CALENDAR' proc.
  PRORATE('GL');

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_GL');
    RAISE;
END;


--
-- Prorate entries in RL fact and pjp1 table in
--  1. GL cal and Non time phased entries into PA cal.
--  2. PA cal and Non time phased entries into GL cal.
--  3. PA, GL cals and Non time phased entries into Ent cal.
--
PROCEDURE PRORATE_TO_ALL_CALENDARS IS
BEGIN

   print_time('PRORATE_TO_ALL_CALENDARS: Begin.. ');

   PRORATE('PA');                    -- Prorate entries in RL fact and pjp1 table
                                                           -- in GL cal and Non time phased entries into PA cal.
   PRORATE('GL');                    -- Prorate entries in RL fact and pjp1 table
                                                           -- in PA cal and Non time phased entries into GL cal.
   PRORATE_TO_ENT;                   -- Prorate entries in PA and GL cals into ENT cal.  /*for bug 3852901 */

   print_time('PRORATE_TO_ALL_CALENDARS: End.. ');

EXCEPTION
  WHEN NO_DATA_FOUND THEN

        /* This issue will come only when PJI_PJP_FP_CURR_WRAP.get_ent_dates_info gives a no_data_found error.
           updating the plan versions as time dangling so that the plan will be marked as dangling. Not updating
           the existing records so that data for the primary calendar is not impacted because of issue in proration to
           other calendars */

        UPDATE PJI_FM_EXTR_PLNVER4
            SET time_dangling_flag='Y'
	  WHERE wp_flag='N'
          AND baselined_flag = 'Y'
          AND worker_id = g_worker_id; -- Not raising any exception as we want the processing to happen properly.
  WHEN OTHERS THEN
    print_time('PRORATE_TO_ALL_CALENDARS: Exception.. ' || sqlerrm);
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_ALL_CALENDARS');
    RAISE;
END;


PROCEDURE PRORATE_TO_ENT IS
    l_calendar_type  VARCHAR2(15) := 'E';
BEGIN

   PJI_PJP_FP_CURR_WRAP.get_global_currency_info (
     x_currency_conversion_rule => g_currency_conversion_rule
   , x_prorating_format         => g_prorating_format
   , x_global1_currency_code    => g_global1_currency_code
   , x_global2_currency_code    => g_global2_currency_code
   , x_global1_currency_mau     => g_global1_currency_mau
   , x_global2_currency_mau     => g_global2_currency_mau ) ;


   PJI_PJP_FP_CURR_WRAP.get_ent_dates_info (
     x_global_start_date      => g_global_start_date
   , x_ent_start_period_id    => g_ent_start_period_id
   , x_ent_start_period_name  => g_ent_start_period_name
   , x_ent_start_date         => g_ent_start_date
   , x_ent_END_date           => g_ent_END_date
   , x_global_start_J         => g_global_start_J
   , x_ent_start_J            => g_ent_start_J
   , x_ent_END_J              => g_ent_END_J
  ) ;

  IF (g_prorating_format = 'D') THEN

    PJI_FM_PLAN_CAL_RLPS.PRORATE_TO_ENT_PG_PJP1_D;
    PJI_FM_PLAN_CAL_RLPS.PRORATE_TO_ENT_N_PJP1_D;

  ELSIF (g_prorating_format IN ( g_end_str, g_start_str ) ) THEN

    PJI_FM_PLAN_CAL_RLPS.PRORATE_TO_ENT_PG_PJP1_SE(g_prorating_format);
    PJI_FM_PLAN_CAL_RLPS.PRORATE_TO_ENT_N_PJP1_SE(g_prorating_format);

  ELSE
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_ENT');
    RAISE;
END;


PROCEDURE PRORATE(
  p_calENDar_type    IN   VARCHAR2 := NULL -- Values can be GL, PA, ENT, ENTW.
) IS
    l_calendar_type        VARCHAR2(15);

BEGIN

  IF (p_calENDar_type NOT IN ('PA', 'GL')) THEN RETURN; END IF;

  IF (p_calENDar_type = 'PA') THEN l_calENDar_type := 'P';
  ELSIF (p_calENDar_type = 'GL') THEN l_calENDar_type := 'G';
  ELSE RETURN;
  END IF;


   PJI_PJP_FP_CURR_WRAP.get_global_currency_info (
     x_currency_conversion_rule => g_currency_conversion_rule
   , x_prorating_format         => g_prorating_format
   , x_global1_currency_code    => g_global1_currency_code
   , x_global2_currency_code    => g_global2_currency_code
   , x_global1_currency_mau     => g_global1_currency_mau
   , x_global2_currency_mau     => g_global2_currency_mau ) ;


   PJI_PJP_FP_CURR_WRAP.get_ent_dates_info (
     x_global_start_date      => g_global_start_date
   , x_ent_start_period_id    => g_ent_start_period_id
   , x_ent_start_period_name  => g_ent_start_period_name
   , x_ent_start_date         => g_ent_start_date
   , x_ent_END_date           => g_ent_END_date
   , x_global_start_J         => g_global_start_J
   , x_ent_start_J            => g_ent_start_J
   , x_ent_END_J              => g_ent_END_J
  ) ;

  print_time ( ' Prorating format is .. ' || g_prorating_format ) ;

  IF (g_prorating_format = 'D') THEN

    PJI_FM_PLAN_CAL_RLPS.PRORATE_TO_PAGL_PGE_PJP1_D( p_calendar_type => l_calendar_type );
    PJI_FM_PLAN_CAL_RLPS.PRORATE_TO_PAGL_N_PJP1_D( p_calendar_type => l_calendar_type );

  ELSIF (g_prorating_format IN ( 'E', 'S' ) ) THEN

    PJI_FM_PLAN_CAL_RLPS.PRORATE_TO_PAGL_PGE_PJP1_SE( p_calendar_type => l_calendar_type ,
                                                      p_prorating_format => g_prorating_format);
    PJI_FM_PLAN_CAL_RLPS.PRORATE_TO_PAGL_N_PJP1_SE( p_calendar_type => l_calendar_type ,
                                                      p_prorating_format => g_prorating_format);

  ELSE
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE');
    RAISE;
END;


PROCEDURE MERGE_INTO_FP_FACT IS
BEGIN

  print_time ( ' MERGE_INTO_FP_FACT 2 ' ) ;
  GET_FP_ROW_IDS;
  print_time ( ' MERGE_INTO_FP_FACT 3 ' ) ;
  UPDATE_FP_ROWS;
  print_time ( ' MERGE_INTO_FP_FACT 4 ' ) ;
  INSERT_FP_ROWS;
  print_time ( ' MERGE_INTO_FP_FACT 5 ' ) ;
  CLEANUP_FP_RMAP_FPR;
  print_time ( ' MERGE_INTO_FP_FACT 6 ' ) ;

EXCEPTION
  WHEN OTHERS THEN
    print_time ( ' MERGE_INTO_FP_FACT 6 ' ) ;
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'MERGE_INTO_FP_FACT');
    RAISE;
END;


PROCEDURE CLEANUP_FP_RMAP_FPR IS
BEGIN

  print_time ( 'CLEANUP_FP_RMAP_FPR begin..');

  DELETE FROM PJI_FP_RMAP_FPR
  WHERE worker_id = g_worker_id;

  print_time ( 'CLEANUP_FP_RMAP_FPR end.' || g_worker_id );

EXCEPTION
  WHEN OTHERS THEN
    print_time ( 'ccc' || sqlerrm );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CLEANUP_FP_RMAP_FPR');
    RAISE;
END;


PROCEDURE GET_FP_ROW_IDS IS
BEGIN

  INSERT INTO PJI_FP_RMAP_FPR
  (
     worker_id
   , rl_rowid
   , tmp_rowid
  )
  SELECT  /*+ ORDERED full(tmp) index(rl,PJI_FP_XBS_ACCUM_F_N1) */
    g_worker_id WORKER_ID
  , rl.ROWID rl_rowid
  , tmp.ROWID TMP_ROWID
  FROM
    pji_fp_aggr_pjp1          tmp
  , pji_fp_xbs_accum_f          rl
  WHERE 1 = 1
--   Removed outer join for bug 5927368
--   AND tmp.WORKER_ID = g_worker_id
--   AND tmp.PROJECT_ID = rl.PROJECT_ID (+)
--   AND tmp.PLAN_VERSION_ID = rl.PLAN_VERSION_ID (+)
--   AND tmp.PLAN_TYPE_ID = rl.PLAN_TYPE_ID (+)
--   AND tmp.PLAN_TYPE_CODE = rl.PLAN_TYPE_CODE(+) /*4471527 */
--   AND tmp.PROJECT_ORG_ID = rl.PROJECT_ORG_ID (+)
--   AND tmp.PROJECT_ORGANIZATION_ID = rl.PROJECT_ORGANIZATION_ID (+)
--   AND tmp.PROJECT_ELEMENT_ID = rl.PROJECT_ELEMENT_ID (+)
--   AND tmp.TIME_ID = rl.TIME_ID (+)
--   AND tmp.PERIOD_TYPE_ID = rl.PERIOD_TYPE_ID (+)
--   AND tmp.CALENDAR_TYPE = rl.CALENDAR_TYPE (+)
--   AND tmp.RBS_AGGR_LEVEL = rl.RBS_AGGR_LEVEL (+)
--   AND tmp.WBS_ROLLUP_FLAG = rl.WBS_ROLLUP_FLAG (+)
--   AND tmp.PRG_ROLLUP_FLAG = rl.PRG_ROLLUP_FLAG (+)
--   AND tmp.CURR_RECORD_TYPE_ID = rl.CURR_RECORD_TYPE_ID (+)
--   AND tmp.CURRENCY_CODE = rl.CURRENCY_CODE (+)
--   AND tmp.RBS_ELEMENT_ID = rl.RBS_ELEMENT_ID (+)
--   AND tmp.RBS_VERSION_ID = rl.RBS_VERSION_ID (+)
--   AND tmp.RATE_DANGLING_FLAG IS NULL
--   AND tmp.TIME_DANGLING_FLAG IS NULL;
   AND tmp.WORKER_ID = g_worker_id
   AND tmp.PROJECT_ID = rl.PROJECT_ID
   AND tmp.PLAN_VERSION_ID = rl.PLAN_VERSION_ID
   AND tmp.PLAN_TYPE_ID = rl.PLAN_TYPE_ID
   AND tmp.PLAN_TYPE_CODE = rl.PLAN_TYPE_CODE
   AND tmp.PROJECT_ORG_ID = rl.PROJECT_ORG_ID
   AND tmp.PROJECT_ORGANIZATION_ID = rl.PROJECT_ORGANIZATION_ID
   AND tmp.PROJECT_ELEMENT_ID = rl.PROJECT_ELEMENT_ID
   AND tmp.TIME_ID = rl.TIME_ID
   AND tmp.PERIOD_TYPE_ID = rl.PERIOD_TYPE_ID
   AND tmp.CALENDAR_TYPE = rl.CALENDAR_TYPE
   AND tmp.RBS_AGGR_LEVEL = rl.RBS_AGGR_LEVEL
   AND tmp.WBS_ROLLUP_FLAG = rl.WBS_ROLLUP_FLAG
   AND tmp.PRG_ROLLUP_FLAG = rl.PRG_ROLLUP_FLAG
   AND tmp.CURR_RECORD_TYPE_ID = rl.CURR_RECORD_TYPE_ID
   AND tmp.CURRENCY_CODE = rl.CURRENCY_CODE
   AND tmp.RBS_ELEMENT_ID = rl.RBS_ELEMENT_ID
   AND tmp.RBS_VERSION_ID = rl.RBS_VERSION_ID
   AND tmp.RATE_DANGLING_FLAG IS NULL
   AND tmp.TIME_DANGLING_FLAG IS NULL;

  print_time ( ' MERGE_INTO_FP_FACT 1.1 ' || SQL%ROWCOUNT ) ;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'GET_FP_ROW_IDS');
    RAISE;
END;



PROCEDURE UPDATE_FP_ROWS IS

  l_last_update_date  DATE   := SYSDATE;
  l_last_updated_by   NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN



    UPDATE /*+ ordered use_nl(rl) rowid(rl) */
      pji_fp_xbs_accum_f rl
    SET (
      rl.RAW_COST
    , rl.BRDN_COST
    , rl.REVENUE
    , rl.BILL_RAW_COST
    , rl.BILL_BRDN_COST
    , rl.BILL_LABOR_RAW_COST
    , rl.BILL_LABOR_BRDN_COST
    , rl.BILL_LABOR_HRS
    , rl.EQUIPMENT_RAW_COST
    , rl.EQUIPMENT_BRDN_COST
    , rl.CAPITALIZABLE_RAW_COST
    , rl.CAPITALIZABLE_BRDN_COST
    , rl.LABOR_RAW_COST
    , rl.LABOR_BRDN_COST
    , rl.LABOR_HRS
    , rl.LABOR_REVENUE
    , rl.EQUIPMENT_HOURS
    , rl.BILLABLE_EQUIPMENT_HOURS
    , rl.SUP_INV_COMMITTED_COST
    , rl.PO_COMMITTED_COST
    , rl.PR_COMMITTED_COST
    , rl.OTH_COMMITTED_COST
       , rl.ACT_LABOR_HRS
	   , rl.ACT_EQUIP_HRS
	   , rl.ACT_LABOR_BRDN_COST
	   , rl.ACT_EQUIP_BRDN_COST
	   , rl.ACT_BRDN_COST
	   , rl.ACT_RAW_COST
	   , rl.ACT_REVENUE
         , rl.ACT_LABOR_RAW_COST
         , rl.ACT_EQUIP_RAW_COST
	   , rl.ETC_LABOR_HRS
	   , rl.ETC_EQUIP_HRS
	   , rl.ETC_LABOR_BRDN_COST
	   , rl.ETC_EQUIP_BRDN_COST
	   , rl.ETC_BRDN_COST
         , rl.ETC_RAW_COST
         , rl.ETC_LABOR_RAW_COST
         , rl.ETC_EQUIP_RAW_COST
    , rl.CUSTOM1
    , rl.CUSTOM2
    , rl.CUSTOM3
    , rl.CUSTOM4
    , rl.CUSTOM5
    , rl.CUSTOM6
    , rl.CUSTOM7
    , rl.CUSTOM8
    , rl.CUSTOM9
    , rl.CUSTOM10
    , rl.CUSTOM11
    , rl.CUSTOM12
    , rl.CUSTOM13
    , rl.CUSTOM14
    , rl.CUSTOM15
    , rl.last_update_date
    , rl.last_updated_by
    , rl.last_update_login
   	) =
    (
      SELECT  /*+  ORDERED ROWID(TMP) index(rwid,PJI_FP_RMAP_FPR_N1) */
         NVL(rl.RAW_COST, 0) + NVL(tmp.RAW_COST, 0)
       , NVL(rl.BRDN_COST, 0) + NVL(tmp.BRDN_COST, 0)
       , NVL(rl.REVENUE, 0) + NVL(tmp.REVENUE, 0)
       , NVL(rl.BILL_RAW_COST, 0) + NVL(tmp.BILL_RAW_COST, 0)
       , NVL(rl.BILL_BRDN_COST, 0) + NVL(tmp.BILL_BRDN_COST, 0)
       , NVL(rl.BILL_LABOR_RAW_COST, 0) + NVL(tmp.BILL_LABOR_RAW_COST, 0)
       , NVL(rl.BILL_LABOR_BRDN_COST, 0) + NVL(tmp.BILL_LABOR_BRDN_COST, 0)
       , NVL(rl.BILL_LABOR_HRS, 0) + NVL(tmp.BILL_LABOR_HRS, 0)
       , NVL(rl.EQUIPMENT_RAW_COST, 0) + NVL(tmp.EQUIPMENT_RAW_COST, 0)
       , NVL(rl.EQUIPMENT_BRDN_COST, 0) + NVL(tmp.EQUIPMENT_BRDN_COST, 0)
       , NVL(rl.CAPITALIZABLE_RAW_COST, 0) + NVL(tmp.CAPITALIZABLE_RAW_COST  , 0)
       , NVL(rl.CAPITALIZABLE_BRDN_COST, 0) + NVL(tmp.CAPITALIZABLE_BRDN_COST    , 0)
       , NVL(rl.LABOR_RAW_COST, 0) + NVL(tmp.LABOR_RAW_COST, 0)
       , NVL(rl.LABOR_BRDN_COST, 0) + NVL(tmp.LABOR_BRDN_COST, 0)
       , NVL(rl.LABOR_HRS, 0) + NVL(tmp.LABOR_HRS, 0)
       , NVL(rl.LABOR_REVENUE, 0) + NVL(tmp.LABOR_REVENUE, 0)
       , NVL(rl.EQUIPMENT_HOURS, 0) + NVL(tmp.EQUIPMENT_HOURS, 0)
       , NVL(rl.BILLABLE_EQUIPMENT_HOURS, 0) + NVL(tmp.BILLABLE_EQUIPMENT_HOURS, 0)
       , NVL(rl.SUP_INV_COMMITTED_COST, 0) + NVL(tmp.SUP_INV_COMMITTED_COST, 0)
       , NVL(rl.PO_COMMITTED_COST, 0) + NVL(tmp.PO_COMMITTED_COST, 0)
       , NVL(rl.PR_COMMITTED_COST, 0) + NVL(tmp.PR_COMMITTED_COST, 0)
       , NVL(rl.OTH_COMMITTED_COST, 0) + NVL(tmp.OTH_COMMITTED_COST, 0)
       , NVL(rl.ACT_LABOR_HRS, 0) + NVL(tmp.ACT_LABOR_HRS, 0)
	   , NVL(rl.ACT_EQUIP_HRS, 0) + NVL(tmp.ACT_EQUIP_HRS, 0)
	   , NVL(rl.ACT_LABOR_BRDN_COST, 0) + NVL(tmp.ACT_LABOR_BRDN_COST, 0)
	   , NVL(rl.ACT_EQUIP_BRDN_COST, 0) + NVL(tmp.ACT_EQUIP_BRDN_COST, 0)
	   , NVL(rl.ACT_BRDN_COST, 0) + NVL(tmp.ACT_BRDN_COST, 0)
	   , NVL(rl.ACT_RAW_COST, 0) + NVL(tmp.ACT_RAW_COST, 0)
	   , NVL(rl.ACT_REVENUE, 0) + NVL(tmp.ACT_REVENUE, 0)
         , NVL(rl.ACT_LABOR_RAW_COST, 0) + NVL(tmp.ACT_LABOR_RAW_COST, 0)
         , NVL(rl.ACT_EQUIP_RAW_COST, 0) + NVL(tmp.ACT_EQUIP_RAW_COST, 0)
	   , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_LABOR_HRS)
	                       , NULL
                             , NVL(rl.ETC_LABOR_HRS, 0) + NVL(tmp.labor_hrs, 0)
			                 , NVL(rl.ETC_LABOR_HRS, 0) + tmp.ETC_LABOR_HRS
										     )
	   , NVL(rl.ETC_LABOR_HRS, 0) + NVL(tmp.ETC_LABOR_HRS, 0)
		      ) ETC_LABOR_HRS
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_EQUIP_HRS)
		                     , NULL
                             , NVL(rl.ETC_EQUIP_HRS, 0) + NVL(tmp.EQUIPMENT_hours, 0)
		 		             , NVL(rl.ETC_EQUIP_HRS, 0) + tmp.ETC_EQUIP_HRS
										     )
	   , NVL(rl.ETC_EQUIP_HRS, 0) + NVL(tmp.ETC_EQUIP_HRS, 0)
			    ) ETC_EQUIP_HRS
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_LABOR_BRDN_COST)
		                 , NULL
                             , NVL(rl.ETC_LABOR_BRDN_COST, 0) + NVL(tmp.labor_BRDN_COST, 0)
                             , NVL(rl.ETC_LABOR_BRDN_COST, 0) + tmp.ETC_LABOR_BRDN_COST
										     )
	   , NVL(rl.ETC_LABOR_BRDN_COST, 0) + NVL(tmp.ETC_LABOR_BRDN_COST, 0)
				  ) ETC_LABOR_BRDN_COST
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_EQUIP_BRDN_COST)
		                 , NULL
                      , NVL(rl.ETC_equip_BRDN_COST, 0) + NVL(tmp.EQUIPment_BRDN_COST, 0)
 		              , NVL(rl.ETC_equip_BRDN_COST, 0) + tmp.ETC_equip_BRDN_COST
										     )
	   , NVL(rl.ETC_EQUIP_BRDN_COST, 0) + NVL(tmp.ETC_EQUIP_BRDN_COST, 0)
				  ) ETC_EQUIP_BRDN_COST
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_BRDN_COST)
		                 , NULL
                             , NVL(rl.ETC_BRDN_COST, 0) + NVL(tmp.BRDN_COST, 0)
                             , NVL(rl.ETC_BRDN_COST, 0) + tmp.ETC_BRDN_COST

										     )
							    , NVL(rl.ETC_BRDN_COST, 0) + NVL(tmp.ETC_BRDN_COST, 0)
				  ) ETC_BRDN_COST
		 , DECODE ( ver3.wp_flag
                     , 'Y'
                     , DECODE(TO_CHAR(tmp.ETC_raw_COST)
		                , NULL
                     , NVL(rl.ETC_raw_COST, 0) + NVL(tmp.raw_COST, 0)
                     , NVL(rl.ETC_raw_COST, 0) + tmp.ETC_raw_COST
										     )
							    , NVL(rl.ETC_raw_COST, 0) + NVL(tmp.ETC_raw_COST, 0)
				  ) ETC_RAW_COST
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_labor_raw_COST)
		                 , NULL
                             , NVL(rl.ETC_labor_raw_COST, 0) + NVL(tmp.labor_raw_COST, 0)
  				             , NVL(rl.ETC_labor_raw_COST, 0) + tmp.ETC_labor_raw_COST
										     )
							    , NVL(rl.ETC_labor_raw_COST, 0) + NVL(tmp.ETC_labor_raw_COST, 0)
				  ) ETC_LABOR_RAW_COST
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_equip_raw_COST)
		                 , NULL
                             , NVL(rl.ETC_equip_raw_COST, 0) + NVL(tmp.equipment_raw_COST, 0)
                             , NVL(rl.ETC_equip_raw_COST, 0) + tmp.ETC_equip_raw_COST
										     )
							    , NVL(rl.ETC_equip_raw_COST, 0) + NVL(tmp.ETC_equip_raw_COST, 0)
			    ) ETC_EQUIP_RAW_COST
       , NVL(rl.CUSTOM1, 0) + NVL(tmp.CUSTOM1, 0)
       , NVL(rl.CUSTOM2, 0) + NVL(tmp.CUSTOM2, 0)
       , NVL(rl.CUSTOM3, 0) + NVL(tmp.CUSTOM3, 0)
       , NVL(rl.CUSTOM4, 0) + NVL(tmp.CUSTOM4, 0)
       , NVL(rl.CUSTOM5, 0) + NVL(tmp.CUSTOM5, 0)
       , NVL(rl.CUSTOM6, 0) + NVL(tmp.CUSTOM6, 0)
       , NVL(rl.CUSTOM7, 0) + NVL(tmp.CUSTOM7, 0)
       , NVL(rl.CUSTOM8, 0) + NVL(tmp.CUSTOM8, 0)
       , NVL(rl.CUSTOM9, 0) + NVL(tmp.CUSTOM9, 0)
       , NVL(rl.CUSTOM10, 0) + NVL(tmp.CUSTOM10, 0)
       , NVL(rl.CUSTOM11, 0) + NVL(tmp.CUSTOM11, 0)
       , NVL(rl.CUSTOM12, 0) + NVL(tmp.CUSTOM12, 0)
       , NVL(rl.CUSTOM13, 0) + NVL(tmp.CUSTOM13, 0)
       , NVL(rl.CUSTOM14, 0) + NVL(tmp.CUSTOM14, 0)
       , NVL(rl.CUSTOM15, 0) + NVL(tmp.CUSTOM15, 0)
       , SYSDATE -- l_last_update_date
       , l_last_updated_by
       , l_last_update_login
     FROM
         PJI_FP_RMAP_FPR           rwid
       , pji_fp_aggr_pjp1          tmp
	 , pji_pjp_wbs_header        ver3  -- replaced ver3 with wbs header for project-to-program association event.
     WHERE  1 = 1
  	  AND tmp.rowid = rwid.tmp_rowid
	  AND rl.rowid = rwid.rl_rowid
--Commented for bug 5927368
--	  AND rwid.rl_rowid IS NOT NULL
	  AND ver3.plan_version_id = tmp.plan_version_id
        AND rwid.worker_id = g_worker_id
        AND tmp.worker_id = g_worker_id
        AND tmp.project_id = ver3.project_id
        AND NVL(tmp.plan_type_id,-1) = NVL(ver3.plan_type_id, -1) -- each plan type can have a different -3, -4 slice.
        AND ver3.plan_type_code = tmp.plan_type_code    /*4471527 */
	)
     WHERE rl.rowid IN
             (
		   SELECT rwid.rl_rowid
		   FROM PJI_FP_RMAP_FPR rwid
--commented for bug 5927368
--		   WHERE rwid.rl_rowid IS NOT NULL
--                 AND rwid.worker_id = g_worker_id
		   WHERE rwid.worker_id = g_worker_id
		   );

  print_time ( ' MERGE_INTO_FP_FACT 2.1 ' || sql%rowcount ) ;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'UPDATE_FP_ROWS');
    RAISE;
END;


PROCEDURE INSERT_FP_ROWS IS

    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN

--Start of addition for bug 5927368
  update /*+ use_nl(pjp1_u) rowid(pjp1_u) */
         PJI_FP_AGGR_PJP1 pjp1_u
  set    RECORD_TYPE = 'U'
  where  ROWID in (select rwid.TMP_ROWID
                   from   PJI_FP_RMAP_FPR rwid
                   where  rwid.WORKER_ID = g_worker_id) and
         nvl(RECORD_TYPE, 'X') <> 'U';
  commit;
--End of addition for bug 5927368

  INSERT INTO pji_fp_xbs_accum_f  fact
  (
       PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_LOGIN
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PLAN_TYPE_CODE   /*4471527 */
  )
 --Commented hint for bug 5927368
  SELECT  /*+ ordered index(ver3 PJI_PJP_WBS_HEADER_N1) */
--  SELECT  / *+ ordered full(rwid) rowid(tmp) * /
       tmp.PROJECT_ID
     , tmp.PROJECT_ORG_ID
     , tmp.PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , tmp.PROJECT_ELEMENT_ID
     , tmp.TIME_ID
     , tmp.PERIOD_TYPE_ID
     , tmp.CALENDAR_TYPE
     , tmp.RBS_AGGR_LEVEL
     , tmp.WBS_ROLLUP_FLAG
     , tmp.PRG_ROLLUP_FLAG
     , tmp.CURR_RECORD_TYPE_ID
     , tmp.CURRENCY_CODE
     , tmp.RBS_ELEMENT_ID
     , tmp.RBS_VERSION_ID
     , ver3.PLAN_VERSION_ID
     , tmp.PLAN_TYPE_ID
     , l_last_update_date
     , l_last_updated_by
     , l_creation_date
     , l_created_by
     , l_last_update_login
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_LABOR_HRS)  -- For Workplan
	                         , NULL
                             , NVL(tmp.labor_hrs, 0)
                             , NVL(tmp.ETC_LABOR_HRS, 0)
                              )
				      , NVL(tmp.ETC_LABOR_HRS, 0)
		       ) ETC_LABOR_HRS
		 , DECODE ( ver3.wp_flag
                          , 'Y'
                          , DECODE(TO_CHAR(tmp.ETC_EQUIP_HRS)
		                         , NULL
                                 , NVL(tmp.EQUIPMENT_hours, 0)
					             , NVL(tmp.ETC_EQUIP_HRS, 0)
					    )
			       , NVL(tmp.ETC_EQUIP_HRS, 0)
			    ) ETC_EQUIP_HRS
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_LABOR_BRDN_COST)
		                     , NULL
                             , NVL(tmp.labor_BRDN_COST, 0)
				             , NVL(tmp.ETC_LABOR_BRDN_COST, 0)
					 )
			         , NVL(tmp.ETC_LABOR_BRDN_COST, 0)
			   ) ETC_LABOR_BRDN_COST
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_EQUIP_BRDN_COST)
		                     , NULL
                             , NVL(tmp.EQUIPment_BRDN_COST, 0)
	                         , NVL(tmp.ETC_equip_BRDN_COST, 0)
				      )
			          , NVL(tmp.ETC_EQUIP_BRDN_COST, 0)
				  ) ETC_equip_BRDN_COST
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_BRDN_COST)
		                     , NULL
                             , NVL(tmp.BRDN_COST, 0)
				             , NVL(tmp.ETC_BRDN_COST, 0)
				      )
			        , NVL(tmp.ETC_BRDN_COST, 0)
				  ) ETC_BRDN_COST
		 , DECODE ( ver3.wp_flag
                     , 'Y'
                     , DECODE(TO_CHAR(tmp.ETC_raw_COST)
		                    , NULL
                            , NVL(tmp.raw_COST, 0)
				            , NVL(tmp.ETC_raw_COST, 0)
				     )
			       , NVL(tmp.ETC_raw_COST, 0)
				  ) ETC_raw_COST
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_labor_raw_COST)
		                     , NULL
                             , NVL(tmp.labor_raw_COST, 0)
				             , NVL(tmp.ETC_labor_raw_COST, 0)
			  	      )
			        , NVL(tmp.ETC_labor_raw_COST, 0)
				  ) ETC_labor_raw_COST
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_equip_raw_COST)
		                     , NULL
                             , NVL(tmp.equipment_raw_COST, 0)
                             ,  NVL(tmp.ETC_equip_raw_COST, 0)
				      )
			        , NVL(tmp.ETC_equip_raw_COST, 0)
			    ) ETC_equip_raw_COST
	 , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     ,tmp.PLAN_TYPE_CODE  PLAN_TYPE_CODE  /*4471527 */
  FROM
--Commented for 5927368
--         PJI_FP_RMAP_FPR  rwid
         pji_fp_aggr_pjp1 tmp
       , pji_pjp_wbs_header ver3  -- replaced ver3 with wbs header for project-to-program association event.
  WHERE 1 = 1
   AND tmp.worker_id = g_worker_id
--commented for 5927368 and added tmp.RECORD_TYPE <> 'U' condition
--   AND rwid.worker_id = g_worker_id
--   AND tmp.rowid = rwid.tmp_rowid
--   AND rwid.rl_rowid IS NULL
   AND nvl(tmp.RECORD_TYPE, 'X') <> 'U'
--
   AND ver3.plan_version_id = tmp.plan_version_id
   AND ver3.plan_type_code = tmp.plan_type_code     /*4471527 */
   AND tmp.project_id = ver3.project_id -- use index.
   AND NVL(tmp.plan_type_id,-1) = NVL(ver3.plan_type_id, -1) -- each plan type can have a different -3, -4 slice.
  ORDER BY
    tmp.PROJECT_ID
  , ver3.PLAN_VERSION_ID
  , tmp.PROJECT_ELEMENT_ID
  , tmp.TIME_ID
  , tmp.RBS_VERSION_ID;

  print_time ( ' MERGE_INTO_FP_FACT 3.1 worker id..' || g_worker_id || 'row count '  || SQL%ROWCOUNT) ;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'INSERT_FP_ROWS');
    RAISE;
END;


PROCEDURE INSERT_INTO_AC_FACT IS
    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
BEGIN

  INSERT INTO PJI_AC_XBS_ACCUM_F
  (
     PROJECT_ID
   , PROJECT_ORG_ID
   , PROJECT_ORGANIZATION_ID
   , PROJECT_ELEMENT_ID
   , TIME_ID
   , PERIOD_TYPE_ID
   , CALENDAR_TYPE
   , WBS_ROLLUP_FLAG
   , PRG_ROLLUP_FLAG
   , CURR_RECORD_TYPE_ID
   , CURRENCY_CODE
   , REVENUE
   , INITIAL_FUNDING_AMOUNT
   , INITIAL_FUNDING_COUNT
   , ADDITIONAL_FUNDING_AMOUNT
   , ADDITIONAL_FUNDING_COUNT
   , CANCELLED_FUNDING_AMOUNT
   , CANCELLED_FUNDING_COUNT
   , FUNDING_ADJUSTMENT_AMOUNT
   , FUNDING_ADJUSTMENT_COUNT
   , REVENUE_WRITEOFF
   , AR_INVOICE_AMOUNT
   , AR_INVOICE_COUNT
   , AR_CASH_APPLIED_AMOUNT
   , AR_INVOICE_WRITE_OFF_AMOUNT
   , AR_INVOICE_WRITEOFF_COUNT
   , AR_CREDIT_MEMO_AMOUNT
   , AR_CREDIT_MEMO_COUNT
   , UNBILLED_RECEIVABLES
   , UNEARNED_REVENUE
   , AR_UNAPPR_INVOICE_AMOUNT
   , AR_UNAPPR_INVOICE_COUNT
   , AR_APPR_INVOICE_AMOUNT
   , AR_APPR_INVOICE_COUNT
   , AR_AMOUNT_DUE
   , AR_COUNT_DUE
   , AR_AMOUNT_OVERDUE
   , AR_COUNT_OVERDUE
   , DORMANT_BACKLOG_INACTIV
   , DORMANT_BACKLOG_START
   , LOST_BACKLOG
   , ACTIVE_BACKLOG
   , REVENUE_AT_RISK
   , LAST_UPDATE_DATE
   , LAST_UPDATED_BY
   , CREATION_DATE
   , CREATED_BY
   , LAST_UPDATE_LOGIN
   , CUSTOM1
   , CUSTOM2
   , CUSTOM3
   , CUSTOM4
   , CUSTOM5
   , CUSTOM6
   , CUSTOM7
   , CUSTOM8
   , CUSTOM9
   , CUSTOM10
   , CUSTOM11
   , CUSTOM12
   , CUSTOM13
   , CUSTOM14
   , CUSTOM15
  )
  SELECT
     PROJECT_ID
   , PROJECT_ORG_ID
   , PROJECT_ORGANIZATION_ID
   , PROJECT_ELEMENT_ID
   , TIME_ID
   , PERIOD_TYPE_ID
   , CALENDAR_TYPE
   , WBS_ROLLUP_FLAG
   , PRG_ROLLUP_FLAG
   , CURR_RECORD_TYPE_ID
   , CURRENCY_CODE
   , REVENUE
   , INITIAL_FUNDING_AMOUNT
   , INITIAL_FUNDING_COUNT
   , ADDITIONAL_FUNDING_AMOUNT
   , ADDITIONAL_FUNDING_COUNT
   , CANCELLED_FUNDING_AMOUNT
   , CANCELLED_FUNDING_COUNT
   , FUNDING_ADJUSTMENT_AMOUNT
   , FUNDING_ADJUSTMENT_COUNT
   , REVENUE_WRITEOFF
   , AR_INVOICE_AMOUNT
   , AR_INVOICE_COUNT
   , AR_CASH_APPLIED_AMOUNT
   , AR_INVOICE_WRITE_OFF_AMOUNT
   , AR_INVOICE_WRITEOFF_COUNT
   , AR_CREDIT_MEMO_AMOUNT
   , AR_CREDIT_MEMO_COUNT
   , UNBILLED_RECEIVABLES
   , UNEARNED_REVENUE
   , AR_UNAPPR_INVOICE_AMOUNT
   , AR_UNAPPR_INVOICE_COUNT
   , AR_APPR_INVOICE_AMOUNT
   , AR_APPR_INVOICE_COUNT
   , AR_AMOUNT_DUE
   , AR_COUNT_DUE
   , AR_AMOUNT_OVERDUE
   , AR_COUNT_OVERDUE
   , DORMANT_BACKLOG_INACTIV
   , DORMANT_BACKLOG_START
   , LOST_BACKLOG
   , ACTIVE_BACKLOG
   , REVENUE_AT_RISK
   , l_last_update_date
   , l_last_updated_by
   , l_creation_date
   , l_created_by
   , l_last_update_login
   , CUSTOM1
   , CUSTOM2
   , CUSTOM3
   , CUSTOM4
   , CUSTOM5
   , CUSTOM6
   , CUSTOM7
   , CUSTOM8
   , CUSTOM9
   , CUSTOM10
   , CUSTOM11
   , CUSTOM12
   , CUSTOM13
   , CUSTOM14
   , CUSTOM15
  FROM PJI_AC_AGGR_PJP1
  WHERE worker_id = g_worker_id
  ORDER BY
     PROJECT_ID
   , PROJECT_ELEMENT_ID
   , TIME_ID
   , CURRENCY_CODE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'INSERT_INTO_AC_FACT');
    RAISE;
END;


PROCEDURE MERGE_INTO_AC_FACT IS
BEGIN

  GET_AC_ROW_IDS;

  UPDATE_AC_ROWS;

  INSERT_AC_ROWS;

  CLEANUP_AC_RMAP_FPR;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'MERGE_INTO_AC_FACT');
    RAISE;
END;


PROCEDURE CLEANUP_AC_RMAP_FPR IS
BEGIN

  DELETE FROM PJI_AC_RMAP_ACR
  WHERE worker_id = g_worker_id;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CLEANUP_AC_RMAP_FPR');
    RAISE;
END;


PROCEDURE GET_AC_ROW_IDS IS
BEGIN

  INSERT INTO PJI_AC_RMAP_ACR /*Not decided to keep this hint yet. + APPEND PARALLEL */
  (
     worker_id
   , rl_rowid
   , tmp_rowid
  )
  SELECT
    g_worker_id WORKER_ID
  , rl.ROWID pjp1_rowid
  , tmp.ROWID TMP1_ROWID
  FROM
    pji_ac_aggr_pjp1            tmp
  , PJI_AC_XBS_ACCUM_F          rl
  WHERE 1 = 1
   AND tmp.worker_id = g_worker_id
   AND tmp.PROJECT_ID = rl.PROJECT_ID (+)
   AND tmp.PROJECT_ORG_ID = rl.PROJECT_ORG_ID (+)
   AND tmp.PROJECT_ORGANIZATION_ID = rl.PROJECT_ORGANIZATION_ID (+)
   AND tmp.PROJECT_ELEMENT_ID = rl.PROJECT_ELEMENT_ID (+)
   AND tmp.TIME_ID = rl.TIME_ID (+)
   AND tmp.PERIOD_TYPE_ID = rl.PERIOD_TYPE_ID (+)
   AND tmp.CALENDAR_TYPE = rl.CALENDAR_TYPE (+)
   AND tmp.WBS_ROLLUP_FLAG = rl.WBS_ROLLUP_FLAG (+)
   AND tmp.PRG_ROLLUP_FLAG = rl.PRG_ROLLUP_FLAG (+)
   AND tmp.CURR_RECORD_TYPE_ID = rl.CURR_RECORD_TYPE_ID (+)
   AND tmp.CURRENCY_CODE = rl.CURRENCY_CODE (+) ;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'GET_AC_ROW_IDS');
    RAISE;
END;


PROCEDURE UPDATE_AC_ROWS IS

  l_last_update_date  DATE   := SYSDATE;
  l_last_updated_by   NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN

    UPDATE /*+ ordered use_nl(rl) rowid(rl) */
      PJI_AC_XBS_ACCUM_F rl
    SET (
      rl.REVENUE
    , rl.INITIAL_FUNDING_AMOUNT
    , rl.INITIAL_FUNDING_COUNT
    , rl.ADDITIONAL_FUNDING_AMOUNT
    , rl.ADDITIONAL_FUNDING_COUNT
    , rl.CANCELLED_FUNDING_AMOUNT
    , rl.CANCELLED_FUNDING_COUNT
    , rl.FUNDING_ADJUSTMENT_AMOUNT
    , rl.FUNDING_ADJUSTMENT_COUNT
    , rl.REVENUE_WRITEOFF
    , rl.AR_INVOICE_AMOUNT
    , rl.AR_INVOICE_COUNT
    , rl.AR_CASH_APPLIED_AMOUNT
    , rl.AR_INVOICE_WRITE_OFF_AMOUNT
    , rl.AR_INVOICE_WRITEOFF_COUNT
    , rl.AR_CREDIT_MEMO_AMOUNT
    , rl.AR_CREDIT_MEMO_COUNT
    , rl.UNBILLED_RECEIVABLES
    , rl.UNEARNED_REVENUE
    , rl.AR_UNAPPR_INVOICE_AMOUNT
    , rl.AR_UNAPPR_INVOICE_COUNT
    , rl.AR_APPR_INVOICE_AMOUNT
    , rl.AR_APPR_INVOICE_COUNT
    , rl.AR_AMOUNT_DUE
    , rl.AR_COUNT_DUE
    , rl.AR_AMOUNT_OVERDUE
    , rl.AR_COUNT_OVERDUE
    , rl.DORMANT_BACKLOG_INACTIV
    , rl.DORMANT_BACKLOG_START
    , rl.LOST_BACKLOG
    , rl.ACTIVE_BACKLOG
    , rl.REVENUE_AT_RISK
    , rl.CUSTOM1
    , rl.CUSTOM2
    , rl.CUSTOM3
    , rl.CUSTOM4
    , rl.CUSTOM5
    , rl.CUSTOM6
    , rl.CUSTOM7
    , rl.CUSTOM8
    , rl.CUSTOM9
    , rl.CUSTOM10
    , rl.CUSTOM11
    , rl.CUSTOM12
    , rl.CUSTOM13
    , rl.CUSTOM14
    , rl.CUSTOM15
    , rl.LAST_UPDATE_DATE
    , rl.LAST_UPDATED_BY
    , rl.LAST_UPDATE_LOGIN
	) =
    (
      SELECT  /*+  ORDERED ROWID(TMP) index(rwid,PJI_AC_RMAP_ACR_N1) */
         NVL(rl.REVENUE, 0) + NVL(tmp.REVENUE, 0)
       , NVL(rl.INITIAL_FUNDING_AMOUNT, 0) + NVL(tmp.INITIAL_FUNDING_AMOUNT, 0)
       , NVL(rl.INITIAL_FUNDING_COUNT, 0) + NVL(tmp.INITIAL_FUNDING_COUNT, 0)
       , NVL(rl.ADDITIONAL_FUNDING_AMOUNT, 0) + NVL(tmp.ADDITIONAL_FUNDING_AMOUNT, 0)
       , NVL(rl.ADDITIONAL_FUNDING_COUNT, 0) + NVL(tmp.ADDITIONAL_FUNDING_COUNT, 0)
       , NVL(rl.CANCELLED_FUNDING_AMOUNT, 0) + NVL(tmp.CANCELLED_FUNDING_AMOUNT, 0)
       , NVL(rl.CANCELLED_FUNDING_COUNT, 0) + NVL(tmp.CANCELLED_FUNDING_COUNT, 0)
       , NVL(rl.FUNDING_ADJUSTMENT_AMOUNT, 0) + NVL(tmp.FUNDING_ADJUSTMENT_AMOUNT, 0)
       , NVL(rl.FUNDING_ADJUSTMENT_COUNT, 0) + NVL(tmp.FUNDING_ADJUSTMENT_COUNT, 0)
       , NVL(rl.REVENUE_WRITEOFF, 0) + NVL(tmp.REVENUE_WRITEOFF, 0)
       , NVL(rl.AR_INVOICE_AMOUNT, 0) + NVL(tmp.AR_INVOICE_AMOUNT, 0)
       , NVL(rl.AR_INVOICE_COUNT, 0) + NVL(tmp.AR_INVOICE_COUNT, 0)
       , NVL(rl.AR_CASH_APPLIED_AMOUNT, 0) + NVL(tmp.AR_CASH_APPLIED_AMOUNT, 0)
       , NVL(rl.AR_INVOICE_WRITE_OFF_AMOUNT, 0) + NVL(tmp.AR_INVOICE_WRITE_OFF_AMOUNT, 0)
       , NVL(rl.AR_INVOICE_WRITEOFF_COUNT, 0) + NVL(tmp.AR_INVOICE_WRITEOFF_COUNT, 0)
       , NVL(rl.AR_CREDIT_MEMO_AMOUNT, 0) + NVL(tmp.AR_CREDIT_MEMO_AMOUNT, 0)
       , NVL(rl.AR_CREDIT_MEMO_COUNT, 0) + NVL(tmp.AR_CREDIT_MEMO_COUNT, 0)
       , NVL(rl.UNBILLED_RECEIVABLES, 0) + NVL(tmp.UNBILLED_RECEIVABLES, 0)
       , NVL(rl.UNEARNED_REVENUE, 0) + NVL(tmp.UNEARNED_REVENUE, 0)
       , NVL(rl.AR_UNAPPR_INVOICE_AMOUNT, 0) + NVL(tmp.AR_UNAPPR_INVOICE_AMOUNT, 0)
       , NVL(rl.AR_UNAPPR_INVOICE_COUNT, 0) + NVL(tmp.AR_UNAPPR_INVOICE_COUNT, 0)
       , NVL(rl.AR_APPR_INVOICE_AMOUNT, 0) + NVL(tmp.AR_APPR_INVOICE_AMOUNT, 0)
       , NVL(rl.AR_APPR_INVOICE_COUNT, 0) + NVL(tmp.AR_APPR_INVOICE_COUNT, 0)
       , NVL(rl.AR_AMOUNT_DUE, 0) + NVL(tmp.AR_AMOUNT_DUE, 0)
       , NVL(rl.AR_COUNT_DUE, 0) + NVL(tmp.AR_COUNT_DUE, 0)
       , NVL(rl.AR_AMOUNT_OVERDUE, 0) + NVL(tmp.AR_AMOUNT_OVERDUE, 0)
       , NVL(rl.AR_COUNT_OVERDUE, 0) + NVL(tmp.AR_COUNT_OVERDUE, 0)
       , NVL(rl.DORMANT_BACKLOG_INACTIV, 0) + NVL(tmp.DORMANT_BACKLOG_INACTIV, 0)
       , NVL(rl.DORMANT_BACKLOG_START, 0) + NVL(tmp.DORMANT_BACKLOG_START, 0)
       , NVL(rl.LOST_BACKLOG, 0) + NVL(tmp.LOST_BACKLOG, 0)
       , NVL(rl.ACTIVE_BACKLOG, 0) + NVL(tmp.ACTIVE_BACKLOG, 0)
       , NVL(rl.REVENUE_AT_RISK, 0) + NVL(tmp.REVENUE_AT_RISK, 0)
       , NVL(rl.CUSTOM1, 0) + NVL(tmp.CUSTOM1, 0)
       , NVL(rl.CUSTOM2, 0) + NVL(tmp.CUSTOM2, 0)
       , NVL(rl.CUSTOM3, 0) + NVL(tmp.CUSTOM3, 0)
       , NVL(rl.CUSTOM4, 0) + NVL(tmp.CUSTOM4, 0)
       , NVL(rl.CUSTOM5, 0) + NVL(tmp.CUSTOM5, 0)
       , NVL(rl.CUSTOM6, 0) + NVL(tmp.CUSTOM6, 0)
       , NVL(rl.CUSTOM7, 0) + NVL(tmp.CUSTOM7, 0)
       , NVL(rl.CUSTOM8, 0) + NVL(tmp.CUSTOM8, 0)
       , NVL(rl.CUSTOM9, 0) + NVL(tmp.CUSTOM9, 0)
       , NVL(rl.CUSTOM10, 0) + NVL(tmp.CUSTOM10, 0)
       , NVL(rl.CUSTOM11, 0) + NVL(tmp.CUSTOM11, 0)
       , NVL(rl.CUSTOM12, 0) + NVL(tmp.CUSTOM12, 0)
       , NVL(rl.CUSTOM13, 0) + NVL(tmp.CUSTOM13, 0)
       , NVL(rl.CUSTOM14, 0) + NVL(tmp.CUSTOM14, 0)
       , NVL(rl.CUSTOM15, 0) + NVL(tmp.CUSTOM15, 0)
       , l_last_update_date
       , l_last_updated_by
       , l_last_update_login
     FROM
       PJI_AC_RMAP_ACR rwid
     , pji_ac_aggr_pjp1 tmp
     WHERE  1 = 1
        AND tmp.worker_id = g_worker_id
        AND rwid.worker_id = g_worker_id
  	  AND tmp.rowid = rwid.tmp_rowid
	  AND rl.rowid = rwid.rl_rowid
	  AND rwid.rl_rowid IS NOT NULL
	)
     WHERE rl.rowid IN
             ( SELECT rl_rowid
		   FROM PJI_AC_RMAP_ACR rwid
		     WHERE 1=1
                   AND rwid.rl_rowid IS NOT NULL
                   AND rwid.worker_id = g_worker_id);

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'UPDATE_AC_ROWS');
    RAISE;
END;


PROCEDURE INSERT_AC_ROWS IS
    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
BEGIN

  INSERT INTO PJI_AC_XBS_ACCUM_F
  (
     PROJECT_ID
   , PROJECT_ORG_ID
   , PROJECT_ORGANIZATION_ID
   , PROJECT_ELEMENT_ID
   , TIME_ID
   , PERIOD_TYPE_ID
   , CALENDAR_TYPE
   , WBS_ROLLUP_FLAG
   , PRG_ROLLUP_FLAG
   , CURR_RECORD_TYPE_ID
   , CURRENCY_CODE
   , REVENUE
   , INITIAL_FUNDING_AMOUNT
   , INITIAL_FUNDING_COUNT
   , ADDITIONAL_FUNDING_AMOUNT
   , ADDITIONAL_FUNDING_COUNT
   , CANCELLED_FUNDING_AMOUNT
   , CANCELLED_FUNDING_COUNT
   , FUNDING_ADJUSTMENT_AMOUNT
   , FUNDING_ADJUSTMENT_COUNT
   , REVENUE_WRITEOFF
   , AR_INVOICE_AMOUNT
   , AR_INVOICE_COUNT
   , AR_CASH_APPLIED_AMOUNT
   , AR_INVOICE_WRITE_OFF_AMOUNT
   , AR_INVOICE_WRITEOFF_COUNT
   , AR_CREDIT_MEMO_AMOUNT
   , AR_CREDIT_MEMO_COUNT
   , UNBILLED_RECEIVABLES
   , UNEARNED_REVENUE
   , AR_UNAPPR_INVOICE_AMOUNT
   , AR_UNAPPR_INVOICE_COUNT
   , AR_APPR_INVOICE_AMOUNT
   , AR_APPR_INVOICE_COUNT
   , AR_AMOUNT_DUE
   , AR_COUNT_DUE
   , AR_AMOUNT_OVERDUE
   , AR_COUNT_OVERDUE
   , DORMANT_BACKLOG_INACTIV
   , DORMANT_BACKLOG_START
   , LOST_BACKLOG
   , ACTIVE_BACKLOG
   , REVENUE_AT_RISK
   , LAST_UPDATE_DATE
   , LAST_UPDATED_BY
   , CREATION_DATE
   , CREATED_BY
   , LAST_UPDATE_LOGIN
   , CUSTOM1
   , CUSTOM2
   , CUSTOM3
   , CUSTOM4
   , CUSTOM5
   , CUSTOM6
   , CUSTOM7
   , CUSTOM8
   , CUSTOM9
   , CUSTOM10
   , CUSTOM11
   , CUSTOM12
   , CUSTOM13
   , CUSTOM14
   , CUSTOM15
  )
  SELECT
     PROJECT_ID
   , PROJECT_ORG_ID
   , PROJECT_ORGANIZATION_ID
   , PROJECT_ELEMENT_ID
   , TIME_ID
   , PERIOD_TYPE_ID
   , CALENDAR_TYPE
   , WBS_ROLLUP_FLAG
   , PRG_ROLLUP_FLAG
   , CURR_RECORD_TYPE_ID
   , CURRENCY_CODE
   , REVENUE
   , INITIAL_FUNDING_AMOUNT
   , INITIAL_FUNDING_COUNT
   , ADDITIONAL_FUNDING_AMOUNT
   , ADDITIONAL_FUNDING_COUNT
   , CANCELLED_FUNDING_AMOUNT
   , CANCELLED_FUNDING_COUNT
   , FUNDING_ADJUSTMENT_AMOUNT
   , FUNDING_ADJUSTMENT_COUNT
   , REVENUE_WRITEOFF
   , AR_INVOICE_AMOUNT
   , AR_INVOICE_COUNT
   , AR_CASH_APPLIED_AMOUNT
   , AR_INVOICE_WRITE_OFF_AMOUNT
   , AR_INVOICE_WRITEOFF_COUNT
   , AR_CREDIT_MEMO_AMOUNT
   , AR_CREDIT_MEMO_COUNT
   , UNBILLED_RECEIVABLES
   , UNEARNED_REVENUE
   , AR_UNAPPR_INVOICE_AMOUNT
   , AR_UNAPPR_INVOICE_COUNT
   , AR_APPR_INVOICE_AMOUNT
   , AR_APPR_INVOICE_COUNT
   , AR_AMOUNT_DUE
   , AR_COUNT_DUE
   , AR_AMOUNT_OVERDUE
   , AR_COUNT_OVERDUE
   , DORMANT_BACKLOG_INACTIV
   , DORMANT_BACKLOG_START
   , LOST_BACKLOG
   , ACTIVE_BACKLOG
   , REVENUE_AT_RISK
   , l_last_update_date
   , l_last_updated_by
   , l_creation_date
   , l_created_by
   , l_last_update_login
   , CUSTOM1
   , CUSTOM2
   , CUSTOM3
   , CUSTOM4
   , CUSTOM5
   , CUSTOM6
   , CUSTOM7
   , CUSTOM8
   , CUSTOM9
   , CUSTOM10
   , CUSTOM11
   , CUSTOM12
   , CUSTOM13
   , CUSTOM14
   , CUSTOM15
  FROM pji_ac_aggr_pjp1 tmp
     , PJI_AC_RMAP_ACR rwid
  WHERE 1 = 1
   AND tmp.worker_id = g_worker_id
   AND rwid.worker_id = g_worker_id
   AND tmp.rowid = rwid.tmp_rowid
   AND rwid.rl_rowid IS NULL
  ORDER BY
     PROJECT_ID
   , PROJECT_ELEMENT_ID
   , TIME_ID
   , CURRENCY_CODE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'INSERT_AC_ROWS');
    RAISE;
END;

PROCEDURE MARK_DANGLING_PLAN_VERSIONS IS
BEGIN

  UPDATE pa_budget_versions bv
  SET    pji_summarized_flag = 'P',
         record_version_number = nvl(record_version_number,0)+1
  WHERE  budget_version_id IN (
	      SELECT plan_version_id
		FROM
   	      (
		  SELECT plan_version_id
                   , (   COUNT(DISTINCT time_dangling_flag)
                       + COUNT(DISTINCT rate_dangling_flag)
                     ) dangling
              FROM   pji_fp_aggr_pjp1
              WHERE worker_id = g_worker_id
      	  GROUP BY plan_version_id
		) b
		WHERE dangling > 2
   	   );

  UPDATE pa_budget_versions bv
  SET    pji_summarized_flag = 'Y',
         record_version_number = nvl(record_version_number,0)+1
  WHERE  budget_version_id IN (
	      SELECT plan_version_id
		FROM
   	      (
		  SELECT plan_version_id
                   , (   COUNT(DISTINCT time_dangling_flag)
                       + COUNT(DISTINCT rate_dangling_flag)
                     ) dangling
              FROM   pji_fp_aggr_pjp1
              WHERE worker_id = g_worker_id
      	  GROUP BY plan_version_id
		) b
		WHERE dangling = 2
   	   );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'MARK_DANGLING_PLAN_VERSIONS');
    RAISE;
END;


--
-- 0. Plans cannot have time / rate dangling records for primary slice.
-- 1. Work plans have primary slice only.
-- 2. Financial plans can have secondary slices only if the plan is baselined.
-- 3. Only baselined financial plans can have time/rate dangling records.
-- 4. Four states of pji_summarized_flag are N, Y, P, NULL.
--      N - Not summarized..
--      P - Have rate/time dangling records..
--      Y - Project performance summaries fully created.
--      NULL - PJI summaries fully created.
--
-- This api processes plans with pji_summarized_flag = N, i.e., secondary slice
--  for dangling baselined financial plans.
--
PROCEDURE PULL_DANGLING_PLANS IS

  l_fp_wp_version_ids   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_fp_version_ids      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

BEGIN

  NULL; -- Pull dangling calls bulk "create secondary private" directly.

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PULL_DANGLING_PLANS');
    RAISE;
END;


PROCEDURE RETRIEVE_ENTERED_SLICE (
  p_pln_ver_id IN NUMBER := NULL ) IS
BEGIN

    INSERT INTO pji_fp_aggr_pjp1
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PRG_LEVEL
     ,PLAN_TYPE_CODE   /*4471527 */
    )
    (
     SELECT
       g_worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , g_default_prg_level
     ,PLAN_TYPE_CODE
     FROM pji_fp_xbs_accum_f
     WHERE plan_version_id = p_pln_ver_id
    );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'RETRIEVE_ENTERED_SLICE');
    RAISE;
END;




PROCEDURE ROLLUP_FPR_RBS IS
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
    -- l_worker_id            NUMBER := 1;

BEGIN

     INSERT INTO  pji_fp_aggr_pjp1
     (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , PRG_LEVEL
     , PLAN_TYPE_CODE   /*4471527 */
    )
     SELECT
        g_worker_id WORKER_ID
      , fact1.PROJECT_ID
	, fact1.PROJECT_ORG_ID
	, fact1.PROJECT_ORGANIZATION_ID
      , fact1.project_element_id
	, fact1.TIME_ID
      , fact1.PERIOD_TYPE_ID
      , fact1.CALENDAR_TYPE
	, 'R'
	, fact1.WBS_ROLLUP_FLAG
	, fact1.PRG_ROLLUP_FLAG
      , fact1.CURR_RECORD_TYPE_ID
      , fact1.CURRENCY_CODE
      , rbs.sup_id
      , fact1.RBS_VERSION_ID
      , fact1.PLAN_VERSION_ID
	, fact1.PLAN_TYPE_ID
      , SUM(fact1.RAW_COST)
      , SUM(fact1.BRDN_COST)
      , SUM(fact1.REVENUE)
      , SUM(fact1.BILL_RAW_COST)
      , SUM(fact1.BILL_BRDN_COST )
      , SUM(fact1.BILL_LABOR_RAW_COST)
      , SUM(fact1.BILL_LABOR_BRDN_COST )
      , SUM(fact1.BILL_LABOR_HRS )
      , SUM(fact1.EQUIPMENT_RAW_COST )
      , SUM(fact1.EQUIPMENT_BRDN_COST )
      , SUM(fact1.CAPITALIZABLE_RAW_COST )
      , SUM(fact1.CAPITALIZABLE_BRDN_COST )
      , SUM(fact1.LABOR_RAW_COST )
      , SUM(fact1.LABOR_BRDN_COST )
      , SUM(fact1.LABOR_HRS)
      , SUM(fact1.LABOR_REVENUE)
      , SUM(fact1.EQUIPMENT_HOURS)
      , SUM(fact1.BILLABLE_EQUIPMENT_HOURS)
      , SUM(fact1.SUP_INV_COMMITTED_COST)
      , SUM(fact1.PO_COMMITTED_COST   )
      , SUM(fact1.PR_COMMITTED_COST  )
      , SUM(fact1.OTH_COMMITTED_COST)
       , SUM(fact1.ACT_LABOR_HRS)
	 , SUM(fact1.ACT_EQUIP_HRS)
	 , SUM(fact1.ACT_LABOR_BRDN_COST)
	 , SUM(fact1.ACT_EQUIP_BRDN_COST)
	 , SUM(fact1.ACT_BRDN_COST)
	 , SUM(fact1.ACT_RAW_COST)
	 , SUM(fact1.ACT_REVENUE)
       , SUM(fact1.ACT_LABOR_RAW_COST)
       , SUM(fact1.ACT_EQUIP_RAW_COST)
	 , SUM(fact1.ETC_LABOR_HRS)
	 , SUM(fact1.ETC_EQUIP_HRS)
	 , SUM(fact1.ETC_LABOR_BRDN_COST)
	 , SUM(fact1.ETC_EQUIP_BRDN_COST)
	 , SUM(fact1.ETC_BRDN_COST )
       , SUM(fact1.ETC_RAW_COST )
       , SUM(fact1.ETC_LABOR_RAW_COST)
       , SUM(fact1.ETC_EQUIP_RAW_COST)
      , SUM(fact1.CUSTOM1 )
      , SUM(fact1.CUSTOM2 )
      , SUM(fact1.CUSTOM3 )
      , SUM(fact1.CUSTOM4 )
      , SUM(fact1.CUSTOM5 )
      , SUM(fact1.CUSTOM6 )
      , SUM(fact1.CUSTOM7 )
      , SUM(fact1.CUSTOM8 )
      , SUM(fact1.CUSTOM9 )
      , SUM(fact1.CUSTOM10 )
      , SUM(fact1.CUSTOM11 )
      , SUM(fact1.CUSTOM12 )
      , SUM(fact1.CUSTOM13 )
      , SUM(fact1.CUSTOM14 )
      , SUM(fact1.CUSTOM15 )
      , fact1.line_type
      , g_default_prg_level
      ,fact1.PLAN_TYPE_CODE   /*4471527 */
    FROM pji_fp_aggr_pjp1       fact1
       , Pji_RBS_DENORM         rbs
	 , pji_rollup_level_status smart
	 , pji_pjp_rbs_header      rhdr
    WHERE 1 = 1
     AND fact1.project_id  = rhdr.project_id
     AND fact1.plan_version_id  = rhdr.plan_version_id
    AND fact1.plan_type_code = rhdr.plan_type_code  /*4471527 */
     AND rbs.struct_version_id = rhdr.rbs_version_id
     AND fact1.rbs_ELEMENT_ID = rbs.sub_id
     AND rbs.sup_level <> rbs.sub_level
     AND rbs.sup_level <> 1
     AND fact1.RBS_AGGR_LEVEL = 'L'
     AND smart.rbs_version_id = rbs.struct_version_id
     AND smart.plan_version_id = fact1.plan_version_id
     AND smart.plan_type_code = fact1.plan_type_code  /*4471527 */
     AND fact1.worker_id = g_worker_id
    GROUP BY
        fact1.PROJECT_ID
	, fact1.PROJECT_ORG_ID
	, fact1.PROJECT_ORGANIZATION_ID
      , fact1.project_element_id
	, fact1.TIME_ID
      , fact1.PERIOD_TYPE_ID
      , fact1.CALENDAR_TYPE
	, fact1.WBS_ROLLUP_FLAG
	, fact1.PRG_ROLLUP_FLAG
      , fact1.CURR_RECORD_TYPE_ID
      , fact1.CURRENCY_CODE
      , rbs.sup_id
      , fact1.RBS_VERSION_ID
      , fact1.PLAN_VERSION_ID
	, fact1.PLAN_TYPE_ID
      , fact1.line_type
      , fact1.plan_type_code ;   /*4471527*/


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'ROLLUP_FPR_RBS');
    RAISE;
END;


PROCEDURE ROLLUP_FPR_RBS_T_SLICE IS
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN

  print_time(' worker id is ... ' || 1);

    INSERT INTO  pji_fp_aggr_pjp1
     (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , PRG_LEVEL
     , PLAN_TYPE_CODE  /*4471527 */
    )
     SELECT
        g_worker_id WORKER_ID
      , fact1.PROJECT_ID
	, fact1.PROJECT_ORG_ID
	, fact1.PROJECT_ORGANIZATION_ID
      , fact1.project_element_id
	, fact1.TIME_ID
      , fact1.PERIOD_TYPE_ID
      , fact1.CALENDAR_TYPE
	, g_top_level
	, fact1.WBS_ROLLUP_FLAG
	, fact1.PRG_ROLLUP_FLAG
      , fact1.CURR_RECORD_TYPE_ID
      , fact1.CURRENCY_CODE
      , -1
      , -1
      , fact1.PLAN_VERSION_ID
	, fact1.PLAN_TYPE_ID
      , SUM(fact1.RAW_COST)
      , SUM(fact1.BRDN_COST)
      , SUM(fact1.REVENUE)
      , SUM(fact1.BILL_RAW_COST)
      , SUM(fact1.BILL_BRDN_COST )
      , SUM(fact1.BILL_LABOR_RAW_COST)
      , SUM(fact1.BILL_LABOR_BRDN_COST )
      , SUM(fact1.BILL_LABOR_HRS )
      , SUM(fact1.EQUIPMENT_RAW_COST )
      , SUM(fact1.EQUIPMENT_BRDN_COST )
      , SUM(fact1.CAPITALIZABLE_RAW_COST )
      , SUM(fact1.CAPITALIZABLE_BRDN_COST )
      , SUM(fact1.LABOR_RAW_COST )
      , SUM(fact1.LABOR_BRDN_COST )
      , SUM(fact1.LABOR_HRS)
      , SUM(fact1.LABOR_REVENUE)
      , SUM(fact1.EQUIPMENT_HOURS)
      , SUM(fact1.BILLABLE_EQUIPMENT_HOURS)
      , SUM(fact1.SUP_INV_COMMITTED_COST)
      , SUM(fact1.PO_COMMITTED_COST   )
      , SUM(fact1.PR_COMMITTED_COST  )
      , SUM(fact1.OTH_COMMITTED_COST)
       , SUM(fact1.ACT_LABOR_HRS)
	 , SUM(fact1.ACT_EQUIP_HRS)
	 , SUM(fact1.ACT_LABOR_BRDN_COST)
	 , SUM(fact1.ACT_EQUIP_BRDN_COST)
	 , SUM(fact1.ACT_BRDN_COST)
	 , SUM(fact1.ACT_RAW_COST)
	 , SUM(fact1.ACT_REVENUE)
       , SUM(fact1.ACT_LABOR_RAW_COST)
       , SUM(fact1.ACT_EQUIP_RAW_COST)
	 , SUM(fact1.ETC_LABOR_HRS)
	 , SUM(fact1.ETC_EQUIP_HRS)
	 , SUM(fact1.ETC_LABOR_BRDN_COST)
	 , SUM(fact1.ETC_EQUIP_BRDN_COST)
	 , SUM(fact1.ETC_BRDN_COST )
       , SUM(fact1.ETC_RAW_COST )
       , SUM(fact1.ETC_LABOR_RAW_COST)
       , SUM(fact1.ETC_EQUIP_RAW_COST)
      , SUM(fact1.CUSTOM1 )
      , SUM(fact1.CUSTOM2 )
      , SUM(fact1.CUSTOM3 )
      , SUM(fact1.CUSTOM4 )
      , SUM(fact1.CUSTOM5 )
      , SUM(fact1.CUSTOM6 )
      , SUM(fact1.CUSTOM7 )
      , SUM(fact1.CUSTOM8 )
      , SUM(fact1.CUSTOM9 )
      , SUM(fact1.CUSTOM10 )
      , SUM(fact1.CUSTOM11 )
      , SUM(fact1.CUSTOM12 )
      , SUM(fact1.CUSTOM13 )
      , SUM(fact1.CUSTOM14 )
      , SUM(fact1.CUSTOM15 )
      , fact1.line_type
      , g_default_prg_level
      , fact1.plan_type_code
    FROM pji_fp_aggr_pjp1       fact1
       , pji_fm_extr_plnver4    ver3
    WHERE
          fact1.RBS_AGGR_LEVEL = g_lowest_level
      AND fact1.worker_id = g_worker_id
      AND ver3.worker_id = g_worker_id
      AND fact1.plan_version_id = ver3.plan_version_id
     AND fact1.plan_type_code = ver3.plan_type_code    /*4471527 */
      AND ( fact1.rbs_version_id = ver3.rbs_struct_version_id
         OR fact1.rbs_version_id = -1)
      AND ver3.secondary_rbs_flag = 'N'
    GROUP BY
        fact1.PROJECT_ID
	, fact1.PROJECT_ORG_ID
	, fact1.PROJECT_ORGANIZATION_ID
      , fact1.project_element_id
	, fact1.TIME_ID
      , fact1.PERIOD_TYPE_ID
      , fact1.CALENDAR_TYPE
	, fact1.WBS_ROLLUP_FLAG
	, fact1.PRG_ROLLUP_FLAG
      , fact1.CURR_RECORD_TYPE_ID
      , fact1.CURRENCY_CODE
      , fact1.RBS_VERSION_ID
      , fact1.PLAN_VERSION_ID
      , fact1.PLAN_TYPE_ID
      , fact1.line_type
      , fact1.plan_type_code;  /*4471527 */


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'ROLLUP_FPR_RBS_T_SLICE');
    RAISE;
END;


PROCEDURE COMPUTE_XBS_UPDATED_ROLLUPS IS
BEGIN
  NULL;
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'COMPUTE_XBS_UPDATED_ROLLUPS');
    RAISE;
END;


PROCEDURE POPULATE_RBS_HDR IS

    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN

  print_time ( ' Before update rbs header ' );

  INSERT INTO pji_pjp_rbs_header
  (
      project_id
    , plan_version_id
    , rbs_version_id
    , reporting_usage_flag
    , prog_rep_usage_flag
    , plan_usage_flag
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_LOGIN
    ,PLAN_TYPE_CODE    /*4471527 */
  )
  SELECT /*+ ordered */ DISTINCT
        rpa.project_id
      , bv.plan_version_id
      , rpa.rbs_version_id
      , rpa.reporting_usage_flag
      , rpa.prog_rep_usage_flag
      , DECODE(bv.wp_flag, 'Y', rpa.wp_usage_flag, rpa.fp_usage_flag)
      , l_last_update_date
      , l_last_updated_by
      , l_creation_date
      , l_created_by
      , l_last_update_login
      , bv.plan_type_code
  FROM
    PJI_FM_EXTR_PLNVER4    bv,
    PA_RBS_PRJ_ASSIGNMENTS rpa,
    PJI_PJP_RBS_HEADER     head
  WHERE bv.project_id = rpa.project_id
    AND bv.worker_id = g_worker_id
    AND bv.RBS_STRUCT_VERSION_ID  = rpa.RBS_VERSION_ID
    AND bv.PROJECT_ID = head.PROJECT_ID (+)
    AND bv.PLAN_VERSION_ID = head.PLAN_VERSION_ID (+)
    AND bv.PLAN_TYPE_CODE  = head.PLAN_TYPE_CODE (+)    /*4471527 */
    AND bv.RBS_STRUCT_VERSION_ID = head.RBS_VERSION_ID (+)
    AND head.PROJECT_ID IS NULL;

  print_time ( ' After update rbs header, # rows inserted is.. '|| SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    print_time ( ' update rbs header exception ' || sqlerrm );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'POPULATE_RBS_HDR');
    RAISE;
END;


PROCEDURE POPULATE_WBS_HDR IS

    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN

  print_time ( ' Before populate wbs header ' );

  INSERT INTO PJI_PJP_WBS_HEADER
  (
    PROJECT_ID
  , PLAN_VERSION_ID
  , WBS_VERSION_ID
  , WP_FLAG
  , CB_FLAG
  , CO_FLAG
  , LOCK_FLAG
  , PLAN_TYPE_ID
  , MIN_TXN_DATE
  , MAX_TXN_DATE
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_LOGIN
  , PLAN_TYPE_CODE   /* 4471527 */
  )
  SELECT DISTINCT
         ver.project_id
       , ver.plan_version_id
       , ver.wbs_struct_version_id
       , ver.wp_flag
       , DECODE( (ver.current_flag || ver.baselined_flag) , 'YY', 'Y', 'N')
       , ver.current_original_flag
       , null
       , ver.plan_type_id
       , to_date('3000/01/01', 'YYYY/MM/DD') MIN_TXN_DATE
       , to_date('0001/01/01', 'YYYY/MM/DD') MAX_TXN_DATE
       , l_last_update_date
       , l_last_updated_by
       , l_creation_date
       , l_created_by
       , l_last_update_login
       , ver.plan_type_code
  FROM PJI_FM_EXTR_PLNVER4 ver
     , PJI_PJP_WBS_HEADER  whdr
  WHERE ver.worker_id = g_worker_id
    AND ver.plan_version_id = whdr.plan_version_id (+)
   AND ver.plan_type_code = whdr.plan_type_code(+)   /*4471527 */
    AND ver.project_id = whdr.project_id (+)
    AND ver.plan_type_id = whdr.plan_type_id (+)
    -- AND ver.wbs_struct_version_id = whdr.wbs_version_id (+)
    AND whdr.plan_version_id IS NULL
    AND ver.plan_version_id <> -1
  ORDER BY
        ver.project_id
      , ver.plan_version_id;

  print_time ( ' After populate wbs header ' );

EXCEPTION
  WHEN OTHERS THEN
    print_time ( ' Populate wbs header exception ' || sqlerrm );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'POPULATE_WBS_HDR');
    RAISE;
END;



PROCEDURE UPDATE_WBS_HDR  IS

    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN

  print_time ( ' Before update wbs header ' );

  delete from pji_fp_aggr_pjp1_t; -- 5309891

  INSERT INTO pji_fp_aggr_pjp1_t
  ( WORKER_ID
  , PROJECT_ID, PROJECT_ORG_ID, PROJECT_ORGANIZATION_ID, PROJECT_ELEMENT_ID
  , TIME_ID, PERIOD_TYPE_ID, CALENDAR_TYPE, RBS_AGGR_LEVEL
  , WBS_ROLLUP_FLAG, PRG_ROLLUP_FLAG , CURR_RECORD_TYPE_ID ,CURRENCY_CODE
  , PLAN_VERSION_ID, PLAN_TYPE_ID, PLAN_TYPE_CODE
  , start_date, end_date)
  SELECT g_worker_id
       , whdr.project_id, 0, 0, 0
       , 0, 0, 'X', 'X'
	   , 'X', 'X', 0, 'X'
       , whdr.plan_version_id, NVL(whdr.plan_type_id, -1)
       , whdr.PLAN_TYPE_CODE
       , MIN(LEAST(cal.start_date,  NVL(whdr.min_txn_date, cal.start_date))) start_date
       , MAX(GREATEST(cal.end_date, NVL(whdr.max_txn_date, cal.end_date))) end_date
    FROM PJI_FP_AGGR_PJP1    pjp1
       , pji_time_cal_period_v   cal
       , pji_pjp_wbs_header whdr
   WHERE
         pjp1.worker_id = g_worker_id
     AND pjp1.project_id = whdr.project_id
     AND pjp1.plan_type_id = NVL(whdr.plan_type_id, -1)
     AND pjp1.plan_version_id = whdr.plan_version_id
     AND pjp1.time_id = cal.cal_period_id
     AND pjp1.calendar_type IN ('P', 'G') -- Non time ph and ent cals don't need to be considered.
     AND pjp1.plan_type_code = whdr.plan_type_code
   GROUP BY whdr.project_id, whdr.plan_type_id
          , whdr.plan_version_id, whdr.plan_type_code;

  UPDATE /*+ index(whdr,PJI_PJP_WBS_HEADER_N1) */
      PJI_PJP_WBS_HEADER whdr
  SET ( MIN_TXN_DATE
      , MAX_TXN_DATE
      , LAST_UPDATE_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_LOGIN ) = (
  SELECT start_date
       , end_date
       , l_last_update_date
       , l_last_updated_by
       , l_last_update_login
    FROM pji_fp_aggr_pjp1_t dates
   WHERE
         dates.plan_version_id = whdr.plan_version_id
     AND dates.project_id = whdr.project_id
     AND dates.plan_type_id = NVL(whdr.plan_type_id, -1)
     AND dates.plan_type_code = whdr.plan_type_code
                                      )
 WHERE (project_id, NVL(plan_type_id, -1), plan_version_id, plan_type_code) IN (
         SELECT project_id, plan_type_id, plan_version_id , plan_type_code
         FROM   PJI_FP_AGGR_PJP1_T ver
         );

  delete from pji_fp_aggr_pjp1_t;


  print_time ( ' After update wbs header ' );

EXCEPTION
  WHEN OTHERS THEN
    print_time ( ' update wbs header exception ' || sqlerrm );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'POPULATE_WBS_HDR');
    RAISE;
END;




PROCEDURE MARK_EXTRACTED_PLANS(p_slice_type IN VARCHAR2) IS
-- Added for bug 9108728
l_up_process_flag  varchar2(1);

BEGIN

-- Added for bug 9108728
l_up_process_flag := PJI_UTILS.GET_SETUP_PARAMETER('UP_PROCESS_FLAG');
  --
  -- On PA_BUDGET_VERSIONS, the PJI_SUMMARIZED_FLAG can have four values:
  --   'N' the plan version has not been summarized
  --   'P' the plan version has been partially summarized due to dangling currency or calendar records
  --   'Y' the plan version has been fully summarized in Project Performance and
  --   NULL the plan version has been fully summarized in both PJI and Project Performance.
  --
  -- Note that, in PJI data extraction, data that existed before PJI was installed
  -- has PJI_SUMMARIZED_FLAG = null and new transactions are inserted with value 'N'.
  -- A similar situation does not occur in PA_BUDGET_VERSIONS.  During the upgrade process
  -- will pull necessary data from PA_BUDGET_VERSIONS and set PJI_SUMMARIZATION_FLAG to 'P', 'N'
  -- or 'Y' accordingly.  New versions will be inserted with value 'N'.)
  --

  IF (p_slice_type = 'PRI') THEN
  -- Added for bug 9108728
      if l_up_process_flag = 'Y' then

          UPDATE /*+ index(bv,pa_budget_versions_u1) */
                 pa_budget_versions bv
          SET    pji_summarized_flag = 'P',
      	    record_version_number=nvl(record_version_number,0)+1
          WHERE  budget_version_id IN
                     ( SELECT DISTINCT plan_version_id
                       FROM   pji_fm_extr_plnver4
                       WHERE  worker_id = g_worker_id )
          AND (bv.current_flag = 'Y' or bv.current_original_flag = 'Y')
          AND nvl(bv.wp_version_flag,'Y') = 'N';

          UPDATE /*+ index(bv,pa_budget_versions_u1) */
                 pa_budget_versions bv
          SET    pji_summarized_flag = 'Y',
      	    record_version_number=nvl(record_version_number,0)+1
          WHERE  budget_version_id IN
                     ( SELECT DISTINCT plan_version_id
                       FROM   pji_fm_extr_plnver4
                       WHERE  worker_id = g_worker_id )
          AND bv.current_flag = 'N'
          AND bv.current_original_flag = 'N';

      else
    -- Added for bug 9108728 ends

    UPDATE /*+ index(bv,pa_budget_versions_u1) */
           pa_budget_versions bv
    SET    pji_summarized_flag =
                       DECODE(wp_version_flag
                            , 'Y', 'Y'
                            , DECODE(budget_status_code
                                   , 'B', 'P'
                                   , 'Y')
                             ),
	    record_version_number=nvl(record_version_number,0)+1
    WHERE  budget_version_id IN
               ( SELECT DISTINCT plan_version_id
                 FROM   pji_fm_extr_plnver4
                 WHERE  worker_id = g_worker_id );

     end if; -- Added for bug 9108728
  ELSE -- Secondary slice.
/*  Modified the logic for bug 4039796 */
UPDATE PJI_FM_EXTR_PLNVER4 ver3
    SET time_dangling_flag = 'Y'
  WHERE (project_id,plan_version_id,plan_type_code) IN
                ( SELECT project_id,plan_version_id,plan_type_code   /*4471527 */
                    FROM pji_fp_aggr_pjp1 pjp1
                   WHERE pjp1.worker_id = g_worker_id
                     AND (    pjp1.time_dangling_flag IS NOT NULL
                           OR pjp1.rate_dangling_flag IS NOT NULL )
                )
   AND worker_id = g_worker_id ;

UPDATE  /*+ index( bv , pa_budget_versions_u1 ) */
        pa_budget_versions bv
   SET  pji_summarized_flag = 'Y',
        record_version_number=nvl(record_version_number,0)+1
 WHERE  budget_version_id IN (SELECT plan_version_id
                                FROM  PJI_FM_EXTR_PLNVER4 ver3
                               WHERE ver3.worker_id=g_worker_id
                                 AND ver3.time_dangling_flag IS NULL);

UPDATE  /*+ index( bv , pa_budget_versions_u1 ) */
        pa_budget_versions bv
   SET  pji_summarized_flag = 'P',
        record_version_number=nvl(record_version_number,0)+1
 WHERE  budget_version_id IN (SELECT plan_version_id
                                FROM  PJI_FM_EXTR_PLNVER4 ver3
                               WHERE ver3.worker_id=g_worker_id
                                 AND ver3.time_dangling_flag IS NOT NULL);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'MARK_EXTRACTED_PLANS');
    RAISE;
END;


------------------------------------------------------------------------------
---- WBS rollup api..
------------------------------------------------------------------------------

PROCEDURE CREATE_WBSRLP IS
BEGIN

  print_time('... Begin CREATE_WBSRLP ' );

  PRINT_NUM_WBSRLPRCDS_INPJP1;

  print_time('... Before call to rollup_fpr_wbs...' );

  PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_WBS(g_worker_id);  /*Added for 3852901*/

  print_time('... after call to rollup_fpr_wbs. ' );

  PRINT_NUM_WBSRLPRCDS_INPJP1;

  print_time('... End CREATE_WBSRLP ' );

EXCEPTION
  WHEN OTHERS THEN
    print_time('... Exception CREATE_WBSRLP ' );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_WBSRLP');
    RAISE;
END;



PROCEDURE PRINT_NUM_WBSRLPRCDS_INPJP1 IS
  l_count NUMBER;
  l_wbs_rollup_flag  VARCHAR2(1);
  l_prg_rollup_flag  VARCHAR2(1);
  l_return_status    VARCHAR2(1);

BEGIN

  l_wbs_rollup_flag  := 'N';
  l_prg_rollup_flag  := 'N';

/*
  select count(1)
  INTO   l_count
  FROM   pji_fp_aggr_pjp1
  WHERE  wbs_rollup_flag = l_wbs_rollup_flag
    AND  prg_rollup_flag = l_prg_rollup_flag;

  print_time ( ' l_worker_id = '|| g_worker_id || ' wbs rollup flag = ' || l_wbs_rollup_flag || ' prg rollup flag = ' || l_prg_rollup_flag || ' l_count ' || l_count);


  l_wbs_rollup_flag  := 'N';
  l_prg_rollup_flag  := 'Y';

  select count(1)
  INTO   l_count
  FROM   pji_fp_aggr_pjp1
  WHERE  wbs_rollup_flag = l_wbs_rollup_flag
    AND  prg_rollup_flag = l_prg_rollup_flag;

  print_time ( ' l_worker_id = '|| g_worker_id || ' wbs rollup flag = ' || l_wbs_rollup_flag || ' prg rollup flag = ' || l_prg_rollup_flag || ' l_count ' || l_count);


  l_wbs_rollup_flag  := 'Y';
  l_prg_rollup_flag  := 'N';

  select count(1)
  INTO   l_count
  FROM   pji_fp_aggr_pjp1
  WHERE  wbs_rollup_flag = l_wbs_rollup_flag
    AND  prg_rollup_flag = l_prg_rollup_flag;

  print_time ( ' l_worker_id = '|| g_worker_id || ' wbs rollup flag = ' || l_wbs_rollup_flag || ' prg rollup flag = ' || l_prg_rollup_flag || ' l_count ' || l_count);


  l_wbs_rollup_flag  := 'Y';
  l_prg_rollup_flag  := 'Y';

  select count(1)
  INTO   l_count
  FROM   pji_fp_aggr_pjp1
  WHERE  wbs_rollup_flag = l_wbs_rollup_flag
    AND  prg_rollup_flag = l_prg_rollup_flag;

  print_time ( ' l_worker_id = '|| g_worker_id || ' wbs rollup flag = ' || l_wbs_rollup_flag || ' prg rollup flag = ' || l_prg_rollup_flag || ' l_count ' || l_count);
*/

EXCEPTION
  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'PRINT_NUM_WBSRLPRCDS_INPJP1'
    , x_return_status  => l_return_status ) ;

    RAISE;
END;


PROCEDURE CLEANUP_INTERIM_TABLES IS
  l_count NUMBER;
BEGIN

  print_time('.......CLEANUP_INTERIM_TABLES: Begin. ');

  DELETE FROM PJI_FM_EXTR_PLNVER4
  WHERE worker_id = g_worker_id ;

  print_time('.......ver3 rows deleted: #= ' || sql%rowcount);

  DELETE FROM pji_fp_aggr_pjp1
  WHERE worker_id = g_worker_id;

  print_time('.......pjp1 rows deleted: #= ' || sql%rowcount);

  print_time('.......CLEANUP_INTERIM_TABLES: End. ');

EXCEPTION
  WHEN OTHERS THEN
    print_time('.......CLEANUP_INTERIM_TABLES: Exception. ' || sqlerrm);
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CLEANUP_INTERIM_TABLES');
    RAISE;
END CLEANUP_INTERIM_TABLES;


----------
-- Print time API to measure time taken by each api. Also useful for debugging.
----------
PROCEDURE PRINT_TIME(p_tag IN VARCHAR2) IS
BEGIN
  PJI_PJP_FP_CURR_WRAP.print_time(p_tag);
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRINT_TIME');
    RAISE;
END;

PROCEDURE EXTRACT_PLAN_AMTS_SECRBS_GLC12 (
  p_pull_dangling_flag IN VARCHAR2 := 'Y') -- Reversals to be computed only if pull_dangling flag is 'Y'
IS
BEGIN

    print_time ( ' EXTRACT_PLAN_AMTS_SECRBS_GLC12 begin. ' );

    PJI_PJP_FP_CURR_WRAP.get_global_currency_info (
      x_currency_conversion_rule => g_currency_conversion_rule
    , x_prorating_format         => g_prorating_format
    , x_global1_currency_code    => g_global1_currency_code
    , x_global2_currency_code    => g_global2_currency_code
    , x_global1_currency_mau     => g_global1_currency_mau
    , x_global2_currency_mau     => g_global2_currency_mau ) ;


  print_time(' Got global currency settings. ');
  print_time(' g_currency_conversion_rule ' || g_currency_conversion_rule || ' g_prorating_format ' ||  g_prorating_format );
  print_time(' g_global1_currency_code ' || g_global1_currency_code || ' g_global2_currency_code ' || g_global2_currency_code );
  print_time(' g_global1_currency_mau ' || g_global1_currency_mau || ' g_global2_currency_mau ' || g_global2_currency_mau ) ;

    INSERT INTO PJI_FP_AGGR_PJP1
    (
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , LINE_TYPE
       , RATE_DANGLING_FLAG
       , TIME_DANGLING_FLAG
       , START_DATE
       , END_DATE
       , PRG_LEVEL
       ,PLAN_TYPE_CODE   /*4471527 */
	)
    SELECT
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , project_ORGANIZATION_ID
       , WBS_ELEMENT_ID
       , time_id
       , period_type_id
       , CALENDAR_TYPE
       , g_lowest_level RBS_AGGR_LEVEL
       , 'N' WBS_ROLLUP_FLAG
       , 'N' PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE
       , currency_code
       , RBS_ELEMENT_ID
       , RBS_STRUCT_VERSION_ID
       , plan_version_id
       , plan_type_id
       , decode(rate_dangling_flag,null,SUM(RAW_COST),0)
       , decode(rate_dangling_flag,null,SUM(BRDN_COST),0)
       , decode(rate_dangling_flag,null,SUM(REVENUE),0)
       , decode(rate_dangling_flag,null,SUM ( BILL_RAW_COST ),0)  BILL_RAW_COST
       , decode(rate_dangling_flag,null,SUM (BILL_BRDN_COST ),0)   BILL_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( BILL_LABOR_RAW_COST),0) BILL_LABOR_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( BILL_LABOR_BRDN_COST),0) BILL_LABOR_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( BILL_LABOR_HRS),0) BILL_LABOR_HRS
       , decode(rate_dangling_flag,null,SUM ( EQUIPMENT_RAW_COST),0) EQUIPMENT_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( EQUIPMENT_BRDN_COST),0) EQUIPMENT_BRDN_COST
       , decode(rate_dangling_flag,null,SUM (CAPITALIZABLE_RAW_COST),0) CAPITALIZABLE_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( CAPITALIZABLE_BRDN_COST),0)
       , decode(rate_dangling_flag,null,SUM ( LABOR_RAW_COST),0) LABOR_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( LABOR_BRDN_COST),0) LABOR_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( labor_hrs),0)  labor_hrs
       , decode(rate_dangling_flag,null,SUM (LABOR_REVENUE),0)  LABOR_REVENUE
       , decode(rate_dangling_flag,null,SUM (EQUIPMENT_HOURS),0) EQUIPMENT_HOURS
       , decode(rate_dangling_flag,null,SUM ( BILLABLE_EQUIPMENT_HOURS),0) BILLABLE_EQUIPMENT_HOURS
       , decode(rate_dangling_flag,null,SUM(SUP_INV_COMMITTED_COST),0) SUP_INV_COMMITTED_COST
       , decode(rate_dangling_flag,null,SUM(PO_COMMITTED_COST),0) PO_COMMITTED_COST
       , decode(rate_dangling_flag,null,SUM(PR_COMMITTED_COST),0) PR_COMMITTED_COST
       , decode(rate_dangling_flag,null,SUM(OTH_COMMITTED_COST),0) PR_COMMITTED_COST
       , decode(rate_dangling_flag,null,SUM ( ACT_LABOR_HRS),0) ACT_LABOR_HRS
       , decode(rate_dangling_flag,null,SUM (ACT_EQUIP_HOURS),0) ACT_EQUIP_HOURS
       , decode(rate_dangling_flag,null,SUM ( ACT_LABOR_BRDN_COST),0) ACT_LABOR_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( ACT_EQUIPMENT_BRDN_COST),0) ACT_EQUIPMENT_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( ACT_BRDN_COST),0) ACT_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( ACT_RAW_COST),0) ACT_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( ACT_REVENUE),0) ACT_REVENUE
       , decode(rate_dangling_flag,null,SUM ( ACT_LABOR_RAW_COST),0) ACT_LABOR_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( ACT_EQUIPMENT_RAW_COST),0) ACT_EQUIPMENT_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( ETC_LABOR_HRS),0) ETC_LABOR_HRS
       , decode(rate_dangling_flag,null,SUM ( ETC_EQUIP_HOURS),0) ETC_EQUIP_HOURS
       , decode(rate_dangling_flag,null,SUM ( ETC_LABOR_BRDN_COST),0) ETC_LABOR_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( ETC_EQUIP_BRDN_COST),0) ETC_EQUIP_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( ETC_BRDN_COST),0) ETC_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( ETC_RAW_COST),0) ETC_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( ETC_LABOR_raw_COST),0) ETC_LABOR_raw_COST
       , decode(rate_dangling_flag,null,SUM ( ETC_EQUIP_raw_COST),0) ETC_EQUIP_raw_COST
       , decode(rate_dangling_flag,null,SUM(CUSTOM1),0) CUSTOM1
       , decode(rate_dangling_flag,null,SUM(CUSTOM2),0) CUSTOM2
       , decode(rate_dangling_flag,null,SUM(CUSTOM3),0) CUSTOM3
       , decode(rate_dangling_flag,null,SUM(CUSTOM4),0) CUSTOM4
       , decode(rate_dangling_flag,null,SUM(CUSTOM5),0) CUSTOM5
       , decode(rate_dangling_flag,null,SUM(CUSTOM6),0) CUSTOM6
       , decode(rate_dangling_flag,null,SUM(CUSTOM7),0) CUSTOM7
       , decode(rate_dangling_flag,null,SUM(CUSTOM8),0) CUSTOM8
       , decode(rate_dangling_flag,null,SUM(CUSTOM9),0) CUSTOM9
       , decode(rate_dangling_flag,null,SUM(CUSTOM10),0) CUSTOM10
       , decode(rate_dangling_flag,null,SUM(CUSTOM11),0) CUSTOM11
       , decode(rate_dangling_flag,null,SUM(CUSTOM12),0) CUSTOM12
       , decode(rate_dangling_flag,null,SUM(CUSTOM13),0) CUSTOM13
       , decode(rate_dangling_flag,null,SUM(CUSTOM14),0) CUSTOM14
       , decode(rate_dangling_flag,null,SUM(CUSTOM15),0) CUSTOM15
       , LINE_TYPE
       , rate_dangling_flag
       , time_dangling_flag
       , start_date
       , end_date
       , g_default_prg_level prg_level
       ,plan_type_code
 FROM
       (   SELECT
         g_worker_id WORKER_ID
       , plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , plr.time_id
       , plr.period_type_id -- period type id...
       , plr.CALENDAR_TYPE
       , g_lowest_level RBS_AGGR_LEVEL
       , 'N' WBS_ROLLUP_FLAG
       , 'N' PRG_ROLLUP_FLAG
       , plr.CURR_RECORD_TYPE
       , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.plan_version_id
       , plr.plan_type_id
       , SUM(plr.RAW_COST)  RAW_COST
       , SUM(plr.BRDN_COST)  BRDN_COST
       , SUM(plr.REVENUE)  REVENUE
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )  BILL_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )   BILL_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_people_resclass_code, plr.raw_cost, 0 ) )  BILL_LABOR_RAW_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_people_resclass_code , plr.BRDN_COST, 0 ) )   BILL_LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'Y' || g_people_resclass_code, plr.quantity, 0 ) )  BILL_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'Y' || g_people_resclass_code,
                                                                  DECODE ( plr.billable_flag , 'Y' , plr.quantity, 0 ) , 0 ) )  BILL_LABOR_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.raw_cost, 0 ) )  EQUIPMENT_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.BRDN_COST, 0 ) )   EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )      CAPITALIZABLE_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )      CAPITALIZABLE_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.raw_cost, 0 ) )  LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.BRDN_COST, 0 ) )   LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.resource_class, g_people_resclass_code,
                                            DECODE ( plr.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
                                                    0 ) )   labor_hrs */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code,
                                            DECODE(plr.billable_flag, 'Y' ,
					           DECODE ( plr.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
						    0 ),
                                                    0 ) )   labor_hrs -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.revenue, 0 ) )  LABOR_REVENUE
      /* , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code,
                                            DECODE ( plr.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),

                                            0 ) )  EQUIPMENT_HOURS */ -- bug 6039785
      , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code,
                                            DECODE(plr.billable_flag, 'Y' ,
                                                   DECODE ( plr.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
					 	    0 ),
                                                    0 ) )  EQUIPMENT_HOURS -- bug 6039785
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_equip_resclass_code, plr.quantity, 0 ) )  BILLABLE_EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_equip_resclass_code,
                                                                 DECODE ( plr.billable_flag , 'Y' , plr.quantity, 0 ) , 0 ) )  BILLABLE_EQUIPMENT_HOURS -- bug 6039785
       , TO_NUMBER(NULL)  SUP_INV_COMMITTED_COST
       , TO_NUMBER(NULL)  PO_COMMITTED_COST
       , TO_NUMBER(NULL)  PR_COMMITTED_COST
       , TO_NUMBER(NULL)  OTH_COMMITTED_COST
       /* , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                                0 ) ) ) ACT_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
										0 ),
                                                                                0 ) ) ) ACT_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                                0 ) ) ) ACT_EQUIP_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
										0 ),
                                                                                0 ) ) ) ACT_EQUIP_HOURS -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.actual_BRDN_COST, 0 ) ) ) ACT_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.actual_BRDN_COST, 0 ) ) ) ACT_EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.actual_brdn_cost ) ) ACT_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.actual_raw_cost ) ) ACT_RAW_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.actual_revenue ) ) ACT_REVENUE
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.actual_RAW_COST, 0 ) ) ) ACT_LABOR_RAW_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.actual_RAW_COST, 0 ) ) ) ACT_EQUIPMENT_RAW_COST
       /* , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ) ) ) ETC_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ),
                                                                                0 ) ) ) ETC_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ) ) ) ETC_EQUIP_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ),
                                                                                0 ) ) ) ETC_EQUIP_HOURS -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.etc_BRDN_COST, 0 ) ) ) ETC_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.etc_BRDN_COST, 0 ) ) ) ETC_EQUIP_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.etc_brdn_cost ) ) ETC_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.etc_raw_cost ) ) ETC_RAW_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.etc_raw_COST, 0 ) ) ) ETC_LABOR_raw_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.etc_raw_COST, 0 ) ) ) ETC_EQUIP_raw_COST
       , TO_NUMBER(NULL) CUSTOM1
       , TO_NUMBER(NULL) CUSTOM2
       , TO_NUMBER(NULL) CUSTOM3
       , TO_NUMBER(NULL) CUSTOM4
       , TO_NUMBER(NULL) CUSTOM5
       , TO_NUMBER(NULL) CUSTOM6
       , TO_NUMBER(NULL) CUSTOM7
       , TO_NUMBER(NULL) CUSTOM8
       , TO_NUMBER(NULL) CUSTOM9
       , TO_NUMBER(NULL) CUSTOM10
       , TO_NUMBER(NULL) CUSTOM11
       , TO_NUMBER(NULL) CUSTOM12
       , TO_NUMBER(NULL) CUSTOM13
       , TO_NUMBER(NULL) CUSTOM14
       , TO_NUMBER(NULL) CUSTOM15
       , plr.LINE_TYPE
       , decode(sign(plr.rate),-1,'Y',NULL) ||decode(sign(plr.rate2),-1,'Y',NULL) rate_dangling_flag
       , NULL time_dangling_flag
       , plr.start_date
  	 , plr.end_date
       , g_default_prg_level  prg_level
       , plr.plan_type_code PLAN_TYPE_CODE /*4471527 */
       FROM
       (          ----- First inline view plr .............
            select
              collapse_bl.PROJECT_ID      -- , 1 partition_id
            , collapse_bl.WBS_ELEMENT_ID  -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , SUM(collapse_bl.CURR_RECORD_TYPE_ID) CURR_RECORD_TYPE
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
		    , collapse_bl.plan_type_id
            , collapse_bl.plan_version_id
			, collapse_bl.time_id
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.RESOURCE_ASSIGNMENT_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS  -- , CALENDAR_TYPE -- , CALENDAR_ID
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , max(collapse_bl.raw_cost) raw_cost
            , max(collapse_bl.BRDN_COST) BRDN_COST
            , max(collapse_bl.revenue) revenue
            , max(collapse_bl.actual_raw_cost) actual_raw_cost
            , max(collapse_bl.actual_BRDN_COST) actual_BRDN_COST
            , max(collapse_bl.actual_revenue) actual_revenue
            , max(collapse_bl.etc_raw_cost) etc_raw_cost
            , max(collapse_bl.etc_BRDN_COST) etc_BRDN_COST
            , max(collapse_bl.etc_revenue) etc_revenue
            , max(collapse_bl.quantity) quantity
            , max(collapse_bl.actual_quantity) actual_quantity
            , max(collapse_bl.etc_quantity) etc_quantity
            , collapse_bl.start_date start_date
            , collapse_bl.end_date   end_date
            -- , collapse_bl.period_name period_name  -- , TRACK_AS_LABOR_FLAG track_as_labor_flag
			, collapse_bl.line_type
			, collapse_bl.calendar_type
			, collapse_bl.period_type_id
            , collapse_bl.row_id
            ,collapse_bl.rate rate
            ,collapse_bl.rate2 rate2
            , collapse_bl.plan_type_code
            , collapse_bl.WP_FLAG
            from
              (                  ----- Second inline view 'collapse_bl' begin .............
               select
                  spread_bl.row_id row_id
                , spread_bl.PROJECT_ID
                , spread_bl.BUDGET_VERSION_ID plan_version_id
				, spread_bl.time_id
                , spread_bl.RESOURCE_ASSIGNMENT_ID
                , spread_bl.WBS_ELEMENT_ID
                , spread_bl.RBS_ELEMENT_ID
                , spread_bl.WBS_STRUCT_VERSION_ID
                , spread_bl.RBS_STRUCT_VERSION_ID
  	 	        , spread_bl.plan_type_id
                , spread_bl.BILLABLE_FLAG
                , spread_bl.RESOURCE_CLASS
                , spread_bl.PROJECT_ORGANIZATION_ID
                , spread_bl.PROJECT_ORG_ID
                , spread_bl.TIME_PHASED_TYPE_CODE
                , DECODE( invert.INVERT_ID
                        , 1, spread_bl.glb1_CURRENCY_CODE
                        , 2, spread_bl.glb2_CURRENCY_CODE
                        , 4, spread_bl.func_CURRENCY_CODE
                        , 8, spread_bl.PRJ_CURRENCY_CODE
                        , 16, spread_bl.TXN_CURRENCY_CODE ) CURRENCY_CODE
                , invert.INVERT_ID CURR_RECORD_TYPE_ID
                , DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_raw_cost
                         , 2, spread_bl.glb2_raw_cost
                         , 4, spread_bl.func_raw_cost
                         , 8, spread_bl.PRJ_raw_cost
                         , 16, spread_bl.TXN_raw_cost) raw_cost
                , DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_brdn_cost
                         , 2, spread_bl.glb2_brdn_cost
                         , 4, spread_bl.func_BRDN_COST
                         , 8, spread_bl.PRJ_BRDN_COST
                         , 16, spread_bl.TXN_BRDN_COST ) BRDN_COST
                , DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_revenue
                         , 2, spread_bl.glb2_revenue
                         , 4, spread_bl.func_revenue
                         , 8, spread_bl.PRJ_revenue
                         , 16, spread_bl.TXN_revenue ) revenue
				, DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_actual_raw_cost
                         , 2, spread_bl.glb2_actual_raw_cost
				         , 4, spread_bl.func_actual_raw_cost
						 , 8, spread_bl.prj_actual_raw_cost
						 , 16, spread_bl.txn_actual_raw_cost ) actual_raw_cost
				, DECODE ( invert.INVERT_ID
				         , 1, spread_bl.glb1_actual_brdn_cost
						 , 2, spread_bl.glb2_actual_brdn_cost
				         , 4, spread_bl.func_actual_brdn_cost
						 , 8, spread_bl.prj_actual_brdn_cost
						 , 16, spread_bl.txn_actual_brdn_cost ) actual_brdn_cost
				, DECODE ( invert.INVERT_ID
				         , 1, spread_bl.glb1_actual_revenue
						 , 2, spread_bl.glb2_actual_revenue
				         , 4, spread_bl.func_actual_revenue
						 , 8, spread_bl.prj_actual_revenue
						 , 16, spread_bl.txn_actual_revenue ) actual_revenue
				, DECODE ( invert.INVERT_ID
				         , 1, spread_bl.glb1_etc_raw_cost
						 , 2, spread_bl.glb2_etc_raw_cost
				         , 4, spread_bl.func_etc_raw_cost
						 , 8, spread_bl.prj_etc_raw_cost
						 , 16, spread_bl.txn_etc_raw_cost ) etc_raw_cost
				, DECODE ( invert.INVERT_ID
				         , 1, spread_bl.glb1_etc_brdn_cost
						 , 2, spread_bl.glb2_etc_brdn_cost
				         , 4, spread_bl.func_etc_brdn_cost
						 , 8, spread_bl.prj_etc_brdn_cost
						 , 16, spread_bl.txn_etc_brdn_cost ) etc_brdn_cost
				, DECODE ( invert.INVERT_ID
				         , 1, spread_bl.glb1_etc_revenue
						 , 2, spread_bl.glb2_etc_revenue
				         , 4, spread_bl.func_etc_revenue
						 , 8, spread_bl.prj_etc_revenue
						 , 16, spread_bl.txn_etc_revenue ) etc_revenue
            	, spread_bl.quantity quantity
            	, spread_bl.actual_quantity actual_quantity
            	, spread_bl.etc_quantity etc_quantity
            	, spread_bl.start_date start_date
            	, spread_bl.end_date   end_date
            	, spread_bl.line_type line_type
				, spread_bl.period_type_id
				, spread_bl.calendar_type
 		,decode(invert.invert_id,1,spread_bl.rate,1) rate
 		,decode(invert.invert_id,2,spread_bl.rate2,1) rate2
                             , spread_bl.plan_type_code
                , spread_bl.WP_FLAG
                from
                  (     ----- Third inline view 'spread_bl'  .............
                    SELECT /*+ ordered */
                	  ra.project_id
                	, bl.rowid row_id
                	, ra.budget_version_id
					, prd.cal_period_id time_id
                	, bl.resource_asSIGNment_id
                	, DECODE(ra.task_id, 0, pevs.proj_element_id, ra.task_id) wbs_element_id
                	, NVL(map.element_id, -1)              rbs_element_id  -- !! changed.
                	, ver.wbs_struct_version_id      wbs_struct_version_id
                	, NVL(ver.rbs_struct_version_id, -1)    rbs_struct_version_id  -- !! changed.
			, ver.plan_type_id               plan_type_id
			, ra.rate_based_flag             billable_flag
			, ra.resource_class_code         resource_class
			, DECODE(ver.time_phased_type_code
                         , g_pa_cal_str, 32
                         , g_gl_cal_str, 32
                         , 'N', 2048
                         , -1) period_type_id
			   , DECODE(ver.time_phased_type_code
                            , g_pa_cal_str, g_pa_cal_str
                            , g_gl_cal_str, g_gl_cal_str
                            , 'N', g_all
                            , 'X')  CALENDAR_TYPE
                	, bl.txn_currency_code           txn_currency_code
                	, bl.txn_raw_cost                txn_raw_cost
                	, bl.txn_burdened_COST           txn_brdn_COST
                	, bl.txn_revenue                 txn_revenue
			, DECODE(ver.wp_flag, 'N', bl.txn_init_raw_cost, TO_NUMBER(NULL))                txn_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.txn_init_burdened_cost, TO_NUMBER(NULL))             txn_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.txn_init_revenue, TO_NUMBER(NULL))                   txn_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N', (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0)), TO_NUMBER(NULL)) txn_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0)), TO_NUMBER(NULL)) txn_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.txn_revenue - NVL(bl.txn_init_revenue, 0)), TO_NUMBER(NULL)) txn_etc_revenue     -- new
                	, bl.project_currency_code          prj_currency_code
                	, bl.project_raw_cost               prj_raw_cost
                	, bl.project_burdened_COST          prj_BRDN_COST
                	, bl.project_revenue                prj_revenue
			, DECODE(ver.wp_flag, 'N', bl.project_init_raw_cost, TO_NUMBER(NULL))          prj_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.project_init_burdened_cost, TO_NUMBER(NULL))     prj_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.project_init_revenue, TO_NUMBER(NULL))           prj_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N', (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0)), TO_NUMBER(NULL)) prj_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0)), TO_NUMBER(NULL)) prj_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.project_revenue - NVL(bl.project_init_revenue, 0)), TO_NUMBER(NULL)) prj_etc_revenue     -- new
                	, bl.projfunc_currency_code         func_currency_code
                  , bl.raw_cost                       func_raw_cost
                	, bl.burdened_COST                  func_BRDN_COST
                	, bl.revenue                        func_revenue
			, DECODE(ver.wp_flag, 'N', bl.init_raw_cost , TO_NUMBER(NULL))                 func_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.init_burdened_cost , TO_NUMBER(NULL))            func_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.init_revenue , TO_NUMBER(NULL))                  func_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N', (bl.raw_cost - NVL(bl.init_raw_cost, 0)), TO_NUMBER(NULL)) func_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)), TO_NUMBER(NULL)) func_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.revenue - NVL(bl.init_revenue, 0)), TO_NUMBER(NULL)) func_etc_revenue     -- new
                	, g_global1_currency_code  glb1_currency_code -- g_global1_currency_code        glb1_currency_code
                  , DECODE (g_global1_currency_code
				          , bl.txn_currency_code
						  , bl.txn_raw_cost
						  , bl.project_currency_code
						  , bl.project_raw_cost
						  , bl.projfunc_currency_code
						  , bl.raw_cost
						  , ROUND((rates.rate * raw_cost )/rates.mau)*rates.mau
					) glb1_raw_cost
                  , DECODE (g_global1_currency_code
				          , bl.txn_currency_code
						  , bl.txn_burdened_cost
						  , bl.project_currency_code
						  , bl.project_burdened_cost
						  , bl.projfunc_currency_code
						  , bl.burdened_cost
						  , ROUND((rates.rate * burdened_cost )/rates.mau)*rates.mau
					) glb1_BRDN_COST
                  , DECODE (g_global1_currency_code
				          , bl.txn_currency_code
						  , bl.txn_revenue
						  , bl.project_currency_code
						  , bl.project_revenue
						  , bl.projfunc_currency_code
						  , bl.revenue
						  , ROUND((rates.rate * revenue )/rates.mau)*rates.mau
					)  glb1_revenue
			      , DECODE(ver.wp_flag
			             , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_raw_cost
						         , bl.project_currency_code
						         , bl.project_init_raw_cost
						         , bl.projfunc_currency_code
						         , bl.init_raw_cost
						         , ROUND((rates.rate * bl.init_raw_cost )/rates.mau)*rates.mau
					              )
						 , TO_NUMBER(NULL))                 glb1_actual_raw_cost
   			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_burdened_cost
						         , bl.project_currency_code
						         , bl.project_init_burdened_cost
						         , bl.projfunc_currency_code
						         , bl.init_burdened_cost
						         , ROUND((rates.rate * bl.init_burdened_cost )/rates.mau)*rates.mau
					              )
						 , TO_NUMBER(NULL))            glb1_actual_brdn_cost
			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_revenue
						         , bl.project_currency_code
						         , bl.project_init_revenue
						         , bl.projfunc_currency_code
						         , bl.init_revenue
						         , ROUND((rates.rate * bl.init_revenue )/rates.mau)*rates.mau
					              )
						 , TO_NUMBER(NULL))                  glb1_actual_revenue
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
						         , ROUND((rates.rate * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau)*rates.mau
					              )
						 , TO_NUMBER(NULL))                glb1_etc_raw_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
						         , ROUND((rates.rate * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau)*rates.mau
					              )
						 , TO_NUMBER(NULL))    glb1_etc_brdn_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
						         , bl.project_currency_code
						         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
						         , bl.projfunc_currency_code
						         , (bl.revenue - NVL(bl.init_revenue, 0))
						         , ROUND((rates.rate * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau)*rates.mau
					              )
						 , TO_NUMBER(NULL))    glb1_etc_revenue
                	, g_global2_currency_code  glb2_currency_code -- g_global2_currency_code        glb2_currency_code
                  , DECODE (g_global2_currency_code
				          , bl.txn_currency_code
						  , bl.txn_raw_cost
						  , bl.project_currency_code
						  , bl.project_raw_cost
						  , bl.projfunc_currency_code
						  , bl.raw_cost
						  , ROUND((rates.rate2 * raw_cost )/rates.mau2)*rates.mau2
					) glb2_raw_cost
                  , DECODE (g_global2_currency_code
				          , bl.txn_currency_code
						  , bl.txn_burdened_cost
						  , bl.project_currency_code
						  , bl.project_burdened_cost
						  , bl.projfunc_currency_code
						  , bl.burdened_cost
						  , ROUND((rates.rate2 * burdened_cost )/rates.mau2)*rates.mau2
					) glb2_BRDN_COST
                  , DECODE (g_global2_currency_code
				          , bl.txn_currency_code
						  , bl.txn_revenue
						  , bl.project_currency_code
						  , bl.project_revenue
						  , bl.projfunc_currency_code
						  , bl.revenue
						  , ROUND((rates.rate2 * revenue )/rates.mau2)*rates.mau2
					)  glb2_revenue
			      , DECODE(ver.wp_flag
			             , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_raw_cost
						         , bl.project_currency_code
						         , bl.project_init_raw_cost
						         , bl.projfunc_currency_code
						         , bl.init_raw_cost
						         , ROUND((rates.rate2 * bl.init_raw_cost )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))                 glb2_actual_raw_cost
   			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_burdened_cost
						         , bl.project_currency_code
						         , bl.project_init_burdened_cost
						         , bl.projfunc_currency_code
						         , bl.init_burdened_cost
						         , ROUND((rates.rate2 * bl.init_burdened_cost )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))            glb2_actual_brdn_cost
			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_revenue
						         , bl.project_currency_code
						         , bl.project_init_revenue
						         , bl.projfunc_currency_code
						         , bl.init_revenue
						         , ROUND((rates.rate2 * bl.init_revenue )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))                  glb2_actual_revenue
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
						         , ROUND((rates.rate2 * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))                glb2_etc_raw_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
						         , ROUND((rates.rate2 * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))    glb2_etc_brdn_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
						         , bl.project_currency_code
						         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
						         , bl.projfunc_currency_code
						         , (bl.revenue - NVL(bl.init_revenue, 0))
						         , ROUND((rates.rate2 * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))    glb2_etc_revenue
                                     , bl.quantity                    quantity
			                   , DECODE(ver.wp_flag, 'N', bl.init_quantity, TO_NUMBER(NULL))                  actual_quantity  -- new
			                   , DECODE(ver.wp_flag, 'N', (bl.quantity - NVL(bl.init_quantity, 0)), TO_NUMBER(NULL)) etc_quantity  -- new
                	                   , TO_DATE(NULL) START_DATE
                	                   , TO_DATE(NULL) END_date
                	                   , ver.time_phased_type_code time_phased_type_code
                	                   , ppa.org_id project_org_id
                	                   , ppa.carrying_out_organization_id project_organization_id
					       , DECODE(ver.time_phased_type_code, g_pa_cal_str, 'OF', g_gl_cal_str, 'OF', 'N', 'NTP', 'X') line_type
 			,decode(ver.rate_dangling_flag,'Y',-1,1) rate
 			,decode(ver.rate_dangling_flag,'Y',-1,1) rate2
                                              ,ver.plan_type_code  plan_type_code /*4471527 */
                        , ver.WP_FLAG
				 FROM
                  PJI_FM_EXTR_PLNVER4           ver
                , pa_resource_asSIGNments       ra
                , PA_BUDGET_LINES               bl
                , pa_projects_all               ppa
                , PJI_ORG_EXTR_INFO             oei
                , pji_pjp_rbs_header            rhdr
                , pji_time_cal_period_v         prd
                , PJI_FM_AGGR_DLY_RATES         rates
                , pji_fp_txn_accum_header       hdr
                , pa_rbs_txn_accum_map          map
                , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                 WHERE 1=1
				     AND ra.resource_asSIGNment_id = bl.resource_asSIGNment_id
                             AND ra.project_id = ver.PROJECT_ID
                             AND ra.budget_version_id = ver.plan_version_id
                             AND ver.project_id = ppa.project_id
                             AND txn_currency_code IS NOT NULL
                             AND bl.project_currency_code IS NOT NULL
                             AND bl.projfunc_currency_code IS NOT NULL
			                 AND pevs.element_version_id = ver.wbs_struct_version_id
                             AND ver.project_id = pevs.project_id
	 		         AND ver.secondary_rbs_flag = 'Y'
					 AND ver.wp_flag = 'N'
					 AND ver.baselined_flag = 'Y'
					 AND oei.org_id = ppa.org_id
					 AND ver.time_phased_type_code IN (g_pa_cal_str, g_gl_cal_str)
					 AND DECODE ( ver.time_phased_type_code
					            , g_pa_cal_str, oei.pa_calendar_id
					 			, g_gl_cal_str, oei.gl_calendar_id) = prd.calendar_id
					 AND bl.period_name = prd.name
					 AND rates.time_id = prd.cal_period_id
                      AND rates.worker_id = g_worker_id
					 AND rates.pf_currency_code = bl.projfunc_currency_code -- 4764334
					  AND ra.txn_accum_header_id = hdr.txn_accum_header_id
					  AND ra.txn_accum_header_id = map.txn_accum_header_id
					  AND map.struct_version_id = rhdr.rbs_version_id
					  AND ra.budget_version_id = rhdr.plan_version_id
                             AND rhdr.project_id = ver.project_id
					  AND ppa.project_id = ra.project_id
                                AND ver.rbs_struct_version_id = rhdr.rbs_version_id
 					  AND ver.worker_id = g_worker_id
             UNION ALL
             SELECT /*+ ordered */
                	  ra.project_id
                	, bl.rowid row_id
                	, ra.budget_version_id
					, -1 time_id
                	, bl.resource_asSIGNment_id
                	, DECODE(ra.task_id, 0, pevs.proj_element_id, ra.task_id) wbs_element_id
                	, NVL(map.element_id, -1)              rbs_element_id  -- !! changed.
                	, ver.wbs_struct_version_id      wbs_struct_version_id
                	, NVL(ver.rbs_struct_version_id, -1)    rbs_struct_version_id  -- !! changed.
			, ver.plan_type_id               plan_type_id
			, ra.rate_based_flag             billable_flag
			, ra.resource_class_code         resource_class
			, DECODE(ver.time_phased_type_code
                         , g_pa_cal_str, 32
                         , g_gl_cal_str, 32
                         , 'N', 2048
                         , -1) period_type_id
		     , DECODE(ver.time_phased_type_code
                         , g_pa_cal_str, g_pa_cal_str
                         , g_gl_cal_str, g_gl_cal_str
                         , 'N', g_all
                         , 'X')  CALENDAR_TYPE
                	, bl.txn_currency_code           txn_currency_code
                	, bl.txn_raw_cost                txn_raw_cost
                	, bl.txn_burdened_COST           txn_brdn_COST
                	, bl.txn_revenue                 txn_revenue
			, DECODE(ver.wp_flag, 'N', bl.txn_init_raw_cost, TO_NUMBER(NULL))                txn_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.txn_init_burdened_cost, TO_NUMBER(NULL))             txn_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.txn_init_revenue, TO_NUMBER(NULL))                   txn_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N', (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0)), TO_NUMBER(NULL)) txn_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0)), TO_NUMBER(NULL)) txn_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.txn_revenue - NVL(bl.txn_init_revenue, 0)), TO_NUMBER(NULL)) txn_etc_revenue     -- new
                	, bl.project_currency_code          prj_currency_code
                	, bl.project_raw_cost               prj_raw_cost
                	, bl.project_burdened_COST          prj_BRDN_COST
                	, bl.project_revenue                prj_revenue
			, DECODE(ver.wp_flag, 'N', bl.project_init_raw_cost, TO_NUMBER(NULL))          prj_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.project_init_burdened_cost, TO_NUMBER(NULL))     prj_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.project_init_revenue, TO_NUMBER(NULL))           prj_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N', (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0)), TO_NUMBER(NULL)) prj_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0)), TO_NUMBER(NULL)) prj_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.project_revenue - NVL(bl.project_init_revenue, 0)), TO_NUMBER(NULL)) prj_etc_revenue     -- new
                	, bl.projfunc_currency_code         func_currency_code
                  , bl.raw_cost                       func_raw_cost
                	, bl.burdened_COST                  func_BRDN_COST
                	, bl.revenue                        func_revenue
			, DECODE(ver.wp_flag, 'N', bl.init_raw_cost , TO_NUMBER(NULL))                 func_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.init_burdened_cost , TO_NUMBER(NULL))            func_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.init_revenue , TO_NUMBER(NULL))                  func_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N', (bl.raw_cost - NVL(bl.init_raw_cost, 0)), TO_NUMBER(NULL)) func_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)), TO_NUMBER(NULL)) func_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.revenue - NVL(bl.init_revenue, 0)), TO_NUMBER(NULL)) func_etc_revenue     -- new
                	, g_global1_currency_code   glb1_currency_code -- g_global1_currency_code         glb1_currency_code
                  , DECODE (g_global1_currency_code
				          , bl.txn_currency_code
						  , bl.txn_raw_cost
						  , bl.project_currency_code
						  , bl.project_raw_cost
						  , bl.projfunc_currency_code
						  , bl.raw_cost
						  , ROUND((rates.rate * raw_cost )/rates.mau)*rates.mau
					) glb1_raw_cost
                  , DECODE (g_global1_currency_code
				          , bl.txn_currency_code
						  , bl.txn_burdened_cost
						  , bl.project_currency_code
						  , bl.project_burdened_cost
						  , bl.projfunc_currency_code
						  , bl.burdened_cost
						  , ROUND((rates.rate * burdened_cost )/rates.mau)*rates.mau
					) glb1_BRDN_COST
                  , DECODE (g_global1_currency_code
				          , bl.txn_currency_code
						  , bl.txn_revenue
						  , bl.project_currency_code
						  , bl.project_revenue
						  , bl.projfunc_currency_code
						  , bl.revenue
						  , ROUND((rates.rate * revenue )/rates.mau)*rates.mau
					)  glb1_revenue
			      , DECODE(ver.wp_flag
			             , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_raw_cost
						         , bl.project_currency_code
						         , bl.project_init_raw_cost
						         , bl.projfunc_currency_code
						         , bl.init_raw_cost
						         , ROUND((rates.rate * bl.init_raw_cost )/rates.mau)*rates.mau
					              )
						 , TO_NUMBER(NULL))                 glb1_actual_raw_cost
   			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_burdened_cost
						         , bl.project_currency_code
						         , bl.project_init_burdened_cost
						         , bl.projfunc_currency_code
						         , bl.init_burdened_cost
						         , ROUND((rates.rate * bl.init_burdened_cost )/rates.mau)*rates.mau
					              )
						 , TO_NUMBER(NULL))            glb1_actual_brdn_cost
			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_revenue
						         , bl.project_currency_code
						         , bl.project_init_revenue
						         , bl.projfunc_currency_code
						         , bl.init_revenue
						         , ROUND((rates.rate * bl.init_revenue )/rates.mau)*rates.mau
					              )
						 , TO_NUMBER(NULL))                  glb1_actual_revenue
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
						         , ROUND((rates.rate * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau)*rates.mau
					              )
						 , TO_NUMBER(NULL))                glb1_etc_raw_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
						         , ROUND((rates.rate * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau)*rates.mau
					              )
						 , TO_NUMBER(NULL))    glb1_etc_brdn_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
						         , bl.project_currency_code
						         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
						         , bl.projfunc_currency_code
						         , (bl.revenue - NVL(bl.init_revenue, 0))
						         , ROUND((rates.rate * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau)*rates.mau
					              )
						 , TO_NUMBER(NULL))    glb1_etc_revenue
                	, g_global2_currency_code   glb2_currency_code -- g_global2_currency_code         glb2_currency_code
                  , DECODE (g_global2_currency_code
				          , bl.txn_currency_code
						  , bl.txn_raw_cost
						  , bl.project_currency_code
						  , bl.project_raw_cost
						  , bl.projfunc_currency_code
						  , bl.raw_cost
						  , ROUND((rates.rate2 * raw_cost )/rates.mau2)*rates.mau2
					) glb2_raw_cost
                  , DECODE (g_global2_currency_code
				          , bl.txn_currency_code
						  , bl.txn_burdened_cost
						  , bl.project_currency_code
						  , bl.project_burdened_cost
						  , bl.projfunc_currency_code
						  , bl.burdened_cost
						  , ROUND((rates.rate2 * burdened_cost )/rates.mau2)*rates.mau2
					) glb2_BRDN_COST
                  , DECODE (g_global2_currency_code
				          , bl.txn_currency_code
						  , bl.txn_revenue
						  , bl.project_currency_code
						  , bl.project_revenue
						  , bl.projfunc_currency_code
						  , bl.revenue
						  , ROUND((rates.rate2 * revenue )/rates.mau2)*rates.mau2
					)  glb2_revenue
			      , DECODE(ver.wp_flag
			             , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_raw_cost
						         , bl.project_currency_code
						         , bl.project_init_raw_cost
						         , bl.projfunc_currency_code
						         , bl.init_raw_cost
						         , ROUND((rates.rate2 * bl.init_raw_cost )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))                 glb2_actual_raw_cost
   			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_burdened_cost
						         , bl.project_currency_code
						         , bl.project_init_burdened_cost
						         , bl.projfunc_currency_code
						         , bl.init_burdened_cost
						         , ROUND((rates.rate2 * bl.init_burdened_cost )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))            glb2_actual_brdn_cost
			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_revenue
						         , bl.project_currency_code
						         , bl.project_init_revenue
						         , bl.projfunc_currency_code
						         , bl.init_revenue
						         , ROUND((rates.rate2 * bl.init_revenue )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))                  glb2_actual_revenue
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
						         , ROUND((rates.rate2 * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))                glb2_etc_raw_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
						         , ROUND((rates.rate2 * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))    glb2_etc_brdn_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
						         , bl.project_currency_code
						         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
						         , bl.projfunc_currency_code
						         , (bl.revenue - NVL(bl.init_revenue, 0))
						         , ROUND((rates.rate2 * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))    glb2_etc_revenue
                          , bl.quantity                    quantity
			        , DECODE(ver.wp_flag, 'N', bl.init_quantity, TO_NUMBER(NULL))                  actual_quantity  -- new
			        , DECODE(ver.wp_flag, 'N', (bl.quantity - NVL(bl.init_quantity, 0)), TO_NUMBER(NULL)) etc_quantity  -- new
                	        , ra.planning_start_date  start_date
                	        , ra.planning_END_date    end_date
                	        , ver.time_phased_type_code time_phased_type_code
                	        , ppa.org_id project_org_id
                	        , ppa.carrying_out_organization_id project_organization_id
			  	  , 'NTP' line_type
 			,decode(ver.rate_dangling_flag,'Y',-1,1) rate
 			,decode(ver.rate_dangling_flag,'Y',-1,1) rate2
	        , ver.plan_type_code plan_type_code   /*4471527 */
                        , ver.WP_FLAG
			FROM
                   PJI_FM_EXTR_PLNVER4           ver
                 , pa_resource_asSIGNments       ra
                 , PA_BUDGET_LINES               bl
                 , pa_projects_all               ppa
                 , pji_pjp_rbs_header            rhdr
                 , PJI_FM_AGGR_DLY_RATES         rates
                 , pji_fp_txn_accum_header       hdr
                 , pa_rbs_txn_accum_map          map
                 , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                 WHERE 1=1
			   AND ra.resource_asSIGNment_id = bl.resource_asSIGNment_id
                     AND ra.project_id = ver.PROJECT_ID
                     AND ra.budget_version_id = ver.plan_version_id
                     AND ver.project_id = ppa.project_id
                     AND txn_currency_code IS NOT NULL
                     AND bl.project_currency_code IS NOT NULL
                     AND bl.projfunc_currency_code IS NOT NULL
			         AND pevs.element_version_id = ver.wbs_struct_version_id
                     AND ver.project_id = pevs.project_id
	 		         AND ver.secondary_rbs_flag = 'Y'
					 AND ver.wp_flag = 'N'
					 AND ver.baselined_flag = 'Y'
					 -- AND oei.org_id = ppa.org_id
					 AND ver.time_phased_type_code = 'N' -- IN (g_pa_cal_str, g_gl_cal_str)
					 AND rates.time_id = DECODE ( g_currency_conversion_rule
                               , g_start_str
					 , TO_NUMBER(to_CHAR(ra.planning_start_date, 'J'))
					 , g_end_str
					 , TO_NUMBER(to_CHAR(ra.planning_end_date, 'J')) )
					 AND rates.pf_currency_code = bl.projfunc_currency_code -- 4764334
                     AND rates.worker_id = g_worker_id
					  AND ra.txn_accum_header_id = hdr.txn_accum_header_id
					  AND ra.txn_accum_header_id = map.txn_accum_header_id
					  AND map.struct_version_id = rhdr.rbs_version_id
					  AND ra.budget_version_id = rhdr.plan_version_id
                             AND rhdr.project_id = ver.project_id
					  AND ppa.project_id = ra.project_id
                                AND ver.rbs_struct_version_id = rhdr.rbs_version_id
					 AND ver.worker_id = g_worker_id
				  ) spread_bl
				   ---- end of third inline view 'spread_bl'...........
            	  ,
            	    (
                      select 1   INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('GLOBAL_CURR1_FLAG') = 'Y' union all /* Added for bug 8708651 */
                      select 2   INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('GLOBAL_CURR2_FLAG') = 'Y' union all
                      select 4   INVERT_ID from dual union all
                      select 8   INVERT_ID from dual union all
                      select 16  INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('TXN_CURR_FLAG') = 'Y'
                    ) invert
				)  collapse_bl
				----  End of second inline view 'collapse_bl' ..........
			GROUP BY
              collapse_bl.PROJECT_ID
			, collapse_bl.time_id
            , collapse_bl.WBS_ELEMENT_ID
            -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
			, collapse_bl.plan_type_id
            , collapse_bl.plan_version_id
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.RESOURCE_ASSIGNMENT_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , collapse_bl.start_date
            , collapse_bl.end_date
            , collapse_bl.row_id
			, collapse_bl.line_type
			, collapse_bl.calendar_type
			, collapse_bl.period_type_id
	    ,collapse_bl.rate
            ,collapse_bl.rate2
            , collapse_bl.plan_type_code
            , collapse_bl.WP_FLAG
       ) plr
				----  End of first inline view plr ..........
	  WHERE 1=1
          -- AND plr.CURR_RECORD_TYPE IS NOT NULL
          AND plr.currency_code IS NOT NULL
       GROUP BY
         plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , plr.time_id
       , plr.period_type_id
       , plr.CALENDAR_TYPE
       , plr.CURR_RECORD_TYPE  -- curr code missing.
  	   , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.plan_version_id
  	 , plr.plan_type_id
       , plr.start_date
  	 , plr.end_date
	 , plr.line_type
	 ,decode(sign(plr.rate),-1,'Y',NULL) ||decode(sign(plr.rate2),-1,'Y',NULL)
        ,plr.plan_type_code   /*4471527 */
  )
 GROUP BY
	 WORKER_ID
	,PROJECT_ID
	,PROJECT_ORG_ID
	,project_ORGANIZATION_ID
	,WBS_ELEMENT_ID
	,time_id
	,period_type_id
	,CALENDAR_TYPE
	,RBS_AGGR_LEVEL
	,WBS_ROLLUP_FLAG
	,PRG_ROLLUP_FLAG
	,CURR_RECORD_TYPE
	,currency_code
	,RBS_ELEMENT_ID
	,RBS_STRUCT_VERSION_ID
	,plan_version_id
	,plan_type_id
        ,LINE_TYPE
        ,rate_dangling_flag
        ,time_dangling_flag
        ,start_date
        ,end_date
        ,prg_level
        , plan_type_code ;   /*4471527 */

  print_time ( ' EXTRACT_PLAN_AMTS_SECRBS_GLC12 end. Inserted rows # is: ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    print_time('EXTRACT_PLAN_AMOUNTS_SECRBS : Exception ' || SQLERRM );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'EXTRACT_PLAN_AMTS_SECRBS_GLC12');
    RAISE;
END;


PROCEDURE EXTRACT_PLAN_AMTS_PRIRBS_GLC12 (
  p_pull_dangling_flag IN VARCHAR2 := 'Y') -- Reversals to be computed only if pull_dangling flag is 'Y'
IS
BEGIN

    print_time ( ' EXTRACT_PLAN_AMTS_PRIRBS_GLC12 begin. ' );

    PJI_PJP_FP_CURR_WRAP.get_global_currency_info (
      x_currency_conversion_rule => g_currency_conversion_rule
    , x_prorating_format         => g_prorating_format
    , x_global1_currency_code    => g_global1_currency_code
    , x_global2_currency_code    => g_global2_currency_code
    , x_global1_currency_mau     => g_global1_currency_mau
    , x_global2_currency_mau     => g_global2_currency_mau ) ;


  print_time(' Got global currency settings. ');
  print_time(' g_currency_conversion_rule ' || g_currency_conversion_rule || ' g_prorating_format ' ||  g_prorating_format );
  print_time(' g_global1_currency_code ' || g_global1_currency_code || ' g_global2_currency_code ' || g_global2_currency_code );
  print_time(' g_global1_currency_mau ' || g_global1_currency_mau || ' g_global2_currency_mau ' || g_global2_currency_mau ) ;

    INSERT INTO PJI_FP_AGGR_PJP1
    (
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , LINE_TYPE
       , RATE_DANGLING_FLAG
       , TIME_DANGLING_FLAG
       , START_DATE
       , END_DATE
       , PRG_LEVEL
       , PLAN_TYPE_CODE   /*4471527 */
	)
    SELECT     /* This select is no more required. Not removing it to minimize impact for nov-11 dhi one off.
                 We can remove it later, to improve performance */
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , project_ORGANIZATION_ID
       , WBS_ELEMENT_ID
       , time_id
       , period_type_id
       , CALENDAR_TYPE
       , g_lowest_level RBS_AGGR_LEVEL
       , 'N' WBS_ROLLUP_FLAG
       , 'N' PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE
       , currency_code
       , RBS_ELEMENT_ID
       , RBS_STRUCT_VERSION_ID
       , plan_version_id
       , plan_type_id
       , decode(rate_dangling_flag,null,SUM(RAW_COST),0)
       , decode(rate_dangling_flag,null,SUM(BRDN_COST),0)
       , decode(rate_dangling_flag,null,SUM(REVENUE),0)
       , decode(rate_dangling_flag,null,SUM ( BILL_RAW_COST ),0)  BILL_RAW_COST
       , decode(rate_dangling_flag,null,SUM (BILL_BRDN_COST ),0)   BILL_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( BILL_LABOR_RAW_COST),0) BILL_LABOR_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( BILL_LABOR_BRDN_COST),0) BILL_LABOR_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( BILL_LABOR_HRS),0) BILL_LABOR_HRS
       , decode(rate_dangling_flag,null,SUM ( EQUIPMENT_RAW_COST),0) EQUIPMENT_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( EQUIPMENT_BRDN_COST),0) EQUIPMENT_BRDN_COST
       , decode(rate_dangling_flag,null,SUM (CAPITALIZABLE_RAW_COST),0) CAPITALIZABLE_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( CAPITALIZABLE_BRDN_COST),0)
       , decode(rate_dangling_flag,null,SUM ( LABOR_RAW_COST),0) LABOR_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( LABOR_BRDN_COST),0) LABOR_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( labor_hrs),0)  labor_hrs
       , decode(rate_dangling_flag,null,SUM (LABOR_REVENUE),0)  LABOR_REVENUE
       , decode(rate_dangling_flag,null,SUM (EQUIPMENT_HOURS),0) EQUIPMENT_HOURS
       , decode(rate_dangling_flag,null,SUM ( BILLABLE_EQUIPMENT_HOURS),0) BILLABLE_EQUIPMENT_HOURS
       , decode(rate_dangling_flag,null,SUM(SUP_INV_COMMITTED_COST),0) SUP_INV_COMMITTED_COST
       , decode(rate_dangling_flag,null,SUM(PO_COMMITTED_COST),0) PO_COMMITTED_COST
       , decode(rate_dangling_flag,null,SUM(PR_COMMITTED_COST),0) PR_COMMITTED_COST
       , decode(rate_dangling_flag,null,SUM(OTH_COMMITTED_COST),0) PR_COMMITTED_COST
       , decode(rate_dangling_flag,null,SUM ( ACT_LABOR_HRS),0) ACT_LABOR_HRS
       , decode(rate_dangling_flag,null,SUM (ACT_EQUIP_HOURS),0) ACT_EQUIP_HOURS
       , decode(rate_dangling_flag,null,SUM ( ACT_LABOR_BRDN_COST),0) ACT_LABOR_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( ACT_EQUIPMENT_BRDN_COST),0) ACT_EQUIPMENT_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( ACT_BRDN_COST),0) ACT_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( ACT_RAW_COST),0) ACT_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( ACT_REVENUE),0) ACT_REVENUE
       , decode(rate_dangling_flag,null,SUM ( ACT_LABOR_RAW_COST),0) ACT_LABOR_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( ACT_EQUIPMENT_RAW_COST),0) ACT_EQUIPMENT_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( ETC_LABOR_HRS),0) ETC_LABOR_HRS
       , decode(rate_dangling_flag,null,SUM ( ETC_EQUIP_HOURS),0) ETC_EQUIP_HOURS
       , decode(rate_dangling_flag,null,SUM ( ETC_LABOR_BRDN_COST),0) ETC_LABOR_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( ETC_EQUIP_BRDN_COST),0) ETC_EQUIP_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( ETC_BRDN_COST),0) ETC_BRDN_COST
       , decode(rate_dangling_flag,null,SUM ( ETC_RAW_COST),0) ETC_RAW_COST
       , decode(rate_dangling_flag,null,SUM ( ETC_LABOR_raw_COST),0) ETC_LABOR_raw_COST
       , decode(rate_dangling_flag,null,SUM ( ETC_EQUIP_raw_COST),0) ETC_EQUIP_raw_COST
       , decode(rate_dangling_flag,null,SUM(CUSTOM1),0) CUSTOM1
       , decode(rate_dangling_flag,null,SUM(CUSTOM2),0) CUSTOM2
       , decode(rate_dangling_flag,null,SUM(CUSTOM3),0) CUSTOM3
       , decode(rate_dangling_flag,null,SUM(CUSTOM4),0) CUSTOM4
       , decode(rate_dangling_flag,null,SUM(CUSTOM5),0) CUSTOM5
       , decode(rate_dangling_flag,null,SUM(CUSTOM6),0) CUSTOM6
       , decode(rate_dangling_flag,null,SUM(CUSTOM7),0) CUSTOM7
       , decode(rate_dangling_flag,null,SUM(CUSTOM8),0) CUSTOM8
       , decode(rate_dangling_flag,null,SUM(CUSTOM9),0) CUSTOM9
       , decode(rate_dangling_flag,null,SUM(CUSTOM10),0) CUSTOM10
       , decode(rate_dangling_flag,null,SUM(CUSTOM11),0) CUSTOM11
       , decode(rate_dangling_flag,null,SUM(CUSTOM12),0) CUSTOM12
       , decode(rate_dangling_flag,null,SUM(CUSTOM13),0) CUSTOM13
       , decode(rate_dangling_flag,null,SUM(CUSTOM14),0) CUSTOM14
       , decode(rate_dangling_flag,null,SUM(CUSTOM15),0) CUSTOM15
       , LINE_TYPE
       , rate_dangling_flag
       , time_dangling_flag
       , start_date
       , end_date
       , g_default_prg_level  prg_level
       , plan_type_code
 FROM
       (   SELECT
         g_worker_id WORKER_ID
       , plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , plr.time_id
       , plr.period_type_id -- period type id...
       , plr.CALENDAR_TYPE
       , g_lowest_level RBS_AGGR_LEVEL
       , 'N' WBS_ROLLUP_FLAG
       , 'N' PRG_ROLLUP_FLAG
       , plr.CURR_RECORD_TYPE
       , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.plan_version_id
       , plr.plan_type_id
       , SUM(plr.RAW_COST)  RAW_COST
       , SUM(plr.BRDN_COST) BRDN_COST
       , SUM(plr.REVENUE)  REVENUE
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )  BILL_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )   BILL_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_people_resclass_code, plr.raw_cost, 0 ) )  BILL_LABOR_RAW_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_people_resclass_code , plr.BRDN_COST, 0 ) )   BILL_LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'Y' || g_people_resclass_code, plr.quantity, 0 ) )  BILL_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'Y' || g_people_resclass_code,
                                             DECODE ( plr.billable_flag , 'Y' , plr.quantity, 0 ) , 0 ) )  BILL_LABOR_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.raw_cost, 0 ) )  EQUIPMENT_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code , plr.BRDN_COST, 0 ) )   EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )      CAPITALIZABLE_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )      CAPITALIZABLE_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.raw_cost, 0 ) )  LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.BRDN_COST, 0 ) )   LABOR_BRDN_COST
       /* , SUM ( DECODE ( plr.resource_class, g_people_resclass_code,
                                            DECODE ( plr.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
                                                    0 ) )   labor_hrs */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, DECODE( plr.billable_flag , 'Y',
                                            DECODE ( plr.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
						    0 ),
                                                    0 ) )   labor_hrs -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_people_resclass_code, plr.revenue, 0 ) )  LABOR_REVENUE
       /* , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code,
                                            DECODE ( plr.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),

                                            0 ) )  EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, g_equip_resclass_code, DECODE( plr.billable_flag , 'Y',
                                            DECODE ( plr.wp_flag, 'N',
                                                                   DECODE ( plr.billable_flag, 'Y',plr.quantity,0),
                                                                   plr.quantity),
				            0 ),
                                            0 ) )  EQUIPMENT_HOURS -- bug 6039785
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_equip_resclass_code, plr.quantity, 0 ) )  BILLABLE_EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'Y' || g_equip_resclass_code,
                                                                 DECODE ( plr.billable_flag , 'Y' , plr.quantity, 0 ) , 0 ) )  BILLABLE_EQUIPMENT_HOURS -- bug 6039785
       , TO_NUMBER(NULL)  SUP_INV_COMMITTED_COST
       , TO_NUMBER(NULL)  PO_COMMITTED_COST
       , TO_NUMBER(NULL)  PR_COMMITTED_COST
       , TO_NUMBER(NULL)  OTH_COMMITTED_COST
       /* , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                                0 ) ) ) ACT_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                             DECODE (plr.billable_flag ,'Y',
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
										0 ),
                                                                                0 ) ) ) ACT_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
                                                                                0 ) ) ) ACT_EQUIP_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                             DECODE (plr.billable_flag ,'Y',
                                                                                DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,0),
										0 ),
                                                                                0 ) ) ) ACT_EQUIP_HOURS -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.actual_BRDN_COST, 0 ) ) ) ACT_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.actual_BRDN_COST, 0 ) ) ) ACT_EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.actual_brdn_cost ) ) ACT_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.actual_raw_cost ) ) ACT_RAW_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.actual_revenue ) ) ACT_REVENUE
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.actual_RAW_COST, 0 ) ) ) ACT_LABOR_RAW_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.actual_RAW_COST, 0 ) ) ) ACT_EQUIPMENT_RAW_COST
       /* , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ) ) ) ETC_LABOR_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ),
                                                                                0 ) ) ) ETC_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ) ) ) ETC_EQUIP_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code,
                                                                                DECODE (plr.billable_flag ,'Y',
                                                                                        DECODE ( plr.billable_flag, 'Y',plr.ETC_quantity,0),
                                                                                0 ),
                                                                                0 ) ) ) ETC_EQUIP_HOURS -- bug 6039785
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.etc_BRDN_COST, 0 ) ) ) ETC_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.etc_BRDN_COST, 0 ) ) ) ETC_EQUIP_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.etc_brdn_cost ) ) ETC_BRDN_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, plr.etc_raw_cost ) ) ETC_RAW_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_people_resclass_code, plr.etc_raw_COST, 0 ) ) ) ETC_LABOR_raw_COST
       , SUM ( DECODE ( plr.wp_flag, 'Y', NULL, DECODE ( plr.resource_class, g_equip_resclass_code , plr.etc_raw_COST, 0 ) ) ) ETC_EQUIP_raw_COST
       , TO_NUMBER(NULL) CUSTOM1
       , TO_NUMBER(NULL) CUSTOM2
       , TO_NUMBER(NULL) CUSTOM3
       , TO_NUMBER(NULL) CUSTOM4
       , TO_NUMBER(NULL) CUSTOM5
       , TO_NUMBER(NULL) CUSTOM6
       , TO_NUMBER(NULL) CUSTOM7
       , TO_NUMBER(NULL) CUSTOM8
       , TO_NUMBER(NULL) CUSTOM9
       , TO_NUMBER(NULL) CUSTOM10
       , TO_NUMBER(NULL) CUSTOM11
       , TO_NUMBER(NULL) CUSTOM12
       , TO_NUMBER(NULL) CUSTOM13
       , TO_NUMBER(NULL) CUSTOM14
       , TO_NUMBER(NULL) CUSTOM15
       , plr.LINE_TYPE
       , decode(sign(plr.rate),-1,'Y',NULL) ||decode(sign(plr.rate2),-1,'Y',NULL) rate_dangling_flag
       , NULL time_dangling_flag
       , plr.start_date
  	 , plr.end_date
       , g_default_prg_level prg_level
       ,plr.plan_type_code plan_type_code  /*4471527 */
       FROM
       (          ----- First inline view plr .............
            select
              collapse_bl.PROJECT_ID      -- , 1 partition_id
            , collapse_bl.WBS_ELEMENT_ID  -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , SUM(collapse_bl.CURR_RECORD_TYPE_ID) CURR_RECORD_TYPE
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
		    , collapse_bl.plan_type_id
            , collapse_bl.plan_version_id
			, collapse_bl.time_id
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.RESOURCE_ASSIGNMENT_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS  -- , CALENDAR_TYPE -- , CALENDAR_ID
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , max(collapse_bl.raw_cost) raw_cost
            , max(collapse_bl.BRDN_COST) BRDN_COST
            , max(collapse_bl.revenue) revenue
            , max(collapse_bl.actual_raw_cost) actual_raw_cost
            , max(collapse_bl.actual_BRDN_COST) actual_BRDN_COST
            , max(collapse_bl.actual_revenue) actual_revenue
            , max(collapse_bl.etc_raw_cost) etc_raw_cost
            , max(collapse_bl.etc_BRDN_COST) etc_BRDN_COST
            , max(collapse_bl.etc_revenue) etc_revenue
            , max(collapse_bl.quantity) quantity
            , max(collapse_bl.actual_quantity) actual_quantity
            , max(collapse_bl.etc_quantity) etc_quantity
            , collapse_bl.start_date start_date
            , collapse_bl.end_date   end_date
            -- , collapse_bl.period_name period_name  -- , TRACK_AS_LABOR_FLAG track_as_labor_flag
			, collapse_bl.line_type
			, collapse_bl.calendar_type
			, collapse_bl.period_type_id
            , collapse_bl.row_id
	    ,collapse_bl.rate rate
	    ,collapse_bl.rate2 rate2
            , collapse_bl.plan_type_code plan_type_code
            , collapse_bl.WP_FLAG
            from
              (                  ----- Second inline view 'collapse_bl' begin .............
               select
                  spread_bl.row_id row_id
                , spread_bl.PROJECT_ID
                , spread_bl.BUDGET_VERSION_ID plan_version_id
				, spread_bl.time_id
                , spread_bl.RESOURCE_ASSIGNMENT_ID
                , spread_bl.WBS_ELEMENT_ID
                , spread_bl.RBS_ELEMENT_ID
                , spread_bl.WBS_STRUCT_VERSION_ID
                , spread_bl.RBS_STRUCT_VERSION_ID
  	 	        , spread_bl.plan_type_id
                , spread_bl.BILLABLE_FLAG
                , spread_bl.RESOURCE_CLASS
                , spread_bl.PROJECT_ORGANIZATION_ID
                , spread_bl.PROJECT_ORG_ID
                , spread_bl.TIME_PHASED_TYPE_CODE
                , DECODE( invert.INVERT_ID
                        , 1, spread_bl.glb1_CURRENCY_CODE
                        , 2, spread_bl.glb2_CURRENCY_CODE
                        , 4, spread_bl.func_CURRENCY_CODE
                        , 8, spread_bl.PRJ_CURRENCY_CODE
                        , 16, spread_bl.TXN_CURRENCY_CODE ) CURRENCY_CODE
                , invert.INVERT_ID CURR_RECORD_TYPE_ID
                , DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_raw_cost
                         , 2, spread_bl.glb2_raw_cost
                         , 4, spread_bl.func_raw_cost
                         , 8, spread_bl.PRJ_raw_cost
                         , 16, spread_bl.TXN_raw_cost) raw_cost
                , DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_brdn_cost
                         , 2, spread_bl.glb2_brdn_cost
                         , 4, spread_bl.func_BRDN_COST
                         , 8, spread_bl.PRJ_BRDN_COST
                         , 16, spread_bl.TXN_BRDN_COST ) BRDN_COST
                , DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_revenue
                         , 2, spread_bl.glb2_revenue
                         , 4, spread_bl.func_revenue
                         , 8, spread_bl.PRJ_revenue
                         , 16, spread_bl.TXN_revenue ) revenue
				, DECODE ( invert.INVERT_ID
                         , 1, spread_bl.glb1_actual_raw_cost
                         , 2, spread_bl.glb2_actual_raw_cost
				         , 4, spread_bl.func_actual_raw_cost
						 , 8, spread_bl.prj_actual_raw_cost
						 , 16, spread_bl.txn_actual_raw_cost ) actual_raw_cost
				, DECODE ( invert.INVERT_ID
				         , 1, spread_bl.glb1_actual_brdn_cost
						 , 2, spread_bl.glb2_actual_brdn_cost
				         , 4, spread_bl.func_actual_brdn_cost
						 , 8, spread_bl.prj_actual_brdn_cost
						 , 16, spread_bl.txn_actual_brdn_cost ) actual_brdn_cost
				, DECODE ( invert.INVERT_ID
				         , 1, spread_bl.glb1_actual_revenue
						 , 2, spread_bl.glb2_actual_revenue
				         , 4, spread_bl.func_actual_revenue
						 , 8, spread_bl.prj_actual_revenue
						 , 16, spread_bl.txn_actual_revenue ) actual_revenue
				, DECODE ( invert.INVERT_ID
				         , 1, spread_bl.glb1_etc_raw_cost
						 , 2, spread_bl.glb2_etc_raw_cost
				         , 4, spread_bl.func_etc_raw_cost
						 , 8, spread_bl.prj_etc_raw_cost
						 , 16, spread_bl.txn_etc_raw_cost ) etc_raw_cost
				, DECODE ( invert.INVERT_ID
				         , 1, spread_bl.glb1_etc_brdn_cost
						 , 2, spread_bl.glb2_etc_brdn_cost
				         , 4, spread_bl.func_etc_brdn_cost
						 , 8, spread_bl.prj_etc_brdn_cost
						 , 16, spread_bl.txn_etc_brdn_cost ) etc_brdn_cost
				, DECODE ( invert.INVERT_ID
				         , 1, spread_bl.glb1_etc_revenue
						 , 2, spread_bl.glb2_etc_revenue
				         , 4, spread_bl.func_etc_revenue
						 , 8, spread_bl.prj_etc_revenue
						 , 16, spread_bl.txn_etc_revenue ) etc_revenue
            	, spread_bl.quantity quantity
            	, spread_bl.actual_quantity actual_quantity
            	, spread_bl.etc_quantity etc_quantity
            	, spread_bl.start_date start_date
            	, spread_bl.end_date   end_date
            	, spread_bl.line_type line_type
				, spread_bl.period_type_id
				, spread_bl.calendar_type
 		,decode(invert.invert_id,1,spread_bl.rate,1) rate
 		,decode(invert.invert_id,2,spread_bl.rate2,1) rate2
                            , spread_bl.plan_type_code plan_type_code   /*4471527 */
                , spread_bl.WP_FLAG
                from
                  (     ----- Third inline view 'spread_bl'  .............
                    SELECT /*+ ordered */
                	  ra.project_id
                	, bl.rowid row_id
                	, ra.budget_version_id
					, prd.cal_period_id time_id
                	, bl.resource_asSIGNment_id
                	, DECODE(ra.task_id, 0, pevs.proj_element_id, ra.task_id) wbs_element_id
                	, NVL(ra.rbs_element_id, -1)              rbs_element_id
                	, ver.wbs_struct_version_id      wbs_struct_version_id
                	, NVL(ver.rbs_struct_version_id, -1)    rbs_struct_version_id
			, ver.plan_type_id               plan_type_id
			, ra.rate_based_flag             billable_flag
			, ra.resource_class_code         resource_class
			, DECODE(ver.time_phased_type_code
               , g_pa_cal_str, 32
               , g_gl_cal_str, 32
               , 'N', 2048
               , -1) period_type_id
			   , DECODE(ver.time_phased_type_code
               , g_pa_cal_str, g_pa_cal_str
               , g_gl_cal_str, g_gl_cal_str
               , 'N', g_all
               , 'X')  CALENDAR_TYPE
                	, bl.txn_currency_code           txn_currency_code
                	, bl.txn_raw_cost                txn_raw_cost
                	, bl.txn_burdened_COST           txn_brdn_COST
                	, bl.txn_revenue                 txn_revenue
			, DECODE(ver.wp_flag, 'N', bl.txn_init_raw_cost, TO_NUMBER(NULL))                txn_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.txn_init_burdened_cost, TO_NUMBER(NULL))             txn_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.txn_init_revenue, TO_NUMBER(NULL))                   txn_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N', (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0)), TO_NUMBER(NULL)) txn_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0)), TO_NUMBER(NULL)) txn_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.txn_revenue - NVL(bl.txn_init_revenue, 0)), TO_NUMBER(NULL)) txn_etc_revenue     -- new
                	, bl.project_currency_code          prj_currency_code
                	, bl.project_raw_cost               prj_raw_cost
                	, bl.project_burdened_COST          prj_BRDN_COST
                	, bl.project_revenue                prj_revenue
			, DECODE(ver.wp_flag, 'N', bl.project_init_raw_cost, TO_NUMBER(NULL))          prj_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.project_init_burdened_cost, TO_NUMBER(NULL))     prj_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.project_init_revenue, TO_NUMBER(NULL))           prj_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N', (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0)), TO_NUMBER(NULL)) prj_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0)), TO_NUMBER(NULL)) prj_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.project_revenue - NVL(bl.project_init_revenue, 0)), TO_NUMBER(NULL)) prj_etc_revenue     -- new
                	, bl.projfunc_currency_code         func_currency_code
                  , bl.raw_cost                       func_raw_cost
                	, bl.burdened_COST                  func_BRDN_COST
                	, bl.revenue                        func_revenue
			, DECODE(ver.wp_flag, 'N', bl.init_raw_cost , TO_NUMBER(NULL))                 func_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.init_burdened_cost , TO_NUMBER(NULL))            func_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N', bl.init_revenue , TO_NUMBER(NULL))                  func_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N', (bl.raw_cost - NVL(bl.init_raw_cost, 0)), TO_NUMBER(NULL)) func_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)), TO_NUMBER(NULL)) func_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N', (bl.revenue - NVL(bl.init_revenue, 0)), TO_NUMBER(NULL)) func_etc_revenue     -- new
                	, g_global1_currency_code  glb1_currency_code -- g_global1_currency_code        glb1_currency_code
                  , DECODE (g_global1_currency_code
				          , bl.txn_currency_code
						  , bl.txn_raw_cost
						  , bl.project_currency_code
						  , bl.project_raw_cost
						  , bl.projfunc_currency_code
						  , bl.raw_cost
						  , ROUND((rates.rate * raw_cost )/rates.mau)*rates.mau
					) glb1_raw_cost
                  , DECODE (g_global1_currency_code
				          , bl.txn_currency_code
						  , bl.txn_burdened_cost
						  , bl.project_currency_code
						  , bl.project_burdened_cost
						  , bl.projfunc_currency_code
						  , bl.burdened_cost
						  , ROUND((rates.rate * burdened_cost )/rates.mau)*rates.mau
					) glb1_BRDN_COST
                  , DECODE (g_global1_currency_code
				          , bl.txn_currency_code
						  , bl.txn_revenue
						  , bl.project_currency_code
						  , bl.project_revenue
						  , bl.projfunc_currency_code
						  , bl.revenue
						  , ROUND((rates.rate * revenue )/rates.mau)*rates.mau
					)  glb1_revenue
			      , DECODE(ver.wp_flag
			             , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_raw_cost
						         , bl.project_currency_code
						         , bl.project_init_raw_cost
						         , bl.projfunc_currency_code
						         , bl.init_raw_cost
						         , ROUND((rates.rate * bl.init_raw_cost )/rates.mau)*rates.mau
					              )
						 , NULL)                 glb1_actual_raw_cost
   			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_burdened_cost
						         , bl.project_currency_code
						         , bl.project_init_burdened_cost
						         , bl.projfunc_currency_code
						         , bl.init_burdened_cost
						         , ROUND((rates.rate * bl.init_burdened_cost )/rates.mau)*rates.mau
					              )
						 , NULL)            glb1_actual_brdn_cost
			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_revenue
						         , bl.project_currency_code
						         , bl.project_init_revenue
						         , bl.projfunc_currency_code
						         , bl.init_revenue
						         , ROUND((rates.rate * bl.init_revenue )/rates.mau)*rates.mau
					              )
						 , NULL)                  glb1_actual_revenue
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
						         , ROUND((rates.rate * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau)*rates.mau
					              )
						 , NULL)                glb1_etc_raw_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
						         , ROUND((rates.rate * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau)*rates.mau
					              )
						 , NULL)    glb1_etc_brdn_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
						         , bl.project_currency_code
						         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
						         , bl.projfunc_currency_code
						         , (bl.revenue - NVL(bl.init_revenue, 0))
						         , ROUND((rates.rate * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau)*rates.mau
					              )
						 , NULL)    glb1_etc_revenue
                	, g_global2_currency_code  glb2_currency_code -- g_global2_currency_code        glb2_currency_code
                  , DECODE (g_global2_currency_code
				          , bl.txn_currency_code
						  , bl.txn_raw_cost
						  , bl.project_currency_code
						  , bl.project_raw_cost
						  , bl.projfunc_currency_code
						  , bl.raw_cost
						  , ROUND((rates.rate2 * raw_cost )/rates.mau2)*rates.mau2
					) glb2_raw_cost
                  , DECODE (g_global2_currency_code
				          , bl.txn_currency_code
						  , bl.txn_burdened_cost
						  , bl.project_currency_code
						  , bl.project_burdened_cost
						  , bl.projfunc_currency_code
						  , bl.burdened_cost
						  , ROUND((rates.rate2 * burdened_cost )/rates.mau2)*rates.mau2
					) glb2_BRDN_COST
                  , DECODE (g_global2_currency_code
				          , bl.txn_currency_code
						  , bl.txn_revenue
						  , bl.project_currency_code
						  , bl.project_revenue
						  , bl.projfunc_currency_code
						  , bl.revenue
						  , ROUND((rates.rate2 * revenue )/rates.mau2)*rates.mau2
					)  glb2_revenue
			      , DECODE(ver.wp_flag
			             , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_raw_cost
						         , bl.project_currency_code
						         , bl.project_init_raw_cost
						         , bl.projfunc_currency_code
						         , bl.init_raw_cost
						         , ROUND((rates.rate2 * bl.init_raw_cost )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))                 glb2_actual_raw_cost
   			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_burdened_cost
						         , bl.project_currency_code
						         , bl.project_init_burdened_cost
						         , bl.projfunc_currency_code
						         , bl.init_burdened_cost
						         , ROUND((rates.rate2 * bl.init_burdened_cost )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))            glb2_actual_brdn_cost
			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_revenue
						         , bl.project_currency_code
						         , bl.project_init_revenue
						         , bl.projfunc_currency_code
						         , bl.init_revenue
						         , ROUND((rates.rate2 * bl.init_revenue )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))                  glb2_actual_revenue
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
						         , ROUND((rates.rate2 * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))                glb2_etc_raw_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
						         , ROUND((rates.rate2 * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))    glb2_etc_brdn_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
						         , bl.project_currency_code
						         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
						         , bl.projfunc_currency_code
						         , (bl.revenue - NVL(bl.init_revenue, 0))
						         , ROUND((rates.rate2 * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))    glb2_etc_revenue
                  , bl.quantity                    quantity
			, DECODE(ver.wp_flag, 'N', bl.init_quantity, TO_NUMBER(NULL))                  actual_quantity  -- new
			, DECODE(ver.wp_flag, 'N', (bl.quantity - NVL(bl.init_quantity, 0)), TO_NUMBER(NULL)) etc_quantity  -- new
                	, TO_DATE(NULL) start_date -- bl.start_date
                	, TO_DATE(NULL) end_date -- bl.END_date
                	, ver.time_phased_type_code time_phased_type_code
                	, ppa.org_id project_org_id
                	, ppa.carrying_out_organization_id project_organization_id
					, DECODE(ver.time_phased_type_code, g_pa_cal_str, 'OF', g_gl_cal_str, 'OF', 'N', 'NTP', 'X') line_type
 			,decode(ver.rate_dangling_flag,'Y',-1,1) rate
 			,decode(ver.rate_dangling_flag,'Y',-1,1) rate2
                               , ver.plan_type_code plan_type_code   /*4471527 */
                        , ver.WP_FLAG
				 FROM
                   PJI_FM_EXTR_PLNVER4           ver
                 , pa_resource_asSIGNments       ra
                 , PA_BUDGET_LINES               bl
                 , pa_projects_all               ppa
                 , PJI_ORG_EXTR_INFO             oei
                 , pji_time_cal_period_v         prd
                 , PJI_FM_AGGR_DLY_RATES         rates
                 , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                 WHERE 1=1
				     AND ra.resource_asSIGNment_id = bl.resource_asSIGNment_id
                     AND ra.project_id = ver.PROJECT_ID
                     AND ra.budget_version_id = ver.plan_version_id
                     AND ver.project_id = ppa.project_id
                     AND txn_currency_code IS NOT NULL
                     AND bl.project_currency_code IS NOT NULL
                     AND bl.projfunc_currency_code IS NOT NULL
			         AND pevs.element_version_id = ver.wbs_struct_version_id
                     AND ver.project_id = pevs.project_id
	 		         AND ver.secondary_rbs_flag = 'N'
					 AND ver.wp_flag = 'N'
					 AND ver.baselined_flag = 'Y'
					 AND oei.org_id = ppa.org_id
					 AND ver.time_phased_type_code IN (g_pa_cal_str, g_gl_cal_str)
					 AND DECODE ( ver.time_phased_type_code
					            , g_pa_cal_str, oei.pa_calendar_id
								, g_gl_cal_str, oei.gl_calendar_id) = prd.calendar_id
					 AND bl.period_name = prd.name
					 AND rates.time_id = prd.cal_period_id
					 AND rates.worker_id = g_worker_id
					 AND rates.pf_currency_code = bl.projfunc_currency_code -- 4764334
					 AND ver.worker_id = g_worker_id
                UNION ALL
                    SELECT /*+ ordered */
                	  ra.project_id
                	, bl.rowid row_id
                	, ra.budget_version_id
					, -1 time_id
                	, bl.resource_asSIGNment_id
                	, DECODE(ra.task_id, 0, pevs.proj_element_id, ra.task_id) wbs_element_id
                	, NVL(ra.rbs_element_id, -1)              rbs_element_id
                	, ver.wbs_struct_version_id      wbs_struct_version_id
                	, NVL(ver.rbs_struct_version_id, -1)    rbs_struct_version_id
			, ver.plan_type_id               plan_type_id
			, ra.rate_based_flag             billable_flag
			, ra.resource_class_code         resource_class
			, 2048 period_type_id
			   , g_all CALENDAR_TYPE
                	, bl.txn_currency_code           txn_currency_code
                	, bl.txn_raw_cost                txn_raw_cost
                	, bl.txn_burdened_COST           txn_brdn_COST
                	, bl.txn_revenue                 txn_revenue
			, DECODE(ver.wp_flag, 'N' , bl.txn_init_raw_cost, TO_NUMBER(NULL))                txn_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N' , bl.txn_init_burdened_cost, TO_NUMBER(NULL))             txn_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N' , bl.txn_init_revenue, TO_NUMBER(NULL))                   txn_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N' , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0)), TO_NUMBER(NULL)) txn_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N' , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0)), TO_NUMBER(NULL)) txn_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N' , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0)), TO_NUMBER(NULL)) txn_etc_revenue     -- new
                	, bl.project_currency_code          prj_currency_code
                	, bl.project_raw_cost               prj_raw_cost
                	, bl.project_burdened_COST          prj_BRDN_COST
                	, bl.project_revenue                prj_revenue
			, DECODE(ver.wp_flag, 'N' , bl.project_init_raw_cost, TO_NUMBER(NULL))          prj_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N' , bl.project_init_burdened_cost, TO_NUMBER(NULL))     prj_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N' , bl.project_init_revenue, TO_NUMBER(NULL))           prj_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N' , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0)), TO_NUMBER(NULL)) prj_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N' , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0)), TO_NUMBER(NULL)) prj_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N' , (bl.project_revenue - NVL(bl.project_init_revenue, 0)), TO_NUMBER(NULL)) prj_etc_revenue     -- new
                	, bl.projfunc_currency_code         func_currency_code
                  , bl.raw_cost                       func_raw_cost
                	, bl.burdened_COST                  func_BRDN_COST
                	, bl.revenue                        func_revenue
			, DECODE(ver.wp_flag, 'N' , bl.init_raw_cost , TO_NUMBER(NULL))                 func_actual_raw_cost  -- new
			, DECODE(ver.wp_flag, 'N' , bl.init_burdened_cost , TO_NUMBER(NULL))            func_actual_brdn_cost  -- new
			, DECODE(ver.wp_flag, 'N' , bl.init_revenue , TO_NUMBER(NULL))                  func_actual_revenue  -- new
			, DECODE(ver.wp_flag, 'N' , (bl.raw_cost - NVL(bl.init_raw_cost, 0)), TO_NUMBER(NULL)) func_etc_raw_cost     -- new
			, DECODE(ver.wp_flag, 'N' , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)), TO_NUMBER(NULL)) func_etc_brdn_cost     -- new
			, DECODE(ver.wp_flag, 'N' , (bl.revenue - NVL(bl.init_revenue, 0)), TO_NUMBER(NULL)) func_etc_revenue     -- new
                	, g_global1_currency_code   glb1_currency_code -- g_global1_currency_code         glb1_currency_code
                  , DECODE (g_global1_currency_code
				          , bl.txn_currency_code
						  , bl.txn_raw_cost
						  , bl.project_currency_code
						  , bl.project_raw_cost
						  , bl.projfunc_currency_code
						  , bl.raw_cost
						  , ROUND((rates.rate * raw_cost )/rates.mau)*rates.mau
					) glb1_raw_cost
                  , DECODE (g_global1_currency_code
				          , bl.txn_currency_code
						  , bl.txn_burdened_cost
						  , bl.project_currency_code
						  , bl.project_burdened_cost
						  , bl.projfunc_currency_code
						  , bl.burdened_cost
						  , ROUND((rates.rate * burdened_cost )/rates.mau)*rates.mau
					) glb1_BRDN_COST
                  , DECODE (g_global1_currency_code
				          , bl.txn_currency_code
						  , bl.txn_revenue
						  , bl.project_currency_code
						  , bl.project_revenue
						  , bl.projfunc_currency_code
						  , bl.revenue
						  , ROUND((rates.rate * revenue )/rates.mau)*rates.mau
					)  glb1_revenue
			      , DECODE(ver.wp_flag
			             , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_raw_cost
						         , bl.project_currency_code
						         , bl.project_init_raw_cost
						         , bl.projfunc_currency_code
						         , bl.init_raw_cost
						         , ROUND((rates.rate * bl.init_raw_cost )/rates.mau)*rates.mau
					              )
						 , NULL)                 glb1_actual_raw_cost
   			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_burdened_cost
						         , bl.project_currency_code
						         , bl.project_init_burdened_cost
						         , bl.projfunc_currency_code
						         , bl.init_burdened_cost
						         , ROUND((rates.rate * bl.init_burdened_cost )/rates.mau)*rates.mau
					              )
						 , NULL)            glb1_actual_brdn_cost
			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_revenue
						         , bl.project_currency_code
						         , bl.project_init_revenue
						         , bl.projfunc_currency_code
						         , bl.init_revenue
						         , ROUND((rates.rate * bl.init_revenue )/rates.mau)*rates.mau
					              )
						 , NULL)                  glb1_actual_revenue
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
						         , ROUND((rates.rate * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau)*rates.mau
					              )
						 , NULL)                glb1_etc_raw_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
						         , ROUND((rates.rate * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau)*rates.mau
					              )
						 , NULL)    glb1_etc_brdn_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global1_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
						         , bl.project_currency_code
						         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
						         , bl.projfunc_currency_code
						         , (bl.revenue - NVL(bl.init_revenue, 0))
						         , ROUND((rates.rate * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau)*rates.mau
					              )
						 , NULL)    glb1_etc_revenue
                	, g_global2_currency_code   glb2_currency_code -- g_global2_currency_code         glb2_currency_code
                  , DECODE (g_global2_currency_code
				          , bl.txn_currency_code
						  , bl.txn_raw_cost
						  , bl.project_currency_code
						  , bl.project_raw_cost
						  , bl.projfunc_currency_code
						  , bl.raw_cost
						  , ROUND((rates.rate2 * raw_cost )/rates.mau2)*rates.mau2
					) glb2_raw_cost
                  , DECODE (g_global2_currency_code
				          , bl.txn_currency_code
						  , bl.txn_burdened_cost
						  , bl.project_currency_code
						  , bl.project_burdened_cost
						  , bl.projfunc_currency_code
						  , bl.burdened_cost
						  , ROUND((rates.rate2 * burdened_cost )/rates.mau2)*rates.mau2
					) glb2_BRDN_COST
                  , DECODE (g_global2_currency_code
				          , bl.txn_currency_code
						  , bl.txn_revenue
						  , bl.project_currency_code
						  , bl.project_revenue
						  , bl.projfunc_currency_code
						  , bl.revenue
						  , ROUND((rates.rate2 * revenue )/rates.mau2)*rates.mau2
					)  glb2_revenue
			      , DECODE(ver.wp_flag
			             , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_raw_cost
						         , bl.project_currency_code
						         , bl.project_init_raw_cost
						         , bl.projfunc_currency_code
						         , bl.init_raw_cost
						         , ROUND((rates.rate2 * bl.init_raw_cost )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))                 glb2_actual_raw_cost
   			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_burdened_cost
						         , bl.project_currency_code
						         , bl.project_init_burdened_cost
						         , bl.projfunc_currency_code
						         , bl.init_burdened_cost
						         , ROUND((rates.rate2 * bl.init_burdened_cost )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))            glb2_actual_brdn_cost
			      , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , bl.txn_init_revenue
						         , bl.project_currency_code
						         , bl.project_init_revenue
						         , bl.projfunc_currency_code
						         , bl.init_revenue
						         , ROUND((rates.rate2 * bl.init_revenue )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))                  glb2_actual_revenue
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_raw_cost - NVL(bl.txn_init_raw_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_raw_cost - NVL(bl.project_init_raw_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.raw_cost - NVL(bl.init_raw_cost, 0))
						         , ROUND((rates.rate2 * (bl.raw_cost - NVL(bl.init_raw_cost, 0)) )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))                glb2_etc_raw_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_burdened_cost - NVL(bl.txn_init_burdened_cost, 0))
						         , bl.project_currency_code
						         , (bl.project_burdened_cost - NVL(bl.project_init_burdened_cost, 0))
						         , bl.projfunc_currency_code
						         , (bl.burdened_cost - NVL(bl.init_burdened_cost, 0))
						         , ROUND((rates.rate2 * (bl.burdened_cost - NVL(bl.init_burdened_cost, 0)) )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))    glb2_etc_brdn_cost
				  , DECODE(ver.wp_flag
				         , 'N'
						 , DECODE (g_global2_currency_code
				                 , bl.txn_currency_code
						         , (bl.txn_revenue - NVL(bl.txn_init_revenue, 0))
						         , bl.project_currency_code
						         , (bl.project_revenue - NVL(bl.project_init_revenue, 0))
						         , bl.projfunc_currency_code
						         , (bl.revenue - NVL(bl.init_revenue, 0))
						         , ROUND((rates.rate2 * (bl.revenue - NVL(bl.init_revenue, 0)) )/rates.mau2)*rates.mau2
					              )
						 , TO_NUMBER(NULL))    glb2_etc_revenue
                  , bl.quantity                    quantity
			, DECODE(ver.wp_flag, 'N' , bl.init_quantity, TO_NUMBER(NULL))                  actual_quantity  -- new
			, DECODE(ver.wp_flag, 'N' , (bl.quantity - NVL(bl.init_quantity, 0)), TO_NUMBER(NULL)) etc_quantity  -- new
                	, ra.planning_start_date
                	, ra.planning_END_date
                	, ver.time_phased_type_code time_phased_type_code
                	, ppa.org_id project_org_id
                	, ppa.carrying_out_organization_id project_organization_id
					, 'NTP' line_type
 			,decode(ver.rate_dangling_flag,'Y',-1,1) rate
 			,decode(ver.rate_dangling_flag,'Y',-1,1) rate2
	, ver.plan_type_code plan_type_code   /*4471527 */
                        , ver.WP_FLAG
				 FROM
                       PJI_FM_EXTR_PLNVER4           ver
                     , pa_resource_asSIGNments       ra
                     , PA_BUDGET_LINES               bl
                     , pa_projects_all               ppa
                     , PJI_FM_AGGR_DLY_RATES         rates
                     , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                 WHERE 1=1
				     AND ra.resource_asSIGNment_id = bl.resource_asSIGNment_id
                     AND ra.project_id = ver.PROJECT_ID
                     AND ra.budget_version_id = ver.plan_version_id
                     AND ver.project_id = ppa.project_id
                     AND txn_currency_code IS NOT NULL
                     AND bl.project_currency_code IS NOT NULL
                     AND bl.projfunc_currency_code IS NOT NULL
			         AND pevs.element_version_id = ver.wbs_struct_version_id
                     AND ver.project_id = pevs.project_id
	 		         AND ver.secondary_rbs_flag = 'N'
					 AND ver.wp_flag = 'N'
					 AND ver.baselined_flag = 'Y'
					 AND ver.time_phased_type_code = 'N'
					 AND rates.time_id = DECODE ( g_currency_conversion_rule
                               , 'S'
					 , TO_NUMBER(to_CHAR(ra.planning_start_date, 'J'))
					 , 'E'
					 , TO_NUMBER(to_CHAR(ra.planning_end_date, 'J')) )
					 AND rates.worker_id = g_worker_id
					 AND rates.pf_currency_code = bl.projfunc_currency_code -- 4764334
					 AND ver.worker_id = g_worker_id
				  ) spread_bl
				   ---- end of third inline view 'spread_bl'...........
            	  ,
            	    (
                      select 1   INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('GLOBAL_CURR1_FLAG') = 'Y' union all /* Added for bug 8708651 */
                      select 2   INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('GLOBAL_CURR2_FLAG') = 'Y' union all
                      select 4   INVERT_ID from dual union all
                      select 8   INVERT_ID from dual union all
                      select 16  INVERT_ID from dual where PJI_UTILS.GET_SETUP_PARAMETER('TXN_CURR_FLAG') = 'Y'
                    ) invert
				)  collapse_bl	-- WHERE wbs_element_id = 7474 -- and rbs_element_id = 10266 -- and budget_version_id = 2909
				----  End of second inline view 'collapse_bl' ..........
			GROUP BY
              collapse_bl.PROJECT_ID
			, collapse_bl.time_id
            , collapse_bl.WBS_ELEMENT_ID
            -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
			, collapse_bl.plan_type_id
            , collapse_bl.plan_version_id
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.RESOURCE_ASSIGNMENT_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , collapse_bl.start_date
            , collapse_bl.end_date
            , collapse_bl.row_id
			, collapse_bl.line_type
			, collapse_bl.calendar_type
			, collapse_bl.period_type_id
	    ,collapse_bl.rate
	    ,collapse_bl.rate2
           , collapse_bl.plan_type_code  /*4471527 */
            , collapse_bl.WP_FLAG
       ) plr
				----  End of first inline view plr ..........
	  WHERE 1=1
          -- AND plr.CURR_RECORD_TYPE IS NOT NULL
          AND plr.currency_code IS NOT NULL
       GROUP BY
         plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , plr.time_id
       , plr.period_type_id
       , plr.CALENDAR_TYPE
       , plr.CURR_RECORD_TYPE  -- curr code missing.
  	   , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.plan_version_id
  	 , plr.plan_type_id
       , plr.start_date
  	 , plr.end_date
	  , plr.line_type
	  ,decode(sign(plr.rate),-1,'Y',NULL) ||decode(sign(plr.rate2),-1,'Y',NULL)
       ,plr.plan_type_code   /*4471527 */
  )
 GROUP BY
	 WORKER_ID
	,PROJECT_ID
	,PROJECT_ORG_ID
	,project_ORGANIZATION_ID
	,WBS_ELEMENT_ID
	,time_id
	,period_type_id
	,CALENDAR_TYPE
	,RBS_AGGR_LEVEL
	,WBS_ROLLUP_FLAG
	,PRG_ROLLUP_FLAG
	,CURR_RECORD_TYPE
	,currency_code
	,RBS_ELEMENT_ID
	,RBS_STRUCT_VERSION_ID
	,plan_version_id
	,plan_type_id
        ,LINE_TYPE
        ,rate_dangling_flag
        ,time_dangling_flag
        ,start_date
        ,end_date
        ,prg_level
        ,plan_type_code ;    /*4471527 */

  print_time ( ' EXTRACT_PLAN_AMTS_PRIRBS_GLC12 end. Inserted rows # is: ' || SQL%ROWCOUNT );
EXCEPTION
  WHEN OTHERS THEN
    print_time('EXTRACT_PLAN_AMTS_PRIRBS_GLC12 : Exception ' || SQLERRM );
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'EXTRACT_PLAN_AMTS_PRIRBS_GLC12');
    RAISE;
END;

PROCEDURE EXTRACT_DANGL_REVERSAL IS
BEGIN

 print_time ( ' EXTRACT_DANGL_REVERSAL begin. ' );

 INSERT INTO PJI_FP_AGGR_PJP1
    (
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , LINE_TYPE
       , RATE_DANGLING_FLAG
       , TIME_DANGLING_FLAG
        , START_DATE
        , END_DATE
       , PRG_LEVEL
       , PLAN_TYPE_CODE   /*4471527 */
	)
SELECT
  g_worker_id WORKER_ID
 ,fact.PROJECT_ID
 ,fact.PROJECT_ORG_ID
 ,fact.PROJECT_ORGANIZATION_ID
 ,fact.PROJECT_ELEMENT_ID
 ,fact.TIME_ID
 ,fact.PERIOD_TYPE_ID
 ,fact.CALENDAR_TYPE
 ,fact.RBS_AGGR_LEVEL
 ,fact.WBS_ROLLUP_FLAG
 ,fact.PRG_ROLLUP_FLAG
 ,fact.CURR_RECORD_TYPE_ID
 ,fact.CURRENCY_CODE
 ,fact.RBS_ELEMENT_ID
 ,fact.RBS_VERSION_ID
 ,fact.PLAN_VERSION_ID
 ,fact.PLAN_TYPE_ID
 ,-fact.RAW_COST
 ,-fact.BRDN_COST
 ,-fact.REVENUE
 ,-fact.BILL_RAW_COST
 ,-fact.BILL_BRDN_COST
 ,-fact.BILL_LABOR_RAW_COST
 ,-fact.BILL_LABOR_BRDN_COST
 ,-fact.BILL_LABOR_HRS
 ,-fact.EQUIPMENT_RAW_COST
 ,-fact.EQUIPMENT_BRDN_COST
 ,-fact.CAPITALIZABLE_RAW_COST
 ,-fact.CAPITALIZABLE_BRDN_COST
 ,-fact.LABOR_RAW_COST
 ,-fact.LABOR_BRDN_COST
 ,-fact.LABOR_HRS
 ,-fact.LABOR_REVENUE
 ,-fact.EQUIPMENT_HOURS
 ,-fact.BILLABLE_EQUIPMENT_HOURS
 ,-fact.SUP_INV_COMMITTED_COST
 ,-fact.PO_COMMITTED_COST
 ,-fact.PR_COMMITTED_COST
 ,-fact.OTH_COMMITTED_COST
 ,-fact.ACT_LABOR_HRS
 ,-fact.ACT_EQUIP_HRS
 ,-fact.ACT_LABOR_BRDN_COST
 ,-fact.ACT_EQUIP_BRDN_COST
 ,-fact.ACT_BRDN_COST
 ,-fact.ACT_RAW_COST
 ,-fact.ACT_REVENUE
 ,-fact.ACT_LABOR_RAW_COST
 ,-fact.ACT_EQUIP_RAW_COST
 ,-fact.ETC_LABOR_HRS
 ,-fact.ETC_EQUIP_HRS
 ,-fact.ETC_LABOR_BRDN_COST
 ,-fact.ETC_EQUIP_BRDN_COST
 ,-fact.ETC_BRDN_COST
 ,-fact.ETC_RAW_COST
 ,-fact.ETC_LABOR_RAW_COST
 ,-fact.ETC_EQUIP_RAW_COST
 ,-fact.CUSTOM1
 ,-fact.CUSTOM2
 ,-fact.CUSTOM3
 ,-fact.CUSTOM4
 ,-fact.CUSTOM5
 ,-fact.CUSTOM6
 ,-fact.CUSTOM7
 ,-fact.CUSTOM8
 ,-fact.CUSTOM9
 ,-fact.CUSTOM10
 ,-fact.CUSTOM11
 ,-fact.CUSTOM12
 ,-fact.CUSTOM13
 ,-fact.CUSTOM14
 ,-fact.CUSTOM15
 ,DECODE(ver.time_phased_type_code,'N',
			DECODE(fact.calendar_type,'A','NTP','CF'),
			fact.calendar_type,'OF','CF') LINE_TYPE
 ,NULL RATE_DANGLING_FLAG
 ,NULL TIME_DANGLING_FLAG
  ,TO_DATE(NULL) START_DATE
  ,TO_DATE(NULL) END_DATE
 ,g_default_prg_level PRG_LEVEL
 , fact.plan_type_code   plan_type_code
FROM
    pji_fp_xbs_accum_f fact,
    pji_fm_extr_plnver4 ver,
    pa_proj_fp_options fp                              -- Bug fix 8510978
WHERE fact.plan_version_id=ver.plan_version_id
  AND fact.project_id = fp.project_id                 -- Bug fix 8510978
  AND fact.plan_type_id = fp.fin_plan_type_id         -- Bug fix 8510978
  AND fact.plan_version_id = fp.fin_plan_version_id   -- Bug fix 8510978
  AND fact.plan_type_code = ver.plan_type_code   /*4471527 */
  AND fact.project_id = ver.project_id
  AND NVL(ver.rbs_struct_version_id,-1) = fact.rbs_version_id
  AND ver.worker_id = g_worker_id
  AND ver.wp_flag = 'N'
  AND ver.baselined_flag = 'Y'
  AND fact.rbs_aggr_level='L'
  AND fact.wbs_rollup_flag='N'
  AND fact.PRG_ROLLUP_FLAG ='N'
  --Bug fix 8510978
 AND ((ver.time_phased_type_code = 'N'
         AND fact.calendar_type = 'A')
         OR ((fact.calendar_type = 'A'
        AND ((Decode(fact.plan_type_code,'A',fp.all_fin_plan_level_code,
                                         'C',fp.cost_fin_plan_level_code,
                                         'R',fp.revenue_fin_plan_level_code) = 'L')
              OR ((Decode(fact.plan_type_code,'A',fp.all_fin_plan_level_code,
                                              'C',fp.cost_fin_plan_level_code,
                                              'R',fp.revenue_fin_plan_level_code) IN ('T','P'))
                  AND Decode(fact.plan_type_code,'A',fp.all_time_phased_code,
                                                 'C',fp.cost_time_phased_code,
                                                 'R',fp.revenue_time_phased_code) = 'P'))))
              OR (fact.calendar_type IN ('P','G','E')
                  AND period_type_id = 32));
  --Bug Fix 8510978

  print_time ( ' EXTRACT_DANGL_REVERSAL end. Inserted rows # is: ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    print_time(' EXTRACT_DANGL_REVERSAL : Exception ' || SQLERRM );
    Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'EXTRACT_DANGL_REVERSAL');
    RAISE;

END;


PROCEDURE EXTRACT_ACTUALS(
  p_extrn_type        IN   VARCHAR2 := NULL -- 'FULL' or 'INCREMENTAL'
) IS

  l_max_project_id         NUMBER;

BEGIN

  print_time ( ' EXTRACT_ACTUALS BEGIN' ) ;

  IF (p_extrn_type NOT IN ('FULL', 'INCREMENTAL')) THEN
    RETURN;
  END IF;

  INSERT_NTP_CAL_RECORD ( x_max_project_id => l_max_project_id );

  IF (l_max_project_id IS NULL) THEN
    RETURN;
  END IF;


  INSERT INTO PJI_FP_AGGR_PJP1
    (
         WORKER_ID
       , PRG_LEVEL
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	 , ACT_EQUIP_HRS
	 , ACT_LABOR_BRDN_COST
	 , ACT_EQUIP_BRDN_COST
	 , ACT_BRDN_COST
	 , ACT_RAW_COST
	 , ACT_REVENUE
       , ACT_LABOR_RAW_COST
       , ACT_EQUIP_RAW_COST
	 , ETC_LABOR_HRS
	 , ETC_EQUIP_HRS
	 , ETC_LABOR_BRDN_COST
	 , ETC_EQUIP_BRDN_COST
	 , ETC_BRDN_COST
       , ETC_RAW_COST
       , ETC_LABOR_RAW_COST
       , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       ,PLAN_TYPE_CODE   /*4471527 */
	)
       -- Get actuals from budget lines for extraction type is full.
	 SELECT /*+ ordered no_merge(plr) */
         g_worker_id worker_id
       , g_default_prg_level prg_level
       , plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , DECODE(plr.time_phased_type_code
              , 'N', -1
              , pji_time.cal_period_id) time_id
       , DECODE(plr.time_phased_type_code
               , 'P', 32
               , 'G', 32
               , 'N', 2048
               , -1) period_type_id -- period type id...
       , DECODE(plr.time_phased_type_code
               , 'P', 'P'
               , 'G', 'G'
               , 'N', 'A'
               , 'X')     --   CALENDAR_TYPE
       , 'L' RBS_AGGR_LEVEL
       , 'N' WBS_ROLLUP_FLAG
       , 'N' PRG_ROLLUP_FLAG
       , plr.CURR_RECORD_TYPE  -- curr code missing.
       , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.BUDGET_VERSION_ID
       , plr.plan_type_id plan_type_id
       , TO_NUMBER(NULL) RAW_COST
       , TO_NUMBER(NULL) BRDN_COST
       , TO_NUMBER(NULL) REVENUE
       , TO_NUMBER(NULL)  BILL_RAW_COST
       , TO_NUMBER(NULL)  BILL_BRDN_COST
       , TO_NUMBER(NULL) BILL_LABOR_RAW_COST
       , TO_NUMBER(NULL) BILL_LABOR_BRDN_COST
       , TO_NUMBER(NULL) BILL_LABOR_HRS
       , TO_NUMBER(NULL)  EQUIPMENT_RAW_COST
       , TO_NUMBER(NULL)  EQUIPMENT_BRDN_COST
       , TO_NUMBER(NULL) CAPITALIZABLE_RAW_COST
       , TO_NUMBER(NULL)  CAPITALIZABLE_BRDN_COST
       , TO_NUMBER(NULL) LABOR_RAW_COST
       , TO_NUMBER(NULL) LABOR_BRDN_COST
       , TO_NUMBER(NULL) labor_hrs
       , TO_NUMBER(NULL)  LABOR_REVENUE
       , TO_NUMBER(NULL) EQUIPMENT_HOURS
       , TO_NUMBER(NULL) BILLABLE_EQUIPMENT_HOURS
       , TO_NUMBER(NULL) -- TO_NUMBER(NULL)  SUP_INV_COMMITTED_COST
       , TO_NUMBER(NULL) -- TO_NUMBER(NULL)  PO_COMMITTED_COST
       , TO_NUMBER(NULL) -- TO_NUMBER(NULL)  PR_COMMITTED_COST
       , TO_NUMBER(NULL) -- TO_NUMBER(NULL)  OTH_COMMITTED_COST
       , SUM ( DECODE (  plr.resource_class
                       , 'PEOPLE'
                       , DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,TO_NUMBER(NULL))
                       , TO_NUMBER(NULL) ) ) ACT_LABOR_HRS
       , SUM ( DECODE ( plr.resource_class
                      , 'EQUIPMENT'
                      , DECODE ( plr.billable_flag, 'Y',plr.actual_quantity,TO_NUMBER(NULL))
                      , TO_NUMBER(NULL) ) ) ACT_EQUIP_HOURS
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.actual_BRDN_COST, TO_NUMBER(NULL) ) ) ACT_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.actual_BRDN_COST, TO_NUMBER(NULL) ) ) ACT_EQUIPMENT_BRDN_COST
       , SUM ( plr.actual_brdn_cost ) ACT_BRDN_COST
       , SUM ( plr.actual_raw_cost ) ACT_RAW_COST
       , SUM ( plr.actual_revenue ) ACT_REVENUE
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.actual_RAW_COST, TO_NUMBER(NULL) ) ) ACT_LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.actual_RAW_COST, TO_NUMBER(NULL) ) ) ACT_EQUIPMENT_RAW_COST
       , TO_NUMBER(NULL) ETC_LABOR_HRS
       , TO_NUMBER(NULL) ETC_EQUIP_HOURS
       , TO_NUMBER(NULL) ETC_LABOR_BRDN_COST
       , TO_NUMBER(NULL) ETC_EQUIP_BRDN_COST
       , TO_NUMBER(NULL) ETC_BRDN_COST
       , TO_NUMBER(NULL) ETC_RAW_COST
       , TO_NUMBER(NULL) ETC_LABOR_raw_COST
       , TO_NUMBER(NULL) ETC_EQUIP_raw_COST
       , TO_NUMBER(NULL) CUSTOM1
       , TO_NUMBER(NULL) CUSTOM2
       , TO_NUMBER(NULL) CUSTOM3
       , TO_NUMBER(NULL) CUSTOM4
       , TO_NUMBER(NULL) CUSTOM5
       , TO_NUMBER(NULL) CUSTOM6
       , TO_NUMBER(NULL) CUSTOM7
       , TO_NUMBER(NULL) CUSTOM8
       , TO_NUMBER(NULL) CUSTOM9
       , TO_NUMBER(NULL) CUSTOM10
       , TO_NUMBER(NULL) CUSTOM11
       , TO_NUMBER(NULL) CUSTOM12
       , TO_NUMBER(NULL) CUSTOM13
       , TO_NUMBER(NULL) CUSTOM14
       , TO_NUMBER(NULL) CUSTOM15
       , plr.plan_type_code PLAN_TYPE_CODE   /*4471527 */
       FROM
       (          ----- First inline view plr .............
            SELECT /*+ no_merge(collapse_bl) */
              collapse_bl.PROJECT_ID
            , collapse_bl.WBS_ELEMENT_ID
            , SUM(collapse_bl.CURR_RECORD_TYPE_ID) CURR_RECORD_TYPE
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
		    , collapse_bl.plan_type_id
            , collapse_bl.BUDGET_VERSION_ID
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.RESOURCE_ASSIGNMENT_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS  -- , CALENDAR_TYPE -- , CALENDAR_ID
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , MAX(collapse_bl.raw_cost) raw_cost
            , MAX(collapse_bl.BRDN_COST) BRDN_COST
            , MAX(collapse_bl.revenue) revenue
            , MAX(collapse_bl.actual_raw_cost) actual_raw_cost
            , MAX(collapse_bl.actual_BRDN_COST) actual_BRDN_COST
            , MAX(collapse_bl.actual_revenue) actual_revenue
            , MAX(collapse_bl.etc_raw_cost) etc_raw_cost
            , MAX(collapse_bl.etc_BRDN_COST) etc_BRDN_COST
            , MAX(collapse_bl.etc_revenue) etc_revenue
            , MAX(collapse_bl.quantity) quantity
            , MAX(collapse_bl.actual_quantity) actual_quantity
            , MAX(collapse_bl.etc_quantity) etc_quantity
            , collapse_bl.start_date start_date
            , collapse_bl.end_date   end_date
            , collapse_bl.period_name period_name
            , collapse_bl.row_id
            , collapse_bl.plan_type_code
            FROM
              (                  ----- Second inline view 'collapse_bl' begin .............
               SELECT /*+ no_merge(spread_bl) */
                  spread_bl.row_id row_id
                , spread_bl.PROJECT_ID
                , spread_bl.BUDGET_VERSION_ID
                , spread_bl.RESOURCE_ASSIGNMENT_ID
                , spread_bl.WBS_ELEMENT_ID
                , spread_bl.RBS_ELEMENT_ID
                , spread_bl.WBS_STRUCT_VERSION_ID
                , spread_bl.RBS_STRUCT_VERSION_ID
  	 	        , spread_bl.plan_type_id
                , spread_bl.BILLABLE_FLAG
                , spread_bl.RESOURCE_CLASS  -- , spread_bl.CALENDAR_TYPE  -- , pji_time.CALENDAR_ID
                , spread_bl.PROJECT_ORGANIZATION_ID
                , spread_bl.PROJECT_ORG_ID
                , spread_bl.TIME_PHASED_TYPE_CODE
                , DECODE( invert.INVERT_ID
                        , 4, spread_bl.func_CURRENCY_CODE
                        , 8, spread_bl.PRJ_CURRENCY_CODE
                        , 16, spread_bl.TXN_CURRENCY_CODE ) CURRENCY_CODE
                , invert.INVERT_ID CURR_RECORD_TYPE_ID
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_raw_cost
                         , 8, spread_bl.PRJ_raw_cost
                         , 16, spread_bl.TXN_raw_cost) raw_cost
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_BRDN_COST
                         , 8, spread_bl.PRJ_BRDN_COST
                         , 16, spread_bl.TXN_BRDN_COST ) BRDN_COST
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_revenue
                         , 8, spread_bl.PRJ_revenue
                         , 16, spread_bl.TXN_revenue ) revenue
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_actual_raw_cost
						 , 8, spread_bl.prj_actual_raw_cost
						 , 16, spread_bl.txn_actual_raw_cost ) actual_raw_cost
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_actual_brdn_cost
						 , 8, spread_bl.prj_actual_brdn_cost
						 , 16, spread_bl.txn_actual_brdn_cost ) actual_brdn_cost
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_actual_revenue
						 , 8, spread_bl.prj_actual_revenue
						 , 16, spread_bl.txn_actual_revenue ) actual_revenue
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_etc_raw_cost
						 , 8, spread_bl.prj_etc_raw_cost
						 , 16, spread_bl.txn_etc_raw_cost ) etc_raw_cost
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_etc_brdn_cost
						 , 8, spread_bl.prj_etc_brdn_cost
						 , 16, spread_bl.txn_etc_brdn_cost ) etc_brdn_cost
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_etc_revenue
						 , 8, spread_bl.prj_etc_revenue
						 , 16, spread_bl.txn_etc_revenue ) etc_revenue
            	, spread_bl.quantity quantity
            	, spread_bl.actual_quantity actual_quantity
            	, spread_bl.etc_quantity etc_quantity
            	, spread_bl.start_date start_date
            	, spread_bl.end_date   end_date
            	, spread_bl.period_name period_name
            	-- , spread_bl.TRACK_AS_LABOR_FLAG track_as_labor_flag
                              , spread_bl.plan_type_code   plan_type_code  /*4471527 */
                FROM
                  (     ----- Third inline view 'spread_bl'  .............
                    SELECT /*+ ordered */
                	  ra.project_id
                	, bl.ROWID row_id
                	, ra.budget_version_id
                	, bl.resource_asSIGNment_id
                	, DECODE(ra.task_id, 0, pevs.proj_element_id, ra.task_id) wbs_element_id
                	, NVL(ra.rbs_element_id, -1)              rbs_element_id
                	, ver.wbs_struct_version_id      wbs_struct_version_id
                	, NVL(ver.rbs_struct_version_id, -1)    rbs_struct_version_id
			, ver.plan_type_id               plan_type_id
			, ra.rate_based_flag             billable_flag
			, ra.resource_class_code         resource_class
                	, bl.txn_currency_code           txn_currency_code
                	, TO_NUMBER(NULL)                              txn_raw_cost
                	, TO_NUMBER(NULL)                              txn_brdn_COST
                	, TO_NUMBER(NULL)                              txn_revenue
			, bl.txn_init_raw_cost           txn_actual_raw_cost
			, bl.txn_init_burdened_cost      txn_actual_brdn_cost
			, bl.txn_init_revenue            txn_actual_revenue
			, TO_NUMBER(NULL)                           txn_etc_raw_cost
                  , TO_NUMBER(NULL)                           txn_etc_brdn_cost
			, TO_NUMBER(NULL)                           txn_etc_revenue
                	, bl.project_currency_code          prj_currency_code
                	, TO_NUMBER(NULL)                                 prj_raw_cost
                	, TO_NUMBER(NULL)                                 prj_BRDN_COST
                	, TO_NUMBER(NULL)                                 prj_revenue
			, bl.project_init_raw_cost          prj_actual_raw_cost
			, bl.project_init_burdened_cost     prj_actual_brdn_cost
			, bl.project_init_revenue           prj_actual_revenue
			, TO_NUMBER(NULL)                              prj_etc_raw_cost
			, TO_NUMBER(NULL)                              prj_etc_brdn_cost
			, TO_NUMBER(NULL)                              prj_etc_revenue
                	, bl.projfunc_currency_code         func_currency_code
                  , TO_NUMBER(NULL)                                 func_raw_cost
                	, TO_NUMBER(NULL)                                 func_BRDN_COST
                	, TO_NUMBER(NULL)                                 func_revenue
			, bl.init_raw_cost                  func_actual_raw_cost
			, bl.init_burdened_cost             func_actual_brdn_cost
			, bl.init_revenue                   func_actual_revenue
			, TO_NUMBER(NULL)                              func_etc_raw_cost
			, TO_NUMBER(NULL)                              func_etc_brdn_cost
			, TO_NUMBER(NULL)                              func_etc_revenue
                	, 'CAD'        glb1_currency_code
                  , TO_NUMBER(NULL)                           glb1_raw_cost
                	, TO_NUMBER(NULL)                           glb1_BRDN_COST
                	, TO_NUMBER(NULL)                           glb1_revenue
                	, 'USD'        glb2_currency_code
                  , TO_NUMBER(NULL)                           glb2_raw_cost
                	, TO_NUMBER(NULL)                           glb1_BRDN_COST
                	, TO_NUMBER(NULL)                           glb1_revenue
                  , TO_NUMBER(NULL)                              quantity
			, bl.init_quantity               actual_quantity
			, TO_NUMBER(NULL)                           etc_quantity
                	, TO_DATE(NULL)                           start_date
                	, TO_DATE(NULL)                           end_date
                	,  NVL(bl.period_name, 'XXX') period_name
                	, ver.time_phased_type_code time_phased_type_code
                	, ppa.org_id project_org_id
                	, ppa.carrying_out_organization_id project_organization_id
                              , ver.plan_type_code   plan_type_code   /* 4471527*/
                 FROM
                     PJI_FM_EXTR_PLNVER4           ver
                   , PA_RESOURCE_ASSIGNMENTS       ra
                   , PA_BUDGET_LINES               bl
                   , PA_PROJECTS_ALL               ppa
                   , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                 WHERE
                         ra.resource_asSIGNment_id = bl.resource_asSIGNment_id
                     AND ra.project_id = ver.PROJECT_ID
                     AND ra.budget_version_id = ver.plan_version_id
                     AND ver.project_id = ppa.project_id
                     AND txn_currency_code IS NOT NULL
                     AND bl.project_currency_code IS NOT NULL
                     AND bl.projfunc_currency_code IS NOT NULL
			         AND pevs.element_version_id = ver.wbs_struct_version_id
			         AND pevs.project_id = ver.project_id
	 		         AND ver.secondary_rbs_flag = 'N'
                     AND p_extrn_type = 'FULL'
                     AND ver.worker_id = g_worker_id
                     AND ver.time_phased_type_code IN ('P', 'G', 'N')
				  ) spread_bl
				   ---- end of third inline view 'spread_bl'...........
            	  ,
            	    (
                      SELECT 4   INVERT_ID FROM dual UNION ALL
                      SELECT 8   INVERT_ID FROM dual UNION ALL
                      SELECT 16  INVERT_ID FROM dual where PJI_UTILS.GET_SETUP_PARAMETER('TXN_CURR_FLAG') = 'Y'
                    ) invert
				)  collapse_bl
				----  End of second inline view 'collapse_bl' ..........
			GROUP BY
              collapse_bl.PROJECT_ID
            , collapse_bl.WBS_ELEMENT_ID
            -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
			, collapse_bl.plan_type_id
            , collapse_bl.BUDGET_VERSION_ID
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.RESOURCE_ASSIGNMENT_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS
            , collapse_bl.TIME_PHASED_TYPE_CODE
            , collapse_bl.CURRENCY_CODE
            , collapse_bl.start_date
            , collapse_bl.end_date
            , collapse_bl.period_name
            , collapse_bl.row_id
             ,collapse_bl.plan_type_code
       ) plr
				----  End of first inline view plr ..........
       , PJI_ORG_EXTR_INFO            orginfo
       , pji_time_cal_period_v      pji_time
         WHERE  1=1
           -- AND    orginfo.projfunc_currency_mau is not TO_NUMBER(NULL
           AND    plr.project_org_id           = orginfo.org_id
           AND    DECODE(plr.time_phased_type_code
                       , 'P', orginfo.pa_calendar_id
                       , 'G', orginfo.gl_calendar_id
                       , -l_max_project_id )   = pji_time.calendar_id
           AND    plr.period_name = pji_time.name
       GROUP BY
         plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , DECODE(plr.time_phased_type_code
              , 'N', -1
              , pji_time.cal_period_id)
       , DECODE(plr.time_phased_type_code
               , 'P', 32
               , 'G', 32
               , 'N', 2048
               , -1) -- period type id...
       , DECODE(plr.time_phased_type_code
               , 'P', 'P'
               , 'G', 'G'
               , 'N', 'A'
               , 'X')     --   CALENDAR_TYPE
       , plr.CURR_RECORD_TYPE  -- curr code missing.
  	   , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.BUDGET_VERSION_ID
  	 , plr.plan_type_id
       , plr.PLAN_TYPE_CODE;


  print_time ( ' EXTRACT_ACTUALS # records is ' || SQL%ROWCOUNT ) ;

  DELETE_NTP_CAL_RECORD ( p_max_project_id => l_max_project_id );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'EXTRACT_ACTUALS');
    RAISE;
END;


--
-- Temp fix until time table will have a record for non time phasing.
--
PROCEDURE INSERT_NTP_CAL_RECORD ( x_max_project_id OUT NOCOPY NUMBER ) IS
    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

    l_start_end_date       DATE   := TRUNC(SYSDATE);
BEGIN

  BEGIN

    SELECT MAX(project_id)
    INTO   x_max_project_id
    FROM   pji_pjp_proj_batch_map
    WHERE  worker_id = g_worker_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
  END;

  IF (x_max_project_id IS NULL) THEN
    RETURN;
  END IF;

  print_time (' Inside INSERT_NTP_CAL_RECORD, max project_id is: ' || x_max_project_id);


  INSERT INTO pji_time_cal_period
  (
		CAL_PERIOD_ID,
		CAL_QTR_ID,
		CALENDAR_ID,
		SEQUENCE,
		NAME ,
		START_DATE,
		END_DATE,
		CREATION_DATE,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATED_BY,
		LAST_UPDATE_LOGIN
)
  SELECT  -x_max_project_id   cal_period_id
        , -x_max_project_id   cal_qtr_id
        , -x_max_project_id   calendar_id
        , -x_max_project_id   SEQUENCE
        , g_ntp_period_name   name
        , l_start_end_date    start_date
        , l_start_end_date    end_date
        , l_creation_date     creation_date
        , l_last_update_date  last_update_date
        , l_last_updated_by   last_updated_by
        , l_created_by        created_by
        , l_last_update_login last_update_login
    FROM  DUAL;

    print_time (' INSERT_NTP_CAL_RECORD, # rows inserted is: ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'INSERT_NTP_CAL_RECORD');
    RAISE;
END;


PROCEDURE DELETE_NTP_CAL_RECORD ( p_max_project_id IN NUMBER ) IS
BEGIN

    print_time (' DELETE_NTP_CAL_RECORD, max project_id is: ' || p_max_project_id);

    DELETE FROM pji_time_cal_period
    WHERE cal_period_id =  -p_max_project_id;

    print_time (' DELETE_NTP_CAL_RECORD, # rows deleted is: ' || SQL%ROWCOUNT );

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'DELETE_NTP_CAL_RECORD');
    RAISE;
END;


--
-- Processes the plan lines that have not yet been processed through bulk summarization.
--
PROCEDURE PROCESS_PENDING_PLAN_UPDATES(
  p_extrn_type    IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_data      OUT NOCOPY VARCHAR2) IS

  l_max_project_id NUMBER := NULL;
  l_extract_etc    VARCHAR2(1) := NULL; -- 4682341

BEGIN

  PJI_PJP_FP_CURR_WRAP.INIT_ERR_STACK
  ( p_package_name   => g_package_name
  , x_return_status  => x_return_status );

  IF (p_extrn_type NOT IN ('FULL', 'INCREMENTAL', 'RBS', 'PARTIAL')) THEN
    RETURN;
  END IF;

  -- 4682341
  -- No data found error should not be thrown.
  --
  BEGIN
    SELECT value
    INTO   l_extract_etc
    FROM   pji_system_parameters
    WHERE  name = 'EXTRACT_ETC_FULLLOAD';
  EXCEPTION
    WHEN OTHERS THEN
      l_extract_etc := 'Y';
  END;

  IF (l_extract_etc = 'N') THEN
    UPDATE pji_system_parameters
    SET    value = 'Y'
    WHERE  name = 'EXTRACT_ETC_FULLLOAD';
  END IF;

  INSERT_NTP_CAL_RECORD ( x_max_project_id => l_max_project_id );

  IF (l_max_project_id IS NULL) THEN
    RETURN;
  END IF;


    INSERT INTO PJI_FP_AGGR_PJP1
    (
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , LINE_TYPE
       , RATE_DANGLING_FLAG
       , TIME_DANGLING_FLAG
       , PRG_LEVEL
       , PLAN_TYPE_CODE   /*4471527 */
	)
	   SELECT /*+ ordered no_merge(plr) */
         g_worker_id  WORKER_ID
       , plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID project_element_id
       , DECODE(plr.time_phased_type_code
              , 'N', -1
              , pji_time.cal_period_id)  time_id
       , DECODE(plr.time_phased_type_code
               , 'P', 32
               , 'G', 32
               , 'N', 2048
               , -1) period_type_id -- period type id...
       , DECODE(plr.time_phased_type_code
               , 'P', 'P'
               , 'G', 'G'
               , 'N', 'A'
               , 'X')    CALENDAR_TYPE
       , 'L' RBS_AGGR_LEVEL
       , 'N' WBS_ROLLUP_FLAG
       , 'N' PRG_ROLLUP_FLAG
       , plr.CURR_RECORD_TYPE  CURR_RECORD_TYPE_id
       , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID  RBS_VERSION_ID
       , plr.BUDGET_VERSION_ID plan_version_id
       , plr.plan_type_id
       , SUM(plr.RAW_COST) RAW_COST
       , SUM(plr.BRDN_COST) BRDN_COST
       , SUM(plr.REVENUE) REVENUE
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )  BILL_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )   BILL_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YPEOPLE', plr.raw_cost, 0 ) )  BILL_LABOR_RAW_COST
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YPEOPLE' , plr.BRDN_COST, 0 ) )   BILL_LABOR_BRDN_COST
       -- , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'YPEOPLE', plr.quantity, 0 ) )  BILL_LABOR_HRS -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class , 'YPEOPLE',
                        DECODE ( plr.billable_flag ,'Y', plr.quantity, 0 ), 0 ) )  BILL_LABOR_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.raw_cost, 0 ) )  EQUIPMENT_RAW_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.BRDN_COST, 0 ) )   EQUIPMENT_BRDN_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.raw_cost, 0 ) )      CAPITALIZABLE_RAW_COST
       , SUM ( DECODE ( plr.billable_flag, 'Y', plr.BRDN_COST, 0 ) )      CAPITALIZABLE_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.raw_cost, 0 ) )  LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.BRDN_COST, 0 ) )   LABOR_BRDN_COST
       -- , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.quantity, 0 ) )   labor_hrs -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE',
                        DECODE(plr.billable_flag , 'Y' , plr.quantity, 0 ),
							  0 ) )   labor_hrs -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.revenue, 0 ) )  LABOR_REVENUE
       /* , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', plr.quantity, 0 ) )  EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT',
                        DECODE(plr.billable_flag , 'Y' , plr.quantity, 0 ),
			                                  0 ) )  EQUIPMENT_HOURS -- bug 6039785
       /* , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YEQUIPMENT', plr.quantity, 0 ) )  BILLABLE_EQUIPMENT_HOURS */ -- bug 6039785
       , SUM ( DECODE ( plr.billable_flag || plr.resource_class, 'YEQUIPMENT',
                        DECODE ( plr.billable_flag ,'Y', plr.quantity, 0 ), 0 ) )  BILLABLE_EQUIPMENT_HOURS -- bug 6039785
       , TO_NUMBER(NULL)                SUP_INV_COMMITTED_COST
       , TO_NUMBER(NULL)                PO_COMMITTED_COST
       , TO_NUMBER(NULL)                PR_COMMITTED_COST
       , TO_NUMBER(NULL)                OTH_COMMITTED_COST
       --, SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.actual_quantity, 0 ) ) ACT_LABOR_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', DECODE ( plr.billable_flag, 'Y', plr.actual_quantity , 0 ),
                                                                                0 ) ) ACT_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', plr.actual_quantity, 0 ) ) ACT_EQUIP_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', DECODE ( plr.billable_flag, 'Y', plr.actual_quantity, 0 ),
                                                                                0 ) ) ACT_EQUIP_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.actual_BRDN_COST, 0 ) ) ACT_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.actual_BRDN_COST, 0 ) ) ACT_EQUIP_BRDN_COST
       , SUM ( plr.actual_brdn_cost ) ACT_BRDN_COST
       , SUM ( plr.actual_raw_cost ) ACT_RAW_COST
       , SUM ( plr.actual_revenue ) ACT_REVENUE
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.actual_RAW_COST, 0 ) ) ACT_LABOR_RAW_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.actual_RAW_COST, 0 ) ) ACT_EQUIP_RAW_COST
       --, SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.etc_quantity, 0 ) ) ETC_LABOR_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', DECODE ( plr.billable_flag, 'Y', plr.etc_quantity, 0 ),
                                                                                0 ) )  ETC_LABOR_HRS -- bug 6039785
       /* , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', plr.etc_quantity, 0 ) ) ETC_EQUIP_HRS */ -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', DECODE ( plr.billable_flag, 'Y', plr.etc_quantity, 0 ),
                                                                                0 ) ) ETC_EQUIP_HRS -- bug 6039785
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.etc_BRDN_COST, 0 ) ) ETC_LABOR_BRDN_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT' , plr.etc_BRDN_COST, 0 ) ) ETC_EQUIP_BRDN_COST
       , SUM(plr.etc_BRDN_COST) ETC_BRDN_COST
       , SUM(plr.etc_RAW_COST) ETC_RAW_COST
       , SUM ( DECODE ( plr.resource_class, 'PEOPLE', plr.etc_raw_cost, 0 ) ) ETC_LABOR_raw_COST
       , SUM ( DECODE ( plr.resource_class, 'EQUIPMENT', plr.etc_raw_cost, 0 ) ) ETC_EQUIP_raw_COST
       , NULL CUSTOM1
       , NULL CUSTOM2
       , NULL CUSTOM3
       , NULL CUSTOM4
       , NULL CUSTOM5
       , NULL CUSTOM6
       , NULL CUSTOM7
       , NULL CUSTOM8
       , NULL CUSTOM9
       , NULL CUSTOM10
       , NULL CUSTOM11
       , NULL CUSTOM12
       , NULL CUSTOM13
       , NULL CUSTOM14
       , NULL CUSTOM15
       , DECODE(plr.time_phased_type_code, 'P', 'OF', 'G', 'OF', 'N', 'NTR', 'X') LINE_TYPE
       , NULL time_dangling_flag
       , NULL rate_dangling_flag
       , g_default_prg_level prg_level
       , plr.plan_type_code plan_type_code   /*4471527 */
       FROM
       (          ----- First inline view plr .............
            SELECT /*+ no_merge(collapse_bl) */
              collapse_bl.PROJECT_ID      -- , 1 partition_id
            , collapse_bl.WBS_ELEMENT_ID  -- ,  time_id, period_type_id, calendar type.., slice type, rollpu flag...
            , SUM(collapse_bl.CURR_RECORD_TYPE_ID) CURR_RECORD_TYPE
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
		    , collapse_bl.plan_type_id
            , collapse_bl.BUDGET_VERSION_ID
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS  -- , CALENDAR_TYPE -- , CALENDAR_ID
            , collapse_bl.CURRENCY_CODE
            , MAX(collapse_bl.raw_cost) raw_cost
            , MAX(collapse_bl.BRDN_COST) BRDN_COST
            , MAX(collapse_bl.revenue) revenue
            , MAX(collapse_bl.actual_raw_cost) actual_raw_cost
            , MAX(collapse_bl.actual_BRDN_COST) actual_BRDN_COST
            , MAX(collapse_bl.actual_revenue) actual_revenue
            , MAX(collapse_bl.etc_raw_cost) etc_raw_cost
            , MAX(collapse_bl.etc_BRDN_COST) etc_BRDN_COST
            , MAX(collapse_bl.quantity) quantity
            , MAX(collapse_bl.actual_quantity) actual_quantity
            , MAX(collapse_bl.etc_quantity) etc_quantity
            , collapse_bl.period_name period_name  -- , TRACK_AS_LABOR_FLAG track_as_labor_flag
            , collapse_bl.row_id
            , collapse_bl.plan_type_code   /*4471527 */
            , collapse_bl.time_phased_type_code
            FROM
              (                  ----- Second inline view 'collapse_bl' begin .............
               SELECT /*+ no_merge(spread_bl) */
                  spread_bl.row_id row_id
                , spread_bl.PROJECT_ID
                , spread_bl.BUDGET_VERSION_ID
                , spread_bl.WBS_ELEMENT_ID
                , spread_bl.RBS_ELEMENT_ID
                , spread_bl.WBS_STRUCT_VERSION_ID
                , spread_bl.RBS_STRUCT_VERSION_ID
  	 	        , spread_bl.plan_type_id
                , spread_bl.BILLABLE_FLAG
                , spread_bl.RESOURCE_CLASS  -- , spread_bl.CALENDAR_TYPE  -- , pji_time.CALENDAR_ID
                , spread_bl.PROJECT_ORGANIZATION_ID
                , spread_bl.PROJECT_ORG_ID
                , DECODE( invert.INVERT_ID
                        , 4, spread_bl.func_CURRENCY_CODE
                        , 8, spread_bl.PRJ_CURRENCY_CODE
                        , 16, spread_bl.TXN_CURRENCY_CODE ) CURRENCY_CODE
                , invert.INVERT_ID CURR_RECORD_TYPE_ID
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_raw_cost
                         , 8, spread_bl.PRJ_raw_cost
                         , 16, spread_bl.TXN_raw_cost) raw_cost
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_BRDN_COST
                         , 8, spread_bl.PRJ_BRDN_COST
                         , 16, spread_bl.TXN_BRDN_COST ) BRDN_COST
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_revenue
                         , 8, spread_bl.PRJ_revenue
                         , 16, spread_bl.TXN_revenue ) revenue
                , DECODE ( invert.INVERT_ID
                         , 4, spread_bl.func_actual_raw_cost
                         , 8, spread_bl.prj_actual_raw_cost
                         , 16, spread_bl.txn_actual_raw_cost ) actual_raw_cost
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_actual_brdn_cost
						 , 8, spread_bl.prj_actual_brdn_cost
						 , 16, spread_bl.txn_actual_brdn_cost ) actual_brdn_cost
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_actual_revenue
						 , 8, spread_bl.prj_actual_revenue
						 , 16, spread_bl.txn_actual_revenue ) actual_revenue
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_etc_raw_cost
						 , 8, spread_bl.prj_etc_raw_cost
						 , 16, spread_bl.txn_etc_raw_cost ) etc_raw_cost
				, DECODE ( invert.INVERT_ID
				         , 4, spread_bl.func_etc_brdn_cost
						 , 8, spread_bl.prj_etc_brdn_cost
						 , 16, spread_bl.txn_etc_brdn_cost ) etc_brdn_cost
            	, spread_bl.quantity quantity
            	, spread_bl.actual_quantity actual_quantity
            	, spread_bl.etc_quantity etc_quantity
            	, spread_bl.period_name period_name
                              , spread_bl.plan_type_code   plan_type_code   /*4471527 */
                , spread_bl.time_phased_type_code
                FROM
                  (     ----- Third inline view 'spread_bl'  .............
                  SELECT /*+ ordered */
                	  bl.project_id
                	, bl.ROWID row_id
                	, bl.plan_version_id budget_version_id
                	, DECODE(bl.project_element_id, 0, pevs.proj_element_id, bl.project_element_id) wbs_element_id
                	, NVL(bl.rbs_element_id, -1)   rbs_element_id
                	, bl.struct_ver_id             wbs_struct_version_id
                	, NVL(ver.rbs_struct_version_id, -1)   rbs_struct_version_id
                	, bl.plan_type_id               plan_type_id -- ver.plan_type_id
                  , bl.rate_based_flag              billable_flag -- ra.rate_based_flag             billable_flag
                  , bl.resource_class_code          resource_class -- ra.resource_class_code         resource_class
                	, bl.txn_currency_code               txn_currency_code
                	, TO_NUMBER(NULL)                               txn_raw_cost -- bl.txn_raw_cost
                	, TO_NUMBER(NULL)                               txn_BRDN_COST  -- bl.txn_burdened_cost
                	, TO_NUMBER(NULL)                               txn_revenue -- bl.txn_revenue
			, DECODE(p_extrn_type, 'FULL', TO_NUMBER(NULL), bl.act_txn_raw_cost)                txn_actual_raw_cost
			, DECODE(p_extrn_type, 'FULL', TO_NUMBER(NULL), bl.act_txn_burdened_cost)           txn_actual_brdn_cost
			, DECODE(p_extrn_type, 'FULL', TO_NUMBER(NULL), bl.act_txn_revenue)                 txn_actual_revenue
			, DECODE(p_extrn_type||l_extract_etc
                            , 'FULLN'
                            , TO_NUMBER(NULL)
                            , bl.etc_txn_raw_cost)  txn_etc_raw_cost
			, DECODE(p_extrn_type||l_extract_etc
                            , 'FULLN'
                            , TO_NUMBER(NULL)
                            , bl.etc_txn_burdened_cost)  txn_etc_brdn_cost
                	, bl.prj_currency_code               prj_currency_code
                	, TO_NUMBER(NULL)                               prj_raw_cost -- bl.prj_raw_cost
                	, TO_NUMBER(NULL)                               prj_BRDN_COST -- bl.prj_burdened_cost
                	, TO_NUMBER(NULL)                               prj_revenue -- bl.prj_revenue
			, DECODE(p_extrn_type, 'FULL', TO_NUMBER(NULL), bl.act_prj_raw_cost) prj_actual_raw_cost
			, DECODE(p_extrn_type, 'FULL', TO_NUMBER(NULL), bl.act_prj_burdened_cost)           prj_actual_brdn_cost
			, DECODE(p_extrn_type, 'FULL', TO_NUMBER(NULL), bl.act_prj_revenue)                 prj_actual_revenue
			, DECODE(p_extrn_type||l_extract_etc
                            , 'FULLN'
                            , TO_NUMBER(NULL)
                            , bl.etc_prj_raw_cost)  prj_etc_raw_cost
			, DECODE(p_extrn_type||l_extract_etc
                            , 'FULLN'
                            , TO_NUMBER(NULL)
                            , bl.etc_prj_burdened_cost)  prj_etc_brdn_cost
                	, bl.pfc_currency_code               func_currency_code
                	, TO_NUMBER(NULL)                               func_raw_cost -- bl.pfc_raw_cost
                	, TO_NUMBER(NULL)                               func_BRDN_COST -- bl.pfc_burdened_cost
                	, TO_NUMBER(NULL)                               func_revenue -- bl.pfc_revenue
			, DECODE(p_extrn_type, 'FULL', TO_NUMBER(NULL), bl.act_pfc_raw_cost)                func_actual_raw_cost
			, DECODE(p_extrn_type, 'FULL', TO_NUMBER(NULL), bl.act_pfc_burdened_cost)           func_actual_brdn_cost
			, DECODE(p_extrn_type, 'FULL', TO_NUMBER(NULL), bl.act_pfc_revenue)                 func_actual_revenue
			, DECODE(p_extrn_type||l_extract_etc
                            , 'FULLN'
                            , TO_NUMBER(NULL)
                            , bl.etc_pfc_raw_cost)  func_etc_raw_cost
			, DECODE(p_extrn_type||l_extract_etc
                            , 'FULLN'
                            , TO_NUMBER(NULL)
                            , bl.etc_pfc_burdened_cost)  func_etc_brdn_cost
                	, TO_NUMBER(NULL)                               quantity -- bl.quantity
			, DECODE(p_extrn_type, 'FULL', TO_NUMBER(NULL), bl.act_quantity)                    actual_quantity
			, DECODE(p_extrn_type||l_extract_etc
                            , 'FULLN'
                            , TO_NUMBER(NULL)
                            , bl.etc_quantity)  etc_quantity
                	, NVL(bl.period_name, 'XXX')         period_name
                	, bl.project_org_id                  project_org_id
                	, ppa.carrying_out_organization_id   project_organization_id
	, ver.plan_type_code plan_type_code    /*4471527 */
                        , ver.time_phased_type_code
                FROM
                    PJI_FM_EXTR_PLNVER4           ver
                  , PJI_FM_EXTR_PLAN_LINES        bl
                  , PA_PROJECTS_ALL               ppa
                  , PA_PROJ_ELEM_VER_STRUCTURE    pevs
                  WHERE 1=1
                               AND ver.wp_flag = 'Y'
                               AND bl.project_id = ver.project_id
                               AND bl.plan_version_id = ver.plan_version_id
                               AND bl.plan_type_id = ver.plan_type_id
                               AND ppa.project_id = ver.project_id
                               AND bl.project_id = ppa.project_id
                               AND bl.TXN_CURRENCY_CODE IS NOT NULL
                               AND bl.prj_currency_code IS NOT NULL
                               AND bl.pfc_currency_code IS NOT NULL
                               AND pevs.element_version_id = ver.wbs_struct_version_id
                               AND pevs.project_id = ver.project_id
                               AND ver.worker_id = g_worker_id
                               AND ver.time_phased_type_code IN ('P', 'G', 'N')
				  ) spread_bl
				   ---- end of third inline view 'spread_bl'...........
            	  ,
            	    (
                      SELECT 4   INVERT_ID FROM dual UNION ALL
                      SELECT 8   INVERT_ID FROM dual UNION ALL
                      SELECT 16  INVERT_ID FROM dual where PJI_UTILS.GET_SETUP_PARAMETER('TXN_CURR_FLAG') = 'Y'
                    ) invert
				)  collapse_bl
				----  End of second inline view 'collapse_bl' ..........
			GROUP BY
              collapse_bl.PROJECT_ID
            , collapse_bl.WBS_ELEMENT_ID
            , collapse_bl.RBS_ELEMENT_ID
            , collapse_bl.RBS_STRUCT_VERSION_ID
			, collapse_bl.plan_type_id
            , collapse_bl.BUDGET_VERSION_ID
            , collapse_bl.PROJECT_ORGANIZATION_ID
            , collapse_bl.PROJECT_ORG_ID
            , collapse_bl.BILLABLE_FLAG
            , collapse_bl.RESOURCE_CLASS
            , collapse_bl.CURRENCY_CODE
            , collapse_bl.period_name
            , collapse_bl.row_id
            , collapse_bl.plan_type_code
            , collapse_bl.time_phased_type_code
       ) plr
				----  End of first inline view plr ..........
       , PJI_ORG_EXTR_INFO            orginfo
       , pji_time_cal_period_v    pji_time
         WHERE  1=1
           -- AND    orginfo.projfunc_currency_mau is not NULL
           AND    plr.project_org_id         = orginfo.org_id
           AND    DECODE(plr.time_phased_type_code
                   , 'P', orginfo.pa_calendar_id
                   , 'G', orginfo.gl_calendar_id
                   , - l_max_project_id ) = pji_time.calendar_id
           AND    plr.period_name = pji_time.name
       GROUP BY
         plr.PROJECT_ID
       , plr.PROJECT_ORG_ID
       , plr.project_ORGANIZATION_ID
       , plr.WBS_ELEMENT_ID
       , DECODE(plr.time_phased_type_code
              , 'N', -1
              , pji_time.cal_period_id)
       , DECODE(plr.time_phased_type_code
               , 'P', 32
               , 'G', 32
               , 'N', 2048
               , -1) -- period type id...
       , DECODE(plr.time_phased_type_code
               , 'P', 'P'
               , 'G', 'G'
               , 'N', 'A'
               , 'X')     --   CALENDAR_TYPE
       , plr.CURR_RECORD_TYPE  -- curr code missing.
  	   , plr.currency_code
       , plr.RBS_ELEMENT_ID
       , plr.RBS_STRUCT_VERSION_ID
       , plr.BUDGET_VERSION_ID
  	 , plr.plan_type_id
       , DECODE(plr.time_phased_type_code, 'P', 'OF', 'G', 'OF', 'N', 'NTR', 'X')
       , plr.plan_type_code ;    /*4471527 */


  print_time(' # of records from plan lines is : ' || SQL%ROWCOUNT );


  DELETE_NTP_CAL_RECORD ( p_max_project_id => l_max_project_id );

  POPULATE_RBS_HDR;
  print_time(' RBS Header Populated.');

  POPULATE_WBS_HDR;
  print_time('Populated new records into WBS Header Table.');

  UPDATE_WBS_HDR; -- To be moved to separate step.
  print_time('Updated the WBS header table with min max txn dates.');

  -- DELETE PLAN LINES.

EXCEPTION
  WHEN OTHERS THEN
    PJI_PJP_FP_CURR_WRAP.EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => ' PROCESS_PENDING_PLAN_UPDATES '
    , x_return_status  => x_return_status ) ;

    RAISE;
END PROCESS_PENDING_PLAN_UPDATES;

-- bug 6063826
PROCEDURE UPDATE_WBS_HDR (p_worker_id in number) is
  pragma autonomous_transaction;

    CURSOR wbs_cur IS
    SELECT  pjp1.project_id
       , pjp1.plan_version_id, NVL(pjp1.plan_type_id, -1) plan_type_id
       , pjp1.PLAN_TYPE_CODE
       , cal.start_date min_txn_date
       , cal.end_date max_txn_date
    FROM PJI_FP_AGGR_PJP1    pjp1
       , pji_time_cal_period_v   cal
   WHERE
         pjp1.worker_id = p_worker_id
     AND pjp1.time_id = cal.cal_period_id
     AND pjp1.calendar_type IN ('P', 'G') ; -- Non time ph and ent cals don't need to be considered.

    TYPE proj_id_tab_type IS TABLE OF pji_pjp_wbs_header.project_id%TYPE;
    TYPE plan_ver_id_tab_type IS TABLE OF pji_pjp_wbs_header.plan_version_id%TYPE;
    TYPE plan_type_id_tab_type IS TABLE OF pji_pjp_wbs_header.plan_type_id%TYPE;
    TYPE plan_type_code_tab_type IS TABLE OF pji_pjp_wbs_header.plan_type_code%TYPE;
    TYPE min_txn_date_tab_type IS TABLE OF pji_pjp_wbs_header.min_txn_date%TYPE;
    TYPE max_txn_date_tab_type IS TABLE OF pji_pjp_wbs_header.max_txn_date%TYPE;

    proj_id_tab proj_id_tab_TYPE;
    plan_ver_id_tab plan_ver_id_tab_TYPE;
    plan_type_id_tab plan_type_id_tab_TYPE;
    plan_type_code_tab plan_type_code_tab_TYPE;
    min_txn_date_tab  min_txn_date_tab_type;
    max_txn_date_tab  max_txn_date_tab_type;

BEGIN

    OPEN wbs_cur;

    LOOP
        FETCH wbs_cur BULK COLLECT
        INTO proj_id_tab,plan_ver_id_tab,plan_type_id_tab,
              plan_type_code_tab,min_txn_date_tab,max_txn_date_tab LIMIT 50000;

        -- EXIT WHEN wbs_cur%NOTFOUND; -- bug 6316433
       If proj_id_tab.count > 0 then
        FORALL i IN proj_id_tab.FIRST .. proj_id_tab.LAST
        UPDATE /*+ index(whdr,PJI_PJP_WBS_HEADER_N1) */
        PJI_PJP_WBS_HEADER whdr
        SET  MIN_TXN_DATE = LEAST(min_txn_date_tab(i),  NVL(whdr.min_txn_date, min_txn_date_tab(i)))
        , MAX_TXN_DATE =  GREATEST(max_txn_date_tab(i),  NVL(whdr.max_txn_date, max_txn_date_tab(i)))
        , LAST_UPDATE_DATE = sysdate
        , LAST_UPDATED_BY = -9999
        , LAST_UPDATE_LOGIN = -9999
        WHERE     whdr.plan_version_id = plan_ver_id_tab(i)
        AND  whdr.project_id = proj_id_tab(i)
        AND  NVL(whdr.plan_type_id, -1) = plan_type_id_tab(i)
        AND  whdr.plan_type_code = plan_type_code_tab(i);

        commit;
        proj_id_tab.delete;
        plan_ver_id_tab.delete;
        plan_type_id_tab.delete;
        plan_type_code_tab.delete;
        min_txn_date_tab.delete;
        max_txn_date_tab.delete;
        EXIT WHEN wbs_cur%NOTFOUND;  -- bug 6316433
       Else
	     Exit;
       End if;
    END LOOP;
    CLOSE wbs_cur;
END UPDATE_WBS_HDR;


-- Bug 6316433 : Added batch processing logic
PROCEDURE MERGE_INTO_FP_FACTS IS

    l_last_update_date     date   := SYSDATE;
    l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    l_creation_date        date   := SYSDATE;
    l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
    l_process varchar2(30); /* Added for bug 7551819 */
    l_from_launch varchar2(5) := 'N'; /* Added for bug 7551819 */


	TYPE row_id_tab_type   IS TABLE OF rowid index by binary_integer;
    x_row_id               row_id_tab_type;

   cursor c1 is
      select rowid from pji_fp_aggr_pjp1
	   where worker_id = g_worker_id;
BEGIN

  print_time ( 'SAM MERGE_INTO_FP_FACTS worker id..' || g_worker_id || ' sysdate '  || sysdate) ;

  l_process := PJI_PJP_SUM_MAIN.g_process || g_worker_id;  /* Added for bug 7551819 */

    /* Added for bug 7551819 */
    begin
        select 'Y' into l_from_launch
        from dual
        where PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'FROM_PROJECT')
        like 'UPP-BATCH-%';
    exception
        when others then
             l_from_launch := 'N';
    end;
    /* Added for bug 7551819 */


  open c1;
  loop

	 fetch c1 bulk collect into x_row_id limit 500000;

  If x_row_id.count > 0  then
    -- gather statistics for PJI metadata tables
    /* Gather stats by partition added for bug 7551819 */
    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_FP_AGGR_PJP1',
				                         partname=>'P'|| g_worker_id,
                                 granularity=>'PARTITION',
                                 percent => 5,
                                 degree  => PJI_UTILS.GET_DEGREE_OF_PARALLELISM());

   /* Added for bug 7551819
      If UPPD is submitted standalone, then gather stats is required.
      If UPPD is submitted from Launch process, gather stats is not required */

   if l_from_launch = 'N' then
    -- gather statistics for PJI metadata tables
    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_FP_XBS_ACCUM_F',
                                 percent => 5,
                                 degree  => PJI_UTILS.GET_DEGREE_OF_PARALLELISM());

   end if;

Forall i in x_row_id.first..x_row_id.last
MERGE INTO PJI_FP_XBS_ACCUM_F fact
USING (  SELECT
       tmp.worker_id
     , tmp.PROJECT_ID
     , tmp.PROJECT_ORG_ID
     , tmp.PROJECT_ORGANIZATION_ID
     , tmp.PROJECT_ELEMENT_ID
     , tmp.TIME_ID
     , tmp.PERIOD_TYPE_ID
     , tmp.CALENDAR_TYPE
     , tmp.RBS_AGGR_LEVEL
     , tmp.WBS_ROLLUP_FLAG
     , tmp.PRG_ROLLUP_FLAG
     , tmp.CURR_RECORD_TYPE_ID
     , tmp.CURRENCY_CODE
     , tmp.RBS_ELEMENT_ID
     , tmp.RBS_VERSION_ID
     , ver3.PLAN_VERSION_ID
     , tmp.PLAN_TYPE_ID
     , tmp.RAW_COST
     , tmp.BRDN_COST
     , tmp.REVENUE
     , tmp.BILL_RAW_COST
     , tmp.BILL_BRDN_COST
     , tmp.BILL_LABOR_RAW_COST
     , tmp.BILL_LABOR_BRDN_COST
     , tmp.BILL_LABOR_HRS
     , tmp.EQUIPMENT_RAW_COST
     , tmp.EQUIPMENT_BRDN_COST
     , tmp.CAPITALIZABLE_RAW_COST
     , tmp.CAPITALIZABLE_BRDN_COST
     , tmp.LABOR_RAW_COST
     , tmp.LABOR_BRDN_COST
     , tmp.LABOR_HRS
     , tmp.LABOR_REVENUE
     , tmp.EQUIPMENT_HOURS
     , tmp.BILLABLE_EQUIPMENT_HOURS
     , tmp.SUP_INV_COMMITTED_COST
     , tmp.PO_COMMITTED_COST
     , tmp.PR_COMMITTED_COST
     , tmp.OTH_COMMITTED_COST
     , tmp.ACT_LABOR_HRS
     , tmp.ACT_EQUIP_HRS
     , tmp.ACT_LABOR_BRDN_COST
     , tmp.ACT_EQUIP_BRDN_COST
     , tmp.ACT_BRDN_COST
     , tmp.ACT_RAW_COST
     , tmp.ACT_REVENUE
     , tmp.ACT_LABOR_RAW_COST
     , tmp.ACT_EQUIP_RAW_COST
     , DECODE ( ver3.wp_flag
                    , 'Y'
                    , DECODE(TO_CHAR(tmp.ETC_LABOR_HRS)  -- For Workplan
                           , NULL
                           , NVL(tmp.labor_hrs, 0)
                           , NVL(tmp.ETC_LABOR_HRS, 0)
                            )
                    , NVL(tmp.ETC_LABOR_HRS, 0)
             ) ETC_LABOR_HRS
       , DECODE ( ver3.wp_flag
                        , 'Y'
                        , DECODE(TO_CHAR(tmp.ETC_EQUIP_HRS)
                               , NULL
                               , NVL(tmp.EQUIPMENT_hours, 0)
                               , NVL(tmp.ETC_EQUIP_HRS, 0)
                      )
                 , NVL(tmp.ETC_EQUIP_HRS, 0)
              ) ETC_EQUIP_HRS
       , DECODE ( ver3.wp_flag
                    , 'Y'
                    , DECODE(TO_CHAR(tmp.ETC_LABOR_BRDN_COST)
                           , NULL
                           , NVL(tmp.labor_BRDN_COST, 0)
                           , NVL(tmp.ETC_LABOR_BRDN_COST, 0)
                   )
                   , NVL(tmp.ETC_LABOR_BRDN_COST, 0)
             ) ETC_LABOR_BRDN_COST
       , DECODE ( ver3.wp_flag
                    , 'Y'
                    , DECODE(TO_CHAR(tmp.ETC_EQUIP_BRDN_COST)
                           , NULL
                           , NVL(tmp.EQUIPment_BRDN_COST, 0)
                           , NVL(tmp.ETC_equip_BRDN_COST, 0)
                    )
                    , NVL(tmp.ETC_EQUIP_BRDN_COST, 0)
                ) ETC_equip_BRDN_COST
       , DECODE ( ver3.wp_flag
                    , 'Y'
                    , DECODE(TO_CHAR(tmp.ETC_BRDN_COST)
                           , NULL
                           , NVL(tmp.BRDN_COST, 0)
                           , NVL(tmp.ETC_BRDN_COST, 0)
                    )
                  , NVL(tmp.ETC_BRDN_COST, 0)
                ) ETC_BRDN_COST
       , DECODE ( ver3.wp_flag
                   , 'Y'
                   , DECODE(TO_CHAR(tmp.ETC_raw_COST)
                          , NULL
                          , NVL(tmp.raw_COST, 0)
                          , NVL(tmp.ETC_raw_COST, 0)
                   )
                 , NVL(tmp.ETC_raw_COST, 0)
                ) ETC_raw_COST
       , DECODE ( ver3.wp_flag
                    , 'Y'
                    , DECODE(TO_CHAR(tmp.ETC_labor_raw_COST)
                           , NULL
                           , NVL(tmp.labor_raw_COST, 0)
                           , NVL(tmp.ETC_labor_raw_COST, 0)
                    )
                  , NVL(tmp.ETC_labor_raw_COST, 0)
                ) ETC_labor_raw_COST
       , DECODE ( ver3.wp_flag
                    , 'Y'
                    , DECODE(TO_CHAR(tmp.ETC_equip_raw_COST)
                           , NULL
                           , NVL(tmp.equipment_raw_COST, 0)
                           ,  NVL(tmp.ETC_equip_raw_COST, 0)
                    )
                  , NVL(tmp.ETC_equip_raw_COST, 0)
              ) ETC_equip_raw_COST
     , tmp.CUSTOM1
     , tmp.CUSTOM2
     , tmp.CUSTOM3
     , tmp.CUSTOM4
     , tmp.CUSTOM5
     , tmp.CUSTOM6
     , tmp.CUSTOM7
     , tmp.CUSTOM8
     , tmp.CUSTOM9
     , tmp.CUSTOM10
     , tmp.CUSTOM11
     , tmp.CUSTOM12
     , tmp.CUSTOM13
     , tmp.CUSTOM14
     , tmp.CUSTOM15
     , tmp.PLAN_TYPE_CODE
     FROM  pji_fp_aggr_pjp1      tmp
         , pji_pjp_wbs_header    ver3  -- replaced ver3 with wbs header for project-to-program association event.
     WHERE  1 = 1
       AND tmp.worker_id            = g_worker_id
       AND tmp.project_id           = ver3.project_id
       AND ver3.plan_version_id     = tmp.plan_version_id
       AND NVL(tmp.plan_type_id,-1) = NVL(ver3.plan_type_id, -1) -- each plan type can have a different -3, -4 slice.
       AND ver3.plan_type_code      = tmp.plan_type_code
	   AND tmp.rowid = x_row_id(i)
       AND tmp.RATE_DANGLING_FLAG IS NULL
       AND tmp.TIME_DANGLING_FLAG IS NULL
      )  pjp1
ON    (pjp1.WORKER_ID               = g_worker_id
   AND pjp1.PROJECT_ID              = fact.PROJECT_ID
   AND pjp1.PLAN_VERSION_ID         = fact.PLAN_VERSION_ID
   AND pjp1.PLAN_TYPE_ID            = fact.PLAN_TYPE_ID
   AND pjp1.PLAN_TYPE_CODE          = fact.PLAN_TYPE_CODE
   AND pjp1.PROJECT_ORG_ID          = fact.PROJECT_ORG_ID
   AND pjp1.PROJECT_ORGANIZATION_ID = fact.PROJECT_ORGANIZATION_ID
   AND pjp1.PROJECT_ELEMENT_ID      = fact.PROJECT_ELEMENT_ID
   AND pjp1.TIME_ID                 = fact.TIME_ID
   AND pjp1.PERIOD_TYPE_ID          = fact.PERIOD_TYPE_ID
   AND pjp1.CALENDAR_TYPE           = fact.CALENDAR_TYPE
   AND pjp1.RBS_AGGR_LEVEL          = fact.RBS_AGGR_LEVEL
   AND pjp1.WBS_ROLLUP_FLAG         = fact.WBS_ROLLUP_FLAG
   AND pjp1.PRG_ROLLUP_FLAG         = fact.PRG_ROLLUP_FLAG
   AND pjp1.CURR_RECORD_TYPE_ID     = fact.CURR_RECORD_TYPE_ID
   AND pjp1.CURRENCY_CODE           = fact.CURRENCY_CODE
   AND pjp1.RBS_ELEMENT_ID          = fact.RBS_ELEMENT_ID
   AND pjp1.RBS_VERSION_ID          = fact.RBS_VERSION_ID)
WHEN MATCHED THEN
UPDATE
SET      fact.RAW_COST                 = NVL(fact.RAW_COST, 0) + NVL(pjp1.RAW_COST, 0)
       , fact.BRDN_COST                = NVL(fact.BRDN_COST, 0) + NVL(pjp1.BRDN_COST, 0)
       , fact.REVENUE                  = NVL(fact.REVENUE, 0) + NVL(pjp1.REVENUE, 0)
       , fact.BILL_RAW_COST            = NVL(fact.BILL_RAW_COST, 0) + NVL(pjp1.BILL_RAW_COST, 0)
       , fact.BILL_BRDN_COST           = NVL(fact.BILL_BRDN_COST, 0) + NVL(pjp1.BILL_BRDN_COST, 0)
       , fact.BILL_LABOR_RAW_COST      = NVL(fact.BILL_LABOR_RAW_COST, 0) + NVL(pjp1.BILL_LABOR_RAW_COST, 0)
       , fact.BILL_LABOR_BRDN_COST     = NVL(fact.BILL_LABOR_BRDN_COST, 0) + NVL(pjp1.BILL_LABOR_BRDN_COST, 0)
       , fact.BILL_LABOR_HRS           = NVL(fact.BILL_LABOR_HRS, 0) + NVL(pjp1.BILL_LABOR_HRS, 0)
       , fact.EQUIPMENT_RAW_COST       = NVL(fact.EQUIPMENT_RAW_COST, 0) + NVL(pjp1.EQUIPMENT_RAW_COST, 0)
       , fact.EQUIPMENT_BRDN_COST      = NVL(fact.EQUIPMENT_BRDN_COST, 0) + NVL(pjp1.EQUIPMENT_BRDN_COST, 0)
       , fact.CAPITALIZABLE_RAW_COST   = NVL(fact.CAPITALIZABLE_RAW_COST, 0) + NVL(pjp1.CAPITALIZABLE_RAW_COST, 0)
       , fact.CAPITALIZABLE_BRDN_COST  = NVL(fact.CAPITALIZABLE_BRDN_COST, 0) + NVL(pjp1.CAPITALIZABLE_BRDN_COST, 0)
       , fact.LABOR_RAW_COST           = NVL(fact.LABOR_RAW_COST, 0) + NVL(pjp1.LABOR_RAW_COST, 0)
       , fact.LABOR_BRDN_COST          = NVL(fact.LABOR_BRDN_COST, 0) + NVL(pjp1.LABOR_BRDN_COST, 0)
       , fact.LABOR_HRS                = NVL(fact.LABOR_HRS, 0) + NVL(pjp1.LABOR_HRS, 0)
       , fact.LABOR_REVENUE            = NVL(fact.LABOR_REVENUE, 0) + NVL(pjp1.LABOR_REVENUE, 0)
       , fact.EQUIPMENT_HOURS          = NVL(fact.EQUIPMENT_HOURS, 0) + NVL(pjp1.EQUIPMENT_HOURS, 0)
       , fact.BILLABLE_EQUIPMENT_HOURS = NVL(fact.BILLABLE_EQUIPMENT_HOURS, 0) + NVL(pjp1.BILLABLE_EQUIPMENT_HOURS, 0)
       , fact.SUP_INV_COMMITTED_COST   = NVL(fact.SUP_INV_COMMITTED_COST, 0) + NVL(pjp1.SUP_INV_COMMITTED_COST, 0)
       , fact.PO_COMMITTED_COST        = NVL(fact.PO_COMMITTED_COST, 0) + NVL(pjp1.PO_COMMITTED_COST, 0)
       , fact.PR_COMMITTED_COST        = NVL(fact.PR_COMMITTED_COST, 0) + NVL(pjp1.PR_COMMITTED_COST, 0)
       , fact.OTH_COMMITTED_COST       = NVL(fact.OTH_COMMITTED_COST, 0) + NVL(pjp1.OTH_COMMITTED_COST, 0)
       , fact.ACT_LABOR_HRS            = NVL(fact.ACT_LABOR_HRS, 0) + NVL(pjp1.ACT_LABOR_HRS, 0)
       , fact.ACT_EQUIP_HRS            = NVL(fact.ACT_EQUIP_HRS, 0) + NVL(pjp1.ACT_EQUIP_HRS, 0)
       , fact.ACT_LABOR_BRDN_COST      = NVL(fact.ACT_LABOR_BRDN_COST, 0) + NVL(pjp1.ACT_LABOR_BRDN_COST, 0)
       , fact.ACT_EQUIP_BRDN_COST      = NVL(fact.ACT_EQUIP_BRDN_COST, 0) + NVL(pjp1.ACT_EQUIP_BRDN_COST, 0)
       , fact.ACT_BRDN_COST            = NVL(fact.ACT_BRDN_COST, 0) + NVL(pjp1.ACT_BRDN_COST, 0)
       , fact.ACT_RAW_COST             = NVL(fact.ACT_RAW_COST, 0) + NVL(pjp1.ACT_RAW_COST, 0)
       , fact.ACT_REVENUE              = NVL(fact.ACT_REVENUE, 0) + NVL(pjp1.ACT_REVENUE, 0)
       , fact.ACT_LABOR_RAW_COST       = NVL(fact.ACT_LABOR_RAW_COST, 0) + NVL(pjp1.ACT_LABOR_RAW_COST, 0)
       , fact.ACT_EQUIP_RAW_COST       = NVL(fact.ACT_EQUIP_RAW_COST, 0) + NVL(pjp1.ACT_EQUIP_RAW_COST, 0)
       , fact.ETC_LABOR_HRS            = NVL(fact.ETC_LABOR_HRS, 0) + NVL(pjp1.ETC_LABOR_HRS, 0)
       , fact.ETC_EQUIP_HRS            = NVL(fact.ETC_EQUIP_HRS, 0) + NVL(pjp1.ETC_EQUIP_HRS, 0)
       , fact.ETC_LABOR_BRDN_COST      = NVL(fact.ETC_LABOR_BRDN_COST, 0) + NVL(pjp1.ETC_LABOR_BRDN_COST, 0)
       , fact.ETC_EQUIP_BRDN_COST      = NVL(fact.ETC_EQUIP_BRDN_COST, 0) + NVL(pjp1.ETC_EQUIP_BRDN_COST, 0)
       , fact.ETC_BRDN_COST            = NVL(fact.ETC_BRDN_COST, 0) + NVL(pjp1.ETC_BRDN_COST, 0)
       , fact.ETC_RAW_COST             = NVL(fact.ETC_RAW_COST, 0) + NVL(pjp1.ETC_RAW_COST, 0)
       , fact.ETC_LABOR_RAW_COST       = NVL(fact.ETC_LABOR_RAW_COST, 0) + NVL(pjp1.ETC_LABOR_RAW_COST, 0)
       , fact.ETC_EQUIP_RAW_COST       = NVL(fact.ETC_EQUIP_RAW_COST, 0) + NVL(pjp1.ETC_EQUIP_RAW_COST, 0)
       , fact.CUSTOM1                  = NVL(fact.CUSTOM1, 0)  + NVL(pjp1.CUSTOM1, 0)
       , fact.CUSTOM2                  = NVL(fact.CUSTOM2, 0)  + NVL(pjp1.CUSTOM2, 0)
       , fact.CUSTOM3                  = NVL(fact.CUSTOM3, 0)  + NVL(pjp1.CUSTOM3, 0)
       , fact.CUSTOM4                  = NVL(fact.CUSTOM4, 0)  + NVL(pjp1.CUSTOM4, 0)
       , fact.CUSTOM5                  = NVL(fact.CUSTOM5, 0)  + NVL(pjp1.CUSTOM5, 0)
       , fact.CUSTOM6                  = NVL(fact.CUSTOM6, 0)  + NVL(pjp1.CUSTOM6, 0)
       , fact.CUSTOM7                  = NVL(fact.CUSTOM7, 0)  + NVL(pjp1.CUSTOM7, 0)
       , fact.CUSTOM8                  = NVL(fact.CUSTOM8, 0)  + NVL(pjp1.CUSTOM8, 0)
       , fact.CUSTOM9                  = NVL(fact.CUSTOM9, 0)  + NVL(pjp1.CUSTOM9, 0)
       , fact.CUSTOM10                 = NVL(fact.CUSTOM10, 0) + NVL(pjp1.CUSTOM10, 0)
       , fact.CUSTOM11                 = NVL(fact.CUSTOM11, 0) + NVL(pjp1.CUSTOM11, 0)
       , fact.CUSTOM12                 = NVL(fact.CUSTOM12, 0) + NVL(pjp1.CUSTOM12, 0)
       , fact.CUSTOM13                 = NVL(fact.CUSTOM13, 0) + NVL(pjp1.CUSTOM13, 0)
       , fact.CUSTOM14                 = NVL(fact.CUSTOM14, 0) + NVL(pjp1.CUSTOM14, 0)
       , fact.CUSTOM15                 = NVL(fact.CUSTOM15, 0) + NVL(pjp1.CUSTOM15, 0)
       , fact.last_update_date         = SYSDATE
       , fact.last_updated_by          = l_last_updated_by
       , fact.last_update_login        = l_last_update_login
WHEN NOT MATCHED THEN
INSERT (
       fact.PROJECT_ID
     , fact.PROJECT_ORG_ID
     , fact.PROJECT_ORGANIZATION_ID
     , fact.PROJECT_ELEMENT_ID
     , fact.TIME_ID
     , fact.PERIOD_TYPE_ID
     , fact.CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG
     , fact.CURR_RECORD_TYPE_ID
     , fact.CURRENCY_CODE
     , fact.RBS_ELEMENT_ID
     , fact.RBS_VERSION_ID
     , fact.PLAN_VERSION_ID
     , fact.PLAN_TYPE_ID
     , fact.LAST_UPDATE_DATE
     , fact.LAST_UPDATED_BY
     , fact.CREATION_DATE
     , fact.CREATED_BY
     , fact.LAST_UPDATE_LOGIN
     , fact.RAW_COST
     , fact.BRDN_COST
     , fact.REVENUE
     , fact.BILL_RAW_COST
     , fact.BILL_BRDN_COST
     , fact.BILL_LABOR_RAW_COST
     , fact.BILL_LABOR_BRDN_COST
     , fact.BILL_LABOR_HRS
     , fact.EQUIPMENT_RAW_COST
     , fact.EQUIPMENT_BRDN_COST
     , fact.CAPITALIZABLE_RAW_COST
     , fact.CAPITALIZABLE_BRDN_COST
     , fact.LABOR_RAW_COST
     , fact.LABOR_BRDN_COST
     , fact.LABOR_HRS
     , fact.LABOR_REVENUE
     , fact.EQUIPMENT_HOURS
     , fact.BILLABLE_EQUIPMENT_HOURS
     , fact.SUP_INV_COMMITTED_COST
     , fact.PO_COMMITTED_COST
     , fact.PR_COMMITTED_COST
     , fact.OTH_COMMITTED_COST
     , fact.ACT_LABOR_HRS
     , fact.ACT_EQUIP_HRS
     , fact.ACT_LABOR_BRDN_COST
     , fact.ACT_EQUIP_BRDN_COST
     , fact.ACT_BRDN_COST
     , fact.ACT_RAW_COST
     , fact.ACT_REVENUE
     , fact.ACT_LABOR_RAW_COST
     , fact.ACT_EQUIP_RAW_COST
     , fact.ETC_LABOR_HRS
     , fact.ETC_EQUIP_HRS
     , fact.ETC_LABOR_BRDN_COST
     , fact.ETC_EQUIP_BRDN_COST
     , fact.ETC_BRDN_COST
     , fact.ETC_RAW_COST
     , fact.ETC_LABOR_RAW_COST
     , fact.ETC_EQUIP_RAW_COST
     , fact.CUSTOM1
     , fact.CUSTOM2
     , fact.CUSTOM3
     , fact.CUSTOM4
     , fact.CUSTOM5
     , fact.CUSTOM6
     , fact.CUSTOM7
     , fact.CUSTOM8
     , fact.CUSTOM9
     , fact.CUSTOM10
     , fact.CUSTOM11
     , fact.CUSTOM12
     , fact.CUSTOM13
     , fact.CUSTOM14
     , fact.CUSTOM15
     , fact.PLAN_TYPE_CODE
  )
VALUES (
       pjp1.PROJECT_ID
     , pjp1.PROJECT_ORG_ID
     , pjp1.PROJECT_ORGANIZATION_ID
     , pjp1.PROJECT_ELEMENT_ID
     , pjp1.TIME_ID
     , pjp1.PERIOD_TYPE_ID
     , pjp1.CALENDAR_TYPE
     , pjp1.RBS_AGGR_LEVEL
     , pjp1.WBS_ROLLUP_FLAG
     , pjp1.PRG_ROLLUP_FLAG
     , pjp1.CURR_RECORD_TYPE_ID
     , pjp1.CURRENCY_CODE
     , pjp1.RBS_ELEMENT_ID
     , pjp1.RBS_VERSION_ID
     , pjp1.PLAN_VERSION_ID
     , pjp1.PLAN_TYPE_ID
     , sysdate
     , l_last_updated_by
     , sysdate
     , l_created_by
     , l_last_update_login
     , pjp1.RAW_COST
     , pjp1.BRDN_COST
     , pjp1.REVENUE
     , pjp1.BILL_RAW_COST
     , pjp1.BILL_BRDN_COST
     , pjp1.BILL_LABOR_RAW_COST
     , pjp1.BILL_LABOR_BRDN_COST
     , pjp1.BILL_LABOR_HRS
     , pjp1.EQUIPMENT_RAW_COST
     , pjp1.EQUIPMENT_BRDN_COST
     , pjp1.CAPITALIZABLE_RAW_COST
     , pjp1.CAPITALIZABLE_BRDN_COST
     , pjp1.LABOR_RAW_COST
     , pjp1.LABOR_BRDN_COST
     , pjp1.LABOR_HRS
     , pjp1.LABOR_REVENUE
     , pjp1.EQUIPMENT_HOURS
     , pjp1.BILLABLE_EQUIPMENT_HOURS
     , pjp1.SUP_INV_COMMITTED_COST
     , pjp1.PO_COMMITTED_COST
     , pjp1.PR_COMMITTED_COST
     , pjp1.OTH_COMMITTED_COST
     , pjp1.ACT_LABOR_HRS
     , pjp1.ACT_EQUIP_HRS
     , pjp1.ACT_LABOR_BRDN_COST
     , pjp1.ACT_EQUIP_BRDN_COST
     , pjp1.ACT_BRDN_COST
     , pjp1.ACT_RAW_COST
     , pjp1.ACT_REVENUE
     , pjp1.ACT_LABOR_RAW_COST
     , pjp1.ACT_EQUIP_RAW_COST
     , pjp1.ETC_LABOR_HRS
     , pjp1.ETC_EQUIP_HRS
     , pjp1.ETC_LABOR_BRDN_COST
     , pjp1.ETC_equip_BRDN_COST
     , pjp1.ETC_BRDN_COST
     , pjp1.ETC_RAW_COST
     , pjp1.ETC_LABOR_RAW_COST
     , pjp1.ETC_EQUIP_RAW_COST
     , pjp1.CUSTOM1
     , pjp1.CUSTOM2
     , pjp1.CUSTOM3
     , pjp1.CUSTOM4
     , pjp1.CUSTOM5
     , pjp1.CUSTOM6
     , pjp1.CUSTOM7
     , pjp1.CUSTOM8
     , pjp1.CUSTOM9
     , pjp1.CUSTOM10
     , pjp1.CUSTOM11
     , pjp1.CUSTOM12
     , pjp1.CUSTOM13
     , pjp1.CUSTOM14
     , pjp1.CUSTOM15
     , pjp1.PLAN_TYPE_CODE
       );

  print_time ( 'SAM MERGE_INTO_FP_FACTS worker id..' || g_worker_id || 'row count '  || SQL%ROWCOUNT) ;

 Forall j in x_row_id.first..x_row_id.last
     delete from pji_fp_aggr_pjp1
	  where worker_id = g_worker_id
	    and rowid = x_row_id(j);

	 commit;

	 x_row_id.delete;

     exit when c1%notfound;
	 Else
	   Exit;
	 End if;
	 end loop;

  close c1;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'MERGE_INTO_FP_FACTS');
    RAISE;
END MERGE_INTO_FP_FACTS;


-- bug 6063826

BEGIN  --  this portion is executed WHENever the package is initialized

  g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

END PJI_FM_PLAN_MAINT_PVT;

/
