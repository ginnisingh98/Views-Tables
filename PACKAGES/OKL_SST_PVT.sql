--------------------------------------------------------
--  DDL for Package OKL_SST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SST_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSSTS.pls 115.3 2002/04/05 09:56:27 pkm ship        $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
/*  -- history tables not supported -- 04 APR 2002
  TYPE okl_srch_strm_typs_h_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    major_version                  NUMBER := Okl_Api.G_MISS_NUM,
    sty_id                         NUMBER := Okl_Api.G_MISS_NUM,
    cah_id                         NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    add_yn                         OKL_SRCH_STRM_TYPS_H.ADD_YN%TYPE := Okl_Api.G_MISS_CHAR,
    attribute_category             OKL_SRCH_STRM_TYPS_H.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_SRCH_STRM_TYPS_H.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_SRCH_STRM_TYPS_H.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_SRCH_STRM_TYPS_H.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_SRCH_STRM_TYPS_H.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_SRCH_STRM_TYPS_H.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_SRCH_STRM_TYPS_H.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_SRCH_STRM_TYPS_H.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_SRCH_STRM_TYPS_H.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_SRCH_STRM_TYPS_H.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_SRCH_STRM_TYPS_H.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_SRCH_STRM_TYPS_H.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_SRCH_STRM_TYPS_H.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_SRCH_STRM_TYPS_H.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_SRCH_STRM_TYPS_H.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_SRCH_STRM_TYPS_H.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_SRCH_STRM_TYPS_H.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_SRCH_STRM_TYPS_H.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  GMissOklSrchStrmTypsHRec                okl_srch_strm_typs_h_rec_type;
  TYPE okl_srch_strm_typs_h_tbl_type IS TABLE OF okl_srch_strm_typs_h_rec_type
        INDEX BY BINARY_INTEGER;
*/  -- history tables not supported -- 04 APR 2002
  TYPE sst_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    sty_id                         NUMBER := Okl_Api.G_MISS_NUM,
    cah_id                         NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    add_yn                         OKL_SRCH_STRM_TYPS.ADD_YN%TYPE := Okl_Api.G_MISS_CHAR,
    attribute_category             OKL_SRCH_STRM_TYPS.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_SRCH_STRM_TYPS.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_SRCH_STRM_TYPS.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_SRCH_STRM_TYPS.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_SRCH_STRM_TYPS.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_SRCH_STRM_TYPS.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_SRCH_STRM_TYPS.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_SRCH_STRM_TYPS.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_SRCH_STRM_TYPS.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_SRCH_STRM_TYPS.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_SRCH_STRM_TYPS.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_SRCH_STRM_TYPS.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_SRCH_STRM_TYPS.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_SRCH_STRM_TYPS.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_SRCH_STRM_TYPS.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_SRCH_STRM_TYPS.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_SRCH_STRM_TYPS.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_SRCH_STRM_TYPS.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  g_miss_sst_rec                          sst_rec_type;
  TYPE sst_tbl_type IS TABLE OF sst_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE sstv_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_Api.G_MISS_NUM,
    sty_id                         NUMBER := Okl_Api.G_MISS_NUM,
    cah_id                         NUMBER := Okl_Api.G_MISS_NUM,
    add_yn                         OKL_SRCH_STRM_TYPS_V.ADD_YN%TYPE := Okl_Api.G_MISS_CHAR,
    attribute_category             OKL_SRCH_STRM_TYPS_V.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_SRCH_STRM_TYPS_V.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_SRCH_STRM_TYPS_V.ATTRIBUTE2%TYPE := Okl_Api.G_MISS_CHAR,
    attribute3                     OKL_SRCH_STRM_TYPS_V.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_SRCH_STRM_TYPS_V.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_SRCH_STRM_TYPS_V.ATTRIBUTE5%TYPE := Okl_Api.G_MISS_CHAR,
    attribute6                     OKL_SRCH_STRM_TYPS_V.ATTRIBUTE6%TYPE := Okl_Api.G_MISS_CHAR,
    attribute7                     OKL_SRCH_STRM_TYPS_V.ATTRIBUTE7%TYPE := Okl_Api.G_MISS_CHAR,
    attribute8                     OKL_SRCH_STRM_TYPS_V.ATTRIBUTE8%TYPE := Okl_Api.G_MISS_CHAR,
    attribute9                     OKL_SRCH_STRM_TYPS_V.ATTRIBUTE9%TYPE := Okl_Api.G_MISS_CHAR,
    attribute10                    OKL_SRCH_STRM_TYPS_V.ATTRIBUTE10%TYPE := Okl_Api.G_MISS_CHAR,
    attribute11                    OKL_SRCH_STRM_TYPS_V.ATTRIBUTE11%TYPE := Okl_Api.G_MISS_CHAR,
    attribute12                    OKL_SRCH_STRM_TYPS_V.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_SRCH_STRM_TYPS_V.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_SRCH_STRM_TYPS_V.ATTRIBUTE14%TYPE := Okl_Api.G_MISS_CHAR,
    attribute15                    OKL_SRCH_STRM_TYPS_V.ATTRIBUTE15%TYPE := Okl_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_SRCH_STRM_TYPS_V.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_Api.G_MISS_NUM,
    last_update_date               OKL_SRCH_STRM_TYPS_V.LAST_UPDATE_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  g_miss_sstv_rec                         sstv_rec_type;
  TYPE sstv_tbl_type IS TABLE OF sstv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SST_PVT';
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

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_TRX_AR_INVOICES_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_rec                     IN sstv_rec_type,
    x_sstv_rec                     OUT NOCOPY sstv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_tbl                     IN sstv_tbl_type,
    x_sstv_tbl                     OUT NOCOPY sstv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_rec                     IN sstv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_tbl                     IN sstv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_rec                     IN sstv_rec_type,
    x_sstv_rec                     OUT NOCOPY sstv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_tbl                     IN sstv_tbl_type,
    x_sstv_tbl                     OUT NOCOPY sstv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_rec                     IN sstv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_tbl                     IN sstv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_rec                     IN sstv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_tbl                     IN sstv_tbl_type);

END Okl_Sst_Pvt;

 

/
