--------------------------------------------------------
--  DDL for Package OKL_ASV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ASV_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSASVS.pls 115.1 2002/02/05 12:14:48 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE asv_rec_type IS RECORD (
    id                             NUMBER := okl_api.G_MISS_NUM,
    asr_id                         NUMBER := okl_api.G_MISS_NUM,
    sequence_number                NUMBER := okl_api.G_MISS_NUM,
    crn_id                         NUMBER := okl_api.G_MISS_NUM,
    asv_type                       OKL_ANSR_SET_CN_VLS.ASV_TYPE%TYPE := okl_api.G_MISS_CHAR,
    object_version_number          NUMBER := okl_api.G_MISS_NUM,
    cvm_from                       OKL_ANSR_SET_CN_VLS.CVM_FROM%TYPE := okl_api.G_MISS_CHAR,
    cvm_to                         OKL_ANSR_SET_CN_VLS.CVM_TO%TYPE := okl_api.G_MISS_CHAR,
    from_object_id1                NUMBER := okl_api.G_MISS_NUM,
    from_object_id2                NUMBER := okl_api.G_MISS_NUM,
    to_object_id1                  NUMBER := okl_api.G_MISS_NUM,
    to_object_id2                  NUMBER := okl_api.G_MISS_NUM,
    attribute_category             OKL_ANSR_SET_CN_VLS.ATTRIBUTE_CATEGORY%TYPE := okl_api.G_MISS_CHAR,
    attribute1                     OKL_ANSR_SET_CN_VLS.ATTRIBUTE1%TYPE := okl_api.G_MISS_CHAR,
    attribute2                     OKL_ANSR_SET_CN_VLS.ATTRIBUTE2%TYPE := okl_api.G_MISS_CHAR,
    attribute3                     OKL_ANSR_SET_CN_VLS.ATTRIBUTE3%TYPE := Okl_Api.G_MISS_CHAR,
    attribute4                     OKL_ANSR_SET_CN_VLS.ATTRIBUTE4%TYPE := Okl_Api.G_MISS_CHAR,
    attribute5                     OKL_ANSR_SET_CN_VLS.ATTRIBUTE5%TYPE := okl_api.G_MISS_CHAR,
    attribute6                     OKL_ANSR_SET_CN_VLS.ATTRIBUTE6%TYPE := okl_api.G_MISS_CHAR,
    attribute7                     OKL_ANSR_SET_CN_VLS.ATTRIBUTE7%TYPE := okl_api.G_MISS_CHAR,
    attribute8                     OKL_ANSR_SET_CN_VLS.ATTRIBUTE8%TYPE := okl_api.G_MISS_CHAR,
    attribute9                     OKL_ANSR_SET_CN_VLS.ATTRIBUTE9%TYPE := okl_api.G_MISS_CHAR,
    attribute10                    OKL_ANSR_SET_CN_VLS.ATTRIBUTE10%TYPE := okl_api.G_MISS_CHAR,
    attribute11                    OKL_ANSR_SET_CN_VLS.ATTRIBUTE11%TYPE := okl_api.G_MISS_CHAR,
    attribute12                    OKL_ANSR_SET_CN_VLS.ATTRIBUTE12%TYPE := okl_api.G_MISS_CHAR,
    attribute13                    OKL_ANSR_SET_CN_VLS.ATTRIBUTE13%TYPE := okl_api.G_MISS_CHAR,
    attribute14                    OKL_ANSR_SET_CN_VLS.ATTRIBUTE14%TYPE := okl_api.G_MISS_CHAR,
    attribute15                    OKL_ANSR_SET_CN_VLS.ATTRIBUTE15%TYPE := okl_api.G_MISS_CHAR,
    created_by                     NUMBER := okl_api.G_MISS_NUM,
    creation_date                  OKL_ANSR_SET_CN_VLS.CREATION_DATE%TYPE := okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := okl_api.G_MISS_NUM,
    last_update_date               OKL_ANSR_SET_CN_VLS.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE,
    last_update_login              NUMBER := okl_api.G_MISS_NUM);
  g_miss_asv_rec                          asv_rec_type;
  TYPE asv_tbl_type IS TABLE OF asv_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE asvv_rec_type IS RECORD (
    id                             NUMBER := okl_api.G_MISS_NUM,
    object_version_number          NUMBER := okl_api.G_MISS_NUM,
    asr_id                         NUMBER := okl_api.G_MISS_NUM,
    crn_id                         NUMBER := okl_api.G_MISS_NUM,
    from_object_id1                NUMBER := okl_api.G_MISS_NUM,
    from_object_id2                NUMBER := okl_api.G_MISS_NUM,
    to_object_id1                  NUMBER := okl_api.G_MISS_NUM,
    to_object_id2                  NUMBER := okl_api.G_MISS_NUM,
    sequence_number                NUMBER := okl_api.G_MISS_NUM,
    cvm_from                       OKL_ANSR_SET_CN_VLS_V.CVM_FROM%TYPE := okl_api.G_MISS_CHAR,
    cvm_to                         OKL_ANSR_SET_CN_VLS_V.CVM_TO%TYPE := okl_api.G_MISS_CHAR,
    attribute_category             OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE_CATEGORY%TYPE := Okl_Api.G_MISS_CHAR,
    attribute1                     OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE1%TYPE := Okl_Api.G_MISS_CHAR,
    attribute2                     OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE2%TYPE := okl_api.G_MISS_CHAR,
    attribute3                     OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE3%TYPE := okl_api.G_MISS_CHAR,
    attribute4                     OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE4%TYPE := okl_api.G_MISS_CHAR,
    attribute5                     OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE5%TYPE := okl_api.G_MISS_CHAR,
    attribute6                     OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE6%TYPE := okl_api.G_MISS_CHAR,
    attribute7                     OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE7%TYPE := okl_api.G_MISS_CHAR,
    attribute8                     OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE8%TYPE := okl_api.G_MISS_CHAR,
    attribute9                     OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE9%TYPE := okl_api.G_MISS_CHAR,
    attribute10                    OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE10%TYPE := okl_api.G_MISS_CHAR,
    attribute11                    OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE11%TYPE := okl_api.G_MISS_CHAR,
    attribute12                    OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE12%TYPE := okl_api.G_MISS_CHAR,
    attribute13                    OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE13%TYPE := okl_api.G_MISS_CHAR,
    attribute14                    OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE14%TYPE := okl_api.G_MISS_CHAR,
    attribute15                    OKL_ANSR_SET_CN_VLS_V.ATTRIBUTE15%TYPE := okl_api.G_MISS_CHAR,
    asv_type                       OKL_ANSR_SET_CN_VLS_V.ASV_TYPE%TYPE := okl_api.G_MISS_CHAR,
    created_by                     NUMBER := okl_api.G_MISS_NUM,
    creation_date                  OKL_ANSR_SET_CN_VLS_V.CREATION_DATE%TYPE := okl_api.G_MISS_DATE,
    last_updated_by                NUMBER := okl_api.G_MISS_NUM,
    last_update_date               OKL_ANSR_SET_CN_VLS_V.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE,
    last_update_login              NUMBER := okl_api.G_MISS_NUM);
  g_miss_asvv_rec                         asvv_rec_type;
  TYPE asvv_tbl_type IS TABLE OF asvv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := okl_api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := okl_api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := okl_api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := okl_api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okl_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okl_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_ASV_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

  /******************ADDED AFTER TAPI, (05/23/2001) ****************/
  --GLOBAL MESSAGES
   G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
   G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
   G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
   G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
   G_NOT_SAME              		CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';


--GLOBAL VARIABLES
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_ANSR_SET_CN_VLS_V';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;

/****************END ADDITION AFTER TAPI, (05/23/2001)**************/

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_rec                     IN asvv_rec_type,
    x_asvv_rec                     OUT NOCOPY asvv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_tbl                     IN asvv_tbl_type,
    x_asvv_tbl                     OUT NOCOPY asvv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_rec                     IN asvv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_tbl                     IN asvv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_rec                     IN asvv_rec_type,
    x_asvv_rec                     OUT NOCOPY asvv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_tbl                     IN asvv_tbl_type,
    x_asvv_tbl                     OUT NOCOPY asvv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_rec                     IN asvv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_tbl                     IN asvv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_rec                     IN asvv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asvv_tbl                     IN asvv_tbl_type);

END Okl_Asv_Pvt;

 

/
