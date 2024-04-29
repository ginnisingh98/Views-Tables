--------------------------------------------------------
--  DDL for Package OKL_DEAL_PARTIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DEAL_PARTIES_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRDPRS.pls 120.1 2007/06/21 18:42:14 asahoo noship $ */
-------------------------------------------------------------------------------------------------
-- COMPOSITE VARIABLES
-------------------------------------------------------------------------------------------------
  TYPE party_role_rec_type IS RECORD (
    chr_id                        OKC_K_HEADERS_B.ID%TYPE,
    party_role_id                 OKL_K_PARTY_ROLES.ID%TYPE,
    party_role                    FND_LOOKUPS.MEANING%TYPE,
    party_id                      HZ_PARTIES.PARTY_ID%TYPE,
    party_name                    HZ_PARTIES.PARTY_NAME%TYPE,
    party_site_number             HZ_PARTY_SITES.PARTY_SITE_NUMBER%TYPE,
    rgp_id                        OKC_RULE_GROUPS_B.id%TYPE,
    rgp_lalabl_lalogo_id          OKC_RULE_GROUPS_B.id%TYPE,
    rgp_lagrdt_lagrnp_id          OKC_RULE_GROUPS_B.id%TYPE,
    rgp_lagrdt_lagrnt_id          OKC_RULE_GROUPS_B.id%TYPE,
    rul_lalogo_id                 OKC_RULES_B.ID%TYPE,
    rul_lagrnp_id                 OKC_RULES_B.ID%TYPE,
    rul_lagrnt_id                 OKC_RULES_B.ID%TYPE,
    lalogo_rule_information1      OKC_RULES_B.RULE_INFORMATION1%TYPE,
    rul_lagrnp_object1_id1        OKC_RULES_B.object1_id1%TYPE,
    rul_lagrnp_object1_id2        OKC_RULES_B.object1_id2%TYPE,
    lagrnp_rule_info_cat          OKC_RULES_B.rule_information_category%TYPE,
    lagrnp_rule_information1      OKC_RULES_B.rule_information1%TYPE,
    lagrnt_rule_info_cat          OKC_RULES_B.rule_information_category%TYPE,
    lagrnt_rule_information1      OKC_RULES_B.rule_information1%TYPE,
    lagrnt_rule_information2      OKC_RULES_B.rule_information2%TYPE,
    lagrnt_rule_information3      OKC_RULES_B.rule_information3%TYPE,
    lagrnt_rule_information4      OKC_RULES_B.rule_information4%TYPE,
    attribute_category            OKL_K_PARTY_ROLES.ATTRIBUTE_CATEGORY%TYPE,
    attribute1                    OKL_K_PARTY_ROLES.ATTRIBUTE1%TYPE,
    attribute2                    OKL_K_PARTY_ROLES.ATTRIBUTE2%TYPE,
    attribute3                    OKL_K_PARTY_ROLES.ATTRIBUTE3%TYPE,
    attribute4                    OKL_K_PARTY_ROLES.ATTRIBUTE4%TYPE,
    attribute5                    OKL_K_PARTY_ROLES.ATTRIBUTE5%TYPE,
    attribute6                    OKL_K_PARTY_ROLES.ATTRIBUTE6%TYPE,
    attribute7                    OKL_K_PARTY_ROLES.ATTRIBUTE7%TYPE,
    attribute8                    OKL_K_PARTY_ROLES.ATTRIBUTE8%TYPE,
    attribute9                    OKL_K_PARTY_ROLES.ATTRIBUTE9%TYPE,
    attribute10                   OKL_K_PARTY_ROLES.ATTRIBUTE10%TYPE,
    attribute11                   OKL_K_PARTY_ROLES.ATTRIBUTE11%TYPE,
    attribute12                   OKL_K_PARTY_ROLES.ATTRIBUTE12%TYPE,
    attribute13                   OKL_K_PARTY_ROLES.ATTRIBUTE13%TYPE,
    attribute14                   OKL_K_PARTY_ROLES.ATTRIBUTE14%TYPE,
    attribute15                   OKL_K_PARTY_ROLES.ATTRIBUTE15%TYPE);


    PROCEDURE process_label_holder(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  party_role_rec_type,
    x_rgpv_rec                     OUT NOCOPY party_role_rec_type);

    PROCEDURE load_guarantor(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      p_party_id                   IN  NUMBER,
      x_party_role_rec             OUT NOCOPY party_role_rec_type);

    PROCEDURE process_guarantor(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_rgpv_rec                   IN  party_role_rec_type,
      x_rgpv_rec                   OUT NOCOPY party_role_rec_type);
End OKL_DEAL_PARTIES_PVT;

/
