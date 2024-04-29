--------------------------------------------------------
--  DDL for Package Body OKL_CASH_APPL_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CASH_APPL_RULES" AS
/* $Header: OKLRCAPB.pls 120.20 2007/10/05 06:52:27 varangan noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.SETUP';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator
---------------------------------------------------------------------------
-- Function get_okl_installed
---------------------------------------------------------------------------

FUNCTION okl_installed (p_org_id IN NUMBER) RETURN BOOLEAN IS

RULES      NUMBER DEFAULT NULL;
okl_ins    BOOLEAN DEFAULT FALSE;

BEGIN

   SELECT ID INTO RULES
   FROM   OKL_CASH_ALLCTN_RLS_ALL
   WHERE  DEFAULT_RULE = 'YES'
   AND SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE)
   AND org_id = p_org_id;


   IF RULES IS NOT NULL THEN
       okl_ins := TRUE;
   END IF;

   RETURN okl_ins;

EXCEPTION

    WHEN OTHERS THEN

        okl_ins := FALSE;

 -- abindal added for bug 4992891 --
   RETURN okl_ins;

END okl_installed;

---------------------------------------------------------------------------
-- PROCEDURE handle_manual_pay
---------------------------------------------------------------------------

PROCEDURE handle_manual_pay (   p_api_version	      IN  NUMBER
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
                               ,p_contract_id         IN  OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL
				               ,p_contract_num        IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                               ,p_customer_id         IN  OKL_TRX_CSH_RECEIPT_V.ILE_id%TYPE DEFAULT NULL
				               ,p_customer_num        IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
                               ,p_gl_date             IN  OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE DEFAULT NULL
                               ,p_receipt_date        IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                               ,p_bank_account_id     IN  OKL_TRX_CSH_RECEIPT_V.IBA_ID%TYPE DEFAULT NULL
                               ,p_comments            IN  AR_CASH_RECEIPTS_ALL.COMMENTS%TYPE DEFAULT NULL
                               ,p_create_receipt_flag IN  VARCHAR2
							   ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

  l_customer_id			         OKL_TRX_CSH_RECEIPT_V.ILE_id%TYPE DEFAULT p_customer_id;
  l_customer_num		         AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT p_customer_num;

  l_cons_bill_id		         OKL_CNSLD_AR_HDRS_V.ID%TYPE DEFAULT p_cons_bill_id;
  l_cons_bill_num		         OKL_CNSLD_AR_HDRS_V.CONSOLIDATED_INVOICE_NUMBER%TYPE DEFAULT p_cons_bill_num;
  l_contract_id			         OKC_K_HEADERS_V.ID%TYPE DEFAULT p_contract_id;
  l_last_contract_id             OKC_K_HEADERS_V.ID%TYPE DEFAULT 1;
  l_contract_num		         OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT p_contract_num;
  l_contract_number_start_date   OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL;
  l_contract_start_date          OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL;
  l_contract_number_id           OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL;

  --
  l_currency_conv_type           OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT p_currency_conv_type;
  l_currency_conv_date           OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT p_currency_conv_date;
  l_currency_conv_rate           OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT p_currency_conv_rate;
  --

  l_conversion_rate              GL_DAILY_RATES_V.CONVERSION_RATE%TYPE DEFAULT 0;
  l_functional_conversion_rate   GL_DAILY_RATES_V.CONVERSION_RATE%TYPE DEFAULT 0;
  l_inverse_conversion_rate      GL_DAILY_RATES_V.INVERSE_CONVERSION_RATE%TYPE DEFAULT 0;
  l_functional_currency          OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;
  l_invoice_currency_code        OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;
  l_receipt_currency_code        OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT p_currency_code;
  l_irm_id			             OKL_TRX_CSH_RECEIPT_V.IRM_ID%TYPE DEFAULT p_irm_id;            -- receipt method id
  l_check_number		         OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT p_check_number;
  l_rcpt_amount			         OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT p_rcpt_amount;
  l_rcpt_amount_orig		     OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT p_rcpt_amount;
  l_converted_receipt_amount     OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL;
  l_rcpt_date                    OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT TRUNC(p_receipt_date);
  l_gl_date                      OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE DEFAULT p_gl_date;
  l_comments                     AR_CASH_RECEIPTS_ALL.COMMENTS%TYPE DEFAULT p_comments;

  l_cash_receipt_id              AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL;
  l_bank_account_id              OKL_TRX_CSH_RECEIPT_V.IBA_ID%TYPE DEFAULT p_bank_account_id;
  l_receivables_invoice_num	     NUMBER DEFAULT NULL;

  l_over_pay                     VARCHAR(1) DEFAULT NULL;
  l_conc_proc                    VARCHAR(2) DEFAULT p_create_receipt_flag;
  l_ordered			             CONSTANT VARCHAR2(3) := 'ODD';
  l_prorate			             CONSTANT VARCHAR2(3) := 'PRO';

  l_start_date                   DATE;
  l_same_cash_app_rule           VARCHAR(1) DEFAULT NULL;
  l_same_date                    VARCHAR(1) DEFAULT NULL;


  l_org_id                       OKL_TRX_CSH_RECEIPT_V.ORG_ID%TYPE DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();
  i				                 NUMBER DEFAULT NULL;
  d                              NUMBER DEFAULT NULL;
  t                              NUMBER DEFAULT NULL;
  l_first_prorate_rec            NUMBER DEFAULT NULL;
  l_order_count                  NUMBER DEFAULT NULL;

  l_appl_tolerance		         NUMBER := 0;
  l_temp_val			         NUMBER := 0;
  l_inv_tot			             NUMBER := 0;
  l_cont_tot			         NUMBER := 0;
  l_stream_tot                   NUMBER := 0;
  l_pro_rate_inv_total		     NUMBER := 0;

  l_rct_id			             OKL_TRX_CSH_RECEIPT_B.ID%TYPE;
  l_rca_id			             OKL_TXL_RCPT_APPS_V.ID%TYPE;
  l_xcr_id			             NUMBER;

  l_sty_id			             OKL_CNSLD_AR_STRMS_V.STY_ID%TYPE;

  l_rule_name                    OKL_CASH_ALLCTN_RLS.NAME%TYPE DEFAULT NULL;

  l_check_cau_id                 OKL_CSH_ALLCTN_RL_HDR.ID%TYPE DEFAULT NULL;
  l_cau_id                       OKL_CSH_ALLCTN_RL_HDR.ID%TYPE DEFAULT NULL;
  l_cat_id                       OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
  l_tolerance			         OKL_CASH_ALLCTN_RLS.AMOUNT_TOLERANCE_PERCENT%TYPE DEFAULT NULL;
  l_days_past_quote_valid	     OKL_CASH_ALLCTN_RLS.DAYS_PAST_QUOTE_VALID_TOLERANC%TYPE DEFAULT NULL;
  l_months_to_bill_ahead	     OKL_CASH_ALLCTN_RLS.MONTHS_TO_BILL_AHEAD%TYPE DEFAULT NULL;
  l_under_payment		         OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_over_payment		         OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_receipt_msmtch		         OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE DEFAULT NULL;

  l_dflt_name                    OKL_CASH_ALLCTN_RLS.NAME%TYPE DEFAULT NULL;

  l_dflt_cat_id                  OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
  l_dflt_tolerance			     OKL_CASH_ALLCTN_RLS.AMOUNT_TOLERANCE_PERCENT%TYPE DEFAULT NULL;
  l_dflt_days_past_quote_valid	 OKL_CASH_ALLCTN_RLS.DAYS_PAST_QUOTE_VALID_TOLERANC%TYPE DEFAULT NULL;
  l_dflt_months_to_bill_ahead	 OKL_CASH_ALLCTN_RLS.MONTHS_TO_BILL_AHEAD%TYPE DEFAULT NULL;
  l_dflt_under_payment		     OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_dflt_over_payment		     OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_dflt_receipt_msmtch		     OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_sequence_number              OKL_STRM_TYP_ALLOCS.SEQUENCE_NUMBER%TYPE DEFAULT NULL;

  l_dup_rcpt_flag                NUMBER DEFAULT NULL;
  l_create_receipt_flag          VARCHAR2(2) DEFAULT p_create_receipt_flag;
  l_cash_applied_flag            VARCHAR2(1) DEFAULT NULL;
  l_cont_applic                  VARCHAR2(1) DEFAULT 'N';
  l_cons_bill_applic             VARCHAR2(1) DEFAULT 'N';


  l_api_version			         NUMBER := 1.0;
  l_init_msg_list		         VARCHAR2(1) := Okc_Api.g_false;
  l_return_status		         VARCHAR2(1);
  l_msg_count			         NUMBER;
  l_msg_data			         VARCHAR2(2000);


  l_api_name                     CONSTANT VARCHAR2(30) := 'handle_manual_pay';

------------------------------
-- DECLARE Record/Table Types
------------------------------

-- Internal Trans

  l_rctv_rec Okl_Rct_Pvt.rctv_rec_type;
  l_rctv_tbl Okl_Rct_Pvt.rctv_tbl_type;

  l_rcav_rec Okl_Rca_Pvt.rcav_rec_type;
  l_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;

  x_rctv_rec Okl_Rct_Pvt.rctv_rec_type;
  x_rctv_tbl Okl_Rct_Pvt.rctv_tbl_type;

  x_rcav_rec Okl_Rca_Pvt.rcav_rec_type;
  x_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;

----------

-- External Trans

  l_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;
  l_xcrv_tbl Okl_Xcr_Pvt.xcrv_tbl_type;

  l_xcav_rec Okl_Xca_Pvt.xcav_rec_type;
  l_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

  x_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;
  x_xcrv_tbl Okl_Xcr_Pvt.xcrv_tbl_type;

  x_xcav_rec Okl_Xca_Pvt.xcav_rec_type;
  x_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

  t_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;


-------------------
-- DECLARE Cursors
-------------------
-- Updated the cursor to fetch with consolidated bill number, to exclude NVL condition
-- for performance issue - bug#5484903
   CURSOR   c_open_invs ( cp_cons_bill_num	 IN VARCHAR2
			             ,cp_contract_num	 IN VARCHAR2
			             ,cp_customer_num	 IN VARCHAR2
			             ,cp_stream_type_id  IN NUMBER) IS
	SELECT  lpt.stream_type_id
		   ,lpt.amount_due_remaining
           ,lpt.currency_code
		   ,lpt.receivables_invoice_number
		   ,lpt.stream_id
           ,lpt.trx_date
	FROM	OKL_BPD_LEASING_PAYMENT_TRX_V lpt
	WHERE	lpt.consolidated_invoice_number	= cp_cons_bill_num
	AND	    NVL (lpt.contract_number, 999) = NVL (DECODE (cp_contract_num, NULL, lpt.contract_number, cp_contract_num), 999)
	AND	    lpt.customer_number = NVL (cp_customer_num,	lpt.customer_number)
	AND	    lpt.stream_type_id = NVL (cp_stream_type_id, lpt.stream_type_id)
	AND	    lpt.status = 'OP'
	AND	    lpt.amount_due_remaining > 0;

   c_open_invs_rec c_open_invs%ROWTYPE;

----------
--Included  another cursor to exclude the NVL condition on contract number
-- Peformance Issue -bug#5484903

CURSOR   c_open_invs_cont ( cp_cons_bill_num	 IN VARCHAR2
			             ,cp_contract_num	 IN VARCHAR2
			             ,cp_customer_num	 IN VARCHAR2
			             ,cp_stream_type_id  IN NUMBER) IS
	SELECT  lpt.stream_type_id
		   ,lpt.amount_due_remaining
           ,lpt.currency_code
		   ,lpt.receivables_invoice_number
		   ,lpt.stream_id
           ,lpt.trx_date
	FROM	OKL_BPD_LEASING_PAYMENT_TRX_V lpt
	WHERE	lpt.consolidated_invoice_number	= NVL (cp_cons_bill_num, lpt.consolidated_invoice_number)
	AND	    lpt.contract_number = cp_contract_num
	AND	    lpt.customer_number = NVL (cp_customer_num,	lpt.customer_number)
	AND	    lpt.stream_type_id = NVL (cp_stream_type_id, lpt.stream_type_id)
	AND	    lpt.status = 'OP'
	AND	    lpt.amount_due_remaining > 0;

---



   CURSOR   c_inv_date  ( cp_cons_bill_num	 IN VARCHAR2
			             ,cp_customer_num	 IN VARCHAR2) IS
  	SELECT  DISTINCT(lpt.contract_number)
           ,lpt.start_date, lpt.contract_id
	FROM	OKL_BPD_LEASING_PAYMENT_TRX_V lpt
	WHERE	lpt.consolidated_invoice_number	= cp_cons_bill_num -- for performance issue #5484903
	                                                           --NVL (cp_cons_bill_num, lpt.consolidated_invoice_number)
	AND	    lpt.customer_number = NVL (cp_customer_num,	lpt.customer_number);

   c_inv_date_rec c_inv_date%ROWTYPE;

----------

   -- get stream application order
   -- bug 5038588, select streams relevant to contract only
   CURSOR   c_stream_alloc ( cp_str_all_type IN VARCHAR2
                            ,cp_cat_id       IN NUMBER
							,cp_khr_id       IN NUMBER) IS
	SELECT	distinct sta.sty_id, sta.sequence_number
	FROM	OKL_STRM_TYP_ALLOCS sta, OKL_CNSLD_AR_STRMS_B st
	WHERE	sta.stream_allc_type = cp_str_all_type
    AND     sta.cat_id = cp_cat_id
    AND     st.khr_id = cp_khr_id
    AND     sta.sty_id = st.sty_id
	ORDER BY sta.sequence_number;

----------
/*
   -- get current exchange rates
   CURSOR   c_get_conversion_rate( cp_from_currency IN VARCHAR2
                                  ,cp_to_currency   IN VARCHAR2) IS
    SELECT  conversion_rate, inverse_conversion_rate
    FROM    GL_DAILY_RATES_V
    WHERE   conversion_type = 'Corporate'
    AND     status_code = 'C'
    AND     from_currency = cp_from_currency
    AND     to_currency = cp_to_currency
    ORDER BY conversion_date DESC;
*/
----------

   -- get a contract number if not known
   -- Added distinct clause as per bug 4510824

   CURSOR   c_get_contract_num (cp_cons_bill_num IN VARCHAR2) IS

   select distinct(ST.KHR_ID) CONTRACT_ID ,
		CN.CONTRACT_NUMBER CONTRACT_NUMBER ,
		CN.START_DATE START_DATE
   from
	OKC_K_HEADERS_ALL_B CN,
	OKL_CNSLD_AR_STRMS_B ST,
	OKL_CNSLD_AR_HDRS_B HD,
	HZ_CUST_ACCOUNTS CA,
	OKL_CNSLD_AR_LINES_B LN,
	AR_PAYMENT_SCHEDULES_ALL PS
   WHERE PS.CLASS IN ('INV', 'CM')
   AND ST.RECEIVABLES_INVOICE_ID = PS.CUSTOMER_TRX_ID AND LN.ID = ST.LLN_ID
   AND HD.ID = LN.CNR_ID AND CA.CUST_ACCOUNT_ID = HD.IXX_ID
   AND CN.ID = ST.KHR_ID
   and HD.CONSOLIDATED_INVOICE_NUMBER = cp_cons_bill_num
   and     ps.status = 'OP'
   and     ps.amount_due_remaining > 0
   ORDER BY CN.start_date; -- fixed for performance bug#5484903 - varangan- 19-9-06

  /*  commented for bug#5484903 - varangan-19-9-06
        SELECT  distinct (lpt.contract_id), lpt.contract_number, lpt.start_date
        FROM	OKL_BPD_LEASING_PAYMENT_TRX_V lpt
	WHERE	lpt.consolidated_invoice_number	= cp_cons_bill_num
	AND	    lpt.status = 'OP'
	AND	    lpt.amount_due_remaining > 0*/


----------

   -- get a contract id if not known
   CURSOR   c_get_contract_id (cp_contract_num IN VARCHAR2) IS
	select ST.KHR_ID CONTRACT_ID
	from
	OKC_K_HEADERS_ALL_B CN,
	OKL_CNSLD_AR_STRMS_B ST,
	AR_PAYMENT_SCHEDULES_ALL PS
	WHERE PS.CLASS IN ('INV', 'CM')
	AND ST.RECEIVABLES_INVOICE_ID = PS.CUSTOMER_TRX_ID
	AND CN.ID = ST.KHR_ID
	and CN.CONTRACT_NUMBER = cp_contract_num
	and     ps.status = 'OP'
	and     ps.amount_due_remaining > 0
	ORDER BY CN.start_date;  -- fixed for performance bug#5484903 - varangan- 19-9-06

     /*  commented for bug#5484903 - varangan-19-9-06
    SELECT  lpt.contract_id
    FROM	OKL_BPD_LEASING_PAYMENT_TRX_V lpt
	WHERE	lpt.contract_number = cp_contract_num
	AND	    lpt.status = 'OP'
	AND	    lpt.amount_due_remaining > 0
    ORDER BY lpt.start_date; */

----------

   -- get org_id for contract
   CURSOR   c_get_org_id (cp_contract_num IN VARCHAR2) IS
    SELECT  authoring_org_id
     FROM   OKC_K_HEADERS_B
     WHERE  contract_number = cp_contract_num;

----------

   -- check for duplicate receipt numbers
   CURSOR   c_dup_rcpt( cp_customer_id IN NUMBER
                       ,cp_check_num IN VARCHAR2
                     --,cp_amount IN NUMBER
                       ,cp_receipt_date IN DATE
                      ) IS
    SELECT  '1'
    FROM    OKL_TRX_CSH_RECEIPT_V
    WHERE   ile_id = cp_customer_id
    AND     check_number = cp_check_num
--  AND     amount = cp_amount
    AND     TRUNC(date_effective) = TRUNC(cp_receipt_date);

----------

   -- get header and line id's for consolidated invoice reference
   CURSOR   c_get_int_id_cons ( cp_customer_id IN NUMBER
                               ,cp_check_num IN VARCHAR2
                               ,cp_amount IN NUMBER
                               ,cp_cons_bill_id IN NUMBER) IS
    SELECT  a.id, b.id
    FROM    OKL_TRX_CSH_RECEIPT_V a, OKL_TXL_RCPT_APPS_V b
    WHERE   a.id = b.rct_id_details
    AND     a.ile_id = cp_customer_id
    AND     a.check_number = cp_check_num
    AND     a.amount = cp_amount
    AND     b.cnr_id = NVL(cp_cons_bill_id, NULL);

----------

   -- get header and line id's for contract reference
   CURSOR   c_get_int_id_cont ( cp_customer_id IN NUMBER
                               ,cp_check_num IN VARCHAR2
                               ,cp_amount IN NUMBER
                               ,cp_contract_id IN NUMBER) IS
    SELECT  a.id, b.id
    FROM    OKL_TRX_CSH_RECEIPT_V a, OKL_TXL_RCPT_APPS_V b
    WHERE   a.id = b.rct_id_details
    AND     a.ile_id = cp_customer_id
    AND     a.check_number = cp_check_num
    AND     a.amount = cp_amount
    AND     b.khr_id = NVL(cp_contract_id, NULL);

----------

   -- get bank details
   CURSOR   c_get_remit_bnk_dtls ( cp_irm_id IN NUMBER ) IS
    SELECT  bank_name, bank_account_num
    FROM    OKL_BPD_RCPT_MTHDS_UV
    WHERE   receipt_method_id = cp_irm_id;

----------

   -- get cash applic rule id
   CURSOR   c_cash_rle_id_csr ( cp_khr_id IN NUMBER) IS
    SELECT  to_number(a.object1_id1)
    FROM    OKC_RULES_B a, OKC_RULE_GROUPS_B b
    WHERE   a.rgp_id = b.id
    AND     b.rgd_code = 'LABILL'
    AND     a.rule_information_category = 'LAINVD'
    AND     a.dnz_chr_id = b.chr_id
    AND     a.dnz_chr_id = cp_khr_id;

----------

   -- get cash applic rule for contract
   CURSOR   c_cash_rule_csr  ( cp_cau_id IN NUMBER ) IS
    SELECT  ID
           ,NAME
           ,AMOUNT_TOLERANCE_PERCENT
           ,DAYS_PAST_QUOTE_VALID_TOLERANC
           ,MONTHS_TO_BILL_AHEAD
           ,UNDER_PAYMENT_ALLOCATION_CODE
           ,OVER_PAYMENT_ALLOCATION_CODE
           ,RECEIPT_MSMTCH_ALLOCATION_CODE
    FROM    OKL_CASH_ALLCTN_RLS
    WHERE   CAU_ID = cp_cau_id
    AND     START_DATE <= trunc(SYSDATE)
    AND     (END_DATE >= trunc(SYSDATE) OR END_DATE IS NULL);

----------

   -- get default cash applic rule for organization
   CURSOR   c_dflt_cash_applic_rule IS
	SELECT  ID
           ,NAME
           ,AMOUNT_TOLERANCE_PERCENT
           ,DAYS_PAST_QUOTE_VALID_TOLERANC
           ,MONTHS_TO_BILL_AHEAD
           ,UNDER_PAYMENT_ALLOCATION_CODE
           ,OVER_PAYMENT_ALLOCATION_CODE
           ,RECEIPT_MSMTCH_ALLOCATION_CODE
	FROM    OKL_CASH_ALLCTN_RLS
    WHERE   default_rule = 'YES'
    AND     TRUNC(end_date) IS NULL;


    --start code by pgomes on 03/05/2003
    CURSOR l_khr_curr_csr(cp_contract_id IN NUMBER) IS SELECT currency_code
    FROM okl_k_headers_full_v
    WHERE id = cp_contract_id;

    CURSOR l_inv_curr_csr(cp_cons_bill_id IN NUMBER) IS SELECT currency_code
    FROM okl_cnsld_ar_hdrs_b
    WHERE id = cp_cons_bill_id;

    l_currency_code okl_k_headers_full_v.currency_code%type;
    --end code by pgomes on 03/05/2003
BEGIN

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_functional_currency := okl_accounting_util.get_func_curr_code;

    -- check for mandatory fields

    IF l_customer_num = '0' OR
       l_cons_bill_num = '0' OR
       l_contract_num = '0' OR
       l_receipt_currency_code = '0' OR
       l_irm_id = '0' OR
       l_check_number = '0' OR
       l_rcpt_date IS NULL OR
       l_rcpt_date = '' OR
       l_rcpt_amount = '0' THEN

       -- Message Text: Please enter all mandatory fields
       x_return_status := OKC_API.G_RET_STS_ERROR;
       OKC_API.set_message( p_app_name    => G_APP_NAME,
                            p_msg_name    =>'OKL_BPD_MISSING_FIELDS');

       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    --start code by pgomes on 03/05/2003
    IF (p_contract_id IS NOT NULL) THEN
      OPEN l_khr_curr_csr(p_contract_id);
      FETCH l_khr_curr_csr INTO l_currency_code;
      CLOSE l_khr_curr_csr;

      IF (l_currency_code <> p_currency_code) THEN
       OKC_API.set_message( p_app_name    => G_APP_NAME,
                            p_msg_name    =>'OKL_BPD_RCPT_KHR_CURR_ERROR');

       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSIF (p_cons_bill_id IS NOT NULL) THEN
      OPEN l_inv_curr_csr(p_cons_bill_id);
      FETCH l_inv_curr_csr INTO l_currency_code;
      CLOSE l_inv_curr_csr;

      IF (l_currency_code <> p_currency_code) THEN
       OKC_API.set_message( p_app_name    => G_APP_NAME,
                            p_msg_name    =>'OKL_BPD_RCPT_INV_CURR_ERROR');

       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
    --end code by pgomes on 03/05/2003

    -- check receipt date and gl_date
/*
    IF l_rcpt_date IS NULL OR
       l_rcpt_date = '' THEN

        l_rcpt_date := TRUNC(SYSDATE);

    END IF;

    IF l_gl_date IS NULL OR
       l_gl_date = '' THEN

        l_gl_date := TRUNC(SYSDATE);

    END IF;
*/

  	-- check to see if customer is delinquent.
	-- IF customer IS delinqient THEN
	--	call Collections process
	-- END IF;

	-- get default cash app rule for organization ...

	OPEN c_dflt_cash_applic_rule;
	FETCH c_dflt_cash_applic_rule INTO  l_dflt_cat_id
                                       ,l_dflt_name
		                               ,l_dflt_tolerance
		                               ,l_dflt_days_past_quote_valid
		                               ,l_dflt_months_to_bill_ahead
		                               ,l_dflt_under_payment
		                               ,l_dflt_over_payment
		                               ,l_dflt_receipt_msmtch;
  	CLOSE c_dflt_cash_applic_rule;

	--  get invoice amount due remaining and invoice currency

    FOR c_open_invs_rec IN c_open_invs (l_cons_bill_num, l_contract_num, l_customer_num, NULL)
    LOOP
        l_invoice_currency_code := c_open_invs_rec.currency_code;
        l_inv_tot := l_inv_tot + c_open_invs_rec.amount_due_remaining;  -- changed from remaining to original
    END LOOP;

--  IF l_invoice_currency_code <> l_receipt_currency_code AND  --bv
    IF l_functional_currency <> l_receipt_currency_code AND
       l_currency_conv_type IN ('NONE') THEN


        -- Message Text: Please enter a currency type.
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_BPD_PLS_ENT_CUR_TYPE');

        RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

--  IF l_invoice_currency_code = l_receipt_currency_code THEN -- bv
    IF l_functional_currency = l_receipt_currency_code THEN

        IF l_currency_conv_type IN ('CORPORATE', 'SPOT', 'USER') OR
           l_currency_conv_rate <> '0' THEN

            -- Message Text: Currency conversion values are not required when the receipt and invoice currency's are the same.
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_BPD_SAME_CURRENCY');

            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

    END IF;

--  IF l_invoice_currency_code <> l_receipt_currency_code AND  -- bv
    IF l_functional_currency <> l_receipt_currency_code AND
       l_currency_conv_type NOT IN ('USER') THEN

        IF l_currency_conv_date IS NULL OR l_currency_conv_date = '' THEN

            l_currency_conv_date := trunc(l_rcpt_date);

        END IF;

        IF l_currency_conv_type = 'CORPORATE' THEN

            l_currency_conv_type := 'Corporate';
        ELSE
            l_currency_conv_type := 'Spot';
        END IF;

        l_functional_conversion_rate := okl_accounting_util.get_curr_con_rate( l_receipt_currency_code
                                                                              ,l_functional_currency
	                                                                          ,l_currency_conv_date
	                                                                          ,l_currency_conv_type
                                                                              );

        l_inverse_conversion_rate := okl_accounting_util.get_curr_con_rate( l_functional_currency
                                                                           ,l_receipt_currency_code
	                                                                       ,l_currency_conv_date
	                                                                       ,l_currency_conv_type
                                                                          );


        IF l_functional_conversion_rate IN (0,-1) THEN

            -- Message Text: No exchange rate defined
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');

            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

        l_currency_conv_rate := l_functional_conversion_rate;

--  ELSIF l_invoice_currency_code <> l_receipt_currency_code AND  --bv
    ELSIF l_functional_currency <> l_receipt_currency_code AND
          l_currency_conv_type IN ('USER') THEN

        IF l_currency_conv_rate IS NULL OR l_currency_conv_rate = '0' THEN

            -- Message Text: No exchange rate defined for currency conversion type USER.
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_BPD_USR_RTE_SUPPLIED');

            RAISE G_EXCEPTION_HALT_VALIDATION;

        ELSE

            l_functional_conversion_rate := l_currency_conv_rate;
            l_inverse_conversion_rate := l_functional_conversion_rate / 1;

        END IF;

        l_currency_conv_type := 'User';
        l_currency_conv_date := trunc(SYSDATE);

    ELSE
            -- no currency conversion required
            l_currency_conv_date := NULL;
            l_currency_conv_type := NULL;
            l_currency_conv_rate := NULL;

    END IF;

    -- need to obtain the exchange rate for invoice currency and receipt currency ...
    IF l_invoice_currency_code <> l_receipt_currency_code THEN

        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_receipt_currency_code
                                                                   ,l_invoice_currency_code
	                                                               ,trunc(SYSDATE)
	                                                               ,'Corporate'
                                                                  );


        IF l_conversion_rate IN (0,-1) THEN

            -- Message Text: No exchange rate defined
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');

            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

        -- convert receipt amount to the transaction currency ...
        l_converted_receipt_amount := (l_rcpt_amount * l_conversion_rate);
        l_rcpt_amount := l_converted_receipt_amount;

    END IF;

   	-- Check for exceptions

	IF l_rcpt_amount = 0 OR l_rcpt_amount IS NULL THEN

        -- Message Text: The receipt cannot have a value of zero
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_BPD_ZERO_RECEIPT');

        RAISE G_EXCEPTION_HALT_VALIDATION;

	ELSIF l_inv_tot = 0 OR l_inv_tot IS NULL THEN

        -- Message Text: The invoice has an amount of zero
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_BPD_ZERO_INVOICE');

        RAISE G_EXCEPTION_HALT_VALIDATION;


	ELSIF l_dflt_tolerance IS NULL OR l_dflt_under_payment IS NULL
	   OR l_dflt_over_payment IS NULL OR l_dflt_receipt_msmtch IS NULL THEN

        -- Message Text: No DEFAULT cash application rule defined
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_BPD_NO_CSH_RLS_DEF');

        RAISE G_EXCEPTION_HALT_VALIDATION;

    ELSIF l_rcpt_amount >= l_inv_tot AND
          l_create_receipt_flag = 'N' THEN      -- allocate receipt

        -- Message Text: No cash allocation required
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_BPD_NO_ALLOC_REQ');

        RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- check for duplicate check number for customer as validation has been taken out of the
    -- tapi.  this is for collections.

    IF l_create_receipt_flag <> 'YC' THEN  -- for concurrent transactions, dup check number check already done.

        OPEN  c_dup_rcpt(l_customer_id, l_check_number, TRUNC(l_rcpt_date));
        FETCH c_dup_rcpt INTO l_dup_rcpt_flag;
        CLOSE c_dup_rcpt;


        IF l_dup_rcpt_flag = 1 THEN

            -- Message Text: Duplicate receipt number for customer
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_BPD_DUP_RECEIPT');

            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

    END IF;

	-- Create record in Internal Transaction Table.

	-- CREATE HEADER REC

	l_rctv_rec.IRM_ID		      := l_irm_id;
    l_rctv_rec.IBA_ID		      := l_bank_account_id;
	l_rctv_rec.ILE_ID		      := l_customer_id;
	l_rctv_rec.CHECK_NUMBER		  := l_check_number;
	l_rctv_rec.AMOUNT		      := l_rcpt_amount_orig;          -- in receipt amount
	l_rctv_rec.CURRENCY_CODE	  := l_receipt_currency_code;     -- entered currency

	l_rctv_rec.EXCHANGE_RATE      := l_currency_conv_rate;
	l_rctv_rec.EXCHANGE_RATE_TYPE := l_currency_conv_type;
	l_rctv_rec.EXCHANGE_RATE_DATE := trunc(l_currency_conv_date);

	l_rctv_rec.DATE_EFFECTIVE	  := trunc(l_rcpt_date);
    l_rctv_rec.GL_DATE            := trunc(l_gl_date);
    l_rctv_rec.ORG_ID             := l_org_id;

	i := 1;

	l_rcav_tbl(i).CNR_ID          := l_cons_bill_id;
	l_rcav_tbl(i).KHR_ID          := l_contract_id;
--	l_rcav_tbl(i).LLN_ID          := l_lln_id;        -- consolidated ar lines id
--	l_rcav_tbl(i).LSM_ID          := l_lsm_id;        -- consolidated ar streams id
	l_rcav_tbl(i).ILE_ID          := l_customer_id;
	l_rcav_tbl(i).AMOUNT          := l_rcpt_amount_orig;
	l_rcav_tbl(i).LINE_NUMBER     := i;
    l_rcav_tbl(i).ORG_ID          := l_org_id;

    IF l_create_receipt_flag <> 'YC' THEN       -- not needed for concurrent process.

-- Start of wraper code generated automatically by Debug code generator for Okl_Rct_Pub.create_internal_trans
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCAPB.pls call Okl_Rct_Pub.create_internal_trans  ');
    END;
  END IF;
 	    Okl_Rct_Pub.create_internal_trans (l_api_version
			    		                  ,l_init_msg_list
				    	                  ,l_return_status
				    	                  ,l_msg_count
				    	                  ,l_msg_data
					                      ,l_rctv_rec
					                      ,l_rcav_tbl
    					                  ,x_rctv_rec
	    				                  ,x_rcav_tbl
                                          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCAPB.pls call Okl_Rct_Pub.create_internal_trans  ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Rct_Pub.create_internal_trans

	    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_rct_id := x_rctv_rec.ID;
        l_rca_id := x_rcav_tbl(x_rcav_tbl.FIRST).ID;

    ELSE

        IF l_cons_bill_id IS NOT NULL THEN
            OPEN  c_get_int_id_cons(l_customer_id, l_check_number, l_rcpt_amount_orig, l_cons_bill_id);
            FETCH c_get_int_id_cons INTO l_rct_id, l_rca_id;
            CLOSE c_get_int_id_cons;
        ELSE
            OPEN  c_get_int_id_cont(l_customer_id, l_check_number, l_rcpt_amount_orig, l_contract_id);
            FETCH c_get_int_id_cont INTO l_rct_id, l_rca_id;
            CLOSE c_get_int_id_cont;
        END IF;

    END IF;

	-- Internal Record created.
    --  **************************************************
    --  Contract level cash application processing BEGINS
    --  **************************************************

    IF l_contract_num IS NOT NULL THEN -- (1)

        l_cont_applic := 'Y';

        IF l_contract_id IS NULL THEN
            OPEN c_get_contract_id(l_contract_num);
            FETCH c_get_contract_id INTO l_contract_id;
            CLOSE c_get_contract_id;
        END IF;

        -- get cash application rule
        OPEN c_cash_rle_id_csr (l_contract_id);
        FETCH c_cash_rle_id_csr INTO l_cau_id;
        CLOSE c_cash_rle_id_csr;

       -- don't do cash application if CAR is 'On Account'  -- varao start
       IF NVL(l_cau_id, 0) = -1 THEN
         l_over_pay := 'O';   -- Customer's account
       ELSE                                                 -- varao end

        IF l_cau_id IS NOT NULL THEN

            OPEN c_cash_rule_csr (l_cau_id);
            FETCH c_cash_rule_csr INTO  l_cat_id
                                       ,l_rule_name
                                       ,l_tolerance
                                       ,l_days_past_quote_valid
                                       ,l_months_to_bill_ahead
                                       ,l_under_payment
                                       ,l_over_payment
		                       ,l_receipt_msmtch;
            CLOSE c_cash_rule_csr;

            IF l_tolerance IS NULL THEN

                        l_rule_name             := l_dflt_name;
                        l_cat_id                := l_dflt_cat_id;
                        l_tolerance             := l_dflt_tolerance;
                        l_days_past_quote_valid := l_dflt_days_past_quote_valid;
		                l_months_to_bill_ahead  := l_dflt_months_to_bill_ahead;
		                l_under_payment         := l_dflt_under_payment;
		                l_over_payment          := l_dflt_over_payment;
		                l_receipt_msmtch        := l_dflt_receipt_msmtch;
            END IF;

        ELSE -- use default rule

            l_rule_name             := l_dflt_name;
            l_cat_id                := l_dflt_cat_id;
            l_tolerance             := l_dflt_tolerance;
            l_days_past_quote_valid := l_dflt_days_past_quote_valid;
	        l_months_to_bill_ahead  := l_dflt_months_to_bill_ahead;
	        l_under_payment         := l_dflt_under_payment;
	        l_over_payment          := l_dflt_over_payment;
	        l_receipt_msmtch        := l_dflt_receipt_msmtch;

        END IF;

        -- TOLERANCE CHECK

        IF l_inv_tot > l_rcpt_amount THEN
            l_appl_tolerance := l_inv_tot * (1 - l_tolerance / 100);
        ELSE
	        l_appl_tolerance := l_inv_tot;
        END IF;

  	    IF l_inv_tot > l_rcpt_amount AND l_appl_tolerance > l_rcpt_amount THEN -- UNDERPAYMENT  (2)

            IF l_under_payment IN ('T','t') THEN -- ORDERED (3)

			 -- i := 1;
			    i := 0; --bv

                l_order_count := 0;

			    OPEN c_stream_alloc (l_ordered, l_cat_id, l_contract_id);
			    LOOP

				    FETCH c_stream_alloc INTO l_sty_id, l_sequence_number;
				    EXIT WHEN c_stream_alloc%NOTFOUND
					OR l_rcpt_amount = 0
					OR l_rcpt_amount IS NULL;

				    OPEN c_open_invs_cont (NULL, l_contract_num, l_customer_num, l_sty_id);
				    LOOP
					    FETCH c_open_invs_cont INTO c_open_invs_rec;

					    EXIT WHEN c_open_invs_cont%NOTFOUND
						    OR l_rcpt_amount = 0
						    OR l_rcpt_amount IS NULL;

					l_order_count := l_order_count + 1;

					i := i + 1;

					    l_xcav_tbl(i).INVOICE_NUMBER := c_open_invs_rec.receivables_invoice_number;
					    l_xcav_tbl(i).AMOUNT_APPLIED := c_open_invs_rec.amount_due_remaining;
					l_xcav_tbl(i).LSM_ID         := c_open_invs_rec.stream_id;
					l_xcav_tbl(i).TRX_DATE       := c_open_invs_rec.trx_date;
					l_xcav_tbl(i).CAT_ID         := l_cat_id;

					    IF l_xcav_tbl(i).AMOUNT_APPLIED > l_rcpt_amount THEN

						    l_xcav_tbl(i).AMOUNT_APPLIED := l_rcpt_amount;

						l_rcpt_amount := 0;

					    ELSE

               					l_rcpt_amount := l_rcpt_amount - l_xcav_tbl(i).AMOUNT_APPLIED;

					    END IF;

						IF l_receipt_currency_code <> l_invoice_currency_code THEN
						    -- convert back to receipt currency
						    l_xcav_tbl(i).AMOUNT_APPLIED_FROM := l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
						    l_xcav_tbl(i).TRANS_TO_RECEIPT_RATE := l_conversion_rate;
						END IF;

								    l_xcav_tbl(i).INVOICE_CURRENCY_CODE := l_receipt_currency_code;
								    l_xcav_tbl(i).RCA_ID                := l_rca_id;
						l_xcav_tbl(i).ORG_ID                := l_org_id;
						l_xcav_tbl(i).TRX_DATE              := c_open_invs_rec.trx_date;
						l_xcav_tbl(i).CAT_ID                := l_cat_id;

							  --  i := i + 1; --bv

				    END LOOP;
				    CLOSE c_open_invs_cont;

			    END LOOP;
			    CLOSE c_stream_alloc;


                IF l_order_count = 0 THEN

                    -- Message Text: No order transaction types for contract
                    x_return_status := OKC_API.G_RET_STS_ERROR;

                    OKC_API.set_message( p_app_name      => G_APP_NAME
                                        ,p_msg_name      => 'OKL_BPD_NO_ORDER_STRMS'
                                        ,p_token1        => 'RULE_NAME'
                                        ,p_token1_value  => l_rule_name
                                        ,p_token2        => 'CONTRACT_NUMBER'
                                        ,p_token2_value  => l_contract_num);

                    RAISE G_EXCEPTION_HALT_VALIDATION;

                END IF;

		    ELSIF l_under_payment IN ('P','p') THEN -- PRO RATE (3)

			    -- i := 1;
			    i := 0;  --bv

			    -- obtain all the streams that are part of the pro rate user defined list.

			    FOR c_stream_alloc_rec IN c_stream_alloc (l_prorate, l_cat_id, l_contract_id) LOOP


				    l_sty_id := c_stream_alloc_rec.sty_id;

				    FOR c_open_invs_rec IN c_open_invs_cont (NULL, l_contract_num, l_customer_num, l_sty_id)
				    LOOP
                                            i := i + 1; --bv
					    l_xcav_tbl(i).AMOUNT_APPLIED := c_open_invs_rec.amount_due_remaining;

                        IF l_receipt_currency_code <> l_invoice_currency_code THEN
                            -- convert back to receipt currency
                            l_xcav_tbl(i).AMOUNT_APPLIED_FROM := l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
                            l_xcav_tbl(i).TRANS_TO_RECEIPT_RATE := l_conversion_rate;
                        END IF;

					    l_xcav_tbl(i).INVOICE_NUMBER        := c_open_invs_rec.receivables_invoice_number;
					    l_xcav_tbl(i).LSM_ID                := c_open_invs_rec.stream_id;
					    l_xcav_tbl(i).INVOICE_CURRENCY_CODE := l_receipt_currency_code;
					    l_xcav_tbl(i).RCA_ID                := l_rca_id;
                        l_xcav_tbl(i).ORG_ID                := l_org_id;
                        l_xcav_tbl(i).TRX_DATE              := c_open_invs_rec.trx_date;
                        l_xcav_tbl(i).CAT_ID                := l_cat_id;
					    l_pro_rate_inv_total                := l_pro_rate_inv_total + l_xcav_tbl(i).AMOUNT_APPLIED;
					    -- i := i + 1;

				    END LOOP; -- c_open_invs

			    END LOOP; -- c_stream_alloc

			    -- Calc Pro Ration
			    -- only if total amount of prorated invoices is greater than receipt

                IF l_pro_rate_inv_total IS NULL OR l_pro_rate_inv_total = 0 THEN

                    -- Message Text: No prorated transaction types for contract
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                    OKC_API.set_message( p_app_name      => G_APP_NAME
                                        ,p_msg_name      => 'OKL_BPD_NO_PRORATED_STRMS'
                                        ,p_token1        => 'RULE_NAME'
                                        ,p_token1_value  => l_rule_name
                                        ,p_token2        => 'CONTRACT_NUMBER'
                                        ,p_token2_value  => l_contract_num);

                    RAISE G_EXCEPTION_HALT_VALIDATION;

  	            END IF;

			    IF (l_pro_rate_inv_total > l_rcpt_amount) THEN
				    i := l_xcav_tbl.FIRST;
				    l_temp_val := l_rcpt_amount / l_pro_rate_inv_total;
				    LOOP
					    l_xcav_tbl(i).AMOUNT_APPLIED := l_temp_val * l_xcav_tbl(i).AMOUNT_APPLIED;

                        IF l_receipt_currency_code <> l_invoice_currency_code THEN
                            -- convert back to receipt currency
                            l_xcav_tbl(i).AMOUNT_APPLIED_FROM := l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
                        END IF;

					    EXIT WHEN (i = l_xcav_tbl.LAST);
					    i := i + 1;
				    END LOOP;
			    END IF;

		    ELSIF l_under_payment IN ('U','u') THEN --(3)

                l_over_pay := 'U';      -- UNAPPLIED

		    END IF; -- (3)

	    ELSE -- EXACT or OVERPAYMENT or TOLERANCE  (2)

 		    -- CREATE LINES TABLE

		    i := 0;

		    OPEN c_open_invs_cont (NULL, l_contract_num, l_customer_num, NULL);

		    LOOP
			    FETCH c_open_invs_cont INTO c_open_invs_rec;
			    EXIT WHEN c_open_invs_cont%NOTFOUND
			    OR l_rcpt_amount = 0 OR l_rcpt_amount IS NULL;

                i := i + 1;

			    l_xcav_tbl(i).INVOICE_NUMBER := c_open_invs_rec.receivables_invoice_number;
			    l_xcav_tbl(i).AMOUNT_APPLIED := c_open_invs_rec.amount_due_remaining;

                IF l_receipt_currency_code <> l_invoice_currency_code THEN
                    -- convert back to receipt currency
                    l_xcav_tbl(i).AMOUNT_APPLIED_FROM := l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
                    l_xcav_tbl(i).TRANS_TO_RECEIPT_RATE := l_conversion_rate;
                END IF;

			    l_xcav_tbl(i).LSM_ID                := c_open_invs_rec.stream_id;
                l_xcav_tbl(i).INVOICE_CURRENCY_CODE := l_receipt_currency_code;
			    l_xcav_tbl(i).RCA_ID                := l_rca_id;
                l_xcav_tbl(i).ORG_ID                := l_org_id;
                l_xcav_tbl(i).TRX_DATE              := c_open_invs_rec.trx_date;
                l_xcav_tbl(i).CAT_ID                := l_cat_id;

			    IF l_rcpt_amount < l_xcav_tbl(i).AMOUNT_APPLIED THEN
				    -- TOLERANCE
				    l_xcav_tbl(i).AMOUNT_APPLIED := l_rcpt_amount;

				    l_rcpt_amount := 0;
				    --i := i + 1;

			    ELSE

				    l_rcpt_amount := l_rcpt_amount - l_xcav_tbl(i).AMOUNT_APPLIED;
				    --i := i + 1;

			    END IF;

                IF l_receipt_currency_code <> l_invoice_currency_code THEN
                    -- convert back to receipt currency
                    l_xcav_tbl(i).AMOUNT_APPLIED_FROM := l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
                END IF;

		    END LOOP;

		    CLOSE c_open_invs_cont;

        END IF; -- under payment.

      END IF;  -- 'On Account' CAR

    ELSIF l_cons_bill_num IS NOT NULL THEN

        l_cons_bill_applic := 'Y';

        i :=  0;

        --  ************************************************
        --  Check for same start date
        --  ************************************************

        OPEN  c_inv_date(l_cons_bill_num, l_customer_num);
        FETCH c_inv_date INTO l_contract_number_start_date, l_start_date, l_contract_number_id;
        CLOSE c_inv_date;

        d := 0;
        FOR c_inv_date_rec IN c_inv_date(l_cons_bill_num, l_customer_num)
	    LOOP

            IF TRUNC(l_start_date) = TRUNC(c_inv_date_rec.start_date) THEN
                l_same_date := 'Y';
                d := d + 1;
            ELSE
                l_same_date := 'N';
                EXIT;
            END IF;

	    END LOOP;

        IF d = 1 THEN
            l_same_date := 'N';
        END IF;

        --  ************************************************
        --  Check for same cash application rule
        --  ************************************************

        OPEN  c_cash_rle_id_csr (l_contract_number_id);
        FETCH c_cash_rle_id_csr INTO l_cau_id;
        CLOSE c_cash_rle_id_csr;

        d := 0;
        FOR c_inv_date_rec IN c_inv_date(l_cons_bill_num, l_customer_num)
	    LOOP

            l_check_cau_id := NULL;

            OPEN c_cash_rle_id_csr (c_inv_date_rec.contract_id);
            FETCH c_cash_rle_id_csr INTO l_check_cau_id;
            CLOSE c_cash_rle_id_csr;

            IF l_check_cau_id IS NULL THEN
                l_same_cash_app_rule := 'N';
                EXIT;
            END IF;

            IF l_cau_id = l_check_cau_id THEN
                l_same_cash_app_rule := 'Y';
                d := d + 1;
            ELSE
                l_same_cash_app_rule := 'N';
                EXIT;
            END IF;

        END LOOP;

        IF d = 1 THEN
            l_same_cash_app_rule := 'N';
        END IF;

        IF l_same_date = 'Y' AND l_same_cash_app_rule = 'Y' THEN

          -- don't do cash application if CAR is 'On Account'  -- varao start
          IF NVL(l_cau_id, 0) = -1 THEN
             l_over_pay := 'O';   -- Customer's account
          ELSE                                                 -- varao end

            --  *******************************************************
            --  Start stream level cash application using default cash
            --  application rule for all
            --  *******************************************************

            l_rule_name             := l_dflt_name;
            l_cat_id                := l_dflt_cat_id;
            l_tolerance             := l_dflt_tolerance;
            l_days_past_quote_valid := l_dflt_days_past_quote_valid;
		    l_months_to_bill_ahead  := l_dflt_months_to_bill_ahead;
		    l_under_payment         := l_dflt_under_payment;
		    l_over_payment          := l_dflt_over_payment;
		    l_receipt_msmtch        := l_dflt_receipt_msmtch;


            --  ************************************************
            --  Stream level cash application processing BEGINS
            --  ************************************************

            -- get stream total

            l_stream_tot := 0;
            FOR c_open_invs_rec IN c_open_invs (l_cons_bill_num, NULL, l_customer_num, NULL)
            LOOP
                l_invoice_currency_code := c_open_invs_rec.currency_code;
                l_stream_tot := l_stream_tot + c_open_invs_rec.amount_due_remaining;

            -- changed from remaining to original
            END LOOP;

            -- calculate tolerance
            IF l_stream_tot > l_rcpt_amount THEN
	            l_appl_tolerance := l_stream_tot * (1 - l_tolerance / 100);
	        ELSE
		        l_appl_tolerance := l_stream_tot;
	        END IF;

            IF l_stream_tot > l_rcpt_amount AND l_appl_tolerance > l_rcpt_amount THEN -- UNDERPAYMENT  (2)

                IF l_under_payment IN ('T','t') THEN -- ORDERED (3)

                    l_order_count := 0;

                    OPEN c_stream_alloc (l_ordered, l_cat_id, l_contract_number_id);
			        LOOP
	                    FETCH c_stream_alloc INTO l_sty_id, l_sequence_number;
				        EXIT WHEN c_stream_alloc%NOTFOUND
					    OR l_rcpt_amount = 0
					    OR l_rcpt_amount IS NULL;

                        OPEN c_open_invs (l_cons_bill_num, NULL, l_customer_num, l_sty_id);
	                    LOOP

			                FETCH c_open_invs INTO c_open_invs_rec;

			                EXIT WHEN c_open_invs%NOTFOUND OR l_rcpt_amount = 0 OR l_rcpt_amount IS NULL;

                            i := i + 1;

                            l_order_count := l_order_count + 1;

                            l_xcav_tbl(i).INVOICE_NUMBER := c_open_invs_rec.receivables_invoice_number;
					        l_xcav_tbl(i).AMOUNT_APPLIED := c_open_invs_rec.amount_due_remaining;
                            l_xcav_tbl(i).LSM_ID         := c_open_invs_rec.stream_id;
                            l_xcav_tbl(i).TRX_DATE       := c_open_invs_rec.trx_date;
                            l_xcav_tbl(i).CAT_ID         := l_cat_id;

    		                IF l_xcav_tbl(i).AMOUNT_APPLIED > l_rcpt_amount THEN

			                    l_xcav_tbl(i).AMOUNT_APPLIED := l_rcpt_amount;

                                l_rcpt_amount := 0;

    		                ELSE

               		            l_rcpt_amount := l_rcpt_amount - l_xcav_tbl(i).AMOUNT_APPLIED;

			                END IF;


                            IF l_receipt_currency_code <> l_invoice_currency_code THEN
                            -- convert back to receipt currency
                                l_xcav_tbl(i).AMOUNT_APPLIED_FROM := l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
                                l_xcav_tbl(i).TRANS_TO_RECEIPT_RATE := l_conversion_rate;
                            END IF;

		                    l_xcav_tbl(i).INVOICE_CURRENCY_CODE := l_receipt_currency_code;
					        l_xcav_tbl(i).RCA_ID                := l_rca_id;
                            l_xcav_tbl(i).ORG_ID                := l_org_id;
                            l_xcav_tbl(i).TRX_DATE              := c_open_invs_rec.trx_date;
                            l_xcav_tbl(i).CAT_ID                := l_cat_id;

		                    -- i := i + 1;

  				        END LOOP;
				        CLOSE c_open_invs;

                    END LOOP;
			        CLOSE c_stream_alloc;

                    IF l_order_count = 0 THEN

                        -- Message Text: No prorated transaction types for rule.
                        x_return_status := OKC_API.G_RET_STS_ERROR;

                        OKC_API.set_message( p_app_name      => G_APP_NAME
                                            ,p_msg_name      => 'OKL_BPD_DEF_NO_ORD'
                                            );

                        RAISE G_EXCEPTION_HALT_VALIDATION;

                    END IF;

                ELSIF l_under_payment IN ('P','p') THEN -- PRO RATE (3)

			        l_first_prorate_rec := i + 1;

                    -- i := 1;
                    -- obtain all the streams that are part of the pro rate default rule.

                    FOR c_stream_alloc_rec IN c_stream_alloc (l_prorate, l_cat_id, l_contract_number_id)
                    LOOP

				        l_sty_id := c_stream_alloc_rec.sty_id;
    		            FOR c_open_invs_rec IN c_open_invs ( l_cons_bill_num
                                                            ,NULL
                                                            ,l_customer_num
                                                            ,l_sty_id
                                                           )
				        LOOP

                            i := i + 1;

        	                l_xcav_tbl(i).AMOUNT_APPLIED := c_open_invs_rec.amount_due_remaining;

                            IF l_receipt_currency_code <> l_invoice_currency_code THEN
                                -- convert back to receipt currency
                                l_xcav_tbl(i).AMOUNT_APPLIED_FROM := l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
                                l_xcav_tbl(i).TRANS_TO_RECEIPT_RATE := l_conversion_rate;
                            END IF;

  			                l_xcav_tbl(i).INVOICE_NUMBER        := c_open_invs_rec.receivables_invoice_number;
			                l_xcav_tbl(i).LSM_ID                := c_open_invs_rec.stream_id;
			                l_xcav_tbl(i).INVOICE_CURRENCY_CODE := l_receipt_currency_code;
			                l_xcav_tbl(i).RCA_ID                := l_rca_id;
                            l_xcav_tbl(i).ORG_ID                := l_org_id;
                            l_xcav_tbl(i).TRX_DATE              := c_open_invs_rec.trx_date;
                            l_xcav_tbl(i).CAT_ID                := l_cat_id;

  			                l_pro_rate_inv_total                := l_pro_rate_inv_total + l_xcav_tbl(i).AMOUNT_APPLIED;
    		                -- i := i + 1;

                        END LOOP; -- c_open_invs

                    END LOOP; -- c_stream_alloc

			        -- Calc Pro Ration
			        -- only if total amount of prorated invoices is greater than receipt

                    IF l_pro_rate_inv_total IS NULL OR l_pro_rate_inv_total = 0 THEN

                        -- Message Text: No prorated transaction types for contract.
                        x_return_status := OKC_API.G_RET_STS_ERROR;

                        OKC_API.set_message( p_app_name      => G_APP_NAME
                                            ,p_msg_name      => 'OKL_BPD_DEF_NO_PRO'
                                            );

                        RAISE G_EXCEPTION_HALT_VALIDATION;

                    END IF;

   	                IF (l_pro_rate_inv_total > l_rcpt_amount) THEN
	    			    i := l_first_prorate_rec;
		    		    l_temp_val := l_rcpt_amount / l_pro_rate_inv_total;

                        l_rcpt_amount := 0;

    		            LOOP
		                    l_xcav_tbl(i).AMOUNT_APPLIED := l_temp_val * l_xcav_tbl(i).AMOUNT_APPLIED;

                            IF l_receipt_currency_code <> l_invoice_currency_code THEN
                                -- convert back to receipt currency
                                l_xcav_tbl(i).AMOUNT_APPLIED_FROM := l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
                            END IF;

    		                EXIT WHEN (i = l_xcav_tbl.LAST);
			                i := i + 1;
		                END LOOP;

                    ELSE  -- added by BV
                        -- Message Text: No prorated transaction types for contract
                        x_return_status := OKC_API.G_RET_STS_ERROR;

                        OKC_API.set_message( p_app_name      => G_APP_NAME
                                            ,p_msg_name      => 'OKL_BPD_DEF_NO_PRO'
                                            );

                        RAISE G_EXCEPTION_HALT_VALIDATION;

                    END IF;

                ELSIF l_under_payment IN ('U','u') THEN --(3)

                    l_over_pay := 'U';      -- UNAPPLIED

                END IF; -- (3)

	        ELSE -- EXACT or OVERPAYMENT or TOLERANCE  (2)

                 -- CREATE LINES TABLE

                 -- i := 1;

		        OPEN c_open_invs (l_cons_bill_num, NULL, l_customer_num, NULL);

                LOOP

	                FETCH c_open_invs INTO c_open_invs_rec;
                    EXIT WHEN c_open_invs%NOTFOUND OR l_rcpt_amount = 0 OR l_rcpt_amount IS NULL;

                    i := i + 1;

                    l_xcav_tbl(i).INVOICE_NUMBER := c_open_invs_rec.receivables_invoice_number;
	                l_xcav_tbl(i).AMOUNT_APPLIED := c_open_invs_rec.amount_due_remaining;

                    IF l_receipt_currency_code <> l_invoice_currency_code THEN
                        -- convert back to receipt currency
                        l_xcav_tbl(i).AMOUNT_APPLIED_FROM :=
                        l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
                        l_xcav_tbl(i).TRANS_TO_RECEIPT_RATE := l_conversion_rate;
                    END IF;

	                l_xcav_tbl(i).LSM_ID                := c_open_invs_rec.stream_id;
                    l_xcav_tbl(i).INVOICE_CURRENCY_CODE := l_receipt_currency_code;
                    l_xcav_tbl(i).RCA_ID                := l_rca_id;
                    l_xcav_tbl(i).ORG_ID                := l_org_id;
                    l_xcav_tbl(i).TRX_DATE              := c_open_invs_rec.trx_date;
                    l_xcav_tbl(i).CAT_ID                := l_cat_id;


			        IF l_rcpt_amount < l_xcav_tbl(i).AMOUNT_APPLIED THEN
		    		-- TOLERANCE
	    			    l_xcav_tbl(i).AMOUNT_APPLIED := l_rcpt_amount;

	                    l_rcpt_amount := 0;
    	                --i := i + 1;

                    ELSE
			            l_rcpt_amount := l_rcpt_amount - l_xcav_tbl(i).AMOUNT_APPLIED;
				        --i := i + 1;

                    END IF;

                    IF l_receipt_currency_code <> l_invoice_currency_code THEN
                        -- convert back to receipt currency
                        l_xcav_tbl(i).AMOUNT_APPLIED_FROM := l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
                    END IF;

                END LOOP;

                CLOSE c_open_invs;

            END IF; -- under payment.

          END IF;  -- 'On Account' CAR

            --  **********************************************
            --  Stream level cash application processing ENDS
            --  **********************************************

        ELSE

            --  ******************************************************
            --  Per/Contract level cash application processing BEGINS
            --  ******************************************************


            OPEN c_get_contract_num(l_cons_bill_num);
            LOOP

		        FETCH c_get_contract_num INTO l_contract_id, l_contract_num, l_contract_start_date;
		        EXIT WHEN c_get_contract_num%NOTFOUND
                OR l_rcpt_amount = 0
                OR l_rcpt_amount IS NULL;

                IF l_last_contract_id <> l_contract_id THEN

                    l_last_contract_id := l_contract_id;

                    IF l_contract_num IS NOT NULL THEN

                        OPEN c_cash_rle_id_csr (l_contract_id);
                        FETCH c_cash_rle_id_csr INTO l_cau_id;
                        CLOSE c_cash_rle_id_csr;

                     -- don't do cash application if CAR is 'On Account'  -- varao start
                     IF NVL(l_cau_id, 0) = -1 THEN
                        l_over_pay := 'O';   -- Customer's account
                     ELSE                                                 -- varao end

--                      IF l_cau_id IS NOT NULL AND l_same_date = 'N' THEN  -- removed by bv
                        IF l_cau_id IS NOT NULL THEN

                            OPEN c_cash_rule_csr (l_cau_id);
                            FETCH c_cash_rule_csr INTO  l_cat_id
                                                       ,l_rule_name
                                                       ,l_tolerance
                                                       ,l_days_past_quote_valid
		                                               ,l_months_to_bill_ahead
		                                               ,l_under_payment
		                                               ,l_over_payment
		                                               ,l_receipt_msmtch;
                            CLOSE c_cash_rule_csr;

                            IF l_tolerance IS NULL THEN
                                l_rule_name             := l_dflt_name;
                                l_cat_id                := l_dflt_cat_id;
                                l_tolerance             := l_dflt_tolerance;
                                l_days_past_quote_valid := l_dflt_days_past_quote_valid;
		                        l_months_to_bill_ahead  := l_dflt_months_to_bill_ahead;
		                        l_under_payment         := l_dflt_under_payment;
		                        l_over_payment          := l_dflt_over_payment;
		                        l_receipt_msmtch        := l_dflt_receipt_msmtch;
                            END IF;

                        ELSE -- use default rule

                            l_rule_name             := l_dflt_name;
                            l_cat_id                := l_dflt_cat_id;
                            l_tolerance             := l_dflt_tolerance;
                            l_days_past_quote_valid := l_dflt_days_past_quote_valid;
		                    l_months_to_bill_ahead  := l_dflt_months_to_bill_ahead;
		                    l_under_payment         := l_dflt_under_payment;
		                    l_over_payment          := l_dflt_over_payment;
		                    l_receipt_msmtch        := l_dflt_receipt_msmtch;

                        END IF;

                        -- CASH APPLICATION ON CONTRACT PER CONTRACT BASIS --

                        -- get contract total
                        l_cont_tot := 0;
                        FOR c_open_invs_rec IN c_open_invs (l_cons_bill_num, l_contract_num, l_customer_num, NULL)
	                    LOOP
                            l_invoice_currency_code := c_open_invs_rec.currency_code;
                            l_cont_tot := l_cont_tot + c_open_invs_rec.amount_due_remaining;
                            -- changed from remaining to original
	                    END LOOP;

                        -- calculate tolerance
                        IF l_cont_tot > l_rcpt_amount THEN
		                    l_appl_tolerance := l_cont_tot * (1 - l_tolerance / 100);
	                    ELSE
		                    l_appl_tolerance := l_cont_tot;
	                    END IF;

                        --  **************************************************
                        --  Contract level cash application processing begins.
                        --  **************************************************

                        IF l_cont_tot > l_rcpt_amount AND l_appl_tolerance > l_rcpt_amount THEN -- UNDERPAYMENT  (2)

                            IF l_under_payment IN ('T','t') THEN -- ORDERED (3)

                                l_order_count := 0;

			                    OPEN c_stream_alloc (l_ordered, l_cat_id, l_contract_id);
			                    LOOP

				                    FETCH c_stream_alloc INTO l_sty_id, l_sequence_number;
				                    EXIT WHEN c_stream_alloc%NOTFOUND
					                OR l_rcpt_amount = 0
					                OR l_rcpt_amount IS NULL;

				                    OPEN c_open_invs (l_cons_bill_num, l_contract_num, l_customer_num, l_sty_id);
				                    LOOP

	   				                    FETCH c_open_invs INTO c_open_invs_rec;

					                    EXIT WHEN c_open_invs%NOTFOUND OR l_rcpt_amount = 0 OR l_rcpt_amount IS NULL;

                                        i := i + 1;

                                        l_order_count := l_order_count + 1;

					                    l_xcav_tbl(i).INVOICE_NUMBER := c_open_invs_rec.receivables_invoice_number;
					                    l_xcav_tbl(i).AMOUNT_APPLIED := c_open_invs_rec.amount_due_remaining;
                                        l_xcav_tbl(i).LSM_ID         := c_open_invs_rec.stream_id;
                                        l_xcav_tbl(i).TRX_DATE       := c_open_invs_rec.trx_date;
                                        l_xcav_tbl(i).CAT_ID         := l_cat_id;

					                    IF l_xcav_tbl(i).AMOUNT_APPLIED > l_rcpt_amount THEN

						                    l_xcav_tbl(i).AMOUNT_APPLIED := l_rcpt_amount;

                                            l_rcpt_amount := 0;

					                    ELSE

               		                        l_rcpt_amount := l_rcpt_amount - l_xcav_tbl(i).AMOUNT_APPLIED;

					                    END IF;

                                        IF l_receipt_currency_code <> l_invoice_currency_code THEN
                                            -- convert back to receipt currency
                                            l_xcav_tbl(i).AMOUNT_APPLIED_FROM := l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
                                            l_xcav_tbl(i).TRANS_TO_RECEIPT_RATE := l_conversion_rate;
                                        END IF;

					                    l_xcav_tbl(i).INVOICE_CURRENCY_CODE := l_receipt_currency_code;
					                    l_xcav_tbl(i).RCA_ID                := l_rca_id;
                                        l_xcav_tbl(i).ORG_ID                := l_org_id;
                                        l_xcav_tbl(i).TRX_DATE              := c_open_invs_rec.trx_date;
                                        l_xcav_tbl(i).CAT_ID                := l_cat_id;

    				                    -- i := i + 1;

    				                END LOOP;
				                    CLOSE c_open_invs;

			                    END LOOP;
  			                    CLOSE c_stream_alloc;

                                IF l_order_count = 0 THEN

                                    -- Message Text: No prorated transaction types for contract.
                                    x_return_status := OKC_API.G_RET_STS_ERROR;

                                    OKC_API.set_message( p_app_name      => G_APP_NAME
                                                        ,p_msg_name      => 'OKL_BPD_NO_ORDER_STRMS'
                                                        ,p_token1        => 'RULE_NAME'
                                                        ,p_token1_value  => l_rule_name
                                                        ,p_token2        => 'CONTRACT_NUMBER'
                                                        ,p_token2_value  => l_contract_num);

                                    RAISE G_EXCEPTION_HALT_VALIDATION;

                                END IF;

                            ELSIF l_under_payment IN ('P','p') THEN -- PRO RATE (3)

			                    l_first_prorate_rec := i + 1;
                                -- i := 1;

			                    -- obtain all the streams that are part of the pro rate user defined list.

			                    FOR c_stream_alloc_rec IN c_stream_alloc (l_prorate, l_cat_id, l_contract_id)
                                LOOP

				                    l_sty_id := c_stream_alloc_rec.sty_id;

				                    FOR c_open_invs_rec IN c_open_invs ( l_cons_bill_num
                                                                        ,l_contract_num
                                                                        ,l_customer_num
                                                                        ,l_sty_id
                                                                        )
				                    LOOP

                                        i := i + 1;

					                    l_xcav_tbl(i).AMOUNT_APPLIED := c_open_invs_rec.amount_due_remaining;

                                        IF l_receipt_currency_code <> l_invoice_currency_code THEN
                                            -- convert back to receipt currency
                                            l_xcav_tbl(i).AMOUNT_APPLIED_FROM := l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
                                            l_xcav_tbl(i).TRANS_TO_RECEIPT_RATE := l_conversion_rate;
                                        END IF;

					                    l_xcav_tbl(i).INVOICE_NUMBER        := c_open_invs_rec.receivables_invoice_number;
					                    l_xcav_tbl(i).LSM_ID                := c_open_invs_rec.stream_id;
					                    l_xcav_tbl(i).INVOICE_CURRENCY_CODE := l_receipt_currency_code;
					                    l_xcav_tbl(i).RCA_ID                := l_rca_id;
                                        l_xcav_tbl(i).ORG_ID                := l_org_id;
                                        l_xcav_tbl(i).TRX_DATE              := c_open_invs_rec.trx_date;
                                        l_xcav_tbl(i).CAT_ID                := l_cat_id;

					                    l_pro_rate_inv_total                := l_pro_rate_inv_total + l_xcav_tbl(i).AMOUNT_APPLIED;

					                    -- i := i + 1;

				                    END LOOP; -- c_open_invs

			                    END LOOP; -- c_stream_alloc

			                    -- Calc Pro Ration
			                    -- only if total amount of prorated invoices is greater than receipt

                                IF l_pro_rate_inv_total IS NULL OR l_pro_rate_inv_total = 0 THEN

                                    -- Message Text: No prorated transaction types for contract.
                                    x_return_status := OKC_API.G_RET_STS_ERROR;

                                    OKC_API.set_message( p_app_name      => G_APP_NAME
                                                        ,p_msg_name      => 'OKL_BPD_NO_PRORATED_STRMS'
                                                        ,p_token1        => 'RULE_NAME'
                                                        ,p_token1_value  => l_rule_name
                                                        ,p_token2        => 'CONTRACT_NUMBER'
                                                        ,p_token2_value  => l_contract_num);


                                    RAISE G_EXCEPTION_HALT_VALIDATION;

      	                        END IF;

    			                IF (l_pro_rate_inv_total > l_rcpt_amount) THEN
	    			                i := l_first_prorate_rec;
		    		                l_temp_val := l_rcpt_amount / l_pro_rate_inv_total;

                                    l_rcpt_amount := 0;

    				                LOOP
					                    l_xcav_tbl(i).AMOUNT_APPLIED := l_temp_val * l_xcav_tbl(i).AMOUNT_APPLIED;

                                        IF l_receipt_currency_code <> l_invoice_currency_code THEN
                                            -- convert back to receipt currency
                                            l_xcav_tbl(i).AMOUNT_APPLIED_FROM := l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
                                        END IF;

					                    EXIT WHEN (i = l_xcav_tbl.LAST);
					                    i := i + 1;
				                    END LOOP;

                                ELSE  -- added by BV
                                    -- Message Text: No prorated transaction types for contract
                                    x_return_status := OKC_API.G_RET_STS_ERROR;

                                    OKC_API.set_message( p_app_name      => G_APP_NAME
                                                        ,p_msg_name      => 'OKL_BPD_NO_PRORATED_STRMS'
                                                        ,p_token1        => 'RULE_NAME'
                                                        ,p_token1_value  => l_rule_name
                                                        ,p_token2        => 'CONTRACT_NUMBER'
                                                        ,p_token2_value  => l_contract_num);

                                    RAISE G_EXCEPTION_HALT_VALIDATION;

			                    END IF;

		                    ELSIF l_under_payment IN ('U','u') THEN --(3)

                                l_over_pay := 'U';      -- UNAPPLIED

		                    END IF; -- (3)

	                    ELSE -- EXACT or OVERPAYMENT or TOLERANCE  (2)

                            -- CREATE LINES TABLE

    	                    -- i := 1;

		                    OPEN c_open_invs (l_cons_bill_num, l_contract_num, l_customer_num, NULL);

                            LOOP

			                    FETCH c_open_invs INTO c_open_invs_rec;
			                    EXIT WHEN c_open_invs%NOTFOUND OR l_rcpt_amount = 0 OR l_rcpt_amount IS NULL;

                                i := i + 1;

			                    l_xcav_tbl(i).INVOICE_NUMBER := c_open_invs_rec.receivables_invoice_number;
			                    l_xcav_tbl(i).AMOUNT_APPLIED := c_open_invs_rec.amount_due_remaining;

                                IF l_receipt_currency_code <> l_invoice_currency_code THEN
                                    -- convert back to receipt currency
                                    l_xcav_tbl(i).AMOUNT_APPLIED_FROM :=
                                    l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
                                    l_xcav_tbl(i).TRANS_TO_RECEIPT_RATE := l_conversion_rate;
                                END IF;

			                    l_xcav_tbl(i).LSM_ID                := c_open_invs_rec.stream_id;
                                l_xcav_tbl(i).INVOICE_CURRENCY_CODE := l_receipt_currency_code;
			                    l_xcav_tbl(i).RCA_ID                := l_rca_id;
                                l_xcav_tbl(i).ORG_ID                := l_org_id;
                                l_xcav_tbl(i).TRX_DATE              := c_open_invs_rec.trx_date;
                                l_xcav_tbl(i).CAT_ID                := l_cat_id;


			                    IF l_rcpt_amount < l_xcav_tbl(i).AMOUNT_APPLIED THEN
		    		                -- TOLERANCE
	    			                l_xcav_tbl(i).AMOUNT_APPLIED := l_rcpt_amount;

				                    l_rcpt_amount := 0;
				                    --i := i + 1;

			                    ELSE

				                    l_rcpt_amount := l_rcpt_amount - l_xcav_tbl(i).AMOUNT_APPLIED;
				                    --i := i + 1;

			                    END IF;

                                IF l_receipt_currency_code <> l_invoice_currency_code THEN
                                    -- convert back to receipt currency
                                    l_xcav_tbl(i).AMOUNT_APPLIED_FROM := l_xcav_tbl(i).AMOUNT_APPLIED / l_conversion_rate;
                                END IF;

		                    END LOOP;

		                    CLOSE c_open_invs;

                        END IF; -- under payment.

                      END IF;  -- 'On Account' CAR

                      --  ****************************************************
                      --  Per/Contract level cash application processing ENDS
                      --  ****************************************************

                    END IF;

                ELSE

                    NULL;  -- duplicate contract number from cursor ...

                END IF;  -- end

            END LOOP;
            CLOSE c_get_contract_num;

        END IF;

    END IF;  -- for cons bill and contract.

                -- OVERPAYMENT
    IF l_rcpt_amount > 0 THEN -- OVERPAYMENT

        IF l_over_payment IN ('M','m') THEN

            l_over_pay := 'U';  -- UNAPPLIED;
            -- just create money against customer and thats it...

        ELSIF l_over_payment IN ('B','b') THEN

            l_over_pay := 'O';  -- CUSTOMERS ACCOUNT
            -- apply money to customers account...

        ELSIF l_over_payment IN ('F','f') THEN

            -- KICK OFF PROCESS FOR FUTURE AMOUNTS DUE
            l_over_pay := 'O';  -- CUSTOMERS ACCOUNT

        END IF;

    END IF;

	-- CREATE HEADER REC

    -- obtain remittance bank details.
    OPEN c_get_remit_bnk_dtls(l_irm_id);
    FETCH c_get_remit_bnk_dtls INTO
	  	  l_xcrv_rec.REMITTANCE_BANK_NAME
		 ,l_xcrv_rec.ACCOUNT;
    CLOSE c_get_remit_bnk_dtls;

    l_xcrv_rec.RCT_ID		         := l_rct_id;

    IF l_check_number IS NULL THEN
        l_xcrv_rec.CHECK_NUMBER		     := to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS');
    ELSE
        l_xcrv_rec.CHECK_NUMBER		     := l_check_number;
    END IF;

    l_xcrv_rec.RECEIPT_METHOD        := NULL;  -- prefer IRM_ID !
    l_xcrv_rec.RECEIPT_DATE		     := trunc(l_rcpt_date);
    l_xcrv_rec.GL_DATE               := trunc(l_gl_date);
    l_xcrv_rec.CURRENCY_CODE	     := l_invoice_currency_code;
    -- store the functional currency at header lvl


    IF l_receipt_currency_code <> l_functional_currency THEN

        l_xcrv_rec.EXCHANGE_RATE_TYPE   := l_currency_conv_type;
        l_xcrv_rec.EXCHANGE_RATE_DATE   := l_currency_conv_date;
        l_xcrv_rec.ATTRIBUTE1           := l_functional_conversion_rate;
         -- in functional currency ...
    END IF;

    IF l_receipt_currency_code <> l_invoice_currency_code THEN
        l_xcrv_rec.EXCHANGE_RATE        := l_conversion_rate;
        l_xcrv_rec.REMITTANCE_AMOUNT    := l_converted_receipt_amount;
        -- in transaction currency ...
    ELSE
        l_xcrv_rec.REMITTANCE_AMOUNT    := l_rcpt_amount_orig;
        -- in receipt currency ...
    END IF;

    l_xcrv_rec.CUSTOMER_NUMBER	        := l_customer_num;
    l_xcrv_rec.COMMENTS                 := l_comments;
    l_xcrv_rec.ORG_ID                   := l_org_id;

    -- LINES TABLE ALREADY BUILT

    -- BUT WE ALSO WANT TO STORE ALL LINES THAT DID NOT GET ANY MONEY APPLIED ....

    t_xcav_tbl := l_xcav_tbl;

    --- open for a second time without sty_id restriction ...

    IF l_cont_applic = 'Y' AND l_create_receipt_flag NOT IN ('Y','YC') THEN

        OPEN c_open_invs_cont (NULL, l_contract_num, l_customer_num, NULL);
        LOOP

	        FETCH c_open_invs_cont INTO c_open_invs_rec;
            EXIT WHEN c_open_invs_cont%NOTFOUND;

            l_cash_applied_flag := 'N';

            IF t_xcav_tbl.COUNT > 0 THEN  -- varao

              t := t_xcav_tbl.FIRST;

              LOOP

                IF c_open_invs_rec.stream_id = t_xcav_tbl(t).LSM_ID THEN
                    l_cash_applied_flag := 'Y';
                    EXIT;
                END IF;

                EXIT WHEN (t = t_xcav_tbl.LAST);
                t := t + 1;

              END LOOP;

            END IF;

            IF l_cash_applied_flag = 'N' THEN  -- not part of cash application ....

                i := i + 1;

                l_xcav_tbl(i).INVOICE_NUMBER        := c_open_invs_rec.receivables_invoice_number;
		        l_xcav_tbl(i).AMOUNT_APPLIED        := 0;
                l_xcav_tbl(i).LSM_ID                := c_open_invs_rec.stream_id;
                l_xcav_tbl(i).TRX_DATE              := c_open_invs_rec.trx_date;

                l_xcav_tbl(i).INVOICE_CURRENCY_CODE := l_receipt_currency_code;
                l_xcav_tbl(i).RCA_ID                := l_rca_id;
                l_xcav_tbl(i).ORG_ID                := l_org_id;

            END IF;

        END LOOP;
        CLOSE c_open_invs_cont;

    ELSIF l_cons_bill_applic = 'Y' AND l_create_receipt_flag NOT IN ('Y','YC') THEN

        OPEN c_open_invs (l_cons_bill_num, NULL, l_customer_num, NULL);
        LOOP

	        FETCH c_open_invs INTO c_open_invs_rec;
            EXIT WHEN c_open_invs%NOTFOUND;

            l_cash_applied_flag := 'N';

            IF t_xcav_tbl.COUNT > 0 THEN  -- varao

              t := t_xcav_tbl.FIRST;

              LOOP

                IF c_open_invs_rec.stream_id = t_xcav_tbl(t).LSM_ID THEN
                    l_cash_applied_flag := 'Y';
                    EXIT;
                END IF;

                EXIT WHEN (t = t_xcav_tbl.LAST);
                t := t + 1;

              END LOOP;

            END IF;

            IF l_cash_applied_flag = 'N' THEN  -- not part of cash application ....

                i := i + 1;

                l_xcav_tbl(i).INVOICE_NUMBER        := c_open_invs_rec.receivables_invoice_number;
		        l_xcav_tbl(i).AMOUNT_APPLIED        := 0;
                l_xcav_tbl(i).LSM_ID                := c_open_invs_rec.stream_id;
                l_xcav_tbl(i).TRX_DATE              := c_open_invs_rec.trx_date;

                l_xcav_tbl(i).INVOICE_CURRENCY_CODE := l_receipt_currency_code;
                l_xcav_tbl(i).RCA_ID                := l_rca_id;
                l_xcav_tbl(i).ORG_ID                := l_org_id;

            END IF;

        END LOOP;
        CLOSE c_open_invs;

    END IF;
    ---

-- Start of wraper code generated automatically by Debug code generator for Okl_Xcr_Pub.create_ext_ar_txns
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCAPB.pls call Okl_Xcr_Pub.create_ext_ar_txns  ');
    END;
  END IF;

    Okl_Xcr_Pub.create_ext_ar_txns ( l_api_version
	   		                        ,l_init_msg_list
				                    ,l_return_status
				                    ,l_msg_count
			    	                ,l_msg_data
				                    ,l_xcrv_rec
				                    ,l_xcav_tbl
				                    ,x_xcrv_rec
				                    ,x_xcav_tbl
                                   );

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCAPB.pls call Okl_Xcr_Pub.create_ext_ar_txns  ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Xcr_Pub.create_ext_ar_txns

    x_return_status := l_return_status;
    x_msg_data      := l_msg_data;
    x_msg_count     := l_msg_count;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- CREATE RECEIPT IN AR ONCE EVERYTHING IS OKAY AT THIS POINT

    IF l_create_receipt_flag IN ('Y','YC') THEN

        IF l_rctv_rec.IBA_ID IS NULL THEN

            okl_cash_receipt.CASH_RECEIPT (p_api_version      => l_api_version
                                          ,p_init_msg_list    => l_init_msg_list
                                          ,x_return_status    => l_return_status
                                          ,x_msg_count        => l_msg_count
                                          ,x_msg_data         => l_msg_data
                                          ,p_over_pay         => l_over_pay
                                          ,p_conc_proc        => l_conc_proc
                                          ,p_xcrv_rec         => l_xcrv_rec
                                          ,p_xcav_tbl         => l_xcav_tbl
                                          ,x_cash_receipt_id  => l_cash_receipt_id
                                         );

        ELSE


            okl_cash_receipt.PAYMENT_RECEIPT (p_api_version      => l_api_version
                                             ,p_init_msg_list    => l_init_msg_list
                                             ,x_return_status    => l_return_status
                                             ,x_msg_count        => l_msg_count
                                             ,x_msg_data         => l_msg_data
                                             ,p_over_pay         => l_over_pay
                                             ,p_conc_proc        => 'N'
                                             ,p_xcrv_rec         => l_xcrv_rec
                                             ,p_xcav_tbl         => l_xcav_tbl
                                             ,x_cash_receipt_id  => l_cash_receipt_id
                                            );

        END IF;

        x_return_status := l_return_status;

	    IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

            -- Message Text: Error creating receipt in AR
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_BPD_ERR_CRT_RCT_AR');

            RAISE G_EXCEPTION_HALT_VALIDATION;

	    END IF;

        -- UPDATE EXT HEADER WITH CASH RECEIPT ID

        SELECT ID INTO l_xcr_id
        FROM   okl_ext_csh_rcpts_b
        WHERE  rct_id = l_rct_id;

        l_xcrv_rec.id := l_xcr_id;
        l_xcrv_rec.icr_id := l_cash_receipt_id;
        l_xcrv_rec.attribute1   := NULL;

-- Start of wraper code generated automatically by Debug code generator for Okl_Xcr_Pub.update_ext_csh_txns
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCAPB.pls call Okl_Xcr_Pub.update_ext_csh_txns ');
    END;
  END IF;
        Okl_Xcr_Pub.update_ext_csh_txns( p_api_version
                                        ,p_init_msg_list
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data
                                        ,l_xcrv_rec
                                        ,x_xcrv_rec
                                       );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCAPB.pls call Okl_Xcr_Pub.update_ext_csh_txns ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Xcr_Pub.update_ext_csh_txns

        x_return_status := l_return_status;
        x_msg_data      := l_msg_data;
        x_msg_count     := l_msg_count;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;

    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);

    x_return_status := l_return_status;
    x_msg_data      := l_msg_data;
    x_msg_count     := l_msg_count;

EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;


    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

END handle_manual_pay;

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
							      ) IS

  l_currency_code                okl_k_headers_full_v.currency_code%type;
  l_customer_id			         OKL_TRX_CSH_RECEIPT_V.ILE_id%TYPE DEFAULT p_rcpt_rec.customer_id;
  l_customer_num                 HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE DEFAULT p_rcpt_rec.customer_number;
  l_contract_id			         OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL;
  l_currency_conv_type           OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT p_rcpt_rec.exchange_rate_type;
  l_currency_conv_date           OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT p_rcpt_rec.exchange_date;
  l_currency_conv_rate           OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT p_rcpt_rec.exchange_rate;
  l_conversion_rate              GL_DAILY_RATES_V.CONVERSION_RATE%TYPE DEFAULT 0;
  l_functional_conversion_rate   GL_DAILY_RATES_V.CONVERSION_RATE%TYPE DEFAULT 0;
  l_inverse_conversion_rate      GL_DAILY_RATES_V.INVERSE_CONVERSION_RATE%TYPE DEFAULT 0;
  l_functional_currency          OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;
  l_receipt_currency_code        OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT p_rcpt_rec.currency_code;
  l_irm_id			             OKL_TRX_CSH_RECEIPT_V.IRM_ID%TYPE DEFAULT p_rcpt_rec.receipt_method_id;
  l_check_number		         OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT p_rcpt_rec.receipt_number;
  l_rcpt_amount			         OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT p_rcpt_rec.amount;
  l_converted_receipt_amount     OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL;
  l_rcpt_date                    OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT TRUNC(p_rcpt_rec.receipt_date);
  l_gl_date                      OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE DEFAULT p_rcpt_rec.gl_date;
  l_org_id                       OKL_TRX_CSH_RECEIPT_V.ORG_ID%TYPE DEFAULT p_rcpt_rec.org_id;
  l_dup_rcpt_flag                NUMBER DEFAULT NULL;
  l_api_version			         NUMBER := 1.0;
  l_init_msg_list		         VARCHAR2(1) := Okc_Api.g_false;
  l_return_status		         VARCHAR2(1);
  l_msg_count			         NUMBER;
  l_msg_data			         VARCHAR2(2000);
  l_api_name                     CONSTANT VARCHAR2(30) := 'create_manual_receipt';
  l_cash_receipt_id              AR_CASH_RECEIPTS.CASH_RECEIPT_ID%TYPE;


  l_rcpt_rec rcpt_rec_type := p_rcpt_rec;


   -- check for duplicate receipt numbers
   CURSOR   c_dup_rcpt( cp_customer_id IN NUMBER
                       ,cp_check_num IN VARCHAR2
                       ,cp_receipt_date IN DATE
                      ) IS
    SELECT  '1'
    FROM    AR_CASH_RECEIPTS
    WHERE   PAY_FROM_CUSTOMER = cp_customer_id
    AND     receipt_number = cp_check_num
    AND     TRUNC(RECEIPT_DATE) = TRUNC(cp_receipt_date);

BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_functional_currency := okl_accounting_util.get_func_curr_code;

    -- check for mandatory fields

    IF l_customer_id IS NULL OR
	   l_customer_id = OKC_API.G_MISS_NUM OR
       l_receipt_currency_code IS NULL OR
       l_receipt_currency_code = OKC_API.G_MISS_CHAR OR
       l_irm_id IS NULL OR
       l_irm_id = OKC_API.G_MISS_NUM OR
       l_rcpt_date IS NULL OR
       l_rcpt_date = OKC_API.G_MISS_DATE OR
       l_gl_date IS NULL OR
       l_gl_date = OKC_API.G_MISS_DATE OR
       l_org_id IS NULL OR
       l_org_id = OKC_API.G_MISS_NUM OR
       l_rcpt_amount = 0 OR
       l_rcpt_amount = OKC_API.G_MISS_NUM OR
       l_rcpt_amount IS NULL  THEN

       -- Message Text: Please enter all mandatory fields
       x_return_status := OKC_API.G_RET_STS_ERROR;
       OKC_API.set_message( p_app_name    => G_APP_NAME,
                            p_msg_name    =>'OKL_BPD_MISSING_FIELDS');

       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;
    --start code by pgomes on 03/05/2003

    IF l_functional_currency <> l_receipt_currency_code AND
       l_currency_conv_type IN ('NONE') THEN
        -- Message Text: Please enter a currency type.
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_BPD_PLS_ENT_CUR_TYPE');
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF l_functional_currency = l_receipt_currency_code THEN
        IF l_currency_conv_type IN ('CORPORATE', 'SPOT', 'USER') OR
           l_currency_conv_rate <> '0' THEN
            -- Message Text: Currency conversion values are not required when the receipt and invoice currency's are the same.
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_BPD_SAME_CURRENCY');
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    END IF;
    IF l_functional_currency <> l_receipt_currency_code AND
       l_currency_conv_type NOT IN ('USER') THEN
        IF l_currency_conv_date IS NULL OR l_currency_conv_date = '' THEN
            l_currency_conv_date := trunc(l_rcpt_date);
        END IF;
        IF l_currency_conv_type = 'CORPORATE' THEN
            l_currency_conv_type := 'Corporate';
        ELSE
            l_currency_conv_type := 'Spot';
        END IF;

        l_functional_conversion_rate := okl_accounting_util.get_curr_con_rate( l_receipt_currency_code
                                                                              ,l_functional_currency
	                                                                          ,l_currency_conv_date
	                                                                          ,l_currency_conv_type
                                                                              );

        l_inverse_conversion_rate := okl_accounting_util.get_curr_con_rate( l_functional_currency
                                                                           ,l_receipt_currency_code
	                                                                       ,l_currency_conv_date
	                                                                       ,l_currency_conv_type
                                                                          );

        IF l_functional_conversion_rate IN (0,-1) THEN
            --No exchange rate defined
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        l_currency_conv_rate := l_functional_conversion_rate;

    ELSIF l_functional_currency <> l_receipt_currency_code AND
          l_currency_conv_type IN ('USER') THEN
        IF l_currency_conv_rate IS NULL OR l_currency_conv_rate = '0' THEN
            -- Message Text: No exchange rate defined for currency conversion type USER.
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message( p_app_name      => G_APP_NAME,
                                 p_msg_name      => 'OKL_BPD_USR_RTE_SUPPLIED');
            RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
            l_functional_conversion_rate := l_currency_conv_rate;
            l_inverse_conversion_rate := l_functional_conversion_rate / 1;
        END IF;

        l_currency_conv_type := 'User';
        l_currency_conv_date := trunc(SYSDATE);
    ELSE
            -- no currency conversion required
            l_currency_conv_date := NULL;
            l_currency_conv_type := NULL;
            l_currency_conv_rate := NULL;
    END IF;
   	-- Check for exceptions
	IF l_rcpt_amount = 0 OR l_rcpt_amount IS NULL THEN
        -- Message Text: The receipt cannot have a value of zero
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_BPD_ZERO_RECEIPT');
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    OPEN  c_dup_rcpt(l_customer_id, l_check_number, TRUNC(l_rcpt_date));
    FETCH c_dup_rcpt INTO l_dup_rcpt_flag;
    CLOSE c_dup_rcpt;


    IF l_dup_rcpt_flag = 1 THEN
      --Message Text: Duplicate receipt number for customer
      x_return_status := OKC_API.G_RET_STS_ERROR;
      OKC_API.set_message( p_app_name      => G_APP_NAME,
                           p_msg_name      => 'OKL_BPD_DUP_RECEIPT');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    IF l_check_number IS NULL THEN
        l_rcpt_rec.RECEIPT_NUMBER		     := to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS');
    END IF;
    -- store the functional currency at header lvl

    IF l_receipt_currency_code <> l_functional_currency THEN

        l_rcpt_rec.EXCHANGE_RATE_TYPE   := l_currency_conv_type;
        l_rcpt_rec.EXCHANGE_DATE        := l_currency_conv_date;
        l_rcpt_rec.EXCHANGE_RATE        := l_functional_conversion_rate;
         -- in functional currency ...
    END IF;

    okl_cash_receipt.CREATE_RECEIPT(p_api_version      => l_api_version
                                  ,p_init_msg_list    => l_init_msg_list
                                  ,x_return_status    => l_return_status
                                  ,x_msg_count        => l_msg_count
                                  ,x_msg_data         => l_msg_data
                                  ,p_rcpt_rec         => l_rcpt_rec
                                  ,x_cash_receipt_id  => l_cash_receipt_id
                                  );
    x_cash_receipt_id := l_cash_receipt_id;
    x_return_status := l_return_status;

	IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      -- Message Text: Error creating receipt in AR
      x_return_status := OKC_API.G_RET_STS_ERROR;
      OKC_API.set_message( p_app_name      => G_APP_NAME,
                           p_msg_name      => 'OKL_BPD_ERR_CRT_RCT_AR');
      RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

-- Start of wraper code generated automatically by Debug code generator for Okl_Xcr_Pub.update_ext_csh_txns
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCAPB.pls call Okl_Xcr_Pub.update_ext_csh_txns ');
    END;
  END IF;

  okl_api.END_ACTIVITY(x_msg_count, x_msg_data);

  x_msg_data      := l_msg_data;
  x_msg_count     := l_msg_count;

EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;


    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;
END create_manual_receipt;


END Okl_Cash_Appl_Rules;

/
