--------------------------------------------------------
--  DDL for Package OKL_CONS_BILL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONS_BILL" AUTHID CURRENT_USER AS
/* $Header: OKLRKONS.pls 120.7 2006/11/17 10:24:42 zrehman noship $ */
       G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CONS_BILL';
   	   G_APP_NAME			CONSTANT VARCHAR2(3)   := Okl_Api.G_APP_NAME;
  	   G_NO_DATA_FOUND 		CONSTANT VARCHAR2(200) := 'NO_DATA_FOUND';
  	   G_TOO_MANY_ROWS 		CONSTANT VARCHAR2(200) := 'TOO_MANY_ROWS';
  	   G_OTHERS        		CONSTANT VARCHAR2(200) := 'OTHERS';

       -- ------------------------------
       -- Commit frequency
       -- ------------------------------
       G_Commit_Max         CONSTANT NUMBER := 1000;

  -- -------------------------------------------------------------------------
  -- Consolidated Billing data structure
  -- -------------------------------------------------------------------------
  TYPE cons_bill_rec_type IS RECORD (
             customer_id            okl_ext_sell_invs_v.customer_id%TYPE,
             currency               okl_ext_sell_invs_v.currency_code%TYPE,
             bill_to_site           okl_ext_sell_invs_v.customer_address_id%TYPE,
             payment_method         okl_ext_sell_invs_v.receipt_method_id%TYPE,
             private_label          okl_ext_sell_invs_v.xtrx_private_label%TYPE,
             date_consolidated      okl_ext_sell_invs_v.TRX_DATE%TYPE,
             contract_id            okc_k_headers_b.id%TYPE,
             contract_number        okc_k_headers_b.contract_number%TYPE,
             inf_id                 okl_invoice_formats_b.id%TYPE,
             prev_cons_invoice_num  okl_cnsld_ar_hdrs_v.consolidated_invoice_number%TYPE,
             org_id                 okl_ext_sell_invs_v.org_id%TYPE,
             set_of_books_id        okl_ext_sell_invs_v.set_of_books_id%TYPE,
             kle_id                 okc_k_lines_b.id%TYPE,
             sty_id                 okl_strm_type_v.id%TYPE,
             xsi_id                 okl_ext_sell_invs_v.id%TYPE,
             xls_id                 okl_xtl_sell_invs_v.id%TYPE,
             amount	                okl_xtl_sell_invs_v.amount%TYPE,
             sel_id                 okl_xtl_sell_invs_v.sel_id%TYPE,
	     legal_entity_id        okl_ext_sell_invs_v.legal_entity_id%TYPE -- for LE Uptake project 08-11-2006
	    );

  TYPE cons_bill_tbl_type IS TABLE OF cons_bill_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE saved_bill_rec_type IS RECORD (
		   	 l_customer_id         okl_ext_sell_invs_v.customer_id%TYPE,
             l_currency            okl_ext_sell_invs_v.currency_code%TYPE,
             l_bill_to_site        okl_ext_sell_invs_v.customer_address_id%TYPE,
             l_payment_method      okl_ext_sell_invs_v.receipt_method_id%TYPE,
             l_private_label       okl_ext_sell_invs_v.xtrx_private_label%TYPE,
             l_date_consolidated   okl_ext_sell_invs_v.TRX_DATE%TYPE,
             l_saved_format_id     okl_invoice_formats_v.id%TYPE,
             l_saved_prev_cons_num okl_cnsld_ar_hdrs_v.consolidated_invoice_number%TYPE,
             l_prev_khr_id         okc_k_headers_b.id%TYPE,
             l_line_number         NUMBER,
             l_commit_cnt          NUMBER,
             l_overall_status      VARCHAR2(1),
             l_cnr_id              NUMBER,
             l_lln_id              NUMBER,
             l_cons_inv_num        okl_cnsld_ar_hdrs_v.consolidated_invoice_number%TYPE);

    TYPE update_rec_type IS RECORD (
	 cnr_id			    NUMBER,
     cons_inv_number    okl_cnsld_ar_hdrs_b.consolidated_invoice_number%TYPE,
	 lln_id			    NUMBER,
	 lsm_id			    NUMBER,
     asset_number       Okl_Xtl_Sell_Invs_tl.XTRX_ASSET%TYPE,
     invoice_format     OKL_INVOICE_FORMATS_V.NAME%TYPE,
     line_type          okl_invc_line_types_v.NAME%TYPE,
     private_label      Okl_Ext_Sell_Invs_tl.xtrx_private_label%TYPE,
     sty_name           okl_strm_type_v.NAME%TYPE,
     contract_number    okc_k_headers_b.contract_number%TYPE,
     lsm_amount         NUMBER,
	 xsi_id			    NUMBER,
	 xls_id			    NUMBER
	);

    TYPE update_tbl_type IS TABLE OF update_rec_type
	     INDEX BY BINARY_INTEGER;

  PROCEDURE create_cons_bill(
	       p_api_version        IN  NUMBER,
    	   p_init_msg_list      IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
           p_commit             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    	   x_return_status      OUT NOCOPY VARCHAR2,
    	   x_msg_count          OUT NOCOPY NUMBER,
    	   x_msg_data           OUT NOCOPY VARCHAR2,
           p_contract_number	IN VARCHAR2	DEFAULT NULL,
           p_inv_msg            IN VARCHAR2 DEFAULT 'TRUE',
           p_assigned_process   IN VARCHAR2 DEFAULT NULL
        );

  PROCEDURE process_cons_bill_tbl(
           p_contract_number	IN  VARCHAR2	DEFAULT NULL,
	       p_api_version        IN NUMBER,
    	   p_init_msg_list      IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
           p_commit             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    	   x_return_status      OUT NOCOPY VARCHAR2,
    	   x_msg_count          OUT NOCOPY NUMBER,
    	   x_msg_data           OUT NOCOPY VARCHAR2,
           p_cons_bill_tbl      IN OUT NOCOPY cons_bill_tbl_type,
           p_saved_bill_rec     IN OUT NOCOPY saved_bill_rec_type,
           p_update_tbl         IN OUT NOCOPY update_tbl_type);

  FUNCTION get_invoice_group(p_khr_id NUMBER)
       RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(get_invoice_group, WNDS);

END Okl_Cons_Bill;

/
