--------------------------------------------------------
--  DDL for Package PA_COSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COSTING" AUTHID CURRENT_USER AS
/* $Header: PAXCOSTS.pls 120.3 2005/09/15 23:46:11 rahariha noship $ */

  PROCEDURE  ReverseCdl( X_expenditure_item_id            IN NUMBER
                       , X_billable_flag                  IN VARCHAR2
                       , X_amount                         IN NUMBER DEFAULT NULL
                       , X_quantity                       IN NUMBER DEFAULT NULL
                       , X_burdened_cost                  IN NUMBER DEFAULT NULL
                       , X_dr_ccid                        IN NUMBER DEFAULT NULL
                       , X_cr_ccid                        IN NUMBER DEFAULT NULL
                       , X_tr_source_accounted            IN VARCHAR2 DEFAULT NULL
                       , X_line_type                      IN VARCHAR2
                       , X_user                           IN NUMBER
          	       , X_denom_currency_code            IN VARCHAR2
                       , X_denom_raw_cost                 IN NUMBER
                       , X_denom_burden_cost              IN NUMBER
                       , X_acct_currency_code             IN VARCHAR2
                       , X_acct_rate_date                 IN DATE
                       , X_acct_rate_type                 IN VARCHAR2
                       , X_acct_exchange_rate             IN NUMBER
                       , X_acct_raw_cost                  IN NUMBER
                       , X_acct_burdened_cost             IN NUMBER
                       , X_project_currency_code          IN VARCHAR2
                       , X_project_rate_date              IN DATE
                       , X_project_rate_type              IN VARCHAR2
                       , X_project_exchange_rate          IN NUMBER
                       , P_Projfunc_currency_code         IN VARCHAR2 default null
                       , P_Projfunc_cost_rate_date        IN DATE     default null
                       , P_Projfunc_cost_rate_type        IN VARCHAR2 default null
                       , P_Projfunc_cost_exchange_rate    IN NUMBER   default null
                       , P_project_raw_cost               IN NUMBER   default null
                       , P_project_burdened_cost          IN NUMBER   default null
                       , P_Work_Type_Id                   IN NUMBER   default null
                       , X_err_code                       IN OUT NOCOPY NUMBER
                       , X_err_stage                      IN OUT NOCOPY VARCHAR2
                       , X_err_stack                      IN OUT NOCOPY VARCHAR2
		       , p_mode                           IN VARCHAR2  default 'COSTING'
                       , X_line_num                       IN NUMBER DEFAULT NULL ) ; -- Bug 4374769 : A new parameter X_line_num is added.

/*
** PROCEDURE  CreateNewCdl( X_expenditure_item_id         IN NUMBER
**                          , X_err_stack                   IN OUT VARCHAR2 );
*/
-- comment this out since told to not use overloading...

-- create another spec for CreateNewCdl due to bug 666884.

  PROCEDURE  CreateNewCdl( X_expenditure_item_id         IN NUMBER
                         , X_amount                      IN NUMBER
                         , X_dr_ccid                     IN NUMBER
                         , X_cr_ccid                     IN NUMBER
                         , X_transfer_status_code        IN VARCHAR2
                         , X_quantity                    IN NUMBER
                         , X_billable_flag               IN VARCHAR2
                         , X_request_id                  IN NUMBER
                         , X_program_application_id      IN NUMBER
                         , x_program_id                  IN NUMBER
                         , x_program_update_date         IN DATE
                         , X_pa_date                     IN DATE
                         , X_recvr_pa_date               IN DATE          /**CBGA**/
                         , X_gl_date                     IN DATE
                         , X_transferred_date            IN DATE
                         , X_transfer_rejection_reason   IN VARCHAR2
                         , X_line_type                   IN VARCHAR2
                         , X_ind_compiled_set_id         IN NUMBER
                         , X_burdened_cost               IN NUMBER
                         , X_line_num_reversed           IN NUMBER
                         , X_reverse_flag                IN VARCHAR2
                         , X_user                        IN NUMBER
                         , X_err_code                    IN OUT NOCOPY NUMBER
                         , X_err_stage                   IN OUT NOCOPY VARCHAR2
                         , X_err_stack                   IN OUT NOCOPY VARCHAR2
                         , X_project_id                  IN NUMBER
                         , X_task_id                     IN NUMBER
                         , X_cdlsr1                      IN VARCHAR2 default null
                         , X_cdlsr2                      IN VARCHAR2 default null
                         , X_cdlsr3                      IN VARCHAR2 default null
			 , X_denom_currency_code         IN VARCHAR2 default null
			 , X_denom_raw_cost	            IN NUMBER   default null
			 , X_denom_burden_cost	         IN NUMBER   default null
			 , X_acct_currency_code	         IN VARCHAR2 default null
			 , X_acct_rate_date	            IN DATE     default null
			 , X_acct_rate_type	            IN VARCHAR2 default null
			 , X_acct_exchange_rate	         IN NUMBER   default null
			 , X_acct_raw_cost		         IN NUMBER   default null
			 , X_acct_burdened_cost	         IN NUMBER   default null
			 , X_project_currency_code	      IN VARCHAR2 default null
			 , X_project_rate_date	         IN DATE     default null
			 , X_project_rate_type	         IN VARCHAR2 default null
			 , X_project_exchange_rate       IN NUMBER   default null
                         , P_PaPeriodName              IN Varchar2 default null
                         , P_RecvrPaPeriodName         IN Varchar2 default null
                         , P_GlPeriodName              IN Varchar2 default null
                         , P_RecvrGlDate               IN DATE     default null
                         , P_RecvrGlPeriodName         IN Varchar2 default null
                         , P_Projfunc_currency_code    IN VARCHAR2 default null
                         , P_Projfunc_cost_rate_date        IN DATE     default null
                         , P_Projfunc_cost_rate_type        IN VARCHAR2 default null
                         , P_Projfunc_cost_exchange_rate    IN NUMBER   default null
                         , P_project_raw_cost          IN NUMBER   default null
                         , P_project_burdened_cost     IN NUMBER   default null
                         , P_Work_Type_Id              IN NUMBER   default null
			 , p_mode                           IN VARCHAR2  default 'COSTING'
                         , p_cdlsr4                      IN VARCHAR2 default null
                         , p_si_assets_addition_flag   IN VARCHAR2 default NULL
                         , p_cdlsr5                    IN NUMBER default null
			 , P_Parent_Line_Num           IN NUMBER DEFAULT NULL);

  PROCEDURE  CreateExternalCdl( X_expenditure_item_id         IN NUMBER
                              , X_ei_date                     IN DATE
                              , X_amount                      IN NUMBER
                              , X_dr_ccid                     IN NUMBER
                              , X_cr_ccid                     IN NUMBER
                              , X_transfer_status_code        IN VARCHAR2
                              , X_quantity                    IN NUMBER
                              , X_billable_flag               IN VARCHAR2
                              , X_request_id                  IN NUMBER
                              , X_program_application_id      IN NUMBER
                              , x_program_id                  IN NUMBER
                              , x_program_update_date         IN DATE
                              , X_pa_date                     IN DATE
                              , X_recvr_pa_date               IN DATE          /**CBGA**/
                              , X_gl_date                     IN DATE
                              , X_transferred_date            IN DATE
                              , X_transfer_rejection_reason   IN VARCHAR2
                              , X_line_type                   IN VARCHAR2
                              , X_ind_compiled_set_id         IN NUMBER
                              , X_burdened_cost               IN NUMBER
                              , X_user                        IN NUMBER
                              , X_project_id                  IN NUMBER
                              , X_task_id                     IN NUMBER
                              , X_cdlsr1                      IN VARCHAR2 default null
                              , X_cdlsr2                      IN VARCHAR2 default null
                              , X_cdlsr3                      IN VARCHAR2 default null
  	                      , X_denom_currency_code         IN VARCHAR2 default null
	                      , X_denom_raw_cost	           IN NUMBER   default null
	                      , X_denom_burden_cost	        IN NUMBER   default null
	                      , X_acct_currency_code	        IN VARCHAR2 default null
	                      , X_acct_rate_date	           IN DATE     default null
	                      , X_acct_rate_type	           IN VARCHAR2 default null
	                      , X_acct_exchange_rate	        IN NUMBER   default null
	                      , X_acct_raw_cost		           IN NUMBER   default null
	                      , X_acct_burdened_cost	        IN NUMBER   default null
	                      , X_project_currency_code	     IN VARCHAR2 default null
	                      , X_project_rate_date	        IN DATE     default null
	                      , X_project_rate_type	        IN VARCHAR2 default null
	                      , X_project_exchange_rate       IN NUMBER   default null
                              , P_PaPeriodName                 IN Varchar2 default null
                              , P_RecvrPaPeriodName            IN Varchar2 default null
                              , P_GlPeriodName                 IN Varchar2 default null
                              , P_RecvrGlDate                  IN DATE     default null
                              , P_RecvrGlPeriodName            IN Varchar2 default null
                              , P_Projfunc_currency_code    IN VARCHAR2 default null
                              , P_Projfunc_cost_rate_date        IN DATE     default null
                              , P_Projfunc_cost_rate_type        IN VARCHAR2 default null
                              , P_Projfunc_cost_exchange_rate    IN NUMBER   default null
                              , P_Project_raw_cost          IN NUMBER   default null
                              , P_Project_burdened_cost     IN NUMBER   default null
                              , P_Work_Type_Id              IN NUMBER   default null
                              , p_cdlsr4                      IN VARCHAR2 default null
			      , p_si_assets_addition_flag   IN VARCHAR2 default NULL
                              , p_cdlsr5                      IN NUMBER default null
                              , X_err_code                    IN OUT NOCOPY NUMBER
                              , X_err_stage                   IN OUT NOCOPY VARCHAR2
                              , X_err_stack                   IN OUT NOCOPY VARCHAR2 );

   FUNCTION Is_Accounted(X_Transaction_Source IN VARCHAR2)
   RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES(Is_Accounted,WNDS,WNPS);

   PROCEDURE  CreateReverseCdl ( X_exp_item_id  IN     NUMBER,
                                 X_backout_id   IN     NUMBER,
                                 X_user         IN     NUMBER,
                                 X_status       OUT    NOCOPY NUMBER);
END PA_COSTING ;

 

/
