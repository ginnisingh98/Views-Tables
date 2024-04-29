--------------------------------------------------------
--  DDL for Package OKL_MRB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MRB_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSMRBS.pls 115.1 2002/05/02 15:21:07 pkm ship     $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_MASS_RBK_CRITERIA_V Record Spec
  TYPE mrbv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,request_name                   OKL_MASS_RBK_CRITERIA_V.REQUEST_NAME%TYPE := OKL_API.G_MISS_CHAR
    ,line_number                    NUMBER := OKL_API.G_MISS_NUM
    ,rbr_code                       OKL_MASS_RBK_CRITERIA_V.RBR_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,criteria_code                  OKL_MASS_RBK_CRITERIA_V.CRITERIA_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,operand                        OKL_MASS_RBK_CRITERIA_V.OPERAND%TYPE := OKL_API.G_MISS_CHAR
    ,criteria_value1                OKL_MASS_RBK_CRITERIA_V.CRITERIA_VALUE1%TYPE := OKL_API.G_MISS_CHAR
    ,criteria_value2                OKL_MASS_RBK_CRITERIA_V.CRITERIA_VALUE2%TYPE := OKL_API.G_MISS_CHAR
    ,set_value                      OKL_MASS_RBK_CRITERIA_V.SET_VALUE%TYPE := OKL_API.G_MISS_CHAR
    ,description                    OKL_MASS_RBK_CRITERIA_V.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,tsu_code                       OKL_MASS_RBK_CRITERIA_V.TSU_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_MASS_RBK_CRITERIA_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_MASS_RBK_CRITERIA_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_MASS_RBK_CRITERIA_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_mrbv_rec                         mrbv_rec_type;
  TYPE mrbv_tbl_type IS TABLE OF mrbv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_MASS_RBK_CRITERIA Record Spec
  TYPE mrb_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,request_name                   OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE := OKL_API.G_MISS_CHAR
    ,line_number                    NUMBER := OKL_API.G_MISS_NUM
    ,rbr_code                       OKL_MASS_RBK_CRITERIA.RBR_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,criteria_code                  OKL_MASS_RBK_CRITERIA.CRITERIA_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,operand                        OKL_MASS_RBK_CRITERIA.OPERAND%TYPE := OKL_API.G_MISS_CHAR
    ,criteria_value1                OKL_MASS_RBK_CRITERIA.CRITERIA_VALUE1%TYPE := OKL_API.G_MISS_CHAR
    ,criteria_value2                OKL_MASS_RBK_CRITERIA.CRITERIA_VALUE2%TYPE := OKL_API.G_MISS_CHAR
    ,set_value                      OKL_MASS_RBK_CRITERIA.SET_VALUE%TYPE := OKL_API.G_MISS_CHAR
    ,description                    OKL_MASS_RBK_CRITERIA.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,tsu_code                       OKL_MASS_RBK_CRITERIA.TSU_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_MASS_RBK_CRITERIA.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_MASS_RBK_CRITERIA.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_MASS_RBK_CRITERIA.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_MASS_RBK_CRITERIA.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_MASS_RBK_CRITERIA.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_MASS_RBK_CRITERIA.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_MASS_RBK_CRITERIA.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_MASS_RBK_CRITERIA.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_MASS_RBK_CRITERIA.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_MASS_RBK_CRITERIA.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_MASS_RBK_CRITERIA.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_MASS_RBK_CRITERIA.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_MASS_RBK_CRITERIA.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_MASS_RBK_CRITERIA.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_MASS_RBK_CRITERIA.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_MASS_RBK_CRITERIA.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_MASS_RBK_CRITERIA.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_MASS_RBK_CRITERIA.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_mrb_rec                          mrb_rec_type;
  TYPE mrb_tbl_type IS TABLE OF mrb_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_MRB_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
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
    p_mrbv_rec                     IN mrbv_rec_type,
    x_mrbv_rec                     OUT NOCOPY mrbv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrbv_tbl                     IN mrbv_tbl_type,
    x_mrbv_tbl                     OUT NOCOPY mrbv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrbv_rec                     IN mrbv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrbv_tbl                     IN mrbv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrbv_rec                     IN mrbv_rec_type,
    x_mrbv_rec                     OUT NOCOPY mrbv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrbv_tbl                     IN mrbv_tbl_type,
    x_mrbv_tbl                     OUT NOCOPY mrbv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrbv_rec                     IN mrbv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrbv_tbl                     IN mrbv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrbv_rec                     IN mrbv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrbv_tbl                     IN mrbv_tbl_type);
END OKL_MRB_PVT;

 

/
