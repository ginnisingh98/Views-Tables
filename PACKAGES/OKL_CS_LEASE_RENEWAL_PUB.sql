--------------------------------------------------------
--  DDL for Package OKL_CS_LEASE_RENEWAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CS_LEASE_RENEWAL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPKLRS.pls 115.2 2002/11/30 08:36:24 spillaip noship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_APP_NAME                    CONSTANT VARCHAR2(3)   := 'OKL';
  G_PKG_NAME                    CONSTANT VARCHAR2(30)  := 'okl_cs_lease_renewal_pub';
  G_API_NAME                    CONSTANT VARCHAR2(30)  := 'okl_cs_lease_renewal';
  G_API_VERSION                 CONSTANT NUMBER        := 1;
  G_COMMIT                      CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_INIT_MSG_LIST               CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_VALIDATION_LEVEL            CONSTANT NUMBER        := FND_API.G_VALID_LEVEL_FULL;


  ---------------------------------------------------------------------------
  -- Local Variables
  ---------------------------------------------------------------------------

  SUBTYPE lease_details_tbl_type IS OKL_CS_LEASE_RENEWAL_PVT.lease_details_tbl_type;
  subtype klev_tbl_type IS OKL_CONTRACT_PUB.klev_tbl_type;
  subtype clev_tbl_type IS OKL_OKC_MIGRATION_PVT.clev_tbl_type;



  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------



FUNCTION get_current_lease_values (p_khr_id             IN      NUMBER)
RETURN lease_details_tbl_type;


   PROCEDURE calculate(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := OKL_API.G_FALSE,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_trqv_tbl              IN  okl_trx_requests_pub.trqv_tbl_type,
                x_trqv_tbl              OUT NOCOPY okl_trx_requests_pub.trqv_tbl_type);

 PROCEDURE create_working_copy(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := OKL_API.G_FALSE,
                p_commit         IN      VARCHAR2 := OKL_API.G_FALSE,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_chr_id                IN NUMBER,
                x_chr_id                OUT NOCOPY NUMBER);

PROCEDURE update_lrnw_request(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_trqv_rec              IN  okl_trx_requests_pub.trqv_rec_type
    ,x_trqv_rec              OUT  NOCOPY okl_trx_requests_pub.trqv_rec_type);


END okl_cs_lease_renewal_pub;

 

/
