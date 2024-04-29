--------------------------------------------------------
--  DDL for Package Body OKL_BILL_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BILL_STATUS_PVT" AS
/* $Header: OKLRBISB.pls 120.15 2007/08/24 12:31:55 gkhuntet noship $ */


  PROCEDURE billing_status(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,x_bill_stat_tbl                OUT NOCOPY bill_stat_tbl_type
    ,p_khr_id                       IN  NUMBER
    ,p_transaction_date             IN  DATE
     ) IS

/* rmunjulu R12 Fixes -- forward port bug 5474864 fixes -- comment this cursor and redone below
CURSOR c_last_bill_date(c_khr_id in NUMBER, c_transaction_date in DATE) IS
select max(AR.DUE_DATE) last_bill_date, tai.description transaction_type
-- abindal bug 4529600 start --
from    okl_cnsld_ar_strms_b cnsld,
        AR_PAYMENT_SCHEDULES_ALL AR,
        OKL_XTL_SELL_INVS_B XTL,
        okl_trx_ar_invoices_tl tai,
        okl_txl_ar_inv_lns_b til,
        okl_txd_ar_ln_dtls_b tld
-- abindal bug 4529600 end --
where   cnsld.receivables_invoice_id    = AR.customer_trx_id
and     cnsld.khr_id                    = c_khr_id
and     cnsld.id                        = XTL.lsm_id
and     xtl.tld_id                     = tld.id
and     til.tai_id                      = tai.id
and     til.id                          = tld.til_id_details
and     tai.description                 in ('Regular Stream Billing')
and     cnsld.sel_id                    in (SELECT SEL.id
-- abindal bug 4529600 start --
                                        FROM    OKL_STREAMS STM,
                                                OKL_STRM_ELEMENTS SEL,
                                                OKC_K_HEADERS_B KHR,
                                                OKL_STRM_TYPE_B STY
-- abindal bug 4529600 end --
                                        WHERE  KHR.id                           = c_khr_id
                                        AND    SEL.stream_element_date          <= c_transaction_date
                                        AND    KHR.id                           = STM.khr_id
                                        AND    STM.id                           = SEL.stm_id
                                        AND    STM.say_code                     = 'CURR'
                                        AND    STM.active_yn                    = 'Y'
                                        AND    STM.sty_id                       = STY.id
                                        AND    NVL(STY.billable_yn,'N')         = 'Y'
                                        AND    STY.stream_type_purpose          IN ('RENT', 'INTEREST_PAYMENT',
                                                                           'PRINCIPAL_PAYMENT', 'LOAN_PAYMENT',
																		   'FLOAT_FACTOR_ADJUSTMENT')
                                        AND    SEL.amount                       > 0)
group by tai.description;
*/

-- rmunjulu R12 Fixes -- forward port bug 5474864 fixes -- redone this cursor
CURSOR c_last_bill_date(c_khr_id in NUMBER, c_transaction_date in DATE) IS
   SELECT MAX(SEL.stream_element_date) last_bill_date
    FROM    OKL_STREAMS STM,
            OKL_STRM_ELEMENTS SEL,
            OKC_K_HEADERS_B KHR,
            OKL_STRM_TYPE_V STY
    WHERE   KHR.id                           = c_khr_id
    AND     SEL.stream_element_date          <=c_transaction_date
    AND     KHR.id                           = STM.khr_id
    AND     STM.id                           = SEL.stm_id
    AND     STM.say_code                     = 'CURR'
    AND     STM.active_yn                    = 'Y'
    AND     STM.sty_id                       = STY.id
    AND     STY.billable_yn                  = 'Y'
   -- AND     STY.name                         = 'RENT'
   AND     STY.STREAM_TYPE_PURPOSE      IN ('RENT', 'INTEREST_PAYMENT',
                                        'PRINCIPAL_PAYMENT', 'LOAN_PAYMENT',
										'FLOAT_FACTOR_ADJUSTMENT')
    AND     SEL.amount                       > 0
    AND     SEL.date_billed is not null;

-- abindal added this cursor for bug 4291677  -- start
CURSOR c_last_bill_date_import(c_khr_id in NUMBER, c_transaction_date in DATE) IS
    SELECT  --SEL.stream_element_date last_bill_date
            MAX(SEL.date_billed) last_bill_date
    FROM    OKL_STREAMS_V STM,
            OKL_STRM_ELEMENTS_V SEL,
            OKC_K_HEADERS_V KHR,
            OKL_STRM_TYPE_V STY
    WHERE   KHR.id                           = c_khr_id
    AND     SEL.stream_element_date          <=c_transaction_date
    AND     KHR.id                           = STM.khr_id
    AND     STM.id                           = SEL.stm_id
    AND     STM.say_code                     = 'CURR'
    AND     STM.active_yn                    = 'Y'
    AND     STM.sty_id                       = STY.id
    AND     NVL(STY.billable_yn,'N')         = 'Y'
   -- gkhuntet added for Forward port Bug #5488905  Start
    AND     STY.STREAM_TYPE_PURPOSE      IN ('RENT', 'INTEREST_PAYMENT',
                                        'PRINCIPAL_PAYMENT', 'LOAN_PAYMENT',
										'FLOAT_FACTOR_ADJUSTMENT');
     -- gkhuntet added for Forward port Bug #5488905  Start

   CURSOR check_cont_typ (cp_khr_id IN NUMBER) IS
   SELECT ORIG_SYSTEM_SOURCE_CODE
   FROM   OKC_K_HEADERS_B
   WHERE  id = cp_khr_id;

-- abindal added this cursor for bug 4291677  -- end

-----------------------------------------------------------------------------------------
-- abindal bug 4396207 start --
-- check AR for invoice due date.
/* -- rmunjulu R12 Fixes -- commented this cursor out and redone below
CURSOR c_last_bill_date_1 (c_sel_id in NUMBER, c_khr_id in NUMBER ) IS
select  AR.DUE_DATE last_bill_date
from    okl_cnsld_ar_strms_b cnsld,
        AR_PAYMENT_SCHEDULES_ALL AR,
        OKL_XTL_SELL_INVS_V XTL,
        okl_trx_ar_invoices_v tai,
        okl_txl_ar_inv_lns_v til,
        okl_txd_ar_ln_dtls_v tld
where   cnsld.receivables_invoice_id    = AR.customer_trx_id
and     cnsld.khr_id                    = c_khr_id
and     cnsld.id                        = XTL.lsm_id
and     xtl.tld_id                      = tld.id
and     til.tai_id                      = tai.id
and     til.id                          = tld.til_id_details
and     tai.description                 in ('Regular Stream Billing')
and     cnsld.sel_id                    = c_sel_id;
*/

-- rmunjulu R12 Fixes - redone this cursor
CURSOR c_last_bill_date_1 (c_sel_id in NUMBER, c_khr_id in NUMBER ) IS
select  AR.DUE_DATE last_bill_date
from    --okl_cnsld_ar_strms_b cnsld,
        AR_PAYMENT_SCHEDULES_ALL AR,
        --OKL_XTL_SELL_INVS_V XTL,
        --okl_trx_ar_invoices_v tai,
        --okl_txl_ar_inv_lns_v til,
        --okl_txd_ar_ln_dtls_v tld
        okl_bpd_tld_ar_lines_v RACTRL
where   RACTRL.customer_trx_id            = AR.customer_trx_id
and     RACTRL.khr_id                     = c_khr_id
--and     cnsld.id                        = XTL.lsm_id
--and     xtl.tld_id                      = tld.id
--and     til.tai_id                      = tai.id
--and     til.id                          = tld.til_id_details
and     RACTRL.description                 in ('Regular Stream Billing')
and     RACTRL.sel_id                    = c_sel_id;


-- obtain ALL lastest SEL_ID's for contract
CURSOR c_last_bill_date_2 (c_khr_id in NUMBER, c_transaction_date in DATE ) IS
--Bug 5050707: SEL.id not being used , putting distinct would restrict the processing of the duplicate link history stream id
--SELECT  SEL.ID, STM.LINK_HIST_STREAM_ID
SELECT  distinct STM.LINK_HIST_STREAM_ID
--Bug 5050707:end
FROM    OKL_STREAMS_V STM,
        OKL_STRM_ELEMENTS_V SEL,
        OKC_K_HEADERS_V KHR,
        OKL_STRM_TYPE_V STY
WHERE   KHR.id                           = c_khr_id
AND     SEL.stream_element_date          <= c_transaction_date
AND     STM.id                           = SEL.stm_id
AND     KHR.id                           = STM.khr_id
AND     STM.say_code                     = 'CURR'
AND     STM.active_yn                    = 'Y'
AND     STM.sty_id                       = STY.id
AND     NVL(STY.billable_yn,'N')         = 'Y'
AND     STY.stream_type_purpose          IN ('RENT', 'INTEREST_PAYMENT',
                                    'PRINCIPAL_PAYMENT', 'LOAN_PAYMENT',
									'FLOAT_FACTOR_ADJUSTMENT')
AND     SEL.amount                       > 0;

-- drill down each SEL_ID until original retreived ...
CURSOR  c_last_bill_date_3 (c_sel_id in NUMBER) IS
SELECT  LINK_HIST_STREAM_ID
FROM    OKL_STREAMS_V
WHERE   ID = c_sel_id;

/* -- rmunjulu R12 Fixes -- commented this cursor out and redone below
-- fetch original sel_ids from stm_id ...
CURSOR  c_last_bill_date_4 (c_stm_id in NUMBER, c_khr_id IN NUMBER,c_transaction_date in DATE) IS
SELECT  distinct(SEL.ID)
FROM    OKL_STREAMS_V STM,
        OKL_STRM_ELEMENTS_V SEL,
        OKC_K_HEADERS_V KHR,
        OKL_STRM_TYPE_V STY,
        okl_cnsld_ar_strms_b cnsld
WHERE   KHR.id                           = c_khr_id
AND     SEL.stream_element_date          <= c_transaction_date
AND     STM.id                           = SEL.stm_id
AND     KHR.id                           = STM.khr_id
AND     STM.say_code                     = 'HIST'
AND     STM.active_yn                    = 'N'
AND     STM.sty_id                       = STY.id
AND     NVL(STY.billable_yn,'N')         = 'Y'
AND     STY.stream_type_purpose          IN ('RENT', 'INTEREST_PAYMENT',
                                    'PRINCIPAL_PAYMENT', 'LOAN_PAYMENT',
									'FLOAT_FACTOR_ADJUSTMENT')
AND     SEL.amount                       > 0
AND     SEL.stm_id                       = c_stm_id
and     cnsld.sel_id                     = sel.id
and     cnsld.khr_id                     = c_khr_id;
*/

-- rmunjulu R12 Fixes - redone this cursor
CURSOR  c_last_bill_date_4 (c_stm_id in NUMBER, c_khr_id IN NUMBER,c_transaction_date in DATE) IS
SELECT  distinct(SEL.ID)
FROM    OKL_STREAMS_V STM,
        OKL_STRM_ELEMENTS_V SEL,
        OKC_K_HEADERS_V KHR,
        OKL_STRM_TYPE_V STY,
        --okl_cnsld_ar_strms_b cnsld
        okl_txd_ar_ln_dtls_b tld
WHERE   KHR.id                           = c_khr_id
AND     SEL.stream_element_date          <= c_transaction_date
AND     STM.id                           = SEL.stm_id
AND     KHR.id                           = STM.khr_id
AND     STM.say_code                     = 'HIST'
AND     STM.active_yn                    = 'N'
AND     STM.sty_id                       = STY.id
AND     NVL(STY.billable_yn,'N')         = 'Y'
AND     STY.stream_type_purpose          IN ('RENT', 'INTEREST_PAYMENT',
                                    'PRINCIPAL_PAYMENT', 'LOAN_PAYMENT',
									'FLOAT_FACTOR_ADJUSTMENT')
AND     SEL.amount                       > 0
AND     SEL.stm_id                       = c_stm_id
and     tld.sel_id                     = sel.id
and     tld.khr_id                     = c_khr_id;


-- abindal bug 4396207 end --
-----------------------------------------------------------------------------------------

-- get contract line id's
CURSOR  c_okl_line_items(c_khr_id IN NUMBER) IS
SELECT  id, lse_id
FROM    okc_k_lines_b
WHERE   dnz_chr_id = c_khr_id
AND     orig_system_source_code  <> 'OKL_SPLIT';

-----------------------------------------------------------------------------------------
/* -- rmunjulu R12 Fixes -- commented this cursor out and redone below
-- get contract line id's
CURSOR  c_last_split_bill_date(  c_khr_id IN NUMBER
                               , c_kle_id IN NUMBER
                               , c_transaction_date IN DATE
                               ) IS

SELECT  max(AR.DUE_DATE) last_bill_date--, tai.description transaction_type
FROM    okl_cnsld_ar_strms_b cnsld,
        AR_PAYMENT_SCHEDULES_ALL AR,
        OKL_XTL_SELL_INVS_V XTL,
        okl_trx_ar_invoices_v tai,
        okl_txl_ar_inv_lns_v til,
        okl_txd_ar_ln_dtls_v tld
WHERE   cnsld.receivables_invoice_id    = AR.customer_trx_id
AND     cnsld.khr_id                    = c_khr_id
AND     cnsld.id                        = XTL.lsm_id
AND     xtl.tld_id                      = tld.id
AND     til.tai_id                      = tai.id
AND     til.id                          = tld.til_id_details
AND     tai.description                 IN ('Regular Stream Billing')
AND EXISTS (    SELECT  '1'
                FROM    OKL_STREAMS STM,
                        OKL_STRM_ELEMENTS SEL,
                     -- OKC_K_LINES_B   KLE,
                        OKL_STRM_TYPE_B STY
                WHERE   SEL.ID = cnsld.SEL_ID
                AND     SEL.stream_element_date          <= TRUNC(c_transaction_date)
             -- AND     KLE.ID                           = STM.KLE_ID
                AND     STM.KHR_ID                       = c_khr_id
                AND     STM.id                           = SEL.stm_id
             -- AND     STM.say_code                     = 'CURR'
             -- AND     STM.active_yn                    = 'Y'
                AND     STM.sty_id                       = STY.id
                AND     NVL(STY.billable_yn,'N')         = 'Y'
                AND     STY.stream_type_purpose          IN ('RENT', 'INTEREST_PAYMENT',
                                                    'PRINCIPAL_PAYMENT', 'LOAN_PAYMENT',
													'FLOAT_FACTOR_ADJUSTMENT')
                AND     SEL.amount                       > 0
                AND     STM.KLE_ID IN ( SELECT   kle.id
                                        FROM     okc_k_lines_b kle
                                        WHERE    kle.dnz_chr_id    = c_khr_id
                                        CONNECT BY PRIOR kle.orig_system_id1 = kle.id
                                        START WITH kle.id =  c_kle_id ))
GROUP BY tai.description;
*/

-- rmunjulu R12 Fixes - redone this cursor
CURSOR  c_last_split_bill_date(  c_khr_id IN NUMBER
                               , c_kle_id IN NUMBER
                               , c_transaction_date IN DATE
                               ) IS

SELECT  max(AR.DUE_DATE) last_bill_date--, tai.description transaction_type
FROM    --okl_cnsld_ar_strms_b cnsld,
        AR_PAYMENT_SCHEDULES_ALL AR,
        --OKL_XTL_SELL_INVS_V XTL,
        --okl_trx_ar_invoices_v tai,
        --okl_txl_ar_inv_lns_v til,
        --okl_txd_ar_ln_dtls_v tld
        okl_bpd_tld_ar_lines_v RACTRL
WHERE   RACTRL.CUSTOMER_TRX_ID    = AR.customer_trx_id
AND     RACTRL.khr_id                    = c_khr_id
--AND     cnsld.id                        = XTL.lsm_id
--AND     xtl.tld_id                      = tld.id
--AND     til.tai_id                      = tai.id
--AND     til.id                          = tld.til_id_details
AND     RACTRL.description                 IN ('Regular Stream Billing')
AND EXISTS (    SELECT  '1'
                FROM    OKL_STREAMS STM,
                        OKL_STRM_ELEMENTS SEL,
                     -- OKC_K_LINES_B   KLE,
                        OKL_STRM_TYPE_B STY
                WHERE   SEL.ID = RACTRL.SEL_ID
                AND     SEL.stream_element_date          <= TRUNC(c_transaction_date)
             -- AND     KLE.ID                           = STM.KLE_ID
                AND     STM.KHR_ID                       = c_khr_id
                AND     STM.id                           = SEL.stm_id
             -- AND     STM.say_code                     = 'CURR'
             -- AND     STM.active_yn                    = 'Y'
                AND     STM.sty_id                       = STY.id
                AND     NVL(STY.billable_yn,'N')         = 'Y'
                AND     STY.stream_type_purpose          IN ('RENT', 'INTEREST_PAYMENT',
                                                    'PRINCIPAL_PAYMENT', 'LOAN_PAYMENT',
													'FLOAT_FACTOR_ADJUSTMENT')
                AND     SEL.amount                       > 0
                AND     STM.KLE_ID IN ( SELECT   kle.id
                                        FROM     okc_k_lines_b kle
                                        WHERE    kle.dnz_chr_id    = c_khr_id
                                        CONNECT BY PRIOR kle.orig_system_id1 = kle.id
                                        START WITH kle.id =  c_kle_id ))
GROUP BY RACTRL.description;

-----------------------------------------------------------------------------------------

/*
CURSOR c_last_sch_bill_date(c_khr_id in NUMBER, c_transaction_date DATE) IS
SELECT max(SEL.stream_element_date) last_sche_bill_date, sel.id
FROM   OKL_STREAMS_V STM,
       OKL_STRM_ELEMENTS_V SEL,
       OKC_K_HEADERS_V KHR,
       OKL_STRM_TYPE_B STY
WHERE  KHR.id                           = c_khr_id
AND    SEL.stream_element_date          <= c_transaction_date
AND    KHR.id                           = STM.khr_id
AND    STM.id                           = SEL.stm_id
AND    STM.say_code                     = 'CURR'
AND    STM.active_yn                    = 'Y'
AND    SEL.date_billed                  IS NULL
AND    STM.sty_id                       = STY.id
AND    NVL(STY.billable_yn,'N')         = 'Y'
AND    SEL.amount                       > 0
AND    ROWNUM                           < 2;
*/

CURSOR c_last_sch_bill_date(c_khr_id in NUMBER, c_transaction_date DATE) IS
SELECT  sel.id stream_id,
        sel.stream_element_date last_sche_bill_date
FROM   OKL_STREAMS_V STM,
       OKL_STRM_ELEMENTS_V SEL,
       OKL_STRM_TYPE_V STY
WHERE  sel.stream_element_date = (SELECT max(SEL.stream_element_date) last_sche_bill_date
FROM   OKL_STREAMS_V STM,
       OKL_STRM_ELEMENTS_V SEL,
       OKC_K_HEADERS_V KHR,
       OKL_STRM_TYPE_V STY
WHERE  KHR.id                           = c_khr_id
AND    SEL.stream_element_date          <= c_transaction_date
AND    KHR.id                           = STM.khr_id
AND    STM.id                           = SEL.stm_id
AND    STM.say_code                     = 'CURR'
AND    STM.active_yn                    = 'Y'
AND    STM.sty_id                       = STY.id
AND    NVL(STY.billable_yn,'N')         = 'Y'
AND    STY.stream_type_purpose          IN ('RENT', 'INTEREST_PAYMENT',
                                   'PRINCIPAL_PAYMENT', 'LOAN_PAYMENT',
								   'FLOAT_FACTOR_ADJUSTMENT')
AND    SEL.amount                       > 0)
AND    STM.id                           = SEL.stm_id
AND    STM.sty_id                       = STY.id
AND    STY.stream_type_purpose          IN ('RENT', 'INTEREST_PAYMENT',
                                   'PRINCIPAL_PAYMENT', 'LOAN_PAYMENT',
								   'FLOAT_FACTOR_ADJUSTMENT')
AND    STM.khr_id                       = c_khr_id
AND    STM.say_code                     = 'CURR'
AND    STM.active_yn                    = 'Y'
AND    NVL(STY.billable_yn,'N')         = 'Y'
AND  ROWNUM < 2;

  --  nikshah -- Bug # 5484903 Fixed,
  --  Changed c_oks_last_sch_bill_date_10(c_khr_id in NUMBER, c_transaction_date DATE) SQL definition
CURSOR c_oks_last_sch_bill_date_10(c_khr_id in NUMBER, c_transaction_date DATE) IS
select  max(schd.date_to_interface) last_sche_bill_date
from    okc_k_rel_objs rel,
        okc_k_headers_b hdr,
        okc_k_headers_b oks,
        okc_k_lines_b oks_line,
        OKS_LEVEL_ELEMENTS_V schd, OKS_STREAM_LEVELS_B strm
where 	hdr.id                          = c_khr_id
and     rty_code                        = 'OKLSRV'
and		rel.jtot_object1_code           = 'OKL_SERVICE'
and     rel.cle_id                      is null
and		rel.chr_id                      = hdr.id
and     rel.object1_id1                 = oks.id
and     oks.id                          = oks_line.dnz_chr_id
and     oks_line.lse_id                 in (7,8,9,10,11,35)
and     oks_line.id                     = strm.cle_id
and     strm.id                         = schd.rul_id
and     schd.date_to_interface          <= c_transaction_date;

  --  nikshah -- Bug # 5484903 Fixed,
  --  Changed c_oks_last_sch_bill_date_9(c_khr_id in NUMBER, c_transaction_date DATE) SQL definition
CURSOR c_oks_last_sch_bill_date_9(c_khr_id in NUMBER, c_transaction_date DATE) IS
select  max(schd.date_to_interface) last_sche_bill_date
from    okc_k_rel_objs rel,
        okc_k_headers_b hdr,
        okc_k_headers_b oks,
        okc_k_lines_b oks_line,
        OKS_LEVEL_ELEMENTS_V schd,
        okc_rules_b rules,
        okc_rule_groups_b rgp
where 	hdr.id                          = c_khr_id
and     rty_code                        = 'OKLSRV'
and		rel.jtot_object1_code           = 'OKL_SERVICE'
and     rel.cle_id                      is null
and		rel.chr_id                      = hdr.id
and     rel.object1_id1                 = oks.id
and     oks.id                          = oks_line.dnz_chr_id
and     oks_line.lse_id                 in (7,8,9,10,11,35)
and     oks_line.id                     = rgp.cle_id
and     rules.rgp_id                    = rgp.id
and     rules.id                        = schd.rul_id
and     rules.rule_information_category = 'SLL'
and     schd.date_to_interface          <= c_transaction_date;

/* -- rmunjulu R12 Fixes -- commented this cursor out and redone below
CURSOR c_oks_last_bill_date(c_khr_id in NUMBER, c_transaction_date DATE) IS
select max(AR.DUE_DATE) last_bill_date, tai.description transaction_type
from    okl_cnsld_ar_strms_b cnsld,
        AR_PAYMENT_SCHEDULES_ALL AR,
        OKL_XTL_SELL_INVS_V XTL,
        okl_trx_ar_invoices_v tai,
        okl_txl_ar_inv_lns_v til,
        okl_txd_ar_ln_dtls_v tld
where   cnsld.receivables_invoice_id    = AR.customer_trx_id
and     cnsld.khr_id                    = c_khr_id
and     cnsld.id                        = XTL.lsm_id
and     xtl.tld_id                     = tld.id
and     til.tai_id                      = tai.id
and     til.id                          = tld.til_id_details
and     tai.description                 in ('OKS Billing')
AND     tai.date_invoiced              <= c_transaction_date
group by tai.description;
*/

-- rmunjulu R12 Fixes - redone this cursor
CURSOR c_oks_last_bill_date(c_khr_id in NUMBER, c_transaction_date DATE) IS
select max(AR.DUE_DATE) last_bill_date, RACTRL.description transaction_type
from    --okl_cnsld_ar_strms_b cnsld,
        AR_PAYMENT_SCHEDULES_ALL AR,
        --OKL_XTL_SELL_INVS_V XTL,
        --okl_trx_ar_invoices_v tai,
        --okl_txl_ar_inv_lns_v til,
        --okl_txd_ar_ln_dtls_v tld
         okl_bpd_tld_ar_lines_v RACTRL
where   RACTRL.CUSTOMER_TRX_id    = AR.customer_trx_id
and     RACTRL.khr_id                    = c_khr_id
--and     cnsld.id                        = XTL.lsm_id
--and     xtl.tld_id                     = tld.id
--and     til.tai_id                      = tai.id
--and     til.id                          = tld.til_id_details
and     RACTRL.description                 in ('OKS Billing')
AND     RACTRL.date_invoiced              <= c_transaction_date
group by RACTRL.description;

CURSOR check_oks_ver IS
   SELECT 1
   FROM   okc_class_operations
   WHERE  cls_code = 'SERVICE'
   AND    opn_code = 'CHECK_RULE';

	l_api_version	CONSTANT NUMBER := 1;
	l_api_name	CONSTANT VARCHAR2(30)  := 'billing_status';
	l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_stream_id                           NUMBER;

--  l_khr_id                           NUMBER;
    i                                  NUMBER;
    j                                  NUMBER;

    -- abindal bug 4396207 start --
    k                                  NUMBER;
    l                                  NUMBER;
    l_link_hist_stream_id              NUMBER DEFAULT NULL;
    l_link_hist_stream_id_2            NUMBER DEFAULT NULL;
    l_max_last_bill_date               DATE DEFAULT NULL;
    l_max_last_bill_date_1             DATE DEFAULT NULL;

    L_EXIT_LOOP                        NUMBER DEFAULT 0;
    l_flag                             NUMBER DEFAULT NULL;

    l_valid_stm_tbl                    valid_stm_tbl_type;
    l_valid_sel_tbl                    valid_sel_tbl_type;
    -- abindal bug 4396207 end --

    -- abindal Added following variables for bug 4291677 start --
    l_cont_typ                         VARCHAR2(30);
    gone_to_AR                         BOOLEAN := TRUE;
    -- abindal Added following variables for bug 4291677 end --

    line_items_tbl                     line_items_tbl_type;
    l_bill_stat_rec                    bill_stat_rec_type;
    l_bill_stat_tbl                    bill_stat_tbl_type;
    l_oks_ver                          VARCHAR2(10);

    l_last_bill_date                   DATE DEFAULT NULL;
    l_exit_loop_flag                   NUMBER DEFAULT 0;


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


           i := 0;
           j := 0;
         -- abindal bug 4396207 start --
           k := 0;
           l := 0;
         -- abindal bug 4396207 end --


   FOR l_last_sch_bill_date IN c_last_sch_bill_date(p_khr_id, p_transaction_date)
    LOOP
        l_bill_stat_tbl(i).last_schedule_bill_date := l_last_sch_bill_date.last_sche_bill_date;
        l_stream_id := l_last_sch_bill_date.stream_id;
        l_bill_stat_tbl(i).transaction_type := 'RENTAL';
--        dbms_output.put_line('Stream :'||l_stream_id);
--        dbms_output.put_line('last_schedule_bill_date :'||l_bill_stat_tbl(i).last_schedule_bill_date);

    FOR l_last_bill_date IN c_last_bill_date(p_khr_id, p_transaction_date)
        LOOP

          l_bill_stat_tbl(i).last_bill_date := l_last_bill_date.last_bill_date;

        --    l_bill_stat_tbl(i).last_bill_date := TRUNC(SYSDATE);
--          l_bill_stat_tbl(i).transaction_type := l_last_bill_date.transaction_type;
--          dbms_output.put_line('last_bill_date :'||l_bill_stat_tbl(i).last_bill_date);

        END LOOP;

        i := i + 1;
    END LOOP;

    -- abindal bug 4396207 start --
    FOR l_last_bill_date IN c_last_bill_date(p_khr_id, p_transaction_date)
    LOOP

        l_bill_stat_tbl(i).last_bill_date := l_last_bill_date.last_bill_date;


    END LOOP;

	IF l_bill_stat_tbl.COUNT > 0 THEN  -- bug 4599897

      IF l_bill_stat_tbl(0).last_bill_date IS NULL THEN
      -- possibly because of rebook, lets see ...

        FOR l_last_bill_date_2 IN c_last_bill_date_2(p_khr_id, p_transaction_date)
        -- pick up all current stream elements for contract
        LOOP

            l_link_hist_stream_id := l_last_bill_date_2.LINK_HIST_STREAM_ID;

            IF l_link_hist_stream_id IS NOT NULL THEN
            -- this contract has been through a rebook ...

                L_EXIT_LOOP := 0;

                LOOP
                    -- Bug 5050707 : store all linked stream ids
                     l_valid_stm_tbl(k).STM_ID := l_link_hist_stream_id;
                     k:=k+1;
                    -- Bug 5050707:end

                    OPEN  c_last_bill_date_3(l_link_hist_stream_id);
                    FETCH c_last_bill_date_3 INTO l_link_hist_stream_id_2;
                    CLOSE c_last_bill_date_3;

                    IF l_link_hist_stream_id_2 IS NOT NULL THEN
                         l_link_hist_stream_id := l_link_hist_stream_id_2;
                         l_link_hist_stream_id_2 := NULL;
                         L_EXIT_LOOP := 0;
                    ELSE
                         /* bug 5050707 commented
                         l_valid_stm_tbl(k).STM_ID := l_link_hist_stream_id;
                         */
                    --   l_valid_sel_tbl(k).SEL_ID := l_link_hist_stream_id;
                         l_link_hist_stream_id := NULL;
                         l_link_hist_stream_id_2 := NULL;
                         L_EXIT_LOOP := 1;
                          /* bug 5050707 commented
                          k := k + 1;
                          */
                    END IF;

                    EXIT WHEN L_EXIT_LOOP = 1;

                END LOOP;
            /*Bug 5050707 : wrong assignment . It should always have stream id rather than stream element id so commented the code below
            ELSE
                l_valid_stm_tbl(k).STM_ID := l_last_bill_date_2.ID;
                k := k + 1;
            */
            END IF;


        END LOOP;

        -- no we have a table of valid sel_id's we can check
        -- against AR for MAX invoice due_date...

        k := l_valid_stm_tbl.FIRST;

        -- bug 5050707 :Changed to prevent PL/SQL: numeric or value errorif count is zero
        --  IF l_valid_stm_tbl.COUNT >= 0 THEN
        IF l_valid_stm_tbl.COUNT > 0 THEN
        -- bug 5050707 end
            LOOP

                FOR l_last_bill_date_4 IN c_last_bill_date_4(l_valid_stm_tbl(k).STM_ID, p_khr_id, p_transaction_date)
                LOOP

                    l_valid_sel_tbl(l).SEL_ID := l_last_bill_date_4.ID;
                    l := l + 1;

                END LOOP;

                EXIT WHEN (k = l_valid_stm_tbl.LAST);
                k := k + 1;

            END LOOP;

        END IF;

        l := l_valid_sel_tbl.FIRST;
        l_flag := 1;

        IF l_valid_sel_tbl.COUNT > 0 THEN    --- ?? why >= 0 any specific reason.. changed to > 0 -- Guru

            LOOP

                OPEN c_last_bill_date_1(l_valid_sel_tbl(l).SEL_ID, p_khr_id);
                FETCH c_last_bill_date_1 INTO l_max_last_bill_date;
                CLOSE c_last_bill_date_1;

                IF l_flag = 1 AND l_max_last_bill_date IS NOT NULL THEN

                    l_max_last_bill_date_1 := TRUNC(l_max_last_bill_date);
                    l_bill_stat_tbl(0).last_bill_date := TRUNC(l_max_last_bill_date_1);
                    l_flag := 0;
                END IF;

                IF l_max_last_bill_date IS NOT NULL THEN
                    IF TRUNC(l_max_last_bill_date) > TRUNC(l_max_last_bill_date_1) THEN
                        l_max_last_bill_date_1 := TRUNC(l_max_last_bill_date);

                        l_bill_stat_tbl(0).last_bill_date := TRUNC(l_max_last_bill_date_1);
                    END IF;
                END IF;

                EXIT WHEN (l = l_valid_sel_tbl.LAST);
                l := l + 1;

            END LOOP;

        END IF;

      END IF;

    END IF;
    -- abindal bug 4396207 end --

-----------------------------------------------------------------------------------------

    IF l_bill_stat_tbl.COUNT = 1 AND l_bill_stat_tbl(0).last_bill_date IS NULL THEN

        FOR l_okl_line_items IN c_okl_line_items(p_khr_id)
        LOOP
            j := j + 1;
            line_items_tbl(j).line_id := l_okl_line_items.id;
        END LOOP;

        IF line_items_tbl.COUNT > 0 THEN

            j := line_items_tbl.FIRST;

            LOOP

                OPEN  c_last_split_bill_date(  p_khr_id
                                             , line_items_tbl(j).line_id
                                             , TRUNC(p_transaction_date)
                                            );
                FETCH c_last_split_bill_date INTO l_last_bill_date;
                CLOSE c_last_split_bill_date;

                IF l_last_bill_date IS NOT NULL THEN
                    l_bill_stat_tbl(0).last_bill_date := TRUNC(l_last_bill_date);
                    l_exit_loop_flag := 1;
                ELSE
                    l_exit_loop_flag := 0;
                END IF;

                EXIT WHEN l_exit_loop_flag = 1;
                EXIT WHEN j = line_items_tbl.LAST;

                j := line_items_tbl.NEXT(j);

            END LOOP;

        END IF;

    END IF;

-----------------------------------------------------------------------------------------


         l_oks_ver := '?';
         OPEN check_oks_ver;
         FETCH check_oks_ver INTO l_oks_ver;

         IF check_oks_ver%NOTFOUND THEN
            l_oks_ver := '9';
         ELSE
            l_oks_ver := '10';
         END IF;

         CLOSE check_oks_ver;


   IF (l_oks_ver = '10') THEN
   FOR l_oks_last_sch_bill_date IN c_oks_last_sch_bill_date_10(p_khr_id, p_transaction_date)
    LOOP
        l_bill_stat_tbl(i).last_schedule_bill_date := l_oks_last_sch_bill_date.last_sche_bill_date;
        l_bill_stat_tbl(i).transaction_type := 'SERVICE';
--        dbms_output.put_line('Stream :'||l_stream_id);
--        dbms_output.put_line('last_schedule_bill_date :'||l_bill_stat_tbl(i).last_schedule_bill_date);

    FOR l_last_bill_date IN c_oks_last_bill_date(p_khr_id, p_transaction_date)
        LOOP

            l_bill_stat_tbl(i).last_bill_date := l_last_bill_date.last_bill_date;
--        dbms_output.put_line('last_bill_date :'||l_bill_stat_tbl(i).last_bill_date);

        END LOOP;

        i := i + 1;
    END LOOP;
   ELSE -- oks_ver = 9
--        dbms_output.put_line('I after Rent: '||i);
--        dbms_output.put_line('In OKS 9 Cursor');
   FOR l_oks_last_sch_bill_date IN c_oks_last_sch_bill_date_9(p_khr_id, p_transaction_date)
    LOOP
        l_bill_stat_rec.last_schedule_bill_date := l_oks_last_sch_bill_date.last_sche_bill_date;
        l_bill_stat_rec.transaction_type := 'SERVICE';
--        dbms_output.put_line('Stream :'||l_stream_id);
--        dbms_output.put_line('last_schedule_bill_date :'||l_bill_stat_rec.last_schedule_bill_date);

    FOR l_last_bill_date IN c_oks_last_bill_date(p_khr_id, p_transaction_date)
        LOOP

            l_bill_stat_rec.last_bill_date := l_last_bill_date.last_bill_date;
--        dbms_output.put_line('last_bill_date :'||l_bill_stat_rec.last_bill_date);

        END LOOP;

        l_bill_stat_tbl(i) := l_bill_stat_rec;

        i := i + 1;
    END LOOP;
    END IF;

    -- abindal START  bug 4290677 --

    IF l_bill_stat_tbl.COUNT > 0 THEN -- [1]

          -- loop thru the bill_statuses table
          FOR l_bill_counter IN l_bill_stat_tbl.FIRST..l_bill_stat_tbl.LAST LOOP

              -- For regular stream billing ie RENT billing
              IF l_bill_stat_tbl(l_bill_counter).transaction_type = 'RENTAL' THEN --[2]

                  -- Raise error if the last_bill_date is NULL
                  -- or if the last scheduled billing date > last billing run date

                  IF l_bill_stat_tbl(l_bill_counter).last_bill_date IS NOT NULL THEN
                      gone_to_AR := TRUE;
                  ELSIF l_bill_stat_tbl(l_bill_counter).last_bill_date IS NULL
                  OR (TRUNC(l_bill_stat_tbl(l_bill_counter).last_schedule_bill_date) >
                      TRUNC(l_bill_stat_tbl(l_bill_counter).last_bill_date)) THEN --[3]
                          gone_to_AR := FALSE;
                  END IF; --[-3]
              END IF; --[-2]
          END LOOP;
      END IF; --[-1]

      IF (NOT gone_to_AR) THEN -- [1]


        OPEN check_cont_typ(p_khr_id);
        FETCH check_cont_typ INTO l_cont_typ;
        CLOSE check_cont_typ;

        IF l_cont_typ = 'OKL_IMPORT' THEN
            i := 0;


            FOR l_last_sch_bill_date IN c_last_sch_bill_date(p_khr_id, p_transaction_date)
            LOOP


                FOR l_last_bill_date IN c_last_bill_date_import(p_khr_id, p_transaction_date)
                LOOP
                    l_bill_stat_tbl(i).last_bill_date := l_last_bill_date.last_bill_date;

                END LOOP;

                i := i + 1;

            END LOOP;

        END IF;


    END IF;

    -- abindal START  bug 4290677 --

    x_bill_stat_tbl := l_bill_stat_tbl;
	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);

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
  END billing_status;

END OKL_BILL_STATUS_PVT;

/
