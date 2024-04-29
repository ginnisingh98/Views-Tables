--------------------------------------------------------
--  DDL for Package OKC_RUL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_RUL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSRULS.pls 120.0 2005/05/25 23:03:31 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE rul_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    rgp_id                         NUMBER := OKC_API.G_MISS_NUM,
    object1_id1                    OKC_RULES_B.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object2_id1                    OKC_RULES_B.OBJECT2_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object3_id1                    OKC_RULES_B.OBJECT3_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKC_RULES_B.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    object2_id2                    OKC_RULES_B.OBJECT2_ID2%TYPE := OKC_API.G_MISS_CHAR,
    object3_id2                    OKC_RULES_B.OBJECT3_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object1_code              OKC_RULES_B.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object2_code              OKC_RULES_B.JTOT_OBJECT2_CODE%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object3_code              OKC_RULES_B.JTOT_OBJECT3_CODE%TYPE := OKC_API.G_MISS_CHAR,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    std_template_yn                OKC_RULES_B.STD_TEMPLATE_YN%TYPE := OKC_API.G_MISS_CHAR,
    warn_yn                        OKC_RULES_B.WARN_YN%TYPE := OKC_API.G_MISS_CHAR,
    priority                       NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_RULES_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_RULES_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKC_RULES_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_RULES_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_RULES_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_RULES_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_RULES_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_RULES_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_RULES_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_RULES_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_RULES_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_RULES_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_RULES_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_RULES_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_RULES_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_RULES_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_RULES_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_RULES_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    rule_information_category      OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    rule_information1              OKC_RULES_B.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
    rule_information2              OKC_RULES_B.RULE_INFORMATION2%TYPE := OKC_API.G_MISS_CHAR,
    rule_information3              OKC_RULES_B.RULE_INFORMATION3%TYPE := OKC_API.G_MISS_CHAR,
    rule_information4              OKC_RULES_B.RULE_INFORMATION4%TYPE := OKC_API.G_MISS_CHAR,
    rule_information5              OKC_RULES_B.RULE_INFORMATION5%TYPE := OKC_API.G_MISS_CHAR,
    rule_information6              OKC_RULES_B.RULE_INFORMATION6%TYPE := OKC_API.G_MISS_CHAR,
    rule_information7              OKC_RULES_B.RULE_INFORMATION7%TYPE := OKC_API.G_MISS_CHAR,
    rule_information8              OKC_RULES_B.RULE_INFORMATION8%TYPE := OKC_API.G_MISS_CHAR,
    rule_information9              OKC_RULES_B.RULE_INFORMATION9%TYPE := OKC_API.G_MISS_CHAR,
    rule_information10             OKC_RULES_B.RULE_INFORMATION10%TYPE := OKC_API.G_MISS_CHAR,
    rule_information11             OKC_RULES_B.RULE_INFORMATION11%TYPE := OKC_API.G_MISS_CHAR,
    rule_information12             OKC_RULES_B.RULE_INFORMATION12%TYPE := OKC_API.G_MISS_CHAR,
    rule_information13             OKC_RULES_B.RULE_INFORMATION13%TYPE := OKC_API.G_MISS_CHAR,
    rule_information14             OKC_RULES_B.RULE_INFORMATION14%TYPE := OKC_API.G_MISS_CHAR,
    rule_information15             OKC_RULES_B.RULE_INFORMATION15%TYPE := OKC_API.G_MISS_CHAR,
    template_yn                    OKC_RULES_B.TEMPLATE_YN%TYPE := OKC_API.G_MISS_CHAR,
    ans_set_jtot_object_code       OKC_RULES_B.ans_set_jtot_object_code%TYPE := OKC_API.G_MISS_CHAR,
    ans_set_jtot_object_id1            OKC_RULES_B.ans_set_jtot_object_id1%TYPE := OKC_API.G_MISS_CHAR,
    ans_set_jtot_object_id2            OKC_RULES_B.ans_set_jtot_object_id2%TYPE := OKC_API.G_MISS_CHAR,
    display_sequence               NUMBER:= OKC_API.G_MISS_NUM,
--Bug 3055393
    comments                       OKC_RULES_B.comments%TYPE := OKC_API.G_MISS_CHAR
);
  g_miss_rul_rec                          rul_rec_type;
  TYPE rul_tbl_type IS TABLE OF rul_rec_type
        INDEX BY BINARY_INTEGER;
/*--Bug 3055393
  TYPE okc_rules_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKC_RULES_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKC_RULES_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKC_RULES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_RULES_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    text                           OKC_RULES_TL.TEXT%TYPE := NULL,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_RULES_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_RULES_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_okc_rules_tl_rec                 okc_rules_tl_rec_type;
  TYPE okc_rules_tl_tbl_type IS TABLE OF okc_rules_tl_rec_type
        INDEX BY BINARY_INTEGER;
*/
  TYPE rulv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
   sfwt_flag                      VARCHAR2(1) := 'N',
    object1_id1                    OKC_RULES_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object2_id1                    OKC_RULES_V.OBJECT2_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object3_id1                    OKC_RULES_V.OBJECT3_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKC_RULES_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    object2_id2                    OKC_RULES_V.OBJECT2_ID2%TYPE := OKC_API.G_MISS_CHAR,
    object3_id2                    OKC_RULES_V.OBJECT3_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object1_code              OKC_RULES_V.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object2_code              OKC_RULES_V.JTOT_OBJECT2_CODE%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object3_code              OKC_RULES_V.JTOT_OBJECT3_CODE%TYPE := OKC_API.G_MISS_CHAR,
    dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM,
    rgp_id                         NUMBER := OKC_API.G_MISS_NUM,
    priority                       NUMBER := OKC_API.G_MISS_NUM,
    std_template_yn                OKC_RULES_V.STD_TEMPLATE_YN%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_RULES_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    warn_yn                        OKC_RULES_V.WARN_YN%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_RULES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_RULES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_RULES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_RULES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_RULES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_RULES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_RULES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_RULES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_RULES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_RULES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_RULES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_RULES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_RULES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_RULES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_RULES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_RULES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_RULES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_RULES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
   text                           VARCHAR2(1) := NULL,
    rule_information_category      OKC_RULES_V.RULE_INFORMATION_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    rule_information1              OKC_RULES_V.RULE_INFORMATION1%TYPE := OKC_API.G_MISS_CHAR,
    rule_information2              OKC_RULES_V.RULE_INFORMATION2%TYPE := OKC_API.G_MISS_CHAR,
    rule_information3              OKC_RULES_V.RULE_INFORMATION3%TYPE := OKC_API.G_MISS_CHAR,
    rule_information4              OKC_RULES_V.RULE_INFORMATION4%TYPE := OKC_API.G_MISS_CHAR,
    rule_information5              OKC_RULES_V.RULE_INFORMATION5%TYPE := OKC_API.G_MISS_CHAR,
    rule_information6              OKC_RULES_V.RULE_INFORMATION6%TYPE := OKC_API.G_MISS_CHAR,
    rule_information7              OKC_RULES_V.RULE_INFORMATION7%TYPE := OKC_API.G_MISS_CHAR,
    rule_information8              OKC_RULES_V.RULE_INFORMATION8%TYPE := OKC_API.G_MISS_CHAR,
    rule_information9              OKC_RULES_V.RULE_INFORMATION9%TYPE := OKC_API.G_MISS_CHAR,
    rule_information10             OKC_RULES_V.RULE_INFORMATION10%TYPE := OKC_API.G_MISS_CHAR,
    rule_information11             OKC_RULES_V.RULE_INFORMATION11%TYPE := OKC_API.G_MISS_CHAR,
    rule_information12             OKC_RULES_V.RULE_INFORMATION12%TYPE := OKC_API.G_MISS_CHAR,
    rule_information13             OKC_RULES_V.RULE_INFORMATION13%TYPE := OKC_API.G_MISS_CHAR,
    rule_information14             OKC_RULES_V.RULE_INFORMATION14%TYPE := OKC_API.G_MISS_CHAR,
    rule_information15             OKC_RULES_V.RULE_INFORMATION15%TYPE := OKC_API.G_MISS_CHAR,
    template_yn                    OKC_RULES_B.TEMPLATE_YN%TYPE := OKC_API.G_MISS_CHAR,
    ans_set_jtot_object_code       OKC_RULES_B.ans_set_jtot_object_code%TYPE := OKC_API.G_MISS_CHAR,
    ans_set_jtot_object_id1            OKC_RULES_B.ans_set_jtot_object_id1%TYPE := OKC_API.G_MISS_CHAR,
    ans_set_jtot_object_id2            OKC_RULES_B.ans_set_jtot_object_id2%TYPE := OKC_API.G_MISS_CHAR,
    display_sequence               NUMBER:= OKC_API.G_MISS_NUM,
    VALIDATE_YN                    VARCHAR2(1) DEFAULT  'Y'
);
  g_miss_rulv_rec                         rulv_rec_type;
  TYPE rulv_tbl_type IS TABLE OF rulv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_RUL_PVT';
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
    p_rulv_rec                     IN rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN rulv_tbl_type,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN rulv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN rulv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN rulv_tbl_type,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN rulv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN rulv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN rulv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN rulv_tbl_type);

  PROCEDURE INSERT_ROW_UPG
		(x_return_status OUT NOCOPY VARCHAR2,p_rulv_tbl rulv_tbl_type);

  FUNCTION create_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

  FUNCTION restore_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

END OKC_RUL_PVT;

 

/
