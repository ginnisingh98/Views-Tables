--------------------------------------------------------
--  DDL for Package OKL_OKC_MIGRATION_A_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OKC_MIGRATION_A_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLROMAS.pls 120.1 2005/08/03 19:22:58 manumanu noship $ */
G_API_TYPE        VARCHAR2(10) := '_PVT';
--------------------------------------------------------------------------------------------
--ARTICLES
--------------------------------------------------------------------------------------------
  TYPE catv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    cat_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_K_ARTICLES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    sav_sae_id                     NUMBER := OKC_API.G_MISS_NUM,
    sav_sav_release                OKC_K_ARTICLES_B.SAV_SAV_RELEASE%TYPE := OKC_API.G_MISS_CHAR,
    sbt_code                       OKC_K_ARTICLES_B.SBT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    comments                       OKC_K_ARTICLES_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    fulltext_yn                    OKC_K_ARTICLES_B.FULLTEXT_YN%TYPE := OKC_API.G_MISS_CHAR,
    variation_description          OKC_K_ARTICLES_TL.VARIATION_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_K_ARTICLES_TL.NAME%TYPE := OKC_API.G_MISS_CHAR,
-- text ... commented out to treat empty CLOB as an of empty content:
-- if need to nullify it then nullify contents, not the pointer
--  text                           OKC_K_ARTICLES_TL.TEXT%TYPE := OKC_API.G_MISS_CHAR,
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
    cat_type                       OKC_K_ARTICLES_B.CAT_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_ARTICLES_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_ARTICLES_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_catv_rec                         catv_rec_type;
  TYPE catv_tbl_type IS TABLE OF catv_rec_type
        INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------------------------
--RULE GROUPS
--------------------------------------------------------------------------------------------
  TYPE rgpv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_RULE_GROUPS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    rgd_code                       OKC_RULE_GROUPS_B.RGD_CODE%TYPE := OKC_API.G_MISS_CHAR,
    sat_code                       OKC_RULE_GROUPS_B.SAT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    rgp_type                       OKC_RULE_GROUPS_B.RGP_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    parent_rgp_id                  NUMBER := OKC_API.G_MISS_NUM,
    comments                       OKC_RULE_GROUPS_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_RULE_GROUPS_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_RULE_GROUPS_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_RULE_GROUPS_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_RULE_GROUPS_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_RULE_GROUPS_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_RULE_GROUPS_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_RULE_GROUPS_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_RULE_GROUPS_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_RULE_GROUPS_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_RULE_GROUPS_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_RULE_GROUPS_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_RULE_GROUPS_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_RULE_GROUPS_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_RULE_GROUPS_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_RULE_GROUPS_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_RULE_GROUPS_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_RULE_GROUPS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_RULE_GROUPS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
    TYPE rgpv_tbl_type IS TABLE OF rgpv_rec_type
        INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------------------------
--QA CHECK
--------------------------------------------------------------------------------------------
  TYPE qa_msg_rec_type IS RECORD (
        severity                OKC_QA_LIST_PROCESSES_V.SEVERITY%TYPE,
        name                    OKC_PROCESS_DEFS_V.NAME%TYPE,
        description             OKC_PROCESS_DEFS_V.DESCRIPTION%TYPE,
        package_name            OKC_PROCESS_DEFS_V.PACKAGE_NAME%TYPE,
        procedure_name          OKC_PROCESS_DEFS_V.PROCEDURE_NAME%TYPE,
  	error_status		VARCHAR2(1),
	data			VARCHAR2(2000));

  TYPE qa_msg_tbl_type IS TABLE OF qa_msg_rec_type
  	INDEX BY BINARY_INTEGER;


  subtype msg_tbl_type is qa_msg_tbl_type;
--------------------------------------------------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN  catv_rec_type,
    x_catv_rec                     OUT NOCOPY  catv_rec_type);

   PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN  catv_rec_type,
    x_catv_rec                     OUT NOCOPY  catv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN  catv_rec_type);

----------------------------------------------------------------------------------
-- INSERT for OKC_RGP_PVT
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY  rgpv_rec_type);
-- UPDATE for OKC_RGP_PVT
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY  rgpv_rec_type);
-- DELETE for OKC_RGP_PVT
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type);
----------------------------------------------------------------------------------
-- QA CHECK LIST
  PROCEDURE execute_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    x_msg_tbl                      OUT NOCOPY msg_tbl_type);

FUNCTION Update_Allowed(p_chr_id IN NUMBER) RETURN VARCHAR2;

END; -- Package Specification OKL_OKC_MIGRATION_A_PVT

 

/
