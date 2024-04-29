--------------------------------------------------------
--  DDL for Package OKL_LEASE_OPPORTUNITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_OPPORTUNITY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLOPS.pls 120.4 2005/10/12 19:22:10 rfedane noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_LEASE_OPPORTUNITY_PVT';
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
  SUBTYPE lease_opp_rec_type IS okl_lop_pvt.lopv_rec_type;
  SUBTYPE lease_opp_tbl_type IS okl_lop_pvt.lopv_tbl_type;

  ----------------
  -- PROGRAM UNITS
  ----------------
  PROCEDURE create_lease_opp (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_lease_opp_rec           IN  lease_opp_rec_type,
                              p_quick_quote_id          IN  NUMBER,
                              x_lease_opp_rec           OUT NOCOPY lease_opp_rec_type,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2);


  PROCEDURE update_lease_opp (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_lease_opp_rec           IN  lease_opp_rec_type,
                              x_lease_opp_rec           OUT NOCOPY lease_opp_rec_type,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2);


  PROCEDURE cancel_lease_opp (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_lease_opp_id            IN  NUMBER,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2);


  PROCEDURE defaults_for_lease_opp (p_api_version       IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_lease_opp_rec           IN  lease_opp_rec_type,
                              p_user_id                 IN  VARCHAR2,
                              x_sales_rep_name          OUT NOCOPY VARCHAR2,
                              x_lease_opp_rec           OUT NOCOPY lease_opp_rec_type,
                              x_dff_name                OUT NOCOPY VARCHAR2,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2);


  PROCEDURE duplicate_lease_opp (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_source_leaseopp_id      IN  NUMBER,
                              p_lease_opp_rec           IN  lease_opp_rec_type,
                              x_lease_opp_rec           OUT NOCOPY lease_opp_rec_type,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2);


END OKL_LEASE_OPPORTUNITY_PVT;

 

/
