--------------------------------------------------------
--  DDL for Package OKL_TAI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TAI_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTAIS.pls 120.7 2007/11/06 07:30:20 dcshanmu noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE tai_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    currency_code                  OKL_TRX_AR_INVOICES_B.CURRENCY_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    currency_conversion_type       OKL_TRX_AR_INVOICES_B.currency_conversion_type%TYPE := Okl_Api.G_MISS_CHAR,
    currency_conversion_rate       OKL_TRX_AR_INVOICES_B.currency_conversion_rate%TYPE := Okl_Api.G_MISS_NUM,
    currency_conversion_date       OKL_TRX_AR_INVOICES_B.currency_conversion_date%TYPE := Okl_Api.G_MISS_DATE,
    ibt_id                         NUMBER := Okl_Api.G_MISS_NUM,
    ixx_id                         NUMBER := Okl_Api.G_MISS_NUM,
    khr_id                         NUMBER := Okl_Api.G_MISS_NUM,
    irm_id                         NUMBER := Okl_Api.G_MISS_NUM,
    irt_id                         NUMBER := Okl_Api.G_MISS_NUM,
    cra_id                         NUMBER := Okl_Api.G_MISS_NUM,
    svf_id                         NUMBER := Okl_Api.G_MISS_NUM,
    tap_id                         NUMBER := Okl_Api.G_MISS_NUM,
    qte_id                         NUMBER := Okl_Api.G_MISS_NUM,
    tcn_id                         NUMBER := Okl_Api.G_MISS_NUM,
    tai_id_reverses                NUMBER := Okl_Api.G_MISS_NUM,
    ipy_id                         NUMBER := Okl_Api.G_MISS_NUM, --Added after postgen changes
    trx_status_code                OKL_TRX_AR_INVOICES_B.TRX_STATUS_CODE%TYPE := Okl_Api.G_MISS_CHAR,
	set_of_books_id                NUMBER := Okl_Api.G_MISS_NUM, --Added after postgen changes
	try_id                         NUMBER := Okl_Api.G_MISS_NUM, --Added after postgen changes
    date_entered                   OKL_TRX_AR_INVOICES_B.DATE_ENTERED%TYPE := Okl_Api.G_MISS_DATE,
    date_invoiced                  OKL_TRX_AR_INVOICES_B.DATE_INVOICED%TYPE := Okl_Api.G_MISS_DATE,
    amount                         NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    amount_applied                 NUMBER := Okl_Api.G_MISS_NUM,
    request_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_Api.G_MISS_NUM,
    program_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_update_date            OKL_TRX_AR_INVOICES_B.PROGRAM_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
	TRX_NUMBER					   OKL_TRX_AR_INVOICES_B.TRX_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
	CLG_ID						   NUMBER := Okl_Api.G_MISS_NUM,
	POX_ID						   NUMBER := Okl_Api.G_MISS_NUM,
	CPY_ID						   NUMBER := Okl_Api.G_MISS_NUM,
    attribute_category             OKL_TRX_AR_INVOICES_B.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_TRX_AR_INVOICES_B.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_TRX_AR_INVOICES_B.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_TRX_AR_INVOICES_B.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_TRX_AR_INVOICES_B.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_TRX_AR_INVOICES_B.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_TRX_AR_INVOICES_B.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_TRX_AR_INVOICES_B.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_TRX_AR_INVOICES_B.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_TRX_AR_INVOICES_B.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_TRX_AR_INVOICES_B.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_TRX_AR_INVOICES_B.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_TRX_AR_INVOICES_B.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_TRX_AR_INVOICES_B.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_TRX_AR_INVOICES_B.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_TRX_AR_INVOICES_B.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_TRX_AR_INVOICES_B.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_TRX_AR_INVOICES_B.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM,
    legal_entity_id                OKL_TRX_AR_INVOICES_B.LEGAL_ENTITY_ID%TYPE := Okl_Api.G_MISS_NUM, -- for LE Uptake project 08-11-2006


-- start:30-Jan-07 cklee  Billing R12 project
    Investor_Agreement_Number     OKL_TRX_AR_INVOICES_B.Investor_Agreement_Number%TYPE := Okl_Api.G_MISS_CHAR,
    Investor_Name                 OKL_TRX_AR_INVOICES_B.Investor_Name%TYPE := Okl_Api.G_MISS_CHAR,
    OKL_SOURCE_BILLING_TRX        OKL_TRX_AR_INVOICES_B.OKL_SOURCE_BILLING_TRX%TYPE := Okl_Api.G_MISS_CHAR,
    INF_ID                        OKL_TRX_AR_INVOICES_B.INF_ID%TYPE := Okl_Api.G_MISS_NUM,
    INVOICE_PULL_YN               OKL_TRX_AR_INVOICES_B.INVOICE_PULL_YN%TYPE := Okl_Api.G_MISS_CHAR,
    CONSOLIDATED_INVOICE_NUMBER   OKL_TRX_AR_INVOICES_B.CONSOLIDATED_INVOICE_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    DUE_DATE                      OKL_TRX_AR_INVOICES_B.DUE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    ISI_ID                        OKL_TRX_AR_INVOICES_B.ISI_ID%TYPE := Okl_Api.G_MISS_NUM,
    RECEIVABLES_INVOICE_ID        OKL_TRX_AR_INVOICES_B.RECEIVABLES_INVOICE_ID%TYPE := Okl_Api.G_MISS_NUM,
--start: 26-02-07 gkhuntet  Insufficient assignment.
    CUST_TRX_TYPE_ID              NUMBER := Okl_Api.G_MISS_NUM,
    CUSTOMER_BANK_ACCOUNT_ID      NUMBER := Okl_Api.G_MISS_NUM,
--end: 26-02-07 gkhuntet
    TAX_EXEMPT_FLAG               OKL_TRX_AR_INVOICES_B.TAX_EXEMPT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    TAX_EXEMPT_REASON_CODE        OKL_TRX_AR_INVOICES_B.TAX_EXEMPT_REASON_CODE%TYPE := Okl_Api.G_MISS_CHAR,
--start: 26-02-07 gkhuntet  Insufficient assignment.
    REFERENCE_LINE_ID             NUMBER  := Okl_Api.G_MISS_NUM,

    PRIVATE_LABEL                 OKL_TRX_AR_INVOICES_B.PRIVATE_LABEL%TYPE := Okl_Api.G_MISS_CHAR,
--end: 26-02-07 gkhuntet
-- end: 30-Jan-07 cklee  Billing R12 project
 --gkhuntet start 02-Nov-07
    TRANSACTION_DATE              OKL_TRX_AR_INVOICES_B.TRANSACTION_DATE%TYPE := Okl_Api.G_MISS_DATE
 --gkhuntet end 02-Nov-07
);
  g_miss_tai_rec                          tai_rec_type;
  TYPE tai_tbl_type IS TABLE OF tai_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OklTrxArInvoicesTlRecType IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    LANGUAGE                       OKL_TRX_AR_INVOICES_TL.LANGUAGE%TYPE := Okl_Api.G_MISS_CHAR,
    source_lang                    OKL_TRX_AR_INVOICES_TL.SOURCE_LANG%TYPE := Okl_Api.G_MISS_CHAR,
    sfwt_flag                      OKL_TRX_AR_INVOICES_TL.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_TRX_AR_INVOICES_TL.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_TRX_AR_INVOICES_TL.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_TRX_AR_INVOICES_TL.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  GMissOklTrxArInvoicesTlRec              OklTrxArInvoicesTlRecType;
  TYPE OklTrxArInvoicesTlTblType IS TABLE OF OklTrxArInvoicesTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE taiv_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    sfwt_flag                      OKL_TRX_AR_INVOICES_V.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    currency_code                  OKL_TRX_AR_INVOICES_V.CURRENCY_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    currency_conversion_type       OKL_TRX_AR_INVOICES_B.currency_conversion_type%TYPE := Okl_Api.G_MISS_CHAR,
    currency_conversion_rate       OKL_TRX_AR_INVOICES_B.currency_conversion_rate%TYPE := Okl_Api.G_MISS_NUM,
    currency_conversion_date       OKL_TRX_AR_INVOICES_B.currency_conversion_date%TYPE := Okl_Api.G_MISS_DATE,
    khr_id                         NUMBER := Okl_Api.G_MISS_NUM,
    cra_id                         NUMBER := Okl_Api.G_MISS_NUM,
    tap_id                         NUMBER := Okl_Api.G_MISS_NUM,
    qte_id                         NUMBER := Okl_Api.G_MISS_NUM,
    tcn_id                         NUMBER := Okl_Api.G_MISS_NUM,
    tai_id_reverses                NUMBER := Okl_Api.G_MISS_NUM,
    ipy_id                         NUMBER := Okl_Api.G_MISS_NUM,
    trx_status_code                OKL_TRX_AR_INVOICES_B.TRX_STATUS_CODE%TYPE := Okl_Api.G_MISS_CHAR,
	set_of_books_id                NUMBER := Okl_Api.G_MISS_NUM, --Added after postgen changes
	try_id                         NUMBER := Okl_Api.G_MISS_NUM, --Added after postgen changes
    ibt_id                         NUMBER := Okl_Api.G_MISS_NUM,
    ixx_id                         NUMBER := Okl_Api.G_MISS_NUM,
    irm_id                         NUMBER := Okl_Api.G_MISS_NUM,
    irt_id                         NUMBER := Okl_Api.G_MISS_NUM,
    svf_id                         NUMBER := Okl_Api.G_MISS_NUM,
    amount                         NUMBER := Okl_Api.G_MISS_NUM,
    date_invoiced                  OKL_TRX_AR_INVOICES_V.DATE_INVOICED%TYPE := Okl_Api.G_MISS_DATE,
    amount_applied                 NUMBER := Okl_Api.G_MISS_NUM,
    description                    OKL_TRX_AR_INVOICES_V.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
	TRX_NUMBER					   OKL_TRX_AR_INVOICES_B.TRX_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
	CLG_ID						   NUMBER := Okl_Api.G_MISS_NUM,
	POX_ID						   NUMBER := Okl_Api.G_MISS_NUM,
	CPY_ID						   NUMBER := Okl_Api.G_MISS_NUM,
    attribute_category             OKL_TRX_AR_INVOICES_V.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_TRX_AR_INVOICES_V.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_TRX_AR_INVOICES_V.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_TRX_AR_INVOICES_V.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_TRX_AR_INVOICES_V.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_TRX_AR_INVOICES_V.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_TRX_AR_INVOICES_V.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_TRX_AR_INVOICES_V.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_TRX_AR_INVOICES_V.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_TRX_AR_INVOICES_V.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_TRX_AR_INVOICES_V.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_TRX_AR_INVOICES_V.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_TRX_AR_INVOICES_V.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_TRX_AR_INVOICES_V.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_TRX_AR_INVOICES_V.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_TRX_AR_INVOICES_V.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    date_entered                   OKL_TRX_AR_INVOICES_V.DATE_ENTERED%TYPE := Okl_Api.G_MISS_DATE,
    request_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_Api.G_MISS_NUM,
    program_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_update_date            OKL_TRX_AR_INVOICES_V.PROGRAM_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_TRX_AR_INVOICES_V.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_TRX_AR_INVOICES_V.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM,
    legal_entity_id                OKL_TRX_AR_INVOICES_V.LEGAL_ENTITY_ID%TYPE := Okl_Api.G_MISS_NUM, -- for LE Uptake project 08-11-2006

-- start:30-Jan-07 cklee  Billing R12 project
    Investor_Agreement_Number     OKL_TRX_AR_INVOICES_B.Investor_Agreement_Number%TYPE := Okl_Api.G_MISS_CHAR,
    Investor_Name                 OKL_TRX_AR_INVOICES_B.Investor_Name%TYPE := Okl_Api.G_MISS_CHAR,
    OKL_SOURCE_BILLING_TRX        OKL_TRX_AR_INVOICES_B.OKL_SOURCE_BILLING_TRX%TYPE := Okl_Api.G_MISS_CHAR,
    INF_ID                        OKL_TRX_AR_INVOICES_B.INF_ID%TYPE := Okl_Api.G_MISS_NUM,
    INVOICE_PULL_YN               OKL_TRX_AR_INVOICES_B.INVOICE_PULL_YN%TYPE := Okl_Api.G_MISS_CHAR,
    DUE_DATE                      OKL_TRX_AR_INVOICES_B.DUE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    CONSOLIDATED_INVOICE_NUMBER   OKL_TRX_AR_INVOICES_B.CONSOLIDATED_INVOICE_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    ISI_ID                        OKL_TRX_AR_INVOICES_B.ISI_ID%TYPE := Okl_Api.G_MISS_NUM,
    RECEIVABLES_INVOICE_ID        OKL_TRX_AR_INVOICES_B.RECEIVABLES_INVOICE_ID%TYPE := Okl_Api.G_MISS_NUM,
--start: 26-02-07 gkhuntet  Insufficient assignment.
    CUST_TRX_TYPE_ID              NUMBER := Okl_Api.G_MISS_NUM,
    CUSTOMER_BANK_ACCOUNT_ID      NUMBER := Okl_Api.G_MISS_NUM,
--end: 26-02-07 gkhuntet      OKL_TRX_AR_INVOICES_B.CUSTOMER_BANK_ACCOUNT_ID%TYPE := Okl_Api.G_MISS_NUM,
    TAX_EXEMPT_FLAG               OKL_TRX_AR_INVOICES_B.TAX_EXEMPT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    TAX_EXEMPT_REASON_CODE        OKL_TRX_AR_INVOICES_B.TAX_EXEMPT_REASON_CODE%TYPE := Okl_Api.G_MISS_CHAR,
--start: 26-02-07 gkhuntet  Insufficient assignment.
    REFERENCE_LINE_ID             NUMBER  := Okl_Api.G_MISS_NUM,
--end: 26-02-07 gkhuntet
    PRIVATE_LABEL                 OKL_TRX_AR_INVOICES_B.PRIVATE_LABEL%TYPE := Okl_Api.G_MISS_CHAR,
--end: 26-02-07 gkhuntet
-- end: 30-Jan-07 cklee  Billing R12 project
 --gkhuntet start 02-Nov-07
    TRANSACTION_DATE              OKL_TRX_AR_INVOICES_B.TRANSACTION_DATE%TYPE := Okl_Api.G_MISS_DATE
 --gkhuntet end 02-Nov-07
);

  g_miss_taiv_rec                         taiv_rec_type;
  TYPE taiv_tbl_type IS TABLE OF taiv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okl_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okc_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := Okl_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TAI_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

  /******************ADDED AFTER TAPI, Sunil T. Mathew (04/16/2001) ****************/
  --GLOBAL MESSAGES
   G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
   G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
   G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
   G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
   G_NOT_SAME              		CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';


--GLOBAL VARIABLES
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_TRX_AR_INVOICES_V';
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
    p_taiv_rec                     IN taiv_rec_type,
    x_taiv_rec                     OUT NOCOPY taiv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_tbl                     IN taiv_tbl_type,
    x_taiv_tbl                     OUT NOCOPY taiv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_rec                     IN taiv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_tbl                     IN taiv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_rec                     IN taiv_rec_type,
    x_taiv_rec                     OUT NOCOPY taiv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_tbl                     IN taiv_tbl_type,
    x_taiv_tbl                     OUT NOCOPY taiv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_rec                     IN taiv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_tbl                     IN taiv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_rec                     IN taiv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taiv_tbl                     IN taiv_tbl_type);

END Okl_Tai_Pvt;

/
