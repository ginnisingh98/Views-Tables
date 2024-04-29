--------------------------------------------------------
--  DDL for Package Body OKL_PAY_INVOICES_DISB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAY_INVOICES_DISB_PVT" AS
/* $Header: OKLRPIDB.pls 120.22.12010000.2 2009/06/02 10:44:59 racheruv ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator
	-----------------------------------------------------------------
	-- The pulic procedure auto_disbursement calls in a loop of receivable
    -- invoices cursors to private procedure invoice_disbursement which
    -- calls private procedure invoice_insert with or without loop for
    -- non-syndication or syndication type association
    -- For non evergreen passthrough percentage is applied.
    -- For evergreen evergreen fees and passthrough percentage is applied.
    -- The passed amount is disbursed to one or shared among investors.
    -- The recivables headers transaction status get updated as PROCESSED_PAY_S
    -- or PROCESSED_PAY_E even if one line in cursor fails.
    --30/May/02 Print Proccessed consolidate invoice numbers.
	-----------------------------------------------------------------

null_disb_rec                         disb_rec_type;

----------------------------------------------------------------------

PROCEDURE print_line (p_message IN VARCHAR2) IS
BEGIN
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, p_message);
EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '** EXCEPTION IN print_line: '||SQLERRM);
END print_line;

---------------------------------------------------------------------------

FUNCTION get_seq_id RETURN NUMBER IS
 BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
END get_seq_id;

----------------------------------------------------------------------

FUNCTION receipt_amount(p_customer_trx_id IN NUMBER) RETURN NUMBER IS

  l_receipt_amount NUMBER := 0;

  CURSOR l_receipt_amount_csr(cp_customer_trx_id NUMBER) IS
  SELECT NVL(SUM(LINE_APPLIED), 0)
  FROM AR_RECEIVABLE_APPLICATIONS_ALL
  WHERE APPLIED_CUSTOMER_TRX_ID = cp_customer_trx_id
  AND   APPLICATION_TYPE = 'CASH'
  AND   STATUS = 'APP';
BEGIN
  OPEN l_receipt_amount_csr(p_customer_trx_id);
  FETCH l_receipt_amount_csr INTO l_receipt_amount;
  CLOSE l_receipt_amount_csr;

  return NVL(l_receipt_amount, 0);
EXCEPTION
  WHEN OTHERS THEN
    return NVL(l_receipt_amount, 0);
END;

----------------------------------------------------------------------

FUNCTION receipt_date(p_customer_trx_id IN NUMBER) RETURN DATE IS

  l_receipt_date DATE := sysdate;

  CURSOR l_receipt_date_csr(cp_customer_trx_id NUMBER) IS
  SELECT MAX(apply_date)
  FROM AR_RECEIVABLE_APPLICATIONS_ALL
  WHERE APPLIED_CUSTOMER_TRX_ID = cp_customer_trx_id
  AND   APPLICATION_TYPE = 'CASH'
  AND   STATUS = 'APP';
BEGIN
  OPEN l_receipt_date_csr(p_customer_trx_id);
  FETCH l_receipt_date_csr INTO l_receipt_date;
  CLOSE l_receipt_date_csr;

  return TRUNC(l_receipt_date);
EXCEPTION
  WHEN OTHERS THEN
    return TRUNC(l_receipt_date);
END;

----------------------------------------------------------------------

FUNCTION partial_receipt_amount(p_customer_trx_id IN NUMBER) RETURN NUMBER IS

  l_receipt_amount NUMBER := 0;

  --rkuttiya R12 B Billing Architecture modified the following cursor
  CURSOR l_receipt_amount_csr(cp_customer_trx_id NUMBER) IS
  SELECT NVL(SUM(LINE_APPLIED), 0)
  FROM AR_RECEIVABLE_APPLICATIONS_ALL RAA
       ,OKL_BPD_TLD_AR_LINES_V ARL
  WHERE RAA.APPLIED_CUSTOMER_TRX_ID = cp_customer_trx_id
  AND   RAA.APPLICATION_TYPE = 'CASH'
  AND   RAA.STATUS = 'APP'
  AND   RAA.applied_customer_trx_id = arl.customer_trx_id
  AND   NOT EXISTS (SELECT 1 FROM OKL_INVESTOR_PAYOUT_SUMMARY_B PAY
                    WHERE PAY.INVESTOR_AGREEMENT_ID IS NULL
                    AND PAY.TLD_ID = ARL.TLD_ID
                    AND PAY.RECEIVABLE_APPLICATION_ID = RAA.RECEIVABLE_APPLICATION_ID);
BEGIN
  OPEN l_receipt_amount_csr(p_customer_trx_id);
  FETCH l_receipt_amount_csr INTO l_receipt_amount;
  CLOSE l_receipt_amount_csr;

  return NVL(l_receipt_amount, 0);
EXCEPTION
  WHEN OTHERS THEN
    return NVL(l_receipt_amount, 0);
END;

----------------------------------------------------------------------

FUNCTION partial_receipt_date(p_customer_trx_id IN NUMBER) RETURN DATE IS

  l_receipt_date DATE := SYSDATE;

  --rkuttiya R12 B Billing modified following cursor
  CURSOR l_receipt_date_csr(cp_customer_trx_id NUMBER) IS
  SELECT MAX(raa.apply_date)
  FROM AR_RECEIVABLE_APPLICATIONS_ALL RAA
       ,OKL_BPD_TLD_AR_LINES_V ARL
  WHERE RAA.APPLIED_CUSTOMER_TRX_ID = cp_customer_trx_id
  AND   RAA.APPLICATION_TYPE = 'CASH'
  AND   RAA.STATUS = 'APP'
  AND   RAA.applied_customer_trx_id = arl.customer_trx_id
  AND   NOT EXISTS (SELECT 1 FROM OKL_INVESTOR_PAYOUT_SUMMARY_B PAY
                    WHERE PAY.INVESTOR_AGREEMENT_ID IS NULL
                    AND PAY.TLD_ID = ARL.TLD_ID
                    AND PAY.RECEIVABLE_APPLICATION_ID = RAA.RECEIVABLE_APPLICATION_ID);
BEGIN
  OPEN l_receipt_date_csr(p_customer_trx_id);
  FETCH l_receipt_date_csr INTO l_receipt_date;
  CLOSE l_receipt_date_csr;

  return TRUNC(l_receipt_date);
EXCEPTION
  WHEN OTHERS THEN
    return TRUNC(l_receipt_date);
END;

----------------------------------------------------------------------

FUNCTION get_next_pymt_date(p_start_date IN Date
                           ,p_frequency IN VARCHAR2
                  	   ,p_offset_date IN DATE) RETURN DATE
AS
  --l_next_date DATE := to_date(to_char(p_start_date, 'MM/DD') || to_char(p_offset_date, 'RRRR'), 'MM/DD/RRRR');
  l_next_date DATE := p_start_date;
  l_mnth_adder NUMBER := 0;
BEGIN
  if(UPPER(p_frequency) = 'A') then
    l_mnth_adder := 12;
  elsif(UPPER(p_frequency) = 'Q') then
    l_mnth_adder := 3;
  elsif(UPPER(p_frequency) = 'M') then
    l_mnth_adder := 1;
  else
    return null;
  end if;

  loop
    exit when l_next_date >= p_offset_date;
    --select add_months(l_next_date, l_mnth_adder) INTO l_next_date from dual;
    l_next_date := add_months(l_next_date, l_mnth_adder);
  end loop;
return l_next_date;
EXCEPTION
  WHEN others THEN
    print_line ( '** EXCEPTION IN get_next_pymt_date: '||SQLERRM);
    return null;
END get_next_pymt_date;

----------------------------------------------------------------------

FUNCTION get_kle_party_pmt_hdr(p_khr_id IN NUMBER
                              ,p_kle_id IN Number
                              ,p_lyt_code IN VARCHAR2
                              ,p_term IN VARCHAR2) RETURN NUMBER IS

  CURSOR l_pph_csr(cp_khr_id NUMBER, cp_kle_id NUMBER, cp_term VARCHAR2) IS
  SELECT id FROM
  OKL_PARTY_PAYMENT_HDR
  WHERE dnz_chr_id = cp_khr_id
  AND   NVL(cle_id, -99) = cp_kle_id
  AND   passthru_term = cp_term;

  l_party_pmt_hdr_id NUMBER:= NULL;
BEGIN
  OPEN l_pph_csr(p_khr_id, p_kle_id, p_term);
  FETCH l_pph_csr INTO l_party_pmt_hdr_id;
  CLOSE l_pph_csr;

  --for an asset line, if evergreen passthru parameters are not defined at the line level,
  --then check to see if they are defined at the contract level
  IF (l_party_pmt_hdr_id IS NULL AND p_lyt_code = 'FREE_FORM1') THEN
    OPEN l_pph_csr(p_khr_id, -99, p_term);
    FETCH l_pph_csr INTO l_party_pmt_hdr_id;
    CLOSE l_pph_csr;
  END IF;

  return l_party_pmt_hdr_id;
EXCEPTION
  WHEN OTHERS THEN
    return l_party_pmt_hdr_id;
END;

----------------------------------------------------------------------

PROCEDURE invoice_insert (
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    p_receivables_invoice_id  IN    NUMBER,
    p_tapv_rec      IN okl_tap_pvt.tapv_rec_type,
    p_tplv_rec      IN okl_tpl_pvt.tplv_rec_type,
    x_tapv_rec      OUT NOCOPY okl_tap_pvt.tapv_rec_type)
IS

    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_name	    CONSTANT VARCHAR2(30)   := 'INVOICE_INSERT';
    l_okl_application_id NUMBER(3) := 540;
    l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';
    lX_dbseqnm          VARCHAR2(2000):= '';
    lX_dbseqid          NUMBER(38):= NULL;
    ------------------------------------------------------------
    -- Declare records: Payable Invoice Headers, Lines and Distributions
    ------------------------------------------------------------
    l_tapv_rec              Okl_tap_pvt.tapv_rec_type;
    lx_tapv_rec             Okl_tap_pvt.tapv_rec_type;
    l_tplv_rec              okl_tpl_pvt.tplv_rec_type;
    lx_tplv_rec             okl_tpl_pvt.tplv_rec_type;

--start:|  18-May-07    cklee   -- Accounting API CR, Disbursement Central API uptake |
    l_tplv_tbl              okl_tpl_pvt.tplv_tbl_type;
    lx_tplv_tbl             okl_tpl_pvt.tplv_tbl_type;
--end:|  18-May-07    cklee   -- Accounting API CR, Disbursement Central API uptake |

    l_tmpl_identify_rec     Okl_Account_Dist_Pvt.TMPL_IDENTIFY_REC_TYPE;
    l_dist_info_rec         Okl_Account_Dist_Pvt.dist_info_REC_TYPE;
    l_ctxt_val_tbl          okl_execute_formula_pvt.ctxt_val_tbl_type;
    l_acc_gen_primary_key_tbl  Okl_Account_Generator_Pvt.primary_key_tbl;
    lu_tapv_rec              Okl_tap_pvt.tapv_rec_type;
    lux_tapv_rec             Okl_tap_pvt.tapv_rec_type;

    l_template_tbl         	Okl_Account_Dist_Pub.AVLV_TBL_TYPE;
  	l_amount_tbl         	Okl_Account_Dist_Pub.AMOUNT_TBL_TYPE;
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    CURSOR pdt_id_csr ( p_khr_id NUMBER ) IS
		   SELECT  khr.pdt_id
		   FROM    okl_k_headers khr
		   WHERE   khr.id =  p_khr_id;

    -- SUBTYPE khr_id_type IS okc_k_headers_b.id%type;
    l_khr_id okc_k_headers_b.id%type;
    l_currency_code okc_k_headers_b.currency_code%type;
    l_currency_conversion_type okl_k_headers.currency_conversion_type%type;
    l_currency_conversion_rate okl_k_headers.currency_conversion_rate%type;
    l_currency_conversion_date okl_k_headers.currency_conversion_date%type;

    --Get currency conversion attributes for a contract
    CURSOR l_curr_conv_csr(cp_khr_id IN okc_k_headers_b.id%TYPE) IS
    SELECT  currency_code
           ,currency_conversion_type
           ,currency_conversion_rate
           ,currency_conversion_date
    FROM    okl_k_headers_full_v
    WHERE   id = cp_khr_id;

    --End code added by pgomes on 02/12/2003

  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

BEGIN
   l_return_status := okl_api.start_activity(
    	p_api_name	=> l_api_name,
    	p_init_msg_list	=> p_init_msg_list,
    	p_api_type	=> '_PVT',
    	x_return_status	=> l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    		  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    		  RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   x_return_status := OKL_API.G_RET_STS_SUCCESS;
   print_line ( '******** IN PROCEDURE INVOICE_INSERT ********');
   ------------------------------------------------------------
   -- Initialization of Parmaeters
   ------------------------------------------------------------
   l_tapv_rec := p_tapv_rec;
   l_tplv_rec := p_tplv_rec;

   ------------------------------------------------------------
   -- Derive Invoice Number: l_tapv_rec.Invoice_Number
   ------------------------------------------------------------
--start:|  18-May-07    cklee   -- Accounting API CR, Disbursement Central API uptake |
/*
   print_line ( '      -- Generating Invoice Number....');
   l_tapv_rec.Invoice_Number := fnd_seqnum.get_next_sequence
                (appid      =>  l_okl_application_id,
                cat_code    =>  l_document_category,
                sobid       =>  P_tapv_rec.set_of_books_id,
                met_code    =>  'A',
                trx_date    =>  SYSDATE,
                dbseqnm     =>  lx_dbseqnm,
                dbseqid     =>  lx_dbseqid);
   l_tapv_rec.invoice_category_code := NULL;
   l_tapv_rec.vendor_invoice_number := l_tapv_rec.Invoice_Number;

   print_line ( '      -- Generated Invoice Number is: '||l_tapv_rec.Invoice_Number);

    l_tapv_rec.date_gl := l_tapv_rec.date_invoiced;

    print_line ( '      -- Invoice Date is: '||l_tapv_rec.date_invoiced ||' and GL Date is: '||l_tapv_rec.date_gl);

    print_line ( '      -- Creating Header Record.');
	------------------------------------------------------------
	--  Insert Invoice Headers
	------------------------------------------------------------

    --Start code added by pgomes on 02/12/2003
    --get contract currency parameters
    --l_khr_id := p_tapv_rec.khr_id ;
    l_khr_id := p_tplv_rec.khr_id ;

    l_currency_code := null;
    l_currency_conversion_type := null;
    l_currency_conversion_rate := null;
    l_currency_conversion_date := null;

    FOR cur IN l_curr_conv_csr(l_khr_id) LOOP
         l_currency_code := cur.currency_code;
         l_currency_conversion_type := cur.currency_conversion_type;
         l_currency_conversion_rate := cur.currency_conversion_rate;
         l_currency_conversion_date := cur.currency_conversion_date;
    END LOOP;
    --End code added by pgomes on 02/12/2003

    -- sjalasut, nullified l_tapv_rec.khr_id as part of OKLR12B disbursements proeject
    l_tapv_rec.khr_id := NULL;

    -- Start of wraper code generated automatically by Debug code generator for Okl_Trx_Ap_Invoices_Pub.insert_trx_ap_invoices
    IF(L_DEBUG_ENABLED='Y') THEN
      L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
      IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
    END IF;
    IF(IS_DEBUG_PROCEDURE_ON) THEN
      BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPIDB.pls call Okl_Trx_Ap_Invoices_Pub.insert_trx_ap_invoices ');
      END;
    END IF;

    --Start code added by pgomes on 02/12/2003

    --Check for currency code
    IF (NVL(l_tapv_rec.currency_code, okl_api.g_miss_char) = okl_api.g_miss_char) THEN
      l_tapv_rec.currency_code := l_currency_code;
    END IF;

    --Check for currency conversion type
    IF (NVL(l_tapv_rec.currency_conversion_type, okl_api.g_miss_char) = okl_api.g_miss_char) THEN
      l_tapv_rec.currency_conversion_type := l_currency_conversion_type;
    END IF;

    --Check for currency conversion date
    IF (NVL(l_tapv_rec.currency_conversion_date, okl_api.g_miss_date) =  okl_api.g_miss_date) THEN
      l_tapv_rec.currency_conversion_date := l_currency_conversion_date;
    END IF;


    --Uncommented the below block of code to handle currency conversion rate
    IF (l_tapv_rec.currency_conversion_type = 'User') THEN
      IF (l_tapv_rec.currency_code = okl_accounting_util.get_func_curr_code) THEN
        l_tapv_rec.currency_conversion_rate := 1;
      ELSE
        IF (NVL(l_tapv_rec.currency_conversion_rate, okl_api.g_miss_num) = okl_api.g_miss_num) THEN
          l_tapv_rec.currency_conversion_rate := l_currency_conversion_rate;
        END IF;
      END IF;
    --pgomes 02/12/2003 added below code to get curr conv rate
    --
    ELSIF (l_tapv_rec.currency_conversion_type = 'Spot' OR l_tapv_rec.currency_conversion_type = 'Corporate') THEN
      l_tapv_rec.currency_conversion_rate := okl_accounting_util.get_curr_con_rate
                                                (p_from_curr_code => l_tapv_rec.currency_code,
	                                         p_to_curr_code => okl_accounting_util.get_func_curr_code,
	                                         p_con_date => l_tapv_rec.currency_conversion_date,
	                                         p_con_type => l_tapv_rec.currency_conversion_type);
--
    END IF;


    --End code added by pgomes on 02/12/2003

       l_tapv_rec.amount := OKL_ACCOUNTING_UTIL.round_amount(l_tapv_rec.amount, l_tapv_rec.currency_code);
       l_tplv_rec.amount := OKL_ACCOUNTING_UTIL.round_amount(l_tplv_rec.amount, l_tapv_rec.currency_code);

        Okl_Trx_Ap_Invoices_Pub.insert_trx_ap_invoices(
            p_api_version       =>   p_api_version
            ,p_init_msg_list    =>   p_init_msg_list
            ,x_return_status    =>   x_return_status
            ,x_msg_count        =>   x_msg_count
            ,x_msg_data         =>   x_msg_data
            ,p_tapv_rec         =>   l_tapv_rec
            ,x_tapv_rec         =>   lx_tapv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPIDB.pls call Okl_Trx_Ap_Invoices_Pub.insert_trx_ap_invoices ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Trx_Ap_Invoices_Pub.insert_trx_ap_invoices

	IF ( x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
	    print_line ( '      -- Created Header Record with Id '||lx_tapv_rec.id);
        lu_tapv_rec := lx_tapv_rec;
	ELSE
	    print_line ( '*=> ERROR : Creating Header.');
	END IF;

	------------------------------------------------------------
	-- Insert Invoice Line
	------------------------------------------------------------
        l_tplv_rec.tap_id := lx_tapv_rec.id;

	print_line ( '      -- Creating Line Record.');

-- Start of wraper code generated automatically by Debug code generator for OKL_TXL_AP_INV_LNS_PUB.insert_txl_ap_inv_lns
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPIDB.pls call OKL_TXL_AP_INV_LNS_PUB.insert_txl_ap_inv_lns ');
    END;
  END IF;
	OKL_TXL_AP_INV_LNS_PUB.insert_txl_ap_inv_lns(
            p_api_version       =>   p_api_version
            ,p_init_msg_list    =>  p_init_msg_list
            ,x_return_status    =>   x_return_status
            ,x_msg_count        =>   x_msg_count
            ,x_msg_data         =>   x_msg_data
            ,p_tplv_rec         =>   l_tplv_rec
            ,x_tplv_rec         =>   lx_tplv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPIDB.pls call OKL_TXL_AP_INV_LNS_PUB.insert_txl_ap_inv_lns ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TXL_AP_INV_LNS_PUB.insert_txl_ap_inv_lns

	IF ( x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
	    print_line ( '      -- Created Line Record with Id '||lx_tplv_rec.id);
	ELSE
	    print_line ( '*=> ERROR : Creating Line.');
	END IF;

	------------------------------------------------------------
	-- Derive and Insert Distribution Line
	------------------------------------------------------------

	print_line ( '      -- Creating Distributions. Supplied parameters:');


------------------ Accounting Engine Calls --------------------------
	l_tmpl_identify_rec.product_id := NULL;

	-- Get Product Id
	OPEN  pdt_id_csr ( l_khr_id );
	FETCH pdt_id_csr INTO l_tmpl_identify_rec.product_id;
	CLOSE pdt_id_csr;

	l_tmpl_identify_rec.transaction_type_id    := P_tapv_rec.try_id;
	l_tmpl_identify_rec.stream_type_id         := p_tplv_rec.sty_id;

	l_tmpl_identify_rec.ADVANCE_ARREARS        := NULL;
	l_tmpl_identify_rec.FACTORING_SYND_FLAG    := NULL;
	l_tmpl_identify_rec.SYNDICATION_CODE       := NULL;
	--l_tmpl_identify_rec.FACTORING_CODE         := NULL;
	l_tmpl_identify_rec.MEMO_YN                := 'N';
	l_tmpl_identify_rec.PRIOR_YEAR_YN          := 'N';

  Okl_Securitization_Pvt.check_khr_ia_associated(p_api_version => p_api_version
                                                ,p_init_msg_list => p_init_msg_list
                                                ,x_return_status => x_return_status
                                                ,x_msg_count => x_msg_count
                                                ,x_msg_data => x_msg_data
                                                ,p_khr_id =>  l_khr_id
                                                ,p_scs_code => NULL
                                                ,p_trx_date => p_tapv_rec.date_invoiced
                                                ,x_fact_synd_code => l_tmpl_identify_rec.FACTORING_SYND_FLAG
                                                ,x_inv_acct_code => l_tmpl_identify_rec.INVESTOR_CODE);

	IF ( x_return_status = okl_api.g_ret_sts_success) THEN
	    print_line ( '      -- Okl_Securitization_Pvt.check_khr_ia_associated called successfully  ');
	ELSE
	    print_line ( '*=> ERROR : Calling Okl_Securitization_Pvt.check_khr_ia_associated.');
	END IF;


	l_dist_info_rec.source_id		    	   := lx_tplv_rec.id;
	l_dist_info_rec.source_table			   := 'OKL_TXL_AP_INV_LNS_B';
	l_dist_info_rec.accounting_date			   := l_tapv_rec.date_invoiced;
	l_dist_info_rec.gl_reversal_flag		   :='N';
	l_dist_info_rec.post_to_gl				   :='N';
	l_dist_info_rec.amount					   := ABS(p_tapv_rec.amount);
	l_dist_info_rec.currency_code			   := p_tapv_rec.currency_code;
	l_dist_info_rec.contract_id				   := l_khr_id;
	l_dist_info_rec.contract_line_id     	   := p_tplv_rec.kle_id;

    --Start code added by pgomes on 02/12/2003

    --Check for currency code
    l_dist_info_rec.currency_code := l_tapv_rec.currency_code;

    IF (NVL(l_dist_info_rec.currency_code, okl_api.g_miss_char) = okl_api.g_miss_char) IS NULL THEN
      l_dist_info_rec.currency_code := l_currency_code;
    END IF;

    --Check for currency conversion type
    l_dist_info_rec.currency_conversion_type := l_tapv_rec.currency_conversion_type;

    IF (NVL(l_dist_info_rec.currency_conversion_type, okl_api.g_miss_char) = okl_api.g_miss_char) THEN
      l_dist_info_rec.currency_conversion_type := l_currency_conversion_type;
    END IF;


    --Check for currency conversion date
    l_dist_info_rec.currency_conversion_date := l_tapv_rec.currency_conversion_date;

    IF (NVL(l_dist_info_rec.currency_conversion_date, okl_api.g_miss_date) =  okl_api.g_miss_date) THEN
      l_dist_info_rec.currency_conversion_date := l_currency_conversion_date;
    END IF;


    --Uncommented the below block of code to handle currency conversion rate
    IF (l_dist_info_rec.currency_conversion_type = 'User') THEN
      IF (l_dist_info_rec.currency_code = okl_accounting_util.get_func_curr_code) THEN
        l_dist_info_rec.currency_conversion_rate := 1;
      ELSE
        IF (NVL(l_tapv_rec.currency_conversion_rate, okl_api.g_miss_num) = okl_api.g_miss_num) THEN
          l_dist_info_rec.currency_conversion_rate := l_currency_conversion_rate;
        ELSE
          l_dist_info_rec.currency_conversion_rate := l_tapv_rec.currency_conversion_rate;
        END IF;
      END IF;
    --pgomes 02/12/2003 added below code to get curr conv rate
    ELSIF (l_dist_info_rec.currency_conversion_type = 'Spot' OR l_dist_info_rec.currency_conversion_type = 'Corporate') THEN
      l_dist_info_rec.currency_conversion_rate := okl_accounting_util.get_curr_con_rate
                                                (p_from_curr_code => l_dist_info_rec.currency_code,
	                                         p_to_curr_code => okl_accounting_util.get_func_curr_code,
	                                         p_con_date => l_dist_info_rec.currency_conversion_date,
	                                         p_con_type => l_dist_info_rec.currency_conversion_type);
    END IF;

    --pgomes 02/12/2003 added below code to default rate so that acct dist are created
    l_dist_info_rec.currency_conversion_rate := NVL(l_dist_info_rec.currency_conversion_rate, 1);

    --End code added by pgomes on 02/12/2003

-- Start of wraper code generated automatically by Debug code generator for Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPIDB.pls call Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen  ');
    END;
  END IF;
    Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen (
	p_contract_id	     => l_khr_id,
	p_contract_line_id	 => p_tplv_rec.kle_id,
	x_acc_gen_tbl		 => l_acc_gen_primary_key_tbl,
	x_return_status		 => x_return_status);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPIDB.pls call Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen  ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen

	IF ( x_return_status = okl_api.g_ret_sts_success) THEN
	    print_line ( '      -- Accounting engine called successfully  ');
	ELSE
	    print_line ( '*=> ERROR : Calling Accounting engine.');
	END IF;


    --dbms_output.PUT_LINE ('    --conversion type passed for distr creation  =>' || l_dist_info_rec.currency_conversion_type);
-- Start of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPIDB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
    Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST(
								   p_api_version             => p_api_version
                                  ,p_init_msg_list  		 => p_init_msg_list
                                  ,x_return_status  		 => x_return_status
                                  ,x_msg_count      		 => x_msg_count
                                  ,x_msg_data       		 => x_msg_data
                                  ,p_tmpl_identify_rec 		 => l_tmpl_identify_rec
                                  ,p_dist_info_rec           => l_dist_info_rec
                                  ,p_ctxt_val_tbl            => l_ctxt_val_tbl
                                  ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl
                                  ,x_template_tbl            => l_template_tbl
                                  ,x_amount_tbl              => l_amount_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPIDB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST

    IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
       	 --RAISE G_EXCEPTION_HALT_VALIDATION;
           	  print_line ( '*=> ERROR: Accounting distributions not created.');

        --l_return_status := x_return_status;
        lu_tapv_rec.TRX_STATUS_CODE := 'ERROR';

        UPDATE Okl_Trx_Ap_Invoices_B
        SET TRX_STATUS_CODE = 'ERROR'
        WHERE id = lx_tapv_rec.id;

	    IF ( x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
	      print_line ( '      -- Updated Header Record with Id '||lx_tapv_rec.id || ' with ERROR Status');
        ELSE
 	      print_line ( '*=> ERROR : Updating Header with ERROR Status.');
	    END IF;
        --x_return_status := l_return_status;
    END IF;
------------------End Accounting Engine Calls -----------------------
--	l_dist_info_rec.contract_line_id     := p_tplv_rec.kle_id;

  x_tapv_rec := lx_tapv_rec;

	print_line ( '      -- KLE_ID: '||p_tplv_rec.kle_id);
	print_line ( '      -- PDT_ID: '||l_tmpl_identify_rec.product_id);
	print_line ( '      -- Amount: '||p_tapv_rec.amount);
	print_line ( '      -- Currency: '||p_tapv_rec.currency_code);
	print_line ( '      -- KHR_ID: '||l_khr_id);
*/
      /* cklee 18-May-07
         Call to the common Disbursement API
         start changes */
    IF(L_DEBUG_ENABLED='Y') THEN
      L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
      IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
    END IF;

    IF(IS_DEBUG_PROCEDURE_ON) THEN
      BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Before create disbursement transaction, ap invoice header id : ' || lx_tapv_rec.id);
      END;
    END IF;
    -- Add tpl_rec to table
    l_tplv_tbl(1) := l_tplv_rec;

    --Call the commong disbursement API to create transactions
    Okl_Create_Disb_Trans_Pvt.create_disb_trx(
             p_api_version      =>   p_api_version
            ,p_init_msg_list    =>   p_init_msg_list
            ,x_return_status    =>   x_return_status
            ,x_msg_count        =>   x_msg_count
            ,x_msg_data         =>   x_msg_data
            ,p_tapv_rec         =>   l_tapv_rec
            ,p_tplv_tbl         =>   l_tplv_tbl
            ,x_tapv_rec         =>   lx_tapv_rec
            ,x_tplv_tbl         =>   lx_tplv_tbl);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    IF(IS_DEBUG_PROCEDURE_ON) THEN
      BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'after create disbursement transaction, ap invoice header id : ' || lx_tapv_rec.id);
      END;
    END IF;
    /* cklee end changes */

--end:|  18-May-07    cklee   -- Accounting API CR, Disbursement Central API uptake |

print_line ( '******** EXITING PROCEDURE INVOICE_INSERT ********');

okl_api.end_activity(x_msg_count => x_msg_count
                      ,x_msg_data => x_msg_data);
EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
  	  print_line ( '*=> ERROR: '||SQLERRM);
      Okl_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

	WHEN OTHERS THEN
		print_line ( '*=> ERROR: '||SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END invoice_insert;

PROCEDURE invoice_disbursement (
    p_api_version   IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    p_disb_rec      IN disb_rec_type)

IS

    ----------------------------------------------------------------
    -- Declare passthru party payment details Cursor
    -----------------------------------------------------------------
    CURSOR c_vendor_dtls(cp_pph_id NUMBER) IS
         SELECT ppd.vendor_id,
                ppd.pay_site_id,
                NVL(ppd.payment_term_id, pvs.terms_id) payment_term_id,
                NVL(ppd.payment_method_code, pvs.payment_method_lookup_code) payment_method_code,
                NVL(ppd.pay_group_code, pvs.pay_group_lookup_code) pay_group_code,
                ppd.payment_basis,
                TRUNC(NVL(ppd.payment_start_date, khr.start_date)) payment_start_date,
                ppd.payment_frequency,
                NVL(ppd.remit_days, 0) remit_days,
                ppd.disbursement_basis,
                ppd.disbursement_fixed_amount,
                ppd.disbursement_percent,
                ppd.processing_fee_basis,
                ppd.processing_fee_fixed_amount,
                ppd.processing_fee_percent
                --ppd.processing_fee_formula
         FROM okl_party_payment_hdr pph,
              okl_party_payment_dtls ppd,
              okc_k_headers_b khr,
              po_vendor_sites pvs
         WHERE pph.id = cp_pph_id
         AND pph.id = ppd.payment_hdr_id
         AND pph.dnz_chr_id = khr.id
         AND ppd.pay_site_id = pvs.vendor_site_id;

    -- Inner declare # 1
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_name	    CONSTANT VARCHAR2(30)   := 'INVOICE_DISBURSEMENT';

    l_amount_pass       NUMBER := 0;
    l_process_fee       NUMBER := 0;
    l_invoice_date      DATE := SYSDATE;

    ------------------------------------------------------------
    -- Declare records: Payable Invoice Headers, Lines and Distributions
    ------------------------------------------------------------
    l_tapv_rec          Okl_tap_pvt.tapv_rec_type;
    l_tplv_rec          okl_tpl_pvt.tplv_rec_type;
    l_tapv_rec_null     Okl_tap_pvt.tapv_rec_type;
    l_tplv_rec_null     okl_tpl_pvt.tplv_rec_type;
    lx_tapv_rec         Okl_tap_pvt.tapv_rec_type;
    l_disb_rec          disb_rec_type;

    -- Cursor to get the AR invoice Numbers for log file
    CURSOR ar_inv_csr ( p_receivables_invoice_id  NUMBER ) IS
    SELECT trx_number
    FROM   ra_customer_trx_all
    WHERE CUSTOMER_TRX_ID = p_receivables_invoice_id;

    --cursor to get the receipt applications applied to a invoice
    CURSOR l_receipt_applic_csr(cp_customer_trx_id NUMBER) IS
    SELECT RAA.receivable_application_id
          ,RAA.LINE_APPLIED
          ,RAA.apply_date
          ,ARL.tld_id tld_id
    FROM AR_RECEIVABLE_APPLICATIONS_ALL RAA
         ,OKL_BPD_TLD_AR_LINES_V ARL
    WHERE RAA.APPLIED_CUSTOMER_TRX_ID = cp_customer_trx_id
    AND   RAA.APPLICATION_TYPE = 'CASH'
    AND   RAA.STATUS = 'APP'
    AND   RAA.applied_customer_trx_id = arl.customer_trx_id
    AND   NOT EXISTS (SELECT 1 FROM OKL_INVESTOR_PAYOUT_SUMMARY_B PAY
                      WHERE PAY.INVESTOR_AGREEMENT_ID IS NULL
                      AND PAY.TLD_ID = ARL.TLD_ID
                      AND PAY.RECEIVABLE_APPLICATION_ID = RAA.RECEIVABLE_APPLICATION_ID);


    --Local Variables
    l_ar_inv_number    ra_customer_trx_all.trx_number%TYPE;
    l_try_id        okl_trx_ap_invoices_b.try_id%TYPE;
    l_overall_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;

    TYPE tap_id_tbl_type IS TABLE OF okl_trx_ap_invoices_b.id%type
        INDEX BY BINARY_INTEGER;

    l_tap_id_tbl tap_id_tbl_type;
    id_ind NUMBER;
    l_idh_id              NUMBER;

    l_lsm_rcpt_tbl lsm_rcpt_tbl_type;
    lsm_rcpt_id_ind NUMBER;
BEGIN

l_return_status := okl_api.start_activity(
	p_api_name	=> l_api_name,
	p_init_msg_list	=> p_init_msg_list,
	p_api_type	=> '_PVT',
	x_return_status	=> l_return_status);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

x_return_status := OKL_API.G_RET_STS_SUCCESS;
l_overall_status := x_return_status;
print_line ( '******** IN PROCEDURE INVOICE_DISBURSEMENT ********');

	------------------------------------------------------------
	-- Derive Transaction Type
	------------------------------------------------------------
	BEGIN
		SELECT id INTO l_try_id
		FROM okl_trx_types_tl
		WHERE name = 'Disbursement'
		AND LANGUAGE= 'US' ;
	EXCEPTION
 	  WHEN OTHERS THEN
		print_line ( '*=> ERROR: while deriving transaction type '||SQLERRM);
	END;

l_disb_rec := p_disb_rec;
l_tap_id_tbl.delete;
id_ind := 0;

FOR cur_vendor_dtls IN c_vendor_dtls(cp_pph_id => l_disb_rec.pph_id) LOOP
  IF NOT(cur_vendor_dtls.disbursement_basis = 'AMOUNT' AND SIGN(Fnd_Global.CONC_REQUEST_ID) = -1) THEN

    l_tapv_rec := l_tapv_rec_null;
    l_tplv_rec := l_tplv_rec_null;

    IF (l_disb_rec.receivables_invoice_id IS NOT NULL) THEN
    	OPEN  ar_inv_csr(l_disb_rec.receivables_invoice_id);
  	  FETCH ar_inv_csr INTO l_ar_inv_number;
  	  CLOSE ar_inv_csr;

  	  print_line ('    --  Processing Receivables Invoice: '||l_disb_rec.receivables_invoice_number||' AR Invoice: '||l_ar_inv_number);
    END IF;

  	l_tapv_rec.nettable_yn 			  := 'Y';
  	l_tapv_rec.wait_vendor_invoice_yn := 'N';
  	l_tapv_rec.vendor_id	   				 := cur_vendor_dtls.vendor_id;
  	l_tapv_rec.ipvs_id	   				 := cur_vendor_dtls.pay_site_id;
  	l_tapv_rec.payment_method_code	 	 := cur_vendor_dtls.payment_method_code;
  	l_tapv_rec.ippt_id 					 := cur_vendor_dtls.payment_term_id;
  	l_tapv_rec.pay_group_lookup_code 	 := cur_vendor_dtls.pay_group_code;
    l_tapv_rec.try_id           := l_try_id;
    l_tapv_rec.set_of_books_id  := l_disb_rec.set_of_books_id;
    l_tapv_rec.org_id           := l_disb_rec.org_id;
    --l_tapv_rec.khr_id           := l_disb_rec.khr_id;
    l_tapv_rec.currency_code    := l_disb_rec.currency_code;
    l_tapv_rec.TRX_STATUS_CODE  := 'ENTERED';
    l_tapv_rec.date_entered     := SYSDATE;
    l_tapv_rec.workflow_yn      := 'N';
    l_tapv_rec.nettable_yn      := 'Y';
    l_tapv_rec.invoice_type     := 'STANDARD';
    -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity
    l_tapv_rec.legal_entity_id    := l_disb_rec.legal_entity_id;

    --obtain the passthrough amount
  	print_line ('    --  Computing Pass through Amount');
    l_amount_pass := 0;

    IF (l_disb_rec.payout_basis = 'PARTIAL_RECEIPT') THEN
      l_disb_rec.amount := 0;
      lsm_rcpt_id_ind := 0;
      l_lsm_rcpt_tbl.delete;
      FOR cur_receipt_applic_cur IN l_receipt_applic_csr(l_disb_rec.receivables_invoice_id) LOOP
        l_disb_rec.amount := l_disb_rec.amount + cur_receipt_applic_cur.line_applied;

        IF (cur_receipt_applic_cur.apply_date > l_disb_rec.transaction_date) THEN
          l_disb_rec.transaction_date := cur_receipt_applic_cur.apply_date;
        END IF;

        lsm_rcpt_id_ind := lsm_rcpt_id_ind + 1;
       --rkuttiya R12 B Billing Architecture commented out following
        --l_lsm_rcpt_tbl(lsm_rcpt_id_ind).lsm_id := cur_receipt_applic_cur.lsm_id;
       --rkuttiya R12 B Billing Architecture added following
        l_lsm_rcpt_tbl(lsm_rcpt_id_ind).tld_id := cur_receipt_applic_cur.tld_id;
       --
        l_lsm_rcpt_tbl(lsm_rcpt_id_ind).receivable_application_id := cur_receipt_applic_cur.receivable_application_id;
      END LOOP;
      print_line ('      --  payout_basis = ''PARTIAL_RECEIPT'' source amount : '||l_disb_rec.amount);
      print_line ('      --  payout_basis = ''PARTIAL_RECEIPT'' transaction_date : '||l_disb_rec.transaction_date);
      print_line ('      --  payout_basis = ''PARTIAL_RECEIPT'' l_lsm_rcpt_tbl count : '||l_lsm_rcpt_tbl.count);
    END IF;

    IF (l_disb_rec.payout_basis = 'FORMULA') THEN
      --evaluate the formula payout_basis_formula to get the passthru amount
      print_line ('    --  payout_basis_formula: '||l_disb_rec.payout_basis_formula);
      Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => p_api_version
                                     ,p_init_msg_list        =>p_init_msg_list
                                     ,x_return_status        =>x_return_status
                                     ,x_msg_count            =>x_msg_count
                                     ,x_msg_data             =>x_msg_data
                                     ,p_formula_name         =>l_disb_rec.payout_basis_formula
                                     ,p_contract_id          =>l_disb_rec.khr_id
                                     ,p_line_id              =>l_disb_rec.kle_id
                                     ,x_value               =>l_amount_pass
                                     );

      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
               print_line ('*=>ERROR: Evaluating Payout Basis of FORMULA.');
               l_overall_status := x_return_status;
      END IF;

      print_line ('    --  passthru amount from formula: '||l_amount_pass);
    ELSE
     IF (cur_vendor_dtls.disbursement_basis = 'AMOUNT') THEN
       print_line ('    --  passthru fixed amount: '||cur_vendor_dtls.disbursement_fixed_amount);
       l_amount_pass := cur_vendor_dtls.disbursement_fixed_amount;
     ELSIF (cur_vendor_dtls.disbursement_basis = 'PERCENT') THEN
       print_line ('    --  passthru percent: '||cur_vendor_dtls.disbursement_percent);
       l_amount_pass := ((l_disb_rec.amount * cur_vendor_dtls.disbursement_percent)/100);
     ELSE
       l_amount_pass := l_disb_rec.amount;
     END IF;
    END IF;

    --obtain the passthrough processing fee
    l_process_fee := 0;

    IF (l_amount_pass > 0) THEN
      IF (cur_vendor_dtls.processing_fee_basis = 'AMOUNT') THEN
        print_line ('    --  passthru fee fixed amount: '||cur_vendor_dtls.processing_fee_fixed_amount);
        l_process_fee := cur_vendor_dtls.processing_fee_fixed_amount;
      ELSIF (cur_vendor_dtls.processing_fee_basis = 'PERCENT') THEN
        print_line ('    --  passthru fee percent: '||cur_vendor_dtls.processing_fee_percent);
        l_process_fee := ((cur_vendor_dtls.processing_fee_percent * l_amount_pass)/100);
      END IF;
    ELSE
        print_line ('    --  passthru fee not charged as passthru amt is -ve');
    END IF;

	-- bug 8411292: do not deduct the processing fee from the disbursement amount.
    -- l_tapv_rec.amount           := NVL(l_amount_pass, 0) - NVL(l_process_fee, 0);
    l_tapv_rec.amount           := NVL(l_amount_pass, 0);

    IF SIGN(l_tapv_rec.amount) = -1 THEN
          l_tapv_rec.invoice_type := 'CREDIT';
          l_tapv_rec.amount := ABS(l_tapv_rec.amount);
    END IF;

    --obtain the invoice date
    l_invoice_date := trunc(sysdate);

    print_line ('    --  payment_basis: '||cur_vendor_dtls.payment_basis);
    IF (cur_vendor_dtls.payment_basis = 'PROCESS_DATE') THEN
      print_line ('    --  remit_days: '||cur_vendor_dtls.remit_days);
      l_invoice_date := l_invoice_date + cur_vendor_dtls.remit_days;
    ELSIF (cur_vendor_dtls.payment_basis = 'SCHEDULED') THEN
      print_line ('    --  payment_frequency: '||cur_vendor_dtls.payment_frequency);
      print_line ('    --  payment_start_date: '||cur_vendor_dtls.payment_start_date);
      l_invoice_date := get_next_pymt_date(p_start_date => cur_vendor_dtls.payment_start_date
                                          ,p_frequency => cur_vendor_dtls.payment_frequency
                    	                    ,p_offset_date => trunc(sysdate));
    ELSIF (cur_vendor_dtls.payment_basis = 'SOURCE_DATE') THEN
      l_invoice_date := l_disb_rec.transaction_date;
    END IF;

    l_tapv_rec.date_invoiced := l_invoice_date;

    print_line ('    --  vendor_id (Vendor Id): '||l_tapv_rec.vendor_id);
    print_line ('    --  ipvs_id (Vendor Site Id): '||l_tapv_rec.ipvs_id);
    print_line ('    --  ippt_id (Terms Id): '||l_tapv_rec.ippt_id);
    print_line ('    --  payment_method_code: '||l_tapv_rec.payment_method_code);
    print_line ('    --  pay_group_lookup_code: '||l_tapv_rec.pay_group_lookup_code);
    print_line ('    --  passthru processing fee: '||l_process_fee);
    print_line ('    --  passthru amount: '||l_amount_pass);
    print_line ('    --  invoice type: '||l_tapv_rec.invoice_type);
    print_line ('    --  date_invoiced: '||l_tapv_rec.date_invoiced);
    print_line ('    --  passthru_stream_type_id: '||l_disb_rec.passthru_stream_type_id);

    print_line ('    --  final passthru amount: '||l_tapv_rec.amount);	-- Bug: 6663203 fixed

    l_tplv_rec.amount           := l_tapv_rec.amount;
    l_tplv_rec.org_id           := l_tapv_rec.org_id;
    l_tplv_rec.khr_id           := l_disb_rec.khr_id;
    l_tplv_rec.kle_id           := l_disb_rec.kle_id;
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts starts
--  l_tplv_rec.lsm_id           := l_disb_rec.tld_id;
    l_tplv_rec.tld_id           := l_disb_rec.tld_id;
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts ends
    l_tplv_rec.sel_id           := l_disb_rec.sel_id;
    l_tplv_rec.line_number      := 1;

    IF (SIGN(Fnd_Global.CONC_REQUEST_ID) <> -1) THEN
      l_tplv_rec.inv_distr_line_code  := 'AUTO_DISBURSEMENT';
    END IF;
    l_tplv_rec.sty_id           := l_disb_rec.passthru_stream_type_id;

    IF (l_disb_rec.payout_basis = 'BILLING') THEN
    	l_tplv_rec.disbursement_basis_code	 := 'BILL_DATE';
    ELSIF (l_disb_rec.payout_basis IN ('FULL_RECEIPT', 'PARTIAL_RECEIPT')) THEN
    	l_tplv_rec.disbursement_basis_code	 := 'CASH_RECEIPT';
    ELSIF (l_disb_rec.payout_basis = 'DUE_DATE') THEN
    	l_tplv_rec.disbursement_basis_code	 := 'DUE_DATE';
    ELSIF (l_disb_rec.payout_basis = 'FORMULA') THEN
    	l_tplv_rec.disbursement_basis_code	 := 'FORMULA';
    END IF;

    print_line ('    --  disbursement_basis_code: '||l_tplv_rec.disbursement_basis_code);

  	-- Test Flag
  	IF  l_tplv_rec.disbursement_basis_code  IS NULL  THEN
  	     print_line ('    ++ Defaulting Disbursement BasisCode to BILL_DATE ');
  	     l_tplv_rec.disbursement_basis_code := 'BILL_DATE';
  	END IF;
/*
|  06-Dec-07    cklee   -- Bug: 6663203 fixed:                                |
|                          skip the following passthrough requests:           |
|                      1. if passthrough amount = 0                           |
|                      2. if passthrough processing fee >= passthrough amount |
|                          and record to concurrent request log file          |
*/
-- start: Bug: 6663203 fixed
  IF l_tapv_rec.amount = 0 THEN
  	     print_line ('    *************************************************');
  	     print_line ('    Skip passthrou request due to request amount = 0');
  	     print_line ('    passthrough amount = passthru amount - passthru processing fee amount');
  	     print_line ('    *************************************************');
  ELSIF NVL(l_process_fee, 0) > ABS(NVL(l_amount_pass, 0)) THEN
  	     print_line ('    *************************************************');
  	     print_line ('    Skip passthrou request due to processing fee amount > passthru amount');
  	     print_line ('    passthrough amount = passthru amount - passthru processing fee amount');
  	     print_line ('    *************************************************');
  ELSE

    IF (NVL(l_overall_status,  OKL_API.G_RET_STS_ERROR) = OKL_API.G_RET_STS_SUCCESS) THEN
      invoice_insert (
      		p_api_version   => p_api_version,
      		p_init_msg_list => p_init_msg_list,
      		x_return_status => x_return_status,
      		x_msg_count     => x_msg_count,
      		x_msg_data      => x_msg_data,
      		p_receivables_invoice_id => l_disb_rec.receivables_invoice_id,
      		P_tapv_rec      => l_tapv_rec,
      		p_tplv_rec      => l_tplv_rec,
          x_tapv_rec      => lx_tapv_rec);

      id_ind := id_ind + 1;
      l_tap_id_tbl(id_ind) := lx_tapv_rec.id;

      IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
  		      print_line ( '    -- Inserted Pay Invoices');
      ELSE
            l_overall_status := x_return_status;
  			    print_line ( '*=> ERROR : Inserting Pay Invoices');
  	  END IF;
    END IF;
  END IF;
-- end: Bug: 6663203 fixed

    IF (l_disb_rec.receivables_invoice_number IS NOT NULL) THEN
      print_line ('    --  Processing Receivables Invoice: '||l_disb_rec.receivables_invoice_number||' AR Invoice: '||l_ar_inv_number);
    END IF;
  END IF;
END LOOP;

IF (l_overall_status <> OKL_API.G_RET_STS_SUCCESS AND l_tap_id_tbl.count > 0 ) THEN
  print_line ('    --  Updating pay invoices TRX_STATUS_CODE with ERROR status since l_overall_status = ' || l_overall_status);
  FOR id_ind IN l_tap_id_tbl.first..l_tap_id_tbl.last LOOP
    update okl_trx_ap_invoices_b
    set TRX_STATUS_CODE = 'ERROR'
       ,object_version_number = object_version_number + 1
       ,last_updated_by = FND_GLOBAL.USER_ID
       ,last_update_date = sysdate
       ,last_update_login = FND_GLOBAL.LOGIN_ID
       ,request_id = NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),null)
    where id = l_tap_id_tbl(id_ind);
  END LOOP;
END IF;

IF (l_overall_status = OKL_API.G_RET_STS_SUCCESS
    AND l_disb_rec.payout_basis = 'PARTIAL_RECEIPT'
    AND l_lsm_rcpt_tbl.count > 0 ) THEN
    FOR lsm_rcpt_id_ind IN l_lsm_rcpt_tbl.first..l_lsm_rcpt_tbl.last LOOP
                        ------------------------------
                        -- Populate PK from sequence
                        ------------------------------
                        l_idh_id := get_seq_id;
                        INSERT INTO okl_investor_payout_summary_b
                        (   ID,
                            OBJECT_VERSION_NUMBER,
                            CREATED_BY,
                            CREATION_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATE_LOGIN,
                            INVESTOR_AGREEMENT_ID,
                            INVESTOR_LINE_ID,
                          --rkuttiya R12 B Billing Architecture commented out following
                            --LSM_ID,
                         --rkuttiya R12 B Billing Architecture added following
                            TLD_ID,
                         --
                            RECEIVABLE_APPLICATION_ID
                        )
                        VALUES
                        (
                            l_idh_id,
                            1,
                            Fnd_Global.USER_ID,
                            SYSDATE,
                            Fnd_Global.USER_ID,
                            SYSDATE,
                            Fnd_Global.LOGIN_ID,
                            null, --inv_lease_k_rec.Investor_Agreement_id,
                            null, --share_rec.TOP_LINE_ID,
                          --rkuttiya R12 B Billing Architecture commented out following
                           -- l_lsm_rcpt_tbl(lsm_rcpt_id_ind).lsm_id,
                          --rkuttiya R12 B Billing Architecture added following
                            l_lsm_rcpt_tbl(lsm_rcpt_id_ind).tld_id,
                          --
                            l_lsm_rcpt_tbl(lsm_rcpt_id_ind).receivable_application_id
                        );
    END LOOP;
END IF;

x_return_status := l_overall_status;
print_line ( '******** EXITING PROCEDURE INVOICE_DISBURSEMENT ********');

okl_api.end_activity(x_msg_count => x_msg_count
                      ,x_msg_data => x_msg_data);
EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
END invoice_disbursement;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_invoice_pay_status
-- Description     : update the pay_status_code, date_disbursed of the cnsld
--                   invoice stream with the status the pay invoice creation
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE update_invoice_pay_status(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY      VARCHAR2
	,x_msg_count		OUT NOCOPY      NUMBER
	,x_msg_data		    OUT NOCOPY      VARCHAR2
  ,p_tld_id        IN NUMBER
  ,p_status        IN VARCHAR2)
IS
  l_api_name	    CONSTANT VARCHAR2(30)   := 'UPDATE_INVOICE_PAY_STATUS';
  l_return_status	VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;

  --rkuttiya R12 B BIlling Architecture commented out following
/*
  u_lsmv_rec	  Okl_Cnsld_Ar_Strms_Pub.lsmv_rec_type;
  r_lsmv_rec	  Okl_Cnsld_Ar_Strms_Pub.lsmv_rec_type;
*/
  --rkuttiya R12 B Billing Architecture added following
  l_txdv_rec   okl_tld_pvt.tldv_rec_type;
  lx_txdv_rec  okl_tld_pvt.tldv_rec_type;

  l_msg_index_out     NUMBER;
  i                   NUMBER;
BEGIN
       print_line ( '******** IN PROCEDURE UPDATE_INVOICE_PAY_STATUS ********');
       print_line ('    --  Updating okl_txd_ar_ln_dtls_pub with status : '||p_status);
       IF NVL(p_status, 'E') = OKL_API.G_RET_STS_SUCCESS THEN

      --rkuttiya R12 B Billing Architecture commented out following
        -- u_lsmv_rec.id   				:= p_lsm_id;
        -- u_lsmv_rec.pay_status_code   := 'PROCESSED';
        -- u_lsmv_rec.date_disbursed := trunc(sysdate);
      --rkuttiya R12 B Billing Architecture added following
         l_txdv_rec.id              := p_tld_id;
         l_txdv_rec.pay_status_code := 'PROCESSED';
         l_txdv_rec.date_disbursed  := trunc(sysdate);

       --rkuttiya R12 B Billing Architecture commented out following
  /*
         Okl_Cnsld_Ar_Strms_Pub.update_cnsld_ar_strms
         (p_api_version
         ,p_init_msg_list
         ,l_return_status
         ,x_msg_count
         ,x_msg_data
         ,u_lsmv_rec
         ,r_lsmv_rec);
   */
         --rkuttiya R12 B Billing Architecture added following
         okl_txd_ar_ln_dtls_pub.update_txd_ar_ln_dtls
         (p_api_version
         ,p_init_msg_list
         ,l_return_status
         ,x_msg_count
         ,x_msg_data
         ,l_txdv_rec
         ,lx_txdv_rec);
        --
         IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
             print_line ('*=>ERROR: Updating  Invoice Lines .');
         END IF;
       ELSE
         IF x_msg_count >= 1 THEN
           	  FOR i IN 1..x_msg_count LOOP
         	  	  fnd_msg_pub.get(p_msg_index=> i,
                        p_encoded   => 'F',
                        p_data      => x_msg_data,
                        p_msg_index_out => l_msg_index_out);
    			      print_line (  x_msg_data);
           	  END LOOP;

         END IF;

       --rkuttiya R12 B Billing Architecture commented out following
         --u_lsmv_rec.id   				:= p_lsm_id;
         --u_lsmv_rec.pay_status_code   := 'ERROR';
       --rkuttiya R12 B BIlling Architecture added following
          l_txdv_rec.id  := p_tld_id;
          l_txdv_rec.pay_status_code := 'ERROR';
       --
	--rkuttiya R12 B Billing Architecture commented out following
        /* Okl_Cnsld_Ar_Strms_Pub.update_cnsld_ar_strms
         (p_api_version
         ,p_init_msg_list
         ,l_return_status
         ,x_msg_count
         ,x_msg_data
         ,u_lsmv_rec
         ,r_lsmv_rec);  */

      --rkuttiya R12 B Billing Architecture added following
         okl_txd_ar_ln_dtls_pub.update_txd_ar_ln_dtls
         (p_api_version
         ,p_init_msg_list
         ,l_return_status
         ,x_msg_count
         ,x_msg_data
         ,l_txdv_rec
         ,lx_txdv_rec);
      --
         IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
             print_line ('*=>ERROR: Updating Invoice Lines.');
         END IF;

       END IF;

       print_line ( '******** EXITING PROCEDURE UPDATE_INVOICE_PAY_STATUS ********');
       x_return_status := l_return_status;
EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN OKL_API.G_EXCEPTION_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
END update_invoice_pay_status;

----------------------------------------------------------------------------------

PROCEDURE auto_disbursement_tbl(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY      VARCHAR2
	,x_msg_count		  OUT NOCOPY      NUMBER
	,x_msg_data		    OUT NOCOPY      VARCHAR2
  ,p_disb_tbl       IN disb_tbl_type)
IS
	------------------------------------------------------------
	-- Declare Variables required by APIs
	------------------------------------------------------------
 	l_api_version	CONSTANT NUMBER         := 1;
  l_api_name	    CONSTANT VARCHAR2(30)   := 'AUTO_DISBURSEMENT_TBL';
  l_return_status	VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;

  l_disb_rec disb_rec_type;
  l_disb_tbl disb_tbl_type;

  ind NUMBER;
BEGIN
  print_line ( '******** IN PROCEDURE AUTO_DISBURSEMENT_TBL ********');

  l_return_status := okl_api.start_activity(
  	p_api_name	=> l_api_name,
  	p_init_msg_list	=> p_init_msg_list,
  	p_api_type	=> '_PVT',
 		x_return_status	=> l_return_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		  RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  l_disb_tbl := p_disb_tbl;
  FOR ind in l_disb_tbl.first..l_disb_tbl.last LOOP
       G_commit_count := G_commit_count + 1;

		   l_return_status := OKL_API.G_RET_STS_SUCCESS;
       l_disb_rec := null_disb_rec;

    	 fnd_msg_pub.initialize;

    	 --SAVEPOINT C_INVOICE_POINT;

       --rkuttiya R12 B Billing commented out cnr_id and consolidated_invoice_number
       --l_disb_rec.cnr_id  := l_disb_tbl(ind).cnr_id;
       --l_disb_rec.consolidated_invoice_number := l_disb_tbl(ind).consolidated_invoice_number;
       --rkuttiya R12 B Billing added receivables invoice number
       l_disb_rec.receivables_invoice_number := l_disb_tbl(ind).receivables_invoice_number;
       l_disb_rec.set_of_books_id  := l_disb_tbl(ind).set_of_books_id;
       l_disb_rec.org_id  := l_disb_tbl(ind).org_id;
       l_disb_rec.transaction_date  := l_disb_tbl(ind).transaction_date;
       l_disb_rec.currency_code  := l_disb_tbl(ind).currency_code;
       l_disb_rec.khr_id  := l_disb_tbl(ind).khr_id;
       l_disb_rec.kle_id  := l_disb_tbl(ind).kle_id;
       l_disb_rec.amount  := l_disb_tbl(ind).amount;
       l_disb_rec.sty_id  := l_disb_tbl(ind).sty_id;
      --rkuttiya R12B Billing commented out lsm_id and added tld_id
       --l_disb_rec.lsm_id  := l_disb_tbl(ind).lsm_id;
       l_disb_rec.tld_id  := l_disb_tbl(ind).tld_id;
      --
       l_disb_rec.receivables_invoice_id  := l_disb_tbl(ind).receivables_invoice_id;
       l_disb_rec.sel_id  := l_disb_tbl(ind).sel_id;
       l_disb_rec.pph_id  := l_disb_tbl(ind).pph_id;
       l_disb_rec.passthru_stream_type_id  := l_disb_tbl(ind).passthru_stream_type_id;
       l_disb_rec.payout_basis  := l_disb_tbl(ind).payout_basis;
       l_disb_rec.payout_basis_formula  := l_disb_tbl(ind).payout_basis_formula;
       l_disb_rec.contract_number  := l_disb_tbl(ind).contract_number;
 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity
       l_disb_rec.legal_entity_id  := l_disb_tbl(ind).legal_entity_id;

   	   print_line ('===========================================================================================');
       IF (l_disb_rec.payout_basis IN ('BILLING', 'FULL_RECEIPT', 'PARTIAL_RECEIPT')) THEN
   	     print_line ('Processing Receivables Invoice Number: ' || l_disb_rec.receivables_invoice_number);
       ELSIF (l_disb_rec.payout_basis IN ('DUE_DATE')) THEN
   	     print_line ('Processing Stream Element: ' || l_disb_rec.sel_id);
       ELSE
   	     print_line ('Processing Contract Line Number: ' || l_disb_rec.kle_id);
       END IF;
   	   print_line ('===========================================================================================');

       print_line ('  --  set_of_books_id : '||l_disb_rec.set_of_books_id);
       print_line ('  --  org_id : '||l_disb_rec.org_id);
       print_line ('  --  transaction_date : '||l_disb_rec.transaction_date);
       print_line ('  --  currency_code : '||l_disb_rec.currency_code);
       print_line ('  --  contract : '||l_disb_tbl(ind).contract_number);
       print_line ('  --  kle_id : '||l_disb_rec.kle_id);
       print_line ('  --  source amount : '||l_disb_rec.amount);
       print_line ('  --  tld_id : '||l_disb_rec.tld_id);
       print_line ('  --  receivables_invoice_id : '||l_disb_rec.receivables_invoice_id);
       print_line ('  --  pph_id (party payment header) : '||l_disb_rec.pph_id);
       print_line ('  --  passthru_stream_type_id : '||l_disb_rec.passthru_stream_type_id);
       print_line ('  --  payout_basis : '||l_disb_rec.payout_basis);
       print_line ('  --  payout_basis_formula : '||l_disb_rec.payout_basis_formula);
 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity
       print_line ('  --  legal_entity_id : '||l_disb_rec.legal_entity_id);

       ------------------------------------------------------------
       -- Call for Invoice Disbursement
       ------------------------------------------------------------
    	 invoice_disbursement (
              p_api_version   => p_api_version,
              p_init_msg_list => p_init_msg_list,
              x_return_status => l_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data,
              p_disb_rec      => l_disb_rec);


       IF NVL(l_return_status, 'E') = OKL_API.G_RET_STS_SUCCESS THEN
         print_line ('=====> Successfully Proccesed Passthrough Transaction');
       ELSE
         print_line ('*=>ERROR: Processing Passthrough Transaction');
       END IF;

       IF (l_disb_rec.payout_basis IN ('BILLING', 'FULL_RECEIPT', 'PARTIAL_RECEIPT')) THEN
         --update consolidated stream with status of passthru transaction creation
         update_invoice_pay_status(
        					 p_api_version   => p_api_version,
        					 p_init_msg_list => p_init_msg_list,
        					 x_return_status => x_return_status,
        					 x_msg_count     => x_msg_count,
        					 x_msg_data      => x_msg_data,
                   p_tld_id        => l_disb_rec.tld_id,
                   p_status        => l_return_status);

         IF NVL(x_return_status, 'E') = OKL_API.G_RET_STS_SUCCESS THEN
           print_line ('=====> Successfully Updated Consolidated Invoice Stream : pay status code');
         ELSE
           print_line ('*=>ERROR: Updating Consolidated Invoice Stream : pay status code');
         END IF;
       ELSIF (l_disb_rec.payout_basis IN ('DUE_DATE')) THEN
         --update stream element with status of passthru transaction creation
         IF NVL(l_return_status, 'E') = OKL_API.G_RET_STS_SUCCESS THEN
           update okl_strm_elements
           set  date_disbursed = trunc(sysdate)
                  ,object_version_number = object_version_number + 1
                  ,last_updated_by = FND_GLOBAL.USER_ID
                  ,last_update_date = sysdate
                  ,last_update_login = FND_GLOBAL.LOGIN_ID
                  ,request_id = NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),null)
           where id = l_disb_rec.sel_id;
         END IF;
       END IF;

       print_line ('===========================================================================================');
       IF (l_disb_rec.payout_basis IN ('BILLING', 'FULL_RECEIPT', 'PARTIAL_RECEIPT')) THEN
   	     print_line ('Done Processing Receivables Invoice Number: ' || l_disb_rec.receivables_invoice_number);
       ELSIF (l_disb_rec.payout_basis IN ('DUE_DATE')) THEN
   	     print_line ('Done Processing Stream Element: ' || l_disb_rec.sel_id);
       ELSE
   	     print_line ('Done Processing Contract Line Number: ' || l_disb_rec.kle_id);
       END IF;
       print_line ('===========================================================================================');

       --Start code added by pgomes on 02/12/2003
       IF (MOD(G_commit_count, G_commit_after_records) = 0) THEN
             COMMIT;
             print_line ('===========================================================================================');
             print_line ('Done committing after processing  ' || G_commit_count || ' transactions.');
             print_line ('===========================================================================================');
       END IF;
  END LOOP;

  print_line ( '******** EXITING PROCEDURE AUTO_DISBURSEMENT_TBL ********');

  okl_api.end_activity(x_msg_count => x_msg_count
                      ,x_msg_data => x_msg_data);
EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN OKL_API.G_EXCEPTION_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

END auto_disbursement_tbl;

----------------------------------------------------------------------------------

PROCEDURE auto_disbursement(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY      VARCHAR2
	,x_msg_count		OUT NOCOPY      NUMBER
	,x_msg_data		    OUT NOCOPY      VARCHAR2
	,p_from_date	    IN  DATE
	,p_to_date		    IN  DATE
  ,p_contract_number IN VARCHAR2)
IS
	------------------------------------------------------------
	-- Declare Variables required by APIs
	------------------------------------------------------------
 	l_api_version	CONSTANT NUMBER         := 1;
  l_api_name	    CONSTANT VARCHAR2(30)   := 'AUTO_DISBURSEMENT';
  l_return_status	VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;

	--------------------------------------------------------------------
	--Declare Cursor: Receivable Invoices eligible for disbursement with
  --payout_basis = 'BILLING' ,passthru_term = 'BASE', 'EVERGREEN'
  --for top lines, sub lines
	--------------------------------------------------------------------
  --02/26/07 rkuttiya modified following cursor for R12 B Billing Architecture
  --replaced data elements, tables, and modified where clause
  CURSOR c_invoice_bill(p_from_date DATE, p_to_date DATE, p_contract_number VARCHAR2)
  IS
         SELECT
             NULL cnr_id
            ,arl.receivables_invoice_number
            ,tai.set_of_books_id
            ,arv.org_id
            ,arv.date_consolidated
            ,arv.currency_code
            ,tai.khr_id
            ,til.kle_id
            ,arl.amount
            ,arl.sty_id
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts starts
--            ,arl.id lsm_id
            ,tld.id  tld_id
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts ends
            ,arl.receivables_invoice_id
            ,null sel_id
            ,pph.id pph_id
            ,NVL(pph.passthru_stream_type_id, arl.sty_id) passthru_stream_type_id
            ,pph.payout_basis
            ,null payout_basis_formula
            ,khr.contract_number
 -- 30-OCT-2006 ANSETHUR  R12B - Legal Entity
            ,tai.legal_entity_id
         FROM okc_k_headers_b khr
             ,okc_k_lines_b kle
             --added for evergreen change request 08_nov_2005
             ,okc_line_styles_b lse
             ,okl_bpd_ar_inv_lines_v arl
             ,okl_bpd_ar_invoices_v arv
             ,okl_trx_ar_invoices_v tai
             ,okl_txl_ar_inv_lns_v til
             ,okl_txd_ar_ln_dtls_b tld
             ,okl_party_payment_hdr pph
         WHERE  khr.contract_number = NVL(p_contract_number, khr.contract_number)
         AND   khr.id = kle.dnz_chr_id
         AND   kle.id = til.kle_id
         AND   til.id = tld.til_id_details
         AND   arl.receivables_invoice_id > 0
        --rkuttiya commented and changed for Billing Architecture
         --AND   (lsm.pay_status_code is NULL OR lsm.pay_status_code = 'ERROR')
           AND   (tld.pay_status_code IS NULL OR tld.pay_status_code = 'ERROR')
         --start fix for bug 5040815 by pgomes 24-mar-2006
         AND   arl.sty_id NOT IN (SELECT id FROM okl_strm_type_v
                                  WHERE stream_type_purpose in ('LATE_FEE', 'LATE_INTEREST'))
         --end fix for bug 5040815 by pgomes 24-mar-2006
       --rkuttiya R12 B Billing Architecture commented out the following
         --AND lsm.lln_id = lln.id
         --AND lln.cnr_id = cnr.id
         --AND cnr.trx_status_code = 'PROCESSED'
       --
       --rkuttiya R12 B BIlling added the following
         AND til.tai_id = tai.id
         AND til.id = arl.til_id_details
         AND tai.trx_status_code = 'PROCESSED'
         AND arv.invoice_id = arl.receivables_invoice_id
       --
         --added for evergreen change request 08_nov_2005
         AND   kle.lse_id = lse.id
         --commented for evergreen change request 08_nov_2005
         --AND   kle.id = pph.cle_id
         AND   kle.dnz_chr_id = pph.dnz_chr_id
         AND   pph.payout_basis = 'BILLING'
         AND   trunc(arv.date_consolidated) >= trunc(NVL(pph.passthru_start_date, arv.date_consolidated))
         AND   (trunc(arv.date_consolidated) <= trunc(kle.end_date) AND pph.passthru_term = 'BASE'
                --added for evergreen change request 08_nov_2005
                AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'BASE') = pph.id
                OR
                trunc(arv.date_consolidated) > trunc(kle.end_date) AND pph.passthru_term = 'EVERGREEN'
                --added for evergreen change request 08_nov_2005
                AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'EVERGREEN') = pph.id)
         AND   trunc(arv.date_consolidated) BETWEEN NVL (TRUNC(p_from_date), SYSDATE-10000)
         AND 	   NVL (TRUNC(p_to_date), SYSDATE+10000)
         UNION ALL
         SELECT
             NULL cnr_id
            ,arl.receivables_invoice_number
            ,tai.set_of_books_id
            ,arv.org_id
            ,arv.date_consolidated
            ,arv.currency_code
            ,tai.khr_id
            ,til.kle_id
            ,arl.amount
            ,arl.sty_id
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts starts
--          ,arl.id lsm_id
            ,tld.id  tld_id
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts ends
            ,arl.receivables_invoice_id
            ,null sel_id
            ,pph.id pph_id
            ,NVL(pph.passthru_stream_type_id, arl.sty_id) passthru_stream_type_id
            ,pph.payout_basis
            ,null payout_basis_formula
            ,khr.contract_number
 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity
            ,tai.legal_entity_id
         FROM okc_k_headers_b khr
             ,okc_k_lines_b kle
             ,okc_k_lines_b sub_kle
             --added for evergreen change request 08_nov_2005
             ,okc_line_styles_b lse
             ,okl_bpd_ar_inv_lines_v arl
             ,okl_bpd_ar_invoices_v arv
             ,okl_trx_ar_invoices_v tai
             ,okl_txl_ar_inv_lns_v til
             ,okl_txd_ar_ln_dtls_b tld
             ,okl_party_payment_hdr pph
         WHERE khr.contract_number = NVL(p_contract_number, khr.contract_number)
         AND   khr.id = sub_kle.dnz_chr_id
         AND   sub_kle.chr_id is null
     --rkuttiya commented for R12 B Billing Architecture
        -- AND   sub_kle.id = lsm.kle_id
         AND   sub_kle.id = til.kle_id
         AND   til.id = tld.til_id_details
     --
         AND   arl.receivables_invoice_id > 0
         AND   (tld.pay_status_code is NULL OR tld.pay_status_code = 'ERROR')
         --start fix for bug 5040815 by pgomes 24-mar-2006
         AND   arl.sty_id NOT IN (SELECT id FROM okl_strm_type_v
                                  WHERE stream_type_purpose in ('LATE_FEE', 'LATE_INTEREST'))
         --end fix for bug 5040815 by pgomes 24-mar-2006
      --rkuttiya commented following for R12 B Billing Architecture
         --AND   lsm.lln_id = lln.id
        -- AND   lln.cnr_id = cnr.id
         --AND   cnr.trx_status_code = 'PROCESSED'
       --rkuttiya added for R12 B Billing Architecture
          AND til.tai_id = tai.id
          AND til.id = arl.til_id_details
          AND arv.invoice_id = arl.receivables_invoice_id
          AND tai.trx_status_code = 'PROCESSED'
       --
          AND   khr.id = kle.chr_id
         AND   sub_kle.cle_id = kle.id
         --added for evergreen change request 08_nov_2005
         AND   kle.lse_id = lse.id
         --commented for evergreen change request 08_nov_2005
         --AND   kle.id = pph.cle_id
         AND   kle.dnz_chr_id = pph.dnz_chr_id
         AND   pph.payout_basis = 'BILLING'
       --rkuttiya R12 B Billing Architecture  replaced arv.date_consolidated by arv.date_consolidated
         AND   trunc(arv.date_consolidated) >= trunc(NVL(pph.passthru_start_date, arv.date_consolidated))
         AND   (trunc(arv.date_consolidated) <= trunc(kle.end_date) AND pph.passthru_term = 'BASE'
                --added for evergreen change request 08_nov_2005
                AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'BASE') = pph.id
                OR
                trunc(arv.date_consolidated) > trunc(kle.end_date) AND pph.passthru_term = 'EVERGREEN'
                --added for evergreen change request 08_nov_2005
                AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'EVERGREEN') = pph.id)
         AND   trunc(arv.date_consolidated) BETWEEN NVL (TRUNC(p_from_date), SYSDATE-10000)
                                                   AND 	   NVL (TRUNC(p_to_date), SYSDATE+10000);
       --rkuttiya R12 B Billing Architecture end changes for this cursor



	--------------------------------------------------------------------
	--Declare Cursor: Receivable Invoices eligible for disbursement with
        --payout_basis = 'FULL_RECEIPT' ,passthru_term = 'BASE', 'EVERGREEN'
        --for top lines, sub lines
	--------------------------------------------------------------------
 --rkuttiya R12 B Billing modified this cursor  data elements, tables, where clause
  CURSOR c_invoice_full_rcpt(p_from_date DATE, p_to_date DATE, p_contract_number VARCHAR2)
  IS
         SELECT
             NULL cnr_id
            ,arl.receivables_invoice_number
            ,tai.set_of_books_id
            ,arv.org_id
            ,okl_pay_invoices_disb_pvt.receipt_date(arl.receivables_invoice_id) receipt_date
            ,arv.currency_code
            ,tai.khr_id
            ,til.kle_id
            ,okl_pay_invoices_disb_pvt.receipt_amount(arl.receivables_invoice_id) amount
            ,arl.sty_id
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts starts
--          ,arl.id lsm_id
            ,tld.id  tld_id
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts ends
            ,arl.receivables_invoice_id
            ,null sel_id
            ,pph.id pph_id
            ,NVL(pph.passthru_stream_type_id, arl.sty_id) passthru_stream_type_id
            ,pph.payout_basis
            ,null payout_basis_formula
            ,khr.contract_number
 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity
            ,tai.legal_entity_id
         FROM okc_k_headers_b khr
             ,okc_k_lines_b kle
             --added for evergreen change request 08_nov_2005
             ,okc_line_styles_b lse
             ,okl_bpd_ar_inv_lines_v arl
             ,okl_bpd_ar_invoices_v arv
             ,okl_trx_ar_invoices_v tai
             ,okl_txl_ar_inv_lns_v til
             ,okl_txd_ar_ln_dtls_b tld
             ,okl_party_payment_hdr pph
             ,ar_payment_schedules_all aps
          WHERE khr.contract_number = NVL(p_contract_number, khr.contract_number)
         AND   khr.id = kle.dnz_chr_id
         AND   kle.id = til.kle_id
         AND   arl.receivables_invoice_id > 0
         --rkuttiya R12 B Billing Architecture  commented the following code and added code replacing lsm by arl
         --AND   (lsm.pay_status_code is NULL OR lsm.pay_status_code = 'ERROR')
         AND til.id = tld.til_id_details
         AND (tld.pay_status_code IS NULL OR tld.pay_status_code = 'ERROR')
         --
         --start fix for bug 5040815 by pgomes 24-mar-2006
         AND   arl.sty_id NOT IN (SELECT id FROM okl_strm_type_v
                                  WHERE stream_type_purpose in ('LATE_FEE', 'LATE_INTEREST'))
         --end fix for bug 5040815 by pgomes 24-mar-2006
         --rkuttiya R12 B Billing Architecture commented out the following
         --AND   lsm.lln_id = lln.id
         --AND   lln.cnr_id = cnr.id
         --AND   cnr.trx_status_code = 'PROCESSED'
        --rkuttiya added for Billing Architecture
         AND til.tai_id = tai.id
         AND til.id = arl.til_id_details
         AND tai.trx_status_code = 'PROCESSED'
         AND arv.invoice_id = arl.receivables_invoice_id
         --
         --added for evergreen change request 08_nov_2005
         AND   kle.lse_id = lse.id
         --commented for evergreen change request 08_nov_2005
         --AND   kle.id = pph.cle_id
         AND   kle.dnz_chr_id = pph.dnz_chr_id
         AND   pph.payout_basis = 'FULL_RECEIPT'
         AND   trunc(arv.date_consolidated) >= trunc(NVL(pph.passthru_start_date, arv.date_consolidated))
         AND   (trunc(arv.date_consolidated) <= trunc(kle.end_date) AND pph.passthru_term = 'BASE'
                --added for evergreen change request 08_nov_2005
                AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'BASE') = pph.id
                OR
                trunc(arv.date_consolidated) > trunc(kle.end_date) AND pph.passthru_term = 'EVERGREEN'
                --added for evergreen change request 08_nov_2005
                AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'EVERGREEN') = pph.id)
         AND   arl.receivables_invoice_id = aps.customer_trx_id
         AND   aps.class = 'INV'
         AND   aps.status = 'CL'
         AND   trunc(arv.date_consolidated) BETWEEN NVL (TRUNC(p_from_date), SYSDATE-10000)
                                     AND 	   NVL (TRUNC(p_to_date), SYSDATE+10000)
         UNION ALL
         SELECT
             NULL cnr_id
            ,arl.receivables_invoice_number
            ,tai.set_of_books_id
            ,arv.org_id
            ,okl_pay_invoices_disb_pvt.receipt_date(arl.receivables_invoice_id) receipt_date
            ,arv.currency_code
            ,tai.khr_id
            ,til.kle_id
            ,okl_pay_invoices_disb_pvt.receipt_amount(arl.receivables_invoice_id) amount
            ,arl.sty_id
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts starts
--          ,arl.id lsm_id
            ,tld.id  tld_id
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts ends
            ,arl.receivables_invoice_id
            ,null sel_id
            ,pph.id pph_id
            ,NVL(pph.passthru_stream_type_id, arl.sty_id) passthru_stream_type_id
            ,pph.payout_basis
            ,null payout_basis_formula
            ,khr.contract_number
 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity
            ,tai.legal_entity_id
         FROM okc_k_headers_b khr
             ,okc_k_lines_b kle
             ,okc_k_lines_b sub_kle
             --added for evergreen change request 08_nov_2005
             ,okc_line_styles_b lse
             ,okl_bpd_ar_inv_lines_v arl
             ,okl_bpd_ar_invoices_v arv
             ,okl_trx_ar_invoices_v tai
             ,okl_txl_ar_inv_lns_v til
             ,okl_txd_ar_ln_dtls_b tld
             ,okl_party_payment_hdr pph
             ,ar_payment_schedules_all aps
         WHERE khr.contract_number = NVL(p_contract_number, khr.contract_number)
         AND   khr.id = sub_kle.dnz_chr_id
         AND   sub_kle.chr_id is null
       --rkuttiya commented for R12 B Billing Architecture
         --AND   sub_kle.id = lsm.kle_id
        --rkuttiya R12 Billing Architecture
         AND sub_kle.id = til.kle_id
        --
         AND   arl.receivables_invoice_id > 0
        --rkuttiya commented for R12 B Billing Architecture
         --AND   (lsm.pay_status_code is NULL OR lsm.pay_status_code = 'ERROR')
        --rkuttiya added R12B Billing Architecture
         AND (tld.pay_status_code IS NULL OR tld.pay_status_code = 'ERROR')
         --start fix for bug 5040815 by pgomes 24-mar-2006
         AND   arl.sty_id NOT IN (SELECT id FROM okl_strm_type_v
                                  WHERE stream_type_purpose in ('LATE_FEE', 'LATE_INTEREST'))
         --end fix for bug 5040815 by pgomes 24-mar-2006
         --rkuttiya commented for R12 B Billing Architecture
         --AND   lsm.lln_id = lln.id
         --AND   lln.cnr_id = cnr.id
         --AND   cnr.trx_status_code = 'PROCESSED'
         --rkuttiya added for R12 B Billing Architecture
         AND   til.tai_id = tai.id
         AND   til.id = arl.til_id_details
         AND   tai.trx_status_code = 'PROCESSED'
         AND   arv.invoice_id = arl.receivables_invoice_id
        --
         AND   khr.id = kle.chr_id
         AND   sub_kle.cle_id = kle.id
         --added for evergreen change request 08_nov_2005
         AND   kle.lse_id = lse.id
         --commented for evergreen change request 08_nov_2005
         --AND   kle.id = pph.cle_id
         AND   kle.dnz_chr_id = pph.dnz_chr_id
         AND   pph.payout_basis = 'FULL_RECEIPT'
         AND   trunc(arv.date_consolidated) >= trunc(NVL(pph.passthru_start_date, arv.date_consolidated))
         AND   (trunc(arv.date_consolidated) <= trunc(kle.end_date) AND pph.passthru_term = 'BASE'
                --added for evergreen change request 08_nov_2005
                AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'BASE') = pph.id
                OR
                trunc(arv.date_consolidated) > trunc(kle.end_date) AND pph.passthru_term = 'EVERGREEN'
                --added for evergreen change request 08_nov_2005
                AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'EVERGREEN') = pph.id)
         AND   arl.receivables_invoice_id = aps.customer_trx_id
         AND   aps.class = 'INV'
         AND   aps.status = 'CL'
         AND   trunc(arv.date_consolidated) BETWEEN NVL (TRUNC(p_from_date), SYSDATE-10000)
                                     AND 	   NVL (TRUNC(p_to_date), SYSDATE+10000);


	--------------------------------------------------------------------
	--Declare Cursor: Receivable Invoices eligible for disbursement with
  --payout_basis = 'PARTIAL_RECEIPT' ,passthru_term = 'BASE', 'EVERGREEN'
  --for top lines, sub lines
	--------------------------------------------------------------------
  CURSOR c_invoice_part_rcpt(p_from_date DATE, p_to_date DATE, p_contract_number VARCHAR2)
  IS
         SELECT
             NULL cnr_id
            ,arl.receivables_invoice_number
            ,tai.set_of_books_id
            ,arv.org_id
            ,okl_pay_invoices_disb_pvt.partial_receipt_date(arl.receivables_invoice_id) partial_receipt_date
            ,arv.currency_code
            ,tai.khr_id
            ,til.kle_id
            ,okl_pay_invoices_disb_pvt.partial_receipt_amount(arl.receivables_invoice_id) amount
            ,arl.sty_id
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts starts
--          ,arl.id lsm_id
            ,tld.id  tld_id
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts ends
            ,arl.receivables_invoice_id
            ,null sel_id
            ,pph.id pph_id
            ,NVL(pph.passthru_stream_type_id, arl.sty_id) passthru_stream_type_id
            ,pph.payout_basis
            ,null payout_basis_formula
            ,khr.contract_number
 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity
            ,tai.legal_entity_id
         FROM okc_k_headers_b khr
             ,okc_k_lines_b kle
             --added for evergreen change request 08_nov_2005
             ,okc_line_styles_b lse
             ,okl_bpd_ar_inv_lines_v arl
             ,okl_bpd_ar_invoices_v arv
             ,okl_trx_ar_invoices_v tai
             ,okl_txl_ar_inv_lns_v til
-- 05/31/07 ansethur added for R12B Billing architecture Passthrough impacts starts
              ,okl_txd_ar_ln_dtls_b tld
-- 05/31/07 ansethur added for R12B Billing architecture Passthrough impacts ends
             ,okl_party_payment_hdr pph
             ,ar_payment_schedules_all aps
         WHERE khr.contract_number = NVL(p_contract_number, khr.contract_number)
         AND   khr.id = kle.dnz_chr_id
         AND   kle.id = til.kle_id
         AND   arl.receivables_invoice_id > 0
         --AND   (lsm.pay_status_code is NULL OR lsm.pay_status_code = 'ERROR')
         --start fix for bug 5040815 by pgomes 24-mar-2006
         AND   arl.sty_id NOT IN (SELECT id FROM okl_strm_type_v
                                  WHERE stream_type_purpose in ('LATE_FEE', 'LATE_INTEREST'))
         --end fix for bug 5040815 by pgomes 24-mar-2006
        --rkuttiya R12 B Billing Architecture commented the following
         --AND   lsm.lln_id = lln.id
         --AND   lln.cnr_id = cnr.id
         --AND   cnr.trx_status_code = 'PROCESSED'
         AND til.tai_id = tai.id
         AND til.id = arl.til_id_details
         AND tai.trx_status_code = 'PROCESSED'
-- 05/31/07 ansethur added for R12B Billing architecture Passthrough impacts starts
         AND til.id = tld.til_id_details
         AND (tld.pay_status_code IS NULL OR tld.pay_status_code = 'ERROR')
-- 05/31/07 ansethur added for R12B Billing architecture Passthrough impacts ends
         AND arv.invoice_id = arl.receivables_invoice_id
         --added for evergreen change request 08_nov_2005
         AND   kle.lse_id = lse.id
         --commented for evergreen change request 08_nov_2005
         --AND   kle.id = pph.cle_id
         AND   kle.dnz_chr_id = pph.dnz_chr_id
         AND   pph.payout_basis = 'PARTIAL_RECEIPT'
         AND   okl_pay_invoices_disb_pvt.partial_receipt_amount(arl.receivables_invoice_id) <> 0
         AND   trunc(arv.date_consolidated) >= trunc(NVL(pph.passthru_start_date, arv.date_consolidated))
         AND   (trunc(arv.date_consolidated) <= trunc(kle.end_date) AND pph.passthru_term = 'BASE'
                --added for evergreen change request 08_nov_2005
                AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'BASE') = pph.id
                OR
                trunc(arv.date_consolidated) > trunc(kle.end_date) AND pph.passthru_term = 'EVERGREEN'
                --added for evergreen change request 08_nov_2005
                AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'EVERGREEN') = pph.id)
         AND   arl.receivables_invoice_id = aps.customer_trx_id
         AND   aps.class = 'INV'
         AND   trunc(arv.date_consolidated) BETWEEN NVL (TRUNC(p_from_date), SYSDATE-10000)
                                     AND 	   NVL (TRUNC(p_to_date), SYSDATE+10000)
         UNION ALL
         SELECT
             NULL cnr_id
            ,arl.receivables_invoice_number
            ,tai.set_of_books_id
            ,arv.org_id
            ,okl_pay_invoices_disb_pvt.partial_receipt_date(arl.receivables_invoice_id) partial_receipt_date
            ,arv.currency_code
            ,tai.khr_id
            ,til.kle_id
            ,okl_pay_invoices_disb_pvt.partial_receipt_amount(arl.receivables_invoice_id) amount
            ,arl.sty_id
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts starts
--          ,arl.id lsm_id
            ,tld.id  tld_id
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts ends
            ,arl.receivables_invoice_id
            , null sel_id
            ,pph.id pph_id
            ,NVL(pph.passthru_stream_type_id, arl.sty_id) passthru_stream_type_id
            ,pph.payout_basis
            ,null payout_basis_formula
            ,khr.contract_number
 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity
            ,tai.legal_entity_id
         FROM okc_k_headers_b khr
             ,okc_k_lines_b kle
             ,okc_k_lines_b sub_kle
             --added for evergreen change request 08_nov_2005
             ,okc_line_styles_b lse
             ,okl_bpd_ar_inv_lines_v arl
             ,okl_bpd_ar_invoices_v arv
             ,okl_trx_ar_invoices_v tai
             ,okl_txl_ar_inv_lns_v til
-- 05/31/07 ansethur added for R12B Billing architecture Passthrough impacts starts
             ,okl_txd_ar_ln_dtls_b tld
-- 05/31/07 ansethur added for R12B Billing architecture Passthrough impacts ends
             ,okl_party_payment_hdr pph
             ,ar_payment_schedules_all aps
         WHERE khr.contract_number = NVL(p_contract_number, khr.contract_number)
         AND   khr.id = sub_kle.dnz_chr_id
         AND   sub_kle.chr_id is null
         AND   sub_kle.id = til.kle_id
         AND   arl.receivables_invoice_id > 0
         --start fix for bug 5040815 by pgomes 24-mar-2006
         AND   arl.sty_id NOT IN (SELECT id FROM okl_strm_type_v
                                  WHERE stream_type_purpose in ('LATE_FEE', 'LATE_INTEREST'))
         --end fix for bug 5040815 by pgomes 24-mar-2006
         --AND   (lsm.pay_status_code is NULL OR lsm.pay_status_code = 'ERROR')
        --rkuttiya R12 B Billing Architecture commented out following
         --AND   lsm.lln_id = lln.id
         --AND   lln.cnr_id = cnr.id
         --AND   cnr.trx_status_code = 'PROCESSED'
         --rkuttiya R12 B BIlling Architecture added following
           AND til.tai_id = tai.id
           AND til.id = arl.til_id_details
           AND tai.trx_status_code = 'PROCESSED'
-- 05/31/07 ansethur added for R12B Billing architecture Passthrough impacts starts
         AND til.id = tld.til_id_details
         AND (tld.pay_status_code IS NULL OR tld.pay_status_code = 'ERROR')
-- 05/31/07 ansethur added for R12B Billing architecture Passthrough impacts ends
           AND arv.invoice_id = arl.receivables_invoice_id
         --
         AND   khr.id = kle.chr_id
         AND   sub_kle.cle_id = kle.id
         --added for evergreen change request 08_nov_2005
         AND   kle.lse_id = lse.id
         --commented for evergreen change request 08_nov_2005
         --AND   kle.id = pph.cle_id
         AND   kle.dnz_chr_id = pph.dnz_chr_id
         AND   pph.payout_basis = 'PARTIAL_RECEIPT'
         AND   okl_pay_invoices_disb_pvt.partial_receipt_amount(arl.receivables_invoice_id) <> 0
         AND   trunc(arv.date_consolidated) >= trunc(NVL(pph.passthru_start_date, arv.date_consolidated))
         AND   (trunc(arv.date_consolidated) <= trunc(kle.end_date) AND pph.passthru_term = 'BASE'
                --added for evergreen change request 08_nov_2005
                AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'BASE') = pph.id
                OR
                trunc(arv.date_consolidated) > trunc(kle.end_date) AND pph.passthru_term = 'EVERGREEN'
                --added for evergreen change request 08_nov_2005
                AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'EVERGREEN') = pph.id)
         AND   arl.receivables_invoice_id = aps.customer_trx_id
         AND   aps.class = 'INV'
         AND   trunc(arv.date_consolidated) BETWEEN NVL (TRUNC(p_from_date), SYSDATE-10000)
                                     AND 	   NVL (TRUNC(p_to_date), SYSDATE+10000);

	--------------------------------------------------------------------
	--Declare Cursor: Stream elements eligible for disbursement with
  --payout_basis = 'DUE DATE' ,passthru_term = 'BASE'
  --for top lines, sub lines
	--------------------------------------------------------------------
  CURSOR c_pay_sel(p_from_date DATE, p_to_date DATE, p_contract_number VARCHAR2)
  IS
    SELECT  null cnr_id,
            null consolidated_invoice_number,
            hou.set_of_books_id,
            khr.authoring_org_id org_id,
            ste.stream_element_date,
            khr.currency_code    currency_code,
            stm.khr_id         khr_id,
            stm.kle_id             kle_id,
            ste.amount             amount,
            stm.sty_id             sty_id,
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts starts
--          null lsm_id,
            null  tld_id,
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts ends
            null                   receivables_invoice_id,
            ste.id                 sel_id,
            pph.id  pph_id,
            NVL(pph.passthru_stream_type_id, stm.sty_id) passthru_stream_type_id,
            pph.payout_basis,
            null payout_basis_formula,
            khr.contract_number,
 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity
            khl.legal_entity_id
       FROM    okl_strm_elements        ste,
            okl_streams                stm,
            okl_strm_type_v            sty,
            okc_k_headers_b            khr,
            okl_k_headers            khl,
            hr_operating_units       hou,
            okc_k_lines_b            kle,
            --added for evergreen change request 08_nov_2005
            okc_line_styles_b lse,
            okc_statuses_b            khs,
            okc_statuses_b            kls,
            okl_party_payment_hdr pph
        WHERE    trunc(ste.stream_element_date)        >=
                 trunc(NVL (p_from_date,    ste.stream_element_date))
        AND      trunc(ste.stream_element_date)        <=
                 trunc((NVL (p_to_date,    SYSDATE) ))
        AND    ste.amount             <> 0
        AND    stm.id                = ste.stm_id
        AND    ste.date_disbursed       IS NULL
        AND    stm.active_yn        = 'Y'
        AND    stm.say_code        = 'CURR'
         --start fix for bug 5040815 by pgomes 24-mar-2006
         AND   stm.sty_id NOT IN (SELECT id FROM okl_strm_type_v
                                  WHERE stream_type_purpose in ('LATE_FEE', 'LATE_INTEREST'))
         --end fix for bug 5040815 by pgomes 24-mar-2006
        AND    sty.id                = stm.sty_id
        AND    sty.billable_yn        = 'Y'
        AND    khr.id                = stm.khr_id
        AND    khr.scs_code        IN ('LEASE', 'LOAN')
        AND    khr.sts_code        IN ( 'BOOKED','TERMINATED')
        AND    khr.authoring_org_id = hou.organization_id
        AND    khr.contract_number    = NVL(p_contract_number, khr.contract_number)
        AND    khl.id                = stm.khr_id
        AND    khl.deal_type        IS NOT NULL
        AND    khs.code             = khr.sts_code
        AND    kle.id               = stm.kle_id
        AND    kle.sts_code         = kls.code
        AND    NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED')
        --added for evergreen change request 08_nov_2005
        AND    kle.lse_id = lse.id
        --commented for evergreen change request 08_nov_2005
        --AND    kle.id = pph.cle_id
        AND    kle.dnz_chr_id = pph.dnz_chr_id
        --added for evergreen change request 08_nov_2005
        AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'BASE') = pph.id
        AND    pph.payout_basis = 'DUE_DATE'
        AND    trunc(ste.stream_element_date) >= trunc(NVL(pph.passthru_start_date, ste.stream_element_date))
        AND    trunc(ste.stream_element_date) <= trunc(kle.end_date)
        AND    pph.passthru_term = 'BASE'
        UNION ALL
        SELECT  null cnr_id,
            null consolidated_invoice_number,
            hou.set_of_books_id,
            khr.authoring_org_id org_id,
            ste.stream_element_date,
            khr.currency_code    currency_code,
            stm.khr_id         khr_id,
            stm.kle_id             kle_id,
            ste.amount             amount,
            stm.sty_id             sty_id,
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts starts
--          null lsm_id,
            null  tld_id,
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts ends
            null                   receivables_invoice_id,
            ste.id                 sel_id,
            pph.id pph_id,
            NVL(pph.passthru_stream_type_id, stm.sty_id) passthru_stream_type_id,
            pph.payout_basis,
            null payout_basis_formula,
            khr.contract_number,
 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity
            khl.legal_entity_id
       FROM    okl_strm_elements        ste,
            okl_streams                stm,
            okl_strm_type_v            sty,
            okc_k_headers_b            khr,
            okl_k_headers            khl,
            hr_operating_units       hou,
            okc_k_lines_b            kle,
            okc_k_lines_b         sub_kle,
            --added for evergreen change request 08_nov_2005
            okc_line_styles_b lse,
            okc_statuses_b            khs,
            okc_statuses_b            kls,
            okl_party_payment_hdr pph
        WHERE    trunc(ste.stream_element_date)        >=
                 trunc(NVL (p_from_date,    ste.stream_element_date))
        AND      trunc(ste.stream_element_date)        <=
                 trunc((NVL (p_to_date,    SYSDATE) ))
        AND    ste.amount             <> 0
        AND    stm.id                = ste.stm_id
        AND    ste.date_disbursed       IS NULL
        AND    stm.active_yn        = 'Y'
        AND    stm.say_code        = 'CURR'
         --start fix for bug 5040815 by pgomes 24-mar-2006
         AND   stm.sty_id NOT IN (SELECT id FROM okl_strm_type_v
                                  WHERE stream_type_purpose in ('LATE_FEE', 'LATE_INTEREST'))
         --end fix for bug 5040815 by pgomes 24-mar-2006
        AND    sty.id                = stm.sty_id
        AND    sty.billable_yn        = 'Y'
        AND    khr.id                = stm.khr_id
        AND    khr.scs_code        IN ('LEASE', 'LOAN')
        AND    khr.sts_code        IN ( 'BOOKED','TERMINATED')
        AND    khr.authoring_org_id = hou.organization_id
        AND    khr.contract_number    = NVL(p_contract_number, khr.contract_number)
        AND    khl.id                = stm.khr_id
        AND    khl.deal_type        IS NOT NULL
        AND    khs.code             = khr.sts_code
        AND    khr.id = sub_kle.dnz_chr_id
        AND    sub_kle.chr_id IS NULL
        AND    sub_kle.id               = stm.kle_id
        AND    sub_kle.cle_id = kle.id
        AND    kle.sts_code         = kls.code
        AND    NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED')
        --added for evergreen change request 08_nov_2005
        AND    kle.lse_id = lse.id
        --commented for evergreen change request 08_nov_2005
        --AND    kle.id = pph.cle_id
        AND    kle.dnz_chr_id = pph.dnz_chr_id
        --added for evergreen change request 08_nov_2005
        AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'BASE') = pph.id
        AND    pph.payout_basis = 'DUE_DATE'
        AND    trunc(ste.stream_element_date) >= trunc(NVL(pph.passthru_start_date, ste.stream_element_date))
        AND    trunc(ste.stream_element_date) <= trunc(kle.end_date)
        AND    pph.passthru_term = 'BASE';

	--------------------------------------------------------------------
	--Declare Cursor: Contract Lines eligible for disbursement with
  --payout_basis = 'FORMULA' ,passthru_term = 'EVERGREEN'
  --for top lines
	--------------------------------------------------------------------
  CURSOR c_pay_formula(p_from_date DATE, p_to_date DATE, p_contract_number VARCHAR2)
  IS
   SELECT     null cnr_id,
                  null consolidated_invoice_number,
                  hou.set_of_books_id,
                  okch.authoring_org_id org_id,
                  kle.start_date transaction_date,
                  okch.currency_code,
                  oklh.id khr_id,
                  kle.id kle_id,
                  null amount,
                  null sty_id,
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts starts
--                null lsm_id
                  null  tld_id,
-- 05/31/07 ansethur changes for R12B Billing architecture Passthrough impacts ends
                  null receivables_invoice_id,
                  null sel_id,
                  pph.id pph_id,
                  pph.passthru_stream_type_id,
                  pph.payout_basis,
                  pph.payout_basis_formula,
                  okch.contract_number,
 -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity
                  oklh.legal_entity_id
   FROM     okl_k_headers	  oklh,
            okc_k_headers_b   okch,
            hr_operating_units       hou,
            okc_k_lines_b     kle,
            --added for evergreen change request 08_nov_2005
            okc_line_styles_b lse,
            okl_party_payment_hdr pph
		   WHERE  oklh.id 			    = okch.id
		   AND    okch.contract_number	= NVL (p_contract_number,	okch.contract_number)
		   AND	  okch.scs_code			IN ('LEASE', 'LOAN')
		   AND    okch.sts_code 		= 'EVERGREEN'
       AND    oklh.deal_type  IS NOT NULL
       AND    okch.authoring_org_id = hou.organization_id
       AND    oklh.id = kle.dnz_chr_id
       AND    kle.sts_code =  'EVERGREEN'
       --added for evergreen change request 08_nov_2005
       AND    kle.lse_id = lse.id
       AND    kle.dnz_chr_id = pph.dnz_chr_id
       --added for evergreen change request 08_nov_2005
       AND    OKL_PAY_INVOICES_DISB_PVT.get_kle_party_pmt_hdr(kle.dnz_chr_id,kle.id,lse.lty_code,'EVERGREEN') = pph.id
       --commented for evergreen change request 08_nov_2005
       --AND    kle.id = pph.cle_id
       AND    pph.passthru_term = 'EVERGREEN'
       AND    pph.payout_basis = 'FORMULA';

  l_disb_tbl disb_tbl_type;

  L_FETCH_SIZE    NUMBER := 10000;
BEGIN
    ------------------------------------------------------------
    -- Start processing
    ------------------------------------------------------------
    print_line ( '=====*** START PROCEDURE AUTO_DISBURSEMENT ***=====');

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_return_status := OKL_API.START_ACTIVITY(
      p_api_name	    => l_api_name,
     	p_pkg_name	    => g_pkg_name,
  		p_init_msg_list	=> p_init_msg_list,
		  l_api_version	=> l_api_version,
  		p_api_version	=> p_api_version,
  		p_api_type  	=> '_PVT',
  		x_return_status	=> l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		  RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    G_commit_count := 0;

    ------------------------------------------------------------
    -- Open Billing Cursor
 	  ------------------------------------------------------------
    print_line ('==============================================');
    print_line ('=> Start - Processing payout basis of BILLING.');
    print_line ('==============================================');
    OPEN c_invoice_bill(p_from_date, p_to_date, p_contract_number);
    LOOP
    ------------------------------
    --Clear table contents
    ------------------------------
    l_disb_tbl.delete;
    FETCH c_invoice_bill BULK COLLECT INTO l_disb_tbl LIMIT L_FETCH_SIZE;
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'c_invoice_bill l_disb_tbl count is: '||l_disb_tbl.COUNT);

    IF l_disb_tbl.COUNT > 0 THEN
      auto_disbursement_tbl(p_api_version	=> p_api_version
      	,p_init_msg_list	=> p_init_msg_list
      	,x_return_status => x_return_status
      	,x_msg_count => x_msg_count
      	,x_msg_data => x_msg_data
        ,p_disb_tbl => l_disb_tbl);
    END IF;

    EXIT WHEN c_invoice_bill%NOTFOUND;
    END LOOP;
    CLOSE c_invoice_bill;
    ------------------------------------------------------------
    -- Close Billing Cursor
 	  ------------------------------------------------------------
    print_line ('==============================================');
    print_line ('=> End - Processing payout basis of BILLING.');
    print_line ('==============================================');
    print_line (' ');

    ------------------------------------------------------------
    -- Open Full Receipt Cursor
 	  ------------------------------------------------------------
    print_line ('==============================================');
    print_line ('=> Start - Processing payout basis of FULL_RECEIPT.');
    print_line ('==============================================');
    OPEN c_invoice_full_rcpt(p_from_date, p_to_date, p_contract_number);
    LOOP
    ------------------------------
    --Clear table contents
    ------------------------------
    l_disb_tbl.delete;
    FETCH c_invoice_full_rcpt BULK COLLECT INTO l_disb_tbl LIMIT L_FETCH_SIZE;
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'c_invoice_full_rcpt l_disb_tbl count is: '||l_disb_tbl.COUNT);

    IF l_disb_tbl.COUNT > 0 THEN
      auto_disbursement_tbl(p_api_version	=> p_api_version
      	,p_init_msg_list	=> p_init_msg_list
      	,x_return_status => x_return_status
      	,x_msg_count => x_msg_count
      	,x_msg_data => x_msg_data
        ,p_disb_tbl => l_disb_tbl);
    END IF;

    EXIT WHEN c_invoice_full_rcpt%NOTFOUND;
    END LOOP;
    CLOSE c_invoice_full_rcpt;
    ------------------------------------------------------------
    -- Close Full Receipt Cursor
 	  ------------------------------------------------------------
    print_line ('==============================================');
    print_line ('=> End - Processing payout basis of FULL_RECEIPT.');
    print_line ('==============================================');
    print_line (' ');

    ------------------------------------------------------------
    -- Open Partial Receipt Cursor
 	  ------------------------------------------------------------
    print_line ('==============================================');
    print_line ('=> Start - Processing payout basis of PARTIAL_RECEIPT.');
    print_line ('==============================================');
    OPEN c_invoice_part_rcpt(p_from_date, p_to_date, p_contract_number);
    LOOP
    ------------------------------
    --Clear table contents
    ------------------------------
    l_disb_tbl.delete;
    FETCH c_invoice_part_rcpt BULK COLLECT INTO l_disb_tbl LIMIT L_FETCH_SIZE;
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'c_invoice_part_rcpt l_disb_tbl count is: '||l_disb_tbl.COUNT);

    IF l_disb_tbl.COUNT > 0 THEN
      auto_disbursement_tbl(p_api_version	=> p_api_version
      	,p_init_msg_list	=> p_init_msg_list
      	,x_return_status => x_return_status
      	,x_msg_count => x_msg_count
      	,x_msg_data => x_msg_data
        ,p_disb_tbl => l_disb_tbl);
    END IF;

    EXIT WHEN c_invoice_part_rcpt%NOTFOUND;
    END LOOP;
    CLOSE c_invoice_part_rcpt;
    ------------------------------------------------------------
    -- Close Partial Receipt Cursor
 	  ------------------------------------------------------------
    print_line ('==============================================');
    print_line ('=> End - Processing payout basis of PARTIAL_RECEIPT.');
    print_line ('==============================================');
    print_line (' ');

    ------------------------------------------------------------
    -- Open Due Date Cursor
 	  ------------------------------------------------------------
    print_line ('==============================================');
    print_line ('=> Start - Processing payout basis of DUE DATE.');
    print_line ('==============================================');
    OPEN c_pay_sel(p_from_date, p_to_date, p_contract_number);
    LOOP
    ------------------------------
    --Clear table contents
    ------------------------------
    l_disb_tbl.delete;
    FETCH c_pay_sel BULK COLLECT INTO l_disb_tbl LIMIT L_FETCH_SIZE;
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'c_pay_sel l_disb_tbl count is: '||l_disb_tbl.COUNT);

    IF l_disb_tbl.COUNT > 0 THEN
      auto_disbursement_tbl(p_api_version	=> p_api_version
      	,p_init_msg_list	=> p_init_msg_list
      	,x_return_status => x_return_status
      	,x_msg_count => x_msg_count
      	,x_msg_data => x_msg_data
        ,p_disb_tbl => l_disb_tbl);
    END IF;

    EXIT WHEN c_pay_sel%NOTFOUND;
    END LOOP;
    CLOSE c_pay_sel;
    ------------------------------------------------------------
    -- Close Due Date Cursor
 	  ------------------------------------------------------------
    print_line ('==============================================');
    print_line ('=> End - Processing payout basis of DUE DATE.');
    print_line ('==============================================');
    print_line (' ');

    ------------------------------------------------------------
    -- Open Formula Cursor
 	  ------------------------------------------------------------
    print_line ('==============================================');
    print_line ('=> Start - Processing payout basis of FORMULA.');
    print_line ('==============================================');
    OPEN c_pay_formula(p_from_date, p_to_date, p_contract_number);
    LOOP
    ------------------------------
    --Clear table contents
    ------------------------------
    l_disb_tbl.delete;
    FETCH c_pay_formula BULK COLLECT INTO l_disb_tbl LIMIT L_FETCH_SIZE;
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'c_pay_formula l_disb_tbl count is: '||l_disb_tbl.COUNT);

    IF l_disb_tbl.COUNT > 0 THEN
      auto_disbursement_tbl(p_api_version	=> p_api_version
      	,p_init_msg_list	=> p_init_msg_list
      	,x_return_status => x_return_status
      	,x_msg_count => x_msg_count
      	,x_msg_data => x_msg_data
        ,p_disb_tbl => l_disb_tbl);
    END IF;

    EXIT WHEN c_pay_formula%NOTFOUND;
    END LOOP;
    CLOSE c_pay_formula;
    ------------------------------------------------------------
    -- Close Formula Cursor
 	  ------------------------------------------------------------
    print_line ('==============================================');
    print_line ('=> End - Processing payout basis of FORMULA.');
    print_line ('==============================================');
    print_line (' ');

    COMMIT;
    print_line ( '=====*** EXITING PROCEDURE AUTO_DISBURSEMENT ***=====');

    okl_api.end_activity(x_msg_count => x_msg_count
                      ,x_msg_data => x_msg_data);
EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN OKL_API.G_EXCEPTION_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');


END auto_disbursement;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : credit_check
-- Description     : Calculate total remaining total for a specific credit line
--                   This credit line may attach to MLAs (Master Lease Agreement)
--                   or other type of contracts.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
FUNCTION credit_check(p_api_version             IN  NUMBER
        ,p_init_msg_list        IN  VARCHAR2
        ,x_return_status        OUT NOCOPY VARCHAR2
        ,x_msg_count            OUT NOCOPY NUMBER
        ,x_msg_data                 OUT NOCOPY VARCHAR2
        ,p_creditline_id   IN  NUMBER
        ,p_credit_max       IN  NUMBER
    ,P_trx_date         IN DATE)
    RETURN NUMBER IS

    l_credit_remain       NUMBER := 0;
    l_disbursement_tot    NUMBER := 0;
    l_is_revolving_credit BOOLEAN := false;
    l_dummy               NUMBER;
    l_principal_tot       NUMBER := 0;

-- sjalasut, modified the cursor to have khr_id referred to okl_txl_ap_inv_lns_all_b
-- instead of okl_trx_ap_invoices_b. changes made as part of OKLR12B disbursements
-- project.
cursor c_disb_tot(p_creditline_id number) is
  SELECT NVL(SUM(NVL(TAP.AMOUNT,0)),0)
FROM   OKL_TRX_AP_INVOICES_B TAP
      ,OKL_TXL_AP_INV_LNS_ALL_B TPL
WHERE  TAP.ID = TPL.TAP_ID
   AND TAP.TRX_STATUS_CODE = 'PROCESSED' -- push to AP
AND    TRUNC(DATE_INVOICED) <= TRUNC(p_trx_date)
AND
( EXISTS
 (
-- indirect refer from MLA contract's credit line
  SELECT 1 -- op chrid
  FROM   OKC_K_HEADERS_ALL_B KHR_OP
  WHERE  KHR_OP.ID = TPL.KHR_ID -- link
  AND EXISTS (
       SELECT 1 -- MLA id
       FROM  OKC_K_HEADERS_ALL_B KHR,
             OKC_GOVERNANCES MLA_GOV
       WHERE KHR.ID = MLA_GOV.CHR_ID_REFERRED
       AND   KHR.SCS_CODE = 'MASTER_LEASE'
       AND   MLA_GOV.DNZ_CHR_ID = KHR_OP.ID -- link
       AND EXISTS (
            SELECT 1 -- credit line id
            FROM   OKC_K_HEADERS_ALL_B CRD,
                   OKC_GOVERNANCES CRD_GOV
            WHERE  CRD.ID = CRD_GOV.CHR_ID_REFERRED
            AND    CRD.STS_CODE = 'ACTIVE'
            AND    KHR.ID = CRD_GOV.DNZ_CHR_ID -- link
            AND    CRD.ID = p_creditline_id
           )
      )
  )
 OR
  EXISTS
 (
-- non-MLA contracts direct associated with credit line
  SELECT 1 -- op chrid
  FROM   OKC_K_HEADERS_ALL_B KHR
  WHERE  KHR.ID = TPL.KHR_ID -- link
  AND    KHR.SCS_CODE <> 'MASTER_LEASE'
  AND EXISTS (
       SELECT 1 -- credit line id
       FROM   OKC_K_HEADERS_ALL_B CRD,
              OKC_GOVERNANCES CRD_GOV
       WHERE  CRD.ID = CRD_GOV.CHR_ID_REFERRED
       AND    CRD.STS_CODE = 'ACTIVE'
       AND    KHR.ID = CRD_GOV.DNZ_CHR_ID -- link
       AND    CRD.ID = p_creditline_id
      )
 )
)
;

cursor c_is_revolv_crd(p_creditline_id number) is
  select 1 -- Revloving line of credit line
from   okl_k_headers REV
where  rev.id = p_creditline_id
and    REV.REVOLVING_CREDIT_YN = 'Y'
;

cursor c_princ_tot(p_creditline_id number) is
SELECT
  NVL(SUM(NVL(PS.AMOUNT_APPLIED,0)),0)
FROM
  AR_PAYMENT_SCHEDULES_ALL PS,
  --rkuttiya R12 B Billing Architecture commented
  --OKL_CNSLD_AR_STRMS_B ST,
    okl_bpd_ar_inv_lines_v ST,
  --OKL_STRM_TYPE_TL SM,
  okl_strm_type_v SM,
  OKC_K_HEADERS_B CN
WHERE
  PS.CLASS IN ('INV') AND
  ST.INVOICE_ID = PS.CUSTOMER_TRX_ID AND
  SM.ID = ST.STY_ID AND
  --SM.LANGUAGE = USERENV ('LANG') AND
  CN.ID = ST.CONTRACT_ID     AND
  --SM.NAME = 'PRINCIPAL PAYMENT' AND
  SM.stream_type_purpose = 'PRINCIPAL_PAYMENT' AND
  TRUNC(NVL(PS.TRX_DATE, SYSDATE)) <= TRUNC(p_trx_date)
AND
( EXISTS
 (
-- indirect refer from MLA contract's credit line
  SELECT 1 -- op chrid
  FROM   OKC_K_HEADERS_ALL_B KHR_OP
  WHERE  KHR_OP.ID = CN.ID -- link
  AND EXISTS (
       SELECT 1 -- MLA id
       FROM  OKC_K_HEADERS_ALL_B KHR,
             OKC_GOVERNANCES MLA_GOV
       WHERE KHR.ID = MLA_GOV.CHR_ID_REFERRED
       AND   KHR.SCS_CODE = 'MASTER_LEASE'
       AND   MLA_GOV.DNZ_CHR_ID = KHR_OP.ID -- link
       AND EXISTS (
            SELECT 1 -- credit line id
            FROM   OKC_K_HEADERS_ALL_B CRD,
                   OKC_GOVERNANCES CRD_GOV
            WHERE  CRD.ID = CRD_GOV.CHR_ID_REFERRED
            AND    CRD.STS_CODE = 'ACTIVE'
            AND    KHR.ID = CRD_GOV.DNZ_CHR_ID -- link
            AND    CRD.ID = p_creditline_id
           )
      )
  )
 OR
  EXISTS
 (
-- non-MLA contracts direct associated with credit line
  SELECT 1 -- op chrid
  FROM   OKC_K_HEADERS_ALL_B KHR
  WHERE  KHR.ID = CN.ID -- link
  AND    KHR.SCS_CODE <> 'MASTER_LEASE'
  AND EXISTS (
       SELECT 1 -- credit line id
       FROM   OKC_K_HEADERS_ALL_B CRD,
              OKC_GOVERNANCES CRD_GOV
       WHERE  CRD.ID = CRD_GOV.CHR_ID_REFERRED
       AND    CRD.STS_CODE = 'ACTIVE'
       AND    KHR.ID = CRD_GOV.DNZ_CHR_ID -- link
       AND    CRD.ID = p_creditline_id
      )
 )
)
;


begin

  OPEN c_disb_tot(p_creditline_id);
  FETCH c_disb_tot into l_disbursement_tot;
  CLOSE c_disb_tot;

  OPEN c_is_revolv_crd(p_creditline_id);
  FETCH c_is_revolv_crd into l_dummy;
  l_is_revolving_credit := c_is_revolv_crd%FOUND;
  CLOSE c_is_revolv_crd;

  IF (l_is_revolving_credit) THEN

    OPEN c_princ_tot(p_creditline_id);
    FETCH c_princ_tot into l_principal_tot;
    CLOSE c_princ_tot;

    l_credit_remain := p_credit_max - l_disbursement_tot + l_principal_tot;
  ELSE
    l_credit_remain := p_credit_max - l_disbursement_tot;
  END IF;

  x_return_status := okl_api.G_RET_STS_SUCCESS;
  RETURN l_credit_remain;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      RETURN NULL;


END credit_check;


END OKL_PAY_INVOICES_DISB_PVT;

/
