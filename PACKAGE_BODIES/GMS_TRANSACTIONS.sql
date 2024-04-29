--------------------------------------------------------
--  DDL for Package Body GMS_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_TRANSACTIONS" AS
/* $Header: GMSTRANB.pls 115.3 2002/11/26 12:41:21 mmalhotr ship $ */


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
                   , X_job_id                       IN NUMBER default null
                   , X_org_id                       IN NUMBER default null
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
		             , X_denom_raw_cost	             IN NUMBER   default NULL
		             , X_denom_burdened_cost          IN NUMBER   default NULL
 		             , X_acct_currency_code           IN VARCHAR2 default null
		             , X_acct_rate_date  	          IN DATE     default NULL
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
                   , X_Cross_Charge_Code            IN VArchar2 default 'P'
                   , X_Prvdr_organization_id        IN Number default NULL
                   , X_Recv_organization_id         IN Number default NULL
                   , X_Recv_Operating_Unit          IN Number default NULL
                   , X_Borrow_Lent_Dist_Code        IN VARCHAR2 default 'X'
                   , X_Ic_Processed_Code            IN VARCHAR2 default 'X'
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
                   , X_Tp_Rule_Percentage           IN Number default NULL )

  IS
  BEGIN
null;
/*
-- dbms_output.put_line('In Loadei:'||to_char(i));
    pa_cc_utils.set_curr_function('LoadEi');
    pa_cc_utils.log_message('Start ');

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
    RawCostTab(i)     := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(X_raw_cost, X_project_currency_code);
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
    BCostTab(i)       := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(X_bcost,X_project_currency_code)  ;
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
    pa_cc_utils.log_message('End ');
    pa_cc_utils.reset_curr_function ;
*/
  END  LoadEi;


-- ========================================================================
-- PROCEDURE FlushEiTabs
-- ========================================================================

  PROCEDURE  FlushEiTabs
  IS
  BEGIN
null;
/*
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
    pa_cc_utils.log_message('End ');
    pa_cc_utils.reset_curr_function ;
*/

  END  FlushEiTabs;



-- ========================================================================
-- PROCEDURE InsItemComment
-- ========================================================================
/*
  PROCEDURE  InsItemComment ( X_ei_id       IN NUMBER
                            , X_ei_comment  IN VARCHAR2
                            , X_user        IN NUMBER
                            , X_login       IN NUMBER
                            , X_status      OUT NOCOPY NUMBER )
  IS
  BEGIN


    pa_cc_utils.set_curr_function('InsItemComment');
    pa_cc_utils.log_message('Start ');

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
    pa_cc_utils.log_message('End ');
    pa_cc_utils.reset_curr_function ;

    EXCEPTION
      WHEN  OTHERS  THEN
        X_status := SQLCODE;
        RAISE;

  END  InsItemComment;

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

  BEGIN
null;
/*
    pa_cc_utils.set_curr_function('InsItems');
    pa_cc_utils.log_message('Start ');

    X_request_id := FND_GLOBAL.CONC_REQUEST_ID ;
    X_program_id := FND_GLOBAL.CONC_PROGRAM_ID  ;
    X_program_application_id := FND_GLOBAL.PROG_APPL_ID ;

--   -- dbms_output.PUT_LINE(' Gl flag : ' || X_gl_flag ) ;

    FOR  i  IN 1..Rows  LOOP
    pa_cc_utils.log_message('Start of Loop');
--    -- dbms_output.PUT_LINE(' Gl date : ' || to_char( GldateTab(i), 'DD-MON-YY') ) ;
    IF nvl(X_gl_flag,'N') <> 'Y' THEN

      INSERT INTO gms_encumbrance_items_all (
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
           , raw_cost
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
           , burden_cost
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
	        , project_currency_code
	        , project_rate_date
   	     , project_rate_type
	        , project_exchange_rate
           , CC_CROSS_CHARGE_TYPE,
             CC_CROSS_CHARGE_CODE,
             CC_PRVDR_ORGANIZATION_ID,
             CC_RECVR_ORGANIZATION_ID,
             RECVR_ORG_ID,
             CC_BL_DISTRIBUTED_CODE,
             CC_IC_PROCESSED_CODE,
             DENOM_TP_CURRENCY_CODE,
             DENOM_TRANSFER_PRICE,
             ACCT_TP_RATE_TYPE,
             ACCT_TP_RATE_DATE,
             ACCT_TP_EXCHANGE_RATE,
             ACCT_TRANSFER_PRICE,
             PROJACCT_TRANSFER_PRICE,
             CC_MARKUP_BASE_CODE,
             TP_BASE_AMOUNT,
             TP_IND_COMPILED_SET_ID,
             TP_BILL_RATE,
             TP_BILL_MARKUP_PERCENTAGE,
             TP_SCHEDULE_LINE_PERCENTAGE,
             TP_RULE_PERCENTAGE)
      VALUES (
             EiIdTab(i)                   -- expenditure_item_id
           , EIdTab(i)                    -- expenditure_id
           , EiDateTab(i)                 -- expenditure_item_date
           , TskIdTab(i)                  -- task_id
           , ETypTab(i)                   -- expenditure_type
           , 'N'                          -- cost_distributed_flag
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
           , 'N'                          -- cost burden distributed flag
           , BCostTab(i)                  -- Burdened_cost
           , BCostRateTab(i)              -- Burdened_cost_rate
           , x_request_id                 -- Request Id
           , x_program_application_id     -- Program Application Id
           , x_program_id                 -- Program Id
           , EtypeClassTab(i)             -- System Linkage Function
           , BurdenDestId(i)              -- Burden Summarization Dest Run Id
           , BurdenCompSetId(i)           -- Burden compile set id
           , ReceiptCurrAmt(i) 		      -- Receipt Currency Amount
           , ReceiptCurrCode(i) 	         -- receipt Currency Code
           , ReceiptExRate(i)  		      -- Receipt Exchange Rate
           , DenomCurrCode(i)  		      -- Denomination Currency Code
           , DenomRawCost(i)   		      -- Denomination Raw Cost
           , DenomBurdenCost(i) 	         -- Denomination Burden Cost
           , AcctCurrCode(i)		         -- Accounting Currency Code
           , AcctRateDate(i)   		      -- Accounting currency Rate Date
           , AcctRateType(i)   		      -- Accounting Currency Rate Type
           , AcctExRate(i)     		      -- Accounting Currency Exchange Rate
           , AcctRawCost(i)    		      -- Accounting Currency Raw Cost
           , AcctBurdenCost(i) 		      -- Accounting Currency Burden Cost
           , AcctRoundLmt(i)              -- Accounting Currency Conversion Rounding Limit
           , ProjCurrCode(i)   		      -- project Currency Code
           , ProjRateDate(i)   		      -- Prohect Currency rate date
           , ProjRateType(i)   		      -- project currency rate type
           , ProjExRate(i)    	         -- project currency exchange rate
           , CrossChargeTypeTab(i)   ,
             CrossChargeCodeTab(i)   ,
             PrvdrOrganizationTab(i) ,
             RecvOrganizationTab(i)  ,
             RecvOperUnitTab(i)      ,
             BorrowLentCodeTab(i)    ,
             IcProcessedCodeTab(i)   ,
             DenomTpCurrCodeTab(i)   ,
             DenomTransferPriceTab(i),
             AcctTpRateTypeTab(i)    ,
             AcctTpRateDateTab(i)    ,
             AcctTpExchangeRateTab(i),
             AcctTransferPriceTab(i) ,
             ProjacctTransferPriceTab(i) ,
             CcMarkupBaseCodeTab(i)   ,
             TpBaseAmountTab(i)       ,
             TpIndCompiledSetIdTab(i) ,
             TpBillRateTab(i)         ,
             TpBillMarkupPercentageTab(i) ,
             TpSchLinePercentageTab(i),
             TpRulePercentageTab(i));
      ELSE
         INSERT INTO gms_encumbrance_items_all (
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
           , raw_cost
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
           , burden_cost
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
	        , project_currency_code
	        , project_rate_date
   	     , project_rate_type
	        , project_exchange_rate
           , CC_CROSS_CHARGE_TYPE,
             CC_CROSS_CHARGE_CODE,
             CC_PRVDR_ORGANIZATION_ID,
             CC_RECVR_ORGANIZATION_ID,
             RECVR_ORG_ID,
             CC_BL_DISTRIBUTED_CODE,
             CC_IC_PROCESSED_CODE,
             DENOM_TP_CURRENCY_CODE,
             DENOM_TRANSFER_PRICE,
             ACCT_TP_RATE_TYPE,
             ACCT_TP_RATE_DATE,
             ACCT_TP_EXCHANGE_RATE,
             ACCT_TRANSFER_PRICE,
             PROJACCT_TRANSFER_PRICE,
             CC_MARKUP_BASE_CODE,
             TP_BASE_AMOUNT,
             TP_IND_COMPILED_SET_ID,
             TP_BILL_RATE,
             TP_BILL_MARKUP_PERCENTAGE,
             TP_SCHEDULE_LINE_PERCENTAGE,
             TP_RULE_PERCENTAGE)
         VALUES (
             EiIdTab(i)                   -- expenditure_item_id
           , EIdTab(i)                    -- expenditure_id
           , EiDateTab(i)                 -- expenditure_item_date
           , TskIdTab(i)                  -- task_id
           , ETypTab(i)                   -- expenditure_type
           , 'Y'                          -- cost_distributed_flag
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
           , 'N'                          -- cost burden distributed flag
           , BCostTab(i)                  -- Burdened_cost
           , BCostRateTab(i)              -- Burdened_cost_rate
           , x_request_id                 -- Request Id
           , x_program_application_id     -- Program Application Id
           , x_program_id                 -- Program Id
           , EtypeClassTab(i)             -- System Linkage Function
           , BurdenDestId(i)              -- Burden Summarization Dest Run Id
           , BurdenCompSetId(i)           -- Burden compile set id
           , ReceiptCurrAmt(i) 		      -- Receipt Currency Amount
           , ReceiptCurrCode(i) 	         -- receipt Currency Code
           , ReceiptExRate(i)  		      -- Receipt Exchange Rate
           , DenomCurrCode(i)  		      -- Denomination Currency Code
           , DenomRawCost(i)   		      -- Denomination Raw Cost
           , DenomBurdenCost(i) 	         -- Denomination Burden Cost
	        , AcctCurrCode(i)   		      -- Accounting Currency Code
           , AcctRateDate(i)   		      -- Accounting currency Rate Date
           , AcctRateType(i)   		      -- Accounting Currency Rate Type
           , AcctExRate(i)     		      -- Accounting Currency Exchange Rate
           , AcctRawCost(i)    		      -- Accounting Currency Raw Cost
           , AcctBurdenCost(i) 		      -- Accounting Currency Burden Cost
           , AcctRoundLmt(i)              -- Accounting Currency Conversion Rounding Limit
           , ProjCurrCode(i)   		      -- project Currency Code
           , ProjRateDate(i)   		      -- Project Currency rate date
           , ProjRateType(i)   		      -- project currency rate type
           , ProjExRate(i)    	         -- project currency exchange rate
           , CrossChargeTypeTab(i)   ,
             CrossChargeCodeTab(i)   ,
             PrvdrOrganizationTab(i) ,
             RecvOrganizationTab(i)  ,
             RecvOperUnitTab(i)      ,
             BorrowLentCodeTab(i)    ,
             IcProcessedCodeTab(i)   ,
             DenomTpCurrCodeTab(i)   ,
             DenomTransferPriceTab(i),
             AcctTpRateTypeTab(i)    ,
             AcctTpRateDateTab(i)    ,
             AcctTpExchangeRateTab(i),
             AcctTransferPriceTab(i) ,
             ProjacctTransferPriceTab(i) ,
             CcMarkupBaseCodeTab(i)   ,
             TpBaseAmountTab(i)       ,
             TpIndCompiledSetIdTab(i) ,
             TpBillRateTab(i)         ,
             TpBillMarkupPercentageTab(i) ,
             TpSchLinePercentageTab(i),
             TpRulePercentageTab(i));

    pa_cc_utils.log_message('After Insert');

         Pa_Costing.CreateExternalCdl( X_expenditure_item_id         =>	EiIdTab(i)
                                     , X_ei_date                     =>	EiDateTab(i)
                                     , X_amount                      =>	RawCostTab(i)
                                     , X_dr_ccid                     =>	DrccidIdTab(i)
                                     , X_cr_ccid                     =>	CrccidIdTab(i)
                                     , X_transfer_status_code        =>	'V'
                                     , X_quantity                    =>	QtyTab(i)
                                     , X_billable_flag               =>	BillFlagTab(i)
                                     , X_request_id                  =>	x_request_id
                                     , X_program_application_id      =>	x_program_application_id
                                     , x_program_id                  =>	x_program_id
                                     , x_program_update_date         =>	sysdate
                                     , X_pa_date                     =>	NULL
                                     , X_gl_date                     =>	GldateTab(i)
                                                                     Trx_Import enhancement
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
                                     , X_err_stack                   =>	X_err_stack );
    pa_cc_utils.log_message('After Creation of CDL');

      END IF ;
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

null;
-- DLANKA
        Pa_Adjustments.CheckStatus( status_indicator => temp_status );

      END IF;

      IF ( X_calling_process = 'TRANSFER' ) THEN

        pa_adjustments.InsAuditRec( X_exp_item_id       =>	TfrEiTab(i)
                                  , X_adj_activity      =>	'TRANSFER ORIGINATING'
                                  , X_module            =>	X_module
                                  , X_user              =>	X_user
                                  , X_login             =>	X_login
                                  , X_status            =>	temp_status );
        Pa_Adjustments.CheckStatus( status_indicator => temp_status );

        pa_adjustments.InsAuditRec( X_exp_item_id       =>	EiIdTab(i)
                                  , X_adj_activity      =>	'TRANSFER DESTINATION'
                                  , X_module            =>	X_module
                                  , X_user              =>	X_user
                                  , X_login             =>	X_login
                                  , X_status            =>	temp_status );

        Pa_Adjustments.CheckStatus( status_indicator => temp_status );


        pa_adjustments.BackoutItem( X_exp_item_id      =>	TfrEiTab(i)
                                  , X_expenditure_id   =>	NULL
                                  , X_adj_activity     =>	'TRANSFER BACK-OUT'
                                  , X_module           =>	X_module
                                  , X_user             =>	X_user
                                  , X_login            =>	X_login
                                  , X_status           =>	temp_status );

        Pa_Adjustments.CheckStatus( status_indicator => temp_status );


           Project Summarization changes
           Call procedure to create CDL for the backout item (if necessary)


        Pa_Costing.CreateReverseCdl( X_exp_item_id => TfrEiTab(i),
                                     X_backout_id  => Pa_Adjustments.BackOutId,
                                     X_user        => X_user,
                                     X_status      => temp_status);

        Pa_Adjustments.CheckStatus( status_indicator => temp_status );

        pa_adjustments.ReverseRelatedItems( X_source_exp_item_id  =>	TfrEiTab(i)
                                          , X_expenditure_id      =>	NULL
                                          , X_module              =>	X_module
                                          , X_user                =>	X_user
                                          , X_login               =>	X_login
                                          , X_status              => temp_status );

        Pa_Adjustments.CheckStatus( status_indicator => temp_status );


      ELSIF ( X_calling_process = 'TRX_IMPORT' ) THEN
    pa_cc_utils.log_message('Trx Import call to InsItems');

        IF ( AdjEiTab(i) IS NOT NULL ) THEN

        pa_adjustments.InsAuditRec( X_exp_item_id       =>	AdjEiTab(i)
                                  , X_adj_activity      =>	'MANUAL BACK-OUT ORIGINATING'
                                  , X_module            =>	X_module
                                  , X_user              =>	X_user
                                  , X_login             =>	X_login
                                  , X_status            =>	temp_status );
    pa_cc_utils.log_message('After call to InsAuditRec');

        Pa_Adjustments.CheckStatus( status_indicator => temp_status );


        pa_adjustments.InsAuditRec( X_exp_item_id       =>	EiIdTab(i)
                                  , X_adj_activity      =>	'MANUAL BACK-OUT'
                                  , X_module            =>	X_module
                                  , X_user              =>	X_user
                                  , X_login             =>	X_login
                                  , X_status            =>	temp_status );

        Pa_Adjustments.CheckStatus( status_indicator => temp_status );

        pa_adjustments.SetNetZero( X_exp_item_id   =>	AdjEiTab(i)
                                 , X_user          =>	X_user
                                 , X_login         =>	X_login
                                 , X_status        =>	temp_status );
    pa_cc_utils.log_message('After call to SetNetZero');

        Pa_Adjustments.CheckStatus( status_indicator => temp_status );

        pa_adjustments.ReverseRelatedItems( X_source_exp_item_id  =>	AdjEiTab(i)
                                          , X_expenditure_id      =>	NULL
                                          , X_module              =>	X_module
                                          , X_user                =>	X_user
                                          , X_login               =>	X_login
                                          , X_status              => temp_status );
    pa_cc_utils.log_message('After call to ReverseRelatedItems');

        Pa_Adjustments.CheckStatus( status_indicator => temp_status );

      END IF;
    END IF;
    END LOOP;

    X_status := 0;
    pa_cc_utils.log_message('End ');
    pa_cc_utils.reset_curr_function ;

    EXCEPTION
      WHEN  OTHERS  THEN
        X_status := SQLCODE;
        RAISE;
*/
  END  InsItems;



-- ========================================================================
-- PROCEDURE
-- Added Multi-Currency Transactions columns Shree 08/06
-- ========================================================================

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
                      -- Trx_import enhancement: Adding new parameters
                      -- These values will be inserted into PA_EXPENDITURES_ALL table
                      , X_orig_exp_txn_reference1 IN VARCHAR2 DEFAULT NULL
                      , X_orig_user_exp_txn_reference IN VARCHAR2 DEFAULT NULL
                      , X_vendor_id           IN NUMBER DEFAULT NULL
                      , X_orig_exp_txn_reference2 IN VARCHAR2 DEFAULT NULL
                      , X_orig_exp_txn_reference3 IN VARCHAR2 DEFAULT NULL
                      )
  IS
  BEGIN
null;
/*
    pa_cc_utils.set_curr_function('InsertExp');
    pa_cc_utils.log_message('Start ');
    INSERT INTO gms_encumbrances(
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
      ,  orig_exp_txn_reference3)
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
      ,  X_orig_exp_txn_reference3);
    pa_cc_utils.log_message('End ');
    pa_cc_utils.reset_curr_function ;
*/
  END  InsertExp;


  PROCEDURE  InsertExpGroup(
                  X_expenditure_group      IN VARCHAR2
               ,  X_exp_group_status_code  IN VARCHAR2
               ,  X_ending_date            IN DATE
               ,  X_system_linkage         IN VARCHAR2
               ,  X_created_by             IN NUMBER
               ,  X_transaction_source     IN VARCHAR2 )
  IS
  BEGIN
/*
    pa_cc_utils.set_curr_function('InsertExpGroup');
    pa_cc_utils.log_message('Start ');

    INSERT INTO gms_encumbrance_groups(
                      expenditure_group
                   ,  expenditure_group_status_code
                   ,  expenditure_ending_date
                   ,  system_linkage_function
                   ,  last_update_date
                   ,  last_updated_by
                   ,  creation_date
                   ,  created_by
                   ,  transaction_source )
    VALUES (  X_expenditure_group
           ,  X_exp_group_status_code
           ,  X_ending_date
           ,  X_system_linkage
           ,  sysdate
           ,  X_created_by
           ,  sysdate
           ,  X_created_by
           ,  X_transaction_source );
    pa_cc_utils.log_message('End ');
    pa_cc_utils.reset_curr_function ;
*/
null;

  END  InsertExpGroup;


  PROCEDURE  CreateRelatedItem(
                  X_source_exp_item_id   IN NUMBER
               ,  X_project_id           IN NUMBER
               ,  X_task_id              IN NUMBER
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
               ,  X_outcome              OUT NOCOPY VARCHAR2 )
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
  BEGIN
null;
/*
    pa_cc_utils.set_curr_function('CreateRelatedItem');
    pa_cc_utils.log_message('Start ');

  -- Need to select new MC columns here to pass to LoadEi and PATC
    SELECT
            gms_encumbrance_items_s.nextval
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

      FROM
            gms_encumbrance_items ei
    ,       gms_encumbrances e
    ,       pa_tasks t
     WHERE
            e.expenditure_id = ei.expenditure_id
       AND  ei.expenditure_item_id = X_source_exp_item_id
       AND  ei.task_id = t.task_id;
    pa_cc_utils.log_message('In gms_transactions.CreateRelatedItem: After select statement');

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

    IF ( NOT pa_exp_copy.CheckExpTypeActive( X_expenditure_type
                                           , X_expenditure_item_date ) ) THEN

      X_outcome := 'EXP_TYPE_INACTIVE';
      X_status  := 1;
      pa_cc_utils.reset_curr_function ;
      RETURN;

    END IF;

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
   -- for Bug # 519532.Since, Billable flag is an OUT NOCOPY parameter and was getting
   -- populated in get_status, it was seen that a null was getting passed. Hence
   -- added the call to get_status again.
    pa_cc_utils.log_message('Before Call to PATC');

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
                     , X_billable_flag       => X_billable_flag );
    pa_cc_utils.log_message('After Call to PATC');

    IF (( temp_outcome IS NOT NULL) and
        ( temp_msg_type = 'E') ) THEN
      -- Since this is a batch program, we handle only errors,no warnings

       X_outcome := temp_outcome;
       X_status  := 1;
       pa_cc_utils.reset_curr_function ;
       RETURN;

    END IF;

-- Passed denom_raw_cost will be stored in array using LoadEi procedure
-- All other new currency attributes (introduced in Multi-Currency Transactions)
-- will be set to NULL.
-- Costing program will calculate appropriate values for accounting and
-- project currency columns

-- Fix for Bug # 813758
-- Need to pass denom acct and proj currency as well as project curr attributes
-- since for the related item this should be the same as the parent



      IC related change
      Send the Recvr_Org_Id to LOADEI using the new API defined
      in PA_UTILS2

    pa_cc_utils.log_message('Before Call to LoadEi');

    gms_transactions.LoadEi( X_expenditure_item_id     =>	X_expenditure_item_id
                           ,X_expenditure_id          =>	X_expenditure_id
                           ,X_expenditure_item_date   =>	X_expenditure_item_date
                           ,X_project_id              =>	NULL
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
                           ,X_Recv_Operating_Unit    => PA_UTILS2.GetPrjOrgId(X_dest_proj_id,
                                                                               X_dest_task_id) ) ;
    pa_cc_utils.log_message('After call to LoadEi');

    gms_transactions.InsItems( X_user              =>	X_userid
                            , X_login             =>	0
                            , X_module            =>	'CreateRelatedItem'
                            , X_calling_process   =>	'RELATED_ITEM'
                            , Rows                =>	1
                            , X_status            => 	temp_status
                            , X_gl_flag           =>	'N'     );
    pa_cc_utils.log_message('After call to InsItems');

    gms_transactions.FlushEiTabs;

    X_status  := 0;
    X_outcome := NULL;
    pa_cc_utils.log_message('End ');
    pa_cc_utils.reset_curr_function ;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      X_status := -1403;
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;
*/
  END  CreateRelatedItem;


-- Modified the parameter name from raw_cost to denom_raw_cost as well as
-- raw_cost_rate as denom_raw_cost_rate
-- Note : In this phase (11.1), cost_rates will be defined in accounting
--        currency (i.e. currency code of set of books in which costing
--        will be done)
  PROCEDURE  UpdateRelatedItem( X_expenditure_item_id  IN NUMBER
                              , X_denom_raw_cost             IN NUMBER
                              , X_denom_raw_cost_rate        IN NUMBER
                              , X_status               OUT NOCOPY NUMBER )
  IS
  BEGIN
null;
/*
    pa_cc_utils.set_curr_function('UpdateRelatedItem');
    pa_cc_utils.log_message('Start ');

    UPDATE  gms_encumbrance_items ei
       SET
            ei.denom_raw_cost = pa_currency.round_trans_currency_amt(X_denom_raw_cost,
                                                             ei.denom_currency_code)
    ,       ei.raw_cost_rate = X_denom_raw_cost_rate
     WHERE
            ei.expenditure_item_id = X_expenditure_item_id;

    X_status := 0;
    pa_cc_utils.log_message('End ');
    pa_cc_utils.reset_curr_function ;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      X_status := -1403;
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;
*/

  END  UpdateRelatedItem;

END GMS_TRANSACTIONS;

/
