--------------------------------------------------------
--  DDL for Package OKL_CASH_APPL_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASH_APPL_RULES" AUTHID CURRENT_USER AS
/* $Header: OKLRCAPS.pls 120.5 2007/08/02 15:50:10 nikshah ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

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
  G_REQUIRED_VALUE           CONSTANT   VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  l_xcav_tbl        Okl_Xca_Pvt.xcav_tbl_type;
  l_initialize      Okl_Xca_Pvt.xcav_tbl_type;

TYPE rcpt_rec_type IS RECORD (
    CASH_RECEIPT_ID                 NUMBER := OKL_API.G_MISS_NUM,
    AMOUNT                          NUMBER := OKL_API.G_MISS_NUM,
    CURRENCY_CODE                   AR_CASH_RECEIPTS.CURRENCY_CODE%TYPE := OKL_API.G_MISS_CHAR,
    CUSTOMER_NUMBER                 HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE := OKL_API.G_MISS_CHAR,
    CUSTOMER_ID                     NUMBER := OKL_API.G_MISS_NUM,
    RECEIPT_NUMBER                  AR_CASH_RECEIPTS.RECEIPT_NUMBER%TYPE := OKL_API.G_MISS_CHAR,
    RECEIPT_DATE                    AR_CASH_RECEIPTS.RECEIPT_DATE%TYPE := OKL_API.G_MISS_DATE,
    EXCHANGE_RATE_TYPE              AR_CASH_RECEIPTS.EXCHANGE_RATE_TYPE%TYPE := OKL_API.G_MISS_CHAR,
    EXCHANGE_RATE                   NUMBER := OKL_API.G_MISS_NUM,
    EXCHANGE_DATE                   AR_CASH_RECEIPTS.EXCHANGE_DATE%TYPE := OKL_API.G_MISS_DATE,
    REMITTANCE_BANK_ACCOUNT_ID      NUMBER := OKL_API.G_MISS_NUM,
    REMITTANCE_BANK_ACCOUNT_NUM     CE_BANK_ACCOUNTS.BANK_ACCOUNT_NUM%TYPE := OKL_API.G_MISS_CHAR,
    REMITTANCE_BANK_ACCOUNT_NAME    CE_BANK_ACCOUNTS.BANK_ACCOUNT_NAME%TYPE := OKL_API.G_MISS_CHAR,
    PAYMENT_TRX_EXTENSION_ID        ar_cash_receipts.payment_trxn_extension_id%TYPE,
    RECEIPT_METHOD_ID               NUMBER := OKL_API.G_MISS_NUM,
    ORG_ID                          NUMBER := OKL_API.G_MISS_NUM,
	GL_DATE                         DATE := OKL_API.G_MISS_DATE,
    DFF_ATTRIBUTE_CATEGORY          AR_CASH_RECEIPTS.ATTRIBUTE_CATEGORY%TYPE,
	DFF_ATTRIBUTE1                  AR_CASH_RECEIPTS.ATTRIBUTE1%TYPE,
	DFF_ATTRIBUTE2                  AR_CASH_RECEIPTS.ATTRIBUTE2%TYPE,
	DFF_ATTRIBUTE3                  AR_CASH_RECEIPTS.ATTRIBUTE3%TYPE,
	DFF_ATTRIBUTE4                  AR_CASH_RECEIPTS.ATTRIBUTE4%TYPE,
	DFF_ATTRIBUTE5                  AR_CASH_RECEIPTS.ATTRIBUTE5%TYPE,
	DFF_ATTRIBUTE6                  AR_CASH_RECEIPTS.ATTRIBUTE6%TYPE,
	DFF_ATTRIBUTE7                  AR_CASH_RECEIPTS.ATTRIBUTE7%TYPE,
	DFF_ATTRIBUTE8                  AR_CASH_RECEIPTS.ATTRIBUTE8%TYPE,
	DFF_ATTRIBUTE9                  AR_CASH_RECEIPTS.ATTRIBUTE9%TYPE,
	DFF_ATTRIBUTE10                  AR_CASH_RECEIPTS.ATTRIBUTE10%TYPE,
	DFF_ATTRIBUTE11                  AR_CASH_RECEIPTS.ATTRIBUTE11%TYPE,
	DFF_ATTRIBUTE12                  AR_CASH_RECEIPTS.ATTRIBUTE12%TYPE,
	DFF_ATTRIBUTE13                  AR_CASH_RECEIPTS.ATTRIBUTE13%TYPE,
	DFF_ATTRIBUTE14                  AR_CASH_RECEIPTS.ATTRIBUTE14%TYPE,
	DFF_ATTRIBUTE15                  AR_CASH_RECEIPTS.ATTRIBUTE15%TYPE
	);

  FUNCTION okl_installed (p_org_id IN NUMBER) RETURN BOOLEAN;  -- used by lockbox processing.

  PROCEDURE handle_manual_pay ( p_api_version         IN  NUMBER
                                               ,p_init_msg_list       IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                                               ,x_return_status       OUT NOCOPY VARCHAR2
                                               ,x_msg_count               OUT NOCOPY NUMBER
                                               ,x_msg_data                OUT NOCOPY VARCHAR2
                               ,p_cons_bill_id        IN  OKL_CNSLD_AR_HDRS_V.ID%TYPE DEFAULT NULL
                                               ,p_cons_bill_num       IN  OKL_CNSLD_AR_HDRS_V.CONSOLIDATED_INVOICE_NUMBER%TYPE DEFAULT NULL
                                               ,p_currency_code       IN  OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL
                               ,p_currency_conv_type  IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT NULL
                               ,p_currency_conv_date  IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT NULL
                                               ,p_currency_conv_rate  IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT NULL
                                               ,p_irm_id                  IN  OKL_TRX_CSH_RECEIPT_V.IRM_ID%TYPE DEFAULT NULL
                                               ,p_check_number        IN  OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL
                                               ,p_rcpt_amount         IN  OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL
                               ,p_contract_id         IN  OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL
                                               ,p_contract_num        IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                               ,p_customer_id         IN  OKL_TRX_CSH_RECEIPT_V.ILE_id%TYPE DEFAULT NULL
                                               ,p_customer_num        IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
                               ,p_gl_date             IN  OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE DEFAULT NULL
                               ,p_receipt_date        IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                               ,p_bank_account_id     IN  OKL_TRX_CSH_RECEIPT_V.IBA_ID%TYPE DEFAULT NULL
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
                                   ,p_rcpt_rec            IN  rcpt_rec_type
								   ,x_cash_receipt_id     OUT NOCOPY NUMBER
							      );


END Okl_Cash_Appl_Rules;

/
