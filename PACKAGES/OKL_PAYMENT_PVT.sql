--------------------------------------------------------
--  DDL for Package OKL_PAYMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAYMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPAYS.pls 120.7 2007/10/10 11:27:27 varangan noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			      CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE		      CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_NAME1_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_PAYMENT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKL';
  G_CUSTOMER_ID_NULL          CONSTANT VARCHAR2(200) := 'OKL_CUSTOMER_ID_NULL';
  G_CONTRACT_ID_NULL          CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_ID_NULL';
  G_PAYMENT_METHOD_INVALID    CONSTANT VARCHAR2(200) := 'OKL_PAYMENT_METHOD_INVALID';
   ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ---------------------------------------------------------------------------
  -- Data Structures
  ----------------------------------------------------------------------------
  TYPE receipt_rec_type IS RECORD (
     currency_code                  OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL,
     currency_conv_type             OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT NULL,
     currency_conv_date             OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT NULL,
     currency_conv_rate             OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT NULL,
     irm_id                         OKL_TRX_CSH_RECEIPT_V.IRM_ID%TYPE DEFAULT NULL,
     rem_bank_acc_id                okl_bpd_rcpt_mthds_uv.bank_account_id%TYPE DEFAULT NULL,
     contract_id                    OKC_K_HEADERS_B.ID%TYPE DEFAULT NULL,
     contract_num                   OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE DEFAULT NULL,
     cust_acct_id                   OKL_TRX_CSH_RECEIPT_V.ILE_id%TYPE DEFAULT NULL,
     customer_num                   HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE DEFAULT NULL,
     gl_date                        OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE DEFAULT NULL,
     payment_date                   OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT TRUNC(SYSDATE),
     customer_site_use_id           AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_SITE_USE_ID%TYPE DEFAULT NULL,
     expiration_date                DATE DEFAULT NULL,
     payment_trxn_extension_id      NUMBER
     );

  TYPE payment_rec_type IS RECORD (
     con_inv_id                     OKL_CNSLD_AR_HDRS_ALL_B.ID%TYPE,
     ar_inv_id                      RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE,
     line_id                        RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_LINE_ID%TYPE,
     amount                         NUMBER
     );

  TYPE payment_tbl_type IS TABLE OF payment_rec_type INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  -- Creates internal transactions for cutomer and contract combination
  PROCEDURE CREATE_INTERNAL_TRANS(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_customer_id                  IN NUMBER,
     p_contract_id			        IN NUMBER,
     p_contract_num                 IN VARCHAR2 DEFAULT NULL,
     p_payment_method_id            IN NUMBER,
     p_payment_ref_number           IN VARCHAR2,
     p_payment_amount               IN NUMBER,
     p_currency_code                IN VARCHAR2,
     p_payment_date                 IN DATE,
     x_payment_id                   OUT NOCOPY NUMBER,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2
  );

  -- Creates internal transactions for cutomer and invoice combination
  PROCEDURE CREATE_INTERNAL_TRANS(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_customer_id                  IN NUMBER,
     p_invoice_id			        IN NUMBER,
     p_payment_method_id            IN NUMBER,
     p_payment_ref_number           IN VARCHAR2,
     p_payment_amount               IN NUMBER,
     p_currency_code                IN VARCHAR2,
     p_payment_date                 IN DATE,
     x_payment_id                   OUT NOCOPY NUMBER,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2
  );

  -- Called from Make Payments UI
  PROCEDURE CREATE_PAYMENTS(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_commit                       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_validation_level             IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_receipt_rec                  IN  receipt_rec_type,
     p_payment_tbl                  IN  payment_tbl_type,
     x_payment_ref_number           OUT NOCOPY AR_CASH_RECEIPTS_ALL.RECEIPT_NUMBER%TYPE,
     x_cash_receipt_id              OUT NOCOPY NUMBER
  );

END OKL_PAYMENT_PVT;

/
