--------------------------------------------------------
--  DDL for Package OKL_XSI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_XSI_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSXSIS.pls 120.3 2006/11/17 10:22:08 zrehman noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE xsi_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    isi_id                         NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    receivables_invoice_id         NUMBER := Okl_Api.G_MISS_NUM,
    set_of_books_id                NUMBER := Okl_Api.G_MISS_NUM,
    trx_date                       OKL_EXT_SELL_INVS_B.TRX_DATE%TYPE := Okl_Api.G_MISS_DATE,
    currency_code                  OKL_EXT_SELL_INVS_B.CURRENCY_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    currency_conversion_type       OKL_EXT_SELL_INVS_B.currency_conversion_type%TYPE := Okl_Api.G_MISS_CHAR,
    currency_conversion_rate       OKL_EXT_SELL_INVS_B.currency_conversion_rate%TYPE := Okl_Api.G_MISS_NUM,
    currency_conversion_date       OKL_EXT_SELL_INVS_B.currency_conversion_date%TYPE := Okl_Api.G_MISS_DATE,
    customer_id                    NUMBER := Okl_Api.G_MISS_NUM,
    receipt_method_id              NUMBER := Okl_Api.G_MISS_NUM,
    term_id                        NUMBER := Okl_Api.G_MISS_NUM,
    customer_address_id            NUMBER := Okl_Api.G_MISS_NUM,
    cust_trx_type_id               NUMBER := Okl_Api.G_MISS_NUM,
    request_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_Api.G_MISS_NUM,
    program_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_update_date            OKL_EXT_SELL_INVS_B.PROGRAM_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    REFERENCE_LINE_ID              NUMBER := Okl_Api.G_MISS_NUM,
    CUSTOMER_BANK_ACCOUNT_ID       NUMBER := Okl_Api.G_MISS_NUM,
    TRX_NUMBER                     OKL_EXT_SELL_INVS_B.TRX_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    inf_id                         NUMBER := Okl_Api.G_MISS_NUM,
/*      khr_id                         NUMBER := Okl_Api.G_MISS_NUM,          */
/*      clg_id                         NUMBER := Okl_Api.G_MISS_NUM,      */
/*      cpy_id                         NUMBER := Okl_Api.G_MISS_NUM,      */
/*      qte_id                         NUMBER := Okl_Api.G_MISS_NUM,                  */
    attribute_category             OKL_EXT_SELL_INVS_B.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_EXT_SELL_INVS_B.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_EXT_SELL_INVS_B.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_EXT_SELL_INVS_B.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_EXT_SELL_INVS_B.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_EXT_SELL_INVS_B.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_EXT_SELL_INVS_B.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_EXT_SELL_INVS_B.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_EXT_SELL_INVS_B.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_EXT_SELL_INVS_B.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_EXT_SELL_INVS_B.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_EXT_SELL_INVS_B.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_EXT_SELL_INVS_B.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_EXT_SELL_INVS_B.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_EXT_SELL_INVS_B.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_EXT_SELL_INVS_B.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_EXT_SELL_INVS_B.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_EXT_SELL_INVS_B.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM,
    trx_status_code                OKL_EXT_SELL_INVS_B.TRX_STATUS_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    tax_exempt_flag                OKL_EXT_SELL_INVS_B.TAX_EXEMPT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    tax_exempt_reason_code         OKL_EXT_SELL_INVS_B.TAX_EXEMPT_REASON_CODE%TYPE:= Okl_Api.G_MISS_CHAR,
    xtrx_invoice_pull_yn           OKL_EXT_SELL_INVS_B.XTRX_INVOICE_PULL_YN%TYPE := Okl_Api.G_MISS_CHAR,
    legal_entity_id                OKL_EXT_SELL_INVS_B.LEGAL_ENTITY_ID%TYPE := Okl_Api.G_MISS_NUM -- for LE Uptake project 08-11-2006
	);
  g_miss_xsi_rec                          xsi_rec_type;
  TYPE xsi_tbl_type IS TABLE OF xsi_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_ext_sell_invs_tl_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    LANGUAGE                       OKL_EXT_SELL_INVS_TL.LANGUAGE%TYPE := Okl_Api.G_MISS_CHAR,
    source_lang                    OKL_EXT_SELL_INVS_TL.SOURCE_LANG%TYPE := Okl_Api.G_MISS_CHAR,
    sfwt_flag                      OKL_EXT_SELL_INVS_TL.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    xtrx_cons_invoice_number       OKL_EXT_SELL_INVS_TL.XTRX_CONS_INVOICE_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    xtrx_format_type               OKL_EXT_SELL_INVS_TL.XTRX_FORMAT_TYPE%TYPE := Okl_Api.G_MISS_CHAR,
    xtrx_private_label             OKL_EXT_SELL_INVS_TL.XTRX_PRIVATE_LABEL%TYPE := Okl_Api.G_MISS_CHAR,
    invoice_message                OKL_EXT_SELL_INVS_TL.INVOICE_MESSAGE%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_EXT_SELL_INVS_TL.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_EXT_SELL_INVS_TL.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_EXT_SELL_INVS_TL.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  GMissOklExtSellInvsTlRec                okl_ext_sell_invs_tl_rec_type;
  TYPE okl_ext_sell_invs_tl_tbl_type IS TABLE OF okl_ext_sell_invs_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE xsiv_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    sfwt_flag                      OKL_EXT_SELL_INVS_V.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    isi_id                         NUMBER := Okl_Api.G_MISS_NUM,
    trx_date                       OKL_EXT_SELL_INVS_V.TRX_DATE%TYPE := Okl_Api.G_MISS_DATE,
    customer_id                    NUMBER := Okl_Api.G_MISS_NUM,
    receipt_method_id              NUMBER := Okl_Api.G_MISS_NUM,
    term_id                        NUMBER := Okl_Api.G_MISS_NUM,
    currency_code                  OKL_EXT_SELL_INVS_V.CURRENCY_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    currency_conversion_type       OKL_EXT_SELL_INVS_V.currency_conversion_type%TYPE := Okl_Api.G_MISS_CHAR,
    currency_conversion_rate       OKL_EXT_SELL_INVS_V.currency_conversion_rate%TYPE := Okl_Api.G_MISS_NUM,
    currency_conversion_date       OKL_EXT_SELL_INVS_V.currency_conversion_date%TYPE := Okl_Api.G_MISS_DATE,
    customer_address_id            NUMBER := Okl_Api.G_MISS_NUM,
    set_of_books_id                NUMBER := Okl_Api.G_MISS_NUM,
    receivables_invoice_id         NUMBER := Okl_Api.G_MISS_NUM,
    cust_trx_type_id               NUMBER := Okl_Api.G_MISS_NUM,
    invoice_message                OKL_EXT_SELL_INVS_V.INVOICE_MESSAGE%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_EXT_SELL_INVS_V.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    xtrx_cons_invoice_number       OKL_EXT_SELL_INVS_V.XTRX_CONS_INVOICE_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    xtrx_format_type               OKL_EXT_SELL_INVS_V.XTRX_FORMAT_TYPE%TYPE := Okl_Api.G_MISS_CHAR,
    xtrx_private_label             OKL_EXT_SELL_INVS_V.XTRX_PRIVATE_LABEL%TYPE := Okl_Api.G_MISS_CHAR,
    REFERENCE_LINE_ID              NUMBER := Okl_Api.G_MISS_NUM,
    CUSTOMER_BANK_ACCOUNT_ID       NUMBER := Okl_Api.G_MISS_NUM,
    TRX_NUMBER                     OKL_EXT_SELL_INVS_V.TRX_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    inf_id                         NUMBER := Okl_Api.G_MISS_NUM,
/*      khr_id                         NUMBER := Okl_Api.G_MISS_NUM,       */
/*      clg_id                         NUMBER := Okl_Api.G_MISS_NUM,      */
/*      cpy_id                         NUMBER := Okl_Api.G_MISS_NUM,      */
/*      qte_id                         NUMBER := Okl_Api.G_MISS_NUM,                         */
    attribute_category             OKL_EXT_SELL_INVS_V.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_EXT_SELL_INVS_V.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_EXT_SELL_INVS_V.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_EXT_SELL_INVS_V.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_EXT_SELL_INVS_V.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_EXT_SELL_INVS_V.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_EXT_SELL_INVS_V.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_EXT_SELL_INVS_V.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_EXT_SELL_INVS_V.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_EXT_SELL_INVS_V.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_EXT_SELL_INVS_V.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_EXT_SELL_INVS_V.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_EXT_SELL_INVS_V.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_EXT_SELL_INVS_V.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_EXT_SELL_INVS_V.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_EXT_SELL_INVS_V.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    request_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_Api.G_MISS_NUM,
    program_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_update_date            OKL_EXT_SELL_INVS_V.PROGRAM_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_EXT_SELL_INVS_V.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_EXT_SELL_INVS_V.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM,
    trx_status_code                OKL_EXT_SELL_INVS_B.TRX_STATUS_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    tax_exempt_flag                OKL_EXT_SELL_INVS_B.TAX_EXEMPT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    tax_exempt_reason_code         OKL_EXT_SELL_INVS_B.TAX_EXEMPT_REASON_CODE%TYPE:= Okl_Api.G_MISS_CHAR,
    xtrx_invoice_pull_yn           OKL_EXT_SELL_INVS_B.XTRX_INVOICE_PULL_YN%TYPE := Okl_Api.G_MISS_CHAR,
    legal_entity_id                OKL_EXT_SELL_INVS_B.LEGAL_ENTITY_ID%TYPE := Okl_Api.G_MISS_NUM -- for LE Uptake project 08-11-2006
	);

  g_miss_xsiv_rec                         xsiv_rec_type;
  TYPE xsiv_tbl_type IS TABLE OF xsiv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okl_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okl_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okl_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_XSI_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

/******************ADDED AFTER TAPI, Sunil T. Mathew (04/16/2001) ****************/
  --GLOBAL MESSAGES
   G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
   G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
   G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
   G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
   G_NOT_SAME              		CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';


--GLOBAL VARIABLES
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_EXT_SELL_INVS_V';
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
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_rec                     IN xsiv_rec_type,
    x_xsiv_rec                     OUT NOCOPY xsiv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_tbl                     IN xsiv_tbl_type,
    x_xsiv_tbl                     OUT NOCOPY xsiv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_rec                     IN xsiv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_tbl                     IN xsiv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_rec                     IN xsiv_rec_type,
    x_xsiv_rec                     OUT NOCOPY xsiv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_tbl                     IN xsiv_tbl_type,
    x_xsiv_tbl                     OUT NOCOPY xsiv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_rec                     IN xsiv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_tbl                     IN xsiv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_rec                     IN xsiv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xsiv_tbl                     IN xsiv_tbl_type);

END Okl_Xsi_Pvt;

/
