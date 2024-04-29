--------------------------------------------------------
--  DDL for Package OKL_BPD_ADVANCED_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BPD_ADVANCED_BILLING_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPABLS.pls 120.2 2005/10/30 04:01:17 appldev noship $ */

  G_PKG_NAME	CONSTANT VARCHAR2(30)  := 'OKL_BPD_ADVANCED_BILLING_PUB';

 SUBTYPE ar_inv_rec_type is OKL_BPD_ADVANCED_BILLING_PVT.ar_inv_rec_type;
 SUBTYPE ar_inv_tbl_type is OKL_BPD_ADVANCED_BILLING_PVT.ar_inv_tbl_type;


  PROCEDURE advanced_billing_conc  (
                errbuf            OUT NOCOPY VARCHAR2 ,
                retcode           OUT NOCOPY NUMBER,
                p_from_bill_date  IN VARCHAR2,
                p_to_bill_date    IN VARCHAR2,
                p_contract_number IN VARCHAR2
                );

  PROCEDURE advanced_billing
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
    );

END OKL_BPD_ADVANCED_BILLING_PUB;

 

/
