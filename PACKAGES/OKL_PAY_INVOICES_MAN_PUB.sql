--------------------------------------------------------
--  DDL for Package OKL_PAY_INVOICES_MAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAY_INVOICES_MAN_PUB" AUTHID CURRENT_USER AS
 /* $Header: OKLPPIMS.pls 115.3 2002/12/18 12:28:00 kjinger noship $ */
 ------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_PAY_INVOICE_MAN_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
 -- Global Record Type
 ------------------------------------------------------------------------------
 SUBTYPE man_inv_rec_type IS okl_pay_invoices_man_pvt.man_inv_rec_type;
 SUBTYPE man_inv_tbl_type IS okl_pay_invoices_man_pvt.man_inv_tbl_type;
  ---------------------------------------------------------------------------
 -- Procedures and Functions
 ---------------------------------------------------------------------------

PROCEDURE manual_entry(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
    ,p_man_inv_rec      IN  man_inv_rec_type
    ,x_man_inv_rec      OUT NOCOPY  man_inv_rec_type);

    PROCEDURE manual_entry(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
    ,p_man_inv_tbl      IN  man_inv_tbl_type
    ,x_man_inv_tbl      OUT NOCOPY  man_inv_tbl_type);

END; -- Package spec

 

/
