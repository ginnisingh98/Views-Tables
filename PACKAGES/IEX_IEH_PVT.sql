--------------------------------------------------------
--  DDL for Package IEX_IEH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_IEH_PVT" AUTHID CURRENT_USER AS
/* $Header: IEXSIEHS.pls 120.0 2004/01/24 03:16:16 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- IEX_EXCLUSION_HIST_V Record Spec
  TYPE iehv_rec_type IS RECORD (
     exclusion_history_id           NUMBER := OKC_API.G_MISS_NUM
    ,object1_id1                    IEX_EXCLUSION_HIST_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,object1_id2                    IEX_EXCLUSION_HIST_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,jtot_object1_code              IEX_EXCLUSION_HIST_V.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,exclusion_reason               IEX_EXCLUSION_HIST_V.EXCLUSION_REASON%TYPE := OKC_API.G_MISS_CHAR
    ,effective_start_date           IEX_EXCLUSION_HIST_V.EFFECTIVE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,effective_end_date             IEX_EXCLUSION_HIST_V.EFFECTIVE_END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,cancel_reason                  IEX_EXCLUSION_HIST_V.CANCEL_REASON%TYPE := OKC_API.G_MISS_CHAR
    ,cancelled_date                 IEX_EXCLUSION_HIST_V.CANCELLED_DATE%TYPE := OKC_API.G_MISS_DATE
    ,exclusion_comment              IEX_EXCLUSION_HIST_V.EXCLUSION_COMMENT%TYPE := OKC_API.G_MISS_CHAR
    ,cancellation_comment           IEX_EXCLUSION_HIST_V.CANCELLATION_COMMENT%TYPE := OKC_API.G_MISS_CHAR
    ,language                       IEX_EXCLUSION_HIST_V.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR
    ,source_lang                    IEX_EXCLUSION_HIST_V.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR
    ,sfwt_flag                      IEX_EXCLUSION_HIST_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,attribute_category             IEX_EXCLUSION_HIST_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     IEX_EXCLUSION_HIST_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     IEX_EXCLUSION_HIST_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     IEX_EXCLUSION_HIST_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     IEX_EXCLUSION_HIST_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     IEX_EXCLUSION_HIST_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     IEX_EXCLUSION_HIST_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     IEX_EXCLUSION_HIST_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     IEX_EXCLUSION_HIST_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     IEX_EXCLUSION_HIST_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    IEX_EXCLUSION_HIST_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    IEX_EXCLUSION_HIST_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    IEX_EXCLUSION_HIST_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    IEX_EXCLUSION_HIST_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    IEX_EXCLUSION_HIST_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    IEX_EXCLUSION_HIST_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  IEX_EXCLUSION_HIST_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               IEX_EXCLUSION_HIST_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_iehv_rec                         iehv_rec_type;
  TYPE iehv_tbl_type IS TABLE OF iehv_rec_type
        INDEX BY BINARY_INTEGER;
  -- IEX_EXCLUSION_HIST_TL Record Spec
  TYPE ieht_rec_type IS RECORD (
     exclusion_history_id           NUMBER := OKC_API.G_MISS_NUM
    ,exclusion_comment              IEX_EXCLUSION_HIST_TL.EXCLUSION_COMMENT%TYPE := OKC_API.G_MISS_CHAR
    ,cancellation_comment           IEX_EXCLUSION_HIST_TL.CANCELLATION_COMMENT%TYPE := OKC_API.G_MISS_CHAR
    ,language                       IEX_EXCLUSION_HIST_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR
    ,source_lang                    IEX_EXCLUSION_HIST_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR
    ,sfwt_flag                      IEX_EXCLUSION_HIST_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  IEX_EXCLUSION_HIST_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               IEX_EXCLUSION_HIST_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_ieht_rec                         ieht_rec_type;
  TYPE ieht_tbl_type IS TABLE OF ieht_rec_type
        INDEX BY BINARY_INTEGER;
  -- IEX_EXCLUSION_HIST_B Record Spec
  TYPE ieh_rec_type IS RECORD (
     exclusion_history_id           NUMBER := OKC_API.G_MISS_NUM
    ,object1_id1                    IEX_EXCLUSION_HIST_B.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,object1_id2                    IEX_EXCLUSION_HIST_B.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,jtot_object1_code              IEX_EXCLUSION_HIST_B.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,exclusion_reason               IEX_EXCLUSION_HIST_B.EXCLUSION_REASON%TYPE := OKC_API.G_MISS_CHAR
    ,effective_start_date           IEX_EXCLUSION_HIST_B.EFFECTIVE_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,effective_end_date             IEX_EXCLUSION_HIST_B.EFFECTIVE_END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,cancel_reason                  IEX_EXCLUSION_HIST_B.CANCEL_REASON%TYPE := OKC_API.G_MISS_CHAR
    ,cancelled_date                 IEX_EXCLUSION_HIST_B.CANCELLED_DATE%TYPE := OKC_API.G_MISS_DATE
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,attribute_category             IEX_EXCLUSION_HIST_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     IEX_EXCLUSION_HIST_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     IEX_EXCLUSION_HIST_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     IEX_EXCLUSION_HIST_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     IEX_EXCLUSION_HIST_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     IEX_EXCLUSION_HIST_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     IEX_EXCLUSION_HIST_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     IEX_EXCLUSION_HIST_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     IEX_EXCLUSION_HIST_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     IEX_EXCLUSION_HIST_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    IEX_EXCLUSION_HIST_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    IEX_EXCLUSION_HIST_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    IEX_EXCLUSION_HIST_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    IEX_EXCLUSION_HIST_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    IEX_EXCLUSION_HIST_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    IEX_EXCLUSION_HIST_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  IEX_EXCLUSION_HIST_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               IEX_EXCLUSION_HIST_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_ieh_rec                          ieh_rec_type;
  TYPE ieh_tbl_type IS TABLE OF ieh_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  --G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  --G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  --G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  --G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'IEX_IEH_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;

  -------------------------------------------------------------------------------
  --Post change to TAPI code
  -------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLCODE';
  g_no_parent_record            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  ---------------------------------------------------------------------------

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
    p_iehv_rec                     IN iehv_rec_type,
    x_iehv_rec                     OUT NOCOPY iehv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type,
    x_iehv_tbl                     OUT NOCOPY iehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type,
    x_iehv_tbl                     OUT NOCOPY iehv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type,
    x_iehv_rec                     OUT NOCOPY iehv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type,
    x_iehv_tbl                     OUT NOCOPY iehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type,
    x_iehv_tbl                     OUT NOCOPY iehv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_rec                     IN iehv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iehv_tbl                     IN iehv_tbl_type);
END IEX_IEH_PVT;

 

/
