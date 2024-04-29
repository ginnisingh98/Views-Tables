--------------------------------------------------------
--  DDL for Package OKL_DRV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DRV_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSDRVS.pls 120.0 2007/03/13 21:17:36 pjgomes noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_DISB_RULE_VENDOR_SITES Record Spec
  TYPE drv_rec_type IS RECORD (
     disb_rule_vendor_site_id       NUMBER
    ,object_version_number          NUMBER
    ,disb_rule_id                   NUMBER
    ,vendor_id                      NUMBER
    ,vendor_site_id                 NUMBER
    ,start_date                     OKL_DISB_RULE_VENDOR_SITES.START_DATE%TYPE
    ,end_date                       OKL_DISB_RULE_VENDOR_SITES.END_DATE%TYPE
    ,invoice_seq_start              NUMBER
    ,invoice_seq_end                NUMBER
    ,next_inv_seq                   NUMBER
    ,attribute_category             OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE_CATEGORY%TYPE
    ,attribute1                     OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE1%TYPE
    ,attribute2                     OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE2%TYPE
    ,attribute3                     OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE3%TYPE
    ,attribute4                     OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE4%TYPE
    ,attribute5                     OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE5%TYPE
    ,attribute6                     OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE6%TYPE
    ,attribute7                     OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE7%TYPE
    ,attribute8                     OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE8%TYPE
    ,attribute9                     OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE9%TYPE
    ,attribute10                    OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE10%TYPE
    ,attribute11                    OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE11%TYPE
    ,attribute12                    OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE12%TYPE
    ,attribute13                    OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE13%TYPE
    ,attribute14                    OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE14%TYPE
    ,attribute15                    OKL_DISB_RULE_VENDOR_SITES.ATTRIBUTE15%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_DISB_RULE_VENDOR_SITES.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_DISB_RULE_VENDOR_SITES.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER);
  G_MISS_drv_rec                          drv_rec_type;
  TYPE drv_tbl_type IS TABLE OF drv_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_DRV_PVT';
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
    p_drv_rec                      IN drv_rec_type,
    x_drv_rec                      OUT NOCOPY drv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type,
    x_drv_tbl                      OUT NOCOPY drv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type,
    x_drv_tbl                      OUT NOCOPY drv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_rec                      IN drv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_rec                      IN drv_rec_type,
    x_drv_rec                      OUT NOCOPY drv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type,
    x_drv_tbl                      OUT NOCOPY drv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type,
    x_drv_tbl                      OUT NOCOPY drv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_rec                      IN drv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_rec                      IN drv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type);
END OKL_DRV_PVT;

/
