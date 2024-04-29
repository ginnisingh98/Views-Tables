--------------------------------------------------------
--  DDL for Package OKL_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TAX_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTAXS.pls 120.3 2006/07/11 10:31:36 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_TAX_LINES_V Record Spec
  TYPE OKL_TAX_LINES_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,kle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,asset_id                       NUMBER := OKC_API.G_MISS_NUM
    ,asset_number                   OKL_TAX_LINES.ASSET_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,tax_line_type                  OKL_TAX_LINES.TAX_LINE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,sel_id                         NUMBER := OKC_API.G_MISS_NUM
    ,tax_due_date                   OKL_TAX_LINES.TAX_DUE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,tax_type                       NUMBER := OKC_API.G_MISS_NUM
    ,tax_rate_code_id               NUMBER := OKC_API.G_MISS_NUM
    ,tax_rate_code                  OKL_TAX_LINES.TAX_RATE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,taxable_amount                 NUMBER := OKC_API.G_MISS_NUM
    ,tax_exemption_id               NUMBER := OKC_API.G_MISS_NUM
    ,manually_entered_flag          OKL_TAX_LINES.MANUALLY_ENTERED_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,overridden_flag                OKL_TAX_LINES.OVERRIDDEN_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,calculated_tax_amount          NUMBER := OKC_API.G_MISS_NUM
    ,tax_rate                       NUMBER := OKC_API.G_MISS_NUM
    ,tax_amount                     NUMBER := OKC_API.G_MISS_NUM
    ,sales_tax_id                   NUMBER := OKC_API.G_MISS_NUM
    ,source_trx_id                  NUMBER := OKC_API.G_MISS_NUM
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,history_yn                     OKL_TAX_LINES.HISTORY_YN%TYPE := OKC_API.G_MISS_CHAR
    ,actual_yn                      OKL_TAX_LINES.ACTUAL_YN%TYPE := OKC_API.G_MISS_CHAR
    ,source_name                    OKL_TAX_LINES.SOURCE_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,trq_id                         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKL_TAX_LINES.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,attribute_category             OKL_TAX_LINES.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_TAX_LINES.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_TAX_LINES.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_TAX_LINES.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_TAX_LINES.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_TAX_LINES.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_TAX_LINES.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_TAX_LINES.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_TAX_LINES.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_TAX_LINES.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_TAX_LINES.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_TAX_LINES.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_TAX_LINES.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_TAX_LINES.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_TAX_LINES.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_TAX_LINES.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_TAX_LINES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_TAX_LINES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_OKL_TAX_LINES_rec              OKL_TAX_LINES_rec_type;
  TYPE OKL_TAX_LINES_tbl_type IS TABLE OF OKL_TAX_LINES_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_TAX_LINES Record Spec
  TYPE tax_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,kle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,asset_id                       NUMBER := OKC_API.G_MISS_NUM
    ,asset_number                   OKL_TAX_LINES.ASSET_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,tax_line_type                  OKL_TAX_LINES.TAX_LINE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,sel_id                         NUMBER := OKC_API.G_MISS_NUM
    ,tax_due_date                   OKL_TAX_LINES.TAX_DUE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,tax_type                       NUMBER := OKC_API.G_MISS_NUM
    ,tax_rate_code_id               NUMBER := OKC_API.G_MISS_NUM
    ,tax_rate_code                  OKL_TAX_LINES.TAX_RATE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,taxable_amount                 NUMBER := OKC_API.G_MISS_NUM
    ,tax_exemption_id               NUMBER := OKC_API.G_MISS_NUM
    ,manually_entered_flag          OKL_TAX_LINES.MANUALLY_ENTERED_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,overridden_flag                OKL_TAX_LINES.OVERRIDDEN_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,calculated_tax_amount          NUMBER := OKC_API.G_MISS_NUM
    ,tax_rate                       NUMBER := OKC_API.G_MISS_NUM
    ,tax_amount                     NUMBER := OKC_API.G_MISS_NUM
    ,sales_tax_id                   NUMBER := OKC_API.G_MISS_NUM
    ,source_trx_id                  NUMBER := OKC_API.G_MISS_NUM
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,history_yn                     OKL_TAX_LINES.HISTORY_YN%TYPE := OKC_API.G_MISS_CHAR
    ,actual_yn                      OKL_TAX_LINES.ACTUAL_YN%TYPE := OKC_API.G_MISS_CHAR
    ,source_name                    OKL_TAX_LINES.SOURCE_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,trq_id                         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKL_TAX_LINES.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,attribute_category             OKL_TAX_LINES.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_TAX_LINES.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_TAX_LINES.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_TAX_LINES.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_TAX_LINES.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_TAX_LINES.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_TAX_LINES.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_TAX_LINES.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_TAX_LINES.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_TAX_LINES.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_TAX_LINES.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_TAX_LINES.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_TAX_LINES.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_TAX_LINES.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_TAX_LINES.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_TAX_LINES.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_TAX_LINES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_TAX_LINES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_tax_rec                          tax_rec_type;
  TYPE tax_tbl_type IS TABLE OF tax_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_TAX_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_rec          IN OKL_TAX_LINES_rec_type,
    x_OKL_TAX_LINES_rec          OUT NOCOPY OKL_TAX_LINES_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type,
    x_OKL_TAX_LINES_tbl          OUT NOCOPY OKL_TAX_LINES_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type,
    x_OKL_TAX_LINES_tbl          OUT NOCOPY OKL_TAX_LINES_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_rec          IN OKL_TAX_LINES_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_rec          IN OKL_TAX_LINES_rec_type,
    x_OKL_TAX_LINES_rec          OUT NOCOPY OKL_TAX_LINES_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type,
    x_OKL_TAX_LINES_tbl          OUT NOCOPY OKL_TAX_LINES_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type,
    x_OKL_TAX_LINES_tbl          OUT NOCOPY OKL_TAX_LINES_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_rec          IN OKL_TAX_LINES_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_rec          IN OKL_TAX_LINES_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type);
END OKL_TAX_PVT;

/
