--------------------------------------------------------
--  DDL for Package Body PA_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TRANSACTIONS" AS
/* $Header: PAXTRANB.pls 120.12.12010000.4 2009/06/18 08:27:36 abjacob ship $ */

  P_DEBUG_MODE BOOLEAN     := pa_cc_utils.g_debug_mode;


-- ========================================================================
-- PROCEDURE LoadEi
-- ========================================================================


PROCEDURE  LoadEi( X_expenditure_item_id            IN NUMBER
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
                   , X_job_id                       IN NUMBER
                   , X_org_id                       IN NUMBER
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
                   , X_burden_sum_dest_run_id       IN NUMBER
	           , X_burden_compile_set_id        IN NUMBER
	           , X_receipt_currency_amount      IN NUMBER
	           , X_receipt_currency_code        IN VARCHAR2
	           , X_receipt_exchange_rate        IN NUMBER
	           , X_denom_currency_code          IN VARCHAR2
	           , X_denom_raw_cost	            IN NUMBER
	           , X_denom_burdened_cost          IN NUMBER
 	           , X_acct_currency_code           IN VARCHAR2
	           , X_acct_rate_date  	            IN DATE
	           , X_acct_rate_type               IN VARCHAR2
	           , X_acct_exchange_rate           IN NUMBER
	           , X_acct_raw_cost                IN NUMBER
	           , X_acct_burdened_cost           IN NUMBER
	           , X_acct_exchange_rounding_limit IN NUMBER
	           , X_project_currency_code        IN VARCHAR2
	           , X_project_rate_date            IN DATE
	           , X_project_rate_type            IN VARCHAR2
	           , X_project_exchange_rate        IN NUMBER
                   , X_Cross_Charge_Type            IN Varchar2
                   , X_Cross_Charge_Code            IN VArchar2
                   , X_Prvdr_organization_id        IN Number
                   , X_Recv_organization_id         IN Number
                   , X_Recv_Operating_Unit          IN Number
                   , X_Borrow_Lent_Dist_Code        IN VARCHAR2
                   , X_Ic_Processed_Code            IN VARCHAR2
                   , X_Denom_Tp_Currency_Code       IN Varchar2
                   , X_Denom_Transfer_Price         IN Number
                   , X_Acct_Tp_Rate_Type            IN Varchar2
                   , X_Acct_Tp_Rate_Date            IN DATE
                   , X_Acct_Tp_Exchange_Rate        IN Number
                   , X_ACCT_TRANSFER_PRICE          IN Number
                   , X_PROJACCT_TRANSFER_PRICE      IN Number
                   , X_CC_MARKUP_BASE_CODE          IN Varchar2
                   , X_TP_BASE_AMOUNT               IN Number
                   , X_Tp_Ind_Compiled_Set_Id       IN Number
                   , X_Tp_Bill_Rate                 IN Number
                   , X_Tp_Bill_Markup_Percentage    IN Number
                   , X_Tp_Schedule_Line_Percentage  IN Number
                   , X_Tp_Rule_Percentage           IN Number
	           , X_Cost_Job_Id 	                IN NUMBER
	           , X_Prov_Proj_Bill_Job_Id        IN NUMBER
	           , X_TP_Job_Id 	                IN NUMBER
                   , P_PaDate                       IN DATE
                   , P_PaPeriodName                 IN Varchar2
                   , P_RecvrPaDate                  IN DATE
                   , P_RecvrPaPeriodName            IN Varchar2
                   , P_GlPeriodName                 IN Varchar2
                   , P_RecvrGlDate                  IN DATE
                   , P_RecvrGlPeriodName            IN Varchar2
	           , p_assignment_id                IN NUMBER
                   , p_work_type_id                 IN NUMBER
                   , p_projfunc_currency_code       IN varchar2
                   , p_projfunc_cost_rate_date      IN date
                   , p_projfunc_cost_rate_type      IN varchar2
                   , p_projfunc_cost_exchange_rate  IN number
                   , p_project_raw_cost             IN number
                   , p_project_burdened_cost        IN number
                   , p_tp_amt_type_code             IN varchar2
                   , p_cdlsr4                       IN varchar2
                   , p_accrual_Date                 IN DATE
                   , p_recvr_accrual_date           IN DATE
	           , p_Wip_Resource_Id	            IN number
	           , p_Inventory_Item_Id	        IN number
	           , p_Unit_Of_Measure	            IN varchar2
	           , p_Po_Line_Id			        IN number
	           , p_Po_Price_Type		        IN varchar2
                   , p_adjustment_type              IN varchar2
                   , p_src_system_linkage_function  IN varchar2 /* 4057874 */
	           /* REL12-AP Lines uptake */
	           , p_document_header_id           IN number   default NULL
	           , p_document_distribution_id     IN number   default NULL
	           , p_document_line_number         IN number   default NULL
	           , p_document_payment_id          IN number   default NULL
	           , p_vendor_id                    IN number   default NULL
	           , p_document_type                in varchar2 default NULL
	           , p_document_distribution_type   in varchar2 default NULL
		   , p_si_assets_addition_flag      in varchar2 default NULL
		   , p_sc_xfer_code                 IN varchar2 default NULL
                   , p_cdlsr5                       IN number   default NULL
                  -- , p_agreement_id                 IN NUMBER   DEFAULT NULL   --FSIO Changes
                   ) IS
  BEGIN
-- dbms_output.put_line('In Loadei:'||to_char(i));
    pa_cc_utils.set_curr_function('LoadEi');
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('LoadEi: ' || 'Start ');
    END IF;

    EiIdTab(i)        := X_expenditure_item_id;
    EIdTab(i)         := X_expenditure_id;
    ProjIdTab(i)      := X_project_id;
    TskIdTab(i)       := X_task_id;
    EiDateTab(i)      := X_expenditure_item_date;
    ETypTab(i)        := X_expenditure_type;
    NlRscTab(i)       := X_non_labor_resource;
    NlRscOrgTab(i)    := X_nl_resource_org_id;
    BillFlagTab(i)    := X_billable_flag;
    BillHoldTab(i)    := X_bill_hold_flag;
    QtyTab(i)         := X_quantity;
    RawCostTab(i)     := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT1(X_raw_cost, X_project_currency_code);
    RawRateTab(i)     := X_raw_cost_rate;
    OvrOrgTab(i)      := X_override_to_org_id;
    AdjEiTab(i)       := X_adj_expend_item_id;
    TfrEiTab(i)       := X_transferred_from_ei;
    TrxRefTab(i)      := X_orig_transaction_ref;
    EiTrxSrcTab(i)    := X_transaction_source;
    AttCatTab(i)      := X_attribute_category;
    Att1Tab(i)        := X_attribute1;
    Att2Tab(i)        := X_attribute2;
    Att3Tab(i)        := X_attribute3;
    Att4Tab(i)        := X_attribute4;
    Att5Tab(i)        := X_attribute5;
    Att6Tab(i)        := X_attribute6;
    Att7Tab(i)        := X_attribute7;
    Att8Tab(i)        := X_attribute8;
    Att9Tab(i)        := X_attribute9;
    Att10Tab(i)       := X_attribute10;
    SrcEiTab(i)       := X_source_exp_item_id;
    EiCommentTab(i)   := X_ei_comment;
    JobIdTab(i)       := X_job_id;
    OrgIdTab(i)       := X_org_id;
    LCMTab(i)         := X_labor_cost_multiplier_name ;
    DrccidIdTab(i)    := X_drccid ;
    CrccidIdTab(i)    := X_crccid ;
    Cdlsr1Tab(i)      := X_cdlsr1 ;
    Cdlsr2Tab(i)      := X_cdlsr2 ;
    Cdlsr3Tab(i)      := X_cdlsr3 ;
    GldateTab(i)      := X_gldate ;
    BCostTab(i)       := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT1(X_bcost,X_project_currency_code)  ;
    BCostRateTab(i)   := X_bcostrate ;
    EtypeClassTab(i)  := X_etypeclass ;
    BurdenDestid(i)   := X_burden_sum_dest_run_id ;
    BurdenCompSetId(i) := X_burden_compile_set_id;
    ReceiptCurrAmt(i) := X_receipt_currency_amount;
    ReceiptCurrCode(i) := X_receipt_currency_code;
    ReceiptExRate(i)  := X_receipt_exchange_rate;
    DenomCurrCode(i)  := X_denom_currency_code;
    DenomRawCost(i)   := X_denom_raw_cost;
    DenomBurdenCost(i) := X_denom_burdened_cost;
    AcctCurrCode(i)   := X_acct_currency_code;
    AcctRateDate(i)   := X_acct_rate_date;
    AcctRateType(i)   := X_acct_rate_type;
    AcctExRate(i)     := X_acct_exchange_rate;
    AcctRawCost(i)    := X_acct_raw_cost;
    AcctBurdenCost(i) := X_acct_burdened_cost;
    AcctRoundLmt(i)   := X_acct_exchange_rounding_limit;
    ProjCurrCode(i)   := X_project_currency_code;
    ProjRateDate(i)   := X_project_rate_date;
    ProjRateType(i)   := X_project_rate_type;
    ProjExRate(i)     := X_project_exchange_rate;


    -- IC Changes
    CrossChargeTypeTab(i)   := X_Cross_Charge_Type;
    CrossChargeCodeTab(i)   := X_Cross_Charge_Code;
    PrvdrOrganizationTab(i) := X_Prvdr_organization_id;
    RecvOrganizationTab(i)  := X_Recv_organization_id;
    RecvOperUnitTab(i)      := NVL(X_Recv_Operating_Unit,
                                 PA_UTILS2.GetPrjOrgId(X_project_id,X_task_id));
    IcProcessedCodeTab(i)   := X_Ic_Processed_Code;
    BorrowLentCodeTab(i)    := X_Borrow_Lent_Dist_Code;
    DenomTpCurrCodeTab(i)      := X_Denom_Tp_Currency_Code;
    DenomTransferPriceTab(i)   := X_Denom_Transfer_Price;
    AcctTpRateTypeTab(i)          := X_Acct_Tp_Rate_Type;
    AcctTpRateDateTab(i)       := X_Acct_Tp_Rate_Date;
    AcctTpExchangeRateTab(i)   := X_Acct_Tp_Exchange_Rate;
    AcctTransferPriceTab(i)    := X_ACCT_TRANSFER_PRICE;
    ProjacctTransferPriceTab(i) := X_PROJACCT_TRANSFER_PRICE;
    CcMarkupBaseCodeTab(i)     := X_CC_MARKUP_BASE_CODE;
    TpBaseAmountTab(i)         := X_TP_BASE_AMOUNT;
    TpIndCompiledSetIdTab(i)   := X_Tp_Ind_Compiled_Set_Id;
    TpBillRateTab(i)           := X_Tp_Bill_Rate;
    TpBillMarkupPercentageTab(i) := X_Tp_Bill_Markup_Percentage;
    TpSchLinePercentageTab(i)  := X_Tp_Schedule_Line_Percentage;
    TpRulePercentageTab(i)     := X_Tp_Rule_Percentage;
   -- END IC Changes

  -- New Jobs Model
    CostJobIdTab(i)            := X_Cost_Job_Id;
    ProvProjBillJobIdTab(i)    := X_Prov_Proj_Bill_Job_Id;
    TPJobIdTab(i)              := X_TP_Job_Id;
  -- End New Jobs Model

   -- Begin EPP changes
    PaDateTab(i)               := P_PaDate;
    PaPeriodNameTab(i)         := P_PaPeriodName;
    RecvrPaDateTab(i)          := P_RecvrPaDate;
    RecvrPaPeriodNameTab(i)    := P_RecvrPaPeriodName;
    GlPeriodNameTab(i)         := P_GlPeriodName;
    RecvrGlDateTab(i)          := P_RecvrGlDate;
    RecvrGlPeriodNameTab(i)    := P_RecvrGlPeriodName;
   -- End EPP changes

   -- start of project currency and  EI attributes
    AssgnIDTab(i)                 := p_assignment_id ;
    WorkTypeTab(i)                := p_work_type_id   ;
    ProjFuncCurrencyTab(i)        := p_projfunc_currency_code;
    ProjFuncCostRateDateTab(i)    := p_projfunc_cost_rate_date;
    ProjFunccostRateTypeTab(i)    := p_projfunc_cost_rate_type ;
    ProjfuncCostExgRateTab(i)     := p_projfunc_cost_exchange_rate;
    ProjRawCostTab(i)             := p_project_raw_cost;
    ProjBurdendCostTab(i)         := p_project_burdened_cost;
    TpAmtTypeCode(i)              := nvl(p_tp_amt_type_code,pa_utils4.get_tp_amt_type_code(p_work_type_id));
  -- End of project currency and  EI attributes

    -- AP Discounts
    Cdlsr4Tab(i)                  := p_cdlsr4;

    /* REL12-AP Lines uptake */
    DocumentHeaderIDTab(i)        := p_document_header_id ;
    DocumentDistributionIdTab(i)  := p_document_distribution_id ;
    DocumentLineNumberTab(i)      := p_document_line_number ;
    DocumentPaymentIdTab(i)       := p_document_payment_id ;
    VendorIdTab(i)                := p_vendor_id ;
    DocumentTypeTab(i)            := p_document_type ;
    DocumentDistributionTypeTab(i):= p_document_distribution_type ;
    SiAssetsAddFlagTab(i)         := p_si_assets_addition_flag ;
    ScXferCodeTab(i)              := p_sc_xfer_code ;
    Cdlsr5Tab(i)                  := p_cdlsr5;

    -- Begin PA-J Period End Accrual Changes
    AccrualDateTab(i)             := p_accrual_date;
    RecvrAccrualDateTab(i)        := p_recvr_accrual_date;
    -- End PA-J Period End Accrual Changes

    --begin PA.M contingent worker and PJM attribute chnages
    Wip_Resource_IdTab(i) := p_Wip_Resource_Id;
    Inventory_Item_IdTab(i)  := p_Inventory_Item_Id;
    Unit_Of_MeasureTab(i)  := p_Unit_Of_Measure;
    Po_Line_IdTab(i)  := p_Po_Line_Id;
    Po_Price_TypeTab(i)  := p_Po_Price_Type;
    Adjustment_TypeTab(i) := p_adjustment_type;
    --end PA.M contingent worker and PJM attribute chnages

    SrcEtypeClassTab(i) := p_src_system_linkage_function;  /* 4057874 */

  --  Agreement_idTab(i) := p_agreement_id; --FSIO Changes
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('LoadEi: ' || 'End ');
    END IF;
    pa_cc_utils.reset_curr_function ;
  END  LoadEi;


-- ========================================================================
-- PROCEDURE FlushEiTabs
-- ========================================================================

  PROCEDURE  FlushEiTabs
  IS
  BEGIN
    pa_cc_utils.set_curr_function('FlushEiTabs');
    pa_cc_utils.log_message('Start ');

    EiIdTab        := pa_utils.EmptyIdTab;
    EIdTab         := pa_utils.EmptyIdTab;
    TskIdTab       := pa_utils.EmptyIdTab;
    EiDateTab      := pa_utils.EmptyDateTab;
    ETypTab        := pa_utils.EmptyChar30Tab;
    NlRscTab       := pa_utils.EmptyChar20Tab;
    NlRscOrgTab    := pa_utils.EmptyIdTab;
    BillFlagTab    := pa_utils.EmptyChar1Tab;
    BillHoldTab    := pa_utils.EmptyChar1Tab;
    QtyTab         := pa_utils.EmptyAmtTab;
    RawCostTab     := pa_utils.EmptyAmtTab;
    RawRateTab     := pa_utils.EmptyAmtTab;
    OvrOrgTab      := pa_utils.EmptyIdTab;
    AdjEiTab       := pa_utils.EmptyIdTab;
    TfrEiTab       := pa_utils.EmptyIdTab;
    TrxRefTab      := pa_utils.EmptyChar30Tab;
    EiTrxSrcTab    := pa_utils.EmptyChar30Tab;
    AttCatTab      := pa_utils.EmptyChar30Tab;
    Att1Tab        := pa_utils.EmptyChar150Tab;
    Att2Tab        := pa_utils.EmptyChar150Tab;
    Att3Tab        := pa_utils.EmptyChar150Tab;
    Att4Tab        := pa_utils.EmptyChar150Tab;
    Att5Tab        := pa_utils.EmptyChar150Tab;
    Att6Tab        := pa_utils.EmptyChar150Tab;
    Att7Tab        := pa_utils.EmptyChar150Tab;
    Att8Tab        := pa_utils.EmptyChar150Tab;
    Att9Tab        := pa_utils.EmptyChar150Tab;
    Att10Tab       := pa_utils.EmptyChar150Tab;
    SrcEiTab       := pa_utils.EmptyIdTab;
    EiCommentTab   := pa_utils.EmptyChar240Tab;
    JobIdTab       := pa_utils.EmptyIdTab;
    OrgIdTab       := pa_utils.EmptyIdTab;
    LCMTab         := pa_utils.EmptyChar20Tab ;
    DrccidIdTab    := pa_utils.EmptyIdTab ;
    CrccidIdTab    := pa_utils.EmptyIdTab ;
    Cdlsr1Tab      := pa_utils.EmptyChar30Tab ;
    Cdlsr2Tab      := pa_utils.EmptyChar30Tab ;
    Cdlsr3Tab      := pa_utils.EmptyChar30Tab ;
    GldateTab      := pa_utils.EmptyDateTab ;
    BCostTab       := pa_utils.EmptyAmtTab;
    BCostRateTab   := pa_utils.EmptyAmtTab;
    EtypeClassTab  := pa_utils.EmptyChar30Tab ;
    BurdenDestId   := pa_utils.EmptyIdTab ;
    BurdenCompSetId := pa_utils.EmptyIdTab ;
    ReceiptCurrAmt := pa_utils.EmptyNewAmtTab;
    ReceiptCurrCode := pa_utils.EmptyChar15Tab;
    ReceiptExRate  := pa_utils.EmptyNewAmtTab;
    DenomCurrCode  := pa_utils.EmptyChar15Tab;
    DenomRawCost   := pa_utils.EmptyNewAmtTab;
    DenomBurdenCost := pa_utils.EmptyNewAmtTab;
    AcctCurrCode   := pa_utils.EmptyChar15Tab;
    AcctRateDate   := pa_utils.EmptyDateTab;
    AcctRateType   := pa_utils.EmptyChar30Tab ;
    AcctExRate     := pa_utils.EmptyNewAmtTab;
    AcctRawCost    := pa_utils.EmptyNewAmtTab;
    AcctBurdenCost := pa_utils.EmptyNewAmtTab;
    AcctRoundLmt   := pa_utils.EmptyNewAmtTab;
    ProjCurrCode   := pa_utils.EmptyChar15Tab;
    ProjRateType   := pa_utils.EmptyChar30Tab ;
    ProjRateDate   := pa_utils.EmptyDateTab;
    ProjExRate     := pa_utils.EmptyNewAmtTab;

    -- IC Changes
    CrossChargeTypeTab   := pa_utils.EmptyChar10Tab ;
    CrossChargeCodeTab   := pa_utils.EmptyChar1Tab ;
    PrvdrOrganizationTab        := pa_utils.EmptyIdTab ;
    RecvOrganizationTab         := pa_utils.EmptyIdTAb ;
    RecvOperUnitTab      := pa_utils.EmptyIdTab ;
    IcProcessedCodeTab  := pa_utils.EmptyChar1Tab ;
    BorrowLentCodeTab   := pa_utils.EmptyChar1Tab ;
    DenomTpCurrCodeTab   := pa_utils.EmptyChar15Tab;
    DenomTransferPriceTab := pa_utils.EmptyNewAmtTab;
    AcctTpRateTypeTab     := pa_utils.EmptyChar30Tab;
    AcctTpRateDateTab     := pa_utils.EmptyDateTab;
    AcctTpExchangeRateTab := pa_utils.EmptyNewAmtTab;
    AcctTransferPriceTab   := pa_utils.EmptyNewAmtTab;
    ProjacctTransferPriceTab := pa_utils.EmptyNewAmtTab;
    CcMarkupBaseCodeTab   := pa_utils.EmptyChar1TAb;
    TpBaseAmountTab        := pa_utils.EmptyNewAmtTab;
    TpIndCompiledSetIdTab := pa_utils.EmptyIdTab;
    TpBillRateTab           := pa_utils.EmptyNewAmtTab;
    TpBillMarkupPercentageTab := pa_utils.EmptyAmtTab;
    TpSchLinePercentageTab  := pa_utils.EmptyAmtTab;
    TpRulePercentageTab     := pa_utils.EmptyAmtTab;
    --END  IC Changes

   -- New Jobs Model changes for 11i
    CostJobIdTab       	 := pa_utils.EmptyIdTab;
    TPJobIdTab       	 := pa_utils.EmptyIdTab;
    ProvProjBillJobIdTab := pa_utils.EmptyIdTab;
   -- End New Jobs Model changes for 11i

   -- Begin EPP changes
    PaDateTab               := pa_utils.EmptyDateTab ;
    PaPeriodNameTab         := pa_utils.EmptyChar15Tab;
    RecvrPaDateTab          := pa_utils.EmptyDateTab ;
    RecvrPaPeriodNameTab    := pa_utils.EmptyChar15Tab;
    GlPeriodNameTab         := pa_utils.EmptyChar15Tab;
    RecvrGlDateTab          := pa_utils.EmptyDateTab ;
    RecvrGlPeriodNameTab    := pa_utils.EmptyChar15Tab;
   -- End EPP changes

   -- start of project currency and EI attributes
    AssgnIDTab                 := pa_utils.EmptyIdTab;
    WorkTypeTab                := pa_utils.EmptyIdTab;
    ProjFuncCurrencyTab        := pa_utils.EmptyChar15Tab;
    ProjFuncCostRateDateTab    := pa_utils.EmptyDateTab ;
    ProjFunccostRateTypeTab    := pa_utils.EmptyChar30Tab;
    ProjfuncCostExgRateTab     := pa_utils.EmptyNewAmtTab;
    ProjRawCostTab             := pa_utils.EmptyNewAmtTab;
    ProjBurdendCostTab         := pa_utils.EmptyNewAmtTab;
    TpAmtTypeCode              := pa_utils.EmptyChar30Tab;
  -- End of project currency and  EI attributes

    -- AP Discounts
    Cdlsr4Tab      := pa_utils.EmptyChar30Tab ;

    -- Begin PA-J Period End Accrual Changes
    AccrualDateTab             := pa_utils.EmptyDateTab;
    RecvrAccrualDateTab        := pa_utils.EmptyDateTab;
    -- End PA-J Period End Accrual Changes

    --begin PA.M contingent worker and PJM attribute chnages
    Wip_Resource_IdTab	:= pa_utils.EmptyIdTab;
    Inventory_Item_IdTab	:= pa_utils.EmptyIdTab;
    Unit_Of_MeasureTab	:= pa_utils.EmptyChar30Tab ;
    Po_Line_IdTab		:= pa_utils.EmptyIdTab;
    Po_Price_TypeTab	:= pa_utils.EmptyChar30Tab ;
    Adjustment_TypeTab := pa_utils.EmptyChar150Tab ;
    --end PA.M contingent worker and PJM attribute chnages

    SrcEtypeClassTab := pa_utils.EmptyChar30Tab ; /* 4057874 */

    /* REL12-AP Lines uptake Start*/
    DocumentHeaderIDTab        := pa_utils.EmptyIdTab;
    DocumentDistributionIdTab  := pa_utils.EmptyIdTab;
    DocumentLineNumberTab      := pa_utils.EmptyIdTab;
    DocumentPaymentIDTab       := pa_utils.EmptyIdTab;
    VendorIdTab                := pa_utils.EmptyIdTab;
    DocumentTypeTab            := pa_utils.EmptyChar30Tab ;
    DocumentDistributionTypeTab:= pa_utils.EmptyChar30Tab ;
    SiAssetsAddFlagTab         := pa_utils.EmptyChar1Tab ;
    ScxferCodeTab              := pa_utils.EmptyChar1Tab ;
    Cdlsr5Tab                  := pa_utils.EmptyIdTab ;

    /* REL12-AP Lines uptake END*/
 --   Agreement_idTab            := pa_utils.EmptyIdTab ;  --FSIO Changes

    pa_cc_utils.log_message('End ');
    pa_cc_utils.reset_curr_function ;

  END  FlushEiTabs;



-- ========================================================================
-- PROCEDURE InsItemComment
-- ========================================================================

  PROCEDURE  InsItemComment ( X_ei_id       IN NUMBER
                            , X_ei_comment  IN VARCHAR2
                            , X_user        IN NUMBER
                            , X_login       IN NUMBER
                            , X_status      OUT NOCOPY NUMBER )
  IS
  BEGIN
    pa_cc_utils.set_curr_function('InsItemComment');
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('InsItemComment: ' || 'Start ');
    END IF;

    INSERT INTO pa_expenditure_comments (
           expenditure_item_id
         , line_number
         , expenditure_comment
         , last_update_date
         , last_updated_by
         , creation_date
         , created_by
         , last_update_login )
    VALUES (
           X_ei_id              -- expenditure_item_id
         , 10                   -- line_number
         , X_ei_comment         -- expenditure_comment
         , sysdate              -- last_update_date
         , X_user               -- last_updated_by
         , sysdate              -- creation_date
         , X_user               -- created_by
         , X_login );           -- last_update_login

    X_status := 0;
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('InsItemComment: ' || 'End ');
    END IF;
    pa_cc_utils.reset_curr_function ;

    EXCEPTION
      WHEN  OTHERS  THEN
        X_status := SQLCODE;
        RAISE;

  END  InsItemComment;


-- ========================================================================
-- PROCEDURE InsItems
-- ========================================================================

  PROCEDURE  InsItems( X_user              IN NUMBER
                     , X_login             IN NUMBER
                     , X_module            IN VARCHAR2
                     , X_calling_process   IN VARCHAR2
                     , Rows                IN BINARY_INTEGER
                     , X_status            OUT NOCOPY NUMBER
                     , X_gl_flag           IN  VARCHAR2 )
  IS
    temp_status     NUMBER DEFAULT NULL;

--  Added the following variables to update the request_id, program_id and program_app_id cols.
--  Selva 03/13/97

    x_request_id               NUMBER(15);
    x_program_application_id   NUMBER(15);
    x_program_id               NUMBER(15);
    x_err_code			          NUMBER(7) DEFAULT 0 ;
    x_err_stage		          VARCHAR2(255) ;
    x_err_stack		          VARCHAR2(255) ;
    l_pa_date                        DATE;
    l_recvr_pa_date                  DATE;                 /**CBGA**/

    l_x_gl_flag VARCHAR2(2);
    -- Oct 2001 Enhanced Period Processing
    -- Start EPP Changes
    l_PaPeriodName        pa_cost_distribution_lines_all.pa_period_name%TYPE;
    l_RecvrPaPeriodName   pa_cost_distribution_lines_all.recvr_pa_period_name%TYPE;
    l_GlPeriodName        pa_cost_distribution_lines_all.gl_period_name%TYPE;
    l_RecvrGlDate         pa_cost_distribution_lines_all.recvr_gl_date%TYPE;
    l_RecvrGlPeriodName   pa_cost_distribution_lines_all.recvr_gl_period_name%TYPE;
    l_SobId               pa_implementations_all.set_of_books_id%TYPE;
    l_RecvrSobId          pa_implementations_all.set_of_books_id%TYPE;

    x_return_status NUMBER;
    x_error_code    VARCHAR2(100);
    x_error_stage   NUMBER;
    -- End EPP Changes

    BackoutItemID    pa_utils.IdTabTyp; -- Bug 5501593
    item_comment     VARCHAR2(240); -- Bug 5501593

  BEGIN
    pa_cc_utils.set_curr_function('InsItems');
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('InsItems: ' || 'Start ');
    END IF;

	/* Bug Fix: 3258043  If the transaction import process calls insItems with gl_accounted_flag = 'Y'
	 * then donot override the GL period information
	 * Initialize the global variable gl_accounted_flag */
	PA_TRANSACTIONS.GL_ACCOUNTED_FLAG := NVL(X_gl_flag,'N') ;

    X_request_id := FND_GLOBAL.CONC_REQUEST_ID ;
    X_program_id := FND_GLOBAL.CONC_PROGRAM_ID  ;
    X_program_application_id := FND_GLOBAL.PROG_APPL_ID ;

    --PA-K Changes: Modified EI insert into bulk insert
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('InsItems: ' || 'Start of bulk insert for EI insertion');
    END IF;
    FORALL i IN 1..Rows  ---{
      INSERT INTO pa_expenditure_items_all (
             expenditure_item_id
           , expenditure_id
           , expenditure_item_date
           , task_id
           , expenditure_type
           , cost_distributed_flag
           , revenue_distributed_flag
           , billable_flag
           , bill_hold_flag
           , net_zero_adjustment_flag
           , non_labor_resource
           , organization_id
           , quantity
           , raw_cost                     -- project functional raw cost
           , raw_cost_rate
           , override_to_organization_id
           , orig_transaction_reference
           , transaction_source
           , adjusted_expenditure_item_id
           , attribute_category
           , attribute1
           , attribute2
           , attribute3
           , attribute4
           , attribute5
           , attribute6
           , attribute7
           , attribute8
           , attribute9
           , attribute10
           , source_expenditure_item_id
           , transferred_from_exp_item_id
           , last_update_date
           , last_updated_by
           , creation_date
           , created_by
           , last_update_login
           , job_id
           , org_id
           , labor_cost_multiplier_name
           , cost_burden_distributed_flag
           , burden_cost                        -- project functional burden cost
           , burden_cost_rate
           , request_id
           , program_application_id
           , program_id
           , system_linkage_function
           , burden_sum_dest_run_id
           , cost_ind_compiled_set_id
           , receipt_currency_amount
           , receipt_currency_code
           , receipt_exchange_rate
           , denom_currency_code
           , denom_raw_cost
           , denom_burdened_cost
           , acct_currency_code
           , acct_rate_date
           , acct_rate_type
           , acct_exchange_rate
           , acct_raw_cost
           , acct_burdened_cost
           , acct_exchange_rounding_limit
           , project_currency_code                -- project currency code
           , project_rate_date                    -- project rate date
           , project_rate_type                    -- project rate type
           , project_exchange_rate                -- project exchange rate
           , CC_CROSS_CHARGE_TYPE
           , CC_CROSS_CHARGE_CODE
           , CC_PRVDR_ORGANIZATION_ID
           , CC_RECVR_ORGANIZATION_ID
           , RECVR_ORG_ID
           , CC_BL_DISTRIBUTED_CODE
           , CC_IC_PROCESSED_CODE
           , DENOM_TP_CURRENCY_CODE
           , DENOM_TRANSFER_PRICE
           , ACCT_TP_RATE_TYPE
           , ACCT_TP_RATE_DATE
           , ACCT_TP_EXCHANGE_RATE
           , ACCT_TRANSFER_PRICE
           , PROJACCT_TRANSFER_PRICE
           , CC_MARKUP_BASE_CODE
           , TP_BASE_AMOUNT
           , TP_IND_COMPILED_SET_ID
           , TP_BILL_RATE
           , TP_BILL_MARKUP_PERCENTAGE
           , TP_SCHEDULE_LINE_PERCENTAGE
           , TP_RULE_PERCENTAGE
           , COST_JOB_ID
           , TP_JOB_ID
           , PROV_PROJ_BILL_JOB_ID
           , ASSIGNMENT_ID                          -- assignment id
           , WORK_TYPE_ID                           -- work type
           , PROJFUNC_CURRENCY_CODE                 -- project functional currency
           , PROJFUNC_COST_RATE_TYPE                -- project functional rate
           , PROJFUNC_COST_RATE_DATE                -- project functional rate date
           , PROJFUNC_COST_EXCHANGE_RATE            -- project functional exchange rate
           , PROJECT_RAW_COST
           , PROJECT_BURDENED_COST
           , PROJECT_ID
           , TP_AMT_TYPE_CODE
           , prvdr_accrual_date
           , recvr_accrual_date
           , Wip_Resource_Id
	   , Inventory_Item_Id
	   , Unit_Of_Measure
	   , Po_Line_Id
	   , Po_Price_Type
           , Adjustment_Type
           , Src_System_Linkage_Function  -- 4057874
           /* REL12-AP Lines uptake Start*/
	   , Document_header_id
	   , Document_distribution_ID
	   , Document_Line_number
	   , Document_Payment_ID
	   , Document_type
	   , Document_distribution_type
	   , Vendor_id
	   , historical_flag
           /* REL12-AP Lines uptake END*/
--           , agreement_id --FSIO Chnages
           )
      VALUES (
             EiIdTab(i)                   -- expenditure_item_id
           , EIdTab(i)                    -- expenditure_id
           , EiDateTab(i)                 -- expenditure_item_date
           , TskIdTab(i)                  -- task_id
           , ETypTab(i)                   -- expenditure_type
           , decode(nvl(X_gl_flag,'N'), 'Y', 'Y','P','Y', 'N')         -- cost_distributed_flag, changed for cost blue print project.
           , 'N'                          -- revenue_distributed_flag
           , BillFlagTab(i)               -- billable_flag
           , BillHoldTab(i)               -- bill_hold_flag
           , decode( AdjEiTab(i),
                     NULL, 'N', 'Y' )     -- net_zero_adjustment_flag
           , NlRscTab(i)                  -- non_labor_resource
           , NlRscOrgTab(i)               -- organization_id
           , QtyTab(i)                    -- quantity
           , RawCostTab(i)                -- raw_cost
           , RawRateTab(i)                -- raw_cost_rate
           , OvrOrgTab(i)                 -- override_to_organization_id
           , TrxRefTab(i)                 -- orig_transaction_reference
           , EiTrxSrcTab(i)               -- transaction_source
           , AdjEiTab(i)                  -- adjusted_expenditure_item_id
           , AttCatTab(i)                 -- attribute_category
           , Att1Tab(i)                   -- attribute1
           , Att2Tab(i)                   -- attribute2
           , Att3Tab(i)                   -- attribute3
           , Att4Tab(i)                   -- attribute4
           , Att5Tab(i)                   -- attribute5
           , Att6Tab(i)                   -- attribute6
           , Att7Tab(i)                   -- attribute7
           , Att8Tab(i)                   -- attribute8
           , Att9Tab(i)                   -- attribute9
           , Att10Tab(i)                  -- attribute10
           , SrcEiTab(i)                  -- source_expenditure_item_id
           , TfrEiTab(i)                  -- transferred_from_exp_item_id
           , sysdate                      -- last_update_date
           , X_user                       -- last_updated_by
           , sysdate                      -- creation_date
           , X_user                       -- created_by
           , X_login                      -- last_update_login
           , JobIdTab(i)                  -- job_id
           , OrgIdTab(i)                  -- org_id
           , LCMTab(i)                    -- labor_cost_multiplier_name
           --, decode(EtypeClassTab(i),'VI',decode(BurdenCompSetId(i),NULL,'X','N'),'N')
           --PA-K Changes
           --For all system linkages, base the cost burden dist flag on the compile set id
           , decode(BurdenCompSetId(i),NULL,'X','N')
                                          -- cost burden distributed flag modified for bug #1978887
           , BCostTab(i)                  -- Burdened_cost
           , BCostRateTab(i)              -- Burdened_cost_rate
           , x_request_id                 -- Request Id
           , x_program_application_id     -- Program Application Id
           , x_program_id                 -- Program Id
           , EtypeClassTab(i)             -- System Linkage Function
           , BurdenDestId(i)              -- Burden Summarization Dest Run Id
           , BurdenCompSetId(i)           -- Burden compile set id
           , ReceiptCurrAmt(i)                -- Receipt Currency Amount
           , ReceiptCurrCode(i)                  -- receipt Currency Code
           , ReceiptExRate(i)                 -- Receipt Exchange Rate
           , DenomCurrCode(i)                 -- Denomination Currency Code
           , DenomRawCost(i)                  -- Denomination Raw Cost
           , DenomBurdenCost(i)                  -- Denomination Burden Cost
           , AcctCurrCode(i)                     -- Accounting Currency Code
           , AcctRateDate(i)                  -- Accounting currency Rate Date
           , AcctRateType(i)                  -- Accounting Currency Rate Type
           , AcctExRate(i)                    -- Accounting Currency Exchange Rate
           , AcctRawCost(i)                   -- Accounting Currency Raw Cost
           , AcctBurdenCost(i)                -- Accounting Currency Burden Cost
           , AcctRoundLmt(i)              -- Accounting Currency Conversion Rounding Limit
           , ProjCurrCode(i)                  -- project Currency Code
           , ProjRateDate(i)                  -- Prohect Currency rate date
           , ProjRateType(i)                  -- project currency rate type
           , ProjExRate(i)               -- project currency exchange rate
           , CrossChargeTypeTab(i)
           , CrossChargeCodeTab(i)
           , PrvdrOrganizationTab(i)
           , RecvOrganizationTab(i)
           , RecvOperUnitTab(i)
           , BorrowLentCodeTab(i)
           , IcProcessedCodeTab(i)
           , DenomTpCurrCodeTab(i)
           , DenomTransferPriceTab(i)
           , AcctTpRateTypeTab(i)
           , AcctTpRateDateTab(i)
           , AcctTpExchangeRateTab(i)
           , AcctTransferPriceTab(i)
           , ProjacctTransferPriceTab(i)
           , CcMarkupBaseCodeTab(i)
           , TpBaseAmountTab(i)
           , TpIndCompiledSetIdTab(i)
           , TpBillRateTab(i)
           , TpBillMarkupPercentageTab(i)
           , TpSchLinePercentageTab(i)
           , TpRulePercentageTab(i)
           , CostJobIdTab(i)
           , ProvProjBillJobIdTab(i)
           , TPJobIdTab(i)
           , AssgnIDTab(i)                  -- assignment id
           , WorkTypeTab(i)                 -- work type id
           , ProjFuncCurrencyTab(i)         -- project functional currency
           , ProjFunccostRateTypeTab(i)     -- project functional rate type
           , ProjFuncCostRateDateTab(i)     -- project funcational rate date
           , ProjfuncCostExgRateTab(i)      -- project functional exchange rate
           , ProjRawCostTab(i)              -- project raw cost
           , ProjBurdendCostTab(i)          -- project burened cost
           , ProjIdTab(i)
           , TpAmtTypeCode(i)
           , AccrualDateTab(i)
           , RecvrAccrualDateTab(i)
           , Wip_Resource_IdTab(i)
           , Inventory_Item_IdTab(i)
           , Unit_Of_MeasureTab(i)
           , Po_Line_IdTab(i)
           , Po_Price_TypeTab(i)
           , Adjustment_TypeTab(i)
           , SrcEtypeClassTab(i) -- 4057874
           /* REL12-AP Lines uptake Start*/
	   , DocumentHeaderidTab(i)
	   , DocumentDistributionIDTab(i)
	   , DocumentLinenumberTab(i)
	   -- Bug: 5443263
	   -- R12.PJ:XB7:QA:APL:UPG:ADJUSTMENT REVERSAL NOT GETTING ACCOUNTED IN CASH
	   -- Cash basis invoice distribution interfaces to projects not payments for historical invoices.
	   -- (DocumentPaymentIDTab(i) value -1 indicates historical invoices.
	   --
	   , DECODE(DocumentPaymentIDTab(i), -1, NULL, DocumentPaymentIDTab(i) )
	   , DocumentTypeTab(i)
	   , DocumentDistributionTypeTab(i)
	   , VendoridTab(i)
	   -- Bug: 5443263
	   -- R12.PJ:XB7:QA:APL:UPG:ADJUSTMENT REVERSAL NOT GETTING ACCOUNTED IN CASH
	   -- Cash basis invoice distribution interfaces to projects not payments for historical invoices.
	   -- (DocumentPaymentIDTab(i) value -1 indicates historical invoices.
	   --
	   , DECODE(DocumentPaymentIDTab(i), -1, 'Y', 'N' )
           /* REL12-AP Lines uptake END*/
--           , Agreement_idTab(i) --FSIO Changes
       ); ---}

    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('InsItems: ' || 'End of bulk insert for EI insertion');
    END IF;

    FOR  i  IN 1..Rows  LOOP  ---{
     IF P_DEBUG_MODE  THEN
        pa_cc_utils.log_message('InsItems: ' || 'Start of Loop for CDL insertion');
     END IF;

     /* #1978887: In case of Supplier Invoices which are interfaced to Projects,
      Cost_Burden_Distributed_Flag should be set to 'N' only if the corresponding project
      type allows burdeneing. For this, we check the cost_ind_compiled_set_id. If some value
      exists for this field, it means the Burdening is there. Hence a check has been added for
      inserting into Cost_Burden_Distributed_Flag instead of inserting it with hard-coded 'N' */

     --PA-K Changes: Commented the following as bulk insert for EIs is being done now
     /*IF nvl(X_gl_flag,'N') <> 'Y' THEN
     **
     **INSERT INTO pa_expenditure_items_all (
     **	   )
     ** VALUES (
     **       );
     **ELSE
     **    INSERT INTO pa_expenditure_items_all (
     **	     )
     **    VALUES (
     **		);
     */

     --PA-K For GL Accoutned Txns, call CDL creation API row by row
     IF nvl(X_gl_flag,'N') in ('Y', 'P') THEN ---{

         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('InsItems: ' || 'After Insert');
         END IF;

         --   Added the following function call to calculate pa_date to Resolve Bug 1103257 base bug 967390

         --Commenting below such that if pa_date and recvr_pa_date is null then call the API
         --to get period information.

         /* EPP Changes
         l_pa_date := pa_integration.get_raw_cdl_pa_date(EiDateTab(i),GldateTab(i),OrgIdTab(i));   --CBGA
         l_recvr_pa_date := pa_integration.get_raw_cdl_recvr_pa_date(EiDateTab(i),GldateTab(i),RecvOperUnitTab(i));   --CBGA
         */

         IF (PaDateTab(i) is NULL  or RecvrPaDateTab(i) is null) THEN

            select set_of_books_id
            into l_SobId
            from pa_implementations_all
            where org_id = nvl(OrgIdTab(i),-99);

            select set_of_books_id
            into l_RecvrSobId
            from pa_implementations_all
            where org_id = nvl(RecvOperUnitTab(i),-99);

            pa_integration.get_period_information(
                 p_expenditure_item_date  => EiDateTab(i)
                ,p_prvdr_gl_date          => GldateTab(i)
                ,x_recvr_gl_date          => l_RecvrGlDate
                ,p_line_type              => 'R'
                ,p_prvdr_org_id           => OrgIdTab(i)
                ,p_recvr_org_id           => RecvOperUnitTab(i)
                ,p_prvdr_sob_id           => l_SobId
                ,p_recvr_sob_id           => l_RecvrSobId
                ,x_prvdr_pa_date          => l_Pa_Date
                ,x_prvdr_pa_period_name   => l_PaPeriodName
                ,x_prvdr_gl_period_name   => l_GlPeriodName
                ,x_recvr_pa_date          => l_Recvr_Pa_Date
                ,x_recvr_pa_period_name   => l_RecvrPaPeriodName
                ,x_recvr_gl_period_name   => l_RecvrGlPeriodName
                ,x_return_status          => x_return_status
                ,x_error_code             => x_error_code
                ,x_error_stage            => x_error_stage);

         ELSE

               l_Pa_Date           := PaDateTab(i);
               l_recvr_pa_date     := RecvrPaDateTab(i);
               l_PaPeriodName      := PaPeriodNameTab(i);
               l_RecvrPaPeriodName := RecvrPaPeriodNameTab(i);
               l_GlPeriodName      := GlPeriodNameTab(i);
               l_RecvrGlDate       := RecvrGlDateTab(i);
               l_RecvrGlPeriodName := RecvrGlPeriodNameTab(i);

         END IF;

	 --added this code to accomodate for cost blue-print project
	 IF(X_gl_flag ='P') THEN
		l_x_gl_flag := 'P';
	 ELSE

            -- REL12 AP Lines uptake
            -- supplier invoice adjusted expenditure items should have transfer status code 'P'
            --
	    IF scXferCodeTab(i) is not NULL AND
               EiTrxSrcTab(i) in ( 'AP EXPENSE', 'AP INVOICE', 'AP NRTAX' , 'AP ERV',
	       		           'INTERCOMPANY_AP_INVOICES', 'INTERPROJECT_AP_INVOICES',
                                   'AP VARIANCE', 'AP DISCOUNTS', 'PO RECEIPT', 'PO RECEIPT NRTAX',
	                           'PO RECEIPT PRICE ADJ', 'PO RECEIPT NRTAX PRICE ADJ' ) THEN
		l_x_gl_flag := ScXferCodeTab(i);
	    ELSE
		l_x_gl_flag := 'V';
	    END IF ;

	 END IF;

         Pa_Costing.CreateExternalCdl( X_expenditure_item_id         =>	EiIdTab(i)
                                     , X_ei_date                     =>	EiDateTab(i)
                                     , X_amount                      =>	RawCostTab(i)
                                     , X_dr_ccid                     =>	DrccidIdTab(i)
                                     , X_cr_ccid                     =>	CrccidIdTab(i)
                                     , X_transfer_status_code        => l_x_gl_flag
                                     , X_quantity                    =>	QtyTab(i)
                                     , X_billable_flag               =>	BillFlagTab(i)
                                     , X_request_id                  =>	x_request_id
                                     , X_program_application_id      =>	x_program_application_id
                                     , x_program_id                  =>	x_program_id
                                     , x_program_update_date         =>	sysdate
                                     , X_pa_date                     =>	l_pa_date
                                     , X_recvr_pa_date               =>	l_recvr_pa_date    /*CBGA*/
                                     , X_gl_date                     =>	GldateTab(i)
                                                                     /*Trx_Import enhancement*/
                                     , X_transferred_date            =>	SYSDATE
                                     , X_transfer_rejection_reason   =>	NULL
                                     , X_line_type                   =>	'R'
                                     , X_ind_compiled_set_id         =>	BurdenCompSetId(i)
                                     , X_burdened_cost               =>	BCostTab(i)
                                     , X_user                        =>	X_user
                                     , X_project_id                  =>	ProjIdTab(i)
                                     , X_task_id                     =>	TskidTab(i)
                                     , X_cdlsr1                      =>	Cdlsr1Tab(i)
                                     , X_cdlsr2                      =>	Cdlsr2Tab(i)
                                     , X_cdlsr3                      =>	Cdlsr3Tab(i)
                                     , X_denom_currency_code         =>	DenomCurrCode(i)
                                     , X_denom_raw_cost              =>	DenomRawCost(i)
                                     , X_denom_burden_cost           =>	DenomBurdenCost(i)
                                     , X_acct_currency_code          =>	AcctCurrCode(i)
                                     , X_acct_rate_date              =>	AcctRateDate(i)
                                     , X_acct_rate_type              =>	AcctRateType(i)
                                     , X_acct_exchange_rate          =>	AcctExRate(i)
                                     , X_acct_raw_cost               =>	AcctRawCost(i)
                                     , X_acct_burdened_cost          =>	AcctBurdenCost(i)
                                     , X_project_currency_code       =>	ProjCurrCode(i)
                                     , X_project_rate_date           =>	ProjRateDate(i)
                                     , X_project_rate_type           =>	ProjRateType(i)
                                     , X_project_exchange_rate       =>	ProjExRate(i)
                                     , X_err_code                    =>	X_err_code
                                     , X_err_stage                   =>	X_err_stage
                                     , X_err_stack                   =>	X_err_stack
                                     , P_PaPeriodName                => l_PaPeriodName
                                     , P_RecvrPaPeriodName           => l_RecvrPaPeriodName
                                     , P_GlPeriodName                => l_GlPeriodName
                                     , P_RecvrGlDate                 => l_RecvrGlDate
                                     , P_RecvrGlPeriodName           => l_RecvrGlPeriodName
                                     /** Added for project currency and EI attributes **/
                                     , p_projfunc_currency_code      => ProjFunccurrencyTab(i)
                                     , p_projfunc_cost_rate_date          => ProjfuncCostRateDateTab(i)
                                     , p_projfunc_cost_rate_type          => ProjfuncCostRateTypeTab(i)
                                     , p_projfunc_cost_exchange_rate      => ProjFuncCostExgRateTab(i)
                                     , p_project_raw_cost            => ProjRawCostTab(i)
                                     , p_project_burdened_cost       => ProjBurdendCostTab(i)
                                     --, p_assignment_id               => AssignIdTab(i)
                                     , p_work_type_id                => WorktypeTab(i)
                                     -- AP Discounts
                                     , p_cdlsr4                      => Cdlsr4Tab(i)
				     , p_si_assets_addition_flag     => SiAssetsAddFlagTab(i)
                                     , p_cdlsr5                      => Cdlsr5Tab(i)
--                                     , p_agreement_id                => Agreement_idTab(i) --FSIO Changes
                                     );

         IF P_DEBUG_MODE  THEN
            pa_cc_utils.log_message('InsItems: ' || 'After Creation of CDL');
         END IF;

     END IF ; ---}

     -- dbms_output.put_line( 'error code : ' || to_char( x_err_code)) ;
     IF X_err_code <> 0 THEN
         x_status := x_err_code ;
         pa_cc_utils.reset_curr_function ;
         RETURN ;
     END IF ;

     IF ( EiCommentTab(i) IS NOT NULL ) THEN
        InsItemComment( X_ei_id       =>	EiIdTab(i)
                      , X_ei_comment  =>	EiCommentTab(i)
                      , X_user        =>	X_user
                      , X_login       =>	X_login
                      , X_status      =>	temp_status );

        Pa_Adjustments.CheckStatus( status_indicator => temp_status );

     END IF;

     IF ( X_calling_process = 'TRX_IMPORT' ) THEN
        IF P_DEBUG_MODE  THEN
           pa_cc_utils.log_message('Trx Import call to InsItems');
        END IF;

        IF ( AdjEiTab(i) IS NOT NULL ) THEN  ---{

          pa_adjustments.InsAuditRec( X_exp_item_id       =>	AdjEiTab(i)
                                  , X_adj_activity      =>	'MANUAL BACK-OUT ORIGINATING'
                                  , X_module            =>	X_module
                                  , X_user              =>	X_user
                                  , X_login             =>	X_login
                                  , X_status            =>	temp_status );
          IF P_DEBUG_MODE  THEN
             pa_cc_utils.log_message('InsItems: ' || 'After call to InsAuditRec');
          END IF;

          Pa_Adjustments.CheckStatus( status_indicator => temp_status );

          pa_adjustments.InsAuditRec( X_exp_item_id       =>	EiIdTab(i)
                                  , X_adj_activity      =>	'MANUAL BACK-OUT'
                                  , X_module            =>	X_module
                                  , X_user              =>	X_user
                                  , X_login             =>	X_login
                                  , X_status            =>	temp_status
			/* R12 Changes Start */
                                  , X_who_req_id        =>      pa_adjustments.G_REQUEST_ID
                                  , X_who_prog_id       =>      pa_adjustments.G_PROGRAM_ID
                                  , X_who_prog_app_id   =>      pa_adjustments.G_PROG_APPL_ID
                                  , X_who_prog_upd_date =>      sysdate);
			/* R12 Changes End */

          Pa_Adjustments.CheckStatus( status_indicator => temp_status );

          pa_adjustments.SetNetZero( X_exp_item_id   =>	AdjEiTab(i)
                                 , X_user          =>	X_user
                                 , X_login         =>	X_login
                                 , X_status        =>	temp_status );
          IF P_DEBUG_MODE  THEN
             pa_cc_utils.log_message('InsItems: ' || 'After call to SetNetZero');
          END IF;

	  -- R12 AP Lines uptake
	  -- SLA need to have parent line_num populated with the latest cdl line
	  -- num of adjusted expenditure item to resolve performance issue.
	  --
          IF nvl(X_gl_flag,'N') in ('Y', 'P') THEN ---{
	     update pa_cost_distribution_lines cdl1
	        set cdl1.parent_line_num = ( select cdl2.line_num
		                               from pa_cost_distribution_lines cdl2
					      where cdl2.expenditure_item_id	= AdjEiTab(i)
					        and cdl2.line_type           = 'R'
						and cdl2.reversed_flag       is NULL
						and cdl2.line_num_reversed   is NULL )
	      where cdl1.expenditure_item_id = EiIdTab(i)
	        and cdl1.line_type           = 'R'
		and cdl1.reversed_flag      is NULL
		and cdl1.line_num_reversed  is NULL ;
	  END IF ; --}

          Pa_Adjustments.CheckStatus( status_indicator => temp_status );

          pa_adjustments.ReverseRelatedItems( X_source_exp_item_id  =>	AdjEiTab(i)
                                          , X_expenditure_id      =>	NULL
                                          , X_module              =>	X_module
                                          , X_user                =>	X_user
                                          , X_login               =>	X_login
                                          , X_status              => temp_status );
          IF P_DEBUG_MODE  THEN
             pa_cc_utils.log_message('InsItems: ' || 'After call to ReverseRelatedItems');
          END IF;

          Pa_Adjustments.CheckStatus( status_indicator => temp_status );

        END IF;  ---}
     END IF;  ---}

    END LOOP; ---}

/* Bug 5501593 - Start */
    IF X_calling_process = 'TRANSFER' THEN
        FOR i IN 1..Rows LOOP
/* Audit trail for the original expenditure item */
            pa_adjustments.InsAuditRec( X_exp_item_id       =>	TfrEiTab(i)
                                      , X_adj_activity      =>	'TRANSFER ORIGINATING'
                                      , X_module            =>	X_module
                                      , X_user              =>	X_user
                                      , X_login             =>	X_login
                                      , X_status            =>	temp_status
                                      , X_who_req_id        =>  pa_adjustments.G_REQUEST_ID
                                      , X_who_prog_id       =>  pa_adjustments.G_PROGRAM_ID
                                      , X_who_prog_app_id   =>  pa_adjustments.G_PROG_APPL_ID
                                      , X_who_prog_upd_date =>  sysdate);
            Pa_Adjustments.CheckStatus( status_indicator => temp_status );

/* Audit trail for new expenditure item */
            pa_adjustments.InsAuditRec( X_exp_item_id       =>	EiIdTab(i)
                                      , X_adj_activity      =>	'TRANSFER DESTINATION'
                                      , X_module            =>	X_module
                                      , X_user              =>	X_user
                                      , X_login             =>	X_login
                                      , X_status            =>	temp_status
                                      , X_who_req_id        =>  pa_adjustments.G_REQUEST_ID
                                      , X_who_prog_id       =>  pa_adjustments.G_PROGRAM_ID
                                      , X_who_prog_app_id   =>  pa_adjustments.G_PROG_APPL_ID
                                      , X_who_prog_upd_date =>  sysdate);
            Pa_Adjustments.CheckStatus( status_indicator => temp_status );

/* Get the expenditure Item IDs for all reversinf EIs */
            BackoutItemID(i) := pa_utils.GetNextEiId;
        END LOOP;

/* Insert the Reversing expenditure Items */
        FORALL i IN 1..Rows
        INSERT INTO pa_expenditure_items_all(
            expenditure_item_id
          , task_id
          , expenditure_type
          , system_linkage_function
          , expenditure_item_date
          , expenditure_id
          , override_to_organization_id
          , last_update_date
          , last_updated_by
          , creation_date
          , created_by
          , last_update_login
          , quantity
          , revenue_distributed_flag
          , bill_hold_flag
          , billable_flag
          , bill_rate_multiplier
          , cost_distributed_flag
          , raw_cost
          , raw_cost_rate
          , burden_cost
          , burden_cost_rate
          , cost_ind_compiled_set_id
          , non_labor_resource
          , organization_id
          , adjusted_expenditure_item_id
          , net_zero_adjustment_flag
          , attribute_category
          , attribute1
          , attribute2
          , attribute3
          , attribute4
          , attribute5
          , attribute6
          , attribute7
          , attribute8
          , attribute9
          , attribute10
          , transferred_from_exp_item_id
          , transaction_source
          , orig_transaction_reference
          , source_expenditure_item_id
          , job_id
          , org_id
          , labor_cost_multiplier_name
          , receipt_currency_amount
          , receipt_currency_code
          , receipt_exchange_rate
          , denom_currency_code
          , denom_raw_cost
          , denom_burdened_cost
          , acct_currency_code
          , acct_rate_date
          , acct_rate_type
          , acct_exchange_rate
          , acct_raw_cost
          , acct_burdened_cost
          , acct_exchange_rounding_limit
          , project_currency_code
          , project_rate_date
          , project_rate_type
          , project_exchange_rate
          , cc_cross_charge_code
          , cc_prvdr_organization_id
          , cc_recvr_organization_id
          , cc_rejection_code
          , denom_tp_currency_code
          , denom_transfer_price
          , acct_tp_rate_type
          , acct_tp_rate_date
          , acct_tp_exchange_rate
          , acct_transfer_price
          , projacct_transfer_price
          , cc_markup_base_code
          , tp_base_amount
          , cc_cross_charge_type
          , recvr_org_id
          , cc_bl_distributed_code
          , cc_ic_processed_code
          , tp_ind_compiled_set_id
          , tp_bill_rate
          , tp_bill_markup_percentage
          , tp_schedule_line_percentage
          , tp_rule_percentage
          , cost_job_id
          , tp_job_id
          , prov_proj_bill_job_id
          , assignment_id
          , work_type_id
          , projfunc_currency_code
          , projfunc_cost_rate_date
          , projfunc_cost_rate_type
          , projfunc_cost_exchange_rate
          , project_raw_cost
          , project_burdened_cost
          , project_id
          , project_tp_rate_date
          , project_tp_rate_type
          , project_tp_exchange_rate
          , project_transfer_price
          , tp_amt_type_code
          , cost_burden_distributed_flag
          , capital_event_id
          , wip_resource_id
          , inventory_item_id
          , unit_of_measure
          , document_header_id
          , document_distribution_id
          , document_line_number
          , document_payment_id
          , vendor_id
          , document_type
          , document_distribution_type)
--          , agreement_id ) --FSIO Changes
        SELECT
            BackoutItemID(i)                 -- expenditure_item_id
         ,  ei.task_id                       -- task_id
         ,  ei.expenditure_type              -- expenditure_type
         ,  ei.system_linkage_function       -- system_linkage_function
         ,  ei.expenditure_item_date         -- expenditure_item_date
         ,  ei.expenditure_id                -- expenditure_id
         ,  ei.override_to_organization_id   -- override exp organization
         ,  sysdate                          -- last_update_date
         ,  X_user                           -- last_updated_by
         ,  sysdate                          -- creation_date
         ,  X_user                           -- created_by
         ,  X_login                          -- last_update_login
         ,  (0 - ei.quantity)                -- quantity
         ,  'N'                              -- revenue_distributed_flag
         ,  ei.bill_hold_flag                -- bill_hold_flag
         ,  ei.billable_flag                 -- billable_flag
         ,  ei.bill_rate_multiplier          -- bill_rate_multiplier
         ,  'N'                              -- cost_distributed_flag
         ,  (0 - ei.raw_cost)                -- raw_cost
         ,  ei.raw_cost_rate                 -- raw_cost_rate
         ,  (0 - ei.burden_cost)             -- raw_cost
         ,  ei.burden_cost_rate              -- raw_cost_rate
         ,  ei.cost_ind_compiled_set_id      -- cost_ind_compiled_set_id
         ,  ei.non_labor_resource            -- non_labor_resource
         ,  ei.organization_id               -- organization_id
         ,  ei.expenditure_item_id           -- adjusted_expenditure_item_id
         ,  'Y'                              -- net_zero_adjustment_flag
         ,  ei.attribute_category            -- attribute_category
         ,  ei.attribute1                    -- attribute1
         ,  ei.attribute2                    -- attribute2
         ,  ei.attribute3                    -- attribute3
         ,  ei.attribute4                    -- attribute4
         ,  ei.attribute5                    -- attribute5
         ,  ei.attribute6                    -- attribute6
         ,  ei.attribute7                    -- attribute7
         ,  ei.attribute8                    -- attribute8
         ,  ei.attribute9                    -- attribute9
         ,  ei.attribute10                   -- attribute10
         ,  ei.transferred_from_exp_item_id  -- tfr from exp item id
         ,  ei.transaction_source            -- transaction_source
         ,  decode(ei.transaction_source,'PTE TIME',NULL,
            decode(ei.transaction_source,'PTE EXPENSE',NULL,
    	    decode(ei.transaction_source,'ORACLE TIME AND LABOR',NULL,
	    decode(ei.transaction_source,'Oracle Self Service Time',NULL,
                   ei.orig_transaction_reference)))) -- orig_transaction_reference
         ,  ei.source_expenditure_item_id    -- source_expenditure_item_id
         ,  ei.job_id                        -- job_id
         ,  ei.org_id                        -- org_id
         ,  ei.labor_cost_multiplier_name    -- labor_cost_multiplier_name
         , (0 - ei.receipt_currency_amount)  -- receipt_currency_amount
         ,  ei.receipt_currency_code         -- receipt_currency_code
         ,  ei.receipt_exchange_rate         -- receipt_exchange_rate
         ,  ei.denom_currency_code           -- denom_currency_code
         ,  (0 - ei.denom_raw_cost)          -- denom_raw_cost
         ,  (0 - ei.denom_burdened_cost)     -- denom_burdened_cost
         ,  ei.acct_currency_code            -- acct_currency_code
         ,  ei.acct_rate_date                -- acct_rate_date
         ,  ei.acct_rate_type                -- acct_rate_type
         ,  ei.acct_exchange_rate            -- acct_exchange_rate
         ,  (0 - ei.acct_raw_cost)           -- acct_raw_cost
         ,  (0 - ei.acct_burdened_cost)      -- acct_burdened_cost
         ,  ei.acct_exchange_rounding_limit  -- acct_exchange_rounding_limit
         ,  ei.project_currency_code         -- project_currency_code
         ,  ei.project_rate_date             -- project_rate_date
         ,  ei.project_rate_type             -- project_rate_type
         ,  ei.project_exchange_rate         -- project_exchange_rate
         ,  ei.cc_cross_charge_code          -- cc_cross_charge_code
         ,  ei.cc_prvdr_organization_id      -- cc_prvdr_organization_id
         ,  ei.cc_recvr_organization_id      -- cc_recvr_organization_id
         ,  ei.cc_rejection_code             -- cc_rejection_code
         ,  ei.denom_tp_currency_code        -- denom_tp_currency_code
         ,  (0 - ei.denom_transfer_price)    -- denom_transfer_price
         ,  ei.acct_tp_rate_type             -- acct_tp_rate_type
         ,  ei.acct_tp_rate_date             -- acct_tp_rate_date
         ,  ei.acct_tp_exchange_rate         -- acct_tp_exchange_rate
         ,  (0 - ei.acct_transfer_price)     -- acct_transfer_price
         ,  (0 - ei.projacct_transfer_price) -- projacct_transfer_price
         ,  ei.cc_markup_base_code           -- cc_markup_base_code
         ,  (0 - ei.tp_base_amount)          -- tp_base_amount
         ,  ei.cc_cross_charge_type          -- cc_cross_charge_type
         ,  ei.recvr_org_id                  -- recvr_org_id
         ,  ei.cc_bl_distributed_code        -- cc_bl_distributed_code
         ,  ei.cc_ic_processed_code          -- cc_ic_processed_code
         ,  ei.tp_ind_compiled_set_id        -- tp_ind_compiled_set_id
         ,  ei.tp_bill_rate                  -- tp_bill_rate
         ,  ei.tp_bill_markup_percentage     -- tp_bill_markup_percentage
         ,  ei.tp_schedule_line_percentage   -- tp_schedule_line_percentage
         ,  ei.tp_rule_percentage            -- tp_rule_percentage
         ,  ei.cost_job_id                   -- cost_job_id
         ,  ei.tp_job_id                     -- tp_job_id
         ,  ei.prov_proj_bill_job_id         -- prov_proj_bill_job_id
         ,  ei.assignment_id
         ,  ei.work_type_id
         ,  ei.projfunc_currency_code
         ,  ei.projfunc_cost_rate_date
         ,  ei.projfunc_cost_rate_type
         ,  ei.projfunc_cost_exchange_rate
         ,  (0 - ei.project_raw_cost)         -- project raw cost
         ,  (0 - ei.project_burdened_cost)    -- project burended cost
         ,  ei.project_id
         ,  ei.project_tp_rate_date
         ,  ei.project_tp_rate_type
         ,  ei.project_tp_exchange_rate
         ,  (0 - ei.project_transfer_price)
         ,  ei.tp_amt_type_code
         ,  decode(ei.cost_ind_compiled_set_id,null,'X','N')
         ,  capital_event_id
         , wip_resource_id
         , inventory_item_id
         , unit_of_measure
         ,  ei.document_header_id
         ,  ei.document_distribution_id
         ,  ei.document_line_number
         ,  ei.document_payment_id
         ,  ei.vendor_id ei_vendor_id
         ,  ei.document_type
         ,  ei.document_distribution_type
--         ,  ei.agreement_id  --FSIO Changes
        FROM
            pa_expenditure_items_all ei
        WHERE
            ei.expenditure_item_id = TfrEiTab(i);

        FOR i IN 1..Rows LOOP
/* Create comment for the reversing EI if they exist for the original EI */
            BEGIN
                SELECT ec.expenditure_comment
                INTO item_comment
                FROM pa_expenditure_comments ec
                WHERE ec.expenditure_item_id = TfrEiTab(i);
            EXCEPTION
                WHEN NO_DATA_FOUND  THEN
                    NULL;
            END;
            IF ( item_comment IS NOT NULL ) THEN
                pa_transactions.InsItemComment( X_ei_id => BackoutItemID(i)
                                              , X_ei_comment => item_comment
                                              , X_user => X_user
                                              , X_login => X_login
                                              , X_status => temp_status );
                pa_adjustments.CheckStatus( status_indicator => temp_status );
            END IF;

/* Set Net Zero Flag on the Original Expenditure Item */
            pa_adjustments.SetNetZero( TfrEiTab(i)
                      , X_user
                      , X_login
                      , temp_status );
            pa_adjustments.CheckStatus( temp_status );

/* Create an Audit trail */
            pa_adjustments.InsAuditRec( BackoutItemID(i)
                , 'TRANSFER BACK-OUT'
                , X_module
                , X_user
                , X_login
                , temp_status
	        , pa_adjustments.G_REQUEST_ID
                , pa_adjustments.G_PROGRAM_ID
	        , pa_adjustments.G_PROG_APPL_ID
	        , sysdate );
            pa_adjustments.CheckStatus( temp_status );

/* Create a reversing CDL */
            Pa_Costing.CreateReverseCdl( X_exp_item_id => TfrEiTab(i),
                                         X_backout_id  => BackoutItemID(i),
                                         X_user        => X_user,
                                         X_status      => temp_status);
            Pa_Adjustments.CheckStatus( status_indicator => temp_status );

/* Reverse Related Items */
            pa_adjustments.ReverseRelatedItems( X_source_exp_item_id  => TfrEiTab(i)
                                              , X_expenditure_id      => NULL
                                              , X_module              => X_module
                                              , X_user                => X_user
                                              , X_login               => X_login
                                              , X_status              => temp_status );
            Pa_Adjustments.CheckStatus( status_indicator => temp_status );
        END LOOP;
    END IF;
/* Bug 5501593 - End */

   X_status := 0;
   IF P_DEBUG_MODE  THEN
      pa_cc_utils.log_message('InsItems: ' || 'End ');
   END IF;
   pa_cc_utils.reset_curr_function ;

  EXCEPTION
     WHEN  OTHERS  THEN
        X_status := SQLCODE;
        RAISE;

  END  InsItems;

-- ========================================================================
-- PROCEDURE
-- Added Multi-Currency Transactions columns Shree 08/06
-- ========================================================================

  PROCEDURE  InsertExp( X_expenditure_id              IN NUMBER
                      , X_expend_status               IN VARCHAR2
                      , X_expend_ending               IN DATE
                      , X_expend_class                IN VARCHAR2
                      , X_inc_by_person               IN NUMBER
                      , X_inc_by_org                  IN NUMBER
                      , X_expend_group                IN VARCHAR2
                      , X_entered_by_id               IN NUMBER
                      , X_created_by_id               IN NUMBER
                      , X_attribute_category          IN VARCHAR2
                      , X_attribute1                  IN VARCHAR2
                      , X_attribute2                  IN VARCHAR2
                      , X_attribute3                  IN VARCHAR2
                      , X_attribute4                  IN VARCHAR2
                      , X_attribute5                  IN VARCHAR2
                      , X_attribute6                  IN VARCHAR2
                      , X_attribute7                  IN VARCHAR2
                      , X_attribute8                  IN VARCHAR2
                      , X_attribute9                  IN VARCHAR2
                      , X_attribute10                 IN VARCHAR2
                      , X_description                 IN VARCHAR2
                      , X_control_total               IN NUMBER
                      , X_denom_currency_code         IN VARCHAR2
                      , X_acct_currency_code          IN VARCHAR2
                      , X_acct_rate_type              IN VARCHAR2
                      , X_acct_rate_date              IN DATE
                      , X_acct_exchange_rate          IN NUMBER
                      -- Trx_import enhancement: Adding new parameters
                      -- These values will be inserted into PA_EXPENDITURES_ALL table
                      , X_orig_exp_txn_reference1     IN VARCHAR2
                      , X_orig_user_exp_txn_reference IN VARCHAR2
                      , X_vendor_id                   IN NUMBER
                      , X_orig_exp_txn_reference2     IN VARCHAR2
                      , X_orig_exp_txn_reference3     IN VARCHAR2
		              , X_person_type                 IN VARCHAR2
                      , P_Org_ID                      IN NUMBER -- 12i MOAC changes
                      )
  IS
  BEGIN
    pa_cc_utils.set_curr_function('InsertExp');
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('InsertExp: ' || 'Start ');
    END IF;
    INSERT INTO pa_expenditures(
         expenditure_id
      ,  expenditure_status_code
      ,  expenditure_ending_date
      ,  expenditure_class_code
      ,  incurred_by_person_id
      ,  incurred_by_organization_id
      ,  expenditure_group
      ,  entered_by_person_id
      ,  last_update_date
      ,  last_updated_by
      ,  creation_date
      ,  created_by
      ,  attribute_category
      ,  attribute1
      ,  attribute2
      ,  attribute3
      ,  attribute4
      ,  attribute5
      ,  attribute6
      ,  attribute7
      ,  attribute8
      ,  attribute9
      ,  attribute10
      ,  description
      ,  control_total_amount
      ,  denom_currency_code
      ,  acct_currency_code
      ,  acct_rate_type
      ,  acct_rate_date
      ,  acct_exchange_rate
      -- Trx_import enhancement
      ,  orig_exp_txn_reference1
      ,  orig_user_exp_txn_reference
      ,  vendor_id
      ,  orig_exp_txn_reference2
      ,  orig_exp_txn_reference3
      ,  person_type
      ,  org_id) -- 12i MOAC changes
    VALUES (
         X_expenditure_id
      ,  X_expend_status
      ,  X_expend_ending
      ,  X_expend_class
      ,  X_inc_by_person
      ,  X_inc_by_org
      ,  X_expend_group
      ,  X_entered_by_id
      ,  sysdate
      ,  X_created_by_id
      ,  sysdate
      ,  X_created_by_id
      ,  X_attribute_category
      ,  X_attribute1
      ,  X_attribute2
      ,  X_attribute3
      ,  X_attribute4
      ,  X_attribute5
      ,  X_attribute6
      ,  X_attribute7
      ,  X_attribute8
      ,  X_attribute9
      ,  X_attribute10
      ,  X_description
      ,  X_control_total
      ,  X_denom_currency_code
      ,  X_acct_currency_code
      ,  X_acct_rate_type
      ,  X_acct_rate_date
      ,  X_acct_exchange_rate
      -- Trx_import enhancement
      ,  X_orig_exp_txn_reference1
      ,  X_orig_user_exp_txn_reference
      ,  X_vendor_id
      ,  X_orig_exp_txn_reference2
      ,  X_orig_exp_txn_reference3
      ,  X_person_type
      ,  P_Org_Id); -- 12i MOAC changes
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('InsertExp: ' || 'End ');
    END IF;
    pa_cc_utils.reset_curr_function ;

  END  InsertExp;


  PROCEDURE  InsertExpGroup(
                  X_expenditure_group      IN VARCHAR2
               ,  X_exp_group_status_code  IN VARCHAR2
               ,  X_ending_date            IN DATE
               ,  X_system_linkage         IN VARCHAR2
               ,  X_created_by             IN NUMBER
               ,  X_transaction_source     IN VARCHAR2
               ,  P_accrual_flag           IN VARCHAR2
               ,  P_Org_Id                 IN NUMBER) -- 12i MOAC changes
  IS
  BEGIN
    pa_cc_utils.set_curr_function('InsertExpGroup');
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('InsertExp: ' || 'Start ');
    END IF;

    INSERT INTO pa_expenditure_groups(
              expenditure_group
           ,  expenditure_group_status_code
           ,  expenditure_ending_date
           ,  system_linkage_function
           ,  last_update_date
           ,  last_updated_by
           ,  creation_date
           ,  created_by
           ,  transaction_source
           ,  period_accrual_flag
           ,  Org_Id)  -- 12i MOAC changes
    VALUES (  X_expenditure_group
           ,  X_exp_group_status_code
           ,  X_ending_date
           ,  X_system_linkage
           ,  sysdate
           ,  X_created_by
           ,  sysdate
           ,  X_created_by
           ,  X_transaction_source
           ,  P_accrual_flag
           ,  P_Org_Id); -- 12i MOAC changes
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('InsertExp: ' || 'End ');
    END IF;
    pa_cc_utils.reset_curr_function ;

  END  InsertExpGroup;

  --PA-K Changes
  PROCEDURE  InsertExpGroupNew(
                  X_expenditure_group      IN VARCHAR2
               ,  X_exp_group_status_code  IN VARCHAR2
               ,  X_ending_date            IN DATE
               ,  X_system_linkage         IN VARCHAR2
               ,  X_created_by             IN NUMBER
               ,  X_transaction_source     IN VARCHAR2
               ,  P_accrual_flag           IN VARCHAR2
               ,  P_Org_Id                 IN NUMBER ) -- 12i MOAC changes
  IS

    l_Dummy       NUMBER;
    l_Ending_Date DATE;

  BEGIN
    pa_cc_utils.set_curr_function('InsertExpGroupNew');
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('InsertExp: ' || 'Start ');
    END IF;

    Begin

       IF P_DEBUG_MODE  THEN
          pa_cc_utils.log_message('InsertExp: ' || 'Selecting if the group already exists');
       END IF;

       select 1, expenditure_ending_date
       into l_Dummy, l_Ending_Date
       from  pa_expenditure_groups
       where expenditure_group = X_expenditure_group;

    Exception
       when no_data_found then
            IF P_DEBUG_MODE  THEN
               pa_cc_utils.log_message('InsertExp: ' || 'no data found when selecting if group already exists');
            END IF;
            l_dummy := 0 ;

    End;

    If (l_dummy = 0) Then
       IF P_DEBUG_MODE  THEN
          pa_cc_utils.log_message('InsertExp: ' || 'Exp Group does not exist, insert');
       END IF;

       INSERT INTO pa_expenditure_groups(
                      expenditure_group
                   ,  expenditure_group_status_code
                   ,  expenditure_ending_date
                   ,  system_linkage_function
                   ,  last_update_date
                   ,  last_updated_by
                   ,  creation_date
                   ,  created_by
                   ,  transaction_source
                   ,  period_accrual_flag
                   ,  org_id) -- 12i MOAC changes
       VALUES (  X_expenditure_group
              ,  X_exp_group_status_code
              ,  X_ending_date
              ,  X_system_linkage
              ,  sysdate
              ,  X_created_by
              ,  sysdate
              ,  X_created_by
              ,  X_transaction_source
              ,  P_accrual_flag
              ,  P_Org_Id);  -- 12i MOAC changes

    Else

       IF P_DEBUG_MODE  THEN
          pa_cc_utils.log_message('InsertExp: ' || 'Exp Group does exist, update if needed');
       END IF;

       If trunc(X_ending_date) > trunc(l_Ending_Date) Then

          IF P_DEBUG_MODE  THEN
             pa_cc_utils.log_message('InsertExp: ' || 'Existing Exp Groups ending date is lesser, update');
          END IF;

          update pa_expenditure_groups
             set expenditure_ending_date = X_ending_date
           where expenditure_group = X_expenditure_group;

          IF P_DEBUG_MODE  THEN
             pa_cc_utils.log_message('InsertExp: ' || 'Updated Count = '||SQL%ROWCOUNT);
          END IF;

       End If;

    End If;

    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('InsertExp: ' || 'End ');
    END IF;
    pa_cc_utils.reset_curr_function ;

  END  InsertExpGroupNew;


  PROCEDURE  CreateRelatedItem(
                  X_source_exp_item_id   IN NUMBER
               ,  X_project_id           IN NUMBER
               ,  X_task_id              IN NUMBER
               ,  X_Award_id             IN NUMBER
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
               ,  X_work_type_name       IN VARCHAR2 /*bug2482593*/
                )
  IS

    X_expenditure_item_id      NUMBER(15);
    X_expenditure_id           NUMBER(15);
    X_expenditure_item_date    DATE;
    X_inc_by_person_id         NUMBER(15);
    X_inc_by_org_id            NUMBER(15);
    X_orig_proj_id             NUMBER(15);
    X_orig_task_id             NUMBER(15);
    X_dest_proj_id             NUMBER(15);
    X_dest_task_id             NUMBER(15);
    X_billable_flag            VARCHAR2(1);
    X_bill_hold_flag           VARCHAR2(1);
    X_system_linkage           VARCHAR2(30);
    X_etype_class              VARCHAR2(3);
    X_job_id                   NUMBER(15);
    X_org_id                   NUMBER(15);
    temp_status                NUMBER;
    temp_outcome               VARCHAR2(30);
    dummy                      NUMBER DEFAULT NULL;
    l_dest_lcm                     VARCHAR2(20);
    l_orig_lcm                     VARCHAR2(20);
    X_denom_currency_code      VARCHAR2(15);
    X_Acct_currency_code       VARCHAR2(15);
    X_project_currency_code    VARCHAR2(15) ;
    temp_msg_application   VARCHAR2(30)  :='PA';
    temp_msg_type          VARCHAR2(1)   :='E';
    temp_msg_token1        VARCHAR2(240) :='';
    temp_msg_token2        VARCHAR2(240) :='';
    temp_msg_token3        VARCHAR2(240) :='';
    temp_msg_count         NUMBER ;
    X_project_rate_type       VARCHAR2(30);
    X_project_rate_date       DATE ;
    X_project_exchange_rate   NUMBER ;
    l_PROJFUNC_CURRENCY_CODE           VARCHAR2(30);
    l_PROJFUNC_COST_RATE_TYPE          VARCHAR2(30);
    l_PROJFUNC_COST_RATE_DATE          DATE ;
    l_PROJFUNC_COST_EXCHANGE_RATE      NUMBER ;
    l_PROJECT_RAW_COST                 NUMBER ;
    l_PROJECT_BURDENED_COST            NUMBER ;
    l_ASSIGNMENT_ID                    NUMBER ;
    l_WORK_TYPE_ID                     NUMBER ;
    l_PROJECT_TP_CURRENCY_CODE         VARCHAR2(30);
    l_PROJECT_TP_COST_RATE_DATE        DATE ;
    l_PROJECT_TP_COST_RATE_TYPE        VARCHAR2(30);
    l_PROJECT_TP_COST_EXG_RATE         NUMBER ;
    l_PROJECT_TRANSFER_PRICE           NUMBER ;
    l_gms_enabled                      VARCHAR(1); /*added for bug 5769510*/
    adl_rec    gms_award_distributions%ROWTYPE; /*added for bug 5769510*/
    source_award_id                    NUMBER ; /*added for bug 5769510*/


  BEGIN
    pa_cc_utils.set_curr_function('CreateRelatedItem');
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('CreateRelatedItem: ' || 'Start ');
    END IF;

    l_gms_enabled := gms_pa_costing_pkg.grants_implemented;

    /* changes for bug2482593 starts */
    if(X_work_type_name IS NOT NULL)then
          Begin
            select work_type_id
            into l_work_type_id
            from pa_work_types_tl
            where name=X_work_type_name AND
                  language = userenv('LANG');
          exception
                when no_data_found then
                  X_status := 10;
                  IF P_DEBUG_MODE  THEN
                     pa_cc_utils.log_message('CreateRelatedItem: ' || 'Invalid Work Type Name');
                  END IF;
                  pa_cc_utils.reset_curr_function ;
                  X_outcome := 'INVALID_WORK_TYPE';
                  return;
          end;

    else
          IF P_DEBUG_MODE  THEN
             pa_cc_utils.log_message('CreateRelatedItem: ' || 'Work Type ID defaults from source EI');
          END IF;
          select work_type_id
          into l_work_type_id
          from pa_expenditure_items
          where expenditure_item_id = X_source_exp_item_id;
    end if;
    /* changes for bug2482593 ends */

  -- Need to select new MC columns here to pass to LoadEi and PATC
    SELECT
            pa_expenditure_items_s.nextval
    ,       ei.expenditure_id
    ,       ei.expenditure_item_date
    ,       e.incurred_by_person_id
    ,       e.incurred_by_organization_id
    ,       ei.source_expenditure_item_id
    ,       ei.bill_hold_flag
    ,       t.project_id
    ,       t.task_id
    ,       ei.job_id
    ,       ei.org_id
    ,       ei.system_linkage_function
    ,       ei.denom_currency_code
    ,       ei.acct_currency_code
    ,       ei.project_currency_code
    ,       ei.project_rate_type
    ,       ei.project_rate_date
    ,       ei.project_exchange_rate
    ,       t.labor_cost_multiplier_name
    ,       ei.PROJFUNC_CURRENCY_CODE
    ,       ei.PROJFUNC_COST_RATE_TYPE
    ,       ei.PROJFUNC_COST_RATE_DATE
    ,       ei.PROJFUNC_COST_EXCHANGE_RATE
    ,       NULL -- bug 4719803 ei.PROJECT_RAW_COST
    ,       NULL -- bug 4719803 ei.PROJECT_BURDENED_COST
    ,       ei.ASSIGNMENT_ID
    /* ,    ei.WORK_TYPE_ID  bug2482593 */
      INTO
            X_expenditure_item_id
    ,       X_expenditure_id
    ,       X_expenditure_item_date
    ,       X_inc_by_person_id
    ,       X_inc_by_org_id
    ,       dummy
    ,       X_bill_hold_flag
    ,       X_orig_proj_id
    ,       X_orig_task_id
    ,       X_job_id
    ,       X_org_id
    ,       X_etype_class
    ,       X_denom_currency_code
    ,       X_Acct_currency_code
    ,       X_project_currency_code
    ,       X_project_rate_type
    ,       X_project_rate_date
    ,       X_project_exchange_rate
    ,       l_orig_lcm
    ,       l_PROJFUNC_CURRENCY_CODE
    ,       l_PROJFUNC_COST_RATE_TYPE
    ,       l_PROJFUNC_COST_RATE_DATE
    ,       l_PROJFUNC_COST_EXCHANGE_RATE
    ,       l_PROJECT_RAW_COST
    ,       l_PROJECT_BURDENED_COST
    ,       l_ASSIGNMENT_ID
/*    ,       l_WORK_TYPE_ID bug2482593*/
      FROM
            pa_expenditure_items ei
    ,       pa_expenditures e
    ,       pa_tasks t
     WHERE
            e.expenditure_id = ei.expenditure_id
       AND  ei.expenditure_item_id = X_source_exp_item_id
       AND  ei.task_id = t.task_id;
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('In pa_transactions.CreateRelatedItem: After select statement');
    END IF;

    IF (    X_project_id IS NULL
         OR X_task_id IS NULL ) THEN

      X_dest_proj_id := X_orig_proj_id;
      X_dest_task_id := X_orig_task_id;

    ELSE

      X_dest_proj_id := X_project_id;
      X_dest_task_id := X_task_id;

    END IF;

    IF ( dummy IS NOT NULL ) THEN

      X_outcome := 'PA_TR_RELATED_ITEM';
      X_status  := 1;
      pa_cc_utils.reset_curr_function ;
      RETURN;

    END IF;
/*
    IF ( NOT pa_exp_copy.CheckExpTypeActive( X_expenditure_type
                                           , X_expenditure_item_date ) ) THEN

      X_outcome := 'EXP_TYPE_INACTIVE';
      X_status  := 1;
      pa_cc_utils.reset_curr_function ;
      RETURN;

    END IF;
*/
    SELECT
            count(*)
      INTO
            dummy
      FROM
            sys.dual
      WHERE EXISTS
            ( SELECT NULL
                FROM pa_expenditure_types
               WHERE expenditure_type = X_expenditure_type);

    IF ( dummy = 0 ) THEN

      X_outcome := 'INVALID_EXP_TYPE';
      X_status  := 1;
      pa_cc_utils.reset_curr_function ;
      RETURN;

    END IF;

    IF ( X_etype_class NOT IN ('ST', 'OT' ) ) THEN
      X_outcome := 'INVALID_EXP_TYPE';
      X_status  := 1;
      pa_cc_utils.reset_curr_function ;
      RETURN;
    END IF;


    dummy := NULL;

    IF ( X_override_to_org_id IS NOT NULL ) THEN

      SELECT
              count(*)
        INTO
              dummy
        FROM
              sys.dual
       WHERE EXISTS
               ( SELECT NULL
                   FROM pa_organizations_v
                  WHERE organization_id = X_override_to_org_id);

      IF ( dummy = 0 ) THEN

        X_outcome := 'INVALID_ORGANIZATION';
        X_status  := 1;
        pa_cc_utils.reset_curr_function ;
        RETURN;

      END IF;

    END IF;

    -- This section added for bug 791759
    IF ( x_task_id  IS NULL ) THEN
       l_dest_lcm                    :=  l_orig_lcm ;
    ELSE
       l_dest_lcm                    := pa_utils2.GetLaborCostMultiplier(x_task_id);
    END IF;

    --

   -- Fix for Bug # 801194. This call to get_status was removed in 11.0
   -- for Bug # 519532.Since, Billable flag is an OUT parameter and was getting
   -- populated in get_status, it was seen that a null was getting passed. Hence
   -- added the call to get_status again.
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('CreateRelatedItem: ' || 'Before Call to PATC');
    END IF;

 pa_transactions_pub.validate_transaction(
                       X_project_id          => X_dest_proj_id
                     , X_task_id             => X_dest_task_id
                     , X_ei_date             => X_expenditure_item_date
                     , X_expenditure_type    => X_expenditure_type
                     , X_non_labor_resource  => NULL
                     , X_person_id           => X_inc_by_person_id
                     , X_quantity            => 0
                     , X_denom_currency_code => X_denom_currency_code
                     , X_acct_currency_code  => X_Acct_currency_code
                     , X_denom_raw_cost      => X_denom_raw_cost
                     , X_acct_raw_cost       => NULL
                     , X_acct_rate_type      => NULL
                     , X_acct_rate_date      => NULL
                     , X_acct_exchange_rate  => NULL
                     , X_transfer_ei         => NULL
                     , X_incurred_by_org_id  => X_inc_by_org_id
                     , X_nl_resource_org_id  => NULL
                     , X_transaction_source  => NULL
                     , X_calling_module      => 'CreateRelatedItem'
                     , X_vendor_id           => NULL
                     , X_entered_by_user_id  => X_userid
                     , X_attribute_category  => X_attribute_category
                     , X_attribute1          => X_attribute1
                     , X_attribute2          => X_attribute2
                     , X_attribute3          => X_attribute3
                     , X_attribute4          => X_attribute4
                     , X_attribute5          => X_attribute5
                     , X_attribute6          => X_attribute6
                     , X_attribute7          => X_attribute7
                     , X_attribute8          => X_attribute8
                     , X_attribute9          => X_attribute9
                     , X_attribute10         => X_attribute10
                     , X_attribute11         => ''
                     , X_attribute12         => ''
                     , X_attribute13         => ''
                     , X_attribute14         => ''
                     , X_attribute15         => ''
                     , X_msg_application     => temp_msg_application
                     , X_msg_type            => temp_msg_type
                     , X_msg_token1          => temp_msg_token1
                     , X_msg_token2          => temp_msg_token2
                     , X_msg_token3          => temp_msg_token3
                     , X_msg_count           => temp_msg_count
                     , X_msg_data            => temp_outcome
                     , X_billable_flag       => X_billable_flag
                     , p_projfunc_currency_code   => l_projfunc_currency_code
                     , p_projfunc_cost_rate_type  => l_projfunc_cost_rate_type
                     , p_projfunc_cost_rate_date  => l_projfunc_cost_rate_date
                     , p_projfunc_cost_exchg_rate => l_projfunc_cost_exchange_rate
                     , p_assignment_id            => l_assignment_id
                     , p_work_type_id             => l_work_type_id
		     , p_sys_link_function        => X_etype_class);
		     /* Added p_sys_link_function        => X_etype_class for bug3557261 */

    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('CreateRelatedItem: ' || 'After Call to PATC');
    END IF;

    /* Start of Bug 2648550 */
    l_assignment_id := PATC.G_OVERIDE_ASSIGNMENT_ID;
    l_work_type_id := PATC.G_OVERIDE_WORK_TYPE_ID;
    /* End of Bug 2648550 */
    IF (( temp_outcome IS NOT NULL) and
        ( temp_msg_type = 'E') ) THEN
      -- Since this is a batch program, we handle only errors,no warnings

       X_outcome := temp_outcome;
       X_status  := 1;
       pa_cc_utils.reset_curr_function ;
       RETURN;

    END IF;

    /* Start of Bug 5984498 */

    IF (l_gms_enabled = 'Y' ) and (x_award_id is NOT NULL) THEN
    	gms_transactions_pub.validate_transaction( X_dest_proj_id
           			,  X_dest_task_id
	   				,  x_award_id
           			,  X_expenditure_type
           			,  X_expenditure_item_date
					,  'CLIENT_EXTN'
					,  temp_outcome       ) ;

	    IF P_DEBUG_MODE  THEN
	       pa_cc_utils.log_message('CreateRelatedItem: ' || 'After Call to gms_transactions_pub.validate_transaction');
	    END IF;

	    IF ( temp_outcome IS NOT NULL) THEN

	       X_outcome := temp_outcome;
	       pa_cc_utils.reset_curr_function ;
	       RETURN;

	    END IF;
    END IF;

   /* End of Bug 5984498 */


-- Passed denom_raw_cost will be stored in array using LoadEi procedure
-- All other new currency attributes (introduced in Multi-Currency Transactions)
-- will be set to NULL.
-- Costing program will calculate appropriate values for accounting and
-- project currency columns

-- Fix for Bug # 813758
-- Need to pass denom acct and proj currency as well as project curr attributes
-- since for the related item this should be the same as the parent


    /*
     * IC related change
     * Send the Recvr_Org_Id to LOADEI using the new API defined
     * in PA_UTILS2
     */
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('CreateRelatedItem: ' || 'Before Call to LoadEi');
    END IF;

    pa_transactions.LoadEi( X_expenditure_item_id     =>	X_expenditure_item_id
                           ,X_expenditure_id          =>	X_expenditure_id
                           ,X_expenditure_item_date   =>	X_expenditure_item_date
                           ,X_project_id              =>	x_dest_proj_id  --Bug fix : 2201207 NULL
                           ,X_task_id                 =>	X_dest_task_id
                           ,X_expenditure_type        =>	X_expenditure_type
                           ,X_non_labor_resource      =>	NULL
                           ,X_nl_resource_org_id      =>	NULL
                           ,X_quantity                =>	0
                           ,X_raw_cost                =>	NULL
                           ,X_raw_cost_rate           =>	X_denom_raw_cost_rate
                           ,X_override_to_org_id      =>	X_override_to_org_id
                           ,X_billable_flag           =>	X_billable_flag
                           ,X_bill_hold_flag          =>	X_bill_hold_flag
                           ,X_orig_transaction_ref    =>	NULL
                           ,X_transferred_from_ei     =>	NULL
                           ,X_adj_expend_item_id      =>	NULL
                           ,X_attribute_category      =>	X_attribute_category
                           ,X_attribute1              =>	X_attribute1
                           ,X_attribute2              =>	X_attribute2
                           ,X_attribute3              =>	X_attribute3
                           ,X_attribute4              =>	X_attribute4
                           ,X_attribute5              =>	X_attribute5
                           ,X_attribute6              =>	X_attribute6
                           ,X_attribute7              =>	X_attribute7
                           ,X_attribute8              =>	X_attribute8
                           ,X_attribute9              =>	X_attribute9
                           ,X_attribute10             =>	X_attribute10
                           ,X_ei_comment              =>	X_comment
                           ,X_transaction_source      =>	NULL
                           ,X_source_exp_item_id      =>	X_source_exp_item_id
                           ,i                         =>	1
                           ,X_job_id                  =>	X_job_id
                           ,X_org_id                  =>	X_org_id
	                   ,X_labor_cost_multiplier_name  =>	 l_dest_lcm
                           ,X_drccid                  =>	NULL
                           ,X_crccid                  =>	NULL
                           ,X_cdlsr1                  =>	NULL
                           ,X_cdlsr2                  =>	NULL
                           ,X_cdlsr3                  =>	NULL
                           ,X_gldate                  =>	NULL
                           ,X_bcost                   =>	NULL
                           ,X_bcostrate               =>	NULL
                           ,X_etypeclass              =>	X_etype_class
                           ,X_burden_sum_dest_run_id  =>	NULL
                           ,X_burden_compile_set_id   =>	NULL
                           ,X_receipt_currency_amount =>	NULL
                           ,X_receipt_currency_code   =>	NULL
                           ,X_receipt_exchange_rate   =>	NULL
                           ,X_denom_currency_code     =>	X_denom_currency_code,
                            X_denom_raw_cost          =>	X_denom_raw_cost
                           ,X_denom_burdened_cost     =>	NULL
                           ,X_acct_currency_code      =>	X_Acct_currency_code
                           ,X_acct_rate_date          =>	NULL
                           ,X_acct_rate_type          =>	NULL
                           ,X_acct_exchange_rate      =>	NULL
                           ,X_acct_raw_cost           =>	NULL
                           ,X_acct_burdened_cost      =>	NULL
                           ,X_acct_exchange_rounding_limit =>	NULL
                           ,X_project_currency_code   =>	X_project_currency_code
                           ,X_project_rate_date       =>	X_project_rate_date
                           ,X_project_rate_type       =>	X_project_rate_type
                           ,X_project_exchange_rate   =>	X_project_exchange_rate
                           ,X_Recv_Operating_Unit     =>    PA_UTILS2.GetPrjOrgId(X_dest_proj_id,
                                                                                  X_dest_task_id)
                           , p_assignment_id                => l_ASSIGNMENT_ID
                           , p_work_type_id                 => l_WORK_TYPE_ID
                           , p_projfunc_currency_code       => l_PROJFUNC_CURRENCY_CODE
                           , p_projfunc_cost_rate_date      => l_PROJFUNC_COST_RATE_DATE
                           , p_projfunc_cost_rate_type      => l_PROJFUNC_COST_RATE_TYPE
                           , p_projfunc_cost_exchange_rate  => l_PROJFUNC_COST_EXCHANGE_RATE
                           , p_project_raw_cost             => l_PROJECT_RAW_COST
                           , p_project_burdened_cost        => l_PROJECT_BURDENED_COST
				);
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('CreateRelatedItem: ' || 'After call to LoadEi');
    END IF;

    pa_transactions.InsItems( X_user              =>	X_userid
                            , X_login             =>	0
                            , X_module            =>	'CreateRelatedItem'
                            , X_calling_process   =>	'RELATED_ITEM'
                            , Rows                =>	1
                            , X_status            => 	temp_status
                            , X_gl_flag           =>	'N'     );
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('CreateRelatedItem: ' || 'After call to InsItems');
    END IF;

    /*start of bug 5769510*/
  IF (l_gms_enabled = 'Y') THEN

      if (x_award_id is NULL) then

    select DISTINCT award_id
                  into source_award_id
                  from gms_award_distributions adl
                  where adl.expenditure_item_id =  X_source_exp_item_id
                  and adl.document_type = 'EXP'
                  and adl_status = 'A' ;
       Else
           source_award_id := x_award_id ;
       END IF;


                adl_rec.expenditure_item_id      := X_expenditure_item_id  ;
                adl_rec.cost_distributed_flag    := 'N';
                adl_rec.project_id               := x_dest_proj_id;
                adl_rec.task_id                  := X_dest_task_id  ;
                adl_rec.cdl_line_num              := NULL; -- Bug 1906331
                adl_rec.adl_line_num              := 1;
                adl_rec.distribution_value        := 100;
                adl_rec.line_type                 :='R';
                adl_rec.adl_status                := 'A';
                adl_rec.document_type             := 'EXP';
                adl_rec.billed_flag               := 'N';
                adl_rec.bill_hold_flag            := NULL ;
                adl_rec.award_set_id              := gms_awards_dist_pkg.get_award_set_id;
                adl_rec.award_id                  := source_award_id ;
                adl_rec.raw_cost                  := NULL;
                adl_rec.last_update_date          := sysdate ;
                adl_rec.creation_date            := sysdate;
                adl_rec.last_updated_by          := X_userid ;
                adl_rec.created_by               := X_userid ;
                adl_rec.last_update_login        := 0  ;

         gms_awards_dist_pkg.create_adls(adl_rec);

END IF;

    pa_transactions.FlushEiTabs;

    X_status  := 0;
    X_outcome := NULL;
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('CreateRelatedItem: ' || 'End ');
    END IF;
    pa_cc_utils.reset_curr_function ;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      X_status := -1403;
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  CreateRelatedItem;


-- Modified the parameter name from raw_cost to denom_raw_cost as well as
-- raw_cost_rate as denom_raw_cost_rate
-- Note : In this phase (11.1), cost_rates will be defined in accounting
--        currency (i.e. currency code of set of books in which costing
--        will be done)
  PROCEDURE  UpdateRelatedItem( X_expenditure_item_id  IN NUMBER
                              , X_denom_raw_cost             IN NUMBER
                              , X_denom_raw_cost_rate        IN NUMBER
                              , X_status               OUT NOCOPY NUMBER
                              , X_work_type_name             IN VARCHAR2 /*bug2482593*/
                                )
  IS

    l_work_type_id              NUMBER; /* bug2482593 */

  BEGIN
    pa_cc_utils.set_curr_function('UpdateRelatedItem');
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('UpdateRelatedItem: ' || 'Start ');
    END IF;

    /* changes for bug 2482593 start */
    if(X_work_type_name IS NOT NULL) then
          Begin
            select work_type_id
            into l_work_type_id
            from pa_work_types_tl
            where name=X_work_type_name AND
                  language = userenv('LANG');
          exception
                when no_data_found then
                  X_status := 10;
                  IF P_DEBUG_MODE  THEN
                     pa_cc_utils.log_message('UpdateRelatedItem: ' || 'Invalid Work Type Name');
                  END IF;
                  pa_cc_utils.reset_curr_function ;
                  return;
          end;

/*    else
        {
          pa_cc_utils.log_message("Work Type ID defaults from source EI");
          select work_type_id
          into l_work_type_id
          from pa_expenditure_items
          where expenditure_item_id = X_Expenditure_item_id;
        }
*/
    end if;
    /* changes for bug 2482593 end */

    UPDATE  pa_expenditure_items ei
       SET  ei.denom_raw_cost = pa_currency.round_trans_currency_amt(X_denom_raw_cost,
                                                              ei.denom_currency_code)
           ,ei.RAW_COST = NULL           /* Added for bug#5067217 */
           ,ei.ACCT_RAW_COST = NULL      /* Added for bug#5067217*/
           ,ei.PROJECT_RAW_COST = NULL   /* Added for bug#5067217 */
           ,ei.raw_cost_rate = X_denom_raw_cost_rate
           ,ei.work_type_id = l_work_type_id        /* bug2482593 */
     WHERE ei.expenditure_item_id = X_expenditure_item_id
       AND (ei.adjusted_expenditure_item_id is NULL or ei.denom_raw_cost is NULL); /*bug 5617096*/

/*
 * Commented for Bug 5617096
    UPDATE  pa_expenditure_items ei
       SET
            ei.denom_raw_cost = pa_currency.round_trans_currency_amt(X_denom_raw_cost,
                                                             ei.denom_currency_code)
    ,       ei.raw_cost_rate = X_denom_raw_cost_rate
    ,       ei.work_type_id = l_work_type_id        ** bug2482593 **
     WHERE
            ei.expenditure_item_id = X_expenditure_item_id;
*/
    X_status := 0;
    IF P_DEBUG_MODE  THEN
       pa_cc_utils.log_message('UpdateRelatedItem: ' || 'End ');
    END IF;
    pa_cc_utils.reset_curr_function ;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      X_status := -1403;
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  UpdateRelatedItem;

/* Added as a fix for bug# 1358018 */

  PROCEDURE UpdateSystemLinkFunc (
                 X_expend_item_id IN NUMBER
               , X_sys_link_func  IN VARCHAR2
             )
  IS
  BEGIN

   UPDATE pa_expenditure_items ei
   SET ei.system_linkage_function = X_sys_link_func
   WHERE ei.source_expenditure_item_id = X_expend_item_id;


   EXCEPTION
   WHEN OTHERS THEN
      RAISE;
  END UpdateSystemLinkFunc;


END PA_TRANSACTIONS;

/
