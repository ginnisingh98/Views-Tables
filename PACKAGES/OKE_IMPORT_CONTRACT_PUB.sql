--------------------------------------------------------
--  DDL for Package OKE_IMPORT_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_IMPORT_CONTRACT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKEPIMPS.pls 120.2 2006/03/27 15:51:15 ifilimon noship $ */
/*#
 * This is the public interface to import project contracts.
 * @rep:metalink 234864.1 See OracleMetaLink bulletin 234864.1
 * @rep:scope public
 * @rep:product OKE
 * @rep:displayname Create Project Contract
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKE_CONTRACT
 */

G_PKG_NAME     CONSTANT VARCHAR2(200) := 'OKE_IMPORT_CONTRACT_PUB';
G_APP_NAME     CONSTANT VARCHAR2(200) := OKE_API.G_APP_NAME;



SUBTYPE del_rec_type IS OKE_CONTRACT_PUB.del_rec_type;


TYPE chr_rec_type IS RECORD(
  k_header_id		NUMBER := OKE_API.G_MISS_NUM,
  program_id 		NUMBER := OKE_API.G_MISS_NUM,
  project_id		NUMBER := OKE_API.G_MISS_NUM,
  boa_id		NUMBER := OKE_API.G_MISS_NUM,
  k_type_code		OKE_K_HEADERS.K_TYPE_CODE%TYPE   := OKE_API.G_MISS_CHAR,
  priority_code		OKE_K_HEADERS.PRIORITY_CODE%TYPE := OKE_API.G_MISS_CHAR,
  prime_k_alias 	OKE_K_HEADERS.PRIME_K_ALIAS%TYPE := OKE_API.G_MISS_CHAR,
  prime_k_number 	OKE_K_HEADERS.PRIME_K_NUMBER%TYPE := OKE_API.G_MISS_CHAR,
  authorize_date 	OKE_K_HEADERS.AUTHORIZE_DATE%TYPE := OKE_API.G_MISS_DATE,
  authorizing_reason 	OKE_K_HEADERS.AUTHORIZING_REASON%TYPE := OKE_API.G_MISS_CHAR,
  award_cancel_date 	OKE_K_HEADERS.AWARD_CANCEL_DATE%TYPE := OKE_API.G_MISS_DATE,
  award_date		OKE_K_HEADERS.AWARD_DATE%TYPE := OKE_API.G_MISS_DATE,
  date_definitized 	OKE_K_HEADERS.DATE_DEFINITIZED%TYPE := OKE_API.G_MISS_DATE,
  date_issued 		OKE_K_HEADERS.DATE_ISSUED%TYPE := OKE_API.G_MISS_DATE,
  date_negotiated 	OKE_K_HEADERS.DATE_NEGOTIATED%TYPE := OKE_API.G_MISS_DATE,
  date_received 	OKE_K_HEADERS.DATE_RECEIVED%TYPE := OKE_API.G_MISS_DATE,
  date_sign_by_contractor OKE_K_HEADERS.DATE_SIGN_BY_CONTRACTOR%TYPE := OKE_API.G_MISS_DATE,
  date_sign_by_customer OKE_K_HEADERS.DATE_SIGN_BY_CUSTOMER%TYPE := OKE_API.G_MISS_DATE,
  faa_approve_date 	OKE_K_HEADERS.FAA_APPROVE_DATE%TYPE := OKE_API.G_MISS_DATE,
  faa_reject_date 	OKE_K_HEADERS.FAA_REJECT_DATE%TYPE := OKE_API.G_MISS_DATE,
  booked_flag		OKE_K_HEADERS.BOOKED_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  open_flag		OKE_K_HEADERS.OPEN_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  cfe_flag		OKE_K_HEADERS.CFE_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  vat_code		OKE_K_HEADERS.VAT_CODE%TYPE := OKE_API.G_MISS_CHAR,
  country_of_origin_code OKE_K_HEADERS.COUNTRY_OF_ORIGIN_CODE%TYPE := OKE_API.G_MISS_CHAR,
  export_flag		OKE_K_HEADERS.EXPORT_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  human_subject_flag 	OKE_K_HEADERS.HUMAN_SUBJECT_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  cqa_flag		OKE_K_HEADERS.CQA_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  interim_rpt_req_flag 	OKE_K_HEADERS.INTERIM_RPT_REQ_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  no_competition_authorize OKE_K_HEADERS.NO_COMPETITION_AUTHORIZE%TYPE := OKE_API.G_MISS_CHAR,
  penalty_clause_flag 	OKE_K_HEADERS.PENALTY_CLAUSE_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  product_line_code 	OKE_K_HEADERS.PRODUCT_LINE_CODE%TYPE := OKE_API.G_MISS_CHAR,
  reporting_flag 	OKE_K_HEADERS.REPORTING_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  sb_plan_req_flag 	OKE_K_HEADERS.SB_PLAN_REQ_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  sb_report_flag 	OKE_K_HEADERS.SB_REPORT_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  nte_amount 		OKE_K_HEADERS.NTE_AMOUNT%TYPE := OKE_API.G_MISS_NUM,
  nte_warning_flag 	OKE_K_HEADERS.NTE_WARNING_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  bill_without_def_flag OKE_K_HEADERS.BILL_WITHOUT_DEF_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  cas_flag		OKE_K_HEADERS.CAS_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  classified_flag 	OKE_K_HEADERS.CLASSIFIED_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  client_approve_req_flag OKE_K_HEADERS.CLIENT_APPROVE_REQ_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  cost_of_money 	OKE_K_HEADERS.COST_OF_MONEY%TYPE := OKE_API.G_MISS_CHAR,
  dcaa_audit_req_flag 	OKE_K_HEADERS.DCAA_AUDIT_REQ_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  cost_share_flag 	OKE_K_HEADERS.COST_SHARE_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  oh_rates_final_flag 	OKE_K_HEADERS.OH_RATES_FINAL_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  prop_delivery_location 	OKE_K_HEADERS.PROP_DELIVERY_LOCATION%TYPE := OKE_API.G_MISS_CHAR,
  prop_due_date_time 	OKE_K_HEADERS.PROP_DUE_DATE_TIME%TYPE := OKE_API.G_MISS_DATE,
  prop_expire_date 	OKE_K_HEADERS.PROP_EXPIRE_DATE%TYPE := OKE_API.G_MISS_DATE,
  copies_required	OKE_K_HEADERS.COPIES_REQUIRED%TYPE := OKE_API.G_MISS_NUM,
  sic_code 		OKE_K_HEADERS.SIC_CODE%TYPE := OKE_API.G_MISS_CHAR,
  tech_data_wh_rate 	OKE_K_HEADERS.TECH_DATA_WH_RATE%TYPE := OKE_API.G_MISS_NUM,
  progress_payment_flag OKE_K_HEADERS.PROGRESS_PAYMENT_FLAG%TYPE :=OKE_API.G_MISS_CHAR,
  progress_payment_liq_rate NUMBER := OKE_API.G_MISS_NUM,
  progress_payment_rate NUMBER :=OKE_API.G_MISS_NUM,
  alternate_liquidation_rate NUMBER :=OKE_API.G_MISS_NUM,
  prop_due_time 	OKE_K_HEADERS.prop_due_time%TYPE :=OKE_API.G_MISS_CHAR,
  definitized_flag	OKE_K_HEADERS.DEFINITIZED_FLAG%TYPE :=OKE_API.G_MISS_CHAR,
  financial_ctrl_verified_flag OKE_K_HEADERS.FINANCIAL_CTRL_VERIFIED_FLAG%TYPE :=OKE_API.G_MISS_CHAR,
  cost_of_sale_rate	NUMBER :=OKE_API.G_MISS_NUM,
  line_value_total	NUMBER :=OKE_API.G_MISS_NUM,
  undef_line_value_total NUMBER:=OKE_API.G_MISS_NUM,
  owning_organization_id NUMBER := OKE_API.G_MISS_NUM,

--    this one is same as k_header_id
--    id                             NUMBER := OKE_API.G_MISS_NUM,

    object_version_number          NUMBER := OKE_API.G_MISS_NUM,
    sfwt_flag                      OKC_K_HEADERS_V.SFWT_FLAG%TYPE := OKE_API.G_MISS_CHAR,
    chr_id_response                NUMBER := OKE_API.G_MISS_NUM,
    chr_id_award                   NUMBER := OKE_API.G_MISS_NUM,
    chr_id_renewed                 NUMBER := OKE_API.G_MISS_NUM,
    INV_ORGANIZATION_ID            NUMBER := OKE_API.G_MISS_NUM,
    sts_code                       OKC_K_HEADERS_V.STS_CODE%TYPE := OKE_API.G_MISS_CHAR,
    qcl_id                         NUMBER := OKE_API.G_MISS_NUM,
    scs_code                       OKC_K_HEADERS_V.SCS_CODE%TYPE := OKE_API.G_MISS_CHAR,
    contract_number                OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE := OKE_API.G_MISS_CHAR,
    currency_code                  OKC_K_HEADERS_V.CURRENCY_CODE%TYPE := OKE_API.G_MISS_CHAR,
    contract_number_modifier       OKC_K_HEADERS_V.CONTRACT_NUMBER_MODIFIER%TYPE := OKE_API.G_MISS_CHAR,
    archived_yn                    OKC_K_HEADERS_V.ARCHIVED_YN%TYPE := OKE_API.G_MISS_CHAR,
    deleted_yn                     OKC_K_HEADERS_V.DELETED_YN%TYPE := OKE_API.G_MISS_CHAR,
    cust_po_number_req_yn          OKC_K_HEADERS_V.CUST_PO_NUMBER_REQ_YN%TYPE := OKE_API.G_MISS_CHAR,
    pre_pay_req_yn                 OKC_K_HEADERS_V.PRE_PAY_REQ_YN%TYPE := OKE_API.G_MISS_CHAR,
    cust_po_number                 OKC_K_HEADERS_V.CUST_PO_NUMBER%TYPE := OKE_API.G_MISS_CHAR,
    short_description              OKC_K_HEADERS_V.SHORT_DESCRIPTION%TYPE := OKE_API.G_MISS_CHAR,
    comments                       OKC_K_HEADERS_V.COMMENTS%TYPE := OKE_API.G_MISS_CHAR,
    description                    OKC_K_HEADERS_V.DESCRIPTION%TYPE := OKE_API.G_MISS_CHAR,
    dpas_rating                    OKC_K_HEADERS_V.DPAS_RATING%TYPE := OKE_API.G_MISS_CHAR,
    cognomen                       OKC_K_HEADERS_V.COGNOMEN%TYPE := OKE_API.G_MISS_CHAR,
    template_yn                    OKC_K_HEADERS_V.TEMPLATE_YN%TYPE := OKE_API.G_MISS_CHAR,
    template_used                  OKC_K_HEADERS_V.TEMPLATE_USED%TYPE := OKE_API.G_MISS_CHAR,
    date_approved                  OKC_K_HEADERS_V.DATE_APPROVED%TYPE := OKE_API.G_MISS_DATE,
    datetime_cancelled             OKC_K_HEADERS_V.DATETIME_CANCELLED%TYPE := OKE_API.G_MISS_DATE,
    auto_renew_days                NUMBER := OKE_API.G_MISS_NUM,
--    duplicated
--    date_issued                    OKC_K_HEADERS_V.DATE_ISSUED%TYPE := OKE_API.G_MISS_DATE,
    datetime_responded             OKC_K_HEADERS_V.DATETIME_RESPONDED%TYPE := OKE_API.G_MISS_DATE,
    non_response_reason            OKC_K_HEADERS_V.NON_RESPONSE_REASON%TYPE := OKE_API.G_MISS_CHAR,
    non_response_explain           OKC_K_HEADERS_V.NON_RESPONSE_EXPLAIN%TYPE := OKE_API.G_MISS_CHAR,
    rfp_type                       OKC_K_HEADERS_V.RFP_TYPE%TYPE := OKE_API.G_MISS_CHAR,
    chr_type                       OKC_K_HEADERS_V.CHR_TYPE%TYPE := OKE_API.G_MISS_CHAR,
    keep_on_mail_list              OKC_K_HEADERS_V.KEEP_ON_MAIL_LIST%TYPE := OKE_API.G_MISS_CHAR,
    set_aside_reason               OKC_K_HEADERS_V.SET_ASIDE_REASON%TYPE := OKE_API.G_MISS_CHAR,
    set_aside_percent              NUMBER := OKE_API.G_MISS_NUM,
    response_copies_req            NUMBER := OKE_API.G_MISS_NUM,
    date_close_projected           OKC_K_HEADERS_V.DATE_CLOSE_PROJECTED%TYPE := OKE_API.G_MISS_DATE,
    datetime_proposed              OKC_K_HEADERS_V.DATETIME_PROPOSED%TYPE := OKE_API.G_MISS_DATE,
    date_signed                    OKC_K_HEADERS_V.DATE_SIGNED%TYPE := OKE_API.G_MISS_DATE,
    date_terminated                OKC_K_HEADERS_V.DATE_TERMINATED%TYPE := OKE_API.G_MISS_DATE,
    date_renewed                   OKC_K_HEADERS_V.DATE_RENEWED%TYPE := OKE_API.G_MISS_DATE,
    trn_code                       OKC_K_HEADERS_V.TRN_CODE%TYPE := OKE_API.G_MISS_CHAR,
    start_date                     OKC_K_HEADERS_V.START_DATE%TYPE := OKE_API.G_MISS_DATE,
    end_date                       OKC_K_HEADERS_V.END_DATE%TYPE := OKE_API.G_MISS_DATE,
    authoring_org_id               NUMBER := OKE_API.G_MISS_NUM,
    buy_or_sell                    OKC_K_HEADERS_V.BUY_OR_SELL%TYPE := OKE_API.G_MISS_CHAR,
    issue_or_receive               OKC_K_HEADERS_V.ISSUE_OR_RECEIVE%TYPE := OKE_API.G_MISS_CHAR,
    estimated_amount		     NUMBER := OKE_API.G_MISS_NUM,
    chr_id_renewed_to		     NUMBER := OKE_API.G_MISS_NUM,
    estimated_amount_renewed       NUMBER := OKE_API.G_MISS_NUM,
    currency_code_renewed	     OKC_K_HEADERS_V.CURRENCY_CODE_RENEWED%TYPE := OKE_API.G_MISS_CHAR,
    upg_orig_system_ref            OKC_K_HEADERS_V.UPG_ORIG_SYSTEM_REF%TYPE := OKE_API.G_MISS_CHAR,
    upg_orig_system_ref_id         NUMBER := OKE_API.G_MISS_NUM,
    attribute_category             OKC_K_HEADERS_V.ATTRIBUTE_CATEGORY%TYPE := OKE_API.G_MISS_CHAR,
    attribute1                     OKC_K_HEADERS_V.ATTRIBUTE1%TYPE := OKE_API.G_MISS_CHAR,
    attribute2                     OKC_K_HEADERS_V.ATTRIBUTE2%TYPE := OKE_API.G_MISS_CHAR,
    attribute3                     OKC_K_HEADERS_V.ATTRIBUTE3%TYPE := OKE_API.G_MISS_CHAR,
    attribute4                     OKC_K_HEADERS_V.ATTRIBUTE4%TYPE := OKE_API.G_MISS_CHAR,
    attribute5                     OKC_K_HEADERS_V.ATTRIBUTE5%TYPE := OKE_API.G_MISS_CHAR,
    attribute6                     OKC_K_HEADERS_V.ATTRIBUTE6%TYPE := OKE_API.G_MISS_CHAR,
    attribute7                     OKC_K_HEADERS_V.ATTRIBUTE7%TYPE := OKE_API.G_MISS_CHAR,
    attribute8                     OKC_K_HEADERS_V.ATTRIBUTE8%TYPE := OKE_API.G_MISS_CHAR,
    attribute9                     OKC_K_HEADERS_V.ATTRIBUTE9%TYPE := OKE_API.G_MISS_CHAR,
    attribute10                    OKC_K_HEADERS_V.ATTRIBUTE10%TYPE := OKE_API.G_MISS_CHAR,
    attribute11                    OKC_K_HEADERS_V.ATTRIBUTE11%TYPE := OKE_API.G_MISS_CHAR,
    attribute12                    OKC_K_HEADERS_V.ATTRIBUTE12%TYPE := OKE_API.G_MISS_CHAR,
    attribute13                    OKC_K_HEADERS_V.ATTRIBUTE13%TYPE := OKE_API.G_MISS_CHAR,
    attribute14                    OKC_K_HEADERS_V.ATTRIBUTE14%TYPE := OKE_API.G_MISS_CHAR,
    attribute15                    OKC_K_HEADERS_V.ATTRIBUTE15%TYPE := OKE_API.G_MISS_CHAR,

    created_by                     NUMBER := OKE_API.G_MISS_NUM,
    creation_date                  OKC_K_HEADERS_V.CREATION_DATE%TYPE := OKE_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKE_API.G_MISS_NUM,
    last_update_date               OKC_K_HEADERS_V.LAST_UPDATE_DATE%TYPE := OKE_API.G_MISS_DATE,
    last_update_login              NUMBER := OKE_API.G_MISS_NUM

);


  TYPE cle_rec_type IS RECORD (

  k_line_id		NUMBER	:= OKE_API.G_MISS_NUM,
  parent_line_id	NUMBER  := OKE_API.G_MISS_NUM,
  project_id		NUMBER  := OKE_API.G_MISS_NUM,
  task_id		NUMBER  := OKE_API.G_MISS_NUM,
  billing_method_code	OKE_K_LINES.BILLING_METHOD_CODE%TYPE  := OKE_API.G_MISS_CHAR,
  inventory_item_id	NUMBER  := OKE_API.G_MISS_NUM,
  delivery_order_flag	VARCHAR2(1) := OKE_API.G_MISS_CHAR,
  splited_flag		VARCHAR2(1) := OKE_API.G_MISS_CHAR,
  priority_code		OKE_K_LINES.PRIORITY_CODE%TYPE := OKE_API.G_MISS_CHAR,
  customer_item_id	NUMBER  := OKE_API.G_MISS_NUM,
  customer_item_number  OKE_K_LINES.CUSTOMER_ITEM_NUMBER%TYPE  := OKE_API.G_MISS_CHAR,
  line_quantity		OKE_K_LINES.LINE_QUANTITY%TYPE := OKE_API.G_MISS_NUM,
  delivery_date		DATE	:= OKE_API.G_MISS_DATE,
  unit_price		OKE_K_LINES.UNIT_PRICE%TYPE    := OKE_API.G_MISS_NUM,
  uom_code		OKE_K_LINES.UOM_CODE%TYPE      := OKE_API.G_MISS_CHAR,
  billable_flag		OKE_K_LINES.BILLABLE_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  shippable_flag	OKE_K_LINES.SHIPPABLE_FLAG%TYPE  := OKE_API.G_MISS_CHAR,
  subcontracted_flag    OKE_K_LINES.SUBCONTRACTED_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  completed_flag	OKE_K_LINES.COMPLETED_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  nsp_flag		OKE_K_LINES.NSP_FLAG%TYPE      := OKE_API.G_MISS_CHAR,
  app_code		OKE_K_LINES.APP_CODE%TYPE      := OKE_API.G_MISS_CHAR,
  as_of_date		OKE_K_LINES.AS_OF_DATE%TYPE    := OKE_API.G_MISS_DATE,
  authority		OKE_K_LINES.AUTHORITY%TYPE := OKE_API.G_MISS_CHAR,
  country_of_origin_code OKE_K_LINES.COUNTRY_OF_ORIGIN_CODE%TYPE := OKE_API.G_MISS_CHAR,
  drop_shipped_flag	OKE_K_LINES.DROP_SHIPPED_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  customer_approval_req_flag  OKE_K_LINES.CUSTOMER_APPROVAL_REQ_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  date_material_req	OKE_K_LINES.DATE_MATERIAL_REQ%TYPE := OKE_API.G_MISS_DATE,
  inspection_req_flag	OKE_K_LINES.INSPECTION_REQ_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  interim_rpt_req_flag	OKE_K_LINES.INTERIM_RPT_REQ_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  subj_a133_flag	OKE_K_LINES.SUBJ_A133_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  export_flag		OKE_K_LINES.EXPORT_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  cfe_req_flag		OKE_K_LINES.CFE_REQ_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  cop_required_flag	OKE_K_LINES.COP_REQUIRED_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  export_license_num	OKE_K_LINES.EXPORT_LICENSE_NUM%TYPE := OKE_API.G_MISS_CHAR,
  export_license_res    OKE_K_LINES.EXPORT_LICENSE_RES%TYPE := OKE_API.G_MISS_CHAR,

  copies_required	OKE_K_LINES.COPIES_REQUIRED%TYPE := OKE_API.G_MISS_NUM,
  cdrl_category		OKE_K_LINES.CDRL_CATEGORY%TYPE := OKE_API.G_MISS_CHAR,
  data_item_name	OKE_K_LINES.DATA_ITEM_NAME%TYPE := OKE_API.G_MISS_CHAR,
  data_item_subtitle	OKE_K_LINES.DATA_ITEM_SUBTITLE%TYPE := OKE_API.G_MISS_CHAR,
  date_of_first_submission OKE_K_LINES.DATE_OF_FIRST_SUBMISSION%TYPE := OKE_API.G_MISS_DATE,
  frequency		OKE_K_LINES.FREQUENCY%TYPE := OKE_API.G_MISS_CHAR,
  requiring_office	OKE_K_LINES.REQUIRING_OFFICE%TYPE := OKE_API.G_MISS_CHAR,
  dcaa_audit_req_flag	OKE_K_LINES.DCAA_AUDIT_REQ_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  definitized_flag	OKE_K_LINES.DEFINITIZED_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  cost_of_money		OKE_K_LINES.COST_OF_MONEY%TYPE := OKE_API.G_MISS_CHAR,
  bill_undefinitized_flag OKE_K_LINES.BILL_UNDEFINITIZED_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  nsn_number		OKE_K_LINES.NSN_NUMBER%TYPE := OKE_API.G_MISS_CHAR,
  nte_warning_flag	OKE_K_LINES.NTE_WARNING_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  discount_for_payment	OKE_K_LINES.DISCOUNT_FOR_PAYMENT%TYPE := OKE_API.G_MISS_NUM,
  financial_ctrl_flag	OKE_K_LINES.FINANCIAL_CTRL_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  c_scs_flag		OKE_K_LINES.C_SCS_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  c_ssr_flag		OKE_K_LINES.C_SSR_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  prepayment_amount	OKE_K_LINES.PREPAYMENT_AMOUNT%TYPE := OKE_API.G_MISS_NUM,
  prepayment_percentage  OKE_K_LINES.PREPAYMENT_PERCENTAGE%TYPE := OKE_API.G_MISS_NUM,
  progress_payment_flag OKE_K_LINES.PROGRESS_PAYMENT_FLAG%TYPE := OKE_API.G_MISS_CHAR,
  progress_payment_liq_rate OKE_K_LINES.PROGRESS_PAYMENT_LIQ_RATE%TYPE := OKE_API.G_MISS_NUM,
  progress_payment_rate OKE_K_LINES.PROGRESS_PAYMENT_RATE%TYPE := OKE_API.G_MISS_NUM,
  award_fee		OKE_K_LINES.AWARD_FEE%TYPE := OKE_API.G_MISS_NUM,
  award_fee_pool_amount OKE_K_LINES.AWARD_FEE_POOL_AMOUNT%TYPE := OKE_API.G_MISS_NUM,
  base_fee		OKE_K_LINES.BASE_FEE%TYPE := OKE_API.G_MISS_NUM,
  ceiling_cost		OKE_K_LINES.CEILING_COST%TYPE := OKE_API.G_MISS_NUM,
  ceiling_price		OKE_K_LINES.CEILING_PRICE%TYPE := OKE_API.G_MISS_NUM,
  labor_cost_index	OKE_K_LINES.LABOR_COST_INDEX%TYPE := OKE_API.G_MISS_CHAR,
  material_cost_index	OKE_K_LINES.MATERIAL_COST_INDEX%TYPE := OKE_API.G_MISS_CHAR,
  customers_percent_in_order OKE_K_LINES.CUSTOMERS_PERCENT_IN_ORDER%TYPE := OKE_API.G_MISS_NUM,
  cost_overrun_share_ratio	OKE_K_LINES.COST_OVERRUN_SHARE_RATIO%TYPE := OKE_API.G_MISS_CHAR,
  cost_underrun_share_ratio	OKE_K_LINES.COST_UNDERRUN_SHARE_RATIO%TYPE := OKE_API.G_MISS_CHAR,
  date_of_price_redetermin OKE_K_LINES.DATE_OF_PRICE_REDETERMIN%TYPE := OKE_API.G_MISS_DATE,
  estimated_total_quantity OKE_K_LINES.ESTIMATED_TOTAL_QUANTITY%TYPE := OKE_API.G_MISS_NUM,
  fee_ajt_formula	OKE_K_LINES.FEE_AJT_FORMULA%TYPE := OKE_API.G_MISS_CHAR,
  final_fee		OKE_K_LINES.FINAL_FEE%TYPE := OKE_API.G_MISS_NUM,
  final_pft_ajt_formula OKE_K_LINES.FINAL_PFT_AJT_FORMULA%TYPE := OKE_API.G_MISS_CHAR,
  fixed_fee		OKE_K_LINES.FIXED_FEE%TYPE := OKE_API.G_MISS_NUM,
  fixed_quantity	OKE_K_LINES.FIXED_QUANTITY%TYPE := OKE_API.G_MISS_NUM,
  initial_fee		OKE_K_LINES.INITIAL_FEE%TYPE := OKE_API.G_MISS_NUM,
  initial_price		OKE_K_LINES.INITIAL_PRICE%TYPE := OKE_API.G_MISS_NUM,
  level_of_effort_hours OKE_K_LINES.LEVEL_OF_EFFORT_HOURS%TYPE := OKE_API.G_MISS_NUM,
  line_liquidation_rate OKE_K_LINES.LINE_LIQUIDATION_RATE%TYPE := OKE_API.G_MISS_NUM,
  maximum_fee		OKE_K_LINES.MAXIMUM_FEE%TYPE := OKE_API.G_MISS_NUM,
  maximum_quantity	OKE_K_LINES.MAXIMUM_QUANTITY%TYPE := OKE_API.G_MISS_NUM,
  minimum_fee		OKE_K_LINES.MINIMUM_FEE%TYPE := OKE_API.G_MISS_NUM,
  minimum_quantity	OKE_K_LINES.MINIMUM_QUANTITY%TYPE := OKE_API.G_MISS_NUM,
  number_of_options	OKE_K_LINES.NUMBER_OF_OPTIONS%TYPE := OKE_API.G_MISS_NUM,
  revised_price		OKE_K_LINES.REVISED_PRICE%TYPE := OKE_API.G_MISS_NUM,
  target_cost		OKE_K_LINES.TARGET_COST%TYPE := OKE_API.G_MISS_NUM,
  target_date_definitize OKE_K_LINES.TARGET_DATE_DEFINITIZE%TYPE := OKE_API.G_MISS_DATE,
  target_fee	        OKE_K_LINES.TARGET_FEE%TYPE := OKE_API.G_MISS_NUM,
  target_price		OKE_K_LINES.TARGET_PRICE%TYPE := OKE_API.G_MISS_NUM,
  total_estimated_cost  OKE_K_LINES.TOTAL_ESTIMATED_COST%TYPE := OKE_API.G_MISS_NUM,
  proposal_due_date	OKE_K_LINES.PROPOSAL_DUE_DATE%TYPE := OKE_API.G_MISS_CHAR,
  cost_of_sale_rate	NUMBER:=OKE_API.G_MISS_NUM,
  line_value		NUMBER:=OKE_API.G_MISS_NUM,
  line_value_total	NUMBER:=OKE_API.G_MISS_NUM,
  UNDEF_UNIT_PRICE	NUMBER  := OKE_API.G_MISS_NUM,
  UNDEF_LINE_VALUE	NUMBER  := OKE_API.G_MISS_NUM,
  UNDEF_LINE_VALUE_TOTAL NUMBER := OKE_API.G_MISS_NUM,


--    id                             NUMBER := OKE_API.G_MISS_NUM,
    object_version_number          NUMBER := OKE_API.G_MISS_NUM,
    sfwt_flag                      OKC_K_LINES_V.SFWT_FLAG%TYPE := OKE_API.G_MISS_CHAR,
    chr_id                         NUMBER := OKE_API.G_MISS_NUM,
    cle_id                         NUMBER := OKE_API.G_MISS_NUM,
    cle_id_renewed                 NUMBER := OKE_API.G_MISS_NUM,
    cle_id_renewed_to		     NUMBER := OKE_API.G_MISS_NUM,
    lse_id                         NUMBER := OKE_API.G_MISS_NUM,
    line_number                    OKC_K_LINES_V.LINE_NUMBER%TYPE := OKE_API.G_MISS_CHAR,
    sts_code                       OKC_K_LINES_V.STS_CODE%TYPE := OKE_API.G_MISS_CHAR,
    display_sequence               NUMBER := OKE_API.G_MISS_NUM,
    trn_code                       OKC_K_LINES_V.TRN_CODE%TYPE := OKE_API.G_MISS_CHAR,
    dnz_chr_id                     NUMBER := OKE_API.G_MISS_NUM,
    comments                       OKC_K_LINES_V.COMMENTS%TYPE := OKE_API.G_MISS_CHAR,
    item_description               OKC_K_LINES_V.ITEM_DESCRIPTION%TYPE := OKE_API.G_MISS_CHAR,
    oke_boe_description            OKC_K_LINES_V.OKE_BOE_DESCRIPTION%TYPE := OKE_API.G_MISS_CHAR,
    hidden_ind                     OKC_K_LINES_V.HIDDEN_IND%TYPE := OKE_API.G_MISS_CHAR,
    price_unit			     NUMBER := OKE_API.G_MISS_NUM,
    price_unit_percent		     NUMBER := OKE_API.G_MISS_NUM,
    price_negotiated               NUMBER := OKE_API.G_MISS_NUM,
    price_negotiated_renewed       NUMBER := OKE_API.G_MISS_NUM,
    price_level_ind                OKC_K_LINES_V.PRICE_LEVEL_IND%TYPE := OKE_API.G_MISS_CHAR,
    invoice_line_level_ind         OKC_K_LINES_V.INVOICE_LINE_LEVEL_IND%TYPE := OKE_API.G_MISS_CHAR,
    dpas_rating                    OKC_K_LINES_V.DPAS_RATING%TYPE := OKE_API.G_MISS_CHAR,
    block23text                    OKC_K_LINES_V.BLOCK23TEXT%TYPE := OKE_API.G_MISS_CHAR,
    exception_yn                   OKC_K_LINES_V.EXCEPTION_YN%TYPE := OKE_API.G_MISS_CHAR,
    template_used                  OKC_K_LINES_V.TEMPLATE_USED%TYPE := OKE_API.G_MISS_CHAR,
    date_terminated                OKC_K_LINES_V.DATE_TERMINATED%TYPE := OKE_API.G_MISS_DATE,
    name                           OKC_K_LINES_V.NAME%TYPE := OKE_API.G_MISS_CHAR,
    start_date                     OKC_K_LINES_V.START_DATE%TYPE := OKE_API.G_MISS_DATE,
    end_date                       OKC_K_LINES_V.END_DATE%TYPE := OKE_API.G_MISS_DATE,
    upg_orig_system_ref            OKC_K_LINES_V.UPG_ORIG_SYSTEM_REF%TYPE := OKE_API.G_MISS_CHAR,
    upg_orig_system_ref_id         NUMBER := OKE_API.G_MISS_NUM,
    attribute_category             OKC_K_LINES_V.ATTRIBUTE_CATEGORY%TYPE := OKE_API.G_MISS_CHAR,
    attribute1                     OKC_K_LINES_V.ATTRIBUTE1%TYPE := OKE_API.G_MISS_CHAR,
    attribute2                     OKC_K_LINES_V.ATTRIBUTE2%TYPE := OKE_API.G_MISS_CHAR,
    attribute3                     OKC_K_LINES_V.ATTRIBUTE3%TYPE := OKE_API.G_MISS_CHAR,
    attribute4                     OKC_K_LINES_V.ATTRIBUTE4%TYPE := OKE_API.G_MISS_CHAR,
    attribute5                     OKC_K_LINES_V.ATTRIBUTE5%TYPE := OKE_API.G_MISS_CHAR,
    attribute6                     OKC_K_LINES_V.ATTRIBUTE6%TYPE := OKE_API.G_MISS_CHAR,
    attribute7                     OKC_K_LINES_V.ATTRIBUTE7%TYPE := OKE_API.G_MISS_CHAR,
    attribute8                     OKC_K_LINES_V.ATTRIBUTE8%TYPE := OKE_API.G_MISS_CHAR,
    attribute9                     OKC_K_LINES_V.ATTRIBUTE9%TYPE := OKE_API.G_MISS_CHAR,
    attribute10                    OKC_K_LINES_V.ATTRIBUTE10%TYPE := OKE_API.G_MISS_CHAR,
    attribute11                    OKC_K_LINES_V.ATTRIBUTE11%TYPE := OKE_API.G_MISS_CHAR,
    attribute12                    OKC_K_LINES_V.ATTRIBUTE12%TYPE := OKE_API.G_MISS_CHAR,
    attribute13                    OKC_K_LINES_V.ATTRIBUTE13%TYPE := OKE_API.G_MISS_CHAR,
    attribute14                    OKC_K_LINES_V.ATTRIBUTE14%TYPE := OKE_API.G_MISS_CHAR,
    attribute15                    OKC_K_LINES_V.ATTRIBUTE15%TYPE := OKE_API.G_MISS_CHAR,
    price_type                     OKC_K_LINES_V.PRICE_TYPE%TYPE := OKE_API.G_MISS_CHAR,
    currency_code                  OKC_K_LINES_V.CURRENCY_CODE%TYPE := OKE_API.G_MISS_CHAR,
    currency_code_renewed	     OKC_K_LINES_V.CURRENCY_CODE_RENEWED%TYPE := OKE_API.G_MISS_CHAR,

  created_by	        NUMBER := OKE_API.G_MISS_NUM,
  creation_date		OKE_K_LINES.CREATION_DATE%TYPE := OKE_API.G_MISS_DATE,
  last_updated_by	NUMBER := OKE_API.G_MISS_NUM,
  last_update_login	NUMBER := OKE_API.G_MISS_NUM,
  last_update_date      OKE_K_LINES.LAST_UPDATE_DATE%TYPE := OKE_API.G_MISS_DATE
);


TYPE bill_rec_type IS RECORD(
 K_HEADER_ID                     	NUMBER := OKE_API.G_MISS_NUM,
 BILLING_METHOD_CODE             	VARCHAR2(30) := OKE_API.G_MISS_CHAR,
 CREATION_DATE                   	DATE := OKE_API.G_MISS_DATE,
 CREATED_BY                       	NUMBER := OKE_API.G_MISS_NUM,
 LAST_UPDATE_DATE                	DATE:= OKE_API.G_MISS_DATE,
 LAST_UPDATED_BY                 	NUMBER := OKE_API.G_MISS_NUM,
 LAST_UPDATE_LOGIN               	NUMBER := OKE_API.G_MISS_NUM,
 DEFAULT_FLAG                    	VARCHAR2(1) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE_CATEGORY                       VARCHAR2(30) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE1                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE2                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE3                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE4                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE5                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE6                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE7                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE8                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE9                               VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE10                              VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE11                              VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE12                              VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE13                              VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE14                              VARCHAR2(150) := OKE_API.G_MISS_CHAR,
 ATTRIBUTE15                              VARCHAR2(150) := OKE_API.G_MISS_CHAR

);

TYPE bill_tbl_type IS TABLE OF bill_rec_type INDEX BY BINARY_INTEGER;

TYPE cimv_rec_type IS RECORD(
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id_for                     NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    object1_id1                    OKC_K_ITEMS_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKC_K_ITEMS_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object1_code              OKC_K_ITEMS_V.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    uom_code                       OKC_K_ITEMS_V.UOM_CODE%TYPE := OKC_API.G_MISS_CHAR,
    exception_yn                   OKC_K_ITEMS_V.EXCEPTION_YN%TYPE := OKC_API.G_MISS_CHAR,
    number_of_items                NUMBER := OKC_API.G_MISS_NUM,
    upg_orig_system_ref            OKC_K_ITEMS_V.UPG_ORIG_SYSTEM_REF%TYPE := OKC_API.G_MISS_CHAR,
    upg_orig_system_ref_id         NUMBER := OKC_API.G_MISS_NUM,
    priced_item_yn                 OKC_K_ITEMS_V.PRICED_ITEM_YN%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_ITEMS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_ITEMS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM
);

TYPE cimv_tbl_type IS TABLE OF cimv_rec_type INDEX BY BINARY_INTEGER;



/*#
 * Creates the contract header. This is the first step towards creating a
 * complete contract document.
 * @rep:metalink 234864.1 See OracleMetaLink bulletin 234864.1
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Project Contract Header
 * @rep:category BUSINESS_ENTITY OKE_CONTRACT
 */
  PROCEDURE create_contract_header(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    p_ignore_oke_validation        IN VARCHAR2 DEFAULT 'N',
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_chr_rec			   IN  chr_rec_type,
    x_chr_rec			   OUT NOCOPY  chr_rec_type);

/*#
 * Creates a contract line. The top level line must be created before
 * creating the lower level sub-lines with this same procedure
 * @rep:metalink 234864.1 See OracleMetaLink bulletin 234864.1
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Project Contract Line
 * @rep:category BUSINESS_ENTITY OKE_CONTRACT
 */
  PROCEDURE create_contract_line(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_cle_rec			   IN  cle_rec_type,
    x_cle_rec			   OUT NOCOPY  cle_rec_type);

/*#
 * Creates a contract deliverable. This is used to create deliverables
 * after all sub-lines are in place.
 * @rep:metalink 234864.1 See OracleMetaLink bulletin 234864.1
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Project Contract Deliverable
 * @rep:category BUSINESS_ENTITY OKE_CONTRACT
 */
  PROCEDURE create_deliverable(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_del_rec			   IN  del_rec_type,
    x_del_rec			   OUT NOCOPY  del_rec_type);


/*#
 * Define billing method set for a particular contract.
 * This can be done anytime after the header has been created.
 * @rep:metalink 234864.1 See OracleMetaLink bulletin 234864.1
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Define Project Contract Billing Method
 * @rep:category BUSINESS_ENTITY OKE_CONTRACT
 */
  PROCEDURE define_billing_methods(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_bill_tbl			   IN bill_tbl_type);


/* - only need to provide k_header_id and billing_method_code to remove
   - will only remove billing_methods not assigned at the lines */

  PROCEDURE remove_billing_methods(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_bill_tbl			   IN bill_tbl_type);



/*
     PURPORSE:
		to attach a line item to a contract line.
		line items should only be attached to lines that have 'item' line style.


     INPUT PARAMETERS:
	DNZ_CHR_ID	-- k_header_id of oke_k_headers; the id of the header that the line belongs to
	CLE_ID		-- k_line_id of oke_k_lines; the id of the particular line you are attaching
			   this line item to.
	EXCEPTION_YN	-- use 'N'
	PRICED_ITEM_YN 	-- use 'N'
	OBJECT1_ID1		-- item id
	OBJECT1_ID2		-- 'inventory org id'  also known as 'item master org id'
	JTOT_OBJECT1_CODE	-- 'OKE_ITEMS'
	UOM_CODE	-- same as uom_code of the line in oke_k_lines table
	NUMBER_OF_ITEMS -- same as line_quantity of the line in oke_k_lines

    	CREATED_BY	-- who columns; please copy from the respective line.
    	CREATION_DATE	   it is supposed to be the same as the line it is attached to.
    	LAST_UPDATED_BY
    	LAST_UPDATE_DATE
    	LAST_UPDATE_LOGIN

*/

  PROCEDURE create_line_item(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_cimv_rec			   IN  cimv_rec_type,
    x_cimv_rec			   OUT NOCOPY  cimv_rec_type);


END OKE_IMPORT_CONTRACT_PUB;


 

/
