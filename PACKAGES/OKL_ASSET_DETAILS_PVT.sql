--------------------------------------------------------
--  DDL for Package OKL_ASSET_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ASSET_DETAILS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRADSS.pls 115.2 2002/12/18 14:45:37 spillaip noship $ */
PROCEDURE Update_year(
                      p_api_version            IN  NUMBER,
                      p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                      x_return_status          OUT NOCOPY VARCHAR2,
                      x_msg_count              OUT NOCOPY NUMBER,
                      x_msg_data               OUT NOCOPY VARCHAR2,
                      p_dnz_chr_id             IN  NUMBER,
                      p_parent_line_id         IN  NUMBER,
                      p_year                   IN  VARCHAR2,
                      x_year                   OUT NOCOPY VARCHAR2);

PROCEDURE update_tax(p_api_version            IN  NUMBER,
                     p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                     x_return_status          OUT NOCOPY VARCHAR2,
                     x_msg_count              OUT NOCOPY NUMBER,
                     x_msg_data               OUT NOCOPY VARCHAR2,
                     p_rule_id                IN  NUMBER,
                     p_rule_grp_id            IN  NUMBER,
                     p_dnz_chr_id             IN  NUMBER,
                     p_rule_information1      IN  VARCHAR2,
                     p_rule_information2      IN  VARCHAR2,
                     p_rule_information3      IN  VARCHAR2,
                     p_rule_information4      IN  VARCHAR2,
                     x_rule_information1      OUT  NOCOPY VARCHAR2,
                     x_rule_information2      OUT  NOCOPY VARCHAR2,
                     x_rule_information3      OUT  NOCOPY VARCHAR2,
                     x_rule_information4      OUT  NOCOPY VARCHAR2);

PROCEDURE update_asset(p_api_version            IN     NUMBER,
                         p_init_msg_list        IN     VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status        OUT    NOCOPY VARCHAR2,
                         x_msg_count            OUT    NOCOPY NUMBER,
                         x_msg_data             OUT    NOCOPY VARCHAR2,
                         p_asset_id             IN     NUMBER,
                         p_asset_number         IN     VARCHAR2,
  -- SPILLAIP - 2689257 - Start
                         px_asset_desc          IN OUT NOCOPY VARCHAR2,
                         px_model_no            IN OUT NOCOPY VARCHAR2,
                         px_manufacturer        IN OUT NOCOPY VARCHAR2);
  -- SPILLAIP - 2689257 - End

END okl_asset_details_pvt ;

 

/
