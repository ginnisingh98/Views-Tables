--------------------------------------------------------
--  DDL for Package OKL_AMORT_SCHED_REQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AMORT_SCHED_REQ_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAMRS.pls 120.2 2008/02/01 18:56:52 srsreeni noship $ */
	G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AMORT_SCHED_REQ_PVT';
	G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
	G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
	G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
	G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
    PROCEDURE process_trx_request(p_chr_id in okc_k_headers_b.id%type,p_api_version IN NUMBER,
								  p_init_msg_list IN VARCHAR2 DEFAULT OKL_API.G_FALSE,p_comments in varchar2 default null,p_user_id in number,
								  x_return_status OUT NOCOPY VARCHAR2,x_msg_count OUT NOCOPY NUMBER,
                                  x_msg_data OUT NOCOPY VARCHAR2,x_trx_req_id OUT NOCOPY okl_trx_requests.id%type,x_summ_flag OUT NOCOPY BOOLEAN);
END OKL_AMORT_SCHED_REQ_PVT;

/
