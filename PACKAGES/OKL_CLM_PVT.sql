--------------------------------------------------------
--  DDL for Package OKL_CLM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CLM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSCLMS.pls 115.6 2002/04/11 19:25:23 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_INS_CLAIMS_V Record Spec
   TYPE clmv_rec_type IS RECORD (
       id                             NUMBER := OKC_API.G_MISS_NUM
      ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
      ,sfwt_flag                      OKL_INS_CLAIMS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
      ,ipy_id                         NUMBER := OKC_API.G_MISS_NUM
      ,ltp_code                       OKL_INS_CLAIMS_V.LTP_CODE%TYPE := OKC_API.G_MISS_CHAR
      ,csu_code                       OKL_INS_CLAIMS_V.CSU_CODE%TYPE := OKC_API.G_MISS_CHAR
      ,claim_number                   OKL_INS_CLAIMS_V.CLAIM_NUMBER%TYPE := OKC_API.G_MISS_CHAR
      ,claim_date                     OKL_INS_CLAIMS_V.CLAIM_DATE%TYPE := OKC_API.G_MISS_DATE
      ,loss_date                      OKL_INS_CLAIMS_V.LOSS_DATE%TYPE := OKC_API.G_MISS_DATE
      ,description                    OKL_INS_CLAIMS_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
      ,police_contact                 OKL_INS_CLAIMS_V.POLICE_CONTACT%TYPE := OKC_API.G_MISS_CHAR
      ,police_report                  OKL_INS_CLAIMS_V.POLICE_REPORT%TYPE := OKC_API.G_MISS_CHAR
      ,amount                         NUMBER := OKC_API.G_MISS_NUM
      ,attribute_category             OKL_INS_CLAIMS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
      ,attribute1                     OKL_INS_CLAIMS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
      ,attribute2                     OKL_INS_CLAIMS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
      ,attribute3                     OKL_INS_CLAIMS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
      ,attribute4                     OKL_INS_CLAIMS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
      ,attribute5                     OKL_INS_CLAIMS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
      ,attribute6                     OKL_INS_CLAIMS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
      ,attribute7                     OKL_INS_CLAIMS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
      ,attribute8                     OKL_INS_CLAIMS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
      ,attribute9                     OKL_INS_CLAIMS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
      ,attribute10                    OKL_INS_CLAIMS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
      ,attribute11                    OKL_INS_CLAIMS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
      ,attribute12                    OKL_INS_CLAIMS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
      ,attribute13                    OKL_INS_CLAIMS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
      ,attribute14                    OKL_INS_CLAIMS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
      ,attribute15                    OKL_INS_CLAIMS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
      ,hold_date                      OKL_INS_CLAIMS_V.HOLD_DATE%TYPE := OKC_API.G_MISS_DATE
      ,org_id                         NUMBER := OKC_API.G_MISS_NUM
      ,request_id                     NUMBER := OKC_API.G_MISS_NUM
      ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
      ,program_id                     NUMBER := OKC_API.G_MISS_NUM
      ,program_update_date            OKL_INS_CLAIMS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
      ,created_by                     NUMBER := OKC_API.G_MISS_NUM
      ,creation_date                  OKL_INS_CLAIMS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
      ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
      ,last_update_date               OKL_INS_CLAIMS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
      ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
    G_MISS_clmv_rec                         clmv_rec_type;
    TYPE clmv_tbl_type IS TABLE OF clmv_rec_type
          INDEX BY BINARY_INTEGER;
    -- OKL_INS_CLAIMS_B Record Spec
    TYPE clm_rec_type IS RECORD (
       id                             NUMBER := OKC_API.G_MISS_NUM
      ,claim_number                   OKL_INS_CLAIMS_B.CLAIM_NUMBER%TYPE := OKC_API.G_MISS_CHAR
      ,csu_code                       OKL_INS_CLAIMS_B.CSU_CODE%TYPE := OKC_API.G_MISS_CHAR
      ,ipy_id                         NUMBER := OKC_API.G_MISS_NUM
      ,ltp_code                       OKL_INS_CLAIMS_B.LTP_CODE%TYPE := OKC_API.G_MISS_CHAR
      ,program_update_date            OKL_INS_CLAIMS_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
      ,claim_date                     OKL_INS_CLAIMS_B.CLAIM_DATE%TYPE := OKC_API.G_MISS_DATE
      ,program_id                     NUMBER := OKC_API.G_MISS_NUM
      ,loss_date                      OKL_INS_CLAIMS_B.LOSS_DATE%TYPE := OKC_API.G_MISS_DATE
      ,police_contact                 OKL_INS_CLAIMS_B.POLICE_CONTACT%TYPE := OKC_API.G_MISS_CHAR
      ,amount                         NUMBER := OKC_API.G_MISS_NUM
      ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
      ,request_id                     NUMBER := OKC_API.G_MISS_NUM
      ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
      ,attribute_category             OKL_INS_CLAIMS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
      ,attribute1                     OKL_INS_CLAIMS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
      ,attribute2                     OKL_INS_CLAIMS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
      ,attribute3                     OKL_INS_CLAIMS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
      ,attribute4                     OKL_INS_CLAIMS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
      ,attribute5                     OKL_INS_CLAIMS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
      ,attribute6                     OKL_INS_CLAIMS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
      ,attribute7                     OKL_INS_CLAIMS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
      ,attribute8                     OKL_INS_CLAIMS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
      ,attribute9                     OKL_INS_CLAIMS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
      ,attribute10                    OKL_INS_CLAIMS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
      ,attribute11                    OKL_INS_CLAIMS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
      ,attribute12                    OKL_INS_CLAIMS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
      ,attribute13                    OKL_INS_CLAIMS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
      ,attribute14                    OKL_INS_CLAIMS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
      ,attribute15                    OKL_INS_CLAIMS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
      ,hold_date                      OKL_INS_CLAIMS_B.HOLD_DATE%TYPE := OKC_API.G_MISS_DATE
      ,org_id                         NUMBER := OKC_API.G_MISS_NUM
      ,created_by                     NUMBER := OKC_API.G_MISS_NUM
      ,creation_date                  OKL_INS_CLAIMS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
      ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
      ,last_update_date               OKL_INS_CLAIMS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
      ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
    G_MISS_clm_rec                          clm_rec_type;
    TYPE clm_tbl_type IS TABLE OF clm_rec_type
          INDEX BY BINARY_INTEGER;
    -- OKL_INS_CLAIMS_TL Record Spec
    TYPE okl_ins_claims_tl_rec_type IS RECORD (
       id                             NUMBER := OKC_API.G_MISS_NUM
      ,language                       OKL_INS_CLAIMS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR
      ,description                    OKL_INS_CLAIMS_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
      ,police_report                  OKL_INS_CLAIMS_TL.POLICE_REPORT%TYPE := OKC_API.G_MISS_CHAR
      ,comments                       OKL_INS_CLAIMS_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR
      ,source_lang                    OKL_INS_CLAIMS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR
      ,sfwt_flag                      OKL_INS_CLAIMS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
      ,created_by                     NUMBER := OKC_API.G_MISS_NUM
      ,creation_date                  OKL_INS_CLAIMS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
      ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
      ,last_update_date               OKL_INS_CLAIMS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
      ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
    G_MISS_okl_ins_claims_tl_rec            okl_ins_claims_tl_rec_type;
    TYPE okl_ins_claims_tl_tbl_type IS TABLE OF okl_ins_claims_tl_rec_type
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
    G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
    G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
    G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
    G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
    ---------------------------------------------------------------------------
    -- GLOBAL EXCEPTIONS
    ---------------------------------------------------------------------------
    G_EXCEPTION_HALT_VALIDATION    EXCEPTION;
    ---------------------------------------------------------------------------
    -- GLOBAL VARIABLES
    ---------------------------------------------------------------------------
    G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_CLM_PVT';
    G_APP_NAME                     CONSTANT VARCHAR2(3)   := 'OKL';
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
      p_clmv_rec                     IN clmv_rec_type,
      x_clmv_rec                     OUT NOCOPY clmv_rec_type);
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type,
      x_clmv_tbl                     OUT NOCOPY clmv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type,
      x_clmv_tbl                     OUT NOCOPY clmv_tbl_type);
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_rec                     IN clmv_rec_type);
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type);
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_rec                     IN clmv_rec_type,
      x_clmv_rec                     OUT NOCOPY clmv_rec_type);
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type,
      x_clmv_tbl                     OUT NOCOPY clmv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type,
      x_clmv_tbl                     OUT NOCOPY clmv_tbl_type);
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_rec                     IN clmv_rec_type);
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type);
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_rec                     IN clmv_rec_type);
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type);
END OKL_CLM_PVT;

 

/
