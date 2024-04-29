--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_REBOOK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_REBOOK_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRBKS.pls 115.0 2002/04/11 17:56:41 pkm ship     $*/

  subtype tcnv_rec_type      IS OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;


  --
  -- Synchronize Rebook and Originating Contract
  --
  PROCEDURE sync_rebook_orig_contract(
                                      p_api_version        IN  NUMBER,
                                      p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                      x_return_status      OUT NOCOPY VARCHAR2,
                                      x_msg_count          OUT NOCOPY NUMBER,
                                      x_msg_data           OUT NOCOPY VARCHAR2,
                                      p_rebook_chr_id      IN  OKC_K_HEADERS_V.ID%TYPE
                                     );

  --
  -- Create Rebook Transaction and Rebook Contract
  -- basically calls next 2 procedure,
  -- viz. create_transaction and create_rebook_contract
  --
  PROCEDURE create_txn_contract(
                                p_api_version        IN  NUMBER,
                                p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_msg_count          OUT NOCOPY NUMBER,
                                x_msg_data           OUT NOCOPY VARCHAR2,
                                p_from_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                                p_rebook_reason_code IN  VARCHAR2,
                                p_rebook_description IN  VARCHAR2,
                                p_trx_date           IN  DATE,
                                x_tcnv_rec           OUT NOCOPY tcnv_rec_type,
                                x_rebook_chr_id      OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                               );

  --
  -- Create Rebook Contract from Originating Contract
  --
  PROCEDURE create_rebook_contract(
                                   p_api_version        IN  NUMBER,
                                   p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_msg_count          OUT NOCOPY NUMBER,
                                   x_msg_data           OUT NOCOPY VARCHAR2,
                                   p_from_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                                   x_rebook_chr_id      OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                                  );

  --
  -- Synchronize Rebook and Original Streams generated from SuperTRUMP
  --
  PROCEDURE sync_rebook_stream(
                               p_api_version        IN  NUMBER,
                               p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER,
                               x_msg_data           OUT NOCOPY VARCHAR2,
                               p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_stream_status      IN  OKL_STREAMS.SAY_CODE%TYPE
                              );

END OKL_CONTRACT_REBOOK_PUB;

 

/
