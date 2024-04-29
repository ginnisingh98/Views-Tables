--------------------------------------------------------
--  DDL for Package PA_ADJUSTMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ADJUSTMENTS" AUTHID CURRENT_USER AS
/* $Header: PAXTADJS.pls 120.21.12000000.4 2007/03/22 09:01:01 pkaur ship $ */

  INVALID_ITEM      EXCEPTION;
  SUBROUTINE_ERROR  EXCEPTION;

  ExpItemsIdTab     pa_utils.IdTabTyp ;

  -- Added the following table to keep track of all the EI's that are
  -- being adjusted by Txn Import program.

  ExpAdjItemTab     pa_utils.IdTabTyp;
  BackOutId         NUMBER;

/* R12 Changes Start */
  G_REQUEST_ID NUMBER(15) := NULL;
  G_PROGRAM_ID NUMBER(15) := NULL;
  G_PROG_APPL_ID NUMBER(15) := NULL;
/* R12 Changes End */

  -- The following variable will decide if MRC data needs to be updated.
  -- This flag is useful in cases where the MRC triggres are disabled(
  -- For example during install/upgrade)
  -- pa41fixs.sql uses this flag to upgrade MRC data.

--G_update_mrc_data Varchar2(1) := 'N'; -- MRC Elimination

  PROCEDURE CheckStatus( status_indicator IN OUT NOCOPY NUMBER );


  FUNCTION VerifyOrigItem ( X_person_id                IN NUMBER
                          , X_org_id                   IN NUMBER
                          , X_item_date                IN DATE
                          , X_task_id                  IN NUMBER
                          , X_exp_type                 IN VARCHAR2
                          , X_system_linkage_function  IN VARCHAR2
                          , X_nl_org_id                IN NUMBER
                          , X_nl_resource              IN VARCHAR2
                          , X_quantity                 IN NUMBER
                          , X_denom_raw_cost           IN NUMBER
                          , X_trx_source               IN VARCHAR2
                          , X_denom_currency_code      IN VARCHAR2
                          , X_acct_raw_cost            IN NUMBER
                          -- SST Changes: Additional parameter
                          , X_reversed_orig_txn_reference IN OUT NOCOPY VARCHAR2
                          ) RETURN  NUMBER;

  PROCEDURE  CommentChange( X_exp_item_id  IN NUMBER
                          , X_new_comment  IN VARCHAR2
                          , X_user         IN NUMBER
                          , X_login        IN NUMBER
                          , X_status       OUT NOCOPY NUMBER );

  PROCEDURE  InsAuditRec( X_exp_item_id       IN NUMBER
                        , X_adj_activity      IN VARCHAR2
                        , X_module            IN VARCHAR2
                        , X_user              IN NUMBER
                        , X_login             IN NUMBER
                        , X_status            OUT NOCOPY NUMBER
                        , X_who_req_id        IN NUMBER DEFAULT NULL
                        , X_who_prog_id       IN NUMBER DEFAULT NULL
                        , X_who_prog_app_id   IN NUMBER DEFAULT NULL
                        , X_who_prog_upd_date IN DATE DEFAULT NULL
/* R12 Changes Start */
			, X_rejection_code    IN VARCHAR2 DEFAULT NULL );
/* R12 Changes End */

  PROCEDURE  SetNetZero( X_exp_item_id   IN NUMBER
                       , X_user          IN NUMBER
                       , X_login         IN NUMBER
                       , X_status        OUT NOCOPY NUMBER );

  PROCEDURE  BackoutItem( X_exp_item_id      IN NUMBER
                        , X_expenditure_id   IN NUMBER
                        , X_adj_activity     IN VARCHAR2
                        , X_module           IN VARCHAR2
                        , X_user             IN NUMBER
                        , X_login            IN NUMBER
                        , X_status           OUT NOCOPY NUMBER );

  /* MRC Elimination
  PROCEDURE  BackoutMrcItem( X_exp_item_id      IN NUMBER
                        , X_backout_id       IN NUMBER
                        , X_adj_activity     IN VARCHAR2
                        , X_module           IN VARCHAR2
                        , X_user             IN NUMBER
                        , X_login            IN NUMBER
                        , X_status           OUT NOCOPY NUMBER );
 */

  PROCEDURE  ReverseRelatedItems( X_source_exp_item_id  IN NUMBER
                                , X_expenditure_id      IN NUMBER
                                , X_module              IN VARCHAR2
                                , X_user                IN NUMBER
                                , X_login               IN NUMBER
                                , X_status              OUT NOCOPY NUMBER );

  PROCEDURE  RecalcRev(ItemsIdTab          IN pa_utils.IdTabTyp
                      , AdjustsIdTab       IN pa_utils.IdTabTyp
                      , X_user           IN NUMBER
                      , X_login          IN NUMBER
                      , X_module         IN VARCHAR2
                      , rows             IN NUMBER
                      , X_status         OUT NOCOPY NUMBER );

  PROCEDURE  RecalcCostRev(ItemsIdTab          IN pa_utils.IdTabTyp
                          , AdjustsIdTab       IN pa_utils.IdTabTyp
                          , X_user           IN NUMBER
                          , X_login          IN NUMBER
                          , X_module         IN VARCHAR2
                          , rows             IN NUMBER
                          , X_num_processed  OUT NOCOPY NUMBER
                          , X_status         OUT NOCOPY NUMBER );

  PROCEDURE  RecalcRawCost(ItemsIdTab          IN pa_utils.IdTabTyp
                          , AdjustsIdTab       IN pa_utils.IdTabTyp
                          , X_user           IN NUMBER
                          , X_login          IN NUMBER
                          , X_module         IN VARCHAR2
                          , rows             IN NUMBER
                          , X_num_processed  OUT NOCOPY NUMBER
                          , X_status         OUT NOCOPY NUMBER );

  PROCEDURE  RecalcIndCost(ItemsIdTab          IN pa_utils.IdTabTyp
                          , AdjustsIdTab       IN pa_utils.IdTabTyp
                          , X_user           IN NUMBER
                          , X_login          IN NUMBER
                          , X_module         IN VARCHAR2
                          , rows             IN BINARY_INTEGER
                          , X_status         OUT NOCOPY NUMBER );

  PROCEDURE  RecalcCapCost(ItemsIdTab          IN pa_utils.IdTabTyp
                          , AdjustsIdTab       IN pa_utils.IdTabTyp
                          , X_user           IN NUMBER
                          , X_login          IN NUMBER
                          , X_module         IN VARCHAR2
                          , rows             IN BINARY_INTEGER
                          , X_status         OUT NOCOPY NUMBER );


  FUNCTION GetInvId (X_expenditure_item_id NUMBER ) RETURN VARCHAR2 ;
  --pragma RESTRICT_REFERENCES ( GetInvId, WNDS, WNPS);

/* R12 Changes Start */
   FUNCTION InvStatus( X_system_reference2  VARCHAR2,
                       X_system_linkage_function VARCHAR2 DEFAULT NULL)
   return VARCHAR2;
/* R12 Changes End */

  PROCEDURE  Hold(ItemsIdTab        IN pa_utils.IdTabTyp
                 , AdjustsIdTab     IN pa_utils.IdTabTyp
                 , X_hold         IN VARCHAR2
                 , X_adj_activity IN VARCHAR2
                 , X_user         IN NUMBER
                 , X_login        IN NUMBER
                 , X_module       IN VARCHAR2
                 , rows           IN BINARY_INTEGER
                 , X_status       OUT NOCOPY NUMBER );

  PROCEDURE  Reclass(ItemsIdTab        IN pa_utils.IdTabTyp
                    , AdjustsIdTab     IN pa_utils.IdTabTyp
                    , X_billable     IN VARCHAR2
                    , X_adj_activity IN VARCHAR2
                    , X_user         IN NUMBER
                    , X_login        IN NUMBER
                    , X_module       IN VARCHAR2
                    , rows           IN BINARY_INTEGER
                    , X_status       OUT NOCOPY NUMBER );

  PROCEDURE  Split( X_exp_item_id         IN NUMBER
                  , X_item1_qty           IN NUMBER
                  , X_item1_raw_cost      IN NUMBER     -- proj func
                  , X_item1_burden_cost   IN NUMBER     -- proj func
                  , X_item1_bill_flag     IN VARCHAR2
                  , X_item1_hold_flag     IN VARCHAR2
                  , X_item2_qty           IN NUMBER
                  , X_item2_raw_cost      IN NUMBER       -- proj func
                  , X_item2_burden_cost   IN NUMBER       -- proj func
                  , X_item1_receipt_curr_amt  IN NUMBER
                  , X_item2_receipt_curr_amt  IN NUMBER
                  , X_item1_denom_raw_cost IN NUMBER
                  , X_item2_denom_raw_cost IN NUMBER
                  , X_item1_denom_burdened_cost IN NUMBER
                  , X_item2_denom_burdened_cost IN NUMBER
                  , X_Item1_acct_raw_cost     IN NUMBER
                  , X_item2_acct_raw_cost     IN NUMBER
                  , X_item1_acct_burdened_cost IN NUMBER
                  , X_item2_acct_burdened_cost IN NUMBER
                  , X_item2_bill_flag     IN VARCHAR2
                  , X_item2_hold_flag     IN VARCHAR2
                  , X_user                IN NUMBER
                  , X_login               IN NUMBER
                  , X_module              IN VARCHAR2
                  , X_status              OUT NOCOPY NUMBER
                  , p_item1_project_raw_cost      IN NUMBER  default null  -- project raw
                  , p_item1_project_burden_cost   IN NUMBER  default null  -- project burden
                  , p_item2_project_raw_cost      IN NUMBER  default null  -- project raw
                  , p_item2_project_burden_cost   IN NUMBER  default null  -- project burden
                  );

  PROCEDURE  Transfer(ItemsIdTab           IN pa_utils.IdTabTyp
                     , X_dest_prj_id     IN NUMBER
                     , X_dest_task_id    IN NUMBER
		     , X_project_currency_code IN VARCHAR2
		     , X_project_rate_type     IN VARCHAR2
		     , X_project_rate_date     IN DATE
		     , X_project_exchange_rate IN NUMBER
                     , X_user            IN NUMBER
                     , X_login           IN NUMBER
                     , X_module          IN VARCHAR2
                     , X_adjust_level    IN VARCHAR2
                     , rows              IN BINARY_INTEGER
                     , X_num_processed   OUT NOCOPY NUMBER
                     , X_num_rejected    OUT NOCOPY NUMBER
                     , X_outcome         OUT NOCOPY VARCHAR2
		     , X_msg_application OUT NOCOPY VARCHAR2
		     , X_msg_type        OUT NOCOPY VARCHAR2
		     , X_msg_token1      OUT NOCOPY VARCHAR2
		     , X_msg_token2      OUT NOCOPY VARCHAR2
		     , X_msg_token3      OUT NOCOPY VARCHAR2
		     , X_msg_count       OUT NOCOPY Number
                     , p_projfunc_currency_code IN VARCHAR2      default null
                     , p_projfunc_cost_rate_type     IN VARCHAR2 default null
                     , p_projfunc_cost_rate_date     IN DATE     default null
                     , p_projfunc_cost_exchg_rate IN NUMBER      default null
                     , p_assignment_id         IN  NUMBER        default null
                     , p_work_type_id          IN  NUMBER        default null );

-- Added New parameters acct rate attributes  and denom currency for new MC     -- adjustments to Adjust
-- Added new parameters X_cc_code, X_cc_type, X_bl_dist_code and
-- X_ic_proc_code as part of the new CC adjustments

  PROCEDURE  Adjust( X_adj_action           IN VARCHAR2
                   , X_module               IN VARCHAR2
                   , X_user                 IN NUMBER
                   , X_login                IN NUMBER
                   , X_project_id           IN NUMBER
                   , X_adjust_level         IN VARCHAR2
                   , X_expenditure_item_id  IN NUMBER    DEFAULT NULL
                   , X_dest_prj_id          IN NUMBER    DEFAULT NULL
                   , X_dest_task_id         IN NUMBER    DEFAULT NULL
     		   , X_project_currency_code IN VARCHAR2 DEFAULT NULL
		   , X_project_rate_type     IN VARCHAR2 DEFAULT NULL
		   , X_project_rate_date     IN DATE     DEFAULT NULL
		   , X_project_exchange_rate IN NUMBER   DEFAULT NULL
		   , X_acct_rate_type        IN VARCHAR2 DEFAULT NULL
		   , X_acct_rate_date        IN DATE     DEFAULT NULL
		   , X_acct_exchange_rate    IN NUMBER   DEFAULT NULL
                   , X_task_id              IN NUMBER    DEFAULT NULL
                   , X_inc_by_person_id     IN NUMBER    DEFAULT NULL
                   , X_inc_by_org_id        IN NUMBER    DEFAULT NULL
                   , X_ei_date_low          IN DATE      DEFAULT NULL
                   , X_ei_date_high         IN DATE      DEFAULT NULL
                   , X_system_linkage       IN VARCHAR2  DEFAULT NULL
                   , X_expenditure_type     IN VARCHAR2  DEFAULT NULL
                   , X_vendor_id            IN NUMBER    DEFAULT NULL
                   , X_nl_resource_org_id   IN NUMBER    DEFAULT NULL
                   , X_nl_resource          IN VARCHAR2  DEFAULT NULL
                   , X_bill_status          IN VARCHAR2  DEFAULT NULL
                   , X_hold_flag            IN VARCHAR2  DEFAULT NULL
                   , X_expenditure_comment  IN VARCHAR2  DEFAULT NULL
                   , X_inv_num              IN NUMBER    DEFAULT NULL
                   , X_inv_line_num         IN NUMBER    DEFAULT NULL
                   , X_cc_code              IN VARCHAR2  DEFAULT NULL
                   , X_cc_type              IN VARCHAR2  DEFAULT NULL
                   , X_bl_dist_code         IN VARCHAR2  DEFAULT NULL
                   , X_ic_proc_code         IN VARCHAR2  DEFAULT NULL
                   , X_prvdr_orgnzn_id      IN NUMBER   DEFAULT NULL
                   , X_recvr_orgnzn_id      IN NUMBER   DEFAULT NULL
                   , X_outcome              OUT NOCOPY VARCHAR2
                   , X_num_processed        OUT NOCOPY NUMBER
                   , X_num_rejected         OUT NOCOPY NUMBER
		   , X_msg_application 	    OUT NOCOPY VARCHAR2
		   , X_msg_type		    OUT NOCOPY VARCHAR2
		   , X_msg_token1 	    OUT NOCOPY VARCHAR2
		   , X_msg_token2	    OUT NOCOPY VARCHAR2
		   , X_msg_token3	    OUT NOCOPY VARCHAR2
		   , X_msg_count	    OUT NOCOPY Number
                    /* added for proj currency  and additional EI attributes **/
                   , p_assignment_id                IN NUMBER  default null
                   , p_work_type_id                 IN NUMBER  default null
                   , p_projfunc_currency_code       IN varchar2 default null
                   , p_projfunc_cost_rate_date      IN date  default  null
                   , p_projfunc_cost_rate_type      IN varchar2 default null
                   , p_projfunc_cost_exchange_rate  IN number default null
                   , p_project_raw_cost             IN number default null
                   , p_project_burdened_cost        IN number default null
                   , p_project_tp_currency_code     IN varchar2 default null
                   , p_project_tp_cost_rate_date    IN date default null
                   , p_project_tp_cost_rate_type    IN  varchar2 default null
                   , p_project_tp_cost_exchg_rate   IN number default null
                   , p_project_transfer_price       IN number default null
	           , p_dest_work_type_id            IN NUMBER  default null
                   , p_tp_amt_type_code             IN varchar2 default null
                   , p_dest_tp_amt_type_code        IN varchar2 default null
                    /** end of proj currency  and additional EI attributes **/
                    );

-- Added new parameters acct rate attributes and denon currency to
-- massadjust procedure for new MC adjustments

  /*
   * IC related changes
   * New parameters added against IC
   */
  PROCEDURE  MassAdjust(
             X_adj_action                IN VARCHAR2
           , X_module                    IN VARCHAR2
           , X_user                      IN NUMBER
           , X_login                     IN NUMBER
           , X_project_id                IN NUMBER
           , X_dest_prj_id               IN NUMBER    DEFAULT NULL
           , X_dest_task_id              IN NUMBER    DEFAULT NULL
           , X_project_currency_code     IN VARCHAR2  DEFAULT NULL
           , X_project_rate_type         IN VARCHAR2  DEFAULT NULL
           , X_project_rate_date         IN DATE      DEFAULT NULL
           , X_project_exchange_rate     IN NUMBER    DEFAULT NULL
           , X_acct_rate_type            IN VARCHAR2  DEFAULT NULL
	   , X_acct_rate_date            IN DATE      DEFAULT NULL
	   , X_acct_exchange_rate        IN NUMBER    DEFAULT NULL
           , X_task_id                   IN NUMBER    DEFAULT NULL
           , X_inc_by_person_id          IN NUMBER    DEFAULT NULL
           , X_inc_by_org_id             IN NUMBER    DEFAULT NULL
           , X_ei_date_low               IN DATE      DEFAULT NULL
           , X_ei_date_high              IN DATE      DEFAULT NULL
           , X_ex_end_date_low           IN DATE      DEFAULT NULL
           , X_ex_end_date_high          IN DATE      DEFAULT NULL
           , X_system_linkage            IN VARCHAR2  DEFAULT NULL
           , X_expenditure_type          IN VARCHAR2  DEFAULT NULL
           , X_expenditure_catg          IN VARCHAR2  DEFAULT NULL
           , X_expenditure_group         IN VARCHAR2  DEFAULT NULL
           , X_vendor_id                 IN NUMBER    DEFAULT NULL
           , X_job_id                    IN NUMBER    DEFAULT NULL
           , X_nl_resource_org_id        IN NUMBER    DEFAULT NULL
           , X_nl_resource               IN VARCHAR2  DEFAULT NULL
           , X_transaction_source        IN VARCHAR2  DEFAULT NULL
           , X_cost_distributed_flag     IN VARCHAR2  DEFAULT NULL
           , X_revenue_distributed_flag  IN VARCHAR2  DEFAULT NULL
           , X_grouped_cip_flag          IN VARCHAR2  DEFAULT NULL
           , X_bill_status               IN VARCHAR2  DEFAULT NULL
           , X_hold_flag                 IN VARCHAR2  DEFAULT NULL
           , X_billable_flag             IN VARCHAR2  DEFAULT NULL
           , X_capitalizable_flag        IN VARCHAR2  DEFAULT NULL
           , X_net_zero_adjust_flag      IN VARCHAR2  DEFAULT NULL
           , X_inv_num                   IN NUMBER    DEFAULT NULL
           , X_inv_line_num              IN NUMBER    DEFAULT NULL
           , X_cc_code_to_be_determined  IN VARCHAR2  DEFAULT 'N'
           , X_cc_code_not_crosscharged  IN VARCHAR2  DEFAULT 'XX'
           , X_cc_code_intra_ou          IN VARCHAR2  DEFAULT 'XX'
           , X_cc_code_inter_ou          IN VARCHAR2  DEFAULT 'XX'
           , X_cc_code_intercompany      IN VARCHAR2  DEFAULT 'XX'
           , X_cc_type_no_processing     IN VARCHAR2  DEFAULT 'Z'
           , X_cc_type_b_and_l           IN VARCHAR2  DEFAULT 'Z'
           , X_cc_type_ic_billing        IN VARCHAR2  DEFAULT 'Z'
           , X_cc_prvdr_organization_id  IN NUMBER    DEFAULT NULL
           , X_cc_prvdr_ou               IN NUMBER    DEFAULT NULL
           , X_cc_recvr_organization_id  IN NUMBER    DEFAULT NULL
           , X_cc_recvr_ou               IN NUMBER    DEFAULT NULL
           , X_cc_bl_distributed_code    IN VARCHAR2  DEFAULT NULL
           , X_cc_ic_processed_code      IN VARCHAR2  DEFAULT NULL
           , X_expenditure_item_id       IN NUMBER    DEFAULT NULL
           , X_outcome                   OUT NOCOPY VARCHAR2
           , X_num_processed             OUT NOCOPY NUMBER
           , X_num_rejected              OUT NOCOPY NUMBER
           /* added for proj currency  and additional EI attributes **/
           , p_assignment_id                IN NUMBER  default null
           , p_work_type_id                 IN NUMBER  default null
           , p_projfunc_currency_code       IN varchar2 default null
           , p_projfunc_cost_rate_date      IN date  default  null
           , p_projfunc_cost_rate_type      IN varchar2 default null
           , p_projfunc_cost_exchange_rate  IN number default null
           , p_project_raw_cost             IN number default null
           , p_project_burdened_cost        IN number default null
           , p_project_tp_currency_code     IN varchar2 default null
           , p_project_tp_cost_rate_date    IN date default null
           , p_project_tp_cost_rate_type    IN  varchar2 default null
           , p_project_tp_cost_exchg_rate   IN number default null
           , p_project_transfer_price       IN number default null
           , p_dest_work_type_id            IN NUMBER  default null
           , p_dest_tp_amt_type_code        IN varchar2  default null
           , p_dest_wt_start_date           IN date  default null
           , p_dest_wt_end_date             IN date  default null
           -- New parameters addes for FP 'L' additional attributes.
           , p_grouped_rwip_flag            IN varchar2 default null
           , p_capital_event_number         IN number default null
           , p_start_gl_date                IN date  default null
           , p_end_gl_date                  IN date  default null
           , p_start_pa_date                IN date  default null
           , p_end_pa_date                  IN date  default null
           , p_recvr_start_gl_date          IN date  default null
           , p_recvr_end_gl_date            IN date  default null
           , p_recvr_start_pa_date          IN date  default null
           , p_recvr_end_pa_date            IN date  default null
/* R12 Changes - Start */
           , p_invoice_id                   IN NUMBER DEFAULT NULL
           , p_invoice_line_number          IN NUMBER DEFAULT NULL
           , p_include_related_tax_lines    IN VARCHAR2 DEFAULT NULL
	   , p_receipt_number               IN VARCHAR2 DEFAULT NULL
	   , p_check_id                     IN NUMBER DEFAULT NULL /* 4914048 */
           , p_org_id                       IN NUMBER DEFAULT NULL
           , p_dest_award_id                IN NUMBER DEFAULT NULL
           , p_rev_exp_items_req_adjust     IN VARCHAR2 DEFAULT NULL
           , p_award_id                     IN NUMBER DEFAULT NULL /* 5194785 */
           , p_expensed_flag                IN VARCHAR2 DEFAULT NULL
           , p_wip_resource_id              IN NUMBER DEFAULT NULL
           , p_inventory_item_id            IN NUMBER DEFAULT NULL
/* R12 Changes - End */
           );


-- Added new parameters acct rate attributes and denon currency to
-- massaction procedure for new MC adjustments

  PROCEDURE  MassAction(
             ItemsIdTab                  IN pa_utils.IdTabTyp
           , AdjustsIdTab                IN pa_utils.IdTabTyp
           , X_adj_action                IN VARCHAR2
           , X_module                    IN VARCHAR2
           , X_user                      IN NUMBER
           , X_login                     IN NUMBER
           , X_num_rows                  IN NUMBER
           , X_dest_prj_id               IN NUMBER    DEFAULT NULL
           , X_dest_task_id              IN NUMBER    DEFAULT NULL
           , X_project_currency_code     IN VARCHAR2  DEFAULT NULL
           , X_project_rate_type     	 IN VARCHAR2  DEFAULT NULL
           , X_project_rate_date     	 IN DATE      DEFAULT NULL
           , X_project_exchange_rate 	 IN NUMBER    DEFAULT NULL
           , X_acct_rate_type            IN VARCHAR2  DEFAULT NULL
	   , X_acct_rate_date            IN DATE      DEFAULT NULL
	   , X_acct_exchange_rate        IN NUMBER    DEFAULT NULL
           , DenomCurrCodeTab            IN pa_utils.Char15TabTyp
           , ProjCurrCodeTab             IN pa_utils.Char15TabTyp
           , X_status                    OUT NOCOPY VARCHAR2
           , X_num_processed             OUT NOCOPY NUMBER
           , X_num_rejected              OUT NOCOPY NUMBER
           , ProjFuncCurrCodeTab           IN pa_utils.Char15TabTyp
           , p_projfunc_cost_rate_type     IN VARCHAR2      DEFAULT NULL
           , p_projfunc_cost_rate_date     IN date  DEFAULT NULL
           , p_projfunc_cost_exchange_rate IN NUMBER     DEFAULT NULL
           , p_project_tp_cost_rate_type   IN VARCHAR2      DEFAULT NULL
           , p_project_tp_cost_rate_date   IN DATE  DEFAULT NULL
           , p_project_tp_cost_exchg_rate  IN NUMBER DEFAULT NULL
           , p_assignment_id               IN NUMBER DEFAULT NULL
           , p_work_type_id                IN NUMBER DEFAULT NULL
           , p_projfunc_currency_code      IN VARCHAR2      DEFAULT NULL
           , p_TpAmtTypCodeTab             IN pa_utils.Char30TabTyp
           , p_dest_tp_amt_type_code       IN VARCHAR2      DEFAULT NULL);

/* ---------------------------------------------------------------------------
-- Start of Comments
-- API Name       : ei_adjusted_in_cache
-- Type           : Public
-- Pre-Reqs       : None
-- Function       : This function checks if the expenditure item that is passed
--                  in as parameter is already adjusted in cache( This is for
--                  transaction import program because it stores all the data
--                  in cache.) If it's adjusted, it returns a value of Y else
--                  returns N.
-- Purity        : WNDS, WNPS.
-- Parameters    :
-- IN            : Expenditure_item_id
-- RETURNS       : VARCHAR2
-- End of Comments
-----------------------------------------------------------------------------*/

  FUNCTION ei_adjusted_in_cache(X_exp_item_id   IN Number) RETURN Varchar2;

  --pragma RESTRICT_REFERENCES(ei_adjusted_in_cache,WNDS,WNPS);


  PROCEDURE  ChangeFuncAttributes(ItemsIdTab IN pa_utils.IdTabTyp
                          , X_adjust_level   IN VARCHAR2
                          , X_user           IN NUMBER
                          , X_login          IN NUMBER
                          , X_module         IN VARCHAR2
                          , X_acct_rate_type IN VARCHAR2
			  , X_acct_rate_date IN DATE
			  , X_acct_exchange_rate IN NUMBER
                          , DenomCurrCodeTab     IN pa_utils.Char15TabTyp
                          , ProjCurrCodeTab      IN  pa_utils.Char15TabTyp
                          , rows             IN NUMBER
                          , X_num_processed  OUT NOCOPY NUMBER
                          , X_num_rejected   OUT NOCOPY NUMBER
                          , X_status         OUT NOCOPY NUMBER
                          , ProjfuncCurrCodeTab IN pa_utils.Char15TabTyp  );


  PROCEDURE  ChangeProjAttributes(ItemsIdTab IN pa_utils.IdTabTyp
                          , X_adjust_level   IN VARCHAR2
                          , X_user           IN NUMBER
                          , X_login          IN NUMBER
                          , X_module         IN VARCHAR2
                          , X_project_rate_type     IN VARCHAR2
			  , X_project_rate_date     IN DATE
			  , X_project_exchange_rate IN NUMBER
                          , DenomCurrCodeTab        IN pa_utils.Char15TabTyp
                          , ProjCurrCodeTab         IN  pa_utils.Char15TabTyp
                          , rows             IN NUMBER
                          , X_num_processed  OUT NOCOPY NUMBER
                          , X_num_rejected   OUT NOCOPY NUMBER
                          , X_status         OUT NOCOPY NUMBER );

-- Added the following new procedures for the Cross Charge Adjustments

  PROCEDURE  ReprocessCrossCharge(ItemsIdTab       IN pa_utils.IdTabTyp
                                , X_adjust_level   IN VARCHAR2
                                , X_user           IN NUMBER
                                , X_login          IN NUMBER
                                , X_module         IN VARCHAR2
                                , X_cc_code        IN VARCHAR2
                                , X_cc_type        IN VARCHAR2
                                , X_bl_dist_code   IN VARCHAR2
                                , X_ic_proc_code   IN VARCHAR2
                                , X_prvdr_orgnzn_id IN NUMBER
                                , X_recvr_orgnzn_id IN NUMBER
                                , rows             IN NUMBER
                                , X_num_processed  OUT NOCOPY NUMBER
                                , X_status         OUT NOCOPY NUMBER );

  PROCEDURE  MarkNoCCProcess     (ItemsIdTab       IN pa_utils.IdTabTyp
                                , X_adjust_level   IN VARCHAR2
                                , X_user           IN NUMBER
                                , X_login          IN NUMBER
                                , X_module         IN VARCHAR2
                                , X_bl_dist_code   IN VARCHAR2
                                , X_ic_proc_code   IN VARCHAR2
                                , rows             IN NUMBER
                                , X_num_processed  OUT NOCOPY NUMBER
                                , X_status         OUT NOCOPY NUMBER );

  PROCEDURE  ChangeTPAttributes(ItemsIdTab          IN pa_utils.IdTabTyp
                          , X_adjust_level          IN VARCHAR2
                          , X_user                  IN NUMBER
                          , X_login                 IN NUMBER
                          , X_module                IN VARCHAR2
                          , X_acct_tp_rate_type     IN VARCHAR2
			  , X_acct_tp_rate_date     IN DATE
			  , X_acct_tp_exchange_rate IN NUMBER
    	                  , X_bl_dist_code          IN VARCHAR2
                          , X_ic_proc_code          IN VARCHAR2
                          , DenomCurrCodeTab        IN pa_utils.Char15TabTyp
                          , rows                    IN NUMBER
                          , X_num_processed         OUT NOCOPY NUMBER
                          , X_num_rejected          OUT NOCOPY NUMBER
                          , X_status                OUT NOCOPY NUMBER
                          , p_PROJECT_TP_COST_RATE_DATE             IN   DATE     default null
                          , p_PROJECT_TP_COST_RATE_TYPE             IN   VARCHAR2 default null
                          , p_PROJECT_TP_COST_EXCHG_RATE         IN   NUMBER   default null
                          );


/* ---------------------------------------------------------------------------
-- Start of Comments
-- API Name       : allow_adjustment
-- Type           : Public
-- Pre-Reqs       : None
-- Function       : This procedure is called when a user attempts to make an
--                  adjustment in Projects to an expenditure item which was imported
--                  from an external system.
--
--                  1) If the transaction source is seeded (except SST) then
--                  the procedure will return pa_transaction_sources.allow_adjustment_flag.
--
--                  2) If the transaction source is SST, then it will check if the item has
--                  already been adjusted in SST.  If it has already been adjusted, then
--                  no adjustment will be allowed.
--
--                  3) If the transaction souce is not seeded then the
--                  allow_adjustment_extn client extension will be called.  By
--                  default, the client extn will return pa_transaction_sources.allow_adjustment_flag.
--
--
-- Parameters:
--
-- IN
--                             p_transaction_source                   IN VARCHAR2
--                             p_orig_transaction_reference           IN VARCHAR2
--                             p_expenditure_type_class               IN VARCHAR2
--                             p_expenditure_type                     IN VARCHAR2
--                             p_expenditure_item_id                  IN NUMBER
--                             p_expenditure_item_date                IN DATE
--                             p_employee_number                      IN VARCHAR2
--                             p_expenditure_organization_name        IN VARCHAR2
--                             p_project_number                       IN VARCHAR2
--                             p_task_number                          IN VARCHAR2
--                             p_non_labor_resource                   IN VARCHAR2
--                             p_non_labor_resource_org_name          IN VARCHAR2
--                             p_quantity                             IN NUMBER
--                             p_raw_cost                             IN NUMBER
--                             p_attribute_category                   IN VARCHAR2
--                             p_attribute1                           IN VARCHAR2
--                             p_attribute2                           IN VARCHAR2
--                             p_attribute3                           IN VARCHAR2
--                             p_attribute4                           IN VARCHAR2
--                             p_attribute5                           IN VARCHAR2
--                             p_attribute6                           IN VARCHAR2
--                             p_attribute7                           IN VARCHAR2
--                             p_attribute8                           IN VARCHAR2
--                             p_attribute9                           IN VARCHAR2
--                             p_attribute10                          IN VARCHAR2
--                             p_org_id                               IN NUMBER
--OUT
--                             x_adjustment_status_code               OUT NOCOPY VARCHAR2
--                             x_return_status                        OUT NOCOPY VARCHAR2
--                             x_application_code                     OUT NOCOPY VARCHAR2,
--                             x_message_code                         OUT NOCOPY VARCHAR2,
--                             x_token_name1                          OUT NOCOPY VARCHAR2,
--                             x_token_val1                           OUT NOCOPY VARCHAR2,
--                             x_token_name2                          OUT NOCOPY VARCHAR2,
--                             x_token_val2                           OUT NOCOPY VARCHAR2,
--                             x_token_name3                          OUT NOCOPY VARCHAR2,
--                             x_token_val3                           OUT NOCOPY VARCHAR2);
--
------------------------------------------------------------------------------------------*/

PROCEDURE allow_adjustment(
                             p_transaction_source                   IN VARCHAR2,
                             p_orig_transaction_reference           IN VARCHAR2,
                             p_expenditure_type_class               IN VARCHAR2,
                             p_expenditure_type                     IN VARCHAR2,
                             p_expenditure_item_id                  IN NUMBER,
                             p_expenditure_item_date                IN DATE,
                             p_employee_number                      IN VARCHAR2,
                             p_expenditure_org_name                 IN VARCHAR2,
                             p_project_number                       IN VARCHAR2,
                             p_task_number                          IN VARCHAR2,
                             p_non_labor_resource                   IN VARCHAR2,
                             p_non_labor_resource_org_name          IN VARCHAR2,
                             p_quantity                             IN NUMBER,
                             p_raw_cost                             IN NUMBER,
                             p_attribute_category                   IN VARCHAR2,
                             p_attribute1                           IN VARCHAR2,
                             p_attribute2                           IN VARCHAR2,
                             p_attribute3                           IN VARCHAR2,
                             p_attribute4                           IN VARCHAR2,
                             p_attribute5                           IN VARCHAR2,
                             p_attribute6                           IN VARCHAR2,
                             p_attribute7                           IN VARCHAR2,
                             p_attribute8                           IN VARCHAR2,
                             p_attribute9                           IN VARCHAR2,
                             p_attribute10                          IN VARCHAR2,
                             p_org_id                               IN NUMBER,
                             x_allow_adjustment_code                OUT NOCOPY VARCHAR2,
                             x_return_status                        OUT NOCOPY VARCHAR2,
                             x_application_code                     OUT NOCOPY VARCHAR2,
                             x_message_code                         OUT NOCOPY VARCHAR2,
                             x_token_name1                          OUT NOCOPY VARCHAR2,
                             x_token_val1                           OUT NOCOPY VARCHAR2,
                             x_token_name2                          OUT NOCOPY VARCHAR2,
                             x_token_val2                           OUT NOCOPY VARCHAR2,
                             x_token_name3                          OUT NOCOPY VARCHAR2,
                             x_token_val3                           OUT NOCOPY VARCHAR2);

/** This api is newly added to convert / change the project functional currency attributes
 *  this is called from EI enquiry form for EI adjustments
 */
  PROCEDURE  ChangeProjFuncAttributes
                         (ItemsIdTab                    IN pa_utils.IdTabTyp
                          , p_adjust_level              IN VARCHAR2
                          , p_user                      IN NUMBER
                          , p_login                     IN NUMBER
                          , p_module                    IN VARCHAR2
                          , p_projfunc_cost_rate_type   IN VARCHAR2
                          , p_projfunc_cost_rate_date   IN DATE
                          , p_projfunc_cost_exchg_rate  IN NUMBER
                          , p_DenomCurrCodeTab          IN pa_utils.Char15TabTyp
                          , p_ProjFuncCurrCodeTab       IN pa_utils.Char15TabTyp
                          , p_rows                      IN NUMBER
                          , X_num_processed             OUT NOCOPY NUMBER
                          , X_num_rejected              OUT NOCOPY NUMBER
                          , X_status                    OUT NOCOPY NUMBER ) ;

FUNCTION is_proj_billable(p_task_id   IN  number) return varchar2 ;
  --pragma RESTRICT_REFERENCES(is_proj_billable ,WNDS,WNPS);

/* Bug#2291180 : This function is added which returns denom_currency_code */
/* This is used during adjustments to update denom_currency_code */
FUNCTION get_denom_curr_code
	(p_transaction_source        IN VARCHAR2
         , p_exp_type                IN VARCHAR2
         , p_denom_currency_code     IN VARCHAR2
         , p_acct_currency_code      IN VARCHAR2
         , p_system_linkage_function IN VARCHAR2
	 , p_calling_mode            IN VARCHAR2 default 'ADJUST' /*Bugfix:2798742 */
	 , p_person_id               IN NUMBER   default NULL    /*Bugfix:2798742 */
	 , p_ei_date                 IN DATE     default NULL   /*Bugfix:2798742 */
         ) RETURN VARCHAR2;


/* R12 Changes Start
   This function returns FALSE if Auto Offset Option is enabled
   and the adjustment action 'p_action' results in a Charge account
   which violates the Auto Offset Rules */
FUNCTION Allow_Adjust_with_Auto_Offset
         (p_expenditure_item_id         IN NUMBER,
          p_org_id                      IN NUMBER,
          p_system_linkage_function     IN VARCHAR2,
          p_transaction_source          IN VARCHAR2,
          P_action                      IN VARCHAR2,
          P_project_id                  IN NUMBER,
          P_task_id                     IN NUMBER,
          p_expenditure_type            IN VARCHAR2,
          p_vendor_id                   IN NUMBER,
          p_expenditure_organization_id IN NUMBER,
          p_expenditure_item_date       IN DATE,
          p_emp_id                      IN NUMBER,
          p_invoice_distribution_id     IN NUMBER,
          p_invoice_payment_id          IN AP_INVOICE_PAYMENTS_ALL.INVOICE_PAYMENT_ID%TYPE, /* Bug 5006835 */
          p_award_id                    IN NUMBER   DEFAULT NULL,
          p_billable_flag1              IN VARCHAR2 DEFAULT NULL,
          p_billable_flag2              IN VARCHAR2 DEFAULT NULL,
          x_encoded_error_message       OUT NOCOPY VARCHAR2) /* Bug 4997739 */
RETURN BOOLEAN;
/* R12 changes End */

/* R12 Changes Start */
FUNCTION Get_Displayed_Field
    ( p_lookup_type varchar2
    , p_lookup_code varchar2)
RETURN VARCHAR2;

FUNCTION Get_PO_Info
    ( p_key varchar2
    , p_po_distribution_id number)
RETURN VARCHAR2;

FUNCTION Get_Rcv_Info
    ( p_key varchar2
    , p_rcv_transaction_id number)
RETURN VARCHAR2;

FUNCTION Get_Inv_Info
    ( p_key varchar2
    , p_invoice_id number)
RETURN VARCHAR2;

   FUNCTION is_recoverability_affected
         (p_expenditure_item_id         IN NUMBER,
          p_org_id                      IN NUMBER,
          p_system_linkage_function     IN VARCHAR2,
          p_transaction_source          IN VARCHAR2,
          P_action                      IN VARCHAR2,
          P_project_id                  IN NUMBER,
          P_task_id                     IN NUMBER,
          p_expenditure_type            IN VARCHAR2,
          p_vendor_id                   IN NUMBER,
          p_expenditure_organization_id IN NUMBER,
          p_expenditure_item_date       IN DATE,
          p_emp_id                      IN NUMBER,
          p_document_header_id          IN NUMBER,
          p_document_line_number        IN NUMBER,
          p_document_distribution_id    IN NUMBER,
          p_document_type               IN VARCHAR2,
          p_award_id                    IN NUMBER   DEFAULT NULL,
          p_billable_flag1              IN VARCHAR2 DEFAULT NULL,
          p_billable_flag2              IN VARCHAR2 DEFAULT NULL,
          x_error_message_name          OUT NOCOPY VARCHAR2,
          x_encoded_error_message       OUT NOCOPY VARCHAR2) /* Bug 4997739 */
   return BOOLEAN;
/* R12 Changes End */

/* Bug 4901129 - Start */
FUNCTION is_orphaned_src_sys_reversal( p_document_distribution_id IN PA_EXPENDITURE_ITEMS_ALL.DOCUMENT_DISTRIBUTION_ID%TYPE
                                     , p_transaction_source IN PA_EXPENDITURE_ITEMS_ALL.TRANSACTION_SOURCE%TYPE)
RETURN VARCHAR2;
/* Bug 4901129 - End */

FUNCTION RepCurrOrSecLedgerDiffCurr(p_org_id PA_EXPENDITURE_ITEMS_ALL.ORG_ID%TYPE) RETURN BOOLEAN; /* Bug 5235354 */

/* Bug 5381260 - Start */
FUNCTION IsPeriodEndAccrual(p_invoice_distribution_id AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_DISTRIBUTION_ID%TYPE)
RETURN BOOLEAN;
/* Bug 5381260 - End */

/* Bug 5501250 - Start */
FUNCTION IsRelatedToPrepayApp(
  p_invoice_distribution_id AP_INVOICE_DISTRIBUTIONS_ALL.INVOICE_DISTRIBUTION_ID%TYPE
) RETURN BOOLEAN;
/* Bug 5501250 - End */

FUNCTION getprojburdenflag(p_project_id IN NUMBER) RETURN VARCHAR2;/*Bug# 5874347*/

END PA_ADJUSTMENTS;

 

/
