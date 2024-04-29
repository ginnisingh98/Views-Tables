--------------------------------------------------------
--  DDL for Package OKL_PVN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PVN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSPVNS.pls 115.5 2002/02/05 12:19:14 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE pvn_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    name                           OKL_PROVISIONS.NAME%TYPE := Okc_Api.G_MISS_CHAR,
    app_debit_ccid  NUMBER := Okc_Api.G_MISS_NUM,
    rev_credit_ccid  NUMBER := Okc_Api.G_MISS_NUM,
    rev_debit_ccid  NUMBER := Okc_Api.G_MISS_NUM,
    app_credit_ccid  NUMBER := Okc_Api.G_MISS_NUM,
    set_of_books_id                NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    version                        OKL_PROVISIONS.VERSION%TYPE := Okc_Api.G_MISS_CHAR,
    description                    OKL_PROVISIONS.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR,
    from_date                      OKL_PROVISIONS.FROM_DATE%TYPE := Okc_Api.G_MISS_DATE,
    TO_DATE                        OKL_PROVISIONS.TO_DATE%TYPE := Okc_Api.G_MISS_DATE,
    attribute_category             OKL_PROVISIONS.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_PROVISIONS.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_PROVISIONS.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_PROVISIONS.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_PROVISIONS.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_PROVISIONS.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_PROVISIONS.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_PROVISIONS.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_PROVISIONS.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_PROVISIONS.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_PROVISIONS.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_PROVISIONS.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_PROVISIONS.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_PROVISIONS.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_PROVISIONS.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_PROVISIONS.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_PROVISIONS.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_PROVISIONS.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_pvn_rec                          pvn_rec_type;
  TYPE pvn_tbl_type IS TABLE OF pvn_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE pvnv_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    app_debit_ccid  NUMBER := Okc_Api.G_MISS_NUM,
    rev_credit_ccid  NUMBER := Okc_Api.G_MISS_NUM,
    rev_debit_ccid  NUMBER := Okc_Api.G_MISS_NUM,
    set_of_books_id                NUMBER := Okc_Api.G_MISS_NUM,
    app_credit_ccid  NUMBER := Okc_Api.G_MISS_NUM,
    name                           OKL_PROVISIONS_V.NAME%TYPE := Okc_Api.G_MISS_CHAR,
    description                    OKL_PROVISIONS_V.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR,
    attribute_category             OKL_PROVISIONS_V.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_PROVISIONS_V.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_PROVISIONS_V.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_PROVISIONS_V.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_PROVISIONS_V.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_PROVISIONS_V.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_PROVISIONS_V.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_PROVISIONS_V.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_PROVISIONS_V.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_PROVISIONS_V.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_PROVISIONS_V.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_PROVISIONS_V.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_PROVISIONS_V.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_PROVISIONS_V.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_PROVISIONS_V.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_PROVISIONS_V.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    version                        OKL_PROVISIONS_V.VERSION%TYPE := Okc_Api.G_MISS_CHAR,
    from_date                      OKL_PROVISIONS_V.FROM_DATE%TYPE := Okc_Api.G_MISS_DATE,
    TO_DATE                        OKL_PROVISIONS_V.TO_DATE%TYPE := Okc_Api.G_MISS_DATE,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_PROVISIONS_V.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_PROVISIONS_V.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_pvnv_rec                         pvnv_rec_type;
  TYPE pvnv_tbl_type IS TABLE OF pvnv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okc_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okc_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNQS CONSTANT VARCHAR2(200) := 'OKL_PVN_ELEMENT_NOT_UNIQUE';
  G_NO_PARENT_RECORD	CONSTANT VARCHAR2(200) := 'OKL__PVN_NO_PARENT_RECORD';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_PVN_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  Procedure qc;
  Procedure change_version;
  Procedure api_copy;
  Procedure insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN pvnv_rec_type,
    x_pvnv_rec                     OUT NOCOPY pvnv_rec_type);

  Procedure insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN pvnv_tbl_type,
    x_pvnv_tbl                     OUT NOCOPY pvnv_tbl_type);

  Procedure lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN pvnv_rec_type);

  Procedure lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN pvnv_tbl_type);

  Procedure update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN pvnv_rec_type,
    x_pvnv_rec                     OUT NOCOPY pvnv_rec_type);

  Procedure update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN pvnv_tbl_type,
    x_pvnv_tbl                     OUT NOCOPY pvnv_tbl_type);

  Procedure delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN pvnv_rec_type);

  Procedure delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN pvnv_tbl_type);

  Procedure validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN pvnv_rec_type);

  Procedure validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN pvnv_tbl_type);

END Okl_Pvn_Pvt;

 

/
