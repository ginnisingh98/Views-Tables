--------------------------------------------------------
--  DDL for Package OKL_ASSET_DETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ASSET_DETAILS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPADSS.pls 115.2 2002/12/27 01:14:05 rkuttiya noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_APP_NAME                    CONSTANT VARCHAR2(3)   := 'OKL';
  G_PKG_NAME                    CONSTANT VARCHAR2(30)  := 'OKL_ASSET_DETAILS_PUB';
  G_API_NAME                    VARCHAR2(30)  := 'Update_Year';
  G_API_VERSION                 CONSTANT NUMBER        := 1;
  G_COMMIT                      CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_INIT_MSG_LIST               CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_VALIDATION_LEVEL            CONSTANT NUMBER        := FND_API.G_VALID_LEVEL_FULL;


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
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
                     x_rule_information1      OUT NOCOPY VARCHAR2,
                     x_rule_information2      OUT NOCOPY VARCHAR2,
                     x_rule_information3      OUT NOCOPY VARCHAR2,
                     x_rule_information4      OUT NOCOPY VARCHAR2);

PROCEDURE update_asset(p_api_version            IN     NUMBER,
                         p_init_msg_list        IN     VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status        OUT    NOCOPY VARCHAR2,
                         x_msg_count            OUT    NOCOPY NUMBER,
                         x_msg_data             OUT    NOCOPY VARCHAR2,
                         p_asset_id             IN     NUMBER,
                         p_asset_number         IN     VARCHAR2,
                         px_asset_desc          IN OUT NOCOPY VARCHAR2,
                         px_model_no            IN OUT NOCOPY VARCHAR2,
                         px_manufacturer        IN OUT NOCOPY VARCHAR2);

END okl_asset_details_pub;

 

/
