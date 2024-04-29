--------------------------------------------------------
--  DDL for Package OKL_ESD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ESD_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSESDS.pls 115.2 2002/02/05 12:16:17 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE esd_rec_type IS RECORD (
    id                             NUMBER := Okl_api.G_MISS_NUM,
    xls_id                         NUMBER := Okl_api.G_MISS_NUM,
    ild_id                         NUMBER := Okl_api.G_MISS_NUM,
    account_class                  OKL_XTD_SELL_INVS_B.ACCOUNT_CLASS%TYPE := Okl_api.G_MISS_CHAR,
    code_combination_id            NUMBER := Okl_api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_api.G_MISS_NUM,
    amount                         NUMBER := Okl_api.G_MISS_NUM,
    percent                        NUMBER := Okl_api.G_MISS_NUM,
    request_id                     NUMBER := Okl_api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_api.G_MISS_NUM,
    program_id                     NUMBER := Okl_api.G_MISS_NUM,
    program_update_date            OKL_XTD_SELL_INVS_B.PROGRAM_UPDATE_DATE%TYPE := Okl_api.G_MISS_DATE,
    org_id                         NUMBER := Okl_api.G_MISS_NUM,
    attribute_category             OKL_XTD_SELL_INVS_B.ATTRIBUTE_CATEGORY%TYPE := Okl_api.G_MISS_CHAR,
    attribute1                     OKL_XTD_SELL_INVS_B.ATTRIBUTE1%TYPE := Okl_api.G_MISS_CHAR,
    attribute2                     OKL_XTD_SELL_INVS_B.ATTRIBUTE2%TYPE := Okl_api.G_MISS_CHAR,
    attribute3                     OKL_XTD_SELL_INVS_B.ATTRIBUTE3%TYPE := Okl_api.G_MISS_CHAR,
    attribute4                     OKL_XTD_SELL_INVS_B.ATTRIBUTE4%TYPE := Okl_api.G_MISS_CHAR,
    attribute5                     OKL_XTD_SELL_INVS_B.ATTRIBUTE5%TYPE := Okl_api.G_MISS_CHAR,
    attribute6                     OKL_XTD_SELL_INVS_B.ATTRIBUTE6%TYPE := Okl_api.G_MISS_CHAR,
    attribute7                     OKL_XTD_SELL_INVS_B.ATTRIBUTE7%TYPE := Okl_api.G_MISS_CHAR,
    attribute8                     OKL_XTD_SELL_INVS_B.ATTRIBUTE8%TYPE := Okl_api.G_MISS_CHAR,
    attribute9                     OKL_XTD_SELL_INVS_B.ATTRIBUTE9%TYPE := Okl_api.G_MISS_CHAR,
    attribute10                    OKL_XTD_SELL_INVS_B.ATTRIBUTE10%TYPE := Okl_api.G_MISS_CHAR,
    attribute11                    OKL_XTD_SELL_INVS_B.ATTRIBUTE11%TYPE := Okl_api.G_MISS_CHAR,
    attribute12                    OKL_XTD_SELL_INVS_B.ATTRIBUTE12%TYPE := Okl_api.G_MISS_CHAR,
    attribute13                    OKL_XTD_SELL_INVS_B.ATTRIBUTE13%TYPE := Okl_api.G_MISS_CHAR,
    attribute14                    OKL_XTD_SELL_INVS_B.ATTRIBUTE14%TYPE := Okl_api.G_MISS_CHAR,
    attribute15                    OKL_XTD_SELL_INVS_B.ATTRIBUTE15%TYPE := Okl_api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_api.G_MISS_NUM,
    creation_date                  OKL_XTD_SELL_INVS_B.CREATION_DATE%TYPE := Okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_api.G_MISS_NUM,
    last_update_date               OKL_XTD_SELL_INVS_B.LAST_UPDATE_DATE%TYPE := Okl_api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_api.G_MISS_NUM);
  g_miss_esd_rec                          esd_rec_type;
  TYPE esd_tbl_type IS TABLE OF esd_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_xtd_sell_invs_tl_rec_type IS RECORD (
    id                             NUMBER := Okl_api.G_MISS_NUM,
    LANGUAGE                       OKL_XTD_SELL_INVS_TL.LANGUAGE%TYPE := Okl_api.G_MISS_CHAR,
    source_lang                    OKL_XTD_SELL_INVS_TL.SOURCE_LANG%TYPE := Okl_api.G_MISS_CHAR,
    sfwt_flag                      OKL_XTD_SELL_INVS_TL.SFWT_FLAG%TYPE := Okl_api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_api.G_MISS_NUM,
    creation_date                  OKL_XTD_SELL_INVS_TL.CREATION_DATE%TYPE := Okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_api.G_MISS_NUM,
    last_update_date               OKL_XTD_SELL_INVS_TL.LAST_UPDATE_DATE%TYPE := Okl_api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_api.G_MISS_NUM);
  GMissOklXtdSellInvsTlRec                okl_xtd_sell_invs_tl_rec_type;
  TYPE okl_xtd_sell_invs_tl_tbl_type IS TABLE OF okl_xtd_sell_invs_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE esdv_rec_type IS RECORD (
    id                             NUMBER := Okl_api.G_MISS_NUM,
    object_version_number          NUMBER := Okl_api.G_MISS_NUM,
    sfwt_flag                      OKL_XTD_SELL_INVS_V.SFWT_FLAG%TYPE := Okl_api.G_MISS_CHAR,
    xls_id                         NUMBER := Okl_api.G_MISS_NUM,
    ild_id                         NUMBER := Okl_api.G_MISS_NUM,
    account_class                  OKL_XTD_SELL_INVS_V.ACCOUNT_CLASS%TYPE := Okl_api.G_MISS_CHAR,
    code_combination_id            NUMBER := Okl_api.G_MISS_NUM,
    amount                         NUMBER := Okl_api.G_MISS_NUM,
    percent                        NUMBER := Okl_api.G_MISS_NUM,
    attribute_category             OKL_XTD_SELL_INVS_V.ATTRIBUTE_CATEGORY%TYPE := Okl_api.G_MISS_CHAR,
    attribute1                     OKL_XTD_SELL_INVS_V.ATTRIBUTE1%TYPE := Okl_api.G_MISS_CHAR,
    attribute2                     OKL_XTD_SELL_INVS_V.ATTRIBUTE2%TYPE := Okl_api.G_MISS_CHAR,
    attribute3                     OKL_XTD_SELL_INVS_V.ATTRIBUTE3%TYPE := Okl_api.G_MISS_CHAR,
    attribute4                     OKL_XTD_SELL_INVS_V.ATTRIBUTE4%TYPE := Okl_api.G_MISS_CHAR,
    attribute5                     OKL_XTD_SELL_INVS_V.ATTRIBUTE5%TYPE := Okl_api.G_MISS_CHAR,
    attribute6                     OKL_XTD_SELL_INVS_V.ATTRIBUTE6%TYPE := Okl_api.G_MISS_CHAR,
    attribute7                     OKL_XTD_SELL_INVS_V.ATTRIBUTE7%TYPE := Okl_api.G_MISS_CHAR,
    attribute8                     OKL_XTD_SELL_INVS_V.ATTRIBUTE8%TYPE := Okl_api.G_MISS_CHAR,
    attribute9                     OKL_XTD_SELL_INVS_V.ATTRIBUTE9%TYPE := Okl_api.G_MISS_CHAR,
    attribute10                    OKL_XTD_SELL_INVS_V.ATTRIBUTE10%TYPE := Okl_api.G_MISS_CHAR,
    attribute11                    OKL_XTD_SELL_INVS_V.ATTRIBUTE11%TYPE := Okl_api.G_MISS_CHAR,
    attribute12                    OKL_XTD_SELL_INVS_V.ATTRIBUTE12%TYPE := Okl_api.G_MISS_CHAR,
    attribute13                    OKL_XTD_SELL_INVS_V.ATTRIBUTE13%TYPE := Okl_api.G_MISS_CHAR,
    attribute14                    OKL_XTD_SELL_INVS_V.ATTRIBUTE14%TYPE := Okl_api.G_MISS_CHAR,
    attribute15                    OKL_XTD_SELL_INVS_V.ATTRIBUTE15%TYPE := Okl_api.G_MISS_CHAR,
    request_id                     NUMBER := Okl_api.G_MISS_NUM,
    program_application_id         NUMBER := Okl_api.G_MISS_NUM,
    program_id                     NUMBER := Okl_api.G_MISS_NUM,
    program_update_date            OKL_XTD_SELL_INVS_V.PROGRAM_UPDATE_DATE%TYPE := Okl_api.G_MISS_DATE,
    org_id                         NUMBER := Okl_api.G_MISS_NUM,
    created_by                     NUMBER := Okl_api.G_MISS_NUM,
    creation_date                  OKL_XTD_SELL_INVS_V.CREATION_DATE%TYPE := Okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := Okl_api.G_MISS_NUM,
    last_update_date               OKL_XTD_SELL_INVS_V.LAST_UPDATE_DATE%TYPE := Okl_api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_api.G_MISS_NUM);
  g_miss_esdv_rec                         esdv_rec_type;
  TYPE esdv_tbl_type IS TABLE OF esdv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okl_api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okl_api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okl_api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okl_api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okl_api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okl_api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okl_api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_api.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_ESD_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_api.G_APP_NAME;

/******************ADDED AFTER TAPI, Sunil T. Mathew (04/16/2001) ****************/
  --GLOBAL MESSAGES
   G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
   G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
   G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
   G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
   G_NOT_SAME              		CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';


--GLOBAL VARIABLES
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_XTD_SELL_INVS_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;

  ---------------------------------------------------------------------------
  -- validation Procedures and Functions
  ---------------------------------------------------------------------------
 --PROCEDURE validate_unique(p_saiv_rec 	IN 	saiv_rec_type,
 --                     x_return_status OUT NOCOPY VARCHAR2);

/****************END ADDED AFTER TAPI, Sunil T. Mathew (04/16/2001)**************/

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_esdv_rec                     IN esdv_rec_type,
    x_esdv_rec                     OUT NOCOPY esdv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_esdv_tbl                     IN esdv_tbl_type,
    x_esdv_tbl                     OUT NOCOPY esdv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_esdv_rec                     IN esdv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_esdv_tbl                     IN esdv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_esdv_rec                     IN esdv_rec_type,
    x_esdv_rec                     OUT NOCOPY esdv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_esdv_tbl                     IN esdv_tbl_type,
    x_esdv_tbl                     OUT NOCOPY esdv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_esdv_rec                     IN esdv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_esdv_tbl                     IN esdv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_esdv_rec                     IN esdv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_esdv_tbl                     IN esdv_tbl_type);

END Okl_Esd_Pvt;

 

/
