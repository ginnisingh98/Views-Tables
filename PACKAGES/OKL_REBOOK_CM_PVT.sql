--------------------------------------------------------
--  DDL for Package OKL_REBOOK_CM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REBOOK_CM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCMRS.pls 120.2 2005/10/30 04:32:19 appldev noship $ */

  G_PKG_NAME	CONSTANT VARCHAR2(30)  := 'OKL_STREAM_BILLING_PVT';

  TYPE rebook_adj_rec_type IS RECORD (
    khr_id                         NUMBER := Okl_Api.G_MISS_NUM,
    kle_id                         NUMBER := Okl_Api.G_MISS_NUM,
    sty_id                         NUMBER := Okl_Api.G_MISS_NUM,
    adjusted_amount				   NUMBER := Okl_Api.G_MISS_NUM,
    date_invoiced                  OKL_TRX_AR_INVOICES_B.DATE_INVOICED%TYPE := Okl_Api.G_MISS_DATE);

  TYPE rebook_adj_tbl_type IS TABLE OF rebook_adj_rec_type
        INDEX BY BINARY_INTEGER;

  PROCEDURE CM_Bill_adjustments
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,p_contract_number	IN  VARCHAR2	DEFAULT NULL
    );

  PROCEDURE CM_Bill_adjustments_conc
    (errbuf  OUT NOCOPY VARCHAR2
    ,retcode OUT NOCOPY NUMBER
    ,p_contract_number  IN VARCHAR2
    );

  PROCEDURE CM_Bill_adjustments
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data			OUT NOCOPY VARCHAR2
	,p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_rebook_adj_tbl	IN  rebook_adj_tbl_type
    );

  PROCEDURE Rebook_Bill_adjustments
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_rebook_adj_tbl	IN  rebook_adj_tbl_type
    );

END OKL_REBOOK_CM_PVT;

 

/
