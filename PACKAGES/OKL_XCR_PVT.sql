--------------------------------------------------------
--  DDL for Package OKL_XCR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_XCR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSXCRS.pls 120.2 2005/10/30 04:46:07 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE xcr_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    xcb_id                         NUMBER := Okl_Api.G_MISS_NUM,
    rct_id                         NUMBER := Okl_Api.G_MISS_NUM,
    icr_id                         NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    gl_date                        DATE := Okl_Api.G_MISS_DATE,
    item_number                    NUMBER := Okl_Api.G_MISS_NUM,
    remittance_amount              NUMBER := Okl_Api.G_MISS_NUM,
    currency_code                  OKL_EXT_CSH_RCPTS_B.CURRENCY_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    receipt_date                   OKL_EXT_CSH_RCPTS_B.RECEIPT_DATE%TYPE := Okl_Api.G_MISS_DATE,
    receipt_method                 OKL_EXT_CSH_RCPTS_B.RECEIPT_METHOD%TYPE := Okl_Api.G_MISS_CHAR,
    check_number                   OKL_EXT_CSH_RCPTS_B.CHECK_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    comments                       OKL_EXT_CSH_RCPTS_TL.COMMENTS%TYPE := Okl_Api.G_MISS_CHAR,
    customer_number                OKL_EXT_CSH_RCPTS_B.CUSTOMER_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    bill_to_location               OKL_EXT_CSH_RCPTS_B.BILL_TO_LOCATION%TYPE := Okl_Api.G_MISS_CHAR,
    exchange_rate_type             OKL_EXT_CSH_RCPTS_B.EXCHANGE_RATE_TYPE%TYPE := Okl_Api.G_MISS_CHAR,
    exchange_rate_date             OKL_EXT_CSH_RCPTS_B.EXCHANGE_RATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    exchange_rate                  NUMBER := Okl_Api.G_MISS_NUM,
    transit_routing_number         OKL_EXT_CSH_RCPTS_B.TRANSIT_ROUTING_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    account                        OKL_EXT_CSH_RCPTS_B.ACCOUNT%TYPE := Okl_Api.G_MISS_CHAR,
    customer_bank_name             OKL_EXT_CSH_RCPTS_B.CUSTOMER_BANK_NAME%TYPE := Okl_Api.G_MISS_CHAR,
    customer_bank_branch_name      OKL_EXT_CSH_RCPTS_B.CUSTOMER_BANK_BRANCH_NAME%TYPE := Okl_Api.G_MISS_CHAR,
    remittance_bank_name           OKL_EXT_CSH_RCPTS_B.REMITTANCE_BANK_NAME%TYPE := Okl_Api.G_MISS_CHAR,
    remittance_bank_branch_name    OKL_EXT_CSH_RCPTS_B.REMITTANCE_BANK_BRANCH_NAME%TYPE := Okl_Api.G_MISS_CHAR,
    request_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_Api.G_MISS_NUM,
    program_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_update_date            OKL_EXT_CSH_RCPTS_B.PROGRAM_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    attribute_category             OKL_EXT_CSH_RCPTS_B.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_EXT_CSH_RCPTS_B.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_EXT_CSH_RCPTS_B.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_EXT_CSH_RCPTS_B.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_EXT_CSH_RCPTS_B.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_EXT_CSH_RCPTS_B.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_EXT_CSH_RCPTS_B.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_EXT_CSH_RCPTS_B.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_EXT_CSH_RCPTS_B.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_EXT_CSH_RCPTS_B.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_EXT_CSH_RCPTS_B.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_EXT_CSH_RCPTS_B.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_EXT_CSH_RCPTS_B.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_EXT_CSH_RCPTS_B.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_EXT_CSH_RCPTS_B.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_EXT_CSH_RCPTS_B.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_EXT_CSH_RCPTS_B.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_EXT_CSH_RCPTS_B.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM,
-- receipt type and fully applied are the two new columns added.
    receipt_type                   OKL_EXT_CSH_RCPTS_B.RECEIPT_TYPE%TYPE := 'REG',
    fully_applied_flag             OKL_EXT_CSH_RCPTS_B.FULLY_APPLIED_FLAG%TYPE := 'REG',
    expired_flag                   OKL_EXT_CSH_RCPTS_B.FULLY_APPLIED_FLAG%TYPE := Okl_Api.G_MISS_CHAR  );
  g_miss_xcr_rec                          xcr_rec_type;
  TYPE xcr_tbl_type IS TABLE OF xcr_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_ext_csh_rcpts_tl_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    LANGUAGE                       OKL_EXT_CSH_RCPTS_TL.LANGUAGE%TYPE := Okl_Api.G_MISS_CHAR,
    source_lang                    OKL_EXT_CSH_RCPTS_TL.SOURCE_LANG%TYPE := Okl_Api.G_MISS_CHAR,
    sfwt_flag                      OKL_EXT_CSH_RCPTS_TL.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    comments                       OKL_EXT_CSH_RCPTS_TL.COMMENTS%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_EXT_CSH_RCPTS_TL.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_EXT_CSH_RCPTS_TL.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  GMissOklExtCshRcptsTlRec                okl_ext_csh_rcpts_tl_rec_type;
  TYPE okl_ext_csh_rcpts_tl_tbl_type IS TABLE OF okl_ext_csh_rcpts_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE xcrv_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
	sfwt_flag                      OKL_EXT_CSH_RCPTS_V.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    xcb_id                         NUMBER := Okl_Api.G_MISS_NUM,
    rct_id                         NUMBER := Okl_Api.G_MISS_NUM,
    icr_id                         NUMBER := Okl_Api.G_MISS_NUM,
    gl_date                        DATE   := Okl_Api.G_MISS_DATE,
    item_number                    NUMBER := Okl_Api.G_MISS_NUM,
    remittance_amount              NUMBER := Okl_Api.G_MISS_NUM,
    currency_code                  OKL_EXT_CSH_RCPTS_V.CURRENCY_CODE%TYPE := Okl_Api.G_MISS_CHAR,
    receipt_date                   OKL_EXT_CSH_RCPTS_V.RECEIPT_DATE%TYPE := Okl_Api.G_MISS_DATE,
    receipt_method                 OKL_EXT_CSH_RCPTS_V.RECEIPT_METHOD%TYPE := Okl_Api.G_MISS_CHAR,
    check_number                   OKL_EXT_CSH_RCPTS_V.CHECK_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    comments                       OKL_EXT_CSH_RCPTS_V.COMMENTS%TYPE := Okl_Api.G_MISS_CHAR,
    customer_number                OKL_EXT_CSH_RCPTS_V.CUSTOMER_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    bill_to_location               OKL_EXT_CSH_RCPTS_V.BILL_TO_LOCATION%TYPE := Okl_Api.G_MISS_CHAR,
    exchange_rate_type             OKL_EXT_CSH_RCPTS_V.EXCHANGE_RATE_TYPE%TYPE := Okl_Api.G_MISS_CHAR,
    exchange_rate_date             OKL_EXT_CSH_RCPTS_V.EXCHANGE_RATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    exchange_rate                  NUMBER := Okl_Api.G_MISS_NUM,
    transit_routing_number         OKL_EXT_CSH_RCPTS_V.TRANSIT_ROUTING_NUMBER%TYPE := Okl_Api.G_MISS_CHAR,
    account                        OKL_EXT_CSH_RCPTS_V.ACCOUNT%TYPE := Okl_Api.G_MISS_CHAR,
    customer_bank_name             OKL_EXT_CSH_RCPTS_V.CUSTOMER_BANK_NAME%TYPE := Okl_Api.G_MISS_CHAR,
    customer_bank_branch_name      OKL_EXT_CSH_RCPTS_V.CUSTOMER_BANK_BRANCH_NAME%TYPE := Okl_Api.G_MISS_CHAR,
    remittance_bank_name           OKL_EXT_CSH_RCPTS_V.REMITTANCE_BANK_NAME%TYPE := Okl_Api.G_MISS_CHAR,
    remittance_bank_branch_name    OKL_EXT_CSH_RCPTS_V.REMITTANCE_BANK_BRANCH_NAME%TYPE := Okl_Api.G_MISS_CHAR,
    attribute_category             OKL_EXT_CSH_RCPTS_V.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_EXT_CSH_RCPTS_V.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_EXT_CSH_RCPTS_V.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_EXT_CSH_RCPTS_V.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_EXT_CSH_RCPTS_V.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_EXT_CSH_RCPTS_V.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_EXT_CSH_RCPTS_V.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_EXT_CSH_RCPTS_V.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_EXT_CSH_RCPTS_V.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_EXT_CSH_RCPTS_V.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_EXT_CSH_RCPTS_V.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_EXT_CSH_RCPTS_V.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_EXT_CSH_RCPTS_V.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_EXT_CSH_RCPTS_V.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_EXT_CSH_RCPTS_V.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_EXT_CSH_RCPTS_V.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    request_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_Api.G_MISS_NUM,
    program_id                     NUMBER := Okl_Api.G_MISS_NUM,
    program_update_date            OKL_EXT_CSH_RCPTS_V.PROGRAM_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_EXT_CSH_RCPTS_V.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_EXT_CSH_RCPTS_V.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM,
-- receipt type and fully applied are the two new columns added.
    receipt_type                   OKL_EXT_CSH_RCPTS_B.RECEIPT_TYPE%TYPE := 'REG',
    fully_applied_flag             OKL_EXT_CSH_RCPTS_B.FULLY_APPLIED_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    expired_flag                   OKL_EXT_CSH_RCPTS_B.FULLY_APPLIED_FLAG%TYPE := Okl_Api.G_MISS_CHAR  );
    g_miss_xcrv_rec                         xcrv_rec_type;
  TYPE xcrv_tbl_type IS TABLE OF xcrv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_XCR_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

  ---------------------------------------------------------------------------
  -- ADDED AFTER TAPI 04/17/2001
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGES
  ---------------------------------------------------------------------------
  G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_USER_MESSAGE               CONSTANT   VARCHAR2(200) := 'OKL_CONTRACTS_INVALID_VALUE';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_TRX_AR_INVOICES_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;

  ---------------------------------------------------------------------------
  -- POST GEN TAPI CODE ENDS HERE 04/17/2001
  ---------------------------------------------------------------------------

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
    p_xcrv_rec                     IN xcrv_rec_type,
    x_xcrv_rec                     OUT NOCOPY xcrv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type,
    x_xcrv_tbl                     OUT NOCOPY xcrv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_rec                     IN xcrv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_rec                     IN xcrv_rec_type,
    x_xcrv_rec                     OUT NOCOPY xcrv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type,
    x_xcrv_tbl                     OUT NOCOPY xcrv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_rec                     IN xcrv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_rec                     IN xcrv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xcrv_tbl                     IN xcrv_tbl_type);

END Okl_Xcr_Pvt;

 

/
