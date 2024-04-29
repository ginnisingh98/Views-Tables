--------------------------------------------------------
--  DDL for Package OKL_CAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CAM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSCAMS.pls 120.2 2006/07/11 10:12:13 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_CURE_AMOUNTS_V Record Spec
  TYPE camv_rec_type IS RECORD (
     cure_amount_id                 NUMBER := OKL_API.G_MISS_NUM
    ,chr_id                         NUMBER := OKL_API.G_MISS_NUM
    ,cure_type                      OKL_CURE_AMOUNTS.CURE_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,cure_amount                    NUMBER := OKL_API.G_MISS_NUM
    ,repurchase_amount              NUMBER := OKL_API.G_MISS_NUM
    ,effective_date                 OKL_CURE_AMOUNTS.EFFECTIVE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,times_cured                    NUMBER := OKL_API.G_MISS_NUM
    ,payments_remaining             NUMBER := OKL_API.G_MISS_NUM
    ,eligible_cure_amount           NUMBER := OKL_API.G_MISS_NUM
    ,outstanding_amount             NUMBER := OKL_API.G_MISS_NUM
    ,past_due_amount                NUMBER := OKL_API.G_MISS_NUM
    ,cures_in_possession            NUMBER := OKL_API.G_MISS_NUM
    ,status                         OKL_CURE_AMOUNTS.STATUS%TYPE := OKL_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,org_id                         NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_CURE_AMOUNTS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_CURE_AMOUNTS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_CURE_AMOUNTS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_CURE_AMOUNTS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_CURE_AMOUNTS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_CURE_AMOUNTS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_CURE_AMOUNTS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_CURE_AMOUNTS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_CURE_AMOUNTS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_CURE_AMOUNTS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_CURE_AMOUNTS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_CURE_AMOUNTS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_CURE_AMOUNTS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_CURE_AMOUNTS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_CURE_AMOUNTS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_CURE_AMOUNTS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_CURE_AMOUNTS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CURE_AMOUNTS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CURE_AMOUNTS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,DELINQUENT_AMOUNT                NUMBER := OKL_API.G_MISS_NUM
    ,NEGOTIATED_AMOUNT              NUMBER := OKL_API.G_MISS_NUM
    ,RECEIVED_AMOUNT                NUMBER := OKL_API.G_MISS_NUM
    ,SHORT_FUND_AMOUNT              NUMBER := OKL_API.G_MISS_NUM
    ,CRT_ID                         NUMBER := OKL_API.G_MISS_NUM
    ,SHOW_ON_REQUEST                OKL_CURE_AMOUNTS.SHOW_ON_REQUEST%TYPE := OKL_API.G_MISS_CHAR
    ,SELECTED_ON_REQUEST            OKL_CURE_AMOUNTS.SELECTED_ON_REQUEST%TYPE := OKL_API.G_MISS_CHAR
    ,QTE_ID                         NUMBER := OKL_API.G_MISS_NUM
    ,PROCESS                       OKL_CURE_AMOUNTS.PROCESS%TYPE := OKL_API.G_MISS_CHAR);

  G_MISS_camv_rec                         camv_rec_type;
  TYPE camv_tbl_type IS TABLE OF camv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_CURE_AMOUNTS Record Spec
  TYPE cam_rec_type IS RECORD (
     cure_amount_id                 NUMBER := OKL_API.G_MISS_NUM
    ,chr_id                         NUMBER := OKL_API.G_MISS_NUM
    ,cure_type                      OKL_CURE_AMOUNTS.CURE_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,cure_amount                    NUMBER := OKL_API.G_MISS_NUM
    ,repurchase_amount              NUMBER := OKL_API.G_MISS_NUM
    ,effective_date                 OKL_CURE_AMOUNTS.EFFECTIVE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,times_cured                    NUMBER := OKL_API.G_MISS_NUM
    ,payments_remaining             NUMBER := OKL_API.G_MISS_NUM
    ,eligible_cure_amount           NUMBER := OKL_API.G_MISS_NUM
    ,outstanding_amount             NUMBER := OKL_API.G_MISS_NUM
    ,past_due_amount                NUMBER := OKL_API.G_MISS_NUM
    ,cures_in_possession            NUMBER := OKL_API.G_MISS_NUM
    ,status                         OKL_CURE_AMOUNTS.STATUS%TYPE := OKL_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,org_id                         NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_CURE_AMOUNTS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_CURE_AMOUNTS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_CURE_AMOUNTS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_CURE_AMOUNTS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_CURE_AMOUNTS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_CURE_AMOUNTS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_CURE_AMOUNTS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_CURE_AMOUNTS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_CURE_AMOUNTS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_CURE_AMOUNTS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_CURE_AMOUNTS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_CURE_AMOUNTS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_CURE_AMOUNTS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_CURE_AMOUNTS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_CURE_AMOUNTS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_CURE_AMOUNTS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_CURE_AMOUNTS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CURE_AMOUNTS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CURE_AMOUNTS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,DELINQUENT_AMOUNT              NUMBER := OKL_API.G_MISS_NUM
    ,NEGOTIATED_AMOUNT              NUMBER := OKL_API.G_MISS_NUM
    ,RECEIVED_AMOUNT                NUMBER := OKL_API.G_MISS_NUM
    ,SHORT_FUND_AMOUNT              NUMBER := OKL_API.G_MISS_NUM
    ,CRT_ID                         NUMBER := OKL_API.G_MISS_NUM
    ,SHOW_ON_REQUEST                OKL_CURE_AMOUNTS.SHOW_ON_REQUEST%TYPE := OKL_API.G_MISS_CHAR
    ,SELECTED_ON_REQUEST            OKL_CURE_AMOUNTS.SELECTED_ON_REQUEST%TYPE := OKL_API.G_MISS_CHAR
    ,QTE_ID                         NUMBER := OKL_API.G_MISS_NUM
    ,PROCESS                       OKL_CURE_AMOUNTS.PROCESS%TYPE := OKL_API.G_MISS_CHAR);
  G_MISS_cam_rec                          cam_rec_type;
  TYPE cam_tbl_type IS TABLE OF cam_rec_type
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
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_CAM_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  -------------------------------------------------------------------------------
  --Post change to TAPI code
  -------------------------------------------------------------------------------
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLCODE';
  g_no_parent_record            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  --Post change to TAPI code
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
    p_camv_rec                     IN camv_rec_type,
    x_camv_rec                     OUT NOCOPY camv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type,
    x_camv_tbl                     OUT NOCOPY camv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type,
    x_camv_tbl                     OUT NOCOPY camv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_rec                     IN camv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_rec                     IN camv_rec_type,
    x_camv_rec                     OUT NOCOPY camv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type,
    x_camv_tbl                     OUT NOCOPY camv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type,
    x_camv_tbl                     OUT NOCOPY camv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_rec                     IN camv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_rec                     IN camv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type);
END OKL_CAM_PVT;

/
