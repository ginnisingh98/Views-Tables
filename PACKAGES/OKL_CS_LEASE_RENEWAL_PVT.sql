--------------------------------------------------------
--  DDL for Package OKL_CS_LEASE_RENEWAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CS_LEASE_RENEWAL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRKLRS.pls 115.2 2002/11/30 08:50:45 spillaip noship $ */

TYPE lease_details_rec_type is RECORD (
   rent		NUMBER(14,3)
   ,start_date  	DATE
   ,end_date    	DATE
   ,Term_duration	NUMBER
   ,residual		NUMBER
   ,yield		NUMBER);

TYPE lease_details_tbl_type IS TABLE OF lease_details_rec_type INDEX BY BINARY_INTEGER;

  subtype klev_tbl_type IS OKL_CONTRACT_PUB.klev_tbl_type;
  subtype clev_tbl_type IS OKL_OKC_MIGRATION_PVT.clev_tbl_type;


FUNCTION get_current_lease_values (p_khr_id		IN	NUMBER)
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
                p_commit	         IN      VARCHAR2 := OKL_API.G_FALSE,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_chr_id                IN NUMBER,
                x_chr_id                OUT NOCOPY NUMBER);

 PROCEDURE update_hdr_info(
                               x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_count      OUT NOCOPY NUMBER,
                               x_msg_data       OUT NOCOPY VARCHAR2,
                               p_working_copy_chr_id    IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_start_date     IN  OKL_K_HEADERS_FULL_V.START_DATE%TYPE,
                               p_end_date       IN  OKL_K_HEADERS_FULL_V.END_DATE%TYPE,
                               p_term_duration  IN  OKL_K_HEADERS_FULL_V.TERM_DURATION%TYPE
                              );

  PROCEDURE update_residual_value(
                                  x_return_status      OUT NOCOPY VARCHAR2,
                                  x_msg_count          OUT NOCOPY NUMBER,
                                  x_msg_data           OUT NOCOPY VARCHAR2,
                                  p_chr_id              IN NUMBER,
                                  p_reduce_residual_ptg_by     IN  NUMBER
                                 );

PROCEDURE update_lrnw_request(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_trqv_rec              IN  okl_trx_requests_pub.trqv_rec_type
    ,x_trqv_rec              OUT  NOCOPY okl_trx_requests_pub.trqv_rec_type);


END OKL_CS_LEASE_RENEWAL_PVT;

 

/
