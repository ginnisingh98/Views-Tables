--------------------------------------------------------
--  DDL for Package OKL_XPI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_XPI_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSXPIS.pls 120.3 2007/02/28 00:09:51 ssiruvol noship $ */
  ---------------------------------------------------------------------------
  -- PostGen --
  -- SPEC:
  -- 0. Global Messages (5) and Variables (2) = Done!
  -- 06/01/00: Post postgen changes
  --           Added 1 new column: TRX_STATUS_CODE
  -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
  --           Added New column : Legal entity Id
  -- BODY:
  -- 1. Check for Not Null Primary Keys
  -- 2. Check for Not Null Foreign Keys
  -- 5. Validity of Foreign Keys, where applicable
  -- 4. Validity of Unique Keys, where applicable
  -- 3. Validity of Org_id, where applicable
  -- 6. Added domain validation, where applicable
  -- 7. Added the Concurrent Manager Columns ( p104 )
  -- 8. Any lookup code should be validated using the OKL_UTIL package.
  -- 9. 02/04/02: Added new columns vendor_invoice_number, pay_group_lookup_code, nettable_yn.
  -- 10. Added New column : Legal entity Id : 30-OCT-2006 ANSETHUR  R12B - Legal Entity
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE xpi_rec_type IS RECORD (
    id                             NUMBER := OKL_API.G_MISS_NUM,
    invoice_id                     NUMBER := OKL_API.G_MISS_NUM,
    object_version_number          NUMBER := OKL_API.G_MISS_NUM,
    trx_status_code                OKL_EXT_PAY_INVS_B.TRX_STATUS_CODE%TYPE := OKL_API.G_MISS_CHAR,  -- Post postgen add column
    invoice_num                    OKL_EXT_PAY_INVS_B.INVOICE_NUM%TYPE := OKL_API.G_MISS_CHAR,
    invoice_type                   OKL_EXT_PAY_INVS_B.INVOICE_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    invoice_date                   OKL_EXT_PAY_INVS_B.INVOICE_DATE%TYPE := OKL_API.G_MISS_DATE,
    vendor_id                      NUMBER := OKL_API.G_MISS_NUM,
    vendor_site_id                 NUMBER := OKL_API.G_MISS_NUM,
    invoice_amount                 NUMBER := OKL_API.G_MISS_NUM,
    invoice_currency_code          OKL_EXT_PAY_INVS_B.INVOICE_CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR,
    terms_id                       NUMBER := OKL_API.G_MISS_NUM,
    workflow_flag                  OKL_EXT_PAY_INVS_B.WORKFLOW_FLAG%TYPE := OKL_API.G_MISS_CHAR,
    doc_category_code              OKL_EXT_PAY_INVS_B.DOC_CATEGORY_CODE%TYPE := OKL_API.G_MISS_CHAR,
    payment_method                 OKL_EXT_PAY_INVS_B.PAYMENT_METHOD%TYPE := OKL_API.G_MISS_CHAR,
    gl_date                        OKL_EXT_PAY_INVS_B.GL_DATE%TYPE := OKL_API.G_MISS_DATE,
    accts_pay_cc_id                NUMBER := OKL_API.G_MISS_NUM,
    pay_alone_flag                 OKL_EXT_PAY_INVS_B.PAY_ALONE_FLAG%TYPE := OKL_API.G_MISS_CHAR,
    wait_vendor_invoice_yn         OKL_EXT_PAY_INVS_B.WAIT_VENDOR_INVOICE_YN%TYPE := OKL_API.G_MISS_CHAR,
    payables_invoice_id            NUMBER := OKL_API.G_MISS_NUM,
    request_id                     NUMBER := OKL_API.G_MISS_NUM,
    program_application_id         NUMBER := OKL_API.G_MISS_NUM,
    program_id                     NUMBER := OKL_API.G_MISS_NUM,
    program_update_date            OKL_EXT_PAY_INVS_B.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    org_id                         NUMBER := OKL_API.G_MISS_NUM,
    CURRENCY_CONVERSION_TYPE       OKL_EXT_PAY_INVS_B.CURRENCY_CONVERSION_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    CURRENCY_CONVERSION_RATE       NUMBER := OKL_API.G_MISS_NUM,
    CURRENCY_CONVERSION_DATE       OKL_EXT_PAY_INVS_B.CURRENCY_CONVERSION_DATE%TYPE := OKL_API.G_MISS_DATE,
    attribute_category             OKL_EXT_PAY_INVS_B.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR,
    attribute1                     OKL_EXT_PAY_INVS_B.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR,
    attribute2                     OKL_EXT_PAY_INVS_B.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR,
    attribute3                     OKL_EXT_PAY_INVS_B.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR,
    attribute4                     OKL_EXT_PAY_INVS_B.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR,
    attribute5                     OKL_EXT_PAY_INVS_B.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR,
    attribute6                     OKL_EXT_PAY_INVS_B.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR,
    attribute7                     OKL_EXT_PAY_INVS_B.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR,
    attribute8                     OKL_EXT_PAY_INVS_B.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR,
    attribute9                     OKL_EXT_PAY_INVS_B.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR,
    attribute10                    OKL_EXT_PAY_INVS_B.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR,
    attribute11                    OKL_EXT_PAY_INVS_B.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR,
    attribute12                    OKL_EXT_PAY_INVS_B.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR,
    attribute13                    OKL_EXT_PAY_INVS_B.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR,
    attribute14                    OKL_EXT_PAY_INVS_B.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR,
    attribute15                    OKL_EXT_PAY_INVS_B.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR,
    created_by                     NUMBER := OKL_API.G_MISS_NUM,
    creation_date                  OKL_EXT_PAY_INVS_B.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKL_API.G_MISS_NUM,
    last_update_date               OKL_EXT_PAY_INVS_B.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER := OKL_API.G_MISS_NUM,
    pay_group_lookup_code          OKL_EXT_PAY_INVS_B.PAY_GROUP_LOOKUP_CODE%TYPE,
    vendor_invoice_number          OKL_EXT_PAY_INVS_B.VENDOR_INVOICE_NUMBER%TYPE,
    nettable_yn                    OKL_EXT_PAY_INVS_B.NETTABLE_YN%TYPE,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
    legal_entity_id                OKL_EXT_PAY_INVS_B.legal_entity_id%TYPE := OKL_API.G_MISS_NUM,
    CNSLD_AP_INV_ID                OKL_EXT_PAY_INVS_B.CNSLD_AP_INV_ID%TYPE := OKL_API.G_MISS_NUM);
  g_miss_xpi_rec                          xpi_rec_type;
  TYPE xpi_tbl_type IS TABLE OF xpi_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_ext_pay_invs_tl_rec_type IS RECORD (
    id                             NUMBER := OKL_API.G_MISS_NUM,
    language                       OKL_EXT_PAY_INVS_TL.LANGUAGE%TYPE := OKL_API.G_MISS_CHAR,
    source_lang                    OKL_EXT_PAY_INVS_TL.SOURCE_LANG%TYPE := OKL_API.G_MISS_CHAR,
    sfwt_flag                      OKL_EXT_PAY_INVS_TL.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR,
    description                    OKL_EXT_PAY_INVS_TL.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR,
    source                         OKL_EXT_PAY_INVS_TL.SOURCE%TYPE := OKL_API.G_MISS_CHAR,
    stream_type                    OKL_EXT_PAY_INVS_TL.STREAM_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    created_by                     NUMBER := OKL_API.G_MISS_NUM,
    creation_date                  OKL_EXT_PAY_INVS_TL.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKL_API.G_MISS_NUM,
    last_update_date               OKL_EXT_PAY_INVS_TL.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  g_miss_okl_ext_pay_invs_tl_rec          okl_ext_pay_invs_tl_rec_type;
  TYPE okl_ext_pay_invs_tl_tbl_type IS TABLE OF okl_ext_pay_invs_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE xpiv_rec_type IS RECORD (
    id                             NUMBER := OKL_API.G_MISS_NUM,
    object_version_number          NUMBER := OKL_API.G_MISS_NUM,
    sfwt_flag                      OKL_EXT_PAY_INVS_V.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR,
    trx_status_code                OKL_EXT_PAY_INVS_V.TRX_STATUS_CODE%TYPE := OKL_API.G_MISS_CHAR,   -- Post postgen add column
    invoice_id                     NUMBER := OKL_API.G_MISS_NUM,
    invoice_num                    OKL_EXT_PAY_INVS_V.INVOICE_NUM%TYPE := OKL_API.G_MISS_CHAR,
    invoice_type                   OKL_EXT_PAY_INVS_V.INVOICE_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    invoice_date                   OKL_EXT_PAY_INVS_V.INVOICE_DATE%TYPE := OKL_API.G_MISS_DATE,
    vendor_id                      NUMBER := OKL_API.G_MISS_NUM,
    vendor_site_id                 NUMBER := OKL_API.G_MISS_NUM,
    invoice_amount                 NUMBER := OKL_API.G_MISS_NUM,
    invoice_currency_code          OKL_EXT_PAY_INVS_V.INVOICE_CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR,
    terms_id                       NUMBER := OKL_API.G_MISS_NUM,
    description                    OKL_EXT_PAY_INVS_V.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR,
    source                         OKL_EXT_PAY_INVS_V.SOURCE%TYPE := OKL_API.G_MISS_CHAR,
    workflow_flag                  OKL_EXT_PAY_INVS_V.WORKFLOW_FLAG%TYPE := OKL_API.G_MISS_CHAR,
    doc_category_code              OKL_EXT_PAY_INVS_V.DOC_CATEGORY_CODE%TYPE := OKL_API.G_MISS_CHAR,
    payment_method                 OKL_EXT_PAY_INVS_V.PAYMENT_METHOD%TYPE := OKL_API.G_MISS_CHAR,
    gl_date                        OKL_EXT_PAY_INVS_V.GL_DATE%TYPE := OKL_API.G_MISS_DATE,
    accts_pay_cc_id                NUMBER := OKL_API.G_MISS_NUM,
    pay_alone_flag                 OKL_EXT_PAY_INVS_V.PAY_ALONE_FLAG%TYPE := OKL_API.G_MISS_CHAR,
    wait_vendor_invoice_yn         OKL_EXT_PAY_INVS_V.WAIT_VENDOR_INVOICE_YN%TYPE := OKL_API.G_MISS_CHAR,
    stream_type                    OKL_EXT_PAY_INVS_V.STREAM_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    payables_invoice_id            NUMBER := OKL_API.G_MISS_NUM,
    CURRENCY_CONVERSION_TYPE       OKL_EXT_PAY_INVS_V.CURRENCY_CONVERSION_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    CURRENCY_CONVERSION_RATE       NUMBER := OKL_API.G_MISS_NUM,
    CURRENCY_CONVERSION_DATE       OKL_EXT_PAY_INVS_V.CURRENCY_CONVERSION_DATE%TYPE := OKL_API.G_MISS_DATE,
    attribute_category             OKL_EXT_PAY_INVS_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR,
    attribute1                     OKL_EXT_PAY_INVS_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR,
    attribute2                     OKL_EXT_PAY_INVS_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR,
    attribute3                     OKL_EXT_PAY_INVS_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR,
    attribute4                     OKL_EXT_PAY_INVS_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR,
    attribute5                     OKL_EXT_PAY_INVS_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR,
    attribute6                     OKL_EXT_PAY_INVS_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR,
    attribute7                     OKL_EXT_PAY_INVS_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR,
    attribute8                     OKL_EXT_PAY_INVS_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR,
    attribute9                     OKL_EXT_PAY_INVS_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR,
    attribute10                    OKL_EXT_PAY_INVS_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR,
    attribute11                    OKL_EXT_PAY_INVS_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR,
    attribute12                    OKL_EXT_PAY_INVS_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR,
    attribute13                    OKL_EXT_PAY_INVS_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR,
    attribute14                    OKL_EXT_PAY_INVS_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR,
    attribute15                    OKL_EXT_PAY_INVS_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR,
    request_id                     NUMBER := OKL_API.G_MISS_NUM,
    program_application_id         NUMBER := OKL_API.G_MISS_NUM,
    program_id                     NUMBER := OKL_API.G_MISS_NUM,
    program_update_date            OKL_EXT_PAY_INVS_V.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    org_id                         NUMBER := OKL_API.G_MISS_NUM,
    created_by                     NUMBER := OKL_API.G_MISS_NUM,
    creation_date                  OKL_EXT_PAY_INVS_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKL_API.G_MISS_NUM,
    last_update_date               OKL_EXT_PAY_INVS_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER := OKL_API.G_MISS_NUM,
    pay_group_lookup_code          OKL_EXT_PAY_INVS_V.PAY_GROUP_LOOKUP_CODE%TYPE,
    vendor_invoice_number          OKL_EXT_PAY_INVS_V.VENDOR_INVOICE_NUMBER%TYPE,
    nettable_yn                    OKL_EXT_PAY_INVS_V.NETTABLE_YN%TYPE,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
    legal_entity_id                OKL_EXT_PAY_INVS_B.legal_entity_id%TYPE := OKL_API.G_MISS_NUM,
    CNSLD_AP_INV_ID                OKL_EXT_PAY_INVS_B.CNSLD_AP_INV_ID%TYPE := OKL_API.G_MISS_NUM
    );
  g_miss_xpiv_rec                         xpiv_rec_type;
  TYPE xpiv_tbl_type IS TABLE OF xpiv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  -- PostGen-Begin-0
  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) :='OKL_UNEXPECTED_ERROR';
  G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) :='OKL_NO_PARENT_RECORD';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) :='ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) :='ERROR_CODE';
  G_NOT_SAME                   CONSTANT   VARCHAR2(200) :='OKL_CANNOT_BE_SAME';
  -- PostGen-End-0
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_XPI_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  -- Post-Gen Begin-0
  G_VIEW   	  		    CONSTANT   VARCHAR2(30) := 'OKL_EXT_PAY_INVS_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;
  -- Post-Gen End-0
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_rec                     IN xpiv_rec_type,
    x_xpiv_rec                     OUT NOCOPY xpiv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_tbl                     IN xpiv_tbl_type,
    x_xpiv_tbl                     OUT NOCOPY xpiv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_rec                     IN xpiv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_tbl                     IN xpiv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_rec                     IN xpiv_rec_type,
    x_xpiv_rec                     OUT NOCOPY xpiv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_tbl                     IN xpiv_tbl_type,
    x_xpiv_tbl                     OUT NOCOPY xpiv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_rec                     IN xpiv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_tbl                     IN xpiv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_rec                     IN xpiv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xpiv_tbl                     IN xpiv_tbl_type);

END OKL_XPI_PVT;

/
