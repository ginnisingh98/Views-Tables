--------------------------------------------------------
--  DDL for Package OKL_DRA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DRA_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSDRAS.pls 120.2 2007/04/30 22:58:00 cklee noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_DISB_RULES_V Record Spec
  TYPE drav_rec_type IS RECORD (
     disb_rule_id                   NUMBER
    ,object_version_number          NUMBER
    ,sfwt_flag                      OKL_DISB_RULES_V.SFWT_FLAG%TYPE
    ,rule_name                      OKL_DISB_RULES_V.RULE_NAME%TYPE
    ,org_id                         NUMBER
    ,start_date                     OKL_DISB_RULES_V.START_DATE%TYPE
    ,end_date                       OKL_DISB_RULES_V.END_DATE%TYPE
    ,fee_option                     OKL_DISB_RULES_V.FEE_OPTION%TYPE
    ,fee_basis                      OKL_DISB_RULES_V.FEE_BASIS%TYPE
    ,fee_amount                     NUMBER
    ,fee_percent                    NUMBER
    ,consolidate_by_due_date        OKL_DISB_RULES_V.CONSOLIDATE_BY_DUE_DATE%TYPE
    ,frequency                      OKL_DISB_RULES_V.FREQUENCY%TYPE
    ,day_of_month                   NUMBER
    ,scheduled_month                OKL_DISB_RULES_V.SCHEDULED_MONTH%TYPE
    ,consolidate_strm_type          OKL_DISB_RULES_V.CONSOLIDATE_STRM_TYPE%TYPE
    ,description                    OKL_DISB_RULES_V.DESCRIPTION%TYPE
    ,attribute_category             OKL_DISB_RULES_V.ATTRIBUTE_CATEGORY%TYPE
    ,attribute1                     OKL_DISB_RULES_V.ATTRIBUTE1%TYPE
    ,attribute2                     OKL_DISB_RULES_V.ATTRIBUTE2%TYPE
    ,attribute3                     OKL_DISB_RULES_V.ATTRIBUTE3%TYPE
    ,attribute4                     OKL_DISB_RULES_V.ATTRIBUTE4%TYPE
    ,attribute5                     OKL_DISB_RULES_V.ATTRIBUTE5%TYPE
    ,attribute6                     OKL_DISB_RULES_V.ATTRIBUTE6%TYPE
    ,attribute7                     OKL_DISB_RULES_V.ATTRIBUTE7%TYPE
    ,attribute8                     OKL_DISB_RULES_V.ATTRIBUTE8%TYPE
    ,attribute9                     OKL_DISB_RULES_V.ATTRIBUTE9%TYPE
    ,attribute10                    OKL_DISB_RULES_V.ATTRIBUTE10%TYPE
    ,attribute11                    OKL_DISB_RULES_V.ATTRIBUTE11%TYPE
    ,attribute12                    OKL_DISB_RULES_V.ATTRIBUTE12%TYPE
    ,attribute13                    OKL_DISB_RULES_V.ATTRIBUTE13%TYPE
    ,attribute14                    OKL_DISB_RULES_V.ATTRIBUTE14%TYPE
    ,attribute15                    OKL_DISB_RULES_V.ATTRIBUTE15%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_DISB_RULES_V.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_DISB_RULES_V.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER);
  G_MISS_drav_rec                         drav_rec_type;
  TYPE drav_tbl_type IS TABLE OF drav_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_DISB_RULES_TL Record Spec
  TYPE okl_disb_rules_tl_rec_type IS RECORD (
     disb_rule_id                   NUMBER
    ,language                       OKL_DISB_RULES_TL.LANGUAGE%TYPE
    ,source_lang                    OKL_DISB_RULES_TL.SOURCE_LANG%TYPE
    ,sfwt_flag                      OKL_DISB_RULES_TL.SFWT_FLAG%TYPE
    ,description                    OKL_DISB_RULES_TL.DESCRIPTION%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_DISB_RULES_TL.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_DISB_RULES_TL.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER);
  G_MISS_okl_disb_rules_tl_rec            okl_disb_rules_tl_rec_type;
  TYPE okl_disb_rules_tl_tbl_type IS TABLE OF okl_disb_rules_tl_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_DISB_RULES_ALL_B Record Spec
  TYPE dra_rec_type IS RECORD (
     disb_rule_id                   NUMBER
    ,object_version_number          NUMBER
    ,rule_name                      OKL_DISB_RULES_ALL_B.RULE_NAME%TYPE
    ,org_id                         NUMBER
    ,start_date                     OKL_DISB_RULES_ALL_B.START_DATE%TYPE
    ,end_date                       OKL_DISB_RULES_ALL_B.END_DATE%TYPE
    ,fee_option                     OKL_DISB_RULES_ALL_B.FEE_OPTION%TYPE
    ,fee_basis                      OKL_DISB_RULES_ALL_B.FEE_BASIS%TYPE
    ,fee_amount                     NUMBER
    ,fee_percent                    NUMBER
    ,consolidate_by_due_date        OKL_DISB_RULES_ALL_B.CONSOLIDATE_BY_DUE_DATE%TYPE
    ,frequency                      OKL_DISB_RULES_ALL_B.FREQUENCY%TYPE
    ,day_of_month                   NUMBER
    ,scheduled_month                OKL_DISB_RULES_ALL_B.SCHEDULED_MONTH%TYPE
    ,consolidate_strm_type          OKL_DISB_RULES_ALL_B.CONSOLIDATE_STRM_TYPE%TYPE
    ,attribute_category             OKL_DISB_RULES_ALL_B.ATTRIBUTE_CATEGORY%TYPE
    ,attribute1                     OKL_DISB_RULES_ALL_B.ATTRIBUTE1%TYPE
    ,attribute2                     OKL_DISB_RULES_ALL_B.ATTRIBUTE2%TYPE
    ,attribute3                     OKL_DISB_RULES_ALL_B.ATTRIBUTE3%TYPE
    ,attribute4                     OKL_DISB_RULES_ALL_B.ATTRIBUTE4%TYPE
    ,attribute5                     OKL_DISB_RULES_ALL_B.ATTRIBUTE5%TYPE
    ,attribute6                     OKL_DISB_RULES_ALL_B.ATTRIBUTE6%TYPE
    ,attribute7                     OKL_DISB_RULES_ALL_B.ATTRIBUTE7%TYPE
    ,attribute8                     OKL_DISB_RULES_ALL_B.ATTRIBUTE8%TYPE
    ,attribute9                     OKL_DISB_RULES_ALL_B.ATTRIBUTE9%TYPE
    ,attribute10                    OKL_DISB_RULES_ALL_B.ATTRIBUTE10%TYPE
    ,attribute11                    OKL_DISB_RULES_ALL_B.ATTRIBUTE11%TYPE
    ,attribute12                    OKL_DISB_RULES_ALL_B.ATTRIBUTE12%TYPE
    ,attribute13                    OKL_DISB_RULES_ALL_B.ATTRIBUTE13%TYPE
    ,attribute14                    OKL_DISB_RULES_ALL_B.ATTRIBUTE14%TYPE
    ,attribute15                    OKL_DISB_RULES_ALL_B.ATTRIBUTE15%TYPE
    ,created_by                     NUMBER
    ,creation_date                  OKL_DISB_RULES_ALL_B.CREATION_DATE%TYPE
    ,last_updated_by                NUMBER
    ,last_update_date               OKL_DISB_RULES_ALL_B.LAST_UPDATE_DATE%TYPE
    ,last_update_login              NUMBER);
  G_MISS_dra_rec                          dra_rec_type;
  TYPE dra_tbl_type IS TABLE OF dra_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_DRA_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_rec                     IN drav_rec_type,
    x_drav_rec                     OUT NOCOPY drav_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_tbl                     IN drav_tbl_type,
    x_drav_tbl                     OUT NOCOPY drav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_tbl                     IN drav_tbl_type,
    x_drav_tbl                     OUT NOCOPY drav_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_rec                     IN drav_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_tbl                     IN drav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_tbl                     IN drav_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_rec                     IN drav_rec_type,
    x_drav_rec                     OUT NOCOPY drav_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_tbl                     IN drav_tbl_type,
    x_drav_tbl                     OUT NOCOPY drav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_tbl                     IN drav_tbl_type,
    x_drav_tbl                     OUT NOCOPY drav_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_rec                     IN drav_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_tbl                     IN drav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_tbl                     IN drav_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_rec                     IN drav_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_tbl                     IN drav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_tbl                     IN drav_tbl_type);
END OKL_DRA_PVT;

/
