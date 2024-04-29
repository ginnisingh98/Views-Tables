--------------------------------------------------------
--  DDL for Package OKL_BGH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BGH_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSBGHS.pls 115.2 2002/03/29 17:43:55 pkm ship        $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE bgh_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    sequence_number                NUMBER := Okc_Api.G_MISS_NUM,
    date_transmission              OKL_BLLNG_CHRG_HDRS_B.DATE_TRANSMISSION%TYPE := Okc_Api.G_MISS_DATE,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    request_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okc_Api.G_MISS_NUM,
    program_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_update_date            OKL_BLLNG_CHRG_HDRS_B.PROGRAM_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
	trx_status_code				   OKL_BLLNG_CHRG_HDRS_B.TRX_STATUS_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    attribute_category             OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_BLLNG_CHRG_HDRS_B.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_BLLNG_CHRG_HDRS_B.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_BLLNG_CHRG_HDRS_B.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_bgh_rec                          bgh_rec_type;
  TYPE bgh_tbl_type IS TABLE OF bgh_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OklBllngChrgHdrsTlRecType IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    LANGUAGE                       OKL_BLLNG_CHRG_HDRS_TL.LANGUAGE%TYPE := Okc_Api.G_MISS_CHAR,
    source_lang                    OKL_BLLNG_CHRG_HDRS_TL.SOURCE_LANG%TYPE := Okc_Api.G_MISS_CHAR,
    sfwt_flag                      OKL_BLLNG_CHRG_HDRS_TL.SFWT_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    name                           OKL_BLLNG_CHRG_HDRS_TL.NAME%TYPE := Okc_Api.G_MISS_CHAR,
    origin                         OKL_BLLNG_CHRG_HDRS_TL.ORIGIN%TYPE := Okc_Api.G_MISS_CHAR,
    destination                    OKL_BLLNG_CHRG_HDRS_TL.DESTINATION%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_BLLNG_CHRG_HDRS_TL.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_BLLNG_CHRG_HDRS_TL.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  GMissOklBllngChrgHdrsTlRec              OklBllngChrgHdrsTlRecType;
  TYPE OklBllngChrgHdrsTlTblType IS TABLE OF OklBllngChrgHdrsTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE bghv_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    sfwt_flag                      OKL_BLLNG_CHRG_HDRS_V.SFWT_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    name                           OKL_BLLNG_CHRG_HDRS_V.NAME%TYPE := Okc_Api.G_MISS_CHAR,
    sequence_number                NUMBER := Okc_Api.G_MISS_NUM,
    date_transmission              OKL_BLLNG_CHRG_HDRS_V.DATE_TRANSMISSION%TYPE := Okc_Api.G_MISS_DATE,
    origin                         OKL_BLLNG_CHRG_HDRS_V.ORIGIN%TYPE := Okc_Api.G_MISS_CHAR,
    destination                    OKL_BLLNG_CHRG_HDRS_V.DESTINATION%TYPE := Okc_Api.G_MISS_CHAR,
	trx_status_code				   OKL_BLLNG_CHRG_HDRS_V.TRX_STATUS_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    attribute_category             OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_BLLNG_CHRG_HDRS_V.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    request_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okc_Api.G_MISS_NUM,
    program_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_update_date            OKL_BLLNG_CHRG_HDRS_V.PROGRAM_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_BLLNG_CHRG_HDRS_V.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_BLLNG_CHRG_HDRS_V.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_bghv_rec                         bghv_rec_type;
  TYPE bghv_tbl_type IS TABLE OF bghv_rec_type
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
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_BGH_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_rec                     IN bghv_rec_type,
    x_bghv_rec                     OUT NOCOPY bghv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_tbl                     IN bghv_tbl_type,
    x_bghv_tbl                     OUT NOCOPY bghv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_rec                     IN bghv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_tbl                     IN bghv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_rec                     IN bghv_rec_type,
    x_bghv_rec                     OUT NOCOPY bghv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_tbl                     IN bghv_tbl_type,
    x_bghv_tbl                     OUT NOCOPY bghv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_rec                     IN bghv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_tbl                     IN bghv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_rec                     IN bghv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bghv_tbl                     IN bghv_tbl_type);

END Okl_Bgh_Pvt;

 

/
