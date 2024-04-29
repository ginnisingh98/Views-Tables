--------------------------------------------------------
--  DDL for Package OKL_INVESTOR_INVOICE_DISB_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INVESTOR_INVOICE_DISB_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPIDBS.pls 115.3 2004/04/21 22:03:28 stmathew noship $ */

 ------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------

 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_INVESTOR_INVOICE_DISB_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

 ---------------------------------------------------------------------------
 -- Procedures and Functions
 ---------------------------------------------------------------------------

PROCEDURE OKL_INVESTOR_DISBURSEMENT
        (errbuf	 OUT NOCOPY  VARCHAR2
	    ,retcode OUT NOCOPY  NUMBER
	    ,p_investor_agreement  IN  VARCHAR2	DEFAULT NULL
	    ,p_to_date		    IN  VARCHAR2	DEFAULT NULL);

END OKL_INVESTOR_INVOICE_DISB_PUB;

 

/
