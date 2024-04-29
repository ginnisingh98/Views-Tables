--------------------------------------------------------
--  DDL for Package IEX_IOH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_IOH_PVT" AUTHID CURRENT_USER AS
/* $Header: IEXSIOHS.pls 120.2 2005/12/21 15:45:46 jypark ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- IEX_OPEN_INT_HST_V Record Spec
  TYPE iohv_rec_type IS RECORD (
     id                             NUMBER := 9.99E125
    ,object1_id1                    IEX_OPEN_INT_HST_V.OBJECT1_ID1%TYPE := chr(0)
    ,object1_id2                    IEX_OPEN_INT_HST_V.OBJECT1_ID2%TYPE := chr(0)
    ,jtot_object1_code              IEX_OPEN_INT_HST_V.JTOT_OBJECT1_CODE%TYPE := chr(0)
    ,action                         IEX_OPEN_INT_HST_V.ACTION%TYPE := chr(0)
    ,status                         IEX_OPEN_INT_HST_V.STATUS%TYPE := chr(0)
    ,comments                       IEX_OPEN_INT_HST_V.COMMENTS%TYPE := chr(0)
    ,request_date                   IEX_OPEN_INT_HST_V.REQUEST_DATE%TYPE := TO_DATE('1','j')
    ,process_date                   IEX_OPEN_INT_HST_V.PROCESS_DATE%TYPE := TO_DATE('1','j')
    ,ext_agncy_id                   NUMBER := 9.99E125
    ,review_date                    IEX_OPEN_INT_HST_V.REVIEW_DATE%TYPE := TO_DATE('1','j')
    ,recall_date                    IEX_OPEN_INT_HST_V.RECALL_DATE%TYPE := TO_DATE('1','j')
    ,automatic_recall_flag          IEX_OPEN_INT_HST_V.AUTOMATIC_RECALL_FLAG%TYPE := chr(0)
    ,review_before_recall_flag      IEX_OPEN_INT_HST_V.REVIEW_BEFORE_RECALL_FLAG%TYPE := chr(0)
    ,object_version_number          NUMBER := 9.99E125
    ,org_id                         NUMBER := 9.99E125
    ,request_id                     NUMBER := 9.99E125
    ,program_application_id         NUMBER := 9.99E125
    ,program_id                     NUMBER := 9.99E125
    ,program_update_date            IEX_OPEN_INT_HST_V.PROGRAM_UPDATE_DATE%TYPE := TO_DATE('1','j')
    ,attribute_category             IEX_OPEN_INT_HST_V.ATTRIBUTE_CATEGORY%TYPE := chr(0)
    ,attribute1                     IEX_OPEN_INT_HST_V.ATTRIBUTE1%TYPE := chr(0)
    ,attribute2                     IEX_OPEN_INT_HST_V.ATTRIBUTE2%TYPE := chr(0)
    ,attribute3                     IEX_OPEN_INT_HST_V.ATTRIBUTE3%TYPE := chr(0)
    ,attribute4                     IEX_OPEN_INT_HST_V.ATTRIBUTE4%TYPE := chr(0)
    ,attribute5                     IEX_OPEN_INT_HST_V.ATTRIBUTE5%TYPE := chr(0)
    ,attribute6                     IEX_OPEN_INT_HST_V.ATTRIBUTE6%TYPE := chr(0)
    ,attribute7                     IEX_OPEN_INT_HST_V.ATTRIBUTE7%TYPE := chr(0)
    ,attribute8                     IEX_OPEN_INT_HST_V.ATTRIBUTE8%TYPE := chr(0)
    ,attribute9                     IEX_OPEN_INT_HST_V.ATTRIBUTE9%TYPE := chr(0)
    ,attribute10                    IEX_OPEN_INT_HST_V.ATTRIBUTE10%TYPE := chr(0)
    ,attribute11                    IEX_OPEN_INT_HST_V.ATTRIBUTE11%TYPE := chr(0)
    ,attribute12                    IEX_OPEN_INT_HST_V.ATTRIBUTE12%TYPE := chr(0)
    ,attribute13                    IEX_OPEN_INT_HST_V.ATTRIBUTE13%TYPE := chr(0)
    ,attribute14                    IEX_OPEN_INT_HST_V.ATTRIBUTE14%TYPE := chr(0)
    ,attribute15                    IEX_OPEN_INT_HST_V.ATTRIBUTE15%TYPE := chr(0)
    ,created_by                     NUMBER := 9.99E125
    ,creation_date                  IEX_OPEN_INT_HST_V.CREATION_DATE%TYPE := TO_DATE('1','j')
    ,last_updated_by                NUMBER := 9.99E125
    ,last_update_date               IEX_OPEN_INT_HST_V.LAST_UPDATE_DATE%TYPE := TO_DATE('1','j')
    ,last_update_login              NUMBER := 9.99E125);
  G_MISS_iohv_rec                         iohv_rec_type;
  TYPE iohv_tbl_type IS TABLE OF iohv_rec_type
        INDEX BY BINARY_INTEGER;
  -- IEX_OPEN_INT_HST Record Spec
  TYPE ioh_rec_type IS RECORD (
     id                             NUMBER := 9.99E125
    ,object1_id1                    IEX_OPEN_INT_HST.OBJECT1_ID1%TYPE := chr(0)
    ,object1_id2                    IEX_OPEN_INT_HST.OBJECT1_ID2%TYPE := chr(0)
    ,jtot_object1_code              IEX_OPEN_INT_HST.JTOT_OBJECT1_CODE%TYPE := chr(0)
    ,action                         IEX_OPEN_INT_HST.ACTION%TYPE := chr(0)
    ,status                         IEX_OPEN_INT_HST.STATUS%TYPE := chr(0)
    ,comments                       IEX_OPEN_INT_HST.COMMENTS%TYPE := chr(0)
    ,request_date                   IEX_OPEN_INT_HST.REQUEST_DATE%TYPE := TO_DATE('1','j')
    ,process_date                   IEX_OPEN_INT_HST.PROCESS_DATE%TYPE := TO_DATE('1','j')
    ,ext_agncy_id                   NUMBER := 9.99E125
    ,review_date                    IEX_OPEN_INT_HST.REVIEW_DATE%TYPE := TO_DATE('1','j')
    ,recall_date                    IEX_OPEN_INT_HST.RECALL_DATE%TYPE := TO_DATE('1','j')
    ,automatic_recall_flag          IEX_OPEN_INT_HST.AUTOMATIC_RECALL_FLAG%TYPE := chr(0)
    ,review_before_recall_flag      IEX_OPEN_INT_HST.REVIEW_BEFORE_RECALL_FLAG%TYPE := chr(0)
    ,object_version_number          NUMBER := 9.99E125
    ,org_id                         NUMBER := 9.99E125
    ,request_id                     NUMBER := 9.99E125
    ,program_application_id         NUMBER := 9.99E125
    ,program_id                     NUMBER := 9.99E125
    ,program_update_date            IEX_OPEN_INT_HST.PROGRAM_UPDATE_DATE%TYPE := TO_DATE('1','j')
    ,attribute_category             IEX_OPEN_INT_HST.ATTRIBUTE_CATEGORY%TYPE := chr(0)
    ,attribute1                     IEX_OPEN_INT_HST.ATTRIBUTE1%TYPE := chr(0)
    ,attribute2                     IEX_OPEN_INT_HST.ATTRIBUTE2%TYPE := chr(0)
    ,attribute3                     IEX_OPEN_INT_HST.ATTRIBUTE3%TYPE := chr(0)
    ,attribute4                     IEX_OPEN_INT_HST.ATTRIBUTE4%TYPE := chr(0)
    ,attribute5                     IEX_OPEN_INT_HST.ATTRIBUTE5%TYPE := chr(0)
    ,attribute6                     IEX_OPEN_INT_HST.ATTRIBUTE6%TYPE := chr(0)
    ,attribute7                     IEX_OPEN_INT_HST.ATTRIBUTE7%TYPE := chr(0)
    ,attribute8                     IEX_OPEN_INT_HST.ATTRIBUTE8%TYPE := chr(0)
    ,attribute9                     IEX_OPEN_INT_HST.ATTRIBUTE9%TYPE := chr(0)
    ,attribute10                    IEX_OPEN_INT_HST.ATTRIBUTE10%TYPE := chr(0)
    ,attribute11                    IEX_OPEN_INT_HST.ATTRIBUTE11%TYPE := chr(0)
    ,attribute12                    IEX_OPEN_INT_HST.ATTRIBUTE12%TYPE := chr(0)
    ,attribute13                    IEX_OPEN_INT_HST.ATTRIBUTE13%TYPE := chr(0)
    ,attribute14                    IEX_OPEN_INT_HST.ATTRIBUTE14%TYPE := chr(0)
    ,attribute15                    IEX_OPEN_INT_HST.ATTRIBUTE15%TYPE := chr(0)
    ,created_by                     NUMBER := 9.99E125
    ,creation_date                  IEX_OPEN_INT_HST.CREATION_DATE%TYPE := TO_DATE('1','j')
    ,last_updated_by                NUMBER := 9.99E125
    ,last_update_date               IEX_OPEN_INT_HST.LAST_UPDATE_DATE%TYPE := TO_DATE('1','j')
    ,last_update_login              NUMBER := 9.99E125);
  G_MISS_ioh_rec                          ioh_rec_type;
  TYPE ioh_tbl_type IS TABLE OF ioh_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'IEX_IOH_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type,
    x_iohv_rec                     OUT NOCOPY iohv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type,
    x_iohv_tbl                     OUT NOCOPY iohv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type,
    x_iohv_tbl                     OUT NOCOPY iohv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type,
    x_iohv_rec                     OUT NOCOPY iohv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type,
    x_iohv_tbl                     OUT NOCOPY iohv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type,
    x_iohv_tbl                     OUT NOCOPY iohv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_rec                     IN iohv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iohv_tbl                     IN iohv_tbl_type);
END IEX_IOH_PVT;

 

/
