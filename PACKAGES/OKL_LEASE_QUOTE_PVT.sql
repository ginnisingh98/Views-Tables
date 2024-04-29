--------------------------------------------------------
--  DDL for Package OKL_LEASE_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_QUOTE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLSQS.pls 120.6 2007/08/08 21:11:02 rravikir noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_LEASE_QUOTE_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(30)  := OKL_API.G_APP_NAME;
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_USER_ID              CONSTANT NUMBER        := FND_GLOBAL.USER_ID;
  G_LOGIN_ID             CONSTANT NUMBER        := FND_GLOBAL.LOGIN_ID;
  G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
  G_DB_ERROR             CONSTANT VARCHAR2(30)  := 'OKL_DB_ERROR';
  G_PKG_NAME_TOKEN       CONSTANT VARCHAR2(30)  := 'PKG_NAME';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(30)  := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLERRM';

  ------------------
  -- DATA STRUCTURES
  ------------------
  SUBTYPE lease_qte_rec_type IS okl_lsq_pvt.lsqv_rec_type;
  SUBTYPE lease_qte_tbl_type IS okl_lsq_pvt.lsqv_tbl_type;

  SUBTYPE lease_qte_fee_rec_type IS okl_fee_pvt.feev_rec_type;

  ----------------
  -- PROGRAM UNITS
  ----------------
  PROCEDURE create_lease_qte (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_lease_qte_rec           IN  lease_qte_rec_type,
                              x_lease_qte_rec           OUT NOCOPY lease_qte_rec_type,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2);


  PROCEDURE update_lease_qte (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_lease_qte_rec           IN  lease_qte_rec_type,
                              x_lease_qte_rec           OUT NOCOPY lease_qte_rec_type,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2);


  PROCEDURE duplicate_lease_qte (p_api_version             IN  NUMBER,
                              	 p_init_msg_list           IN  VARCHAR2,
                              	 p_transaction_control     IN  VARCHAR2,
                              	 p_source_quote_id		   IN  NUMBER,
                              	 p_lease_qte_rec           IN  lease_qte_rec_type,
                                 x_lease_qte_rec           OUT NOCOPY lease_qte_rec_type,
                              	 x_return_status           OUT NOCOPY VARCHAR2,
                              	 x_msg_count               OUT NOCOPY NUMBER,
                              	 x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE duplicate_lease_qte (p_api_version             IN  NUMBER,
                              	 p_init_msg_list           IN  VARCHAR2,
                              	 p_transaction_control     IN  VARCHAR2,
                              	 p_quote_id		   	   	   IN  NUMBER,
                                 x_lease_qte_rec           OUT NOCOPY lease_qte_rec_type,
                              	 x_return_status           OUT NOCOPY VARCHAR2,
                              	 x_msg_count               OUT NOCOPY NUMBER,
                              	 x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE duplicate_quotes(p_api_version             IN  NUMBER,
                             p_init_msg_list           IN  VARCHAR2,
                             p_transaction_control     IN  VARCHAR2,
                             p_source_leaseopp_id  	   IN  NUMBER,
                             p_target_leaseopp_id      IN  NUMBER,
                             x_return_status           OUT NOCOPY VARCHAR2,
                             x_msg_count               OUT NOCOPY NUMBER,
                             x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE cancel_lease_qte (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_lease_qte_tbl           IN  lease_qte_tbl_type,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE submit_lease_qte (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_quote_id		   	   	IN  NUMBER,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE accept_lease_qte (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_quote_id		   	   	IN  NUMBER,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE validate_lease_qte (p_lease_qte_rec         IN lease_qte_rec_type,
                                x_return_status         OUT NOCOPY VARCHAR2);

  PROCEDURE unaccept_lease_qte (p_api_version             IN  NUMBER,
                                p_init_msg_list           IN  VARCHAR2,
                                p_transaction_control     IN  VARCHAR2,
                                p_quote_id                IN  NUMBER,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE  change_pricing(p_api_version              IN  NUMBER,
                            p_init_msg_list           IN  VARCHAR2,
                            p_transaction_control     IN  VARCHAR2,
                            p_quote_id                IN  NUMBER,
                            x_return_status           OUT NOCOPY VARCHAR2,
                            x_msg_count               OUT NOCOPY NUMBER,
                            x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE calculate_sales_tax(p_api_version              IN  NUMBER,
                                p_init_msg_list            IN  VARCHAR2,
                                x_return_status            OUT NOCOPY VARCHAR2,
                                x_msg_count                OUT NOCOPY NUMBER,
                                x_msg_data                 OUT NOCOPY VARCHAR2,
                                p_transaction_control      IN  VARCHAR2,
                                p_quote_id                 IN  NUMBER);

END OKL_LEASE_QUOTE_PVT;

/
