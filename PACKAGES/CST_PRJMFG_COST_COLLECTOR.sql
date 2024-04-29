--------------------------------------------------------
--  DDL for Package CST_PRJMFG_COST_COLLECTOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PRJMFG_COST_COLLECTOR" AUTHID CURRENT_USER as
/* $Header: CSTPPCCS.pls 120.3.12010000.2 2010/03/12 20:03:26 ipineda ship $*/
/*----------------------------------------------------------------------------*
 |   PUBLIC VARIABLES/TYPES	      					      |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    pm_mark_non_project_world_txns                                         |
 |                                                                            |
 | DESCRIPTION                                                                |
 |									      |
 |    This procedure would mark all non-project world transactions as Cost    |
 |    Collected for the Given Organization and Upto the Given Date.           |
 |									      |
 |    If user desires,this procedure could be invoked by the user independent |
 |    of the execution of the Cost Collector. This could be in order to get   |
 |    done with the pre-processing needs much prior to the scheduled Cost     |  |    Collector Execution.                                                    |
 |									      |
 | PARAMETERS                                                                 |
 |      Organization_Id, UpToDate				              |
 |                                                                            |
 | HISTORY                                                                    |
 |    07-SEP-96  Bhaskar Dasari Created.                                      |
 *----------------------------------------------------------------------------*/
PROCEDURE pm_mark_non_project_world_txns (
			p_Org_Id			NUMBER,
		       	p_prior_days			NUMBER,
			p_user_id			NUMBER,
			p_login_id			NUMBER,
			p_req_id			NUMBER,
			p_prg_appl_id         		NUMBER,
			p_prg_id         		NUMBER,
  			O_err_num	OUT NOCOPY		NUMBER,
  			O_err_code	OUT NOCOPY		VARCHAR2,
  			O_err_msg	OUT NOCOPY		VARCHAR2
		);

  PROCEDURE pm_cc_worker_mmt ( 	p_transaction_id		NUMBER,
			        p_Org_Id			NUMBER,
                                p_std_cg_acct                   NUMBER, -- Added for bug 3495967
			       	p_inv_txn_source_literal	VARCHAR2,
			       	p_cap_txn_source_literal	VARCHAR2,
				p_inv_syslink_literal		VARCHAR2,
				p_bur_syslink_literal		VARCHAR2,
				p_wip_syslink_literal		VARCHAR2,
                                p_denom_currency_code           VARCHAR2,
                                p_user_def_exp_type             NUMBER,
  				p_user_id			NUMBER,
  				p_login_id			NUMBER,
  				p_req_id			NUMBER,
  				p_prg_appl_id         		NUMBER,
  				p_prg_id         		NUMBER,
  				O_err_num	        OUT NOCOPY	NUMBER,
  				O_err_code	        OUT NOCOPY	VARCHAR2,
  				O_err_msg	        OUT NOCOPY	VARCHAR2);

  PROCEDURE pm_cc_worker_wt  ( 	p_transaction_id		NUMBER,
			        p_Org_Id			NUMBER,
			       	p_wip_txn_source_literal	VARCHAR2,
                                p_wip_straight_time_literal     VARCHAR2,
                                p_wip_syslink_literal           VARCHAR2,
				p_bur_syslink_literal		VARCHAR2,
                                p_denom_currency_code           VARCHAR2,
  				p_user_id			NUMBER,
  				p_login_id			NUMBER,
  				p_req_id			NUMBER,
  				p_prg_appl_id         		NUMBER,
  				p_prg_id         		NUMBER,
  				O_err_num	OUT NOCOPY		NUMBER,
  				O_err_code	OUT NOCOPY		VARCHAR2,
  				O_err_msg	OUT NOCOPY		VARCHAR2);

  PROCEDURE assign_groups_to_mmt_txns ( p_Org_Id		NUMBER,
					p_prior_days            NUMBER,
					p_user_spec_group_size	NUMBER,
					p_rows_processed OUT NOCOPY	NUMBER,
				    	p_group_id 	 OUT NOCOPY 	NUMBER,
  				 	p_user_id		NUMBER,
  				 	p_login_id		NUMBER,
  				 	p_req_id		NUMBER,
  				 	p_prg_appl_id         	NUMBER,
  				 	p_prg_id         	NUMBER,
  				 	p_proj_misc_txn_only    NUMBER,
  					O_err_num	 OUT NOCOPY	NUMBER,
  					O_err_code	 OUT NOCOPY	VARCHAR2,
  					O_err_msg	 OUT NOCOPY	VARCHAR2);

  PROCEDURE assign_groups_to_wt_txns (  p_Org_Id		NUMBER,
					p_prior_days            NUMBER,
					p_user_spec_group_size	NUMBER,
					p_rows_processed    OUT NOCOPY NUMBER,
				    	p_group_id 	    OUT NOCOPY NUMBER,
  				 	p_user_id		NUMBER,
  				 	p_login_id		NUMBER,
  				 	p_req_id		NUMBER,
  				 	p_prg_appl_id         	NUMBER,
  				 	p_prg_id         	NUMBER,
  					O_err_num	    OUT NOCOPY	NUMBER,
  					O_err_code	    OUT NOCOPY	VARCHAR2,
  					O_err_msg	    OUT NOCOPY	VARCHAR2);

  PROCEDURE pm_get_mta_accts ( 	p_transaction_id	NUMBER,
				p_cost_element_id       NUMBER,
				p_resource_id		NUMBER DEFAULT NULL,
				p_source_flag		NUMBER DEFAULT -1,
                                p_variance_flag         NUMBER DEFAULT -1,
  				O_dr_code_combination_id  IN OUT NOCOPY NUMBER,
				O_cr_code_combination_id  IN OUT NOCOPY NUMBER,
                                O_inv_cr_sub_ledger_id   OUT NOCOPY NUMBER,
                                O_inv_dr_sub_ledger_id   OUT NOCOPY NUMBER,
                                O_cc_rate                OUT NOCOPY NUMBER,
				O_err_num		 OUT NOCOPY NUMBER,
				O_err_code		 OUT NOCOPY VARCHAR2,
				O_err_msg		 OUT NOCOPY VARCHAR2);


FUNCTION  get_group_size RETURN NUMBER;

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    get_last_cost_collection_date( Organization_Code )                      |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    reset_error_transaction                                                 |
 *----------------------------------------------------------------------------*/

END CST_PRJMFG_COST_COLLECTOR;

/
