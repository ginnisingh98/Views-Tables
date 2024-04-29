--------------------------------------------------------
--  DDL for Package OKL_ART_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ART_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSARTS.pls 120.5 2007/11/09 22:09:59 djanaswa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE art_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    security_dep_trx_ap_id         NUMBER := OKC_API.G_MISS_NUM,
    iso_id                         NUMBER := OKC_API.G_MISS_NUM,
    rna_id                         NUMBER := OKC_API.G_MISS_NUM,
    rmr_id                         NUMBER := OKC_API.G_MISS_NUM,
    ars_code                       OKL_ASSET_RETURNS_B.ARS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    imr_id                         NUMBER := OKC_API.G_MISS_NUM,
    art1_code                      OKL_ASSET_RETURNS_B.ART1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    date_return_due                OKL_ASSET_RETURNS_B.DATE_RETURN_DUE%TYPE := OKC_API.G_MISS_DATE,
    date_return_notified           OKL_ASSET_RETURNS_B.DATE_RETURN_NOTIFIED%TYPE := OKC_API.G_MISS_DATE,
    relocate_asset_yn              OKL_ASSET_RETURNS_B.RELOCATE_ASSET_YN%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    voluntary_yn                   OKL_ASSET_RETURNS_B.VOLUNTARY_YN%TYPE := OKC_API.G_MISS_CHAR,
    commmercially_reas_sale_yn     OKL_ASSET_RETURNS_B.COMMMERCIALLY_REAS_SALE_YN%TYPE := OKC_API.G_MISS_CHAR,
    date_repossession_required     OKL_ASSET_RETURNS_B.DATE_REPOSSESSION_REQUIRED%TYPE := OKC_API.G_MISS_DATE,
    date_repossession_actual       OKL_ASSET_RETURNS_B.DATE_REPOSSESSION_ACTUAL%TYPE := OKC_API.G_MISS_DATE,
    date_hold_until                OKL_ASSET_RETURNS_B.DATE_HOLD_UNTIL%TYPE := OKC_API.G_MISS_DATE,
    date_returned                  OKL_ASSET_RETURNS_B.DATE_RETURNED%TYPE := OKC_API.G_MISS_DATE,
    date_title_returned            OKL_ASSET_RETURNS_B.DATE_TITLE_RETURNED%TYPE := OKC_API.G_MISS_DATE,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_ASSET_RETURNS_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKL_ASSET_RETURNS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_ASSET_RETURNS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_ASSET_RETURNS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_ASSET_RETURNS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_ASSET_RETURNS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_ASSET_RETURNS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_ASSET_RETURNS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_ASSET_RETURNS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_ASSET_RETURNS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_ASSET_RETURNS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_ASSET_RETURNS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_ASSET_RETURNS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_ASSET_RETURNS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_ASSET_RETURNS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_ASSET_RETURNS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_ASSET_RETURNS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_ASSET_RETURNS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_ASSET_RETURNS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    floor_price                    NUMBER := OKC_API.G_MISS_NUM,
    -- SECHAWLA 30-SEP-04 3924244 : added  a new column new_item_number

    -- 17-MAR-05 SECHAWLA 4239947 : initailize new_item_number to OKC_API.G_MISS_CHAR
    new_item_number                OKL_ASSET_RETURNS_B.new_item_number%TYPE := OKC_API.G_MISS_CHAR,

    new_item_price                 NUMBER := OKC_API.G_MISS_NUM,
    asset_relocated_yn             OKL_ASSET_RETURNS_B.ASSET_RELOCATED_YN%TYPE := OKC_API.G_MISS_CHAR,
    repurchase_agmt_yn             OKL_ASSET_RETURNS_B.REPURCHASE_AGMT_YN%TYPE := OKC_API.G_MISS_CHAR,
    like_kind_yn                   OKL_ASSET_RETURNS_B.LIKE_KIND_YN%TYPE := OKC_API.G_MISS_CHAR,
 -- RABHUPAT - 2667636 - Start
    currency_code                  OKL_ASSET_RETURNS_B.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_code       OKL_ASSET_RETURNS_B.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_ASSET_RETURNS_B.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       OKL_ASSET_RETURNS_B.CURRENCY_CONVERSION_RATE%TYPE := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_ASSET_RETURNS_B.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE,
  --RABHUPAT - 2667636 - End
  -- RRAVIKIR - Legal Entity Changes
    legal_entity_id                OKL_ASSET_RETURNS_B.LEGAL_ENTITY_ID%TYPE := OKC_API.G_MISS_NUM,
  -- Legal Entity Changes End
  -- DJANASWA Loan Repossession proj start
    ASSET_FMV_AMOUNT               OKL_ASSET_RETURNS_B.ASSET_FMV_AMOUNT%TYPE := OKC_API.G_MISS_NUM);
  --   Loan Repossession proj end
  g_miss_art_rec                          art_rec_type;
  TYPE art_tbl_type IS TABLE OF art_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_asset_returns_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_ASSET_RETURNS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_ASSET_RETURNS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_ASSET_RETURNS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKL_ASSET_RETURNS_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_ASSET_RETURNS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_ASSET_RETURNS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    new_item_description           OKL_ASSET_RETURNS_TL.NEW_ITEM_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR);
  GMissOklAssetReturnsTlRec               okl_asset_returns_tl_rec_type;
  TYPE okl_asset_returns_tl_tbl_type IS TABLE OF okl_asset_returns_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE artv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKL_ASSET_RETURNS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    rmr_id                         NUMBER := OKC_API.G_MISS_NUM,
    imr_id                         NUMBER := OKC_API.G_MISS_NUM,
    rna_id                         NUMBER := OKC_API.G_MISS_NUM,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    iso_id                         NUMBER := OKC_API.G_MISS_NUM,
    security_dep_trx_ap_id         NUMBER := OKC_API.G_MISS_NUM,
    ars_code                       OKL_ASSET_RETURNS_V.ARS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    art1_code                      OKL_ASSET_RETURNS_V.ART1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    date_returned                  OKL_ASSET_RETURNS_V.DATE_RETURNED%TYPE := OKC_API.G_MISS_DATE,
    date_title_returned            OKL_ASSET_RETURNS_V.DATE_TITLE_RETURNED%TYPE := OKC_API.G_MISS_DATE,
    date_return_due                OKL_ASSET_RETURNS_V.DATE_RETURN_DUE%TYPE := OKC_API.G_MISS_DATE,
    date_return_notified           OKL_ASSET_RETURNS_V.DATE_RETURN_NOTIFIED%TYPE := OKC_API.G_MISS_DATE,
    relocate_asset_yn              OKL_ASSET_RETURNS_V.RELOCATE_ASSET_YN%TYPE := OKC_API.G_MISS_CHAR,
    voluntary_yn                   OKL_ASSET_RETURNS_V.VOLUNTARY_YN%TYPE := OKC_API.G_MISS_CHAR,
    date_repossession_required     OKL_ASSET_RETURNS_V.DATE_REPOSSESSION_REQUIRED%TYPE := OKC_API.G_MISS_DATE,
    date_repossession_actual       OKL_ASSET_RETURNS_V.DATE_REPOSSESSION_ACTUAL%TYPE := OKC_API.G_MISS_DATE,
    date_hold_until                OKL_ASSET_RETURNS_V.DATE_HOLD_UNTIL%TYPE := OKC_API.G_MISS_DATE,
    commmercially_reas_sale_yn     OKL_ASSET_RETURNS_V.COMMMERCIALLY_REAS_SALE_YN%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKL_ASSET_RETURNS_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKL_ASSET_RETURNS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_ASSET_RETURNS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_ASSET_RETURNS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_ASSET_RETURNS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_ASSET_RETURNS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_ASSET_RETURNS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_ASSET_RETURNS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_ASSET_RETURNS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_ASSET_RETURNS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_ASSET_RETURNS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_ASSET_RETURNS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_ASSET_RETURNS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_ASSET_RETURNS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_ASSET_RETURNS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_ASSET_RETURNS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_ASSET_RETURNS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_ASSET_RETURNS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_ASSET_RETURNS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_ASSET_RETURNS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    floor_price                    NUMBER := OKC_API.G_MISS_NUM,
    -- SECHAWLA 30-SEP-04 3924244 : added  a new column new_item_number

    -- 17-MAR-05 SECHAWLA 4239947 : initailize new_item_number to OKC_API.G_MISS_CHAR
    new_item_number                OKL_ASSET_RETURNS_B.new_item_number%TYPE := OKC_API.G_MISS_CHAR,
    new_item_price                 NUMBER := OKC_API.G_MISS_NUM,
    asset_relocated_yn             OKL_ASSET_RETURNS_V.ASSET_RELOCATED_YN%TYPE := OKC_API.G_MISS_CHAR,
    new_item_description           OKL_ASSET_RETURNS_V.NEW_ITEM_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    repurchase_agmt_yn             OKL_ASSET_RETURNS_V.REPURCHASE_AGMT_YN%TYPE := OKC_API.G_MISS_CHAR,
    like_kind_yn                   OKL_ASSET_RETURNS_V.LIKE_KIND_YN%TYPE := OKC_API.G_MISS_CHAR,
  -- RABHUPAT - 2667636 - Start
    currency_code                  OKL_ASSET_RETURNS_V.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_code       OKL_ASSET_RETURNS_V.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_ASSET_RETURNS_V.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       OKL_ASSET_RETURNS_V.CURRENCY_CONVERSION_RATE%TYPE := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_ASSET_RETURNS_V.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE,
  -- RABHUPAT - 2667636 - End
  -- RRAVIKIR - Legal Entity Changes
    legal_entity_id                OKL_ASSET_RETURNS_B.LEGAL_ENTITY_ID%TYPE := OKC_API.G_MISS_NUM,
  -- Legal Entity Changes End
  -- DJANASWA Loan Repossession proj start
    ASSET_FMV_AMOUNT               OKL_ASSET_RETURNS_V.ASSET_FMV_AMOUNT%TYPE := OKC_API.G_MISS_NUM);
  --   Loan Repossession proj end

  g_miss_artv_rec                         artv_rec_type;
  TYPE artv_tbl_type IS TABLE OF artv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_ART_PVT';
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
    p_artv_rec                     IN artv_rec_type,
    x_artv_rec                     OUT NOCOPY artv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_tbl                     IN artv_tbl_type,
    x_artv_tbl                     OUT NOCOPY artv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_rec                     IN artv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_tbl                     IN artv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_rec                     IN artv_rec_type,
    x_artv_rec                     OUT NOCOPY artv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_tbl                     IN artv_tbl_type,
    x_artv_tbl                     OUT NOCOPY artv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_rec                     IN artv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_tbl                     IN artv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_rec                     IN artv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_artv_tbl                     IN artv_tbl_type);

END OKL_ART_PVT;

/
