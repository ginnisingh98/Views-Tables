--------------------------------------------------------
--  DDL for Package OKL_DEAL_CHARGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DEAL_CHARGES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRKACS.pls 120.0 2007/04/03 15:33:43 gboomina noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'okl_la_deal_charges_pvt';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  TYPE fee_rec_type IS RECORD(
    cleb_fee_id                  OKC_K_LINES_B.id%TYPE,
    dnz_chr_id                   OKC_K_LINES_B.dnz_chr_id%TYPE,
    fee_type                     OKL_K_LINES.fee_type%TYPE,
    cim_fee_id                   OKC_K_ITEMS.id%TYPE,
    cim_fee_sty_name             OKL_STRMTYP_SOURCE_V.name%TYPE,
    cim_fee_object1_id1          OKC_K_ITEMS.object1_id1%TYPE,
    cim_fee_object1_id2          OKC_K_ITEMS.object1_id2%TYPE,
    cplb_fee_id                  OKC_K_PARTY_ROLES_B.id%TYPE,
    cplb_fee_vendor_name         OKX_PARTIES_V.name%TYPE,
    cplb_fee_object1_id1         OKC_K_PARTY_ROLES_B.object1_id1%TYPE,
    cplb_fee_object1_id2         OKC_K_PARTY_ROLES_B.object1_id2%TYPE,
    start_date                   OKC_K_LINES_B.start_date%TYPE,
    end_date                     OKC_K_LINES_B.end_date%TYPE,
    amount                       OKL_K_LINES.amount%TYPE,
    initial_direct_cost          OKL_K_LINES.initial_direct_cost%TYPE,
    rollover_term_quote_number   OKL_TRX_QUOTES_B.quote_number%TYPE,
    qte_id                       OKL_K_LINES.qte_id%TYPE,
    funding_date                 OKL_K_LINES.funding_date%TYPE,
    fee_purpose_code             OKL_K_LINES.fee_purpose_code%TYPE,
    attribute_category           OKL_K_LINES.attribute_category%TYPE,
    attribute1                   OKL_K_LINES.attribute1%TYPE,
    attribute2                   OKL_K_LINES.attribute2%TYPE,
    attribute3                   OKL_K_LINES.attribute3%TYPE,
    attribute4                   OKL_K_LINES.attribute4%TYPE,
    attribute5                   OKL_K_LINES.attribute5%TYPE,
    attribute6                   OKL_K_LINES.attribute6%TYPE,
    attribute7                   OKL_K_LINES.attribute7%TYPE,
    attribute8                   OKL_K_LINES.attribute8%TYPE,
    attribute9                   OKL_K_LINES.attribute9%TYPE,
    attribute10                  OKL_K_LINES.attribute10%TYPE,
    attribute11                  OKL_K_LINES.attribute11%TYPE,
    attribute12                  OKL_K_LINES.attribute12%TYPE,
    attribute13                  OKL_K_LINES.attribute13%TYPE,
    attribute14                  OKL_K_LINES.attribute14%TYPE,
    attribute15                  OKL_K_LINES.attribute15%TYPE,
    validate_dff_yn              VARCHAR2(3),
    rgp_lafexp_id                OKC_RULE_GROUPS_B.id%TYPE,
    rul_lafreq_id                OKC_RULES_B.id%TYPE,
    rul_lafreq_object1_id1       OKC_RULES_B.object1_id1%TYPE,
    rul_lafreq_object1_id2       OKC_RULES_B.object1_id2%TYPE,
    rul_lafreq_object1_code      OKC_RULES_B.jtot_object1_code%TYPE,
    frequency_name               OKL_TIME_UNITS_V.name%TYPE,
    rul_lafexp_id                OKC_RULES_B.id%TYPE,
    rul_lafexp_rule_information1 OKC_RULES_B.rule_information1%TYPE,
    rul_lafexp_rule_information2 OKC_RULES_B.rule_information2%TYPE
    );

  TYPE fee_tbl_type IS TABLE OF fee_rec_type INDEX BY BINARY_INTEGER;

  TYPE cov_asset_rec_type IS RECORD (
     cleb_cov_asset_id              OKC_K_LINES_B.id%TYPE
    ,cleb_cov_asset_cle_id          OKC_K_LINES_B.cle_id%TYPE
    ,dnz_chr_id                     OKC_K_LINES_B.dnz_chr_id%TYPE
    ,asset_number                   OKC_K_LINES_TL.name%TYPE
    ,description                    OKC_K_LINES_TL.item_description%TYPE
    ,capital_amount                 OKL_K_LINES.amount%TYPE
    ,cim_cov_asset_id               OKC_K_LINES_B.id%TYPE
    ,object1_id1                    OKC_K_ITEMS.object1_id1%TYPE
    ,object1_id2                    OKC_K_ITEMS.object1_id2%TYPE
    ,jtot_object1_code              OKC_K_ITEMS.jtot_object1_code%TYPE
    );

  TYPE cov_asset_tbl_type IS TABLE OF cov_asset_rec_type INDEX BY BINARY_INTEGER;

  PROCEDURE delete_fee_service(
            p_api_version           IN  NUMBER,
            p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2,
            p_id                    IN  NUMBER);

  PROCEDURE delete_usage(
            p_api_version           IN  NUMBER,
            p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2,
            p_id                    IN  NUMBER);

  PROCEDURE delete_insurance(
            p_api_version           IN  NUMBER,
            p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2,
            p_id                    IN  NUMBER);

  PROCEDURE allocate_amount_charges (
            p_api_version    	       IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_cle_id                 IN  NUMBER DEFAULT NULL,
            p_amount                 IN  NUMBER,
            p_mode                   IN  VARCHAR2,
            x_cov_asset_tbl          OUT NOCOPY cov_asset_tbl_type);

  PROCEDURE create_fee(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_fee_rec        IN  fee_rec_type,
            x_fee_rec        OUT NOCOPY fee_rec_type);

  PROCEDURE update_fee(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_fee_rec        IN  fee_rec_type,
            x_fee_rec        OUT NOCOPY fee_rec_type);


END okl_deal_charges_pvt;

/
