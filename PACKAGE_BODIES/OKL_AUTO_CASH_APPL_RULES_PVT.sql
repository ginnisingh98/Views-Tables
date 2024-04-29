--------------------------------------------------------
--  DDL for Package Body OKL_AUTO_CASH_APPL_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AUTO_CASH_APPL_RULES_PVT" AS
/* $Header: OKLRACUB.pls 120.34.12010000.5 2010/06/03 10:01:34 sosharma ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

 --asawanka added for llca start
  PROCEDURE log_debug(p_message  IN varchar2)
  IS
  BEGIN
--    IF (is_debug_statement_on) THEN
--         dbms_output.put_line(p_message);
         --okl_debug_pub.LogMessage(p_message,l_level_statement,'Y');
 --   END IF;
 null;
  END log_debug;
  --asawanka added for llca end

--Begin - varangan - receipts project
---------------------------------------------------------------------------
-- PROCEDURE Cash Application Rules for AR Invoice Number
---------------------------------------------------------------------------
/*Description:  This procedure accepts AR invoice number as a primary input parameter
                and process the cash application rule logic based on the
                way of contracts grouped together under this AR invoice.
IN Parameters:
                p_customer_num  - Holds the Customer Number
                p_arinv_number  - AR Invoice Number
                p_currency_code - Receipt Currency Code
                p_check_number  - Check Number
                p_rcpt_amount   - Receipt Number
                p_arinv_id      - AR Invoice Id
                p_org_id        - Operating Unit

OUT Parameter
                x_appl_tbl  - Holds the receipt amount split up based on the cash application rules
                              to be applied on each invoice line.

*/
PROCEDURE auto_cashapp_for_arinv (
                                        p_api_version        IN  NUMBER
                                        ,p_init_msg_list     IN  VARCHAR2  DEFAULT Okc_Api.G_FALSE
                                        ,x_return_status     OUT NOCOPY VARCHAR2
                                        ,x_msg_count         OUT NOCOPY NUMBER
                                        ,x_msg_data          OUT NOCOPY VARCHAR2
                                        ,p_customer_num      IN  VARCHAR2  DEFAULT NULL
                                        ,p_arinv_number      IN  VARCHAR2  DEFAULT NULL
                                        ,p_currency_code     IN  VARCHAR2
                                        ,p_amount_app_to     IN  NUMBER DEFAULT NULL
                                        ,p_amount_app_from   IN  NUMBER DEFAULT NULL
                                        ,p_inv_to_rct_rate   IN  NUMBER DEFAULT NULL
                                        ,p_receipt_date      IN  DATE
                                        ,p_arinv_id          IN  NUMBER DEFAULT NULL
                                        ,p_org_id            IN Number
                                        ,x_appl_tbl          OUT NOCOPY okl_appl_dtls_tbl_type
                                        ,x_onacc_amount      OUT NOCOPY NUMBER
                                        ,x_unapply_amount    OUT NOCOPY NUMBER
                                    ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

  l_inv_ref             VARCHAR2(120) := p_arinv_number;
  l_org_id              Number :=p_org_id;
  l_currency_code       VARCHAR2(45)  := p_currency_code;
  l_amount_app_from     NUMBER            := p_amount_app_from;
  l_amount_app_to       NUMBER            := p_amount_app_to;
  l_inv_to_rct_rate     NUMBER            := p_inv_to_rct_rate;
  l_inv_curr_Code       VARCHAR2(45);
  l_receipt_Date        DATE := p_receipt_date;
  l_cross_curr_enabled  varchar2(3):='N';
  l_conversion_rate     NUMBER;
  l_exchange_rate_type  VARCHAR2(45);
  l_orig_rcpt_amount    NUMBER            := p_amount_app_to;
  l_due_date            DATE          DEFAULT NULL;
  l_customer_id         NUMBER;
  l_customer_num        VARCHAR2(30)  := p_customer_num;
  l_cons_bill_num       VARCHAR2(90);
  l_last_contract_id    OKC_K_HEADERS_V.ID%TYPE DEFAULT 1;
  l_contract_id         NUMBER;
  l_contract_num        VARCHAR2(120);
  l_contract_number_start_date  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL;
  l_contract_number_id          OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL;

  l_receivables_invoice_num     NUMBER            DEFAULT NULL;
  l_over_pay                    VARCHAR(1)    DEFAULT NULL;
  l_ordered                     CONSTANT      VARCHAR2(3) := 'ODD';
  l_prorate                     CONSTANT      VARCHAR2(3) := 'PRO';
  i                             NUMBER;
  j                             NUMBER;
  k                             NUMBER;
  d                             NUMBER DEFAULT NULL;

  l_first_prorate_rec           NUMBER DEFAULT NULL;
  l_first_prorate_rec_j         NUMBER DEFAULT NULL;

  l_appl_tolerance              NUMBER;
  l_temp_val                    NUMBER;
  l_inv_tot                     NUMBER          := 0;
  l_cont_tot                    NUMBER      := 0;
  l_pro_rate_inv_total          NUMBER          := 0;
  l_line_tot                    NUMBER      := 0;
  l_diff_amount                 NUMBER      := 0;
  l_inv_total_amt               NUMBER      := 0;
  l_tot_amt_app_from            NUMBER      := 0;

  l_start_date                  DATE;
  l_same_date                   VARCHAR(1) DEFAULT NULL;
  l_same_cash_app_rule          VARCHAR(1) DEFAULT NULL;

  l_count                       NUMBER DEFAULT NULL;
  l_rct_id                      OKL_TRX_CSH_RECEIPT_V.ID%TYPE;
  l_rca_id                      OKL_TXL_RCPT_APPS_V.ID%TYPE;
--  l_xcr_id                    OKL_EXT_CSH_RCPTS_V.ID%TYPE;
  l_check_cau_id                OKL_CSH_ALLCTN_RL_HDR.ID%TYPE DEFAULT NULL;
  l_cau_id                      OKL_CSH_ALLCTN_RL_HDR.ID%TYPE DEFAULT NULL;
  l_cat_id                      OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
  l_sty_id                      OKL_CNSLD_AR_STRMS_V.STY_ID%TYPE;
  l_tolerance                   OKL_CASH_ALLCTN_RLS.AMOUNT_TOLERANCE_PERCENT%TYPE;
  l_days_past_quote_valid       OKL_CASH_ALLCTN_RLS.DAYS_PAST_QUOTE_VALID_TOLERANC%TYPE;
  l_months_to_bill_ahead        OKL_CASH_ALLCTN_RLS.MONTHS_TO_BILL_AHEAD%TYPE;
  l_under_payment               OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE;
  l_over_payment                OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE;
  l_receipt_msmtch              OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE;
  l_api_version                 NUMBER := 1.0;
  l_init_msg_list               VARCHAR2(1)     := Okc_Api.g_false;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);

-- Begin  - local variables for Receipts Project - varangan
  --Record/Table Definitions
  l_rcpt_tbl                    okl_rcpt_dtls_tbl_type;
  l_appl_tbl                    okl_appl_dtls_tbl_type;
  l_ar_inv_num                  VARCHAR2(120);
  l_amount_apply_pref           VARCHAR2(15)  := 'PRORATE';
  l_original_line_amount        NUMBER;
  l_original_tax_amount         NUMBER;
  l_total_amount                NUMBER;
  l_has_invoices                BOOLEAN := FALSE;
  No_Open_Invoices_Exception    EXCEPTION;
-- End - local variables for Receipts Project - varangan

-------------------
-- DECLARE Cursors
-------------------
 --Cursor to fetch the open invoice lines for given AR Invoice Number and Contract number
   CURSOR   c_open_invs1 (  cp_arinv_num         IN VARCHAR2,
                            cp_org_id    IN Number
                          ) IS
    SELECT
            AR_INVOICE_ID  Ar_Invoice_Id,
            Invoice_Number  Invoice_number,
            invoice_currency_code ,
            INVOICE_LINE_ID invoice_line_id,
            Line_Identifier Line_Number,
            amount_due_remaining amount_due_remaining,
            line_identifier Line_Identifier,
            sty_id,
            CONTRACT_NUMBER
    From   OKL_RCPT_ARINV_BALANCES_UV
    Where  Invoice_Number = cp_arinv_num
    And    Org_id = cp_org_id
    --asawanka changed for bug #5391874
    AND    customer_account_number = nvl(p_customer_num,customer_account_number)
    AND    status = 'OP';

    c_all_open_invs_rec  c_open_invs1%ROWTYPE;
    TYPE open_inv_tbl_type IS TABLE OF c_open_invs1%ROWTYPE INDEX BY BINARY_INTEGER;
    open_inv_tbl open_inv_tbl_type;
    open_inv_contract_tbl open_inv_tbl_type;

----------

-- Cursor to fetch contract Id and contract start date with the AR invoice Number

   Cursor c_inv_date (cp_arinv_num IN VARCHAR2 , cp_org_id Number) IS
   SELECT A.Id contract_id , A.start_date Start_Date
   From Okc_k_headers_all_b A, OKL_RCPT_ARINV_BALANCES_UV B
   Where B.Invoice_Number = cp_arinv_num
   and a.contract_number = b.contract_number
   And b.org_id= cp_org_id;

----------
 -- Cursor to get the Stream type Id for the given allocation order.
   CURSOR   c_stream_alloc ( cp_str_all_type IN VARCHAR2
                            ,cp_cat_id       IN NUMBER ) IS
        SELECT  sty_id
        FROM    OKL_STRM_TYP_ALLOCS
        WHERE   stream_allc_type = cp_str_all_type
    AND     cat_id = cp_cat_id
        ORDER BY sequence_number;

----------
-- Cursor to fetch the Cash Application Rule for the given Contract Id

   CURSOR   c_cash_rle_id_csr ( cp_khr_id IN NUMBER) IS
    SELECT  to_number(a.object1_id1)
    FROM    OKC_RULES_B a, OKC_RULE_GROUPS_B b
    WHERE   a.rgp_id = b.id
    AND     b.rgd_code = 'LABILL'
    AND     a.rule_information_category = 'LAINVD'
    AND     a.dnz_chr_id = b.chr_id
    AND     a.dnz_chr_id = cp_khr_id;

----------
-- Cursor to fetch the cash application rule details for the given CAR Id
   CURSOR   c_cash_rule_csr  ( cp_cau_id IN NUMBER ) IS
    SELECT  ID
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

-- Cursor to fetch contract id , contract number group under an AR Invoice Number
   CURSOR   c_get_contract_num (l_inv_ref IN VARCHAR2,l_org_id IN NUMBER) IS
    SELECT  lpt.khr_id contract_id, lpt.CONTRACT_NUMBER contract_number
    FROM        OKL_RCPT_ARINV_BALANCES_UV lpt
        WHERE   lpt.INVOICE_NUMBER      = l_inv_ref
        AND         lpt.amount_due_remaining > 0
        And     lpt.org_id= l_org_id
    ORDER BY lpt.start_date;

--
CURSOR c_get_arinv ( l_inv_ref IN VARCHAR2,cp_org_id IN NUMBER) IS
SELECT TRX_NUMBER, invoice_currency_code
FROM RA_CUSTOMER_TRX_ALL
WHERE TRX_NUMBER= l_inv_ref
AND org_id = cp_org_id;

l_trx_number NUMBER;

l_unapply_amount NUMBER :=0;
l_onacc_amount NUMBER :=0;

BEGIN
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Cash Application Rules - AR Invoice Number - '||l_ar_inv_num);
  END IF;
  x_return_status:= OKC_API.G_RET_STS_SUCCESS;
  /* Begin - validate AR Invoice Reference and Org Id */
  If p_arinv_number is Null and P_arinv_id Is Null Then
           x_return_status := OKC_API.G_RET_STS_ERROR;
           OKC_API.set_message( p_app_name      => G_APP_NAME
                               ,p_msg_name      => 'OKL_REQUIRED_VALUE'
                               ,p_token1                => 'COL_NAME'
                                   ,p_token1_value  => 'Either p_arinv_number or P_arinv_id'
                               );
           RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  If p_org_id Is Null Then
             x_return_status := OKC_API.G_RET_STS_ERROR;
             OKC_API.set_message( p_app_name      => G_APP_NAME
                                 ,p_msg_name      => 'OKL_REQUIRED_VALUE'
                                 ,p_token1                => 'COL_NAME'
                                     ,p_token1_value  => 'Org_Id'
                                 );
              RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;
    --Check whether AR Invoice number provided is having any open invoices or not
  l_has_invoices := FALSE;
  OPEN c_get_arinv ( p_arinv_number,p_org_id);
  LOOP
    FETCH c_get_arinv INTO l_trx_number,l_inv_curr_code;
    EXIT WHEN c_get_arinv%NOTFOUND;
    l_has_invoices := TRUE;
  END LOOP;
  CLOSE c_get_arinv;

  IF (l_has_invoices = FALSE) THEN
    RAISE No_Open_Invoices_Exception;
  END IF;

  /* End - validate AR Invoice Reference and Org Id */
        i :=  0;
        j :=  0;
        l_inv_ref := p_arinv_number;
        l_org_id :=  p_org_id;

        OPEN  c_inv_date(l_inv_ref,l_org_id);
        FETCH c_inv_date INTO l_contract_number_id , l_start_date;
        CLOSE c_inv_date;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_contract_number_id , l_start_date : '||
                                            l_contract_number_id||', '||l_start_date);
        END IF;
        d := 0;
        log_debug('l_inv_ref = '||l_inv_ref);
        log_debug('l_org_id = '|| l_org_id);
        FOR c_inv_date_rec IN c_inv_date(l_inv_ref,l_org_id)
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
        log_debug('l_same_date = '||l_same_date);
        --  ************************************************
        --  Check for same cash application rule
        --  ************************************************

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Check for same cash application rule');
        END IF;
        OPEN  c_cash_rle_id_csr (l_contract_number_id);
        FETCH c_cash_rle_id_csr INTO l_cau_id;
        CLOSE c_cash_rle_id_csr;

        d := 0;
        FOR c_inv_date_rec IN c_inv_date(l_inv_ref,l_org_id)
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
        log_debug('l_same_cash_app_rule ='||l_same_cash_app_rule);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_same_date, l_same_cash_app_rule : '||
                                    l_same_date||', '||l_same_cash_app_rule);
        END IF;
        log_debug('Receipt Currency = '||l_currency_code);
        log_debug('Invoice Currency = '||l_inv_curr_Code);
        log_debug('l_amount_app_from = '||l_amount_app_from);
        log_debug('l_amount_app_to = '||l_amount_app_to);
        log_debug('l_inv_to_rct_rate = '||l_inv_to_rct_rate);

        IF l_currency_code = l_inv_curr_Code THEN
                IF l_amount_app_from IS NULL AND l_amount_app_to IS NULL THEN
                  OKL_API.set_message( p_app_name      => G_APP_NAME
                                      ,p_msg_name      => 'OKL_BPD_INVALID_PARAMS'
                                            );
                  RAISE G_EXCEPTION_HALT_VALIDATION;
                ELSIF l_amount_app_from IS NULL THEN
                   l_amount_app_from := l_amount_app_to;
                ELSE
                   l_amount_app_to := l_amount_app_from;
                END IF;
        ELSE
                IF l_amount_app_from IS NOT NULL AND l_amount_app_to IS NOT NULL AND l_inv_to_rct_rate IS NOT NULL THEN
                  IF ( l_amount_app_to * l_inv_to_rct_rate) <> l_amount_app_from THEN
                    OKL_API.set_message( p_app_name      => G_APP_NAME
                                              ,p_msg_name      => 'OKL_BPD_PARAMS_MISMATCH'
                                                    );
                  END IF;
                  IF l_inv_to_rct_rate <> 0 and ( ( l_amount_app_from / l_inv_to_rct_rate) <> l_amount_app_to) THEN
                    OKL_API.set_message( p_app_name      => G_APP_NAME
                                              ,p_msg_name      => 'OKL_BPD_PARAMS_MISMATCH'
                                                    );
                  END IF;
                END IF;
              /*  l_cross_curr_enabled := nvl(FND_PROFILE.value('AR_ENABLE_CROSS_CURRENCY'),'N');
                log_debug('l_cross_curr_enabled = '||l_cross_curr_enabled);
                IF l_cross_curr_enabled <> 'Y' THEN
                  OKL_API.set_message( p_app_name      => G_APP_NAME
                                      ,p_msg_name      => 'OKL_BPD_CROSS_CURR_NA'
                                            );
                  RAISE G_EXCEPTION_HALT_VALIDATION;
                ELSE*/
                   IF l_inv_to_rct_rate is null THEN
                     l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                     log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                     IF l_exchange_rate_type IS  NULL THEN
                        OKL_API.set_message( p_app_name      => G_APP_NAME
                                            ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                           );
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                     ELSE
                        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                   ,l_currency_code
                                                                   ,l_receipt_date
                                                                   ,l_exchange_rate_type
                                                                   );

                        IF l_conversion_rate IN (0,-1) THEN

                            -- Message Text: No exchange rate defined
                            x_return_status := okl_api.G_RET_STS_ERROR;
                            okl_api.set_message( p_app_name      => G_APP_NAME,
                                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                            RAISE G_EXCEPTION_HALT_VALIDATION;
                        END IF;
                     END IF;
                  ELSE
                    l_conversion_rate := l_inv_to_rct_rate;
                  END IF;
                  log_debug('l_conversion_rate ='||l_conversion_rate);
                  IF l_amount_app_from IS NULL AND l_amount_app_to IS NULL THEN
                      OKL_API.set_message( p_app_name      => G_APP_NAME
                                          ,p_msg_name      => 'OKL_BPD_INVALID_PARAMS'
                                         );
                      RAISE G_EXCEPTION_HALT_VALIDATION;
                  ELSIF l_amount_app_from IS NULL THEN
                     l_amount_app_from := l_amount_app_to * l_conversion_rate;
                  ELSE
                     l_amount_app_to := l_amount_app_from * (1/l_conversion_rate);
                  END IF;
               -- END IF;
        END IF;
        l_amount_app_from := arp_util.CurrRound(l_amount_app_from,l_currency_code);
        l_amount_app_to := arp_util.CurrRound(l_amount_app_to,l_inv_curr_code);

	--22--Apr-2008 ankushar Bug# 6978225, Passed the value to l_orig_rcpt_amount
	l_orig_rcpt_amount := l_amount_app_to;
        --22-Apr-2008 ankushar End Changes

        log_debug('l_amount_app_from = '||l_amount_app_from);
        log_debug('l_amount_app_to = '||l_amount_app_to);
        log_debug('l_inv_to_rct_rate = '||l_inv_to_rct_rate);
        IF l_same_date = 'Y' THEN

           IF l_same_cash_app_rule = 'Y' THEN  -- Use Common Cash Application
               IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Date and CAR are same for all contracts ...');
               END IF;
               --  *******************************************************
               --  Start Line level cash application using the same cash
               --  application rule for all
               --  *******************************************************
               OPEN c_cash_rule_csr (l_cau_id);
               FETCH c_cash_rule_csr
               INTO  l_cat_id
                  ,l_tolerance
                  ,l_days_past_quote_valid
                          ,l_months_to_bill_ahead
                          ,l_under_payment
                          ,l_over_payment
                          ,l_receipt_msmtch;
               CLOSE c_cash_rule_csr;
          Elsif  l_same_cash_app_rule = 'N' THEN  -- Use Default Cash Application
               IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Same Date but different CAR for all contracts ...');
               END IF;
               --  *******************************************************
               --  Start Line level cash application using the same cash
               --  application rule for all
               --  *******************************************************
                Get_Default_Cash_App_Rule(
                         l_org_id
                        ,l_cat_id
                        ,l_tolerance
                        ,l_days_past_quote_valid
                        ,l_months_to_bill_ahead
                        ,l_under_payment
                        ,l_over_payment
                        ,l_receipt_msmtch);
          End If;
            --  ************************************************
            --  Line level cash application processing BEGINS
            --  ************************************************

            -- Get Line total

             l_line_tot := 0;
             i := 0;
             FOR c_open_invs_rec IN c_open_invs1 (l_inv_ref,l_org_id)
             LOOP
                 IF c_open_invs_rec.amount_due_remaining > 0 THEN
                   i := i + 1;
                   open_inv_tbl(i) := c_open_invs_rec;
                   l_inv_curr_Code := c_open_invs_rec.invoice_currency_code;
                   l_line_tot := l_line_tot + c_open_invs_rec.amount_due_remaining;
                 END IF;
             END LOOP;

             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_line_tot : ' || l_line_tot);
                     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_amount_app_to : ' || l_amount_app_to);
             END IF;
             -- calculate tolerance
             IF l_line_tot > l_amount_app_to THEN
                    l_appl_tolerance := l_line_tot * (1 - l_tolerance / 100);
                 ELSE
                        l_appl_tolerance := l_line_tot;
                 END IF;
             log_debug('l_line_tot = '||l_line_tot);
             log_debug('l_amount_app_to = '||l_amount_app_to);
             log_debug('l_appl_tolerance = '||l_appl_tolerance);
             log_debug('l_under_payment = '||l_under_payment);
             IF l_line_tot > l_amount_app_to AND l_appl_tolerance > l_amount_app_to THEN -- UNDERPAYMENT  (2)

                    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'UNDERPAYMENT ...');
                    END IF;
                    IF l_under_payment IN ('U','u') THEN -- Unapply underpayment (3)

                       IF l_currency_code = l_inv_curr_code THEN
                         l_unapply_amount:=l_amount_app_to;
                       ELSE
                         l_unapply_amount:= l_amount_app_to * l_conversion_rate;
                         l_unapply_amount := GET_ROUNDED_AMOUNT(l_unapply_amount,l_currency_code);
                       END IF;

                    ELSIF l_under_payment IN ('T','t') THEN -- ORDERED (3)

                      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ORDERED ...');
                      END IF;
                      OPEN c_stream_alloc (l_ordered, l_cat_id);
                          LOOP
                               FETCH c_stream_alloc INTO l_sty_id;
                               EXIT WHEN c_stream_alloc%NOTFOUND OR l_amount_app_to = 0 OR l_amount_app_to IS NULL;

                               FOR i IN open_inv_tbl.FIRST..open_inv_tbl.LAST
                                  LOOP
                                    c_all_open_invs_rec := open_inv_tbl(i);
                                    EXIT WHEN l_amount_app_to = 0 OR l_amount_app_to IS NULL;
                                    IF c_all_open_invs_rec.sty_id = l_sty_id THEN
                                        j := j + 1;
                                        --Populate receipt table
                                        l_rcpt_tbl(j).INVOICE_ID := c_all_open_invs_rec.ar_invoice_id;
                                        l_rcpt_tbl(j).INVOICE_NUMBER := c_all_open_invs_rec.invoice_number;
                                        l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_code;
                                        l_rcpt_tbl(j).INVOICE_LINE_ID := c_all_open_invs_rec.invoice_line_id;
                                        l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_all_open_invs_rec.line_identifier;
                                        --Code without linelevel prorate
                                        --Amount Applied will be total amount applied including line and tax
                                        l_rcpt_tbl(j).AMOUNT_APPLIED := c_all_open_invs_rec.amount_due_remaining;
                                        IF l_amount_app_to < l_rcpt_tbl(j).AMOUNT_APPLIED THEN
                                                    l_rcpt_tbl(j).AMOUNT_APPLIED := l_amount_app_to;
                                                    l_amount_app_to := 0;
                                        ELSE
                                                l_amount_app_to := l_amount_app_to - l_rcpt_tbl(j).AMOUNT_APPLIED;
                                        END IF;

                                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).INVOICE_LINE_NUMBER : '||l_rcpt_tbl(j).INVOICE_LINE_NUMBER);
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
                                        END IF;
                                        IF l_currency_code <> l_inv_curr_code THEN
                                          IF l_inv_to_rct_rate is null THEN
                                             l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                             log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                             IF l_exchange_rate_type IS  NULL THEN
                                                OKL_API.set_message( p_app_name      => G_APP_NAME
                                                                    ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                                   );
                                                RAISE G_EXCEPTION_HALT_VALIDATION;
                                             ELSE
                                                l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                           ,l_currency_code
                                                                                           ,l_receipt_date
                                                                                           ,l_exchange_rate_type
                                                                                           );

                                                IF l_conversion_rate IN (0,-1) THEN

                                                    -- Message Text: No exchange rate defined
                                                    x_return_status := okl_api.G_RET_STS_ERROR;
                                                    okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                         p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                                    RAISE G_EXCEPTION_HALT_VALIDATION;
                                                END IF;
                                             END IF;
                                          ELSE
                                            l_conversion_rate := l_inv_to_rct_rate;
                                          END IF;
                                           l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                        ELSE
                                           l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                        END IF;
                                    END IF;
                                  END LOOP;
                           END LOOP;
                           CLOSE c_stream_alloc;

                 ELSIF l_under_payment IN ('P','p') THEN -- PRO RATE (3)

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'PRO RATE ...');
                        END IF;
                                    j := 0;
                        -- obtain all the streams that are part of the pro rate default rule.

                        FOR c_stream_alloc_rec IN c_stream_alloc (l_prorate, l_cat_id)
                        LOOP

                                             l_sty_id := c_stream_alloc_rec.sty_id;
                                             FOR i IN open_inv_tbl.FIRST..open_inv_tbl.LAST
                                             LOOP
                                               c_all_open_invs_rec := open_inv_tbl(i);
                                               IF c_all_open_invs_rec.sty_id = l_sty_id THEN

                                        j := j + 1;
                                        --Populate receipt table
                                        l_rcpt_tbl(j).INVOICE_ID := c_all_open_invs_rec.ar_invoice_id;
                                                l_rcpt_tbl(j).INVOICE_NUMBER := c_all_open_invs_rec.invoice_number;
                                        l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_code;
                                        l_rcpt_tbl(j).INVOICE_LINE_ID := c_all_open_invs_rec.invoice_line_id;
                                        l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_all_open_invs_rec.line_identifier;
                                        l_rcpt_tbl(j).AMOUNT_APPLIED := c_all_open_invs_rec.amount_due_remaining;
                                        l_pro_rate_inv_total :=l_pro_rate_inv_total + l_rcpt_tbl(j).AMOUNT_APPLIED;
                                        IF l_currency_code <> l_inv_curr_code THEN
                                          IF l_inv_to_rct_rate is null THEN
                                             l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                             log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                             IF l_exchange_rate_type IS  NULL THEN
                                                OKL_API.set_message( p_app_name      => G_APP_NAME
                                                                    ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                                   );
                                                RAISE G_EXCEPTION_HALT_VALIDATION;
                                             ELSE
                                                l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                           ,l_currency_code
                                                                                           ,l_receipt_date
                                                                                           ,l_exchange_rate_type
                                                                                           );

                                                IF l_conversion_rate IN (0,-1) THEN

                                                    -- Message Text: No exchange rate defined
                                                    x_return_status := okl_api.G_RET_STS_ERROR;
                                                    okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                         p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                                    RAISE G_EXCEPTION_HALT_VALIDATION;
                                                END IF;
                                             END IF;
                                          ELSE
                                            l_conversion_rate := l_inv_to_rct_rate;
                                          END IF;
                                           l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                        ELSE
                                           l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                        END IF;
                                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).INVOICE_LINE_NUMBER : '||l_rcpt_tbl(j).INVOICE_LINE_NUMBER);
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);

                                        END IF;
                                END IF;
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
                    log_debug('l_pro_rate_inv_total = '||l_pro_rate_inv_total);
                    log_debug('l_orig_rcpt_amount = '||l_orig_rcpt_amount);
                        IF (l_pro_rate_inv_total > l_orig_rcpt_amount) THEN

                                    j := 1;
                                    l_temp_val := l_orig_rcpt_amount / l_pro_rate_inv_total;

                            LOOP
                                    l_rcpt_tbl(j).AMOUNT_APPLIED := l_temp_val * l_rcpt_tbl(j).AMOUNT_APPLIED;
                            l_rcpt_tbl(j).AMOUNT_APPLIED:=GET_ROUNDED_AMOUNT(l_rcpt_tbl(j).AMOUNT_APPLIED,l_inv_curr_code);
                            IF l_currency_code <> l_inv_curr_code THEN
                                IF l_inv_to_rct_rate is null THEN
                                   l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                   log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                   IF l_exchange_rate_type IS  NULL THEN
                                      OKL_API.set_message( p_app_name      => G_APP_NAME
                                                          ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                         );
                                      RAISE G_EXCEPTION_HALT_VALIDATION;
                                   ELSE
                                      l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                 ,l_currency_code
                                                                                 ,l_receipt_date
                                                                                 ,l_exchange_rate_type
                                                                                 );

                                      IF l_conversion_rate IN (0,-1) THEN

                                          -- Message Text: No exchange rate defined
                                          x_return_status := okl_api.G_RET_STS_ERROR;
                                          okl_api.set_message( p_app_name      => G_APP_NAME,
                                                               p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                          RAISE G_EXCEPTION_HALT_VALIDATION;
                                      END IF;
                                   END IF;
                                ELSE
                                  l_conversion_rate := l_inv_to_rct_rate;
                                END IF;
                                 l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                 l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                 l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                            ELSE
                               l_rcpt_tbl(j).trans_to_receipt_rate := null;
                               l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                            END IF;
                            l_inv_total_amt := l_inv_total_amt + l_rcpt_tbl(j).AMOUNT_APPLIED;
                                EXIT WHEN (j = l_rcpt_tbl.LAST);
                            j := j + 1;
                                 END LOOP;
                         l_diff_amount := l_amount_app_to - l_inv_total_amt;
                         if l_diff_amount > 0 then
                           l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied := l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied + l_diff_amount;
                           IF l_currency_code <> l_inv_curr_code THEN
                                IF l_inv_to_rct_rate is null THEN
                                   l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                   log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                   IF l_exchange_rate_type IS  NULL THEN
                                      OKL_API.set_message( p_app_name      => G_APP_NAME
                                                          ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                         );
                                      RAISE G_EXCEPTION_HALT_VALIDATION;
                                   ELSE
                                      l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                 ,l_currency_code
                                                                                 ,l_receipt_date
                                                                                 ,l_exchange_rate_type
                                                                                 );

                                      IF l_conversion_rate IN (0,-1) THEN

                                          -- Message Text: No exchange rate defined
                                          x_return_status := okl_api.G_RET_STS_ERROR;
                                          okl_api.set_message( p_app_name      => G_APP_NAME,
                                                               p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                          RAISE G_EXCEPTION_HALT_VALIDATION;
                                      END IF;
                                   END IF;
                                ELSE
                                  l_conversion_rate := l_inv_to_rct_rate;
                                END IF;
                                 l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                 l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                 l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                           ELSE
                              l_rcpt_tbl(j).trans_to_receipt_rate := null;
                              l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                           END IF;
                         end if;
                         log_debug('l_amount_app_from = '||l_amount_app_from);
                       /*  l_diff_amount := l_amount_app_from - l_tot_amt_app_from;
                         if l_diff_amount > 0 then
                           l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied_from := l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied_from + l_diff_amount;
                         end if;*/
                         log_debug('l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied_from = '||l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied_from);
                                END IF;             -- bug 5221326

               END IF; -- (3)

          ELSE -- EXACT or OVERPAYMENT or TOLERANCE  (2)

                      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'EXACT or OVERPAYMENT or TOLERANCE');
                      END IF;
                       j := 0;
                      -- CREATE LINES TABLE
                              FOR i IN open_inv_tbl.FIRST..open_inv_tbl.LAST
                      LOOP
                        c_all_open_invs_rec := open_inv_tbl(i);
                        EXIT WHEN l_amount_app_to = 0 OR l_amount_app_to IS NULL;
                            j := j + 1;
                            --Populate receipt table
                                        l_rcpt_tbl(j).INVOICE_ID := c_all_open_invs_rec.ar_invoice_id;
                                                l_rcpt_tbl(j).INVOICE_NUMBER := c_all_open_invs_rec.invoice_number;
                                        l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_code;
                                        l_rcpt_tbl(j).INVOICE_LINE_ID := c_all_open_invs_rec.invoice_line_id;
                                                l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_all_open_invs_rec.line_identifier;
                                       --Amount Applied will be total amount applied including line and tax
                                            l_rcpt_tbl(j).AMOUNT_APPLIED := c_all_open_invs_rec.amount_due_remaining;
                                                   IF l_amount_app_to < l_rcpt_tbl(j).AMOUNT_APPLIED THEN
                                                    l_rcpt_tbl(j).AMOUNT_APPLIED := l_amount_app_to;
                                                    l_amount_app_to := 0;
                                                   ELSE
                                                        l_amount_app_to := l_amount_app_to - l_rcpt_tbl(j).AMOUNT_APPLIED;
                                                   END IF;
                                        IF l_currency_code <> l_inv_curr_code THEN
                                          IF l_inv_to_rct_rate is null THEN
                                             l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                             log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                             IF l_exchange_rate_type IS  NULL THEN
                                                OKL_API.set_message( p_app_name      => G_APP_NAME
                                                                    ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                                   );
                                                RAISE G_EXCEPTION_HALT_VALIDATION;
                                             ELSE
                                                l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                           ,l_currency_code
                                                                                           ,l_receipt_date
                                                                                           ,l_exchange_rate_type
                                                                                           );

                                                IF l_conversion_rate IN (0,-1) THEN

                                                    -- Message Text: No exchange rate defined
                                                    x_return_status := okl_api.G_RET_STS_ERROR;
                                                    okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                         p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                                    RAISE G_EXCEPTION_HALT_VALIDATION;
                                                END IF;
                                             END IF;
                                          ELSE
                                            l_conversion_rate := l_inv_to_rct_rate;
                                          END IF;
                                           l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                        ELSE
                                           l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                        END IF;
                                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).INVOICE_LINE_NUMBER : '||l_rcpt_tbl(j).INVOICE_LINE_NUMBER);
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
                                        END IF;
                       END LOOP;
                     -- Apply the remaining balance as per the Cash Application Rule

                       If l_over_payment In ('B','b') Then  -- Onaccount --move cash to customer balances -OVP
                           IF l_currency_code = l_inv_curr_code THEN
                             l_onacc_amount:=l_amount_app_to;
                           ELSE
                             l_onacc_amount := l_amount_app_to * l_conversion_rate;
                             l_onacc_amount := GET_ROUNDED_AMOUNT(l_onacc_amount,l_currency_code);
                           END IF;
                       Elsif l_over_payment In ('F','f') Then --Unapply  -- move cash to unapplied -OVP
                           IF l_currency_code = l_inv_curr_code THEN
                             l_unapply_amount:=l_amount_app_to;
                           ELSE
                             l_unapply_amount:= l_amount_app_to * l_conversion_rate;
                             l_unapply_amount := GET_ROUNDED_AMOUNT(l_unapply_amount,l_currency_code);
                           END IF;
                       End If;

            END IF; -- under payment. (2)


            --  **********************************************
            --  Line level cash application processing ENDS
            --  **********************************************

      ELSE  /*IF l_same_date = 'N' THEN */
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract level cash application processing BEGINS');
              END IF;
            --  ******************************************************
            --  Contract level cash application processing BEGINS
            --  ******************************************************
            j := 0;
            open_inv_tbl.delete;
             FOR c_open_invs_rec IN c_open_invs1 (l_inv_ref,l_org_id)
             LOOP
                 IF c_open_invs_rec.amount_due_remaining > 0 THEN
                   i := i + 1;
                   open_inv_tbl(i) := c_open_invs_rec;
                 END IF;
             END LOOP;
             log_debug('open_inv_tbl.count = '||open_inv_tbl.count);
            OPEN c_get_contract_num(l_inv_ref,l_org_id);
            LOOP
                        FETCH c_get_contract_num INTO l_contract_id, l_contract_num;
                           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_contract_num : '||l_contract_num);
                                   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_amount_app_to : '||l_amount_app_to);
                           END IF;
                        log_debug('l_contract_num = '||l_contract_num);
                        log_debug('l_amount_app_to = '||l_amount_app_to);
                        EXIT WHEN c_get_contract_num%NOTFOUND
                    OR l_amount_app_to = 0
                    OR l_amount_app_to IS NULL;
                IF l_last_contract_id <> l_contract_id THEN -- added by bv

                    l_last_contract_id := l_contract_id;  -- added by bv

                    IF l_contract_num IS NOT NULL THEN
                        OPEN c_cash_rle_id_csr (l_contract_id);
                        FETCH c_cash_rle_id_csr INTO l_cau_id;
                        CLOSE c_cash_rle_id_csr;

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cau_id : '||l_cau_id);
                        END IF;
                        IF l_cau_id IS NOT NULL THEN  -- Process with Contract's CAR
                            OPEN c_cash_rule_csr (l_cau_id);
                            FETCH c_cash_rule_csr INTO  l_cat_id
                                                       ,l_tolerance
                                                       ,l_days_past_quote_valid
                                                               ,l_months_to_bill_ahead
                                                               ,l_under_payment
                                                               ,l_over_payment
                                                               ,l_receipt_msmtch;
                            CLOSE c_cash_rule_csr;

                            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tolerance : '||l_tolerance);
                            END IF;
                            IF l_tolerance IS NULL THEN  -- Use Default CAR
                              -- Process with default cash application rule
                                Get_Default_Cash_App_Rule (
                                                      l_org_id
                                                     ,l_cat_id
                                                     ,l_tolerance
                                                     ,l_days_past_quote_valid
                                                             ,l_months_to_bill_ahead
                                                     ,l_under_payment
                                                             ,l_over_payment
                                                             ,l_receipt_msmtch
                                                              );
                            END IF;

                        ELSE /* If CAR is not defined on this contract process with default CAR */

                            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cau_id is null, using default cash appln rule');
                            END IF;
                             Get_Default_Cash_App_Rule (
                                                      l_org_id
                                                     ,l_cat_id
                                                     ,l_tolerance
                                                     ,l_days_past_quote_valid
                                                             ,l_months_to_bill_ahead
                                                     ,l_under_payment
                                                             ,l_over_payment
                                                             ,l_receipt_msmtch
                                                              );

                        END IF;  /* End Contract's CAR check */

                        -- get contract total
                        l_cont_tot := 0;
                        k := 0;
                        FOR i IN open_inv_tbl.FIRST..open_inv_tbl.LAST
                            LOOP
                                IF open_inv_tbl(i).contract_number = l_contract_num THEN
                                  k := k + 1;
                                  c_all_open_invs_rec := open_inv_tbl(i);
                                  open_inv_contract_tbl(k) := open_inv_tbl(i);
                              -- l_invoice_currency_code := c_open_invs_rec.currency_code;
                              l_cont_tot := l_cont_tot + c_all_open_invs_rec.amount_due_remaining;
                              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cont_tot : '||l_cont_tot);
                              END IF;
                            END IF;
                            END LOOP;
                            log_debug('l_cau_id ='||l_cau_id);
                           IF NVL(l_cau_id, 0) = -1 THEN  -- VR 07-Oct-2005 GE-20 Receipts - On Account CAR
                                                       -- Receipt needs to be left as unapplied
                                       j := 1;
                                       --Populate receipt table
                                        l_rcpt_tbl(j).INVOICE_ID := NULL;
                                                l_rcpt_tbl(j).INVOICE_NUMBER := NULL;
                                        l_rcpt_tbl(j).INVOICE_LINE_ID := NULL;
                                            l_rcpt_tbl(j).INVOICE_LINE_NUMBER := NULL;
                                        l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_code;
                                       --Amount Applied will be total amount applied including line and tax
                                        l_rcpt_tbl(j).AMOUNT_APPLIED := l_amount_app_to;
                                        IF l_currency_code <> l_inv_curr_code THEN
                                          IF l_inv_to_rct_rate is null THEN
                                             l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                             log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                             IF l_exchange_rate_type IS  NULL THEN
                                                OKL_API.set_message( p_app_name      => G_APP_NAME
                                                                    ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                                   );
                                                RAISE G_EXCEPTION_HALT_VALIDATION;
                                             ELSE
                                                l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                           ,l_currency_code
                                                                                           ,l_receipt_date
                                                                                           ,l_exchange_rate_type
                                                                                           );

                                                IF l_conversion_rate IN (0,-1) THEN

                                                    -- Message Text: No exchange rate defined
                                                    x_return_status := okl_api.G_RET_STS_ERROR;
                                                    okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                         p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                                    RAISE G_EXCEPTION_HALT_VALIDATION;
                                                END IF;
                                             END IF;
                                          ELSE
                                            l_conversion_rate := l_inv_to_rct_rate;
                                          END IF;
                                           l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                       ELSE
                                           l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                        END IF;

                        ELSE
                          -- calculate tolerance
                          IF l_cont_tot > l_amount_app_to THEN
                                    l_appl_tolerance := l_cont_tot * (1 - l_tolerance / 100);
                              ELSE
                                    l_appl_tolerance := l_cont_tot;
                              END IF;

                          --  Contract level cash application processing begins.
                          --  *************************************************
                         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Checking UNDERPAYMENT/OVERPAYMENT/MATCH');
                             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cont_tot : '||l_cont_tot);
                             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_amount_app_to : '||l_amount_app_to);
                             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_appl_tolerance : '||l_appl_tolerance);
                         END IF;
                         log_debug('l_cont_tot ='||l_cont_tot);
                         IF l_cont_tot > l_amount_app_to AND l_appl_tolerance > l_amount_app_to THEN -- UNDERPAYMENT  (2)
                             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'UNDERPAYMENT');
                             END IF;
                             log_Debug('l_under_payment ='||l_under_payment);
                             IF l_under_payment In ('U','u') THEN -- Unapply underpayment (3)
                                   IF l_currency_code = l_inv_curr_code THEN
                                     l_unapply_amount:=l_amount_app_to;
                                   ELSE
                                     l_unapply_amount:= l_amount_app_to * l_conversion_rate;
                                     l_unapply_amount := GET_ROUNDED_AMOUNT(l_unapply_amount,l_currency_code);
                                   END IF;

                             ELSIF l_under_payment IN ('T','t') THEN -- ORDERED (3)

                                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ORDERED ...');
                                END IF;

                                OPEN c_stream_alloc (l_ordered, l_cat_id);
                                    LOOP
                                      FETCH c_stream_alloc INTO l_sty_id;
                                              EXIT WHEN c_stream_alloc%NOTFOUND OR l_amount_app_to = 0 OR l_amount_app_to IS NULL;
                                   log_Debug('l_sty_id = '||l_sty_id);

                                  FOR i IN open_inv_contract_tbl.FIRST..open_inv_contract_tbl.LAST
                                      LOOP
                                               c_all_open_invs_rec := open_inv_contract_tbl(i);
                                               log_debug('c_all_open_invs_rec.sty_id = '||c_all_open_invs_rec.sty_id);
                                               EXIT WHEN l_amount_app_to = 0 OR l_amount_app_to IS NULL;
                                               IF c_all_open_invs_rec.sty_id = l_sty_id THEN
                                         j := j + 1;
                                        --Populate receipt table
                                        l_rcpt_tbl(j).INVOICE_ID := c_all_open_invs_rec.ar_invoice_id;
                                                l_rcpt_tbl(j).INVOICE_NUMBER := c_all_open_invs_rec.invoice_number;
                                        l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_code;
                                        l_rcpt_tbl(j).INVOICE_LINE_ID := c_all_open_invs_rec.invoice_line_id;
                                                l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_all_open_invs_rec.line_identifier;
                                                --Code without linelevel prorate
                                                --Amount Applied will be total amount applied including line and tax
                                        l_rcpt_tbl(j).AMOUNT_APPLIED := c_all_open_invs_rec.amount_due_remaining;
                                            IF l_amount_app_to < l_rcpt_tbl(j).AMOUNT_APPLIED THEN
                                                    l_rcpt_tbl(j).AMOUNT_APPLIED := l_amount_app_to;
                                                    l_amount_app_to := 0;
                                        ELSE
                                                l_amount_app_to := l_amount_app_to - l_rcpt_tbl(j).AMOUNT_APPLIED;
                                        END IF;
                                        IF l_currency_code <> l_inv_curr_code THEN
                                          IF l_inv_to_rct_rate is null THEN
                                             l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                             log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                             IF l_exchange_rate_type IS  NULL THEN
                                                OKL_API.set_message( p_app_name      => G_APP_NAME
                                                                    ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                                   );
                                                RAISE G_EXCEPTION_HALT_VALIDATION;
                                             ELSE
                                                l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                           ,l_currency_code
                                                                                           ,l_receipt_date
                                                                                           ,l_exchange_rate_type
                                                                                           );

                                                IF l_conversion_rate IN (0,-1) THEN

                                                    -- Message Text: No exchange rate defined
                                                    x_return_status := okl_api.G_RET_STS_ERROR;
                                                    okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                         p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                                    RAISE G_EXCEPTION_HALT_VALIDATION;
                                                END IF;
                                             END IF;
                                          ELSE
                                            l_conversion_rate := l_inv_to_rct_rate;
                                          END IF;
                                           l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                        ELSE
                                           l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                        END IF;
                                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).INVOICE_LINE_NUMBER : '||l_rcpt_tbl(j).INVOICE_LINE_NUMBER);
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
                                        END IF;
                                      END IF;
                                            END LOOP;
                                END LOOP;
                                            CLOSE c_stream_alloc;
                                 /* IF l_rcpt_tbl.count > 0 THEN
                                     l_diff_amount := l_amount_app_from - l_tot_amt_app_from;
                                     if l_diff_amount > 0 then
                                       l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied_from := l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied_from + l_diff_amount;
                                     end if;
                                  end if;*/
                                    ELSIF l_under_payment IN ('P','p') THEN -- PRO RATE (3)
                                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'PRO RATE ...');
                                END IF;

                              -- obtain all the streams that are part of the pro rate default rule.

                                FOR c_stream_alloc_rec IN c_stream_alloc (l_prorate, l_cat_id)
                                LOOP

                                             l_sty_id := c_stream_alloc_rec.sty_id;
                                             log_debug('l_sty_id = '||l_sty_id);
                                             FOR i IN open_inv_contract_tbl.FIRST..open_inv_contract_tbl.LAST
                                             LOOP
                                               c_all_open_invs_rec := open_inv_contract_tbl(i);
                                               IF c_all_open_invs_rec.sty_id = l_sty_id THEN
                                        j := j + 1;
                                        --Populate receipt table
                                        l_rcpt_tbl(j).INVOICE_ID := c_all_open_invs_rec.ar_invoice_id;
                                                l_rcpt_tbl(j).INVOICE_NUMBER := c_all_open_invs_rec.invoice_number;
                                        l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_code;
                                        l_rcpt_tbl(j).INVOICE_LINE_ID := c_all_open_invs_rec.invoice_line_id;
                                                l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_all_open_invs_rec.line_identifier;
                                            l_rcpt_tbl(j).AMOUNT_APPLIED := c_all_open_invs_rec.amount_due_remaining;
                                        IF l_currency_code <> l_inv_curr_code THEN
                                          IF l_inv_to_rct_rate is null THEN
                                             l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                             log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                             IF l_exchange_rate_type IS  NULL THEN
                                                OKL_API.set_message( p_app_name      => G_APP_NAME
                                                                    ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                                   );
                                                RAISE G_EXCEPTION_HALT_VALIDATION;
                                             ELSE
                                                l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                           ,l_currency_code
                                                                                           ,l_receipt_date
                                                                                           ,l_exchange_rate_type
                                                                                           );

                                                IF l_conversion_rate IN (0,-1) THEN

                                                    -- Message Text: No exchange rate defined
                                                    x_return_status := okl_api.G_RET_STS_ERROR;
                                                    okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                         p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                                    RAISE G_EXCEPTION_HALT_VALIDATION;
                                                END IF;
                                             END IF;
                                          ELSE
                                            l_conversion_rate := l_inv_to_rct_rate;
                                          END IF;
                                           l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                        ELSE
                                           l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                        END IF;
                                        l_pro_rate_inv_total :=l_pro_rate_inv_total + l_rcpt_tbl(j).AMOUNT_APPLIED;
                                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).INVOICE_LINE_NUMBER : '||l_rcpt_tbl(j).INVOICE_LINE_NUMBER);
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
                                        END IF;
                                    END IF;

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

                                 IF (l_pro_rate_inv_total > l_orig_rcpt_amount) THEN
                                           j := 1;
                                               l_temp_val := l_orig_rcpt_amount / l_pro_rate_inv_total;

                                        LOOP
                                               l_rcpt_tbl(j).AMOUNT_APPLIED := l_temp_val * l_rcpt_tbl(j).AMOUNT_APPLIED;
                                       l_rcpt_tbl(j).AMOUNT_APPLIED:=GET_ROUNDED_AMOUNT(l_rcpt_tbl(j).AMOUNT_APPLIED,l_inv_curr_code);
                                       IF l_currency_code <> l_inv_curr_code THEN
                                          IF l_inv_to_rct_rate is null THEN
                                             l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                             log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                             IF l_exchange_rate_type IS  NULL THEN
                                                OKL_API.set_message( p_app_name      => G_APP_NAME
                                                                    ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                                   );
                                                RAISE G_EXCEPTION_HALT_VALIDATION;
                                             ELSE
                                                l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                           ,l_currency_code
                                                                                           ,l_receipt_date
                                                                                           ,l_exchange_rate_type
                                                                                           );

                                                IF l_conversion_rate IN (0,-1) THEN

                                                    -- Message Text: No exchange rate defined
                                                    x_return_status := okl_api.G_RET_STS_ERROR;
                                                    okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                         p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                                    RAISE G_EXCEPTION_HALT_VALIDATION;
                                                END IF;
                                             END IF;
                                          ELSE
                                            l_conversion_rate := l_inv_to_rct_rate;
                                          END IF;
                                           l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                        ELSE
                                           l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                        END IF;
                                       l_inv_total_amt := l_inv_total_amt + l_rcpt_tbl(j).AMOUNT_APPLIED;
                                               EXIT WHEN (j = l_rcpt_tbl.LAST);
                                       j := j + 1;
                                            END LOOP;
                                    l_diff_amount := l_amount_app_to - l_inv_total_amt;
                                    if l_diff_amount > 0 then
                                      l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied := l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied + l_diff_amount;
                                      IF l_currency_code <> l_inv_curr_code THEN
                                          IF l_inv_to_rct_rate is null THEN
                                             l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                             log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                             IF l_exchange_rate_type IS  NULL THEN
                                                OKL_API.set_message( p_app_name      => G_APP_NAME
                                                                    ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                                   );
                                                RAISE G_EXCEPTION_HALT_VALIDATION;
                                             ELSE
                                                l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                           ,l_currency_code
                                                                                           ,l_receipt_date
                                                                                           ,l_exchange_rate_type
                                                                                           );

                                                IF l_conversion_rate IN (0,-1) THEN

                                                    -- Message Text: No exchange rate defined
                                                    x_return_status := okl_api.G_RET_STS_ERROR;
                                                    okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                         p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                                    RAISE G_EXCEPTION_HALT_VALIDATION;
                                                END IF;
                                             END IF;
                                          ELSE
                                            l_conversion_rate := l_inv_to_rct_rate;
                                          END IF;
                                           l_rcpt_tbl(l_rcpt_tbl.LAST).trans_to_receipt_rate := l_conversion_rate;

                                           l_rcpt_tbl(l_rcpt_tbl.LAST).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(l_rcpt_tbl.LAST).AMOUNT_APPLIED * l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);

                                        ELSE
                                           l_rcpt_tbl(l_rcpt_tbl.LAST).trans_to_receipt_rate := null;
                                           l_rcpt_tbl(l_rcpt_tbl.LAST).AMOUNT_APPLIED_FROM  := null;
                                        END IF;
                                    end if;
                                    log_debug('l_amount_app_from = '||l_amount_app_from);

                                  /*  if l_diff_amount > 0 then
                                      l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied_from := l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied_from + l_diff_amount;
                                    END IF;*/
                                    log_debug('l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied_from = '||l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied_from);
                                         END IF;-- bug 5221326
                         END IF; -- (3)
               ELSE -- EXACT or OVERPAYMENT or TOLERANCE  (2)
                         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'EXACT or OVERPAYMENT or TOLERANCE');
                         END IF;

                         -- CREATE LINES TABLE
                         FOR i IN open_inv_contract_tbl.FIRST..open_inv_contract_tbl.LAST
                         LOOP
                                          c_all_open_invs_rec := open_inv_contract_tbl(i);
                                      EXIT WHEN l_amount_app_to = 0 OR l_amount_app_to IS NULL;
                                       j := j + 1;
                                        --Populate receipt table
                                        l_rcpt_tbl(j).INVOICE_ID := c_all_open_invs_rec.ar_invoice_id;
                                                l_rcpt_tbl(j).INVOICE_NUMBER := c_all_open_invs_rec.invoice_number;
                                        l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_code;
                                        l_rcpt_tbl(j).INVOICE_LINE_ID := c_all_open_invs_rec.invoice_line_id;
                                                l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_all_open_invs_rec.line_identifier;
                                       --Amount Applied will be total amount applied including line and tax
                                            l_rcpt_tbl(j).AMOUNT_APPLIED := c_all_open_invs_rec.amount_due_remaining;
                                                   IF l_amount_app_to < l_rcpt_tbl(j).AMOUNT_APPLIED THEN
                                                    l_rcpt_tbl(j).AMOUNT_APPLIED := l_amount_app_to;
                                                    l_amount_app_to := 0;
                                                   ELSE
                                                        l_amount_app_to := l_amount_app_to - l_rcpt_tbl(j).AMOUNT_APPLIED;
                                                   END IF;
                                        IF l_currency_code <> l_inv_curr_code THEN
                                          IF l_inv_to_rct_rate is null THEN
                                             l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                             log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                             IF l_exchange_rate_type IS  NULL THEN
                                                OKL_API.set_message( p_app_name      => G_APP_NAME
                                                                    ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                                   );
                                                RAISE G_EXCEPTION_HALT_VALIDATION;
                                             ELSE
                                                l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                           ,l_currency_code
                                                                                           ,l_receipt_date
                                                                                           ,l_exchange_rate_type
                                                                                           );

                                                IF l_conversion_rate IN (0,-1) THEN

                                                    -- Message Text: No exchange rate defined
                                                    x_return_status := okl_api.G_RET_STS_ERROR;
                                                    okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                         p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                                    RAISE G_EXCEPTION_HALT_VALIDATION;
                                                END IF;
                                             END IF;
                                          ELSE
                                            l_conversion_rate := l_inv_to_rct_rate;
                                          END IF;
                                           l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                        ELSE
                                           l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                        END IF;
                                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).INVOICE_LINE_NUMBER : '||l_rcpt_tbl(j).INVOICE_LINE_NUMBER);
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
                                        END IF;
                       END LOOP;

                      -- Apply the remaining balance as per the Cash Application Rule
                       If l_over_payment In ('B','b') Then  -- Onaccount --move cash to customer balances -OVP
                            IF l_currency_code = l_inv_curr_code THEN
                             l_onacc_amount:=l_amount_app_to;
                           ELSE
                             l_onacc_amount:= l_amount_app_to * l_conversion_rate;
                             l_onacc_amount := GET_ROUNDED_AMOUNT(l_onacc_amount,l_currency_code);
                           END IF;
                       Elsif l_over_payment In ('F','f') Then --Unapply  -- move cash to unapplied -OVP
                            IF l_currency_code = l_inv_curr_code THEN
                             l_unapply_amount:=l_amount_app_to;
                           ELSE
                             l_unapply_amount:= l_amount_app_to * l_conversion_rate;
                             l_unapply_amount := GET_ROUNDED_AMOUNT(l_unapply_amount,l_currency_code);
                           END IF;
                       End If;

                 END IF; -- under payment. (2)
              END IF; -- VR 07-Oct-2005 GE-20 Receipts - On Account CAR
              --  **********************************************
              --  Contract level cash application processing ends.
              --  *************************************************

           END IF;  /* l_contract_num IS NOT NULL check  Ends*/
       END IF;  /* l_last_contract_id <> l_contract_id  check Ends */

       END LOOP;
       CLOSE c_get_contract_num;
   END IF;  /*  Process if l_same_date = 'N' : Ends */
   log_debug('Calling get_applications');

   GET_APPLICATIONS(l_rcpt_tbl,x_appl_tbl);

   log_debug('Called get_applications');
   l_tot_amt_app_from := 0;
   IF x_appl_tbl.COUNT > 0 THEN
     IF x_appl_tbl(x_appl_tbl.FIRST).inv_hdr_rec.trans_to_receipt_rate IS NOT NULL THEN
       FOR ll IN x_appl_tbl.FIRST..x_appl_tbl.LAST LOOP
         l_tot_amt_app_from := l_tot_amt_app_from + nvl(x_appl_tbl(ll).inv_hdr_rec.amount_applied_from,0);
       END LOOP;
      IF (l_onacc_amount + l_unapply_amount + l_tot_amt_app_from ) <> l_amount_app_from THEN
         l_diff_amount := l_amount_app_from - (l_onacc_amount + l_unapply_amount + l_tot_amt_app_from );
         log_debug('l_diff_amount = '||l_diff_amount);
         IF nvl(l_onacc_amount,0) <> 0  THEN
           l_onacc_amount := l_onacc_amount + l_diff_amount;
           log_debug('l_onacc_amount = '||l_onacc_amount);
         ELSIF nvl(l_unapply_amount,0) <> 0  THEN
           l_unapply_amount := l_unapply_amount + l_diff_amount;
         END IF;
       END IF;
    END IF;
  END IF;

    x_onacc_amount :=l_onacc_amount;
    x_unapply_amount :=l_unapply_amount;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done execution of OKL_AUTO_CASH_APPL_RULES_PVT.auto_cashapp_for_arinv ...');
    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
    x_return_status := OKL_API.G_RET_STS_ERROR;
    x_appl_tbl.delete;

   WHEN No_Open_Invoices_Exception THEN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
    x_appl_tbl.delete;

    WHEN OTHERS THEN
    x_appl_tbl.DELETE;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;


END auto_cashapp_for_arinv;

/*---------------------------------------------------------------------------
-- Cash Application Rules for AR Invoice Number Ends
-- End - varangan - receipts project
---------------------------------------------------------------------------*/

--START: Bug 6275659 by nikshah

--Identifies all invoice lines to be applied against for a given contract number
--based on CAR setup for the contract
PROCEDURE auto_cashapp_for_contract(p_api_version           IN   NUMBER
                                ,p_init_msg_list    IN   VARCHAR2        DEFAULT Okc_Api.G_FALSE
                                ,x_return_status    OUT  NOCOPY VARCHAR2
                                ,x_msg_count        OUT  NOCOPY NUMBER
                                ,x_msg_data             OUT  NOCOPY VARCHAR2
                                ,p_customer_num     IN   VARCHAR2        DEFAULT NULL
                                ,p_contract_num     IN   VARCHAR2        DEFAULT NULL
                                ,p_currency_code    IN   VARCHAR2
                                ,p_amount_app_to     IN  NUMBER DEFAULT NULL
                                ,p_amount_app_from   IN  NUMBER DEFAULT NULL
                                ,p_inv_to_rct_rate   IN  NUMBER DEFAULT NULL
                                ,p_receipt_date      IN  DATE
                                ,p_org_id               IN   NUMBER
                                ,x_appl_tbl         OUT  NOCOPY  okl_appl_dtls_tbl_type
                                ,x_onacc_amount        OUT NOCOPY NUMBER
                                ,x_unapply_amount      OUT NOCOPY NUMBER
                                ) IS

  --Variables declaration
  l_dflt_cat_id                 OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
  l_dflt_tolerance                          OKL_CASH_ALLCTN_RLS.AMOUNT_TOLERANCE_PERCENT%TYPE DEFAULT NULL;
  l_dflt_days_past_quote_valid  OKL_CASH_ALLCTN_RLS.DAYS_PAST_QUOTE_VALID_TOLERANC%TYPE DEFAULT NULL;
  l_dflt_months_to_bill_ahead   OKL_CASH_ALLCTN_RLS.MONTHS_TO_BILL_AHEAD%TYPE DEFAULT NULL;
  l_dflt_under_payment              OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_dflt_over_payment               OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_dflt_receipt_msmtch             OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE DEFAULT NULL;

  l_msg_count                           NUMBER;
  l_msg_data                            VARCHAR2(2000);

  l_contract_id                         NUMBER;
  l_contract_num                OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE := p_contract_num;
  l_customer_num                        HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE  := p_customer_num;
  l_currency_code                       VARCHAR2(45)  := p_currency_code;
  l_amount_app_from     NUMBER            := p_amount_app_from;
  l_amount_app_to       NUMBER            := p_amount_app_to;
  l_inv_to_rct_rate     NUMBER            := p_inv_to_rct_rate;
  l_inv_curr_Code       VARCHAR2(45);
  l_receipt_Date        DATE := p_receipt_date;
  l_cross_curr_enabled  varchar2(3):='N';
  l_conversion_rate     NUMBER;
  l_exchange_rate_type  VARCHAR2(45);

  l_org_id                      NUMBER        := p_org_id;
  j                             NUMBER;
  i                             NUMBER;

  l_over_pay                    VARCHAR(1)    DEFAULT NULL;
  l_ordered                                 CONSTANT      VARCHAR2(3) := 'ODD';
  l_prorate                                 CONSTANT      VARCHAR2(3) := 'PRO';
  l_appl_tolerance                      NUMBER;
  l_has_invoices                        BOOLEAN;
  l_valid_contract                      BOOLEAN;
  l_temp_val                            NUMBER;
  l_inv_tot                                 NUMBER              := 0;
  l_pro_rate_inv_total              NUMBER              := 0;
  l_diff_amount                 NUMBER      := 0;
  l_inv_total_amt               NUMBER      := 0;

  l_cau_id                      OKL_CSH_ALLCTN_RL_HDR.ID%TYPE DEFAULT NULL;
  l_cat_id                      OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
  l_sty_id                                  OKL_CNSLD_AR_STRMS_V.STY_ID%TYPE;
  l_tolerance                           OKL_CASH_ALLCTN_RLS.AMOUNT_TOLERANCE_PERCENT%TYPE;
  l_days_past_quote_valid           OKL_CASH_ALLCTN_RLS.DAYS_PAST_QUOTE_VALID_TOLERANC%TYPE;
  l_months_to_bill_ahead            OKL_CASH_ALLCTN_RLS.MONTHS_TO_BILL_AHEAD%TYPE;
  l_under_payment                       OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE;
  l_over_payment                        OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE;
  l_receipt_msmtch                      OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE;


  --Record/Table Definitions
  l_rcpt_tbl    okl_auto_cash_appl_rules_pvt.okl_rcpt_dtls_tbl_type;
  l_appl_tbl    okl_auto_cash_appl_rules_pvt.okl_appl_dtls_tbl_type;
  l_tot_amt_app_from NUMBEr := 0;

  --Cursor definitions

  CURSOR   c_open_invoices_contract ( cp_org_id         IN NUMBER
                                     ,cp_contract_id    IN NUMBER) IS
    SELECT  AR_INVOICE_ID,
            AR_INVOICE_NUMBER,
            INVOICE_LINE_ID,
            LINE_NUMBER,
            AMOUNT_DUE_REMAINING,
            STY_ID
    FROM    OKL_RCPT_CUST_CONT_BALANCES_UV
    WHERE   KHR_ID = cp_contract_id
    AND     ORG_ID = cp_org_id
    AND     STATUS = 'OP';

  -- Bug 7022180 by nikshah:
  -- Splitted c_open_invoices_contract into two.
  -- Removed nvl condition from above cursor and attached direct join in
  -- c_open_invoices_contract_cust curose
  CURSOR   c_open_invoices_contract_cust ( cp_org_id         IN NUMBER
                                          ,cp_contract_id    IN NUMBER
                                          ,cp_customer_num   IN VARCHAR2) IS
    SELECT  AR_INVOICE_ID,
            AR_INVOICE_NUMBER,
            INVOICE_LINE_ID,
            LINE_NUMBER,
            AMOUNT_DUE_REMAINING,
            STY_ID
    FROM    OKL_RCPT_CUST_CONT_BALANCES_UV
    WHERE   KHR_ID = cp_contract_id
    --asawanka changed for bug #5391874
    AND     CUSTOMER_ACCOUNT_NUMBER = cp_customer_num
    AND     ORG_ID = cp_org_id
    AND     STATUS = 'OP';

    c_open_invoices_contract_rec c_open_invoices_contract%ROWTYPE;
    TYPE open_inv_contract_tbl_type IS TABLE OF c_open_invoices_contract%ROWTYPE INDEX BY BINARY_INTEGER;
    open_inv_contract_tbl open_inv_contract_tbl_type;

   -- get stream application order
  CURSOR   c_stream_alloc ( cp_str_all_type IN VARCHAR2
                           ,cp_cat_id       IN NUMBER ) IS
    SELECT      sty_id
        FROM    OKL_STRM_TYP_ALLOCS
        WHERE   stream_allc_type = cp_str_all_type
    AND     cat_id = cp_cat_id
        ORDER BY sequence_number;

  CURSOR   c_cash_rle_id_csr ( cp_khr_id IN NUMBER) IS
    SELECT  to_number(a.object1_id1)
    FROM    OKC_RULES_B a, OKC_RULE_GROUPS_B b
    WHERE   a.rgp_id = b.id
    AND     b.rgd_code = 'LABILL'
    AND     a.rule_information_category = 'LAINVD'
    AND     a.dnz_chr_id = b.chr_id
    AND     a.dnz_chr_id = cp_khr_id;

  -- get cash applic rule for contract
  CURSOR   c_cash_rule_csr  ( cp_cau_id IN NUMBER ) IS
    SELECT  ID
           ,AMOUNT_TOLERANCE_PERCENT
           ,DAYS_PAST_QUOTE_VALID_TOLERANC
           ,MONTHS_TO_BILL_AHEAD
           ,UNDER_PAYMENT_ALLOCATION_CODE
           ,OVER_PAYMENT_ALLOCATION_CODE
           ,RECEIPT_MSMTCH_ALLOCATION_CODE
    FROM    OKL_CASH_ALLCTN_RLS_ALL
    WHERE   CAU_ID = cp_cau_id
    AND     START_DATE <= trunc(SYSDATE)
    AND     (END_DATE >= trunc(SYSDATE) OR END_DATE IS NULL);

  -- get a contract id if not known
  CURSOR   c_get_contract_id (cp_contract_num IN VARCHAR2) IS
    SELECT  ID CONTRACT_ID, currency_code
    FROM        OKC_K_HEADERS_ALL_B
    WHERE       contract_number = cp_contract_num;

l_unapply_amount NUMBER:=0;
l_onacc_amount NUMBER:=0;

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Starting execution of OKL_AUTO_CASH_APPL_RULES_PVT.auto_cashapp_for_contract ...');
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Procedure parameters, p_customer_num : '|| p_customer_num);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_contract_num : '|| p_contract_num);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_currency_code : '|| p_currency_code);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_amount_app_to : '|| p_amount_app_to);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_org_id : '|| p_org_id);
  END IF;

  --Check whether contract number provided is having any open invoices or not
  l_valid_contract := FALSE;
  OPEN c_get_contract_id(l_contract_num);
  FETCH c_get_contract_id INTO l_contract_id,l_inv_curr_Code;
  IF c_get_contract_id%FOUND THEN
    l_valid_contract := TRUE;
  END IF;
  CLOSE c_get_contract_id;

  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract is valid');
  IF (l_valid_contract = FALSE) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract is not valid');
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    RETURN;
  ELSE
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract is valid');
  END IF;

  l_has_invoices := FALSE;
  i := 0;
  IF l_customer_num IS NOT NULL THEN
    OPEN c_open_invoices_contract_cust(l_org_id, l_contract_id, l_customer_num);
    LOOP
      FETCH c_open_invoices_contract_cust INTO c_open_invoices_contract_rec;
      EXIT WHEN c_open_invoices_contract_cust%NOTFOUND;
      IF c_open_invoices_contract_rec.amount_due_remaining > 0 THEN
        i := i + 1;
        open_inv_contract_tbl(i) := c_open_invoices_contract_rec;
        l_has_invoices := TRUE;
      END IF;
    END LOOP;
    i := 0;
    CLOSE c_open_invoices_contract_cust;
  ELSE
    OPEN c_open_invoices_contract(l_org_id, l_contract_id);
    LOOP
      FETCH c_open_invoices_contract INTO c_open_invoices_contract_rec;
      EXIT WHEN c_open_invoices_contract%NOTFOUND;
      IF c_open_invoices_contract_rec.amount_due_remaining > 0 THEN
        i := i + 1;
        open_inv_contract_tbl(i) := c_open_invoices_contract_rec;
        l_has_invoices := TRUE;
      END IF;
    END LOOP;
    i := 0;
    CLOSE c_open_invoices_contract;
  END IF;
  IF (l_has_invoices = FALSE) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract is having no open invoices');
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    RETURN;
  ELSE
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract is having open invoices');
  END IF;

  log_debug('Receipt Currency = '||l_currency_code);
  log_debug('Contract Currency = '||l_inv_curr_Code);
  log_debug('l_amount_app_from = '||l_amount_app_from);
  log_debug('l_amount_app_to = '||l_amount_app_to);
  log_debug('l_inv_to_rct_rate = '||l_inv_to_rct_rate);
  IF l_currency_code = l_inv_curr_Code THEN
          IF l_amount_app_from IS NULL AND l_amount_app_to IS NULL THEN
            OKL_API.set_message( p_app_name      => G_APP_NAME
                                ,p_msg_name      => 'OKL_BPD_INVALID_PARAMS'
                                      );
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSIF l_amount_app_from IS NULL THEN
             l_amount_app_from := l_amount_app_to;
          ELSE
             l_amount_app_to := l_amount_app_from;
          END IF;
  ELSE
          IF l_amount_app_from IS NOT NULL AND l_amount_app_to IS NOT NULL AND l_inv_to_rct_rate IS NOT NULL THEN
            IF ( l_amount_app_to * l_inv_to_rct_rate) <> l_amount_app_from THEN
              OKL_API.set_message( p_app_name      => G_APP_NAME
                                        ,p_msg_name      => 'OKL_BPD_PARAMS_MISMATCH'
                                              );
            END IF;
            IF l_inv_to_rct_rate <> 0 and ( ( l_amount_app_from / l_inv_to_rct_rate) <> l_amount_app_to) THEN
              OKL_API.set_message( p_app_name      => G_APP_NAME
                                        ,p_msg_name      => 'OKL_BPD_PARAMS_MISMATCH'
                                              );
            END IF;
          END IF;
          l_cross_curr_enabled := nvl(FND_PROFILE.value('AR_ENABLE_CROSS_CURRENCY'),'N');
          log_debug('l_cross_curr_enabled = '||l_cross_curr_enabled);
       /*   IF l_cross_curr_enabled <> 'Y' THEN
            OKL_API.set_message( p_app_name      => G_APP_NAME
                                ,p_msg_name      => 'OKL_BPD_CROSS_CURR_NA'
                                      );
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE*/
             IF l_inv_to_rct_rate is null THEN
               l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
               log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
               IF l_exchange_rate_type IS  NULL THEN
                  OKL_API.set_message( p_app_name      => G_APP_NAME
                                      ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                     );
                  RAISE G_EXCEPTION_HALT_VALIDATION;
               ELSE
                  l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                             ,l_currency_code
                                                             ,l_receipt_date
                                                             ,l_exchange_rate_type
                                                             );

                  IF l_conversion_rate IN (0,-1) THEN

                      -- Message Text: No exchange rate defined
                      x_return_status := okl_api.G_RET_STS_ERROR;
                      okl_api.set_message( p_app_name      => G_APP_NAME,
                                           p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                      RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;
               END IF;
            ELSE
              l_conversion_rate := l_inv_to_rct_rate;
            END IF;
            log_debug('l_conversion_rate ='||l_conversion_rate);
            IF l_amount_app_from IS NULL AND l_amount_app_to IS NULL THEN
                OKL_API.set_message( p_app_name      => G_APP_NAME
                                    ,p_msg_name      => 'OKL_BPD_INVALID_PARAMS'
                                   );
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSIF l_amount_app_from IS NULL THEN
               l_amount_app_from := l_amount_app_to * l_conversion_rate;
            ELSE
               l_amount_app_to := l_amount_app_from * (1/l_conversion_rate);
            END IF;
          --END IF;
  END IF;
  l_amount_app_from := arp_util.CurrRound(l_amount_app_from,l_currency_code);
  l_amount_app_to := arp_util.CurrRound(l_amount_app_to,l_inv_curr_code);
  log_debug('l_amount_app_from = '||l_amount_app_from);
  log_debug('l_amount_app_to = '||l_amount_app_to);
  log_debug('l_inv_to_rct_rate = '||l_inv_to_rct_rate);

  --get default cash application rules.
  get_default_cash_app_rule( p_org_id => l_org_id
                            ,x_dflt_cat_id => l_dflt_cat_id
                            ,x_dflt_tolerance => l_dflt_tolerance
                            ,x_dflt_days_past_quote_valid => l_dflt_days_past_quote_valid
                            ,x_dflt_months_to_bill_ahead => l_dflt_months_to_bill_ahead
                            ,x_dflt_under_payment => l_dflt_under_payment
                            ,x_dflt_over_payment => l_dflt_over_payment
                            ,x_dflt_receipt_msmtch => l_dflt_receipt_msmtch);

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Default Tolerance: ' || l_dflt_tolerance);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Default Under Payment: ' || l_dflt_under_payment);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Default Over Payment: ' || l_dflt_over_payment);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Default Receipt Mismatch: ' || l_dflt_receipt_msmtch);
  END IF;

  --If default cash application rule is not defined then
  --raise an exception
 -- sosharma Modified the check for bug 9771644
/*  IF l_dflt_tolerance IS NULL OR l_dflt_under_payment IS NULL
        OR l_dflt_over_payment IS NULL OR l_dflt_receipt_msmtch IS NULL THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;*/

 IF l_dflt_tolerance IS NULL OR l_dflt_under_payment IS NULL
        OR l_dflt_over_payment IS NULL THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- START OKL CASH APPLICATION.
  IF l_contract_num IS NOT NULL THEN
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside if block of l_contract_num is not null ');
    END IF;

    IF l_contract_id IS NULL THEN
      OPEN c_get_contract_id(l_contract_num);
      FETCH c_get_contract_id INTO l_contract_id,l_inv_curr_Code;
      CLOSE c_get_contract_id;
    END IF;

    --get cash application rule
    OPEN c_cash_rle_id_csr (l_contract_id);
    FETCH c_cash_rle_id_csr INTO l_cau_id;
    CLOSE c_cash_rle_id_csr;

    IF l_cau_id IS NOT NULL THEN
      OPEN c_cash_rule_csr (l_cau_id);
      FETCH c_cash_rule_csr INTO  l_cat_id
                                 ,l_tolerance
                                 ,l_days_past_quote_valid
                                 ,l_months_to_bill_ahead
                                 ,l_under_payment
                                 ,l_over_payment
                                         ,l_receipt_msmtch;
      CLOSE c_cash_rule_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tolerance : '||l_tolerance);
      END IF;

          IF l_tolerance IS NULL THEN
        l_cat_id                := l_dflt_cat_id;
        l_tolerance             := l_dflt_tolerance;
        l_days_past_quote_valid := l_dflt_days_past_quote_valid;
                l_months_to_bill_ahead  := l_dflt_months_to_bill_ahead;
                l_under_payment         := l_dflt_under_payment;
                l_over_payment          := l_dflt_over_payment;
                l_receipt_msmtch        := l_dflt_receipt_msmtch;
      END IF;
    ELSE -- use default rule

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Using default CAR since l_cau_id is NULL');
      END IF;
      l_cat_id                := l_dflt_cat_id;
      l_tolerance             := l_dflt_tolerance;
      l_days_past_quote_valid := l_dflt_days_past_quote_valid;
      l_months_to_bill_ahead  := l_dflt_months_to_bill_ahead;
      l_under_payment         := l_dflt_under_payment;
      l_over_payment          := l_dflt_over_payment;
      l_receipt_msmtch        := l_dflt_receipt_msmtch;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Opening cursor c_open_invoices_contract ('||l_contract_num||', '||l_customer_num||', NULL)..');
    END IF;

    IF NVL(l_cau_id, 0) = -1 THEN  -- VR 07-Oct-2005 GE-20 Receipts - On Account CAR
                                       -- Receipt needs to be left as unapplied
      j := 1;
      l_rcpt_tbl(j).INVOICE_ID := NULL;
      l_rcpt_tbl(j).INVOICE_LINE_ID := NULL;
          l_rcpt_tbl(j).INVOICE_LINE_NUMBER := NULL;
      l_rcpt_tbl(j).INVOICE_NUMBER        := NULL;
      l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_Code;
      l_rcpt_tbl(j).AMOUNT_APPLIED        := l_amount_app_to;
    ELSE

      FOR i IN open_inv_contract_tbl.FIRST..open_inv_contract_tbl.LAST
      LOOP
        --l_invoice_currency_code := c_open_invoices_contract_rec.currency_code;
        l_inv_tot := l_inv_tot + open_inv_contract_tbl(i).amount_due_remaining;  -- changed from remaining to original
      END LOOP;
      -- TOLERANCE CHECK

      IF l_inv_tot > l_amount_app_to THEN
        l_appl_tolerance := l_inv_tot * (1 - l_tolerance / 100);
      ELSE
            l_appl_tolerance := l_inv_tot;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_inv_tot : ' || l_inv_tot);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_amount_app_to : ' || l_amount_app_to);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_appl_tolerance : ' || l_appl_tolerance);
      END IF;

          IF l_inv_tot > l_amount_app_to AND l_appl_tolerance > l_amount_app_to THEN -- UNDERPAYMENT  (2)
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'auto_cashapp_for_contract > UNDERPAYMENT ...');
        END IF;

        IF l_under_payment In ('U','u') THEN -- Unapply underpayment (3)
             IF l_currency_code = l_inv_curr_code THEN
               l_unapply_amount:=l_amount_app_to;
             ELSE
               l_unapply_amount:= l_amount_app_to * l_conversion_rate;
               l_unapply_amount:=GET_ROUNDED_AMOUNT(l_unapply_amount,l_currency_code);
             END IF;
        ELSIF l_under_payment IN ('T','t') THEN -- ORDERED (3)
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ORDERED ...');
          END IF;

          j := 0;
                  OPEN c_stream_alloc (l_ordered, l_cat_id);
                  LOOP
                    FETCH c_stream_alloc INTO l_sty_id;
                        EXIT WHEN c_stream_alloc%NOTFOUND OR l_amount_app_to = 0 OR l_amount_app_to IS NULL;

                        FOR i IN open_inv_contract_tbl.FIRST..open_inv_contract_tbl.LAST
            LOOP
              c_open_invoices_contract_rec := open_inv_contract_tbl(i);
              IF c_open_invoices_contract_rec.sty_id = l_sty_id THEN
                            EXIT WHEN l_amount_app_to = 0 OR l_amount_app_to IS NULL;
                j := j + 1;
                l_rcpt_tbl(j).AMOUNT_APPLIED  := c_open_invoices_contract_rec.amount_due_remaining;
                            IF l_rcpt_tbl(j).AMOUNT_APPLIED > l_amount_app_to THEN
                  l_rcpt_tbl(j).AMOUNT_APPLIED := l_amount_app_to;
                  l_amount_app_to := 0;
                            ELSE
                  l_amount_app_to := l_amount_app_to - l_rcpt_tbl(j).AMOUNT_APPLIED;
                            END IF;
                l_rcpt_tbl(j).INVOICE_NUMBER        := c_open_invoices_contract_rec.ar_invoice_number;
                l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_Code;
                l_rcpt_tbl(j).INVOICE_ID := c_open_invoices_contract_rec.ar_invoice_id;
                l_rcpt_tbl(j).INVOICE_LINE_ID := c_open_invoices_contract_rec.invoice_line_id;
                l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_open_invoices_contract_rec.line_number;
                IF l_currency_code <> l_inv_curr_code THEN
                  IF l_inv_to_rct_rate is null THEN
                     l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                     log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                     IF l_exchange_rate_type IS  NULL THEN
                        OKL_API.set_message( p_app_name      => G_APP_NAME
                                            ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                           );
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                     ELSE
                        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                   ,l_currency_code
                                                                   ,l_receipt_date
                                                                   ,l_exchange_rate_type
                                                                   );

                        IF l_conversion_rate IN (0,-1) THEN

                            -- Message Text: No exchange rate defined
                            x_return_status := okl_api.G_RET_STS_ERROR;
                            okl_api.set_message( p_app_name      => G_APP_NAME,
                                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                            RAISE G_EXCEPTION_HALT_VALIDATION;
                        END IF;
                     END IF;
                  ELSE
                    l_conversion_rate := l_inv_to_rct_rate;
                  END IF;
                   l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                ELSE
                   l_rcpt_tbl(j).trans_to_receipt_rate := null;
                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                END IF;
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_ID : '||l_rcpt_tbl(j).INVOICE_ID);
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_LINE_ID : '||l_rcpt_tbl(j).INVOICE_LINE_ID);
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_LINE_NUMBER : '||l_rcpt_tbl(j).INVOICE_LINE_NUMBER);
                END IF;
              END IF;
            END LOOP;
          END LOOP;
          CLOSE c_stream_alloc;

                ELSIF l_under_payment IN ('P','p') THEN -- PRO RATE (3)
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'PRO RATE');
          END IF;

          j := 0;
                  -- obtain all the streams that are part of the pro rate user defined list.

                  FOR c_stream_alloc_rec IN c_stream_alloc (l_prorate, l_cat_id)
                  LOOP
                    l_sty_id := c_stream_alloc_rec.sty_id;
                        FOR i IN open_inv_contract_tbl.FIRST..open_inv_contract_tbl.LAST
                        LOOP
                          c_open_invoices_contract_rec := open_inv_contract_tbl(i);
                          IF c_open_invoices_contract_rec.sty_id = l_sty_id THEN
                j := j + 1;
                l_rcpt_tbl(j).INVOICE_NUMBER        := c_open_invoices_contract_rec.ar_invoice_number;
                l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_Code;
                l_rcpt_tbl(j).INVOICE_ID := c_open_invoices_contract_rec.ar_invoice_id;
                l_rcpt_tbl(j).INVOICE_LINE_ID := c_open_invoices_contract_rec.invoice_line_id;
                l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_open_invoices_contract_rec.line_number;
                l_rcpt_tbl(j).AMOUNT_APPLIED        := c_open_invoices_contract_rec.amount_due_remaining;
                            l_pro_rate_inv_total                := l_pro_rate_inv_total + l_rcpt_tbl(j).AMOUNT_APPLIED;

                IF l_currency_code <> l_inv_curr_code THEN
                  IF l_inv_to_rct_rate is null THEN
                     l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                     log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                     IF l_exchange_rate_type IS  NULL THEN
                        OKL_API.set_message( p_app_name      => G_APP_NAME
                                            ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                           );
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                     ELSE
                        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                   ,l_currency_code
                                                                   ,l_receipt_date
                                                                   ,l_exchange_rate_type
                                                                   );

                        IF l_conversion_rate IN (0,-1) THEN

                            -- Message Text: No exchange rate defined
                            x_return_status := okl_api.G_RET_STS_ERROR;
                            okl_api.set_message( p_app_name      => G_APP_NAME,
                                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                            RAISE G_EXCEPTION_HALT_VALIDATION;
                        END IF;
                     END IF;
                  ELSE
                    l_conversion_rate := l_inv_to_rct_rate;
                  END IF;
                   l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                ELSE
                   l_rcpt_tbl(j).trans_to_receipt_rate := null;
                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                END IF;
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_ID : '||l_rcpt_tbl(j).INVOICE_ID);
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_LINE_ID : '||l_rcpt_tbl(j).INVOICE_LINE_ID);
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_LINE_NUMBER : '||l_rcpt_tbl(j).INVOICE_LINE_NUMBER);
                END IF;
              END IF;
                        END LOOP; -- c_open_invs
                  END LOOP; -- c_stream_alloc

                  -- Calc Pro Ration
                  -- only if total amount of prorated invoices is greater than receipt
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_pro_rate_inv_total: '||l_pro_rate_inv_total);
          END IF;
          IF l_pro_rate_inv_total IS NULL OR l_pro_rate_inv_total = 0 THEN
            -- Message Text: No prorated transaction types
            --x_return_status := OKC_API.G_RET_STS_ERROR;
            --OKC_API.set_message( p_app_name      => G_APP_NAME,
            --                     p_msg_name      => 'OKL_BPD_NO_PRORATED_STRMS');
            --RAISE OKL_API.G_EXCEPTION_ERROR;
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Pro-rate invoice total is zero or null');
              x_return_status := OKC_API.G_RET_STS_SUCCESS;
              x_appl_tbl.delete;
              RETURN;
              END IF;

                  IF (l_pro_rate_inv_total > l_amount_app_to) THEN
            j := l_rcpt_tbl.FIRST;
                        l_temp_val := l_amount_app_to / l_pro_rate_inv_total;
                        LOOP
              l_rcpt_tbl(j).AMOUNT_APPLIED := l_temp_val * l_rcpt_tbl(j).AMOUNT_APPLIED;
              l_rcpt_tbl(j).AMOUNT_APPLIED:=GET_ROUNDED_AMOUNT(l_rcpt_tbl(j).AMOUNT_APPLIED,l_inv_curr_Code);
              l_inv_total_amt := l_inv_total_amt + l_rcpt_tbl(j).AMOUNT_APPLIED;
              IF l_currency_code <> l_inv_curr_code THEN
                  IF l_inv_to_rct_rate is null THEN
                     l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                     log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                     IF l_exchange_rate_type IS  NULL THEN
                        OKL_API.set_message( p_app_name      => G_APP_NAME
                                            ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                           );
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                     ELSE
                        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                   ,l_currency_code
                                                                   ,l_receipt_date
                                                                   ,l_exchange_rate_type
                                                                   );

                        IF l_conversion_rate IN (0,-1) THEN

                            -- Message Text: No exchange rate defined
                            x_return_status := okl_api.G_RET_STS_ERROR;
                            okl_api.set_message( p_app_name      => G_APP_NAME,
                                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                            RAISE G_EXCEPTION_HALT_VALIDATION;
                        END IF;
                     END IF;
                  ELSE
                    l_conversion_rate := l_inv_to_rct_rate;
                  END IF;
                   l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);

                ELSE
                   l_rcpt_tbl(j).trans_to_receipt_rate := null;
                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                END IF;
            EXIT WHEN (j = l_rcpt_tbl.LAST);
            j := j + 1;
                        END LOOP;
            l_diff_amount := l_amount_app_to - l_inv_total_amt;
            if l_diff_amount > 0 then
              l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied := l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied + l_diff_amount;
              IF l_currency_code <> l_inv_curr_code THEN
                  IF l_inv_to_rct_rate is null THEN
                     l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                     log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                     IF l_exchange_rate_type IS  NULL THEN
                        OKL_API.set_message( p_app_name      => G_APP_NAME
                                            ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                           );
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                     ELSE
                        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                   ,l_currency_code
                                                                   ,l_receipt_date
                                                                   ,l_exchange_rate_type
                                                                   );

                        IF l_conversion_rate IN (0,-1) THEN

                            -- Message Text: No exchange rate defined
                            x_return_status := okl_api.G_RET_STS_ERROR;
                            okl_api.set_message( p_app_name      => G_APP_NAME,
                                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                            RAISE G_EXCEPTION_HALT_VALIDATION;
                        END IF;
                     END IF;
                  ELSE
                    l_conversion_rate := l_inv_to_rct_rate;
                  END IF;
                   l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                ELSE
                   l_rcpt_tbl(j).trans_to_receipt_rate := null;
                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                END IF;
            end if;
                  END IF;
                END IF; -- (3)
      ELSE -- EXACT or OVERPAYMENT or TOLERANCE  (2)
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'auto_cashapp_for_contract > EXACT or OVERPAYMENT or TOLERANCE');
        END IF;

        j := 0;

        FOR i IN open_inv_contract_tbl.FIRST..open_inv_contract_tbl.LAST
        LOOP
              EXIT WHEN l_amount_app_to = 0 OR l_amount_app_to IS NULL;
              c_open_invoices_contract_rec := open_inv_contract_tbl(i);
          j := j + 1;

          l_rcpt_tbl(j).INVOICE_NUMBER        := c_open_invoices_contract_rec.ar_invoice_number;
          l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_Code;
          l_rcpt_tbl(j).INVOICE_ID := c_open_invoices_contract_rec.ar_invoice_id;
          l_rcpt_tbl(j).INVOICE_LINE_ID := c_open_invoices_contract_rec.invoice_line_id;
          l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_open_invoices_contract_rec.line_number;
              l_rcpt_tbl(j).AMOUNT_APPLIED        := c_open_invoices_contract_rec.amount_due_remaining;

                  IF l_amount_app_to < l_rcpt_tbl(j).AMOUNT_APPLIED THEN
                    -- TOLERANCE
            l_rcpt_tbl(j).AMOUNT_APPLIED := l_amount_app_to;
                        l_amount_app_to := 0;
                  ELSE
                    l_amount_app_to := l_amount_app_to - l_rcpt_tbl(j).AMOUNT_APPLIED;
                  END IF;
          IF l_currency_code <> l_inv_curr_code THEN
            IF l_inv_to_rct_rate is null THEN
               l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
               log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
               IF l_exchange_rate_type IS  NULL THEN
                  OKL_API.set_message( p_app_name      => G_APP_NAME
                                      ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                     );
                  RAISE G_EXCEPTION_HALT_VALIDATION;
               ELSE
                  l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                             ,l_currency_code
                                                             ,l_receipt_date
                                                             ,l_exchange_rate_type
                                                             );

                  IF l_conversion_rate IN (0,-1) THEN

                      -- Message Text: No exchange rate defined
                      x_return_status := okl_api.G_RET_STS_ERROR;
                      okl_api.set_message( p_app_name      => G_APP_NAME,
                                           p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                      RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;
               END IF;
            ELSE
              l_conversion_rate := l_inv_to_rct_rate;
            END IF;
             l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
             l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
             l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
          ELSE
             l_rcpt_tbl(j).trans_to_receipt_rate := null;
             l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
          END IF;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_ID : '||l_rcpt_tbl(j).INVOICE_ID);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_LINE_ID : '||l_rcpt_tbl(j).INVOICE_LINE_ID);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_LINE_NUMBER : '||l_rcpt_tbl(j).INVOICE_LINE_NUMBER);
          END IF;
        END LOOP;

        -- Apply the remaining balance as per the Cash Application Rule
        If l_over_payment In ('B','b') Then  -- Onaccount --move cash to customer balances -OVP
           IF l_currency_code = l_inv_curr_code THEN
             l_onacc_amount:=l_amount_app_to;
           ELSE
             l_onacc_amount:= l_amount_app_to * l_conversion_rate;
             l_onacc_amount:=GET_ROUNDED_AMOUNT(l_onacc_amount,l_currency_code);
           END IF;
        Elsif l_over_payment In ('F','f') Then --Unapply  -- move cash to unapplied -OVP
            IF l_currency_code = l_inv_curr_code THEN
               l_unapply_amount:=l_amount_app_to;
            ELSE
               l_unapply_amount:= l_amount_app_to * l_conversion_rate;
               l_unapply_amount:=GET_ROUNDED_AMOUNT(l_unapply_amount,l_currency_code);
            END IF;
        End If;

      END IF; -- under payment.;
    END IF;    -- VR 07-Oct-2005 GE-20 Receipts - On Account CAR

    --Get grouped application table (in the form of invoice header > multiple invoice lines table)
     GET_APPLICATIONS( p_rcpt_tbl => l_rcpt_tbl
                     ,x_appl_tbl => l_appl_tbl);
    x_appl_tbl := l_appl_tbl;
  END IF;

   l_tot_amt_app_from := 0;
   IF x_appl_tbl.COUNT > 0 THEN
     IF x_appl_tbl(x_appl_tbl.FIRST).inv_hdr_rec.trans_to_receipt_rate IS NOT NULL THEN
       FOR ll IN x_appl_tbl.FIRST..x_appl_tbl.LAST LOOP
         l_tot_amt_app_from := l_tot_amt_app_from + nvl(x_appl_tbl(ll).inv_hdr_rec.amount_applied_from,0);
       END LOOP;
      IF (l_onacc_amount + l_unapply_amount + l_tot_amt_app_from ) <> l_amount_app_from THEN
         l_diff_amount := l_amount_app_from - (l_onacc_amount + l_unapply_amount + l_tot_amt_app_from );
         log_debug('l_diff_amount = '||l_diff_amount);
         IF nvl(l_onacc_amount,0) <> 0  THEN
           l_onacc_amount := l_onacc_amount + l_diff_amount;
           log_debug('l_onacc_amount = '||l_onacc_amount);
         ELSIF nvl(l_unapply_amount,0) <> 0  THEN
           l_unapply_amount := l_unapply_amount + l_diff_amount;
         END IF;
       END IF;
    END IF;
  END IF;

x_onacc_amount   :=l_onacc_amount;
x_unapply_amount :=l_unapply_amount;

  x_return_status := OKL_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
  x_appl_tbl.DELETE;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    x_appl_tbl.delete;
  WHEN OTHERS THEN
  x_appl_tbl.DELETE;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data := sqlerrm;
END auto_cashapp_for_contract;



--Receipt mismatch which will identify all the invoice lines
--for the given customer based on CAR setup i.e. Newest invoices or Oldest invoices
PROCEDURE receipt_mismatch(p_api_version          IN   NUMBER
                          ,p_init_msg_list    IN   VARCHAR2        DEFAULT Okc_Api.G_FALSE
                          ,x_return_status    OUT  NOCOPY VARCHAR2
                          ,x_msg_count        OUT  NOCOPY NUMBER
                          ,x_msg_data         OUT  NOCOPY VARCHAR2
                          ,p_customer_num     IN   VARCHAR2        DEFAULT NULL
                          ,p_currency_code    IN   VARCHAR2
                          ,p_rcpt_amount          IN   NUMBER
                          ,p_org_id               IN   NUMBER
                          ,p_receipt_date  IN DATE
                          ,x_appl_tbl         OUT  NOCOPY  okl_appl_dtls_tbl_type
                          ,x_onacc_amount        OUT NOCOPY NUMBER
                                    ) IS

  --Variables declaration
  l_dflt_cat_id                 OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
  l_dflt_tolerance                          OKL_CASH_ALLCTN_RLS.AMOUNT_TOLERANCE_PERCENT%TYPE DEFAULT NULL;
  l_dflt_days_past_quote_valid  OKL_CASH_ALLCTN_RLS.DAYS_PAST_QUOTE_VALID_TOLERANC%TYPE DEFAULT NULL;
  l_dflt_months_to_bill_ahead   OKL_CASH_ALLCTN_RLS.MONTHS_TO_BILL_AHEAD%TYPE DEFAULT NULL;
  l_dflt_under_payment              OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_dflt_over_payment               OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_dflt_receipt_msmtch             OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE DEFAULT NULL;

  l_customer_num                        HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE  := p_customer_num;
  l_currency_code                       VARCHAR2(45)  := p_currency_code;
  l_rcpt_amount                         NUMBER            := p_rcpt_amount;
  l_org_id                      NUMBER        := p_org_id;
  j                             NUMBER;

  l_msg_count                           NUMBER;
  l_msg_data                            VARCHAR2(2000);

  --Record/Table Definitions
  l_rcpt_tbl    okl_rcpt_dtls_tbl_type;
  l_appl_tbl    okl_appl_dtls_tbl_type;

  --Cursor definitions

  CURSOR  c_all_open_invs (cp_customer_num IN VARCHAR2, cp_org_id IN NUMBER,cp_curr_code IN VARCHAR2) IS
  SELECT  AR_INVOICE_ID,
          AR_INVOICE_NUMBER,
          INVOICE_LINE_ID,
          LINE_NUMBER,
          AMOUNT_DUE_REMAINING,
          INVOICE_DUE_DATE
  FROM    OKL_RCPT_CUST_CONT_BALANCES_UV
  WHERE   CUSTOMER_ACCOUNT_NUMBER = cp_customer_num
  AND     ORG_ID = cp_org_id
  AND     STATUS = 'OP'
  AND     CURRENCY_CODE = cp_curr_code
 -- AND     AMOUNT_DUE_REMAINING > 0
  ORDER BY INVOICE_DUE_DATE;

  c_all_open_invs_rec c_all_open_invs%ROWTYPE;


  CURSOR  c_all_open_invs_desc (cp_customer_num IN VARCHAR2, cp_org_id IN NUMBER,cp_curr_code IN VARCHAR2) IS
  SELECT  AR_INVOICE_ID,
          AR_INVOICE_NUMBER,
          INVOICE_LINE_ID,
          LINE_NUMBER,
          AMOUNT_DUE_REMAINING,
                  INVOICE_DUE_DATE
  FROM    OKL_RCPT_CUST_CONT_BALANCES_UV
  WHERE   CUSTOMER_ACCOUNT_NUMBER = cp_customer_num
  AND     ORG_ID = cp_org_id
  AND     STATUS = 'OP'
 -- AND     AMOUNT_DUE_REMAINING > 0
  AND     CURRENCY_CODE = cp_curr_code
  ORDER BY INVOICE_DUE_DATE DESC;

  c_all_open_invs_desc_rec c_all_open_invs_desc%ROWTYPE;

l_onacc_amount  Number:=0;

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Starting execution of OKL_AUTO_CASH_APPL_RULES_PVT.receipt_mismatch ...');
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Procedure parameters, p_customer_num : '|| p_customer_num);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_org_id : '|| p_org_id);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_currency_code : '|| p_currency_code);
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_rcpt_amount : '|| p_rcpt_amount);
  END IF;

  --get default cash application rules.
  get_default_cash_app_rule( p_org_id => l_org_id
                            ,x_dflt_cat_id => l_dflt_cat_id
                            ,x_dflt_tolerance => l_dflt_tolerance
                            ,x_dflt_days_past_quote_valid => l_dflt_days_past_quote_valid
                            ,x_dflt_months_to_bill_ahead => l_dflt_months_to_bill_ahead
                            ,x_dflt_under_payment => l_dflt_under_payment
                            ,x_dflt_over_payment => l_dflt_over_payment
                            ,x_dflt_receipt_msmtch => l_dflt_receipt_msmtch);

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Default Tolerance: ' || l_dflt_tolerance);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Default Under Payment: ' || l_dflt_under_payment);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Default Over Payment: ' || l_dflt_over_payment);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Default Receipt Mismatch: ' || l_dflt_receipt_msmtch);
  END IF;

  --If default cash application rule is not defined then
  --raise an exception
  IF l_dflt_tolerance IS NULL OR l_dflt_under_payment IS NULL
        OR l_dflt_over_payment IS NULL OR l_dflt_receipt_msmtch IS NULL THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- START OKL CASH APPLICATION.

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Checking whether l_customer_num is not null ..');
  END IF;

  --If customer is not null then find open invoices for this customer
  IF l_customer_num IS NOT NULL THEN
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside branch for l_customer_num IS NOT NULL');
    END IF;
    j := 0;

    IF l_dflt_receipt_msmtch In ('A' ,'a') THEN -- Apply 'on-account'
        l_onacc_amount :=l_rcpt_amount;
    ELSIF l_dflt_receipt_msmtch = 'O' or                -- APPLY TO CUSTOMER'S OLDEST INVOICES FIRST
       l_dflt_receipt_msmtch = 'o' THEN
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Apply to customers oldest invoices first');
      END IF;
      OPEN c_all_open_invs (l_customer_num, l_org_id,l_currency_code);
          LOOP
            FETCH c_all_open_invs INTO c_all_open_invs_rec;
                EXIT WHEN c_all_open_invs%NOTFOUND OR l_rcpt_amount = 0 OR l_rcpt_amount IS NULL;
                IF c_all_open_invs_rec.AMOUNT_DUE_REMAINING > 0 THEN
          j := j + 1;

          --Populate receipt table
                  l_rcpt_tbl(j).INVOICE_ID := c_all_open_invs_rec.ar_invoice_id;
                  l_rcpt_tbl(j).INVOICE_NUMBER := c_all_open_invs_rec.ar_invoice_number;
          l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_currency_code;
          l_rcpt_tbl(j).INVOICE_LINE_ID := c_all_open_invs_rec.invoice_line_id;
                  l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_all_open_invs_rec.line_number;

          --Amount Applied will be total amount applied including line and tax
              l_rcpt_tbl(j).AMOUNT_APPLIED := c_all_open_invs_rec.amount_due_remaining;

                  IF l_rcpt_amount < l_rcpt_tbl(j).AMOUNT_APPLIED THEN
            l_rcpt_tbl(j).AMOUNT_APPLIED := l_rcpt_amount;
            l_rcpt_amount := 0;
          ELSE
                l_rcpt_amount := l_rcpt_amount - l_rcpt_tbl(j).AMOUNT_APPLIED;
                  END IF;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_ID : '||l_rcpt_tbl(j).INVOICE_ID);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).INVOICE_LINE_ID : '||l_rcpt_tbl(j).INVOICE_LINE_ID);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).INVOICE_LINE_NUMBER : '||l_rcpt_tbl(j).INVOICE_LINE_NUMBER);
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
          END IF;
        END IF;
      END LOOP;
      CLOSE c_all_open_invs;

    ELSIF l_dflt_receipt_msmtch ='N' or             -- APPLY TO CUSTOMER'S NEWEST INVOICES FIRST
          l_dflt_receipt_msmtch ='n' THEN

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Apply to customers newest invoices first');
      END IF;

      OPEN c_all_open_invs_desc (l_customer_num, l_org_id,l_currency_code);
      LOOP
            FETCH c_all_open_invs_desc INTO c_all_open_invs_desc_rec;
                EXIT WHEN c_all_open_invs_desc%NOTFOUND OR l_rcpt_amount = 0 OR l_rcpt_amount IS NULL;
                IF c_all_open_invs_desc_rec.AMOUNT_DUE_REMAINING > 0 THEN
          j := j + 1;

          --Populate receipt table
          l_rcpt_tbl(j).INVOICE_ID := c_all_open_invs_desc_rec.ar_invoice_id;
                  l_rcpt_tbl(j).INVOICE_NUMBER := c_all_open_invs_desc_rec.ar_invoice_number;
          l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_currency_code;
          l_rcpt_tbl(j).INVOICE_LINE_ID := c_all_open_invs_desc_rec.invoice_line_id;
                  l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_all_open_invs_desc_rec.line_number;

          --Amount Applied will be total amount applied including line and tax
              l_rcpt_tbl(j).AMOUNT_APPLIED := c_all_open_invs_desc_rec.amount_due_remaining;

                  IF l_rcpt_amount < l_rcpt_tbl(j).AMOUNT_APPLIED THEN
            l_rcpt_tbl(j).AMOUNT_APPLIED := l_rcpt_amount;
            l_rcpt_amount := 0;
          ELSE
                l_rcpt_amount := l_rcpt_amount - l_rcpt_tbl(j).AMOUNT_APPLIED;
                  END IF;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_ID : '||l_rcpt_tbl(j).INVOICE_ID);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).INVOICE_LINE_ID : '||l_rcpt_tbl(j).INVOICE_LINE_ID);
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).INVOICE_LINE_NUMBER : '||l_rcpt_tbl(j).INVOICE_LINE_NUMBER);
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
          END IF;
        END IF;
      END LOOP;
      CLOSE c_all_open_invs_desc;
    END IF;
    --Get grouped application table (in the form of invoice header > multiple invoice lines table)
    GET_APPLICATIONS( p_rcpt_tbl => l_rcpt_tbl
                     ,x_appl_tbl => l_appl_tbl);
        x_appl_tbl := l_appl_tbl;
  END IF;

  --Commented on account amount assignment as it is not supported from 12.1.3
  --For bug 8521220 - by NIKSHAH
  --x_onacc_amount :=l_onacc_amount;
  x_onacc_amount := 0;

  x_return_status := OKL_API.G_RET_STS_SUCCESS;
  --to be coded -onacc

EXCEPTION
    WHEN OTHERS THEN
    x_appl_tbl.DELETE;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data := sqlerrm;
END receipt_mismatch;


--Get default cash application rule
PROCEDURE get_default_cash_app_rule(p_org_id IN OKL_CASH_ALLCTN_RLS.ORG_ID%TYPE,
                                    x_dflt_cat_id  OUT NOCOPY OKL_CASH_ALLCTN_RLS.ID%TYPE,
                                    x_dflt_tolerance OUT NOCOPY OKL_CASH_ALLCTN_RLS.AMOUNT_TOLERANCE_PERCENT%TYPE,
                                    x_dflt_days_past_quote_valid OUT NOCOPY OKL_CASH_ALLCTN_RLS.DAYS_PAST_QUOTE_VALID_TOLERANC%TYPE,
                                    x_dflt_months_to_bill_ahead  OUT NOCOPY OKL_CASH_ALLCTN_RLS.MONTHS_TO_BILL_AHEAD%TYPE,
                                    x_dflt_under_payment OUT NOCOPY OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE,
                                    x_dflt_over_payment OUT  NOCOPY OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE ,
                                    x_dflt_receipt_msmtch OUT NOCOPY OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE
                                   ) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  l_org_id                      OKL_CASH_ALLCTN_RLS.ORG_ID%TYPE := p_org_id;
  l_dflt_cat_id                 OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
  l_dflt_tolerance       OKL_CASH_ALLCTN_RLS.AMOUNT_TOLERANCE_PERCENT%TYPE DEFAULT NULL;
  l_dflt_days_past_quote_valid  OKL_CASH_ALLCTN_RLS.DAYS_PAST_QUOTE_VALID_TOLERANC%TYPE DEFAULT NULL;
  l_dflt_months_to_bill_ahead   OKL_CASH_ALLCTN_RLS.MONTHS_TO_BILL_AHEAD%TYPE DEFAULT NULL;
  l_dflt_under_payment      OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_dflt_over_payment      OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_dflt_receipt_msmtch      OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE DEFAULT NULL;


-------------------
-- DECLARE Cursors
-------------------
     -- get default cash applic rule for organization
   CURSOR   c_dflt_cash_applic_rule(p_org_id NUMBER) IS
   SELECT  ID
           ,AMOUNT_TOLERANCE_PERCENT
           ,DAYS_PAST_QUOTE_VALID_TOLERANC
           ,MONTHS_TO_BILL_AHEAD
           ,UNDER_PAYMENT_ALLOCATION_CODE
           ,OVER_PAYMENT_ALLOCATION_CODE
           ,RECEIPT_MSMTCH_ALLOCATION_CODE
   FROM    OKL_CASH_ALLCTN_RLS_ALL
   WHERE   default_rule = 'YES'
   AND     TRUNC(end_date) IS NULL
   AND     org_id = p_org_id;

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
-- get default cash application rules.

  OPEN c_dflt_cash_applic_rule(l_org_id);
  FETCH c_dflt_cash_applic_rule INTO  l_dflt_cat_id
                                 ,l_dflt_tolerance
                                 ,l_dflt_days_past_quote_valid
                                 ,l_dflt_months_to_bill_ahead
                                 ,l_dflt_under_payment
                                 ,l_dflt_over_payment
                                 ,l_dflt_receipt_msmtch;
   CLOSE c_dflt_cash_applic_rule;

   x_dflt_cat_id := l_dflt_cat_id;
   x_dflt_tolerance:=l_dflt_tolerance;
   x_dflt_days_past_quote_valid := l_dflt_days_past_quote_valid;
   x_dflt_months_to_bill_ahead :=l_dflt_months_to_bill_ahead;
   x_dflt_under_payment:=l_dflt_under_payment;
   x_dflt_over_payment:=l_dflt_over_payment;
   x_dflt_receipt_msmtch := l_dflt_receipt_msmtch;

EXCEPTION
    WHEN OTHERS THEN
      l_dflt_cat_id:=null;
END get_default_cash_app_rule;


--Get application details table for the given receipt table
--So the application details table will be table of invoice header
--and its corresponding invoice lines with its applied amount
PROCEDURE GET_APPLICATIONS ( p_rcpt_tbl IN okl_rcpt_dtls_tbl_type
                            ,x_appl_tbl OUT NOCOPY okl_appl_dtls_tbl_type) IS

  l_inv_num                     RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE DEFAULT NULL;
  l_prev_inv_num                RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE DEFAULT NULL;
  line_counter                  NUMBER;
  hdr_counter                   NUMBER;
  i                             NUMBER;
  j                             NUMBER;
  complete_cycle                BOOLEAN;
  counter                       NUMBER;
  l_total_amount_applied        NUMBER := 0;
  l_line_amount_round             NUMBER:=0;
  l_rcpt_tbl    okl_rcpt_dtls_tbl_type := p_rcpt_tbl;
  l_appl_tbl    okl_appl_dtls_tbl_type;
  l_inv_lns_tbl okl_inv_line_tbl_type;
  l_total_amount_app_from NUMBER := 0;

BEGIN
  /*
    Description:
    . We will have l_rcpt_tbl which is flat table where each row consists of
    invoice header and invoice line information.
    . We need to group invoice lines to corresponding invoice header. It is not
          necessary that all invoice headers will come sequentially in this table.
          So the logic to group invoice lines is not straight forward.
    . And return the resulting table back to calling procedure, which in turn, will
    return to calling procedure (OKL Lockbox API)
  */

  /*
    Logic Flow:
    . hdr_counter is the counter for invoice header record
    . line_counter is the counter for invoice line record within each invoice header
    . complete_cycle ( = TRUE) indicates that l_rcpt_tbl has been traversed
      completely.
    . once invoice line is grouped in any invoice header, then will make amount_applied
      field to -1 in l_rcpt_tbl
    . counter is the counter for number of invoice lines whose amount_applied
      has been set to -1. We will increment counter everytime will update amount to -1
    . If value of counter is equal to count of l_rcpt_tbl then will terminate the loop
    . It makes a check in the loop whether amount is -1 if it is -1 then leave it
      otherwise if it is accessing any record from top of l_rcpt_tbl for the first time
      then assign create invoice header record and create 1st invoice line for this header.
      Also set amount to -1 and increment counter.
    . For the subsequent records in l_rcpt_tbl, if same invoice header is found then
      create another line record in invoice lines table. Also set amount to -1 and
      increment counter.
    . If the index of l_rcpt_tbl is the last then associate invoice lines table to
      invoice header record. Set complete_cycle to TRUE. Re-initialize i to 1,
          which will point to first record of l_rcpt_tbl. Re-initialize line_counter to 1.
          Increment hdr_counter.
  */
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Starting execution of OKL_AUTO_CASH_APPL_RULES_PVT.GET_APPLICATIONS ...');
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Count of l_rcpt_tbl: '|| l_rcpt_tbl.COUNT);
  END IF;

  IF (l_rcpt_tbl IS NOT NULL AND l_rcpt_tbl.COUNT > 0) THEN
    hdr_counter := l_rcpt_tbl.FIRST;
    complete_cycle := FALSE;
    line_counter := l_rcpt_tbl.FIRST;
    i := l_rcpt_tbl.FIRST;
    j := i;
    counter := 0;
    WHILE (i <= l_rcpt_tbl.LAST)
    LOOP
      IF (l_rcpt_tbl(i).amount_applied <> -1) THEN
          l_inv_num := l_rcpt_tbl(i).INVOICE_NUMBER;

          IF ( i = l_rcpt_tbl.FIRST OR complete_cycle = TRUE) THEN
            complete_cycle := FALSE;
            --Assign invoice header record in applications table
            l_appl_tbl(hdr_counter).inv_hdr_rec.invoice_number := l_inv_num;
            l_appl_tbl(hdr_counter).inv_hdr_rec.invoice_id := l_rcpt_tbl(i).invoice_id;
            l_appl_tbl(hdr_counter).inv_hdr_rec.invoice_currency_code:= l_rcpt_tbl(i).invoice_currency_code;
            --Assign invoice lines record in invoice lines table
            l_inv_lns_tbl(line_counter).invoice_line_id := l_rcpt_tbl(i).invoice_line_id;
            l_inv_lns_tbl(line_counter).invoice_line_number := l_rcpt_tbl(i).invoice_line_number;
            -- round off the amount applied
            l_inv_lns_tbl(line_counter).amount_applied := l_rcpt_tbl(i).AMOUNT_APPLIED;
            l_inv_lns_tbl(line_counter).amount_applied_from := l_rcpt_tbl(i).AMOUNT_APPLIED_FROM;
            l_inv_lns_tbl(line_counter).trans_to_receipt_rate := l_rcpt_tbl(i).trans_to_receipt_rate;
            l_total_amount_app_from := l_total_amount_app_from + l_inv_lns_tbl(line_counter).amount_applied_from;
            l_total_amount_applied := l_total_amount_applied + l_inv_lns_tbl(line_counter).amount_applied;

            line_counter := line_counter + 1;
            l_prev_inv_num := l_inv_num;
            l_rcpt_tbl(i).amount_applied := -1;
            counter := counter + 1;
      ELSIF (i <> l_rcpt_tbl.FIRST) THEN
        IF (l_inv_num = l_prev_inv_num) THEN
                    --Assign invoice lines record in invoice lines table
                    l_inv_lns_tbl(line_counter).invoice_line_id := l_rcpt_tbl(i).invoice_line_id;
                    l_inv_lns_tbl(line_counter).invoice_line_number := l_rcpt_tbl(i).invoice_line_number;
                    -- round off the amount applied
                    l_inv_lns_tbl(line_counter).amount_applied := l_rcpt_tbl(i).AMOUNT_APPLIED;
                    l_inv_lns_tbl(line_counter).amount_applied_from := l_rcpt_tbl(i).AMOUNT_APPLIED_FROM;
                    l_inv_lns_tbl(line_counter).trans_to_receipt_rate := l_rcpt_tbl(i).trans_to_receipt_rate;
                    l_total_amount_app_from := l_total_amount_app_from + l_inv_lns_tbl(line_counter).amount_applied_from;

                    l_total_amount_applied := l_total_amount_applied + l_inv_lns_tbl(line_counter).amount_applied;

                    line_counter := line_counter + 1;
                    l_prev_inv_num := l_inv_num;
                    l_rcpt_tbl(i).amount_applied := -1;
                    counter := counter + 1;
          END IF;
        END IF;
        IF ( i = l_rcpt_tbl.LAST) THEN
          i := l_rcpt_tbl.FIRST;
          complete_cycle := TRUE;
          --Assign lines table generated into applications table
          l_appl_tbl(hdr_counter).inv_hdr_rec.amount_applied := l_total_amount_applied;
          l_appl_tbl(hdr_counter).inv_hdr_rec.amount_applied_from := l_total_amount_app_from;
          l_appl_tbl(hdr_counter).inv_hdr_rec.trans_to_receipt_rate := l_inv_lns_tbl(l_inv_lns_tbl.FIRST).trans_to_receipt_rate;
          l_total_amount_app_from := 0;
          l_total_amount_applied := 0;
          l_appl_tbl(hdr_counter).inv_lines_tbl := l_inv_lns_tbl;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Created invoice header and its lines');
           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Invoice Number: '|| l_appl_tbl(hdr_counter).inv_hdr_rec.invoice_number);
           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Number of lines for this invoice number: '|| l_inv_lns_tbl.COUNT);
          END IF;
          --Delete lines table and reinitialize
          l_inv_lns_tbl.delete;
          line_counter := 1;
                  hdr_counter := hdr_counter + 1;
        ELSE
          i := i + 1;
        END IF;
      ELSE
        IF ( i = l_rcpt_tbl.LAST) THEN
          i := l_rcpt_tbl.FIRST;
          complete_cycle := TRUE;
          --Assign lines table into applications table
          l_appl_tbl(hdr_counter).inv_hdr_rec.amount_applied := l_total_amount_applied;
          l_appl_tbl(hdr_counter).inv_hdr_rec.amount_applied_from := l_total_amount_app_from;
          l_appl_tbl(hdr_counter).inv_hdr_rec.trans_to_receipt_rate := l_inv_lns_tbl(l_inv_lns_tbl.FIRST).trans_to_receipt_rate;
          l_total_amount_app_from := 0;
          l_total_amount_applied := 0;

          l_appl_tbl(hdr_counter).inv_lines_tbl := l_inv_lns_tbl;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Created invoice header and its lines');
           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Invoice Number: '|| l_appl_tbl(hdr_counter).inv_hdr_rec.invoice_number);
           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Number of lines for this invoice number: '|| l_inv_lns_tbl.COUNT);
          END IF;
          --Delete lines table and reinitialize
          l_inv_lns_tbl.delete;
          line_counter := 1;
                  hdr_counter := hdr_counter + 1;
        ELSE
          i := i + 1;
        END IF;
      END IF;
      IF (counter = l_rcpt_tbl.COUNT) THEN
        EXIT;
      END IF;
    END LOOP;
    --If invoice lines table is not null and count is greater than 0
    --Then assign invoice lines table to last created invoice header.
    IF (l_inv_lns_tbl IS NOT NULL AND l_inv_lns_tbl.COUNT > 0) THEN
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Created invoice header and its lines');
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Invoice Number: '|| l_appl_tbl(hdr_counter).inv_hdr_rec.invoice_number);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Number of lines for this invoice number: '|| l_inv_lns_tbl.COUNT);
      END IF;
      l_appl_tbl(hdr_counter).inv_hdr_rec.amount_applied := l_total_amount_applied;
      l_appl_tbl(hdr_counter).inv_hdr_rec.amount_applied_from := l_total_amount_app_from;
      l_appl_tbl(hdr_counter).inv_hdr_rec.trans_to_receipt_rate := l_inv_lns_tbl(l_inv_lns_tbl.FIRST).trans_to_receipt_rate;
      l_total_amount_app_from := 0;
      l_total_amount_applied := 0;
      l_appl_tbl(hdr_counter).inv_lines_tbl := l_inv_lns_tbl;
    END IF;
  END IF;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Padding remaining invoice headers to make number of invoice headers divisible by 8');
  END IF;

  --Pad additional application records
  IF (l_appl_tbl.COUNT > 0 AND l_appl_tbl.COUNT < 8) OR mod((l_appl_tbl.COUNT), 8) <> 0 THEN
    j := l_appl_tbl.LAST;
    LOOP
    EXIT WHEN mod((l_appl_tbl.COUNT), 8) = 0;       -- multiple of 8
      j := j + 1;
      l_appl_tbl(j).inv_hdr_rec.INVOICE_CURRENCY_CODE := '';     --this is just to buffer the record out !!
    END LOOP;
  END IF;
  --Assign local application details table to out variable
  x_appl_tbl := l_appl_tbl;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END GET_APPLICATIONS;

--END: Bug 6275659 by nikshah


/* sosharma 30-jul-2007
Added proceudure to handle cash application rules on  consolidated Invoices
*/
PROCEDURE auto_cashapp_for_consinv (  p_api_version      IN   NUMBER
                         ,p_init_msg_list    IN   VARCHAR2        DEFAULT Okc_Api.G_FALSE
                         ,x_return_status    OUT  NOCOPY VARCHAR2
                         ,x_msg_count          OUT  NOCOPY NUMBER
                         ,x_msg_data          OUT  NOCOPY VARCHAR2
                         ,p_customer_num     IN   VARCHAR2        DEFAULT NULL
                         ,p_cons_inv         IN   VARCHAR2
                         ,p_currency_code    IN   VARCHAR2
                         ,p_amount_app_to     IN  NUMBER DEFAULT NULL
                         ,p_amount_app_from   IN  NUMBER DEFAULT NULL
                         ,p_inv_to_rct_rate   IN  NUMBER DEFAULT NULL
                         ,p_receipt_date      IN  DATE
                         ,p_org_id           IN   NUMBER
                         ,x_appl_tbl         OUT  NOCOPY  okl_appl_dtls_tbl_type
                        ,x_onacc_amount        OUT NOCOPY NUMBER
                        ,x_unapply_amount      OUT NOCOPY NUMBER
                       ) IS

---------------------------
-- DECLARE Local Variables
---------------------------


 l_amount_apply_pref           VARCHAR2(15)  := 'PRORATE';


 l_original_line_amount        NUMBER;
 l_original_tax_amount         NUMBER;
 l_total_amount                NUMBER;
 l_line_amount_applied         NUMBER;
 l_tax_amount_applied          NUMBER;


 l_cons_inv                     VARCHAR2(120) := p_cons_inv;
 l_currency_code                VARCHAR2(45)  := p_currency_code;
 l_amount_app_from     NUMBER            := p_amount_app_from;
 l_amount_app_to       NUMBER            := p_amount_app_to;
 l_inv_to_rct_rate     NUMBER            := p_inv_to_rct_rate;
 l_inv_curr_Code       VARCHAR2(45);
 l_receipt_Date        DATE := p_receipt_date;
 l_cross_curr_enabled  varchar2(3):='N';
 l_conversion_rate     NUMBER;
 l_exchange_rate_type  VARCHAR2(45);
 l_tot_amt_app_from    NUMBER;

 l_due_date                    DATE          DEFAULT NULL;

 l_customer_id                  NUMBER;
 l_customer_num                VARCHAR2(30)  := p_customer_num;
 l_cons_bill_id                NUMBER;
 l_cons_bill_num               VARCHAR2(90);
 l_last_contract_id            OKC_K_HEADERS_V.ID%TYPE DEFAULT 1;
 l_contract_id                 NUMBER;
 l_contract_num                VARCHAR2(120);
 l_contract_number_start_date  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL;
 l_contract_number_id          OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL;

 l_receivables_invoice_num        NUMBER          DEFAULT NULL;
 l_over_pay                    VARCHAR(1)    DEFAULT NULL;
 l_ordered                        CONSTANT      VARCHAR2(3) := 'ODD';
 l_prorate                        CONSTANT      VARCHAR2(3) := 'PRO';


 l_org_id                        NUMBER := p_org_id;

 i                                NUMBER;
 j                             NUMBER;
 d                             NUMBER DEFAULT NULL;

 l_first_prorate_rec           NUMBER DEFAULT NULL;
 l_first_prorate_rec_j         NUMBER DEFAULT NULL;

 l_appl_tolerance                NUMBER;
 l_temp_val                      NUMBER;
 l_inv_tot                       NUMBER        := 0;
 l_cont_tot                      NUMBER      := 0;
 l_pro_rate_inv_total            NUMBER        := 0;
 l_stream_tot                    NUMBER      := 0;
 l_diff_amount                 NUMBER      := 0;
 l_inv_total_amt               NUMBER      := 0;


 l_start_date                  DATE;
 l_same_date                   VARCHAR(1) DEFAULT NULL;
 l_same_cash_app_rule          VARCHAR(1) DEFAULT NULL;

 l_count                       NUMBER DEFAULT NULL;


 l_check_cau_id                 OKL_CSH_ALLCTN_RL_HDR.ID%TYPE DEFAULT NULL;
 l_cau_id                       OKL_CSH_ALLCTN_RL_HDR.ID%TYPE DEFAULT NULL;
 l_cat_id                       OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
 l_sty_id                       OKL_CNSLD_AR_STRMS_V.STY_ID%TYPE;
 l_tolerance                    OKL_CASH_ALLCTN_RLS.AMOUNT_TOLERANCE_PERCENT%TYPE;
 l_days_past_quote_valid        OKL_CASH_ALLCTN_RLS.DAYS_PAST_QUOTE_VALID_TOLERANC%TYPE;
 l_months_to_bill_ahead         OKL_CASH_ALLCTN_RLS.MONTHS_TO_BILL_AHEAD%TYPE;
 l_under_payment                OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE;
 l_over_payment                 OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE;
 l_receipt_msmtch               OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE;

  l_dflt_cat_id                 OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
  l_dflt_tolerance              OKL_CASH_ALLCTN_RLS.AMOUNT_TOLERANCE_PERCENT%TYPE DEFAULT NULL;
  l_dflt_days_past_quote_valid  OKL_CASH_ALLCTN_RLS.DAYS_PAST_QUOTE_VALID_TOLERANC%TYPE DEFAULT NULL;
  l_dflt_months_to_bill_ahead   OKL_CASH_ALLCTN_RLS.MONTHS_TO_BILL_AHEAD%TYPE DEFAULT NULL;
  l_dflt_under_payment          OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_dflt_over_payment           OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_dflt_receipt_msmtch         OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE DEFAULT NULL;

 l_valid_yn                      VARCHAR2(1);

 l_api_version                  NUMBER := 1.0;
 l_init_msg_list                VARCHAR2(1)     := Okc_Api.g_false;
 l_return_status                VARCHAR2(1);
 l_msg_count                    NUMBER;
 l_msg_data                    VARCHAR2(2000);

 l_inv_num                     RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE DEFAULT NULL;
 l_prev_inv_num                RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE DEFAULT NULL;
 line_counter                  NUMBER;
 hdr_counter                   NUMBER;

------------------------------
-- DECLARE Record/Table Types
------------------------------


 l_rcpt_tbl    okl_auto_cash_appl_rules_pvt.okl_rcpt_dtls_tbl_type;
 l_appl_tbl    okl_auto_cash_appl_rules_pvt.okl_appl_dtls_tbl_type;
 l_inv_lns_tbl okl_auto_cash_appl_rules_pvt.okl_inv_line_tbl_type;

 -- ** internal use only ** --

 TYPE okl_inv_refs_type IS RECORD ( contract_number   AR_PAYMENTS_INTERFACE_ALL.INVOICE1%TYPE DEFAULT NULL
                                   ,cons_inv_number   AR_PAYMENTS_INTERFACE_ALL.INVOICE1%TYPE DEFAULT NULL
                                  );

 TYPE okl_inv_refs_tbl_type IS TABLE OF okl_inv_refs_type
       INDEX BY BINARY_INTEGER;

 l_cust_inv_ref      okl_inv_refs_tbl_type;


-------------------
-- DECLARE Cursors
-------------------
  -- cursor to get contracts information

 CURSOR   c_open_invs2( cp_cons_bill_id     IN NUMBER
                       ,cp_org_id          IN NUMBER
                       ,cp_customer_num     IN VARCHAR2
                       ) IS
 SELECT  lpt.stream_type_id
          ,lpt.amount_due_remaining invoice_due_remaining
          ,lpt.amount_due_original invoice_due_original
          ,lpt.currency_code invoice_currency_code
          ,lpt.AR_INVOICE_NUMBER
          ,lpt.AR_INVOICE_ID
          ,lpt.stream_element_id
          ,lpt.ar_invoice_line_id
          ,lpt.ar_invoice_line_number
          ,lpt.trx_date invoice_date
          ,lpt.contract_number
FROM okl_rcpt_consinv_balances_uv lpt
   WHERE    lpt.consolidated_invoice_id    = cp_cons_bill_id
   --asawanka changed for bug #5391874
   AND    lpt.customer_account_number = nvl(cp_customer_num,lpt.customer_account_number)
   AND    lpt.org_id=cp_org_id
   AND    lpt.status='OP';

   c_open_invs_rec c_open_invs2%ROWTYPE;
   TYPE open_inv_tbl_type IS TABLE OF c_open_invs2%ROWTYPE INDEX BY BINARY_INTEGER;
   open_inv_tbl open_inv_tbl_type;
   open_inv_contract_tbl open_inv_tbl_type;

----------

  CURSOR   c_inv_date  ( cp_cons_bill_id     IN NUMBER
                        ,cp_customer_num     IN VARCHAR2) IS
     SELECT  DISTINCT(lpt.contract_number)
          ,lpt.invoice_date Start_date, lpt.contract_id,lpt.currency_code
   FROM    okl_rcpt_consinv_balances_uv lpt
   WHERE    lpt.consolidated_invoice_id    = cp_cons_bill_id   --Always passing cp_cons_bill_id as not null so no need to have nvl
   AND        lpt.customer_account_number = NVL (cp_customer_num,    lpt.customer_account_number);


  c_inv_date_rec c_inv_date%ROWTYPE;

----------

  -- get stream application order
  CURSOR   c_stream_alloc ( cp_str_all_type IN VARCHAR2
                           ,cp_cat_id       IN NUMBER ) IS
   SELECT    sty_id
   FROM    OKL_STRM_TYP_ALLOCS
   WHERE    stream_allc_type = cp_str_all_type
   AND     cat_id = cp_cat_id
   ORDER BY sequence_number;

----------

   /*
  -- get cash applic rule id
     */

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
-- get a contract number if not known
  CURSOR   c_get_contract_num (cp_cons_bill_id IN NUMBER) IS
   SELECT  lpt.contract_id, lpt.contract_number
   FROM    okl_rcpt_consinv_balances_uv lpt, okc_k_headers_all_b khr
   WHERE   lpt.consolidated_invoice_id    = cp_cons_bill_id
   AND     lpt.status = 'OP'
   AND     lpt.amount_due_remaining > 0
   AND     khr.id = lpt.contract_id
   ORDER BY khr.start_date;
----------


CURSOR valid_consinv(cl_cons_inv IN VARCHAR2)
IS
select ID
from OKL_CNSLD_AR_HDRS_B
where consolidated_invoice_number=cl_cons_inv;

l_unapply_amount NUMBER:=0;
l_onacc_amount NUMBER:=0;

BEGIN

  OPEN valid_consinv(l_cons_inv);
  FETCH  valid_consinv into l_cons_bill_id;
  IF l_cons_bill_id IS NULL THEN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;
  CLOSE valid_consinv;

  IF l_cons_inv IS NOT NULL THEN
       l_count := 0;
       i := 0;
       FOR c_open_invs_rec IN c_open_invs2 (l_cons_bill_id,l_org_id, l_customer_num)
       LOOP
            IF c_open_invs_rec.invoice_due_remaining > 0 THEN
              i := i + 1;
              open_inv_tbl(i) := c_open_invs_rec;
              l_count := l_count + 1;
            END IF;
       END LOOP;
       i := 0;
       IF l_count > 0 THEN
           l_cons_bill_num := l_cons_inv;
           l_contract_num := NULL;
       END IF;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_contract_num : '||l_contract_num);
         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cons_bill_num : '||l_cons_bill_num);
         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cons_bill_id : '||l_cons_bill_id);
       END IF;
   END IF;




   -- START OKL CASH APPLICATION.

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Checking whether l_contract_num or l_cons_bill_num is not null ..');

    END IF;

   IF l_cons_bill_num IS NOT NULL THEN  --(1)

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cons_bill_num is not null - '||l_cons_bill_num);

  END IF;

       j :=  0;

       OPEN  c_inv_date(l_cons_bill_id, l_customer_num);
       FETCH c_inv_date INTO l_contract_number_start_date, l_start_date, l_contract_number_id,l_inv_curr_Code;
       CLOSE c_inv_date;

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_contract_number_start_date, l_start_date, l_contract_number_id : '||
                                           l_contract_number_start_date||', '||l_start_date||', '||l_contract_number_id);

         END IF;

       d :=0;
       FOR c_inv_date_rec IN c_inv_date(l_cons_bill_id, l_customer_num)
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

IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Check for same cash application rule');


END IF;
       OPEN  c_cash_rle_id_csr (l_contract_number_id);
       FETCH c_cash_rle_id_csr INTO l_cau_id;
       CLOSE c_cash_rle_id_csr;

       d := 0;
       FOR c_inv_date_rec IN c_inv_date(l_cons_bill_id, l_customer_num)
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

IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_same_date, l_same_cash_app_rule : '||
                                              l_same_date||', '||l_same_cash_app_rule);

END IF;



  log_debug('Receipt Currency = '||l_currency_code);
  log_debug('Contract Currency = '||l_inv_curr_Code);
  log_debug('l_amount_app_from = '||l_amount_app_from);
  log_debug('l_amount_app_to = '||l_amount_app_to);
  log_debug('l_inv_to_rct_rate = '||l_inv_to_rct_rate);
  IF l_currency_code = l_inv_curr_Code THEN
          IF l_amount_app_from IS NULL AND l_amount_app_to IS NULL THEN
            OKL_API.set_message( p_app_name      => G_APP_NAME
                                ,p_msg_name      => 'OKL_BPD_INVALID_PARAMS'
                                      );
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSIF l_amount_app_from IS NULL THEN
             l_amount_app_from := l_amount_app_to;
          ELSE
             l_amount_app_to := l_amount_app_from;
          END IF;
  ELSE
          IF l_amount_app_from IS NOT NULL AND l_amount_app_to IS NOT NULL AND l_inv_to_rct_rate IS NOT NULL THEN
            IF ( l_amount_app_to * l_inv_to_rct_rate) <> l_amount_app_from THEN
              OKL_API.set_message( p_app_name      => G_APP_NAME
                                        ,p_msg_name      => 'OKL_BPD_PARAMS_MISMATCH'
                                              );
            END IF;
            IF l_inv_to_rct_rate <> 0 and ( ( l_amount_app_from / l_inv_to_rct_rate) <> l_amount_app_to) THEN
              OKL_API.set_message( p_app_name      => G_APP_NAME
                                        ,p_msg_name      => 'OKL_BPD_PARAMS_MISMATCH'
                                              );
            END IF;
          END IF;
/*          l_cross_curr_enabled := nvl(FND_PROFILE.value('AR_ENABLE_CROSS_CURRENCY'),'N');
          log_debug('l_cross_curr_enabled = '||l_cross_curr_enabled);
          IF l_cross_curr_enabled <> 'Y' THEN
            OKL_API.set_message( p_app_name      => G_APP_NAME
                                ,p_msg_name      => 'OKL_BPD_CROSS_CURR_NA'
                                      );
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE*/
             IF l_inv_to_rct_rate is null THEN
               l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
               log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
               IF l_exchange_rate_type IS  NULL THEN
                  OKL_API.set_message( p_app_name      => G_APP_NAME
                                      ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                     );
                  RAISE G_EXCEPTION_HALT_VALIDATION;
               ELSE
                  l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                             ,l_currency_code
                                                             ,l_receipt_date
                                                             ,l_exchange_rate_type
                                                             );

                  IF l_conversion_rate IN (0,-1) THEN

                      -- Message Text: No exchange rate defined
                      x_return_status := okl_api.G_RET_STS_ERROR;
                      okl_api.set_message( p_app_name      => G_APP_NAME,
                                           p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                      RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;
               END IF;
            ELSE
              l_conversion_rate := l_inv_to_rct_rate;
            END IF;
            log_debug('l_conversion_rate ='||l_conversion_rate);
            IF l_amount_app_from IS NULL AND l_amount_app_to IS NULL THEN
                OKL_API.set_message( p_app_name      => G_APP_NAME
                                    ,p_msg_name      => 'OKL_BPD_INVALID_PARAMS'
                                   );
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSIF l_amount_app_from IS NULL THEN
               l_amount_app_from := l_amount_app_to * l_conversion_rate;
            ELSE
               l_amount_app_to := l_amount_app_from * (1/l_conversion_rate);
            END IF;
--          END IF;
  END IF;
  l_amount_app_from := arp_util.CurrRound(l_amount_app_from,l_currency_code);
  l_amount_app_to := arp_util.CurrRound(l_amount_app_to,l_inv_curr_code);
  log_debug('l_amount_app_from = '||l_amount_app_from);
  log_debug('l_amount_app_to = '||l_amount_app_to);
  log_debug('l_inv_to_rct_rate = '||l_inv_to_rct_rate);

     --  IF l_same_date = 'Y' AND l_same_cash_app_rule = 'Y' THEN  --(1)
     IF l_same_date = 'Y' THEN

           IF l_same_cash_app_rule = 'Y' THEN  -- Use Common Cash Application
               IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Date and CAR are same for all contracts ...');
               END IF;
               --  *******************************************************
               --  Start Line level cash application using the same cash
               --  application rule for all
               --  *******************************************************
               OPEN c_cash_rule_csr (l_cau_id);
               FETCH c_cash_rule_csr
               INTO  l_cat_id
                  ,l_tolerance
                  ,l_days_past_quote_valid
                          ,l_months_to_bill_ahead
                          ,l_under_payment
                          ,l_over_payment
                          ,l_receipt_msmtch;
               CLOSE c_cash_rule_csr;
          Elsif  l_same_cash_app_rule = 'N' THEN  -- Use Default Cash Application
               IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Same Date but different CAR for all contracts ...');
               END IF;
               --  *******************************************************
               --  Start Line level cash application using the same cash
               --  application rule for all
               --  *******************************************************
                Get_Default_Cash_App_Rule(
                         l_org_id
                        ,l_cat_id
                        ,l_tolerance
                        ,l_days_past_quote_valid
                        ,l_months_to_bill_ahead
                        ,l_under_payment
                        ,l_over_payment
                        ,l_receipt_msmtch);
          End If;
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Date and CAR are same for all contracts ...');

          END IF;

                  --  ************************************************
           --  Stream level cash application processing BEGINS
           --  ************************************************

           -- get stream total

           l_stream_tot := 0;
           FOR i IN open_inv_tbl.FIRST..open_inv_tbl.LAST
           LOOP
            -- l_invoice_currency_code := c_open_invs_rec.currency_code;
               c_open_invs_rec := open_inv_tbl(i);
               IF c_open_invs_rec.invoice_due_remaining > 0 THEN
                 l_stream_tot := l_stream_tot + c_open_invs_rec.invoice_due_remaining;
               END IF;
           END LOOP;

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_stream_tot : ' || l_stream_tot);
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_amount_app_to : ' || l_amount_app_to);



              END IF;
           -- calculate tolerance
           IF l_stream_tot > l_amount_app_to THEN
               l_appl_tolerance := l_stream_tot * (1 - l_tolerance / 100);
           ELSE
               l_appl_tolerance := l_stream_tot;
           END IF;

           IF l_stream_tot > l_amount_app_to AND l_appl_tolerance > l_amount_app_to THEN -- UNDERPAYMENT  (2)

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'UNDERPAYMENT ...');

              END IF;

               IF l_under_payment In ('U','u') THEN -- Unapply underpayment (3)
                   IF l_currency_code = l_inv_curr_code THEN
                     l_unapply_amount:=l_amount_app_to;
                   ELSE
                     l_unapply_amount:= l_amount_app_to * l_conversion_rate;
                     l_unapply_amount := GET_ROUNDED_AMOUNT(l_unapply_amount,l_currency_code);
                   END IF;
               ELSIF l_under_payment IN ('T','t') THEN -- ORDERED (3)

                   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ORDERED ...');

                   END IF;
                   OPEN c_stream_alloc (l_ordered, l_cat_id);
                   LOOP
                       FETCH c_stream_alloc INTO l_sty_id;
                       EXIT WHEN c_stream_alloc%NOTFOUND
                       OR l_amount_app_to = 0
                       OR l_amount_app_to IS NULL;

                       FOR i IN open_inv_tbl.FIRST..open_inv_tbl.LAST
                       LOOP
                           c_open_invs_rec := open_inv_tbl(i);
                           EXIT WHEN l_amount_app_to = 0 OR  l_amount_app_to IS NULL;
                           IF c_open_invs_rec.stream_type_id = l_sty_id THEN
                             j := j + 1;

                             l_rcpt_tbl(j).INVOICE_NUMBER := c_open_invs_rec.ar_invoice_number;
                             -- added for AR changes
                             l_rcpt_tbl(j).INVOICE_ID := c_open_invs_rec.ar_invoice_id;
                             l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_open_invs_rec.ar_invoice_line_number;
                             l_rcpt_tbl(j).INVOICE_LINE_ID := c_open_invs_rec.ar_invoice_line_id;
                             l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_Code;
                             l_rcpt_tbl(j).AMOUNT_APPLIED        := c_open_invs_rec.invoice_due_remaining;

                             IF l_rcpt_tbl(j).AMOUNT_APPLIED > l_amount_app_to THEN
                               l_rcpt_tbl(j).AMOUNT_APPLIED := l_amount_app_to;
                               l_amount_app_to := 0;
                             ELSE
                               l_amount_app_to := l_amount_app_to - l_rcpt_tbl(j).AMOUNT_APPLIED;
                             END IF;
                             IF l_currency_code <> l_inv_curr_code THEN
                                  IF l_inv_to_rct_rate is null THEN
                                     l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                     log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                     IF l_exchange_rate_type IS  NULL THEN
                                        OKL_API.set_message( p_app_name      => G_APP_NAME
                                                            ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                           );
                                        RAISE G_EXCEPTION_HALT_VALIDATION;
                                     ELSE
                                        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                   ,l_currency_code
                                                                                   ,l_receipt_date
                                                                                   ,l_exchange_rate_type
                                                                                   );

                                        IF l_conversion_rate IN (0,-1) THEN

                                            -- Message Text: No exchange rate defined
                                            x_return_status := okl_api.G_RET_STS_ERROR;
                                            okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                            RAISE G_EXCEPTION_HALT_VALIDATION;
                                        END IF;
                                     END IF;
                                  ELSE
                                    l_conversion_rate := l_inv_to_rct_rate;
                                  END IF;
                                   l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                ELSE
                                   l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                END IF;
                             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
                               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
                             END IF;
                           END IF;
                         END LOOP;
                   END LOOP;
                   CLOSE c_stream_alloc;

               ELSIF l_under_payment IN ('P','p') THEN -- PRO RATE (3)

                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'PRO RATE ...');

               END IF;

                   l_first_prorate_rec_j := j + 1;

                   -- i := 1;
                   -- obtain all the streams that are part of the pro rate default rule.

                   FOR c_stream_alloc_rec IN c_stream_alloc (l_prorate, l_cat_id)
                   LOOP

                       l_sty_id := c_stream_alloc_rec.sty_id;
                       FOR i IN open_inv_tbl.FIRST..open_inv_tbl.LAST
                       LOOP
                         c_open_invs_rec := open_inv_tbl(i);
                         IF c_open_invs_rec.stream_type_id = l_sty_id THEN
                           j := j + 1;

                           l_rcpt_tbl(j).AMOUNT_APPLIED        := c_open_invs_rec.invoice_due_remaining;
                           l_rcpt_tbl(j).INVOICE_NUMBER        := c_open_invs_rec.ar_invoice_number;
                           l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_Code;
                           l_rcpt_tbl(j).INVOICE_ID := c_open_invs_rec.ar_invoice_id;
                           l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_open_invs_rec.ar_invoice_line_number;
                           l_rcpt_tbl(j).INVOICE_LINE_ID := c_open_invs_rec.ar_invoice_line_id;
                           IF l_currency_code <> l_inv_curr_code THEN
                                  IF l_inv_to_rct_rate is null THEN
                                     l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                     log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                     IF l_exchange_rate_type IS  NULL THEN
                                        OKL_API.set_message( p_app_name      => G_APP_NAME
                                                            ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                           );
                                        RAISE G_EXCEPTION_HALT_VALIDATION;
                                     ELSE
                                        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                   ,l_currency_code
                                                                                   ,l_receipt_date
                                                                                   ,l_exchange_rate_type
                                                                                   );

                                        IF l_conversion_rate IN (0,-1) THEN

                                            -- Message Text: No exchange rate defined
                                            x_return_status := okl_api.G_RET_STS_ERROR;
                                            okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                            RAISE G_EXCEPTION_HALT_VALIDATION;
                                        END IF;
                                     END IF;
                                  ELSE
                                    l_conversion_rate := l_inv_to_rct_rate;
                                  END IF;
                                   l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM:=arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                ELSE
                                   l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                END IF;
                           l_pro_rate_inv_total := l_pro_rate_inv_total + l_rcpt_tbl(j).AMOUNT_APPLIED;

                           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
                             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
                           END IF;
                         END IF;
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

                      IF (l_pro_rate_inv_total > l_amount_app_to) THEN

                       j := l_first_prorate_rec_j;

                       l_temp_val := l_amount_app_to / l_pro_rate_inv_total;

--                       l_amount_app_to := 0;

                       LOOP
                          l_rcpt_tbl(j).AMOUNT_APPLIED := l_temp_val * l_rcpt_tbl(j).AMOUNT_APPLIED;
                          l_rcpt_tbl(j).AMOUNT_APPLIED:=GET_ROUNDED_AMOUNT(l_rcpt_tbl(j).AMOUNT_APPLIED,l_inv_curr_Code);
                          IF l_currency_code <> l_inv_curr_code THEN
                                  IF l_inv_to_rct_rate is null THEN
                                     l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                     log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                     IF l_exchange_rate_type IS  NULL THEN
                                        OKL_API.set_message( p_app_name      => G_APP_NAME
                                                            ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                           );
                                        RAISE G_EXCEPTION_HALT_VALIDATION;
                                     ELSE
                                        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                   ,l_currency_code
                                                                                   ,l_receipt_date
                                                                                   ,l_exchange_rate_type
                                                                                   );

                                        IF l_conversion_rate IN (0,-1) THEN

                                            -- Message Text: No exchange rate defined
                                            x_return_status := okl_api.G_RET_STS_ERROR;
                                            okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                            RAISE G_EXCEPTION_HALT_VALIDATION;
                                        END IF;
                                     END IF;
                                  ELSE
                                    l_conversion_rate := l_inv_to_rct_rate;
                                  END IF;
                                   l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM := arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                ELSE
                                   l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                END IF;
                          l_inv_total_amt := l_inv_total_amt + l_rcpt_tbl(j).AMOUNT_APPLIED;
                           EXIT WHEN (j = l_rcpt_tbl.LAST);
                           j := j + 1;
                       END LOOP;
                       l_diff_amount := l_amount_app_to - l_inv_total_amt;
                       if l_diff_amount > 0 then
                         l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied := l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied + l_diff_amount;
                         IF l_currency_code <> l_inv_curr_code THEN
                          IF l_inv_to_rct_rate is null THEN
                             l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                             log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                             IF l_exchange_rate_type IS  NULL THEN
                                OKL_API.set_message( p_app_name      => G_APP_NAME
                                                    ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                   );
                                RAISE G_EXCEPTION_HALT_VALIDATION;
                             ELSE
                                l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                           ,l_currency_code
                                                                           ,l_receipt_date
                                                                           ,l_exchange_rate_type
                                                                           );

                                IF l_conversion_rate IN (0,-1) THEN

                                    -- Message Text: No exchange rate defined
                                    x_return_status := okl_api.G_RET_STS_ERROR;
                                    okl_api.set_message( p_app_name      => G_APP_NAME,
                                                         p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                    RAISE G_EXCEPTION_HALT_VALIDATION;
                                END IF;
                             END IF;
                          ELSE
                            l_conversion_rate := l_inv_to_rct_rate;
                          END IF;
                           l_rcpt_tbl(l_rcpt_tbl.LAST).trans_to_receipt_rate := l_conversion_rate;
                           l_rcpt_tbl(l_rcpt_tbl.LAST).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(l_rcpt_tbl.LAST).AMOUNT_APPLIED * l_conversion_rate;
                           l_rcpt_tbl(l_rcpt_tbl.LAST).AMOUNT_APPLIED_FROM := arp_util.CurrRound(l_rcpt_tbl(l_rcpt_tbl.LAST).AMOUNT_APPLIED_FROM,l_currency_code);
                        ELSE
                           l_rcpt_tbl(l_rcpt_tbl.LAST).trans_to_receipt_rate := null;
                           l_rcpt_tbl(l_rcpt_tbl.LAST).AMOUNT_APPLIED_FROM  := null;
                        END IF;
                       end if;


           END IF;             -- bug 5221326

                   END IF; -- (3)

           ELSE -- EXACT or OVERPAYMENT or TOLERANCE  (2)

            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'EXACT or OVERPAYMENT or TOLERANCE');

            END IF;
                -- CREATE LINES TABLE

               FOR i IN open_inv_tbl.FIRST..open_inv_tbl.LAST
               LOOP
                   c_open_invs_rec := open_inv_tbl(i);
                   EXIT WHEN l_amount_app_to = 0 OR l_amount_app_to IS NULL;
                   j := j + 1;
                   l_rcpt_tbl(j).AMOUNT_APPLIED        := c_open_invs_rec.invoice_due_remaining;
                   l_rcpt_tbl(j).INVOICE_NUMBER        := c_open_invs_rec.ar_invoice_number;
                   l_rcpt_tbl(j).INVOICE_ID := c_open_invs_rec.ar_invoice_id;
                   l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_open_invs_rec.ar_invoice_line_number;
                   l_rcpt_tbl(j).INVOICE_LINE_ID := c_open_invs_rec.ar_invoice_line_id;
                   l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_Code;

                   IF l_amount_app_to < l_rcpt_tbl(j).AMOUNT_APPLIED THEN
                   -- TOLERANCE
                       l_rcpt_tbl(j).AMOUNT_APPLIED := l_amount_app_to;
                       l_amount_app_to := 0;
                   ELSE
                       l_amount_app_to := l_amount_app_to - l_rcpt_tbl(j).AMOUNT_APPLIED;
                   END IF;
                   IF l_currency_code <> l_inv_curr_code THEN
                          IF l_inv_to_rct_rate is null THEN
                             l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                             log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                             IF l_exchange_rate_type IS  NULL THEN
                                OKL_API.set_message( p_app_name      => G_APP_NAME
                                                    ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                   );
                                RAISE G_EXCEPTION_HALT_VALIDATION;
                             ELSE
                                l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                           ,l_currency_code
                                                                           ,l_receipt_date
                                                                           ,l_exchange_rate_type
                                                                           );

                                IF l_conversion_rate IN (0,-1) THEN

                                    -- Message Text: No exchange rate defined
                                    x_return_status := okl_api.G_RET_STS_ERROR;
                                    okl_api.set_message( p_app_name      => G_APP_NAME,
                                                         p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                    RAISE G_EXCEPTION_HALT_VALIDATION;
                                END IF;
                             END IF;
                          ELSE
                            l_conversion_rate := l_inv_to_rct_rate;
                          END IF;
                           l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM := arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                        ELSE
                           l_rcpt_tbl(j).trans_to_receipt_rate := null;
                           l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                        END IF;
                   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
                     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
                   END IF;
                 END LOOP;
                -- Apply the remaining balance as per the Cash Application Rule
                If l_over_payment In ('B','b') Then  -- Onaccount --move cash to customer balances -OVP
                    IF l_currency_code = l_inv_curr_code THEN
                      l_onacc_amount:=l_amount_app_to;
                    ELSE
                      l_onacc_amount:= l_amount_app_to * l_conversion_rate;
                      l_onacc_amount := GET_ROUNDED_AMOUNT(l_onacc_amount,l_currency_code);
                    END IF;
                Elsif l_over_payment In ('F','f') Then --Unapply  -- move cash to unapplied -OVP
                    IF l_currency_code = l_inv_curr_code THEN
                      l_unapply_amount:=l_amount_app_to;
                    ELSE
                      l_unapply_amount:= l_amount_app_to * l_conversion_rate;
                      l_unapply_amount := GET_ROUNDED_AMOUNT(l_unapply_amount,l_currency_code);
                    END IF;
                End If;
           END IF; -- under payment. (2)


           --  **********************************************
           --  Stream level cash application processing ENDS
           --  **********************************************

       ELSE

                   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Per/Contract level cash application processing BEGINS');

                   END IF;
           --  ******************************************************
           --  Per/Contract level cash application processing BEGINS
           --  ******************************************************


           OPEN c_get_contract_num(l_cons_bill_id);

           LOOP

               FETCH c_get_contract_num INTO l_contract_id, l_contract_num;

                          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_contract_num : '||l_contract_num);
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_amount_app_to : '||l_amount_app_to);

                          END IF;
               EXIT WHEN c_get_contract_num%NOTFOUND
                   OR l_amount_app_to = 0
                   OR l_amount_app_to IS NULL;

               IF l_last_contract_id <> l_contract_id THEN -- added by bv

                   l_last_contract_id := l_contract_id;  -- added by bv

                   IF l_contract_num IS NOT NULL THEN

                       OPEN c_cash_rle_id_csr (l_contract_id);
                       FETCH c_cash_rle_id_csr INTO l_cau_id;
                       CLOSE c_cash_rle_id_csr;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cau_id : '||l_cau_id);

  END IF;
                       IF l_cau_id IS NOT NULL THEN

                           OPEN c_cash_rule_csr (l_cau_id);
                           FETCH c_cash_rule_csr INTO  l_cat_id
                                                      ,l_tolerance
                                                      ,l_days_past_quote_valid
                                                      ,l_months_to_bill_ahead
                                                      ,l_under_payment
                                                      ,l_over_payment
                                                      ,l_receipt_msmtch;
                           CLOSE c_cash_rule_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tolerance : '||l_tolerance);

      END IF;
                 IF l_tolerance IS NULL THEN
                  Get_Default_Cash_App_Rule(
                         l_org_id
                        ,l_cat_id
                        ,l_tolerance
                        ,l_days_past_quote_valid
                        ,l_months_to_bill_ahead
                        ,l_under_payment
                        ,l_over_payment
                        ,l_receipt_msmtch);
                 END IF;

                       ELSE -- use default rule

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cau_id is null, using default cash appln rule');

    END IF;
                  Get_Default_Cash_App_Rule(
                         l_org_id
                        ,l_cat_id
                        ,l_tolerance
                        ,l_days_past_quote_valid
                        ,l_months_to_bill_ahead
                        ,l_under_payment
                        ,l_over_payment
                        ,l_receipt_msmtch);

                       END IF;

                       -- get contract total
                       l_cont_tot := 0;
                       j := 0;
                       FOR i IN open_inv_tbl.FIRST..open_inv_tbl.LAST
                       LOOP
                           IF open_inv_tbl(i).contract_number = l_contract_num THEN
                             -- l_invoice_currency_code := c_open_invs_rec.currency_code;
                             j := j + 1;
                             open_inv_contract_tbl(j) := open_inv_tbl(i);
                             l_cont_tot := l_cont_tot + open_inv_tbl(i).invoice_due_remaining;
                           END IF;
                           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cont_tot : '||l_cont_tot);
                           END IF;
                       END LOOP;
                       j := 0;

                       IF NVL(l_cau_id, 0) = -1 THEN  -- VR 07-Oct-2005 GE-20 Receipts - On Account CAR
                                                      -- Receipt needs to be left as unapplied
                         j := 1;
                         l_rcpt_tbl(j).INVOICE_ID := NULL;
                         l_rcpt_tbl(j).INVOICE_LINE_ID := NULL;
                         l_rcpt_tbl(j).INVOICE_LINE_NUMBER := NULL;
                         l_rcpt_tbl(j).INVOICE_NUMBER        := NULL;
                         l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_Code;
                         l_rcpt_tbl(j).AMOUNT_APPLIED        := l_amount_app_to;

                       ELSE

                         -- calculate tolerance
                         IF l_cont_tot > l_amount_app_to THEN
                           l_appl_tolerance := l_cont_tot * (1 - l_tolerance / 100);
                         ELSE
                           l_appl_tolerance := l_cont_tot;
                         END IF;

                         --  Contract level cash application processing begins.
                         --  *************************************************
                         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Checking UNDERPAYMENT/OVERPAYMENT/MATCH');
                           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_cont_tot : '||l_cont_tot);
                           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_amount_app_to : '||l_amount_app_to);
                           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_appl_tolerance : '||l_appl_tolerance);
                         END IF;
                         IF l_cont_tot > l_amount_app_to AND l_appl_tolerance > l_amount_app_to THEN -- UNDERPAYMENT  (2)
                           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'UNDERPAYMENT');
                           END IF;

                           IF l_under_payment In ('U','u') THEN -- Unapply underpayment (3)
                             IF l_currency_code = l_inv_curr_code THEN
                               l_unapply_amount:=l_amount_app_to;
                             ELSE
                               l_unapply_amount:= l_amount_app_to * l_conversion_rate;
                               l_unapply_amount := GET_ROUNDED_AMOUNT(l_unapply_amount,l_currency_code);
                             END IF;
                           ELSIF l_under_payment IN ('T','t') THEN -- ORDERED (3)

                             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ORDERED');
                             END IF;
                             OPEN c_stream_alloc (l_ordered, l_cat_id);
                             LOOP
                               FETCH c_stream_alloc INTO l_sty_id;
                               EXIT WHEN c_stream_alloc%NOTFOUND
                                      OR l_amount_app_to = 0
                                      OR l_amount_app_to IS NULL;

                               FOR i IN open_inv_contract_tbl.FIRST..open_inv_contract_tbl.LAST
                               LOOP
                                 c_open_invs_rec := open_inv_contract_tbl(i);
                                 EXIT WHEN l_amount_app_to = 0 OR l_amount_app_to IS NULL;
                                 IF c_open_invs_rec.stream_type_id = l_sty_id THEN
                                   j := j + 1;

                                   l_rcpt_tbl(j).AMOUNT_APPLIED        := c_open_invs_rec.invoice_due_remaining;
                                   l_rcpt_tbl(j).INVOICE_ID := c_open_invs_rec.ar_invoice_id;
                                   l_rcpt_tbl(j).INVOICE_NUMBER := c_open_invs_rec.ar_invoice_number;
                                   l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_Code;
                                   l_rcpt_tbl(j).INVOICE_LINE_ID := c_open_invs_rec.ar_invoice_line_id;
                                   l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_open_invs_rec.ar_invoice_line_number;

                                   IF l_rcpt_tbl(j).AMOUNT_APPLIED > l_amount_app_to THEN
                                     l_rcpt_tbl(j).AMOUNT_APPLIED := l_amount_app_to;
                                     l_amount_app_to := 0;
                                   ELSE
                                     l_amount_app_to := l_amount_app_to - l_rcpt_tbl(j).AMOUNT_APPLIED;
                                   END IF;

                                   l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_Code;

                                        --j := j + 1;
                                   IF l_currency_code <> l_inv_curr_code THEN
                                  IF l_inv_to_rct_rate is null THEN
                                     l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                     log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                     IF l_exchange_rate_type IS  NULL THEN
                                        OKL_API.set_message( p_app_name      => G_APP_NAME
                                                            ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                           );
                                        RAISE G_EXCEPTION_HALT_VALIDATION;
                                     ELSE
                                        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                   ,l_currency_code
                                                                                   ,l_receipt_date
                                                                                   ,l_exchange_rate_type
                                                                                   );

                                        IF l_conversion_rate IN (0,-1) THEN

                                            -- Message Text: No exchange rate defined
                                            x_return_status := okl_api.G_RET_STS_ERROR;
                                            okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                            RAISE G_EXCEPTION_HALT_VALIDATION;
                                        END IF;
                                     END IF;
                                  ELSE
                                    l_conversion_rate := l_inv_to_rct_rate;
                                  END IF;
                                   l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM := arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                ELSE
                                   l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                END IF;
                                   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
                                     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
                                   END IF;
                                 END IF;
                               END LOOP;
                             END LOOP;
                             CLOSE c_stream_alloc;

                           ELSIF l_under_payment IN ('P','p') THEN -- PRO RATE (3)

                             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                               OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'PRO RATE');
                             END IF;
                             l_first_prorate_rec_j   := j + 1;

                               -- obtain all the streams that are part of the pro rate user defined list.

                               FOR c_stream_alloc_rec IN c_stream_alloc (l_prorate, l_cat_id)
                               LOOP

                                 l_sty_id := c_stream_alloc_rec.sty_id;
                                 FOR i IN open_inv_contract_tbl.FIRST..open_inv_contract_tbl.LAST
                                 LOOP
                                   c_open_invs_rec := open_inv_contract_tbl(i);
                                   IF c_open_invs_rec.stream_type_id = l_sty_id THEN
                                     j := j + 1;

                                     l_rcpt_tbl(j).AMOUNT_APPLIED        := c_open_invs_rec.invoice_due_remaining;
                                     l_rcpt_tbl(j).INVOICE_ID := c_open_invs_rec.ar_invoice_id;
                                         l_rcpt_tbl(j).INVOICE_NUMBER := c_open_invs_rec.ar_invoice_number;
                                     l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_Code;
                                     l_rcpt_tbl(j).INVOICE_LINE_ID := c_open_invs_rec.ar_invoice_line_id;
                                         l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_open_invs_rec.ar_invoice_line_number;
                                     IF l_currency_code <> l_inv_curr_code THEN
                                  IF l_inv_to_rct_rate is null THEN
                                     l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                     log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                     IF l_exchange_rate_type IS  NULL THEN
                                        OKL_API.set_message( p_app_name      => G_APP_NAME
                                                            ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                           );
                                        RAISE G_EXCEPTION_HALT_VALIDATION;
                                     ELSE
                                        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                   ,l_currency_code
                                                                                   ,l_receipt_date
                                                                                   ,l_exchange_rate_type
                                                                                   );

                                        IF l_conversion_rate IN (0,-1) THEN

                                            -- Message Text: No exchange rate defined
                                            x_return_status := okl_api.G_RET_STS_ERROR;
                                            okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                            RAISE G_EXCEPTION_HALT_VALIDATION;
                                        END IF;
                                     END IF;
                                  ELSE
                                    l_conversion_rate := l_inv_to_rct_rate;
                                  END IF;
                                   l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM := arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                ELSE
                                   l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                END IF;
                                     l_pro_rate_inv_total                := l_pro_rate_inv_total + l_rcpt_tbl(j).AMOUNT_APPLIED;

                                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
                                       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);
                                     END IF;
                                   END IF;
                                 END LOOP; -- c_open_invs
                               END LOOP; -- c_stream_alloc

                               -- Calc Pro Ration
                               -- only if total amount of prorated invoices is greater than receipt

                               IF l_pro_rate_inv_total IS NULL OR l_pro_rate_inv_total = 0 THEN

                                   -- Message Text: No prorated transaction types
                                   x_return_status := OKC_API.G_RET_STS_ERROR;
                                   OKC_API.set_message( p_app_name      => G_APP_NAME,
                                                        p_msg_name      => 'OKL_BPD_NO_PRORATED_STRMS');

                                   RAISE G_EXCEPTION_HALT_VALIDATION;

                                 END IF;

                               IF (l_pro_rate_inv_total > l_amount_app_to) THEN

                                   j := l_first_prorate_rec_j;

                                   l_temp_val := l_amount_app_to / l_pro_rate_inv_total;

                                   LOOP
                                       l_rcpt_tbl(j).AMOUNT_APPLIED := l_temp_val * l_rcpt_tbl(j).AMOUNT_APPLIED;
                                       l_rcpt_tbl(j).AMOUNT_APPLIED:=GET_ROUNDED_AMOUNT(l_rcpt_tbl(j).AMOUNT_APPLIED,l_inv_curr_Code);
                                       IF l_currency_code <> l_inv_curr_code THEN
                                  IF l_inv_to_rct_rate is null THEN
                                     l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                     log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                     IF l_exchange_rate_type IS  NULL THEN
                                        OKL_API.set_message( p_app_name      => G_APP_NAME
                                                            ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                           );
                                        RAISE G_EXCEPTION_HALT_VALIDATION;
                                     ELSE
                                        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                   ,l_currency_code
                                                                                   ,l_receipt_date
                                                                                   ,l_exchange_rate_type
                                                                                   );

                                        IF l_conversion_rate IN (0,-1) THEN

                                            -- Message Text: No exchange rate defined
                                            x_return_status := okl_api.G_RET_STS_ERROR;
                                            okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                            RAISE G_EXCEPTION_HALT_VALIDATION;
                                        END IF;
                                     END IF;
                                  ELSE
                                    l_conversion_rate := l_inv_to_rct_rate;
                                  END IF;
                                   l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM := arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                ELSE
                                   l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                END IF;
                                       l_inv_total_amt := l_inv_total_amt + l_rcpt_tbl(j).AMOUNT_APPLIED;
                                       EXIT WHEN (j = l_rcpt_tbl.LAST);
                                       j := j + 1;
                                   END LOOP;
                                   l_diff_amount := l_amount_app_to - l_inv_total_amt;
                                   if l_diff_amount > 0 then
                                     l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied := l_rcpt_tbl(l_rcpt_tbl.LAST).amount_Applied + l_diff_amount;
                                   end if;
                               END IF;

                           END IF; -- (3)

                       ELSE -- EXACT or OVERPAYMENT or TOLERANCE  (2)
                         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'EXACT or OVERPAYMENT or TOLERANCE');


                         END IF;
                            -- CREATE LINES TABLE
                           FOR i IN open_inv_contract_tbl.FIRST..open_inv_contract_tbl.LAST
                           LOOP
                               c_open_invs_rec := open_inv_contract_tbl(i);
                               EXIT WHEN l_amount_app_to = 0 OR l_amount_app_to IS NULL;

                               j := j + 1;
                                        l_rcpt_tbl(j).AMOUNT_APPLIED        := c_open_invs_rec.invoice_due_remaining;
                                        l_rcpt_tbl(j).INVOICE_ID := c_open_invs_rec.ar_invoice_id;
                                                l_rcpt_tbl(j).INVOICE_NUMBER := c_open_invs_rec.ar_invoice_number;
                                        l_rcpt_tbl(j).INVOICE_CURRENCY_CODE := l_inv_curr_Code;
                                        l_rcpt_tbl(j).INVOICE_LINE_ID := c_open_invs_rec.ar_invoice_line_id;
                                                l_rcpt_tbl(j).INVOICE_LINE_NUMBER := c_open_invs_rec.ar_invoice_line_number;

                               IF l_amount_app_to < l_rcpt_tbl(j).AMOUNT_APPLIED THEN
                               -- TOLERANCE
                                   --l_xcav_tbl(i).AMOUNT_APPLIED := l_amount_app_to;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED := l_amount_app_to;

                                   l_amount_app_to := 0;

                               ELSE

                                   l_amount_app_to := l_amount_app_to - l_rcpt_tbl(j).AMOUNT_APPLIED;

                               END IF;
                                IF l_currency_code <> l_inv_curr_code THEN
                                  IF l_inv_to_rct_rate is null THEN
                                     l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(p_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                                     log_debug('l_exchange_rate_type = '||l_exchange_rate_type);
                                     IF l_exchange_rate_type IS  NULL THEN
                                        OKL_API.set_message( p_app_name      => G_APP_NAME
                                                            ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                                           );
                                        RAISE G_EXCEPTION_HALT_VALIDATION;
                                     ELSE
                                        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_inv_curr_code
                                                                                   ,l_currency_code
                                                                                   ,l_receipt_date
                                                                                   ,l_exchange_rate_type
                                                                                   );

                                        IF l_conversion_rate IN (0,-1) THEN

                                            -- Message Text: No exchange rate defined
                                            x_return_status := okl_api.G_RET_STS_ERROR;
                                            okl_api.set_message( p_app_name      => G_APP_NAME,
                                                                 p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                                            RAISE G_EXCEPTION_HALT_VALIDATION;
                                        END IF;
                                     END IF;
                                  ELSE
                                    l_conversion_rate := l_inv_to_rct_rate;
                                  END IF;
                                   l_rcpt_tbl(j).trans_to_receipt_rate := l_conversion_rate;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM :=  l_rcpt_tbl(j).AMOUNT_APPLIED * l_conversion_rate;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM := arp_util.CurrRound(l_rcpt_tbl(j).AMOUNT_APPLIED_FROM,l_currency_code);
                                ELSE
                                   l_rcpt_tbl(j).trans_to_receipt_rate := null;
                                   l_rcpt_tbl(j).AMOUNT_APPLIED_FROM  := null;
                                END IF;
                                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).INVOICE_NUMBER : '||l_rcpt_tbl(j).INVOICE_NUMBER);
                                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rcpt_tbl(j).AMOUNT_APPLIED : '||l_rcpt_tbl(j).AMOUNT_APPLIED);

                                END IF;
                           END LOOP;
                                -- Apply the remaining balance as per the Cash Application Rule
                                If l_over_payment In ('B','b') Then  -- Onaccount --move cash to customer balances -OVP
                                    IF l_currency_code = l_inv_curr_code THEN
                                      l_onacc_amount:=l_amount_app_to;
                                    ELSE
                                      l_onacc_amount:= l_amount_app_to * l_conversion_rate;
                                      l_onacc_amount := GET_ROUNDED_AMOUNT(l_onacc_amount,l_currency_code);
                                    END IF;
                                Elsif l_over_payment In ('F','f') Then --Unapply  -- move cash to unapplied -OVP
                                    IF l_currency_code = l_inv_curr_code THEN
                                      l_unapply_amount:=l_amount_app_to;
                                    ELSE
                                      l_unapply_amount:= l_amount_app_to * l_conversion_rate;
                                      l_unapply_amount := GET_ROUNDED_AMOUNT(l_unapply_amount,l_currency_code);
                                    END IF;
                                End If;

                         END IF; -- under payment.

                       END IF; -- VR 07-Oct-2005 GE-20 Receipts - On Account CAR

                       --  Contract level cash application processing ends.
                       --  *************************************************

                     END IF;

                   ELSE -- added by bv

                       NULL;  -- added by bv

                   END IF;  -- added by bv

               END LOOP;
               CLOSE c_get_contract_num;

           END IF;  -- l_same_date/l_same_cash_rule

       END IF;



   -- END OKL CASH APPLICATION.


     --Get grouped application table (in the form of invoice header > multiple invoice lines table)
    GET_APPLICATIONS( p_rcpt_tbl => l_rcpt_tbl
                     ,x_appl_tbl => l_appl_tbl);
        x_appl_tbl := l_appl_tbl;

   l_tot_amt_app_from := 0;
   IF x_appl_tbl.COUNT > 0 THEN
     IF x_appl_tbl(x_appl_tbl.FIRST).inv_hdr_rec.trans_to_receipt_rate IS NOT NULL THEN
       FOR ll IN x_appl_tbl.FIRST..x_appl_tbl.LAST LOOP
         l_tot_amt_app_from := l_tot_amt_app_from + nvl(x_appl_tbl(ll).inv_hdr_rec.amount_applied_from,0);
       END LOOP;
      IF (l_onacc_amount + l_unapply_amount + l_tot_amt_app_from ) <> l_amount_app_from THEN
         l_diff_amount := l_amount_app_from - (l_onacc_amount + l_unapply_amount + l_tot_amt_app_from );
         log_debug('l_diff_amount = '||l_diff_amount);
         IF nvl(l_onacc_amount,0) <> 0  THEN
           l_onacc_amount := l_onacc_amount + l_diff_amount;
           log_debug('l_onacc_amount = '||l_onacc_amount);
         ELSIF nvl(l_unapply_amount,0) <> 0  THEN
           l_unapply_amount := l_unapply_amount + l_diff_amount;
         END IF;
       END IF;
    END IF;
  END IF;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Done execution of OKL_AUTO_CASH_APPL_RULES_pvt.auto_cash_app_for_consinv ...');


     END IF;
     x_return_status := OKL_API.G_RET_STS_SUCCESS;

x_onacc_amount:= l_onacc_amount ;
x_unapply_amount:= l_unapply_amount;

EXCEPTION

   WHEN OTHERS THEN
     x_appl_tbl.DELETE;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count := l_msg_count;
     x_msg_data := l_msg_data;

END auto_cashapp_for_consinv;

 FUNCTION GET_ROUNDED_AMOUNT( p_amount_to_round IN NUMBER
                             ,p_currency_code IN VARCHAR2)
          RETURN NUMBER
 AS
 BEGIN
--    RETURN( arpcurr.CurrRound( p_amount_to_round, p_currency_code ) );
    RETURN okl_accounting_util.round_amount(p_amount_to_round,p_currency_code);
 EXCEPTION
   WHEN OTHERS THEN
     RETURN 0;
 END GET_ROUNDED_AMOUNT;

END OKL_AUTO_CASH_APPL_RULES_PVT;

/
