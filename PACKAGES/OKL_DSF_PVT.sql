--------------------------------------------------------
--  DDL for Package OKL_DSF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DSF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSDSFS.pls 120.2 2006/12/07 06:13:51 ssdeshpa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE dsf_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    name                           OKL_DATA_SRC_FNCTNS_B.NAME%TYPE := OKC_API.G_MISS_CHAR,
    version                        OKL_DATA_SRC_FNCTNS_B.VERSION%TYPE := OKC_API.G_MISS_CHAR,
    source                         OKL_DATA_SRC_FNCTNS_B.SOURCE%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    start_date                     OKL_DATA_SRC_FNCTNS_B.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKL_DATA_SRC_FNCTNS_B.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    fnctn_code                     OKL_DATA_SRC_FNCTNS_B.FNCTN_CODE%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_DATA_SRC_FNCTNS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_DATA_SRC_FNCTNS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_DATA_SRC_FNCTNS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_dsf_rec                          dsf_rec_type;
  TYPE dsf_tbl_type IS TABLE OF dsf_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OklDataSrcFnctnsTlRecType IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_DATA_SRC_FNCTNS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_DATA_SRC_FNCTNS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_DATA_SRC_FNCTNS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_DATA_SRC_FNCTNS_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_DATA_SRC_FNCTNS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_DATA_SRC_FNCTNS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOklDataSrcFnctnsTlRec              OklDataSrcFnctnsTlRecType;
  TYPE OklDataSrcFnctnsTlTblType IS TABLE OF OklDataSrcFnctnsTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE dsfv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKL_DATA_SRC_FNCTNS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    fnctn_code                     OKL_DATA_SRC_FNCTNS_V.FNCTN_CODE%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKL_DATA_SRC_FNCTNS_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_DATA_SRC_FNCTNS_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    version                        OKL_DATA_SRC_FNCTNS_V.VERSION%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKL_DATA_SRC_FNCTNS_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKL_DATA_SRC_FNCTNS_V.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    source                         OKL_DATA_SRC_FNCTNS_V.SOURCE%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_DATA_SRC_FNCTNS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_DATA_SRC_FNCTNS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_DATA_SRC_FNCTNS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_dsfv_rec                         dsfv_rec_type;
  TYPE dsfv_tbl_type IS TABLE OF dsfv_rec_type
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
  --RPOONUGA001: Add message constant
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		    CONSTANT VARCHAR2(200) := 'OKC_SQLERRM';
  G_SQLCODE_TOKEN		    CONSTANT VARCHAR2(200) := 'OKC_SQLCODE';
  G_TABLE_TOKEN		        CONSTANT VARCHAR2(200) := 'OKL_TABLE_NAME';
  G_UPPERCASE_REQUIRED	    CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
  G_ONE_DOI	                CONSTANT VARCHAR2(200) := 'OKC_ONE_DOI';
---  G_UNQS	                CONSTANT VARCHAR2(200) := 'OKL_PMR_NOT_UNIQUE';  ---CHG001
  G_UNQS	                CONSTANT VARCHAR2(200) := 'OKL_NOT_UNIQUE';  ---CHG001
  G_MISS_DATA	 	        CONSTANT VARCHAR2(200) := 'OKL_MISS_DATA';
  G_TO_DATE_ERROR	        CONSTANT VARCHAR2(200) := 'OKL_TO_DATE_ERROR';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_DSF_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  --RPOONUGA001: Add global variables
  G_PLSQL_TYPE	 	    CONSTANT VARCHAR2(200) := 'PLSQL';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;

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
    p_dsfv_rec                     IN dsfv_rec_type,
    x_dsfv_rec                     OUT NOCOPY dsfv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN dsfv_tbl_type,
    x_dsfv_tbl                     OUT NOCOPY dsfv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN dsfv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN dsfv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN dsfv_rec_type,
    x_dsfv_rec                     OUT NOCOPY dsfv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN dsfv_tbl_type,
    x_dsfv_tbl                     OUT NOCOPY dsfv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN dsfv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN dsfv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_rec                     IN dsfv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dsfv_tbl                     IN dsfv_tbl_type);

  PROCEDURE LOAD_SEED_ROW(
    p_upload_mode	     IN VARCHAR2,
    p_data_src_fnctn_id      IN VARCHAR2,
    p_name                   IN VARCHAR2,
    p_version                IN VARCHAR2,
    p_object_version_number  IN VARCHAR2,
    p_source                 IN VARCHAR2,
    p_org_id                 IN VARCHAR2,
    p_start_date             IN VARCHAR2,
    p_end_date               IN VARCHAR2,
    p_fnctn_code             IN VARCHAR2,
    p_attribute_category     IN VARCHAR2,
    p_attribute1             IN VARCHAR2,
    p_attribute2             IN VARCHAR2,
    p_attribute3             IN VARCHAR2,
    p_attribute4             IN VARCHAR2,
    p_attribute5             IN VARCHAR2,
    p_attribute6             IN VARCHAR2,
    p_attribute7             IN VARCHAR2,
    p_attribute8             IN VARCHAR2,
    p_attribute9             IN VARCHAR2,
    p_attribute10            IN VARCHAR2,
    p_attribute11            IN VARCHAR2,
    p_attribute12            IN VARCHAR2,
    p_attribute13            IN VARCHAR2,
    p_attribute14            IN VARCHAR2,
    p_attribute15            IN VARCHAR2,
    p_description            IN VARCHAR2,
    p_owner                  IN VARCHAR2,
    p_last_update_date       IN VARCHAR2);

END OKL_DSF_PVT;

/
