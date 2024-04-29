--------------------------------------------------------
--  DDL for Package OKL_TRY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTRYS.pls 120.4 2006/12/26 07:22:23 dpsingh noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE try_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    try_id                         NUMBER := OKC_API.G_MISS_NUM,
    try_id_for                     NUMBER := OKC_API.G_MISS_NUM,
    ilc_id                         NUMBER := OKC_API.G_MISS_NUM,
    aep_code                       OKL_TRX_TYPES_B.AEP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    try_type                       OKL_TRX_TYPES_B.TRY_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TRX_TYPES_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TRX_TYPES_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    trx_type_class                 OKL_TRX_TYPES_B.TRX_TYPE_CLASS%TYPE := OKC_API.G_MISS_CHAR,
    --Added by kthiruva on 04-May-2005 for Tax Enhancements
    --Bug 4386433 - Start of Changes
    tax_upfront_yn                 OKL_TRX_TYPES_B.TAX_UPFRONT_YN%TYPE := OKC_API.G_MISS_CHAR,
    tax_invoice_yn                 OKL_TRX_TYPES_B.TAX_INVOICE_YN%TYPE := OKC_API.G_MISS_CHAR,
    tax_schedule_yn                OKL_TRX_TYPES_B.TAX_SCHEDULE_YN%TYPE := OKC_API.G_MISS_CHAR,
    --Bug 4386433 -End of Changes
    --Bug 5707866 dpsingh
    formula_yn                OKL_TRX_TYPES_B.FORMULA_YN%TYPE := OKL_API.G_MISS_CHAR,
    accounting_event_class_code                OKL_TRX_TYPES_B.ACCOUNTING_EVENT_CLASS_CODE%TYPE := OKL_API.G_MISS_CHAR
	);
  g_miss_try_rec                          try_rec_type;
  TYPE try_tbl_type IS TABLE OF try_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_trx_types_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    LANGUAGE                       OKL_TRX_TYPES_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_TRX_TYPES_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_TRX_TYPES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKL_TRX_TYPES_TL.NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_TRX_TYPES_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    contract_header_line_flag      OKL_TRX_TYPES_TL.CONTRACT_HEADER_LINE_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    transaction_header_line_detail  OKL_TRX_TYPES_TL.TRANSACTION_HEADER_LINE_DETAIL%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TRX_TYPES_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TRX_TYPES_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_okl_trx_types_tl_rec             okl_trx_types_tl_rec_type;
  TYPE okl_trx_types_tl_tbl_type IS TABLE OF okl_trx_types_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE tryv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKL_TRX_TYPES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    aep_code                       OKL_TRX_TYPES_V.AEP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    ilc_id                         NUMBER := OKC_API.G_MISS_NUM,
    try_id                         NUMBER := OKC_API.G_MISS_NUM,
    try_id_for                     NUMBER := OKC_API.G_MISS_NUM,
    try_type                       OKL_TRX_TYPES_V.TRY_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKL_TRX_TYPES_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_TRX_TYPES_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    contract_header_line_flag      OKL_TRX_TYPES_V.CONTRACT_HEADER_LINE_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    transaction_header_line_detail  OKL_TRX_TYPES_V.TRANSACTION_HEADER_LINE_DETAIL%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TRX_TYPES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TRX_TYPES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    trx_type_class                 OKL_TRX_TYPES_V.TRX_TYPE_CLASS%TYPE := OKC_API.G_MISS_CHAR,
    --Added by kthiruva on 04-May-2005 for Tax Enhancements
    --Bug 4386433 - Start of Changes
    tax_upfront_yn                 OKL_TRX_TYPES_V.TAX_UPFRONT_YN%TYPE := OKC_API.G_MISS_CHAR,
    tax_invoice_yn                 OKL_TRX_TYPES_V.TAX_INVOICE_YN%TYPE := OKC_API.G_MISS_CHAR,
    tax_schedule_yn                OKL_TRX_TYPES_V.TAX_SCHEDULE_YN%TYPE := OKC_API.G_MISS_CHAR,
    --Bug 4386433 - End of Changes
     --Bug 5707866 dpsingh
    formula_yn          OKL_TRX_TYPES_B.FORMULA_YN%TYPE := OKL_API.G_MISS_CHAR,
    accounting_event_class_code       OKL_TRX_TYPES_B.ACCOUNTING_EVENT_CLASS_CODE%TYPE := OKL_API.G_MISS_CHAR
	);
  g_miss_tryv_rec                         tryv_rec_type;
  TYPE tryv_tbl_type IS TABLE OF tryv_rec_type
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
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_UPPERCASE_REQUIRED	CONSTANT VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNQS CONSTANT VARCHAR2(200) := 'OKL_TRY_ELEMENT_NOT_UNIQUE';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TRY_PVT';
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
    p_tryv_rec                     IN tryv_rec_type,
    x_tryv_rec                     OUT NOCOPY tryv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_tbl                     IN tryv_tbl_type,
    x_tryv_tbl                     OUT NOCOPY tryv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_rec                     IN tryv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_tbl                     IN tryv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_rec                     IN tryv_rec_type,
    x_tryv_rec                     OUT NOCOPY tryv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_tbl                     IN tryv_tbl_type,
    x_tryv_tbl                     OUT NOCOPY tryv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_rec                     IN tryv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_tbl                     IN tryv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_rec                     IN tryv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_tbl                     IN tryv_tbl_type);

  PROCEDURE  LOAD_SEED_ROW(
    p_upload_mode                  IN VARCHAR2,
    p_id                           IN VARCHAR2,
    p_trx_type_class               IN VARCHAR2,
    p_try_id                       IN VARCHAR2,
    p_try_id_for                   IN VARCHAR2,
    p_ilc_id                       IN VARCHAR2,
    p_aep_code                     IN VARCHAR2,
    p_try_type                     IN VARCHAR2,
    p_object_version_number        IN VARCHAR2,
    p_org_id                       IN VARCHAR2,
    p_name                         IN VARCHAR2,
    p_description                  IN VARCHAR2,
    p_owner                        IN VARCHAR2,
    p_last_update_date             IN VARCHAR2,
    p_tax_upfront_yn               IN VARCHAR2,
    p_tax_invoice_yn               IN VARCHAR2,
    p_tax_schedule_yn              IN VARCHAR2,
    --Added by dpsingh for Bug 5707866
    p_formula_yn              IN VARCHAR2,
    p_accounting_event_class_code    IN VARCHAR2);

END OKL_TRY_PVT;

/
