--------------------------------------------------------
--  DDL for Package OKL_AUL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AUL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSAULS.pls 120.2 2007/02/27 07:06:38 dpsingh ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE aul_rec_type IS RECORD (
    id                             NUMBER := okl_API.G_MISS_NUM,
    SEGMENT                        OKL_ACC_GEN_RUL_LNS.SEGMENT%TYPE := okl_API.G_MISS_CHAR,
    agr_id                         NUMBER := okl_API.G_MISS_NUM,
    source                         OKL_ACC_GEN_RUL_LNS.SOURCE%TYPE := okl_API.G_MISS_CHAR,
    segment_number                 NUMBER := okl_API.G_MISS_NUM,
    object_version_number          NUMBER := okl_API.G_MISS_NUM,
    constants                      OKL_ACC_GEN_RUL_LNS.CONSTANTS%TYPE := okl_API.G_MISS_CHAR,
    attribute_category             OKL_ACC_GEN_RUL_LNS.ATTRIBUTE_CATEGORY%TYPE := okl_API.G_MISS_CHAR,
    attribute1                     OKL_ACC_GEN_RUL_LNS.ATTRIBUTE1%TYPE := okl_API.G_MISS_CHAR,
    attribute2                     OKL_ACC_GEN_RUL_LNS.ATTRIBUTE2%TYPE := okl_API.G_MISS_CHAR,
    attribute3                     OKL_ACC_GEN_RUL_LNS.ATTRIBUTE3%TYPE := okl_API.G_MISS_CHAR,
    attribute4                     OKL_ACC_GEN_RUL_LNS.ATTRIBUTE4%TYPE := okl_API.G_MISS_CHAR,
    attribute5                     OKL_ACC_GEN_RUL_LNS.ATTRIBUTE5%TYPE := okl_API.G_MISS_CHAR,
    attribute6                     OKL_ACC_GEN_RUL_LNS.ATTRIBUTE6%TYPE := okl_API.G_MISS_CHAR,
    attribute7                     OKL_ACC_GEN_RUL_LNS.ATTRIBUTE7%TYPE := okl_API.G_MISS_CHAR,
    attribute8                     OKL_ACC_GEN_RUL_LNS.ATTRIBUTE8%TYPE := okl_API.G_MISS_CHAR,
    attribute9                     OKL_ACC_GEN_RUL_LNS.ATTRIBUTE9%TYPE := okl_API.G_MISS_CHAR,
    attribute10                    OKL_ACC_GEN_RUL_LNS.ATTRIBUTE10%TYPE := okl_API.G_MISS_CHAR,
    attribute11                    OKL_ACC_GEN_RUL_LNS.ATTRIBUTE11%TYPE := okl_API.G_MISS_CHAR,
    attribute12                    OKL_ACC_GEN_RUL_LNS.ATTRIBUTE12%TYPE := okl_API.G_MISS_CHAR,
    attribute13                    OKL_ACC_GEN_RUL_LNS.ATTRIBUTE13%TYPE := okl_API.G_MISS_CHAR,
    attribute14                    OKL_ACC_GEN_RUL_LNS.ATTRIBUTE14%TYPE := okl_API.G_MISS_CHAR,
    attribute15                    OKL_ACC_GEN_RUL_LNS.ATTRIBUTE15%TYPE := okl_API.G_MISS_CHAR,
    created_by                     NUMBER := okl_API.G_MISS_NUM,
    creation_date                  OKL_ACC_GEN_RUL_LNS.CREATION_DATE%TYPE := okl_API.G_MISS_DATE,
    last_updated_by                NUMBER := okl_API.G_MISS_NUM,
    last_update_date               OKL_ACC_GEN_RUL_LNS.LAST_UPDATE_DATE%TYPE := okl_API.G_MISS_DATE,
    last_update_login              NUMBER := okl_API.G_MISS_NUM);
  g_miss_aul_rec                          aul_rec_type;
  TYPE aul_tbl_type IS TABLE OF aul_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE aulv_rec_type IS RECORD (
    id                             NUMBER := okl_API.G_MISS_NUM,
    object_version_number          NUMBER := okl_API.G_MISS_NUM,
    source                         OKL_ACC_GEN_RUL_LNS_V.SOURCE%TYPE := okl_API.G_MISS_CHAR,
    SEGMENT                        OKL_ACC_GEN_RUL_LNS_V.SEGMENT%TYPE := okl_API.G_MISS_CHAR,
    segment_number                 NUMBER := okl_API.G_MISS_NUM,
    constants                   OKL_ACC_GEN_RUL_LNS_V.constants%TYPE := okl_API.G_MISS_CHAR,
    attribute_category             OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE_CATEGORY%TYPE := okl_API.G_MISS_CHAR,
    attribute1                     OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE1%TYPE := okl_API.G_MISS_CHAR,
    attribute2                     OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE2%TYPE := okl_API.G_MISS_CHAR,
    attribute3                     OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE3%TYPE := okl_API.G_MISS_CHAR,
    attribute4                     OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE4%TYPE := okl_API.G_MISS_CHAR,
    attribute5                     OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE5%TYPE := okl_API.G_MISS_CHAR,
    attribute6                     OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE6%TYPE := okl_API.G_MISS_CHAR,
    attribute7                     OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE7%TYPE := okl_API.G_MISS_CHAR,
    attribute8                     OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE8%TYPE := okl_API.G_MISS_CHAR,
    attribute9                     OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE9%TYPE := okl_API.G_MISS_CHAR,
    attribute10                    OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE10%TYPE := okl_API.G_MISS_CHAR,
    attribute11                    OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE11%TYPE := okl_API.G_MISS_CHAR,
    attribute12                    OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE12%TYPE := okl_API.G_MISS_CHAR,
    attribute13                    OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE13%TYPE := okl_API.G_MISS_CHAR,
    attribute14                    OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE14%TYPE := okl_API.G_MISS_CHAR,
    attribute15                    OKL_ACC_GEN_RUL_LNS_V.ATTRIBUTE15%TYPE := okl_API.G_MISS_CHAR,
    agr_id                         NUMBER := okl_API.G_MISS_NUM,
    created_by                     NUMBER := okl_API.G_MISS_NUM,
    creation_date                  OKL_ACC_GEN_RUL_LNS_V.CREATION_DATE%TYPE := okl_API.G_MISS_DATE,
    last_updated_by                NUMBER := okl_API.G_MISS_NUM,
    last_update_date               OKL_ACC_GEN_RUL_LNS_V.LAST_UPDATE_DATE%TYPE := okl_API.G_MISS_DATE,
    last_update_login              NUMBER := okl_API.G_MISS_NUM);
  g_miss_aulv_rec                         aulv_rec_type;
  TYPE aulv_tbl_type IS TABLE OF aulv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := okl_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := okl_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := okl_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := okl_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := okl_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := okl_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := okl_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := okl_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := okl_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := okl_API.G_CHILD_TABLE_TOKEN;
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AUL_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  okl_API.G_APP_NAME;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type,
    x_aulv_rec                     OUT NOCOPY aulv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type,
    x_aulv_tbl                     OUT NOCOPY aulv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type,
    x_aulv_rec                     OUT NOCOPY aulv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type,
    x_aulv_tbl                     OUT NOCOPY aulv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_rec                     IN aulv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aulv_tbl                     IN aulv_tbl_type);

END OKL_AUL_PVT;

/
