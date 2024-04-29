--------------------------------------------------------
--  DDL for Package OKL_VP_CAT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_CAT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSCARS.pls 120.1 2005/10/30 04:40:29 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE cat_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    sav_sae_id                     NUMBER := OKC_API.G_MISS_NUM,
    sbt_code                       OKC_K_ARTICLES_B.SBT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    cat_type                       OKC_K_ARTICLES_B.CAT_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    cat_id                         NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_ARTICLES_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_ARTICLES_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    fulltext_yn                    OKC_K_ARTICLES_B.FULLTEXT_YN%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKC_K_ARTICLES_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_K_ARTICLES_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_K_ARTICLES_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_K_ARTICLES_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_K_ARTICLES_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_K_ARTICLES_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_K_ARTICLES_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_K_ARTICLES_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_K_ARTICLES_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_K_ARTICLES_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_K_ARTICLES_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_K_ARTICLES_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_K_ARTICLES_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_K_ARTICLES_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_K_ARTICLES_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_K_ARTICLES_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    security_group_id              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_cat_rec                          cat_rec_type;
  TYPE cat_tbl_type IS TABLE OF cat_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okc_k_articles_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKC_K_ARTICLES_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKC_K_ARTICLES_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKC_K_ARTICLES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    comments                       OKC_K_ARTICLES_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    variation_description          OKC_K_ARTICLES_TL.VARIATION_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_K_ARTICLES_TL.NAME%TYPE := OKC_API.G_MISS_CHAR,
-- text ... commented out to treat empty CLOB as an of empty content:
-- if need to nullify it then nullify contents, not the pointer
--    text                           OKC_K_ARTICLES_TL.TEXT%TYPE := OKC_API.G_MISS_CHAR,
--+Hand code start
--    text                           OKC_K_ARTICLES_TL.TEXT%TYPE,
--+Hand code end
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_ARTICLES_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_ARTICLES_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    security_group_id              NUMBER := OKC_API.G_MISS_NUM,
    sav_sav_release                OKC_K_ARTICLES_TL.SAV_SAV_RELEASE%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_okc_k_articles_tl_rec            okc_k_articles_tl_rec_type;
  TYPE okc_k_articles_tl_tbl_type IS TABLE OF okc_k_articles_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE catv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    cat_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_K_ARTICLES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    sav_sae_id                     NUMBER := OKC_API.G_MISS_NUM,
    sav_sav_release                OKC_K_ARTICLES_V.SAV_SAV_RELEASE%TYPE := OKC_API.G_MISS_CHAR,
    sbt_code                       OKC_K_ARTICLES_V.SBT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    comments                       OKC_K_ARTICLES_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    fulltext_yn                    OKC_K_ARTICLES_V.FULLTEXT_YN%TYPE := OKC_API.G_MISS_CHAR,
    variation_description          OKC_K_ARTICLES_V.VARIATION_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_K_ARTICLES_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
-- text ... commented out to treat empty CLOB as an of empty content:
-- if need to nullify it then nullify contents, not the pointer
--  text                           OKC_K_ARTICLES_V.TEXT%TYPE := OKC_API.G_MISS_CHAR,
--+Hand code start
--    text                           OKC_K_ARTICLES_V.TEXT%TYPE,
--+Hand code end
    attribute_category             OKC_K_ARTICLES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_K_ARTICLES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_K_ARTICLES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_K_ARTICLES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_K_ARTICLES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_K_ARTICLES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_K_ARTICLES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_K_ARTICLES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_K_ARTICLES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_K_ARTICLES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_K_ARTICLES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_K_ARTICLES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_K_ARTICLES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_K_ARTICLES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_K_ARTICLES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_K_ARTICLES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    cat_type                       OKC_K_ARTICLES_V.CAT_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_ARTICLES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_ARTICLES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_catv_rec                         catv_rec_type;
  TYPE catv_tbl_type IS TABLE OF catv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CAT_PVT';
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
    p_catv_rec                     IN catv_rec_type,
    x_catv_rec                     OUT NOCOPY catv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type,
    x_catv_tbl                     OUT NOCOPY catv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type,
    x_catv_rec                     OUT NOCOPY catv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type,
    x_catv_tbl                     OUT NOCOPY catv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN catv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_tbl                     IN catv_tbl_type);

  PROCEDURE INSERT_ROW_UPG(p_catv_tbl catv_tbl_type);

  FUNCTION create_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

  FUNCTION restore_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

END; -- Package Specification OKL_VP_CAT_PVT

 

/
