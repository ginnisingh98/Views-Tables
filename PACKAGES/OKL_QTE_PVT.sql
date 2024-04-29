--------------------------------------------------------
--  DDL for Package OKL_QTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_QTE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSQTES.pls 120.3 2007/11/05 20:09:17 apaul noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE qte_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    qrs_code                       OKL_TRX_QUOTES_B.QRS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    qst_code                       OKL_TRX_QUOTES_B.QST_CODE%TYPE := OKC_API.G_MISS_CHAR,
    consolidated_qte_id            NUMBER := OKC_API.G_MISS_NUM,
    khr_id                         NUMBER := OKC_API.G_MISS_NUM,
    art_id                         NUMBER := OKC_API.G_MISS_NUM,
    qtp_code                       OKL_TRX_QUOTES_B.QTP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    trn_code                       OKL_TRX_QUOTES_B.TRN_CODE%TYPE := OKC_API.G_MISS_CHAR,
    pop_code_end                   OKL_TRX_QUOTES_B.POP_CODE_END%TYPE := OKC_API.G_MISS_CHAR,
    pop_code_early                 OKL_TRX_QUOTES_B.POP_CODE_EARLY%TYPE := OKC_API.G_MISS_CHAR,
    pdt_id                         NUMBER := OKC_API.G_MISS_NUM,
    date_effective_from            OKL_TRX_QUOTES_B.DATE_EFFECTIVE_FROM%TYPE := OKC_API.G_MISS_DATE,
    quote_number                   NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    purchase_percent               NUMBER := OKC_API.G_MISS_NUM,
    term                           NUMBER := OKC_API.G_MISS_NUM,
    date_restructure_start         OKL_TRX_QUOTES_B.DATE_RESTRUCTURE_START%TYPE := OKC_API.G_MISS_DATE,
    date_due                       OKL_TRX_QUOTES_B.DATE_DUE%TYPE := OKC_API.G_MISS_DATE,
    date_approved                  OKL_TRX_QUOTES_B.DATE_APPROVED%TYPE := OKC_API.G_MISS_DATE,
    date_restructure_end           OKL_TRX_QUOTES_B.DATE_RESTRUCTURE_END%TYPE := OKC_API.G_MISS_DATE,
    remaining_payments             NUMBER := OKC_API.G_MISS_NUM,
    rent_amount                    NUMBER := OKC_API.G_MISS_NUM,
    yield                          NUMBER := OKC_API.G_MISS_NUM,
    residual_amount                NUMBER := OKC_API.G_MISS_NUM,
    principal_paydown_amount       NUMBER := OKC_API.G_MISS_NUM,
    payment_frequency              OKL_TRX_QUOTES_B.PAYMENT_FREQUENCY%TYPE := OKC_API.G_MISS_CHAR,
    early_termination_yn           OKL_TRX_QUOTES_B.EARLY_TERMINATION_YN%TYPE := OKC_API.G_MISS_CHAR,
    partial_yn                     OKL_TRX_QUOTES_B.PARTIAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    preproceeds_yn                 OKL_TRX_QUOTES_B.PREPROCEEDS_YN%TYPE := OKC_API.G_MISS_CHAR,
    summary_format_yn              OKL_TRX_QUOTES_B.SUMMARY_FORMAT_YN%TYPE := OKC_API.G_MISS_CHAR,
    consolidated_yn                OKL_TRX_QUOTES_B.CONSOLIDATED_YN%TYPE := OKC_API.G_MISS_CHAR,
    date_requested                 OKL_TRX_QUOTES_B.DATE_REQUESTED%TYPE := OKC_API.G_MISS_DATE,
    date_proposal                  OKL_TRX_QUOTES_B.DATE_PROPOSAL%TYPE := OKC_API.G_MISS_DATE,
    date_effective_to              OKL_TRX_QUOTES_B.DATE_EFFECTIVE_TO%TYPE := OKC_API.G_MISS_DATE,
    date_accepted                  OKL_TRX_QUOTES_B.DATE_ACCEPTED%TYPE := OKC_API.G_MISS_DATE,
    payment_received_yn            OKL_TRX_QUOTES_B.PAYMENT_RECEIVED_YN%TYPE := OKC_API.G_MISS_CHAR,
    requested_by                   NUMBER := OKC_API.G_MISS_NUM,
    approved_yn                    OKL_TRX_QUOTES_B.APPROVED_YN%TYPE := OKC_API.G_MISS_CHAR,
    accepted_yn                    OKL_TRX_QUOTES_B.ACCEPTED_YN%TYPE := OKC_API.G_MISS_CHAR,
    date_payment_received          OKL_TRX_QUOTES_B.DATE_PAYMENT_RECEIVED%TYPE := OKC_API.G_MISS_DATE,
    approved_by                    NUMBER := OKC_API.G_MISS_NUM,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_TRX_QUOTES_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKL_TRX_QUOTES_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_TRX_QUOTES_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_TRX_QUOTES_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_TRX_QUOTES_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_TRX_QUOTES_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_TRX_QUOTES_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_TRX_QUOTES_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_TRX_QUOTES_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_TRX_QUOTES_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_TRX_QUOTES_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_TRX_QUOTES_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_TRX_QUOTES_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_TRX_QUOTES_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_TRX_QUOTES_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_TRX_QUOTES_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_TRX_QUOTES_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TRX_QUOTES_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TRX_QUOTES_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    purchase_amount                NUMBER := OKC_API.G_MISS_NUM,
    purchase_formula               OKL_TRX_QUOTES_B.PURCHASE_FORMULA%TYPE := OKC_API.G_MISS_CHAR,
    asset_value                    NUMBER := OKC_API.G_MISS_NUM,
    residual_value                 NUMBER := OKC_API.G_MISS_NUM,
    unbilled_receivables           NUMBER := OKC_API.G_MISS_NUM,
    gain_loss                      NUMBER := OKC_API.G_MISS_NUM,
    PERDIEM_AMOUNT                 NUMBER := OKC_API.G_MISS_NUM, -- SANAHUJA -- LOANS_ENHACEMENTS -- start -- end
-- BAKUCHIB - 2667636 - start
    currency_code                  OKL_TRX_QUOTES_B.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_code       OKL_TRX_QUOTES_B.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_TRX_QUOTES_B.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       OKL_TRX_QUOTES_B.CURRENCY_CONVERSION_RATE%TYPE := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_TRX_QUOTES_B.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE,
-- BAKUCHIB - 2667636 - End
    legal_entity_id                OKL_TRX_QUOTES_B.LEGAL_ENTITY_ID%TYPE := OKL_API.G_MISS_NUM,  --dkagrawa for LE Uptake
    repo_quote_indicator_yn        OKL_TRX_QUOTES_B.REPO_QUOTE_INDICATOR_YN%TYPE := OKL_API.G_MISS_CHAR -- AKP:REPO-QUOTE-START-END 6599890
   );

  g_miss_qte_rec                          qte_rec_type;
  TYPE qte_tbl_type IS TABLE OF qte_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_trx_quotes_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_TRX_QUOTES_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_TRX_QUOTES_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_TRX_QUOTES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKL_TRX_QUOTES_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TRX_QUOTES_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TRX_QUOTES_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_okl_trx_quotes_tl_rec            okl_trx_quotes_tl_rec_type;
  TYPE okl_trx_quotes_tl_tbl_type IS TABLE OF okl_trx_quotes_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE qtev_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKL_TRX_QUOTES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    qrs_code                       OKL_TRX_QUOTES_V.QRS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    qst_code                       OKL_TRX_QUOTES_V.QST_CODE%TYPE := OKC_API.G_MISS_CHAR,
    qtp_code                       OKL_TRX_QUOTES_V.QTP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    trn_code                       OKL_TRX_QUOTES_V.TRN_CODE%TYPE := OKC_API.G_MISS_CHAR,
    pop_code_end                   OKL_TRX_QUOTES_V.POP_CODE_END%TYPE := OKC_API.G_MISS_CHAR,
    pop_code_early                 OKL_TRX_QUOTES_V.POP_CODE_EARLY%TYPE := OKC_API.G_MISS_CHAR,
    consolidated_qte_id            NUMBER := OKC_API.G_MISS_NUM,
    khr_id                         NUMBER := OKC_API.G_MISS_NUM,
    art_id                         NUMBER := OKC_API.G_MISS_NUM,
    pdt_id                         NUMBER := OKC_API.G_MISS_NUM,
    early_termination_yn           OKL_TRX_QUOTES_V.EARLY_TERMINATION_YN%TYPE := OKC_API.G_MISS_CHAR,
    partial_yn                     OKL_TRX_QUOTES_V.PARTIAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    preproceeds_yn                 OKL_TRX_QUOTES_V.PREPROCEEDS_YN%TYPE := OKC_API.G_MISS_CHAR,
    date_requested                 OKL_TRX_QUOTES_V.DATE_REQUESTED%TYPE := OKC_API.G_MISS_DATE,
    date_proposal                  OKL_TRX_QUOTES_V.DATE_PROPOSAL%TYPE := OKC_API.G_MISS_DATE,
    date_effective_to              OKL_TRX_QUOTES_V.DATE_EFFECTIVE_TO%TYPE := OKC_API.G_MISS_DATE,
    date_accepted                  OKL_TRX_QUOTES_V.DATE_ACCEPTED%TYPE := OKC_API.G_MISS_DATE,
    summary_format_yn              OKL_TRX_QUOTES_V.SUMMARY_FORMAT_YN%TYPE := OKC_API.G_MISS_CHAR,
    consolidated_yn                OKL_TRX_QUOTES_V.CONSOLIDATED_YN%TYPE := OKC_API.G_MISS_CHAR,
    principal_paydown_amount       NUMBER := OKC_API.G_MISS_NUM,
    residual_amount                NUMBER := OKC_API.G_MISS_NUM,
    yield                          NUMBER := OKC_API.G_MISS_NUM,
    rent_amount                    NUMBER := OKC_API.G_MISS_NUM,
    date_restructure_end           OKL_TRX_QUOTES_V.DATE_RESTRUCTURE_END%TYPE := OKC_API.G_MISS_DATE,
    date_restructure_start         OKL_TRX_QUOTES_V.DATE_RESTRUCTURE_START%TYPE := OKC_API.G_MISS_DATE,
    term                           NUMBER := OKC_API.G_MISS_NUM,
    purchase_percent               NUMBER := OKC_API.G_MISS_NUM,
    comments                       OKL_TRX_QUOTES_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    date_due                       OKL_TRX_QUOTES_V.DATE_DUE%TYPE := OKC_API.G_MISS_DATE,
    payment_frequency              OKL_TRX_QUOTES_V.PAYMENT_FREQUENCY%TYPE := OKC_API.G_MISS_CHAR,
    remaining_payments             NUMBER := OKC_API.G_MISS_NUM,
    date_effective_from            OKL_TRX_QUOTES_V.DATE_EFFECTIVE_FROM%TYPE := OKC_API.G_MISS_DATE,
    quote_number                   NUMBER := OKC_API.G_MISS_NUM,
    requested_by                   NUMBER := OKC_API.G_MISS_NUM,
    approved_yn                    OKL_TRX_QUOTES_V.APPROVED_YN%TYPE := OKC_API.G_MISS_CHAR,
    accepted_yn                    OKL_TRX_QUOTES_V.ACCEPTED_YN%TYPE := OKC_API.G_MISS_CHAR,
    payment_received_yn            OKL_TRX_QUOTES_V.PAYMENT_RECEIVED_YN%TYPE := OKC_API.G_MISS_CHAR,
    date_payment_received          OKL_TRX_QUOTES_V.DATE_PAYMENT_RECEIVED%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKL_TRX_QUOTES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_TRX_QUOTES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_TRX_QUOTES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_TRX_QUOTES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_TRX_QUOTES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_TRX_QUOTES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_TRX_QUOTES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_TRX_QUOTES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_TRX_QUOTES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_TRX_QUOTES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_TRX_QUOTES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_TRX_QUOTES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_TRX_QUOTES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_TRX_QUOTES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_TRX_QUOTES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_TRX_QUOTES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    date_approved                  OKL_TRX_QUOTES_V.DATE_APPROVED%TYPE := OKC_API.G_MISS_DATE,
    approved_by                    NUMBER := OKC_API.G_MISS_NUM,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_TRX_QUOTES_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TRX_QUOTES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TRX_QUOTES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    purchase_amount                NUMBER := OKC_API.G_MISS_NUM,
    purchase_formula               OKL_TRX_QUOTES_V.PURCHASE_FORMULA%TYPE := OKC_API.G_MISS_CHAR,
    asset_value                    NUMBER := OKC_API.G_MISS_NUM,
    residual_value                 NUMBER := OKC_API.G_MISS_NUM,
    unbilled_receivables           NUMBER := OKC_API.G_MISS_NUM,
    gain_loss                      NUMBER := OKC_API.G_MISS_NUM,
    PERDIEM_AMOUNT                 NUMBER := OKC_API.G_MISS_NUM, -- SANAHUJA -- LOANS_ENHACEMENTS -- start -- end
-- BAKUCHIB - 2667636 - start
    currency_code                  OKL_TRX_QUOTES_B.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_code       OKL_TRX_QUOTES_B.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_TRX_QUOTES_B.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       OKL_TRX_QUOTES_B.CURRENCY_CONVERSION_RATE%TYPE := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_TRX_QUOTES_B.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE,
-- BAKUCHIB - 2667636 - end
    legal_entity_id                OKL_TRX_QUOTES_B.LEGAL_ENTITY_ID%TYPE := OKL_API.G_MISS_NUM,  --dkagrawa for LE Uptake
    repo_quote_indicator_yn        OKL_TRX_QUOTES_B.REPO_QUOTE_INDICATOR_YN%TYPE := OKL_API.G_MISS_CHAR -- AKP:REPO-QUOTE-START-END 6599890
   );
  g_miss_qtev_rec                         qtev_rec_type;
  TYPE qtev_tbl_type IS TABLE OF qtev_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_QTE_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
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
    p_qtev_rec                     IN qtev_rec_type,
    x_qtev_rec                     OUT NOCOPY qtev_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_tbl                     IN qtev_tbl_type,
    x_qtev_tbl                     OUT NOCOPY qtev_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_rec                     IN qtev_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_tbl                     IN qtev_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_rec                     IN qtev_rec_type,
    x_qtev_rec                     OUT NOCOPY qtev_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_tbl                     IN qtev_tbl_type,
    x_qtev_tbl                     OUT NOCOPY qtev_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_rec                     IN qtev_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_tbl                     IN qtev_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_rec                     IN qtev_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qtev_tbl                     IN qtev_tbl_type);

END OKL_QTE_PVT;

/
