--------------------------------------------------------
--  DDL for Package Body PA_ALLOC_RUN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ALLOC_RUN" AS
/* $Header: PAXALRNB.pls 120.7.12010000.4 2010/06/10 06:45:28 lamalviy ship $ */
      P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
      G_creation_date      DATE    ;
      G_last_update_date   DATE    ;
      G_created_by         NUMBER  ;
      G_last_updated_by    NUMBER  ;
      G_last_update_login  NUMBER  ;
      G_sysdate            DATE := SYSDATE;
      G_fatal_err_found    BOOLEAN := FALSE;
      G_denom_currency_code      VARCHAR2(15);
      G_lock_name VARCHAR2(20):= NULL;
      G_rule_id     NUMBER ;
      G_run_id      NUMBER ;
      G_rule_name   PA_ALLOC_RULES_ALL.rule_name%TYPE ;
      G_request_id  NUMBER ;
      /* Bug No:- 2487147, UTF8 change : changed G_tgt_expnd_org to %TYPE */
      /* G_tgt_expnd_org      VARCHAR2(60); */
      G_tgt_expnd_org   hr_organization_units.name%TYPE;
      G_tgt_expnd_type_class VARCHAR2(30);
      G_tgt_expnd_type       VARCHAR2(30);
      /* Bug No:- 2487147, UTF8 change : changed   G_offset_expnd_org to %TYPE */
      /* G_offset_expnd_org      VARCHAR2(60); */
      G_offset_expnd_org   hr_organization_units.name%TYPE;
      G_offset_expnd_type_class VARCHAR2(30);
      G_offset_expnd_type       VARCHAR2(30);
      G_num_txns  NUMBER := 0 ;
      G_basis_balance_category PA_ALLOC_RULES_ALL.basis_balance_category%TYPE;   /* added bug 2619977 */
      G_basis_budget_type_code PA_ALLOC_RULES_ALL.basis_budget_type_code%TYPE;   /* added bug 2619977 */
      G_basis_fin_plan_type_id PA_ALLOC_RULES_ALL.basis_fin_plan_type_id%TYPE;   /* added bug 2619977 */
	  G_Org_Id      Number; /* F
      /* Cursor Declarations --------------------------------------- */
      CURSOR C_proj_in_RL (p_project_id IN NUMBER, p_rl_id IN NUMBER , p_resource_struct_type in Varchar2, p_version_id In Number ) IS
        SELECT 1
          FROM pa_resource_list_assignments
          WHERE project_id = p_project_id
          AND resource_list_id = p_rl_id
		  AND P_resource_struct_type = 'RL'
		  UNION All
		Select 1
		  From PA_RBS_PRJ_ASSIGNMENTS
		 Where Project_Id = p_project_id
		   And RBS_VERSION_ID = p_version_id
		   AND P_resource_struct_type = 'RBS' ;
        -- ------------------------------------------------------------
        -- Init_who_cols
        -- ------------------------------------------------------------
        PROCEDURE Init_who_cols
        IS
        BEGIN
           G_created_by        := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
           G_last_update_login := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')), -1);
           G_last_updated_by   := G_created_by;
           G_creation_date     := G_sysdate;
           G_last_update_date  := G_sysdate ;
        END Init_who_cols ;
        -- ------------------------------------------------------------
        -- allocation_run: Main procedure for Allocation Run process
        --                 Called through a report.
        -- ------------------------------------------------------------
PROCEDURE allocation_run( p_process_mode    IN  VARCHAR2
                                    , p_debug_mode      IN  VARCHAR2
                                    , p_run_mode        IN  VARCHAR2 DEFAULT 'G'
                                    , p_rule_id         IN  NUMBER
                                    , p_run_period      IN  VARCHAR2 DEFAULT NULL
                                    , p_expnd_item_date IN  DATE DEFAULT NULL
                                    , x_run_id          OUT NOCOPY NUMBER
                                    , x_retcode         OUT NOCOPY VARCHAR2
                                    , x_errbuf          OUT NOCOPY VARCHAR2 ) IS
           CURSOR C_get_rule IS
             SELECT RULE_ID
               , RULE_NAME
               , ALLOCATION_METHOD
               , TARGET_EXP_TYPE_CLASS
               , TARGET_EXP_ORG_ID
               , TARGET_EXP_TYPE
               , TARGET_COST_TYPE
               , POOL_PERCENT
               , PERIOD_TYPE
               , SOURCE_AMOUNT_TYPE
               , SOURCE_BALANCE_CATEGORY
               , SOURCE_BALANCE_TYPE
               , ALLOC_RESOURCE_LIST_ID
               , AUTO_RELEASE_FLAG
               , IMP_WITH_EXCEPTION
               , DUP_TARGETS_FLAG
               , OFFSET_EXP_TYPE_CLASS
               , OFFSET_EXP_ORG_ID
               , OFFSET_EXP_TYPE
               , OFFSET_COST_TYPE
               , OFFSET_METHOD
               , OFFSET_PROJECT_ID
               , OFFSET_TASK_ID
               , BASIS_METHOD
               , BASIS_RELATIVE_PERIOD
               , BASIS_AMOUNT_TYPE
               , BASIS_BALANCE_CATEGORY
               , BASIS_BUDGET_TYPE_CODE
               , BASIS_FIN_PLAN_TYPE_ID   /* added bug 2619977 */
               , BASIS_BUDGET_ENTRY_METHOD_CODE
               , BASIS_BALANCE_TYPE
               , BASIS_RESOURCE_LIST_ID
               , SOURCE_EXTN_FLAG
               , TARGET_EXTN_FLAG
               , FIXED_AMOUNT
               , NVL(START_DATE_ACTIVE, G_sysdate) START_DATE_ACTIVE
               , NVL(END_DATE_ACTIVE, G_sysdate) END_DATE_ACTIVE
               , ORG_ID
               , LIMIT_TARGET_PROJECTS_CODE
			   /* FP.M : Allocation Impact : Bug # 3512552 */
			   , ALLOC_RESOURCE_STRUCT_TYPE
			   , BASIS_RESOURCE_STRUCT_TYPE
			   , ALLOC_RBS_VERSION
			   , BASIS_RBS_VERSION
               FROM pa_alloc_rules_all
               WHERE rule_id = p_rule_id ;
             cursor c_target_det is
               select '1'
               from dual
                 where exists ( select 'Y'
                 from pa_alloc_run_targets
                 where run_id = x_run_id
                 and exclude_flag <> 'Y' ) ;
               v_alloc_rule_rec C_get_rule%ROWTYPE;
               v_status NUMBER:= NULL;
               v_mode VARCHAR2(10) := NULL;
               v_run_id NUMBER:=NULL;
               v_prev_run_id NUMBER:= NULL;
               v_old_stack VARCHAR2(630);
               v_debug_mode VARCHAR2(2);
               v_process_mode VARCHAR2(10);
               v_src_amount_from_GL NUMBER;
               v_src_amount_from_proj NUMBER;
               v_bas_amount_from_proj NUMBER;
               v_curr_alloc_amount NUMBER ;
               v_period_type VARCHAR2(15);
               v_period_set_name VARCHAR2(30);
               v_period_year NUMBER;
               v_quarter NUMBER;
               v_period_num NUMBER;
               v_run_period_end_date DATE;
               v_request_id NUMBER;
               v_err_message VARCHAR2(250);
               v_basis_method VARCHAR2(2);
               v_dummy  varchar2(1) := NULL ;
	       completion_status boolean;   -- Added for 2841843
        BEGIN
           pa_debug.Init_err_stack ( 'Allocation Run');
           v_debug_mode := NVL(p_debug_mode, 'Y');
           v_process_mode := NVL(p_process_mode, 'SQL');
           pa_debug.set_process(v_process_mode, 'LOG', v_debug_mode) ;
           pa_debug.G_err_code := '0';
           x_retcode := pa_debug.G_err_code;
           x_errbuf := NULL;
           G_rule_id  := p_rule_id ;
           pa_debug.G_err_stage := 'GETTING NEW RUN ID';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
           SELECT pa_alloc_runs_s.nextval
             INTO v_run_id
             FROM dual;
           G_alloc_run_id := v_run_id;
           x_run_id := v_run_id;
           pa_debug.G_err_stage:= 'INITIALIZING WHO COLUMNS';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
           init_who_cols();
           -- Initialize the global variables for currency information
           pa_currency.SET_CURRENCY_INFO ;
           pa_debug.G_err_stage:= 'GETTING CURENCY CODE';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
           G_denom_currency_code := pa_currency.get_currency_code();
           --  G_lock_name := 'PA_AL-'||to_char(p_rule_id);
           --  pa_debug.G_err_stage := 'ACQUIRING LOCK';
           --  pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
           --  IF (pa_debug.Acquire_User_Lock(G_lock_name) <> 0 ) THEN
           --    alloc_errors( p_rule_id, x_run_id, 'R', 'E',
           --                  'PA_AL_CANT_ACQUIRE_LOCK', TRUE );
           --  END IF;
           lock_rule ( p_rule_id , x_run_id ) ;
           pa_debug.G_err_stage := 'GETTING RULE DEFINITION';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
		   OPEN C_get_rule;
		   FETCH C_get_rule INTO v_alloc_rule_rec;
		   IF C_get_rule%NOTFOUND THEN
              alloc_errors( p_rule_id, x_run_id, 'R', 'E','PA_AL_RULE_NOT_FOUND', TRUE);
           END IF;
           G_basis_balance_category := v_alloc_rule_rec.basis_balance_category;   /* added bug 2619977 */
           G_basis_budget_type_code := v_alloc_rule_rec.basis_budget_type_code;   /* added bug 2619977 */
           G_basis_fin_plan_type_id := v_alloc_rule_rec.basis_fin_plan_type_id;   /* added bug 2619977 */
		   G_Org_Id := v_alloc_rule_rec.Org_Id ; /* FP.M : Allocation Impact */
           CLOSE C_get_rule;
           pa_client_extn_alloc.check_dependency(p_rule_id, v_status, v_err_message) ;
           IF nvl(v_status,0) <> 0 then
              v_err_message:=nvl(v_err_message,'PA_AL_CE_FAILED');
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('allocation_run: ' || 'LOG',v_err_message);
              END IF;
              alloc_errors(p_rule_id, x_run_id, 'R', 'E',v_err_message, TRUE) ;
           END IF ;
           pa_debug.G_err_stage := 'CHECKING LAST RUN STATUS';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
		   check_last_run_status (p_rule_id, v_run_id, v_mode );
		   G_alloc_run_id := v_run_id;
           x_run_id := v_run_id;
           IF ( v_mode = 'RELEASE' AND p_run_mode = 'G' ) THEN
              v_mode := 'INVALID' ;
           END IF ;
           IF(v_mode = 'INVALID') THEN
              x_retcode:='-1';
              alloc_errors( p_rule_id, x_run_id, 'R', 'E',
                'PA_AL_DRAFT_PENDING_FOR_DEL', TRUE );
           ELSE
              G_alloc_run_id := v_run_id;
              x_run_id := v_run_id;
           END IF;
           pa_debug.G_err_stage := 'GET CONCURRENT REQUEST_ID FOR DRAFT';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
           v_request_id:= fnd_global.conc_request_id ;
           -- 923184 : Getting rule name and request id into a global variable.
           G_rule_name := v_alloc_rule_rec.rule_name ;
           G_request_id := v_request_id ;
           IF (v_mode = 'DRAFT' OR v_mode = 'DELETE') THEN    /* for 2176096 */
              pa_debug.G_err_stage := 'GET FISCAL YEAR QUARTER for '||p_run_period;
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
              END IF;
              get_fiscalyear_quarter(  v_alloc_rule_rec.period_type
                , p_run_period
                , v_period_type
                , v_period_set_name
                , v_period_year
                , v_quarter
                , v_period_num
                , v_run_period_end_date );
              pa_debug.G_err_stage := 'INSERTING ALLOC RUNS';
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
              END IF;
              insert_alloc_runs( x_run_id
                , p_rule_id
                , p_run_period
                , p_expnd_item_date
                , G_creation_date
                , G_created_by
                , G_last_update_date
                , G_last_updated_by
                , G_last_update_login
                , v_alloc_rule_rec.pool_percent
                , v_alloc_rule_rec.period_type
                , v_alloc_rule_rec.source_amount_type
                , v_alloc_rule_rec.source_balance_category
                , v_alloc_rule_rec.source_balance_type
                , v_alloc_rule_rec.alloc_resource_list_id
                , v_alloc_rule_rec.auto_release_flag
                , v_alloc_rule_rec.allocation_method
                , v_alloc_rule_rec.imp_with_exception
                , v_alloc_rule_rec.dup_targets_flag
                , v_alloc_rule_rec.target_exp_type_class
                , v_alloc_rule_rec.target_exp_org_id
                , v_alloc_rule_rec.target_exp_type
                , v_alloc_rule_rec.target_cost_type
                , v_alloc_rule_rec.offset_exp_type_class
                , v_alloc_rule_rec.offset_exp_org_id
                , v_alloc_rule_rec.offset_exp_type
                , v_alloc_rule_rec.offset_cost_type
                , v_alloc_rule_rec.offset_method
                , v_alloc_rule_rec.offset_project_id
                , v_alloc_rule_rec.offset_task_id
                , 'IP' /* In-Process as initial status */
				, v_alloc_rule_rec.basis_method
				, v_alloc_rule_rec.basis_relative_period
				, v_alloc_rule_rec.basis_amount_type
				, v_alloc_rule_rec.basis_balance_category
		        , v_alloc_rule_rec.basis_budget_type_code
			    , v_alloc_rule_rec.basis_balance_type
			    , v_alloc_rule_rec.basis_resource_list_id
				, v_period_year  /* fiscal_year */
				, v_quarter
				, v_period_num /* p_period_num  */
				, NULL /* p_target_exp_group */
				, NULL /* p_offset_exp_group */
				, NULL /* p_total_pool_amount  */
				, NULL  /* p_allocated_amount */
				, NULL /* p_reversal_date */
				, v_request_id
				, G_sysdate /*p_draft_request_date */
				, NULL /* p_release_request_id */
				, NULL /* p_release_request_date */
				, G_denom_currency_code
				, v_alloc_rule_rec.fixed_amount
				, NULL  /* rev_target_exp_group */
				, NULL  /* rev_offset_exp_group */
				, v_alloc_rule_rec.ORG_ID
				, v_alloc_rule_rec.limit_target_projects_code
			    /* FP.M : Allocation Impact : Bug # 3512552 */
				, Null /* p_CINT_RATE_NAME  */
				, v_alloc_rule_rec.ALLOC_RESOURCE_STRUCT_TYPE
				, v_alloc_rule_rec.BASIS_RESOURCE_STRUCT_TYPE
				, v_alloc_rule_rec.ALLOC_RBS_VERSION
				, v_alloc_rule_rec.BASIS_RBS_VERSION
				);
           G_tgt_expnd_org:=pa_utils.GetOrgName( v_alloc_rule_rec.target_exp_org_id);
           G_tgt_expnd_type_class:= v_alloc_rule_rec.target_exp_type_class;
           G_tgt_expnd_type:=v_alloc_rule_rec.target_exp_type;
           G_offset_expnd_org:=pa_utils.GetOrgName( v_alloc_rule_rec.offset_exp_org_id);
           G_offset_expnd_type_class:= v_alloc_rule_rec.offset_exp_type_class;
           G_offset_expnd_type:=v_alloc_rule_rec.offset_exp_type;
           pa_debug.G_err_stage := 'VALIDATING RULE';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
           validate_rule( p_rule_id
             , x_run_id
             , v_alloc_rule_rec.start_date_active
             , v_alloc_rule_rec.end_date_active
             , v_alloc_rule_rec.source_extn_flag
             , v_alloc_rule_rec.target_extn_flag
             , v_alloc_rule_rec.target_exp_type_class
             , v_alloc_rule_rec.target_exp_org_id
             , v_alloc_rule_rec.target_exp_type
             , v_alloc_rule_rec.offset_exp_type_class
             , v_alloc_rule_rec.offset_exp_org_id
             , v_alloc_rule_rec.offset_exp_type
             , v_alloc_rule_rec.offset_method
             , v_alloc_rule_rec.offset_project_id
             , v_alloc_rule_rec.offset_task_id
             , v_alloc_rule_rec.basis_method
             , v_alloc_rule_rec.basis_amount_type
             , v_alloc_rule_rec.basis_balance_category
             , v_alloc_rule_rec.basis_budget_type_code
             , v_alloc_rule_rec.basis_budget_entry_method_code
             , v_alloc_rule_rec.basis_balance_type
             , v_alloc_rule_rec.ORG_ID
             , v_alloc_rule_rec.fixed_amount
             , p_expnd_item_date );
           pa_debug.G_err_stage := 'POPULATING RUN SOURCES';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
           populate_run_sources( p_rule_id
             , x_run_id
             , v_alloc_rule_rec.alloc_resource_list_id
             , v_alloc_rule_rec.source_extn_flag
			 /* FP.M : Allocation Impact */
			 , v_alloc_rule_rec.alloc_resource_struct_type
			 , v_alloc_rule_rec.alloc_rbs_version
			 );
           pa_debug.G_err_stage := 'POPULATING RUN TARGETS';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
           populate_run_targets( p_rule_id
             , x_run_id
             , v_alloc_rule_rec.basis_method
             , v_alloc_rule_rec.basis_budget_type_code
             , v_alloc_rule_rec.basis_budget_entry_method_code
             , v_alloc_rule_rec.basis_resource_list_id
             , v_alloc_rule_rec.target_extn_flag
             , v_alloc_rule_rec.dup_targets_flag
             , p_expnd_item_date
             , v_alloc_rule_rec.limit_target_projects_code
             , v_basis_method
			 /* FP.M : ALlocation Impact */
			 , v_alloc_rule_rec.basis_resource_struct_type
		     , v_alloc_rule_rec.basis_rbs_version
			 ) ;
           /** Basis method of FS and FP may be overwritten by
                populate_run_targets.
            When targets lines are defined by client extension and also
                there are lines in the form **/
           open c_target_det ;
           fetch c_target_det into  v_dummy ;
           close c_target_det ;
           if v_dummy is NULL then
              alloc_errors( p_rule_id, x_run_id, 'T', 'E',
                'PA_AL_NO_TARGET_DETAILS', TRUE,'Y' );
           end if ;
           /* raise error NOW if validation failed at any point */
           pa_debug.G_err_stage := 'CHECKING FOR FATAL ERRORS';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
           IF (G_fatal_err_found) THEN
              G_fatal_err_found:= FALSE;
              COMMIT;
              alloc_errors( p_rule_id, x_run_id, 'R', 'E',
                'PA_AL_FATAL_ERROR_FOUND', TRUE,'N' );
           END IF;
           COMMIT ;  /* Introduced as part of commit cycle changes */
           pa_debug.G_err_stage := 'CALCULATE SRC PROJECT AMOUNTS';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
           cal_amounts_from_projects(  p_rule_id
             , x_run_id
             , v_alloc_rule_rec.period_type
             , v_alloc_rule_rec.source_amount_type
             , p_run_period
             , v_alloc_rule_rec.source_balance_type
             , v_alloc_rule_rec.alloc_resource_list_id
             , v_alloc_rule_rec.pool_percent
             , v_alloc_rule_rec.fixed_amount
             , v_src_amount_from_proj
			 /* FP.M : Allocation Impact : Bug # 3512552 */
			 , v_alloc_rule_rec.ALLOC_RESOURCE_STRUCT_TYPE
			 , v_alloc_rule_rec.ALLOC_RBS_VERSION
			 );
           pa_debug.G_err_stage := 'CALCULATE SRC GL AMOUNTS';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
           calculate_src_GL_amounts( p_rule_id
             , x_run_id
             , p_run_period
             , v_alloc_rule_rec.source_amount_type
             , v_src_amount_from_GL );
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' || 'LOG', 'v_src_amount_from_GL: '||to_char(v_src_amount_from_GL) );
           END IF;
           If v_alloc_rule_rec.allocation_method = 'F' then
              If (nvl(v_src_amount_from_proj,0) + nvl(v_src_amount_from_GL,0)) = 0  then
                 alloc_errors( p_rule_id, x_run_id, 'R', 'E',
                   'PA_AL_ZERO_SOURCE_POOL_AMOUNT', TRUE );
                   /*Return; reverting changes done in 5598267 for bug 9789612*/
              End if ;
           End If ;
           pa_debug.G_err_stage := 'CALCULATE BASIS PROJECT AMOUNTS';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
           /* 2182563 - v_basis_method is a out variable now. If no records are found
              for basis method 'P' or 'C' then it is changed to 'S'. */
           cal_proj_basis_amounts( p_rule_id
             , x_run_id
             , v_alloc_rule_rec.period_type
             , p_run_period
             , v_basis_method
             , v_alloc_rule_rec.basis_amount_type
             , v_alloc_rule_rec.basis_balance_type
             , v_alloc_rule_rec.basis_relative_period
             , v_alloc_rule_rec.basis_balance_category
             , v_alloc_rule_rec.basis_resource_list_id
             , v_alloc_rule_rec.basis_budget_type_code
             , v_bas_amount_from_proj
			 /* FP.M : Allocation Impact : Bug# 3512552 */
            , v_alloc_rule_rec.BASIS_RESOURCE_STRUCT_TYPE
			, v_alloc_rule_rec.BASIS_RBS_VERSION
			 );
           COMMIT ;  /* Introduced as part of commit cycle changes */
           pa_debug.G_err_stage := 'CREATING TARGET TRANSACTIONS';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
           create_target_txns( p_rule_id
             , x_run_id
             , v_alloc_rule_rec.period_type
             , v_period_year
             , v_quarter
             , v_period_num
             , v_run_period_end_date
             , v_alloc_rule_rec.target_exp_type
             , v_alloc_rule_rec.allocation_method
             , v_basis_method
             , v_alloc_rule_rec.source_amount_type
             , nvl(v_src_amount_from_proj,0) + nvl(v_src_amount_from_GL,0)
             , v_curr_alloc_amount );
           IF (v_alloc_rule_rec.offset_method <> 'N') THEN
              pa_debug.G_err_stage := 'CREATING OFFSET TRANSACTIONS';
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
              END IF;
              create_offset_txns( p_rule_id
                , x_run_id
                , v_alloc_rule_rec.period_type
                , v_period_year
                , v_quarter
                , v_period_num
                , v_run_period_end_date
                , v_alloc_rule_rec.offset_exp_type
                , v_alloc_rule_rec.allocation_method
                , v_alloc_rule_rec.offset_method
                , v_alloc_rule_rec.offset_project_id
                , v_alloc_rule_rec.offset_task_id
                , v_alloc_rule_rec.source_amount_type
                , nvl(v_src_amount_from_proj,0) + nvl(v_src_amount_from_GL,0)
                , v_curr_alloc_amount );
           END IF;
        END IF;    /* v_mode = draft */
           COMMIT ;  /* Introduced as part of commit cycle changes */
           IF (v_mode = 'RELEASE' OR v_alloc_rule_rec.auto_release_flag ='Y') THEN
           v_mode := 'RELEASE' ;
           pa_debug.G_err_stage := 'RELEASING THE RUN';
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;
           pa_alloc_run.release_alloc_txns( p_rule_id, x_run_id ,x_retcode,
             x_errbuf );
           END IF;    /* v_mode = release */
           if x_errbuf is NOT NULL then
           alloc_errors( p_rule_id, x_run_id, 'R', 'E',
           x_errbuf, TRUE );
           End if ;
           --
           --
           --    Bug: 983057  Do not create txn with zero curren alloc amount
           --   If no txns created set the allocation run status as release success
           --
           IF (G_num_txns = 0 )  THEN
              v_mode := 'RELEASE' ;
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('allocation_run: ' ||  'LOG', 'All tasks received zero amounts. No transactions created');
              END IF;
              alloc_errors( p_rule_id, x_run_id,'R','W','PA_AL_ALL_TASKS_RECD_ZERO_AMT', FALSE) ;
           END IF ;

        if x_errbuf is null then  /* added if clause for 6243121 */
 	    UPDATE pa_alloc_runs
 	       SET run_status = DECODE( v_mode, 'RELEASE', 'RS', 'DS'),
 	           release_request_id = decode(v_mode, 'RELEASE',v_request_id, NULL),
 	           release_request_date = decode(v_mode, 'RELEASE',sysdate, NULL)
 	     WHERE run_id = x_run_id;

           pa_debug.G_err_stage := 'UPDATING RUN STATUS AS SUCCESS';

           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
           END IF;

	   /* added for 6243121 */
 	 else         -- if any error/exception is encountered while releasing
           UPDATE pa_alloc_runs
             SET run_status = DECODE( v_mode, 'RELEASE', 'RF', 'DF'),
             release_request_id = decode(v_mode, 'RELEASE',v_request_id, NULL),
             release_request_date = decode(v_mode, 'RELEASE',sysdate, NULL)
             WHERE run_id = x_run_id;

	   pa_debug.G_err_stage := 'UPDATED RUN STATUS AS FAILURE';
 	     IF P_DEBUG_MODE = 'Y' THEN
 	        pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
 	     END IF;
 	  end if;
 	      /* added for 6243121 */

           pa_debug.G_err_stage := 'RELEASING LOCK';
           --  pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
           --  IF (pa_debug.Release_User_Lock(G_lock_name) <> 0 ) THEN
           --    alloc_errors( p_rule_id, x_run_id, 'R', 'E',
           --                  'PA_AL_LOCK_RELEASE_FAILED', TRUE );
           --  END IF;
           unlock_rule(p_rule_id, x_run_id) ;
           COMMIT;
           /* restore the old stack */
           pa_debug.reset_err_stack;
    EXCEPTION
       WHEN OTHERS THEN
         x_errbuf:= pa_debug.G_err_stage|| ': '||sqlerrm;
         x_run_id:= G_alloc_run_id;
         IF P_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('allocation_run: ' ||  'LOG', x_errbuf);
            pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stack);
         END IF;
         pa_debug.G_err_stage := 'UPDATING RUN STATUS AS FAILURE';
         IF P_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('allocation_run: ' ||  'LOG', pa_debug.G_err_stage);
         END IF;
         UPDATE pa_alloc_runs
           SET run_status = DECODE( v_mode, 'RELEASE', 'RF',
           'DRAFT',   'DF',
           run_status ),
           release_request_id = decode(v_mode, 'RELEASE',v_request_id, NULL),
           release_request_date = decode(v_mode, 'RELEASE',sysdate, NULL)
           WHERE run_id = x_run_id;
         IF P_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('allocation_run: ' ||  'LOG', 'x_run_id in when others of Main: '||to_char( x_run_id) );
         END IF;
         COMMIT;
        /* 2841843 Marking Conc request as completed failure
	   Explicitely not raising the exception as all debug messages
	   are retrived in "After report" trigger of the report. */
        completion_status  := fnd_concurrent.set_completion_status('ERROR', SQLERRM);
    END allocation_run;
-- ------------------------------------------------------------
-- check_last_run_status
-- ------------------------------------------------------------
PROCEDURE check_last_run_status( p_rule_id     IN  NUMBER
                               , x_run_id      IN OUT NOCOPY NUMBER
                               , x_mode        OUT NOCOPY VARCHAR2 ) IS
CURSOR C_run_id IS
  SELECT max(run_id)
  FROM pa_alloc_runs
  WHERE rule_id = p_rule_id
  AND   run_id <> x_run_id;
CURSOR C_prev_run( p_prev_run_id IN NUMBER) IS
  SELECT run_status
  FROM pa_alloc_runs
  WHERE run_id = p_prev_run_id ;
 v_run_status VARCHAR2(5) := NULL;
 v_prev_run_id NUMBER;
BEGIN
  pa_debug.set_err_stack('check_last_run_status');
  pa_debug.G_err_code := 0;
  OPEN C_run_id;
  FETCH C_run_id INTO v_prev_run_id;
  CLOSE C_run_id;
  IF v_prev_run_id IS NULL THEN
  /* a draft does not exists, so draft mode */
    x_mode := 'DRAFT';
  ELSE  /* a draft exists, check the status */
    OPEN C_prev_run( v_prev_run_id);
    FETCH C_prev_run INTO v_run_status;
    CLOSE C_prev_run;
      IF ( v_run_status = 'RS' OR v_run_status ='RV')  THEN
        x_mode := 'DRAFT';
      ELSIF (v_run_status = 'RF' OR v_run_status ='DS') THEN
        x_mode := 'RELEASE';
               x_run_id := v_prev_run_id;
      /* added for bug 2176096 */
      ELSIF (v_run_status = 'DL' ) THEN
        x_mode := 'DELETE';
--      ELSIF (v_run_status = 'DF') THEN
--        x_mode := 'INVALID';
--             x_run_id := v_prev_run_id;
      ELSE
        x_mode := 'INVALID';
      END IF;  /* end if v_run_status */
  END IF; /* end if v_prev_run_id */
/*
  IF (x_mode = 'RELEASE') THEN
         x_run_id := v_prev_run_id;
  END IF ;
*/
  /* restore the old stack */
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    pa_debug.G_err_code := SQLCODE;
    RAISE;
END check_last_run_status;
-- ------------------------------------------------------------
-- ins_alloc_exceptions
-- ------------------------------------------------------------
PROCEDURE ins_alloc_exceptions (  p_rule_id           IN NUMBER
                                , p_run_id            IN NUMBER
                                , p_creation_date     IN DATE
                                , p_created_by        IN NUMBER
                                , p_last_updated_date IN DATE
                                , p_last_updated_by   IN NUMBER
                                , p_last_update_login IN NUMBER
                                , p_level_code        IN VARCHAR2
                                , p_exception_type    IN VARCHAR2
                                , p_project_id        IN NUMBER
                                , p_task_id           IN NUMBER
                                , p_exception_code    IN VARCHAR2 ) IS
BEGIN
  pa_debug.set_err_stack('ins_alloc_exceptions');
  INSERT INTO pa_alloc_exceptions (
    RUN_ID
  , RULE_ID
  , LEVEL_CODE
  , EXCEPTION_TYPE
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  , PROJECT_ID
  , TASK_ID
  , EXCEPTION_CODE )
  VALUES (
    p_run_id
  , p_rule_id
  , p_level_code
  , p_exception_type
  , p_creation_date
  , p_created_by
  , p_last_updated_date
  , p_last_updated_by
  , p_last_update_login
  , p_project_id
  , p_task_id
  , p_exception_code );
  /*  restore the old stack */
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
  pa_debug.G_err_code := SQLCODE;
  RAISE;
END ins_alloc_exceptions;
-- ------------------------------------------------------------
-- alloc_errors:
-- ------------------------------------------------------------
PROCEDURE alloc_errors( p_rule_id IN NUMBER
                      , p_run_id  IN NUMBER
                      , p_level   IN VARCHAR2
                      , p_type    IN VARCHAR2
                      , p_mesg_code   IN VARCHAR2
                      , p_fatal_err   IN BOOLEAN  DEFAULT FALSE
                      , p_insert_flag IN VARCHAR2 DEFAULT 'Y'
                      , p_project_id  IN NUMBER   DEFAULT NULL
                      , p_task_id     IN NUMBER   DEFAULT NULL ) IS
v_mesg_code VARCHAR2(30);
BEGIN
  v_mesg_code := SUBSTR( p_mesg_code,1,30);
  pa_debug.set_err_stack('alloc_errors');
  IF ( p_insert_flag = 'Y') THEN
    ins_alloc_exceptions( p_rule_id, p_run_id, G_creation_date,
                          G_created_by, G_last_update_date,
                          G_last_updated_by, G_last_update_login,
                          p_level, p_type, p_project_id, p_task_id, v_mesg_code );
  END IF;
  IF (p_fatal_err) THEN
	           /*Return; reverting changes done in 5598267 for bug 9789612 */
 	           pa_debug.raise_error( -20010, p_mesg_code );
  END IF;
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    pa_debug.G_err_code := SQLCODE;
    RAISE;
END alloc_errors;
-- ----------------------------------------------------------------------
-- Validate_rule
-- ----------------------------------------------------------------------
PROCEDURE validate_rule( p_rule_id               IN NUMBER
                       , p_run_id                IN NUMBER
                       , p_start_date_active     IN DATE
                       , p_end_date_active       IN DATE
                       , p_source_extn_flag      IN VARCHAR2
                       , p_target_extn_flag      IN VARCHAR2
                       , p_target_exp_type_class IN VARCHAR2
                       , p_target_exp_org_id     IN NUMBER
                       , p_target_exp_type       IN VARCHAR2
                       , p_offset_exp_type_class IN VARCHAR2
                       , p_offset_exp_org_id     IN NUMBER
                       , p_offset_exp_type       IN VARCHAR2
                       , p_offset_method         IN VARCHAR2
                       , p_offset_project_id     IN NUMBER
                       , p_offset_task_id        IN NUMBER
                       , p_basis_method             IN VARCHAR2
                       , p_basis_amount_type        IN VARCHAR2
                       , p_basis_balance_category   IN VARCHAR2
                       , p_bas_budget_type_code     IN VARCHAR2
                       , p_bas_bdgt_entry_mthd_code IN VARCHAR2
                       , p_basis_balance_type       IN VARCHAR2
                       , p_org_id                IN NUMBER
                       , p_fixed_amount          IN NUMBER
                       , p_expnd_item_date       IN DATE ) IS
CURSOR C_pa_src_exists IS
  SELECT 1
  FROM pa_alloc_source_lines
  WHERE rule_id = p_rule_id ;
CURSOR C_gl_src_exists IS
  SELECT 1
  FROM pa_alloc_GL_lines
  WHERE rule_id = p_rule_id ;
CURSOR C_target_lines IS
  SELECT project_id, task_id, exclude_flag, billable_only_flag
  FROM pa_alloc_target_lines
  WHERE rule_id = p_rule_id;
CURSOR C_pa_trg_exists IS
  SELECT 1
  FROM pa_alloc_target_lines
  WHERE rule_id = p_rule_id;
CURSOR C_check_task( p_project_id IN NUMBER
                   , p_task_id    IN NUMBER
                                                 , p_expnd_item_date IN DATE ) IS
SELECT 1
  FROM pa_tasks pt
  WHERE pt.task_id = p_task_id
  AND nvl(pt.chargeable_flag, 'N') = 'Y'
  AND ( trunc(p_expnd_item_date) BETWEEN  trunc(nvl(pt.start_date,p_expnd_item_date))
         AND trunc(NVL(pt.completion_date, p_expnd_item_date)) )
  AND ( pa_project_utils.check_project_action_allowed( p_project_id, 'NEW_TXNS') = 'Y')
  AND (pa_project_stus_utils.is_project_closed( p_project_id )= 'N');
CURSOR C_exptype_exists(p_exp_type IN VARCHAR2) IS
  SELECT 1
  FROM pa_expenditure_types
  WHERE expenditure_type = p_exp_type
  AND TRUNC(G_sysdate) BETWEEN TRUNC(start_date_active)
                AND TRUNC(nvl(end_date_active, G_sysdate));
CURSOR C_fixed_percent IS
  SELECT nvl(sum(NVL(line_percent,0)),0)
  FROM pa_alloc_target_lines
  WHERE rule_id = p_rule_id;
CURSOR C_billable_task( p_task_id            IN NUMBER
                      , p_billable_only_flag IN VARCHAR2 ) IS
  SELECT 1
  FROM pa_tasks
  WHERE task_id = p_task_id
  AND billable_flag = p_billable_only_flag;
v_src_error_found BOOLEAN;
v_gl_error_found BOOLEAN;
v_dummy NUMBER;
-- v_task_id  NUMBER;
-- v_billable_only_flag VARCHAR2(1);
BEGIN
  pa_debug.set_err_stack('validate_rule');
  pa_debug.G_err_code:= 0;
  pa_debug.G_err_stage:= 'CHECKING DATE EFFECTIVITY OF RULE';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('validate_rule: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  IF ( TRUNC(p_start_date_active) > TRUNC(G_sysdate) OR
      TRUNC(p_end_date_active) <TRUNC(G_sysdate) ) THEN
    G_fatal_err_found := TRUE;
    alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                  'PA_AL_RULE_INACTIVE');
  END IF;
  pa_debug.G_err_stage:= 'CHECKING SRC_LINES DEFINITON';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('validate_rule: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  IF(p_fixed_amount IS NULL) THEN
    IF (p_source_extn_flag = 'N') THEN
      OPEN C_pa_src_exists;
      FETCH C_pa_src_exists INTO v_dummy;
       IF C_pa_src_exists%NOTFOUND THEN
          v_src_error_found := TRUE;
        END IF;
      CLOSE C_pa_src_exists;
      OPEN C_gl_src_exists;
      FETCH C_gl_src_exists INTO v_dummy;
        IF C_gl_src_exists%NOTFOUND THEN
          v_GL_error_found := TRUE;
        ELSE
          v_GL_error_found := FALSE;
        END IF;
      CLOSE C_gl_src_exists ;
      IF( v_GL_error_found AND v_src_error_found ) THEN
        G_fatal_err_found := TRUE;
        alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                      'PA_AL_NO_SOURCE_LINES');
      END IF;  /* if v_gl_err AND v_src_err */
    END IF;  /* if p_source_extn_flag */
  END IF;  /* if p_fixed_amount */
  pa_debug.G_err_stage:= 'CHECKING TARGET LINES';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('validate_rule: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  IF( p_target_extn_flag = 'N') THEN
    v_dummy:= 0;
    OPEN C_pa_trg_exists ;
    FETCH C_pa_trg_exists INTO v_dummy;
    IF (C_pa_trg_exists%NOTFOUND) THEN
          G_fatal_err_found := TRUE;
          alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                        'PA_AL_NO_TARGET_LINES');
    END IF;   /* if c_pa_trg_exists */
    CLOSE C_pa_trg_exists;
    /* if target lines exists and basis_method = Fixed_prorate
                 or Fixed_SpreadEvenly */
    IF (v_dummy <> 0 AND p_basis_method IN ( 'FP', 'FS') ) THEN
      OPEN C_fixed_percent;
      FETCH C_fixed_percent INTO v_dummy;
        IF (v_dummy <>100) THEN
          G_fatal_err_found := TRUE;
          alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                        'PA_AL_LINE_PRCNT_NOT_100');
        END IF;
      CLOSE C_fixed_percent;
    END IF; /* if basis_method */
  END IF;   /* if p_target_extn_flag */
  FOR target_line_rec IN C_target_lines LOOP
    /* check if task is billable */
    IF ( target_line_rec.task_id IS NOT NULL AND target_line_rec.exclude_flag = 'N') THEN
      /* check that the proj-task combination is valid and chargeable */
      OPEN C_check_task( target_line_rec.project_id
                       , target_line_rec.task_id
                                                          , p_expnd_item_date );
      FETCH C_check_task INTO v_dummy;
      IF C_check_task%NOTFOUND THEN
        G_fatal_err_found := TRUE;
        alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                      'PA_AL_NOT_A_CHARGEABLE_TASK',
                       FALSE, 'Y',
                       target_line_rec.project_id,
                       target_line_rec.task_id );
      END IF;
      CLOSE C_check_task;
      IF ( target_line_rec.billable_only_flag = 'Y' ) THEN
        OPEN C_billable_task ( target_line_rec.task_id
                             , target_line_rec.billable_only_flag );
        FETCH C_billable_task INTO v_dummy;
        IF C_billable_task%NOTFOUND THEN
          G_fatal_err_found := TRUE;
          alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                        'PA_AL_TASK_NON_BILLABLE',
                                                                 FALSE, 'Y',
                         target_line_rec.project_id,
                         target_line_rec.task_id );
        END IF;
        CLOSE C_billable_task ;
      END IF;  /* billable_flag */
    END IF; /* task_id IS NOT NULL */
  END LOOP;  /* C_target_lines */
  pa_debug.G_err_stage:= 'VALIDATING OFFSET METHOD';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('validate_rule: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  IF(p_offset_method IN ( 'A', 'B')) THEN
    /* if GL_source_lines exists or p_fixed_amount exists
    then error out */
    IF (v_GL_error_found = FALSE OR p_fixed_amount IS NOT NULL) THEN
        G_fatal_err_found := TRUE;
        alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                      'PA_AL_INVALID_OFFSET_METHOD');
    END IF;
  END IF; /* if p_offset_method */
  IF (p_offset_method <> 'N') THEN
    pa_debug.G_err_stage:= 'CHECKING OFFSET LINES';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('validate_rule: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
    IF(p_offset_method = 'C') THEN      /* specific offset proj/task */
      OPEN C_check_task(p_offset_project_id, p_offset_task_id, p_expnd_item_date);
      FETCH C_check_task INTO v_dummy;
        IF C_check_task%NOTFOUND THEN
        G_fatal_err_found := TRUE;
        alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                      'PA_AL_INVALID_OFFSET_DEFN');
        END IF;
      CLOSE C_check_task;
    END IF;   /* endif offset_method */
  END IF;  /* p_offset_method <> */
  IF(p_basis_method NOT IN ( 'S', 'C')) THEN
    pa_debug.G_err_stage:= 'CHECKING BASIS LINES';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('validate_rule: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
    IF (p_basis_method IN( 'P', 'FP')) THEN
      IF (p_basis_balance_category IS NULL) THEN
        G_fatal_err_found := TRUE;
        alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                      'PA_AL_NO_BASIS_BAL_CATGRY');
      END IF ;
      IF (p_basis_amount_type IS NULL) THEN
          G_fatal_err_found := TRUE;
          alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                        'PA_AL_NO_BASIS_AMNT_TYPE');
      END IF ;
      IF ( p_basis_balance_type IS NULL) THEN
          G_fatal_err_found := TRUE;
          alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                        'PA_AL_NO_BASIS_BAL_TYPE');
      END IF;
      IF ( p_basis_balance_category = 'B') THEN
        IF ( p_bas_budget_type_code IS NULL) THEN
          G_fatal_err_found := TRUE;
          alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                        'PA_AL_NO_BASIS_BDGT_TYP_CODE');
        END IF;
      END IF;  /* if p_basis_balance_category */
      IF ( p_basis_balance_category = 'F') THEN  /* added validation for FP_type_id bug 2619977 */
        IF ( G_basis_fin_plan_type_id IS NULL) THEN
          G_fatal_err_found := TRUE;
          alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                        'PA_AL_NO_BASIS_FP_TYPE_ID');
        END IF;
      END IF;  /* if p_basis_balance_category */
    END IF; /* if p_basis_method = 'P' or 'FP' */
  END IF; /* if basis_method NOT IN  */
  pa_debug.G_err_stage:= 'VALIDATING TARGET EXP ORGANIZATION';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('validate_rule: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  IF( p_target_exp_org_id IS NULL OR
      pa_utils2.CheckExpOrg( p_target_exp_org_id) = 'N') THEN
    G_fatal_err_found := TRUE;
    alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                  'PA_AL_INVALID_TARGET_EXP_ORG') ;
  END IF;
  pa_debug.G_err_stage:= 'VALIDATING TARGET EXPENDITURE TYPE';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('validate_rule: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  IF(p_target_exp_type IS NOT NULL) THEN
    OPEN C_exptype_exists(p_target_exp_type);
    FETCH C_exptype_exists INTO v_dummy;
      IF C_exptype_exists%NOTFOUND THEN
        G_fatal_err_found := TRUE;
        alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                      'PA_AL_INVALID_TARGET_EXP_TYPE') ;
      END IF;
    CLOSE C_exptype_exists;
  ELSE
    G_fatal_err_found := TRUE;
    alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                      'PA_AL_INVALID_TARGET_EXP_TYPE') ;
  END IF; /* if p_target_exp_type */
  IF (p_offset_method <> 'N') THEN
    pa_debug.G_err_stage:= 'VALIDATING OFFSET EXP ORGANIZATION';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('validate_rule: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
    IF( p_offset_exp_org_id IS NULL ) THEN
      G_fatal_err_found := TRUE;
      alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                        'PA_AL_UNDEFINED_OFFSET_EXP_ORG') ;
    ELSIF(pa_utils2.CheckExpOrg( p_offset_exp_org_id) = 'N') THEN
      G_fatal_err_found := TRUE;
      alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                        'PA_AL_INVALID_OFFSET_EXP_ORG') ;
    END IF;
    pa_debug.G_err_stage:= 'VALIDATING OFFSET EXPENDITURE TYPE';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('validate_rule: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
         IF ( p_offset_exp_type IS NOT NULL) THEN
      OPEN C_exptype_exists(p_offset_exp_type);
      FETCH C_exptype_exists INTO v_dummy;
        IF C_exptype_exists%NOTFOUND THEN
          G_fatal_err_found := TRUE;
          alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                        'PA_AL_INVALID_OFFSET_EXP_TYPE') ;
        END IF ;
      CLOSE C_exptype_exists;
    ELSE
      G_fatal_err_found := TRUE;
      alloc_errors( p_rule_id, p_run_id, 'R', 'E',
                    'PA_AL_UNDEFINED_OFFSET_EXP_TYPE');
         END IF; /* if p_offset_exp_type */
  END IF; /* p_offset_method */
  /* restore the old G_err_stack */
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    pa_debug.G_err_code := SQLCODE;
    RAISE;
END validate_rule;
-- ------------------------------------------------------------
-- insert_alloc_run_sources
-- ------------------------------------------------------------
PROCEDURE insert_alloc_run_sources( p_rule_id           IN NUMBER
                                  , p_run_id            IN NUMBER
                                  , p_line_num          IN NUMBER
                                  , p_project_id        IN NUMBER
                                  , p_task_id           IN NUMBER
                                  , p_exclude_flag      IN VARCHAR2
                                  , p_creation_date     IN DATE
                                  , p_created_by        IN NUMBER
                                  , p_last_update_date  IN DATE
                                  , p_last_updated_by   IN NUMBER
                                  , p_last_update_login IN NUMBER) IS
CURSOR source_exists IS
  SELECT 1
  FROM pa_alloc_run_sources
  WHERE run_id = p_run_id
  AND project_id = p_project_id
  AND task_id = p_task_id;
v_dummy NUMBER;
allow_insert_flag VARCHAR2(1);
BEGIN
  pa_debug.set_err_stack('ins_alloc_run_sources');
  pa_debug.G_err_code:= 0;
  OPEN source_exists;
  FETCH source_exists INTO v_dummy;
    IF source_exists%NOTFOUND THEN
                /* allow insert if current proj-task not exists */
           allow_insert_flag := 'Y';
    ELSE
           allow_insert_flag := 'N';
                alloc_errors( p_rule_id, p_run_id, 'S', 'W',
                    'PA_AL_DUP_SRC_PROJ_TASK', FALSE, 'Y',
                                                  p_project_id, p_task_id );
    END IF;
  CLOSE source_exists;
  IF (allow_insert_flag = 'Y') THEN
    INSERT INTO PA_ALLOC_RUN_SOURCES (
       RUN_ID
     , RULE_ID
     , LINE_NUM
     , PROJECT_ID
     , EXCLUDE_FLAG
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , LAST_UPDATE_LOGIN
     , TASK_ID )
    VALUES (
       p_run_id
     , p_rule_id
     , p_line_num
     , p_project_id
     , p_exclude_flag
     , p_creation_date
     , p_created_by
     , p_last_update_date
     , p_last_updated_by
     , p_last_update_login
     , p_task_id );
  END IF;
 /*  restore the old stack */
 pa_debug.reset_err_stack;
EXCEPTION
   WHEN OTHERS THEN
     pa_debug.G_err_code := SQLCODE;
     RAISE;
END insert_alloc_run_sources;
-- ------------------------------------------------------------
-- exclude_curr_proj_task
-- ------------------------------------------------------------
FUNCTION exclude_curr_proj_task ( p_run_id     IN NUMBER
                                , p_type       IN VARCHAR2
                                , p_project_id IN NUMBER
                                , p_task_id    IN NUMBER ) RETURN NUMBER IS
CURSOR C_excl_src_proj_task IS
  SELECT project_id, task_id
  FROM pa_alloc_run_sources
  WHERE run_id = p_run_id
  AND exclude_flag = 'Y'
  AND project_id = p_project_id
  AND NVL(task_id, NVL(p_task_id, -1)) = NVL(p_task_id, -1);
CURSOR C_excl_trg_proj_task IS
  SELECT project_id, task_id
  FROM pa_alloc_run_targets
  WHERE run_id = p_run_id
  AND exclude_flag = 'Y'
  AND project_id = p_project_id
  AND NVL(task_id, NVL(p_task_id, -1)) = NVL(p_task_id, -1);
v_dummy1 NUMBER;
v_dummy2 NUMBER;
v_status NUMBER:= 0;
BEGIN
 pa_debug.set_err_stack('exclude_curr_proj_task');
 pa_debug.G_err_code:= 0;
 pa_debug.G_err_stage := 'DETERMINE EXCL_CURR_PROJ_TASK';
 IF P_DEBUG_MODE = 'Y' THEN
    pa_debug.write_file('exclude_curr_proj_task: ' ||  'LOG', pa_debug.G_err_stage);
 END IF;
 IF (p_type = 'SRC') THEN
   OPEN C_excl_src_proj_task;
   FETCH C_excl_src_proj_task INTO v_dummy1, v_dummy2;
     IF C_excl_src_proj_task%NOTFOUND THEN
       v_status := 0;
     ELSE
       v_status := 1;
     END IF;
   CLOSE C_excl_src_proj_task;
 ELSIF (p_type = 'TRG') THEN
   OPEN C_excl_trg_proj_task;
   FETCH C_excl_trg_proj_task INTO v_dummy1, v_dummy2;
     IF C_excl_trg_proj_task%NOTFOUND THEN
       v_status := 0;
     ELSE
       v_status := 1;
     END IF;
   CLOSE C_excl_trg_proj_task;
 END IF;
  /*  restore the old stack */
  pa_debug.reset_err_stack;
  return v_status;
EXCEPTION
  WHEN OTHERS THEN
    return (SQLCODE);
--    return 0;
END exclude_curr_proj_task;
-- ------------------------------------------------------------
-- Build_src_sql
-- ------------------------------------------------------------
Procedure  Build_src_sql( p_project_org_id   IN NUMBER
          ,p_project_type     IN VARCHAR2
          ,p_task_org_id      IN NUMBER
          ,p_service_type     IN VARCHAR2
          ,p_class_category   IN VARCHAR2
          ,p_class_code       IN VARCHAR2
          ,p_project_id       IN NUMBER
          ,p_task_id          IN NUMBER
          ,x_sql_str          OUT NOCOPY VARCHAR2 ) IS
l_proj_org_str  VARCHAR2(80) ;
l_proj_type_str  VARCHAR2(80) ;
l_task_org_str   VARCHAR2(80) ;
l_serv_type_str  VARCHAR2(80) ;
l_class_catg_str VARCHAR2(80) ;
l_class_code_str VARCHAR2(80) ;
l_proj_id_str    VARCHAR2(80) ;
l_task_id_str    VARCHAR2(300) ;
l_select_clause    VARCHAR2(80) ;
l_from_clause     VARCHAR2(80) ;
l_from_str1     VARCHAR2(80) ;
l_from_str2     VARCHAR2(80) ;
l_pc_pp_str     VARCHAR2(80) ;
l_pc_pt_str     VARCHAR2(80) ;
l_where_str0    VARCHAR2(500) ;
l_where_str1    VARCHAR2(80) ;
l_where_str2    VARCHAR2(80) ;
l_where_clause  VARCHAR2(1200) ;
v_csr_id  INTEGER ;
BEGIN
l_proj_org_str  := ' pp.carrying_out_organization_id = :lp_project_org_id ' ;
l_proj_type_str := ' pp.project_type = :lp_project_type '                   ;
l_task_org_str  := ' pt.carrying_out_organization_id = :lp_task_org_id '    ;
l_serv_type_str := ' pt.service_type_code = :lp_service_type_code '         ;
l_class_catg_str:= ' pc.class_category = :lp_class_category '             ;
l_class_code_str:= ' pc.class_code     = :lp_class_code    '             ;
l_proj_id_str   := ' pp.project_id = :lp_project_id '                    ;
l_task_id_str   := ' ( (pt.task_id = :lp_task_id AND '
                   || ' pa_task_utils.check_child_exists(:lp_task_id)=0) OR '
                   || '  (pt.top_task_id = :lp_task_id AND pt.task_id in '
                   || ' (select  pt1.task_id FROM pa_tasks pt1 '
                   || ' WHERE pt1.top_task_id = :lp_task_id  '
                   || ' AND pa_task_utils.check_child_exists(pt1.task_id)=0 )))'  ;
l_select_clause   := 'Select pt.project_id, pt.task_id, pt.top_task_id ' ;
l_from_str1    := ' From pa_project_classes pc, pa_tasks pt, pa_projects pp' ;
l_from_str2    := ' From pa_tasks pt, pa_projects pp' ;
l_pc_pp_str    := ' pp.project_id = pc.project_id ' ;
l_where_str0   := ' where pp.project_id = pt.project_id  AND ' ;
l_where_str1   := ' pa_project_stus_utils.is_project_status_closed(pp.project_status_code)=''N''' ;
l_where_str2   := ' pa_task_utils.check_child_exists(pt.task_id)=0'  ;
IF p_project_org_id is NOT NULL THEN
 l_where_str0 := l_where_str0 || l_proj_org_str || ' AND ' ;
 --  l_where_str0 := l_where_str0 || l_proj_org_str  ;
END IF ;
IF p_project_type is NOT NULL THEN
   l_where_str0 := l_where_str0 || l_proj_type_str || ' AND ' ;
END IF ;
IF p_task_org_id is NOT NULL THEN
   l_where_str0 := l_where_str0 || l_task_org_str || ' AND ' ;
END IF ;
IF p_service_type is NOT NULL THEN
   l_where_str0 := l_where_str0 || l_serv_type_str || ' AND ' ;
END IF ;
IF p_class_category is NOT NULL OR p_class_code is NOT NULL THEN
   l_from_clause  := l_from_str1 ;
   l_where_str0 := l_where_str0 ||l_pc_pp_str|| ' AND ' ;
   IF p_class_category is NOT NULL THEN
      l_where_str0 := l_where_str0 || l_class_catg_str || ' AND ' ;
   END IF ;
   IF p_class_code is NOT NULL THEN
      l_where_str0 := l_where_str0 || l_class_code_str || ' AND ' ;
   END IF ;
ELSE
   l_from_clause  := l_from_str2 ;
END IF ;
IF p_project_id is NOT NULL THEN
   l_where_str0 := l_where_str0 || l_proj_id_str || ' AND ' ;
END IF ;
IF p_task_id is NOT NULL THEN
   l_where_clause := l_where_str0 ||l_where_str1||' AND '||  l_task_id_str  ;
ELSE
 l_where_clause := l_where_str0 || l_where_str1 || ' AND ' || l_where_str2  ;
 --  l_where_clause := l_where_str0 || ';' ;
END IF ;
x_sql_str := l_select_clause || l_from_clause || l_where_clause  ;
EXCEPTION
  WHEN OTHERS THEN
  RAISE ;
END build_src_sql;
-- ------------------------------------------------------------
-- populate_run_sources
-- ------------------------------------------------------------
PROCEDURE populate_run_sources ( p_rule_id               IN NUMBER
                               , p_run_id                IN NUMBER
                               , p_resource_list_id      IN NUMBER
                               , p_source_clnt_extn_flag IN VARCHAR2
							   /* FP.M : Allocation Impact */
							   , p_alloc_resource_struct_type In Varchar2
							   , p_rbs_version_id		 In Number
							   ) IS
CURSOR c_alloc_source_lines IS
  SELECT exclude_flag
  , line_num
  , project_org_id
  , task_org_id
  , project_type
  , class_category
  , class_code
  , service_type
  , project_id
  , task_id
  FROM pa_alloc_source_lines
  WHERE rule_id = p_rule_id
  ORDER BY exclude_flag, line_num;
source_lines_rec c_alloc_source_lines%ROWTYPE;
CURSOR c_leaf_tasks_under_task(p_tsk_id IN NUMBER) IS
  SELECT task_id
  FROM pa_tasks
  WHERE top_task_id = p_tsk_id
  AND pa_task_utils.check_child_exists(task_id) = 0;
leaf_task_rec c_leaf_tasks_under_task%ROWTYPE;
CURSOR c_leaf_tasks_under_proj(p_proj_id IN NUMBER) IS
  SELECT task_id
  FROM pa_tasks
  WHERE project_id = p_proj_id
  AND pa_task_utils.check_child_exists(task_id) = 0;
CURSOR c_alloc_run_src_projects IS
  SELECT project_id, task_id
  FROM pa_alloc_run_sources
  WHERE rule_id = p_rule_id
  AND run_id = p_run_id;
RUN_SRC_PROJ_REC c_alloc_run_src_projects%ROWTYPE;
CURSOR C_top_task (p_tsk_id IN NUMBER)IS
  SELECT top_task_id
  FROM pa_tasks
  WHERE top_task_id = p_tsk_id;
v_top_task_id NUMBER;
v_retcode NUMBER;
v_dummy NUMBER;
v_src_extn_tabtype PA_CLIENT_EXTN_ALLOC.ALLOC_SOURCE_TABTYPE;
v_cx_project_id NUMBER;
v_cx_task_id NUMBER;
v_cx_exclude_flag VARCHAR2(1);
v_status NUMBER :=NULL;
v_err_message VARCHAR2(250);
v_src_sql_str       VARCHAR2 (2000) ;
v_source_csr_id     INTEGER ;
v_src_project_id   NUMBER ;
v_src_task_id   NUMBER ;
v_src_top_task_id NUMBER ;
v_cx_err_flag VARCHAR2(1) ;
BEGIN
  pa_debug.set_err_stack('populate_run_sources');
  pa_debug.G_err_code:= 0;
  IF p_source_clnt_extn_flag = 'Y' THEN
  pa_debug.G_err_stage:= 'READING SRC CLIENT EXTENSION FOR EXCLUDES';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('populate_run_sources: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  /* reset the error_flag */
  G_fatal_err_found := FALSE;
  pa_client_extn_alloc.source_extn(p_rule_id, v_src_extn_tabtype,v_status,v_err_message);
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('populate_run_sources: ' || 'LOG','Client return message: '|| v_err_message);
  END IF;
  IF nvl(v_status,0) <> 0 then
     v_err_message:=nvl(v_err_message,'PA_AL_CE_FAILED');
     alloc_errors(p_rule_id, p_run_id, 'S', 'E', v_err_message, TRUE) ;
  END IF ;
    IF ( v_src_extn_tabtype.count >0 ) THEN
      FOR I in 1..v_src_extn_tabtype.count LOOP
             v_cx_err_flag := 'N' ;
             v_cx_project_id := NVL(v_src_extn_tabtype(I).project_id, 0);
             v_cx_task_id := NVL(v_src_extn_tabtype(I).task_id,0);
             v_cx_exclude_flag := NVL(v_src_extn_tabtype(I).exclude_flag,'N');
                  /* capture all the invalid exclude flags now and error out later */
        IF  is_src_project_valid( v_cx_project_id) = 'N' THEN
            G_fatal_err_found:= TRUE;
            alloc_errors( p_rule_id, p_run_id, 'S', 'E',
                      'PA_AL_INV_PROJECT_TASK_IN_CE',FALSE,'Y',v_cx_project_id);
            IF P_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('populate_run_sources: ' || 'LOG','Client Extension returned an invalid source project:  '
                               || to_char(v_cx_project_id));
            END IF;
            v_cx_err_flag := 'Y' ;
        END IF;
        IF (v_cx_task_id <> 0 AND
            is_src_task_valid( v_cx_project_id, v_cx_task_id) = 'N') THEN
            G_fatal_err_found:= TRUE;
            alloc_errors( p_rule_id, p_run_id, 'S', 'E',
                        'PA_AL_INV_PROJECT_TASK_IN_CE',FALSE,'Y',v_cx_project_id, v_cx_task_id);
            IF P_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('populate_run_sources: ' || 'LOG','Client Extension returned an invalid source task:  '
                                ||to_char( v_cx_task_id) );
            END IF;
            v_cx_err_flag := 'Y' ;
        END IF;
        IF( v_cx_exclude_flag NOT IN ( 'Y', 'N') ) THEN
          G_fatal_err_found:= TRUE;
          alloc_errors( p_rule_id, p_run_id, 'S', 'E',
                        'PA_AL_INVAL_CLNT_EXCL_FLG');
          v_cx_err_flag := 'Y' ;
        END IF;
                  /* capture all the NULL projects now and error out later */
        IF( v_cx_project_id = 0 ) THEN
          G_fatal_err_found:= TRUE;
          alloc_errors( p_rule_id, p_run_id, 'S', 'E', 'PA_AL_CLNT_RETURNED_NO_PROJ');
          v_cx_err_flag := 'Y' ;
        END IF;
        IF (v_cx_err_flag = 'N' AND v_cx_exclude_flag = 'Y') THEN
          IF v_cx_project_id <>0  THEN /* i.e. a valid project */
                                IF v_cx_task_id IS NULL  THEN
                                  /* only valid project_id so insert */
              insert_alloc_run_sources( p_rule_id
                                      , p_run_id
                                      , ( I * -1) /* line_num */
                                      , v_cx_project_id
                                      , v_cx_task_id
                                      , v_cx_exclude_flag
                                      , G_creation_date
                                      , G_created_by
                                      , G_last_update_date
                                      , G_last_updated_by
                                      , G_last_update_login );
                           ELSE /* v_cx_task_id is NOT NULL i.e. a valid task_id */
              /* check if lowest level task */
              IF( pa_task_utils.check_child_exists(v_cx_task_id) = 0) THEN
              /* if lowest level task */
                IF (exclude_curr_proj_task( p_run_id, 'SRC', v_cx_project_id
                                          , v_cx_task_id ) = 0) THEN
                  /* include current project/task, so insert... */
                  insert_alloc_run_sources( p_rule_id
                                          , p_run_id, 0
                                          , v_cx_project_id
                                          , v_cx_task_id
                                          , v_cx_exclude_flag
                                          , G_creation_date
                                          , G_created_by
                                          , G_last_update_date
                                          , G_last_updated_by
                                          , G_last_update_login );
                END IF;
              ELSE  /* not a lowest level task */
                OPEN C_top_task( v_cx_task_id);
                FETCH C_top_task INTO v_top_task_id;
                CLOSE C_top_task;
                IF (v_top_task_id <> v_cx_task_id ) THEN
                  /* not a top task, mid-level task */
                  G_fatal_err_found := TRUE;
                  alloc_errors( p_rule_id, p_run_id, 'S', 'E',
                                'PA_AL_MID_LEVEL_TASK', FALSE,'Y',
                                v_cx_project_id, v_cx_task_id);
                ELSE /* if top_task, explode to lowest level */
                  FOR leaf_task_rec IN c_leaf_tasks_under_task(v_cx_task_id) LOOP
                    IF (exclude_curr_proj_task( p_run_id, 'SRC', v_cx_project_id
                                              , leaf_task_rec.task_id) = 0) THEN
                      /* include current project/task, so insert... */
                      insert_alloc_run_sources( p_rule_id
                                               , p_run_id
                                               , (I * -1) /* line_num */
                                               , v_cx_project_id
                                               , leaf_task_rec.task_id
                                               , v_cx_exclude_flag
                                               , G_creation_date
                                               , G_created_by
                                               , G_last_update_date
                                               , G_last_updated_by
                                               , G_last_update_login );
                    END IF; /* exclude_curr_proj_task */
                  END LOOP;
                END IF; /* top_task */
              END IF; /* pa_task_utils */
            END IF; /* end v_cx_task_id */
          END IF; /* if v_cx_project_id = 0 */
        END IF; /* end exclude_flag = 'Y' */
      END LOOP;
    END IF;  /* end cound>0 */
  END IF; /* end src_extn_flag = 'Y' */
  pa_debug.G_err_stage:= 'READING SRC LINES FOR EXCLUDES';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('populate_run_sources: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  v_source_csr_id := DBMS_SQL.OPEN_CURSOR ; -- added for bug 3799389

  FOR source_lines_rec IN c_alloc_source_lines LOOP
    IF (source_lines_rec.exclude_flag = 'Y') THEN
      build_src_sql( source_lines_rec.project_org_id
                   , source_lines_rec.project_type
                   , source_lines_rec.task_org_id
                   , source_lines_rec.service_type
                   , source_lines_rec.class_category
                   , source_lines_rec.class_code
                   , source_lines_rec.project_id
                   , source_lines_rec.task_id
                   , v_src_sql_str ) ;
        IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('populate_run_sources: ' || 'LOG',v_src_sql_str);
        END IF;
/*        v_source_csr_id := DBMS_SQL.OPEN_CURSOR ;  commented for bug 3799389 */
        DBMS_SQL.PARSE(v_source_csr_id, v_src_sql_str, DBMS_SQL.V7) ;
        IF source_lines_rec.project_org_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_project_org_id',source_lines_rec.project_org_id) ;
        END IF ;
        IF  source_lines_rec.project_type is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_project_type',source_lines_rec.project_type) ;
        END IF ;
        IF source_lines_rec.task_org_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_task_org_id',source_lines_rec.task_org_id) ;
        END IF ;
        IF source_lines_rec.service_type is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_service_type_code',source_lines_rec.service_type) ;
        END IF ;
        IF source_lines_rec.class_category is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_class_category',source_lines_rec.class_category) ;
        END IF ;
        IF source_lines_rec.class_code is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_class_code',source_lines_rec.class_code) ;
        END IF ;
        IF source_lines_rec.project_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_project_id',source_lines_rec.project_id) ;
        END IF ;
        IF source_lines_rec.task_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_task_id',source_lines_rec.task_id) ;
        END IF ;
        DBMS_SQL.DEFINE_COLUMN(v_source_csr_id,1,v_src_project_id ) ;
        DBMS_SQL.DEFINE_COLUMN(v_source_csr_id,2,v_src_task_id ) ;
        DBMS_SQL.DEFINE_COLUMN(v_source_csr_id,3,v_src_top_task_id ) ;
        v_dummy := DBMS_SQL.execute(v_source_csr_id) ;
        LOOP
           IF DBMS_SQL.FETCH_ROWS(v_source_csr_id) = 0 THEN
                 EXIT ;
           END IF ;
           dbms_sql.column_value(v_source_csr_id,1,v_src_project_id) ;
           dbms_sql.column_value(v_source_csr_id,2,v_src_task_id ) ;
           dbms_sql.column_value(v_source_csr_id,3,v_src_top_task_id ) ;
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('populate_run_sources: ' || 'LOG',to_char(v_src_project_id) || to_char(v_src_task_id) ||
                                  to_char(v_src_top_task_id));
           END IF;
           insert_alloc_run_sources( p_rule_id
                                , p_run_id
                                , source_lines_rec.line_num
                                , v_src_project_id
                                , v_src_task_id
                                , source_lines_rec.exclude_flag
                                , G_creation_date
                                , G_created_by
                                , G_last_update_date
                                , G_last_updated_by
                                , G_last_update_login );
        END LOOP;    /* endloop explode srcs  Dynamic sql */
    END IF;     /* End if of source excludes from table */
  END LOOP;    /* endloop read srcs */
  DBMS_SQL.CLOSE_CURSOR(v_source_csr_id ); --added for bug 3799389
  IF p_source_clnt_extn_flag = 'Y' THEN
  pa_debug.G_err_stage:= 'READING SRC CLIENT EXTENSION FOR INCLUDES';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('populate_run_sources: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
    pa_client_extn_alloc.source_extn( p_rule_id, v_src_extn_tabtype,v_status,v_err_message);
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('populate_run_sources: ' || 'LOG','Client return message: '|| v_err_message);
    END IF;
    IF nvl(v_status,0) <> 0 then
      v_err_message:=nvl(v_err_message,'PA_AL_CE_FAILED');
      alloc_errors(p_rule_id, p_run_id, 'S', 'E', v_err_message, TRUE) ;
    END IF ;
    IF (v_src_extn_tabtype.count >0) THEN
      FOR I in 1..v_src_extn_tabtype.count LOOP
        v_cx_err_flag := 'N' ;
        v_cx_project_id :=  NVl(v_src_extn_tabtype(I).project_id, 0);
        v_cx_task_id :=  v_src_extn_tabtype(I).task_id ;
        v_cx_exclude_flag :=  NVL(v_src_extn_tabtype(I).exclude_flag,'N');
        IF  is_src_project_valid( v_cx_project_id) = 'N' THEN
            G_fatal_err_found:= TRUE;
            alloc_errors( p_rule_id, p_run_id, 'S', 'E',
                      'PA_AL_INV_PROJECT_TASK_IN_CE',FALSE,'Y',v_cx_project_id);
            IF P_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('populate_run_sources: ' || 'LOG','Client Extension returned an invalid source project:  '
                               || to_char(v_cx_project_id));
            END IF;
           v_cx_err_flag := 'Y' ;
        END IF;
        IF (v_cx_task_id <> 0 AND
             is_src_task_valid( v_cx_project_id, v_cx_task_id) = 'N') THEN
            G_fatal_err_found:= TRUE;
            alloc_errors( p_rule_id, p_run_id, 'S', 'E',
                        'PA_AL_INV_PROJECT_TASK_IN_CE',FALSE,'Y',v_cx_project_id, v_cx_task_id);
            IF P_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('populate_run_sources: ' || 'LOG','Client Extension returned an invalid source task:  '
                                ||to_char( v_cx_task_id) );
            END IF;
           v_cx_err_flag := 'Y' ;
        END IF;
        IF( v_cx_exclude_flag NOT IN ( 'Y', 'N') ) THEN
          G_fatal_err_found:= TRUE;
          alloc_errors( p_rule_id, p_run_id, 'S', 'E',
                        'PA_AL_INVAL_CLNT_EXCL_FLG');
           v_cx_err_flag := 'Y' ;
        END IF;
        IF (v_cx_err_flag = 'N' AND v_cx_exclude_flag = 'N') THEN
          IF( v_cx_project_id <> 0 ) THEN
             IF v_cx_task_id IS NULL THEN
               FOR each_task in c_leaf_tasks_under_proj(v_cx_project_id) LOOP
                IF (exclude_curr_proj_task( p_run_id, 'SRC', v_cx_project_id,
                                   each_task.task_id ) = 0) THEN
                  /* include current project/task, so insert */
                 insert_alloc_run_sources( p_rule_id
                                    , p_run_id
                                    , to_number(I*-1)
                                    , v_cx_project_id
                                    , each_task.task_id
                                    , 'N'
                                    , G_creation_date
                                    , G_created_by
                                    , G_last_update_date
                                    , G_last_updated_by
                                    , G_last_update_login);
                 END IF ;
               END LOOP ;
             ELSE /* v_cx_task_id is NOT NULL */
              -- check if lowest level task
              IF( pa_task_utils.check_child_exists(v_cx_task_id) = 0) THEN
                IF (exclude_curr_proj_task( p_run_id, 'SRC', v_cx_project_id
                                           , v_cx_task_id ) = 0) THEN
                  /* include current project/task, so insert... */
                  insert_alloc_run_sources( p_rule_id
                                          , p_run_id
                                          , ( I * -1) /* line_num */
                                          , v_cx_project_id
                                          , v_cx_task_id
                                          , v_cx_exclude_flag
                                          , G_creation_date
                                          , G_created_by
                                          , G_last_update_date
                                          , G_last_updated_by
                                          , G_last_update_login );
                END IF;
              ELSE   /* not a lowest level task */
                OPEN C_top_task( v_cx_task_id);
                FETCH C_top_task INTO v_top_task_id;
                CLOSE C_top_task;
                IF (v_top_task_id <> v_cx_task_id ) THEN
                  /* not a top task, mid-level task */
                  G_fatal_err_found := TRUE;
                  alloc_errors( p_rule_id, p_run_id, 'S', 'E',
                                'PA_AL_MID_LEVEL_TASK',FALSE, 'Y',
                                v_cx_project_id, v_cx_task_id );
                ELSE /* if top_task, explode to lowest level */
                  FOR leaf_task_rec IN c_leaf_tasks_under_task(v_cx_task_id) LOOP
                    IF (exclude_curr_proj_task( p_run_id, 'SRC', v_cx_project_id
                                               , leaf_task_rec.task_id) = 0) THEN
                      /* include current project/task, so insert... */
                      insert_alloc_run_sources( p_rule_id
                                               , p_run_id
                                               , (I * -1) /* line_num */
                                               , v_cx_project_id
                                               , leaf_task_rec.task_id
                                               , v_cx_exclude_flag
                                               , G_creation_date
                                               , G_created_by
                                               , G_last_update_date
                                               , G_last_updated_by
                                               , G_last_update_login );
                    END IF; /* exclude_curr_proj */
                  END LOOP;
                END IF; /* if v_top_task_id */
              END IF; /* end pa_task_utils  */
            END IF; /* v_cx_task_id = 0 */
          END IF; /* v_cx_project_id <> 0 */
        END IF; /* end exclude_flag = 'N' */
      END LOOP;
    END IF; /* if count>0 */
  END IF; /* end src_extn_flag = 'Y' */
  pa_debug.G_err_stage:= 'READING SRC LINES FOR INCLUDES';
  v_source_csr_id := DBMS_SQL.OPEN_CURSOR ; -- added for bug 3799389
  FOR source_lines_rec IN c_alloc_source_lines LOOP
    IF (source_lines_rec.exclude_flag = 'N') THEN
      pa_debug.G_err_stage:= 'EXPLODING SOURCE LINES FOR INCLUDES';
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('populate_run_sources: ' ||  'LOG', pa_debug.G_err_stage);
      END IF;
      build_src_sql( source_lines_rec.project_org_id
                   , source_lines_rec.project_type
                   , source_lines_rec.task_org_id
                   , source_lines_rec.service_type
                   , source_lines_rec.class_category
                   , source_lines_rec.class_code
                   , source_lines_rec.project_id
                   , source_lines_rec.task_id
                   , v_src_sql_str ) ;
        IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('populate_run_sources: ' || 'LOG',v_src_sql_str);
        END IF;
/*        v_source_csr_id := DBMS_SQL.OPEN_CURSOR ;  commented for bug 3799389 */
        IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('populate_run_sources: ' || 'LOG','Parsing the code' );
        END IF;
        DBMS_SQL.PARSE(v_source_csr_id, v_src_sql_str, DBMS_SQL.V7) ;
        IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('populate_run_sources: ' || 'LOG','After Parsing the code' );
        END IF;
        IF source_lines_rec.project_org_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_project_org_id',source_lines_rec.project_org_id) ;
        END IF ;
        IF  source_lines_rec.project_type is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_project_type',source_lines_rec.project_type) ;
        END IF ;
        IF source_lines_rec.task_org_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_task_org_id',source_lines_rec.task_org_id) ;
        END IF ;
        IF source_lines_rec.service_type is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_service_type_code',source_lines_rec.service_type) ;
        END IF ;
        IF source_lines_rec.class_category is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_class_category',source_lines_rec.class_category) ;
        END IF ;
        IF source_lines_rec.class_code is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_class_code',source_lines_rec.class_code) ;
        END IF ;
        IF source_lines_rec.project_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_project_id',source_lines_rec.project_id) ;
        END IF ;
        IF source_lines_rec.task_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_source_csr_id,':lp_task_id',source_lines_rec.task_id) ;
        END IF ;
        DBMS_SQL.DEFINE_COLUMN(v_source_csr_id,1,v_src_project_id ) ;
        DBMS_SQL.DEFINE_COLUMN(v_source_csr_id,2,v_src_task_id ) ;
        DBMS_SQL.DEFINE_COLUMN(v_source_csr_id,3,v_src_top_task_id ) ;
        IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('populate_run_sources: ' || 'LOG','Executing the code' );
        END IF;
        v_dummy := DBMS_SQL.execute(v_source_csr_id) ;
        IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('populate_run_sources: ' || 'LOG','After Executing the code' );
        END IF;
        LOOP
           IF DBMS_SQL.FETCH_ROWS(v_source_csr_id) = 0 THEN
                 EXIT ;
           END IF ;
           dbms_sql.column_value(v_source_csr_id,1,v_src_project_id) ;
           dbms_sql.column_value(v_source_csr_id,2,v_src_task_id ) ;
           dbms_sql.column_value(v_source_csr_id,3,v_src_top_task_id ) ;
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('populate_run_sources: ' || 'LOG',to_char(v_src_project_id) || to_char(v_src_task_id) ||
                                  to_char(v_src_top_task_id));
           END IF;
        -- check if lowest level task
        IF( pa_task_utils.check_child_exists(v_src_task_id)= 0) THEN
          /* if lowest level task */
          IF (exclude_curr_proj_task( p_run_id, 'SRC', v_src_project_id
                                     , v_src_task_id ) = 0) THEN
            /* include current project/task, so insert */
            insert_alloc_run_sources( p_rule_id
                                    , p_run_id
                                    , to_number(source_lines_rec.line_num)
                                    , v_src_project_id
                                    , v_src_task_id
                                    , source_lines_rec.exclude_flag
                                    , G_creation_date
                                    , G_created_by
                                    , G_last_update_date
                                    , G_last_updated_by
                                    , G_last_update_login);
          END IF;
        ELSE /* not a lowest level task */
          IF (v_src_top_task_id <> v_src_task_id ) THEN
            /* not a top task, mid-level task */
            G_fatal_err_found := TRUE;
            alloc_errors( p_rule_id, p_run_id, 'S', 'E',
                          'PA_AL_MID_LEVEL_TASK', FALSE, 'Y',
                          v_src_project_id, v_src_task_id);
          ELSE     /* if top_task, explode to lowest level */
            FOR leaf_task_rec IN c_leaf_tasks_under_task(v_src_task_id) LOOP
              IF (exclude_curr_proj_task( p_run_id, 'SRC', v_src_project_id
                                         , leaf_task_rec.task_id) = 0) THEN
                /* include current project/task, so insert */
                insert_alloc_run_sources( p_rule_id
                                        , p_run_id
                                        , source_lines_rec.line_num
                                        , v_src_project_id
                                        , leaf_task_rec.task_id
                                        , source_lines_rec.exclude_flag
                                        , G_creation_date
                                        , G_created_by
                                        , G_last_update_date
                                        , G_last_updated_by
                                        , G_last_update_login );
              END IF;  /* exclude_curr_proj */
            END LOOP;  /* End of leaf_task_rec  */
          END IF; /* if v_top_task */
        END IF;   /* end pa_task_utils */
      END LOOP;   /* end alloc_sources for loop - Dyn sql*/
    END IF;       /* end exclude_flag = 'N' */
  END LOOP;       /* alloc_source_lines */
  DBMS_SQL.CLOSE_CURSOR(v_source_csr_id );  --added for bug 3799389
  IF (p_resource_list_id IS NOT NULL ) THEN
    /* -- validate_srce_proj_for_RL ----------------------- */
    pa_debug.G_err_stage:= 'VALIDATING RSRCE ASSIGNMENTS TO SRC PROJECTS';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('populate_run_sources: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
	FOR run_src_proj_rec IN c_alloc_run_src_projects LOOP
      OPEN C_proj_in_RL( run_src_proj_rec.project_id
                       , p_resource_list_id
						/* FP.M : ALlocation Impact */
					   , p_alloc_resource_struct_type
					   , p_rbs_version_id);
      FETCH C_proj_in_RL INTO v_dummy;
        IF C_proj_in_RL%NOTFOUND THEN
          G_fatal_err_found := TRUE;
          alloc_errors( p_rule_id, p_run_id, 'S', 'E',
                        'PA_AL_UNASSIGNED_SRC_RL', FALSE, 'Y',
                                                                run_src_proj_rec.project_id,
                                                                run_src_proj_rec.task_id );
        END IF;
      CLOSE C_proj_in_RL;
    END LOOP;
  END IF;  /* p_resource_list_id */
  /*  restore the old stack */
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    pa_debug.G_err_code := SQLCODE;
    RAISE;
END populate_run_sources;
-- ------------------------------------------------------------
-- insert_alloc_run_targets
-- ------------------------------------------------------------
PROCEDURE insert_alloc_run_targets( p_rule_id            IN NUMBER
                                  , p_run_id            IN NUMBER
                                  , p_line_num          IN NUMBER
                                  , p_project_id        IN NUMBER
                                  , p_task_id           IN NUMBER
                                  , p_line_percent      IN NUMBER
                                  , p_exclude_flag      IN VARCHAR2
                                  , p_creation_date     IN DATE
                                  , p_created_by        IN NUMBER
                                  , p_last_update_date  IN DATE
                                  , p_last_updated_by   IN NUMBER
                                  , p_last_update_login IN NUMBER
                                  , p_bas_method        IN VARCHAR2
                                  , p_dup_targets_flag  IN VARCHAR2 ) IS
CURSOR target_exists IS
  SELECT 1
  FROM pa_alloc_run_targets
  WHERE run_id = p_run_id
  AND project_id = p_project_id
  AND task_id = p_task_id;
v_dummy NUMBER;
allow_insert_flag VARCHAR2(1):= 'Y';
x_budget_version_id PA_BUDGET_VERSIONS.budget_version_id%TYPE := Null; /* added bug2619977 */
x_return_status VARCHAR2(2000) := Null; /* added bug2619977 */
x_msg_count     NUMBER         := 0   ; /* added bug2619977 */
x_msg_data      VARCHAR2(2000) := Null; /* added bug2619977 */
BEGIN
  pa_debug.set_err_stack('insert_alloc_run_targets');
  pa_debug.G_err_code:= 0;
  IF p_dup_targets_flag = 'N'THEN
  /* allow insert only if current proj-task does NOT exist */
    OPEN target_exists;
    FETCH target_exists INTO v_dummy;
      IF target_exists%NOTFOUND THEN
        allow_insert_flag := 'Y';
      ELSE
        allow_insert_flag := 'N';
      END IF;
    CLOSE target_exists;
  END IF;
  IF (allow_insert_flag = 'Y') THEN
      /* added if condition for bug 2619977 */
      /* Invoking FP API to get budget_version_id. Will populate the ID in
         pa_alloc_run_targets based on budget type or FP type selected. After
         this processing become same for both basis - budgets and FPs */
	PA_FIN_PLAN_UTILS.GET_COST_BASE_VERSION_INFO
     (  p_project_id
       ,G_basis_fin_plan_Type_id
       ,G_basis_budget_type_code
       ,x_budget_version_id
       ,x_return_status
       ,x_msg_count
       ,x_msg_data
	 );
 IF P_DEBUG_MODE = 'Y' THEN
    pa_debug.write_file('insert_alloc_run_targets: ' || 'LOG','Fetching budget version id for project ['|| to_char(p_project_id) ||
                           '] Fin plan type ['||to_char(G_basis_fin_plan_Type_id) ||
                           '] Budget type code ['||G_basis_budget_type_code ||
                           '] Budget version ['||to_char(x_budget_version_id) ||
                           '] Return status ['||x_return_status||']' );
 END IF;
 ---- Here needs a validation of
/******** Need to handle the if error is generated in API *****/
  INSERT INTO PA_ALLOC_RUN_TARGETS (
      RUN_ID
    , RULE_ID
    , LINE_NUM
    , PROJECT_ID
    , EXCLUDE_FLAG
    , TASK_ID
    , LINE_PERCENT
    , BUDGET_VERSION_ID /* added bug 2619977 */
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN )
    VALUES (
      p_run_id
    , p_rule_id
    , p_line_num
    , p_project_id
    , p_exclude_flag
    , p_task_id
    , DECODE( p_bas_method, 'S', NULL, 'P', NULL, p_line_percent )
    , x_budget_version_id  /* added bug 2619977 */
    , p_creation_date
    , p_created_by
    , p_last_update_date
    , p_last_updated_by
    , p_last_update_login );
END IF;
  /* restore the old stack */
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    pa_debug.G_err_code := SQLCODE;
    RAISE;
END insert_alloc_run_targets;
-- ------------------------------------------------------------
-- Build_tgt_sql
-- ------------------------------------------------------------
Procedure  Build_tgt_sql( p_project_org_id   IN NUMBER
          ,p_project_type     IN VARCHAR2
          ,p_task_org_id      IN NUMBER
          ,p_service_type     IN VARCHAR2
          ,p_class_category   IN VARCHAR2
          ,p_class_code       IN VARCHAR2
          ,p_project_id       IN NUMBER
          ,p_task_id          IN NUMBER
          ,p_billable_only_flag    IN VARCHAR2
          ,p_expnd_item_date  IN DATE
          , p_limit_target_projects_code IN VARCHAR2
          ,x_sql_str          OUT NOCOPY VARCHAR2 ) IS
l_proj_org_str  VARCHAR2(80) ;
l_proj_type_str  VARCHAR2(80) ;
l_task_org_str   VARCHAR2(80) ;
l_serv_type_str  VARCHAR2(80) ;
l_class_catg_str VARCHAR2(80) ;
l_class_code_str VARCHAR2(80) ;
l_proj_id_str    VARCHAR2(80) ;
l_task_id_str    VARCHAR2(255) ;
l_billable_str   VARCHAR2(80)  ;
l_expnd_item_str VARCHAR2(120) ;
l_select_clause    VARCHAR2(80) ;
l_from_clause     VARCHAR2(120) ;
l_from_str1     VARCHAR2(100) ;
l_from_str2     VARCHAR2(80) ;
l_pc_pp_str     VARCHAR2(80) ;
l_pc_pt_str     VARCHAR2(80) ;
l_where_str0    VARCHAR2(1300) ;
l_where_str1    VARCHAR2(200) ;
l_where_str2    VARCHAR2(80) ;
l_where_clause  VARCHAR2(1500) ;
v_csr_id  INTEGER ;
BEGIN
  pa_debug.set_err_stack('build_tgt_sql');
  pa_debug.G_err_code:= 0;
l_proj_org_str  := ' pp.carrying_out_organization_id = :lp_project_org_id ' ;
l_proj_type_str := ' pp.project_type = :lp_project_type '                   ;
l_task_org_str  := ' pt.carrying_out_organization_id = :lp_task_org_id '    ;
l_serv_type_str := ' pt.service_type_code = :lp_service_type_code '         ;
l_class_catg_str:= ' pc.class_category = :lp_class_category '             ;
l_class_code_str:= ' pc.class_code     = :lp_class_code    '             ;
l_proj_id_str   := ' pp.project_id = :lp_project_id '                    ;
l_task_id_str   := ' ( (pt.task_id =:lp_task_id AND pt.chargeable_flag=''Y'') OR '
                   || '  (pt.top_task_id = :lp_task_id AND pt.task_id in '
                   || ' (select  pt1.task_id FROM pa_tasks pt1 '
                   || ' WHERE pt1.top_task_id = :lp_task_id  '
                   || ' AND pt1.chargeable_flag = ''Y'' )))'  ;
l_billable_str  := ' pt.billable_flag = :lp_billable_only_flag ' ;
l_expnd_item_str:= ' :p_expnd_item_date BETWEEN  nvl(pt.start_date,:p_expnd_item_date) AND NVL(pt.completion_date, :p_expnd_item_date) ' ;
l_select_clause   := 'Select pt.project_id, pt.task_id, pt.top_task_id ' ;
if p_limit_target_projects_code = 'O' then
  l_from_str1    := ' From pa_project_classes pc, pa_tasks pt, pa_projects pp ' ;
  l_from_str2    := ' From pa_tasks pt, pa_projects pp ' ;
  l_where_str0   := ' where pp.project_id = pt.project_id AND ' ;
else
  l_from_str1    := ' From pa_project_classes pc, pa_tasks pt, pa_cross_chargeable_ou_v pcou, pa_projects_all pp ' ;
  l_from_str2    := ' From pa_tasks pt, pa_cross_chargeable_ou_v pcou, pa_projects_all pp ' ;
  --l_where_str0   := ' where pp.project_id = pt.project_id AND nvl(pp.org_id,''0'') = nvl(pcou.recvr_org_id, ''0'')  AND ' ;
  l_where_str0   := ' where pp.project_id = pt.project_id AND  pp.org_id  = nvl(pcou.recvr_org_id, ''0'')  AND ' ;
  if p_limit_target_projects_code = 'L' then
   l_where_str0 := l_where_str0 || 'pcou.prvdr_legal_entity_id = pcou.recvr_legal_entity_id AND ' ;
  end if ;
  if p_limit_target_projects_code = 'B' then
   l_where_str0 := l_where_str0 || 'pcou.business_group_id = pcou.recvr_business_group_id AND ' ;
  end if ;
end if ;
l_pc_pp_str    := ' pp.project_id = pc.project_id ' ;
l_where_str1   := ' pa_project_stus_utils.is_project_status_closed(pp.project_status_code)=''N'' '||
                  ' AND pa_project_utils.check_project_action_allowed( pp.project_id, ''NEW_TXNS'') = ''Y'' ' ;
l_where_str2   := '  pt.chargeable_flag= ''Y'' '   ;
IF p_project_org_id is NOT NULL THEN
 l_where_str0 := l_where_str0 || l_proj_org_str || ' AND ' ;
 --  l_where_str0 := l_where_str0 || l_proj_org_str  ;
END IF ;
IF p_project_type is NOT NULL THEN
   l_where_str0 := l_where_str0 || l_proj_type_str || ' AND ' ;
END IF ;
IF p_task_org_id is NOT NULL THEN
   l_where_str0 := l_where_str0 || l_task_org_str || ' AND ' ;
END IF ;
IF p_service_type is NOT NULL THEN
   l_where_str0 := l_where_str0 || l_serv_type_str || ' AND ' ;
END IF ;
IF p_class_category is NOT NULL OR p_class_code is NOT NULL THEN
   l_from_clause  := l_from_str1 ;
   l_where_str0 := l_where_str0 ||l_pc_pp_str|| ' AND ' ;
   IF p_class_category is NOT NULL THEN
      l_where_str0 := l_where_str0 || l_class_catg_str || ' AND ' ;
   END IF ;
   IF p_class_code is NOT NULL THEN
      l_where_str0 := l_where_str0 || l_class_code_str || ' AND ' ;
   END IF ;
ELSE
   l_from_clause  := l_from_str2 ;
END IF ;
-- If billable is set select all billable tasks else should select all chargeable tasks.
IF ( nvl(p_billable_only_flag,'N') = 'Y' )  THEN
   l_where_str0 := l_where_str0 || l_billable_str || ' AND ' ;
END IF ;
IF p_project_id is NOT NULL THEN
   l_where_str0 := l_where_str0 || l_proj_id_str || ' AND ' ;
END IF ;
IF p_task_id is NOT NULL THEN
   l_where_str0 := l_where_str0 ||l_task_id_str ||' AND '   ;
END IF ;
 l_where_clause := l_where_str0 || l_where_str1 || ' AND ' || l_where_str2 || ' AND ' || l_expnd_item_str ;
   l_where_clause := l_where_clause || ' AND pp.template_flag = ''N''' ;
x_sql_str := l_select_clause || l_from_clause || l_where_clause  ;
  /* restore the old stack */
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    pa_debug.G_err_code := SQLCODE;
  RAISE ;
END build_tgt_sql;
-- ------------------------------------------------------------
-- populate_run_targets
-- ------------------------------------------------------------
PROCEDURE populate_run_targets( p_rule_id           IN NUMBER
                              , p_run_id           IN NUMBER
                              , p_basis_method     IN VARCHAR2
                              , p_bas_budget_type_code         IN VARCHAR2
                              , p_bas_budget_entry_method_code IN VARCHAR2
                              , p_resource_list_id IN NUMBER
                              , p_trgt_client_extn IN VARCHAR2
                              , p_dup_targets_flag IN VARCHAR2
                              , p_expnd_item_date IN DATE
                              , p_limit_target_projects_code  IN VARCHAR2
                              , x_basis_method OUT NOCOPY VARCHAR2
							  /* FP.M : Allocation Impact */
							  , p_basis_resource_struct_type in varchar2
							  , p_rbs_version_id in Number
							  ) IS
CURSOR c_alloc_target_lines  IS
  SELECT exclude_flag
  , line_num
  , project_org_id
  , task_org_id
  , project_type
  , class_category
  , class_code
  , service_type
  , project_id
  , task_id
  , billable_only_flag
  , line_percent
  FROM pa_alloc_target_lines
  WHERE rule_id = p_rule_id
  ORDER BY 1, 2;
target_lines_rec c_alloc_target_lines%ROWTYPE;
Cursor c_chargeable_tasks_in_proj (x_project_id IN NUMBER,
                                   x_ei_date    IN DATE  ) is
    select project_id, task_id
      from pa_tasks pt
     where pt.project_id = x_project_id
       AND pt.chargeable_flag = 'Y'
       AND x_ei_date between nvl(pt.start_date,x_ei_date) and nvl(pt.completion_date,x_ei_date) ;
CURSOR c_alloc_run_trg_projects IS
  SELECT project_id, task_id
  FROM pa_alloc_run_targets
  WHERE run_id = p_run_id;
CURSOR c_rule_entry_level_code IS
  SELECT entry_level_code
  FROM pa_budget_entry_methods
  WHERE budget_entry_method_code = p_bas_budget_entry_method_code;
CURSOR c_proj_entry_level_code(p_proj_id IN NUMBER) IS
  SELECT entry_level_code
  FROM pa_budget_entry_methods
  WHERE budget_entry_method_code =
        ( SELECT budget_entry_method_code
          FROM pa_budget_versions
          WHERE project_id = p_proj_id
          AND current_flag = 'Y'
          AND budget_type_code = p_bas_budget_type_code
          AND budget_entry_method_code = p_bas_budget_entry_method_code );
CURSOR C_target_line_exists IS
  SELECT 1
  FROM pa_alloc_target_lines
  WHERE rule_id = p_rule_id;
v_trg_extn_tabtype PA_CLIENT_EXTN_ALLOC.ALLOC_TARGET_TABTYPE;
v_top_task_id NUMBER;
v_retcode NUMBER;
v_dummy NUMBER;
v_dummy_target NUMBER;
v_rule_level_code VARCHAR2(1);
v_proj_level_code VARCHAR2(1);
v_cx_project_id NUMBER;
v_cx_task_id NUMBER;
v_cx_percent NUMBER;
v_cx_exclude_flag VARCHAR2(1);
v_status NUMBER :=NULL;
v_err_message VARCHAR2(250);
v_tgt_sql_str       VARCHAR2 (2000) ;
v_target_csr_id     INTEGER ;
v_tgt_project_id   NUMBER ;
v_tgt_task_id   NUMBER ;
v_tgt_top_task_id NUMBER ;
v_cx_err_flag VARCHAR2(1) ;
FUNCTION check_line_percent RETURN NUMBER IS
CURSOR c_check_line_percent IS
  SELECT distinct line_num, nvl(line_percent,0) line_percent
  FROM pa_alloc_run_targets
  WHERE rule_id = p_rule_id
  AND   run_id = p_run_id;
  v_percent NUMBER;
  v_tot_percent number ;
  v_line_no number ;
BEGIN
  v_percent := 0 ;
  v_tot_percent := 0 ;
  For line_percent_rec in c_check_line_percent LOOP
  v_tot_percent := v_tot_percent + line_percent_rec.line_percent ;
  END LOOP ;
  IF ( v_tot_percent <>100 ) THEN
         v_tot_percent:= 0;
  END IF;
  RETURN v_tot_percent;
EXCEPTION
  WHEN OTHERS THEN
  raise;
END check_line_percent;
BEGIN
  pa_debug.set_err_stack('populate_run_targets');
  pa_debug.G_err_code:= 0;
  x_basis_method := p_basis_method;
  IF ( p_basis_method = 'FS' OR p_basis_method ='FP') THEN
    IF (p_trgt_client_extn = 'Y') THEN
        open c_target_line_exists;
        fetch c_target_line_exists
        into v_dummy_target;
        IF c_target_line_exists%FOUND THEN
           alloc_errors( p_rule_id, p_run_id, 'T', 'W',
                    'PA_AL_LINE_PERCENT_IGNORED');
           IF ( p_basis_method = 'FS') THEN
                x_basis_method := 'S';
           ELSE
                x_basis_method := 'P';
           END IF;
        END IF; /** Target line exists **/
        close c_target_line_exists;
     END IF;/** client_extn = 'Y' **/
  END IF;    /* end p_basis_method */
  IF (p_trgt_client_extn = 'Y') THEN
    pa_debug.G_err_stage:= 'READING TRG CLIENT EXTENSION FOR EXCLUDES';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('populate_run_targets: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
    pa_client_extn_alloc.target_extn(p_rule_id, v_trg_extn_tabtype,v_status,v_err_message);
    IF nvl(v_status,0) <>0 THEN
       v_err_message:=nvl(v_err_message,'PA_AL_CE_FAILED');
       alloc_errors(p_rule_id,p_run_id,'T','E',v_err_message,TRUE);
    END IF;
    IF ( v_trg_extn_tabtype.count >0 ) THEN
      FOR I in 1..v_trg_extn_tabtype.count LOOP
        v_cx_err_flag := 'N' ;
        v_cx_project_id := NVl(v_trg_extn_tabtype(I).project_id, 0);
        v_cx_task_id:= NVL(v_trg_extn_tabtype(I).task_id,0);
        v_cx_percent:= v_trg_extn_tabtype(I).percent;   /* for bug 2013779 */
        v_cx_exclude_flag:= NVl(v_trg_extn_tabtype(I).exclude_flag,'N');
        /* capture all the invalid exclude flags now and error out later */
        IF  is_tgt_project_valid( v_cx_project_id) = 'N' THEN
            G_fatal_err_found:= TRUE;
            alloc_errors( p_rule_id, p_run_id, 'T', 'E',
                        'PA_AL_INV_PROJECT_TASK_IN_CE',FALSE,'Y',v_cx_project_id);
            IF P_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('populate_run_targets: ' || 'LOG','Client Extension returned an invalid target project:  '
                                        ||to_char(v_cx_project_id));
            END IF;
            v_cx_err_flag := 'Y' ;
        END IF;
        IF (v_cx_task_id <> 0 AND
           is_tgt_task_valid( v_cx_project_id, v_cx_task_id) = 'N' ) THEN
            G_fatal_err_found:= TRUE;
            alloc_errors( p_rule_id, p_run_id, 'T', 'E',
                        'PA_AL_INV_PROJECT_TASK_IN_CE',FALSE,'Y',v_cx_project_id, v_cx_task_id);
            IF P_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('populate_run_targets: ' || 'LOG','Client Extension returned an invalid target task:  '
                   || to_char(v_cx_task_id));
            END IF;
            v_cx_err_flag := 'Y' ;
        END IF;
        IF( v_cx_exclude_flag NOT IN ( 'Y', 'N') ) THEN
          G_fatal_err_found:= TRUE;
          alloc_errors( p_rule_id, p_run_id, 'S', 'E',
                        'PA_AL_INVAL_CLNT_EXCL_FLG');
            v_cx_err_flag := 'Y' ;
        END IF;
        /* capture all NULL projects and error out */
        IF (v_cx_project_id = 0) THEN
          G_fatal_err_found:= TRUE;
          alloc_errors( p_rule_id, p_run_id, 'T', 'E',
                        'PA_AL_CLNT_RETURNED_NO_PROJ');
          v_cx_err_flag := 'Y' ;
        END IF;
        IF (v_cx_err_flag = 'N' AND v_cx_exclude_flag = 'Y')  THEN
           IF (v_cx_task_id is NULL OR
              (pa_task_utils.check_child_exists(v_cx_task_id)= 0)) THEN
                 insert_alloc_run_targets( p_rule_id, p_run_id
                                    , (I * -1) /* line_num */
                                    , v_cx_project_id
                                    , v_cx_task_id
                                    , v_cx_percent
                                    , v_cx_exclude_flag
                                    , G_creation_date
                                    , G_created_by
                                    , G_last_update_date
                                    , G_last_updated_by
                                    , G_last_update_login
                                    , x_basis_method
                                    , p_dup_targets_flag );
           ELSE
             G_fatal_err_found := TRUE;
             alloc_errors( p_rule_id, p_run_id, 'T', 'E',
                              'PA_AL_NOT_A_CHARGEABLE_TASK',FALSE,'Y',
                              v_cx_project_id,
                              v_cx_task_id );
           END IF; /* exclude_curr_proj_task */
        END IF; /* exclude_flag */
      END LOOP;
    END IF; /* count */
  END IF; /* if p_trgt_client_extn */
  pa_debug.G_err_stage:= 'READING TRG LINES FOR EXCLUDES';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('populate_run_targets: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  v_target_csr_id := DBMS_SQL.OPEN_CURSOR ; --added for bug 3799389
  FOR target_lines_rec IN c_alloc_target_lines LOOP
    IF (target_lines_rec.exclude_flag = 'Y') THEN
      build_tgt_sql( target_lines_rec.project_org_id
                   , target_lines_rec.project_type
                   , target_lines_rec.task_org_id
                   , target_lines_rec.service_type
                   , target_lines_rec.class_category
                   , target_lines_rec.class_code
                   , target_lines_rec.project_id
                   , target_lines_rec.task_id
                   , target_lines_rec.billable_only_flag
                   , p_expnd_item_date
                   , p_limit_target_projects_code
                   , v_tgt_sql_str ) ;
        IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('populate_run_targets: ' || 'LOG',v_tgt_sql_str);
        END IF;
/*        v_target_csr_id := DBMS_SQL.OPEN_CURSOR ; commented for bug 3799389 */
        DBMS_SQL.PARSE(v_target_csr_id, v_tgt_sql_str, DBMS_SQL.V7) ;
        IF target_lines_rec.project_org_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_project_org_id',target_lines_rec.project_org_id) ;
        END IF ;
        IF  target_lines_rec.project_type is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_project_type',target_lines_rec.project_type) ;
        END IF ;
        IF target_lines_rec.task_org_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_task_org_id',target_lines_rec.task_org_id) ;
        END IF ;
        IF target_lines_rec.service_type is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_service_type_code',target_lines_rec.service_type) ;
        END IF ;
        IF target_lines_rec.class_category is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_class_category',target_lines_rec.class_category) ;
        END IF ;
        IF target_lines_rec.class_code is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_class_code',target_lines_rec.class_code) ;
        END IF ;
        IF target_lines_rec.project_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_project_id',target_lines_rec.project_id) ;
        END IF ;
        IF target_lines_rec.task_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_task_id',target_lines_rec.task_id) ;
        END IF ;
        IF p_expnd_item_date is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':p_expnd_item_date',p_expnd_item_date) ;
        END IF ;
        IF ( nvl(target_lines_rec.billable_only_flag,'N') = 'Y' )  THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_billable_only_flag',target_lines_rec.billable_only_flag) ;
        END IF ;
        DBMS_SQL.DEFINE_COLUMN(v_target_csr_id,1,v_tgt_project_id ) ;
        DBMS_SQL.DEFINE_COLUMN(v_target_csr_id,2,v_tgt_task_id ) ;
        DBMS_SQL.DEFINE_COLUMN(v_target_csr_id,3,v_tgt_top_task_id ) ;
        v_dummy := DBMS_SQL.execute(v_target_csr_id) ;
        LOOP
           IF DBMS_SQL.FETCH_ROWS(v_target_csr_id) = 0 THEN
                 EXIT ;
           END IF ;
           dbms_sql.column_value(v_target_csr_id,1,v_tgt_project_id) ;
           dbms_sql.column_value(v_target_csr_id,2,v_tgt_task_id ) ;
           dbms_sql.column_value(v_target_csr_id,3,v_tgt_top_task_id ) ;
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('populate_run_targets: ' || 'LOG',to_char(v_tgt_project_id) || to_char(v_tgt_task_id) ||
                                  to_char(v_tgt_top_task_id));
           END IF;
        insert_alloc_run_targets( p_rule_id
                                , p_run_id
                                , target_lines_rec.line_num
                                , v_tgt_project_id
                                , v_tgt_task_id
                                , target_lines_rec.line_percent
                                , target_lines_rec.exclude_flag
                                , G_creation_date
                                , G_created_by
                                , G_last_update_date
                                , G_last_updated_by
                                , G_last_update_login
                                , x_basis_method
                                , p_dup_targets_flag );
      END LOOP; /* for c_alloc_targets */
    END IF;
  END LOOP; /* for c_alloc_target_lines */
  DBMS_SQL.CLOSE_CURSOR(v_target_csr_id );  --added for bug 3799389
  IF (p_trgt_client_extn = 'Y') THEN
    pa_debug.G_err_stage:= 'READING TRG CLIENT EXTENSION FOR INCLUDES';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('populate_run_targets: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
    pa_client_extn_alloc.target_extn( p_rule_id, v_trg_extn_tabtype,v_status, v_err_message);
    IF nvl(v_status,0) <>0 THEN
       v_err_message:=nvl(v_err_message,'PA_AL_CE_FAILED');
       alloc_errors(p_rule_id,p_run_id,'T','E',v_err_message,TRUE);
    END IF;
    IF (v_trg_extn_tabtype.count >0) THEN
      FOR I in 1..v_trg_extn_tabtype.count LOOP
        v_cx_project_id:= NVL(v_trg_extn_tabtype(I).project_id, 0);
        v_cx_task_id := v_trg_extn_tabtype(I).task_id;
        v_cx_percent:= v_trg_extn_tabtype(I).percent; /* bug 2013779 */
        v_cx_exclude_flag := NVL(v_trg_extn_tabtype(I).exclude_flag, 'N');
        IF v_cx_exclude_flag = 'N' THEN
          IF (v_cx_project_id <> 0 ) THEN
          IF ( v_cx_task_id IS NOT NULL ) THEN /* if task_id is NOT NULL */
            /*  check if lowest level task */
            IF( pa_task_utils.check_child_exists(v_cx_task_id)= 0) THEN
              /* if lowest level chargeable task */
               IF (exclude_curr_proj_task( p_run_id, 'TRG', v_cx_project_id
                                        , v_cx_task_id ) = 0) THEN
                /* include current project/task, so insert... */
                insert_alloc_run_targets( p_rule_id, p_run_id
                                        , (I * -1) /* line_num */
                                        , v_cx_project_id
                                        , v_cx_task_id
                                        , v_cx_percent
                                        , v_cx_exclude_flag
                                        , G_creation_date
                                        , G_created_by
                                        , G_last_update_date
                                        , G_last_updated_by
                                        , G_last_update_login
                                        , x_basis_method
                                        , p_dup_targets_flag );
               END IF; /* exclude_curr_proj_task */
            ELSE
                G_fatal_err_found := TRUE;
                alloc_errors( p_rule_id, p_run_id, 'T', 'E',
                              'PA_AL_NOT_A_CHARGEABLE_TASK',FALSE,'Y',
                              v_cx_project_id,
                              v_cx_task_id );
            END IF; /* pa_task_utils */
          ELSE
             FOR chargeable_tasks in c_chargeable_tasks_in_proj(v_cx_project_id
                                                                ,p_expnd_item_date)
             LOOP
                insert_alloc_run_targets( p_rule_id, p_run_id
                                        , (I * -1) /* line_num */
                                        , v_cx_project_id
                                        , chargeable_tasks.task_id
                                        , v_cx_percent
                                        , v_cx_exclude_flag
                                        , G_creation_date
                                        , G_created_by
                                        , G_last_update_date
                                        , G_last_updated_by
                                        , G_last_update_login
                                        , x_basis_method
                                        , p_dup_targets_flag );
             END LOOP ;
          END IF; /* v_cx_task_id <> 0 */
         END IF ; /* v_cx_project_id <> 0 */
        END IF;  /* v_cx_exclude_flag = N */
      END LOOP;
    END IF;  /* if count>0 */
  END IF; /* trg_lnc_extn_flag */
  pa_debug.G_err_stage:= 'READING TRG LINES FOR INCLUDES';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('populate_run_targets: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  v_target_csr_id := DBMS_SQL.OPEN_CURSOR ;  --added for bug 3799389
  FOR target_lines_rec IN c_alloc_target_lines LOOP
    IF (target_lines_rec.exclude_flag = 'N') THEN
      build_tgt_sql( target_lines_rec.project_org_id
                   , target_lines_rec.project_type
                   , target_lines_rec.task_org_id
                   , target_lines_rec.service_type
                   , target_lines_rec.class_category
                   , target_lines_rec.class_code
                   , target_lines_rec.project_id
                   , target_lines_rec.task_id
                   , target_lines_rec.billable_only_flag
                   , p_expnd_item_date
                   , p_limit_target_projects_code
                   , v_tgt_sql_str ) ;
        IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('populate_run_targets: ' || 'LOG',v_tgt_sql_str);
        END IF;
/*        v_target_csr_id := DBMS_SQL.OPEN_CURSOR ;  commented for bug 3799389 */
        DBMS_SQL.PARSE(v_target_csr_id, v_tgt_sql_str, DBMS_SQL.V7) ;
        IF target_lines_rec.project_org_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_project_org_id',target_lines_rec.project_org_id) ;
        END IF ;
        IF  target_lines_rec.project_type is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_project_type',target_lines_rec.project_type) ;
        END IF ;
        IF target_lines_rec.task_org_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_task_org_id',target_lines_rec.task_org_id) ;
        END IF ;
        IF target_lines_rec.service_type is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_service_type_code',target_lines_rec.service_type) ;
        END IF ;
        IF target_lines_rec.class_category is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_class_category',target_lines_rec.class_category) ;
        END IF ;
        IF target_lines_rec.class_code is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_class_code',target_lines_rec.class_code) ;
        END IF ;
        IF target_lines_rec.project_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_project_id',target_lines_rec.project_id) ;
        END IF ;
        IF target_lines_rec.task_id is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_task_id',target_lines_rec.task_id) ;
        END IF ;
        IF p_expnd_item_date is NOT NULL THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':p_expnd_item_date',p_expnd_item_date) ;
        END IF ;
        IF ( nvl(target_lines_rec.billable_only_flag,'N') = 'Y' )  THEN
           DBMS_SQL.BIND_VARIABLE(v_target_csr_id,':lp_billable_only_flag',target_lines_rec.billable_only_flag) ;
        END IF ;
        DBMS_SQL.DEFINE_COLUMN(v_target_csr_id,1,v_tgt_project_id ) ;
        DBMS_SQL.DEFINE_COLUMN(v_target_csr_id,2,v_tgt_task_id ) ;
        DBMS_SQL.DEFINE_COLUMN(v_target_csr_id,3,v_tgt_top_task_id ) ;
        v_dummy := DBMS_SQL.execute(v_target_csr_id) ;
        LOOP
           IF DBMS_SQL.FETCH_ROWS(v_target_csr_id) = 0 THEN
                 EXIT ;
           END IF ;
           dbms_sql.column_value(v_target_csr_id,1,v_tgt_project_id) ;
           dbms_sql.column_value(v_target_csr_id,2,v_tgt_task_id ) ;
           dbms_sql.column_value(v_target_csr_id,3,v_tgt_top_task_id ) ;
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('populate_run_targets: ' || 'LOG','Exploded proj/tasks: '|| to_char(v_tgt_project_id) ||
                                  to_char(v_tgt_task_id) ||
                                  to_char(v_tgt_top_task_id));
           END IF;
        /* since always lowest chargeable task, check whether to exclude */
        IF (exclude_curr_proj_task(p_run_id, 'TRG',v_tgt_project_id
                                  , v_tgt_task_id ) = 0) THEN
          /* include current project/task, so insert */
          insert_alloc_run_targets( p_rule_id
                                  , p_run_id
                                  , target_lines_rec.line_num
                                  , v_tgt_project_id
                                  , v_tgt_task_id
                                  , target_lines_rec.line_percent
                                  , target_lines_rec.exclude_flag
                                  , G_creation_date
                                  , G_created_by
                                  , G_last_update_date
                                  , G_last_updated_by
                                  , G_last_update_login
                                  , x_basis_method
                                  , p_dup_targets_flag );
        END IF; /* exclude_curr_proj_task */
      END LOOP;
    END IF;
  END LOOP;
  DBMS_SQL.CLOSE_CURSOR(v_target_csr_id );  --added for bug 3799389
  /* -- validate budget_entry_level_code for trg_proj --------------- */
  IF( p_bas_budget_entry_method_code IS NOT NULL) THEN
    pa_debug.G_err_stage:= 'VALIDATING BASIS BUDGET ENTRY METHOD TO TRG PROJECTS';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('populate_run_targets: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
    OPEN c_rule_entry_level_code;
    FETCH c_rule_entry_level_code INTO v_rule_level_code;
    CLOSE c_rule_entry_level_code;
    FOR run_trg_proj_rec IN c_alloc_run_trg_projects LOOP
      OPEN c_proj_entry_level_code(run_trg_proj_rec.project_id);
      FETCH c_proj_entry_level_code INTO v_proj_level_code;
      IF (v_rule_level_code <> v_proj_level_code ) THEN
        G_fatal_err_found := TRUE;
        alloc_errors(p_rule_id, p_run_id, 'B', 'E',
                      'PA_AL_UNASSIGNED_BASIS_BEM', FALSE, 'Y',
                       run_trg_proj_rec.project_id );
      END IF;
      CLOSE c_proj_entry_level_code;
    END LOOP;
  END IF; /* p_bas_budget_entry_method_code  */
  /* -- validate_trg_proj_for_RL ----------------------- */
  IF( p_resource_list_id IS NOT NULL ) THEN
    pa_debug.G_err_stage:= 'VALIDATING RSRCE ASSIGNMENTS TO TRG PROJECTS';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('populate_run_targets: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
    FOR run_trg_proj_rec IN c_alloc_run_trg_projects LOOP
      OPEN C_proj_in_RL( run_trg_proj_rec.project_id
                       , p_resource_list_id
					   /* FP.M : ALlocation Impact */
					   , p_basis_resource_struct_type
					   , p_rbs_version_id
					   );
      FETCH C_proj_in_RL INTO v_dummy;
        IF C_proj_in_RL%NOTFOUND THEN
          G_fatal_err_found := TRUE;
          alloc_errors( p_rule_id, p_run_id,
                        'T', 'E',
                        'PA_AL_UNASSIGNED_TRG_RL', FALSE, 'Y',
                         run_trg_proj_rec.project_id,
                         run_trg_proj_rec.task_id );
        END IF;
      CLOSE C_proj_in_RL;
    END LOOP;
  END IF;
  IF ( x_basis_method IN ( 'FS', 'FP') AND check_line_percent <> 100 ) THEN
    pa_debug.G_err_stage:= 'VALIDATING TRG LINE PERCENT';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('populate_run_targets: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
    G_fatal_err_found := TRUE;
    alloc_errors( p_rule_id, p_run_id,
                  'T', 'E',
                  'PA_AL_LINE_PRCNT_NOT_100');
  END IF;
  /*  restore the old stack */
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    pa_debug.G_err_code := SQLCODE;
    RAISE;
END populate_run_targets;
-- ------------------------------------------------------------
-- insert_alloc_run_GL_det
-- ------------------------------------------------------------
PROCEDURE insert_alloc_run_GL_det ( p_run_id            IN NUMBER
                                  , p_rule_id           IN NUMBER
                                  , p_line_num          IN NUMBER
                                  , p_source_ccid       IN NUMBER
                                  , p_subtract_flag     IN VARCHAR2
                                  , p_creation_date     IN DATE
                                  , p_created_by        IN NUMBER
                                  , p_last_update_date  IN DATE
                                  , p_last_updated_by   IN NUMBER
                                  , p_last_update_login IN NUMBER
                                  , p_source_percent    IN NUMBER
                                  , p_amount            IN NUMBER
                                  , p_eligible_amount   IN NUMBER ) IS
BEGIN
  pa_debug.set_err_stack('insert_alloc_run_GL_det');
  INSERT INTO pa_alloc_run_gl_det(
    RUN_ID
  , RULE_ID
  , LINE_NUM
  , SOURCE_CCID
  , SUBTRACT_FLAG
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  , SOURCE_PERCENT
  , AMOUNT
  , ELIGIBLE_AMOUNT )
  VALUES (
    p_run_id
  , p_rule_id
  , p_line_num
  , p_source_ccid
  , p_subtract_flag
  , p_creation_date
  , p_created_by
  , p_last_update_date
  , p_last_updated_by
  , p_last_update_login
  , p_source_percent
  , p_amount
  , p_eligible_amount);
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    pa_debug.G_err_code := SQLCODE;
    RAISE;
END insert_alloc_run_GL_det;
-- ------------------------------------------------------------
-- calculate_src_GL_amounts
-- ------------------------------------------------------------
PROCEDURE calculate_src_GL_amounts( p_rule_id      IN  NUMBER
                                 , p_run_id        IN  NUMBER
                                 , p_run_period    IN  VARCHAR2
                                 , p_amount_type   IN  VARCHAR2
                                 , x_gl_src_amount OUT NOCOPY NUMBER ) IS
CURSOR gl_sources IS
  SELECT source_ccid
       , nvl(source_percent,100) source_percent
       , subtract_flag
       , line_num
  FROM pa_alloc_gl_lines
  WHERE rule_id = p_rule_id;
CURSOR gl_account_dets IS
  SELECT a.set_of_books_id
       , b.accounted_period_type
       , b.currency_code
  FROM pa_implementations a
     , gl_sets_of_books b
  WHERE a.set_of_books_id = b.set_of_books_id;
CURSOR gl_eligible_amount IS
  SELECT nvl(sum( nvl(eligible_amount,0)*DECODE(subtract_flag,'Y',-1,1) ),0)
  FROM pa_alloc_run_GL_det
  WHERE run_id = p_run_id;
CURSOR get_gl_amount( p_sob_id        IN NUMBER
                                                  , p_source_ccid   IN NUMBER
                                                  , p_currency_code IN VARCHAR2
                                                  , p_run_period    IN VARCHAR2
                                                  , p_amount_type   In VARCHAR2 ) IS
  SELECT NVL(period_net_dr,0) - NVL(period_net_cr, 0) +
           decode(p_amount_type, 'FYTD',NVL(begin_balance_dr, 0), 'QTD'
                  , NVL(quarter_to_date_dr, 0), 0) -
           decode(p_amount_type, 'FYTD', NVL(begin_balance_cr, 0), 'QTD'
                  , NVL(quarter_to_date_cr, 0), 0)
  FROM gl_balances
  WHERE ledger_id = p_sob_id
  AND code_combination_id = p_source_ccid   /** .source_ccid */
  AND currency_code = p_currency_code
  AND period_name = p_run_period
  AND actual_flag = 'A'
  AND translated_flag IS NULL;
CURSOR get_pool_percent  IS
  SELECT nvl(pool_percent,100) pool_percent
  FROM   pa_alloc_runs
  WHERE  run_id = p_run_id;
v_sob_id NUMBER;
v_currency_code VARCHAR2(10);
v_period_type VARCHAR2(10);
v_amount NUMBER;
v_pool_percent NUMBER;
BEGIN
  pa_debug.set_err_stack('calculate_src_GL_amounts');
  pa_debug.G_err_stage:= 'Getting gl_account_details';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('calculate_src_GL_amounts: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  OPEN gl_account_dets;
  FETCH gl_account_dets
  INTO v_sob_id, v_period_type, v_currency_code ;
  CLOSE gl_account_dets;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('calculate_src_GL_amounts: ' || 'LOG', 'v_SOB_ID is: '|| to_char(v_sob_id) );
      pa_debug.write_file('calculate_src_GL_amounts: ' || 'LOG', 'v_currency_code is: '|| v_currency_code );
      pa_debug.write_file('calculate_src_GL_amounts: ' || 'LOG', 'v_period_type is: '|| v_period_type );
   END IF;
  OPEN get_pool_percent;
  FETCH get_pool_percent
  INTO v_pool_percent;
  CLOSE get_pool_percent;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('calculate_src_GL_amounts: ' || 'LOG', 'v_pool_percent is: '|| to_char(v_pool_percent));
  END IF;
  FOR gl_source_rec IN gl_sources LOOP
    OPEN get_gl_amount( v_sob_id
                      , gl_source_rec.source_ccid
                      , v_currency_code
                      , p_run_period
                      , p_amount_type );
         FETCH get_gl_amount INTO v_amount;
         IF (get_gl_amount%NOTFOUND) THEN
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_debug.write_file('calculate_src_GL_amounts: ' || 'LOG', 'no amount found for the source');
                END IF;
                v_amount := 0;               /* for bug 2154559 */
                alloc_errors( p_rule_id, p_run_id, 'S', 'W',
                                                  'PA_AL_NO_GL_BALANCES');
         END IF;
         CLOSE get_gl_amount;
--  Commented the following line as a part of fixing rounding issues.
--  The rounding is done for eligible amount
--    v_amount:= pa_currency.round_currency_amt( NVl(v_amount,0) );
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('calculate_src_GL_amounts: ' || 'LOG', 'v_amount is: '|| to_char(v_amount) );
   END IF;
    /* then insert into gl_source_det */
    insert_alloc_run_GL_det( p_run_id
                           , p_rule_id
                           , gl_source_rec.line_num
                           , gl_source_rec.source_ccid
                           , gl_source_rec.subtract_flag
                           , G_creation_date
                           , G_created_by
                           , G_last_update_date
                           , G_last_updated_by
                           , G_last_update_login
                           , gl_source_rec.source_percent
                           , v_amount
                           , pa_currency.round_currency_amt(v_amount*
                                   (gl_source_rec.source_percent/100)*
                                   ( v_pool_percent/100))
                            ) ;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('calculate_src_GL_amounts: ' || 'LOG', 'After insert into alloc_run_Gl' );
   END IF;
  END LOOP;
  /* calculate total GL pool amount */
  OPEN gl_eligible_amount ;
  FETCH gl_eligible_amount INTO v_amount;
  CLOSE gl_eligible_amount ;
  x_gl_src_amount:= NVL(v_amount, 0);
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
  pa_debug.G_err_code:= SQLCODE;
  RAISE;
END calculate_src_GL_amounts;
-- ------------------------------------------------------------
-- get_trg_line_proj_task_count
-- ------------------------------------------------------------
FUNCTION get_trg_line_proj_task_count( p_run_id IN NUMBER
                                     , p_line_num IN NUMBER ) RETURN NUMBER IS
x_count NUMBER:=0;
CURSOR C_get_count IS
  SELECT count(task_id)
  FROM pa_alloc_run_targets
  WHERE run_id = p_run_id
  AND line_num = p_line_num;
BEGIN
  pa_debug.set_err_stack ('Get Proj_task Count For Each Target Line');
  OPEN C_get_count;
  FETCH C_get_count INTO x_count;
  CLOSE C_get_count;
  pa_debug.reset_err_stack ;
  return x_count;
EXCEPTION
  WHEN OTHERS THEN
    return (SQLCODE);
--    return 0;
END get_trg_line_proj_task_count;
-- ------------------------------------------------------------
-- insert_missing_costs
-- ------------------------------------------------------------
PROCEDURE insert_missing_costs(     p_run_id              IN NUMBER
                                  , p_type_code           IN VARCHAR2
                                  , p_project_id          IN NUMBER
                                  , p_task_id             IN NUMBER
                                  , p_amount  IN NUMBER )  IS
BEGIN
  pa_debug.set_err_stack('Insert missing project costs');
  INSERT INTO pa_alloc_missing_costs (
      RUN_ID
    , TYPE_CODE
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    , PROJECT_ID
    , TASK_ID
    , AMOUNT)
  VALUES (
      p_run_id
    , p_type_code
    , G_creation_date
    , G_created_by
    , G_last_update_date
    , G_last_updated_by
    , G_last_update_login
    , p_project_id
    , p_task_id
    , p_amount);
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    pa_debug.G_err_code := SQLCODE;
    RAISE;
END insert_missing_costs;
-- ------------------------------------------------------------
-- get_sunk_cost
-- ------------------------------------------------------------
PROCEDURE get_sunk_cost( p_rule_id IN NUMBER
                      , p_run_id  IN NUMBER
                      , p_fiscal_year IN NUMBER
                      , p_quarter_num IN NUMBER
                      , p_period_num  IN NUMBER
                      , p_amount_type IN VARCHAR2
                      , x_src_sunk_cost OUT NOCOPY NUMBER
                      , x_tgt_sunk_cost OUT NOCOPY NUMBER
                      , p_src_proj_id  IN NUMBER    ) IS
-- the parameter p_src_proj_id is added to get the sunk cost for given project.
-- This will be used only when called from the create_offset_txns procedure.
-- So if this parameter is not null then, the target sunk cost calculations and
-- the insert operations into the missing cost table are not required
/* The cursor definition was changed in bug 3157765
CURSOR C_src_sunk_cost( p_fscl_year IN NUMBER
        , p_qrtr_num  IN NUMBER
        , p_prd_num   IN NUMBER ) IS
  SELECT a.run_id run_id
  , a.project_id  project_id
  , a.task_id     task_id
  , nvl(a.eligible_amount,0) eligible_amount
  FROM pa_alloc_run_source_det a,
       pa_alloc_runs ar
  WHERE a.run_id = ar.run_id
  AND  a.rule_id = p_rule_id
  AND  ar.fiscal_year = NVL(p_fscl_year, ar.fiscal_year)
  AND  ar.quarter = NVL(p_qrtr_num, ar.quarter)
  AND ar.period_num = NVL(p_prd_num, ar.period_num )
  AND  a.run_id < p_run_id
  AND NOT EXISTS ( SELECT 1
                  FROM pa_alloc_run_source_det b
                  WHERE a.project_id = b.project_id
                  AND a.task_id = b.task_id
                  AND b.rule_id = p_rule_id
                  AND b.run_id = p_run_id )
  AND a.run_id =( SELECT max(c.run_id)
                  FROM pa_alloc_run_source_det c,
                       pa_alloc_runs c_ar    -- added this table to exclude reversed runs.
                  WHERE c.project_id = a.project_id
                  AND c.task_id = a.task_id
                  AND c.run_id = c_ar.run_id
                  AND c_ar.rule_id = p_rule_id
                  AND c_ar.run_status = 'RS'
                  AND c.run_id < p_run_id )
 AND  a.project_id > 0   -- This is added to ignore the missing cost from fixed amount.
 AND  a.project_id = nvl(p_src_proj_id, a.project_id) ;
*******/
CURSOR C_Src_Sunk_Cost
    (  p_Fscl_Year    IN NUMBER
    ,  p_Qrtr_Num      IN NUMBER
    ,  p_Prd_Num      IN NUMBER
    )  IS
   SELECT  A.Run_Id                        Run_Id,
           A.Project_Id                    Project_Id,
           A.Task_Id                       Task_Id,
           NVL ( A.Eligible_Amount, 0 )    Eligible_Amount
   FROM    PA_ALLOC_RUN_SOURCE_DET    A ,
    (  --
       -- The purpose of this in-line view is to return
       --  the PA_ALLOC_RUNS (single) record for the largest Run_Id
       --  less than the input p_Run_Id
       --
       SELECT  MAX ( AR.Run_Id ) AS Run_Id
       FROM    PA_ALLOC_RUNS              AR
       WHERE  AR.Fiscal_Year  = NVL ( p_Fscl_Year , AR.Fiscal_Year )
       AND    AR.Quarter      = NVL ( p_Qrtr_Num  , AR.Quarter  )
       AND    AR.Period_Num  = NVL ( p_Prd_Num  , AR.Period_Num  )
       AND    AR.Run_Id      < p_Run_Id
       AND    AR.Rule_Id      = p_Rule_Id
       AND    AR.Run_Status  = 'RS'
     )  AR
    WHERE  A.Run_Id        = AR.Run_Id
    AND    A.Rule_Id      = p_Rule_Id
    AND NOT EXISTS
           (  SELECT  1
              FROM    PA_ALLOC_RUN_SOURCE_DET    B
              WHERE  A.Project_Id    = B.Project_Id
              AND    A.Task_Id      = B.Task_Id
              AND    B.Rule_Id      = p_Rule_Id
              AND    B.Run_Id        = p_Run_Id
           )
    AND  A.Project_Id > 0
    AND  A.Project_Id = NVL ( p_Src_Proj_Id, A.Project_Id ) ;
/**** Changes for bug-3157765 ends here *****/
CURSOR C_trg_sunk_cost( p_fscl_year IN NUMBER
        , p_qrtr_num  IN NUMBER
        , p_prd_num   IN NUMBER ) IS
  SELECT a.run_id  run_id
  , a.project_id  project_id
  , a.task_id     task_id
  , nvl(a.Total_allocation,0) Total_allocation
  FROM pa_alloc_txn_details a,
       pa_alloc_runs ar
  WHERE a.run_id = ar.run_id
  AND  a.rule_id = p_rule_id
  AND  ar.fiscal_year = NVL(p_fscl_year, ar.fiscal_year)
  AND  ar.quarter = NVL(p_qrtr_num, ar.quarter)
  AND ar.period_num = NVL(p_prd_num, ar.period_num )
  AND  a.run_id < p_run_id
  AND  a.transaction_type  = 'T'
  AND NOT EXISTS ( SELECT 1
                  FROM pa_alloc_run_targets b
                  WHERE b.project_id = a.project_id
                    AND b.task_id = a.task_id
                    AND b.exclude_flag    = 'N'
                    AND b.run_id = p_run_id )
  AND a.run_id =( SELECT max(c.run_id)
                  FROM pa_alloc_txn_details c,
                       pa_alloc_runs c_ar   -- added this table to exclude reversed runs.
                  WHERE c.project_id = a.project_id
                  AND c.task_id = a.task_id
                  AND c.transaction_type    = 'T'
                  AND c.run_id = c_ar.run_id
                  AND c_ar.rule_id = p_rule_id
                  AND c_ar.run_status = 'RS'
                  AND c.run_id < p_run_id );
v_tot_sunk_cost NUMBER;
v_src_sunk_cost NUMBER;
v_trg_sunk_cost NUMBER;
v_prev_amount NUMBER:=0;
v_quarter_num NUMBER;
v_fiscal_year NUMBER;
v_period_num NUMBER;
BEGIN
  pa_debug.set_err_stack('Get_Sunk_Cost');
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('get_sunk_cost: ' || 'LOG', 'p_amount_type '||p_amount_type);
  END IF;
  IF( p_amount_type = 'ITD') THEN
    v_fiscal_year:= NULL;
    v_quarter_num:= NULL;
    v_period_num := NULL;
  ELSIF (p_amount_type = 'FYTD') THEN
    v_fiscal_year:= p_fiscal_year;
    v_quarter_num:= NULL;
    v_period_num := NULL;
  ELSIF (p_amount_type = 'QTD') THEN
    v_fiscal_year:= p_fiscal_year;
    v_quarter_num:= p_quarter_num;
    v_period_num := NULL;
  ELSE
    v_fiscal_year:= p_fiscal_year;
    v_quarter_num:= p_quarter_num;
    v_period_num := p_period_num;
  END IF;
v_src_sunk_cost :=0;
v_trg_sunk_cost :=0;
  /* calculate total src_sunk_cost */
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('get_sunk_cost: ' || 'LOG',' calculate total src_sunk_cost' );
  END IF;
  FOR src_sunk_cost_rec IN C_src_sunk_cost( v_fiscal_year
                                          , v_quarter_num
                                          , v_period_num ) LOOP
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('get_sunk_cost: ' || 'LOG','src_sunk_cost :'|| to_char(src_sunk_cost_rec.eligible_amount) );
    END IF;
    if p_src_proj_id is  NULL then
     insert_missing_costs( p_run_id
                          ,'S'
                          ,src_sunk_cost_rec.project_id
                          ,src_sunk_cost_rec.task_id
                          ,src_sunk_cost_rec.eligible_amount);
    end if ;
    v_src_sunk_cost := v_src_sunk_cost + src_sunk_cost_rec.eligible_amount;
  END LOOP;
  x_src_sunk_cost := nvl(v_src_sunk_cost, 0) ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('get_sunk_cost: ' || 'LOG','v_src_sunk_cost =' ||to_char(v_src_sunk_cost) );
  END IF;
 /* calculate total trgt_sunk_cost */
if p_src_proj_id is  NULL then
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('get_sunk_cost: ' || 'LOG',' calculate total tgt_sunk_cost ' || to_char(v_fiscal_year)
          || ' ' || to_char(v_quarter_num) || ' '
          || to_char(v_period_num) );
  END IF;
  FOR trg_sunk_cost_rec IN C_trg_sunk_cost( v_fiscal_year
                                          , v_quarter_num
                                          , v_period_num ) LOOP
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('get_sunk_cost: ' || 'LOG','tgt_sunk_cost = '|| to_char(trg_sunk_cost_rec.Total_allocation) );
  END IF;
     insert_missing_costs( p_run_id
                          ,'T'
                          ,trg_sunk_cost_rec.project_id
                          ,trg_sunk_cost_rec.task_id
                          ,trg_sunk_cost_rec.Total_allocation);
    v_trg_sunk_cost := v_trg_sunk_cost + trg_sunk_cost_rec.Total_allocation;
  END LOOP;
  x_tgt_sunk_cost := nvl(v_trg_sunk_cost,0) ;
 IF P_DEBUG_MODE = 'Y' THEN
    pa_debug.write_file('get_sunk_cost: ' || 'LOG','v_tgt_sunk_cost =' ||to_char(x_tgt_sunk_cost) );
 END IF;
End if ;
  v_tot_sunk_cost := NVL(v_src_sunk_cost,0) - NVL(v_trg_sunk_cost,0);
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
   null;
 --    return (SQLCODE);
--       return 0;
END get_sunk_cost;
-- ------------------------------------------------------------
-- get_previous_alloc_amnt
-- ------------------------------------------------------------
FUNCTION get_previous_alloc_amnt ( p_rule_id     IN NUMBER
                                 , p_run_id      IN NUMBER
                                 , p_project_id  IN NUMBER
                                 , p_task_id     IN NUMBER
                                 , p_quarter_num IN NUMBER
                                 , p_fiscal_year IN NUMBER
                                 , p_period_num  IN NUMBER
                                 , p_type        IN VARCHAR2
                                 , p_amount_type IN VARCHAR2 ) RETURN NUMBER IS
CURSOR C_prev_amount( p_qrtr_num  IN NUMBER
        , p_fscl_year IN NUMBER
        , p_prd_num   IN NUMBER ) IS
  SELECT nvl(sum(nvl(a.current_allocation,0)),0)
  FROM pa_alloc_txn_details a,
       pa_alloc_runs b
  WHERE b.rule_id = p_rule_id
    AND b.run_id < p_run_id
    AND b.quarter = nvl(p_qrtr_num, b.quarter)
    AND b.fiscal_year = nvl(p_fscl_year, b.fiscal_year)
    AND b.period_num = nvl(p_prd_num, b.period_num)
    AND b.run_id = a.run_id
    AND a.transaction_type = p_type
    AND a.project_id = p_project_id
    AND a.task_id = p_task_id
    AND b.reversal_date is NULL
    AND b.run_status <> 'DL'; /* for bug 2176096 */
v_prev_amount NUMBER:=0;
v_quarter_num NUMBER;
v_fiscal_year NUMBER;
v_period_num NUMBER;
BEGIN
  v_prev_amount :=0;
  pa_debug.set_err_stack('Get_Previous_Alloc_Amount');
  IF( p_amount_type = 'ITD') THEN
    v_fiscal_year:= NULL;
    v_quarter_num:= NULL;
    v_period_num := NULL;
  ELSIF (p_amount_type = 'FYTD') THEN
    v_fiscal_year:= p_fiscal_year;
    v_quarter_num:= NULL;
    v_period_num := NULL;
  ELSIF (p_amount_type = 'QTD') THEN
    v_fiscal_year:= p_fiscal_year;
    v_quarter_num:= p_quarter_num;
    v_period_num := NULL;
  ELSE
    v_fiscal_year:= p_fiscal_year;
    v_quarter_num:= p_quarter_num;
    v_period_num := p_period_num;
  END IF;
  /* returns the previous allocated amount for the
   passed rule_id, project_id and task_id */
  OPEN C_prev_amount ( v_quarter_num, v_fiscal_year, v_period_num );
  FETCH C_prev_amount INTO v_prev_amount;
  CLOSE C_prev_amount;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('get_previous_alloc_amnt: ' || 'LOG','rule_id:run_id:year:quarter:period:project:task:Amt='||
         to_char(p_rule_id)||': '|| to_char(p_run_id)||': '||
         to_char(v_fiscal_year)||': '|| to_char(v_quarter_num)||': '||
         to_char(v_period_num)||': '|| to_char(p_project_id)||': '||
         to_char(p_task_id)||':'||to_char(v_prev_amount));
  END IF;
  pa_debug.reset_err_stack;
  return nvl(v_prev_amount,0);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
         return 0;
  WHEN OTHERS THEN
         return (SQLCODE);
END get_previous_alloc_amnt;
-- ------------------------------------------------------------
-- insert_alloc_txn_details
-- ------------------------------------------------------------
PROCEDURE insert_alloc_txn_details( x_alloc_txn_id        IN OUT NOCOPY NUMBER
                                  , p_run_id              IN NUMBER
                                  , p_rule_id             IN NUMBER
                                  , p_transaction_type    IN VARCHAR2
                                  , p_fiscal_year         IN NUMBER
                                  , p_quarter_num         IN NUMBER
                                  , p_period_num          IN NUMBER
                                  , p_run_period          IN VARCHAR2
                                  , p_line_num            IN NUMBER
                                  , p_project_id          IN NUMBER
                                  , p_task_id             IN NUMBER
                                  , p_expenditure_type    IN VARCHAR2
                                  , p_total_allocation    IN NUMBER
                                  , p_previous_allocation IN NUMBER
                                  , p_current_allocation  IN NUMBER
                                 /* PA.L:Added for Capitalized Interest */
                                  , p_EXPENDITURE_ID      IN NUMBER   DEFAULT NULL
                                  , p_EXPENDITURE_ITEM_ID IN NUMBER   DEFAULT NULL
                                  , p_CINT_SOURCE_TASK_ID IN NUMBER   DEFAULT NULL
                                  , p_CINT_EXP_ORG_ID     IN NUMBER   DEFAULT NULL
                                  , p_CINT_RATE_MULTIPLIER IN NUMBER   DEFAULT NULL
                                  , p_CINT_PRIOR_BASIS_AMT IN NUMBER   DEFAULT NULL
                                  , p_CINT_CURRENT_BASIS_AMT IN NUMBER   DEFAULT NULL
                                  , p_REJECTION_CODE      IN VARCHAR2 DEFAULT NULL
                                  , p_STATUS_CODE         IN VARCHAR2 DEFAULT NULL
                                  , p_ATTRIBUTE_CATEGORY  IN VARCHAR2 DEFAULT NULL
                                  , p_ATTRIBUTE1          IN VARCHAR2 DEFAULT NULL
                                  , p_ATTRIBUTE2          IN VARCHAR2 DEFAULT NULL
                                  , p_ATTRIBUTE3          IN VARCHAR2 DEFAULT NULL
                                  , p_ATTRIBUTE4          IN VARCHAR2 DEFAULT NULL
                                  , p_ATTRIBUTE5          IN VARCHAR2 DEFAULT NULL
                                  , p_ATTRIBUTE6          IN VARCHAR2 DEFAULT NULL
                                  , p_ATTRIBUTE7          IN VARCHAR2 DEFAULT NULL
                                  , p_ATTRIBUTE8          IN VARCHAR2 DEFAULT NULL
                                  , p_ATTRIBUTE9          IN VARCHAR2 DEFAULT NULL
                                  , p_ATTRIBUTE10         IN VARCHAR2 DEFAULT NULL
                                /* PA.L : end */
				 ) IS
v_attribute_category VARCHAR2(30);
v_attribute1  VARCHAR2(150);
v_attribute2  VARCHAR2(150);
v_attribute3  VARCHAR2(150);
v_attribute4  VARCHAR2(150);
v_attribute5  VARCHAR2(150);
v_attribute6  VARCHAR2(150);
v_attribute7  VARCHAR2(150);
v_attribute8  VARCHAR2(150);
v_attribute9  VARCHAR2(150);
v_attribute10  VARCHAR2(150);
v_status NUMBER ;
v_err_message VARCHAR2(250);
BEGIN
  pa_debug.set_err_stack('Insert Alloc Txn Details');
 /* Added if condition to avoid calling client extns for capint if p_rule_id =-1 */
 IF nvl(p_rule_id,0) <> -1 Then
   --For Capitalized Interest the DFF will be derived outside the
   --table handler by calling client extn
  If p_transaction_type='T' then
      PA_CLIENT_EXTN_ALLOC.txn_dff_extn( p_rule_id
                       ,p_run_id
                       ,p_transaction_type
                       ,p_project_id
                       ,P_task_id
                       ,G_tgt_expnd_org
                       ,G_tgt_expnd_type_class
                       ,G_tgt_expnd_type
                       ,v_attribute_category
                       ,v_attribute1
                       ,v_attribute2
                       ,v_attribute3
                       ,v_attribute4
                       ,v_attribute5
                       ,v_attribute6
                       ,v_attribute7
                       ,v_attribute8
                       ,v_attribute9
                       ,v_attribute10
                       , v_status
                       , v_err_message
                     ) ;
     IF nvl(v_status,0) <> 0 then
        v_err_message:=nvl(v_err_message,'PA_AL_CE_FAILED');
        IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('insert_alloc_txn_details: ' || 'LOG',v_err_message);
        END IF;
        alloc_errors(p_rule_id, p_run_id, 'R', 'E',v_err_message, TRUE) ;
     END IF ;
   Elsif  p_transaction_type='O' then
     PA_CLIENT_EXTN_ALLOC.txn_dff_extn( p_rule_id
                       ,p_run_id
                       ,p_transaction_type
                       ,p_project_id
                       ,P_task_id
                       ,G_offset_expnd_org
                       ,G_offset_expnd_type_class
                       ,G_offset_expnd_type
                       ,v_attribute_category
                       ,v_attribute1
                       ,v_attribute2
                       ,v_attribute3
                       ,v_attribute4
                       ,v_attribute5
                       ,v_attribute6
                       ,v_attribute7
                       ,v_attribute8
                       ,v_attribute9
                       ,v_attribute10
                       , v_status
                       , v_err_message
                     ) ;
       IF nvl(v_status,0) <> 0 then
           v_err_message:=nvl(v_err_message,'PA_AL_CE_FAILED');
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('insert_alloc_txn_details: ' || 'LOG',v_err_message);
           END IF;
           alloc_errors(p_rule_id, p_run_id, 'R', 'E',v_err_message, TRUE) ;
       END IF ;
    End if;
  END IF ;  -- end of p_rule_id <> -1
  If x_alloc_txn_id is Null Then
      Select pa_alloc_txn_details_s.nextval
      Into x_alloc_txn_id
      From Dual;
  End If;
  INSERT INTO pa_alloc_txn_details (
      RUN_ID
    , RULE_ID
    , TRANSACTION_TYPE
    , FISCAL_YEAR
    , QUARTER_NUM
    , PERIOD_NUM
    , RUN_PERIOD
    , LINE_NUM
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    , PROJECT_ID
    , TASK_ID
    , EXPENDITURE_TYPE
    , TOTAL_ALLOCATION
    , PREVIOUS_ALLOCATION
    , CURRENT_ALLOCATION
    , ALLOC_TXN_ID
    , ATTRIBUTE_CATEGORY
    ,ATTRIBUTE1
    ,ATTRIBUTE2
    ,ATTRIBUTE3
    ,ATTRIBUTE4
    ,ATTRIBUTE5
    ,ATTRIBUTE6
    ,ATTRIBUTE7
    ,ATTRIBUTE8
    ,ATTRIBUTE9
    ,ATTRIBUTE10
    ,EXPENDITURE_ID
    ,EXPENDITURE_ITEM_ID
    ,CINT_SOURCE_TASK_ID
    ,CINT_EXP_ORG_ID
    ,CINT_RATE_MULTIPLIER
    ,CINT_PRIOR_BASIS_AMT
    ,CINT_CURRENT_BASIS_AMT
    ,REJECTION_CODE
    ,STATUS_CODE
)
  VALUES (
      p_run_id
    , p_rule_id
    , p_transaction_type
    , p_fiscal_year
    , p_quarter_num
    , p_period_num
    , p_run_period
    , p_line_num
    , G_creation_date
    , G_created_by
    , G_last_update_date
    , G_last_updated_by
    , G_last_update_login
    , p_project_id
    , p_task_id
    , p_expenditure_type
    , p_total_allocation
    , p_previous_allocation
    , p_current_allocation
    , x_alloc_txn_id --, pa_alloc_txn_details_s.nextval
    ,decode(p_rule_id,-1,p_attribute_category,v_attribute_category)
    ,decode(p_rule_id,-1,p_attribute1,v_attribute1)
    ,decode(p_rule_id,-1,p_attribute2,v_attribute2)
    ,decode(p_rule_id,-1,p_attribute3,v_attribute3)
    ,decode(p_rule_id,-1,p_attribute4,v_attribute4)
    ,decode(p_rule_id,-1,p_attribute5,v_attribute5)
    ,decode(p_rule_id,-1,p_attribute6,v_attribute6)
    ,decode(p_rule_id,-1,p_attribute7,v_attribute7)
    ,decode(p_rule_id,-1,p_attribute8,v_attribute8)
    ,decode(p_rule_id,-1,p_attribute9,v_attribute9)
    ,decode(p_rule_id,-1,p_attribute10,v_attribute10)
    ,p_EXPENDITURE_ID
    ,p_EXPENDITURE_ITEM_ID
    ,p_CINT_SOURCE_TASK_ID
    ,p_CINT_EXP_ORG_ID
    ,p_CINT_RATE_MULTIPLIER
    ,p_CINT_PRIOR_BASIS_AMT
    ,p_CINT_CURRENT_BASIS_AMT
    ,p_REJECTION_CODE
    ,p_STATUS_CODE
 );
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    pa_debug.G_err_code := SQLCODE;
    RAISE;
END insert_alloc_txn_details;
-- ------------------------------------------------------------
-- create_target_txns
-- ------------------------------------------------------------
PROCEDURE create_target_txns( p_rule_id           IN NUMBER
                            , p_run_id            IN NUMBER
                            , p_type              IN VARCHAR2
                            , p_fiscal_year       IN NUMBER
                            , p_quarter_num       IN NUMBER
                            , p_period_num        IN NUMBER
                            , p_run_period        IN VARCHAR2
                            , p_expenditure_type  IN VARCHAR2
                            , p_allocation_method IN VARCHAR2
                            , p_basis_method      IN VARCHAR2
                            , p_amount_type       IN VARCHAR2
                            , p_pool_amount       IN NUMBER
                            , x_curr_alloc_amount OUT NOCOPY NUMBER  ) IS
CURSOR C_run_basis_det( p_run_id       IN NUMBER
                      , p_basis_method IN VARCHAR2
                      , p_line_num     IN NUMBER
                      , p_project_id   IN NUMBER
                      , p_task_id      IN NUMBER ) IS
  SELECT nvl(sum( nvl(basis_percent, 0)*nvl(line_percent,100)/10000),0) basis
  FROM pa_alloc_run_basis_det
  WHERE run_id = p_run_id
  AND line_num = p_line_num
  AND project_id = p_project_id
  AND task_id = p_task_id ;
CURSOR C_run_targets IS
  SELECT line_num
  , project_id
  , task_id
  , line_percent
  , exclude_flag
  FROM pa_alloc_run_targets
  WHERE run_id = p_run_id
  AND exclude_flag = 'N';
/* added p_run_id parameter for bug 1900331 */
CURSOR C_all_proj_task_count (p_run_id IN NUMBER) IS
  SELECT count(task_id)
  FROM pa_alloc_run_targets
  WHERE run_id = p_run_id
  AND exclude_flag = 'N';
CURSOR C_count_of_trg_lines IS
  SELECT COUNT(DISTINCT line_num)
  FROM pa_alloc_run_targets
  WHERE run_id = p_run_id
  AND exclude_flag = 'N';
v_quarter_num NUMBER;
v_fiscal_year NUMBER;
v_period_num NUMBER;
cursor c_sum_of_allocated_amts is
  select NVL(sum ( nvl(par1.allocated_amount,0)),0)
    from pa_alloc_runs par1
   where par1.run_id < p_run_id
     and par1.rule_id = p_rule_id
     and par1.fiscal_year = nvl(v_fiscal_year, par1.fiscal_year)
     and par1.quarter     = nvl(v_quarter_num, par1.quarter)
     and par1.period_num = nvl(v_period_num, par1.period_num)
     and par1.reversal_date is NULL
     and par1.run_status <> 'DL'; /* for bug 2176096 */
v_sunk_cost NUMBER :=0;
v_src_sunk_cost NUMBER :=0;
v_tgt_sunk_cost NUMBER :=0;
v_tot_pool_amount NUMBER :=0;
v_curr_alloc_amount NUMBER :=0;
v_prev_alloc_amount NUMBER :=0;
v_tot_alloc_amount NUMBER :=0;
v_count NUMBER :=0;
v_count2 NUMBER :=0;
v_factor NUMBER :=0;
v_remnant_amount NUMBER;
v_net_alloc_amount NUMBER;
v_sum_alloc_amts  NUMBER ;
v_sum_tot_alloc_amt NUMBER;
l_alloc_txn_id      NUMBER := NULL; /** added for capint changes */
Function get_basis_factor( p_run_id       IN NUMBER
                          ,p_basis_method IN VARCHAR2
                          ,p_line_num     IN NUMBER
                          ,p_project_id   IN NUMBER
                          ,p_task_id      IN NUMBER ) return NUMBER
IS
 v_basis   number ;
BEGIN
  OPEN C_run_basis_det(p_run_id,p_basis_method,p_line_num, p_project_id, p_task_id) ;
  FETCH C_run_basis_det INTO v_basis;
  IF C_run_basis_det%NOTFOUND then  /* Bug 2182563 */
    CLOSE C_run_basis_det ;
    return 0 ;
  END IF ;
  CLOSE C_run_basis_det ;
  return NVL(v_basis,0) ;
EXCEPTION
  WHEN OTHERS THEN
    return (SQLCODE);
--    return 0 ;
END get_basis_factor ;
BEGIN
  pa_debug.set_err_stack('Create_Target_txns');
  pa_debug.G_err_stage:= 'CREATING TARGET TRANSACTIONS';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('create_target_txns: ' || 'LOG', pa_debug.G_err_stage);
     pa_debug.write_file('create_target_txns: ' || 'LOG','p_pool_amount : '|| to_char(p_pool_amount));
  END IF;
  v_tot_pool_amount:= p_pool_amount;
  IF p_allocation_method = 'I' THEN
    /* if allocation method is Incremental then consider sunk cost */
    get_sunk_cost(p_rule_id
                  , p_run_id
                  , p_fiscal_year
                  , p_quarter_num
                  , p_period_num
                  , p_amount_type
                  , v_src_sunk_cost
                  , v_tgt_sunk_cost
                  , NULL );
     v_sunk_cost :=NVL( v_src_sunk_cost,0) - NVL( v_tgt_sunk_cost,0) ;
IF P_DEBUG_MODE = 'Y' THEN
   pa_debug.write_file('create_target_txns: ' || 'LOG','v_src_sunk_cost is: '||to_char(v_src_sunk_cost) );
   pa_debug.write_file('create_target_txns: ' || 'LOG','v_tgt_sunk_cost is: '||to_char(v_tgt_sunk_cost) );
     pa_debug.write_file('create_target_txns: ' || 'LOG','v_sunk_cost is: '||to_char(v_sunk_cost) );
    pa_debug.write_file('create_target_txns: ' || 'LOG','v_tot_pool_amount_before_ is: '||to_char(v_tot_pool_amount) );
 END IF;
    v_tot_pool_amount := NVL(v_tot_pool_amount,0) + NVl(v_sunk_cost, 0);
 IF P_DEBUG_MODE = 'Y' THEN
    pa_debug.write_file('create_target_txns: ' || 'LOG','v_tot_pool_amount_after_ is: '||to_char(v_tot_pool_amount) );
 END IF;
  END IF;
 IF( p_basis_method = 'S') THEN
    /* get count of total number of project/tasks for targets */
    OPEN C_all_proj_task_count(p_run_id); /* 1900331 added p_run_id */
    FETCH C_all_proj_task_count
    INTO v_count;
    CLOSE C_all_proj_task_count;
    IF (v_count>0) THEN
      v_factor := 1/ v_count;
    END IF;
 END IF;
 FOR run_target_rec IN C_run_targets LOOP
    IF (p_basis_method = 'FS') THEN
      /* get the count of project/tasks for the current line */
      v_count2 := get_trg_line_proj_task_count( p_run_id,
                                                run_target_rec.line_num );
      IF (v_count2 >0) THEN
        v_factor := (NVL(run_target_rec.line_percent, 0)/100 )/ v_count2;
      END IF; /* end v_count2 */
    END IF; /* if p_basis_method */
    IF ( p_basis_method in ( 'P','FP','C' )) THEN
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('create_target_txns: ' || 'LOG','In basis_method'||p_basis_method);
      END IF;
      v_factor := get_basis_factor( p_run_id,
                                    p_basis_method,
                                    run_target_rec.line_num,
                                    run_target_rec.project_id,
                                    run_target_rec.task_id ) ;
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('create_target_txns: ' || 'LOG','V_factor is :'|| to_char(v_factor));
      END IF;
    END IF ;
         /* if basis amount is zero for a particular proj-task then show warning */
         IF (v_factor = 0 ) THEN
                  alloc_errors( p_rule_id, p_run_id, 'B','W',
                    'PA_AL_ZERO_TXN_BASIS_AMT', FALSE, 'Y',
                    run_target_rec.project_id, run_target_rec.task_id );
         END IF;
    v_curr_alloc_amount :=     v_tot_pool_amount * v_factor ;
 IF P_DEBUG_MODE = 'Y' THEN
    pa_debug.write_file('create_target_txns: ' || 'LOG', 'v_current_alloc_amount :'||to_char(v_curr_alloc_amount) );
 END IF;
    v_tot_alloc_amount := v_curr_alloc_amount;
    v_sum_tot_alloc_amt := v_sum_tot_alloc_amt + v_tot_alloc_amount ;
    IF (p_allocation_method = 'F') THEN
        v_prev_alloc_amount := 0;
    ELSE   /* if p_allocation_method = 'I' */
        v_prev_alloc_amount := get_previous_alloc_amnt ( p_rule_id
                                                       , p_run_id
                                                       , run_target_rec.project_id
                                                       , run_target_rec.task_id
                                                       , p_quarter_num
                                                       , p_fiscal_year
                                                       , p_period_num
                                                       , 'T'
                                                       , p_amount_type );
        v_curr_alloc_amount := NVl(v_curr_alloc_amount,0) - NVl(v_prev_alloc_amount, 0);
    END IF;
      v_tot_alloc_amount:= pa_currency.round_currency_amt(v_tot_alloc_amount);
      v_prev_alloc_amount:= pa_currency.round_currency_amt(v_prev_alloc_amount);
      v_curr_alloc_amount:= pa_currency.round_currency_amt(v_curr_alloc_amount);
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('create_target_txns: ' || 'LOG', 'Amounts after rounding' );
     pa_debug.write_file('create_target_txns: ' || 'LOG', 'v_tot_alloc_amount:'||to_char(v_tot_alloc_amount) );
     pa_debug.write_file('create_target_txns: ' || 'LOG', 'v_prev_alloc_amount:'||to_char(v_prev_alloc_amount) );
     pa_debug.write_file('create_target_txns: ' || 'LOG', 'v_curr_alloc_amount:'||to_char(v_curr_alloc_amount) );
  END IF;
      pa_debug.G_err_stage:= 'INSERTING INTO ALLOC TXN DETAILS';
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('create_target_txns: ' || 'LOG', pa_debug.G_err_stage);
      END IF;
      /* insert into alloc_txn_details */
--
--    Bug: 983057  Do not create txn with zero curren alloc amount
--
      IF (v_curr_alloc_amount <> 0 ) THEN
	/** modified to call the api by reference **/
         ---insert_alloc_txn_details(  p_run_id
         ---, p_rule_id
         ---, 'T'
         ---, p_fiscal_year
         --- , p_quarter_num
         --- , p_period_num
         --- , p_run_period
         --- , run_target_rec.line_num
         --- , run_target_rec.project_id
         --- , run_target_rec.task_id
         --- , p_expenditure_type
         ---, v_tot_alloc_amount
         ---, v_prev_alloc_amount
         ---, v_curr_alloc_amount );
	 l_alloc_txn_id := Null;
	 insert_alloc_txn_details( x_alloc_txn_id         => l_alloc_txn_id
                                  , p_run_id              => p_run_id
                                  , p_rule_id             => p_rule_id
                                  , p_transaction_type    => 'T'
                                  , p_fiscal_year         => p_fiscal_year
                                  , p_quarter_num         => p_quarter_num
                                  , p_period_num          => p_period_num
                                  , p_run_period          => p_run_period
                                  , p_line_num            => run_target_rec.line_num
                                  , p_project_id          => run_target_rec.project_id
                                  , p_task_id             => run_target_rec.task_id
                                  , p_expenditure_type    => p_expenditure_type
                                  , p_total_allocation    => v_tot_alloc_amount
                                  , p_previous_allocation => v_prev_alloc_amount
                                  , p_current_allocation  => v_curr_alloc_amount
                                  , p_EXPENDITURE_ID      => NULL
                                  , p_EXPENDITURE_ITEM_ID => NULL
                                  , p_CINT_SOURCE_TASK_ID => NULL
                                  , p_CINT_EXP_ORG_ID     => NULL
                                  , p_CINT_RATE_MULTIPLIER => NULL
                                  , p_CINT_PRIOR_BASIS_AMT => NULL
                                  , p_CINT_CURRENT_BASIS_AMT => NULL
                                  , p_REJECTION_CODE      => NULL
                                  , p_STATUS_CODE         => NULL
                                  , p_ATTRIBUTE_CATEGORY  => NULL
                                  , p_ATTRIBUTE1          => NULL
                                  , p_ATTRIBUTE2          => NULL
                                  , p_ATTRIBUTE3          => NULL
                                  , p_ATTRIBUTE4          => NULL
                                  , p_ATTRIBUTE5          => NULL
                                  , p_ATTRIBUTE6          => NULL
                                  , p_ATTRIBUTE7          => NULL
                                  , p_ATTRIBUTE8          => NULL
                                  , p_ATTRIBUTE9          => NULL
                                  , p_ATTRIBUTE10         => NULL
				);
	 /* End of PA.L Capint changes */
         G_num_txns := G_num_txns + 1 ;
      END IF ;
      /* get the total allocated */
      v_net_alloc_amount := NVl(v_net_alloc_amount,0) + NVL(v_curr_alloc_amount,0) ;
      END LOOP;
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('create_target_txns: ' || 'LOG', 'v_net_alloc_amount:'||to_char(v_net_alloc_amount) );
       END IF;
        pa_debug.G_err_stage:= 'ALLOCATING REMNANT';
        IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('create_target_txns: ' || 'LOG', pa_debug.G_err_stage);
        END IF;
        If p_allocation_method = 'I' then
           IF( p_amount_type = 'ITD') THEN
             v_fiscal_year:= NULL;
             v_quarter_num:= NULL;
             v_period_num := NULL;
           ELSIF (p_amount_type = 'FYTD') THEN
             v_fiscal_year:= p_fiscal_year;
             v_quarter_num:= NULL;
             v_period_num := NULL;
           ELSIF (p_amount_type = 'QTD') THEN
             v_fiscal_year:= p_fiscal_year;
             v_quarter_num:= p_quarter_num;
             v_period_num := NULL;
           ELSE
             v_fiscal_year:= p_fiscal_year;
             v_quarter_num:= p_quarter_num;
             v_period_num := p_period_num;
           END IF;
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('create_target_txns: ' || 'LOG', 'Fetching sum of allocated amounts until the current run' );
           END IF;
           Open c_sum_of_allocated_amts ;
           Fetch c_sum_of_allocated_amts into v_sum_alloc_amts ;
           if c_sum_of_allocated_amts%NOTFOUND then
             v_sum_alloc_amts := 0 ;
           end if ;
           Close c_sum_of_allocated_amts ;
        End If ;
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('create_target_txns: ' || 'LOG', 'v_sum_alloc_amts:'||to_char(v_sum_alloc_amts) );
       END IF;
       allocate_remnant ( p_run_id, p_pool_amount + v_src_sunk_cost - nvl(v_sum_alloc_amts,0)
                            , v_remnant_amount);
        pa_debug.G_err_stage:= 'UPDATING ALLOC RUNS WITH AMOUNTS';
        IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('create_target_txns: ' || 'LOG', pa_debug.G_err_stage);
          pa_debug.write_file('create_target_txns: ' || 'LOG', 'v_sum_alloc_amts:'||to_char(v_sum_alloc_amts) );
          pa_debug.write_file('create_target_txns: ' || 'LOG', 'v_net_alloc_amount:'||to_char(v_net_alloc_amount) );
          pa_debug.write_file('create_target_txns: ' || 'LOG', 'v_remnant_amount:'||to_char(v_remnant_amount) );
          pa_debug.write_file('create_target_txns: ' || 'LOG', 'v_src_sunk_cost:'||to_char(v_src_sunk_cost) );
          pa_debug.write_file('create_target_txns: ' || 'LOG', 'v_tgt_sunk_cost:'||to_char(v_tgt_sunk_cost) );
       END IF;
        x_curr_alloc_amount :=  nvl(v_net_alloc_amount,0)+nvl(v_remnant_amount,0) ;
        UPDATE pa_alloc_runs
        SET total_pool_amount = nvl(p_pool_amount,0)
          , allocated_amount = nvl(v_net_alloc_amount,0)+nvl(v_remnant_amount,0)
          , Missing_source_proj_amt = v_src_sunk_cost
          , Missing_target_proj_amt = v_tgt_sunk_cost
          , Total_allocated_amount  = nvl(v_sum_alloc_amts,0) + nvl(v_net_alloc_amount,0)+nvl(v_remnant_amount,0)-nvl(v_tgt_sunk_cost,0)
        WHERE run_id = p_run_id;
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    pa_debug.G_err_code := SQLCODE;
    RAISE;
END create_target_txns;
-- ------------------------------------------------------------
-- create_offset_txns
-- ------------------------------------------------------------
PROCEDURE create_offset_txns( p_rule_id           IN NUMBER
                            , p_run_id            IN NUMBER
                            , p_type              IN VARCHAR2
                            , p_fiscal_year       IN NUMBER
                            , p_quarter_num       IN NUMBER
                            , p_period_num        IN NUMBER
                            , p_run_period        IN VARCHAR2
                            , p_expenditure_type  IN VARCHAR2
                            , p_allocation_method IN VARCHAR2
                            , p_offset_method      IN VARCHAR2
                            , p_offset_project_id  IN NUMBER
                            , p_offset_task_id     IN NUMBER
                            , p_amount_type        IN VARCHAR2
                            , p_pool_amount        IN NUMBER
                            , p_allocated_amount   IN NUMBER ) IS
CURSOR C_offset_det IS
  SELECT line_num, project_id, task_id, nvl(sum(nvl(eligible_amount,0)),0) eligible_amount
  FROM pa_alloc_run_source_det
  WHERE run_id=p_run_id
  GROUP BY line_num, project_id, task_id;
CURSOR c_offset_proj_sum IS
  SELECT project_id, nvl(sum(nvl(eligible_amount,0)),0) eligible_amount
  FROM pa_alloc_run_source_det
  WHERE run_id = p_run_id
  GROUP BY project_id ;
CURSOR c_pool_amount IS
  SELECT nvl(sum(nvl(eligible_amount,0)),0) pool_amount
  FROM pa_alloc_run_source_det
  WHERE run_id = p_run_id;
  v_project_id   NUMBER ;
  v_task_id      NUMBER ;
  v_proj_prev_offset_amt NUMBER ;
 -- This cursor will get the previously allocated offset amounts for a given source project
 -- on the tasks other than current task provided by client extension.
CURSOR C_prev_offset_task_CE (v_project_id IN NUMBER
                            , v_task_id    IN NUMBER) is
   SELECT nvl(sum(nvl(current_allocation,0)),0)
     from pa_alloc_txn_details pat
         ,pa_alloc_runs par
    where pat.run_id = par.run_id
      and par.fiscal_year = nvl(p_fiscal_year, par.fiscal_year)
      and par.quarter     = nvl(p_quarter_num,par.quarter)
      and par.period_num  = nvl(p_period_num , par.period_num)
      and par.run_id < p_run_id
      and par.rule_id = p_rule_id
      and par.run_status = 'RS'
      and pat.transaction_type = 'O'
      and pat.project_id = v_project_id
      and pat.task_id   <> v_task_id ;
CURSOR C_off_sunk_cost( p_fscl_year IN NUMBER
        , p_qrtr_num  IN NUMBER
        , p_prd_num   IN NUMBER ) IS
  SELECT a.run_id  run_id
  , a.project_id  project_id
  , a.task_id     task_id
  , nvl(a.Total_allocation,0) Total_allocation
  FROM pa_alloc_txn_details a,
       pa_alloc_runs ar
  WHERE a.run_id = ar.run_id
  AND  a.rule_id = p_rule_id
  AND  ar.fiscal_year = NVL(p_fscl_year, ar.fiscal_year)
  AND  ar.quarter = NVL(p_qrtr_num, ar.quarter)
  AND ar.period_num = NVL(p_prd_num, ar.period_num )
  AND  a.run_id < p_run_id
  AND  a.transaction_type  = 'O'
  AND NOT EXISTS ( SELECT 1
                  FROM pa_alloc_txn_details b
                  WHERE b.project_id = a.project_id
                    AND b.task_id = a.task_id
                    AND b.transaction_type    = 'O'
                    AND b.run_id = p_run_id )
  AND a.run_id =( SELECT max(c.run_id)
                  FROM pa_alloc_txn_details c,
                       pa_alloc_runs c_ar   -- added this table to exclude reversed runs.
                  WHERE c.project_id = a.project_id
                  AND c.task_id = a.task_id
                  AND c.transaction_type    = 'O'
                  AND c.run_id = c_ar.run_id
                  AND c_ar.rule_id = p_rule_id
                  AND c_ar.run_status = 'RS'
                  AND c.run_id < p_run_id );
v_tot_pool_amount NUMBER := 0;
v_curr_offset_amount NUMBER := 0;
v_prev_offset_amount NUMBER := 0;
v_tot_offset_amount NUMBER := 0;
v_src_sunk_cost NUMBER :=0;
v_tgt_sunk_cost NUMBER :=0;
v_off_sunk_cost NUMBER := 0 ;
v_sum_tot_offsets NUMBER := 0 ;
v_cx_task_id NUMBER ;
v_cx_project_id NUMBER ;
l_alloc_txn_id      NUMBER := NULL; /** added for capint changes */
v_quarter_num NUMBER;
v_fiscal_year NUMBER;
v_period_num NUMBER;
v_status NUMBER :=NULL;
v_err_message VARCHAR2(250);
v_returned_amount  NUMBER := 0;
v_offset_extn_tabtype PA_CLIENT_EXTN_ALLOC.ALLOC_OFFSET_TABTYPE;
BEGIN
  pa_debug.set_err_stack('Create_Offset_txns');
  pa_debug.G_err_stage:= 'CREATING OFFSET TRANSACTIONS';
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('create_offset_txns: ' || 'LOG', pa_debug.G_err_stage);
  END IF;
  IF (p_offset_method = 'A') THEN   -- Offset Method: Same as source
    FOR offset_det_rec IN c_offset_det LOOP
  v_tot_offset_amount := offset_det_rec.eligible_amount * (-1);
      IF p_allocation_method = 'I' THEN
        v_prev_offset_amount := get_previous_alloc_amnt( p_rule_id
                                                       , p_run_id
                                                       , offset_det_rec.project_id
                                                       , offset_det_rec.task_id
                                                       , p_quarter_num
                                                       , p_fiscal_year
                                                       , p_period_num
                                                       , 'O'
                                                       , p_amount_type );
      ELSE   /* if full allocation */
        v_prev_offset_amount:= 0;
      END IF;
      v_curr_offset_amount := NVl(v_tot_offset_amount,0) - NVL(v_prev_offset_amount,0);
      v_tot_offset_amount:= pa_currency.round_currency_amt(v_tot_offset_amount);
      v_prev_offset_amount:= pa_currency.round_currency_amt(v_prev_offset_amount);
      v_curr_offset_amount:= pa_currency.round_currency_amt(v_curr_offset_amount);
      v_sum_tot_offsets := v_sum_tot_offsets + v_tot_offset_amount ;
      /* insert into alloc_txn_details */
--
--    Bug: 983057  Do not create txn with zero curren alloc amount
--
      IF (v_curr_offset_amount <> 0 ) THEN
	/** Calling the api by reference changed for capint */
      	--insert_alloc_txn_details( p_run_id
        --                      , p_rule_id
        --                      , 'O'
        --                      , p_fiscal_year
        --                      , p_quarter_num
        --                      , p_period_num
        --                      , p_run_period
        --                      , offset_det_rec.line_num
        --                      , offset_det_rec.project_id
        --                      , offset_det_rec.task_id
        --                      , p_expenditure_type
        --                      , v_tot_offset_amount
        --                      , v_prev_offset_amount
        --                      , v_curr_offset_amount );
	 l_alloc_txn_id :=  Null;
         insert_alloc_txn_details( x_alloc_txn_id         => l_alloc_txn_id
                                  , p_run_id              => p_run_id
                                  , p_rule_id             => p_rule_id
                                  , p_transaction_type    => 'O'
                                  , p_fiscal_year         => p_fiscal_year
                                  , p_quarter_num         => p_quarter_num
                                  , p_period_num          => p_period_num
                                  , p_run_period          => p_run_period
                                  , p_line_num            => offset_det_rec.line_num
                                  , p_project_id          => offset_det_rec.project_id
                                  , p_task_id             => offset_det_rec.task_id
                                  , p_expenditure_type    => p_expenditure_type
                                  , p_total_allocation    => v_tot_offset_amount
                                  , p_previous_allocation => v_prev_offset_amount
                                  , p_current_allocation  => v_curr_offset_amount
                                  , p_EXPENDITURE_ID      => NULL
                                  , p_EXPENDITURE_ITEM_ID => NULL
                                  , p_CINT_SOURCE_TASK_ID => NULL
                                  , p_CINT_EXP_ORG_ID     => NULL
                                  , p_CINT_RATE_MULTIPLIER => NULL
                                  , p_CINT_PRIOR_BASIS_AMT => NULL
                                  , p_CINT_CURRENT_BASIS_AMT => NULL
                                  , p_REJECTION_CODE      => NULL
                                  , p_STATUS_CODE         => NULL
                                  , p_ATTRIBUTE_CATEGORY  => NULL
                                  , p_ATTRIBUTE1          => NULL
                                  , p_ATTRIBUTE2          => NULL
                                  , p_ATTRIBUTE3          => NULL
                                  , p_ATTRIBUTE4          => NULL
                                  , p_ATTRIBUTE5          => NULL
                                  , p_ATTRIBUTE6          => NULL
                                  , p_ATTRIBUTE7          => NULL
                                  , p_ATTRIBUTE8          => NULL
                                  , p_ATTRIBUTE9          => NULL
                                  , p_ATTRIBUTE10         => NULL
                                );
	/* End of capint changes */
         G_num_txns := G_num_txns + 1 ;
      END IF ;
      END LOOP;
  ELSIF (p_offset_method = 'B') THEN -- Offset Method: same as source project, CE tasks
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('create_offset_txns: ' || 'LOG', 'Test offset method B ');
    END IF;
    FOR offset_proj_sum_rec IN c_offset_proj_sum LOOP
      pa_client_extn_alloc.offset_task_extn(p_rule_id, offset_proj_sum_rec.project_id, v_task_id,v_status,v_err_message);
      IF nvl(v_status,0) <>0 THEN
         v_err_message:=nvl(v_err_message,'PA_AL_CE_FAILED');
         alloc_errors(p_rule_id, p_run_id,'O','E',v_err_message,TRUE);
      END IF;
      v_cx_task_id:=NVL(v_task_id,0);
      v_cx_project_id:=NVL(offset_proj_sum_rec.project_id,0);
      IF  is_offset_task_valid(v_cx_project_id, v_cx_task_id) = 'N' THEN
         G_fatal_err_found:= TRUE;
         alloc_errors( p_rule_id, p_run_id, 'O', 'E',
                        'PA_AL_INV_PROJECT_TASK_IN_CE',FALSE,'Y',NULL, v_task_id);
         IF P_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('create_offset_txns: ' || 'LOG','Client Extension returned an invalid offset task:  '
                          || to_char(v_cx_task_id));
         END IF;
       END IF;
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('create_offset_txns: ' || 'LOG', 'v_task_id: '||to_char(v_task_id) );
      END IF;
      v_tot_offset_amount:= offset_proj_sum_rec.eligible_amount * (-1);
      IF (p_allocation_method = 'I') THEN  /* incremental */
        v_prev_offset_amount := get_previous_alloc_amnt( p_rule_id
                                                       , p_run_id
                                                       , offset_proj_sum_rec.project_id
                                                       , v_task_id
                                                       , p_quarter_num
                                                       , p_fiscal_year
                                                       , p_period_num
                                                       , 'O'
                                                       , p_amount_type );
         get_sunk_cost(p_rule_id
                  , p_run_id
                  , p_fiscal_year
                  , p_quarter_num
                  , p_period_num
                  , p_amount_type
                  , v_src_sunk_cost
                  , v_tgt_sunk_cost
                  , offset_proj_sum_rec.project_id);
           open C_prev_offset_task_CE( offset_proj_sum_rec.project_id,v_task_id ) ;
           Fetch C_prev_offset_task_CE into v_proj_prev_offset_amt;
           Close C_prev_offset_task_CE ;
           IF P_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('create_offset_txns: ' || 'LOG', 'offset project:Task:total_amount:src_sunk_cost:prev_offset '
                                ||to_char(offset_proj_sum_rec.project_id)||':'
                                ||to_char(v_task_id)|| ':'
                                ||to_char(v_tot_offset_amount)|| ':'
                                || to_char(v_src_sunk_cost)||':'
                                || to_char(v_proj_prev_offset_amt) );
           END IF;
          v_tot_offset_amount:= v_tot_offset_amount +  NVL(v_src_sunk_cost,0) *(-1) - v_proj_prev_offset_amt ;
      ELSE   /* if full allocation */
        v_prev_offset_amount := 0;
      END IF;
      v_curr_offset_amount:= NVL(v_tot_offset_amount,0) - NVL(v_prev_offset_amount,0);
      v_tot_offset_amount:= pa_currency.round_currency_amt(v_tot_offset_amount);
      v_prev_offset_amount:= pa_currency.round_currency_amt(v_prev_offset_amount);
      v_curr_offset_amount:= pa_currency.round_currency_amt(v_curr_offset_amount);
      v_sum_tot_offsets := v_sum_tot_offsets + v_tot_offset_amount ;
      /* insert into alloc_txn_details */
--
--    Bug: 983057  Do not create txn with zero curren alloc amount
--
      IF (v_curr_offset_amount <> 0 ) THEN
		/* Start of capint changes Call by reference */
      		--insert_alloc_txn_details( p_run_id
                --              , p_rule_id
                --              , 'O'
                --              , p_fiscal_year
                --              , p_quarter_num
                --              , p_period_num
                --              , p_run_period
                --              , 0 /* offset_proj_sum_rec.line_num */
                --              , offset_proj_sum_rec.project_id
                --              , v_task_id
                --              , p_expenditure_type
                --              , v_tot_offset_amount
                --              , v_prev_offset_amount
                --              , v_curr_offset_amount );
         	l_alloc_txn_id :=  Null;
         	insert_alloc_txn_details( x_alloc_txn_id  => l_alloc_txn_id
                                  , p_run_id              => p_run_id
                                  , p_rule_id             => p_rule_id
                                  , p_transaction_type    => 'O'
                                  , p_fiscal_year         => p_fiscal_year
                                  , p_quarter_num         => p_quarter_num
                                  , p_period_num          => p_period_num
                                  , p_run_period          => p_run_period
                                  , p_line_num            => 0 /* offset_proj_sum_rec.line_num */
                                  , p_project_id          => offset_proj_sum_rec.project_id
                                  , p_task_id             => v_task_id
                                  , p_expenditure_type    => p_expenditure_type
                                  , p_total_allocation    => v_tot_offset_amount
                                  , p_previous_allocation => v_prev_offset_amount
                                  , p_current_allocation  => v_curr_offset_amount
                                  , p_EXPENDITURE_ID      => NULL
                                  , p_EXPENDITURE_ITEM_ID => NULL
                                  , p_CINT_SOURCE_TASK_ID => NULL
                                  , p_CINT_EXP_ORG_ID     => NULL
                                  , p_CINT_RATE_MULTIPLIER => NULL
                                  , p_CINT_PRIOR_BASIS_AMT => NULL
                                  , p_CINT_CURRENT_BASIS_AMT => NULL
                                  , p_REJECTION_CODE      => NULL
                                  , p_STATUS_CODE         => NULL
                                  , p_ATTRIBUTE_CATEGORY  => NULL
                                  , p_ATTRIBUTE1          => NULL
                                  , p_ATTRIBUTE2          => NULL
                                  , p_ATTRIBUTE3          => NULL
                                  , p_ATTRIBUTE4          => NULL
                                  , p_ATTRIBUTE5          => NULL
                                  , p_ATTRIBUTE6          => NULL
                                  , p_ATTRIBUTE7          => NULL
                                  , p_ATTRIBUTE8          => NULL
                                  , p_ATTRIBUTE9          => NULL
                                  , p_ATTRIBUTE10         => NULL
                                );
		/* End of capint changes */
         G_num_txns := G_num_txns + 1 ;
       END IF ;
    END LOOP;
  ELSIF( p_offset_method= 'C' ) THEN  --Offset Method:  Specific project and Task
    IF (p_allocation_method = 'I') THEN
        v_prev_offset_amount := Get_previous_alloc_amnt( p_rule_id
                                                     , p_run_id
                                                     , p_offset_project_id
                                                     , p_offset_task_id
                                                     , p_quarter_num
                                                     , p_fiscal_year
                                                     , p_period_num
                                                     , 'O'
                                                     , p_amount_type );
       v_tot_offset_amount:= v_tot_offset_amount + v_src_sunk_cost * (-1);
    ELSE  /* full allocation */
      v_prev_offset_amount:= 0;
    END IF;
    v_tot_offset_amount := (p_allocated_amount*-1) + v_prev_offset_amount ;
    v_prev_offset_amount:= pa_currency.round_currency_amt(v_prev_offset_amount);
    v_curr_offset_amount:= pa_currency.round_currency_amt(p_allocated_amount*-1);
    v_tot_offset_amount:= pa_currency.round_currency_amt(v_tot_offset_amount);
      v_sum_tot_offsets := v_sum_tot_offsets + v_tot_offset_amount ;
    /* insert into alloc_txn_details */
--
--    Bug: 983057  Do not create txn with zero curren alloc amount
--
      IF (v_curr_offset_amount <> 0 ) THEN
		/** Start Capint changes  call by reference */
    		--insert_alloc_txn_details( p_run_id
                --            , p_rule_id
                --            , 'O'
                --            , p_fiscal_year
                --            , p_quarter_num
                --            , p_period_num
                --            , p_run_period
                --            , 0
                --            , p_offset_project_id
                --            , p_offset_task_id
                --            , p_expenditure_type
                --            , v_tot_offset_amount
                --            , v_prev_offset_amount
                --            , v_curr_offset_amount );
                l_alloc_txn_id :=  Null;
                insert_alloc_txn_details( x_alloc_txn_id  => l_alloc_txn_id
                                  , p_run_id              => p_run_id
                                  , p_rule_id             => p_rule_id
                                  , p_transaction_type    => 'O'
                                  , p_fiscal_year         => p_fiscal_year
                                  , p_quarter_num         => p_quarter_num
                                  , p_period_num          => p_period_num
                                  , p_run_period          => p_run_period
                                  , p_line_num            => 0
                                  , p_project_id          => p_offset_project_id
                                  , p_task_id             => p_offset_task_id
                                  , p_expenditure_type    => p_expenditure_type
                                  , p_total_allocation    => v_tot_offset_amount
                                  , p_previous_allocation => v_prev_offset_amount
                                  , p_current_allocation  => v_curr_offset_amount
                                  , p_EXPENDITURE_ID      => NULL
                                  , p_EXPENDITURE_ITEM_ID => NULL
                                  , p_CINT_SOURCE_TASK_ID => NULL
                                  , p_CINT_EXP_ORG_ID     => NULL
                                  , p_CINT_RATE_MULTIPLIER => NULL
                                  , p_CINT_PRIOR_BASIS_AMT => NULL
                                  , p_CINT_CURRENT_BASIS_AMT => NULL
                                  , p_REJECTION_CODE      => NULL
                                  , p_STATUS_CODE         => NULL
                                  , p_ATTRIBUTE_CATEGORY  => NULL
                                  , p_ATTRIBUTE1          => NULL
                                  , p_ATTRIBUTE2          => NULL
                                  , p_ATTRIBUTE3          => NULL
                                  , p_ATTRIBUTE4          => NULL
                                  , p_ATTRIBUTE5          => NULL
                                  , p_ATTRIBUTE6          => NULL
                                  , p_ATTRIBUTE7          => NULL
                                  , p_ATTRIBUTE8          => NULL
                                  , p_ATTRIBUTE9          => NULL
                                  , p_ATTRIBUTE10         => NULL
				);
		/* End capint chagnes */
         G_num_txns := G_num_txns + 1 ;
      END IF ;
  ELSIF (p_offset_method = 'D') THEN  -- Offset Method: CLient Extension
    v_tot_offset_amount:= p_allocated_amount * (-1);
    pa_client_extn_alloc.offset_extn( p_rule_id, v_tot_offset_amount
                              , v_offset_extn_tabtype,v_status,v_err_message);
    IF nvl(v_status,0) <> 0 THEN
       v_err_message:=nvl(v_err_message,'PA_AL_CE_FAILED');
       alloc_errors(p_rule_id,p_run_id,'O','E',v_err_message,TRUE);
    END IF;
    /* check whether tot_offset_amount retuned is same as what was passed */
    FOR I in 1..v_offset_extn_tabtype.count LOOP
             IF P_DEBUG_MODE = 'Y' THEN
                pa_debug.write_file('create_offset_txns: ' || 'LOG', 'offset project-Task: '||
              to_char(v_offset_extn_tabtype(I).project_id)||'-'||
              to_char(v_offset_extn_tabtype(I).task_id) || 'Index :'||to_char(I) );
             END IF;
              v_cx_project_id:=v_offset_extn_tabtype(I).project_id;
              v_cx_task_id:=v_offset_extn_tabtype(I).task_id;
             v_returned_amount := v_returned_amount + NVL(v_offset_extn_tabtype(I).offset_amount, 0);
        IF  is_offset_project_valid( v_cx_project_id) = 'N' THEN
              G_fatal_err_found:= TRUE;
              alloc_errors( p_rule_id, p_run_id, 'O', 'E',
                        'PA_AL_INV_PROJECT_TASK_IN_CE',FALSE,'Y',v_cx_project_id);
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('create_offset_txns: ' || 'LOG','Client Extension returned an invalid offset project:  '
                                        ||to_char(v_cx_project_id) );
              END IF;
        END IF;
        IF is_offset_task_valid(v_cx_project_id,v_cx_task_id ) = 'N' THEN
            G_fatal_err_found:= TRUE;
            alloc_errors( p_rule_id, p_run_id, 'O', 'E',
                        'PA_AL_INV_PROJECT_TASK_IN_CE',FALSE,'Y',v_cx_project_id,v_cx_task_id);
            IF P_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('create_offset_txns: ' || 'LOG','Client Extension returned an invalid offset task:  '
                                        || to_char(v_cx_task_id ));
            END IF;
        END IF;
    END LOOP;
    IF ( v_tot_offset_amount <> v_returned_amount ) THEN
            alloc_errors( p_rule_id, p_run_id, 'O', 'E',
                     'PA_AL_CLNT_INCORECT_OFFST_AMNT', TRUE );
    END IF;
  FOR I in 1..v_offset_extn_tabtype.count LOOP
      IF p_allocation_method = 'I' THEN
        v_prev_offset_amount := get_previous_alloc_amnt( p_rule_id
                                                       , p_run_id
                                                       , v_offset_extn_tabtype(I).project_id
                                                       , v_offset_extn_tabtype(I).task_id
                                                       , p_quarter_num
                                                       , p_fiscal_year
                                                       , p_period_num
                                                       , 'O'
                                                       , p_amount_type );
      ELSE   /* if full allocation */
        v_prev_offset_amount:= 0;
      END IF;
                    v_curr_offset_amount:=  v_offset_extn_tabtype(I).offset_amount;
                    v_tot_offset_amount:= NVl(v_curr_offset_amount,0) + NVl(v_prev_offset_amount,0);
      v_tot_offset_amount:= pa_currency.round_currency_amt(v_tot_offset_amount);
      v_prev_offset_amount:= pa_currency.round_currency_amt(v_prev_offset_amount);
      v_curr_offset_amount:= pa_currency.round_currency_amt(v_curr_offset_amount);
      v_sum_tot_offsets := v_sum_tot_offsets + v_tot_offset_amount ;
--
--    Bug: 983057  Do not create txn with zero curren alloc amount
--
      IF (v_curr_offset_amount <> 0 ) THEN
		/* Start Capint changes */
      		--insert_alloc_txn_details( p_run_id
                --              , p_rule_id
                --              , 'O'
                --              , p_fiscal_year
                --              , p_quarter_num
                --              , p_period_num
                --              , p_run_period
                --              , 0
                --              , v_offset_extn_tabtype(I).project_id
                --              , v_offset_extn_tabtype(I).task_id
                --              , p_expenditure_type
                --              , v_tot_offset_amount
                --              , v_prev_offset_amount
                --              , v_curr_offset_amount );
                l_alloc_txn_id :=  Null;
                insert_alloc_txn_details( x_alloc_txn_id  => l_alloc_txn_id
                                  , p_run_id              => p_run_id
                                  , p_rule_id             => p_rule_id
                                  , p_transaction_type    => 'O'
                                  , p_fiscal_year         => p_fiscal_year
                                  , p_quarter_num         => p_quarter_num
                                  , p_period_num          => p_period_num
                                  , p_run_period          => p_run_period
                                  , p_line_num            => 0
                                  , p_project_id          => v_offset_extn_tabtype(I).project_id
                                  , p_task_id             => v_offset_extn_tabtype(I).task_id
                                  , p_expenditure_type    => p_expenditure_type
                                  , p_total_allocation    => v_tot_offset_amount
                                  , p_previous_allocation => v_prev_offset_amount
                                  , p_current_allocation  => v_curr_offset_amount
                                  , p_EXPENDITURE_ID      => NULL
                                  , p_EXPENDITURE_ITEM_ID => NULL
                                  , p_CINT_SOURCE_TASK_ID => NULL
                                  , p_CINT_EXP_ORG_ID     => NULL
                                  , p_CINT_RATE_MULTIPLIER => NULL
                                  , p_CINT_PRIOR_BASIS_AMT => NULL
                                  , p_CINT_CURRENT_BASIS_AMT => NULL
                                  , p_REJECTION_CODE      => NULL
                                  , p_STATUS_CODE         => NULL
                                  , p_ATTRIBUTE_CATEGORY  => NULL
                                  , p_ATTRIBUTE1          => NULL
                                  , p_ATTRIBUTE2          => NULL
                                  , p_ATTRIBUTE3          => NULL
                                  , p_ATTRIBUTE4          => NULL
                                  , p_ATTRIBUTE5          => NULL
                                  , p_ATTRIBUTE6          => NULL
                                  , p_ATTRIBUTE7          => NULL
                                  , p_ATTRIBUTE8          => NULL
                                  , p_ATTRIBUTE9          => NULL
                                  , p_ATTRIBUTE10         => NULL
				);
		/* End capint changes */
         G_num_txns := G_num_txns + 1 ;
       END IF ;
    END LOOP;
  END IF; /* end of p_allocation_method */
  IF p_allocation_method = 'I' THEN
     IF( p_amount_type = 'ITD') THEN
       v_fiscal_year:= NULL;
       v_quarter_num:= NULL;
       v_period_num := NULL;
     ELSIF (p_amount_type = 'FYTD') THEN
       v_fiscal_year:= p_fiscal_year;
       v_quarter_num:= NULL;
       v_period_num := NULL;
     ELSIF (p_amount_type = 'QTD') THEN
       v_fiscal_year:= p_fiscal_year;
       v_quarter_num:= p_quarter_num;
       v_period_num := NULL;
     ELSE
       v_fiscal_year:= p_fiscal_year;
       v_quarter_num:= p_quarter_num;
       v_period_num := p_period_num;
     END IF;
     IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('create_offset_txns: ' || 'LOG',' calculate total offset missing cost'
                ||to_char(p_fiscal_year) || ' ' || to_char(v_quarter_num)
                || ' ' || to_char(v_period_num) );
     END IF;
     FOR off_sunk_cost_rec IN C_off_sunk_cost( v_fiscal_year
                                             , v_quarter_num
                                             , v_period_num ) LOOP
     IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('create_offset_txns: ' || 'LOG','off_sunk_cost = '|| to_char(off_sunk_cost_rec.Total_allocation) );
     END IF;
        insert_missing_costs( p_run_id
                             ,'O'
                             ,off_sunk_cost_rec.project_id
                             ,off_sunk_cost_rec.task_id
                             ,off_sunk_cost_rec.Total_allocation);
       v_off_sunk_cost := v_off_sunk_cost + nvl(off_sunk_cost_rec.Total_allocation,0) ;
     END LOOP;
     IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('create_offset_txns: ' || 'LOG','v_off_sunk_cost =' ||to_char(v_off_sunk_cost) );
     END IF;
  END IF ;
       update pa_alloc_runs
          set  Missing_offset_proj_amt = nvl(v_off_sunk_cost,0) ,
               TOTAL_OFFSETTED_AMOUNT  = v_sum_tot_offsets
        where run_id = p_run_id ;
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    pa_debug.G_err_code := SQLCODE;
    RAISE;
END create_offset_txns;
-- ------------------------------------------------------------
-- allocate_remnant
-- ------------------------------------------------------------
PROCEDURE allocate_remnant( p_run_id IN NUMBER
                          , p_act_alloc_amount IN NUMBER
                          , x_remnant_amount OUT NOCOPY NUMBER ) IS
CURSOR c_amnt_before_remnant IS
  SELECT nvl(SUM(current_allocation),0) sum_curr_alloc
       , MAX( ABS(current_allocation) ) max_curr_alloc
  FROM pa_alloc_txn_details
  WHERE run_id = p_run_id
  AND transaction_type = 'T';
CURSOR c_remnant_proj_task( p_max_alloc IN NUMBER ) IS
  SELECT project_id, task_id
  FROM pa_alloc_txn_details
  WHERE run_id = p_run_id
  AND transaction_type = 'T'
  AND ABS(current_allocation) = p_max_alloc;
v_tot_pool_amount NUMBER;
v_sum_curr_alloc NUMBER;
v_max_curr_alloc NUMBER;
v_project_id NUMBER;
v_task_id NUMBER;
v_amount NUMBER;
v_remnant NUMBER;
BEGIN
  pa_debug.set_err_stack ('allocate_remnant');
  OPEN c_amnt_before_remnant;
  FETCH c_amnt_before_remnant INTO v_sum_curr_alloc, v_max_curr_alloc ;
  CLOSE c_amnt_before_remnant;
 IF P_DEBUG_MODE = 'Y' THEN
    pa_debug.write_file('allocate_remnant: ' || 'LOG', 'Actual allocated amount is:'|| to_char(p_act_alloc_amount));
 END IF;
  v_remnant:= p_act_alloc_amount - v_sum_curr_alloc;
  IF (v_remnant <>0 ) THEN
  OPEN c_remnant_proj_task( v_max_curr_alloc );
  FETCH c_remnant_proj_task INTO v_project_id, v_task_id;
  CLOSE c_remnant_proj_task;
  x_remnant_amount:= NVL(v_remnant,0);
  UPDATE pa_alloc_txn_details
  SET current_allocation = NVL(current_allocation,0) + NVL(v_remnant,0)
   ,  total_allocation = NVL(total_allocation, 0) + NVl(v_remnant, 0)
  WHERE run_id = p_run_id
  AND transaction_type='T'
  AND project_id = v_project_id
  AND task_id = v_task_id;
  END IF;
  pa_debug.reset_err_stack ;
EXCEPTION
  WHEN OTHERS THEN
    pa_debug.G_err_code := SQLCODE;
    RAISE;
END allocate_remnant;
-- ------------------------------------------------------------
-- insert_alloc_runs
-- ------------------------------------------------------------
PROCEDURE insert_alloc_runs( x_run_id                  IN OUT NOCOPY NUMBER /* modified as IN OUT for capint */
                           , p_rule_id                 IN NUMBER
                           , p_run_period              IN VARCHAR2
                           , p_expnd_item_date         IN DATE
                           , p_creation_date           IN DATE
                           , p_created_by              IN NUMBER
                           , p_last_update_date        IN DATE
                           , p_last_updated_by         IN NUMBER
                           , p_last_update_login       IN NUMBER
                           , p_pool_percent            IN NUMBER
                           , p_period_type             IN VARCHAR2
                           , p_source_amount_type      IN VARCHAR2
                           , p_source_balance_category IN VARCHAR2
                           , p_source_balance_type     IN VARCHAR2
                           , p_alloc_resource_list_id  IN NUMBER
                           , p_auto_release_flag       IN VARCHAR2
                           , p_allocation_method       IN VARCHAR2
                           , p_imp_with_exception      IN VARCHAR2
                           , p_dup_targets_flag        IN VARCHAR2
                           , p_target_exp_type_class   IN VARCHAR2
                           , p_target_exp_org_id       IN NUMBER
                           , p_target_exp_type         IN VARCHAR2
                           , p_target_cost_type        IN VARCHAR2
                           , p_offset_exp_type_class   IN VARCHAR2
                           , p_offset_exp_org_id       IN NUMBER
                           , p_offset_exp_type         IN VARCHAR2
                           , p_offset_cost_type        IN VARCHAR2
                           , p_offset_method           IN VARCHAR2
                           , p_offset_project_id       IN NUMBER
                           , p_offset_task_id          IN NUMBER
                           , p_run_status              IN VARCHAR2
                           , p_basis_method            IN VARCHAR2
                           , p_basis_relative_period   IN NUMBER
                           , p_basis_amount_type       IN VARCHAR2
                           , p_basis_balance_category  IN VARCHAR2
                           , p_basis_budget_type_code  IN VARCHAR2
                           , p_basis_balance_type      IN VARCHAR2
                           , p_basis_resource_list_id  IN NUMBER
                           , p_fiscal_year             IN NUMBER
                           , p_quarter                 IN NUMBER
                           , p_period_num              IN VARCHAR2
                           , p_target_exp_group        IN VARCHAR2
                           , p_offset_exp_group        IN VARCHAR2
                           , p_total_pool_amount       IN NUMBER
                           , p_allocated_amount        IN NUMBER
                           , p_reversal_date           IN DATE
                           , p_draft_request_id        IN NUMBER
                           , p_draft_request_date      IN DATE
                           , p_release_request_id      IN NUMBER
                           , p_release_request_date    IN DATE
                           , p_denom_currency_code     IN VARCHAR2
                           , p_fixed_amount            IN NUMBER
                           , p_rev_target_exp_group    IN VARCHAR2
                           , p_rev_offset_exp_group    IN VARCHAR2
                           , p_org_id                  IN NUMBER
                           , p_limit_target_projects_code IN VARCHAR2
						   , p_CINT_RATE_NAME            IN VARCHAR2 default NULL
						   /* FP.M : Allocation Impact : bug # 3512552 */
						   , p_ALLOC_RESOURCE_STRUCT_TYPE In Varchar2 default NULL
						   , p_BASIS_RESOURCE_STRUCT_TYPE In Varchar2 default NULL
						   , p_ALLOC_RBS_VERSION          In Number default NULL
						   , p_BASIS_RBS_VERSION          In Number default NULL
						   ) IS
BEGIN
  pa_debug.set_err_stack('insert_alloc_runs');
  If x_run_id is NULL then
	Select pa_alloc_runs_s.nextval
	Into x_run_id
	From dual;
  End If;
  INSERT INTO pa_alloc_runs_all (
    RUN_ID
  , RULE_ID
  , RUN_PERIOD
  , EXPND_ITEM_DATE
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  , POOL_PERCENT
  , PERIOD_TYPE
  , SOURCE_AMOUNT_TYPE
  , SOURCE_BALANCE_CATEGORY
  , SOURCE_BALANCE_TYPE
  , ALLOC_RESOURCE_LIST_ID
  , AUTO_RELEASE_FLAG
  , ALLOCATION_METHOD
  , IMP_WITH_EXCEPTION
  , DUP_TARGETS_FLAG
  , TARGET_EXP_TYPE_CLASS
  , TARGET_EXP_ORG_ID
  , TARGET_EXP_TYPE
  , TARGET_COST_TYPE
  , OFFSET_EXP_TYPE_CLASS
  , OFFSET_EXP_ORG_ID
  , OFFSET_EXP_TYPE
  , OFFSET_COST_TYPE
  , OFFSET_METHOD
  , OFFSET_PROJECT_ID
  , OFFSET_TASK_ID
  , RUN_STATUS
  , BASIS_METHOD
  , BASIS_RELATIVE_PERIOD
  , BASIS_AMOUNT_TYPE
  , BASIS_BALANCE_CATEGORY
  , BASIS_BUDGET_TYPE_CODE
  , BASIS_FIN_PLAN_TYPE_ID                   /* added bug 2619977 */
  , BASIS_BALANCE_TYPE
  , BASIS_RESOURCE_LIST_ID
  , FISCAL_YEAR
  , QUARTER
  , PERIOD_NUM
  , TARGET_EXP_GROUP
  , OFFSET_EXP_GROUP
  , TOTAL_POOL_AMOUNT
  , ALLOCATED_AMOUNT
  , REVERSAL_DATE
  , DRAFT_REQUEST_ID
  , DRAFT_REQUEST_DATE
  , RELEASE_REQUEST_ID
  , RELEASE_REQUEST_DATE
  , DENOM_CURRENCY_CODE
  , FIXED_AMOUNT
  , REV_TARGET_EXP_GROUP
  , REV_OFFSET_EXP_GROUP
  , org_id
  , limit_target_projects_code
  , cint_rate_name
  /* FP.M : Allocation Impact : Bug # 3512552 */
  , ALLOC_RESOURCE_STRUCT_TYPE
  , BASIS_RESOURCE_STRUCT_TYPE
  , ALLOC_RBS_VERSION
  , BASIS_RBS_VERSION
  )
  VALUES (
    x_run_id
    ---p_run_id
  , p_rule_id
  , p_run_period
  , p_expnd_item_date
  , p_creation_date
  , p_created_by
  , p_last_update_date
  , p_last_updated_by
  , p_last_update_login
  , p_pool_percent
  , p_period_type
  , p_source_amount_type
  , p_source_balance_category
  , p_source_balance_type
  , p_alloc_resource_list_id
  , p_auto_release_flag
  , p_allocation_method
  , p_imp_with_exception
  , p_dup_targets_flag
  , p_target_exp_type_class
  , p_target_exp_org_id
  , p_target_exp_type
  , p_target_cost_type
  , p_offset_exp_type_class
  , p_offset_exp_org_id
  , p_offset_exp_type
  , p_offset_cost_type
  , p_offset_method
  , p_offset_project_id
  , p_offset_task_id
  , p_run_status
  , p_basis_method
  , p_basis_relative_period
  , p_basis_amount_type
  , p_basis_balance_category
  , p_basis_budget_type_code
  , G_basis_fin_plan_type_id    /* added bug 2619977 */
  , p_basis_balance_type
  , p_basis_resource_list_id
  , p_fiscal_year
  , p_quarter
  , p_period_num
  , p_target_exp_group
  , p_offset_exp_group
  , p_total_pool_amount
  , p_allocated_amount
  , p_reversal_date
  , p_draft_request_id
  , p_draft_request_date
  , p_release_request_id
  , p_release_request_date
  , p_denom_currency_code
  , p_fixed_amount
  , p_rev_target_exp_group
  , p_rev_offset_exp_group
  , p_org_id
  , p_limit_target_projects_code
  , p_CINT_RATE_NAME
   /* FP.M : Allocation Impact : Bug # 3512552 */
  , p_ALLOC_RESOURCE_STRUCT_TYPE
  , p_BASIS_RESOURCE_STRUCT_TYPE
  , p_ALLOC_RBS_VERSION
  , p_BASIS_RBS_VERSION
  ) ;
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
  pa_debug.G_err_code:= SQLCODE;
  RAISE;
END insert_alloc_runs;
-- ------------------------------------------------------------
-- get_fiscalyear_quarter
-- PROCEDURE : get_fiscalyear_quarter()
--   Purpose : For a given run_period_type (PA/GL) and run_period,
--             this PROCEDURE will get period_type, period_set_name(calender)
--             ,period_year ( Fiscal Year), quarterperiod_num and
--             end date of the run period.
--   Created : 27-JUL-98   Sesivara
-- ------------------------------------------------------------
PROCEDURE get_fiscalyear_quarter(   p_run_period_type  IN VARCHAR2,
                                    p_run_period         IN  VARCHAR2 ,
                                    x_period_type      OUT NOCOPY VARCHAR2 ,
                                    x_period_set_name  OUT NOCOPY VARCHAR2 ,
                                    x_period_year      OUT NOCOPY NUMBER   ,
                                    x_quarter          OUT NOCOPY NUMBER   ,
                                    x_period_num       OUT NOCOPY NUMBER   ,
                                    x_run_period_end_date  OUT NOCOPY DATE )
IS
  Cursor C_fy_qtr is
     select  decode(p_run_period_type,'PA', b.pa_period_type, a.accounted_period_type),
             a.period_set_name,glp.period_year,glp.quarter_num,glp.period_num,end_date
      from  gl_periods glp,
            gl_sets_of_books a,
            pa_implementations b
      where a.set_of_books_id    =  b.set_of_books_id
        and glp.period_set_name  =  a.period_set_name
        and glp.period_type      = decode(p_run_period_type,'PA', b.pa_period_type,
                                   a.accounted_period_type)
        and glp.period_name =  p_run_period ;
BEGIN
      OPEN C_fy_qtr ;
      FETCH C_fy_qtr into  x_period_type, x_period_set_name, x_period_year,
                           x_quarter,x_period_num, x_run_period_end_date;
      IF C_fy_qtr%NOTFOUND then
          G_fatal_err_found:= TRUE;
         alloc_errors(G_rule_id, G_alloc_run_id, 'R', 'E','PA_AL_INVALID_RUN_PERIOD',TRUE) ;
      End If;
      Close C_fy_qtr    ;
EXCEPTION
   WHEN OTHERS THEN
      x_period_type      := NULL ;
      x_period_set_name  := NULL ;
      x_period_year      := NULL ;
      x_quarter          := NULL ;
      x_period_num       := NULL ;
      x_run_period_end_date  := NULL ;
      RAISE ;
END get_fiscalyear_quarter ;
-- ==========================================================================
-- PROCEDURE :  populate_RLM_table
--   Purpose   :  Build the included  resource list members and resource percent of a given
--              resource list.
--  Rules: 1.If no members are defines for the RL,then all the defined RLMs are considered.
--         2. If  RLMS are defined, the table is populated with all the  included RLMs.
--         3. If a  RLM is a resource group, its child RLMs are placed in the array
--            after checking for exclusion.
-- Created :   28-JUL-98   Sesivara
-- ==========================================================================
/* removed the plsql table as output from this procedure */
PROCEDURE populate_RLM_table( p_rule_id           IN  NUMBER,
                              p_run_id            IN  NUMBER, /* for bug 2211234 */
                              p_type              IN  VARCHAR2,
                              p_resource_list_id  IN  NUMBER ,
							  /* FP.M : Allocation Impact Bug # 3512552 */
							  p_resource_struct_type in Varchar2 ,
							  p_rbs_version_id	  In Number ,
							  p_basis_category    In Varchar2 /* Added to consider if it is 'A' then only leaf nodes should be considered for basis %. Else all nodes */
							)
IS
   v_rl_id              NUMBER ;
   v_rlm_id             NUMBER ;
   v_chd_rlm_id			NUMBER ;
   v_rlm_exists         VARCHAR2(1) := 'N' ;
   v_counter            BINARY_INTEGER  ;
   v_incld_exists       VARCHAR2(1) := 'N' ; /*2564418 Flagged if an include
   							is specified*/
   v_excld_exists       VARCHAR2(1) := 'N' ; /*2564418 Flagged if an exclude
   							is specified*/
   v_child_resource_excl_id pa_plsql_datatypes.IdTabTyp; /* 3567201 : Exclusion Of Childs when Parent Resource Is Excluded. */
   v_child_resource_excl_id_temp pa_plsql_datatypes.IdTabTyp; /* 3567201 : Exclusion Of Childs when Parent Resource Is Excluded. */
   v_cnt Number := 0;
-- Cursor to get all the Resource list members of a rule
   Cursor C_RLM is
	Select * From
		(
          Select  par.resource_list_member_id ,
                  par.exclude_flag            ,
                  nvl(pbr.parent_member_id,0) parent_member_id,
                  par.resource_percentage
            from  pa_resource_list_members pbr,
            /**   pa_budget_resources_v pbr,    ** bug 2661889 */
                  pa_alloc_resources par
           where  par.rule_id = p_rule_id
             and  par.member_type = p_type
             and  pbr.resource_list_member_id = par.resource_list_member_id
			 and  display_flag = 'Y'  /* FP.M : Allocation Impact Bug # 3512552 */
			 and  enabled_flag = 'Y'  /* FP.M : Allocation Impact Bug # 3512552 */
			 and  nvl(pbr.migration_code , 'M') = 'M'
			 and  p_resource_struct_type = 'RL'
		Union All
		/* FP.M : Allocation Impact Bug # 3512552 */
		 Select  par.resource_list_member_id					  ,
 				 par.exclude_flag							      ,
				 nvl(prbs.parent_element_id , 0) parent_member_id ,
				 par.resource_percentage
		   From  pa_rbs_elements prbs,
		 	     pa_alloc_resources par
		  Where  par.rule_id = p_rule_id
		    and  prbs.user_created_flag = 'N' /* To show only those elements created after summarization process */
		    and  par.member_type = p_type
		    and  prbs.rbs_version_id = p_rbs_version_id
		    and  prbs.rbs_element_id = par.resource_list_member_id
			and  p_resource_struct_type = 'RBS'
		)
	order by  exclude_flag, parent_member_id, resource_list_member_id ;
-- Cursor to all defined resource list members of a resource list
/******************    Bug 3149853 Starts   ****************************
 * Modified Cursor query for performance improvement.
 *  --2564418. Added the second condition in the where clause below
 *     cursor C_RL_RLM is
 *        Select resource_list_member_id
 *          from  pa_resource_list_members
 *		-- pa_budget_resources_v     -- bug 2661889
 *         where resource_list_id     = p_resource_list_id
 *		-- 2564418 changes start
 *            AND resource_list_member_id NOT IN
 *                              (select resource_list_member_id
 *                               from pa_alloc_resources
 *                               where exclude_flag='Y'
 *                                AND rule_id = p_rule_id);
 *		-- 2564418 changes end.
******************  End of comment  *****************************/
	 Cursor C_RL_RLM_ALL is /* Cursor Created for performnace : Derived from C_RL_RLM and removed the exists call.
							   This cursor will be used When no include and no exclude is defined. */
        Select  prlm.resource_list_member_id
          From  pa_resource_list_members prlm
         Where  prlm.resource_list_id    = p_resource_list_id
		   And  display_flag = 'Y'  /* FP.M : Allocation Impact Bug # 3512552 */
		   And  enabled_flag = 'Y'  /* FP.M : Allocation Impact Bug # 3512552 */
		   And  nvl(prlm.migration_code , 'M') = 'M';
	Cursor C_RL_RLM_RBS_ALL_ACT is /* Cursor Created for performnace : Derived from C_RL_RLM and removed the exists call.
									  This cursor will be used When no include and no exclude is defined.
									  This cursor is used only in source and basis ( if the basis_category is actuals )
								   */
        Select prbs.rbs_element_id
		  From pa_rbs_elements prbs
		 Where prbs.rbs_version_id = p_rbs_version_id
		   and prbs.user_created_flag = 'N' /* To show only those elements created after summarization process */
		   and prbs.resource_type_id <> -1 /* To remove first record of Version Info*/
		   and Not Exists (Select '1'
		                    From pa_rbs_elements rbs_chd
						   Where rbs_chd.rbs_version_id = p_rbs_version_id
						     and rbs_chd.user_created_flag = 'N' /* To show only those elements created after summarization process */
						     And rbs_chd.parent_element_id = prbs.rbs_element_id
						  ); /* To select only Leaf nodes in case of Actuals */
	Cursor C_RL_RLM_RBS_ALL_NON_ACT is /* Cursor Created for performnace : Derived from C_RL_RLM and removed the exists call.
										   This cursor will be used When no include and no exclude is defined.
										   This cursor is used only in basis and basis category is not actuals. Only
										   If the basis Category is Finplan or Budgets
										   */
        Select prbs.rbs_element_id
		  From pa_rbs_elements prbs
		 Where prbs.rbs_version_id = p_rbs_version_id
		   and prbs.user_created_flag = 'N' /* To show only those elements created after summarization process */
		   and prbs.resource_type_id <> -1 ; /* To remove first record of Version Info*/
									  	     /* In this case, data can be there for intermediate nodes also. So to insert all the records */
	 Cursor C_RL_RLM is
        Select  prlm.resource_list_member_id
          from  pa_resource_list_members prlm
         where  prlm.resource_list_id    = p_resource_list_id
		   And  display_flag = 'Y'  /* FP.M : Allocation Impact Bug # 3512552 */
		   And  enabled_flag = 'Y'  /* FP.M : Allocation Impact Bug # 3512552 */
		   And  nvl(prlm.migration_code , 'M') = 'M'
           AND  NOT exists
                (select par.resource_list_member_id
                 from pa_alloc_resources par
                 where par.exclude_flag = 'Y'
				 And par.member_type = p_type /* Bug 3819804 */
                 AND par.rule_id = p_rule_id
                 and prlm.resource_list_member_id = par.resource_list_member_id
				)
		   AND p_resource_struct_type = 'RL';
   /* FP.M : Allocation Impact Bug # 3512552 */
	Cursor C_RL_RLM_RBS_ACT is
        Select prbs.rbs_element_id
		  From pa_rbs_elements prbs
		 Where prbs.rbs_version_id = p_rbs_version_id
		   and prbs.user_created_flag = 'N' /* To show only those elements created after summarization process */
		   and NOT exists
                (Select par.resource_list_member_id
                   From pa_alloc_resources par
                  Where par.exclude_flag = 'Y'
				    And par.member_type = p_type /* Bug 3819804 */
                    AND par.rule_id = p_rule_id
                    AND prbs.rbs_element_id = par.resource_list_member_id
				)
		   and Not Exists ( Select '1'
		                      From pa_rbs_elements chd_prbs
							 where chd_prbs.rbs_version_id    = p_rbs_Version_id
							   and chd_prbs.user_created_flag = 'N' /* To show only those elements created after summarization process */
							   And chd_prbs.parent_element_id = prbs.rbs_element_id
						  ) /* To fetch only leaf nodes */
           and p_resource_struct_type = 'RBS';
	Cursor C_RL_RLM_RBS_NON_ACT is
        Select prbs.rbs_element_id
		  From pa_rbs_elements prbs
		 Where prbs.rbs_version_id = p_rbs_version_id
   		   and prbs.user_created_flag = 'N' /* To show only those elements created after summarization process */
		   and NOT exists
                (Select par.resource_list_member_id
                   From pa_alloc_resources par
                  Where par.exclude_flag = 'Y'
				    And par.member_type = p_type /* Bug 3819804 */
                    AND par.rule_id = p_rule_id
                    AND prbs.rbs_element_id = par.resource_list_member_id
				)
           and p_resource_struct_type = 'RBS';
   resource_list_member_tab pa_plsql_datatypes.IdTabTyp;
/******************    Bug 3149853 Ends   ***************************/
-- Cursor to all defined resource list members of a resource group
   Cursor C_RG_RLM is
         Select resource_list_member_id
           from  pa_resource_list_members
           /**   pa_budget_resources_v  ** bug 2661889 */
          where nvl(parent_member_id,0) = v_rlm_id
            and  resource_list_id     = p_resource_list_id
			and  display_flag = 'Y'  /* FP.M : Allocation Impact Bug # 3512552 */
			and  enabled_flag = 'Y'  /* FP.M : Allocation Impact Bug # 3512552 */
			And  nvl(migration_code , 'M') = 'M'
            and  p_resource_struct_type = 'RL';
	/* FP.M : Allocation Impact Bug # 3512552 */
   Cursor C_RG_RLM_RBS_ACT Is
		Select Rbs_Element_Id  resource_list_member_id
		  From pa_rbs_elements prbs
		 Where Rbs_Version_Id = p_rbs_version_id
		   and prbs.user_created_flag = 'N' /* To show only those elements created after summarization process */
		   AND p_resource_struct_type = 'RBS'
		   AND Not Exists (
							Select '1'
							  From pa_rbs_elements chd_prbs
							 Where chd_prbs.rbs_version_id = p_rbs_version_id
							   and chd_prbs.user_created_flag = 'N' /* To show only those elements created after summarization process */
							   and chd_prbs.parent_element_id = prbs.rbs_element_id
						   )
		  Start with Rbs_Element_Id = v_rlm_id
		Connect By Prior rbs_element_id = parent_element_id;
     Cursor C_RG_RLM_RBS_NON_ACT Is
		Select Rbs_Element_Id  resource_list_member_id
		  From pa_rbs_elements prbs
		 Where Rbs_Version_Id = p_rbs_version_id
		   and prbs.user_created_flag = 'N' /* To show only those elements created after summarization process */
		   AND p_resource_struct_type = 'RBS'
		  Start with Rbs_Element_Id = v_rlm_id
		Connect By Prior rbs_element_id = parent_element_id;
  /* FP.M : Allocation Impact Bug # 3512552
     Bug # 3567201 : Child Exlcusion When Parent Exlcluded
  */
   Cursor C_Exc_RLM Is
		 Select Resource_List_Member_Id
		   From pa_alloc_resources
		  Where Rule_Id = P_Rule_Id
		    And Member_Type = P_type
			And Exclude_Flag = 'Y';
  /* FP.M : Allocation Impact Bug # 3512552
     Bug # 3567201 : Child Exlcusion When Parent Exlcluded
  */
Function check_rlm_excluded( p_rule_id IN NUMBER  ,
                             p_type    IN VARCHAR2,
                             p_rlm_id  IN NUMBER  ) RETURN VARCHAR2
IS
    v_rlm_excluded  VARCHAR2(1) ;
    cursor c_rlm_excluded is
       Select  'Y'
         from  pa_alloc_resources
        where  rule_id  = p_rule_id
          and  member_type = p_type
          and  resource_list_member_id = p_rlm_id
          and  exclude_flag = 'Y'  ;
BEGIN
       v_rlm_excluded := 1 ;
       OPEN c_rlm_excluded ;
       FETCH c_rlm_excluded INTO v_rlm_excluded ;
       If c_rlm_excluded%NOTFOUND then
          v_rlm_excluded :='N';
       End If ;
       CLOSE c_rlm_excluded ;
       return ( v_rlm_excluded) ;
EXCEPTION
       WHEN OTHERS THEN
          RAISE ;
END Check_rlm_excluded ;
Function check_rlm_exists( p_rule_id IN NUMBER,
                           p_type    IN VARCHAR2  ) RETURN VARCHAR2
IS
	v_rlm_exists  VARCHAR2(1);
    cursor c_rlm_exists is
       select 'Y'
         from  pa_alloc_resources
        where  rule_id  = p_rule_id
          and  member_type = p_type  ;
BEGIN
	   v_rlm_exists  := 'N' ;
       OPEN c_rlm_exists ;
       FETCH c_rlm_exists INTO v_rlm_exists ;
       If c_rlm_exists%NOTFOUND then
          v_rlm_exists :='N';
       End If ;
       CLOSE c_rlm_exists ;
       return ( v_rlm_exists) ;
EXCEPTION
       WHEN OTHERS then
          RAISE ;
END Check_Rlm_Exists ;
Function check_child_rlm_exists( p_rlm_id IN NUMBER ) RETURN VARCHAR2
IS
       v_rlm_exists  VARCHAR2(1) ;
       cursor c_child_rlm is
           select 'Y'
           from  pa_resource_list_members
           /**   pa_budget_resources_v     ** bug 2661889 */
            where  nvl(parent_member_id,0)  = p_rlm_id
			  and  display_flag = 'Y'  /* FP.M : Allocation Impact Bug # 3512552 */
			  and  enabled_flag = 'Y'  /* FP.M : Allocation Impact Bug # 3512552 */
			  And  nvl(migration_code , 'M') = 'M';
	/* FP.M : Allocation Impact : Bug # 3512552 */
	   cursor c_child_rbs_rlm Is
	     Select 'Y'
		   From pa_rbs_elements
		  Where rbs_version_id = p_rbs_version_id
		    and user_created_flag = 'N' /* To show only those elements created after summarization process */
		    And Nvl(parent_element_id,0) = p_rlm_id
			And RowNum = 1;
BEGIN
      v_rlm_exists := 'N' ;
	  If nvl(p_resource_struct_type,'RL') = 'RL' then
		  OPEN c_child_rlm ;
		  FETCH c_child_rlm INTO v_rlm_exists ;
	      If c_child_rlm%NOTFOUND then
		      v_rlm_exists :='N';
	      End If ;
		  CLOSE c_child_rlm ;
	  Else
		  OPEN c_child_rbs_rlm ;
		  FETCH c_child_rbs_rlm INTO v_rlm_exists ;
	      If c_child_rbs_rlm%NOTFOUND then
		      v_rlm_exists :='N';
	      End If ;
		  CLOSE c_child_rbs_rlm ;
	  End If;
	  Return ( v_rlm_exists) ;
EXCEPTION
       WHEN OTHERS THEN
          RAISE ;
END Check_child_rlm_exists;
/* added for 2211234 */
Procedure insert_alloc_run_resources(p_run_id IN NUMBER,
                                     p_rule_id IN NUMBER,
                                     p_member_type IN VARCHAR2,
                                     p_res_list_member_id IN NUMBER,
                                     p_resource_percent  IN NUMBER)
IS
BEGIN
     insert into pa_alloc_run_resource_det (
            rule_id,
            run_id,
            member_type,
            resource_list_member_id,
            resource_percent,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login)
     values(p_rule_id,
            p_run_id,
            p_member_type,
            p_res_list_member_id ,
            p_resource_percent,
            G_creation_date,
            G_created_by,
            G_last_update_date,
            G_last_updated_by,
            G_last_update_login) ;
EXCEPTION
     WHEN OTHERS THEN
     RAISE;
END;
 -- Bug3149853 .Changes done to enhance performance .
 -- Created procedure to perform BULK INSERT into pa_alloc_run_resource_det.
Procedure bulk_ins_alloc_run_res(p_run_id 			IN NUMBER,
				  p_rule_id 			IN NUMBER,
				  p_member_type 		IN VARCHAR2,
				  p_res_list_member_id_tab	IN pa_plsql_datatypes.IdTabTyp,
				  p_resource_percent  		IN NUMBER)
IS
BEGIN
        FORALL i IN p_res_list_member_id_tab.first..p_res_list_member_id_tab.last
        insert into pa_alloc_run_resource_det (
                    rule_id,
                    run_id,
                    member_type,
                    resource_list_member_id,
                    resource_percent,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    last_update_login)
             values(p_rule_id,
                    p_run_id,
                    p_type,
                    resource_list_member_tab(i),
                    100,
                    G_creation_date,
                    G_created_by,
                    G_last_update_date,
                    G_last_updated_by,
                    G_last_update_login) ;
EXCEPTION
     WHEN OTHERS THEN
     RAISE;
END;
/*
  Created By : Vthakkar
  Created Date : 26-Apr-2004
  Desc : to store all the excluded resources of Resource List or RBS in Allocation Rule for Basis or Source.
*/
procedure fetch_all_excludes
Is
Begin
	------------------------------------------------------------------
	---- Filling All Excludes And All its childs to The PLSQL table ----
	IF P_DEBUG_MODE = 'Y' THEN
		pa_debug.write_file('fetch_all_excludes: ' ||  'LOG',' Inside fetch_all_excludes');
	END IF;
	v_cnt := 0;
	v_child_resource_excl_id.delete;
	If Nvl(p_resource_struct_type,'RL') = 'RL' Then
			IF P_DEBUG_MODE = 'Y' THEN
				pa_debug.write_file('fetch_all_excludes: ' ||  'LOG',' In case of RL');
			END IF;
			Declare
				Cursor C_Exc_Chd_Rlm (V_parent_rlm in Number)
				Is
				  Select resource_list_member_id
				    From pa_resource_list_members
				   Where Resource_List_Id = p_resource_list_Id
				     And Parent_member_Id = v_parent_rlm
					 And display_flag = 'Y'  /* FP.M : Allocation Impact Bug # 3512552 */
		 			 And enabled_flag = 'Y'  /* FP.M : Allocation Impact Bug # 3512552 */
					 And nvl(migration_code , 'M') = 'M'
					 And p_resource_struct_type = 'RL';
			Begin
				Open C_Exc_RLM;
				Loop
					IF P_DEBUG_MODE = 'Y' THEN
						pa_debug.write_file('fetch_all_excludes: ' ||  'LOG',' In case of RL 1 ');
					END IF;
					Resource_List_Member_tab.Delete;
					Fetch C_Exc_RLM Bulk Collect Into Resource_List_Member_tab Limit 500;
					If Not Resource_List_Member_Tab.Exists(1) Then
						Exit;
					End If;
					For k in 1..Resource_List_Member_tab.count
					Loop
						Open  C_Exc_Chd_Rlm(Resource_List_Member_tab(k));
						IF P_DEBUG_MODE = 'Y' THEN
							pa_debug.write_file('fetch_all_excludes: ' ||  'LOG',' RL : Child Member ' || Resource_List_Member_tab(k) );
						END IF;
						Loop
							v_child_resource_excl_id_temp.Delete;
							Fetch C_Exc_Chd_Rlm Bulk Collect
							 Into v_child_resource_excl_id_temp
							Limit 500;
							If Not v_child_resource_excl_id_temp.Exists(1) Then
								Exit;
							End If;
							For i in 1..v_child_resource_excl_id_temp.count
							Loop
								v_cnt := v_cnt + 1;
								v_child_resource_excl_id (v_cnt) := v_child_resource_excl_id_temp(i);
							End Loop;
						  End Loop;
						/* Include The Node Itself also */
						v_cnt := v_cnt + 1;
						v_child_resource_excl_id (v_cnt) := Resource_List_Member_tab(k);
						Close C_Exc_Chd_Rlm;
					 End Loop;
				End Loop;
				Close C_Exc_RLM;
			 End;
	ElsIf Nvl(p_resource_struct_type,'RL') = 'RBS' Then
			IF P_DEBUG_MODE = 'Y' THEN
				pa_debug.write_file('fetch_all_excludes: ' ||  'LOG',' In case of RBS');
			END IF;
			Declare
				Cursor C_Exc_Chd_Rlm_RBS (V_parent_rlm in Number)
				    Is
				  Select Rbs_Element_Id  resource_list_member_id
					From pa_rbs_elements
				   Where Rbs_Version_Id = p_rbs_version_id
				     and user_created_flag = 'N' /* To show only those elements created after summarization process */
					 And p_resource_struct_type = 'RBS'
				   Start With Parent_element_Id = V_parent_Rlm
				  Connect By Prior Rbs_Element_Id = Parent_Element_Id;
			Begin
				Open C_Exc_RLM;
				Loop
					IF P_DEBUG_MODE = 'Y' THEN
						pa_debug.write_file('fetch_all_excludes: ' ||  'LOG',' In case of RBS 1 ');
					END IF;
					Resource_List_Member_tab.Delete;
					Fetch C_Exc_RLM Bulk Collect Into Resource_List_Member_tab Limit 500;
					If Not Resource_List_Member_Tab.Exists(1) Then
						Exit;
					End If;
					For k in 1..Resource_List_Member_tab.count
					Loop
						Open  C_Exc_Chd_Rlm_RBS(Resource_List_Member_tab(k));
						IF P_DEBUG_MODE = 'Y' THEN
							pa_debug.write_file('fetch_all_excludes: ' ||  'LOG',' RBS : Child Member ' || Resource_List_Member_tab(k) );
						END IF;
						Loop
							v_child_resource_excl_id_temp.Delete;
							Fetch C_Exc_Chd_Rlm_RBS Bulk Collect
							 Into v_child_resource_excl_id_temp
							Limit 500;
							If Not v_child_resource_excl_id_temp.Exists(1) Then
								Exit;
							End If;
							For i in 1..v_child_resource_excl_id_temp.count
							Loop
								v_cnt := v_cnt + 1;
								v_child_resource_excl_id (v_cnt) := v_child_resource_excl_id_temp(i);
							End Loop;
						 End Loop;
						 /* Include The Node Itself also */
						v_cnt := v_cnt + 1;
						v_child_resource_excl_id (v_cnt) := Resource_List_Member_tab(k);
						Close C_Exc_Chd_Rlm_RBS;
					 End Loop;
				End Loop;
				Close C_Exc_RLM;
			End;
	End If;
	------------------------------------------------------------------
EXCEPTION
       WHEN OTHERS then
          RAISE ;
End fetch_all_excludes;
/*
  Created By : Vthakkar
  Created Date : 26-Apr-2004
  Desc : to validate a resource list member whether it's included or excluded.
*/
Function Is_Excluded_Rlm (v_rlm_id in Number) return Boolean
Is
	l_ret_flag Boolean := False;
Begin
	For i in 1..v_child_resource_excl_id.count
		Loop
			If v_child_resource_excl_id(i) = v_rlm_Id Then
				l_ret_flag := True;
				Return l_ret_flag;
			End If;
		End Loop;
	Return l_ret_flag;
EXCEPTION
       WHEN OTHERS then
		Return l_ret_flag;
End Is_Excluded_Rlm;
BEGIN
v_counter := 1 ;
IF P_DEBUG_MODE = 'Y' THEN
	pa_debug.write_file('populate_RLM_table: ' ||  'LOG','Inside populate_RLM');
END IF;/*2564418*/
IF check_rlm_exists(p_rule_id, p_type) = 'N' then
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('populate_RLM_table: ' || 'LOG','If check_rlm_exists is N');
    END IF;/*2564418*/
--   populate inc_rlm_tbl using pa_budget_resources_v for
--   given alloc_rule.alloc_resource_list ;
/***********************   Bug 3149853 starts  *****************************
    For RL_RLM_REC in C_RL_RLM LOOP
    --  commented for 2211234
    --  x_inc_rlm_tbl(v_counter).resource_list_member_id := RL_RLM_REC.resource_list_member_id ;
    --  x_inc_rlm_tbl(v_counter).resource_percent := 100 ;
    --  v_counter := v_counter + 1 ;
        insert_alloc_run_resources(p_run_id             => p_run_id
                                  ,p_rule_id            => p_rule_id
                                  ,p_member_type        => p_type
                                  ,p_res_list_member_id => RL_RLM_REC.resource_list_member_id
                                  ,p_resource_percent   => 100);
    END LOOP ;
********************   Commented for bug 3149853   ***********************/
	If NVL(p_resource_struct_type,'RL') = 'RL' Then
		Open C_RL_RLM_ALL;
	Elsif NVL(p_resource_struct_type,'RL') = 'RBS' Then
		If p_type = 'S' Then
			Open C_RL_RLM_RBS_ALL_ACT;
		Elsif P_type = 'B' Then
			If p_basis_category = 'A' Then
				Open C_RL_RLM_RBS_ALL_ACT;
			Else
				Open C_RL_RLM_RBS_ALL_NON_ACT;
			End If;
		End If;
	End IF;
    LOOP
		Resource_list_member_tab.delete;
		If NVL(p_resource_struct_type,'RL') = 'RL' Then
			Fetch C_RL_RLM_ALL BULK COLLECT INTO resource_list_member_tab LIMIT 500;
		ElsIf NVL(p_resource_struct_type,'RL') = 'RBS' Then
			If p_type = 'S' Then
				Fetch C_RL_RLM_RBS_ALL_ACT BULK COLLECT INTO resource_list_member_tab LIMIT 500;
			ElsIf p_type = 'B' Then
				If P_basis_category = 'A' Then
					Fetch C_RL_RLM_RBS_ALL_ACT BULK COLLECT INTO resource_list_member_tab LIMIT 500;
				Else
					Fetch C_RL_RLM_RBS_ALL_NON_ACT BULK COLLECT INTO resource_list_member_tab LIMIT 500;
				End If;
			End If;
		End If;
		If NOT resource_list_member_tab.exists(1) Then
                EXIT;
        End If;
        bulk_ins_alloc_run_res(     p_run_id             	 => p_run_id
                                  , p_rule_id            	 => p_rule_id
                                  , p_member_type        	 => p_type
                                  , p_res_list_member_id_tab => resource_list_member_tab
                                  , p_resource_percent   	 => 100
							   );
    END LOOP;
	If NVL(p_resource_struct_type,'RL') = 'RL' Then
	    CLOSE C_RL_RLM_ALL;
	ElsIf NVL(p_resource_struct_type,'RL') = 'RBS' Then
		If p_type = 'S' Then
			CLOSE C_RL_RLM_RBS_ALL_ACT;
		Elsif p_type = 'B' Then
			if P_basis_category = 'A' Then
				CLOSE C_RL_RLM_RBS_ALL_ACT;
			Else
				CLOSE C_RL_RLM_RBS_ALL_NON_ACT;
			End If;
		End If;
	End IF;
/***********************   Bug 3149853 ends  *****************************/
 Else
	Fetch_all_excludes; /* Added For 3567201 */
	IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('populate_RLM_table: ' || 'LOG','If some RLM exists....');
    END IF;/*2564418*/
	For RLM_REC in C_RLM LOOP
		v_rlm_id := RLM_REC.resource_list_member_id ;
		If RLM_REC.exclude_flag <> 'Y' then
		   IF P_DEBUG_MODE = 'Y' THEN
     	      pa_debug.write_file('populate_RLM_table: ' || 'LOG','Some include exists....');
     	   END IF; /*2564418*/
		   v_incld_exists := 'Y'; /*2564418 Hence some include is specified*/
		   If (
				 (
				    nvl(RLM_REC.parent_member_id,0) = 0
		         AND check_child_rlm_exists(v_rlm_id) = 'Y'
				 AND NVL(p_resource_struct_type,'RL') = 'RL'
				 )
				 OR
				 (
					NVL(p_resource_struct_type,'RL') = 'RBS'
				 AND check_child_rlm_exists(v_rlm_id) = 'Y'
				 )
			 ) then
			  IF P_DEBUG_MODE = 'Y' THEN
				   pa_debug.write_file('populate_RLM_table: ' || 'LOG','A RG is included specifically');
			  END IF;/*2564418*/
			  If NVL(p_resource_struct_type,'RL') = 'RL' Then
				Open C_RG_RLM;
			  Elsif NVL(p_resource_struct_type,'RL') = 'RBS' Then
				If P_Type = 'S' Then
					Open C_RG_RLM_RBS_ACT;
				Elsif p_type = 'B' Then
					If p_basis_Category = 'A' Then
						Open C_RG_RLM_RBS_ACT;
					Else
						Open C_RG_RLM_RBS_NON_ACT;
					End If;
				End If;
			  End If;
			  Loop
				 If NVL(p_resource_struct_type,'RL') = 'RL' Then
					Fetch C_RG_RLM INTO v_chd_rlm_id ;
					If C_RG_RLM%NOTFOUND Then
						Exit;
					End If;
			     Else
					If p_type = 'S' Then
						Fetch C_RG_RLM_RBS_ACT INTO v_chd_rlm_id ;
						If C_RG_RLM_RBS_ACT%NOTFOUND Then
							Exit;
						End If;
					Elsif P_Type = 'B' Then
						If P_basis_category = 'A' Then
							Fetch C_RG_RLM_RBS_ACT INTO v_chd_rlm_id ;
							If C_RG_RLM_RBS_ACT%NOTFOUND Then
								Exit;
							End If;
						Else
							Fetch C_RG_RLM_RBS_NON_ACT INTO v_chd_rlm_id ;
							If C_RG_RLM_RBS_NON_ACT%NOTFOUND Then
								Exit;
							End If;
						End If;
					End If;
				 End If;
				 IF P_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('populate_RLM_table: ' || 'LOG','v_counter: '|| to_char(v_counter)||' RLM ID :' || to_char(v_rlm_id ));
                 END IF;
				 --- If check_rlm_excluded(p_rule_id, p_type, v_chd_rlm_id ) = 'N' then
				 /* Check is thru now from PLSQL tables For 3567201 */
				   /* commented for bug 2211234
                    x_inc_rlm_tbl(v_counter).resource_list_member_id := v_chd_rlm_id ;
                    x_inc_rlm_tbl(v_counter).resource_percent :=  nvl(v_chd_rlm_id,100) ;
                    v_counter := v_counter+1 ;
                   */
                   /* added for 2211234 */
					If Not Is_Excluded_Rlm (v_chd_rlm_id) Then /* Added For 3567201 */
						insert_alloc_run_resources(
						                           p_run_id             => p_run_id
												  ,p_rule_id            => p_rule_id
                                                  ,p_member_type        => p_type
                                                  ,p_res_list_member_id => v_chd_rlm_id
                                                  ,p_resource_percent   => nvl(RLM_REC.resource_percentage,100)
												  );
					End If;
                 ---- End if;
				END LOOP ;
				If NVL(p_resource_struct_type,'RL') = 'RL' Then
					Close C_RG_RLM;
			    Elsif NVL(p_resource_struct_type,'RL') = 'RBS' Then
				    If P_Type = 'S' Then
					    Close C_RG_RLM_RBS_ACT;
					Elsif P_type = 'B' Then
						If p_basis_category = 'A' Then
							Close C_RG_RLM_RBS_ACT;
						Else
							Close C_RG_RLM_RBS_NON_ACT;
						End If;
					End If;
			    End If;
-- Bug 914304: If Budget is at resource group level it is ignored for basis
-- Fix: Added the resource group into the RLM table if the p_type = 'B'
			   If p_type = 'B' And NVL(p_resource_struct_type,'RL') = 'RL' then
				 /* commented for 2211234
					x_inc_rlm_tbl(v_counter).resource_list_member_id :=  RLM_REC.resource_list_member_id ;
	                x_inc_rlm_tbl(v_counter).resource_percent := RLM_REC.resource_percentage ;
		            v_counter := v_counter+1 ;
			     */
				 /* added for 2211234 */
				 insert_alloc_run_resources(
										   p_run_id             => p_run_id
                                          ,p_rule_id            => p_rule_id
                                          ,p_member_type        => p_type
                                          ,p_res_list_member_id => RLM_REC.resource_list_member_id
                                          ,p_resource_percent   => RLM_REC.resource_percentage
										   );
              End if ;
		  Else
			  IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('populate_RLM_table: ' || 'LOG','v_counter : ' || to_char(v_counter) );
              END IF;
			  --- If check_rlm_excluded (p_rule_id, p_type, RLM_REC.resource_list_member_id) = 'N' then
			   /* Check is thru now from PLSQL tables For 3567201 */
				/* commented for bug 2211234
                 x_inc_rlm_tbl(v_counter).resource_list_member_id := RLM_REC.resource_list_member_id ;
                 x_inc_rlm_tbl(v_counter).resource_percent := nvl(RLM_REC.resource_percentage,100) ;
                 v_counter := v_counter+1 ;
                */
				/* added for 2211234 */
				If Not Is_Excluded_Rlm (RLM_REC.resource_list_member_id) Then /* Added For 3567201 */
					insert_alloc_run_resources(p_run_id             => p_run_id
                                          ,p_rule_id            => p_rule_id
                                          ,p_member_type        => p_type
                                          ,p_res_list_member_id => RLM_REC.resource_list_member_id
                                          ,p_resource_percent   => nvl(RLM_REC.resource_percentage,100));
				End If;
              --- End if ;
		   End if ;
	Else /* If the RLM is an exclude. 2564418 changes start here */
  	   IF P_DEBUG_MODE = 'Y' THEN
  	      pa_debug.write_file('populate_RLM_table: ' || 'LOG','If an exclude is specified...');
  	   END IF;
	   If (v_incld_exists = 'N') then /* no include has been specified */
		IF P_DEBUG_MODE = 'Y' THEN
		   pa_debug.write_file('populate_RLM_table: ' || 'LOG','No include has been specified...');
		END IF;
		/*include all RLM but this one */
/***********************   Bug 3149853 starts  *****************************
                For RL_RLM_REC in C_RL_RLM LOOP
                  if(v_excld_exists <> 'Y') then
                        IF P_DEBUG_MODE = 'Y' THEN
                           pa_debug.write_file('populate_RLM_table: ' || 'LOG','Inserting the other members-- '|| RLM_REC.resource_list_member_id);
                        END IF;
                        insert_alloc_run_resources(p_run_id     => p_run_id
												  ,p_rule_id            => p_rule_id
												  ,p_member_type        => p_type
                                                  ,p_res_list_member_id => RL_RLM_REC.resource_list_member_id
												  ,p_resource_percent   => nvl(RLM_REC.resource_percentage,100));
                  end if;
                END LOOP;
********************   Commented for bug 3149853   ***********************/
				if ( v_excld_exists <> 'Y') then	-- Added in version 115.69.40.3.
					If NVL(p_resource_struct_type,'RL') = 'RL' Then
						Open C_RL_RLM;
					Elsif NVL(p_resource_struct_type,'RL') = 'RBS' Then
						If p_Type = 'S' Then
							Open C_RL_RLM_RBS_ACT;
						ElsIf P_Type = 'B' Then
							If P_basis_category = 'A' Then
								Open C_RL_RLM_RBS_ACT;
							Else
								Open C_RL_RLM_RBS_NON_ACT;
							End If;
						End If;
					End IF;
					LOOP
						Resource_list_member_tab.delete;
						If NVL(p_resource_struct_type,'RL') = 'RL' Then
							Fetch C_RL_RLM BULK COLLECT INTO resource_list_member_tab LIMIT 500;
						ElsIf NVL(p_resource_struct_type,'RL') = 'RBS' Then
							If p_type = 'S' Then
								Fetch C_RL_RLM_RBS_ACT BULK COLLECT INTO resource_list_member_tab LIMIT 500;
							ElsIf P_TYpe = 'B' Then
								If P_basis_category = 'A' Then
									Fetch C_RL_RLM_RBS_ACT BULK COLLECT INTO resource_list_member_tab LIMIT 500;
								Else
									Fetch C_RL_RLM_RBS_NON_ACT BULK COLLECT INTO resource_list_member_tab LIMIT 500;
								End If;
							End If;
						End If;
						If NOT resource_list_member_tab.exists(1) Then
                           EXIT;
                        End If;
						FOR i IN resource_list_member_tab.first..resource_list_member_tab.last
						LOOP
							IF P_DEBUG_MODE = 'Y' THEN
								pa_debug.write_file('populate_RLM_table:'||'LOG','Inserting member-'|| resource_list_member_tab(i));
	                        END IF;
							If Not Is_Excluded_Rlm (resource_list_member_tab(i)) Then /* Added For 3567201 */
								insert_alloc_run_resources(p_run_id             => p_run_id
									                      ,p_rule_id            => p_rule_id
										                  ,p_member_type        => p_type
											              ,p_res_list_member_id => resource_list_member_tab(i)
												          ,p_resource_percent   => 100 /* nvl(RLM_REC.resource_percentage,100) */
														  /*
														    Bug 3741132 : When only excludes are defined. Then all other resources should
														    be considered with 100 percentage instead of exclude's percentage
														  */
														  );
							End If; /* Added For 3567201 */
                        END LOOP;
                      END LOOP;
					  If NVL(p_resource_struct_type,'RL') = 'RL' Then
					    CLOSE C_RL_RLM;
					  ElsIf NVL(p_resource_struct_type,'RL') = 'RBS' Then
						If P_Type = 'S' Then
							CLOSE C_RL_RLM_RBS_ACT;
						Elsif P_type = 'B' Then
							If p_basis_category = 'A' Then
								CLOSE C_RL_RLM_RBS_ACT;
							Else
								CLOSE C_RL_RLM_RBS_NON_ACT;
							End If;
						End If;
					  End IF;
				End if;		-- Added in version 115.69.40.3.
/***********************   Bug 3149853 ends  *****************************/
			v_excld_exists := 'Y';
	   /*
	    All the RLMs are arranged as includes first followed by excludes
		hence, once we see an exclude, we will not encounter any more
		includes. The above insert inserts all members which can be
		included. Hence there is no need to process further excludes.
		Hence, for every exclude except the first, we do not insert.
	   */
	   End if; /* v_incld_exists='N' 2564418 changes end here*/
        End if ;
     END LOOP ;
 End If ;
END populate_RLM_table ;
-- ==========================================================================
/* PROCEDURE :   get_amttype_start_date
   Purpose   :  To get the start date of the given amount type ( FYTD/QTD)
                based on a given period type( PA/GL)
     Created :   30-JUL-98   Sesivara
*/
-- ==========================================================================
PROCEDURE get_amttype_start_date( p_amt_type                  IN  VARCHAR2,
                                  p_period_type               IN  VARCHAR2 ,
                                  p_period_set_name           IN  VARCHAR2 ,
                                  p_run_period_end_date       IN  DATE,
                                  p_quarter_num               IN  NUMBER,
                                  p_period_year               IN  NUMBER,
                                  p_period                    IN  VARCHAR2 ,
                                  x_start_date                OUT NOCOPY DATE    )
IS
   v_quarter_num   NUMBER ;
   cursor c_amttype_start_date is
      select  min (start_date)
        from  gl_periods glp
       where  glp.period_set_name =  p_period_set_name
         and  glp.period_type     =  p_period_type
         and  glp.end_date       <=  p_run_period_end_date
         and  glp.period_year     =  p_period_year
         and  glp.quarter_num     =  nvl(v_quarter_num, glp.quarter_num);
   cursor c_period_start_date is
      select  start_date
        from  gl_periods glp
       where  glp.period_set_name =  p_period_set_name
         and  glp.period_type     =  p_period_type
         and  glp.period_name     =  p_period ;
BEGIN
    If p_amt_type in ('FYTD' ,'QTD' ) then
         IF p_amt_type = 'FYTD' then
            v_quarter_num := NULL ;
         ELSE
            v_quarter_num := p_quarter_num ;
         END IF ;
         OPEN  c_amttype_start_date ;
         FETCH c_amttype_start_date INTO x_start_date ;
         IF c_amttype_start_date%NOTFOUND THEN
           x_start_date := NULL ;
              alloc_errors(G_rule_id, G_alloc_run_id, 'R', 'E','PA_AL_NO_AMT_TYPE_START_DATE',TRUE) ;
         END IF ;
         CLOSE c_amttype_start_date ;
    elsif p_amt_type ='PTD' then
         OPEN c_period_start_date ;
         FETCH c_period_start_date into x_start_date ;
         IF c_period_start_date%NOTFOUND THEN
           x_start_date := NULL ;
           alloc_errors(G_rule_id, G_alloc_run_id, 'R', 'E','PA_AL_NO_AMT_TYPE_START_DATE',TRUE) ;
         END IF ;
    else
           x_start_date := NULL ;
    end if ;
EXCEPTION
      WHEN OTHERS THEN
      RAISE ;
END get_amttype_start_date  ;
-- ==========================================================================
/* PROCEDURE :  insert_alloc_basis_resource
   Purpose   :  To insert data into pa_alloc_run_basis_det table for each resource
                for each task which has some data available in summarization.
                Separate inserts are written for each type of amt_type
                (FYTD,qtd,itd and ptd).
   Created :    16-JAN-02   Manokuma
   Modified:	 24-JAN-03   Tarun   for bug 2757875
*/
-- ==========================================================================
PROCEDURE insert_alloc_basis_resource(
                            p_run_id          IN NUMBER,
                            p_rule_id         IN NUMBER,
                            p_resource_list_id IN NUMBER,
                            p_amt_type        IN VARCHAR2,
                            p_bal_type        IN VARCHAR2,
                            p_run_period_type IN VARCHAR2,
                            p_period          IN VARCHAR2,
                            p_run_period_end_date IN DATE ,
                            p_amttype_start_date  IN DATE ,
							/* FP.M : Allocation Impact */
							p_resource_struct_type in Varchar2,
							p_rbs_version_id In Varchar2
                            )
IS
     cursor c_projects is
     select distinct part.project_id project_id
       from pa_alloc_run_targets part,
            pa_resource_list_assignments prla
      where part.project_id = prla.project_id
        and prla.resource_list_id = p_resource_list_id
        and prla.resource_list_accumulated_flag = 'Y'
        and part.run_id = p_run_id
		and Nvl(p_resource_struct_type,'RL') = 'RL'
	Union All
	 select distinct part.project_id project_id
       from pa_alloc_run_targets part,
            pa_rbs_prj_assignments prpa
      where part.project_id = prpa.project_id
        and prpa.rbs_header_id = p_resource_list_id
		and prpa.rbs_version_id = p_rbs_version_id
        and part.run_id = p_run_id
		and Nvl(p_resource_struct_type,'RL') = 'RBS'
		;
/****cursor c_proj_start_date(p_proj_id IN NUMBER) is
     select start_date
       from pa_projects
      where project_id = p_proj_id;
     v_project_start_date  PA_PROJECTS.START_DATE%TYPE ; Commented for bug 2757875 ****/
     v_commit_count        NUMBER;
BEGIN
--    project and task amount are inserted based on the amount type (FTYD/QTD/PTD/ITD)
--    and run period and run period type
     pa_debug.G_err_stage:= 'INSIDE INSERT_ALLOC_BASIS_RESOURCE procedure';
     IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('insert_alloc_basis_resource: ' ||  'LOG', pa_debug.G_err_stage);
     END IF;
     If p_amt_type in ( 'FYTD', 'QTD') then
       pa_debug.G_err_stage:= 'inserting for FYTD or QTD';
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('insert_alloc_basis_resource: ' ||  'LOG', pa_debug.G_err_stage);
       END IF;
       v_commit_count := 0;
       FOR c_projects_rec in c_projects LOOP
	   IF P_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('insert_alloc_basis_resource: ' ||  'LOG', 'inserting data for project ' || c_projects_rec.project_id );
           END IF;
		   If Nvl(p_resource_struct_type,'RL') = 'RL' Then	-------------- {
				   INSERT INTO PA_ALLOC_RUN_BASIS_DET (
					  RUN_ID
					, RULE_ID
					, LINE_NUM
					, PROJECT_ID
					, TASK_ID
					, RESOURCE_LIST_MEMBER_ID
					, AMOUNT
					, LINE_PERCENT
					, CREATION_DATE
					, CREATED_BY
					, LAST_UPDATE_DATE
					, LAST_UPDATED_BY
					, LAST_UPDATE_LOGIN )
				   (  select /*+ ORDERED INDEX (prad, PA_RESOURCE_ACCUM_DETAILS_N2) */ --Bug Fix: 3634912 added hint
						part.run_id
						,part.rule_id
						,part.line_num
						,part.project_id
						,part.task_id
						,parr.resource_list_member_id
						,NVL(sum( decode (p_bal_type,
							'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
							'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
													 +nvl( pta.i_tot_billable_raw_cost,0),
							'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
													 +nvl( pta.i_tot_billable_burdened_cost,0),
							'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
													 +nvl(pta.i_tot_burdened_cost,0),
							'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
													 +nvl(pta.i_tot_labor_hours,0),
							'TOT_QUANTITY', nvl(pta.tot_quantity,0)
													 +nvl(pta.i_tot_quantity,0),
							0
						  )),0) AMOUNT
						,part.line_percent
						,G_creation_date
						,G_created_by
						,G_last_update_date
						,G_last_updated_by
						,G_last_update_login
					 from   ----Bug Fix: 3634912 :Changed the order of the tables
						pa_alloc_run_targets part,
						pa_alloc_run_resource_det parr,
						pa_resource_accum_details prad,
						pa_txn_accum  pta
					where   pta.txn_accum_id              = prad.txn_accum_id
					   and  prad.Resource_list_member_id  = parr.resource_list_member_id
					   and  prad.Project_id               = part.project_id
					   and  prad.task_id                  = part.task_id
					   and  part.run_id                   = p_run_id
					   and  parr.run_id                   = part.run_id
					   and  parr.member_type              = 'B'
					   and  part.project_id               = c_projects_rec.project_id
					   and  part.exclude_flag             = 'N'
					   and  exists
		 /* Using gl_period_statuses instead of pa_periods for Bug 2757875 */
					  (select /*+ NO_UNNEST */  -- Bug Fix: 3634912 added hint
						  gl.period_name
					   from   gl_period_statuses gl,
						  pa_implementations imp
					   where  pta.gl_period	    = gl.period_name
					   and    gl.set_of_books_id = imp.set_of_books_id
					   and    gl.application_id  = pa_period_process_pkg.application_id
					   and    gl.adjustment_period_flag = 'N'
					   and    gl.closing_status in ('C','F','O','P')
					   and    gl.end_date	between  p_amttype_start_date
								and      p_run_period_end_date)
		/****                     (select 1
					   from pa_periods pp
					  where  pta.pa_period        = pp.period_name
						and  pp.end_date between p_amttype_start_date
						and  p_run_period_end_date ) **** Commented for Bug 2757875 ****/
					 group by part.run_id
						,part.rule_id
						,part.line_num
						,part.project_id
						,part.task_id
						,parr.resource_list_member_id
						,part.line_percent
						,G_creation_date
						,G_created_by
						,G_last_update_date
						,G_last_updated_by
						,G_last_update_login);
			ElsIf Nvl(p_resource_struct_type,'RL') = 'RBS' Then
					 INSERT INTO PA_ALLOC_RUN_BASIS_DET (
						  RUN_ID
						, RULE_ID
						, LINE_NUM
						, PROJECT_ID
						, TASK_ID
						, RESOURCE_LIST_MEMBER_ID
						, AMOUNT
						, LINE_PERCENT
						, CREATION_DATE
						, CREATED_BY
						, LAST_UPDATE_DATE
						, LAST_UPDATED_BY
						, LAST_UPDATE_LOGIN )
					   (  select
					         part.run_id
						,part.rule_id
						,part.line_num
						,part.project_id
						,part.task_id
						,parr.resource_list_member_id
						,NVL(sum( decode (p_bal_type,
						'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
						'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
												 +nvl( pta.i_tot_billable_raw_cost,0),
						'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
												 +nvl( pta.i_tot_billable_burdened_cost,0),
						'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
												 +nvl(pta.i_tot_burdened_cost,0),
						'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
												 +nvl(pta.i_tot_labor_hours,0),
						'TOT_QUANTITY', nvl(pta.tot_quantity,0)
													 +nvl(pta.i_tot_quantity,0),
							0
						  )),0) AMOUNT
						,part.line_percent
						,G_creation_date
						,G_created_by
						,G_last_update_date
						,G_last_updated_by
						,G_last_update_login
					       from   pa_alloc_run_resource_det parr,
							pa_alloc_run_targets part,
							PA_ALLOC_TXN_ACCUM_RBS_V pta
						where   pta.Rbs_Element_Id		= parr.resource_list_member_id
						   and  pta.Project_id          = part.project_id
						   and  pta.task_id             = part.task_id
						   and  pta.RBS_STRUCT_VER_ID   = p_rbs_version_id
						   and  part.run_id             = p_run_id
						   and  parr.run_id             = part.run_id
						   and  parr.member_type        = 'B'
						   and  part.project_id         = c_projects_rec.project_id
						   and  part.exclude_flag       = 'N'
						   and  exists
		 					(   select gl.period_name
							      from gl_period_statuses gl,
									   pa_implementations imp
							     where pta.gl_period	    = gl.period_name
								   and gl.set_of_books_id = imp.set_of_books_id
								   and gl.application_id  = pa_period_process_pkg.application_id
								   and gl.adjustment_period_flag = 'N'
								   and gl.closing_status in ('C','F','O','P')
								   and gl.end_date between p_amttype_start_date
													   and p_run_period_end_date
							)
						 group by part.run_id
							,part.rule_id
							,part.line_num
							,part.project_id
							,part.task_id
							,parr.resource_list_member_id
							,part.line_percent
							,G_creation_date
							,G_created_by
							,G_last_update_date
							,G_last_updated_by
							,G_last_update_login);
			End If;		----------------- }
               v_commit_count := v_commit_count + sql%rowcount;
                IF v_commit_count > 5000 then
                   IF P_DEBUG_MODE = 'Y' THEN
                      pa_debug.write_file('insert_alloc_basis_resource: ' || 'LOG','commiting the changes after 5000 records');
                   END IF;
                   COMMIT;
                   v_commit_count := 0;
                END IF;
        END LOOP;
        COMMIT;
	 Elsif  p_amt_type = 'PTD' then
       pa_debug.G_err_stage:= 'inserting for PTD';
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('insert_alloc_basis_resource: ' ||  'LOG', pa_debug.G_err_stage);
       END IF;
	   v_commit_count := 0;
	   FOR c_projects_rec in c_projects LOOP
			   IF p_run_period_type = 'PA' THEN
                    IF P_DEBUG_MODE = 'Y' THEN
                       pa_debug.write_file('insert_alloc_basis_resource: ' ||  'LOG', 'inserting data for project ' || c_projects_rec.project_id);
                    END IF;
			If Nvl(p_resource_struct_type,'RL') = 'RL' Then		-------------{
					INSERT INTO PA_ALLOC_RUN_BASIS_DET  (
					   RUN_ID
					 , RULE_ID
					 , LINE_NUM
					 , PROJECT_ID
					 , TASK_ID
					 , RESOURCE_LIST_MEMBER_ID
					 , AMOUNT
					 , LINE_PERCENT
					 , CREATION_DATE
					 , CREATED_BY
					 , LAST_UPDATE_DATE
					 , LAST_UPDATED_BY
					 , LAST_UPDATE_LOGIN )
					(  select /*+ ORDERED INDEX (prad, PA_RESOURCE_ACCUM_DETAILS_N2) */  --Bug Fix: 3634912 added hint
					          part.run_id
						 ,part.rule_id
						 ,part.line_num
						 ,part.project_id
						 ,part.task_id
						 ,parr.resource_list_member_id
						 ,NVL(sum( decode (p_bal_type,
						 'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
						 'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
												 +nvl( pta.i_tot_billable_raw_cost,0),
						 'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
													  +nvl( pta.i_tot_billable_burdened_cost,0),
						 'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
											  +nvl(pta.i_tot_burdened_cost,0),
						 'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
											+nvl(pta.i_tot_labor_hours,0),
						 'TOT_QUANTITY', nvl(pta.tot_quantity,0)
										+nvl(pta.i_tot_quantity,0),
						  0)),0)AMOUNT
						 ,part.line_percent
						 ,G_creation_date
						 ,G_created_by
						 ,G_last_update_date
						 ,G_last_updated_by
						 ,G_last_update_login
					 from --Bug Fix: 3634912 : Changed the order of the tables.
		                                pa_alloc_run_targets part,
				                pa_alloc_run_resource_det parr,
						pa_resource_accum_details prad,
						pa_txn_accum  pta
					  where  pta.txn_accum_id              = prad.txn_accum_id
						and  prad.Resource_list_member_id  = parr.resource_list_member_id
						and  pta.Project_id                = part.project_id
						and  pta.task_id                   = part.task_id
						and  part.run_id                   = p_run_id
						and  parr.run_id                   = part.run_id
						and  parr.member_type              = 'B'
						and  part.project_id               = c_projects_rec.project_id
						and  part.exclude_flag             = 'N'
						and  pta.pa_period = p_period
					  group by part.run_id
						 ,part.rule_id
						 ,part.line_num
						 ,part.project_id
						 ,part.task_id
						 ,parr.resource_list_member_id
						 ,part.line_percent
						 ,G_creation_date
						 ,G_created_by
						 ,G_last_update_date
						 ,G_last_updated_by
						 ,G_last_update_login);
			ElsIf Nvl(p_resource_struct_type,'RL') = 'RBS' Then
					INSERT INTO PA_ALLOC_RUN_BASIS_DET  (
						   RUN_ID
						 , RULE_ID
						 , LINE_NUM
						 , PROJECT_ID
						 , TASK_ID
						 , RESOURCE_LIST_MEMBER_ID
						 , AMOUNT
						 , LINE_PERCENT
						 , CREATION_DATE
						 , CREATED_BY
						 , LAST_UPDATE_DATE
						 , LAST_UPDATED_BY
						 , LAST_UPDATE_LOGIN )
						(  select part.run_id
							 ,part.rule_id
							 ,part.line_num
							 ,part.project_id
							 ,part.task_id
							 ,parr.resource_list_member_id
							 ,NVL(sum( decode (p_bal_type,
							 'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
							 'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
													 +nvl( pta.i_tot_billable_raw_cost,0),
							 'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
														  +nvl( pta.i_tot_billable_burdened_cost,0),
							 'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
												  +nvl(pta.i_tot_burdened_cost,0),
							 'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
												+nvl(pta.i_tot_labor_hours,0),
							 'TOT_QUANTITY', nvl(pta.tot_quantity,0)
											+nvl(pta.i_tot_quantity,0),
							  0)),0)AMOUNT
							 ,part.line_percent
							 ,G_creation_date
							 ,G_created_by
							 ,G_last_update_date
							 ,G_last_updated_by
							 ,G_last_update_login
						 from    pa_alloc_run_resource_det parr,
							 pa_alloc_run_targets part,
							 PA_ALLOC_TXN_ACCUM_RBS_V  pta
						  where  pta.Rbs_Element_ID  = parr.resource_list_member_id
							and  pta.Project_id                = part.project_id
							and  pta.task_id                   = part.task_id
							and  pta.RBS_STRUCT_VER_ID		   = p_rbs_version_id
							and  part.run_id                   = p_run_id
							and  parr.run_id                   = part.run_id
							and  parr.member_type              = 'B'
							and  part.project_id               = c_projects_rec.project_id
							and  part.exclude_flag             = 'N'
							and  pta.pa_period = p_period
						  group by part.run_id
							 ,part.rule_id
							 ,part.line_num
							 ,part.project_id
							 ,part.task_id
							 ,parr.resource_list_member_id
							 ,part.line_percent
							 ,G_creation_date
							 ,G_created_by
							 ,G_last_update_date
							 ,G_last_updated_by
							 ,G_last_update_login);
			End If;		---------------- }
              ELSE /* p_run_period_type = 'GL' */
			If Nvl(p_resource_struct_type,'RL') = 'RL' Then		--------------{
					INSERT INTO PA_ALLOC_RUN_BASIS_DET  (
					   RUN_ID
					 , RULE_ID
					 , LINE_NUM
					 , PROJECT_ID
					 , TASK_ID
					 , RESOURCE_LIST_MEMBER_ID
					 , AMOUNT
					 , LINE_PERCENT
					 , CREATION_DATE
					 , CREATED_BY
					 , LAST_UPDATE_DATE
					 , LAST_UPDATED_BY
					 , LAST_UPDATE_LOGIN )
					(  select /*+ ORDERED INDEX (prad, PA_RESOURCE_ACCUM_DETAILS_N2) */  --Bug Fix: 3634912 added hint
					          part.run_id
						 ,part.rule_id
						 ,part.line_num
						 ,part.project_id
						 ,part.task_id
						 ,parr.resource_list_member_id
						 ,NVL(sum( decode (p_bal_type,
						 'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
						 'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
												 +nvl( pta.i_tot_billable_raw_cost,0),
						 'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
													  +nvl( pta.i_tot_billable_burdened_cost,0),
						 'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
											  +nvl(pta.i_tot_burdened_cost,0),
						 'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
											+nvl(pta.i_tot_labor_hours,0),
						 'TOT_QUANTITY', nvl(pta.tot_quantity,0)
										+nvl(pta.i_tot_quantity,0),
						  0)),0)AMOUNT
						 ,part.line_percent
						 ,G_creation_date
						 ,G_created_by
						 ,G_last_update_date
						 ,G_last_updated_by
						 ,G_last_update_login
				         from    --Bug Fix: 3634912 : Changed the order of tables
						 pa_alloc_run_targets part,
					         pa_alloc_run_resource_det parr,
						 pa_resource_accum_details prad,
						 pa_txn_accum  pta
					  where  pta.txn_accum_id              = prad.txn_accum_id
						and  prad.Resource_list_member_id  = parr.resource_list_member_id
						and  pta.Project_id                = part.project_id
						and  pta.task_id                   = part.task_id
						and  part.run_id                   = p_run_id
						and  parr.run_id                   = part.run_id
						and  parr.member_type              = 'B'
						and  part.project_id               = c_projects_rec.project_id
						and  part.exclude_flag             = 'N'
						and  pta.gl_period		   = p_period  /*Using gl_period on pta directly for bug 2757875 */
			/****                   and  pta.pa_period IN
							 (SELECT period_name
								FROM pa_periods pp
							   WHERE pp.gl_period_name = p_period) **** Commented for bug 2757875 ****/
					  group by part.run_id
						 ,part.rule_id
						 ,part.line_num
						 ,part.project_id
						 ,part.task_id
						 ,parr.resource_list_member_id
						 ,part.line_percent
						 ,G_creation_date
						 ,G_created_by
						 ,G_last_update_date
						 ,G_last_updated_by
						 ,G_last_update_login);
				ElsIf Nvl(p_resource_struct_type,'RL') = 'RBS' Then
					INSERT INTO PA_ALLOC_RUN_BASIS_DET  (
					   RUN_ID
					 , RULE_ID
					 , LINE_NUM
					 , PROJECT_ID
					 , TASK_ID
					 , RESOURCE_LIST_MEMBER_ID
					 , AMOUNT
					 , LINE_PERCENT
					 , CREATION_DATE
					 , CREATED_BY
					 , LAST_UPDATE_DATE
					 , LAST_UPDATED_BY
					 , LAST_UPDATE_LOGIN )
					(  select part.run_id
						 ,part.rule_id
						 ,part.line_num
						 ,part.project_id
						 ,part.task_id
						 ,parr.resource_list_member_id
						 ,NVL(sum( decode (p_bal_type,
						 'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
						 'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
												 +nvl( pta.i_tot_billable_raw_cost,0),
						 'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
												  +nvl( pta.i_tot_billable_burdened_cost,0),
						 'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
											  +nvl(pta.i_tot_burdened_cost,0),
						 'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
										+nvl(pta.i_tot_labor_hours,0),
						 'TOT_QUANTITY', nvl(pta.tot_quantity,0)
										+nvl(pta.i_tot_quantity,0),
						  0)),0)AMOUNT
						 ,part.line_percent
						 ,G_creation_date
						 ,G_created_by
						 ,G_last_update_date
						 ,G_last_updated_by
						 ,G_last_update_login
					 from    pa_alloc_run_resource_det parr,
						 pa_alloc_run_targets part,
						 PA_ALLOC_TXN_ACCUM_RBS_V  pta
					  where  pta.Rbs_Element_ID		  = parr.resource_list_member_id
						and  pta.Project_id                = part.project_id
						and  pta.task_id                   = part.task_id
						and  pta.RBS_STRUCT_VER_ID   = p_rbs_version_id
						and  part.run_id                   = p_run_id
						and  parr.run_id                   = part.run_id
						and  parr.member_type              = 'B'
						and  part.project_id               = c_projects_rec.project_id
						and  part.exclude_flag             = 'N'
						and  pta.gl_period				   = p_period
					  group by part.run_id
						 ,part.rule_id
						 ,part.line_num
						 ,part.project_id
						 ,part.task_id
						 ,parr.resource_list_member_id
						 ,part.line_percent
						 ,G_creation_date
						 ,G_created_by
						 ,G_last_update_date
						 ,G_last_updated_by
						 ,G_last_update_login);
			End If;		--------------- }
               END IF;
               v_commit_count := v_commit_count + sql%rowcount;
                IF v_commit_count > 5000 then
                   IF P_DEBUG_MODE = 'Y' THEN
                      pa_debug.write_file('insert_alloc_basis_resource: ' || 'LOG','commiting the changes after 5000 records');
                   END IF;
                   COMMIT;
                   v_commit_count := 0;
                END IF;
       END LOOP;
       COMMIT;
    Elsif p_amt_type = 'ITD' then
       pa_debug.G_err_stage:= 'inserting for ITD';
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('insert_alloc_basis_resource: ' ||  'LOG', pa_debug.G_err_stage);
       END IF;
       v_commit_count := 0;
       FOR c_projects_rec in c_projects LOOP
/****      OPEN C_proj_start_date(c_projects_rec.project_id) ;
           FETCH C_proj_start_date into v_project_start_date ;
           If C_proj_start_date%NOTFOUND  then
               v_project_start_date := NULL ;
           End if ;
           CLOSE C_proj_start_date ;
               IF v_project_start_date is NOT NULL then **** Commented for bug 2757875 ****/
               IF P_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('insert_alloc_basis_resource: ' ||  'LOG', 'inserting data for project ' || c_projects_rec.project_id);
               END IF;
		If Nvl(p_resource_struct_type,'RL') = 'RL' Then		---------------{
                       INSERT INTO PA_ALLOC_RUN_BASIS_DET (
                          RUN_ID
                        , RULE_ID
                        , LINE_NUM
                        , PROJECT_ID
                        , TASK_ID
                        , RESOURCE_LIST_MEMBER_ID
                        , AMOUNT
                        , LINE_PERCENT
                        , CREATION_DATE
                        , CREATED_BY
                        , LAST_UPDATE_DATE
                        , LAST_UPDATED_BY
                        , LAST_UPDATE_LOGIN )
                       (  select /*+ ORDERED INDEX (prad, PA_RESOURCE_ACCUM_DETAILS_N2) */ -- Bug Fix: 3634912 added hint
		                 part.run_id
                                ,part.rule_id
                                ,part.line_num
                                ,part.project_id
                                ,part.task_id
                                ,parr.resource_list_member_id
                                ,NVL(sum( decode (p_bal_type,
                                    'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
                                    'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
                                                             +nvl( pta.i_tot_billable_raw_cost,0),
                                    'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
                                                             +nvl( pta.i_tot_billable_burdened_cost,0),
                                    'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
                                                             +nvl(pta.i_tot_burdened_cost,0),
                                    'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
                                                             +nvl(pta.i_tot_labor_hours,0),
                                    'TOT_QUANTITY', nvl(pta.tot_quantity,0)
                                                             +nvl(pta.i_tot_quantity,0),
                                    0
                                  )),0) AMOUNT
                                ,part.line_percent
                                ,G_creation_date
                                ,G_created_by
                                ,G_last_update_date
                                ,G_last_updated_by
                                ,G_last_update_login
                        from    -- Bug Fix: 3634912 : Changed the order of tables.
                                pa_alloc_run_targets part,
				pa_alloc_run_resource_det parr,
                                pa_resource_accum_details prad,
                                pa_txn_accum  pta
                         where  pta.txn_accum_id              = prad.txn_accum_id
                           and  prad.Resource_list_member_id  = parr.resource_list_member_id
                           and  prad.Project_id               = part.project_id
                           and  prad.task_id                  = part.task_id
                           and  part.run_id                   = p_run_id
                           and  parr.run_id                   = part.run_id
                           and  parr.member_type              = 'B'
                           and  part.project_id               = c_projects_rec.project_id
                           and  part.exclude_flag             = 'N'
                           and  exists
                                (select  /*+ NO_UNNEST */  -- Bug Fix: 3634912 added hint
				       1
                                  from pa_periods pp
                                 where  pta.pa_period = pp.period_name
				   and  pp.end_date  <= p_run_period_end_date) /* Added for bug 2757875 */
			/****    and  pp.end_date   between v_project_start_date
						  and  p_run_period_end_date ) ****  Commented for bug 2757875 ****/
                         group by part.run_id
                                ,part.rule_id
                                ,part.line_num
                                ,part.project_id
                                ,part.task_id
                                ,parr.resource_list_member_id
                                ,part.line_percent
                                ,G_creation_date
                                ,G_created_by
                                ,G_last_update_date
                                ,G_last_updated_by
                                ,G_last_update_login);
		ElsIf Nvl(p_resource_struct_type,'RL') = 'RBS' Then
			INSERT INTO PA_ALLOC_RUN_BASIS_DET (
                          RUN_ID
                        , RULE_ID
                        , LINE_NUM
                        , PROJECT_ID
                        , TASK_ID
                        , RESOURCE_LIST_MEMBER_ID
                        , AMOUNT
                        , LINE_PERCENT
                        , CREATION_DATE
                        , CREATED_BY
                        , LAST_UPDATE_DATE
                        , LAST_UPDATED_BY
                        , LAST_UPDATE_LOGIN )
                       (  select part.run_id
                                ,part.rule_id
                                ,part.line_num
                                ,part.project_id
                                ,part.task_id
                                ,parr.resource_list_member_id
                                ,NVL(sum( decode (p_bal_type,
                                    'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
                                    'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
                                                             +nvl( pta.i_tot_billable_raw_cost,0),
                                    'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
                                                             +nvl( pta.i_tot_billable_burdened_cost,0),
                                    'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
                                                             +nvl(pta.i_tot_burdened_cost,0),
                                    'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
                                                             +nvl(pta.i_tot_labor_hours,0),
                                    'TOT_QUANTITY', nvl(pta.tot_quantity,0)
                                                             +nvl(pta.i_tot_quantity,0),
                                    0
                                  )),0) AMOUNT
                                ,part.line_percent
                                ,G_creation_date
                                ,G_created_by
                                ,G_last_update_date
                                ,G_last_updated_by
                                ,G_last_update_login
                        from    pa_alloc_run_resource_det parr,
                                pa_alloc_run_targets part,
                                PA_ALLOC_TXN_ACCUM_RBS_V  pta
                         where  pta.Rbs_Element_Id           = parr.resource_list_member_id
                           and  pta.Project_id                = part.project_id
                           and  pta.task_id                   = part.task_id
						   and  pta.RBS_STRUCT_VER_ID   = p_rbs_version_id
                           and  part.run_id                   = p_run_id
                           and  parr.run_id                   = part.run_id
                           and  parr.member_type              = 'B'
                           and  part.project_id               = c_projects_rec.project_id
                           and  part.exclude_flag             = 'N'
                           and  exists
                                (
				  select /*+ NO_UNNEST */  -- Bug Fix: 3634912 added hint
				        1
                                   from pa_periods pp
				  where pta.pa_period = pp.period_name
				    and pp.end_date  <= p_run_period_end_date
				 )
                         group by part.run_id
                                ,part.rule_id
                                ,part.line_num
                                ,part.project_id
                                ,part.task_id
                                ,parr.resource_list_member_id
                                ,part.line_percent
                                ,G_creation_date
                                ,G_created_by
                                ,G_last_update_date
                                ,G_last_updated_by
                                ,G_last_update_login);
		   End If;		--------------- }
					 v_commit_count := v_commit_count + sql%rowcount;
--             END IF;    **** Commetned for bug 2757875
               IF v_commit_count > 5000 then
                  IF P_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('insert_alloc_basis_resource: ' || 'LOG','commiting the changes after 5000 records');
                  END IF;
                  COMMIT;
                  v_commit_count := 0;
               END IF;
       END LOOP;
       COMMIT;
    End If ;
    pa_debug.G_err_stage:= 'exiting insert_alloc_basis_resource';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('insert_alloc_basis_resource: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
       RAISE ;
END insert_alloc_basis_resource;
-- ==========================================================================
/* PROCEDURE :  insert_alloc_source_resource
   Purpose   :  To insert data into pa_alloc_run_source_det table for each resource
                for each task which has some data available in summarization.
                Separate inserts are written for each type of amt_type
                (FYTD,qtd,itd and ptd).
   Created :    16-JAN-02   Manokuma
   Modified:	 24-JAN-03   Tarun    for bug 2757875
*/
-- ==========================================================================
PROCEDURE insert_alloc_source_resource(
                            p_run_id          IN NUMBER,
                            p_rule_id         IN NUMBER,
                            p_resource_list_id IN NUMBER,
                            p_amt_type        IN VARCHAR2,
                            p_bal_type        IN VARCHAR2,
                            p_run_period_type IN VARCHAR2,
                            p_period          IN VARCHAR2,
                            p_run_period_end_date IN DATE ,
                            p_amttype_start_date  IN DATE ,
							/* FP.M : Allocation Impact */
							p_resource_struct_type in Varchar2,
							p_rbs_version_id in Number
                            )
IS
     cursor c_projects is
     select distinct pars.project_id project_id
       from pa_alloc_run_sources pars,
            pa_resource_list_assignments prla
      where pars.project_id = prla.project_id
        and prla.resource_list_id = p_resource_list_id
        and prla.resource_list_accumulated_flag = 'Y'
        and pars.run_id = p_run_id
		and NVL(p_resource_struct_type,'RL') = 'RL'
	UNION All
	 select distinct pars.project_id project_id
       from pa_alloc_run_sources pars,
            pa_rbs_prj_assignments prpa
      where pars.project_id = prpa.project_id
        and prpa.rbs_header_id = p_resource_list_id
		and prpa.rbs_version_id = p_rbs_version_id
        and pars.run_id = p_run_id
		and NVL(p_resource_struct_type,'RL') = 'RBS'
		;
     /* Added for bug 3227783 */
     cursor c_get_rule_pool_percent is
        Select nvl(pool_percent,100)/100
        from   pa_alloc_rules_all
        where  rule_id = p_rule_id;
/****cursor c_proj_start_date(p_proj_id IN NUMBER) is
     select start_date
       from pa_projects
      where project_id = p_proj_id;
     v_project_start_date  PA_PROJECTS.START_DATE%TYPE ;
****  Commented for bug 2757875 ****/
     v_commit_count        NUMBER;
     v_rule_pool_percent   NUMBER;      /* Added for bug 3227783 */
BEGIN
--    project and task amount are inserted based on the amount type (FTYD/QTD/PTD/ITD)
--    and run period and run period type
     pa_debug.G_err_stage:= 'INSIDE INSERT_ALLOC_source_RESOURCE procedure';
     IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('insert_alloc_source_resource: ' ||  'LOG', pa_debug.G_err_stage);
     END IF;
     pa_debug.G_err_stage:= 'getting the pool_percent set for the rule.';
     IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('insert_alloc_source_resource: ' ||  'LOG', pa_debug.G_err_stage);
     END IF;
     /* Added for bug 3227783 */
     Open c_get_rule_pool_percent ;
     FETCH c_get_rule_pool_percent into v_rule_pool_percent;
     CLOSE c_get_rule_pool_percent;
     If p_amt_type in ( 'FYTD', 'QTD') then
	   pa_debug.G_err_stage:= 'inserting for FYTD or QTD';
	   IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('insert_alloc_source_resource: ' ||  'LOG', pa_debug.G_err_stage);
       END IF;
       v_commit_count := 0;
       FOR c_projects_rec in c_projects LOOP
	  IF P_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('insert_alloc_source_resource: ' ||  'LOG', 'inserting data for project ' || c_projects_rec.project_id );
          END IF;
	   IF Nvl(p_resource_struct_type,'RL') = 'RL' Then		-------------------{
			INSERT INTO PA_ALLOC_RUN_SOURCE_DET (
				  RUN_ID
				, RULE_ID
				, LINE_NUM
				, PROJECT_ID
				, TASK_ID
				, RESOURCE_LIST_MEMBER_ID
				, AMOUNT
				, ELIGIBLE_AMOUNT
				, RESOURCE_PERCENT
				, CREATION_DATE
				, CREATED_BY
				, LAST_UPDATE_DATE
				, LAST_UPDATED_BY
				, LAST_UPDATE_LOGIN )
				(  select /*+ ORDERED INDEX (prad, PA_RESOURCE_ACCUM_DETAILS_N2) */ --Bug Fix: 3634912 added hint
				         pars.run_id
					,pars.rule_id
					,pars.line_num
					,pars.project_id
					,pars.task_id
					,parr.resource_list_member_id
					,NVL(sum( decode (p_bal_type,
						'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) + nvl(pta.i_tot_raw_cost,0),
						'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
												 + nvl(pta.i_tot_billable_raw_cost,0),
						'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
												 + nvl(pta.i_tot_billable_burdened_cost,0),
						'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
												 + nvl(pta.i_tot_burdened_cost,0),
						'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
												 + nvl(pta.i_tot_labor_hours,0),
						'TOT_QUANTITY', nvl(pta.tot_quantity,0)
												 + nvl(pta.i_tot_quantity,0),
						0
					  )),0) AMOUNT
					, pa_currency.round_currency_amt(NVL(sum( decode (p_bal_type,	 --Bug 3590551:Introduced rounding
						'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
						'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
												 +nvl( pta.i_tot_billable_raw_cost,0),
						'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
												 +nvl( pta.i_tot_billable_burdened_cost,0),
						'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
												 +nvl(pta.i_tot_burdened_cost,0),
						'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
												 +nvl(pta.i_tot_labor_hours,0),
						'TOT_QUANTITY', nvl(pta.tot_quantity,0)
												 +nvl(pta.i_tot_quantity,0),
					   0
					  )),0)*(parr.resource_percent/100)*v_rule_pool_percent) ELIGIBLE_AMOUNT /* bug 3227783 */
					,parr.resource_percent
					,G_creation_date
					,G_created_by
					,G_last_update_date
					,G_last_updated_by
					,G_last_update_login
				 from   --Bug Fix: 3634912 : Changed the order of the tables.
					pa_alloc_run_sources pars,
					pa_alloc_run_resource_det parr,
					pa_resource_accum_details prad,
					pa_txn_accum  pta
				where   pta.txn_accum_id              = prad.txn_accum_id
				   and  prad.Resource_list_member_id  = parr.resource_list_member_id
				   and  prad.Project_id               = pars.project_id
				   and  prad.task_id                  = pars.task_id
				   and  pars.run_id                   = p_run_id
				   and  parr.run_id                   = pars.run_id
				   and  parr.member_type              = 'S'
				   and  pars.project_id               = c_projects_rec.project_id
				   and  pars.exclude_flag             = 'N'
				   and  exists
		/* Using gl_period_statuses instead of pa_periods for bug 2757875 */
				(select /*+ NO_UNNEST */  -- Bug Fix: 3634912 added hint
					gl.period_name
				   From gl_period_statuses gl,
					pa_implementations imp
				  where pta.gl_period		= gl.period_name
					and gl.set_of_books_id = imp.set_of_books_id
					and gl.application_id  = pa_period_process_pkg.application_id
					and gl.adjustment_period_flag = 'N'
					and gl.closing_status in ('C','F','O','P')
					and gl.end_date between p_amttype_start_date
					and p_run_period_end_date
					 )
		/*                      (select 1
					 from pa_periods pp
					 where pta.pa_period = pp.period_name
					 and  pp.end_date  between p_amttype_start_date
					 and p_run_period_end_date) **** 2757875 */
				 group by pars.run_id
					,pars.rule_id
					,pars.line_num
					,pars.project_id
					,pars.task_id
					,parr.resource_list_member_id
					,parr.resource_percent
					,G_creation_date
					,G_created_by
					,G_last_update_date
					,G_last_updated_by
					,G_last_update_login);
		ElsIf Nvl(p_resource_struct_type,'RL') = 'RBS' Then
				/* FP.M : Allocation Impact */
					INSERT INTO PA_ALLOC_RUN_SOURCE_DET (
						  RUN_ID
						, RULE_ID
						, LINE_NUM
						, PROJECT_ID
						, TASK_ID
						, RESOURCE_LIST_MEMBER_ID
						, AMOUNT
						, ELIGIBLE_AMOUNT
						, RESOURCE_PERCENT
						, CREATION_DATE
						, CREATED_BY
						, LAST_UPDATE_DATE
						, LAST_UPDATED_BY
						, LAST_UPDATE_LOGIN
						)
						(  select pars.run_id
							,pars.rule_id
							,pars.line_num
							,pars.project_id
							,pars.task_id
							,parr.resource_list_member_id
							,NVL(sum( decode (p_bal_type,
								'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) + nvl(pta.i_tot_raw_cost,0),
								'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
														 + nvl(pta.i_tot_billable_raw_cost,0),
								'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
														 + nvl(pta.i_tot_billable_burdened_cost,0),
								'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
														 + nvl(pta.i_tot_burdened_cost,0),
								'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
														 + nvl(pta.i_tot_labor_hours,0),
								'TOT_QUANTITY', nvl(pta.tot_quantity,0)
														 + nvl(pta.i_tot_quantity,0),
								0
							  )),0) AMOUNT
							,pa_currency.round_currency_amt(NVL(sum( decode (p_bal_type,   --Bug 3590551:Introduced rounding
								'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
								'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
														 +nvl( pta.i_tot_billable_raw_cost,0),
								'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
														 +nvl( pta.i_tot_billable_burdened_cost,0),
								'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
														 +nvl(pta.i_tot_burdened_cost,0),
								'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
														 +nvl(pta.i_tot_labor_hours,0),
								'TOT_QUANTITY', nvl(pta.tot_quantity,0)
														 +nvl(pta.i_tot_quantity,0),
								0
							  )),0)*(parr.resource_percent/100) * v_rule_pool_percent) ELIGIBLE_AMOUNT
							,parr.resource_percent
							,G_creation_date
							,G_created_by
							,G_last_update_date
							,G_last_updated_by
							,G_last_update_login
						 from   pa_alloc_run_resource_det parr,
							pa_alloc_run_sources pars,
							PA_ALLOC_TXN_ACCUM_RBS_V  pta
						where   pta.Rbs_Element_Id			  = parr.resource_list_member_id
						   and  pta.Project_id                = pars.project_id
						   and  pta.task_id                   = pars.task_id
						   and  pta.RBS_STRUCT_VER_ID   = p_rbs_version_id
						   and  pars.run_id                   = p_run_id
						   and  parr.run_id                   = pars.run_id
						   and  parr.member_type              = 'S'
						   and  pars.project_id               = C_projects_rec.project_id
						   and  pars.exclude_flag             = 'N'
						   and  Exists
								(select gl.period_name
								   From gl_period_statuses gl,
										pa_implementations imp
								  where pta.gl_period		= gl.period_name
									and gl.set_of_books_id	= imp.set_of_books_id
									and gl.application_id	= pa_period_process_pkg.application_id
									and gl.adjustment_period_flag = 'N'
									and	gl.closing_status in ('C','F','O','P')
									and gl.end_date between p_amttype_start_date
														and p_run_period_end_date
								)
						 group by pars.run_id
								,pars.rule_id
								,pars.line_num
								,pars.project_id
								,pars.task_id
								,parr.resource_list_member_id
								,parr.resource_percent
								,G_creation_date
								,G_created_by
								,G_last_update_date
								,G_last_updated_by
								,G_last_update_login);
			End If;		------------}
                v_commit_count := v_commit_count + sql%rowcount;
                IF v_commit_count > 5000 then
                   IF P_DEBUG_MODE = 'Y' THEN
                      pa_debug.write_file('insert_alloc_source_resource: ' || 'LOG','commiting the changes after 5000 records');
                   END IF;
                   COMMIT;
                   v_commit_count := 0;
                END IF;
        END LOOP;
        COMMIT;
     Elsif  p_amt_type = 'PTD' then
	   pa_debug.G_err_stage:= 'inserting for PTD';
        IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('insert_alloc_source_resource: ' ||  'LOG', pa_debug.G_err_stage);
        END IF;
          v_commit_count := 0;
	   FOR c_projects_rec in c_projects LOOP
	      IF p_run_period_type = 'PA' THEN
                    IF P_DEBUG_MODE = 'Y' THEN
                       pa_debug.write_file('insert_alloc_source_resource: ' ||  'LOG', 'inserting data for project ' || c_projects_rec.project_id);
                    END IF;
			IF Nvl(p_resource_struct_type,'RL') = 'RL' Then		------------{
					INSERT INTO PA_ALLOC_RUN_source_DET  (
					   RUN_ID
					 , RULE_ID
					 , LINE_NUM
					 , PROJECT_ID
					 , TASK_ID
					 , RESOURCE_LIST_MEMBER_ID
					 , AMOUNT
					 , ELIGIBLE_AMOUNT
					 , RESOURCE_PERCENT
					 , CREATION_DATE
					 , CREATED_BY
					 , LAST_UPDATE_DATE
					 , LAST_UPDATED_BY
					 , LAST_UPDATE_LOGIN )
				(  select /*+ ORDERED INDEX (prad, PA_RESOURCE_ACCUM_DETAILS_N2) */ -- Bug Fix: 3634912 added hint
					 pars.run_id
					,pars.rule_id
					,pars.line_num
					,pars.project_id
					,pars.task_id
					,parr.resource_list_member_id
					,NVL(sum( decode (p_bal_type,
						'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) + nvl( pta.i_tot_raw_cost,0),
						'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
												 +nvl( pta.i_tot_billable_raw_cost,0),
						'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
													  +nvl( pta.i_tot_billable_burdened_cost,0),
						'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
											  +nvl(pta.i_tot_burdened_cost,0),
						'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
											+nvl(pta.i_tot_labor_hours,0),
						'TOT_QUANTITY', nvl(pta.tot_quantity,0)
										+nvl(pta.i_tot_quantity,0),
						 0)),0)AMOUNT
					 ,pa_currency.round_currency_amt(NVL(sum( decode (p_bal_type,	 --Bug 3590551:Introduced rounding
						'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
						'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
												 +nvl( pta.i_tot_billable_raw_cost,0),
						'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
													  +nvl( pta.i_tot_billable_burdened_cost,0),
						'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
											  +nvl(pta.i_tot_burdened_cost,0),
						'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
											+nvl(pta.i_tot_labor_hours,0),
						'TOT_QUANTITY', nvl(pta.tot_quantity,0)
										+nvl(pta.i_tot_quantity,0),
						 0)),0)*(parr.resource_percent/100)*v_rule_pool_percent) ELIGIBLE_AMOUNT /* bug 3227783 */
					,parr.resource_percent
					,G_creation_date
					,G_created_by
					,G_last_update_date
					,G_last_updated_by
					,G_last_update_login
				from    -- Bug Fix: 3634912 :Changed the order of the tables.
					pa_alloc_run_sources pars,
					pa_alloc_run_resource_det parr,
					pa_resource_accum_details prad,
					pa_txn_accum  pta
				  where  pta.txn_accum_id              = prad.txn_accum_id
					and  prad.Resource_list_member_id  = parr.resource_list_member_id
					and  pta.Project_id                = pars.project_id
					and  pta.task_id                   = pars.task_id
					and  pars.run_id                   = p_run_id
					and  parr.run_id                   = pars.run_id
					and  parr.member_type              = 'S'
					and  pars.exclude_flag             = 'N'
					and  pars.project_id               = c_projects_rec.project_id
					and  pta.pa_period                 = p_period
				  group by pars.run_id
					 ,pars.rule_id
					 ,pars.line_num
					 ,pars.project_id
					 ,pars.task_id
					 ,parr.resource_list_member_id
					 ,parr.resource_percent
					 ,G_creation_date
					 ,G_created_by
					 ,G_last_update_date
					 ,G_last_updated_by
					 ,G_last_update_login);
			ElsiF Nvl(p_resource_struct_type,'RL') = 'RBS' Then
					INSERT INTO PA_ALLOC_RUN_source_DET  (
						   RUN_ID
						 , RULE_ID
						 , LINE_NUM
						 , PROJECT_ID
						 , TASK_ID
						 , RESOURCE_LIST_MEMBER_ID
						 , AMOUNT
						 , ELIGIBLE_AMOUNT
						 , RESOURCE_PERCENT
						 , CREATION_DATE
						 , CREATED_BY
						 , LAST_UPDATE_DATE
						 , LAST_UPDATED_BY
						 , LAST_UPDATE_LOGIN )
					(  select pars.run_id
						 ,pars.rule_id
						 ,pars.line_num
						 ,pars.project_id
						 ,pars.task_id
						 ,parr.resource_list_member_id
						 ,NVL(sum( decode (p_bal_type,
							 'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) + nvl( pta.i_tot_raw_cost,0),
							 'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
													 +nvl( pta.i_tot_billable_raw_cost,0),
							 'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
														  +nvl( pta.i_tot_billable_burdened_cost,0),
							 'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
											  +nvl(pta.i_tot_burdened_cost,0),
							'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
												+nvl(pta.i_tot_labor_hours,0),
							'TOT_QUANTITY',  nvl(pta.tot_quantity,0)
											+ nvl(pta.i_tot_quantity,0),
							 0)),0)AMOUNT
						,pa_currency.round_currency_amt(NVL(sum( decode (p_bal_type,    --Bug 3590551:Introduced rounding
							'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
							'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
													 +nvl( pta.i_tot_billable_raw_cost,0),
							'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
														  +nvl( pta.i_tot_billable_burdened_cost,0),
							'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
												  +nvl(pta.i_tot_burdened_cost,0),
							'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
												+nvl(pta.i_tot_labor_hours,0),
							'TOT_QUANTITY', nvl(pta.tot_quantity,0)
											+nvl(pta.i_tot_quantity,0),
							 0)),0)*(parr.resource_percent/100)*v_rule_pool_percent) ELIGIBLE_AMOUNT /* bug 3227783 */
						,parr.resource_percent
						,G_creation_date
						,G_created_by
						,G_last_update_date
						,G_last_updated_by
						,G_last_update_login
					 from    pa_alloc_run_resource_det parr,
						 pa_alloc_run_sources pars,
						 PA_ALLOC_TXN_ACCUM_RBS_V pta
					  where  pta.Rbs_Element_ID		   = parr.resource_list_member_id
					    and  pta.Project_id                = pars.project_id
					    and  pta.task_id                   = pars.task_id
						and  pta.RBS_STRUCT_VER_ID   = p_rbs_version_id
					    and  pars.run_id                   = p_run_id
					    and  parr.run_id                   = pars.run_id
					    and  parr.member_type              = 'S'
					    and  pars.exclude_flag             = 'N'
					    and  pars.project_id               = c_projects_rec.project_id
					    and  pta.pa_period                 = p_period
					  group by pars.run_id
						 ,pars.rule_id
						 ,pars.line_num
						 ,pars.project_id
						 ,pars.task_id
						 ,parr.resource_list_member_id
						 ,parr.resource_percent
						 ,G_creation_date
						 ,G_created_by
						 ,G_last_update_date
						 ,G_last_updated_by
						 ,G_last_update_login);
				End If;		-------------}
		ELSE /* p_run_period_type = 'GL' */
				IF Nvl(p_resource_struct_type,'RL') = 'RL' Then		----------- {
						INSERT INTO PA_ALLOC_RUN_source_DET  (
						   RUN_ID
						 , RULE_ID
						 , LINE_NUM
						 , PROJECT_ID
						 , TASK_ID
						 , RESOURCE_LIST_MEMBER_ID
						 , AMOUNT
						 , ELIGIBLE_AMOUNT
						 , RESOURCE_PERCENT
						 , CREATION_DATE
						 , CREATED_BY
						 , LAST_UPDATE_DATE
						 , LAST_UPDATED_BY
						 , LAST_UPDATE_LOGIN )
						(  select /*+ ORDERED INDEX (prad, PA_RESOURCE_ACCUM_DETAILS_N2) */ --Bug Fix: 3634912 added hint
						          pars.run_id
							  ,pars.rule_id
							,pars.line_num
							,pars.project_id
							,pars.task_id
							,parr.resource_list_member_id
							,NVL(sum( decode (p_bal_type,
								'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
								'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
													 +nvl( pta.i_tot_billable_raw_cost,0),
								'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
													  +nvl( pta.i_tot_billable_burdened_cost,0),
								'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
													  +nvl(pta.i_tot_burdened_cost,0),
								'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
													  +nvl(pta.i_tot_labor_hours,0),
								'TOT_QUANTITY', nvl(pta.tot_quantity,0)
													  +nvl(pta.i_tot_quantity,0),
								 0)),0)AMOUNT
							,pa_currency.round_currency_amt(NVL(sum( decode (p_bal_type,	  --Bug 3590551:Introduced rounding
								'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
								'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
													 +nvl( pta.i_tot_billable_raw_cost,0),
								'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
													  +nvl( pta.i_tot_billable_burdened_cost,0),
								'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
													  +nvl(pta.i_tot_burdened_cost,0),
								'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
													  +nvl(pta.i_tot_labor_hours,0),
								'TOT_QUANTITY', nvl(pta.tot_quantity,0)
													  +nvl(pta.i_tot_quantity,0),
								 0)),0)*(parr.resource_percent/100)*v_rule_pool_percent) ELIGIBLE_AMOUNT /* bug 3227783 */
							,parr.resource_percent
							,G_creation_date
							,G_created_by
							,G_last_update_date
							,G_last_updated_by
							,G_last_update_login
			                        from    --Bug Fix: 3634912 : Changed the order of the tables.
							pa_alloc_run_sources pars,
						        pa_alloc_run_resource_det parr,
							pa_resource_accum_details prad,
							pa_txn_accum  pta
						  where  pta.txn_accum_id              = prad.txn_accum_id
							and  prad.Resource_list_member_id  = parr.resource_list_member_id
							and  pta.Project_id                = pars.project_id
							and  pta.task_id                   = pars.task_id
							and  pars.run_id                   = p_run_id
							and  parr.run_id                   = pars.run_id
							and  parr.member_type              = 'S'
							and  pars.exclude_flag             = 'N'
							and  pars.project_id               = c_projects_rec.project_id
							and  pta.gl_period		   = p_period /* Using gl_period on pta directly :bug 2757875 */
				/****                   and  pta.pa_period IN
						 (SELECT period_name
							FROM pa_periods pp
						   WHERE pp.gl_period_name = p_period) **** Commented for bug 2757875 ****/
						  group by pars.run_id
								 ,pars.rule_id
								 ,pars.line_num
								 ,pars.project_id
								 ,pars.task_id
								 ,parr.resource_list_member_id
								 ,parr.resource_percent
								 ,G_creation_date
								 ,G_created_by
								 ,G_last_update_date
								 ,G_last_updated_by
								 ,G_last_update_login);
				ElsIF Nvl(p_resource_struct_type,'RL') = 'RBS' Then
				INSERT INTO PA_ALLOC_RUN_source_DET  (
						   RUN_ID
						 , RULE_ID
						 , LINE_NUM
						 , PROJECT_ID
						 , TASK_ID
						 , RESOURCE_LIST_MEMBER_ID
						 , AMOUNT
						 , ELIGIBLE_AMOUNT
						 , RESOURCE_PERCENT
						 , CREATION_DATE
						 , CREATED_BY
						 , LAST_UPDATE_DATE
						 , LAST_UPDATED_BY
						 , LAST_UPDATE_LOGIN )
					(  select pars.run_id
						 ,pars.rule_id
						 ,pars.line_num
						 ,pars.project_id
						 ,pars.task_id
						 ,parr.resource_list_member_id
						 ,NVL(sum( decode (p_bal_type,
							 'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
							 'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
													 +nvl( pta.i_tot_billable_raw_cost,0),
							 'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
													  +nvl( pta.i_tot_billable_burdened_cost,0),
							 'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
													  +nvl(pta.i_tot_burdened_cost,0),
							 'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
													  +nvl(pta.i_tot_labor_hours,0),
							 'TOT_QUANTITY', nvl(pta.tot_quantity,0)
													  +nvl(pta.i_tot_quantity,0),
							  0)),0)AMOUNT
						 ,pa_currency.round_currency_amt(NVL(sum( decode (p_bal_type,	 --Bug 3590551:Introduced rounding
							 'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
							 'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
													  +nvl( pta.i_tot_billable_raw_cost,0),
							 'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
													  +nvl( pta.i_tot_billable_burdened_cost,0),
							 'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
													  +nvl(pta.i_tot_burdened_cost,0),
							 'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
													  +nvl(pta.i_tot_labor_hours,0),
							 'TOT_QUANTITY', nvl(pta.tot_quantity,0)
													  +nvl(pta.i_tot_quantity,0),
							  0)),0)*(parr.resource_percent/100)*v_rule_pool_percent) ELIGIBLE_AMOUNT /* bug 3227783 */
						 ,parr.resource_percent
						 ,G_creation_date
						 ,G_created_by
						 ,G_last_update_date
						 ,G_last_updated_by
						 ,G_last_update_login
					 from    pa_alloc_run_resource_det parr,
						 pa_alloc_run_sources pars,
						 PA_ALLOC_TXN_ACCUM_RBS_V pta
					  where  pta.Rbs_Element_Id			   = parr.resource_list_member_id
						and  pta.Project_id                = pars.project_id
						and  pta.task_id                   = pars.task_id
						and  pta.RBS_STRUCT_VER_ID   = p_rbs_version_id
						and  pars.run_id                   = p_run_id
						and  parr.run_id                   = pars.run_id
						and  parr.member_type              = 'S'
						and  pars.exclude_flag             = 'N'
						and  pars.project_id               = c_projects_rec.project_id
						and  pta.gl_period		   = p_period
					  group by pars.run_id
						 ,pars.rule_id
						 ,pars.line_num
						 ,pars.project_id
						 ,pars.task_id
						 ,parr.resource_list_member_id
						 ,parr.resource_percent
						 ,G_creation_date
						 ,G_created_by
						 ,G_last_update_date
						 ,G_last_updated_by
						 ,G_last_update_login);
			End If;		------------- }
           END IF;
               v_commit_count := v_commit_count + sql%rowcount;
                IF v_commit_count > 5000 then
                   IF P_DEBUG_MODE = 'Y' THEN
                      pa_debug.write_file('insert_alloc_source_resource: ' || 'LOG','commiting the changes after 5000 records');
                   END IF;
                   COMMIT;
                   v_commit_count := 0;
                END IF;
       END LOOP;
       COMMIT;
    Elsif p_amt_type = 'ITD' then
       pa_debug.G_err_stage:= 'inserting for ITD';
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('insert_alloc_source_resource: ' ||  'LOG', pa_debug.G_err_stage);
       END IF;
       v_commit_count := 0;
       FOR c_projects_rec in c_projects LOOP
/****      OPEN C_proj_start_date(c_projects_rec.project_id) ;
           FETCH C_proj_start_date into v_project_start_date ;
           If C_proj_start_date%NOTFOUND  then
               v_project_start_date := NULL ;
           End if ;
           CLOSE C_proj_start_date ;
               IF v_project_start_date is NOT NULL then
**** Commented for bug 2757875****/
	      IF P_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('insert_alloc_source_resource: ' ||  'LOG', 'inserting data for project ' || c_projects_rec.project_id);
              END IF;
		   IF Nvl(p_resource_struct_type,'RL') = 'RL' Then	---------{
			INSERT INTO PA_ALLOC_RUN_source_DET (
						  RUN_ID
						, RULE_ID
						, LINE_NUM
						, PROJECT_ID
						, TASK_ID
						, RESOURCE_LIST_MEMBER_ID
						, AMOUNT
						, ELIGIBLE_AMOUNT
						, RESOURCE_PERCENT
						, CREATION_DATE
						, CREATED_BY
						, LAST_UPDATE_DATE
						, LAST_UPDATED_BY
						, LAST_UPDATE_LOGIN )
				   (  select /*+ ORDERED INDEX (prad, PA_RESOURCE_ACCUM_DETAILS_N2) */ --Bug Fix: 3634912 added hint
					      pars.run_id
					     ,pars.rule_id
					     ,pars.line_num
					     ,pars.project_id
					     ,pars.task_id
					     ,parr.resource_list_member_id
					     ,NVL(sum( decode (p_bal_type,
					     'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
						'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
												 +nvl( pta.i_tot_billable_raw_cost,0),
						'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
												 +nvl( pta.i_tot_billable_burdened_cost,0),
						'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
												 +nvl(pta.i_tot_burdened_cost,0),
						'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
												 +nvl(pta.i_tot_labor_hours,0),
						'TOT_QUANTITY', nvl(pta.tot_quantity,0)
											 +nvl(pta.i_tot_quantity,0),
							0
						  )),0) AMOUNT
						,pa_currency.round_currency_amt(NVL(sum( decode (p_bal_type,	 --Bug 3590551:Introduced rounding
							'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
							'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
													 +nvl( pta.i_tot_billable_raw_cost,0),
							'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
													 +nvl( pta.i_tot_billable_burdened_cost,0),
							'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
													 +nvl(pta.i_tot_burdened_cost,0),
							'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
														 +nvl(pta.i_tot_labor_hours,0),
							'TOT_QUANTITY', nvl(pta.tot_quantity,0)
													 +nvl(pta.i_tot_quantity,0),
							0
						  )),0)*(parr.resource_percent/100)*v_rule_pool_percent) ELIGIBLE_AMOUNT /* bug 3227783 */
						,parr.resource_percent
						,G_creation_date
						,G_created_by
						,G_last_update_date
						,G_last_updated_by
						,G_last_update_login
					from  --Bug Fix: 3634912 : Changed the order of the tables
						pa_alloc_run_sources pars,
						pa_alloc_run_resource_det parr,
						pa_resource_accum_details prad,
						pa_txn_accum  pta
					 where  pta.txn_accum_id              = prad.txn_accum_id
					   and  prad.Resource_list_member_id  = parr.resource_list_member_id
					   and  prad.Project_id               = pars.project_id
					   and  prad.task_id                  = pars.task_id
					   and  pars.run_id                   = p_run_id
					   and  parr.run_id                   = pars.run_id
					   and  parr.member_type              = 'S'
					   and  pars.exclude_flag             = 'N'
					   and  pars.project_id               = c_projects_rec.project_id
					   and  exists
							(select /*+ NO_UNNEST */	--Bug 3634912 : Added Hint.
								1
							  from  pa_periods pp
							 where  pta.pa_period = pp.period_name
							   and  pp.end_date  <= p_run_period_end_date) /* Added for bug 2757875 */
			/****                              and  pp.end_date between v_project_start_date
						and p_run_period_end_date) **** Commented for bug 2757875****/
					 group by pars.run_id
						,pars.rule_id
						,pars.line_num
						,pars.project_id
						,pars.task_id
						,parr.resource_list_member_id
						,parr.resource_percent
						,G_creation_date
						,G_created_by
						,G_last_update_date
						,G_last_updated_by
						,G_last_update_login);
			  ElsIf Nvl(p_resource_struct_type,'RL') = 'RBS' Then
					INSERT INTO PA_ALLOC_RUN_source_DET (
							  RUN_ID
							, RULE_ID
							, LINE_NUM
							, PROJECT_ID
							, TASK_ID
							, RESOURCE_LIST_MEMBER_ID
							, AMOUNT
							, ELIGIBLE_AMOUNT
							, RESOURCE_PERCENT
							, CREATION_DATE
							, CREATED_BY
							, LAST_UPDATE_DATE
							, LAST_UPDATED_BY
							, LAST_UPDATE_LOGIN )
						   (  select pars.run_id
							,pars.rule_id
							,pars.line_num
							,pars.project_id
							,pars.task_id
							,parr.resource_list_member_id
							,NVL(sum( decode (p_bal_type,
								'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
								'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
													 +nvl( pta.i_tot_billable_raw_cost,0),
								'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
													 +nvl( pta.i_tot_billable_burdened_cost,0),
								'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
													 +nvl(pta.i_tot_burdened_cost,0),
								'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
													 +nvl(pta.i_tot_labor_hours,0),
								'TOT_QUANTITY', nvl(pta.tot_quantity,0)
													 +nvl(pta.i_tot_quantity,0),
								0
							  )),0) AMOUNT
							,pa_currency.round_currency_amt(NVL(sum( decode (p_bal_type,  --Bug 3590551:Introduced rounding
								'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
								'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
													 +nvl( pta.i_tot_billable_raw_cost,0),
								'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
													 +nvl( pta.i_tot_billable_burdened_cost,0),
								'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
													 +nvl(pta.i_tot_burdened_cost,0),
								'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
													 +nvl(pta.i_tot_labor_hours,0),
								'TOT_QUANTITY', nvl(pta.tot_quantity,0)
													 +nvl(pta.i_tot_quantity,0),
								0
							  )),0)*(parr.resource_percent/100)*v_rule_pool_percent) ELIGIBLE_AMOUNT /* bug 3227783 */
							,parr.resource_percent
							,G_creation_date
							,G_created_by
							,G_last_update_date
							,G_last_updated_by
							,G_last_update_login
						from    pa_alloc_run_resource_det parr,
							pa_alloc_run_sources	  pars,
							PA_ALLOC_TXN_ACCUM_RBS_V  pta
						 where  pta.Rbs_Element_Id			  = parr.resource_list_member_id
						   and  pta.Project_id                = pars.project_id
						   and  pta.task_id                   = pars.task_id
						   and  pta.RBS_STRUCT_VER_ID   = p_rbs_version_id
						   and  pars.run_id                   = p_run_id
						   and  parr.run_id                   = pars.run_id
						   and  parr.member_type              = 'S'
						   and  pars.exclude_flag             = 'N'
						   and  pars.project_id               = C_projects_rec.project_id
						   and  exists
							(select /*+ NO_UNNEST */  -- Bug3634912 : Added hint .
								1
							   from  pa_periods pp
								  where  pta.pa_period = pp.period_name
									    and  pp.end_date  <= p_run_period_end_date
									)
						 group by pars.run_id
							,pars.rule_id
							,pars.line_num
							,pars.project_id
							,pars.task_id
							,parr.resource_list_member_id
							,parr.resource_percent
							,G_creation_date
							,G_created_by
							,G_last_update_date
							,G_last_updated_by
							,G_last_update_login);
		  End If;
	      v_commit_count := v_commit_count + sql%rowcount;
--             END IF; ****  Commented for bug 2757875
               IF v_commit_count > 5000 then
                  IF P_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('insert_alloc_source_resource: ' || 'LOG','commiting the changes after 5000 records');
                  END IF;
                  COMMIT;
                  v_commit_count := 0;
               END IF;
       END LOOP;
       COMMIT;
    End If ;
    pa_debug.G_err_stage:= 'exiting insert_alloc_source_resource';
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('insert_alloc_source_resource: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
       RAISE ;
END insert_alloc_source_resource;
-- ==========================================================================
/* PROCEDURE :  insert_budget_basis_resource
   Purpose   :  inserts records into pa_alloc_run_basis_det when budgets are used
                for basis and resource lists are used to calculate basis amounts.
   Created   :  02-feb-01 Manoj.
   Modified  :  24-JAN-03 Tarun for bug 2757875
                06-Apr-04 vthakkar FP.M : ALlocation Impact
*/
-- ==========================================================================
PROCEDURE insert_budget_basis_resource(p_run_id              IN NUMBER,
                                       p_rule_id             IN NUMBER,
                                       p_run_period_type     IN VARCHAR2,
                                       p_bal_type            IN VARCHAR2,
                                       p_budget_type_code    IN VARCHAR2,
                                       p_start_date          IN DATE ,
                                       p_end_date            IN DATE ,
									   /* FP.M : Allocation Impact */
									   p_basis_resource_struct_Type in Varchar2
									   )
IS
     cursor c_projects is
     select distinct project_id
       from pa_alloc_run_targets part
      where part.run_id = p_run_id;
    v_commit NUMBER := 0;
BEGIN
  FOR c_projects_rec IN c_projects LOOP
     If p_run_period_type = 'PA' then
          INSERT INTO PA_ALLOC_RUN_BASIS_DET (
             RUN_ID
           , RULE_ID
           , LINE_NUM
           , PROJECT_ID
           , TASK_ID
           , RESOURCE_LIST_MEMBER_ID
           , AMOUNT
           , LINE_PERCENT
           , CREATION_DATE
           , CREATED_BY
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN )
          (  select part.run_id
                   ,part.rule_id
                   ,part.line_num
                   ,part.project_id
                   ,part.task_id
                   ,parr.resource_list_member_id
                   ,nvl(sum(decode (p_bal_type,
                    'BASE_RAW_COST',       nvl(pfpp.raw_cost,0),
                    'BASE_BURDENED_COST',  nvl(pfpp.burdened_cost,0),
                    'BASE_QUANTITY',       nvl(pfpp.quantity,0),
                    'BASE_LABOR_QUANTITY', nvl(pfpp.labor_quantity,0),
                    0)),0) AMOUNT
                   ,part.line_percent
                   ,G_creation_date
                   ,G_created_by
                   ,G_last_update_date
                   ,G_last_updated_by
                   ,G_last_update_login
            from   pa_alloc_run_resource_det parr,
                   pa_alloc_run_targets part,
    /***           pa_base_budget_by_pa_period_v  pbpp *** commented bug 2619977 */
                   pa_base_finplan_by_pa_period_v  pfpp   /* added bug 2619977 */
           where    Decode (
							Nvl(p_basis_resource_struct_Type,'RL') ,
							'RL' , pfpp.resource_list_member_id ,
							'RBS' , pfpp.RBS_ELEMENT_ID
					        ) = parr.resource_list_member_id
             and   pfpp.Project_id              = part.project_id
             and   pfpp.task_id                 = part.task_id
             and   part.project_id              = c_projects_rec.project_id
             and   part.exclude_flag            = 'N'
   /***      and   pbpp.budget_type_code        = p_budget_type_code *** commented bug 2619977 */
             and   pfpp.budget_version_id       = part.budget_version_id /* added bug 2619977 */
             and   pfpp.period_start_date      >= nvl(p_start_date,pfpp.period_start_date)
             and   pfpp.period_end_date        <= p_end_date
             and   parr.run_id                  = p_run_id
			 and   parr.run_id                  = part.run_id  /* Bug #  3850611 */
             and   parr.member_type             = 'B'
            group by part.run_id
                   ,part.rule_id
                   ,part.line_num
                   ,part.project_id
                   ,part.task_id
                   ,parr.resource_list_member_id
                   ,part.line_percent
                   ,G_creation_date
                   ,G_created_by
                   ,G_last_update_date
                   ,G_last_updated_by
                   ,G_last_update_login);
     Elsif  p_run_period_type = 'GL' then
          INSERT INTO PA_ALLOC_RUN_BASIS_DET (
             RUN_ID
           , RULE_ID
           , LINE_NUM
           , PROJECT_ID
           , TASK_ID
           , RESOURCE_LIST_MEMBER_ID
           , AMOUNT
           , LINE_PERCENT
           , CREATION_DATE
           , CREATED_BY
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN )
          (  select part.run_id
                   ,part.rule_id
                   ,part.line_num
                   ,part.project_id
                   ,part.task_id
                   ,parr.resource_list_member_id
                   ,nvl(sum( decode (p_bal_type,
                    'BASE_RAW_COST',       nvl(pfpg.raw_cost,0),
                    'BASE_BURDENED_COST',  nvl(pfpg.burdened_cost,0),
                    'BASE_QUANTITY',       nvl(pfpg.quantity,0),
                    'BASE_LABOR_QUANTITY', nvl(pfpg.labor_quantity,0),
                    0
                    )),0)  amount
                   ,part.line_percent
                   ,G_creation_date
                   ,G_created_by
                   ,G_last_update_date
                   ,G_last_updated_by
                   ,G_last_update_login
            from   pa_alloc_run_resource_det parr,
                   pa_alloc_run_targets part,
    /***           pa_base_budget_by_gl_period_v  pbpg *** commented bug 2619977 */
	           /* pa_base_finplan_by_pa_period_v  pfpg     added bug 2619977 commented bug 2757875 */
			    pa_base_finplan_by_gl_period_v  pfpg     /*  added bug 2757875 */
           where   Decode (
							NVL(p_basis_resource_struct_Type,'RL') ,
							'RL' , pfpg.resource_list_member_id ,
							'RBS' , pfpg.RBS_ELEMENT_ID
					        )  = parr.resource_list_member_id
             and   pfpg.Project_id              = part.project_id
             and   pfpg.task_id                 = part.task_id
    /***     and   pfpg.budget_type_code        = p_budget_type_code ** commented bug 2619977 */
             and   pfpg.budget_version_id       = part.budget_version_id /* added bug 2619977 */
             and   pfpg.period_start_date      >= nvl(p_start_date,pfpg.period_start_date)
             and   pfpg.period_end_date        <= p_end_date
             and   part.project_id              = c_projects_rec.project_id
             and   part.exclude_flag            = 'N'
             and   parr.run_id                  = p_run_id
			 and   parr.run_id                  = part.run_id /* Bug #  3850611 */
             and   parr.member_type             = 'B'
            group by part.run_id
                   ,part.rule_id
                   ,part.line_num
                   ,part.project_id
                   ,part.task_id
                   ,parr.resource_list_member_id
                   ,part.line_percent
                   ,G_creation_date
                   ,G_created_by
                   ,G_last_update_date
                   ,G_last_updated_by
                   ,G_last_update_login);
     End if ;
     v_commit := v_commit + sql%rowcount;
     if v_commit > 5000 then
        commit;
        v_commit := 0;
     end if;
  END LOOP;
EXCEPTION
    WHEN OTHERS THEN
       RAISE ;
END insert_budget_basis_resource;
/* following procedure is obsoleted (not in use after fix for 2211234 */
-- ==========================================================================
/* PROCEDURE :  get_alloc_amount
   Purpose   :  To get the accumulated amount for given project/task/Resource.
                The amount type ( FYTD/QTD/ITD/PTD) determines the start date from
                which the amounts need to be considered.
                For FYTD and QTD the period type is always GL.
                For PTD the period type can be PA or GL
                For ITD the project start date is the start date.
     Created :   30-JUL-98   Sesivara
*/
-- ==========================================================================
PROCEDURE get_alloc_amount( p_amt_type        IN VARCHAR2,
                            p_bal_type        IN VARCHAR2,
                            p_run_period_type IN VARCHAR2,
                            p_project_id      IN NUMBER  ,
                            p_task_id         IN NUMBER  ,
                            p_rlm_id          IN NUMBER  ,
                            p_period          IN VARCHAR2,
                            p_period_type     IN VARCHAR2 ,
                            p_peiod_set_name  IN VARCHAR2 ,
                            p_period_year     IN NUMBER   ,
                            p_quarter         IN NUMBER   ,
                            p_run_period_end_date IN DATE ,
                            p_amttype_start_date  IN DATE ,
                            x_amount          OUT NOCOPY NUMBER  )
IS
     v_project_start_date  DATE ;
     cursor C_fytd_qtd_amt is
       select NVL(sum( decode (p_bal_type,
                    'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
                    'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
                                             +nvl( pta.i_tot_billable_raw_cost,0),
                    'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
                                             +nvl( pta.i_tot_billable_burdened_cost,0),
                    'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
                                             +nvl(pta.i_tot_burdened_cost,0),
                    'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
                                             +nvl(pta.i_tot_labor_hours,0),
                    'TOT_QUANTITY', nvl(pta.tot_quantity,0)
                                             +nvl(pta.i_tot_quantity,0),
                    0
                  )),0)
         from pa_txn_accum  pta,
              pa_periods pp,
              pa_resource_accum_details prad
        where pta.txn_accum_id = prad.txn_accum_id
           and  prad. Resource_list_member_id = p_rlm_id
           and  prad. Project_id              = p_project_id
           and  prad.task_id                  = p_task_id
           and  pta.pa_period                 = pp.period_name
           and  pp.end_date                  >= p_amttype_start_date
           and  pp.end_date                  <= p_run_period_end_date ;
     cursor C_ptd_amt is
       select NVL(sum( decode (p_bal_type,
                    'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
                    'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
                                             +nvl( pta.i_tot_billable_raw_cost,0),
                    'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
                                             +nvl( pta.i_tot_billable_burdened_cost,0),
                    'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
                                             +nvl(pta.i_tot_burdened_cost,0),
                    'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
                                             +nvl(pta.i_tot_labor_hours,0),
                    'TOT_QUANTITY', nvl(pta.tot_quantity,0)
                                             +nvl(pta.i_tot_quantity,0),
                    0
                  )),0)
         from pa_txn_accum  pta,
              pa_resource_accum_details prad
         where pta.txn_accum_id = prad.txn_accum_id
           and  prad. Resource_list_member_id = p_rlm_id
           and  prad. Project_id              = p_project_id
           and  prad.task_id                  = p_task_id
           and  decode ( p_run_period_type, 'GL', pta.gl_period, pta.pa_period) = p_period ;
     cursor C_itd_amt is
       select NVL(sum( decode (p_bal_type,
                    'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
                    'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
                                             +nvl( pta.i_tot_billable_raw_cost,0),
                    'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
                                             +nvl( pta.i_tot_billable_burdened_cost,0),
                    'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
                                             +nvl(pta.i_tot_burdened_cost,0),
                    'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
                                             +nvl(pta.i_tot_labor_hours,0),
                    'TOT_QUANTITY', nvl(pta.tot_quantity,0)
                                             +nvl(pta.i_tot_quantity,0),
                    0
                  )),0)
         from pa_txn_accum  pta,
              pa_periods    pp ,
              pa_resource_accum_details prad
       where  pta.txn_accum_id = prad.txn_accum_id
         and  prad. Resource_list_member_id = p_rlm_id
         and  prad. Project_id              = p_project_id
         and  prad.task_id                  = p_task_id
         and  pta.pa_period                 = pp.period_name
         and  pp.end_date                  >= v_project_start_date
         and  pp.end_date                  <= p_run_period_end_date ;
   Cursor C_proj_start_date is
        select start_date
          from  pa_projects
         where project_id =  p_project_id ;
BEGIN
--    project and task amount is returned  based on the amount type (FTYD/QTD/PTD/ITD)
--    and run period and run period type
     If p_amt_type in ( 'FYTD', 'QTD') then
        OPEN C_fytd_qtd_amt ;
        FETCH C_fytd_qtd_amt into x_amount ;
        If C_fytd_qtd_amt%NOTFOUND  then
            x_amount := 0 ;
        End if ;
        CLOSE C_fytd_qtd_amt ;
     Elsif  p_amt_type = 'PTD' then
        OPEN C_ptd_amt ;
        FETCH C_ptd_amt into x_amount ;
        If C_ptd_amt%NOTFOUND  then
            x_amount := 0 ;
        End if ;
        CLOSE C_ptd_amt ;
    Elsif p_amt_type = 'ITD' then
        OPEN C_proj_start_date ;
        FETCH C_proj_start_date into v_project_start_date ;
        If C_proj_start_date%NOTFOUND  then
            v_project_start_date := NULL ;
        End if ;
        CLOSE C_proj_start_date ;
        IF v_project_start_date is NOT NULL then
           OPEN C_itd_amt ;
           FETCH C_itd_amt into x_amount ;
           If C_itd_amt%NOTFOUND  then
               x_amount := 0 ;
           End if ;
           CLOSE C_itd_amt ;
        End if ;
    End If ;
EXCEPTION
    WHEN OTHERS THEN
       RAISE ;
END get_alloc_amount ;
-- ============================================================
-- insert_alloc_run_src_det
-- ============================================================
PROCEDURE insert_alloc_run_src_det( p_rule_id            IN NUMBER
                                  , p_run_id             IN NUMBER
                                  , p_line_num           IN NUMBER
                                  , p_project_id         IN NUMBER
                                  , p_task_id            IN NUMBER
                                  , p_rlm_id             IN NUMBER
                                  , p_amount             IN NUMBER
                                  , p_resource_percent   IN NUMBER
                                  , p_eligible_amount    IN NUMBER
                                  , p_creation_date      IN DATE
                                  , p_created_by         IN NUMBER
                                  , p_last_update_date   IN DATE
                                  , p_last_updated_by    IN NUMBER
                                  , p_last_update_login  IN NUMBER)
IS
BEGIN
  pa_debug.set_err_stack('insert_alloc_run_source_det') ;
  pa_debug.G_err_stage := 'INSERTING PA_ALLOC_RUN_SOURCE_DET' ;
  INSERT INTO PA_ALLOC_RUN_SOURCE_DET (
     RUN_ID
   , RULE_ID
   , LINE_NUM
   , PROJECT_ID
   , TASK_ID
   , RESOURCE_LIST_MEMBER_ID
   , AMOUNT
   , RESOURCE_PERCENT
   , ELIGIBLE_AMOUNT
   , CREATION_DATE
   , CREATED_BY
   , LAST_UPDATE_DATE
   , LAST_UPDATED_BY
   , LAST_UPDATE_LOGIN )
  VALUES (
      p_run_id
    , p_rule_id
    , p_line_num
    , p_project_id
    , p_task_id
    , p_rlm_id
    , p_amount
    , p_resource_percent
    , p_eligible_amount
    , p_creation_date
    , p_created_by
    , p_last_update_date
    , p_last_updated_by
    , p_last_update_login ) ;
   /*  restore the old stack */
    pa_debug.reset_err_stack;
EXCEPTION
   WHEN OTHERS THEN
   RAISE;
END insert_alloc_run_src_det;
-- ==========================================================================
/* PROCEDURE :  calculate_amount_from_projects
   Purpose   :  For a given allocation run, this function will find the amount
                for all defined projects , tasks on the given resources
     Created :   03-AUG-98   Sesivara
	Modified:	  24-JAN-03   Tarun for bug 2757875
*/
-- ==========================================================================
PROCEDURE cal_amounts_from_projects(p_rule_id          IN NUMBER,
                                    p_run_id           IN NUMBER,
                                    p_run_period_type  IN VARCHAR2,
                                    p_run_amount_type  IN VARCHAR2,
                                    p_run_period       IN VARCHAR2,
                                    p_bal_type         IN VARCHAR2,
                                    p_resource_list_id IN NUMBER  ,
									p_pool_percent     IN NUMBER  ,
                                    p_fixed_amount     IN NUMBER  ,
                                    x_proj_pool_amount OUT NOCOPY NUMBER ,
									/* FP.M : Allocation Impact  Bug # 3512552 */
									p_source_resource_struct_type in Varchar2,
									p_source_rbs_version_id In Number
)
IS
/*
  Function:  To calculate the source amount from each project and task for a
             given rule, run, and period type , amount type and run_period.
   Steps: 1.  Get the  Period Year and Quarter Num values for the given run_period.
          2. If source_resource_lists is not null then
               Populate  Include_RLM_tbl.
               For each resource list member in the Include_RLM_tbl then
                   Get source amount for each project and task in pa_alloc_run_sources
                   tables for given rule_id and run_id
             Else
               For each project and task in  pa_alloc_run_targets
               find the basis amount at project and task level.
             End if.
*/
    v_period_type           VARCHAR2(15)  ;
    v_period_set_name       VARCHAR2 (15) ;
    v_period_year           NUMBER    ;
    v_quarter               NUMBER    ;
    v_period_num            NUMBER    ;
    v_run_period_end_date   DATE      ;
    v_amttype_start_date    DATE      ;
    v_resource_list_id      NUMBER    ;
    v_rlm_id                NUMBER ;
    v_rlm_percent           NUMBER ;
--  v_src_rlm_tab           SRC_RLM_TABTYPE ;  /* after fix 2211234 this table is not required */
    v_resource_count        NUMBER;  /* added for 2211234 */
    v_amount                NUMBER ;
    v_pool_amount           NUMBER ;
    v_pool_percent          NUMBER ;
         v_net_fixed_amount      NUMBER ;
    cursor C_run_source_details is
           Select  line_num, project_id , task_id
             from  pa_alloc_run_sources
            where  rule_id   =  p_rule_id
             and   run_id    =  p_run_id
             and   exclude_flag  <> 'Y' ;
    cursor C_get_pool_amount is
           select nvl(sum(nvl(eligible_amount,0)),0)
             from pa_alloc_run_source_det
            where run_id = p_run_id ;
	Cursor c_get_proj is
		   Select RUN_ID              ,
				  RULE_ID             ,
				  LINE_NUM            ,
				  PROJECT_ID          ,
				  TASK_ID
		     From Pa_Alloc_Run_Sources
			Where Rule_Id = P_Rule_Id
			  And Run_Id = P_Run_Id
			  And Nvl(Exclude_Flag,'N') = 'N';
BEGIN
    pa_debug.set_err_stack('Cal_amounts_from_projects') ;
    pa_debug.G_err_stage := 'Get Fiscal Year and quarter for run period and amounttype' ;
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('cal_amounts_from_projects: ' || 'LOG', pa_debug.G_Err_Stage);
    END IF;
    get_fiscalyear_quarter(p_run_period_type, p_run_period, v_period_type,
                           v_period_set_name, v_period_year, v_quarter, v_period_num,
                           v_run_period_end_date) ;
    pa_debug.G_err_stage := 'Getting start date for given amount type(FYTD/QTD)' ;
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('cal_amounts_from_projects: ' || 'LOG', pa_debug.G_Err_Stage);
    END IF;
    get_amttype_start_date( p_run_amount_type, v_period_type, v_period_set_name,
                            v_run_period_end_date, v_quarter, v_period_year,
                            p_run_period, v_amttype_start_date) ;
--  v_resource_list_id := alloc_rule.alloc_resource_list_id ;
--  v_pool_percent     := nvl(alloc_rule.pool_percent,100)/100     ;
    v_pool_percent     :=  nvl(p_pool_percent,100)/100  ;
    v_resource_list_id :=  p_resource_list_id ;
--  Create source details record for fixed amount defined at rule level
    If nvl(p_fixed_amount, 0)  <> 0 then
	   v_net_fixed_amount := p_fixed_amount*v_pool_percent;
       v_net_fixed_amount := pa_currency.round_currency_amt( v_net_fixed_amount );
	   insert_alloc_run_src_det(p_rule_id, p_run_id, 0,
                                0, 0, NULL, p_fixed_amount,
                                NULL , v_net_fixed_amount,
                                G_creation_date, G_created_by,
                                G_last_update_date,
                                G_last_updated_by, G_last_update_login);
    End if ;
    If v_resource_list_id is NOT NULL then
       pa_debug.G_err_stage := 'Populating the Resource List Member array         ' ;
	   IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('cal_amounts_from_projects: ' || 'LOG', pa_debug.G_Err_Stage);
       END IF;
       /* bug 2211234 - added p_run_id.
                      - removed v_src_rlm_tab
          This procedure will now populate records into pa_alloc_run_resources_det */
       populate_RLM_table( p_rule_id, p_run_id,
						   'S',
						   v_resource_list_id ,
						   p_source_resource_struct_type ,
						   p_source_rbs_version_id ,
						   'A'  /* value of p_basis_category  as 'A' in case of Source */
						   ) ;
       BEGIN
            select count(*)
              into v_resource_count
              from pa_alloc_run_resource_det
             where rule_id = p_rule_id
               and run_id = p_run_id
               and member_type = 'S';
            if v_resource_count = 0 then
               alloc_errors(p_rule_id, p_run_id, 'S','E', 'PA_AL_NO_INCL_SRC_RESRC',TRUE) ;
            end if ;
       EXCEPTION
       WHEN OTHERS THEN
          pa_debug.G_err_stage := 'error during selecting count from pa_alloc_run_resources_det' ;
          IF P_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('cal_amounts_from_projects: ' || 'LOG', pa_debug.G_Err_Stage);
          END IF;
          RAISE;
       END;
       pa_debug.G_err_stage := 'Processing project/Tasks to get resource level amounts ' ;
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('cal_amounts_from_projects: ' || 'LOG', pa_debug.G_Err_Stage);
       END IF;
/*     added for 2211234 */
       insert_alloc_source_resource(p_run_id               =>   p_run_id
                                   ,p_rule_id              =>   p_rule_id
                                   ,p_resource_list_id     =>   v_resource_list_id
                                   ,p_amt_type             =>   p_run_amount_type
                                   ,p_bal_type             =>   p_bal_type
                                   ,p_run_period_type      =>   p_run_period_type
                                   ,p_period               =>   p_run_period
                                   ,p_run_period_end_date  =>   v_run_period_end_date
                                   ,p_amttype_start_date   =>   v_amttype_start_date
								   /* FP.M : Allocation Impact */
								   ,p_resource_struct_type =>   p_source_resource_struct_type
								   ,p_rbs_version_id       =>   p_source_rbs_version_id
								   );
/*     insert_alloc_source_resource will do whatever used to be done by this block
       For  I in 1.. v_src_rlm_tab.count   LOOP
             v_rlm_id            :=  v_src_rlm_tab(I).resource_list_member_id ;
             v_rlm_percent       := v_src_rlm_tab(I).resource_percent ;
            For src_det_rec in C_run_source_details  LOOP
                get_alloc_amount( p_run_amount_type, p_bal_type, p_run_period_type,
                                  src_det_rec.project_id, src_det_rec.task_id,
                                  v_rlm_id, p_run_period, v_period_type,
                                  v_period_set_name, v_period_year, v_quarter,
                                  v_run_period_end_date,
                                  v_amttype_start_date, v_amount )  ;
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_debug.write_file('cal_amounts_from_projects: ' || 'LOG', 'v_rlm_percent '||to_char(v_rlm_percent));
                END IF;
                v_pool_amount := v_amount * (nvl(v_rlm_percent,100)/100) *
                                 (nvl(p_pool_percent,100)/100) ;
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_debug.write_file('cal_amounts_from_projects: ' || 'LOG', 'v_amount '||to_char(v_amount));
                   pa_debug.write_file('cal_amounts_from_projects: ' || 'LOG', 'v_pool_amount '||to_char(v_pool_amount));
                END IF;
                v_pool_amount := pa_currency.round_currency_amt( v_pool_amount );
                v_amount := pa_currency.round_currency_amt( v_amount );
                insert_alloc_run_src_det(p_rule_id, p_run_id, src_det_rec.line_num,
                                         src_det_rec.project_id,
                                         src_det_rec.task_id, v_rlm_id, v_amount,
                                         v_rlm_percent , v_pool_amount,
                                         G_creation_date, G_created_by,
                                         G_last_update_date,
                                         G_last_updated_by, G_last_update_login) ;
            END LOOP ;
       END LOOP ;
*/
	Else
	   pa_debug.G_err_stage := 'Processing project/Tasks to get amounts         ' ;
	   IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('cal_amounts_from_projects: ' || 'LOG', pa_debug.G_Err_Stage);
       END IF;
	   If  p_run_amount_type in ( 'FYTD','QTD')  then
		 For l_get_proj in c_get_proj
		 Loop
			 Insert into pa_alloc_run_source_det( rule_id, run_id, line_num, project_id,
												  task_id, creation_date, created_by,
												  last_update_date,
												  last_updated_by, last_update_login,
												  amount, eligible_amount)
						 select  l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
								 l_get_proj.task_id,
								 /*  Bug 3749469
								 pars.rule_id, pars.run_id,  pars.line_num, pars.project_id,
								 pars.task_id,
								 */
								 G_creation_date, G_created_by, G_last_update_date,
								 G_last_updated_by, G_last_update_login ,
								 sum( decode (p_bal_type,
						'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
						'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
												 +nvl( pta.i_tot_billable_raw_cost,0),
						'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
												 +nvl( pta.i_tot_billable_burdened_cost,0),
						'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)+
												 +nvl(pta.i_tot_burdened_cost,0),
									  0 )),
								 pa_currency.round_currency_amt(sum( decode (p_bal_type,
						'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
						'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
												 +nvl( pta.i_tot_billable_raw_cost,0),
						'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
												 +nvl( pta.i_tot_billable_burdened_cost,0),
						'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)+
												 +nvl(pta.i_tot_burdened_cost,0),
										0) * v_pool_percent ) )
						   from  pa_alloc_txn_accum_v pta,
														   /* FP.M : Allocation Impact : pa_txn_accum pta */
														   /* Commenting out pa_periods for bug 2757875 and using gl_period_statuses instead */
	--                           pa_periods   pp ,
								 gl_period_statuses   gl ,
								 pa_implementations imp
								 /* pa_alloc_run_sources pars */ /* Loop thru pa_alloc_run_sources. Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id and Task_Id */
						   where  /*  Bug 3749469
						                 pars.rule_id       = p_rule_id
									and  pars.run_id        = p_run_id
								    and  pars.exclude_flag  = 'N'
								    and  pta.project_id     = pars.project_id
									and  pta.task_id        = pars.task_id
								 */
							      pta.project_id     = l_get_proj.project_id /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id */
						     and  pta.task_id        = l_get_proj.task_id /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id */
							 and  pta.gl_period      = gl.period_name
							 and  gl.set_of_books_id = imp.set_of_books_id
							 and  gl.application_id = pa_period_process_pkg.application_id
							 and  gl.adjustment_period_flag = 'N'
							 and  gl.closing_status in ('C','F','O','P')
							 and  gl.end_date       >= v_amttype_start_date
							 and  gl.end_date       <= v_run_period_end_date
	--                       and  pta.pa_period      = pp.period_name
	--                       and  pp.end_date       >= v_amttype_start_date
	--                       and  pp.end_date       <= v_run_period_end_date
						group by  /*
								  pars.rule_id, pars.run_id,  pars.line_num, pars.project_id,
								  pars.task_id,
								  */
								  l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
								  l_get_proj.task_id,
								  G_creation_date, G_created_by, G_last_update_date,
								  G_last_updated_by, G_last_update_login ;
		 End Loop;
       elsif p_run_amount_type = 'PTD' then
		   If p_run_period_type = 'GL' then
			For l_get_proj in c_get_proj
			Loop
			  Insert into pa_alloc_run_source_det( rule_id, run_id, line_num, project_id,                                              task_id,
                                              creation_date, created_by,
                                              last_update_date,
                                              last_updated_by, last_update_login,
                                              amount, eligible_amount)
                 select  /* Bug 3749469
						 pars.rule_id, pars.run_id, pars.line_num,  pars.project_id,
                         pars.task_id,
						 */
						 l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
						 l_get_proj.task_id,
                         G_creation_date, G_created_by, G_last_update_date,
                         G_last_updated_by, G_last_update_login ,
                             sum( decode (p_bal_type,
                    'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
                    'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
                                             +nvl( pta.i_tot_billable_raw_cost,0),
                    'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
                                             +nvl( pta.i_tot_billable_burdened_cost,0),
                    'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)+
                                             +nvl(pta.i_tot_burdened_cost,0),
                                  0 )),
                            pa_currency.round_currency_amt( sum( decode (p_bal_type,
                    'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
                    'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
                                             +nvl( pta.i_tot_billable_raw_cost,0),
                    'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
                                             +nvl( pta.i_tot_billable_burdened_cost,0),
                    'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)+
                                             +nvl(pta.i_tot_burdened_cost,0),
                                    0) * v_pool_percent ) )
                 from  pa_alloc_txn_accum_v pta /* FP.M : Allocation Impact : pa_txn_accum pta */
-- Commented out pa_periods. Used the gl_periods column in pa_txn_accum table
--                     pa_periods   pp
                       /* pa_alloc_run_sources pars */ /* Loop thru pa_alloc_run_sources. Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id and Task_Id */
                where  /* pars.rule_id       = p_rule_id
                  and  pars.run_id        = p_run_id
                  and  pars.exclude_flag  = 'N'
				  and  pta.project_id     = pars.project_id
                  and  pta.task_id        = pars.task_id
                  */
				       pta.project_id     = l_get_proj.project_id /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id */
				  and  pta.task_id		  = l_get_proj.task_id /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Task_Id */
                  and  pta.gl_period      = p_run_period
--                and  pta.pa_period      = pp.period_name
--                and  pp.gl_period_name  = p_run_period
             group by
			           /* Bug 3749469
					   pars.rule_id, pars.run_id, pars.line_num,pars.project_id,
                       pars.task_id,
					   */
					   l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
					   l_get_proj.task_id,
                       G_creation_date, G_created_by, G_last_update_date,
                       G_last_updated_by, G_last_update_login ;
			End Loop;
		elsif p_run_period_type = 'PA' then
			For l_get_proj in c_get_proj
			Loop
				 Insert into pa_alloc_run_source_det(
                      rule_id, run_id, line_num, project_id, task_id,
                      creation_date, created_by, last_update_date,
                      last_updated_by, last_update_login,
                      amount, eligible_amount)
                  select
					   /* Bug 3749469
					   pars.rule_id, pars.run_id, pars.line_num,pars.project_id,
                       pars.task_id,
					   */
					   l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
					   l_get_proj.task_id,
                          G_creation_date, G_created_by, G_last_update_date,
                          G_last_updated_by, G_last_update_login ,
                             sum( decode (p_bal_type,
                    'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
                    'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
                                             +nvl( pta.i_tot_billable_raw_cost,0),
                    'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
                                             +nvl( pta.i_tot_billable_burdened_cost,0),
                    'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)+
                                             +nvl(pta.i_tot_burdened_cost,0),
                                  0 )),
                             pa_currency.round_currency_amt(sum( decode (p_bal_type,
                    'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
                    'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
                                             +nvl( pta.i_tot_billable_raw_cost,0),
                    'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
                                             +nvl( pta.i_tot_billable_burdened_cost,0),
                    'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)+
                                             +nvl(pta.i_tot_burdened_cost,0),
                                    0) * v_pool_percent ) )
                  from  pa_alloc_txn_accum_v pta  /* FP.M : Allocation Impact : pa_txn_accum pta */
                        /* pa_alloc_run_sources pars */ /* Loop thru pa_alloc_run_sources. Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id and Task_Id */
                 where  /* pars.rule_id       = p_rule_id
                   and  pars.run_id        = p_run_id
                   and  pars.exclude_flag  = 'N'
				   and  pta.project_id     = pars.project_id
                   and  pta.task_id        = pars.task_id
				   */   pta.project_id     = l_get_proj.project_id  /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id */
                   and  pta.task_id		   = l_get_proj.task_id  /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Task_Id */
                   and  pta.pa_period      = p_run_period
              group by
						/* Bug 3749469
					   pars.rule_id, pars.run_id, pars.line_num,pars.project_id,
                       pars.task_id,
					   */
					   l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
					   l_get_proj.task_id,
                        G_creation_date, G_created_by, G_last_update_date,
                        G_last_updated_by, G_last_update_login ;
				End Loop;
			   end if ;
           else
			  For l_get_proj in c_get_proj
				Loop
				  Insert into pa_alloc_run_source_det(
						 rule_id, run_id, line_num, project_id, task_id,
						 creation_date, created_by, last_update_date,
						 last_updated_by, last_update_login,
						 amount, eligible_amount)
				  select /* Bug 3749469
					   pars.rule_id, pars.run_id, pars.line_num,pars.project_id,
                       pars.task_id,
					   */
					   l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
					   l_get_proj.task_id,
						 G_creation_date, G_created_by, G_last_update_date,
						 G_last_updated_by, G_last_update_login ,
								 sum( decode (p_bal_type,
						'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
						'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
												 +nvl( pta.i_tot_billable_raw_cost,0),
						'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
												 +nvl( pta.i_tot_billable_burdened_cost,0),
						'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)+
												 +nvl(pta.i_tot_burdened_cost,0),
									  0 )),
								 pa_currency.round_currency_amt(sum( decode (p_bal_type,
						'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
						'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
												 +nvl( pta.i_tot_billable_raw_cost,0),
						'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
												 +nvl( pta.i_tot_billable_burdened_cost,0),
						'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)+
												 +nvl(pta.i_tot_burdened_cost,0),
										0) * v_pool_percent ) )
				   from  pa_alloc_txn_accum_v pta, /* FP.M : Allocation Impact : pa_txn_accum pta */
						 pa_periods   pp ,
						 pa_projects  P
						 /* pa_alloc_run_sources pars */ /* Loop thru pa_alloc_run_sources. Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id and Task_Id */
				  where  /* pars.rule_id       = p_rule_id
					and  pars.run_id        = p_run_id
					and  pars.exclude_flag  = 'N'
					and  pars.project_id    = p.project_id
					and  pta.project_id     = pars.project_id
					and  pta.task_id        = pars.task_id
						*/
					     pta.project_id     = l_get_proj.project_id /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id */
				    and  pta.task_id		= l_get_proj.task_id /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Task_Id */
					and  p.project_id       = l_get_proj.project_id
					and  pta.pa_period      = pp.period_name
	--                                Removed check for Project start date bug 1063600
	--              and  pp.end_date        >= p.start_date
					and  pp.end_date        <= v_run_period_end_date
			   group by /* Bug 3749469
					   pars.rule_id, pars.run_id, pars.line_num,pars.project_id,
                       pars.task_id,
					   */
					   l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
					   l_get_proj.task_id,
						 G_creation_date, G_created_by, G_last_update_date,
						 G_last_updated_by, G_last_update_login ;
				End Loop;
			End if ;
   End If ;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('cal_amounts_from_projects: ' || 'LOG', 'Amount type is '|| p_run_amount_type ||'--' || to_char(SQL%ROWCOUNT));
   END IF;
   pa_debug.G_err_stage := 'Getting pool amount from projects for run'||to_char(p_run_id) ;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('cal_amounts_from_projects: ' || 'LOG', pa_debug.G_Err_Stage);
   END IF;
   commit ;
   OPEN C_get_pool_amount ;
   Fetch C_get_pool_amount into x_proj_pool_amount ;
   close C_get_pool_amount ;
   pa_debug.reset_err_stack;
EXCEPTION
   WHEN OTHERS THEN
   RAISE;
END cal_amounts_from_projects ;
-- ============================================================
-- get_relative_period_name
-- ============================================================
PROCEDURE get_relative_period_name( p_period_set_name      IN VARCHAR2,
                                    p_period_type          IN VARCHAR2,
                                    p_run_period_end_date  IN DATE,
                                    p_run_period           IN VARCHAR2,
                                    p_relative_period      IN NUMBER,
                                    x_rel_period_name     OUT NOCOPY VARCHAR2 )
IS
   v_rel_period  NUMBER ;
   v_counter     NUMBER ;
   Cursor C_rel_period is
       select  period_name
         from  gl_periods glp
        where  glp.period_set_name  =  p_period_set_name
          and glp.period_type       =  p_period_type
          and glp.end_date         <=  p_run_period_end_date
          and glp.adjustment_period_flag <> 'Y' /* Added for Bug#2409474 */
     order by start_date desc ;
BEGIN
     pa_debug.set_err_stack('get_relative_period_name') ;
     pa_debug.G_err_stage := 'Fetching the Relative period name' ;
     IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('get_relative_period_name: ' || 'LOG', pa_debug.G_err_stage);
     END IF;
      v_rel_period := 1 + nvl(p_relative_period,0)* -1 ;
      v_counter    := 1 ;
     If v_rel_period > 0 then
        OPEN C_rel_period ;
        For V_counter in 1..v_rel_period LOOP
          FETCH C_rel_period INTO x_rel_period_name ;
          EXIT WHEN C_rel_period%NOTFOUND ;
        END LOOP ;
        If C_rel_period%NOTFOUND  then
           CLOSE C_rel_period ;
           alloc_errors(G_rule_id, G_alloc_run_id, 'R', 'E','PA_AL_NO_BASIS_RELATIVE_PERIOD',TRUE) ;
        End if ;
        CLOSE C_rel_period ;
      else
         x_rel_period_name := p_run_period;
      End if ;
        IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('get_relative_period_name: ' || 'LOG', 'Relative Period is '||x_rel_period_name);
        END IF;
        pa_debug.reset_err_stack;
EXCEPTION
   WHEN OTHERS THEN
     RAISE ;
END get_relative_period_name ;
-- ============================================================
-- insert_alloc_run_basis_det
-- ============================================================
PROCEDURE insert_alloc_run_basis_det( p_rule_id          IN NUMBER
                                  , p_run_id             IN NUMBER
                                  , p_line_num           IN NUMBER
                                  , p_project_id         IN NUMBER
                                  , p_task_id            IN NUMBER
                                  , p_rlm_id             IN NUMBER
                                  , p_amount             IN NUMBER
                                  , p_basis_percent      IN NUMBER
                                  , p_line_percent       IN NUMBER
                                  , p_creation_date      IN DATE
                                  , p_created_by         IN NUMBER
                                  , p_last_update_date   IN DATE
                                  , p_last_updated_by    IN NUMBER
                                  , p_last_update_login  IN NUMBER)
IS
BEGIN
  pa_debug.set_err_stack('insert_alloc_run_basis_det') ;
  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('insert_alloc_run_basis_det: ' || 'insert Basis record for task '||to_char(p_task_id)||':'||to_char(p_amount));
     pa_debug.write_file('insert_alloc_run_basis_det: ' || 'LOG', pa_debug.G_Err_Stage);
  END IF;
  pa_debug.G_err_stage := 'INSERTING PA_ALLOC_RUN_BASIS_DET' ;
  INSERT INTO PA_ALLOC_RUN_BASIS_DET (
     RUN_ID
   , RULE_ID
   , LINE_NUM
   , PROJECT_ID
   , TASK_ID
   , RESOURCE_LIST_MEMBER_ID
   , AMOUNT
   , BASIS_PERCENT
   , LINE_PERCENT
   , CREATION_DATE
   , CREATED_BY
   , LAST_UPDATE_DATE
   , LAST_UPDATED_BY
   , LAST_UPDATE_LOGIN )
  VALUES (
      p_run_id
    , p_rule_id
    , p_line_num
    , p_project_id
    , p_task_id
    , p_rlm_id
    , p_amount
    , p_basis_percent
    , p_line_percent
    , p_creation_date
    , p_created_by
    , p_last_update_date
    , p_last_updated_by
    , p_last_update_login ) ;
   /*  restore the old stack */
    pa_debug.reset_err_stack;
EXCEPTION
   WHEN OTHERS THEN
   pa_debug.reset_err_stack;
   RAISE;
END insert_alloc_run_basis_det ;
-- ============================================================
-- cal_proj_basis_amounts
-- ============================================================
PROCEDURE cal_proj_basis_amounts(p_rule_id          IN NUMBER,
                                 p_run_id           IN NUMBER,
                                 p_run_period_type  IN VARCHAR2,
                                 p_run_period       IN VARCHAR2,
                                 p_basis_method     IN OUT NOCOPY VARCHAR2, /* for bug 2182563 */
                                 p_basis_amt_type   IN VARCHAR2,
                                 P_basis_bal_type   IN VARCHAR2,
                                 P_basis_rel_period IN NUMBER,
                                 p_basis_category   IN VARCHAR2,
                                 p_basis_RL_id      IN NUMBER  ,
								 p_budget_type_code IN VARCHAR2,
                         		 x_proj_pool_amount OUT NOCOPY NUMBER ,
								 /* FP.M : Allocation Impact : Bug# 3512552 */
                                 p_basis_resource_struct_type in Varchar2 ,
								 p_basis_rbs_version_id in number
								 )
IS
/*---------- Logic--------------------------------------------------------------
 If basis_method  is Client extension
    get the basis amounts for target project and tasks using extension.
 Else
    Get  the  Period Year and Quarter Num values for the given Relative_period.
    If basis_resource_lists is not null then
       Populate  Include_RLM_tbl.
       For each resource list member in the Include_RLM_tbl Loop
          For Each project and task in pa_alloc_run_targets table Loop
        If Basis_category is 'ACTUALS' then
           Get the  basis amount using get_alloc_amounts( )
            Else
          Get the basis amount from get_budget_amounts()
            End if ;
          End Loop ;
       End Loop ;
     Else
      If basis_category is ACTUALS then
           For each project and task in  pa_alloc_run_targets
              find the basis amount at project and task level from pa_txn_accum
          and insert that into pa_alloc_run_basis_det.
         Else
           For each project and task in  pa_alloc_run_targets
              find the basis amount at project and task level from
              pa_base_budget_by_pa_period_v
              and insert that into pa_alloc_run_basis_det.
         End if.
     End if;
  End if
  Determine the basis_percent ;
---------------Logic ----------------------------------------------------------------- */
    v_period_type           VARCHAR2(15)  ;
    v_period_set_name       VARCHAR2 (15) ;
    v_period_year           NUMBER    ;
    v_quarter               NUMBER    ;
    v_period_num            NUMBER    ;
    v_run_period_end_date   DATE      ;
    v_amttype_start_date    DATE      ;
    v_resource_list_id      NUMBER    ;
    v_rlm_id                NUMBER ;
    v_rlm_percent           NUMBER ;
--  v_basis_rlm_tab         SRC_RLM_TABTYPE ; /* after fix for 2211234 this table is not required */
    v_line_num              NUMBER ;
    v_amount                NUMBER ;
    v_pool_amount           NUMBER ;
--  v_pool_percent          NUMBER ;
    v_basis_method         VARCHAR2(2) ;
    v_basis_amt_type       VARCHAR2(4) ;
    v_basis_bal_type       VARCHAR2(15) ;
    v_basis_rel_period     NUMBER     ;
    v_rel_period_name      VARCHAR2(15) ;
    v_rel_period_end_date  DATE      ;
   v_tot_basis_amt        NUMBER  ;
   v_max_basis_amt        NUMBER  ;    /* added for bug 1900331 */
   v_tot_basis_rec        NUMBER  ;    /* added for bug 1900331 */
   v_line_basis_amt       NUMBER  ;
   v_line_percent         NUMBER  ;
   v_line_max_amt         NUMBER  ;   /* added for bug 1900331 */
   v_line_count           NUMBER  ;   /* added for bug 1900331 */
   v_commit_count         NUMBER  ;   /* added for bug 2182563 */
   v_sum_tgt_pct          NUMBER ;
   v_status               NUMBER := NULL;
  v_err_message           VARCHAR2(250);
    cursor C_run_targets is
           Select  line_num, project_id , task_id, line_percent
             from  pa_alloc_run_targets
            where  rule_id   =  p_rule_id
             and   run_id    =  p_run_id
             and   exclude_flag  <> 'Y' ;
    cursor C_tot_basis_amt is
        select nvl(sum(nvl(amount,0)),0), nvl(max(nvl(amount,0)),0), count(1) /* 1900331 */
         from pa_alloc_run_basis_det
            where run_id = p_run_id ;
    cursor C_line_basis_amt is
        select line_num, line_percent, nvl(sum(nvl(amount,0)),0),  nvl(max(nvl(amount,0)),0), count(1) /* 1900331 */
         from pa_alloc_run_basis_det
            where run_id = p_run_id
        group by line_num, line_percent ;
    cursor C_tgt_line_pct is
        select sum((nvl(line_percent,0)))
          from pa_alloc_run_basis_det
         where run_id = p_run_id ;
	cursor c_get_proj is
		Select RUN_ID                 ,
			   RULE_ID                ,
			   LINE_NUM               ,
			   PROJECT_ID             ,
			   TASK_ID                ,
			   EXCLUDE_FLAG           ,
			   LINE_PERCENT           ,
			   BUDGET_VERSION_ID
		  From Pa_Alloc_Run_Targets
		 Where rule_id = p_rule_id
		   And run_id  = p_run_id
		   And Nvl(exclude_flag,'N') = 'N' ;
BEGIN
    v_basis_method     := p_basis_method ;
    v_resource_list_id := p_basis_RL_id  ;
    v_sum_tgt_pct      := 0 ;
       pa_debug.set_err_stack('Cal_proj_basis_amounts') ;
    If p_basis_method = 'C' then
       pa_debug.G_err_stage := 'Call basis client extension';
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG', pa_debug.G_Err_Stage);
       END IF;
       For run_targets_rec in C_run_targets LOOP
          pa_client_extn_alloc.basis_extn(p_rule_id, run_targets_rec.project_id,
                                    run_targets_rec.task_id, v_amount,v_status,v_err_message) ;
          IF nvl(v_status,0) <> 0 THEN
              v_err_message:=nvl(v_err_message,'PA_AL_CE_FAILED');
              alloc_errors(p_rule_id,p_run_id,'B','E',v_err_message,TRUE);
          END IF;
          insert_alloc_run_basis_det(
                    p_rule_id, p_run_id, run_targets_rec.line_num,
                    run_targets_rec.project_id, run_targets_rec.task_id,
                    v_rlm_id, nvl(v_amount,0), NULL, run_targets_rec.line_percent,
                    G_creation_date, G_created_by, G_last_update_date,
                    G_last_updated_by, G_last_update_login) ;
       End Loop ;
       Open C_tgt_line_pct ;
       Fetch C_tgt_line_pct into v_sum_tgt_pct  ;
       Close C_tgt_line_pct;
    elsif p_basis_method  in ( 'P', 'FP') then
       pa_debug.G_err_stage := 'Call get_fiscalyear_quarter';
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG', pa_debug.G_Err_Stage);
       END IF;
       get_fiscalyear_quarter(p_run_period_type, p_run_period, v_period_type,
                              v_period_set_name,
                              v_period_year, v_quarter, v_period_num,
                              v_run_period_end_date) ;
       pa_debug.G_err_stage := 'Calling get_relative_period_name' ;
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG', pa_debug.G_Err_Stage);
       END IF;
       get_relative_period_name(v_period_set_name, v_period_type, v_run_period_end_date,
                                p_run_period, p_basis_rel_period, v_rel_period_name ) ;
       pa_debug.G_err_stage := 'calling get_fiscalyear_quarter for relative period' ;
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG', pa_debug.G_Err_Stage);
       END IF;
       get_fiscalyear_quarter(p_run_period_type, v_rel_period_name, v_period_type,
                              v_period_set_name,
                              v_period_year, v_quarter, v_period_num,
                              v_rel_period_end_date) ;
       pa_debug.G_err_stage := 'calling get_amttype_start_date';
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG', pa_debug.G_Err_Stage);
       END IF;
       get_amttype_start_date( p_basis_amt_type, v_period_type,
                               v_period_set_name, v_rel_period_end_date,
                               v_quarter, v_period_year, p_run_period, v_amttype_start_date) ;
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG','amttype start date = '|| to_char(v_amttype_start_date));
          pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG','rel_period_end_date = '|| to_char(v_rel_period_end_date));
       END IF;
       If v_resource_list_id is NOT NULL then
          pa_debug.G_err_stage := 'Populating the Resource List Member array for basis  ' ;
          IF P_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG', pa_debug.G_Err_Stage);
          END IF;
          /* Bug 2211234 - added p_run_id.
                         - removed v_basis_rlm_tab
          this procedure will now insert into pa_alloc_run_resources_det */
          populate_RLM_table( p_rule_id,
							  p_run_id,
							  'B',
							  v_resource_list_id,
							  p_basis_resource_struct_type ,
						      p_basis_rbs_version_id ,
							  p_basis_category
							  ) ;
          pa_debug.G_err_stage := 'Processing project/Tasks to get resource level amounts';
          IF P_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG', pa_debug.G_Err_Stage);
          END IF;
/*   major changes done for actuals for performance improvements. No more a call to get_alloc_amount
     is made and bulk inserts are done in new procedure added insert_alloc_basis_resource
     These changes are not done for budgets as in budgets the volume of data should not be that high.
*/
          IF p_basis_category = 'A' THEN
                   /* Currenly we insert all project/tasks into pa_alloc_run_targets.
                      These do not get converted into final txns in case there are no basis existing
                      for these targets in summarization. We want to intelligently delete those data
                      from pa_alloc_run_targets table which do not contain any basis
                      amount. */
                   clean_up_targets_for_actuals(p_run_id               =>   p_run_id
                                               ,p_rule_id              =>   p_rule_id
                                               ,p_amt_type             =>   p_basis_amt_type
                                               ,p_run_period_type      =>   p_run_period_type
                                               ,p_period               =>   v_rel_period_name
                                               ,p_run_period_end_date  =>   v_rel_period_end_date
                                               ,p_amttype_start_date   =>   v_amttype_start_date
                                               ,p_basis_method         =>   v_basis_method
											   );
                   /* if basis method is not switched by the clean up targets process */
                   IF p_basis_method <> 'S' THEN
                      insert_alloc_basis_resource( p_run_id               =>   p_run_id
                                                  ,p_rule_id              =>   p_rule_id
                                                  ,p_resource_list_id     =>   v_resource_list_id
                                                  ,p_amt_type             =>   p_basis_amt_type
                                                  ,p_bal_type             =>   p_basis_bal_type
                                                  ,p_run_period_type      =>   p_run_period_type
                                                  ,p_period               =>   v_rel_period_name
                                                  ,p_run_period_end_date  =>   v_rel_period_end_date
                                                  ,p_amttype_start_date   =>   v_amttype_start_date
												  /* FP.M : Allocation Impact : Bug# 3512552 */
				                                  ,p_resource_struct_type => p_basis_resource_struct_type
												  ,p_rbs_version_id       => p_basis_rbs_version_id
												  );
                   END IF;
          ELSE /* for budgets */
          /* added for 2211234 */
                    insert_budget_basis_resource(p_run_id              =>   p_run_id
                                                ,p_rule_id             =>   p_rule_id
                                                ,p_run_period_type     =>   p_run_period_type
                                                ,p_bal_type            =>   p_basis_bal_type
                                                ,p_budget_type_code    =>   p_budget_type_code
                                                ,p_start_date          =>   v_amttype_start_date
                                                ,p_end_date            =>   v_rel_period_end_date
												,p_basis_resource_struct_Type => p_basis_resource_struct_type);
          /***2211234 - insert_budget_basis_resource will take care of this.
           ***    FOR  I in 1.. v_basis_rlm_tab.count   LOOP
           ***         v_rlm_id            :=  v_basis_rlm_tab (I).resource_list_member_id ;
           ***         pa_debug.write_file('LOG','Resource list member : '|| to_char(v_rlm_id) );
           ***
           ***         FOR run_targets_rec in C_run_targets  LOOP
           ***             get_budget_amounts( p_run_period_type, p_basis_bal_type,
           ***                                   run_targets_rec.project_id,
           ***                                  run_targets_rec.task_id,
           ***                                  v_resource_list_id, v_rlm_id,
           ***                                  p_budget_type_code, v_amttype_start_date,
           ***                                  v_rel_period_end_date, v_amount) ;
           ***             pa_debug.write_file('LOG','get_budget_amounts  '||'project: '
           ***                   ||to_char( run_targets_rec.project_id)||'
           ***                   task: '|| to_char( run_targets_rec.task_id)|| '
           ***                   Amt:'|| to_char(v_amount) );
           ***
           ***             IF (p_basis_method in ('P','FP') and nvl(v_amount,0) <> 0) then
           ***                     insert_alloc_run_basis_det(
           ***                         p_rule_id, p_run_id, run_targets_rec.line_num,
           ***                         run_targets_rec.project_id, run_targets_rec.task_id,
           ***                         v_rlm_id, nvl(v_amount,0), NULL, run_targets_rec.line_percent,
           ***                         G_creation_date, G_created_by, G_last_update_date,
           ***                         G_last_updated_by, G_last_update_login) ;
           ***             END IF;
           ***         END LOOP ;
           ***    END LOOP;
           ***/
          END IF ;
          COMMIT;
       Else
          If p_basis_category = 'A' then
             pa_debug.G_err_stage := 'Processing project/Tasks to get basis amounts' ;
             IF P_DEBUG_MODE = 'Y' THEN
                pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG', pa_debug.G_Err_Stage);
             END IF;
             If  p_basis_amt_type in ( 'FYTD','QTD')  then
                 IF P_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG','p_basis_amt_type' ||p_basis_amt_type);
                 END IF;
				For l_get_proj in c_get_proj
				Loop
							Insert into pa_alloc_run_basis_det (
							  rule_id, run_id, line_num, project_id, task_id,
							  line_percent, creation_date, created_by,
							  last_update_date, last_updated_by,
							  last_update_login, amount)
							select  /* Bug 3749469
									part.rule_id, part.run_id,  part.line_num, part.project_id,
									part.task_id, part.line_percent,
									*/
									l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
									l_get_proj.task_id, l_get_proj.line_percent,
									G_creation_date, G_created_by,
									G_last_update_date, G_last_updated_by, G_last_update_login ,
									sum( decode (p_basis_bal_type,
								'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
								'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
														 +nvl( pta.i_tot_billable_raw_cost,0),
								'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
														 +nvl( pta.i_tot_billable_burdened_cost,0),
								'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
														 +nvl(pta.i_tot_burdened_cost,0),
								'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
														 +nvl(pta.i_tot_labor_hours,0),
								'TOT_QUANTITY', nvl(pta.tot_quantity,0)
														 +nvl(pta.i_tot_quantity,0),
											  0 )) AMOUNT
							  from  pa_alloc_txn_accum_v  pta, /* FP.M : Allocation Impact : pa_txn_accum pta, */
			/* Commenting out pa_periods and using gl_period_statuses instead for bug 2757875 */
			--                      pa_periods   pp ,
									gl_period_statuses   gl,
									pa_implementations imp
									/* pa_alloc_run_targets part */ /* Loop thru pa_alloc_run_sources. Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id and Task_Id */
							 where  /* Bug 3749469 part.rule_id       = p_rule_id
							   and  part.run_id        = p_run_id
							   and  part.exclude_flag  = 'N'
							   and  pta.project_id     = part.project_id
							   and  pta.task_id        = part.task_id
							   */												/* added outer join for bug 1900331 */
																			  /* Removed Outer join for bug 2182563 */
							        pta.project_id     = l_get_proj.project_id /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id */
							   and  pta.task_id		   = l_get_proj.task_id /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id */
							   and  pta.gl_period	   = gl.period_name
							   and  gl.set_of_books_id  = imp.set_of_books_id
							   and  gl.application_id   = pa_period_process_pkg.application_id
							   and  gl.adjustment_period_flag = 'N'
							   and  gl.closing_status in ('C','F','O','P')
							   and  gl.end_date	  >= v_amttype_start_date
							   and  gl.end_date   <= v_rel_period_end_date
			--                 and  nvl(pta.pa_period,pp.period_name)   = pp.period_name /* bug 2121598 */
			--                 and  pp.end_date        >= v_amttype_start_date
			--                 and  pp.end_date        <= v_rel_period_end_date
						  group by
								    /* Bug 3749469
									part.rule_id, part.run_id,  part.line_num, part.project_id,
									part.task_id, part.line_percent,
									*/
									l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
									l_get_proj.task_id, l_get_proj.line_percent,
									G_creation_date, G_created_by,
									G_last_update_date,
									G_last_updated_by, G_last_update_login ;
				End Loop;
             elsif p_basis_amt_type = 'PTD' then
                 If p_run_period_type = 'GL' then
			   For l_get_proj in c_get_proj
				Loop
						   Insert into pa_alloc_run_basis_det (
							  rule_id, run_id, line_num, project_id, task_id,
							  line_percent, creation_date, created_by,
							  last_update_date, last_updated_by,
							  last_update_login, amount)
						   select  /* Bug 3749469
									part.rule_id, part.run_id,  part.line_num, part.project_id,
									part.task_id, part.line_percent,
									*/
									l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
									l_get_proj.task_id, l_get_proj.line_percent,
								   G_creation_date, G_created_by,
								   G_last_update_date, G_last_updated_by, G_last_update_login ,
								   sum( decode (p_basis_bal_type,
							'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
							'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
													 +nvl( pta.i_tot_billable_raw_cost,0),
							'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
													 +nvl( pta.i_tot_billable_burdened_cost,0),
							'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
													 +nvl(pta.i_tot_burdened_cost,0),
							'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
													 +nvl(pta.i_tot_labor_hours,0),
							'TOT_QUANTITY', nvl(pta.tot_quantity,0)
													 +nvl(pta.i_tot_quantity,0),
										  0 )) AMOUNT
							 from  pa_alloc_txn_accum_v  pta /* FP.M : Allocation Impact : pa_txn_accum pta, */
		-- Commented out pa_periods. Used the gl_periods column in pa_txn_accum table
		--                         pa_periods   pp
								   /* pa_alloc_run_targets part */ /* Loop thru pa_alloc_run_sources. Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id and Task_Id */
							where  /* Bug 3749469
							       part.rule_id       = p_rule_id
							  and  part.run_id        = p_run_id
							  and  part.exclude_flag  = 'N'
							  and  pta.project_id     = part.project_id
							  and  pta.task_id        = part.task_id
							  */
							  /* added outer join for bug 1900331 */
																		  /* Removed Outer join for bug 2182563 */
							       pta.project_id     = l_get_proj.project_id /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id */
							  and  pta.task_id        = l_get_proj.task_id /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Task_Id */
							  and  pta.gl_period      = v_rel_period_name
		--                    and  pta.pa_period      = pp.period_name
		--                    and  pp.gl_period_name  = v_rel_period_name
					 group by  /* Bug 3749469
									part.rule_id, part.run_id,  part.line_num, part.project_id,
									part.task_id, part.line_percent,
								*/
									l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
									l_get_proj.task_id, l_get_proj.line_percent,
							   G_creation_date, G_created_by,
							   G_last_update_date,
							   G_last_updated_by, G_last_update_login ;
				  End Loop;
				 Elsif p_run_period_type = 'PA' then
				For l_get_proj in c_get_proj
				Loop
						   Insert into pa_alloc_run_basis_det (
							   rule_id, run_id, line_num, project_id, task_id,
							   line_percent, creation_date, created_by,
							   last_update_date, last_updated_by,
							   last_update_login, amount)
						   select  /* Bug 3749469
									part.rule_id, part.run_id,  part.line_num, part.project_id,
									part.task_id, part.line_percent,
								*/
									l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
									l_get_proj.task_id, l_get_proj.line_percent,
								  G_creation_date, G_created_by,
								  G_last_update_date, G_last_updated_by,G_last_update_login,
								  sum( decode (p_basis_bal_type,
						'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
						'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
												 +nvl( pta.i_tot_billable_raw_cost,0),
						'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
												 +nvl( pta.i_tot_billable_burdened_cost,0),
						'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
												 +nvl(pta.i_tot_burdened_cost,0),
						'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
												 +nvl(pta.i_tot_labor_hours,0),
						'TOT_QUANTITY', nvl(pta.tot_quantity,0)
												 +nvl(pta.i_tot_quantity,0),
									  0 )) AMOUNT
							from  pa_alloc_txn_accum_v  pta /* FP.M : Allocation Impact : pa_txn_accum pta, */
								  /* pa_alloc_run_targets part */ /* Loop thru pa_alloc_run_sources. Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id and Task_Id */
						   where  /* Bug 3749469  part.rule_id       = p_rule_id
							 and  part.run_id        = p_run_id
							 and  part.exclude_flag  = 'N'
							 and  pta.project_id     = part.project_id
							 and  pta.task_id        = part.task_id
							  */ 							 /* added outer join for bug 1900331 */
																	  /* Removed Outer join for bug 2182563 */
							      pta.project_id     = l_get_proj.project_id /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id */
							 and  pta.task_id        = l_get_proj.task_id /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Task_Id */
							 and  pta.pa_period      = v_rel_period_name
						group by   /* Bug 3749469
									part.rule_id, part.run_id,  part.line_num, part.project_id,
									part.task_id, part.line_percent,
								*/
									l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
									l_get_proj.task_id, l_get_proj.line_percent,
								  G_creation_date, G_created_by,
								  G_last_update_date,
								  G_last_updated_by, G_last_update_login ;
				 End Loop;
                end if ;
			 Else   -- process for ITD amounts
				For l_get_proj in c_get_proj
				Loop
						Insert into pa_alloc_run_basis_det (
							 rule_id, run_id, line_num, project_id, task_id,
							 line_percent, creation_date, created_by,
							 last_update_date, last_updated_by,
							 last_update_login, amount)
						select /*+ORDERED*/ -- added ORDERED hint for bug 2751178
							    /* Bug 3749469
									part.rule_id, part.run_id,  part.line_num, part.project_id,
									part.task_id, part.line_percent,
								*/
								l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
								l_get_proj.task_id, l_get_proj.line_percent,
							   G_creation_date, G_created_by,
							   G_last_update_date, G_last_updated_by, G_last_update_login ,
							   sum( decode (p_basis_bal_type,
							'TOT_RAW_COST', nvl(pta.tot_raw_cost,0) +nvl( pta.i_tot_raw_cost,0),
							'TOT_BILLABLE_RAW_COST', nvl(pta.tot_billable_raw_cost,0)
													 +nvl( pta.i_tot_billable_raw_cost,0),
							'TOT_BILLABLE_BURDENED_COST', nvl(pta.tot_billable_burdened_cost,0)
													 +nvl( pta.i_tot_billable_burdened_cost,0),
							'TOT_BURDENED_COST', nvl(pta.tot_burdened_cost,0)
													 +nvl(pta.i_tot_burdened_cost,0),
							'TOT_LABOR_HOURS', nvl(pta.tot_labor_hours,0)
													 +nvl(pta.i_tot_labor_hours,0),
							'TOT_QUANTITY', nvl(pta.tot_quantity,0)
													 +nvl(pta.i_tot_quantity,0),
										  0 )) AMOUNT
				/* Rearranged the tables in the FROM clause and commented out pa_projects_all for bug 2751178 */
						 from  /* pa_alloc_run_targets part, */ /* Loop thru pa_alloc_run_sources. Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id and Task_Id */
							   pa_alloc_txn_accum_v  pta, /* FP.M : Allocation Impact : pa_txn_accum pta, */
							   pa_periods  pp
		--                     pa_projects_all   p  ,
						where  /* Bug 3749469
							   part.rule_id       = p_rule_id
						  and  part.run_id        = p_run_id
						  and  part.exclude_flag  = 'N'
		--                and  part.project_id    = p.project_id  --- Commented for bug 2751178
		                  and  pta.project_id     = part.project_id
						  and  pta.task_id        = part.task_id
						      */
						    /* added for bug 1900331 */
																   /* Removed Outer join for bug 2182563 */
						       pta.project_id     = l_get_proj.project_id /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id */
					      and  pta.task_id		  = l_get_proj.task_id /* Bug 3749469 : Performance with pa_alloc_txn_accum_v. Filter for Project_Id */
					/* Removed nvl for bug 2751178 */
		--                and  nvl(pta.pa_period,pp.period_name)   = pp.period_name /* bug 2121598 */
				  and  pta.pa_period = pp.period_name
		--                                Removed check for Project start date bug 1063600
		--                and  pp.end_date        >= p.start_date
						  and  pp.end_date        <= v_rel_period_end_date
					 group by  /* Bug 3749469
									part.rule_id, part.run_id,  part.line_num, part.project_id,
									part.task_id, part.line_percent,
							   */
							   l_get_proj.rule_id, l_get_proj.run_id,  l_get_proj.line_num, l_get_proj.project_id,
							   l_get_proj.task_id, l_get_proj.line_percent,
							   G_creation_date, G_created_by,
							   G_last_update_date,
							   G_last_updated_by, G_last_update_login ;
				End Loop;
             End if ;
          Else -- Processing the Budget amounts ...
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG','Inserting in basis_det from budgets');
       END IF;
             if p_basis_amt_type  = 'ITD' then
                Insert into pa_alloc_run_basis_det(
                       rule_id, run_id, line_num, project_id, task_id,
                       line_percent, creation_date, created_by, last_update_date,
                       last_updated_by, last_update_login, amount)
                select  part.rule_id, part.run_id,  part.line_num,
                        part.project_id, part.task_id,
                        part.line_percent, G_creation_date,
                        G_created_by, G_last_update_date,
                        G_last_updated_by, G_last_update_login ,
                        sum( decode (p_basis_bal_type,
                             'BASE_RAW_COST',       nvl(pfpp.raw_cost,0),
                             'BASE_BURDENED_COST',  nvl(pfpp.burdened_cost,0),
                             'BASE_QUANTITY',       nvl(pfpp.quantity,0),
                             'BASE_LABOR_QUANTITY', nvl(pfpp.labor_quantity,0),
                             0
                             ))
          /***    from  pa_base_budget_by_pa_period_v pbpp, *** commented bug 2619977 */
                  from  pa_base_finplan_by_pa_period_v pfpp, /* added bug 2619977 */
                        pa_projects_all   p  ,
                        pa_alloc_run_targets part
                 where  part.rule_id            = p_rule_id
                   and  part.run_id             = p_run_id
                   and  part.exclude_flag       = 'N'
                   and  part.project_id         = p.project_id
                   and  pfpp.project_id         = part.project_id
                   and  pfpp.task_id            = part.task_id
                   and  pfpp.budget_version_id  = part.budget_version_id /* added bug 2619977 */
         /***      and  pbpp.budget_type_code   = p_budget_type_code  *** commented bug 2619977 */
--                                Removed check for Project start date bug 1063600
--                 and  pfpp.Period_start_date >= p.start_date
                   and  pfpp.period_end_date   <= v_rel_period_end_date
              group by  part.rule_id, part.run_id, part.line_num,
                        part.project_id, part.task_id,
                        part.line_percent, G_creation_date, G_created_by,
                        G_last_update_date,
                        G_last_updated_by, G_last_update_login ;
             elsif p_basis_amt_type  in ('FYTD','QTD') then /* Added bug 2757875 */
                Insert into pa_alloc_run_basis_det(
                       rule_id, run_id, line_num, project_id, task_id,
                       line_percent, creation_date, created_by, last_update_date,
                       last_updated_by, last_update_login, amount)
                select  part.rule_id, part.run_id,  part.line_num,
                        part.project_id, part.task_id,
                        part.line_percent, G_creation_date,
                        G_created_by, G_last_update_date,
                        G_last_updated_by, G_last_update_login ,
                        sum( decode (p_basis_bal_type,
                             'BASE_RAW_COST',       nvl(pfpp.raw_cost,0),
                             'BASE_BURDENED_COST',  nvl(pfpp.burdened_cost,0),
                             'BASE_QUANTITY',       nvl(pfpp.quantity,0),
                             'BASE_LABOR_QUANTITY', nvl(pfpp.labor_quantity,0),
                             0
                             ))
          /***    from  pa_base_budget_by_pa_period_v pbpp, *** commented bug 2619977 */
          /****   from  pa_base_finplan_by_pa_period_v pfpp,  added bug 2619977. **** Commented bug 2757875*/
		        from  pa_base_finplan_by_gl_period_v pfpp, /* Added bug 2757875 */
                        pa_alloc_run_targets part
                 where  part.rule_id            = p_rule_id
                   and  part.run_id             = p_run_id
                   and  part.exclude_flag       = 'N'
                   and  pfpp.project_id         = part.project_id
                   and  pfpp.task_id            = part.task_id
                   and  pfpp.budget_version_id  = part.budget_version_id /* added bug 2619977 */
         /***      and  pbpp.budget_type_code   = p_budget_type_code  *** commented bug 2619977 */
         /****     and  pfpp.Period_start_date >= v_amttype_start_date *** Commented bug 2757875 */
	           and  pfpp.period_end_date   >= v_amttype_start_date /* Added bug 2757875 */
                   and  pfpp.period_end_date   <= v_rel_period_end_date
              group by  part.rule_id, part.run_id,  part.line_num,
                        part.project_id, part.task_id,
                        part.line_percent, G_creation_date, G_created_by,
                        G_last_update_date,
                        G_last_updated_by, G_last_update_login ;
/* Added the following code for bug 2757875 */
		   else -- process for PTD amounts
		      If p_run_period_type = 'GL' then
			    Insert into pa_alloc_run_basis_det(
                       rule_id, run_id, line_num, project_id, task_id,
                       line_percent, creation_date, created_by, last_update_date,
                       last_updated_by, last_update_login, amount)
                select  part.rule_id, part.run_id,  part.line_num,
                        part.project_id, part.task_id,
                        part.line_percent, G_creation_date,
                        G_created_by, G_last_update_date,
                        G_last_updated_by, G_last_update_login ,
                        sum( decode (p_basis_bal_type,
                             'BASE_RAW_COST',       nvl(pfgp.raw_cost,0),
                             'BASE_BURDENED_COST',  nvl(pfgp.burdened_cost,0),
                             'BASE_QUANTITY',       nvl(pfgp.quantity,0),
                             'BASE_LABOR_QUANTITY', nvl(pfgp.labor_quantity,0),
                             0
                             ))
                  from  pa_base_finplan_by_gl_period_v pfgp,
                        pa_alloc_run_targets part
                 where  part.rule_id            = p_rule_id
                   and  part.run_id             = p_run_id
                   and  part.exclude_flag       = 'N'
                   and  pfgp.project_id         = part.project_id
                   and  pfgp.task_id            = part.task_id
                   and  pfgp.budget_version_id  = part.budget_version_id
                   and  pfgp.gl_period_name	   = v_rel_period_name
              group by  part.rule_id, part.run_id,  part.line_num,
                        part.project_id, part.task_id,
                        part.line_percent, G_creation_date, G_created_by,
                        G_last_update_date,
                        G_last_updated_by, G_last_update_login ;
		      elsif p_run_period_type = 'PA' then
			       Insert into pa_alloc_run_basis_det(
                       rule_id, run_id, line_num, project_id, task_id,
                       line_percent, creation_date, created_by, last_update_date,
                       last_updated_by, last_update_login, amount)
                select  part.rule_id, part.run_id,  part.line_num,
                        part.project_id, part.task_id,
                        part.line_percent, G_creation_date,
                        G_created_by, G_last_update_date,
                        G_last_updated_by, G_last_update_login ,
                        sum( decode (p_basis_bal_type,
                             'BASE_RAW_COST',       nvl(pfpp.raw_cost,0),
                             'BASE_BURDENED_COST',  nvl(pfpp.burdened_cost,0),
                             'BASE_QUANTITY',       nvl(pfpp.quantity,0),
                             'BASE_LABOR_QUANTITY', nvl(pfpp.labor_quantity,0),
                             0
                             ))
                  from  pa_base_finplan_by_pa_period_v pfpp,
                        pa_alloc_run_targets part
                 where  part.rule_id            = p_rule_id
                   and  part.run_id             = p_run_id
                   and  part.exclude_flag       = 'N'
                   and  pfpp.project_id         = part.project_id
                   and  pfpp.task_id            = part.task_id
                   and  pfpp.budget_version_id  = part.budget_version_id
                   and  pfpp.pa_period          = v_rel_period_name
              group by  part.rule_id, part.run_id,  part.line_num,
                        part.project_id, part.task_id,
                        part.line_percent, G_creation_date, G_created_by,
                        G_last_update_date,
                        G_last_updated_by, G_last_update_login ;
		      end if; -- p_run_period_type
/* Code changes end for bug 2757875 */
             End if ;
---   Create Zero amount records for tasks that did not have budgets..
                Insert into pa_alloc_run_basis_det(
                      rule_id, run_id, line_num, project_id, task_id,
                      line_percent, creation_date, created_by, last_update_date,
                      last_updated_by, last_update_login, amount)
                select  part.rule_id, part.run_id,  part.line_num,
                        part.project_id, part.task_id,
                        part.line_percent, G_creation_date,
                        G_created_by, G_last_update_date,
                        G_last_updated_by, G_last_update_login ,
                        0
                  from  pa_alloc_run_targets part
                 where  part.rule_id            = p_rule_id
                   and  part.run_id             = p_run_id
                   and  part.exclude_flag       = 'N'
                   and  NOT EXISTS ( Select 'Exists'
                                       from  pa_alloc_run_basis_det parbd
                                      where  parbd.run_id = part.run_id
                                        and  parbd.project_id = part.project_id
                                        and  parbd.task_id    = part.task_id ) ;
          End if ; -- basis category
       End if ; -- For Resource list
    End if ; --- For basis_method
    /* added for bug 2182563. For FP insert one row per target with zero amount */
    IF p_basis_method  = 'FP' then
       /* First delete any records that are existing in the table 'pa_alloc_run_basis_det'
          with amount = 0. so that the following insert does not insert any duplicate
          records into the table if there is a record already existing with amount = 0 */
               DELETE FROM PA_ALLOC_RUN_BASIS_DET
                WHERE rule_id = p_rule_id
                  AND run_id  = p_run_id
                  AND nvl(amount,0)  = 0;
       /* we need to insert rows for a run_id/line_num only if there are no records in
          in basis table for that run_id and line number with amount <> 0. Because in this
          case the program has function like basis_method = 'FS' for that target line. */
                Insert into pa_alloc_run_basis_det (
                  rule_id, run_id, line_num, project_id, task_id,
                  line_percent, creation_date, created_by,
                  last_update_date, last_updated_by,
                  last_update_login, amount)
                select  part.rule_id, part.run_id,  part.line_num, part.project_id,
                        part.task_id, part.line_percent, G_creation_date, G_created_by,
                        G_last_update_date, G_last_updated_by, G_last_update_login ,
                        0 AMOUNT
                  from  pa_alloc_run_targets part
                 where  part.rule_id       = p_rule_id
                   and  part.run_id        = p_run_id
                   and  part.exclude_flag  = 'N'
                   and  not exists
                        (select null
                           from pa_alloc_run_basis_det parb
                          where parb.run_id = part.run_id
                            and parb.line_num = part.line_num
                            and parb.amount <> 0);
    END IF;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG', 'No of Records Inserted in basis details'||
                      to_char(SQL%ROWCOUNT));
   END IF;
   pa_debug.G_err_stage := 'Calculating basis percent' ;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG', pa_debug.G_Err_Stage);
   END IF;
   pa_debug.G_err_stage := 'Getting Basis total for Method:'||p_basis_method ;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG', pa_debug.G_Err_Stage);
   END IF;
  If ((p_basis_method = 'P') or (p_basis_method ='C' and v_sum_tgt_pct = 0) ) then
     OPEN C_tot_basis_amt ;
     FETCH C_tot_basis_Amt INTO v_tot_basis_amt , v_max_basis_amt, v_tot_basis_rec; /* 1900331 */
     IF C_tot_basis_amt%NOTFOUND then
         /* 2182563 - this should be a warning and not an error. A different warning needs to be
            created */
         alloc_errors(p_rule_id, p_run_id, 'B', 'E','PA_AL_NO_BASIS_FOUND',FALSE) ;
         /* add different warning to say that it will be spread evenly */
     END IF ;
     If nvl(v_tot_basis_amt,0) = 0 and nvl(v_max_basis_amt,0) <> 0 then /* 1900331 */
        alloc_errors(p_rule_id, p_run_id, 'B', 'E','PA_AL_ZERO_BASIS',TRUE) ;
     Else
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG','Basis_amount :'||to_char(v_tot_basis_amt) );
       END IF;
     End if;
     Close C_tot_basis_amt ;
    if nvl(v_tot_basis_amt,0) <> 0 then   /* added for 1900331 */
       UPDATE pa_alloc_run_basis_det
       SET basis_percent = decode(nvl(amount,0), 0, 0, amount*100/v_tot_basis_amt)
       WHERE run_id = p_run_id ;
    else
      /* for bug 2182563. Change the basis method to 'S' and return to main program */
       p_basis_method := 'S';
      /* bug 1900331 prorate equally */
      /* commented for 2182563
       UPDATE pa_alloc_run_basis_det
       SET basis_percent = 100/v_tot_basis_rec
       WHERE run_id = p_run_id ;
      */
    end if;
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG','No of Records Updated : '|| to_char(SQL%ROWCOUNT));
    END IF;
  Elsif ((p_basis_method = 'FP') or (p_basis_method ='C' and v_sum_tgt_pct = 100)) then
    OPEN C_line_basis_amt;
    LOOP
     Fetch C_line_basis_amt into v_line_num, v_line_percent, v_line_basis_amt, v_line_max_amt, v_line_count; /* 1900331 */
    EXIT when c_line_basis_amt%NOTFOUND ;
     If ( nvl(v_line_basis_amt,0) = 0 and nvl(v_line_percent,0) > 0 and nvl(v_line_max_amt,0) <> 0 ) then /* 1900331 */
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('cal_proj_basis_amounts: ' || 'LOG','basis amount  is zero for target line '||
                         to_char(v_line_num) );
      END IF;
         alloc_errors(p_rule_id, p_run_id, 'B', 'E','PA_AL_LINE_BASIS_AMT_IS_ZERO',TRUE) ;
      End if;
    if nvl(v_line_basis_amt,0) <> 0 then /* added for bug 1900331 */
    UPDATE pa_alloc_run_basis_det
      SET basis_percent = decode(nvl(amount,0), 0, 0, amount*100/v_line_basis_amt)
       WHERE run_id = p_run_id
      AND line_num = v_line_num ;
    else
      /* 1900331 - prorate equaly within the same target line */
      UPDATE pa_alloc_run_basis_det
      SET basis_percent = 100/v_line_count
       WHERE run_id = p_run_id
      AND line_num = v_line_num ;
    end if;
    END LOOP ;
     IF C_line_basis_amt%ROWCOUNT = 0 then
       alloc_errors(p_rule_id, p_run_id, 'B', 'E','PA_AL_NO_BASIS_FOUND',TRUE) ;
     End If ;
     Close C_line_basis_amt ;
   End If ;
   pa_debug.reset_err_stack;
EXCEPTION
   WHEN OTHERS THEN
--    pa_debug.reset_err_stack;
   RAISE;
END cal_proj_basis_amounts ;
/* following procedure is obsoleted (not in use after fix for 2211234 */
/***-- ============================================================
 ***-- get_budget_amounts
 ***-- ============================================================
 ***PROCEDURE get_budget_amounts( p_run_period_type     IN VARCHAR2,
 ***                              p_bal_type            IN VARCHAR2,
 ***                              p_project_id          IN NUMBER  ,
 ***                              p_task_id             IN NUMBER  ,
 ***                              p_rl_id               IN NUMBER  ,
 ***                              p_rlm_id              IN NUMBER  ,
 ***                              p_budget_type_code    IN VARCHAR2,
 ***                              p_start_date          IN DATE ,
 ***                              p_end_date            IN DATE ,
 ***                              x_amount              OUT NOCOPY NUMBER  )
 ***IS
 ***     v_project_start_date  DATE ;
 ***
 ***     cursor C_budget_amt_by_pa_period is
 ***        select nvl(sum( decode (p_bal_type,
 ***                    'BASE_RAW_COST',       nvl(pbpp.raw_cost,0),
 ***                    'BASE_BURDENED_COST',  nvl(pbpp.burdened_cost,0),
 ***                    'BASE_QUANTITY',       nvl(pbpp.quantity,0),
 ***                    'BASE_LABOR_QUANTITY', nvl(pbpp.labor_quantity,0),
 ***                    0
 ***                    )),0)
 ***         from pa_base_budget_by_pa_period_v  pbpp
 ***        where pbpp.Resource_list_id        = p_rl_id
 ***          and pbpp.Resource_list_member_id = p_rlm_id
 ***          and pbpp.Project_id              = p_project_id
 ***          and pbpp.task_id                 = p_task_id
 ***          and pbpp.budget_type_code        = p_budget_type_code
 ***          and pbpp.period_start_date      >= nvl(p_start_date,pbpp.period_start_date)
 ***          and pbpp.period_end_date        <= p_end_date ;
 ***
 ***     cursor C_budget_amt_by_gl_period is
 ***        select nvl(sum( decode (p_bal_type,
 ***                    'BASE_RAW_COST',       nvl(pbpg.raw_cost,0),
 ***                    'BASE_BURDENED_COST',  nvl(pbpg.burdened_cost,0),
 ***                    'BASE_QUANTITY',       nvl(pbpg.quantity,0),
 ***                    'BASE_LABOR_QUANTITY', nvl(pbpg.labor_quantity,0),
 ***                    0
 ***                    )),0)
 ***         from pa_base_budget_by_gl_period_v  pbpg
 ***        where pbpg.Resource_list_id        = p_rl_id
 ***          and pbpg.Resource_list_member_id = p_rlm_id
 ***          and pbpg.Project_id              = p_project_id
 ***          and pbpg.task_id                 = p_task_id
 ***          and pbpg.budget_type_code        = p_budget_type_code
 ***          and pbpg.period_start_date      >= nvl(p_start_date, pbpg.period_start_date)
 ***          and pbpg.period_end_date        <= p_end_date ;
 ***BEGIN
 ***     If p_run_period_type = 'PA' then
 ***        OPEN C_budget_amt_by_pa_period ;
 ***        FETCH C_budget_amt_by_pa_period into x_amount ;
 ***        If C_budget_amt_by_pa_period%NOTFOUND  then
 ***        pa_debug.write_file('LOG','No data found');
 ***            x_amount := 0 ;
 ***        End if ;
 ***        CLOSE C_budget_amt_by_pa_period ;
 ***
 ***     Elsif  p_run_period_type = 'GL' then
 ***        OPEN C_budget_amt_by_gl_period ;
 ***        FETCH C_budget_amt_by_gl_period into x_amount ;
 ***        If C_budget_amt_by_gl_period%NOTFOUND  then
 ***            x_amount := 0 ;
 ***        End if ;
 ***        CLOSE C_budget_amt_by_gl_period ;
 ***     End if ;
 ***EXCEPTION
 ***    WHEN OTHERS THEN
 ***       RAISE ;
 ***END get_budget_amounts ;
 ***/
-- ==========================================================================
/* PROCEDURE :  clean_up_targets_for_actuals
   Purpose   :  Deletes records from pa_alloc_run_targets which do not contain
                any Basis amount. The addition of this procedure does not
                modify the existing flow. This procedure has been added to
                delete unnecessary records from pa_alloc_run_targets for
                performance reasons. So, removing this procedure will not impact
                the existing flow of Allocations.
   Created   :  18-feb-02 Praveen for Bug #2222280
*/
-- ==========================================================================
PROCEDURE clean_up_targets_for_actuals(
                            p_run_id              IN NUMBER,
                            p_rule_id             IN NUMBER,
                            p_amt_type            IN VARCHAR2,
                            p_run_period_type     IN VARCHAR2,
                            p_period              IN VARCHAR2,
                            p_run_period_end_date IN DATE ,
                            p_amttype_start_date  IN DATE,
                            p_basis_method        IN OUT NOCOPY VARCHAR2
                            )
IS
     cursor c_target_lines is
     select line_num
       from pa_alloc_target_lines patl
      where rule_id = p_rule_id;
     v_commit_count NUMBER ;
     v_do_commit    VARCHAR2(1);
BEGIN
     pa_debug.G_err_stage:= 'INSIDE CLEAN_UP_TARGETS_FOR_ACTUALS procedure';
     IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', pa_debug.G_err_stage);
     END IF;
     IF p_amt_type in ( 'FYTD', 'QTD') THEN
          pa_debug.G_err_stage:= 'Deleting data from PA_Alloc_Run_Targets for FYTD or QTD';
          IF P_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', pa_debug.G_err_stage);
          END IF;
          v_commit_count := 0;
          IF p_basis_method = 'P' THEN
               SAVEPOINT delete_unwanted_targets;
	       /*For Bug 5403833*/
               DELETE FROM pa_alloc_run_targets part
                WHERE part.run_id = p_run_id
                  AND part.exclude_flag = 'N' /* we want to delete only exclude flag 'N' targets */
                  AND not exists
                      (select null
                         from pa_txn_accum pta,pa_periods pp
                        where pta.project_id = part.project_id
                          and pta.task_id = part.task_id
                            and pp.period_name = pta.pa_period
                            and pp.end_date between p_amttype_start_date
                                                and p_run_period_end_date);
               IF P_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Deleted '||sql%rowcount||' records');
               END IF;
               BEGIN
                       select 'Y'
                         into v_do_commit
                         from dual
                        where exists
                             (select null
                                from pa_alloc_run_targets part
                               where part.run_id = p_run_id
                                 and part.exclude_flag = 'N'
                                 and rownum = 1);
                       /* We will commit if any records are still there in targets table.
                          If all the records are deleted then we will need these records
                          to do spread evenly.
                       */
                          COMMIT;
                          IF P_DEBUG_MODE = 'Y' THEN
                             pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Committed the deletion');
                          END IF;
               EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                          /* switch the basis method to 'S' in case all records are deleted.
                             We need to do rollback also
                          */
                          ROLLBACK TO delete_unwanted_targets;
                          IF P_DEBUG_MODE = 'Y' THEN
                             pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Rolled back the deletion');
                          END IF;
                          p_basis_method := 'S';
               END;
          elsif p_basis_method = 'FP' then
               FOR c_target_lines_rec in c_target_lines LOOP
                    SAVEPOINT delete_unwanted_targets;
		    /* For Bug 5403833 */
                    DELETE FROM pa_alloc_run_targets part
                     WHERE part.run_id = p_run_id
                       AND part.exclude_flag = 'N' /* we want to delete only exclude flag 'N' targets */
                       AND part.line_num = c_target_lines_rec.line_num
                       AND not exists
                           (select null
                              from pa_txn_accum pta,pa_periods pp
                             where pta.project_id = part.project_id
                               and pta.task_id = part.task_id
                               and pp.period_name = pta.pa_period
                               and pp.end_date between p_amttype_start_date
                               and p_run_period_end_date);

                    IF P_DEBUG_MODE = 'Y' THEN
                       pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Deleted '||sql%rowcount||' records');
                    END IF;
              BEGIN
                       select 'Y'
                         into  v_do_commit
                         from dual
                        where exists
                             (select null
                                from pa_alloc_run_targets part
                               where part.run_id = p_run_id
                                 and part.exclude_flag = 'N'
                                 and line_num = c_target_lines_rec.line_num
                                 and rownum = 1);
                       /* We will commit if any records are still there in targets table.
                          If all the records are deleted then we will need these records
                          to do spread evenly.
                          No switch of basis method can be done in case of FP.
                       */
                          COMMIT;
                          IF P_DEBUG_MODE = 'Y' THEN
                             pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Committed the deletion');
                          END IF;
               EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                          ROLLBACK TO delete_unwanted_targets;
                          IF P_DEBUG_MODE = 'Y' THEN
                             pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Rolled back the deletion');
                          END IF;
               END;
               end loop;
          END IF;
     ELSIF  p_amt_type = 'PTD' THEN
          pa_debug.G_err_stage:= 'Deleting data from PA_Alloc_Run_Targets for PTD';
          IF P_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', pa_debug.G_err_stage);
          END IF;
          v_commit_count := 0;
          IF p_basis_method = 'P' THEN
             IF p_run_period_type = 'PA' THEN
               IF P_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Deleting for Period_Type = PA');
               END IF;
               SAVEPOINT delete_unwanted_targets;
               DELETE FROM pa_alloc_run_targets part
                WHERE part.run_id = p_run_id
                  AND part.exclude_flag = 'N' /* we want to delete only exclude flag 'N' targets */
                  AND not exists
                      (select null
                         from pa_txn_accum pta
                        where pta.project_id = part.project_id
                          and pta.task_id = part.task_id
                          and pta.pa_period = p_period
                          and rownum = 1
                      );
               IF P_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Deleted '||sql%rowcount||' records');
               END IF;
               BEGIN
                       select 'Y'
                         into v_do_commit
                         from dual
                        where exists
                             (select null
                                from pa_alloc_run_targets part
                               where part.run_id = p_run_id
                                 and part.exclude_flag = 'N'
                                 and rownum = 1);
                       /* We will commit if any records are still there in targets table.
                          If all the records are deleted then we will need these records
                          to do spread evenly.
                       */
                          COMMIT;
                          IF P_DEBUG_MODE = 'Y' THEN
                             pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Committed the deletion');
                          END IF;
               EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          /* switch the basis method to 'S' in case all records are deleted.
                             We need to do rollback also
                          */
                          ROLLBACK TO delete_unwanted_targets;
                          IF P_DEBUG_MODE = 'Y' THEN
                             pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Rolled back the deletion');
                          END IF;
                          p_basis_method := 'S';
               END;
             ELSE /* if p_run_period_type = GL */
               IF P_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Deleting for Period_Type = GL');
               END IF;
               SAVEPOINT delete_unwanted_targets;

              /*For Bug 5403833*/

               DELETE FROM pa_alloc_run_targets part
                WHERE part.run_id = p_run_id
                  AND part.exclude_flag = 'N' /* we want to delete only exclude flag 'N' targets */
                  AND not exists
                      (select null
                         from pa_txn_accum pta,pa_periods pp
                        where pta.project_id = part.project_id
                          and pta.task_id = part.task_id
                          and pp.period_name = pta.pa_period
                          and pp.gl_period_name = p_period);

               IF P_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Deleted '||sql%rowcount||' records');
               END IF;
               BEGIN
                       select 'Y'
                         into v_do_commit
                         from dual
                        where exists
                             (select null
                                from pa_alloc_run_targets part
                               where part.run_id = p_run_id
                                 and part.exclude_flag = 'N'
                                 and rownum = 1);
                       /* We will commit if any records are still there in targets table.
                          If all the records are deleted then we will need these records
                          to do spread evenly.
                       */
                          IF P_DEBUG_MODE = 'Y' THEN
                             pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Committed the deletion');
                          END IF;
                          COMMIT;
               EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          /* swith the basis method to 'S' in case all records are deleted
                             we need to do rollback also
                          */
                          ROLLBACK TO delete_unwanted_targets;
                          IF P_DEBUG_MODE = 'Y' THEN
                             pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Rolled back the deletion');
                          END IF;
                          p_basis_method := 'S';
               END;
             END IF; /* p_run_period_type = 'PA' */
          elsif p_basis_method = 'FP' then
             IF p_run_period_type = 'PA' THEN
               IF P_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Deleting for Period_Type = PA');
               END IF;
               FOR c_target_lines_rec in c_target_lines LOOP
                    SAVEPOINT delete_unwanted_targets;
                    DELETE FROM pa_alloc_run_targets part
                     WHERE part.run_id = p_run_id
                       AND part.exclude_flag = 'N' /* we want to delete only exclude flag 'N' targets */
                       AND part.line_num = c_target_lines_rec.line_num
                       AND not exists
                           (select null
                              from pa_txn_accum pta
                             where pta.project_id = part.project_id
                               and pta.task_id = part.task_id
                               and pta.pa_period = p_period
                               and rownum = 1
                           );
                    IF P_DEBUG_MODE = 'Y' THEN
                       pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Deleted '||sql%rowcount||' records');
                    END IF;
                    BEGIN
                            select 'Y'
                             into  v_do_commit
                              from dual
                             where exists
                                  (select null
                                     from pa_alloc_run_targets part
                                    where part.run_id = p_run_id
                                      and part.exclude_flag = 'N'
                                      and line_num = c_target_lines_rec.line_num
                                      and rownum = 1);
                            /* We will commit if any records are still there in targets table.
                               If all the records for the line are deleted then we will need
                               these records to do spread evenly.
                               No switch of basis method can be done in case of FP.
                            */
                               COMMIT;
                               IF P_DEBUG_MODE = 'Y' THEN
                                  pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Committed the deletion');
                               END IF;
                    EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                               ROLLBACK TO delete_unwanted_targets;
                               IF P_DEBUG_MODE = 'Y' THEN
                                  pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Rolled back the deletion');
                               END IF;
                    END;
               end loop;
             ELSE /* p_run_period_type = 'GL' */
               IF P_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Deleting for Period_Type = GL');
               END IF;
               FOR c_target_lines_rec in c_target_lines LOOP
                    SAVEPOINT delete_unwanted_targets;
		    /*For Bug 5403833 */
                    DELETE FROM pa_alloc_run_targets part
                     WHERE part.run_id = p_run_id
                       AND part.exclude_flag = 'N' /* we want to delete only exclude flag 'N' targets */
                       AND part.line_num = c_target_lines_rec.line_num
                       AND not exists
                           (select null
                              from pa_txn_accum pta,pa_periods pp
                             where pta.project_id = part.project_id
                               and pta.task_id = part.task_id
                               and pp.period_name = pta.pa_period
                               and pp.gl_period_name = p_period
                           );
                    IF P_DEBUG_MODE = 'Y' THEN
                       pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Deleted '||sql%rowcount||' records');
                    END IF;
                    BEGIN
                            select 'Y'
                             into  v_do_commit
                              from dual
                             where exists
                                  (select null
                                     from pa_alloc_run_targets part
                                    where part.run_id = p_run_id
                                      and part.exclude_flag = 'N'
                                      and line_num = c_target_lines_rec.line_num
                                      and rownum = 1);
                            /* We will commit if any records are still there in targets table.
                               If all the records for the line are deleted then we will need
                               these records to do spread evenly.
                               No switch of basis method can be done in case of FP.
                            */
                               COMMIT;
                               IF P_DEBUG_MODE = 'Y' THEN
                                  pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Committed the deletion');
                               END IF;
                    EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                               ROLLBACK TO delete_unwanted_targets;
                               IF P_DEBUG_MODE = 'Y' THEN
                                  pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Rolled back the deletion');
                               END IF;
                    END;
               end loop;
             END IF; /* p_run_period_type = 'GL' */
          END IF;
     ELSIF p_amt_type = 'ITD' THEN
         /* For ITD let's consider all periods in pa_periods table rather than
            doing this delete for each project id in the targets table. Hence do
            not use pa_periods table in this case. */
          pa_debug.G_err_stage:= 'Deleting data from PA_Alloc_Run_Targets for ITD';
          IF P_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', pa_debug.G_err_stage);
          END IF;
          v_commit_count := 0;
          IF p_basis_method = 'P' THEN
               SAVEPOINT delete_unwanted_targets;
               DELETE FROM pa_alloc_run_targets part
                WHERE part.run_id = p_run_id
                  AND part.exclude_flag = 'N' /* we want to delete only exclude flag 'N' targets */
                  AND not exists
                      (select null
                         from pa_txn_accum pta
                        where pta.project_id = part.project_id
                          and pta.task_id = part.task_id
                          and rownum = 1
                      );
               IF P_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Deleted '||sql%rowcount||' records');
               END IF;
               BEGIN
                       select 'Y'
                         into v_do_commit
                         from dual
                        where exists
                             (select null
                                from pa_alloc_run_targets part
                               where part.run_id = p_run_id
                                 and part.exclude_flag = 'N'
                                 and rownum = 1);
                       /* We will commit if any records are still there in targets table.
                          If all the records are deleted then we will need these records
                          to do spread evenly.
                       */
                          IF P_DEBUG_MODE = 'Y' THEN
                             pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Committed the deletion');
                          END IF;
                          COMMIT;
               EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          /* swith the basis method to 'S' in case all records are deleted
                             we need to do rollback also
                          */
                          ROLLBACK TO delete_unwanted_targets;
                          IF P_DEBUG_MODE = 'Y' THEN
                             pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', 'Rolled back the deletion');
                          END IF;
                          p_basis_method := 'S';
               END;
          elsif p_basis_method = 'FP' then
               FOR c_target_lines_rec in c_target_lines LOOP
                    SAVEPOINT delete_unwanted_targets;
                    DELETE FROM pa_alloc_run_targets part
                     WHERE part.run_id = p_run_id
                       AND part.exclude_flag = 'N' /* we want to delete only exclude flag 'N' targets */
                       AND part.line_num = c_target_lines_rec.line_num
                       AND not exists
                           (select null
                              from pa_txn_accum pta
                             where pta.project_id = part.project_id
                               and pta.task_id = part.task_id
                               and rownum = 1
                           );
                    BEGIN
                            select 'Y'
                             into  v_do_commit
                              from dual
                             where exists
                                  (select null
                                     from pa_alloc_run_targets part
                                    where part.run_id = p_run_id
                                      and part.exclude_flag = 'N'
                                      and line_num = c_target_lines_rec.line_num
                                      and rownum = 1);
                            /* We will commit if any records are still there in targets table.
                               If all the records for the line are deleted then we will need
                               these records to do spread evenly.
                               No switch of basis method can be done in case of FP.
                            */
                               COMMIT;
                    EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                               ROLLBACK TO delete_unwanted_targets;
                    END;
               end loop;
          END IF;
     END IF ;
     pa_debug.G_err_stage:= 'exiting clean_up_targets_for_actuals';
     IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('clean_up_targets_for_actuals: ' ||  'LOG', pa_debug.G_err_stage);
     END IF;
EXCEPTION
    WHEN OTHERS THEN
       RAISE ;
END clean_up_targets_for_actuals;
-- ------------------------------------------------------------
-- lock_rule
-- ------------------------------------------------------------
PROCEDURE lock_rule( p_rule_id  IN NUMBER
                    ,p_run_id   IN NUMBER )
IS
BEGIN
   pa_debug.G_err_stage := 'Acquiring lock  on the rule ' ;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('lock_rule: ' || 'LOG',pa_debug.G_err_stage);
   END IF;
   --Added this If and the else part for capital project changes
   IF p_rule_id <> -1 THEN
         If pa_debug.Acquire_user_lock( 'PA_AL_'||to_char(p_rule_id)) <> 0  then
          G_fatal_err_found:= TRUE;
          pa_alloc_run.ins_alloc_exceptions( p_rule_id, p_run_id, G_creation_date,
                                G_created_by, G_last_update_date,
                                G_last_updated_by, G_last_update_login,
                                'R', 'E', NULL, NULL, 'PA_AL_CANT_ACQUIRE_LOCK');
          end if;
   ELSE
         If pa_debug.Acquire_user_lock( 'PA_CINT_'||to_char(p_run_id)) <> 0  then
          G_fatal_err_found:= TRUE;
          pa_alloc_run.ins_alloc_exceptions( p_rule_id, p_run_id, G_creation_date,
                                G_created_by, G_last_update_date,
                                G_last_updated_by, G_last_update_login,
                                'R', 'E', NULL, NULL, 'PA_CINT_CANT_ACQUIRE_LOCK');
         END IF;
   END IF ;
EXCEPTION
    WHEN OTHERS THEN
    RAISE ;
END lock_rule ;
-- ------------------------------------------------------------
-- unlock_rule
-- ------------------------------------------------------------
PROCEDURE unlock_rule( p_rule_id  IN NUMBER
                    ,p_run_id   IN NUMBER  )
IS
BEGIN
   pa_debug.G_err_stage := 'unlock the  rule ' ;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('unlock_rule: ' || 'LOG',pa_debug.G_err_stage);
   END IF;
   IF p_rule_id <> -1 THEN
         If pa_debug.Release_user_lock(  'PA_AL_'||to_char(p_rule_id)) <> 0  then
          G_fatal_err_found:= TRUE;
          pa_alloc_run.ins_alloc_exceptions( p_rule_id, p_run_id, G_creation_date,
                                G_created_by, G_last_update_date,
                                G_last_updated_by, G_last_update_login,
                                'R', 'E', NULL, NULL, 'PA_AL_LOCK_RELEASE_FAILED');
          end if;
   ELSE
         If pa_debug.Release_user_lock(  'PA_CINT_'||to_char(p_run_id)) <> 0  then
          G_fatal_err_found:= TRUE;
          pa_alloc_run.ins_alloc_exceptions( p_rule_id, p_run_id, G_creation_date,
                                G_created_by, G_last_update_date,
                                G_last_updated_by, G_last_update_login,
                                'R', 'E', NULL, NULL, 'PA_CINT_LOCK_RELEASE_FAILED');
         End If;
   End If ;
EXCEPTION
    WHEN OTHERS THEN
    RAISE ;
END unlock_rule ;
-- ------------------------------------------------------------
-- Release_alloc_txns
-- ------------------------------------------------------------
PROCEDURE Release_alloc_txns( p_rule_id  IN NUMBER
                             ,p_run_id   IN  NUMBER
                             , x_retcode OUT NOCOPY VARCHAR2
                             , x_errbuf  OUT NOCOPY VARCHAR2
                            )
IS
   Cursor C_run is
    Select  denom_currency_code
          , target_exp_type_class
          , offset_exp_type_class
          , target_exp_org_id
          , offset_exp_org_id
          , target_exp_type
          , offset_exp_type
          , trunc(expnd_item_date)  expnd_item_date
          , offset_method
      from  pa_alloc_runs
     where  run_id = p_run_id ;
   cursor C_org_id is
    select org_id
      from pa_implementations ;
   run_rec   C_run%ROWTYPE ;
   v_import_failed    VARCHAR2(1) ;
   v_org_id           NUMBER ;
   /* Bug No:- 2487147, UTF8 change : changed  v_target_expnd_org to %TYPE */
   /* v_target_expnd_org VARCHAR2(60) ; */
   v_target_expnd_org   hr_organization_units.name%TYPE;
   /* Bug No:- 2487147, UTF8 change : changed v_offset_expnd_org to %TYPE */
   /* v_offset_expnd_org VARCHAR2(60) ; */
   v_offset_expnd_org   hr_organization_units.name%TYPE;
   v_target_exp_type_class VARCHAR2(30) ;
   v_offset_exp_type_class VARCHAR2(30) ;
   v_expnd_end_date   DATE ;
   v_interface_id     NUMBER ;
   v_batch_name       PA_TRANSACTION_INTERFACE_ALL.BATCH_NAME%TYPE ;
   v_tgt_exp_group    PA_EXPENDITURE_GROUPS.EXPENDITURE_GROUP%TYPE ;
   v_off_exp_group    PA_EXPENDITURE_GROUPS.EXPENDITURE_GROUP%TYPE ;
   v_expnd_comment    PA_TRANSACTION_INTERFACE_ALL.EXPENDITURE_COMMENT%TYPE;

   l_rej_code         PA_ALLOC_TXN_DETAILS.rejection_code%type;  /* added for bug 6243121 */
   l_cnt_ex           number:=0; /* added for bug 6243121 */

   Cursor  C_expenditure is
     Select expenditure_id
       from pa_expenditures
      where expenditure_group in (v_tgt_exp_group,v_off_exp_group) ;
      --Get the the rule name for capitalized interest
      Cursor C_cint_rule_name IS
      SELECT  meaning
        FROM  pa_lookups
       WHERE  lookup_type='PROJECT_STATUS_ACTIONS'
          AND lookup_code='CAPITALIZED_INTEREST';

	/* added cursor for bug 6243121 */
       cursor c_alloc_txn_err(runid IN NUMBER) is
       select distinct rejection_code
         from pa_alloc_txn_details
        where run_id=runid
	  and status_code='R'
          and rejection_code is not null;

   --Declared this variable for Capital project Changes
   l_transaction_source       pa_lookups.meaning%TYPE;
BEGIN
   pa_debug.set_err_stack('Release_alloc_txns') ;
   pa_debug.G_err_stage := 'Release_alloc_txns' ;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('Release_alloc_txns: ' || 'LOG',pa_debug.G_err_stage);
   END IF;
-- Init_who_cols ;
   x_errbuf := NULL ;
   --Included this block for Capital project changes
   IF p_rule_id = -1 THEN
         l_transaction_source := 'Capitalized Interest' ;
   ELSE
         l_transaction_source := 'ALLOCATIONS';
   END IF;
-- No  need lock the rule here. Allocation_run procedure is called in the report (PAXALRUN)
-- and this procedure locks the rule.
--    lock_rule(p_rule_id, p_run_id) ;
   pa_debug.G_err_stage := 'Inserting records in Interface table ' ;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('Release_alloc_txns: ' || 'LOG',pa_debug.G_err_stage);
   END IF;
---   Get info about the run   -----------------------
   OPEN C_run;
   FETCH C_run INTO run_rec ;
   IF C_run%NOTFOUND THEN
      G_fatal_err_found := TRUE;
      pa_alloc_run.ins_alloc_exceptions( p_rule_id, p_run_id, G_creation_date,
                          G_created_by, G_last_update_date,
                          G_last_updated_by, G_last_update_login,
                          'R', 'E', NULL, NULL, 'PA_AL_RUN_NOT_EXISTS');
     x_errbuf := 'PA_AL_RUN_NOT_EXISTS' ;
   END IF;
   CLOSE C_run;
   v_target_expnd_org := pa_utils.GetOrgName(run_rec.target_exp_org_id ) ;
   v_offset_expnd_org := pa_utils.GetOrgName(run_rec.offset_exp_org_id ) ;
   If (nvl(p_rule_id,-99) <> -1) AND --Added this condition for capital project changes
      v_target_expnd_org is NULL THEN
      G_fatal_err_found := TRUE;
      pa_alloc_run.ins_alloc_exceptions( p_rule_id, p_run_id, G_creation_date,
                          G_created_by, G_last_update_date,
                          G_last_updated_by, G_last_update_login,
                          'R', 'E', NULL, NULL, 'PA_AL_INVALID_TARGET_EXP_ORG');
     x_errbuf := 'PA_AL_INVALID_TARGET_EXP_ORG' ;
   End if ;
   If (nvl(p_rule_id,-99) <> -1) AND --Added this condition for capital project changes
      (run_rec.offset_method <> 'N') AND
      (v_offset_expnd_org is NULL) then
      G_fatal_err_found := TRUE;
      pa_alloc_run.ins_alloc_exceptions( p_rule_id, p_run_id, G_creation_date,
                          G_created_by, G_last_update_date,
                          G_last_updated_by, G_last_update_login,
                          'R', 'E', NULL, NULL, 'PA_AL_INVALID_OFFSET_EXP_ORG');
     x_errbuf := 'PA_AL_INVALID_OFFSET_EXP_ORG' ;
   End if ;
   v_expnd_end_date := pa_utils.GetWeekEnding(run_rec.expnd_item_date) ;
   If v_expnd_end_date is NULL then
      G_fatal_err_found := TRUE;
     alloc_errors(p_rule_id, p_run_id, 'R', 'E','PA_AL_INVALID_EXP_ITEM_DATE',TRUE) ;
     x_errbuf := 'PA_AL_INVALID_EXP_ITEM_DATE' ;
   End if ;
   if G_fatal_err_found  then
      --Added the if block for capital project changes
      IF p_rule_id = -1 THEN
            alloc_errors(p_rule_id, p_run_id, 'R', 'E','PA_CINT_RELEASE_FAILED',TRUE,'N') ;
      ELSE
            alloc_errors(p_rule_id, p_run_id, 'R', 'E','PA_AL_RELEASE_FAILED',TRUE,'N') ;
      END IF;
   end if ;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('Release_alloc_txns: ' || 'LOG', 'Inserting records in pa_transaction_interface_all');
   END IF;
   v_batch_name := substr( to_char(p_run_id), 1, 10) ;
   Open C_org_id ;
   Fetch C_org_id into v_org_id ;
   Close C_org_id ;
   --Added this check for cap int changes
   IF (nvl(p_rule_id,-99) <> -1 )THEN
-- 923184: Adding rulename and release req id as comment.
         v_expnd_comment := G_rule_name || ' - '|| to_number(G_request_id) ;
   ELSE
    /* bug 3041022 transalation issue , commented out the hardcoded value*/
      OPEN C_cint_rule_name;
      FETCH C_cint_rule_name INTO v_expnd_comment;
      CLOSE C_cint_rule_name;
       --  v_expnd_comment :='CAPITALIZED INTEREST ';
       /* end of  bug 3041022 transalation issue */
   END IF;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('Release_alloc_txns: ' || 'LOG', 'Exp item Description : '||v_expnd_comment );
   END IF;
---- Validate the Items inserted in the Interface table  --------
--- We don't do this since transaction import will take care of this
--- If we call validate item then we have to maintain that.
----  Items inserted in to the Interface table  --------
   insert into pa_transaction_interface_all
           (       transaction_source
           ,       system_linkage
           ,       batch_name
           ,       organization_name
           ,       expenditure_ending_date
           ,       expenditure_item_date
           ,       project_number
           ,       task_number
           ,       expenditure_type
           ,       quantity
           ,       denom_currency_code
           ,       denom_raw_cost
           ,       denom_burdened_cost
           ,       transaction_status_code
           ,       orig_transaction_reference
           ,       unmatched_negative_txn_flag
           ,       attribute_category
           ,       attribute1
           ,       attribute2
           ,       attribute3
           ,       attribute4
           ,       attribute5
           ,       attribute6
           ,       attribute7
           ,       attribute8
           ,       attribute9
           ,       attribute10
           ,       created_by
           ,       creation_date
           ,       last_updated_by
           ,       last_update_date
           ,       org_id
           ,       expenditure_comment
	   ,       billable_flag  -- added for Capitalized Interest Functionality
		/* Passing the following columns values to increase the performance*/
           ,       project_id
	   ,       task_id
	   ,       organization_id
	   ,       PERSON_BUSINESS_GROUP_ID
		/* end of performance changes */
           )
   Select
                   l_transaction_source -- Changed this for capital project changes
           ,       decode(patd.transaction_type,'T', run_rec.target_exp_type_class,
                          run_rec.offset_exp_type_class)
           ,       v_batch_name
           ,       decode(p_rule_id,    --Changed for capital project changes
                          -1,pa_utils.GetOrgName(patd.cint_exp_org_id ),
                          decode(patd.transaction_type,
                                 'T',v_target_expnd_org,
                                  v_offset_expnd_org))
           ,       v_expnd_end_date
           ,       run_rec.expnd_item_date
           ,       pp.segment1
           ,       pt.task_number
           ,       patd.expenditure_type
           ,       decode(patd.transaction_type, 'T',
                          decode(run_rec.target_exp_type_class,
                                 'PJ', patd.current_allocation,0),
                          decode(run_rec.offset_exp_type_class,
                                 'PJ', patd.current_allocation,0))
           ,       run_rec.denom_currency_code
           ,       decode(patd.transaction_type, 'T',
                          decode(run_rec.target_exp_type_class,
                                 'PJ', patd.current_allocation,0),
                          decode(run_rec.offset_exp_type_class,
                                 'PJ', patd.current_allocation,0))
/* In the decode below changed the 0 in default to null for bug 1524669 */
           ,       decode(patd.transaction_type, 'T',
                          decode(run_rec.target_exp_type_class,
                                 'BTC', patd.current_allocation,null),
                          decode(run_rec.offset_exp_type_class,
                                 'BTC', patd.current_allocation,null))
           ,       'P'
           ,       to_char(patd.alloc_txn_id)
           ,       'Y'
           ,       patd.attribute_category
           ,       patd.attribute1
           ,       patd.attribute2
           ,       patd.attribute3
           ,       patd.attribute4
           ,       patd.attribute5
           ,       patd.attribute6
           ,       patd.attribute7
           ,       patd.attribute8
           ,       patd.attribute9
           ,       patd.attribute10
           ,       G_created_by
           ,       G_creation_date
           ,       G_last_updated_by
           ,       G_last_update_date
           ,       v_org_id
           ,       v_expnd_comment
	   ,       decode(l_transaction_source,'Capitalized Interest','Y',null)
                /* Passing the following columns values to increase the performance*/
           ,       pp.project_id
           ,       pt.task_id
           ,       decode(p_rule_id,-1,patd.cint_exp_org_id,
			decode(patd.transaction_type,'T',run_rec.target_exp_org_id,
				run_rec.offset_exp_org_id))
           ,       decode(p_rule_id,
                          -1,pa_utils4.GetOrgBusinessGrpId(patd.cint_exp_org_id ),
                          decode(patd.transaction_type,
                                 'T',pa_utils4.GetOrgBusinessGrpId(run_rec.target_exp_org_id)
                                  ,pa_utils4.GetOrgBusinessGrpId(run_rec.offset_exp_org_id)))
                /* end of performance changes */
     from  pa_alloc_txn_details patd
         , pa_projects_all pp
         , pa_tasks        pt
    where  patd.run_id = p_run_id
      and  patd.project_id = pp.project_id
      and  patd.task_id    = pt.task_id    ;
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('Release_alloc_txns: ' || 'LOG', to_char(SQL%ROWCOUNT)||' Records inserted');
    END IF;
    Commit ;
---  Call import procedure to import the records ------
     Select pa_interface_id_s.nextval
       into v_interface_id
       from  dual ;
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('Release_alloc_txns: ' || 'LOG', 'Calling Transaction Import ..' );
    END IF;
/* Adding exception handling for bug 2749043 */
     BEGIN
     pa_trx_import.import1( l_transaction_source -- Changed this for capital project changes
                           , v_batch_name
                           , v_interface_id
                           , G_created_by
                           , NULL ) ;
     EXCEPTION
              WHEN OTHERS THEN
                IF P_DEBUG_MODE = 'Y' THEN
       		pa_debug.write_file('Release_alloc_txns: ' || 'LOG', 'Error occurred in Transaction Import' );
    		END IF;
     END;
--- Update txn_details table with import info ---------
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('Release_alloc_txns: ' || 'LOG', 'Updating the transactions with import results');
    END IF;
    update pa_alloc_txn_details patd
       set (   status_code
             , rejection_code
             , expenditure_id
             , expenditure_item_id) =
               ( select transaction_status_code
                        ,transaction_rejection_code
                        , expenditure_id
                        , expenditure_item_id
                   from pa_transaction_interface_all pti
                  where pti.orig_transaction_reference = to_char(alloc_txn_id)
                    and pti.transaction_source = l_transaction_source -- Changed this for capital project changes
                    and pti.batch_name         = v_batch_name )
     where run_id = p_run_id ;
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('Release_alloc_txns: ' || 'LOG', to_char(SQL%ROWCOUNT)||' Records updated');
    END IF;

 	   /**** added for bug 6243121 ***/

 	              ---    Alloc Exceptions status is used in report to populate 'Release status' of the release allocations run.
 	              ---    If generate allocations completes well, pa_alloc_exceptions will have no errors for the run and
 	              ---    run status is updated to 'RS' even if transaction import fails. Hence adding this code to reflect the
 	              ---    transaction import result into pa_alloc_exceptions. Also added code in allocation_run to
 	              ---    update the run_status_code conditionally based on whether any errors exist or not.

 	    begin
 	            for r1 in c_alloc_txn_err(p_run_id) loop

 	                pa_alloc_run.ins_alloc_exceptions( p_rule_id, p_run_id, G_creation_date,
 	                                                  G_created_by, G_last_update_date,
 	                                                  G_last_updated_by, G_last_update_login,
 	                                                 'T', 'E', NULL, NULL, r1.rejection_code);
 	            end loop;

 	    end;
 	    /* added for bug 6243121 */

     BEGIN
          select 'Y'
            into  v_import_failed
            from  dual
           where  EXISTS ( select 'exists'
                       from  pa_alloc_txn_details
                      where run_id = p_run_id
                        and status_code = 'R' ) ;
     EXCEPTION
                                 When NO_DATA_FOUND then
                                   v_import_failed := 'N' ;
                   END;
     IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('Release_alloc_txns: ' || 'LOG', 'v_import_failed :' ||v_import_failed );
     END IF;
     v_tgt_exp_group :=  v_batch_name||run_rec.target_exp_type_class||to_char(v_interface_id);
     v_off_exp_group :=  v_batch_name||run_rec.offset_exp_type_class||to_char(v_interface_id);
      If v_import_failed ='Y' then
         For exp_rec in C_expenditure LOOP
             delete from pa_expenditure_items
             where  expenditure_id = exp_rec.expenditure_id ;
             delete from pa_expenditures
             where  expenditure_id = exp_rec.expenditure_id ;
         END LOOP ;
         Delete from pa_expenditure_groups
         where expenditure_group in ( v_tgt_exp_group, v_off_exp_group) ;
      else
        --Modifed this for capital project changes.
        update pa_alloc_runs
           set target_exp_group = v_tgt_exp_group ,
               offset_exp_group = decode(p_rule_id,
                                         -1,null,
                                         decode(run_rec.offset_method,'N',NULL,v_off_exp_group) )
        where run_id = p_run_id ;
      End if ;
     if v_import_failed = 'Y' then
        --Added the code for capital project changes.
        IF p_rule_id = -1 THEN
              x_errbuf := 'PA_CINT_RELEASE_FAILED' ;
        ELSE
              x_errbuf := 'PA_AL_RELEASE_FAILED' ;
        END IF;
     end if ;
----  Release Lock on the rule_name   ---------------------
-- No  need unlock the rule here. Allocation_run procedure is called in the report (PAXALRUN)
-- and this procedure locks and unlocks the rule.
--    unlock_rule(p_rule_id, p_run_id) ;
   pa_debug.reset_err_stack ;
EXCEPTION
    When OTHERS then
        RAISE ;
END Release_alloc_txns ;
-- ------------------------------------------------------------
-- Reverse_alloc_txns
-- ------------------------------------------------------------
PROCEDURE Reverse_alloc_txns( p_rule_id          IN NUMBER
                             ,p_run_id           IN  NUMBER
                             ,p_tgt_exp_group    IN VARCHAR2
                             ,p_off_exp_group    IN VARCHAR2
                             ,x_retcode          OUT NOCOPY NUMBER
                             ,x_errbuf           OUT NOCOPY VARCHAR2
                            )
IS
   Cursor C_run is
    Select  target_exp_group
          , offset_exp_group
      from  pa_alloc_runs
     where  run_id = p_run_id ;
   run_rec   C_run%ROWTYPE ;
   v_num_reversed     NUMBER ;
   v_num_rejected     NUMBER ;
   v_return_code      VARCHAR2(30) ;
BEGIN
   -- pa_debug.G_process := 'SQL' ;
   pa_debug.Init_err_stack('Start') ;
   pa_debug.set_err_stack('Reverse_alloc_txns') ;
   pa_debug.G_err_stage := 'Reverse_alloc_txns' ;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('Reverse_alloc_txns: ' || 'LOG',pa_debug.G_err_stage);
   END IF;
   Init_who_cols ;
   lock_rule(p_rule_id, p_run_id) ;
/*added for bug#2357646 */
   if (G_fatal_err_found) then
      G_fatal_err_found := FALSE;
       v_return_code := 'PA_AL_CANT_ACQUIRE_LOCK';
       COMMIT;
       x_retcode := -1 ;
       x_errbuf  := v_return_code ;
       return;
    end if;
/*end of fix for bug#2357646 */
---- Check for the group name and call reverse group ------
   pa_debug.G_err_stage := 'Checking for expenditure groups' ;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('Reverse_alloc_txns: ' || 'LOG', pa_debug.G_err_stage);
   END IF;
   OPEN  C_run ;
   Fetch C_run into  run_rec ;
   Close C_run ;
   pa_exp_copy.reverseExpGroup(run_rec.target_exp_group
                                  ,p_tgt_exp_group
                                  ,G_created_by
                                  ,'PAXALRN'
                                  , v_num_reversed
                                  , v_num_rejected
                                  , v_return_code
                                  , 'RELEASED' ) ;
   If nvl(v_return_code,'0') <> '0' then
         IF P_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('Reverse_alloc_txns: ' || 'LOG', 'Reversing Error :'||v_return_code);
            pa_debug.write_file('Reverse_alloc_txns: ' || 'LOG','Records Reversed in Rejection :'||
                                 to_char(v_num_rejected) );
         END IF;
--       pa_debug.raise_error('-20010',v_return_code) ;
   else
         IF P_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('Reverse_alloc_txns: ' || 'LOG','Records Reversed :'||
                                 to_char(v_num_reversed) );
         END IF;
   end if ;
   If run_rec.offset_exp_group is NOT NULL then
      If run_rec.offset_exp_group <> run_rec.target_exp_group then
         pa_exp_copy.reverseExpGroup(run_rec.offset_exp_group
                                     ,p_off_exp_group
                                     ,G_created_by
                                     ,'PAXALRN'
                                     , v_num_reversed
                                     , v_num_rejected
                                     , v_return_code
                                     , 'RELEASED' ) ;
          if nvl(v_return_code,'0') <> '0' then
             IF P_DEBUG_MODE = 'Y' THEN
                pa_debug.write_file('Reverse_alloc_txns: ' || 'LOG', 'Reversing Error :'||v_return_code);
                pa_debug.write_file('Reverse_alloc_txns: ' || 'LOG','Records Reversed in Rejection :'||
                                 to_char(v_num_rejected) );
             END IF;
             pa_debug.raise_error('-20010',v_return_code) ;
          else
             IF P_DEBUG_MODE = 'Y' THEN
                pa_debug.write_file('Reverse_alloc_txns: ' || 'LOG','Records Reversed :'||
                                 to_char(v_num_reversed) );
             END IF;
          end if ;
       End if;
   End If;
--  Update the alloc runs table with the reversal info --
  If nvl(v_return_code,'0') = '0' then
    update pa_alloc_runs
      set  run_status = 'RV'
          ,reversal_date = trunc(sysdate)
          ,rev_target_exp_group = p_tgt_exp_group
          ,rev_offset_exp_group = p_off_exp_group
     where run_id = p_run_id ;
  else
     x_retcode := -1 ;
     x_errbuf  := v_return_code ;
  end if ;
----  Release Lock on the rule_name   ---------------------
   unlock_rule(p_rule_id, p_run_id) ;
   pa_debug.reset_err_stack ;
EXCEPTION
    WHEN OTHERS THEN
       --Added this code for capital project changes
       BEGIN
            IF p_rule_id = -1 THEN
                  unlock_rule(p_rule_id,p_run_id);
            END IF;
       EXCEPTION
            WHEN OTHERS THEN
                  NULL;
       END;
       RAISE ;
END Reverse_alloc_txns ;
-- ------------------------------------------------------------
-- Delete_alloc_txns
-- ------------------------------------------------------------
PROCEDURE Delete_alloc_txns( p_rule_id  IN NUMBER
                             ,p_run_id   IN  NUMBER)
IS
BEGIN
-- pa_debug.G_process := 'SQL' ;
   pa_debug.Init_err_stack('Start') ;
   pa_debug.set_err_stack('Delete_alloc_txns') ;
   pa_debug.G_err_stage := 'Delete_alloc_txns' ;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('Delete_alloc_txns: ' || 'LOG',pa_debug.G_err_stage);
   END IF;
   Init_who_cols ;
   lock_rule(p_rule_id, p_run_id) ;
--  Delete Transactions from pa_alloc_txn_details
    While 1=1 Loop /* Bug 2176096 */
    Delete from pa_alloc_txn_details
    where run_id = p_run_id and rownum < 10001;
/* Commented for Bug 2984871 Commit; */
    If Sql%Rowcount = 0 THen
      Exit;
    End If;
   /*Code Changes for Bug No.2984871 start */
   Commit;
   /*Code Changes for Bug No.2984871 end */
    End Loop;
--- Delete Transactions from source_details
    While 1=1 Loop /* Bug 2176096 */
    Delete from pa_alloc_run_source_det
    where  run_id = p_run_id and rownum < 10001;
/* Commented for Bug 2984871 Commit; */
    If Sql%Rowcount = 0 THen
      Exit;
    End If;
   /*Code Changes for Bug No.2984871 start */
   Commit;
   /*Code Changes for Bug No.2984871 end */
    End Loop;
--- Delete Transactions from  basis_details
    While 1=1 Loop /* Bug 2176096 */
    Delete from pa_alloc_run_basis_det
    where run_id = p_run_id and rownum < 10001;
/* Commented for Bug 2984871 Commit; */
    If Sql%Rowcount = 0 THen
      Exit;
    End If;
   /*Code Changes for Bug No.2984871 start */
   Commit;
   /*Code Changes for Bug No.2984871 end */
    End Loop;
--  Delete Transactions from pa_alloc_run_sources
    While 1=1 Loop /* Bug 2176096 */
    Delete from pa_alloc_run_sources
    where run_id = p_run_id and rownum < 10001;
/* Commented for Bug 2984871 Commit; */
    If Sql%Rowcount = 0 THen
      Exit;
    End If;
   /*Code Changes for Bug No.2984871 start */
   Commit;
   /*Code Changes for Bug No.2984871 end */
    End Loop;
--  Delete Transactions from pa_alloc_run_targets
    While 1=1 Loop /* Bug 2176096 */
    Delete from pa_alloc_run_targets
     where run_id = p_run_id and rownum < 10001;
/* Commented for Bug 2984871 Commit; */
    If Sql%Rowcount = 0 THen
      Exit;
    End If;
   /*Code Changes for Bug No.2984871 start */
   Commit;
   /*Code Changes for Bug No.2984871 end */
    End Loop;
--  Delete Transactions from pa_alloc_run_resource_det
    While 1=1 Loop /* Bug 2182563 */
    Delete from pa_alloc_run_resource_det
     where run_id = p_run_id and rownum < 10001;
/* Commented for Bug 2984871 Commit; */
    If Sql%Rowcount = 0 Then
      Exit;
    End If;
   /*Code Changes for Bug No.2984871 start */
   Commit;
   /*Code Changes for Bug No.2984871 end */
    End Loop;
--  Delete Transactions from pa_alloc_missing_costs
    Delete from pa_alloc_missing_costs
    where run_id = p_run_id ;
--  Delete Transactions from pa_alloc_exceptions
    Delete from pa_alloc_exceptions
    where run_id = p_run_id ;
--  Delete Transactions from pa_alloc_runs
    Delete from pa_alloc_runs
     where run_id = p_run_id ;
----  Release Lock on the rule_name   ---------------------
   unlock_rule(p_rule_id , p_run_id) ;
   pa_debug.reset_err_stack ;
EXCEPTION
     WHEN OTHERS THEN
     RAISE ;
END Delete_alloc_txns ;
-- ------------------------------------------------------------
-- Delete_alloc_run
-- ------------------------------------------------------------
PROCEDURE Delete_alloc_run(
                           errbuf                  OUT NOCOPY VARCHAR2,
                           retcode                 OUT NOCOPY VARCHAR2,
                           p_rule_id  IN NUMBER
                           )
IS
   CURSOR get_run_id
     IS
        select run_id from pa_alloc_runs_all
          where rule_id = p_rule_id
          and  run_status = 'DL';
   l_run_id NUMBER;
    v_debug_mode VARCHAR2(2);
    v_process_mode VARCHAR2(10);
    --Declared these variables for capital project changes
    l_return_status      VARCHAR2(1);
    l_msg_data           VARCHAR2(1000);
    l_msg_count          NUMBER :=0;
BEGIN
   -- pa_debug.G_process := 'SQL' ;
   -- v_debug_mode := NVL(p_debug_mode, 'Y');
   --v_process_mode := NVL(p_process_mode, 'SQL');
   pa_debug.Init_err_stack('Start') ;
   v_debug_mode := 'Y';
   v_process_mode := 'PLSQL';
   pa_debug.set_process(v_process_mode, 'LOG', v_debug_mode) ;
   pa_debug.set_err_stack('Delete_alloc_run') ;
   pa_debug.G_err_stage := 'Delete_alloc_run' || To_char(p_rule_id) ;
   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('Delete_alloc_run: ' || 'LOG',pa_debug.G_err_stage);
   END IF;
   Init_who_cols ;
   FOR run_rec IN get_run_id LOOP
      l_run_id := run_rec.run_id;
      pa_debug.G_err_stage := 'Delete Rule Id' || To_char(p_rule_id) ;
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('Delete_alloc_run: ' || 'LOG',pa_debug.G_err_stage);
      END IF;
      pa_debug.G_err_stage := 'Delete Run Id' || To_char(l_run_id) ;
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('Delete_alloc_run: ' || 'LOG',pa_debug.G_err_stage);
      END IF;
      --Delete all the txn source details when this api is called in
      --the context of Capitalized Interest
      IF p_rule_id = -1 THEN
            pa_alloc_run.delete_cint_source_dets
           ( p_run_id         => l_run_id
            ,x_return_status  => l_return_status
            ,x_msg_data       => l_msg_data
            ,x_msg_count      => l_msg_count);
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 IF P_DEBUG_MODE = 'Y' THEN
                      pa_debug.G_err_stage := 'delte cint sources errored out' ;
                      pa_debug.write_file('Delete_alloc_run: ' || 'LOG',pa_debug.G_err_stage);
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
     END IF;
--   lock_rule(p_rule_id, l_run_id) ;
--  Delete Transactions from pa_alloc_txn_details
    While 1=1 Loop /* Bug 2176096 */
    Delete from pa_alloc_txn_details
    where run_id = l_run_id and rownum < 10001;
/* Commented for Bug 2984871 Commit; */
    If Sql%Rowcount = 0 THen
      Exit;
    End If;
   /*Code Changes for Bug No.2984871 start */
   Commit;
   /*Code Changes for Bug No.2984871 end */
    End Loop;
--- Delete Transactions from source_details
    While 1=1 Loop /* Bug 2176096 */
    Delete from pa_alloc_run_source_det
    where  run_id = l_run_id and rownum < 10001;
/* Commented for Bug 2984871 Commit; */
    If Sql%Rowcount = 0 THen
      Exit;
    End If;
   /*Code Changes for Bug No.2984871 start */
   Commit;
   /*Code Changes for Bug No.2984871 end */
    End Loop;
--- Delete Transactions from  basis_details
    While 1=1 Loop /* Bug 2176096 */
    Delete from pa_alloc_run_basis_det
    where run_id = l_run_id and rownum < 10001;
/* Commented for Bug 2984871 Commit; */
    If Sql%Rowcount = 0 THen
      Exit;
    End If;
   /*Code Changes for Bug No.2984871 start */
   Commit;
   /*Code Changes for Bug No.2984871 end */
    End Loop;
--  Delete Transactions from pa_alloc_run_sources
    While 1=1 Loop /* Bug 2176096 */
    Delete from pa_alloc_run_sources
    where run_id = l_run_id and rownum < 10001;
/* Commented for Bug 2984871 Commit; */
    If Sql%Rowcount = 0 THen
      Exit;
    End If;
   /*Code Changes for Bug No.2984871 start */
   Commit;
   /*Code Changes for Bug No.2984871 end */
    End Loop;
--  Delete Transactions from pa_alloc_run_targets
    While 1=1 Loop /* Bug 2176096 */
    Delete from pa_alloc_run_targets
     where run_id = l_run_id and rownum < 10001;
/* Commented for Bug 2984871 Commit; */
    If Sql%Rowcount = 0 THen
      Exit;
    End If;
   /*Code Changes for Bug No.2984871 start */
   Commit;
   /*Code Changes for Bug No.2984871 end */
    End Loop;
--  Delete Transactions from pa_alloc_run_resource_det
    While 1=1 Loop /* Bug 2182563 */
    Delete from pa_alloc_run_resource_det
     where run_id = l_run_id and rownum < 10001;
/* Commented for Bug 2984871 Commit; */
    If Sql%Rowcount = 0 Then
      Exit;
    End If;
   /*Code Changes for Bug No.2984871 start */
   Commit;
   /*Code Changes for Bug No.2984871 end */
    End Loop;
--  Delete Transactions from pa_alloc_missing_costs
    Delete from pa_alloc_missing_costs
    where run_id = l_run_id ;
--  Delete Transactions from pa_alloc_exceptions
    Delete from pa_alloc_exceptions
    where run_id = l_run_id ;
--  Delete Transactions from pa_alloc_runs
    Delete from pa_alloc_runs
     where run_id = l_run_id ;
----  Release Lock on the rule_name   ---------------------
    --unlock_rule(p_rule_id , l_run_id) ;
   END LOOP;
   pa_debug.reset_err_stack ;
EXCEPTION
     WHEN OTHERS THEN
     RAISE ;
END Delete_alloc_run ;
--------------------------------------------------------------------------
--Function:  Is_src_project_valid
--Purpose: validating source project_id returned from source client extension
----------------------------------------------------------------------------
FUNCTION Is_src_project_valid(p_project_id IN NUMBER)
                                           RETURN VARCHAR2
IS
CURSOR C_valid_project is
 SELECT '1'
 FROM dual
 WHERE EXISTS (SELECT 'Y'
               FROM  pa_alloc_src_projects_v ps
               WHERE ps.project_id=p_project_id);
v_ret_code varchar2(1) ;
v_dummy  varchar2(1);
BEGIN
  v_ret_code := 'N';
  OPEN  C_valid_project;
  FETCH C_valid_project INTO v_dummy;
  IF C_valid_project%FOUND THEN
     v_ret_code := 'Y' ;
  END IF;
  CLOSE C_valid_project;
  RETURN v_ret_code;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     Return v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
END  is_src_project_valid;
--------------------------------------------------------------------------
--Function:  Is_src_task_valid
--Purpose: validating source task_id returned from source client extension
----------------------------------------------------------------------------
FUNCTION Is_src_task_valid(p_project_id IN NUMBER,p_task_id IN NUMBER)
                                           RETURN VARCHAR2
IS
CURSOR C_valid_task is
 SELECT '1'
 FROM dual
 WHERE EXISTS (SELECT 'Y'
               FROM  pa_alloc_src_tasks_v pt
               WHERE pt.project_id=p_project_id
               and pt.task_id=p_task_id);
v_ret_code varchar2(1) ;
v_dummy  varchar2(1);
BEGIN
  v_ret_code := 'N';
  OPEN  C_valid_task;
  FETCH C_valid_task INTO v_dummy;
  IF C_valid_task%FOUND THEN
     v_ret_code := 'Y' ;
  END IF;
  CLOSE C_valid_task;
  RETURN v_ret_code;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     Return v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
END  is_src_task_valid;
--------------------------------------------------------------------------
--Function:  Is_tgt_project_valid
--Purpose: validating target project_id returned from target client extension
----------------------------------------------------------------------------
FUNCTION Is_tgt_project_valid(p_project_id IN NUMBER)
                                           RETURN VARCHAR2
IS
CURSOR C_valid_project is
 SELECT '1'
 FROM dual
 WHERE EXISTS (SELECT 'Y'
               FROM  pa_alloc_target_proj_v pap
               WHERE pap.project_id=p_project_id);
v_ret_code varchar2(1) ;
v_dummy  varchar2(1);
BEGIN
  v_ret_code := 'N';
  OPEN  C_valid_project;
  FETCH C_valid_project INTO v_dummy;
  IF C_valid_project%FOUND THEN
     v_ret_code := 'Y' ;
  END IF;
  CLOSE C_valid_project;
  RETURN v_ret_code;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     Return v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
END  is_tgt_project_valid;
--------------------------------------------------------------------------
--Function:  Is_tgt_task_valid
--Purpose: validating target task_id returned from target client extension
----------------------------------------------------------------------------
FUNCTION Is_tgt_task_valid(p_project_id IN NUMBER,p_task_id IN NUMBER)
                                           RETURN VARCHAR2
IS
CURSOR C_valid_task is
 SELECT '1'
 FROM dual
 WHERE EXISTS (SELECT 'Y'
               FROM  pa_alloc_tgt_tasks_v pt
               WHERE pt.project_id=p_project_id
               and pt.task_id=p_task_id);
v_ret_code varchar2(1) ;
v_dummy  varchar2(1);
BEGIN
  v_ret_code := 'N';
  OPEN  C_valid_task;
  FETCH C_valid_task INTO v_dummy;
  IF C_valid_task%FOUND THEN
     v_ret_code := 'Y' ;
  END IF;
  CLOSE C_valid_task;
  RETURN v_ret_code;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     Return v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
END  is_tgt_task_valid;
--------------------------------------------------------------------------
--Function:  Is_offset_project_valid
--Purpose: validating offset project_id returned from offset client extension
----------------------------------------------------------------------------
FUNCTION Is_offset_project_valid(p_project_id IN NUMBER)
                                           RETURN VARCHAR2
IS
CURSOR C_valid_project is
 SELECT '1'
 FROM dual
 WHERE EXISTS (SELECT 'Y'
               FROM  pa_alloc_offset_projects_v pap
               WHERE pap.project_id=p_project_id);
v_ret_code varchar2(1) ;
v_dummy  varchar2(1);
BEGIN
  v_ret_code := 'N';
  OPEN  C_valid_project;
  FETCH C_valid_project INTO v_dummy;
  IF C_valid_project%FOUND THEN
     v_ret_code := 'Y' ;
  END IF;
  CLOSE C_valid_project;
  RETURN v_ret_code;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     Return v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
END  is_offset_project_valid;
--------------------------------------------------------------------------
--Function:  Is_offset_task_valid
--Purpose: validating offset task_id returned from offset client extension
----------------------------------------------------------------------------
FUNCTION Is_offset_task_valid(p_project_id IN NUMBER,p_task_id IN NUMBER)
                                           RETURN VARCHAR2
IS
CURSOR C_valid_task is
 SELECT '1'
 FROM dual
 WHERE EXISTS (SELECT 'Y'
               FROM  pa_alloc_tgt_tasks_v pt
               WHERE pt.project_id=p_project_id
               and pt.task_id=p_task_id);
v_ret_code varchar2(1) ;
v_dummy  varchar2(1);
BEGIN
  v_ret_code := 'N';
  OPEN  C_valid_task;
  FETCH C_valid_task INTO v_dummy;
  IF C_valid_task%FOUND THEN
     v_ret_code := 'Y' ;
  END IF;
  CLOSE C_valid_task;
  RETURN v_ret_code;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     Return v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
END  is_offset_task_valid;
--Added this procedure for Capital Project Enhancement. This procedure releases a capitalized interest run
--This procedure is called from PA_CAP_INT_PVT. Generate_cap_interest when release button is pressed on the
--Allocation form(when form is accessed in the context of capitalized interest) or when auto release flag is
--passed Y
PROCEDURE release_capint_txns
( p_run_id           IN   pa_alloc_runs_all.run_id%TYPE
 ,x_return_status    OUT  NOCOPY VARCHAR2
 ,x_msg_count        OUT  NOCOPY NUMBER
 ,x_msg_data         OUT  NOCOPY VARCHAR2
)
IS
l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level5                  CONSTANT NUMBER := 5;
l_rel_request_id                CONSTANT NUMBER := fnd_global.conc_request_id;
completion_status               BOOLEAN;
l_module_name                   VARCHAR2(100);
BEGIN
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
      l_module_name := 'release_capint_txns';
      pa_debug.set_curr_function( p_function   => 'release_capint_txns',
                                  p_debug_mode => l_debug_mode );
      IF l_debug_mode = 'Y' THEN
            pa_debug.G_err_stage := 'About to call release_alloc_txns';
            pa_debug.write_file('LOG',pa_debug.g_err_stage);
      END IF;
      --Initialise the who columns
      pa_alloc_run.init_who_cols;
      --Call the api that releases the allocation run
      pa_alloc_run.release_alloc_txns
                   ( p_rule_id  => -1
                    ,p_run_id   => p_run_id
                    ,x_retcode  => x_return_status
                    ,x_errbuf   => x_msg_data);
      IF l_debug_mode = 'Y' THEN
            pa_debug.G_err_stage := 'Returned after releasing with msg '||x_msg_data;
            pa_debug.write_file('LOG',pa_debug.g_err_stage);
      END IF;
      --If failed insert errors into alloc_exceptions table and raise error
      IF x_msg_data is NOT NULL then
            x_return_status := FND_API.G_RET_STS_ERROR;
            alloc_errors( -1, p_run_id, 'R', 'E',x_msg_data, FALSE );
      Else
	    x_return_status := 'S';
      End if ;
      --Update the capital interest run status
      IF l_debug_mode = 'Y' THEN
            pa_debug.G_err_stage := 'About to update the Release status to ['||x_return_status||']';
            pa_debug.write_file('LOG',pa_debug.g_err_stage);
      END IF;
	/* bug fix: 3123539  based on the return status update the run staus and avoid
         * setting the concurrent process to raise error
         */
	IF x_return_status = 'S' Then
      		UPDATE pa_alloc_runs
      		SET    run_status = 'RS'
            		,release_request_id = l_rel_request_id
            		,release_request_date =sysdate
      		WHERE run_id = p_run_id;
       Else
            	-- Update the status to release failure
            	UPDATE pa_alloc_runs
            	SET    run_status = 'RF'
                  ,release_request_id = null
                  ,release_request_date =sysdate
            	WHERE  run_id = p_run_id;
	End If;
	/* bug fix:3123539 Setting these values as success
           the concurrent process should error out only for the unexpected errors
         */
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_msg_data := Null;
      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Leaving release_capint_txns return status ['||x_return_status||']';
           pa_debug.write_file('LOG',pa_debug.g_err_stage);
      END IF;
      pa_debug.reset_curr_function;
EXCEPTION
      WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count  := FND_MSG_PUB.count_msg;
            IF l_debug_mode = 'Y' THEN
                  x_msg_data:=sqlerrm;
                  pa_debug.write_file('cap_int run: ' ||  'LOG', x_msg_data);
                  pa_debug.write_file('cap_int run: ' ||  'LOG', pa_debug.G_err_stack);
                  pa_debug.G_err_stage := 'UPDATING RUN STATUS AS FAILURE';
                  pa_debug.write_file('cap_int: ' ||  'LOG', pa_debug.G_err_stage);
            END IF;
            -- Update the status to release failure
            UPDATE pa_alloc_runs
            SET    run_status = 'RF'
                  ,release_request_id = l_rel_request_id
                  ,release_request_date =sysdate
            WHERE  run_id = p_run_id;
            IF l_debug_mode = 'Y' THEN
                  pa_debug.write_file('LOG','p_run_id in when others of Main: '||to_char( p_run_id) );
            END IF;
            COMMIT;
            pa_debug.reset_curr_function;
            completion_status  := fnd_concurrent.set_completion_status('ERROR', SQLERRM);
END release_capint_txns;
--This procedure deletes the source details for each capital interest transaction. This procedure will
--be called from delete_alloc_run api when the DELETE button is pressed to delete a capital interest
--batch
PROCEDURE delete_cint_source_dets
( p_run_id              IN  pa_alloc_runs_all.run_id%TYPE
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_msg_count           OUT NOCOPY NUMBER
 ,x_msg_data            OUT NOCOPY VARCHAR2
)
IS
l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level5                  CONSTANT NUMBER := 5;
l_rel_request_id                CONSTANT NUMBER := fnd_global.conc_request_id;
completion_status               BOOLEAN;
l_module_name                   VARCHAR2(100);
CURSOR c_get_cint_txns
IS
SELECT alloc_txn_id
FROM   pa_alloc_txn_details
WHERE  run_id=p_run_id;
BEGIN
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
      l_module_name := 'delete_cint_source_dets';
      pa_debug.set_curr_function( p_function   => l_module_name,
                                  p_debug_mode => l_debug_mode );
      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'About to delete the source txn details';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;
      FOR c_cint_txn_rec IN  c_get_cint_txns LOOP
            LOOP
                  DELETE
                  FROM   pa_cint_source_details
                  WHERE  alloc_txn_id = c_cint_txn_rec.alloc_txn_id
                  AND ROWNUM <1000;
                  IF SQL%ROWCOUNT <1000 THEN
                      EXIT;
                  END IF;
            END LOOP;
      END LOOP;
      IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Leaving delete_cint_source_dets';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;
      pa_debug.reset_curr_function;
EXCEPTION
WHEN others THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;
     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'pa_alloc_run'
                    ,p_procedure_name  => 'delete_cint_source_dets'
                    ,p_error_text      => x_msg_data);
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
     END IF;
     pa_debug.reset_curr_function;
     RAISE;
END delete_cint_source_dets;
END PA_ALLOC_run;

/
