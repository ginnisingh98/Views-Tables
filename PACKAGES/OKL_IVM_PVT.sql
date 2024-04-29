--------------------------------------------------------
--  DDL for Package OKL_IVM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_IVM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSIVMS.pls 115.1 2002/02/05 12:17:48 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ivm_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    package_name                   OKL_INVC_MSS_PRCDRS.PACKAGE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    procedure_name                 OKL_INVC_MSS_PRCDRS.PROCEDURE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    sequence_number                NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKL_INVC_MSS_PRCDRS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_INVC_MSS_PRCDRS.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_INVC_MSS_PRCDRS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_INVC_MSS_PRCDRS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_INVC_MSS_PRCDRS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_INVC_MSS_PRCDRS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_INVC_MSS_PRCDRS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_INVC_MSS_PRCDRS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_INVC_MSS_PRCDRS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_INVC_MSS_PRCDRS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_INVC_MSS_PRCDRS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_INVC_MSS_PRCDRS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_INVC_MSS_PRCDRS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_INVC_MSS_PRCDRS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_INVC_MSS_PRCDRS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_INVC_MSS_PRCDRS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_INVC_MSS_PRCDRS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_INVC_MSS_PRCDRS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_ivm_rec                          ivm_rec_type;
  TYPE ivm_tbl_type IS TABLE OF ivm_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE ivmv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    package_name                   OKL_INVC_MSS_PRCDRS_V.PACKAGE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    procedure_name                 OKL_INVC_MSS_PRCDRS_V.PROCEDURE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    sequence_number                NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_INVC_MSS_PRCDRS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_INVC_MSS_PRCDRS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_INVC_MSS_PRCDRS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_ivmv_rec                         ivmv_rec_type;
  TYPE ivmv_tbl_type IS TABLE OF ivmv_rec_type
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
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_IVM_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivmv_rec                     IN ivmv_rec_type,
    x_ivmv_rec                     OUT NOCOPY ivmv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivmv_tbl                     IN ivmv_tbl_type,
    x_ivmv_tbl                     OUT NOCOPY ivmv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivmv_rec                     IN ivmv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivmv_tbl                     IN ivmv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivmv_rec                     IN ivmv_rec_type,
    x_ivmv_rec                     OUT NOCOPY ivmv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivmv_tbl                     IN ivmv_tbl_type,
    x_ivmv_tbl                     OUT NOCOPY ivmv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivmv_rec                     IN ivmv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivmv_tbl                     IN ivmv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivmv_rec                     IN ivmv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ivmv_tbl                     IN ivmv_tbl_type);

END OKL_IVM_PVT;

 

/
