--------------------------------------------------------
--  DDL for Package Body OKL_STREAMS_RECON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STREAMS_RECON_PVT" AS
/* $Header: OKLRSCRB.pls 120.10 2007/06/21 14:34:24 varangan noship $ */

SUBTYPE error_message_type IS Okl_Accounting_Util.ERROR_MESSAGE_TYPE;

--------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibhotla
-- Procedure Name       : recon_qry
-- Description          : Generates the streams reconciliation report
-- Business Rules       : we need to reconcile the streams amount
--                        We reconcile the Total streams, Billed streams
--                        cancled streams , Unbilled streams and
--                        then get the differences
--                        If the there is value for unbilled streams
--                        Send we show the amount for each deal type and
--                        associated products for the same.
--                        If the there is value for difference streams
--                        Send we show the amount for total billed amount
--                        unbilled amounts, canceled amount and then difference
--                        Difference amout = total_billed_amount - billed streams
--                        - Canceled streams - Unbilled streams.
-- Parameters           : p_contract_number, p_end_date
-- Version              : 1.0
-- History              : BAKUCHIB  20-JAN-2004 - 3344086 created
-- End of Commnets
--------------------------------------------------------------------------------
  PROCEDURE recon_qry (p_errbuf          OUT NOCOPY VARCHAR2,
                       p_retcode         OUT NOCOPY NUMBER,
                       p_contract_number IN okc_k_headers_b.contract_number%TYPE DEFAULT NULL,
                       p_end_date        IN VARCHAR2 DEFAULT NULL)
  IS
    l_api_name          CONSTANT VARCHAR2(40):= 'OKL_STREAMS_RECON_REPORT';
    l_api_version       CONSTANT NUMBER      := 1.0;
    p_api_version       CONSTANT NUMBER      := 1.0;
    l_init_msg_list              VARCHAR2(3) := okl_api.g_true;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
    x_return_status              VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    lp_end_date                  VARCHAR2(200);
    lp_contract_number           VARCHAR2(200);
    ln_org_id                    okc_k_headers_b.authoring_org_id%TYPE := 0;
    lv_org_name                  mtl_organizations.organization_name%TYPE := NULL;
    lv_sum_curr_code             VARCHAR2(2000);
    lv_curr_code                 VARCHAR2(20) := 'XXX';
    lv_clb_display               VARCHAR2(3) := 'N';
    lv_dif_display               VARCHAR2(3) := 'N';
    lv_curr_dif_code             VARCHAR2(20) := 'XXX';
    lv_dlts_curr_code            VARCHAR2(20) := 'XXX';
    lv_book_class                VARCHAR2(100) := 'XXX';
    lv_contract_number           VARCHAR2(150) := 'XXXXXXXXXX';
    lv_dlt_curr_code             VARCHAR2(2000);
    lv_tot_amt                   VARCHAR2(2000);
    lv_diff_dlts                 VARCHAR2(2000);
    lv_diff_dlts_dash            VARCHAR2(2000);
    lv_diff_dlts_khr             VARCHAR2(2000);
    lv_dlt_book                  VARCHAR2(2000);
    lv_dlt_pdt                   VARCHAR2(2000);
    lv_bil_amt                   VARCHAR2(2000);
    lv_can_amt                   VARCHAR2(2000);
    lv_clb_amt                   VARCHAR2(2000);
    lv_dif_amt                   VARCHAR2(2000);
    lv_dif_amt1                  VARCHAR2(2000);
    lv_dif_amt2                  VARCHAR2(2000);
    lv_dlt_tot_amt               VARCHAR2(2000);
    lv_dlt_amt                   VARCHAR2(2000);
    lv_diff_dlts_amt             VARCHAR2(2000);
    lv_sum_bil_dash              VARCHAR2(2000);
    lv_sum_can_dash              VARCHAR2(2000);
    lv_sum_clb_dash              VARCHAR2(2000);
    lv_value_clb                 VARCHAR2(3) := 'N';
    lv_value_dif                 VARCHAR2(3) := 'N';
    lv_sum_dif_dash              VARCHAR2(2000);
    lv_end_date                  DATE;
    delimit                      VARCHAR2(10) := ' ';
    lv_dash                      VARCHAR2(10) := '-';
    lv_frm_amt                   VARCHAR2(30) := '999,999,999,990.00';
    i                            NUMBER := 0;
    c                            NUMBER := 0;
    k                            NUMBER := 0;
    h                            NUMBER := 0;
    m                            NUMBER := 0;
    a                            NUMBER := 0;
    ln_tot_curr_amt              NUMBER := 0;
    ln_bil_curr_amt              NUMBER := 0;
    ln_can_curr_amt              NUMBER := 0;
    ln_clb_curr_amt              NUMBER := 0;
    ln_dif_curr_amt              NUMBER := 0;
    ln_tot_amt                   NUMBER := 0;
    ln_bil_amt                   NUMBER := 0;
    ln_can_amt                   NUMBER := 0;
    ln_clb_amt                   NUMBER := 0;
    ln_cnt_tot                   NUMBER := 0;
    ln_cnt_bil                   NUMBER := 0;
    ln_cnt_can                   NUMBER := 0;
    ln_cnt_clb                   NUMBER := 0;
    ln_dif_amt                   NUMBER := 0;
    ln_dlt_tot_amt               NUMBER := 0;
    ln_diff_dlts_amt             NUMBER := 0;
    ln_dlt_amt                   NUMBER := 0;
    ln_dif_amt1                  NUMBER := 0;
    ln_dif_amt2                  NUMBER := 0;
    TYPE unbill_rec_type IS RECORD (
         book_class      VARCHAR2(2000) := NULL,
         currency_code   VARCHAR2(2000) := NULL,
         product_name    VARCHAR2(2000) := NULL,
         amount          NUMBER := 0);
    TYPE value_rec_type IS RECORD (
         clb_amt            NUMBER := 0,
         dif_amt            NUMBER := 0,
         curr_code          okc_k_headers_b.currency_code%TYPE := NULL);
    TYPE diff_rec_type IS RECORD (
         contract_number         okc_k_headers_b.contract_number%TYPE := NULL,
         currency_code           okc_k_headers_b.currency_code%TYPE := NULL,
         total_billable_streams  VARCHAR2(2000) := NULL,
         billed_streams          VARCHAR2(2000) := NULL,
         cancelled_streams       VARCHAR2(2000) := NULL,
         unbilled_streams        VARCHAR2(2000) := NULL,
         amount                  NUMBER := 0,
         diff_amount             NUMBER := 0);
    TYPE unbill_tbl_type IS TABLE OF unbill_rec_type
          INDEX BY BINARY_INTEGER;
    TYPE value_tbl_type IS TABLE of value_rec_type
          INDEX BY BINARY_INTEGER;
    TYPE curr_tbl_type IS TABLE OF okc_k_headers_b.currency_code%TYPE
          INDEX BY BINARY_INTEGER;
    TYPE book_tbl_type IS TABLE OF VARCHAR2(2000)
          INDEX BY BINARY_INTEGER;
    TYPE diff_tbl_type IS TABLE OF diff_rec_type
          INDEX BY BINARY_INTEGER;
    lt_unbill_tbl          unbill_tbl_type;
    lt_value_tbl           value_tbl_type;
    lt_diff_tbl            diff_tbl_type;
    lt_diff_tbl_1          diff_tbl_type;
    lt_curr_tbl            curr_tbl_type;
    lt_curr_tbl_1          curr_tbl_type;
    lt_book_tbl            book_tbl_type;
    l_error_msg_rec        error_message_type;
    -- To get authoring org id
    CURSOR get_org_id
    IS
    SELECT name,
           organization_id
    FROM hr_operating_units
    WHERE ORGANIZATION_ID=MO_GLOBAL.GET_CURRENT_ORG_ID; --MOAC- Concurrent request

    -- To get different currency code in the system
    CURSOR get_currency_code(p_org_id          IN okc_k_headers_b.authoring_org_id%TYPE,
                             p_contract_number IN okc_k_headers_b.contract_number%TYPE,
                             p_end_date        IN okc_k_headers_b.end_date%TYPE)
    IS
    SELECT DISTINCT chrb.currency_code
    FROM okl_strm_elements ele,
         okl_streams stm,
         okl_strm_type_b sty,
         okl_k_headers khr,
         okc_k_headers_b chrb,
         okc_k_lines_b kle,
         okc_statuses_b khs,
         okc_statuses_b kls
    WHERE chrb.contract_number = NVL(p_contract_number,chrb.contract_number)
    AND chrb.end_date <= NVL(p_end_date,chrb.end_date)
    AND chrb.authoring_org_id = p_org_id
    AND chrb.id = stm.khr_id
    AND chrb.scs_code IN ('LEASE', 'LOAN')
    AND chrb.sts_code IN ( 'BOOKED','EVERGREEN')
    AND chrb.id = khr.id
    AND khr.deal_type  IS NOT NULL
    AND khs.code = chrb.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND stm.sty_id = sty.id
    AND stm.id = ele.stm_id
    AND sty.billable_yn = 'Y'
    AND stm.say_code <> 'WORK'
    AND stm.purpose_code IS NULL
    ORDER BY chrb.currency_code DESC;
    -- To get total streams total
    CURSOR get_total_csr(p_org_id          IN okc_k_headers_b.authoring_org_id%TYPE,
                         p_curr_code       IN okc_k_headers_b.currency_code%TYPE,
                         p_contract_number IN okc_k_headers_b.contract_number%TYPE,
                         p_end_date        IN okc_k_headers_b.end_date%TYPE)
    IS
    SELECT SUM(ele.amount) amount
    FROM okl_strm_elements ele,
         okl_streams stm,
         okl_strm_type_b sty,
         okl_k_headers khr,
         okc_k_headers_b chrb,
         okc_k_lines_b kle,
         okc_statuses_b khs,
         okc_statuses_b kls
    WHERE chrb.contract_number = NVL(p_contract_number,chrb.contract_number)
    AND chrb.end_date <= NVL(p_end_date,chrb.end_date)
    AND chrb.authoring_org_id = p_org_id
    AND chrb.currency_code = p_curr_code
    AND chrb.id = stm.khr_id
    AND chrb.scs_code IN ('LEASE', 'LOAN')
    AND chrb.sts_code IN ( 'BOOKED','EVERGREEN')
    AND chrb.id = khr.id
    AND khr.deal_type  IS NOT NULL
    AND khs.code = chrb.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND stm.sty_id = sty.id
    AND stm.id = ele.stm_id
    AND sty.billable_yn = 'Y'
    AND stm.say_code <> 'WORK'
    AND stm.purpose_code IS NULL;
    -- To get billed streams total
    CURSOR get_billed_csr(p_org_id          IN okc_k_headers_b.authoring_org_id%TYPE,
                          p_curr_code       IN okc_k_headers_b.currency_code%TYPE,
                          p_contract_number IN okc_k_headers_b.contract_number%TYPE,
                          p_end_date        IN okc_k_headers_b.end_date%TYPE)
    IS
    SELECT SUM(ste.amount) amount
    FROM okl_strm_type_v sty,
         okl_strm_elements ste,
         okl_streams stm,
         okc_statuses_b khs,
         okc_statuses_b kls,
         okl_k_headers khl,
         okc_k_lines_b kle,
         okc_k_headers_b khr
    WHERE khr.contract_number = NVL(p_contract_number,khr.contract_number)
    AND khr.end_date <= NVL(p_end_date,khr.end_date)
    AND khr.authoring_org_id = p_org_id
    AND khr.currency_code = p_curr_code
    AND khr.id = stm.khr_id
    AND khr.scs_code IN ('LEASE', 'LOAN')
    AND khr.sts_code IN ( 'BOOKED','EVERGREEN')
    AND khl.id = stm.khr_id
    AND khl.deal_type  IS NOT NULL
    AND khs.code = khr.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND ste.amount <> 0
    AND stm.id = ste.stm_id
    AND ste.date_billed  IS NOT NULL
    AND stm.say_code IN  ('CURR','HIST')
    AND sty.id = stm.sty_id
    AND sty.billable_yn  = 'Y';
    -- To get cancelled streams total
    CURSOR get_cancel_csr(p_org_id          IN okc_k_headers_b.authoring_org_id%TYPE,
                          p_curr_code       IN okc_k_headers_b.currency_code%TYPE,

                          p_contract_number IN okc_k_headers_b.contract_number%TYPE,
                          p_end_date        IN okc_k_headers_b.end_date%TYPE)
    IS
    SELECT SUM(ste.amount) amount
    FROM okl_strm_type_v sty,
         okl_strm_elements ste,
         okl_streams stm,
         okc_statuses_b khs,
         okc_statuses_b kls,
         okl_k_headers khl,
         okc_k_lines_b kle,
         okc_k_headers_b khr
    WHERE khr.contract_number = NVL(p_contract_number,khr.contract_number)
    AND khr.end_date <= NVL(p_end_date,khr.end_date)
    AND khr.authoring_org_id = p_org_id
    AND khr.currency_code = p_curr_code
    AND khr.id = stm.khr_id
    AND khr.scs_code IN ('LEASE', 'LOAN')
    AND khr.sts_code IN ( 'BOOKED','EVERGREEN')
    AND khl.id = stm.khr_id
    AND khl.deal_type  IS NOT NULL
    AND khs.code = khr.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND ste.amount <> 0
    AND stm.id = ste.stm_id
    AND ste.date_billed  IS NULL
    AND stm.active_yn = 'N'
    AND stm.say_code IN ('HIST')
    AND stm.purpose_code IS NULL
    AND sty.id = stm.sty_id
    AND sty.billable_yn  = 'Y';
    -- To get Closing balance streams total
    CURSOR get_clobal_csr(p_org_id          IN okc_k_headers_b.authoring_org_id%TYPE,
                          p_curr_code       IN okc_k_headers_b.currency_code%TYPE,
                          p_contract_number IN okc_k_headers_b.contract_number%TYPE,
                          p_end_date        IN okc_k_headers_b.end_date%TYPE)
    IS
    SELECT SUM(ste.amount) amount
    FROM okl_strm_type_v sty,
         okl_strm_elements ste,
         okl_streams stm,
         okc_statuses_b khs,
         okc_statuses_b kls,
         okl_k_headers khl,
         okc_k_lines_b kle,
         okc_k_headers_b khr
    WHERE khr.contract_number = NVL(p_contract_number,khr.contract_number)
    AND khr.end_date <= NVL(p_end_date,khr.end_date)
    AND khr.authoring_org_id = p_org_id
    AND khr.currency_code  = p_curr_code
    AND khr.id = stm.khr_id
    AND khr.scs_code IN ('LEASE', 'LOAN')
    AND khr.sts_code IN ( 'BOOKED','EVERGREEN')
    AND khl.id = stm.khr_id
    AND khl.deal_type  IS NOT NULL
    AND khs.code = khr.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND stm.khr_id = khr.id
    AND stm.id = ste.stm_id
    AND ste.amount <> 0
    AND ste.date_billed  IS NULL
    AND stm.active_yn = 'Y'
    AND stm.say_code = 'CURR'
    AND stm.purpose_code IS NULL
    AND sty.id = stm.sty_id
    AND sty.billable_yn  = 'Y';
    -- To get details of Closing balance based on the deal type and
    -- Product associated to the same
    CURSOR get_dlts_clobal_csr(p_org_id          IN okc_k_headers_b.authoring_org_id%TYPE,
                               p_contract_number IN okc_k_headers_b.contract_number%TYPE,
                               p_end_date        IN okc_k_headers_b.end_date%TYPE)
    IS
    SELECT khr.currency_code currency_code,
           fnd.meaning book_class,
           pdt.name product_name,
           SUM(ste.amount) amount
    FROM okl_strm_type_v sty,
         okl_strm_elements ste,
         okl_streams stm,
         okc_statuses_b khs,
         okc_statuses_b kls,
         okl_products pdt,
         fnd_lookup_values fnd,
         okl_k_headers khl,
         okc_k_lines_b kle,
         okc_k_headers_b khr
    WHERE khr.contract_number = NVL(p_contract_number,khr.contract_number)
    AND khr.end_date <= NVL(p_end_date,khr.end_date)
    AND khr.authoring_org_id = p_org_id
    AND khr.id = stm.khr_id
    AND khr.scs_code IN ('LEASE', 'LOAN')
    AND khr.sts_code IN ( 'BOOKED','EVERGREEN')
    AND khl.id = stm.khr_id
    AND khl.deal_type  IS NOT NULL
    AND khs.code = khr.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND stm.khr_id = khr.id
    AND stm.id = ste.stm_id
    AND ste.amount <> 0
    AND ste.date_billed  IS NULL
    AND stm.active_yn = 'Y'
    AND stm.say_code = 'CURR'
    AND stm.purpose_code IS NULL
    AND sty.id = stm.sty_id
    AND sty.billable_yn  = 'Y'
    AND fnd.lookup_code = khl.deal_type
    AND fnd.lookup_type = 'OKL_BOOK_CLASS'
    AND fnd.LANGUAGE = USERENV('LANG')
    AND khl.pdt_id = pdt.id(+)
    GROUP BY khr.currency_code,
             fnd.meaning,
             pdt.name
    ORDER BY 1 DESC ;
    -- To get Difference contracts streams
    CURSOR get_diff_csr(p_org_id          IN okc_k_headers_b.authoring_org_id%TYPE,
                        p_contract_number IN okc_k_headers_b.contract_number%TYPE,
                        p_end_date        IN okc_k_headers_b.end_date%TYPE)
    IS
    SELECT chrb.currency_code currency_code,
           chrb.contract_number contract_number,
           'Y' total_billable_streams,
           'N' billed_streams,
           'N' cancelled_streams,
           'N' unbilled_streams,
           SUM(ele.amount) amount
    FROM okl_strm_elements ele,
         okl_streams stm,
         okl_strm_type_b sty,
         okl_k_headers khr,
         okc_k_headers_b chrb,
         okc_k_lines_b kle,
         okc_statuses_b khs,
         okc_statuses_b kls
    WHERE chrb.contract_number = NVL(p_contract_number,chrb.contract_number)
    AND chrb.end_date <= NVL(p_end_date,chrb.end_date)
    AND chrb.authoring_org_id = p_org_id
    AND chrb.id = stm.khr_id
    AND chrb.scs_code IN ('LEASE', 'LOAN')
    AND chrb.sts_code IN ( 'BOOKED','EVERGREEN')
    AND chrb.id = khr.id
    AND khr.deal_type  IS NOT NULL
    AND khs.code = chrb.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND stm.sty_id = sty.id
    AND stm.id = ele.stm_id
    AND sty.billable_yn = 'Y'
    AND stm.say_code <> 'WORK'
    AND stm.purpose_code IS NULL
    GROUP BY chrb.contract_number,
             chrb.currency_code
    UNION
    SELECT khr.currency_code currency_code,
           khr.contract_number contract_number,
           'N' total_billable_streams,
           'Y' billed_streams,
           'N' cancelled_streams,
           'N' unbilled_streams,
           SUM(ste.amount) billed_streams
    FROM okl_strm_type_v sty,
         okl_strm_elements ste,
         okl_streams stm,
         okc_statuses_b khs,
         okc_statuses_b kls,
         okl_k_headers khl,
         okc_k_lines_b kle,
         okc_k_headers_b khr
    WHERE khr.contract_number = NVL(p_contract_number,khr.contract_number)
    AND khr.end_date <= NVL(p_end_date,khr.end_date)
    AND khr.authoring_org_id = p_org_id
    AND khr.id = stm.khr_id
    AND khr.scs_code IN ('LEASE', 'LOAN')
    AND khr.sts_code IN ( 'BOOKED','EVERGREEN')
    AND khl.id = stm.khr_id
    AND khl.deal_type  IS NOT NULL
    AND khs.code = khr.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND ste.amount <> 0
    AND stm.id = ste.stm_id
    AND ste.date_billed  IS NOT NULL
    AND stm.say_code IN  ('CURR','HIST')
    AND sty.id = stm.sty_id
    AND sty.billable_yn  = 'Y'
    GROUP BY khr.contract_number,
             khr.currency_code
    UNION
    SELECT khr.currency_code currency_code,
           khr.contract_number contract_number,
           'N' total_billable_streams,
           'N' billed_streams,
           'Y' cancelled_streams,
           'N' unbilled_streams,
           SUM(ste.amount)
    FROM okl_strm_type_v sty,
         okl_strm_elements ste,
         okl_streams stm,
         okc_statuses_b khs,
         okc_statuses_b kls,
         okl_k_headers khl,
         okc_k_lines_b kle,
         okc_k_headers_b khr
    WHERE khr.contract_number = NVL(p_contract_number,khr.contract_number)
    AND khr.end_date <= NVL(p_end_date,khr.end_date)
    AND khr.authoring_org_id = p_org_id
    AND khr.id = stm.khr_id
    AND khr.scs_code IN ('LEASE', 'LOAN')
    AND khr.sts_code IN ( 'BOOKED','EVERGREEN')
    AND khl.id = stm.khr_id
    AND khl.deal_type  IS NOT NULL
    AND khs.code = khr.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND ste.amount <> 0
    AND stm.id = ste.stm_id
    AND ste.date_billed  IS NULL
    AND stm.active_yn = 'N'
    AND stm.say_code IN ('HIST')
    AND stm.purpose_code IS NULL
    AND sty.id = stm.sty_id
    AND sty.billable_yn  = 'Y'
    GROUP BY khr.contract_number,
             khr.currency_code
    UNION
    SELECT khr.currency_code currency_code,
           khr.contract_number contract_number,
           'N' total_billable_streams,
           'N' billed_streams,
           'N' cancelled_streams,
           'Y' unbilled_streams,
           SUM(ste.amount)
    FROM okl_strm_type_v sty,
         okl_strm_elements ste,
         okl_streams stm,
         okc_statuses_b khs,
         okc_statuses_b kls,
         okl_k_headers khl,
         okc_k_lines_b kle,
         okc_k_headers_b khr
    WHERE khr.contract_number = NVL(p_contract_number,khr.contract_number)
    AND khr.end_date <= NVL(p_end_date,khr.end_date)
    AND khr.authoring_org_id = p_org_id
    AND khr.id = stm.khr_id
    AND khr.scs_code IN ('LEASE', 'LOAN')
    AND khr.sts_code IN ( 'BOOKED','EVERGREEN')
    AND khl.id = stm.khr_id
    AND khl.deal_type  IS NOT NULL
    AND khs.code = khr.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND stm.khr_id = khr.id
    AND stm.id = ste.stm_id
    AND ste.amount <> 0
    AND ste.date_billed  IS NULL
    AND stm.active_yn = 'Y'
    AND stm.say_code = 'CURR'
    AND stm.purpose_code IS NULL
    AND sty.id = stm.sty_id
    AND sty.billable_yn  = 'Y'
    GROUP BY khr.contract_number,
             khr.currency_code
    ORDER BY 1 DESC;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    p_retcode := 0;
    x_return_status := okl_api.start_activity(
                               l_api_name,
                               G_PKG_NAME,
                               l_init_msg_list,
                               l_api_version,
                               p_api_version,
                               '_PVT',
                               x_return_status);
    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      fnd_file.put_line(fnd_file.log,SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_ERROR_ACTIVITY'),1,30));
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_Status = okl_api.g_ret_sts_error) THEN
      fnd_file.put_line(fnd_file.log,SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_ERROR_ACTIVITY'),1,30));
      RAISE okl_api.g_exception_error;
    END IF;
    fnd_file.put_line(fnd_file.log,SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_START_ACTIVITY'),1,34));
    fnd_file.put_line(fnd_file.log,delimit);
    -- we need to convert the date from varchar2 to date format
    -- Since the parametr we use in the concurrent program is fnd_standard_date
    IF p_end_date IS NOT NULL THEN
      lv_end_date := fnd_date.canonical_to_date(p_end_date);
    END IF;
    -- To get authoring org id
    OPEN get_org_id;
    FETCH get_org_id INTO lv_org_name,
                          ln_org_id;
    IF get_org_id%NOTFOUND THEN
      fnd_file.put_line(fnd_file.log,SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_ERROR_ORG'),1,36));
      raise okl_api.g_exception_error;
    END IF;
    CLOSE get_org_id;
    -- Filling in the header section of the report file
    fnd_file.put_line(fnd_file.log, SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_GEN_SUM'),1,52));
    fnd_file.put_line(fnd_file.log, ' ');
    fnd_file.put_line(fnd_file.output,RPAD(delimit,55)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_ACCT_LEASE_MANAGEMENT'),1,30)||LPAD(delimit,55));
    fnd_file.put_line(fnd_file.output,RPAD(delimit,47)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_RECON_PROCESS_REPORT'),1,50)||LPAD(delimit,47));
    fnd_file.put_line(fnd_file.output,RPAD(delimit,47)||RPAD(lv_dash,38,lv_dash)||LPAD(delimit,47));
    fnd_file.put_line(fnd_file.output,SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_RUN_DATE'),1,12)||RPAD(delimit,8)||': '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
    fnd_file.put_line(fnd_file.output,SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_OPERUNIT'),1,20)||RPAD(delimit,2)||': '||lv_org_name);
    fnd_file.put_line(fnd_file.output,delimit);
    fnd_file.put_line(fnd_file.output,SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_PARAMETERS'),1,13));
    fnd_file.put_line(fnd_file.output,RPAD(lv_dash,13,lv_dash));
    lp_contract_number := SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_CONTRACT_NUMBER'),1,20)||RPAD(delimit,1)||': ';
    fnd_file.put_line(fnd_file.output,lp_contract_number||NVL(p_contract_number,okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_NOT_SUPPLIED')));
    lp_end_date := SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_END_DATE'),1,12)||RPAD(delimit,8)||': ';
    fnd_file.put_line(fnd_file.output,lp_end_date||NVL(p_end_date,okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_NOT_SUPPLIED')));
    fnd_file.put_line(fnd_file.output,delimit);
    -- Filling in the summary section of the report file
    -- Now we are populating the FND_FILE to display the above resultant record
    fnd_file.put_line(fnd_file.output,RPAD(delimit,12)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_SUMMARY'),1,10));
    fnd_file.put_line(fnd_file.output,RPAD(delimit,12)||RPAD(lv_dash,7,lv_dash));
    fnd_file.put_line(fnd_file.output,delimit);
    lv_sum_bil_dash  := RPAD(delimit,45);
    lv_tot_amt   := RPAD(delimit,15)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_TOT_BILL_STREAM'),1,29)||RPAD(delimit,7)||':';
    lv_bil_amt := RPAD(delimit,15)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_BILL_STREAM'),1,25)||RPAD(delimit,10)||':';
    lv_can_amt := RPAD(delimit,15)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_CANCEL_STREAM'),1,29)||RPAD(delimit,7)||':';
    lv_clb_amt := RPAD(delimit,15)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_UNBILL_STREAM'),1,28)||RPAD(delimit,8)||':';
    lv_dif_amt   := RPAD(delimit,15)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_DIFF_STREAM'),1,13)||RPAD(delimit,19)||':';
    lv_dif_amt1  := RPAD(delimit,45);
    lv_dif_amt2  := RPAD(delimit,45);
    lv_sum_bil_dash     := lv_sum_bil_dash||RPAD(lv_dash,22,lv_dash)||RPAD(delimit,1);
    FOR get_currency_code_rec IN get_currency_code(p_org_id          => ln_org_id,
                                                   p_contract_number => p_contract_number,
                                                   p_end_date        => lv_end_date) LOOP
      fnd_file.put_line(fnd_file.output,delimit||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_CURRENCY'),1,11)||' : '||get_currency_code_rec.currency_code);
      fnd_file.put_line(fnd_file.output,delimit);
      -- To get total streams total
      OPEN  get_total_csr(p_org_id          => ln_org_id,
                          p_curr_code       => get_currency_code_rec.currency_code,
                          p_contract_number => p_contract_number,
                          p_end_date        => lv_end_date);
      FETCH get_total_csr INTO ln_tot_curr_amt;
      IF get_total_csr%NOTFOUND THEN
        ln_tot_curr_amt := 0;
      END IF;
      CLOSE get_total_csr;
      -- To get billed streams total
      OPEN  get_billed_csr(p_org_id          => ln_org_id,
                           p_curr_code       => get_currency_code_rec.currency_code,
                           p_contract_number => p_contract_number,
                           p_end_date        => lv_end_date);
      FETCH get_billed_csr INTO ln_bil_curr_amt;
      IF get_billed_csr%NOTFOUND THEN
        ln_bil_curr_amt := 0;
      END IF;
      CLOSE get_billed_csr;
      fnd_file.put_line(fnd_file.output,lv_tot_amt||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(ln_tot_curr_amt,0),lv_frm_amt))),1,22),22));
      fnd_file.put_line(fnd_file.output,lv_bil_amt||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(ln_bil_curr_amt,0),lv_frm_amt))),1,22),22));
      fnd_file.put_line(fnd_file.output,lv_sum_bil_dash);
      -- To get differnece in the stream amount
      -- to show the difference of Total billable streams and billed streams we do the below
      ln_dif_amt1  := ln_tot_curr_amt - ln_bil_curr_amt;
      fnd_file.put_line(fnd_file.output,lv_dif_amt1||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(ln_dif_amt1,0),lv_frm_amt))),1,22),22));
      -- To get cancelled streams total
      OPEN  get_cancel_csr(p_org_id          => ln_org_id,
                           p_curr_code       => get_currency_code_rec.currency_code,
                           p_contract_number => p_contract_number,
                           p_end_date        => lv_end_date);
      FETCH get_cancel_csr INTO ln_can_curr_amt;
      IF get_cancel_csr%NOTFOUND THEN
        ln_can_curr_amt := 0;
      END IF;
      CLOSE get_cancel_csr;
      fnd_file.put_line(fnd_file.output,lv_can_amt||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(ln_can_curr_amt,0),lv_frm_amt))),1,22),22));
      fnd_file.put_line(fnd_file.output,lv_sum_bil_dash);
      -- to show the difference of 1 difference amount and the cancelled amounts
      ln_dif_amt2  := ln_dif_amt1 - ln_can_curr_amt;
      fnd_file.put_line(fnd_file.output,lv_dif_amt2||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(ln_dif_amt2,0),lv_frm_amt))),1,22),22));
      -- To get Closing balance streams total
      OPEN  get_clobal_csr(p_org_id           => ln_org_id,
                           p_curr_code       => get_currency_code_rec.currency_code,
                           p_contract_number => p_contract_number,
                           p_end_date        => lv_end_date);
      FETCH get_clobal_csr INTO ln_clb_curr_amt;
      IF get_clobal_csr%NOTFOUND THEN
        ln_clb_curr_amt := 0;
      END IF;
      CLOSE get_clobal_csr;
      -- To let know the further process that
      -- there was value for un billed streams
      IF ln_clb_curr_amt <> 0 THEN
        lt_value_tbl(a).clb_amt := ln_clb_curr_amt;
      END IF;
      fnd_file.put_line(fnd_file.output,lv_clb_amt||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(ln_clb_curr_amt,0),lv_frm_amt))),1,22),22));
      fnd_file.put_line(fnd_file.output,lv_sum_bil_dash);
      -- To get differnece in the stream amount
      -- the components of these are the total Billable streasm less billed streams
      -- To get differnece in the stream amount
      -- less cancelled streams and less unbilled streams
      -- To get differnece in the stream amount
      ln_dif_amt   := NVL(ln_tot_curr_amt,0) - NVL(ln_bil_curr_amt,0) - NVL(ln_can_curr_amt,0) - NVL(ln_clb_curr_amt,0);
      -- To let know the further process that
      -- there was value for Difference streams
      IF ln_dif_amt <> 0 THEN
        lt_value_tbl(a).dif_amt   := ln_dif_amt;
        lt_value_tbl(a).curr_code := get_currency_code_rec.currency_code;
      ELSIF ln_dif_amt = 0 THEN
        lt_value_tbl(a).dif_amt   := ln_dif_amt;
        lt_value_tbl(a).curr_code := get_currency_code_rec.currency_code;
      END IF;
      fnd_file.put_line(fnd_file.output,lv_dif_amt||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(ln_dif_amt,0),lv_frm_amt))),1,22),22));
      fnd_file.put_line(fnd_file.output,lv_sum_bil_dash);
      fnd_file.put_line(fnd_file.output,delimit);
      fnd_file.put_line(fnd_file.output,delimit);
      a := a + 1;
    END LOOP;
    -- Filling in the Details section of the unbilled Streams report file
    fnd_file.put_line(fnd_file.log, SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_GEN_DETAIL_UNBILL'),1,64));
    fnd_file.put_line(fnd_file.log, ' ');
    IF lt_value_tbl.COUNT > 0 THEN
      FOR i IN lt_value_tbl.FIRST..lt_value_tbl.LAST LOOP
        IF lt_value_tbl(i).clb_amt <> 0 THEN
          lv_value_clb := 'Y';
          EXIT WHEN (lv_value_clb = 'Y');
        ELSIF lt_value_tbl(i).clb_amt = 0 THEN
          lv_value_clb := 'N';
        END IF;
      END LOOP;
    END IF;
    fnd_file.put_line(fnd_file.output,RPAD(delimit,12)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_DLTS_UNBILLED_STREAM'),1,36));
    fnd_file.put_line(fnd_file.output,RPAD(delimit,12)||RPAD(lv_dash,27,lv_dash));
    fnd_file.put_line(fnd_file.output,delimit);
    IF lv_value_clb = 'Y' THEN
      -- To get details of Closing balance based on the deal type and
      -- Product associated to the same
      FOR get_dlts_clobal_rec IN get_dlts_clobal_csr(p_org_id          => ln_org_id,
                                                     p_contract_number => p_contract_number,
                                                     p_end_date        => lv_end_date) LOOP
        lt_unbill_tbl(i).book_class    := get_dlts_clobal_rec.book_class;
        lt_unbill_tbl(i).currency_code := get_dlts_clobal_rec.currency_code;
        lt_unbill_tbl(i).product_name  := get_dlts_clobal_rec.product_name;
        lt_unbill_tbl(i).amount        := get_dlts_clobal_rec.amount;
        i := i + 1;
      END LOOP;
      i := 0;
      IF lt_unbill_tbl.COUNT > 0 THEN
        FOR j IN lt_unbill_tbl.FIRST..lt_unbill_tbl.LAST LOOP
          IF lv_curr_code <> lt_unbill_tbl(j).currency_code THEN
            lt_curr_tbl(k) := lt_unbill_tbl(j).currency_code;
            lv_curr_code := lt_curr_tbl(k);
            k := k + 1;
          END IF;
        END LOOP;
        FOR m IN lt_curr_tbl.FIRST..lt_curr_tbl.LAST LOOP
          lv_dlt_curr_code  := delimit||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_CURRENCY'),1,11)||' : '||lt_curr_tbl(m);
          fnd_file.put_line(fnd_file.output,lv_dlt_curr_code);
          fnd_file.put_line(fnd_file.output,delimit);
          lv_dlt_tot_amt  := NULL;
          lv_dlt_amt  := NULL;
          ln_dlt_tot_amt  := 0;
          ln_dlt_amt  := 0;
          lv_dlt_book := delimit||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_BOOK_CLASSIFICATION'),1,25)||delimit||lv_dash||delimit;
          lv_dlt_pdt := RPAD(delimit,10)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_FINANCIAL_PRODUCT'),1,23)||delimit;
          FOR j IN lt_unbill_tbl.FIRST..lt_unbill_tbl.LAST LOOP
            IF lv_book_class <> lt_unbill_tbl(j).book_class AND
               lt_unbill_tbl(j).currency_code = lt_curr_tbl(m) THEN
              fnd_file.put_line(fnd_file.output,lv_dlt_book||lt_unbill_tbl(j).book_class);
              lv_book_class := lt_unbill_tbl(j).book_class;
              fnd_file.put_line(fnd_file.output,delimit);
              fnd_file.put_line(fnd_file.output,lv_dlt_pdt);
              ln_dlt_amt := 0;
              FOR h IN lt_unbill_tbl.FIRST..lt_unbill_tbl.LAST LOOP
                IF lt_unbill_tbl(j).book_class = lt_unbill_tbl(h).book_class AND
                  lt_unbill_tbl(j).currency_code = lt_curr_tbl(m) THEN
                  fnd_file.put_line(fnd_file.output,RPAD(delimit,15)||RPAD(substr(lt_unbill_tbl(h).product_name,1,20),20,delimit)||RPAD(delimit,9)||':'||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(lt_unbill_tbl(h).amount,0),lv_frm_amt))),1,22),22));
                  ln_dlt_amt     := ln_dlt_amt + lt_unbill_tbl(h).amount;
                  ln_dlt_tot_amt := ln_dlt_tot_amt + lt_unbill_tbl(h).amount;
                END IF;
              END LOOP;
              fnd_file.put_line(fnd_file.output,RPAD(delimit,45)||RPAD(lv_dash,22,lv_dash));
              lv_dlt_amt := RPAD(delimit,15)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_TOTAL'),1,7)||RPAD(delimit,24)||':';
              lv_dlt_amt := lv_dlt_amt||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(ln_dlt_amt,0),lv_frm_amt))),1,22),22);
              fnd_file.put_line(fnd_file.output,lv_dlt_amt);
            END IF;
          END LOOP;
          fnd_file.put_line(fnd_file.output,RPAD(delimit,45)||RPAD(lv_dash,22,lv_dash));
          lv_dlt_tot_amt := RPAD(delimit,15)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_TOTAL_UNBILL_STREAM'),1,29)||RPAD(delimit,7)||':';
          lv_dlt_tot_amt := lv_dlt_tot_amt||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(ln_dlt_tot_amt,0),lv_frm_amt))),1,22),22);
          fnd_file.put_line(fnd_file.output,lv_dlt_tot_amt);
          fnd_file.put_line(fnd_file.output,RPAD(delimit,45)||RPAD(lv_dash,22,lv_dash));
        END LOOP;
      END IF;
    ELSIF lv_value_clb = 'N' THEN
      fnd_file.put_line(fnd_file.output,RPAD(delimit,12)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_NO_RECORDS'),1,21));
    END IF;
    -- Filling in the Details section of the Difference report file
    fnd_file.put_line(fnd_file.log, SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_GEN_DETAIL_DIFF'),1,67));
    fnd_file.put_line(fnd_file.log, ' ');
    fnd_file.put_line(fnd_file.output,delimit);
    fnd_file.put_line(fnd_file.output,RPAD(delimit,12)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_DLTS_DIFF_STREAM'),1,38));
    fnd_file.put_line(fnd_file.output,RPAD(delimit,12)||RPAD(lv_dash,29,lv_dash));
    fnd_file.put_line(fnd_file.output,delimit);
    FOR get_diff_rec IN  get_diff_csr(p_org_id          => ln_org_id,
                                      p_contract_number => p_contract_number,
                                      p_end_date        => lv_end_date) LOOP
      lt_diff_tbl(h).contract_number        :=  get_diff_rec.contract_number;
      lt_diff_tbl(h).currency_code          :=  get_diff_rec.currency_code;
      lt_diff_tbl(h).total_billable_streams :=  get_diff_rec.total_billable_streams;
      lt_diff_tbl(h).billed_streams         :=  get_diff_rec.billed_streams;
      lt_diff_tbl(h).cancelled_streams      :=  get_diff_rec.cancelled_streams;
      lt_diff_tbl(h).unbilled_streams       :=  get_diff_rec.unbilled_streams;
      lt_diff_tbl(h).amount                 :=  get_diff_rec.amount;
      h := h + 1;
    END LOOP;
    IF lt_diff_tbl.COUNT > 0 THEN
      lv_contract_number :=  lt_diff_tbl(lt_diff_tbl.FIRST).contract_number;
      FOR i IN lt_diff_tbl.FIRST..lt_diff_tbl.LAST LOOP
        IF lv_contract_number = lt_diff_tbl(i).contract_number THEN
          lt_diff_tbl_1(m).contract_number := lt_diff_tbl(i).contract_number;
          lt_diff_tbl_1(m).currency_code := lt_diff_tbl(i).currency_code;
          IF lt_diff_tbl(i).total_billable_streams = 'Y' THEN
            lt_diff_tbl_1(m).total_billable_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
          IF lt_diff_tbl(i).billed_streams = 'Y' THEN
            lt_diff_tbl_1(m).billed_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
          IF lt_diff_tbl(i).cancelled_streams = 'Y' THEN
            lt_diff_tbl_1(m).cancelled_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
          IF lt_diff_tbl(i).unbilled_streams = 'Y' THEN
            lt_diff_tbl_1(m).unbilled_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
        ELSIF lv_contract_number <> lt_diff_tbl(i).contract_number THEN
          m := m + 1;
          lv_contract_number := lt_diff_tbl(i).contract_number;
          lt_diff_tbl_1(m).contract_number := lt_diff_tbl(i).contract_number;
          lt_diff_tbl_1(m).currency_code := lt_diff_tbl(i).currency_code;
          IF lt_diff_tbl(i).total_billable_streams = 'Y' THEN
            lt_diff_tbl_1(m).total_billable_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
          IF lt_diff_tbl(i).billed_streams = 'Y' THEN
            lt_diff_tbl_1(m).billed_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
          IF lt_diff_tbl(i).cancelled_streams = 'Y' THEN
            lt_diff_tbl_1(m).cancelled_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
          IF lt_diff_tbl(i).unbilled_streams = 'Y' THEN
            lt_diff_tbl_1(m).unbilled_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
        END IF;
      END LOOP;
      lv_diff_dlts := delimit;
      lv_diff_dlts := lv_diff_dlts||okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_CONTRACT_NUMBER')||RPAD(delimit,1);
      lv_diff_dlts := lv_diff_dlts||okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_TOT_BILL_STREAM')||RPAD(delimit,1);
      lv_diff_dlts := lv_diff_dlts||LPAD(SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_BILL_STREAM'),5),22)||RPAD(delimit,1);
      lv_diff_dlts := lv_diff_dlts||LPAD(SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_CANCEL_STREAM'),5),22)||RPAD(delimit,1);
      lv_diff_dlts := lv_diff_dlts||LPAD(SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_UNBILL_STREAM'),5),22)||RPAD(delimit,1);
      lv_diff_dlts := lv_diff_dlts||LPAD(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_DIFF_STREAM'),22)||RPAD(delimit,1);
      lv_diff_dlts_dash := delimit;
      lv_diff_dlts_dash := lv_diff_dlts_dash||RPAD(lv_dash,15,lv_dash)||RPAD(delimit,1);
      lv_diff_dlts_dash := lv_diff_dlts_dash||RPAD(lv_dash,22,lv_dash)||RPAD(delimit,1);
      lv_diff_dlts_dash := lv_diff_dlts_dash||RPAD(lv_dash,22,lv_dash)||RPAD(delimit,1);
      lv_diff_dlts_dash := lv_diff_dlts_dash||RPAD(lv_dash,22,lv_dash)||RPAD(delimit,1);
      lv_diff_dlts_dash := lv_diff_dlts_dash||RPAD(lv_dash,22,lv_dash)||RPAD(delimit,1);
      lv_diff_dlts_dash := lv_diff_dlts_dash||RPAD(lv_dash,22,lv_dash)||RPAD(delimit,1);
      FOR j IN lt_diff_tbl_1.FIRST..lt_diff_tbl_1.LAST LOOP
        IF lv_curr_dif_code <> lt_diff_tbl_1(j).currency_code THEN
          lt_curr_tbl_1(c) := lt_diff_tbl_1(j).currency_code;
          lv_curr_dif_code := lt_curr_tbl_1(c);
            c := c + 1;
        END IF;
      END LOOP;
      FOR j IN lt_curr_tbl_1.FIRST..lt_curr_tbl_1.LAST LOOP
        ln_diff_dlts_amt := 0;
        lv_diff_dlts_amt := NULL;
        lv_value_dif := NULL;
        IF lt_value_tbl.COUNT > 0 THEN
          FOR i IN lt_value_tbl.FIRST..lt_value_tbl.LAST LOOP
            IF lt_value_tbl(i).dif_amt <> 0 AND
              lt_value_tbl(i).curr_code = lt_curr_tbl_1(j) THEN
              lv_value_dif := 'Y';
              EXIT WHEN (lv_value_dif = 'Y');
            ELSIF lt_value_tbl(i).dif_amt = 0 AND
                  lt_value_tbl(i).curr_code = lt_curr_tbl_1(j) THEN
              lv_value_dif := 'N';
            END IF;
          END LOOP;
        ELSIF NVL(lv_value_dif,'N') = 'N' THEN
          fnd_file.put_line(fnd_file.output,RPAD(delimit,12)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_NO_RECORDS'),1,21));
        END IF;
        IF lv_value_dif = 'Y' THEN
          fnd_file.put_line(fnd_file.output,delimit||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_CURRENCY'),1,11)||' : '||lt_curr_tbl_1(j));

          fnd_file.put_line(fnd_file.output,delimit||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_REMARKS'),1,11)||'  : ');
          fnd_file.put_line(fnd_file.output,lv_diff_dlts);
          fnd_file.put_line(fnd_file.output,lv_diff_dlts_dash);
          FOR i IN lt_diff_tbl_1.FIRST..lt_diff_tbl_1.LAST LOOP
            IF lt_diff_tbl_1(i).currency_code = lt_curr_tbl_1(j) THEN
              lt_diff_tbl_1(i).diff_amount := NVL(TO_NUMBER(lt_diff_tbl_1(i).total_billable_streams),0) -
                                              (NVL(TO_NUMBER(lt_diff_tbl_1(i).billed_streams),0) +
                                              NVL(TO_NUMBER(lt_diff_tbl_1(i).cancelled_streams),0) +
                                               NVL(TO_NUMBER(lt_diff_tbl_1(i).unbilled_streams),0));
              IF lt_diff_tbl_1(i).diff_amount <> 0 THEN
                lv_diff_dlts_khr := delimit;
                lv_diff_dlts_khr := lv_diff_dlts_khr||RPAD(SUBSTR(lt_diff_tbl_1(i).contract_number,1,15),15)||RPAD(delimit,1);
                lv_diff_dlts_khr := lv_diff_dlts_khr||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(TO_NUMBER(lt_diff_tbl_1(i).total_billable_streams),0),lv_frm_amt))),1,22),22)||RPAD(delimit,1);
                lv_diff_dlts_khr := lv_diff_dlts_khr||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(TO_NUMBER(lt_diff_tbl_1(i).billed_streams),0),lv_frm_amt))),1,22),22)||RPAD(delimit,1);
                lv_diff_dlts_khr := lv_diff_dlts_khr||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(TO_NUMBER(lt_diff_tbl_1(i).cancelled_streams),0),lv_frm_amt))),1,22),22)||RPAD(delimit,1);
                lv_diff_dlts_khr := lv_diff_dlts_khr||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(TO_NUMBER(lt_diff_tbl_1(i).unbilled_streams),0),lv_frm_amt))),1,22),22)||RPAD(delimit,1);
                lv_diff_dlts_khr := lv_diff_dlts_khr||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(lt_diff_tbl_1(i).diff_amount,0),lv_frm_amt))),1,22),22)||RPAD(delimit,1);
                fnd_file.puT_line(fnd_file.output,lv_diff_dlts_khr);
                ln_diff_dlts_amt := ln_diff_dlts_amt + lt_diff_tbl_1(i).diff_amount;
              END IF;
            END IF;
          END LOOP;
          lv_diff_dlts_amt := RPAD(delimit,112)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_TOTAL'),1,7)||delimit;
          lv_diff_dlts_amt := lv_diff_dlts_amt||LPAD(SUBSTR(LTRIM(RTRIM(TO_CHAR(NVL(ln_diff_dlts_amt,0),lv_frm_amt))),1,13),13);
          fnd_file.put_line(fnd_file.output,RPAD(delimit,118)||RPAD(lv_dash,13,lv_dash));
          fnd_file.put_line(fnd_file.output,lv_diff_dlts_amt);
          fnd_file.put_line(fnd_file.output,RPAD(delimit,118)||RPAD(lv_dash,13,lv_dash));
        ELSIF NVL(lv_value_dif,'N') = 'N' THEN
          fnd_file.put_line(fnd_file.output,RPAD(delimit,12)||SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_NO_RECORDS'),1,21));
        END IF;
      END LOOP;
    END IF;
    fnd_file.put_line(fnd_file.output,delimit);
    fnd_file.put_line(fnd_file.output,delimit);
    fnd_file.put_line(fnd_file.output,'Copyright (c) 1979, Oracle Corporation. All rights reserved.');
    okl_api.end_activity(l_msg_count, l_msg_data);
    fnd_file.put_line(fnd_file.log,SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_END_ACTIVITY'),1,32));
    p_retcode := 0;
  EXCEPTION
    WHEN okl_api.g_exception_error THEN
      p_retcode := 2;
      IF get_org_id%ISOPEN THEN
        CLOSE get_org_id;
      END IF;
      IF get_currency_code%ISOPEN THEN
        CLOSE get_currency_code;
      END IF;
      IF get_total_csr%ISOPEN THEN
        CLOSE get_total_csr;
      END IF;
      IF get_billed_csr%ISOPEN THEN
        CLOSE get_billed_csr;
      END IF;
      IF get_cancel_csr%ISOPEN THEN
        CLOSE get_cancel_csr;
      END IF;
      IF get_clobal_csr%ISOPEN THEN
        CLOSE get_clobal_csr;
      END IF;
      IF get_dlts_clobal_csr%ISOPEN THEN
        CLOSE get_dlts_clobal_csr;
      END IF;
      IF get_diff_csr%ISOPEN THEN
        CLOSE get_diff_csr;
      END IF;
      x_return_status := okl_api.handle_exceptions(
                                 l_api_name,
                                 g_pkg_name,
                                 'okl_api.g_ret_sts_error',
                                 l_msg_count,
                                 l_msg_data,
                                 '_PVT');
      -- print the error message in the log file
      okl_accounting_util.get_error_message(l_error_msg_rec);
      IF (l_error_msg_rec.COUNT > 0) THEN
        FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
          fnd_file.put_line(fnd_file.output, l_error_msg_rec(i));
        END LOOP;
      END IF;
    WHEN okl_api.g_exception_unexpected_error THEN
      IF get_org_id%ISOPEN THEN
        CLOSE get_org_id;
      END IF;
      IF get_currency_code%ISOPEN THEN
        CLOSE get_currency_code;
      END IF;
      IF get_total_csr%ISOPEN THEN
        CLOSE get_total_csr;
      END IF;
      IF get_billed_csr%ISOPEN THEN
        CLOSE get_billed_csr;
      END IF;
      IF get_cancel_csr%ISOPEN THEN
        CLOSE get_cancel_csr;
      END IF;
      IF get_clobal_csr%ISOPEN THEN
        CLOSE get_clobal_csr;
      END IF;
      IF get_dlts_clobal_csr%ISOPEN THEN
        CLOSE get_dlts_clobal_csr;
      END IF;

      IF get_diff_csr%ISOPEN THEN
        CLOSE get_diff_csr;
      END IF;
      x_return_status := okl_api.handle_exceptions(
                                 l_api_name,
                                 g_pkg_name,
                                 'okl_api.g_ret_sts_unexp_error',
                                 l_msg_count,
                                 l_msg_data,
                                 '_PVT');
      -- print the error message in the log file
      okl_accounting_util.get_error_message(l_error_msg_rec);
      IF (l_error_msg_rec.COUNT > 0) THEN
        FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
           fnd_file.put_line(fnd_file.output, l_error_msg_rec(i));
        END LOOP;
      END IF;
    WHEN OTHERS THEN
       p_errbuf := SQLERRM;
       p_retcode := 2;
      IF get_org_id%ISOPEN THEN
        CLOSE get_org_id;
      END IF;
      IF get_currency_code%ISOPEN THEN
        CLOSE get_currency_code;
      END IF;
      IF get_total_csr%ISOPEN THEN
        CLOSE get_total_csr;
      END IF;
      IF get_billed_csr%ISOPEN THEN
        CLOSE get_billed_csr;
      END IF;
      IF get_cancel_csr%ISOPEN THEN
        CLOSE get_cancel_csr;
      END IF;
      IF get_clobal_csr%ISOPEN THEN
        CLOSE get_clobal_csr;
      END IF;
      IF get_dlts_clobal_csr%ISOPEN THEN
        CLOSE get_dlts_clobal_csr;
      END IF;
      IF get_diff_csr%ISOPEN THEN
        CLOSE get_diff_csr;
      END IF;
      x_return_status := okl_api.handle_exceptions(
                                 l_api_name,
                                 g_pkg_name,
                                 'OTHERS',
                                 l_msg_count,
                                 l_msg_data,
                                 '_PVT');
      -- print the error message in the log file
      okl_accounting_util.get_error_message(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
          FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
            fnd_file.put_line(fnd_file.output, l_error_msg_rec(i));
          END LOOP;
        END IF;
      fnd_file.put_line(fnd_file.log, SQLERRM);
  END recon_qry;

  -------------------------------------------------------------------------------
  -- Function xml_recon_qry
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : xml_recon_qry
  -- Description     : Function for Billable Streams reconciliation Report Generation
  --                   in XML Publisher
  -- Business Rules  :
  -- Parameters      : p_contract_number, p_end_date
  -- Version         : 1.0
  -- History         : 03-Jan-2007 UDHENUKO created.
  -- End of comments
  -------------------------------------------------------------------------------
FUNCTION xml_recon_qry RETURN BOOLEAN
  IS
    p_errbuf			          VARCHAR2(1000) := NULL;
    p_retcode			          NUMBER;
    l_api_name                   CONSTANT VARCHAR2(40):= 'OKL_STREAMS_RECON_REPORT';
    l_api_version                CONSTANT NUMBER      := 1.0;
    p_api_version                CONSTANT NUMBER      := 1.0;
    l_init_msg_list              VARCHAR2(3) := okl_api.g_true;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
    x_return_status              VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    lp_end_date                  VARCHAR2(200);
    lp_contract_number           VARCHAR2(200);
    ln_org_id                    okc_k_headers_b.authoring_org_id%TYPE := 0;
    lv_org_name                  mtl_organizations.organization_name%TYPE := NULL;
    lv_sum_curr_code             VARCHAR2(2000);
    lv_curr_code                 VARCHAR2(20) := 'XXX';
    lv_clb_display               VARCHAR2(3) := 'N';
    lv_dif_display               VARCHAR2(3) := 'N';
    lv_curr_dif_code             VARCHAR2(20) := 'XXX';
    lv_dlts_curr_code            VARCHAR2(20) := 'XXX';
    lv_book_class                VARCHAR2(100) := 'XXX';
    lv_contract_number           VARCHAR2(150) := 'XXXXXXXXXX';
    lv_dlt_curr_code             VARCHAR2(2000);
    lv_tot_amt                   VARCHAR2(2000);
    lv_diff_dlts                 VARCHAR2(2000);
    lv_diff_dlts_dash            VARCHAR2(2000);
    lv_diff_dlts_khr             VARCHAR2(2000);
    lv_dlt_book                  VARCHAR2(2000);
    lv_dlt_pdt                   VARCHAR2(2000);
    lv_bil_amt                   VARCHAR2(2000);
    lv_can_amt                   VARCHAR2(2000);
    lv_clb_amt                   VARCHAR2(2000);
    lv_dif_amt                   VARCHAR2(2000);
    lv_dif_amt1                  VARCHAR2(2000);
    lv_dif_amt2                  VARCHAR2(2000);
    lv_dlt_tot_amt               VARCHAR2(2000);
    lv_dlt_amt                   VARCHAR2(2000);
    lv_diff_dlts_amt             VARCHAR2(2000);
    lv_sum_bil_dash              VARCHAR2(2000);
    lv_sum_can_dash              VARCHAR2(2000);
    lv_sum_clb_dash              VARCHAR2(2000);
    lv_value_clb                 VARCHAR2(3) := 'N';
    lv_value_dif                 VARCHAR2(3) := 'N';
    lv_sum_dif_dash              VARCHAR2(2000);
    lv_end_date                  DATE;
    delimit                      VARCHAR2(10) := ' ';
    lv_dash                      VARCHAR2(10) := '-';
    lv_frm_amt                   VARCHAR2(30) := '999,999,999,990.00';
    i                            NUMBER := 0;
    c                            NUMBER := 0;
    k                            NUMBER := 0;
    h                            NUMBER := 0;
    m                            NUMBER := 0;
    a                            NUMBER := 0;
    ln_tot_curr_amt              NUMBER := 0;
    ln_bil_curr_amt              NUMBER := 0;
    ln_can_curr_amt              NUMBER := 0;
    ln_clb_curr_amt              NUMBER := 0;
    ln_dif_curr_amt              NUMBER := 0;
    ln_tot_amt                   NUMBER := 0;
    ln_bil_amt                   NUMBER := 0;
    ln_can_amt                   NUMBER := 0;
    ln_clb_amt                   NUMBER := 0;
    ln_cnt_tot                   NUMBER := 0;
    ln_cnt_bil                   NUMBER := 0;
    ln_cnt_can                   NUMBER := 0;
    ln_cnt_clb                   NUMBER := 0;
    ln_dif_amt                   NUMBER := 0;
    ln_dlt_tot_amt               NUMBER := 0;
    ln_diff_dlts_amt             NUMBER := 0;
    ln_dlt_amt                   NUMBER := 0;
    ln_dif_amt1                  NUMBER := 0;
    ln_dif_amt2                  NUMBER := 0;
    smry_cnt                     NUMBER := 0;
    ubil_cnt                     NUMBER := 0;
    diff_cnt                     NUMBER := 0;
    TYPE unbill_rec_type IS RECORD (
         book_class      VARCHAR2(2000) := NULL,
         currency_code   VARCHAR2(2000) := NULL,
         product_name    VARCHAR2(2000) := NULL,
         amount          NUMBER := 0);
    TYPE value_rec_type IS RECORD (
         clb_amt            NUMBER := 0,
         dif_amt            NUMBER := 0,
         curr_code          okc_k_headers_b.currency_code%TYPE := NULL);
    TYPE diff_rec_type IS RECORD (
         contract_number         okc_k_headers_b.contract_number%TYPE := NULL,
         currency_code           okc_k_headers_b.currency_code%TYPE := NULL,
         total_billable_streams  VARCHAR2(2000) := NULL,
         billed_streams          VARCHAR2(2000) := NULL,
         cancelled_streams       VARCHAR2(2000) := NULL,
         unbilled_streams        VARCHAR2(2000) := NULL,
         amount                  NUMBER := 0,
         diff_amount             NUMBER := 0);
    TYPE gt_unbill_rec_type IS RECORD (
         book_class      VARCHAR2(2000) := NULL,
         currency_code   VARCHAR2(2000) := NULL,
         product_name    VARCHAR2(2000) := NULL,
         amount          NUMBER := 0);
    TYPE gt_diff_rec_type IS RECORD (
         contract_number         okc_k_headers_b.contract_number%TYPE := NULL,
         currency_code           okc_k_headers_b.currency_code%TYPE := NULL,
         total_billable_streams  NUMBER := 0,
         billed_streams          NUMBER := 0,
         cancelled_streams       NUMBER := 0,
         unbilled_streams        NUMBER := 0,
         diff_amount             NUMBER := 0);
    TYPE bill_smry_rec_type IS RECORD (
         currency_code      VARCHAR2(2000) := NULL,
         total_strm         VARCHAR2(2000) := NULL,
         bill_total_strm    VARCHAR2(2000) := NULL,
         diff1_total_strm   VARCHAR2(2000) := NULL,
         cancel_total_strm  VARCHAR2(2000) := NULL,
         diff2_total_strm   VARCHAR2(2000) := NULL,
         clobal_total_strm  VARCHAR2(2000) := NULL,
         main_diff_total    VARCHAR2(2000) := NULL);
    TYPE unbill_tbl_type IS TABLE OF unbill_rec_type
          INDEX BY BINARY_INTEGER;
    TYPE value_tbl_type IS TABLE of value_rec_type
          INDEX BY BINARY_INTEGER;
    TYPE curr_tbl_type IS TABLE OF okc_k_headers_b.currency_code%TYPE
          INDEX BY BINARY_INTEGER;
    TYPE book_tbl_type IS TABLE OF VARCHAR2(2000)
          INDEX BY BINARY_INTEGER;
    TYPE diff_tbl_type IS TABLE OF diff_rec_type
          INDEX BY BINARY_INTEGER;
    TYPE gt_unbill_tbl_type IS TABLE OF gt_unbill_rec_type
          INDEX BY BINARY_INTEGER;
    TYPE gt_diff_tbl_type IS TABLE OF gt_diff_rec_type
          INDEX BY BINARY_INTEGER;
    TYPE bill_smry_tbl_type IS TABLE OF bill_smry_rec_type
          INDEX BY BINARY_INTEGER;

    lt_unbill_tbl          unbill_tbl_type;
    lt_unbill_gt_tbl       gt_unbill_tbl_type;
    lt_value_tbl           value_tbl_type;
    lt_diff_tbl            diff_tbl_type;
    lt_diff_tbl_1          diff_tbl_type;
    lt_diff_gt_tbl         gt_diff_tbl_type;
    lt_curr_tbl            curr_tbl_type;
    lt_curr_tbl_1          curr_tbl_type;
    lt_book_tbl            book_tbl_type;
    lt_bill_smry_gt_tbl    bill_smry_tbl_type;
    l_error_msg_rec        error_message_type;
    -- To get authoring org id
    CURSOR get_org_id
    IS
    SELECT name,
           organization_id
    FROM hr_operating_units
    WHERE ORGANIZATION_ID=MO_GLOBAL.GET_CURRENT_ORG_ID; --MOAC- Concurrent request

    -- To get different currency code in the system
    CURSOR get_currency_code(p_org_id          IN okc_k_headers_b.authoring_org_id%TYPE,
                             p_contract_number IN okc_k_headers_b.contract_number%TYPE,
                             p_end_date        IN okc_k_headers_b.end_date%TYPE)
    IS
    SELECT DISTINCT chrb.currency_code
    FROM okl_strm_elements ele,
         okl_streams stm,
         okl_strm_type_b sty,
         okl_k_headers khr,
         okc_k_headers_b chrb,
         okc_k_lines_b kle,
         okc_statuses_b khs,
         okc_statuses_b kls
    WHERE chrb.contract_number = NVL(p_contract_number,chrb.contract_number)
    AND chrb.end_date <= NVL(p_end_date,chrb.end_date)
    AND chrb.authoring_org_id = p_org_id
    AND chrb.id = stm.khr_id
    AND chrb.scs_code IN ('LEASE', 'LOAN')
    AND chrb.sts_code IN ( 'BOOKED','EVERGREEN')
    AND chrb.id = khr.id
    AND khr.deal_type  IS NOT NULL
    AND khs.code = chrb.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND stm.sty_id = sty.id
    AND stm.id = ele.stm_id
    AND sty.billable_yn = 'Y'
    AND stm.say_code <> 'WORK'
    AND stm.purpose_code IS NULL
    ORDER BY chrb.currency_code DESC;
    -- To get total streams total
    CURSOR get_total_csr(p_org_id          IN okc_k_headers_b.authoring_org_id%TYPE,
                         p_curr_code       IN okc_k_headers_b.currency_code%TYPE,
                         p_contract_number IN okc_k_headers_b.contract_number%TYPE,
                         p_end_date        IN okc_k_headers_b.end_date%TYPE)
    IS
    SELECT SUM(ele.amount) amount
    FROM okl_strm_elements ele,
         okl_streams stm,
         okl_strm_type_b sty,
         okl_k_headers khr,
         okc_k_headers_b chrb,
         okc_k_lines_b kle,
         okc_statuses_b khs,
         okc_statuses_b kls
    WHERE chrb.contract_number = NVL(p_contract_number,chrb.contract_number)
    AND chrb.end_date <= NVL(p_end_date,chrb.end_date)
    AND chrb.authoring_org_id = p_org_id
    AND chrb.currency_code = p_curr_code
    AND chrb.id = stm.khr_id
    AND chrb.scs_code IN ('LEASE', 'LOAN')
    AND chrb.sts_code IN ( 'BOOKED','EVERGREEN')
    AND chrb.id = khr.id
    AND khr.deal_type  IS NOT NULL
    AND khs.code = chrb.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND stm.sty_id = sty.id
    AND stm.id = ele.stm_id
    AND sty.billable_yn = 'Y'
    AND stm.say_code <> 'WORK'
    AND stm.purpose_code IS NULL;
    -- To get billed streams total
    CURSOR get_billed_csr(p_org_id          IN okc_k_headers_b.authoring_org_id%TYPE,
                          p_curr_code       IN okc_k_headers_b.currency_code%TYPE,
                          p_contract_number IN okc_k_headers_b.contract_number%TYPE,
                          p_end_date        IN okc_k_headers_b.end_date%TYPE)
    IS
    SELECT SUM(ste.amount) amount
    FROM okl_strm_type_v sty,
         okl_strm_elements ste,
         okl_streams stm,
         okc_statuses_b khs,
         okc_statuses_b kls,
         okl_k_headers khl,
         okc_k_lines_b kle,
         okc_k_headers_b khr
    WHERE khr.contract_number = NVL(p_contract_number,khr.contract_number)
    AND khr.end_date <= NVL(p_end_date,khr.end_date)
    AND khr.authoring_org_id = p_org_id
    AND khr.currency_code = p_curr_code
    AND khr.id = stm.khr_id
    AND khr.scs_code IN ('LEASE', 'LOAN')
    AND khr.sts_code IN ( 'BOOKED','EVERGREEN')
    AND khl.id = stm.khr_id
    AND khl.deal_type  IS NOT NULL
    AND khs.code = khr.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND ste.amount <> 0
    AND stm.id = ste.stm_id
    AND ste.date_billed  IS NOT NULL
    AND stm.say_code IN  ('CURR','HIST')
    AND sty.id = stm.sty_id
    AND sty.billable_yn  = 'Y';
    -- To get cancelled streams total
    CURSOR get_cancel_csr(p_org_id          IN okc_k_headers_b.authoring_org_id%TYPE,
                          p_curr_code       IN okc_k_headers_b.currency_code%TYPE,

                          p_contract_number IN okc_k_headers_b.contract_number%TYPE,
                          p_end_date        IN okc_k_headers_b.end_date%TYPE)
    IS
    SELECT SUM(ste.amount) amount
    FROM okl_strm_type_v sty,
         okl_strm_elements ste,
         okl_streams stm,
         okc_statuses_b khs,
         okc_statuses_b kls,
         okl_k_headers khl,
         okc_k_lines_b kle,
         okc_k_headers_b khr
    WHERE khr.contract_number = NVL(p_contract_number,khr.contract_number)
    AND khr.end_date <= NVL(p_end_date,khr.end_date)
    AND khr.authoring_org_id = p_org_id
    AND khr.currency_code = p_curr_code
    AND khr.id = stm.khr_id
    AND khr.scs_code IN ('LEASE', 'LOAN')
    AND khr.sts_code IN ( 'BOOKED','EVERGREEN')
    AND khl.id = stm.khr_id
    AND khl.deal_type  IS NOT NULL
    AND khs.code = khr.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND ste.amount <> 0
    AND stm.id = ste.stm_id
    AND ste.date_billed  IS NULL
    AND stm.active_yn = 'N'
    AND stm.say_code IN ('HIST')
    AND stm.purpose_code IS NULL
    AND sty.id = stm.sty_id
    AND sty.billable_yn  = 'Y';
    -- To get Closing balance streams total
    CURSOR get_clobal_csr(p_org_id          IN okc_k_headers_b.authoring_org_id%TYPE,
                          p_curr_code       IN okc_k_headers_b.currency_code%TYPE,
                          p_contract_number IN okc_k_headers_b.contract_number%TYPE,
                          p_end_date        IN okc_k_headers_b.end_date%TYPE)
    IS
    SELECT SUM(ste.amount) amount
    FROM okl_strm_type_v sty,
         okl_strm_elements ste,
         okl_streams stm,
         okc_statuses_b khs,
         okc_statuses_b kls,
         okl_k_headers khl,
         okc_k_lines_b kle,
         okc_k_headers_b khr
    WHERE khr.contract_number = NVL(p_contract_number,khr.contract_number)
    AND khr.end_date <= NVL(p_end_date,khr.end_date)
    AND khr.authoring_org_id = p_org_id
    AND khr.currency_code  = p_curr_code
    AND khr.id = stm.khr_id
    AND khr.scs_code IN ('LEASE', 'LOAN')
    AND khr.sts_code IN ( 'BOOKED','EVERGREEN')
    AND khl.id = stm.khr_id
    AND khl.deal_type  IS NOT NULL
    AND khs.code = khr.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND stm.khr_id = khr.id
    AND stm.id = ste.stm_id
    AND ste.amount <> 0
    AND ste.date_billed  IS NULL
    AND stm.active_yn = 'Y'
    AND stm.say_code = 'CURR'
    AND stm.purpose_code IS NULL
    AND sty.id = stm.sty_id
    AND sty.billable_yn  = 'Y';
    -- To get details of Closing balance based on the deal type and
    -- Product associated to the same
    CURSOR get_dlts_clobal_csr(p_org_id          IN okc_k_headers_b.authoring_org_id%TYPE,
                               p_contract_number IN okc_k_headers_b.contract_number%TYPE,
                               p_end_date        IN okc_k_headers_b.end_date%TYPE)
    IS
    SELECT khr.currency_code currency_code,
           fnd.meaning book_class,
           pdt.name product_name,
           SUM(ste.amount) amount
    FROM okl_strm_type_v sty,
         okl_strm_elements ste,
         okl_streams stm,
         okc_statuses_b khs,
         okc_statuses_b kls,
         okl_products pdt,
         fnd_lookup_values fnd,
         okl_k_headers khl,
         okc_k_lines_b kle,
         okc_k_headers_b khr
    WHERE khr.contract_number = NVL(p_contract_number,khr.contract_number)
    AND khr.end_date <= NVL(p_end_date,khr.end_date)
    AND khr.authoring_org_id = p_org_id
    AND khr.id = stm.khr_id
    AND khr.scs_code IN ('LEASE', 'LOAN')
    AND khr.sts_code IN ( 'BOOKED','EVERGREEN')
    AND khl.id = stm.khr_id
    AND khl.deal_type  IS NOT NULL
    AND khs.code = khr.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND stm.khr_id = khr.id
    AND stm.id = ste.stm_id
    AND ste.amount <> 0
    AND ste.date_billed  IS NULL
    AND stm.active_yn = 'Y'
    AND stm.say_code = 'CURR'
    AND stm.purpose_code IS NULL
    AND sty.id = stm.sty_id
    AND sty.billable_yn  = 'Y'
    AND fnd.lookup_code = khl.deal_type
    AND fnd.lookup_type = 'OKL_BOOK_CLASS'
    AND fnd.LANGUAGE = USERENV('LANG')
    AND khl.pdt_id = pdt.id(+)
    GROUP BY khr.currency_code,
             fnd.meaning,
             pdt.name
    ORDER BY 1 DESC ;
    -- To get Difference contracts streams
    CURSOR get_diff_csr(p_org_id          IN okc_k_headers_b.authoring_org_id%TYPE,
                        p_contract_number IN okc_k_headers_b.contract_number%TYPE,
                        p_end_date        IN okc_k_headers_b.end_date%TYPE)
    IS
    SELECT chrb.currency_code currency_code,
           chrb.contract_number contract_number,
           'Y' total_billable_streams,
           'N' billed_streams,
           'N' cancelled_streams,
           'N' unbilled_streams,
           SUM(ele.amount) amount
    FROM okl_strm_elements ele,
         okl_streams stm,
         okl_strm_type_b sty,
         okl_k_headers khr,
         okc_k_headers_b chrb,
         okc_k_lines_b kle,
         okc_statuses_b khs,
         okc_statuses_b kls
    WHERE chrb.contract_number = NVL(p_contract_number,chrb.contract_number)
    AND chrb.end_date <= NVL(p_end_date,chrb.end_date)
    AND chrb.authoring_org_id = p_org_id
    AND chrb.id = stm.khr_id
    AND chrb.scs_code IN ('LEASE', 'LOAN')
    AND chrb.sts_code IN ( 'BOOKED','EVERGREEN')
    AND chrb.id = khr.id
    AND khr.deal_type  IS NOT NULL
    AND khs.code = chrb.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND stm.sty_id = sty.id
    AND stm.id = ele.stm_id
    AND sty.billable_yn = 'Y'
    AND stm.say_code <> 'WORK'
    AND stm.purpose_code IS NULL
    GROUP BY chrb.contract_number,
             chrb.currency_code
    UNION
    SELECT khr.currency_code currency_code,
           khr.contract_number contract_number,
           'N' total_billable_streams,
           'Y' billed_streams,
           'N' cancelled_streams,
           'N' unbilled_streams,
           SUM(ste.amount) billed_streams
    FROM okl_strm_type_v sty,
         okl_strm_elements ste,
         okl_streams stm,
         okc_statuses_b khs,
         okc_statuses_b kls,
         okl_k_headers khl,
         okc_k_lines_b kle,
         okc_k_headers_b khr
    WHERE khr.contract_number = NVL(p_contract_number,khr.contract_number)
    AND khr.end_date <= NVL(p_end_date,khr.end_date)
    AND khr.authoring_org_id = p_org_id
    AND khr.id = stm.khr_id
    AND khr.scs_code IN ('LEASE', 'LOAN')
    AND khr.sts_code IN ( 'BOOKED','EVERGREEN')
    AND khl.id = stm.khr_id
    AND khl.deal_type  IS NOT NULL
    AND khs.code = khr.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND ste.amount <> 0
    AND stm.id = ste.stm_id
    AND ste.date_billed  IS NOT NULL
    AND stm.say_code IN  ('CURR','HIST')
    AND sty.id = stm.sty_id
    AND sty.billable_yn  = 'Y'
    GROUP BY khr.contract_number,
             khr.currency_code
    UNION
    SELECT khr.currency_code currency_code,
           khr.contract_number contract_number,
           'N' total_billable_streams,
           'N' billed_streams,
           'Y' cancelled_streams,
           'N' unbilled_streams,
           SUM(ste.amount)
    FROM okl_strm_type_v sty,
         okl_strm_elements ste,
         okl_streams stm,
         okc_statuses_b khs,
         okc_statuses_b kls,
         okl_k_headers khl,
         okc_k_lines_b kle,
         okc_k_headers_b khr
    WHERE khr.contract_number = NVL(p_contract_number,khr.contract_number)
    AND khr.end_date <= NVL(p_end_date,khr.end_date)
    AND khr.authoring_org_id = p_org_id
    AND khr.id = stm.khr_id
    AND khr.scs_code IN ('LEASE', 'LOAN')
    AND khr.sts_code IN ( 'BOOKED','EVERGREEN')
    AND khl.id = stm.khr_id
    AND khl.deal_type  IS NOT NULL
    AND khs.code = khr.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND ste.amount <> 0
    AND stm.id = ste.stm_id
    AND ste.date_billed  IS NULL
    AND stm.active_yn = 'N'
    AND stm.say_code IN ('HIST')
    AND stm.purpose_code IS NULL
    AND sty.id = stm.sty_id
    AND sty.billable_yn  = 'Y'
    GROUP BY khr.contract_number,
             khr.currency_code
    UNION
    SELECT khr.currency_code currency_code,
           khr.contract_number contract_number,
           'N' total_billable_streams,
           'N' billed_streams,
           'N' cancelled_streams,
           'Y' unbilled_streams,
           SUM(ste.amount)
    FROM okl_strm_type_v sty,
         okl_strm_elements ste,
         okl_streams stm,
         okc_statuses_b khs,
         okc_statuses_b kls,
         okl_k_headers khl,
         okc_k_lines_b kle,
         okc_k_headers_b khr
    WHERE khr.contract_number = NVL(p_contract_number,khr.contract_number)
    AND khr.end_date <= NVL(p_end_date,khr.end_date)
    AND khr.authoring_org_id = p_org_id
    AND khr.id = stm.khr_id
    AND khr.scs_code IN ('LEASE', 'LOAN')
    AND khr.sts_code IN ( 'BOOKED','EVERGREEN')
    AND khl.id = stm.khr_id
    AND khl.deal_type  IS NOT NULL
    AND khs.code = khr.sts_code
    AND khs.ste_code = 'ACTIVE'
    AND kle.id(+) = stm.kle_id
    AND kls.code(+) = kle.sts_code
    AND stm.khr_id = khr.id
    AND stm.id = ste.stm_id
    AND ste.amount <> 0
    AND ste.date_billed  IS NULL
    AND stm.active_yn = 'Y'
    AND stm.say_code = 'CURR'
    AND stm.purpose_code IS NULL
    AND sty.id = stm.sty_id
    AND sty.billable_yn  = 'Y'
    GROUP BY khr.contract_number,
             khr.currency_code
    ORDER BY 1 DESC;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    p_retcode := 0;
    x_return_status := okl_api.start_activity(
                               l_api_name,
                               G_PKG_NAME,
                               l_init_msg_list,
                               l_api_version,
                               p_api_version,
                               '_PVT',
                               x_return_status);
    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      fnd_file.put_line(fnd_file.log,SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_ERROR_ACTIVITY'),1,30));
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_Status = okl_api.g_ret_sts_error) THEN
      fnd_file.put_line(fnd_file.log,SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_ERROR_ACTIVITY'),1,30));
      RAISE okl_api.g_exception_error;
    END IF;
    fnd_file.put_line(fnd_file.log,SUBSTR(okl_accounting_util.get_message_token('OKL_LP_CONCURRENT_PROCESS','OKL_START_ACTIVITY'),1,34));
    fnd_file.put_line(fnd_file.log,delimit);
    -- we need to convert the date from varchar2 to date format
    -- Since the parametr we use in the concurrent program is fnd_standard_date
    IF P_END_DATE IS NOT NULL THEN
      lv_end_date := fnd_date.canonical_to_date(P_END_DATE);
    END IF;
    -- To get authoring org id
    OPEN get_org_id;
    FETCH get_org_id INTO lv_org_name,
                          ln_org_id;
    CLOSE get_org_id;
    FOR get_currency_code_rec IN get_currency_code(p_org_id          => ln_org_id,
                                                   p_contract_number => P_CONTRACT_NUMBER,
                                                   p_end_date        => lv_end_date) LOOP
      lt_bill_smry_gt_tbl(smry_cnt).currency_code := get_currency_code_rec.currency_code;
      -- To get total streams total
      OPEN  get_total_csr(p_org_id          => ln_org_id,
                          p_curr_code       => get_currency_code_rec.currency_code,
                          p_contract_number => P_CONTRACT_NUMBER,
                          p_end_date        => lv_end_date);
      FETCH get_total_csr INTO ln_tot_curr_amt;
      IF get_total_csr%NOTFOUND THEN
        ln_tot_curr_amt := 0;
      END IF;
      CLOSE get_total_csr;
      -- To get billed streams total
      OPEN  get_billed_csr(p_org_id          => ln_org_id,
                           p_curr_code       => get_currency_code_rec.currency_code,
                           p_contract_number => P_CONTRACT_NUMBER,
                           p_end_date        => lv_end_date);
      FETCH get_billed_csr INTO ln_bil_curr_amt;
      IF get_billed_csr%NOTFOUND THEN
        ln_bil_curr_amt := 0;
      END IF;
      CLOSE get_billed_csr;
      lt_bill_smry_gt_tbl(smry_cnt).total_strm := okl_accounting_util.format_amount(NVL(ln_tot_curr_amt,0),lt_bill_smry_gt_tbl(smry_cnt).currency_code);
      lt_bill_smry_gt_tbl(smry_cnt).bill_total_strm := okl_accounting_util.format_amount(NVL(ln_bil_curr_amt,0),lt_bill_smry_gt_tbl(smry_cnt).currency_code);
      -- To get differnece in the stream amount
      -- to show the difference of Total billable streams and billed streams we do the below
      ln_dif_amt1  := ln_tot_curr_amt - ln_bil_curr_amt;
      lt_bill_smry_gt_tbl(smry_cnt).diff1_total_strm := okl_accounting_util.format_amount(NVL(ln_dif_amt1,0),lt_bill_smry_gt_tbl(smry_cnt).currency_code);
      -- To get cancelled streams total
      OPEN  get_cancel_csr(p_org_id          => ln_org_id,
                           p_curr_code       => get_currency_code_rec.currency_code,
                           p_contract_number => P_CONTRACT_NUMBER,
                           p_end_date        => lv_end_date);
      FETCH get_cancel_csr INTO ln_can_curr_amt;
      IF get_cancel_csr%NOTFOUND THEN
        ln_can_curr_amt := 0;
      END IF;
      CLOSE get_cancel_csr;
      lt_bill_smry_gt_tbl(smry_cnt).cancel_total_strm := okl_accounting_util.format_amount(NVL(ln_can_curr_amt,0),lt_bill_smry_gt_tbl(smry_cnt).currency_code);
      -- to show the difference of 1 difference amount and the cancelled amounts
      ln_dif_amt2  := ln_dif_amt1 - ln_can_curr_amt;
      lt_bill_smry_gt_tbl(smry_cnt).diff2_total_strm := okl_accounting_util.format_amount(NVL(ln_dif_amt2,0),lt_bill_smry_gt_tbl(smry_cnt).currency_code);
      -- To get Closing balance streams total
      OPEN  get_clobal_csr(p_org_id           => ln_org_id,
                           p_curr_code       => get_currency_code_rec.currency_code,
                           p_contract_number => P_CONTRACT_NUMBER,
                           p_end_date        => lv_end_date);
      FETCH get_clobal_csr INTO ln_clb_curr_amt;
      IF get_clobal_csr%NOTFOUND THEN
        ln_clb_curr_amt := 0;
      END IF;
      CLOSE get_clobal_csr;
      -- To let know the further process that
      -- there was value for un billed streams
      IF ln_clb_curr_amt <> 0 THEN
        lt_value_tbl(a).clb_amt := ln_clb_curr_amt;
      END IF;
      lt_bill_smry_gt_tbl(smry_cnt).clobal_total_strm := okl_accounting_util.format_amount(NVL(ln_clb_curr_amt,0),lt_bill_smry_gt_tbl(smry_cnt).currency_code);
      -- To get differnece in the stream amount
      -- the components of these are the total Billable streasm less billed streams
      -- To get differnece in the stream amount
      -- less cancelled streams and less unbilled streams
      -- To get differnece in the stream amount
      ln_dif_amt   := NVL(ln_tot_curr_amt,0) - NVL(ln_bil_curr_amt,0) - NVL(ln_can_curr_amt,0) - NVL(ln_clb_curr_amt,0);
      -- To let know the further process that
      -- there was value for Difference streams
      IF ln_dif_amt <> 0 THEN
        lt_value_tbl(a).dif_amt   := ln_dif_amt;
        lt_value_tbl(a).curr_code := get_currency_code_rec.currency_code;
      ELSIF ln_dif_amt = 0 THEN
        lt_value_tbl(a).dif_amt   := ln_dif_amt;
        lt_value_tbl(a).curr_code := get_currency_code_rec.currency_code;
      END IF;
      lt_bill_smry_gt_tbl(smry_cnt).main_diff_total := okl_accounting_util.format_amount(NVL(ln_dif_amt,0),lt_bill_smry_gt_tbl(smry_cnt).currency_code);
      a := a + 1;
      smry_cnt := smry_cnt+1;
    END LOOP;
    -- Filling in the Details section of the unbilled Streams report file
    IF lt_value_tbl.COUNT > 0 THEN
      FOR i IN lt_value_tbl.FIRST..lt_value_tbl.LAST LOOP
        IF lt_value_tbl(i).clb_amt <> 0 THEN
          lv_value_clb := 'Y';
          EXIT WHEN (lv_value_clb = 'Y');
        ELSIF lt_value_tbl(i).clb_amt = 0 THEN
          lv_value_clb := 'N';
        END IF;
      END LOOP;
    END IF;
    IF lv_value_clb = 'Y' THEN
      -- To get details of Closing balance based on the deal type and
      -- Product associated to the same
      FOR get_dlts_clobal_rec IN get_dlts_clobal_csr(p_org_id          => ln_org_id,
                                                     p_contract_number => P_CONTRACT_NUMBER,
                                                     p_end_date        => lv_end_date) LOOP
        lt_unbill_tbl(i).book_class    := get_dlts_clobal_rec.book_class;
        lt_unbill_tbl(i).currency_code := get_dlts_clobal_rec.currency_code;
        lt_unbill_tbl(i).product_name  := get_dlts_clobal_rec.product_name;
        lt_unbill_tbl(i).amount        := get_dlts_clobal_rec.amount;
        i := i + 1;
      END LOOP;
      i := 0;
      IF lt_unbill_tbl.COUNT > 0 THEN
        FOR j IN lt_unbill_tbl.FIRST..lt_unbill_tbl.LAST LOOP
          IF lv_curr_code <> lt_unbill_tbl(j).currency_code THEN
            lt_curr_tbl(k) := lt_unbill_tbl(j).currency_code;
            lv_curr_code := lt_curr_tbl(k);
            k := k + 1;
          END IF;
        END LOOP;
        FOR m IN lt_curr_tbl.FIRST..lt_curr_tbl.LAST LOOP

          lv_dlt_tot_amt  := NULL;
          lv_dlt_amt  := NULL;
          ln_dlt_tot_amt  := 0;
          ln_dlt_amt  := 0;
          FOR j IN lt_unbill_tbl.FIRST..lt_unbill_tbl.LAST LOOP
            IF lv_book_class <> lt_unbill_tbl(j).book_class AND
               lt_unbill_tbl(j).currency_code = lt_curr_tbl(m) THEN

              lv_book_class := lt_unbill_tbl(j).book_class;
              ln_dlt_amt := 0;
              FOR h IN lt_unbill_tbl.FIRST..lt_unbill_tbl.LAST LOOP
                IF lt_unbill_tbl(j).book_class = lt_unbill_tbl(h).book_class AND
                  lt_unbill_tbl(j).currency_code = lt_curr_tbl(m) THEN

                  lt_unbill_gt_tbl(ubil_cnt).currency_code := lt_curr_tbl(m);
                  lt_unbill_gt_tbl(ubil_cnt).book_class := lt_unbill_tbl(j).book_class;
                  lt_unbill_gt_tbl(ubil_cnt).product_name := substr(lt_unbill_tbl(h).product_name,1,20);
                  lt_unbill_gt_tbl(ubil_cnt).amount := NVL(lt_unbill_tbl(h).amount,0);
                  ln_dlt_amt     := ln_dlt_amt + lt_unbill_tbl(h).amount;
                  ln_dlt_tot_amt := ln_dlt_tot_amt + lt_unbill_tbl(h).amount;
                  ubil_cnt := ubil_cnt + 1;
                END IF;
              END LOOP;
            END IF;
          END LOOP;
        END LOOP;
      END IF;
    END IF;
    FOR get_diff_rec IN  get_diff_csr(p_org_id          => ln_org_id,
                                      p_contract_number => P_CONTRACT_NUMBER,
                                      p_end_date        => lv_end_date) LOOP
      lt_diff_tbl(h).contract_number        :=  get_diff_rec.contract_number;
      lt_diff_tbl(h).currency_code          :=  get_diff_rec.currency_code;
      lt_diff_tbl(h).total_billable_streams :=  get_diff_rec.total_billable_streams;
      lt_diff_tbl(h).billed_streams         :=  get_diff_rec.billed_streams;
      lt_diff_tbl(h).cancelled_streams      :=  get_diff_rec.cancelled_streams;
      lt_diff_tbl(h).unbilled_streams       :=  get_diff_rec.unbilled_streams;
      lt_diff_tbl(h).amount                 :=  get_diff_rec.amount;
      h := h + 1;
    END LOOP;
    IF lt_diff_tbl.COUNT > 0 THEN
      lv_contract_number :=  lt_diff_tbl(lt_diff_tbl.FIRST).contract_number;
      FOR i IN lt_diff_tbl.FIRST..lt_diff_tbl.LAST LOOP
        IF lv_contract_number = lt_diff_tbl(i).contract_number THEN
          lt_diff_tbl_1(m).contract_number := lt_diff_tbl(i).contract_number;
          lt_diff_tbl_1(m).currency_code := lt_diff_tbl(i).currency_code;
          IF lt_diff_tbl(i).total_billable_streams = 'Y' THEN
            lt_diff_tbl_1(m).total_billable_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
          IF lt_diff_tbl(i).billed_streams = 'Y' THEN
            lt_diff_tbl_1(m).billed_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
          IF lt_diff_tbl(i).cancelled_streams = 'Y' THEN
            lt_diff_tbl_1(m).cancelled_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
          IF lt_diff_tbl(i).unbilled_streams = 'Y' THEN
            lt_diff_tbl_1(m).unbilled_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
        ELSIF lv_contract_number <> lt_diff_tbl(i).contract_number THEN
          m := m + 1;
          lv_contract_number := lt_diff_tbl(i).contract_number;
          lt_diff_tbl_1(m).contract_number := lt_diff_tbl(i).contract_number;
          lt_diff_tbl_1(m).currency_code := lt_diff_tbl(i).currency_code;
          IF lt_diff_tbl(i).total_billable_streams = 'Y' THEN
            lt_diff_tbl_1(m).total_billable_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
          IF lt_diff_tbl(i).billed_streams = 'Y' THEN
            lt_diff_tbl_1(m).billed_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
          IF lt_diff_tbl(i).cancelled_streams = 'Y' THEN
            lt_diff_tbl_1(m).cancelled_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
          IF lt_diff_tbl(i).unbilled_streams = 'Y' THEN
            lt_diff_tbl_1(m).unbilled_streams := TO_CHAR(lt_diff_tbl(i).amount);
          END IF;
        END IF;
      END LOOP;
      FOR j IN lt_diff_tbl_1.FIRST..lt_diff_tbl_1.LAST LOOP
        IF lv_curr_dif_code <> lt_diff_tbl_1(j).currency_code THEN
          lt_curr_tbl_1(c) := lt_diff_tbl_1(j).currency_code;
          lv_curr_dif_code := lt_curr_tbl_1(c);
            c := c + 1;
        END IF;
      END LOOP;
      FOR j IN lt_curr_tbl_1.FIRST..lt_curr_tbl_1.LAST LOOP
        ln_diff_dlts_amt := 0;
        lv_diff_dlts_amt := NULL;
        lv_value_dif := NULL;
        IF lt_value_tbl.COUNT > 0 THEN
          FOR i IN lt_value_tbl.FIRST..lt_value_tbl.LAST LOOP
            IF lt_value_tbl(i).dif_amt <> 0 AND
              lt_value_tbl(i).curr_code = lt_curr_tbl_1(j) THEN
              lv_value_dif := 'Y';
              EXIT WHEN (lv_value_dif = 'Y');
            ELSIF lt_value_tbl(i).dif_amt = 0 AND
                  lt_value_tbl(i).curr_code = lt_curr_tbl_1(j) THEN
              lv_value_dif := 'N';
            END IF;
          END LOOP;
        END IF;
        IF lv_value_dif = 'Y' THEN

          FOR i IN lt_diff_tbl_1.FIRST..lt_diff_tbl_1.LAST LOOP
            IF lt_diff_tbl_1(i).currency_code = lt_curr_tbl_1(j) THEN
              lt_diff_tbl_1(i).diff_amount := NVL(TO_NUMBER(lt_diff_tbl_1(i).total_billable_streams),0) -
                                              (NVL(TO_NUMBER(lt_diff_tbl_1(i).billed_streams),0) +
                                              NVL(TO_NUMBER(lt_diff_tbl_1(i).cancelled_streams),0) +
                                               NVL(TO_NUMBER(lt_diff_tbl_1(i).unbilled_streams),0));
              IF lt_diff_tbl_1(i).diff_amount <> 0 THEN
                lt_diff_gt_tbl(diff_cnt).currency_code := lt_curr_tbl_1(j);
                lt_diff_gt_tbl(diff_cnt).contract_number := lt_diff_tbl_1(i).contract_number;
                lt_diff_gt_tbl(diff_cnt).total_billable_streams := NVL(TO_NUMBER(lt_diff_tbl_1(i).total_billable_streams),0);
                lt_diff_gt_tbl(diff_cnt).billed_streams := NVL(TO_NUMBER(lt_diff_tbl_1(i).billed_streams),0);
                lt_diff_gt_tbl(diff_cnt).cancelled_streams := NVL(TO_NUMBER(lt_diff_tbl_1(i).cancelled_streams),0);
                lt_diff_gt_tbl(diff_cnt).unbilled_streams := NVL(TO_NUMBER(lt_diff_tbl_1(i).unbilled_streams),0);
                lt_diff_gt_tbl(diff_cnt).diff_amount := NVL(lt_diff_tbl_1(i).diff_amount,0);
                ln_diff_dlts_amt := ln_diff_dlts_amt + lt_diff_tbl_1(i).diff_amount;
                diff_cnt := diff_cnt + 1;
              END IF;
            END IF;
          END LOOP;
        END IF;
      END LOOP;
    END IF;
    IF lt_bill_smry_gt_tbl.COUNT > 0 THEN --Condition Added by varangan for bug# 5738018
	    FOR i IN lt_bill_smry_gt_tbl.FIRST..lt_bill_smry_gt_tbl.LAST LOOP
		INSERT INTO
		OKL_G_REPORTS_GT(VALUE1_TEXT,
			VALUE2_TEXT,
			VALUE3_TEXT,
			VALUE4_TEXT,
			VALUE5_TEXT,
			VALUE6_TEXT,
			VALUE7_TEXT,
			VALUE8_TEXT,
		VALUE9_TEXT)
		  VALUES
		  ('SUMMARY',
		  lt_bill_smry_gt_tbl(i).currency_code,
		  lt_bill_smry_gt_tbl(i).total_strm,
		  lt_bill_smry_gt_tbl(i).bill_total_strm,
		  lt_bill_smry_gt_tbl(i).diff1_total_strm,
		  lt_bill_smry_gt_tbl(i).cancel_total_strm,
		  lt_bill_smry_gt_tbl(i).diff2_total_strm,
		  lt_bill_smry_gt_tbl(i).clobal_total_strm,
		  lt_bill_smry_gt_tbl(i).main_diff_total
		  );
	    END LOOP;
    END IF;
    IF lt_unbill_gt_tbl.COUNT > 0 THEN -- Condition Added by varangan for bug# 5738018
	    FOR i IN lt_unbill_gt_tbl.FIRST..lt_unbill_gt_tbl.LAST LOOP
		INSERT INTO
		OKL_G_REPORTS_GT(VALUE1_TEXT,
			VALUE2_TEXT,
			VALUE3_TEXT,
			VALUE4_TEXT,
			VALUE5_TEXT,
			VALUE1_NUM)
		  VALUES
		  ('UNBILLED_DTLS',
		  lt_unbill_gt_tbl(i).currency_code,
		  lt_unbill_gt_tbl(i).book_class,
		  lt_unbill_gt_tbl(i).product_name,
		  okl_accounting_util.format_amount(lt_unbill_gt_tbl(i).amount,lt_unbill_gt_tbl(i).currency_code),
		      lt_unbill_gt_tbl(i).amount
		  );
	    END LOOP;
    END IF;
    IF lt_diff_gt_tbl.COUNT > 0 THEN -- Condition Added by varangan for bug# 5738018
	    FOR i IN lt_diff_gt_tbl.FIRST..lt_diff_gt_tbl.LAST LOOP
		INSERT INTO
		OKL_G_REPORTS_GT(VALUE1_TEXT,
			VALUE2_TEXT,
			VALUE3_TEXT,
			VALUE4_TEXT,
			VALUE5_TEXT,
			VALUE6_TEXT,
			VALUE7_TEXT,
			VALUE8_TEXT,
			VALUE1_NUM,
			VALUE2_NUM,
			VALUE3_NUM,
			VALUE4_NUM,
			VALUE5_NUM)
		VALUES
		  ('DIFF_DTLS',
		  lt_diff_gt_tbl(i).currency_code,
		  lt_diff_gt_tbl(i).contract_number,
		      okl_accounting_util.format_amount(lt_diff_gt_tbl(i).total_billable_streams,lt_diff_gt_tbl(i).currency_code),
		      okl_accounting_util.format_amount(lt_diff_gt_tbl(i).billed_streams,lt_diff_gt_tbl(i).currency_code),
		      okl_accounting_util.format_amount(lt_diff_gt_tbl(i).cancelled_streams,lt_diff_gt_tbl(i).currency_code),
		      okl_accounting_util.format_amount(lt_diff_gt_tbl(i).unbilled_streams,lt_diff_gt_tbl(i).currency_code),
		      okl_accounting_util.format_amount(lt_diff_gt_tbl(i).diff_amount,lt_diff_gt_tbl(i).currency_code),
		  lt_diff_gt_tbl(i).total_billable_streams,
		  lt_diff_gt_tbl(i).billed_streams,
		  lt_diff_gt_tbl(i).cancelled_streams,
		  lt_diff_gt_tbl(i).unbilled_streams,
		  lt_diff_gt_tbl(i).diff_amount
		  );
	    END LOOP;
    END IF;
    okl_api.end_activity(l_msg_count, l_msg_data);
    p_retcode := 0;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
       p_errbuf := SQLERRM;
       p_retcode := 2;
      IF get_org_id%ISOPEN THEN
        CLOSE get_org_id;
      END IF;
      IF get_currency_code%ISOPEN THEN
        CLOSE get_currency_code;
      END IF;
      IF get_total_csr%ISOPEN THEN
        CLOSE get_total_csr;
      END IF;
      IF get_billed_csr%ISOPEN THEN
        CLOSE get_billed_csr;
      END IF;
      IF get_cancel_csr%ISOPEN THEN
        CLOSE get_cancel_csr;
      END IF;
      IF get_clobal_csr%ISOPEN THEN
        CLOSE get_clobal_csr;
      END IF;
      IF get_dlts_clobal_csr%ISOPEN THEN
        CLOSE get_dlts_clobal_csr;
      END IF;
      IF get_diff_csr%ISOPEN THEN
        CLOSE get_diff_csr;
      END IF;
      x_return_status := okl_api.handle_exceptions(
                                 l_api_name,
                                 g_pkg_name,
                                 'OTHERS',
                                 l_msg_count,
                                 l_msg_data,
                                 '_PVT');
      -- print the error message in the log file
      okl_accounting_util.get_error_message(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
          FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST LOOP
            fnd_file.put_line(fnd_file.log, l_error_msg_rec(i));
          END LOOP;
        END IF;
      fnd_file.put_line(fnd_file.log, SQLERRM);
  END xml_recon_qry;
END  OKL_STREAMS_RECON_PVT;

/
