--------------------------------------------------------
--  DDL for Package OKL_INF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSINFS.pls 120.2 2005/10/30 04:42:57 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE inf_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    contract_level_yn              OKL_INVOICE_FORMATS_B.CONTRACT_LEVEL_YN%TYPE := Okl_Api.G_MISS_CHAR,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    ilt_id                         NUMBER := Okl_Api.G_MISS_NUM,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    start_date                     OKL_INVOICE_FORMATS_B.START_DATE%TYPE := Okl_Api.G_MISS_DATE,
    end_date                       OKL_INVOICE_FORMATS_B.END_DATE%TYPE := Okl_Api.G_MISS_DATE,
    attribute_category             OKL_INVOICE_FORMATS_B.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_INVOICE_FORMATS_B.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_INVOICE_FORMATS_B.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_INVOICE_FORMATS_B.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_INVOICE_FORMATS_B.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_INVOICE_FORMATS_B.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_INVOICE_FORMATS_B.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_INVOICE_FORMATS_B.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_INVOICE_FORMATS_B.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_INVOICE_FORMATS_B.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_INVOICE_FORMATS_B.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_INVOICE_FORMATS_B.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_INVOICE_FORMATS_B.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_INVOICE_FORMATS_B.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_INVOICE_FORMATS_B.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_INVOICE_FORMATS_B.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_INVOICE_FORMATS_B.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_INVOICE_FORMATS_B.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  g_miss_inf_rec                          inf_rec_type;
  TYPE inf_tbl_type IS TABLE OF inf_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OklInvoiceFormatsTlRecType IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    LANGUAGE                       OKL_INVOICE_FORMATS_TL.LANGUAGE%TYPE := Okl_Api.G_MISS_CHAR,
    source_lang                    OKL_INVOICE_FORMATS_TL.SOURCE_LANG%TYPE := Okl_Api.G_MISS_CHAR,
    sfwt_flag                      OKL_INVOICE_FORMATS_TL.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    name                           OKL_INVOICE_FORMATS_TL.NAME%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_INVOICE_FORMATS_TL.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_INVOICE_FORMATS_TL.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_INVOICE_FORMATS_TL.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  GMissOklInvoiceFormatsTlRec             OklInvoiceFormatsTlRecType;
  TYPE OklInvoiceFormatsTlTblType IS TABLE OF OklInvoiceFormatsTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE infv_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    ilt_id                         NUMBER := Okl_Api.G_MISS_NUM,
    org_id                         NUMBER := Okl_Api.G_MISS_NUM,
    sfwt_flag                      OKL_INVOICE_FORMATS_V.SFWT_FLAG%TYPE := Okl_Api.G_MISS_CHAR,
    name                           OKL_INVOICE_FORMATS_V.NAME%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_INVOICE_FORMATS_V.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    contract_level_yn              OKL_INVOICE_FORMATS_V.CONTRACT_LEVEL_YN%TYPE := Okl_Api.G_MISS_CHAR,
    start_date                     OKL_INVOICE_FORMATS_V.START_DATE%TYPE := Okl_Api.G_MISS_DATE,
    end_date                       OKL_INVOICE_FORMATS_V.END_DATE%TYPE := Okl_Api.G_MISS_DATE,
    attribute_category             OKL_INVOICE_FORMATS_V.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_INVOICE_FORMATS_V.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_INVOICE_FORMATS_V.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_INVOICE_FORMATS_V.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_INVOICE_FORMATS_V.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_INVOICE_FORMATS_V.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_INVOICE_FORMATS_V.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_INVOICE_FORMATS_V.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_INVOICE_FORMATS_V.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_INVOICE_FORMATS_V.ATTRIBUTE9%TYPE := okl_api.G_MISS_CHAR,
    attribute10                    OKL_INVOICE_FORMATS_V.ATTRIBUTE10%TYPE := okl_api.G_MISS_CHAR,
    attribute11                    OKL_INVOICE_FORMATS_V.ATTRIBUTE11%TYPE := okl_api.G_MISS_CHAR,
    attribute12                    OKL_INVOICE_FORMATS_V.ATTRIBUTE12%TYPE := okl_api.G_MISS_CHAR,
    attribute13                    OKL_INVOICE_FORMATS_V.ATTRIBUTE13%TYPE := okl_api.G_MISS_CHAR,
    attribute14                    OKL_INVOICE_FORMATS_V.ATTRIBUTE14%TYPE := okl_api.G_MISS_CHAR,
    attribute15                    OKL_INVOICE_FORMATS_V.ATTRIBUTE15%TYPE := okl_api.G_MISS_CHAR,
    created_by                     NUMBER := okl_api.G_MISS_NUM,
    creation_date                  OKL_INVOICE_FORMATS_V.CREATION_DATE%TYPE := okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := okl_api.G_MISS_NUM,
    last_update_date               OKL_INVOICE_FORMATS_V.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE,
    last_update_login              NUMBER := okl_api.G_MISS_NUM);
  g_miss_infv_rec                         infv_rec_type;
  TYPE infv_tbl_type IS TABLE OF infv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := okl_api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := okl_api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := okl_api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := okl_api.G_RECORD_LOGICALLY_DELETED;
  -- G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := okl_api.G_REQUIRED_VALUE;

  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := okc_api.G_REQUIRED_VALUE;

  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := okl_api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := okl_api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := okl_api.G_CHILD_TABLE_TOKEN;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_NOT_SAME                CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_INF_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  okl_api.G_APP_NAME;

  G_VIEW   CONSTANT   VARCHAR2(30) := 'OKL_INVOICE_FORMATS_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_rec                     IN infv_rec_type,
    x_infv_rec                     OUT NOCOPY infv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_tbl                     IN infv_tbl_type,
    x_infv_tbl                     OUT NOCOPY infv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_rec                     IN infv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_tbl                     IN infv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_rec                     IN infv_rec_type,
    x_infv_rec                     OUT NOCOPY infv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_tbl                     IN infv_tbl_type,
    x_infv_tbl                     OUT NOCOPY infv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_rec                     IN infv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_tbl                     IN infv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_rec                     IN infv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_infv_tbl                     IN infv_tbl_type);

END Okl_Inf_Pvt;

 

/
