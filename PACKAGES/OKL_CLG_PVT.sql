--------------------------------------------------------
--  DDL for Package OKL_CLG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CLG_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSCLGS.pls 120.2 2006/11/17 10:28:25 zrehman noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE clg_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    currency_code                  OKL_CNTR_LVLNG_GRPS_B.CURRENCY_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    inf_id                         NUMBER := Okc_Api.G_MISS_NUM,
    ica_id                         NUMBER := Okc_Api.G_MISS_NUM,
    ibt_id                         NUMBER := Okc_Api.G_MISS_NUM,
    irm_id                         NUMBER := Okc_Api.G_MISS_NUM,
    iuv_id                         NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    attribute_category             OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_CNTR_LVLNG_GRPS_B.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_CNTR_LVLNG_GRPS_B.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_CNTR_LVLNG_GRPS_B.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM,
    effective_date_from           OKL_CNTR_LVLNG_GRPS_B.EFFECTIVE_DATE_FROM%TYPE := Okc_Api.G_MISS_DATE,
    effective_date_to             OKL_CNTR_LVLNG_GRPS_B.EFFECTIVE_DATE_TO%TYPE := Okc_Api.G_MISS_DATE,
    ipl_id                         NUMBER := Okc_Api.G_MISS_NUM,
    legal_entity_id                OKL_CNTR_LVLNG_GRPS_B.LEGAL_ENTITY_ID%TYPE := Okc_Api.G_MISS_NUM); -- for LE Uptake project 08-11-2006
  g_miss_clg_rec                          clg_rec_type;
  TYPE clg_tbl_type IS TABLE OF clg_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OklCntrLvlngGrpsTlRecType IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    LANGUAGE                       OKL_CNTR_LVLNG_GRPS_TL.LANGUAGE%TYPE := Okc_Api.G_MISS_CHAR,
    source_lang                    OKL_CNTR_LVLNG_GRPS_TL.SOURCE_LANG%TYPE := Okc_Api.G_MISS_CHAR,
    sfwt_flag                      OKL_CNTR_LVLNG_GRPS_TL.SFWT_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    name                           OKL_CNTR_LVLNG_GRPS_TL.NAME%TYPE := Okc_Api.G_MISS_CHAR,
    description                    OKL_CNTR_LVLNG_GRPS_TL.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR,
    private_label_logo_url         OKL_CNTR_LVLNG_GRPS_TL.PRIVATE_LABEL_LOGO_URL%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_CNTR_LVLNG_GRPS_TL.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_CNTR_LVLNG_GRPS_TL.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  GMissOklCntrLvlngGrpsTlRec              OklCntrLvlngGrpsTlRecType;
  TYPE OklCntrLvlngGrpsTlTblType IS TABLE OF OklCntrLvlngGrpsTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE clgv_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    org_id                             NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    sfwt_flag                      OKL_CNTR_LVLNG_GRPS_V.SFWT_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    inf_id                         NUMBER := Okc_Api.G_MISS_NUM,
    ica_id                         NUMBER := Okc_Api.G_MISS_NUM,
    ibt_id                         NUMBER := Okc_Api.G_MISS_NUM,
    currency_code                  OKL_CNTR_LVLNG_GRPS_V.CURRENCY_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    irm_id                         NUMBER := Okc_Api.G_MISS_NUM,
    iuv_id                         NUMBER := Okc_Api.G_MISS_NUM,
    name                           OKL_CNTR_LVLNG_GRPS_V.NAME%TYPE := Okc_Api.G_MISS_CHAR,
    description                    OKL_CNTR_LVLNG_GRPS_V.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR,
    private_label_logo_url         OKL_CNTR_LVLNG_GRPS_V.PRIVATE_LABEL_LOGO_URL%TYPE := Okc_Api.G_MISS_CHAR,
    attribute_category             OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_CNTR_LVLNG_GRPS_V.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_CNTR_LVLNG_GRPS_V.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_CNTR_LVLNG_GRPS_V.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM,
    effective_date_from           OKL_CNTR_LVLNG_GRPS_B.EFFECTIVE_DATE_FROM%TYPE := Okc_Api.G_MISS_DATE,
    effective_date_to             OKL_CNTR_LVLNG_GRPS_B.EFFECTIVE_DATE_TO%TYPE := Okc_Api.G_MISS_DATE,
    ipl_id                         NUMBER := Okc_Api.G_MISS_NUM,
    legal_entity_id                OKL_CNTR_LVLNG_GRPS_V.LEGAL_ENTITY_ID%TYPE := Okc_Api.G_MISS_NUM); -- for LE Uptake project 08-11-2006
  g_miss_clgv_rec                         clgv_rec_type;
  TYPE clgv_tbl_type IS TABLE OF clgv_rec_type
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

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_NOT_SAME                CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CLG_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

  G_VIEW   CONSTANT   VARCHAR2(30) := 'OKL_XTD_SELL_INVS_V';
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
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_rec                     IN clgv_rec_type,
    x_clgv_rec                     OUT NOCOPY clgv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_tbl                     IN clgv_tbl_type,
    x_clgv_tbl                     OUT NOCOPY clgv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_rec                     IN clgv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_tbl                     IN clgv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_rec                     IN clgv_rec_type,
    x_clgv_rec                     OUT NOCOPY clgv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_tbl                     IN clgv_tbl_type,
    x_clgv_tbl                     OUT NOCOPY clgv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_rec                     IN clgv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_tbl                     IN clgv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_rec                     IN clgv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clgv_tbl                     IN clgv_tbl_type);

END Okl_Clg_Pvt;


/
