--------------------------------------------------------
--  DDL for Package OKL_CSP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CSP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSCSPS.pls 115.5 2002/03/18 01:12:19 pkm ship        $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE csp_rec_type IS RECORD (
    id                             NUMBER := OKL_API.G_MISS_NUM,
    pov_id                         NUMBER := OKL_API.G_MISS_NUM,
    khr_id                         NUMBER := OKL_API.G_MISS_NUM,
    object_version_number          NUMBER := OKL_API.G_MISS_NUM,
    attribute_category             OKL_SLCTD_OPTNS.ATTRIBUTE_CATEGORY%TYPE,
    attribute1                     OKL_SLCTD_OPTNS.ATTRIBUTE1%TYPE,
    attribute2                     OKL_SLCTD_OPTNS.ATTRIBUTE2%TYPE,
    attribute3                     OKL_SLCTD_OPTNS.ATTRIBUTE3%TYPE,
    attribute4                     OKL_SLCTD_OPTNS.ATTRIBUTE4%TYPE,
    attribute5                     OKL_SLCTD_OPTNS.ATTRIBUTE5%TYPE,
    attribute6                     OKL_SLCTD_OPTNS.ATTRIBUTE6%TYPE,
    attribute7                     OKL_SLCTD_OPTNS.ATTRIBUTE7%TYPE,
    attribute8                     OKL_SLCTD_OPTNS.ATTRIBUTE8%TYPE,
    attribute9                     OKL_SLCTD_OPTNS.ATTRIBUTE9%TYPE,
    attribute10                    OKL_SLCTD_OPTNS.ATTRIBUTE10%TYPE,
    attribute11                    OKL_SLCTD_OPTNS.ATTRIBUTE11%TYPE,
    attribute12                    OKL_SLCTD_OPTNS.ATTRIBUTE12%TYPE,
    attribute13                    OKL_SLCTD_OPTNS.ATTRIBUTE13%TYPE,
    attribute14                    OKL_SLCTD_OPTNS.ATTRIBUTE14%TYPE,
    attribute15                    OKL_SLCTD_OPTNS.ATTRIBUTE15%TYPE,
    created_by                     NUMBER := OKL_API.G_MISS_NUM,
    creation_date                  OKL_SLCTD_OPTNS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKL_API.G_MISS_NUM,
    last_update_date               OKL_SLCTD_OPTNS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  g_miss_csp_rec                          csp_rec_type;
  TYPE csp_tbl_type IS TABLE OF csp_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE cspv_rec_type IS RECORD (
    id                             NUMBER := OKL_API.G_MISS_NUM,
    object_version_number          NUMBER := OKL_API.G_MISS_NUM,
    pov_id                         NUMBER := OKL_API.G_MISS_NUM,
    khr_id                         NUMBER := OKL_API.G_MISS_NUM,
    attribute_category             OKL_SLCTD_OPTNS_V.ATTRIBUTE_CATEGORY%TYPE,
    attribute1                     OKL_SLCTD_OPTNS_V.ATTRIBUTE1%TYPE,
    attribute2                     OKL_SLCTD_OPTNS_V.ATTRIBUTE2%TYPE,
    attribute3                     OKL_SLCTD_OPTNS_V.ATTRIBUTE3%TYPE,
    attribute4                     OKL_SLCTD_OPTNS_V.ATTRIBUTE4%TYPE,
    attribute5                     OKL_SLCTD_OPTNS_V.ATTRIBUTE5%TYPE,
    attribute6                     OKL_SLCTD_OPTNS_V.ATTRIBUTE6%TYPE,
    attribute7                     OKL_SLCTD_OPTNS_V.ATTRIBUTE7%TYPE,
    attribute8                     OKL_SLCTD_OPTNS_V.ATTRIBUTE8%TYPE,
    attribute9                     OKL_SLCTD_OPTNS_V.ATTRIBUTE9%TYPE,
    attribute10                    OKL_SLCTD_OPTNS_V.ATTRIBUTE10%TYPE,
    attribute11                    OKL_SLCTD_OPTNS_V.ATTRIBUTE11%TYPE,
    attribute12                    OKL_SLCTD_OPTNS_V.ATTRIBUTE12%TYPE,
    attribute13                    OKL_SLCTD_OPTNS_V.ATTRIBUTE13%TYPE,
    attribute14                    OKL_SLCTD_OPTNS_V.ATTRIBUTE14%TYPE,
    attribute15                    OKL_SLCTD_OPTNS_V.ATTRIBUTE15%TYPE,
    created_by                     NUMBER := OKL_API.G_MISS_NUM,
    creation_date                  OKL_SLCTD_OPTNS_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKL_API.G_MISS_NUM,
    last_update_date               OKL_SLCTD_OPTNS_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  g_miss_cspv_rec                         cspv_rec_type;
  TYPE cspv_tbl_type IS TABLE OF cspv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CSP_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type,
    x_cspv_rec                     OUT NOCOPY cspv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type,
    x_cspv_tbl                     OUT NOCOPY cspv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type,
    x_cspv_rec                     OUT NOCOPY cspv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type,
    x_cspv_tbl                     OUT NOCOPY cspv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_rec                     IN cspv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cspv_tbl                     IN cspv_tbl_type);

END OKL_CSP_PVT;

 

/
