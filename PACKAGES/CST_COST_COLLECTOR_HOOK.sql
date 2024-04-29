--------------------------------------------------------
--  DDL for Package CST_COST_COLLECTOR_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_COST_COLLECTOR_HOOK" AUTHID CURRENT_USER as
/* $Header: CSTCCHKS.pls 115.3 2002/11/08 03:07:44 awwang ship $*/

PROCEDURE pm_invtxn_hook(
			         p_transaction_id		NUMBER,
			         p_organization_id		NUMBER,
			         p_transaction_action_id	NUMBER,
			         p_transaction_source_type_id	NUMBER,
			         p_type_class			NUMBER,
			         p_project_id			NUMBER,
			         p_task_id			NUMBER,
			         p_transaction_date		DATE,
			         p_primary_quantity		NUMBER,
				 p_cost_group_id		NUMBER,
				 p_transfer_cost_group_id	NUMBER,
		        	 p_inventory_item_id		NUMBER,
		        	 p_transaction_source_id	NUMBER,
			         p_to_project_id		NUMBER,
			         p_to_task_id			NUMBER,
			         p_source_project_id		NUMBER,
			         p_source_task_id		NUMBER,
			         p_transfer_transaction_id	NUMBER,
			         p_primary_cost_method		NUMBER,
			         p_acct_period_id		NUMBER,
			         p_exp_org_id			NUMBER,
			         p_distribution_account_id	NUMBER,
			         p_proj_job_ind		        NUMBER,
			         p_first_matl_se_exp_type	VARCHAR2,
			         p_inv_txn_source_literal	VARCHAR2,
			         p_cap_txn_source_literal	VARCHAR2,
				 p_inv_syslink_literal		VARCHAR2,
				 p_bur_syslink_literal		VARCHAR2,
				 p_wip_syslink_literal		VARCHAR2,
                                 p_user_def_exp_type            NUMBER,
				 p_transfer_organization_id     NUMBER,
				 p_flow_schedule		VARCHAR2,
				 p_si_asset_yes_no		NUMBER,
				 p_transfer_si_asset_yes_no	NUMBER,
                                 p_denom_currency_code          VARCHAR2,
                                 p_exp_type                     VARCHAR2,
                                 p_dr_code_combination_id       NUMBER,
	   	                 p_cr_code_combination_id       NUMBER,
                                 p_raw_cost                     NUMBER,
                                 p_burden_cost                  NUMBER,

                                 p_transaction_source           VARCHAR2,
                                 p_batch_name                   VARCHAR2,
                                 p_expenditure_ending_date      DATE,
                                 p_employee_number              VARCHAR2,
                                 p_organization_name            VARCHAR2,
                                 p_expenditure_item_date        DATE,
                                 p_project_number               VARCHAR2,
                                 p_task_number                  VARCHAR2,
                                 p_pa_quantity                  NUMBER,
                                 p_expenditure_comment          VARCHAR2,
                                 p_orig_transaction_reference   VARCHAR2,
                                 p_raw_cost_rate                NUMBER,
                                 p_unmatched_negative_txn_flag  VARCHAR2,
                                 p_gl_date                      DATE,
                                 p_org_id                       NUMBER,
                                 p_burdened_cost_rate           NUMBER,
                                 p_system_linkage               VARCHAR2,
                                 p_transaction_status_code      VARCHAR2,

                                 O_hook_used                OUT NOCOPY NUMBER,
                                 O_err_num                  OUT NOCOPY NUMBER,
                                 O_err_code                 OUT NOCOPY NUMBER,
                                 O_err_msg                  OUT NOCOPY NUMBER);
END CST_COST_COLLECTOR_HOOK;

 

/
