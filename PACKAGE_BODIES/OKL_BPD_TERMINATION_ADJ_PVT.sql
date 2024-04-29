--------------------------------------------------------
--  DDL for Package Body OKL_BPD_TERMINATION_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BPD_TERMINATION_ADJ_PVT" AS
/* $Header: OKLRBAJB.pls 120.17.12010000.5 2010/03/17 12:04:28 nikshah ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------


  PROCEDURE create_debit_memo(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_sel_id                   IN NUMBER,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) IS

     l_return_status            VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'create_debit_memo';

    -----------------------------------------------------------------
  	-- Declare Process Variable
  	-----------------------------------------------------------------
  	l_okl_application_id NUMBER(3) := 540;
  	l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';
  	lx_dbseqnm          VARCHAR2(2000):= '';
  	lx_dbseqid          NUMBER(38):= NULL;

  	------------------------------------------------------------
  	-- Declare records: Payable Invoice Headers, Lines and Distributions
  	------------------------------------------------------------
  	l_tapv_rec              okl_tap_pvt.tapv_rec_type;
  	lx_tapv_rec     	      okl_tap_pvt.tapv_rec_type;
  	l_tplv_rec     	        okl_tpl_pvt.tplv_rec_type;
  	lx_tplv_rec     	      okl_tpl_pvt.tplv_rec_type;

   /* ankushar 22-JAN-2007
       added table definitions
       start changes
   */
   l_tplv_tbl     	        okl_tpl_pvt.tplv_tbl_type;
  	lx_tplv_tbl     	      okl_tpl_pvt.tplv_tbl_type;
   /* ankushar end changes*/

  	l_tmpl_identify_rec     Okl_Account_Dist_Pvt.TMPL_IDENTIFY_REC_TYPE;
  	l_dist_info_rec         Okl_Account_Dist_Pvt.dist_info_REC_TYPE;
  	l_ctxt_val_tbl          okl_execute_formula_pvt.ctxt_val_tbl_type;
  	l_acc_gen_primary_key_tbl  Okl_Account_Generator_Pvt.primary_key_tbl;
  	l_template_tbl         	OKL_TMPT_SET_PUB.avlv_tbl_type;
  	l_amount_tbl            Okl_Account_Dist_Pvt.AMOUNT_TBL_TYPE;

    lu_tapv_rec              Okl_tap_pvt.tapv_rec_type;
    lux_tapv_rec             Okl_tap_pvt.tapv_rec_type;

    -- sjalasut, commented the subtype declaration. changed the usages to point
    -- to the table.column names.
    -- SUBTYPE khr_id_type IS okl_k_headers_full_v.id%type;
    l_khr_id okc_k_headers_b.id%TYPE;
    l_currency_code okl_k_headers_full_v.currency_code%type;
    l_currency_conversion_type okl_k_headers_full_v.currency_conversion_type%type;
    l_currency_conversion_rate okl_k_headers_full_v.currency_conversion_rate%type;
    l_currency_conversion_date okl_k_headers_full_v.currency_conversion_date%type;

    l_created_tap BOOLEAN := TRUE;
    l_created_tpl BOOLEAN := TRUE;
    l_created_dist BOOLEAN := TRUE;

	  -- Update Pay Status
--	  u_lsmv_rec	  Okl_Cnsld_Ar_Strms_Pub.lsmv_rec_type; -- rmunjulu R12 Billing Fixes: commented
--	  r_lsmv_rec	  Okl_Cnsld_Ar_Strms_Pub.lsmv_rec_type;	-- rmunjulu R12 Billing Fixes: commented

-- rmunjulu R12 Billing Fixes: added new variables
    l_tldv_rec  okl_txd_ar_ln_dtls_pub.tldv_rec_type;
    lx_tldv_rec okl_txd_ar_ln_dtls_pub.tldv_rec_type;

    CURSOR pdt_id_csr (p_khr_id NUMBER) IS
		   SELECT  khr.pdt_id
		   FROM    okl_k_headers khr
		   WHERE   khr.id =  p_khr_id;

    -- sjalasut, modified the below cursor to have khr_id be picked up from
    -- okl_txl_ap_inv_lns_v instead of okl_trx_ap_invoices_v
    -- changes made as part of OKLR12B disbursements project.
    CURSOR l_ap_inv_csr(cp_sel_id IN NUMBER) IS
     select tap.id tap_id
           ,tap.nettable_yn
           ,tap.wait_vendor_invoice_yn
           ,tap.ipvs_id
           ,tap.payment_method_code
           ,tap.ippt_id
           ,tap.pay_group_lookup_code
           ,tap.try_id
           ,tap.set_of_books_id
           ,tap.org_id tap_org
           ,tpl.khr_id
           ,tap.currency_code
           ,tap.currency_conversion_date
           ,tap.currency_conversion_rate
           ,tap.currency_conversion_type
           ,tap.trx_status_code
           ,tap.date_invoiced
           ,tap.date_entered
           ,tap.workflow_yn
           ,tap.invoice_type
           ,tap.amount tap_amount
           ,tap.invoice_number
           ,tap.invoice_category_code
           ,tap.vendor_invoice_number
           ,tap.date_gl
           ,tpl.id
           ,tpl.disbursement_basis_code
           ,tpl.amount
           ,tpl.org_id
           ,tpl.kle_id
           ,tpl.lsm_id
           ,tpl.sty_id
           ,tpl.line_number
           ,tpl.inv_distr_line_code
           ,tld.id tld_id  -- rmunjulu R12 Billing Fixes: added
 -- 02-NOV-2006 ANSETHUR  R12B - Legal Entity
           ,tap.legal_entity_id
     from -- okl_cnsld_ar_strms_v lsm -- rmunjulu R12 Billing Fixes: commented
          okl_trx_ap_invoices_v tap
        , okl_txl_ap_inv_lns_v tpl
        , okl_txd_ar_ln_dtls_b tld -- rmunjulu R12 Billing Fixes: added
     where tap.id = tpl.tap_id
     -- and tpl.lsm_id = lsm.id -- rmunjulu R12 Billing Fixes: commented
     and tpl.tld_id = tld.id -- rmunjulu R12 Billing Fixes: added
     and tld.sel_id = cp_sel_id -- rmunjulu R12 Billing Fixes: changed to use TLD
     and tld.pay_status_code = 'PROCESSED' -- rmunjulu R12 Billing Fixes: changed to use TLD
     and tld.amount > 0 -- rmunjulu R12 Billing Fixes: changed to use TLD
     and tap.trx_status_code in ('ENTERED', 'APPROVED', 'PROCESSED');

     CURSOR try_id_csr IS
     	   SELECT id
    	   FROM okl_trx_types_tl
    	   WHERE name = 'Debit Memo'
    	   AND language= 'US';

    --Get currency conversion attributes for a contract
    CURSOR l_curr_conv_csr(cp_khr_id IN okc_k_headers_b.id%TYPE) IS
    SELECT  currency_code
           ,currency_conversion_type
           ,currency_conversion_rate
           ,currency_conversion_date
    FROM    okl_k_headers_full_v
    WHERE   id = cp_khr_id;

    cnt NUMBER;
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts

    FOR cur IN l_ap_inv_csr(p_sel_id) LOOP
      -- sjalasut, added code to store khr_id in a local variable so that
      -- this local variable could be used in cursor and other assignments.
      l_khr_id := cur.khr_id ;

      ------------------------------------------------------------
      -- Insert Invoice Header
      ------------------------------------------------------------
      l_tapv_rec.tap_id_reverses := cur.tap_id;
      l_tapv_rec.nettable_yn := cur.nettable_yn;
      l_tapv_rec.ipvs_id := cur.ipvs_id;
      l_tapv_rec.payment_method_code := cur.payment_method_code;
      l_tapv_rec.ippt_id := cur.ippt_id;
      l_tapv_rec.pay_group_lookup_code := cur.pay_group_lookup_code;

      OPEN  try_id_csr;
      FETCH try_id_csr INTO l_tapv_rec.try_id;
      CLOSE try_id_csr;

      l_tapv_rec.set_of_books_id := cur.set_of_books_id;
      l_tapv_rec.org_id := cur.tap_org;
      -- sjalasut, commenting the below assignment because khr_id would now be
      -- captured at the tplv_rec (internal disbursement transaction lines entity)
      -- changes made as part of OKLR12B disbursements project
      -- l_tapv_rec.khr_id := cur.khr_id;
      l_tapv_rec.khr_id := NULL;
      l_tapv_rec.currency_code := cur.currency_code;
      l_tapv_rec.currency_conversion_date := cur.currency_conversion_date;
      l_tapv_rec.currency_conversion_rate := cur.currency_conversion_rate;
      l_tapv_rec.currency_conversion_type := cur.currency_conversion_type;
      l_tapv_rec.trx_status_code := 'ENTERED';
      l_tapv_rec.date_invoiced := trunc(SYSDATE);
      l_tapv_rec.date_entered := trunc(SYSDATE);
      l_tapv_rec.invoice_type := 'CREDIT';
      l_tapv_rec.amount  := cur.tap_amount;
      l_tapv_rec.workflow_yn := cur.workflow_yn;
      l_tapv_rec.wait_vendor_invoice_yn := cur.wait_vendor_invoice_yn;
 -- 02-NOV-2006 ANSETHUR  R12B - Legal Entity
      l_tapv_rec.legal_entity_id := cur.legal_entity_id;

      l_tapv_rec.invoice_number := fnd_seqnum.get_next_sequence
                                             (appid      =>  l_okl_application_id,
                                             cat_code    =>  l_document_category,
                                             sobid       =>  l_tapv_rec.set_of_books_id,
                                             met_code    =>  'A',
                                             trx_date    =>  SYSDATE,
                                             dbseqnm     =>  lx_dbseqnm,
                                             dbseqid     =>  lx_dbseqid);

      l_tapv_rec.vendor_invoice_number  := l_tapv_rec.invoice_number;

      l_tapv_rec.invoice_category_code := cur.invoice_category_code;
      l_tapv_rec.date_gl := l_tapv_rec.date_invoiced;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before create disbursement transactions');
      END IF;

      ------------------------------------------------------------
      -- Insert Invoice Line
      ------------------------------------------------------------
      l_tplv_rec.amount := cur.amount;
      l_tplv_rec.org_id := cur.org_id;
      l_tplv_rec.kle_id := cur.kle_id;
      l_tplv_rec.sty_id := cur.sty_id;
      l_tplv_rec.line_number := 1;
      -- sjalasut, added khr_id assignment to l_tplv_rec.
      -- changes made as part of OKLR12B disbursements project
      l_tplv_rec.khr_id := l_khr_id;

      /* ankushar 23-JAN-2007
         Call to the common Disbursement API
         start changes */

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
            l_created_tpl := FALSE;
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after create disbursement transaction, ap invoice header id : ' || lx_tapv_rec.id);
        END IF;
       /* ankushar end changes */

      --update lsm.pay_status_code with a status of REVERSED
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              -- OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'evaluating whether to update lsm with Reversed status'); -- rmunjulu R12 Billing Fixes: commented
-- rmunjulu R12 Billing Fixes
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'evaluating whether to update TLD with Reversed status');
      END IF;
      IF (l_created_tap AND l_created_tpl AND l_created_dist) THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  -- OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before updating lsm with Reversed status'); -- rmunjulu R12 Billing Fixes: commented
-- rmunjulu R12 Billing Fixes
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before updating TLD with Reversed status');
        END IF;

/* rmunjulu R12 Billing Fixes -- commented below code
	      u_lsmv_rec.id   				:= cur.lsm_id;
		    u_lsmv_rec.pay_status_code   := 'REVERSED';

		    Okl_Cnsld_Ar_Strms_Pub.update_cnsld_ar_strms
			     (p_api_version
			     ,p_init_msg_list
			     ,l_return_status
			     ,x_msg_count
			     ,x_msg_data
			     ,u_lsmv_rec
			     ,r_lsmv_rec);
*/
-- rmunjulu R12 Billing Fixes : start
            l_tldv_rec.id := cur.tld_id;
            l_tldv_rec.pay_status_code := 'REVERSED';  -- set the tld record to REVERSED status

		    okl_txd_ar_ln_dtls_pub.update_txd_ar_ln_dtls
			     (p_api_version   => p_api_version
			     ,p_init_msg_list => p_init_msg_list
			     ,x_return_status => l_return_status
			     ,x_msg_count     => x_msg_count
			     ,x_msg_data      => x_msg_data
			     ,p_tldv_rec      => l_tldv_rec
			     ,x_tldv_rec      => lx_tldv_rec);

-- rmunjulu R12 Billing Fixes : end
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  -- OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after updating lsm with Reversed status, Status : ' || l_return_status); -- rmunjulu R12 Billing Fixes: commented
-- rmunjulu R12 Billing Fixes
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after updating TLD with Reversed status, Status : ' || l_return_status);
        END IF;
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END LOOP;

    -- Processing ends

    x_return_status := l_return_status;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END create_debit_memo;

  ---------------------------------------------------------------------------

  FUNCTION get_kle_status_code(p_kle_id IN NUMBER) RETURN VARCHAR2 IS

     l_status_code OKC_STATUSES_B.CODE%TYPE := NULL;

     cursor l_kle_status_code_csr(cp_kle_id IN NUMBER) IS SELECT ste_code
     FROM   okc_k_lines_b kle,
           okc_statuses_b kls
     WHERE kle.id = cp_kle_id
     AND   kle.sts_code = kls.code;
  BEGIN
     if (p_kle_id IS NOT NULL) THEN
       open l_kle_status_code_csr(p_kle_id);
       fetch l_kle_status_code_csr INTO l_status_code;
       close l_kle_status_code_csr;
     else
       l_status_code := 'HEADER_LEVEL';
     end if;

     RETURN l_status_code;
  EXCEPTION
    WHEN OTHERS THEN
     RETURN l_status_code;
  END get_kle_status_code;

  ---------------------------------------------------------------------------

  PROCEDURE get_billing_adjust(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_input_tbl                IN input_tbl_type,
     x_baj_tbl                  OUT NOCOPY baj_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) IS

     l_return_status            VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'get_billing_adjust';

     l_input_rec                input_rec_type;
     l_input_tbl                input_tbl_type;

     l_baj_rec                  baj_rec_type;
     lx_baj_tbl                 baj_tbl_type;

     input_cnt                  NUMBER;
     baj_cnt                    NUMBER := 0;

     ------------------------------------------------
     --Billed Receivables for Credit Memo Application
     --For prior dated termination
     ------------------------------------------------
     cursor l_bill_adj_csr(cp_khr_id IN NUMBER, cp_kle_id IN NUMBER, cp_term_date_from IN DATE, cp_term_date_to IN DATE) IS
           SELECT stm.khr_id         khr_id,
           stm.kle_id                kle_id,
           TRUNC (ste.stream_element_date)    stream_element_date,
           ste.id                    sel_id,
           stm.id                    stm_id,
           stm.sty_id                sty_id,
           sty.name                  sty_name,
           ste.amount,
           ste.se_line_number,
           ste.source_id,
           ste.source_table
          FROM    okl_strm_elements   ste,
           okl_streams                stm,
           okl_strm_type_v            sty,
           okc_k_headers_b            khr,
           okl_k_headers              khl,
           okc_k_lines_b              kle,
           okc_statuses_b             khs
          WHERE  trunc(ste.stream_element_date)    >     trunc(nvl(cp_term_date_from, ste.stream_element_date))
          AND    trunc(ste.stream_element_date)    <=    trunc(nvl(cp_term_date_to, ste.stream_element_date))
          AND    ste.amount             <> 0
          AND    stm.id                = ste.stm_id
          AND    ste.date_billed        IS NOT NULL
          AND    stm.active_yn        = 'Y'
          AND    stm.say_code        = 'CURR'
          AND    sty.id                = stm.sty_id
          AND    sty.billable_yn        = 'Y'
          AND    khr.id                = stm.khr_id
          AND    khr.scs_code        IN ('LEASE', 'LOAN')
          AND    khr.sts_code        IN ( 'BOOKED','EVERGREEN')
          AND    khr.id                = cp_khr_id
          AND    khl.id                = stm.khr_id
          AND    khl.deal_type        IS NOT NULL
          AND    khs.code            = khr.sts_code
          AND    khs.ste_code        = 'ACTIVE'
          AND    stm.kle_id          = kle.id(+)
          AND    ((khr.sts_code = 'EVERGREEN' AND sty.STREAM_TYPE_PURPOSE <> 'ACTUAL_PROPERTY_TAX')
                   OR khr.sts_code <> 'EVERGREEN') -- Bug 9306259
          AND    nvl(stm.kle_id, -99) = nvl(cp_kle_id, nvl(stm.kle_id, -99))
          AND OKL_BPD_TERMINATION_ADJ_PVT.get_kle_status_code(stm.kle_id) IN  ('ACTIVE', 'TERMINATED', 'HEADER_LEVEL')
          ORDER    BY 1, 2, 3;
   -- akrangan bug 5655680  -- start
     --cursor to check if financial asset appears as linked asset
 	     CURSOR l_lnk_ast_csr (p_line_id  OKC_K_LINES_B.ID%TYPE) IS
 	     Select lnk.id link_kle_id
 	     --lnk.cle_id link_kle_id
 	     From   okc_k_lines_b lnk,
 	            okc_line_styles_b lnk_lse,
 	            okc_statuses_b sts,
 	            okc_k_items    cim
 	     Where  lnk.id = cim.cle_id
 	     and    lnk.dnz_chr_id = cim.dnz_chr_id
 	     and    lnk.lse_id = lnk_lse.id
 	     and    lnk_lse.lty_code in ('LINK_FEE_ASSET','LINK_SERV_ASSET')
 	     and    sts.code = lnk.sts_code
 	     and    sts.ste_code not in ('EXPIRED','TERMINATED','CANCELLED')
 	     and    cim.jtot_object1_code = 'OKX_COVASST'
 	     and    cim.object1_id1 = to_char(p_line_id)
 	     and    cim.object1_id2 = '#';
    --akrangan bug 5655680  -- end

     --Bug 7456516
     CURSOR GET_PRICING_DET_CSR(P_KHR_ID IN NUMBER) IS
       SELECT GTS.PRICING_ENGINE,
              GTS.ISG_ARREARS_PAY_DATES_OPTION
         FROM OKL_K_HEADERS KHR,
              OKL_PRODUCTS PDT,
              OKL_AE_TMPT_SETS_ALL AES,
              OKL_ST_GEN_TMPT_SETS_ALL GTS
        WHERE KHR.PDT_ID = PDT.ID
          AND PDT.AES_ID = AES.ID
          AND AES.GTS_ID = GTS.ID
          AND KHR.ID  = P_KHR_ID;

     CURSOR GET_PMNT_ARREAR_FLAG(P_KHR_ID IN NUMBER, P_KLE_ID IN NUMBER) IS
     SELECT RL.RULE_INFORMATION10
       FROM OKC_RULES_B RL,
            OKC_RULE_GROUPS_B RGP
      WHERE RL.RULE_INFORMATION_CATEGORY = 'LASLL'
        AND RL.RGP_ID = RGP.ID
        AND RGP.RGD_CODE = 'LALEVL'
        AND RGP.CLE_ID = P_KLE_ID
        AND RGP.DNZ_CHR_ID = P_KHR_ID
        AND ROWNUM < 2;

     l_pmnt_arrear_flag        VARCHAR2(1);
     l_term_date_flag          VARCHAR2(1);
     l_pricing_engine          OKL_ST_GEN_TMPT_SETS.PRICING_ENGINE%TYPE;
     l_int_arrears_pay_option  OKL_ST_GEN_TMPT_SETS.ISG_ARREARS_PAY_DATES_OPTION%TYPE;
     --end Bug 7456516

  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
    l_input_tbl := p_input_tbl;

    input_cnt := l_input_tbl.FIRST;
    WHILE (input_cnt IS NOT NULL)
    LOOP
      l_input_rec := l_input_tbl(input_cnt);

      --Bug 7456516
      OPEN GET_PRICING_DET_CSR(l_input_rec.khr_id);
      FETCH GET_PRICING_DET_CSR INTO l_pricing_engine, l_int_arrears_pay_option;
      CLOSE GET_PRICING_DET_CSR;

      l_term_date_flag := 'N';
      IF((l_pricing_engine = 'EXTERNAL') OR
         ((l_pricing_engine = 'INTERNAL') AND (l_int_arrears_pay_option = 'FIRST_DAY_OF_NEXT_PERIOD'))
          ) THEN
         l_term_date_flag := 'Y';
      END IF;
      --end Bug 7456516

      FOR cur_bill_adj IN l_bill_adj_csr(l_input_rec.khr_id, l_input_rec.kle_id, l_input_rec.term_date_from, l_input_rec.term_date_to) LOOP
        --Bug 7456516
        l_pmnt_arrear_flag := 'N';
        OPEN GET_PMNT_ARREAR_FLAG(cur_bill_adj.khr_id, cur_bill_adj.kle_id);
        FETCH GET_PMNT_ARREAR_FLAG INTO l_pmnt_arrear_flag;
        CLOSE GET_PMNT_ARREAR_FLAG;

        IF((l_pmnt_arrear_flag = 'Y') AND (l_term_date_flag = 'Y')) THEN
           --Add +1 day to Termination Date in case of Arrears payment
           IF(TRUNC(cur_bill_adj.stream_element_date) > TRUNC(l_input_rec.term_date_from + 1)) THEN
              baj_cnt := baj_cnt + 1;
              lx_baj_tbl(baj_cnt) := cur_bill_adj;
           END IF;
        ELSE
          baj_cnt := baj_cnt + 1;
          lx_baj_tbl(baj_cnt) := cur_bill_adj;
        END IF;
        --end Bug 7456516
      END LOOP;
       --akrangan  Bug 5655680 start --
 	       FOR l_lnk_ast IN l_lnk_ast_csr(l_input_rec.kle_id) LOOP
 	         FOR cur_bill_adj IN l_bill_adj_csr(l_input_rec.khr_id, l_lnk_ast.link_kle_id, l_input_rec.term_date_from, l_input_rec.term_date_to) LOOP
                 --Bug 7456516
                 l_pmnt_arrear_flag := 'N';
                 OPEN GET_PMNT_ARREAR_FLAG(cur_bill_adj.khr_id, cur_bill_adj.kle_id);
                 FETCH GET_PMNT_ARREAR_FLAG INTO l_pmnt_arrear_flag;
                 CLOSE GET_PMNT_ARREAR_FLAG;

                 IF((l_pmnt_arrear_flag = 'Y') AND (l_term_date_flag = 'Y')) THEN
                   --Add +1 day to Termination Date in case of Arrears payment
                   IF(TRUNC(cur_bill_adj.stream_element_date) > TRUNC(l_input_rec.term_date_from + 1)) THEN
                      baj_cnt := baj_cnt + 1;
                      lx_baj_tbl(baj_cnt) := cur_bill_adj;
                   END IF;
                 ELSE
                   baj_cnt := baj_cnt + 1;
                   lx_baj_tbl(baj_cnt) := cur_bill_adj;
                 END IF;
                 --end Bug 7456516
 	         END LOOP;
 	       END LOOP;
      --akrangan  Bug 5655680 end --
      IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_ERROR;
      END IF;

      input_cnt := l_input_tbl.NEXT(input_cnt);
    END LOOP;

    -- Processing ends
    x_baj_tbl := lx_baj_tbl;
    x_return_status := l_return_status;

    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END get_billing_adjust;

  ---------------------------------------------------------------------------

  PROCEDURE get_unbilled_recvbl(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_input_tbl                IN input_tbl_type,
     x_baj_tbl                  OUT NOCOPY baj_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) IS

     l_return_status            VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'get_unbilled_recvbl';

     l_input_rec                input_rec_type;
     l_input_tbl                input_tbl_type;

     l_baj_rec                  baj_rec_type;
     lx_baj_tbl                 baj_tbl_type;

     input_cnt                  NUMBER;
     baj_cnt                    NUMBER := 0;

     ------------------------------------------------
     --Un-Billed Receivables for invoices
     --For future dated termination
     ------------------------------------------------
     cursor l_bill_adj_csr(cp_khr_id IN NUMBER, cp_kle_id IN NUMBER, cp_term_date_from IN DATE, cp_term_date_to IN DATE) IS
           SELECT stm.khr_id         khr_id,
           stm.kle_id                kle_id,
           TRUNC (ste.stream_element_date)    stream_element_date,
           ste.id                    sel_id,
           stm.id                    stm_id,
           stm.sty_id                sty_id,
           sty.name                  sty_name,
           ste.amount,
           ste.se_line_number,
           ste.source_id,
           ste.source_table
          FROM    okl_strm_elements   ste,
           okl_streams                stm,
           okl_strm_type_v            sty,
           okc_k_headers_b            khr,
           okl_k_headers              khl,
           okc_k_lines_b              kle,
           okc_statuses_b             khs
          WHERE  trunc(ste.stream_element_date)    >=    trunc(nvl(cp_term_date_from, ste.stream_element_date))
          AND    trunc(ste.stream_element_date)    <=    trunc(nvl(cp_term_date_to, ste.stream_element_date))
          AND    ste.amount             <> 0
          AND    stm.id                = ste.stm_id
          AND    ste.date_billed        IS NULL
          AND    stm.active_yn        = 'Y'
          AND    stm.say_code        = 'CURR'
          AND    sty.id                = stm.sty_id
          AND    sty.billable_yn        = 'Y'
          AND    khr.id                = stm.khr_id
          AND    khr.scs_code        IN ('LEASE', 'LOAN')
          AND    khr.sts_code        IN ( 'BOOKED','EVERGREEN')
          AND    khr.id                = cp_khr_id
          AND    khl.id                = stm.khr_id
          AND    khl.deal_type        IS NOT NULL
          AND    khs.code            = khr.sts_code
          AND    khs.ste_code        = 'ACTIVE'
          AND    stm.kle_id          = kle.id(+)
          AND    nvl(stm.kle_id, -99) = nvl(cp_kle_id, nvl(stm.kle_id, -99))
          AND OKL_BPD_TERMINATION_ADJ_PVT.get_kle_status_code(stm.kle_id) IN  ('ACTIVE', 'TERMINATED', 'HEADER_LEVEL')
          ORDER    BY 1, 2, 3;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
    l_input_tbl := p_input_tbl;

    input_cnt := l_input_tbl.FIRST;
    WHILE (input_cnt IS NOT NULL)
    LOOP
      l_input_rec := l_input_tbl(input_cnt);

      FOR cur_bill_adj IN l_bill_adj_csr(l_input_rec.khr_id, l_input_rec.kle_id, l_input_rec.term_date_from, l_input_rec.term_date_to) LOOP
        baj_cnt := baj_cnt + 1;
        lx_baj_tbl(baj_cnt) := cur_bill_adj;
      END LOOP;

      IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_ERROR;
      END IF;

      input_cnt := l_input_tbl.NEXT(input_cnt);
    END LOOP;

    -- Processing ends
    x_baj_tbl := lx_baj_tbl;
    x_return_status := l_return_status;

    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END get_unbilled_recvbl;

  ---------------------------------------------------------------------------

  PROCEDURE create_passthru_adj(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_baj_tbl                  IN baj_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) IS

     l_return_status            VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'create_passthru_adj';
     l_ableto_complete          BOOLEAN := TRUE;

     l_baj_rec                  baj_rec_type;
     l_baj_tbl                  baj_tbl_type;

     cnt                        NUMBER;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
    l_baj_tbl := p_baj_tbl;

    cnt := l_baj_tbl.FIRST;
    WHILE (cnt IS NOT NULL)
    LOOP
      l_baj_rec := l_baj_tbl(cnt);

      create_debit_memo(
       p_api_version => l_api_version,
       p_init_msg_list => p_init_msg_list,
       p_sel_id => l_baj_rec.sel_id,
       x_return_status => l_return_status,
       x_msg_count => x_msg_count,
       x_msg_data  => x_msg_data);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        l_ableto_complete := FALSE;
      END IF;

      cnt := l_baj_tbl.NEXT(cnt);
    END LOOP;

    -- Processing ends
    IF NOT(l_ableto_complete) THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    ELSE
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
    END IF;

    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END create_passthru_adj;

  ---------------------------------------------------------------------------

  PROCEDURE get_unbilled_prop_tax(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_input_tbl                IN input_tbl_type,
     x_baj_tbl                  OUT NOCOPY baj_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) IS

     l_return_status            VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'get_unbilled_prop_tax';

     l_input_rec                input_rec_type;
     l_input_tbl                input_tbl_type;

     l_baj_rec                  baj_rec_type;
     lx_baj_tbl                 baj_tbl_type;

     input_cnt                  NUMBER;
     baj_cnt                    NUMBER := 0;

     ------------------------------------------------
     --Un-Billed Property Tax Receivables for invoices
     --For future dated termination
     ------------------------------------------------
     cursor l_bill_adj_csr(cp_khr_id IN NUMBER, cp_kle_id IN NUMBER, cp_term_date_from IN DATE, cp_term_date_to IN DATE) IS
         SELECT	stm.khr_id		 khr_id,
			stm.kle_id	     kle_id,
			TRUNC (ste.stream_element_date)	stream_element_date,
			ste.id		     sel_id,
            stm.id           stm_id,
			stm.sty_id		 sty_id,
            sty.name         sty_name,
			ste.amount	     amount,
            ste.se_line_number,
            ste.source_id,
            ste.source_table
   	      FROM	okl_strm_elements		ste,
			okl_streams			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			okl_k_headers			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs
          WHERE  trunc(ste.stream_element_date)    >=    trunc(nvl(cp_term_date_from, ste.stream_element_date))
          AND    trunc(ste.stream_element_date)    <=    trunc(nvl(cp_term_date_to, ste.stream_element_date))
          AND    ste.amount             <> 0
          AND    stm.id                = ste.stm_id
          AND    ste.date_billed        IS NULL
          AND    stm.active_yn        = 'Y'
          AND    stm.say_code        = 'CURR'
          AND    sty.id                = stm.sty_id
          AND    sty.billable_yn        = 'Y'
          AND    khr.id                = stm.khr_id
          AND    khr.scs_code        IN ('LEASE', 'LOAN')
          AND    khr.sts_code        IN ( 'BOOKED','EVERGREEN')
          AND    khr.id                = cp_khr_id
          AND    khl.id                = stm.khr_id
          AND    khl.deal_type        IS NOT NULL
          AND    khs.code            = khr.sts_code
          AND    khs.ste_code        = 'ACTIVE'
          AND    stm.kle_id          = kle.id(+)
          AND    nvl(stm.kle_id, -99) = nvl(cp_kle_id, nvl(stm.kle_id, -99))
          AND OKL_BPD_TERMINATION_ADJ_PVT.get_kle_status_code(stm.kle_id) IN  ('ACTIVE', 'TERMINATED', 'HEADER_LEVEL')
    AND exists (select 1 from okc_rule_groups_b rgp
                                , okc_rules_b rul
                  where rgp.dnz_chr_id = kle.dnz_chr_id
                  and   rgp.cle_id = kle.id
                  and rgp.rgd_code = 'LAASTX'
                  and rgp.id = rul.rgp_id
                  and rul.rule_information_category = 'LAPRTX'
                  and rul.rule_information1 = 'Y'
                  and (rul.rule_information3 = 'ESTIMATED' or rul.rule_information3 = 'ESTIMATED_AND_ACTUAL')
                  )
    AND sty.stream_type_purpose = 'ESTIMATED_PROPERTY_TAX'
    ORDER	BY 1, 2, 3;

  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
    l_input_tbl := p_input_tbl;

    input_cnt := l_input_tbl.FIRST;
    WHILE (input_cnt IS NOT NULL)
    LOOP
      l_input_rec := l_input_tbl(input_cnt);

      FOR cur_bill_adj IN l_bill_adj_csr(l_input_rec.khr_id, l_input_rec.kle_id, l_input_rec.term_date_from, l_input_rec.term_date_to) LOOP
        baj_cnt := baj_cnt + 1;
        lx_baj_tbl(baj_cnt) := cur_bill_adj;
      END LOOP;

      IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_ERROR;
      END IF;

      input_cnt := l_input_tbl.NEXT(input_cnt);
    END LOOP;

    -- Processing ends
    x_baj_tbl := lx_baj_tbl;
    x_return_status := l_return_status;

    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END get_unbilled_prop_tax;

  ------------------------------------------------------------------
  --interface between rebook api and bpd processing apis by fmiao
  ------------------------------------------------------------------
  PROCEDURE create_rbk_passthru_adj(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_rebook_adj_tbl           IN rebook_adj_tbl,
	 x_disb_rec					OUT NOCOPY disb_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) IS

     l_return_status            VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'create_rbk_passthru_adj';

	 l_disb_rec					disb_rec_type;
	 i                   		NUMBER;

  CURSOR get_contract_csr (p_chr_id NUMBER) IS
    SELECT chr.authoring_org_id,
         chr.currency_code,
         hr.set_of_books_id
 -- 02-NOV-2006 ANSETHUR  R12B - Legal Entity
         ,khr.legal_entity_id
    FROM  okc_k_headers_b chr,hr_operating_units hr
 -- 02-NOV-2006 ANSETHUR  R12B - Legal Entity
          ,OKL_K_HEADERS khr
     WHERE chr.authoring_org_id = hr.organization_id
     AND   chr.id = p_chr_id
-- 02-NOV-2006 ANSETHUR  R12B - Legal Entity
     AND   khr.id = chr.id;

  l_authoring_org_id okc_k_headers_b.authoring_org_id%TYPE;
  l_currency_code    okc_k_headers_b.currency_code%TYPE;
  l_set_of_books_id  hr_operating_units.set_of_books_id%TYPE;
 -- 02-NOV-2006 ANSETHUR  R12B - Legal Entity
  l_legal_entity_id    okl_k_headers.legal_entity_id%TYPE;

	 CURSOR get_passthru_csr (p_chr_id NUMBER, p_cle_id NUMBER) IS
	 SELECT id,
	 		passthru_stream_type_id,
	 		payout_basis,
			payout_basis_formula
	 FROM	okl_party_payment_hdr
	 WHERE  dnz_chr_id = p_chr_id
	 AND    cle_id = p_cle_id
         --Bug# 4884423
         AND passthru_term = 'BASE';
	 l_pph_id okl_party_payment_hdr.id%TYPE;
	 l_passthru_stream_type_id okl_party_payment_hdr.passthru_stream_type_id%TYPE;
	 l_payout_basis okl_party_payment_hdr.payout_basis%TYPE;
	 l_payout_basis_formula okl_party_payment_hdr.payout_basis_formula%TYPE;

  BEGIN
    --Bug# 4884423
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_rebook_adj_tbl.COUNT > 0 THEN
      i := p_rebook_adj_tbl.FIRST;
      LOOP
  OPEN get_contract_csr (p_rebook_adj_tbl(i).khr_id);
  FETCH get_contract_csr INTO l_authoring_org_id,
                              l_currency_code,
                              l_set_of_books_id,
                              l_legal_entity_id;
		CLOSE get_contract_csr;
		OPEN get_passthru_csr(p_rebook_adj_tbl(i).khr_id,
		  	   			      p_rebook_adj_tbl(i).kle_id);
		FETCH get_passthru_csr INTO l_pph_id,
		  						 	l_passthru_stream_type_id,
									l_payout_basis,
									l_payout_basis_formula;
		CLOSE get_passthru_csr;

        IF (p_rebook_adj_tbl(i).kle_id IS NOT NULL AND
		    l_payout_basis = 'DUE_DATE')
               -- Bug# 4884423
               -- Disbursement Adjustment should be processed for all amounts
               -- AND	p_rebook_adj_tbl(i).adjusted_amount < 0)
        THEN

		  l_disb_rec.set_of_books_id := l_set_of_books_id;
		  l_disb_rec.org_id := l_authoring_org_id;
		  l_disb_rec.currency_code := l_currency_code;
		  l_disb_rec.khr_id := p_rebook_adj_tbl(i).khr_id;
		  l_disb_rec.kle_id := p_rebook_adj_tbl(i).kle_id;
		  l_disb_rec.amount := p_rebook_adj_tbl(i).adjusted_amount;
		  l_disb_rec.sty_id := p_rebook_adj_tbl(i).sty_id;
		  l_disb_rec.transaction_date := p_rebook_adj_tbl(i).date_invoiced;
		  l_disb_rec.pph_id := l_pph_id;
		  l_disb_rec.passthru_stream_type_id := l_passthru_stream_type_id;
		  l_disb_rec.payout_basis := l_payout_basis;
		  l_disb_rec.payout_basis_formula := l_payout_basis_formula;
 -- 02-NOV-2006 ANSETHUR  R12B - Legal Entity
    l_disb_rec.legal_entity_id := l_legal_entity_id;

		  OKL_PAY_INVOICES_DISB_PVT.INVOICE_DISBURSEMENT(
    	  	p_api_version   => p_api_version,
   			p_init_msg_list => p_init_msg_list,
   			x_return_status => x_return_status,
   			x_msg_count     => x_msg_count,
   			x_msg_data      => x_msg_data,
   			p_disb_rec      => l_disb_rec);

    	    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
	  		  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    		ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
	  		  RAISE OKL_API.G_EXCEPTION_ERROR;
    		END IF;
		END IF;

      EXIT WHEN (i = p_rebook_adj_tbl.LAST);
      i := p_rebook_adj_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
	  RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END create_rbk_passthru_adj;

  ---------------------------------------------------------------------------
END OKL_BPD_TERMINATION_ADJ_PVT;

/
