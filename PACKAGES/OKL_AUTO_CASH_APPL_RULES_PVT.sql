--------------------------------------------------------
--  DDL for Package OKL_AUTO_CASH_APPL_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AUTO_CASH_APPL_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRACUS.pls 120.17 2008/01/08 12:13:13 asawanka ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  G_APP_NAME             CONSTANT   VARCHAR2(3)   :=  Okl_api.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT   VARCHAR2(200) := 'SQLCODE';

  G_PKG_NAME             CONSTANT   VARCHAR2(200) := 'OKL_AUTO_CASH_APPL_RULES_PVT';
  G_COL_NAME_TOKEN       CONSTANT   VARCHAR2(200) :=  OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN   CONSTANT   VARCHAR2(200) :=  Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN    CONSTANT   VARCHAR2(200) :=  Okl_Api.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD     CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_INVALID_VALUE        CONSTANT   VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_REQUIRED_VALUE           CONSTANT   VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------



 TYPE okl_rcpt_dtls_rec_type IS RECORD (  invoice_id            NUMBER DEFAULT NULL
                                         ,invoice_number        RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE DEFAULT NULL
                                         ,invoice_currency_code VARCHAR2(30)
                                         ,invoice_line_id       RA_CUSTOMER_TRX_LINES_ALL.customer_trx_line_id%TYPE DEFAULT NULL
                                         ,invoice_line_number   RA_CUSTOMER_TRX_LINES_ALL.LINE_NUMBER%TYPE DEFAULT NULL
                                         ,amount_applied        AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL
                                         ,amount_applied_from   AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED_FROM%TYPE DEFAULT NULL
                                         ,trans_to_receipt_rate NUMBER
                                        );

  TYPE okl_rcpt_dtls_tbl_type IS TABLE OF okl_rcpt_dtls_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE okl_inv_hdr_rec_type IS RECORD  ( invoice_id            NUMBER DEFAULT NULL
                                        ,invoice_number        RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE DEFAULT NULL
                                        ,invoice_currency_code AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                        ,freight_amount        AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL
                                        ,charges_amount        AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL
                                        ,amount_applied        AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL
                                        ,amount_applied_from   AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL
                                        ,gl_date               DATE DEFAULT NULL
                                        ,trans_to_receipt_rate NUMBER
                                        );

  TYPE okl_inv_line_rec_type IS RECORD ( invoice_line_id       RA_CUSTOMER_TRX_LINES_ALL.customer_trx_line_id%TYPE DEFAULT NULL
                                        ,invoice_line_number   RA_CUSTOMER_TRX_LINES_ALL.LINE_NUMBER%TYPE DEFAULT NULL
                                        ,amount_applied        AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL
                                        ,amount_applied_from        AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED_FROM%TYPE DEFAULT NULL
                                        ,original_applied_amount    AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL
                                        ,line_applied          AR_RECEIVABLE_APPLICATIONS_ALL.LINE_APPLIED%TYPE DEFAULT NULL
                                        ,tax_applied           AR_RECEIVABLE_APPLICATIONS_ALL.TAX_APPLIED%TYPE DEFAULT NULL
                                        ,trans_to_receipt_rate NUMBER
                                       );
  TYPE okl_inv_line_tbl_type IS TABLE OF okl_inv_line_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE okl_appl_dtls_rec_type IS RECORD ( inv_hdr_rec okl_inv_hdr_rec_type
                                         ,inv_lines_tbl okl_inv_line_tbl_type
                                        );
  TYPE okl_appl_dtls_tbl_type IS TABLE OF okl_appl_dtls_rec_type
        INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  --START: Bug 6275659 by nikshah
  ---------------------------------------------------------------------------
  --Get default cash application rule
  ---------------------------------------------------------------------------
  PROCEDURE get_default_cash_app_rule(p_org_id IN OKL_CASH_ALLCTN_RLS.ORG_ID%TYPE,
                                      x_dflt_cat_id  OUT  NOCOPY OKL_CASH_ALLCTN_RLS.ID%TYPE,
                                      x_dflt_tolerance OUT  NOCOPY OKL_CASH_ALLCTN_RLS.AMOUNT_TOLERANCE_PERCENT%TYPE,
                                      x_dflt_days_past_quote_valid OUT NOCOPY OKL_CASH_ALLCTN_RLS.DAYS_PAST_QUOTE_VALID_TOLERANC%TYPE,
                                      x_dflt_months_to_bill_ahead  OUT NOCOPY OKL_CASH_ALLCTN_RLS.MONTHS_TO_BILL_AHEAD%TYPE,
                                      x_dflt_under_payment OUT NOCOPY OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE,
                                      x_dflt_over_payment OUT  NOCOPY OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE ,
                                      x_dflt_receipt_msmtch OUT NOCOPY OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE
                                     );
  --END: Bug 6275659 by nikshah

  -- Begin - Bug 6275659 -varangan - receipts project
  ---------------------------------------------------------------------------
  -- Procedures for AR invoice Number - cash application rules
  ---------------------------------------------------------------------------
  PROCEDURE auto_cashapp_for_arinv (
                                        p_api_version        IN  NUMBER
                                        ,p_init_msg_list     IN  VARCHAR2  DEFAULT Okc_Api.G_FALSE
                                        ,x_return_status     OUT NOCOPY VARCHAR2
                                        ,x_msg_count         OUT NOCOPY NUMBER
                                        ,x_msg_data          OUT NOCOPY VARCHAR2
                                        ,p_customer_num      IN  VARCHAR2  DEFAULT NULL
                                        ,p_arinv_number      IN  VARCHAR2  DEFAULT NULL
                                        ,p_currency_code     IN  VARCHAR2
                                        ,p_amount_app_to     IN  NUMBER DEFAULT NULL
                                        ,p_amount_app_from   IN  NUMBER DEFAULT NULL
                                        ,p_inv_to_rct_rate   IN  NUMBER DEFAULT NULL
                                        ,p_receipt_date      IN  DATE
                                        ,p_arinv_id          IN  NUMBER DEFAULT NULL
                                        ,p_org_id            IN Number
                                        ,x_appl_tbl          OUT NOCOPY okl_appl_dtls_tbl_type
                                        ,x_onacc_amount      OUT NOCOPY NUMBER
                                        ,x_unapply_amount    OUT NOCOPY NUMBER
                                    );
  -- End - Bug 6275659 - varangan - Receipts project

  --START: Bug 6275659 by nikshah
  --Get application details table for the given receipt table
  --So the application details table will be table of invoice header
  --and its corresponding invoice lines with its applied amount
  PROCEDURE GET_APPLICATIONS ( p_rcpt_tbl IN okl_rcpt_dtls_tbl_type
                              ,x_appl_tbl OUT NOCOPY okl_appl_dtls_tbl_type);
  --END: Bug 6275659 by nikshah


  --START: Bug 6275659 by nikshah
  --Identifies all invoice lines to be applied against for a given contract number
  --based on CAR setup for the contract
  PROCEDURE auto_cashapp_for_contract(p_api_version           IN   NUMBER
                                ,p_init_msg_list    IN   VARCHAR2        DEFAULT Okc_Api.G_FALSE
                                ,x_return_status    OUT  NOCOPY VARCHAR2
                                ,x_msg_count        OUT  NOCOPY NUMBER
                                ,x_msg_data             OUT  NOCOPY VARCHAR2
                                ,p_customer_num     IN   VARCHAR2        DEFAULT NULL
                                ,p_contract_num     IN   VARCHAR2        DEFAULT NULL
                                ,p_currency_code    IN   VARCHAR2
                                ,p_amount_app_to     IN  NUMBER DEFAULT NULL
                                ,p_amount_app_from   IN  NUMBER DEFAULT NULL
                                ,p_inv_to_rct_rate   IN  NUMBER DEFAULT NULL
                                ,p_receipt_date      IN  DATE
                                ,p_org_id               IN   NUMBER
                                ,x_appl_tbl         OUT  NOCOPY  okl_appl_dtls_tbl_type
                                ,x_onacc_amount        OUT NOCOPY NUMBER
                                ,x_unapply_amount      OUT NOCOPY NUMBER
                                ) ;

  --Receipt mismatch which will identify all the invoice lines
  --for the given customer based on CAR setup i.e. Newest invoices or Oldest invoices
  PROCEDURE receipt_mismatch(p_api_version          IN   NUMBER
                            ,p_init_msg_list    IN   VARCHAR2        DEFAULT Okc_Api.G_FALSE
                            ,x_return_status    OUT  NOCOPY VARCHAR2
                            ,x_msg_count            OUT  NOCOPY NUMBER
                            ,x_msg_data         OUT  NOCOPY VARCHAR2
                            ,p_customer_num     IN   VARCHAR2        DEFAULT NULL
                            ,p_currency_code    IN   VARCHAR2
                            ,p_rcpt_amount          IN   NUMBER
                            ,p_org_id           IN   NUMBER
                            ,p_receipt_date     IN DATE
                            ,x_appl_tbl         OUT  NOCOPY  okl_appl_dtls_tbl_type
                            ,x_onacc_amount        OUT NOCOPY NUMBER
                            );
  --END: Bug 6275659 by nikshah
  /* sosharma 30- Jul-2007
  Identifies all  invoice lines to be applied against for a given consolidated invoice number
  based on CAR setup */

 PROCEDURE auto_cashapp_for_consinv (  p_api_version      IN   NUMBER
                         ,p_init_msg_list    IN   VARCHAR2        DEFAULT Okc_Api.G_FALSE
                         ,x_return_status    OUT  NOCOPY VARCHAR2
                         ,x_msg_count          OUT  NOCOPY NUMBER
                         ,x_msg_data          OUT  NOCOPY VARCHAR2
                         ,p_customer_num     IN   VARCHAR2        DEFAULT NULL
                         ,p_cons_inv         IN   VARCHAR2
                         ,p_currency_code    IN   VARCHAR2
                         ,p_amount_app_to     IN  NUMBER DEFAULT NULL
                         ,p_amount_app_from   IN  NUMBER DEFAULT NULL
                         ,p_inv_to_rct_rate   IN  NUMBER DEFAULT NULL
                         ,p_receipt_date      IN  DATE
                         ,p_org_id           IN   NUMBER
                         ,x_appl_tbl         OUT  NOCOPY  okl_appl_dtls_tbl_type
                        ,x_onacc_amount        OUT NOCOPY NUMBER
                        ,x_unapply_amount      OUT NOCOPY NUMBER
                       );

 --Gets the rounded amount for the given amount and currency code
 FUNCTION GET_ROUNDED_AMOUNT( p_amount_to_round IN NUMBER
                             ,p_currency_code IN VARCHAR2)
          RETURN NUMBER;

END OKL_AUTO_CASH_APPL_RULES_PVT;


/
