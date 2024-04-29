--------------------------------------------------------
--  DDL for Package OKL_RAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RAS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSRASS.pls 115.5 2002/12/20 00:06:43 gkadarka noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ras_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    ist_id                         NUMBER := OKC_API.G_MISS_NUM,
    pac_id                         NUMBER := OKC_API.G_MISS_NUM,
    art_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    date_shipping_instructions_sen  OKL_RELOCATE_ASSETS_B.DATE_SHIPPING_INSTRUCTIONS_SEN%TYPE := OKC_API.G_MISS_DATE,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_RELOCATE_ASSETS_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    trans_option_accepted_yn       OKL_RELOCATE_ASSETS_B.TRANS_OPTION_ACCEPTED_YN%TYPE := OKC_API.G_MISS_CHAR,
    insurance_amount               NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKL_RELOCATE_ASSETS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_RELOCATE_ASSETS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_RELOCATE_ASSETS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_RELOCATE_ASSETS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_RELOCATE_ASSETS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_RELOCATE_ASSETS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_RELOCATE_ASSETS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_RELOCATE_ASSETS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_RELOCATE_ASSETS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_RELOCATE_ASSETS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_RELOCATE_ASSETS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_RELOCATE_ASSETS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_RELOCATE_ASSETS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_RELOCATE_ASSETS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_RELOCATE_ASSETS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_RELOCATE_ASSETS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_RELOCATE_ASSETS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_RELOCATE_ASSETS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
  -- RABHUPAT - 2667636 - Start
    currency_code                  OKL_RELOCATE_ASSETS_B.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_code       OKL_RELOCATE_ASSETS_B.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_RELOCATE_ASSETS_B.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       OKL_RELOCATE_ASSETS_B.CURRENCY_CONVERSION_RATE%TYPE := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_RELOCATE_ASSETS_B.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE);
  --RABHUPAT - 2667636 - End
  g_miss_ras_rec                          ras_rec_type;
  TYPE ras_tbl_type IS TABLE OF ras_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OklRelocateAssetsTlRecType IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_RELOCATE_ASSETS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_RELOCATE_ASSETS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_RELOCATE_ASSETS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKL_RELOCATE_ASSETS_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_RELOCATE_ASSETS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_RELOCATE_ASSETS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOklRelocateAssetsTlRec             OklRelocateAssetsTlRecType;
  TYPE OklRelocateAssetsTlTblType IS TABLE OF OklRelocateAssetsTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE rasv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKL_RELOCATE_ASSETS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    art_id                         NUMBER := OKC_API.G_MISS_NUM,
    pac_id                         NUMBER := OKC_API.G_MISS_NUM,
    ist_id                         NUMBER := OKC_API.G_MISS_NUM,
    date_shipping_instructions_sen  OKL_RELOCATE_ASSETS_V.DATE_SHIPPING_INSTRUCTIONS_SEN%TYPE := OKC_API.G_MISS_DATE,
    comments                       OKL_RELOCATE_ASSETS_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    trans_option_accepted_yn       OKL_RELOCATE_ASSETS_V.TRANS_OPTION_ACCEPTED_YN%TYPE := OKC_API.G_MISS_CHAR,
    insurance_amount               NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKL_RELOCATE_ASSETS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_RELOCATE_ASSETS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_RELOCATE_ASSETS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_RELOCATE_ASSETS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_RELOCATE_ASSETS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_RELOCATE_ASSETS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_RELOCATE_ASSETS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_RELOCATE_ASSETS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_RELOCATE_ASSETS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_RELOCATE_ASSETS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_RELOCATE_ASSETS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_RELOCATE_ASSETS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_RELOCATE_ASSETS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_RELOCATE_ASSETS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_RELOCATE_ASSETS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_RELOCATE_ASSETS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_RELOCATE_ASSETS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_RELOCATE_ASSETS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_RELOCATE_ASSETS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
  -- RABHUPAT - 2667636 - Start
    currency_code                  OKL_RELOCATE_ASSETS_V.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_code       OKL_RELOCATE_ASSETS_V.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_RELOCATE_ASSETS_V.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       OKL_RELOCATE_ASSETS_V.CURRENCY_CONVERSION_RATE%TYPE := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_RELOCATE_ASSETS_V.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE);
  -- RABHUPAT - 2667636 - End
  g_miss_rasv_rec                         rasv_rec_type;
  TYPE rasv_tbl_type IS TABLE OF rasv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_RAS_PVT';
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
    p_rasv_rec                     IN rasv_rec_type,
    x_rasv_rec                     OUT NOCOPY rasv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_tbl                     IN rasv_tbl_type,
    x_rasv_tbl                     OUT NOCOPY rasv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_rec                     IN rasv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_tbl                     IN rasv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_rec                     IN rasv_rec_type,
    x_rasv_rec                     OUT NOCOPY rasv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_tbl                     IN rasv_tbl_type,
    x_rasv_tbl                     OUT NOCOPY rasv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_rec                     IN rasv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_tbl                     IN rasv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_rec                     IN rasv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rasv_tbl                     IN rasv_tbl_type);

END OKL_RAS_PVT;

 

/
