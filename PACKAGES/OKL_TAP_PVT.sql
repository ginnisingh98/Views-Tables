--------------------------------------------------------
--  DDL for Package OKL_TAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TAP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTAPS.pls 120.4 2007/11/06 07:39:50 veramach noship $ */
  ---------------------------------------------------------------------------
  -- PostGen --
  -- SPEC:
  -- 0. Global Messages (5) and Variables (2) = Done!
  -- 06/01/00: Post postgen changes
  --           Removed all references to TRX_TYPE. This columns dropped from BD -- Post postgen changes
  --           Added 3 new columns: TRX_STATUS_CODE, SET_OF_BOOKS_ID, TRY_ID
  --           Renamed Combo_ID to code_combination_id
  --  30-OCT-2006 ANSETHUR  R12B - Legal Entity
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
  -- 9. 02/04/02: Added new columns vendor_invoice_number, pay_group_lookup_code,invoice_type, nettable_yn
  -- 10. Added New column : Legal entity Id : 30-OCT-2006 ANSETHUR  R12B - Legal Entity

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE tap_rec_type IS RECORD (
    id                             NUMBER := OKL_API.G_MISS_NUM,
    currency_code                  OKL_TRX_AP_INVOICES_B.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR,
    payment_method_code            OKL_TRX_AP_INVOICES_B.PAYMENT_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR,
    funding_type_code              OKL_TRX_AP_INVOICES_B.FUNDING_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR,
    invoice_category_code          OKL_TRX_AP_INVOICES_B.INVOICE_CATEGORY_CODE%TYPE := OKL_API.G_MISS_CHAR,
    ipvs_id                        NUMBER := OKL_API.G_MISS_NUM,
    khr_id                         NUMBER := OKL_API.G_MISS_NUM,
    ccf_id                         NUMBER := OKL_API.G_MISS_NUM,
    cct_id                         NUMBER := OKL_API.G_MISS_NUM,
    cplv_id                        NUMBER := OKL_API.G_MISS_NUM,
    pox_id                        NUMBER := OKL_API.G_MISS_NUM,
    ippt_id                        NUMBER := OKL_API.G_MISS_NUM,
    code_combination_id            NUMBER := OKL_API.G_MISS_NUM,
    qte_id                         NUMBER := OKL_API.G_MISS_NUM,
    art_id                         NUMBER := OKL_API.G_MISS_NUM,
    tcn_id                         NUMBER := OKL_API.G_MISS_NUM,
    vpa_id                         NUMBER := OKL_API.G_MISS_NUM,
    ipt_id                         NUMBER := OKL_API.G_MISS_NUM,
    tap_id_reverses                NUMBER := OKL_API.G_MISS_NUM,
    date_entered                   OKL_TRX_AP_INVOICES_B.DATE_ENTERED%TYPE := OKL_API.G_MISS_DATE,
    date_invoiced                  OKL_TRX_AP_INVOICES_B.DATE_INVOICED%TYPE := OKL_API.G_MISS_DATE,
    amount                         NUMBER := OKL_API.G_MISS_NUM,
    trx_status_code                OKL_TRX_AP_INVOICES_B.TRX_STATUS_CODE%TYPE := Okl_Api.G_MISS_CHAR, -- Post postgen changes
    set_of_books_id                NUMBER := Okl_Api.G_MISS_NUM, -- Post postgen changes
    try_id                         NUMBER := OKL_API.G_MISS_NUM, -- Post postgen changes
    object_version_number          NUMBER := OKL_API.G_MISS_NUM,
    date_requisition               OKL_TRX_AP_INVOICES_B.DATE_REQUISITION%TYPE := OKL_API.G_MISS_DATE,
    date_funding_approved          OKL_TRX_AP_INVOICES_B.DATE_FUNDING_APPROVED%TYPE := OKL_API.G_MISS_DATE,
    invoice_number                 OKL_TRX_AP_INVOICES_B.INVOICE_NUMBER%TYPE := OKL_API.G_MISS_CHAR,
    date_gl                        OKL_TRX_AP_INVOICES_B.DATE_GL%TYPE := OKL_API.G_MISS_DATE,
    workflow_yn                    OKL_TRX_AP_INVOICES_B.WORKFLOW_YN%TYPE := OKL_API.G_MISS_CHAR,
    match_required_yn              OKL_TRX_AP_INVOICES_B.MATCH_REQUIRED_YN%TYPE := OKL_API.G_MISS_CHAR,
    ipt_frequency                  OKL_TRX_AP_INVOICES_B.IPT_FREQUENCY%TYPE := OKL_API.G_MISS_CHAR,
    consolidate_yn                 OKL_TRX_AP_INVOICES_B.CONSOLIDATE_YN%TYPE := OKL_API.G_MISS_CHAR,
    wait_vendor_invoice_yn         OKL_TRX_AP_INVOICES_B.WAIT_VENDOR_INVOICE_YN%TYPE := OKL_API.G_MISS_CHAR,
    request_id                     NUMBER := OKL_API.G_MISS_NUM,
    program_application_id         NUMBER := OKL_API.G_MISS_NUM,
    program_id                     NUMBER := OKL_API.G_MISS_NUM,
    program_update_date            OKL_TRX_AP_INVOICES_B.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    org_id                         NUMBER := OKL_API.G_MISS_NUM,
    CURRENCY_CONVERSION_TYPE       OKL_TRX_AP_INVOICES_B.CURRENCY_CONVERSION_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    CURRENCY_CONVERSION_RATE       NUMBER := OKL_API.G_MISS_NUM,
    CURRENCY_CONVERSION_DATE       OKL_TRX_AP_INVOICES_B.CURRENCY_CONVERSION_DATE%TYPE := OKL_API.G_MISS_DATE,
    vendor_id                      OKL_TRX_AP_INVOICES_B.vendor_id%TYPE := OKL_API.G_MISS_NUM,
    attribute_category             OKL_TRX_AP_INVOICES_B.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR,
    attribute1                     OKL_TRX_AP_INVOICES_B.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR,
    attribute2                     OKL_TRX_AP_INVOICES_B.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR,
    attribute3                     OKL_TRX_AP_INVOICES_B.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR,
    attribute4                     OKL_TRX_AP_INVOICES_B.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR,
    attribute5                     OKL_TRX_AP_INVOICES_B.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR,
    attribute6                     OKL_TRX_AP_INVOICES_B.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR,
    attribute7                     OKL_TRX_AP_INVOICES_B.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR,
    attribute8                     OKL_TRX_AP_INVOICES_B.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR,
    attribute9                     OKL_TRX_AP_INVOICES_B.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR,
    attribute10                    OKL_TRX_AP_INVOICES_B.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR,
    attribute11                    OKL_TRX_AP_INVOICES_B.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR,
    attribute12                    OKL_TRX_AP_INVOICES_B.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR,
    attribute13                    OKL_TRX_AP_INVOICES_B.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR,
    attribute14                    OKL_TRX_AP_INVOICES_B.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR,
    attribute15                    OKL_TRX_AP_INVOICES_B.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR,
    created_by                     NUMBER := OKL_API.G_MISS_NUM,
    creation_date                  OKL_TRX_AP_INVOICES_B.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKL_API.G_MISS_NUM,
    last_update_date               OKL_TRX_AP_INVOICES_B.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER := OKL_API.G_MISS_NUM,
    invoice_type                   OKL_TRX_AP_INVOICES_B.invoice_type%TYPE,
    pay_group_lookup_code          OKL_TRX_AP_INVOICES_B.pay_group_lookup_code%TYPE,
    vendor_invoice_number          OKL_TRX_AP_INVOICES_B.vendor_invoice_number%TYPE,
    nettable_yn                    OKL_TRX_AP_INVOICES_B.nettable_yn%TYPE,
    ASSET_TAP_ID                   OKL_TRX_AP_INVOICES_B.ASSET_TAP_ID%TYPE := OKL_API.G_MISS_NUM,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
    legal_entity_id                OKL_TRX_AP_INVOICES_B.legal_entity_id%TYPE := OKL_API.G_MISS_NUM
    ,transaction_date              OKL_TRX_AP_INVOICES_B.transaction_date%TYPE := OKL_API.G_MISS_DATE
    );
  g_miss_tap_rec                          tap_rec_type;
  TYPE tap_tbl_type IS TABLE OF tap_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OklTrxApInvoicesTlRecType IS RECORD (
    id                             NUMBER := OKL_API.G_MISS_NUM,
    language                       OKL_TRX_AP_INVOICES_TL.LANGUAGE%TYPE := OKL_API.G_MISS_CHAR,
    source_lang                    OKL_TRX_AP_INVOICES_TL.SOURCE_LANG%TYPE := OKL_API.G_MISS_CHAR,
    sfwt_flag                      OKL_TRX_AP_INVOICES_TL.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR,
    description                    OKL_TRX_AP_INVOICES_TL.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR,
    created_by                     NUMBER := OKL_API.G_MISS_NUM,
    creation_date                  OKL_TRX_AP_INVOICES_TL.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKL_API.G_MISS_NUM,
    last_update_date               OKL_TRX_AP_INVOICES_TL.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  GMissOklTrxApInvoicesTlRec              OklTrxApInvoicesTlRecType;
  TYPE OklTrxApInvoicesTlTblType IS TABLE OF OklTrxApInvoicesTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE tapv_rec_type IS RECORD (
    id                             NUMBER := OKL_API.G_MISS_NUM,
    object_version_number          NUMBER := OKL_API.G_MISS_NUM,
    sfwt_flag                      OKL_TRX_AP_INVOICES_V.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR,
    cct_id                         NUMBER := OKL_API.G_MISS_NUM,
    currency_code                  OKL_TRX_AP_INVOICES_V.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR,
    ccf_id                         NUMBER := OKL_API.G_MISS_NUM,
    funding_type_code              OKL_TRX_AP_INVOICES_V.FUNDING_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR,
    khr_id                         NUMBER := OKL_API.G_MISS_NUM,
    art_id                         NUMBER := OKL_API.G_MISS_NUM,
    tap_id_reverses                NUMBER := OKL_API.G_MISS_NUM,
    ippt_id                        NUMBER := OKL_API.G_MISS_NUM,
    code_combination_id            NUMBER := OKL_API.G_MISS_NUM,
    ipvs_id                        NUMBER := OKL_API.G_MISS_NUM,
    tcn_id                         NUMBER := OKL_API.G_MISS_NUM,
    vpa_id                         NUMBER := OKL_API.G_MISS_NUM,
    ipt_id                         NUMBER := OKL_API.G_MISS_NUM,
    qte_id                         NUMBER := OKL_API.G_MISS_NUM,
    invoice_category_code          OKL_TRX_AP_INVOICES_V.INVOICE_CATEGORY_CODE%TYPE := OKL_API.G_MISS_CHAR,
    payment_method_code            OKL_TRX_AP_INVOICES_V.PAYMENT_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR,
    cplv_id                        NUMBER := OKL_API.G_MISS_NUM,
    pox_id                         NUMBER := OKL_API.G_MISS_NUM,
    amount                         NUMBER := OKL_API.G_MISS_NUM,
    date_invoiced                  OKL_TRX_AP_INVOICES_V.DATE_INVOICED%TYPE := OKL_API.G_MISS_DATE,
    invoice_number                 OKL_TRX_AP_INVOICES_V.INVOICE_NUMBER%TYPE := OKL_API.G_MISS_CHAR,
    date_funding_approved          OKL_TRX_AP_INVOICES_V.DATE_FUNDING_APPROVED%TYPE := OKL_API.G_MISS_DATE,
    date_gl                        OKL_TRX_AP_INVOICES_V.DATE_GL%TYPE := OKL_API.G_MISS_DATE,
    workflow_yn                    OKL_TRX_AP_INVOICES_V.WORKFLOW_YN%TYPE := OKL_API.G_MISS_CHAR,
    match_required_yn              OKL_TRX_AP_INVOICES_B.MATCH_REQUIRED_YN%TYPE := OKL_API.G_MISS_CHAR,
    ipt_frequency                  OKL_TRX_AP_INVOICES_B.IPT_FREQUENCY%TYPE := OKL_API.G_MISS_CHAR,
    consolidate_yn                 OKL_TRX_AP_INVOICES_V.CONSOLIDATE_YN%TYPE := OKL_API.G_MISS_CHAR,
    wait_vendor_invoice_yn         OKL_TRX_AP_INVOICES_V.WAIT_VENDOR_INVOICE_YN%TYPE := OKL_API.G_MISS_CHAR,
    date_requisition               OKL_TRX_AP_INVOICES_V.DATE_REQUISITION%TYPE := OKL_API.G_MISS_DATE,
    description                    OKL_TRX_AP_INVOICES_V.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR,
    CURRENCY_CONVERSION_TYPE       OKL_TRX_AP_INVOICES_B.CURRENCY_CONVERSION_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    CURRENCY_CONVERSION_RATE       NUMBER := OKL_API.G_MISS_NUM,
    CURRENCY_CONVERSION_DATE       OKL_TRX_AP_INVOICES_B.CURRENCY_CONVERSION_DATE%TYPE := OKL_API.G_MISS_DATE,
    vendor_id                      OKL_TRX_AP_INVOICES_B.vendor_id%TYPE := OKL_API.G_MISS_NUM,
    attribute_category             OKL_TRX_AP_INVOICES_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR,
    attribute1                     OKL_TRX_AP_INVOICES_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR,
    attribute2                     OKL_TRX_AP_INVOICES_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR,
    attribute3                     OKL_TRX_AP_INVOICES_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR,
    attribute4                     OKL_TRX_AP_INVOICES_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR,
    attribute5                     OKL_TRX_AP_INVOICES_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR,
    attribute6                     OKL_TRX_AP_INVOICES_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR,
    attribute7                     OKL_TRX_AP_INVOICES_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR,
    attribute8                     OKL_TRX_AP_INVOICES_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR,
    attribute9                     OKL_TRX_AP_INVOICES_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR,
    attribute10                    OKL_TRX_AP_INVOICES_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR,
    attribute11                    OKL_TRX_AP_INVOICES_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR,
    attribute12                    OKL_TRX_AP_INVOICES_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR,
    attribute13                    OKL_TRX_AP_INVOICES_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR,
    attribute14                    OKL_TRX_AP_INVOICES_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR,
    attribute15                    OKL_TRX_AP_INVOICES_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR,
    date_entered                   OKL_TRX_AP_INVOICES_V.DATE_ENTERED%TYPE := OKL_API.G_MISS_DATE,
    trx_status_code                OKL_TRX_AP_INVOICES_V.TRX_STATUS_CODE%TYPE := Okl_Api.G_MISS_CHAR, -- Post postgen changes
    set_of_books_id                NUMBER := Okl_Api.G_MISS_NUM, -- Post postgen changes
    try_id                         NUMBER := OKL_API.G_MISS_NUM, -- Post postgen changes
    request_id                     NUMBER := OKL_API.G_MISS_NUM,
    program_application_id         NUMBER := OKL_API.G_MISS_NUM,
    program_id                     NUMBER := OKL_API.G_MISS_NUM,
    program_update_date            OKL_TRX_AP_INVOICES_V.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    org_id                         NUMBER := OKL_API.G_MISS_NUM,
    created_by                     NUMBER := OKL_API.G_MISS_NUM,
    creation_date                  OKL_TRX_AP_INVOICES_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKL_API.G_MISS_NUM,
    last_update_date               OKL_TRX_AP_INVOICES_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER := OKL_API.G_MISS_NUM,
    invoice_type                   OKL_TRX_AP_INVOICES_V.invoice_type%TYPE,
    pay_group_lookup_code          OKL_TRX_AP_INVOICES_V.pay_group_lookup_code%TYPE,
    vendor_invoice_number          OKL_TRX_AP_INVOICES_V.vendor_invoice_number%TYPE,
    nettable_yn                    OKL_TRX_AP_INVOICES_B.nettable_yn%TYPE,
    ASSET_TAP_ID                   OKL_TRX_AP_INVOICES_V.ASSET_TAP_ID%TYPE := OKL_API.G_MISS_NUM ,
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
    legal_entity_id                OKL_TRX_AP_INVOICES_V.legal_entity_id%TYPE := OKL_API.G_MISS_NUM
    ,transaction_date                OKL_TRX_AP_INVOICES_V.transaction_date%TYPE := OKL_API.G_MISS_DATE);
  g_miss_tapv_rec                         tapv_rec_type;
  TYPE tapv_tbl_type IS TABLE OF tapv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TAP_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  -- Post-Gen Begin-0
  G_VIEW   	  		    CONSTANT   VARCHAR2(30) := 'OKL_TRX_AP_INVOICES_V';
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
    p_tapv_rec                     IN tapv_rec_type,
    x_tapv_rec                     OUT NOCOPY tapv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_tbl                     IN tapv_tbl_type,
    x_tapv_tbl                     OUT NOCOPY tapv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_rec                     IN tapv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_tbl                     IN tapv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_rec                     IN tapv_rec_type,
    x_tapv_rec                     OUT NOCOPY tapv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_tbl                     IN tapv_tbl_type,
    x_tapv_tbl                     OUT NOCOPY tapv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_rec                     IN tapv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_tbl                     IN tapv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_rec                     IN tapv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tapv_tbl                     IN tapv_tbl_type);

END OKL_TAP_PVT;

/
