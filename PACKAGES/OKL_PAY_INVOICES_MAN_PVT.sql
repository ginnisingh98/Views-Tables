--------------------------------------------------------
--  DDL for Package OKL_PAY_INVOICES_MAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAY_INVOICES_MAN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPIMS.pls 120.3 2006/11/17 11:57:56 zrehman noship $ */
 ------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------

 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_PAY_INVOICE_MAN';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
 -- Global Record Type
 ------------------------------------------------------------------------------

 TYPE man_inv_rec_type IS RECORD (
  ipvs_id        okl_trx_ap_invoices_b.ipvs_id%type
 ,khr_id         okl_trx_ap_invoices_b.khr_id%type
 ,currency       okl_trx_ap_invoices_b.currency_code%type
 ,vendor_id      okl_trx_ap_invoices_b.vendor_id%type
 ,payment_method_code  okl_trx_ap_invoices_b.payment_method_code%type
 ,invoice_date   DATE
 ,pay_terms      okl_trx_ap_invoices_b.ippt_id%type
 ,invoice_number okl_trx_ap_invoices_b.invoice_number%type
 ,invoice_category_code  okl_trx_ap_invoices_b.invoice_category_code%type
 ,invoice_type   okl_trx_ap_invoices_b.invoice_type%type
 ,amount         okl_trx_ap_invoices_b.amount%type
 ,sty_id         okl_strm_type_b.id%type
 ,Pay_Group_lookup_code  okl_trx_ap_invoices_b.Pay_Group_lookup_code%type
 ,Vendor_Invoice_Number  okl_trx_ap_invoices_b.Vendor_Invoice_Number%type
 ,sel_id                 okl_strm_elements.id%TYPE
 ,legal_entity_id        okl_trx_ap_invoices_b.legal_entity_id%TYPE -- for LE Uptake project 08-11-2006
  );

 g_miss_man_inv_rec      man_inv_rec_type;

 TYPE man_inv_tbl_type IS TABLE OF man_inv_rec_type
        INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
 -- Procedures and Functions
 ---------------------------------------------------------------------------

PROCEDURE manual_entry(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
    ,p_man_inv_rec      IN  man_inv_rec_type
    ,x_man_inv_rec      OUT NOCOPY man_inv_rec_type
    );

PROCEDURE manual_entry(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
    ,p_man_inv_tbl      IN  man_inv_tbl_type
    ,x_man_inv_tbl      OUT NOCOPY man_inv_tbl_type
    );
END; -- Package spec

/
