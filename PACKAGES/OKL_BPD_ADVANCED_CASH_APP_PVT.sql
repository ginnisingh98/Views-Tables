--------------------------------------------------------
--  DDL for Package OKL_BPD_ADVANCED_CASH_APP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BPD_ADVANCED_CASH_APP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAVCS.pls 120.9 2008/01/09 06:38:35 dkagrawa ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  SUBTYPE xcrv_rec_type IS Okl_Extrn_Pvt.xcrv_rec_type;
  SUBTYPE xcav_tbl_type IS Okl_Extrn_Pvt.xcav_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  G_APP_NAME             CONSTANT   VARCHAR2(3)   :=  Okl_api.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLCODE';

  G_PKG_NAME             CONSTANT   VARCHAR2(200) := 'OKL_CASH_APPL_RULES';
  G_COL_NAME_TOKEN       CONSTANT   VARCHAR2(200) :=  OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN   CONSTANT   VARCHAR2(200) :=  Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN    CONSTANT   VARCHAR2(200) :=  Okl_Api.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD     CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_INVALID_VALUE        CONSTANT   VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_REQUIRED_VALUE	     CONSTANT   VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

 PROCEDURE advanced_cash_app              ( p_api_version    IN  NUMBER
	                                       ,p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE
	                                       ,x_return_status  OUT NOCOPY VARCHAR2
	                                       ,x_msg_count	     OUT NOCOPY NUMBER
	                                       ,x_msg_data	     OUT NOCOPY VARCHAR2
                                           ,p_contract_num   IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                           ,p_customer_num   IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
                                           ,p_receipt_num    IN  OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL
					   ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                          );


 PROCEDURE apply_rcpt_to_contract_no_rule ( p_api_version        IN  NUMBER
	                                       ,p_init_msg_list      IN  VARCHAR2 DEFAULT okl_api.G_FALSE
	                                       ,x_return_status      OUT NOCOPY VARCHAR2
	                                       ,x_msg_count	         OUT NOCOPY NUMBER
	                                       ,x_msg_data	         OUT NOCOPY VARCHAR2
                                           ,p_contract_id        IN  OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL
                                           ,p_contract_num       IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                           ,p_customer_id        IN  OKL_TRX_CSH_RECEIPT_V.ILE_ID%TYPE DEFAULT NULL
                                           ,p_customer_num       IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
                                           ,p_receipt_id         IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                           ,p_receipt_amount     IN  AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE
                                           ,p_remain_rcpt_amount OUT NOCOPY AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE
                                           ,p_receipt_currency   IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                           ,p_receipt_date       IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                                           ,p_invoice_currency   IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                           ,p_currency_conv_date IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT NULL
                                           ,p_currency_conv_rate IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT NULL
                                           ,p_currency_conv_type IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT NULL
                                           ,p_xcr_id             IN  NUMBER DEFAULT NULL
					   ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                          );


 PROCEDURE apply_rcpt_to_contract_w_rule  ( p_api_version        IN  NUMBER
	                                       ,p_init_msg_list      IN  VARCHAR2 DEFAULT okl_api.G_FALSE
	                                       ,x_return_status      OUT NOCOPY VARCHAR2
	                                       ,x_msg_count	         OUT NOCOPY NUMBER
	                                       ,x_msg_data	         OUT NOCOPY VARCHAR2
                                           ,p_contract_id        IN  OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL
                                           ,p_contract_num       IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                           ,p_customer_id        IN  OKL_TRX_CSH_RECEIPT_V.ILE_ID%TYPE DEFAULT NULL
                                           ,p_customer_num       IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
                                           ,p_receipt_id         IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                           ,p_receipt_amount     IN  AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE
                                           ,p_remain_rcpt_amount OUT NOCOPY AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE
                                           ,p_receipt_currency   IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                           ,p_receipt_date       IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                                           ,p_invoice_currency   IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                           ,p_invoice_total      IN  OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL
                                           ,p_currency_conv_date IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT NULL
                                           ,p_currency_conv_rate IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT NULL
                                           ,p_currency_conv_type IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT NULL
                                           ,p_xcr_id             IN  NUMBER DEFAULT NULL
					   ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                          );

 PROCEDURE reapplic_rcpt_w_cntrct        (  p_api_version        IN  NUMBER
	                                       ,p_init_msg_list      IN  VARCHAR2 DEFAULT okl_api.G_FALSE
	                                       ,x_return_status      OUT NOCOPY VARCHAR2
	                                       ,x_msg_count	         OUT NOCOPY NUMBER
	                                       ,x_msg_data	         OUT NOCOPY VARCHAR2
                                           ,p_contract_num       IN  VARCHAR2 DEFAULT NULL
                                           ,p_customer_num       IN  NUMBER DEFAULT NULL
					   ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                          );


PROCEDURE reapplic_advanced_cash_app ( p_api_version        IN  NUMBER
                                      ,p_init_msg_list      IN  VARCHAR2 DEFAULT okl_api.G_FALSE
                                      ,x_return_status      OUT NOCOPY VARCHAR2
                                      ,x_msg_count          OUT NOCOPY NUMBER
                                      ,x_msg_data           OUT NOCOPY VARCHAR2
                                      ,p_contract_num       IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                      ,p_customer_num       IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
                                      ,p_receipt_id         IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                      ,p_receipt_num        IN  OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL
                                      ,p_receipt_date_from  IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                                      ,p_receipt_date_to    IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                                      ,p_receipt_type       IN  VARCHAR2 DEFAULT NULL
				      ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                     );


PROCEDURE AR_advance_receipt     (   p_api_version       IN  NUMBER
	                                ,p_init_msg_list     IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE
	                                ,x_return_status     OUT NOCOPY VARCHAR2
	                                ,x_msg_count	     OUT NOCOPY NUMBER
	                                ,x_msg_data	         OUT NOCOPY VARCHAR2
                                    ,p_xcav_tbl          IN  xcav_tbl_type
                                    ,p_receipt_id        IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                    ,p_receipt_amount    IN OUT NOCOPY AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE
                                    ,p_receipt_date      IN  AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT NULL
                                    ,p_receipt_currency  IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                    ,p_currency_code     IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                  ,p_ar_inv_tbl        IN  OKL_BPD_ADVANCED_BILLING_PVT.ar_inv_tbl_type
                                  );

PROCEDURE migrate_Applications     ( p_api_version       IN  NUMBER
                                    ,p_init_msg_list     IN  VARCHAR2 DEFAULT okl_api.G_FALSE
                                    ,x_return_status     OUT NOCOPY VARCHAR2
                                    ,x_msg_count         OUT NOCOPY NUMBER
                                    ,x_msg_data          OUT NOCOPY VARCHAR2
                                    ,p_receipt_id        IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                    ,p_appl_tbl          IN  okl_receipts_pvt.appl_tbl_type
                                    ,x_appl_tbl          OUT  NOCOPY okl_receipts_pvt.appl_tbl_type
                                  );

END OKL_BPD_ADVANCED_CASH_APP_PVT;

/
