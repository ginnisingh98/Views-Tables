--------------------------------------------------------
--  DDL for Package Body OKL_REBOOK_CM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REBOOK_CM_PVT" AS
/* $Header: OKLRCMRB.pls 120.17.12010000.3 2009/01/30 05:54:55 rpillay ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.BILLING';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator


  ------------------------------------------------------------------
  -- Function GET_TRX_TYPE to extract transaction type
  ------------------------------------------------------------------




  FUNCTION get_trx_type
      (p_name           VARCHAR2,
      p_language      VARCHAR2)
      RETURN            NUMBER IS


      CURSOR c_trx_type (cp_name VARCHAR2, cp_language VARCHAR2) IS
            SELECT      id
            FROM      okl_trx_types_tl
            WHERE      name      = cp_name
            AND      LANGUAGE    = cp_language;


    -- Replace with following query
      CURSOR c_trx_id( p_sob_id   NUMBER, p_org_id   NUMBER ) IS
         SELECT  ID1
         FROM OKX_CUST_TRX_TYPES_V
         WHERE name = 'Invoice-OKL'              AND
                   set_of_books_id = p_sob_id       AND
                   org_id                  = p_org_id;


      l_trx_type      okl_trx_types_v.id%TYPE;


  BEGIN


      l_trx_type := NULL;


      OPEN      c_trx_type (p_name, p_language);
      FETCH      c_trx_type INTO l_trx_type;
      CLOSE      c_trx_type;


      RETURN      l_trx_type;


  END get_trx_type;


  ------------------------------------------------------------------
  -- Procedure CM_Bill_adjustments to create adjustments to
  -- Rebooked and unfulfilled invoices with the amounts on the
  -- Billing_Adjustment Stream Type
  ------------------------------------------------------------------


  PROCEDURE CM_Bill_adjustments
      (p_api_version          IN  NUMBER
      ,p_init_msg_list      IN  VARCHAR2
      ,x_return_status      OUT NOCOPY VARCHAR2
      ,x_msg_count            OUT NOCOPY NUMBER
      ,x_msg_data       OUT NOCOPY VARCHAR2
      ,p_contract_number      IN  VARCHAR2
    ) IS


      ------------------------------------------------------------
      -- Get Rebooked Contracts
      ------------------------------------------------------------
      CURSOR rbk_ctrct_csr ( p_contract_number VARCHAR2 )  IS
             SELECT distinct KHR.ID
            FROM OKC_K_HEADERS_B KHR,
                 OKL_STREAMS STM,
                 OKL_STRM_TYPE_B STY,
                 OKL_STRM_ELEMENTS SEL
            WHERE KHR.contract_number = NVL(p_contract_number, contract_number)
            AND KHR.STS_CODE = 'BOOKED'
            AND KHR.ID = STM.KHR_ID
            AND STM.sty_id = STY.id
            AND STY.STREAM_TYPE_PURPOSE = 'REBOOK_BILLING_ADJUSTMENT'
            AND STM.active_yn = 'Y'
            AND sel.stm_id = stm.id
            AND SEL.DATE_BILLED IS NULL;


/*              SELECT  id  */
/*              FROM okc_k_headers_b   */
/*              WHERE contract_number = NVL(p_contract_number, contract_number)
AND  */
/*              sts_code = 'BOOKED' AND  */
/*              id in (  */
/*              SELECT rebook.id  */
/*              FROM okc_k_headers_b orig,  */
/*                   okc_k_headers_b rebook   */
/*              WHERE orig.contract_number = NVL(p_contract_number,
orig.contract_number) and  */
/*                    orig.authoring_org_id =
NVL(TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10)),-99) and  */
/*                    rebook.orig_system_id1 = orig.id and  */
/*                    rebook.orig_system_source_code = 'OKL_REBOOK'          */
/*              UNION                       */
/*              SELECT mass_rebook.id  */
/*              FROM  okc_k_headers_b mass_rebook,  */
/*                    okl_rbk_selected_contract rbk  */
/*              WHERE mass_rebook.contract_number = NVL(p_contract_number,
mass_rebook.contract_number) and  */
/*              mass_rebook.authoring_org_id =
NVL(TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10)),-99) and  */
/*              rbk.khr_id = mass_rebook.id)  */
/*              order by 1;  */


      ------------------------------------------------------------
      -- Get Rebooked Contracts with a Billing Adjustment
    -- Stream Type
      ------------------------------------------------------------
      CURSOR adj_streams_csr( p_khr_id NUMBER ) IS
            SELECT      stm.khr_id             khr_id,
                  TRUNC (ste.stream_element_date)      bill_date,
                  stm.kle_id               kle_id,
                  ste.id                           sel_id,
                  stm.sty_id                 sty_id,
                  khr.contract_number      contract_number,
            khr.currency_code        currency_code,
            khr.authoring_org_id     authoring_org_id,
                --sty.name                stream_name,
            sty.taxable_default_yn   taxable_default_yn,
                  ste.amount                 amount,
            khr.sts_code             sts_code
               FROM
            okl_strm_elements ste,
                  okl_streams            stm,
                  okl_strm_type_b         sty,
                  okc_k_headers_b         khr,
                  okl_k_headers           khl,
                  okc_k_lines_b           kle,
                  okc_statuses_b          khs,
                  okc_statuses_b          kls
            WHERE ste.amount     <> 0
            AND      stm.id                    = ste.stm_id
            AND      ste.date_billed       IS NULL
            AND      stm.active_yn         = 'Y'
--          AND      stm.say_code      = 'CURR'
            AND      sty.id                    = stm.sty_id
          AND sty.stream_type_purpose = 'REBOOK_BILLING_ADJUSTMENT'
--          AND      sty.billable_yn      = 'Y'
            AND      khr.id                    = stm.khr_id
            AND      khr.scs_code          IN ('LEASE', 'LOAN')
        AND       khr.sts_code    = 'BOOKED'
        AND khr.id              = p_khr_id
--          AND      khr.contract_number =
--                      NVL (NULL, khr.contract_number)
            AND      khl.id                = stm.khr_id
            AND      khl.deal_type      IS NOT NULL
            AND      khs.code        = khr.sts_code
            AND      khs.ste_code      = 'ACTIVE'
            AND      kle.id           (+)= stm.kle_id
            AND      kls.code     (+)= kle.sts_code
        --  Bug 3816891 adjust terminated asset lines
            AND      NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED')
            ORDER      BY 1, 2, 3;


      ------------------------------------------------------------
      -- Get Unpaid Invoices For the Contract Line
      ------------------------------------------------------------
   --Bug 5000886: Removed references of stream tables in the following  cursor

    -- Bug 6802801
    -- Bug# 7720775: Changed API call to
    --               OKL_BILLING_UTIL_PVT.INV_LN_AMT_REMAINING_W_INCTAX
    CURSOR unpaid_invs_csr ( p_khr_id NUMBER, p_kle_id NUMBER )  IS
            SELECT
            tai.date_entered          date_billed,
            khr.id                    khr_id,
            TRUNC (tai.date_invoiced) bill_date,
            tld.kle_id                kle_id,
            tld.sel_id                sel_id,
            tld.sty_id                sty_id,
            khr.contract_number       contract_number,
            khr.currency_code         currency_code,
            khr.authoring_org_id      authoring_org_id,
            sty.code                  comments,
            sty.taxable_default_yn    taxable_default_yn,
            OKL_BILLING_UTIL_PVT.INV_LN_AMT_ORIG_WOTAX
            (tldv.CUSTOMER_TRX_ID, tldv.CUSTOMER_TRX_LINE_ID) amount,
            khr.sts_code              sts_code,
            tld.id                    tld_id,
         OKL_BILLING_UTIL_PVT.INV_LN_AMT_REMAINING_W_INCTAX
         (tldv.CUSTOMER_TRX_ID, tldv.CUSTOMER_TRX_LINE_ID) amount_due_remaining,
            PS.trx_number             trx_number,
            PS.class,
            PS.TERMS_SEQUENCE_NUMBER
            FROM
                  okl_strm_type_b               sty,
                  okc_k_headers_b               khr,
                  okl_k_headers                 khl,
                  okc_k_lines_b                 kle,
                  okc_statuses_b                khs,
                  okc_statuses_b                kls,
                  okl_txd_ar_ln_dtls_v          tld,
                  okl_txl_ar_inv_lns_v          til,
                  okl_trx_ar_invoices_v         tai,
                  okl_bpd_tld_ar_lines_v        tldv,
                  AR_PAYMENT_SCHEDULES_ALL      PS
            WHERE sty.billable_yn          = 'Y'
            AND   tld.sty_id               = sty.id
            AND   khr.id                   = p_khr_id
            AND   khr.scs_code             IN ('LEASE', 'LOAN')
            AND   khr.sts_code             IN ( 'BOOKED','EVERGREEN')
            AND   tld.kle_id               = p_kle_id
            AND   tld.kle_id               = kle.id
            AND   khl.id                   = khr.id
            AND   khl.deal_type            IS NOT NULL
            AND   khs.code                 = khr.sts_code
            AND   khs.ste_code             = 'ACTIVE'
            AND   kls.code          (+)    = kle.sts_code
            AND   NVL (kls.ste_code, 'ACTIVE')  IN ('ACTIVE', 'TERMINATED')
            AND   tai.trx_status_code      = 'PROCESSED'
            AND   tai.id                   = til.tai_id
            AND   til.id                   = tld.til_id_details
            AND   tldv.tld_id              = tld.id
            AND   tldv.khr_id              = khr.id
            AND   tldv.customer_trx_id     = ps.customer_trx_id
            AND   tldv.customer_trx_id IS NOT NULL
            AND   PS.TERMS_SEQUENCE_NUMBER = 1
            AND   PS.amount_due_remaining > 0
            ORDER BY 1, 2, 3;

    --Bug 5000886:End

      ------------------------------------------------------------
      -- Get trx_id for Invoice
      ------------------------------------------------------------
      CURSOR c_trx_id( p_sob_id   NUMBER, p_org_id   NUMBER ) IS
         SELECT  ID1
         FROM OKX_CUST_TRX_TYPES_V
         WHERE name = 'Invoice-OKL'              AND
                   set_of_books_id = p_sob_id       AND
                   org_id                  = p_org_id;


     /* --Commented out, since this cursor never used--Bug#5484903
      ------------------------------------------------------------
      -- Get trx_id for Credit Memo
      ------------------------------------------------------------
      CURSOR c_trx_id1( p_sob_id   NUMBER, p_org_id   NUMBER ) IS
         SELECT  ID1
         FROM OKX_CUST_TRX_TYPES_V
         WHERE name = 'Credit Memo-OKL'         AND
                   set_of_books_id = p_sob_id       AND
                   org_id                  = p_org_id; */


      ------------------------------------------------------------
      -- Initialise constants
      ------------------------------------------------------------


      l_def_desc      CONSTANT VARCHAR2(30)      := 'Regular Stream Billing';
      l_line_code     CONSTANT VARCHAR2(30)      := 'LINE';
      l_init_status      CONSTANT VARCHAR2(30)      := 'ENTERED';
      l_final_status      CONSTANT VARCHAR2(30)      := 'PROCESSED';
      l_trx_type_name      CONSTANT VARCHAR2(30)      := 'Billing';
      l_trx_type_lang      CONSTANT VARCHAR2(30)      := 'US';
      l_date_entered      CONSTANT DATE               := SYSDATE;
      l_zero_amount      CONSTANT NUMBER             := 0;
      l_first_line      CONSTANT NUMBER             := 1;
      l_line_step     CONSTANT NUMBER                := 1;
      l_def_no_val      CONSTANT NUMBER             := -1;
      l_null_kle_id      CONSTANT NUMBER             := -2;


      ------------------------------------------------------------
      -- Declare records: i - insert, u - update, r - result
      ------------------------------------------------------------


      -- Transaction headers
      i_taiv_rec      okl_tai_pvt.taiv_rec_type;
      u_taiv_rec      okl_tai_pvt.taiv_rec_type;
      lx_taiv_rec     okl_tai_pvt.taiv_rec_type;
       l_init_taiv_rec      Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
      r_taiv_rec      Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;


      -- Transaction lines
      i_tilv_rec      okl_til_pvt.tilv_rec_type;
        i_tilv_tbl          okl_til_pvt.tilv_tbl_type;
        lx_tilv_tbl         okl_til_pvt.tilv_tbl_type;
      u_tilv_rec      Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
      x_tilv_rec      Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
      l_init_tilv_rec      Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
      r_tilv_rec      Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;


      -- Transaction line details
      i_tldv_rec          okl_tld_pvt.tldv_rec_type;
        i_tldv_tbl              okl_tld_pvt.tldv_tbl_type;
        lx_tldv_tbl             okl_tld_pvt.tldv_tbl_type;
      u_tldv_rec          Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
      x_tldv_rec          Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
    l_init_tldv_rec     Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
      r_tldv_rec          Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;


      -- Ext Transaction Header
      i_xsiv_rec          Okl_Ext_Sell_Invs_Pub.xsiv_rec_type;
    l_init_xsiv_rec     Okl_Ext_Sell_Invs_Pub.xsiv_rec_type;
      r_xsiv_rec          Okl_Ext_Sell_Invs_Pub.xsiv_rec_type;


      -- Ext Transaction Lines
      i_xlsv_rec          Okl_Xtl_Sell_Invs_Pub.xlsv_rec_type;
    l_init_xlsv_rec     Okl_Xtl_Sell_Invs_Pub.xlsv_rec_type;
      r_xlsv_rec          Okl_Xtl_Sell_Invs_Pub.xlsv_rec_type;


      -- Ext Transaction Details
      i_esdv_rec          Okl_Xtd_Sell_Invs_Pub.esdv_rec_type;
    l_init_esdv_rec     Okl_Xtd_Sell_Invs_Pub.esdv_rec_type;
      r_esdv_rec          Okl_Xtd_Sell_Invs_Pub.esdv_rec_type;


      -- Stream elements
      u_selv_rec          Okl_Streams_Pub.selv_rec_type;
      l_init_selv_rec       Okl_Streams_Pub.selv_rec_type;
      r_selv_rec          Okl_Streams_Pub.selv_rec_type;


      ------------------------------------------------------------
      -- Declare local variables used in the program
      ------------------------------------------------------------


      l_khr_id      okl_trx_ar_invoices_v.khr_id%TYPE;
      l_bill_date      okl_trx_ar_invoices_v.date_invoiced%TYPE;
      l_trx_type      okl_trx_ar_invoices_v.try_id%TYPE;
      l_kle_id      okl_txl_ar_inv_lns_v.kle_id%TYPE;


      l_line_number      okl_txl_ar_inv_lns_v.line_number%TYPE;
      l_detail_number      okl_txd_ar_ln_dtls_v.line_detail_number%TYPE;


      l_header_amount      okl_trx_ar_invoices_v.amount%TYPE;
      l_line_amount      okl_txl_ar_inv_lns_v.amount%TYPE;


      l_header_id      okl_trx_ar_invoices_v.id%TYPE;
      l_line_id      okl_txl_ar_inv_lns_v.id%TYPE;


      ------------------------------------------------------------
      -- Declare variables required by APIs
      ------------------------------------------------------------


      l_api_version      CONSTANT NUMBER := 1;
      l_api_name      CONSTANT VARCHAR2(30)  := 'BILL_STREAMS';
      l_return_status      VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;


      ------------------------------------------------------------
      -- Declare variables to call Accounting Engine.
      ------------------------------------------------------------
      p_bpd_acc_rec                             Okl_Acc_Call_Pub.bpd_acc_rec_type;
      l_init_bpd_acc_rec                        Okl_Acc_Call_Pub.bpd_acc_rec_type;




      ------------------------------------------------------------
      -- Variables for Error Processing and Committing Stream Billing
    -- Transactions
      ------------------------------------------------------------


    l_error_status               VARCHAR2(1);
    l_error_message              VARCHAR2(2000);
    l_trx_status_code            Okl_trx_ar_invoices_v.trx_status_code%TYPE;


    -- To enforce commit frequency
    l_commit_cnt                 NUMBER;
    l_max_commit_cnt             NUMBER := 500;


    -- For currecy precision rounded amount
    l_ste_amount                 okl_strm_elements.amount%type;
    l_curr_code                  okc_k_headers_b.currency_code%TYPE;
      ------------------------------------------------------------
      -- For errors in Stream Elements Table
      ------------------------------------------------------------


    l_distr_cnt             NUMBER;


    -------------------------------------------------------------------------
    -- Account Builder Code
    -------------------------------------------------------------------------
        l_acc_gen_primary_key_tbl           Okl_Account_Dist_Pub.acc_gen_primary_key;
        l_init_acc_gen_primary_key_tbl  Okl_Account_Dist_Pub.acc_gen_primary_key;




    TYPE sel_err_rec_type IS RECORD (
            sel_id              NUMBER,
            tld_id              NUMBER,
            xsi_id              NUMBER,
                  bill_date           DATE,
                  contract_number     okc_k_headers_b.contract_number%type,
                  stream_purpose      okl_strm_type_v.stream_type_purpose%type,
                  amount              okl_strm_elements.amount%type,
            error_message       Varchar2(2000)
      );


    TYPE sel_err_tbl_type IS TABLE OF sel_err_rec_type
            INDEX BY BINARY_INTEGER;


    sel_error_log_table         sel_err_tbl_type;
    l_init_sel_table            sel_err_tbl_type;


    l_sel_tab_index             NUMBER;


      ------------------------------------------------------------
      -- Cursors for Rule based values
      ------------------------------------------------------------


    -- Local Vars for Rule based values --EXT
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
    l_rct_method_code             AR_RECEIPT_CLASSES.CREATION_METHOD_CODE%TYPE;
    l_asst_tax                OKC_RULES_B.rule_information1%TYPE;
    l_asst_line_tax           OKC_RULES_B.rule_information1%TYPE;
    l_product_id              okl_k_headers_full_v.pdt_id%TYPE;


      -----------------------------------------
      -- Local Variables for Rebook Credit Memo
      -- amounts
      -----------------------------------------
      l_bill_ajst_amt      NUMBER;
      lx_tai_id            NUMBER;
      l_credit_amount      NUMBER;


      l_err_status         VARCHAR2(1);


      TYPE err_rec_type IS RECORD (
           tai_id                  NUMBER,
         trx_number     ra_customer_trx_all.trx_number%TYPE,
         amount         NUMBER
        );


      TYPE err_tbl_type IS TABLE OF err_rec_type
           INDEX BY BINARY_INTEGER;


        err_tbl                        err_tbl_type;
        l_init_err_tbl           err_tbl_type;
        err_idx                        NUMBER;


      l_commit_cntr          NUMBER;
      l_credit_date          DATE;
BEGIN


      ------------------------------------------------------------
      -- Start processing
      ------------------------------------------------------------


      x_return_status := Okl_Api.G_RET_STS_SUCCESS;


      l_return_status := Okl_Api.START_ACTIVITY(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_init_msg_list      => p_init_msg_list,
            l_api_version      => l_api_version,
            p_api_version      => p_api_version,
            p_api_type  => '_PVT',
            x_return_status      => l_return_status);


      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;


    ------------------------------------------------------------
    -- Process all Or specific rebooked Contracts
    -- with Billing Adjustment lines
    ------------------------------------------------------------
    l_commit_cntr := 0;


    FOR rbk_ctrct_rec IN rbk_ctrct_csr( p_contract_number ) LOOP


        --------------------------------------------------------
        -- Process Lines with Adjustment amounts
        --------------------------------------------------------
        FOR adj_streams_rec IN adj_streams_csr( rbk_ctrct_rec.id ) LOOP
            FND_FILE.PUT_LINE (FND_FILE.LOG,'Adjustment Amount: '
                                         ||adj_streams_rec.amount
                                         ||' for Contract: '
                                         ||adj_streams_rec.contract_number);


            -------------------------------------------
            -- Track commit batch size
            -------------------------------------------
            l_commit_cntr := l_commit_cntr + 1;


            IF l_commit_cntr >= 500 THEN
               COMMIT;
               l_commit_cntr := 0;
            END IF;
            -------------------------------------------
            -- Create adjustment Invoice if amount > 0
            -- (This is an unlikely case given the rebook
            --  process functionality)
            -------------------------------------------
            IF adj_streams_rec.amount > 0 THEN


               ------------------------------------------------
               -- Initialize the error processing variables
               ------------------------------------------------
               l_err_status               := 'S';
                 err_tbl                       := l_init_err_tbl;
                 err_idx                           := 0;


               i_taiv_rec                 := l_init_taiv_rec;


               i_taiv_rec.trx_status_code := 'SUBMITTED';
               i_taiv_rec.khr_id          := adj_streams_rec.khr_id;
               i_taiv_rec.amount          := adj_streams_rec.amount;


               l_trx_type                 := get_trx_type ('Billing', 'US');
               i_taiv_rec.try_id          := l_trx_type;
               i_taiv_rec.date_invoiced   := adj_streams_rec.bill_date;
               i_taiv_rec.date_entered    := SYSDATE;
               i_taiv_rec.description     := 'Rebook Adjustment Invoice';
               i_taiv_rec.okl_source_billing_trx := 'REBOOK';


            --rkuttiya commented  for R12 B Billing Architecture, calling the common Billing API to create Billing Transactions

              i_tilv_rec                        := l_init_tilv_rec;
              i_tilv_rec.amount                 := adj_streams_rec.amount;
              i_tilv_rec.kle_id                 := adj_streams_rec.kle_id;
              i_tilv_rec.inv_receiv_line_code      := l_line_code;
              i_tilv_rec.line_number        := 1;
              i_tilv_rec.txl_ar_line_number     := 1;
              i_tilv_rec.description            := 'Rebook Adjustment Invoice';
              i_tilv_rec.date_bill_period_start := adj_streams_rec.bill_date;
              i_tilv_rec.sty_id := adj_streams_rec.sty_id; -- 6328168

              i_tilv_tbl(1) := i_tilv_rec;




              i_tldv_rec  := l_init_tldv_rec;


              i_tldv_rec.amount             := adj_streams_rec.amount;
              i_tldv_rec.line_detail_number := 1;
              i_tldv_rec.sty_id             := adj_streams_rec.sty_id;
              i_tldv_rec.sel_id             := adj_streams_rec.sel_id;
              i_tldv_rec.description        := 'Rebook Adjustment Invoice';
              i_tldv_rec.txl_ar_line_number := 1;


              i_tldv_tbl(1) := i_tldv_rec;


             --rkuttiya R12 B Billing Architecture
             -- call central Billing API to create transaction and accounting distributions
                 OKL_INTERNAL_BILLING_PVT.create_billing_trx( p_api_version
=> l_api_version
                                                             ,p_init_msg_list
=> p_init_msg_list
                                                             ,x_return_status
=> l_return_status
                                                             ,x_msg_count
=> x_msg_count
                                                             ,x_msg_data
=> x_msg_data
                                                             ,p_taiv_rec
=> i_taiv_rec
                                                             ,p_tilv_tbl
=> i_tilv_tbl
                                                             ,p_tldv_tbl
=> i_tldv_tbl
                                                             ,x_taiv_rec
=> lx_taiv_rec
                                                             ,x_tilv_tbl
=> lx_tilv_tbl
                                                             ,x_tldv_tbl
=> lx_tldv_tbl);


                 ----------------------------------------
                 -- Record tai_id for error processing
                 ----------------------------------------
                 err_idx                     := err_idx + 1;
                 err_tbl(err_idx).tai_id     := lx_taiv_rec.id;
                 err_tbl(err_idx).trx_number := NULL;
                 err_tbl(err_idx).amount     := i_taiv_rec.amount;


                IF  (x_return_status = 'S' ) THEN
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Billing Transactions Created.');
                ELSE
                    l_err_status  := 'E';
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating Billing Transactions.');
                END IF;


                IF (x_return_status <> 'S' ) THEN
                    UPDATE okl_trx_ar_invoices_b
                    SET trx_status_code = 'ERROR'
                    WHERE id = lx_taiv_rec.id;
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating Billing Transactions.');
                ELSE
                    ----------------------------------------------
                    -- Check if there was ever an error and update
                    -- accordingly
                    ----------------------------------------------
                    IF l_err_status = 'E' THEN
                        -----------------------------------------
                        -- Flag all TAI records for this bill adj
                        -- as error
                        -----------------------------------------
                        FOR i in err_tbl.FIRST..err_tbl.LAST LOOP
                               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Reversing Invoice for '||err_tbl(i).amount);


                               UPDATE okl_trx_ar_invoices_b
                               SET trx_status_code = 'ERROR'
                               WHERE id = err_tbl(i).tai_id;
                        END LOOP;


                    ELSE
                        UPDATE okl_strm_elements
                        SET date_billed = SYSDATE
                        WHERE id = adj_streams_rec.sel_id;
                    END IF;
                END IF;


            ELSE -- (create Invoice specific credit memo)


                ------------------------------------------------
                -- Initialize the error processing variables
                ------------------------------------------------
                l_err_status              := 'S';
                  err_tbl                   := l_init_err_tbl;
                  err_idx                           := 0;


                l_bill_ajst_amt := adj_streams_rec.amount;


                FOR unpaid_invs_rec IN unpaid_invs_csr (
                                        adj_streams_rec.khr_id,
                                        adj_streams_rec.kle_id ) LOOP


                    IF l_bill_ajst_amt >= 0 THEN
                       EXIT;
                    END IF;


                    r_taiv_rec      := l_init_taiv_rec;
                    l_credit_amount := 0;


                    IF ( abs(l_bill_ajst_amt) > unpaid_invs_rec.amount_due_remaining )
                    THEN
                            l_credit_amount := unpaid_invs_rec.amount_due_remaining;
                    ELSE
                            l_credit_amount := abs(l_bill_ajst_amt);
                    END IF;


                    -- ----------------------------
                    -- Credit date
                    -- ----------------------------
                    l_credit_date := NULL;
                    IF unpaid_invs_rec.bill_date > SYSDATE THEN
                        l_credit_date := unpaid_invs_rec.bill_date;
                    ELSE
                        l_credit_date := SYSDATE;
                    END IF;




                    --rkuttiya R12 B Billing Architecture
                    -- changed p_lsm_id  to p_tld_id
                    okl_credit_memo_pub.insert_request(
                                            p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            p_tld_id        => unpaid_invs_rec.tld_id,
                                            p_credit_amount => (-1*l_credit_amount),
                                            p_credit_sty_id => NULL,
                                            p_credit_desc   => 'Rebook Adjustment Credit Memo',
                                            p_credit_date   => l_credit_date,
                                            p_try_id        => NULL,
                                            p_transaction_source=>'REBOOK',  -- bug 6328168
                                            x_tai_id        => lx_tai_id,
                                            x_taiv_rec      => r_taiv_rec,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data);


                     ----------------------------------------
                     -- Record tai_id for error processing
                     ----------------------------------------
                     err_idx                     := err_idx + 1;
                     err_tbl(err_idx).tai_id     := lx_tai_id;
                     err_tbl(err_idx).trx_number := unpaid_invs_rec.trx_number;
                     err_tbl(err_idx).amount     := l_credit_amount;


                     IF l_return_status = 'S' THEN
                        FND_FILE.PUT_LINE (FND_FILE.LOG,'Credited AR Invoice: '
                                           ||unpaid_invs_rec.trx_number
                                           ||' for: '||l_credit_amount);
                        l_bill_ajst_amt := l_bill_ajst_amt + unpaid_invs_rec.amount_due_remaining;
                     ELSE
                        l_err_status  := 'E';


                        FND_FILE.PUT_LINE (FND_FILE.LOG,'ERROR Crediting AR Invoice: '
                                           ||unpaid_invs_rec.trx_number
                                           ||' for: '||l_credit_amount);
                        EXIT;
                     END IF;
                END LOOP;


                -- If there was more credit than Invoices could use,
                -- then, create an On-account CM
                IF l_bill_ajst_amt < 0 THEN


                    i_taiv_rec                 := l_init_taiv_rec;


                    i_taiv_rec.trx_status_code := 'SUBMITTED';
                    i_taiv_rec.khr_id          := adj_streams_rec.khr_id;
                    i_taiv_rec.amount          := l_bill_ajst_amt;


                    l_trx_type                 := get_trx_type ('Credit Memo', 'US');
                          i_taiv_rec.try_id          := l_trx_type;
                    i_taiv_rec.date_invoiced   := adj_streams_rec.bill_date;
                    i_taiv_rec.date_entered    := SYSDATE;
                    i_taiv_rec.description     := 'Rebook Adjustment Invoice';
                    i_taiv_rec.okl_source_billing_trx := 'REBOOK';

                    i_tilv_rec                        := l_init_tilv_rec;
                    i_tilv_rec.amount                 := l_bill_ajst_amt;
                    i_tilv_rec.kle_id                 := adj_streams_rec.kle_id;
                    i_tilv_rec.inv_receiv_line_code      := l_line_code;
                    i_tilv_rec.line_number        := 1;
                    i_tilv_rec.description            := 'Rebook Adjustment Invoice';
                    i_tilv_rec.date_bill_period_start := adj_streams_rec.bill_date;
                    i_tilv_rec.sty_id                 := adj_streams_rec.sty_id;
-- 6328168


                    i_tilv_tbl(1) := i_tilv_rec;


                    i_tldv_rec  := l_init_tldv_rec;


                    i_tldv_rec.amount             := l_bill_ajst_amt;
                    i_tldv_rec.line_detail_number := 1;
                    i_tldv_rec.sty_id             := adj_streams_rec.sty_id;
                    i_tldv_rec.sel_id             := adj_streams_rec.sel_id;
                    i_tldv_rec.txl_ar_line_number := 1;


                    i_tldv_tbl(1) := i_tldv_rec;


                   --rkuttiya R12 B Billing Architecture
             -- call central Billing API to create transaction and accounting distributions
                 OKL_INTERNAL_BILLING_PVT.create_billing_trx( p_api_version
=> l_api_version
                                                             ,p_init_msg_list
=> p_init_msg_list
                                                             ,x_return_status
=> l_return_status
                                                             ,x_msg_count
=> x_msg_count
                                                             ,x_msg_data
=> x_msg_data
                                                             ,p_taiv_rec
=> i_taiv_rec
                                                             ,p_tilv_tbl
=> i_tilv_tbl
                                                             ,p_tldv_tbl
=> i_tldv_tbl
                                                             ,x_taiv_rec
=> lx_taiv_rec
                                                             ,x_tilv_tbl
=> lx_tilv_tbl
                                                             ,x_tldv_tbl
=> lx_tldv_tbl);


                     ----------------------------------------
                    -- Record tai_id for error processing
                    ----------------------------------------
                    err_idx                     := err_idx + 1;
                    err_tbl(err_idx).tai_id     := lx_taiv_rec.id;
                    err_tbl(err_idx).trx_number := NULL;
                    err_tbl(err_idx).amount     := lx_taiv_rec.amount;


                    IF  (x_return_status = 'S' ) THEN
                        FND_FILE.PUT_LINE (FND_FILE.LOG, 'On Account Billing Transactions Created.');
                    ELSE
                        l_err_status  := 'E';
                        FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating On Account Billing Transactions.');
                    END IF;




                END IF; -- More Credit remaining than needed


                --IF (x_return_status = 'S' ) THEN
                --    UPDATE okl_strm_elements
                --    SET date_billed = SYSDATE
                --    WHERE id = adj_streams_rec.sel_id;
                --END IF;
                IF (x_return_status <> 'S' ) THEN
                    IF l_err_status  = 'E' THEN
                        -----------------------------------------
                        -- Flag all TAI records for this bill adj
                        -- as error
                        -----------------------------------------
                        FOR i in err_tbl.FIRST..err_tbl.LAST LOOP
                               IF err_tbl(i).trx_number IS NOT NULL THEN
                                  FND_FILE.PUT_LINE (FND_FILE.LOG, 'Reversing Credited Invoice '
                                  ||err_tbl(i).trx_number
                                  ||' for amount '
                                  ||err_tbl(i).amount);
                               ELSE
                                  FND_FILE.PUT_LINE (FND_FILE.LOG, 'Reversing Credit for amount '
                                  ||err_tbl(i).amount);
                               END IF;


                               UPDATE okl_trx_ar_invoices_b
                               SET trx_status_code = 'ERROR'
                               WHERE id = err_tbl(i).tai_id;
                        END LOOP;
                    ELSE
                        UPDATE okl_strm_elements
                        SET date_billed = SYSDATE
                        WHERE id = adj_streams_rec.sel_id;
                    END IF;


                    --UPDATE okl_trx_ar_invoices_b
                    --SET trx_status_code = 'ERROR'
                    --WHERE id = x_taiv_rec.id;
                    --FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating Accounting Distributions.');
                ELSE
                    IF l_err_status  = 'E' THEN
                        -----------------------------------------
                        -- Flag all TAI records for this bill adj
                        -- as error
                        -----------------------------------------
                        FOR i in err_tbl.FIRST..err_tbl.LAST LOOP
                               IF err_tbl(i).trx_number IS NOT NULL THEN
                                  FND_FILE.PUT_LINE (FND_FILE.LOG, 'Reversing Credited Invoice '
                                  ||err_tbl(i).trx_number
                                  ||' for amount '
                                  ||err_tbl(i).amount);
                               ELSE
                                  FND_FILE.PUT_LINE (FND_FILE.LOG, 'Reversing Credit for amount '
                                  ||err_tbl(i).amount);
                               END IF;


                               UPDATE okl_trx_ar_invoices_b
                               SET trx_status_code = 'ERROR'
                               WHERE id = err_tbl(i).tai_id;
                        END LOOP;
                    ELSE
                        UPDATE okl_strm_elements
                        SET date_billed = SYSDATE
                        WHERE id = adj_streams_rec.sel_id;
                    END IF;
                END IF;


            END IF;
        END LOOP;
    END LOOP;


      ------------------------------------------------------------
      -- End processing
      ------------------------------------------------------------


      Okl_Api.END_ACTIVITY (
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data);




  EXCEPTION


      ------------------------------------------------------------
      -- Exception handling
      ------------------------------------------------------------


      WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'Okl_Api.G_RET_STS_ERROR',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


      WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXP) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'Okl_Api.G_RET_STS_UNEXP_ERROR',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


      WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'OTHERS',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


  END CM_Bill_adjustments;






  PROCEDURE CUSTOM_CM_Bill_adjustments
      (p_api_version          IN  NUMBER
      ,p_init_msg_list      IN  VARCHAR2
      ,x_return_status      OUT NOCOPY VARCHAR2
      ,x_msg_count            OUT NOCOPY NUMBER
      ,x_msg_data       OUT NOCOPY VARCHAR2
      ,p_contract_number      IN  VARCHAR2
    ) IS
  BEGIN


      NULL;


  END CUSTOM_CM_Bill_adjustments;




  PROCEDURE ON_ACCT_Bill_adjustments
      (p_api_version          IN  NUMBER
      ,p_init_msg_list      IN  VARCHAR2
      ,x_return_status      OUT NOCOPY VARCHAR2
      ,x_msg_count            OUT NOCOPY NUMBER
      ,x_msg_data       OUT NOCOPY VARCHAR2
      ,p_contract_number      IN  VARCHAR2
    )
  IS




      ------------------------------------------------------------
      -- Get Rebooked Contracts
      ------------------------------------------------------------
      CURSOR rbk_ctrct_csr ( p_contract_number VARCHAR2 )  IS
            SELECT distinct KHR.ID
            FROM OKC_K_HEADERS_B KHR,
                 OKL_STREAMS STM,
                 OKL_STRM_TYPE_B STY,
                 OKL_STRM_ELEMENTS SEL
            WHERE KHR.contract_number = NVL(p_contract_number, contract_number)
            AND KHR.STS_CODE = 'BOOKED'
            AND KHR.ID = STM.KHR_ID
            AND STM.sty_id = STY.id
            AND STY.STREAM_TYPE_PURPOSE = 'REBOOK_BILLING_ADJUSTMENT'
            AND STM.active_yn = 'Y'
            AND sel.stm_id = stm.id
            AND SEL.DATE_BILLED IS NULL;


/*              SELECT  id  */
/*              FROM okc_k_headers_b   */
/*              WHERE contract_number = NVL(p_contract_number, contract_number)
AND  */
/*              sts_code = 'BOOKED' AND  */
/*              id in (  */
/*              SELECT rebook.id  */
/*              FROM okc_k_headers_b orig,  */
/*                   okc_k_headers_b rebook   */
/*              WHERE orig.contract_number = NVL(p_contract_number,
orig.contract_number) and  */
/*                    orig.authoring_org_id =
NVL(TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10)),-99) and  */
/*                    rebook.orig_system_id1 = orig.id and  */
/*                    rebook.orig_system_source_code = 'OKL_REBOOK'          */
/*              UNION                       */
/*              SELECT mass_rebook.id  */
/*              FROM  okc_k_headers_b mass_rebook,  */
/*                    okl_rbk_selected_contract rbk  */
/*              WHERE mass_rebook.contract_number = NVL(p_contract_number,
mass_rebook.contract_number) and  */
/*              mass_rebook.authoring_org_id =
NVL(TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10)),-99) and  */
/*              rbk.khr_id = mass_rebook.id)  */
/*              order by 1;         */




      ------------------------------------------------------------
      -- Get Rebooked Contracts with a Billing Adjustment
    -- Stream Type
      ------------------------------------------------------------
      CURSOR adj_streams_csr( p_khr_id NUMBER ) IS
            SELECT      stm.khr_id             khr_id,
                  TRUNC (ste.stream_element_date)      bill_date,
                  stm.kle_id               kle_id,
                  ste.id                           sel_id,
                  stm.sty_id                 sty_id,
                  khr.contract_number      contract_number,
            khr.currency_code        currency_code,
            khr.authoring_org_id     authoring_org_id,
                  --sty.name                   stream_name,
            sty.taxable_default_yn   taxable_default_yn,
                  ste.amount                 amount,
            khr.sts_code             sts_code
               FROM
            okl_strm_elements ste,
                  okl_streams            stm,
                  okl_strm_type_b         sty,
                  okc_k_headers_b         khr,
                  okl_k_headers           khl,
                  okc_k_lines_b           kle,
                  okc_statuses_b          khs,
                  okc_statuses_b          kls
            WHERE ste.amount     <> 0
            AND      stm.id                    = ste.stm_id
            AND      ste.date_billed       IS NULL
            AND      stm.active_yn         = 'Y'
--          AND      stm.say_code      = 'CURR'
            AND      sty.id                    = stm.sty_id
          AND sty.stream_type_purpose = 'REBOOK_BILLING_ADJUSTMENT'
--          AND      sty.billable_yn      = 'Y'
            AND      khr.id                    = stm.khr_id
            AND      khr.scs_code          IN ('LEASE', 'LOAN')
        AND       khr.sts_code    = 'BOOKED'
        AND khr.id              = p_khr_id
--          AND      khr.contract_number =
--                      NVL (NULL, khr.contract_number)
            AND      khl.id                = stm.khr_id
            AND      khl.deal_type      IS NOT NULL
            AND      khs.code        = khr.sts_code
            AND      khs.ste_code      = 'ACTIVE'
            AND      kle.id           (+)= stm.kle_id
            AND      kls.code     (+)= kle.sts_code
        AND      NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED')
            ORDER      BY 1, 2, 3;


      ------------------------------------------------------------
      -- Declare variables required by APIs
      ------------------------------------------------------------


      l_api_version      CONSTANT NUMBER := 1;
      l_api_name      CONSTANT VARCHAR2(30)  := 'BILL_STREAMS';
      l_return_status      VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;


      ------------------------------------------------------------
      -- Declare variables to call Accounting Engine.
      ------------------------------------------------------------
      p_bpd_acc_rec
Okl_Acc_Call_Pub.bpd_acc_rec_type;
      l_init_bpd_acc_rec
Okl_Acc_Call_Pub.bpd_acc_rec_type;


      ------------------------------------------------------------
      -- Declare records: i - insert, u - update, r - result
      ------------------------------------------------------------


      -- Transaction headers
      i_taiv_rec      okl_tai_pvt.taiv_rec_type;
      u_taiv_rec      okl_tai_pvt.taiv_rec_type;
      lx_taiv_rec     okl_tai_pvt.taiv_rec_type;
       l_init_taiv_rec      Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
      r_taiv_rec      Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;


      -- Transaction lines
      i_tilv_rec      okl_til_pvt.tilv_rec_type;
        i_tilv_tbl          okl_til_pvt.tilv_tbl_type;
      u_tilv_rec      okl_til_pvt.tilv_rec_type;
      lx_tilv_tbl     okl_til_pvt.tilv_tbl_type;
      l_init_tilv_rec       okl_til_pvt.tilv_rec_type;
      r_tilv_rec      Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;


      -- Transaction line details
      i_tldv_rec        okl_tld_pvt .tldv_rec_type;
        i_tldv_tbl            okl_tld_pvt.tldv_tbl_type;
      u_tldv_rec        okl_tld_pvt.tldv_rec_type;
      lx_tldv_tbl       okl_tld_pvt.tldv_tbl_type;
    l_init_tldv_rec           okl_tld_pvt.tldv_rec_type;
      r_tldv_rec        okl_tld_pvt.tldv_rec_type;


      l_trx_type          okl_trx_ar_invoices_v.try_id%TYPE;
      l_line_code         CONSTANT VARCHAR2(30)      := 'LINE';


    -----------------------------------------
    -- Local Variables for Rebook Credit Memo
    -- amounts
    -----------------------------------------
    l_bill_ajst_amt      NUMBER;




BEGIN


      ------------------------------------------------------------
      -- Start processing
      ------------------------------------------------------------


      x_return_status := Okl_Api.G_RET_STS_SUCCESS;


      l_return_status := Okl_Api.START_ACTIVITY(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_init_msg_list      => p_init_msg_list,
            l_api_version      => l_api_version,
            p_api_version      => p_api_version,
            p_api_type  => '_PVT',
            x_return_status      => l_return_status);


      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;


    ------------------------------------------------------------
    -- Process all Or specific rebooked Contracts
    -- with Billing Adjustment lines
    ------------------------------------------------------------
    FOR rbk_ctrct_rec IN rbk_ctrct_csr( p_contract_number ) LOOP


        --------------------------------------------------------
        -- Process Lines with Adjustment amounts
        --------------------------------------------------------
        FOR adj_streams_rec IN adj_streams_csr( rbk_ctrct_rec.id ) LOOP
            FND_FILE.PUT_LINE (FND_FILE.LOG,'Adjustment Amount: '
                                         ||adj_streams_rec.amount
                                         ||' for Contract: '
                                         ||adj_streams_rec.contract_number);




            -------------------------------------------
            -- Create adjustment Invoice if amount > 0
            -------------------------------------------
            IF adj_streams_rec.amount > 0 THEN


               i_taiv_rec                 := l_init_taiv_rec;


               i_taiv_rec.trx_status_code := 'SUBMITTED';
               i_taiv_rec.khr_id          := adj_streams_rec.khr_id;
               i_taiv_rec.amount          := adj_streams_rec.amount;


               l_trx_type                 := get_trx_type ('Billing', 'US');
               i_taiv_rec.try_id          := l_trx_type;
               i_taiv_rec.date_invoiced   := adj_streams_rec.bill_date;
               i_taiv_rec.date_entered    := SYSDATE;
               i_taiv_rec.description     := 'Rebook Adjustment Invoice';
               i_taiv_rec.okl_source_billing_trx := 'REBOOK';


              i_tilv_rec                        := l_init_tilv_rec;
              i_tilv_rec.amount                 := adj_streams_rec.amount;
              i_tilv_rec.kle_id                 := adj_streams_rec.kle_id;
              i_tilv_rec.inv_receiv_line_code      := l_line_code;
              i_tilv_rec.line_number        := 1;
              i_tilv_rec.txl_ar_line_number     := 1;
              i_tilv_rec.description            := 'Rebook Adjustment Invoice';
              i_tilv_rec.date_bill_period_start := adj_streams_rec.bill_date;


              i_tilv_tbl(1)  := i_tilv_rec;


              i_tldv_rec  := l_init_tldv_rec;


              i_tldv_rec.amount             := adj_streams_rec.amount;
              i_tldv_rec.line_detail_number := 1;
              i_tldv_rec.sty_id             := adj_streams_rec.sty_id;
              i_tldv_rec.sel_id             := adj_streams_rec.sel_id;
              i_tldv_rec.description        := 'Rebook Adjustment Invoice';
              i_tldv_rec.txl_ar_line_number := 1;


              i_tldv_tbl(1) := i_tldv_rec;


                --rkuttiya R12 B Billing Architecture
               --call to central Billing API to create Billing transactions and accounting distributions


                 OKL_INTERNAL_BILLING_PVT.create_billing_trx( p_api_version
=> l_api_version
                                                             ,p_init_msg_list
=> p_init_msg_list
                                                             ,x_return_status
=> l_return_status
                                                             ,x_msg_count
=> x_msg_count
                                                             ,x_msg_data
=> x_msg_data
                                                             ,p_taiv_rec
=> i_taiv_rec
                                                             ,p_tilv_tbl
=> i_tilv_tbl
                                                             ,p_tldv_tbl
=> i_tldv_tbl
                                                             ,x_taiv_rec
=> lx_taiv_rec
                                                             ,x_tilv_tbl
=> lx_tilv_tbl
                                                             ,x_tldv_tbl
=> lx_tldv_tbl);


                IF  (x_return_status = 'S' ) THEN
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Billing Transactions Created.');
                ELSE
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating Billing Transactions.');
                END IF;


                IF (x_return_status <> 'S' ) THEN
                    UPDATE okl_trx_ar_invoices_b
                    SET trx_status_code = 'ERROR'
                    WHERE id = lx_taiv_rec.id;
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating Billing Transactions.');
                ELSE
                    UPDATE okl_strm_elements
                    SET date_billed = SYSDATE
                    WHERE id = adj_streams_rec.sel_id;
                END IF;


            ELSE -- (create Invoice specific credit memo)


                l_bill_ajst_amt := adj_streams_rec.amount;


                IF l_bill_ajst_amt < 0 THEN


                    i_taiv_rec                 := l_init_taiv_rec;


                    i_taiv_rec.trx_status_code := 'SUBMITTED';
                    i_taiv_rec.khr_id          := adj_streams_rec.khr_id;
                    i_taiv_rec.amount          := l_bill_ajst_amt;


                    l_trx_type                 := get_trx_type ('Credit Memo',
'US');
                 i_taiv_rec.try_id          := l_trx_type;
                    i_taiv_rec.date_invoiced   := adj_streams_rec.bill_date;
                    i_taiv_rec.date_entered    := SYSDATE;
                    i_taiv_rec.description     := 'Rebook Adjustment Invoice';
                    i_taiv_rec.okl_source_billing_trx := 'REBOOK';


                    i_tilv_rec                        := l_init_tilv_rec;
                    i_tilv_rec.amount                 := l_bill_ajst_amt;
                    i_tilv_rec.kle_id                 := adj_streams_rec.kle_id;
                    i_tilv_rec.inv_receiv_line_code      := l_line_code;
                    i_tilv_rec.line_number        := 1;
                    i_tilv_rec.txl_ar_line_number     := 1;
                    i_tilv_rec.description            := 'Rebook Adjustment Invoice';
                    i_tilv_rec.date_bill_period_start :=
adj_streams_rec.bill_date;
                    i_tilv_rec.sty_id     := adj_streams_rec.sty_id;--6328168


                    i_tilv_tbl(1) := i_tilv_rec;


                    i_tldv_rec  := l_init_tldv_rec;


                    i_tldv_rec.amount             := l_bill_ajst_amt;
                    i_tldv_rec.line_detail_number := 1;
                    i_tldv_rec.sty_id             := adj_streams_rec.sty_id;
                    i_tldv_rec.sel_id             := adj_streams_rec.sel_id;
                    i_tldv_rec.description        := 'Rebook Adjustment Invoice';
                    i_tldv_rec.txl_ar_line_number := 1;


                    i_tldv_tbl(1) := i_tldv_rec;


                    --rkuttiya R12 B Billing Architecture
                    --call to central Billing API to create Billing transactions and accounting distributions


                 OKL_INTERNAL_BILLING_PVT.create_billing_trx( p_api_version
=> l_api_version
                                                             ,p_init_msg_list
=> p_init_msg_list
                                                             ,x_return_status
=> l_return_status
                                                             ,x_msg_count
=> x_msg_count
                                                             ,x_msg_data
=> x_msg_data
                                                             ,p_taiv_rec
=> i_taiv_rec
                                                             ,p_tilv_tbl
=> i_tilv_tbl
                                                             ,p_tldv_tbl
=> i_tldv_tbl
                                                             ,x_taiv_rec
=> lx_taiv_rec
                                                             ,x_tilv_tbl
=> lx_tilv_tbl
                                                             ,x_tldv_tbl
=> lx_tldv_tbl);


                    IF  (x_return_status = 'S' ) THEN
                        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Billing Transactions Created');
                    ELSE
                        FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating Billing Transactions.');
                    END IF;


                    IF (x_return_status <> 'S' ) THEN
                        UPDATE okl_trx_ar_invoices_b
                        SET trx_status_code = 'ERROR'
                        WHERE id = lx_taiv_rec.id;
                        FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating Billing Transactions.');
                    ELSE
                        UPDATE okl_strm_elements
                        SET date_billed = SYSDATE
                        WHERE id = adj_streams_rec.sel_id;
                    END IF;


                END IF;
            END IF;
        END LOOP;
    END LOOP;


      ------------------------------------------------------------
      -- End processing
      ------------------------------------------------------------


      Okl_Api.END_ACTIVITY (
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data);


  EXCEPTION


      ------------------------------------------------------------
      -- Exception handling
      ------------------------------------------------------------


      WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'Okl_Api.G_RET_STS_ERROR',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


      WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXP) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'Okl_Api.G_RET_STS_UNEXP_ERROR',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


      WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'OTHERS',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


  END ON_ACCT_Bill_adjustments;




  PROCEDURE CM_Bill_adjustments_conc (
            errbuf  OUT NOCOPY VARCHAR2
           ,retcode OUT NOCOPY NUMBER
           ,p_contract_number  IN VARCHAR2
  ) IS


  l_api_version   NUMBER := 1;
  lx_msg_count     NUMBER;
  l_from_bill_date   DATE;
  l_to_bill_date     DATE;
  l_count1          NUMBER :=0;
  l_count2          NUMBER :=0;
  l_count           NUMBER :=0;
  I                 NUMBER :=0;
  l_msg_index_out   NUMBER :=0;
  lx_msg_data    VARCHAR2(450);
  lx_return_status  VARCHAR2(1);


  l_request_id      NUMBER;


   CURSOR req_id_csr IS
        SELECT
          DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID)
        FROM dual;


   CURSOR txd_cnt_succ_csr( p_req_id NUMBER ) IS
          SELECT count(*)
          FROM okl_trx_ar_invoices_v a,
               okl_txl_ar_inv_lns_v b,
               okl_txd_ar_ln_dtls_v c
          WHERE a.id = b.tai_id AND
                b.id = c.til_id_details AND
                a.trx_status_code = 'SUBMITTED' AND
                a.request_id = p_req_id ;


   CURSOR txd_cnt_err_csr( p_req_id NUMBER ) IS
          SELECT count(*)
          FROM okl_trx_ar_invoices_v a,
               okl_txl_ar_inv_lns_v b,
               okl_txd_ar_ln_dtls_v c
          WHERE a.id = b.tai_id AND
                b.id = c.til_id_details AND
                a.trx_status_code = 'ERROR' AND
                a.request_id = p_req_id ;


   l_succ_cnt    NUMBER;
   l_err_cnt     NUMBER;
BEGIN


   l_succ_cnt    := 0;
   l_err_cnt     := 0;


    -- Get the request Id
    l_request_id := NULL;
    OPEN  req_id_csr;
    FETCH req_id_csr INTO l_request_id;
    CLOSE req_id_csr;


    FND_FILE.PUT_LINE (FND_FILE.LOG, '**              *                 **');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Contract Number = ' ||p_contract_number);
    FND_FILE.PUT_LINE (FND_FILE.LOG, '**              *                 **');


    IF fnd_profile.value('OKL_APPLY_CM') IS NULL THEN
        -- On Account Credit Memo For Manual application


        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Profile OKL:Apply Billing Adjustment: NULL');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Create On-Invoice Credit Memo.');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Invoking OKL_REBOOK_CM_PVT.ON_ACCT_Bill_adjustments');
        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');


         ON_ACCT_Bill_adjustments (
                p_api_version   => l_api_version,
                p_init_msg_list => Okl_Api.G_FALSE,
                x_return_status => lx_return_status,
                x_msg_count     => lx_msg_count,
                x_msg_data      => errbuf,
                p_contract_number => p_contract_number
         );


    ELSIF (fnd_profile.value('OKL_APPLY_CM') = 'SEEDED') THEN
        -- Development Logic
        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Profile OKL:Apply Billing Adjustment: SEEDED');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Create On-Invoice and On-Acct Credit Memo.');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Invoking OKL_REBOOK_CM_PVT.CM_Bill_adjustments');
        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');


         CM_Bill_adjustments (
                p_api_version   => l_api_version,
                p_init_msg_list => Okl_Api.G_FALSE,
                x_return_status => lx_return_status,
                x_msg_count     => lx_msg_count,
                x_msg_data      => errbuf,
                p_contract_number => p_contract_number
         );


    ELSIF (fnd_profile.value('OKL_APPLY_CM') = 'CUSTOM') THEN


        -- Custom Logic
        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Profile OKL:Apply Billing Adjustment: CUSTOM');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Create Credit Memo using CUSTOM Logic.');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Invoking OKL_REBOOK_CM_PVT.CUSTOM_CM_Bill_adjustments');
        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');


         OKL_CUSTOM_PVT.CUSTOM_CM_Bill_adjustments (
                p_api_version   => l_api_version,
                p_init_msg_list => Okl_Api.G_FALSE,
                x_return_status => lx_return_status,
                x_msg_count     => lx_msg_count,
                x_msg_data      => errbuf,
                p_contract_number => p_contract_number
         );


    ELSE
        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Profile OKL:Apply Billing Adjustment: '||fnd_profile.value('OKL_APPLY_CM'));
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Acceptable Values are: NULL, SEEDED OR CUSTOM.');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Exiting Procedure ..');
        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');
    END IF;


     -- Success Count
     OPEN   txd_cnt_succ_csr( l_request_id );
     FETCH  txd_cnt_succ_csr INTO l_succ_cnt;
     CLOSE  txd_cnt_succ_csr;


     -- Error Count
     OPEN   txd_cnt_err_csr( l_request_id );
     FETCH  txd_cnt_err_csr INTO l_err_cnt;
     CLOSE  txd_cnt_err_csr;


    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Automatic Adjustments for Rebooked Contracts');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date: '||SYSDATE||' Request Id: '||l_request_id);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
'***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'PARAMETERS');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Contract Number = '
||p_contract_number);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
'***********************************************');


    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Number of Successful Stream Lines in Okl_Txd_Ar_Ln_Dtls_b = '||l_succ_cnt);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Number of Errored Stream Lines in Okl_Txd_Ar_Ln_Dtls_b = '||l_err_cnt);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Detailed Error Messages For Each Records and Columns from TAPI ');


    IF lx_msg_count > 0 THEN
       FOR i IN 1..lx_msg_count LOOP
            fnd_msg_pub.get (p_msg_index => i,
                       p_encoded => 'F',
                       p_data => lx_msg_data,
                       p_msg_index_out => l_msg_index_out);


            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,TO_CHAR(i) || ': ' ||
lx_msg_data);
      END LOOP;
    END IF;
   EXCEPTION
      WHEN OTHERS THEN
          NULL ;
   END CM_Bill_adjustments_conc;


  ------------------------------------------------------------------
  -- Procedure CM_Bill_adjustments to create adjustments to
  -- Rebooked and unfulfilled invoices
  ------------------------------------------------------------------


   PROCEDURE CM_Bill_adjustments
      (p_api_version          IN  NUMBER
      ,p_init_msg_list      IN  VARCHAR2      DEFAULT OKC_API.G_FALSE
      ,x_return_status      OUT NOCOPY VARCHAR2
      ,x_msg_count            OUT NOCOPY NUMBER
      ,x_msg_data             OUT NOCOPY VARCHAR2
      ,p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
      ,p_rebook_adj_tbl      IN  rebook_adj_tbl_type
    ) IS


      ------------------------------------------------------------
      -- Get Unpaid Invoices For the Contract Stream
      ------------------------------------------------------------
    -- Bug 6802801
    -- Bug# 7720775: Changed API call to
    --               OKL_BILLING_UTIL_PVT.INV_LN_AMT_REMAINING_W_INCTAX
    --               Added parameter p_sty_id
    CURSOR unpaid_invs_csr ( p_khr_id NUMBER, p_kle_id NUMBER, p_sty_id NUMBER  )  IS
            SELECT
            tai.date_entered          date_billed,
            khr.id                    khr_id,
            TRUNC (tai.date_invoiced) bill_date,
            tld.kle_id                kle_id,
            tld.sel_id                sel_id,
            tld.sty_id                sty_id,
            khr.contract_number       contract_number,
            khr.currency_code         currency_code,
            khr.authoring_org_id      authoring_org_id,
            sty.code                  comments,
            sty.taxable_default_yn    taxable_default_yn,
            OKL_BILLING_UTIL_PVT.INV_LN_AMT_ORIG_WOTAX
            (tldv.CUSTOMER_TRX_ID, tldv.CUSTOMER_TRX_LINE_ID) amount,
            khr.sts_code              sts_code,
            tld.id                    tld_id,
         OKL_BILLING_UTIL_PVT.INV_LN_AMT_REMAINING_W_INCTAX
         (tldv.CUSTOMER_TRX_ID, tldv.CUSTOMER_TRX_LINE_ID) amount_due_remaining,
            PS.trx_number             trx_number,
            PS.class,
            PS.TERMS_SEQUENCE_NUMBER
            FROM
                  okl_strm_type_b               sty,
                  okc_k_headers_b               khr,
                  okl_k_headers                 khl,
                  okc_k_lines_b                 kle,
                  okc_statuses_b                khs,
                  okc_statuses_b                kls,
                  okl_txd_ar_ln_dtls_v          tld,
                  okl_txl_ar_inv_lns_v          til,
                  okl_trx_ar_invoices_v         tai,
                  okl_bpd_tld_ar_lines_v        tldv,
                  AR_PAYMENT_SCHEDULES_ALL      PS
            WHERE sty.billable_yn          = 'Y'
            AND   tld.sty_id               = p_sty_id
            AND   tld.sty_id               = sty.id
            AND   khr.id                   = p_khr_id
            AND   khr.scs_code             IN ('LEASE', 'LOAN')
            AND   khr.sts_code             IN ( 'BOOKED','EVERGREEN')
            AND   tld.kle_id               = p_kle_id
            AND   tld.kle_id               = kle.id
            AND   khl.id                   = khr.id
            AND   khl.deal_type            IS NOT NULL
            AND   khs.code                 = khr.sts_code
            AND   khs.ste_code             = 'ACTIVE'
            AND   kls.code          (+)    = kle.sts_code
            AND   NVL (kls.ste_code, 'ACTIVE')  IN ('ACTIVE', 'TERMINATED')
            AND   tai.trx_status_code      = 'PROCESSED'
            AND   tai.id                   = til.tai_id
            AND   til.id                   = tld.til_id_details
            AND   tldv.tld_id              = tld.id
            AND   tldv.khr_id              = khr.id
            AND   tldv.customer_trx_id     = ps.customer_trx_id
            AND   tldv.customer_trx_id IS NOT NULL
            AND   PS.TERMS_SEQUENCE_NUMBER = 1
            AND   PS.amount_due_remaining > 0
            ORDER BY 1, 2, 3;

    --Bug 5000886 : Removed reference of stream tables in the following cursor
    -- Bug 6328168: Modified unpaid_invs_csr cursor

   --Bug 5000886: End


      ------------------------------------------------------------
      -- Get trx_id for Invoice
      ------------------------------------------------------------
      CURSOR c_trx_id( p_sob_id   NUMBER, p_org_id   NUMBER ) IS
         SELECT  ID1
         FROM OKX_CUST_TRX_TYPES_V
         WHERE name = 'Invoice-OKL'              AND
                   set_of_books_id = p_sob_id       AND
                   org_id                  = p_org_id;


      /* -- commented out since this cursor never used - bug#5484903
      ------------------------------------------------------------
      -- Get trx_id for Credit Memo
      ------------------------------------------------------------
      CURSOR c_trx_id1( p_sob_id   NUMBER, p_org_id   NUMBER ) IS
         SELECT  ID1
         FROM OKX_CUST_TRX_TYPES_V
         WHERE name = 'Credit Memo-OKL'         AND
                   set_of_books_id = p_sob_id       AND
                   org_id                  = p_org_id; */


      ------------------------------------------------------------
      -- Initialise constants
      ------------------------------------------------------------


      l_def_desc      CONSTANT VARCHAR2(30)      := 'Regular Stream Billing';
      l_line_code     CONSTANT VARCHAR2(30)      := 'LINE';
      l_init_status      CONSTANT VARCHAR2(30)      := 'ENTERED';
      l_final_status      CONSTANT VARCHAR2(30)      := 'PROCESSED';
      l_trx_type_name      CONSTANT VARCHAR2(30)      := 'Billing';
      l_trx_type_lang      CONSTANT VARCHAR2(30)      := 'US';
      l_date_entered      CONSTANT DATE               := SYSDATE;
      l_zero_amount      CONSTANT NUMBER             := 0;
      l_first_line      CONSTANT NUMBER             := 1;
      l_line_step     CONSTANT NUMBER                := 1;
      l_def_no_val      CONSTANT NUMBER             := -1;
      l_null_kle_id      CONSTANT NUMBER             := -2;


      ------------------------------------------------------------
      -- Declare records: i - insert, u - update, r - result
      ------------------------------------------------------------


      -- Transaction headers
      i_taiv_rec      okl_tai_pvt.taiv_rec_type;
      u_taiv_rec      okl_tai_pvt.taiv_rec_type;
      lx_taiv_rec     okl_tai_pvt.taiv_rec_type;
       l_init_taiv_rec       okl_tai_pvt.taiv_rec_type;
      r_taiv_rec      Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;


      -- Transaction lines
      i_tilv_rec      okl_til_pvt.tilv_rec_type;
        i_tilv_tbl          okl_til_pvt.tilv_tbl_type;
      u_tilv_rec      okl_til_pvt.tilv_rec_type;
      lx_tilv_tbl     okl_til_pvt.tilv_tbl_type;
      l_init_tilv_rec       okl_til_pvt.tilv_rec_type;
      r_tilv_rec      okl_til_pvt.tilv_rec_type;


      -- Transaction line details
      i_tldv_rec      okl_tld_pvt.tldv_rec_type;
        i_tldv_tbl          okl_tld_pvt.tldv_tbl_type;
      u_tldv_rec      okl_tld_pvt.tldv_rec_type;
      lx_tldv_tbl     okl_tld_pvt.tldv_tbl_type;
    l_init_tldv_rec         okl_tld_pvt.tldv_rec_type;
      r_tldv_rec      okl_tld_pvt.tldv_rec_type;


      -- Ext Transaction Header
      i_xsiv_rec          Okl_Ext_Sell_Invs_Pub.xsiv_rec_type;
    l_init_xsiv_rec     Okl_Ext_Sell_Invs_Pub.xsiv_rec_type;
      r_xsiv_rec          Okl_Ext_Sell_Invs_Pub.xsiv_rec_type;


      -- Ext Transaction Lines
      i_xlsv_rec          Okl_Xtl_Sell_Invs_Pub.xlsv_rec_type;
    l_init_xlsv_rec     Okl_Xtl_Sell_Invs_Pub.xlsv_rec_type;
      r_xlsv_rec          Okl_Xtl_Sell_Invs_Pub.xlsv_rec_type;


      -- Ext Transaction Details
      i_esdv_rec          Okl_Xtd_Sell_Invs_Pub.esdv_rec_type;
    l_init_esdv_rec     Okl_Xtd_Sell_Invs_Pub.esdv_rec_type;
      r_esdv_rec          Okl_Xtd_Sell_Invs_Pub.esdv_rec_type;


      -- Stream elements
      u_selv_rec          Okl_Streams_Pub.selv_rec_type;
      l_init_selv_rec       Okl_Streams_Pub.selv_rec_type;
      r_selv_rec          Okl_Streams_Pub.selv_rec_type;


      ------------------------------------------------------------
      -- Declare local variables used in the program
      ------------------------------------------------------------


      l_khr_id      okl_trx_ar_invoices_v.khr_id%TYPE;
      l_bill_date      okl_trx_ar_invoices_v.date_invoiced%TYPE;
      l_trx_type      okl_trx_ar_invoices_v.try_id%TYPE;
      l_kle_id      okl_txl_ar_inv_lns_v.kle_id%TYPE;


      l_line_number      okl_txl_ar_inv_lns_v.line_number%TYPE;
      l_detail_number      okl_txd_ar_ln_dtls_v.line_detail_number%TYPE;


      l_header_amount      okl_trx_ar_invoices_v.amount%TYPE;
      l_line_amount      okl_txl_ar_inv_lns_v.amount%TYPE;


      l_header_id      okl_trx_ar_invoices_v.id%TYPE;
      l_line_id      okl_txl_ar_inv_lns_v.id%TYPE;


      ------------------------------------------------------------
      -- Declare variables required by APIs
      ------------------------------------------------------------


      l_api_version      CONSTANT NUMBER := 1;
      l_api_name      CONSTANT VARCHAR2(30)  := 'BILL_STREAMS';
      l_return_status      VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;


      ------------------------------------------------------------
      -- Declare variables to call Accounting Engine.
      ------------------------------------------------------------
      p_bpd_acc_rec
Okl_Acc_Call_Pub.bpd_acc_rec_type;
      l_init_bpd_acc_rec
Okl_Acc_Call_Pub.bpd_acc_rec_type;




      ------------------------------------------------------------
      -- Variables for Error Processing and Committing Stream Billing
    -- Transactions
      ------------------------------------------------------------


    l_error_status               VARCHAR2(1);
    l_error_message              VARCHAR2(2000);
    l_trx_status_code            Okl_trx_ar_invoices_v.trx_status_code%TYPE;


    -- To enforce commit frequency
    l_commit_cnt                 NUMBER;
    l_max_commit_cnt             NUMBER := 500;


    -- For currecy precision rounded amount
    l_ste_amount                 okl_strm_elements.amount%type;
    l_curr_code                  okc_k_headers_b.currency_code%TYPE;
      ------------------------------------------------------------
      -- For errors in Stream Elements Table
      ------------------------------------------------------------


    l_distr_cnt             NUMBER;


    -------------------------------------------------------------------------
    -- Account Builder Code
    -------------------------------------------------------------------------
        l_acc_gen_primary_key_tbl
Okl_Account_Dist_Pub.acc_gen_primary_key;
        l_init_acc_gen_primary_key_tbl
Okl_Account_Dist_Pub.acc_gen_primary_key;




    TYPE sel_err_rec_type IS RECORD (
            sel_id              NUMBER,
            tld_id              NUMBER,
            xsi_id              NUMBER,
                  bill_date           DATE,
                  contract_number     okc_k_headers_b.contract_number%type,
                  stream_name         okl_strm_type_v.name%type,
                  amount              okl_strm_elements.amount%type,
            error_message       Varchar2(2000)
      );


    TYPE sel_err_tbl_type IS TABLE OF sel_err_rec_type
            INDEX BY BINARY_INTEGER;


    sel_error_log_table         sel_err_tbl_type;
    l_init_sel_table            sel_err_tbl_type;


    l_sel_tab_index             NUMBER;


      ------------------------------------------------------------
      -- Cursors for Rule based values
      ------------------------------------------------------------


    -- Local Vars for Rule based values --EXT
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
    l_rct_method_code             AR_RECEIPT_CLASSES.CREATION_METHOD_CODE%TYPE;
    l_asst_tax                OKC_RULES_B.rule_information1%TYPE;
    l_asst_line_tax           OKC_RULES_B.rule_information1%TYPE;
    l_product_id              okl_k_headers_full_v.pdt_id%TYPE;


      -----------------------------------------
      -- Local Variables for Rebook Credit Memo
      -- amounts
      -----------------------------------------
      l_bill_ajst_amt      NUMBER;
      lx_tai_id            NUMBER;
      l_credit_amount      NUMBER;


      l_err_status         VARCHAR2(1);


      TYPE err_rec_type IS RECORD (
           tai_id                  NUMBER,
         trx_number     ra_customer_trx_all.trx_number%TYPE,
         amount         NUMBER
        );


      TYPE err_tbl_type IS TABLE OF err_rec_type
           INDEX BY BINARY_INTEGER;


        err_tbl                        err_tbl_type;
        l_init_err_tbl           err_tbl_type;
        err_idx                        NUMBER;


      l_commit_cntr          NUMBER;
      l_credit_date          DATE;
      i                      NUMBER := 0;
      l_rebook_adj_rec        rebook_adj_rec_type;


BEGIN


      ------------------------------------------------------------
      -- Start processing
      ------------------------------------------------------------


      x_return_status := Okl_Api.G_RET_STS_SUCCESS;


      l_return_status := Okl_Api.START_ACTIVITY(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_init_msg_list      => p_init_msg_list,
            l_api_version      => l_api_version,
            p_api_version      => p_api_version,
            p_api_type  => '_PVT',
            x_return_status      => l_return_status);


      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;


    ------------------------------------------------------------
    -- Process Adjustments
    ------------------------------------------------------------
    IF (p_rebook_adj_tbl.COUNT > 0) THEN
      i := p_rebook_adj_tbl.FIRST;
      LOOP
        l_rebook_adj_rec := p_rebook_adj_tbl(i);
            -------------------------------------------
            -- Create adjustment Invoice if amount > 0
            -------------------------------------------
            IF l_rebook_adj_rec.adjusted_amount > 0 THEN


               ------------------------------------------------
               -- Initialize the error processing variables
               ------------------------------------------------
               l_err_status               := 'S';
             err_tbl                       := l_init_err_tbl;
             err_idx                       := 0;


               i_taiv_rec                 := l_init_taiv_rec;


               i_taiv_rec.trx_status_code := 'SUBMITTED';
               i_taiv_rec.khr_id          := l_rebook_adj_rec.khr_id;
               i_taiv_rec.amount          := l_rebook_adj_rec.adjusted_amount;


               l_trx_type                 := get_trx_type ('Billing', 'US');
                     i_taiv_rec.try_id          := l_trx_type;
                     IF l_rebook_adj_rec.date_invoiced IS NULL THEN
                 i_taiv_rec.date_invoiced   := SYSDATE;
               ELSE
                 i_taiv_rec.date_invoiced   := l_rebook_adj_rec.date_invoiced;
               END IF;
               i_taiv_rec.date_entered    := SYSDATE;
               i_taiv_rec.description     := 'Rebook Adjustment Invoice';
               i_taiv_rec.okl_source_billing_trx := 'REBOOK';


              i_tilv_rec                        := l_init_tilv_rec;
              i_tilv_rec.amount                 :=
l_rebook_adj_rec.adjusted_amount;
              i_tilv_rec.kle_id                 := l_rebook_adj_rec.kle_id;
              i_tilv_rec.inv_receiv_line_code      := l_line_code;
              i_tilv_rec.line_number        := 1;
              i_tilv_rec.txl_ar_line_number     := 1;
              i_tilv_rec.description            := 'Rebook Adjustment Invoice';
              i_tilv_rec.date_bill_period_start :=
l_rebook_adj_rec.date_invoiced;
              i_tilv_rec.sty_id                 := l_rebook_adj_rec.sty_id; -- 6328168


              i_tilv_tbl(1)     := i_tilv_rec;


               --rkuttiya R12 B Billing Architecture
               --call to central Billing API to create Billing transactions and accounting distributions
                OKL_INTERNAL_BILLING_PVT.create_billing_trx( p_api_version
=> l_api_version
                                                             ,p_init_msg_list
=> p_init_msg_list
                                                             ,x_return_status
=> l_return_status
                                                             ,x_msg_count
=> x_msg_count
                                                             ,x_msg_data
=> x_msg_data
                                                             ,p_taiv_rec
=> i_taiv_rec
                                                             ,p_tilv_tbl
=> i_tilv_tbl
                                                             ,p_tldv_tbl
=> i_tldv_tbl
                                                             ,x_taiv_rec
=> lx_taiv_rec
                                                             ,x_tilv_tbl
=> lx_tilv_tbl
                                                             ,x_tldv_tbl
=> lx_tldv_tbl);




                    ----------------------------------------
                    -- Record tai_id for error processing
                    ----------------------------------------
                    err_idx                     := err_idx + 1;
                    err_tbl(err_idx).tai_id     := lx_taiv_rec.id;
                    err_tbl(err_idx).trx_number := NULL;
                    err_tbl(err_idx).amount     := i_taiv_rec.amount;




                IF  (x_return_status = 'S' ) THEN
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Accounting Distributions Created.');
                ELSE
                    l_err_status  := 'E';
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating Accounting Distributions.');
                END IF;


                IF (x_return_status <> 'S' ) THEN
                    UPDATE okl_trx_ar_invoices_b
                    SET trx_status_code = 'ERROR'
                    WHERE id = lx_taiv_rec.id;
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating Accounting Distributions.');
                ELSE
                    ----------------------------------------------
                    -- Check if there was ever an error and update
                    -- accordingly
                    ----------------------------------------------
                    IF l_err_status = 'E' THEN
                        -----------------------------------------
                        -- Flag all TAI records for this bill adj
                        -- as error
                        -----------------------------------------
                        FOR j in err_tbl.FIRST..err_tbl.LAST LOOP
                               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Reversing Invoice for '||err_tbl(j).amount);


                               UPDATE okl_trx_ar_invoices_b
                               SET trx_status_code = 'ERROR'
                               WHERE id = err_tbl(j).tai_id;
                        END LOOP;
                    END IF;
                END IF;


            ELSE -- (create Invoice specific credit memo)


                ------------------------------------------------
                -- Initialize the error processing variables
                ------------------------------------------------
                l_err_status              := 'S';
                  err_tbl                   := l_init_err_tbl;
                  err_idx                           := 0;


                l_bill_ajst_amt := l_rebook_adj_rec.adjusted_amount;

                --Bug# 7720775: Added parameter sty_id
                FOR unpaid_invs_rec IN unpaid_invs_csr (
                                        l_rebook_adj_rec.khr_id,
                                        l_rebook_adj_rec.kle_id,
                                        l_rebook_adj_rec.sty_id ) LOOP


                    IF l_bill_ajst_amt >= 0 THEN
                       EXIT;
                    END IF;


                    r_taiv_rec      := l_init_taiv_rec;
                    l_credit_amount := 0;

                   --Bug# 7720775: Added check for Invoice Balance > 0
                   IF (unpaid_invs_rec.amount_due_remaining > 0) THEN

                    IF ( abs(l_bill_ajst_amt) > unpaid_invs_rec.amount_due_remaining )
                    THEN
                            l_credit_amount := unpaid_invs_rec.amount_due_remaining;
                    ELSE
                            l_credit_amount := abs(l_bill_ajst_amt);
                    END IF;


                    -- ----------------------------
                    -- Credit date
                    -- ----------------------------
                    l_credit_date := NULL;
                    IF unpaid_invs_rec.bill_date > SYSDATE THEN
                        l_credit_date := unpaid_invs_rec.bill_date;
                    ELSE
                        l_credit_date := SYSDATE;
                    END IF;





                    okl_credit_memo_pub.insert_request(
                                            p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            p_tld_id        => unpaid_invs_rec.tld_id,
                                            p_credit_amount => (-1*l_credit_amount),
                                            p_credit_sty_id => NULL,
                                            p_credit_desc   => 'Rebook Adjustment Credit Memo',
                                            p_credit_date   => l_credit_date,
                                            p_try_id        => NULL,
                                            p_transaction_source=>'REBOOK', -- Bug 6328168
                                            x_tai_id        => lx_tai_id,
                                            x_taiv_rec      => r_taiv_rec,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data);


                     ----------------------------------------
                     -- Record tai_id for error processing
                     ----------------------------------------
                     err_idx                     := err_idx + 1;
                     err_tbl(err_idx).tai_id     := lx_tai_id;
                     err_tbl(err_idx).trx_number := unpaid_invs_rec.trx_number;
                     err_tbl(err_idx).amount     := l_credit_amount;


                     IF l_return_status = 'S' THEN
                        FND_FILE.PUT_LINE (FND_FILE.LOG,'Credited AR Invoice: '
                                           ||unpaid_invs_rec.trx_number
                                           ||' for: '||l_credit_amount);
                        l_bill_ajst_amt := l_bill_ajst_amt +
unpaid_invs_rec.amount_due_remaining;
                     ELSE
                        l_err_status  := 'E';


                        FND_FILE.PUT_LINE (FND_FILE.LOG,'ERROR Crediting AR Invoice: '
                                           ||unpaid_invs_rec.trx_number
                                           ||' for: '||l_credit_amount);
                        EXIT;
                     END IF;
                   END IF;
                   --Bug# 7720775: Added check for Invoice Balance > 0
                END LOOP;


                -- If there was more credit than Invoices could use,
                -- then, create an On-account CM
                IF l_bill_ajst_amt < 0 THEN


                    i_taiv_rec                 := l_init_taiv_rec;


                    i_taiv_rec.trx_status_code := 'SUBMITTED';
                    i_taiv_rec.khr_id          := l_rebook_adj_rec.khr_id;
                    i_taiv_rec.amount          := l_bill_ajst_amt;


                    l_trx_type                 := get_trx_type ('Credit Memo', 'US');
                    i_taiv_rec.try_id          := l_trx_type;
		    i_taiv_rec.date_invoiced   := l_rebook_adj_rec.date_invoiced;
                    i_taiv_rec.date_entered    := SYSDATE;
                    i_taiv_rec.description     := 'Rebook Adjustment Invoice';
                    i_taiv_rec.okl_source_billing_trx := 'REBOOK';


                    i_tilv_rec                        := l_init_tilv_rec;
                    i_tilv_rec.amount                 := l_bill_ajst_amt;
                    i_tilv_rec.kle_id                 := l_rebook_adj_rec.kle_id;
                    i_tilv_rec.inv_receiv_line_code      := l_line_code;
                    i_tilv_rec.line_number        := 1;
                    i_tilv_rec.txl_ar_line_number     := 1;
                    i_tilv_rec.date_bill_period_start := l_rebook_adj_rec.date_invoiced;
                    i_tilv_rec.sty_id                 := l_rebook_adj_rec.sty_id; -- 6328168


                    i_tilv_tbl(1) := i_tilv_rec;


                 --rkuttiya R12 B Billing Architecture commented out details record structure, as not required to pass here
                 -- since sel id is NULL
                    /*i_tldv_rec  := l_init_tldv_rec;


                    i_tldv_rec.amount             := l_bill_ajst_amt;
                    i_tldv_rec.line_detail_number := 1;
                    i_tldv_rec.sty_id             := l_rebook_adj_rec.sty_id;
                    i_tldv_rec.sel_id             := NULL;


                    i_tldv_tbl(1) := i_tldv_rec; */



                  --rkuttiya R12 B Billing Architecture
             -- call central Billing API to create billing transactions and accounting distributions
                 OKL_INTERNAL_BILLING_PVT.create_billing_trx( p_api_version
=> l_api_version
                                                             ,p_init_msg_list
=> p_init_msg_list
                                                             ,x_return_status
=> l_return_status
                                                             ,x_msg_count
=> x_msg_count
                                                             ,x_msg_data
=> x_msg_data
                                                             ,p_taiv_rec
=> i_taiv_rec
                                                             ,p_tilv_tbl
=> i_tilv_tbl
                                                             ,p_tldv_tbl
=> i_tldv_tbl
                                                             ,x_taiv_rec
=> lx_taiv_rec
                                                             ,x_tilv_tbl
=> lx_tilv_tbl
                                                             ,x_tldv_tbl
=> lx_tldv_tbl);




                    ----------------------------------------
                    -- Record tai_id for error processing
                    ----------------------------------------
                    err_idx                     := err_idx + 1;
                    err_tbl(err_idx).tai_id     := lx_taiv_rec.id;
                    err_tbl(err_idx).trx_number := NULL;
                    err_tbl(err_idx).amount     := i_taiv_rec.amount;


                    IF  (x_return_status = 'S' ) THEN
                        FND_FILE.PUT_LINE (FND_FILE.LOG, 'On Account Accounting Distributions Created.');
                    ELSE
                        l_err_status  := 'E';
                        FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating On Account Accounting Distributions.');
                    END IF;


                END IF; -- More Credit remaining than needed


                --IF (x_return_status = 'S' ) THEN
                --    UPDATE okl_strm_elements
                --    SET date_billed = SYSDATE
                --    WHERE id = adj_streams_rec.sel_id;
                --END IF;
                IF (x_return_status <> 'S' ) THEN
                    IF l_err_status  = 'E' THEN
                        -----------------------------------------
                        -- Flag all TAI records for this bill adj
                        -- as error
                        -----------------------------------------
                        FOR j in err_tbl.FIRST..err_tbl.LAST LOOP
                               IF err_tbl(j).trx_number IS NOT NULL THEN
                                  FND_FILE.PUT_LINE (FND_FILE.LOG, 'Reversing Credited Invoice '
                                  ||err_tbl(j).trx_number
                                  ||' for amount '
                                  ||err_tbl(j).amount);
                               ELSE
                                  FND_FILE.PUT_LINE (FND_FILE.LOG, 'Reversing Credit for amount '
                                  ||err_tbl(j).amount);
                               END IF;


                               UPDATE okl_trx_ar_invoices_b
                               SET trx_status_code = 'ERROR'
                               WHERE id = err_tbl(j).tai_id;
                        END LOOP;
                    END IF;


                    --UPDATE okl_trx_ar_invoices_b
                    --SET trx_status_code = 'ERROR'
                    --WHERE id = x_taiv_rec.id;
                    --FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating Accounting Distributions.');
                ELSE
                    IF l_err_status  = 'E' THEN
                        -----------------------------------------
                        -- Flag all TAI records for this bill adj
                        -- as error
                        -----------------------------------------
                        FOR j in err_tbl.FIRST..err_tbl.LAST LOOP
                               IF err_tbl(j).trx_number IS NOT NULL THEN
                                  FND_FILE.PUT_LINE (FND_FILE.LOG, 'Reversing Credited Invoice '
                                  ||err_tbl(j).trx_number
                                  ||' for amount '
                                  ||err_tbl(j).amount);
                               ELSE
                                  FND_FILE.PUT_LINE (FND_FILE.LOG, 'Reversing Credit for amount '
                                  ||err_tbl(j).amount);
                               END IF;


                               UPDATE okl_trx_ar_invoices_b
                               SET trx_status_code = 'ERROR'
                               WHERE id = err_tbl(j).tai_id;
                        END LOOP;
                    END IF;
                END IF;


            END IF;


        EXIT WHEN (i = p_rebook_adj_tbl.LAST);
        i := p_rebook_adj_tbl.NEXT(i);
      END LOOP;
    END IF;


    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT;
    END IF;


      ------------------------------------------------------------
      -- End processing
      ------------------------------------------------------------


      Okl_Api.END_ACTIVITY (
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data);




  EXCEPTION


      ------------------------------------------------------------
      -- Exception handling
      ------------------------------------------------------------


      WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'Okl_Api.G_RET_STS_ERROR',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


      WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXP) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'Okl_Api.G_RET_STS_UNEXP_ERROR',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


      WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'OTHERS',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


  END CM_Bill_adjustments;




  PROCEDURE CUSTOM_CM_Bill_adjustments
      (p_api_version          IN  NUMBER
      ,p_init_msg_list      IN  VARCHAR2
      ,x_return_status      OUT NOCOPY VARCHAR2
      ,x_msg_count            OUT NOCOPY NUMBER
      ,x_msg_data             OUT NOCOPY VARCHAR2
      ,p_rebook_adj_tbl      IN  rebook_adj_tbl_type
    ) IS
  BEGIN


      NULL;


  END CUSTOM_CM_Bill_adjustments;




  PROCEDURE ON_ACCT_Bill_adjustments
      (p_api_version          IN  NUMBER
      ,p_init_msg_list      IN  VARCHAR2
      ,x_return_status      OUT NOCOPY VARCHAR2
      ,x_msg_count            OUT NOCOPY NUMBER
      ,x_msg_data             OUT NOCOPY VARCHAR2
      ,p_rebook_adj_tbl      IN  rebook_adj_tbl_type
    )
  IS


      ------------------------------------------------------------
      -- Declare variables required by APIs
      ------------------------------------------------------------


      l_api_version      CONSTANT NUMBER := 1;
      l_api_name      CONSTANT VARCHAR2(30)  := 'BILL_STREAMS';
      l_return_status      VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;


      ------------------------------------------------------------
      -- Declare variables to call Accounting Engine.
      ------------------------------------------------------------
      p_bpd_acc_rec
Okl_Acc_Call_Pub.bpd_acc_rec_type;
      l_init_bpd_acc_rec
Okl_Acc_Call_Pub.bpd_acc_rec_type;


      ------------------------------------------------------------
      -- Declare records: i - insert, u - update, r - result
      ------------------------------------------------------------


      -- Transaction headers
      i_taiv_rec      okl_tai_pvt.taiv_rec_type;
      u_taiv_rec      okl_tai_pvt.taiv_rec_type;
      lx_taiv_rec     okl_tai_pvt.taiv_rec_type;
       l_init_taiv_rec       okl_tai_pvt.taiv_rec_type;
      r_taiv_rec      okl_tai_pvt.taiv_rec_type;


      -- Transaction lines
      i_tilv_rec      okl_til_pvt.tilv_rec_type;
        i_tilv_tbl          okl_til_pvt.tilv_tbl_type;
      u_tilv_rec      okl_til_pvt.tilv_rec_type;
      lx_tilv_tbl     okl_til_pvt.tilv_tbl_type;
      l_init_tilv_rec       okl_til_pvt.tilv_rec_type;
      r_tilv_rec      okl_til_pvt.tilv_rec_type;


      -- Transaction line details
      i_tldv_rec          okl_tld_pvt.tldv_rec_type;
        i_tldv_tbl              okl_tld_pvt.tldv_tbl_type;
      u_tldv_rec          okl_tld_pvt.tldv_rec_type;
      lx_tldv_tbl         okl_tld_pvt.tldv_tbl_type;
    l_init_tldv_rec             okl_tld_pvt.tldv_rec_type;
      r_tldv_rec          okl_tld_pvt.tldv_rec_type;


      l_trx_type          okl_trx_ar_invoices_v.try_id%TYPE;
      l_line_code         CONSTANT VARCHAR2(30)      := 'LINE';


    -----------------------------------------
    -- Local Variables for Rebook Credit Memo
    -- amounts
    -----------------------------------------
    l_bill_ajst_amt      NUMBER;
    i                    NUMBER := 0;
    l_rebook_adj_rec  rebook_adj_rec_type;


  BEGIN


      ------------------------------------------------------------
      -- Start processing
      ------------------------------------------------------------


      x_return_status := Okl_Api.G_RET_STS_SUCCESS;


      l_return_status := Okl_Api.START_ACTIVITY(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_init_msg_list      => p_init_msg_list,
            l_api_version      => l_api_version,
            p_api_version      => p_api_version,
            p_api_type  => '_PVT',
            x_return_status      => l_return_status);


      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;




FND_FILE.PUT_LINE (FND_FILE.LOG, 'Count'||p_rebook_adj_tbl.COUNT);
    ------------------------------------------------------------
    -- Process Adjustments
    ------------------------------------------------------------
    IF (p_rebook_adj_tbl.COUNT > 0) THEN
      i := p_rebook_adj_tbl.FIRST;
      LOOP
        l_rebook_adj_rec := p_rebook_adj_tbl(i);



            -------------------------------------------
            -- Create adjustment Invoice if amount > 0
            -------------------------------------------
            IF l_rebook_adj_rec.adjusted_amount > 0 THEN


               i_taiv_rec                 := l_init_taiv_rec;


               i_taiv_rec.trx_status_code := 'SUBMITTED';
               i_taiv_rec.khr_id          := l_rebook_adj_rec.khr_id;
               i_taiv_rec.amount          := l_rebook_adj_rec.adjusted_amount;


               l_trx_type                 := get_trx_type ('Billing', 'US');
               i_taiv_rec.try_id          := l_trx_type;
               IF l_rebook_adj_rec.date_invoiced IS NULL THEN
                  i_taiv_rec.date_invoiced   := SYSDATE;
               ELSE
                  i_taiv_rec.date_invoiced   := l_rebook_adj_rec.date_invoiced;
               END IF;
               i_taiv_rec.date_entered    := SYSDATE;
               i_taiv_rec.description     := 'Rebook Adjustment Invoice';
               i_taiv_rec.okl_source_billing_trx  := 'REBOOK';


              i_tilv_rec                        := l_init_tilv_rec;
              i_tilv_rec.amount                 := l_rebook_adj_rec.adjusted_amount;
              i_tilv_rec.kle_id                 := l_rebook_adj_rec.kle_id;
              i_tilv_rec.inv_receiv_line_code      := l_line_code;
              i_tilv_rec.line_number        := 1;
              i_tilv_rec.txl_ar_line_number     := 1;
              i_tilv_rec.description            := 'Rebook Adjustment Invoice';
              i_tilv_rec.date_bill_period_start := l_rebook_adj_rec.date_invoiced;

	          -- rmunjulu - added
              i_tilv_rec.sty_id                 := l_rebook_adj_rec.sty_id;

              i_tilv_tbl(1) := i_tilv_rec;


             --rkuttiya R12 B Billing Architecture commented details record structure since sel id is NULL


              /*i_tldv_rec  := l_init_tldv_rec;


              i_tldv_rec.amount             := l_rebook_adj_rec.adjusted_amount;
              i_tldv_rec.line_detail_number := 1;
              i_tldv_rec.sty_id             := l_rebook_adj_rec.sty_id;
              i_tldv_rec.sel_id             := NULL;


              i_tldv_tbl(1)  := i_tldv_rec; */


             --rkuttiya R12 B Billing Architecture
             -- call central Billing API to create transaction and accounting distributions
                 OKL_INTERNAL_BILLING_PVT.create_billing_trx( p_api_version
=> l_api_version
                                                             ,p_init_msg_list
=> p_init_msg_list
                                                             ,x_return_status
=> l_return_status
                                                             ,x_msg_count
=> x_msg_count
                                                             ,x_msg_data
=> x_msg_data
                                                             ,p_taiv_rec
=> i_taiv_rec
                                                             ,p_tilv_tbl
=> i_tilv_tbl
                                                             ,p_tldv_tbl
=> i_tldv_tbl
                                                             ,x_taiv_rec
=> lx_taiv_rec
                                                             ,x_tilv_tbl
=> lx_tilv_tbl
                                                             ,x_tldv_tbl
=> lx_tldv_tbl);


                IF  (x_return_status = 'S' ) THEN
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Billing Transactions Created.');
                ELSE
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating Billing Transactions.');
                END IF;


                IF (x_return_status <> 'S' ) THEN
                    UPDATE okl_trx_ar_invoices_b
                    SET trx_status_code = 'ERROR'
                    WHERE id = lx_taiv_rec.id;
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating Billing Transactions.');
                END IF;


            ELSE -- (create On-account credit memo)


                l_bill_ajst_amt := l_rebook_adj_rec.adjusted_amount;

                IF l_bill_ajst_amt < 0 THEN


                    i_taiv_rec                 := l_init_taiv_rec;


                    i_taiv_rec.trx_status_code := 'SUBMITTED';
                    i_taiv_rec.khr_id          := l_rebook_adj_rec.khr_id;
                    i_taiv_rec.amount          := l_bill_ajst_amt;


                    l_trx_type                 := get_trx_type ('Credit Memo', 'US');
                   i_taiv_rec.try_id          := l_trx_type;
                    i_taiv_rec.date_invoiced   := l_rebook_adj_rec.date_invoiced;
                    i_taiv_rec.date_entered    := SYSDATE;
                    i_taiv_rec.description     := 'Rebook Adjustment Invoice';
                    i_taiv_rec.okl_source_billing_trx := 'REBOOK';


                    i_tilv_rec                        := l_init_tilv_rec;
                    i_tilv_rec.amount                 := l_bill_ajst_amt;
                    i_tilv_rec.kle_id                 :=
l_rebook_adj_rec.kle_id;
                    i_tilv_rec.inv_receiv_line_code      := l_line_code;
                    i_tilv_rec.line_number            := 1;
                    i_tilv_rec.txl_ar_line_number := 1;
                    i_tilv_rec.description := 'Rebook Adjustment Invoice';
                    i_tilv_rec.date_bill_period_start :=
l_rebook_adj_rec.date_invoiced;
                    i_tilv_rec.sty_id                 := l_rebook_adj_rec.sty_id; -- bug 6328168



                    i_tilv_tbl(1)  := i_tilv_rec;




                 --rkuttiya R12 B Billing Architecture commented details record structure as sel id IS NULL
                   /* i_tldv_rec  := l_init_tldv_rec;


                    i_tldv_rec.amount             := l_bill_ajst_amt;
                    i_tldv_rec.line_detail_number := 1;
                    i_tldv_rec.sty_id             := l_rebook_adj_rec.sty_id;
                    i_tldv_rec.sel_id             := NULL;
                    i_tldv_rec.txl_ar_line_number := 1;



                    i_tldv_tbl(1)    :=  i_tldv_rec;*/



             --rkuttiya R12 B Billing Architecture
             -- call central Billing API to create transaction and accounting distributions
                 OKL_INTERNAL_BILLING_PVT.create_billing_trx( p_api_version
=> l_api_version
                                                             ,p_init_msg_list
=> p_init_msg_list
                                                             ,x_return_status
=> l_return_status
                                                             ,x_msg_count
=> x_msg_count
                                                             ,x_msg_data
=> x_msg_data
                                                             ,p_taiv_rec
=> i_taiv_rec
                                                             ,p_tilv_tbl
=> i_tilv_tbl
                                                             ,p_tldv_tbl
=> i_tldv_tbl
                                                             ,x_taiv_rec
=> lx_taiv_rec
                                                             ,x_tilv_tbl
=> lx_tilv_tbl
                                                             ,x_tldv_tbl
=> lx_tldv_tbl);



                    IF  (x_return_status = 'S' ) THEN
                        FND_FILE.PUT_LINE (FND_FILE.LOG, 'On Account Billing Transactions Created.');
                    ELSE
                        FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating On Account Billing Transactions.');
                    END IF;


                    IF (x_return_status <> 'S' ) THEN
                        UPDATE okl_trx_ar_invoices_b
                        SET trx_status_code = 'ERROR'
                        WHERE id = lx_taiv_rec.id;
                        FND_FILE.PUT_LINE (FND_FILE.LOG, 'ERROR Creating Billing Transactions');
                    END IF;


                END IF;
            END IF;


        EXIT WHEN (i = p_rebook_adj_tbl.LAST);
        i := p_rebook_adj_tbl.NEXT(i);
      END LOOP;
    END IF;


      ------------------------------------------------------------
      -- End processing
      ------------------------------------------------------------


      Okl_Api.END_ACTIVITY (
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data);


  EXCEPTION


      ------------------------------------------------------------
      -- Exception handling
      ------------------------------------------------------------


      WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'Okl_Api.G_RET_STS_ERROR',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


      WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXP) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'Okl_Api.G_RET_STS_UNEXP_ERROR',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


      WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'OTHERS',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


   END ON_ACCT_Bill_adjustments;




   PROCEDURE Rebook_Bill_adjustments
      (p_api_version          IN  NUMBER
      ,p_init_msg_list      IN  VARCHAR2      DEFAULT OKC_API.G_FALSE
      ,x_return_status      OUT NOCOPY VARCHAR2
      ,x_msg_count            OUT NOCOPY NUMBER
      ,x_msg_data           OUT NOCOPY VARCHAR2
      ,p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
      ,p_rebook_adj_tbl      IN  rebook_adj_tbl_type
    ) IS


    ------------------------------------------------------------
      -- Declare variables required by APIs
      ------------------------------------------------------------


      l_api_version      CONSTANT NUMBER := 1;
      l_api_name      CONSTANT VARCHAR2(30)  := 'BILL_STREAMS';
      l_return_status      VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;


   BEGIN




   ------------------------------------------------------------
      -- Start processing
      ------------------------------------------------------------


      x_return_status := Okl_Api.G_RET_STS_SUCCESS;


      l_return_status := Okl_Api.START_ACTIVITY(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_init_msg_list      => p_init_msg_list,
            l_api_version      => l_api_version,
            p_api_version      => p_api_version,
            p_api_type  => '_PVT',
            x_return_status      => l_return_status);


      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;


    ------------------------------------------------------------
    -- Check the profile value and call corresponding
    -- procedure with processing logic
    ------------------------------------------------------------


    IF fnd_profile.value('OKL_APPLY_CM') IS NULL THEN
        -- On Account Credit Memo For Manual application


        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Profile OKL:Apply Billing Adjustment: NULL');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Create On-Invoice Credit Memo.');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Invoking OKL_REBOOK_CM_PVT.ON_ACCT_Bill_adjustments');
        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');


         ON_ACCT_Bill_adjustments (
                p_api_version    => p_api_version,
                p_init_msg_list  => Okl_Api.G_FALSE,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_rebook_adj_tbl => p_rebook_adj_tbl
         );


    ELSIF (fnd_profile.value('OKL_APPLY_CM') = 'SEEDED') THEN
        -- Development Logic
        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Profile OKL:Apply Billing Adjustment: SEEDED');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Create On-Invoice and On-Acct Credit Memo.');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Invoking OKL_REBOOK_CM_PVT.CM_Bill_adjustments');
        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');


         CM_Bill_adjustments (
                p_api_version    => p_api_version,
                p_init_msg_list  => Okl_Api.G_FALSE,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_commit          => p_commit,
                p_rebook_adj_tbl => p_rebook_adj_tbl
         );


    ELSIF (fnd_profile.value('OKL_APPLY_CM') = 'CUSTOM') THEN


        -- Custom Logic
        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Profile OKL:Apply Billing Adjustment: CUSTOM');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Create Credit Memo using CUSTOM Logic.');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Invoking OKL_REBOOK_CM_PVT.CUSTOM_CM_Bill_adjustments');
        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');


         OKL_CUSTOM_PVT.CUSTOM_CM_Bill_adjustments (
                p_api_version    => p_api_version,
                p_init_msg_list  => Okl_Api.G_FALSE,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_rebook_adj_tbl => p_rebook_adj_tbl
         );


    ELSE
        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Profile OKL:Apply Billing Adjustment: '||fnd_profile.value('OKL_APPLY_CM'));
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Acceptable Values are: NULL, SEEDED OR CUSTOM.');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Exiting Procedure ..');
        FND_FILE.PUT_LINE (FND_FILE.LOG,
'******************************************');
    END IF;


      IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT;
    END IF;


   ------------------------------------------------------------
      -- End processing
      ------------------------------------------------------------


      Okl_Api.END_ACTIVITY (
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data);


  EXCEPTION


      ------------------------------------------------------------
      -- Exception handling
      ------------------------------------------------------------


      WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'Okl_Api.G_RET_STS_ERROR',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


      WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXP) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'Okl_Api.G_RET_STS_UNEXP_ERROR',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


      WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS) => '||SQLERRM);
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
                              p_api_name  => l_api_name,
                              p_pkg_name  => G_PKG_NAME,
                              p_exc_name  => 'OTHERS',
                              x_msg_count => x_msg_count,
                              x_msg_data  => x_msg_data,
                              p_api_type  => '_PVT');


   END Rebook_Bill_adjustments;


END OKL_REBOOK_CM_PVT;

/
