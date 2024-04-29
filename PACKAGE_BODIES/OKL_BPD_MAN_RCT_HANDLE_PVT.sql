--------------------------------------------------------
--  DDL for Package Body OKL_BPD_MAN_RCT_HANDLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BPD_MAN_RCT_HANDLE_PVT" AS
/* $Header: OKLRMRHB.pls 120.8 2007/08/02 07:12:11 dcshanmu noship $ */

  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.SETUP';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;

  -- Message constants
  G_MSG_BPD_INV_APPL_AMT VARCHAR2(30)    := 'OKL_BPD_INV_APPL_AMT';
  G_MSG_BPD_NO_AMT_TO_APPLY VARCHAR2(30) := 'OKL_BPD_NO_AMT_TO_APPLY';
  G_MSG_BPD_APP_NEG_UNAPP VARCHAR2(30)   := 'OKL_BPD_RCPT_ALLOC_ERR';
  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By     : abindal
    -- Procedure Name : man_receipt_apply
    -- Description    : Procedure functions to apply the receipts to the relevant
    --                  invoices using the AR procedures. The steps involved are:
    --                  (i) Insert a row in OKL_EXT_CSH_APPS_B/TL table
    --                  (i) Place all the On-Acc Amt in UnApply Amt
    --                 (ii) Unapply the previous applied amount. And add the current
    --                      applied amount to the previous applied amount.
    --                 (iv) Apply the receipt amount to all the invoices
    --                  (v) If there is any amount left on the receipt, place it
    --                      on account.
    --                 (vi) If there is any part of the intial UnApply amount that
    --                      is not used, return the part unused to UnApply Amount.
    --                 (vii) If the receipt is Adanced, update the FULLY_APPLIED_FLAG
    --                      of the OKL_EXT_CSH_APPS_B table
    -- Dependencies   :
    -- Parameters     :
    -- Version        : 1.0
    -- End of Comments
  -----------------------------------------------------------------------------
PROCEDURE man_receipt_apply      (   p_api_version       IN  NUMBER
                                    ,p_init_msg_list     IN  VARCHAR2 DEFAULT OkL_Api.G_FALSE
                                    ,x_return_status     OUT NOCOPY VARCHAR2
                                    ,x_msg_count         OUT NOCOPY NUMBER
                                    ,x_msg_data          OUT NOCOPY VARCHAR2
                                    ,p_xcav_tbl          IN  xcav_tbl_type
                                    ,p_receipt_id        IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL -- cash receipt id
                                    ,p_receipt_amount    IN  AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE
                                    ,p_receipt_date      IN  AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT NULL
                                    ,p_receipt_currency  IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                  ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

  l_api_version         NUMBER := 1.0;
  l_init_msg_list               VARCHAR2(1) := OKL_API.G_FALSE;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'man_receipt_apply';

  l_conversion_rate             GL_DAILY_RATES_V.CONVERSION_RATE%TYPE DEFAULT 0;

  l_receipt_number              OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL;
  l_receipt_type                OKL_TRX_CSH_RECEIPT_V.RECEIPT_TYPE%TYPE DEFAULT NULL;
  l_receipt_date                AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT p_receipt_date;
  l_receipt_currency_code       OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT p_receipt_currency;
  l_receipt_amount              OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL;

  l_xcr_id                      NUMBER;

  l_customer_trx_id             AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_TRX_ID%TYPE DEFAULT NULL;
  l_cash_receipt_id             AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_receipt_id;

  l_trans_currency_code         OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;  -- entered currency code

  l_init_on_acc_amount          AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL;
  l_tot_applied_amount          AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT 0;
  l_applied_amount              AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL;
  l_applied_amount_from         AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED_FROM%TYPE DEFAULT NULL;
  l_tot_amount_to_apply         AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT 0;
  l_unapplied_amount            AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL;
  l_outstanding_amt             AR_PAYMENT_SCHEDULES_ALL.AMOUNT_DUE_REMAINING%TYPE DEFAULT 0;

  l_prev_applied_amt            AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL;
  l_remaining_amt               NUMBER DEFAULT NULL;

  l_receivable_application_id   AR_RECEIVABLE_APPLICATIONS_ALL.RECEIVABLE_APPLICATION_ID%TYPE DEFAULT NULL;

  l_gl_date                     OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
  l_apply_date                  OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;

  i                             NUMBER DEFAULT NULL;
  l_exit_loop                   NUMBER DEFAULT 0;

  l_counter                     NUMBER;
  l_unapply                     VARCHAR2(3);

  l_record_count                NUMBER DEFAULT NULL;
  l_org_id                      OKL_TRX_CSH_RECEIPT_V.ORG_ID%TYPE DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();
  l_chk_on_acc_amt              AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL;
  l_apply_amt_error_flag        BOOLEAN := FALSE;
  -------------------------------------------------------------------------------
  -- DECLARE Record/Table Types
  -------------------------------------------------------------------------------

  -- External Trans
  lp_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;
  lx_xcav_rec Okl_Xca_Pvt.xcav_rec_type;

  lp_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;
  lx_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;

  -------------------------------------------------------------------------------
  -- DEFINE CURSORS
  -------------------------------------------------------------------------------
    --get gl date from open accounting period
     CURSOR c_get_gl_date(cp_date IN DATE) IS SELECT * from (
     SELECT trunc(cp_date) gl_date, 1 Counter
     FROM gl_period_statuses
     WHERE application_id = 222
     -- BEGIN abindal bug 4356410 --
     AND closing_status IN ('F','O')
     -- END abindal bug 4356410 --
     AND ledger_id = okl_accounting_util.get_set_of_books_id
     AND trunc(cp_date) between start_date and end_date
     AND adjustment_period_flag = 'N'
     UNION
     SELECT MAX(end_date) gl_date, 2 Counter
     FROM gl_period_statuses
     WHERE application_id = 222
     AND ledger_id = okl_accounting_util.get_set_of_books_id
     AND closing_status IN ('F','O')
     AND end_date <= trunc(cp_date)
     AND adjustment_period_flag = 'N'
     UNION
     SELECT MIN(start_date) gl_date, 3 Counter
     FROM gl_period_statuses
     WHERE application_id = 222
     AND ledger_id = okl_accounting_util.get_set_of_books_id
     AND closing_status IN ('F','O')
     AND start_date >= trunc(cp_date)
     AND adjustment_period_flag = 'N'
     )
     where gl_date is not null
     order by counter;
  -------------------------------------------------------------------------------
  -- Get the receipt information
  CURSOR c_get_rcpt_details(cp_cash_rcpt_id IN AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE) IS
  SELECT
         RCT.CHECK_NUMBER RECEIPT_NUMBER
       , RCT.RECEIPT_TYPE
       , RCT.AMOUNT
       , NULL ID
    FROM
        OKL_TRX_CSH_RECEIPT_V RCT
--      , OKL_EXT_CSH_RCPTS_V   XCR
   WHERE
--         XCR.RCT_ID = RCT.ID
--     AND XCR.ICR_ID = cp_cash_rcpt_id;
	RCT.CASH_RECEIPT_ID = cp_cash_rcpt_id;
  -------------------------------------------------------------------------------

  -- verify on account receipt amount
  CURSOR   c_ver_on_acct_amt(cp_csh_rcpt_id IN NUMBER) IS
  SELECT   NVL(SUM(AMOUNT_APPLIED),0)
  FROM     AR_RECEIVABLE_APPLICATIONS_ALL
  WHERE    STATUS = 'ACC'
  AND      CASH_RECEIPT_ID = cp_csh_rcpt_id;

  -------------------------------------------------------------------------------

  -- verify unapplied receipt amount
  CURSOR   c_ver_unapp_amt(cp_csh_rcpt_id IN NUMBER) IS
  SELECT   NVL(SUM(AMOUNT_APPLIED),0)
  FROM     AR_RECEIVABLE_APPLICATIONS_ALL
  WHERE    STATUS = 'UNAPP'
  AND      CASH_RECEIPT_ID = cp_csh_rcpt_id;

  -------------------------------------------------------------------------------

  -- check receipt applic
  CURSOR   c_ver_dup_applic( cp_customer_trx_id IN NUMBER
                            ,cp_cash_receipt_id IN NUMBER) IS
  SELECT   NVL(AMOUNT_APPLIED,0), NVL(RECEIVABLE_APPLICATION_ID,0)
  FROM     AR_RECEIVABLE_APPLICATIONS_ALL
  WHERE    APPLIED_CUSTOMER_TRX_ID = cp_customer_trx_id
  AND      CASH_RECEIPT_ID = cp_cash_receipt_id
  AND      STATUS = 'APP'
  ORDER BY CREATION_DATE desc;

  -------------------------------------------------------------------------------
  -- Gets the Invoice details for the stream
  CURSOR c_get_rec_inv_dtls( cp_stream_id IN OKL_CNSLD_AR_STRMS_V.ID%TYPE ) IS
    SELECT CNSLD.RECEIVABLES_INVOICE_ID
      FROM OKL_CNSLD_AR_STRMS_V CNSLD
     WHERE CNSLD.ID = cp_stream_id;
  -------------------------------------------------------------------------------

  -- Obtain the payment details for the invoice
CURSOR c_get_pymt_dtls(cp_customer_trx_id AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_TRX_ID%TYPE) IS
  SELECT
         APS.AMOUNT_DUE_REMAINING
    FROM
         AR_PAYMENT_SCHEDULES_ALL APS
   WHERE
         APS.CUSTOMER_TRX_ID = cp_customer_trx_id;
  -------------------------------------------------------------------------------
BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRMRHB.pls call MAN_RECEIPT_APPLY');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name
      , p_pkg_name      => G_PKG_NAME
      , p_init_msg_list => p_init_msg_list
      , l_api_version   => l_api_version
      , p_api_version   => p_api_version
      , p_api_type      => G_API_TYPE
      , x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    lp_xcav_tbl := p_xcav_tbl;

    l_record_count := lp_xcav_tbl.COUNT;

    -- Obtain the receipt details
    OPEN c_get_rcpt_details(l_cash_receipt_id);
      FETCH c_get_rcpt_details INTO l_receipt_number
                                  , l_receipt_type
                                  , l_receipt_amount
                                  , l_xcr_id;
    CLOSE c_get_rcpt_details;

    -- Obtain the On-Account Amount on the receipt before start of processing
    OPEN  c_ver_on_acct_amt(l_cash_receipt_id);
      FETCH c_ver_on_acct_amt INTO l_init_on_acc_amount;
    CLOSE c_ver_on_acct_amt;
    IF l_init_on_acc_amount IS NULL THEN
      l_init_on_acc_amount := 0;
    END IF;

    OPEN  c_ver_unapp_amt(l_cash_receipt_id);
      FETCH c_ver_unapp_amt INTO l_unapplied_amount;
    CLOSE c_ver_unapp_amt;
    IF l_unapplied_amount IS NULL THEN
      l_unapplied_amount := 0;
    END IF;

    l_unapply := 'N';
    l_tot_applied_amount := 0;

    IF l_record_count > 0  THEN

      ------------------------------------------
      -- Validations
      ------------------------------------------
      l_tot_amount_to_apply := 0;
      FOR i IN lp_xcav_tbl.FIRST..lp_xcav_tbl.LAST
      LOOP
        -- Get the receivable invoice ID
        OPEN c_get_rec_inv_dtls(lp_xcav_tbl(i).lsm_id);
          FETCH c_get_rec_inv_dtls INTO l_customer_trx_id;
        CLOSE c_get_rec_inv_dtls;

        OPEN c_get_pymt_dtls(l_customer_trx_id);
          FETCH c_get_pymt_dtls INTO l_outstanding_amt;
        CLOSE c_get_pymt_dtls;

        l_tot_amount_to_apply := l_tot_amount_to_apply +
                                 lp_xcav_tbl(i).amount_applied;

        IF (lp_xcav_tbl(i).amount_applied > l_outstanding_amt ) THEN
          OKL_API.set_message( p_app_name      => G_APP_NAME,
                               p_msg_name      => G_MSG_BPD_INV_APPL_AMT,
                               p_token1        => 'RCT',
                               p_token1_value  => l_receipt_number,
                               p_token2        => 'INV',
                               p_token2_value  => lp_xcav_tbl(i).invoice_number);
          l_apply_amt_error_flag := TRUE;
        END IF;

      END LOOP; -- end of for loop

      -- If there is no amount to apply
      IF ( l_tot_amount_to_apply = 0) THEN
               OKL_API.set_message( p_app_name      => G_APP_NAME,
                                    p_msg_name      => G_MSG_BPD_NO_AMT_TO_APPLY,
                                    p_token1        => 'RCT',
                                    p_token1_value  => l_receipt_number
                                    );
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- If there are records with applied amount exceeding the outstanding amount
      IF (l_apply_amt_error_flag) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- If the total amount to be applied is greater then the sum of on-account amount
      -- and unapplied amount then throw an error.
      if(l_tot_amount_to_apply > (l_init_on_acc_amount + l_unapplied_amount)) THEN
          OKL_API.set_message( p_app_name      => G_APP_NAME,
                               p_msg_name      => G_MSG_BPD_APP_NEG_UNAPP
                              );
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

        i := lp_xcav_tbl.FIRST;
        LOOP
          l_trans_currency_code := lp_xcav_tbl(i).invoice_currency_code;

          OPEN c_get_rec_inv_dtls(lp_xcav_tbl(i).lsm_id);
            FETCH c_get_rec_inv_dtls INTO l_customer_trx_id;
          CLOSE c_get_rec_inv_dtls;

          ----------------------------------------------------------
          -- Initialization of Cash appln Record p_xcav_rec begin
          ----------------------------------------------------------

          IF l_receipt_currency_code = l_trans_currency_code THEN
            l_applied_amount := lp_xcav_tbl(i).amount_applied;
            l_applied_amount_from := NULL;
          ELSE
            l_applied_amount := lp_xcav_tbl(i).amount_applied;
            -- Convert receipt currency to invoice currency if different
            l_conversion_rate := okl_accounting_util.get_curr_con_rate
                                      ( l_receipt_currency_code
                                       ,l_trans_currency_code
                                       ,trunc(SYSDATE)
                                       ,'Corporate'
                                       );

             IF l_conversion_rate IN (0,-1) THEN
               -- Message Text: No exchange rate defined
               x_return_status := OKL_API.G_RET_STS_ERROR;
               OKL_API.set_message( p_app_name      => G_APP_NAME,
                                    p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             l_applied_amount_from := lp_xcav_tbl(i).amount_applied/l_conversion_rate;

             lp_xcav_tbl(i).amount_applied_from   := l_applied_amount_from;
             lp_xcav_tbl(i).trans_to_receipt_rate := l_conversion_rate;
          END IF; -- end of check for receipt currency = transaction currency

          IF (lp_xcav_tbl(i).trx_date >= l_receipt_date) AND (lp_xcav_tbl(i).trx_date >= SYSDATE) THEN
            l_apply_date := lp_xcav_tbl(i).trx_date;
          ELSIF (l_receipt_date >= lp_xcav_tbl(i).trx_date) AND (l_receipt_date >= SYSDATE) THEN
            l_apply_date := l_receipt_date;
          ELSE
            l_apply_date := SYSDATE;
          END IF; -- end of comparison of system date, receipt date and AR Invoice transaction date

            OPEN c_get_gl_date(l_apply_date);
              FETCH c_get_gl_date INTO l_gl_date, l_counter;

              IF c_get_gl_date%NOTFOUND THEN
                CLOSE c_get_gl_date;
                OKL_API.SET_MESSAGE( p_app_name    => G_APP_NAME,
                                     p_msg_name    => 'OKL_BPD_GL_PERIOD_ERROR',
                                     p_token1      => 'TRX_DATE',
                                     p_token1_value => TRUNC(lp_xcav_tbl(i).trx_date));

                l_return_status := OKL_API.G_RET_STS_ERROR;
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
           CLOSE c_get_gl_date;

          lp_xcav_tbl(i).xcr_id_details        := l_xcr_id;
          lp_xcav_tbl(i).org_id                := l_org_id;
          ----------------------------------------------------------
          -- Initialization of Cash appln Record p_xcav_rec end
          ----------------------------------------------------------
          OKL_XCA_PVT.insert_row( p_api_version   => l_api_version
                                 ,p_init_msg_list => l_init_msg_list
                                 ,x_return_status => l_return_status
                                 ,x_msg_count     => l_msg_count
                                 ,x_msg_data      => l_msg_data
                                 ,p_xcav_rec      => lp_xcav_tbl(i)
                                 ,x_xcav_rec      => lx_xcav_rec
                                );

           x_return_status := l_return_status;
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           --------------------------------------------------------
           -- AR processing begin
           --------------------------------------------------------
           -- Process only if there is atleast some amount to apply
           IF l_applied_amount = 0 THEN
             NULL;
           ELSE
             -- unapply cash from customers account once only
             IF l_unapply = 'N' THEN
               -- Curosr to check if there is any Amount on account to unapply
               OPEN c_ver_on_acct_amt (l_cash_receipt_id);
                 FETCH c_ver_on_acct_amt INTO l_chk_on_acc_amt;
               CLOSE c_ver_on_acct_amt ;

               -- Unapply only if there is any amount on account
               IF NVL(l_chk_on_acc_amt,0) <> 0 THEN
                 AR_RECEIPT_API_PUB.unapply_on_account(
                            p_api_version        => l_api_version
                           ,p_init_msg_list      => p_init_msg_list
                           ,x_return_status      => l_return_status
                           ,x_msg_count          => l_msg_count
                           ,x_msg_data           => l_msg_data
                           ,p_cash_receipt_id    => l_cash_receipt_id
                           ,p_reversal_gl_date   => null
                              );

                  x_return_status := l_return_status;

                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;
                l_unapply := 'Y';
              END IF; -- end of check for unApply flag

                OPEN  c_ver_dup_applic (l_customer_trx_id, l_cash_receipt_id);
                FETCH c_ver_dup_applic INTO l_prev_applied_amt, l_receivable_application_id;
                CLOSE c_ver_dup_applic;

                IF l_prev_applied_amt > 0 AND l_receivable_application_id IS NOT NULL THEN

                    AR_RECEIPT_API_PUB.Unapply( p_api_version               => l_api_version
                                               ,p_init_msg_list             => l_init_msg_list
                                               ,x_return_status             => l_return_status
                                               ,x_msg_count                 => l_msg_count
                                               ,x_msg_data                  => l_msg_data
                                               ,p_cash_receipt_id           => l_cash_receipt_id
                                               ,p_customer_trx_id           => l_customer_trx_id
                                               ,p_receivable_application_id => l_receivable_application_id
                                               ,p_reversal_gl_date          => null
                                              );

                    x_return_status := l_return_status;

                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    l_applied_amount := l_applied_amount + l_prev_applied_amt;

                END IF;

                AR_RECEIPT_API_PUB.apply( p_api_version           => l_api_version
                                         ,p_init_msg_list         => l_init_msg_list
                                         ,x_return_status         => l_return_status
                                         ,x_msg_count             => l_msg_count
                                         ,x_msg_data              => l_msg_data
                                         ,p_customer_trx_id       => l_customer_trx_id
                                         ,p_amount_applied        => l_applied_amount       -- in func/rcpt currency.
                                         ,p_amount_applied_from   => l_applied_amount_from  -- in rcpt_currency
                                         ,p_apply_gl_date         => l_gl_date
                                         ,p_apply_date            => l_apply_date
                                         ,p_cash_receipt_id       => l_cash_receipt_id
                                        );

                x_return_status := l_return_status;

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

            -- Add up the applied amounts for calculating the unused part
            -- of On-Account amount at the end of the process.
            l_tot_applied_amount := l_tot_applied_amount + lp_xcav_tbl(i).amount_applied;
            END IF; -- end of check if the amount to be applied is not zero

            EXIT WHEN (i = lp_xcav_tbl.LAST);

            i := i + 1;

        END LOOP;

    END IF;
    l_remaining_amt := l_init_on_acc_amount - l_tot_applied_amount;

    -- Get the part of the intial On_account amount which was not used during
    -- application process, from the Unapplied amount. This is done to return any
    -- amount that was on account during the start of this procedure that was not
    -- used during the application of receipts to invoices.
    IF l_remaining_amt > 0 THEN

            OPEN c_get_gl_date(l_receipt_date);
              FETCH c_get_gl_date INTO l_gl_date, l_counter;

              IF c_get_gl_date%NOTFOUND THEN
                CLOSE c_get_gl_date;
                OKL_API.SET_MESSAGE( p_app_name    => G_APP_NAME,
                                     p_msg_name    => 'OKL_BPD_GL_PERIOD_ERROR',
                                     p_token1      => 'TRX_DATE',
                                     p_token1_value => TRUNC(lp_xcav_tbl(i).trx_date));

                l_return_status := OKL_API.G_RET_STS_ERROR;
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
           CLOSE c_get_gl_date;

      AR_RECEIPT_API_PUB.Apply_on_account( p_api_version     => l_api_version
                                          ,p_init_msg_list   => l_init_msg_list
                                          ,x_return_status   => l_return_status
                                          ,x_msg_count       => l_msg_count
                                          ,x_msg_data        => l_msg_data
                                          ,p_cash_receipt_id => l_cash_receipt_id
                                          ,p_amount_applied  => l_remaining_amt
                                          ,p_apply_date      => l_receipt_date
                                          ,p_apply_gl_date   => l_gl_date
                                           );

       x_return_status := l_return_status;

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

    END IF; -- end of check for unused On-Acc amount

    -- Check if the receipt is of type ADVANCED
    IF l_receipt_type = 'ADV' THEN
      lp_xcrv_rec.id := l_xcr_id;
      -- Check if all the amount has been applied for the receipt
      IF l_receipt_amount = l_applied_amount  THEN
        lp_xcrv_rec.fully_applied_flag := 'Y';
      ELSE
        lp_xcrv_rec.fully_applied_flag := 'N';
      END IF;
      -- Update the FULLY_APPLIED_FLAG colum for Advance receipts
      OKL_XCR_PUB.UPDATE_EXT_CSH_TXNS( p_api_version   => l_api_version
                                      ,p_init_msg_list => l_init_msg_list
                                      ,x_return_status => l_return_status
                                      ,x_msg_count     => l_msg_count
                                      ,x_msg_data      => l_msg_data
                                      ,p_xcrv_rec      => lp_xcrv_rec
                                      ,x_xcrv_rec      => lx_xcrv_rec
                                      );

      x_return_status := l_return_status;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- end of check for Advance receipt

    -- commit the savepoint
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRMRHB.pls call MAN_RECEIPT_APPLY');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

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
      Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

END man_receipt_apply;




  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By     : abindal
    -- Procedure Name : man_receipt_unapply
    -- Description    : Procedure functions to unapply the invioce amount for a
    --                  corresponding receipt using the AR procedures.
    --                  The steps involved are:
    --                  (i)   Insert a row in OKL_EXT_CSH_APPS_B/TL table
    --                  (ii)  Unapply the invoice amount and add it to the receipt
    --                        unapplied amount.
    --                  (iii) If the receipt is Adanced, update the FULLY_APPLIED_FLAG
    --                        of the OKL_EXT_CSH_APPS_B table
    -- Dependencies   :
    -- Parameters     :
    -- Version        : 1.0
    -- End of Comments
  -----------------------------------------------------------------------------
PROCEDURE man_receipt_unapply     (  p_api_version       IN  NUMBER
                                    ,p_init_msg_list     IN  VARCHAR2 DEFAULT OkL_Api.G_FALSE
                                    ,x_return_status     OUT NOCOPY VARCHAR2
                                    ,x_msg_count         OUT NOCOPY NUMBER
                                    ,x_msg_data          OUT NOCOPY VARCHAR2
                                    ,p_xcav_tbl          IN  xcav_tbl_type
                                    ,p_receipt_id        IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL -- cash receipt id
                                    ,p_receipt_date      IN  AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT NULL
                                  ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

  l_api_version                 NUMBER := 1.0;
  l_init_msg_list               VARCHAR2(1) := OKL_API.G_FALSE;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'man_receipt_unapply';

  l_receipt_number              OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL;
  l_receipt_type                OKL_TRX_CSH_RECEIPT_V.RECEIPT_TYPE%TYPE DEFAULT NULL;
  l_receipt_date                AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT p_receipt_date;
  l_receipt_amount              OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL;
  l_receipt_currency            OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;
  l_applied_amount              AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL;
  l_total_applied_amount        AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL;
  l_trans_currency_code         OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;  -- entered currency code
  l_conversion_rate             GL_DAILY_RATES_V.CONVERSION_RATE%TYPE DEFAULT 0;
  l_applied_amount_from         AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED_FROM%TYPE DEFAULT NULL;

  l_xcr_id                      NUMBER;
  l_customer_trx_id             AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_TRX_ID%TYPE DEFAULT NULL;
  l_cash_receipt_id             AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_receipt_id;

  l_receivable_application_id   AR_RECEIVABLE_APPLICATIONS_ALL.RECEIVABLE_APPLICATION_ID%TYPE DEFAULT NULL;
  l_gl_date                     OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
  l_apply_date                  OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
  i                             NUMBER DEFAULT NULL;
  l_counter                     NUMBER;
  l_record_count                NUMBER DEFAULT NULL;
  l_org_id                      OKL_TRX_CSH_RECEIPT_V.ORG_ID%TYPE DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();

  -------------------------------------------------------------------------------
  -- DECLARE Record/Table Types
  -------------------------------------------------------------------------------

  -- External Trans
  lp_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;
  lx_xcav_rec Okl_Xca_Pvt.xcav_rec_type;

  lp_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;
  lx_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;

  -------------------------------------------------------------------------------
  -- DEFINE CURSORS
  -------------------------------------------------------------------------------
  -- Get the receipt information
  CURSOR c_get_rcpt_details(cp_cash_rcpt_id IN AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE) IS
  SELECT
         RCT.CHECK_NUMBER RECEIPT_NUMBER
       , RCT.RECEIPT_TYPE
       , RCT.AMOUNT
       , NULL ID
       ,RCT.CURRENCY_CODE
  FROM
        OKL_TRX_CSH_RECEIPT_V RCT
--      , OKL_EXT_CSH_RCPTS_V   XCR
  WHERE
--         XCR.RCT_ID = RCT.ID
--    AND XCR.ICR_ID = cp_cash_rcpt_id;
	RCT.CASH_RECEIPT_ID = cp_cash_rcpt_id;
  -------------------------------------------------------------------------------

  -- check receipt applic
  CURSOR   c_ver_dup_applic( cp_customer_trx_id IN NUMBER
                            ,cp_cash_receipt_id IN NUMBER) IS
  SELECT   NVL(RECEIVABLE_APPLICATION_ID,0)
  FROM     AR_RECEIVABLE_APPLICATIONS_ALL
  WHERE    APPLIED_CUSTOMER_TRX_ID = cp_customer_trx_id
  AND      CASH_RECEIPT_ID = cp_cash_receipt_id
  AND      STATUS = 'APP'
  ORDER BY CREATION_DATE desc;

  -------------------------------------------------------------------------------
  -- Gets the Invoice details for the stream
  CURSOR c_get_rec_inv_dtls( cp_stream_id IN OKL_CNSLD_AR_STRMS_V.ID%TYPE ) IS
  SELECT CNSLD.RECEIVABLES_INVOICE_ID
  FROM   OKL_CNSLD_AR_STRMS_V CNSLD
  WHERE  CNSLD.ID = cp_stream_id;
  -------------------------------------------------------------------------------

  -- verify receipt applied amount
  CURSOR   c_ver_app_amt(cp_csh_rcpt_id IN NUMBER) IS
  SELECT   NVL(SUM(AMOUNT_APPLIED),0)
  FROM     AR_RECEIVABLE_APPLICATIONS_ALL
  WHERE    STATUS = 'APP'
  AND      CASH_RECEIPT_ID = cp_csh_rcpt_id;
  -------------------------------------------------------------------------------

BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRMRHB.pls call MAN_RECEIPT_UNAPPLY');
    END IF;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name
      , p_pkg_name      => G_PKG_NAME
      , p_init_msg_list => p_init_msg_list
      , l_api_version   => l_api_version
      , p_api_version   => p_api_version
      , p_api_type      => G_API_TYPE
      , x_return_status => x_return_status);
    -- check if activity started successfully
    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    lp_xcav_tbl := p_xcav_tbl;

    l_record_count := lp_xcav_tbl.COUNT;

    -- Obtain the receipt details
    OPEN c_get_rcpt_details(l_cash_receipt_id);
    FETCH c_get_rcpt_details INTO  l_receipt_number
                                  , l_receipt_type
                                  , l_receipt_amount
                                  , l_xcr_id
                                  , l_receipt_currency;
    CLOSE c_get_rcpt_details;

    i := lp_xcav_tbl.FIRST;
    LOOP

       l_trans_currency_code := lp_xcav_tbl(i).invoice_currency_code;
       OPEN c_get_rec_inv_dtls(lp_xcav_tbl(i).lsm_id);
       FETCH c_get_rec_inv_dtls INTO l_customer_trx_id;
       CLOSE c_get_rec_inv_dtls;

       ----------------------------------------------------------
       -- Initialization of Cash appln Record p_xcav_rec begin
       ----------------------------------------------------------
          IF l_receipt_currency = l_trans_currency_code THEN
            l_applied_amount := lp_xcav_tbl(i).amount_applied ;
            l_applied_amount_from := NULL;
          ELSE
            l_applied_amount := lp_xcav_tbl(i).amount_applied;
            -- Convert receipt currency to invoice currency if different
            l_conversion_rate := okl_accounting_util.get_curr_con_rate
                                      ( l_receipt_currency
                                       ,l_trans_currency_code
                                       ,trunc(SYSDATE)
                                       ,'Corporate'
                                       );

             IF l_conversion_rate IN (0,-1) THEN
               -- Message Text: No exchange rate defined
               x_return_status := OKL_API.G_RET_STS_ERROR;
               OKL_API.set_message( p_app_name      => G_APP_NAME,
                                    p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             l_applied_amount_from := lp_xcav_tbl(i).amount_applied/l_conversion_rate;

             lp_xcav_tbl(i).amount_applied_from   := l_applied_amount_from * -1;
             lp_xcav_tbl(i).trans_to_receipt_rate := l_conversion_rate;
          END IF; -- end of check for receipt currency = transaction currency

       lp_xcav_tbl(i).amount_applied  := l_applied_amount * -1;
       lp_xcav_tbl(i).xcr_id_details  := l_xcr_id;
       lp_xcav_tbl(i).org_id          := l_org_id;

       OKL_XCA_PVT.insert_row( p_api_version   => l_api_version
                              ,p_init_msg_list => l_init_msg_list
                              ,x_return_status => l_return_status
                              ,x_msg_count     => l_msg_count
                              ,x_msg_data      => l_msg_data
                              ,p_xcav_rec      => lp_xcav_tbl(i)
                              ,x_xcav_rec      => lx_xcav_rec
                             );

       x_return_status := l_return_status;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

        --------------------------------------------------------
        -- AR processing begin
        --------------------------------------------------------

       OPEN  c_ver_dup_applic (l_customer_trx_id, l_cash_receipt_id);
       FETCH c_ver_dup_applic INTO l_receivable_application_id;
       CLOSE c_ver_dup_applic;

       AR_RECEIPT_API_PUB.Unapply( p_api_version               => l_api_version
                                  ,p_init_msg_list             => l_init_msg_list
                                  ,x_return_status             => l_return_status
                                  ,x_msg_count                 => l_msg_count
                                  ,x_msg_data                  => l_msg_data
                                  ,p_cash_receipt_id           => l_cash_receipt_id
                                  ,p_customer_trx_id           => l_customer_trx_id
                                  ,p_receivable_application_id => l_receivable_application_id
                                  ,p_reversal_gl_date          => null
                                 );

       x_return_status := l_return_status;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

          EXIT WHEN (i = lp_xcav_tbl.LAST);
          i := i + 1;
     END LOOP;

    -- Check if the receipt is of type ADVANCED
    IF l_receipt_type = 'ADV' THEN
      lp_xcrv_rec.id := l_xcr_id;
      OPEN c_ver_app_amt(l_cash_receipt_id);
      FETCH c_ver_app_amt INTO l_total_applied_amount;
      CLOSE c_ver_app_amt;
      IF(l_total_applied_amount = l_receipt_amount) THEN
        lp_xcrv_rec.fully_applied_flag := 'Y';
      ELSE
        lp_xcrv_rec.fully_applied_flag := 'N';
      END IF;

      -- Update the FULLY_APPLIED_FLAG colum for Advance receipts
      OKL_XCR_PUB.UPDATE_EXT_CSH_TXNS( p_api_version   => l_api_version
                                      ,p_init_msg_list => l_init_msg_list
                                      ,x_return_status => l_return_status
                                      ,x_msg_count     => l_msg_count
                                      ,x_msg_data      => l_msg_data
                                      ,p_xcrv_rec      => lp_xcrv_rec
                                      ,x_xcrv_rec      => lx_xcrv_rec
                                      );

      x_return_status := l_return_status;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF; -- end of check for Advance receipt

    -- commit the savepoint
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRMRHB.pls call MAN_RECEIPT_UNAPPLY');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

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
      Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

END man_receipt_unapply;

END OKL_BPD_MAN_RCT_HANDLE_PVT;

/
