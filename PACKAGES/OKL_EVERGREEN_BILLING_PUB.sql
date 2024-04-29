--------------------------------------------------------
--  DDL for Package OKL_EVERGREEN_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_EVERGREEN_BILLING_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPEGBS.pls 115.4 2003/01/31 18:04:40 stmathew noship $ */

  G_PKG_NAME	CONSTANT VARCHAR2(30)  := 'OKL_EVERGREEN_BILLING_PUB';

  PROCEDURE bill_evg_streams_conc (
                errbuf  OUT NOCOPY VARCHAR2 ,
                retcode OUT NOCOPY NUMBER,
                p_from_bill_date  IN VARCHAR2,
                p_to_bill_date  IN VARCHAR2,
                p_contract_number  IN VARCHAR2
                );

  PROCEDURE bill_evg_streams
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,p_contract_number	IN  VARCHAR2	DEFAULT NULL
	,p_from_bill_date	IN  DATE	DEFAULT NULL
	,p_to_bill_date		IN  DATE	DEFAULT NULL);

END Okl_Evergreen_Billing_Pub;

 

/
