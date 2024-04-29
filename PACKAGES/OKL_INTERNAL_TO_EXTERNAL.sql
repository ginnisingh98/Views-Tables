--------------------------------------------------------
--  DDL for Package OKL_INTERNAL_TO_EXTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INTERNAL_TO_EXTERNAL" AUTHID CURRENT_USER AS
/* $Header: OKLRIEXS.pls 120.5 2006/11/17 10:27:33 zrehman noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okl_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okl_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okl_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_INTERNAL_TO_EXTERNAL';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

/******************ADDED AFTER TAPI, Sunil T. Mathew (04/16/2001) ****************/
  --GLOBAL MESSAGES
   G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
   G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
   G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
   G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
   G_NOT_SAME              		CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';


--GLOBAL VARIABLES
  G_VIEW			CONSTANT   VARCHAR2(30) := 'OKL_INT_TO_EXT';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;

 --fmiao 5209209 change
 /*
PROCEDURE internal_to_external(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit                       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_contract_number	           IN  VARCHAR2	DEFAULT NULL
); */

  TYPE ie_rec_type1 IS RECORD
  ( tai_id             		 okl_trx_ar_invoices_v.id%TYPE
   ,contract_id 		 	 okl_trx_ar_invoices_v.khr_id%TYPE
   ,trx_status_code			 okl_trx_ar_invoices_v.trx_status_code%TYPE
   ,date_invoiced			 okl_trx_ar_invoices_v.date_invoiced%TYPE
   ,ixx_id					 okl_trx_ar_invoices_v.ixx_id%TYPE
   ,irm_id					 okl_trx_ar_invoices_v.irm_id%TYPE
   ,irt_id				 	 okl_trx_ar_invoices_v.irt_id%TYPE
   ,ibt_id			 		 okl_trx_ar_invoices_v.ibt_id%TYPE
   ,set_of_books_id		 	 okl_trx_ar_invoices_v.set_of_books_id%TYPE
   ,tai_description			 okl_trx_ar_invoices_v.description%TYPE
   ,currency_code		 	 okl_trx_ar_invoices_v.currency_code%TYPE
   ,currency_conversion_type okl_trx_ar_invoices_v.currency_conversion_type%TYPE
   ,currency_conversion_rate okl_trx_ar_invoices_v.currency_conversion_rate%TYPE
   ,currency_conversion_date okl_trx_ar_invoices_v.currency_conversion_date%TYPE
   ,org_id				 	 okl_trx_ar_invoices_v.org_id%TYPE
   ,legal_entity_id          okl_trx_ar_invoices_v.legal_entity_id%TYPE -- for LE Uptake project 08-11-2006
   ,trx_number				 okl_trx_ar_invoices_v.trx_number%TYPE
   ,inv_receiv_line_code	 okl_txl_ar_inv_lns_v.inv_receiv_line_code%TYPE
   ,til_description		 	 okl_txd_ar_ln_dtls_v.description%TYPE
   ,quantity				 okl_txl_ar_inv_lns_v.quantity%TYPE
   ,kle_id                 	 okl_txl_ar_inv_lns_v.kle_id%TYPE
   ,tld_id			  		 okl_txd_ar_ln_dtls_v.id%TYPE
   ,amount				 	 okl_txd_ar_ln_dtls_v.amount%TYPE
   ,tld_id_reverses			 okl_txd_ar_ln_dtls_v.TLD_ID_REVERSES%TYPE
   ,sty_id		 			 okl_txd_ar_ln_dtls_v.sty_id%TYPE
   ,taxable_default_yn       okl_strm_type_v.taxable_default_yn%TYPE
   ,sel_id                 	 okl_txd_ar_ln_dtls_v.sel_id%TYPE
   ,inventory_item_id		 okl_txd_ar_ln_dtls_v.inventory_item_id%TYPE
   ,inventory_org_id         okl_txd_ar_ln_dtls_v.inventory_org_id%TYPE
  );
  TYPE ie_tbl_type1 IS TABLE OF ie_rec_type1
     INDEX BY BINARY_INTEGER;

  TYPE ie_rec_type2 IS RECORD
  ( tai_id                   okl_trx_ar_invoices_v.id%TYPE
   ,contract_id	  		 	 okl_trx_ar_invoices_v.khr_id%TYPE
   ,trx_status_code		  	 okl_trx_ar_invoices_v.trx_status_code%TYPE
   ,date_invoiced			 okl_trx_ar_invoices_v.date_invoiced%TYPE
   ,ixx_id					 okl_trx_ar_invoices_v.ixx_id%TYPE
   ,irm_id				 	 okl_trx_ar_invoices_v.irm_id%TYPE
   ,irt_id				 	 okl_trx_ar_invoices_v.irt_id%TYPE
   ,ibt_id				 	 okl_trx_ar_invoices_v.ibt_id%TYPE
   ,set_of_books_id			 okl_trx_ar_invoices_v.set_of_books_id%TYPE
   ,tai_description			 okl_trx_ar_invoices_v.description%TYPE
   ,currency_code			 okl_trx_ar_invoices_v.currency_code%TYPE
   ,currency_conversion_type okl_trx_ar_invoices_v.currency_conversion_type%TYPE
   ,currency_conversion_rate okl_trx_ar_invoices_v.currency_conversion_rate%TYPE
   ,currency_conversion_date okl_trx_ar_invoices_v.currency_conversion_date%TYPE
   ,org_id				 	 okl_trx_ar_invoices_v.org_id%TYPE
   ,legal_entity_id          okl_trx_ar_invoices_v.legal_entity_id%TYPE -- for LE Uptake project 08-11-2006
   ,trx_number				 okl_trx_ar_invoices_v.trx_number%TYPE
   ,til_id				 	 okl_txl_ar_inv_lns_v.id%TYPE
   ,kle_id                   okl_txl_ar_inv_lns_v.kle_id%TYPE
   ,inv_receiv_line_code	 okl_txl_ar_inv_lns_v.inv_receiv_line_code%TYPE
   ,til_description			 okl_txl_ar_inv_lns_v.description%TYPE
   ,quantity				 okl_txl_ar_inv_lns_v.quantity%TYPE
   ,amount				 	 okl_txl_ar_inv_lns_v.amount%TYPE
   ,TIL_ID_REVERSES			 okl_txl_ar_inv_lns_v.TIL_ID_REVERSES%TYPE
   ,sty_id			 		 okl_txl_ar_inv_lns_v.sty_id%TYPE
   ,taxable_default_yn       okl_strm_type_v.taxable_default_yn%TYPE
   ,inventory_item_id		 okl_txl_ar_inv_lns_v.inventory_item_id%TYPE
   ,inventory_org_id         okl_txl_ar_inv_lns_v.inventory_org_id%TYPE
   ,bank_acct_id             okl_txl_ar_inv_lns_v.bank_acct_id%TYPE
   ,qte_id                   okl_trx_ar_invoices_v.qte_id%TYPE
  );
  TYPE ie_tbl_type2 IS TABLE OF ie_rec_type2
     INDEX BY BINARY_INTEGER;


  -- ----------------------------------------------------------------
  -- Procedure
  -- ----------------------------------------------------------------
  PROCEDURE internal_to_external
  (      p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT Okc_Api.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
        ,p_commit           IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
	,p_contract_number	IN  VARCHAR2	DEFAULT NULL
	,p_assigned_process IN VARCHAR2 DEFAULT NULL
  );
 --fmiao 5209209 change end


END  Okl_Internal_To_External;

/
