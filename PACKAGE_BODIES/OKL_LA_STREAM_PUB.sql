--------------------------------------------------------
--  DDL for Package Body OKL_LA_STREAM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LA_STREAM_PUB" as
/* $Header: OKLPSGAB.pls 120.4 2006/04/20 15:27:22 kthiruva noship $ */

-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_NO_PARENT_RECORD    CONSTANT  VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_FND_APP		        CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_REQUIRED_VALUE	    CONSTANT  VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT  VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR    CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN       CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN       CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED	CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UPPERCASE_REQ';
  G_COL_NAME_TOKEN      CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                CONSTANT  VARCHAR2(4) := '_PUB';
  G_API_VERSION             CONSTANT  NUMBER      := 1.0;
  G_SCOPE                   CONSTANT  VARCHAR2(4) := '_PUB';

 -- GLOBAL VARIABLES
-----------------------------------------------------------------------------------

  Procedure allocate_streams(
            p_api_version   IN NUMBER,
            p_init_msg_list IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_count     OUT NOCOPY NUMBER,
            x_msg_data      OUT NOCOPY VARCHAR2,
            p_chr_id        IN  NUMBER)  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'ALLOCATE_STREAMS';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
    l_chr_id NUMBER := p_chr_id;

  BEGIN

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;




    OKL_LA_STREAM_PVT.allocate_streams(
                             p_api_version,
                             p_init_msg_list,
                             x_return_status,
                             x_msg_count,
                             x_msg_data,
                             p_chr_id);


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;




    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    Exception
	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END allocate_streams;

 Procedure GEN_INTR_EXTR_STREAM (
            p_api_version         IN NUMBER,
            p_init_msg_list       IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status       OUT NOCOPY VARCHAR2,
            x_msg_count           OUT NOCOPY NUMBER,
            x_msg_data            OUT NOCOPY VARCHAR2,
            p_khr_id              IN  OKC_K_HEADERS_B.ID%TYPE,
            p_generation_ctx_code IN  VARCHAR2,
            x_trx_number          OUT NOCOPY NUMBER,
            x_trx_status          OUT NOCOPY VARCHAR2) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'GEN_STREAM_PUB';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;





    OKL_LA_STREAM_PVT.GEN_INTR_EXTR_STREAM (
                         p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_khr_id,
                         p_generation_ctx_code,
                         x_trx_number,
                         x_trx_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    Exception
	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END GEN_INTR_EXTR_STREAM;

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
            x_trans_status       OUT NOCOPY VARCHAR2) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'MAP_AND_GEN_STREAMS';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_chr_id NUMBER := p_chr_id;
    l_generation_context VARCHAR2(256) := p_generation_context;
    l_skip_prc_engine VARCHAR2(1) := p_skip_prc_engine;

  BEGIN

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;





    OKL_LA_STREAM_PVT.generate_streams(
                     p_api_version,
                     p_init_msg_list,
                     p_chr_id,
                     p_generation_context,
                     p_skip_prc_engine,
                     x_return_status,
                     x_msg_count,
                     x_msg_data,
                     x_request_id,
                     x_trans_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    Exception
	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END generate_streams;


  Procedure update_contract_yields(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2,
            p_chr_yields      IN  yields_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_YIELDS';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_chr_id VARCHAR2(256) := p_chr_id;
    l_chr_yields yields_rec_type := p_chr_yields;

  begin

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;



    OKL_LA_STREAM_PVT.update_contract_yields(
                     p_api_version,
                     p_init_msg_list,
                     x_return_status,
                     x_msg_count,
                     x_msg_data,
                     p_chr_id,
                     p_chr_yields);


    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    Exception
	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  end update_contract_yields;



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
            x_rents_tbl                 OUT NOCOPY okl_create_streams_pub.csm_periodic_expenses_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'LEASE_PARAMS';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_chr_id VARCHAR2(256) := p_chr_id;

  begin

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;



    OKL_LA_STREAM_PVT.extract_params_lease(
                                p_api_version,
                                p_init_msg_list,
                                p_chr_id,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                x_csm_lease_header,
                                x_csm_one_off_fee_tbl,
                                x_csm_periodic_expenses_tbl,
                                x_csm_yields_tbl,
                                x_req_stream_types_tbl,
                                x_csm_line_details_tbl,
                                x_rents_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    Exception
	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  end extract_params_lease;

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
            x_csm_stream_types_tbl      OUT NOCOPY okl_create_streams_pub.csm_stream_types_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'LOAN_PARAMS';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_chr_id VARCHAR2(256) := p_chr_id;

  begin

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;



    OKL_LA_STREAM_PVT.extract_params_loan(
                                p_api_version,
                                p_init_msg_list,
                                p_chr_id,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                x_csm_loan_header,
                                x_csm_loan_lines_tbl,
                                x_csm_loan_levels_tbl,
                                x_csm_one_off_fee_tbl,
                                x_csm_periodic_expenses_tbl,
                                x_csm_yields_tbl,
                                x_csm_stream_types_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    Exception
	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  end extract_params_loan;

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
            x_csm_stream_types_tbl       OUT NOCOPY okl_create_streams_pub.csm_stream_types_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'EXTRACT_PARAMS_LOAN_PPD';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_chr_id VARCHAR2(256) := p_chr_id;

  begin

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;



    OKL_LA_STREAM_PVT.extract_params_loan_paydown(
                               p_api_version     ,
                               p_init_msg_list   ,
                               p_chr_id          ,
                               p_deal_type       ,
                               p_paydown_type    ,
                               p_paydown_date    ,
                               p_paydown_amount  ,
                               p_balance_type_code,
                               x_return_status   ,
                               x_msg_count       ,
                               x_msg_data        ,
                               x_csm_loan_header ,
                               x_csm_loan_lines_tbl,
			       x_csm_loan_levels_tbl,
			       x_csm_one_off_fee_tbl ,
			       x_csm_periodic_expenses_tbl,
			       x_csm_yields_tbl,
			       x_csm_stream_types_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    Exception
	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  end extract_params_loan_paydown;

  --Added by kthiruva for Bug 5161075
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
            x_csm_stream_types_tbl      OUT NOCOPY okl_create_streams_pub.csm_stream_types_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'LOAN_PARAMS';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_chr_id VARCHAR2(256) := p_chr_id;

  begin

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;



    OKL_LA_STREAM_PVT.extract_params_loan_reamort(
                                p_api_version,
                                p_init_msg_list,
                                p_chr_id,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                x_csm_loan_header,
                                x_csm_loan_lines_tbl,
                                x_csm_loan_levels_tbl,
                                x_csm_one_off_fee_tbl,
                                x_csm_periodic_expenses_tbl,
                                x_csm_yields_tbl,
                                x_csm_stream_types_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    Exception
	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  end extract_params_loan_reamort;


End OKL_LA_STREAM_PUB;

/
