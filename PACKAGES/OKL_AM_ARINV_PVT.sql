--------------------------------------------------------
--  DDL for Package OKL_AM_ARINV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_ARINV_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRARVS.pls 115.6 2002/07/19 18:43:51 rmunjulu noship $ */

---------------------------------------------------------------------------
-- GLOBAL CONSTANTS
---------------------------------------------------------------------------
G_PKG_NAME         CONSTANT VARCHAR2(200) := 'OKL_AM_ARINV_PVT';
G_APP_NAME         CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'SQLcode';
G_REQUIRED_VALUE   CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
G_INVALID_VALUE	   CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN   CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
G_YES              CONSTANT VARCHAR2(1)   := 'Y';
G_NO               CONSTANT VARCHAR2(1)   := 'N';

SUBTYPE ariv_tbl_type IS okl_am_invoices_pvt.ariv_tbl_type;

PROCEDURE Create_Asset_Repair_Invoice (
	p_api_version  	IN  NUMBER,
	p_init_msg_list	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count   	OUT NOCOPY NUMBER,
	x_msg_data    	OUT NOCOPY VARCHAR2,
	p_ariv_tbl	    IN  ariv_tbl_type);

PROCEDURE Approve_Asset_Repair (
	p_api_version  	IN  NUMBER,
	p_init_msg_list	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count   	OUT NOCOPY NUMBER,
	x_msg_data    	OUT NOCOPY VARCHAR2,
	p_ariv_tbl	    IN  ariv_tbl_type,
	x_ariv_tbl	    OUT NOCOPY ariv_tbl_type);

END okl_am_arinv_pvt;

 

/
