--------------------------------------------------------
--  DDL for Package OKL_VFA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VFA_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSVFAS.pls 120.3 2006/11/13 07:35:35 dpsingh noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE vfav_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,major_version                  NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKL_API.G_MISS_NUM
    ,fa_cle_id                      NUMBER := OKL_API.G_MISS_NUM
    ,name                           OKL_CONTRACT_ASSET_HV.NAME%TYPE := OKL_API.G_MISS_CHAR
    ,description                    OKL_CONTRACT_ASSET_HV.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,asset_id                       NUMBER := OKL_API.G_MISS_NUM
    ,asset_number                   OKL_CONTRACT_ASSET_HV.ASSET_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,corporate_book                 OKL_CONTRACT_ASSET_HV.CORPORATE_BOOK%TYPE := OKL_API.G_MISS_CHAR
    ,life_in_months                 NUMBER := OKL_API.G_MISS_NUM
    ,original_cost                  NUMBER := OKL_API.G_MISS_NUM
    ,cost                           NUMBER := OKL_API.G_MISS_NUM
    ,adjusted_cost                  NUMBER := OKL_API.G_MISS_NUM
    ,current_units                  NUMBER := OKL_API.G_MISS_NUM
    ,new_used                       OKL_CONTRACT_ASSET_HV.NEW_USED%TYPE := OKL_API.G_MISS_CHAR
    ,in_service_date                OKL_CONTRACT_ASSET_HV.IN_SERVICE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,model_number                   OKL_CONTRACT_ASSET_HV.MODEL_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,asset_type                     OKL_CONTRACT_ASSET_HV.ASSET_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,salvage_value                  NUMBER := OKL_API.G_MISS_NUM
    ,percent_salvage_value          NUMBER := OKL_API.G_MISS_NUM
    ,depreciation_category          NUMBER := OKL_API.G_MISS_NUM
    ,deprn_start_date               OKL_CONTRACT_ASSET_HV.DEPRN_START_DATE%TYPE := OKL_API.G_MISS_DATE
    ,deprn_method_code              OKL_CONTRACT_ASSET_HV.DEPRN_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,rate_adjustment_factor         NUMBER := OKL_API.G_MISS_NUM
    ,basic_rate                     NUMBER := OKL_API.G_MISS_NUM
    ,adjusted_rate                  NUMBER := OKL_API.G_MISS_NUM
    ,start_date_active              OKL_CONTRACT_ASSET_HV.START_DATE_ACTIVE%TYPE := OKL_API.G_MISS_DATE
    ,end_date_active                OKL_CONTRACT_ASSET_HV.END_DATE_ACTIVE%TYPE := OKL_API.G_MISS_DATE
    ,status                         OKL_CONTRACT_ASSET_HV.STATUS%TYPE := OKL_API.G_MISS_CHAR
    ,primary_uom_code               OKL_CONTRACT_ASSET_HV.PRIMARY_UOM_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,recoverable_cost               NUMBER := OKL_API.G_MISS_NUM
--Bug# 2981308 :
    ,asset_key_id                   NUMBER := OKL_API.G_MISS_NUM
    ,attribute_category             OKL_CONTRACT_ASSET_HV.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_CONTRACT_ASSET_HV.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_CONTRACT_ASSET_HV.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_CONTRACT_ASSET_HV.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_CONTRACT_ASSET_HV.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_CONTRACT_ASSET_HV.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_CONTRACT_ASSET_HV.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_CONTRACT_ASSET_HV.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_CONTRACT_ASSET_HV.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_CONTRACT_ASSET_HV.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_CONTRACT_ASSET_HV.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_CONTRACT_ASSET_HV.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_CONTRACT_ASSET_HV.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_CONTRACT_ASSET_HV.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_CONTRACT_ASSET_HV.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_CONTRACT_ASSET_HV.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CONTRACT_ASSET_HV.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CONTRACT_ASSET_HV.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    --Added by dpsingh for LE uptake
    ,legal_entity_id                   NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_vfav_rec                         vfav_rec_type;
  TYPE vfav_tbl_type IS TABLE OF vfav_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE vfa_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,major_version                  NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKL_API.G_MISS_NUM
    ,fa_cle_id                      NUMBER := OKL_API.G_MISS_NUM
    ,name                           OKL_CONTRACT_ASSET_H.NAME%TYPE := OKL_API.G_MISS_CHAR
    ,description                    OKL_CONTRACT_ASSET_H.DESCRIPTION%TYPE := OKL_API.G_MISS_CHAR
    ,asset_id                       NUMBER := OKL_API.G_MISS_NUM
    ,asset_number                   OKL_CONTRACT_ASSET_H.ASSET_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,corporate_book                 OKL_CONTRACT_ASSET_H.CORPORATE_BOOK%TYPE := OKL_API.G_MISS_CHAR
    ,life_in_months                 NUMBER := OKL_API.G_MISS_NUM
    ,original_cost                  NUMBER := OKL_API.G_MISS_NUM
    ,cost                           NUMBER := OKL_API.G_MISS_NUM
    ,adjusted_cost                  NUMBER := OKL_API.G_MISS_NUM
    ,current_units                  NUMBER := OKL_API.G_MISS_NUM
    ,new_used                       OKL_CONTRACT_ASSET_H.NEW_USED%TYPE := OKL_API.G_MISS_CHAR
    ,in_service_date                OKL_CONTRACT_ASSET_H.IN_SERVICE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,model_number                   OKL_CONTRACT_ASSET_H.MODEL_NUMBER%TYPE := OKL_API.G_MISS_CHAR
    ,asset_type                     OKL_CONTRACT_ASSET_H.ASSET_TYPE%TYPE := OKL_API.G_MISS_CHAR
    ,salvage_value                  NUMBER := OKL_API.G_MISS_NUM
    ,percent_salvage_value          NUMBER := OKL_API.G_MISS_NUM
    ,depreciation_category          NUMBER := OKL_API.G_MISS_NUM
    ,deprn_start_date               OKL_CONTRACT_ASSET_H.DEPRN_START_DATE%TYPE := OKL_API.G_MISS_DATE
    ,deprn_method_code              OKL_CONTRACT_ASSET_H.DEPRN_METHOD_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,rate_adjustment_factor         NUMBER := OKL_API.G_MISS_NUM
    ,basic_rate                     NUMBER := OKL_API.G_MISS_NUM
    ,adjusted_rate                  NUMBER := OKL_API.G_MISS_NUM
    ,start_date_active              OKL_CONTRACT_ASSET_H.START_DATE_ACTIVE%TYPE := OKL_API.G_MISS_DATE
    ,end_date_active                OKL_CONTRACT_ASSET_H.END_DATE_ACTIVE%TYPE := OKL_API.G_MISS_DATE
    ,status                         OKL_CONTRACT_ASSET_H.STATUS%TYPE := OKL_API.G_MISS_CHAR
    ,primary_uom_code               OKL_CONTRACT_ASSET_H.PRIMARY_UOM_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,recoverable_cost               NUMBER := OKL_API.G_MISS_NUM
--Bug# 2981308 :
    ,asset_key_id                   NUMBER := OKL_API.G_MISS_NUM
    ,attribute_category             OKL_CONTRACT_ASSET_H.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_CONTRACT_ASSET_H.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_CONTRACT_ASSET_H.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_CONTRACT_ASSET_H.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_CONTRACT_ASSET_H.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_CONTRACT_ASSET_H.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_CONTRACT_ASSET_H.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_CONTRACT_ASSET_H.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_CONTRACT_ASSET_H.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_CONTRACT_ASSET_H.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_CONTRACT_ASSET_H.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_CONTRACT_ASSET_H.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_CONTRACT_ASSET_H.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_CONTRACT_ASSET_H.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_CONTRACT_ASSET_H.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_CONTRACT_ASSET_H.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CONTRACT_ASSET_H.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CONTRACT_ASSET_H.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    --Added by dpsingh for LE uptake
    ,legal_entity_id                   NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_vfa_rec                          vfa_rec_type;
  TYPE vfa_tbl_type IS TABLE OF vfa_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_VFA_PVT';
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
    p_vfav_rec                     IN vfav_rec_type,
    x_vfav_rec                     OUT NOCOPY vfav_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type,
    x_vfav_tbl                     OUT NOCOPY vfav_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_rec                     IN vfav_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_rec                     IN vfav_rec_type,
    x_vfav_rec                     OUT NOCOPY vfav_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type,
    x_vfav_tbl                     OUT NOCOPY vfav_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_rec                     IN vfav_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_rec                     IN vfav_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type);
END OKL_VFA_PVT;

/
