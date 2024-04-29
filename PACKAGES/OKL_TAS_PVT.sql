--------------------------------------------------------
--  DDL for Package OKL_TAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TAS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTASS.pls 120.4 2007/11/06 07:40:41 veramach noship $ */
-- Badrinath Kuchibholta
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE tas_rec_type IS RECORD (
    id                             NUMBER := OKL_API.G_MISS_NUM,
    ica_id                         NUMBER := OKL_API.G_MISS_NUM,
    tas_type                       OKL_TRX_ASSETS.TAS_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKL_API.G_MISS_NUM,
    attribute_category             OKL_TRX_ASSETS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR,
    attribute1                     OKL_TRX_ASSETS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR,
    attribute2                     OKL_TRX_ASSETS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR,
    attribute3                     OKL_TRX_ASSETS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR,
    attribute4                     OKL_TRX_ASSETS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR,
    attribute5                     OKL_TRX_ASSETS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR,
    attribute6                     OKL_TRX_ASSETS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR,
    attribute7                     OKL_TRX_ASSETS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR,
    attribute8                     OKL_TRX_ASSETS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR,
    attribute9                     OKL_TRX_ASSETS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR,
    attribute10                    OKL_TRX_ASSETS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR,
    attribute11                    OKL_TRX_ASSETS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR,
    attribute12                    OKL_TRX_ASSETS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR,
    attribute13                    OKL_TRX_ASSETS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR,
    attribute14                    OKL_TRX_ASSETS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR,
    attribute15                    OKL_TRX_ASSETS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR,
    created_by                     NUMBER := OKL_API.G_MISS_NUM,
    creation_date                  OKL_TRX_ASSETS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKL_API.G_MISS_NUM,
    last_update_date               OKL_TRX_ASSETS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER := OKL_API.G_MISS_NUM,
    tsu_code                       OKL_TRX_ASSETS.TSU_CODE%TYPE := OKL_API.G_MISS_CHAR,
    try_id                         NUMBER := OKL_API.G_MISS_NUM,
    date_trans_occurred            OKL_TRX_ASSETS.DATE_TRANS_OCCURRED%TYPE := OKL_API.G_MISS_DATE,
    trans_number                   NUMBER := OKL_API.G_MISS_NUM,
    comments                       OKL_TRX_ASSETS.COMMENTS%TYPE := OKL_API.G_MISS_CHAR,
    req_asset_id                   NUMBER := OKL_API.G_MISS_NUM,
    total_match_amount             NUMBER := OKL_API.G_MISS_NUM,
--Bug# 2697681 - 11.5.9 Schema changes
    org_id                         NUMBER := OKL_API.G_MISS_NUM,
    --Added by dpsingh for LE uptake
    legal_entity_id          NUMBER := OKL_API.G_MISS_NUM
   ,transaction_date               DATE := OKL_API.G_MISS_DATE);
  g_miss_tas_rec                          tas_rec_type;
  TYPE tas_tbl_type IS TABLE OF tas_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE tasv_rec_type IS RECORD (
    id                             NUMBER := OKL_API.G_MISS_NUM,
    object_version_number          NUMBER := OKL_API.G_MISS_NUM,
    ica_id                         NUMBER := OKL_API.G_MISS_NUM,
    attribute_category             OKL_TRX_ASSETS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR,
    attribute1                     OKL_TRX_ASSETS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR,
    attribute2                     OKL_TRX_ASSETS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR,
    attribute3                     OKL_TRX_ASSETS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR,
    attribute4                     OKL_TRX_ASSETS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR,
    attribute5                     OKL_TRX_ASSETS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR,
    attribute6                     OKL_TRX_ASSETS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR,
    attribute7                     OKL_TRX_ASSETS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR,
    attribute8                     OKL_TRX_ASSETS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR,
    attribute9                     OKL_TRX_ASSETS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR,
    attribute10                    OKL_TRX_ASSETS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR,
    attribute11                    OKL_TRX_ASSETS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR,
    attribute12                    OKL_TRX_ASSETS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR,
    attribute13                    OKL_TRX_ASSETS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR,
    attribute14                    OKL_TRX_ASSETS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR,
    attribute15                    OKL_TRX_ASSETS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR,
    tas_type                       OKL_TRX_ASSETS.TAS_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    created_by                     NUMBER := OKL_API.G_MISS_NUM,
    creation_date                  OKL_TRX_ASSETS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKL_API.G_MISS_NUM,
    last_update_date               OKL_TRX_ASSETS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
    last_update_login              NUMBER := OKL_API.G_MISS_NUM,
    tsu_code                       OKL_TRX_ASSETS.TSU_CODE%TYPE := OKL_API.G_MISS_CHAR,
    try_id                         NUMBER := OKL_API.G_MISS_NUM,
    date_trans_occurred            OKL_TRX_ASSETS.DATE_TRANS_OCCURRED%TYPE := OKL_API.G_MISS_DATE,
    trans_number                   NUMBER := OKL_API.G_MISS_NUM,
    comments                       OKL_TRX_ASSETS.COMMENTS%TYPE := OKL_API.G_MISS_CHAR,
    req_asset_id                   NUMBER := OKL_API.G_MISS_NUM,
    total_match_amount             NUMBER := OKL_API.G_MISS_NUM,
--Bug# 2697681 - 11.5.9 Schema changes
    org_id                         NUMBER := OKL_API.G_MISS_NUM,
     --Added by dpsingh for LE uptake
   legal_entity_id          NUMBER := OKL_API.G_MISS_NUM
  ,transaction_date               DATE := OKL_API.G_MISS_DATE);
  g_miss_tasv_rec                         tasv_rec_type;
  TYPE tasv_tbl_type IS TABLE OF tasv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TAS_PVT';
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
    p_tasv_rec                     IN tasv_rec_type,
    x_tasv_rec                     OUT NOCOPY tasv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tasv_tbl_type,
    x_tasv_tbl                     OUT NOCOPY tasv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_rec                     IN tasv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tasv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_rec                     IN tasv_rec_type,
    x_tasv_rec                     OUT NOCOPY tasv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tasv_tbl_type,
    x_tasv_tbl                     OUT NOCOPY tasv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_rec                     IN tasv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tasv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_rec                     IN tasv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tasv_tbl_type);

END OKL_TAS_PVT;

/
