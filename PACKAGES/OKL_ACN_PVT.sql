--------------------------------------------------------
--  DDL for Package OKL_ACN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSACNS.pls 115.5 2002/12/20 00:03:43 gkadarka noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE acn_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    sequence_number                NUMBER := OKC_API.G_MISS_NUM,
    acd_id                         NUMBER := OKC_API.G_MISS_NUM,
    ctp_code                       OKL_ASSET_CNDTN_LNS_B.CTP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    cdn_code                       OKL_ASSET_CNDTN_LNS_B.CDN_CODE%TYPE := OKC_API.G_MISS_CHAR,
    dty_code                       OKL_ASSET_CNDTN_LNS_B.DTY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    acs_code                       OKL_ASSET_CNDTN_LNS_B.ACS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    isq_id                         NUMBER := OKC_API.G_MISS_NUM,
    pzt_id                         NUMBER := OKC_API.G_MISS_NUM,
    rpc_id                         NUMBER := OKC_API.G_MISS_NUM,
    estimated_repair_cost          NUMBER := OKC_API.G_MISS_NUM,
    actual_repair_cost             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    approved_by                    NUMBER := OKC_API.G_MISS_NUM,
    approved_yn                    OKL_ASSET_CNDTN_LNS_B.APPROVED_YN%TYPE := OKC_API.G_MISS_CHAR,
    date_approved                  OKL_ASSET_CNDTN_LNS_B.DATE_APPROVED%TYPE := OKC_API.G_MISS_DATE,
    date_reported                  OKL_ASSET_CNDTN_LNS_B.DATE_REPORTED%TYPE := OKC_API.G_MISS_DATE,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_ASSET_CNDTN_LNS_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_ASSET_CNDTN_LNS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_ASSET_CNDTN_LNS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_ASSET_CNDTN_LNS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
  -- RABHUPAT - 2667636 - Start
    currency_code                  OKL_ASSET_CNDTN_LNS_B.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_code       OKL_ASSET_CNDTN_LNS_B.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_ASSET_CNDTN_LNS_B.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       OKL_ASSET_CNDTN_LNS_B.CURRENCY_CONVERSION_RATE%TYPE := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_ASSET_CNDTN_LNS_B.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE);
  --RABHUPAT - 2667636 - End
  g_miss_acn_rec                          acn_rec_type;
  TYPE acn_tbl_type IS TABLE OF acn_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OklAssetCndtnLnsTlRecType IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_ASSET_CNDTN_LNS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_ASSET_CNDTN_LNS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_ASSET_CNDTN_LNS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    damage_description             OKL_ASSET_CNDTN_LNS_TL.DAMAGE_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    claim_description              OKL_ASSET_CNDTN_LNS_TL.CLAIM_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    recommended_repair             OKL_ASSET_CNDTN_LNS_TL.RECOMMENDED_REPAIR%TYPE := OKC_API.G_MISS_CHAR,
    part_name                      OKL_ASSET_CNDTN_LNS_TL.PART_NAME%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_ASSET_CNDTN_LNS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_ASSET_CNDTN_LNS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOklAssetCndtnLnsTlRec              OklAssetCndtnLnsTlRecType;
  TYPE OklAssetCndtnLnsTlTblType IS TABLE OF OklAssetCndtnLnsTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE acnv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKL_ASSET_CNDTN_LNS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    ctp_code                       OKL_ASSET_CNDTN_LNS_V.CTP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    dty_code                       OKL_ASSET_CNDTN_LNS_V.DTY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    cdn_code                       OKL_ASSET_CNDTN_LNS_V.CDN_CODE%TYPE := OKC_API.G_MISS_CHAR,
    acs_code                       OKL_ASSET_CNDTN_LNS_V.ACS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    isq_id                         NUMBER := OKC_API.G_MISS_NUM,
    pzt_id                         NUMBER := OKC_API.G_MISS_NUM,
    acd_id                         NUMBER := OKC_API.G_MISS_NUM,
    rpc_id                         NUMBER := OKC_API.G_MISS_NUM,
    sequence_number                NUMBER := OKC_API.G_MISS_NUM,
    damage_description             OKL_ASSET_CNDTN_LNS_V.DAMAGE_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    claim_description              OKL_ASSET_CNDTN_LNS_V.CLAIM_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    estimated_repair_cost          NUMBER := OKC_API.G_MISS_NUM,
    actual_repair_cost             NUMBER := OKC_API.G_MISS_NUM,
    approved_by                    NUMBER := OKC_API.G_MISS_NUM,
    approved_yn                    OKL_ASSET_CNDTN_LNS_V.APPROVED_YN%TYPE := OKC_API.G_MISS_CHAR,
    date_approved                  OKL_ASSET_CNDTN_LNS_V.DATE_APPROVED%TYPE := OKC_API.G_MISS_DATE,
    date_reported                  OKL_ASSET_CNDTN_LNS_V.DATE_REPORTED%TYPE := OKC_API.G_MISS_DATE,
    recommended_repair             OKL_ASSET_CNDTN_LNS_V.RECOMMENDED_REPAIR%TYPE := OKC_API.G_MISS_CHAR,
    part_name                      OKL_ASSET_CNDTN_LNS_V.PART_NAME%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_ASSET_CNDTN_LNS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_ASSET_CNDTN_LNS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_ASSET_CNDTN_LNS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_ASSET_CNDTN_LNS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
  -- RABHUPAT - 2667636 - Start
    currency_code                  OKL_ASSET_CNDTN_LNS_V.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_code       OKL_ASSET_CNDTN_LNS_V.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_ASSET_CNDTN_LNS_V.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       OKL_ASSET_CNDTN_LNS_V.CURRENCY_CONVERSION_RATE%TYPE := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_ASSET_CNDTN_LNS_V.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE);
  -- RABHUPAT - 2667636 - End
  g_miss_acnv_rec                         acnv_rec_type;
  TYPE acnv_tbl_type IS TABLE OF acnv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_ACN_PVT';
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
    p_acnv_rec                     IN acnv_rec_type,
    x_acnv_rec                     OUT NOCOPY acnv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type,
    x_acnv_tbl                     OUT NOCOPY acnv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type,
    x_acnv_rec                     OUT NOCOPY acnv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type,
    x_acnv_tbl                     OUT NOCOPY acnv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_rec                     IN acnv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acnv_tbl                     IN acnv_tbl_type);

END OKL_ACN_PVT;

 

/
