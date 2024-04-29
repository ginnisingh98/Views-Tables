--------------------------------------------------------
--  DDL for Package OKL_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RULE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRULS.pls 115.8 2004/02/03 18:17:23 avsingh noship $ */

  TYPE rulv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_RULES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
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
    --text                           OKC_RULES_V.TEXT%TYPE := NULL,
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
    display_sequence               NUMBER:= OKC_API.G_MISS_NUM
);

  g_miss_rulv_rec                rulv_rec_type;

  TYPE rulv_tbl_type IS TABLE OF rulv_rec_type INDEX BY BINARY_INTEGER;
  subtype rgpv_rec_type is okl_okc_migration_pvt.rgpv_rec_type;
  subtype rgpv_tbl_type is okl_okc_migration_pvt.rgpv_tbl_type;
  subtype rmpv_rec_type is okl_okc_migration_pvt.rmpv_rec_type;
  subtype rmpv_tbl_type is okl_okc_migration_pvt.rmpv_tbl_type;
--  subtype ctiv_rec_type is OKC_CTI_PVT.ctiv_rec_type;
--  subtype ctiv_tbl_type is OKC_CTI_PVT.ctiv_tbl_type;
--  subtype rilv_rec_type is OKC_RIL_PVT.rilv_rec_type;
--  subtype rilv_tbl_type is OKC_RIL_PVT.rilv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_UPPERCASE_REQUIRED';

  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_RULE_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  g_rulv_rec                    rulv_rec_type;
  g_rgpv_rec                    rgpv_rec_type;
  g_rmpv_rec                    rmpv_rec_type;
  --g_ctiv_rec                    ctiv_rec_type;
  --g_rilv_rec                    rilv_rec_type;


  -- public procedure declarations
  PROCEDURE create_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type,
    p_euro_conv_yn                 IN VARCHAR2);
  PROCEDURE create_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type);
  PROCEDURE create_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type,
    p_euro_conv_yn                 IN VARCHAR2);
  PROCEDURE create_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type);
  PROCEDURE update_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type);

  --Bug# 3388812 : overloaded for LLAP to introduce p_edit_mode
  PROCEDURE update_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type,
    p_edit_mode                    IN  VARCHAR2,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type);

  PROCEDURE update_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type);

 --Bug# 3388812 : overloaded for LLAP to introduce p_edit_mode
 PROCEDURE update_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type,
    p_edit_mode                    IN  VARCHAR2,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type);

  PROCEDURE validate_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type);
  PROCEDURE validate_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type);
  PROCEDURE delete_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type);
  PROCEDURE delete_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type);
  PROCEDURE lock_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type);
  PROCEDURE lock_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type);
  PROCEDURE create_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type);
  PROCEDURE create_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type,
    x_rgpv_tbl                     OUT NOCOPY rgpv_tbl_type);
  PROCEDURE update_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type);
  PROCEDURE update_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type,
    x_rgpv_tbl                     OUT NOCOPY rgpv_tbl_type);
  PROCEDURE delete_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type);
  PROCEDURE delete_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type);
  PROCEDURE lock_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type);
  PROCEDURE lock_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type);
  PROCEDURE validate_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type);
  PROCEDURE validate_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type);
  PROCEDURE create_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type,
    x_rmpv_rec                     OUT NOCOPY rmpv_rec_type);
  PROCEDURE create_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type,
    x_rmpv_tbl                     OUT NOCOPY rmpv_tbl_type);
  PROCEDURE update_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type,
    x_rmpv_rec                     OUT NOCOPY rmpv_rec_type);
  PROCEDURE update_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type,
    x_rmpv_tbl                     OUT NOCOPY rmpv_tbl_type);
  PROCEDURE delete_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type);
  PROCEDURE delete_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type);
  PROCEDURE lock_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type);
  PROCEDURE lock_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type);
  PROCEDURE validate_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type);
  PROCEDURE validate_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type);
/***********commented as OKL do not need to use these************/
/*
  PROCEDURE create_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type,
    x_ctiv_rec                     OUT NOCOPY ctiv_rec_type);
  PROCEDURE create_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type,
    x_ctiv_tbl                     OUT NOCOPY ctiv_tbl_type);
  PROCEDURE update_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type,
    x_ctiv_rec                     OUT NOCOPY ctiv_rec_type);
  PROCEDURE update_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type,
    x_ctiv_tbl                     OUT NOCOPY ctiv_tbl_type);
  PROCEDURE delete_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type);
  PROCEDURE delete_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type);
  PROCEDURE lock_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type);
  PROCEDURE lock_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type);
  PROCEDURE validate_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type);
  PROCEDURE validate_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type);
  PROCEDURE create_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type,
    x_rilv_rec                     OUT NOCOPY rilv_rec_type);
  PROCEDURE create_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type,
    x_rilv_tbl                     OUT NOCOPY rilv_tbl_type);
  PROCEDURE update_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type,
    x_rilv_rec                     OUT NOCOPY rilv_rec_type);
  PROCEDURE update_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type,
    x_rilv_tbl                     OUT NOCOPY rilv_tbl_type);
  PROCEDURE delete_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type);
  PROCEDURE delete_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type);
  PROCEDURE lock_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type);
  PROCEDURE lock_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type);
  PROCEDURE validate_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type);
  PROCEDURE validate_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type);
*/
  PROCEDURE add_language;
  function rule_meaning(p_rle_code varchar2) return varchar2;
  function get_new_code
    (p_rgd_code in varchar2, p_rdf_code in varchar2, p_intent varchar2, p_number number)
      return varchar2;
  --
  -- (select 'object_code' object_code,id1,id2,name value,description
  -- from 'from_table'
  -- where 'where_clause')
  --
  function get_object_sql(p_object_code in varchar2,p_clause_yn in varchar2) return varchar2;
  function get_object_sql(p_object_code in varchar2,p_cpl_id in number) return varchar2;
  function get_object_sql(p_object_code in varchar2) return varchar2;
  function get_object_val
    (p_object_code in varchar2, p_object_id1 in varchar2, p_object_id2 in varchar2)
      return varchar2;
  function get_object_dsc
    (p_object_code in varchar2, p_object_id1 in varchar2, p_object_id2 in varchar2)
      return varchar2;
  procedure get_object_ids(
		p_value in varchar2,
		p_sql in varchar2,
		x_object_code out nocopy varchar2,
		x_id1 out nocopy varchar2,
		x_id2 out nocopy varchar2,
		x_desc out nocopy varchar2
  );
  procedure get_object_ids(
		p_value in varchar2,
		p_desc in varchar2,
		p_sql in varchar2,
		x_object_code out nocopy varchar2,
		x_id1 out nocopy varchar2,
		x_id2 out nocopy varchar2,
		x_desc out nocopy varchar2
  );
  --
  -- (select id, value, meaning description
  -- from 'application_table_name'
  -- where 'additional_where_clause'  --get rid of where and order by)
  --
  function get_flex_sql(p_rdf_code in varchar2, p_col_name in varchar2,p_clause_yn in varchar2) return varchar2;
  function get_flex_sql(p_rdf_code in varchar2, p_col_name in varchar2) return varchar2;
  function get_flex_val(p_rdf_code in varchar2, p_col_name in varchar2, p_id in varchar2)
	return varchar2;
  function get_flex_dsc(p_rdf_code in varchar2, p_col_name in varchar2, p_id in varchar2)
	return varchar2;
  procedure get_flex_ids(
		p_value varchar2,
		p_sql in varchar2,
		x_id out nocopy varchar2,
		x_desc out nocopy varchar2
  );
  procedure get_flex_ids(
		p_value varchar2,
		p_desc varchar2,
		p_sql in varchar2,
		x_id out nocopy varchar2,
		x_desc out nocopy varchar2
  );
  function euro_YN(rle_code varchar2, p_chr_id number) return varchar2;
function gen_comments return varchar2;
procedure no_comments;
function euro_yn(auth_org_id number) return varchar2;
END OKL_RULE_PUB;

 

/
