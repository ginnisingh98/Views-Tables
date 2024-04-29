--------------------------------------------------------
--  DDL for Package OKL_INVESTOR_INVOICE_DISB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INVESTOR_INVOICE_DISB_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRIDBS.pls 115.4 2003/11/21 22:35:05 stmathew noship $ */
 ------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_INVESTOR_INVOICE_DISB_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

 ---------------------------------------------------------------------------
 -- Procedures and Functions
 ---------------------------------------------------------------------------
PROCEDURE OKL_INVESTOR_DISBURSEMENT
    (p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
    ,p_investor_agreement  IN  VARCHAR2	DEFAULT NULL
	,p_to_date		    IN  DATE	DEFAULT NULL);

FUNCTION get_disb_amt(p_ia_id      NUMBER
                     ,p_rbk_khr_id NUMBER
                     ,p_rbk_kle_id NUMBER)
         RETURN NUMBER;

END OKL_INVESTOR_INVOICE_DISB_PVT;

 

/
