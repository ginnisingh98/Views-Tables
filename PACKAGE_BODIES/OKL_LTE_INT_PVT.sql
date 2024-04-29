--------------------------------------------------------
--  DDL for Package Body OKL_LTE_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LTE_INT_PVT" AS
/* $Header: OKLRLINB.pls 120.20.12010000.2 2008/11/18 20:59:33 cklee ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.INTEREST';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

-- Bug 6472228 - Added constant for Late fee/interest calculation SGN_CODE
  G_LATE_SGN_CODE CONSTANT VARCHAR2(10) := 'LATE_CALC';


  PROCEDURE calculate_late_interest(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
     ) IS

    l_api_version                   CONSTANT NUMBER := 1;
    l_api_name                      CONSTANT VARCHAR2(30) := 'calculate_late_interest';
    l_return_status                 VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_init_msg_list                 VARCHAR2(1) ;
    l_msg_count                     NUMBER ;

    l_amt_applied                   AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%type;
    l_due_date                      AR_PAYMENT_SCHEDULES_ALL.DUE_DATE%type;
    l_khr_id                        OKL_CNSLD_AR_STRMS_V.KHR_ID%type;
    l_apply_date                    AR_RECEIVABLE_APPLICATIONS_ALL.APPLY_DATE%TYPE;
    l_cnsld_id						OKL_CNSLD_AR_STRMS_V.ID%type;
    l_amount                        NUMBER;
    l_interest_amount               NUMBER;

    --start code pgomes 12/18/2002
    l_func_currency                okl_k_headers_full_v.currency_code%TYPE := okl_accounting_util.get_func_curr_code;
    l_contract_currency            okl_k_headers_full_v.currency_code%TYPE;
    l_prev_contract_currency       okl_k_headers_full_v.currency_code%TYPE;
    l_late_policy                  okl_late_policies_v.name%TYPE;
    l_prev_late_policy             okl_late_policies_v.name%TYPE;

    l_minimum_late_interest        okl_late_policies_b.minimum_late_interest%TYPE;
    l_maximum_late_interest        okl_late_policies_b.maximum_late_interest%TYPE;
    l_late_int_minimum_balance     okl_late_policies_b.late_int_minimum_balance%TYPE;

    l_currency_conversion_type     okl_k_headers_full_v.currency_conversion_type%type;
    l_currency_conversion_rate     okl_k_headers_full_v.currency_conversion_rate%type;
    l_currency_conversion_date     okl_k_headers_full_v.currency_conversion_date%type;

    l_last_updated_by   NUMBER;
    l_last_update_login NUMBER;
    l_request_id NUMBER;
    --end code pgomes 12/18/2002
    l_prev_khr_id           okl_k_headers.id%TYPE;     --dkagrawa added for bug# 4728636

	------------------------------------------------------------
	-- Declare variables to call Accounting Engine.
	------------------------------------------------------------
	p_bpd_acc_rec					Okl_Acc_Call_Pub.bpd_acc_rec_type;

    -- Variables for Late Interest rules Call
    l_late_int_fixed_yn             OKL_LATE_POLICIES_V.LATE_INT_FIXED_YN%TYPE;
    l_late_int_rate                 OKL_LATE_POLICIES_V.LATE_INT_RATE%TYPE;
    l_adder_rate                    OKL_LATE_POLICIES_V.ADDER_RATE%TYPE;
    l_index_rate                    OKL_INDEX_VALUES.VALUE%TYPE;
    l_days_in_year                  OKL_LATE_POLICIES_V.DAYS_IN_YEAR%TYPE;
    l_days_calc                     NUMBER := 0;
    l_held_until_date               DATE;

    l_sty_id                        OKL_STRM_TYPE_V.ID%TYPE;
    l_stm_id                        OKL_STREAMS_V.ID%TYPE;
    l_stream_purpose                OKL_STRM_TYPE_V.stream_type_purpose%TYPE;
    l_sec_stream_id                 OKL_CNSLD_AR_STRMS_V.ID%TYPE;
    l_se_line_number                OKL_STRM_ELEMENTS_V.SE_LINE_NUMBER%TYPE;
    l_error_flag                    BOOLEAN := FALSE;

    l_stmv_rec          Okl_Streams_Pub.stmv_rec_type;
    lx_stmv_rec         Okl_Streams_Pub.stmv_rec_type;
    l_init_stmv_rec     Okl_Streams_Pub.stmv_rec_type;

    l_selv_rec          Okl_Sel_Pvt.selv_rec_type;
    lx_selv_rec         Okl_Sel_Pvt.selv_rec_type;
    l_init_selv_rec     Okl_Sel_Pvt.selv_rec_type;
    l_sel_id            Okl_strm_elements_v.sel_id%TYPE;

	------------------------------------------------------------
	--Consolidated invoices for Late Interest Cursor
	------------------------------------------------------------
     --rkuttiya modified this cursor for R12 B Billing Architecture
     -- vdamerla: bug:6342067 : Modified cursor for per contract per invoice
     -- gboomina Bug 6797022 - Start
     -- Modified this cursor to pick contracts with no held until date defined
         CURSOR l_late_invs_cur IS
         SELECT  LTE.name late_policy
                , KHR.currency_code
                , ARL.RECEIVABLES_INVOICE_ID RECEIVABLES_INVOICE_ID
                , KHR.contract_number
                , ARL.CONTRACT_ID CONTRACT_ID
                , sum(NVL(ARL.AMOUNT_DUE_ORIGINAL,0)) AMOUNT_APPLIED
                , max(greatest(TRUNC((FND_DATE.canonical_to_date(NVL(rul_hld.rule_information1,AR_PAY.DUE_DATE)))),TRUNC(AR_PAY.DUE_DATE))) DUE_DATE
                , max(TRUNC(AR_REC.APPLY_DATE)) APPLY_DATE
                ,max('AR-INVOICE') invoice_flag
          FROM      AR_RECEIVABLE_APPLICATIONS_ALL AR_REC
                  , AR_PAYMENT_SCHEDULES_ALL AR_PAY
                  , OKL_BPD_AR_INV_LINES_V ARL
                  , OKL_K_HEADERS_FULL_V KHR
                  , OKC_RULE_GROUPS_B RGP
                  , OKC_RULES_B RUL
                  , okc_rules_b rul_exm
                   ,okc_rules_b rul_hld
                  , OKL_LATE_POLICIES_V LTE
       WHERE
                    AR_REC.APPLY_DATE > (AR_PAY.DUE_DATE + nvl(LTE.late_int_grace_period, 0))
           AND      ARL.RECEIVABLES_INVOICE_ID = AR_PAY.CUSTOMER_TRX_ID
           AND      AR_PAY.PAYMENT_SCHEDULE_ID = AR_REC.APPLIED_PAYMENT_SCHEDULE_ID
           AND      AR_PAY.CLASS = 'INV'
           AND      AR_PAY.status = 'CL'
           AND      AR_REC.STATUS = 'APP'
           AND      AR_REC.APPLICATION_TYPE = 'CASH'
           AND      ARL.CONTRACT_ID = khr.id
           AND      ARL.late_int_assess_date IS NULL
           AND      NVL(ARL.late_int_ass_yn, 'N') = 'N'
           and      khr.id = rgp.dnz_chr_id
           and      rgp.rgd_code = 'LALIGR'
           and      khr.id = rul.dnz_chr_id
           and      rgp.id = rul.rgp_id
           and      rul.rule_information_category = 'LALCIN'
           and      rul.rule_information1 = lte.id
           and      (lte.late_policy_type_code = 'LCT' or lte.late_policy_type_code = 'INT')
           and      khr.id = rul_exm.dnz_chr_id
           and      rgp.id = rul_exm.rgp_id
           and      rul_exm.rule_information_category = 'LALIEX'
           and      NVL(rul_exm.rule_information1, 'N') = 'N'
           and not exists (select 1 from okl_strm_type_exempt_v sty_exm
                           where    lte.id = sty_exm.lpo_id
                           and      ARL.sty_id = sty_exm.sty_id
                           and      NVL(sty_exm.late_policy_exempt_yn, 'N') = 'Y')
           and      khr.id = rul_hld.dnz_chr_id
           and      rgp.id = rul_hld.rgp_id
           and      rul_hld.rule_information_category = 'LAHUDT'
           and      TRUNC(NVL(FND_DATE.canonical_to_date(NVL(rul_hld.rule_information1,sysdate)), sysdate - 1)) < trunc(sysdate)
         and     ((TRUNC((FND_DATE.canonical_to_date(rul_hld.rule_information1))) IS NOT NULL
                   AND TRUNC((FND_DATE.canonical_to_date(rul_hld.rule_information1))) < TRUNC(AR_REC.APPLY_DATE))
                   OR TRUNC(AR_REC.APPLY_DATE) IS NULL
		   OR rul_hld.rule_information1 IS NULL)
           group by
                  LTE.name
                , KHR.currency_code
                , KHR.contract_number
                , ARL.CONTRACT_ID
                , ARL.RECEIVABLES_INVOICE_ID
                ,'AR-INVOICE'
       union
       SELECT       LTE.name late_policy
                  , KHR.currency_code
                  , CNSLD.RECEIVABLES_INVOICE_ID RECEIVABLES_INVOICE_ID
                  , KHR.contract_number
                  , CNSLD.KHR_ID CONTRACT_ID
                  , sum(NVL(AR_REC.AMOUNT_APPLIED,0)) AMOUNT_APPLIED
                  , max(greatest(TRUNC((FND_DATE.canonical_to_date(NVL(rul_hld.rule_information1,AR_PAY.DUE_DATE)))),TRUNC(AR_PAY.DUE_DATE))) DUE_DATE
                  , max(TRUNC(AR_REC.APPLY_DATE)) APPLY_DATE
                  , max('CONS-INVOICE') invoice_flag
       FROM         AR_RECEIVABLE_APPLICATIONS_ALL AR_REC
                  , AR_PAYMENT_SCHEDULES_ALL AR_PAY
                  , OKL_CNSLD_AR_STRMS_B CNSLD
                  , OKL_K_HEADERS_FULL_V KHR
                  , OKC_RULE_GROUPS_B RGP
                  , OKC_RULES_B RUL
                  , okc_rules_b rul_exm
                   ,okc_rules_b rul_hld
                  , OKL_LATE_POLICIES_V LTE
         WHERE
                AR_REC.APPLY_DATE > (AR_PAY.DUE_DATE + nvl(LTE.late_int_grace_period, 0)) AND
                    CNSLD.RECEIVABLES_INVOICE_ID = AR_PAY.CUSTOMER_TRX_ID
           AND      AR_PAY.PAYMENT_SCHEDULE_ID = AR_REC.APPLIED_PAYMENT_SCHEDULE_ID
           AND      AR_PAY.CLASS = 'INV'
           AND      AR_PAY.status = 'CL'
           AND      AR_REC.STATUS = 'APP'
           AND      AR_REC.APPLICATION_TYPE = 'CASH'
           and      CNSLD.KHR_ID = khr.id
           AND      CNSLD.late_int_assess_date IS NULL
           AND      NVL(CNSLD.late_int_ass_yn, 'N') = 'N'
           and      khr.id = rgp.dnz_chr_id
           and      rgp.rgd_code = 'LALIGR'
           and      khr.id = rul.dnz_chr_id
           and      rgp.id = rul.rgp_id
           and      rul.rule_information_category = 'LALCIN'
           and      rul.rule_information1 = lte.id
           and      (lte.late_policy_type_code = 'LCT' or lte.late_policy_type_code = 'INT')
           and      khr.id = rul_exm.dnz_chr_id
           and      khr.authoring_org_id = MO_GLOBAL.get_current_org_id
           and      rgp.id = rul_exm.rgp_id
           and      rul_exm.rule_information_category = 'LALIEX'
           and      NVL(rul_exm.rule_information1, 'N') = 'N'
           and not exists (select 1 from okl_strm_type_exempt_v sty_exm
                           where    lte.id = sty_exm.lpo_id
                           and      CNSLD.sty_id = sty_exm.sty_id
                           and      NVL(sty_exm.late_policy_exempt_yn, 'N') = 'Y')
           and      khr.id = rul_hld.dnz_chr_id
           and      rgp.id = rul_hld.rgp_id
           and      rul_hld.rule_information_category = 'LAHUDT'
           and      TRUNC(NVL(FND_DATE.canonical_to_date(NVL(rul_hld.rule_information1,sysdate)), sysdate - 1)) < trunc(sysdate)
           and     ((TRUNC((FND_DATE.canonical_to_date(rul_hld.rule_information1))) IS NOT NULL
                   AND TRUNC((FND_DATE.canonical_to_date(rul_hld.rule_information1))) < TRUNC(AR_REC.APPLY_DATE))
                   OR TRUNC(AR_REC.APPLY_DATE) IS NULL
		   OR rul_hld.rule_information1 IS NULL)
          group by  LTE.name
                  , KHR.currency_code
                  , KHR.contract_number
                  , CNSLD.KHR_ID
                  , CNSLD.RECEIVABLES_INVOICE_ID
                  ,'CONS-INVOICE';
     -- gboomina Bug 6797022 - End

	------------------------------------------------------------
	-- Late Policy Cursor
	------------------------------------------------------------
    CURSOR l_late_policy_cur(cp_name IN VARCHAR2) IS
            SELECT  LTE.LATE_POLICY_TYPE_CODE, LTE.LATE_INT_ALLOWED_YN, LTE.LATE_INT_FIXED_YN
                  , NVL(LTE.LATE_INT_RATE,0) LATE_INT_RATE
                  , NVL(LTE.ADDER_RATE,0) ADDER_RATE
                  , NVL(LTE.LATE_INT_GRACE_PERIOD,0) LATE_INT_GRACE_PERIOD
                  , NVL(LTE.LATE_INT_MINIMUM_BALANCE,0) LATE_INT_MINIMUM_BALANCE
                  , NVL(LTE.MINIMUM_LATE_INTEREST,0) MINIMUM_LATE_INTEREST
                  , NVL(LTE.MAXIMUM_LATE_INTEREST,9999999999) MAXIMUM_LATE_INTEREST
                  , NVL(IDX.value,0) INDEX_RATE
                  , NVL(LTE.DAYS_IN_YEAR, 'ACTUAL') DAYS_IN_YEAR
            FROM    OKL_LATE_POLICIES_V LTE
                  , OKL_INDEX_VALUES IDX
            WHERE   LTE.NAME = cp_name
            AND     LTE.idx_id = IDX.idx_id(+)
            AND     TRUNC(SYSDATE) BETWEEN TRUNC(NVL(IDX.DATETIME_VALID, SYSDATE)) AND TRUNC(NVL(IDX.DATETIME_INVALID, SYSDATE));


	------------------------------------------------------------
	-- Consolidated stream update Cursor
	------------------------------------------------------------

    -- vdamerla: bug:6342067 :  Get the late int data

  -- cursor for consolidated invoices

    CURSOR l_cons_lsm_cur(l_RECEIVABLES_INVOICE_ID IN NUMBER, l_khr_id in number) IS
          SELECT  lsm.id
         , lsm.LATE_CHARGE_ASS_YN
         , lsm.LATE_CHARGE_ASSESS_DATE
          FROM    OKL_CNSLD_AR_STRMS_B lsm,
                  OKL_CNSLD_AR_LINES_B lln,
                  OKL_CNSLD_AR_HDRS_B cnr,
                  okl_bpd_leasing_payment_trx_v lpt
          WHERE
                 lpt.RECEIVABLES_INVOICE_ID=l_RECEIVABLES_INVOICE_ID
          and    cnr.id = lpt.consolidated_invoice_id
          and    lln.cnr_id = cnr.id
          and     lsm.lln_id = lln.id
          and     lsm.KHR_ID = l_khr_id
          FOR UPDATE OF lsm.LATE_CHARGE_ASS_YN, lsm.LATE_CHARGE_ASSESS_DATE;


    -- cursor for AR invoices
    CURSOR l_AR_lsm_cur(l_id IN NUMBER,l_contract_id in number) IS
    SELECT  ID
          , LATE_CHARGE_ASS_YN
          , LATE_CHARGE_ASSESS_DATE
    FROM   OKL_BPD_AR_INV_LINES_V
    WHERE   RECEIVABLES_INVOICE_ID = l_id
    AND     CONTRACT_ID=l_contract_id
    FOR UPDATE OF LATE_CHARGE_ASS_YN, LATE_CHARGE_ASSESS_DATE;


	------------------------------------------------------------
	-- Transaction Number Cursor
	------------------------------------------------------------
    CURSOR c_tran_num_csr IS
            SELECT  okl_sif_seq.nextval
            FROM    dual;

	------------------------------------------------------------
	-- Stream Type Constants
	------------------------------------------------------------
    cns_late_interest constant  varchar2(50) := 'LATE_INTEREST';
    cns_late_fee constant  varchar2(50) := 'LATE_FEE';
    cns_late_interest_payable constant  varchar2(50) := 'INVESTOR_LATE_INTEREST_PAY';
    cns_source_table constant varchar2(25) := 'OKL_CNSLD_AR_STRMS_V';

/*	------------------------------------------------------------
	-- Stream Id Cursor
	------------------------------------------------------------
    CURSOR l_sty_id_cur(cp_purpose IN VARCHAR2) IS
            SELECT id FROM okl_strm_type_b where stream_type_purpose = cp_purpose;
*/
	------------------------------------------------------------
	-- Stream Cursor
	------------------------------------------------------------

     -- vdamerla: bug:6342067 : Modified cursor for Billing impact chnages
    -- cursor for AR invoices
    CURSOR l_AR_stream_csr(cp_khr_id IN NUMBER
                   ,cp_sty_id IN NUMBER) IS
            SELECT stm.id
            FROM   okl_streams_v stm
            WHERE  stm.khr_id = cp_khr_id
            AND    stm.sty_id = cp_sty_id
            AND    stm.say_code = 'CURR'
            AND    stm.active_yn = 'Y';

    -- cursor for consolidated invoices
   CURSOR l_cons_stream_csr(cp_khr_id IN NUMBER
                   ,cp_kle_id IN NUMBER
                   ,cp_sty_id IN NUMBER) IS
            SELECT stm.id
            FROM   okl_streams_v stm
            WHERE  stm.khr_id = cp_khr_id
            AND    nvl(stm.kle_id, -99) = nvl(cp_kle_id, -99)
            AND    stm.sty_id = cp_sty_id
            AND    stm.say_code = 'CURR'
            AND    stm.active_yn = 'Y';




	------------------------------------------------------------
	-- Stream Element Line Number Cursor
	------------------------------------------------------------
    CURSOR l_stream_line_nbr_csr(cp_stm_id IN NUMBER) IS
            SELECT nvl(max(se_line_number), 0) se_line_number
            FROM okl_strm_elements_v
            WHERE stm_id = cp_stm_id;

	------------------------------------------------------------
	-- Securitized streams Cursor
	------------------------------------------------------------
    --rkuttiya modified this cursor for R12 B Billing Architecture
    --modified data elements, table name, where clause
    -- vdamerla: bug:6342067 : Modified cursor for Billing impact chnages

    CURSOR c_sec_strm_cons_csr(l_khr_id in number, l_cons_rec_inv_id IN NUMBER ) IS
    select lsm.id cnsld_strm_id,
           pol.khr_id,lsm.kle_id
    from okl_cnsld_ar_strms_b lsm
       , okl_cnsld_ar_hdrs_b cnr
       , okl_cnsld_ar_lines_b lln
       , okl_pool_contents_v pk
       , okl_pools pol
    where lsm.RECEIVABLES_INVOICE_ID = l_cons_rec_inv_id
      and   lln.cnr_id = cnr.id
      and   lsm.lln_id = lln.id
      and   lsm.khr_id = l_khr_id
      and   lsm.khr_id = pk.khr_id
      and   nvl(lsm.kle_id, -99) = nvl(pk.kle_id, -99)
      and   lsm.sty_id = pk.sty_id
      and   pk.pol_id = pol.id
      and   pol.status_code='ACTIVE'  -- Added vdamerla for bug 6064374
 and   pk.status_code = 'ACTIVE'  --Added by bkatraga for bug 6983321
      and   trunc(cnr.date_consolidated) between trunc(pk.streams_from_date) and trunc(pk.streams_to_date)
      AND   pk.status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE; --Added by VARANGAN -Pool Contents Impact(Bug#6658065)

    CURSOR c_sec_strm_AR_csr(cp_contract_id in number, cp_con_rec_inv_id IN VARCHAR2) IS
    SELECT arl.id cnsld_strm_id
          ,pol.khr_id, pk.kle_id kle_id
    FROM okl_bpd_ar_inv_lines_v arl
        ,okl_bpd_ar_invoices_v arv
        ,okl_pool_contents_v pk
        ,okl_pools pol
    WHERE arl.RECEIVABLES_INVOICE_ID  = cp_con_rec_inv_id
    AND   arl.contract_id = cp_contract_id
    AND   arl.contract_id = pk.khr_id
    AND   nvl(arl.contract_line_id, -99) = nvl(pk.kle_id, -99)
    AND   arl.sty_id = pk.sty_id
    AND   pk.pol_id = pol.id
    and   pol.status_code='ACTIVE'  -- Added vdamerla for bug 6064374
 and   pk.status_code = 'ACTIVE'  --Added by bkatraga for bug 6983321
    AND   arv.invoice_id = arl.invoice_id
    AND   trunc(arv.date_consolidated) between trunc(pk.streams_from_date) and trunc(pk.streams_to_date)
    AND   pk.status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE; --Added by VARANGAN -Pool Contents Impact(Bug#6658065)

	------------------------------------------------------------
	-- Source id of stream element of Late Invoice Cursor
	------------------------------------------------------------
    --rkuttiya modified this cursor for R12 B Billing Architecture
    --Modified data elements, view name, where clause

    CURSOR c_src_sel(cp_stream_id IN NUMBER) IS
    SELECT sel.source_id
    FROM okl_bpd_ar_inv_lines_v arl
        ,okl_strm_elements_v sel
    WHERE arl.id = cp_stream_id
    AND   arl.sel_id = sel.id;



    BEGIN
      l_return_status :=  OKL_API.START_ACTIVITY(l_api_name,
                                                 G_PKG_NAME,
                                                 p_init_msg_list,
                                                 l_api_version,
                                                 p_api_version,
                                                 '_PVT',
                                                 x_return_status);


      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_init_msg_list := p_init_msg_list ;

      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Start of Calculate Late Interest.');

      SELECT FND_GLOBAL.USER_ID
         ,FND_GLOBAL.LOGIN_ID
         ,NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),null)
      INTO  l_last_updated_by
        ,l_last_update_login
        ,l_request_id
      FROM dual;

      FOR l_inv_cur IN l_late_invs_cur
      LOOP
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Processing: RECEIVABLES INVOICE ID => '||l_inv_cur.RECEIVABLES_INVOICE_ID||
         ' ,due date=> '||l_inv_cur.DUE_DATE|| ' ,payment application date=> '||l_inv_cur.APPLY_DATE||' and Amount=> '||l_inv_cur.AMOUNT_APPLIED
                        ||' ,Contract Id=> '||l_inv_cur.contract_number);
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Late policy => ' || l_inv_cur.late_policy
                        || ' ,Contract currency => ' || l_inv_cur.currency_code);
          l_amt_applied           := l_inv_cur.AMOUNT_APPLIED;
          l_due_date              := l_inv_cur.due_date;
          l_khr_id                := l_inv_cur.CONTRACT_ID;
          l_apply_date            := l_inv_cur.APPLY_DATE;
          l_contract_currency     := l_inv_cur.currency_code;
          l_late_policy           := l_inv_cur.late_policy;


          IF (nvl(l_late_policy, 'xxx') <> nvl(l_prev_late_policy, 'yyy') or
            nvl(l_contract_currency, 'aaa') <> nvl(l_prev_contract_currency, 'bbb')) THEN
            FOR l_lpo_cur IN l_late_policy_cur(l_late_policy)
            LOOP
              --start code pgomes 12/18/2002
              IF (l_func_currency <> NVL(l_contract_currency, '000')) THEN
              --convert minimum_late_interest to contract currency
              OKL_ACCOUNTING_UTIL.convert_to_contract_currency(
                p_khr_id  		  	=> l_khr_id,
                p_from_currency   		=> l_func_currency,
                p_transaction_date 		=> sysdate,
                p_amount 			=> l_lpo_cur.minimum_late_interest,
                x_contract_currency		=> l_contract_currency,
                x_currency_conversion_type	=> l_currency_conversion_type,
                x_currency_conversion_rate	=> l_currency_conversion_rate,
                x_currency_conversion_date	=> l_currency_conversion_date,
                x_converted_amount 		=> l_minimum_late_interest);

                l_minimum_late_interest := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_minimum_late_interest, l_contract_currency);

              --convert maximum_late_interest to contract currency
              OKL_ACCOUNTING_UTIL.convert_to_contract_currency(
                p_khr_id  		  	=> l_khr_id,
                p_from_currency   		=> l_func_currency,
                p_transaction_date 		=> sysdate,
                p_amount 			=> l_lpo_cur.maximum_late_interest,
                x_contract_currency		=> l_contract_currency,
                x_currency_conversion_type	=> l_currency_conversion_type,
                x_currency_conversion_rate	=> l_currency_conversion_rate,
                x_currency_conversion_date	=> l_currency_conversion_date,
                x_converted_amount 		=> l_maximum_late_interest);

                l_maximum_late_interest := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_maximum_late_interest, l_contract_currency);

              --convert late_int_minimum_balance to contract currency
              OKL_ACCOUNTING_UTIL.convert_to_contract_currency(
                p_khr_id  		  	=> l_khr_id,
                p_from_currency   		=> l_func_currency,
                p_transaction_date 		=> sysdate,
                p_amount 			=> l_lpo_cur.late_int_minimum_balance,
                x_contract_currency		=> l_contract_currency,
                x_currency_conversion_type	=> l_currency_conversion_type,
                x_currency_conversion_rate	=> l_currency_conversion_rate,
                x_currency_conversion_date	=> l_currency_conversion_date,
                x_converted_amount 		=> l_late_int_minimum_balance);

              l_late_int_minimum_balance := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_late_int_minimum_balance, l_contract_currency);
            ELSE
              l_minimum_late_interest := l_lpo_cur.minimum_late_interest;
              l_maximum_late_interest := l_lpo_cur.maximum_late_interest;
              l_late_int_minimum_balance := l_lpo_cur.late_int_minimum_balance;
            END IF;
            l_late_int_fixed_yn := l_lpo_cur.late_int_fixed_yn;
            l_late_int_rate := l_lpo_cur.late_int_rate;
            l_adder_rate := l_lpo_cur.adder_rate;
            l_index_rate := l_lpo_cur.index_rate;
            l_days_in_year := l_lpo_cur.days_in_year;
            --end code pgomes 12/18/2002

            -- pgomes 12/18/2002 start, changed code to consider converted amounts
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- LATE POLICY TYPE CODE => '||l_lpo_cur.LATE_POLICY_TYPE_CODE||
                          ' LATE INT MINIMUM BALANCE=> '||l_late_int_minimum_balance
                        ||' ,LATE INT GRACE PERIOD=> '||l_lpo_cur.LATE_INT_GRACE_PERIOD);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- INTEREST RATE => ' || l_late_int_rate ||
                          ' ADDER RATE => ' || l_adder_rate || ' INDEX RATE => ' || l_index_rate);
            END LOOP;
            l_prev_late_policy := l_late_policy;
            l_prev_contract_currency := l_contract_currency;
          END IF;

          l_error_flag := FALSE;
          IF(l_late_int_minimum_balance < l_amt_applied) THEN
            --FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Stream Type Id => '||l_sty_id);
            -- 365 to be replaced by no. of days from the rule
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Days past due => '||(l_apply_date - l_due_date));
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Days in a year code => '||l_days_in_year);

            BEGIN
              IF (upper(l_days_in_year) = 'ACTUAL') THEN
                l_days_calc := add_months(trunc(l_due_date, 'YEAR'), 12)  - trunc(l_due_date, 'YEAR');
              ELSE
                l_days_calc := to_number(l_days_in_year);
              END IF;

              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Days in a year  => '||l_days_calc);
            EXCEPTION
              WHEN OTHERS THEN
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,  '        -- ERROR: Calculating Days in a year.');
            END;

            IF(l_late_int_fixed_yn = 'Y') THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Fixed: Interest rate applied => '||(l_late_int_rate+l_adder_rate));
              l_amount := ((l_amt_applied*(l_late_int_rate+l_adder_rate)*(l_apply_date-l_due_date))/100)/l_days_calc;
              l_amount := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_amount, l_contract_currency);
            ELSE
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Variable: Interest rate applied => '||(l_index_rate+l_adder_rate));
              l_amount := ((l_amt_applied*(l_index_rate+l_adder_rate)*(l_apply_date-l_due_date))/100)/l_days_calc;
              l_amount := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_amount, l_contract_currency);
            END IF;
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Calculated late interest => '||l_amount);

            IF(l_amount < l_minimum_late_interest) THEN
              l_interest_amount              := l_minimum_late_interest;
            ELSIF(l_amount > l_maximum_late_interest) THEN
              l_interest_amount              := l_maximum_late_interest;
            ELSE
              l_interest_amount              := l_amount;
            END IF;
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Applied late interest => '||l_interest_amount);
            -- pgomes 12/18/2002 end, changed code to consider converted amountss


             IF l_interest_amount > 0 then

            ----------------------------------------------------------------
            --PROCESSING FOR LATE INTEREST
            ----------------------------------------------------------------

            --get stream type id
            l_sty_id := null;

            Okl_Streams_Util.get_primary_stream_type(
                   p_khr_id => l_khr_id,
                   p_primary_sty_purpose => cns_late_interest,
                   x_return_status => l_return_status,
                   x_primary_sty_id => l_sty_id );

            IF 	(l_return_status = 'S' ) THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream Id for purpose LATE_INTEREST retrieved.');
            ELSE
            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Could not retrieve Stream Id for purpose LATE_INTEREST.');
           END IF;

           IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_ERROR;
           END IF;
            --check for stream
            l_stm_id := null;
            l_se_line_number := null;

              OPEN  l_AR_stream_csr(l_inv_cur.contract_id, l_sty_id);
              FETCH l_AR_stream_csr INTO l_stm_id;
              CLOSE l_AR_stream_csr;

            --create stream for late interest
            IF (l_stm_id IS NULL) THEN
              l_stmv_rec := l_init_stmv_rec;

              OPEN  c_tran_num_csr;
              FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
              CLOSE c_tran_num_csr;

              l_stmv_rec.sty_id                := l_sty_id;
              l_stmv_rec.khr_id                := l_inv_cur.contract_id;
              -- l_stmv_rec.sgn_code              := 'MANL'  -- bug 6472228
              l_stmv_rec.sgn_code              := G_LATE_SGN_CODE; -- bug 6472228
              l_stmv_rec.say_code              := 'CURR';
              l_stmv_rec.active_yn             := 'Y';
              l_stmv_rec.date_current          := sysdate;
              l_stmv_rec.comments              := 'LATE INTEREST BILLING';

              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Creating LATE INTEREST Stream');

              Okl_Streams_Pub.create_streams(
                 p_api_version    =>     p_api_version,
                 p_init_msg_list  =>     p_init_msg_list,
                 x_return_status  =>     x_return_status,
                 x_msg_count      =>     x_msg_count,
                 x_msg_data       =>     x_msg_data,
                 p_stmv_rec       =>     l_stmv_rec,
                 x_stmv_rec       =>     lx_stmv_rec);

              l_stm_id := lx_stmv_rec.id;
              l_se_line_number := 1;

              IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                l_error_flag := TRUE;
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Creating Stream for LATE INTEREST');
              ELSE
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- SUCCESS: Creating Stream for LATE INTEREST');
              END IF;
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream element line number => ' || l_se_line_number);
            ELSE
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream for LATE INTEREST found');
              open l_stream_line_nbr_csr(l_stm_id);
              fetch l_stream_line_nbr_csr into l_se_line_number;
              close l_stream_line_nbr_csr;
              l_se_line_number := l_se_line_number + 1;
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream element line number => ' || l_se_line_number);
            END IF;

            --create stream element for late interest
            IF (l_stm_id IS NOT NULL) THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Creating Stream Element for LATE INTEREST');
              l_selv_rec := l_init_selv_rec;

              l_selv_rec.stm_id 				   := l_stm_id;
              l_selv_rec.SE_LINE_NUMBER          := l_se_line_number;
              l_selv_rec.STREAM_ELEMENT_DATE     := sysdate;
              l_selv_rec.AMOUNT                  := l_interest_amount;
              l_selv_rec.COMMENTS                := 'LATE INTEREST BILLING ELEMENTS';
              l_selv_rec.ACCRUED_YN			   := 'Y';

              l_selv_rec.source_table := cns_source_table;

              l_selv_rec.source_id :=l_inv_cur.RECEIVABLES_INVOICE_ID;

              Okl_Sel_Pvt.insert_row(
                 p_api_version,
                 p_init_msg_list,
                 x_return_status,
                 x_msg_count,
                 x_msg_data,
                 l_selv_rec,
                 lx_selv_rec);

              l_sel_id := lx_selv_rec.id;
              l_sec_stream_id := lx_selv_rec.source_id;

              IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                      l_error_flag := TRUE;
                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,  '        -- Error Creating Stream Element for Contract: '
                                          ||l_inv_cur.contract_number
                                          ||' Stream Purpose: '||cns_late_interest
                                          ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                          ||' Amount: '||l_interest_amount);
              ELSE

                  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '         -- Created Late Interest Stream Element for Contract: '
                                        ||l_inv_cur.contract_number
                                        ||' Stream Purpose: '||cns_late_interest
                                        ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                        ||' Amount: '||l_interest_amount
                                      );
              END IF;
            END IF;

            ----------------------------------------------------------------
            --PROCESSING FOR LATE INTEREST PAYABLE TO INVESTOR
            ----------------------------------------------------------------
            if l_inv_cur.invoice_flag = 'AR-INVOICE' then
              FOR cur_sec_strm IN c_sec_strm_AR_csr(l_inv_cur.contract_id, l_inv_cur.RECEIVABLES_INVOICE_ID) LOOP
                --get stream type id
                 l_sty_id := null;

                 Okl_Streams_Util.get_primary_stream_type(
                      p_khr_id => cur_sec_strm.khr_id,
                      p_primary_sty_purpose => cns_late_interest_payable,
                      x_return_status => l_return_status,
                      x_primary_sty_id => l_sty_id );

                 IF 	(l_return_status = 'S' ) THEN
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream Id for purpose INVESTOR_LATE_INTEREST_PAY retrieved.');
                 ELSE
                    FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Could not retrieve Stream Id for purpose INVESTOR_LATE_INTEREST_PAY.');
                 END IF;

                 IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                   RAISE Okl_Api.G_EXCEPTION_ERROR;
                 END IF;
                  --check for stream
                 l_stm_id := null;
                 l_se_line_number := null;

                 OPEN  l_AR_stream_csr(l_inv_cur.contract_id, l_sty_id);
                 FETCH l_AR_stream_csr INTO l_stm_id;
                 CLOSE l_AR_stream_csr;

                 --create stream for late interest payable
                 IF (l_stm_id IS NULL) THEN
                   l_stmv_rec := l_init_stmv_rec;

                   OPEN  c_tran_num_csr;
                   FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
                   CLOSE c_tran_num_csr;

                   l_stmv_rec.sty_id                := l_sty_id;
                   l_stmv_rec.khr_id                := l_inv_cur.contract_id;
                   -- l_stmv_rec.sgn_code              := 'MANL'; -- bug 6472228
                   l_stmv_rec.sgn_code              := G_LATE_SGN_CODE;  -- bug 6472228
                   l_stmv_rec.say_code              := 'CURR';
                   l_stmv_rec.active_yn             := 'Y';
                   l_stmv_rec.date_current          := sysdate;
                   l_stmv_rec.comments              := 'INVESTOR LATE INTEREST PAYABLE';
                   IF (cur_sec_strm.khr_id IS NOT NULL) THEN
                       l_stmv_rec.source_id :=  cur_sec_strm.khr_id;
                       l_stmv_rec.source_table := 'OKL_K_HEADERS';
                   END IF;

                   FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Creating INVESTOR LATE INTEREST PAYABLE Stream');

                   Okl_Streams_Pub.create_streams(
                     p_api_version    =>     p_api_version,
                     p_init_msg_list  =>     p_init_msg_list,
                     x_return_status  =>     x_return_status,
                     x_msg_count      =>     x_msg_count,
                     x_msg_data       =>     x_msg_data,
                     p_stmv_rec       =>     l_stmv_rec,
                     x_stmv_rec       =>     lx_stmv_rec);

                    l_stm_id := lx_stmv_rec.id;
                    l_se_line_number := 1;

                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream element line number => ' || l_se_line_number);
                    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                      l_error_flag := TRUE;
                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Creating Stream for INVESTOR LATE INTEREST PAYABLE');
                    ELSE
                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- SUCCESS: Creating Stream for INVESTOR LATE INTEREST PAYABLE');
                    END IF;
                  ELSE
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream for INVESTOR LATE INTEREST PAYABLE found');
                    open l_stream_line_nbr_csr(l_stm_id);
                    fetch l_stream_line_nbr_csr into l_se_line_number;
                    close l_stream_line_nbr_csr;
                    l_se_line_number := l_se_line_number + 1;
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream element line number => ' || l_se_line_number);
                  END IF;

                  --create stream element for late interest payable
                  IF (l_stm_id IS NOT NULL) THEN
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Creating INVESTOR LATE INTEREST PAYABLE Stream Elements');
                    l_selv_rec := l_init_selv_rec;
                    l_selv_rec.stm_id 				 := l_stm_id;
                    l_selv_rec.SE_LINE_NUMBER          := l_se_line_number;
                    l_selv_rec.STREAM_ELEMENT_DATE     := sysdate;
                    l_selv_rec.AMOUNT                  := l_interest_amount;
                    l_selv_rec.COMMENTS                := 'INVESTOR LATE INTEREST PAYABLE ELEMENTS';
                    l_selv_rec.ACCRUED_YN			     := 'Y';
                    l_selv_rec.sel_id := l_sel_id;
                    IF (cur_sec_strm.khr_id IS NOT NULL) THEN
                       l_selv_rec.source_id :=  cur_sec_strm.khr_id;
                       l_selv_rec.source_table := 'OKL_K_HEADERS';
                    END IF;

                    Okl_Sel_Pvt.insert_row(
                      p_api_version,
                      p_init_msg_list,
                      x_return_status,
                      x_msg_count,
                      x_msg_data,
                      l_selv_rec,
                      lx_selv_rec);

                      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                         l_error_flag := TRUE;
                         FND_FILE.PUT_LINE (FND_FILE.OUTPUT,  '        -- Error Creating Payable Stream Element for Contract: '
                            ||l_inv_cur.contract_number
                            ||' Stream Purpose: '||cns_late_interest
                            ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                            ||' Amount: '||l_interest_amount);
                      ELSE
                        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '         -- Created Investor Late Interest Payable Stream Element for Contract: '
                            ||l_inv_cur.contract_number
                            ||' Stream Purpose: '||cns_late_interest
                            ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                            ||' Amount: '||l_interest_amount
                           );
                     END IF;
                  END IF;
                END LOOP;
              ELSE

                FOR cur_sec_strm IN c_sec_strm_cons_csr(l_inv_cur.contract_id, l_inv_cur.RECEIVABLES_INVOICE_ID) LOOP
                  --get stream type id
                  l_sty_id := null;

                  Okl_Streams_Util.get_primary_stream_type(
                       p_khr_id => cur_sec_strm.khr_id,
                       p_primary_sty_purpose => cns_late_interest_payable,
                       x_return_status => l_return_status,
                       x_primary_sty_id => l_sty_id );

                  IF 	(l_return_status = 'S' ) THEN
                  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream Id for purpose INVESTOR_LATE_INTEREST_PAY retrieved.');
               ELSE
                  FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Could not retrieve Stream Id for purpose INVESTOR_LATE_INTEREST_PAY.');
                 END IF;

                 IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                   RAISE Okl_Api.G_EXCEPTION_ERROR;
                 END IF;
                  --check for stream
                 l_stm_id := null;
                 l_se_line_number := null;

                 OPEN  l_cons_stream_csr(l_inv_cur.contract_id,cur_sec_strm.kle_id,l_sty_id);
                 FETCH l_cons_stream_csr INTO l_stm_id;
                 CLOSE l_cons_stream_csr;

                 --create stream for late interest payable
                 IF ((l_stm_id IS NULL) or (l_stm_id = -99))THEN
                    l_stmv_rec := l_init_stmv_rec;

                    OPEN  c_tran_num_csr;
                    FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
                    CLOSE c_tran_num_csr;

                    l_stmv_rec.sty_id                := l_sty_id;
                    l_stmv_rec.khr_id                := l_inv_cur.contract_id;
                    -- l_stmv_rec.sgn_code              := 'MANL'; -- bug 6472228
                    l_stmv_rec.sgn_code              := G_LATE_SGN_CODE;  -- bug 6472228
                    l_stmv_rec.say_code              := 'CURR';
                    l_stmv_rec.active_yn             := 'Y';
                    l_stmv_rec.date_current          := sysdate;
                    l_stmv_rec.comments              := 'INVESTOR LATE INTEREST PAYABLE';
                    IF (cur_sec_strm.khr_id IS NOT NULL) THEN
                             l_stmv_rec.source_id :=  cur_sec_strm.khr_id;
                             l_stmv_rec.source_table := 'OKL_K_HEADERS';
                    END IF;

                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Creating INVESTOR LATE INTEREST PAYABLE Stream');

                    Okl_Streams_Pub.create_streams(
                     p_api_version    =>     p_api_version,
                     p_init_msg_list  =>     p_init_msg_list,
                     x_return_status  =>     x_return_status,
                     x_msg_count      =>     x_msg_count,
                     x_msg_data       =>     x_msg_data,
                     p_stmv_rec       =>     l_stmv_rec,
                     x_stmv_rec       =>     lx_stmv_rec);

                    l_stm_id := lx_stmv_rec.id;
                    l_se_line_number := 1;

                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream element line number => ' || l_se_line_number);
                    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                      l_error_flag := TRUE;
                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Creating Stream for INVESTOR LATE INTEREST PAYABLE');
                    ELSE
                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- SUCCESS: Creating Stream for INVESTOR LATE INTEREST PAYABLE');
                    END IF;
                  ELSE
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream for INVESTOR LATE INTEREST PAYABLE found');
                    open l_stream_line_nbr_csr(l_stm_id);
                    fetch l_stream_line_nbr_csr into l_se_line_number;
                    close l_stream_line_nbr_csr;
                    l_se_line_number := l_se_line_number + 1;
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream element line number => ' || l_se_line_number);
                  END IF;

                  --create stream element for late interest payable
                  IF (l_stm_id IS NOT NULL) THEN
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Creating INVESTOR LATE INTEREST PAYABLE Stream Elements');
                    l_selv_rec := l_init_selv_rec;
                    l_selv_rec.stm_id 				 := l_stm_id;
                    l_selv_rec.SE_LINE_NUMBER          := l_se_line_number;
                    l_selv_rec.STREAM_ELEMENT_DATE     := sysdate;
                    l_selv_rec.AMOUNT                  := l_interest_amount;
                    l_selv_rec.COMMENTS                := 'INVESTOR LATE INTEREST PAYABLE ELEMENTS';
                    l_selv_rec.ACCRUED_YN			     := 'Y';
                    l_selv_rec.sel_id := l_sel_id;
                    IF (cur_sec_strm.khr_id IS NOT NULL) THEN
                        l_selv_rec.source_id :=  cur_sec_strm.khr_id;
                        l_selv_rec.source_table := 'OKL_K_HEADERS';
                    END IF;

                    Okl_Sel_Pvt.insert_row(
                      p_api_version,
                      p_init_msg_list,
                      x_return_status,
                      x_msg_count,
                      x_msg_data,
                      l_selv_rec,
                      lx_selv_rec);

                    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                          l_error_flag := TRUE;
                          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,  '        -- Error Creating Payable Stream Element for Contract: '
                                              ||l_inv_cur.contract_number
                                              ||' Stream Purpose: '||cns_late_interest
                                              ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                              ||' Amount: '||l_interest_amount);
                    ELSE

                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '         -- Created Investor Late Interest Payable Stream Element for Contract: '
                                            ||l_inv_cur.contract_number
                                            ||' Stream Purpose: '||cns_late_interest
                                            ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                            ||' Amount: '||l_interest_amount
                                          );
                     END IF;
                  END IF;
                END LOOP;
              END IF;
            END IF; -- END IF l_interest_amount > 0

            IF l_inv_cur.INVOICE_FLAG = 'AR-INVOICE'  THEN
              IF NOT(l_error_flag) THEN
                FOR l_lsm IN l_AR_lsm_cur(l_inv_cur.RECEIVABLES_INVOICE_ID, l_inv_cur.CONTRACT_ID)
                LOOP
                  Update OKL_TXD_AR_LN_DTLS_B
                  set LATE_INT_ASS_YN = 'Y'
                    , LATE_INT_ASSESS_DATE = SYSDATE
                    ,last_updated_by = l_last_updated_by
                    ,last_update_date = sysdate
                    ,last_update_login = l_last_update_login
                    ,request_id = l_request_id
                  WHERE CURRENT OF l_AR_lsm_cur;

                  --  IF 	(l_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
                  IF (SQL%NOTFOUND) THEN
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '         --  Internal Consolidation Record Update Unsuccessful.');
                  ELSE
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '         --  Internal Consolidation Record Updated.');
                  END IF;
                  --  END IF;

                END LOOP;
              END IF;
            END IF;
            IF l_inv_cur.INVOICE_FLAG = 'CONS-INVOICE'  THEN
              IF NOT(l_error_flag) THEN
                 FOR l_lsm IN l_cons_lsm_cur(l_inv_cur.RECEIVABLES_INVOICE_ID, l_inv_cur.CONTRACT_ID)
                 LOOP
                   Update okl_cnsld_ar_strms_b
                   set LATE_INT_ASS_YN = 'Y'
                     , LATE_INT_ASSESS_DATE = SYSDATE
                     ,last_updated_by = l_last_updated_by
                     ,last_update_date = sysdate
                     ,last_update_login = l_last_update_login
                     ,request_id = l_request_id
                   WHERE CURRENT OF l_cons_lsm_cur;

                   --  IF  (l_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
                   IF (SQL%NOTFOUND) THEN
                     FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '         --  Internal Consolidation Record Update Unsuccessful.');
                   ELSE
                     FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '         --  Internal Consolidation Record Updated.');
                   END IF;
                --  END IF;

                 END LOOP;
               END IF;
             END IF;


          END IF;
          --dkagrawa bug# 4728636 changes start
          IF l_prev_khr_id IS NULL THEN
            l_prev_khr_id := l_inv_cur.contract_id;
          END IF;
          IF l_prev_khr_id <> l_inv_cur.contract_id THEN
            IF NOT(l_error_flag) THEN
              OKL_BILLING_CONTROLLER_PVT.track_next_bill_date ( l_prev_khr_id );
            END IF;
            l_prev_khr_id := l_inv_cur.contract_id;
          END IF;
      END LOOP;
      IF l_prev_khr_id IS NOT NULL THEN
        IF NOT(l_error_flag) THEN
          OKL_BILLING_CONTROLLER_PVT.track_next_bill_date ( l_prev_khr_id );
        END IF;
      END IF;
     --dkagrawa bug# 4728636 changes end


      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'End of Calculate Late Interest.');
      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
        x_return_status := Okl_Api.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
      WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXCP) => '||SQLERRM);
        x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
      WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (Others) => '||SQLERRM);
        x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    END calculate_late_interest;

END OKL_LTE_INT_PVT;


/
