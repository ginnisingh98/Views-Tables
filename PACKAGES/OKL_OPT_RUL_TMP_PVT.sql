--------------------------------------------------------
--  DDL for Package OKL_OPT_RUL_TMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OPT_RUL_TMP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRRTMS.pls 115.1 2002/02/25 17:08:32 pkm ship        $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
/*
  TYPE rul_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    rgp_id                         NUMBER := Okc_Api.G_MISS_NUM,
    object1_id1                    OKC_RULES_B.OBJECT1_ID1%TYPE := Okc_Api.G_MISS_CHAR,
    object2_id1                    OKC_RULES_B.OBJECT2_ID1%TYPE := Okc_Api.G_MISS_CHAR,
    object3_id1                    OKC_RULES_B.OBJECT3_ID1%TYPE := Okc_Api.G_MISS_CHAR,
    object1_id2                    OKC_RULES_B.OBJECT1_ID2%TYPE := Okc_Api.G_MISS_CHAR,
    object2_id2                    OKC_RULES_B.OBJECT2_ID2%TYPE := Okc_Api.G_MISS_CHAR,
    object3_id2                    OKC_RULES_B.OBJECT3_ID2%TYPE := Okc_Api.G_MISS_CHAR,
    jtot_object1_code              OKC_RULES_B.JTOT_OBJECT1_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    jtot_object2_code              OKC_RULES_B.JTOT_OBJECT2_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    jtot_object3_code              OKC_RULES_B.JTOT_OBJECT3_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    dnz_chr_id                     NUMBER := Okc_Api.G_MISS_NUM,
    std_template_yn                OKC_RULES_B.STD_TEMPLATE_YN%TYPE := Okc_Api.G_MISS_CHAR,
    warn_yn                        OKC_RULES_B.WARN_YN%TYPE := Okc_Api.G_MISS_CHAR,
    priority                       NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKC_RULES_B.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKC_RULES_B.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM,
    attribute_category             OKC_RULES_B.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKC_RULES_B.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKC_RULES_B.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKC_RULES_B.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKC_RULES_B.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKC_RULES_B.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKC_RULES_B.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKC_RULES_B.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKC_RULES_B.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKC_RULES_B.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKC_RULES_B.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKC_RULES_B.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKC_RULES_B.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKC_RULES_B.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKC_RULES_B.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKC_RULES_B.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information_category      OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information1              OKC_RULES_B.RULE_INFORMATION1%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information2              OKC_RULES_B.RULE_INFORMATION2%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information3              OKC_RULES_B.RULE_INFORMATION3%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information4              OKC_RULES_B.RULE_INFORMATION4%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information5              OKC_RULES_B.RULE_INFORMATION5%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information6              OKC_RULES_B.RULE_INFORMATION6%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information7              OKC_RULES_B.RULE_INFORMATION7%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information8              OKC_RULES_B.RULE_INFORMATION8%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information9              OKC_RULES_B.RULE_INFORMATION9%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information10             OKC_RULES_B.RULE_INFORMATION10%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information11             OKC_RULES_B.RULE_INFORMATION11%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information12             OKC_RULES_B.RULE_INFORMATION12%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information13             OKC_RULES_B.RULE_INFORMATION13%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information14             OKC_RULES_B.RULE_INFORMATION14%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information15             OKC_RULES_B.RULE_INFORMATION15%TYPE := Okc_Api.G_MISS_CHAR,
    template_yn                    OKC_RULES_B.TEMPLATE_YN%TYPE := Okc_Api.G_MISS_CHAR,
    ans_set_jtot_object_code       OKC_RULES_B.ans_set_jtot_object_code%TYPE := Okc_Api.G_MISS_CHAR,
    ans_set_jtot_object_id1            OKC_RULES_B.ans_set_jtot_object_id1%TYPE := Okc_Api.G_MISS_CHAR,
    ans_set_jtot_object_id2            OKC_RULES_B.ans_set_jtot_object_id2%TYPE := Okc_Api.G_MISS_CHAR,
    display_sequence               NUMBER:= Okc_Api.G_MISS_NUM
);
  g_miss_rul_rec                          rul_rec_type;
  TYPE rul_tbl_type IS TABLE OF rul_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okc_rules_tl_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    LANGUAGE                       OKC_RULES_TL.LANGUAGE%TYPE := Okc_Api.G_MISS_CHAR,
    source_lang                    OKC_RULES_TL.SOURCE_LANG%TYPE := Okc_Api.G_MISS_CHAR,
    sfwt_flag                      OKC_RULES_TL.SFWT_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    comments                       OKC_RULES_TL.COMMENTS%TYPE := Okc_Api.G_MISS_CHAR,
    text                           OKC_RULES_TL.TEXT%TYPE := NULL,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKC_RULES_TL.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKC_RULES_TL.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_okc_rules_tl_rec                 okc_rules_tl_rec_type;
  TYPE okc_rules_tl_tbl_type IS TABLE OF okc_rules_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE rulv_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    sfwt_flag                      OKC_RULES_V.SFWT_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    object1_id1                    OKC_RULES_V.OBJECT1_ID1%TYPE := Okc_Api.G_MISS_CHAR,
    object2_id1                    OKC_RULES_V.OBJECT2_ID1%TYPE := Okc_Api.G_MISS_CHAR,
    object3_id1                    OKC_RULES_V.OBJECT3_ID1%TYPE := Okc_Api.G_MISS_CHAR,
    object1_id2                    OKC_RULES_V.OBJECT1_ID2%TYPE := Okc_Api.G_MISS_CHAR,
    object2_id2                    OKC_RULES_V.OBJECT2_ID2%TYPE := Okc_Api.G_MISS_CHAR,
    object3_id2                    OKC_RULES_V.OBJECT3_ID2%TYPE := Okc_Api.G_MISS_CHAR,
    jtot_object1_code              OKC_RULES_V.JTOT_OBJECT1_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    jtot_object2_code              OKC_RULES_V.JTOT_OBJECT2_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    jtot_object3_code              OKC_RULES_V.JTOT_OBJECT3_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    dnz_chr_id                     NUMBER := Okc_Api.G_MISS_NUM,
    rgp_id                         NUMBER := Okc_Api.G_MISS_NUM,
    priority                       NUMBER := Okc_Api.G_MISS_NUM,
    std_template_yn                OKC_RULES_V.STD_TEMPLATE_YN%TYPE := Okc_Api.G_MISS_CHAR,
    comments                       OKC_RULES_V.COMMENTS%TYPE := Okc_Api.G_MISS_CHAR,
    warn_yn                        OKC_RULES_V.WARN_YN%TYPE := Okc_Api.G_MISS_CHAR,
    attribute_category             OKC_RULES_V.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKC_RULES_V.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKC_RULES_V.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKC_RULES_V.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKC_RULES_V.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKC_RULES_V.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKC_RULES_V.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKC_RULES_V.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKC_RULES_V.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKC_RULES_V.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKC_RULES_V.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKC_RULES_V.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKC_RULES_V.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKC_RULES_V.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKC_RULES_V.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKC_RULES_V.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKC_RULES_V.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKC_RULES_V.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM,
    text                           OKC_RULES_V.TEXT%TYPE := NULL,
    rule_information_category      OKC_RULES_V.RULE_INFORMATION_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information1              OKC_RULES_V.RULE_INFORMATION1%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information2              OKC_RULES_V.RULE_INFORMATION2%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information3              OKC_RULES_V.RULE_INFORMATION3%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information4              OKC_RULES_V.RULE_INFORMATION4%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information5              OKC_RULES_V.RULE_INFORMATION5%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information6              OKC_RULES_V.RULE_INFORMATION6%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information7              OKC_RULES_V.RULE_INFORMATION7%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information8              OKC_RULES_V.RULE_INFORMATION8%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information9              OKC_RULES_V.RULE_INFORMATION9%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information10             OKC_RULES_V.RULE_INFORMATION10%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information11             OKC_RULES_V.RULE_INFORMATION11%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information12             OKC_RULES_V.RULE_INFORMATION12%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information13             OKC_RULES_V.RULE_INFORMATION13%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information14             OKC_RULES_V.RULE_INFORMATION14%TYPE := Okc_Api.G_MISS_CHAR,
    rule_information15             OKC_RULES_V.RULE_INFORMATION15%TYPE := Okc_Api.G_MISS_CHAR,
    template_yn                    OKC_RULES_B.TEMPLATE_YN%TYPE := Okc_Api.G_MISS_CHAR,
    ans_set_jtot_object_code       OKC_RULES_B.ans_set_jtot_object_code%TYPE := Okc_Api.G_MISS_CHAR,
    ans_set_jtot_object_id1            OKC_RULES_B.ans_set_jtot_object_id1%TYPE := Okc_Api.G_MISS_CHAR,
    ans_set_jtot_object_id2            OKC_RULES_B.ans_set_jtot_object_id2%TYPE := Okc_Api.G_MISS_CHAR,
    display_sequence               NUMBER:= Okc_Api.G_MISS_NUM
);
  g_miss_rulv_rec                         rulv_rec_type;
  TYPE rulv_tbl_type IS TABLE OF rulv_rec_type
        INDEX BY BINARY_INTEGER;
*/

  SUBTYPE ovtv_rec_type IS Okl_Ovt_Pvt.ovtv_rec_type;
  SUBTYPE rgrv_rec_type IS Okl_Rgrp_Rules_Process_Pvt.rgr_rec_type;
  SUBTYPE rgrv_tbl_type IS Okl_Rgrp_Rules_Process_Pvt.rgr_tbl_type;

  SUBTYPE rulv_rec_type IS Okc_Rul_Pvt.rulv_rec_type;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okc_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okc_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_CHILD_TABLE_TOKEN;

  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_TABLE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_TABLE_NAME';
  G_SQLERRM_TOKEN		    CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN		    CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_UNQS	                CONSTANT VARCHAR2(200) := 'OKL_NOT_UNIQUE';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  G_ITEM_NOT_FOUND_ERROR	   EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_OVD_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
  G_LOOKUP_TYPE			CONSTANT VARCHAR2(50)  := 'OKL_OPTION_VALUE_RULE_FLAG';
  G_INTENT_TYPE         CONSTANT VARCHAR2(50)  := 'OKL_INTENT_TYPE';
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovd_id                       IN NUMBER,
    p_rgrv_rec                     IN rgrv_rec_type,
    x_rgrv_rec                     OUT NOCOPY rgrv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovd_id                       IN NUMBER,
    p_rgrv_tbl                     IN rgrv_tbl_type,
    x_rgrv_tbl                     OUT NOCOPY rgrv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_rec                     IN rgrv_rec_type,
    x_rgrv_rec                     OUT NOCOPY rgrv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_tbl                     IN rgrv_tbl_type,
    x_rgrv_tbl                     OUT NOCOPY rgrv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_rec                     IN rgrv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgrv_tbl                     IN rgrv_tbl_type);

END Okl_Opt_Rul_Tmp_Pvt;

 

/
