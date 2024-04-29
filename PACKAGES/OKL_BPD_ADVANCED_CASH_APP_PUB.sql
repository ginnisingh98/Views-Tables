--------------------------------------------------------
--  DDL for Package OKL_BPD_ADVANCED_CASH_APP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BPD_ADVANCED_CASH_APP_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPAVCS.pls 120.10 2008/01/23 09:29:53 asawanka ship $ */

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_BPD_ADVANCED_CASH_APP_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 ------------------------------------------------------------------------------
 -- Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

 ---------------------------------------------------------------------------
 -- GLOBAL DATASTRUCTURES
 ---------------------------------------------------------------------------
 TYPE ar_inv_rec_type IS RECORD (receivables_invoice_id   ra_customer_trx_all.customer_trx_id%TYPE);

 TYPE ar_inv_tbl_type IS TABLE OF ar_inv_rec_type INDEX BY BINARY_INTEGER;

 PROCEDURE ADVANCED_CASH_APP            ( p_api_version        IN  NUMBER
	                                     ,p_init_msg_list      IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
	                                     ,x_return_status      OUT NOCOPY VARCHAR2
	                                     ,x_msg_count	       OUT NOCOPY NUMBER
	                                     ,x_msg_data	       OUT NOCOPY VARCHAR2
                                         ,p_contract_num       IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                         ,p_customer_num       IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
                                         ,p_receipt_num        IN  OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL
                                         ,p_receipt_type       IN  OKL_TRX_CSH_RECEIPT_V.RECEIPT_TYPE%TYPE DEFAULT NULL
                                         ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                         );

 PROCEDURE REAPPLIC_ADVANCED_CASH_APP   ( p_api_version        IN  NUMBER
	                                     ,p_init_msg_list      IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
	                                     ,x_return_status      OUT NOCOPY VARCHAR2
	                                     ,x_msg_count	       OUT NOCOPY NUMBER
	                                     ,x_msg_data	       OUT NOCOPY VARCHAR2
                                         ,p_contract_num       IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                         ,p_customer_num       IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
                                         ,p_receipt_id         IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                         ,p_receipt_num        IN  OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL
                                         ,p_receipt_date_from  IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                                         ,p_receipt_date_to    IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                                         ,p_receipt_type       IN  VARCHAR2 DEFAULT NULL
					 ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                         );

 PROCEDURE ADVANCED_CASH_APP_CONC       ( errbuf  		       OUT NOCOPY VARCHAR2
                                         ,retcode 		       OUT NOCOPY NUMBER
                                         ,p_contract_num       IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                         ,p_customer_num       IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
                                         ,p_receipt_id         IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                         ,p_receipt_num        IN  OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL
                                         ,p_receipt_date_from  IN  VARCHAR2 DEFAULT NULL
                                         ,p_receipt_date_to    IN  VARCHAR2 DEFAULT NULL
                                         ,p_receipt_type       IN  VARCHAR2 DEFAULT NULL
					 ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                         );

 PROCEDURE REAPPLIC_RCPT_W_CNTRCT       ( p_api_version        IN  NUMBER
	                                     ,p_init_msg_list      IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
	                                     ,x_return_status      OUT NOCOPY VARCHAR2
	                                     ,x_msg_count	       OUT NOCOPY NUMBER
	                                     ,x_msg_data	       OUT NOCOPY VARCHAR2
                                         ,p_contract_num       IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                         ,p_customer_num       IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
					 ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                         );

PROCEDURE REAPPLIC_RCPT_W_CNTRCT_CONC  (  errbuf  		       OUT NOCOPY VARCHAR2
                                         ,retcode 		       OUT NOCOPY NUMBER
                                         ,p_contract_num       IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                         ,p_customer_num       IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
					 ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                         );

 PROCEDURE AR_advance_receipt           ( p_api_version        IN  NUMBER
	                                     ,p_init_msg_list      IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
	                                     ,x_return_status      OUT NOCOPY VARCHAR2
	                                     ,x_msg_count	       OUT NOCOPY NUMBER
	                                     ,x_msg_data	       OUT NOCOPY VARCHAR2
                                         ,p_xcav_tbl           IN  OKL_BPD_ADVANCED_CASH_APP_PVT.xcav_tbl_type
                                         ,p_receipt_id         IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                         ,p_receipt_amount     IN OUT NOCOPY AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE
                                         ,p_receipt_date       IN  AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT NULL
                                         ,p_receipt_currency   IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                         ,p_currency_code      IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                         ,p_ar_inv_tbl         IN  OKL_BPD_ADVANCED_BILLING_PVT.ar_inv_tbl_type
  );


END OKL_BPD_ADVANCED_CASH_APP_PUB;

/
