--------------------------------------------------------
--  DDL for Package OKL_PAY_INVOICES_DISB_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAY_INVOICES_DISB_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPIDS.pls 120.1 2005/06/03 23:18:13 pjgomes noship $ */

 ------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------

 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_PAY_INVOICES_DISB_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

 ---------------------------------------------------------------------------
 -- Procedures and Functions
 ---------------------------------------------------------------------------

PROCEDURE auto_disbursement(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_from_date	    IN  DATE	DEFAULT NULL
	,p_to_date		    IN  DATE	DEFAULT NULL
  ,p_contract_number IN VARCHAR2);

PROCEDURE auto_disbursement
    (errbuf	 OUT NOCOPY  VARCHAR2
    ,retcode OUT NOCOPY  NUMBER
    ,p_from_date IN  VARCHAR2	DEFAULT NULL
    ,p_to_date	 IN  VARCHAR2	DEFAULT NULL
    ,p_contract_number IN VARCHAR2 DEFAULT NULL);

END; -- Package spec

 

/
