--------------------------------------------------------
--  DDL for Package OKL_DEAL_TERMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DEAL_TERMS_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRDTRS.pls 120.2 2008/06/08 01:53:06 avsingh noship $ */

-------------------------------------------------------------------------------------------------
-- COMPOSITE VARIABLES
-------------------------------------------------------------------------------------------------
  TYPE billing_setup_rec_type IS RECORD (
    chr_id                        OKC_K_HEADERS_B.id%TYPE,
    cle_id                        OKC_K_LINES_B.id%TYPE,
    asset_number                  OKC_K_LINES_TL.name%TYPE,
    item_description              OKC_K_LINES_TL.item_description%TYPE,
    rgp_id                        OKC_rule_groups_b.id%TYPE,
    bill_to_site_use_id           OKC_K_LINES_B.bill_to_site_use_id%TYPE,
    bill_to_site_name             HZ_CUST_SITE_USES_ALL.location%TYPE,
    rgp_labill_lapmth_id          OKC_RULE_GROUPS_B.id%TYPE,
    rgp_labill_labacc_id          OKC_RULE_GROUPS_B.id%TYPE,
    rgp_labill_lainvd_id          OKC_RULE_GROUPS_B.id%TYPE,
    rgp_labill_lainpr_id          OKC_RULE_GROUPS_B.id%TYPE,
    rul_lapmth_id                 OKC_RULES_B.ID%TYPE,
    rul_labacc_id                 OKC_RULES_B.ID%TYPE,
    rul_lainvd_id                 OKC_RULES_B.ID%TYPE,
    rul_lainpr_id                 OKC_RULES_B.ID%TYPE,
    rul_lapmth_object1_id1        OKC_RULES_B.object1_id1%TYPE,
    rul_lapmth_object1_id2        OKC_RULES_B.object1_id2%TYPE,
    rul_lapmth_name               AR_RECEIPT_METHODS.name%TYPE,
    rul_labacc_object1_id1        OKC_RULES_B.object1_id1%TYPE,
    rul_labacc_object1_id2        OKC_RULES_B.object1_id2%TYPE,
    rul_labacc_name               OKX_RCPT_METHOD_ACCOUNTS_V.name%TYPE,
    rul_labacc_bank_name          AP_BANK_BRANCHES.bank_name%TYPE,
    lainvd_invoice_format_meaning VARCHAR2(200),
    lainvd_rule_information1      VARCHAR2(200),
    lainvd_rule_information3      VARCHAR2(200),
    lainvd_rule_information4      VARCHAR2(200),
    rul_lainvd_object1_id1        OKC_RULES_B.object1_id1%TYPE,
    rul_lainvd_object1_id2        OKC_RULES_B.object1_id2%TYPE,
    rul_lainvd_name               VARCHAR2(200),
    lainpr_rule_information1      VARCHAR2(200),
    lainpr_rule_information2      VARCHAR2(200));

  TYPE rvi_rec_type IS RECORD (
    line_id                       OKC_K_LINES_B.id%type,
    chr_id                        OKC_K_HEADERS_B.id%TYPE,
    fee_type                      VARCHAR2(250),
    rgp_id                        OKC_RULE_GROUPS_b.id%TYPE,
    rgd_code                      OKC_RULE_GROUPS_B.rgd_code%TYPE,
    rgp_larvin_larvau_id          OKC_RULE_GROUPS_B.id%TYPE,
    rgp_larvin_larvam_id          OKC_RULE_GROUPS_B.id%TYPE,
    rul_larvau_id                 OKC_RULES_B.ID%TYPE,
    larvau_rule_info_cat          OKC_RULES_B.rule_information_category%TYPE,
    rul_larvam_id                 OKC_RULES_B.ID%TYPE,
    larvam_rule_info_cat          OKC_RULES_B.rule_information_category%TYPE,
    larvau_rule_information1      OKC_RULES_B.rule_information1%TYPE,
    larvam_rule_information4      OKC_RULES_B.rule_information4%TYPE,
    item_id1                      OKL_STRM_TYPE_B.id%TYPE,
    item_name                     OKL_STRM_TYPE_TL.name%TYPE);

    PROCEDURE delete_terms(
            p_api_version         IN  NUMBER,
            p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status       OUT NOCOPY VARCHAR2,
            x_msg_count           OUT NOCOPY NUMBER,
            x_msg_data            OUT NOCOPY VARCHAR2,
            p_chr_id              IN  NUMBER,
            p_rgp_id              IN  NUMBER,
            p_page_name           IN  VARCHAR2);

    PROCEDURE process_billing_setup(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  billing_setup_rec_type,
    x_rgpv_rec                     OUT NOCOPY billing_setup_rec_type);

    PROCEDURE process_rvi(
    p_api_version            IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_rgpv_rec               IN  rvi_rec_type,
    x_rgpv_rec               OUT NOCOPY rvi_rec_type);

    PROCEDURE load_billing_setup(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_billing_setup_rec          OUT NOCOPY billing_setup_rec_type);

    PROCEDURE load_rvi(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_rvi_rec                    OUT NOCOPY rvi_rec_type);

-- Start of comments
  -- API name       : delete_tnc_group
  -- Pre-reqs       : None
  -- Function       : This procedure deletes the tnc group
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_tnc_id  - terms and conditions record id
  -- Version        : 1.0
  -- History        : 03-Jun-08 avsingh Created
  -- End of comments

  PROCEDURE delete_tnc_group(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_tnc_id                     IN  NUMBER
      );

End OKL_DEAL_TERMS_PVT;

/
