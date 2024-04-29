--------------------------------------------------------
--  DDL for Package PA_PROJECTS_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECTS_PKG1" AUTHID CURRENT_USER as
/* $Header: PAXPRO1S.pls 120.2.12010000.2 2008/10/27 16:38:52 atshukla ship $ */

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
                       X_NL_Invoice_Format_Id 	   	NUMBER,
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
                       X_Template_Start_Date  		DATE,
                       X_Template_End_Date    		DATE,
--added to remove bug#594567 : Ashia Bagai 6-jan-98
-- Commented for Bug 3605235
		       --X_Wf_Status_Code			VARCHAR2,
--End of addition toremove bug#594567
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
--   17-MAY-00  kkekkar     Added the following columns for CBGA project
--                            bill_job_group_id, cost_job_group_id
                     x_bill_job_group_id              NUMBER   ,
                     x_cost_job_group_id              NUMBER   ,
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
                       x_include_gains_losses_flag      VARCHAR2,
-- msundare
                       x_security_level                 NUMBER,
                       x_labor_disc_reason_code         VARCHAR2,
                       x_non_labor_disc_reason_code     VARCHAR2,
-- End of changes
                       x_record_version_number          NUMBER,
		       x_btc_cost_base_rev_code         VARCHAR2, /* Bug#2638968 */
                       x_revtrans_currency_type         VARCHAR2, /* R12 - Bug 4353092 */
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
                    );

  PROCEDURE Delete_Row(X_project_id NUMBER);

END PA_PROJECTS_PKG1;

/
