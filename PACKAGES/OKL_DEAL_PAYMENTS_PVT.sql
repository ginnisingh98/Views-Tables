--------------------------------------------------------
--  DDL for Package OKL_DEAL_PAYMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DEAL_PAYMENTS_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRDPYS.pls 120.0 2007/05/04 14:55:18 sjalasut noship $ */

-------------------------------------------------------------------------------------------------
-- COMPOSITE VARIABLES
-------------------------------------------------------------------------------------------------

  FUNCTION get_fee_service_name(
            p_chr_id           IN  NUMBER,
            p_cle_id           IN  NUMBER,
            p_lse_id           IN  NUMBER,
            p_parent_cle_id    IN  NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_asset_number(
            p_chr_id           IN  NUMBER,
            p_cle_id           IN  NUMBER,
            p_lse_id           IN  NUMBER)
  RETURN VARCHAR2;

  PROCEDURE load_payment_header(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_chr_id             IN  NUMBER,
            p_cle_id             IN  NUMBER,
            x_service_fee_cle_id OUT NOCOPY NUMBER,
            x_service_fee_name   OUT NOCOPY VARCHAR2,
            x_asset_cle_id       OUT NOCOPY NUMBER,
            x_asset_number       OUT NOCOPY VARCHAR2,
            x_asset_description  OUT NOCOPY VARCHAR2);

End OKL_DEAL_PAYMENTS_PVT;

/
