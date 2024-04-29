--------------------------------------------------------
--  DDL for Package Body OKL_CASH_RECEIPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CASH_RECEIPT" AS
/* $Header: OKLRRTCB.pls 120.20 2007/08/03 17:17:14 nikshah noship $ */

---------------------------------------------------------------------------
-- PROCEDURE cash_receipt
---------------------------------------------------------------------------

 PROCEDURE CASH_RECEIPT (p_api_version      IN  NUMBER   := 1.0
                        ,p_init_msg_list    IN  VARCHAR2 := OKC_API.G_FALSE
                        ,x_return_status    OUT NOCOPY  VARCHAR2
                        ,x_msg_count        OUT NOCOPY  NUMBER
                        ,x_msg_data         OUT NOCOPY  VARCHAR2
                        ,p_over_pay         IN  VARCHAR2
                        ,p_conc_proc        IN  VARCHAR2
                        ,p_xcrv_rec         IN  xcrv_rec_type
                        ,p_xcav_tbl         IN  xcav_tbl_type
                        ,x_cash_receipt_id  OUT NOCOPY NUMBER
                        ) IS

------------------------------
-- DECLARE Local variables
------------------------------

i                           NUMBER      DEFAULT 1;
l_record_count              NUMBER      DEFAULT NULL;

l_api_version			    NUMBER      := 1.0;
l_init_msg_list		        VARCHAR2(1);

l_return_status		        VARCHAR2(1);
l_msg_count			        NUMBER;
l_msg_data			        VARCHAR2(2000);

l_cash_receipt_id           AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL;
l_func_amount_applied_tot   NUMBER  := 0;
l_rcpt_amount_applied_tot   NUMBER  := 0;
l_amount_unapplied          NUMBER  := 0;

l_applied_amount            AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL;
l_applied_amount_from       AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED_FROM%TYPE DEFAULT NULL;

l_exchange_rate             AR_CASH_RECEIPTS_ALL.EXCHANGE_RATE%TYPE DEFAULT NULL;
l_exchange_rate_type        AR_CASH_RECEIPTS_ALL.EXCHANGE_RATE_TYPE%TYPE DEFAULT NULL;
l_exchange_rate_date        AR_CASH_RECEIPTS_ALL.EXCHANGE_DATE%TYPE DEFAULT NULL;

l_over_pay                  VARCHAR2(1) DEFAULT NULL;
l_conc_proc                 VARCHAR2(2) DEFAULT p_conc_proc;
l_counter                   NUMBER;

l_irm_id                    OKL_TRX_CSH_RECEIPT_V.IRM_ID%TYPE DEFAULT NULL;
l_ile_id                    OKL_TRX_CSH_RECEIPT_V.ILE_ID%TYPE DEFAULT NULL;
l_iba_id                    OKL_TRX_CSH_RECEIPT_V.IBA_ID%TYPE DEFAULT NULL;
l_orig_rcpt_amount          OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL;
l_currency_code             OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;
l_functional_currency       OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;

ar_invoice_num              RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE DEFAULT NULL;
ar_invoice_date             OKL_BPD_LEASING_PAYMENT_TRX_V.INVOICE_DATE%TYPE DEFAULT NULL;

l_inv_gl_date               OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
l_rec_gl_date               OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
l_apply_date                OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;

l_customer_trx_id           AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_TRX_ID%TYPE DEFAULT NULL;
l_customer_site_use_id      AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_SITE_USE_ID%TYPE DEFAULT NULL;

l_api_name                  CONSTANT VARCHAR2(30) := 'Cash_Receipt';

 -- BEGIN abindal bug 4316610 --
   l_applic_month              VARCHAR2(10);
   l_gl_month                  VARCHAR2(10);
 -- END abindal bug 4316610 --

------------------------------
-- DECLARE Record/Table Types
------------------------------

l_xcrv_rec                  Okl_Extrn_Pvt.xcrv_rec_type;
l_xcav_tbl                  Okl_Extrn_Pvt.xcav_tbl_type;

------------------------------
-- DECLARE Cursors
------------------------------

     -- get receipt info
     CURSOR c_get_rcpt_info (cp_rct_id IN NUMBER) IS
     SELECT a.irm_id
           ,a.iba_id
           ,a.ile_id
           ,a.amount                      -- rcpt currency
           ,a.currency_code
     FROM   okl_trx_csh_receipt_b a
     WHERE  a.id = cp_rct_id;

----------

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
   ----------


BEGIN

    l_over_pay := p_over_pay;
    l_xcrv_rec := p_xcrv_rec;
    l_xcav_tbl := p_xcav_tbl;

    IF l_conc_proc = 'YC' THEN
        l_init_msg_list := fnd_api.g_false;
    ELSE
        l_init_msg_list := fnd_api.g_true;
    END IF;

    l_functional_currency := okl_accounting_util.get_func_curr_code;

    -- BEGIN abindal bug 4356410 --
    OPEN c_get_gl_date(p_xcrv_rec.receipt_date);
    -- END abindal bug 4356410 --
    FETCH c_get_gl_date INTO l_rec_gl_date, l_counter;

    IF c_get_gl_date%NOTFOUND THEN
        CLOSE c_get_gl_date;

        OKC_API.set_message( p_app_name     => G_APP_NAME,
                             p_msg_name     =>'OKL_BPD_GL_PERIOD_ERROR',
                             p_token1       => 'TRX_DATE',
                             p_token1_value => TRUNC(SYSDATE));

        l_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE c_get_gl_date;

    IF l_xcrv_rec.remittance_amount = 0 OR
       l_xcrv_rec.remittance_amount IS NULL THEN
            x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- get IRM_ID, ILE_ID ...

    OPEN c_get_rcpt_info(l_xcrv_rec.rct_id);
    FETCH c_get_rcpt_info INTO l_irm_id
                              ,l_iba_id
                              ,l_ile_id
                              ,l_orig_rcpt_amount   -- receipt currency
                              ,l_currency_code;
    CLOSE c_get_rcpt_info;

    IF l_functional_currency <> l_currency_code THEN   -- dealing with currency ...
--  IF l_currency_code <> l_xcrv_rec.currency_code THEN -- bv

        l_exchange_rate_type := l_xcrv_rec.exchange_rate_type;

        IF l_exchange_rate_type IN ('Corporate', 'Spot') THEN
            l_exchange_rate_date := l_xcrv_rec.exchange_rate_date;
            l_exchange_rate      := NULL;
        ELSE
            l_exchange_rate_date := NULL;
            l_exchange_rate      := l_xcrv_rec.attribute1;
        END IF;

    END IF;

    l_record_count := l_xcav_tbl.COUNT;

    IF l_record_count > 0 THEN
        i := l_xcav_tbl.FIRST;
        LOOP        -- in functional currency ...
            l_func_amount_applied_tot := l_func_amount_applied_tot + l_xcav_tbl(i).AMOUNT_APPLIED;
            IF l_currency_code <> l_xcrv_rec.currency_code THEN   -- dealing with currency ...
                l_rcpt_amount_applied_tot := l_rcpt_amount_applied_tot + l_xcav_tbl(i).AMOUNT_APPLIED_FROM;
            END IF;
            EXIT WHEN (i = l_xcav_tbl.LAST);
    	    i := i + 1;
        END LOOP;
    END IF;

    IF l_record_count >= 0 THEN
        i := l_xcav_tbl.FIRST;

        IF l_record_count > 0 THEN

            SELECT receivables_invoice_id INTO l_customer_trx_id
            FROM   okl_cnsld_ar_strms_v
            WHERE  okl_cnsld_ar_strms_v.id = l_xcav_tbl(i).lsm_id;

            SELECT bill_to_site_use_id INTO l_customer_site_use_id
            FROM   ra_customer_trx_all
            WHERE  customer_trx_id = l_customer_trx_id;

            l_customer_trx_id := NULL;

        END IF;

        ----------------------------------------------------------------
        -- when dealing with cross currencies, daily exchange rates must
        -- be defined.
        ----------------------------------------------------------------

        Ar_receipt_api_pub.Create_cash( p_api_version             => l_api_version
                                       ,p_init_msg_list           => l_init_msg_list
                                       ,x_return_status           => l_return_status
                                       ,x_msg_count               => l_msg_count
                                       ,x_msg_data                => l_msg_data
                                       ,p_receipt_number          => l_xcrv_rec.check_number
                                       ,p_receipt_date            => l_xcrv_rec.receipt_date
                                       ,p_customer_site_use_id    => l_customer_site_use_id
                                       ,p_customer_number         => l_xcrv_rec.customer_number
                                       ,p_amount                  => l_orig_rcpt_amount             -- in receipt currency ...
                                       ,p_currency_code           => l_currency_code

                                       ,p_exchange_rate_type      => l_exchange_rate_type           -- daily exchge rate required ...
                                       ,p_exchange_rate           => l_exchange_rate                -- daily exchge rate required ...
                                       ,p_exchange_rate_date      => l_exchange_rate_date           -- daily exchge rate required ...

                                       ,p_gl_date                 => l_rec_gl_date
                                       ,p_receipt_method_id       => l_irm_id
                                       ,p_cr_id                   => l_cash_receipt_id  -- OUT
                                       ,p_org_id => mo_global.get_current_org_id()
                                       );

        x_return_status := l_return_status;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;

    IF l_record_count > 0  THEN   -- LOOP APPLY

            i := l_xcav_tbl.FIRST;
            LOOP

                ar_invoice_num := NULL;

                SELECT receivables_invoice_id INTO l_customer_trx_id
                FROM   okl_cnsld_ar_strms_v
                WHERE  okl_cnsld_ar_strms_v.id = l_xcav_tbl(i).lsm_id;

                /* Modified select statement to address bug 4510824 */
                SELECT max(trx_date), invoice_number INTO l_xcav_tbl(i).trx_date, ar_invoice_num
                FROM   okl_xtl_csh_apps_v
                WHERE  lsm_id = l_xcav_tbl(i).lsm_id
                AND    rca_id = l_xcav_tbl(i).rca_id
				GROUP BY invoice_number;

                /* added to address bug 4208639 */
                SELECT invoice_date INTO ar_invoice_date
                FROM   OKL_BPD_LEASING_PAYMENT_TRX_V
                WHERE  receivables_invoice_number = ar_invoice_num;

                IF l_currency_code = l_xcrv_rec.currency_code THEN
                    l_applied_amount := l_xcav_tbl(i).amount_applied;
                    l_applied_amount_from := NULL;
                ELSE
                    l_applied_amount := l_xcav_tbl(i).amount_applied;
                    l_applied_amount_from := l_xcav_tbl(i).amount_applied_from;
                END IF;

                -- bug 4208639 start
                IF l_xcrv_rec.receipt_date <= SYSDATE THEN
                    l_apply_date := TRUNC(SYSDATE);
                END IF;

                IF l_xcrv_rec.receipt_date > SYSDATE THEN
                    l_apply_date := l_xcrv_rec.receipt_date;
                END IF;

                IF ar_invoice_date > l_xcrv_rec.receipt_date THEN
                    IF ar_invoice_date > SYSDATE THEN
                        l_apply_date := ar_invoice_date;
                    END IF;
                END IF;
                -- bug 4208639 end

                OPEN c_get_gl_date(l_apply_date);
                FETCH c_get_gl_date INTO l_inv_gl_date, l_counter;

                IF c_get_gl_date%NOTFOUND THEN
                    CLOSE c_get_gl_date;
                    OKC_API.set_message( p_app_name    => G_APP_NAME,
                                             p_msg_name    =>'OKL_BPD_GL_PERIOD_ERROR',
                                             p_token1       => 'TRX_DATE',
                                             p_token1_value => TRUNC(l_xcav_tbl(i).trx_date));

                    l_return_status := OKC_API.G_RET_STS_ERROR;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
                CLOSE c_get_gl_date;

                IF l_applied_amount = 0 THEN
                    NULL;
                ELSE
                    Ar_receipt_api_pub.apply( p_api_version           => l_api_version
                                             ,p_init_msg_list         => l_init_msg_list
                                             ,x_return_status         => l_return_status
                                             ,x_msg_count             => l_msg_count
                                             ,x_msg_data              => l_msg_data
                                             ,p_customer_trx_id       => l_customer_trx_id
                                             ,p_amount_applied        => l_applied_amount       -- in func/rcpt currency.
                                             ,p_amount_applied_from   => l_applied_amount_from  -- in rcpt_currency
                                             ,p_apply_gl_date         => l_inv_gl_date
                                             ,p_apply_date            => l_apply_date
                                             ,p_cash_receipt_id       => l_cash_receipt_id
                                             ,p_org_id => mo_global.get_current_org_id()
                                            );

                    x_return_status := l_return_status;

                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                END IF;

                EXIT WHEN (i = l_xcav_tbl.LAST);

    	        i := i + 1;

            END LOOP;

    END IF;

    IF l_func_amount_applied_tot < l_orig_rcpt_amount THEN

        IF l_over_pay = 'O' THEN        -- APPLY TO ON ACCOUNT IF SELECTED.

              Ar_receipt_api_pub.Apply_on_account( p_api_version      => l_api_version
                                                  ,p_init_msg_list    => l_init_msg_list
                                                  ,x_return_status    => l_return_status
                                                  ,x_msg_count        => l_msg_count
                                                  ,x_msg_data         => l_msg_data
                                                  ,p_cash_receipt_id  => l_cash_receipt_id
                                               -- ,p_amount_applied   => l_amount_unapplied -- not required.  we will just write off remaining rcpt.
                                                  ,p_apply_date       => l_xcrv_rec.receipt_date
                                                  ,p_apply_gl_date    => l_rec_gl_date
                                                  ,p_org_id => mo_global.get_current_org_id()
                                                 );

              x_return_status := l_return_status;
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

        END IF; -- ELSE LEAVE CASH AS UNAPPLIED.

    END IF;

    x_cash_receipt_id := l_cash_receipt_id;
    x_return_status   := l_return_status;

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
    NULL;
/*  --  fix bug number 2439881
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

*/
 END CASH_RECEIPT;

PROCEDURE CREATE_RECEIPT (p_api_version    IN  NUMBER   := 1.0
                        ,p_init_msg_list    IN  VARCHAR2 := OKC_API.G_FALSE
                        ,x_return_status    OUT NOCOPY  VARCHAR2
                        ,x_msg_count        OUT NOCOPY  NUMBER
                        ,x_msg_data         OUT NOCOPY  VARCHAR2
                        ,p_rcpt_rec         IN  OKL_CASH_APPL_RULES.rcpt_rec_type
                        ,x_cash_receipt_id  OUT NOCOPY NUMBER
                        ) IS

------------------------------
-- DECLARE Local variables
------------------------------

l_api_version                       NUMBER      := 1.0;
l_init_msg_list                 VARCHAR2(1);
l_return_status                 VARCHAR2(1);
l_msg_count                             NUMBER;
l_msg_data                              VARCHAR2(2000);

l_cash_receipt_id           AR_CASH_RECEIPTS.CASH_RECEIPT_ID%TYPE DEFAULT NULL;

l_exchange_rate             AR_CASH_RECEIPTS.EXCHANGE_RATE%TYPE := p_rcpt_rec.exchange_rate;
l_exchange_rate_type        AR_CASH_RECEIPTS.EXCHANGE_RATE_TYPE%TYPE := p_rcpt_rec.exchange_rate_type;
l_exchange_rate_date        AR_CASH_RECEIPTS.EXCHANGE_DATE%TYPE := p_rcpt_rec.exchange_date;
l_functional_currency       AR_CASH_RECEIPTS.CURRENCY_CODE%TYPE DEFAULT NULL;

l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_RECEIPT';

 -- BEGIN abindal bug 4316610 --
   l_applic_month              VARCHAR2(10);
   l_gl_month                  VARCHAR2(10);
 -- END abindal bug 4316610 --

------------------------------
-- DECLARE Record/Table Types
------------------------------

l_rcpt_rec                  OKL_CASH_APPL_RULES.rcpt_rec_type;
l_attribute_rec             AR_RECEIPT_API_PUB.attribute_rec_type;


BEGIN
SAVEPOINT create_receipt;
    l_rcpt_rec := p_rcpt_rec;
    l_attribute_rec.attribute_category := l_rcpt_rec.dff_attribute_category;
    l_attribute_rec.attribute1 := l_rcpt_rec.dff_attribute1;
    l_attribute_rec.attribute2 := l_rcpt_rec.dff_attribute2;
    l_attribute_rec.attribute3 := l_rcpt_rec.dff_attribute3;
    l_attribute_rec.attribute4 := l_rcpt_rec.dff_attribute4;
    l_attribute_rec.attribute5 := l_rcpt_rec.dff_attribute5;
    l_attribute_rec.attribute6 := l_rcpt_rec.dff_attribute6;
    l_attribute_rec.attribute7 := l_rcpt_rec.dff_attribute7;
    l_attribute_rec.attribute8 := l_rcpt_rec.dff_attribute8;
        l_attribute_rec.attribute9 := l_rcpt_rec.dff_attribute9;
        l_attribute_rec.attribute10 := l_rcpt_rec.dff_attribute10;
        l_attribute_rec.attribute11 := l_rcpt_rec.dff_attribute11;
        l_attribute_rec.attribute12 := l_rcpt_rec.dff_attribute12;
        l_attribute_rec.attribute13 := l_rcpt_rec.dff_attribute13;
        l_attribute_rec.attribute14 := l_rcpt_rec.dff_attribute14;
        l_attribute_rec.attribute15 := l_rcpt_rec.dff_attribute15;


    l_functional_currency := okl_accounting_util.get_func_curr_code;
    IF l_functional_currency <> l_rcpt_rec.currency_code THEN

        l_exchange_rate_type := l_rcpt_rec.exchange_rate_type;

        IF l_exchange_rate_type IN ('Corporate', 'Spot') THEN
            l_exchange_rate_date := l_rcpt_rec.exchange_date;
            l_exchange_rate      := NULL;
        ELSE
            l_exchange_rate_date := NULL;
            l_exchange_rate      := l_rcpt_rec.exchange_rate;
        END IF;

    END IF;

    IF l_exchange_rate_type = 'NONE' THEN
      l_exchange_rate_type := NULL;
    END IF;

       Ar_receipt_api_pub.Create_cash( p_api_version             => l_api_version
                                       ,p_init_msg_list           => l_init_msg_list
                                       ,x_return_status           => l_return_status
                                       ,x_msg_count               => l_msg_count
                                       ,x_msg_data                => l_msg_data
                                       ,p_receipt_number          => l_rcpt_rec.RECEIPT_NUMBER
                                       ,p_receipt_date            => l_rcpt_rec.receipt_date
                                       ,p_customer_number         => l_rcpt_rec.customer_number
                                       ,p_amount                  => l_rcpt_rec.AMOUNT  -- in receipt currency ...
                                       ,p_currency_code           => l_rcpt_rec.CURRENCY_CODE
                                       ,p_exchange_rate_type      => l_exchange_rate_type           -- daily exchge rate required ...
                                       ,p_exchange_rate           => l_exchange_rate                -- daily exchge rate required ...
                                       ,p_exchange_rate_date      => l_exchange_rate_date           -- daily exchge rate required ...
                                       ,p_gl_date                 => l_rcpt_rec.GL_DATE
                                       ,p_receipt_method_id       => l_rcpt_rec.RECEIPT_METHOD_ID
                                       ,p_attribute_rec           => l_attribute_rec
                                       ,p_remittance_bank_account_id => l_rcpt_rec.REMITTANCE_BANK_ACCOUNT_ID
                                       ,p_remittance_bank_account_num => l_rcpt_rec.REMITTANCE_BANK_ACCOUNT_NUM
                                       ,p_remittance_bank_account_name => l_rcpt_rec.REMITTANCE_BANK_ACCOUNT_NAME
                                                                           ,p_payment_trxn_extension_id => l_rcpt_rec.PAYMENT_TRX_EXTENSION_ID
                                       ,p_cr_id                   => l_cash_receipt_id  -- OUT
                                       ,p_org_id => l_rcpt_rec.org_id
                                       );
        x_return_status := l_return_status;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    x_cash_receipt_id := l_cash_receipt_id;
    x_return_status   := l_return_status;
EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      ROLLBACK TO create_receipt;
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO create_receipt;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

 END CREATE_RECEIPT;


 PROCEDURE PAYMENT_RECEIPT (p_api_version      IN  NUMBER   := 1.0
                           ,p_init_msg_list    IN  VARCHAR2 := OKC_API.G_FALSE
                           ,x_return_status    OUT NOCOPY  VARCHAR2
                           ,x_msg_count        OUT NOCOPY  NUMBER
                           ,x_msg_data         OUT NOCOPY  VARCHAR2
                           ,p_over_pay         IN  VARCHAR2
                           ,p_conc_proc        IN  VARCHAR2
                           ,p_xcrv_rec         IN  xcrv_rec_type
                           ,p_xcav_tbl         IN  xcav_tbl_type
                           ,x_cash_receipt_id  OUT NOCOPY NUMBER
                          ) IS

------------------------------
-- DECLARE Local variables
------------------------------

i                           NUMBER      DEFAULT 1;
l_record_count              NUMBER      DEFAULT NULL;

l_api_version			    NUMBER      := 1.0;
l_init_msg_list		        VARCHAR2(1);

l_return_status		        VARCHAR2(1);
l_msg_count			        NUMBER;
l_msg_data			        VARCHAR2(2000);

l_cash_receipt_id           AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL;
l_func_amount_applied_tot   NUMBER  := 0;
l_rcpt_amount_applied_tot   NUMBER  := 0;
l_amount_unapplied          NUMBER  := 0;

l_applied_amount            AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL;
l_applied_amount_from       AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED_FROM%TYPE DEFAULT NULL;

l_exchange_rate             AR_CASH_RECEIPTS_ALL.EXCHANGE_RATE%TYPE DEFAULT NULL;
l_exchange_rate_type        AR_CASH_RECEIPTS_ALL.EXCHANGE_RATE_TYPE%TYPE DEFAULT NULL;
l_exchange_rate_date        AR_CASH_RECEIPTS_ALL.EXCHANGE_DATE%TYPE DEFAULT NULL;

l_over_pay                  VARCHAR2(1) DEFAULT NULL;
l_conc_proc                 VARCHAR2(2) DEFAULT p_conc_proc;
l_counter                   NUMBER;

l_irm_id                    OKL_TRX_CSH_RECEIPT_V.IRM_ID%TYPE DEFAULT NULL;
l_ile_id                    OKL_TRX_CSH_RECEIPT_V.ILE_ID%TYPE DEFAULT NULL;
l_iba_id                    OKL_TRX_CSH_RECEIPT_V.IBA_ID%TYPE DEFAULT NULL;
l_orig_rcpt_amount          OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL;
l_currency_code             OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;
l_functional_currency       OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;

l_gl_date                   OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
l_apply_date                OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;

l_customer_trx_id           AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_TRX_ID%TYPE DEFAULT NULL;
l_customer_site_use_id      AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_SITE_USE_ID%TYPE DEFAULT NULL;

l_api_name                  CONSTANT VARCHAR2(30) := 'Cash_Receipt';

-- BEGIN abindal bug 4316610 --
 l_applic_month              VARCHAR2(10);
 l_gl_month                  VARCHAR2(10);
 -- END abindal bug 4316610 --


------------------------------
-- DECLARE Record/Table Types
------------------------------

l_xcrv_rec                  Okl_Extrn_Pvt.xcrv_rec_type;
l_xcav_tbl                  Okl_Extrn_Pvt.xcav_tbl_type;

------------------------------
-- DECLARE Cursors
------------------------------

     -- get receipt info
     CURSOR c_get_rcpt_info (cp_rct_id IN NUMBER) IS
     SELECT a.irm_id
           ,a.iba_id
           ,a.ile_id
           ,a.amount                      -- rcpt currency
           ,a.currency_code
     FROM   okl_trx_csh_receipt_b a
     WHERE  a.id = cp_rct_id;

----------

    --get gl date from open accounting period
     CURSOR c_get_gl_date(cp_date IN DATE) IS SELECT * from (
     SELECT end_date gl_date, 1 Counter
     FROM gl_period_statuses
     WHERE application_id = 222
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
     SELECT MIN(end_date) gl_date, 3 Counter
     FROM gl_period_statuses
     WHERE application_id = 222
     AND ledger_id = okl_accounting_util.get_set_of_books_id
     AND closing_status IN ('F','O')
     AND start_date >= trunc(cp_date)
     AND adjustment_period_flag = 'N'
     )
     where gl_date is not null
     order by counter;

----------
    -- BEGIN abindal bug 4316610 --
      --get gl date from open accounting period -- min date
      CURSOR c_get_gl_date_start(cp_date IN DATE) IS SELECT * from (
      SELECT start_date gl_date, 1 Counter
      FROM gl_period_statuses
      WHERE application_id = 222
      AND ledger_id = okl_accounting_util.get_set_of_books_id
      AND trunc(cp_date) between start_date and end_date
      AND adjustment_period_flag = 'N'
      UNION
      SELECT MAX(start_date) gl_date, 2 Counter
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
    -- END abindal bug 4316610 --
 ----------


BEGIN

    l_over_pay := p_over_pay;
    l_xcrv_rec := p_xcrv_rec;
    l_xcav_tbl := p_xcav_tbl;


    IF l_conc_proc = 'YC' THEN
        l_init_msg_list := fnd_api.g_false;
    ELSE
        l_init_msg_list := fnd_api.g_true;
    END IF;

    l_functional_currency := okl_accounting_util.get_func_curr_code;

    OPEN c_get_gl_date(SYSDATE);
    FETCH c_get_gl_date INTO l_gl_date, l_counter;

    IF c_get_gl_date%NOTFOUND THEN
        CLOSE c_get_gl_date;

        OKC_API.set_message( p_app_name     => G_APP_NAME,
                             p_msg_name     =>'OKL_BPD_GL_PERIOD_ERROR',
                             p_token1       => 'TRX_DATE',
                             p_token1_value => TRUNC(SYSDATE));

        l_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE c_get_gl_date;

    -- BEGIN abindal bug 4316610 --

      SELECT TO_CHAR(sysdate, 'MONTH') INTO l_applic_month
      FROM DUAL;

      SELECT TO_CHAR(l_gl_date, 'MONTH') INTO l_gl_month
      FROM DUAL;

      IF l_gl_month = l_applic_month THEN
          l_gl_date := TRUNC(SYSDATE);
      END IF;

      IF TRUNC(l_gl_date) > TRUNC(SYSDATE) THEN
          OPEN c_get_gl_date_start(SYSDATE);  -- min
          FETCH c_get_gl_date_start INTO l_gl_date, l_counter;

          IF c_get_gl_date_start%NOTFOUND THEN
              CLOSE c_get_gl_date_start;

              OKC_API.set_message( p_app_name     => G_APP_NAME,
                                   p_msg_name     =>'OKL_BPD_GL_PERIOD_ERROR',
                                   p_token1       => 'TRX_DATE',
                                   p_token1_value => TRUNC(SYSDATE));

              l_return_status := OKC_API.G_RET_STS_ERROR;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
          CLOSE c_get_gl_date_start;
      END IF;

    -- END abindal bug 4316610 --



    IF l_xcrv_rec.remittance_amount = 0 OR
       l_xcrv_rec.remittance_amount IS NULL THEN
            x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- get IRM_ID, ILE_ID ...

    OPEN c_get_rcpt_info(l_xcrv_rec.rct_id);
    FETCH c_get_rcpt_info INTO l_irm_id
                              ,l_iba_id
                              ,l_ile_id
                              ,l_orig_rcpt_amount   -- receipt currency
                              ,l_currency_code;
    CLOSE c_get_rcpt_info;

    IF l_functional_currency <> l_currency_code THEN   -- dealing with currency ...
--  IF l_currency_code <> l_xcrv_rec.currency_code THEN -- bv

        l_exchange_rate_type := l_xcrv_rec.exchange_rate_type;

        IF l_exchange_rate_type IN ('Corporate', 'Spot') THEN
            l_exchange_rate_date := l_xcrv_rec.exchange_rate_date;
            l_exchange_rate      := NULL;
        ELSE
            l_exchange_rate_date := NULL;
            l_exchange_rate      := l_xcrv_rec.attribute1;
        END IF;

    END IF;

    l_record_count := l_xcav_tbl.COUNT;

    IF l_record_count > 0 THEN
        i := l_xcav_tbl.FIRST;
        LOOP        -- in functional currency ...
            l_func_amount_applied_tot := l_func_amount_applied_tot + l_xcav_tbl(i).AMOUNT_APPLIED;
            IF l_currency_code <> l_xcrv_rec.currency_code THEN   -- dealing with currency ...
                l_rcpt_amount_applied_tot := l_rcpt_amount_applied_tot + l_xcav_tbl(i).AMOUNT_APPLIED_FROM;
            END IF;
            EXIT WHEN (i = l_xcav_tbl.LAST);
    	    i := i + 1;
        END LOOP;
    END IF;

    IF l_record_count > 0 THEN
        i := l_xcav_tbl.FIRST;

        ----------------------------------------------------------------

        SELECT receivables_invoice_id INTO l_customer_trx_id
        FROM   okl_cnsld_ar_strms_v
        WHERE  okl_cnsld_ar_strms_v.id = l_xcav_tbl(i).lsm_id;

        SELECT bill_to_site_use_id INTO l_customer_site_use_id
        FROM   ra_customer_trx_all
        WHERE  customer_trx_id = l_customer_trx_id;

   --   l_customer_trx_id := NULL;

        SELECT trx_date INTO l_xcav_tbl(i).trx_date
        FROM   okl_xtl_csh_apps_v
        WHERE  lsm_id = l_xcav_tbl(i).lsm_id
        AND    rca_id = l_xcav_tbl(i).rca_id;

        IF l_currency_code = l_xcrv_rec.currency_code THEN
            l_applied_amount := l_xcav_tbl(i).amount_applied;
            l_applied_amount_from := NULL;
        ELSE
            l_applied_amount := l_xcav_tbl(i).amount_applied;
            l_applied_amount_from := l_xcav_tbl(i).amount_applied_from;
        END IF;

        IF l_xcav_tbl(i).trx_date > l_xcrv_rec.receipt_date THEN
            l_apply_date := l_xcav_tbl(i).trx_date;
            --l_gl_date := l_xcav_tbl(i).trx_date;
            OPEN c_get_gl_date(l_xcav_tbl(i).trx_date);
            FETCH c_get_gl_date INTO l_gl_date, l_counter;

            IF c_get_gl_date%NOTFOUND THEN
                CLOSE c_get_gl_date;

                OKC_API.set_message( p_app_name    => G_APP_NAME,
                                     p_msg_name    =>'OKL_BPD_GL_PERIOD_ERROR',
                                     p_token1       => 'TRX_DATE',
                                     p_token1_value => TRUNC(l_xcav_tbl(i).trx_date));

                l_return_status := OKC_API.G_RET_STS_ERROR;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
            CLOSE c_get_gl_date;
        ELSE
            l_apply_date := l_xcrv_rec.receipt_date;
            --l_gl_date := l_xcrv_rec.receipt_date;
        END IF;
            -------------------------------------------------------------

        Ar_receipt_api_pub.Create_and_apply( p_api_version              => l_api_version
                                            ,p_init_msg_list            => l_init_msg_list
                                            ,x_return_status            => l_return_status
                                            ,x_msg_count                => l_msg_count
                                            ,x_msg_data                 => l_msg_data
                                            ,p_customer_site_use_id     => l_customer_site_use_id
                                            ,p_customer_number          => l_xcrv_rec.customer_number
                                            ,p_customer_trx_id          => l_customer_trx_id
                                            ,p_amount                   => l_orig_rcpt_amount
                                            ,p_amount_applied           => l_applied_amount
                                            ,p_amount_applied_from      => l_applied_amount_from
                                            ,p_receipt_number           => NULL -- l_xcrv_rec.check_number
                                            ,p_currency_code            => l_currency_code
                                            ,p_exchange_rate_type       => l_exchange_rate_type
                                            ,p_exchange_rate            => l_exchange_rate
                                            ,p_exchange_rate_date       => l_exchange_rate_date
                                            ,p_receipt_date             => l_xcrv_rec.receipt_date
                                            ,p_gl_date                  => l_gl_date
                                            ,p_apply_date               => l_apply_date
                                            ,p_apply_gl_date            => l_gl_date
                                            ,p_receipt_method_id        => l_irm_id
                                            ,p_customer_bank_account_id => l_iba_id
                                            ,p_cr_id                    => l_cash_receipt_id    -- OUT
                                            ,p_org_id => mo_global.get_current_org_id()
                                           );


        x_return_status := l_return_status;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;

    -- Get the total amount applied.

    IF i <> l_xcav_tbl.LAST THEN

--    IF l_record_count > 1  THEN   -- LOOP APPLY

            i := i + 1;
            LOOP

                SELECT receivables_invoice_id INTO l_customer_trx_id
                FROM   okl_cnsld_ar_strms_v
                WHERE  okl_cnsld_ar_strms_v.id = l_xcav_tbl(i).lsm_id;

                SELECT trx_date INTO l_xcav_tbl(i).trx_date
                FROM   okl_xtl_csh_apps_v
                WHERE  lsm_id = l_xcav_tbl(i).lsm_id
                AND    rca_id = l_xcav_tbl(i).rca_id;

                IF l_currency_code = l_xcrv_rec.currency_code THEN
                    l_applied_amount := l_xcav_tbl(i).amount_applied;
                    l_applied_amount_from := NULL;
                ELSE
                    l_applied_amount := l_xcav_tbl(i).amount_applied;
                    l_applied_amount_from := l_xcav_tbl(i).amount_applied_from;
                END IF;

                IF l_xcav_tbl(i).trx_date > l_xcrv_rec.receipt_date THEN
                    l_apply_date := l_xcav_tbl(i).trx_date;
                    --l_gl_date := l_xcav_tbl(i).trx_date;
                    OPEN c_get_gl_date(l_xcav_tbl(i).trx_date);
                    FETCH c_get_gl_date INTO l_gl_date, l_counter;

                    IF c_get_gl_date%NOTFOUND THEN
                        CLOSE c_get_gl_date;
                        OKC_API.set_message( p_app_name    => G_APP_NAME,
                                             p_msg_name    =>'OKL_BPD_GL_PERIOD_ERROR',
                                             p_token1       => 'TRX_DATE',
                                             p_token1_value => TRUNC(l_xcav_tbl(i).trx_date));

                        l_return_status := OKC_API.G_RET_STS_ERROR;
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;
                    CLOSE c_get_gl_date;
                ELSE
                    l_apply_date := l_xcrv_rec.receipt_date;
                    --l_gl_date := l_xcrv_rec.receipt_date;
                END IF;


                IF l_applied_amount = 0 THEN
                    NULL;
                ELSE
                    Ar_receipt_api_pub.apply( p_api_version           => l_api_version
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
                                             ,p_org_id => mo_global.get_current_org_id()
                                            );

                    x_return_status := l_return_status;

                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                END IF;

                EXIT WHEN (i = l_xcav_tbl.LAST);

    	        i := i + 1;

            END LOOP;

    END IF;

    IF l_func_amount_applied_tot < l_orig_rcpt_amount THEN
/*
        IF l_currency_code = l_xcrv_rec.currency_code THEN      -- functional currency ...
            l_amount_unapplied := l_xcrv_rec.remittance_amount - l_func_amount_applied_tot;
        ELSE
            l_amount_unapplied := l_orig_rcpt_amount - l_rcpt_amount_applied_tot;       -- in receipt currency ...
        END IF;
*/
        IF l_over_pay = 'O' THEN        -- APPLY TO ON ACCOUNT IF SELECTED.

              Ar_receipt_api_pub.Apply_on_account( p_api_version      => l_api_version
                                                  ,p_init_msg_list    => l_init_msg_list
                                                  ,x_return_status    => l_return_status
                                                  ,x_msg_count        => l_msg_count
                                                  ,x_msg_data         => l_msg_data
                                                  ,p_cash_receipt_id  => l_cash_receipt_id
                                               -- ,p_amount_applied   => l_amount_unapplied -- not required.  we will just write off remaining rcpt.
                                                  ,p_apply_date       => l_xcrv_rec.receipt_date
                                                  ,p_apply_gl_date    => l_gl_date
                                                  ,p_org_id => mo_global.get_current_org_id()
                                                 );

              x_return_status := l_return_status;
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

        END IF; -- ELSE LEAVE CASH AS UNAPPLIED.

    END IF;

    x_cash_receipt_id := l_cash_receipt_id;
    x_return_status   := l_return_status;

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
    NULL;
/*  --  fix bug number 2439881
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

*/
    END PAYMENT_RECEIPT;

END OKL_CASH_RECEIPT;

/
