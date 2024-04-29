--------------------------------------------------------
--  DDL for Package OKL_XLP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_XLP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSXLPS.pls 115.3 2002/08/16 00:19:08 stmathew noship $ */
  ---------------------------------------------------------------------------
  -- PostGen --
  -- SPEC:
  -- 0. Global Messages (5) and Variables (2) = Done!
  -- BODY:
  -- 1. Check for Not Null Primary Keys
  -- 2. Check for Not Null Foreign Keys
  -- 5. Validity of Foreign Keys, where applicable
  -- 4. Validity of Unique Keys, where applicable
  -- 3. Validity of Org_id, where applicable
  -- 6. Added domain validation, where applicable
  -- 7. Added the Concurrent Manager Columns ( p104 )
  -- 8. Any lookup code should be validated using the OKL_UTIL package.
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE xlp_rec_type IS RECORD (
    id                             NUMBER := OKL_API.G_MISS_NUM,
    xpi_id_details                 NUMBER := OKL_API.G_MISS_NUM,
    pid_id                         NUMBER := OKL_API.G_MISS_NUM,
    ibi_id                         NUMBER := OKL_API.G_MISS_NUM,
    tpl_id                         NUMBER := OKL_API.G_MISS_NUM,
	tap_id						   NUMBER := OKL_API.G_MISS_NUM,
    object_version_number          NUMBER := OKL_API.G_MISS_NUM,
    invoice_line_id                NUMBER := OKL_API.G_MISS_NUM,
    line_number                    NUMBER := OKL_API.G_MISS_NUM,
    line_type                      OKL_XTL_PAY_INVS_B.LINE_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    amount                         NUMBER := OKL_API.G_MISS_NUM,
    accounting_date                OKL_XTL_PAY_INVS_B.ACCOUNTING_DATE%TYPE := OKL_API.G_MISS_DATE,
    dist_code_combination_id       NUMBER := OKL_API.G_MISS_NUM,
    tax_code                       OKL_XTL_PAY_INVS_B.TAX_CODE%TYPE := OKL_API.G_MISS_CHAR,
    request_id                     NUMBER := OKL_API.G_MISS_NUM,
    program_application_id         NUMBER := OKL_API.G_MISS_NUM,
    program_id                     NUMBER := OKL_API.G_MISS_NUM,
    program_update_date            OKL_XTL_PAY_INVS_B.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    org_id                         NUMBER := OKL_API.G_MISS_NUM,
    attribute_category             OKL_XTL_PAY_INVS_B.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR,
    attribute1                     OKL_XTL_PAY_INVS_B.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR,
    attribute2                     OKL_XTL_PAY_INVS_B.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR,
    attribute3                     OKL_XTL_PAY_INVS_B.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR,
    attribute4                     OKL_XTL_PAY_INVS_B.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR,
    attribute5                     OKL_XTL_PAY_INVS_B.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR,
    attribute6                     OKL_XTL_PAY_INVS_B.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR,
    attribute7                     OKL_XTL_PAY_INVS_B.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR,
    attribute8                     OKL_XTL_PAY_INVS_B.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR,
    attribute9                     OKL_XTL_PAY_INVS_B.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR,
    attribute10                    OKL_XTL_PAY_INVS_B.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR,
    attribute11                    OKL_XTL_PAY_INVS_B.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR,
    attribute12                    OKL_XTL_PAY_INVS_B.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR,
    attribute13                    OKL_XTL_PAY_INVS_B.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR,
    attribute14                    OKL_XTL_PAY_INVS_B.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR,
    attribute15                    OKL_XTL_PAY_INVS_B.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR,
    created_by                     NUMBER := OKL_API.G_MISS_NUM,
    creation_date                  OKL_XTL_PAY_INVS_B.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKL_API.G_MISS_NUM,
    last_update_date               OKL_XTL_PAY_INVS_B.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  g_miss_xlp_rec                          xlp_rec_type;
  TYPE xlp_tbl_type IS TABLE OF xlp_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_xtl_pay_invs_tl_rec_type IS RECORD (
    id                             NUMBER := OKL_API.G_MISS_NUM,
    language                       OKL_XTL_PAY_INVS_TL.LANGUAGE%TYPE := OKL_API.G_MISS_CHAR,
    source_lang                    OKL_XTL_PAY_INVS_TL.SOURCE_LANG%TYPE := OKL_API.G_MISS_CHAR,
    sfwt_flag                      OKL_XTL_PAY_INVS_TL.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR,
    description                    OKL_XTL_PAY_INVS_TL.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR,
    stream_type                    OKL_XTL_PAY_INVS_TL.STREAM_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    created_by                     NUMBER := OKL_API.G_MISS_NUM,
    creation_date                  OKL_XTL_PAY_INVS_TL.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKL_API.G_MISS_NUM,
    last_update_date               OKL_XTL_PAY_INVS_TL.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  g_miss_okl_xtl_pay_invs_tl_rec          okl_xtl_pay_invs_tl_rec_type;
  TYPE okl_xtl_pay_invs_tl_tbl_type IS TABLE OF okl_xtl_pay_invs_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE xlpv_rec_type IS RECORD (
    id                             NUMBER := OKL_API.G_MISS_NUM,
    object_version_number          NUMBER := OKL_API.G_MISS_NUM,
    sfwt_flag                      OKL_XTL_PAY_INVS_V.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR,
    tpl_id                         NUMBER := OKL_API.G_MISS_NUM,
    tap_id                         NUMBER := OKL_API.G_MISS_NUM,
    pid_id                         NUMBER := OKL_API.G_MISS_NUM,
    ibi_id                         NUMBER := OKL_API.G_MISS_NUM,
    xpi_id_details                 NUMBER := OKL_API.G_MISS_NUM,
    invoice_line_id                NUMBER := OKL_API.G_MISS_NUM,
    line_number                    NUMBER := OKL_API.G_MISS_NUM,
    line_type                      OKL_XTL_PAY_INVS_V.LINE_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    amount                         NUMBER := OKL_API.G_MISS_NUM,
    accounting_date                OKL_XTL_PAY_INVS_V.ACCOUNTING_DATE%TYPE := OKL_API.G_MISS_DATE,
    description                    OKL_XTL_PAY_INVS_V.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR,
    dist_code_combination_id       NUMBER := OKL_API.G_MISS_NUM,
    tax_code                       OKL_XTL_PAY_INVS_V.TAX_CODE%TYPE := OKL_API.G_MISS_CHAR,
    stream_type                    OKL_XTL_PAY_INVS_V.STREAM_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    attribute_category             OKL_XTL_PAY_INVS_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR,
    attribute1                     OKL_XTL_PAY_INVS_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR,
    attribute2                     OKL_XTL_PAY_INVS_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR,
    attribute3                     OKL_XTL_PAY_INVS_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR,
    attribute4                     OKL_XTL_PAY_INVS_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR,
    attribute5                     OKL_XTL_PAY_INVS_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR,
    attribute6                     OKL_XTL_PAY_INVS_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR,
    attribute7                     OKL_XTL_PAY_INVS_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR,
    attribute8                     OKL_XTL_PAY_INVS_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR,
    attribute9                     OKL_XTL_PAY_INVS_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR,
    attribute10                    OKL_XTL_PAY_INVS_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR,
    attribute11                    OKL_XTL_PAY_INVS_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR,
    attribute12                    OKL_XTL_PAY_INVS_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR,
    attribute13                    OKL_XTL_PAY_INVS_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR,
    attribute14                    OKL_XTL_PAY_INVS_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR,
    attribute15                    OKL_XTL_PAY_INVS_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR,
    request_id                     NUMBER := OKL_API.G_MISS_NUM,
    program_application_id         NUMBER := OKL_API.G_MISS_NUM,
    program_id                     NUMBER := OKL_API.G_MISS_NUM,
    program_update_date            OKL_XTL_PAY_INVS_V.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    org_id                         NUMBER := OKL_API.G_MISS_NUM,
    created_by                     NUMBER := OKL_API.G_MISS_NUM,
    creation_date                  OKL_XTL_PAY_INVS_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKL_API.G_MISS_NUM,
    last_update_date               OKL_XTL_PAY_INVS_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  g_miss_xlpv_rec                         xlpv_rec_type;
  TYPE xlpv_tbl_type IS TABLE OF xlpv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_XLP_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  -- Post-Gen Begin-0
  G_VIEW   	  		    CONSTANT   VARCHAR2(30) := 'OKL_XTL_PAY_INVS_V';
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
    p_xlpv_rec                     IN xlpv_rec_type,
    x_xlpv_rec                     OUT NOCOPY xlpv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_tbl                     IN xlpv_tbl_type,
    x_xlpv_tbl                     OUT NOCOPY xlpv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_rec                     IN xlpv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_tbl                     IN xlpv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_rec                     IN xlpv_rec_type,
    x_xlpv_rec                     OUT NOCOPY xlpv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_tbl                     IN xlpv_tbl_type,
    x_xlpv_tbl                     OUT NOCOPY xlpv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_rec                     IN xlpv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_tbl                     IN xlpv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_rec                     IN xlpv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlpv_tbl                     IN xlpv_tbl_type);

END OKL_XLP_PVT;

 

/
