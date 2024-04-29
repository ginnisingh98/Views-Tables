--------------------------------------------------------
--  DDL for Package OKL_PTC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PTC_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSPTCS.pls 120.2 2005/10/30 04:43:55 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ptcv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,sequence_number                NUMBER := OKC_API.G_MISS_NUM
    ,asset_id                       NUMBER := OKC_API.G_MISS_NUM
    ,asset_number                   OKL_PROPERTY_TAX_V.ASSET_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,contract_number                OKL_PROPERTY_TAX_V.contract_number%TYPE := OKC_API.G_MISS_CHAR
    ,sty_name                       OKL_PROPERTY_TAX_V.STY_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,sty_id                         NUMBER := OKC_API.G_MISS_NUM
    ,invoice_date                   OKL_PROPERTY_TAX_V.INVOICE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,amount                         NUMBER := OKC_API.G_MISS_NUM
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,asset_description              OKL_PROPERTY_TAX_V.ASSET_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,kle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,asset_units                    NUMBER := OKC_API.G_MISS_NUM
    ,language                       OKL_PROPERTY_TAX_V.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR
    ,source_lang                    OKL_PROPERTY_TAX_V.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR
    ,sfwt_flag                      OKL_PROPERTY_TAX_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,asset_address_1                OKL_PROPERTY_TAX_V.ASSET_ADDRESS_1%TYPE := OKC_API.G_MISS_CHAR
    ,asset_address_2                OKL_PROPERTY_TAX_V.ASSET_ADDRESS_2%TYPE := OKC_API.G_MISS_CHAR
    ,asset_address_3                OKL_PROPERTY_TAX_V.ASSET_ADDRESS_3%TYPE := OKC_API.G_MISS_CHAR
    ,asset_address_4                OKL_PROPERTY_TAX_V.ASSET_ADDRESS_4%TYPE := OKC_API.G_MISS_CHAR
    ,asset_city                     OKL_PROPERTY_TAX_V.ASSET_CITY%TYPE := OKC_API.G_MISS_CHAR
    ,asset_state                    OKL_PROPERTY_TAX_V.ASSET_STATE%TYPE := OKC_API.G_MISS_CHAR
    ,asset_country                  OKL_PROPERTY_TAX_V.ASSET_COUNTRY%TYPE := OKC_API.G_MISS_CHAR
    ,tax_assessment_amount          NUMBER := OKC_API.G_MISS_NUM
    ,tax_jurisdiction_city          OKL_PROPERTY_TAX_V.TAX_JURISDICTION_CITY%TYPE := OKC_API.G_MISS_CHAR
    -- End Addition for Est Property Tax
    ,JURSDCTN_TYPE                  OKL_PROPERTY_TAX_V.JURSDCTN_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,JURSDCTN_NAME                  OKL_PROPERTY_TAX_V.JURSDCTN_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,MLRT_TAX                       NUMBER := OKC_API.G_MISS_NUM
    ,TAX_VENDOR_ID                  NUMBER := OKC_API.G_MISS_NUM
    ,TAX_VENDOR_NAME                OKL_PROPERTY_TAX_V.TAX_VENDOR_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,TAX_VENDOR_SITE_ID             NUMBER := OKC_API.G_MISS_NUM
    ,TAX_VENDOR_SITE_NAME           OKL_PROPERTY_TAX_V.TAX_VENDOR_SITE_NAME%TYPE := OKC_API.G_MISS_CHAR
    -- End Addition for Est Property Tax
    ,tax_jurisdiction_city_rate     NUMBER := OKC_API.G_MISS_NUM
    ,tax_jurisdiction_county        OKL_PROPERTY_TAX_V.TAX_JURISDICTION_COUNTY%TYPE := OKC_API.G_MISS_CHAR
    ,tax_jurisdiction_county_rate   NUMBER := OKC_API.G_MISS_NUM
    ,tax_jurisdiction_state         OKL_PROPERTY_TAX_V.TAX_JURISDICTION_STATE%TYPE := OKC_API.G_MISS_CHAR
    ,tax_jurisdiction_state_rate    NUMBER := OKC_API.G_MISS_NUM
    ,tax_jurisdiction_school        OKL_PROPERTY_TAX_V.TAX_JURISDICTION_SCHOOL%TYPE := OKC_API.G_MISS_CHAR
    ,tax_jurisdiction_school_rate   NUMBER := OKC_API.G_MISS_NUM
    ,tax_jurisdiction_country       OKL_PROPERTY_TAX_V.TAX_JURISDICTION_COUNTRY%TYPE := OKC_API.G_MISS_CHAR
    ,tax_jurisdiction_country_rate  NUMBER := OKC_API.G_MISS_NUM
    ,tax_assessment_date            OKL_PROPERTY_TAX_V.TAX_ASSESSMENT_DATE%TYPE := OKC_API.G_MISS_DATE
    ,milrate                        NUMBER := OKC_API.G_MISS_NUM
    ,property_tax_amount            NUMBER := OKC_API.G_MISS_NUM
    ,oec                            NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_PROPERTY_TAX_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_PROPERTY_TAX_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_ptcv_rec                         ptcv_rec_type;
  TYPE ptcv_tbl_type IS TABLE OF ptcv_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE ptc_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,sequence_number                NUMBER := OKC_API.G_MISS_NUM
    ,asset_id                       NUMBER := OKC_API.G_MISS_NUM
    ,asset_number                   OKL_PROPERTY_TAX_B.ASSET_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,kle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,asset_units                    NUMBER := OKC_API.G_MISS_NUM
    ,asset_address_1                OKL_PROPERTY_TAX_B.ASSET_ADDRESS_1%TYPE := OKC_API.G_MISS_CHAR
    ,asset_address_2                OKL_PROPERTY_TAX_B.ASSET_ADDRESS_2%TYPE := OKC_API.G_MISS_CHAR
    ,asset_address_3                OKL_PROPERTY_TAX_B.ASSET_ADDRESS_3%TYPE := OKC_API.G_MISS_CHAR
    ,asset_address_4                OKL_PROPERTY_TAX_B.ASSET_ADDRESS_4%TYPE := OKC_API.G_MISS_CHAR
    ,asset_city                     OKL_PROPERTY_TAX_B.ASSET_CITY%TYPE := OKC_API.G_MISS_CHAR
    ,asset_state                    OKL_PROPERTY_TAX_B.ASSET_STATE%TYPE := OKC_API.G_MISS_CHAR
    ,asset_country                  OKL_PROPERTY_TAX_B.ASSET_COUNTRY%TYPE := OKC_API.G_MISS_CHAR
    ,tax_assessment_amount          NUMBER := OKC_API.G_MISS_NUM
    ,tax_jurisdiction_city          OKL_PROPERTY_TAX_B.TAX_JURISDICTION_CITY%TYPE := OKC_API.G_MISS_CHAR
    -- Addition for Est Property Tax
    ,JURSDCTN_TYPE                  OKL_PROPERTY_TAX_B.JURSDCTN_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,JURSDCTN_NAME                  OKL_PROPERTY_TAX_B.JURSDCTN_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,MLRT_TAX                       NUMBER := OKC_API.G_MISS_NUM
    ,TAX_VENDOR_ID                  NUMBER := OKC_API.G_MISS_NUM
    ,TAX_VENDOR_NAME                OKL_PROPERTY_TAX_B.TAX_VENDOR_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,TAX_VENDOR_SITE_ID             NUMBER := OKC_API.G_MISS_NUM
    ,TAX_VENDOR_SITE_NAME           OKL_PROPERTY_TAX_B.TAX_VENDOR_SITE_NAME%TYPE := OKC_API.G_MISS_CHAR
    -- End Addition for Est Property Tax
    ,tax_jurisdiction_city_rate     NUMBER := OKC_API.G_MISS_NUM
    ,tax_jurisdiction_county        OKL_PROPERTY_TAX_B.TAX_JURISDICTION_COUNTY%TYPE := OKC_API.G_MISS_CHAR
    ,tax_jurisdiction_county_rate   NUMBER := OKC_API.G_MISS_NUM
    ,tax_jurisdiction_state         OKL_PROPERTY_TAX_B.TAX_JURISDICTION_STATE%TYPE := OKC_API.G_MISS_CHAR
    ,tax_jurisdiction_state_rate    NUMBER := OKC_API.G_MISS_NUM
    ,tax_jurisdiction_school        OKL_PROPERTY_TAX_B.TAX_JURISDICTION_SCHOOL%TYPE := OKC_API.G_MISS_CHAR
    ,tax_jurisdiction_school_rate   NUMBER := OKC_API.G_MISS_NUM
    ,tax_jurisdiction_country       OKL_PROPERTY_TAX_B.TAX_JURISDICTION_COUNTRY%TYPE := OKC_API.G_MISS_CHAR
    ,tax_jurisdiction_country_rate  NUMBER := OKC_API.G_MISS_NUM
    ,tax_assessment_date            OKL_PROPERTY_TAX_B.TAX_ASSESSMENT_DATE%TYPE := OKC_API.G_MISS_DATE
    ,milrate                        NUMBER := OKC_API.G_MISS_NUM
    ,property_tax_amount            NUMBER := OKC_API.G_MISS_NUM
    ,oec                            NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_PROPERTY_TAX_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_PROPERTY_TAX_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,contract_number                OKL_PROPERTY_TAX_B.contract_number%TYPE := OKC_API.G_MISS_CHAR
    ,sty_name                       OKL_PROPERTY_TAX_B.STY_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,sty_id                         NUMBER := OKC_API.G_MISS_NUM
    ,invoice_date                   OKL_PROPERTY_TAX_B.INVOICE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,amount                         NUMBER := OKC_API.G_MISS_NUM
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_ptc_rec                          ptc_rec_type;
  TYPE ptc_tbl_type IS TABLE OF ptc_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE ptct_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,language                       OKL_PROPERTY_TAX_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR
    ,source_lang                    OKL_PROPERTY_TAX_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR
    ,sfwt_flag                      OKL_PROPERTY_TAX_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,asset_description              OKL_PROPERTY_TAX_TL.ASSET_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_PROPERTY_TAX_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_PROPERTY_TAX_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_ptct_rec                         ptct_rec_type;
  TYPE ptct_tbl_type IS TABLE OF ptct_rec_type
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
  --G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  --G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  --G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  --G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_PTC_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;

  -------------------------------------------------------------------------------
  --Post change to TAPI code
  -------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLCODE';
  g_no_parent_record            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  ---------------------------------------------------------------------------

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
    p_ptcv_rec                     IN ptcv_rec_type,
    x_ptcv_rec                     OUT NOCOPY ptcv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type,
    x_ptcv_tbl                     OUT NOCOPY ptcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type,
    x_ptcv_tbl                     OUT NOCOPY ptcv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_rec                     IN ptcv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_rec                     IN ptcv_rec_type,
    x_ptcv_rec                     OUT NOCOPY ptcv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type,
    x_ptcv_tbl                     OUT NOCOPY ptcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type,
    x_ptcv_tbl                     OUT NOCOPY ptcv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_rec                     IN ptcv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_rec                     IN ptcv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptcv_tbl                     IN ptcv_tbl_type);
END OKL_PTC_PVT;

 

/
