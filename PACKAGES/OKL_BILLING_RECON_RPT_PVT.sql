--------------------------------------------------------
--  DDL for Package OKL_BILLING_RECON_RPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BILLING_RECON_RPT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRBRES.pls 115.0 2004/01/13 19:15:11 stmathew noship $ */

--  G_PKG_NAME	CONSTANT VARCHAR2(30)  := 'OKL_BILLING_RECON_RPT_PVT';
  G_PKG_NAME	CONSTANT VARCHAR2(30)  := 'SS';

  PROCEDURE recon_report
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_contract_number	IN  VARCHAR2	DEFAULT NULL
	,p_from_bill_date	IN  DATE	DEFAULT NULL
	,p_to_bill_date		IN  DATE	DEFAULT NULL);

  PROCEDURE recon_report_conc
    (errbuf             OUT NOCOPY VARCHAR2
    ,retcode            OUT NOCOPY NUMBER
    ,p_from_bill_date   IN VARCHAR2
    ,p_to_bill_date     IN VARCHAR2
    ,p_contract_number  IN VARCHAR2);


END OKL_BILLING_RECON_RPT_PVT;

 

/
