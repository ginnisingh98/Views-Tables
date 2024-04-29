--------------------------------------------------------
--  DDL for Package OKL_PAY_INVOICES_TRANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAY_INVOICES_TRANS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPIIS.pls 115.4 2002/03/22 07:29:40 pkm ship        $ */

 ------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------

 G_PKG_NAME             CONSTANT VARCHAR2(200) :=  'OKL_PAY_INVOICES_TRANS_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

 ---------------------------------------------------------------------------
 -- Procedures and Functions
 ---------------------------------------------------------------------------

PROCEDURE transfer(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2);
END OKL_PAY_INVOICES_TRANS_PVT;

 

/
