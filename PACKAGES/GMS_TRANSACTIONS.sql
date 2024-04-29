--------------------------------------------------------
--  DDL for Package GMS_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_TRANSACTIONS" AUTHID CURRENT_USER AS
/* $Header: GMSTRANS.pls 120.1 2005/07/26 14:38:47 appldev ship $ */

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
  BatchNameTab    pa_utils.Char30TabTyp;


/*----------------------------------------------------------------------------
   The following PL/SQL tables are used by several programs including
   Transaction Import and the Transfer prodedure of the PA Adjustments
   package.  These PL/SQL tables are loaded with VALIDATED expenditure items
   and then inserted into PA_EXPENDITURE_ITEMS using the
   gms_transactions.InsItems procedure.  This method allows the programs to
   store validated items one at a time until all items are validated.  The
   items can then either be inserted into PA_EXPENDITURE_ITEMS with one call
   to gms_transactions.InsItems or can be rolled back using the
   gms_transactions.FlushEiTabs procedure without having to execute any DDL
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
                   , X_Tp_Rule_Percentage           IN Number default NULL );



-- ========================================================================
-- PROCEDURE FlushEiTabs
-- ========================================================================

  PROCEDURE  FlushEiTabs;


-- ========================================================================
-- PROCEDURE InsItemComment
-- ========================================================================
/*
  PROCEDURE  InsItemComment( X_ei_id       IN NUMBER
                           , X_ei_comment  IN VARCHAR2
                           , X_user        IN NUMBER
                           , X_login       IN NUMBER
                           , X_status      OUT NOCOPY NUMBER );

*/
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
-- Added new multi-Currency parameters to GMS_ENCUMBRANCES
--

  PROCEDURE  InsertExp( X_expenditure_id     IN NUMBER
                      , X_expend_status      IN VARCHAR2
                      , X_expend_ending      IN DATE
                      , X_expend_class       IN VARCHAR2
                      , X_inc_by_person      IN NUMBER
                      , X_inc_by_org         IN NUMBER
                      , X_expend_group       IN VARCHAR2
                      , X_entered_by_id      IN NUMBER
                      , X_created_by_id      IN NUMBER
                      , X_attribute_category IN VARCHAR2 DEFAULT NULL
                      , X_attribute1         IN VARCHAR2 DEFAULT NULL
                      , X_attribute2         IN VARCHAR2 DEFAULT NULL
                      , X_attribute3         IN VARCHAR2 DEFAULT NULL
                      , X_attribute4         IN VARCHAR2 DEFAULT NULL
                      , X_attribute5         IN VARCHAR2 DEFAULT NULL
                      , X_attribute6         IN VARCHAR2 DEFAULT NULL
                      , X_attribute7         IN VARCHAR2 DEFAULT NULL
                      , X_attribute8         IN VARCHAR2 DEFAULT NULL
                      , X_attribute9         IN VARCHAR2 DEFAULT NULL
                      , X_attribute10        IN VARCHAR2 DEFAULT NULL
                      , X_description        IN VARCHAR2 DEFAULT NULL
                      , X_control_total      IN NUMBER   DEFAULT NULL
                      , X_denom_currency_code IN VARCHAR2   DEFAULT NULL
                      , X_acct_currency_code IN VARCHAR2   DEFAULT NULL
                      , X_acct_rate_type     IN VARCHAR2   DEFAULT NULL
                      , X_acct_rate_date     IN DATE   DEFAULT NULL
                      , X_acct_exchange_rate IN NUMBER   DEFAULT NULL
                      -- Trx_import enhancement:
                      -- New parameters used to populate GMS_ENCUMBRANCES_ALL
                      -- table's new columns
                      , X_orig_exp_txn_reference1 IN VARCHAR2 DEFAULT NULL
                      , X_orig_user_exp_txn_reference IN VARCHAR2 DEFAULT NULL
                      , X_vendor_id IN NUMBER DEFAULT NULL
                      , X_orig_exp_txn_reference2 IN VARCHAR2 DEFAULT NULL
                      , X_orig_exp_txn_reference3 IN VARCHAR2 DEFAULT NULL
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
               ,  X_transaction_source     IN VARCHAR2 );


-- ========================================================================
-- PROCEDURE CreateRelatedItem
-- ========================================================================
-- Changed the parameter name from raw_cost to denom_raw_cost and
-- raw_cost_rate to denom_cost_rate
--
  PROCEDURE  CreateRelatedItem( X_source_exp_item_id   IN NUMBER
                              , X_project_id           IN NUMBER DEFAULT NULL
                              , X_task_id              IN NUMBER DEFAULT NULL
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
               ,  X_outcome              OUT NOCOPY VARCHAR2 );


-- ========================================================================
-- PROCEDURE UpdateRelatedItem
-- ========================================================================
-- Changed the parameter name from raw_cost to denom_raw_cost and
-- raw_cost_rate to denom_cost_rate
--
  PROCEDURE  UpdateRelatedItem( X_expenditure_item_id  IN NUMBER
                              , X_denom_raw_cost       IN NUMBER
                              , X_denom_raw_cost_rate  IN NUMBER
                              , X_status               OUT NOCOPY NUMBER );

END GMS_TRANSACTIONS;

 

/
