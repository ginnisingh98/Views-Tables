--------------------------------------------------------
--  DDL for Package OKL_RFC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RFC_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSRFCS.pls 115.4 2002/12/20 00:07:14 gkadarka noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE rfc_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    cos_code                       OKL_REMARKTNG_COSTS_B.COS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    art_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_REMARKTNG_COSTS_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKL_REMARKTNG_COSTS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_REMARKTNG_COSTS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_REMARKTNG_COSTS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_REMARKTNG_COSTS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_REMARKTNG_COSTS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_REMARKTNG_COSTS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_REMARKTNG_COSTS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_REMARKTNG_COSTS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_REMARKTNG_COSTS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_REMARKTNG_COSTS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_REMARKTNG_COSTS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_REMARKTNG_COSTS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_REMARKTNG_COSTS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_REMARKTNG_COSTS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_REMARKTNG_COSTS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_REMARKTNG_COSTS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_REMARKTNG_COSTS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_REMARKTNG_COSTS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
  -- RABHUPAT - 2667636 - Start
    currency_code                  OKL_REMARKTNG_COSTS_B.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_code       OKL_REMARKTNG_COSTS_B.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_REMARKTNG_COSTS_B.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       OKL_REMARKTNG_COSTS_B.CURRENCY_CONVERSION_RATE%TYPE := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_REMARKTNG_COSTS_B.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE);
  --RABHUPAT - 2667636 - End
  g_miss_rfc_rec                          rfc_rec_type;
  TYPE rfc_tbl_type IS TABLE OF rfc_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OklRemarktngCostsTlRecType IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_REMARKTNG_COSTS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_REMARKTNG_COSTS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_REMARKTNG_COSTS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKL_REMARKTNG_COSTS_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_REMARKTNG_COSTS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_REMARKTNG_COSTS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOklRemarktngCostsTlRec             OklRemarktngCostsTlRecType;
  TYPE OklRemarktngCostsTlTblType IS TABLE OF OklRemarktngCostsTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE rfcv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKL_REMARKTNG_COSTS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    art_id                         NUMBER := OKC_API.G_MISS_NUM,
    cos_code                       OKL_REMARKTNG_COSTS_V.COS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    comments                       OKL_REMARKTNG_COSTS_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKL_REMARKTNG_COSTS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_REMARKTNG_COSTS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_REMARKTNG_COSTS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_REMARKTNG_COSTS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_REMARKTNG_COSTS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_REMARKTNG_COSTS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_REMARKTNG_COSTS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_REMARKTNG_COSTS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_REMARKTNG_COSTS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_REMARKTNG_COSTS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_REMARKTNG_COSTS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_REMARKTNG_COSTS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_REMARKTNG_COSTS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_REMARKTNG_COSTS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_REMARKTNG_COSTS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_REMARKTNG_COSTS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_REMARKTNG_COSTS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_REMARKTNG_COSTS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_REMARKTNG_COSTS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
  -- RABHUPAT - 2667636 - Start
    currency_code                  OKL_REMARKTNG_COSTS_V.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_code       OKL_REMARKTNG_COSTS_V.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_REMARKTNG_COSTS_V.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       OKL_REMARKTNG_COSTS_V.CURRENCY_CONVERSION_RATE%TYPE := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_REMARKTNG_COSTS_V.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE);
  -- RABHUPAT - 2667636 - End
  g_miss_rfcv_rec                         rfcv_rec_type;
  TYPE rfcv_tbl_type IS TABLE OF rfcv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP						CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED			CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED			CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE				CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE				CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN				CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN			CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN			CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_RFC_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
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
    p_rfcv_rec                     IN rfcv_rec_type,
    x_rfcv_rec                     OUT NOCOPY rfcv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rfcv_tbl                     IN rfcv_tbl_type,
    x_rfcv_tbl                     OUT NOCOPY rfcv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rfcv_rec                     IN rfcv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rfcv_tbl                     IN rfcv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rfcv_rec                     IN rfcv_rec_type,
    x_rfcv_rec                     OUT NOCOPY rfcv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rfcv_tbl                     IN rfcv_tbl_type,
    x_rfcv_tbl                     OUT NOCOPY rfcv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rfcv_rec                     IN rfcv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rfcv_tbl                     IN rfcv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rfcv_rec                     IN rfcv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rfcv_tbl                     IN rfcv_tbl_type);

END OKL_RFC_PVT;

 

/
