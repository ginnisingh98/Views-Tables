--------------------------------------------------------
--  DDL for Package OKL_OKC_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OKC_MIGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLROKCS.pls 120.2 2006/11/13 07:34:05 dpsingh noship $ */
-- The Enities we are Handling are as listed below
--1.OKC_K_VERS_NUMBERS_V  -- cvmv
--2.OKC_K_HEADERS_V       -- chrv
--3.OKC_K_LINES_V         -- clev
--4.OKC_K_ITEMS_V         -- cimv
--5.OKC_K_PARTY_ROLES_V   -- cplv
--6.OKC_GOVERNANCES_V     -- gvev
--7.OKC_RULE_GROUPS_V     -- rgpv
--8.OKC_RG_PARTY_ROLES_V  -- rmpv
--9.OKC_CONTACTS_V        -- ctcv
-- End of Listing
-- Badriath Kuchibhotla
  TYPE cvmv_rec_type IS RECORD (
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    major_version                  NUMBER := OKC_API.G_MISS_NUM,
    minor_version                  NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_VERS_NUMBERS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_VERS_NUMBERS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);

  TYPE cvmv_tbl_type IS TABLE OF cvmv_rec_type
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
    buy_or_sell                    OKC_K_HEADERS_V.BUY_OR_SELL%TYPE := OKC_API.G_MISS_CHAR,
    issue_or_receive               OKC_K_HEADERS_V.ISSUE_OR_RECEIVE%TYPE := OKC_API.G_MISS_CHAR,
    estimated_amount           NUMBER := OKC_API.G_MISS_NUM,
    chr_id_renewed_to          NUMBER := OKC_API.G_MISS_NUM,
    estimated_amount_renewed       NUMBER := OKC_API.G_MISS_NUM,
    currency_code_renewed      OKC_K_HEADERS_V.CURRENCY_CODE_RENEWED%TYPE := OKC_API.G_MISS_CHAR,
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
    new_ste_code                   OKC_STATUSES_V.STE_CODE%TYPE := OKC_API.G_MISS_CHAR,
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
    --Added by dpsingh for LE Uptake
    legal_entity_id                    NUMBER :=OKL_API.G_MISS_NUM);

  TYPE chrv_tbl_type IS TABLE OF chrv_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE clev_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_K_LINES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id_renewed                 NUMBER := OKC_API.G_MISS_NUM,
    cle_id_renewed_to              NUMBER := OKC_API.G_MISS_NUM,
    lse_id                         NUMBER := OKC_API.G_MISS_NUM,
    line_number                    OKC_K_LINES_V.LINE_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    sts_code                       OKC_K_LINES_V.STS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    display_sequence               NUMBER := OKC_API.G_MISS_NUM,
    trn_code                       OKC_K_LINES_V.TRN_CODE%TYPE := OKC_API.G_MISS_CHAR,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    comments                       OKC_K_LINES_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    item_description               OKC_K_LINES_V.ITEM_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    oke_boe_description            OKC_K_LINES_V.OKE_BOE_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    cognomen                       OKC_K_LINES_V.COGNOMEN%TYPE := OKC_API.G_MISS_CHAR,
    hidden_ind                     OKC_K_LINES_V.HIDDEN_IND%TYPE := OKC_API.G_MISS_CHAR,
    price_unit                     NUMBER := OKC_API.G_MISS_NUM,
    price_unit_percent             NUMBER := OKC_API.G_MISS_NUM,
    price_negotiated               NUMBER := OKC_API.G_MISS_NUM,
    price_negotiated_renewed       NUMBER := OKC_API.G_MISS_NUM,
    price_level_ind                OKC_K_LINES_V.PRICE_LEVEL_IND%TYPE := OKC_API.G_MISS_CHAR,
    invoice_line_level_ind         OKC_K_LINES_V.INVOICE_LINE_LEVEL_IND%TYPE := OKC_API.G_MISS_CHAR,
    dpas_rating                    OKC_K_LINES_V.DPAS_RATING%TYPE := OKC_API.G_MISS_CHAR,
    block23text                    OKC_K_LINES_V.BLOCK23TEXT%TYPE := OKC_API.G_MISS_CHAR,
    exception_yn                   OKC_K_LINES_V.EXCEPTION_YN%TYPE := OKC_API.G_MISS_CHAR,
    template_used                  OKC_K_LINES_V.TEMPLATE_USED%TYPE := OKC_API.G_MISS_CHAR,
    date_terminated                OKC_K_LINES_V.DATE_TERMINATED%TYPE := OKC_API.G_MISS_DATE,
    name                           OKC_K_LINES_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKC_K_LINES_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKC_K_LINES_V.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    date_renewed                   OKC_K_LINES_V.DATE_RENEWED%TYPE := OKC_API.G_MISS_DATE,
    upg_orig_system_ref            OKC_K_LINES_V.UPG_ORIG_SYSTEM_REF%TYPE := OKC_API.G_MISS_CHAR,
    upg_orig_system_ref_id         NUMBER := OKC_API.G_MISS_NUM,
    orig_system_source_code        OKC_K_LINES_V.ORIG_SYSTEM_SOURCE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
    orig_system_id1                NUMBER := OKC_API.G_MISS_NUM,
    orig_system_reference1         OKC_K_LINES_V.ORIG_SYSTEM_REFERENCE1%TYPE :=OKC_API.G_MISS_CHAR,
    attribute_category             OKC_K_LINES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_K_LINES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_K_LINES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_K_LINES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_K_LINES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_K_LINES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_K_LINES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_K_LINES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_K_LINES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_K_LINES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_K_LINES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_K_LINES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_K_LINES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_K_LINES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_K_LINES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_K_LINES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_LINES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_LINES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    price_type                     OKC_K_LINES_V.PRICE_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_code                  OKC_K_LINES_V.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_code_renewed      OKC_K_LINES_V.CURRENCY_CODE_RENEWED%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    old_sts_code                   OKC_K_LINES_V.STS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    new_sts_code                   OKC_K_LINES_V.STS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    old_ste_code                   OKC_STATUSES_V.STE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    new_ste_code                   OKC_STATUSES_V.STE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    Call_Action_Asmblr             VARCHAR2(1) := 'Y',
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKC_K_LINES_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    price_list_id                  NUMBER := OKC_API.G_MISS_NUM,
    pricing_date                   OKC_K_LINES_V.PRICING_DATE%TYPE := OKC_API.G_MISS_DATE,
    price_list_line_id             NUMBER := OKC_API.G_MISS_NUM,
    line_list_price                NUMBER := OKC_API.G_MISS_NUM,
    item_to_price_yn               OKC_K_LINES_V.ITEM_TO_PRICE_YN%TYPE := OKC_API.G_MISS_CHAR,
    price_basis_yn                 OKC_K_LINES_V.PRICE_BASIS_YN%TYPE := OKC_API.G_MISS_CHAR,
    config_header_id               NUMBER := OKC_API.G_MISS_NUM,
    config_revision_number         NUMBER := OKC_API.G_MISS_NUM,
    config_complete_yn             OKC_K_LINES_V.CONFIG_COMPLETE_YN%TYPE := OKC_API.G_MISS_CHAR,
    config_valid_yn                OKC_K_LINES_V.CONFIG_VALID_YN%TYPE := OKC_API.G_MISS_CHAR,
    config_top_model_line_id       NUMBER := OKC_API.G_MISS_NUM,
    config_item_type               OKC_K_LINES_V.CONFIG_ITEM_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    CONFIG_ITEM_ID                 NUMBER := OKC_API.G_MISS_NUM,
        --new columns to replace rules
    cust_acct_id                   NUMBER := OKC_API.G_MISS_NUM,
    bill_to_site_use_id            NUMBER := OKC_API.G_MISS_NUM,
    inv_rule_id                    NUMBER := OKC_API.G_MISS_NUM,
    line_renewal_type_code         OKC_K_LINES_B.LINE_RENEWAL_TYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
    ship_to_site_use_id            NUMBER := OKC_API.G_MISS_NUM,
    payment_term_id                NUMBER :=OKC_API.G_MISS_NUM
    );


  TYPE clev_tbl_type IS TABLE OF clev_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE cimv_rec_type IS RECORD (
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
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);

  TYPE cimv_tbl_type IS TABLE OF cimv_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE cplv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_K_PARTY_ROLES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    cpl_id                         NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    rle_code                       OKC_K_PARTY_ROLES_V.RLE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    object1_id1                    OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object1_code              OKC_K_PARTY_ROLES_V.jtot_object1_code%TYPE := OKC_API.G_MISS_CHAR,
    cognomen                       OKC_K_PARTY_ROLES_V.COGNOMEN%TYPE := OKC_API.G_MISS_CHAR,
    code                           OKC_K_PARTY_ROLES_V.CODE%TYPE := OKC_API.G_MISS_CHAR,
    facility                       OKC_K_PARTY_ROLES_V.FACILITY%TYPE := OKC_API.G_MISS_CHAR,
    minority_group_lookup_code     OKC_K_PARTY_ROLES_V.MINORITY_GROUP_LOOKUP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    small_business_flag            OKC_K_PARTY_ROLES_V.SMALL_BUSINESS_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    women_owned_flag               OKC_K_PARTY_ROLES_V.WOMEN_OWNED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    alias                          OKC_K_PARTY_ROLES_V.ALIAS%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_K_PARTY_ROLES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_K_PARTY_ROLES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_K_PARTY_ROLES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_K_PARTY_ROLES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_K_PARTY_ROLES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_K_PARTY_ROLES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_K_PARTY_ROLES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_K_PARTY_ROLES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_K_PARTY_ROLES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_K_PARTY_ROLES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_K_PARTY_ROLES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_K_PARTY_ROLES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_K_PARTY_ROLES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_K_PARTY_ROLES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_K_PARTY_ROLES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_K_PARTY_ROLES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_PARTY_ROLES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_PARTY_ROLES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    cust_acct_id                   NUMBER := OKC_API.G_MISS_NUM,
    bill_to_site_use_id            NUMBER := OKC_API.G_MISS_NUM);

  TYPE cplv_tbl_type IS TABLE OF cplv_rec_type
        INDEX BY BINARY_INTEGER;
-- Badriath Kuchibhotla

  TYPE gvev_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    isa_agreement_id               NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    chr_id_referred                NUMBER := OKC_API.G_MISS_NUM,
    cle_id_referred                NUMBER := OKC_API.G_MISS_NUM,
    copied_only_yn                 OKC_GOVERNANCES_V.COPIED_ONLY_YN%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_GOVERNANCES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_GOVERNANCES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);

  TYPE gvev_tbl_type IS TABLE OF gvev_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE rgpv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_RULE_GROUPS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    rgd_code                       OKC_RULE_GROUPS_V.RGD_CODE%TYPE := OKC_API.G_MISS_CHAR,
    sat_code                       OKC_RULE_GROUPS_V.SAT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    rgp_type                       OKC_RULE_GROUPS_V.RGP_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    parent_rgp_id                  NUMBER := OKC_API.G_MISS_NUM,
    comments                       OKC_RULE_GROUPS_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_RULE_GROUPS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_RULE_GROUPS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_RULE_GROUPS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_RULE_GROUPS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_RULE_GROUPS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_RULE_GROUPS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_RULE_GROUPS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_RULE_GROUPS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_RULE_GROUPS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_RULE_GROUPS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_RULE_GROUPS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_RULE_GROUPS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_RULE_GROUPS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_RULE_GROUPS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_RULE_GROUPS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_RULE_GROUPS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_RULE_GROUPS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_RULE_GROUPS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);

  TYPE rgpv_tbl_type IS TABLE OF rgpv_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE rmpv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    rgp_id                         NUMBER := OKC_API.G_MISS_NUM,
    rrd_id                         NUMBER := OKC_API.G_MISS_NUM,
    cpl_id                         NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_RG_PARTY_ROLES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_RG_PARTY_ROLES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);

  TYPE rmpv_tbl_type IS TABLE OF rmpv_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE ctcv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    cpl_id                         NUMBER := OKC_API.G_MISS_NUM,
    cro_code                       OKC_CONTACTS_V.CRO_CODE%TYPE := OKC_API.G_MISS_CHAR,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    contact_sequence               NUMBER := OKC_API.G_MISS_NUM,
    object1_id1                    OKC_CONTACTS_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKC_CONTACTS_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object1_code              OKC_CONTACTS_V.jtot_object1_code%TYPE:= OKC_API.G_MISS_CHAR,
    attribute_category             OKC_CONTACTS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_CONTACTS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_CONTACTS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_CONTACTS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_CONTACTS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_CONTACTS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_CONTACTS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_CONTACTS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_CONTACTS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_CONTACTS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_CONTACTS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_CONTACTS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_CONTACTS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_CONTACTS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_CONTACTS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_CONTACTS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_CONTACTS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_CONTACTS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    start_date                     OKC_CONTACTS_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKC_CONTACTS_V.END_DATE%TYPE := OKC_API.G_MISS_DATE);

  TYPE ctcv_tbl_type IS TABLE OF ctcv_rec_type
        INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------------
G_API_TYPE        VARCHAR2(10) := '_PVT';



--start ashish
  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  chrv_rec_type,
    x_chrv_rec                     OUT NOCOPY  chrv_rec_type);


  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chrv_rec                     IN chrv_rec_type,
    x_chrv_rec                     OUT NOCOPY chrv_rec_type);


  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN chrv_rec_type);


  PROCEDURE lock_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN chrv_rec_type);


  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN chrv_rec_type);


  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2 DEFAULT 'F',
    p_clev_rec                     IN  clev_rec_type,
    x_clev_rec                     OUT NOCOPY  clev_rec_type);

  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2 DEFAULT 'F',
    p_clev_tbl                     IN clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type);

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_clev_rec                     IN clev_rec_type,
    x_clev_rec                     OUT NOCOPY clev_rec_type);

    PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_clev_tbl                     IN clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type);


  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN clev_rec_type);

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN clev_tbl_type);



  PROCEDURE lock_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN clev_rec_type);


  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN clev_rec_type);


  PROCEDURE create_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY gvev_rec_type);


  PROCEDURE update_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY gvev_rec_type);


  PROCEDURE delete_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type);


  PROCEDURE lock_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type);


  PROCEDURE validate_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type);



--end ashish
--------------------------------------------------------------------------------
--start badri

PROCEDURE version_contract(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
        p_cvmv_rec          IN cvmv_rec_type,
    p_commit            IN VARCHAR2 DEFAULT OKC_API.G_TRUE,
        x_cvmv_rec          OUT NOCOPY cvmv_rec_type);

PROCEDURE version_contract(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
        p_cvmv_tbl          IN cvmv_tbl_type,
    p_commit            IN VARCHAR2 DEFAULT OKC_API.G_TRUE,
        x_cvmv_tbl          OUT NOCOPY cvmv_tbl_type);
---------------------------------------------------------------------------------------

  procedure create_contract_item(p_api_version  IN  NUMBER,
                              p_init_msg_list   IN  VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status   OUT NOCOPY  VARCHAR2,
                              x_msg_count   OUT NOCOPY  NUMBER,
                              x_msg_data    OUT NOCOPY  VARCHAR2,
                              p_cimv_rec    IN  cimv_rec_type,
                              x_cimv_rec    OUT NOCOPY  cimv_rec_type);


  procedure create_contract_item(p_api_version  IN  NUMBER,
                              p_init_msg_list   IN  VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status   OUT NOCOPY  VARCHAR2,
                              x_msg_count   OUT NOCOPY  NUMBER,
                              x_msg_data    OUT NOCOPY  VARCHAR2,
                              p_cimv_tbl    IN  cimv_tbl_type,
                              x_cimv_tbl    OUT NOCOPY  cimv_tbl_type);

  PROCEDURE update_contract_item(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_rec                     IN  cimv_rec_type,
    x_cimv_rec                     OUT NOCOPY cimv_rec_type);

  procedure update_contract_item(p_api_version  IN  NUMBER,
                              p_init_msg_list   IN  VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status   OUT NOCOPY  VARCHAR2,
                              x_msg_count   OUT NOCOPY  NUMBER,
                              x_msg_data    OUT NOCOPY  VARCHAR2,
                              p_cimv_tbl    IN  cimv_tbl_type,
                              x_cimv_tbl    OUT NOCOPY  cimv_tbl_type);


  PROCEDURE delete_contract_item(
    p_api_version   IN  NUMBER,
    p_init_msg_list IN  VARCHAR2 default OKC_API.G_FALSE,
    x_return_status OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    p_cimv_rec      IN  cimv_rec_type);

  procedure delete_contract_item(p_api_version  IN  NUMBER,
                              p_init_msg_list   IN  VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status   OUT NOCOPY  VARCHAR2,
                              x_msg_count   OUT NOCOPY  NUMBER,
                              x_msg_data    OUT NOCOPY  VARCHAR2,
                              p_cimv_tbl    IN  cimv_tbl_type);

  PROCEDURE create_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN  cplv_rec_type,
    x_cplv_rec                     OUT NOCOPY cplv_rec_type);

  PROCEDURE create_k_party_role(
    p_api_version   IN  NUMBER,
    p_init_msg_list IN  VARCHAR2 default OKC_API.G_FALSE,
    x_return_status OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    p_cplv_tbl      IN  cplv_tbl_type,
    x_cplv_tbl      OUT NOCOPY  cplv_tbl_type);

  PROCEDURE update_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN  cplv_rec_type,
    x_cplv_rec                     OUT NOCOPY cplv_rec_type);

  PROCEDURE update_k_party_role(
    p_api_version   IN  NUMBER,
    p_init_msg_list IN  VARCHAR2 default OKC_API.G_FALSE,
    x_return_status OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    p_cplv_tbl      IN  cplv_tbl_type,
    x_cplv_tbl      OUT NOCOPY  cplv_tbl_type);

  PROCEDURE delete_k_party_role(
    p_api_version   IN  NUMBER,
    p_init_msg_list IN  VARCHAR2 default OKC_API.G_FALSE,
    x_return_status OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    p_cplv_rec      IN  cplv_rec_type);

  PROCEDURE delete_k_party_role(
    p_api_version   IN  NUMBER,
    p_init_msg_list IN  VARCHAR2 default OKC_API.G_FALSE,
    x_return_status OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    p_cplv_tbl      IN  cplv_tbl_type);

  PROCEDURE create_contact(
    p_api_version   IN  NUMBER,
    p_init_msg_list IN  VARCHAR2 default OKC_API.G_FALSE,
    x_return_status OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    p_ctcv_rec      IN  ctcv_rec_type,
    x_ctcv_rec      OUT NOCOPY  ctcv_rec_type);

  PROCEDURE create_contact(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_ctcv_tbl      IN  ctcv_tbl_type,
    x_ctcv_tbl      OUT NOCOPY  ctcv_tbl_type);

  PROCEDURE update_contact(
    p_api_version    IN NUMBER,
    p_init_msg_list  IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    p_ctcv_rec       IN ctcv_rec_type,
    x_ctcv_rec       OUT NOCOPY ctcv_rec_type);

  PROCEDURE update_contact(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_ctcv_tbl      IN  ctcv_tbl_type,
    x_ctcv_tbl      OUT NOCOPY  ctcv_tbl_type);

  PROCEDURE delete_contact(
    p_api_version   IN  NUMBER,
    p_init_msg_list IN  VARCHAR2 default OKC_API.G_FALSE,
    x_return_status OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    p_ctcv_rec      IN  ctcv_rec_type);

  PROCEDURE delete_contact(
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_ctcv_tbl      IN  ctcv_tbl_type);

--end badri
------------------------------------------------------------------------------
--start cklee
  PROCEDURE create_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type);

  PROCEDURE update_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type);

  PROCEDURE delete_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type);

  PROCEDURE lock_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type);

  PROCEDURE validate_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type);


  PROCEDURE create_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type,
    x_rmpv_rec                     OUT NOCOPY rmpv_rec_type);

  PROCEDURE update_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type,
    x_rmpv_rec                     OUT NOCOPY rmpv_rec_type);

  PROCEDURE delete_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type);

  PROCEDURE lock_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type);

  PROCEDURE validate_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type);

--end cklee
END OKL_OKC_MIGRATION_PVT;

/
