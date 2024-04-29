--------------------------------------------------------
--  DDL for Package OKL_TRANSACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRANSACTION_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPTXNS.pls 115.2 2002/08/19 22:05:21 dedey noship $*/

  subtype tcnv_rec_type      IS OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;
  subtype rev_tbl_type       IS OKL_TRANSACTION_PVT.rev_tbl_type;

  PROCEDURE create_transaction(
                               p_api_version        IN  NUMBER,
                               p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER,
                               x_msg_data           OUT NOCOPY VARCHAR2,
                               p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_new_chr_id         IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_reason_code        IN  VARCHAR2,
                               p_description        IN  VARCHAR2,
                               p_trx_date           IN  DATE,
                               p_trx_type           IN  VARCHAR2, -- 'REBOOK' or 'SPLIT'
                               x_tcnv_rec           OUT NOCOPY tcnv_rec_type
                              );

  PROCEDURE update_trx_status(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                              p_status             IN  VARCHAR2,
                              x_tcnv_rec           OUT NOCOPY tcnv_rec_type
                             );

  PROCEDURE abandon_revisions(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_rev_tbl            IN  rev_tbl_type,
                              p_contract_status    IN  VARCHAR2,
		              p_tsu_code           IN  VARCHAR2
                             );

END OKL_TRANSACTION_PUB;

 

/
