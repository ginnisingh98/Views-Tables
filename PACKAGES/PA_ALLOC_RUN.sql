--------------------------------------------------------
--  DDL for Package PA_ALLOC_RUN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ALLOC_RUN" AUTHID CURRENT_USER AS
	/* $Header: PAXALRNS.pls 120.1 2005/08/10 13:37:21 dlanka noship $ */


	-- ------------------------------------------------------------
	-- allocation_run: Main procedure for Allocation Run process
	--                 Called through a report.
	-- ------------------------------------------------------------
	  PROCEDURE allocation_run(  p_process_mode    IN  VARCHAR2
							   , p_debug_mode      IN  VARCHAR2
							   ,p_run_mode        IN  VARCHAR2 DEFAULT 'G'
							   , p_rule_id         IN  NUMBER
							   , p_run_period      IN  VARCHAR2 DEFAULT NULL
							   , p_expnd_item_date IN  DATE DEFAULT NULL
							   , x_run_id          OUT NOCOPY NUMBER
							   , x_retcode         OUT NOCOPY VARCHAR2
							   , x_errbuf          OUT NOCOPY VARCHAR2 );
	  G_alloc_run_id NUMBER;
	-- ---------------------------------------------------------------
	-- check_last_run_status: Checks the status of the rule being run.
	--                        Returns Mode= DRAFT or RELEASE,run_id,
	--                        prev_run_id to the calling function
	-- ---------------------------------------------------------------
	  PROCEDURE check_last_run_status( p_rule_id     IN  NUMBER
									 , x_run_id      IN OUT NOCOPY  NUMBER
									 , x_mode        OUT  NOCOPY VARCHAR2 );

	-- ----------------------------------------------------------------
	-- ins_alloc_exceptions:  Inserts a row into PA_ALLOC_EXCEPTIONS
	--                        table with the passed paramter values
	-- ----------------------------------------------------------------
	  PROCEDURE ins_alloc_exceptions( p_rule_id           IN NUMBER
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
									, p_exception_code    IN VARCHAR2 );

	  PROCEDURE alloc_errors ( p_rule_id IN NUMBER
																	 , p_run_id  IN NUMBER
																	 , p_level   IN VARCHAR2
																	 , p_type    IN VARCHAR2
																	 , p_mesg_code   IN VARCHAR2
																	 , p_fatal_err   IN BOOLEAN  DEFAULT FALSE
																	 , p_insert_flag IN VARCHAR2 DEFAULT 'Y'
																	 , p_project_id  IN NUMBER   DEFAULT NULL
																	 , p_task_id     IN NUMBER   DEFAULT NULL );

	-- ----------------------------------------------------------------
	-- validate_rule: Validates the following for the passed in rule_id
	--                and run_id:
	--                1. Date efffectivity of rule
	--                2. Source Line definitions( PA and GL lines )
	--                3. Target Line definitions
	--                4. Offset definitions (if any)
	--                5. Basis definitions (if any)
	--                6. Date effectivity of Exp Types (offset/target)
	--                7. Expenditure Orgs (offset/target)
	-- ----------------------------------------------------------------
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
						   , p_expnd_item_date       IN DATE );

	-- -----------------------------------------------------------------
	-- insert_alloc_run_sources: Inserts a row into PA_ALLOC_RUN_SOURCES
	--                           table with the passed in param values
	-- -----------------------------------------------------------------
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
									  , p_last_update_login IN NUMBER );


	-- ----------------------------------------------------------------
	-- exclude_curr_proj_task: Returns 0 if passed in project_id and task_id
	--                         need to be excluded, else returns 1
	--                         p_type = 'SRC' or 'TRG'
	-- ----------------------------------------------------------------
	FUNCTION exclude_curr_proj_task( p_run_id     IN NUMBER
								   , p_type       IN VARCHAR2
								   , p_project_id IN NUMBER
								   , p_task_id    IN NUMBER ) RETURN NUMBER;


	-- -------------------------------------------------------------------
	-- populate_run_sources: Explodes the source_lines and source client
	--                       extension (if any), of the passed in
	--                       rule_id, upto project and lowest level tasks
	--                       and then populates PA_ALLOC_RUN_SOURCES table
	-- --------------------------------------------------------------------
	PROCEDURE populate_run_sources( p_rule_id               IN NUMBER
								  , p_run_id                IN NUMBER
								  , p_resource_list_id      IN NUMBER
								  , p_source_clnt_extn_flag IN VARCHAR2
								  /* FP.M : Allocation Impact */
								  , p_alloc_resource_struct_type In Varchar2
								  , p_rbs_version_id		 In Number
								  );


	-- -------------------------------------------------------------------
	-- insert_alloc_run_targets: Inserts a row in PA_ALLOC_RUN_TARGETS
	--                           table with the passed in paramter values
	-- -------------------------------------------------------------------
	PROCEDURE insert_alloc_run_targets( p_rule_id           IN NUMBER
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
									  , p_dup_targets_flag  IN VARCHAR2 );


	-- ----------------------------------------------------------------
	-- populate_run_targets:
	-- ----------------------------------------------------------------
	PROCEDURE populate_run_targets( p_rule_id           IN NUMBER
								  , p_run_id           IN NUMBER
								  , p_basis_method     IN VARCHAR2
								  , p_bas_budget_type_code         IN VARCHAR2
								  , p_bas_budget_entry_method_code IN VARCHAR2
								  , p_resource_list_id IN NUMBER
								  , p_trgt_client_extn IN VARCHAR2
								  , p_dup_targets_flag IN VARCHAR2
								  , p_expnd_item_date  IN DATE
								  , p_limit_target_projects_code IN VARCHAR2
								  , x_basis_method  OUT NOCOPY VARCHAR2
								  /* FP.M : Allocation Impact */
								  , p_basis_resource_struct_type in varchar2
								  , p_rbs_version_id in Number
								  );


	-- ----------------------------------------------------------------
	-- calculate_src_GL_amounts:
	-- ----------------------------------------------------------------
	PROCEDURE calculate_src_GL_amounts( p_rule_id     IN NUMBER
									 , p_run_id      IN NUMBER
									 , p_run_period  IN VARCHAR2
									 , p_amount_type IN VARCHAR2
									 , x_gl_src_amount OUT NOCOPY NUMBER
									   );


	-- ----------------------------------------------------------------
	-- insert_alloc_run_GL_det:
	-- ----------------------------------------------------------------
	PROCEDURE insert_alloc_run_GL_det( p_run_id            IN NUMBER
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
									 , p_eligible_amount   IN NUMBER );

	-- ------------------------------------------------------------------
	-- get_trg_line_proj_task_count:
	-- ------------------------------------------------------------------

	FUNCTION get_trg_line_proj_task_count( p_run_id   IN NUMBER
										 , p_line_num IN NUMBER ) RETURN NUMBER;

	-- ------------------------------------------------------------------
	-- get_sunk_cost:
	-- ------------------------------------------------------------------
	PROCEDURE get_sunk_cost( p_rule_id IN NUMBER
						  , p_run_id  IN NUMBER
						  , p_fiscal_year IN NUMBER
						  , p_quarter_num IN NUMBER
						  , p_period_num  IN NUMBER
						  , p_amount_type IN VARCHAR2
						  , x_src_sunk_cost OUT NOCOPY NUMBER
						  , x_tgt_sunk_cost OUT NOCOPY NUMBER
						  , p_src_proj_id  IN NUMBER    ) ;

	-- -----------------------------------------------------------------
	-- get_previous_alloc_amnt:
	-- -----------------------------------------------------------------
	FUNCTION get_previous_alloc_amnt( p_rule_id     IN NUMBER
									, p_run_id      IN NUMBER
									, p_project_id  IN NUMBER
									, p_task_id     IN NUMBER
									, p_quarter_num IN NUMBER
									, p_fiscal_year IN NUMBER
									, p_period_num  IN NUMBER
									, p_type        IN VARCHAR2
									, p_amount_type IN VARCHAR2 ) RETURN NUMBER;

	-- ---------------------------------------------------------------------
	-- insert_alloc_txn_details:
	-- ---------------------------------------------------------------------
	PROCEDURE insert_alloc_txn_details(x_alloc_txn_id         IN OUT NOCOPY NUMBER /* Added for PA.L */
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
						 );

	-- -------------------------------------------------------------------
	-- create_target_txns:
	-- -------------------------------------------------------------------
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
								, p_amount_type      IN VARCHAR2
								, p_pool_amount      IN NUMBER
								, x_curr_alloc_amount OUT NOCOPY NUMBER  ) ;

	-- -------------------------------------------------------------------
	-- create_offset_txns:
	-- -------------------------------------------------------------------
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
								, p_amount_type      IN VARCHAR2
								, p_pool_amount      IN NUMBER
								, p_allocated_amount IN NUMBER ) ;

	-- -------------------------------------------------------------------
	-- allocate_remnant:
	-- -------------------------------------------------------------------
	PROCEDURE allocate_remnant( p_run_id IN NUMBER
							  , p_act_alloc_amount IN NUMBER
							  , x_remnant_amount OUT NOCOPY NUMBER );

	-- -------------------------------------------------------------------
	-- insert_alloc_runs:
	-- -------------------------------------------------------------------
	PROCEDURE insert_alloc_runs( x_run_id                  IN OUT NOCOPY NUMBER /* Modified as IN OUT for capint */
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
							   /* FP.M : Allocation Impact : 3512552 */
							   , p_ALLOC_RESOURCE_STRUCT_TYPE IN Varchar2  default NULL
							   , p_BASIS_RESOURCE_STRUCT_TYPE IN Varchar2  default NULL
							   , p_ALLOC_RBS_VERSION IN Number  default NULL
							   , p_BASIS_RBS_VERSION IN Number  default NULL

							   );


	-- -------------------------------------------------------------------
	-- The procedures above were done by msiddiqu
	-- The procedures below were done by sesivara
	-- -------------------------------------------------------------------


	TYPE SRC_RLM_RECORD IS RECORD (
		 resource_list_member_id  NUMBER ,
		 resource_percent         NUMBER
								  ) ;
	TYPE SRC_RLM_TABTYPE IS TABLE OF SRC_RLM_RECORD
	INDEX BY BINARY_INTEGER ;

	-- -------------------------------------------------------------------
	-- Init_who_cols
	-- -------------------------------------------------------------------
	procedure Init_who_cols ;

	-- -------------------------------------------------------------------
	-- get_fiscalyear_quarter
	-- -------------------------------------------------------------------
	/* Procedure :   get_fiscalyear_quarter()
		 Purpose :   For a given run_period_type (PA/GL) and run_period, this procedure will get
					 period_type, period_set_name ( calender) , period_year ( Fiscal Year), quarter
					 period_num and  end date of the run period.
		 Created :   27-JUL-98   Sesivara
	*/

	Procedure get_fiscalyear_quarter(   p_run_period_type    IN  VARCHAR2 ,
										p_run_period         IN  VARCHAR2 ,
										x_period_type      OUT NOCOPY VARCHAR2 ,
										x_period_set_name  OUT NOCOPY VARCHAR2 ,
										x_period_year      OUT NOCOPY NUMBER   ,
										x_quarter          OUT NOCOPY NUMBER   ,
										x_period_num       OUT NOCOPY NUMBER   ,
										x_run_period_end_date  OUT NOCOPY DATE )  ;

	-- -------------------------------------------------------------------
	-- populate_RLM_table
	-- -------------------------------------------------------------------
	Procedure populate_RLM_table( p_rule_id           IN  NUMBER,
								  p_run_id            IN  NUMBER,
								  p_type              IN  VARCHAR2,
								  p_resource_list_id  IN  NUMBER  ,
								  /* FP.M : Allocation Impact Bug # 3512552 */
								  p_resource_struct_type in Varchar2 ,
								  p_rbs_version_id	  In Number ,
								  p_basis_category    In Varchar2
								  );



	-- -------------------------------------------------------------------
	-- get_amttype_start_date
	-- -------------------------------------------------------------------
	PROCEDURE get_amttype_start_date( p_amt_type                  IN  VARCHAR2,
									  p_period_type               IN  VARCHAR2 ,
									  p_period_set_name           IN  VARCHAR2 ,
									  p_run_period_end_date       IN  DATE,
									  p_quarter_num               IN  NUMBER,
									  p_period_year               IN  NUMBER,
									  p_period                    IN  VARCHAR2 ,
									  x_start_date                OUT NOCOPY DATE    ) ;

	-- -------------------------------------------------------------------
	-- get_alloc_amount
	-- -------------------------------------------------------------------
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
								x_amount          OUT NOCOPY NUMBER  )  ;

	-- -------------------------------------------------------------------
	-- cal_amounts_from_projects
	-- -------------------------------------------------------------------
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
										);

	-- -------------------------------------------------------------------
	-- insert_alloc_run_src_det
	-- -------------------------------------------------------------------
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
									  , p_last_update_login  IN NUMBER) ;

	-- -------------------------------------------------------------------
	-- get_relative_period_name
	-- -------------------------------------------------------------------
	Procedure get_relative_period_name( p_period_set_name      IN VARCHAR2,
										p_period_type          IN VARCHAR2,
										p_run_period_end_date  IN DATE,
										p_run_period           IN VARCHAR2,
										p_relative_period      IN NUMBER,
										x_rel_period_name     OUT NOCOPY VARCHAR2 ) ;

	-- -------------------------------------------------------------------
	-- insert_alloc_run_basis_det
	-- -------------------------------------------------------------------
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
									  , p_last_update_login  IN NUMBER)  ;

	-- -------------------------------------------------------------------
	-- cal_proj_basis_amounts
	-- -------------------------------------------------------------------
	PROCEDURE cal_proj_basis_amounts(p_rule_id          IN NUMBER,
									 p_run_id           IN NUMBER,
									 p_run_period_type  IN VARCHAR2,
									 p_run_period       IN VARCHAR2,
									 p_basis_method     IN OUT NOCOPY VARCHAR2, -- verify
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
									 ) ;

	-- -------------------------------------------------------------------
	-- get_budget_amounts
	-- -------------------------------------------------------------------
	/***PROCEDURE get_budget_amounts( p_run_period_type     IN VARCHAR2,
	 ***                          p_bal_type            IN VARCHAR2,
	 ***                          p_project_id          IN NUMBER  ,
	 ***                          p_task_id             IN NUMBER  ,
	 ***                          p_rl_id               IN NUMBER  ,
	 ***                          p_rlm_id              IN NUMBER  ,
	 ***                          p_budget_type_code    IN VARCHAR2,
	 ***                          p_start_date          IN DATE ,
	 ***                          p_end_date            IN DATE ,
	 ***                          x_amount              OUT NUMBER  ) ;
	 *** commented for bug 2619977 */
	-- -------------------------------------------------------------------
	-- clean_up_targets_for_actuals
	-- -------------------------------------------------------------------
	PROCEDURE clean_up_targets_for_actuals(
								p_run_id              IN NUMBER,
								p_rule_id             IN NUMBER,
								p_amt_type            IN VARCHAR2,
								p_run_period_type     IN VARCHAR2,
								p_period              IN VARCHAR2,
								p_run_period_end_date IN DATE ,
								p_amttype_start_date  IN DATE,
								p_basis_method        IN OUT NOCOPY VARCHAR2 -- verify
								) ;

	-- -------------------------------------------------------------------
	-- Release_alloc_txns
	-- -------------------------------------------------------------------
	PROCEDURE Release_alloc_txns( p_rule_id  IN NUMBER
								 ,p_run_id   IN  NUMBER
								 , x_retcode         OUT NOCOPY VARCHAR2
								 , x_errbuf          OUT NOCOPY VARCHAR2
								 ) ;

	-- -------------------------------------------------------------------
	-- Reverse_alloc_txns
	-- -------------------------------------------------------------------
	PROCEDURE Reverse_alloc_txns( p_rule_id  IN NUMBER
								 ,p_run_id   IN  NUMBER
								 ,p_tgt_exp_group IN VARCHAR2
								 ,p_off_exp_group  IN VARCHAR2
								 ,x_retcode       OUT NOCOPY NUMBER
								 ,x_errbuf        OUT NOCOPY VARCHAR2
								) ;
	-- -------------------------------------------------------------------
	-- Delete_alloc_txns
	-- -------------------------------------------------------------------
	PROCEDURE Delete_alloc_txns( p_rule_id  IN NUMBER
								 ,p_run_id   IN  NUMBER) ;

	-- -------------------------------------------------------------------
	-- lock_rule
	-- -------------------------------------------------------------------
	PROCEDURE lock_rule(p_rule_id IN NUMBER
						,p_run_id  IN NUMBER ) ;

	-- -------------------------------------------------------------------
	-- unlock_rule
	-- -------------------------------------------------------------------
	PROCEDURE unlock_rule(p_rule_id IN NUMBER
						 ,p_run_id  IN NUMBER ) ;

	-- ------------------------------------------------------------
	-- insert_missing_costs
	-- ------------------------------------------------------------
	PROCEDURE insert_missing_costs(     p_run_id              IN NUMBER
									  , p_type_code           IN VARCHAR2
									  , p_project_id          IN NUMBER
									  , p_task_id             IN NUMBER
									  , p_amount  IN NUMBER );


	--------------------------------------------------------------------------
	--Function:  Is_src_project_valid
	--Purpose: validating source project_id returned from source client extension
	----------------------------------------------------------------------------
	FUNCTION Is_src_project_valid(p_project_id IN NUMBER) RETURN VARCHAR2 ;

	--------------------------------------------------------------------------
	--Function:  Is_src_task_valid
	--Purpose: validating source task_id returned from source client extension
	----------------------------------------------------------------------------

	FUNCTION Is_src_task_valid(p_project_id IN NUMBER,p_task_id IN NUMBER) RETURN VARCHAR2 ;

	--------------------------------------------------------------------------
	--Function:  Is_tgt_project_valid
	--Purpose: validating target project_id returned from target client extension
	----------------------------------------------------------------------------
	FUNCTION Is_tgt_project_valid(p_project_id IN NUMBER) RETURN VARCHAR2 ;

	--------------------------------------------------------------------------
	--Function:  Is_tgt_task_valid
	--Purpose: validating target task_id returned from target client extension
	----------------------------------------------------------------------------
	FUNCTION Is_tgt_task_valid(p_project_id IN NUMBER,p_task_id IN NUMBER) RETURN VARCHAR2;

	--------------------------------------------------------------------------
	--Function:  Is_offset_project_valid
	--Purpose: validating offset project_id returned from offset client extension
	----------------------------------------------------------------------------
	FUNCTION Is_offset_project_valid(p_project_id IN NUMBER) RETURN VARCHAR2 ;

	--------------------------------------------------------------------------
	--Function:  Is_offset_task_valid
	--Purpose: validating offset task_id returned from offset client extension
	----------------------------------------------------------------------------
	FUNCTION Is_offset_task_valid(p_project_id IN NUMBER,p_task_id IN NUMBER) RETURN VARCHAR2;

	--------------------------------------------------------------------------
	--Function:  build_src_sql
	--Purpose: build dynamic sql for sources
	----------------------------------------------------------------------------
	Procedure  build_src_sql( p_project_org_id   IN NUMBER
			  ,p_project_type     IN VARCHAR2
			  ,p_task_org_id      IN NUMBER
			  ,p_service_type     IN VARCHAR2
			  ,p_class_category   IN VARCHAR2
			  ,p_class_code       IN VARCHAR2
			  ,p_project_id       IN NUMBER
			  ,p_task_id          IN NUMBER
			  ,x_sql_str          OUT NOCOPY VARCHAR2 ) ;

	--------------------------------------------------------------------------
	--Function:  Build_tgt_sql
	--Purpose: build dynamic sql for targets
	----------------------------------------------------------------------------
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
			  ,p_limit_target_projects_code IN VARCHAR2
			  ,x_sql_str          OUT NOCOPY VARCHAR2 ) ;

	--------------------------------------------------------------------------
	--Function:  Delete_alloc_run
	--Purpose: Delete allocation run give a rule_id
	----------------------------------------------------------------------------
	PROCEDURE Delete_alloc_run(
							   errbuf                  OUT NOCOPY VARCHAR2,
							   retcode                 OUT NOCOPY VARCHAR2,
							   p_rule_id  IN NUMBER
							   );

	--------------------------------------------------------------------------
	--Procedure:  insert_alloc_basis_resource
	--Purpose: inserts resource related actuals data into pa_alloc_run_basis_det table.
	----------------------------------------------------------------------------

	PROCEDURE insert_alloc_basis_resource(
								p_run_id          IN NUMBER,
								p_rule_id         IN NUMBER,
								p_resource_list_id IN NUMBER,
								p_amt_type        IN VARCHAR2,
								p_bal_type        IN VARCHAR2,
								p_run_period_type IN VARCHAR2,
								p_period          IN VARCHAR2,
								p_run_period_end_date IN DATE ,
								p_amttype_start_date  IN DATE  ,
								-- FP.M : Allocation Impact
								p_resource_struct_type in Varchar2,
								p_rbs_version_id In Varchar2
								);

	--This procedure deletes the source details for each capital interest transaction. This procedure will
	--be called from delete_alloc_run api when the DELETE button is pressed to delete a capital interest
	--batch
	PROCEDURE delete_cint_source_dets
	( p_run_id              IN  pa_alloc_runs_all.run_id%TYPE
	 ,x_return_status       OUT NOCOPY VARCHAR2
	 ,x_msg_count           OUT NOCOPY NUMBER
	 ,x_msg_data            OUT NOCOPY VARCHAR2
	);

	--Added this procedure for Capital Project Enhancement. This procedure releases a capitalized interest run
	--This procedure is called from PA_CAP_INT_PVT. Generate_cap_interest when release button is pressed on the
	--Allocation form(when form is accessed in the context of capitalized interest) or when auto release flag is
	--passed Y
	PROCEDURE release_capint_txns
	( p_run_id           IN   pa_alloc_runs_all.run_id%TYPE
	 ,x_return_status    OUT  NOCOPY VARCHAR2
	 ,x_msg_count        OUT  NOCOPY NUMBER
	 ,x_msg_data         OUT  NOCOPY VARCHAR2
	);


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
								);

END PA_ALLOC_RUN;

 

/
