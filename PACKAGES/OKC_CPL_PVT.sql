--------------------------------------------------------
--  DDL for Package OKC_CPL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CPL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSCPLS.pls 120.2 2005/08/03 05:39:49 parkumar noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE cpl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    cpl_id                         NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    rle_code                       OKC_K_PARTY_ROLES_B.RLE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    object1_id1                    OKC_K_PARTY_ROLES_B.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKC_K_PARTY_ROLES_B.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object1_code              OKC_K_PARTY_ROLES_B.jtot_object1_code%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_PARTY_ROLES_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_PARTY_ROLES_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    code                           OKC_K_PARTY_ROLES_B.CODE%TYPE := OKC_API.G_MISS_CHAR,
    facility                       OKC_K_PARTY_ROLES_B.FACILITY%TYPE := OKC_API.G_MISS_CHAR,
    minority_group_lookup_code     OKC_K_PARTY_ROLES_B.MINORITY_GROUP_LOOKUP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    small_business_flag            OKC_K_PARTY_ROLES_B.SMALL_BUSINESS_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    women_owned_flag               OKC_K_PARTY_ROLES_B.WOMEN_OWNED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    primary_yn                     OKC_K_PARTY_ROLES_B.PRIMARY_YN%TYPE := OKC_API.G_MISS_CHAR,
    cust_acct_id                   NUMBER := OKC_API.G_MISS_NUM,
    bill_to_site_use_id            NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKC_K_PARTY_ROLES_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_K_PARTY_ROLES_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_K_PARTY_ROLES_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_K_PARTY_ROLES_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_K_PARTY_ROLES_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_K_PARTY_ROLES_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_K_PARTY_ROLES_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_K_PARTY_ROLES_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_K_PARTY_ROLES_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_K_PARTY_ROLES_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_K_PARTY_ROLES_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_K_PARTY_ROLES_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_K_PARTY_ROLES_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_K_PARTY_ROLES_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_K_PARTY_ROLES_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_K_PARTY_ROLES_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
-- R12 Data Model Changes 4485150 Start
    orig_system_id1                NUMBER := OKC_API.G_MISS_NUM,
    orig_system_reference1         OKC_K_PARTY_ROLES_B.ORIG_SYSTEM_REFERENCE1%TYPE := OKC_API.G_MISS_CHAR,
    orig_system_source_code        OKC_K_PARTY_ROLES_B.ORIG_SYSTEM_SOURCE_CODE%TYPE := OKC_API.G_MISS_CHAR
-- R12 Data Model Changes 4485150 End
);
  g_miss_cpl_rec                          cpl_rec_type;
  TYPE cpl_tbl_type IS TABLE OF cpl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okc_k_party_roles_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKC_K_PARTY_ROLES_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKC_K_PARTY_ROLES_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKC_K_PARTY_ROLES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_PARTY_ROLES_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_PARTY_ROLES_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    cognomen                       OKC_K_PARTY_ROLES_TL.COGNOMEN%TYPE := OKC_API.G_MISS_CHAR,
    alias                          OKC_K_PARTY_ROLES_TL.ALIAS%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOkcKPartyRolesTlRec                okc_k_party_roles_tl_rec_type;
  TYPE okc_k_party_roles_tl_tbl_type IS TABLE OF okc_k_party_roles_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE cplv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_K_PARTY_ROLES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    cpl_id                         NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    rle_code                       OKC_K_PARTY_ROLES_V.RLE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    object1_id1                    OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object1_code              OKC_K_PARTY_ROLES_V.jtot_object1_code%TYPE := OKC_API.G_MISS_CHAR,
    cognomen                       OKC_K_PARTY_ROLES_V.COGNOMEN%TYPE := OKC_API.G_MISS_CHAR,
    code                           OKC_K_PARTY_ROLES_V.CODE%TYPE := OKC_API.G_MISS_CHAR,
    facility                       OKC_K_PARTY_ROLES_V.FACILITY%TYPE := OKC_API.G_MISS_CHAR,
    minority_group_lookup_code     OKC_K_PARTY_ROLES_V.MINORITY_GROUP_LOOKUP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    small_business_flag            OKC_K_PARTY_ROLES_V.SMALL_BUSINESS_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    women_owned_flag               OKC_K_PARTY_ROLES_V.WOMEN_OWNED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    alias                          OKC_K_PARTY_ROLES_V.ALIAS%TYPE := OKC_API.G_MISS_CHAR,
    primary_yn                     OKC_K_PARTY_ROLES_V.PRIMARY_YN%TYPE := OKC_API.G_MISS_CHAR,
    --new columns to replace rules
    cust_acct_id                   NUMBER := OKC_API.G_MISS_NUM,
    bill_to_site_use_id            NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKC_K_PARTY_ROLES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_K_PARTY_ROLES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_K_PARTY_ROLES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_K_PARTY_ROLES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_K_PARTY_ROLES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_K_PARTY_ROLES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_K_PARTY_ROLES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_K_PARTY_ROLES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_K_PARTY_ROLES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_K_PARTY_ROLES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_K_PARTY_ROLES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_K_PARTY_ROLES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_K_PARTY_ROLES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_K_PARTY_ROLES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_K_PARTY_ROLES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_K_PARTY_ROLES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_PARTY_ROLES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_PARTY_ROLES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_cplv_rec                         cplv_rec_type;
  TYPE cplv_tbl_type IS TABLE OF cplv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CPL_PVT';
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
    p_cplv_rec                     IN cplv_rec_type,
    x_cplv_rec                     OUT NOCOPY cplv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN cplv_tbl_type,
    x_cplv_tbl                     OUT NOCOPY cplv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN cplv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN cplv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN cplv_rec_type,
    x_cplv_rec                     OUT NOCOPY cplv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN cplv_tbl_type,
    x_cplv_tbl                     OUT NOCOPY cplv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN cplv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN cplv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN cplv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN cplv_tbl_type);

   PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2, p_cplv_tbl cplv_tbl_type);

  FUNCTION create_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

  FUNCTION restore_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

END OKC_CPL_PVT;

 

/
