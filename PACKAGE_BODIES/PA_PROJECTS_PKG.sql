--------------------------------------------------------
--  DDL for Package Body PA_PROJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECTS_PKG" as
/* $Header: PAXPROJB.pls 120.4.12010000.2 2008/10/27 16:56:19 atshukla ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, -- 4537865
                       X_Project_Id                     IN OUT NOCOPY NUMBER, -- 4537865
                       x_org_id                         NUMBER, --R12: Bug 4363092
                       X_Name                           VARCHAR2,
                       X_Long_Name                      VARCHAR2,
                       X_Segment1                       VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Project_Type                   VARCHAR2,
                       X_Carrying_Out_Organization_Id   NUMBER,
                       X_Public_Sector_Flag             VARCHAR2,
                       X_Project_Status_Code            VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_Completion_Date                DATE,
                       X_Closed_Date                    DATE,
                       X_Distribution_Rule              VARCHAR2,
                       X_Labor_Invoice_Format_Id        NUMBER,
                       X_NL_Invoice_Format_Id	        NUMBER,
                       X_Retention_Invoice_Format_Id    NUMBER,
                       X_Retention_Percentage           NUMBER,
                       X_Billing_Offset                 NUMBER,
                       X_Billing_Cycle_Id               NUMBER,
                       X_Labor_Std_Bill_Rate_Schdl      VARCHAR2,
                       X_Labor_Bill_Rate_Org_Id         NUMBER,
                       X_Labor_Schedule_Fixed_Date      DATE,
                       X_Labor_Schedule_Discount        NUMBER,
                       X_NL_Std_Bill_Rate_Schdl   	VARCHAR2,
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
                       X_Template_Start_Date		DATE,
                       X_Template_End_Date    		DATE,
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
                       x_btc_cost_base_rev_code         VARCHAR2,  /* Bug#2638968 */
                       x_revtrans_currency_type         VARCHAR2,  /* R12 - Bug 4363092 */
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
		       --sunkalya:federal Bug#5511353
		       x_date_eff_funds_flag        VARCHAR2
		       --sunkalya:federal Bug#5511353
                      ,x_ar_rec_notify_flag             VARCHAR2  -- 7508661 : EnC
                      ,x_auto_release_pwp_inv           VARCHAR2  -- 7508661 : EnC
  ) IS
    CURSOR C IS SELECT rowid FROM pa_projects
                 WHERE project_id = X_Project_Id;
      CURSOR C2 IS SELECT pa_projects_s.nextval FROM sys.dual;

    l_return_status VARCHAR2(1);
   BEGIN
      if (X_Project_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Project_Id;
        CLOSE C2;
      end if;

       INSERT INTO pa_projects(
              project_id,
              org_id, --R12: Bug 4363092
              name,
              long_name,
              segment1,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              project_type,
              carrying_out_organization_id,
              public_sector_flag,
              project_status_code,
              description,
              start_date,
              completion_date,
              closed_date,
              distribution_rule,
              labor_invoice_format_id,
              non_labor_invoice_format_id,
              retention_invoice_format_id,
              retention_percentage,
              billing_offset,
              billing_cycle_id,
              labor_std_bill_rate_schdl,
              labor_bill_rate_org_id,
              labor_schedule_fixed_date,
              labor_schedule_discount,
              non_labor_std_bill_rate_schdl,
              non_labor_bill_rate_org_id,
              non_labor_schedule_fixed_date,
              non_labor_schedule_discount,
              limit_to_txn_controls_flag,
              project_level_funding_flag,
              invoice_comment,
              unbilled_receivable_dr,
              unearned_revenue_cr,
              summary_flag,
              enabled_flag,
              segment2,
              segment3,
              segment4,
              segment5,
              segment6,
              segment7,
              segment8,
              segment9,
              segment10,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              cost_ind_rate_sch_id,
              rev_ind_rate_sch_id,
              inv_ind_rate_sch_id,
              cost_ind_sch_fixed_date,
              rev_ind_sch_fixed_date,
              inv_ind_sch_fixed_date,
              labor_sch_type,
              non_labor_sch_type,
              template_flag,
              verification_date,
              created_from_project_id,
              template_start_date_active,
              template_end_date_active,
              Project_Currency_Code,
              Allow_Cross_Charge_Flag,
              Project_Rate_Date,
              Project_Rate_Type,
              Output_Tax_Code,
              Retention_Tax_Code,
				  CC_Process_Labor_Flag,
				  Labor_Tp_Schedule_Id,
				  Labor_Tp_Fixed_Date,
				  CC_Process_NL_Flag,
				  Nl_Tp_Schedule_Id,
				  Nl_Tp_Fixed_Date,
				  CC_Tax_Task_Id,
              bill_job_group_id,
              cost_job_group_id,
              role_list_id,
              work_type_id,
              calendar_id,
              location_id,
              probability_member_id,
              project_value,
              expected_approval_date,
              initial_team_template_id,
              job_bill_rate_schedule_id,
              emp_bill_rate_schedule_id,
--MCA Sakthi for MultiAgreementCurreny Project
                 competence_match_wt,
                 availability_match_wt,
                 job_level_match_wt,
                 enable_automated_search,
                 search_min_availability,
                 search_org_hier_id,
                 search_starting_org_id,
                 search_country_code,
                 min_cand_score_reqd_for_nom,
                 non_lab_std_bill_rt_sch_id,
                 invproc_currency_type,
                 revproc_currency_code,
                 project_bil_rate_date_code,
                 project_bil_rate_type,
                 project_bil_rate_date,
                 project_bil_exchange_rate,
                 projfunc_currency_code,
                 projfunc_bil_rate_date_code,
                 projfunc_bil_rate_type,
                 projfunc_bil_rate_date,
                 projfunc_bil_exchange_rate,
                 funding_rate_date_code,
                 funding_rate_type,
                 funding_rate_date,
                 funding_exchange_rate,
                 baseline_funding_flag,
                 projfunc_cost_rate_type,
                 projfunc_cost_rate_date,
                 multi_currency_billing_flag,
                 inv_by_bill_trans_curr_flag,
--MCA Sakthi for MultiAgreementCurreny Project
                 assign_precedes_task,
--Structure
                 split_cost_From_workplan_flag,
                 split_cost_from_bill_flag,
--Structure
--Advertisement
                 adv_action_set_id        ,
                 start_adv_action_set_flag,
--Advertisement
--Project Setup
                 priority_code,
--Project Setup
--Retention
                 retn_billing_inv_format_id,
                 retn_accounting_flag ,
--Retention
-- anlee
-- patchset K changes
                 revaluate_funding_flag,
                 include_gains_losses_flag,
-- msundare
                 security_level                 ,
                 labor_disc_reason_code         ,
                 non_labor_disc_reason_code     ,
-- End of changes
              record_version_number,
	      btc_cost_base_rev_code , /* Bug#2638968 */
              revtrans_currency_type, /* R12 - Bug 4363092 */
--PA L
              asset_allocation_method ,
              capital_event_processing,
              cint_rate_sch_id ,
              cint_eligible_flag,
              cint_stop_date,
--FP_M Changes. Tracking Bug 3279981
              enable_top_task_customer_flag,
              enable_top_task_inv_mth_flag,
              revenue_accrual_method,
              invoice_method,
              projfunc_attr_for_ar_flag,
              sys_program_flag,
              allow_multi_program_rollup,
              proj_req_res_format_id,
              proj_asgmt_res_format_id,
	      --sunkalya:federal Bug#5511353
	      date_eff_funds_consumption
	      --sunkalya:federal Bug#5511353
             ,ar_rec_notify_flag      -- 7508661 : EnC
             ,auto_release_pwp_inv    -- 7508661 : EnC
             )
	     VALUES (
              X_Project_Id,
              X_Org_id, --R12: Bug 4363092
              X_Name,
              X_Long_Name,
              X_Segment1,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Project_Type,
              X_Carrying_Out_Organization_Id,
              X_Public_Sector_Flag,
              X_Project_Status_Code,
              X_Description,
              X_Start_Date,
              X_Completion_Date,
              X_Closed_Date,
              X_Distribution_Rule,
              X_Labor_Invoice_Format_Id,
              X_NL_Invoice_Format_Id,
              X_Retention_Invoice_Format_Id,
              X_Retention_Percentage,
              X_Billing_Offset,
              X_Billing_Cycle_Id,
              X_Labor_Std_Bill_Rate_Schdl,
              X_Labor_Bill_Rate_Org_Id,
              X_Labor_Schedule_Fixed_Date,
              X_Labor_Schedule_Discount,
              X_NL_Std_Bill_Rate_Schdl,
              X_NL_Bill_Rate_Org_Id,
              X_NL_Schedule_Fixed_Date,
              X_NL_Schedule_Discount,
              X_Limit_To_Txn_Controls_Flag,
              X_Project_Level_Funding_Flag,
              X_Invoice_Comment,
              X_Unbilled_Receivable_Dr,
              X_Unearned_Revenue_Cr,
              X_Summary_Flag,
              X_Enabled_Flag,
              X_Segment2,
              X_Segment3,
              X_Segment4,
              X_Segment5,
              X_Segment6,
              X_Segment7,
              X_Segment8,
              X_Segment9,
              X_Segment10,
              X_Attribute_Category,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Cost_Ind_Rate_Sch_Id,
              X_Rev_Ind_Rate_Sch_Id,
              X_Inv_Ind_Rate_Sch_Id,
              X_Cost_Ind_Sch_Fixed_Date,
              X_Rev_Ind_Sch_Fixed_Date,
              X_Inv_Ind_Sch_Fixed_Date,
              X_Labor_Sch_Type,
              X_Non_Labor_Sch_Type,
              X_Template_Flag,
              X_Verification_Date,
              X_Created_From_Project_Id,
              X_Template_Start_Date,
              X_Template_End_Date,
              X_Project_Currency_Code,
              X_Allow_Cross_Charge_Flag,
              X_Project_Rate_Date,
              X_Project_Rate_Type,
              X_Output_Tax_Code,
              X_Retention_Tax_Code,
				  X_CC_Process_Labor_Flag,
				  X_Labor_Tp_Schedule_Id,
				  X_Labor_Tp_Fixed_Date,
				  X_CC_Process_NL_Flag,
				  X_Nl_Tp_Schedule_Id,
				  X_Nl_Tp_Fixed_Date,
				  X_CC_Tax_Task_Id,
              x_bill_job_group_id,
              x_cost_job_group_id,
              x_role_list_id,
              x_work_type_id,
              x_calendar_id,
              x_location_id,
              x_probability_member_id,
              x_project_value,
              x_expected_approval_date,
              x_team_template_id,
              x_job_bill_rate_schedule_id,
              x_emp_bill_rate_schedule_id,
--MCA Sakthi for MultiAgreementCurreny Project
              x_competence_match_wt,
              x_availability_match_wt,
              x_job_level_match_wt,
              x_enable_automated_search,
              x_search_min_availability,
              x_search_org_hier_id,
              x_search_starting_org_id,
              x_search_country_code,
              x_min_cand_score_reqd_for_nom,
              x_non_lab_std_bill_rt_sch_id,
              x_invproc_currency_type,
              x_revproc_currency_code,
              x_project_bil_rate_date_code,
              x_project_bil_rate_type,
              x_project_bil_rate_date,
              x_project_bil_exchange_rate,
              x_projfunc_currency_code,
              x_projfunc_bil_rate_date_code,
              x_projfunc_bil_rate_type,
              x_projfunc_bil_rate_date,
              x_projfunc_bil_exchange_rate,
              x_funding_rate_date_code,
              x_funding_rate_type,
              x_funding_rate_date,
              x_funding_exchange_rate,
              x_baseline_funding_flag,
              x_projfunc_cost_rate_type,
              x_projfunc_cost_rate_date,
              x_multi_currency_billing_flag,
              x_inv_by_bill_trans_curr_flag,
--MCA Sakthi for MultiAgreementCurreny Project
              x_assign_precedes_task,
--Structure
              x_split_cost_from_wokplan_flag,
              x_split_cost_from_bill_flag,
--Structure
--Advertisement
              x_adv_action_set_id        ,
              x_start_adv_action_set_flag,
--Advertisement
--Project Setup
              x_priority_code,
--Project Setup
--Retention
              x_retn_billing_inv_format_id  ,
              x_retn_accounting_flag        ,
--Retention
-- anlee
-- patchset K changes
                 x_revaluate_funding_flag,
                 x_include_gains_losses_flag,
-- msundare
                 x_security_level                 ,
                 x_labor_disc_reason_code         ,
                 x_non_labor_disc_reason_code     ,
-- End of changes
              x_record_version_number,
	      x_btc_cost_base_rev_code,   /* Bug#2638968 */
              x_revtrans_currency_type, /* R12 - Bug 4363092 */
--PA L
              x_asset_allocation_method ,
              x_capital_event_processing,
              x_cint_rate_sch_id ,
              x_cint_eligible_flag,
              x_cint_stop_date,
--FP_M Changes. Tracking Bug 3279981
                       x_en_top_task_customer_flag,
                       x_en_top_task_inv_mth_flag,
                       x_revenue_accrual_method,
                       x_invoice_method,
                       x_projfunc_attr_for_ar_flag,
                       x_sys_program_flag,
                       x_allow_multi_program_rollup,
                       x_proj_req_res_format_id,
                       x_proj_asgmt_res_format_id,
		       --sunkalya:federal Bug#5511353
		       x_date_eff_funds_flag
		       --sunkalya:federal Bug#5511353
                      ,x_ar_rec_notify_flag     -- 7508661 : EnC
                      ,x_auto_release_pwp_inv   -- 7508661 : EnC
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

    -- anlee
    -- Added for intermedia search
    PA_PROJECT_CTX_SEARCH_PVT.INSERT_ROW (
     p_project_id           => x_project_id
    ,p_template_flag        => x_template_flag
    ,p_project_name         => x_name
    ,p_project_number       => x_segment1
    ,p_project_long_name    => x_long_name
    ,p_project_description  => x_description
    ,x_return_status        => l_return_status );
    -- anlee end of changes

  EXCEPTION -- 4537865 Included Exception Block
  WHEN OTHERS THEN
	X_Rowid := NULL ;
	X_Project_Id := NULL;
	Fnd_Msg_Pub.add_exc_msg(p_pkg_name        => 'PA_PROJECTS_PKG'
				,p_procedure_name => 'Insert_Row'
				,p_error_text     => SUBSTRB(SQLERRM,1,240));
	RAISE;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Project_Id                       NUMBER,
                     X_Name                             VARCHAR2,
                     X_Long_Name                        VARCHAR2,
                     X_Segment1                         VARCHAR2,
                     X_Project_Type                     VARCHAR2,
                     X_Carrying_Out_Organization_Id     NUMBER,
                     X_Public_Sector_Flag               VARCHAR2,
                     X_Project_Status_Code              VARCHAR2,
                     X_Description                      VARCHAR2,
                     X_Start_Date                       DATE,
                     X_Completion_Date                  DATE,
                     X_Closed_Date                      DATE,
                     X_Distribution_Rule                VARCHAR2,
                     X_Labor_Invoice_Format_Id          NUMBER,
                     X_NL_Invoice_Format_Id	        NUMBER,
                     X_Retention_Invoice_Format_Id      NUMBER,
                     X_Retention_Percentage             NUMBER,
                     X_Billing_Offset                   NUMBER,
                     X_Billing_Cycle_Id                 NUMBER,
                     X_Labor_Std_Bill_Rate_Schdl        VARCHAR2,
                     X_Labor_Bill_Rate_Org_Id           NUMBER,
                     X_Labor_Schedule_Fixed_Date        DATE,
                     X_Labor_Schedule_Discount          NUMBER,
                     X_NL_Std_Bill_Rate_Schdl		VARCHAR2,
                     X_NL_Bill_Rate_Org_Id      	NUMBER,
                     X_NL_Schedule_Fixed_Date    	DATE,
                     X_NL_Schedule_Discount      	NUMBER,
                     X_Limit_To_Txn_Controls_Flag       VARCHAR2,
                     X_Project_Level_Funding_Flag       VARCHAR2,
                     X_Invoice_Comment                  VARCHAR2,
                     X_Unbilled_Receivable_Dr           NUMBER,
                     X_Unearned_Revenue_Cr              NUMBER,
                     X_Summary_Flag                     VARCHAR2,
                     X_Enabled_Flag                     VARCHAR2,
                     X_Segment2                         VARCHAR2,
                     X_Segment3                         VARCHAR2,
                     X_Segment4                         VARCHAR2,
                     X_Segment5                         VARCHAR2,
                     X_Segment6                         VARCHAR2,
                     X_Segment7                         VARCHAR2,
                     X_Segment8                         VARCHAR2,
                     X_Segment9                         VARCHAR2,
                     X_Segment10                        VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Cost_Ind_Rate_Sch_Id             NUMBER,
                     X_Rev_Ind_Rate_Sch_Id              NUMBER,
                     X_Inv_Ind_Rate_Sch_Id              NUMBER,
                     X_Cost_Ind_Sch_Fixed_Date          DATE,
                     X_Rev_Ind_Sch_Fixed_Date           DATE,
                     X_Inv_Ind_Sch_Fixed_Date           DATE,
                     X_Labor_Sch_Type                   VARCHAR2,
                     X_Non_Labor_Sch_Type               VARCHAR2,
                     X_Template_Flag                    VARCHAR2,
                     X_Verification_Date                DATE,
                     X_Created_From_Project_Id          NUMBER,
                     X_Template_Start_Date    		DATE,
                     X_Template_End_Date      		DATE,
                     X_Project_Currency_Code         VARCHAR2,
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
                     x_project_value              NUMBER,
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
                       x_assign_precedes_task       VARCHAR2,
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
		     x_btc_cost_base_rev_code         VARCHAR2,
                     x_revtrans_currency_type         VARCHAR2,     /* R12 - Bug 4363092 */
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
		        --sunkalya:federal Bug#5511353
		       x_date_eff_funds_flag        VARCHAR2
		       --sunkalya:federal Bug#5511353
                      ,x_ar_rec_notify_flag             VARCHAR2  -- 7508661 : EnC
                      ,x_auto_release_pwp_inv           VARCHAR2  -- 7508661 : EnC
  ) IS
    CURSOR C IS
        SELECT *
        FROM   pa_projects
        WHERE  rowid = X_Rowid
        FOR UPDATE of Project_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if Recinfo.record_version_number <> x_record_version_number
    then
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    if (
               (Recinfo.project_id =  X_Project_Id)
           AND (Recinfo.name =  X_Name)
           AND (Recinfo.long_name =  X_Long_Name)
           AND (Recinfo.segment1 =  X_Segment1)
           AND (Recinfo.project_type =  X_Project_Type)
           AND (Recinfo.carrying_out_organization_id =
			 X_Carrying_Out_Organization_Id)
           AND (Recinfo.public_sector_flag =  X_Public_Sector_Flag)
           AND (Recinfo.project_status_code =  X_Project_Status_Code)
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.start_date =  X_Start_Date)
                OR (    (Recinfo.start_date IS NULL)
                    AND (X_Start_Date IS NULL)))
           AND (   (Recinfo.completion_date =  X_Completion_Date)
                OR (    (Recinfo.completion_date IS NULL)
                    AND (X_Completion_Date IS NULL)))
--changed to remove bug# 609287 by Ashia Bagai on 27-jan-98
           AND (   (TRUNC(Recinfo.closed_date) =  TRUNC(X_Closed_Date))
--           AND (   (Recinfo.closed_date =  X_Closed_Date)
--end of change to remove bug# 609287
                OR (    (Recinfo.closed_date IS NULL)
                    AND (X_Closed_Date IS NULL)))
           AND (   (Recinfo.distribution_rule =  X_Distribution_Rule)
                OR (    (Recinfo.distribution_rule IS NULL)
                    AND (X_Distribution_Rule IS NULL)))
           AND (   (Recinfo.labor_invoice_format_id =
			X_Labor_Invoice_Format_Id)
                OR (    (Recinfo.labor_invoice_format_id IS NULL)
                    AND (X_Labor_Invoice_Format_Id IS NULL)))
           AND (   (Recinfo.non_labor_invoice_format_id =
			X_NL_Invoice_Format_Id)
                OR (    (Recinfo.non_labor_invoice_format_id IS NULL)
                    AND (X_NL_Invoice_Format_Id IS NULL)))
           AND (   (Recinfo.retention_invoice_format_id =
			 X_Retention_Invoice_Format_Id)
                OR (    (Recinfo.retention_invoice_format_id IS NULL)
                    AND (X_Retention_Invoice_Format_Id IS NULL)))
           AND (   (Recinfo.retention_percentage =  X_Retention_Percentage)
                OR (    (Recinfo.retention_percentage IS NULL)
                    AND (X_Retention_Percentage IS NULL)))
           AND (   (Recinfo.billing_offset =  X_Billing_Offset)
                OR (    (Recinfo.billing_offset IS NULL)
                    AND (X_Billing_Offset IS NULL)))
           AND (   (Recinfo.billing_cycle_id =  X_Billing_Cycle_Id)
                OR (    (Recinfo.billing_cycle_id IS NULL)
                    AND (X_Billing_Cycle_Id IS NULL)))
           AND (   (Recinfo.labor_std_bill_rate_schdl =
			 X_Labor_Std_Bill_Rate_Schdl)
                OR (    (Recinfo.labor_std_bill_rate_schdl IS NULL)
                    AND (X_Labor_Std_Bill_Rate_Schdl IS NULL)))
           AND (   (Recinfo.labor_bill_rate_org_id =  X_Labor_Bill_Rate_Org_Id)
                OR (    (Recinfo.labor_bill_rate_org_id IS NULL)
                    AND (X_Labor_Bill_Rate_Org_Id IS NULL)))
           AND (   (Recinfo.labor_schedule_fixed_date =
			 X_Labor_Schedule_Fixed_Date)
                OR (    (Recinfo.labor_schedule_fixed_date IS NULL)
                    AND (X_Labor_Schedule_Fixed_Date IS NULL)))
           AND (   (Recinfo.labor_schedule_discount =
			X_Labor_Schedule_Discount)
                OR (    (Recinfo.labor_schedule_discount IS NULL)
                    AND (X_Labor_Schedule_Discount IS NULL)))
           AND (   (Recinfo.non_labor_std_bill_rate_schdl =
			 X_NL_Std_Bill_Rate_Schdl)
                OR (    (Recinfo.non_labor_std_bill_rate_schdl IS NULL)
                    AND (X_NL_Std_Bill_Rate_Schdl IS NULL)))
           AND (   (Recinfo.non_labor_bill_rate_org_id =
			 X_NL_Bill_Rate_Org_Id)
                OR (    (Recinfo.non_labor_bill_rate_org_id IS NULL)
                    AND (X_NL_Bill_Rate_Org_Id IS NULL)))
           AND (   (Recinfo.non_labor_schedule_fixed_date =
		    	 X_NL_Schedule_Fixed_Date)
                OR (    (Recinfo.non_labor_schedule_fixed_date IS NULL)
                    AND (X_NL_Schedule_Fixed_Date IS NULL)))
           AND (   (Recinfo.non_labor_schedule_discount =
			 X_NL_Schedule_Discount)
                OR (    (Recinfo.non_labor_schedule_discount IS NULL)
                    AND (X_NL_Schedule_Discount IS NULL)))
           AND (   (Recinfo.limit_to_txn_controls_flag =
			 X_Limit_To_Txn_Controls_Flag)
                OR (    (Recinfo.limit_to_txn_controls_flag IS NULL)
                    AND (X_Limit_To_Txn_Controls_Flag IS NULL)))
           AND (   (Recinfo.project_level_funding_flag =
			 X_Project_Level_Funding_Flag)
                OR (    (Recinfo.project_level_funding_flag IS NULL)
                    AND (X_Project_Level_Funding_Flag IS NULL)))
           AND (   (Recinfo.invoice_comment =  X_Invoice_Comment)
                OR (    (Recinfo.invoice_comment IS NULL)
                    AND (X_Invoice_Comment IS NULL)))
           AND (   (Recinfo.unbilled_receivable_dr =  X_Unbilled_Receivable_Dr)
                OR (    (Recinfo.unbilled_receivable_dr IS NULL)
                    AND (X_Unbilled_Receivable_Dr IS NULL)))
           AND (   (Recinfo.unearned_revenue_cr =  X_Unearned_Revenue_Cr)
                OR (    (Recinfo.unearned_revenue_cr IS NULL)
                    AND (X_Unearned_Revenue_Cr IS NULL)))
           AND (Recinfo.summary_flag =  X_Summary_Flag)
           AND (Recinfo.enabled_flag =  X_Enabled_Flag)
           AND (   (Recinfo.segment2 =  X_Segment2)
                OR (    (Recinfo.segment2 IS NULL)
                    AND (X_Segment2 IS NULL)))
           AND (   (Recinfo.segment3 =  X_Segment3)
                OR (    (Recinfo.segment3 IS NULL)
                    AND (X_Segment3 IS NULL)))
           AND (   (Recinfo.segment4 =  X_Segment4)
                OR (    (Recinfo.segment4 IS NULL)
                    AND (X_Segment4 IS NULL)))
           AND (   (Recinfo.segment5 =  X_Segment5)
                OR (    (Recinfo.segment5 IS NULL)
                    AND (X_Segment5 IS NULL)))
           AND (   (Recinfo.segment6 =  X_Segment6)
                OR (    (Recinfo.segment6 IS NULL)
                    AND (X_Segment6 IS NULL)))
           AND (   (Recinfo.segment7 =  X_Segment7)
                OR (    (Recinfo.segment7 IS NULL)
                    AND (X_Segment7 IS NULL)))
           AND (   (Recinfo.segment8 =  X_Segment8)
                OR (    (Recinfo.segment8 IS NULL)
                    AND (X_Segment8 IS NULL)))
           AND (   (Recinfo.segment9 =  X_Segment9)
                OR (    (Recinfo.segment9 IS NULL)
                    AND (X_Segment9 IS NULL)))
           AND (   (Recinfo.segment10 =  X_Segment10)
                OR (    (Recinfo.segment10 IS NULL)
                    AND (X_Segment10 IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.cost_ind_rate_sch_id =  X_Cost_Ind_Rate_Sch_Id)
                OR (    (Recinfo.cost_ind_rate_sch_id IS NULL)
                    AND (X_Cost_Ind_Rate_Sch_Id IS NULL)))
           AND (   (Recinfo.rev_ind_rate_sch_id =  X_Rev_Ind_Rate_Sch_Id)
                OR (    (Recinfo.rev_ind_rate_sch_id IS NULL)
                    AND (X_Rev_Ind_Rate_Sch_Id IS NULL)))
           AND (   (Recinfo.inv_ind_rate_sch_id =  X_Inv_Ind_Rate_Sch_Id)
                OR (    (Recinfo.inv_ind_rate_sch_id IS NULL)
                    AND (X_Inv_Ind_Rate_Sch_Id IS NULL)))
           AND (   (Recinfo.cost_ind_sch_fixed_date =
			X_Cost_Ind_Sch_Fixed_Date)
                OR (    (Recinfo.cost_ind_sch_fixed_date IS NULL)
                    AND (X_Cost_Ind_Sch_Fixed_Date IS NULL)))
           AND (   (Recinfo.rev_ind_sch_fixed_date =  X_Rev_Ind_Sch_Fixed_Date)
                OR (    (Recinfo.rev_ind_sch_fixed_date IS NULL)
                    AND (X_Rev_Ind_Sch_Fixed_Date IS NULL)))
           AND (   (Recinfo.inv_ind_sch_fixed_date =  X_Inv_Ind_Sch_Fixed_Date)
                OR (    (Recinfo.inv_ind_sch_fixed_date IS NULL)
                    AND (X_Inv_Ind_Sch_Fixed_Date IS NULL)))
           AND (   (Recinfo.labor_sch_type =  X_Labor_Sch_Type)
                OR (    (Recinfo.labor_sch_type IS NULL)
                    AND (X_Labor_Sch_Type IS NULL)))
	)
    then
	   if ((   (Recinfo.non_labor_sch_type =  X_Non_Labor_Sch_Type)
                OR (    (Recinfo.non_labor_sch_type IS NULL)
                    AND (X_Non_Labor_Sch_Type IS NULL)))
              AND (   (Recinfo.template_flag =  X_Template_Flag)
                OR (    (Recinfo.template_flag IS NULL)
                    AND (X_Template_Flag IS NULL)))
              AND (   (Recinfo.verification_date =  X_Verification_Date)
                OR (    (Recinfo.verification_date IS NULL)
                    AND (X_Verification_Date IS NULL)))
              AND (   (Recinfo.created_from_project_id =
			 X_Created_From_Project_Id)
                OR (    (Recinfo.created_from_project_id IS NULL)
                    AND (X_Created_From_Project_Id IS NULL)))
              AND (   (Recinfo.template_start_date_active =
			 X_Template_Start_Date)
                OR (    (Recinfo.template_start_date_active IS NULL)
                    AND (X_Template_Start_Date IS NULL)))
              AND (   (Recinfo.template_end_date_active =
			X_Template_End_Date)
                OR (    (Recinfo.template_end_date_active IS NULL)
                    AND (X_Template_End_Date IS NULL)))
              AND (   (Recinfo.Project_Currency_Code =
         X_Project_Currency_Code)
                OR (    (Recinfo.Project_Currency_Code IS NULL)
                    AND (X_Project_Currency_Code IS NULL)))
              AND (   (Recinfo.Allow_Cross_Charge_Flag =
         X_Allow_Cross_Charge_Flag)
                OR (    (Recinfo.Allow_Cross_Charge_Flag IS NULL)
                    AND (X_Allow_Cross_Charge_Flag IS NULL)))
              AND (   (Recinfo.Project_Rate_Date =
         X_Project_Rate_Date)
                OR (    (Recinfo.Project_Rate_Date IS NULL)
                    AND (X_Project_Rate_Date IS NULL)))
              AND (   (Recinfo.Project_Rate_Type =
         X_Project_Rate_Type)
                OR (    (Recinfo.Project_Rate_Type IS NULL)
                    AND (X_Project_Rate_Type IS NULL)))
             AND (   (Recinfo.Output_Tax_Code =
         X_Output_Tax_Code)
                OR (    (Recinfo.Output_Tax_Code IS NULL)
                    AND (X_Output_Tax_Code IS NULL)))
             AND (   (Recinfo.Retention_Tax_Code =
         X_Retention_Tax_Code)
                OR (    (Recinfo.Retention_Tax_Code IS NULL)
                    AND (X_Retention_Tax_Code IS NULL)))
             AND (   (Recinfo.CC_Process_Labor_Flag =
         X_CC_Process_Labor_Flag)
                OR (    (Recinfo.CC_Process_Labor_Flag IS NULL)
                    AND (X_CC_Process_Labor_Flag IS NULL)))
             AND (   (Recinfo.Labor_Tp_Schedule_Id =
         X_Labor_Tp_Schedule_Id)
                OR (    (Recinfo.Labor_Tp_Schedule_Id IS NULL)
                    AND (X_Labor_Tp_Schedule_Id IS NULL)))
             AND (   (Recinfo.Labor_Tp_Fixed_Date =
         X_Labor_Tp_Fixed_Date)
                OR (    (Recinfo.Labor_Tp_Fixed_Date IS NULL)
                    AND (X_Labor_Tp_Fixed_Date IS NULL)))
             AND (   (Recinfo.CC_Process_NL_Flag =
         X_CC_Process_NL_Flag)
                OR (    (Recinfo.CC_Process_NL_Flag IS NULL)
                    AND (X_CC_Process_NL_Flag IS NULL)))
             AND (   (Recinfo.Nl_Tp_Schedule_Id =
         X_Nl_Tp_Schedule_Id)
                OR (    (Recinfo.Nl_Tp_Schedule_Id IS NULL)
                    AND (X_Nl_Tp_Schedule_Id IS NULL)))
             AND (   (Recinfo.Nl_Tp_Fixed_Date =
         X_Nl_Tp_Fixed_Date)
                OR (    (Recinfo.Nl_Tp_Fixed_Date IS NULL)
                    AND (X_Nl_Tp_Fixed_Date IS NULL)))
             AND (   (Recinfo.CC_Tax_Task_Id =
         X_CC_Tax_Task_Id)
                OR (    (Recinfo.CC_Tax_Task_Id IS NULL)
                    AND (X_CC_Tax_Task_Id IS NULL)))
             AND (   (Recinfo.bill_job_group_id =
         X_bill_job_group_id )
                OR (    (Recinfo.bill_job_group_id IS NULL )
                    AND (X_bill_job_group_id IS NULL )))
            AND (    (Recinfo.cost_job_group_id =
         X_cost_job_group_id )
                OR (    (Recinfo.cost_job_group_id IS NULL )
                   AND ( X_cost_job_group_id IS NULL )))
            AND (    (Recinfo.role_list_id =
         X_role_list_id )
                OR (    (Recinfo.role_list_id IS NULL )
                   AND ( X_role_list_id IS NULL )))
            AND (    (Recinfo.work_type_id =
         X_work_type_id )
                OR (    (Recinfo.work_type_id IS NULL )
                   AND ( X_work_type_id IS NULL )))
            AND (    (Recinfo.calendar_id =
         X_calendar_id )
                OR (    (Recinfo.calendar_id IS NULL )
                   AND ( X_calendar_id IS NULL )))
            AND (    (Recinfo.location_id =
         X_location_id )
                OR (    (Recinfo.location_id IS NULL )
                   AND ( X_location_id IS NULL )))
            AND (    (Recinfo.probability_member_id =
         X_probability_member_id )
                OR (    (Recinfo.probability_member_id IS NULL )
                   AND ( X_probability_member_id IS NULL )))
            AND (    (Recinfo.project_value =
         X_project_value )
                OR (    (Recinfo.project_value IS NULL )
                   AND ( X_project_value IS NULL )))
            AND (    (Recinfo.expected_approval_date =
         X_expected_approval_date )
                OR (    (Recinfo.expected_approval_date IS NULL )
                   AND ( X_expected_approval_date IS NULL )))
            AND (    (Recinfo.initial_team_template_id =
         x_team_template_id )
                OR (    (Recinfo.initial_team_template_id IS NULL )
                   AND ( x_team_template_id IS NULL )))
            AND (    (Recinfo.job_bill_rate_schedule_id =
         x_job_bill_rate_schedule_id )
                OR (    (Recinfo.job_bill_rate_schedule_id IS NULL )
                   AND ( x_job_bill_rate_schedule_id IS NULL )))
            AND (    (Recinfo.emp_bill_rate_schedule_id =
         x_emp_bill_rate_schedule_id )
                OR (    (Recinfo.emp_bill_rate_schedule_id IS NULL )
                   AND ( x_emp_bill_rate_schedule_id IS NULL )))
--MCA Sakthi for MultiAgreementCurreny Project
            AND (    (Recinfo.competence_match_wt =
         x_competence_match_wt )
                OR (    (Recinfo.competence_match_wt IS NULL )
                   AND ( x_competence_match_wt IS NULL )))
            AND (    (Recinfo.availability_match_wt =
         x_availability_match_wt )
                OR (    (Recinfo.availability_match_wt IS NULL )
                   AND ( x_availability_match_wt IS NULL )))
            AND (    (Recinfo.job_level_match_wt =
         x_job_level_match_wt )
                OR (    (Recinfo.job_level_match_wt IS NULL )
                   AND ( x_job_level_match_wt IS NULL )))
            AND (    (Recinfo.enable_automated_search =
         x_enable_automated_search )
                OR (    (Recinfo.enable_automated_search IS NULL )
                   AND ( x_enable_automated_search IS NULL )))
            AND (    (Recinfo.search_min_availability =
         x_search_min_availability )
                OR (    (Recinfo.search_min_availability IS NULL )
                   AND ( x_search_min_availability IS NULL )))
            AND (    (Recinfo.search_org_hier_id =
         x_search_org_hier_id )
                OR (    (Recinfo.search_org_hier_id IS NULL )
                   AND ( x_search_org_hier_id IS NULL )))
            AND (    (Recinfo.search_starting_org_id =
         x_search_starting_org_id )
                OR (    (Recinfo.search_starting_org_id IS NULL )
                   AND ( x_search_starting_org_id IS NULL )))
            AND (    (Recinfo.search_country_code =
         x_search_country_code )
                OR (    (Recinfo.search_country_code IS NULL )
                   AND ( x_search_country_code IS NULL )))
            AND (    (Recinfo.min_cand_score_reqd_for_nom =
         x_min_cand_score_reqd_for_nom )
                OR (    (Recinfo.min_cand_score_reqd_for_nom IS NULL )
                   AND ( x_min_cand_score_reqd_for_nom IS NULL )))
            AND (    (Recinfo.non_lab_std_bill_rt_sch_id =
         x_non_lab_std_bill_rt_sch_id )
                OR (    (Recinfo.non_lab_std_bill_rt_sch_id IS NULL )
                   AND ( x_non_lab_std_bill_rt_sch_id IS NULL )))
            AND (    (Recinfo.invproc_currency_type =
         x_invproc_currency_type )
                OR (    (Recinfo.invproc_currency_type IS NULL )
                   AND ( x_invproc_currency_type IS NULL )))
            AND (    (Recinfo.revproc_currency_code =
         x_revproc_currency_code )
                OR (    (Recinfo.revproc_currency_code IS NULL )
                   AND ( x_revproc_currency_code IS NULL )))
            AND (    (Recinfo.project_bil_rate_date_code =
         x_project_bil_rate_date_code )
                OR (    (Recinfo.project_bil_rate_date_code IS NULL )
                   AND ( x_project_bil_rate_date_code IS NULL )))
            AND (    (Recinfo.project_bil_rate_type =
         x_project_bil_rate_type )
                OR (    (Recinfo.project_bil_rate_type IS NULL )
                   AND ( x_project_bil_rate_type IS NULL )))
            AND (    (Recinfo.project_bil_rate_date =
         x_project_bil_rate_date )
                OR (    (Recinfo.project_bil_rate_date IS NULL )
                   AND ( x_project_bil_rate_date IS NULL )))
            AND (    (Recinfo.project_bil_exchange_rate =
         x_project_bil_exchange_rate )
                OR (    (Recinfo.project_bil_exchange_rate IS NULL )
                   AND ( x_project_bil_exchange_rate IS NULL )))
            AND (    (Recinfo.projfunc_currency_code =
         x_projfunc_currency_code )
                OR (    (Recinfo.projfunc_currency_code IS NULL )
                   AND ( x_projfunc_currency_code IS NULL )))
            AND (    (Recinfo.projfunc_bil_rate_date_code =
         x_projfunc_bil_rate_date_code )
                OR (    (Recinfo.projfunc_bil_rate_date_code IS NULL )
                   AND ( x_projfunc_bil_rate_date_code IS NULL )))
            AND (    (Recinfo.projfunc_bil_rate_type =
         x_projfunc_bil_rate_type )
                OR (    (Recinfo.projfunc_bil_rate_type IS NULL )
                   AND ( x_projfunc_bil_rate_type IS NULL )))
            AND (    (Recinfo.projfunc_bil_rate_date =
         x_projfunc_bil_rate_date )
                OR (    (Recinfo.projfunc_bil_rate_date IS NULL )
                   AND ( x_projfunc_bil_rate_date IS NULL )))
            AND (    (Recinfo.projfunc_bil_exchange_rate =
         x_projfunc_bil_exchange_rate )
                OR (    (Recinfo.projfunc_bil_exchange_rate IS NULL )
                   AND ( x_projfunc_bil_exchange_rate IS NULL )))
            AND (    (Recinfo.funding_rate_date_code =
         x_funding_rate_date_code )
                OR (    (Recinfo.funding_rate_date_code IS NULL )
                   AND ( x_funding_rate_date_code IS NULL )))
            AND (    (Recinfo.funding_rate_type =
         x_funding_rate_type )
                OR (    (Recinfo.funding_rate_type IS NULL )
                   AND ( x_funding_rate_type IS NULL )))
            AND (    (Recinfo.funding_rate_date =
         x_funding_rate_date )
                OR (    (Recinfo.funding_rate_date IS NULL )
                   AND ( x_funding_rate_date IS NULL )))
            AND (    (Recinfo.funding_exchange_rate =
         x_funding_exchange_rate )
                OR (    (Recinfo.funding_exchange_rate IS NULL )
                   AND ( x_funding_exchange_rate IS NULL )))
            AND (    (Recinfo.baseline_funding_flag =
         x_baseline_funding_flag )
                OR (    (Recinfo.baseline_funding_flag IS NULL )
                   AND ( x_baseline_funding_flag IS NULL )))
            AND (    (Recinfo.projfunc_cost_rate_type =
         x_projfunc_cost_rate_type )
                OR (    (Recinfo.projfunc_cost_rate_type IS NULL )
                   AND ( x_projfunc_cost_rate_type IS NULL )))
            AND (    (Recinfo.projfunc_cost_rate_date =
         x_projfunc_cost_rate_date )
                OR (    (Recinfo.projfunc_cost_rate_date IS NULL )
                   AND ( x_projfunc_cost_rate_date IS NULL )))
            AND (    (Recinfo.multi_currency_billing_flag =
         x_multi_currency_billing_flag )
                OR (    (Recinfo.multi_currency_billing_flag IS NULL )
                   AND ( x_multi_currency_billing_flag IS NULL )))
            AND (    (Recinfo.btc_cost_base_rev_code =
         x_btc_cost_base_rev_code )
                OR (    (Recinfo.btc_cost_base_rev_code IS NULL )
                   AND ( x_btc_cost_base_rev_code IS NULL )))
-- R12 - Bug 4363092
            AND (    (Recinfo.revtrans_currency_type =
         x_revtrans_currency_type )
                OR (    (Recinfo.revtrans_currency_type IS NULL )
                   AND ( x_revtrans_currency_type IS NULL )))
-- R12 - Bug 4363092
            AND (    (Recinfo.inv_by_bill_trans_curr_flag =
         x_inv_by_bill_trans_curr_flag )
                OR (    (Recinfo.inv_by_bill_trans_curr_flag IS NULL )
                   AND ( x_inv_by_bill_trans_curr_flag IS NULL )))
--MCA Sakthi for MultiAgreementCurrency Project
            AND (    (Recinfo.assign_precedes_task =
         x_assign_precedes_task )
                OR (    (Recinfo.assign_precedes_task IS NULL )
                   AND ( x_assign_precedes_task IS NULL )))
--Structure
            AND (    (Recinfo.split_cost_from_workplan_flag  =
         x_split_cost_from_wokplan_flag )
                OR (    (Recinfo.split_cost_from_workplan_flag IS NULL )
                   AND ( x_split_cost_from_wokplan_flag IS NULL )))

            AND (    (Recinfo.split_cost_from_bill_flag =
         x_split_cost_from_bill_flag )
                OR (    (Recinfo.split_cost_from_bill_flag IS NULL )
                   AND ( x_split_cost_from_bill_flag IS NULL )))
--Structure
--Advertisement
            AND (    (Recinfo.adv_action_set_id  =
         x_adv_action_set_id )
                OR (    (Recinfo.adv_action_set_id IS NULL )
                   AND ( x_adv_action_set_id IS NULL )))

            AND (    (Recinfo.start_adv_action_set_flag =
         x_start_adv_action_set_flag )
                OR (    (Recinfo.start_adv_action_set_flag IS NULL )
                   AND ( x_start_adv_action_set_flag IS NULL )))
--Advertisement
--Project Setup
            AND (    (Recinfo.Priority_code =
         x_Priority_code )
                OR (    (Recinfo.Priority_code IS NULL )
                   AND ( x_Priority_code IS NULL )))
--Project Setup
--Retention
            AND (    (Recinfo.retn_billing_inv_format_id =
         x_retn_billing_inv_format_id )
                OR (    (Recinfo.retn_billing_inv_format_id IS NULL )
                   AND ( x_retn_billing_inv_format_id IS NULL )))

            AND (    (Recinfo.retn_accounting_flag =
         x_retn_accounting_flag )
                OR (    (Recinfo.retn_accounting_flag IS NULL )
                   AND ( x_retn_accounting_flag IS NULL )))
--Retention
-- anlee
-- patchset K changes
            AND (    (Recinfo.revaluate_funding_flag =
         x_revaluate_funding_flag )
                OR (    (Recinfo.revaluate_funding_flag IS NULL )
                   AND ( x_revaluate_funding_flag IS NULL )))

            AND (    (Recinfo.include_gains_losses_flag =
         x_include_gains_losses_flag )
                OR (    (Recinfo.include_gains_losses_flag IS NULL )
                   AND ( x_include_gains_losses_flag IS NULL )))
-- msundare
            AND (    (Recinfo.security_level = x_security_level )
                OR (    (Recinfo.security_level IS NULL )
                   AND ( x_security_level IS NULL )))

            AND (    (Recinfo.labor_disc_reason_code = x_labor_disc_reason_code )
                OR (    (Recinfo.labor_disc_reason_code IS NULL )
                   AND ( x_labor_disc_reason_code IS NULL )))

            AND (    (Recinfo.non_labor_disc_reason_code = x_non_labor_disc_reason_code )
                OR (    (Recinfo.non_labor_disc_reason_code IS NULL )
                   AND ( x_non_labor_disc_reason_code IS NULL )))
-- End of changes
--PA L changes
            AND (    (Recinfo.asset_allocation_method = x_asset_allocation_method )
                OR (    (Recinfo.asset_allocation_method IS NULL )
                   AND ( x_asset_allocation_method IS NULL )))

            AND (    (Recinfo.capital_event_processing = x_capital_event_processing )
                OR (    (Recinfo.capital_event_processing IS NULL )
                   AND ( x_capital_event_processing IS NULL )))

            AND (    (Recinfo.cint_rate_sch_id = x_cint_rate_sch_id )
                OR (    (Recinfo.cint_rate_sch_id IS NULL )
                   AND ( x_cint_rate_sch_id IS NULL )))

            AND (    (Recinfo.cint_eligible_flag = x_cint_eligible_flag )
                OR (    (Recinfo.cint_eligible_flag IS NULL )
                   AND ( x_cint_eligible_flag IS NULL )))

            AND (    (Recinfo.cint_stop_date = x_cint_stop_date )
                OR (    (Recinfo.cint_stop_date IS NULL )
                   AND ( x_cint_stop_date IS NULL )))

--FP_M Changes. Tracking Bug 3279981
            AND (    (Recinfo.enable_top_task_customer_flag = x_en_top_task_customer_flag )
                OR (    (Recinfo.enable_top_task_customer_flag IS NULL )
                   AND ( x_en_top_task_customer_flag IS NULL )))

            AND (    (Recinfo.enable_top_task_inv_mth_flag = x_en_top_task_inv_mth_flag )
                OR (    (Recinfo.enable_top_task_inv_mth_flag IS NULL )
                   AND ( x_en_top_task_inv_mth_flag IS NULL )))

            AND (    (Recinfo.revenue_accrual_method = x_revenue_accrual_method )
                OR (    (Recinfo.revenue_accrual_method IS NULL )
                   AND ( x_revenue_accrual_method IS NULL )))

            AND (    (Recinfo.invoice_method = x_invoice_method )
                OR (    (Recinfo.invoice_method IS NULL )
                   AND ( x_invoice_method IS NULL )))

            AND (    (Recinfo.projfunc_attr_for_ar_flag = x_projfunc_attr_for_ar_flag )
                OR (    (Recinfo.projfunc_attr_for_ar_flag IS NULL )
                   AND ( x_projfunc_attr_for_ar_flag IS NULL )))

--sunkalya:federal changes Bug#5511353
	    AND (    (Recinfo.date_eff_funds_consumption = x_date_eff_funds_flag )
                OR (    (Recinfo.date_eff_funds_consumption IS NULL )
                   AND ( x_date_eff_funds_flag IS NULL )))
--sunkalya:federal changes	Bug#5511353

        /* 7508661 : EnC : Start */
        AND (    (Recinfo.ar_rec_notify_flag = x_ar_rec_notify_flag )
                OR (    (Recinfo.ar_rec_notify_flag IS NULL )
                   AND ( x_ar_rec_notify_flag IS NULL )))
        AND (    (Recinfo.auto_release_pwp_inv = x_auto_release_pwp_inv )
                OR (    (Recinfo.auto_release_pwp_inv IS NULL )
                   AND ( x_auto_release_pwp_inv IS NULL )))
        /* 7508661 : EnC : End */

       )
	    then
		      return;
	    else
		      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		      APP_EXCEPTION.Raise_Exception;
	    end if;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


END PA_PROJECTS_PKG;

/
