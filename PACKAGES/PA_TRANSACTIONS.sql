--------------------------------------------------------
--  DDL for Package PA_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TRANSACTIONS" AUTHID CURRENT_USER AS
/* $Header: PAXTRANS.pls 120.6.12010000.3 2009/06/18 08:28:10 abjacob ship $ */
/*#
 * This extension is used to create related transactions.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Related Transactions Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_LABOR_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/* Adding new global variable for the bug fix: 3258043
 * if the transaction import process calls the insItems procedure with
 * gl_accounted_flag = 'Y' then DONOT overide the gl period and date info
 */
   GL_ACCOUNTED_FLAG    VARCHAR2(1) := 'N';

/*----------------------------------------------------------------------------
   The following two PL/SQL tables are used by the triggers on
   PA_TRANSACTION_INTERFACE in order to workaround the "mutating table"
   restriction for triggers.  These triggers are part of the Transaction
   Import utility.  For more information on exactly how TI uses these
   PL/SQL tables and how the workaround functions, refer to the following
   document:
   $pa/designs/transaction/trx_import/mutating_table_trigger_workaround.doc
------------------------------------------------------------------------------*/
  TrxSrcTab       pa_utils.Char30TabTyp;
  BatchNameTab    pa_utils.Char10TabTyp;


/*----------------------------------------------------------------------------
   The following PL/SQL tables are used by several programs including
   Transaction Import and the Transfer prodedure of the PA Adjustments
   package.  These PL/SQL tables are loaded with VALIDATED expenditure items
   and then inserted into PA_EXPENDITURE_ITEMS using the
   pa_transactions.InsItems procedure.  This method allows the programs to
   store validated items one at a time until all items are validated.  The
   items can then either be inserted into PA_EXPENDITURE_ITEMS with one call
   to pa_transactions.InsItems or can be rolled back using the
   pa_transactions.FlushEiTabs procedure without having to execute any DDL
   statements.
------------------------------------------------------------------------------*/

  EiIdTab        pa_utils.IdTabTyp;
  EIdTab         pa_utils.IdTabTyp;
  ProjIdTab      pa_utils.IdTabtyp;
  TskIdTab       pa_utils.IdTabTyp;
  EiDateTab      pa_utils.DateTabTyp;
  ETypTab        pa_utils.Char30TabTyp;
  NlRscTab       pa_utils.Char20TabTyp;
  NlRscOrgTab    pa_utils.IdTabTyp;
  BillFlagTab    pa_utils.Char1TabTyp;
  BillHoldTab    pa_utils.Char1TabTyp;
  QtyTab         pa_utils.AmtTabTyp;
  RawCostTab     pa_utils.AmtTabTyp;
  RawRateTab     pa_utils.AmtTabTyp;
  OvrOrgTab      pa_utils.IdTabTyp;
  AdjEiTab       pa_utils.IdTabTyp;
  TrxRefTab      pa_utils.Char30TabTyp;
  EiTrxSrcTab    pa_utils.Char30TabTyp;
  AttCatTab      pa_utils.Char30TabTyp;
  Att1Tab        pa_utils.Char150TabTyp;
  Att2Tab        pa_utils.Char150TabTyp;
  Att3Tab        pa_utils.Char150TabTyp;
  Att4Tab        pa_utils.Char150TabTyp;
  Att5Tab        pa_utils.Char150TabTyp;
  Att6Tab        pa_utils.Char150TabTyp;
  Att7Tab        pa_utils.Char150TabTyp;
  Att8Tab        pa_utils.Char150TabTyp;
  Att9Tab        pa_utils.Char150TabTyp;
  Att10Tab       pa_utils.Char150TabTyp;
  SrcEiTab       pa_utils.IdTabTyp;
  EiCommentTab   pa_utils.Char240TabTyp;
  TfrEiTab       pa_utils.IdTabTyp;
  JobIdTab       pa_utils.IdTabTyp;
  OrgIdTab       pa_utils.IdTabTyp;
  LCMTab         pa_utils.Char20TabTyp ;
  DrccidIdTab    pa_utils.IdTabTyp ;
  CrccidIdTab    pa_utils.IdTabTyp ;
  Cdlsr1Tab      pa_utils.Char30TabTyp ;
  Cdlsr2Tab      pa_utils.Char30TabTyp ;
  Cdlsr3Tab      pa_utils.Char30TabTyp ;
  GldateTab      pa_utils.DateTabTyp ;
  BCostTab       pa_utils.AmtTabTyp;
  BCostRateTab   pa_utils.AmtTabTyp;
  EtypeClassTab  pa_utils.Char30TabTyp ;
  BurdenDestId   pa_utils.IdTabTyp;
  BurdenCompSetId pa_utils.IdTabTyp;
  ReceiptCurrAmt pa_utils.NewAmtTabTyp;
  ReceiptCurrCode pa_utils.Char15TabTyp;
  ReceiptExRate  pa_utils.NewAmtTabTyp;
  DenomCurrCode  pa_utils.Char15TabTyp;
  DenomRawCost   pa_utils.NewAmtTabTyp;
  DenomBurdenCost pa_utils.NewAmtTabTyp;
  AcctCurrCode   pa_utils.Char15TabTyp;
  AcctRateDate   pa_utils.DateTabTyp;
  AcctRateType   pa_utils.Char30TabTyp;
  AcctExRate     pa_utils.NewAmtTabTyp;
  AcctRawCost    pa_utils.NewAmtTabTyp;
  AcctBurdenCost pa_utils.NewAmtTabTyp;
  AcctRoundLmt   pa_utils.NewAmtTabTyp;
  ProjCurrCode   pa_utils.Char15TabTyp;
  ProjRateType   pa_utils.Char30TabTyp;
  ProjRateDate   pa_utils.DateTabTyp;
  ProjExRate     pa_utils.NewAmtTabTyp;

  -- IC Changes
  CrossChargeTypeTab   pa_utils.Char10TabTyp;
  CrossChargeCodeTab   pa_utils.Char1TAbTyp;
  PrvdrOrganizationTab pa_utils.IdTabTyp;
  RecvOrganizationTab  pa_utils.IdTabTyp;
  RecvOperUnitTab      pa_utils.IdTabTyp;
  IcProcessedCodeTab   pa_utils.Char1TAbTyp;
  BorrowLentCodeTab    pa_utils.Char1TabTyp;
  DenomTpCurrCodeTab   pa_utils.Char15TabTyp;
  DenomTransferPriceTab pa_utils.NewAmtTabTyp;
  AcctTpRateTypeTab     pa_utils.Char30TabTyp;
  AcctTpRateDateTab     pa_utils.DateTabTyp;
  AcctTpExchangeRateTab pa_utils.NewAmtTabTyp;
  AcctTransferPriceTab   pa_utils.NewAmtTabTyp;
  ProjacctTransferPriceTab pa_utils.NewAmtTabTyp;
  CcMarkupBaseCodeTab   pa_utils.Char1TAbTyp;
  TpBaseAmountTab        pa_utils.NewAmtTabTyp;
  TpIndCompiledSetIdTab pa_utils.IdTabTyp;
  TpBillRateTab           pa_utils.NewAmtTabTyp;
  TpBillMarkupPercentageTab pa_utils.AmtTabTyp;
  TpSchLinePercentageTab  pa_utils.AmtTabTyp;
  TpRulePercentageTab     pa_utils.AmtTabTyp;
 -- END IC Changes

 -- Begin CBGA changes for new jobs model in 11i
  CostJobIdTab       	      pa_utils.IdTabTyp;
  ProvProjBillJobIdTab        pa_utils.IdTabTyp;
  TPJobIdTab       	      pa_utils.IdTabTyp;
 -- End CBGA changes for new jobs model in 11i

 -- Begin EPP changes
  PaDateTab               pa_utils.DateTabTyp ;
  PaPeriodNameTab         pa_utils.Char15TabTyp;
  RecvrPaDateTab          pa_utils.DateTabTyp ;
  RecvrPaPeriodNameTab    pa_utils.Char15TabTyp;
  GlPeriodNameTab         pa_utils.Char15TabTyp;
  RecvrGlDateTab          pa_utils.DateTabTyp ;
  RecvrGlPeriodNameTab    pa_utils.Char15TabTyp;
 -- End EPP changes

   -- start of project currency and EI attributes
    AssgnIDTab                  pa_utils.IdTabTyp;
    WorkTypeTab                 pa_utils.IdTabTyp;
    ProjFuncCurrencyTab         pa_utils.Char15TabTyp;
    ProjFuncCostRateDateTab     pa_utils.DateTabTyp ;
    ProjFunccostRateTypeTab     pa_utils.Char30TabTyp;
    ProjfuncCostExgRateTab      pa_utils.NewAmtTabTyp;
    ProjRawCostTab              pa_utils.NewAmtTabTyp;
    ProjBurdendCostTab          pa_utils.NewAmtTabTyp;
    TpAmtTypeCode               pa_utils.Char30TabTyp;
  -- End of project currency and  EI attributes

  -- Begin PA-J Period End Accrual Changes
   AccrualDateTab                 pa_utils.DateTabTyp ;
   RecvrAccrualDateTab            pa_utils.DateTabTyp ;
  -- End PA-J Period End Accrual Changes

    -- AP Discounts
    Cdlsr4Tab                   pa_utils.Char30TabTyp ;

    --begin PA.M contingent worker and PJM attribute chnages
    Wip_Resource_IdTab	pa_utils.IdTabTyp;
    Inventory_Item_IdTab	pa_utils.IdTabTyp;
    Unit_Of_MeasureTab	pa_utils.Char30TabTyp;
    Po_Line_IdTab		pa_utils.IdTabTyp;
    Po_Price_TypeTab	pa_utils.Char30TabTyp;
    Adjustment_TypeTab pa_utils.Char150TabTyp;
    --end PA.M contingent worker and PJM attribute chnages

    SrcEtypeClassTab    pa_utils.Char30TabTyp; -- 4057874

    -- REL12 AP lines changes
    DocumentHeaderIdTab		pa_utils.IdTabTyp;
    DocumentDistributionIdTab   pa_utils.IdTabTyp ;
    DocumentLineNumberTab       pa_utils.IdTabTyp ;
    DocumentPaymentIdTab	pa_utils.IdTabTyp ;
    VendorIdTab			pa_utils.IdTabTyp ;
    DocumentTypeTab		pa_utils.Char30TabTyp ;
    DocumentDistributionTypeTab pa_utils.Char30TabTyp ;
    SiAssetsAddFlagTab          pa_utils.char1TabTyp;
    scxfercodetab               pa_utils.Char1TabTyp ;
    Cdlsr5Tab                   pa_utils.IdTabTyp ;
    Agreement_idTab             pa_utils.IdTabTyp;  --FSIO Changes
-- ========================================================================
-- PROCEDURE LoadEi
-- ========================================================================

  PROCEDURE  LoadEi( X_expenditure_item_id          IN NUMBER
                   , X_expenditure_id               IN NUMBER
                   , X_expenditure_item_date        IN DATE
                   , X_project_id                   IN NUMBER
                   , X_task_id                      IN NUMBER
                   , X_expenditure_type             IN VARCHAR2
                   , X_non_labor_resource           IN VARCHAR2
                   , X_nl_resource_org_id           IN NUMBER
                   , X_quantity                     IN NUMBER
                   , X_raw_cost                     IN NUMBER
                   , X_raw_cost_rate                IN NUMBER
                   , X_override_to_org_id           IN NUMBER
                   , X_billable_flag                IN VARCHAR2
                   , X_bill_hold_flag               IN VARCHAR2
                   , X_orig_transaction_ref         IN VARCHAR2
                   , X_transferred_from_ei          IN NUMBER
                   , X_adj_expend_item_id           IN NUMBER
                   , X_attribute_category           IN VARCHAR2
                   , X_attribute1                   IN VARCHAR2
                   , X_attribute2                   IN VARCHAR2
                   , X_attribute3                   IN VARCHAR2
                   , X_attribute4                   IN VARCHAR2
                   , X_attribute5                   IN VARCHAR2
                   , X_attribute6                   IN VARCHAR2
                   , X_attribute7                   IN VARCHAR2
                   , X_attribute8                   IN VARCHAR2
                   , X_attribute9                   IN VARCHAR2
                   , X_attribute10                  IN VARCHAR2
                   , X_ei_comment                   IN VARCHAR2
                   , X_transaction_source           IN VARCHAR2
                   , X_source_exp_item_id           IN NUMBER
                   , i                              IN BINARY_INTEGER
                   , X_job_id                       IN NUMBER   default null
                   , X_org_id                       IN NUMBER   default null
                   , X_labor_cost_multiplier_name   IN VARCHAR2
                   , X_drccid                       IN NUMBER
                   , X_crccid                       IN NUMBER
                   , X_cdlsr1                       IN VARCHAR2
                   , X_cdlsr2                       IN VARCHAR2
                   , X_cdlsr3                       IN VARCHAR2
                   , X_gldate                       IN DATE
                   , X_bcost                        IN NUMBER
                   , X_bcostrate                    IN NUMBER
                   , X_etypeclass                   IN VARCHAR2
                   , X_burden_sum_dest_run_id       IN NUMBER   default null
		           , X_burden_compile_set_id        IN NUMBER   default null
                   , X_receipt_currency_amount      IN NUMBER   default null
                   , X_receipt_currency_code        IN VARCHAR2 default NULL
                   , X_receipt_exchange_rate        IN NUMBER   default NULL
                   , X_denom_currency_code          IN VARCHAR2 default NULL
                   , X_denom_raw_cost               IN NUMBER   default NULL
                   , X_denom_burdened_cost          IN NUMBER   default NULL
  		           , X_acct_currency_code           IN VARCHAR2 default NULL
                   , X_acct_rate_date               IN DATE     default NULL
                   , X_acct_rate_type               IN VARCHAR2 default NULL
                   , X_acct_exchange_rate           IN NUMBER   default NULL
                   , X_acct_raw_cost                IN NUMBER   default NULL
                   , X_acct_burdened_cost           IN NUMBER   default NULL
                   , X_acct_exchange_rounding_limit IN NUMBER   default NULL
                   , X_project_currency_code        IN VARCHAR2 default NULL
                   , X_project_rate_date            IN DATE     default NULL
                   , X_project_rate_type            IN VARCHAR2 default NULL
                   , X_project_exchange_rate        IN NUMBER   default NULL
                   , X_Cross_Charge_Type            IN Varchar2 default 'NO'
                   , X_Cross_Charge_Code            IN Varchar2 default 'P'
                   , X_Prvdr_organization_id        IN Number default NULL
                   , X_Recv_organization_id         IN Number default NULL
                   , X_Recv_Operating_Unit          IN Number default NULL
                   , X_Borrow_Lent_Dist_Code        IN Varchar2 default 'X'
                   , X_Ic_Processed_Code            IN Varchar2 default 'X'
                   , X_Denom_Tp_Currency_Code       IN Varchar2 default NULL
                   , X_Denom_Transfer_Price         IN Number default NULL
                   , X_Acct_Tp_Rate_Type            IN Varchar2 default NULL
                   , X_Acct_Tp_Rate_Date            IN DATE default NULL
                   , X_Acct_Tp_Exchange_Rate        IN Number default NULL
                   , X_ACCT_TRANSFER_PRICE          IN Number default NULL
                   , X_PROJACCT_TRANSFER_PRICE      IN Number default NULL
                   , X_CC_MARKUP_BASE_CODE          IN Varchar2 default NULL
                   , X_TP_BASE_AMOUNT               IN Number default NULL
                   , X_Tp_Ind_Compiled_Set_Id       IN Number default NULL
                   , X_Tp_Bill_Rate                 IN Number default NULL
                   , X_Tp_Bill_Markup_Percentage    IN Number default NULL
                   , X_Tp_Schedule_Line_Percentage  IN Number default NULL
                   , X_Tp_Rule_Percentage           IN Number default NULL
		           , X_Cost_Job_Id 	            IN NUMBER default null
		           , X_Prov_Proj_Bill_Job_Id        IN NUMBER default null
		           , X_TP_Job_Id 	            IN NUMBER default null
                   , P_PaDate                       IN DATE     default null
                   , P_PaPeriodName                 IN Varchar2 default null
                   , P_RecvrPaDate                  IN DATE     default null
                   , P_RecvrPaPeriodName            IN Varchar2 default null
                   , P_GlPeriodName                 IN Varchar2 default null
                   , P_RecvrGlDate                  IN DATE     default null
                   , P_RecvrGlPeriodName            IN Varchar2 default null
                   , p_assignment_id                IN NUMBER  default null
                   , p_work_type_id                 IN NUMBER  default null
                   , p_projfunc_currency_code       IN varchar2 default null
                   , p_projfunc_cost_rate_date      IN date  default  null
                   , p_projfunc_cost_rate_type      IN varchar2 default null
                   , p_projfunc_cost_exchange_rate  IN number default null
                   , p_project_raw_cost             IN number default null
                   , p_project_burdened_cost        IN number default null
                   , p_tp_amt_type_code             IN varchar2 default null
                   , p_cdlsr4                       IN varchar2 default null
                   , p_accrual_Date                 IN DATE default null
                   , p_recvr_accrual_date           IN DATE default null
                   , p_Wip_Resource_Id	IN number default null  /* cwk */
                   , p_Inventory_Item_Id	     IN number default null
                   , p_Unit_Of_Measure	     IN varchar2 default null
                   , p_Po_Line_Id			IN number default null
                   , p_Po_Price_Type		IN varchar2 default null
                   , p_adjustment_type      IN varchar2 default null
                   , p_src_system_linkage_function    IN varchar2 default null /* 4057874 */
		     /* REL12-AP Lines uptake */
		   , p_document_header_id           IN number   default NULL
		   , p_document_distribution_id     IN number   default NULL
		   , p_document_line_number         IN number   default NULL
		   , p_document_payment_id          IN number   default NULL
		   , p_vendor_id                    IN number   default NULL
		   , p_document_type                IN varchar2 default NULL
		   , p_document_distribution_type   IN varchar2 default NULL
		   , p_si_assets_addition_flag      IN varchar2 default NULL
		   , p_sc_xfer_code                 IN varchar2 default NULL
                   , p_cdlsr5                       IN number   default null
--                   , p_agreement_id                 IN NUMBER   DEFAULT NULL   --FSIO Changes
                   );


-- ========================================================================
-- PROCEDURE FlushEiTabs
-- ========================================================================

  PROCEDURE  FlushEiTabs;


-- ========================================================================
-- PROCEDURE InsItemComment
-- ========================================================================

  PROCEDURE  InsItemComment( X_ei_id       IN NUMBER
                           , X_ei_comment  IN VARCHAR2
                           , X_user        IN NUMBER
                           , X_login       IN NUMBER
                           , X_status      OUT NOCOPY NUMBER );


-- ========================================================================
-- PROCEDURE InsItems
-- ========================================================================

  PROCEDURE  InsItems( X_user              IN NUMBER
                     , X_login             IN NUMBER
                     , X_module            IN VARCHAR2
                     , X_calling_process   IN VARCHAR2
                     , Rows                IN BINARY_INTEGER
                     , X_status            OUT NOCOPY NUMBER
                     , X_gl_flag           IN VARCHAR2 );


-- ========================================================================
-- PROCEDURE InsertExp
-- ========================================================================
-- Added new multi-Currency parameters to PA_EXPENDITURES
--

  PROCEDURE  InsertExp( X_expenditure_id              IN NUMBER
                      , X_expend_status               IN VARCHAR2
                      , X_expend_ending               IN DATE
                      , X_expend_class                IN VARCHAR2
                      , X_inc_by_person               IN NUMBER
                      , X_inc_by_org                  IN NUMBER
                      , X_expend_group                IN VARCHAR2
                      , X_entered_by_id               IN NUMBER
                      , X_created_by_id               IN NUMBER
                      , X_attribute_category          IN VARCHAR2 DEFAULT NULL
                      , X_attribute1                  IN VARCHAR2 DEFAULT NULL
                      , X_attribute2                  IN VARCHAR2 DEFAULT NULL
                      , X_attribute3                  IN VARCHAR2 DEFAULT NULL
                      , X_attribute4                  IN VARCHAR2 DEFAULT NULL
                      , X_attribute5                  IN VARCHAR2 DEFAULT NULL
                      , X_attribute6                  IN VARCHAR2 DEFAULT NULL
                      , X_attribute7                  IN VARCHAR2 DEFAULT NULL
                      , X_attribute8                  IN VARCHAR2 DEFAULT NULL
                      , X_attribute9                  IN VARCHAR2 DEFAULT NULL
                      , X_attribute10                 IN VARCHAR2 DEFAULT NULL
                      , X_description                 IN VARCHAR2 DEFAULT NULL
                      , X_control_total               IN NUMBER   DEFAULT NULL
                      , X_denom_currency_code         IN VARCHAR2   DEFAULT NULL
                      , X_acct_currency_code          IN VARCHAR2   DEFAULT NULL
                      , X_acct_rate_type              IN VARCHAR2   DEFAULT NULL
                      , X_acct_rate_date              IN DATE   DEFAULT NULL
                      , X_acct_exchange_rate          IN NUMBER   DEFAULT NULL
                      -- Trx_import enhancement:
                      -- New parameters used to populate PA_EXPENDITURES_ALL
                      -- table's new columns
                      , X_orig_exp_txn_reference1     IN VARCHAR2 DEFAULT NULL
                      , X_orig_user_exp_txn_reference IN VARCHAR2 DEFAULT NULL
                      , X_vendor_id                   IN NUMBER DEFAULT NULL
                      , X_orig_exp_txn_reference2     IN VARCHAR2 DEFAULT NULL
                      , X_orig_exp_txn_reference3     IN VARCHAR2 DEFAULT NULL
                      , X_person_type                 IN VARCHAR2 DEFAULT NULL     /* cwk */
                      , P_Org_Id                      IN NUMBER Default NULL -- 12i MOAC changes
                      );

-- ========================================================================
-- PROCEDURE InsertExpGroup
-- ========================================================================

  PROCEDURE  InsertExpGroup(
                  X_expenditure_group      IN VARCHAR2
               ,  X_exp_group_status_code  IN VARCHAR2
               ,  X_ending_date            IN DATE
               ,  X_system_linkage         IN VARCHAR2
               ,  X_created_by             IN NUMBER
               ,  X_transaction_source     IN VARCHAR2
               ,  P_Accrual_Flag           IN VARCHAR2  default null
               ,  P_Org_Id                 IN NUMBER    default Null); -- 12i MOAC changes


-- ========================================================================
-- PROCEDURE CreateRelatedItem
-- ========================================================================
-- Changed the parameter name from raw_cost to denom_raw_cost and
-- raw_cost_rate to denom_cost_rate
--
/*#
 * Use this procedure to create related transactions within the logic of the Add Transactions procedure.
 * @param X_source_exp_item_id The identifier of the source transaction
 * @rep:paraminfo {@rep:required}
 * @param X_project_id The identifier of the project to charge the related transaction to
 * @param X_task_id The identifier of the task
 * @param X_expenditure_type The expenditure type of the related transaction
 * @rep:paraminfo {@rep:required}
 * @param X_denom_raw_cost The raw cost amount of the related transaction in transaction currency
 * @rep:paraminfo {@rep:required}
 * @param X_denom_raw_cost_rate The raw cost rate of the related transaction
 * @rep:paraminfo {@rep:required}
 * @param X_override_to_org_id The identifier of the organization that overrides the expenditure organization used by the source transaction
 * @rep:paraminfo {@rep:required}
 * @param X_userid The identifier of the user that entered the source transaction
 * @rep:paraminfo {@rep:required}
 * @param X_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param X_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param X_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param X_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param X_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param X_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param X_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param X_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param X_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param X_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param X_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param X_comment Expenditure item comment
 * @rep:paraminfo {@rep:required}
 * @param X_status Status indicating whether an error occurred. The valid values are =0 (Success), <0 OR >0 (Application Error)
 * @rep:paraminfo {@rep:required}
 * @param X_outcome  Outcome of the procedure
 * @rep:paraminfo {@rep:required}
 * @param X_work_type_name Name of the work type assigned to the transaction
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Related Transactions
 * @rep:compatibility S
*/
  PROCEDURE  CreateRelatedItem(
		          X_source_exp_item_id   IN NUMBER
               ,  X_project_id           IN NUMBER DEFAULT NULL
               ,  X_task_id              IN NUMBER DEFAULT NULL
               ,  X_Award_id             IN NUMBER DEFAULT NULL
               ,  X_expenditure_type     IN VARCHAR2
               ,  X_denom_raw_cost       IN NUMBER
               ,  X_denom_raw_cost_rate  IN NUMBER
               ,  X_override_to_org_id   IN NUMBER
               ,  X_userid               IN NUMBER
               ,  X_attribute_category   IN VARCHAR2
               ,  X_attribute1           IN VARCHAR2
               ,  X_attribute2           IN VARCHAR2
               ,  X_attribute3           IN VARCHAR2
               ,  X_attribute4           IN VARCHAR2
               ,  X_attribute5           IN VARCHAR2
               ,  X_attribute6           IN VARCHAR2
               ,  X_attribute7           IN VARCHAR2
               ,  X_attribute8           IN VARCHAR2
               ,  X_attribute9           IN VARCHAR2
               ,  X_attribute10          IN VARCHAR2
               ,  X_comment              IN VARCHAR2
               ,  X_status               OUT NOCOPY NUMBER
               ,  X_outcome              OUT NOCOPY VARCHAR2
                , X_work_type_name       IN VARCHAR2 DEFAULT NULL/*bug2482593*/
                );


-- ========================================================================
-- PROCEDURE UpdateRelatedItem
-- ========================================================================
-- Changed the parameter name from raw_cost to denom_raw_cost and
-- raw_cost_rate to denom_cost_rate
--
--
/*#
 * Use this procedure to update the raw cost amount of existing related transactions within the logic of your labor
 * transaction extension when related transactions are marked for cost recalculation.
 * @param X_expenditure_item_id The identifier of the related expenditure item
 * @rep:paraminfo {@rep:required}
 * @param X_denom_raw_cost The new raw cost of the related transaction in the transaction currency
 * @rep:paraminfo {@rep:required}
 * @param X_denom_raw_cost_rate The new raw cost rate of the related transaction in the transaction currency
 * @rep:paraminfo {@rep:required}
 * @param X_status Status indicating whether an error occurred. The valid values are =0 (Success), <0 OR >0 (Application Error)
 * @rep:paraminfo {@rep:required}
 * @param X_work_type_name Name of the work type assigned to the transaction
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Related Transactions
 * @rep:compatibility S
*/
  PROCEDURE  UpdateRelatedItem( X_expenditure_item_id  IN NUMBER
                              , X_denom_raw_cost       IN NUMBER
                              , X_denom_raw_cost_rate  IN NUMBER
                              , X_status               OUT NOCOPY NUMBER
                              , X_work_type_name       IN VARCHAR2 DEFAULT NULL/*bug2482593*/
                                );


-- Added as a fix for  the bug # 1358018
-- ========================================================================
-- PROCEDURE UpdateSystemLinkFunc
-- ========================================================================

  PROCEDURE  UpdateSystemLinkFunc( X_expend_item_id  IN NUMBER
                              , X_sys_link_func      IN VARCHAR2);

-- ========================================================================
-- PA-K Changes: Added this procedure
-- PROCEDURE InsertExpGroupNew
-- ========================================================================

  PROCEDURE  InsertExpGroupNew(
                  X_expenditure_group      IN VARCHAR2
               ,  X_exp_group_status_code  IN VARCHAR2
               ,  X_ending_date            IN DATE
               ,  X_system_linkage         IN VARCHAR2
               ,  X_created_by             IN NUMBER
               ,  X_transaction_source     IN VARCHAR2
               ,  P_Accrual_Flag           IN VARCHAR2  default null
               ,  P_Org_Id                 IN NUMBER default null); -- 12i MOAC changes

END PA_TRANSACTIONS;

/
