--------------------------------------------------------
--  DDL for Package OKC_CHR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CHR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSCHRS.pls 120.5 2007/09/07 10:08:06 vmutyala ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE chr_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    contract_number                OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    authoring_org_id               NUMBER := OKC_API.G_MISS_NUM,
--    org_id                         NUMBER := OKC_API.G_MISS_NUM, --mmadhavi added for MOAC
    contract_number_modifier       OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE := OKC_API.G_MISS_CHAR,
    chr_id_response                NUMBER := OKC_API.G_MISS_NUM,
    chr_id_award                   NUMBER := OKC_API.G_MISS_NUM,
    chr_id_renewed                 NUMBER := OKC_API.G_MISS_NUM,
    INV_ORGANIZATION_ID            NUMBER := OKC_API.G_MISS_NUM,
    sts_code                       OKC_K_HEADERS_B.STS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    qcl_id                         NUMBER := OKC_API.G_MISS_NUM,
    scs_code                       OKC_K_HEADERS_B.SCS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    trn_code                       OKC_K_HEADERS_B.TRN_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_code                  OKC_K_HEADERS_B.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    archived_yn                    OKC_K_HEADERS_B.ARCHIVED_YN%TYPE := OKC_API.G_MISS_CHAR,
    deleted_yn                     OKC_K_HEADERS_B.DELETED_YN%TYPE := OKC_API.G_MISS_CHAR,
    template_yn                    OKC_K_HEADERS_B.TEMPLATE_YN%TYPE := OKC_API.G_MISS_CHAR,
    chr_type                       OKC_K_HEADERS_B.CHR_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_HEADERS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_HEADERS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    cust_po_number_req_yn          OKC_K_HEADERS_B.CUST_PO_NUMBER_REQ_YN%TYPE := OKC_API.G_MISS_CHAR,
    pre_pay_req_yn                 OKC_K_HEADERS_B.PRE_PAY_REQ_YN%TYPE := OKC_API.G_MISS_CHAR,
    cust_po_number                 OKC_K_HEADERS_B.CUST_PO_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    dpas_rating                    OKC_K_HEADERS_B.DPAS_RATING%TYPE := OKC_API.G_MISS_CHAR,
    template_used                  OKC_K_HEADERS_B.TEMPLATE_USED%TYPE := OKC_API.G_MISS_CHAR,
    date_approved                  OKC_K_HEADERS_B.DATE_APPROVED%TYPE := OKC_API.G_MISS_DATE,
    datetime_cancelled             OKC_K_HEADERS_B.DATETIME_CANCELLED%TYPE := OKC_API.G_MISS_DATE,
    auto_renew_days                NUMBER := OKC_API.G_MISS_NUM,
    date_issued                    OKC_K_HEADERS_B.DATE_ISSUED%TYPE := OKC_API.G_MISS_DATE,
    datetime_responded             OKC_K_HEADERS_B.DATETIME_RESPONDED%TYPE := OKC_API.G_MISS_DATE,
    rfp_type                       OKC_K_HEADERS_B.RFP_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    keep_on_mail_list              OKC_K_HEADERS_B.KEEP_ON_MAIL_LIST%TYPE := OKC_API.G_MISS_CHAR,
    set_aside_percent              NUMBER := OKC_API.G_MISS_NUM,
    response_copies_req            NUMBER := OKC_API.G_MISS_NUM,
    date_close_projected           OKC_K_HEADERS_B.DATE_CLOSE_PROJECTED%TYPE := OKC_API.G_MISS_DATE,
    datetime_proposed              OKC_K_HEADERS_B.DATETIME_PROPOSED%TYPE := OKC_API.G_MISS_DATE,
    date_signed                    OKC_K_HEADERS_B.DATE_SIGNED%TYPE := OKC_API.G_MISS_DATE,
    date_terminated                OKC_K_HEADERS_B.DATE_TERMINATED%TYPE := OKC_API.G_MISS_DATE,
    date_renewed                   OKC_K_HEADERS_B.DATE_RENEWED%TYPE := OKC_API.G_MISS_DATE,
    start_date                     OKC_K_HEADERS_B.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKC_K_HEADERS_B.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    buy_or_sell                    OKC_K_HEADERS_B.BUY_OR_SELL%TYPE := OKC_API.G_MISS_CHAR,
    issue_or_receive               OKC_K_HEADERS_B.ISSUE_OR_RECEIVE%TYPE := OKC_API.G_MISS_CHAR,
    estimated_amount		     NUMBER := OKC_API.G_MISS_NUM,
    chr_id_renewed_to		     NUMBER := OKC_API.G_MISS_NUM,
    estimated_amount_renewed       NUMBER := OKC_API.G_MISS_NUM,
    currency_code_renewed	     OKC_K_HEADERS_B.CURRENCY_CODE_RENEWED%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    upg_orig_system_ref            OKC_K_HEADERS_B.UPG_ORIG_SYSTEM_REF%TYPE := OKC_API.G_MISS_CHAR,
    upg_orig_system_ref_id         NUMBER := OKC_API.G_MISS_NUM,
    application_id                 NUMBER := OKC_API.G_MISS_NUM,
    orig_system_source_code        OKC_K_HEADERS_B.ORIG_SYSTEM_SOURCE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    orig_system_id1                NUMBER := OKC_API.G_MISS_NUM,
    orig_system_reference1         OKC_K_HEADERS_B.ORIG_SYSTEM_REFERENCE1%TYPE := OKC_API.G_MISS_CHAR,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    price_list_id                  NUMBER := OKC_API.G_MISS_NUM,
    pricing_date                   OKC_K_HEADERS_B.PRICING_DATE%TYPE := OKC_API.G_MISS_DATE,
    sign_by_date                   OKC_K_HEADERS_B.SIGN_BY_DATE%TYPE := OKC_API.G_MISS_DATE,
    program_update_date            OKC_K_HEADERS_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    total_line_list_price          NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    USER_ESTIMATED_AMOUNT          NUMBER := OKC_API.G_MISS_NUM,
    GOVERNING_CONTRACT_YN          OKC_K_HEADERS_B.GOVERNING_CONTRACT_YN%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_K_HEADERS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_K_HEADERS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_K_HEADERS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_K_HEADERS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_K_HEADERS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_K_HEADERS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_K_HEADERS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_K_HEADERS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_K_HEADERS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_K_HEADERS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_K_HEADERS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_K_HEADERS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_K_HEADERS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_K_HEADERS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_K_HEADERS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_K_HEADERS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
--new columns to replace rules
    conversion_type                OKC_K_HEADERS_B.CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    conversion_rate                NUMBER := OKC_API.G_MISS_NUM,
    conversion_rate_date           OKC_K_HEADERS_B.CONVERSION_RATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    conversion_euro_rate           NUMBER := OKC_API.G_MISS_NUM,
    cust_acct_id                   NUMBER := OKC_API.G_MISS_NUM,
    bill_to_site_use_id            NUMBER := OKC_API.G_MISS_NUM,
    inv_rule_id                    NUMBER := OKC_API.G_MISS_NUM,
    renewal_type_code              OKC_K_HEADERS_B.RENEWAL_TYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
    renewal_notify_to              NUMBER :=OKC_API.G_MISS_NUM,
    renewal_end_date               OKC_K_HEADERS_B.RENEWAL_END_DATE%TYPE :=OKC_API.G_MISS_DATE,
    ship_to_site_use_id            NUMBER := OKC_API.G_MISS_NUM,
    payment_term_id                NUMBER :=OKC_API.G_MISS_NUM,
    document_id			   NUMBER :=OKC_API.G_MISS_NUM,
-- R12 Data Model Changes 4485150 start
    approval_type                  OKC_K_HEADERS_B.APPROVAL_TYPE%TYPE :=  OKC_API.G_MISS_CHAR,
    term_cancel_source             OKC_K_HEADERS_B.TERM_CANCEL_SOURCE%TYPE :=  OKC_API.G_MISS_CHAR,
    payment_instruction_type       OKC_K_HEADERS_B.PAYMENT_INSTRUCTION_TYPE%TYPE :=  OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,    --mmadhavi added for MOAC
-- R12 Data Model Changes 4485150 End
    cancelled_amount 		     NUMBER := OKC_API.G_MISS_NUM, -- LLC
    billed_at_source		   OKC_K_HEADERS_ALL_B.BILLED_AT_SOURCE%TYPE
);
  g_miss_chr_rec                          chr_rec_type;
  TYPE chr_tbl_type IS TABLE OF chr_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE okc_k_headers_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKC_K_HEADERS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKC_K_HEADERS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKC_K_HEADERS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_K_HEADERS_TL.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_K_HEADERS_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_K_HEADERS_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    cognomen                       OKC_K_HEADERS_TL.COGNOMEN%TYPE := OKC_API.G_MISS_CHAR,
    non_response_reason            OKC_K_HEADERS_TL.NON_RESPONSE_REASON%TYPE := OKC_API.G_MISS_CHAR,
    non_response_explain           OKC_K_HEADERS_TL.NON_RESPONSE_EXPLAIN%TYPE := OKC_API.G_MISS_CHAR,
    set_aside_reason               OKC_K_HEADERS_TL.SET_ASIDE_REASON%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_HEADERS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_HEADERS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_okc_k_headers_tl_rec             okc_k_headers_tl_rec_type;
  TYPE okc_k_headers_tl_tbl_type IS TABLE OF okc_k_headers_tl_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE chrv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_K_HEADERS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    chr_id_response                NUMBER := OKC_API.G_MISS_NUM,
    chr_id_award                   NUMBER := OKC_API.G_MISS_NUM,
    chr_id_renewed                 NUMBER := OKC_API.G_MISS_NUM,
    INV_ORGANIZATION_ID            NUMBER := OKC_API.G_MISS_NUM,
    sts_code                       OKC_K_HEADERS_V.STS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    qcl_id                         NUMBER := OKC_API.G_MISS_NUM,
    scs_code                       OKC_K_HEADERS_V.SCS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    contract_number                OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    currency_code                  OKC_K_HEADERS_V.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    contract_number_modifier       OKC_K_HEADERS_V.CONTRACT_NUMBER_MODIFIER%TYPE := OKC_API.G_MISS_CHAR,
    archived_yn                    OKC_K_HEADERS_V.ARCHIVED_YN%TYPE := OKC_API.G_MISS_CHAR,
    deleted_yn                     OKC_K_HEADERS_V.DELETED_YN%TYPE := OKC_API.G_MISS_CHAR,
    cust_po_number_req_yn          OKC_K_HEADERS_V.CUST_PO_NUMBER_REQ_YN%TYPE := OKC_API.G_MISS_CHAR,
    pre_pay_req_yn                 OKC_K_HEADERS_V.PRE_PAY_REQ_YN%TYPE := OKC_API.G_MISS_CHAR,
    cust_po_number                 OKC_K_HEADERS_V.CUST_PO_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_K_HEADERS_V.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_K_HEADERS_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_K_HEADERS_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    dpas_rating                    OKC_K_HEADERS_V.DPAS_RATING%TYPE := OKC_API.G_MISS_CHAR,
    cognomen                       OKC_K_HEADERS_V.COGNOMEN%TYPE := OKC_API.G_MISS_CHAR,
    template_yn                    OKC_K_HEADERS_V.TEMPLATE_YN%TYPE := OKC_API.G_MISS_CHAR,
    template_used                  OKC_K_HEADERS_V.TEMPLATE_USED%TYPE := OKC_API.G_MISS_CHAR,
    date_approved                  OKC_K_HEADERS_V.DATE_APPROVED%TYPE := OKC_API.G_MISS_DATE,
    datetime_cancelled             OKC_K_HEADERS_V.DATETIME_CANCELLED%TYPE := OKC_API.G_MISS_DATE,
    auto_renew_days                NUMBER := OKC_API.G_MISS_NUM,
    date_issued                    OKC_K_HEADERS_V.DATE_ISSUED%TYPE := OKC_API.G_MISS_DATE,
    datetime_responded             OKC_K_HEADERS_V.DATETIME_RESPONDED%TYPE := OKC_API.G_MISS_DATE,
    non_response_reason            OKC_K_HEADERS_V.NON_RESPONSE_REASON%TYPE := OKC_API.G_MISS_CHAR,
    non_response_explain           OKC_K_HEADERS_V.NON_RESPONSE_EXPLAIN%TYPE := OKC_API.G_MISS_CHAR,
    rfp_type                       OKC_K_HEADERS_V.RFP_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    chr_type                       OKC_K_HEADERS_V.CHR_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    keep_on_mail_list              OKC_K_HEADERS_V.KEEP_ON_MAIL_LIST%TYPE := OKC_API.G_MISS_CHAR,
    set_aside_reason               OKC_K_HEADERS_V.SET_ASIDE_REASON%TYPE := OKC_API.G_MISS_CHAR,
    set_aside_percent              NUMBER := OKC_API.G_MISS_NUM,
    response_copies_req            NUMBER := OKC_API.G_MISS_NUM,
    date_close_projected           OKC_K_HEADERS_V.DATE_CLOSE_PROJECTED%TYPE := OKC_API.G_MISS_DATE,
    datetime_proposed              OKC_K_HEADERS_V.DATETIME_PROPOSED%TYPE := OKC_API.G_MISS_DATE,
    date_signed                    OKC_K_HEADERS_V.DATE_SIGNED%TYPE := OKC_API.G_MISS_DATE,
    date_terminated                OKC_K_HEADERS_V.DATE_TERMINATED%TYPE := OKC_API.G_MISS_DATE,
    date_renewed                   OKC_K_HEADERS_V.DATE_RENEWED%TYPE := OKC_API.G_MISS_DATE,
    trn_code                       OKC_K_HEADERS_V.TRN_CODE%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKC_K_HEADERS_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKC_K_HEADERS_V.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    authoring_org_id               NUMBER := OKC_API.G_MISS_NUM,
--    org_id                         NUMBER := OKC_API.G_MISS_NUM, --mmadhavi added for MOAC
    buy_or_sell                    OKC_K_HEADERS_V.BUY_OR_SELL%TYPE := OKC_API.G_MISS_CHAR,
    issue_or_receive               OKC_K_HEADERS_V.ISSUE_OR_RECEIVE%TYPE := OKC_API.G_MISS_CHAR,
    estimated_amount		     NUMBER := OKC_API.G_MISS_NUM,
    chr_id_renewed_to		     NUMBER := OKC_API.G_MISS_NUM,
    estimated_amount_renewed       NUMBER := OKC_API.G_MISS_NUM,
    currency_code_renewed	     OKC_K_HEADERS_V.CURRENCY_CODE_RENEWED%TYPE := OKC_API.G_MISS_CHAR,
    upg_orig_system_ref            OKC_K_HEADERS_V.UPG_ORIG_SYSTEM_REF%TYPE := OKC_API.G_MISS_CHAR,
    upg_orig_system_ref_id         NUMBER := OKC_API.G_MISS_NUM,
    application_id                 NUMBER := OKC_API.G_MISS_NUM,
    orig_system_source_code        OKC_K_HEADERS_V.ORIG_SYSTEM_SOURCE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    orig_system_id1                NUMBER := OKC_API.G_MISS_NUM,
    orig_system_reference1         OKC_K_HEADERS_V.ORIG_SYSTEM_REFERENCE1%TYPE := OKC_API.G_MISS_CHAR,
      program_id                     NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    price_list_id                  NUMBER := OKC_API.G_MISS_NUM,
    pricing_date                   OKC_K_HEADERS_V.PRICING_DATE%TYPE := OKC_API.G_MISS_DATE,
    sign_by_date                   OKC_K_HEADERS_V.SIGN_BY_DATE%TYPE := OKC_API.G_MISS_DATE,
    program_update_date            OKC_K_HEADERS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    total_line_list_price          NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    USER_ESTIMATED_AMOUNT          NUMBER := OKC_API.G_MISS_NUM,
    GOVERNING_CONTRACT_YN          OKC_K_HEADERS_V.GOVERNING_CONTRACT_YN%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_K_HEADERS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_K_HEADERS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_K_HEADERS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_K_HEADERS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_K_HEADERS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_K_HEADERS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_K_HEADERS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_K_HEADERS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_K_HEADERS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_K_HEADERS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_K_HEADERS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_K_HEADERS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_K_HEADERS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_K_HEADERS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_K_HEADERS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_K_HEADERS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_HEADERS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_HEADERS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    old_sts_code                   OKC_K_HEADERS_V.STS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    new_sts_code                   OKC_K_HEADERS_V.STS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    old_ste_code                   OKC_STATUSES_V.STE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    new_ste_code                   OKC_STATUSES_V.STE_CODE%TYPE := OKC_API.G_MISS_CHAR ,
    --new columns to replace rules
    conversion_type                OKC_K_HEADERS_V.CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    conversion_rate                NUMBER := OKC_API.G_MISS_NUM,
    conversion_rate_date           OKC_K_HEADERS_V.CONVERSION_RATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    conversion_euro_rate           NUMBER := OKC_API.G_MISS_NUM,
    cust_acct_id                   NUMBER := OKC_API.G_MISS_NUM,
    bill_to_site_use_id            NUMBER := OKC_API.G_MISS_NUM,
    inv_rule_id                    NUMBER := OKC_API.G_MISS_NUM,
    renewal_type_code              OKC_K_HEADERS_V.RENEWAL_TYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
    renewal_notify_to              NUMBER :=OKC_API.G_MISS_NUM,
    renewal_end_date               OKC_K_HEADERS_V.RENEWAL_END_DATE%TYPE :=OKC_API.G_MISS_DATE,
    ship_to_site_use_id            NUMBER := OKC_API.G_MISS_NUM,
    payment_term_id                NUMBER :=OKC_API.G_MISS_NUM,
    VALIDATE_YN                    VARCHAR2(1) DEFAULT  'Y', --Bug#3150149.
    document_id				NUMBER :=OKC_API.G_MISS_NUM,
-- R12 Data Model Changes 4485150 Start
    approval_type                  OKC_K_HEADERS_B.APPROVAL_TYPE%TYPE :=  OKC_API.G_MISS_CHAR,
    term_cancel_source             OKC_K_HEADERS_B.TERM_CANCEL_SOURCE%TYPE :=  OKC_API.G_MISS_CHAR,
    payment_instruction_type       OKC_K_HEADERS_B.PAYMENT_INSTRUCTION_TYPE%TYPE :=  OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,    --mmadhavi added for MOAC
-- R12 Data Model Changes 4485150 End
    cancelled_amount 		     NUMBER := OKC_API.G_MISS_NUM, -- LLC
    billed_at_source		   OKC_K_HEADERS_ALL_V.BILLED_AT_SOURCE%TYPE
    );
  g_miss_chrv_rec                         chrv_rec_type;
  TYPE chrv_tbl_type IS TABLE OF chrv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CHR_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN chrv_rec_type,
    x_chrv_rec                     OUT NOCOPY chrv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN chrv_tbl_type,
    x_chrv_tbl                     OUT NOCOPY chrv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN chrv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN chrv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chrv_rec                     IN chrv_rec_type,
    x_chrv_rec                     OUT NOCOPY chrv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chrv_tbl                     IN chrv_tbl_type,
    x_chrv_tbl                     OUT NOCOPY chrv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN chrv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN chrv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN chrv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN chrv_tbl_type);

  PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2, p_chrv_tbl chrv_tbl_type);

  FUNCTION create_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

  FUNCTION restore_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

  -- function to check uninue contract_number + modifier
  FUNCTION IS_UNIQUE (p_chrv_rec chrv_rec_type) RETURN VARCHAR2;

END OKC_CHR_PVT;

/
