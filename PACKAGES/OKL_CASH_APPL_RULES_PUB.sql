--------------------------------------------------------
--  DDL for Package OKL_CASH_APPL_RULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASH_APPL_RULES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCAPS.pls 120.10 2008/02/29 10:48:47 asawanka ship $ */



 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CASH_ALLCTN_RLS_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 ------------------------------------------------------------------------------



 PROCEDURE okl_cash_applic  (   p_api_version	      IN  NUMBER
  				               ,p_init_msg_list       IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
				               ,x_return_status       OUT NOCOPY VARCHAR2
				               ,x_msg_count	          OUT NOCOPY NUMBER
				               ,x_msg_data	          OUT NOCOPY VARCHAR2
                               ,p_cons_bill_id        IN  OKL_CNSLD_AR_HDRS_V.ID%TYPE DEFAULT NULL
				               ,p_cons_bill_num       IN  OKL_CNSLD_AR_HDRS_V.CONSOLIDATED_INVOICE_NUMBER%TYPE DEFAULT NULL
				               ,p_currency_code       IN  OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL
                               ,p_currency_conv_type  IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT NULL
                               ,p_currency_conv_date  IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT NULL
				               ,p_currency_conv_rate  IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT NULL
				               ,p_irm_id	          IN  OKL_TRX_CSH_RECEIPT_V.IRM_ID%TYPE DEFAULT NULL
				               ,p_check_number        IN  OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL
				               ,p_rcpt_amount	      IN  OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL
                               ,p_contract_id         IN  OKC_K_HEADERS_B.ID%TYPE DEFAULT NULL
				               ,p_contract_num        IN  OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE DEFAULT NULL
                               ,p_customer_id         IN  OKL_TRX_CSH_RECEIPT_V.ILE_id%TYPE DEFAULT NULL
				               ,p_customer_num        IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
                               ,p_gl_date             IN  OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE DEFAULT NULL
                               ,p_receipt_date        IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                               ,p_bank_account_id     IN  OKL_TRX_CSH_RECEIPT_V.IBA_ID%TYPE
                               ,p_comments            IN  AR_CASH_RECEIPTS_ALL.COMMENTS%TYPE DEFAULT NULL
                               ,p_create_receipt_flag IN  VARCHAR2
							   );

  PROCEDURE create_manual_receipt ( p_api_version	      IN  NUMBER
		                   ,p_init_msg_list       IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
		                   ,x_return_status       OUT NOCOPY VARCHAR2
                                   ,x_msg_count	          OUT NOCOPY NUMBER
                                   ,x_msg_data	          OUT NOCOPY VARCHAR2
                                   ,p_cons_bill_id        IN  OKL_CNSLD_AR_HDRS_V.ID%TYPE DEFAULT NULL
                                   ,p_ar_inv_id           IN  RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE DEFAULT NULL
                                   ,p_contract_id         IN  OKC_K_HEADERS_ALL_B.ID%TYPE DEFAULT NULL
                                   ,p_rcpt_rec            IN  OKL_CASH_APPL_RULES.rcpt_rec_type
				   ,x_cash_receipt_id     OUT NOCOPY NUMBER
			          );


END Okl_Cash_Appl_Rules_Pub;

/
