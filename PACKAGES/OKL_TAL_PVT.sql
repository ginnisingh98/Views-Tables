--------------------------------------------------------
--  DDL for Package OKL_TAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TAL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTALS.pls 120.4 2006/02/13 20:45:41 rpillay noship $ */
-- Badrinath Kuchibholta
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE tal_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    tas_id                         NUMBER := OKC_API.G_MISS_NUM,
    ilo_id                         NUMBER := OKC_API.G_MISS_NUM,
    ilo_id_old                     NUMBER := OKC_API.G_MISS_NUM,
    iay_id                         NUMBER := OKC_API.G_MISS_NUM,
    iay_id_new                     NUMBER := OKC_API.G_MISS_NUM,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    dnz_khr_id                     NUMBER := OKC_API.G_MISS_NUM,
    line_number                    NUMBER := OKC_API.G_MISS_NUM,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    tal_type                       OKL_TXL_ASSETS_B.TAL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    asset_number                   OKL_TXL_ASSETS_B.ASSET_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    fa_location_id                 NUMBER := OKC_API.G_MISS_NUM,
    original_cost                  NUMBER := OKC_API.G_MISS_NUM,
    current_units                  NUMBER := OKC_API.G_MISS_NUM,
    manufacturer_name              OKL_TXL_ASSETS_B.MANUFACTURER_NAME%TYPE := OKC_API.G_MISS_CHAR,
    year_manufactured              NUMBER := OKC_API.G_MISS_NUM,
    supplier_id                    NUMBER := OKC_API.G_MISS_NUM,
    used_asset_yn                  OKL_TXL_ASSETS_B.USED_ASSET_YN%TYPE := OKC_API.G_MISS_CHAR,
    tag_number                     OKL_TXL_ASSETS_B.TAG_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    model_number                   OKL_TXL_ASSETS_B.MODEL_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    corporate_book                 OKL_TXL_ASSETS_B.CORPORATE_BOOK%TYPE := OKC_API.G_MISS_CHAR,
    date_purchased                 OKL_TXL_ASSETS_B.DATE_PURCHASED%TYPE := OKC_API.G_MISS_DATE,
    date_delivery                  OKL_TXL_ASSETS_B.DATE_DELIVERY%TYPE := OKC_API.G_MISS_DATE,
    in_service_date                OKL_TXL_ASSETS_B.IN_SERVICE_DATE%TYPE := OKC_API.G_MISS_DATE,
    life_in_months                 NUMBER := OKC_API.G_MISS_NUM,
    depreciation_id                NUMBER := OKC_API.G_MISS_NUM,
    depreciation_cost              NUMBER := OKC_API.G_MISS_NUM,
    deprn_method                   OKL_TXL_ASSETS_B.DEPRN_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    deprn_rate                     NUMBER := OKC_API.G_MISS_NUM,
    salvage_value                  NUMBER := OKC_API.G_MISS_NUM,
    percent_salvage_value          NUMBER := OKC_API.G_MISS_NUM,
    --Bug# 2981308
    asset_key_id                   NUMBER := OKL_API.G_MISS_NUM,
    -- Bug 4028371
    fa_trx_date                    OKL_TXL_ASSETS_B.FA_TRX_DATE%TYPE := OKC_API.G_MISS_DATE,
    --Bug# 4899328
    fa_cost                        NUMBER := OKL_API.G_MISS_NUM,
    attribute_category             OKL_TXL_ASSETS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_TXL_ASSETS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_TXL_ASSETS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_TXL_ASSETS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_TXL_ASSETS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_TXL_ASSETS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_TXL_ASSETS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_TXL_ASSETS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_TXL_ASSETS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_TXL_ASSETS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_TXL_ASSETS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_TXL_ASSETS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_TXL_ASSETS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_TXL_ASSETS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_TXL_ASSETS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_TXL_ASSETS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TXL_ASSETS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TXL_ASSETS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    depreciate_yn                  OKL_TXL_ASSETS_B.DEPRECIATE_YN%TYPE := OKC_API.G_MISS_CHAR,
    hold_period_days               NUMBER := OKC_API.G_MISS_NUM,
    old_salvage_value              NUMBER := OKC_API.G_MISS_NUM,
    new_residual_value             NUMBER := OKC_API.G_MISS_NUM,
    old_residual_value             NUMBER := OKC_API.G_MISS_NUM,
    units_retired                  NUMBER := OKC_API.G_MISS_NUM,
    cost_retired                   NUMBER := OKC_API.G_MISS_NUM,
    sale_proceeds                  NUMBER := OKC_API.G_MISS_NUM,
    removal_cost                   NUMBER := OKC_API.G_MISS_NUM,
    dnz_asset_id                   NUMBER := OKC_API.G_MISS_NUM,
    date_due                       OKL_TXL_ASSETS_B.DATE_DUE%TYPE := OKC_API.G_MISS_DATE,
    rep_asset_id                   NUMBER := OKC_API.G_MISS_NUM,
    lke_asset_id                   NUMBER := OKC_API.G_MISS_NUM,
    match_amount                   NUMBER := OKC_API.G_MISS_NUM,
    split_into_singles_flag        OKL_TXL_ASSETS_B.SPLIT_INTO_SINGLES_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    split_into_units               NUMBER := OKC_API.G_MISS_NUM,
-- Multi-Currency Change
    currency_code                  OKL_TXL_ASSETS_B.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_TXL_ASSETS_B.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       NUMBER := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_TXL_ASSETS_B.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE,
-- Multi-Currency Change
-- VRS Project - START
    RESIDUAL_SHR_PARTY_ID          NUMBER := OKC_API.G_MISS_NUM,
    RESIDUAL_SHR_AMOUNT            NUMBER := OKC_API.G_MISS_NUM,
    RETIREMENT_ID                  NUMBER := OKC_API.G_MISS_NUM
-- VRS Project - END
);
  g_miss_tal_rec                          tal_rec_type;
  TYPE tal_tbl_type IS TABLE OF tal_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_txl_assets_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_TXL_ASSETS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_TXL_ASSETS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_TXL_ASSETS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_TXL_ASSETS_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TXL_ASSETS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TXL_ASSETS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_okl_txl_assets_tl_rec            okl_txl_assets_tl_rec_type;
  TYPE okl_txl_assets_tl_tbl_type IS TABLE OF okl_txl_assets_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE talv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKL_TXL_ASSETS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    tas_id                         NUMBER := OKC_API.G_MISS_NUM,
    ilo_id                         NUMBER := OKC_API.G_MISS_NUM,
    ilo_id_old                     NUMBER := OKC_API.G_MISS_NUM,
    iay_id                         NUMBER := OKC_API.G_MISS_NUM,
    iay_id_new                     NUMBER := OKC_API.G_MISS_NUM,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    dnz_khr_id                     NUMBER := OKC_API.G_MISS_NUM,
    line_number                    NUMBER := OKC_API.G_MISS_NUM,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    tal_type                       OKL_TXL_ASSETS_V.TAL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    asset_number                   OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_TXL_ASSETS_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    fa_location_id                 NUMBER := OKC_API.G_MISS_NUM,
    original_cost                  NUMBER := OKC_API.G_MISS_NUM,
    current_units                  NUMBER := OKC_API.G_MISS_NUM,
    manufacturer_name              OKL_TXL_ASSETS_B.MANUFACTURER_NAME%TYPE := OKC_API.G_MISS_CHAR,
    year_manufactured              NUMBER := OKC_API.G_MISS_NUM,
    supplier_id                    NUMBER := OKC_API.G_MISS_NUM,
    used_asset_yn                  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE := OKC_API.G_MISS_CHAR,
    tag_number                     OKL_TXL_ASSETS_V.TAG_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    model_number                   OKL_TXL_ASSETS_V.MODEL_NUMBER%TYPE := OKC_API.G_MISS_CHAR,
    corporate_book                 OKL_TXL_ASSETS_V.CORPORATE_BOOK%TYPE := OKC_API.G_MISS_CHAR,
    date_purchased                 OKL_TXL_ASSETS_V.DATE_PURCHASED%TYPE := OKC_API.G_MISS_DATE,
    date_delivery                  OKL_TXL_ASSETS_V.DATE_DELIVERY%TYPE := OKC_API.G_MISS_DATE,
    in_service_date                OKL_TXL_ASSETS_V.IN_SERVICE_DATE%TYPE := OKC_API.G_MISS_DATE,
    life_in_months                 NUMBER := OKC_API.G_MISS_NUM,
    depreciation_id                NUMBER := OKC_API.G_MISS_NUM,
    depreciation_cost              NUMBER := OKC_API.G_MISS_NUM,
    deprn_method                   OKL_TXL_ASSETS_V.DEPRN_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    deprn_rate                     NUMBER := OKC_API.G_MISS_NUM,
    salvage_value                  NUMBER := OKC_API.G_MISS_NUM,
    percent_salvage_value          NUMBER := OKC_API.G_MISS_NUM,
    --Bug# 2981308
    asset_key_id                   NUMBER := OKL_API.G_MISS_NUM,
    -- Bug 4028371
    fa_trx_date                    OKL_TXL_ASSETS_V.FA_TRX_DATE%TYPE := OKC_API.G_MISS_DATE,
    --Bug# 4899328
    fa_cost                        NUMBER := OKL_API.G_MISS_NUM,
    attribute_category             OKL_TXL_ASSETS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_TXL_ASSETS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_TXL_ASSETS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_TXL_ASSETS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_TXL_ASSETS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_TXL_ASSETS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_TXL_ASSETS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_TXL_ASSETS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_TXL_ASSETS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_TXL_ASSETS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_TXL_ASSETS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_TXL_ASSETS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_TXL_ASSETS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_TXL_ASSETS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_TXL_ASSETS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_TXL_ASSETS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TXL_ASSETS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TXL_ASSETS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    depreciate_yn                  OKL_TXL_ASSETS_B.DEPRECIATE_YN%TYPE := OKC_API.G_MISS_CHAR,
    hold_period_days               NUMBER := OKC_API.G_MISS_NUM,
    old_salvage_value              NUMBER := OKC_API.G_MISS_NUM,
    new_residual_value             NUMBER := OKC_API.G_MISS_NUM,
    old_residual_value             NUMBER := OKC_API.G_MISS_NUM,
    units_retired                  NUMBER := OKC_API.G_MISS_NUM,
    cost_retired                   NUMBER := OKC_API.G_MISS_NUM,
    sale_proceeds                  NUMBER := OKC_API.G_MISS_NUM,
    removal_cost                   NUMBER := OKC_API.G_MISS_NUM,
    dnz_asset_id                   NUMBER := OKC_API.G_MISS_NUM,
    date_due                       OKL_TXL_ASSETS_B.DATE_DUE%TYPE := OKC_API.G_MISS_DATE,
    rep_asset_id                   NUMBER := OKC_API.G_MISS_NUM,
    lke_asset_id                   NUMBER := OKC_API.G_MISS_NUM,
    match_amount                   NUMBER := OKC_API.G_MISS_NUM,
    split_into_singles_flag        OKL_TXL_ASSETS_B.SPLIT_INTO_SINGLES_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    split_into_units               NUMBER := OKC_API.G_MISS_NUM,
-- Multi-Currency Change
    currency_code                  OKL_TXL_ASSETS_B.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_TXL_ASSETS_B.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       NUMBER := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_TXL_ASSETS_B.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE,
-- Multi-Currency Change
-- VRS Project - START
    RESIDUAL_SHR_PARTY_ID          NUMBER := OKC_API.G_MISS_NUM,
    RESIDUAL_SHR_AMOUNT            NUMBER := OKC_API.G_MISS_NUM,
    RETIREMENT_ID                  NUMBER := OKC_API.G_MISS_NUM
-- VRS Project - END
  );

  g_miss_talv_rec                         talv_rec_type;
  TYPE talv_tbl_type IS TABLE OF talv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TAL_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
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
    p_talv_rec                     IN talv_rec_type,
    x_talv_rec                     OUT NOCOPY talv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type,
    x_talv_tbl                     OUT NOCOPY talv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type,
    x_talv_rec                     OUT NOCOPY talv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type,
    x_talv_tbl                     OUT NOCOPY talv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type);

END OKL_TAL_PVT;

/
