--------------------------------------------------------
--  DDL for Package OKL_TLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TLD_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTLDS.pls 120.6 2007/03/22 18:21:34 cklee ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE tld_rec_type IS RECORD (
    id                             NUMBER := Okl_api.G_MISS_NUM,
    bch_id                         NUMBER := Okl_api.G_MISS_NUM,
    bcl_id                         NUMBER := Okl_api.G_MISS_NUM,
    bsl_id                         NUMBER := Okl_api.G_MISS_NUM,
    bgh_id                         NUMBER := Okl_api.G_MISS_NUM,
    idx_id                         NUMBER := Okl_api.G_MISS_NUM,
    sel_id                         NUMBER := Okl_api.G_MISS_NUM,
    sty_id                         NUMBER := Okl_api.G_MISS_NUM,
    til_id_details                 NUMBER := Okl_api.G_MISS_NUM,
    tld_id_reverses                NUMBER := Okl_api.G_MISS_NUM,
    line_detail_number             NUMBER := Okl_api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_api.G_MISS_NUM,
    late_charge_yn                 OKL_TXD_AR_LN_DTLS_B.LATE_CHARGE_YN%TYPE := Okl_api.G_MISS_CHAR,
    date_calculation               OKL_TXD_AR_LN_DTLS_B.DATE_CALCULATION%TYPE := Okl_api.G_MISS_DATE,
    fixed_rate_yn                  OKL_TXD_AR_LN_DTLS_B.FIXED_RATE_YN%TYPE := Okl_api.G_MISS_CHAR,
    amount                         NUMBER := Okl_api.G_MISS_NUM,
    receivables_invoice_id         NUMBER := Okl_api.G_MISS_NUM,
    amount_applied                 NUMBER := Okl_api.G_MISS_NUM,
    request_id                     NUMBER := Okl_api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_api.G_MISS_NUM,
    program_id                     NUMBER := Okl_api.G_MISS_NUM,
    program_update_date            OKL_TXD_AR_LN_DTLS_B.PROGRAM_UPDATE_DATE%TYPE := Okl_api.G_MISS_DATE,
    org_id                         NUMBER := Okl_api.G_MISS_NUM,
    inventory_org_id                         NUMBER := Okl_Api.G_MISS_NUM,
-- Start changes on remarketing by fmiao on 10/18/04 --
    inventory_item_id              NUMBER := Okl_api.G_MISS_NUM,
-- End changes on remarketing by fmiao on 10/18/04 --
    attribute_category             OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE_CATEGORY%TYPE := Okl_api.G_MISS_CHAR,
    attribute1                     OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE1%TYPE := Okl_api.G_MISS_CHAR,
    attribute2                     OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE2%TYPE := Okl_api.G_MISS_CHAR,
    attribute3                     OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE3%TYPE := Okl_api.G_MISS_CHAR,
    attribute4                     OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE4%TYPE := Okl_api.G_MISS_CHAR,
    attribute5                     OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE5%TYPE := Okl_api.G_MISS_CHAR,
    attribute6                     OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE6%TYPE := Okl_api.G_MISS_CHAR,
    attribute7                     OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE7%TYPE := Okl_api.G_MISS_CHAR,
    attribute8                     OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE8%TYPE := Okl_api.G_MISS_CHAR,
    attribute9                     OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE9%TYPE := Okl_api.G_MISS_CHAR,
    attribute10                    OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE10%TYPE := Okl_api.G_MISS_CHAR,
    attribute11                    OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE11%TYPE := Okl_api.G_MISS_CHAR,
    attribute12                    OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE12%TYPE := Okl_api.G_MISS_CHAR,
    attribute13                    OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE13%TYPE := Okl_api.G_MISS_CHAR,
    attribute14                    OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE14%TYPE := Okl_api.G_MISS_CHAR,
    attribute15                    OKL_TXD_AR_LN_DTLS_B.ATTRIBUTE15%TYPE := Okl_api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_api.G_MISS_NUM,
    creation_date                  OKL_TXD_AR_LN_DTLS_B.CREATION_DATE%TYPE := Okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_api.G_MISS_NUM,
    last_update_date               OKL_TXD_AR_LN_DTLS_B.LAST_UPDATE_DATE%TYPE := Okl_api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_api.G_MISS_NUM,

--start: 30-Jan-07 cklee  Billing R12 project                             |
    TXL_AR_LINE_NUMBER              OKL_TXD_AR_LN_DTLS_B.TXL_AR_LINE_NUMBER%TYPE := Okl_api.G_MISS_NUM,
    INVOICE_FORMAT_TYPE            OKL_TXD_AR_LN_DTLS_B.INVOICE_FORMAT_TYPE%TYPE := Okl_api.G_MISS_CHAR,
    INVOICE_FORMAT_LINE_TYPE       OKL_TXD_AR_LN_DTLS_B.INVOICE_FORMAT_LINE_TYPE%TYPE := Okl_api.G_MISS_CHAR,
    LATE_CHARGE_ASSESS_DATE        OKL_TXD_AR_LN_DTLS_B.LATE_CHARGE_ASSESS_DATE%TYPE := Okl_api.G_MISS_DATE,
--start: 26-02-07 gkhuntet  Invalid assignment.
    LATE_INT_ASSESS_DATE           OKL_TXD_AR_LN_DTLS_B.LATE_INT_ASSESS_DATE%TYPE := Okl_api.G_MISS_DATE,
--end: 26-02-07 gkhuntet
    LATE_CHARGE_ASS_YN             OKL_TXD_AR_LN_DTLS_B.LATE_CHARGE_ASS_YN%TYPE := Okl_api.G_MISS_CHAR,
    LATE_INT_ASS_YN                OKL_TXD_AR_LN_DTLS_B.LATE_INT_ASS_YN%TYPE := Okl_api.G_MISS_CHAR,
    INVESTOR_DISB_STATUS           OKL_TXD_AR_LN_DTLS_B.INVESTOR_DISB_STATUS%TYPE := Okl_api.G_MISS_CHAR,
    INVESTOR_DISB_ERR_MG           OKL_TXD_AR_LN_DTLS_B.INVESTOR_DISB_ERR_MG%TYPE := Okl_api.G_MISS_CHAR,
    DATE_DISBURSED                 OKL_TXD_AR_LN_DTLS_B.DATE_DISBURSED%TYPE := Okl_api.G_MISS_DATE,
    PAY_STATUS_CODE                OKL_TXD_AR_LN_DTLS_B.PAY_STATUS_CODE%TYPE := Okl_api.G_MISS_CHAR,
    RBK_ORI_INVOICE_NUMBER         OKL_TXD_AR_LN_DTLS_B.RBK_ORI_INVOICE_NUMBER%TYPE := Okl_api.G_MISS_CHAR,
    RBK_ORI_INVOICE_LINE_NUMBER    OKL_TXD_AR_LN_DTLS_B.RBK_ORI_INVOICE_LINE_NUMBER%TYPE := Okl_api.G_MISS_CHAR,
    RBK_ADJUSTMENT_DATE            OKL_TXD_AR_LN_DTLS_B.RBK_ADJUSTMENT_DATE%TYPE := Okl_api.G_MISS_DATE,
--start: 26-02-07 gkhuntet  Invalid assignment.
   --KHR_ID                         OKL_TXD_AR_LN_DTLS_B.KHR_ID%TYPE := Okl_api.G_MISS_CHAR,
    KHR_ID                          OKL_TXD_AR_LN_DTLS_B.KHR_ID%TYPE := Okl_api.G_MISS_NUM,
    KLE_ID                          OKL_TXD_AR_LN_DTLS_B.KLE_ID%TYPE := Okl_api.G_MISS_NUM,
    TAX_AMOUNT                     NUMBER := Okl_api.G_MISS_NUM
--end: 26-02-07 gkhuntet
--end: 30-Jan-07 cklee  Billing R12 project                             |

);
  g_miss_tld_rec                          tld_rec_type;
  TYPE tld_tbl_type IS TABLE OF tld_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_txd_ar_ln_dtls_tl_rec_type IS RECORD (
    id                             NUMBER := Okl_api.G_MISS_NUM,
    LANGUAGE                       OKL_TXD_AR_LN_DTLS_TL.LANGUAGE%TYPE := Okl_api.G_MISS_CHAR,
    source_lang                    OKL_TXD_AR_LN_DTLS_TL.SOURCE_LANG%TYPE := Okl_api.G_MISS_CHAR,
    error_message                  OKL_TXD_AR_LN_DTLS_TL.ERROR_MESSAGE%TYPE := Okl_api.G_MISS_CHAR,
    sfwt_flag                      OKL_TXD_AR_LN_DTLS_TL.SFWT_FLAG%TYPE := Okl_api.G_MISS_CHAR,
    description                    OKL_TXD_AR_LN_DTLS_TL.DESCRIPTION%TYPE := Okl_api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_api.G_MISS_NUM,
    creation_date                  OKL_TXD_AR_LN_DTLS_TL.CREATION_DATE%TYPE := Okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_api.G_MISS_NUM,
    last_update_date               OKL_TXD_AR_LN_DTLS_TL.LAST_UPDATE_DATE%TYPE := Okl_api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_api.G_MISS_NUM);
  GMissOklTxdArLnDtlsTlRec                okl_txd_ar_ln_dtls_tl_rec_type;
  TYPE okl_txd_ar_ln_dtls_tl_tbl_type IS TABLE OF okl_txd_ar_ln_dtls_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE tldv_rec_type IS RECORD (
    id                             NUMBER := Okl_api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_api.G_MISS_NUM,
    error_message                  OKL_TXD_AR_LN_DTLS_TL.ERROR_MESSAGE%TYPE := Okl_api.G_MISS_CHAR,
    sfwt_flag                      OKL_TXD_AR_LN_DTLS_V.SFWT_FLAG%TYPE := Okl_api.G_MISS_CHAR,
    bch_id                         NUMBER := Okl_api.G_MISS_NUM,
    bgh_id                         NUMBER := Okl_api.G_MISS_NUM,
    idx_id                         NUMBER := Okl_api.G_MISS_NUM,
    tld_id_reverses                NUMBER := Okl_api.G_MISS_NUM,
    sty_id                         NUMBER := Okl_api.G_MISS_NUM,
    sel_id                         NUMBER := Okl_api.G_MISS_NUM,
    til_id_details                 NUMBER := Okl_api.G_MISS_NUM,
    bcl_id                         NUMBER := Okl_api.G_MISS_NUM,
    bsl_id                         NUMBER := Okl_api.G_MISS_NUM,
    amount                         NUMBER := Okl_api.G_MISS_NUM,
    line_detail_number             NUMBER := Okl_api.G_MISS_NUM,
    receivables_invoice_id         NUMBER := Okl_api.G_MISS_NUM,
    late_charge_yn                 OKL_TXD_AR_LN_DTLS_V.LATE_CHARGE_YN%TYPE := Okl_api.G_MISS_CHAR,
    description                    OKL_TXD_AR_LN_DTLS_V.DESCRIPTION%TYPE := Okl_api.G_MISS_CHAR,
    amount_applied                 NUMBER := Okl_api.G_MISS_NUM,
    date_calculation               OKL_TXD_AR_LN_DTLS_V.DATE_CALCULATION%TYPE := Okl_api.G_MISS_DATE,
    fixed_rate_yn                  OKL_TXD_AR_LN_DTLS_V.FIXED_RATE_YN%TYPE := Okl_api.G_MISS_CHAR,
-- Start changes on remarketing by fmiao on 10/18/04 --
    inventory_item_id              NUMBER := Okl_api.G_MISS_NUM,
-- End changes on remarketing by fmiao on 10/18/04 --
	attribute_category             OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE_CATEGORY%TYPE := Okl_api.G_MISS_CHAR,
    attribute1                     OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE1%TYPE := Okl_api.G_MISS_CHAR,
    attribute2                     OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE2%TYPE := Okl_api.G_MISS_CHAR,
    attribute3                     OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE3%TYPE := Okl_api.G_MISS_CHAR,
    attribute4                     OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE4%TYPE := Okl_api.G_MISS_CHAR,
    attribute5                     OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE5%TYPE := Okl_api.G_MISS_CHAR,
    attribute6                     OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE6%TYPE := Okl_api.G_MISS_CHAR,
    attribute7                     OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE7%TYPE := Okl_api.G_MISS_CHAR,
    attribute8                     OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE8%TYPE := Okl_api.G_MISS_CHAR,
    attribute9                     OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE9%TYPE := Okl_api.G_MISS_CHAR,
    attribute10                    OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE10%TYPE := Okl_api.G_MISS_CHAR,
    attribute11                    OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE11%TYPE := Okl_api.G_MISS_CHAR,
    attribute12                    OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE12%TYPE := Okl_api.G_MISS_CHAR,
    attribute13                    OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE13%TYPE := Okl_api.G_MISS_CHAR,
    attribute14                    OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE14%TYPE := Okl_api.G_MISS_CHAR,
    attribute15                    OKL_TXD_AR_LN_DTLS_V.ATTRIBUTE15%TYPE := Okl_api.G_MISS_CHAR,
    request_id                     NUMBER := Okl_api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_api.G_MISS_NUM,
    program_id                     NUMBER := Okl_api.G_MISS_NUM,
    program_update_date            OKL_TXD_AR_LN_DTLS_V.PROGRAM_UPDATE_DATE%TYPE := Okl_api.G_MISS_DATE,
    org_id                         NUMBER := Okl_api.G_MISS_NUM,
    inventory_org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    created_by                     NUMBER := Okl_api.G_MISS_NUM,
    creation_date                  OKL_TXD_AR_LN_DTLS_V.CREATION_DATE%TYPE := Okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_api.G_MISS_NUM,
    last_update_date               OKL_TXD_AR_LN_DTLS_V.LAST_UPDATE_DATE%TYPE := Okl_api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_api.G_MISS_NUM,

--start: 30-Jan-07 cklee  Billing R12 project                             |
    TXL_AR_LINE_NUMBER              OKL_TXD_AR_LN_DTLS_B.TXL_AR_LINE_NUMBER%TYPE := Okl_api.G_MISS_NUM,
    INVOICE_FORMAT_TYPE            OKL_TXD_AR_LN_DTLS_B.INVOICE_FORMAT_TYPE%TYPE := Okl_api.G_MISS_CHAR,
    INVOICE_FORMAT_LINE_TYPE       OKL_TXD_AR_LN_DTLS_B.INVOICE_FORMAT_LINE_TYPE%TYPE := Okl_api.G_MISS_CHAR,
    LATE_CHARGE_ASSESS_DATE        OKL_TXD_AR_LN_DTLS_B.LATE_CHARGE_ASSESS_DATE%TYPE := Okl_api.G_MISS_DATE,

--start: 26-02-07 gkhuntet  Invalid assignment.
    LATE_INT_ASSESS_DATE           OKL_TXD_AR_LN_DTLS_B.LATE_INT_ASSESS_DATE%TYPE := Okl_api.G_MISS_DATE,
--end: 26-02-07 gkhuntet

    LATE_CHARGE_ASS_YN             OKL_TXD_AR_LN_DTLS_B.LATE_CHARGE_ASS_YN%TYPE := Okl_api.G_MISS_CHAR,
    LATE_INT_ASS_YN                OKL_TXD_AR_LN_DTLS_B.LATE_INT_ASS_YN%TYPE := Okl_api.G_MISS_CHAR,
    INVESTOR_DISB_STATUS           OKL_TXD_AR_LN_DTLS_B.INVESTOR_DISB_STATUS%TYPE := Okl_api.G_MISS_CHAR,
    INVESTOR_DISB_ERR_MG           OKL_TXD_AR_LN_DTLS_B.INVESTOR_DISB_ERR_MG%TYPE := Okl_api.G_MISS_CHAR,
    DATE_DISBURSED                 OKL_TXD_AR_LN_DTLS_B.DATE_DISBURSED%TYPE := Okl_api.G_MISS_DATE,
    PAY_STATUS_CODE                OKL_TXD_AR_LN_DTLS_B.PAY_STATUS_CODE%TYPE := Okl_api.G_MISS_CHAR,
    RBK_ORI_INVOICE_NUMBER         OKL_TXD_AR_LN_DTLS_B.RBK_ORI_INVOICE_NUMBER%TYPE := Okl_api.G_MISS_CHAR,
    RBK_ORI_INVOICE_LINE_NUMBER    OKL_TXD_AR_LN_DTLS_B.RBK_ORI_INVOICE_LINE_NUMBER%TYPE := Okl_api.G_MISS_CHAR,
    RBK_ADJUSTMENT_DATE            OKL_TXD_AR_LN_DTLS_B.RBK_ADJUSTMENT_DATE%TYPE := Okl_api.G_MISS_DATE,
--start: 26-02-07 gkhuntet  Invalid assignment.
--KHR_ID                         OKL_TXD_AR_LN_DTLS_B.KHR_ID%TYPE := Okl_api.G_MISS_CHAR,
    KHR_ID                          OKL_TXD_AR_LN_DTLS_B.KHR_ID%TYPE := Okl_api.G_MISS_NUM,
    KLE_ID                          OKL_TXD_AR_LN_DTLS_B.KLE_ID%TYPE := Okl_api.G_MISS_NUM,
    TAX_AMOUNT                     NUMBER := Okl_api.G_MISS_NUM
--end: 26-02-07 gkhuntet
--end: 30-Jan-07 cklee  Billing R12 project                             |

);

  g_miss_tldv_rec                         tldv_rec_type;
  TYPE tldv_tbl_type IS TABLE OF tldv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okl_api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okl_api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okl_api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okl_api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okl_api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okl_api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okl_api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_api.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TLD_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_api.G_APP_NAME;

/******************ADDED AFTER TAPI, Sunil T. Mathew (04/16/2001) ****************/
  --GLOBAL MESSAGES
   G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
   G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
   G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
   G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
   G_NOT_SAME              		CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';


--GLOBAL VARIABLES
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_TXD_AR_LN_DTLS_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;

  ---------------------------------------------------------------------------
  -- validation Procedures and Functions
  ---------------------------------------------------------------------------
 --PROCEDURE validate_unique(p_saiv_rec 	IN 	saiv_rec_type,
 --                     x_return_status OUT NOCOPY VARCHAR2);

/****************END ADDED AFTER TAPI, Sunil T. Mathew (04/16/2001)**************/

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_rec                     IN tldv_rec_type,
    x_tldv_rec                     OUT NOCOPY tldv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_tbl                     IN tldv_tbl_type,
    x_tldv_tbl                     OUT NOCOPY tldv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_rec                     IN tldv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_tbl                     IN tldv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_rec                     IN tldv_rec_type,
    x_tldv_rec                     OUT NOCOPY tldv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_tbl                     IN tldv_tbl_type,
    x_tldv_tbl                     OUT NOCOPY tldv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_rec                     IN tldv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_tbl                     IN tldv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_rec                     IN tldv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tldv_tbl                     IN tldv_tbl_type);

END Okl_Tld_Pvt;

/
