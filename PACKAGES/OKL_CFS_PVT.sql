--------------------------------------------------------
--  DDL for Package OKL_CFS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CFS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSCFSS.pls 120.2 2006/07/11 10:13:59 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE cfsv_rec_type IS RECORD (
     cure_fund_sum_id               NUMBER := okl_api.G_MISS_NUM
    ,vendor_id              NUMBER := okl_api.G_MISS_NUM
    ,balance                        NUMBER := okl_api.G_MISS_NUM
    ,object_version_number          NUMBER := okl_api.G_MISS_NUM
    ,org_id                         NUMBER := okl_api.G_MISS_NUM
    ,request_id                     NUMBER := okl_api.G_MISS_NUM
    ,program_application_id         NUMBER := okl_api.G_MISS_NUM
    ,program_id                     NUMBER := okl_api.G_MISS_NUM
    ,program_update_date            OKL_CURE_FUND_SUMS.PROGRAM_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE
    ,attribute_category             OKL_CURE_FUND_SUMS.ATTRIBUTE_CATEGORY%TYPE := okl_api.G_MISS_CHAR
    ,attribute1                     OKL_CURE_FUND_SUMS.ATTRIBUTE1%TYPE := okl_api.G_MISS_CHAR
    ,attribute2                     OKL_CURE_FUND_SUMS.ATTRIBUTE2%TYPE := okl_api.G_MISS_CHAR
    ,attribute3                     OKL_CURE_FUND_SUMS.ATTRIBUTE3%TYPE := okl_api.G_MISS_CHAR
    ,attribute4                     OKL_CURE_FUND_SUMS.ATTRIBUTE4%TYPE := okl_api.G_MISS_CHAR
    ,attribute5                     OKL_CURE_FUND_SUMS.ATTRIBUTE5%TYPE := okl_api.G_MISS_CHAR
    ,attribute6                     OKL_CURE_FUND_SUMS.ATTRIBUTE6%TYPE := okl_api.G_MISS_CHAR
    ,attribute7                     OKL_CURE_FUND_SUMS.ATTRIBUTE7%TYPE := okl_api.G_MISS_CHAR
    ,attribute8                     OKL_CURE_FUND_SUMS.ATTRIBUTE8%TYPE := okl_api.G_MISS_CHAR
    ,attribute9                     OKL_CURE_FUND_SUMS.ATTRIBUTE9%TYPE := okl_api.G_MISS_CHAR
    ,attribute10                    OKL_CURE_FUND_SUMS.ATTRIBUTE10%TYPE := okl_api.G_MISS_CHAR
    ,attribute11                    OKL_CURE_FUND_SUMS.ATTRIBUTE11%TYPE := okl_api.G_MISS_CHAR
    ,attribute12                    OKL_CURE_FUND_SUMS.ATTRIBUTE12%TYPE := okl_api.G_MISS_CHAR
    ,attribute13                    OKL_CURE_FUND_SUMS.ATTRIBUTE13%TYPE := okl_api.G_MISS_CHAR
    ,attribute14                    OKL_CURE_FUND_SUMS.ATTRIBUTE14%TYPE := okl_api.G_MISS_CHAR
    ,attribute15                    OKL_CURE_FUND_SUMS.ATTRIBUTE15%TYPE := okl_api.G_MISS_CHAR
    ,created_by                     NUMBER := okl_api.G_MISS_NUM
    ,creation_date                  OKL_CURE_FUND_SUMS.CREATION_DATE%TYPE := okl_api.G_MISS_DATE
    ,last_updated_by                NUMBER := okl_api.G_MISS_NUM
    ,last_update_date               OKL_CURE_FUND_SUMS.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE
    ,last_update_login              NUMBER := okl_api.G_MISS_NUM);
  G_MISS_cfsv_rec                         cfsv_rec_type;
  TYPE cfsv_tbl_type IS TABLE OF cfsv_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE cfs_rec_type IS RECORD (
     cure_fund_sum_id               NUMBER := okl_api.G_MISS_NUM
    ,vendor_id              NUMBER := okl_api.G_MISS_NUM
    ,balance                        NUMBER := okl_api.G_MISS_NUM
    ,object_version_number          NUMBER := okl_api.G_MISS_NUM
    ,org_id                         NUMBER := okl_api.G_MISS_NUM
    ,request_id                     NUMBER := okl_api.G_MISS_NUM
    ,program_application_id         NUMBER := okl_api.G_MISS_NUM
    ,program_id                     NUMBER := okl_api.G_MISS_NUM
    ,program_update_date            OKL_CURE_FUND_SUMS.PROGRAM_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE
    ,attribute_category             OKL_CURE_FUND_SUMS.ATTRIBUTE_CATEGORY%TYPE := okl_api.G_MISS_CHAR
    ,attribute1                     OKL_CURE_FUND_SUMS.ATTRIBUTE1%TYPE := okl_api.G_MISS_CHAR
    ,attribute2                     OKL_CURE_FUND_SUMS.ATTRIBUTE2%TYPE := okl_api.G_MISS_CHAR
    ,attribute3                     OKL_CURE_FUND_SUMS.ATTRIBUTE3%TYPE := okl_api.G_MISS_CHAR
    ,attribute4                     OKL_CURE_FUND_SUMS.ATTRIBUTE4%TYPE := okl_api.G_MISS_CHAR
    ,attribute5                     OKL_CURE_FUND_SUMS.ATTRIBUTE5%TYPE := okl_api.G_MISS_CHAR
    ,attribute6                     OKL_CURE_FUND_SUMS.ATTRIBUTE6%TYPE := okl_api.G_MISS_CHAR
    ,attribute7                     OKL_CURE_FUND_SUMS.ATTRIBUTE7%TYPE := okl_api.G_MISS_CHAR
    ,attribute8                     OKL_CURE_FUND_SUMS.ATTRIBUTE8%TYPE := okl_api.G_MISS_CHAR
    ,attribute9                     OKL_CURE_FUND_SUMS.ATTRIBUTE9%TYPE := okl_api.G_MISS_CHAR
    ,attribute10                    OKL_CURE_FUND_SUMS.ATTRIBUTE10%TYPE := okl_api.G_MISS_CHAR
    ,attribute11                    OKL_CURE_FUND_SUMS.ATTRIBUTE11%TYPE := okl_api.G_MISS_CHAR
    ,attribute12                    OKL_CURE_FUND_SUMS.ATTRIBUTE12%TYPE := okl_api.G_MISS_CHAR
    ,attribute13                    OKL_CURE_FUND_SUMS.ATTRIBUTE13%TYPE := okl_api.G_MISS_CHAR
    ,attribute14                    OKL_CURE_FUND_SUMS.ATTRIBUTE14%TYPE := okl_api.G_MISS_CHAR
    ,attribute15                    OKL_CURE_FUND_SUMS.ATTRIBUTE15%TYPE := okl_api.G_MISS_CHAR
    ,created_by                     NUMBER := okl_api.G_MISS_NUM
    ,creation_date                  OKL_CURE_FUND_SUMS.CREATION_DATE%TYPE := okl_api.G_MISS_DATE
    ,last_updated_by                NUMBER := okl_api.G_MISS_NUM
    ,last_update_date               OKL_CURE_FUND_SUMS.LAST_UPDATE_DATE%TYPE := okl_api.G_MISS_DATE
    ,last_update_login              NUMBER := okl_api.G_MISS_NUM);
  G_MISS_cfs_rec                          cfs_rec_type;
  TYPE cfs_tbl_type IS TABLE OF cfs_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := okl_api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := okl_api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := okl_api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := okl_api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := okl_api.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := okl_api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := okl_api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := okl_api.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_CFS_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := okl_api.G_APP_NAME;
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
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_rec                     IN cfsv_rec_type,
    x_cfsv_rec                     OUT NOCOPY cfsv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_tbl                     IN cfsv_tbl_type,
    x_cfsv_tbl                     OUT NOCOPY cfsv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_tbl                     IN cfsv_tbl_type,
    x_cfsv_tbl                     OUT NOCOPY cfsv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_rec                     IN cfsv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_tbl                     IN cfsv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_tbl                     IN cfsv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_rec                     IN cfsv_rec_type,
    x_cfsv_rec                     OUT NOCOPY cfsv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_tbl                     IN cfsv_tbl_type,
    x_cfsv_tbl                     OUT NOCOPY cfsv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_tbl                     IN cfsv_tbl_type,
    x_cfsv_tbl                     OUT NOCOPY cfsv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_rec                     IN cfsv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_tbl                     IN cfsv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_tbl                     IN cfsv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_rec                     IN cfsv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_tbl                     IN cfsv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY okl_api.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfsv_tbl                     IN cfsv_tbl_type);
END OKL_CFS_PVT;

/
