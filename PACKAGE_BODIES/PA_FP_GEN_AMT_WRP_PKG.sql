--------------------------------------------------------
--  DDL for Package Body PA_FP_GEN_AMT_WRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_GEN_AMT_WRP_PKG" AS
/* $Header: PAFPGAWB.pls 120.11.12010000.5 2010/02/05 10:51:54 kmaddi ship $ */
  P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE GEN_AMT_WRP(
        errbuff             OUT NOCOPY VARCHAR2,
        retcode             OUT NOCOPY VARCHAR2,
        p_organization_id   IN NUMBER,
        p_project_type_id   IN NUMBER,
        p_proj_manager_id   IN NUMBER,
        p_from_project_no   IN VARCHAR2,
        p_to_project_no     IN VARCHAR2,
        p_plan_type_id      IN NUMBER)
IS
  l_module_name  VARCHAR2(200) :=
    'pa.plsql.PA_FP_GEN_AMT_WRP_PKG.GEN_AMT_WRP';

  l_from_proj_no        varchar2(100) := NULL;
  l_to_proj_no          varchar2(100) := NULL;

  l_sel_clause      varchar2(2000);
  l_where_clause    varchar2(2000);
  l_where_clause0   varchar2(2000);
  l_where_clause1   varchar2(2000);
  l_where_clause2   varchar2(2000);
  l_from_clause     varchar2(2000);
  l_stmt        varchar2(2000);
  l_proj_id         number;
  l_plan_type_id    number;
  l_fin_plan_preference_code    varchar2(30);
  l_plan_class_code varchar2(30);
  l_count       number := 0;
  l_element_type_tab    pa_plsql_datatypes.Char30TabTyp;
  l_rows        number;
  l_rows1       number;
  sql_cursor        number;

  lx_budget_version_id  number;
  lx_proj_fp_option_id  number;
  l_unspent_amt_period  varchar2(50);
  l_act_from_period     varchar2(50);
  l_act_to_period   varchar2(50);
  l_etc_from_period     varchar2(50);
  l_etc_to_period   varchar2(50);
  l_act_thru_period     varchar2(50);
  l_act_thru_date   date;

  l_versioning_enabled  varchar2(10);

  l_fp_cols_rec         PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
  l_gen_src_wp_ver_code varchar2(50);
  l_gen_src_plan_ver_code varchar2(50);
  l_etc_wp_struct_ver_id number;
  l_etc_wp_fin_ver_id   number;
  l_etc_fp_type_id  number;
  l_etc_fp_ver_id   number;
  l_etc_fp_ver_name VARCHAR2(60);
  l_fp_options_id   number;
  l_project_name        VARCHAR2(200);
  l_plan_type_name      pa_fin_plan_types_tl.name%type;
  l_struct_sharing_code pa_projects_all.structure_sharing_code%type;
  l_return_status   varchar2(10);
  l_msg_count       number;
  l_msg_data        varchar2(2000);
  l_msg_data_in     varchar2(2000);

  l_data                VARCHAR2(2000);
  l_msg_index_out       number;

  l_called_mode         Varchar2(50) := 'CONCURRENT';

  l_version_name        Varchar2(2000);
/* Added two flag variables to check for create_version and return_status from APIs called
   -bug 4029915 */
  l_generation_flag     VARCHAR2(10) := 'Y';
  l_gen_api_call_flag        VARCHAR2(10) := 'Y';

  l_project_name_err_token       VARCHAR2(500);
  l_fin_plan_type_err_token      VARCHAR2(500);

  l_fin_plan_src_dtls_flag       VARCHAR2(1);
  l_workplan_src_dtls_flag       VARCHAR2(1);
  lc_FinancialPlan               CONSTANT VARCHAR2(30) := 'FINANCIAL_PLAN';
  lc_WorkplanResources           CONSTANT VARCHAR2(30) := 'WORKPLAN_RESOURCES';
  lc_TaskLevelSel                CONSTANT VARCHAR2(30) := 'TASK_LEVEL_SEL';
  l_fin_plan_count               NUMBER;
  l_workplan_count               NUMBER;

  /* Added for ER 4391321 */
  -- Added for VALIDATE_SUPPORT_CASES API. Value not used by Concurrent Program.
  l_warning_message              VARCHAR2(2000);

  -- gboomina added for AAI requirement 8318932 - start
  l_copy_etc_from_plan_flag PA_PROJ_FP_OPTIONS.COPY_ETC_FROM_PLAN_FLAG%TYPE;
  l_gen_cost_etc_src_code PA_PROJ_FP_OPTIONS.GEN_COST_ETC_SRC_CODE%TYPE;
  l_cost_time_phased_code PA_PROJ_FP_OPTIONS.COST_TIME_PHASED_CODE%TYPE;
  l_plan_type_validated VARCHAR2(1) := 'Y';
  -- gboomina added for AAI requirement 8318932 - end

BEGIN
    -- hr_utility.trace_on(null,'Sharmila');
    IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_curr_function( p_function   => 'GEN_AMT_WRP',
                                    p_debug_mode => p_pa_debug_mode );
    END IF;

    /* Getting token values for use by possible error messages. */
    FND_MESSAGE.SET_NAME('PA','PA_FP_GEN_EXCEPTION_INFO');
    l_project_name_err_token := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME('PA','PA_FP_GEN_EXCEPTION_INFO1');
    l_fin_plan_type_err_token := FND_MESSAGE.GET;

    retcode := '0';

    sql_cursor := DBMS_SQL.OPEN_CURSOR;
    l_sel_clause   := ' SELECT  distinct pj.project_id, opt.fin_plan_type_id,'
                    ||' opt.FIN_PLAN_PREFERENCE_CODE,pt.PLAN_CLASS_CODE'
                    ||',pj.name'||
       -- gboomina added for AAI Requirement 8318932 - start
       -- select ETC source code, Time Phase and Copy ETC from Plan flag
       -- to validate the target financial plan if Copy ETC from plan flag
       -- is selected
                ' ,opt.GEN_COST_ETC_SRC_CODE, opt.COST_TIME_PHASED_CODE, ' ||  --Bug 9322311
                'opt.COPY_ETC_FROM_PLAN_FLAG';
       -- gboomina added for AAI Requirement 8318932 - end

    -- Bug 4367064: Instead of checking if pj.project_status_code <> 'CLOSED'
    -- directly, we make use of the Is_Project_Status_Closed function, which
    -- returns 'Y' if the project_status_code is equivalent to 'CLOSED'.

    -- bug 5657334: Changed pa_projects_all to refer pa_projects as the concurrent
    -- program has been modified to make it single org compliant.

    l_from_clause  := ' FROM  pa_projects pj, pa_proj_fp_options opt,' ||
                      ' pa_fin_plan_types_b pt, pa_project_types_all pta';
    l_where_clause := ' WHERE 1 = 1 AND pj.project_id = opt.project_id' ||
                      ' AND nvl(pj.template_flag,''N'') <> ''Y''' ||
                      ' AND NVL(PA_PROJECT_STUS_UTILS.Is_Project_Status_Closed' ||
                      '(pj.project_status_code),''N'') <> ''Y''' ||
                      ' AND opt.FIN_PLAN_OPTION_LEVEL_CODE = ''PLAN_TYPE''' ||
                      'AND (pj.project_type = pta.project_type AND pta.org_project_flag <> ''Y'')';
    l_where_clause0:= ' AND pt.fin_plan_type_id = opt.fin_plan_type_id';

    --****p_organization_id****--
    IF (P_ORGANIZATION_ID) IS NOT NULL THEN
        -- SQL Repository Bug 5112175; SQL ID 16507224
        -- Replaced SQL literals with bind variables.
    l_where_clause1 := ' AND pj.CARRYING_OUT_ORGANIZATION_ID = '
            ||':organization_id';
    END IF;

    --****p_project_type_id****--
    IF (P_PROJECT_TYPE_ID IS NOT NULL) THEN
    l_from_clause := l_from_clause || ', pa_project_types pt'; /* Bug 5657334 */
        -- SQL Repository Bug 5112175; SQL ID 16507225
        -- Replaced SQL literals with bind variables.
        -- R12 MOAC 4447573:  AND NVL(pj.org_id, -99) = NVL(pt.org_id, -99)
    l_where_clause1 := l_where_clause1 ||
                        ' AND pj.org_id = pt.org_id ' ||
                ' AND pj.project_type = pt.project_type AND pt.PROJECT_TYPE_ID = '
            ||':project_type_id';
    END IF;

    --*****p_proj_manager_id****--
    -- SQL Repository Bug 4884427; SQL ID 14901662
    -- Replaced SQL literal with a bind variable.
    IF (p_proj_manager_id IS NOT NULL) THEN
    l_from_clause := l_from_clause ||', pa_project_parties pp';
    l_where_clause1 := l_where_clause1 ||' AND pp.project_id = pj.project_id'
         ||' AND pp.object_type = ''PA_PROJECTS'' AND pp.resource_source_id = '
         ||' :proj_manager_id';
    END IF;

    -- Bug 4367064: Instead of checking if pj.project_status_code <> 'CLOSED'
    -- directly, we make use of the Is_Project_Status_Closed function, which
    -- returns 'Y' if the project_status_code is equivalent to 'CLOSED'.

    --*****p_from_project_no ande p_to_project_no****--
    IF (p_from_project_no IS NULL) THEN
    SELECT  min(pj.segment1)
    INTO    l_from_proj_no
    FROM    pa_projects pj /* Bug 5657334 */
    WHERE   NVL(PA_PROJECT_STUS_UTILS.Is_Project_Status_Closed(pj.project_status_code),'N') <> 'Y';

    ELSE
    l_from_proj_no := p_from_project_no;
        -- hr_utility.trace('l_from_proj_no '||l_from_proj_no);
    END IF;
        -- hr_utility.trace('l_from_proj_no '||l_from_proj_no);

    -- Bug 4367064: Instead of checking if pj.project_status_code <> 'CLOSED'
    -- directly, we make use of the Is_Project_Status_Closed function, which
    -- returns 'Y' if the project_status_code is equivalent to 'CLOSED'.

    IF (p_to_project_no IS NULL) THEN
    SELECT  max(pj.segment1)
    INTO l_to_proj_no
    FROM pa_projects pj /* Bug 5657334 */
    WHERE NVL(PA_PROJECT_STUS_UTILS.Is_Project_Status_Closed(pj.project_status_code),'N') <> 'Y';
    ELSE
    l_to_proj_no := p_to_project_no;
        -- hr_utility.trace('l_to_proj_no '||l_to_proj_no);
    END IF;
    -- SQL Repository Bug 4884427; SQL ID 14901706
    -- Instead of concatenating quotes around l_from_proj_no and
    -- l_to_proj_no, just leave them as normal strings for binding.
    /*********************** BEGIN Commenting ***********************
    -- l_from_proj_no := ''''||l_from_proj_no||'''';
    -- l_to_proj_no := ''''||l_to_proj_no||'''';
    ************************ END Commenting** ***********************/

        -- hr_utility.trace('l_from_proj_no2 '||l_from_proj_no);
        -- hr_utility.trace('l_to_proj_no2 '||l_to_proj_no);

    -- SQL Repository Bug 4884427; SQL ID 14901706
    -- Replaced SQL literals with bind variables.
    l_where_clause2 := ' AND pj.segment1 BETWEEN :from_proj_no and :to_proj_no';

    --*****p_plan_type_id****--
    IF (P_PLAN_TYPE_ID) IS NOT NULL THEN
        -- SQL Repository Bug 5112175; SQL ID 16507275
        -- Replaced SQL literals with bind variables.
    l_where_clause2 := l_where_clause2 ||
                ' AND opt.FIN_PLAN_TYPE_ID = '
            ||':plan_type_id';
    END IF;

    l_stmt := l_sel_clause || l_from_clause || l_where_clause||l_where_clause0
          ||l_where_clause1||l_where_clause2;

    --dbms_output.put_line('Sel Clause: '||l_sel_clause);
    --dbms_output.put_line('From Clause: '||l_from_clause);
    --dbms_output.put_line('Where Clause: '||l_where_clause);
    --dbms_output.put_line('Where Clause0: '||l_where_clause0);
    --dbms_output.put_line('Where Clause1 : ' || l_where_clause1);
    --dbms_output.put_line('Where Clause2 : ' || l_where_clause2);
      /* hr_utility.trace('Sel Clause: '||l_sel_clause);
      hr_utility.trace('From Clause: '||l_from_clause);
      hr_utility.trace('Where Clause: '||l_where_clause);
      hr_utility.trace('Where Clause0: '||l_where_clause0);
      hr_utility.trace('Where Clause1 : ' || l_where_clause1);
      hr_utility.trace('Where Clause2 : ' || l_where_clause2);
      hr_utility.trace('Dynamic SQL ' || l_stmt);   */

    DBMS_SQL.PARSE(sql_cursor, l_stmt, dbms_sql.v7);

    -- SQL Repository Bugs 4884427, 5112175;
    -- SQL IDs 14901706, 14901662, 16507224, 16507225, 16507275
    -- Bind values to the new bind variables.
    IF (P_ORGANIZATION_ID) IS NOT NULL THEN
        DBMS_SQL.BIND_VARIABLE(sql_cursor, ':organization_id', p_organization_id);
    END IF;
    IF (P_PROJECT_TYPE_ID IS NOT NULL) THEN
        DBMS_SQL.BIND_VARIABLE(sql_cursor, ':project_type_id', p_project_type_id);
    END IF;
    IF (p_proj_manager_id IS NOT NULL) THEN
        DBMS_SQL.BIND_VARIABLE(sql_cursor, ':proj_manager_id', p_proj_manager_id);
    END IF;
    IF (P_PLAN_TYPE_ID) IS NOT NULL THEN
        DBMS_SQL.BIND_VARIABLE(sql_cursor, ':plan_type_id', p_plan_type_id);
    END IF;
    DBMS_SQL.BIND_VARIABLE(sql_cursor, ':from_proj_no', l_from_proj_no);
    DBMS_SQL.BIND_VARIABLE(sql_cursor, ':to_proj_no', l_to_proj_no);

    l_rows := DBMS_SQL.EXECUTE (sql_cursor);

    --dbms_output.put_line('After execute, l_rows is: '||l_rows);
    -- hr_utility.trace('After execute, l_rows is: '||l_rows);

    IF (l_rows < 0) THEN
       IF p_pa_debug_mode = 'Y' THEN
          pa_fp_gen_amount_utils.fp_debug
                 (p_called_mode => l_called_mode,
                  p_msg         =>'After dbms parse '||to_char(l_rows),
                  p_module_name => l_module_name,
                  p_log_level   => 5);
          PA_DEBUG.RESET_CURR_FUNCTION;
       END IF;
       RETURN;
    END IF;

    DBMS_SQL.DEFINE_COLUMN(sql_cursor, 1, l_proj_id);
    DBMS_SQL.DEFINE_COLUMN(sql_cursor, 2, l_plan_type_id);
    DBMS_SQL.DEFINE_COLUMN(sql_cursor, 3, l_fin_plan_preference_code,30);
    DBMS_SQL.DEFINE_COLUMN(sql_cursor, 4, l_plan_class_code,30);
    DBMS_SQL.DEFINE_COLUMN(sql_cursor, 5, l_project_name,200);
    -- gboomina added for AAI Requirement 8318932 - start
    DBMS_SQL.DEFINE_COLUMN(sql_cursor, 6, l_gen_cost_etc_src_code,30);
    DBMS_SQL.DEFINE_COLUMN(sql_cursor, 7, l_cost_time_phased_code,30);
    DBMS_SQL.DEFINE_COLUMN(sql_cursor, 8, l_copy_etc_from_plan_flag,1);
    -- gboomina added for AAI Requirement 8318932 - end

    LOOP
        l_rows1 := DBMS_SQL.FETCH_ROWS(sql_cursor);
        --dbms_output.put_line('l_rows1 value inside the loop is : ' || l_rows1);
        --hr_utility.trace('l_rows1 value inside the loop is : ' || l_rows1);
        IF l_rows1 = 0 then
            EXIT;
        END IF;
        DBMS_SQL.COLUMN_VALUE(sql_cursor,1,l_proj_id);
    DBMS_SQL.COLUMN_VALUE(sql_cursor,2,l_plan_type_id);
        DBMS_SQL.COLUMN_VALUE(sql_cursor,3,l_fin_plan_preference_code);
    DBMS_SQL.COLUMN_VALUE(sql_cursor,4,l_plan_class_code);
    DBMS_SQL.COLUMN_VALUE(sql_cursor,5,l_project_name);
    -- gboomina added for AAI Requirement 8318932 - start
    DBMS_SQL.COLUMN_VALUE(sql_cursor,6,l_gen_cost_etc_src_code);
    DBMS_SQL.COLUMN_VALUE(sql_cursor,7,l_cost_time_phased_code);
    DBMS_SQL.COLUMN_VALUE(sql_cursor,8,l_copy_etc_from_plan_flag);
    -- gboomina added for AAI Requirement 8318932 - end

        --dbms_output.put_line('====l_proj_id  is : ' || l_proj_id);
        --dbms_output.put_line('====l_plan_type_id  is : ' || l_plan_type_id);
    --dbms_output.put_line('====l_fin_plan_preference_code  is : ' || l_fin_plan_preference_code);
        --dbms_output.put_line('====l_plan_class_code  is : ' || l_plan_class_code);

        /**Under the context of one project_id and one plan_type_id, a new
      *budget version is to be created. **/

       -- gboomina added for AAI requirement 8318932 - start
       -- Moving the plan type code here to get the plan type value beforehand
       -- so that this will be used blow to display the plan type in output log file
       /* The hard-coded values Project Name and the Financial Plan Type
          should be replaced with FND Message. (This will be done
          based on the release team response for the processing of
          the SEED bug. */
       BEGIN
           SELECT name INTO l_plan_type_name FROM pa_fin_plan_types_tl
           WHERE
           fin_plan_type_id = l_plan_type_id AND
           language = USERENV('LANG');
       EXCEPTION
       WHEN OTHERS THEN
          l_plan_type_name := NULL;
       END;

       IF l_plan_class_code = 'FORECAST' THEN
         IF l_copy_etc_from_plan_flag = 'Y' THEN
           -- Check whether the target version type is 'COST' and
           -- ETC Source is 'Task Level Selection'. Only this combo is supported for
           -- Copy ETC from plan flow.
           IF ( l_fin_plan_preference_code <> 'COST_ONLY' )  THEN
               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_FP_COST_PLAN_TYPE_ONLY_SUPP');
               l_plan_type_validated := 'N';
           END IF;
           IF ( l_gen_cost_etc_src_code <> 'TASK_LEVEL_SEL' ) THEN
               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_FP_TASK_LEVEL_SEL_ONLY');
               l_plan_type_validated := 'N';
           END IF;
           -- Check whether destination financial plan is non time phased.
           -- if so, throw an error.
           -- Only time phased plan is supported for Copy ETC From plan AAI requirement
           IF ( l_cost_time_phased_code ) = 'N' THEN
              PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_FP_NON_TIME_PHASE_NOT_SUPP',
                                    p_token1         => 'PLAN_TYPE',
                                    p_value1         => 'Financial Plan');

               l_plan_type_validated := 'N';
           END IF;
         END IF;
       END IF;

   IF l_plan_type_validated = 'Y' THEN
   -- gboomina added for AAI requirement 8318932 - end

    l_element_type_tab.delete;
    IF l_fin_plan_preference_code = 'COST_ONLY' THEN
        l_count := 1;
        l_element_type_tab(1) := 'COST';
        ELSIF l_fin_plan_preference_code = 'REVENUE_ONLY' THEN
        l_count := 1;
        l_element_type_tab(1) := 'REVENUE';
    ELSIF l_fin_plan_preference_code = 'COST_AND_REV_SEP' THEN
        l_count := 2;
        l_element_type_tab(1) := 'COST';
        l_element_type_tab(2) := 'REVENUE';
    ELSIF l_fin_plan_preference_code = 'COST_AND_REV_SAME' THEN
        --dbms_output.put_line('HERE++++++++');
        l_count := 1;
        l_element_type_tab(1) := 'ALL';
    END IF;


        IF l_plan_class_code = 'BUDGET' THEN
            FND_MESSAGE.SET_NAME( 'PA', 'PA_FP_BUDGET_GENERATION' );
            l_version_name :=  FND_MESSAGE.GET;
        ELSIF l_plan_class_code = 'FORECAST' THEN
            FND_MESSAGE.SET_NAME( 'PA', 'PA_FP_FORECAST_GENERATION' );
            l_version_name :=  FND_MESSAGE.GET;
        END IF;

    FOR i in 1..l_count LOOP
            l_generation_flag := 'Y';
            l_gen_api_call_flag := 'Y';

        IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                 (p_called_mode => l_called_mode,
                  p_msg         =>'Before calling
                      pa_fin_plan_pub.Create_Version',
                  p_module_name => l_module_name,
                  p_log_level   => 5);
                  pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => l_called_mode,
                  p_msg         =>'Value of Project_id: '||l_proj_id,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
                  pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => l_called_mode,
                  p_msg         =>'Value of fin_plan_type_id  : '||l_plan_type_id,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
                  pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => l_called_mode,
                  p_msg         =>'Element Type : '|| l_element_type_tab(i),
                  p_module_name => l_module_name,
                  p_log_level   => 5);
            END IF;

        --dbms_output.put_line('before create_version');
            --hr_utility.trace('before create_version');
        --dbms_output.put_line('Value of Project_id before calling create_version: '||l_proj_id);
            --hr_utility.trace('Value of Project_id before calling create_version:'||l_proj_id);
        --dbms_output.put_line('Value of fin_plan_type_id before calling create_version: '||l_plan_type_id);
        --hr_utility.trace('Value of fin_plan_type_id before calling create_version: '||l_plan_type_id);
        --dbms_output.put_line('Value of element_type before calling create_version: '||l_element_type_tab(i));
        --hr_utility.trace('Value of element_type before calling create_version: '||l_element_type_tab(i));
        --hr_utility.trace('Value of Version_Name before calling create_version: '||l_version_name);
        --hr_utility.trace('Value of px_budget_version_id before calling create_version: '||lx_budget_version_id);
        --hr_utility.trace('Value of x_proj_fp_option_id before calling create_version: '||lx_proj_fp_option_id);

            -- 3831449: pass 'GENERATE' as p_calling_context parameter to Create Version API

            /* Reseting lx_budget_version_id and lx_proj_fp_option_id  Bug 4029915 */
            FND_MSG_PUB.initialize;
            lx_budget_version_id := NULL;
            lx_proj_fp_option_id := NULL;

        BEGIN
        pa_fin_plan_pub.Create_Version(
            p_project_id        => l_proj_id,
        p_fin_plan_type_id      => l_plan_type_id,
        p_element_type          => l_element_type_tab(i),
        p_version_name      => l_version_name|| ' '||
                                           to_char(sysdate,'rrrr:mm:dd hh24:mi:ss'),
        p_description       => l_version_name|| ' '||
                                           to_char(sysdate,'rrrr:mm:dd hh24:mi:ss'),
        px_budget_version_id    => lx_budget_version_id,
        x_proj_fp_option_id     => lx_proj_fp_option_id,
        p_calling_context   => 'GENERATE',
        x_return_status     => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data      => l_msg_data);

            --dbms_output.put_line('l_return_status for create_version:' || l_return_status);
           -- hr_utility.trace('l_return_status for create_version:' || l_return_status);
           -- dbms_output.put_line('Newly created version is: '||lx_budget_version_id);
            --hr_utility.trace('Newly created version is: '||lx_budget_version_id);
        EXCEPTION
        WHEN OTHERS THEN
             l_generation_flag := 'N';
        END;

        IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                 (p_called_mode => l_called_mode,
                  p_msg         =>'Status aft calling pa_fin_plan_pub.Create_Version:'
                              ||l_return_status,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
            END IF;

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               IF p_pa_debug_mode = 'Y' THEN
                      pa_fp_gen_amount_utils.fp_debug
                     (p_called_mode => l_called_mode,
                      p_msg         =>'Raising invalid arg exc after create version api call',
                      p_module_name => l_module_name,
                      p_log_level   => 5);
                   END IF;
                   raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  l_generation_flag := 'N';
                  l_msg_count := FND_MSG_PUB.Count_Msg;
                  IF p_pa_debug_mode = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                     (p_called_mode => l_called_mode,
                      p_msg         =>
                      'Value of l_msg_count after calling create_version api: '||l_msg_count ,
                      p_module_name => l_module_name,
                     p_log_level   => 5);
                  END IF;

                  PA_DEBUG.g_err_stage := l_project_name_err_token || l_project_name ||
                  '   ' ||l_fin_plan_type_err_token || l_plan_type_name;
                  PA_DEBUG.log_Message( p_message => PA_DEBUG.g_err_stage,
                                        p_write_file => 'OUT',
                                        p_write_mode => 1);
                  IF l_msg_count > 0 THEN
                     IF l_msg_count = 1 THEN
                        l_msg_data_in := l_msg_data;
                        PA_INTERFACE_UTILS_PUB.get_messages
                          (p_encoded        => FND_API.G_FALSE,
                           p_msg_index      => 1,
                           p_msg_count      => 1,
                           p_msg_data       => l_msg_data_in,
                           p_data           => l_msg_data,
                           p_msg_index_out  => l_msg_index_out);
                       --dbms_output.put_line('x msg data in msg count 1 '||x_msg_data);
                       --dbms_output.put_line('l msg data in msg count 1: '||l_msg_data);
                       --hr_utility.trace('l msg data in msg count 1: '||l_msg_data);
                       --dbms_output.put_line('p msg index out in msg count 1:  '||l_msg_index_out);
                         PA_DEBUG.g_err_stage := l_msg_data;
                         PA_DEBUG.log_Message( p_message => PA_DEBUG.g_err_stage,
                                        p_write_file => 'OUT',
                                        p_write_mode => 1);
                    ELSE
                      FOR j in 1 .. l_msg_count LOOP
                         --dbms_output.put_line('inside the error loop ');
                         l_msg_data_in := l_msg_data;
                         pa_interface_utils_pub.get_messages
                         (p_encoded        => FND_API.G_FALSE,
                          p_msg_index      => j,
                          p_msg_count      => l_msg_count ,
                          p_msg_data       => l_msg_data_in ,
                          p_data           => l_msg_data,
                          p_msg_index_out  => l_msg_index_out );
                         PA_DEBUG.g_err_stage := l_msg_data;
                         PA_DEBUG.log_Message( p_message => PA_DEBUG.g_err_stage,
                                        p_write_file => 'OUT',
                                        p_write_mode => 1);
                         --dbms_output.put_line('error # '||j||' '|| substr(l_msg_Data,1,200));
                     END LOOP;
                  END IF;
               END IF;
            ELSE
                 COMMIT;
            END IF;    -- for the return status chk

            --dbms_output.put_line('Value of plan_class_code b4 calling get_plan_version_dtls api: '||l_plan_class_code );
            --hr_utility.trace('Value of plan_class_code b4 calling get_plan_version_dtls api: '||l_plan_class_code );
        IF l_plan_class_code = 'FORECAST' AND
               l_generation_flag = 'Y' THEN

                IF p_pa_debug_mode = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                      (p_called_mode => l_called_mode,
                       p_msg         => 'Before calling
                      pa_fp_gen_amount_utils.get_plan_version_dtls',
                       p_module_name => l_module_name,
                       p_log_level   => 5);
                END IF;
            --dbms_output.put_line('b4 calling get_plan_version_dtls api');
                BEGIN
                    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                (P_BUDGET_VERSION_ID       => lx_budget_version_id,
                     X_FP_COLS_REC             => l_fp_cols_rec,
                     X_RETURN_STATUS           => l_return_status,
                     X_MSG_COUNT               => l_msg_count,
                     X_MSG_DATA                => l_msg_data);
                 EXCEPTION
                 WHEN OTHERS THEN
                     l_gen_api_call_flag := 'N';
                 END;
           -- dbms_output.put_line('Status after calling get_plan_version_dtls api: '||l_return_status);
           -- hr_utility.trace('L_RETURN_Status after calling get_plan_version_dtls api: '||l_return_status);
                IF p_pa_debug_mode = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                      (p_called_mode => l_called_mode,
                       p_msg         => 'Status after calling
                                pa_fp_gen_amount_utils.get_plan_version_dtls'
                                ||l_return_status,
                       p_module_name => l_module_name,
                       p_log_level   => 5);
                END IF;

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               IF p_pa_debug_mode = 'Y' THEN
                      pa_fp_gen_amount_utils.fp_debug
                     (p_called_mode => l_called_mode,
                      p_msg     =>'Raising invalid arg exc after Get Plan ver dtls api call',
                      p_module_name => l_module_name,
                      p_log_level   => 5);
                   END IF;
                   raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       l_gen_api_call_flag := 'N';
                END IF;

            l_unspent_amt_period :=
          PA_FP_GEN_FCST_PG_PKG.GET_UNSPENT_AMT_PERIOD(lx_budget_version_id);
           -- dbms_output.put_line('Value of l_unspent_amt_period: '||l_unspent_amt_period);
           -- hr_utility.trace('Value of l_unspent_amt_period: '||l_unspent_amt_period);
            l_act_from_period :=
          PA_FP_GEN_FCST_PG_PKG.GET_ACT_FRM_PERIOD(lx_budget_version_id);
           -- dbms_output.put_line('Value of l_act_from_period: '||l_act_from_period);
           -- hr_utility.trace('Value of l_act_from_period: '||l_act_from_period);
            l_act_to_period :=
          PA_FP_GEN_FCST_PG_PKG.GET_ACT_TO_PERIOD(lx_budget_version_id);
           -- hr_utility.trace('Value of l_act_from_period: '||l_act_from_period);
           -- hr_utility.trace('Value of l_act_to_period: '||l_act_to_period);
            --dbms_output.put_line('Value of l_act_to_period: '||l_act_to_period);
            l_etc_from_period :=
          PA_FP_GEN_FCST_PG_PKG.GET_ETC_FRM_PERIOD(lx_budget_version_id);
            --dbms_output.put_line('Value of l_etc_from_period: '||l_etc_from_period);
            --hr_utility.trace('Value of l_etc_frm_period: '||l_etc_from_period);
            l_etc_to_period :=
          PA_FP_GEN_FCST_PG_PKG.GET_ETC_TO_PERIOD(lx_budget_version_id);
            --dbms_output.put_line('Value of l_etc_to_period: '||l_etc_to_period);
            --hr_utility.trace('Value of l_etc_to_period: '||l_etc_to_period);
            l_act_thru_period :=
          PA_FP_GEN_FCST_PG_PKG.GET_ACTUALS_THRU_PERIOD_DTLS(lx_budget_version_id, 'PERIOD');
            --dbms_output.put_line('Value of l_act_thru_period: '||l_act_thru_period);
            --hr_utility.trace('Value of l_act_thru_period: '||l_act_thru_period);
            l_act_thru_date := to_date(
          PA_FP_GEN_FCST_PG_PKG.GET_ACTUALS_THRU_PERIOD_DTLS(lx_budget_version_id,'END_DATE'),'RRRRMMDD');
            --dbms_output.put_line('Value of l_act_thru_date: '||l_act_thru_date);
             --hr_utility.trace('Value of l_act_thru_date: '||l_act_thru_date);
--------------------------------------

                -- Bug 4197956: We need to derive the Financial Plan / Work Plan generation
                -- source plan version information only in the following cases:
                -- 1) The generation source is Financial Plan / Work Plan respectively
                --    (i.e. the Target is a Revenue only version).
                -- 2) The generation source is Task Level Selection and at least one of the
                --    financial tasks has ETC generation source as Financial Plan / Work Plan,
                --    respectively.

                l_fin_plan_src_dtls_flag := 'N';
                l_workplan_src_dtls_flag := 'N';
                --bug 9195544 : START : skkoppul : reset the local variables to NULL
                l_etc_wp_struct_ver_id := NULL;
                l_etc_fp_ver_name      := NULL;
                l_etc_fp_ver_id        := NULL;
                l_etc_wp_fin_ver_id    := NULL;
                l_etc_fp_type_id       := NULL;
                --bug 9195544 : END : skkoppul : reset the local variables to NULL

                IF l_fp_cols_rec.x_gen_etc_src_code = lc_FinancialPlan THEN
                    l_fin_plan_src_dtls_flag := 'Y';
                ELSIF l_fp_cols_rec.x_gen_etc_src_code = lc_WorkplanResources THEN
                    l_workplan_src_dtls_flag := 'Y';
                ELSIF l_fp_cols_rec.x_gen_etc_src_code = lc_TaskLevelSel THEN
                    SELECT count(*) INTO l_fin_plan_count
                    FROM   pa_tasks
                    WHERE  project_id = l_proj_id
                    AND    gen_etc_source_code = lc_FinancialPlan
                    AND    rownum < 2;

                    IF l_fin_plan_count > 0 THEN
                        l_fin_plan_src_dtls_flag := 'Y';
                    END IF;

                    SELECT count(*) INTO l_workplan_count
                    FROM   pa_tasks
                    WHERE  project_id = l_proj_id
                    AND    gen_etc_source_code = lc_WorkplanResources
                    AND    rownum < 2;

                    IF l_workplan_count > 0 THEN
                        l_workplan_src_dtls_flag := 'Y';
                    END IF;
                END IF;

                IF l_workplan_src_dtls_flag = 'Y' THEN

                    IF l_fp_cols_rec.x_gen_src_wp_version_id is not NULL THEN

         -- Mani
                            --hr_utility.trace('fp cols rec gen src wp version id  not null '||
                             --l_fp_cols_rec.x_gen_src_wp_version_id );
                        l_etc_wp_fin_ver_id := l_fp_cols_rec.x_gen_src_wp_version_id;
                            select project_structure_version_id into l_etc_wp_struct_ver_id
                            from pa_budget_versions
                            where budget_version_id = l_etc_wp_fin_ver_id;

                    END IF;

                    IF l_fp_cols_rec.x_gen_src_wp_version_id  is NULL THEN
                        l_versioning_enabled :=
                            PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_proj_id);
                        IF l_versioning_enabled = 'Y' THEN
                            /*Get latest published/current working/baselined work plan version id*/
                            l_gen_src_wp_ver_code := l_fp_cols_rec.x_gen_src_wp_ver_code;
                            IF (l_gen_src_wp_ver_code = 'LAST_PUBLISHED') THEN
                                        l_etc_wp_struct_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(
                                    P_PROJECT_ID => l_proj_id ) ;
                          --  hr_utility.trace('inside last published wp : '|| l_etc_wp_struct_ver_id );
                                        IF l_etc_wp_struct_ver_id is null THEN
                                            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                                  p_msg_name       => 'PA_LATEST_WPID_NULL');
                                        l_gen_api_call_flag := 'N';
                                            --raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                END IF;
                            ELSIF (l_gen_src_wp_ver_code = 'CURRENT_WORKING') THEN
                                l_etc_wp_struct_ver_id :=
                                    PA_PROJECT_STRUCTURE_UTILS.GET_CURRENT_WORKING_VER_ID(P_PROJECT_ID => l_proj_id );
                                IF l_etc_wp_struct_ver_id is null THEN
                                            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                                  p_msg_name       => 'PA_CW_WPID_NULL');
                                        l_gen_api_call_flag := 'N';
                                            --raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                END IF;
                            -- Bug 4426511: Changed 'BASELINE', which was INCORRECT, to 'BASELINED'.
                            ELSIF (l_gen_src_wp_ver_code = 'BASELINED') THEN
                                l_etc_wp_struct_ver_id :=
                                    PA_PROJECT_STRUCTURE_UTILS.GET_BASELINE_STRUCT_VER(P_PROJECT_ID => l_proj_id );
                                IF l_etc_wp_struct_ver_id is null THEN
                                            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                              p_msg_name       => 'PA_BASELINED_WPID_NULL');
                                        l_gen_api_call_flag := 'N';
                                            --raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                END IF;
                            END IF;     -- end if for ver code
                        ELSE
                                 -- versioning disabled case
                            l_etc_wp_struct_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(
                                            P_PROJECT_ID => l_proj_id);
                            IF l_etc_wp_struct_ver_id is null THEN
                                        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                              p_msg_name       => 'PA_LATEST_WPID_NULL');
                                        l_gen_api_call_flag := 'N';
                            END IF;
                        END IF;  -- version enabled chk
                            l_etc_wp_fin_ver_id := Pa_Fp_wp_gen_amt_utils.get_wp_version_id(
                            p_project_id      => l_proj_id,
                            p_plan_type_id    => l_plan_type_id,
                            p_proj_str_ver_id => l_etc_wp_struct_ver_id);
                            --hr_utility.trace('after calling fn etc wp fin ver id : '||
                            --l_etc_wp_fin_ver_id );
                            END IF;  -- fp cols rec check
                    /*We need the strcut_ver_id for fcst_amt_gen,
                          wp_fin_plan_ver_id to update back to pa_proj_fp_options*/

                END IF; -- l_workplan_src_dtls_flag

                IF l_fin_plan_src_dtls_flag = 'Y' THEN

                    l_gen_src_plan_ver_code :=  l_fp_cols_rec.X_GEN_SRC_PLAN_VER_CODE;
                    IF l_gen_src_plan_ver_code = 'CURRENT_BASELINED'
                            OR l_gen_src_plan_ver_code = 'ORIGINAL_BASELINED'
                            OR l_gen_src_plan_ver_code = 'CURRENT_APPROVED'
                            OR l_gen_src_plan_ver_code = 'ORIGINAL_APPROVED' THEN
                        /*Get the current baselined or original baselined version*/
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_fp_gen_amount_utils.fp_debug
                          (p_called_mode => l_called_mode,
                           p_msg         => 'Before calling pa_fp_gen_amount_utils.Get_Curr_Original_Version_Info',
                           p_module_name => l_module_name,
                           p_log_level   => 5);
                        END IF;
                        --hr_utility.trace('pa_fp_gen_amount_utils.Get_Curr_Original_Version_Info');
                        pa_fp_gen_amount_utils.Get_Curr_Original_Version_Info(
                            p_project_id                => l_proj_id,
                            p_fin_plan_type_id          => l_fp_cols_rec.X_GEN_SRC_PLAN_TYPE_ID,
                            p_version_type              => NULL,                                 -- bug 7032123 skkoppul : changed COST to NULL
                            p_status_code               => l_gen_src_plan_ver_code,
                            x_fp_options_id             => l_fp_options_id,
                            x_fin_plan_version_id       => l_etc_fp_ver_id,
                            x_return_status             => l_return_status,
                            x_msg_count                 => l_msg_count,
                            x_msg_data                  => l_msg_data);
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_fp_gen_amount_utils.fp_debug
                          (p_called_mode => l_called_mode,
                           p_msg         =>'After calling pa_fp_gen_amount_utils.Get_Curr_Original_Version_Info,return status is: '
                                                    ||l_return_status,
                           p_module_name => l_module_name,
                           p_log_level   => 5);
                        END IF;


                        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                           IF p_pa_debug_mode = 'Y' THEN
                              pa_fp_gen_amount_utils.fp_debug
                              (p_called_mode => l_called_mode,
                               p_msg=>'Raising invalid arg exc aft Get Curr Original ver api call',
                               p_module_name => l_module_name,
                               p_log_level   => 5);
                           END IF;
                           raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        END IF;
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           l_gen_api_call_flag := 'N';
                        END IF;


                    ELSIF l_gen_src_plan_ver_code = 'CURRENT_WORKING' THEN
                        /*Get the current working version*/
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_fp_gen_amount_utils.fp_debug
                          (p_called_mode => l_called_mode,
                           p_msg         => 'Before calling pa_fin_plan_utils.Get_Curr_Working_Version_Info',
                           p_module_name => l_module_name,
                           p_log_level   => 5);
                        END IF;
                        pa_fin_plan_utils.Get_Curr_Working_Version_Info(
                            p_project_id                => l_proj_id,
                            p_fin_plan_type_id          => l_fp_cols_rec.X_GEN_SRC_PLAN_TYPE_ID,
                            p_version_type              => NULL,                                    -- bug 7032123 skkoppul : changed COST to NULL
                            x_fp_options_id             => l_fp_options_id,
                            x_fin_plan_version_id       => l_etc_fp_ver_id,
                            x_return_status             => l_return_status,
                            x_msg_count                 => l_msg_count,
                            x_msg_data                  => l_msg_data);
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_fp_gen_amount_utils.fp_debug
                          (p_called_mode => l_called_mode,
                           p_msg         =>
                           'Aft calling pa_fin_plan_utils.Get_Curr_Working_Version_Info ret sta:'
                                            ||l_return_status,
                           p_module_name => l_module_name,
                           p_log_level   => 5);
                        END IF;

                        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                           IF p_pa_debug_mode = 'Y' THEN
                              pa_fp_gen_amount_utils.fp_debug
                              (p_called_mode => l_called_mode,
                               p_msg=>'Raising invalid arg exc aft Get Curr Wkg ver api call',
                               p_module_name => l_module_name,
                               p_log_level   => 5);
                           END IF;
                           raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        END IF;
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           l_gen_api_call_flag := 'N';
                        END IF;
                    END IF;

                    IF l_etc_fp_ver_id IS NULL THEN
                        --hr_utility.trace('l_etc_fp_ver_id is null chk and raising error');
                        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_SRC_FP_VER_NULL');
                           l_gen_api_call_flag := 'N';
                    ELSE
                    SELECT version_name INTO l_etc_fp_ver_name
                    FROM pa_budget_versions
                    WHERE budget_version_id = l_etc_fp_ver_id;

                    l_etc_fp_type_id := l_fp_cols_rec.X_GEN_SRC_PLAN_TYPE_ID;
                    END IF;

                END IF; -- l_fin_plan_src_dtls_flag

          -- gboomina added for AAI requirement 8318932 - start
          -- If Copy ETC from Plan flag is selected, then validate whether
          -- Source Work plan and Financial Plan time phased and ETC Source for
          -- Source Work plan is either 'Workplan Resources' or 'Financial Plan'
          IF l_copy_etc_from_plan_flag = 'Y' THEN
            BEGIN --Begining of the block for validation_for_copy_etc_flag
              IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                     (p_msg         => 'Before calling
                                     pa_fp_gen_fcst_pg_pkg.validation_for_copy_etc_flag',
                      p_module_name => l_module_name,
                      p_log_level   => 5);
              END IF;
              -- Calling the following method to validate time phase and ETC source of
              -- source plan
              pa_fp_gen_fcst_pg_pkg.validation_for_copy_etc_flag
                  (p_project_id          => l_fp_cols_rec.x_project_id,
                   p_wp_version_id       => l_etc_wp_fin_ver_id,
                   p_etc_plan_version_id => l_etc_fp_ver_id,
                   x_return_status       => l_return_status,
                   x_msg_count           => l_msg_count,
                   x_msg_data                 => l_msg_data);
              IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                     (p_msg         => 'Status after calling
                      pa_fp_gen_fcst_pg_pkg.validation_for_copy_etc_flag: '
                                      ||l_return_status,
                      p_module_name => l_module_name,
                      p_log_level   => 5);
              END IF;
            EXCEPTION
            WHEN OTHERS THEN
               rollback;
               l_gen_api_call_flag := 'N';
               l_return_status := FND_API.G_RET_STS_ERROR;
               l_msg_count     := 1;
               l_msg_data      := substr(sqlerrm,1,240);
               IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_fp_gen_amount_utils.fp_debug
                            (p_called_mode => l_called_mode,
                             p_msg         => 'Error: Validate Copy ETC from Plan'||l_msg_data,
                             p_module_name => l_module_name,
                             p_log_level   => 5);
               END IF;
            END; --End of the block for validation_for_copy_etc_flag

          END IF;
        -- gboomina added for AAI requirement 8318932 - end

        /*As of now, we have the l_etc_wp_struct_ver_id and l_etc_fp_ver_id*/
        /*update the etc source version id back to pa_proj_fp_options*/
        IF l_element_type_tab(i) = 'COST' THEN
            UPDATE PA_PROJ_FP_OPTIONS
            SET GEN_SRC_COST_PLAN_TYPE_ID = l_etc_fp_type_id,
                GEN_SRC_COST_PLAN_VERSION_ID = l_etc_fp_ver_id,
                GEN_SRC_COST_WP_VERSION_ID = l_etc_wp_fin_ver_id
            WHERE fin_plan_version_id = lx_budget_version_id;
        ELSIF l_element_type_tab(i) = 'REVENUE' THEN
            UPDATE PA_PROJ_FP_OPTIONS
            SET GEN_SRC_REV_PLAN_TYPE_ID = l_etc_fp_type_id,
                GEN_SRC_REV_PLAN_VERSION_ID = l_etc_fp_ver_id,
                GEN_SRC_REV_WP_VERSION_ID = l_etc_wp_fin_ver_id
            WHERE fin_plan_version_id = lx_budget_version_id;
        ELSIF l_element_type_tab(i) = 'ALL' THEN
            UPDATE PA_PROJ_FP_OPTIONS
            SET GEN_SRC_ALL_PLAN_TYPE_ID = l_etc_fp_type_id,
                GEN_SRC_ALL_PLAN_VERSION_ID = l_etc_fp_ver_id,
                GEN_SRC_ALL_WP_VERSION_ID = l_etc_wp_fin_ver_id
            WHERE fin_plan_version_id = lx_budget_version_id;
        END IF;

                l_struct_sharing_code := PA_PROJECT_STRUCTURE_UTILS.
                        get_structure_sharing_code(p_project_id=>l_proj_id);

        --hr_utility.trace('l_etc_fp_type_id : '||l_etc_fp_type_id);
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
           (p_called_mode => l_called_mode,
            p_msg         => 'Before calling PA_FP_GEN_FCST_AMT_PUB.GENERATE_FCST_AMT_WRP'||
                             'l_proj_id = '||l_proj_id,
            p_module_name => l_module_name,
            p_log_level   => 5);

           pa_fp_gen_amount_utils.fp_debug
           (p_called_mode => l_called_mode,
            p_msg         => 'Budget version id :'||lx_budget_version_id,
            p_module_name => l_module_name,
            p_log_level   => 5);
           pa_fp_gen_amount_utils.fp_debug
           (p_called_mode => l_called_mode,
            p_msg         => 'ver type : Unspent amt flag '||
                             l_element_type_tab(i)|| ' : '||
                             l_fp_cols_rec.x_gen_incl_unspent_amt_flag,
            p_module_name => l_module_name,
            p_log_level   => 5);
           pa_fp_gen_amount_utils.fp_debug
           (p_called_mode => l_called_mode,
            p_msg         => 'unspent amt pd : Incu chg doc flag '||
                             l_unspent_amt_period|| ' : ' ||
                             l_fp_cols_rec.x_gen_incl_change_doc_flag,
            p_module_name => l_module_name,
            p_log_level   => 5);
           pa_fp_gen_amount_utils.fp_debug
           (p_called_mode => l_called_mode,
            p_msg         => 'Incl Open cmt  : Incu bill events ' ||
                             l_fp_cols_rec.x_gen_incl_open_comm_flag|| ' : ' ||
                             l_fp_cols_rec.x_gen_incl_bill_event_flag,
            p_module_name => l_module_name,
            p_log_level   => 5);
           pa_fp_gen_amount_utils.fp_debug
           (p_called_mode => l_called_mode,
            p_msg         => 'Ret manual lines : ETC plan type id ' ||
                             l_fp_cols_rec.x_gen_ret_manual_line_flag || ' : ' ||
                             l_fp_cols_rec.X_GEN_SRC_PLAN_TYPE_ID,
            p_module_name => l_module_name,
            p_log_level   => 5);
           pa_fp_gen_amount_utils.fp_debug
           (p_called_mode => l_called_mode,
            p_msg         => 'ver name : etc fp ver id ' ||
                             l_etc_fp_ver_name || ' : ' ||
                             l_etc_fp_ver_id,
            p_module_name => l_module_name,
            p_log_level   => 5);
           pa_fp_gen_amount_utils.fp_debug
           (p_called_mode => l_called_mode,
            p_msg         => 'Act fr pd : Act to Pd ' ||
                             l_act_from_period || ' : ' ||
                             l_act_to_period,
            p_module_name => l_module_name,
            p_log_level   => 5);
           pa_fp_gen_amount_utils.fp_debug
           (p_called_mode => l_called_mode,
            p_msg         => 'ETC fr pd : ETC to Pd ' ||
                             l_etc_from_period || ' : ' ||
                             l_etc_to_period,
            p_module_name => l_module_name,
            p_log_level   => 5);
           /* sysdate is used just for log message. The date should not be
              modified. */
           pa_fp_gen_amount_utils.fp_debug
           (p_called_mode => l_called_mode,
            p_msg         => 'Actu thru pd : Actu thru Dt '||
                             l_act_thru_period || ' : ' ||
                             to_char(nvl(l_act_thru_date,trunc(sysdate)),'mm/dd/yyyy'),
            p_module_name => l_module_name,
            p_log_level   => 5);
           pa_fp_gen_amount_utils.fp_debug
           (p_called_mode => l_called_mode,
            p_msg         => 'ETC WP Str Ver id :' ||
                             l_etc_wp_struct_ver_id,
            p_module_name => l_module_name,
            p_log_level   => 5);
        END IF;
/*
hr_utility.trace('l_proj_id  '||l_proj_id);
hr_utility.trace('lx_budget_version_id '||lx_budget_version_id);
hr_utility.trace('l_element_type_tab(i)  ' ||l_element_type_tab(i));
hr_utility.trace('l_fp_cols_rec.x_gen_incl_unspent_amt_flag  '||l_fp_cols_rec.x_gen_incl_unspent_amt_flag);
hr_utility.trace('l_unspent_amt_period '||l_unspent_amt_period);
hr_utility.trace('l_fp_cols_rec.x_gen_incl_change_doc_flag'||l_fp_cols_rec.x_gen_incl_change_doc_flag);
hr_utility.trace('l_fp_cols_rec.x_gen_incl_open_comm_flag  '||l_fp_cols_rec.x_gen_incl_open_comm_flag);
hr_utility.trace('l_fp_cols_rec.x_gen_incl_bill_event_flag  '||l_fp_cols_rec.x_gen_incl_bill_event_flag);
hr_utility.trace('l_fp_cols_rec.x_gen_ret_manual_line_flag  '||l_fp_cols_rec.x_gen_ret_manual_line_flag);
hr_utility.trace('l_fp_cols_rec.X_GEN_SRC_PLAN_TYPE_ID  '||l_fp_cols_rec.X_GEN_SRC_PLAN_TYPE_ID);
hr_utility.trace('l_etc_fp_ver_id  '||l_etc_fp_ver_id);
hr_utility.trace('l_etc_fp_ver_name  '||l_etc_fp_ver_name);
hr_utility.trace('l_act_from_period  '||l_act_from_period);
hr_utility.trace('l_act_to_period '||l_act_to_period);
hr_utility.trace('l_etc_from_period '||l_etc_from_period);
hr_utility.trace('l_etc_to_period  '||l_etc_to_period);
hr_utility.trace('l_act_thru_period  l_Orig_Version_flag'||l_act_thru_period);
hr_utility.trace('l_act_thru_date  '||l_act_thru_date);
hr_utility.trace('l_etc_wp_struct_ver_id  '||l_etc_wp_struct_ver_id);
hr_utility.trace('l_return_status before gen fcst amt  '||l_return_status);
hr_utility.trace('l_gen_api_call_flag before gen fcst amt  '||l_gen_api_call_flag);
*/

           IF l_gen_api_call_flag = 'Y' THEN
             BEGIN
                IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                       ( p_called_mode => l_called_mode,
                         p_msg         => 'Before calling
                                           pa_fp_gen_amount_utils.validate_support_cases',
                         p_module_name => l_module_name,
                         p_log_level   => 5 );
                END IF;
                PA_FP_GEN_AMOUNT_UTILS.VALIDATE_SUPPORT_CASES (
                    P_FP_COLS_REC_TGT       => l_fp_cols_rec,
                    P_CALLING_CONTEXT       => 'CONCURRENT',
                    X_WARNING_MESSAGE       => l_warning_message, /* Added for ER 4391321 */
                    X_RETURN_STATUS         => l_return_status,
                    X_MSG_COUNT             => l_msg_count,
                    X_MSG_DATA              => l_msg_data );
                IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                       ( p_called_mode => l_called_mode,
                         p_msg         => 'Status after calling
                                          pa_fp_gen_amount_utils.validate_support_cases: '
                                          ||l_return_status,
                         p_module_name => l_module_name,
                         p_log_level   => 5 );
                END IF;
                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    IF p_pa_debug_mode = 'Y' THEN
                        pa_fp_gen_amount_utils.fp_debug
                          (p_called_mode => l_called_mode,
                           p_msg=>'Raising invalid arg exc aft validation api call',
                           p_module_name => l_module_name,
                           p_log_level   => 5);
                    END IF;
                    raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    l_gen_api_call_flag := 'N';
                END IF;
            PA_FP_GEN_FCST_AMT_PUB.GENERATE_FCST_AMT_WRP
                 (P_PROJECT_ID      => l_proj_id,
              P_BUDGET_VERSION_ID   => lx_budget_version_id,
              P_FP_COLS_REC     => l_fp_cols_rec,
              P_CALLED_MODE     => 'CONCURRENT',
              P_COMMIT_FLAG     => 'Y',
              P_INIT_MSG_FLAG   => 'Y',
              P_VERSION_TYPE    => l_element_type_tab(i),
                  P_UNSPENT_AMT_FLAG    => l_fp_cols_rec.x_gen_incl_unspent_amt_flag,
              P_UNSPENT_AMT_PERIOD  => l_unspent_amt_period,
              P_INCL_CHG_DOC_FLAG   => l_fp_cols_rec.x_gen_incl_change_doc_flag,
              P_INCL_OPEN_CMT_FLAG  => l_fp_cols_rec.x_gen_incl_open_comm_flag,
              P_INCL_BILL_EVT_FLAG  => l_fp_cols_rec.x_gen_incl_bill_event_flag,
              P_RET_MANUAL_LNS_FLAG => l_fp_cols_rec.x_gen_ret_manual_line_flag,
              P_PLAN_TYPE_ID        => NULL,
              P_PLAN_VERSION_ID     => NULL,
              P_PLAN_VERSION_NAME   => NULL,
              P_ETC_PLAN_TYPE_ID    => l_fp_cols_rec.X_GEN_SRC_PLAN_TYPE_ID,
              P_ETC_PLAN_VERSION_ID => l_etc_fp_ver_id,
              P_ETC_PLAN_VERSION_NAME=> l_etc_fp_ver_name,
              P_ACTUALS_FROM_PERIOD => l_act_from_period,
              P_ACTUALS_TO_PERIOD   => l_act_to_period,
              P_ETC_FROM_PERIOD     => l_etc_from_period,
              P_ETC_TO_PERIOD       => l_etc_to_period,
              P_ACTUALS_THRU_PERIOD => l_act_thru_period,
              P_ACTUALS_THRU_DATE   => l_act_thru_date,
              P_WP_STRUCTURE_VERSION_ID =>l_etc_wp_struct_ver_id,
              X_RETURN_STATUS       => l_return_status,
              X_MSG_COUNT           => l_msg_count,
              X_MSG_DATA        => l_msg_data );
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                     (p_called_mode => l_called_mode,
                      p_msg         =>
                      'After calling PA_FP_GEN_FCST_AMT_PUB.GENERATE_FCST_AMT_WRP'||
                    ' ret status is:'||l_return_status,
                      p_module_name => l_module_name,
                      p_log_level   => 5);
                 END IF;
                     -- hr_utility.trace('l_return_status after GENERATE_FCST_AMT_WRP '||l_return_status);
                     -- hr_utility.trace('l_version_generation GENERATE_FCST_AMT_WRP '||l_generation_flag);

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   IF p_pa_debug_mode = 'Y' THEN
                          pa_fp_gen_amount_utils.fp_debug
                          (p_called_mode => l_called_mode,
                           p_msg=>'Raising invalid arg exc aft Fcst Gen api call',
                           p_module_name => l_module_name,
                           p_log_level   => 5);
                       END IF;
                     raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     -- hr_utility.trace('EXCEPTION ERROR FROM GENERATE_FCST_AMT_WRP');
                     l_gen_api_call_flag := 'N';
                END IF;
               EXCEPTION
/*xxxxx*/
                WHEN OTHERS THEN
                    -- hr_utility.trace('Inside Forecast Gen others  Ex');
                   rollback;
                   l_return_status := FND_API.G_RET_STS_ERROR;
                   l_msg_count     := 1;
                   l_msg_data      := substr(sqlerrm,1,240);
                   --dbms_output.put_line('error msg :'||x_msg_data);
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                               pa_fp_gen_amount_utils.fp_debug
                                (p_called_mode => l_called_mode,
                                 p_msg         => 'Forecast Gen Error'||l_msg_data,
                                 p_module_name => l_module_name,
                                 p_log_level   => 5);
                   END IF;
             END; --End of the block for FORCAST AMT GEN


             END IF; --for IF condition checking the l_gen_api_call_flag
                     -- hr_utility.trace('l_return_status after FCST GEN '||l_return_status);
                     -- hr_utility.trace('l_gen_api_call_flag _flag after FCST GEN '||l_gen_api_call_flag);
        ELSIF l_plan_class_code = 'BUDGET' AND
                  l_generation_flag = 'Y' AND
                  l_gen_api_call_flag = 'Y' THEN
            IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                     (p_called_mode => l_called_mode,
                      p_msg         =>
                      'Before calling PA_FP_WP_GEN_BUDGET_AMT_PUB.GENERATE_WP_BUDGET_AMT'||
                            'Proj  Id  : '||to_char(l_proj_id) ||
                            'Budget Version id : '|| lx_budget_version_id,
                      p_module_name => l_module_name,
                      p_log_level   => 5);
                END IF;
            --dbms_output.put_line('before budget generation');
            --dbms_output.put_line('before calling GENERATE_BUDGET_AMT_WRP');
            -- hr_utility.trace('before calling GENERATE_BUDGET_AMT_WRP');
                     -- hr_utility.trace('l_return_status after FCST GEN '||l_return_status);
                     -- hr_utility.trace('l_gen_api_call_flag after FCST GEN '||l_gen_api_call_flag);
                     -- hr_utility.trace('l_proj_id GENERATE_BUDGET_AMT_WRP '|| l_proj_id);
                     -- hr_utility.trace('lx_budget_version_id GENERATE_BUDGET_AMT_WRP '||lx_budget_version_id);
                     -- hr_utility.trace(' l_fp_cols_rec.X_GEN_SRC_PLAN_TYPE_ID '|| l_fp_cols_rec.X_GEN_SRC_PLAN_TYPE_ID);

         BEGIN
            PA_FP_GEN_BUDGET_AMT_PUB.GENERATE_BUDGET_AMT_WRP (
          P_PROJECT_ID      => l_proj_id,
              P_BUDGET_VERSION_ID   => lx_budget_version_id,
              P_CALLED_MODE     => 'CONCURRENT',
              P_COMMIT_FLAG     => 'Y',
              P_INIT_MSG_FLAG   => 'Y',
                  X_WARNING_MESSAGE     => l_warning_message, /* Added for ER 4391321 */
              X_RETURN_STATUS   => l_return_status,
              X_MSG_COUNT       => l_msg_count,
              X_MSG_DATA        => l_msg_data );
            -- dbms_output.put_line('after budget generation l_rest_status: '||l_return_status);
            -- hr_utility.trace('after budget generation l_rest_status: '||l_return_status);
            -- dbms_output.put_line('after budget generation lx_budget_version_id: '||lx_budget_version_id);
            -- hr_utility.trace('after budget generation lx_budget_version_id: '||lx_budget_version_id);
            -- dbms_output.put_line('after budget generation l_proj_id: '||l_proj_id);
            -- hr_utility.trace('after budget generation l_proj_id: '||l_proj_id);
            -- dbms_output.put_line(': '||FND_API.G_RET_STS_SUCCESS);
            -- hr_utility.trace('FND API. G RET STS SUCCESS: '||FND_API.G_RET_STS_SUCCESS);
            IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                     (p_called_mode => l_called_mode,
                      p_msg         => 'Status after calling
                               PA_FP_WP_GEN_BUDGET_AMT_PUB.GENERATE_WP_BUDGET_AMT:'
                                ||l_return_status,
                      p_module_name => l_module_name,
                      p_log_level   => 5);
                END IF;
                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   IF p_pa_debug_mode = 'Y' THEN
                          pa_fp_gen_amount_utils.fp_debug
                          (p_called_mode => l_called_mode,
                           p_msg=>'Raising invalid arg exc aft Bdgt Gen api call',
                           p_module_name => l_module_name,
                           p_log_level   => 5);
                       END IF;
                     raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
  /*xxxxxx*/
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     -- hr_utility.trace('EXCEPTION ERROR FROM GENERATE_BUDGET_AMT_WRP');
                     l_gen_api_call_flag := 'N';
                END IF;
          EXCEPTION
               WHEN OTHERS THEN
                    -- hr_utility.trace('Inside others  Ex');
                   rollback;
                   l_return_status := FND_API.G_RET_STS_ERROR;
                   l_msg_count     := 1;
                   l_msg_data      := substr(sqlerrm,1,240);
                   --dbms_output.put_line('error msg :'||x_msg_data);
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                               pa_fp_gen_amount_utils.fp_debug
                                (p_called_mode => l_called_mode,
                                 p_msg         => 'Budget Gen  Error'||l_msg_data,
                                 p_module_name => l_module_name,
                                 p_log_level   => 5);
                   END IF;
           END; --End of block for Budget Amt Gen



        END IF;--For IF condition for BUDGET

               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 -- hr_utility.trace('INVALID EXCEPTION!!!');
                   IF p_pa_debug_mode = 'Y' THEN
                          pa_fp_gen_amount_utils.fp_debug
                          (p_called_mode => l_called_mode,
                           p_msg=>'Raising invalid arg exc aft Fcst / Bdgt Gen api call',
                           p_module_name => l_module_name,
                           p_log_level   => 5);
                       END IF;
                     raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  l_gen_api_call_flag := 'N';
               END IF;

               IF l_gen_api_call_flag = 'N' THEN
                   l_msg_count := FND_MSG_PUB.Count_Msg;
                   IF p_pa_debug_mode = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                     (p_called_mode => l_called_mode,
                      p_msg         =>
                      'Value of l_msg_count after calling Budget / Forecast Gen API'
                      ||l_msg_count,
                      p_module_name => l_module_name,
                      p_log_level   => 5);
                   END IF;
                   IF l_msg_count > 0 THEN
                      PA_DEBUG.g_err_stage := l_project_name_err_token || l_project_name ||
                      '   ' ||l_fin_plan_type_err_token || l_plan_type_name;
                      PA_DEBUG.log_Message( p_message => PA_DEBUG.g_err_stage,
                                        p_write_file => 'OUT',
                                        p_write_mode => 1);
                     IF l_msg_count = 1 THEN
                        l_msg_data_in := l_msg_data;
                        PA_INTERFACE_UTILS_PUB.get_messages
                          (p_encoded        => FND_API.G_FALSE,
                           p_msg_index      => 1,
                           p_msg_count      => 1,
                           p_msg_data       => l_msg_data_in ,
                           p_data           => l_msg_data,
                           p_msg_index_out  => l_msg_index_out);

                        PA_DEBUG.g_err_stage := l_msg_data;
                        PA_DEBUG.log_Message( p_message => PA_DEBUG.g_err_stage,
                                        p_write_file => 'OUT',
                                        p_write_mode => 1);
                       --dbms_output.put_line('x msg data in msg count 1 '||x_msg_data);
                       --dbms_output.put_line('l msg data in msg count 1: '||l_msg_data);
                       --dbms_output.put_line('p msg index out in msg count 1:  '||l_msg_index_out);
                     ELSE
                      FOR j in 1 .. l_msg_count LOOP
                         --dbms_output.put_line('inside the error loop ');
                         l_msg_data_in := l_msg_data;
                         pa_interface_utils_pub.get_messages
                         (p_encoded        => FND_API.G_FALSE,
                          p_msg_index      => j,
                          p_msg_count      => l_msg_count ,
                          p_msg_data       => l_msg_data_in ,
                          p_data           => l_msg_data,
                          p_msg_index_out  => l_msg_index_out );

                        PA_DEBUG.g_err_stage := l_msg_data;
                        PA_DEBUG.log_Message( p_message => PA_DEBUG.g_err_stage,
                                        p_write_file => 'OUT',
                                        p_write_mode => 1);
                        -- dbms_output.put_line('error # '||j||' '||substr(l_msg_Data,1,200));
                     END LOOP;
                    END IF;
                END IF;
            END IF;
            /* end if for plan class code */

    END LOOP;
     -- gboomina added for AAI requirements 8318932 - start
     -- Added code to handle error after processing each plan type
     END IF;
       IF l_plan_type_validated = 'N' THEN
           l_msg_count := FND_MSG_PUB.Count_Msg;
           IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => l_called_mode,
              p_msg         =>
              'Value of l_msg_count after processing Plan Type :'||l_plan_type_name
              ||l_msg_count,
              p_module_name => l_module_name,
              p_log_level   => 5);
           END IF;
           IF l_msg_count > 0 THEN
              PA_DEBUG.g_err_stage := l_project_name_err_token || l_project_name ||
              '   ' ||l_fin_plan_type_err_token || l_plan_type_name;
              PA_DEBUG.log_Message( p_message => PA_DEBUG.g_err_stage,
                                p_write_file => 'OUT',
                                p_write_mode => 1);
             IF l_msg_count = 1 THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                  (p_encoded        => FND_API.G_FALSE,
                   p_msg_index      => 1,
                   p_msg_count      => 1,
                   p_msg_data       => l_msg_data ,
                   p_data           => l_msg_data,
                   p_msg_index_out  => l_msg_index_out);

                PA_DEBUG.g_err_stage := l_msg_data;
                PA_DEBUG.log_Message( p_message => PA_DEBUG.g_err_stage,
                                p_write_file => 'OUT',
                                p_write_mode => 1);
             ELSE
               FOR j in 1 .. l_msg_count LOOP
                 pa_interface_utils_pub.get_messages
                 (p_encoded        => FND_API.G_FALSE,
                  p_msg_index      => j,
                  p_msg_count      => l_msg_count ,
                  p_msg_data       => l_msg_data ,
                  p_data           => l_msg_data,
                  p_msg_index_out  => l_msg_index_out );

                PA_DEBUG.g_err_stage := l_msg_data;
                PA_DEBUG.log_Message( p_message => PA_DEBUG.g_err_stage,
                                p_write_file => 'OUT',
                                p_write_mode => 1);
               END LOOP;
             END IF;
           END IF;
       END IF;
       -- gboomina added for AAI requirements 8318932 - end
   END LOOP;

    DBMS_SQL.CLOSE_CURSOR(sql_cursor); -- Bug 5715252 Cursor is closed

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
    -- hr_utility.trace('Inside invalid arg Ex');
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
            l_msg_data := l_data;
        END IF;

        ROLLBACK;

    -- hr_utility.trace('Outside Ex');
    -- hr_utility.trace('Outside-l_return_status'||l_return_status);
        l_return_status := FND_API.G_RET_STS_ERROR;
    -- hr_utility.trace('Outside Error-l_return_status'||l_return_status);

    IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                     (p_called_mode => l_called_mode,
                      p_msg         => 'Invalid Arg Exc Error'||substr(sqlerrm, 1, 240),
                      p_module_name => l_module_name,
                      p_log_level   => 5);
        PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;

        retcode := '2';
        errbuff := substr(sqlerrm,1,240);

        /* Start Bug 5715252 */
           IF DBMS_SQL.IS_OPEN(sql_cursor) THEN
             DBMS_SQL.CLOSE_CURSOR(sql_cursor);
           END IF;
        /* End  Bug 5715252 */

        RAISE;

    WHEN OTHERS THEN
    -- hr_utility.trace('Inside others  Ex');
        rollback;
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        l_msg_count     := 1;
        l_msg_data      := substr(sqlerrm,1,240);
        --dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => ' PA_FP_GEN_AMT_WRP_PKG',
                     p_procedure_name  => 'GEN_AMT_WRP',
                     p_error_text      => substr(sqlerrm,1,240));
    IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                     (p_called_mode => l_called_mode,
                      p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                      p_module_name => l_module_name,
                      p_log_level   => 5);
        PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        retcode := '2';
        errbuff := substr(sqlerrm,1,240);

        /* Start Bug 5715252 */
           IF DBMS_SQL.IS_OPEN(sql_cursor) THEN
             DBMS_SQL.CLOSE_CURSOR(sql_cursor);
           END IF;
        /* End  Bug 5715252 */

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GEN_AMT_WRP;

END PA_FP_GEN_AMT_WRP_PKG;

/
