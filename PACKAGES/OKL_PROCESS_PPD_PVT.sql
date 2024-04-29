--------------------------------------------------------
--  DDL for Package OKL_PROCESS_PPD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROCESS_PPD_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPPNS.pls 120.1 2005/10/30 04:02:38 appldev noship $*/

  G_UNEXPECTED_ERROR         CONSTANT VARCHAR2(1000) := 'OKL_UNEXPECTED_ERROR';

  PROCEDURE apply_ppd
   (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
    p_kle_tbl            IN  OKL_MASS_REBOOK_PVT.kle_tbl_type,
    p_transaction_date   IN  OKL_TRX_CONTRACTS.DATE_TRANSACTION_OCCURRED%TYPE,
    p_ppd_amount         IN  NUMBER,
    p_ppd_reason_code    IN  FND_LOOKUPS.LOOKUP_CODE%TYPE,
    p_payment_struc      IN  okl_mass_rebook_pvt.strm_lalevl_tbl_type,
    --p_ppd_payment_struc  IN  okl_mass_rebook_pvt.strm_lalevl_tbl_type,
    p_ppd_txn_id         IN  NUMBER
   );

END OKL_PROCESS_PPD_PVT;

 

/
