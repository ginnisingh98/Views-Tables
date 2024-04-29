--------------------------------------------------------
--  DDL for Package Body PA_PROJECTS_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECTS_PKG1" as
/* $Header: PAXPRO1B.pls 120.2.12010000.2 2008/10/27 16:40:16 atshukla ship $ */

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Project_Id                     NUMBER,
                       X_Name                           VARCHAR2,
                       X_Long_Name                      VARCHAR2,
                       X_Segment1                       VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Project_Type                   VARCHAR2,
                       X_Carrying_Out_Organization_Id   NUMBER,
                       X_Public_Sector_Flag             VARCHAR2,
-- Commented for Bug 3605235
                       --X_Project_Status_Code            VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_Completion_Date                DATE,
                       X_Closed_Date                    DATE,
                       X_Distribution_Rule              VARCHAR2,
                       X_Labor_Invoice_Format_Id        NUMBER,
                       X_NL_Invoice_Format_Id    	NUMBER,
                       X_Retention_Invoice_Format_Id    NUMBER,
                       X_Retention_Percentage           NUMBER,
                       X_Billing_Offset                 NUMBER,
                       X_Billing_Cycle_Id               NUMBER,
                       X_Labor_Std_Bill_Rate_Schdl      VARCHAR2,
                       X_Labor_Bill_Rate_Org_Id         NUMBER,
                       X_Labor_Schedule_Fixed_Date      DATE,
                       X_Labor_Schedule_Discount        NUMBER,
                       X_NL_Std_Bill_Rate_Schdl  	VARCHAR2,
                       X_NL_Bill_Rate_Org_Id     	NUMBER,
                       X_NL_Schedule_Fixed_Date  	DATE,
                       X_NL_Schedule_Discount    	NUMBER,
                       X_Limit_To_Txn_Controls_Flag     VARCHAR2,
                       X_Project_Level_Funding_Flag     VARCHAR2,
                       X_Invoice_Comment                VARCHAR2,
                       X_Unbilled_Receivable_Dr         NUMBER,
                       X_Unearned_Revenue_Cr            NUMBER,
                       X_Summary_Flag                   VARCHAR2,
                       X_Enabled_Flag                   VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Segment6                       VARCHAR2,
                       X_Segment7                       VARCHAR2,
                       X_Segment8                       VARCHAR2,
                       X_Segment9                       VARCHAR2,
                       X_Segment10                      VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Cost_Ind_Rate_Sch_Id           NUMBER,
                       X_Rev_Ind_Rate_Sch_Id            NUMBER,
                       X_Inv_Ind_Rate_Sch_Id            NUMBER,
                       X_Cost_Ind_Sch_Fixed_Date        DATE,
                       X_Rev_Ind_Sch_Fixed_Date         DATE,
                       X_Inv_Ind_Sch_Fixed_Date         DATE,
                       X_Labor_Sch_Type                 VARCHAR2,
                       X_Non_Labor_Sch_Type             VARCHAR2,
                       X_Template_Flag                  VARCHAR2,
                       X_Verification_Date              DATE,
                       X_Created_From_Project_Id        NUMBER,
                       X_Template_Start_Date  		     DATE,
                       X_Template_End_Date    		     DATE,
--added to remove bug#594567 :ashia Bagai 6-jan-98
-- Commented for Bug 3605235
              	        --X_Wf_Status_Code			        VARCHAR2,
                       X_Project_Currency_Code          VARCHAR2,
                       X_Allow_Cross_Charge_Flag        VARCHAR2,
                       X_Project_Rate_Date              DATE,
                       X_Project_Rate_Type              VARCHAR2,
                       X_Output_Tax_Code                VARCHAR2,
                       X_Retention_Tax_Code             VARCHAR2,
                       X_CC_Process_Labor_Flag          VARCHAR2,
                       X_Labor_Tp_Schedule_Id           NUMBER,
                       X_Labor_Tp_Fixed_Date            DATE,
                       X_CC_Process_NL_Flag             VARCHAR2,
                       X_Nl_Tp_Schedule_Id              NUMBER,
                       X_Nl_Tp_Fixed_Date               DATE,
                       X_CC_Tax_Task_Id                 NUMBER,
--   End of addtion to remove bug#594567
--   17-MAY-00  kkekkar     Added the following columns for CBGA project
--                          bill_job_group_id, cost_job_group_id
                       x_bill_job_group_id              NUMBER,
                       x_cost_job_group_id              NUMBER,
                       x_role_list_id                   NUMBER,
                       x_work_type_id                   NUMBER,
                       x_calendar_id                    NUMBER,
                       x_location_id                    NUMBER,
                       x_probability_member_id          NUMBER,
                       x_project_value                  NUMBER,
                       x_expected_approval_date         DATE,
                       x_team_template_id               NUMBER,
-- 21-MAR-2001 anlee
-- added job_bill_rate_schedule_id,
-- emp_bill_rate_schedule_id for
-- PRM forecasting changes
                       x_job_bill_rate_schedule_id      NUMBER,
                       x_emp_bill_rate_schedule_id      NUMBER,
--MCA Sakthi for MultiAgreementCurreny Project
                       x_competence_match_wt            NUMBER,
                       x_availability_match_wt          NUMBER,
                       x_job_level_match_wt             NUMBER,
                       x_enable_automated_search        VARCHAR2,
                       x_search_min_availability        NUMBER,
                       x_search_org_hier_id             NUMBER,
                       x_search_starting_org_id         NUMBER,
                       x_search_country_code            VARCHAR2,
                       x_min_cand_score_reqd_for_nom    NUMBER,
                       x_non_lab_std_bill_rt_sch_id     NUMBER,
                       x_invproc_currency_type          VARCHAR2,
                       x_revproc_currency_code          VARCHAR2,
                       x_project_bil_rate_date_code     VARCHAR2,
                       x_project_bil_rate_type          VARCHAR2,
                       x_project_bil_rate_date          DATE,
                       x_project_bil_exchange_rate      NUMBER,
                       x_projfunc_currency_code         VARCHAR2,
                       x_projfunc_bil_rate_date_code    VARCHAR2,
                       x_projfunc_bil_rate_type         VARCHAR2,
                       x_projfunc_bil_rate_date         DATE,
                       x_projfunc_bil_exchange_rate     NUMBER,
                       x_funding_rate_date_code         VARCHAR2,
                       x_funding_rate_type              VARCHAR2,
                       x_funding_rate_date              DATE,
                       x_funding_exchange_rate          NUMBER,
                       x_baseline_funding_flag          VARCHAR2,
                       x_projfunc_cost_rate_type         VARCHAR2,
                       x_projfunc_cost_rate_date         DATE,
                       x_multi_currency_billing_flag    VARCHAR2,
                       x_inv_by_bill_trans_curr_flag    VARCHAR2,
--MCA Sakthi for MultiAgreementCurrency Project
--MCA
                       x_assign_precedes_task       VARCHAR2,
--MCA
--Structure
                       x_split_cost_from_wokplan_flag   VARCHAR2,
                       x_split_cost_from_bill_flag       VARCHAR2,
--Structure
--Advertisement
                       x_adv_action_set_id              NUMBER,
                       x_start_adv_action_set_flag      VARCHAR2,
--Advertisement
--Project Setup
                       x_priority_code                  VARCHAR2,
--Project Setup
--Retention
                       x_retn_billing_inv_format_id     NUMBER,
                       x_retn_accounting_flag           VARCHAR2,
--Retention
-- anlee
-- patchset K changes
                       x_revaluate_funding_flag         VARCHAR2,
                       x_include_gains_losses_flag    VARCHAR2,
-- msundare
                       x_security_level                 NUMBER,
                       x_labor_disc_reason_code         VARCHAR2,
                       x_non_labor_disc_reason_code     VARCHAR2,
-- End of changes
	               x_record_version_number          NUMBER,
		       x_btc_cost_base_rev_code         VARCHAR2,   /* Bug#2638968 */
                       x_revtrans_currency_type         VARCHAR2, /* R12 - Bug 4363092 */
--PA L
                       x_asset_allocation_method        VARCHAR2,
                       x_capital_event_processing       VARCHAR2,
                       x_cint_rate_sch_id               NUMBER,
                       x_cint_eligible_flag             VARCHAR2,
                       x_cint_stop_date                 DATE,
--FP_M Changes. Tracking Bug 3279981
                       x_en_top_task_customer_flag  VARCHAR2,
                       x_en_top_task_inv_mth_flag   VARCHAR2,
                       x_revenue_accrual_method         VARCHAR2,
                       x_invoice_method                 VARCHAR2,
                       x_projfunc_attr_for_ar_flag      VARCHAR2,
                       x_sys_program_flag               VARCHAR2,
                       x_allow_multi_program_rollup     VARCHAR2,
                       x_proj_req_res_format_id         NUMBER,
                       x_proj_asgmt_res_format_id       NUMBER,
                       x_date_eff_funds_flag            VARCHAR2  --Bug 5511353
                      ,x_ar_rec_notify_flag             VARCHAR2  -- 7508661 : EnC
                      ,x_auto_release_pwp_inv           VARCHAR2  -- 7508661 : EnC
                 )
   IS

    l_return_status  VARCHAR2(1);
  BEGIN

    UPDATE pa_projects
    SET
       project_id                      =     X_Project_Id,
       name                            =     X_Name,
       long_name                       =     X_Long_Name,
       segment1                        =     X_Segment1,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       project_type                    =     X_Project_Type,
       carrying_out_organization_id    =     X_Carrying_Out_Organization_Id,
       public_sector_flag              =     X_Public_Sector_Flag,
-- Commented for Bug 3605235
       --project_status_code             =     X_Project_Status_Code,
       description                     =     X_Description,
       start_date                      =     X_Start_Date,
       completion_date                 =     X_Completion_Date,
       closed_date                     =     X_Closed_Date,
       distribution_rule               =     X_Distribution_Rule,
       labor_invoice_format_id         =     X_Labor_Invoice_Format_Id,
       non_labor_invoice_format_id     =     X_NL_Invoice_Format_Id,
       retention_invoice_format_id     =     X_Retention_Invoice_Format_Id,
       retention_percentage            =     X_Retention_Percentage,
       billing_offset                  =     X_Billing_Offset,
       billing_cycle_id                =     X_Billing_Cycle_Id,
       labor_std_bill_rate_schdl       =     X_Labor_Std_Bill_Rate_Schdl,
       labor_bill_rate_org_id          =     X_Labor_Bill_Rate_Org_Id,
       labor_schedule_fixed_date       =     X_Labor_Schedule_Fixed_Date,
       labor_schedule_discount         =     X_Labor_Schedule_Discount,
       non_labor_std_bill_rate_schdl   =     X_NL_Std_Bill_Rate_Schdl,
       non_labor_bill_rate_org_id      =     X_NL_Bill_Rate_Org_Id,
       non_labor_schedule_fixed_date   =     X_NL_Schedule_Fixed_Date,
       non_labor_schedule_discount     =     X_NL_Schedule_Discount,
       limit_to_txn_controls_flag      =     X_Limit_To_Txn_Controls_Flag,
       project_level_funding_flag      =     X_Project_Level_Funding_Flag,
       invoice_comment                 =     X_Invoice_Comment,
       unbilled_receivable_dr          =     X_Unbilled_Receivable_Dr,
       unearned_revenue_cr             =     X_Unearned_Revenue_Cr,
       summary_flag                    =     X_Summary_Flag,
       enabled_flag                    =     X_Enabled_Flag,
       segment2                        =     X_Segment2,
       segment3                        =     X_Segment3,
       segment4                        =     X_Segment4,
       segment5                        =     X_Segment5,
       segment6                        =     X_Segment6,
       segment7                        =     X_Segment7,
       segment8                        =     X_Segment8,
       segment9                        =     X_Segment9,
       segment10                       =     X_Segment10,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       cost_ind_rate_sch_id            =     X_Cost_Ind_Rate_Sch_Id,
       rev_ind_rate_sch_id             =     X_Rev_Ind_Rate_Sch_Id,
       inv_ind_rate_sch_id             =     X_Inv_Ind_Rate_Sch_Id,
       cost_ind_sch_fixed_date         =     X_Cost_Ind_Sch_Fixed_Date,
       rev_ind_sch_fixed_date          =     X_Rev_Ind_Sch_Fixed_Date,
       inv_ind_sch_fixed_date          =     X_Inv_Ind_Sch_Fixed_Date,
       labor_sch_type                  =     X_Labor_Sch_Type,
       non_labor_sch_type              =     X_Non_Labor_Sch_Type,
       template_flag                   =     X_Template_Flag,
       verification_date               =     X_Verification_Date,
       created_from_project_id         =     X_Created_From_Project_Id,
       template_start_date_active      =     X_Template_Start_Date,
       template_end_date_active        =     X_Template_End_Date,
--added to remove bug#594567 :ashia Bagai 6-jan-98
-- Commented for Bug 3605235
       --wf_Status_Code		       =     X_Wf_Status_Code,
--end of addition to remove bug#594567
       Project_Currency_Code           =     X_Project_Currency_Code,
       Allow_Cross_Charge_Flag         =     X_Allow_Cross_Charge_Flag,
       Project_Rate_Date               =     X_Project_Rate_Date,
       Project_Rate_Type               =     X_Project_Rate_Type,
       Output_Tax_Code                 =     X_Output_Tax_Code,
       Retention_Tax_Code              =     X_Retention_Tax_Code,
       CC_Process_Labor_Flag           =     X_CC_Process_Labor_Flag,
       Labor_Tp_Schedule_Id            =     X_Labor_Tp_Schedule_Id,
       Labor_Tp_Fixed_Date             =     X_Labor_Tp_Fixed_Date,
       CC_Process_NL_Flag              =     X_CC_Process_NL_Flag,
       Nl_Tp_Schedule_Id               =     X_Nl_Tp_Schedule_Id,
       Nl_Tp_Fixed_Date                =     X_Nl_Tp_Fixed_Date,
       CC_Tax_Task_Id                  =     X_CC_Tax_Task_Id,
       bill_job_group_id               =     X_bill_job_group_id,
       cost_job_group_id               =     x_cost_job_group_id,
       role_list_id                    =     x_role_list_id,
       work_type_id                    =     x_work_type_id,
       calendar_id                     =     x_calendar_id,
       location_id                     =     x_location_id,
       probability_member_id           =     x_probability_member_id,
       project_value                   =     x_project_value,
       expected_approval_date          =     x_expected_approval_date,
       initial_team_template_id        =     x_team_template_id,
       job_bill_rate_schedule_id       =     x_job_bill_rate_schedule_id,
       emp_bill_rate_schedule_id       =     x_emp_bill_rate_schedule_id,
--MCA Sakthi for MultiAgreementCurreny Project
       competence_match_wt             =     x_competence_match_wt,
       availability_match_wt         =     x_availability_match_wt,
       job_level_match_wt            =     x_job_level_match_wt,
       enable_automated_search       =     x_enable_automated_search,
       search_min_availability       =     x_search_min_availability,
       search_org_hier_id            =     x_search_org_hier_id,
       search_starting_org_id        =     x_search_starting_org_id,
       search_country_code           =     x_search_country_code,
       min_cand_score_reqd_for_nom   =     x_min_cand_score_reqd_for_nom,
       non_lab_std_bill_rt_sch_id    =     x_non_lab_std_bill_rt_sch_id,
       invproc_currency_type         =     x_invproc_currency_type,
       revproc_currency_code         =     x_revproc_currency_code,
       project_bil_rate_date_code    =     x_project_bil_rate_date_code,
       project_bil_rate_type         =     x_project_bil_rate_type,
       project_bil_rate_date         =     x_project_bil_rate_date,
       project_bil_exchange_rate     =     x_project_bil_exchange_rate,
       projfunc_currency_code        =     x_projfunc_currency_code,
       projfunc_bil_rate_date_code   =     x_projfunc_bil_rate_date_code,
       projfunc_bil_rate_type        =     x_projfunc_bil_rate_type,
       projfunc_bil_rate_date        =     x_projfunc_bil_rate_date,
       projfunc_bil_exchange_rate    =     x_projfunc_bil_exchange_rate,
       funding_rate_date_code        =     x_funding_rate_date_code,
       funding_rate_type             =     x_funding_rate_type,
       funding_rate_date             =     x_funding_rate_date,
       funding_exchange_rate         =     x_funding_exchange_rate,
       baseline_funding_flag         =     x_baseline_funding_flag,
       multi_currency_billing_flag   =     x_multi_currency_billing_flag,
       inv_by_bill_trans_curr_flag   =     x_inv_by_bill_trans_curr_flag,
       projfunc_cost_rate_type       =     x_projfunc_cost_rate_type,
       projfunc_cost_rate_date       =     x_projfunc_cost_rate_date,
--MCA Sakthi for MultiAgreementCurrency Project
--MCA
       assign_precedes_task      =     x_assign_precedes_task,
--Structure
       split_cost_from_workplan_flag = x_split_cost_from_wokplan_flag,
       split_cost_from_bill_flag     = x_split_cost_from_bill_flag,
--Structure
--Advertisement
       adv_action_set_id             = x_adv_action_set_id,
       start_adv_action_set_flag     = x_start_adv_action_set_flag,
--Advertisement
--Project Setup
       priority_code                 = x_priority_code,
--Project Setup
--Retention
       retn_billing_inv_format_id    = x_retn_billing_inv_format_id,
       retn_accounting_flag          = x_retn_accounting_flag,
--Retention
-- anlee
-- patchset K changes
       revaluate_funding_flag        = x_revaluate_funding_flag,
       include_gains_losses_flag     = x_include_gains_losses_flag,
       security_level              = x_security_level,
       labor_disc_reason_code      = x_labor_disc_reason_code,
       non_labor_disc_reason_code  = x_non_labor_disc_reason_code,
-- End of changes
       record_version_number         = x_record_version_number,
       btc_cost_base_rev_code      = x_btc_cost_base_rev_code,  /* Bug#2638968 */
       revtrans_currency_type      = x_revtrans_currency_type, /* R12 - Bug 4363092 */
--PA L
       asset_allocation_method     = x_asset_allocation_method,
       capital_event_processing    = x_capital_event_processing,
       cint_rate_sch_id            = x_cint_rate_sch_id,
       cint_eligible_flag          = x_cint_eligible_flag,
       cint_stop_date              = x_cint_stop_date,
--FP_M Changes. Tracking Bug 3279981
       enable_top_task_customer_flag = x_en_top_task_customer_flag,
       enable_top_task_inv_mth_flag = x_en_top_task_inv_mth_flag,
       revenue_accrual_method = x_revenue_accrual_method,
       invoice_method = x_invoice_method,
       projfunc_attr_for_ar_flag = x_projfunc_attr_for_ar_flag,
       sys_program_flag  = x_sys_program_flag,
       allow_multi_program_rollup=x_allow_multi_program_rollup,
       proj_req_res_format_id =x_proj_req_res_format_id,
       proj_asgmt_res_format_id =x_proj_asgmt_res_format_id,
       date_eff_funds_consumption = x_date_eff_funds_flag  -- Bug 5511353
      ,ar_rec_notify_flag   = x_ar_rec_notify_flag   -- 7508661 : EnC
      ,auto_release_pwp_inv = x_auto_release_pwp_inv -- 7508661 : EnC
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    -- anlee
    -- Added for intermedia search
    PA_PROJECT_CTX_SEARCH_PVT.UPDATE_ROW (
     p_project_id           => x_project_id
    ,p_template_flag        => x_template_flag
    ,p_project_name         => x_name
    ,p_project_number       => x_segment1
    ,p_project_long_name    => x_long_name
    ,p_project_description  => x_description
    ,x_return_status        => l_return_status );
    -- anlee end of changes

  END Update_Row;

  PROCEDURE Delete_Row(X_project_id NUMBER) IS

    CURSOR get_template_flag IS
    SELECT template_flag
    FROM PA_PROJECTS_ALL
    WHERE project_id = x_project_id;

    l_template_flag VARCHAR2(1);
    l_return_status VARCHAR2(1);
  BEGIN

    -- anlee
    -- Added for intermedia search
    OPEN get_template_flag;
    FETCH get_template_flag INTO l_template_flag;
    CLOSE get_template_flag;

    PA_PROJECT_CTX_SEARCH_PVT.DELETE_ROW (
     p_project_id           => x_project_id
    ,p_template_flag        => l_template_flag
    ,x_return_status        => l_return_status );
    -- anlee end of changes

    DELETE FROM pa_projects
    WHERE project_id = X_project_id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Delete_Row;


END PA_PROJECTS_PKG1;

/
