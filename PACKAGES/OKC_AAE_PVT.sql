--------------------------------------------------------
--  DDL for Package OKC_AAE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_AAE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSAAES.pls 120.0 2005/05/26 09:55:20 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE aae_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    aal_id                         NUMBER := OKC_API.G_MISS_NUM,
    acn_id                         NUMBER := OKC_API.G_MISS_NUM,
    element_name                   OKC_ACTION_ATTRIBUTES_B.ELEMENT_NAME%TYPE := OKC_API.G_MISS_CHAR,
    data_type                      OKC_ACTION_ATTRIBUTES_B.DATA_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    list_yn                        OKC_ACTION_ATTRIBUTES_B.LIST_YN%TYPE := OKC_API.G_MISS_CHAR,
    visible_yn                     OKC_ACTION_ATTRIBUTES_B.VISIBLE_YN%TYPE := OKC_API.G_MISS_CHAR,
    date_of_interest_yn            OKC_ACTION_ATTRIBUTES_B.DATE_OF_INTEREST_YN%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_ACTION_ATTRIBUTES_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_ACTION_ATTRIBUTES_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    format_mask                    OKC_ACTION_ATTRIBUTES_B.FORMAT_MASK%TYPE := OKC_API.G_MISS_CHAR,
    minimum_value                  OKC_ACTION_ATTRIBUTES_B.MINIMUM_VALUE%TYPE := OKC_API.G_MISS_CHAR,
    maximum_value                  OKC_ACTION_ATTRIBUTES_B.MAXIMUM_VALUE%TYPE := OKC_API.G_MISS_CHAR,
    JTOT_OBJECT_CODE               OKC_ACTION_ATTRIBUTES_B.JTOT_OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    NAME_COLUMN                    OKC_ACTION_ATTRIBUTES_B.NAME_COLUMN%TYPE := OKC_API.G_MISS_CHAR,
    DESCRIPTION_COLUMN             OKC_ACTION_ATTRIBUTES_B.DESCRIPTION_COLUMN%TYPE := OKC_API.G_MISS_CHAR,
    source_doc_number_yn           OKC_ACTION_ATTRIBUTES_B.source_doc_number_yn%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    application_id                 NUMBER := OKC_API.G_MISS_NUM,
    seeded_flag                    OKC_ACTION_ATTRIBUTES_B.SEEDED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_ACTION_ATTRIBUTES_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_aae_rec                          aae_rec_type;
  TYPE aae_tbl_type IS TABLE OF aae_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OkcActionAttributesTlRecType IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKC_ACTION_ATTRIBUTES_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKC_ACTION_ATTRIBUTES_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKC_ACTION_ATTRIBUTES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_ACTION_ATTRIBUTES_TL.NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_ACTION_ATTRIBUTES_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_ACTION_ATTRIBUTES_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_ACTION_ATTRIBUTES_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOkcActionAttributesTlRec           OkcActionAttributesTlRecType;
  TYPE OkcActionAttributesTlTblType IS TABLE OF OkcActionAttributesTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE aaev_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    aal_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_ACTION_ATTRIBUTES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    acn_id                         NUMBER := OKC_API.G_MISS_NUM,
    element_name                   OKC_ACTION_ATTRIBUTES_V.ELEMENT_NAME%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_ACTION_ATTRIBUTES_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_ACTION_ATTRIBUTES_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    data_type                      OKC_ACTION_ATTRIBUTES_V.DATA_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    list_yn                        OKC_ACTION_ATTRIBUTES_V.LIST_YN%TYPE := OKC_API.G_MISS_CHAR,
    visible_yn                     OKC_ACTION_ATTRIBUTES_V.VISIBLE_YN%TYPE := OKC_API.G_MISS_CHAR,
    date_of_interest_yn            OKC_ACTION_ATTRIBUTES_V.DATE_OF_INTEREST_YN%TYPE := OKC_API.G_MISS_CHAR,
    format_mask                    OKC_ACTION_ATTRIBUTES_V.FORMAT_MASK%TYPE := OKC_API.G_MISS_CHAR,
    minimum_value                  OKC_ACTION_ATTRIBUTES_V.MINIMUM_VALUE%TYPE := OKC_API.G_MISS_CHAR,
    maximum_value                  OKC_ACTION_ATTRIBUTES_V.MAXIMUM_VALUE%TYPE := OKC_API.G_MISS_CHAR,
    JTOT_OBJECT_CODE               OKC_ACTION_ATTRIBUTES_V.JTOT_OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    NAME_COLUMN                    OKC_ACTION_ATTRIBUTES_V.NAME_COLUMN%TYPE := OKC_API.G_MISS_CHAR,
    DESCRIPTION_COLUMN             OKC_ACTION_ATTRIBUTES_V.DESCRIPTION_COLUMN%TYPE := OKC_API.G_MISS_CHAR,
    source_doc_number_yn           OKC_ACTION_ATTRIBUTES_V.source_doc_number_yn%TYPE := OKC_API.G_MISS_CHAR,
    application_id                 NUMBER := OKC_API.G_MISS_NUM,
    seeded_flag                    OKC_ACTION_ATTRIBUTES_V.SEEDED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_ACTION_ATTRIBUTES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_ACTION_ATTRIBUTES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_ACTION_ATTRIBUTES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_aaev_rec                         aaev_rec_type;
  TYPE aaev_tbl_type IS TABLE OF aaev_rec_type
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
  G_COL_NAME_TOKEN1		CONSTANT VARCHAR2(30) := 'COL_NAME1';
  G_COL_NAME_TOKEN2		CONSTANT VARCHAR2(30) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKC_SQLerrm';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKC_SQLcode';
  G_UPPERCASE_REQUIRED	CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
  --G_UNQS	CONSTANT VARCHAR2(200) := 'OKC_VALUES_NOT_UNIQUE';
  G_UNQS	CONSTANT VARCHAR2(200) := 'OKC_ACN_ELEMENT_NOT_UNIQUE';
  G_ONE_DOI	CONSTANT VARCHAR2(200) := 'OKC_ONE_DOI';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_AAE_PVT';
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
    p_aaev_rec                     IN aaev_rec_type,
    x_aaev_rec                     OUT NOCOPY aaev_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type,
    x_aaev_tbl                     OUT NOCOPY aaev_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type,
    x_aaev_rec                     OUT NOCOPY aaev_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type,
    x_aaev_tbl                     OUT NOCOPY aaev_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_rec                     IN aaev_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aaev_tbl                     IN aaev_tbl_type);

END OKC_AAE_PVT;

 

/
