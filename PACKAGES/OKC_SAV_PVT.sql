--------------------------------------------------------
--  DDL for Package OKC_SAV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_SAV_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSSAVS.pls 120.0 2005/05/25 22:53:45 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE sav_rec_type IS RECORD (
    sav_release                    OKC_STD_ART_VERSIONS_B.SAV_RELEASE%TYPE := OKC_API.G_MISS_CHAR,
    sae_id                         NUMBER := OKC_API.G_MISS_NUM,
    date_active                    OKC_STD_ART_VERSIONS_B.DATE_ACTIVE%TYPE := OKC_API.G_MISS_DATE,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_STD_ART_VERSIONS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_STD_ART_VERSIONS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKC_STD_ART_VERSIONS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_STD_ART_VERSIONS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_STD_ART_VERSIONS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_STD_ART_VERSIONS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_STD_ART_VERSIONS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_STD_ART_VERSIONS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_STD_ART_VERSIONS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_STD_ART_VERSIONS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_STD_ART_VERSIONS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_STD_ART_VERSIONS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_STD_ART_VERSIONS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_STD_ART_VERSIONS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_STD_ART_VERSIONS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_STD_ART_VERSIONS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_STD_ART_VERSIONS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_STD_ART_VERSIONS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_sav_rec                          sav_rec_type;
  TYPE sav_tbl_type IS TABLE OF sav_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OkcStdArtVersionsTlRecType IS RECORD (
    sae_id                         NUMBER := OKC_API.G_MISS_NUM,
    sav_release                    OKC_STD_ART_VERSIONS_TL.SAV_RELEASE%TYPE := OKC_API.G_MISS_CHAR,
    language                       OKC_STD_ART_VERSIONS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKC_STD_ART_VERSIONS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKC_STD_ART_VERSIONS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_STD_ART_VERSIONS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_STD_ART_VERSIONS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    text                           OKC_STD_ART_VERSIONS_TL.TEXT%TYPE ,
    short_description              OKC_STD_ART_VERSIONS_TL.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOkcStdArtVersionsTlRec             OkcStdArtVersionsTlRecType;
  TYPE OkcStdArtVersionsTlTblType IS TABLE OF OkcStdArtVersionsTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE savv_rec_type IS RECORD (
    sae_id                         NUMBER := OKC_API.G_MISS_NUM,
    sav_release                    OKC_STD_ART_VERSIONS_V.SAV_RELEASE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_STD_ART_VERSIONS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    date_active                    OKC_STD_ART_VERSIONS_V.DATE_ACTIVE%TYPE := OKC_API.G_MISS_DATE,
    text                           OKC_STD_ART_VERSIONS_V.TEXT%TYPE ,
    short_description              OKC_STD_ART_VERSIONS_V.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_STD_ART_VERSIONS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_STD_ART_VERSIONS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_STD_ART_VERSIONS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_STD_ART_VERSIONS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_STD_ART_VERSIONS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_STD_ART_VERSIONS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_STD_ART_VERSIONS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_STD_ART_VERSIONS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_STD_ART_VERSIONS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_STD_ART_VERSIONS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_STD_ART_VERSIONS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_STD_ART_VERSIONS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_STD_ART_VERSIONS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_STD_ART_VERSIONS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_STD_ART_VERSIONS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_STD_ART_VERSIONS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_STD_ART_VERSIONS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_STD_ART_VERSIONS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_savv_rec                         savv_rec_type;
  TYPE savv_tbl_type IS TABLE OF savv_rec_type
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
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_SAV_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

/******************ADDED AFTER TAPI****************/
  --GLOBAL MESSAGES

   G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
   G_NO_PARENT_RECORD           CONSTANT   varchar2(200) := 'OKC_NO_PARENT_RECORD';
   G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
   G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
   G_NOT_UPPER		        CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
  -- G_LESS_THAN_SYSDATE		CONSTANT VARCHAR2(200) := 'OKC_LESS_THAN_SYSDATE';
   G_LESS_THAN_RELEASE_DATE	CONSTANT VARCHAR2(200) := 'OKC_LESS_THAN_RELEASE_DATE';
   G_ATE_REFERENCES      	CONSTANT VARCHAR2(200) := 'OKC_ATE_REFERENCES';
   G_ATE_CANNOT_DELETE      	CONSTANT VARCHAR2(200) := 'OKC_ATE_CANNOT_DELETE';
   G_NOT_LATEST  	      	CONSTANT VARCHAR2(200) := 'OKC_NOT_LATEST_RELEASE';

--GLOBAL VARIABLES
  G_VIEW			CONSTANT   varchar2(30) := 'OKC_STD_ART_VERSIONS_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;

-------------------------------------------------------------------
--  Individual Field Validation Procedures
-------------------------------------------------------------------
PROCEDURE validate_sav_release(p_savv_rec 	IN 	savv_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE validate_date_active(p_savv_rec 	IN 	savv_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE validate_no_k_attached(p_savv_rec 	IN 	savv_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE validate_latest(p_savv_rec 	IN 	savv_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE validate_updatable(p_savv_rec 	IN 	savv_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2);

/****************END ADDED AFTER TAPI**************/

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type,
    x_savv_rec                     OUT NOCOPY savv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type,
    x_savv_tbl                     OUT NOCOPY savv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type,
    x_savv_rec                     OUT NOCOPY savv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type,
    x_savv_tbl                     OUT NOCOPY savv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_tbl                     IN savv_tbl_type);

END OKC_SAV_PVT;

 

/
