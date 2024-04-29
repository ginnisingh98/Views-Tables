--------------------------------------------------------
--  DDL for Package OKL_TRANSACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRANSACTION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTXNS.pls 120.3 2007/06/06 15:51:17 akrangan ship $*/

  G_INVALID_VALUE            CONSTANT VARCHAR2(1000) := 'OKL_INVALID_VALUE';
  G_UNEXPECTED_ERROR         CONSTANT VARCHAR2(1000) := 'OKL_UNEXPECTED_ERROR';
  G_LLA_CHR_ID               CONSTANT VARCHAR2(1000) := 'OKL_LLA_CHR_ID';
  G_LLA_NO_TRY               CONSTANT VARCHAR2(1000) := 'OKL_LLA_NO_TRY';
  G_LLA_INVALID_TRX_TYPE     CONSTANT VARCHAR2(1000) := 'OKL_LLA_INVALID_TRX_TYPE';
  G_LLA_MISSING_TRX_DATE     CONSTANT VARCHAR2(1000) := 'OKL_LLA_MISSING_TRX_DATE';
  G_LLA_WRONG_TRX_DATE       CONSTANT VARCHAR2(1000) := 'OKL_LLA_WRONG_TRX_DATE';   -- Bug# 2504598
  G_LLA_SECU_ERROR           CONSTANT VARCHAR2(1000) := 'OKL_LLA_SECU_ERROR';

  subtype tcnv_rec_type      IS OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;
  subtype inv_agmt_chr_id_tbl_type IS okl_securitization_pvt.inv_agmt_chr_id_tbl_type;

  -------------------------------------------------

  TYPE rev_rec_type IS RECORD (
      chr_id                         OKC_K_HEADERS_V.ID%TYPE := OKC_API.G_MISS_NUM
      );

    TYPE rev_tbl_type     IS TABLE OF rev_rec_type     INDEX BY BINARY_INTEGER;

  subtype chrv_rec_type is OKL_OKC_MIGRATION_PVT.chrv_rec_type;
  subtype khrv_rec_type is OKL_CONTRACT_PUB.khrv_rec_type;
  ----------------------------------------------------

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
                              p_tsu_code           IN  VARCHAR2,
                               --akrangan added for ebtax rebook changes starts
			      p_source_trx_id      IN  NUMBER DEFAULT NULL ,
			      p_source_trx_name    IN  VARCHAR2 DEFAULT NULL
			       --akrangan added for ebtax rebook changes ends
                             );

  PROCEDURE check_contract_securitized(
                                 p_api_version        IN  NUMBER,
                                 p_init_msg_list      IN  VARCHAR2,
                                 x_return_status      OUT NOCOPY VARCHAR2,
                                 x_msg_count          OUT NOCOPY NUMBER,
                                 x_msg_data           OUT NOCOPY VARCHAR2,
                                 p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                                 p_trx_date           IN  DATE
                                );

  PROCEDURE check_contract_securitized(
                                 p_api_version        IN  NUMBER,
                                 p_init_msg_list      IN  VARCHAR2,
                                 x_return_status      OUT NOCOPY VARCHAR2,
                                 x_msg_count          OUT NOCOPY NUMBER,
                                 x_msg_data           OUT NOCOPY VARCHAR2,
                                 p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                                 p_cle_id             IN  OKC_K_LINES_V.ID%TYPE,
                                 p_stream_type_class  IN  okl_strm_type_b.stream_type_subclass%TYPE,
                                 p_trx_date           IN  DATE
                                );

  PROCEDURE create_service_transaction(
                          p_api_version        IN  NUMBER,
                          p_init_msg_list      IN  VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2,
                          p_lease_id           IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_service_id         IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_description        IN  VARCHAR2,
                          p_trx_date           IN  DATE,
                          p_status             IN  VARCHAR2,
                          x_tcnv_rec           OUT NOCOPY tcnv_rec_type
                         );

  PROCEDURE create_ppd_transaction(
                          p_api_version        IN  NUMBER,
                          p_init_msg_list      IN  VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2,
                          p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_trx_date           IN  DATE,
                          p_trx_type           IN  VARCHAR2,
                          p_reason_code        IN  VARCHAR2,
                          x_tcnv_rec           OUT NOCOPY tcnv_rec_type
                         );
END OKL_TRANSACTION_PVT;

/
