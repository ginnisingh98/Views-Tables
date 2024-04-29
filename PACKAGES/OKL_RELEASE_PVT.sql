--------------------------------------------------------
--  DDL for Package OKL_RELEASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RELEASE_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRREKS.pls 120.4 2006/03/01 19:05:09 rpillay noship $ */

  subtype chrv_rec_type is OKL_OKC_MIGRATION_PVT.CHRV_REC_TYPE;
  subtype khrv_rec_type is OKL_CONTRACT_PUB.KHRV_REC_TYPE;

  --Bug 3948361
  subtype tcnv_rec_type      IS OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;

  --Bug 3948361
  Procedure create_release_contract(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_chr_id               IN  OKC_K_HEADERS_B.ID%TYPE,
            p_release_reason_code  IN  VARCHAR2,
            p_release_description  IN  VARCHAR2,
            p_trx_date             IN  DATE,
            p_source_trx_id        IN  NUMBER,
            p_source_trx_type      IN  VARCHAR2,
            x_tcnv_rec             OUT NOCOPY tcnv_rec_type,
            x_release_chr_id       OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE);

  PROCEDURE activate_release_contract(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_chr_id             IN  OKC_K_HEADERS_B.ID%TYPE);

  --Bug# 4072796
  PROCEDURE validate_release_contract(p_api_version   IN  NUMBER,
                                      p_init_msg_list IN  VARCHAR2,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_count     OUT NOCOPY NUMBER,
                                      x_msg_data      OUT NOCOPY VARCHAR2,
                                      p_chr_id        IN  NUMBER,
                                      p_release_date  IN  DATE,
                                      p_source_trx_id IN  NUMBER,
                                      p_call_program  IN  VARCHAR2);

  --Bug# 4631549
  PROCEDURE Calculate_expected_cost
            (p_api_version    IN  NUMBER,
             p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
             x_return_status  OUT NOCOPY VARCHAR2,
             x_msg_count      OUT NOCOPY NUMBER,
             x_msg_data       OUT NOCOPY VARCHAR2,
             p_new_chr_id     IN  NUMBER,
             p_orig_chr_id    IN  NUMBER,
             p_orig_cle_id    IN  NUMBER,
             p_asset_id       IN  NUMBER,
             p_book_type_code IN  VARCHAR2,
             p_nbv            IN  NUMBER,
             p_release_date   IN  DATE,
             x_expected_cost  OUT NOCOPY NUMBER);
End okl_release_pvt;

/
