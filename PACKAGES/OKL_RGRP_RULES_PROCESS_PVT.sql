--------------------------------------------------------
--  DDL for Package OKL_RGRP_RULES_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RGRP_RULES_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRRGRS.pls 115.8 2002/11/30 08:58:31 spillaip noship $ */
  /* *************************************** */
TYPE rgr_rec_type IS RECORD (
    rgd_code                       OKC_RULE_GROUPS_B.RGD_CODE%TYPE := OKC_API.G_MISS_CHAR,
    --id                             NUMBER := OKC_API.G_MISS_NUM,
    rule_id                        OKC_RULES_V.ID%TYPE := OKC_API.G_MISS_NUM,
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
--    text                           OKC_RULES_V.TEXT%TYPE := NULL,
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
    ans_set_jtot_object_id1        OKC_RULES_B.ans_set_jtot_object_id1%TYPE := OKC_API.G_MISS_CHAR,
    ans_set_jtot_object_id2        OKC_RULES_B.ans_set_jtot_object_id2%TYPE := OKC_API.G_MISS_CHAR,
    display_sequence               NUMBER:= OKC_API.G_MISS_NUM);

TYPE rgr_out_rec_type IS RECORD (
    id                             OKC_RULES_V.ID%TYPE := OKC_API.G_MISS_NUM,
    rule_code                      OKC_RULES_V.RULE_INFORMATION_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    rgd_code                       OKC_RULE_GROUPS_V.RGD_CODE%TYPE := OKC_API.G_MISS_CHAR,
    new_yn                         OKC_RULES_B.TEMPLATE_YN%TYPE := OKC_API.G_MISS_CHAR);

    TYPE rgr_tbl_type     IS TABLE OF rgr_rec_type     INDEX BY BINARY_INTEGER;
    TYPE rgr_out_tbl_type IS TABLE OF rgr_out_rec_type INDEX BY BINARY_INTEGER;
    subtype rgpv_rec_type is OKL_RULE_PUB.rgpv_rec_type;
    subtype rgpv_tbl_type is OKL_RULE_PUB.rgpv_tbl_type;
    subtype rulv_rec_type is OKL_RULE_PUB.rulv_rec_type;
    subtype rulv_tbl_type is OKL_RULE_PUB.rulv_tbl_type;
    subtype rmpv_rec_type is OKL_RULE_PUB.rmpv_rec_type;

PROCEDURE process_rule_group_rules(
            p_api_version                  IN NUMBER,
            p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status                OUT NOCOPY VARCHAR2,
            x_msg_count                    OUT NOCOPY NUMBER,
            x_msg_data                     OUT NOCOPY VARCHAR2,
            p_chr_id                       IN  NUMBER,
            p_line_id                      IN  NUMBER,
            p_cpl_id                       IN  NUMBER,
            p_rrd_id                       IN  NUMBER,
            p_rgr_tbl                      IN  rgr_tbl_type);

PROCEDURE process_template_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id          	           IN  NUMBER,
    p_rgr_tbl                      IN  rgr_tbl_type,
    x_rgr_tbl			   OUT NOCOPY rgr_out_tbl_type);

  FUNCTION get_header_rule_group_id(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_rgd_code                     IN  VARCHAR2)
    RETURN OKC_RULE_GROUPS_B.ID%TYPE;
    /* *************************************** */
END OKL_RGRP_RULES_PROCESS_PVT;

 

/
