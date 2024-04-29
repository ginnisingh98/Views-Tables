--------------------------------------------------------
--  DDL for Package OKL_RELEASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RELEASE_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPREKS.pls 120.2 2005/10/30 03:33:48 appldev noship $ */

  subtype chrv_rec_type is OKL_OKC_MIGRATION_PVT.CHRV_REC_TYPE;
  subtype khrv_rec_type is OKL_CONTRACT_PUB.KHRV_REC_TYPE;
  g_chrv_rec               chrv_rec_type;
  g_khrv_rec               khrv_rec_type;

 --Bug 3948361
  subtype tcnv_rec_type      IS OKL_RELEASE_PVT.tcnv_rec_type;


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


End OKL_RELEASE_PUB;

 

/
