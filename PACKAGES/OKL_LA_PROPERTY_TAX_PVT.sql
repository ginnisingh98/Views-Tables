--------------------------------------------------------
--  DDL for Package OKL_LA_PROPERTY_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LA_PROPERTY_TAX_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPTXS.pls 120.2 2005/10/30 03:17:00 appldev noship $ */

-- GLOBAL VARIABLES
---------------------------------------------------------------------------
g_api_type	  CONSTANT VARCHAR2(4)  := '_PVT';
g_pkg_name    CONSTANT VARCHAR2(30) := 'OKL_LA_PROPERTY_TAX_PVT';
---------------------------------------------------------------------------

  subtype rgpv_rec_type IS OKL_RULE_PUB.rgpv_rec_type;
  subtype rulv_rec_type IS OKL_RULE_PUB.rulv_rec_type;


  PROCEDURE create_est_prop_tax_rules(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_cle_id                 IN  NUMBER);

  -- 4086808 fmiao 2/9/05 --
  PROCEDURE create_est_prop_tax_rules(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER);

  PROCEDURE sync_contract_property_tax(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER);

END OKL_LA_PROPERTY_TAX_PVT;

 

/
