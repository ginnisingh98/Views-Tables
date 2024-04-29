--------------------------------------------------------
--  DDL for Package OKL_CREATE_STREAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREATE_STREAMS_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKLRCSMS.pls 120.11.12010000.5 2009/08/10 14:37:36 rgooty ship $ */
------------------------------------------------------------------------------
 -- Global Variables
  G_EXC_NAME_ERROR  CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_RET_STS_SUCCESS  CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR  CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_EXCEPTION_HALT_PROCESSING   EXCEPTION;
  G_EXCEPTION_ERROR   EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR  EXCEPTION;
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CREATE_STREAMS_PVT';
 G_OKC_APP              CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_NO_DATA_FOUND        CONSTANT VARCHAR2(200) := 'OKL_NOT_FOUND';
 G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
 G_INVALID_VALUE CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
 G_COL_NAME_TOKEN CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 G_OKL_CSM_PENDING         CONSTANT VARCHAR2(15) := 'OKL_CSM_PENDING';
 G_OKL_MULTIPLE_TARGET_VALUES CONSTANT VARCHAR2(26) := 'OKL_MULTIPLE_TARGET_VALUES';
 G_SIS_HDR_INSERTED       CONSTANT VARCHAR2(20) := 'HDR_INSERTED';
 G_SIS_DATA_ENTERED       CONSTANT VARCHAR2(20) := 'DATA_ENTERED';
 G_SIS_PROCESS_COMPLETE   CONSTANT VARCHAR2(20) := 'PROCESS_COMPLETE';
 G_SIS_PROCESSING_FAILED  CONSTANT VARCHAR2(20) := 'PROCESSING_FAILED';
 G_SIS_PROCESSING_REQUEST CONSTANT VARCHAR2(20) := 'PROCESSING_REQUEST';
 G_SIS_PROCESS_ABORTED    CONSTANT VARCHAR2(20) := 'PROCESS_ABORTED';
 G_SIS_SERVER_NA          CONSTANT VARCHAR2(20) := 'SERVER_NA';
 G_SIS_TIME_OUT           CONSTANT VARCHAR2(20) := 'TIME_OUT';
 G_SIS_PROCESS_COMPLETE_ERRORS CONSTANT VARCHAR2(30) := 'PROCESS_COMPLETE_ERRORS';
 G_SIS_RET_DATA_RECEIVED  CONSTANT VARCHAR2(30) := 'RET_DATA_RECEIVED';
 G_CURRENT_STREAM         CONSTANT VARCHAR2(10) := 'CURR';
 G_SFE_TYPE_ONE_OFF       CONSTANT VARCHAR2(30) :=  OKL_SFE_PVT.G_SFE_TYPE_ONE_OFF;
 G_SFE_TYPE_PERIODIC_EXPENSE CONSTANT VARCHAR2(30) :=  OKL_SFE_PVT.G_SFE_TYPE_PERIODIC_EXPENSE;
 G_SFE_TYPE_RENT          CONSTANT VARCHAR2(30) :=  OKL_SFE_PVT.G_SFE_TYPE_RENT;
 G_SFE_TYPE_PERIODIC_INCOME CONSTANT VARCHAR2(30) :=  OKL_SFE_PVT.G_SFE_TYPE_PERIODIC_INCOME;
 G_SFE_TYPE_LOAN CONSTANT VARCHAR2(30) :=  OKL_SFE_PVT.G_SFE_TYPE_LOAN;
 --smahapat for fee type soln
 G_SFE_TYPE_SECURITY_DEPOSIT CONSTANT VARCHAR2(30) := OKL_SFE_PVT.G_SFE_TYPE_SECURITY_DEPOSIT;
 ---SGORANTL ADDED FOR SUBSIDY
 G_SFE_TYPE_SUBSIDY CONSTANT VARCHAR2(30) := OKL_SFE_PVT.G_SFE_TYPE_SUBSIDY;
 G_SIL_TYPE_LEASE CONSTANT VARCHAR2(10) :=  Okl_Sil_Pvt.G_SIL_TYPE_LEASE;
 G_SIL_TYPE_LOAN CONSTANT VARCHAR2(10) :=  Okl_Sil_Pvt.G_SIL_TYPE_LOAN;
  -- mvasudev , sno changes
 G_SIY_TYPE_YIELD           CONSTANT VARCHAR2(3) := OKL_SIY_PVT.G_SIY_TYPE_YIELD;
 G_SIY_TYPE_INTEREST_RATE   CONSTANT VARCHAR2(3) := OKL_SIY_PVT.G_SIY_TYPE_INTEREST_RATE;
 G_EXPENSE  CONSTANT VARCHAR2(10) := 'EXPENSE';
 G_INCOME  CONSTANT VARCHAR2(10) := 'INCOME';
 G_ADVANCE  CONSTANT VARCHAR2(10) := 'ADVANCE';
 G_ARREARS  CONSTANT VARCHAR2(10) := 'ARREARS';
 G_FND_YES  CONSTANT VARCHAR2(1)  := 'Y';
 G_FND_NO  CONSTANT VARCHAR2(1)  := 'N';
 G_CSM_TRUE  CONSTANT VARCHAR2(10) := 'true';
 G_CSM_FALSE  CONSTANT VARCHAR2(10) := 'false';
 G_TRUE          CONSTANT VARCHAR2(1) := OKL_API.G_TRUE;
 G_FALSE  CONSTANT VARCHAR2(1) := OKL_API.G_FALSE;
 G_ORP_CODE_BOOKING        CONSTANT VARCHAR2(4) := 'AUTH';
 G_ORP_CODE_RESTRUCTURE_AM CONSTANT VARCHAR2(4) := 'RSAM';
 G_ORP_CODE_RESTRUCTURE_CS CONSTANT VARCHAR2(4) := 'RSCS';
 G_ORP_CODE_UPGRADE        CONSTANT VARCHAR2(10) := 'UPGRADE';
  -- mvasudev , sno, changed "QUOT" to "QUOTE"
 G_ORP_CODE_QUOTE          CONSTANT VARCHAR2(4) := 'QUOT';
 G_ORP_CODE_VARIABLE_INTEREST        CONSTANT VARCHAR2(4) := 'VIRP';
 G_ORP_CODE_RENEWAL        CONSTANT VARCHAR2(4) := 'RENW';
 -- 04/26/2002 -- mvasudev
 /*
 -- Commenting in favor of referring to OKL_INVOKE_PRICING_ENGINE_PVT directly
 G_XMLG_TRX_TYPE              CONSTANT VARCHAR2(30)  := OKL_INVOKE_PRICING_ENGINE_PVT.G_XMLG_TRX_TYPE;
 G_XMLG_TRX_SUBTYPE_LEASE_BOOK  CONSTANT VARCHAR2(30)  := OKL_INVOKE_PRICING_ENGINE_PVT.G_XMLG_TRX_SUBTYPE_LEASE_BOOK;
 G_XMLG_TRX_SUBTYPE_LOAN_BOOK   CONSTANT VARCHAR2(30)  := OKL_INVOKE_PRICING_ENGINE_PVT.G_XMLG_TRX_SUBTYPE_LOAN_BOOK;
 G_XMLG_TRX_SUBTYPE_LEASE_RESTR CONSTANT VARCHAR2(30)  := OKL_INVOKE_PRICING_ENGINE_PVT.G_XMLG_TRX_SUBTYPE_LEASE_RESTR;
 G_XMLG_TRX_SUBTYPE_LOAN_RESTR  CONSTANT VARCHAR2(30)  := OKL_INVOKE_PRICING_ENGINE_PVT.G_XMLG_TRX_SUBTYPE_LOAN_RESTR;
 */
 -- end,04/26/2002 -- mvasudev
 G_LOCK_AMOUNT  CONSTANT VARCHAR2(10) := 'AMOUNT';
 G_LOCK_RATE         CONSTANT VARCHAR2(10) := 'RATE';
 G_LOCK_BOTH         CONSTANT VARCHAR2(10) := 'BOTH';
 G_MODE_LESSOR  CONSTANT VARCHAR2(10) := 'LESSOR';
 G_MODE_LENDER  CONSTANT VARCHAR2(10) := 'LENDER';
 G_MODE_BOTH        CONSTANT VARCHAR2(10) := 'BOTH';
 G_SFE_LEVEL_PAYMENT CONSTANT VARCHAR2(7) :=  'PAYMENT';
 G_SFE_LEVEL_INTEREST CONSTANT VARCHAR2(8) := 'INTEREST';
 G_SFE_LEVEL_PRINCIPAL CONSTANT VARCHAR2(9) := 'PRINCIPAL';
 G_SFE_LEVEL_FUNDING CONSTANT VARCHAR2(7) := 'FUNDING';
 -- added akjain 07/26
 G_ADJUST            CONSTANT VARCHAR2(10) := 'Rent';
 -- changed smahapat bug 4170057
 G_ADJUST_LOAN            CONSTANT VARCHAR2(30) := 'Loan: payments => rates';
 G_ADJUSTMENT_METHOD CONSTANT VARCHAR2(20) := 'Proportional';
 G_AK_REGION_NAME    CONSTANT VARCHAR2(40) := 'OKL_LP_CREATE_STREAMS';
 -- smahapat multi-gaap 11/10/02 addition
 G_PURPOSE_CODE_REPORT CONSTANT VARCHAR2(10) := 'REPORT';
 ------------------------------------------------------------------------------
 --kthiruva VR build
  G_BALANCE_RATE              CONSTANT VARCHAR2(20) := 'BALANCE_RATE';
  G_BALANCE_PAYMENT           CONSTANT VARCHAR2(20) := 'BALANCE_PAYMENT';
  G_BALANCE_TERM              CONSTANT VARCHAR2(20) := 'BALANCE_TERM';
  G_BALANCE_FUNDING           CONSTANT VARCHAR2(20) := 'BALANCE_FUNDING';
  G_PAYDOWN_TYPE_PPD           CONSTANT VARCHAR2(20) := 'PPD';
  G_PAYDOWN_TYPE_LPD           CONSTANT VARCHAR2(20) := 'LPD';

--gboomina added for Bug 4659724
  G_OKL_INT_PRIC_RESTR_NA CONSTANT VARCHAR2(30) := 'OKL_INT_PRICING_RESTR_QUOTE_NA' ;

 SUBTYPE sifv_rec_type IS Okl_Stream_Interfaces_Pub.sifv_rec_type;
 SUBTYPE sifv_tbl_type IS Okl_Stream_Interfaces_Pub.sifv_tbl_type;
 SUBTYPE silv_rec_type IS Okl_Sif_Lines_Pub.silv_rec_type;
 SUBTYPE silv_tbl_type IS Okl_Sif_Lines_Pub.silv_tbl_type;
 SUBTYPE sfev_rec_type IS Okl_Sif_Fees_Pub.sfev_rec_type;
 SUBTYPE sfev_tbl_type IS Okl_Sif_Fees_Pub.sfev_tbl_type;
 SUBTYPE siyv_rec_type IS Okl_Sif_Yields_Pub.siyv_rec_type;
 SUBTYPE siyv_tbl_type IS Okl_Sif_Yields_Pub.siyv_tbl_type;
 SUBTYPE sitv_rec_type IS Okl_Sif_Stream_Types_Pub.sitv_rec_type;
 SUBTYPE sitv_tbl_type IS Okl_Sif_Stream_Types_Pub.sitv_tbl_type;
 /* ONE OFF FEES */
 /*
 -- One-off Fees (Single or Multiple ) can occur both at Header as well as Line Levels
 -- In the abscence of "KLE_ID" it is assumed to be in the Header
 -- else it will be assigned to the corresponding KLE_ID / Line
 */
 TYPE csm_one_off_fee_rec_type IS RECORD(
     description           OKL_SIF_FEES_V.description%TYPE := OKC_API.G_MISS_CHAR
    ,income_or_expense     OKL_SIF_FEES_V.income_or_expense%TYPE := OKC_API.G_MISS_CHAR
    ,amount                NUMBER := OKC_API.G_MISS_NUM
    ,date_start            OKL_SIF_FEES_V.date_paid%TYPE := OKC_API.G_MISS_DATE --smahapat fee type solution
    ,date_paid             OKL_SIF_FEES_V.date_paid%TYPE := OKC_API.G_MISS_DATE
    ,idc_accounting_flag   OKL_SIF_FEES_V.idc_accounting_flag%TYPE := OKC_API.G_MISS_CHAR
    ,advance_or_arrears    OKL_SIF_FEES_V.advance_or_arrears%TYPE := OKC_API.G_MISS_CHAR
    ,kle_fee_id            NUMBER := OKC_API.G_MISS_NUM
    ,fee_type              OKL_K_LINES_v.fee_type%TYPE := OKC_API.G_MISS_CHAR --SGORANTL ADDED FOR FINANCE FEES
     -- Use ONLY in case this fees is for a Specific Line (Asset Line / Loan Line)
    ,kle_asset_id          NUMBER := OKC_API.G_MISS_NUM
    ,other_type_id         NUMBER := OKC_API.G_MISS_NUM --SGORANTL ADDED FOR subsidy
    ,other_type            OKL_K_LINES_v.fee_type%TYPE := OKC_API.G_MISS_CHAR --SGORANTL ADDED FOR subsidy
    ,rate                  NUMBER := OKC_API.G_MISS_NUM
	-- add reference to the external ID
	,orig_contract_line_id NUMBER := OKC_API.G_MISS_NUM
 );

 TYPE csm_one_off_fee_tbl_type IS TABLE OF csm_one_off_fee_rec_type
        INDEX BY BINARY_INTEGER;
 /* PERIODIC FEES  */
 /*
 -- Periodic Fees (Always Multiple) can occur both at Header as well as Line Levels
 -- In the abscence of "KLE_ID" it is assumed to be in the Header
 -- else it will be assigned to the corresponding KLE_ID / Line
 */
 TYPE csm_periodic_expenses_rec_type IS RECORD(
       -- Common Details
        description             OKL_SIF_FEES_V.description%TYPE := OKC_API.G_MISS_CHAR
       ,date_start              OKL_SIF_FEES_V.date_start%TYPE := OKC_API.G_MISS_DATE --smahapat fee type soln interpreted as en accrual for stub payment
       ,kle_fee_id              NUMBER := OKC_API.G_MISS_NUM
       -- Use ONLY in case this fees is for a Specific Line (Asset Line / Loan Line)
       ,kle_asset_id            NUMBER := OKC_API.G_MISS_NUM
       -- Per-Record Details
       ,level_index_number      NUMBER := OKC_API.G_MISS_NUM
       ,level_type              OKL_SIF_FEES_V.level_type%TYPE := OKC_API.G_MISS_CHAR
       ,number_of_periods       NUMBER := OKC_API.G_MISS_NUM
       ,amount                  NUMBER := OKC_API.G_MISS_NUM
       ,rate                    NUMBER := OKC_API.G_MISS_NUM
       ,lock_level_step         OKL_SIF_FEES_V.lock_level_step%TYPE := OKC_API.G_MISS_CHAR
       ,period                  OKL_SIF_FEES_V.period%TYPE := OKC_API.G_MISS_CHAR
       ,advance_or_arrears      OKL_SIF_FEES_V.advance_or_arrears%TYPE := OKC_API.G_MISS_CHAR
       ,income_or_expense       OKL_SIF_FEES_V.income_or_expense%TYPE := OKC_API.G_MISS_CHAR
       ,fee_type                OKL_K_LINES_v.fee_type%TYPE := OKC_API.G_MISS_CHAR --SGORANTL ADDED FOR FINANCE FEES
       -- 04/29/2002, mvasudev
       -- added for "Restructure" requirements
       ,query_level_yn          OKL_SIF_FEES_V.query_level_yn%TYPE := OKC_API.G_MISS_CHAR
        -- 06/13/2002
       ,structure               OKL_SIF_FEES_V.structure%TYPE := OKC_API.G_MISS_CHAR
       ,cash_effect_yn          OKL_SIF_FEES_V.cash_effect_yn%TYPE := OKC_API.G_MISS_CHAR
       ,tax_effect_yn           OKL_SIF_FEES_V.tax_effect_yn%TYPE := OKC_API.G_MISS_CHAR
       ,days_in_month           OKL_SIF_FEES_V.days_in_month%TYPE :=OKC_API.G_MISS_CHAR
       ,days_in_year            OKL_SIF_FEES_V.days_in_year%TYPE    :=OKC_API.G_MISS_CHAR
       ,down_payment_amount     NUMBER := OKC_API.G_MISS_NUM
       ,date_paid               OKL_SIF_FEES_V.DATE_PAID%TYPE := OKC_API.G_MISS_DATE -- RGOOTY: Bug 7552496
	   -- add reference to the external ID
	   ,orig_contract_line_id   NUMBER := OKC_API.G_MISS_NUM
 );
 TYPE csm_periodic_expenses_tbl_type IS TABLE OF csm_periodic_expenses_rec_type
        INDEX BY BINARY_INTEGER;
 /* Stream Types*/
 TYPE csm_yields_rec_type IS RECORD(
    yield_name                     OKL_SIF_YIELDS_V.YIELD_NAME%TYPE := OKC_API.G_MISS_CHAR,
    method                         OKL_SIF_YIELDS_V.METHOD%TYPE := OKC_API.G_MISS_CHAR,
    array_type                     OKL_SIF_YIELDS_V.ARRAY_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    roe_type                       OKL_SIF_YIELDS_V.ROE_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    roe_base                       OKL_SIF_YIELDS_V.ROE_BASE%TYPE := OKC_API.G_MISS_CHAR,
    compounded_method              OKL_SIF_YIELDS_V.COMPOUNDED_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    target_value                   NUMBER := OKC_API.G_MISS_NUM,
    nominal_yn                     OKL_SIF_YIELDS_V.NOMINAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    -- 04/29/2002, mvasudev
    -- added for "Restructure" requirements
    pre_tax_yn                     OKL_SIF_YIELDS_V.PRE_TAX_YN%TYPE := OKC_API.G_MISS_CHAR,
    -- 06/24/2002, mvasudev
    -- added for "sno" requirements
    siy_type                       OKL_SIF_YIELDS_V.SIY_TYPE%TYPE := OKC_API.G_MISS_CHAR
 );
 TYPE csm_yields_tbl_type IS TABLE OF csm_yields_rec_type
        INDEX BY BINARY_INTEGER;
 /* Stream Types*/
 TYPE csm_stream_types_rec_type IS RECORD(
        stream_type_id           NUMBER := OKC_API.G_MISS_NUM
       ,kle_asset_id             NUMBER := OKC_API.G_MISS_NUM
       ,kle_fee_id               NUMBER := OKC_API.G_MISS_NUM
    ,pricing_name OKL_SIF_STREAM_TYPES_V.PRICING_NAME%type := OKC_API.G_MISS_CHAR
 );
 TYPE csm_stream_types_tbl_type IS TABLE OF csm_stream_types_rec_type
        INDEX BY BINARY_INTEGER;
 /* -- "Lease" Specific Definitions -- */
 /* Line Level Details Record */
 TYPE csm_line_details_rec_type IS RECORD(
       kle_asset_id                     NUMBER := OKC_API.G_MISS_NUM
       ,state_depre_dmnshing_value_rt   NUMBER := OKC_API.G_MISS_NUM
       ,book_depre_dmnshing_value_rt    NUMBER := OKC_API.G_MISS_NUM
       ,residual_guarantee_method       OKL_SIF_LINES_V.residual_guarantee_method%TYPE := OKC_API.G_MISS_CHAR
       ,fed_depre_term                  NUMBER := OKC_API.G_MISS_NUM
       ,fed_depre_dmnshing_value_rate   NUMBER := OKC_API.G_MISS_NUM
       ,fed_depre_adr_conve             OKL_SIF_LINES_V.fed_depre_adr_conve%TYPE := OKC_API.G_MISS_CHAR
       ,state_depre_basis_percent       NUMBER := OKC_API.G_MISS_NUM
       ,state_depre_method              OKL_SIF_LINES_V.state_depre_method%TYPE := OKC_API.G_MISS_CHAR
       ,purchase_option                 OKL_SIF_LINES_V.purchase_option%TYPE := OKC_API.G_MISS_CHAR
       ,purchase_option_amount          NUMBER := OKC_API.G_MISS_NUM
       ,asset_cost                      NUMBER := OKC_API.G_MISS_NUM
       ,state_depre_term                NUMBER := OKC_API.G_MISS_NUM
       ,state_depre_adr_convent         OKL_SIF_LINES_V.state_depre_adr_convent%TYPE := OKC_API.G_MISS_CHAR
       ,fed_depre_method                OKL_SIF_LINES_V.fed_depre_method%TYPE := OKC_API.G_MISS_CHAR
       ,residual_amount                 NUMBER := OKC_API.G_MISS_NUM
       ,residual_date                   OKL_SIF_LINES_V.residual_date%TYPE := OKC_API.G_MISS_DATE
       ,fed_depre_salvage               NUMBER := OKC_API.G_MISS_NUM
       ,date_fed_depre                  OKL_SIF_LINES_V.date_fed_depre%TYPE := OKC_API.G_MISS_DATE
       ,book_salvage                    NUMBER := OKC_API.G_MISS_NUM
       ,book_adr_convention             OKL_SIF_LINES_V.book_adr_convention%TYPE := OKC_API.G_MISS_CHAR
       ,state_depre_salvage             NUMBER := OKC_API.G_MISS_NUM
       ,fed_depre_basis_percent         NUMBER := OKC_API.G_MISS_NUM
       ,book_basis_percent              NUMBER := OKC_API.G_MISS_NUM
       ,date_delivery                   OKL_SIF_LINES_V.date_delivery%TYPE := OKC_API.G_MISS_DATE
       ,book_term                       NUMBER := OKC_API.G_MISS_NUM
       ,residual_guarantee_amount       NUMBER := OKC_API.G_MISS_NUM
       ,date_funding                    OKL_SIF_LINES_V.date_funding%TYPE := OKC_API.G_MISS_DATE
       ,date_book                       OKL_SIF_LINES_V.date_book%TYPE := OKC_API.G_MISS_DATE
       ,date_state_depre                OKL_SIF_LINES_V.date_state_depre%TYPE := OKC_API.G_MISS_DATE
       ,book_method                     OKL_SIF_LINES_V.book_method%TYPE := OKC_API.G_MISS_CHAR
       ,description                     OKL_SIF_LINES_V.description%TYPE := OKC_API.G_MISS_CHAR
       -- stream_interface_attribute01 => guarantee_type
       ,guarantee_type                  OKL_SIF_LINES_V.residual_guarantee_type%TYPE
       ,down_payment_amount             NUMBER := OKC_API.G_MISS_NUM
       ,capitalize_down_payment_yn      OKL_SIF_LINES_V.capitalize_down_payment_yn%TYPE := OKC_API.G_MISS_CHAR
	   -- add reference to the external ID
	   ,orig_contract_line_id           NUMBER := OKC_API.G_MISS_NUM
 );
 TYPE csm_line_details_tbl_type IS TABLE OF csm_line_details_rec_type
        INDEX BY BINARY_INTEGER;
 /* Lease Type - Header */
 TYPE csm_lease_rec_type IS RECORD(
     -- Common Details
        jtot_object1_code        OKL_STREAM_INTERFACES_V.jtot_object1_code%TYPE := OKC_API.G_MISS_CHAR
       ,object1_id1              OKL_STREAM_INTERFACES_V.object1_id1%TYPE := OKC_API.G_MISS_CHAR
       ,khr_id                   NUMBER := OKC_API.G_MISS_NUM
       ,pdt_id                   NUMBER := OKC_API.G_MISS_NUM
       ,sif_mode                 OKL_STREAM_INTERFACES_V.sif_mode%TYPE DEFAULT 'Lessor'
       ,country                  OKL_STREAM_INTERFACES_V.country%TYPE := OKC_API.G_MISS_CHAR
       ,orp_code                 OKL_STREAM_INTERFACES_V.orp_code%TYPE := OKC_API.G_MISS_CHAR
       ,date_payments_commencement OKL_STREAM_INTERFACES_V.date_payments_commencement%TYPE := OKC_API.G_MISS_DATE
       ,security_deposit_amount  NUMBER := OKC_API.G_MISS_NUM
       ,date_sec_deposit_collected OKL_STREAM_INTERFACES_V.date_sec_deposit_collected%TYPE := OKC_API.G_MISS_DATE
       ,fasb_acct_treatment_method OKL_STREAM_INTERFACES_V.fasb_acct_treatment_method%TYPE := OKC_API.G_MISS_CHAR
       ,adjust                     OKL_STREAM_INTERFACES_V.adjust%TYPE
       ,adjustment_method          OKL_STREAM_INTERFACES_V.adjustment_method%TYPE
       ,term                       NUMBER := OKC_API.G_MISS_NUM
       ,structure                  OKL_STREAM_INTERFACES_V.structure%TYPE := OKC_API.G_MISS_CHAR
       -- Lease Type Details
       ,irs_tax_treatment_method   OKL_STREAM_INTERFACES_V.irs_tax_treatment_method%TYPE := OKC_API.G_MISS_CHAR
       ,date_delivery              OKL_STREAM_INTERFACES_V.date_delivery%TYPE := OKC_API.G_MISS_DATE
       ,implicit_interest_rate     NUMBER DEFAULT NULL
       ,rvi_yn                     OKL_STREAM_INTERFACES_V.rvi_yn%TYPE := OKC_API.G_MISS_CHAR
       ,rvi_rate                   NUMBER := OKC_API.G_MISS_NUM
    -- mvasudev, Bug#2650599
       ,sif_id                     NUMBER := OKC_API.G_MISS_NUM
       ,purpose_code               OKL_STREAM_INTERFACES_V.PURPOSE_CODE%TYPE := OKC_API.G_MISS_CHAR
    -- end, mvasudev, Bug#2650599
 );
 -- 04/21/2002
 /* Loan Lines */
 TYPE csm_loan_line_rec_type IS RECORD(
 	    kle_loan_id        NUMBER := OKC_API.G_MISS_NUM
       --Added by kthiruva on 15-Nov-2005 for the Down Payment CR
       --Bug 4738011 - Start of Changes
       ,down_payment_amount             NUMBER := OKC_API.G_MISS_NUM
       ,capitalize_down_payment_yn      OKL_SIF_LINES_V.capitalize_down_payment_yn%TYPE := OKC_API.G_MISS_CHAR
       ,orig_contract_line_id           NUMBER := OKC_API.G_MISS_NUM
       --Bug 4738011 - End of Changes
 );
 TYPE csm_loan_line_tbl_type IS TABLE OF csm_loan_line_rec_type
        INDEX BY BINARY_INTEGER;
 /* Loan Levels */
 TYPE csm_loan_level_rec_type IS RECORD(
       -- Common Details
        description               OKL_SIF_FEES_V.description%TYPE := OKC_API.G_MISS_CHAR
       ,date_start                OKL_SIF_FEES_V.date_start%TYPE := OKC_API.G_MISS_DATE
       ,kle_loan_id               NUMBER := OKC_API.G_MISS_NUM
       -- Per-Record Details
       ,level_index_number        NUMBER := OKC_API.G_MISS_NUM
       ,level_type                OKL_SIF_FEES_V.level_type%TYPE := OKC_API.G_MISS_CHAR
       ,number_of_periods         NUMBER := OKC_API.G_MISS_NUM
       ,amount                    NUMBER := OKC_API.G_MISS_NUM
       ,lock_level_step           OKL_SIF_FEES_V.lock_level_step%TYPE := OKC_API.G_MISS_CHAR
       ,rate                      NUMBER := OKC_API.G_MISS_NUM
       ,period                    OKL_SIF_FEES_V.period%TYPE := OKC_API.G_MISS_CHAR
       ,advance_or_arrears        OKL_SIF_FEES_V.advance_or_arrears%TYPE := OKC_API.G_MISS_CHAR
       ,income_or_expense         OKL_SIF_FEES_V.income_or_expense%TYPE := OKC_API.G_MISS_CHAR
        -- 06/13/2002
       ,structure                 OKL_SIF_FEES_V.structure%TYPE := OKC_API.G_MISS_CHAR
       -- added for "Restructure" requirements akjain 08/20/02
       ,query_level_yn            OKL_SIF_FEES_V.query_level_yn%TYPE := OKC_API.G_MISS_CHAR
       ,days_in_month             OKL_SIF_FEES_V.days_in_month%TYPE :=OKC_API.G_MISS_CHAR
       ,days_in_year              OKL_SIF_FEES_V.days_in_year%TYPE    :=OKC_API.G_MISS_CHAR
       ,balance_type_code         OKL_SIF_FEES_V.balance_type_code%TYPE     :=OKC_API.G_MISS_CHAR
       ,payment_type              VARCHAR2(30)  :=OKC_API.G_MISS_CHAR
	   -- add reference to external id
	   ,orig_contract_line_id     NUMBER := OKC_API.G_MISS_NUM
 );
 TYPE csm_loan_level_tbl_type IS TABLE OF csm_loan_level_rec_type
        INDEX BY BINARY_INTEGER;
 -- end,04/21/2002
 /* Loan Type - Header */
 TYPE csm_loan_rec_type IS RECORD(
  -- Common Details
        jtot_object1_code          OKL_STREAM_INTERFACES_V.jtot_object1_code%TYPE := OKC_API.G_MISS_CHAR
       ,object1_id1                OKL_STREAM_INTERFACES_V.object1_id1%TYPE := OKC_API.G_MISS_CHAR
       ,khr_id                     NUMBER := OKC_API.G_MISS_NUM
       ,pdt_id                     NUMBER := OKC_API.G_MISS_NUM
       ,sif_mode                   OKL_STREAM_INTERFACES_V.sif_mode%TYPE DEFAULT 'Lender'
       ,country                    OKL_STREAM_INTERFACES_V.country%TYPE := OKC_API.G_MISS_CHAR
       ,orp_code                   OKL_STREAM_INTERFACES_V.orp_code%TYPE := OKC_API.G_MISS_CHAR
       ,date_payments_commencement OKL_STREAM_INTERFACES_V.date_payments_commencement%TYPE := OKC_API.G_MISS_DATE
       ,security_deposit_amount    NUMBER := OKC_API.G_MISS_NUM
       ,date_sec_deposit_collected OKL_STREAM_INTERFACES_V.date_sec_deposit_collected%TYPE := OKC_API.G_MISS_DATE
        -- Loan Type Details
       ,total_lending              NUMBER := OKC_API.G_MISS_NUM
       ,date_start                 OKL_STREAM_INTERFACES_V.date_sec_deposit_collected%TYPE := OKC_API.G_MISS_DATE
       ,lending_rate               NUMBER DEFAULT NULL
       -- mvasudev, Bug#2650599
       ,sif_id                     NUMBER := OKC_API.G_MISS_NUM
       ,purpose_code               OKL_STREAM_INTERFACES_V.PURPOSE_CODE%TYPE := OKC_API.G_MISS_CHAR
       -- end, mvasudev, Bug#2650599
       -- added for Loan Quote requirements smahapat 10/30/03
       ,adjust                     OKL_STREAM_INTERFACES_V.adjust%TYPE
       ,adjustment_method          OKL_STREAM_INTERFACES_V.adjustment_method%TYPE
 );
 /* For Fees and Asset Index */
TYPE index_rec_type IS RECORD
 (
    id NUMBER,
    idx NUMBER
 );
 TYPE index_tbl_type IS TABLE OF index_rec_type INDEX BY BINARY_INTEGER;
 g_asset_ids index_tbl_type;
 /* For Perioidic Expenses Index */
TYPE periodic_index_rec_type IS RECORD
 (
    description                   VARCHAR2(1995),
    idx                           NUMBER
 );
 TYPE periodic_index_tbl_type IS TABLE OF periodic_index_rec_type INDEX BY BINARY_INTEGER;
 g_periodic_expenses_indexes  periodic_index_tbl_type;
 g_periodic_incomes_indexes   periodic_index_tbl_type;
 g_rents_indexes              periodic_index_tbl_type;
 g_siy_names periodic_index_tbl_type;
 /* For Cross-Referencing SFE IDs with corresponding KLE Fee IDs*/
TYPE sfe_id_rec_type IS RECORD
 (
    kle_fee_id NUMBER,
    sfe_id     NUMBER,
 stream_type_id NUMBER  -- smahapat added for fee type solution
 );
 TYPE sfe_id_tbl_type IS TABLE OF sfe_id_rec_type INDEX BY BINARY_INTEGER;
 g_sfe_ids   sfe_id_tbl_type;
 /* For Cross-Referencing SIL IDs with corresponding KLE Asset IDs*/
 TYPE sil_id_rec_type IS RECORD
 (
    kle_asset_id NUMBER,
    sil_id       NUMBER
 );
 TYPE sil_id_tbl_type IS TABLE OF sil_id_rec_type INDEX BY BINARY_INTEGER;
 g_sil_ids   sil_id_tbl_type;
  -- Procedure to Create Streams for Lease Type Contract
  PROCEDURE Create_Streams_Lease_Book (
        p_api_version               IN  NUMBER
       ,p_init_msg_list             IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine           IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_lease_header          IN  csm_lease_rec_type
       ,p_csm_one_off_fee_tbl       IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl            IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl      IN  csm_stream_types_tbl_type
       ,p_csm_line_details_tbl      IN  csm_line_details_tbl_type
       ,p_rents_tbl                 IN  csm_periodic_expenses_tbl_type
       ,x_trans_id                  OUT NOCOPY NUMBER
       ,x_trans_status              OUT NOCOPY VARCHAR2
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
       );
  -- Procedure to Create Streams for Loan Type Contract
  PROCEDURE Create_Streams_Loan_Book (
        p_api_version               IN  NUMBER
       ,p_init_msg_list             IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine           IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_loan_header           IN  csm_loan_rec_type
        -- 04/21/2002
       ,p_csm_loan_lines_tbl        IN  csm_loan_line_tbl_type
       ,p_csm_loan_levels_tbl       IN  csm_loan_level_tbl_type
       ,p_csm_one_off_fee_tbl       IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl IN  csm_periodic_expenses_tbl_type
       -- end, 04/21/2002
       ,p_csm_yields_tbl            IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl      IN  csm_stream_types_tbl_type
       ,x_trans_id                  OUT NOCOPY NUMBER
       ,x_trans_status              OUT NOCOPY VARCHAR2
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2

 );
   PROCEDURE Invoke_Pricing_Engine(
        p_api_version                    IN  NUMBER
       ,p_init_msg_list                  IN  VARCHAR2 DEFAULT G_FALSE
       ,p_sifv_rec                       IN  sifv_rec_type
       ,x_sifv_rec                       OUT NOCOPY  sifv_rec_type
       ,x_return_status                  OUT NOCOPY VARCHAR2
       ,x_msg_count                      OUT NOCOPY NUMBER
       ,x_msg_data                       OUT NOCOPY VARCHAR2
   );

  -- 04/30/2002
  -- Procedure to Create Streams for Lease Type Contract - Restructure
  PROCEDURE Create_Streams_Lease_Restr (
        p_api_version                    IN  NUMBER
       ,p_init_msg_list                  IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine                IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_lease_header               IN  csm_lease_rec_type
       ,p_csm_one_off_fee_tbl            IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl      IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl                 IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl           IN  csm_stream_types_tbl_type
       ,p_csm_line_details_tbl           IN  csm_line_details_tbl_type
       ,p_rents_tbl                      IN  csm_periodic_expenses_tbl_type
       ,x_trans_id                       OUT NOCOPY NUMBER
       ,x_trans_status                   OUT NOCOPY VARCHAR2
       ,x_return_status                  OUT NOCOPY VARCHAR2
       ,x_msg_count                      OUT NOCOPY NUMBER
       ,x_msg_data                       OUT NOCOPY VARCHAR2
       );
  -- Procedure to Create Streams for Loan Type Contract

  PROCEDURE Create_Streams_Loan_Restr (
        p_api_version                    IN  NUMBER
       ,p_init_msg_list                  IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine                IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_loan_header                IN  csm_loan_rec_type
       ,p_csm_loan_lines_tbl             IN  csm_loan_line_tbl_type
       ,p_csm_loan_levels_tbl            IN  csm_loan_level_tbl_type
       ,p_csm_one_off_fee_tbl            IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl      IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl                 IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl           IN  csm_stream_types_tbl_type
       ,x_trans_id                       OUT NOCOPY NUMBER
       ,x_trans_status                   OUT NOCOPY VARCHAR2
       ,x_return_status                  OUT NOCOPY VARCHAR2
       ,x_msg_count                      OUT NOCOPY NUMBER
       ,x_msg_data                       OUT NOCOPY VARCHAR2
 );
  -- end, 04/30/2002
  -- Procedure to Create Streams for Quote
  PROCEDURE Create_Streams_Lease_Quote (
        p_api_version                    IN  NUMBER
       ,p_init_msg_list                  IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine                IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_lease_header               IN  csm_lease_rec_type
       ,p_csm_one_off_fee_tbl            IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl      IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl                 IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl           IN  csm_stream_types_tbl_type
       ,p_csm_line_details_tbl           IN  csm_line_details_tbl_type
       ,p_rents_tbl                      IN  csm_periodic_expenses_tbl_type
       ,x_trans_id                       OUT NOCOPY NUMBER
       ,x_trans_status                   OUT NOCOPY VARCHAR2
       ,x_return_status                  OUT NOCOPY VARCHAR2
       ,x_msg_count                      OUT NOCOPY NUMBER
       ,x_msg_data                       OUT NOCOPY VARCHAR2
   );

--kthiruva VR build
 PROCEDURE add_balance_information(x_sfev_tbl        IN OUT NOCOPY sfev_tbl_type,
                                   x_return_status   OUT NOCOPY VARCHAR2);

END Okl_Create_Streams_Pvt;

/
