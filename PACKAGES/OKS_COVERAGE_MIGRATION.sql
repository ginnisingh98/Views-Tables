--------------------------------------------------------
--  DDL for Package OKS_COVERAGE_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_COVERAGE_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: OKSCOVMS.pls 120.0 2005/05/25 18:30:50 appldev noship $ */




G_APP_NAME_OKS	   CONSTANT VARCHAR2(3)   := 'OKS';
G_APP_NAME               VARCHAR2(200);
G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';

x_ctzv_tbl_in               oks_ctz_pvt.OksCoverageTimezonesVTblType;
l_ctzv_tbl_in               oks_ctz_pvt.OksCoverageTimezonesVTblType;

x_cvtv_tbl_in               OKS_CVT_PVT.oks_coverage_times_v_tbl_type;
l_cvtv_tbl_in               OKS_CVT_PVT.oks_coverage_times_v_tbl_type;


x_acmv_tbl_in               OKS_ACM_PVT.oks_action_times_v_tbl_type;
l_acmv_tbl_in               OKS_ACM_PVT.oks_action_times_v_tbl_type;

l_ctz_rec   NUMBER :=0;
l_cvt_rec   NUMBER :=0;
l_act_ctr   NUMBER :=0;
l_acm_ctr   NUMBER :=0;

G_PKG_NAME  VARCHAR2(200):= 'OKS_COVERAGE_MIGRATION';


PROCEDURE Coverage_migration( p_start_rowid IN ROWID,p_end_rowid IN ROWID,x_return_status OUT NOCOPY VARCHAR2,x_message_data  OUT NOCOPY VARCHAR2); -- Migrate the Coverage Header From Rules Architecture To New Architecture.

PROCEDURE BILL_TYPES_MIGRATION( p_start_rowid IN ROWID,p_end_rowid IN ROWID,x_return_status OUT NOCOPY VARCHAR2,x_message_data OUT NOCOPY VARCHAR2); --Migrate the Billing Types  From Rules Architecture To New Architecture.

PROCEDURE Business_Process_migration(p_start_rowid IN ROWID,p_end_rowid IN ROWID,x_return_status OUT NOCOPY VARCHAR2,x_message_data  OUT NOCOPY VARCHAR2); -- Migrate the Business Process  From Rules Architecture To New Architecture.

PROCEDURE COVERAGE_TIMES_MIGRATION ( p_start_rowid IN ROWID,p_end_rowid IN ROWID,x_return_status OUT NOCOPY VARCHAR2,x_message_data  OUT NOCOPY VARCHAR2); -- Migrate the Coverage Times From Rules Architecture To New Architecture.

PROCEDURE Reaction_Time_migration( p_start_rowid IN ROWID,p_end_rowid IN ROWID,x_return_status OUT NOCOPY VARCHAR2,x_message_data  OUT NOCOPY VARCHAR2); -- Migrate the Reaction Times  From Rules Architecture To New Architecture.

PROCEDURE Reaction_TimeValues_Migration ( x_return_status OUT NOCOPY VARCHAR2,x_message_data  OUT NOCOPY VARCHAR2);
-- Migrate the reaction Time Values  From Rules Architecture To New Architecture.

/*****************************           HISTORY            ***************************************/
In_ID           OKC_DATATYPES.NumberTabTyp;
In_MAJOR_VERSION           OKC_DATATYPES.NumberTabTyp;
In_CLE_ID           OKC_DATATYPES.NumberTabTyp;
In_DNZ_CHR_ID           OKC_DATATYPES.NumberTabTyp;
In_DISCOUNT_LIST           OKC_DATATYPES.NumberTabTyp;
In_ACCT_RULE_ID           OKC_DATATYPES.NumberTabTyp;
In_PAYMENT_TYPE           OKC_DATATYPES.VAR30TabTyp;
In_CC_NO           OKC_DATATYPES.VAR120TabTyp;
In_CC_EXPIRY_DATE           OKC_DATATYPES.DateTabTyp;
In_CC_BANK_ACCT_ID           OKC_DATATYPES.NumberTabTyp;
In_CC_AUTH_CODE           OKC_DATATYPES.VAR150TabTyp;
In_LOCKED_PRICE_LIST_ID           OKC_DATATYPES.NumberTabTyp;
In_USAGE_EST_YN           OKC_DATATYPES.VAR3TabTyp;
In_USAGE_EST_METHOD           OKC_DATATYPES.VAR30TabTyp;
In_USAGE_EST_START_DATE           OKC_DATATYPES.DateTabTyp;
In_TERMN_METHOD           OKC_DATATYPES.VAR30TabTyp;
In_UBT_AMOUNT           OKC_DATATYPES.NumberTabTyp;
In_CREDIT_AMOUNT           OKC_DATATYPES.NumberTabTyp;
In_SUPPRESSED_CREDIT           OKC_DATATYPES.NumberTabTyp;
In_OVERRIDE_AMOUNT           OKC_DATATYPES.NumberTabTyp;
In_CUST_PO_NUMBER_REQ_YN           OKC_DATATYPES.VAR3TabTyp;
In_CUST_PO_NUMBER           OKC_DATATYPES.VAR150TabTyp;
In_GRACE_DURATION           OKC_DATATYPES.NumberTabTyp;
In_GRACE_PERIOD           OKC_DATATYPES.VAR30TabTyp;
In_INV_PRINT_FLAG           OKC_DATATYPES.VAR3TabTyp;
In_PRICE_UOM           OKC_DATATYPES.VAR30TabTyp;
In_TAX_AMOUNT           OKC_DATATYPES.NumberTabTyp;
In_TAX_INCLUSIVE_YN           OKC_DATATYPES.VAR3TabTyp;
In_TAX_STATUS           OKC_DATATYPES.VAR30TabTyp;
In_TAX_CODE           OKC_DATATYPES.NumberTabTyp;
In_TAX_EXEMPTION_ID           OKC_DATATYPES.NumberTabTyp;
In_IB_TRANS_TYPE           OKC_DATATYPES.VAR10TabTyp;
In_IB_TRANS_DATE           OKC_DATATYPES.DateTabTyp;
In_PROD_PRICE           OKC_DATATYPES.NumberTabTyp;
In_SERVICE_PRICE           OKC_DATATYPES.NumberTabTyp;
In_CLVL_LIST_PRICE           OKC_DATATYPES.NumberTabTyp;
In_CLVL_QUANTITY           OKC_DATATYPES.NumberTabTyp;
In_CLVL_EXTENDED_AMT           OKC_DATATYPES.NumberTabTyp;
In_CLVL_UOM_CODE           OKC_DATATYPES.VAR3TabTyp;
In_TOPLVL_OPERAND_CODE           OKC_DATATYPES.VAR30TabTyp;
In_TOPLVL_OPERAND_VAL           OKC_DATATYPES.NumberTabTyp;
In_TOPLVL_QUANTITY           OKC_DATATYPES.NumberTabTyp;
In_TOPLVL_UOM_CODE           OKC_DATATYPES.VAR3TabTyp;
In_TOPLVL_ADJ_PRICE           OKC_DATATYPES.NumberTabTyp;
In_TOPLVL_PRICE_QTY           OKC_DATATYPES.NumberTabTyp;
In_AVERAGING_INTERVAL           OKC_DATATYPES.NumberTabTyp;
In_SETTLEMENT_INTERVAL           OKC_DATATYPES.VAR30TabTyp;
In_MINIMUM_QUANTITY           OKC_DATATYPES.NumberTabTyp;
In_DEFAULT_QUANTITY           OKC_DATATYPES.NumberTabTyp;
In_AMCV_FLAG           OKC_DATATYPES.VAR3TabTyp;
In_FIXED_QUANTITY           OKC_DATATYPES.NumberTabTyp;
In_USAGE_DURATION           OKC_DATATYPES.NumberTabTyp;
In_USAGE_PERIOD           OKC_DATATYPES.VAR3TabTyp;
In_LEVEL_YN           OKC_DATATYPES.VAR3TabTyp;
In_USAGE_TYPE           OKC_DATATYPES.VAR10TabTyp;
In_UOM_QUANTIFIED           OKC_DATATYPES.VAR3TabTyp;
In_BASE_READING           OKC_DATATYPES.NumberTabTyp;
In_BILLING_SCHEDULE_TYPE           OKC_DATATYPES.VAR10TabTyp;
In_COVERAGE_TYPE           OKC_DATATYPES.VAR3TabTyp;
In_EXCEPTION_COV_ID           OKC_DATATYPES.NumberTabTyp;
In_LIMIT_UOM_QUANTIFIED           OKC_DATATYPES.VAR3TabTyp;
In_DISCOUNT_AMOUNT           OKC_DATATYPES.NumberTabTyp;
In_DISCOUNT_PERCENT           OKC_DATATYPES.NumberTabTyp;
In_OFFSET_DURATION           OKC_DATATYPES.NumberTabTyp;
In_OFFSET_PERIOD           OKC_DATATYPES.VAR3TabTyp;
In_INCIDENT_SEVERITY_ID           OKC_DATATYPES.NumberTabTyp;
In_PDF_ID           OKC_DATATYPES.NumberTabTyp;
In_WORK_THRU_YN           OKC_DATATYPES.VAR3TabTyp;
In_REACT_ACTIVE_YN           OKC_DATATYPES.VAR3TabTyp;
In_TRANSFER_OPTION           OKC_DATATYPES.VAR30TabTyp;
In_PROD_UPGRADE_YN           OKC_DATATYPES.VAR3TabTyp;
In_INHERITANCE_TYPE           OKC_DATATYPES.VAR30TabTyp;
In_PM_PROGRAM_ID           OKC_DATATYPES.NumberTabTyp;
In_PM_CONF_REQ_YN           OKC_DATATYPES.VAR3TabTyp;
In_PM_SCH_EXISTS_YN           OKC_DATATYPES.VAR3TabTyp;
In_ALLOW_BT_DISCOUNT           OKC_DATATYPES.VAR3TabTyp;
In_APPLY_DEFAULT_TIMEZONE           OKC_DATATYPES.VAR3TabTyp;
In_SYNC_DATE_INSTALL           OKC_DATATYPES.VAR3TabTyp;
In_OBJECT_VERSION_NUMBER           OKC_DATATYPES.NumberTabTyp;
In_SECURITY_GROUP_ID           OKC_DATATYPES.NumberTabTyp;
In_REQUEST_ID           OKC_DATATYPES.NumberTabTyp;
In_CREATED_BY           OKC_DATATYPES.NumberTabTyp;
In_CREATION_DATE           OKC_DATATYPES.DateTabTyp;
In_LAST_UPDATED_BY           OKC_DATATYPES.NumberTabTyp;
In_LAST_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
In_LAST_UPDATE_LOGIN           OKC_DATATYPES.NumberTabTyp;
In_COMMITMENT_ID           OKC_DATATYPES.NumberTabTyp;
In_FULL_CREDIT           OKC_DATATYPES.VAR3TabTyp;

IN_ACTION_TYPE_CODE     OKC_DATATYPES.VAR30TabTyp;
IN_PROGRAM_APPLICATION_ID  OKC_DATATYPES.NumberTabTyp;
IN_PROGRAM_ID OKC_DATATYPES.NumberTabTyp;
IN_PROGRAM_UPDATE_DATE OKC_DATATYPES.DateTabTyp;
IN_COV_ACTION_TYPE_ID   OKC_DATATYPES.NumberTabTyp;
IN_UOM_CODE OKC_DATATYPES.VAR3TabTyp;
IN_SUN_DURATION OKC_DATATYPES.NumberTabTyp;
IN_MON_DURATION OKC_DATATYPES.NumberTabTyp;
IN_TUE_DURATION OKC_DATATYPES.NumberTabTyp;
IN_WED_DURATION OKC_DATATYPES.NumberTabTyp;
IN_THU_DURATION OKC_DATATYPES.NumberTabTyp;
IN_FRI_DURATION OKC_DATATYPES.NumberTabTyp;
IN_SAT_DURATION OKC_DATATYPES.NumberTabTyp;
IN_DEFAULT_YN       OKC_DATATYPES.VAR3TabTyp;
IN_TIMEZONE_ID OKC_DATATYPES.NumberTabTyp;
/*****************************************************/
TLn_ID                  OKC_DATATYPES.NumberTabTyp;
tln_major_version       OKC_DATATYPES.NumberTabTyp;
tln_language            OKC_DATATYPES.VAR30TabTyp;
tln_source_lang         OKC_DATATYPES.VAR30TabTyp;
tln_sfwt_flag           OKC_DATATYPES.VAR30TabTyp;
tln_invoice_text     OKC_DATATYPES.VAR1995TabTyp;
tln_CREATED_BY           OKC_DATATYPES.NumberTabTyp;
tln_CREATION_DATE           OKC_DATATYPES.DateTabTyp;
tln_LAST_UPDATED_BY           OKC_DATATYPES.NumberTabTyp;
tln_LAST_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
tln_LAST_UPDATE_LOGIN           OKC_DATATYPES.NumberTabTyp;

    I           NUMBER;
    J           NUMBER;
    K           NUMBER;
    l_tabsize   NUMBER;
    l_tabsize2  NUMBER;

  TYPE OksCoverageTimezonesVRecType IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,default_yn                     OKS_COVERAGE_TIMEZONES_V.DEFAULT_YN%TYPE := OKC_API.G_MISS_CHAR
    ,timezone_id                    NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,security_group_id              NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKS_COVERAGE_TIMEZONES_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_COVERAGE_TIMEZONES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_COVERAGE_TIMEZONES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,Major_Version                  NUMBER := OKC_API.G_MISS_NUM);

  GMissOksCoverageTimezonesVRec           OksCoverageTimezonesVRecType;
  TYPE OksCoverageTimezonesVTblType IS TABLE OF OksCoverageTimezonesVRecType
        INDEX BY BINARY_INTEGER;
h_ctzv_tbl_in               OksCoverageTimezonesVTblType;
i_ctzv_tbl_in               OksCoverageTimezonesVTblType;



  TYPE oks_action_times_v_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cov_action_type_id             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,uom_code                       OKS_ACTION_TIMES_V.UOM_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,sun_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,mon_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,tue_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,wed_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,thu_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,fri_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,sat_duration                   NUMBER := OKC_API.G_MISS_NUM
    ,security_group_id              NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKS_ACTION_TIMES_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_ACTION_TIMES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_ACTION_TIMES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,major_version                  NUMBER := OKC_API.G_MISS_NUM);

  TYPE oks_action_times_v_tbl_type IS TABLE OF oks_action_times_v_rec_type         INDEX BY BINARY_INTEGER;

h_acmv_tbl_in               oks_action_times_v_tbl_type;
i_acmv_tbl_in               oks_action_times_v_tbl_type;



  TYPE klnv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,discount_list                  NUMBER := OKC_API.G_MISS_NUM
    ,acct_rule_id                   NUMBER := OKC_API.G_MISS_NUM
    ,payment_type                   OKS_K_LINES_V.PAYMENT_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,cc_no                          OKS_K_LINES_V.CC_NO%TYPE := OKC_API.G_MISS_CHAR
    ,cc_expiry_date                 OKS_K_LINES_V.CC_EXPIRY_DATE%TYPE := OKC_API.G_MISS_DATE
    ,cc_bank_acct_id                NUMBER := OKC_API.G_MISS_NUM
    ,cc_auth_code                   OKS_K_LINES_V.CC_AUTH_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,commitment_id                  NUMBER := OKC_API.G_MISS_NUM
    ,locked_price_list_id           NUMBER := OKC_API.G_MISS_NUM
    ,usage_est_yn                   OKS_K_LINES_V.USAGE_EST_YN%TYPE := OKC_API.G_MISS_CHAR
    ,usage_est_method               OKS_K_LINES_V.USAGE_EST_METHOD%TYPE := OKC_API.G_MISS_CHAR
    ,usage_est_start_date           OKS_K_LINES_V.USAGE_EST_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,termn_method                   OKS_K_LINES_V.TERMN_METHOD%TYPE := OKC_API.G_MISS_CHAR
    ,ubt_amount                     NUMBER := OKC_API.G_MISS_NUM
    ,credit_amount                  NUMBER := OKC_API.G_MISS_NUM
    ,suppressed_credit              NUMBER := OKC_API.G_MISS_NUM
    ,override_amount                NUMBER := OKC_API.G_MISS_NUM
    ,cust_po_number_req_yn          OKS_K_LINES_V.CUST_PO_NUMBER_REQ_YN%TYPE := OKC_API.G_MISS_CHAR
    ,cust_po_number                 OKS_K_LINES_V.CUST_PO_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,grace_duration                 NUMBER := OKC_API.G_MISS_NUM
    ,grace_period                   OKS_K_LINES_V.GRACE_PERIOD%TYPE := OKC_API.G_MISS_CHAR
    ,inv_print_flag                 OKS_K_LINES_V.INV_PRINT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,price_uom                      OKS_K_LINES_V.PRICE_UOM%TYPE := OKC_API.G_MISS_CHAR
    ,tax_amount                     NUMBER := OKC_API.G_MISS_NUM
    ,tax_inclusive_yn               OKS_K_LINES_V.TAX_INCLUSIVE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,tax_status                     OKS_K_LINES_V.TAX_STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,tax_code                       NUMBER := OKC_API.G_MISS_NUM
    ,tax_exemption_id               NUMBER := OKC_API.G_MISS_NUM
    ,ib_trans_type                  OKS_K_LINES_V.IB_TRANS_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,ib_trans_date                  OKS_K_LINES_V.IB_TRANS_DATE%TYPE := OKC_API.G_MISS_DATE
    ,prod_price                     NUMBER := OKC_API.G_MISS_NUM
    ,service_price                  NUMBER := OKC_API.G_MISS_NUM
    ,clvl_list_price                NUMBER := OKC_API.G_MISS_NUM
    ,clvl_quantity                  NUMBER := OKC_API.G_MISS_NUM
    ,clvl_extended_amt              NUMBER := OKC_API.G_MISS_NUM
    ,clvl_uom_code                  OKS_K_LINES_V.CLVL_UOM_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,toplvl_operand_code            OKS_K_LINES_V.TOPLVL_OPERAND_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,toplvl_operand_val             NUMBER := OKC_API.G_MISS_NUM
    ,toplvl_quantity                NUMBER := OKC_API.G_MISS_NUM
    ,toplvl_uom_code                OKS_K_LINES_V.TOPLVL_UOM_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,toplvl_adj_price               NUMBER := OKC_API.G_MISS_NUM
    ,toplvl_price_qty               NUMBER := OKC_API.G_MISS_NUM
    ,averaging_interval             NUMBER := OKC_API.G_MISS_NUM
    ,settlement_interval            OKS_K_LINES_V.SETTLEMENT_INTERVAL%TYPE := OKC_API.G_MISS_CHAR
    ,minimum_quantity               NUMBER := OKC_API.G_MISS_NUM
    ,default_quantity               NUMBER := OKC_API.G_MISS_NUM
    ,amcv_flag                      OKS_K_LINES_V.AMCV_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,fixed_quantity                 NUMBER := OKC_API.G_MISS_NUM
    ,usage_duration                 NUMBER := OKC_API.G_MISS_NUM
    ,usage_period                   OKS_K_LINES_V.USAGE_PERIOD%TYPE := OKC_API.G_MISS_CHAR
    ,level_yn                       OKS_K_LINES_V.LEVEL_YN%TYPE := OKC_API.G_MISS_CHAR
    ,usage_type                     OKS_K_LINES_V.USAGE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,uom_quantified                 OKS_K_LINES_V.UOM_QUANTIFIED%TYPE := OKC_API.G_MISS_CHAR
    ,base_reading                   NUMBER := OKC_API.G_MISS_NUM
    ,billing_schedule_type          OKS_K_LINES_V.BILLING_SCHEDULE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,full_credit                    OKS_K_LINES_V.FULL_CREDIT%TYPE := OKC_API.G_MISS_CHAR
    ,locked_price_list_line_id      NUMBER := OKC_API.G_MISS_NUM
    ,break_uom                      OKS_K_LINES_V.BREAK_UOM%TYPE := OKC_API.G_MISS_CHAR
    ,prorate                        OKS_K_LINES_V.PRORATE%TYPE := OKC_API.G_MISS_CHAR
    ,coverage_type                  OKS_K_LINES_V.COVERAGE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,exception_cov_id               NUMBER := OKC_API.G_MISS_NUM
    ,limit_uom_quantified           OKS_K_LINES_V.LIMIT_UOM_QUANTIFIED%TYPE := OKC_API.G_MISS_CHAR
    ,discount_amount                NUMBER := OKC_API.G_MISS_NUM
    ,discount_percent               NUMBER := OKC_API.G_MISS_NUM
    ,offset_duration                NUMBER := OKC_API.G_MISS_NUM
    ,offset_period                  OKS_K_LINES_V.OFFSET_PERIOD%TYPE := OKC_API.G_MISS_CHAR
    ,incident_severity_id           NUMBER := OKC_API.G_MISS_NUM
    ,pdf_id                         NUMBER := OKC_API.G_MISS_NUM
    ,work_thru_yn                   OKS_K_LINES_V.WORK_THRU_YN%TYPE := OKC_API.G_MISS_CHAR
    ,react_active_yn                OKS_K_LINES_V.REACT_ACTIVE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,transfer_option                OKS_K_LINES_V.TRANSFER_OPTION%TYPE := OKC_API.G_MISS_CHAR
    ,prod_upgrade_yn                OKS_K_LINES_V.PROD_UPGRADE_YN%TYPE := OKC_API.G_MISS_CHAR
    ,inheritance_type               OKS_K_LINES_V.INHERITANCE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,pm_program_id                  NUMBER := OKC_API.G_MISS_NUM
    ,pm_conf_req_yn                 OKS_K_LINES_V.PM_CONF_REQ_YN%TYPE := OKC_API.G_MISS_CHAR
    ,pm_sch_exists_yn               OKS_K_LINES_V.PM_SCH_EXISTS_YN%TYPE := OKC_API.G_MISS_CHAR
    ,allow_bt_discount              OKS_K_LINES_V.ALLOW_BT_DISCOUNT%TYPE := OKC_API.G_MISS_CHAR
    ,apply_default_timezone         OKS_K_LINES_V.APPLY_DEFAULT_TIMEZONE%TYPE := OKC_API.G_MISS_CHAR
    ,sync_date_install              OKS_K_LINES_V.SYNC_DATE_INSTALL%TYPE := OKC_API.G_MISS_CHAR
    ,sfwt_flag                      OKS_K_LINES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,invoice_text                   OKS_K_LINES_V.INVOICE_TEXT%TYPE := OKC_API.G_MISS_CHAR
    ,ib_trx_details                 OKS_K_LINES_V.IB_TRX_DETAILS%TYPE := OKC_API.G_MISS_CHAR
    ,status_text                    OKS_K_LINES_V.STATUS_TEXT%TYPE := OKC_API.G_MISS_CHAR
    ,react_time_name                OKS_K_LINES_V.REACT_TIME_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,security_group_id              NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_K_LINES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_K_LINES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,major_version                  NUMBER := OKC_API.G_MISS_NUM);

  TYPE klnv_tbl_type IS TABLE OF klnv_rec_type  INDEX BY BINARY_INTEGER;

h_clev_tbl_in             	klnv_tbl_type;
i_clev_tbl_in             	klnv_tbl_type;

TYPE klt_rec_type is RECORD
(
ID                  OKS_K_LINES_TLH.ID%TYPE,
MAJOR_VERSION       OKS_K_LINES_TLH.MAJOR_VERSION%TYPE,
LANGUAGE               OKS_K_LINES_TLH.LANGUAGE%TYPE,
SOURCE_LANG            OKS_K_LINES_TLH.SOURCE_LANG%TYPE,
SFWT_FLAG             OKS_K_LINES_TLH.SFWT_FLAG%TYPE,
INVOICE_TEXT          OKS_K_LINES_TLH.INVOICE_TEXT%TYPE,
IB_TRX_DETAILS        OKS_K_LINES_TLH.IB_TRX_DETAILS%TYPE,
STATUS_TEXT           OKS_K_LINES_TLH.STATUS_TEXT%TYPE,
REACT_TIME_NAME       OKS_K_LINES_TLH.REACT_TIME_NAME%TYPE,
SECURITY_GROUP_ID     OKS_K_LINES_TLH.SECURITY_GROUP_ID%TYPE,
CREATED_BY            OKS_K_LINES_TLH.CREATED_BY%TYPE,
CREATION_DATE         OKS_K_LINES_TLH.CREATION_DATE%TYPE,
LAST_UPDATED_BY       OKS_K_LINES_TLH.LAST_UPDATED_BY%TYPE,
LAST_UPDATE_DATE      OKS_K_LINES_TLH.LAST_UPDATE_DATE%TYPE,
LAST_UPDATE_LOGIN     OKS_K_LINES_TLH.LAST_UPDATE_LOGIN%TYPE);

TYPE klt_tbl_type IS TABLE OF klt_rec_type  INDEX BY BINARY_INTEGER;

x_clet_tbl_in             	klt_tbl_type;
l_clet_tbl_in             	klt_tbl_type;


  TYPE oks_coverage_times_v_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,cov_tze_line_id                NUMBER := OKC_API.G_MISS_NUM
    ,start_hour                     NUMBER := OKC_API.G_MISS_NUM
    ,start_minute                   NUMBER := OKC_API.G_MISS_NUM
    ,end_hour                       NUMBER := OKC_API.G_MISS_NUM
    ,end_minute                     NUMBER := OKC_API.G_MISS_NUM
    ,monday_yn                      VARCHAR2(3) := NULL--OKS_COVERAGE_TIMES_V.MONDAY_YN%TYPE := OKC_API.G_MISS_CHAR
    ,tuesday_yn                     VARCHAR2(3) := NULL--OKS_COVERAGE_TIMES_V.TUESDAY_YN%TYPE := OKC_API.G_MISS_CHAR
    ,wednesday_yn                   VARCHAR2(3) := NULL--OKS_COVERAGE_TIMES_V.WEDNESDAY_YN%TYPE := OKC_API.G_MISS_CHAR
    ,thursday_yn                    VARCHAR2(3) := NULL--OKS_COVERAGE_TIMES_V.THURSDAY_YN%TYPE := OKC_API.G_MISS_CHAR
    ,friday_yn                      VARCHAR2(3) := NULL--OKS_COVERAGE_TIMES_V.FRIDAY_YN%TYPE := OKC_API.G_MISS_CHAR
    ,saturday_yn                    VARCHAR2(3) := NULL--OKS_COVERAGE_TIMES_V.SATURDAY_YN%TYPE := OKC_API.G_MISS_CHAR
    ,sunday_yn                      VARCHAR2(3) := NULL--OKS_COVERAGE_TIMES_V.SUNDAY_YN%TYPE := OKC_API.G_MISS_CHAR
    ,security_group_id              NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKS_COVERAGE_TIMES_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_COVERAGE_TIMES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_COVERAGE_TIMES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,major_version                  NUMBER := OKC_API.G_MISS_NUM);

  TYPE oks_coverage_times_v_tbl_type IS TABLE OF oks_coverage_times_v_rec_type INDEX BY BINARY_INTEGER;

h_cvtv_tbl_in               oks_coverage_times_v_tbl_type;
i_cvtv_tbl_in               oks_coverage_times_v_tbl_type;

TYPE OksActionTimeTypesVRecType IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,action_type_code               OKS_ACTION_TIME_TYPES_V.ACTION_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,security_group_id              NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKS_ACTION_TIME_TYPES_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_ACTION_TIME_TYPES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_ACTION_TIME_TYPES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,major_version                  NUMBER := OKC_API.G_MISS_NUM);

  TYPE OksActionTimeTypesVTblType IS TABLE OF OksActionTimeTypesVRecType INDEX BY BINARY_INTEGER;

h_actv_tbl_in               OksActionTimeTypesVTblType;
i_actv_tbl_in               OksActionTimeTypesVTblType;


l_clt_ctr   NUMBER :=0;

 PROCEDURE COVERAGE_HISTORY_MIGRATION (   p_start_rowid   IN ROWID,
                                         p_end_rowid     IN ROWID,
                                         x_return_status OUT NOCOPY VARCHAR2,
                                            x_message_data  OUT NOCOPY VARCHAR2);
-- Migrate the History For Coverage Header From Rules Architecture To New Architecture.


PROCEDURE Buss_Proc_History_migration(   p_start_rowid   IN ROWID,
                                         p_end_rowid     IN ROWID,
                                         x_return_status OUT NOCOPY VARCHAR2,
                                         x_message_data  OUT NOCOPY VARCHAR2);

-- Migrate the History For Business Process  From Rules Architecture To New Architecture.

PROCEDURE COV_TIMES_History_MIGRATION(      p_start_rowid IN ROWID,
                                            p_end_rowid IN ROWID,
                                            x_return_status OUT NOCOPY VARCHAR2,
                                            x_message_data  OUT NOCOPY VARCHAR2);

-- Migrate the History For Coverage Times From Rules Architecture To New Architecture.

PROCEDURE Reaction_Time_Hist_migration(     p_start_rowid IN ROWID,
                                            p_end_rowid IN ROWID,
                                            x_return_status OUT NOCOPY VARCHAR2,
                                            x_message_data  OUT NOCOPY VARCHAR2);
-- Migrate the History For Reaction Times  From Rules Architecture To New Architecture.

PROCEDURE React_TimeVal_Hist_Migration(    x_return_status OUT NOCOPY VARCHAR2,
                                            x_message_data  OUT NOCOPY VARCHAR2);
-- Migrate the History For Reaction Time Values  From Rules Architecture To New Architecture.

PROCEDURE BILL_TYPE_HIST_MIGRATION( p_start_rowid   IN ROWID,
                                    p_end_rowid     IN ROWID,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_message_data  OUT NOCOPY VARCHAR2);


-- Migrate the History For Bill Types From Rules Architecture To New Architecture.

/******************************************HISTORY*************************************************************/

END OKS_COVERAGE_MIGRATION; -- Package Specification OKS_COVERAGE_MIGRATION


 

/
