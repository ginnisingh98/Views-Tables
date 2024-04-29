--------------------------------------------------------
--  DDL for Package Body PA_FI_AMT_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FI_AMT_CALC_PKG" as
/* $Header: PAFICALB.pls 120.5.12010000.3 2009/02/16 10:40:13 amehrotr ship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE Calculate_Fcst_Amounts_Wrap
                   (
                            errbuff OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            retcode OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            p_run_mode              IN  VARCHAR2 default 'I',
                            p_select_criteria       IN  VARCHAR2 default '00',
                            p_project_flag          IN  VARCHAR2 default NULL,
                            p_project_id            IN  NUMBER default NULL,
                            p_assignment_id         IN  NUMBER default NULL,
                            P_ORGANIZATION_FLAG     IN  VARCHAR2 default NULL,
                            p_organization_id       IN  NUMBER default NULL,
                            P_Start_Organization_Flag IN  VARCHAR2 default NULL,
                            p_start_organization_id IN  NUMBER default NULL,
                            p_debug_mode            IN VARCHAR2 default 'N',
                            p_gen_report_flag       IN VARCHAR2 default 'N'
                    ) IS

   CURSOR Org_Hierarchy(c_organization_id NUMBER)  IS
   SELECT
           Org.CHILD_ORGANIZATION_ID organization_id
   FROM
           pa_org_hierarchy_denorm  org,
           pa_implementations imp
   WHERE  Org.PA_ORG_USE_TYPE='REPORTING' and
          Org.PARENT_ORGANIZATION_ID=c_organization_Id and
          /* Bug fix: 4367847 NVL(org.ORG_ID,-99)=NVL(imp.ORG_ID,-99) and */
	  org.ORG_ID = imp.ORG_ID and
          Org.ORG_HIERARCHY_VERSION_ID=imp.ORG_STRUCTURE_VERSION_ID
   ORDER BY
           Org.CHILD_ORGANIZATION_ID;

  l_errbuff VARCHAR2(500);
  l_retcode VARCHAR2(100);
  l_rpt_request_id NUMBER;
  l_excep_org_id NUMBER;
  l_current_org_id NUMBER;
  BEGIN

    /* Bug fix:4329035 */
    IF  P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.Set_Curr_Function( p_function   => 'FI Amt Wrap Pkg:',
                                p_debug_mode => p_debug_mode );
        PA_DEBUG.g_err_stage := 'Parameters :';
    END IF;
    IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            PA_DEBUG.g_err_stage := 'Run Mode              :'||p_run_mode;
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            PA_DEBUG.g_err_stage := 'Select Criteria       :'||p_select_criteria;
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            PA_DEBUG.g_err_stage := 'Project Id            :'||NVL(p_project_id,-99);
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            PA_DEBUG.g_err_stage := 'Assignment Id         :'||NVL(p_assignment_id,-99);
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            PA_DEBUG.g_err_stage := 'Organization Id       :'||NVL(p_organization_id,-99);
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            PA_DEBUG.g_err_stage := 'Start Organization Id :'||NVL(p_start_organization_id,-99);
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            PA_DEBUG.g_err_stage := 'Generate Report Flag  :'||NVL(p_gen_Report_flag,'N');
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

     /* Bug fix: 4367847 */
     SELECT NVL(org_id,-99) INTO
     l_excep_org_id FROM PA_IMPLEMENTATIONS;

     If P_PA_DEBUG_MODE = 'Y' THEN
	PA_DEBUG.Log_Message(p_message => 'l_excep_org_id => :'||l_excep_org_id);
	PA_DEBUG.Log_Message(p_message => 'Calling MO_GLOBAL.INITapi');
     End If;
     MO_GLOBAL.INIT('PA');
     If NVL(l_excep_org_id,-99) = -99 Then
            l_excep_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID;
     End If;
     If P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.Log_Message(p_message => 'Calling MO_GLOBAL.SET_POLICY_CONTEXT');
     End If;
     MO_GLOBAL.SET_POLICY_CONTEXT('S',l_excep_org_id);
     /* end of bug fix:4367847 */

     IF   p_run_mode IN (  'F' , 'I' ) OR
        ( p_run_mode = 'P' AND p_select_criteria IN ( '02' , '01' ) ) THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Inside Full or Incremental call or specific Org call';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         END IF;

         Pa_Fi_Amt_Calc_Pkg.Calculate_Fcst_Amounts
                   (
                            errbuff  => l_errbuff,
                            retcode  => l_retcode,
                            p_run_mode              => p_run_mode,
                            p_select_criteria       => p_select_criteria,
                            p_project_id            => p_project_id,
                            p_assignment_id         => p_assignment_id,
                            p_organization_id       => p_organization_id,
                            p_debug_mode            => p_debug_mode );
     ELSIF p_run_mode =  'P' AND p_select_criteria = '03' THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.g_err_stage := 'Inside Org hierarchy call';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

        FOR org_rec IN org_hierarchy(p_start_organization_id) LOOP

            IF P_PA_DEBUG_MODE = 'Y' THEN
               PA_DEBUG.g_err_stage := 'Processing Organizaion Id : '||
                                             org_rec.organization_id;
               PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            END IF;


             Pa_Fi_Amt_Calc_Pkg.Calculate_Fcst_Amounts
                   (
                            errbuff  => l_errbuff,
                            retcode  => l_retcode,
                            p_run_mode              => p_run_mode,
                            p_select_criteria       => p_select_criteria,
                            p_project_id            => p_project_id,
                            p_assignment_id         => p_assignment_id,
                            p_organization_id       => Org_Rec.organization_id,
                            p_debug_mode            => p_debug_mode );
        END LOOP;
     END IF;
     retcode := l_retcode;
     IF NVL(p_gen_report_flag,'N' ) = 'Y' AND p_run_mode  <>  'I' THEN
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   PA_DEBUG.g_err_stage := 'Before calling the Exception Report';
                   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                END IF;


               SELECT NVL(org_id,-99) INTO
               l_excep_org_id FROM PA_IMPLEMENTATIONS;

	       /* Bug fix: 4367847 */
	       If P_PA_DEBUG_MODE = 'Y' THEN
        	   PA_DEBUG.Log_Message(p_message => 'Calling FND_REQUEST.set_org_id{'||l_excep_org_id||'}');
     	       End If;
	       FND_REQUEST.set_org_id(l_excep_org_id);
	       /* end of Bug fix: 4367847 */

               l_rpt_request_id := FND_REQUEST.submit_request
               (application                =>   'PA',
                program                    =>   'PAFPEXRP',
                description                =>   'PRC: List Organization Forecast Exceptions',
                start_time                 =>   NULL,
                sub_request                =>   false,
                argument1                  =>   l_excep_org_id,
                argument2                  =>   p_select_criteria,
                argument3                  =>   p_project_flag,
                argument4                  =>   p_project_id,
                argument5                  =>   p_assignment_id,
                argument6                  =>   P_ORGANIZATION_FLAG,
                argument7                  =>   p_organization_id,
                argument8                  =>   P_Start_Organization_Flag,
                argument9                  =>   p_start_organization_id);

            IF l_rpt_request_id = 0 then
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  PA_DEBUG.g_err_stage := 'Error while submitting Report [PAFPEXRP]';
                  PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
               END IF;
               retcode := FND_API.G_RET_STS_ERROR;
            ELSE
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  PA_DEBUG.g_err_stage := 'Exception Report Request Id : ' ||
                                           LTRIM(TO_CHAR(l_rpt_request_id )) ;
                  PA_DEBUG.log_Message( p_message => PA_DEBUG.g_err_stage,
                                        p_write_file => 'OUT',
                                        p_write_mode => 1);
                  PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                END IF;
            END IF;
     END IF;
      /* Bug fix:4329035 */
    IF  P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
    END IF;

  EXCEPTION
        WHEN OTHERS THEN
                 /* Bug fix:4329035 */
                IF  P_PA_DEBUG_MODE = 'Y' THEN
                        PA_DEBUG.Reset_Curr_Function;
                END IF;
                RAISE;
  END Calculate_Fcst_Amounts_Wrap;





  PROCEDURE Calculate_Fcst_Amounts
                   (
                            errbuff OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            retcode OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            p_run_mode              IN  VARCHAR2 default 'I',
                            p_select_criteria       IN  VARCHAR2 default '00',
                            p_project_id            IN  NUMBER default NULL,
                            p_assignment_id         IN  NUMBER default NULL,
                            p_organization_id       IN  NUMBER default NULL,
                            p_debug_mode            IN VARCHAR2 default 'N'
                    ) IS
        l_count  NUMBER := 5;
    CURSOR fcst_item_All(c_start_date DATE)  IS SELECT
                        forecast_item_id,
                        forecast_item_type,
                        EXPENDITURE_ORG_ID,
                        EXPENDITURE_ORGANIZATION_ID,
                        PROJECT_ORG_ID,
                        PROJECT_ORGANIZATION_ID,
                        PROJECT_ID,
                        PROJECT_TYPE_CLASS,
                        PERSON_ID,
                        RESOURCE_ID,
                        NVL(ASSIGNMENT_ID,-9999),
                        ITEM_DATE,
                        ITEM_UOM,
                        ITEM_QUANTITY,
                        PVDR_PA_PERIOD_NAME,
                        RCVR_PA_PERIOD_NAME,
                        EXPENDITURE_TYPE,
                        EXPENDITURE_TYPE_CLASS,
                        Tp_Amount_Type,
                        Delete_Flag
           FROM
                        Pa_Forecast_Items
           WHERE        Error_Flag = 'N' AND Item_Date >= c_start_date
           ORDER BY PROJECT_ID,ASSIGNMENT_ID;

    CURSOR fcst_item_Inc  IS SELECT
                        forecast_item_id,
                        forecast_item_type,
                        EXPENDITURE_ORG_ID,
                        EXPENDITURE_ORGANIZATION_ID,
                        PROJECT_ORG_ID,
                        PROJECT_ORGANIZATION_ID,
                        PROJECT_ID,
                        PROJECT_TYPE_CLASS,
                        PERSON_ID,
                        RESOURCE_ID,
                        NVL(ASSIGNMENT_ID,-9999),
                        ITEM_DATE,
                        ITEM_UOM,
                        ITEM_QUANTITY,
                        PVDR_PA_PERIOD_NAME,
                        RCVR_PA_PERIOD_NAME,
                        EXPENDITURE_TYPE,
                        EXPENDITURE_TYPE_CLASS,
                        Tp_Amount_Type,
                        Delete_Flag
           FROM
                        Pa_Forecast_Items WHERE
                        forecast_amt_calc_flag = 'N' AND
                        Error_Flag = 'N'
           ORDER BY PROJECT_ID,ASSIGNMENT_ID;

    CURSOR fcst_item_Prj(c_project_id NUMBER)  IS SELECT
                        forecast_item_id,
                        forecast_item_type,
                        EXPENDITURE_ORG_ID,
                        EXPENDITURE_ORGANIZATION_ID,
                        PROJECT_ORG_ID,
                        PROJECT_ORGANIZATION_ID,
                        PROJECT_ID,
                        PROJECT_TYPE_CLASS,
                        PERSON_ID,
                        RESOURCE_ID,
                        NVL(ASSIGNMENT_ID,-9999),
                        ITEM_DATE,
                        ITEM_UOM,
                        ITEM_QUANTITY,
                        PVDR_PA_PERIOD_NAME,
                        RCVR_PA_PERIOD_NAME,
                        EXPENDITURE_TYPE,
                        EXPENDITURE_TYPE_CLASS,
                        Tp_Amount_Type,
                        Delete_Flag
           FROM
                        Pa_Forecast_Items WHERE
                        Project_Id = c_project_id AND
                        Error_Flag = 'N'
           ORDER BY PROJECT_ID,ASSIGNMENT_ID;

    CURSOR fcst_item_Prj_Asg(c_project_id NUMBER,
                             c_assignment_id NUMBER)  IS SELECT
                        forecast_item_id,
                        forecast_item_type,
                        EXPENDITURE_ORG_ID,
                        EXPENDITURE_ORGANIZATION_ID,
                        PROJECT_ORG_ID,
                        PROJECT_ORGANIZATION_ID,
                        PROJECT_ID,
                        PROJECT_TYPE_CLASS,
                        PERSON_ID,
                        RESOURCE_ID,
                        NVL(ASSIGNMENT_ID,-9999),
                        ITEM_DATE,
                        ITEM_UOM,
                        ITEM_QUANTITY,
                        PVDR_PA_PERIOD_NAME,
                        RCVR_PA_PERIOD_NAME,
                        EXPENDITURE_TYPE,
                        EXPENDITURE_TYPE_CLASS,
                        Tp_Amount_Type,
                        Delete_Flag
           FROM
                        Pa_Forecast_Items WHERE
                        Project_Id = c_project_id AND
                        Assignment_Id = c_assignment_id AND
                        Error_Flag = 'N';

    CURSOR fcst_item_Organization(c_organization_id NUMBER) IS
           SELECT
                        forecast_item_id,
                        forecast_item_type,
                        EXPENDITURE_ORG_ID,
                        EXPENDITURE_ORGANIZATION_ID,
                        PROJECT_ORG_ID,
                        PROJECT_ORGANIZATION_ID,
                        PROJECT_ID,
                        PROJECT_TYPE_CLASS,
                        PERSON_ID,
                        RESOURCE_ID,
                        Assignment_Id,
                        ITEM_DATE,
                        ITEM_UOM,
                        ITEM_QUANTITY,
                        PVDR_PA_PERIOD_NAME,
                        RCVR_PA_PERIOD_NAME,
                        EXPENDITURE_TYPE,
                        EXPENDITURE_TYPE_CLASS,
                        Tp_Amount_Type,
                        Delete_Flag
           FROM
           (
           SELECT
                        forecast_item_id,
                        forecast_item_type,
                        EXPENDITURE_ORG_ID,
                        EXPENDITURE_ORGANIZATION_ID,
                        PROJECT_ORG_ID,
                        PROJECT_ORGANIZATION_ID,
                        PROJECT_ID,
                        PROJECT_TYPE_CLASS,
                        PERSON_ID,
                        RESOURCE_ID,
                        NVL(ASSIGNMENT_ID,-9999) Assignment_Id,
                        ITEM_DATE,
                        ITEM_UOM,
                        ITEM_QUANTITY,
                        PVDR_PA_PERIOD_NAME,
                        RCVR_PA_PERIOD_NAME,
                        EXPENDITURE_TYPE,
                        EXPENDITURE_TYPE_CLASS,
                        Tp_Amount_Type,
                        Delete_Flag
           FROM
                        Pa_Forecast_Items WHERE
                        EXPENDITURE_ORGANIZATION_ID = c_organization_id AND
                        Error_Flag = 'N'
         UNION
           SELECT
                        forecast_item_id,
                        forecast_item_type,
                        EXPENDITURE_ORG_ID,
                        EXPENDITURE_ORGANIZATION_ID,
                        PROJECT_ORG_ID,
                        PROJECT_ORGANIZATION_ID,
                        PROJECT_ID,
                        PROJECT_TYPE_CLASS,
                        PERSON_ID,
                        RESOURCE_ID,
                        NVL(ASSIGNMENT_ID,-9999) ASSIGNMENT_ID,
                        ITEM_DATE,
                        ITEM_UOM,
                        ITEM_QUANTITY,
                        PVDR_PA_PERIOD_NAME,
                        RCVR_PA_PERIOD_NAME,
                        EXPENDITURE_TYPE,
                        EXPENDITURE_TYPE_CLASS,
                        Tp_Amount_Type,
                        Delete_Flag
           FROM
                        Pa_Forecast_Items WHERE
                        PROJECT_ORGANIZATION_ID = c_organization_id AND
                        Error_Flag = 'N'   ) DUAL
           ORDER BY Project_Id,Assignment_Id;

    CURSOR Fcst_Options IS
           SELECT
                   NVL(imp.Org_Id,-99) Org_Id,
                   NVL(fcst.ORG_FCST_PERIOD_TYPE,'AaBb') ORG_FCST_PERIOD_TYPE,
                   fcst.START_PERIOD_NAME START_PERIOD_NAME,
                   imp.Pa_Period_Type Pa_Period_Type,
                   sob.PERIOD_SET_NAME PERIOD_SET_NAME,
                   sob.ACCOUNTED_PERIOD_TYPE ACCOUNTED_PERIOD_TYPE
           FROM    Pa_Forecasting_Options_All fcst,
                   Pa_Implementations_All imp,
                   Gl_Sets_Of_Books sob
           WHERE   /* Bug fix:4367847 NVL(imp.Org_Id,-99) = NVL(fcst.Org_Id,-99) AND */
		   imp.Org_Id = NVL(fcst.Org_Id,-99) AND
                   sob.SET_OF_BOOKS_ID = imp.SET_OF_BOOKS_ID;

/* Added this cursor for bug 3051110 */

    CURSOR Cur_Assignments(c_request_id NUMBER) IS
        Select distinct assignment_id from PA_FORECAST_ITEMS
        Where request_id = c_request_id and Forecast_amt_calc_flag = 'Y'
          and assignment_id is NOT NULL;

  l_fi_id_tab                    PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_item_type_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_exp_orgid_tab             PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_exp_organizationid_tab    PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_proj_orgid_tab            PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_proj_organizationid_tab   PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_projid_tab                PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_proj_type_class_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_personid_tab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_resid_tab                 PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_asgid_tab                 PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_date_tab                  PA_PLSQL_DATATYPES.DateTabTyp;
  l_fi_uom_tab                   PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_qty_tab                   PA_PLSQL_DATATYPES.NumTabTyp;
  l_fi_pvdr_papd_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_rcvr_papd_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_exptype_tab               PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_exptypeclass_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_amount_type_tab           PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_rev_rejct_reason_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_cst_rejct_reason_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_bd_rejct_reason_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_others_rejct_reason_tab   PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_tp_rejct_reason_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_delete_flag_tab           PA_PLSQL_DATATYPES.Char1TabTyp;

  l_fi_process_flag_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
  l_line_num                     Pa_Forecast_Item_Details.Line_Num%TYPE;
  l_temp_line_num                Pa_Forecast_Item_Details.Line_Num%TYPE;

  l_prev_fi_pvdr_papd    Pa_Forecast_Items.PVDR_PA_PERIOD_NAME%TYPE;

  l_prev_project_id NUMBER;
  l_prev_asg_id     NUMBER;
  l_prev_proj_orgid NUMBER;
  l_prev_exp_type   Pa_Expenditure_Types.EXPENDITURE_TYPE%TYPE;
  /* Project Info */
  l_prj_type          Pa_Projects_All.Project_Type%TYPE;
  l_distribution_rule Pa_Projects_All.Distribution_Rule%TYPE;
  l_bill_job_group_id Pa_Projects_All.Bill_Job_Group_Id%TYPE;
  l_cost_job_group_id Pa_Projects_All.Cost_Job_Group_Id%TYPE;
  l_job_bill_rate_sch_id Pa_Projects_All.JOB_BILL_RATE_SCHEDULE_ID%TYPE;
  l_emp_bill_rate_sch_id Pa_Projects_All.EMP_BILL_RATE_SCHEDULE_ID%TYPE;
  l_prj_curr_code Pa_Projects_All.PROJECT_CURRENCY_CODE%TYPE;
  l_prj_rate_date Pa_Projects_All.PROJECT_RATE_DATE%TYPE;
  l_prj_rate_type Pa_Projects_All.PROJECT_RATE_TYPE%TYPE;
  l_prj_bil_rate_date_code Pa_Projects_All.PROJECT_BIL_RATE_DATE_CODE%TYPE;
  l_prj_bil_rate_type Pa_Projects_All.PROJECT_BIL_RATE_TYPE%TYPE;
  l_prj_bil_rate_date Pa_Projects_All.PROJECT_BIL_RATE_DATE%TYPE;
  l_prj_bil_ex_rate Pa_Projects_All.PROJECT_BIL_EXCHANGE_RATE%TYPE;
  l_prjfunc_curr_code Pa_Projects_All.PROJFUNC_CURRENCY_CODE%TYPE;
  l_prjfunc_cost_rate_type Pa_Projects_All.PROJFUNC_COST_RATE_TYPE%TYPE;
  l_prjfunc_cost_rate_date Pa_Projects_All.PROJFUNC_COST_RATE_DATE%TYPE;
  l_prjfunc_bil_rate_date_code Pa_Projects_All.PROJFUNC_BIL_RATE_DATE_CODE%TYPE;
  l_prjfunc_bil_rate_type Pa_Projects_All.PROJFUNC_BIL_RATE_TYPE%TYPE;
  l_prjfunc_bil_rate_date Pa_Projects_All.PROJFUNC_BIL_RATE_DATE%TYPE;
  l_prjfunc_bil_ex_rate Pa_Projects_All.PROJFUNC_BIL_EXCHANGE_RATE%TYPE;
  l_labor_tp_schedule_id Pa_Projects_All.LABOR_TP_SCHEDULE_ID%TYPE;
  l_labor_tp_fixed_date Pa_Projects_All.LABOR_TP_FIXED_DATE%TYPE;
  l_fcst_cost_rate_schid pa_forecasting_options_All.JOB_COST_RATE_SCHEDULE_ID%TYPE;

  l_labor_sch_discount Pa_Projects_All.LABOR_SCHEDULE_DISCOUNT%TYPE;
  l_asg_precedes_task Pa_Projects_All.ASSIGN_PRECEDES_TASK%TYPE;
  l_labor_bill_rate_orgid Pa_Projects_All.LABOR_BILL_RATE_ORG_ID%TYPE;
  l_labor_std_bill_rate_sch Pa_Projects_All.LABOR_STD_BILL_RATE_SCHDL%TYPE;
  l_labor_sch_fixed_dt Pa_Projects_All.LABOR_SCHEDULE_FIXED_DATE%TYPE;
  l_labor_sch_type Pa_Projects_All.LABOR_SCH_TYPE%TYPE;

  l_chk number := 0;

  /* Project PL SQL table for Rate API  */

  l_prj_type_tab                 PA_PLSQL_DATATYPES.Char30TabTyp;
  l_distribution_rule_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
  l_bill_job_group_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
  l_cost_job_group_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
  l_job_bill_rate_sch_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;
  l_emp_bill_rate_sch_id_tab     PA_PLSQL_DATATYPES.IdTabTyp;
  l_prj_curr_code_tab            PA_PLSQL_DATATYPES.Char15TabTyp;
  l_prj_rate_date_tab            PA_PLSQL_DATATYPES.DateTabTyp;
  l_prj_rate_type_tab            PA_PLSQL_DATATYPES.Char30TabTyp;
  l_prj_bil_rate_dt_code_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
  l_prj_bil_rate_type_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
  l_prj_bil_rate_date_tab        PA_PLSQL_DATATYPES.DateTabTyp;
  l_prj_bil_ex_rate_tab          PA_PLSQL_DATATYPES.NumTabTyp;
  l_prjfunc_curr_code_tab        PA_PLSQL_DATATYPES.Char15TabTyp;
  l_prjfunc_cost_rt_type_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
  l_prjfunc_cost_rt_dt_tab       PA_PLSQL_DATATYPES.DateTabTyp;
  l_prjfunc_bil_rt_dt_code_tab   PA_PLSQL_DATATYPES.Char30TabTyp;
  l_prjfunc_bil_rate_type_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
  l_prjfunc_bil_rate_date_tab    PA_PLSQL_DATATYPES.DateTabTyp;
  l_prjfunc_bil_ex_rate_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  l_prj_cost_rate_schid_tab      PA_PLSQL_DATATYPES.IdTabTyp;

  l_labor_sch_discount_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_asg_precedes_task_tab        PA_PLSQL_DATATYPES.Char1TabTyp;
  l_labor_bill_rate_orgid_tab    PA_PLSQL_DATATYPES.NumTabTyp;
  l_labor_std_bill_rate_sch_tab  PA_PLSQL_DATATYPES.Char20TabTyp;
  l_labor_sch_fixed_dt_tab       PA_PLSQL_DATATYPES.DateTabTyp;
  l_labor_sch_type_tab           PA_PLSQL_DATATYPES.Char1TabTyp;


  /* Project Assignment info */

  l_asg_fcst_job_id Pa_Project_Assignments.Fcst_Job_Id%TYPE;
  l_asg_fcst_job_group_id Pa_Project_Assignments.Fcst_Job_Group_Id%TYPE;
  l_asg_project_role_id Pa_Project_Assignments.Project_Role_Id%TYPE;
  l_asg_markup_percent Pa_Project_Assignments.Markup_Percent%TYPE;
  l_asg_bill_rate_override Pa_Project_Assignments.Bill_Rate_Override%TYPE;
  l_asg_bill_rate_curr_override Pa_Project_Assignments.BILL_RATE_CURR_OVERRIDE%TYPE;
  l_asg_markup_percent_override Pa_Project_Assignments.MARKUP_PERCENT_OVERRIDE%TYPE;
  l_asg_tp_rate_override Pa_Project_Assignments.TP_RATE_OVERRIDE%TYPE;
  l_asg_tp_curr_override Pa_Project_Assignments.TP_CURRENCY_OVERRIDE%TYPE;
  l_asg_tp_calc_base_code_ovr Pa_Project_Assignments.TP_CALC_BASE_CODE_OVERRIDE%TYPE;
  l_asg_tp_percent_applied_ovr Pa_Project_Assignments.TP_PERCENT_APPLIED_OVERRIDE%TYPE;
  l_prj_assignment_type          PA_PROJECT_ASSIGNMENTS.ASSIGNMENT_TYPE%TYPE;
  l_prj_status_code              PA_PROJECT_ASSIGNMENTS.STATUS_CODE%TYPE;

  /* Project Assignments PL SQL Tables  */

  l_asg_fcst_jobid_tab           PA_PLSQL_DATATYPES.IdTabTyp;
  l_asg_fcst_jobgroupid_tab      PA_PLSQL_DATATYPES.IdTabTyp;

  l_cc_sys_link_tab              PA_PLSQL_DATATYPES.Char30TabTyp;
  l_cc_taskid_tab                PA_PLSQL_DATATYPES.IdTabTyp;
  l_cc_expitemid_tab             PA_PLSQL_DATATYPES.IdTabTyp;
  l_cc_transsource_tab           PA_PLSQL_DATATYPES.Char30TabTyp;
  l_cc_NLOrgzid_tab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_cc_prvdreid_tab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_cc_recvreid_tab              PA_PLSQL_DATATYPES.IdTabTyp;
  lx_cc_status_tab               PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_cc_type_tab                 PA_PLSQL_DATATYPES.Char3TabTyp;
  lx_cc_code_tab                 PA_PLSQL_DATATYPES.Char1TabTyp;
  lx_cc_prvdr_orgzid_tab         PA_PLSQL_DATATYPES.IdTabTyp;
  lx_cc_recvr_orgzid_tab         PA_PLSQL_DATATYPES.IdTabTyp;
  lx_cc_recvr_orgid_tab          PA_PLSQL_DATATYPES.IdTabTyp;
  lx_cc_prvdr_orgid_tab          PA_PLSQL_DATATYPES.IdTabTyp;
  lx_cc_error_stage              VARCHAR2(500);
  lx_cc_error_code               NUMBER;

  l_cc_sys_link Pa_Expenditure_Types.System_Linkage_Function%TYPE;
  l_cc_exp_category Pa_Expenditure_Types.EXPENDITURE_CATEGORY%TYPE;

  l_tp_asgid                     PA_PLSQL_DATATYPES.IdTabTyp;
  l_tp_exp_category              PA_PLSQL_DATATYPES.Char30TabTyp;
  l_tp_exp_itemid                PA_PLSQL_DATATYPES.IdTabTyp;
  l_tp_labor_nl_flag             PA_PLSQL_DATATYPES.Char1TabTyp;
  l_tp_taskid                    PA_PLSQL_DATATYPES.IdTabTyp;
  l_tp_scheduleid                PA_PLSQL_DATATYPES.IdTabTyp;
  l_tp_denom_currcode            PA_PLSQL_DATATYPES.Char15TabTyp;
  l_tp_rev_distributed_flag      PA_PLSQL_DATATYPES.Char1TabTyp;
  l_tp_compute_flag              PA_PLSQL_DATATYPES.Char1TabTyp;
  l_tp_fixed_date                PA_PLSQL_DATATYPES.DateTabTyp;

  l_tp_asg_precedes_task_tab     PA_PLSQL_DATATYPES.Char1TabTyp; -- Added for bug 3260017

  l_tp_denom_raw_cost            PA_PLSQL_DATATYPES.NumTabTyp;
  l_tp_denom_bd_cost             PA_PLSQL_DATATYPES.NumTabTyp;
  l_tp_raw_revenue               PA_PLSQL_DATATYPES.NumTabTyp;
  l_tp_nl_resource               PA_PLSQL_DATATYPES.Char20TabTyp;
  l_tp_nl_resource_orgzid        PA_PLSQL_DATATYPES.IdTabTyp;
  l_tp_pa_date                   PA_PLSQL_DATATYPES.DateTabTyp;

  lx_proj_tp_rate_type           PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_proj_tp_rate_date           PA_PLSQL_DATATYPES.DateTabTyp;
  lx_proj_tp_exchange_rate       PA_PLSQL_DATATYPES.NumTabTyp;
  lx_proj_tp_amt                 PA_PLSQL_DATATYPES.NumTabTyp;

  lx_projfunc_tp_rate_type       PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_projfunc_tp_rate_date       PA_PLSQL_DATATYPES.DateTabTyp;
  lx_projfunc_tp_exchange_rate   PA_PLSQL_DATATYPES.NumTabTyp;
  lx_projfunc_tp_amt             PA_PLSQL_DATATYPES.NumTabTyp;

  lx_denom_tp_currcode           PA_PLSQL_DATATYPES.Char15TabTyp;
  lx_denom_tp_amt                PA_PLSQL_DATATYPES.NumTabTyp;

  lx_expfunc_tp_rate_type        PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_expfunc_tp_rate_date        PA_PLSQL_DATATYPES.DateTabTyp;
  lx_expfunc_tp_exchange_rate    PA_PLSQL_DATATYPES.NumTabTyp;
  lx_expfunc_tp_amt              PA_PLSQL_DATATYPES.NumTabTyp;

  lx_cc_markup_basecode          PA_PLSQL_DATATYPES.Char1TabTyp;
  lx_tp_ind_compiled_setid       PA_PLSQL_DATATYPES.IdTabTyp;
  lx_tp_bill_rate                PA_PLSQL_DATATYPES.NumTabTyp;
  lx_tp_base_amount              PA_PLSQL_DATATYPES.NumTabTyp;
  lx_tp_bill_markup_percent      PA_PLSQL_DATATYPES.NumTabTyp;
  lx_tp_sch_line_percent         PA_PLSQL_DATATYPES.NumTabTyp;
  lx_tp_rule_percent             PA_PLSQL_DATATYPES.NumTabTyp;
  lx_tp_job_id                   PA_PLSQL_DATATYPES.IdTabTyp;
  lx_tp_error_code               PA_PLSQL_DATATYPES.Char30TabTyp;

  l_tp_array_size                NUMBER;
  l_tp_debug_mode                VARCHAR2(30);
  lx_tp_return_status            NUMBER;


  /* Rate API */

  l_rt_fi_id_tab                 PA_PLSQL_DATATYPES.IdTabTyp;
  l_rt_start_date_tab            PA_PLSQL_DATATYPES.DateTabTyp;
  l_rt_qty_tab                   PA_PLSQL_DATATYPES.NumTabTyp;
  l_rt_exp_org_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
  l_rt_exp_organization_id_tab   PA_PLSQL_DATATYPES.IdTabTyp;
  l_rt_system_linkage_tab        PA_PLSQL_DATATYPES.Char30TabTyp;

  lx_rt_expfunc_raw_cst_rt_tab   PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_expfunc_raw_cst_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_expfunc_bd_cst_rt_tab    PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_expfunc_bd_cst_tab       PA_PLSQL_DATATYPES.NumTabTyp;

  lx_rt_proj_bill_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_projfunc_bill_rate_tab   PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_raw_revenue_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_raw_cost_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_bd_cost_rt_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_bd_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;

  lx_rt_rev_rejct_reason_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_rt_cst_rejct_reason_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_rt_bd_rejct_reason_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_rt_others_rejct_reason_tab  PA_PLSQL_DATATYPES.Char30TabTyp;

  lx_rt_error_msg VARCHAR2(1000);
  lx_rt_return_status VARCHAR2(30);
  lx_rt_msg_count NUMBER;
  lx_rt_msg_data VARCHAR2(1000); --Bug 7423839

  /* new parameters for Org Fcst */

   lx_rt_pfunc_raw_revenue_tab   PA_PLSQL_DATATYPES.NumTabTyp;

   l_rt_pfunc_rev_rt_date_tab    PA_PLSQL_DATATYPES.DateTabTyp ;
   l_rt_pfunc_rev_rt_type_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_rt_pfunc_rev_ex_rt_tab      PA_PLSQL_DATATYPES.NumTabTyp;
   l_rt_pfunc_rev_rt_dt_code_tab PA_PLSQL_DATATYPES.Char30TabTyp;


   lx_rt_pfunc_rev_rt_date_tab   PA_PLSQL_DATATYPES.DateTabTyp ;
   lx_rt_pfunc_rev_rt_type_tab   PA_PLSQL_DATATYPES.Char30TabTyp;
   lx_rt_pfunc_rev_ex_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;

   lx_rt_pfunc_raw_cost_tab      PA_PLSQL_DATATYPES.NumTabTyp;
   lx_rt_pfunc_raw_cost_rt_tab   PA_PLSQL_DATATYPES.NumTabTyp;
   lx_rt_pfunc_bd_cost_tab       PA_PLSQL_DATATYPES.NumTabTyp;
   lx_rt_pfunc_bd_cost_rt_tab    PA_PLSQL_DATATYPES.NumTabTyp;

   l_rt_pfunc_cost_rt_date_tab   PA_PLSQL_DATATYPES.DateTabTyp;
   l_rt_pfunc_cost_rt_type_tab   PA_PLSQL_DATATYPES.Char30TabTyp;

   lx_rt_pfunc_cost_rt_date_tab  PA_PLSQL_DATATYPES.DateTabTyp;
   lx_rt_pfunc_cost_rt_type_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
   lx_rt_pfunc_cost_ex_rt_tab    PA_PLSQL_DATATYPES.NumTabTyp;

   l_rt_proj_cost_rt_date_tab    PA_PLSQL_DATATYPES.DateTabTyp;
   l_rt_proj_cost_rt_type_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_rt_proj_rev_rt_date_tab     PA_PLSQL_DATATYPES.DateTabTyp;
   l_rt_proj_rev_rt_type_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
   l_rt_proj_rev_rt_dt_code_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
   l_rt_proj_rev_ex_rt_tab       PA_PLSQL_DATATYPES.NumTabTyp;

   lx_rt_proj_cost_rt_date_tab   PA_PLSQL_DATATYPES.DateTabTyp;
   lx_rt_proj_cost_rt_type_tab   PA_PLSQL_DATATYPES.Char30TabTyp;
   lx_rt_proj_cost_ex_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
   lx_rt_proj_rev_rt_date_tab    PA_PLSQL_DATATYPES.DateTabTyp;
   lx_rt_proj_rev_rt_type_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
   lx_rt_proj_rev_ex_rt_tab      PA_PLSQL_DATATYPES.NumTabTyp;

   lx_rt_expfunc_curr_code_tab   PA_PLSQL_DATATYPES.Char15TabTyp;
   lx_rt_expfunc_cost_rt_date_tab PA_PLSQL_DATATYPES.DateTabTyp;
   lx_rt_expfunc_cost_rt_type_tab PA_PLSQL_DATATYPES.Char30TabTyp;
   lx_rt_expfunc_cost_ex_rt_tab  PA_PLSQL_DATATYPES.NumTabTyp;

   lx_rt_cost_txn_curr_code_tab  PA_PLSQL_DATATYPES.Char15TabTyp;
   lx_rt_txn_raw_cost_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp ;
   lx_rt_txn_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
   lx_rt_txn_bd_cost_rt_tab      PA_PLSQL_DATATYPES.NumTabTyp;
   lx_rt_txn_bd_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
   lx_rt_rev_txn_curr_code_tab   PA_PLSQL_DATATYPES.Char15TabTyp;
   lx_rt_txn_rev_bill_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
   lx_rt_txn_raw_revenue_tab     PA_PLSQL_DATATYPES.NumTabTyp;


  /* Forecast Item PL SQL Tables */

  l_fia_cost_txn_curr_code       PA_PLSQL_DATATYPES.Char15TabTyp;
  l_fia_rev_txn_curr_code        PA_PLSQL_DATATYPES.Char15TabTyp;
  l_fia_txn_raw_cost             PA_PLSQL_DATATYPES.NumTabTyp;
  l_fia_txn_bd_cost              PA_PLSQL_DATATYPES.NumTabTyp;
  l_fia_txn_revenue              PA_PLSQL_DATATYPES.NumTabTyp;

  l_fia_expfunc_curr_code        PA_PLSQL_DATATYPES.Char15TabTyp;
  l_fia_expfunc_raw_cost         PA_PLSQL_DATATYPES.NumTabTyp;
  l_fia_expfunc_bd_cost          PA_PLSQL_DATATYPES.NumTabTyp;

  l_fia_projfunc_raw_cost        PA_PLSQL_DATATYPES.NumTabTyp;
  l_fia_projfunc_bd_cost         PA_PLSQL_DATATYPES.NumTabTyp;
  l_fia_projfunc_revenue         PA_PLSQL_DATATYPES.NumTabTyp;

  l_fia_proj_raw_cost            PA_PLSQL_DATATYPES.NumTabTyp;
  l_fia_proj_bd_cost             PA_PLSQL_DATATYPES.NumTabTyp;
  l_fia_proj_revenue             PA_PLSQL_DATATYPES.NumTabTyp;

  l_fia_proj_cost_rate_type      PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fia_proj_cost_rate_date      PA_PLSQL_DATATYPES.DateTabTyp;
  l_fia_proj_cost_ex_rate        PA_PLSQL_DATATYPES.NumTabTyp;

  l_fia_proj_rev_rate_type       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fia_proj_rev_rate_date       PA_PLSQL_DATATYPES.DateTabTyp;
  l_fia_proj_rev_ex_rate         PA_PLSQL_DATATYPES.NumTabTyp;

  l_fia_expfunc_cost_rate_type   PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fia_expfunc_cost_rate_date   PA_PLSQL_DATATYPES.DateTabTyp;
  l_fia_expfunc_cost_ex_rate     PA_PLSQL_DATATYPES.NumTabTyp;

  l_fia_projfunc_cost_rate_type  PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fia_projfunc_cost_rate_date  PA_PLSQL_DATATYPES.DateTabTyp;
  l_fia_projfunc_cost_ex_rate    PA_PLSQL_DATATYPES.NumTabTyp;

  l_fia_projfunc_rev_rate_type   PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fia_projfunc_rev_rate_date   PA_PLSQL_DATATYPES.DateTabTyp;
  l_fia_projfunc_rev_ex_rate     PA_PLSQL_DATATYPES.NumTabTyp;

  /* fid - forecast item amount details PL SQL tables */

  l_fid_cost_txn_curr_code       PA_PLSQL_DATATYPES.Char15TabTyp;
  l_fid_rev_txn_curr_code        PA_PLSQL_DATATYPES.Char15TabTyp;
  l_fid_txn_raw_cost             PA_PLSQL_DATATYPES.NumTabTyp;
  l_fid_txn_bd_cost              PA_PLSQL_DATATYPES.NumTabTyp;
  l_fid_txn_revenue              PA_PLSQL_DATATYPES.NumTabTyp;

  l_fid_expfunc_curr_code        PA_PLSQL_DATATYPES.Char15TabTyp;
  l_fid_expfunc_raw_cost         PA_PLSQL_DATATYPES.NumTabTyp;
  l_fid_expfunc_bd_cost          PA_PLSQL_DATATYPES.NumTabTyp;

  l_fid_projfunc_curr_code       PA_PLSQL_DATATYPES.Char15TabTyp;
  l_fid_projfunc_raw_cost        PA_PLSQL_DATATYPES.NumTabTyp;
  l_fid_projfunc_bd_cost         PA_PLSQL_DATATYPES.NumTabTyp;
  l_fid_projfunc_revenue         PA_PLSQL_DATATYPES.NumTabTyp;

  l_fid_proj_curr_code           PA_PLSQL_DATATYPES.Char15TabTyp;
  l_fid_proj_raw_cost            PA_PLSQL_DATATYPES.NumTabTyp;
  l_fid_proj_bd_cost             PA_PLSQL_DATATYPES.NumTabTyp;
  l_fid_proj_revenue             PA_PLSQL_DATATYPES.NumTabTyp;

  l_fid_proj_cost_rate_type      PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fid_proj_cost_rate_date      PA_PLSQL_DATATYPES.DateTabTyp;
  l_fid_proj_cost_ex_rate        PA_PLSQL_DATATYPES.NumTabTyp;

  l_fid_proj_rev_rate_type       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fid_proj_rev_rate_date       PA_PLSQL_DATATYPES.DateTabTyp;
  l_fid_proj_rev_ex_rate         PA_PLSQL_DATATYPES.NumTabTyp;

  l_fid_expfunc_cost_rate_type   PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fid_expfunc_cost_rate_date   PA_PLSQL_DATATYPES.DateTabTyp;
  l_fid_expfunc_cost_ex_rate     PA_PLSQL_DATATYPES.NumTabTyp;

  l_fid_projfunc_cost_rate_type  PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fid_projfunc_cost_rate_date  PA_PLSQL_DATATYPES.DateTabTyp;
  l_fid_projfunc_cost_ex_rate    PA_PLSQL_DATATYPES.NumTabTyp;

  l_fid_projfunc_rev_rate_type   PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fid_projfunc_rev_rate_date   PA_PLSQL_DATATYPES.DateTabTyp;
  l_fid_projfunc_rev_ex_rate     PA_PLSQL_DATATYPES.NumTabTyp;

  l_fid_fcst_itemid              PA_PLSQL_DATATYPES.IdTabTyp;
  l_fid_line_num                 PA_PLSQL_DATATYPES.NumTabTyp;
  l_fid_item_date                PA_PLSQL_DATATYPES.DateTabTyp;
  l_fid_item_uom                 PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fid_item_qty                 PA_PLSQL_DATATYPES.NumTabTyp;
  l_fid_reversed_flag            PA_PLSQL_DATATYPES.Char1TabTyp;
  l_fid_net_zero_flag            PA_PLSQL_DATATYPES.Char1TabTyp;
  l_fid_line_num_reversed        PA_PLSQL_DATATYPES.NumTabTyp;

  l_fid_proj_tp_rate_type        PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fid_proj_tp_rate_date        PA_PLSQL_DATATYPES.DateTabTyp;
  l_fid_proj_tp_ex_rate          PA_PLSQL_DATATYPES.NumTabTyp;
  l_fid_proj_tp_amt              PA_PLSQL_DATATYPES.NumTabTyp;

  l_fid_projfunc_tp_rate_type    PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fid_projfunc_tp_rate_date    PA_PLSQL_DATATYPES.DateTabTyp;
  l_fid_projfunc_tp_ex_rate      PA_PLSQL_DATATYPES.NumTabTyp;
  l_fid_projfunc_tp_amt          PA_PLSQL_DATATYPES.NumTabTyp;

  l_fid_denom_tp_currcode        PA_PLSQL_DATATYPES.Char15TabTyp;
  l_fid_denom_tp_amt             PA_PLSQL_DATATYPES.NumTabTyp;

  l_fid_expfunc_tp_rate_type     PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fid_expfunc_tp_rate_date     PA_PLSQL_DATATYPES.DateTabTyp;
  l_fid_expfunc_tp_ex_rate       PA_PLSQL_DATATYPES.NumTabTyp;
  l_fid_expfunc_tp_amt           PA_PLSQL_DATATYPES.NumTabTyp;

  l_fid_upd_fcst_itemid          PA_PLSQL_DATATYPES.IdTabTyp;
  l_fid_upd_line_num             PA_PLSQL_DATATYPES.NumTabTyp;
  l_fid_upd_reversed_flag        PA_PLSQL_DATATYPES.Char1TabTyp;
  l_fid_upd_net_zero_flag        PA_PLSQL_DATATYPES.Char1TabTyp;

  l_prev_rt_prj_id               Pa_Forecast_Items.Project_Id%TYPE;
  l_prev_rt_asg_id               Pa_Forecast_Items.Assignment_Id%TYPE;
  l_prev_rt_personid             Pa_Forecast_Items.Person_Id%TYPE;
  l_prev_rt_fi_itemtype          Pa_Forecast_Items.Forecast_Item_Type%TYPE;
  l_prev_rt_fi_proc_flag         VARCHAR2(1);
  l_prev_rt_calling_mode         VARCHAR2(30);
  l_prev_rt_fcst_jobid           Pa_Project_Assignments.Fcst_Job_Id%TYPE;
  l_prev_rt_fcst_jobgroupid      Pa_Project_Assignments.Fcst_Job_Group_Id%TYPE;
  l_prev_rt_exp_type             Pa_Forecast_Items.Expenditure_Type%TYPE;
  l_prev_rt_org_id               Pa_Forecast_Items.Expenditure_Org_Id%TYPE;
  l_prev_rt_prj_type             Pa_Projects_All.Project_Type%TYPE;
  l_prev_rt_projfunc_currcode    Pa_Projects_All.Project_Currency_Code%TYPE;
  l_prev_rt_proj_currcode        Pa_Projects_All.Project_Currency_Code%TYPE;
  l_prev_rt_bill_jobgroup_id     Pa_Projects_All.Bill_Job_Group_Id%TYPE;
  l_prev_rt_emp_bilrate_schid    Pa_Projects_All.Emp_Bill_Rate_Schedule_Id%TYPE;
  l_prev_rt_job_bilrate_schid    Pa_Projects_All.Job_Bill_Rate_Schedule_Id%TYPE;
  l_prev_rt_dist_rule            Pa_Projects_All.Distribution_Rule%TYPE;
  l_prev_rt_cost_rate_schid      Pa_Projects_All.Emp_Bill_Rate_Schedule_Id%TYPE;

  l_prev_rt_labor_sch_discount   NUMBER;
  l_prev_rt_asg_precedes_task    Pa_Projects_All.ASSIGN_PRECEDES_TASK%TYPE;
  l_prev_rt_labor_bill_rt_orgid  Pa_Projects_All.LABOR_BILL_RATE_ORG_ID%TYPE;
  l_prev_rt_labor_std_bl_rt_sch  Pa_Projects_All.LABOR_STD_BILL_RATE_SCHDL%TYPE;
  l_prev_rt_labor_sch_fixed_dt   Pa_Projects_All.LABOR_SCHEDULE_FIXED_DATE%TYPE;
  l_prev_rt_labor_sch_type       Pa_Projects_All.LABOR_SCH_TYPE%TYPE;

  /* local variables */
  l_fi_process_flag varchar2(1);
  l_call_rate_api_flag varchar2(1) := 'N';
  l_amount_calc_mode VARCHAR2(30);
  l_rt_index  NUMBER;
  l_temp_last NUMBER;
  l_fia_index NUMBER;
  l_fia_upd_index NUMBER;
  l_fetch_size NUMBER(5) := 200;
  l_t_LINE_NUM                       Pa_Fi_Amount_Details.LINE_NUM%TYPE;
  l_t_ITEM_QUANTITY                  Pa_Fi_Amount_Details.ITEM_QUANTITY%TYPE;
  l_t_COST_TXN_CURR_CODE         Pa_Fi_Amount_Details.COST_TXN_CURRENCY_CODE%TYPE;
  l_t_REV_TXN_CURR_CODE      Pa_Fi_Amount_Details.REVENUE_TXN_CURRENCY_CODE%TYPE;
  l_t_TXN_RAW_COST                   Pa_Fi_Amount_Details.TXN_RAW_COST%TYPE;
  l_t_TXN_BD_COST              Pa_Fi_Amount_Details.TXN_BURDENED_COST%TYPE;
  l_t_TXN_REVENUE                    Pa_Fi_Amount_Details.TXN_REVENUE %TYPE;
  l_t_TXN_TRANSFER_PRICE             Pa_Fi_Amount_Details.TXN_TRANSFER_PRICE%TYPE;
  l_t_TP_TXN_CURR_CODE           Pa_Fi_Amount_Details.TP_TXN_CURRENCY_CODE%TYPE;
  l_t_PROJ_CURR_CODE          Pa_Fi_Amount_Details.PROJECT_CURRENCY_CODE%TYPE;
  l_t_PROJ_RAW_COST               Pa_Fi_Amount_Details.PROJECT_RAW_COST%TYPE;
  l_t_PROJ_BD_COST          Pa_Fi_Amount_Details.PROJECT_BURDENED_COST%TYPE;
  l_t_PROJ_COST_RATE_DATE         Pa_Fi_Amount_Details.PROJECT_COST_RATE_DATE%TYPE;
  l_t_PROJ_COST_RATE_TYPE         Pa_Fi_Amount_Details.PROJECT_COST_RATE_TYPE%TYPE;
  l_t_PROJ_COST_EX_RATE     Pa_Fi_Amount_Details.PROJECT_COST_EXCHANGE_RATE%TYPE;
  l_t_PROJ_REV_RATE_DATE      Pa_Fi_Amount_Details.PROJECT_REVENUE_RATE_DATE %TYPE;
  l_t_PROJ_REV_RATE_TYPE      Pa_Fi_Amount_Details.PROJECT_REVENUE_RATE_TYPE%TYPE;
  l_t_PROJ_REV_EX_RATE  Pa_Fi_Amount_Details.PROJECT_REVENUE_EXCHANGE_RATE%TYPE;
  l_t_PROJ_REVENUE                Pa_Fi_Amount_Details.PROJECT_REVENUE%TYPE;
  l_t_PROJ_TP_RATE_DATE           Pa_Fi_Amount_Details.PROJECT_TP_RATE_DATE%TYPE;
  l_t_PROJ_TP_RATE_TYPE           Pa_Fi_Amount_Details.PROJECT_TP_RATE_TYPE%TYPE;
  l_t_PROJ_TP_EX_RATE       Pa_Fi_Amount_Details.PROJECT_TP_EXCHANGE_RATE%TYPE;
  l_t_PROJ_TRANSFER_PRICE         Pa_Fi_Amount_Details.PROJECT_TRANSFER_PRICE%TYPE;
  l_t_PFUNC_CURR_CODE         Pa_Fi_Amount_Details.PROJFUNC_CURRENCY_CODE%TYPE;
  l_t_PFUNC_COST_RATE_DATE        Pa_Fi_Amount_Details.PROJFUNC_COST_RATE_DATE%TYPE;
  l_t_PFUNC_COST_RATE_TYPE        Pa_Fi_Amount_Details.PROJFUNC_COST_RATE_TYPE %TYPE;
  l_t_PFUNC_COST_EX_RATE    Pa_Fi_Amount_Details.PROJFUNC_COST_EXCHANGE_RATE%TYPE;
  l_t_PFUNC_RAW_COST              Pa_Fi_Amount_Details.PROJFUNC_RAW_COST%TYPE;
  l_t_PFUNC_BD_COST         Pa_Fi_Amount_Details.PROJFUNC_RAW_COST%TYPE;
  l_t_PFUNC_REV_RATE_DATE     Pa_Fi_Amount_Details.PROJFUNC_REVENUE_RATE_DATE%TYPE;
  l_t_PFUNC_REV_RATE_TYPE     Pa_Fi_Amount_Details.PROJFUNC_REVENUE_RATE_TYPE%TYPE;
  l_t_PFUNC_REV_EX_RATE Pa_Fi_Amount_Details.PROJFUNC_REVENUE_EXCHANGE_RATE%TYPE;
  l_t_PFUNC_REVENUE               Pa_Fi_Amount_Details.PROJFUNC_REVENUE%TYPE;
  l_t_PFUNC_TP_RATE_DATE          Pa_Fi_Amount_Details.PROJFUNC_TP_RATE_DATE%TYPE;
  l_t_PFUNC_TP_RATE_TYPE          Pa_Fi_Amount_Details.PROJFUNC_TP_RATE_TYPE%TYPE;
  l_t_PFUNC_TP_EX_RATE      Pa_Fi_Amount_Details.PROJFUNC_TP_EXCHANGE_RATE%TYPE;
  l_t_PFUNC_TRANSFER_PRICE        Pa_Fi_Amount_Details.PROJFUNC_TRANSFER_PRICE%TYPE;
  l_t_EFUNC_CURR_CODE          Pa_Fi_Amount_Details.EXPFUNC_CURRENCY_CODE%TYPE;
  l_t_EFUNC_COST_RATE_DATE         Pa_Fi_Amount_Details.EXPFUNC_COST_RATE_DATE %TYPE;
  l_t_EFUNC_COST_RATE_TYPE         Pa_Fi_Amount_Details.EXPFUNC_COST_RATE_TYPE%TYPE;
  l_t_EFUNC_COST_EX_RATE     Pa_Fi_Amount_Details.EXPFUNC_COST_EXCHANGE_RATE%TYPE;
  l_t_EFUNC_RAW_COST               Pa_Fi_Amount_Details.EXPFUNC_RAW_COST%TYPE;
  l_t_EFUNC_BD_COST          Pa_Fi_Amount_Details.EXPFUNC_BURDENED_COST%TYPE;
  l_t_EFUNC_TP_RATE_DATE           Pa_Fi_Amount_Details.EXPFUNC_TP_RATE_DATE%TYPE;
  l_t_EFUNC_TP_RATE_TYPE           Pa_Fi_Amount_Details.EXPFUNC_TP_RATE_TYPE%TYPE;
  l_t_EFUNC_TP_EX_RATE       Pa_Fi_Amount_Details.EXPFUNC_TP_EXCHANGE_RATE%TYPE;
  l_t_EFUNC_TRANSFER_PRICE         Pa_Fi_Amount_Details.EXPFUNC_TRANSFER_PRICE%TYPE;

  l_last_updated_by   NUMBER := FND_GLOBAL.USER_ID;
  l_created_by        NUMBER := FND_GLOBAL.USER_ID;
  l_creation_date     DATE := SYSDATE;
  l_last_update_date  DATE := l_creation_date;
  l_last_update_login      NUMBER := FND_GLOBAL.LOGIN_ID;
  l_program_application_id NUMBER := FND_GLOBAL.PROG_APPL_ID;
  l_request_id NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  l_program_id NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
  l_call_tp_api_flag VARCHAR2(1);
  l_fi_process_start_date DATE;
  l_curr_process_start_date DATE;
  l_process_fis_flag   VARCHAR2(1);
  l_asgmt_status_flag  VARCHAR2(1);

  /* Variables added for bug 3051110 */
  l_assignment_id pa_project_assignments.assignment_id%TYPE;
  l_sum_transfer_price PA_FORECAST_ITEMS.PROJFUNC_TRANSFER_PRICE%TYPE;
  l_sum_item_quantity  PA_FORECAST_ITEMS.ITEM_QUANTITY%TYPE;
  l_average_transfer_price_rate PA_FORECAST_ITEMS.PROJFUNC_TRANSFER_PRICE%TYPE;
  l_return_status VARCHAR2(1);

  BEGIN
     retcode := '0';
    /* Bug fix:4329035 */
    IF  P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.Set_Curr_Function( p_function   => 'F I Amt:',
                                 p_debug_mode => p_debug_mode );
    END IF;
    l_count := l_count + 5;
    l_chk := 1;
    l_prev_project_id := -9999991;
    l_prev_asg_id     := -9999991;
    l_prev_proj_orgid := -9999991;
    l_prev_exp_type   := 'DummY ExP TyPe';
    l_cc_exp_category := NULL;
    l_prev_fi_pvdr_papd := NULL;
    l_tp_debug_mode := p_debug_mode;

    l_asg_fcst_job_id    := NULL;
    l_asg_fcst_job_group_id := NULL;
    l_asg_project_role_id := NULL;
    l_prj_assignment_type        := NULL;
    l_prj_status_code            := NULL;
    l_process_fis_flag   := 'Y';

    IF p_run_mode = 'F' THEN
       l_fi_process_start_date := NULL;
       FOR opt_rec IN Fcst_Options LOOP
          IF opt_rec.ORG_FCST_PERIOD_TYPE = 'PA' AND
             opt_rec.START_PERIOD_NAME IS NOT NULL THEN
             BEGIN
                SELECT Start_Date INTO l_curr_process_start_date FROM Gl_Periods
                WHERE Period_Set_Name     = opt_rec.Period_Set_Name AND
                   Period_Type            = opt_rec.Pa_Period_Type  AND
                   Period_Name            = opt_rec.START_PERIOD_NAME AND
                   ADJUSTMENT_PERIOD_FLAG = 'N';
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
                retcode := '2';
                /* dbms_output.put_line('inside PA period no data ');
                dbms_output.put_line('PA Pd Type : Start Pd Name :'||
                opt_rec.Pa_Period_Type ||' : ' ||opt_rec.START_PERIOD_NAME); */
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   PA_DEBUG.g_err_stage := 'Org Id :'||opt_rec.Org_Id;
                   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                   PA_DEBUG.g_err_stage := 'No Data Found In PA Pd:'||opt_rec.Pa_Period_Type;
                   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                 END IF;
                RAISE;
             END;
          ELSIF opt_rec.ORG_FCST_PERIOD_TYPE = 'GL' AND
                opt_rec.START_PERIOD_NAME IS NOT NULL THEN
             BEGIN
                SELECT Start_Date INTO l_curr_process_start_date FROM Gl_Periods
                WHERE Period_Set_Name     = opt_rec.Period_Set_Name AND
                   Period_Type            = opt_rec.Accounted_Period_Type  AND
                   Period_Name            = opt_rec.START_PERIOD_NAME AND
                   ADJUSTMENT_PERIOD_FLAG = 'N';
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
                /* dbms_output.put_line('inside GL period no data ');
                dbms_output.put_line('GL Pd Type : Start Pd Name : '||
                opt_rec.Accounted_Period_Type ||' : ' ||opt_rec.START_PERIOD_NAME); */
                retcode := '2';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   PA_DEBUG.g_err_stage := 'Org Id :'||opt_rec.Org_Id;
                   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                   PA_DEBUG.g_err_stage := 'No Data Found In GL Pd:'||opt_rec.Accounted_Period_Type;
                   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                 END IF;
               RAISE;
             END;
          END IF;
          IF l_fi_process_start_date     IS     NULL OR
             ( l_fi_process_start_date   IS NOT NULL AND
               l_curr_process_start_date IS NOT NULL AND
               l_curr_process_start_date < l_fi_process_start_date ) THEN
               l_fi_process_start_date := l_curr_process_start_date;
          END IF;
       END LOOP;
       IF l_fi_process_start_date IS NULL THEN
          IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.g_err_stage := 'No Forecasting Options Setup, returning';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
	     PA_DEBUG.Reset_Curr_Function;
          END IF;
          RETURN;
       END IF;
       IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.g_err_stage := 'FI Process Start Date :'||
                                  TO_CHAR(l_fi_process_start_date,'yyyy/mm/dd');
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;
       /* dbms_output.put_line('FI Process Start Dt :'||
                             TO_CHAR(l_fi_process_start_date,'yyyy/mm/dd')); */
       OPEN fcst_item_All(l_fi_process_start_date);
       IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.g_err_stage := 'Opening Fcst_Item_All cursor';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;
    ELSIF p_run_mode = 'I' THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.g_err_stage := 'Opening Fcst_Item_Inc cursor';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;
       OPEN fcst_item_Inc;
    ELSIF p_run_mode = 'P' AND p_select_criteria = '01' AND
          p_project_id IS NOT NULL AND p_assignment_id IS NULL      THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.g_err_stage := 'Opening Fcst_Item_Prj cursor';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;
       OPEN fcst_item_Prj(p_project_id);
    ELSIF p_run_mode = 'P' AND p_select_criteria = '01' AND
          p_project_id IS NOT NULL AND p_assignment_id IS NOT NULL      THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.g_err_stage := 'Opening Fcst_Item_Prj_Asg cursor';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;
       OPEN fcst_item_Prj_Asg(p_project_id,p_assignment_id);
    ELSIF p_run_mode = 'P' AND p_select_criteria in ( '02','03') THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.g_err_stage := 'Opening Fcst_Ftem_Organization cursor';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;
       OPEN fcst_item_Organization(p_organization_id);
    END IF;
    LOOP
      l_fi_id_tab.delete;
      l_fi_item_type_tab.delete;
      l_fi_exp_orgid_tab.delete;
      l_fi_exp_organizationid_tab.delete;
      l_fi_proj_orgid_tab.delete;
      l_fi_proj_organizationid_tab.delete;
      l_fi_projid_tab.delete;
      l_fi_proj_type_class_tab.delete;
      l_fi_personid_tab.delete;
      l_fi_resid_tab.delete;
      l_fi_asgid_tab.delete;
      l_fi_date_tab.delete;
      l_fi_uom_tab.delete;
      l_fi_qty_tab.delete;
      l_fi_pvdr_papd_tab.delete;
      l_fi_rcvr_papd_tab.delete;
      l_fi_exptype_tab.delete;
      l_fi_exptypeclass_tab.delete;
      l_fi_amount_type_tab.delete;
      l_fi_process_flag_tab.delete;

      l_fi_rev_rejct_reason_tab.delete;
      l_fi_cst_rejct_reason_tab.delete;
      l_fi_bd_rejct_reason_tab.delete;
      l_fi_others_rejct_reason_tab.delete;
      l_fi_tp_rejct_reason_tab.delete;
      l_fi_delete_flag_tab.delete;

      l_prj_type_tab.delete;
      l_distribution_rule_tab.delete;
      l_bill_job_group_id_tab.delete;
      l_cost_job_group_id_tab.delete;
      l_job_bill_rate_sch_id_tab.delete;
      l_emp_bill_rate_sch_id_tab.delete;
      l_prj_curr_code_tab.delete;
      l_prj_rate_date_tab.delete;
      l_prj_rate_type_tab.delete;
      l_prj_bil_rate_dt_code_tab.delete;
      l_prj_bil_rate_type_tab.delete;
      l_prj_bil_rate_date_tab.delete;
      l_prj_bil_ex_rate_tab.delete;
      l_prjfunc_curr_code_tab.delete;
      l_prjfunc_cost_rt_type_tab.delete;
      l_prjfunc_cost_rt_dt_tab.delete;
      l_prjfunc_bil_rt_dt_code_tab.delete;
      l_prjfunc_bil_rate_type_tab.delete;
      l_prjfunc_bil_rate_date_tab.delete;
      l_prjfunc_bil_ex_rate_tab.delete;

      l_labor_sch_discount_tab.delete;
      l_asg_precedes_task_tab.delete;
      l_labor_bill_rate_orgid_tab.delete;
      l_labor_std_bill_rate_sch_tab.delete;
      l_labor_sch_fixed_dt_tab.delete;
      l_labor_sch_type_tab.delete;

      l_prj_cost_rate_schid_tab.delete;

      l_asg_fcst_jobid_tab.delete;
      l_asg_fcst_jobgroupid_tab.delete;

      l_cc_sys_link_tab.delete;
      l_cc_taskid_tab.delete;
      l_cc_expitemid_tab.delete;
      l_cc_transsource_tab.delete;
      l_cc_NLOrgzid_tab.delete;
      l_cc_prvdreid_tab.delete;
      l_cc_recvreid_tab.delete;
      lx_cc_status_tab.delete;
      lx_cc_type_tab.delete;
      lx_cc_code_tab.delete;
      lx_cc_prvdr_orgzid_tab.delete;
      lx_cc_recvr_orgzid_tab.delete;
      lx_cc_recvr_orgid_tab.delete;
      lx_cc_prvdr_orgid_tab.delete;

      l_tp_exp_category.delete;
      l_tp_exp_itemid.delete;
      l_tp_labor_nl_flag.delete;
      l_tp_taskid.delete;
      l_tp_scheduleid.delete;
      l_tp_denom_currcode.delete;
      l_tp_rev_distributed_flag.delete;
      l_tp_compute_flag.delete;
      l_tp_fixed_date.delete;
      l_tp_denom_raw_cost.delete;
      l_tp_denom_bd_cost.delete;
      l_tp_raw_revenue.delete;
      l_tp_nl_resource.delete;
      l_tp_nl_resource_orgzid.delete;
      l_tp_pa_date.delete;
      l_tp_asg_precedes_task_tab.delete; -- Added for bug 3260017

      lx_proj_tp_rate_type.delete;
      lx_proj_tp_rate_date.delete;
      lx_proj_tp_exchange_rate.delete;
      lx_proj_tp_amt.delete;

      lx_projfunc_tp_rate_type.delete;
      lx_projfunc_tp_rate_date.delete;
      lx_projfunc_tp_exchange_rate.delete;
      lx_projfunc_tp_amt.delete;

      lx_denom_tp_currcode.delete;
      lx_denom_tp_amt.delete;

      lx_expfunc_tp_rate_type.delete;
      lx_expfunc_tp_rate_date.delete;
      lx_expfunc_tp_exchange_rate.delete;
      lx_expfunc_tp_amt.delete;

      lx_cc_markup_basecode.delete;
      lx_tp_ind_compiled_setid.delete;
      lx_tp_bill_rate.delete;
      lx_tp_base_amount.delete;
      lx_tp_bill_markup_percent.delete;
      lx_tp_sch_line_percent.delete;
      lx_tp_rule_percent.delete;
      lx_tp_job_id.delete;
      lx_tp_error_code.delete;

  /* fcst item start */

  l_fia_cost_txn_curr_code.delete;
  l_fia_rev_txn_curr_code.delete;
  l_fia_txn_raw_cost.delete;
  l_fia_txn_bd_cost.delete;
  l_fia_txn_revenue.delete;

  l_fia_expfunc_curr_code.delete;
  l_fia_expfunc_raw_cost.delete;
  l_fia_expfunc_bd_cost.delete;

  l_fia_projfunc_raw_cost.delete;
  l_fia_projfunc_bd_cost.delete;
  l_fia_projfunc_revenue.delete;

  l_fia_proj_raw_cost.delete;
  l_fia_proj_bd_cost.delete;
  l_fia_proj_revenue.delete;


  l_fia_proj_cost_rate_type.delete;
  l_fia_proj_cost_rate_date.delete;
  l_fia_proj_cost_ex_rate.delete;

  l_fia_proj_rev_rate_type.delete;
  l_fia_proj_rev_rate_date.delete;
  l_fia_proj_rev_ex_rate.delete;

  l_fia_expfunc_cost_rate_type.delete;
  l_fia_expfunc_cost_rate_date.delete;
  l_fia_expfunc_cost_ex_rate.delete;

  l_fia_projfunc_cost_rate_type.delete;
  l_fia_projfunc_cost_rate_date.delete;
  l_fia_projfunc_cost_ex_rate.delete;

  l_fia_projfunc_rev_rate_type.delete;
  l_fia_projfunc_rev_rate_date.delete;
  l_fia_projfunc_rev_ex_rate.delete;

  /* fcst item end */

  /* Fcst Amount Details  start */

  l_fid_fcst_itemid.delete;
  l_fid_line_num.delete;
  l_fid_item_date.delete;
  l_fid_item_uom.delete;
  l_fid_item_qty.delete;
  l_fid_reversed_flag.delete;
  l_fid_net_zero_flag.delete;
  l_fid_line_num_reversed.delete;

  l_fid_cost_txn_curr_code.delete;
  l_fid_rev_txn_curr_code.delete;
  l_fid_txn_raw_cost.delete;
  l_fid_txn_bd_cost.delete;
  l_fid_txn_revenue.delete;

  l_fid_expfunc_curr_code.delete;
  l_fid_expfunc_raw_cost.delete;
  l_fid_expfunc_bd_cost.delete;

  l_fid_projfunc_curr_code.delete;
  l_fid_projfunc_raw_cost.delete;
  l_fid_projfunc_bd_cost.delete;
  l_fid_projfunc_revenue.delete;

  l_fid_proj_curr_code.delete;
  l_fid_proj_raw_cost.delete;
  l_fid_proj_bd_cost.delete;
  l_fid_proj_revenue.delete;


  l_fid_proj_cost_rate_type.delete;
  l_fid_proj_cost_rate_date.delete;
  l_fid_proj_cost_ex_rate.delete;

  l_fid_proj_rev_rate_type.delete;
  l_fid_proj_rev_rate_date.delete;
  l_fid_proj_rev_ex_rate.delete;

  l_fid_expfunc_cost_rate_type.delete;
  l_fid_expfunc_cost_rate_date.delete;
  l_fid_expfunc_cost_ex_rate.delete;

  l_fid_projfunc_cost_rate_type.delete;
  l_fid_projfunc_cost_rate_date.delete;
  l_fid_projfunc_cost_ex_rate.delete;

  l_fid_projfunc_rev_rate_type.delete;
  l_fid_projfunc_rev_rate_date.delete;
  l_fid_projfunc_rev_ex_rate.delete;

  l_fid_proj_tp_rate_type.delete;
  l_fid_proj_tp_rate_date.delete;
  l_fid_proj_tp_ex_rate.delete;
  l_fid_proj_tp_amt.delete;

  l_fid_projfunc_tp_rate_type.delete;
  l_fid_projfunc_tp_rate_date.delete;
  l_fid_projfunc_tp_ex_rate.delete;
  l_fid_projfunc_tp_amt.delete;

  l_fid_denom_tp_currcode.delete;
  l_fid_denom_tp_amt.delete;

  l_fid_expfunc_tp_rate_type.delete;
  l_fid_expfunc_tp_rate_date.delete;
  l_fid_expfunc_tp_ex_rate.delete;
  l_fid_expfunc_tp_amt.delete;

  /* Fcst Amount Details  start */

      l_fia_index := 1;
      l_fia_upd_index := 1;
      IF p_run_mode = 'F' THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.g_err_stage := 'Fetching Fcst_Item_All';
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         END IF;
         FETCH fcst_item_All BULK COLLECT INTO
            l_fi_id_tab,
            l_fi_item_type_tab,
            l_fi_exp_orgid_tab,
            l_fi_exp_organizationid_tab,
            l_fi_proj_orgid_tab,
            l_fi_proj_organizationid_tab,
            l_fi_projid_tab,
            l_fi_proj_type_class_tab,
            l_fi_personid_tab,
            l_fi_resid_tab,
            l_fi_asgid_tab,
            l_fi_date_tab,
            l_fi_uom_tab,
            l_fi_qty_tab,
            l_fi_pvdr_papd_tab,
            l_fi_rcvr_papd_tab,
            l_fi_exptype_tab,
            l_fi_exptypeclass_tab,
            l_fi_amount_type_tab,
            l_fi_delete_flag_tab LIMIT l_fetch_size;
      ELSIF p_run_mode = 'I' THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.g_err_stage := 'Fetching Fcst_Item_Inc';
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         END IF;
         FETCH fcst_item_Inc BULK COLLECT INTO
            l_fi_id_tab,
            l_fi_item_type_tab,
            l_fi_exp_orgid_tab,
            l_fi_exp_organizationid_tab,
            l_fi_proj_orgid_tab,
            l_fi_proj_organizationid_tab,
            l_fi_projid_tab,
            l_fi_proj_type_class_tab,
            l_fi_personid_tab,
            l_fi_resid_tab,
            l_fi_asgid_tab,
            l_fi_date_tab,
            l_fi_uom_tab,
            l_fi_qty_tab,
            l_fi_pvdr_papd_tab,
            l_fi_rcvr_papd_tab,
            l_fi_exptype_tab,
            l_fi_exptypeclass_tab,
            l_fi_amount_type_tab,
            l_fi_delete_flag_tab LIMIT l_fetch_size;
      ELSIF p_run_mode = 'P' AND p_select_criteria = '01' AND
          p_project_id IS NOT NULL AND p_assignment_id IS NULL      THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.g_err_stage := 'Fetching Fcst_Item_Prj';
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         END IF;
         FETCH fcst_item_Prj BULK COLLECT INTO
            l_fi_id_tab,
            l_fi_item_type_tab,
            l_fi_exp_orgid_tab,
            l_fi_exp_organizationid_tab,
            l_fi_proj_orgid_tab,
            l_fi_proj_organizationid_tab,
            l_fi_projid_tab,
            l_fi_proj_type_class_tab,
            l_fi_personid_tab,
            l_fi_resid_tab,
            l_fi_asgid_tab,
            l_fi_date_tab,
            l_fi_uom_tab,
            l_fi_qty_tab,
            l_fi_pvdr_papd_tab,
            l_fi_rcvr_papd_tab,
            l_fi_exptype_tab,
            l_fi_exptypeclass_tab,
            l_fi_amount_type_tab,
            l_fi_delete_flag_tab LIMIT l_fetch_size;
      ELSIF p_run_mode = 'P' AND p_select_criteria = '01' AND
          p_project_id IS NOT NULL AND p_assignment_id IS NOT NULL      THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.g_err_stage := 'Fetching Fcst_Item_Prj_Asg';
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         END IF;
         FETCH fcst_item_Prj_Asg BULK COLLECT INTO
            l_fi_id_tab,
            l_fi_item_type_tab,
            l_fi_exp_orgid_tab,
            l_fi_exp_organizationid_tab,
            l_fi_proj_orgid_tab,
            l_fi_proj_organizationid_tab,
            l_fi_projid_tab,
            l_fi_proj_type_class_tab,
            l_fi_personid_tab,
            l_fi_resid_tab,
            l_fi_asgid_tab,
            l_fi_date_tab,
            l_fi_uom_tab,
            l_fi_qty_tab,
            l_fi_pvdr_papd_tab,
            l_fi_rcvr_papd_tab,
            l_fi_exptype_tab,
            l_fi_exptypeclass_tab,
            l_fi_amount_type_tab,
            l_fi_delete_flag_tab LIMIT l_fetch_size;
    ELSIF p_run_mode = 'P' AND p_select_criteria in ( '02','03') THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.g_err_stage := 'Fetching fcst_item_Organization';
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
         END IF;
         FETCH fcst_item_Organization BULK COLLECT INTO
            l_fi_id_tab,
            l_fi_item_type_tab,
            l_fi_exp_orgid_tab,
            l_fi_exp_organizationid_tab,
            l_fi_proj_orgid_tab,
            l_fi_proj_organizationid_tab,
            l_fi_projid_tab,
            l_fi_proj_type_class_tab,
            l_fi_personid_tab,
            l_fi_resid_tab,
            l_fi_asgid_tab,
            l_fi_date_tab,
            l_fi_uom_tab,
            l_fi_qty_tab,
            l_fi_pvdr_papd_tab,
            l_fi_rcvr_papd_tab,
            l_fi_exptype_tab,
            l_fi_exptypeclass_tab,
            l_fi_amount_type_tab,
            l_fi_delete_flag_tab LIMIT l_fetch_size;
      END IF;
      IF l_fi_id_tab.count = 0 THEN
         EXIT;
      END IF;
      /* dbms_output.put_line('fetch count:'||l_fi_id_tab.count); */
      IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.g_err_stage := 'Fetch Count:'||l_fi_id_tab.COUNT;
         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;


      DELETE FROM Pa_Fi_Amount_Dtls_Tmp;
      COMMIT;


      /* Forecast Item records should be locked to prevent Update from
         Forecast Item generation Process */

      FORALL l_fi_lck_idx IN 1 .. l_fi_id_tab.COUNT
         UPDATE Pa_Forecast_Items SET Forecast_Amt_Calc_Flag = 'P'
             WHERE
         Forecast_Item_Id = l_fi_id_tab(l_fi_lck_idx);

      FOR I IN 1 .. l_fi_id_tab.count LOOP
        IF l_fi_item_type_tab(i) = 'R' THEN
           l_fi_item_type_tab(i) := 'ROLE';
        ELSIF l_fi_item_type_tab(i) = 'A' THEN
           l_fi_item_type_tab(i) := 'ASSIGNMENT';
        ELSIF l_fi_item_type_tab(i) = 'U' THEN
           l_fi_item_type_tab(i) := 'UNASSIGNED';
           l_process_fis_flag   := 'Y';
        END IF;
        l_fi_process_flag_tab(i) := 'Y';
        l_fi_others_rejct_reason_tab(i) := NULL;
        l_tp_exp_itemid(i) := l_fi_id_tab(i);

        /* dbms_output.put_line('fi id :'||l_fi_id_tab(i) );
        dbms_output.put_line('del fg:'||l_fi_delete_flag_tab(i) );  */

        IF l_fi_delete_flag_tab(i) = 'Y' OR l_fi_qty_tab(i) <= 0 THEN
           l_fi_process_flag_tab(i) := 'N';
           l_fi_others_rejct_reason_tab(i) := 'E';
        END IF;
        /* The following logic is included, because the FI generation process
           populates negative values if the Resource is transferred from Exp Orgz
           to Non-Exp Orgz         */
        IF ( l_fi_exp_orgid_tab(i)           < 0 AND l_fi_exp_orgid_tab(i) <> -99 ) OR
           ( l_fi_exp_organizationid_tab(i)  < 0 AND l_fi_exp_organizationid_tab(i) <> -99 ) OR
           ( l_fi_proj_orgid_tab(i)          < 0 AND l_fi_proj_orgid_tab(i) <> -99 ) OR
           ( l_fi_proj_organizationid_tab(i) < 0 AND l_fi_proj_organizationid_tab(i) <> -99 ) THEN
           l_fi_process_flag_tab(i) := 'X';
           l_fi_others_rejct_reason_tab(i) := 'E';
        END IF;


        IF l_prev_project_id <> l_fi_projId_tab(i) AND
           l_fi_process_flag_tab(i) = 'Y' THEN
           /* dbms_output.put_line('prev prj id :'||l_prev_project_id);
           dbms_output.put_line('curr prj id :'||l_fi_projid_tab(i)); */

           IF  P_PA_DEBUG_MODE = 'Y' THEN    -- Bug 7423839
               PA_DEBUG.g_err_stage := 'F I Amt: prev prj id :'||l_prev_project_id||' curr prj id :'||l_fi_projid_tab(i);
               PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
           END IF;


               l_prj_type := NULL;
               l_distribution_rule := NULL;
               l_bill_job_group_id := NULL;
               l_cost_job_group_id := NULL;
               l_job_bill_rate_sch_id := NULL;
               l_emp_bill_rate_sch_id := NULL;
               l_prj_curr_code := NULL;
               l_prj_rate_date := NULL;
               l_prj_rate_type := NULL;
               l_prj_bil_rate_date_code := NULL;
               l_prj_bil_rate_type := NULL;
               l_prj_bil_rate_date := NULL;
               l_prj_bil_ex_rate := NULL;
               l_prjfunc_curr_code := NULL;
               l_prjfunc_cost_rate_type := NULL;
               l_prjfunc_cost_rate_date := NULL;
               l_prjfunc_bil_rate_date_code := NULL;
               l_prjfunc_bil_rate_type      := NULL;
               l_prjfunc_bil_rate_date := NULL;
               l_prjfunc_bil_ex_rate := NULL;
               l_labor_tp_schedule_id := NULL;
               l_labor_tp_fixed_date := NULL;
               l_labor_sch_discount := NULL;
               l_asg_precedes_task := NULL;
               l_labor_bill_rate_orgid := NULL;
               l_labor_std_bill_rate_sch := NULL;
               l_labor_sch_fixed_dt := NULL;
               l_labor_sch_type := NULL;
           l_prev_project_id := l_fi_projid_tab(i);
           BEGIN
              SELECT Project_Type,
               DISTRIBUTION_RULE,
               BILL_JOB_GROUP_ID,
               COST_JOB_GROUP_ID,
               JOB_BILL_RATE_SCHEDULE_ID,
               EMP_BILL_RATE_SCHEDULE_ID,
               PROJECT_CURRENCY_CODE,
               PROJECT_RATE_DATE,
               PROJECT_RATE_TYPE,
               PROJECT_BIL_RATE_DATE_CODE,
               PROJECT_BIL_RATE_TYPE,
               PROJECT_BIL_RATE_DATE,
               PROJECT_BIL_EXCHANGE_RATE,
               PROJFUNC_CURRENCY_CODE,
               PROJFUNC_COST_RATE_TYPE,
               PROJFUNC_COST_RATE_DATE,
               PROJFUNC_BIL_RATE_DATE_CODE,
               PROJFUNC_BIL_RATE_TYPE,
               PROJFUNC_BIL_RATE_DATE,
               PROJFUNC_BIL_EXCHANGE_RATE,
               LABOR_TP_SCHEDULE_ID,
               LABOR_TP_FIXED_DATE,
               LABOR_SCHEDULE_DISCOUNT,
               ASSIGN_PRECEDES_TASK,
               NVL(LABOR_BILL_RATE_ORG_ID,-99),
               LABOR_STD_BILL_RATE_SCHDL,
               LABOR_SCHEDULE_FIXED_DATE,
               LABOR_SCH_TYPE
           INTO
               l_prj_type,
               l_distribution_rule,
               l_bill_job_group_id,
               l_cost_job_group_id,
               l_job_bill_rate_sch_id,
               l_emp_bill_rate_sch_id,
               l_prj_curr_code,
               l_prj_rate_date,
               l_prj_rate_type,
               l_prj_bil_rate_date_code,
               l_prj_bil_rate_type,
               l_prj_bil_rate_date,
               l_prj_bil_ex_rate,
               l_prjfunc_curr_code,
               l_prjfunc_cost_rate_type,
               l_prjfunc_cost_rate_date,
               l_prjfunc_bil_rate_date_code,
               l_prjfunc_bil_rate_type,
               l_prjfunc_bil_rate_date,
               l_prjfunc_bil_ex_rate,
               l_labor_tp_schedule_id,
               l_labor_tp_fixed_date,
               l_labor_sch_discount,
               l_asg_precedes_task,
               l_labor_bill_rate_orgid,
               l_labor_std_bill_rate_sch,
               l_labor_sch_fixed_dt,
               l_labor_sch_type
             FROM  Pa_Projects_All P
             WHERE P.Project_Id = l_prev_project_id;
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_fi_others_rejct_reason_tab(i) := 'PA_INVALID_PROJECT_ID';
              l_fi_process_flag_tab(i) := 'N';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 PA_DEBUG.g_err_stage := 'Invalid Project Id :'||TO_CHAR(l_prev_project_id);
                 PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
              END IF;
           END;
        END IF;

            /* dbms_output.put_line('after prj'); */

        l_fcst_cost_rate_schid := NULL;

        IF l_prev_proj_orgid <> l_fi_proj_orgid_tab(i) AND
           l_fi_process_flag_tab(i) = 'Y' THEN
           l_prev_proj_orgid := l_fi_proj_orgid_tab(i);
           BEGIN
               SELECT JOB_COST_RATE_SCHEDULE_ID INTO
               l_fcst_cost_rate_schid
                 FROM PA_FORECASTING_OPTIONS_ALL
               WHERE NVL(ORG_ID,-99) = l_prev_proj_orgid AND
                     JOB_COST_RATE_SCHEDULE_ID IS NOT NULL;
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 PA_DEBUG.g_err_stage := 'No Fcst Job Cost Rt Sch for Proj Orgid:' ||
                                          TO_CHAR(l_prev_proj_orgid);
                 PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
              END IF;
                 l_fi_others_rejct_reason_tab(i) := 'PA_FCST_NO_JOB_SCH_ID';
                 l_fi_process_flag_tab(i) := 'N';
           END;
        END IF;
            /* dbms_output.put_line('after options'); */

        l_prj_type_tab(i) :=  l_prj_type;
        l_distribution_rule_tab(i) :=  l_distribution_rule;
        l_bill_job_group_id_tab(i) :=  l_bill_job_group_id;
        l_cost_job_group_id_tab(i) :=  l_cost_job_group_id;
        l_job_bill_rate_sch_id_tab(i) :=  l_job_bill_rate_sch_id;
        l_emp_bill_rate_sch_id_tab(i) :=  l_emp_bill_rate_sch_id;
        l_prj_curr_code_tab(i) :=  l_prj_curr_code;
        l_prj_rate_date_tab(i) :=  l_prj_rate_date;
        l_prj_rate_type_tab(i) :=  l_prj_rate_type;
        l_prj_bil_rate_dt_code_tab(i) :=  l_prj_bil_rate_date_code;
        l_prj_bil_rate_type_tab(i) :=  l_prj_bil_rate_type;
        l_prj_bil_rate_date_tab(i) :=  l_prj_bil_rate_date;
        l_prj_bil_ex_rate_tab(i) :=  l_prj_bil_ex_rate;
        l_prjfunc_curr_code_tab(i) :=  l_prjfunc_curr_code;
        l_prjfunc_cost_rt_type_tab(i) :=  l_prjfunc_cost_rate_type;
        l_prjfunc_cost_rt_dt_tab(i) :=  l_prjfunc_cost_rate_date;
        l_prjfunc_bil_rt_dt_code_tab(i) :=  l_prjfunc_bil_rate_date_code;
        l_prjfunc_bil_rate_type_tab(i) :=  l_prjfunc_bil_rate_type;
        l_prjfunc_bil_rate_date_tab(i) :=  l_prjfunc_bil_rate_date;
        l_prjfunc_bil_ex_rate_tab(i) :=  l_prjfunc_bil_ex_rate;
        l_tp_scheduleid(i)           := l_labor_tp_schedule_id;
        l_tp_fixed_date(i)           := l_labor_tp_fixed_date;
        l_tp_denom_currcode(i)       := NULL;
        l_tp_denom_raw_cost(i)       := NULL;
        l_tp_denom_bd_cost(i)        := NULL;
        l_tp_raw_revenue(i)          := NULL;
        l_prj_cost_rate_schid_tab(i) := l_fcst_cost_rate_schid;

        l_labor_sch_discount_tab(i)       := l_labor_sch_discount;
        l_asg_precedes_task_tab(i)        := l_asg_precedes_task;
        l_labor_bill_rate_orgid_tab(i)    := l_labor_bill_rate_orgid;
        l_labor_std_bill_rate_sch_tab(i)  := l_labor_std_bill_rate_sch;
        l_labor_sch_fixed_dt_tab(i)       := l_labor_sch_fixed_dt;
        l_labor_sch_type_tab(i)           := l_labor_sch_type;


        l_asg_markup_percent := NULL;
        l_asg_bill_rate_override := NULL;
        l_asg_bill_rate_curr_override := NULL;
        l_asg_markup_percent_override := NULL;
        l_asg_tp_rate_override := NULL;
        l_asg_tp_curr_override := NULL;
        l_asg_tp_calc_base_code_ovr := NULL;
        l_asg_tp_percent_applied_ovr := NULL;

        l_asg_fcst_jobid_tab(i) := NULL;
        l_asg_fcst_jobgroupid_tab(i) := NULL;

        lx_cc_status_tab(i) := NULL;
        lx_tp_error_code(i) := NULL;

        IF ( l_prev_asg_id <> l_fi_asgid_tab(i) AND
             l_fi_asgid_tab(i) <> -9999  AND
             l_fi_process_flag_tab(i) = 'Y' ) THEN
           /* dbms_output.put_line('asg id changing prev id :'||l_prev_asg_id );
              dbms_output.put_line('asg id current  prev id :'||l_fi_asgid_tab(i) ); */
          l_prev_asg_id := l_fi_asgid_tab(i);
            /* dbms_output.put_line('inside asg ');
            dbms_output.put_line('asg id  '||l_prev_asg_id); */
          l_process_fis_flag := 'Y';
          BEGIN
            l_asg_fcst_job_id    := NULL;
            l_asg_fcst_job_group_id := NULL;
            l_asg_project_role_id := NULL;
            l_prj_assignment_type        := NULL;
            l_prj_status_code            := NULL;

            SELECT Fcst_Job_Id,
                   Fcst_Job_Group_Id,
                   Project_Role_Id,
                   MARKUP_PERCENT,
                   BILL_RATE_OVERRIDE,
                   BILL_RATE_CURR_OVERRIDE,
                   MARKUP_PERCENT_OVERRIDE,
                   TP_RATE_OVERRIDE,
                   TP_CURRENCY_OVERRIDE,
                   TP_CALC_BASE_CODE_OVERRIDE,
                   TP_PERCENT_APPLIED_OVERRIDE,
                   ASSIGNMENT_TYPE,
                   STATUS_CODE
             INTO
                   l_asg_fcst_job_id,
                   l_asg_fcst_job_group_id,
                   l_asg_project_role_id,
                   l_asg_markup_percent,
                   l_asg_bill_rate_override,
                   l_asg_bill_rate_curr_override,
                   l_asg_markup_percent_override,
                   l_asg_tp_rate_override,
                   l_asg_tp_curr_override,
                   l_asg_tp_calc_base_code_ovr,
                   l_asg_tp_percent_applied_ovr,
                   l_prj_assignment_type,
                   l_prj_status_code
             FROM  PA_PROJECT_ASSIGNMENTS P
             WHERE P.Assignment_Id = l_prev_asg_id;
             l_asg_fcst_jobid_tab(i) := l_asg_fcst_job_id;
             l_asg_fcst_jobgroupid_tab(i) := l_asg_fcst_job_group_id;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 PA_DEBUG.g_err_stage := 'Invalid Assignment Id:' ||
                                          TO_CHAR(l_prev_asg_id);
                 PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
              END IF;
              l_fi_others_rejct_reason_tab(i) := 'PA_FP_INVALID_ASG_ID';
              l_fi_process_flag_tab(i) := 'N';
            RAISE;
          END;
            /* dbms_output.put_line('after asg'); */

          /* The Forecast Items needs to be checked in the Assignment Level whether
             it needs to be processed or not. The flag l_process_fis_flag is used to set
             the l_fi_process_flag_tab PL SQL table value */

          IF l_fi_process_flag_tab(i) = 'Y' AND l_prj_status_code IS NOT NULL THEN
             IF l_prj_assignment_type = 'OPEN_ASSIGNMENT' THEN
               l_asgmt_status_flag := PA_ASSIGNMENT_UTILS.Is_Asgmt_In_Open_Status(
                                     l_prj_status_code,
                                     'OPEN_ASGMT');
               IF l_asgmt_status_flag = 'N' THEN
                 l_process_fis_flag := 'N';
               END IF;
             ELSIF ( l_prj_assignment_type = 'STAFFED_ASSIGNMENT' OR
                     l_prj_assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' ) THEN
               l_asgmt_status_flag := PA_ASSIGNMENT_UTILS.Is_Staffed_Asgmt_Cancelled(
                                     l_prj_status_code,
                                     'STAFFED_ASGMT');
               IF l_asgmt_status_flag = 'Y' THEN
                 l_process_fis_flag := 'N';
               END IF;
             END IF;
          END IF;
          /* dbms_output.put_line('asg id : fis process flag'||l_fi_asgid_tab(i) ||
                                             ' : ' ||l_process_fis_flag); */
          IF l_fi_item_type_tab(i) = 'R'  AND
             ( l_asg_fcst_job_id IS NULL  OR
               l_asg_fcst_job_group_id IS NULL ) AND
               l_process_fis_flag = 'Y'                  THEN
            BEGIN
              SELECT PR.DEFAULT_JOB_ID,
                     PJ.JOB_GROUP_ID
              INTO
                     l_asg_fcst_job_id,
                     l_asg_fcst_job_group_id
              FROM PA_PROJECT_ROLE_TYPES PR,
                   PER_JOBS PJ
              WHERE
                   PR.PROJECT_ROLE_ID = l_asg_project_role_id AND
                   PJ.JOB_ID          = PR.DEFAULT_JOB_ID;
              l_asg_fcst_jobid_tab(i) := l_asg_fcst_job_id;
              l_asg_fcst_jobgroupid_tab(i) := l_asg_fcst_job_group_id;
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_fi_others_rejct_reason_tab(i) := 'PA_FCST_NOJOB_FOR_ROLE';
                l_fi_process_flag_tab(i) := 'N';
                l_asg_fcst_job_id := NULL;
                l_asg_fcst_job_group_id := NULL;
              WHEN OTHERS THEN
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   PA_DEBUG.g_err_stage := 'Inside Prj Role others Excep';
                   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                END IF;
                RAISE;
            END;
          END IF;      /* fi item type = R   chk */
        END IF;       /* if asg id changes chk */
            /* dbms_output.put_line('after prj role '); */

        IF l_fi_asgid_tab(i) = -9999 THEN
           l_asg_fcst_jobid_tab(i) := NULL;
           l_asg_fcst_jobgroupid_tab(i) := NULL;
        ELSE
           l_asg_fcst_jobid_tab(i) := l_asg_fcst_job_id;
           l_asg_fcst_jobgroupid_tab(i) := l_asg_fcst_job_group_id;
           IF l_process_fis_flag = 'N' THEN
              l_fi_others_rejct_reason_tab(i) := 'E';
              l_fi_process_flag_tab(i) := 'X';

              /* Forecast Amt Calc Flag should be set to X, so that it would not be
                 picked up by Org Forecast Generation Process */
           END IF;
        END IF;

        l_cc_sys_link_tab(i) := NULL;
        l_cc_taskid_tab(i) := NULL;
        l_cc_expitemid_tab(i) := NULL;
        l_cc_transsource_tab(i) := NULL;
        l_cc_NLOrgzid_tab(i) := NULL;
        l_cc_prvdreid_tab(i) := NULL;
        l_cc_recvreid_tab(i) := NULL;
        lx_cc_type_tab(i) := NULL;
        lx_cc_code_tab(i) := NULL;
        lx_cc_prvdr_orgzid_tab(i) := NULL;
        lx_cc_recvr_orgzid_tab(i) := NULL;
        lx_cc_recvr_orgid_tab(i) := NULL;
        lx_cc_prvdr_orgid_tab(i) := NULL;

        IF l_prev_exp_type <> l_fi_exptype_tab(i) AND
           l_fi_process_flag_tab(i) = 'Y'         THEN
           l_prev_exp_type := l_fi_exptype_tab(i);
           BEGIN
             SELECT EXPENDITURE_CATEGORY
             INTO l_cc_exp_category
             FROM pa_expenditure_types WHERE
             EXPENDITURE_TYPE = l_prev_exp_type;
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
                l_fi_process_flag_tab(i) := 'N';
                l_cc_exp_category        := NULL;
           WHEN OTHERS THEN
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 PA_DEBUG.g_err_stage := 'Inside Exp Type others Excep';
                 PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
              END IF;
              RAISE;
           END;
        END IF;
            /* dbms_output.put_line('after sys link '); */
        l_tp_exp_category(i) := l_cc_exp_category;

        IF l_fi_process_flag_tab(i) = 'Y' THEN
           /* AND l_fi_amount_type_tab(i) IS NULL THEN */
             BEGIN
                SELECT
                TP_AMOUNT_TYPE
                INTO
                l_fi_amount_type_tab(i)
                FROM Pa_Forecast_Item_Details
                WHERE
                FORECAST_ITEM_ID = l_fi_id_tab(i) AND
                Line_Num = ( SELECT MAX(Line_Num) FROM
                Pa_Forecast_Item_Details WHERE
                Forecast_Item_Id = l_fi_id_tab(i) AND
                Net_Zero_Flag = 'N' );
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
                NULL;
                /* dbms_output.put_line('inside no data found for tp amt type'||
                                           l_fi_delete_flag_tab(i) );
                dbms_output.put_line('fi id :'||l_fi_id_tab(i) ); */
             WHEN OTHERS THEN
                retcode := '2';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   PA_DEBUG.g_err_stage := 'Inside FI Dtls others Excep';
                   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                END IF;
                RAISE;
             END;
           END IF;

        IF l_fi_process_flag_tab(i) <> 'Y' THEN
           lx_cc_status_tab(i) := 'E';
           lx_tp_error_code(i) := 'E';
        END IF;

        /* The Cross Charge API should process the Forecast Item only,
           if there is no error in the Forecast Item level and no error
           returned from the Rate API.

           The CC API checks for the X_StatusTab value and proceeds with processing
           only if the value is NULL    */


       /* dbms_output.put_line('fi prj id :<'||i ||'>' ||l_fi_projid_tab(i) ||
                             '  : '|| l_fi_id_tab(i));
        dbms_output.put_line('fi asg id :<'||i ||'>' ||l_fi_asgid_tab(i));
        dbms_output.put_line('proc flag and qty <'||i ||'>' ||l_fi_process_flag_tab(i)
                                  || ' Q  ' || l_fi_qty_tab(i) );
        dbms_output.put_line('others    :<'||i ||'>' ||l_fi_others_rejct_reason_tab(i));  */

         l_fi_rev_rejct_reason_tab(i) := NULL;
         l_fi_cst_rejct_reason_tab(i) := NULL;
         l_fi_bd_rejct_reason_tab(i) := NULL;
         l_fi_tp_rejct_reason_tab(i)     := NULL;

         l_fia_cost_txn_curr_code(i) := NULL;
         l_fia_rev_txn_curr_code(i) := NULL;
         l_fia_txn_raw_cost(i) := NULL;
         l_fia_txn_bd_cost(i) := NULL;
         l_fia_txn_revenue(i) := NULL;

         l_fia_expfunc_curr_code(i) := NULL;
         l_fia_expfunc_raw_cost(i) := NULL;
         l_fia_expfunc_bd_cost(i) := NULL;

         l_fia_projfunc_raw_cost(i) := NULL;
         l_fia_projfunc_bd_cost(i) := NULL;
         l_fia_projfunc_revenue(i) := NULL;

         l_fia_proj_raw_cost(i) := NULL;
         l_fia_proj_bd_cost(i) := NULL;
         l_fia_proj_revenue(i) := NULL;


         l_fia_proj_cost_rate_type(i) := NULL;
         l_fia_proj_cost_rate_date(i) := NULL;
         l_fia_proj_cost_ex_rate(i) := NULL;

         l_fia_proj_rev_rate_type(i) := NULL;
         l_fia_proj_rev_rate_date(i) := NULL;
         l_fia_proj_rev_ex_rate(i) := NULL;

         l_fia_expfunc_cost_rate_type(i) := NULL;
         l_fia_expfunc_cost_rate_date(i) := NULL;
         l_fia_expfunc_cost_ex_rate(i) := NULL;

         l_fia_projfunc_cost_rate_type(i) := NULL;
         l_fia_projfunc_cost_rate_date(i) := NULL;
         l_fia_projfunc_cost_ex_rate(i) := NULL;

         l_fia_projfunc_rev_rate_type(i) := NULL;
         l_fia_projfunc_rev_rate_date(i) := NULL;
         l_fia_projfunc_rev_ex_rate(i) := NULL;


      END LOOP;
       /* end loop for setting other plsql table values
      for rt_tmp in 1 .. l_fi_id_tab.count loop
          dbms_output.put_line('index: '||rt_tmp ||' asg id '||
                     l_fi_asgid_tab(rt_tmp) || ' job id :job gr id: '||
                     l_asg_fcst_jobid_tab(rt_tmp)|| '  '||
                     l_asg_fcst_jobgroupid_tab(rt_tmp)||' fl '||
                      l_fi_process_flag_tab(rt_tmp) || ' '||
                       l_fi_id_tab(rt_tmp));
      end loop;   */
      /* calling Rate API */
      /* dbms_output.put_line('before assigning variables for Rate api ');  */
      l_prev_rt_prj_id := l_fi_projid_tab(1);
      l_prev_rt_asg_id := l_fi_asgid_tab(1);
      l_prev_rt_personid := l_fi_personid_tab(1);
      l_prev_rt_fi_itemtype := l_fi_item_type_tab(1);
      l_prev_rt_fi_proc_flag := l_fi_process_flag_tab(1);
      l_prev_rt_calling_mode := l_fi_item_type_tab(1);
      l_prev_rt_fcst_jobid  := l_asg_fcst_jobid_tab(1);
      l_prev_rt_fcst_jobgroupid := l_asg_fcst_jobgroupid_tab(1);
      l_prev_rt_exp_type := l_fi_exptype_tab(1);
      l_prev_rt_org_id  := l_fi_proj_orgid_tab(1);
      l_prev_rt_prj_type := l_prj_type_tab(1);
      l_prev_rt_projfunc_currcode := l_prjfunc_curr_code_tab(1);
      l_prev_rt_proj_currcode := l_prj_curr_code_tab(1);
      l_prev_rt_bill_jobgroup_id  := l_bill_job_group_id_tab(1);
      l_prev_rt_emp_bilrate_schid := l_emp_bill_rate_sch_id_tab(1);
      l_prev_rt_job_bilrate_schid := l_job_bill_rate_sch_id_tab(1);
      l_prev_rt_dist_rule         := l_distribution_rule_tab(1);
      l_prev_rt_cost_rate_schid   := l_prj_cost_rate_schid_tab(1);

      l_prev_rt_labor_sch_discount := l_labor_sch_discount_tab(1);
      l_prev_rt_asg_precedes_task := l_asg_precedes_task_tab(1);
      l_prev_rt_labor_bill_rt_orgid := l_labor_bill_rate_orgid_tab(1);
      l_prev_rt_labor_std_bl_rt_sch := l_labor_std_bill_rate_sch_tab(1);
      l_prev_rt_labor_sch_fixed_dt := l_labor_sch_fixed_dt_tab(1);
      l_prev_rt_labor_sch_type := l_labor_sch_type_tab(1);

      /* dbms_output.put_line('after assigning variables for Rate api '); */

      l_rt_fi_id_tab.delete;
      l_rt_start_date_tab.delete;
      l_rt_qty_tab.delete;
      l_rt_exp_org_id_tab.delete;
      l_rt_exp_organization_id_tab.delete;
      l_rt_system_linkage_tab.delete;
      lx_rt_others_rejct_reason_tab.delete;

      /* new parameters added for Org Forecast */


   l_rt_pfunc_rev_rt_date_tab.delete;
   l_rt_pfunc_rev_rt_type_tab.delete;
   l_rt_pfunc_rev_ex_rt_tab.delete;

   l_rt_pfunc_cost_rt_date_tab.delete;
   l_rt_pfunc_cost_rt_type_tab.delete;

   l_rt_proj_cost_rt_date_tab.delete;
   l_rt_proj_cost_rt_type_tab.delete;
   l_rt_proj_rev_rt_date_tab.delete;
   l_rt_proj_rev_rt_type_tab.delete;
   l_rt_proj_rev_ex_rt_tab.delete;
   l_rt_proj_rev_rt_dt_code_tab.delete;
   l_rt_pfunc_rev_rt_dt_code_tab.delete;

      l_temp_last := l_fi_id_tab.LAST;

      FOR m IN 1 .. l_fi_id_tab.count LOOP
          IF  ( ( l_prev_rt_prj_id <> l_fi_projid_tab(m) ) OR

              ( l_prev_rt_asg_id <> l_fi_asgid_tab(m)  AND
                l_prev_rt_asg_id  > 0 AND l_fi_asgid_tab(m) > 0 ) OR
              ( l_prev_rt_asg_id = -9999 AND l_fi_asgid_tab(m) > 0 ) OR
              ( l_prev_rt_asg_id > 0  AND l_fi_asgid_tab(m) = -9999 ) OR
              ( l_prev_rt_asg_id IS NOT NULL and l_fi_asgid_tab(m) IS NULL ) OR
              ( l_prev_rt_asg_id = -9999 and l_fi_asgid_tab(m) = -9999 AND
                l_prev_rt_personid <> l_fi_personid_tab(m) ) )
          OR ( m = l_temp_last )   THEN
                 /* dbms_output.put_line('prev asg id :'||l_prev_rt_asg_id);
                 dbms_output.put_line('curr asg id :'||l_fi_asgid_tab(m));
                 dbms_output.put_line('prev per id :'||l_prev_rt_personid);
                 dbms_output.put_line('curr per id :'||l_fi_personid_tab(m));
                 dbms_output.put_line('prev prj id :'||l_prev_rt_prj_id);
                 dbms_output.put_line('curr prj id :'|| l_fi_projid_tab(m)); */
                    IF m = l_temp_last AND l_fi_process_flag_tab(m) = 'Y' THEN
                       l_prev_rt_prj_id := l_fi_projid_tab(m);
                       l_prev_rt_asg_id := l_fi_asgid_tab(m);
                       l_prev_rt_personid := l_fi_personid_tab(m);
                       l_prev_rt_fi_itemtype := l_fi_item_type_tab(m);
                       l_prev_rt_fi_proc_flag := l_fi_process_flag_tab(m);
                       l_prev_rt_calling_mode := l_fi_item_type_tab(m);
                       l_prev_rt_fcst_jobid  := l_asg_fcst_jobid_tab(m);
                       l_prev_rt_fcst_jobgroupid := l_asg_fcst_jobgroupid_tab(m);
                       l_prev_rt_exp_type := l_fi_exptype_tab(m);
                       l_prev_rt_org_id  := l_fi_proj_orgid_tab(m);
                       l_prev_rt_prj_type := l_prj_type_tab(m);
                       l_prev_rt_projfunc_currcode := l_prjfunc_curr_code_tab(m);
                       l_prev_rt_proj_currcode := l_prj_curr_code_tab(m);
                       l_prev_rt_bill_jobgroup_id  := l_bill_job_group_id_tab(m);
                       l_prev_rt_emp_bilrate_schid := l_emp_bill_rate_sch_id_tab(m);
                       l_prev_rt_job_bilrate_schid := l_job_bill_rate_sch_id_tab(m);
                       l_prev_rt_dist_rule         := l_distribution_rule_tab(m);
                       l_prev_rt_cost_rate_schid   := l_prj_cost_rate_schid_tab(m);

                       l_prev_rt_labor_sch_discount := l_labor_sch_discount_tab(m);
                       l_prev_rt_asg_precedes_task := l_asg_precedes_task_tab(m);
                       l_prev_rt_labor_bill_rt_orgid := l_labor_bill_rate_orgid_tab(m);
                       l_prev_rt_labor_std_bl_rt_sch := l_labor_std_bill_rate_sch_tab(m);
                       l_prev_rt_labor_sch_fixed_dt := l_labor_sch_fixed_dt_tab(m);
                       l_prev_rt_labor_sch_type := l_labor_sch_type_tab(m);

                       l_rt_fi_id_tab(m)       := l_fi_id_tab(m);
                       l_rt_start_date_tab(m)  := l_fi_date_tab(m);
                       l_rt_qty_tab(m)        := l_fi_qty_tab(m);
                       l_rt_system_linkage_tab(m) := l_fi_exptypeclass_tab(m);
                       l_rt_exp_org_id_tab(m)  := l_fi_exp_orgid_tab(m);
                       l_rt_exp_organization_id_tab(m) := l_fi_exp_organizationid_tab(m);
                       lx_rt_others_rejct_reason_tab(m) := l_fi_others_rejct_reason_tab(m);

                       l_rt_pfunc_rev_rt_date_tab(m)    := l_prjfunc_bil_rate_date_tab(m);
                       l_rt_pfunc_rev_rt_type_tab(m)    := l_prjfunc_bil_rate_type_tab(m);
                       l_rt_pfunc_rev_ex_rt_tab(m)      := l_prjfunc_bil_ex_rate_tab(m);
                       l_rt_pfunc_cost_rt_date_tab(m)   := l_prjfunc_cost_rt_dt_tab(m);
                       l_rt_pfunc_cost_rt_type_tab(m)   := l_prjfunc_cost_rt_type_tab(m);
                       l_rt_proj_cost_rt_date_tab(m)    := l_prj_rate_date_tab(m);
                       l_rt_proj_cost_rt_type_tab(m)    := l_prj_rate_type_tab(m);
                       l_rt_proj_rev_rt_date_tab(m)     := l_prj_bil_rate_date_tab(m);
                       l_rt_proj_rev_rt_type_tab(m)     := l_prj_bil_rate_type_tab(m);
                       l_rt_proj_rev_ex_rt_tab(m)       := l_prj_bil_ex_rate_tab(m);
                       l_rt_proj_rev_rt_dt_code_tab(m)  := l_prjfunc_bil_rt_dt_code_tab(m);
                       l_rt_pfunc_rev_rt_dt_code_tab(m) := l_prj_bil_rate_dt_code_tab(m);
                 END IF;

                 IF l_rt_start_date_tab.COUNT > 0 THEN

                      /*   dbms_output.put_line('st dt :'|| l_rt_start_date_tab.count);
                         dbms_output.put_line('id :'||   l_rt_fi_id_tab.count);
                         dbms_output.put_line('qty :'|| l_rt_qty_tab.count);
                         dbms_output.put_line('sys lk:'|| l_rt_system_linkage_tab.count);
                         dbms_output.put_line('exp org :'||   l_rt_exp_org_id_tab.count);
                         dbms_output.put_line('exp orgz :'||l_rt_exp_organization_id_tab.count);
                         dbms_output.put_line('pf bl rt  dt:'|| l_rt_pfunc_rev_rt_date_tab.count);
                         dbms_output.put_line('pf bl rt ty :'||l_rt_pfunc_rev_rt_type_tab.count);
                         dbms_output.put_line('pf bl ex rt :'||l_rt_pfunc_rev_ex_rt_tab.count);
                         dbms_output.put_line('pf ct rt dt :'||l_rt_pfunc_cost_rt_date_tab.count);
                         dbms_output.put_line('pf ct rt ty :'||l_rt_pfunc_cost_rt_type_tab.count);
                         dbms_output.put_line('pf bl rt dt cd :'||l_rt_pfunc_rev_rt_dt_code_tab.count);
                         dbms_output.put_line('p bl rt dt:'||l_rt_proj_rev_rt_date_tab.count);
                         dbms_output.put_line('p_bl_rt ty:'|| l_rt_proj_rev_rt_type_tab.count);
                         dbms_output.put_line('p_bl_ex rt:'||l_rt_proj_rev_ex_rt_tab.count);
                         dbms_output.put_line('p bl rt dt cd:'||l_rt_proj_rev_rt_dt_code_tab.count);
                         dbms_output.put_line('p ct rt dt:'|| l_rt_proj_cost_rt_date_tab.count);
                         dbms_output.put_line('p ct rt ty:'|| l_rt_proj_cost_rt_type_tab.count);
                         dbms_output.put_line('other :'||lx_rt_others_rejct_reason_tab.count);
                         dbms_output.put_line('asg id :'||l_prev_rt_asg_id);
                         dbms_output.put_line('asg id :'||l_prev_rt_asg_id);  */

                      IF l_prev_rt_fi_itemtype = 'UNASSIGNED' THEN
                         l_amount_calc_mode := 'COST';
                      ELSE
                         l_amount_calc_mode := 'ALL';
                      END IF;

                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         PA_DEBUG.g_err_stage := 'Bef calling Rate API for Asg Id:Person Id' ||
                                                  TO_CHAR(l_prev_rt_asg_id)||' : '||
                                                  TO_CHAR(l_prev_rt_personid);
                         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                      END IF;
                      /*   dbms_output.put_line('before calling Rate api :count'||
                                        l_rt_start_date_tab.count); */

                      IF  P_PA_DEBUG_MODE = 'Y' THEN -- Bug 7423839
                        PA_DEBUG.g_err_stage := 'F I Amt: prj id :'||l_prev_rt_prj_id||' proj type:'||l_prev_rt_prj_type;
                        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                      END IF;

                      Begin
                      PA_RATE_PVT_PKG.Calc_Rate_Amount(
                         P_CALLING_MODE                   =>  l_prev_rt_fi_itemtype,
                         p_forecasting_type               => 'ORG_FORECASTING',
                         p_amount_calc_mode               =>  l_amount_calc_mode,
                         P_RATE_CALC_DATE_TAB             =>  l_rt_start_date_tab,
                         P_ITEM_ID                        =>  l_prev_rt_asg_id,
                         P_ASSIGN_PRECEDES_TASK           => l_prev_rt_asg_precedes_task,
                         P_LABOR_SCHDL_DISCNT             => l_prev_rt_labor_sch_discount,
                         P_LABOR_BILL_RATE_ORG_ID         => l_prev_rt_labor_bill_rt_orgid,
                         P_LABOR_STD_BILL_RATE_SCHDL      => l_prev_rt_labor_std_bl_rt_sch,
                         P_LABOR_SCHEDULE_FIXED_DATE      => l_prev_rt_labor_sch_fixed_dt,
                         P_LABOR_SCH_TYPE                 => l_prev_rt_labor_sch_type,
                         p_forecast_item_id_tab           =>  l_rt_fi_id_tab,
                         P_ASGN_START_DATE                =>  NULL,
                         P_PROJECT_ID                     =>  l_prev_rt_prj_id,
                         P_QUANTITY_TAB                   =>  l_rt_qty_tab,
                         P_SYSTEM_LINKAGE                 =>  l_rt_system_linkage_tab,
                         P_FORECAST_JOB_ID                =>  l_prev_rt_fcst_jobid,
                         P_FORECAST_JOB_GROUP_ID          =>  l_prev_rt_fcst_jobgroupid,
                         P_PERSON_ID                      =>  l_prev_rt_personid,
                         P_EXPENDITURE_ORG_ID_TAB         =>  l_rt_exp_org_id_tab,
                         P_EXPENDITURE_TYPE               =>  l_prev_rt_exp_type,
                         P_EXPENDITURE_ORGZ_ID_TAB        =>  l_rt_exp_organization_id_tab,
                         P_PROJECT_ORG_ID                 =>  l_prev_rt_org_id,
                         P_LABOR_COST_MULTI_NAME          => NULL,
                         P_PROJ_COST_JOB_GROUP_ID         => NULL,
                         P_JOB_COST_RATE_SCHEDULE_ID      => l_prev_rt_cost_rate_schid,
                         P_PROJECT_TYPE                   => l_prev_rt_prj_type,
                         P_TASK_ID                        => NULL,
                         P_PROJFUNC_CURRENCY_CODE         => l_prev_rt_projfunc_currcode,
                         P_BILL_RATE_MULTIPLIER           => NULL,
                         P_PROJECT_BILL_JOB_GROUP_ID      => l_prev_rt_bill_jobgroup_id,
                         P_EMP_BILL_RATE_SCHEDULE_ID      => l_prev_rt_emp_bilrate_schid,
                         P_JOB_BILL_RATE_SCHEDULE_ID      => l_prev_rt_job_bilrate_schid,
                         P_DISTRIBUTION_RULE              => l_prev_rt_dist_rule,
                         X_PROJFUNC_BILL_RT_TAB           => lx_rt_projfunc_bill_rate_tab,
                         X_PROJFUNC_RAW_REVENUE_TAB       => lx_rt_pfunc_raw_revenue_tab,
                         X_PROJFUNC_RAW_CST_TAB           => lx_rt_pfunc_raw_cost_tab,
                         X_PROJFUNC_RAW_CST_RT_TAB        => lx_rt_pfunc_raw_cost_rt_tab,
                         X_PROJFUNC_BURDNED_CST_TAB       => lx_rt_pfunc_bd_cost_tab,
                         X_PROJFUNC_BURDNED_CST_RT_TAB    => lx_rt_pfunc_bd_cost_rt_tab,
                         p_projfunc_rev_rt_date_tab       => l_rt_pfunc_rev_rt_date_tab,
                         p_projfunc_rev_rt_type_tab       => l_rt_pfunc_rev_rt_type_tab,
                         p_projfunc_rev_exch_rt_tab       => l_rt_pfunc_rev_ex_rt_tab,
                         p_projfunc_cst_rt_date_tab       => l_rt_pfunc_cost_rt_date_tab,
                         p_projfunc_cst_rt_type_tab       => l_rt_pfunc_cost_rt_type_tab,
                         x_projfunc_rev_rt_date_tab       => lx_rt_pfunc_rev_rt_date_tab,
                         x_projfunc_rev_rt_type_tab       => lx_rt_pfunc_rev_rt_type_tab,
                         x_projfunc_rev_exch_rt_tab       => lx_rt_pfunc_rev_ex_rt_tab,
                         p_projfunc_rev_rt_dt_code_tab    => l_rt_pfunc_rev_rt_dt_code_tab,
                         x_projfunc_cst_rt_date_tab       => lx_rt_pfunc_cost_rt_date_tab,
                         x_projfunc_cst_rt_type_tab       => lx_rt_pfunc_cost_rt_type_tab,
                         x_projfunc_cst_exch_rt_tab       => lx_rt_pfunc_cost_ex_rt_tab,
                         p_project_currency_code          => l_prev_rt_proj_currcode,
                         x_project_bill_rt_tab            => lx_rt_proj_bill_rate_tab,
                         x_project_raw_revenue_tab        => lx_rt_proj_raw_revenue_tab,
                         p_project_rev_rt_date_tab        => l_rt_proj_rev_rt_date_tab,
                         p_project_rev_rt_type_tab        => l_rt_proj_rev_rt_type_tab,
                         p_project_rev_exch_rt_tab        => l_rt_proj_rev_ex_rt_tab,
                         p_project_rev_rt_dt_code_tab     => l_rt_proj_rev_rt_dt_code_tab,
                         x_project_rev_rt_date_tab        => lx_rt_proj_rev_rt_date_tab,
                         x_project_rev_rt_type_tab        => lx_rt_proj_rev_rt_type_tab,
                         x_project_rev_exch_rt_tab        => lx_rt_proj_rev_ex_rt_tab,
                         x_project_raw_cst_tab            => lx_rt_proj_raw_cost_tab,
                         x_project_raw_cst_rt_tab         => lx_rt_proj_raw_cost_rt_tab,
                         x_project_burdned_cst_tab        => lx_rt_proj_bd_cost_tab,
                         x_project_burdned_cst_rt_tab     => lx_rt_proj_bd_cost_rt_tab,
                         p_project_cst_rt_date_tab        => l_rt_proj_cost_rt_date_tab,
                         p_project_cst_rt_type_tab        => l_rt_proj_cost_rt_type_tab,
                         x_project_cst_rt_date_tab        => lx_rt_proj_cost_rt_date_tab,
                         x_project_cst_rt_type_tab        => lx_rt_proj_cost_rt_type_tab,
                         x_project_cst_exch_rt_tab        => lx_rt_proj_cost_ex_rt_tab,
                         x_exp_func_curr_code_tab         => lx_rt_expfunc_curr_code_tab,
                         x_exp_func_raw_cst_rt_tab        => lx_rt_expfunc_raw_cst_rt_tab,
                         x_exp_func_raw_cst_tab           => lx_rt_expfunc_raw_cst_tab,
                         x_exp_func_burdned_cst_rt_tab    => lx_rt_expfunc_bd_cst_rt_tab,
                         x_exp_func_burdned_cst_tab       => lx_rt_expfunc_bd_cst_tab,
                         x_exp_func_cst_rt_date_tab       => lx_rt_expfunc_cost_rt_date_tab,
                         x_exp_func_cst_rt_type_tab       => lx_rt_expfunc_cost_rt_type_tab,
                         x_exp_func_cst_exch_rt_tab       => lx_rt_expfunc_cost_ex_rt_tab,
                         x_cst_txn_curr_code_tab          => lx_rt_cost_txn_curr_code_tab,
                         x_txn_raw_cst_rt_tab             => lx_rt_txn_raw_cost_rt_tab,
                         x_txn_raw_cst_tab                => lx_rt_txn_raw_cost_tab,
                         x_txn_burdned_cst_rt_tab         => lx_rt_txn_bd_cost_rt_tab,
                         x_txn_burdned_cst_tab            => lx_rt_txn_bd_cost_tab,
                         x_rev_txn_curr_code_tab          => lx_rt_rev_txn_curr_code_tab,
                         x_txn_rev_bill_rt_tab            => lx_rt_txn_rev_bill_rt_tab,
                         x_txn_rev_raw_revenue_tab        => lx_rt_txn_raw_revenue_tab,
                         X_ERROR_MSG                      => lx_rt_error_msg,
                         X_REV_REJCT_REASON_TAB           => lx_rt_rev_rejct_reason_tab,
                         X_CST_REJCT_REASON_TAB           => lx_rt_cst_rejct_reason_tab,
                         X_BURDNED_REJCT_REASON_TAB       => lx_rt_bd_rejct_reason_tab,
                         X_OTHERS_REJCT_REASON_TAB        => lx_rt_others_rejct_reason_tab,
                         X_RETURN_STATUS                  => lx_rt_return_status,
                         X_MSG_COUNT                      => lx_rt_msg_count,
                         X_MSG_DATA                       => lx_rt_msg_data  );

    exception  -- Bug 7423839
        when others then
            IF P_PA_DEBUG_MODE  = 'Y' THEN
               PA_DEBUG.g_err_stage := 'Error in PA_RATE_PVT_PKG.Calc_Rate_Amount';
               PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
               PA_DEBUG.Log_Message(p_message => 'x_msg_count '||lx_rt_msg_count || 'l_msg_data '||substr(lx_rt_msg_data,1,300));
               PA_DEBUG.Log_Message(p_message => 'X_ERROR_MSG '||substr(lx_rt_error_msg,1,300) || 'X_RETURN_STATUS '||lx_rt_return_status);
            END IF;
            Raise;
    end;

                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         PA_DEBUG.g_err_stage := 'Aft calling Rate API';
                         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                      END IF;
                      /* dbms_output.put_line('after calling Rate api'); */

             FOR k IN l_fi_process_flag_tab.FIRST .. l_fi_process_flag_tab.LAST LOOP
              IF l_fi_process_flag_tab(k) = 'Y' THEN
                      /* dbms_output.put_line('fi id in rt:'||k ||':'||
                                    l_fi_id_tab(k)); */

                IF lx_rt_cost_txn_curr_code_tab.exists(k) THEN
                   l_tp_denom_currcode(k) := lx_rt_cost_txn_curr_code_tab(k);
                END IF;
                IF lx_rt_txn_raw_cost_tab.exists(k) THEN
                   l_tp_denom_raw_cost(k)          := lx_rt_txn_raw_cost_tab(k);
                END IF;
                IF lx_rt_txn_bd_cost_tab.exists(k) THEN
                   l_tp_denom_bd_cost(k)           := lx_rt_txn_bd_cost_tab(k);
                END IF;
                /* Transfer price API supports only Txn currency for Cost and for
                   Revenue always Project Functional Currency Amount should be passed
                   bug 2444090 */
                IF lx_rt_pfunc_raw_revenue_tab.exists(k) THEN
                   l_tp_raw_revenue(k)             := lx_rt_pfunc_raw_revenue_tab(k);
                END IF;


                IF lx_rt_pfunc_raw_cost_tab.exists(k) THEN
                   l_fia_projfunc_raw_cost(k) := lx_rt_pfunc_raw_cost_tab(k);
                END IF;
                IF lx_rt_pfunc_bd_cost_tab.exists(k) THEN
                   l_fia_projfunc_bd_cost(k) := lx_rt_pfunc_bd_cost_tab(k);
                END IF;
                IF lx_rt_pfunc_raw_revenue_tab.exists(k) THEN
                   l_fia_projfunc_revenue(k) := lx_rt_pfunc_raw_revenue_tab(k);
                END IF;

                /* dbms_output.put_line('prjfunc raw cost :'||l_fia_projfunc_raw_cost(k) );
                dbms_output.put_line('prjfunc bd  cost :'||l_fia_projfunc_bd_cost(k) );
                dbms_output.put_line('prjfunc     rev  :'||l_fia_projfunc_revenue(k) ); */

                IF lx_rt_pfunc_cost_rt_type_tab.exists(k) THEN
                   l_fia_projfunc_cost_rate_type(k) := lx_rt_pfunc_cost_rt_type_tab(k);
                END IF;
                IF lx_rt_pfunc_cost_rt_date_tab.exists(k) THEN
                   l_fia_projfunc_cost_rate_date(k) := lx_rt_pfunc_cost_rt_date_tab(k);
                END IF;
                IF lx_rt_pfunc_cost_ex_rt_tab.exists(k) THEN
                   l_fia_projfunc_cost_ex_rate(k) := lx_rt_pfunc_cost_ex_rt_tab(k);
                END IF;

                IF lx_rt_pfunc_rev_rt_type_tab.exists(k) THEN
                   l_fia_projfunc_rev_rate_type(k) := lx_rt_pfunc_rev_rt_type_tab(k);
                END IF;

                IF lx_rt_pfunc_rev_rt_date_tab.exists(k) THEN
                   l_fia_projfunc_rev_rate_date(k) := lx_rt_pfunc_rev_rt_date_tab(k);
                END IF;
                IF lx_rt_pfunc_rev_ex_rt_tab.exists(k) THEN
                   l_fia_projfunc_rev_ex_rate(k) := lx_rt_pfunc_rev_ex_rt_tab(k);
                END IF;

                IF lx_rt_proj_raw_cost_tab.exists(k) THEN
                   l_fia_proj_raw_cost(k) := lx_rt_proj_raw_cost_tab(k);
                END IF;
                IF lx_rt_proj_bd_cost_tab.exists(k) THEN
                   l_fia_proj_bd_cost(k) := lx_rt_proj_bd_cost_tab(k);
                END IF;
                IF lx_rt_proj_raw_revenue_tab.exists(k) THEN
                   l_fia_proj_revenue(k) := lx_rt_proj_raw_revenue_tab(k);
                END IF;
                   /* dbms_output.put_line('prj     raw cost :'||l_fia_proj_raw_cost(k) );
                   dbms_output.put_line('prj     bd  cost :'||l_fia_proj_bd_cost(k) );
                   dbms_output.put_line('prj         rev  :'||l_fia_proj_revenue(k) ); */
                IF lx_rt_proj_cost_rt_type_tab.exists(k) THEN
                   l_fia_proj_cost_rate_type(k) := lx_rt_proj_cost_rt_type_tab(k);
                END IF;
                IF lx_rt_proj_cost_rt_date_tab.exists(k) THEN
                   l_fia_proj_cost_rate_date(k) := lx_rt_proj_cost_rt_date_tab(k);
                END IF;
                IF lx_rt_proj_cost_ex_rt_tab.exists(k) THEN
                   l_fia_proj_cost_ex_rate(k) := lx_rt_proj_cost_ex_rt_tab(k);
                   /* dbms_output.put_line('prj ex rt:'|| lx_rt_proj_cost_ex_rt_tab(k)); */
                END IF;
                IF lx_rt_proj_rev_rt_type_tab.exists(k) THEN
                   l_fia_proj_rev_rate_type(k) := lx_rt_proj_rev_rt_type_tab(k);
                END IF;
                IF lx_rt_proj_rev_rt_date_tab.exists(k) THEN
                   l_fia_proj_rev_rate_date(k) := lx_rt_proj_rev_rt_date_tab(k);
                END IF;
                IF lx_rt_proj_rev_ex_rt_tab.exists(k) THEN
                   l_fia_proj_rev_ex_rate(k) := lx_rt_proj_rev_ex_rt_tab(k);
                END IF;

                IF lx_rt_expfunc_curr_code_tab.exists(k) THEN
                   l_fia_expfunc_curr_code(k) := lx_rt_expfunc_curr_code_tab(k);
                END IF;
                IF lx_rt_expfunc_cost_rt_type_tab.exists(k) THEN
                   l_fia_expfunc_cost_rate_type(k) := lx_rt_expfunc_cost_rt_type_tab(k);
                END IF;
                IF lx_rt_expfunc_cost_rt_date_tab.exists(k) THEN
                   l_fia_expfunc_cost_rate_date(k) := lx_rt_expfunc_cost_rt_date_tab(k);
                END IF;
                IF lx_rt_expfunc_cost_ex_rt_tab.exists(k) THEN
                   l_fia_expfunc_cost_ex_rate(k) := lx_rt_expfunc_cost_ex_rt_tab(k);
                END IF;
                IF lx_rt_expfunc_raw_cst_tab.exists(k) THEN
                   l_fia_expfunc_raw_cost(k) := lx_rt_expfunc_raw_cst_tab(k);
                END IF;
                IF lx_rt_expfunc_bd_cst_tab.exists(k) THEN
                   l_fia_expfunc_bd_cost(k) := lx_rt_expfunc_bd_cst_tab(k);
                END IF;

                IF lx_rt_cost_txn_curr_code_tab.exists(k) THEN
                   l_fia_cost_txn_curr_code(k) := lx_rt_cost_txn_curr_code_tab(k);
                END IF;
                IF lx_rt_rev_txn_curr_code_tab.exists(k) THEN
                   l_fia_rev_txn_curr_code(k) := lx_rt_rev_txn_curr_code_tab(k);
                END IF;
                IF lx_rt_txn_raw_cost_tab.exists(k) THEN
                   l_fia_txn_raw_cost(k) := lx_rt_txn_raw_cost_tab(k);
                END IF;
                IF lx_rt_txn_bd_cost_tab.exists(k) THEN
                   l_fia_txn_bd_cost(k) := lx_rt_txn_bd_cost_tab(k);
                END IF;
                IF lx_rt_txn_raw_revenue_tab.exists(k) THEN
                   l_fia_txn_revenue(k) := lx_rt_txn_raw_revenue_tab(k);
                END IF;


                IF lx_rt_cst_rejct_reason_tab.exists(k) THEN
                   l_fi_cst_rejct_reason_tab(k)    := lx_rt_cst_rejct_reason_tab(k);
                END IF;
                IF lx_rt_rev_rejct_reason_tab.exists(k) THEN
                   l_fi_rev_rejct_reason_tab(k)    := lx_rt_rev_rejct_reason_tab(k);
                END IF;
                IF lx_rt_bd_rejct_reason_tab.exists(k) THEN
                   l_fi_bd_rejct_reason_tab(k)     := lx_rt_bd_rejct_reason_tab(k);
                END IF;
                IF lx_rt_others_rejct_reason_tab.exists(k) THEN
                   l_fi_others_rejct_reason_tab(k) := lx_rt_others_rejct_reason_tab(k);
                END IF;
                IF l_fi_process_flag_tab(k) = 'Y' AND
                   (  l_fi_rev_rejct_reason_tab(k)    IS NOT NULL OR
                      l_fi_cst_rejct_reason_tab(k)    IS NOT NULL OR
                      l_fi_bd_rejct_reason_tab(k)     IS NOT NULL OR
                      l_fi_others_rejct_reason_tab(k) IS NOT NULL     ) THEN
                      /* dbms_output.put_line('inside rate api error');
                      dbms_output.put_line('fi id:'||l_fi_id_tab(k));
                      dbms_output.put_line('rev rej code  :'||l_fi_rev_rejct_reason_tab(k));
                      dbms_output.put_line('cst rej code  :'||l_fi_cst_rejct_reason_tab(k));
                      dbms_output.put_line('bd  rej code  :'||l_fi_bd_rejct_reason_tab(k));
                      dbms_output.put_line('ot  rej code  :'||l_fi_others_rejct_reason_tab(k));
                      dbms_output.put_line('p     curr:'||l_prj_curr_code_tab(k)); */
                   lx_cc_status_tab(k) := 'E';
                   lx_tp_error_code(k) := 'E';
                   l_fi_process_flag_tab(k) := 'N';
                END IF;
              END IF;          /* for process flag tab = Y to avoid the index problem */
             END LOOP;

             l_rt_fi_id_tab.delete;
             l_rt_start_date_tab.delete;
             l_rt_qty_tab.delete;
             l_rt_system_linkage_tab.delete;
             l_rt_exp_org_id_tab.delete;
             l_rt_exp_organization_id_tab.delete;
             lx_rt_others_rejct_reason_tab.delete;

             l_rt_pfunc_rev_rt_date_tab.delete;
             l_rt_pfunc_rev_rt_type_tab.delete;
             l_rt_pfunc_rev_ex_rt_tab.delete;

             l_rt_pfunc_cost_rt_date_tab.delete;
             l_rt_pfunc_cost_rt_type_tab.delete;

             l_rt_proj_cost_rt_date_tab.delete;
             l_rt_proj_cost_rt_type_tab.delete;
             l_rt_proj_rev_rt_date_tab.delete;
             l_rt_proj_rev_rt_type_tab.delete;
             l_rt_proj_rev_ex_rt_tab.delete;
             l_rt_proj_rev_rt_dt_code_tab.delete;
             l_rt_pfunc_rev_rt_dt_code_tab.delete;
          END IF;           /* for rate table count > 0 */

             l_prev_rt_prj_id := l_fi_projid_tab(m);
             l_prev_rt_asg_id := l_fi_asgid_tab(m);
             l_prev_rt_personid := l_fi_personid_tab(m);
             l_prev_rt_fi_itemtype := l_fi_item_type_tab(m);
             l_prev_rt_fi_proc_flag := l_fi_process_flag_tab(m);
             l_prev_rt_calling_mode := l_fi_item_type_tab(m);
             l_prev_rt_fcst_jobid  := l_asg_fcst_jobid_tab(m);
             l_prev_rt_fcst_jobgroupid := l_asg_fcst_jobgroupid_tab(m);
             l_prev_rt_exp_type := l_fi_exptype_tab(m);
             l_prev_rt_org_id  := l_fi_proj_orgid_tab(m);
             l_prev_rt_prj_type := l_prj_type_tab(m);
             l_prev_rt_projfunc_currcode := l_prjfunc_curr_code_tab(m);
             l_prev_rt_proj_currcode := l_prj_curr_code_tab(m);
             l_prev_rt_bill_jobgroup_id  := l_bill_job_group_id_tab(m);
             l_prev_rt_emp_bilrate_schid := l_emp_bill_rate_sch_id_tab(m);
             l_prev_rt_job_bilrate_schid := l_job_bill_rate_sch_id_tab(m);
             l_prev_rt_dist_rule         := l_distribution_rule_tab(m);
             l_prev_rt_cost_rate_schid   := l_prj_cost_rate_schid_tab(m);

             l_prev_rt_labor_sch_discount := l_labor_sch_discount_tab(m);
             l_prev_rt_asg_precedes_task := l_asg_precedes_task_tab(m);
             l_prev_rt_labor_bill_rt_orgid := l_labor_bill_rate_orgid_tab(m);
             l_prev_rt_labor_std_bl_rt_sch := l_labor_std_bill_rate_sch_tab(m);
             l_prev_rt_labor_sch_fixed_dt := l_labor_sch_fixed_dt_tab(m);
             l_prev_rt_labor_sch_type := l_labor_sch_type_tab(m);

             /* dbms_output.put_line('inside any changes asg id :'||l_fi_asgid_tab(m)); */

          END IF;              /* if prj or asg id or person id changes   */
          IF l_fi_process_flag_tab(m) = 'Y' THEN
             l_rt_fi_id_tab(m)       := l_fi_id_tab(m);
             l_rt_start_date_tab(m)  := l_fi_date_tab(m);
             l_rt_qty_tab(m)        := l_fi_qty_tab(m);
             l_rt_system_linkage_tab(m) := l_fi_exptypeclass_tab(m);
             l_rt_exp_org_id_tab(m)  := l_fi_exp_orgid_tab(m);
             l_rt_exp_organization_id_tab(m) := l_fi_exp_organizationid_tab(m);
             lx_rt_others_rejct_reason_tab(m) := l_fi_others_rejct_reason_tab(m);

             l_rt_pfunc_rev_rt_date_tab(m)    := l_prjfunc_bil_rate_date_tab(m);
             l_rt_pfunc_rev_rt_type_tab(m)    := l_prjfunc_bil_rate_type_tab(m);
             l_rt_pfunc_rev_ex_rt_tab(m)      := l_prjfunc_bil_ex_rate_tab(m);
             l_rt_pfunc_cost_rt_date_tab(m)   := l_prjfunc_cost_rt_dt_tab(m);
             l_rt_pfunc_cost_rt_type_tab(m)   := l_prjfunc_cost_rt_type_tab(m);
             l_rt_proj_cost_rt_date_tab(m)    := l_prj_rate_date_tab(m);
             l_rt_proj_cost_rt_type_tab(m)    := l_prj_rate_type_tab(m);
             l_rt_proj_rev_rt_date_tab(m)     := l_prj_bil_rate_date_tab(m);
             l_rt_proj_rev_rt_type_tab(m)     := l_prj_bil_rate_type_tab(m);
             l_rt_proj_rev_ex_rt_tab(m)       := l_prj_bil_ex_rate_tab(m);
             l_rt_proj_rev_rt_dt_code_tab(m)  := l_prjfunc_bil_rt_dt_code_tab(m);
             l_rt_pfunc_rev_rt_dt_code_tab(m) := l_prj_bil_rate_dt_code_tab(m);


          END IF;
          l_prev_rt_fi_proc_flag := l_fi_process_flag_tab(m);
      END LOOP;              /* for I1  rate api call */

      lx_cc_error_stage      := NULL;
      lx_cc_error_code       := NULL;

       /* dbms_output.put_line('bef calling cc ident ');
        dbms_output.put_line('count exp orgzid :'||l_fi_exp_organizationid_tab.count);
       dbms_output.put_line('count exp org id :'||l_fi_exp_orgid_tab.count);
       dbms_output.put_line('count prj     id :'||l_fi_projid_tab.count);
       dbms_output.put_line('count tsk     id :'||l_cc_taskid_tab.count);
       dbms_output.put_line('count fi dt   id :'||l_fi_date_tab.count);
       dbms_output.put_line('count ex item id :'||l_cc_expitemid_tab.count);
       dbms_output.put_line('count person  id :'||l_fi_personid_tab.count);
       dbms_output.put_line('count exp   type :'||l_fi_exptype_tab.count);
       dbms_output.put_line('count sys   link :'||l_fi_exptypeclass_tab.count);
       dbms_output.put_line('count prj orgz id:'||l_fi_proj_organizationid_tab.count);
       dbms_output.put_line('count prj org  id:'||l_fi_proj_orgid_tab.count);
       dbms_output.put_line('count tran source:'||l_cc_transsource_tab.count);
       dbms_output.put_line('count nl orgz id :'||l_cc_NLOrgzid_tab.count);
       dbms_output.put_line('count prvdr eiid :'||l_cc_prvdreid_tab.count);
       dbms_output.put_line('count recvr eiid :'||l_cc_recvreid_tab.count);
       dbms_output.put_line('count status     :'||lx_cc_status_tab.count);
       dbms_output.put_line('count cc type    :'||lx_cc_type_tab.count);
       dbms_output.put_line('count cc code    :'||lx_cc_code_tab.count);
       dbms_output.put_line('count prvdr orgz :'||lx_cc_prvdr_orgzid_tab.count);
       dbms_output.put_line('count recvr orgz :'||lx_cc_recvr_orgzid_tab.count);
       dbms_output.put_line('count recvr org  :'||lx_cc_recvr_orgid_tab.count);
       dbms_output.put_line('count prvdr org  :'||lx_cc_prvdr_orgid_tab.count);   */

        IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.g_err_stage := 'Bef calling CC API';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

        Pa_Cc_Ident.PA_CC_IDENTIFY_TXN_FI(
          P_ExpOrganizationIdTab     => l_fi_exp_organizationid_tab,
          P_ExpOrgidTab              => l_fi_exp_orgid_tab,
          P_ProjectIdTab             => l_fi_projid_tab,
          P_TaskIdTab                => l_cc_taskid_tab,
          P_ExpItemDateTab           => l_fi_date_tab,
          P_ExpItemIdTab             => l_cc_expitemid_tab,
          P_PersonIdTab              => l_fi_personid_tab,
          P_ExpTypeTab               => l_fi_exptype_tab,
          P_SysLinkTab               => l_fi_exptypeclass_tab,
          P_PrjOrganizationIdTab     => l_fi_proj_organizationid_tab,
          P_PrjOrgIdTab              => l_fi_proj_orgid_tab,
          P_TransSourceTab           => l_cc_transsource_tab,
          P_NLROrganizationIdTab     => l_cc_NLOrgzid_tab,
          P_PrvdrLEIdTab             => l_cc_prvdreid_tab,
          P_RecvrLEIdTab             => l_cc_recvreid_tab,
          X_StatusTab                => lx_cc_status_tab,
          X_CrossChargeTypeTab       => lx_cc_type_tab,
          X_CrossChargeCodeTab       => lx_cc_code_tab,
          X_PrvdrOrganizationIdTab   => lx_cc_prvdr_orgzid_tab,
          X_RecvrOrganizationIdTab   => lx_cc_recvr_orgzid_tab,
          X_RecvrOrgIdTab            => lx_cc_recvr_orgid_tab,
          X_PrvdrOrgIdTab            => lx_cc_prvdr_orgid_tab,
          X_Error_Stage              => lx_cc_error_stage,
          X_Error_Code               => lx_cc_error_code                         );

        IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.g_err_stage := 'Aft calling CC API';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

       /* dbms_output.put_line('aft calling cc ident ');
       dbms_output.put_line('count exp orgzid :'||l_fi_exp_organizationid_tab.count);
       dbms_output.put_line('count exp org id :'||l_fi_exp_orgid_tab.count);
       dbms_output.put_line('count prj     id :'||l_fi_projid_tab.count);
       dbms_output.put_line('count tsk     id :'||l_cc_taskid_tab.count);
       dbms_output.put_line('count fi dt   id :'||l_fi_date_tab.count);
       dbms_output.put_line('count ex item id :'||l_cc_expitemid_tab.count);
       dbms_output.put_line('count person  id :'||l_fi_personid_tab.count);
       dbms_output.put_line('count exp   type :'||l_fi_exptype_tab.count);
       dbms_output.put_line('count sys   link :'||l_fi_exptypeclass_tab.count);
       dbms_output.put_line('count prj orgz id:'||l_fi_proj_organizationid_tab.count);
       dbms_output.put_line('count prj org  id:'||l_fi_proj_orgid_tab.count);
       dbms_output.put_line('count tran source:'||l_cc_transsource_tab.count);
       dbms_output.put_line('count nl orgz id :'||l_cc_NLOrgzid_tab.count);
       dbms_output.put_line('count prvdr eiid :'||l_cc_prvdreid_tab.count);
       dbms_output.put_line('count recvr eiid :'||l_cc_recvreid_tab.count);
       dbms_output.put_line('count status     :'||lx_cc_status_tab.count);
       dbms_output.put_line('count cc type    :'||lx_cc_type_tab.count);
       dbms_output.put_line('count cc code    :'||lx_cc_code_tab.count);
       dbms_output.put_line('count prvdr orgz :'||lx_cc_prvdr_orgzid_tab.count);
       dbms_output.put_line('count recvr orgz :'||lx_cc_recvr_orgzid_tab.count);
       dbms_output.put_line('count recvr org  :'||lx_cc_recvr_orgid_tab.count);
       dbms_output.put_line('count prvdr org  :'||lx_cc_prvdr_orgid_tab.count);  */

     FOR l_temp IN  1 .. l_fi_date_tab.count LOOP
         IF lx_cc_status_tab(l_temp) IS NOT NULL AND
            lx_cc_status_tab(l_temp) <> 'E' THEN
            l_fi_tp_rejct_reason_tab(l_temp) := lx_cc_status_tab(l_temp);
            lx_tp_error_code(l_temp) := lx_cc_status_tab(l_temp);
            l_fi_process_flag_tab(l_temp) := 'N';
         ELSIF lx_cc_status_tab(l_temp) IS NULL AND
            lx_cc_code_tab(l_temp) NOT IN ( 'B','I') THEN
            lx_tp_error_code(l_temp) := 'E';
         END IF;
            /* dbms_output.put_line('error code  :'||lx_tp_error_code(l_temp));
            dbms_output.put_line('exp orgid   :'||l_fi_exp_orgid_tab(l_temp));
            dbms_output.put_line('papd        :'||l_fi_pvdr_papd_tab(l_temp));  */

         l_tp_pa_date(l_temp) := l_fi_date_tab(l_temp);

         IF lx_tp_error_code(l_temp) IS NULL THEN
            BEGIN
               SELECT End_Date INTO l_tp_pa_date(l_temp)
               FROM Pa_Periods_All WHERE
               PERIOD_NAME = l_fi_pvdr_papd_tab(l_temp) AND
	       -- begin:bug:5938943: NVL function has been removed to achieve the performance gain
	       Org_Id = l_fi_exp_orgid_tab(l_temp);
	       -- end:bug:5938943
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_fi_process_flag_tab(l_temp) := 'N';
               lx_tp_error_code(l_temp) := 'E';
               l_fi_others_rejct_reason_tab(l_temp) := 'PA_FP_PVDR_PA_PD_NOT_FOUND';
            END;
         END IF;

         /* assign TP values */

         l_tp_labor_nl_flag(l_temp) := 'Y';
         l_tp_taskid(l_temp)        := NULL;
         l_tp_rev_distributed_flag(l_temp) := 'Y';
         l_tp_compute_flag(l_temp) := 'Y';
         l_tp_nl_resource(l_temp)  := NULL;
         l_tp_nl_resource_orgzid(l_temp)  := NULL;

         l_tp_asg_precedes_task_tab(l_temp)  := l_asg_precedes_task; -- Added for bug 3260017

         /* set NULL to all tp out variables  */

         lx_proj_tp_rate_type(l_temp) := NULL;
         lx_proj_tp_rate_date(l_temp) := NULL;
         lx_proj_tp_exchange_rate(l_temp) := NULL;
         lx_proj_tp_amt(l_temp) := NULL;

         lx_projfunc_tp_rate_type(l_temp) := NULL;
         lx_projfunc_tp_rate_date(l_temp) := NULL;
         lx_projfunc_tp_exchange_rate(l_temp) := NULL;
         lx_projfunc_tp_amt(l_temp) := NULL;

         lx_denom_tp_currcode(l_temp) := NULL;
         lx_denom_tp_amt(l_temp) := NULL;

         lx_expfunc_tp_rate_type(l_temp) := NULL;
         lx_expfunc_tp_rate_date(l_temp) := NULL;
         lx_expfunc_tp_exchange_rate(l_temp) := NULL;
         lx_expfunc_tp_amt(l_temp) := NULL;

         lx_cc_markup_basecode(l_temp) := NULL;
         lx_tp_ind_compiled_setid(l_temp) := NULL;
         lx_tp_bill_rate(l_temp) := NULL;
         lx_tp_base_amount(l_temp) := NULL;
         lx_tp_bill_markup_percent(l_temp) := NULL;
         lx_tp_sch_line_percent(l_temp) := NULL;
         lx_tp_rule_percent(l_temp) := NULL;
         lx_tp_job_id(l_temp) := NULL;



     END LOOP;

     /* FOR i_dummy in 1 .. lx_tp_error_code.count loop
            dbms_output.put_line('tp error code <'||i_dummy||'>'||
                                  lx_tp_error_code(i_dummy));
             dbms_output.put_line('sys link:exp cate:'|| l_fi_exptypeclass_tab(i_dummy)
                  ||':'||l_tp_exp_category(i_dummy)  );

     END LOOP;   */


                  /*   dbms_output.put_line    ( lx_cc_prvdr_orgid_tab.count );
                    dbms_output.put_line   ( lx_cc_prvdr_orgzid_tab.count );
                    dbms_output.put_line            ( lx_cc_recvr_orgid_tab.count );
                    dbms_output.put_line   ( lx_cc_recvr_orgzid_tab.count );
                    dbms_output.put_line   ( l_fi_exp_organizationid_tab.count );
                    dbms_output.put_line     ( l_tp_exp_itemid.count );
                    dbms_output.put_line        ( l_fi_exptype_tab.count );
                    dbms_output.put_line    ( l_tp_exp_category.count );
                    dbms_output.put_line   ( l_fi_date_tab.count );
                    dbms_output.put_line    ( l_tp_labor_nl_flag.count );
                    dbms_output.put_line ( l_fi_exptypeclass_tab.count );
                    dbms_output.put_line                 ( l_tp_taskid.count );
                    dbms_output.put_line          ( l_tp_scheduleid.count );
                    dbms_output.put_line     ( l_tp_denom_currcode.count );
                    dbms_output.put_line   ( l_prj_curr_code_tab.count );
                    dbms_output.put_line  ( l_prjfunc_curr_code_tab.count );
                    dbms_output.put_line( l_tp_rev_distributed_flag.count );
                    dbms_output.put_line            ( l_tp_compute_flag.count );
                    dbms_output.put_line           ( l_tp_fixed_date.count );
                    dbms_output.put_line   ( l_tp_denom_raw_cost.count );
                    dbms_output.put_line ( l_tp_denom_bd_cost.count );
                    dbms_output.put_line         ( l_tp_raw_revenue.count );
                    dbms_output.put_line            ( l_tp_asg_precedes_task_tab.count ); -- Added for bug 3260017
                    dbms_output.put_line                 ( l_fi_projid_tab.count );
                    dbms_output.put_line                   ( l_fi_qty_tab.count );
                    dbms_output.put_line      ( l_fi_personid_tab.count );
                    dbms_output.put_line                     ( l_asg_fcst_jobid_tab.count );
                    dbms_output.put_line         ( l_tp_nl_resource.count );
                    dbms_output.put_line( l_tp_nl_resource_orgzid.count );
                    dbms_output.put_line                    ( l_tp_pa_date.count );
                    dbms_output.put_line                 ( l_tp_array_size );
                    dbms_output.put_line                 ( l_tp_debug_mode );
                    dbms_output.put_line           ( l_fi_amount_type_tab.count );
                    dbms_output.put_line              ( l_fi_asgid_tab.count );
                    dbms_output.put_line          ( lx_proj_tp_rate_type.count );
                    dbms_output.put_line          ( lx_proj_tp_rate_date.count );
                    dbms_output.put_line      ( lx_proj_tp_exchange_rate.count );
                    dbms_output.put_line        ( lx_proj_tp_amt.count );
                    dbms_output.put_line      ( lx_projfunc_tp_rate_type.count );
                    dbms_output.put_line      ( lx_proj_tp_rate_date.count );
                    dbms_output.put_line  ( lx_proj_tp_exchange_rate.count );
                    dbms_output.put_line    ( lx_proj_tp_amt.count );
                    dbms_output.put_line     ( lx_denom_tp_currcode.count );
                    dbms_output.put_line       ( lx_denom_tp_amt.count );
                    dbms_output.put_line          ( lx_expfunc_tp_rate_type.count );
                    dbms_output.put_line          ( lx_expfunc_tp_rate_date.count );
                    dbms_output.put_line      ( lx_expfunc_tp_exchange_rate.count );
                    dbms_output.put_line        ( lx_expfunc_tp_amt.count );
                    dbms_output.put_line        ( lx_cc_markup_basecode.count );
                    dbms_output.put_line     ( lx_tp_ind_compiled_setid.count );
                    dbms_output.put_line               ( lx_tp_bill_rate.count );
                    dbms_output.put_line             ( lx_tp_base_amount.count );
                    dbms_output.put_line  ( lx_tp_bill_markup_percent.count );
                    dbms_output.put_line( lx_tp_sch_line_percent.count );
                    dbms_output.put_line         ( lx_tp_rule_percent.count );
                    dbms_output.put_line                  ( lx_tp_job_id.count );
                    dbms_output.put_line                 ( lx_tp_error_code.count );   */

         /* call Trf Price API to get Cross Charge Amounts  */

          l_tp_asgid.delete;
          l_call_tp_api_flag := 'N';

          FOR l_tp_asg_idx  IN 1 .. l_fi_asgid_tab.COUNT LOOP
              IF l_fi_asgid_tab(l_tp_asg_idx) <= 0 THEN
                 l_tp_asgid(l_tp_asg_idx) := NULL;
              ELSE
                 l_tp_asgid(l_tp_asg_idx) := l_fi_asgid_tab(l_tp_asg_idx);
              END IF;
              IF lx_tp_error_code(l_tp_asg_idx) IS NULL THEN
                 l_call_tp_api_flag := 'Y';
              END IF;
          END LOOP;

          IF l_call_tp_api_flag = 'Y' THEN
             FORALL b_tmp IN 1 .. l_fi_id_tab.COUNT
             INSERT INTO  Pa_Fi_Amount_Dtls_Tmp(
             FORECAST_ITEM_ID             ,
             ITEM_DATE                    ,
             ITEM_UOM                     ,
             ITEM_QUANTITY                ,
             COST_TXN_CURRENCY_CODE       ,
             REVENUE_TXN_CURRENCY_CODE    ,
             TXN_RAW_COST                 ,
             TXN_BURDENED_COST            ,
             TXN_REVENUE                  ,
             TP_TXN_CURRENCY_CODE_IN      ,
             TP_TXN_CURRENCY_CODE_OUT     ,
             TXN_TRANSFER_PRICE           ,
             PROJECT_CURRENCY_CODE        ,
             PROJECT_COST_RATE_DATE       ,
             PROJECT_COST_RATE_TYPE       ,
             PROJECT_COST_EXCHANGE_RATE   ,
             PROJECT_RAW_COST             ,
             PROJECT_BURDENED_COST        ,
             PROJECT_REVENUE_RATE_DATE    ,
             PROJECT_REVENUE_RATE_TYPE    ,
             PROJECT_REVENUE_EXCHANGE_RATE,
             PROJECT_REVENUE              ,
             PROJECT_TP_RATE_DATE         ,
             PROJECT_TP_RATE_TYPE         ,
             PROJECT_TP_EXCHANGE_RATE     ,
             PROJECT_TRANSFER_PRICE       ,
             PROJFUNC_CURRENCY_CODE       ,
             PROJFUNC_COST_RATE_DATE      ,
             PROJFUNC_COST_RATE_TYPE      ,
             PROJFUNC_COST_EXCHANGE_RATE  ,
             PROJFUNC_RAW_COST            ,
             PROJFUNC_BURDENED_COST       ,
             PROJFUNC_REVENUE_RATE_DATE   ,
             PROJFUNC_REVENUE_RATE_TYPE   ,
             PROJFUNC_REVENUE_EXCHANGE_RATE,
             PROJFUNC_REVENUE             ,
             PROJFUNC_TP_RATE_DATE        ,
             PROJFUNC_TP_RATE_TYPE        ,
             PROJFUNC_TP_EXCHANGE_RATE    ,
             PROJFUNC_TRANSFER_PRICE      ,
             EXPFUNC_CURRENCY_CODE        ,
             EXPFUNC_COST_RATE_DATE       ,
             EXPFUNC_COST_RATE_TYPE       ,
             EXPFUNC_COST_EXCHANGE_RATE   ,
             EXPFUNC_RAW_COST             ,
             EXPFUNC_BURDENED_COST        ,
             EXPFUNC_TP_RATE_DATE         ,
             EXPFUNC_TP_RATE_TYPE         ,
             EXPFUNC_TP_EXCHANGE_RATE     ,
             EXPFUNC_TRANSFER_PRICE       ,
             CC_PRVDR_ORG_ID              ,
             CC_PRVDR_ORGANIZITION_ID     ,
             CC_RECVR_ORG_ID              ,
             CC_RECVR_ORGANIZITION_ID     ,
             EXPENDITURE_ORGANIZATION_ID  ,
             EXPENDITURE_TYPE             ,
             EXPENDITURE_TYPE_CLASS       ,
             EXPENDITURE_CATEGORY         ,
             TP_LABOR_NL_FLAG             ,
             TP_TASK_ID                   ,
             TP_SCHEDULE_ID               ,
             TP_REV_DISTRIBUTED_FLAG      ,
             TP_COMPUTE_FLAG              ,
             TP_FIXED_DATE                ,
             PROJECT_ID                   ,
             PERSON_ID                    ,
             FORECAST_JOB_ID              ,
             TP_NL_RESOURCE               ,
             TP_NL_RESOURCE_ORGZ_ID       ,
             TP_PA_DATE                   ,
             TP_AMOUNT_TYPE               ,
             assignment_id                ,
             fi_process_flag              ,
             delete_flag                  ,
             tp_error_code                ,
             COST_REJECTION_CODE       ,
             REV_REJECTION_CODE        ,
             BURDEN_REJECTION_CODE     ,
             OTHER_REJECTION_CODE      ,
             TP_DENOM_RAW_COST         ,
             TP_DENOM_BURDENED_COST    ,
             TP_RAW_REVENUE            ,
             tp_ind_compiled_setid    ,
             tp_bill_rate                 ,
             tp_base_amount               ,
             tp_bill_markup_percent       ,
             tp_sch_line_percent          ,
             tp_rule_percent              ,
             tp_job_id                    ,
             cc_markup_basecode                  )
            VALUES(
             l_fi_id_tab(b_tmp),
             l_fi_date_tab(b_tmp),
             l_fi_uom_tab(b_tmp),
             l_fi_qty_tab(b_tmp),
             l_fia_cost_txn_curr_code(b_tmp),
             l_fia_rev_txn_curr_code(b_tmp),
             l_fia_txn_raw_cost(b_tmp),
             l_fia_txn_bd_cost(b_tmp),
             l_fia_txn_revenue(b_tmp),
             l_tp_denom_currcode(b_tmp), -- tp txn curr code
             lx_denom_tp_currcode(b_tmp),
             null, -- TXN_TRANSFER_PRICE
             l_prj_curr_code_tab(b_tmp),
             l_fia_proj_cost_rate_date(b_tmp),
             l_fia_proj_cost_rate_type(b_tmp),
             l_fia_proj_cost_ex_rate(b_tmp),
             l_fia_proj_raw_cost(b_tmp),
             l_fia_proj_bd_cost(b_tmp),
             l_fia_proj_rev_rate_date(b_tmp),
             l_fia_proj_rev_rate_type(b_tmp),
             l_fia_proj_rev_ex_rate(b_tmp),
             l_fia_proj_revenue(b_tmp),
             null, -- PROJECT_TP_RATE_DATE
             null, -- PROJECT_TP_RATE_TYPE
             null, -- PROJECT_TP_EXCHANGE_RATE
             null, -- PROJECT_TRANSFER_PRICE
             l_prjfunc_curr_code_tab(b_tmp),
             l_fia_projfunc_cost_rate_date(b_tmp),
             l_fia_projfunc_cost_rate_type(b_tmp),
             l_fia_projfunc_cost_ex_rate(b_tmp),
             l_fia_projfunc_raw_cost(b_tmp),
             l_fia_projfunc_bd_cost(b_tmp),
             l_fia_projfunc_rev_rate_date  (b_tmp),
             l_fia_projfunc_rev_rate_type(b_tmp),
             l_fia_projfunc_rev_ex_rate (b_tmp),
             l_fia_projfunc_revenue(b_tmp),
             null, -- PROJFUNC_TP_RATE_DATE
             null, -- PROJFUNC_TP_RATE_TYPE
             null, -- PROJFUNC_TP_EXCHANGE_RATE
             null, -- PROJFUNC_TRANSFER_PRICE
             l_fia_expfunc_curr_code(b_tmp),
             l_fia_expfunc_cost_rate_date(b_tmp),
             l_fia_expfunc_cost_rate_type(b_tmp),
             l_fia_expfunc_cost_ex_rate(b_tmp),
             l_fia_expfunc_raw_cost(b_tmp),
             l_fia_expfunc_bd_cost(b_tmp),
             null, -- EXPFUNC_TP_RATE_DATE
             null, -- EXPFUNC_TP_RATE_TYPE
             null, -- EXPFUNC_TP_EXCHANGE_RATE
             null, -- EXPFUNC_TRANSFER_PRICE
             lx_cc_prvdr_orgid_tab(b_tmp),
             lx_cc_prvdr_orgzid_tab(b_tmp),
             lx_cc_recvr_orgid_tab(b_tmp),
             lx_cc_recvr_orgzid_tab(b_tmp),
             l_fi_exp_organizationid_tab(b_tmp),
             l_fi_exptype_tab(b_tmp),
             l_fi_exptypeclass_tab(b_tmp),
             l_tp_exp_category(b_tmp),
             l_tp_labor_nl_flag(b_tmp),
             l_tp_taskid(b_tmp),
             l_tp_scheduleid(b_tmp),
             l_tp_rev_distributed_flag(b_tmp),
             l_tp_compute_flag(b_tmp),
             l_tp_fixed_date(b_tmp),
             l_fi_projid_tab(b_tmp),
             l_fi_personid_tab(b_tmp),
             l_asg_fcst_jobid_tab(b_tmp),
             l_tp_nl_resource(b_tmp),
             l_tp_nl_resource_orgzid(b_tmp),
             l_tp_pa_date(b_tmp),
             l_fi_amount_type_tab(b_tmp),
             l_tp_asgid(b_tmp),
             l_fi_process_flag_tab(b_tmp),
             l_fi_delete_flag_tab(b_tmp),
             lx_tp_error_code(b_tmp),
             l_fi_cst_rejct_reason_tab(b_tmp),
             l_fi_rev_rejct_reason_tab(b_tmp),
             l_fi_bd_rejct_reason_tab(b_tmp),
             l_fi_others_rejct_reason_tab(b_tmp),
             l_tp_denom_raw_cost(b_tmp),
             l_tp_denom_bd_cost(b_tmp),
             l_tp_raw_revenue(b_tmp) ,
             lx_tp_ind_compiled_setid(b_tmp),
             lx_tp_bill_rate(b_tmp)         ,
             lx_tp_base_amount(b_tmp)               ,
             lx_tp_bill_markup_percent(b_tmp)       ,
             lx_tp_sch_line_percent(b_tmp)          ,
             lx_tp_rule_percent(b_tmp)              ,
             lx_tp_job_id(b_tmp)    ,
             lx_cc_markup_basecode(b_tmp)              );

             l_fi_id_tab.delete;
             l_fi_date_tab.delete;
             l_fi_uom_tab.delete;
             l_fi_qty_tab.delete;
             l_fia_cost_txn_curr_code.delete;
             l_fia_rev_txn_curr_code.delete;
             l_fia_txn_raw_cost.delete;
             l_fia_txn_bd_cost.delete;
             l_fia_txn_revenue.delete;
             l_tp_denom_currcode.delete; -- tp txn curr code
             lx_denom_tp_currcode.delete; -- tp txn curr code
             lx_denom_tp_amt.delete;     -- TXN_TRANSFER_PRICE
             l_prj_curr_code_tab.delete;
             l_fia_proj_cost_rate_date.delete;
             l_fia_proj_cost_rate_type.delete;
             l_fia_proj_cost_ex_rate.delete;
             l_fia_proj_raw_cost.delete;
             l_fia_proj_bd_cost.delete;
             l_fia_proj_rev_rate_date.delete;
             l_fia_proj_rev_rate_type.delete;
             l_fia_proj_rev_ex_rate.delete;
             l_fia_proj_revenue.delete;
             lx_proj_tp_rate_date.delete; -- PROJECT_TP_RATE_DATE
             lx_proj_tp_rate_type.delete; -- PROJECT_TP_RATE_TYPE
             lx_proj_tp_exchange_rate.delete; -- PROJECT_TP_EXCHANGE_RATE
             lx_proj_tp_amt.delete; -- PROJECT_TRANSFER_PRICE
             l_prjfunc_curr_code_tab.delete;
             l_fia_projfunc_cost_rate_date.delete;
             l_fia_projfunc_cost_rate_type.delete;
             l_fia_projfunc_cost_ex_rate.delete;
             l_fia_projfunc_raw_cost.delete;
             l_fia_projfunc_bd_cost.delete;
             l_fia_projfunc_rev_rate_date  .delete;
             l_fia_projfunc_rev_rate_type.delete;
             l_fia_projfunc_rev_ex_rate .delete;
             l_fia_projfunc_revenue.delete;
             lx_projfunc_tp_rate_date.delete; -- PROJFUNC_TP_RATE_DATE
             lx_projfunc_tp_rate_type.delete; -- PROJFUNC_TP_RATE_TYPE
             lx_projfunc_tp_exchange_rate.delete; -- PROJFUNC_TP_EXCHANGE_RATE
             lx_projfunc_tp_amt.delete; -- PROJFUNC_TRANSFER_PRICE
             l_fia_expfunc_curr_code.delete;
             l_fia_expfunc_cost_rate_date.delete;
             l_fia_expfunc_cost_rate_type.delete;
             l_fia_expfunc_cost_ex_rate.delete;
             l_fia_expfunc_raw_cost.delete;
             l_fia_expfunc_bd_cost.delete;
             lx_expfunc_tp_rate_date.delete; -- EXPFUNC_TP_RATE_DATE
             lx_expfunc_tp_rate_type.delete; -- EXPFUNC_TP_RATE_TYPE
             lx_expfunc_tp_exchange_rate.delete; -- EXPFUNC_TP_EXCHANGE_RATE
             lx_expfunc_tp_amt.delete; -- EXPFUNC_TRANSFER_PRICE
             lx_cc_prvdr_orgid_tab.delete;
             lx_cc_prvdr_orgzid_tab.delete;
             lx_cc_recvr_orgid_tab.delete;
             lx_cc_recvr_orgzid_tab.delete;
             l_fi_exp_organizationid_tab.delete;
             l_fi_exptype_tab.delete;
             l_fi_exptypeclass_tab.delete;
             l_tp_exp_category.delete;
             l_tp_labor_nl_flag.delete;
             l_tp_taskid.delete;
             l_tp_scheduleid.delete;
             l_tp_rev_distributed_flag.delete;
             l_tp_compute_flag.delete;
             l_tp_fixed_date.delete;
             l_tp_asg_precedes_task_tab.delete; -- Added for bug 3260017
             l_fi_projid_tab.delete;
             l_fi_personid_tab.delete;
             l_asg_fcst_jobid_tab.delete;
             l_tp_nl_resource.delete;
             l_tp_nl_resource_orgzid.delete;
             l_tp_pa_date.delete;
             l_fi_amount_type_tab.delete;
             l_tp_asgid.delete;
             l_fi_process_flag_tab.delete;
             l_fi_delete_flag_tab.delete;
             lx_tp_error_code.delete;

             lx_tp_ind_compiled_setid.delete;
             lx_tp_bill_rate.delete;
             lx_tp_base_amount.delete;
             lx_tp_bill_markup_percent.delete;
             lx_tp_sch_line_percent.delete;
             lx_tp_rule_percent.delete;
             lx_tp_job_id.delete;
             lx_cc_markup_basecode.delete;

             l_tp_denom_raw_cost.delete;
             l_tp_denom_bd_cost.delete;
             l_tp_raw_revenue.delete;

             l_fi_cst_rejct_reason_tab.delete;
             l_fi_rev_rejct_reason_tab.delete;
             l_fi_bd_rejct_reason_tab.delete;
             l_fi_others_rejct_reason_tab.delete;


             /* dbms_output.put_line('tp api call flag:'||l_call_tp_api_flag); */

             SELECT
             FORECAST_ITEM_ID             ,
             ITEM_DATE                    ,
             ITEM_UOM                     ,
             ITEM_QUANTITY                ,
             COST_TXN_CURRENCY_CODE       ,
             REVENUE_TXN_CURRENCY_CODE    ,
             TXN_RAW_COST                 ,
             TXN_BURDENED_COST            ,
             TXN_REVENUE                  ,
             TP_TXN_CURRENCY_CODE_IN      ,
             TP_TXN_CURRENCY_CODE_OUT     ,
             TXN_TRANSFER_PRICE           ,
             PROJECT_CURRENCY_CODE        ,
             PROJECT_COST_RATE_DATE       ,
             PROJECT_COST_RATE_TYPE       ,
             PROJECT_COST_EXCHANGE_RATE   ,
             PROJECT_RAW_COST             ,
             PROJECT_BURDENED_COST        ,
             PROJECT_REVENUE_RATE_DATE    ,
             PROJECT_REVENUE_RATE_TYPE    ,
             PROJECT_REVENUE_EXCHANGE_RATE,
             PROJECT_REVENUE              ,
             PROJECT_TP_RATE_DATE         ,
             PROJECT_TP_RATE_TYPE         ,
             PROJECT_TP_EXCHANGE_RATE     ,
             PROJECT_TRANSFER_PRICE       ,
             PROJFUNC_CURRENCY_CODE       ,
             PROJFUNC_COST_RATE_DATE      ,
             PROJFUNC_COST_RATE_TYPE      ,
             PROJFUNC_COST_EXCHANGE_RATE  ,
             PROJFUNC_RAW_COST            ,
             PROJFUNC_BURDENED_COST       ,
             PROJFUNC_REVENUE_RATE_DATE   ,
             PROJFUNC_REVENUE_RATE_TYPE   ,
             PROJFUNC_REVENUE_EXCHANGE_RATE,
             PROJFUNC_REVENUE             ,
             PROJFUNC_TP_RATE_DATE        ,
             PROJFUNC_TP_RATE_TYPE        ,
             PROJFUNC_TP_EXCHANGE_RATE    ,
             PROJFUNC_TRANSFER_PRICE      ,
             EXPFUNC_CURRENCY_CODE        ,
             EXPFUNC_COST_RATE_DATE       ,
             EXPFUNC_COST_RATE_TYPE       ,
             EXPFUNC_COST_EXCHANGE_RATE   ,
             EXPFUNC_RAW_COST             ,
             EXPFUNC_BURDENED_COST        ,
             EXPFUNC_TP_RATE_DATE         ,
             EXPFUNC_TP_RATE_TYPE         ,
             EXPFUNC_TP_EXCHANGE_RATE     ,
             EXPFUNC_TRANSFER_PRICE       ,
             CC_PRVDR_ORG_ID              ,
             CC_PRVDR_ORGANIZITION_ID     ,
             CC_RECVR_ORG_ID              ,
             CC_RECVR_ORGANIZITION_ID     ,
             EXPENDITURE_ORGANIZATION_ID  ,
             EXPENDITURE_TYPE             ,
             EXPENDITURE_TYPE_CLASS       ,
             EXPENDITURE_CATEGORY         ,
             TP_LABOR_NL_FLAG             ,
             TP_TASK_ID                   ,
             TP_SCHEDULE_ID               ,
             TP_REV_DISTRIBUTED_FLAG      ,
             TP_COMPUTE_FLAG              ,
             TP_FIXED_DATE                ,
             PROJECT_ID                   ,
             PERSON_ID                    ,
             FORECAST_JOB_ID              ,
             TP_NL_RESOURCE               ,
             TP_NL_RESOURCE_ORGZ_ID       ,
             TP_PA_DATE                   ,
             TP_AMOUNT_TYPE               ,
             assignment_id                ,
             fi_process_flag              ,
             delete_flag                  ,
             tp_error_code                ,
             COST_REJECTION_CODE       ,
             REV_REJECTION_CODE        ,
             BURDEN_REJECTION_CODE     ,
             OTHER_REJECTION_CODE      ,
             TP_DENOM_RAW_COST         ,
             TP_DENOM_BURDENED_COST    ,
             TP_RAW_REVENUE            ,
             tp_ind_compiled_setid    ,
             tp_bill_rate                 ,
             tp_base_amount               ,
             tp_bill_markup_percent       ,
             tp_sch_line_percent          ,
             tp_rule_percent              ,
             tp_job_id                    ,
             cc_markup_basecode      BULK COLLECT INTO
             l_fi_id_tab,
             l_fi_date_tab,
             l_fi_uom_tab,
             l_fi_qty_tab,
             l_fia_cost_txn_curr_code,
             l_fia_rev_txn_curr_code,
             l_fia_txn_raw_cost,
             l_fia_txn_bd_cost,
             l_fia_txn_revenue,
             l_tp_denom_currcode, -- tp txn curr code
             lx_denom_tp_currcode,
             lx_denom_tp_amt,
             l_prj_curr_code_tab,
             l_fia_proj_cost_rate_date,
             l_fia_proj_cost_rate_type,
             l_fia_proj_cost_ex_rate,
             l_fia_proj_raw_cost,
             l_fia_proj_bd_cost,
             l_fia_proj_rev_rate_date,
             l_fia_proj_rev_rate_type,
             l_fia_proj_rev_ex_rate,
             l_fia_proj_revenue,
             lx_proj_tp_rate_date,
             lx_proj_tp_rate_type,
             lx_proj_tp_exchange_rate,
             lx_proj_tp_amt,
             l_prjfunc_curr_code_tab,
             l_fia_projfunc_cost_rate_date,
             l_fia_projfunc_cost_rate_type,
             l_fia_projfunc_cost_ex_rate,
             l_fia_projfunc_raw_cost,
             l_fia_projfunc_bd_cost,
             l_fia_projfunc_rev_rate_date  ,
             l_fia_projfunc_rev_rate_type,
             l_fia_projfunc_rev_ex_rate ,
             l_fia_projfunc_revenue,
             lx_projfunc_tp_rate_date,
             lx_projfunc_tp_rate_type,
             lx_projfunc_tp_exchange_rate,
             lx_projfunc_tp_amt,
             l_fia_expfunc_curr_code,
             l_fia_expfunc_cost_rate_date,
             l_fia_expfunc_cost_rate_type,
             l_fia_expfunc_cost_ex_rate,
             l_fia_expfunc_raw_cost,
             l_fia_expfunc_bd_cost,
             lx_expfunc_tp_rate_date,
             lx_expfunc_tp_rate_type,
             lx_expfunc_tp_exchange_rate,
             lx_expfunc_tp_amt,
             lx_cc_prvdr_orgid_tab,
             lx_cc_prvdr_orgzid_tab,
             lx_cc_recvr_orgid_tab,
             lx_cc_recvr_orgzid_tab,
             l_fi_exp_organizationid_tab,
             l_fi_exptype_tab,
             l_fi_exptypeclass_tab,
             l_tp_exp_category,
             l_tp_labor_nl_flag,
             l_tp_taskid,
             l_tp_scheduleid,
             l_tp_rev_distributed_flag,
             l_tp_compute_flag,
             l_tp_fixed_date,
             l_fi_projid_tab,
             l_fi_personid_tab,
             l_asg_fcst_jobid_tab,
             l_tp_nl_resource,
             l_tp_nl_resource_orgzid,
             l_tp_pa_date,
             l_fi_amount_type_tab,
             l_tp_asgid,
             l_fi_process_flag_tab,
             l_fi_delete_flag_tab,
             lx_tp_error_code,
             l_fi_cst_rejct_reason_tab,
             l_fi_rev_rejct_reason_tab,
             l_fi_bd_rejct_reason_tab,
             l_fi_others_rejct_reason_tab,
             l_tp_denom_raw_cost,
             l_tp_denom_bd_cost,
             l_tp_raw_revenue   ,
             lx_tp_ind_compiled_setid,
             lx_tp_bill_rate,
             lx_tp_base_amount,
             lx_tp_bill_markup_percent,
             lx_tp_sch_line_percent,
             lx_tp_rule_percent,
             lx_tp_job_id,
             lx_cc_markup_basecode FROM Pa_Fi_Amount_Dtls_Tmp WHERE
                              Tp_Error_Code IS NULL;

             l_tp_array_size :=  l_fi_date_tab.count;


            -- Added this for loop for bug 3260017
           IF (l_tp_array_size > 0 ) THEN
             l_tp_asg_precedes_task_tab.delete;

             FOR i IN l_fi_date_tab.first..l_fi_date_tab.last LOOP
                 l_tp_asg_precedes_task_tab(i) := l_asg_precedes_task;
             END LOOP;
           END IF;

              /* FOR trf_temp IN l_fi_id_tab.first .. l_fi_id_tab.last loop
                dbms_output.put_line('before index : proc flag  : tp err:'||trf_temp||
                                  '  '||l_fi_process_flag_tab(trf_temp) ||
                                  '  '||lx_tp_error_code(trf_temp));
                dbms_output.put_line('fi amt type   :'||l_fi_amount_type_tab(trf_temp));
                dbms_output.put_line('after index : proc flag  : tp err:'||trf_temp||
                                  '  '||l_fi_process_flag_tab(trf_temp) ||
                                  '  '||lx_tp_error_code(trf_temp));
                dbms_output.put_line('cc pvdr orgid :'||lx_cc_prvdr_orgid_tab(trf_temp));
                dbms_output.put_line('cc pvdr orgzd :'||lx_cc_prvdr_orgzid_tab(trf_temp));
                dbms_output.put_line('cc rcvr orgid :'||lx_cc_recvr_orgid_tab(trf_temp));
                dbms_output.put_line('cc rcvr orgzd :'||lx_cc_recvr_orgzid_tab(trf_temp));
                dbms_output.put_line('fi exp orgz d :'||l_fi_exp_organizationid_tab(trf_temp));
                dbms_output.put_line('exp item id   :'||l_fi_id_tab(trf_temp));
                dbms_output.put_line('exp type tab  :'||l_fi_exptype_tab(trf_temp));
                dbms_output.put_line('index : tp error :'||trf_temp
                                     || '  :'||lx_tp_error_code(trf_temp));
                dbms_output.put_line('exp category  :'||l_tp_exp_category(trf_temp));
                dbms_output.put_line('fi date tab   :'||l_fi_date_tab(trf_temp));
                dbms_output.put_line('tp labor fg   :'||l_tp_labor_nl_flag(trf_temp));
                dbms_output.put_line('exp type cls  :'||l_fi_exptypeclass_tab(trf_temp));
                dbms_output.put_line('task id       :'||l_tp_taskid(trf_temp));
                dbms_output.put_line('tp sch id     :'||l_tp_scheduleid(trf_temp));
                dbms_output.put_line('tp denom curr :'||l_tp_denom_currcode(trf_temp));
                dbms_output.put_line('l prj curr    :'||l_prj_curr_code_tab(trf_temp));
                dbms_output.put_line('l pf  curr    :'||l_prjfunc_curr_code_tab(trf_temp));
                dbms_output.put_line('rev disti fg  :'||l_tp_rev_distributed_flag(trf_temp));
                dbms_output.put_line('tp comp   fg  :'||l_tp_compute_flag(trf_temp));
                dbms_output.put_line('tp fixed dt   :'||l_tp_fixed_date(trf_temp));
                dbms_output.put_line('tp raw cost   :'||l_tp_denom_raw_cost(trf_temp));
                dbms_output.put_line('bd cost       :'||l_tp_denom_bd_cost(trf_temp));
                dbms_output.put_line('raw revenue   :'||l_tp_raw_revenue(trf_temp));
                dbms_output.put_line('asgn precedes task   :'||l_tp_asg_precedes_task_tab(trf_temp)); -- Added for bug 3260017
                dbms_output.put_line('projid        :'||l_fi_projid_tab(trf_temp));
                dbms_output.put_line('fi qty        :'||l_fi_qty_tab(trf_temp));
                dbms_output.put_line('fi person id  :'||l_fi_personid_tab(trf_temp));
                dbms_output.put_line('fcst job id   :'||l_asg_fcst_jobid_tab(trf_temp));
                dbms_output.put_line('nl res        :'||l_tp_nl_resource(trf_temp));
                dbms_output.put_line('nl orgz id    :'||l_tp_nl_resource_orgzid(trf_temp));
                dbms_output.put_line('tp pa date    :'||l_tp_pa_date(trf_temp));
                dbms_output.put_line('fi amt type   :'||l_fi_amount_type_tab(trf_temp));
                dbms_output.put_line('fi asgid      :'||l_tp_asgid(trf_temp));
             END LOOP;
             dbms_output.put_line('tp asgid      :'||l_tp_asgid.count);
             dbms_output.put_line('tp array siz  :'||l_tp_array_size);
             dbms_output.put_line('tp debug mode :'||l_tp_debug_mode);
             dbms_output.put_line('cc pvdr orgid :'||lx_cc_prvdr_orgid_tab.count);
             dbms_output.put_line('cc pvdr orgzd :'||lx_cc_prvdr_orgzid_tab.count);
             dbms_output.put_line('cc rcvr orgid :'||lx_cc_recvr_orgid_tab.count);
             dbms_output.put_line('cc rcvr orgzd :'||lx_cc_recvr_orgzid_tab.count);
             dbms_output.put_line('fi exp orgz d :'||l_fi_exp_organizationid_tab.count);
             dbms_output.put_line('exp item id   :'||l_fi_id_tab.count);
             dbms_output.put_line('exp type tab  :'||l_fi_exptype_tab.count);
             dbms_output.put_line('exp category  :'||l_tp_exp_category.count);
             dbms_output.put_line('fi date tab   :'||l_fi_date_tab.count);
             dbms_output.put_line('tp labor fg   :'||l_tp_labor_nl_flag.count);
             dbms_output.put_line('exp type cls  :'||l_fi_exptypeclass_tab.count);
             dbms_output.put_line('task id       :'||l_tp_taskid.count);
             dbms_output.put_line('tp sch id     :'||l_tp_scheduleid.count);
             dbms_output.put_line('tp denom curr :'||l_tp_denom_currcode.count);
             dbms_output.put_line('l prj curr    :'||l_prj_curr_code_tab.count);
             dbms_output.put_line('l pf  curr    :'||l_prjfunc_curr_code_tab.count);
             dbms_output.put_line('rev disti fg  :'||l_tp_rev_distributed_flag.count);
             dbms_output.put_line('tp comp   fg  :'||l_tp_compute_flag.count);
             dbms_output.put_line('tp fixed dt   :'||l_tp_fixed_date.count);
             dbms_output.put_line('tp raw cost   :'||l_tp_denom_raw_cost.count);
             dbms_output.put_line('bd cost       :'||l_tp_denom_bd_cost.count);
             dbms_output.put_line('raw revenue   :'||l_tp_raw_revenue.count);
             dbms_output.put_line('asgn precedes task   :'||l_tp_asg_precedes_task_tab.count); -- Added for bug 3260017
             dbms_output.put_line('projid        :'||l_fi_projid_tab.count);
             dbms_output.put_line('fi qty        :'||l_fi_qty_tab.count);
             dbms_output.put_line('fi person id  :'||l_fi_personid_tab.count);
             dbms_output.put_line('fcst job id   :'||l_asg_fcst_jobid_tab.count);
             dbms_output.put_line('nl res        :'||l_tp_nl_resource.count);
             dbms_output.put_line('nl orgz id    :'||l_tp_nl_resource_orgzid.count);
             dbms_output.put_line('tp pa date    :'||l_tp_pa_date.count);
             dbms_output.put_line('tp array siz  :'||l_tp_array_size);
             dbms_output.put_line('tp debug mode :'||l_tp_debug_mode);
             dbms_output.put_line('fi amt type   :'||l_fi_amount_type_tab.count);
             dbms_output.put_line('tp asgid      :'||l_tp_asgid.count);
             dbms_output.put_line('prj tp rt ty :'||lx_proj_tp_rate_type.count);
             dbms_output.put_line('prj tp rt dt :'||lx_proj_tp_rate_date.count);
             dbms_output.put_line('prj tp ex    :'||lx_proj_tp_exchange_rate.count);
             dbms_output.put_line('prj tp amt   :'||lx_proj_tp_amt.count);
             dbms_output.put_line('pf tp rt ty  :'||lx_projfunc_tp_rate_type.count);
             dbms_output.put_line('pf tp rt dt  :'||lx_projfunc_tp_rate_date.count);
             dbms_output.put_line('pf tp ex     :'||lx_projfunc_tp_exchange_rate.count);
             dbms_output.put_line('pf tp amt    :'||lx_projfunc_tp_amt.count);
             dbms_output.put_line('denom tp curr:'||lx_denom_tp_currcode.count);
             dbms_output.put_line('denom tp amt :'||lx_denom_tp_amt.count);
             dbms_output.put_line('ef tp rt ty  :'||lx_expfunc_tp_rate_type.count);
             dbms_output.put_line('ef tp rt dt  :'||lx_expfunc_tp_rate_date.count);
             dbms_output.put_line('ef tp ex     :'||lx_expfunc_tp_exchange_rate.count);
             dbms_output.put_line('ef tp amt    :'||lx_expfunc_tp_amt.count);
             dbms_output.put_line('cc mark      :'||lx_cc_markup_basecode.count);
             dbms_output.put_line('ind compiled :'||lx_tp_ind_compiled_setid.count);
             dbms_output.put_line('tp bill rate :'||lx_tp_bill_rate.count);
             dbms_output.put_line('tp base amt  :'||lx_tp_base_amount.count);
             dbms_output.put_line('tp bill mark :'||lx_tp_bill_markup_percent.count);
             dbms_output.put_line('tp sch perc  :'||lx_tp_sch_line_percent.count);
             dbms_output.put_line('tp rule perc :'||lx_tp_rule_percent.count);
             dbms_output.put_line('tp job id    :'||lx_tp_job_id.count);

             dbms_output.put_line('bef calling trf price');  */

             IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Bef calling Trf Price API';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
             END IF;

             Pa_Cc_Transfer_Price.Get_Transfer_Price(
              p_module_name             => 'FORECAST',
              p_prvdr_operating_unit    => lx_cc_prvdr_orgid_tab,
              p_prvdr_organization_id   => lx_cc_prvdr_orgzid_tab,
              p_recvr_org_id            => lx_cc_recvr_orgid_tab,
              p_recvr_organization_id   => lx_cc_recvr_orgzid_tab,
              p_expnd_organization_id   => l_fi_exp_organizationid_tab,
              p_expenditure_item_id     => l_fi_id_tab,
              p_expenditure_type        => l_fi_exptype_tab,
              p_expenditure_category    => l_tp_exp_category,
              p_expenditure_item_date   => l_fi_date_tab,
              p_labor_non_labor_flag    => l_tp_labor_nl_flag,
              p_system_linkage_function => l_fi_exptypeclass_tab,
              p_task_id                 => l_tp_taskid,
              p_tp_schedule_id          => l_tp_scheduleid,
              p_denom_currency_code     => l_tp_denom_currcode,
              p_project_currency_code   => l_prj_curr_code_tab,
              p_projfunc_currency_code  => l_prjfunc_curr_code_tab,
              p_revenue_distributed_flag=> l_tp_rev_distributed_flag,
              p_processed_thru_date     => sysdate,
              p_compute_flag            => l_tp_compute_flag,
              p_tp_fixed_date           => l_tp_fixed_date,
              p_denom_raw_cost_amount   => l_tp_denom_raw_cost,
              p_denom_burdened_cost_amount => l_tp_denom_bd_cost,
              p_raw_revenue_amount         => l_tp_raw_revenue,
              p_assignment_precedes_task   => l_tp_asg_precedes_task_tab, -- Added for bug 3260017
              p_project_id                 => l_fi_projid_tab,
              p_quantity                   => l_fi_qty_tab,
              p_incurred_by_person_id      => l_fi_personid_tab,
              p_job_id                     => l_asg_fcst_jobid_tab,
              p_non_labor_resource         => l_tp_nl_resource,
              p_nl_resource_organization_id=> l_tp_nl_resource_orgzid,
              p_pa_date                    => l_tp_pa_date,
              p_array_size                 => l_tp_array_size,
              p_debug_mode                 => l_tp_debug_mode,
              p_tp_amt_type_code           => l_fi_amount_type_tab,
              p_assignment_id              => l_tp_asgid,
              x_proj_tp_rate_type          => lx_proj_tp_rate_type,
              x_proj_tp_rate_date          => lx_proj_tp_rate_date,
              x_proj_tp_exchange_rate      => lx_proj_tp_exchange_rate,
              x_proj_transfer_price        => lx_proj_tp_amt,
              x_projfunc_tp_rate_type      => lx_projfunc_tp_rate_type,
              x_projfunc_tp_rate_date      => lx_projfunc_tp_rate_date,
              x_projfunc_tp_exchange_rate  => lx_projfunc_tp_exchange_rate,
              x_projfunc_transfer_price    => lx_projfunc_tp_amt,
              x_denom_tp_currency_code     => lx_denom_tp_currcode,
              x_denom_transfer_price       => lx_denom_tp_amt,
              x_acct_tp_rate_type          => lx_expfunc_tp_rate_type,
              x_acct_tp_rate_date          => lx_expfunc_tp_rate_date,
              x_acct_tp_exchange_rate      => lx_expfunc_tp_exchange_rate,
              x_acct_transfer_price        => lx_expfunc_tp_amt,
              x_cc_markup_base_code        => lx_cc_markup_basecode,
              x_tp_ind_compiled_set_id     => lx_tp_ind_compiled_setid,
              x_tp_bill_rate               => lx_tp_bill_rate,
              x_tp_base_amount             => lx_tp_base_amount,
              x_tp_bill_markup_percentage  => lx_tp_bill_markup_percent,
              x_tp_schedule_line_percentage=> lx_tp_sch_line_percent,
              x_tp_rule_percentage         => lx_tp_rule_percent,
              x_tp_job_id                  => lx_tp_job_id,
              x_error_code                 => lx_tp_error_code,
              x_return_status              => lx_tp_return_status  );

             IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Aft calling Trf Price API';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
             END IF;
             /* dbms_output.put_line('aft calling trf price');  */

             FORALL l_trf_upd IN 1 .. l_fi_date_tab.COUNT
             UPDATE Pa_Fi_Amount_Dtls_Tmp SET
             TP_TXN_CURRENCY_CODE_out      = lx_denom_tp_currcode(l_trf_upd),
             TXN_TRANSFER_PRICE            = lx_denom_tp_amt(l_trf_upd),
             PROJECT_TP_RATE_DATE          = lx_proj_tp_rate_date(l_trf_upd),
             PROJECT_TP_RATE_TYPE          = lx_proj_tp_rate_type(l_trf_upd),
             PROJECT_TP_EXCHANGE_RATE      = lx_proj_tp_exchange_rate(l_trf_upd),
             PROJECT_TRANSFER_PRICE        = lx_proj_tp_amt(l_trf_upd),
             PROJFUNC_TP_RATE_DATE         = lx_projfunc_tp_rate_date(l_trf_upd),
             PROJFUNC_TP_RATE_TYPE         = lx_projfunc_tp_rate_type(l_trf_upd),
             PROJFUNC_TP_EXCHANGE_RATE     = lx_projfunc_tp_exchange_rate(l_trf_upd),
             PROJFUNC_TRANSFER_PRICE       = lx_projfunc_tp_amt(l_trf_upd),
             EXPFUNC_TP_RATE_DATE          = lx_expfunc_tp_rate_date(l_trf_upd),
             EXPFUNC_TP_RATE_TYPE          = lx_expfunc_tp_rate_type(l_trf_upd),
             EXPFUNC_TP_EXCHANGE_RATE      = lx_expfunc_tp_exchange_rate(l_trf_upd),
             EXPFUNC_TRANSFER_PRICE        = lx_expfunc_tp_amt(l_trf_upd),
             TP_ERROR_CODE                 = lx_tp_error_code(l_trf_upd)
             WHERE  Forecast_Item_Id = l_fi_id_tab(l_trf_upd);

             /* dbms_output.put_line('no of rows upd '||sql%rowcount);   */

             l_fi_id_tab.delete;
             l_fi_date_tab.delete;
             l_fi_uom_tab.delete;
             l_fi_qty_tab.delete;
             l_fia_cost_txn_curr_code.delete;
             l_fia_rev_txn_curr_code.delete;
             l_fia_txn_raw_cost.delete;
             l_fia_txn_bd_cost.delete;
             l_fia_txn_revenue.delete;
             l_tp_denom_currcode.delete; -- tp txn curr code
             lx_denom_tp_currcode.delete; -- tp txn curr code
             lx_denom_tp_amt.delete;     -- TXN_TRANSFER_PRICE
             l_prj_curr_code_tab.delete;
             l_fia_proj_cost_rate_date.delete;
             l_fia_proj_cost_rate_type.delete;
             l_fia_proj_cost_ex_rate.delete;
             l_fia_proj_raw_cost.delete;
             l_fia_proj_bd_cost.delete;
             l_fia_proj_rev_rate_date.delete;
             l_fia_proj_rev_rate_type.delete;
             l_fia_proj_rev_ex_rate.delete;
             l_fia_proj_revenue.delete;
             lx_proj_tp_rate_date.delete; -- PROJECT_TP_RATE_DATE
             lx_proj_tp_rate_type.delete; -- PROJECT_TP_RATE_TYPE
             lx_proj_tp_exchange_rate.delete; -- PROJECT_TP_EXCHANGE_RATE
             lx_proj_tp_amt.delete; -- PROJECT_TRANSFER_PRICE
             l_prjfunc_curr_code_tab.delete;
             l_fia_projfunc_cost_rate_date.delete;
             l_fia_projfunc_cost_rate_type.delete;
             l_fia_projfunc_cost_ex_rate.delete;
             l_fia_projfunc_raw_cost.delete;
             l_fia_projfunc_bd_cost.delete;
             l_fia_projfunc_rev_rate_date  .delete;
             l_fia_projfunc_rev_rate_type.delete;
             l_fia_projfunc_rev_ex_rate .delete;
             l_fia_projfunc_revenue.delete;
             lx_projfunc_tp_rate_date.delete; -- PROJFUNC_TP_RATE_DATE
             lx_projfunc_tp_rate_type.delete; -- PROJFUNC_TP_RATE_TYPE
             lx_projfunc_tp_exchange_rate.delete; -- PROJFUNC_TP_EXCHANGE_RATE
             lx_projfunc_tp_amt.delete; -- PROJFUNC_TRANSFER_PRICE
             l_fia_expfunc_curr_code.delete;
             l_fia_expfunc_cost_rate_date.delete;
             l_fia_expfunc_cost_rate_type.delete;
             l_fia_expfunc_cost_ex_rate.delete;
             l_fia_expfunc_raw_cost.delete;
             l_fia_expfunc_bd_cost.delete;
             lx_expfunc_tp_rate_date.delete; -- EXPFUNC_TP_RATE_DATE
             lx_expfunc_tp_rate_type.delete; -- EXPFUNC_TP_RATE_TYPE
             lx_expfunc_tp_exchange_rate.delete; -- EXPFUNC_TP_EXCHANGE_RATE
             lx_expfunc_tp_amt.delete; -- EXPFUNC_TRANSFER_PRICE
             lx_cc_prvdr_orgid_tab.delete;
             lx_cc_prvdr_orgzid_tab.delete;
             lx_cc_recvr_orgid_tab.delete;
             lx_cc_recvr_orgzid_tab.delete;
             l_fi_exp_organizationid_tab.delete;
             l_fi_exptype_tab.delete;
             l_fi_exptypeclass_tab.delete;
             l_tp_exp_category.delete;
             l_tp_labor_nl_flag.delete;
             l_tp_taskid.delete;
             l_tp_scheduleid.delete;
             l_tp_rev_distributed_flag.delete;
             l_tp_compute_flag.delete;
             l_tp_fixed_date.delete;
             l_fi_projid_tab.delete;
             l_fi_personid_tab.delete;
             l_asg_fcst_jobid_tab.delete;
             l_tp_nl_resource.delete;
             l_tp_nl_resource_orgzid.delete;
             l_tp_pa_date.delete;
             l_fi_amount_type_tab.delete;
             l_tp_asgid.delete;
             l_fi_process_flag_tab.delete;
             l_fi_delete_flag_tab.delete;
             lx_tp_error_code.delete;

             lx_tp_ind_compiled_setid.delete;
             lx_tp_bill_rate.delete;
             lx_tp_base_amount.delete;
             lx_tp_bill_markup_percent.delete;
             lx_tp_sch_line_percent.delete;
             lx_tp_rule_percent.delete;
             lx_tp_job_id.delete;
             lx_cc_markup_basecode.delete;

             l_tp_denom_raw_cost.delete;
             l_tp_denom_bd_cost.delete;
             l_tp_raw_revenue.delete;

             l_fi_cst_rejct_reason_tab.delete;
             l_fi_rev_rejct_reason_tab.delete;
             l_fi_bd_rejct_reason_tab.delete;
             l_fi_others_rejct_reason_tab.delete;



             SELECT
             FORECAST_ITEM_ID             ,
             ITEM_DATE                    ,
             ITEM_UOM                     ,
             ITEM_QUANTITY                ,
             COST_TXN_CURRENCY_CODE       ,
             REVENUE_TXN_CURRENCY_CODE    ,
             TXN_RAW_COST                 ,
             TXN_BURDENED_COST            ,
             TXN_REVENUE                  ,
             TP_TXN_CURRENCY_CODE_IN      ,
             TP_TXN_CURRENCY_CODE_OUT     ,
             TXN_TRANSFER_PRICE           ,
             PROJECT_CURRENCY_CODE        ,
             PROJECT_COST_RATE_DATE       ,
             PROJECT_COST_RATE_TYPE       ,
             PROJECT_COST_EXCHANGE_RATE   ,
             PROJECT_RAW_COST             ,
             PROJECT_BURDENED_COST        ,
             PROJECT_REVENUE_RATE_DATE    ,
             PROJECT_REVENUE_RATE_TYPE    ,
             PROJECT_REVENUE_EXCHANGE_RATE,
             PROJECT_REVENUE              ,
             PROJECT_TP_RATE_DATE         ,
             PROJECT_TP_RATE_TYPE         ,
             PROJECT_TP_EXCHANGE_RATE     ,
             PROJECT_TRANSFER_PRICE       ,
             PROJFUNC_CURRENCY_CODE       ,
             PROJFUNC_COST_RATE_DATE      ,
             PROJFUNC_COST_RATE_TYPE      ,
             PROJFUNC_COST_EXCHANGE_RATE  ,
             PROJFUNC_RAW_COST            ,
             PROJFUNC_BURDENED_COST       ,
             PROJFUNC_REVENUE_RATE_DATE   ,
             PROJFUNC_REVENUE_RATE_TYPE   ,
             PROJFUNC_REVENUE_EXCHANGE_RATE,
             PROJFUNC_REVENUE             ,
             PROJFUNC_TP_RATE_DATE        ,
             PROJFUNC_TP_RATE_TYPE        ,
             PROJFUNC_TP_EXCHANGE_RATE    ,
             PROJFUNC_TRANSFER_PRICE      ,
             EXPFUNC_CURRENCY_CODE        ,
             EXPFUNC_COST_RATE_DATE       ,
             EXPFUNC_COST_RATE_TYPE       ,
             EXPFUNC_COST_EXCHANGE_RATE   ,
             EXPFUNC_RAW_COST             ,
             EXPFUNC_BURDENED_COST        ,
             EXPFUNC_TP_RATE_DATE         ,
             EXPFUNC_TP_RATE_TYPE         ,
             EXPFUNC_TP_EXCHANGE_RATE     ,
             EXPFUNC_TRANSFER_PRICE       ,
             CC_PRVDR_ORG_ID              ,
             CC_PRVDR_ORGANIZITION_ID     ,
             CC_RECVR_ORG_ID              ,
             CC_RECVR_ORGANIZITION_ID     ,
             EXPENDITURE_ORGANIZATION_ID  ,
             EXPENDITURE_TYPE             ,
             EXPENDITURE_TYPE_CLASS       ,
             EXPENDITURE_CATEGORY         ,
             TP_LABOR_NL_FLAG             ,
             TP_TASK_ID                   ,
             TP_SCHEDULE_ID               ,
             TP_REV_DISTRIBUTED_FLAG      ,
             TP_COMPUTE_FLAG              ,
             TP_FIXED_DATE                ,
             PROJECT_ID                   ,
             PERSON_ID                    ,
             FORECAST_JOB_ID              ,
             TP_NL_RESOURCE               ,
             TP_NL_RESOURCE_ORGZ_ID       ,
             TP_PA_DATE                   ,
             TP_AMOUNT_TYPE               ,
             assignment_id                ,
             fi_process_flag              ,
             delete_flag                  ,
             tp_error_code                ,
             COST_REJECTION_CODE          ,
             REV_REJECTION_CODE           ,
             BURDEN_REJECTION_CODE        ,
             OTHER_REJECTION_CODE         ,
             TP_DENOM_RAW_COST            ,
             TP_DENOM_BURDENED_COST       ,
             TP_RAW_REVENUE               ,
             tp_ind_compiled_setid        ,
             tp_bill_rate                 ,
             tp_base_amount               ,
             tp_bill_markup_percent       ,
             tp_sch_line_percent          ,
             tp_rule_percent              ,
             tp_job_id                    ,
             cc_markup_basecode                 BULK COLLECT INTO
             l_fi_id_tab,
             l_fi_date_tab,
             l_fi_uom_tab,
             l_fi_qty_tab,
             l_fia_cost_txn_curr_code,
             l_fia_rev_txn_curr_code,
             l_fia_txn_raw_cost,
             l_fia_txn_bd_cost,
             l_fia_txn_revenue,
             l_tp_denom_currcode, -- tp txn curr code
             lx_denom_tp_currcode,
             lx_denom_tp_amt,
             l_prj_curr_code_tab,
             l_fia_proj_cost_rate_date,
             l_fia_proj_cost_rate_type,
             l_fia_proj_cost_ex_rate,
             l_fia_proj_raw_cost,
             l_fia_proj_bd_cost,
             l_fia_proj_rev_rate_date,
             l_fia_proj_rev_rate_type,
             l_fia_proj_rev_ex_rate,
             l_fia_proj_revenue,
             lx_proj_tp_rate_date,
             lx_proj_tp_rate_type,
             lx_proj_tp_exchange_rate,
             lx_proj_tp_amt,
             l_prjfunc_curr_code_tab,
             l_fia_projfunc_cost_rate_date,
             l_fia_projfunc_cost_rate_type,
             l_fia_projfunc_cost_ex_rate,
             l_fia_projfunc_raw_cost,
             l_fia_projfunc_bd_cost,
             l_fia_projfunc_rev_rate_date  ,
             l_fia_projfunc_rev_rate_type,
             l_fia_projfunc_rev_ex_rate ,
             l_fia_projfunc_revenue,
             lx_projfunc_tp_rate_date,
             lx_projfunc_tp_rate_type,
             lx_projfunc_tp_exchange_rate,
             lx_projfunc_tp_amt,
             l_fia_expfunc_curr_code,
             l_fia_expfunc_cost_rate_date,
             l_fia_expfunc_cost_rate_type,
             l_fia_expfunc_cost_ex_rate,
             l_fia_expfunc_raw_cost,
             l_fia_expfunc_bd_cost,
             lx_expfunc_tp_rate_date,
             lx_expfunc_tp_rate_type,
             lx_expfunc_tp_exchange_rate,
             lx_expfunc_tp_amt,
             lx_cc_prvdr_orgid_tab,
             lx_cc_prvdr_orgzid_tab,
             lx_cc_recvr_orgid_tab,
             lx_cc_recvr_orgzid_tab,
             l_fi_exp_organizationid_tab,
             l_fi_exptype_tab,
             l_fi_exptypeclass_tab,
             l_tp_exp_category,
             l_tp_labor_nl_flag,
             l_tp_taskid,
             l_tp_scheduleid,
             l_tp_rev_distributed_flag,
             l_tp_compute_flag,
             l_tp_fixed_date,
             l_fi_projid_tab,
             l_fi_personid_tab,
             l_asg_fcst_jobid_tab,
             l_tp_nl_resource,
             l_tp_nl_resource_orgzid,
             l_tp_pa_date,
             l_fi_amount_type_tab,
             l_tp_asgid,
             l_fi_process_flag_tab,
             l_fi_delete_flag_tab,
             lx_tp_error_code,
             l_fi_cst_rejct_reason_tab,
             l_fi_rev_rejct_reason_tab,
             l_fi_bd_rejct_reason_tab,
             l_fi_others_rejct_reason_tab,
             l_tp_denom_raw_cost,
             l_tp_denom_bd_cost,
             l_tp_raw_revenue   ,
             lx_tp_ind_compiled_setid,
             lx_tp_bill_rate,
             lx_tp_base_amount,
             lx_tp_bill_markup_percent,
             lx_tp_sch_line_percent,
             lx_tp_rule_percent,
             lx_tp_job_id,
           lx_cc_markup_basecode FROM Pa_Fi_Amount_Dtls_Tmp;

           FOR l_trf_err_idx IN 1 .. l_fi_id_tab.COUNT LOOP
              IF lx_tp_error_code(l_trf_err_idx) IS NOT NULL AND
                 lx_tp_error_code(l_trf_err_idx) <> 'E' THEN
                 l_fi_process_flag_tab(l_trf_err_idx) := 'N';
              END IF;
           END LOOP;
           /* dbms_output.put_line('after calling tp api :'||l_fi_id_tab.count); */
        END IF;

        FOR d IN 1 .. l_fi_id_tab.count LOOP

           l_t_line_num := 0;

           IF l_fi_process_flag_tab(d) IN ( 'Y' , 'X' )   OR
              l_fi_delete_flag_tab(d)  = 'Y'              OR
              l_fi_qty_tab(d)         <= 0              THEN
              BEGIN
                  SELECT
                  LINE_NUM                     ,
                  ITEM_QUANTITY                ,
                  COST_TXN_CURRENCY_CODE       ,
                  REVENUE_TXN_CURRENCY_CODE    ,
                  TXN_RAW_COST                 ,
                  TXN_BURDENED_COST            ,
                  TXN_REVENUE                  ,
                  TXN_TRANSFER_PRICE           ,
                  TP_TXN_CURRENCY_CODE         ,
                  PROJECT_CURRENCY_CODE        ,
                  PROJECT_RAW_COST             ,
                  PROJECT_BURDENED_COST        ,
                  PROJECT_COST_RATE_DATE       ,
                  PROJECT_COST_RATE_TYPE       ,
                  PROJECT_COST_EXCHANGE_RATE   ,
                  PROJECT_REVENUE_RATE_DATE    ,
                  PROJECT_REVENUE_RATE_TYPE    ,
                  PROJECT_REVENUE_EXCHANGE_RATE,
                  PROJECT_REVENUE              ,
                  PROJECT_TP_RATE_DATE         ,
                  PROJECT_TP_RATE_TYPE         ,
                  PROJECT_TP_EXCHANGE_RATE     ,
                  PROJECT_TRANSFER_PRICE       ,
                  PROJFUNC_CURRENCY_CODE       ,
                  PROJFUNC_COST_RATE_DATE      ,
                  PROJFUNC_COST_RATE_TYPE      ,
                  PROJFUNC_COST_EXCHANGE_RATE  ,
                  PROJFUNC_RAW_COST            ,
                  PROJFUNC_BURDENED_COST       ,
                  PROJFUNC_REVENUE_RATE_DATE   ,
                  PROJFUNC_REVENUE_RATE_TYPE   ,
                  PROJFUNC_REVENUE_EXCHANGE_RATE,
                  PROJFUNC_REVENUE             ,
                  PROJFUNC_TP_RATE_DATE        ,
                  PROJFUNC_TP_RATE_TYPE        ,
                  PROJFUNC_TP_EXCHANGE_RATE    ,
                  PROJFUNC_TRANSFER_PRICE      ,
                  EXPFUNC_CURRENCY_CODE        ,
                  EXPFUNC_COST_RATE_DATE       ,
                  EXPFUNC_COST_RATE_TYPE       ,
                  EXPFUNC_COST_EXCHANGE_RATE   ,
                  EXPFUNC_RAW_COST             ,
                  EXPFUNC_BURDENED_COST        ,
                  EXPFUNC_TP_RATE_DATE         ,
                  EXPFUNC_TP_RATE_TYPE         ,
                  EXPFUNC_TP_EXCHANGE_RATE     ,
                  EXPFUNC_TRANSFER_PRICE
                  INTO
                  l_t_LINE_NUM                ,
                  l_t_ITEM_QUANTITY           ,
                  l_t_COST_TXN_CURR_CODE      ,
                  l_t_REV_TXN_CURR_CODE      ,
                  l_t_TXN_RAW_COST            ,
                  l_t_TXN_BD_COST             ,
                  l_t_TXN_REVENUE             ,
                  l_t_TXN_TRANSFER_PRICE      ,
                  l_t_TP_TXN_CURR_CODE        ,
                  l_t_PROJ_CURR_CODE          ,
                  l_t_PROJ_RAW_COST           ,
                  l_t_PROJ_BD_COST          ,
                  l_t_PROJ_COST_RATE_DATE     ,
                  l_t_PROJ_COST_RATE_TYPE     ,
                  l_t_PROJ_COST_EX_RATE     ,
                  l_t_PROJ_REV_RATE_DATE      ,
                  l_t_PROJ_REV_RATE_TYPE      ,
                  l_t_PROJ_REV_EX_RATE ,
                  l_t_PROJ_REVENUE            ,
                  l_t_PROJ_TP_RATE_DATE       ,
                  l_t_PROJ_TP_RATE_TYPE       ,
                  l_t_PROJ_TP_EX_RATE      ,
                  l_t_PROJ_TRANSFER_PRICE     ,
                  l_t_PFUNC_CURR_CODE         ,
                  l_t_PFUNC_COST_RATE_DATE    ,
                  l_t_PFUNC_COST_RATE_TYPE    ,
                  l_t_PFUNC_COST_EX_RATE      ,
                  l_t_PFUNC_RAW_COST          ,
                  l_t_PFUNC_BD_COST         ,
                  l_t_PFUNC_REV_RATE_DATE     ,
                  l_t_PFUNC_REV_RATE_TYPE     ,
                  l_t_PFUNC_REV_EX_RATE ,
                  l_t_PFUNC_REVENUE           ,
                  l_t_PFUNC_TP_RATE_DATE      ,
                  l_t_PFUNC_TP_RATE_TYPE      ,
                  l_t_PFUNC_TP_EX_RATE    ,
                  l_t_PFUNC_TRANSFER_PRICE    ,
                  l_t_EFUNC_CURR_CODE         ,
                  l_t_EFUNC_COST_RATE_DATE    ,
                  l_t_EFUNC_COST_RATE_TYPE    ,
                  l_t_EFUNC_COST_EX_RATE     ,
                  l_t_EFUNC_RAW_COST          ,
                  l_t_EFUNC_BD_COST         ,
                  l_t_EFUNC_TP_RATE_DATE     ,
                  l_t_EFUNC_TP_RATE_TYPE      ,
                  l_t_EFUNC_TP_EX_RATE     ,
                  l_t_EFUNC_TRANSFER_PRICE
                  FROM Pa_Fi_Amount_Details WHERE
                  Forecast_Item_Id = l_fi_id_tab(d) AND
                  Line_Num = ( SELECT MAX(LINE_NUM) FROM
                  Pa_Fi_Amount_Details WHERE
                  Forecast_Item_Id = l_fi_id_tab(d) );


             /* setting the variables for updating the FI amount records */
                  IF l_t_ITEM_QUANTITY > 0 THEN
                     l_fid_upd_fcst_itemid(l_fia_upd_index) := l_fi_id_tab(d);
                     l_fid_upd_line_num(l_fia_upd_index) := l_t_line_num;
                     l_fid_upd_reversed_flag(l_fia_upd_index) := 'Y';
                     l_fid_upd_net_zero_flag(l_fia_upd_index) := 'Y';
                     l_fia_upd_index := l_fia_upd_index + 1;

                    /* Setting the variables for the reversal record */

                     l_fid_cost_txn_curr_code(l_fia_index) :=  l_t_COST_TXN_CURR_CODE;
                     l_fid_rev_txn_curr_code(l_fia_index) :=  l_t_REV_TXN_CURR_CODE;
                     l_fid_txn_raw_cost(l_fia_index) := -l_t_TXN_RAW_COST;
                     l_fid_txn_bd_cost(l_fia_index) := -l_t_TXN_BD_COST;
                     l_fid_txn_revenue(l_fia_index) := -l_t_TXN_REVENUE;

                     l_fid_expfunc_curr_code(l_fia_index) := l_t_EFUNC_CURR_CODE;
                     l_fid_expfunc_raw_cost(l_fia_index) := -l_t_EFUNC_RAW_COST;
                     l_fid_expfunc_bd_cost(l_fia_index) := -l_t_EFUNC_BD_COST;

                     l_fid_projfunc_curr_code(l_fia_index) := l_t_pfunc_curr_code;
                     l_fid_projfunc_raw_cost(l_fia_index) := -l_t_PFUNC_RAW_COST;
                     l_fid_projfunc_bd_cost(l_fia_index) := -l_t_PFUNC_BD_COST;
                     l_fid_projfunc_revenue(l_fia_index) := -l_t_PFUNC_REVENUE;

                     l_fid_proj_curr_code(l_fia_index) := l_t_proj_curr_code;
                     l_fid_proj_raw_cost(l_fia_index) := -l_t_PROJ_RAW_COST;
                     l_fid_proj_bd_cost(l_fia_index) := -l_t_PROJ_BD_COST;
                     l_fid_proj_revenue(l_fia_index) := -l_t_PROJ_REVENUE;

                     l_fid_proj_cost_rate_type(l_fia_index) := l_t_PROJ_COST_RATE_TYPE;
                     l_fid_proj_cost_rate_date(l_fia_index) := l_t_PROJ_COST_RATE_DATE;
                     l_fid_proj_cost_ex_rate(l_fia_index) := l_t_PROJ_COST_EX_RATE;

                     l_fid_proj_rev_rate_type(l_fia_index) := l_t_PROJ_REV_RATE_TYPE;
                     l_fid_proj_rev_rate_date(l_fia_index) := l_t_PROJ_REV_RATE_DATE;
                     l_fid_proj_rev_ex_rate(l_fia_index) := l_t_PROJ_REV_EX_RATE;

                     l_fid_expfunc_cost_rate_type(l_fia_index) := l_t_EFUNC_COST_RATE_TYPE;
                     l_fid_expfunc_cost_rate_date(l_fia_index) := l_t_EFUNC_COST_RATE_DATE;
                     l_fid_expfunc_cost_ex_rate(l_fia_index) := l_t_EFUNC_COST_EX_RATE;

                     l_fid_projfunc_cost_rate_type(l_fia_index) := l_t_PFUNC_COST_RATE_TYPE;
                     l_fid_projfunc_cost_rate_date(l_fia_index) := l_t_PFUNC_COST_RATE_DATE;
                     l_fid_projfunc_cost_ex_rate(l_fia_index)   := l_t_PFUNC_COST_EX_RATE;

                     l_fid_projfunc_rev_rate_type(l_fia_index) := l_t_PFUNC_REV_RATE_TYPE;
                     l_fid_projfunc_rev_rate_date(l_fia_index) := l_t_PFUNC_REV_RATE_DATE;
                     l_fid_projfunc_rev_ex_rate(l_fia_index) := l_t_PFUNC_REV_EX_RATE;

                     l_fid_proj_tp_rate_type(l_fia_index) := l_t_PROJ_TP_RATE_TYPE;
                     l_fid_proj_tp_rate_date(l_fia_index) := l_t_PROJ_TP_RATE_DATE;
                     l_fid_proj_tp_ex_rate(l_fia_index) := l_t_PROJ_TP_EX_RATE;
                     l_fid_proj_tp_amt(l_fia_index) := -l_t_PROJ_TRANSFER_PRICE;

                     l_fid_projfunc_tp_rate_type(l_fia_index) := l_t_PFUNC_TP_RATE_TYPE;
                     l_fid_projfunc_tp_rate_date(l_fia_index) := l_t_PFUNC_TP_RATE_DATE;
                     l_fid_projfunc_tp_ex_rate(l_fia_index) := l_t_PFUNC_TP_EX_RATE;
                     l_fid_projfunc_tp_amt(l_fia_index) := -l_t_PFUNC_TRANSFER_PRICE;

                     l_fid_denom_tp_currcode(l_fia_index) := l_t_TP_TXN_CURR_CODE;
                     l_fid_denom_tp_amt(l_fia_index) := -l_t_TXN_TRANSFER_PRICE;

                     l_fid_expfunc_tp_rate_type(l_fia_index) := l_t_EFUNC_TP_RATE_TYPE;
                     l_fid_expfunc_tp_rate_date(l_fia_index) := l_t_EFUNC_TP_RATE_DATE;
                     l_fid_expfunc_tp_ex_rate(l_fia_index) := l_t_EFUNC_TP_EX_RATE;
                     l_fid_expfunc_tp_amt(l_fia_index) := -l_t_EFUNC_TRANSFER_PRICE;

                     l_fid_fcst_itemid(l_fia_index) := l_fi_id_tab(d);
                     l_fid_line_num(l_fia_index) := l_t_line_num + 1;
                     l_fid_item_date(l_fia_index) := l_fi_date_tab(d);
                     l_fid_item_uom(l_fia_index) := l_fi_uom_tab(d);
                     l_fid_item_qty(l_fia_index) := -l_t_ITEM_QUANTITY;
                     l_fid_reversed_flag(l_fia_index) := 'N';
                     l_fid_net_zero_flag(l_fia_index) := 'Y';
                     l_fid_line_num_reversed(l_fia_index) := l_t_line_num;

                     l_t_line_num := l_t_line_num + 1;
                     l_fia_index := l_fia_index + 1;
                  END IF;
                  /* end if for l_t_ITEM_QUANTITY gt zero */
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 NULL;
              WHEN OTHERS THEN
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    PA_DEBUG.g_err_stage := 'Inside FI Amt Dtls others Excep';
                    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                 END IF;
                 RAISE;
              END;

              /* dbms_output.put_line('assigning values for the new line');
              dbms_output.put_line('before txn curr code and txn amts'); */
              IF l_fi_process_flag_tab(d) = 'Y' THEN
                  l_fid_cost_txn_curr_code(l_fia_index) :=  l_fia_cost_txn_curr_code(d);
                  l_fid_rev_txn_curr_code(l_fia_index) :=  l_fia_rev_txn_curr_code(d);
                  l_fid_txn_raw_cost(l_fia_index) := l_fia_txn_raw_cost(d);
                  l_fid_txn_bd_cost(l_fia_index) := l_fia_txn_bd_cost(d);
                  l_fid_txn_revenue(l_fia_index) := l_fia_txn_revenue(d);

                  /* dbms_output.put_line('before exp func code and amts');   */

                  l_fid_expfunc_curr_code(l_fia_index) := l_fia_expfunc_curr_code(d);
                  l_fid_expfunc_raw_cost(l_fia_index) := l_fia_expfunc_raw_cost(d);
                  l_fid_expfunc_bd_cost(l_fia_index) := l_fia_expfunc_bd_cost(d);

                  l_fid_expfunc_cost_rate_type(l_fia_index) := l_fia_expfunc_cost_rate_type(d);
                  l_fid_expfunc_cost_rate_date(l_fia_index) := l_fia_expfunc_cost_rate_date(d);
                  l_fid_expfunc_cost_ex_rate(l_fia_index) := l_fia_expfunc_cost_ex_rate(d);

                  l_fid_expfunc_tp_rate_type(l_fia_index) := lx_expfunc_tp_rate_type(d);
                  l_fid_expfunc_tp_rate_date(l_fia_index) := lx_expfunc_tp_rate_date(d);
                  l_fid_expfunc_tp_ex_rate(l_fia_index) := lx_expfunc_tp_exchange_rate(d);
                  l_fid_expfunc_tp_amt(l_fia_index) := lx_expfunc_tp_amt(d);

                  /* dbms_output.put_line('before proj func code and amts');  */

                  l_fid_projfunc_curr_code(l_fia_index) := l_prjfunc_curr_code_tab(d);
                  l_fid_projfunc_raw_cost(l_fia_index) := l_fia_projfunc_raw_cost(d);
                  l_fid_projfunc_bd_cost(l_fia_index) := l_fia_projfunc_bd_cost(d);
                  l_fid_projfunc_revenue(l_fia_index) := l_fia_projfunc_revenue(d);

                  l_fid_projfunc_cost_rate_type(l_fia_index) := l_fia_projfunc_cost_rate_type(d);
                  l_fid_projfunc_cost_rate_date(l_fia_index) := l_fia_projfunc_cost_rate_date(d);
                  l_fid_projfunc_cost_ex_rate(l_fia_index) := l_fia_projfunc_cost_ex_rate(d);

                  l_fid_projfunc_rev_rate_type(l_fia_index) := l_fia_projfunc_rev_rate_type(d);
                  l_fid_projfunc_rev_rate_date(l_fia_index) := l_fia_projfunc_rev_rate_date(d);
                  l_fid_projfunc_rev_ex_rate(l_fia_index) := l_fia_projfunc_rev_ex_rate(d);

                  l_fid_projfunc_tp_rate_type(l_fia_index) := lx_projfunc_tp_rate_type(d);
                  l_fid_projfunc_tp_rate_date(l_fia_index) := lx_projfunc_tp_rate_date(d);
                  l_fid_projfunc_tp_ex_rate(l_fia_index) := lx_projfunc_tp_exchange_rate(d);
                  l_fid_projfunc_tp_amt(l_fia_index) := lx_projfunc_tp_amt(d);

                  /* dbms_output.put_line('pf tp rt type :'||lx_projfunc_tp_rate_type(d));
                  dbms_output.put_line('pf tp rt date :'||lx_projfunc_tp_rate_date(d));
                  dbms_output.put_line('pf tp ex rate :'||lx_projfunc_tp_exchange_rate(d));
                  dbms_output.put_line('pf tp amount  :'||lx_projfunc_tp_amt(d));
                   dbms_output.put_line('before proj code and amts');   */

                  l_fid_proj_curr_code(l_fia_index) := l_prj_curr_code_tab(d);
                  l_fid_proj_raw_cost(l_fia_index) := l_fia_proj_raw_cost(d);
                  l_fid_proj_bd_cost(l_fia_index) := l_fia_proj_bd_cost(d);
                  l_fid_proj_revenue(l_fia_index) := l_fia_proj_revenue(d);

                  /* dbms_output.put_line('before assigning proj rev');
                  dbms_output.put_line('fia proj rev :'||l_fia_proj_revenue(d));
                  dbms_output.put_line('fid proj rev :'||l_fid_proj_revenue(l_fia_index)); */

                  l_fid_proj_cost_rate_type(l_fia_index) := l_fia_proj_cost_rate_type(d);
                  l_fid_proj_cost_rate_date(l_fia_index) := l_fia_proj_cost_rate_date(d);
                  l_fid_proj_cost_ex_rate(l_fia_index) := l_fia_proj_cost_ex_rate(d);

                  l_fid_proj_rev_rate_type(l_fia_index) := l_fia_proj_rev_rate_type(d);
                  l_fid_proj_rev_rate_date(l_fia_index) := l_fia_proj_rev_rate_date(d);
                  l_fid_proj_rev_ex_rate(l_fia_index) := l_fia_proj_rev_ex_rate(d);

                  l_fid_proj_tp_rate_type(l_fia_index) := lx_proj_tp_rate_type(d);
                  l_fid_proj_tp_rate_date(l_fia_index) := lx_proj_tp_rate_date(d);
                  l_fid_proj_tp_ex_rate(l_fia_index) := lx_proj_tp_exchange_rate(d);
                  l_fid_proj_tp_amt(l_fia_index) := lx_proj_tp_amt(d);

                  /* dbms_output.put_line('before denom and amts');  */

                  l_fid_denom_tp_currcode(l_fia_index) := lx_denom_tp_currcode(d);
                  l_fid_denom_tp_amt(l_fia_index) := lx_denom_tp_amt(d);


                  l_fid_fcst_itemid(l_fia_index) := l_fi_id_tab(d);
                  l_fid_line_num(l_fia_index) := l_t_line_num + 1;
                  l_fid_item_date(l_fia_index) := l_fi_date_tab(d);
                  l_fid_item_uom(l_fia_index) := l_fi_uom_tab(d);
                  l_fid_item_qty(l_fia_index) := l_fi_qty_tab(d);
                  l_fid_reversed_flag(l_fia_index) := 'N';
                  l_fid_net_zero_flag(l_fia_index) := 'N';
                  l_fid_line_num_reversed(l_fia_index) := NULL;

                  l_fia_index := l_fia_index + 1;
              END IF;
          END IF;
                     /* forecast_process_flag = Y   */
        END LOOP;

        /* dbms_output.put_line('fi amt tab count :'||l_fid_fcst_itemid.count);
        dbms_output.put_line('bef inserting FI amount dtls :');  */

        IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.g_err_stage := 'Bef inserting FI Amt Dtls';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;

        FORALL b IN 1 .. l_fid_fcst_itemid.COUNT
            INSERT INTO Pa_Fi_Amount_Details(
            FORECAST_ITEM_ID,
            LINE_NUM,
            ITEM_DATE,
            ITEM_UOM,
            ITEM_QUANTITY,
            NET_ZERO_FLAG,
            REVERSED_FLAG,
            LINE_NUM_REVERSED,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            COST_TXN_CURRENCY_CODE,
            REVENUE_TXN_CURRENCY_CODE,
            TXN_RAW_COST,
            TXN_BURDENED_COST,
            TXN_REVENUE,
            TXN_TRANSFER_PRICE,
            TP_TXN_CURRENCY_CODE,
            PROJECT_CURRENCY_CODE,
            PROJECT_RAW_COST,
            PROJECT_BURDENED_COST,
            PROJECT_COST_RATE_DATE,
            PROJECT_COST_RATE_TYPE,
            PROJECT_COST_EXCHANGE_RATE,
            PROJECT_REVENUE_RATE_DATE,
            PROJECT_REVENUE_RATE_TYPE,
            PROJECT_REVENUE_EXCHANGE_RATE,
            PROJECT_REVENUE,
            PROJECT_TP_RATE_DATE,
            PROJECT_TP_RATE_TYPE,
            PROJECT_TP_EXCHANGE_RATE,
            PROJECT_TRANSFER_PRICE,
            PROJFUNC_CURRENCY_CODE,
            PROJFUNC_COST_RATE_DATE,
            PROJFUNC_COST_RATE_TYPE,
            PROJFUNC_COST_EXCHANGE_RATE,
            PROJFUNC_RAW_COST,
            PROJFUNC_BURDENED_COST,
            PROJFUNC_REVENUE_RATE_DATE,
            PROJFUNC_REVENUE_RATE_TYPE,
            PROJFUNC_REVENUE_EXCHANGE_RATE,
            PROJFUNC_REVENUE,
            PROJFUNC_TP_RATE_DATE,
            PROJFUNC_TP_RATE_TYPE,
            PROJFUNC_TP_EXCHANGE_RATE,
            PROJFUNC_TRANSFER_PRICE,
            EXPFUNC_CURRENCY_CODE,
            EXPFUNC_COST_RATE_DATE,
            EXPFUNC_COST_RATE_TYPE,
            EXPFUNC_COST_EXCHANGE_RATE,
            EXPFUNC_RAW_COST,
            EXPFUNC_BURDENED_COST,
            EXPFUNC_TP_RATE_DATE,
            EXPFUNC_TP_RATE_TYPE,
            EXPFUNC_TP_EXCHANGE_RATE,
            EXPFUNC_TRANSFER_PRICE   )
         VALUES(
            l_fid_fcst_itemid(b),
            l_fid_line_num(b),
            l_fid_item_date(b),
            l_fid_item_uom(b),
            l_fid_item_qty(b),
            l_fid_net_zero_flag(b),
            l_fid_reversed_flag(b),
            l_fid_line_num_reversed(b),
            l_creation_date,
            l_created_by,
            l_last_update_date,
            l_last_updated_by,
            l_last_update_login,
            l_request_id,
            l_program_application_id,
            l_program_id,
            l_last_update_date,
            l_fid_cost_txn_curr_code(b),
            l_fid_rev_txn_curr_code(b),
            l_fid_txn_raw_cost(b),
            l_fid_txn_bd_cost(b),
            l_fid_txn_revenue(b),
            l_fid_denom_tp_amt(b),
            l_fid_denom_tp_currcode(b),
            l_fid_proj_curr_code(b),
            l_fid_proj_raw_cost(b),
            l_fid_proj_bd_cost(b),
            l_fid_proj_cost_rate_date(b),
            l_fid_proj_cost_rate_type(b),
            l_fid_proj_cost_ex_rate(b),
            l_fid_proj_rev_rate_date(b),
            l_fid_proj_rev_rate_type(b),
            l_fid_proj_rev_ex_rate(b),
            l_fid_proj_revenue(b),
            l_fid_proj_tp_rate_date(b),
            l_fid_proj_tp_rate_type(b),
            l_fid_proj_tp_ex_rate(b),
            l_fid_proj_tp_amt(b),
            l_fid_projfunc_curr_code(b),
            l_fid_projfunc_cost_rate_date(b),
            l_fid_projfunc_cost_rate_type(b),
            l_fid_projfunc_cost_ex_rate(b),
            l_fid_projfunc_raw_cost(b),
            l_fid_projfunc_bd_cost(b),
            l_fid_projfunc_rev_rate_date(b),
            l_fid_projfunc_rev_rate_type(b),
            l_fid_projfunc_rev_ex_rate(b),
            l_fid_projfunc_revenue(b),
            l_fid_projfunc_tp_rate_date(b),
            l_fid_projfunc_tp_rate_type(b),
            l_fid_projfunc_tp_ex_rate(b),
            l_fid_projfunc_tp_amt(b),
            l_fid_expfunc_curr_code(b),
            l_fid_expfunc_cost_rate_date(b),
            l_fid_expfunc_cost_rate_type(b),
            l_fid_expfunc_cost_ex_rate(b),
            l_fid_expfunc_raw_cost(b),
            l_fid_expfunc_bd_cost(b),
            l_fid_expfunc_tp_rate_date(b),
            l_fid_expfunc_tp_rate_type(b),
            l_fid_expfunc_tp_ex_rate(b),
            l_fid_expfunc_tp_amt(b)  );

        IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.g_err_stage := 'Bef updating FI Amt Dtls';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;
        /* dbms_output.put_line('bef updating FI amount dtls :');  */

    FORALL l_upd_idx IN 1 .. l_fid_upd_fcst_itemid.COUNT
    UPDATE Pa_FI_Amount_Details SET
    Reversed_flag          = 'Y',
    Net_Zero_Flag          = 'Y',
    LAST_UPDATE_DATE       = l_last_update_date,
    LAST_UPDATED_BY        = l_last_updated_by,
    LAST_UPDATE_LOGIN      = l_last_update_login,
    REQUEST_ID             = l_request_id,
    PROGRAM_APPLICATION_ID = l_program_application_id,
    PROGRAM_ID             = l_program_id,
    PROGRAM_UPDATE_DATE    = l_last_update_date
        WHERE
    Forecast_Item_Id       = l_fid_upd_fcst_itemid(l_upd_idx) AND
    Line_Num               = l_fid_upd_line_num(l_upd_idx);

        IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.g_err_stage := 'Bef updating Fcst Items';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;
        /* dbms_output.put_line('bef updating FIs :');  */

    FOR l_tupd IN 1 .. l_fi_id_tab.COUNT LOOP
       IF l_fi_delete_flag_tab(l_tupd) = 'Y' OR l_fi_qty_tab(l_tupd) <= 0 THEN
          l_fi_process_flag_tab(l_tupd) := 'X';
       END IF;
       IF NVL(l_fi_others_rejct_reason_tab(l_tupd),'abcx') = 'E' THEN
          l_fi_others_rejct_reason_tab(l_tupd) := NULL;
       END IF;
       IF NVL(lx_tp_error_code(l_tupd),'abcx') = 'E' THEN
          lx_tp_error_code(l_tupd) := NULL;
       END IF;
       IF l_fi_process_flag_tab(l_tupd) <>  'Y' OR
          l_fi_delete_flag_tab(l_tupd)  =  'Y' OR
          l_fi_qty_tab(l_tupd)          <= 0           THEN
          l_fia_cost_txn_curr_code(l_tupd) := NULL;
          l_fia_rev_txn_curr_code(l_tupd) := NULL;
          l_fia_txn_raw_cost(l_tupd) := NULL;
          l_fia_txn_bd_cost(l_tupd) := NULL;
          l_fia_txn_revenue(l_tupd) := NULL;
          lx_denom_tp_currcode(l_tupd) := NULL;
          lx_denom_tp_amt(l_tupd) := NULL;
          l_fia_expfunc_curr_code(l_tupd) := NULL;
          l_fia_expfunc_raw_cost(l_tupd) := NULL;
          l_fia_expfunc_bd_cost(l_tupd) := NULL;
          lx_expfunc_tp_amt(l_tupd) := NULL;
          l_prjfunc_curr_code_tab(l_tupd) := NULL;
          l_fia_projfunc_raw_cost(l_tupd) := NULL;
          l_fia_projfunc_bd_cost(l_tupd) := NULL;
          l_fia_projfunc_revenue(l_tupd) := NULL;
          lx_projfunc_tp_amt(l_tupd) := NULL;
          l_prj_curr_code_tab(l_tupd) := NULL;
          l_fia_proj_raw_cost(l_tupd) := NULL;
          l_fia_proj_bd_cost(l_tupd) := NULL;
          l_fia_proj_revenue(l_tupd) := NULL;
          lx_proj_tp_amt(l_tupd) := NULL;
       END IF;
    END LOOP;

     /* dbms_output.put_line(' pro flag        '||l_fi_process_flag_tab.count);
     dbms_output.put_line(' amt type        '||l_fi_amount_type_tab.count);
     dbms_output.put_line(' cst txn curr    '||l_fia_cost_txn_curr_code.count);
     dbms_output.put_line(' rev txn curr    '||l_fia_rev_txn_curr_code.count);
     dbms_output.put_line(' txn raw cost    '||l_fia_txn_raw_cost.count);
     dbms_output.put_line(' txn bd cost     '||l_fia_txn_bd_cost.count);
     dbms_output.put_line(' txn rev         '||l_fia_txn_revenue.count);
     dbms_output.put_line(' denom tp curr   '||lx_denom_tp_currcode.count);
     dbms_output.put_line(' denom tp amt    '||lx_denom_tp_amt.count);
     dbms_output.put_line(' ef curr         '||l_fia_expfunc_curr_code.count);
     dbms_output.put_line(' ef raw cst      '||l_fia_expfunc_raw_cost.count);
     dbms_output.put_line(' ef bd cst       '||l_fia_expfunc_bd_cost.count);
     dbms_output.put_line(' ef tp amt       '||lx_expfunc_tp_amt.count);
     dbms_output.put_line(' pf curr         '||l_prjfunc_curr_code_tab.count);
     dbms_output.put_line(' pf raw cst      '||l_fia_projfunc_raw_cost.count);
     dbms_output.put_line(' pf bd cst       '||l_fia_projfunc_bd_cost.count);
     dbms_output.put_line(' pf rev          '||l_fia_projfunc_revenue.count);
     dbms_output.put_line(' pf tp amt       '||lx_projfunc_tp_amt.count);
     dbms_output.put_line(' prj curr        '||l_prj_curr_code_tab.count);
     dbms_output.put_line(' prj raw cst     '||l_fia_proj_raw_cost.count);
     dbms_output.put_line(' prj bd cst      '||l_fia_proj_bd_cost.count);
     dbms_output.put_line(' prj rev         '||l_fia_proj_revenue.count);
     dbms_output.put_line(' prj tp amt      '||lx_proj_tp_amt.count);
     dbms_output.put_line(' cst rej         '||l_fi_cst_rejct_reason_tab.count);
     dbms_output.put_line(' rev rej         '||l_fi_rev_rejct_reason_tab.count);
     dbms_output.put_line(' tp  rej         '||lx_tp_error_code.count);
     dbms_output.put_line(' bd  rej         '||l_fi_bd_rejct_reason_tab.count);
     dbms_output.put_line(' other rej       '||l_fi_others_rejct_reason_tab.count);
     dbms_output.put_line(' fi id           '||l_fi_id_tab.count); */


    FORALL l_fi_upd_index IN 1 .. l_fi_id_tab.COUNT
    UPDATE Pa_Forecast_Items SET
    FORECAST_AMT_CALC_FLAG    = l_fi_process_flag_tab(l_fi_upd_index),
    TP_AMOUNT_TYPE            = l_fi_amount_type_tab(l_fi_upd_index),
    COST_TXN_CURRENCY_CODE    = l_fia_cost_txn_curr_code(l_fi_upd_index),
    REVENUE_TXN_CURRENCY_CODE = l_fia_rev_txn_curr_code(l_fi_upd_index),
    TXN_RAW_COST              = l_fia_txn_raw_cost(l_fi_upd_index),
    TXN_BURDENED_COST         = l_fia_txn_bd_cost(l_fi_upd_index),
    TXN_REVENUE               = l_fia_txn_revenue(l_fi_upd_index),
    TP_TXN_CURRENCY_CODE      = lx_denom_tp_currcode(l_fi_upd_index),
    TXN_TRANSFER_PRICE        = lx_denom_tp_amt(l_fi_upd_index),
    EXPFUNC_CURRENCY_CODE     = l_fia_expfunc_curr_code(l_fi_upd_index),
    EXPFUNC_RAW_COST          = l_fia_expfunc_raw_cost(l_fi_upd_index),
    EXPFUNC_BURDENED_COST     = l_fia_expfunc_bd_cost(l_fi_upd_index),
    EXPFUNC_TRANSFER_PRICE    = lx_expfunc_tp_amt(l_fi_upd_index),
    PROJFUNC_CURRENCY_CODE    = l_prjfunc_curr_code_tab(l_fi_upd_index),
    PROJFUNC_RAW_COST         = l_fia_projfunc_raw_cost(l_fi_upd_index),
    PROJFUNC_BURDENED_COST    = l_fia_projfunc_bd_cost(l_fi_upd_index),
    PROJFUNC_REVENUE          = l_fia_projfunc_revenue(l_fi_upd_index),
    PROJFUNC_TRANSFER_PRICE   = lx_projfunc_tp_amt(l_fi_upd_index),
    PROJECT_CURRENCY_CODE     = l_prj_curr_code_tab(l_fi_upd_index),
    PROJECT_RAW_COST          = l_fia_proj_raw_cost(l_fi_upd_index),
    PROJECT_BURDENED_COST     = l_fia_proj_bd_cost(l_fi_upd_index),
    PROJECT_REVENUE           = l_fia_proj_revenue(l_fi_upd_index),
    PROJECT_TRANSFER_PRICE    = lx_proj_tp_amt(l_fi_upd_index),
    COST_REJECTION_CODE       = l_fi_cst_rejct_reason_tab(l_fi_upd_index),
    REV_REJECTION_CODE        = l_fi_rev_rejct_reason_tab(l_fi_upd_index),
    TP_REJECTION_CODE         = lx_tp_error_code(l_fi_upd_index),
    BURDEN_REJECTION_CODE     = l_fi_bd_rejct_reason_tab(l_fi_upd_index),
    OTHER_REJECTION_CODE      = l_fi_others_rejct_reason_tab(l_fi_upd_index),
    LAST_UPDATE_DATE          = l_last_update_date,
    LAST_UPDATED_BY           = l_last_updated_by,
    LAST_UPDATE_LOGIN         = l_last_update_login,
    REQUEST_ID                = l_request_id,
    PROGRAM_APPLICATION_ID    = l_program_application_id,
    PROGRAM_ID                = l_program_id,
    PROGRAM_UPDATE_DATE       = l_last_update_date
    WHERE Forecast_Item_Id    = l_fi_id_tab(l_fi_upd_index);

     /* dbms_output.put_line('records updated in FI :'||sql%rowcount );  */


    /*    for i in 1.. l_fi_id_tab.count loop
        dbms_output.put_line(i ||' pid   ' ||l_fi_projid_tab(i) || ' aid  '||l_fi_asgid_tab(i)
                               ||' ity   ' ||l_fi_item_type_tab(I)
                               ||' etyp  ' ||l_fi_exptype_Tab(i)
                               ||' sys   ' ||l_fi_exptypeclass_tab(i)
                               ||' cty   ' ||lx_cc_type_tab(i)
                               ||' cc    ' ||lx_cc_code_tab(i)
                               ||' csta  ' ||lx_cc_status_tab(i) );
        dbms_output.put_line('pfunc curr:'||l_prjfunc_curr_code_tab(i));
        dbms_output.put_line('p     curr:'||l_prj_curr_code_tab(i));
      end loop;    */

       COMMIT;
    END LOOP;
    /* main loop for bulk fetch from FIs */

    /* Bug 3051110 - Code added for populating two columns in pa_project_assignments table
                      TP Enhancement */

	IF p_debug_mode = 'Y' THEN
	   pa_debug.write('Pa_Fi_Amt_Calc_Pkg.Calculate_Fcst_Amounts', 'Start of populating TP Rate columns', 3);
	END IF;

/* The cursor Cur_Assignments will get all the assignment_ids processed in this particular request */

    Open Cur_Assignments(l_request_id);
    LOOP
	FETCH Cur_Assignments INTO l_assignment_id;
        EXIT WHEN Cur_Assignments%NOTFOUND;

	IF p_debug_mode = 'Y' THEN
	   pa_debug.write('Pa_Fi_Amt_Calc_Pkg.Calculate_Fcst_Amounts', 'Currently Populating for assignment_id :'||l_assignment_id, 3);
	END IF;

/*
   Getting the sum of projfunc_transfer_price and item_quantity from pa_forecast_items table for the assignment_id,
   if any of the sum is NULL we populate the transfer_price_rate as NULL and transfer_pr_rate_curr as NULL and if
   any of the sum is 0, we populate the transfer_price_rate as 0 and transfer_pr_rate_curr as the project
   functional currency. If both the sums have non zero value and they are not null, we calculate the average
   transfer_price_rate and call the api to populate the transfer_price_rate as average Transfer_price_Rate and
   transfer_pr_rate_curr as the project functional currency
*/

       BEGIN
	Select sum(PROJFUNC_TRANSFER_PRICE), Sum(ITEM_QUANTITY)
	INTO l_sum_transfer_price, l_sum_item_quantity
	From PA_FORECAST_ITEMS
	Where assignment_id = l_assignment_ID and delete_flag = 'N'
	and error_flag = 'N' And forecast_amt_Calc_flag ='Y';
       EXCEPTION WHEN NO_DATA_FOUND THEN
           l_sum_transfer_price := Null;
	   l_sum_item_quantity := Null;
       END;

	IF p_debug_mode = 'Y' THEN
	   pa_debug.write('Pa_Fi_Amt_Calc_Pkg.Calculate_Fcst_Amounts', 'TP rate for assignment:'||l_sum_transfer_price, 3);
	   pa_debug.write('Pa_Fi_Amt_Calc_Pkg.Calculate_Fcst_Amounts', 'Item Quantity for assignment:'||l_sum_item_quantity, 3);
           pa_debug.write('Pa_Fi_Amt_Calc_Pkg.Calculate_Fcst_Amounts', 'Proj Func Curency:'||l_prjfunc_curr_code, 3);
	END IF;

	IF l_sum_transfer_price is NULL OR l_sum_item_quantity is NULL OR l_sum_item_quantity = 0 THEN
		PA_ASSIGNMENTS_PVT.Update_Transfer_Price
		(
		  p_assignment_id        => l_assignment_id
		 ,p_debug_mode           => p_debug_mode
		 ,p_transfer_price_rate  => NULL
		 ,p_transfer_pr_rate_curr=> NULL
		 ,x_return_status            => l_return_status
		 );
        ELSE
	  l_average_transfer_price_rate := l_sum_transfer_price / l_sum_item_quantity;
		PA_ASSIGNMENTS_PVT.Update_Transfer_Price
		(
		  p_assignment_id        => l_assignment_id
  		 ,p_debug_mode           => p_debug_mode
		 ,p_transfer_price_rate  => l_average_transfer_price_rate
		 ,p_transfer_pr_rate_curr=> l_prjfunc_curr_code
		 ,x_return_status        => l_return_status
		 );
        END IF;

    END LOOP;
    CLOSE Cur_Assignments;

    IF p_run_mode = 'F' THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.g_err_stage := 'Closing Fcst_Item_All and returning';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;
       CLOSE fcst_item_All;
    ELSIF p_run_mode = 'I' THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.g_err_stage := 'Closing Fcst_Item_Inc and returning';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;
       CLOSE fcst_item_Inc;
    ELSIF p_run_mode = 'P' AND p_select_criteria = '01' AND
          p_project_id IS NOT NULL AND p_assignment_id IS NULL      THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.g_err_stage := 'Closing Fcst_Item_Prj and returning';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;
       CLOSE fcst_item_Prj;
    ELSIF p_run_mode = 'P' AND p_select_criteria = '01' AND
          p_project_id IS NOT NULL AND p_assignment_id IS NOT NULL      THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.g_err_stage := 'Closing Fcst_Item_Prj_Asg and returning';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;
       CLOSE fcst_item_Prj_Asg;
    ELSIF p_run_mode = 'P' AND p_select_criteria in ( '02','03') THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.g_err_stage := 'Closing Fcst_Item_Organization and returning';
          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;
       CLOSE fcst_item_Organization;
    END IF;
     /* Bug fix:4329035 */
    IF  P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
    END IF;
    RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    retcode := '2';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.g_err_stage := 'Inside Main Others Excep';
       PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       PA_DEBUG.Log_Message(p_message => SQLERRM); -- Bug 7423839
	PA_DEBUG.Reset_Curr_Function;
    END IF;
    RAISE;
  END;
END Pa_Fi_Amt_Calc_Pkg;

/
