--------------------------------------------------------
--  DDL for Package OKC_CLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CLE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSCLES.pls 120.8 2005/08/22 00:39:14 maanand noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE cle_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    line_number                    OKC_K_LINES_B.LINE_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id_renewed                 NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    display_sequence               NUMBER := OKC_API.G_MISS_NUM,
    sts_code                       OKC_K_LINES_B.STS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    trn_code                       OKC_K_LINES_B.TRN_CODE%TYPE := OKC_API.G_MISS_CHAR,
    lse_id                         NUMBER := OKC_API.G_MISS_NUM,
    exception_yn                   OKC_K_LINES_B.EXCEPTION_YN%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_LINES_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_LINES_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    hidden_ind                     OKC_K_LINES_B.HIDDEN_IND%TYPE := OKC_API.G_MISS_CHAR,
    price_unit			     NUMBER := OKC_API.G_MISS_NUM,
    price_unit_percent		     NUMBER := OKC_API.G_MISS_NUM,
    price_negotiated               NUMBER := OKC_API.G_MISS_NUM,
    price_level_ind                OKC_K_LINES_B.PRICE_LEVEL_IND%TYPE := OKC_API.G_MISS_CHAR,
    invoice_line_level_ind         OKC_K_LINES_B.INVOICE_LINE_LEVEL_IND%TYPE := OKC_API.G_MISS_CHAR,
    dpas_rating                    OKC_K_LINES_B.DPAS_RATING%TYPE := OKC_API.G_MISS_CHAR,
    template_used                  OKC_K_LINES_B.TEMPLATE_USED%TYPE := OKC_API.G_MISS_CHAR,
    price_type                     OKC_K_LINES_B.PRICE_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_code                  OKC_K_LINES_B.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    date_terminated                OKC_K_LINES_B.DATE_TERMINATED%TYPE := OKC_API.G_MISS_DATE,
    start_date                     OKC_K_LINES_B.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKC_K_LINES_B.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    date_renewed                   OKC_K_LINES_B.DATE_RENEWED%TYPE := OKC_API.G_MISS_DATE,
    upg_orig_system_ref            OKC_K_LINES_B.UPG_ORIG_SYSTEM_REF%TYPE := OKC_API.G_MISS_CHAR,
    upg_orig_system_ref_id         NUMBER := OKC_API.G_MISS_NUM,
    orig_system_source_code        OKC_K_LINES_B.ORIG_SYSTEM_SOURCE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
    orig_system_id1                NUMBER := OKC_API.G_MISS_NUM,
    orig_system_reference1         OKC_K_LINES_B.ORIG_SYSTEM_REFERENCE1%TYPE :=OKC_API.G_MISS_CHAR,
    attribute_category             OKC_K_LINES_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_K_LINES_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_K_LINES_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_K_LINES_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_K_LINES_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_K_LINES_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_K_LINES_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_K_LINES_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_K_LINES_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_K_LINES_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_K_LINES_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_K_LINES_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_K_LINES_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_K_LINES_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_K_LINES_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_K_LINES_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    cle_id_renewed_to		   NUMBER := OKC_API.G_MISS_NUM,
    currency_code_renewed	   OKC_K_LINES_B.CURRENCY_CODE_RENEWED%TYPE := OKC_API.G_MISS_CHAR,
    price_negotiated_renewed       NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKC_K_LINES_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    price_list_id                  NUMBER := OKC_API.G_MISS_NUM,
    pricing_date                   OKC_K_LINES_B.PRICING_DATE%TYPE := OKC_API.G_MISS_DATE,
    price_list_line_id             NUMBER := OKC_API.G_MISS_NUM,
    line_list_price                NUMBER := OKC_API.G_MISS_NUM,
    item_to_price_yn               OKC_K_LINES_B.ITEM_TO_PRICE_YN%TYPE := OKC_API.G_MISS_CHAR,
    price_basis_yn                 OKC_K_LINES_B.PRICE_BASIS_YN%TYPE := OKC_API.G_MISS_CHAR,
    config_header_id               NUMBER := OKC_API.G_MISS_NUM,
    config_revision_number         NUMBER := OKC_API.G_MISS_NUM,
    config_complete_yn             OKC_K_LINES_B.CONFIG_COMPLETE_YN%TYPE := OKC_API.G_MISS_CHAR,
    config_valid_yn                OKC_K_LINES_B.CONFIG_VALID_YN%TYPE := OKC_API.G_MISS_CHAR,
    config_top_model_line_id       NUMBER := OKC_API.G_MISS_NUM,
    config_item_type               OKC_K_LINES_B.CONFIG_ITEM_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    CONFIG_ITEM_ID                 NUMBER := OKC_API.G_MISS_NUM,
    service_item_yn                OKC_K_LINES_B.SERVICE_ITEM_YN%TYPE := OKC_API.G_MISS_CHAR,
    --new columns for price hold
    ph_pricing_type                OKC_K_LINES_B.PH_PRICING_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    ph_price_break_basis           OKC_K_LINES_B.PH_PRICE_BREAK_BASIS%TYPE := OKC_API.G_MISS_CHAR,
    ph_min_qty                     OKC_K_LINES_B.PH_MIN_QTY%TYPE := OKC_API.G_MISS_NUM,
    ph_min_amt                     OKC_K_LINES_B.PH_MIN_AMT%TYPE := OKC_API.G_MISS_NUM,
    ph_qp_reference_id             OKC_K_LINES_B.PH_QP_REFERENCE_ID%TYPE := OKC_API.G_MISS_NUM,
    ph_value                       OKC_K_LINES_B.PH_VALUE%TYPE := OKC_API.G_MISS_NUM,
    ph_enforce_price_list_yn       OKC_K_LINES_B.PH_ENFORCE_PRICE_LIST_YN%TYPE := OKC_API.G_MISS_CHAR,
    ph_adjustment                  OKC_K_LINES_B.PH_ADJUSTMENT%TYPE := OKC_API.G_MISS_NUM,
    ph_integrated_with_qp          OKC_K_LINES_B.PH_INTEGRATED_WITH_QP%TYPE := OKC_API.G_MISS_CHAR,
    --new columns to replace rules
    cust_acct_id                   NUMBER := OKC_API.G_MISS_NUM,
    bill_to_site_use_id            NUMBER := OKC_API.G_MISS_NUM,
    inv_rule_id                    NUMBER := OKC_API.G_MISS_NUM,
    line_renewal_type_code         OKC_K_LINES_B.LINE_RENEWAL_TYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
    ship_to_site_use_id            NUMBER := OKC_API.G_MISS_NUM,
    payment_term_id	               NUMBER :=OKC_API.G_MISS_NUM,
     --NPALEPU on 03-JUN-2005 Added new column for Annualized amounts Project.
    annualized_factor              OKC_K_LINES_B.ANNUALIZED_FACTOR%TYPE := OKC_API.G_MISS_NUM,
    -- Line level Cancellation --
    date_cancelled		  OKC_K_LINES_B.DATE_CANCELLED%TYPE := OKC_API.G_MISS_DATE,
    --canc_reason_code		  OKC_K_LINES_B.CANC_REASON_CODE%TYPE := OKC_API.G_MISS_CHAR,
    term_cancel_source		  OKC_K_LINES_B.TERM_CANCEL_SOURCE%TYPE := OKC_API.G_MISS_CHAR,
    cancelled_amount		  OKC_K_LINES_B.CANCELLED_AMOUNT%TYPE := OKC_API.G_MISS_NUM,
    payment_instruction_type      OKC_K_LINES_B.PAYMENT_INSTRUCTION_TYPE%TYPE := OKC_API.G_MISS_CHAR

);

  g_miss_cle_rec                          cle_rec_type;
  TYPE cle_tbl_type IS TABLE OF cle_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE okc_k_lines_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKC_K_LINES_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKC_K_LINES_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKC_K_LINES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_K_LINES_TL.NAME%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_K_LINES_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    item_description               OKC_K_LINES_TL.ITEM_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    oke_boe_description            OKC_K_LINES_TL.OKE_BOE_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    cognomen                       OKC_K_LINES_TL.COGNOMEN%TYPE := OKC_API.G_MISS_CHAR,
    block23text                    OKC_K_LINES_TL.BLOCK23TEXT%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_LINES_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_LINES_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);

  g_miss_okc_k_lines_tl_rec               okc_k_lines_tl_rec_type;
  TYPE okc_k_lines_tl_tbl_type IS TABLE OF okc_k_lines_tl_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE clev_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_K_LINES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id_renewed                 NUMBER := OKC_API.G_MISS_NUM,
    cle_id_renewed_to		   NUMBER := OKC_API.G_MISS_NUM,
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
    price_unit			   NUMBER := OKC_API.G_MISS_NUM,
    price_unit_percent		   NUMBER := OKC_API.G_MISS_NUM,
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
    currency_code_renewed	   OKC_K_LINES_V.CURRENCY_CODE_RENEWED%TYPE := OKC_API.G_MISS_CHAR,
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
    service_item_yn                OKC_K_LINES_V.SERVICE_ITEM_YN%TYPE := OKC_API.G_MISS_CHAR,
--new columns for price hold
    ph_pricing_type                OKC_K_LINES_V.PH_PRICING_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    ph_price_break_basis           OKC_K_LINES_V.PH_PRICE_BREAK_BASIS%TYPE := OKC_API.G_MISS_CHAR,
    ph_min_qty                     OKC_K_LINES_V.PH_MIN_QTY%TYPE := OKC_API.G_MISS_NUM,
    ph_min_amt                     OKC_K_LINES_V.PH_MIN_AMT%TYPE := OKC_API.G_MISS_NUM,
    ph_qp_reference_id             OKC_K_LINES_V.PH_QP_REFERENCE_ID%TYPE := OKC_API.G_MISS_NUM,
    ph_value                       OKC_K_LINES_V.PH_VALUE%TYPE := OKC_API.G_MISS_NUM,
    ph_enforce_price_list_yn       OKC_K_LINES_V.PH_ENFORCE_PRICE_LIST_YN%TYPE := OKC_API.G_MISS_CHAR,
    ph_adjustment                  OKC_K_LINES_V.PH_ADJUSTMENT%TYPE := OKC_API.G_MISS_NUM,
    ph_integrated_with_qp          OKC_K_LINES_V.PH_INTEGRATED_WITH_QP%TYPE := OKC_API.G_MISS_CHAR,

--new columns to replace rules
    cust_acct_id                   NUMBER := OKC_API.G_MISS_NUM,
    bill_to_site_use_id            NUMBER := OKC_API.G_MISS_NUM,
    inv_rule_id                    NUMBER := OKC_API.G_MISS_NUM,
    line_renewal_type_code         OKC_K_LINES_V.LINE_RENEWAL_TYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
    ship_to_site_use_id            NUMBER := OKC_API.G_MISS_NUM,
    payment_term_id                NUMBER :=OKC_API.G_MISS_NUM,
    VALIDATE_YN                    VARCHAR2(1) DEFAULT  'Y', --Bug#3150149.
    --- Line level Cancellation ---
    date_cancelled		   OKC_K_LINES_V.DATE_CANCELLED%TYPE := OKC_API.G_MISS_DATE,
    --canc_reason_code 		   OKC_K_LINES_V.CANC_REASON_CODE%TYPE := OKC_API.G_MISS_CHAR,
    term_cancel_source		   OKC_K_LINES_V.TERM_CANCEL_SOURCE%TYPE := OKC_API.G_MISS_CHAR,
    cancelled_amount		   OKC_K_LINES_V.CANCELLED_AMOUNT%TYPE := OKC_API.G_MISS_NUM,
    --R12 changes added by mchoudha--
    annualized_factor              OKC_K_LINES_B.ANNUALIZED_FACTOR%TYPE := OKC_API.G_MISS_NUM,
    payment_instruction_type      OKC_K_LINES_B.PAYMENT_INSTRUCTION_TYPE%TYPE := OKC_API.G_MISS_CHAR
   );
  g_miss_clev_rec                         clev_rec_type;
  TYPE clev_tbl_type IS TABLE OF clev_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CLE_PVT';
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
    p_clev_rec                     IN clev_rec_type,
    x_clev_rec                     OUT NOCOPY clev_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN clev_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN clev_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_clev_rec                     IN clev_rec_type,
    x_clev_rec                     OUT NOCOPY clev_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_clev_tbl                     IN clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN clev_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN clev_tbl_type);

  PROCEDURE force_delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN clev_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN clev_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN clev_tbl_type);

  PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2, p_clev_tbl clev_tbl_type);

  FUNCTION create_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

  FUNCTION restore_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

END OKC_CLE_PVT;

 

/
