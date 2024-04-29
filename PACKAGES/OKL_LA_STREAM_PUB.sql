--------------------------------------------------------
--  DDL for Package OKL_LA_STREAM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LA_STREAM_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPSGAS.pls 120.2 2006/04/20 15:27:05 kthiruva noship $ */


  subtype yields_rec_type is OKL_LA_STREAM_PVT.yields_rec_type;

-- Global variables for user hooks
  G_PKG_NAME   CONSTANT VARCHAR2(200) := 'OKL_LA_STREAM_PUB';
  G_APP_NAME   CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;


  Procedure generate_streams(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            p_chr_id             IN  VARCHAR2,
            p_generation_context IN  VARCHAR2,
            p_skip_prc_engine    IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            x_request_id         OUT NOCOPY NUMBER,
            x_trans_status       OUT NOCOPY VARCHAR2);

  Procedure update_contract_yields(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2,
            p_chr_yields      IN  yields_rec_type);

  Procedure extract_params_lease(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_chr_id          IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            x_csm_lease_header          OUT NOCOPY okl_create_streams_pub.csm_lease_rec_type,
            x_csm_one_off_fee_tbl       OUT NOCOPY okl_create_streams_pub.csm_one_off_fee_tbl_type,
            x_csm_periodic_expenses_tbl OUT NOCOPY okl_create_streams_pub.csm_periodic_expenses_tbl_type,
            x_csm_yields_tbl            OUT NOCOPY okl_create_streams_pub.csm_yields_tbl_type,
            x_req_stream_types_tbl      OUT NOCOPY okl_create_streams_pub.csm_stream_types_tbl_type,
            x_csm_line_details_tbl      OUT NOCOPY okl_create_streams_pub.csm_line_details_tbl_type,
            x_rents_tbl                 OUT NOCOPY okl_create_streams_pub.csm_periodic_expenses_tbl_type);

  Procedure extract_params_loan(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_chr_id          IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            x_csm_loan_header           OUT NOCOPY okl_create_streams_pvt.csm_loan_rec_type,
            x_csm_loan_lines_tbl        OUT NOCOPY okl_create_streams_pvt.csm_loan_line_tbl_type,
            x_csm_loan_levels_tbl       OUT NOCOPY okl_create_streams_pvt.csm_loan_level_tbl_type,
            x_csm_one_off_fee_tbl       OUT NOCOPY okl_create_streams_pub.csm_one_off_fee_tbl_type,
            x_csm_periodic_expenses_tbl OUT NOCOPY okl_create_streams_pub.csm_periodic_expenses_tbl_type,
            x_csm_yields_tbl            OUT NOCOPY okl_create_streams_pub.csm_yields_tbl_type,
            x_csm_stream_types_tbl      OUT NOCOPY okl_create_streams_pub.csm_stream_types_tbl_type);

 Procedure GEN_INTR_EXTR_STREAM (
            p_api_version         IN NUMBER,
            p_init_msg_list       IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status       OUT NOCOPY VARCHAR2,
            x_msg_count           OUT NOCOPY NUMBER,
            x_msg_data            OUT NOCOPY VARCHAR2,
            p_khr_id              IN  OKC_K_HEADERS_B.ID%TYPE,
            p_generation_ctx_code IN  VARCHAR2,
            x_trx_number          OUT NOCOPY NUMBER,
            x_trx_status          OUT NOCOPY VARCHAR2);

  Procedure extract_params_loan_paydown(
            p_api_version                IN  NUMBER,
            p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_chr_id                     IN  VARCHAR2,
            p_deal_type                  IN VARCHAR2,
	    p_paydown_type               IN  VARCHAR2,
	    p_paydown_date               IN  DATE,
	    p_paydown_amount             IN  NUMBER,
            p_balance_type_code          IN  VARCHAR2,
            x_return_status              OUT NOCOPY VARCHAR2,
            x_msg_count                  OUT NOCOPY NUMBER,
            x_msg_data                   OUT NOCOPY VARCHAR2,
            x_csm_loan_header            OUT NOCOPY okl_create_streams_pvt.csm_loan_rec_type,
            x_csm_loan_lines_tbl         OUT NOCOPY okl_create_streams_pvt.csm_loan_line_tbl_type,
            x_csm_loan_levels_tbl        OUT NOCOPY okl_create_streams_pvt.csm_loan_level_tbl_type,
            x_csm_one_off_fee_tbl        OUT NOCOPY okl_create_streams_pub.csm_one_off_fee_tbl_type,
            x_csm_periodic_expenses_tbl  OUT NOCOPY okl_create_streams_pub.csm_periodic_expenses_tbl_type,
            x_csm_yields_tbl             OUT NOCOPY okl_create_streams_pub.csm_yields_tbl_type,
            x_csm_stream_types_tbl       OUT NOCOPY okl_create_streams_pub.csm_stream_types_tbl_type);

  --Added by kthiruva for bug 5161075
  Procedure extract_params_loan_reamort(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_chr_id          IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            x_csm_loan_header           OUT NOCOPY okl_create_streams_pvt.csm_loan_rec_type,
            x_csm_loan_lines_tbl        OUT NOCOPY okl_create_streams_pvt.csm_loan_line_tbl_type,
            x_csm_loan_levels_tbl       OUT NOCOPY okl_create_streams_pvt.csm_loan_level_tbl_type,
            x_csm_one_off_fee_tbl       OUT NOCOPY okl_create_streams_pub.csm_one_off_fee_tbl_type,
            x_csm_periodic_expenses_tbl OUT NOCOPY okl_create_streams_pub.csm_periodic_expenses_tbl_type,
            x_csm_yields_tbl            OUT NOCOPY okl_create_streams_pub.csm_yields_tbl_type,
            x_csm_stream_types_tbl      OUT NOCOPY okl_create_streams_pub.csm_stream_types_tbl_type);

End OKL_LA_STREAM_PUB;

/
