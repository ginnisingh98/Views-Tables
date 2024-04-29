--------------------------------------------------------
--  DDL for Package OKC_CRT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CRT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSCRTS.pls 120.0 2005/05/25 18:11:35 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE crt_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    crs_code                       OKC_CHANGE_REQUESTS_B.CRS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    user_id                        NUMBER := OKC_API.G_MISS_NUM,
    datetime_request               OKC_CHANGE_REQUESTS_B.DATETIME_REQUEST%TYPE := OKC_API.G_MISS_DATE,
    crt_type                       OKC_CHANGE_REQUESTS_B.CRT_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_CHANGE_REQUESTS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_CHANGE_REQUESTS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    datetime_effective             OKC_CHANGE_REQUESTS_B.DATETIME_EFFECTIVE%TYPE := OKC_API.G_MISS_DATE,
    extended_yn                    OKC_CHANGE_REQUESTS_B.EXTENDED_YN%TYPE := OKC_API.G_MISS_CHAR,
    authority                      OKC_CHANGE_REQUESTS_B.AUTHORITY%TYPE := OKC_API.G_MISS_CHAR,
    signature_required_yn          OKC_CHANGE_REQUESTS_B.SIGNATURE_REQUIRED_YN%TYPE := OKC_API.G_MISS_CHAR,
    datetime_approved              OKC_CHANGE_REQUESTS_B.DATETIME_APPROVED%TYPE := OKC_API.G_MISS_DATE,
    datetime_rejected              OKC_CHANGE_REQUESTS_B.DATETIME_REJECTED%TYPE := OKC_API.G_MISS_DATE,
    datetime_ineffective           OKC_CHANGE_REQUESTS_B.DATETIME_INEFFECTIVE%TYPE := OKC_API.G_MISS_DATE,
    version_contract               OKC_CHANGE_REQUESTS_B.VERSION_CONTRACT%TYPE := OKC_API.G_MISS_CHAR,
    applied_contract_version       OKC_CHANGE_REQUESTS_B.APPLIED_CONTRACT_VERSION%TYPE := OKC_API.G_MISS_CHAR,
    datetime_applied               OKC_CHANGE_REQUESTS_B.DATETIME_APPLIED%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKC_CHANGE_REQUESTS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_CHANGE_REQUESTS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_CHANGE_REQUESTS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_CHANGE_REQUESTS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_CHANGE_REQUESTS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_CHANGE_REQUESTS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_CHANGE_REQUESTS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_CHANGE_REQUESTS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_CHANGE_REQUESTS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_CHANGE_REQUESTS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_CHANGE_REQUESTS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_CHANGE_REQUESTS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_CHANGE_REQUESTS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_CHANGE_REQUESTS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_CHANGE_REQUESTS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_CHANGE_REQUESTS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_crt_rec                          crt_rec_type;
  TYPE crt_tbl_type IS TABLE OF crt_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OkcChangeRequestsTlRecType IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKC_CHANGE_REQUESTS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKC_CHANGE_REQUESTS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKC_CHANGE_REQUESTS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_CHANGE_REQUESTS_TL.NAME%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_CHANGE_REQUESTS_TL.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_CHANGE_REQUESTS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_CHANGE_REQUESTS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOkcChangeRequestsTlRec             OkcChangeRequestsTlRecType;
  TYPE OkcChangeRequestsTlTblType IS TABLE OF OkcChangeRequestsTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE crtv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_CHANGE_REQUESTS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    crs_code                       OKC_CHANGE_REQUESTS_V.CRS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    user_id                        NUMBER := OKC_API.G_MISS_NUM,
    name                           OKC_CHANGE_REQUESTS_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    datetime_request               OKC_CHANGE_REQUESTS_V.DATETIME_REQUEST%TYPE := OKC_API.G_MISS_DATE,
    short_description              OKC_CHANGE_REQUESTS_V.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    extended_yn                    OKC_CHANGE_REQUESTS_V.EXTENDED_YN%TYPE := OKC_API.G_MISS_CHAR,
    authority                      OKC_CHANGE_REQUESTS_V.AUTHORITY%TYPE := OKC_API.G_MISS_CHAR,
    signature_required_yn          OKC_CHANGE_REQUESTS_V.SIGNATURE_REQUIRED_YN%TYPE := OKC_API.G_MISS_CHAR,
    datetime_approved              OKC_CHANGE_REQUESTS_V.DATETIME_APPROVED%TYPE := OKC_API.G_MISS_DATE,
    datetime_rejected              OKC_CHANGE_REQUESTS_V.DATETIME_REJECTED%TYPE := OKC_API.G_MISS_DATE,
    datetime_effective             OKC_CHANGE_REQUESTS_V.DATETIME_EFFECTIVE%TYPE := OKC_API.G_MISS_DATE,
    datetime_ineffective           OKC_CHANGE_REQUESTS_V.DATETIME_INEFFECTIVE%TYPE := OKC_API.G_MISS_DATE,
    datetime_applied               OKC_CHANGE_REQUESTS_V.DATETIME_APPLIED%TYPE := OKC_API.G_MISS_DATE,
    version_contract               OKC_CHANGE_REQUESTS_V.VERSION_CONTRACT%TYPE := OKC_API.G_MISS_CHAR,
    applied_contract_version       OKC_CHANGE_REQUESTS_V.APPLIED_CONTRACT_VERSION%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_CHANGE_REQUESTS_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_CHANGE_REQUESTS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_CHANGE_REQUESTS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_CHANGE_REQUESTS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_CHANGE_REQUESTS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_CHANGE_REQUESTS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_CHANGE_REQUESTS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_CHANGE_REQUESTS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_CHANGE_REQUESTS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_CHANGE_REQUESTS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_CHANGE_REQUESTS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_CHANGE_REQUESTS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_CHANGE_REQUESTS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_CHANGE_REQUESTS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_CHANGE_REQUESTS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_CHANGE_REQUESTS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    crt_type                       OKC_CHANGE_REQUESTS_V.CRT_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_CHANGE_REQUESTS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_CHANGE_REQUESTS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_crtv_rec                         crtv_rec_type;
  TYPE crtv_tbl_type IS TABLE OF crtv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CRT_PVT';
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
    p_crtv_rec                     IN crtv_rec_type,
    x_crtv_rec                     OUT NOCOPY crtv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_tbl                     IN crtv_tbl_type,
    x_crtv_tbl                     OUT NOCOPY crtv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_rec                     IN crtv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_tbl                     IN crtv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_rec                     IN crtv_rec_type,
    x_crtv_rec                     OUT NOCOPY crtv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_tbl                     IN crtv_tbl_type,
    x_crtv_tbl                     OUT NOCOPY crtv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_rec                     IN crtv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_tbl                     IN crtv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_rec                     IN crtv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crtv_tbl                     IN crtv_tbl_type);

END OKC_CRT_PVT;

 

/
