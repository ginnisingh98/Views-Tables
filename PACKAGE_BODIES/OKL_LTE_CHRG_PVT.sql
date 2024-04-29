--------------------------------------------------------
--  DDL for Package Body OKL_LTE_CHRG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LTE_CHRG_PVT" AS
/* $Header: OKLRCHGB.pls 120.20.12010000.3 2009/06/02 10:37:03 racheruv ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.FEES';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

-- Bug 6472228 - Added constant for Late fee/interest calculation SGN_CODE
G_LATE_SGN_CODE CONSTANT VARCHAR2(10) := 'LATE_CALC';


  PROCEDURE calculate_late_charge(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
     ) IS



    l_hd_id							NUMBER;
    l_found							BOOLEAN;
    l_api_version                   CONSTANT NUMBER := 1;
    l_api_name                      CONSTANT VARCHAR2(30) := 'calculate_late_charge';
    l_return_status                 VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_init_msg_list                 VARCHAR2(1) ;
    l_msg_count                     NUMBER ;

    i                               NUMBER := 0;

    l_rec_inv_id                    OKL_CNSLD_AR_STRMS_B.RECEIVABLES_INVOICE_ID%type;
    l_rec_inv_contract_id               NUMBER;
    l_amt_due_remaining             AR_PAYMENT_SCHEDULES_ALL.AMOUNT_DUE_REMAINING%type;
    l_due_date                      AR_PAYMENT_SCHEDULES_ALL.DUE_DATE%type;
    l_khr_id                        OKL_CNSLD_AR_STRMS_B.KHR_ID%type;
    l_sty_id                        OKL_STRM_TYPE_V.ID%TYPE;
    l_stm_id                        OKL_STREAMS_V.ID%TYPE;
    l_late_stm_id                   OKL_STREAMS_V.ID%TYPE;
    l_se_line_number                OKL_STRM_ELEMENTS_V.SE_LINE_NUMBER%TYPE;
    l_amount                        NUMBER;
    l_stream_purpose                OKL_STRM_TYPE_V.stream_type_purpose%TYPE;
    l_sec_rec_inv_id                 OKL_CNSLD_AR_STRMS_V.ID%TYPE;
    l_error_flag                    BOOLEAN := FALSE;

    --start code pgomes 12/18/2002
    l_func_currency                okl_k_headers_full_v.currency_code%TYPE := okl_accounting_util.get_func_curr_code;
    l_contract_currency            okl_k_headers_full_v.currency_code%TYPE;
    l_prev_contract_currency       okl_k_headers_full_v.currency_code%TYPE;
    l_late_policy                  okl_late_policies_v.name%TYPE;
    l_prev_late_policy             okl_late_policies_v.name%TYPE;


    l_late_chrg_amount             okl_late_policies_b.late_chrg_amount%TYPE;
    l_minimum_late_charge          okl_late_policies_b.minimum_late_charge%TYPE;
    l_maximum_late_charge          okl_late_policies_b.maximum_late_charge%TYPE;
    l_late_chrg_minimum_balance    okl_late_policies_b.late_chrg_minimum_balance%TYPE;
    l_late_chrg_fixed_yn           okl_late_policies_v.late_chrg_fixed_yn%TYPE;
    l_late_chrg_allowed_yn         okl_late_policies_v.late_chrg_allowed_yn%TYPE;
    l_late_chrg_rate               okl_late_policies_v.late_chrg_rate%TYPE;

    l_late_charge_amt              okl_strm_elements_v.amount%TYPE;

    l_currency_conversion_type okl_k_headers_full_v.currency_conversion_type%type;
    l_currency_conversion_rate okl_k_headers_full_v.currency_conversion_rate%type;
    l_currency_conversion_date okl_k_headers_full_v.currency_conversion_date%type;

    l_last_updated_by   NUMBER;
    l_last_update_login NUMBER;
    l_request_id NUMBER;
    --end code pgomes 12/18/2002

    l_lsmv_rec                      lsmv_rec_type;
    lx_lsmv_rec                     lsmv_rec_type;


    l_stmv_rec          Okl_Streams_Pub.stmv_rec_type;
    lx_stmv_rec         Okl_Streams_Pub.stmv_rec_type;
    l_init_stmv_rec     Okl_Streams_Pub.stmv_rec_type;

    l_selv_rec          Okl_Sel_Pvt.selv_rec_type;
    lx_selv_rec         Okl_Sel_Pvt.selv_rec_type;
    l_init_selv_rec     Okl_Sel_Pvt.selv_rec_type;
    l_sel_id            Okl_strm_elements_v.sel_id%TYPE;
    l_prev_khr_id       okl_k_headers.id%TYPE;     --dkagrawa added for bug# 4728636

    --vdamerla bug 5474844
    l_investor_disb_flag varchar2(1);

    -- vdamerla  bug 5474844  modified this cursor for R12 B Billing Architecture
    --made changes to cursor data elements, table names, where clauses

    --fetches late invoices which have never been charged a late fee
    CURSOR l_late_invs_cur IS
         select  lte.name late_policy
                ,khr.currency_code
                ,lpt1.contract_number
                ,lpt1.contract_id
                ,NULL   consolidated_invoice_id
                ,lpt1.trx_number consolidated_invoice_number
                ,sum(lpt1.amount_due_remaining)  amount_due_remaining
                ,max(lpt.due_date) due_date
           from
              (SELECT
                   PAY_SCH.DUE_DATE DUE_DATE, RACTRX.STATUS_TRX STATUS,
                   RACTRX.CUSTOMER_TRX_ID INVOICE_ID,
                   PAY_SCH.CLASS PAY_SCH_CLASS
               FROM
                  RA_CUSTOMER_TRX_ALL RACTRX,
                  RA_CUST_TRX_TYPES_ALL RATRXTYPE,
                  AR_PAYMENT_SCHEDULES_ALL PAY_SCH
               WHERE
                   RACTRX.CUST_TRX_TYPE_ID = RATRXTYPE.CUST_TRX_TYPE_ID
                and RACTRX.CUSTOMER_TRX_ID = PAY_SCH.CUSTOMER_TRX_ID
                and RACTRX.ORG_ID = RATRXTYPE.ORG_ID ) lpt
                   ,okl_bpd_ar_inv_lines_v lpt1
                   ,okl_k_headers_full_v khr
                   ,okc_rule_groups_b rgp
                   ,okc_rules_b rul
                   ,okc_rules_b rul_exm
                   ,okc_rules_b rul_hld
                   ,okl_late_policies_v lte
                   ,okl_strm_type_b stb --For bug 7356486
           where    lpt.invoice_id=lpt1.invoice_id
           and      lpt.pay_sch_class = 'INV'
           AND      lpt.STATUS = 'OP'
           and      nvl(lpt1.late_charge_ass_yn, 'N') = 'N'
           and      lpt1.contract_number = khr.contract_number
           AND      lpt1.sty_id = stb.id --For bug 7356486
           AND      lpt1.stream_type_id = stb.id --For bug 7356486
           and      khr.id = rgp.dnz_chr_id
           and      rgp.rgd_code = 'LALCGR'
           and      khr.id = rul.dnz_chr_id
           and      rgp.id = rul.rgp_id
           and      rul.rule_information_category = 'LALCPR'
           and      rul.rule_information1 = lte.id
           and      (lte.late_policy_type_code = 'LCT' or lte.late_policy_type_code = 'CHG')
           and      (trunc(lpt.due_date) + nvl(lte.late_chrg_grace_period, 0)) < trunc(sysdate)
           and      khr.id = rul_exm.dnz_chr_id
           and      rgp.id = rul_exm.rgp_id
           and      rul_exm.rule_information_category = 'LALCEX'
           and      NVL(rul_exm.rule_information1, 'N') = 'N'
           and not exists (select 1 from okl_strm_type_exempt_v sty_exm
                           where    lte.id = sty_exm.lpo_id
                           and      lpt1.stream_type_id = sty_exm.sty_id
                           and      NVL(sty_exm.late_policy_exempt_yn, 'N') = 'Y')
           and      khr.id = rul_hld.dnz_chr_id
           and      rgp.id = rul_hld.rgp_id
           and      rul_hld.rule_information_category = 'LAHUDT'
           and      TRUNC(NVL(FND_DATE.canonical_to_date(rul_hld.rule_information1), sysdate - 1)) < trunc(sysdate)
           and      khr.authoring_org_id = MO_GLOBAL.get_current_org_id
           and      stb.STREAM_TYPE_PURPOSE <> 'LATE_FEE' -- for bug 7295166 -- Don't charge late charge on late charge.
            group by lte.name
                  ,khr.currency_code
                  ,lpt1.contract_number
                  ,lpt1.contract_id
                  ,null
                  ,lpt1.trx_number
                  ,lpt.due_date
          UNION
          select  lte.name late_policy
                ,khr.currency_code
                ,CN.contract_number
                ,ST.khr_id
                ,HD.id
                ,HD.consolidated_invoice_number
                ,sum(PS.amount_due_remaining)  amount_due_remaining
                ,PS.due_date
         from    AR_PAYMENT_SCHEDULES_ALL PS
                ,OKL_CNSLD_AR_STRMS_B ST
                ,OKL_CNSLD_AR_HDRS_B HD
                ,OKC_K_HEADERS_ALL_B CN
                ,OKL_CNSLD_AR_LINES_B LN
                ,OKL_STRM_TYPE_B SM
                ,okl_k_headers_full_v khr
                ,okc_rule_groups_b rgp
                ,okc_rules_b rul
                ,okc_rules_b rul_exm
                ,okc_rules_b rul_hld
                ,okl_late_policies_v lte
         where    PS.CLASS IN ('INV', 'CM')
         AND      ST.RECEIVABLES_INVOICE_ID = PS.CUSTOMER_TRX_ID
         AND      LN.ID = ST.LLN_ID
         AND      HD.ID = LN.CNR_ID
         AND      SM.ID = ST.STY_ID
         AND      CN.ID = ST.KHR_ID
         AND      HD.ORG_ID = MO_GLOBAL.get_current_org_id
         AND      ps.class = 'INV'
         AND      ps.STATUS = 'OP'
         and      nvl(st.late_charge_ass_yn, 'N') = 'N'
         and      st.khr_id = khr.id
         and      khr.id = rgp.dnz_chr_id
         and      rgp.rgd_code = 'LALCGR'
         and      khr.id = rul.dnz_chr_id
         and      rgp.id = rul.rgp_id
         and      rul.rule_information_category = 'LALCPR'
         and      rul.rule_information1 = lte.id
         and      (lte.late_policy_type_code = 'LCT' or lte.late_policy_type_code = 'CHG')
         and      (trunc(ps.due_date) + nvl(lte.late_chrg_grace_period, 0)) < trunc(sysdate)
         and      khr.id = rul_exm.dnz_chr_id
         and      rgp.id = rul_exm.rgp_id
         and      rul_exm.rule_information_category = 'LALCEX'
         and      NVL(rul_exm.rule_information1, 'N') = 'N'
         and not exists (select 1 from okl_strm_type_exempt_v sty_exm
                         where    lte.id = sty_exm.lpo_id
                         and      SM.id = sty_exm.sty_id
                         and      NVL(sty_exm.late_policy_exempt_yn, 'N') = 'Y')
         and      khr.id = rul_hld.dnz_chr_id
         and      rgp.id = rul_hld.rgp_id
         and      rul_hld.rule_information_category = 'LAHUDT'
         and      TRUNC(NVL(FND_DATE.canonical_to_date(rul_hld.rule_information1), sysdate - 1)) < trunc(sysdate)
         and      khr.authoring_org_id = MO_GLOBAL.get_current_org_id
         and      SM.STREAM_TYPE_PURPOSE <> 'LATE_FEE' -- for bug 7295166 -- Don't charge late charge on late charge.
         group by lte.name
                ,khr.currency_code
                ,CN.contract_number
                ,ST.KHR_id
                ,HD.id
                ,HD.consolidated_invoice_number
                ,PS.due_date;


    --vdamerla  bug 5474844 modified this cursor for R12 B Billing Architecture
    --modified cursor data elements, table names, where clause, group by clause
    --fetches late invoices which are late again

    CURSOR l_late_invs_cur1 IS
    SELECT   lte.name late_policy
             ,khr.currency_code
             ,orig_arl.contract_number
             ,orig_arl.contract_id contract_id
             ,NULL   consolidated_invoice_id
             ,orig_arl.trx_number consolidated_invoice_number
             ,sum(orig_arl.amount_due_remaining)  amount_due_remaining
             ,max(last_arv.due_date) due_date
    FROM   (SELECT
              PAY_SCH.DUE_DATE DUE_DATE, RACTRX.STATUS_TRX STATUS,
              RACTRX.CUSTOMER_TRX_ID INVOICE_ID,
              PAY_SCH.CLASS PAY_SCH_CLASS
            FROM
              RA_CUSTOMER_TRX_ALL RACTRX,
              RA_CUST_TRX_TYPES_ALL RATRXTYPE,
              AR_PAYMENT_SCHEDULES_ALL PAY_SCH
            WHERE
                  RACTRX.CUST_TRX_TYPE_ID = RATRXTYPE.CUST_TRX_TYPE_ID
              and RACTRX.CUSTOMER_TRX_ID = PAY_SCH.CUSTOMER_TRX_ID
              and RACTRX.ORG_ID = RATRXTYPE.ORG_ID ) orig_arv
           ,(SELECT
              PAY_SCH.DUE_DATE DUE_DATE, RACTRX.STATUS_TRX STATUS,
              RACTRX.CUSTOMER_TRX_ID INVOICE_ID,
              PAY_SCH.CLASS PAY_SCH_CLASS
            FROM
              RA_CUSTOMER_TRX_ALL RACTRX,
              RA_CUST_TRX_TYPES_ALL RATRXTYPE,
              AR_PAYMENT_SCHEDULES_ALL PAY_SCH
            WHERE
                  RACTRX.CUST_TRX_TYPE_ID = RATRXTYPE.CUST_TRX_TYPE_ID
              and RACTRX.CUSTOMER_TRX_ID = PAY_SCH.CUSTOMER_TRX_ID
              and RACTRX.ORG_ID = RATRXTYPE.ORG_ID ) last_arv
           ,okl_bpd_ar_inv_lines_v orig_arl
           ,okl_bpd_ar_inv_lines_v last_arl
           ,okl_strm_elements_v sel
           ,okl_k_headers_full_v khr
           ,okc_rule_groups_b rgp
           ,okc_rules_b rul
           ,okc_rules_b rul_exm
           ,okc_rules_b rul_hld
           ,okl_late_policies_v lte
    WHERE    last_arl.sel_id = sel.id
    and      orig_arv.pay_sch_class = 'INV'
    AND      orig_arv.STATUS = 'OP'
    and      orig_arl.receivables_invoice_id = sel.source_id
    and      sel.source_table='RA_CUSTOMER_TRX_LINES_ALL'
    and      orig_arl.late_charge_ass_yn = 'Y'
    and      nvl(last_arl.late_charge_ass_yn, 'N') = 'N'
    and      orig_arv.invoice_id = orig_arl.invoice_id
    and      last_arv.invoice_id = last_arl.invoice_id
    and      orig_arl.contract_id=last_arl.contract_id
    and      orig_arl.contract_id = khr.id
    and      khr.id = rgp.dnz_chr_id
    and      rgp.rgd_code = 'LALCGR'
    and      rgp.id = rul.rgp_id
    and      khr.id = rul.dnz_chr_id
    and      rul.rule_information_category = 'LALCPR'
    and      rul.rule_information1 = lte.id
    and      (lte.late_policy_type_code = 'LCT' or lte.late_policy_type_code = 'CHG')
    and      khr.id = rul_exm.dnz_chr_id
    and      rgp.id = rul_exm.rgp_id
    and      rul_exm.rule_information_category = 'LALCEX'
    and      NVL(rul_exm.rule_information1, 'N') = 'N'
    and not exists (select 1 from okl_strm_type_exempt_v sty_exm
                    where    lte.id = sty_exm.lpo_id
                    and      orig_arl.stream_type_id = sty_exm.sty_id
                    and      NVL(sty_exm.late_policy_exempt_yn, 'N') = 'Y')
    and      khr.id = rul_hld.dnz_chr_id
    and      rgp.id = rul_hld.rgp_id
    and      rul_hld.rule_information_category = 'LAHUDT'
    and      TRUNC(NVL(FND_DATE.canonical_to_date(rul_hld.rule_information1), sysdate - 1)) < trunc(sysdate)
    and      khr.authoring_org_id = MO_GLOBAL.get_current_org_id
    and exists (select'x'  from ra_customer_trx_lines_all trxl where trxl.customer_trx_id=orig_arv.invoice_id and
                trxl.interface_line_attribute6=khr.contract_number)
    and exists (select'x'  from ra_customer_trx_lines_all trxl where trxl.customer_trx_id=last_arv.invoice_id and
                trxl.interface_line_attribute6=khr.contract_number)

    group by  lte.name, khr.currency_code, orig_arl.contract_id,orig_arl.contract_number
              ,orig_arl.receivables_invoice_number, orig_arl.receivables_invoice_id
              ,orig_arl.amount_due_remaining, lte.late_chrg_grace_period
    having      (trunc(max(last_arv.due_date)) + nvl(lte.late_chrg_grace_period, 0))  < trunc(sysdate)
    UNION
    select    lte.name late_policy
             ,khr.currency_code
             ,orig.contract_number
             ,orig.contract_id
             ,orig.consolidated_invoice_id
             ,orig.consolidated_invoice_number
             ,sum(orig.amount_due_remaining) amount_due_remaining
             , max(last.due_date) due_date
       from
             (SELECT
                  HD.ID CONSOLIDATED_INVOICE_ID ,
                  HD.CONSOLIDATED_INVOICE_NUMBER CONSOLIDATED_INVOICE_NUMBER ,
                  ST.RECEIVABLES_INVOICE_ID RECEIVABLES_INVOICE_ID ,
                  ST.KHR_ID CONTRACT_ID ,
                  CN.CONTRACT_NUMBER CONTRACT_NUMBER ,
                  PS.DUE_DATE DUE_DATE ,
                  PS.AMOUNT_DUE_REMAINING AMOUNT_DUE_REMAINING ,
                  ST.LATE_CHARGE_ASS_YN LATE_CHARGE_ASS_YN,
                  ST.SEL_ID SEL_ID,
                  PS.CLASS CLASS ,
                  SM.ID STREAM_TYPE_ID,
                  PS.STATUS STATUS
              FROM AR_PAYMENT_SCHEDULES_ALL PS,
                   OKL_CNSLD_AR_STRMS_B ST,
                   OKL_CNSLD_AR_HDRS_B HD,
                   OKC_K_HEADERS_ALL_B CN,
                   OKL_CNSLD_AR_LINES_B LN,
                   OKL_STRM_TYPE_B SM
              WHERE PS.CLASS IN ('INV', 'CM')
                AND ST.RECEIVABLES_INVOICE_ID = PS.CUSTOMER_TRX_ID
                AND CN.ID = ST.KHR_ID
                AND LN.ID = ST.LLN_ID
                AND HD.ID = LN.CNR_ID
                AND SM.ID = ST.STY_ID) orig
             , (SELECT
                  HD.ID CONSOLIDATED_INVOICE_ID ,
                  HD.CONSOLIDATED_INVOICE_NUMBER CONSOLIDATED_INVOICE_NUMBER ,
                  ST.RECEIVABLES_INVOICE_ID RECEIVABLES_INVOICE_ID ,
                  ST.KHR_ID CONTRACT_ID ,
                  CN.CONTRACT_NUMBER CONTRACT_NUMBER ,
                  PS.DUE_DATE DUE_DATE ,
                  PS.AMOUNT_DUE_REMAINING AMOUNT_DUE_REMAINING ,
                  ST.LATE_CHARGE_ASS_YN LATE_CHARGE_ASS_YN,
                  ST.SEL_ID SEL_ID,
                  PS.CLASS CLASS ,
                  SM.ID STREAM_TYPE_ID,
                  PS.STATUS STATUS
                FROM AR_PAYMENT_SCHEDULES_ALL PS,
                     OKL_CNSLD_AR_STRMS_B ST,
                     OKL_CNSLD_AR_HDRS_B HD,
                     OKC_K_HEADERS_ALL_B CN,
                     OKL_CNSLD_AR_LINES_B LN,
                     OKL_STRM_TYPE_B SM
                WHERE PS.CLASS IN ('INV', 'CM')
                  AND ST.RECEIVABLES_INVOICE_ID = PS.CUSTOMER_TRX_ID
                  AND CN.ID = ST.KHR_ID
                  AND LN.ID = ST.LLN_ID
                  AND HD.ID = LN.CNR_ID
                  AND SM.ID = ST.STY_ID) last
               ,okl_strm_elements_v sel
               ,okl_k_headers_full_v khr
               ,okc_rule_groups_b rgp
               ,okc_rules_b rul
               ,okc_rules_b rul_exm
               ,okc_rules_b rul_hld
               ,okl_late_policies_v lte
       where    last.sel_id = sel.id
           and      orig.class = 'INV'
           and      orig.status = 'OP'
           and      orig.consolidated_invoice_id = sel.source_id
           and      sel.source_table = 'OKL_CNSLD_AR_STRMS_V'
           and      orig.late_charge_ass_yn = 'Y'
           and      nvl(last.late_charge_ass_yn, 'N') = 'N'
           and      orig.contract_id = last.contract_id
           and      orig.contract_id = khr.id
           and      khr.id = rgp.dnz_chr_id
           and      rgp.rgd_code = 'LALCGR'
           and      rgp.id = rul.rgp_id
           and      khr.id = rul.dnz_chr_id
           and      rul.rule_information_category = 'LALCPR'
           and      rul.rule_information1 = lte.id
           and      (lte.late_policy_type_code = 'LCT' or lte.late_policy_type_code = 'CHG')
           and      khr.id = rul_exm.dnz_chr_id
           and      rgp.id = rul_exm.rgp_id
           and      rul_exm.rule_information_category = 'LALCEX'
           and      NVL(rul_exm.rule_information1, 'N') = 'N'
           and not exists (select 1 from okl_strm_type_exempt_v sty_exm
                           where    lte.id = sty_exm.lpo_id
                           and      orig.stream_type_id = sty_exm.sty_id
                           and      NVL(sty_exm.late_policy_exempt_yn, 'N') = 'Y')
           and      khr.id = rul_hld.dnz_chr_id
           and      rgp.id = rul_hld.rgp_id
           and      rul_hld.rule_information_category = 'LAHUDT'
           and     TRUNC(NVL(FND_DATE.canonical_to_date(rul_hld.rule_information1), sysdate - 1)) < trunc(sysdate)
          -- and      khr.authoring_org_id = NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
          and      khr.authoring_org_id = MO_GLOBAL.get_current_org_id
           group by  lte.name, khr.currency_code, orig.contract_id,orig.contract_number
                    ,orig.consolidated_invoice_id, orig.consolidated_invoice_number
                    , lte.late_chrg_grace_period
         having      (trunc(max(last.due_date)) + nvl(lte.late_chrg_grace_period, 0)) < trunc(sysdate);


    CURSOR l_late_policy_cur(l_id IN VARCHAR2) IS
            SELECT  LATE_POLICY_TYPE_CODE
                  , LATE_CHRG_ALLOWED_YN
                  , LATE_CHRG_FIXED_YN
                  , NVL(LATE_CHRG_AMOUNT, 0) LATE_CHRG_AMOUNT
                  , NVL(LATE_CHRG_RATE, 0) LATE_CHRG_RATE
                  , NVL(LATE_CHRG_GRACE_PERIOD,0) LATE_CHRG_GRACE_PERIOD
                  , NVL(LATE_CHRG_MINIMUM_BALANCE, 0) LATE_CHRG_MINIMUM_BALANCE
                  , NVL(MINIMUM_LATE_CHARGE, 0) MINIMUM_LATE_CHARGE
                  , NVL(MAXIMUM_LATE_CHARGE, 9999999999) MAXIMUM_LATE_CHARGE
            FROM    OKL_LATE_POLICIES_V
            WHERE   NAME = l_id;

    -- vdamerla: bug 5474844  Get the late charge data

    -- cursor for consolidated invoices

     CURSOR l_cons_lsm_cur(l_consolidated_invoice_id IN NUMBER, l_khr_id in number) IS
              SELECT  lsm.id
            , LATE_CHARGE_ASS_YN
            , LATE_CHARGE_ASSESS_DATE
            FROM    OKL_CNSLD_AR_STRMS_B lsm,
                    OKL_CNSLD_AR_LINES_B lln,
                    OKL_CNSLD_AR_HDRS_B cnr
            WHERE  cnr.id = l_consolidated_invoice_id
            and    lln.cnr_id = cnr.id
            and     lsm.lln_id = lln.id
            and     lsm.KHR_ID = l_khr_id
            FOR UPDATE OF LATE_CHARGE_ASS_YN, LATE_CHARGE_ASSESS_DATE;


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
    cns_late_fee constant  varchar2(50) := 'LATE_FEE';
    cns_late_interest constant  varchar2(50) := 'LATE_INTEREST';
    cns_late_charge_payable constant  varchar2(50) := 'INVESTOR_LATE_FEE_PAYABLE';
    cns_AR_source_table constant varchar2(25) := 'RA_CUSTOMER_TRX_LINES_ALL';
    cns_cons_source_table constant varchar2(25) := 'OKL_CNSLD_AR_STRMS_V';

/*	------------------------------------------------------------
	-- Stream Id Cursor
	------------------------------------------------------------
    CURSOR l_sty_id_cur(cp_name IN VARCHAR2) IS
            SELECT id FROM okl_strm_type_v where name = cp_name;
*/
	------------------------------------------------------------
	-- Stream Cursor
	------------------------------------------------------------
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
    --  second cursor for consolidated invoices
    CURSOR l_stream_csr(cp_khr_id IN NUMBER
                   ,cp_sty_id IN NUMBER) IS
            SELECT stm.id
            FROM   okl_streams_v stm
            WHERE  stm.khr_id = cp_khr_id
            AND    stm.sty_id = cp_sty_id
            AND    stm.say_code = 'CURR'
            AND    stm.active_yn = 'Y';



	------------------------------------------------------------
	-- Stream Element Line Number Cursor
	------------------------------------------------------------
    CURSOR l_stream_line_nbr_csr(cp_stm_id IN NUMBER) IS
            SELECT max(se_line_number) se_line_number
            FROM okl_strm_elements_v
            WHERE stm_id = cp_stm_id;



-- vdamerla bug 5474844
  ------------------------------------------------------------
  -- Receivable invoice cursor
  ------------------------------------------------------------



     CURSOR l_receivables_inv_csr (cp_contract_id number, cp_trx_number varchar2)
     is
        select RECEIVABLES_INVOICE_ID, CONTRACT_ID
        from  okl_bpd_ar_inv_lines_v
        where contract_id=cp_contract_id
        and trx_number=cp_trx_number;


	------------------------------------------------------------
	-- Securitized streams Cursor
	------------------------------------------------------------


    CURSOR c_sec_strm_cons_csr(l_consolidated_invoice_id IN NUMBER, l_khr_id in number) IS
            select lsm.id cnsld_strm_id, pol.khr_id, ps.amount_due_remaining,lsm.kle_id
            from
                 okl_cnsld_ar_strms_b lsm
                , okl_cnsld_ar_hdrs_b cnr
                , okl_cnsld_ar_lines_b lln
                , okl_pool_contents_v pk
       --         , okl_pools_v pol
                , okl_pools pol
                , ar_payment_schedules_all ps
                , okl_strm_elements_v  sel
            where cnr.id = l_consolidated_invoice_id
            and   lln.cnr_id = cnr.id
            and   lsm.lln_id = lln.id
            and   lsm.khr_id = l_khr_id
            and   lsm.khr_id = pk.khr_id
            and   nvl(lsm.kle_id, -99) = nvl(pk.kle_id, -99)
            and   lsm.sty_id = pk.sty_id
            and   pk.pol_id = pol.id
            and   trunc(cnr.date_consolidated) between trunc(pk.streams_from_date) and trunc(pk.streams_to_date)
            and   lsm.receivables_invoice_id = ps.customer_trx_id
            and    ps.class = 'INV'
            and    ps.status = 'OP'
            and   lsm.sel_id = sel.id
            and   pk.status_code = 'ACTIVE' --Added by bkatraga for bug 6983321
			and    pk.stm_id = sel.stm_id
            AND   pk.status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE; --Added by VARANGAN -Pool Contents Impact(Bug#6658065)


    CURSOR c_sec_strm_AR_csr(cp_contract_id in number, cp_con_inv_number IN VARCHAR2) IS
    SELECT arl.id cnsld_strm_id
          ,pol.khr_id, pk.kle_id kle_id
    FROM okl_bpd_ar_inv_lines_v arl
        ,okl_bpd_ar_invoices_v arv
        ,okl_pool_contents_v pk
        ,okl_pools pol
    WHERE arl.trx_number  = cp_con_inv_number
    AND   arl.contract_id = cp_contract_id
    AND   arl.contract_id = pk.khr_id
    AND   nvl(arl.contract_line_id, -99) = nvl(pk.kle_id, -99)
    AND   arl.sty_id = pk.sty_id
    AND  pk.pol_id = pol.id
    AND arv.invoice_id = arl.invoice_id
    AND trunc(arv.date_consolidated) between trunc(pk.streams_from_date) and trunc(pk.streams_to_date)
    AND   pk.status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE; --Added by VARANGAN -Pool Contents Impact(Bug#6658065)

	------------------------------------------------------------
	-- Stream Type of Late Invoice Cursor
	------------------------------------------------------------
   --rkuttiya modified this cursor for R12 B Billing Architecture
   --modified view name, where clause

   CURSOR c_strm_purpose(cp_stream_id IN NUMBER) IS
    SELECT sty.stream_type_purpose
    FROM okl_bpd_ar_inv_lines_v arl
        ,okl_strm_type_b sty
    WHERE arl.id = cp_stream_id
    AND   arl.sty_id = sty.id;

	------------------------------------------------------------
	-- Source id of stream element of Late Invoice Cursor
	------------------------------------------------------------
    cursor c_AR_source_sel(cp_contract_number varchar2, cp_trx_number varchar2) is
    SELECT receivables_invoice_id
    FROM okl_bpd_ar_inv_lines_v
    WHERE contract_number = cp_contract_number
    AND        trx_number = cp_trx_number;
  ---
  ---  END DECLARE
  ---
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

      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Start of Calculate Late Charges.');

      SELECT FND_GLOBAL.USER_ID
         ,FND_GLOBAL.LOGIN_ID
         ,NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),null)
      INTO  l_last_updated_by
        ,l_last_update_login
        ,l_request_id
      FROM dual;

/* -- for bug 7295166 - start
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Subsequent late charges');
      FOR l_inv_cur IN l_late_invs_cur1
      LOOP
         FND_FILE.PUT_LINE (FND_FILE.LOG, 'Processing:Never Late: Receivables invoice => '||l_inv_cur.consolidated_invoice_number||
					  ' ,due date=> '||l_inv_cur.DUE_DATE||' and Amount=> '||l_inv_cur.AMOUNT_DUE_REMAINING
                      ||' ,Contract => '||l_inv_cur.CONTRACT_NUMBER );
        FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Late policy => ' || l_inv_cur.late_policy
                      || ' ,Contract currency => ' || l_inv_cur.currency_code);

       -- vdamerla bug 5474844
        open l_receivables_inv_csr(l_inv_cur.CONTRACT_ID,l_inv_cur.consolidated_invoice_number);
        fetch  l_receivables_inv_csr into  l_rec_inv_id,l_rec_inv_contract_id;
        close l_receivables_inv_csr;

        if l_inv_cur.CONSOLIDATED_INVOICE_ID is not null then
            l_rec_inv_id            := l_inv_cur.CONSOLIDATED_INVOICE_ID;
            -- Get the amount_due_remaining
            OKL_BILLING_UTIL_PVT.get_contract_invoice_balance(
                        p_api_version              =>  1.0
                       ,p_init_msg_list            =>  OKL_API.G_FALSE
                       ,p_contract_number          =>  l_inv_cur.CONTRACT_NUMBER
                       ,p_trx_number               =>  l_inv_cur.consolidated_invoice_number
                       ,x_return_status            =>  x_return_status
                       ,x_msg_count                =>  x_msg_count
                       ,x_msg_data                 =>  x_msg_data
                       ,x_remaining_amount         =>  l_amt_due_remaining);
           IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                l_error_flag := TRUE;
                FND_FILE.PUT_LINE (FND_FILE.LOG,  '        -- Error fetching Consolidated Invoice Balance for contract: '
                ||l_inv_cur.contract_number
                ||' consolidated_invoice_number: '||l_inv_cur.consolidated_invoice_number);
           ELSE
                FND_FILE.PUT_LINE (FND_FILE.LOG,  '        -- Successfully  fetched Consolidated Invoice Balance for contract: '
                ||l_inv_cur.contract_number
                ||' consolidated_invoice_number: '||l_inv_cur.consolidated_invoice_number
                ||'Invoice Balance:'|| l_amt_due_remaining);
           END IF;

        else
           l_amt_due_remaining     := l_inv_cur.AMOUNT_DUE_REMAINING;
           FND_FILE.PUT_LINE (FND_FILE.LOG, 'AR Invoice Balance => '||l_amt_due_remaining);
        end if;

        l_due_date              := l_inv_cur.DUE_DATE;
        l_khr_id                := l_inv_cur.CONTRACT_ID;
        l_contract_currency     := l_inv_cur.currency_code;
        l_late_policy           := l_inv_cur.late_policy;


        IF (nvl(l_late_policy, 'xxx') <> nvl(l_prev_late_policy, 'yyy') or
          nvl(l_contract_currency, 'aaa') <> nvl(l_prev_contract_currency, 'bbb')) THEN
          FOR l_lpo_cur IN l_late_policy_cur(l_late_policy)
          LOOP
            --start code pgomes 12/18/2002
            IF (l_func_currency <> NVL(l_contract_currency, '000')) THEN
              --convert late_chrg_amount to contract currency
              OKL_ACCOUNTING_UTIL.convert_to_contract_currency(
              p_khr_id  		  	=> l_khr_id,
              p_from_currency   		=> l_func_currency,
              p_transaction_date 		=> sysdate,
              p_amount 			=> l_lpo_cur.late_chrg_amount,
              x_contract_currency		=> l_contract_currency,
              x_currency_conversion_type	=> l_currency_conversion_type,
              x_currency_conversion_rate	=> l_currency_conversion_rate,
              x_currency_conversion_date	=> l_currency_conversion_date,
              x_converted_amount 		=> l_late_chrg_amount);

              l_late_chrg_amount := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_late_chrg_amount, l_contract_currency);

              --convert minimum_late_charge to contract currency
              OKL_ACCOUNTING_UTIL.convert_to_contract_currency(
              p_khr_id  		  	=> l_khr_id,
              p_from_currency   		=> l_func_currency,
              p_transaction_date 		=> sysdate,
              p_amount 			=> l_lpo_cur.minimum_late_charge,
              x_contract_currency		=> l_contract_currency,
              x_currency_conversion_type	=> l_currency_conversion_type,
              x_currency_conversion_rate	=> l_currency_conversion_rate,
              x_currency_conversion_date	=> l_currency_conversion_date,
              x_converted_amount 		=> l_minimum_late_charge);

              l_minimum_late_charge := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_minimum_late_charge, l_contract_currency);

              --convert maximum_late_charge to contract currency
              OKL_ACCOUNTING_UTIL.convert_to_contract_currency(
              p_khr_id  		  	=> l_khr_id,
              p_from_currency   		=> l_func_currency,
              p_transaction_date 		=> sysdate,
              p_amount 			=> l_lpo_cur.maximum_late_charge,
              x_contract_currency		=> l_contract_currency,
              x_currency_conversion_type	=> l_currency_conversion_type,
              x_currency_conversion_rate	=> l_currency_conversion_rate,
              x_currency_conversion_date	=> l_currency_conversion_date,
              x_converted_amount 		=> l_maximum_late_charge);

              l_maximum_late_charge := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_maximum_late_charge, l_contract_currency);

              --convert late_chrg_minimum_balance to contract currency
              OKL_ACCOUNTING_UTIL.convert_to_contract_currency(
              p_khr_id  		  	=> l_khr_id,
              p_from_currency   		=> l_func_currency,
              p_transaction_date 		=> sysdate,
              p_amount 			=> l_lpo_cur.late_chrg_minimum_balance,
              x_contract_currency		=> l_contract_currency,
              x_currency_conversion_type	=> l_currency_conversion_type,
              x_currency_conversion_rate	=> l_currency_conversion_rate,
              x_currency_conversion_date	=> l_currency_conversion_date,
              x_converted_amount 		=> l_late_chrg_minimum_balance);

              l_late_chrg_minimum_balance := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_late_chrg_minimum_balance, l_contract_currency);
            ELSE
              l_late_chrg_amount := l_lpo_cur.late_chrg_amount;
              l_minimum_late_charge := l_lpo_cur.minimum_late_charge;
              l_maximum_late_charge := l_lpo_cur.maximum_late_charge;
              l_late_chrg_minimum_balance := l_lpo_cur.late_chrg_minimum_balance;
            END IF;

            l_late_chrg_fixed_yn := l_lpo_cur.late_chrg_fixed_yn;
            l_late_chrg_allowed_yn := l_lpo_cur.late_chrg_allowed_yn;
            l_late_chrg_rate := l_lpo_cur.late_chrg_rate;

            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Processing: LATE POLICY TYPE CODE => '||l_lpo_cur.LATE_POLICY_TYPE_CODE||
					  ' LATE CHRG MINIMUM BALANCE=> '||l_late_chrg_minimum_balance
                      ||' ,LATE CHRG GRACE PERIOD=> '||l_lpo_cur.LATE_CHRG_GRACE_PERIOD);
          END LOOP;
          l_prev_late_policy := l_late_policy;
          l_prev_contract_currency := l_contract_currency;
        END IF;
        --end code pgomes 12/18/2002

        -- pgomes 12/18/2002 start, changed code to consider converted charges

        l_error_flag := FALSE;
        l_late_stm_id := null;
        IF(nvl(l_late_chrg_minimum_balance,0) <= l_amt_due_remaining) THEN

          IF(l_late_chrg_fixed_yn = 'Y') THEN
            l_late_charge_amt              := l_late_chrg_amount;
            l_investor_disb_flag    := 'N';
          ELSE --IF(l_lpo_cur.LATE_CHRG_FIXED_YN = 'N') THEN
            l_amount := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_amt_due_remaining*(l_late_chrg_rate/100), l_contract_currency);
            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Calculated late charge => '||l_amount);

            IF(l_amount < nvl(l_minimum_late_charge,0)) THEN
              l_late_charge_amt              := l_minimum_late_charge;
              l_investor_disb_flag    := 'N';
            ELSIF(l_amount > nvl(l_maximum_late_charge,0)) THEN
              l_late_charge_amt              := l_maximum_late_charge;
              l_investor_disb_flag    := 'N';
            ELSE
              l_late_charge_amt              := l_amount;
              l_investor_disb_flag    := 'Y';
              FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_investor_disb_flag is set to '||l_investor_disb_flag );
            END IF;
          END IF;
          FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Applied late charge => '||l_late_charge_amt);
          -- pgomes 12/18/2002 end, changed code to consider converted charges


          ----------------------------------------------------------------
          --PROCESSING FOR LATE CHARGE
          ----------------------------------------------------------------

          --get stream type id
          l_sty_id := null;

          Okl_Streams_Util.get_primary_stream_type(
		               p_khr_id => l_khr_id,
		               p_primary_sty_purpose => cns_late_fee,
		               x_return_status => l_return_status,
		               x_primary_sty_id => l_sty_id );

          IF 	(l_return_status = 'S' ) THEN
         	  FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream Id for purpose LATE_FEE retrieved.');
       	  ELSE
         	  FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Could not retrieve Stream Id for purpose LATE_FEE.');
            l_error_flag := TRUE;
      	  END IF;


          --check for stream type id
          IF NOT (l_error_flag) THEN
          l_stm_id := null;
          l_se_line_number := null;
          -- vdamerla: bug 5474844  If consolidated invoices
          if l_inv_cur.CONSOLIDATED_INVOICE_ID is not null then
            OPEN l_stream_csr(l_inv_cur.contract_id, l_sty_id);
            FETCH l_stream_csr INTO l_stm_id;
            CLOSE l_stream_csr;
          else
            OPEN l_AR_stream_csr(l_inv_cur.contract_id, l_sty_id);
            FETCH l_AR_stream_csr INTO l_stm_id;
            CLOSE l_AR_stream_csr;
          end if;

          --create stream for late charge
          IF (l_stm_id IS NULL) THEN
            l_stmv_rec := l_init_stmv_rec;

            OPEN  c_tran_num_csr;
       	    FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
            CLOSE c_tran_num_csr;

            l_stmv_rec.sty_id                := l_sty_id;
            l_stmv_rec.khr_id                := l_inv_cur.contract_id;
          --  l_stmv_rec.sgn_code              := 'MANL'; --  Bug 6472228
            l_stmv_rec.sgn_code              := G_LATE_SGN_CODE; -- Bug 6472228
            l_stmv_rec.say_code              := 'CURR';
            l_stmv_rec.active_yn             := 'Y';
            l_stmv_rec.date_current          := sysdate;
            l_stmv_rec.comments              := 'LATE FEE BILLING';

            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Creating LATE FEE Stream');

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
            --fix for bug 4439728
            --save the parent stm id so that if creation of payable stm is unsuccessful
            --then the parent stm can be invalidated
            l_late_stm_id := l_stm_id;


            IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
              l_error_flag := TRUE;
              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Creating Stream for LATE FEE');
            ELSE
              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- SUCCESS: Creating Stream for LATE FEE');
            END IF;
            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream element line number => ' || l_se_line_number);
          ELSE
            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream for LATE FEE found');
            open l_stream_line_nbr_csr(l_stm_id);
            fetch l_stream_line_nbr_csr into l_se_line_number;
            close l_stream_line_nbr_csr;
            l_se_line_number := nvl(l_se_line_number,0) + 1;
            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream element line number => ' || l_se_line_number);
          END IF;

          --create stream element for late charge
          IF (l_stm_id IS NOT NULL) THEN
            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Creating Stream Element for LATE FEE');
            l_selv_rec := l_init_selv_rec;

       			l_selv_rec.stm_id 				   := l_stm_id;
      			l_selv_rec.SE_LINE_NUMBER          := l_se_line_number;
      			l_selv_rec.STREAM_ELEMENT_DATE     := sysdate;
      			l_selv_rec.AMOUNT                  := l_late_charge_amt;
      			l_selv_rec.COMMENTS                := 'LATE FEE BILLING ELEMENTS';
      			l_selv_rec.ACCRUED_YN			   := 'Y';


            -- vdamerla bug 5474844  Added the following lines to get the source_id

            if l_inv_cur.consolidated_invoice_id is not null then
              l_selv_rec.source_id:=l_inv_cur.consolidated_invoice_id;
              l_selv_rec.source_table := cns_cons_source_table;
            else
              OPEN  c_AR_source_sel(l_inv_cur.contract_number, l_inv_cur.consolidated_invoice_number);
              FETCH c_AR_source_sel INTO l_selv_rec.source_id;
              CLOSE c_AR_source_sel;
              l_selv_rec.source_table := cns_AR_source_table;
            end if;





    		    Okl_Sel_Pvt.insert_row(
    		 			p_api_version,
    		 			p_init_msg_list,
    		 			x_return_status,
    		 			x_msg_count,
    		 			x_msg_data,
    		 			l_selv_rec,
    		 			lx_selv_rec);

            l_sel_id := lx_selv_rec.id;

            --l_sec_rec_inv_id := lx_selv_rec.source_id;

            IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    l_error_flag := TRUE;
                    FND_FILE.PUT_LINE (FND_FILE.LOG,  '        -- Error Creating Stream Element for Contract: '

                                        ||l_inv_cur.contract_number
                                        ||' Stream Purpose: '||cns_late_fee
                                        ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                        ||' Amount: '||l_late_charge_amt
                                        ||'source_id:'||l_selv_rec.source_id);
            ELSE

                FND_FILE.PUT_LINE (FND_FILE.LOG, '         -- Created Late Fee Stream Element for Contract: '
                                      ||l_inv_cur.contract_number
                                      ||' Stream Purpose: '||cns_late_fee
                                      ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                      ||' Amount: '||l_late_charge_amt
                                    );
   	        END IF;
          END IF;

          ----------------------------------------------------------------
          --PROCESSING FOR LATE CHARGE PAYABLE TO INVESTOR
          ----------------------------------------------------------------
          FND_FILE.PUT_LINE (FND_FILE.LOG, '(l_late_invs_cur) l_investor_disb_flag:'||l_investor_disb_flag);

          IF   nvl(l_investor_disb_flag,'N')  = 'Y' then
            IF l_inv_cur.consolidated_invoice_id is null then
              FOR cur_sec_strm IN c_sec_strm_AR_csr(l_inv_cur.contract_id, l_inv_cur.consolidated_invoice_number)
              LOOP
                --get stream type id
                l_sty_id := null;

                Okl_Streams_Util.get_primary_stream_type(
		                   p_khr_id => cur_sec_strm.khr_id,
		                   p_primary_sty_purpose => cns_late_charge_payable,
		                   x_return_status => l_return_status,
		                   x_primary_sty_id => l_sty_id );

                IF 	(l_return_status = 'S' ) THEN
           	      FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream Id for purpose INVESTOR_LATE_FEE_PAYABLE retrieved.');
       	        ELSE
           	      FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Could not retrieve Stream Id for purpose INVESTOR_LATE_FEE_PAYABLE.');
                  l_error_flag := TRUE;
      	        END IF;

                --check for stream
                IF NOT (l_error_flag) THEN
                  l_stm_id := null;
                  l_se_line_number := null;

                  OPEN l_AR_stream_csr(l_inv_cur.contract_id, l_sty_id);
                  FETCH l_AR_stream_csr INTO l_stm_id;
                  CLOSE l_AR_stream_csr;


                  --create stream for late charge payable
                  IF (l_stm_id IS NULL) THEN
                    l_stmv_rec := l_init_stmv_rec;

                    OPEN  c_tran_num_csr;
       	            FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
                    CLOSE c_tran_num_csr;

                    l_stmv_rec.sty_id                := l_sty_id;
                    l_stmv_rec.khr_id                := l_inv_cur.contract_id;
                    l_stmv_rec.kle_id                := cur_sec_strm.kle_id;
                    -- l_stmv_rec.sgn_code              := 'MANL';  -- Bug 6472228
                    l_stmv_rec.sgn_code              := G_LATE_SGN_CODE; -- Bug 6472228
                    l_stmv_rec.say_code              := 'CURR';
                    l_stmv_rec.active_yn             := 'Y';
                    l_stmv_rec.date_current          := sysdate;
                    l_stmv_rec.comments              := 'INVESTOR LATE FEE PAYABLE';
                    IF (cur_sec_strm.khr_id IS NOT NULL) THEN
                      l_stmv_rec.source_id :=  cur_sec_strm.khr_id;
                      l_stmv_rec.source_table := 'OKL_K_HEADERS';
                    END IF;

                    FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Creating INVESTOR LATE FEE PAYABLE Stream');

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

                     FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream element line number => ' || l_se_line_number);
                     IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                       l_error_flag := TRUE;
                       FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Creating Stream for INVESTOR LATE FEE PAYABLE');
	                   ELSE
                       FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- SUCCESS: Creating Stream for INVESTOR LATE FEE PAYABLE');
                     END IF;
                   ELSE
                     FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream for INVESTOR LATE FEE PAYABLE found');
                     open l_stream_line_nbr_csr(l_stm_id);
                     fetch l_stream_line_nbr_csr into l_se_line_number;
                     close l_stream_line_nbr_csr;
                     l_se_line_number := nvl(l_se_line_number,0) + 1;
                     FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream element line number => ' || l_se_line_number);
                   END IF;

                  --create stream element for late charge payable
                  IF (l_stm_id IS NOT NULL) THEN
                    FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Creating INVESTOR LATE FEE PAYABLE Stream Elements');
                    l_selv_rec := l_init_selv_rec;

        		        l_selv_rec.stm_id 				 := l_stm_id;
      			        l_selv_rec.SE_LINE_NUMBER          := l_se_line_number;
      			        l_selv_rec.STREAM_ELEMENT_DATE     := sysdate;
      			        l_selv_rec.AMOUNT                  := l_late_charge_amt;
      			        l_selv_rec.COMMENTS                := 'INVESTOR LATE FEE PAYABLE ELEMENTS';
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
                       FND_FILE.PUT_LINE (FND_FILE.LOG,  '        -- Error Creating Payable Stream Element for Contract: '
                                            ||l_inv_cur.contract_number
                                            ||' Stream Purpose: '||cns_late_fee
                                            ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                            ||' Amount: '||l_late_charge_amt);
                    ELSE

                       FND_FILE.PUT_LINE (FND_FILE.LOG, '         -- Created Investor Late Charge Payable Stream Element for Contract: '
                                          ||l_inv_cur.contract_number
                                          ||' Stream Purpose: '||cns_late_fee
                                          ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                          ||' Amount: '||l_late_charge_amt
                                        );
 	                  END IF;
                  END IF;
                ELSE
                 --fix for bug 4439728
                 --deactivate late charge stream as payable stream creation was unsuccessful
                 Update okl_streams
                 set  say_code = 'HIST'
                      ,active_yn = 'N'
                      ,last_updated_by = l_last_updated_by
                      ,last_update_date = sysdate
                      ,last_update_login = l_last_update_login
                      ,request_id = l_request_id
                      ,date_history = SYSDATE
                  WHERE id = l_late_stm_id;

                 IF (SQL%NOTFOUND) THEN
                   FND_FILE.PUT_LINE (FND_FILE.LOG, ' ... Late charge stream not deactivated successfully as payable stream creation was unsuccessful.');
                 ELSE
                   FND_FILE.PUT_LINE (FND_FILE.LOG, ' ... Late charge stream deactivated successfully as payable stream creation was unsuccessful.');
                 END IF;
              END IF;
            END LOOP;
          END IF; -- if consolidated_invoice_id is null

          IF l_inv_cur.consolidated_invoice_id is not null then
            FOR cur_sec_strm IN c_sec_strm_cons_csr(l_inv_cur.consolidated_invoice_id, l_inv_cur.contract_id)
            LOOP
              --get stream type id
              l_sty_id := null;

              Okl_Streams_Util.get_primary_stream_type(
                     p_khr_id => cur_sec_strm.khr_id,
                     p_primary_sty_purpose => cns_late_charge_payable,
                     x_return_status => l_return_status,
                     x_primary_sty_id => l_sty_id );

              IF  (l_return_status = 'S' ) THEN
                FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream Id for purpose INVESTOR_LATE_FEE_PAYABLE retrieved.');
              ELSE
                --Added by bkatraga for bug 5601733
                FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Could not retrieve Stream Id for purpose INVESTOR_LATE_FEE_PAYABLE while processing Consolidated invoice  => '||
                                                l_inv_cur.consolidated_INVOICE_NUMBER);
                --end bkatraga
                l_error_flag := TRUE;
              END IF;

              --check for stream
              IF NOT (l_error_flag) THEN
                l_stm_id := null;
                l_se_line_number := null;

                --Added by bkatraga for bug 5601733
                OPEN l_cons_stream_csr(l_inv_cur.contract_id, cur_sec_strm.kle_id,l_sty_id);
                FETCH l_cons_stream_csr INTO l_stm_id;
                CLOSE l_cons_stream_csr;
                --end bkatraga

                --create stream for late charge payable
                IF ((l_stm_id IS NULL) or (l_stm_id = -99)) THEN  --Added or clause by bkatraga for bug 5601733
                  l_stmv_rec := l_init_stmv_rec;

                  OPEN  c_tran_num_csr;
                  FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
                  CLOSE c_tran_num_csr;

                  l_stmv_rec.sty_id                := l_sty_id;
                  l_stmv_rec.khr_id                := l_inv_cur.contract_id;
                  l_stmv_rec.kle_id                := cur_sec_strm.kle_id; --Added by bkatraga for bug 5601733
                  -- l_stmv_rec.sgn_code              := 'MANL'; -- Bug 6472228
                  l_stmv_rec.sgn_code              := G_LATE_SGN_CODE; -- Bug 6472228
                  l_stmv_rec.say_code              := 'CURR';
                  l_stmv_rec.active_yn             := 'Y';
                  l_stmv_rec.date_current          := sysdate;
                  l_stmv_rec.comments              := 'INVESTOR LATE FEE PAYABLE';
                  IF (cur_sec_strm.khr_id IS NOT NULL) THEN
                       l_stmv_rec.source_id :=  cur_sec_strm.khr_id;
                       l_stmv_rec.source_table := 'OKL_K_HEADERS';
                  END IF;

                  FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Creating INVESTOR LATE FEE PAYABLE Stream');

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

                  FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream element line number => ' || l_se_line_number);
                  IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                      l_error_flag := TRUE;
                      FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Creating Stream for INVESTOR LATE FEE PAYABLE');
                  ELSE
                      FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- SUCCESS: Creating Stream for INVESTOR LATE FEE PAYABLE');
                  END IF;
                ELSE
                  FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream for INVESTOR LATE FEE PAYABLE found');
                  open l_stream_line_nbr_csr(l_stm_id);
                  fetch l_stream_line_nbr_csr into l_se_line_number;
                  close l_stream_line_nbr_csr;
                  l_se_line_number := nvl(l_se_line_number,0) + 1;
                  FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream element line number => ' || l_se_line_number);
                END IF;

                --create stream element for late charge payable
                IF (l_stm_id IS NOT NULL) THEN
                  FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Creating INVESTOR LATE FEE PAYABLE Stream Elements');
                  l_selv_rec := l_init_selv_rec;
                  l_selv_rec.stm_id          := l_stm_id;
                  l_selv_rec.SE_LINE_NUMBER          := l_se_line_number;
                  l_selv_rec.STREAM_ELEMENT_DATE     := sysdate;
                  --Added by bkatraga for bug 5601733
                  l_selv_rec.AMOUNT                  := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(cur_sec_strm.amount_due_remaining*(l_late_chrg_rate/100), l_contract_currency);
                  --end bkatraga
                  l_selv_rec.COMMENTS                := 'INVESTOR LATE FEE PAYABLE ELEMENTS';
                  l_selv_rec.ACCRUED_YN          := 'Y';
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
                        FND_FILE.PUT_LINE (FND_FILE.LOG,  '        -- Error Creating Payable Stream Element for Contract: '
                                            ||l_inv_cur.contract_number
                                            ||' Stream Purpose: '||cns_late_fee
                                            ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                            ||' Amount: '||l_late_charge_amt);
                  ELSE

                        FND_FILE.PUT_LINE (FND_FILE.LOG, '         -- Created Investor Late Charge Payable Stream Element for Contract: '
                                      ||l_inv_cur.contract_number
                                      ||' Stream Purpose: '||cns_late_fee
                                      ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                      ||' Amount: '||l_late_charge_amt
                                    );
                  END IF;
                END IF;
              ELSE
                --fix for bug 4439728
                --deactivate late charge stream as payable stream creation was unsuccessful
                Update okl_streams
                set  say_code = 'HIST'
                    ,active_yn = 'N'
                    ,last_updated_by = l_last_updated_by
                    ,last_update_date = sysdate
                    ,last_update_login = l_last_update_login
                    ,request_id = l_request_id
                    ,date_history = SYSDATE
                WHERE id = l_late_stm_id;

                IF (SQL%NOTFOUND) THEN
                  FND_FILE.PUT_LINE (FND_FILE.LOG, ' ... Late charge stream not deactivated successfully as payable stream creation was unsuccessful.');
                ELSE
                  FND_FILE.PUT_LINE (FND_FILE.LOG, ' ... Late charge stream deactivated successfully as payable stream creation was unsuccessful.');
                END IF;

              END IF;
            END LOOP;
          END IF;  -- if consolidated_invoice_id is not null
        END IF; -- l_investor_disb_flag



          -- Start of wraper code generated automatically by Debug code generator for Okl_Trx_Ar_Invoices_Pub.insert_trx_ar_invoices
        IF NOT(l_error_flag) THEN
                 -- if consolidated Invoice
            IF l_inv_cur.consolidated_invoice_id  is not null then
               FOR l_lsm IN l_cons_lsm_cur(l_inv_cur.consolidated_invoice_id , l_khr_id) --Added by bkatraga for bug 5601733
               LOOP
                 Update okl_cnsld_ar_strms_b
                 set  LATE_CHARGE_ASS_YN = 'Y'
                     ,LATE_CHARGE_ASSESS_DATE = SYSDATE
                     ,last_updated_by = l_last_updated_by
                     ,last_update_date = sysdate
                     ,last_update_login = l_last_update_login
                     ,request_id = l_request_id
                 WHERE CURRENT OF l_cons_lsm_cur;  -- Made changes by bkatraga for bug 5601733

                 IF (SQL%NOTFOUND) THEN
                   FND_FILE.PUT_LINE (FND_FILE.LOG, ' ... Internal Consolidation Record Update Unsuccessful.');
                 ELSE
                   FND_FILE.PUT_LINE (FND_FILE.LOG, ' ... Internal Consolidation Record Updated.');
                 END IF;

               END LOOP;
            ELSE
                 -- if AR Invoice

               FOR l_lsm IN l_AR_lsm_cur(l_rec_inv_id,l_rec_inv_contract_id)
               LOOP

                 Update okl_txd_ar_ln_dtls_b
                 set  LATE_CHARGE_ASS_YN = 'Y'
                     ,LATE_CHARGE_ASSESS_DATE = SYSDATE
                     ,last_updated_by = l_last_updated_by
                     ,last_update_date = sysdate
                     ,last_update_login = l_last_update_login
                     ,request_id = l_request_id
                 WHERE CURRENT OF l_AR_lsm_cur;

                 IF (SQL%NOTFOUND) THEN
                   FND_FILE.PUT_LINE (FND_FILE.LOG, ' ... Internal Consolidation Record Update Unsuccessful.');
                 ELSE
                   FND_FILE.PUT_LINE (FND_FILE.LOG, ' ... Internal Consolidation Record Updated.');
                 END IF;

               END LOOP;
            END IF;
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
      --dkagrawa bug# 4728636 changes end */ ---- for bug 7295166 -- Don't charge late charge on late charge.


      l_contract_currency     := null;
      l_late_policy           := null;
      l_prev_contract_currency     := null;
      l_prev_late_policy           := null;
      l_prev_khr_id                := null;  --dkagrawa bug# 4728636

      FOR l_inv_cur IN l_late_invs_cur
      LOOP
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Processing:Already Late: Receivables invoice => '||l_inv_cur.consolidated_invoice_number||
					  ' ,due date=> '||l_inv_cur.DUE_DATE||' and Amount=> '||l_inv_cur.AMOUNT_DUE_REMAINING
                      ||' ,Contract => '||l_inv_cur.CONTRACT_NUMBER);
        FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Late policy => ' || l_inv_cur.late_policy
                      || ' ,Contract currency => ' || l_inv_cur.currency_code);
        -- vdamerla bug 5474844
        open l_receivables_inv_csr(l_inv_cur.CONTRACT_ID,l_inv_cur.consolidated_invoice_number);
        fetch  l_receivables_inv_csr into  l_rec_inv_id,l_rec_inv_contract_id;
        close l_receivables_inv_csr;

        if l_inv_cur.CONSOLIDATED_INVOICE_ID is not null then
           l_rec_inv_id            := l_inv_cur.CONSOLIDATED_INVOICE_ID;
           -- Get the amount_due_remaining
           OKL_BILLING_UTIL_PVT.get_contract_invoice_balance(
                        p_api_version              =>  1.0
                       ,p_init_msg_list            =>  OKL_API.G_FALSE
                       ,p_contract_number          =>  l_inv_cur.CONTRACT_NUMBER
                       ,p_trx_number               =>  l_inv_cur.consolidated_invoice_number
                       ,x_return_status            =>  x_return_status
                       ,x_msg_count                =>  x_msg_count
                       ,x_msg_data                 =>  x_msg_data
                       ,x_remaining_amount         =>  l_amt_due_remaining);
           IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                l_error_flag := TRUE;
                FND_FILE.PUT_LINE (FND_FILE.LOG,  '        -- Error fetching Consolidated Invoice Balance for contract: '
                ||l_inv_cur.contract_number
                ||' consolidated_invoice_number: '||l_inv_cur.consolidated_invoice_number);
           ELSE
                FND_FILE.PUT_LINE (FND_FILE.LOG,  '        -- Successfully  fetched Consolidated Invoice Balance for contract: '
                ||l_inv_cur.contract_number
                ||' consolidated_invoice_number: '||l_inv_cur.consolidated_invoice_number
                ||'Invoice Balance:'|| l_amt_due_remaining);


           END IF;

           FND_FILE.PUT_LINE (FND_FILE.LOG,' Contract Number => '||l_inv_cur.CONTRACT_NUMBER);
           FND_FILE.PUT_LINE (FND_FILE.LOG,'consolidated_invoice_number => '||l_inv_cur.consolidated_invoice_number);
           FND_FILE.PUT_LINE (FND_FILE.LOG,'Consolidated Invoice Balance => '||l_amt_due_remaining);
        else
           l_amt_due_remaining     := l_inv_cur.AMOUNT_DUE_REMAINING;
           FND_FILE.PUT_LINE (FND_FILE.LOG, 'AR Invoice Balance => '||l_amt_due_remaining);
        end if;

        l_due_date              := l_inv_cur.DUE_DATE;
        l_khr_id                := l_inv_cur.CONTRACT_ID;
        l_contract_currency     := l_inv_cur.currency_code;
        l_late_policy           := l_inv_cur.late_policy;

        l_investor_disb_flag    := 'N';


        --      IF (l_name IS NOT NULL) THEN
        IF (nvl(l_late_policy, 'xxx') <> nvl(l_prev_late_policy, 'yyy') or
          nvl(l_contract_currency, 'aaa') <> nvl(l_prev_contract_currency, 'bbb')) THEN
          FOR l_lpo_cur IN l_late_policy_cur(l_late_policy)
          LOOP

            --start code pgomes 12/18/2002
            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Functional currency : ' || l_func_currency || ' Contract currency : ' || l_contract_currency);
            IF (l_func_currency <> NVL(l_contract_currency, '000')) THEN
              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Converting late charge amounts from functional to contract.');
              --convert late_chrg_amount to contract currency
              OKL_ACCOUNTING_UTIL.convert_to_contract_currency(
               p_khr_id  		  	=> l_khr_id,
               p_from_currency   		=> l_func_currency,
               p_transaction_date 		=> sysdate,
               p_amount 			=> l_lpo_cur.late_chrg_amount,
               x_contract_currency		=> l_contract_currency,
               x_currency_conversion_type	=> l_currency_conversion_type,
               x_currency_conversion_rate	=> l_currency_conversion_rate,
               x_currency_conversion_date	=> l_currency_conversion_date,
               x_converted_amount 		=> l_late_chrg_amount);

               l_late_chrg_amount := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_late_chrg_amount, l_contract_currency);

              --convert minimum_late_charge to contract currency
              OKL_ACCOUNTING_UTIL.convert_to_contract_currency(
               p_khr_id  		  	=> l_khr_id,
               p_from_currency   		=> l_func_currency,
               p_transaction_date 		=> sysdate,
               p_amount 			=> l_lpo_cur.minimum_late_charge,
               x_contract_currency		=> l_contract_currency,
               x_currency_conversion_type	=> l_currency_conversion_type,
               x_currency_conversion_rate	=> l_currency_conversion_rate,
               x_currency_conversion_date	=> l_currency_conversion_date,
               x_converted_amount 		=> l_minimum_late_charge);

               l_minimum_late_charge := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_minimum_late_charge, l_contract_currency);

              --convert maximum_late_charge to contract currency
              OKL_ACCOUNTING_UTIL.convert_to_contract_currency(
               p_khr_id  		  	=> l_khr_id,
               p_from_currency   		=> l_func_currency,
               p_transaction_date 		=> sysdate,
               p_amount 			=> l_lpo_cur.maximum_late_charge,
               x_contract_currency		=> l_contract_currency,
               x_currency_conversion_type	=> l_currency_conversion_type,
               x_currency_conversion_rate	=> l_currency_conversion_rate,
               x_currency_conversion_date	=> l_currency_conversion_date,
               x_converted_amount 		=> l_maximum_late_charge);

               l_maximum_late_charge := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_maximum_late_charge, l_contract_currency);

              --convert late_chrg_minimum_balance to contract currency
              OKL_ACCOUNTING_UTIL.convert_to_contract_currency(
               p_khr_id  		  	=> l_khr_id,
               p_from_currency   		=> l_func_currency,
               p_transaction_date 		=> sysdate,
               p_amount 			=> l_lpo_cur.late_chrg_minimum_balance,
               x_contract_currency		=> l_contract_currency,
               x_currency_conversion_type	=> l_currency_conversion_type,
               x_currency_conversion_rate	=> l_currency_conversion_rate,
               x_currency_conversion_date	=> l_currency_conversion_date,
               x_converted_amount 		=> l_late_chrg_minimum_balance);

              l_late_chrg_minimum_balance := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_late_chrg_minimum_balance, l_contract_currency);
            ELSE
              l_late_chrg_amount := l_lpo_cur.late_chrg_amount;
              l_minimum_late_charge := l_lpo_cur.minimum_late_charge;
              l_maximum_late_charge := l_lpo_cur.maximum_late_charge;
              l_late_chrg_minimum_balance := l_lpo_cur.late_chrg_minimum_balance;
            END IF;
            --end code pgomes 12/18/2002

            l_late_chrg_fixed_yn := l_lpo_cur.late_chrg_fixed_yn;
            l_late_chrg_allowed_yn := l_lpo_cur.late_chrg_allowed_yn;
            l_late_chrg_rate := l_lpo_cur.late_chrg_rate;

            -- pgomes 12/18/2002 start, changed code to consider converted charges
            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Processing: LATE POLICY TYPE CODE => '||l_lpo_cur.LATE_POLICY_TYPE_CODE||
					  ' LATE CHRG MINIMUM BALANCE=> '||l_late_chrg_minimum_balance
                      ||' ,LATE CHRG GRACE PERIOD=> '||l_lpo_cur.LATE_CHRG_GRACE_PERIOD);

          END LOOP;
          l_prev_late_policy := l_late_policy;
          l_prev_contract_currency := l_contract_currency;
        END IF;

        l_error_flag := FALSE;
        l_late_stm_id := null;
        IF(nvl(l_late_chrg_minimum_balance,0) < l_amt_due_remaining) THEN

          l_sty_id := null;

          IF(l_late_chrg_fixed_yn = 'Y') THEN
            l_late_charge_amt              := l_late_chrg_amount;
            l_investor_disb_flag    := 'N';
          ELSE --(l_lpo_cur.LATE_CHRG_FIXED_YN = 'N') THEN
            l_amount := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(l_amt_due_remaining*(l_late_chrg_rate/100), l_contract_currency);
            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Calculated late charge => '||l_amount);

            IF(l_amount < nvl(l_minimum_late_charge,0)) THEN
              l_late_charge_amt              := l_minimum_late_charge;
              l_investor_disb_flag    := 'N';
            ELSIF(l_amount > nvl(l_maximum_late_charge,0)) THEN
              l_late_charge_amt              := l_maximum_late_charge;
              l_investor_disb_flag    := 'N';
            ELSE
              l_late_charge_amt              := l_amount;
              l_investor_disb_flag    := 'Y';
              FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_investor_disb_flag is set to '||l_investor_disb_flag );
            END IF;

          END IF;

          FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Applied late charge => '||l_late_charge_amt);
          -- pgomes 12/18/2002 end, changed code to consider converted charges


          ----------------------------------------------------------------
          --PROCESSING FOR LATE CHARGE
          ----------------------------------------------------------------

          --get stream type id
          l_sty_id := null;

          Okl_Streams_Util.get_primary_stream_type(
		               p_khr_id => l_khr_id,
		               p_primary_sty_purpose => cns_late_fee,
		               x_return_status => l_return_status,
		               x_primary_sty_id => l_sty_id );

          IF 	(l_return_status = 'S' ) THEN
           	FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream Id for purpose LATE_FEE retrieved.');
       	  ELSE
           	FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Could not retrieve Stream Id for purpose LATE_FEE.');
            l_error_flag := TRUE;
      	  END IF;

          --check for stream
          --check for stream type id
          IF NOT (l_error_flag) THEN
          l_stm_id := null;
          l_se_line_number := null;

          if l_inv_cur.CONSOLIDATED_INVOICE_ID is not null then
            OPEN l_stream_csr(l_inv_cur.contract_id, l_sty_id);
            FETCH l_stream_csr INTO l_stm_id;
            CLOSE l_stream_csr;
          else
            OPEN l_AR_stream_csr(l_inv_cur.contract_id, l_sty_id);
            FETCH l_AR_stream_csr INTO l_stm_id;
            CLOSE l_AR_stream_csr;
          end if;

          --create stream for late charge
          IF (l_stm_id IS NULL) THEN
            l_stmv_rec := l_init_stmv_rec;

            OPEN  c_tran_num_csr;
       	    FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
            CLOSE c_tran_num_csr;

            l_stmv_rec.sty_id                := l_sty_id;
            l_stmv_rec.khr_id                := l_inv_cur.contract_id;
            -- l_stmv_rec.sgn_code              := 'MANL'; -- Bug 6472228
            l_stmv_rec.sgn_code              := G_LATE_SGN_CODE; -- Bug 6472228
            l_stmv_rec.say_code              := 'CURR';
            l_stmv_rec.active_yn             := 'Y';
            l_stmv_rec.date_current          := sysdate;
            l_stmv_rec.comments              := 'LATE FEE BILLING';

            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Creating LATE FEE Streams');

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
            --fix for bug 4439728
            --save the parent stm id so that if creation of payable stm is unsuccessful
            --then the parent stm can be invalidated
            l_late_stm_id := l_stm_id;

            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream element line number => ' || l_se_line_number);
            IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
              l_error_flag := TRUE;
              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Creating Streams for LATE FEE');
	          ELSE
              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- SUCCESS: Creating Streams for LATE FEE');
            END IF;

          ELSE
            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream for LATE FEE found');
            open l_stream_line_nbr_csr(l_stm_id);
            fetch l_stream_line_nbr_csr into l_se_line_number;
            close l_stream_line_nbr_csr;
            l_se_line_number := nvl(l_se_line_number,0) + 1;
            FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream element line number => ' || l_se_line_number);
          END IF;


          --create stream element for late charge
          IF (l_stm_id IS NOT NULL) THEN
            l_selv_rec := l_init_selv_rec;

      			l_selv_rec.stm_id 				   := l_stm_id;
      			l_selv_rec.SE_LINE_NUMBER          := l_se_line_number;
      			l_selv_rec.STREAM_ELEMENT_DATE     := sysdate;
      			l_selv_rec.AMOUNT                  := l_late_charge_amt;
      			l_selv_rec.COMMENTS                := 'LATE FEE BILLING ELEMENTS';
      			l_selv_rec.ACCRUED_YN			   := 'Y';


            -- vdamerla bug 5474844

            if l_inv_cur.consolidated_invoice_id is not null then

              l_selv_rec.source_id:=l_inv_cur.consolidated_invoice_id;
              l_selv_rec.source_table := cns_cons_source_table;
            else
              OPEN  c_AR_source_sel(l_inv_cur.contract_number, l_inv_cur.consolidated_invoice_number);
              FETCH c_AR_source_sel INTO l_selv_rec.source_id;
              CLOSE c_AR_source_sel;
              l_selv_rec.source_table := cns_AR_source_table;
            end if;

    		    Okl_Sel_Pvt.insert_row(
    		 			p_api_version,
    		 			p_init_msg_list,
    		 			x_return_status,
    		 			x_msg_count,
    		 			x_msg_data,
    		 			l_selv_rec,
    		 			lx_selv_rec);

            l_sel_id := lx_selv_rec.id;
            l_sec_rec_inv_id := lx_selv_rec.source_id;

            IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    l_error_flag := TRUE;
                    FND_FILE.PUT_LINE (FND_FILE.LOG,  '        -- Error Creating Stream Element for Contract: '

                                        ||l_inv_cur.contract_number
                                        ||' Stream Purpose: '||cns_late_fee
                                        ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                        ||' Amount: '||l_late_charge_amt
                                        ||'source_id:'||l_selv_rec.source_id);
            ELSE

                FND_FILE.PUT_LINE (FND_FILE.LOG, '         -- Created Late Fee Stream Element for Contract: '
                                      ||l_inv_cur.contract_number
                                      ||' Stream Purpose: '||cns_late_fee
                                      ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                      ||' Amount: '||l_late_charge_amt
                                    );
 	        END IF;
          END IF;

          ----------------------------------------------------------------
          --PROCESSING FOR LATE CHARGE PAYABLE TO INVESTOR
          ----------------------------------------------------------------
          FND_FILE.PUT_LINE (FND_FILE.LOG, '(l_late_invs_cur1) l_investor_disb_flag:'||l_investor_disb_flag);
          IF nvl(l_investor_disb_flag,'N')  = 'Y'  THEN
          IF l_inv_cur.consolidated_invoice_id is null then
          FOR cur_sec_strm IN c_sec_strm_AR_csr(l_inv_cur.contract_id, l_inv_cur.consolidated_invoice_number) LOOP
            --get stream type id
            l_sty_id := null;

            Okl_Streams_Util.get_primary_stream_type(
		               p_khr_id => cur_sec_strm.khr_id,
		               p_primary_sty_purpose => cns_late_charge_payable,
		               x_return_status => l_return_status,
		               x_primary_sty_id => l_sty_id );

            IF 	(l_return_status = 'S' ) THEN
           	  FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream Id for purpose INVESTOR_LATE_FEE_PAYABLE retrieved.');
       	    ELSE
           	  FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Could not retrieve Stream Id for purpose INVESTOR_LATE_FEE_PAYABLE.');
              l_error_flag := TRUE;
      	    END IF;

            --check for stream
            IF NOT (l_error_flag) THEN
            l_stm_id := null;
            l_se_line_number := null;


              OPEN l_AR_stream_csr(l_inv_cur.contract_id, l_sty_id);
              FETCH l_AR_stream_csr INTO l_stm_id;
              CLOSE l_AR_stream_csr;



            --create stream for late charge payable
            IF (l_stm_id IS NULL) THEN
              l_stmv_rec := l_init_stmv_rec;

              OPEN  c_tran_num_csr;
       	      FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
              CLOSE c_tran_num_csr;

              l_stmv_rec.sty_id                := l_sty_id;
              l_stmv_rec.khr_id                := l_inv_cur.contract_id;
              l_stmv_rec.kle_id                := cur_sec_strm.kle_id;
              -- l_stmv_rec.sgn_code              := 'MANL'; --  Bug 6472228
              l_stmv_rec.sgn_code              := G_LATE_SGN_CODE; -- Bug 6472228
              l_stmv_rec.say_code              := 'CURR';
              l_stmv_rec.active_yn             := 'Y';
              l_stmv_rec.date_current          := sysdate;
              l_stmv_rec.comments              := 'INVESTOR LATE FEE PAYABLE';
              -- gboomina Bug 6797000 - Start
              -- Stamping source id and source table for INVESTOR LATE FEE PAYABLE
              -- streams which are used as a condn to pick these streams
              -- while running Investor Disbursement program
       	      IF (cur_sec_strm.khr_id IS NOT NULL) THEN
                l_stmv_rec.source_id :=  cur_sec_strm.khr_id;
                l_stmv_rec.source_table := 'OKL_K_HEADERS';
              END IF;
              -- gboomina Bug 6797000 - End
              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Creating INVESTOR LATE FEE PAYABLE Streams');

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

              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream element line number => ' || l_se_line_number);
              IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                l_error_flag := TRUE;
                FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Creating Streams for INVESTOR LATE FEE PAYABLE');
	          ELSE
                FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- SUCCESS: Creating Streams for INVESTOR LATE FEE PAYABLE');
              END IF;
            ELSE
              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream for INVESTOR LATE FEE PAYABLE found');
              open l_stream_line_nbr_csr(l_stm_id);
              fetch l_stream_line_nbr_csr into l_se_line_number;
              close l_stream_line_nbr_csr;
              l_se_line_number := nvl(l_se_line_number,0) + 1;
              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream element line number => ' || l_se_line_number);
            END IF;

            --create stream element for late charge payable
            IF (l_stm_id IS NOT NULL) THEN
              l_selv_rec := l_init_selv_rec;

         		   l_selv_rec.stm_id 				 := l_stm_id;
       			    l_selv_rec.SE_LINE_NUMBER          := l_se_line_number;
        			   l_selv_rec.STREAM_ELEMENT_DATE     := sysdate;
        			   l_selv_rec.AMOUNT                  := l_late_charge_amt;
       	 		   l_selv_rec.COMMENTS                := 'INVESTOR LATE FEE PAYABLE ELEMENTS';
       		 	   l_selv_rec.ACCRUED_YN			     := 'Y';
              -- gboomina Bug 6797000 - Start
              -- Stamping source id and source table for INVESTOR LATE FEE PAYABLE
              -- streams which are used as a condn to pick these streams
              -- while running Investor Disbursement program
       	      IF (cur_sec_strm.khr_id IS NOT NULL) THEN
                l_selv_rec.source_id :=  cur_sec_strm.khr_id;
                l_selv_rec.source_table := 'OKL_K_HEADERS';
              END IF;
              -- gboomina Bug 6797000 - End

              --@IMPORTANT@ Uncomment out this code once lsm_id is added to okl_strm_elements
              --l_selv_rec.lsm_id                  := cur_sec_strm.cnsld_strm_id;
              l_selv_rec.sel_id := l_sel_id;

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
                    FND_FILE.PUT_LINE (FND_FILE.LOG,  '        -- Error Creating Payable Stream Element for Contract: '
                                        ||l_inv_cur.contract_number
                                        ||' Stream Purpose: '||cns_late_fee
                                        ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                        ||' Amount: '||l_late_charge_amt);
              ELSE

                FND_FILE.PUT_LINE (FND_FILE.LOG, '         -- Created Investor Late Charge Payable Stream Element for Contract: '
                                      ||l_inv_cur.contract_number
                                      ||' Stream Purpose: '||cns_late_fee
                                      ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                      ||' Amount: '||l_late_charge_amt
                                    );
 	          END IF;
            END IF;
            ELSE
              --fix for bug 4439728
              --deactivate late charge stream as payable stream creation was unsuccessful
              Update okl_streams
              set  say_code = 'HIST'
                  ,active_yn = 'N'
                  ,last_updated_by = l_last_updated_by
                  ,last_update_date = sysdate
                  ,last_update_login = l_last_update_login
                  ,request_id = l_request_id
                  ,date_history = SYSDATE
              WHERE id = l_late_stm_id;

              IF (SQL%NOTFOUND) THEN
                FND_FILE.PUT_LINE (FND_FILE.LOG, ' ... Late charge stream not deactivated successfully as payable stream creation was unsuccessful.');
              ELSE
                FND_FILE.PUT_LINE (FND_FILE.LOG, ' ... Late charge stream deactivated successfully as payable stream creation was unsuccessful.');
              END IF;

            END IF;

          END LOOP;
      END IF;  -- if consolidated_invoice_id is null

          IF l_inv_cur.consolidated_invoice_id is not null then
          FOR cur_sec_strm IN c_sec_strm_cons_csr(l_inv_cur.consolidated_invoice_id,
              l_inv_cur.contract_id) LOOP
              --get stream type id
            l_sty_id := null;

            Okl_Streams_Util.get_primary_stream_type(
                   p_khr_id => cur_sec_strm.khr_id,
                   p_primary_sty_purpose => cns_late_charge_payable,
                   x_return_status => l_return_status,
                   x_primary_sty_id => l_sty_id );

            IF  (l_return_status = 'S' ) THEN
              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream Id for purpose INVESTOR_LATE_FEE_PAYABLE retrieved.');
            ELSE
            --Added by bkatraga for bug 5601733
              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Could not retrieve Stream Id for purpose INVESTOR_LATE_FEE_PAYABLE while processing Consolidated invoice  => '||
                                                l_inv_cur.consolidated_INVOICE_NUMBER);
            --end bkatraga
              l_error_flag := TRUE;
            END IF;

            --check for stream
            IF NOT (l_error_flag) THEN
            l_stm_id := null;
            l_se_line_number := null;

            --Added by bkatraga for bug 5601733
            OPEN l_cons_stream_csr(l_inv_cur.contract_id, cur_sec_strm.kle_id,l_sty_id);
            FETCH l_cons_stream_csr INTO l_stm_id;
            CLOSE l_cons_stream_csr;
            --end bkatraga

            --create stream for late charge payable
            IF ((l_stm_id IS NULL) or (l_stm_id = -99)) THEN  --Added or clause by bkatraga for bug 5601733
              l_stmv_rec := l_init_stmv_rec;

              OPEN  c_tran_num_csr;
              FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
              CLOSE c_tran_num_csr;

              l_stmv_rec.sty_id                := l_sty_id;
              l_stmv_rec.khr_id                := l_inv_cur.contract_id;
              l_stmv_rec.kle_id                := cur_sec_strm.kle_id; --Added by bkatraga for bug 5601733
              -- l_stmv_rec.sgn_code              := 'MANL'; -- Bug 6472228
              l_stmv_rec.sgn_code              := G_LATE_SGN_CODE; -- Bug 6472228
              l_stmv_rec.say_code              := 'CURR';
              l_stmv_rec.active_yn             := 'Y';
              l_stmv_rec.date_current          := sysdate;
              l_stmv_rec.comments              := 'INVESTOR LATE FEE PAYABLE';
              IF (cur_sec_strm.khr_id IS NOT NULL) THEN
                       l_stmv_rec.source_id :=  cur_sec_strm.khr_id;
                       l_stmv_rec.source_table := 'OKL_K_HEADERS';
              END IF;

              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Creating INVESTOR LATE FEE PAYABLE Stream');

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

              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream element line number => ' || l_se_line_number);
              IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                l_error_flag := TRUE;
                FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Creating Stream for INVESTOR LATE FEE PAYABLE');
            ELSE
                FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- SUCCESS: Creating Stream for INVESTOR LATE FEE PAYABLE');
              END IF;
            ELSE
              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream for INVESTOR LATE FEE PAYABLE found');
              open l_stream_line_nbr_csr(l_stm_id);
              fetch l_stream_line_nbr_csr into l_se_line_number;
              close l_stream_line_nbr_csr;
              l_se_line_number := nvl(l_se_line_number,0) + 1;
              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Stream element line number => ' || l_se_line_number);
            END IF;

            --create stream element for late charge payable
            IF (l_stm_id IS NOT NULL) THEN
              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Creating INVESTOR LATE FEE PAYABLE Stream Elements');
              l_selv_rec := l_init_selv_rec;

              l_selv_rec.stm_id          := l_stm_id;
              l_selv_rec.SE_LINE_NUMBER          := l_se_line_number;
              l_selv_rec.STREAM_ELEMENT_DATE     := sysdate;
              --Added by bkatraga for bug 5601733
              l_selv_rec.AMOUNT                  := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(cur_sec_strm.amount_due_remaining*(l_late_chrg_rate/100), l_contract_currency);
              --end bkatraga
              l_selv_rec.COMMENTS                := 'INVESTOR LATE FEE PAYABLE ELEMENTS';
              l_selv_rec.ACCRUED_YN          := 'Y';
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
                    FND_FILE.PUT_LINE (FND_FILE.LOG,  '        -- Error Creating Payable Stream Element for Contract: '
                                        ||l_inv_cur.contract_number
                                        ||' Stream Purpose: '||cns_late_fee
                                        ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                        ||' Amount: '||l_late_charge_amt);
              ELSE

                FND_FILE.PUT_LINE (FND_FILE.LOG, '         -- Created Investor Late Charge Payable Stream Element for Contract: '
                                      ||l_inv_cur.contract_number
                                      ||' Stream Purpose: '||cns_late_fee
                                      ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                      ||' Amount: '||l_late_charge_amt
                                    );
              END IF;
            END IF;
            ELSE
              --fix for bug 4439728
              --deactivate late charge stream as payable stream creation was unsuccessful
              Update okl_streams
              set  say_code = 'HIST'
                  ,active_yn = 'N'
                  ,last_updated_by = l_last_updated_by
                  ,last_update_date = sysdate
                  ,last_update_login = l_last_update_login
                  ,request_id = l_request_id
                  ,date_history = SYSDATE
              WHERE id = l_late_stm_id;

              IF (SQL%NOTFOUND) THEN
                FND_FILE.PUT_LINE (FND_FILE.LOG, ' ... Late charge stream not deactivated successfully as payable stream creation was unsuccessful.');
              ELSE
                FND_FILE.PUT_LINE (FND_FILE.LOG, ' ... Late charge stream deactivated successfully as payable stream creation was unsuccessful.');
              END IF;
            END IF;
          END LOOP;
        END IF;  -- if consolidated_invoice_id is not null
      END IF;  -- l_investor_disb_flag


          IF NOT(l_error_flag) THEN
            FOR l_lsm IN l_AR_lsm_cur(l_rec_inv_id,l_rec_inv_contract_id)
            LOOP
              Update okl_txd_ar_ln_dtls_b
              set LATE_CHARGE_ASS_YN = 'Y'
                , LATE_CHARGE_ASSESS_DATE = SYSDATE
                ,last_updated_by = l_last_updated_by
                ,last_update_date = sysdate
                ,last_update_login = l_last_update_login
                ,request_id = l_request_id
              WHERE CURRENT OF l_AR_lsm_cur;

              --  IF 	(l_return_status = Fnd_Api.G_RET_STS_SUCCESS) THEN
              IF (SQL%NOTFOUND) THEN
                FND_FILE.PUT_LINE (FND_FILE.LOG, ' ... Internal Consolidation Record Update Unsuccessful.');
              ELSE
                FND_FILE.PUT_LINE (FND_FILE.LOG, ' ... Internal Consolidation Record Updated.');
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


      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'End of Calculate charges.');
      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
      x_return_status := l_return_status;

    EXCEPTION
      WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Error (EXCP) => '||SQLERRM);
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
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'Error (UNEXCP) => '||SQLERRM);
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
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Error (Other) => '||SQLERRM);
        x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
  END calculate_late_charge;

END OKL_LTE_CHRG_PVT;

/
