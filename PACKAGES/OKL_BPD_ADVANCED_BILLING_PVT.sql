--------------------------------------------------------
--  DDL for Package OKL_BPD_ADVANCED_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BPD_ADVANCED_BILLING_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRABLS.pls 120.4 2008/04/10 11:33:55 dkagrawa ship $ */

  G_PKG_NAME	CONSTANT VARCHAR2(30)  := 'OKL_BPD_ADVANCED_BILLING_PVT';

  TYPE ar_inv_rec_type IS RECORD (
    receivables_invoice_id   ra_customer_trx_all.customer_trx_id%TYPE);

  TYPE ar_inv_tbl_type IS TABLE OF ar_inv_rec_type
        INDEX BY BINARY_INTEGER;

  PROCEDURE ADVANCED_BILLING
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_contract_number	IN  VARCHAR2	DEFAULT NULL
	,p_from_bill_date	IN  DATE	DEFAULT NULL
	,p_to_bill_date		IN  DATE	DEFAULT NULL
    ,p_source           IN  VARCHAR2 DEFAULT 'STREAM_BILLING'
    ,x_ar_inv_tbl       OUT NOCOPY ar_inv_tbl_type
    ,p_ppd_flow         IN VARCHAR2 DEFAULT 'N'
 );

END OKL_BPD_ADVANCED_BILLING_PVT;

/
