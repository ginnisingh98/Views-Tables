--------------------------------------------------------
--  DDL for Package OKL_BPD_CREDIT_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BPD_CREDIT_CHECK_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCCFS.pls 120.2 2005/10/30 03:16:09 appldev noship $ */
 ------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_BPD_CREDIT_CHECK_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

 ---------------------------------------------------------------------------
 -- Procedures and Functions
 ---------------------------------------------------------------------------

 --function to return the credit amount available for a customer
 FUNCTION credit_check(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_creditline_id   IN  NUMBER
	,p_credit_max       IN  NUMBER
    ,P_trx_date         IN DATE DEFAULT SYSDATE)
    RETURN NUMBER;

END OKL_BPD_CREDIT_CHECK_PVT;

 

/
