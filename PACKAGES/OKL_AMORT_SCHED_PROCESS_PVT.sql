--------------------------------------------------------
--  DDL for Package OKL_AMORT_SCHED_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AMORT_SCHED_PROCESS_PVT" AUTHID CURRENT_USER as
 /* $Header: OKLRLAMS.pls 120.3 2008/02/20 00:48:17 srsreeni noship $ */
	G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AMORT_SCHED_PROCESS_PVT';
	G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
	G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
	G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
	G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
	G_REPORT_TYPE_SUMMARY  CONSTANT VARCHAR2(50) := 'SUMMARY';
	G_REPORT_TYPE_DETAIL   CONSTANT VARCHAR2(50) := 'DETAIL';
	G_REPORT_TYPE_SUMMARY_C  CONSTANT VARCHAR2(50) := 'S';
	G_REPORT_TYPE_DETAIL_C   CONSTANT VARCHAR2(50) := 'D';
	G_PRINCIPAL_TYPE	   CONSTANT VARCHAR2(30) := 'PRINCIPAL';
	G_INTEREST_TYPE	   CONSTANT VARCHAR2(30) := 'INTEREST';
	G_PRINCIPAL_BAL_TYPE	   CONSTANT VARCHAR2(30) := 'PRINCIPAL_BALANCE';
	G_LOAN_PAYMENT	   CONSTANT VARCHAR2(30) := 'LOAN_PAYMENT';
	G_DATE_FROM	   CONSTANT VARCHAR2(30) := 'DATE_FROM';
	G_DATE_TO	   CONSTANT VARCHAR2(30) := 'DATE_TO';
	G_PERIOD		CONSTANT VARCHAR2(30) := 'PERIOD';
	G_PAST_PROJ	CONSTANT VARCHAR2(20) := 'PAST_OR_PROJECTED';
	G_PROJ_INTEREST_RATE CONSTANT VARCHAR2(20) := 'PROJ_INTEREST_RATE';
	G_ORDER_BY CONSTANT VARCHAR2(20) := 'ORDER_BY';
	G_SUMM_COLUMNS CONSTANT number := 7;
	G_DET_COLUMNS CONSTANT number := 8;
	g_user_id	number := -1;
 ------------------------------------------------------------------------------
 -- Record Type
 ------------------------------------------------------------------------------
    TYPE amort_hdr_id_rec_type IS RECORD (
    	pri_summ_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
  		pri_det_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
  		int_summ_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
  		int_det_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
  		pri_bal_summ_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
  		pri_bal_det_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
    	loan_pymnt_summ_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
  		loan_pymnt_det_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
  		date_from_summ_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
  		date_from_det_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
  		date_to_summ_id  OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
		proj_interest_rate_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
  	--	pastproj_summ_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
  		pastproj_det_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
  		order_by_summ_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type,
  		order_by_det_id OKL_AMORT_SCHED_HDRS.amort_hdr_id%type
    );

    TYPE amort_hdr_id_tbl_type is table of amort_hdr_id_rec_type INDEX BY BINARY_INTEGER;
  	TYPE amort_line_id is table of number;
    procedure generate_amor_sched(p_chr_id in okc_k_headers_b.id%type,p_api_version IN NUMBER,
								  p_init_msg_list IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
								  p_trx_req_id in okl_trx_requests.id%type,
								  p_user_id in number,
								  x_return_status OUT NOCOPY VARCHAR2,x_msg_count OUT NOCOPY NUMBER,
								  x_msg_data OUT NOCOPY VARCHAR2,x_summ_flag OUT boolean);
        procedure delete_old_sched(p_api_version IN  NUMBER,p_init_msg_list IN
VARCHAR2,x_return_status OUT NOCOPY VARCHAR2,
                                                           x_msg_count OUT
NOCOPY NUMBER,x_msg_data OUT NOCOPY VARCHAR2,p_chr_id in
okc_k_headers_b.id%type,
                                                           p_req_id in
okl_trx_requests.id%type);
end OKL_AMORT_SCHED_PROCESS_PVT;

/
