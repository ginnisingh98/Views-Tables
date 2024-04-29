--------------------------------------------------------
--  DDL for Package OKL_LEASE_QUOTE_SUBPOOL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_QUOTE_SUBPOOL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRQUYS.pls 120.1 2006/04/18 16:02:42 asawanka noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_LEASE_QUOTE_SUBSIDY_PVT';
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
  subtype subsidy_pool_rec_type is okl_subsidy_pool_trx_pvt.sixv_rec_type;
  subtype subsidy_pool_tbl_type is okl_subsidy_pool_trx_pvt.sixv_tbl_type;

  subtype quote_sp_usage_rec_type is OKL_QUL_PVT.qulv_rec_type;
  subtype quote_sp_usage_tbl_type is OKL_QUL_PVT.qulv_tbl_type;

  ----------------
  -- PROGRAM UNITS
  ----------------
  PROCEDURE process_quote_subsidy_pool (p_api_version             IN  NUMBER,
			                            p_init_msg_list           IN  VARCHAR2,
            		                    p_transaction_control     IN  VARCHAR2,
 		                                p_quote_id                IN  NUMBER,
 		                                p_transaction_reason      IN  VARCHAR2,
                          			    x_return_status           OUT NOCOPY VARCHAR2,
                          			    x_msg_count               OUT NOCOPY NUMBER,
                          			    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE process_leaseapp_subsidy_pool (p_api_version             IN  NUMBER,
			                               p_init_msg_list           IN  VARCHAR2,
            		                       p_transaction_control     IN  VARCHAR2,
 		                                   p_leaseapp_id             IN  NUMBER,
 		                                   p_transaction_reason      IN  VARCHAR2,
                                       p_quote_id                IN NUMBER,
                          			       x_return_status           OUT NOCOPY VARCHAR2,
                          			       x_msg_count               OUT NOCOPY NUMBER,
                          			       x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE process_cancel_leaseopp (p_api_version             IN  NUMBER,
			                         p_init_msg_list           IN  VARCHAR2,
            		                 p_transaction_control     IN  VARCHAR2,
                                     p_parent_object_id        IN  NUMBER,
                          			 x_return_status           OUT NOCOPY VARCHAR2,
                          			 x_msg_count               OUT NOCOPY NUMBER,
                          			 x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE process_active_contract (p_api_version             IN  NUMBER,
			                         p_init_msg_list           IN  VARCHAR2,
            		                 p_transaction_control     IN  VARCHAR2,
                                     p_contract_id             IN  NUMBER,
                          			 x_return_status           OUT NOCOPY VARCHAR2,
                          			 x_msg_count               OUT NOCOPY NUMBER,
                          			 x_msg_data                OUT NOCOPY VARCHAR2);


END OKL_LEASE_QUOTE_SUBPOOL_PVT;

/
