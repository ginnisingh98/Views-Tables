--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_REBOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_REBOOK_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRRBKS.pls 120.5.12010000.2 2008/10/20 18:37:56 apaul ship $*/

  G_INVALID_VALUE            CONSTANT VARCHAR2(1000) := 'OKL_INVALID_VALUE';
  G_UNEXPECTED_ERROR         CONSTANT VARCHAR2(1000) := 'OKL_UNEXPECTED_ERROR';
  G_LLA_CHR_ID               CONSTANT VARCHAR2(1000) := 'OKL_LLA_CHR_ID';
  G_LLA_NO_ORIG_REFERENCE    CONSTANT VARCHAR2(1000) := 'OKL_LLA_NO_ORIG_REFERENCE';
  G_LLA_NO_STREAM            CONSTANT VARCHAR2(1000) := 'OKL_LLA_NO_STREAM';
  G_LLA_NO_STREAM_ELEMENT    CONSTANT VARCHAR2(1000) := 'OKL_LLA_NO_STREAM_ELEMENT';

  subtype tcnv_rec_type      IS OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;

  PROCEDURE Report_Error(
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2
                        );

  PROCEDURE sync_rebook_orig_contract(
                                      p_api_version        IN  NUMBER,
                                      p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                      x_return_status      OUT NOCOPY VARCHAR2,
                                      x_msg_count          OUT NOCOPY NUMBER,
                                      x_msg_data           OUT NOCOPY VARCHAR2,
                                      p_rebook_chr_id      IN  OKC_K_HEADERS_V.ID%TYPE
                                     );

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

  PROCEDURE sync_rebook_stream(
                               p_api_version        IN  NUMBER,
                               p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER,
                               x_msg_data           OUT NOCOPY VARCHAR2,
                               p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_stream_status      IN  OKL_STREAMS.SAY_CODE%TYPE
                              );

  PROCEDURE create_rebook_contract(
                                   p_api_version        IN  NUMBER,
                                   p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_msg_count          OUT NOCOPY NUMBER,
                                   x_msg_data           OUT NOCOPY VARCHAR2,
                                   p_from_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                                   x_rebook_chr_id      OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE,
                                   p_rbk_date           IN  DATE DEFAULT NULL
                                  );

  --Bug# 4212626: start
  PROCEDURE link_streams(
                         p_api_version     IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_khr_id          IN  NUMBER
                         );

  PROCEDURE create_billing_adjustment(
                         p_api_version     IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_rbk_khr_id      IN  NUMBER,
                         p_orig_khr_id     IN  NUMBER,
                         p_trx_id          IN  NUMBER,
                         p_trx_date        IN  DATE
                         );


-- dedey, Bug#4264314
/*
 *
  PROCEDURE create_accrual_adjustment(
                         p_api_version     IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_rbk_khr_id      IN  NUMBER,
                         p_orig_khr_id     IN  NUMBER,
                         p_trx_id          IN  NUMBER,
                         p_trx_date        IN  DATE
                         );
  --Bug# 4212626: end
*/

  --Added new input parameters p_trx_tbl_code and p_trx_type by for Bug# 6344223
  PROCEDURE calc_accrual_adjustment(
                           p_api_version     IN  NUMBER,
                           p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                           x_return_status   OUT NOCOPY VARCHAR2,
                           x_msg_count       OUT NOCOPY NUMBER,
                           x_msg_data        OUT NOCOPY VARCHAR2,
                           p_rbk_khr_id      IN  NUMBER,
                           p_orig_khr_id     IN  NUMBER,
                           p_trx_id          IN  NUMBER,
                           p_trx_date        IN  DATE,
                           x_accrual_rec     OUT NOCOPY OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type,
                           x_stream_tbl      OUT NOCOPY OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type,
                           p_trx_tbl_code    IN  VARCHAR2 DEFAULT 'TCN',
                           p_trx_type        IN  VARCHAR2 DEFAULT 'CRB'
                         );
-- dedey, Bug#4264314

-- Bug# 4775555: Start
  PROCEDURE create_inv_disb_adjustment(
                         p_api_version     IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_orig_khr_id     IN  NUMBER
                         ) ;

  PROCEDURE link_inv_accrual_streams(
                         p_api_version     IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_khr_id          IN  NUMBER
                         ) ;

  --Added new input parameters p_trx_tbl_code and p_trx_type for Bug# 6344223
  PROCEDURE calc_inv_acc_adjustment(
                         p_api_version     IN  NUMBER,
                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_orig_khr_id     IN  NUMBER,
                         p_trx_id          IN  NUMBER,
                         p_trx_date        IN  DATE,
                         x_inv_accrual_rec OUT NOCOPY OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type,
                         x_inv_stream_tbl  OUT NOCOPY OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type,
                         p_trx_tbl_code    IN  VARCHAR2 DEFAULT 'TCN',
                         p_trx_type        IN  VARCHAR2 DEFAULT 'CRB',
                         p_product_id      IN  NUMBER   DEFAULT  NULL -- MGAAP
                         ) ;
-- Bug# 4775555: End

END OKL_CONTRACT_REBOOK_PVT;

/
