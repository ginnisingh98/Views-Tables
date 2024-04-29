--------------------------------------------------------
--  DDL for Package OKL_SPP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SPP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSPPS.pls 115.2 2002/02/15 18:20:31 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE spp_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    name                           OKL_SIF_PRICE_PARMS.NAME%TYPE := OKC_API.G_MISS_CHAR,
    version                        OKL_SIF_PRICE_PARMS.VERSION%TYPE := OKC_API.G_MISS_CHAR,
    date_start                     OKL_SIF_PRICE_PARMS.DATE_START%TYPE := OKC_API.G_MISS_DATE,
    date_end                       OKL_SIF_PRICE_PARMS.DATE_END%TYPE := OKC_API.G_MISS_DATE,
    description                    OKL_SIF_PRICE_PARMS.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    sps_code                       OKL_SIF_PRICE_PARMS.SPS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    dyp_code                       OKL_SIF_PRICE_PARMS.DYP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    array_yn                       OKL_SIF_PRICE_PARMS.ARRAY_YN%TYPE := OKC_API.G_MISS_CHAR,
    xml_tag                        OKL_SIF_PRICE_PARMS.XML_TAG%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category			   OKL_SIF_PRICE_PARMS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1					   OKL_SIF_PRICE_PARMS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute2					   OKL_SIF_PRICE_PARMS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3					   OKL_SIF_PRICE_PARMS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4					   OKL_SIF_PRICE_PARMS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5					   OKL_SIF_PRICE_PARMS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6					   OKL_SIF_PRICE_PARMS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7					   OKL_SIF_PRICE_PARMS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8					   OKL_SIF_PRICE_PARMS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9					   OKL_SIF_PRICE_PARMS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10					   OKL_SIF_PRICE_PARMS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11					   OKL_SIF_PRICE_PARMS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12					   OKL_SIF_PRICE_PARMS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13					   OKL_SIF_PRICE_PARMS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14					   OKL_SIF_PRICE_PARMS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15					   OKL_SIF_PRICE_PARMS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_SIF_PRICE_PARMS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_date               OKL_SIF_PRICE_PARMS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_spp_rec                          spp_rec_type;
  TYPE spp_tbl_type IS TABLE OF spp_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE sppv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    name                           OKL_SIF_PRICE_PARMS_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    version                        OKL_SIF_PRICE_PARMS_V.VERSION%TYPE := OKC_API.G_MISS_CHAR,
    date_start                     OKL_SIF_PRICE_PARMS_V.DATE_START%TYPE := OKC_API.G_MISS_DATE,
    date_end                       OKL_SIF_PRICE_PARMS_V.DATE_END%TYPE := OKC_API.G_MISS_DATE,
    description                    OKL_SIF_PRICE_PARMS_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    sps_code                       OKL_SIF_PRICE_PARMS_V.SPS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    dyp_code                       OKL_SIF_PRICE_PARMS_V.DYP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    array_yn                       OKL_SIF_PRICE_PARMS_V.ARRAY_YN%TYPE := OKC_API.G_MISS_CHAR,
    xml_tag                        OKL_SIF_PRICE_PARMS_V.XML_TAG%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category			   OKL_SIF_PRICE_PARMS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute2					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15					   OKL_SIF_PRICE_PARMS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_SIF_PRICE_PARMS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_date               OKL_SIF_PRICE_PARMS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_sppv_rec                         sppv_rec_type;
  TYPE sppv_tbl_type IS TABLE OF sppv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_OKC_APP			CONSTANT VARCHAR2(200) := Okc_Api.G_APP_NAME;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  -- START CHANGE : akjain -- 05/07/2001
  -- Adding MESSAGE CONSTANTs for 'Unique Key Validation','SQLCode', 'SQLErrM','Unexpected Error'
  G_OKL_UNQS                        CONSTANT VARCHAR2(200) := 'OKL_PRICE_PARM_NOT_UNIQUE';
  G_OKL_SQLERRM_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_OKL_SQLCODE_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_OKL_UNEXPECTED_ERROR          	CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_OKL_NO_PARENT_RECORD		CONSTANT VARCHAR2(200) := 'NO PARENT RECORD';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SPP_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  -- Added Exception for Halt_validation
  --------------------------------------------------------------------------------
  -- ERRORS AND EXCEPTIONS
  --------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  -- END change : mvasudev

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN sppv_rec_type,
    x_sppv_rec                     OUT NOCOPY sppv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN sppv_tbl_type,
    x_sppv_tbl                     OUT NOCOPY sppv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN sppv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN sppv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN sppv_rec_type,
    x_sppv_rec                     OUT NOCOPY sppv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN sppv_tbl_type,
    x_sppv_tbl                     OUT NOCOPY sppv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN sppv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN sppv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN sppv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN sppv_tbl_type);

END OKL_SPP_PVT;

 

/
