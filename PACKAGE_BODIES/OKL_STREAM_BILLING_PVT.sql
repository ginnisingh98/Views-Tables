--------------------------------------------------------
--  DDL for Package Body OKL_STREAM_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STREAM_BILLING_PVT" AS
/* $Header: OKLRBSTB.pls 120.49.12010000.4 2009/06/02 10:36:37 racheruv ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.BILLING';
  L_DEBUG_ENABLED VARCHAR2(10);
--  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := Okl_Debug_Pub.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

  -- Bug 4546873, Global variable for warning status
  l_warning_status   VARCHAR2(1);
  -- End Bug 4546873, Global variable for warning status

    -- Contract or Investor Agreement type
  L_IA_TYPE   VARCHAR2(10) :='IA';
  L_CONTRACT_TYPE   VARCHAR2(10) :='CONTRACT';

  ----------------------------------------------
  -- Global variables for bulk processing
  ----------------------------------------------

  l_tai_cnt 	NUMBER := 0;
  l_til_cnt     NUMBER := 0;
  l_tld_cnt     NUMBER := 0;
  l_xsi_cnt     NUMBER := 0;
  l_xls_cnt     NUMBER := 0;

  TYPE tai_tbl_type IS TABLE OF OKL_TRX_AR_INVOICES_B%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE til_tbl_type IS TABLE OF OKL_TXL_AR_INV_LNS_B%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE tld_tbl_type IS TABLE OF OKL_TXD_AR_LN_DTLS_B%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE xsi_tbl_type IS TABLE OF OKL_EXT_SELL_INVS_B%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE xls_tbl_type IS TABLE OF OKL_XTL_SELL_INVS_B%ROWTYPE INDEX BY BINARY_INTEGER;

  tai_tbl       tai_tbl_type;
  til_tbl       til_tbl_type;
  tld_tbl       tld_tbl_type;
  xsi_tbl       xsi_tbl_type;
  xls_tbl       xls_tbl_type;

  l_taitl_cnt 	  NUMBER := 0;
  l_tiltl_cnt     NUMBER := 0;
  l_tldtl_cnt     NUMBER := 0;
  l_xsitl_cnt     NUMBER := 0;
  l_xlstl_cnt     NUMBER := 0;

  TYPE taitl_tbl_type IS TABLE OF OKL_TRX_AR_INVOICES_TL%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE tiltl_tbl_type IS TABLE OF OKL_TXL_AR_INV_LNS_TL%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE tldtl_tbl_type IS TABLE OF OKL_TXD_AR_LN_DTLS_TL%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE xsitl_tbl_type IS TABLE OF OKL_EXT_SELL_INVS_TL%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE xlstl_tbl_type IS TABLE OF OKL_XTL_SELL_INVS_TL%ROWTYPE INDEX BY BINARY_INTEGER;

  taitl_tbl       taitl_tbl_type;
  tiltl_tbl       tiltl_tbl_type;
  tldtl_tbl       tldtl_tbl_type;
  xsitl_tbl       xsitl_tbl_type;
  xlstl_tbl       xlstl_tbl_type;

    TYPE all_rec_type IS RECORD (
            tai_id              NUMBER,
            til_id              NUMBER,
            tld_id              NUMBER,
            sel_id              NUMBER,
            xsi_id              NUMBER,
            xls_id              NUMBER,
            contract_number     okc_k_headers_b.contract_number%TYPE,
            stream_name         okl_strm_type_v.name%TYPE,
            bill_date           DATE,
            error_status        VARCHAR2(10)
	);

    TYPE all_rec_tbl_type IS TABLE OF all_rec_type
            INDEX BY BINARY_INTEGER;

    all_rec_tbl         	    all_rec_tbl_type;

    l_art_index                 NUMBER := 0;
    l_commit_cnt                NUMBER := 0;
	l_khr_id	okl_trx_ar_invoices_v.khr_id%TYPE := -1;
	l_bill_date	okl_trx_ar_invoices_v.date_invoiced%TYPE;
	l_kle_id	okl_txl_ar_inv_lns_v.kle_id%TYPE := -1;
	l_header_amount	okl_trx_ar_invoices_v.amount%TYPE;
	l_line_amount	okl_txl_ar_inv_lns_v.amount%TYPE;
	l_header_id	okl_trx_ar_invoices_v.id%TYPE;
	l_line_id	okl_txl_ar_inv_lns_v.id%TYPE;

      --  Bug 4524095 -- make break variables global
      l_line_number okl_txl_ar_inv_lns_v.line_number%TYPE;
      l_detail_number       okl_txd_ar_ln_dtls_v.line_detail_number%TYPE;
      --  End Code; Bug 4524095 -- make break variables global

    -- To enforce commit frequency
    -- Bug 4540379
    l_max_commit_cnt             NUMBER := 500;

    l_ext_customer_id         Okl_Ext_Sell_Invs_V.customer_id%TYPE;
    l_ext_receipt_method_id   Okl_Ext_Sell_Invs_V.receipt_method_id%TYPE;
    l_ext_term_id             Okl_Ext_Sell_Invs_V.term_id%TYPE;
    l_ext_sob_id              Okl_Ext_Sell_Invs_V.set_of_books_id%TYPE;
    l_ext_trx_type_id         Okl_Ext_Sell_Invs_V.cust_trx_type_id%TYPE;
    l_ext_addr_id             Okl_Ext_Sell_Invs_V.customer_address_id%TYPE;
    l_ext_cust_bank_id        Okl_Ext_Sell_Invs_V.customer_bank_account_id%TYPE;
    l_addr_id1                OKC_RULES_B.OBJECT1_ID1%TYPE;
    l_pmth_id1                OKC_RULES_B.OBJECT1_ID1%TYPE;
    l_bank_id1                OKC_RULES_B.OBJECT1_ID1%TYPE;
    l_rct_method_code 	      AR_RECEIPT_CLASSES.CREATION_METHOD_CODE%TYPE;
    l_asst_tax                OKC_RULES_B.rule_information1%TYPE;
    l_asst_line_tax           OKC_RULES_B.rule_information1%TYPE;
    l_product_id              okl_k_headers_full_v.pdt_id%TYPE;

    -- Multi Currency Compliance
    l_currency_code            OKL_EXT_SELL_INVS_B.currency_code%TYPE;
    l_currency_conversion_type OKL_EXT_SELL_INVS_B.currency_conversion_type%TYPE;
    l_currency_conversion_rate OKL_EXT_SELL_INVS_B.currency_conversion_rate%TYPE;
    l_currency_conversion_date OKL_EXT_SELL_INVS_B.currency_conversion_date%TYPE;
    l_func_curr_code           OKL_EXT_SELL_INVS_B.currency_code%TYPE;


    l_inf_id              okl_invoice_formats_v.id%TYPE;
    l_private_label  okc_rules_b.Rule_information1%type;
    -- End Bug 4540379

    -- For PPD process error reporting
    l_overall_err_sts   VARCHAR2(1);

-- -------------------------------------------------
-- To print log messages for tai_rec
-- -------------------------------------------------
PROCEDURE PRINT_TAI_REC(i_taiv_rec IN Okl_Tai_Pvt.taiv_rec_type)
IS
BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Start TAI Record (+)');
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.khr_id ' || i_taiv_rec.khr_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.date_invoiced ' || i_taiv_rec.date_invoiced);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.try_id ' || i_taiv_rec.try_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.date_entered ' || i_taiv_rec.date_entered);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.description ' || i_taiv_rec.description);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.trx_status_code ' || i_taiv_rec.trx_status_code);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.amount ' || i_taiv_rec.amount);

-- rmunjulu R12 Fixes -- added code for debug
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.ixx_id ' || i_taiv_rec.ixx_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.irm_id ' || i_taiv_rec.irm_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.irt_id ' || i_taiv_rec.irt_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.ibt_id ' || i_taiv_rec.ibt_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.cust_trx_type_id ' || i_taiv_rec.cust_trx_type_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.customer_bank_account_id ' || i_taiv_rec.customer_bank_account_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.org_id ' || i_taiv_rec.org_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.inf_id ' || i_taiv_rec.inf_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.invoice_pull_yn ' || i_taiv_rec.invoice_pull_yn);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.tax_exempt_flag ' || i_taiv_rec.tax_exempt_flag);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.currency_code ' || i_taiv_rec.currency_code);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.currency_conversion_type ' || i_taiv_rec.currency_conversion_type);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.currency_conversion_rate ' || i_taiv_rec.currency_conversion_rate);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.currency_conversion_date ' || i_taiv_rec.currency_conversion_date);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.private_label ' || i_taiv_rec.private_label);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_taiv_rec.set_of_books_id ' || i_taiv_rec.set_of_books_id);

          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End TAI Record (-)');
        END IF;
END PRINT_TAI_REC;

-- -------------------------------------------------
-- To print log messages for til_rec
-- -------------------------------------------------
PROCEDURE PRINT_TIL_REC(i_tilv_rec IN Okl_Til_Pvt.tilv_rec_type)
IS
BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Start TIL Record (+)');
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tilv_rec.kle_id ' || i_tilv_rec.kle_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tilv_rec.line_number ' || i_tilv_rec.line_number);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tilv_rec.tai_id ' || i_tilv_rec.tai_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tilv_rec.description ' || i_tilv_rec.description);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tilv_rec.inv_receiv_line_code ' || i_tilv_rec.inv_receiv_line_code);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tilv_rec.amount ' || i_tilv_rec.amount);

-- rmunjulu R12 Fixes -- added code for debug
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tilv_rec.ISL_ID ' || i_tilv_rec.ISL_ID);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tilv_rec.ORG_ID ' || i_tilv_rec.ORG_ID);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tilv_rec.inv_receiv_line_code ' || i_tilv_rec.inv_receiv_line_code);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tilv_rec.QUANTITY ' || i_tilv_rec.QUANTITY);

          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End TIL Record (-)');
        END IF;
END PRINT_TIL_REC;

-- -------------------------------------------------
-- To print log messages for tld_rec
-- -------------------------------------------------
PROCEDURE PRINT_TLD_REC(i_tldv_rec IN Okl_Tld_Pvt.tldv_rec_type)
IS
BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Start TLD Record (+)');
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tldv_rec.amount ' || i_tldv_rec.amount);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tldv_rec.description ' || i_tldv_rec.description);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tldv_rec.sel_id ' || i_tldv_rec.sel_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tldv_rec.sty_id ' || i_tldv_rec.sty_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tldv_rec.til_id_details ' || i_tldv_rec.til_id_details);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tldv_rec.line_detail_number ' || i_tldv_rec.line_detail_number);

-- rmunjulu R12 Fixes -- added code for debug
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tldv_rec.invoice_format_type ' || i_tldv_rec.invoice_format_type);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_tldv_rec.invoice_format_line_type ' || i_tldv_rec.invoice_format_line_type);

          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End TLD Record (-)');
        END IF;
END PRINT_TLD_REC;

-- -------------------------------------------------
-- To print log messages for xsi_rec
-- -------------------------------------------------
PROCEDURE PRINT_XSI_REC(i_xsiv_rec IN Okl_Xsi_Pvt.xsiv_rec_type)
IS
BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Start XSI Record (+)');
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.trx_date ' || i_xsiv_rec.trx_date);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.customer_id ' || i_xsiv_rec.customer_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.receipt_method_id ' || i_xsiv_rec.receipt_method_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.term_id ' || i_xsiv_rec.term_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.currency_code ' || i_xsiv_rec.currency_code);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.currency_conversion_type ' || i_xsiv_rec.currency_conversion_type);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.currency_conversion_rate ' || i_xsiv_rec.currency_conversion_rate);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.currency_conversion_date ' || i_xsiv_rec.currency_conversion_date);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.customer_address_id ' || i_xsiv_rec.customer_address_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.set_of_books_id ' || i_xsiv_rec.set_of_books_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.cust_trx_type_id ' || i_xsiv_rec.cust_trx_type_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.description ' || i_xsiv_rec.description);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.CUSTOMER_BANK_ACCOUNT_ID ' || i_xsiv_rec.CUSTOMER_BANK_ACCOUNT_ID);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.org_id ' || i_xsiv_rec.org_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.trx_status_code ' || i_xsiv_rec.trx_status_code);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.tax_exempt_flag ' || i_xsiv_rec.tax_exempt_flag);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xsiv_rec.tax_exempt_reason_code ' || i_xsiv_rec.tax_exempt_reason_code);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End XSI Record (-)');
        END IF;
END PRINT_XSI_REC;

-- -------------------------------------------------
-- To print log messages for xls_rec
-- -------------------------------------------------
PROCEDURE PRINT_XLS_REC(i_xlsv_rec IN Okl_Xls_Pvt.xlsv_rec_type)
IS
BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Start XLS Record (+)');

          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xlsv_rec.TLD_ID ' || i_xlsv_rec.TLD_ID);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xlsv_rec.XSI_ID_DETAILS ' || i_xlsv_rec.XSI_ID_DETAILS);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xlsv_rec.LINE_TYPE ' || i_xlsv_rec.LINE_TYPE);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xlsv_rec.DESCRIPTION ' || i_xlsv_rec.DESCRIPTION);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xlsv_rec.AMOUNT ' || i_xlsv_rec.AMOUNT);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xlsv_rec.ORG_ID ' || i_xlsv_rec.ORG_ID);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_xlsv_rec.SEL_ID ' || i_xlsv_rec.SEL_ID);

          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End XLS Record (-)');
        END IF;
END PRINT_XLS_REC;

-- -------------------------------------------------
-- To print log messages for esd_rec
-- -------------------------------------------------
PROCEDURE PRINT_ESD_REC(i_esdv_rec IN Okl_Esd_Pvt.esdv_rec_type)
IS
BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Start ESD Record (+)');
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_esdv_rec.code_combination_id ' || i_esdv_rec.code_combination_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_esdv_rec.xls_id ' || i_esdv_rec.xls_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_esdv_rec.amount ' || i_esdv_rec.amount);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_esdv_rec.percent ' || i_esdv_rec.percent);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i_esdv_rec.account_class ' || i_esdv_rec.account_class);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End ESD Record (-)');

        END IF;
END PRINT_ESD_REC;

  ------------------------------------------------------------------
  -- Function GET_TRX_TYPE to extract transaction type
  ------------------------------------------------------------------


  FUNCTION get_trx_type
	(p_name		VARCHAR2,
	p_language	VARCHAR2)
	RETURN		NUMBER IS

	CURSOR c_trx_type (cp_name VARCHAR2, cp_language VARCHAR2) IS
		SELECT	id
		FROM	OKL_TRX_TYPES_TL
		WHERE	name	= cp_name
		AND	LANGUAGE	= cp_language;

    -- Replace with following query
	CURSOR c_trx_id( p_sob_id   NUMBER, p_org_id   NUMBER ) IS
	   SELECT  ID1
	   FROM OKX_CUST_TRX_TYPES_V
	   WHERE name = 'Invoice-OKL' 			AND
	   		 set_of_books_id = p_sob_id 	AND
			 org_id			 = p_org_id;

	l_trx_type	okl_trx_types_v.id%TYPE;

  BEGIN

	l_trx_type := NULL;

	OPEN	c_trx_type (p_name, p_language);
	FETCH	c_trx_type INTO l_trx_type;
	CLOSE	c_trx_type;

	RETURN	l_trx_type;

  END get_trx_type;

  ------------------------------------------------------------------------------
  -- Function GET_PRINTING_LEAD_DAYS to extract lead days for invoice generation
  ------------------------------------------------------------------------------
  FUNCTION get_printing_lead_days
	(p_khr_id		NUMBER)
	RETURN		NUMBER IS

    -- Derive print lead days from the rules
    CURSOR c_lead_days(p_khr_id IN NUMBER) IS
	SELECT rule_information3
    FROM  okc_rules_b rule,
          okc_rule_groups_b rgp
    WHERE rgp.id = rule.rgp_id
    AND   rgp.dnz_chr_id = p_khr_id
    AND   rgd_code = 'LABILL'
    AND   rule_information_category = 'LAINVD';

  -- nikshah -- Bug # 5484903 Fixed,
  -- Changed CURSOR c_default_lead_days SQL definition
    --Derive print lead days from receivables setup
    CURSOR c_default_lead_days(p_khr_id IN NUMBER) IS
	SELECT term.printing_lead_days
    FROM  okc_k_headers_b khr
         ,hz_customer_profiles cp
         ,ra_terms_b term
    WHERE khr.id = p_khr_id
    AND khr.bill_to_site_use_id = cp.site_use_id
    AND cp.standard_terms = term.term_id;

    l_printing_lead_days NUMBER := 0;
  BEGIN
    OPEN c_lead_days(p_khr_id);
    FETCH c_lead_days INTO l_printing_lead_days;
    CLOSE c_lead_days;

    IF (l_printing_lead_days IS NULL) THEN
      OPEN c_default_lead_days(p_khr_id);
      FETCH c_default_lead_days INTO l_printing_lead_days;
      CLOSE c_default_lead_days;
    END IF;

    RETURN NVL(l_printing_lead_days, 0);
  END get_printing_lead_days;

  ------------------------------------------------------------------------------
  -- Function GET_BANKRUPTCY_STATUS to get the bankruptcy status of a contract.
  -- It also returns the disposition code.
  ------------------------------------------------------------------------------
  FUNCTION get_bankruptcy_status
   (p_khr_id NUMBER
   ,x_disposition_code OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

    l_bankruptcy_status VARCHAR2(10) := 'N';

    CURSOR l_bankrupt_csr(cp_khr_id NUMBER) IS
    SELECT DECODE(disposition_code, 'NEGOTIATION', 'Y', 'GRANTED', 'Y', NULL, 'Y', 'N') bankruptcy_status
           , disposition_code
    FROM iex_bankruptcies ban
    WHERE EXISTS (SELECT 1 FROM okc_k_party_roles_b rle
                  WHERE rle.dnz_chr_id = cp_khr_id
                  AND rle.rle_code = 'LESSEE'
                  AND TO_NUMBER(rle.object1_id1) = ban.party_id);

  BEGIN
    OPEN l_bankrupt_csr(p_khr_id);
    FETCH l_bankrupt_csr INTO l_bankruptcy_status, x_disposition_code;
    CLOSE l_bankrupt_csr;

    RETURN NVL(l_bankruptcy_status, 'N');
  END get_bankruptcy_status;

  ------------------------------------------------------------------
  -- Procedure BULK_PROCESS to bulk insert and bulk update
  ------------------------------------------------------------------
  PROCEDURE bulk_process
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
    ,p_commit           IN  VARCHAR2
    ,p_source           IN  VARCHAR2
 ) IS

	l_api_name	    CONSTANT VARCHAR2(30)  := 'BULK_PROCESS';
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_api_version	CONSTANT NUMBER := 1;

    CURSOR acc_dstrs_csr( p_source_id IN NUMBER, p_source_table IN VARCHAR2 ) IS
               SELECT  CR_DR_FLAG,
                       CODE_COMBINATION_ID,
                       SOURCE_ID,
                       AMOUNT,
                       PERCENTAGE,
                       NVL(COMMENTS,'-99') COMMENTS
               FROM OKL_TRNS_ACC_DSTRS
               WHERE SOURCE_ID    = p_source_id   AND
                     SOURCE_TABLE = p_source_table;

    CURSOR get_languages IS
        SELECT *
        FROM FND_LANGUAGES
        WHERE INSTALLED_FLAG IN ('I', 'B');


     -- Start : Bug#5964007 : PRASJAIN
     -- Cursor to check if 3 level credit memo is on-account
     CURSOR c_3level_cm(p_tld_id OKL_TXD_AR_LN_DTLS_B.ID%TYPE) IS
       SELECT 'X' FROM
           OKL_TXD_AR_LN_DTLS_B
       WHERE ID = p_tld_id
         AND TLD_ID_REVERSES IS NULL;

     l_on_acc_cm BOOLEAN;
     l_chk VARCHAR2(1);
     -- End : Bug#5964007 : PRASJAIN

    l_xtd_cnt               NUMBER := 0;
    l_xtdtl_cnt             NUMBER := 0;
    l_code_combination_id   NUMBER;
    l_acc_dist_status      VARCHAR2(1);


    TYPE xtd_tbl_type IS TABLE OF OKL_XTD_SELL_INVS_B%ROWTYPE INDEX BY BINARY_INTEGER;
	TYPE xtdtl_tbl_type IS TABLE OF OKL_XTD_SELL_INVS_TL%ROWTYPE INDEX BY BINARY_INTEGER;
    xtd_tbl       xtd_tbl_type;
    xtdtl_tbl       xtdtl_tbl_type;
	l_xtd_id    okl_xtd_sell_invs_v.id%TYPE;
	l_prev_tai_id OKL_TRX_AR_INVOICES_B.ID%TYPE := NULL;

	-------------------------------------
	-- Variables for bulk updates
	-------------------------------------

	l_tai_id_cnt	 NUMBER := 0;
	l_xsi_id_cnt     NUMBER := 0;
	l_sel_id_cnt     NUMBER := 0;

	TYPE num_tbl IS TABLE OF NUMBER INDEX  BY BINARY_INTEGER;

    tai_id_tbl    num_tbl;
    xsi_id_tbl    num_tbl;
    sel_id_tbl    num_tbl;

	------------------------------------------------------------
	-- Declare variables to call Accounting Engine.
	------------------------------------------------------------
	p_bpd_acc_rec					Okl_Acc_Call_Pub.bpd_acc_rec_type;

	------------------------------------------------------------
	-- For errors in Stream Elements Table
	------------------------------------------------------------
    l_distr_cnt             NUMBER := 0;

	------------------------------------------------------------
	-- Variables for Error Processing
	------------------------------------------------------------

    l_error_status               VARCHAR2(1);
    l_error_message              VARCHAR2(2000);
	l_err_tai_id  OKL_TRX_AR_INVOICES_B.ID%TYPE := NULL;
	l_rec_status	  VARCHAR2(10) := NULL;

    l_request_id                NUMBER(15);
    l_program_application_id    NUMBER(15);
    l_program_id                NUMBER(15);
    l_program_update_date       DATE;

    -- Start Bug 4520466
    dist_khr_id_tbl    num_tbl;

    dist_khr_indx      number;

    -- ----------------------
    -- Std Who columns
    -- ----------------------
    lx_last_updated_by     okl_k_control.last_updated_by%TYPE := Fnd_Global.USER_ID;
    lx_last_update_login   okl_k_control.last_update_login%TYPE := Fnd_Global.LOGIN_ID;
    lx_request_id          okl_k_control.request_id%TYPE := Fnd_Global.CONC_REQUEST_ID;
    lx_program_id          okl_k_control.program_id%TYPE := Fnd_Global.CONC_PROGRAM_ID;
    -- End Bug 4520466

---- Added by Vpanwar --- Code for new accounting API uptake
	l_tmpl_identify_rec    	    Okl_Account_Dist_Pub.TMPL_IDENTIFY_REC_TYPE;
  	l_dist_info_rec        		Okl_Account_Dist_Pub.DIST_INFO_REC_TYPE;
  	l_ctxt_val_tbl         		Okl_Account_Dist_Pub.CTXT_VAL_TBL_TYPE;
  	l_acc_gen_primary_key_tbl   Okl_Account_Dist_Pub.ACC_GEN_PRIMARY_KEY;

    l_tmpl_identify_tbl         Okl_Account_Dist_Pvt.TMPL_IDENTIFY_TBL_TYPE;
    l_dist_info_tbl             Okl_Account_Dist_Pvt.DIST_INFO_TBL_TYPE;
    l_ctxt_tbl                  Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
    l_acc_gen_tbl               Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;
   	l_template_out_tbl		    Okl_Account_Dist_Pvt.avlv_out_tbl_type;
	l_amount_out_tbl		    Okl_Account_Dist_Pvt.amount_out_tbl_type;
	l_trx_header_id             NUMBER;
    l_trx_header_tbl            VARCHAR2(50);
    l_curr_tai_id               NUMBER;
    l_prev_tld_counter          NUMBER;
	l_curr_til_counter          NUMBER;
    l_next_til_counter          NUMBER;
    l_accounting_dist_flag      BOOLEAN;
---- End Added by Vpanwar --- Code for new accounting API uptake


BEGIN

    IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
       Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE,'okl_stream_billing_pvt'
									,'Begin(+)');
    END IF;

    -- ------------------------
    -- Print Input variables
    -- ------------------------
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_commit '||p_commit);

    END IF;
	l_return_status := Okl_Api.START_ACTIVITY(
		p_api_name	=> l_api_name,
		p_pkg_name	=> G_PKG_NAME,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> x_return_status); -- rmunjulu bug 6736148  use x_return_status as out param

		--------------------------------------------
		-- Initialize request/program variables
		--------------------------------------------
		BEGIN
      	        SELECT
  	  	    	   DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
      	  		   DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
      	  		   DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
      	  		   DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
          	   INTO
  	  	           l_request_id,
          	  	   l_program_application_id,
          	  	   l_program_id,
          	  	   l_program_update_date
          	   FROM dual;
              EXCEPTION
                  WHEN OTHERS THEN
                      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'(Exception): When resolving request_id'||SQLERRM );
                      END IF;
                      Fnd_File.PUT_LINE (Fnd_File.LOG,'(Exception): When resolving request_id'||SQLERRM );
        END;

		--------------------------------------------------
		-- Bulk insert TAI, TIL, TLD, XSI and XLS records
		--------------------------------------------------

           -- --------------------------------------
           -- Transfer Tai records to the Tai table
           -- --------------------------------------
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       		   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inserting into okl_trx_ar_invoices_b');

     END IF;
           Fnd_File.PUT_LINE (Fnd_File.LOG, 'Transfering TAI records to TAI table...');

           Fnd_File.PUT_LINE (Fnd_File.LOG, 'tai_tbl.COUNT : ' || tai_tbl.COUNT);

           IF tai_tbl.COUNT > 0 THEN
              FORALL indx IN tai_tbl.first..tai_tbl.LAST
                INSERT INTO OKL_TRX_AR_INVOICES_B
                VALUES tai_tbl(indx);

                -- Start Bug 4520466
                -- update okl_k_control table

                -- Clear all table entries, if any
                dist_khr_id_tbl.delete;

                for i in tai_tbl.first..tai_tbl.last loop

                   FND_FILE.PUT_LINE (FND_FILE.LOG, 'tai_tbl(i).khr_id: '||tai_tbl(i).khr_id);

                   if dist_khr_id_tbl.count = 0 then

                       FND_FILE.PUT_LINE (FND_FILE.LOG, 'dist_khr_id_tbl.count: '||dist_khr_id_tbl.count);

                       dist_khr_indx := dist_khr_id_tbl.count + 1;
                       dist_khr_id_tbl(dist_khr_indx) := tai_tbl(i).khr_id;

                   else

                       FND_FILE.PUT_LINE (FND_FILE.LOG, 'dist_khr_id_tbl(dist_khr_indx): '||dist_khr_id_tbl(dist_khr_indx));
                       FND_FILE.PUT_LINE (FND_FILE.LOG, 'tai_tbl(i).khr_id: '||tai_tbl(i).khr_id);

                       if ( dist_khr_id_tbl(dist_khr_indx) <> tai_tbl(i).khr_id ) then

                           FND_FILE.PUT_LINE (FND_FILE.LOG, 'dist_khr_id_tbl(dist_khr_indx) <> tai_tbl(i).khr_id');

                           dist_khr_indx := dist_khr_id_tbl.count + 1;
                           dist_khr_id_tbl(dist_khr_indx) := tai_tbl(i).khr_id;

                       end if;
                   end if;
                end loop; -- for tai_tbl records
                -- End Bug 4520466

           END IF; -- if tai_tbl.COUNT > 0

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done Inserting into okl_trx_ar_invoices_b');

           END IF;
           Fnd_File.PUT_LINE (Fnd_File.LOG, 'Done transfering TAI records to TAI table...');
           -- --------------------------------------
           -- Transfer TaiTl records to the TaiTl table
           -- --------------------------------------
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inserting into okl_trx_ar_invoices_tl');

           END IF;
           Fnd_File.PUT_LINE (Fnd_File.LOG, 'Transfering TAI_TL records to TAI_TL table...');

           Fnd_File.PUT_LINE (Fnd_File.LOG, 'taitl_tbl.COUNT : ' || taitl_tbl.COUNT);

           IF taitl_tbl.COUNT > 0 THEN
              FORALL indx IN taitl_tbl.first..taitl_tbl.LAST
                INSERT INTO OKL_TRX_AR_INVOICES_TL
                VALUES taitl_tbl(indx);
           END IF;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done Inserting into okl_trx_ar_invoices_tl');

           END IF;
           Fnd_File.PUT_LINE (Fnd_File.LOG, 'Done transfering TAI_TL records to TAI_TL table...');
           -- --------------------------------------
           -- Transfer Til records to the Til table
           -- --------------------------------------
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inserting into okl_txl_ar_inv_lns_b');

           END IF;
           Fnd_File.PUT_LINE (Fnd_File.LOG, 'Transfering TIL records to TIL table...');

           Fnd_File.PUT_LINE (Fnd_File.LOG, 'til_tbl.COUNT : ' || til_tbl.COUNT);

           IF til_tbl.COUNT > 0 THEN
              FORALL indx IN til_tbl.first..til_tbl.LAST
                INSERT INTO OKL_TXL_AR_INV_LNS_B
                VALUES til_tbl(indx);
           END IF;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done Inserting into okl_txl_ar_inv_lns_b');

           END IF;
           Fnd_File.PUT_LINE (Fnd_File.LOG, 'Done transfering TIL records to TIL table...');
           -- --------------------------------------
           -- Transfer TilTl records to the TilTl table
           -- --------------------------------------
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inserting into okl_txl_ar_inv_lns_tl');

           END IF;
           Fnd_File.PUT_LINE (Fnd_File.LOG, 'Transfering TIL_TL records to TIL_TL table...');

           Fnd_File.PUT_LINE (Fnd_File.LOG, 'tiltl_tbl.COUNT : ' || tiltl_tbl.COUNT);

           IF tiltl_tbl.COUNT > 0 THEN
              FORALL indx IN tiltl_tbl.first..tiltl_tbl.LAST
                INSERT INTO OKL_TXL_AR_INV_LNS_TL
                VALUES tiltl_tbl(indx);
           END IF;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done Inserting into okl_txl_ar_inv_lns_tl');

           END IF;
           Fnd_File.PUT_LINE (Fnd_File.LOG, 'Done transfering TIL_TL records to TIL_TL table...');
           -- --------------------------------------
           -- Transfer Tld records to the Tld table
           -- --------------------------------------
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inserting into okl_txd_ar_ln_dtls_b');

           END IF;
           Fnd_File.PUT_LINE (Fnd_File.LOG, 'Transfering TLD records to TLD table...');

           Fnd_File.PUT_LINE (Fnd_File.LOG, 'tld_tbl.COUNT : ' || tld_tbl.COUNT);

           IF tld_tbl.COUNT > 0 THEN
              FORALL indx IN tld_tbl.first..tld_tbl.LAST
                INSERT INTO OKL_TXD_AR_LN_DTLS_B
                VALUES tld_tbl(indx);
           END IF;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done Inserting into okl_txd_ar_ln_dtls_b');

           END IF;
           Fnd_File.PUT_LINE (Fnd_File.LOG, 'Done transfering TLD records to TLD table...');
           -- --------------------------------------
           -- Transfer TldTl records to the TldTl table
           -- --------------------------------------
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inserting into okl_txd_ar_ln_dtls_tl');

           END IF;
           Fnd_File.PUT_LINE (Fnd_File.LOG, 'Transfering TLD_TL records to TLD_TL table...');

           Fnd_File.PUT_LINE (Fnd_File.LOG, 'tldtl_tbl.COUNT : ' || tldtl_tbl.COUNT);

           IF tldtl_tbl.COUNT > 0 THEN
              FORALL indx IN tldtl_tbl.first..tldtl_tbl.LAST
                INSERT INTO OKL_TXD_AR_LN_DTLS_TL
                VALUES tldtl_tbl(indx);
           END IF;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done Inserting into okl_txd_ar_ln_dtls_tl');

           END IF;
           Fnd_File.PUT_LINE (Fnd_File.LOG, 'Done transfering TLD_TL records to TLD_TL table...');
           -- --------------------------------------
           -- Transfer Xsi records to the Xsi table
           -- --------------------------------------
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inserting into okl_ext_sell_invs_b');

           END IF;
    -- ---------------------------------------------
    -- Create distributions using Accounting Enginge
    -- ---------------------------------------------

    Fnd_File.PUT_LINE (Fnd_File.LOG, 'Creating Acct Distributions...'); -- and XTD, XTD_TL records...'); -- rmunjulu R12 Fixes commented

    IF tld_tbl.COUNT > 0 THEN  -- rmunjulu R12 Fixes changed to tld
    ---- Added by Vpanwar --- Code for new accounting API uptake
    l_curr_til_counter := til_tbl.FIRST;
    l_prev_tld_counter := tld_tbl.FIRST;

    LOOP
        l_curr_tai_id := til_tbl(l_curr_til_counter).tai_id;
        FOR i IN l_prev_tld_counter..tld_tbl.LAST LOOP  -- rmunjulu R12 Fixes changed to tld
        ---- End Added by Vpanwar --- Code for new accounting API uptake
            l_acc_dist_status          := 'S';
            l_error_message            := NULL;
            p_bpd_acc_rec.id           := tld_tbl(i).id; --xls_tbl(i).tld_id;  -- rmunjulu R12 Fixes changed to tld
            p_bpd_acc_rec.source_table := 'OKL_TXD_AR_LN_DTLS_B';

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Transaction Line Id '||p_bpd_acc_rec.id);
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Transaction Source Table '||p_bpd_acc_rec.source_table);
            END IF;

            ---- Added by Vpanwar --- Code for new accounting API uptake
            l_prev_tld_counter := i;

            IF tld_tbl(i).TIL_ID_DETAILS = til_tbl(l_curr_til_counter).id THEN
                Okl_Acc_Call_Pub.CREATE_ACC_TRANS_NEW(p_api_version     =>  p_api_version,
                                            p_init_msg_list             =>  p_init_msg_list,
                                            x_return_status             =>  l_return_status,
                                            x_msg_count                 =>  x_msg_count,
                                            x_msg_data                  =>  x_msg_data,
                                            p_bpd_acc_rec               =>  p_bpd_acc_rec,
                                            x_tmpl_identify_rec         =>  l_tmpl_identify_rec,
                                            x_dist_info_rec             =>  l_dist_info_rec,
                                            x_ctxt_val_tbl              =>  l_ctxt_val_tbl,
                                            x_acc_gen_primary_key_tbl   =>  l_acc_gen_primary_key_tbl);

                IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                    IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        x_return_status := l_return_status;
                    END IF;
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                END IF;

                --- populate the tables for passing to Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST

                l_acc_gen_tbl(i).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
                l_acc_gen_tbl(i).source_id       := l_dist_info_rec.source_id;

                l_ctxt_tbl(i).ctxt_val_tbl       := l_ctxt_val_tbl;
                l_ctxt_tbl(i).source_id          := l_dist_info_rec.source_id;

                l_tmpl_identify_tbl(i)           := l_tmpl_identify_rec;

                l_dist_info_tbl(i)               := l_dist_info_rec;

                ---- End populate the tables for passing to Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST

                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'AE Call: x_return_status '||x_return_status);
                END IF;

                l_accounting_dist_flag := TRUE;

            ELSE
                IF l_accounting_dist_flag THEN
                    EXIT;
                END IF;
            END IF;
        END LOOP;------ end loop for tld_tbl
        ---- End Added by Vpanwar --- Code for new accounting API uptake

        ---- Added by Vpanwar --- Code for new accounting API uptake


        l_next_til_counter := til_tbl.next(l_curr_til_counter);
		if (l_next_til_counter is  null) OR ((til_tbl(l_next_til_counter).tai_id <> l_curr_tai_id)) THEN
		        l_trx_header_tbl:= 'okl_trx_ar_invoices_b';
                l_trx_header_id := l_curr_tai_id; --- need to be correct
                --Call accounting with new signature
                Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
                                  p_api_version        => p_api_version,
                                  p_init_msg_list      => p_init_msg_list,
                                  x_return_status      => x_return_status,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data,
                                  p_tmpl_identify_tbl  => l_tmpl_identify_tbl,
                                  p_dist_info_tbl      => l_dist_info_tbl,
                                  p_ctxt_val_tbl       => l_ctxt_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                  x_template_tbl       => l_template_out_tbl,
                                  x_amount_tbl         => l_amount_out_tbl,
			                      p_trx_header_id      => l_trx_header_id,
                                  p_trx_header_table   => l_trx_header_tbl);

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                --DELETE local tables
                l_acc_gen_tbl.DELETE;
                l_ctxt_tbl.DELETE;
                l_tmpl_identify_tbl.DELETE;
                l_dist_info_tbl.DELETE;

        END IF;
        l_curr_til_counter := l_next_til_counter;

        EXIT WHEN l_curr_til_counter is null;

    END LOOP; -- Accounting Engine Loop
        ---- End Added by Vpanwar --- Code for new accounting API uptake

    END IF;

    Fnd_File.PUT_LINE (Fnd_File.LOG, 'Done creating Acct Distributions...'); -- and XTD, XTD_TL records...'); -- rmunjulu R12 Fixes commented

    -----------------------------------------------------
	-- Move tai, xsi and sel records to different tables
	-- for bulk updates
	-----------------------------------------------------

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'all_rec_tbl.count : ' || all_rec_tbl.COUNT);
 END IF;
    IF all_rec_tbl.COUNT > 0 THEN
    FOR i IN all_rec_tbl.first..all_rec_tbl.last LOOP
	  IF l_prev_tai_id IS NULL OR all_rec_tbl(i).tai_id <> l_prev_tai_id THEN
	    l_rec_status := all_rec_tbl(i).error_status;
		IF l_rec_status IS NULL THEN
	      tai_id_tbl(l_tai_id_cnt) := all_rec_tbl(i).tai_id;
		  l_tai_id_cnt := l_tai_id_cnt + 1;
	    END IF;
	  END IF;
-- rmunjulu R12 Fixes comment XSI
	  IF l_rec_status IS NULL THEN
--	      xsi_id_tbl(l_xsi_id_cnt) := all_rec_tbl(i).xsi_id;
--		  l_xsi_id_cnt := l_xsi_id_cnt + 1;
		  sel_id_tbl(l_sel_id_cnt) := all_rec_tbl(i).sel_id;
		  l_sel_id_cnt := l_sel_id_cnt + 1;
	  END IF;

      l_prev_tai_id := all_rec_tbl(i).tai_id;
    END LOOP;
	END IF;

	-- ---------------------------------------------------
    -- Flag internal transaction to status of Processed
    -- ---------------------------------------------------
 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'tai_id_tbl.count : ' || tai_id_tbl.COUNT);
 END IF;
	IF tai_id_tbl.COUNT > 0 THEN
      FORALL indx IN tai_id_tbl.FIRST..tai_id_tbl.LAST
             UPDATE okl_trx_ar_invoices_b
             SET trx_status_code = 'SUBMITTED' -- 'PROCESSED' -- rmunjulu R12 Fixes changed to submitted IS THIS CORRECT
             WHERE id = tai_id_tbl(indx);
	END IF;
	-- ---------------------------------------------------
    -- Set stream elements to billed status
    -- ---------------------------------------------------
 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'sel_id_tbl.count : ' || sel_id_tbl.COUNT);
 END IF;
	IF sel_id_tbl.COUNT > 0 THEN
      FORALL indx IN sel_id_tbl.FIRST..sel_id_tbl.LAST
             UPDATE okl_strm_elements
             SET date_billed = SYSDATE
             WHERE id = sel_id_tbl(indx);
	END IF;

    -- Start Bug 4520466 stmathew update okl_k_control

    if dist_khr_id_tbl.count > 0 then
          forall indx in dist_khr_id_tbl.first..dist_khr_id_tbl.last
          save exceptions
               UPDATE okl_k_control nbd
               set EARLIEST_STRM_BILL_DATE = (
                                SELECT	MIN(ste.stream_element_date)
                               	FROM	OKL_STRM_ELEMENTS		ste,
                            			OKL_STREAMS			    stm,
                            			okl_strm_type_v			sty,
                            			okc_k_headers_b			khr,
                            			OKL_K_HEADERS			khl,
                            			okc_k_lines_b			kle,
                            			okc_statuses_b			khs,
                            			okc_statuses_b			kls
                        		WHERE ste.amount 	    <> 0
                        		AND	stm.id				= ste.stm_id
                        		AND	ste.date_billed		IS NULL
                        		AND	stm.active_yn		= 'Y'
                        		AND	stm.say_code		= 'CURR'
                        		AND	sty.id				= stm.sty_id
                        		AND	sty.billable_yn		= 'Y'
                        		AND	khr.id				= stm.khr_id
                            	AND	khr.scs_code		IN ('LEASE', 'LOAN', 'INVESTOR')
                                AND khr.sts_code        IN ( 'BOOKED','EVERGREEN','TERMINATED', 'EXPIRED', 'ACTIVE') -- bug 6472228 added EXPIRED status
                        		AND	khr.id	= nbd.khr_id
                        		AND	khl.id				= stm.khr_id
                        		AND	(khl.deal_type		IS NOT NULL  OR khr.sts_code = 'ACTIVE')
                        		AND	khs.code			= khr.sts_code
                        		AND	kle.id			(+)	= stm.kle_id
                        		AND	kls.code		(+)	= kle.sts_code
                                AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED', 'EXPIRED') ), -- bug 6472228 added EXPIRED status
                    last_update_date = sysdate,
                    last_updated_by = lx_last_updated_by,
                    last_update_login = lx_last_update_login,
                    request_id = lx_request_id,
                    program_update_date = sysdate,
                    program_id = lx_program_id
               where nbd.khr_id =  dist_khr_id_tbl(indx);

               if sql%bulk_exceptions.count > 0 then
                    for i in 1..sql%bulk_exceptions.count loop
                              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'while fetching, error ' || i || ' occurred during '||
                                    'iteration ' || sql%bulk_exceptions(i).error_index);
                                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'oracle error is ' ||
                                    sqlerrm(sql%bulk_exceptions(i).error_code));
                              END IF;
                    end loop;
               end if; -- if sql bulk_exceptions > 0
    end if; -- if dist_khr_id_tbl count > 0

    dist_khr_id_tbl.delete;

    -- End Bug 4520466 stmathew update okl_k_control

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done updating status of records in tai and sel database tables'); -- rmunjulu R12 Fixes REMOVED XSI FROM COMMENTS

    END IF;
    Fnd_File.PUT_LINE (Fnd_File.LOG, 'Done updating status of records in tai and sel database tables'); -- rmunjulu R12 Fixes REMOVED XSI FROM COMMENTS

    -----------------------
	-- Commit
	-----------------------
	IF Fnd_Api.To_Boolean( p_commit ) THEN
          COMMIT;
    END IF;

	------------------------------------------
	-- Clean up the tables after processing
	------------------------------------------

    tai_tbl.DELETE;
    til_tbl.DELETE;
    tld_tbl.DELETE;

    taitl_tbl.DELETE;
    tiltl_tbl.DELETE;
    tldtl_tbl.DELETE;

	tai_id_tbl.DELETE;
    sel_id_tbl.DELETE;

	all_rec_tbl.DELETE;
	l_art_index := 0;

    l_tai_cnt  := 1;
    l_til_cnt  := 0;
    l_tld_cnt  := 0;

    l_taitl_cnt   := 0;
    l_tiltl_cnt   := 0;
    l_tldtl_cnt   := 0;

    IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
       Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE,'okl_stream_billing_pvt'
									,'End(-)');
    END IF;

	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);


  EXCEPTION

	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (EXCP) => '||SQLERRM);

            IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_stream_billing_pvt',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
            END IF;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (UNEXP) => '||SQLERRM);

        IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
            Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_stream_billing_pvt',
               'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (OTHERS 1) => '||SQLERRM);

        IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
            Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_stream_billing_pvt',
               'EXCEPTION :'||'OTHERS');
        END IF;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

  END bulk_process;

  ------------------------------------------------------------------
  -- Procedure Process_bill_tbl to bill outstanding stream elements
  ------------------------------------------------------------------
  PROCEDURE Process_bill_tbl
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
    ,p_commit           IN  VARCHAR2
	,p_contract_number	IN  VARCHAR2
	,p_from_bill_date	IN  DATE
	,p_to_bill_date		IN  DATE
    ,p_bill_tbl         IN  bill_tbl_type
    ,p_source           IN  VARCHAR2
	,p_end_of_records   IN  VARCHAR2)
  IS

--cklee: start 3/16/07
    cursor c_seq is
	SELECT OKL_TXD_AR_LN_DTLS_B_S.NEXTVAL
	FROM dual;
    l_seq number;
--cklee: start 3/16/07

	------------------------------------------------------------
	-- Get trx_id for Invoice
	------------------------------------------------------------
	CURSOR c_trx_id( p_sob_id   NUMBER, p_org_id   NUMBER ) IS
	   SELECT  ID1
	   FROM OKX_CUST_TRX_TYPES_V
	   WHERE name = 'Invoice-OKL' 			AND
	   		 set_of_books_id = p_sob_id 	AND
			 org_id			 = p_org_id;

	------------------------------------------------------------
	-- Get trx_id for Credit Memo
	------------------------------------------------------------
	CURSOR c_trx_id1( p_sob_id   NUMBER, p_org_id   NUMBER ) IS
	   SELECT  ID1
	   FROM OKX_CUST_TRX_TYPES_V
	   WHERE name = 'Credit Memo-OKL'   	AND
	   		 set_of_books_id = p_sob_id 	AND
			 org_id			 = p_org_id;

	l_api_name	    CONSTANT VARCHAR2(30)  := 'PROCESS_BILL_TBL';

	------------------------------------------------------------
	-- Initialise constants
	------------------------------------------------------------
	l_def_desc	    CONSTANT VARCHAR2(30)	:= 'Regular Stream Billing';
	l_line_code	    CONSTANT VARCHAR2(30)	:= 'LINE';
	l_init_status	CONSTANT VARCHAR2(30)	:= 'ENTERED';
	l_final_status	CONSTANT VARCHAR2(30)	:= 'PROCESSED';
	l_trx_type_name	CONSTANT VARCHAR2(30)	:= 'Billing';
	l_trx_type_lang	CONSTANT VARCHAR2(30)	:= 'US';
	l_date_entered	CONSTANT DATE		    := SYSDATE;
	l_zero_amount	CONSTANT NUMBER		    := 0;
	l_first_line	CONSTANT NUMBER		    := 1;
	l_line_step	    CONSTANT NUMBER		    := 1;
	l_def_no_val	CONSTANT NUMBER		    := -1;
	l_null_kle_id	CONSTANT NUMBER		    := -2;

	------------------------------------------------------------
	-- Declare records: i - insert, u - update, r - result
	------------------------------------------------------------

	-- Transaction headers
	i_taiv_rec	Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
	u_taiv_rec	Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
	r_taiv_rec	Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;

	-- Transaction lines
	i_tilv_rec	Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
	u_tilv_rec	Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
	r_tilv_rec	Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;

	-- Transaction line details
	i_tldv_rec	        Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
	u_tldv_rec	        Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
        l_init_tldv_rec     Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
	r_tldv_rec	        Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;

	-- Ext Transaction Header
	i_xsiv_rec	        Okl_Ext_Sell_Invs_Pub.xsiv_rec_type;
    l_init_xsiv_rec     Okl_Ext_Sell_Invs_Pub.xsiv_rec_type;
	r_xsiv_rec	        Okl_Ext_Sell_Invs_Pub.xsiv_rec_type;

	-- Ext Transaction Lines
	i_xlsv_rec	        Okl_Xtl_Sell_Invs_Pub.xlsv_rec_type;
    l_init_xlsv_rec     Okl_Xtl_Sell_Invs_Pub.xlsv_rec_type;
	r_xlsv_rec	        Okl_Xtl_Sell_Invs_Pub.xlsv_rec_type;

	-- Ext Transaction Details
	i_esdv_rec	        Okl_Xtd_Sell_Invs_Pub.esdv_rec_type;
        l_init_esdv_rec     Okl_Xtd_Sell_Invs_Pub.esdv_rec_type;
	r_esdv_rec	        Okl_Xtd_Sell_Invs_Pub.esdv_rec_type;


	------------------------------------------------------------
	-- Declare local variables used in the program
	------------------------------------------------------------

	l_trx_type	     okl_trx_ar_invoices_v.try_id%TYPE;
        l_use_trx_type       okl_trx_ar_invoices_v.try_id%TYPE;
        l_legal_entity_id    okl_trx_ar_invoices_v.legal_entity_id%TYPE;  -- for LE Uptake project 08-11-2006
        l_x_legal_entity_id  okl_ext_sell_invs_b.legal_entity_id%TYPE; -- for LE Uptake project 08-11-2006

      -- Bug 4524095
	--l_line_number	okl_txl_ar_inv_lns_v.line_number%TYPE;
	--l_detail_number	okl_txd_ar_ln_dtls_v.line_detail_number%TYPE;
	l_tld_id    okl_txd_ar_ln_dtls_v.id%TYPE;
	l_xsi_id    okl_ext_sell_invs_v.id%TYPE;
	l_xls_id    okl_xtl_sell_invs_v.id%TYPE;

	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------

	l_api_version	CONSTANT NUMBER := 1;
	l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

	------------------------------------------------------------
	-- Variables for Error Processing and Committing Stream Billing
    -- Transactions
	------------------------------------------------------------

    l_error_status               VARCHAR2(1);
    l_error_message              VARCHAR2(2000);
    l_trx_status_code            Okl_trx_ar_invoices_v.trx_status_code%TYPE;


    -- For currecy precision rounded amount
    l_ste_amount                 OKL_STRM_ELEMENTS.amount%TYPE := 0;
    l_curr_code                  okc_k_headers_b.currency_code%TYPE;

    -------------------------------------------------------------------------
    -- Account Builder Code
    -------------------------------------------------------------------------
  	l_acc_gen_primary_key_tbl  		Okl_Account_Dist_Pub.acc_gen_primary_key;
  	l_init_acc_gen_primary_key_tbl  Okl_Account_Dist_Pub.acc_gen_primary_key;


    TYPE sel_err_rec_type IS RECORD (
            sel_id              NUMBER,
            tld_id              NUMBER,
            xsi_id              NUMBER,
			bill_date           DATE,
			contract_number     okc_k_headers_b.contract_number%TYPE,
			stream_name         okl_strm_type_v.name%TYPE,
			amount              OKL_STRM_ELEMENTS.amount%TYPE,
            error_message       VARCHAR2(2000)
	);

    TYPE sel_err_tbl_type IS TABLE OF sel_err_rec_type
            INDEX BY BINARY_INTEGER;

    sel_error_log_table 	    sel_err_tbl_type;
    l_init_sel_table            sel_err_tbl_type;

    l_sel_tab_index             NUMBER;

	------------------------------------------------------------
	-- Cursors for Rule based values
	------------------------------------------------------------
    --added for rules migration
    CURSOR cust_id_csr(p_khr_id  NUMBER) IS
        SELECT cust_acct_id
        FROM okc_k_headers_v
        WHERE id = p_khr_id;

   --added for rules migration
   CURSOR cust_acct_csr (p_khr_id NUMBER) IS
        SELECT cs.cust_acct_site_id
             , cp.standard_terms payment_term_id
        FROM okc_k_headers_v khr
           , okx_cust_site_uses_v cs
           , hz_customer_profiles cp
        WHERE khr.id = p_khr_id
        AND khr.bill_to_site_use_id = cs.id1
        AND khr.bill_to_site_use_id = cp.site_use_id(+);

  -- nikshah -- Bug # 5484903 Fixed,
  -- Changed CURSOR line_bill_to_csr SQL definition
   CURSOR line_bill_to_csr(p_khr_id NUMBER, p_kle_id NUMBER) IS
        SELECT cs.cust_acct_site_id, cp.standard_terms payment_term_id
        FROM okc_k_headers_b khr
           , okx_cust_site_uses_v cs
           , okc_k_lines_b cle
           , hz_customer_profiles cp
        WHERE khr.id = p_khr_id
        AND cle.dnz_chr_id = khr.id
        AND cle.chr_id IS NOT NULL
        AND cle.id = p_kle_id
        AND cle.BILL_TO_SITE_USE_ID = cs.id1
        AND khr.bill_to_site_use_id = cp.site_use_id(+)
        UNION
        SELECT cs.cust_acct_site_id, cp.standard_terms payment_term_id
        FROM okc_k_headers_b khr
           , okc_k_lines_b cle
           , okc_k_items item
           , okc_k_lines_b linked_asset
           , okx_cust_site_uses_v cs
           , hz_customer_profiles cp
        WHERE khr.id = p_khr_id
        AND cle.dnz_chr_id = khr.id
        AND cle.id = p_kle_id
        AND cle.chr_id IS NULL
        AND cle.id = item.cle_id
        AND item.object1_id1 = linked_asset.id
        AND linked_asset.BILL_TO_SITE_USE_ID = cs.id1
        AND khr.bill_to_site_use_id = cp.site_use_id(+);

   -- Receipt Method Or Payment method
   CURSOR cust_pmth_csr ( p_khr_id NUMBER ) IS
        SELECT  object1_id1
        FROM OKC_RULES_B       rul,
             Okc_rule_groups_B rgp
        WHERE rul.rgp_id     = rgp.id                  AND
              rgp.rgd_code   = 'LABILL'                AND
              rgp.dnz_chr_id = rgp.chr_id              AND
              rul.rule_information_category = 'LAPMTH' AND
              rgp.dnz_chr_id = p_khr_id;

   CURSOR cust_line_pmth_csr ( p_khr_id NUMBER, p_kle_id NUMBER ) IS
        SELECT  object1_id1
        FROM OKC_RULES_B       rul,
             Okc_rule_groups_B rgp
        WHERE rul.rgp_id     = rgp.id                  AND
              rgp.rgd_code   = 'LABILL'                AND
              rgp.cle_id     = p_kle_id                AND
              rul.rule_information_category = 'LAPMTH' AND
              rgp.dnz_chr_id = p_khr_id
        UNION
        SELECT  rul.object1_id1
        FROM okc_k_lines_b cle
            , okc_k_items_v item
            , okc_k_lines_b linked_asset
            , OKC_RULES_B       rul
            , Okc_rule_groups_B rgp
        WHERE cle.dnz_chr_id = p_khr_id                AND
              cle.id = p_kle_id                        AND
              cle.chr_id IS NULL                       AND
              cle.id = item.cle_id                     AND
              item.object1_id1 = linked_asset.id       AND
              linked_asset.id = rgp.cle_id             AND
              linked_asset.dnz_chr_id = rgp.dnz_chr_id AND
              rgp.rgd_code   = 'LABILL'                AND
              rul.rgp_id     = rgp.id                  AND
              rul.rule_information_category = 'LAPMTH';


    CURSOR rcpt_mthd_csr(p_cust_rct_mthd NUMBER) IS
 	   SELECT C.RECEIPT_METHOD_ID
	   FROM RA_CUST_RECEIPT_METHODS C
	   WHERE C.cust_receipt_method_id = p_cust_rct_mthd;

   -- Bank Account Cursor
   CURSOR rcpt_method_csr ( p_rct_method_id  NUMBER) IS
	   SELECT C.CREATION_METHOD_CODE
	   FROM  AR_RECEIPT_METHODS M,
       		 AR_RECEIPT_CLASSES C
	   WHERE  M.RECEIPT_CLASS_ID = C.RECEIPT_CLASS_ID AND
	   		  M.receipt_method_id = p_rct_method_id;

   CURSOR cust_bank_csr ( p_khr_id NUMBER ) IS
        SELECT  object1_id1
        FROM OKC_RULES_B       rul,
             Okc_rule_groups_B rgp
        WHERE rul.rgp_id     = rgp.id                  AND
              rgp.rgd_code   = 'LABILL'                AND
              rgp.dnz_chr_id = rgp.chr_id              AND
              rul.rule_information_category = 'LABACC' AND
              rgp.dnz_chr_id = p_khr_id;

   CURSOR cust_line_bank_csr ( p_khr_id NUMBER, p_kle_id NUMBER ) IS
        SELECT  object1_id1
        FROM OKC_RULES_B       rul,
             Okc_rule_groups_B rgp
        WHERE rul.rgp_id     = rgp.id                  AND
              rgp.cle_id     = p_kle_id                AND
              rgp.rgd_code   = 'LABILL'                AND
              rul.rule_information_category = 'LABACC' AND
              rgp.dnz_chr_id = p_khr_id
        UNION
        SELECT  rul.object1_id1
        FROM okc_k_lines_b cle
            , okc_k_items_v item
            , okc_k_lines_b linked_asset
            , OKC_RULES_B       rul
            , Okc_rule_groups_B rgp
        WHERE cle.dnz_chr_id = p_khr_id                AND
              cle.id = p_kle_id                        AND
              cle.chr_id IS NULL                       AND
              cle.id = item.cle_id                     AND
              item.object1_id1 = linked_asset.id       AND
              linked_asset.id = rgp.cle_id             AND
              linked_asset.dnz_chr_id = rgp.dnz_chr_id AND
              rgp.rgd_code   = 'LABILL'                AND
              rul.rgp_id     = rgp.id                  AND
              rul.rule_information_category = 'LABACC';

   CURSOR bank_acct_csr(p_id1 NUMBER) IS
	   SELECT bank_account_id
	   FROM OKX_RCPT_METHOD_ACCOUNTS_V
	   WHERE id1 = p_id1;

    --Get currency conversion attributes for a contract
    CURSOR l_curr_conv_csr( cp_khr_id  NUMBER ) IS
        SELECT  currency_code
               ,currency_conversion_type
               ,currency_conversion_rate
               ,currency_conversion_date
        FROM    okl_k_headers_full_v
        WHERE   id = cp_khr_id;

  -- nikshah -- Bug # 5484903 Fixed,
  -- Changed CURSOR std_terms_csr SQL definition
    -- Default term Id
    CURSOR std_terms_csr  IS
           SELECT B.term_id
           FROM ra_terms_b b, ra_terms_tl t
           WHERE t.name = 'IMMEDIATE'
             and B.TERM_ID = T.TERM_ID
             and T.LANGUAGE = userenv('LANG');

    --Get product Id
    CURSOR pdt_id_csr( p_khr_id  NUMBER ) IS
        SELECT  pdt_id
        FROM okl_k_headers_full_v
        WHERE id = p_khr_id;
    -- Variables for XTD Accounting Distributions

    l_esd_acc_cc_id     OKL_AE_TMPT_LNES.code_combination_id%TYPE;
    l_esd_ae_ln_type    OKL_AE_TMPT_LNES.ae_line_type%TYPE;
    l_esd_crd_code      OKL_AE_TMPT_LNES.crd_code%TYPE;
    l_esd_acc_bldr_yn   OKL_AE_TMPT_LNES.account_builder_yn%TYPE;
    l_esd_percentage    OKL_AE_TMPT_LNES.percentage%TYPE;
    l_esd_amount        OKL_XTD_SELL_INVS_V.amount%TYPE;

    -- Create Distributions
    CURSOR dstrs_csr( p_pdt_id NUMBER, p_try_id NUMBER, p_sty_id NUMBER, p_date DATE) IS
           SELECT
            C.CODE_COMBINATION_ID,
            C.AE_LINE_TYPE,
            C.CRD_CODE,
            C.ACCOUNT_BUILDER_YN,
            C.PERCENTAGE
           FROM OKL_AE_TEMPLATES A,
                OKL_PRODUCTS_V     B,
                OKL_AE_TMPT_LNES C
           WHERE A.aes_id = b.aes_id AND
                 A.start_date <= p_date AND
                 (A.end_date IS NULL OR A.end_date >= p_date) AND
                 A.memo_yn = 'N' AND
                 b.id     = p_pdt_id AND
                 a.sty_id = p_sty_id AND
                 a.try_id = p_try_id AND
                 C.avl_id = A.id;

    --added variables for bankruptcy hold
    l_turnoff_inv_on_bankruptcy VARCHAR2(1) := 'N';
    l_disposition_code iex_bankruptcies.disposition_code%TYPE;
    l_bankruptcy_flag VARCHAR2(1) := 'N';
    l_previous_khr OKL_K_HEADERS.khr_id%TYPE;

    -- -------------------------------------------
    -- To support new fields in XSI and XLS
    -- -------------------------------------------
    -- rseela BUG# 4733028 Start: fetching review invoice flag
    CURSOR inv_frmt_csr(cp_khr_id IN NUMBER) IS
        SELECT to_number(rul.rule_information1), --inf.id,  --sechawla 26-may-09 6826580
		       rul.rule_information4 review_invoice_yn
        FROM okc_rule_groups_v      rgp,
            okc_rules_v            rul
          --  ,okl_invoice_formats_v  inf --sechawla 26-may-09 6826580
        WHERE rgp.dnz_chr_id = cp_khr_id                         AND
        rgp.chr_id             = rgp.dnz_chr_id                  AND
        rgp.id                 = rul.rgp_id                      AND
        rgp.cle_id             IS NULL                           AND
        rgp.rgd_code           = 'LABILL'                        AND
        rul.rule_information_category = 'LAINVD'   ;
      -- AND rul.rule_information1 = inf.name;

  -- Bug 4540379
  --l_inf_id              okl_invoice_formats_v.id%TYPE;
  -- End Bug 4540379

  CURSOR get_languages IS
      SELECT *
      FROM FND_LANGUAGES
      WHERE INSTALLED_FLAG IN ('I', 'B');

  l_request_id                NUMBER(15);
  l_program_application_id    NUMBER(15);
  l_program_id                NUMBER(15);
  l_program_update_date       DATE;
  l_review_invoice_yn         okc_rules_v.rule_information4%type;

  -- -------------------------------------------
  -- To support private label transfers to
  -- AR. Bug 4525643
  -- -------------------------------------------
  CURSOR pvt_label_csr(cp_khr_id IN NUMBER) IS
      SELECT Rule_information1 PRIVATE_LABEL
      FROM okc_rule_groups_b A,
           okc_rules_b B
      WHERE A.DNZ_CHR_ID = CP_KHR_ID
      AND A.rgd_code = 'LALABL'
      AND A.id = B.rgp_id
      AND B.rule_information_category = 'LALOGO';

  -- Bug 4540379
  --l_private_label  okc_rules_b.Rule_information1%type;
  -- End Bug 4540379

    -- to get inventory_org_id   bug 4890024 begin
    CURSOR inv_org_id_csr ( p_khr_id NUMBER ) IS
       SELECT nvl(inv_organization_id,-99)
       FROM okc_k_headers_b
       WHERE id = p_khr_id;
    -- bug 4890024 end

-- modified by zrehman for Bug#6788005 on 07-Feb-2008 start
    CURSOR check_if_inv(p_khr_id NUMBER ) IS
       SELECT 1
       FROM okc_k_headers_all_b
       WHERE id = p_khr_id
       AND scs_code = 'INVESTOR';
    l_is_inv NUMBER := 0;
-- get cust_acct_id and cust_acct_site_id for investor fees
    CURSOR get_inv_cust_info(p_khr_id NUMBER, p_kle_id NUMBER) IS
     SELECT cle_inv.cust_acct_id, cs.cust_acct_site_id, hz.party_name
        FROM okc_k_headers_b khr
           , okx_cust_site_uses_v cs
           , okc_k_lines_b cle
           , okc_k_lines_b cle_inv
           , okc_k_party_roles_b cpl
           , okc_k_party_roles_b cpl_inv
	   , hz_parties hz
        WHERE khr.id = p_khr_id
        AND cle.dnz_chr_id = khr.id
        AND cle_inv.dnz_chr_id = khr.id
        AND cpl.rle_code = 'INVESTOR'
        AND cpl_inv.rle_code = 'INVESTOR'
        and cpl.cle_id = cle.id
        AND cpl.object1_id1 = cpl_inv.object1_id1
        AND cpl_inv.cle_id = cle_inv.id
        AND cle_inv.lse_id = 65
        AND cle.chr_id IS NOT NULL
        AND cle_inv.chr_id IS NOT NULL
        AND cle.id = p_kle_id
        AND cle_inv.BILL_TO_SITE_USE_ID = cs.id1
	and hz.party_id = cpl_inv.object1_id1;
   l_inv_cust_acct_id NUMBER;
   l_inv_cust_acct_site_id NUMBER;
   l_investor_name VARCHAR2(360);
-- modified by zrehman for Bug#6788005 on 07-Feb-2008 end


-- rmunjulu R12 Fixes -- added new variables
      l_temp_return_status VARCHAR2(3);
      lx_msg_count NUMBER;
      lx_msg_data VARCHAR2(3000);
      lx_invoice_format_type okl_invoice_types_v.name%TYPE;
      lx_invoice_format_line_type okl_invc_line_types_v.name%TYPE;

  BEGIN

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Start PROCESS_BILL_TBL (+)');
    END IF;
	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------
	l_return_status := Okl_Api.START_ACTIVITY(
		p_api_name	=> l_api_name,
		p_pkg_name	=> G_PKG_NAME,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> l_return_status);

    IF l_overall_err_sts IS NULL THEN
	   l_overall_err_sts := Okl_Api.G_RET_STS_SUCCESS;
	END IF;

	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Start time Process_Bill_Tbl : '||TO_CHAR(SYSDATE, 'HH:MI:SS'));
END IF;
	------------------------------------------------------------
	-- If all records are processd, do bulk insert and update
	------------------------------------------------------------
	IF p_end_of_records = 'Y' THEN

       Fnd_File.PUT_LINE (Fnd_File.LOG, ' Done building TAI, TIL, TLD, XSI and XLS records ...');

					bulk_process
	                    (p_api_version
                	    ,p_init_msg_list
                	    ,x_return_status
                	    ,x_msg_count
                	    ,x_msg_data
                        ,p_commit
                        ,p_source);

       Fnd_File.PUT_LINE (Fnd_File.LOG, '=========================================================================================');
       Fnd_File.PUT_LINE (Fnd_File.LOG, '             ** End Processing. Please See Error Log for any errored transactions **   ');
       Fnd_File.PUT_LINE (Fnd_File.LOG, '=========================================================================================');

	ELSE

	------------------------------------
	-- Process records
	------------------------------------

	------------------------------------------------------------
	-- Initialise local variables
	------------------------------------------------------------
	l_trx_type	:= get_trx_type (l_trx_type_name, l_trx_type_lang);
	l_func_curr_code := Okl_Accounting_Util.get_func_curr_code;
    l_ext_sob_id            := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID;

	BEGIN
      	        SELECT
  	  	    	   DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
      	  		   DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
      	  		   DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
      	  		   DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
          	   INTO
  	  	           l_request_id,
          	  	   l_program_application_id,
          	  	   l_program_id,
          	  	   l_program_update_date
          	   FROM dual;
              EXCEPTION
                  WHEN OTHERS THEN
                      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'(Exception): When resolving request_id'||SQLERRM );
                      END IF;
                      Fnd_File.PUT_LINE (Fnd_File.LOG,'(Exception): When resolving request_id'||SQLERRM );
   END;

	------------------------------------------------------------
	-- Initialise table Index for error tables
	------------------------------------------------------------
    sel_error_log_table := l_init_sel_table;
    l_sel_tab_index     := 0;

	------------------------------------------------------------
	-- Process every stream to be billed
	------------------------------------------------------------

    Fnd_File.PUT_LINE (Fnd_File.LOG, '=========================================================================================');
    Fnd_File.PUT_LINE (Fnd_File.LOG, '             ** Start Processing. Please See Error Log for any errored transactions **   ');
    Fnd_File.PUT_LINE (Fnd_File.LOG, '=========================================================================================');

    --check if invoicing is to be turned off if a party is bankrupt
    Fnd_Profile.get('IEX_TURNOFF_INVOICE_BANKRUPTCY' , l_turnoff_inv_on_bankruptcy);
    l_turnoff_inv_on_bankruptcy := NVL(l_turnoff_inv_on_bankruptcy, 'N');
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Turnoff invoice on bankruptcy => ' || l_turnoff_inv_on_bankruptcy);
    END IF;

    -- Build table records for bulk processing

    Fnd_File.PUT_LINE (Fnd_File.LOG, 'Building TAI, TIL, TLD, XSI and XLS records ...');

    FOR k IN p_bill_tbl.FIRST..p_bill_tbl.LAST LOOP
  -- ******************************************************
        IF (l_turnoff_inv_on_bankruptcy = 'Y') THEN
          IF (l_previous_khr IS NULL OR l_previous_khr <> p_bill_tbl(k).khr_id)THEN
            l_bankruptcy_flag := get_bankruptcy_status
                                 (p_bill_tbl(k).khr_id
                                  , l_disposition_code);

            l_previous_khr := p_bill_tbl(k).khr_id;

            IF (l_bankruptcy_flag = 'Y') THEN
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Invoices of contract => ' || p_bill_tbl(k).contract_number || ' not billed due to bankruptcy.');
              END IF;
              Fnd_File.PUT_LINE (Fnd_File.LOG, 'Invoices of contract => ' || p_bill_tbl(k).contract_number || ' not billed due to bankruptcy.');
            END IF;
          END IF;
        END IF;

        IF (l_bankruptcy_flag = 'N') THEN
        l_commit_cnt := l_commit_cnt + 1;
        ---------------------------------------------------------------
        -- Start with a Clean State
        ---------------------------------------------------------------
        l_error_message := NULL;
  		----------------------------------------------------
		-- Create new transaction header for every
		-- contract and bill_date combination
		----------------------------------------------------

        IF l_khr_id <> p_bill_tbl(k).khr_id
		OR l_bill_date	<> p_bill_tbl(k).bill_date THEN

                    Fnd_File.PUT_LINE (Fnd_File.LOG, ' Contract Number : '||p_bill_tbl(k).contract_number||', Bill Date : '||p_bill_tbl(k).bill_date);

		    l_tai_cnt := l_tai_cnt + 1;

                -- Check if commit point reached
            IF l_commit_cnt > l_max_commit_cnt THEN

                    Fnd_File.PUT_LINE (Fnd_File.LOG, ' Done building TAI, TIL, TLD, XSI and XLS records ...');

                    -- Bulk insert/update records, Commit and restart
					bulk_process
	                    (p_api_version
                	    ,p_init_msg_list
                	    ,x_return_status
                	    ,x_msg_count
                	    ,x_msg_data
                        ,p_commit
                        ,p_source);

                    l_commit_cnt := 0;

             END IF;
            ------------------------------------------------
            -- Reset the flag to S whenever creating a new
            -- Transaction Header
            ------------------------------------------------
            l_error_status := 'S';

            -- Bulk insert
            ---------------------------------------------
	    -- Populate required columns
	    ---------------------------------------------
	    -- for LE Uptake project 07-11-2006
	       l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_bill_tbl(k).khr_id); -- for LE Uptake project 08-11-2006
	       tai_tbl(l_tai_cnt).legal_entity_id := l_legal_entity_id; -- for LE Uptake project 08-11-2006
	    -- for LE Uptake project 07-11-2006
		tai_tbl(l_tai_cnt).khr_id	   := p_bill_tbl(k).khr_id;
		tai_tbl(l_tai_cnt).date_invoiced   := p_bill_tbl(k).bill_date;
--start: cklee 3/8/07
		-- modified by zrehman for Bug#6788005 on 04-Feb-2008 start
		-- for Investor, the value of OKL_SOURCE_BILLING_TRX is 'INVESTOR_STAKE'
		OPEN check_if_inv(p_bill_tbl(k).khr_id);
		FETCH check_if_inv INTO l_is_inv;
		   if check_if_inv%NOTFOUND THEN
		      l_is_inv := 0;
                   else
                      l_is_inv := 1;
                   end if;
		CLOSE check_if_inv;
		IF (nvl(l_is_inv,0) =1 ) THEN
                  tai_tbl(l_tai_cnt).OKL_SOURCE_BILLING_TRX := 'INVESTOR_STAKE';
                  OPEN get_inv_cust_info(p_bill_tbl(k).khr_id, p_bill_tbl(k).kle_id);
		  FETCH get_inv_cust_info INTO l_inv_cust_acct_id, l_inv_cust_acct_site_id, l_investor_name;
		  CLOSE get_inv_cust_info;
                  tai_tbl(l_tai_cnt).INVESTOR_AGREEMENT_NUMBER := p_bill_tbl(k).contract_number;
		  tai_tbl(l_tai_cnt).INVESTOR_NAME := l_investor_name;
		ELSE
		  tai_tbl(l_tai_cnt).OKL_SOURCE_BILLING_TRX := 'STREAM';
		END IF;
		-- modified by zrehman for Bug#6788005 on 04-Feb-2008 end

            l_private_label := NULL;
            OPEN  pvt_label_csr( p_bill_tbl(k).khr_id );
            FETCH pvt_label_csr INTO l_private_label;
            CLOSE pvt_label_csr;
            tai_tbl(l_tai_cnt).private_label    := l_private_label;
--end: cklee 3/8/07

            IF p_bill_tbl(k).sts_code = 'EVERGREEN' THEN
               l_trx_type        := get_trx_type ('Evergreen', 'US');
			   tai_tbl(l_tai_cnt).try_id := l_trx_type;
            ELSE
               l_trx_type        := get_trx_type ('Billing', 'US');
			   tai_tbl(l_tai_cnt).try_id := l_trx_type;
            END IF;

			tai_tbl(l_tai_cnt).date_entered		:= l_date_entered;
			tai_tbl(l_tai_cnt).trx_status_code	:= 'ERROR';
			tai_tbl(l_tai_cnt).amount		    := l_zero_amount;

			---------------------------------------------
			-- Columns to be populated later based on CONTRACT_ID
			---------------------------------------------
			tai_tbl(l_tai_cnt).currency_code	        := NULL;
			tai_tbl(l_tai_cnt).currency_conversion_type	:= NULL;
			tai_tbl(l_tai_cnt).currency_conversion_rate	:= NULL;
			tai_tbl(l_tai_cnt).currency_conversion_date	:= NULL;

			tai_tbl(l_tai_cnt).set_of_books_id	:= NULL;
			tai_tbl(l_tai_cnt).ibt_id		:= NULL;
			tai_tbl(l_tai_cnt).ixx_id		:= NULL;
			tai_tbl(l_tai_cnt).irm_id		:= NULL;
			tai_tbl(l_tai_cnt).irt_id		:= NULL;
			tai_tbl(l_tai_cnt).org_id		:= NULL;
			---------------------------------------------
			-- Columns which are not used by stream billing
			---------------------------------------------
			tai_tbl(l_tai_cnt).cra_id		:= NULL;
			tai_tbl(l_tai_cnt).tap_id		:= NULL;
			tai_tbl(l_tai_cnt).qte_id		:= NULL;
			tai_tbl(l_tai_cnt).tcn_id		:= NULL;
			tai_tbl(l_tai_cnt).svf_id		:= NULL;
			tai_tbl(l_tai_cnt).ipy_id		:= NULL;
			tai_tbl(l_tai_cnt).tai_id_reverses	:= NULL;
			tai_tbl(l_tai_cnt).amount_applied	:= NULL;
			tai_tbl(l_tai_cnt).pox_id		:= NULL;
			tai_tbl(l_tai_cnt).cpy_id		:= NULL;
			tai_tbl(l_tai_cnt).clg_id		:= NULL;
			---------------------------------------------
			-- Other Mandatory Columns
			---------------------------------------------
            tai_tbl(l_tai_cnt).CREATION_DATE     := SYSDATE;
            tai_tbl(l_tai_cnt).CREATED_BY        := Fnd_Global.USER_ID;
            tai_tbl(l_tai_cnt).LAST_UPDATE_DATE  := SYSDATE;
            tai_tbl(l_tai_cnt).LAST_UPDATED_BY   := Fnd_Global.USER_ID;
            tai_tbl(l_tai_cnt).LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
            tai_tbl(l_tai_cnt).OBJECT_VERSION_NUMBER := 1;
            l_header_id                          := Okc_P_Util.raw_to_number(sys_guid());
            tai_tbl(l_tai_cnt).ID                := l_header_id;
	    tai_tbl(l_tai_cnt).trx_number        := SUBSTR(TO_CHAR(l_header_id),-6);
            tai_tbl(l_tai_cnt).request_id             := l_request_id;
            tai_tbl(l_tai_cnt).program_application_id := l_program_application_id;
            tai_tbl(l_tai_cnt).program_id             := l_program_id;
            tai_tbl(l_tai_cnt).program_update_date    := l_program_update_date;

	    --gkhuntet start 02-Nov-2007
            tai_tbl(l_tai_cnt).transaction_date       := SYSDATE;
       	    --gkhuntet end 02-Nov-2007

	---------------------------------------------
	-- Create TAI_TL records
	---------------------------------------------

		FOR l_lang_rec IN get_languages LOOP
			taitl_tbl(l_taitl_cnt).ID                := l_header_id;
			taitl_tbl(l_taitl_cnt).LANGUAGE          := l_lang_rec.language_code;
			taitl_tbl(l_taitl_cnt).SOURCE_LANG       := USERENV('LANG');
			taitl_tbl(l_taitl_cnt).SFWT_FLAG         := 'N';
			taitl_tbl(l_taitl_cnt).DESCRIPTION       := l_def_desc;

            taitl_tbl(l_taitl_cnt).CREATION_DATE     := SYSDATE;
            taitl_tbl(l_taitl_cnt).CREATED_BY        := Fnd_Global.USER_ID;
            taitl_tbl(l_taitl_cnt).LAST_UPDATE_DATE  := SYSDATE;
            taitl_tbl(l_taitl_cnt).LAST_UPDATED_BY   := Fnd_Global.USER_ID;
            taitl_tbl(l_taitl_cnt).LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;

            l_taitl_cnt     := l_taitl_cnt + 1;
        END LOOP;
            ------------------------------------------------
            -- Resolve T and C
            ------------------------------------------------
            l_ext_receipt_method_id := NULL;
            l_ext_term_id           := NULL;
            l_ext_customer_id       := NULL;
            --l_ext_trx_type_id       := NULL;
            l_ext_cust_bank_id      := NULL;
            l_ext_addr_id           := NULL;
            l_addr_id1              := NULL;
            l_pmth_id1              := NULL;
            l_bank_id1              := NULL;
            l_rct_method_code       := NULL;
-- 5162232 Start
--            l_asst_tax              := NULL;
-- 5162232 End
            l_product_id            := NULL;

            -- Newly added fields
            l_inf_id                := NULL;

            -- Multi-Currency Compliance
            l_currency_code            := NULL;
            l_currency_conversion_type := NULL;
            l_currency_conversion_rate := NULL;
            l_currency_conversion_date := NULL;

            -- Customer Id
            OPEN  cust_id_csr ( p_bill_tbl(k).khr_id );
            FETCH cust_id_csr INTO l_ext_customer_id;
            CLOSE cust_id_csr;

            OPEN  cust_acct_csr ( p_bill_tbl(k).khr_id );
            FETCH cust_acct_csr INTO l_ext_addr_id, l_ext_term_id;
            CLOSE cust_acct_csr;

            -- Force Term Id to be Immediate, ignoring the site
            -- level set up
            l_ext_term_id := NULL;
			OPEN  std_terms_csr;
		    FETCH std_terms_csr INTO l_ext_term_id;
		    CLOSE std_terms_csr;

            -- Payment Or Receipt Method Id
            OPEN  cust_pmth_csr ( p_bill_tbl(k).khr_id );
            FETCH cust_pmth_csr INTO l_pmth_id1;
            CLOSE cust_pmth_csr;

            OPEN  rcpt_mthd_csr( l_pmth_id1 );
            FETCH rcpt_mthd_csr INTO l_ext_receipt_method_id;
            CLOSE rcpt_mthd_csr;

            -- Evaluate Bank Account Id
		    OPEN  rcpt_method_csr (l_ext_receipt_method_id);
		    FETCH rcpt_method_csr INTO l_rct_method_code;
		    CLOSE rcpt_method_csr;

            IF (l_rct_method_code <> 'MANUAL') THEN
   			  OPEN  cust_bank_csr( p_bill_tbl(k).khr_id );
			  FETCH cust_bank_csr INTO l_bank_id1;
			  CLOSE cust_bank_csr;

			  OPEN 	bank_acct_csr( l_bank_id1 );
			  FETCH bank_acct_csr INTO l_ext_cust_bank_id;
			  CLOSE bank_acct_csr;
		    END IF;

            -- Multi Currency Compliance
            FOR cur IN l_curr_conv_csr( p_bill_tbl(k).khr_id ) LOOP
                l_currency_code            := cur.currency_code;
                l_currency_conversion_type := cur.currency_conversion_type;
                l_currency_conversion_rate := cur.currency_conversion_rate;
                l_currency_conversion_date := cur.currency_conversion_date;
            END LOOP;

            -- To support old contracts without multi-currency fields
            IF l_currency_conversion_type IS NULL THEN
                l_currency_conversion_type := 'User';
                l_currency_conversion_rate := 1;
                l_currency_conversion_date := SYSDATE;
            END IF;

            -- Product Id CSR
            OPEN  pdt_id_csr( p_bill_tbl(k).khr_id );
            FETCH pdt_id_csr INTO l_product_id;
            CLOSE pdt_id_csr;

            --
            OPEN  inv_frmt_csr ( p_bill_tbl(k).khr_id );
            -- 4733028
            FETCH inv_frmt_csr INTO l_inf_id, l_review_invoice_yn;
            CLOSE inv_frmt_csr;

			---------------------------------------------
			-- Adjust header variables
			---------------------------------------------
			l_line_number	:= l_first_line;
			l_header_amount	:= l_zero_amount;

--			l_header_id	    := r_taiv_rec.id;
            -- Replace for non-TAPI code testing
--            l_header_id	    := i_taiv_rec.ID

		END IF;

		----------------------------------------------------
		-- Create new transaction line for every
		-- contract line and bill_date combination
		----------------------------------------------------

        -- rmunjulu - Bug# 5715349 - Added one condition in IF
        -- Need to create billing TIL line every time a new
        -- contract is processed. This is more relevant in cases
        -- of contract level streams across contracts billed on
        -- same dates. In this case l_khr_id check will ensure TIL
        -- record creation
		IF l_khr_id <> p_bill_tbl(k).khr_id
		OR l_kle_id	<> NVL (p_bill_tbl(k).kle_id, l_null_kle_id)
--		IF l_kle_id	<> NVL (p_bill_tbl(k).kle_id, l_null_kle_id)
		OR l_bill_date	<> p_bill_tbl(k).bill_date THEN

		    l_til_cnt := l_til_cnt + 1;

			---------------------------------------------
			-- Populate required columns
			---------------------------------------------
			til_tbl(l_til_cnt).kle_id		        := p_bill_tbl(k).kle_id;
			til_tbl(l_til_cnt).line_number		    := l_line_number;
			til_tbl(l_til_cnt).tai_id		        := l_header_id;
			til_tbl(l_til_cnt).inv_receiv_line_code	:= l_line_code;
			til_tbl(l_til_cnt).amount		        := l_zero_amount;

			---------------------------------------------
			-- Columns which are not used by stream billing
			---------------------------------------------
			til_tbl(l_til_cnt).til_id_reverses	:= NULL;
			til_tbl(l_til_cnt).tpl_id		    := NULL;
			til_tbl(l_til_cnt).acn_id_cost		:= NULL;
			til_tbl(l_til_cnt).sty_id		    := NULL;
			til_tbl(l_til_cnt).quantity		    := NULL;
			til_tbl(l_til_cnt).amount_applied	:= NULL;
			til_tbl(l_til_cnt).org_id		    := NULL;
			til_tbl(l_til_cnt).date_bill_period_end	  := NULL;
			til_tbl(l_til_cnt).date_bill_period_start := NULL;
			til_tbl(l_til_cnt).receivables_invoice_id := NULL;

                  --Bug# 4488818: Sales Tax changes
                  til_tbl(l_til_cnt).qte_line_id := NULL;
                  til_tbl(l_til_cnt).txs_trx_id := NULL;

			l_line_id                          := Okc_P_Util.raw_to_number(sys_guid());
  			til_tbl(l_til_cnt).ID              := l_line_id;

  			til_tbl(l_til_cnt).OBJECT_VERSION_NUMBER  := 1;
            til_tbl(l_til_cnt).CREATION_DATE          := SYSDATE;
            til_tbl(l_til_cnt).CREATED_BY             := Fnd_Global.USER_ID;
            til_tbl(l_til_cnt).LAST_UPDATE_DATE       := SYSDATE;
            til_tbl(l_til_cnt).LAST_UPDATED_BY        := Fnd_Global.USER_ID;
            til_tbl(l_til_cnt).LAST_UPDATE_LOGIN      := Fnd_Global.LOGIN_ID;

            til_tbl(l_til_cnt).request_id             := l_request_id;
            til_tbl(l_til_cnt).program_application_id := l_program_application_id;
          	til_tbl(l_til_cnt).program_id             := l_program_id;
          	til_tbl(l_til_cnt).program_update_date    := l_program_update_date;

			---------------------------------------------
			-- Create TIL_TL records
			---------------------------------------------

		FOR l_lang_rec IN get_languages LOOP
			tiltl_tbl(l_tiltl_cnt).ID                := l_line_id;
			tiltl_tbl(l_tiltl_cnt).LANGUAGE          := l_lang_rec.language_code;
			tiltl_tbl(l_tiltl_cnt).SOURCE_LANG       := USERENV('LANG');
			tiltl_tbl(l_tiltl_cnt).SFWT_FLAG         := 'N';
			tiltl_tbl(l_tiltl_cnt).DESCRIPTION       := l_def_desc;

            tiltl_tbl(l_tiltl_cnt).CREATION_DATE     := SYSDATE;
            tiltl_tbl(l_tiltl_cnt).CREATED_BY        := Fnd_Global.USER_ID;
            tiltl_tbl(l_tiltl_cnt).LAST_UPDATE_DATE  := SYSDATE;
            tiltl_tbl(l_tiltl_cnt).LAST_UPDATED_BY   := Fnd_Global.USER_ID;
            tiltl_tbl(l_tiltl_cnt).LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;

            l_tiltl_cnt     := l_tiltl_cnt + 1;
        END LOOP;

			---------------------------------------------
			-- Adjust line variables
			---------------------------------------------
			l_detail_number	:= l_first_line;
			l_line_amount	:= l_zero_amount;

--			l_line_id	    := r_tilv_rec.id;
            -- Replace for non-TAPI code testing
--			l_line_id	    := i_tilv_rec.id;

			l_line_number	:= l_line_number + l_line_step;

		END IF;

		----------------------------------------------------
		-- Create new transaction line detail for every stream
		----------------------------------------------------

		----------------------------------------------------
		-- Populate required columns
		----------------------------------------------------
        -- Round to the Currency precision and rounding rules
        l_ste_amount := p_bill_tbl(k).amount;
        l_curr_code  := p_bill_tbl(k).currency_code;
        l_ste_amount := Okl_Accounting_Util.cross_currency_round_amount
                           (p_amount => l_ste_amount
                           ,p_currency_code => l_curr_code);

		tld_tbl(l_tld_cnt).amount			:= l_ste_amount;
		tld_tbl(l_tld_cnt).sel_id			:= p_bill_tbl(k).sel_id;
		tld_tbl(l_tld_cnt).sty_id			:= p_bill_tbl(k).sty_id;
		tld_tbl(l_tld_cnt).til_id_details	:= l_line_id;
		tld_tbl(l_tld_cnt).line_detail_number := l_detail_number;

		----------------------------------------------------
		-- Columns which are not used by stream billing
		----------------------------------------------------
		tld_tbl(l_tld_cnt).tld_id_reverses		:= NULL;
		tld_tbl(l_tld_cnt).idx_id			    := NULL;
		tld_tbl(l_tld_cnt).late_charge_yn		:= NULL;
		tld_tbl(l_tld_cnt).date_calculation		:= NULL;
		tld_tbl(l_tld_cnt).fixed_rate_yn		:= NULL;
		tld_tbl(l_tld_cnt).receivables_invoice_id	:= NULL;
		tld_tbl(l_tld_cnt).amount_applied		:= NULL;
		tld_tbl(l_tld_cnt).bch_id			:= NULL;
		tld_tbl(l_tld_cnt).bgh_id			:= NULL;
		tld_tbl(l_tld_cnt).bcl_id			:= NULL;
		tld_tbl(l_tld_cnt).bsl_id			:= NULL;
		tld_tbl(l_tld_cnt).org_id			:= NULL;
		----------------------------------------------------
		-- Other Columns
		----------------------------------------------------
--cklee: start 3/16/07
    open c_seq;
    fetch c_seq into l_seq;
    close c_seq;
--		l_tld_id                                 := Okc_P_Util.raw_to_number(sys_guid());
        l_tld_id                                 := l_seq;
--cklee: start 3/16/07
      	tld_tbl(l_tld_cnt).ID                     := l_tld_id;
  		tld_tbl(l_tld_cnt).OBJECT_VERSION_NUMBER  := 1;
        tld_tbl(l_tld_cnt).CREATION_DATE          := SYSDATE;
        tld_tbl(l_tld_cnt).CREATED_BY             := Fnd_Global.USER_ID;
        tld_tbl(l_tld_cnt).LAST_UPDATE_DATE       := SYSDATE;
        tld_tbl(l_tld_cnt).LAST_UPDATED_BY        := Fnd_Global.USER_ID;
        tld_tbl(l_tld_cnt).LAST_UPDATE_LOGIN      := Fnd_Global.LOGIN_ID;

        tld_tbl(l_tld_cnt).request_id             := l_request_id;
        tld_tbl(l_tld_cnt).program_application_id := l_program_application_id;
       	tld_tbl(l_tld_cnt).program_id             := l_program_id;
       	tld_tbl(l_tld_cnt).program_update_date    := l_program_update_date;

       	-- l_tld_cnt := l_tld_cnt + 1; -- rmunjulu R12 Fixes -- increment at the end

			---------------------------------------------
			-- Create TLD_TL records
			---------------------------------------------

		FOR l_lang_rec IN get_languages LOOP
			tldtl_tbl(l_tldtl_cnt).ID                := l_tld_id;
			tldtl_tbl(l_tldtl_cnt).LANGUAGE          := l_lang_rec.language_code;
			tldtl_tbl(l_tldtl_cnt).SOURCE_LANG       := USERENV('LANG');
			tldtl_tbl(l_tldtl_cnt).SFWT_FLAG         := 'N';
			tldtl_tbl(l_tldtl_cnt).DESCRIPTION       := p_bill_tbl(k).sty_name;

            tldtl_tbl(l_tldtl_cnt).CREATION_DATE     := SYSDATE;
            tldtl_tbl(l_tldtl_cnt).CREATED_BY        := Fnd_Global.USER_ID;
            tldtl_tbl(l_tldtl_cnt).LAST_UPDATE_DATE  := SYSDATE;
            tldtl_tbl(l_tldtl_cnt).LAST_UPDATED_BY   := Fnd_Global.USER_ID;
            tldtl_tbl(l_tldtl_cnt).LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;

            l_tldtl_cnt     := l_tldtl_cnt + 1;
        END LOOP;

        -- If negative, create a credit memo
        l_ext_trx_type_id                    := NULL;
        IF l_ste_amount > 0 THEN
            -- Trx Type Id
            OPEN  c_trx_id ( l_ext_sob_id , p_bill_tbl(k).authoring_org_id );
            FETCH c_trx_id INTO l_ext_trx_type_id;
            CLOSE c_trx_id;
        ELSE
            -- Trx Type Id
            OPEN  c_trx_id1 ( l_ext_sob_id , p_bill_tbl(k).authoring_org_id );
            FETCH c_trx_id1 INTO l_ext_trx_type_id;
            CLOSE c_trx_id1;
        END IF;

	l_khr_id 	:= p_bill_tbl(k).khr_id;
	l_bill_date	:= p_bill_tbl(k).bill_date;
	l_kle_id 	:= NVL (p_bill_tbl(k).kle_id, l_null_kle_id);
	l_header_amount	:= l_header_amount + l_ste_amount;
	l_line_amount	:= l_line_amount   + l_ste_amount;
	l_detail_number	:= l_detail_number + l_line_step;

	tai_tbl(l_tai_cnt).amount := l_header_amount;
	til_tbl(l_til_cnt).amount := l_line_amount;

        -- rmunjulu R12 Fixes -- Populate NEW columns in tai_tbl -- start
        tai_tbl(l_tai_cnt).inf_id                      := l_inf_id; -- okl consolidate invoice format id
        tai_tbl(l_tai_cnt).invoice_pull_yn             := l_review_invoice_yn;
        --tai_tbl(l_tai_cnt).due_date                  := ; rmunjulu R12 Fixes -- not need as used for legacy data
        tai_tbl(l_tai_cnt).isi_id                      := NULL;
        tai_tbl(l_tai_cnt).receivables_invoice_id      := NULL;
        tai_tbl(l_tai_cnt).cust_trx_type_id            := l_ext_trx_type_id;
        tai_tbl(l_tai_cnt).customer_bank_account_id    := l_ext_cust_bank_id;
        tai_tbl(l_tai_cnt).tax_exempt_flag             := 'S';
        tai_tbl(l_tai_cnt).tax_exempt_reason_code      := NULL;
        tai_tbl(l_tai_cnt).reference_line_id           := NULL;
        tai_tbl(l_tai_cnt).private_label               := l_private_label;
        -- rmunjulu R12 Fixes -- Populate NEW columns in tai_tbl -- end

-- rmunjulu R12 Fixes -- Populate ADDITIONAL columns of tai_tbl -- start
-- modified by zrehman for Bug#6788005 on 12-Feb-2008 start
	IF(nvl(l_is_inv,0) <>1 ) THEN
          tai_tbl(l_tai_cnt).ixx_id             := l_ext_customer_id;
	ELSE
	  tai_tbl(l_tai_cnt).ixx_id             := l_inv_cust_acct_id;
	END IF;
-- modified by zrehman for Bug#6788005 on 12-Feb-2008 end
	tai_tbl(l_tai_cnt).irm_id             := l_ext_receipt_method_id;
        IF l_ste_amount > 0 THEN
            tai_tbl(l_tai_cnt).irt_id          := l_ext_term_id;
        END IF;
-- modified by zrehman for Bug#6788005 on 12-Feb-2008 start
	IF(nvl(l_is_inv,0) <>1) THEN
	  tai_tbl(l_tai_cnt).ibt_id             := l_ext_addr_id;
	ELSE
	  tai_tbl(l_tai_cnt).ibt_id             := l_inv_cust_acct_site_id;
	END IF;
-- modified by zrehman for Bug#6788005 on 12-Feb-2008 end
        tai_tbl(l_tai_cnt).set_of_books_id    := l_ext_sob_id;
        tai_tbl(l_tai_cnt).currency_code      := l_currency_code;
        tai_tbl(l_tai_cnt).currency_conversion_type    := l_currency_conversion_type;

		--DO currency conversion rate and date based on type
        IF (l_currency_conversion_type = 'User') THEN
            IF (l_currency_code = l_func_curr_code) THEN
                l_currency_conversion_rate := 1;
            ELSE
                l_currency_conversion_rate := l_currency_conversion_rate;
            END IF;
		    --Check for currency conversion date - forward port bug 5466577
            l_currency_conversion_date  := l_currency_conversion_date;
        ELSE
            l_currency_conversion_rate := NULL;
		    --Check for currency conversion date - forward port bug 5466577
            l_currency_conversion_date  := p_bill_tbl(k).bill_date;
        END IF;

        tai_tbl(l_tai_cnt).currency_conversion_rate    := l_currency_conversion_rate;
        tai_tbl(l_tai_cnt).currency_conversion_date    := l_currency_conversion_date;
        tai_tbl(l_tai_cnt).ORG_ID             := p_bill_tbl(k).authoring_org_id;
-- rmunjulu R12 Fixes -- Populate ADDITIONAL columns of tai_tbl -- end

-- rmunjulu R12 Fixes -- Populate NEW columns in til_tbl
-- not needed for the 2 new columns that were added to OKL_TXL_AR_INV_LNS

-- rmunjulu R12 Fixes -- Populate ADDITIONAL columns in til_tbl -- start
		til_tbl(l_til_cnt).ISL_ID    := 1;
		til_tbl(l_til_cnt).ORG_ID    := p_bill_tbl(k).authoring_org_id;
		til_tbl(l_til_cnt).inv_receiv_line_code  := l_line_code;
		til_tbl(l_til_cnt).QUANTITY  := 1;
-- rmunjulu R12 Fixes -- Populate ADDITIONAL columns in til_tbl -- end

-- rmunjulu R12 Fixes -- Populate NEW columns in tld_tbl -- start
  		-- tld_tbl(l_tld_cnt).CONSOLIDATED_INVOICE_NUMBER := ; -- no need to populate as used for legacy data
  	    tld_tbl(l_tld_cnt).KHR_ID := p_bill_tbl(k).khr_id; -- need to populate this khr_id which is the denormalized one
-- rmunjulu R12 Fixes -- Populate NEW columns in tld_tbl -- end
  	    tld_tbl(l_tld_cnt).KLE_ID := p_bill_tbl(k).kle_id; -- cklee 3/22/07 - added okc_k_lines_b.id as FK directly

-- rmunjulu R12 Fixes -- Populate ADDITIONAL columns in tld_tbl -- start

        -- make call to get invoice format API to get the formats
        OKL_INTERNAL_BILLING_PVT.Get_Invoice_format(
             p_api_version                  => p_api_version
            ,p_init_msg_list                => OKL_API.G_FALSE
            ,x_return_status                => l_return_status
            ,x_msg_count                    => lx_msg_count
            ,x_msg_data                     => lx_msg_data
            ,p_inf_id                       => tai_tbl(l_tai_cnt).inf_id
            ,p_sty_id                       => tld_tbl(l_tld_cnt).sty_id
            ,x_invoice_format_type          => lx_invoice_format_type
            ,x_invoice_format_line_type     => lx_invoice_format_line_type);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        tld_tbl(l_tld_cnt).invoice_format_type   := lx_invoice_format_type;
        tld_tbl(l_tld_cnt).invoice_format_line_type   := lx_invoice_format_line_type;
-- rmunjulu R12 Fixes -- Populate ADDITIONAL columns in tld_tbl -- end

	    ------------------------------------------------------------
	    -- Create record with all record id
	    ------------------------------------------------------------
         all_rec_tbl(l_art_index).tai_id := l_header_id;
         all_rec_tbl(l_art_index).til_id := l_line_id;
         all_rec_tbl(l_art_index).tld_id := l_tld_id;
         all_rec_tbl(l_art_index).sel_id := p_bill_tbl(k).sel_id;
         all_rec_tbl(l_art_index).xsi_id := l_xsi_id;
         all_rec_tbl(l_art_index).xls_id := l_xls_id;
         all_rec_tbl(l_art_index).contract_number := p_bill_tbl(k).contract_number;
         all_rec_tbl(l_art_index).stream_name     := p_bill_tbl(k).sty_name;
         all_rec_tbl(l_art_index).bill_date       := p_bill_tbl(k).bill_date;

         l_art_index := l_art_index + 1;
         l_tld_cnt := l_tld_cnt + 1; -- rmunjulu R12 Fixes -- moved here

    END IF;
    END LOOP;     -- Loop thru bill_tbl of records

    IF p_source = 'PRINCIPAL_PAYDOWN' THEN
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Overall Error Status for PPD ' || l_overall_err_sts);
       END IF;
       x_return_status := l_overall_err_sts;
    END IF;
  -- ******************************************************

    END IF;

IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End time Process_Bill_Tbl : '||TO_CHAR(SYSDATE, 'HH:MI:SS'));

      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End PROCESS_BILL_TBL (-)');


END IF;
	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);

  EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (EXCP) => '||SQLERRM);

            IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_stream_billing_pvt',
                  'EXCEPTION (Process_bill_tbl):'||'OKL_API.G_EXCEPTION_ERROR');
            END IF;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (UNEXP) => '||SQLERRM);

        IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
            Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_stream_billing_pvt',
               'EXCEPTION (Process_bill_tbl):'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (OTHERS 3) => '||SQLERRM);

        IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
            Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_stream_billing_pvt',
               'EXCEPTION (Process_bill_tbl):'||'OTHERS');
        END IF;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
  END Process_bill_tbl;


  -- ----------------------------------------------------------------
  -- Procedure bill_streams_master to bill outstanding stream elements
  -- ----------------------------------------------------------------
  PROCEDURE bill_streams_master
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
        ,p_commit           IN  VARCHAR2
	,p_ia_contract_type     IN  VARCHAR2	DEFAULT NULL  --modified by zrehman for Bug#6788005 on 01-Feb-2008
	,p_contract_number	IN  VARCHAR2
	,p_from_bill_date	IN  DATE
	,p_to_bill_date		IN  DATE
    ,p_cust_acct_id     IN  NUMBER
    ,p_inv_cust_acct_id      IN NUMBER    DEFAULT NULL  --modified by zrehman for Bug#6788005 on 01-Feb-2008
    ,p_assigned_process IN VARCHAR2
    ,p_source           IN  VARCHAR2
    ,p_request_id    IN  NUMBER		--Bug 7584183
 ) IS

	l_api_name	    CONSTANT VARCHAR2(30)  := 'BILL_STREAMS_MASTER';
	l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_version	CONSTANT NUMBER := 1;

	CURSOR c1 IS
    --1st select for all streams other than Property tax streams
    SELECT	stm.khr_id		 khr_id,
			TRUNC (ste.stream_element_date)	bill_date,
			stm.kle_id			 kle_id,
			ste.id				 sel_id,
			stm.sty_id			 sty_id,
			khr.contract_number  contract_number,
            khr.currency_code    currency_code,
            khr.authoring_org_id authoring_org_id,
			sty.name 			 comments,
            sty.taxable_default_yn taxable_default_yn,
			ste.amount			 amount,
            khr.sts_code         sts_code
   	FROM	OKL_STRM_ELEMENTS		ste,
			OKL_STREAMS			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			OKL_K_HEADERS			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls
		WHERE	TRUNC(ste.stream_element_date)		>=
				TRUNC(NVL (p_from_bill_date,	ste.stream_element_date))
		AND	TRUNC(ste.stream_element_date)		<=
				TRUNC((NVL (p_to_bill_date,	SYSDATE) + get_printing_lead_days(stm.khr_id)))
		AND ste.amount 			<> 0
		AND	stm.id				= ste.stm_id
		AND	ste.date_billed		IS NULL
		AND	stm.active_yn		= 'Y'
		AND	stm.say_code		= 'CURR'
		AND	sty.id				= stm.sty_id
		AND	sty.billable_yn		= 'Y'
		AND	khr.id				= stm.khr_id
		AND	khr.scs_code		IN ('LEASE', 'LOAN')
    AND khr.sts_code        IN ( 'BOOKED','EVERGREEN','TERMINATED', 'EXPIRED')  -- bug 6472228 added EXPIRED status
    AND	khr.contract_number	 = p_contract_number
    AND khr.cust_acct_id     = NVL( p_cust_acct_id, khr.cust_acct_id )
    AND nvl(p_ia_contract_type, L_CONTRACT_TYPE) =  L_CONTRACT_TYPE

		AND	khl.id				= stm.khr_id
		AND	khl.deal_type		IS NOT NULL
		AND	khs.code			= khr.sts_code
--		AND	khs.ste_code		= 'ACTIVE'
		AND	kle.id			(+)	= stm.kle_id
		AND	kls.code		(+)	= kle.sts_code
    AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED' , 'EXPIRED')  -- bug 6472228 added EXPIRED status
    AND sty.stream_type_purpose NOT IN ('ACTUAL_PROPERTY_TAX', 'ESTIMATED_PROPERTY_TAX')
    AND ( p_source <> 'PRINCIPAL_PAYDOWN' OR (p_source = 'PRINCIPAL_PAYDOWN'
                                               AND sty.stream_type_purpose
                                                in ('UNSCHEDULED_PRINCIPAL_PAYMENT','UNSCHEDULED_LOAN_PAYMENT')
                                               )
         )
    -- modified by zrehman for Bug#6788005 on 01-Feb-2008 start
UNION
    SELECT	stm.khr_id		 khr_id,
			TRUNC (ste.stream_element_date)	bill_date,
			stm.kle_id			 kle_id,
			ste.id				 sel_id,
			stm.sty_id			 sty_id,
			khr.contract_number  contract_number,
                        khr.currency_code    currency_code,
                        khr.authoring_org_id authoring_org_id,
			sty.name 			 comments,
                        sty.taxable_default_yn taxable_default_yn,
			ste.amount			 amount,
                        khr.sts_code         sts_code
   	FROM	        OKL_STRM_ELEMENTS		ste,
			OKL_STREAMS			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			OKL_K_HEADERS			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls,
			okc_k_lines_b                   cle
		WHERE	TRUNC(ste.stream_element_date)	>=  TRUNC(NVL (p_from_bill_date,	ste.stream_element_date))
		AND	TRUNC(ste.stream_element_date)	<= TRUNC((NVL (p_to_bill_date,	SYSDATE) + nvl(get_printing_lead_days(stm.khr_id), 0)))
		AND ste.amount 			<> 0
		AND	stm.id				= ste.stm_id
		AND	ste.date_billed		IS NULL
		AND	stm.active_yn		= 'Y'
		AND	stm.say_code		= 'CURR'
		AND	sty.id				= stm.sty_id
		AND	sty.billable_yn		= 'Y'
		AND	khr.id				= stm.khr_id
		AND	khr.scs_code		= 'INVESTOR'
                AND     khr.sts_code        = ( 'ACTIVE')  -- bug 6472228 added EXPIRED status
                AND	khr.contract_number	 = p_contract_number
		AND     nvl(p_ia_contract_type,L_IA_TYPE) =  L_IA_TYPE
		AND     cle.dnz_chr_id = khr.id
                AND    (p_inv_cust_acct_id IS NULL OR (p_inv_cust_acct_id IS NOT NULL AND (cle.cust_acct_id IS NOT NULL and cle.cust_acct_id = p_inv_cust_acct_id)))
		AND	khl.id				= stm.khr_id
		AND	khs.code			= khr.sts_code
		AND	kle.id			= stm.kle_id
		AND	kls.code		= kle.sts_code
    AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED' , 'EXPIRED')  -- bug 6472228 added EXPIRED status
    AND sty.stream_type_purpose NOT IN ('ACTUAL_PROPERTY_TAX', 'ESTIMATED_PROPERTY_TAX')
    ORDER	BY 1, 2, 3;
-- modified by zrehman for Bug#6788005 on 01-Feb-2008 end

    --2nd select for Actual property tax streams
	CURSOR c2 IS
    SELECT	stm.khr_id		 khr_id,
			TRUNC (ste.stream_element_date)	bill_date,
			stm.kle_id			 kle_id,
			ste.id				 sel_id,
			stm.sty_id			 sty_id,
			khr.contract_number  contract_number,
            khr.currency_code    currency_code,
            khr.authoring_org_id authoring_org_id,
			sty.name 			 comments,
            sty.taxable_default_yn taxable_default_yn,
			ste.amount			 amount,
            khr.sts_code         sts_code
   	FROM	OKL_STRM_ELEMENTS		ste,
			OKL_STREAMS			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			OKL_K_HEADERS			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls
		WHERE	TRUNC(ste.stream_element_date)		>=
				TRUNC(NVL (p_from_bill_date,	ste.stream_element_date))
		AND	TRUNC(ste.stream_element_date)		<=
				TRUNC((NVL (p_to_bill_date,	SYSDATE) + get_printing_lead_days(stm.khr_id)))
		AND ste.amount 			<> 0
		AND	stm.id				= ste.stm_id
		AND	ste.date_billed		IS NULL
		AND	stm.active_yn		= 'Y'
		AND	stm.say_code		= 'CURR'
		AND	sty.id				= stm.sty_id
		AND	sty.billable_yn		= 'Y'
		AND	khr.id				= stm.khr_id
		AND	khr.scs_code		IN ('LEASE', 'LOAN')
        AND khr.sts_code        IN ( 'BOOKED','EVERGREEN')
		AND	khr.contract_number	= p_contract_number
		AND     nvl(p_ia_contract_type, L_CONTRACT_TYPE) =  L_CONTRACT_TYPE

        AND khr.cust_acct_id     = NVL( p_cust_acct_id, khr.cust_acct_id )
		AND	khl.id				= stm.khr_id
		AND	khl.deal_type		IS NOT NULL
		AND	khs.code			= khr.sts_code
		AND	khs.ste_code		= 'ACTIVE'
		AND	kle.id			(+)	= stm.kle_id
		AND	kls.code		(+)	= kle.sts_code
    AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED')
    AND EXISTS (SELECT 1 FROM okc_rule_groups_b rgp
                                , okc_rules_b rul
                  WHERE rgp.dnz_chr_id = kle.dnz_chr_id
                  AND   rgp.cle_id = kle.id
                  AND rgp.rgd_code = 'LAASTX'
                  AND rgp.id = rul.rgp_id
                  AND rul.rule_information_category = 'LAPRTX'
                  AND rul.rule_information1 = 'Y'
                  AND (rul.rule_information3 = 'ACTUAL')
                  )
    AND sty.stream_type_purpose = 'ACTUAL_PROPERTY_TAX'
    AND (p_source <> 'PRINCIPAL_PAYDOWN')
    ORDER	BY 1, 2, 3;

    --3rd select for Estimated property tax streams
	CURSOR c3 IS
    SELECT	stm.khr_id		 khr_id,
			TRUNC (ste.stream_element_date)	bill_date,
			stm.kle_id			 kle_id,
			ste.id				 sel_id,
			stm.sty_id			 sty_id,
			khr.contract_number  contract_number,
            khr.currency_code    currency_code,
            khr.authoring_org_id authoring_org_id,
			sty.name 			 comments,
            sty.taxable_default_yn taxable_default_yn,
			ste.amount			 amount,
            khr.sts_code         sts_code
   	FROM	OKL_STRM_ELEMENTS		ste,
			OKL_STREAMS			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			OKL_K_HEADERS			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls
		WHERE	TRUNC(ste.stream_element_date)		>=
				TRUNC(NVL (p_from_bill_date,	ste.stream_element_date))
		AND	TRUNC(ste.stream_element_date)		<=
				TRUNC((NVL (p_to_bill_date,	SYSDATE) + get_printing_lead_days(stm.khr_id)))
		AND ste.amount 			<> 0
		AND	stm.id				= ste.stm_id
		AND	ste.date_billed		IS NULL
		AND	stm.active_yn		= 'Y'
		AND	stm.say_code		= 'CURR'
		AND	sty.id				= stm.sty_id
		AND	sty.billable_yn		= 'Y'
		AND	khr.id				= stm.khr_id
		AND	khr.scs_code		IN ('LEASE', 'LOAN')
    AND khr.sts_code        IN ( 'BOOKED','EVERGREEN')
		AND	khr.contract_number	= p_contract_number
		AND nvl(p_ia_contract_type, L_CONTRACT_TYPE) =  L_CONTRACT_TYPE
                AND khr.cust_acct_id     = NVL( p_cust_acct_id, khr.cust_acct_id )
		AND	khl.id				= stm.khr_id
		AND	khl.deal_type		IS NOT NULL
		AND	khs.code			= khr.sts_code
		AND	khs.ste_code		= 'ACTIVE'
		AND	kle.id			(+)	= stm.kle_id
		AND	kls.code		(+)	= kle.sts_code
    AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED')
    AND EXISTS (SELECT 1 FROM okc_rule_groups_b rgp
                                , okc_rules_b rul
                  WHERE rgp.dnz_chr_id = kle.dnz_chr_id
                  AND   rgp.cle_id = kle.id
                  AND rgp.rgd_code = 'LAASTX'
                  AND rgp.id = rul.rgp_id
                  AND rul.rule_information_category = 'LAPRTX'
                  AND rul.rule_information1 = 'Y'
                  AND (rul.rule_information3 = 'ESTIMATED' OR rul.rule_information3 = 'ESTIMATED_AND_ACTUAL')
                  )
    AND sty.stream_type_purpose = 'ESTIMATED_PROPERTY_TAX'
    AND (p_source <> 'PRINCIPAL_PAYDOWN')
    ORDER	BY 1, 2, 3;

	CURSOR c4 IS
    --1st select for all streams other than Property tax streams
    SELECT	stm.khr_id		 khr_id,
			TRUNC (ste.stream_element_date)	bill_date,
			stm.kle_id			 kle_id,
			ste.id				 sel_id,
			stm.sty_id			 sty_id,
			khr.contract_number  contract_number,
            khr.currency_code    currency_code,
            khr.authoring_org_id authoring_org_id,
			sty.name 			 comments,
            sty.taxable_default_yn taxable_default_yn,
			ste.amount			 amount,
            khr.sts_code         sts_code
   	FROM	OKL_STRM_ELEMENTS		ste,
			OKL_STREAMS			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			OKL_K_HEADERS			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls
		WHERE	TRUNC(ste.stream_element_date)		>=
				TRUNC(NVL (p_from_bill_date,	ste.stream_element_date))
		AND	TRUNC(ste.stream_element_date)		<=
				TRUNC((NVL (p_to_bill_date,	SYSDATE) + get_printing_lead_days(stm.khr_id)))
		AND ste.amount 			<> 0
		AND	stm.id				= ste.stm_id
		AND	ste.date_billed		IS NULL
		AND	stm.active_yn		= 'Y'
		AND	stm.say_code		= 'CURR'
		AND	sty.id				= stm.sty_id
		AND	sty.billable_yn		= 'Y'
		AND	khr.id				= stm.khr_id
		AND	khr.scs_code		IN ('LEASE', 'LOAN')
          AND khr.sts_code        IN ( 'BOOKED','EVERGREEN','TERMINATED', 'EXPIRED')  -- bug 6472228 added EXPIRED status
--		AND	khr.contract_number	= NVL (p_contract_number,	khr.contract_number)
        AND nvl(p_ia_contract_type, L_CONTRACT_TYPE) =  L_CONTRACT_TYPE
        AND khr.cust_acct_id     = NVL( p_cust_acct_id, khr.cust_acct_id )
		AND	khl.id				= stm.khr_id
		AND	khl.deal_type		IS NOT NULL
		AND	khs.code			= khr.sts_code
--		AND	khs.ste_code		= 'ACTIVE'
		AND	kle.id			(+)	= stm.kle_id
		AND	kls.code		(+)	= kle.sts_code
    AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED', 'EXPIRED')  -- bug 6472228 added EXPIRED status
    AND sty.stream_type_purpose NOT IN ('ACTUAL_PROPERTY_TAX', 'ESTIMATED_PROPERTY_TAX')
    AND ( p_source <> 'PRINCIPAL_PAYDOWN' OR (p_source = 'PRINCIPAL_PAYDOWN'
                                               AND sty.stream_type_purpose
                                                = 'UNSCHEDULED_PRINCIPAL_PAYMENT'
                                               )
         )
-- modified by zrehman for Bug#6788005 on 04-Feb-2008 start
UNION
    SELECT	stm.khr_id		 khr_id,
			TRUNC (ste.stream_element_date)	bill_date,
			stm.kle_id			 kle_id,
			ste.id				 sel_id,
			stm.sty_id			 sty_id,
			khr.contract_number  contract_number,
            khr.currency_code    currency_code,
            khr.authoring_org_id authoring_org_id,
			sty.name 			 comments,
            sty.taxable_default_yn taxable_default_yn,
			ste.amount			 amount,
            khr.sts_code         sts_code
   	FROM	OKL_STRM_ELEMENTS		ste,
			OKL_STREAMS			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			OKL_K_HEADERS			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls,
			okc_k_lines_b                   cle
		WHERE	TRUNC(ste.stream_element_date)		>=
				TRUNC(NVL (p_from_bill_date,	ste.stream_element_date))
		AND	TRUNC(ste.stream_element_date)		<=	TRUNC((NVL (p_to_bill_date,	SYSDATE) + get_printing_lead_days(stm.khr_id)))
		AND ste.amount 			<> 0
		AND	stm.id			= ste.stm_id
		AND	ste.date_billed		IS NULL
		AND	stm.active_yn		= 'Y'
		AND	stm.say_code		= 'CURR'
		AND	sty.id			= stm.sty_id
		AND	sty.billable_yn		= 'Y'
		AND	khr.id			= stm.khr_id
		AND	khr.scs_code		= 'INVESTOR'
                AND khr.sts_code                = 'ACTIVE'
                AND     nvl(p_ia_contract_type,L_IA_TYPE) =  L_IA_TYPE
		AND     cle.dnz_chr_id = khr.id
                AND    (p_inv_cust_acct_id IS NULL OR (p_inv_cust_acct_id IS NOT NULL AND (cle.cust_acct_id IS NOT NULL and cle.cust_acct_id = p_inv_cust_acct_id)))
                AND	khl.id				= stm.khr_id
		AND	khs.code			= khr.sts_code
--		AND	khs.ste_code		= 'ACTIVE'
		AND	kle.id			= stm.kle_id
		AND	kls.code		= kle.sts_code
    AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED', 'EXPIRED')  -- bug 6472228 added EXPIRED status
    AND sty.stream_type_purpose NOT IN ('ACTUAL_PROPERTY_TAX', 'ESTIMATED_PROPERTY_TAX')
    ORDER	BY 1, 2, 3;
-- modified by zrehman for Bug#6788005 on 04-Feb-2008 end

   --2nd select for Actual property tax streams
	CURSOR c5 IS
    SELECT	stm.khr_id		 khr_id,
			TRUNC (ste.stream_element_date)	bill_date,
			stm.kle_id			 kle_id,
			ste.id				 sel_id,
			stm.sty_id			 sty_id,
			khr.contract_number  contract_number,
            khr.currency_code    currency_code,
            khr.authoring_org_id authoring_org_id,
			sty.name 			 comments,
            sty.taxable_default_yn taxable_default_yn,
			ste.amount			 amount,
            khr.sts_code         sts_code
   	FROM	OKL_STRM_ELEMENTS		ste,
			OKL_STREAMS			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			OKL_K_HEADERS			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls
		WHERE	TRUNC(ste.stream_element_date)		>=
				TRUNC(NVL (p_from_bill_date,	ste.stream_element_date))
		AND	TRUNC(ste.stream_element_date)		<=
				TRUNC((NVL (p_to_bill_date,	SYSDATE) + get_printing_lead_days(stm.khr_id)))
		AND ste.amount 			<> 0
		AND	stm.id				= ste.stm_id
		AND	ste.date_billed		IS NULL
		AND	stm.active_yn		= 'Y'
		AND	stm.say_code		= 'CURR'
		AND	sty.id				= stm.sty_id
		AND	sty.billable_yn		= 'Y'
		AND	khr.id				= stm.khr_id
		AND	khr.scs_code		IN ('LEASE', 'LOAN')
		AND nvl(p_ia_contract_type, L_CONTRACT_TYPE) =  L_CONTRACT_TYPE
        AND khr.sts_code        IN ( 'BOOKED','EVERGREEN')
--		AND	khr.contract_number	= NVL (p_contract_number,	khr.contract_number)
        AND khr.cust_acct_id     = NVL( p_cust_acct_id, khr.cust_acct_id )
		AND	khl.id				= stm.khr_id
		AND	khl.deal_type		IS NOT NULL
		AND	khs.code			= khr.sts_code
		AND	khs.ste_code		= 'ACTIVE'
		AND	kle.id			(+)	= stm.kle_id
		AND	kls.code		(+)	= kle.sts_code
    AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED')
    AND EXISTS (SELECT 1 FROM okc_rule_groups_b rgp
                                , okc_rules_b rul
                  WHERE rgp.dnz_chr_id = kle.dnz_chr_id
                  AND   rgp.cle_id = kle.id
                  AND rgp.rgd_code = 'LAASTX'
                  AND rgp.id = rul.rgp_id
                  AND rul.rule_information_category = 'LAPRTX'
                  AND rul.rule_information1 = 'Y'
                  AND (rul.rule_information3 = 'ACTUAL')
                  )
    AND sty.stream_type_purpose = 'ACTUAL_PROPERTY_TAX'
    AND (p_source <> 'PRINCIPAL_PAYDOWN')
    ORDER	BY 1, 2, 3;

    --3rd select for Estimated property tax streams
	CURSOR c6 IS
    SELECT	stm.khr_id		 khr_id,
			TRUNC (ste.stream_element_date)	bill_date,
			stm.kle_id			 kle_id,
			ste.id				 sel_id,
			stm.sty_id			 sty_id,
			khr.contract_number  contract_number,
            khr.currency_code    currency_code,
            khr.authoring_org_id authoring_org_id,
			sty.name 			 comments,
            sty.taxable_default_yn taxable_default_yn,
			ste.amount			 amount,
            khr.sts_code         sts_code
   	FROM	OKL_STRM_ELEMENTS		ste,
			OKL_STREAMS			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			OKL_K_HEADERS			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls
		WHERE	TRUNC(ste.stream_element_date)		>=
				TRUNC(NVL (p_from_bill_date,	ste.stream_element_date))
		AND	TRUNC(ste.stream_element_date)		<=
				TRUNC((NVL (p_to_bill_date,	SYSDATE) + get_printing_lead_days(stm.khr_id)))
		AND ste.amount 			<> 0
		AND	stm.id				= ste.stm_id
		AND	ste.date_billed		IS NULL
		AND	stm.active_yn		= 'Y'
		AND	stm.say_code		= 'CURR'
		AND	sty.id				= stm.sty_id
		AND	sty.billable_yn		= 'Y'
		AND	khr.id				= stm.khr_id
		AND	khr.scs_code		IN ('LEASE', 'LOAN')
    AND khr.sts_code        IN ( 'BOOKED','EVERGREEN')
--		AND	khr.contract_number	= NVL (p_contract_number,	khr.contract_number)
     		AND nvl(p_ia_contract_type, L_CONTRACT_TYPE) =  L_CONTRACT_TYPE
	AND khr.cust_acct_id     = NVL( p_cust_acct_id, khr.cust_acct_id )
		AND	khl.id				= stm.khr_id
		AND	khl.deal_type		IS NOT NULL
		AND	khs.code			= khr.sts_code
		AND	khs.ste_code		= 'ACTIVE'
		AND	kle.id			(+)	= stm.kle_id
		AND	kls.code		(+)	= kle.sts_code
    AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED')
    AND EXISTS (SELECT 1 FROM okc_rule_groups_b rgp
                                , okc_rules_b rul
                  WHERE rgp.dnz_chr_id = kle.dnz_chr_id
                  AND   rgp.cle_id = kle.id
                  AND rgp.rgd_code = 'LAASTX'
                  AND rgp.id = rul.rgp_id
                  AND rul.rule_information_category = 'LAPRTX'
                  AND rul.rule_information1 = 'Y'
                  AND (rul.rule_information3 = 'ESTIMATED' OR rul.rule_information3 = 'ESTIMATED_AND_ACTUAL')
                  )
    AND sty.stream_type_purpose = 'ESTIMATED_PROPERTY_TAX'
    AND (p_source <> 'PRINCIPAL_PAYDOWN')
    ORDER	BY 1, 2, 3;

 	CURSOR c7 IS
    --1st select for all streams other than Property tax streams
    SELECT	stm.khr_id		 khr_id,
			TRUNC (ste.stream_element_date)	bill_date,
			stm.kle_id			 kle_id,
			ste.id				 sel_id,
			stm.sty_id			 sty_id,
			khr.contract_number  contract_number,
            khr.currency_code    currency_code,
            khr.authoring_org_id authoring_org_id,
			sty.name 			 comments,
            sty.taxable_default_yn taxable_default_yn,
			ste.amount			 amount,
            khr.sts_code         sts_code
   	FROM	OKL_STRM_ELEMENTS		ste,
			OKL_STREAMS			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			OKL_K_HEADERS			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls,
            OKL_PARALLEL_PROCESSES  pws
		WHERE	TRUNC(ste.stream_element_date)		>=
				TRUNC(NVL (p_from_bill_date,	ste.stream_element_date))
		AND	TRUNC(ste.stream_element_date)		<=
				TRUNC((NVL (p_to_bill_date,	SYSDATE) + get_printing_lead_days(stm.khr_id)))
		AND ste.amount 			<> 0
		AND	stm.id				= ste.stm_id
		AND	ste.date_billed		IS NULL
		AND	stm.active_yn		= 'Y'
		AND	stm.say_code		= 'CURR'
		AND	sty.id				= stm.sty_id
		AND	sty.billable_yn		= 'Y'
		AND	khr.id				= stm.khr_id
		AND	khr.scs_code		IN ('LEASE', 'LOAN')
        AND khr.sts_code        IN ( 'BOOKED','EVERGREEN','TERMINATED', 'EXPIRED')  -- bug 6472228 added EXPIRED status
		AND	khr.contract_number	= NVL (p_contract_number,	khr.contract_number)
		AND nvl(p_ia_contract_type, L_CONTRACT_TYPE) =  L_CONTRACT_TYPE
        AND khr.cust_acct_id     = NVL( p_cust_acct_id, khr.cust_acct_id )
		AND	khl.id				= stm.khr_id
		AND	khl.deal_type		IS NOT NULL
		AND	khs.code			= khr.sts_code
		AND	kle.id			(+)	= stm.kle_id
		AND	kls.code		(+)	= kle.sts_code
    AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED', 'EXPIRED')   -- bug 6472228 added EXPIRED status
    AND sty.stream_type_purpose NOT IN ('ACTUAL_PROPERTY_TAX', 'ESTIMATED_PROPERTY_TAX')
    AND ( p_source <> 'PRINCIPAL_PAYDOWN' OR (p_source = 'PRINCIPAL_PAYDOWN'
                                               AND sty.stream_type_purpose
                                                = 'UNSCHEDULED_PRINCIPAL_PAYMENT'
                                               )
         )
    AND pws.object_type = 'CONTRACT'
    AND pws.object_value = khr.contract_number
    AND pws.assigned_process = p_assigned_process
-- modified by zrehman for Bug#6788005 on 04-Feb-2008 start
UNION
    SELECT	        stm.khr_id		 khr_id,
			TRUNC (ste.stream_element_date)	bill_date,
			stm.kle_id			 kle_id,
			ste.id				 sel_id,
			stm.sty_id			 sty_id,
			khr.contract_number  contract_number,
                        khr.currency_code    currency_code,
                        khr.authoring_org_id authoring_org_id,
			sty.name 			 comments,
                        sty.taxable_default_yn taxable_default_yn,
			ste.amount			 amount,
                        khr.sts_code         sts_code
   	FROM	        OKL_STRM_ELEMENTS		ste,
			OKL_STREAMS			stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			OKL_K_HEADERS			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls,
			okc_k_lines_b                   cle,
                        OKL_PARALLEL_PROCESSES  pws
		WHERE	TRUNC(ste.stream_element_date)		>=
				TRUNC(NVL (p_from_bill_date,	ste.stream_element_date))
		AND	TRUNC(ste.stream_element_date)		<=
				TRUNC((NVL (p_to_bill_date,	SYSDATE) + get_printing_lead_days(stm.khr_id)))
		AND ste.amount 			<> 0
		AND	stm.id			= ste.stm_id
		AND	ste.date_billed		IS NULL
		AND	stm.active_yn		= 'Y'
		AND	stm.say_code		= 'CURR'
		AND	sty.id			= stm.sty_id
		AND	sty.billable_yn		= 'Y'
		AND	khr.id			= stm.khr_id
		AND	khr.scs_code		= 'INVESTOR'
                AND     khr.sts_code            = 'ACTIVE'  -- bug 6472228 added EXPIRED status
		AND	khr.contract_number	= NVL (p_contract_number,	khr.contract_number)
     		AND     nvl(p_ia_contract_type,L_IA_TYPE) =  L_IA_TYPE
		AND     cle.dnz_chr_id = khr.id
                AND    (p_inv_cust_acct_id IS NULL OR (p_inv_cust_acct_id IS NOT NULL AND (cle.cust_acct_id IS NOT NULL and cle.cust_acct_id = p_inv_cust_acct_id)))
                AND	khl.id			= stm.khr_id
		AND	khs.code		= khr.sts_code
		AND	kle.id			= stm.kle_id
		AND	kls.code		= kle.sts_code
    AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED', 'EXPIRED')   -- bug 6472228 added EXPIRED status
    AND sty.stream_type_purpose NOT IN ('ACTUAL_PROPERTY_TAX', 'ESTIMATED_PROPERTY_TAX')
    AND pws.object_type = 'CONTRACT'
    AND pws.object_value = khr.contract_number
    AND pws.assigned_process = p_assigned_process
    ORDER	BY 1, 2, 3;
-- modified by zrehman for Bug#6788005 on 04-Feb-2008 end

CURSOR c8 IS
    SELECT	stm.khr_id		 khr_id,
			TRUNC (ste.stream_element_date)	bill_date,
			stm.kle_id			 kle_id,
			ste.id				 sel_id,
			stm.sty_id			 sty_id,
			khr.contract_number  contract_number,
            khr.currency_code    currency_code,
            khr.authoring_org_id authoring_org_id,
			sty.name 			 comments,
            sty.taxable_default_yn taxable_default_yn,
			ste.amount			 amount,
            khr.sts_code         sts_code
   	FROM	OKL_STRM_ELEMENTS		ste,
			OKL_STREAMS			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			OKL_K_HEADERS			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls,
            OKL_PARALLEL_PROCESSES  pws
		WHERE	TRUNC(ste.stream_element_date)		>=
				TRUNC(NVL (p_from_bill_date,	ste.stream_element_date))
		AND	TRUNC(ste.stream_element_date)		<=
				TRUNC((NVL (p_to_bill_date,	SYSDATE) + get_printing_lead_days(stm.khr_id)))
		AND ste.amount 			<> 0
		AND	stm.id				= ste.stm_id
		AND	ste.date_billed		IS NULL
		AND	stm.active_yn		= 'Y'
		AND	stm.say_code		= 'CURR'
		AND	sty.id				= stm.sty_id
		AND	sty.billable_yn		= 'Y'
		AND	khr.id				= stm.khr_id
		AND	khr.scs_code		IN ('LEASE', 'LOAN')
		AND khr.sts_code        IN ( 'BOOKED','EVERGREEN','TERMINATED','EXPIRED') -- Bug#7475594
		AND	khr.contract_number	= NVL (p_contract_number,	khr.contract_number)
		AND nvl(p_ia_contract_type, L_CONTRACT_TYPE) =  L_CONTRACT_TYPE
        AND khr.cust_acct_id     = NVL( p_cust_acct_id, khr.cust_acct_id )
		AND	khl.id				= stm.khr_id
		AND	khl.deal_type		IS NOT NULL
		AND	khs.code			= khr.sts_code
	--      AND	khs.ste_code		= 'ACTIVE'
		AND	kle.id			(+)	= stm.kle_id
		AND	kls.code		(+)	= kle.sts_code
		AND NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED', 'EXPIRED')  -- Bug# 7475594
    AND EXISTS (SELECT 1 FROM okc_rule_groups_b rgp
                                , okc_rules_b rul
                  WHERE rgp.dnz_chr_id = kle.dnz_chr_id
                  AND   rgp.cle_id = kle.id
                  AND rgp.rgd_code = 'LAASTX'
                  AND rgp.id = rul.rgp_id
                  AND rul.rule_information_category = 'LAPRTX'
                  AND rul.rule_information1 = 'Y'
                  AND (rul.rule_information3 = 'ACTUAL')
                  )
    AND sty.stream_type_purpose = 'ACTUAL_PROPERTY_TAX'
    AND (p_source <> 'PRINCIPAL_PAYDOWN')
    AND pws.object_type = 'CONTRACT'
    AND  pws.object_value = khr.contract_number
    AND pws.assigned_process = p_assigned_process
    ORDER	BY 1, 2, 3;

	CURSOR c9 IS
    SELECT	stm.khr_id		 khr_id,
			TRUNC (ste.stream_element_date)	bill_date,
			stm.kle_id			 kle_id,
			ste.id				 sel_id,
			stm.sty_id			 sty_id,
			khr.contract_number  contract_number,
            khr.currency_code    currency_code,
            khr.authoring_org_id authoring_org_id,
			sty.name 			 comments,
            sty.taxable_default_yn taxable_default_yn,
			ste.amount			 amount,
            khr.sts_code         sts_code
   	FROM	OKL_STRM_ELEMENTS		ste,
			OKL_STREAMS			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			OKL_K_HEADERS			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls,
            OKL_PARALLEL_PROCESSES  pws
		WHERE	TRUNC(ste.stream_element_date)		>=
				TRUNC(NVL (p_from_bill_date,	ste.stream_element_date))
		AND	TRUNC(ste.stream_element_date)		<=
				TRUNC((NVL (p_to_bill_date,	SYSDATE) + get_printing_lead_days(stm.khr_id)))
		AND ste.amount 			<> 0
		AND	stm.id				= ste.stm_id
		AND	ste.date_billed		IS NULL
		AND	stm.active_yn		= 'Y'
		AND	stm.say_code		= 'CURR'
		AND	sty.id				= stm.sty_id
		AND	sty.billable_yn		= 'Y'
		AND	khr.id				= stm.khr_id
		AND	khr.scs_code		IN ('LEASE', 'LOAN')
        AND khr.sts_code        IN ( 'BOOKED','EVERGREEN')
		AND	khr.contract_number	= NVL (p_contract_number,	khr.contract_number)
       		AND nvl(p_ia_contract_type, L_CONTRACT_TYPE) =  L_CONTRACT_TYPE
	AND khr.cust_acct_id     = NVL( p_cust_acct_id, khr.cust_acct_id )
		AND	khl.id				= stm.khr_id
		AND	khl.deal_type		IS NOT NULL
		AND	khs.code			= khr.sts_code
		AND	khs.ste_code		= 'ACTIVE'
		AND	kle.id			(+)	= stm.kle_id
		AND	kls.code		(+)	= kle.sts_code
    AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED')
    AND EXISTS (SELECT 1 FROM okc_rule_groups_b rgp
                                , okc_rules_b rul
                  WHERE rgp.dnz_chr_id = kle.dnz_chr_id
                  AND   rgp.cle_id = kle.id
                  AND rgp.rgd_code = 'LAASTX'
                  AND rgp.id = rul.rgp_id
                  AND rul.rule_information_category = 'LAPRTX'
                  AND rul.rule_information1 = 'Y'
                  AND (rul.rule_information3 = 'ESTIMATED' OR rul.rule_information3 = 'ESTIMATED_AND_ACTUAL')
                  )
    AND sty.stream_type_purpose = 'ESTIMATED_PROPERTY_TAX'
    AND (p_source <> 'PRINCIPAL_PAYDOWN')
    AND pws.object_type = 'CONTRACT'
    AND  pws.object_value = khr.contract_number
    AND pws.assigned_process = p_assigned_process

    ORDER	BY 1, 2, 3;

    bill_tbl        bill_tbl_type;

    L_FETCH_SIZE    NUMBER := 5000;

    -- --------------------------------------------------------
    -- To Print log messages
    -- --------------------------------------------------------

    l_request_id      NUMBER;		--Bug 7584183

    CURSOR txd_cnt_succ_csr( p_req_id NUMBER, p_sts VARCHAR2 ) IS
           SELECT COUNT(*)
           FROM okl_trx_ar_invoices_v a,
                okl_txl_ar_inv_lns_v b,
                okl_txd_ar_ln_dtls_v c
           WHERE a.id = b.tai_id AND
                 b.id = c.til_id_details AND
                 a.trx_status_code = p_sts AND
                 a.request_id = p_req_id ;

    CURSOR txd_cnt_err_csr( p_req_id NUMBER, p_sts VARCHAR2 ) IS
           SELECT COUNT(*)
           FROM okl_trx_ar_invoices_v a,
                okl_txl_ar_inv_lns_v b,
                okl_txd_ar_ln_dtls_v c
           WHERE a.id = b.tai_id AND
                 b.id = c.til_id_details AND
                 a.trx_status_code = p_sts AND
                 a.request_id = p_req_id ;

 	 ------------------------------------------------------------
	 -- Operating Unit
	 ------------------------------------------------------------
     CURSOR op_unit_csr IS
            SELECT NAME
            FROM hr_operating_units
	    WHERE ORGANIZATION_ID=MO_GLOBAL.GET_CURRENT_ORG_ID; --MOAC- Concurrent request


    l_succ_cnt          NUMBER;
    l_err_cnt           NUMBER;
    l_op_unit_name      hr_operating_units.name%TYPE;
    lx_msg_data         VARCHAR2(450);
    l_msg_index_out     NUMBER :=0;
    processed_sts       okl_trx_ar_invoices_v.trx_status_code%TYPE;
    error_sts           okl_trx_ar_invoices_v.trx_status_code%TYPE;
	l_end_of_records    VARCHAR2(1);


  BEGIN

	l_return_status := Okl_Api.START_ACTIVITY(
		p_api_name	=> l_api_name,
		p_pkg_name	=> G_PKG_NAME,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> l_return_status);

    L_DEBUG_ENABLED := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;

	l_end_of_records := 'N';

  IF p_assigned_process IS NOT NULL THEN

     -- Cursors 7,8 and 9

        OPEN C7;
        LOOP
            -- ----------------------------
            -- Clear table contents
            -- ----------------------------
            bill_tbl.DELETE;
            FETCH C7 BULK COLLECT INTO bill_tbl LIMIT L_FETCH_SIZE;
            Fnd_File.PUT_LINE (Fnd_File.LOG, 'C7 Bill_Tbl count is: '||bill_tbl.COUNT);
            IF bill_tbl.COUNT > 0 THEN
				Process_bill_tbl
                	(p_api_version
                	,p_init_msg_list
                	,x_return_status
                	,x_msg_count
                	,x_msg_data
                    ,p_commit
                	,p_contract_number
                	,p_from_bill_date
                	,p_to_bill_date
                    ,bill_tbl
                    ,p_source
					,l_end_of_records);
            END IF;
        EXIT WHEN C7%NOTFOUND;
        END LOOP;
        CLOSE C7;
--
        OPEN C8;
        LOOP
            -- ----------------------------
            -- Clear table contents
            -- ----------------------------
            bill_tbl.DELETE;
            FETCH C8 BULK COLLECT INTO bill_tbl LIMIT L_FETCH_SIZE;
            Fnd_File.PUT_LINE (Fnd_File.LOG, 'C8 Bill_Tbl count is: '||bill_tbl.COUNT);
            IF bill_tbl.COUNT > 0 THEN
                Process_bill_tbl
                	(p_api_version
                	,p_init_msg_list
                	,x_return_status
                	,x_msg_count
                	,x_msg_data
                    ,p_commit
                	,p_contract_number
                	,p_from_bill_date
                	,p_to_bill_date
                    ,bill_tbl
                    ,p_source
					,l_end_of_records);
            END IF;
        EXIT WHEN C8%NOTFOUND;
        END LOOP;
        CLOSE C8;
--
        OPEN C9;
        LOOP
            -- ----------------------------
            -- Clear table contents
            -- ----------------------------
            bill_tbl.DELETE;
            FETCH C9 BULK COLLECT INTO bill_tbl LIMIT L_FETCH_SIZE;
            Fnd_File.PUT_LINE (Fnd_File.LOG, 'C9 Bill_Tbl count is: '||bill_tbl.COUNT);
            IF bill_tbl.COUNT > 0 THEN
                Process_bill_tbl
                	(p_api_version
                	,p_init_msg_list
                	,x_return_status
                	,x_msg_count
                	,x_msg_data
                    ,p_commit
                	,p_contract_number
                	,p_from_bill_date
                	,p_to_bill_date
                    ,bill_tbl
                    ,p_source
					,l_end_of_records);
            END IF;
        EXIT WHEN C9%NOTFOUND;
        END LOOP;
        CLOSE C9;


  ELSE -- Assigned Process Id
    IF (p_source <> 'PRINCIPAL_PAYDOWN') THEN
        IF p_contract_number IS NOT NULL THEN

        -- Cursors 1, 2 and 3
            OPEN C1;
            LOOP
                -- ----------------------------
                -- Clear table contents
                -- ----------------------------
                bill_tbl.DELETE;
                FETCH C1 BULK COLLECT INTO bill_tbl LIMIT L_FETCH_SIZE;
                Fnd_File.PUT_LINE (Fnd_File.LOG, 'C1 Bill_Tbl count is: '||bill_tbl.COUNT);
                IF bill_tbl.COUNT > 0 THEN
                    Process_bill_tbl
                    	(p_api_version
                    	,p_init_msg_list
                    	,x_return_status
                    	,x_msg_count
                    	,x_msg_data
                        ,p_commit
                    	,p_contract_number
                    	,p_from_bill_date
                    	,p_to_bill_date
                        ,bill_tbl
                        ,p_source
					    ,l_end_of_records);
                END IF;
            EXIT WHEN C1%NOTFOUND;
            END LOOP;
            CLOSE C1;
--
            OPEN C2;
            LOOP
                -- ----------------------------
                -- Clear table contents
                -- ----------------------------
                bill_tbl.DELETE;
                FETCH C2 BULK COLLECT INTO bill_tbl LIMIT L_FETCH_SIZE;
                Fnd_File.PUT_LINE (Fnd_File.LOG, 'C2 Bill_Tbl count is: '||bill_tbl.COUNT);
                IF bill_tbl.COUNT > 0 THEN
                    Process_bill_tbl
                    	(p_api_version
                    	,p_init_msg_list
                    	,x_return_status
                    	,x_msg_count
                    	,x_msg_data
                        ,p_commit
                    	,p_contract_number
                    	,p_from_bill_date
                    	,p_to_bill_date
                        ,bill_tbl
                        ,p_source
					    ,l_end_of_records);
                END IF;
            EXIT WHEN C2%NOTFOUND;
            END LOOP;
            CLOSE C2;
--
            OPEN C3;
            LOOP
                -- ----------------------------
                -- Clear table contents
                -- ----------------------------
                bill_tbl.DELETE;
                FETCH C3 BULK COLLECT INTO bill_tbl LIMIT L_FETCH_SIZE;
                Fnd_File.PUT_LINE (Fnd_File.LOG, 'C3 Bill_Tbl count is: '||bill_tbl.COUNT);
                IF bill_tbl.COUNT > 0 THEN
                    Process_bill_tbl
                    	(p_api_version
                    	,p_init_msg_list
                    	,x_return_status
                    	,x_msg_count
                    	,x_msg_data
                        ,p_commit
                    	,p_contract_number
                    	,p_from_bill_date
                    	,p_to_bill_date
                        ,bill_tbl
                        ,p_source
					    ,l_end_of_records);
                END IF;
            EXIT WHEN C3%NOTFOUND;
            END LOOP;
            CLOSE C3;
--*******************

        ELSE -- p_contract_number supplied or not
        -- Cursors 4, 5 and 6

            OPEN C4;
            LOOP
                -- ----------------------------
                -- Clear table contents
                -- ----------------------------
                bill_tbl.DELETE;
                FETCH C4 BULK COLLECT INTO bill_tbl LIMIT L_FETCH_SIZE;
                Fnd_File.PUT_LINE (Fnd_File.LOG, 'C4 Bill_Tbl count is: '||bill_tbl.COUNT);
                IF bill_tbl.COUNT > 0 THEN
                        Process_bill_tbl
                    	(p_api_version
                    	,p_init_msg_list
                    	,x_return_status
                    	,x_msg_count
                    	,x_msg_data
                        ,p_commit
                    	,p_contract_number
                    	,p_from_bill_date
                    	,p_to_bill_date
                        ,bill_tbl
                        ,p_source
					    ,l_end_of_records);
                END IF;
            EXIT WHEN C4%NOTFOUND;
            END LOOP;
            CLOSE C4;
--
            OPEN C5;
            LOOP
                -- ----------------------------
                -- Clear table contents
                -- ----------------------------
                bill_tbl.DELETE;
                FETCH C5 BULK COLLECT INTO bill_tbl LIMIT L_FETCH_SIZE;
                Fnd_File.PUT_LINE (Fnd_File.LOG, 'C5 Bill_Tbl count is: '||bill_tbl.COUNT);
                IF bill_tbl.COUNT > 0 THEN
                    Process_bill_tbl
                    	(p_api_version
                    	,p_init_msg_list
                    	,x_return_status
                      	,x_msg_count
                    	,x_msg_data
                        ,p_commit
                    	,p_contract_number
                    	,p_from_bill_date
                    	,p_to_bill_date
                        ,bill_tbl
                        ,p_source
					    ,l_end_of_records);
                END IF;
            EXIT WHEN C5%NOTFOUND;
            END LOOP;
            CLOSE C5;
--
            OPEN C6;
            LOOP
                -- ----------------------------
                -- Clear table contents
                -- ----------------------------
                bill_tbl.DELETE;
                FETCH C6 BULK COLLECT INTO bill_tbl LIMIT L_FETCH_SIZE;
                Fnd_File.PUT_LINE (Fnd_File.LOG, 'C6 Bill_Tbl count is: '||bill_tbl.COUNT);
                IF bill_tbl.COUNT > 0 THEN
                    Process_bill_tbl
                    	(p_api_version
                    	,p_init_msg_list
                    	,x_return_status
                    	,x_msg_count
                    	,x_msg_data
                        ,p_commit
                    	,p_contract_number
                    	,p_from_bill_date
                       	,p_to_bill_date
                        ,bill_tbl
                        ,p_source
					    ,l_end_of_records);
                END IF;
            EXIT WHEN C6%NOTFOUND;
            END LOOP;
            CLOSE C6;

        END IF; -- Contract Number null or not null
    ELSE -- Source of principal paydown
    -- ---------------------------------------------------
    -- Assumption is that the Principal Paydown process
    -- always supplies a contract number
    -- ---------------------------------------------------
    -- Principal Paydown Code
--*******************
        IF p_contract_number IS NOT NULL THEN
            -- --------------------------------------------------
            OPEN C1;
            LOOP
                -- ----------------------------
                -- Clear table contents
                -- ----------------------------
                bill_tbl.DELETE;
                FETCH C1 BULK COLLECT INTO bill_tbl LIMIT L_FETCH_SIZE;
                IF bill_tbl.COUNT > 0 THEN
                    Process_bill_tbl
                    	(p_api_version
                    	,p_init_msg_list
                    	,x_return_status
                    	,x_msg_count
                    	,x_msg_data
                        ,p_commit
                    	,p_contract_number
                    	,p_from_bill_date
                    	,p_to_bill_date
                        ,bill_tbl
                        ,p_source
					    ,l_end_of_records);
                END IF;
            EXIT WHEN C1%NOTFOUND;
            END LOOP;
            CLOSE C1;
        END IF; -- Contract Number not supplied and principal paydown

--*******************
    END IF; -- Source Of Principal Paydown
  END IF; -- Assigned Process Id

  ------------------------------------------------
  -- Call Process_bill_tbl to mark end of process
  ------------------------------------------------
  l_end_of_records := 'Y';

                    Process_bill_tbl
                    	(p_api_version
                    	,p_init_msg_list
                    	,x_return_status
                    	,x_msg_count
                    	,x_msg_data
                        ,p_commit
                    	,p_contract_number
                    	,p_from_bill_date
                    	,p_to_bill_date
                        ,bill_tbl
                        ,p_source
					    ,l_end_of_records);

    -----------------------------------------------------------
	-- Print log and output messages
	------------------------------------------------------------

    -- Get the request Id
    l_request_id := p_request_id;          --Bug 7584183

    processed_sts       := 'SUBMITTED'; -- 'PROCESSED'; -- rmunjulu R12 Fixes, check for submitted status not processed
    error_sts           := 'ERROR';

    l_succ_cnt          := 0;
    l_err_cnt           := 0;

     -- Success Count
     OPEN   txd_cnt_succ_csr( l_request_id, processed_sts );
     FETCH  txd_cnt_succ_csr INTO l_succ_cnt;
     CLOSE  txd_cnt_succ_csr;

     -- Error Count
     OPEN   txd_cnt_err_csr( l_request_id, error_sts );
     FETCH  txd_cnt_err_csr INTO l_err_cnt;
     CLOSE  txd_cnt_err_csr;

    if (l_err_cnt > 0) and (l_warning_status is null) then
        l_warning_status := 'W';
    end if;

    ----------------------------------------
    -- Get Operating unit name
    ----------------------------------------
    l_op_unit_name := NULL;
    OPEN  op_unit_csr;
    FETCH op_unit_csr INTO l_op_unit_name;
    CLOSE op_unit_csr;

    -- Start New Out File stmathew 15-OCT-2004
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 54, ' ')||'Oracle Leasing and Finance Management'||LPAD(' ', 55, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 54, ' ')||'Process Billable Streams'||LPAD(' ', 54, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 54, ' ')||'------------------------'||LPAD(' ', 54, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Operating Unit: '||l_op_unit_name);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Request Id: '||l_request_id||LPAD(' ',74,' ') ||'Run Date: '||TO_CHAR(SYSDATE));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Currency: '||Okl_Accounting_Util.get_func_curr_code);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD('-', 132, '-'));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'From Bill Date  : ' ||p_from_bill_date);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'To Bill Date    : ' ||p_to_bill_date);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Contract Number : ' ||p_contract_number);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD('-', 132, '-'));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));

    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Processing Details:'||LPAD(' ', 113, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '                Number of Successful Stream Elements: '||l_succ_cnt);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '                Number of Errored Stream Elements: '||l_err_cnt);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '                Total: '||(l_succ_cnt+l_err_cnt));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));

    -- End New Out File stmathew 15-OCT-2004
    IF x_msg_count > 0 THEN
       FOR i IN 1..x_msg_count LOOP
            IF i = 1 THEN
                Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Details of Errored Stream Elements:'||LPAD(' ', 97, ' '));
                Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
            END IF;
            Fnd_Msg_Pub.get (p_msg_index => i,
                       p_encoded => 'F',
                       p_data => lx_msg_data,
                       p_msg_index_out => l_msg_index_out);

            Fnd_File.PUT_LINE (Fnd_File.OUTPUT,TO_CHAR(i) || ': ' || lx_msg_data);

            IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_stream_billing_pvt',
                  TO_CHAR(i) || ': ' || lx_msg_data);
            END IF;

      END LOOP;
    END IF;


	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);

  EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
	WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (EXCP) => '||SQLERRM);

            IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_stream_billing_pvt',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
            END IF;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (UNEXP) => '||SQLERRM);

        IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
            Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_stream_billing_pvt',
               'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (OTHERS 2) => '||SQLERRM);

        IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
            Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_stream_billing_pvt',
               'EXCEPTION :'||'OTHERS');
        END IF;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
  END bill_streams_master;

  ------------------------------------------------------------------
  -- Procedure BIL_STREAMS to bill outstanding stream elements
  ------------------------------------------------------------------
  PROCEDURE bill_streams
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
    ,p_commit           IN  VARCHAR2
    ,p_ia_contract_type  IN  VARCHAR2 --modified by zrehman for Bug#6788005 on 01-Feb-2008
	,p_contract_number	IN  VARCHAR2
	,p_from_bill_date	IN  DATE
	,p_to_bill_date		IN  DATE
    ,p_cust_acct_id     IN  NUMBER
    ,p_inv_cust_acct_id       IN  NUMBER --modified by zrehman for Bug#6788005 on 01-Feb-2008
    ,p_assigned_process IN VARCHAR2
    ,p_source           IN  VARCHAR2
 ) IS

	l_api_name	    CONSTANT VARCHAR2(30)  := 'BILL_STREAMS';
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_api_version	CONSTANT NUMBER := 1;
    --Bug 7584183-Added by kkorrapo
    l_request_id    NUMBER := -1;
    CURSOR req_id_csr IS
	   SELECT
           DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID)
	   FROM dual;
    --Bug 7584183-Addition end

BEGIN

    IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
       Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE,'okl_stream_billing_pvt'
									,'Begin(+)');
    END IF;
IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Start time Bill_Streams : '||TO_CHAR(SYSDATE, 'HH:MI:SS'));
END IF;
    -- ------------------------
    -- Print Input variables
    -- ------------------------
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_commit '||p_commit);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_contract_number '||p_contract_number);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_from_bill_date '||p_from_bill_date);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_to_bill_date '||p_to_bill_date);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_source '||p_source);

    END IF;
	l_return_status := Okl_Api.START_ACTIVITY(
		p_api_name	=> l_api_name,
		p_pkg_name	=> G_PKG_NAME,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> l_return_status);

  --Bug 7584183-Added by kkorrapo
    OPEN  req_id_csr;
    FETCH req_id_csr INTO l_request_id;
    CLOSE req_id_csr;
    --Bug 7584183-Addition end

    bill_streams_master
	(p_api_version      => p_api_version
	,p_init_msg_list    => p_init_msg_list
	,x_return_status    => x_return_status
	,x_msg_count        => x_msg_count
	,x_msg_data         => x_msg_data
    ,p_commit           => p_commit
    ,p_ia_contract_type   => p_ia_contract_type --modified by zrehman for Bug#6788005 on 01-Feb-2008
	,p_contract_number  => p_contract_number
	,p_from_bill_date   => p_from_bill_date
	,p_to_bill_date     => p_to_bill_date
    ,p_cust_acct_id     => p_cust_acct_id
    ,p_inv_cust_acct_id      => p_inv_cust_acct_id --modified by zrehman for Bug#6788005 on 01-Feb-2008
    ,p_assigned_process => p_assigned_process
    ,p_source           => p_source
    ,p_request_id       => l_request_id);                      -- Bug 7584183


    IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
       Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE,'okl_stream_billing_pvt'
									,'End(-)');
    END IF;

    -- -------------------------------------------
    -- Purge data from the Parallel process Table
    -- -------------------------------------------
    IF p_assigned_process IS NOT NULL THEN

        DELETE OKL_PARALLEL_PROCESSES
        WHERE assigned_process = p_assigned_process;

        COMMIT;

    END IF;

	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);

IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'End time Bill_Streams : '||TO_CHAR(SYSDATE, 'HH:MI:SS'));

END IF;
    if l_warning_status = 'W' then
       x_return_status := 'W';
    end if;

  EXCEPTION

	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (EXCP) => '||SQLERRM);

        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

            IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_stream_billing_pvt',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
            END IF;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (UNEXP) => '||SQLERRM);

        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

        IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
            Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_stream_billing_pvt',
               'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (OTHERS 1) => '||SQLERRM);

        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

        IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
            Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_stream_billing_pvt',
               'EXCEPTION :'||'OTHERS');
        END IF;

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

  END bill_streams;

END Okl_Stream_Billing_Pvt;

/
