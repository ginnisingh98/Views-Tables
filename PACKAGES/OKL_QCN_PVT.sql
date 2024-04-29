--------------------------------------------------------
--  DDL for Package OKL_QCN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_QCN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSQCNS.pls 115.1 2002/02/05 12:19:17 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE qcn_rec_type IS RECORD (
    id                             NUMBER := okl_api.G_MISS_NUM,
    crn_id                         NUMBER := okl_api.G_MISS_NUM,
    qty_id                         NUMBER := okl_api.G_MISS_NUM,
    object_version_number          NUMBER := okl_api.G_MISS_NUM,
    attribute_category             OKL_QUESTION_CRTRNS.ATTRIBUTE_CATEGORY%TYPE := okl_api.G_MISS_CHAR,
    attribute1                     OKL_QUESTION_CRTRNS.ATTRIBUTE1%TYPE := okl_api.G_MISS_CHAR,
    attribute2                     OKL_QUESTION_CRTRNS.ATTRIBUTE2%TYPE := okl_api.G_MISS_CHAR,
    attribute3                     OKL_QUESTION_CRTRNS.ATTRIBUTE3%TYPE := okl_api.G_MISS_CHAR,
    attribute4                     OKL_QUESTION_CRTRNS.ATTRIBUTE4%TYPE := okl_api.G_MISS_CHAR,
    attribute5                     OKL_QUESTION_CRTRNS.ATTRIBUTE5%TYPE := okl_api.G_MISS_CHAR,
    attribute6                     OKL_QUESTION_CRTRNS.ATTRIBUTE6%TYPE := okl_api.G_MISS_CHAR,
    attribute7                     OKL_QUESTION_CRTRNS.ATTRIBUTE7%TYPE := okl_api.G_MISS_CHAR,
    attribute8                     OKL_QUESTION_CRTRNS.ATTRIBUTE8%TYPE := okl_api.G_MISS_CHAR,
    attribute9                     OKL_QUESTION_CRTRNS.ATTRIBUTE9%TYPE := okl_api.G_MISS_CHAR,
    attribute10                    OKL_QUESTION_CRTRNS.ATTRIBUTE10%TYPE := okl_api.G_MISS_CHAR,
    attribute11                    OKL_QUESTION_CRTRNS.ATTRIBUTE11%TYPE := okl_api.G_MISS_CHAR,
    attribute12                    OKL_QUESTION_CRTRNS.ATTRIBUTE12%TYPE := Okl_Api.G_MISS_CHAR,
    attribute13                    OKL_QUESTION_CRTRNS.ATTRIBUTE13%TYPE := Okl_Api.G_MISS_CHAR,
    attribute14                    OKL_QUESTION_CRTRNS.ATTRIBUTE14%TYPE := okl_api.G_MISS_CHAR,
    attribute15                    OKL_QUESTION_CRTRNS.ATTRIBUTE15%TYPE := okl_api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_QUESTION_CRTRNS.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := okl_api.G_MISS_NUM,
    last_update_date               OKL_QUESTION_CRTRNS.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE,
    last_update_login              NUMBER := okl_api.G_MISS_NUM);
  g_miss_qcn_rec                          qcn_rec_type;
  TYPE qcn_tbl_type IS TABLE OF qcn_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE qcnv_rec_type IS RECORD (
    id                             NUMBER := okl_api.G_MISS_NUM,
    object_version_number          NUMBER := okl_api.G_MISS_NUM,
    crn_id                         NUMBER := okl_api.G_MISS_NUM,
    qty_id                         NUMBER := okl_api.G_MISS_NUM,
    attribute_category             OKL_QUESTION_CRTRNS_V.ATTRIBUTE_CATEGORY%TYPE := okl_api.G_MISS_CHAR,
    attribute1                     OKL_QUESTION_CRTRNS_V.ATTRIBUTE1%TYPE := okl_api.G_MISS_CHAR,
    attribute2                     OKL_QUESTION_CRTRNS_V.ATTRIBUTE2%TYPE := okl_api.G_MISS_CHAR,
    attribute3                     OKL_QUESTION_CRTRNS_V.ATTRIBUTE3%TYPE := okl_api.G_MISS_CHAR,
    attribute4                     OKL_QUESTION_CRTRNS_V.ATTRIBUTE4%TYPE := okl_api.G_MISS_CHAR,
    attribute5                     OKL_QUESTION_CRTRNS_V.ATTRIBUTE5%TYPE := okl_api.G_MISS_CHAR,
    attribute6                     OKL_QUESTION_CRTRNS_V.ATTRIBUTE6%TYPE := okl_api.G_MISS_CHAR,
    attribute7                     OKL_QUESTION_CRTRNS_V.ATTRIBUTE7%TYPE := okl_api.G_MISS_CHAR,
    attribute8                     OKL_QUESTION_CRTRNS_V.ATTRIBUTE8%TYPE := okl_api.G_MISS_CHAR,
    attribute9                     OKL_QUESTION_CRTRNS_V.ATTRIBUTE9%TYPE := okl_api.G_MISS_CHAR,
    attribute10                    OKL_QUESTION_CRTRNS_V.ATTRIBUTE10%TYPE := okl_api.G_MISS_CHAR,
    attribute11                    OKL_QUESTION_CRTRNS_V.ATTRIBUTE11%TYPE := okl_api.G_MISS_CHAR,
    attribute12                    OKL_QUESTION_CRTRNS_V.ATTRIBUTE12%TYPE := okl_api.G_MISS_CHAR,
    attribute13                    OKL_QUESTION_CRTRNS_V.ATTRIBUTE13%TYPE := okl_api.G_MISS_CHAR,
    attribute14                    OKL_QUESTION_CRTRNS_V.ATTRIBUTE14%TYPE := okl_api.G_MISS_CHAR,
    attribute15                    OKL_QUESTION_CRTRNS_V.ATTRIBUTE15%TYPE := okl_api.G_MISS_CHAR,
    created_by                     NUMBER := Okl_Api.G_MISS_NUM,
    creation_date                  OKL_QUESTION_CRTRNS_V.CREATION_DATE%TYPE := Okl_Api.G_MISS_DATE,
    last_updated_by                NUMBER := okl_api.G_MISS_NUM,
    last_update_date               OKL_QUESTION_CRTRNS_V.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE,
    last_update_login              NUMBER := Okl_Api.G_MISS_NUM);
  g_miss_qcnv_rec                         qcnv_rec_type;
  TYPE qcnv_tbl_type IS TABLE OF qcnv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_QCN_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  okl_api.G_APP_NAME;

  /******************ADDED AFTER TAPI, (05/23/2001) ****************/
  --GLOBAL MESSAGES
   G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
   G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
   G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
   G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
   G_NOT_SAME              		CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';


--GLOBAL VARIABLES
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_QUESTION_CRTRNS_V';
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
    p_qcnv_rec                     IN qcnv_rec_type,
    x_qcnv_rec                     OUT NOCOPY qcnv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_tbl                     IN qcnv_tbl_type,
    x_qcnv_tbl                     OUT NOCOPY qcnv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_rec                     IN qcnv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_tbl                     IN qcnv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_rec                     IN qcnv_rec_type,
    x_qcnv_rec                     OUT NOCOPY qcnv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_tbl                     IN qcnv_tbl_type,
    x_qcnv_tbl                     OUT NOCOPY qcnv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_rec                     IN qcnv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_tbl                     IN qcnv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_rec                     IN qcnv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcnv_tbl                     IN qcnv_tbl_type);

END Okl_Qcn_Pvt;

 

/
