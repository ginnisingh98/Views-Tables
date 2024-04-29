--------------------------------------------------------
--  DDL for Package OKL_ASR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ASR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSASRS.pls 115.1 2002/02/05 12:14:45 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE asr_rec_type IS RECORD (
    id                             NUMBER := okl_api.G_MISS_NUM,
    ant_id                         NUMBER := okl_api.G_MISS_NUM,
    qcn_id                         NUMBER := okl_api.G_MISS_NUM,
    sort_sequence                  NUMBER := okl_api.G_MISS_NUM,
    object_version_number          NUMBER := okl_api.G_MISS_NUM,
    attribute_category             OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE_CATEGORY%TYPE := okl_api.G_MISS_CHAR,
    attribute1                     OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE1%TYPE := okl_api.G_MISS_CHAR,
    attribute2                     OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE2%TYPE := okl_api.G_MISS_CHAR,
    attribute3                     OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE3%TYPE := okl_api.G_MISS_CHAR,
    attribute4                     OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE4%TYPE := okl_api.G_MISS_CHAR,
    attribute5                     OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE5%TYPE := okl_api.G_MISS_CHAR,
    attribute6                     OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE6%TYPE := okl_api.G_MISS_CHAR,
    attribute7                     OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE7%TYPE := okl_api.G_MISS_CHAR,
    attribute8                     OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE8%TYPE := okl_api.G_MISS_CHAR,
    attribute9                     OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE9%TYPE := okl_api.G_MISS_CHAR,
    attribute10                    OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE10%TYPE := okl_api.G_MISS_CHAR,
    attribute11                    OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE11%TYPE := okl_api.G_MISS_CHAR,
    attribute12                    OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE12%TYPE := okl_api.G_MISS_CHAR,
    attribute13                    OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE13%TYPE := okl_api.G_MISS_CHAR,
    attribute14                    OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE14%TYPE := okl_api.G_MISS_CHAR,
    attribute15                    OKL_ANSR_SET_CRTRIA_B.ATTRIBUTE15%TYPE := okl_api.G_MISS_CHAR,
    created_by                     NUMBER := okl_api.G_MISS_NUM,
    creation_date                  OKL_ANSR_SET_CRTRIA_B.CREATION_DATE%TYPE := okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := okl_api.G_MISS_NUM,
    last_update_date               OKL_ANSR_SET_CRTRIA_B.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE,
    last_update_login              NUMBER := okl_api.G_MISS_NUM);
  g_miss_asr_rec                          asr_rec_type;
  TYPE asr_tbl_type IS TABLE OF asr_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OklAnsrSetCrtriaTlRecType IS RECORD (
    id                             NUMBER := okl_api.G_MISS_NUM,
    LANGUAGE                       OKL_ANSR_SET_CRTRIA_TL.LANGUAGE%TYPE := okl_api.G_MISS_CHAR,
    source_lang                    OKL_ANSR_SET_CRTRIA_TL.SOURCE_LANG%TYPE := okl_api.G_MISS_CHAR,
    sfwt_flag                      OKL_ANSR_SET_CRTRIA_TL.SFWT_FLAG%TYPE := okl_api.G_MISS_CHAR,
    description                    OKL_ANSR_SET_CRTRIA_TL.DESCRIPTION%TYPE := okl_api.G_MISS_CHAR,
    created_by                     NUMBER := okl_api.G_MISS_NUM,
    creation_date                  OKL_ANSR_SET_CRTRIA_TL.CREATION_DATE%TYPE := okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := okl_api.G_MISS_NUM,
    last_update_date               OKL_ANSR_SET_CRTRIA_TL.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE,
    last_update_login              NUMBER := okl_api.G_MISS_NUM);
  GMissOklAnsrSetCrtriaTlRec              OklAnsrSetCrtriaTlRecType;
  TYPE OklAnsrSetCrtriaTlTblType IS TABLE OF OklAnsrSetCrtriaTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE asrv_rec_type IS RECORD (
    id                             NUMBER := okl_api.G_MISS_NUM,
    object_version_number          NUMBER := okl_api.G_MISS_NUM,
    sfwt_flag                      OKL_ANSR_SET_CRTRIA_V.SFWT_FLAG%TYPE := okl_api.G_MISS_CHAR,
    ant_id                         NUMBER := okl_api.G_MISS_NUM,
    qcn_id                         NUMBER := okl_api.G_MISS_NUM,
    sort_sequence                  NUMBER := okl_api.G_MISS_NUM,
    description                    OKL_ANSR_SET_CRTRIA_V.DESCRIPTION%TYPE := okl_api.G_MISS_CHAR,
    attribute_category             OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE_CATEGORY%TYPE := okl_api.G_MISS_CHAR,
    attribute1                     OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE1%TYPE := okl_api.G_MISS_CHAR,
    attribute2                     OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE2%TYPE := okl_api.G_MISS_CHAR,
    attribute3                     OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE3%TYPE := okl_api.G_MISS_CHAR,
    attribute4                     OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE4%TYPE := okl_api.G_MISS_CHAR,
    attribute5                     OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE5%TYPE := okl_api.G_MISS_CHAR,
    attribute6                     OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE6%TYPE := okl_api.G_MISS_CHAR,
    attribute7                     OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE7%TYPE := okl_api.G_MISS_CHAR,
    attribute8                     OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE8%TYPE := okl_api.G_MISS_CHAR,
    attribute9                     OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE9%TYPE := okl_api.G_MISS_CHAR,
    attribute10                    OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE10%TYPE := okl_api.G_MISS_CHAR,
    attribute11                    OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE11%TYPE := okl_api.G_MISS_CHAR,
    attribute12                    OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE12%TYPE := okl_api.G_MISS_CHAR,
    attribute13                    OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE13%TYPE := okl_api.G_MISS_CHAR,
    attribute14                    OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE14%TYPE := okl_api.G_MISS_CHAR,
    attribute15                    OKL_ANSR_SET_CRTRIA_V.ATTRIBUTE15%TYPE := okl_api.G_MISS_CHAR,
    created_by                     NUMBER := okl_api.G_MISS_NUM,
    creation_date                  OKL_ANSR_SET_CRTRIA_V.CREATION_DATE%TYPE := okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := okl_api.G_MISS_NUM,
    last_update_date               OKL_ANSR_SET_CRTRIA_V.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE,
    last_update_login              NUMBER := okl_api.G_MISS_NUM);
  g_miss_asrv_rec                         asrv_rec_type;
  TYPE asrv_tbl_type IS TABLE OF asrv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := okl_api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := okl_api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := okl_api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := okl_api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := okl_api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := okl_api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := okl_api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := okl_api.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_ASR_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  okl_api.G_APP_NAME;

  /******************ADDED AFTER TAPI, (05/23/2001) ****************/
  --GLOBAL MESSAGES
   G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
   G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
   G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
   G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
   G_NOT_SAME              		CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';


--GLOBAL VARIABLES
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_ANSR_SET_CRTRIA_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;

/****************END ADDITION AFTER TAPI, (05/23/2001)**************/

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asrv_rec                     IN asrv_rec_type,
    x_asrv_rec                     OUT NOCOPY asrv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asrv_tbl                     IN asrv_tbl_type,
    x_asrv_tbl                     OUT NOCOPY asrv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asrv_rec                     IN asrv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asrv_tbl                     IN asrv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asrv_rec                     IN asrv_rec_type,
    x_asrv_rec                     OUT NOCOPY asrv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asrv_tbl                     IN asrv_tbl_type,
    x_asrv_tbl                     OUT NOCOPY asrv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asrv_rec                     IN asrv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asrv_tbl                     IN asrv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asrv_rec                     IN asrv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asrv_tbl                     IN asrv_tbl_type);

END Okl_Asr_Pvt;

 

/
