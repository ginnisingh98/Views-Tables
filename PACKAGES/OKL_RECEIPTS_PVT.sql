--------------------------------------------------------
--  DDL for Package OKL_RECEIPTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RECEIPTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRRCTS.pls 120.9 2008/05/14 11:51:24 sosharma noship $ */
---------------------------------------------------------------------------
-- GLOBAL DATASTRUCTURES
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------

  g_app_name  CONSTANT VARCHAR2(3) := okl_api.g_app_name;

  g_unexpected_error  CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';

  g_sqlerrm_token  CONSTANT VARCHAR2(200) := 'SQLERRM';

  g_sqlcode_token  CONSTANT VARCHAR2(200) := 'SQLCODE';

  g_pkg_name  CONSTANT VARCHAR2(200) := 'OKL_RECEIPTS_PVT';

  g_col_name_token  CONSTANT VARCHAR2(200) := okl_api.g_col_name_token;

  g_parent_table_token  CONSTANT VARCHAR2(200) := okl_api.g_parent_table_token;

  g_child_table_token  CONSTANT VARCHAR2(200) := okl_api.g_child_table_token;

  g_no_parent_record  CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';

  g_invalid_value  CONSTANT VARCHAR2(200) := okl_api.g_invalid_value;

  g_required_value  CONSTANT VARCHAR2(200) := okl_api.g_required_value;

  g_exception_halt_validation  EXCEPTION;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  TYPE rcpt_rec_type IS RECORD(cash_receipt_id NUMBER := okl_api.g_miss_num,
                                amount NUMBER := okl_api.g_miss_num,
                                currency_code ar_cash_receipts.currency_code%TYPE := okl_api.g_miss_char,
                                customer_number hz_cust_accounts.account_number%TYPE := okl_api.g_miss_char,
                                customer_id NUMBER := okl_api.g_miss_num,
                                receipt_number ar_cash_receipts.receipt_number%TYPE := okl_api.g_miss_char,
                                receipt_date ar_cash_receipts.receipt_date%TYPE := okl_api.g_miss_date,
                                exchange_rate_type ar_cash_receipts.exchange_rate_type%TYPE := okl_api.g_miss_char,
                                exchange_rate NUMBER := okl_api.g_miss_num,
                                exchange_date ar_cash_receipts.exchange_date%TYPE := okl_api.g_miss_date,
                                remittance_bank_account_id NUMBER := okl_api.g_miss_num,
                                customer_bank_account_id NUMBER := okl_api.g_miss_num,
                                remittance_bank_account_num ce_bank_accounts.bank_account_num%TYPE := okl_api.g_miss_char,
                                remittance_bank_account_name ce_bank_accounts.bank_account_name%TYPE := okl_api.g_miss_char,
                                payment_trx_extension_id ar_cash_receipts.payment_trxn_extension_id%TYPE,
                                receipt_method_id NUMBER := okl_api.g_miss_num,
                                org_id NUMBER := okl_api.g_miss_num,
                                gl_date DATE := okl_api.g_miss_date,
                                dff_attribute_category ar_cash_receipts.attribute_category%TYPE,
                                dff_attribute1 ar_cash_receipts.attribute1%TYPE,
                                dff_attribute2 ar_cash_receipts.attribute2%TYPE,
                                dff_attribute3 ar_cash_receipts.attribute3%TYPE,
                                dff_attribute4 ar_cash_receipts.attribute4%TYPE,
                                dff_attribute5 ar_cash_receipts.attribute5%TYPE,
                                dff_attribute6 ar_cash_receipts.attribute6%TYPE,
                                dff_attribute7 ar_cash_receipts.attribute7%TYPE,
                                dff_attribute8 ar_cash_receipts.attribute8%TYPE,
                                dff_attribute9 ar_cash_receipts.attribute9%TYPE,
                                dff_attribute10 ar_cash_receipts.attribute10%TYPE,
                                dff_attribute11 ar_cash_receipts.attribute11%TYPE,
                                dff_attribute12 ar_cash_receipts.attribute12%TYPE,
                                dff_attribute13 ar_cash_receipts.attribute13%TYPE,
                                dff_attribute14 ar_cash_receipts.attribute14%TYPE,
                                dff_attribute15 ar_cash_receipts.attribute15%TYPE,
                                create_mode VARCHAR2(30), -- can take values 'UNAPPLIED', 'UNIDENTIFIED', 'ONACCOUNT', 'APPLIED'
                                p_original_onacc_amount  NUMBER := okl_api.g_miss_num, -- should be zero if this is new receipt or new application
                                p_apply_onacc_amount  NUMBER := okl_api.g_miss_num
                                );

  TYPE appl_rec_type IS RECORD(contract_id okc_k_headers_all_b.id%TYPE,
                                con_inv_id okl_cnsld_ar_hdrs_all_b.id%TYPE,
                                ar_inv_id NUMBER,
                                line_id ra_customer_trx_lines_all.customer_trx_line_id%TYPE,
                                original_applied_amount NUMBER, -- should be zero if this is new receipt or new application
                                line_type VARCHAR2(30) DEFAULT 'LINE',
                                amount_to_apply NUMBER DEFAULT NULL,
                                gl_date DATE,
                                line_applied NUMBER,
                                tax_applied NUMBER,
                                trans_to_receipt_rate NUMBER,
                                amount_applied_from NUMBER DEFAULT NULL);

  TYPE appl_tbl_type IS TABLE OF APPL_REC_TYPE INDEX BY BINARY_INTEGER ;


  PROCEDURE handle_receipt
       (p_api_version     IN NUMBER,
        p_init_msg_list   IN VARCHAR2 DEFAULT okl_api.g_false,
        x_return_status   OUT NOCOPY VARCHAR2,
        x_msg_count       OUT NOCOPY NUMBER,
        x_msg_data        OUT NOCOPY VARCHAR2,
        p_rcpt_rec        IN RCPT_REC_TYPE,
        p_appl_tbl         IN APPL_TBL_TYPE,
        x_cash_receipt_id OUT NOCOPY NUMBER);

FUNCTION cross_currency_rate_type
    (p_org_id IN NUMBER)
  RETURN VARCHAR2;

END okl_receipts_pvt;

/
