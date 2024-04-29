--------------------------------------------------------
--  DDL for Package Body OKL_BPD_ADVANCED_CASH_APP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BPD_ADVANCED_CASH_APP_PVT" AS
/* $Header: OKLRAVCB.pls 120.44.12010000.3 2009/01/30 04:16:31 nikshah ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.SETUP';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

PROCEDURE log_file(p_message IN VARCHAR2) IS
BEGIN
 FND_FILE.PUT_LINE (FND_FILE.LOG, p_message);
END;

PROCEDURE migrate_Applications     ( p_api_version       IN  NUMBER
                                    ,p_init_msg_list     IN  VARCHAR2 DEFAULT okl_api.G_FALSE
                                    ,x_return_status     OUT NOCOPY VARCHAR2
                                    ,x_msg_count         OUT NOCOPY NUMBER
                                    ,x_msg_data          OUT NOCOPY VARCHAR2
                                    ,p_receipt_id        IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                    ,p_appl_tbl          IN  okl_receipts_pvt.appl_tbl_type
                                    ,x_appl_tbl          OUT  NOCOPY okl_receipts_pvt.appl_tbl_type
                                  ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

  l_api_version                 NUMBER := 1.0;
  l_init_msg_list               VARCHAR2(1) := okl_api.g_false;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'migrate_Applications';

  l_cash_receipt_id             AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_receipt_id;
  i                             NUMBER;
  j                             NUMBER;
  k                             NUMBER;
  -------------------------------------------------------------------------------
  -- DECLARE Record/Table Types
  -------------------------------------------------------------------------------

  l_new_appl_tbl okl_receipts_pvt.appl_tbl_type;
  l_old_appl_tbl okl_receipts_pvt.appl_tbl_type;
  l_appl_tbl okl_receipts_pvt.appl_tbl_type;
  -------------------------------------------------------------------------------
  -- DEFINE CURSORS
  -------------------------------------------------------------------------------

    -- abindal start bug#4897580 --

 -------------------------------------------------------------------------------


  CURSOR   get_unapp_amt(cp_csh_rcpt_id IN NUMBER) IS
  SELECT   sum(amount_applied)
  FROM     AR_RECEIVABLE_APPLICATIONS_ALL
  WHERE    status = 'UNAPP'
  AND      display = 'Y'
  AND      cash_receipt_id = cp_csh_rcpt_id;

  CURSOR  get_existing_Applications(cp_csh_rcpt_id IN NUMBER) IS
  SELECT  customer_trx_id,
          customer_trx_line_id,
          (line_Applied + tax_applied) amount_applied
  FROM   okl_Receipt_Applications_uv
  WHERE  cash_receipt_id = cp_csh_rcpt_id;

BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_return_status := Okl_Api.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => p_init_msg_list,
            l_api_version   => l_api_version,
            p_api_version   => p_api_version,
            p_api_type      => '_PVT',
            x_return_status => l_return_status);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_new_appl_tbl  := p_appl_tbl;
    i := 0;
    log_file('l_new_appl_tbl.count = '||l_new_appl_tbl.count);
    IF l_new_appl_tbl.count > 0 THEN
      FOR l_app_rec IN get_existing_Applications(l_cash_receipt_id) LOOP
        l_old_appl_tbl(i).ar_inv_id := l_app_rec.customer_trx_id;
        l_old_appl_tbl(i).line_id := l_app_rec.customer_trx_line_id;
        l_old_appl_tbl(i).amount_to_apply := l_app_rec.amount_applied;
        i := i + 1;
      END LOOP;
      log_file('l_old_appl_tbl.count = '||l_old_appl_tbl.count);
      IF l_old_appl_tbl.count > 0 THEN
        -- merge l_old_appl_tbl and l_new_appl_tbl into l_appl_tbl
        k := 1;
        FOR i IN l_old_appl_tbl.FIRST..l_old_appl_tbl.LAST LOOP
          FOR j IN l_new_appl_tbl.FIRST..l_new_appl_tbl.LAST LOOP
            log_file(' l_new_appl_tbl(j).ar_inv_id = '|| l_new_appl_tbl(j).ar_inv_id);
            log_file(' l_old_appl_tbl(i).ar_inv_id = '|| l_old_appl_tbl(i).ar_inv_id);
            log_file(' l_new_appl_tbl(j).line_id = '|| l_new_appl_tbl(j).line_id);
            log_file(' l_old_appl_tbl(i).line_id = '|| l_old_appl_tbl(i).line_id);
            log_file(' l_new_appl_tbl(j).amount_to_apply = '|| l_new_appl_tbl(j).amount_to_apply);
            log_file(' l_old_appl_tbl(i).amount_to_apply = '|| l_old_appl_tbl(i).amount_to_apply);
            IF l_new_appl_tbl(j).ar_inv_id = l_old_appl_tbl(i).ar_inv_id THEN
              IF l_old_appl_tbl(i).line_id IS NULL OR l_new_appl_tbl(j).line_id IS NULL THEN
                l_appl_tbl(k) := l_new_appl_tbl(j);
                l_new_appl_tbl(j).original_applied_amount := 1;
                l_old_appl_tbl(i).original_applied_amount := 1;
                k := k +1;
              ELSIF l_new_appl_tbl(j).line_id = l_old_appl_tbl(i).line_id  THEN
                l_appl_tbl(k) := l_new_appl_tbl(j);
                l_appl_tbl(k).amount_to_apply := l_new_appl_tbl(j).amount_to_apply + l_old_appl_tbl(i).amount_to_apply;
                l_new_appl_tbl(j).original_applied_amount := 1;
                l_old_appl_tbl(i).original_applied_amount := 1;
                k := k + 1;
              END IF;
            END IF;
          END LOOP;
        END LOOP;
        FOR i IN l_old_appl_tbl.FIRST..l_old_appl_tbl.LAST LOOP
          log_file('l_old_appl_tbl(i).original_applied_amount = '||l_old_appl_tbl(i).original_applied_amount);
          IF nvl(l_old_appl_tbl(i).original_applied_amount,-1) <> 1 THEN
            l_appl_tbl(k) := l_old_appl_tbl(i);
            k := k + 1;
          END IF;
        END LOOP;
        FOR i IN l_new_appl_tbl.FIRST..l_new_appl_tbl.LAST LOOP
          log_file('l_new_appl_tbl(i).original_applied_amount = '||l_new_appl_tbl(i).original_applied_amount);
          IF nvl(l_new_appl_tbl(i).original_applied_amount,-1) <> 1 THEN
            l_appl_tbl(k) := l_new_appl_tbl(i);
            k := k + 1;
          END IF;
        END LOOP;
      ELSE
        l_appl_tbl := l_new_appl_tbl;
      END IF;
    END IF;

    x_appl_tbl := l_appl_tbl;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    Okl_Api.END_ACTIVITY ( x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data);


EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;


    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        Okl_Api.G_RET_STS_ERROR,
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
        x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

END migrate_Applications;
---------------------------------------------------------------------------
-- PROCEDURE process_advance_receipt
-- This routine handles receivables interaction.
---------------------------------------------------------------------------

PROCEDURE process_advance_receipt     (   p_api_version       IN  NUMBER
                                    ,p_init_msg_list     IN  VARCHAR2 DEFAULT okl_api.G_FALSE
                                    ,x_return_status     OUT NOCOPY VARCHAR2
                                    ,x_msg_count         OUT NOCOPY NUMBER
                                    ,x_msg_data          OUT NOCOPY VARCHAR2
                                    ,p_receipt_id        IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                    ,p_org_id            IN  NUMBER
                                    ,p_appl_tbl          IN  okl_receipts_pvt.appl_tbl_type
                                    ,x_remaining_amt     OUT NOCOPY NUMBER
                                  ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

  l_api_version                 NUMBER := 1.0;
  l_init_msg_list               VARCHAR2(1) := okl_api.g_false;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'process_advance_receipt';

  l_receipt_id                  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_receipt_id;
  l_unapp_amt                   NUMBER;
  l_org_id                      NUMBER := p_org_id;
  l_onacc_amt                   NUMBER;
  -------------------------------------------------------------------------------
  -- DECLARE Record/Table Types
  -------------------------------------------------------------------------------

  l_appl_tbl okl_receipts_pvt.appl_tbl_type;
  x_appl_tbl okl_receipts_pvt.appl_tbl_type;
  l_rcpt_rec okl_receipts_pvt.rcpt_rec_type;
  -------------------------------------------------------------------------------
  -- DEFINE CURSORS
  -------------------------------------------------------------------------------

    -- abindal start bug#4897580 --

 -------------------------------------------------------------------------------


  CURSOR   get_unapp_amt(cp_csh_rcpt_id IN NUMBER) IS
  SELECT   sum(nvl(amount_applied,0))
  FROM     AR_RECEIVABLE_APPLICATIONS_ALL
  WHERE    status = 'UNAPP'
  AND      cash_receipt_id = cp_csh_rcpt_id;

  CURSOR   get_onacc_amt(cp_csh_rcpt_id IN NUMBER) IS
  SELECT   sum(nvl(amount_applied,0))
  FROM     AR_RECEIVABLE_APPLICATIONS_ALL
  WHERE    status = 'ACC'
  AND      cash_receipt_id = cp_csh_rcpt_id;



BEGIN
    log_file('process_advance_receipt start');
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_return_status := Okl_Api.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => p_init_msg_list,
            l_api_version   => l_api_version,
            p_api_version   => p_api_version,
            p_api_type      => '_PVT',
            x_return_status => l_return_status);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_appl_tbl  := p_appl_tbl;

    OPEN get_onacc_amt(l_receipt_id);
    FETCH get_onacc_amt INTO l_onacc_amt;
    CLOSE get_onacc_amt;

    x_remaining_amt := l_onacc_amt;
    log_file('l_appl_tbl.count = '||l_appl_tbl.COUNT);
    IF l_appl_tbl.count > 0 THEN
        --migrate l_appl_tbl so that it has complete application details for given receipt
        log_file('calling migrate_applications');
        migrate_applications( p_api_version       => l_api_version
                           ,p_init_msg_list     => l_init_msg_list
                           ,x_return_status     => l_return_status
                           ,x_msg_count         => l_msg_count
                           ,x_msg_data          => l_msg_data
                           ,p_receipt_id        => l_receipt_id
                           ,p_appl_tbl          => l_appl_tbl
                           ,x_appl_tbl          => x_appl_tbl
                          );
        x_return_status := l_return_status;
        log_file('x_return_status = '||x_return_status);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_appl_tbl := x_appl_tbl;
        log_file('l_appl_tbl.count = '||l_appl_tbl.COUNT);
        -- unapply on account amount if any
        IF l_onacc_amt > 0 THEN
                Ar_receipt_api_pub.unapply_on_account(p_api_version        => l_api_version
                                                      ,p_init_msg_list      => l_init_msg_list
                                                      ,x_return_status      => l_return_status
                                                      ,x_msg_count          => l_msg_count
                                                      ,x_msg_data           => l_msg_data
                                                      ,p_cash_receipt_id    => l_receipt_id
                                                      ,p_reversal_gl_date   => null
                                                      );

                log_file('Ar_receipt_api_pub.unapply_on_account return status = '|| l_return_status);
                x_return_status := l_return_status;

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
        END IF;
        --apply the receipt
        l_rcpt_rec.cash_receipt_id := l_receipt_id;
        l_rcpt_rec.org_id := p_org_id;
        log_file('l_rcpt_rec.cash_receipt_id = '||l_rcpt_rec.cash_receipt_id);
        log_file('l_rcpt_rec.org_id = '||l_rcpt_rec.org_id);
        IF l_appl_tbl.COUNT > 0 THEN
          FOR ll IN l_appl_tbl.FIRST..l_appl_tbl.LAST LOOP
            log_file(' l_appl_tbl('||ll||').ar_inv_id = '|| l_appl_tbl(ll).ar_inv_id);
            log_file(' l_appl_tbl('||ll||').line_id = '|| l_appl_tbl(ll).line_id);
            log_file(' l_appl_tbl('||ll||').amount_to_apply = '|| l_appl_tbl(ll).amount_to_apply);
          END LOOP;
        END IF;
        okl_receipts_pvt.handle_receipt( p_api_version     => l_api_version
                                        ,p_init_msg_list   => l_init_msg_list
                                        ,x_return_status   => l_return_status
                                        ,x_msg_count       => l_msg_count
                                        ,x_msg_data        => l_msg_data
                                        ,p_rcpt_rec        => l_rcpt_rec
                                        ,p_appl_tbl        => l_appl_tbl
                                        ,x_cash_receipt_id => l_receipt_id
                                        );

        x_return_status := l_return_status;
        log_file('okl_receipts_pvt.handle_receipt return status = ' ||x_return_status);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        log_file('*** l_receipt_id = '||l_receipt_id);
        -- move unapplied amount to on account amount
        OPEN get_unapp_amt(l_receipt_id);
        FETCH get_unapp_amt INTO l_unapp_amt;
        CLOSE get_unapp_amt;
        log_file('l_unapp_amt = '||l_unapp_amt);
        x_remaining_amt := l_unapp_amt;
        IF l_unapp_amt > 0 THEN

                Ar_receipt_api_pub.Apply_on_account( p_api_version    => l_api_version
                                                  ,p_init_msg_list    => l_init_msg_list
                                                  ,x_return_status    => l_return_status
                                                  ,x_msg_count        => l_msg_count
                                                  ,x_msg_data         => l_msg_data
                                                  ,p_cash_receipt_id  => l_receipt_id
                                                  ,p_amount_applied   => l_unapp_amt
                                                --  ,p_apply_date       => l_receipt_date
                                                  ,p_org_id           => l_org_id
                                                 );

                x_return_status := l_return_status;

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
        END IF;

    END IF;

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    Okl_Api.END_ACTIVITY ( x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data);


EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;


    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        Okl_Api.G_RET_STS_ERROR,
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
        x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

END process_advance_receipt;


---------------------------------------------------------------------------
-- PROCEDURE advanced_cash_app
-- This routine called from advanced billing api.  Looks for advanced
-- receipts for newly booked contract
---------------------------------------------------------------------------

PROCEDURE advanced_cash_app (   p_api_version    IN  NUMBER
                               ,p_init_msg_list  IN  VARCHAR2 DEFAULT okl_api.G_FALSE
                               ,x_return_status  OUT NOCOPY VARCHAR2
                               ,x_msg_count      OUT NOCOPY NUMBER
                               ,x_msg_data       OUT NOCOPY VARCHAR2
                               ,p_contract_num   IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                               ,p_customer_num   IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL -- HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID indeed
                               ,p_receipt_num    IN  OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL
			       ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                              ) IS


---------------------------
-- DECLARE Local Variables
---------------------------

  l_api_version                 NUMBER := 1.0;
  l_init_msg_list               VARCHAR2(1) := okl_api.g_false;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'advanced_cash_app';

  l_contract_id                 OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL;
  l_contract_num                OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT p_contract_num;
  l_customer_id                 OKL_TRX_CSH_RECEIPT_V.ILE_ID%TYPE DEFAULT NULL;
--  l_customer_num                AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT p_customer_num;
--start:|           13-May-2008 cklee  --Fixed bug 7036445                           |
-- note: p_customer_num = HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID indeed
  l_customer_num                hz_cust_accounts.account_number%TYPE;
--end:|           13-May-2008 cklee  --Fixed bug 7036445                           |
  l_receipt_id                  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL;
  l_receipt_num                 OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT p_receipt_num;
  l_receipt_amount              OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL;
  l_cross_currency_allowed      VARCHAR2(1) DEFAULT p_cross_currency_allowed;

  l_cash_receipt_id             AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL;

  l_remittance_amount           AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE;
  l_remain_rcpt_amount          AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE;
  l_check_number                OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE;
  l_actual_remittance_amount    AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE;
  l_receipt_currency            OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE;
  l_receipt_date                OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE;
  l_receipt_count               NUMBER;

  l_invoice_currency_code       OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;
  l_inv_tot                                 NUMBER := 0;

  --
  l_currency_conv_type          OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE;
  l_currency_conv_date          OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE;
  l_currency_conv_rate          OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE;
  --


  l_rct_id                      NUMBER;
  l_rca_id                                  OKL_TXL_RCPT_APPS_V.ID%TYPE;
  l_cat_id                      OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
  i                                 NUMBER DEFAULT NULL;

  l_stat_total_rcpt_amt         OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT 0;
  l_stat_num_of_rcpts           NUMBER DEFAULT 0;
  l_stat_num_of_cont            NUMBER DEFAULT 0;

  l_org_id                      OKL_TRX_CSH_RECEIPT_V.ORG_ID%TYPE DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();

  l_exit_loop                   NUMBER DEFAULT 0;
  l_exchange_rate_type          VARCHAR2(100);
  l_conversion_rate             NUMBER;
  -------------------------------------------------------------------------------
  -- DECLARE Record/Table Types
  -------------------------------------------------------------------------------
  -- Internal Trans

  l_rctv_rec Okl_Rct_Pvt.rctv_rec_type;
  l_rctv_tbl Okl_Rct_Pvt.rctv_tbl_type;

  l_rcav_rec Okl_Rca_Pvt.rcav_rec_type;
  l_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;

  x_rctv_rec Okl_Rct_Pvt.rctv_rec_type;
  x_rctv_tbl Okl_Rct_Pvt.rctv_tbl_type;

  x_rcav_rec Okl_Rca_Pvt.rcav_rec_type;
  x_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;

  -- External Trans

  l_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;
  l_xcrv_tbl Okl_Xcr_Pvt.xcrv_tbl_type;

  l_xcav_rec Okl_Xca_Pvt.xcav_rec_type;
  l_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

  x_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;
  x_xcrv_tbl Okl_Xcr_Pvt.xcrv_tbl_type;

  x_xcav_rec Okl_Xca_Pvt.xcav_rec_type;
  x_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

  t_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

  -------------------------------------------------------------------------------
  -- DEFINE CURSORS
  -------------------------------------------------------------------------------

--start:|           13-May-2008 cklee  --Fixed bug 7036445                           |
  cursor c_customer_acc_num (cp_account_id number) is
  select ca.account_number
  from HZ_CUST_ACCOUNTS ca
  where ca.cust_account_id = cp_account_id;
--end:|           13-May-2008 cklee  --Fixed bug 7036445                           |

  -- get all advanced receipts for newly booked contract
  CURSOR   c_get_adv_rcpt_for_cont(cp_cont_id             IN NUMBER
                                  ,cp_currency_code       IN VARCHAR2) IS
  SELECT   DISTINCT(a.cash_receipt_id) icr_id,
           a.amount,
           a.date_effective,
           a.check_number,
           a.currency_code,
         --  arcash.exchange_rate_date,
         --  arcash.exchange_rate_type,
         --  arcash.exchange_rate ,
           a.id,
           arcash.receipt_Date
  FROM     OKL_TRX_CSH_RECEIPT_V a,
           OKL_TXL_RCPT_APPS_V b,
           ar_cash_receipts_All arcash
  WHERE    a.id = b.rct_id_details
  AND      a.FULLY_APPLIED_FLAG = 'N'
  AND      a.EXPIRED_FLAG = 'N'
  AND      a.receipt_type = 'ADV'
  AND      b.khr_id = cp_cont_id
  AND      a.cash_receipt_id = arcash.cash_receipt_id
  AND      a.currency_code = decode(p_cross_currency_allowed,'N', cp_currency_code ,a.currency_code)
  ORDER BY receipt_date;

  c_get_adv_rcpt_for_cont_rec c_get_adv_rcpt_for_cont%ROWTYPE;

  -------------------------------------------------------------------------------

  -- verify on account receipt amount
  CURSOR   c_ver_on_acct_amt(cp_csh_rcpt_id IN NUMBER) IS
  SELECT   (unapplied_amount + onaccount_amount) amount_available
  FROM     okl_receipt_Details_uv
  WHERE    cash_Receipt_id = cp_csh_rcpt_id;

  -------------------------------------------------------------------------------

  -- get contract total
  CURSOR   c_open_invs ( cp_contract_num         IN VARCHAR2
                         ,cp_customer_num        IN VARCHAR2
                         ,cp_currency_code       IN VARCHAR2
                         ) IS
  SELECT   lpt.sty_id
          ,lpt.amount_due_remaining
          ,lpt.currency_code
          ,lpt.ar_invoice_number
          ,lpt.trx_date
          ,lpt.customer_acct_id
          ,lpt.khr_id
  FROM     okl_rcpt_cust_cont_balances_uv lpt
  WHERE    lpt.contract_number = cp_contract_num
  AND      lpt.customer_account_number = NVL (cp_customer_num,  lpt.customer_account_number)
  AND      lpt.status = 'OP'
  AND      lpt.amount_due_remaining > 0
  AND      lpt.currency_code = decode(p_cross_currency_allowed,'N', NVL(cp_currency_code, lpt.currency_code),lpt.currency_code);

  c_open_invs_rec c_open_invs%ROWTYPE;

BEGIN
    log_file('advanced_Cash_App start');
    log_file('p_contract_num = '||p_contract_num);
    log_file('(cust_account_id)p_customer_num = '||p_customer_num);
    log_file('p_receipt_num = '|| p_Receipt_num);
    ------------------------------------------------------------
    -- Start processing
    ------------------------------------------------------------

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_return_status := Okl_Api.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => p_init_msg_list,
            l_api_version   => l_api_version,
            p_api_version   => p_api_version,
            p_api_type      => '_PVT',
            x_return_status => l_return_status);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

--start:|           13-May-2008 cklee  --Fixed bug 7036445                           |
    open c_customer_acc_num (p_customer_num);
    fetch c_customer_acc_num into l_customer_num;
    close c_customer_acc_num;
--end:|           13-May-2008 cklee  --Fixed bug 7036445                           |

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '=================================================================================');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '    ** Start Processing. Please See Error Log for any errored transactions **    ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '=================================================================================');

    IF l_contract_num IS NULL THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-------------------------------------------');
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'ERROR - You must specify a contract Number.');
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-------------------------------------------');
    END IF;

        ------------------------------------------------------------
        -- Handle call from auto billing api ...
        ------------------------------------------------------------

    IF l_contract_num IS NOT NULL THEN

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'CONTRACT NUMBER: '||l_contract_num);
        log_file('BEFORE CUrsor');
        FOR c_open_invs_rec IN c_open_invs (l_contract_num, l_customer_num, null)
        LOOP
            l_inv_tot := l_inv_tot + c_open_invs_rec.amount_due_remaining;
            l_contract_id := c_open_invs_rec.khr_id;
            l_customer_id := c_open_invs_rec.customer_acct_id;
	    l_invoice_currency_code := c_open_invs_rec.currency_code;
            log_file('l_inv_tot = '||l_inv_tot);
        END LOOP;
        log_file('l_inv_tot = '||l_inv_tot);
        log_file('l_contract_id = '||l_contract_id);
        log_file('l_customer_id = '||l_customer_id);
        IF l_inv_tot = 0 THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-----------------------------------------------------------------------------');
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Following contract has a balance of zero -- unable to apply advanced receipts');
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, l_contract_num);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-----------------------------------------------------------------------------');
        END IF;

        IF l_inv_tot > 0 THEN

            l_receipt_count := 0;

            FOR c_get_adv_rcpt_for_cont_rec IN c_get_adv_rcpt_for_cont (l_contract_id,l_invoice_currency_code)
            LOOP
                log_file('c_get_adv_rcpt_for_cont_rec.icr_id = '||c_get_adv_rcpt_for_cont_rec.icr_id);
                l_inv_tot := 0;

                FOR c_open_invs_rec IN c_open_invs (l_contract_num, l_customer_num, null)
                LOOP
                    l_invoice_currency_code := c_open_invs_rec.currency_code;
                    l_inv_tot := l_inv_tot + c_open_invs_rec.amount_due_remaining;
                END LOOP;

                IF l_inv_tot = 0 THEN
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'CONTRACT '||l_contract_num|| 'now has a zero balance - receipt application complete');
                    l_exit_loop := 1;
                END IF;

                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' NEW CONTRACT BALANCE: '||l_inv_tot);
                log_file('New Contract balance = '||l_inv_tot);
                EXIT WHEN l_exit_loop = 1;

                l_receipt_count      := l_receipt_count + 1;
                l_cash_receipt_id    := c_get_adv_rcpt_for_cont_rec.icr_id;
                l_remittance_amount  := c_get_adv_rcpt_for_cont_rec.amount;
                l_receipt_date       := c_get_adv_rcpt_for_cont_rec.date_effective;
                l_check_number       := c_get_adv_rcpt_for_cont_rec.check_number;
                l_receipt_currency   := c_get_adv_rcpt_for_cont_rec.currency_code;

              /*  l_currency_conv_date := c_get_adv_rcpt_for_cont_rec.exchange_rate_date;
                l_currency_conv_type := c_get_adv_rcpt_for_cont_rec.exchange_rate_type;
                l_currency_conv_rate := c_get_adv_rcpt_for_cont_rec.exchange_rate;
*/
                l_rct_id             := c_get_adv_rcpt_for_cont_rec.id;

                OPEN  c_ver_on_acct_amt(l_cash_receipt_id);
                FETCH c_ver_on_acct_amt INTO l_actual_remittance_amount;
                CLOSE c_ver_on_acct_amt;
                log_file('l_cash_receipt_id = '||l_cash_receipt_id);
                log_file('l_actual_remittance_amount = '||l_actual_remittance_amount);
                IF l_actual_remittance_amount = 0 OR l_actual_remittance_amount IS NULL THEN

                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'RECEIPT '||l_check_number|| 'now has zero Balance');
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'MOVING ON TO NEXT RECEIPT');

                    GOTO NEXT_RECEIPT;
                END IF;

                IF l_actual_remittance_amount <> l_remittance_amount THEN
                    l_remittance_amount := l_actual_remittance_amount;
                END IF;
                log_file('l_remittance_amount = '||l_remittance_amount);
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'RECEIPT NUMBER: '||l_check_number);
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'RECEIPT AMOUNT: '||l_actual_remittance_amount);

                --following code added by dkagrawa for cross currency
		IF l_invoice_currency_code <> l_receipt_currency THEN
                  l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(l_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                  IF l_exchange_rate_type IS  NULL THEN
                    OKL_API.set_message( p_app_name      => G_APP_NAME
                                        ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                       );
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                  ELSE
                    l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_invoice_currency_code
                                                                               ,l_receipt_currency
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
                  l_inv_tot := l_inv_tot*l_conversion_rate;
                END IF;

                IF l_inv_tot <= l_remittance_amount THEN

                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'No cash application rules required.  Balance of contract is less than or equal to receipt amount');
                    log_file('calling apply_rcpt_to_contract_no_rule ');
                    apply_rcpt_to_contract_no_rule ( p_api_version        => l_api_version
                                                    ,p_init_msg_list      => l_init_msg_list
                                                    ,x_return_status      => l_return_status
                                                    ,x_msg_count          => l_msg_count
                                                    ,x_msg_data           => l_msg_data
                                                    ,p_contract_id        => l_contract_id
                                                    ,p_contract_num       => l_contract_num
                                                    ,p_customer_id        => l_customer_id
--start:|           13-May-2008 cklee  --Fixed bug 7036445                           |
--                                                    ,p_customer_num       => l_customer_num
                                                    ,p_customer_num       => p_customer_num-- note: p_customer_num = HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID indeed
--end:|           13-May-2008 cklee  --Fixed bug 7036445                           |
                                                    ,p_receipt_id         => l_cash_receipt_id
                                                    ,p_receipt_amount     => l_remittance_amount
                                                    ,p_remain_rcpt_amount => l_remain_rcpt_amount
                                                    ,p_receipt_currency   => l_receipt_currency
                                                    ,p_receipt_date       => l_receipt_date
                                                    ,p_invoice_currency   => l_invoice_currency_code
                                                    ,p_currency_conv_date => l_currency_conv_date
                                                    ,p_currency_conv_rate => l_currency_conv_rate
                                                    ,p_currency_conv_type => l_currency_conv_type
                                                    ,p_xcr_id             => l_rct_id
						    ,p_cross_currency_allowed => l_cross_currency_allowed
                                                   );
                  log_file('l_return_status = '||l_return_status);

                ELSIF l_inv_tot > l_remittance_amount THEN

                    -- call procedure to do cash app

                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Cash application rule required.  Balance of contract is greater than receipt amount');
                    log_file('calling apply_rcpt_to_contract_w_rule');
                    apply_rcpt_to_contract_w_rule ( p_api_version        => l_api_version
                                                   ,p_init_msg_list      => l_init_msg_list
                                                   ,x_return_status      => l_return_status
                                                   ,x_msg_count          => l_msg_count
                                                   ,x_msg_data           => l_msg_data
                                                   ,p_contract_id        => l_contract_id
                                                   ,p_contract_num       => l_contract_num
                                                   ,p_customer_id        => l_customer_id
--start:|           13-May-2008 cklee  --Fixed bug 7036445                           |
--                                                    ,p_customer_num       => l_customer_num
                                                    ,p_customer_num       => p_customer_num-- note: p_customer_num = HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID indeed
--end:|           13-May-2008 cklee  --Fixed bug 7036445                           |
                                                   ,p_receipt_id         => l_cash_receipt_id
                                                   ,p_receipt_amount     => l_remittance_amount
                                                   ,p_remain_rcpt_amount => l_remain_rcpt_amount
                                                   ,p_receipt_currency   => l_receipt_currency
                                                   ,p_receipt_date       => l_receipt_date
                                                   ,p_invoice_currency   => l_invoice_currency_code
                                                   ,p_invoice_total      => l_inv_tot
                                                   ,p_currency_conv_date => l_currency_conv_date
                                                   ,p_currency_conv_rate => l_currency_conv_rate
                                                   ,p_currency_conv_type => l_currency_conv_type
                                                   ,p_xcr_id             => l_rct_id
						   ,p_cross_currency_allowed => l_cross_currency_allowed
                                                  );
                  log_file('l_return_status = '||l_return_status);
                END IF;

                x_return_status := l_return_status;

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                log_file(' l_remain_rcpt_amount =  '||l_remain_rcpt_amount);
                IF l_remain_rcpt_amount <> l_actual_remittance_amount THEN -- application took place, move to next contract ...

                    l_stat_total_rcpt_amt := l_stat_total_rcpt_amt + (l_actual_remittance_amount - l_remain_rcpt_amount);
                    l_stat_num_of_rcpts := l_stat_num_of_rcpts + 1;
                    l_stat_num_of_cont := l_stat_num_of_cont + 1;

                END IF;

                IF l_remain_rcpt_amount > 0 THEN
                    l_rctv_rec.FULLY_APPLIED_FLAG := 'N';
                ELSE
                    l_rctv_rec.FULLY_APPLIED_FLAG := 'Y';
                END IF;

                l_rctv_rec.ID := l_rct_id;
                log_file('l_rctv_rec.ID = '||l_rctv_rec.ID);
                OKL_RCT_PVT.update_row( p_api_version   =>  l_api_version
                                       ,p_init_msg_list =>  l_init_msg_list
                                       ,x_return_status =>  l_return_status
                                       ,x_msg_count     =>  l_msg_count
                                       ,x_msg_data      =>  l_msg_data
                                       ,p_rctv_rec      =>  l_rctv_rec
                                       ,x_rctv_rec      =>  x_rctv_rec);

                x_return_status := l_return_status;

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                -- commented out for testing purposes.
                -------------------------------------------------------------------
                -- COMMIT; -- Need to commit here to update balance of contract ...
                -------------------------------------------------------------------

                <<NEXT_RECEIPT>>

                NULL;

            END LOOP; -- looping through available advanced receipts for contract ...

            IF l_receipt_count = 0 THEN
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '------------------------------------------------------------------');
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'There are no advanced receipts for this contract - EXITING PROCESS');
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '------------------------------------------------------------------');
            END IF;

        END IF; -- IF inv_tot > 0

    END IF; -- IF l_contract_num IS NOT NULL

        ------------------------------------------------------------
        -- END Handle call from auto billing api ...
        ------------------------------------------------------------

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '====================================================================================');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Total number of receipts processed: '||l_stat_num_of_rcpts);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Total of receipt amounts: '||l_stat_total_rcpt_amt);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Total number of contracts that received cash application: '||l_stat_num_of_cont);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '====================================================================================');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'PROCESS COMPLETE: '||SYSDATE);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '====================================================================================');

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '====================================================================================');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '      ** End Processing. Please See Error Log for any errored transactions **       ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '====================================================================================');

        ------------------------------------------------------------
        -- End processing
        ------------------------------------------------------------

        Okl_Api.END_ACTIVITY (
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);
    log_file('end advanced_Cash_app');

EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := okl_api.G_RET_STS_ERROR;


    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        okl_api.G_RET_STS_ERROR,
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
    x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

END advanced_cash_app;

---------------------------------------------------------------------------
-- PROCEDURE apply_rcpt_to_contract_no_rule
-- Apply receipt to contract.  no purpose or cash application rule reqd.
-- as receipt amount is greater than contract total
---------------------------------------------------------------------------

PROCEDURE apply_rcpt_to_contract_no_rule ( p_api_version        IN  NUMBER
                                          ,p_init_msg_list      IN  VARCHAR2 DEFAULT okl_api.G_FALSE
                                          ,x_return_status      OUT NOCOPY VARCHAR2
                                          ,x_msg_count          OUT NOCOPY NUMBER
                                          ,x_msg_data           OUT NOCOPY VARCHAR2
                                          ,p_contract_id        IN  OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL
                                          ,p_contract_num       IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                          ,p_customer_id        IN  OKL_TRX_CSH_RECEIPT_V.ILE_ID%TYPE DEFAULT NULL
                                          ,p_customer_num       IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL-- note: p_customer_num = HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID indeed
                                          ,p_receipt_id         IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                          ,p_receipt_amount     IN  AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE
                                          ,p_remain_rcpt_amount OUT NOCOPY AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE
                                          ,p_receipt_currency   IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                          ,p_receipt_date       IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                                          ,p_invoice_currency   IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                          ,p_currency_conv_date IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT NULL
                                          ,p_currency_conv_rate IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT NULL
                                          ,p_currency_conv_type IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT NULL
                                          ,p_xcr_id             IN  NUMBER DEFAULT NULL
					  ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                       ) IS

---------------------------
-- DECLARE Local Variables
---------------------------



  l_api_version                 NUMBER := 1.0;
  l_init_msg_list               VARCHAR2(1) := okl_api.g_false;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'apply_rcpt_to_contract_no_rule';

  l_contract_id                 OKC_K_HEADERS_V.ID%TYPE DEFAULT p_contract_id;
  l_contract_num                OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT p_contract_num;
  l_customer_id                 OKL_TRX_CSH_RECEIPT_V.ILE_ID%TYPE DEFAULT p_customer_id;
--start:|           13-May-2008 cklee  --Fixed bug 7036445                           |
-- note: p_customer_num = HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID indeed
  l_customer_num                hz_cust_accounts.account_number%TYPE;
--end:|           13-May-2008 cklee  --Fixed bug 7036445                           |
  l_receipt_id                  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_receipt_id;
  l_receipt_amount              OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT p_receipt_amount;
  l_receipt_date                AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT p_receipt_date;
  l_cross_currency_allowed      VARCHAR2(1) DEFAULT p_cross_currency_allowed;
  l_converted_receipt_amount    OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL;


  l_customer_trx_id             AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_TRX_ID%TYPE DEFAULT NULL;

  l_cash_receipt_id             AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_receipt_id;
  l_check_number                OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE;
  l_receipt_currency_code       OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT p_receipt_currency;
  l_receipt_count               NUMBER;

  l_invoice_currency_code       OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT p_invoice_currency;

  l_currency_code               OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;  -- entered currency code

  l_applied_amount              AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL;
  l_applied_amount_from         AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED_FROM%TYPE DEFAULT NULL;

  --
  l_currency_conv_type          OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT p_currency_conv_type;
  l_currency_conv_date          OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT p_currency_conv_date;
  l_currency_conv_rate          OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT p_currency_conv_rate;
  --


  l_gl_date                     OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
  l_apply_date                  OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;

  l_xcr_id                      NUMBER DEFAULT p_xcr_id;
  l_rca_id                      OKL_TXL_RCPT_APPS_V.ID%TYPE;
  l_cat_id                      OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
  i                             NUMBER DEFAULT NULL;

  l_counter                     NUMBER;
  l_unapply                     VARCHAR2(3);

  l_record_count                NUMBER DEFAULT NULL;
  l_org_id                      OKL_TRX_CSH_RECEIPT_V.ORG_ID%TYPE DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();

  l_cau_id                      OKL_CSH_ALLCTN_RL_HDR.ID%TYPE DEFAULT NULL;

  l_appl_tbl                    okl_receipts_pvt.appl_tbl_type;
  x_appl_tbl                    okl_receipts_pvt.appl_tbl_type;
  l_exchange_rate_type          VARCHAR2(100);
  l_conversion_rate             NUMBER;

  -------------------------------------------------------------------------------
  -- DEFINE CURSORS
  -------------------------------------------------------------------------------
--start:|           13-May-2008 cklee  --Fixed bug 7036445                           |
  cursor c_customer_acc_num (cp_account_id number) is
  select ca.account_number
  from HZ_CUST_ACCOUNTS ca
  where ca.cust_account_id = cp_account_id;
--end:|           13-May-2008 cklee  --Fixed bug 7036445                           |


  -- get contract total
  CURSOR   c_open_invs ( cp_contract_num         IN VARCHAR2
                         ,cp_customer_num        IN VARCHAR2
                         ,cp_currency_code       IN VARCHAR2
                         ) IS
  SELECT   lpt.sty_id
          ,lpt.amount_due_remaining
          ,lpt.currency_code
          ,lpt.AR_INVOICE_NUMBER
          ,lpt.trx_date
          ,lpt.ar_invoice_id
          ,lpt.invoice_line_id
  FROM     okl_rcpt_cust_cont_balances_uv lpt
  WHERE    lpt.contract_number = cp_contract_num
  AND      lpt.customer_account_number = NVL (cp_customer_num,  lpt.customer_account_number)
  AND      lpt.status = 'OP'
  AND      lpt.amount_due_remaining > 0
  AND      lpt.currency_code = decode(p_cross_currency_allowed,'N',cp_currency_code,lpt.currency_code);  --dkagrawa added decode for cross currency support

  c_open_invs_rec c_open_invs%ROWTYPE;

  -------------------------------------------------------------------------------

  -- get cash applic rule id
  CURSOR   c_cash_rle_id_csr ( cp_khr_id IN NUMBER) IS
  SELECT   to_number(a.object1_id1)
  FROM     OKC_RULES_B a, OKC_RULE_GROUPS_B b
  WHERE    a.rgp_id = b.id
  AND      b.rgd_code = 'LABILL'
  AND      a.rule_information_category = 'LAINVD'
  AND      a.dnz_chr_id = b.chr_id
  AND      a.dnz_chr_id = cp_khr_id;

----------

BEGIN

--start:|           13-May-2008 cklee  --Fixed bug 7036445                           |
    open c_customer_acc_num (p_customer_num);
    fetch c_customer_acc_num into l_customer_num;
    close c_customer_acc_num;
--end:|           13-May-2008 cklee  --Fixed bug 7036445                           |


  log_file('apply_rcpt_to_contract_no_rule start');
  log_file('l_contract_id = '||l_contract_id);
  log_file('l_customer_num = '||l_customer_num);
  -- get cash application rule
  OPEN c_cash_rle_id_csr (l_contract_id);
  FETCH c_cash_rle_id_csr INTO l_cau_id;
  CLOSE c_cash_rle_id_csr;
  log_file('l_cau_id = '||l_cau_id);
  -- don't do cash application if CAR is 'On Account'  -- varao start
  IF NVL(l_cau_id, 0) = -1 THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'No cash application, ON-ACCOUNT Cash Application Rule.');
    p_remain_rcpt_amount := l_receipt_amount;
  ELSE                -- varao end
    i := 0;
        ------------------------------------------------------------
        -- Convert receipt currency to invoice currency if different
        ------------------------------------------------------------

        --  get invoice amount due remaining and invoice currency

    IF l_invoice_currency_code <> l_receipt_currency_code THEN
      l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(l_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
      IF l_exchange_rate_type IS  NULL THEN
        OKL_API.set_message( p_app_name      => G_APP_NAME
                            ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                           );
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_invoice_currency_code
                                                                   ,l_receipt_currency_code
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
        log_file('l_conversion_rate '||l_conversion_rate);
        l_converted_receipt_amount := (l_receipt_amount / l_conversion_rate);
        l_receipt_amount := l_converted_receipt_amount;
        log_file('receipt amount in inv currency '||l_receipt_amount);
    END IF;

    log_file('l_receipt_amount = '||l_receipt_amount);
    IF l_contract_num IS NOT NULL THEN
            OPEN c_open_invs ( l_contract_num, l_customer_num, l_receipt_currency_code);
            LOOP
                FETCH c_open_invs INTO c_open_invs_rec;
                EXIT WHEN c_open_invs%NOTFOUND OR l_receipt_amount = 0 OR l_receipt_amount IS NULL;

                i := i + 1;

                l_invoice_currency_code := c_open_invs_rec.currency_code;
                l_appl_tbl(i).ar_inv_id := c_open_invs_rec.ar_invoice_id;
                l_appl_tbl(i).line_id := c_open_invs_rec.invoice_line_id;
                l_appl_tbl(i).amount_to_apply := c_open_invs_rec.amount_due_remaining;
                log_file('**** Applications ****');
                log_file('l_appl_tbl(i).ar_inv_id = '||l_appl_tbl(i).ar_inv_id);
                log_file('l_appl_tbl(i).line_id = '||l_appl_tbl(i).line_id);
                log_file('l_appl_tbl(i).amount_to_apply = '||l_appl_tbl(i).amount_to_apply);
                IF l_receipt_amount < l_appl_tbl(i).amount_to_apply THEN
                    l_appl_tbl(i).amount_to_apply := l_receipt_amount;
                    l_receipt_amount := 0;
                ELSE
                    l_receipt_amount := l_receipt_amount - l_appl_tbl(i).amount_to_apply;
                END IF;
                log_file('l_appl_tbl(i).amount_to_apply = '||l_appl_tbl(i).amount_to_apply);
            END LOOP;
            CLOSE c_open_invs;
    END IF;
    log_file('l_receipt_amount before conversion =' ||l_receipt_amount);
    IF l_invoice_currency_code <> l_receipt_currency_code THEN
      p_remain_rcpt_amount := l_receipt_amount*l_conversion_rate;
    ELSE
      p_remain_rcpt_amount := l_receipt_amount;
    END IF;
    log_file('l_receipt_amount after conversion =' ||p_remain_rcpt_amount);
    l_record_count := l_appl_tbl.COUNT;
    log_file('l_record_count = '||l_record_count);
    IF l_record_count > 0  THEN
        log_file('calling process_advance_receipt');
        process_advance_receipt( p_api_version       => l_api_version
                           ,p_init_msg_list     => l_init_msg_list
                           ,x_return_status     => l_return_status
                           ,x_msg_count         => l_msg_count
                           ,x_msg_data          => l_msg_data
                           ,p_receipt_id        => l_receipt_id
                           ,p_org_id            => l_org_id
                           ,p_appl_tbl          => l_appl_tbl
                           ,x_remaining_amt     => p_remain_rcpt_amount
                          );
        log_file('l_return_status = ' ||l_return_status);
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;

  END IF;

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
   log_file('apply_rcpt_to_contract_no_rule end');
EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := okl_api.G_RET_STS_ERROR;


    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        OKL_API.G_RET_STS_ERROR,
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
        x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

END apply_rcpt_to_contract_no_rule;

---------------------------------------------------------------------------
-- PROCEDURE apply_rcpt_to_contract_w_rule
-- Apply receipt to contract w/ either defined purpose or cash application
-- rule
---------------------------------------------------------------------------

PROCEDURE apply_rcpt_to_contract_w_rule  ( p_api_version        IN  NUMBER
                                          ,p_init_msg_list      IN  VARCHAR2 DEFAULT okl_api.G_FALSE
                                          ,x_return_status      OUT NOCOPY VARCHAR2
                                          ,x_msg_count              OUT NOCOPY NUMBER
                                          ,x_msg_data               OUT NOCOPY VARCHAR2
                                          ,p_contract_id        IN  OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL
                                          ,p_contract_num       IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                          ,p_customer_id        IN  OKL_TRX_CSH_RECEIPT_V.ILE_ID%TYPE DEFAULT NULL
                                          ,p_customer_num       IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL-- note: p_customer_num = HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID indeed
                                          ,p_receipt_id         IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                          ,p_receipt_amount     IN  AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE
                                          ,p_remain_rcpt_amount OUT NOCOPY AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE
                                          ,p_receipt_currency   IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                          ,p_receipt_date       IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                                          ,p_invoice_currency   IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                          ,p_invoice_total      IN  OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL
                                          ,p_currency_conv_date IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT NULL
                                          ,p_currency_conv_rate IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT NULL
                                          ,p_currency_conv_type IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT NULL
                                          ,p_xcr_id             IN  NUMBER DEFAULT NULL
					  ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                       ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

  l_api_version                 NUMBER := 1.0;
  l_init_msg_list               VARCHAR2(1) := okl_api.g_false;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'apply_rcpt_to_contract_w_rule';

  l_contract_id                 OKC_K_HEADERS_V.ID%TYPE DEFAULT p_contract_id;
  l_contract_num                OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT p_contract_num;
  l_customer_id                 OKL_TRX_CSH_RECEIPT_V.ILE_ID%TYPE DEFAULT p_customer_id;
--start:|           13-May-2008 cklee  --Fixed bug 7036445                           |
-- note: p_customer_num = HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID indeed
  l_customer_num                hz_cust_accounts.account_number%TYPE;
--end:|           13-May-2008 cklee  --Fixed bug 7036445                           |
  l_receipt_id                  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_receipt_id;
  l_receipt_amount              OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT p_receipt_amount;
  l_receipt_date                AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT p_receipt_date;
  l_cross_currency_allowed      VARCHAR2(1) DEFAULT p_cross_currency_allowed;

  l_converted_receipt_amount     OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL;

  l_customer_trx_id             AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_TRX_ID%TYPE DEFAULT NULL;

  l_cash_receipt_id             AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_receipt_id;
  l_check_number                OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE;
  l_expired_flag                  OKL_TRX_CSH_RECEIPT_V.FULLY_APPLIED_FLAG%TYPE;
  l_receipt_currency_code       OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT p_receipt_currency;

  l_receipt_remaining           OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL;
  l_amt_due_remaining_tot       OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL;

  l_inv_tot                                 OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT p_invoice_total;
  l_temp_val                            NUMBER := 0;
  l_receipt_count               NUMBER;

  l_appl_tolerance                      NUMBER := 0;
  l_first_prorate_rec           NUMBER DEFAULT NULL;
  l_order_count                 NUMBER DEFAULT NULL;

  l_ordered                                 CONSTANT VARCHAR2(3) := 'ODD';
  l_prorate                                 CONSTANT VARCHAR2(3) := 'PRO';
  l_pro_rate_inv_total              NUMBER := 0;
  l_sty_id                                  OKL_CNSLD_AR_STRMS_V.STY_ID%TYPE;



  l_invoice_currency_code       OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT p_invoice_currency;

  l_currency_code               OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;  -- entered currency code

  l_applied_amount              AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL;
  l_applied_amount_from         AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED_FROM%TYPE DEFAULT NULL;

  --
  l_currency_conv_type          OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT p_currency_conv_type;
  l_currency_conv_date          OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT p_currency_conv_date;
  l_currency_conv_rate          OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT p_currency_conv_rate;
  --


  l_gl_date                     OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
  l_apply_date                  OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;

  l_rule_name                   OKL_CASH_ALLCTN_RLS.NAME%TYPE DEFAULT NULL;
  l_check_cau_id                OKL_CSH_ALLCTN_RL_HDR.ID%TYPE DEFAULT NULL;
  l_cau_id                      OKL_CSH_ALLCTN_RL_HDR.ID%TYPE DEFAULT NULL;
  l_cat_id                      OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
  l_tolerance                           OKL_CASH_ALLCTN_RLS.AMOUNT_TOLERANCE_PERCENT%TYPE DEFAULT NULL;
  l_days_past_quote_valid           OKL_CASH_ALLCTN_RLS.DAYS_PAST_QUOTE_VALID_TOLERANC%TYPE DEFAULT NULL;
  l_months_to_bill_ahead            OKL_CASH_ALLCTN_RLS.MONTHS_TO_BILL_AHEAD%TYPE DEFAULT NULL;
  l_under_payment                       OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_over_payment                        OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_receipt_msmtch                      OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE DEFAULT NULL;

  l_dflt_cat_id                 OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
  l_dflt_name                   OKL_CASH_ALLCTN_RLS.NAME%TYPE DEFAULT NULL;
  l_dflt_tolerance                          OKL_CASH_ALLCTN_RLS.AMOUNT_TOLERANCE_PERCENT%TYPE DEFAULT NULL;
  l_dflt_days_past_quote_valid  OKL_CASH_ALLCTN_RLS.DAYS_PAST_QUOTE_VALID_TOLERANC%TYPE DEFAULT NULL;
  l_dflt_months_to_bill_ahead   OKL_CASH_ALLCTN_RLS.MONTHS_TO_BILL_AHEAD%TYPE DEFAULT NULL;
  l_dflt_under_payment              OKL_CASH_ALLCTN_RLS.UNDER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_dflt_over_payment               OKL_CASH_ALLCTN_RLS.OVER_PAYMENT_ALLOCATION_CODE%TYPE DEFAULT NULL;
  l_dflt_receipt_msmtch             OKL_CASH_ALLCTN_RLS.RECEIPT_MSMTCH_ALLOCATION_CODE%TYPE DEFAULT NULL;

  l_purpose_id                  OKL_TXL_RCPT_APPS_V.STY_ID%TYPE DEFAULT NULL;
  l_purpose_amt                 OKL_TXL_RCPT_APPS_V.AMOUNT%TYPE DEFAULT NULL;
  l_purpose_total               OKL_TXL_RCPT_APPS_V.AMOUNT%TYPE DEFAULT NULL;

  l_applied_running_total       OKL_TXL_RCPT_APPS_V.AMOUNT%TYPE DEFAULT NULL;

  l_xcr_id                      NUMBER DEFAULT p_xcr_id;
  l_rca_id                                  OKL_TXL_RCPT_APPS_V.ID%TYPE;
  i                                 NUMBER DEFAULT NULL;
  k                             NUMBER := 0;

  l_counter                     NUMBER;
  l_unapply                     VARCHAR2(3);

  l_record_count                NUMBER DEFAULT NULL;
  l_org_id                      OKL_TRX_CSH_RECEIPT_V.ORG_ID%TYPE DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();
  x_onacc_amount                NUMBER;
  x_unapply_amount              NUMBER;
  l_exchange_rate_type          VARCHAR2(100);
  l_conversion_rate             NUMBER;

  -------------------------------------------------------------------------------
  -- DECLARE Record/Table Types
  -------------------------------------------------------------------------------

  l_autocash_appl_tbl okl_auto_cash_appl_rules_pvt.okl_appl_dtls_tbl_type;
  l_appl_tbl  okl_receipts_pvt.appl_tbl_type;
  -------------------------------------------------------------------------------
  -- DEFINE CURSORS
  -------------------------------------------------------------------------------
--start:|           13-May-2008 cklee  --Fixed bug 7036445                           |
  cursor c_customer_acc_num (cp_account_id number) is
  select ca.account_number
  from HZ_CUST_ACCOUNTS ca
  where ca.cust_account_id = cp_account_id;
--end:|           13-May-2008 cklee  --Fixed bug 7036445                           |


  -- nikshah -- Bug # 5484903 Fixed,
  -- Changed CURSOR c_open_invs SQL definition
  -- get contract total
  CURSOR   c_open_invs (  cp_contract_num    IN VARCHAR2
                         ,cp_customer_num    IN VARCHAR2
                         ,cp_stream_type_id  IN NUMBER
                         ,cp_currency_code   IN VARCHAR2) IS
  SELECT   lpt.sty_id
          ,lpt.amount_due_remaining
          ,lpt.currency_code
          ,lpt.ar_invoice_number
          ,lpt.trx_date
          ,lpt.ar_invoice_id
          ,lpt.invoice_line_id
  FROM     okl_rcpt_cust_cont_balances_uv lpt
  WHERE    lpt.contract_number = cp_contract_num
  AND      lpt.customer_account_number = NVL (cp_customer_num,  lpt.customer_account_number)
  AND      lpt.sty_id = NVL (cp_stream_type_id, lpt.sty_id)
  AND      lpt.status = 'OP'
  AND      lpt.amount_due_remaining > 0
  AND      lpt.currency_code = decode(p_cross_currency_allowed,'N',cp_currency_code,lpt.currency_code);  --dkagrawa added decode for cross currency support


  c_open_invs_rec c_open_invs%ROWTYPE;

  CURSOR c_get_cust_acct_num(cp_cash_receipt_id IN NUMBER) IS
  SELECT hca.account_number
  FROM hz_cust_accounts_all hca,
       ar_cash_receipts_all arcash
  WHERE hca.cust_account_id = arcash.pay_from_customer
  AND arcash.cash_receipt_id = cp_cash_receipt_id;

  -------------------------------------------------------------------------------

  -- get purpose for advance receipt if any
  CURSOR   c_get_purpose_for_adv_rcpt(cp_cont_id IN NUMBER, cp_icr_id IN NUMBER) IS
  SELECT   b.sty_id, b.amount
  FROM     OKL_TRX_CSH_RECEIPT_V a, OKL_TXL_RCPT_APPS_V b
  WHERE    a.id = b.rct_id_details
  AND      a.receipt_type = 'ADV'
  AND      a.EXPIRED_FLAG = 'N'
  AND      a.FULLY_APPLIED_FLAG = 'N'
  AND      a.cash_receipt_id = cp_icr_id
  AND      b.khr_id = cp_cont_id
  AND      b.sty_id IS NOT NULL;

  -------------------------------------------------------------------------------

  -- get stream application order
  CURSOR   c_stream_alloc ( cp_str_all_type IN VARCHAR2
                           ,cp_cat_id       IN NUMBER ) IS
  SELECT   sty_id
  FROM     OKL_STRM_TYP_ALLOCS
  WHERE    stream_allc_type = cp_str_all_type
  AND      cat_id = cp_cat_id
  ORDER BY sequence_number;

  -------------------------------------------------------------------------------

  -- get cash applic rule id
  CURSOR   c_cash_rle_id_csr ( cp_khr_id IN NUMBER) IS
  SELECT   to_number(a.object1_id1)
  FROM     OKC_RULES_B a, OKC_RULE_GROUPS_B b
  WHERE    a.rgp_id = b.id
  AND      b.rgd_code = 'LABILL'
  AND      a.rule_information_category = 'LAINVD'
  AND      a.dnz_chr_id = b.chr_id
  AND      a.dnz_chr_id = cp_khr_id;

  -------------------------------------------------------------------------------

   -- get cash applic rule for contract
  CURSOR   c_cash_rule_csr  ( cp_cau_id IN NUMBER ) IS
  SELECT   ID
          ,NAME
          ,AMOUNT_TOLERANCE_PERCENT
          ,DAYS_PAST_QUOTE_VALID_TOLERANC
          ,MONTHS_TO_BILL_AHEAD
          ,UNDER_PAYMENT_ALLOCATION_CODE
          ,OVER_PAYMENT_ALLOCATION_CODE
          ,RECEIPT_MSMTCH_ALLOCATION_CODE
  FROM     OKL_CASH_ALLCTN_RLS
  WHERE    CAU_ID = cp_cau_id
  AND      START_DATE <= trunc(SYSDATE)
  AND     (END_DATE >= trunc(SYSDATE) OR END_DATE IS NULL);

  -------------------------------------------------------------------------------

   -- get default cash applic rule for organization
  CURSOR   c_dflt_cash_applic_rule IS
  SELECT   ID
          ,NAME
          ,AMOUNT_TOLERANCE_PERCENT
          ,DAYS_PAST_QUOTE_VALID_TOLERANC
          ,MONTHS_TO_BILL_AHEAD
          ,UNDER_PAYMENT_ALLOCATION_CODE
          ,OVER_PAYMENT_ALLOCATION_CODE
          ,RECEIPT_MSMTCH_ALLOCATION_CODE
  FROM     OKL_CASH_ALLCTN_RLS
  WHERE    default_rule = 'YES'
  AND      TRUNC(end_date) IS NULL;

   -- get default cash applic rule for organization
  CURSOR   c_get_org_id(cp_khr_id IN NUMBER) IS
  SELECT   org_id
  FROM     okc_k_headers_All_b
  WHERE    id = cp_khr_id;

  CURSOR   get_onacc_amt(cp_csh_rcpt_id IN NUMBER) IS
  SELECT   sum(nvl(amount_applied,0))
  FROM     AR_RECEIVABLE_APPLICATIONS_ALL
  WHERE    status = 'ACC'
  AND      cash_receipt_id = cp_csh_rcpt_id;

  CURSOR chk_exp_flag(cp_rct_id IN NUMBER) IS
  SELECT nvl(expired_flag,'N') INTO l_expired_flag
        FROM   OKL_TRX_CSH_RECEIPT_V
        WHERE  cash_receipt_id = cp_rct_id;
  -------------------------------------------------------------------------------


BEGIN
    log_file('apply_rcpt_to_contract_w_rule start');

--start:|           13-May-2008 cklee  --Fixed bug 7036445                           |
    open c_customer_acc_num (p_customer_num);
    fetch c_customer_acc_num into l_customer_num;
    close c_customer_acc_num;
--end:|           13-May-2008 cklee  --Fixed bug 7036445                           |

    -- get default cash application rule
    OPEN c_dflt_cash_applic_rule;
    FETCH c_dflt_cash_applic_rule INTO  l_dflt_cat_id
                                   ,l_dflt_name
                                           ,l_dflt_tolerance
                                           ,l_dflt_days_past_quote_valid
                                           ,l_dflt_months_to_bill_ahead
                                           ,l_dflt_under_payment
                                           ,l_dflt_over_payment
                                           ,l_dflt_receipt_msmtch;
    CLOSE c_dflt_cash_applic_rule;

    -- get cash application rule
    OPEN c_cash_rle_id_csr (l_contract_id);
    FETCH c_cash_rle_id_csr INTO l_cau_id;
    CLOSE c_cash_rle_id_csr;

    IF l_cau_id IS NOT NULL THEN

        OPEN c_cash_rule_csr (l_cau_id);
        FETCH c_cash_rule_csr INTO  l_cat_id
                                   ,l_rule_name
                                   ,l_tolerance
                                   ,l_days_past_quote_valid
                                   ,l_months_to_bill_ahead
                                   ,l_under_payment
                                   ,l_over_payment
                                           ,l_receipt_msmtch;
        CLOSE c_cash_rule_csr;

        IF l_tolerance IS NULL THEN

            l_rule_name             := l_dflt_name;
            l_cat_id                := l_dflt_cat_id;
            l_tolerance             := l_dflt_tolerance;
            l_days_past_quote_valid := l_dflt_days_past_quote_valid;
                    l_months_to_bill_ahead  := l_dflt_months_to_bill_ahead;
                    l_under_payment         := l_dflt_under_payment;
                    l_over_payment          := l_dflt_over_payment;
                    l_receipt_msmtch        := l_dflt_receipt_msmtch;
        END IF;

    ELSE -- use default rule

        l_rule_name             := l_dflt_name;
        l_cat_id                := l_dflt_cat_id;
        l_tolerance             := l_dflt_tolerance;
        l_days_past_quote_valid := l_dflt_days_past_quote_valid;
            l_months_to_bill_ahead  := l_dflt_months_to_bill_ahead;
            l_under_payment         := l_dflt_under_payment;
            l_over_payment          := l_dflt_over_payment;
        l_receipt_msmtch        := l_dflt_receipt_msmtch;

    END IF;

        i := 0;
    l_expired_flag := NULL;
    IF l_receipt_id IS NOT NULL THEN
        OPEN chk_exp_flag(l_receipt_id);
        FETCH chk_exp_flag INTO l_expired_flag;
        CLOSE chk_exp_flag;
    END IF;
    IF l_expired_flag IS NULL THEN
      l_expired_flag :='N';
    END IF;
    log_file('l_expired_flag = '||l_expired_flag);
    ------------------------------------------------------------
    -- Convert receipt currency to invoice currency if different
    ------------------------------------------------------------
    --  get invoice amount due remaining and invoice currency

    IF l_invoice_currency_code <> l_receipt_currency_code THEN
      l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(l_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
      IF l_exchange_rate_type IS  NULL THEN
        OKL_API.set_message( p_app_name      => G_APP_NAME
                            ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                           );
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_invoice_currency_code
                                                                   ,l_receipt_currency_code
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
        log_file('l_conversion_rate '||l_conversion_rate);
        l_converted_receipt_amount := (l_receipt_amount / l_conversion_rate);
        l_receipt_amount := l_converted_receipt_amount;
        log_file('receipt amount in inv currency '||l_receipt_amount);
    END IF;

    log_file('l_receipt_id = '||l_receipt_id);

    IF l_expired_flag = 'N' AND l_receipt_id IS NOT NULL THEN
        l_purpose_total := 0;

        OPEN  c_get_purpose_for_adv_rcpt(l_contract_id, l_receipt_id);
        LOOP
            FETCH c_get_purpose_for_adv_rcpt INTO l_purpose_id, l_purpose_amt;
            EXIT WHEN c_get_purpose_for_adv_rcpt%NOTFOUND;
            l_purpose_total := l_purpose_total + l_purpose_amt;
        END LOOP;
        CLOSE c_get_purpose_for_adv_rcpt;

        IF l_purpose_total > l_receipt_amount THEN
            NULL; --ERROR;  "EXIT WITH UNEXPECTED ERROR"
        END IF;
    END IF;

    log_file('l_purpose_id = '||l_purpose_id);
    IF l_purpose_id IS NOT NULL AND l_expired_flag = 'N' THEN

        l_applied_running_total := 0;
        l_amt_due_remaining_tot := 0;
        l_receipt_remaining := l_receipt_amount;

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'ADVANCED ALLOCATION RULE USED');
        --Fixed bug 7034283, by nikshah
        i := 0;
        OPEN c_get_purpose_for_adv_rcpt (l_contract_id, l_receipt_id);
        LOOP

            FETCH c_get_purpose_for_adv_rcpt INTO l_purpose_id, l_purpose_amt;
                EXIT WHEN c_get_purpose_for_adv_rcpt%NOTFOUND
                        OR l_purpose_amt = 0;
                    log_file('l_contract_num = '||l_contract_num);
                    IF l_purpose_amt IS NULL THEN

                      IF l_contract_num IS NOT NULL THEN
                              FOR c_open_invs_rcd in c_open_invs(l_contract_num, l_customer_num, l_purpose_id, l_receipt_currency_code) LOOP
                                l_amt_due_remaining_tot := l_amt_due_remaining_tot + c_open_invs_rcd.amount_due_remaining;
                              END LOOP;
                      END IF;
                      IF l_amt_due_remaining_tot > l_receipt_remaining THEN
                        l_purpose_amt := l_receipt_remaining;
                      ELSE
                        l_purpose_amt := l_amt_due_remaining_tot;
                      END IF;
                      l_amt_due_remaining_tot := 0;
                    ELSE
		      --dkagrawa added following code to convert purpose amount into invoice currency
		      IF l_invoice_currency_code <> l_receipt_currency_code THEN
                        l_purpose_amt := l_purpose_amt/l_conversion_rate;
                      END IF;
                      IF l_purpose_amt > l_receipt_remaining THEN
                        l_purpose_amt := l_receipt_remaining;
                      END IF;
                    END IF;
                    IF l_contract_num IS NOT NULL THEN
                        OPEN c_open_invs (l_contract_num, l_customer_num, l_purpose_id, l_receipt_currency_code);
                        LOOP
                                FETCH c_open_invs INTO c_open_invs_rec;
                                        EXIT WHEN c_open_invs%NOTFOUND
                                                OR l_purpose_amt = 0;

                                i := i + 1;

                                l_appl_tbl(i).ar_inv_id := c_open_invs_rec.ar_invoice_id;
                                l_appl_tbl(i).AMOUNT_TO_APPLY := c_open_invs_rec.amount_due_remaining;
                                l_appl_tbl(i).line_id         := c_open_invs_rec.invoice_line_id;

                                IF l_appl_tbl(i).AMOUNT_TO_APPLY >= l_purpose_amt THEN
                                    l_appl_tbl(i).AMOUNT_TO_APPLY := l_purpose_amt;
                                    l_purpose_amt := 0;
                                ELSE
                                    l_appl_tbl(i).AMOUNT_TO_APPLY := c_open_invs_rec.amount_due_remaining;
                                    l_purpose_amt := l_purpose_amt - l_appl_tbl(i).AMOUNT_TO_APPLY;
                                END IF;

                                l_applied_running_total := l_applied_running_total + l_appl_tbl(i).AMOUNT_TO_APPLY;

                        END LOOP;
                        CLOSE c_open_invs;
                    END IF;
                    l_receipt_remaining := l_receipt_amount - l_applied_running_total;

            END LOOP;
            CLOSE c_get_purpose_for_adv_rcpt;

            l_receipt_amount := l_receipt_amount - l_applied_running_total;

     ELSE -- purpose is not defined, use cash application rule
       log_file('l_cau_id = '||l_cau_id);
       -- don't do cash application if CAR is 'On Account'  -- abindal start
       IF NVL(l_cau_id, 0) = -1 THEN
         l_receipt_remaining := l_receipt_amount;
       ELSE                -- abindal end

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'USING CASH APPLICATIONM RULE');
        IF l_customer_num IS NULL THEN
          OPEN c_get_cust_acct_num(l_receipt_id);
          FETCH c_get_cust_acct_num INTO l_customer_num; -- now this is a real customer number: HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE
          CLOSE c_get_cust_acct_num;
        END IF;
        log_file('calling auto_cashapp_for_contract ');
        log_file('l_receipt_amount = '||l_receipt_amount);
        okl_auto_cash_appl_rules_pvt.auto_cashapp_for_contract( p_api_version   => l_api_version,
                                                                p_init_msg_list => l_init_msg_list,
                                                                x_return_status => l_return_status,
                                                                x_msg_count     => l_msg_count,
                                                                x_msg_data      => l_msg_data,
                                                                p_customer_num  => l_customer_num, -- HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE
                                                                p_contract_num  => l_contract_num,
                                                                p_currency_code => l_receipt_currency_code,
                                                                p_amount_app_to => l_receipt_amount,
								p_receipt_date  => l_receipt_date,
                                                                p_org_id        => l_org_id,
                                                                x_appl_tbl      => l_autocash_appl_tbl,
                                                                x_onacc_amount  => x_onacc_amount,
                                                                x_unapply_amount=> x_unapply_amount);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        log_file('l_autocash_appl_tbl.count = '||l_autocash_appl_tbl.count);
        l_applied_running_total := 0;
        IF l_autocash_appl_tbl.count > 0 THEN
          i := 1;
          FOR k IN l_autocash_appl_tbl.FIRST..l_autocash_appl_tbl.lAST LOOP
             IF l_autocash_appl_tbl(k).inv_lines_tbl.COUNT > 0 THEN
               FOR l IN l_autocash_appl_tbl(k).inv_lines_tbl.FIRST..l_autocash_appl_tbl(k).inv_lines_tbl.LAST LOOP
                  l_appl_tbl(i).ar_inv_id       := l_autocash_appl_tbl(k).inv_hdr_rec.invoice_id;
                  l_appl_tbl(i).AMOUNT_TO_APPLY  := l_autocash_appl_tbl(k).inv_lines_tbl(l).amount_applied;
                  l_appl_tbl(i).line_id := l_autocash_appl_tbl(k).inv_lines_tbl(l).invoice_line_id;
                  l_applied_running_total := l_applied_running_total + l_autocash_appl_tbl(k).inv_lines_tbl(l).amount_applied;
                  log_file('l_appl_tbl(i).ar_inv_id = '||l_appl_tbl(i).ar_inv_id);
                  log_file('l_appl_tbl(i).AMOUNT_TO_APPLY = '||l_appl_tbl(i).AMOUNT_TO_APPLY);
                  log_file('l_appl_tbl(i).line_id = '||l_appl_tbl(i).line_id);
                  i := i +1;
               END LOOP;
             END IF;
          END LOOP;
        END IF;
        l_receipt_remaining := l_receipt_amount - l_applied_running_total;
       END IF;   -- 'On Account' CAR

    END IF;

    IF l_appl_tbl.COUNT > 0  THEN
        log_file('calling process_advance_receipt');
        process_advance_receipt( p_api_version       => l_api_version
                           ,p_init_msg_list     => l_init_msg_list
                           ,x_return_status     => l_return_status
                           ,x_msg_count         => l_msg_count
                           ,x_msg_data          => l_msg_data
                           ,p_receipt_id        => l_receipt_id
                           ,p_org_id            => l_org_id
                           ,p_appl_tbl          => l_appl_tbl
                           ,x_remaining_amt     => p_remain_rcpt_amount
                          );
        log_file('l_return_status = '||l_return_status);
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;
    log_file('p_remain_rcpt_amount in invoice currency = '||l_receipt_remaining);
    IF l_invoice_currency_code <> l_receipt_currency_code THEN
      p_remain_rcpt_amount := l_receipt_remaining*l_conversion_rate;
    ELSE
      p_remain_rcpt_amount := l_receipt_remaining;
    END IF;
    log_file('p_remain_rcpt_amount in receipt currency = '||p_remain_rcpt_amount);
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    Okl_Api.END_ACTIVITY ( x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data);

    log_file('end  apply_rcpt_to_contract_w_rule');
EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := okl_api.G_RET_STS_ERROR;


    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        OKL_API.G_RET_STS_ERROR,
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

END apply_rcpt_to_contract_w_rule;

---------------------------------------------------------------------------
-- PROCEDURE reapplic_advanced_cash_app
-- Re application of advanced cash
---------------------------------------------------------------------------

PROCEDURE reapplic_advanced_cash_app ( p_api_version        IN  NUMBER
                                      ,p_init_msg_list      IN  VARCHAR2 DEFAULT okl_api.G_FALSE
                                      ,x_return_status      OUT NOCOPY VARCHAR2
                                      ,x_msg_count          OUT NOCOPY NUMBER
                                      ,x_msg_data           OUT NOCOPY VARCHAR2
                                      ,p_contract_num       IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                      ,p_customer_num       IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL-- note: p_customer_num = HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID indeed
                                      ,p_receipt_id         IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                      ,p_receipt_num        IN  OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL
                                      ,p_receipt_date_from  IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                                      ,p_receipt_date_to    IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                                      ,p_receipt_type       IN  VARCHAR2 DEFAULT NULL
				      ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                     ) IS


---------------------------
-- DECLARE Local Variables
---------------------------

  l_api_version                 NUMBER := 1.0;
  l_init_msg_list                       VARCHAR2(1) := okl_api.g_false;
  l_return_status                       VARCHAR2(1);
  l_msg_count                           NUMBER;
  l_msg_data                            VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'reapplic_advanced_cash_app';

  l_contract_id                 OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL;
  l_contract_num                OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT p_contract_num;
  l_customer_id                 OKL_TRX_CSH_RECEIPT_V.ILE_ID%TYPE DEFAULT NULL;
--  l_customer_num                AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL;
--start:|           13-May-2008 cklee  --Fixed bug 7036445                           |
  l_customer_num                hz_cust_accounts.account_number%TYPE;
--end:|           13-May-2008 cklee  --Fixed bug 7036445                           |

  l_customer_acct_id            NUMBER DEFAULT p_customer_num;
  l_receipt_id                  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_receipt_id;
  l_receipt_num                 OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT p_receipt_num;
  l_receipt_amount              OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL;
  l_cross_currency_allowed      VARCHAR2(1) DEFAULT p_cross_currency_allowed;

  l_receipt_date                OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE;
  l_receipt_date_from           OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT TRUNC(p_receipt_date_from);
  l_receipt_date_to             OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT TRUNC(p_receipt_date_to);

  l_cash_receipt_id             AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL;

  l_dflt_days_to_hold_adv_pay   OKL_CASH_ALLCTN_RLS.NUM_DAYS_HOLD_ADV_PAY%TYPE;
  l_days_to_hold_adv_pay        OKL_CASH_ALLCTN_RLS.NUM_DAYS_HOLD_ADV_PAY%TYPE;

  l_temp_contract_id            OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL;
  l_temp_receipt_id             AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL;
  l_temp_rcpt_date              AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT NULL;

  l_remittance_amount           AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE;
  l_remain_rcpt_amount          AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE;
  l_check_number                OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE;
  l_actual_remittance_amount    AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE;
  l_on_account_bal              AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE;
  l_receipt_currency            OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE;
  l_receipt_count               NUMBER;
  l_receipt_type                VARCHAR2(30) := p_receipt_type;

  l_invoice_currency_code       OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;
  l_inv_tot                                 NUMBER := 0;

  --
  l_currency_conv_type          OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE;
  l_currency_conv_date          OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE;
  l_currency_conv_rate          OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE;
  --


  l_cau_id                      OKL_CSH_ALLCTN_RL_HDR.ID%TYPE DEFAULT NULL;

  l_okl_receipt_id              NUMBER;
  l_xcr_id                      NUMBER;
  l_rct_id                      OKL_TRX_CSH_RECEIPT_V.ID%TYPE;
  l_rca_id                                  OKL_TXL_RCPT_APPS_V.ID%TYPE;
  l_cat_id                      OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
  i                                 NUMBER DEFAULT NULL;


  l_org_id                      OKL_TRX_CSH_RECEIPT_V.ORG_ID%TYPE DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();

  l_stat_total_rcpt_amt         OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT 0;
  l_stat_num_of_rcpts           NUMBER DEFAULT 0;
  l_stat_num_of_cont            NUMBER DEFAULT 0;

  l_exit_loop                   NUMBER DEFAULT 0;
  l_exchange_rate_type          VARCHAR2(100);
  l_conversion_rate             NUMBER;
  -------------------------------------------------------------------------------
  -- DECLARE Record/Table Types
  -------------------------------------------------------------------------------
  -- Internal Trans

  l_rctv_rec Okl_Rct_Pvt.rctv_rec_type;
  l_rctv_tbl Okl_Rct_Pvt.rctv_tbl_type;

  l_rcav_rec Okl_Rca_Pvt.rcav_rec_type;
  l_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;

  x_rctv_rec Okl_Rct_Pvt.rctv_rec_type;
  x_rctv_tbl Okl_Rct_Pvt.rctv_tbl_type;

  x_rcav_rec Okl_Rca_Pvt.rcav_rec_type;
  x_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;
  -------------------------------------------------------------------------------
  -- DEFINE CURSORS
  -------------------------------------------------------------------------------

  CURSOR   c_get_cont_for_cust(cp_customer_num IN VARCHAR2,
                               cp_contract_num IN VARCHAR2) IS
  SELECT   DISTINCT(lpt.contract_number),
           lpt.khr_id,
           lpt.start_date,
           lpt.currency_code,
           lpt.customer_account_number
  FROM     okl_rcpt_cust_cont_balances_uv lpt
  WHERE    lpt.customer_account_number = nvl(cp_customer_num,lpt.customer_account_number)
  AND      lpt.contract_number = NVL(cp_contract_num,lpt.contract_number)
  AND      lpt.status = 'OP'
  AND      lpt.amount_due_remaining > 0
  AND      lpt.org_id = mo_global.get_current_org_id
  ORDER BY lpt.start_date;

  c_get_cont_for_cust_rec c_get_cont_for_cust%ROWTYPE;

  -------------------------------------------------------------------------------

  -- get advanced receipt details to apply to given contract
  CURSOR   c_get_rcpt_dtls(cp_icr_id IN NUMBER) IS
  SELECT   b.amount,
           b.receipt_number,
           b.currency_code,
           b.receipt_date,
           a.id
  FROM     OKL_TRX_CSH_RECEIPT_V a,
           ar_Cash_receipts_all b
  WHERE    a.fully_applied_flag = 'N'
  AND      a.expired_flag = 'N'
  AND      a.receipt_type = 'ADV'
  AND      a.cash_receipt_id = b.cash_receipt_id
  AND      a.cash_receipt_id = cp_icr_id;

  c_get_rcpt_dtls_rec c_get_rcpt_dtls%ROWTYPE;
  -------------------------------------------------------------------------------

  -- get all unapplied advanced receipts
  CURSOR   c_get_all_adv_rcpt IS
  SELECT   DISTINCT(c.cash_receipt_id) icr_id,
           a.id RCT_ID,
           c.receipt_date,
           b.khr_id
  FROM     OKL_TRX_CSH_RECEIPT_V a,
           OKL_TXL_RCPT_APPS_V b,
           AR_CASH_RECEIPTS_ALL c
  WHERE    a.id = b.rct_id_details
  AND      a.cash_receipt_id = c.cash_receipt_id
  AND      a.FULLY_APPLIED_FLAG = 'N'
  AND      a.receipt_type = 'ADV'
  AND      a.expired_flag = 'N'
  AND      b.khr_id IS NOT NULL
  ORDER BY c.receipt_date;

  c_get_all_adv_rcpt_rec c_get_all_adv_rcpt%ROWTYPE;

  -------------------------------------------------------------------------------
/*
  -- get all regular and advanced receipts w/balance
  CURSOR   c_get_all_rcpt_dtls (cp_customer_num IN VARCHAR2) IS
  SELECT   b.amount,
           b.receipt_number,
           b.currency_code,
           a.ile_id,
           a.id,
           b.cash_receipt_id icr_id,
           b.pay_from_customer customer_number
  FROM     OKL_TRX_CSH_RECEIPT_V a,
           AR_CASH_RECEIPTS_ALL b,
           hz_cust_accounts_all hca
  WHERE    a.cash_receipt_id = b.cash_receipt_id
  AND      hca.account_number  = cp_customer_num
  AND      b.pay_from_customer = hca.cust_account_id
  AND      a.fully_applied_flag = 'N';

  c_get_all_rcpt_dtls_rec c_get_all_rcpt_dtls%ROWTYPE;*/

  -------------------------------------------------------------------------------

  -- get customer id from customer number
  -- replaced the reference ra_customers to hz_cust_accounts for bug#4891734
  CURSOR   c_get_cust_id(cp_customer_num IN VARCHAR2) IS
  SELECT   cust_account_id
  FROM     hz_cust_accounts
  WHERE    account_number = cp_customer_num;

  -------------------------------------------------------------------------------

  -- get all applied receipts for customer within date range
  CURSOR   c_get_csh_rcpt_id( cp_customer_id IN NUMBER
                             ,cp_receipt_date_from IN DATE
                             ,cp_receipt_date_to IN DATE
                             ,cp_receipt_currency IN VARCHAR2 ) IS
  SELECT   cash_receipt_id,
           currency_code,
           amount,
           receipt_date,
           receipt_number,
	   decode(currency_code,cp_receipt_currency,1,2) order_by_ccy
  FROM     AR_CASH_RECEIPTS
  WHERE    pay_from_customer = cp_customer_id
  AND      currency_code = decode(p_cross_currency_allowed,'N',cp_receipt_currency,currency_code)  --dkagrawa added decode for cross currency support
  AND      receipt_date >= cp_receipt_date_from
  AND      receipt_date <= cp_receipt_date_to
  ORDER BY order_by_ccy ASC;

  c_get_csh_rcpt_id_rec c_get_csh_rcpt_id%ROWTYPE;

  -------------------------------------------------------------------------------

  -- verify on account receipt amount
  CURSOR   c_ver_on_acct_amt(cp_csh_rcpt_id IN NUMBER) IS
  SELECT   (unapplied_amount + onaccount_amount) amount_available
  FROM     okl_receipt_Details_uv
  WHERE    cash_receipt_id = cp_csh_rcpt_id;

  -------------------------------------------------------------------------------

  -- get contract total
  CURSOR   c_open_invs (  cp_contract_num    IN VARCHAR2
                                     ,cp_customer_num    IN VARCHAR2
                                     ,cp_stream_type_id  IN NUMBER
                                     ,cp_currency_code   IN VARCHAR2) IS
  SELECT   lpt.sty_id
          ,lpt.amount_due_remaining
          ,lpt.currency_code
          ,lpt.ar_invoice_number
          ,lpt.trx_date
          ,lpt.customer_account_number
          ,lpt.customer_acct_id
          ,lpt.khr_id
          ,lpt.ar_invoice_id
          ,lpt.invoice_line_id
  FROM     okl_rcpt_cust_cont_balances_uv lpt
  WHERE    lpt.contract_number = cp_contract_num
  AND      lpt.customer_account_number = NVL (cp_customer_num,  lpt.customer_account_number)
  AND      lpt.sty_id = NVL (cp_stream_type_id, lpt.sty_id)
  AND      lpt.status = 'OP'
  AND      lpt.amount_due_remaining > 0
  AND      lpt.currency_code = decode(p_cross_currency_allowed,'N',cp_currency_code,lpt.currency_code);  --dkagrawa added decode for cross currency support

  c_open_invs_rec c_open_invs%ROWTYPE;

  -------------------------------------------------------------------------------

  CURSOR   c_get_rcpt_id ( cp_receipt_number in VARCHAR2
                          ,cp_customer_num in VARCHAR2) IS
  SELECT   a.cash_receipt_id icr_id
  FROM     AR_CASH_RECEIPTS a,
           hz_cust_Accounts_all hca
  WHERE    a.receipt_number = l_receipt_num
  AND      a.pay_from_customer = hca.cust_account_id
  AND      hca.account_number = cp_customer_num;

  -------------------------------------------------------------------------------

  -- get cash applic rule id
  CURSOR   c_cash_rle_id_csr ( cp_khr_id IN NUMBER) IS
  SELECT   to_number(a.object1_id1)
  FROM     OKC_RULES_B a, OKC_RULE_GROUPS_B b
  WHERE    a.rgp_id = b.id
  AND      b.rgd_code = 'LABILL'
  AND      a.rule_information_category = 'LAINVD'
  AND      a.dnz_chr_id = b.chr_id
  AND      a.dnz_chr_id = cp_khr_id;

  -------------------------------------------------------------------------------

  -- get cash applic rule for contract
  CURSOR   c_cash_rule_csr  ( cp_cau_id IN NUMBER ) IS
  SELECT   NUM_DAYS_HOLD_ADV_PAY
  FROM     OKL_CASH_ALLCTN_RLS
  WHERE    CAU_ID = cp_cau_id
  AND      START_DATE <= trunc(SYSDATE)
  AND     (END_DATE >= trunc(SYSDATE) OR END_DATE IS NULL);

  -------------------------------------------------------------------------------

  -- get default cash applic rule for organization
  CURSOR   c_dflt_cash_applic_rule IS
  SELECT   NUM_DAYS_HOLD_ADV_PAY
  FROM     OKL_CASH_ALLCTN_RLS
  WHERE    default_rule = 'YES'
  AND      TRUNC(end_date) IS NULL;

  CURSOR c_get_cust_Acct_num(cp_acct_id in number) IS
  SELECT account_number
  from hz_cust_accounts
  where cust_Account_id = cp_acct_id;
  -------------------------------------------------------------------------------

BEGIN
       log_file('reapplic_advanced_cash_app start');
       log_file('l_customer_acct_id = '||l_customer_acct_id);
       log_file('l_contract_num = '||l_contract_num);
       log_file('l_receipt_num = '||l_receipt_num);
       log_file('l_receipt_date_from = '||l_receipt_date_from);
       log_file('l_receipt_date_to = '||l_receipt_date_to);
        ------------------------------------------------------------
        -- Start processing
        ------------------------------------------------------------

        x_return_status := Okl_Api.G_RET_STS_SUCCESS;

        l_return_status := Okl_Api.START_ACTIVITY(
                p_api_name      => l_api_name,
                p_pkg_name      => G_PKG_NAME,
                p_init_msg_list => p_init_msg_list,
                l_api_version   => l_api_version,
                p_api_version   => p_api_version,
                p_api_type      => '_PVT',
                x_return_status => l_return_status);

        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

    -- get default cash application rule
        OPEN c_dflt_cash_applic_rule;
        FETCH c_dflt_cash_applic_rule INTO  l_dflt_days_to_hold_adv_pay;
        CLOSE c_dflt_cash_applic_rule;

        IF l_customer_acct_id IS NOT NULL THEN
         OPEN c_get_cust_Acct_num(l_customer_acct_id);
         FETCH c_get_cust_Acct_num INTO l_customer_num; -- HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE
         CLOSE c_get_cust_Acct_num;
        END IF;
      log_file('l_customer_num = '||l_customer_num);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '=================================================================================');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '    ** Start Processing. Please See Error Log for any errored transactions **    ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '=================================================================================');

    IF l_customer_num IS NULL AND
       l_contract_num IS NULL AND
       l_receipt_date_from IS NULL AND
       l_receipt_date_to IS NULL AND
       l_receipt_num IS NULL THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-------------------------------------');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'ERROR - No input parameters specified');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-------------------------------------');
        GOTO END_PROCESS;
    END IF;

    IF l_receipt_num IS NOT NULL AND l_contract_num IS NULL THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-----------------------------------------------------------');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'ERROR - You must specify a contract number to apply cash to');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-----------------------------------------------------------');
        GOTO END_PROCESS;
    END IF;

    IF l_customer_num IS NOT NULL AND (l_receipt_date_from IS NULL OR l_receipt_date_to IS NULL) THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-----------------------------------------------------------------');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'ERROR - You must specify start and end dates for receipt');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-----------------------------------------------------------------');
        GOTO END_PROCESS;
    END IF;

     IF l_customer_num IS NOT NULL AND (l_receipt_type IS NULL) THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-----------------------------------------------------------------');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'ERROR - You must specify Receipt Type');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-----------------------------------------------------------------');
        GOTO END_PROCESS;
    END IF;



    ---------------------------------------------------------------
    -- First do a clean up ...
        -- Find all expired receipts and make them available to all ...
    -- BEGIN CLEAN UP PROCESS
        ---------------------------------------------------------------

    log_file('clean up starts');
    FOR c_get_all_adv_rcpt_rec IN c_get_all_adv_rcpt
    LOOP
        l_temp_receipt_id   := c_get_all_adv_rcpt_rec.icr_id;
        l_rct_id            := c_get_all_adv_rcpt_rec.rct_id;
        l_temp_contract_id  := c_get_all_adv_rcpt_rec.khr_id;
        l_temp_rcpt_date    := c_get_all_adv_rcpt_rec.receipt_date;
        log_file('l_temp_receipt_id = '||l_temp_receipt_id);
        OPEN  c_ver_on_acct_amt(l_temp_receipt_id);
        FETCH c_ver_on_acct_amt INTO l_actual_remittance_amount;
        CLOSE c_ver_on_acct_amt;
        log_file('l_actual_remittance_amount = '||l_actual_remittance_amount);
        IF l_actual_remittance_amount > 0 THEN
            -- get cash application rule
            OPEN c_cash_rle_id_csr (l_temp_contract_id);
            FETCH c_cash_rle_id_csr INTO l_cau_id;
            CLOSE c_cash_rle_id_csr;

            IF l_cau_id IS NOT NULL THEN
                OPEN c_cash_rule_csr (l_cau_id);
                FETCH c_cash_rule_csr INTO  l_days_to_hold_adv_pay;
                CLOSE c_cash_rule_csr;

                IF l_days_to_hold_adv_pay IS NULL THEN
                    l_days_to_hold_adv_pay  := l_dflt_days_to_hold_adv_pay;
                END IF;
            ELSE -- use default rule
                l_days_to_hold_adv_pay  := l_dflt_days_to_hold_adv_pay;
            END IF;

            IF TRUNC(l_temp_rcpt_date) + l_days_to_hold_adv_pay < TRUNC(SYSDATE) THEN
                l_rctv_rec.expired_flag := 'Y';
            ELSE
                l_rctv_rec.expired_flag := 'N';
            END IF;

        END IF;

        IF l_actual_remittance_amount = 0 OR l_actual_remittance_amount IS NULL THEN
            l_rctv_rec.fully_applied_flag := 'Y';
            l_rctv_rec.expired_flag := 'Y';
        ELSE
            l_rctv_rec.fully_applied_flag := 'N';
        END IF;
        log_file('l_rctv_rec.fully_applied_flag = '||l_rctv_rec.fully_applied_flag);
        log_file('l_rctv_rec.expired_flag = '||l_rctv_rec.expired_flag);
        l_rctv_rec.id := l_rct_id;

        OKL_RCT_PVT.update_row( p_api_version   =>  l_api_version
                               ,p_init_msg_list =>  l_init_msg_list
                               ,x_return_status =>  l_return_status
                               ,x_msg_count     =>  l_msg_count
                               ,x_msg_data      =>  l_msg_data
                               ,p_rctv_rec      =>  l_rctv_rec
                               ,x_rctv_rec      =>  x_rctv_rec);

        x_return_status := l_return_status;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    END LOOP;

    ---------------------------------------------------------------
    -- END CLEAN UP PROCESS
        ---------------------------------------------------------------

    ---------------------------------------------------------------
    -- Then check for specified contract
        ---------------------------------------------------------------

    IF l_contract_num IS NOT NULL AND l_receipt_num IS NOT NULL THEN

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'CONTRACT NUMBER: '||l_contract_num);

        IF l_receipt_num IS NOT NULL THEN
          l_receipt_id := NULL;
          OPEN  c_get_rcpt_id(l_receipt_num, l_customer_num);
          FETCH c_get_rcpt_id INTO l_receipt_id;
          CLOSE c_get_rcpt_id;
        END IF;
        log_file('l_receipt_id = '||l_receipt_id);
        IF l_receipt_id IS NOT NULL THEN
          OPEN c_get_rcpt_dtls(l_receipt_id);
          FETCH c_get_rcpt_dtls INTO l_remittance_amount
                                    ,l_check_number
                                    ,l_receipt_currency
                                    ,l_receipt_date
                                    ,l_rct_id;
          CLOSE c_get_rcpt_dtls;
        END IF;

        FOR c_open_invs_rec IN c_open_invs (l_contract_num, NULL, NULL, l_receipt_currency)
        LOOP
            log_file('l_inv_tot = '||l_inv_tot);
            l_invoice_currency_code := c_open_invs_rec.currency_code;
            l_inv_tot := l_inv_tot + c_open_invs_rec.amount_due_remaining;
            l_customer_num := c_open_invs_rec.customer_account_number;
            l_customer_id := c_open_invs_rec.customer_acct_id;
            l_contract_id := c_open_invs_rec.khr_id;
        END LOOP;
        log_file('l_inv_tot = '||l_inv_tot);
        IF l_inv_tot  > 0 THEN
            IF l_receipt_id IS NOT NULL THEN

                OPEN  c_ver_on_acct_amt(l_receipt_id);
                FETCH c_ver_on_acct_amt INTO l_actual_remittance_amount;
                CLOSE c_ver_on_acct_amt;

                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'RECEIPT NUMBER: '||l_check_number);
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'RECEIPT AMOUNT: '||l_actual_remittance_amount);

                IF l_actual_remittance_amount = 0 THEN
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Receipt number '||l_check_number||' has a zero balance - Cash application cannot continue');
                    GOTO END_PROCESS;
                END IF;

                IF l_actual_remittance_amount <> l_remittance_amount THEN
                    l_remittance_amount := l_actual_remittance_amount;
                END IF;
                log_file('l_remittance_amount ='||l_remittance_amount);
		--following code added by dkagrawa for cross currency
		IF l_invoice_currency_code <> l_receipt_currency THEN
                  l_exchange_rate_type := OKL_RECEIPTS_PVT.cross_currency_rate_type(l_org_id);--FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                  IF l_exchange_rate_type IS  NULL THEN
                    OKL_API.set_message( p_app_name      => G_APP_NAME
                                        ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                       );
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                  ELSE
                    l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_invoice_currency_code
                                                                               ,l_receipt_currency
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
                  l_inv_tot := l_inv_tot*l_conversion_rate;
                END IF;
                IF l_inv_tot <=  l_remittance_amount THEN

                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'No cash application rules required.  Balance of contract is less than or equal to receipt amount');
                    log_file('calling apply_rcpt_to_contract_no_rule');
                    apply_rcpt_to_contract_no_rule ( p_api_version        => l_api_version
                                                        ,p_init_msg_list      => l_init_msg_list
                                                        ,x_return_status      => l_return_status
                                                        ,x_msg_count              => l_msg_count
                                                        ,x_msg_data           => l_msg_data
                                                    ,p_contract_id        => l_contract_id
                                                    ,p_contract_num       => l_contract_num
                                                    ,p_customer_id        => l_customer_id
--                                                    ,p_customer_num       => l_customer_num
                                                    ,p_customer_num       => p_customer_num -- cklee 7036445-- note: p_customer_num = HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID indeed
                                                    ,p_receipt_id         => l_receipt_id
                                                    ,p_receipt_amount     => l_remittance_amount
                                                    ,p_remain_rcpt_amount => l_remain_rcpt_amount
                                                    ,p_receipt_currency   => l_receipt_currency
                                                    ,p_receipt_date       => l_receipt_date
                                                    ,p_invoice_currency   => l_invoice_currency_code
                                                    ,p_xcr_id             => l_rct_id
						    ,p_cross_currency_allowed => l_cross_currency_allowed
                                                   );
                 log_file('l_return_status ='||l_return_status);
                ELSIF l_inv_tot > l_remittance_amount THEN

                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Cash application rule required.  Balance of contract is greater than receipt amount');
                    log_file('calling apply_rcpt_to_contract_w_rule');
                    apply_rcpt_to_contract_w_rule  ( p_api_version        => l_api_version
                                                        ,p_init_msg_list      => l_init_msg_list
                                                        ,x_return_status      => l_return_status
                                                        ,x_msg_count              => l_msg_count
                                                        ,x_msg_data           => l_msg_data
                                                    ,p_contract_id        => l_contract_id
                                                    ,p_contract_num       => l_contract_num
                                                    ,p_customer_id        => l_customer_id
--                                                    ,p_customer_num       => l_customer_num
                                                    ,p_customer_num       => p_customer_num -- cklee 7036445-- note: p_customer_num = HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID indeed
                                                    ,p_receipt_id         => l_receipt_id
                                                    ,p_receipt_amount     => l_remittance_amount
                                                    ,p_remain_rcpt_amount => l_remain_rcpt_amount
                                                    ,p_receipt_currency   => l_receipt_currency
                                                    ,p_receipt_date       => l_receipt_date
                                                    ,p_invoice_currency   => l_invoice_currency_code
                                                    ,p_xcr_id             => l_rct_id
						    ,p_cross_currency_allowed => l_cross_currency_allowed
                                                  );
                 log_file('l_return_status ='||l_return_status);
                END IF;

                x_return_status := l_return_status;

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                log_file('l_remain_rcpt_amount = '||l_remain_rcpt_amount);
                IF l_remain_rcpt_amount <> l_actual_remittance_amount THEN -- application took place, move to next contract ...

                    l_stat_total_rcpt_amt := l_stat_total_rcpt_amt + (l_actual_remittance_amount - l_remain_rcpt_amount);
                    l_stat_num_of_rcpts := l_stat_num_of_rcpts + 1;
                    l_stat_num_of_cont := l_stat_num_of_cont + 1;

                END IF;

                IF l_remain_rcpt_amount > 0 THEN
                    l_rctv_rec.FULLY_APPLIED_FLAG := 'N';
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Receipt number '||l_check_number||' has been partially applied.');
                ELSE
                    l_rctv_rec.FULLY_APPLIED_FLAG := 'Y';
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Receipt number '||l_check_number||' has been fully applied.');
                END IF;
                -- commented out for testing purposes.
                -------------------------------------------------------------------
                -- COMMIT; -- Need to commit here to update balance of contract ...
                -------------------------------------------------------------------

                GOTO END_PROCESS;

            ELSE -- we just have contract_number w/no receipt amount
               log_file('CALLING advanced_cash_app ');
                advanced_cash_app ( p_api_version    => l_api_version
                                   ,p_init_msg_list  => l_init_msg_list
                                   ,x_return_status  => l_return_status
                                   ,x_msg_count      => l_msg_count
                                   ,x_msg_data       => l_msg_data
                                   ,p_contract_num   => l_contract_num
--                                   ,p_customer_num   => l_customer_num
                                   ,p_customer_num   => p_customer_num -- cklee 7036445-- note: p_customer_num = HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID indeed
                                   ,p_receipt_num    => null
				   ,p_cross_currency_allowed => l_cross_currency_allowed
                                  );
                log_file('l_return_status = '||l_return_status);
                x_return_status := l_return_status;

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

            END IF;
        ELSE
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'CONTRACT NUMBER: '||l_contract_num ||' has no balance.');
        END IF; -- IF l_inv_tot > 0
        GOTO END_PROCESS;

    END IF;  -- if we have contract number

    IF (l_customer_num IS NOT NULL AND l_receipt_type = 'ADV') OR
       (l_customer_num IS NULL AND l_contract_num IS NOT NULL)
    THEN

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'CUSTOMER NUMBER: '||l_customer_num);

        FOR c_get_cont_for_cust_rec IN c_get_cont_for_cust (l_customer_num, l_contract_num)
        LOOP

            l_contract_num := c_get_cont_for_cust_rec.contract_number;
            l_contract_id  := c_get_cont_for_cust_rec.khr_id;
            l_customer_num := c_get_cont_for_cust_rec.customer_account_number;

            advanced_cash_app ( p_api_version    => l_api_version
	                           ,p_init_msg_list  => l_init_msg_list
	                           ,x_return_status  => l_return_status
	                           ,x_msg_count	     => l_msg_count
	                           ,x_msg_data	     => l_msg_data
                               ,p_contract_num   => l_contract_num
--                               ,p_customer_num   => l_customer_num
                               ,p_customer_num   => p_customer_num -- cklee 7036445-- note: p_customer_num = HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID indeed
                               ,p_receipt_num    => l_receipt_num
			       ,p_cross_currency_allowed => l_cross_currency_allowed
                              );

            x_return_status := l_return_status;

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        END LOOP;

        GOTO END_PROCESS;

    END IF;

    IF l_customer_num IS NOT NULL  AND l_receipt_type = 'ALL' THEN

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'CUSTOMER NUMBER: '||l_customer_num);

            -- get contract details first, then loop through receipts  report all events on form

            OPEN  c_get_cust_id(l_customer_num);
            FETCH c_get_cust_id INTO l_customer_id;-- note: HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID
            CLOSE c_get_cust_id;
            log_file('l_customer_id = '||l_customer_id);-- note: HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID
            FOR c_get_cont_for_cust_rec IN c_get_cont_for_cust (l_customer_num, l_contract_num)
            LOOP

                l_contract_num := c_get_cont_for_cust_rec.contract_number;
                l_contract_id  := c_get_cont_for_cust_rec.khr_id;
                log_file('l_contract_num = '||l_contract_num);
                l_inv_tot := 0;
                FOR c_open_invs_rec IN c_open_invs (l_contract_num, l_customer_num, NULL, c_get_cont_for_cust_rec.currency_code)
                LOOP
                    l_invoice_currency_code := c_open_invs_rec.currency_code;
                    l_inv_tot := l_inv_tot + c_open_invs_rec.amount_due_remaining;
                END LOOP;
                log_file('l_inv_tot = '||l_inv_tot);
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '---------------');
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'CONTRACT NUMBER:  '||l_contract_num|| ' located for cash application ');
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'CONTRACT BALANCE: '||l_inv_tot);
                IF l_inv_tot = 0 THEN
                  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-----------------------------------------------------------------------------');
                  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Following contract has a balance of zero -- unable to apply receipts');
                  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, l_contract_num);
                  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-----------------------------------------------------------------------------');
                END IF;
                IF l_inv_tot > 0 THEN
                  FOR c_get_csh_rcpt_id_rec IN c_get_csh_rcpt_id (l_customer_id, l_receipt_date_from, l_receipt_date_to, l_invoice_currency_code)
                  LOOP

                    l_exit_loop := 0;

                    l_receipt_id         := c_get_csh_rcpt_id_rec.cash_receipt_id;
                    l_receipt_date       := c_get_csh_rcpt_id_rec.receipt_date;
                    l_receipt_currency   := c_get_csh_rcpt_id_rec.currency_code;
                    l_check_number       :=  c_get_csh_rcpt_id_rec.receipt_number;
                    log_file('l_receipt_id = '||l_receipt_id);
                    log_file('l_check_number = '|| l_check_number);
                    OPEN  c_ver_on_acct_amt(l_receipt_id);
                    FETCH c_ver_on_acct_amt INTO l_actual_remittance_amount;
                    CLOSE c_ver_on_acct_amt;

                    l_remittance_amount := l_actual_remittance_amount;
                    log_file('l_remittance_amount = '||l_remittance_amount);
                    IF l_actual_remittance_amount > 0 THEN

                        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'RECEIPT '||l_check_number|| '  located with balance of '||l_actual_remittance_amount||' '||l_receipt_currency);
                        IF l_invoice_currency_code <> l_receipt_currency THEN
                          l_exchange_rate_type :=OKL_RECEIPTS_PVT.cross_currency_rate_type(l_org_id);-- FND_PROFILE.value('AR_CROSS_CURRENCY_RATE_TYPE');
                          IF l_exchange_rate_type IS  NULL THEN
                            OKL_API.set_message( p_app_name      => G_APP_NAME
                                                ,p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                               );
                            RAISE G_EXCEPTION_HALT_VALIDATION;
                          ELSE
                            l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_invoice_currency_code
                                                                                       ,l_receipt_currency
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
                         l_inv_tot := l_inv_tot*l_conversion_rate;
                       END IF;
                       IF l_inv_tot <=  l_actual_remittance_amount THEN
                            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'No cash application rules required.  Balance of contract is less than or equal to receipt amount');
                            log_file('calling apply_rcpt_to_contract_no_rule ');
                            apply_rcpt_to_contract_no_rule ( p_api_version        => l_api_version
                                                            ,p_init_msg_list      => l_init_msg_list
                                                            ,x_return_status      => l_return_status
                                                            ,x_msg_count          => l_msg_count
                                                            ,x_msg_data           => l_msg_data
                                                            ,p_contract_id        => l_contract_id
                                                            ,p_contract_num       => l_contract_num
                                                            ,p_customer_id        => l_customer_id
--                                                            ,p_customer_num       => l_customer_num
                                                            ,p_customer_num       => p_customer_num -- cklee 7036445
                                                            ,p_receipt_id         => l_receipt_id
                                                            ,p_receipt_amount     => l_remittance_amount
                                                            ,p_remain_rcpt_amount => l_remain_rcpt_amount
                                                            ,p_receipt_currency   => l_receipt_currency
                                                            ,p_receipt_date       => l_receipt_date
                                                            ,p_invoice_currency   => l_invoice_currency_code
                                                            ,p_currency_conv_date => l_currency_conv_date
                                                            ,p_currency_conv_rate => l_currency_conv_rate
                                                            ,p_currency_conv_type => l_currency_conv_type
                                                            ,p_xcr_id             => l_xcr_id
							    ,p_cross_currency_allowed => l_cross_currency_allowed
                                                            );


                      ELSIF l_inv_tot > l_actual_remittance_amount THEN

                            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Cash application rule required.  Balance of contract is greater than receipt amount');
                            log_file('calling apply_rcpt_to_contract_w_rule');
                            apply_rcpt_to_contract_w_rule  ( p_api_version        => l_api_version
                                                            ,p_init_msg_list      => l_init_msg_list
                                                            ,x_return_status      => l_return_status
                                                            ,x_msg_count          => l_msg_count
                                                            ,x_msg_data           => l_msg_data
                                                            ,p_contract_id        => l_contract_id
                                                            ,p_contract_num       => l_contract_num
                                                            ,p_customer_id        => l_customer_id
--                                                            ,p_customer_num       => l_customer_num
                                                            ,p_customer_num       => p_customer_num -- cklee 7036445
                                                            ,p_receipt_id         => l_receipt_id
                                                            ,p_receipt_amount     => l_remittance_amount
                                                            ,p_remain_rcpt_amount => l_remain_rcpt_amount
                                                            ,p_receipt_currency   => l_receipt_currency
                                                            ,p_receipt_date       => l_receipt_date
                                                            ,p_invoice_currency   => l_invoice_currency_code
                                                            ,p_currency_conv_date => l_currency_conv_date
                                                            ,p_currency_conv_rate => l_currency_conv_rate
                                                            ,p_currency_conv_type => l_currency_conv_type
                                                            ,p_xcr_id             => l_xcr_id
							    ,p_cross_currency_allowed => l_cross_currency_allowed
                                                            );

                        END IF;
                        log_file('l_return_status = '||l_return_status);
                        x_return_status := l_return_status;

                        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;
                        log_file('l_remain_rcpt_amount = '||l_remain_rcpt_amount);
                        IF l_remain_rcpt_amount <> l_actual_remittance_amount THEN -- application took place, move to next contract ...

                            l_stat_total_rcpt_amt := l_stat_total_rcpt_amt + (l_actual_remittance_amount - l_remain_rcpt_amount);
                            l_stat_num_of_rcpts := l_stat_num_of_rcpts + 1;
                            l_stat_num_of_cont := l_stat_num_of_cont + 1;
                        END IF;
			l_inv_tot := 0;
                        FOR c_open_invs_rec IN c_open_invs (l_contract_num, l_customer_num, NULL, c_get_cont_for_cust_rec.currency_code)
                        LOOP
                          l_invoice_currency_code := c_open_invs_rec.currency_code;
                          l_inv_tot := l_inv_tot + c_open_invs_rec.amount_due_remaining;
                        END LOOP;
	                IF l_inv_tot = 0 THEN
                          l_exit_loop := 1;
                        END IF;
                        EXIT WHEN l_exit_loop = 1;
                      END IF; --check remittance amount
                    END LOOP; -- receipt loop
   	          END IF;  --check if inv_total>0
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

            END LOOP; -- contract loop

     --   END IF;

    END IF;

    <<END_PROCESS>>

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '====================================================================================');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Total number of receipts processed: '||l_stat_num_of_rcpts);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Total of receipt amounts: '||l_stat_total_rcpt_amt);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Total number of contracts that received cash application: '||l_stat_num_of_cont);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '====================================================================================');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'PROCESS COMPLETE: '||SYSDATE);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '====================================================================================');

        ------------------------------------------------------------
        -- End processing
        ------------------------------------------------------------

        Okl_Api.END_ACTIVITY (
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);

     log_file('reapplic_advanced_cash_app end');
EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := okl_api.G_RET_STS_ERROR;


    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        OKL_API.G_RET_STS_ERROR,
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
    x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

END reapplic_advanced_cash_app;

PROCEDURE reapplic_rcpt_w_cntrct   ( p_api_version       IN  NUMBER
                                    ,p_init_msg_list     IN  VARCHAR2 DEFAULT okl_api.G_FALSE
                                    ,x_return_status     OUT NOCOPY VARCHAR2
                                    ,x_msg_count         OUT NOCOPY NUMBER
                                    ,x_msg_data          OUT NOCOPY VARCHAR2
                                    ,p_contract_num      IN  VARCHAR2 DEFAULT NULL
                                    ,p_customer_num      IN  NUMBER DEFAULT NULL
				    ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                   )IS

  l_api_version                 NUMBER := 1.0;
  l_init_msg_list                       VARCHAR2(1) := okl_api.g_false;
  l_return_status                       VARCHAR2(1);
  l_msg_count                           NUMBER;
  l_msg_data                            VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'reapplic_rcpt_w_cntrct';

  l_remittance_amount           AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE;
  l_remain_rcpt_amount          AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE;
  l_check_number                OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE;
  l_actual_remittance_amount    AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE;
  l_on_account_bal              AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE;
  l_receipt_currency            OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE;
  l_receipt_count               NUMBER;

  l_dflt_days_to_hold_adv_pay   OKL_CASH_ALLCTN_RLS.NUM_DAYS_HOLD_ADV_PAY%TYPE;
  l_days_to_hold_adv_pay        OKL_CASH_ALLCTN_RLS.NUM_DAYS_HOLD_ADV_PAY%TYPE;

  l_contract_id                 OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL;
  l_contract_num                OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT p_contract_num;
  l_customer_num                HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE DEFAULT NULL;
  l_customer_acct_id            NUMBER DEFAULT p_customer_num;
  l_cross_currency_allowed      VARCHAR2(1) DEFAULT p_cross_currency_allowed;

  l_temp_contract_id            OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL;
  l_temp_receipt_id             AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL;
  l_temp_rcpt_date              AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT NULL;

  l_xcr_id                      NUMBER;
  l_rct_id                      OKL_TRX_CSH_RECEIPT_V.ID%TYPE;
  l_rca_id                                  OKL_TXL_RCPT_APPS_V.ID%TYPE;
  l_cat_id                      OKL_CASH_ALLCTN_RLS.ID%TYPE DEFAULT NULL;
  l_cau_id                      OKL_CSH_ALLCTN_RL_HDR.ID%TYPE DEFAULT NULL;

  l_stat_total_rcpt_amt         OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT 0;
  l_stat_num_of_rcpts           NUMBER DEFAULT 0;
  l_stat_num_of_cont            NUMBER DEFAULT 0;


  -------------------------------------------------------------------------------
  -- DECLARE Record/Table Types
  -------------------------------------------------------------------------------
  -- Internal Trans

  l_rctv_rec Okl_Rct_Pvt.rctv_rec_type;
  l_rctv_tbl Okl_Rct_Pvt.rctv_tbl_type;

  l_rcav_rec Okl_Rca_Pvt.rcav_rec_type;
  l_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;

  x_rctv_rec Okl_Rct_Pvt.rctv_rec_type;
  x_rctv_tbl Okl_Rct_Pvt.rctv_tbl_type;

  x_rcav_rec Okl_Rca_Pvt.rcav_rec_type;
  x_rcav_tbl Okl_Rca_Pvt.rcav_tbl_type;

  -- External Trans

  l_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;
  l_xcrv_tbl Okl_Xcr_Pvt.xcrv_tbl_type;

  l_xcav_rec Okl_Xca_Pvt.xcav_rec_type;
  l_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

  x_xcrv_rec Okl_Xcr_Pvt.xcrv_rec_type;
  x_xcrv_tbl Okl_Xcr_Pvt.xcrv_tbl_type;

  x_xcav_rec Okl_Xca_Pvt.xcav_rec_type;
  x_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

  t_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

  -------------------------------------------------------------------------------
  -- DEFINE CURSORS
  -------------------------------------------------------------------------------

  -- get all unapplied advanced receipts
  CURSOR   c_get_all_adv_rcpt IS
  SELECT   DISTINCT(a.cash_receipt_id) icr_id,
           a.id RCT_ID,
           c.receipt_date,
           b.khr_id
  FROM     OKL_TRX_CSH_RECEIPT_V a, OKL_TXL_RCPT_APPS_V b, AR_CASH_RECEIPTS_ALL c
  WHERE    a.id = b.rct_id_details
  AND      a.cash_receipt_id = c.cash_receipt_id
  AND      a.FULLY_APPLIED_FLAG = 'N'
  AND      a.receipt_type = 'ADV'
  AND      a.expired_flag = 'N'
  AND      b.khr_id IS NOT NULL
  ORDER BY c.receipt_date;

  c_get_all_adv_rcpt_rec c_get_all_adv_rcpt%ROWTYPE;

  -------------------------------------------------------------------------------

  -- verify on account receipt amount
  CURSOR   c_ver_on_acct_amt(cp_csh_rcpt_id IN NUMBER) IS
  SELECT   (unapplied_amount + onaccount_amount) amount_available
  FROM     okl_receipt_Details_uv
  WHERE    cash_receipt_id = cp_csh_rcpt_id;


  -------------------------------------------------------------------------------

  -- get cash applic rule id
  CURSOR   c_cash_rle_id_csr ( cp_khr_id IN NUMBER) IS
  SELECT   to_number(a.object1_id1)
  FROM     OKC_RULES_B a, OKC_RULE_GROUPS_B b
  WHERE    a.rgp_id = b.id
  AND      b.rgd_code = 'LABILL'
  AND      a.rule_information_category = 'LAINVD'
  AND      a.dnz_chr_id = b.chr_id
  AND      a.dnz_chr_id = cp_khr_id;

  -------------------------------------------------------------------------------

  -- get cash applic rule for contract
  CURSOR   c_cash_rule_csr  ( cp_cau_id IN NUMBER ) IS
  SELECT   NUM_DAYS_HOLD_ADV_PAY
  FROM     OKL_CASH_ALLCTN_RLS
  WHERE    CAU_ID = cp_cau_id
  AND      START_DATE <= trunc(SYSDATE)
  AND     (END_DATE >= trunc(SYSDATE) OR END_DATE IS NULL);

  -------------------------------------------------------------------------------

  -- get open contracts for customer
  CURSOR   c_get_cont_for_cust(cp_customer_num IN VARCHAR2,
                               cp_receipt_currency IN VARCHAR2) IS
  SELECT   DISTINCT(lpt.contract_number),
           lpt.khr_id,
           lpt.start_date
  FROM     okl_rcpt_cust_cont_balances_uv lpt
  WHERE    lpt.customer_account_number = cp_customer_num
  AND      lpt.status = 'OP'
  AND      lpt.amount_due_remaining > 0
  AND      lpt.currency_code = NVL (cp_receipt_currency,lpt.currency_code)
  AND      lpt.org_id = mo_global.get_current_org_id
  ORDER BY lpt.start_date;

  c_get_cont_for_cust_rec c_get_cont_for_cust%ROWTYPE;

  -------------------------------------------------------------------------------

  -- nikshah -- Bug # 5484903 Fixed,
  -- Changed CURSOR c_open_invs SQL definition
    -- get contract total
  CURSOR   c_open_invs (  cp_contract_num        IN VARCHAR2) IS
  SELECT  lpt.customer_account_number
  FROM     okl_rcpt_cust_cont_balances_uv lpt
  WHERE    lpt.contract_number = cp_contract_num
  AND      lpt.status = 'OP'
  AND      lpt.amount_due_remaining > 0
  AND rownum < 2;

  c_open_invs_rec c_open_invs%ROWTYPE;

   -- get default cash applic rule for organization
  CURSOR   c_dflt_cash_applic_rule IS
  SELECT   NUM_DAYS_HOLD_ADV_PAY
  FROM     OKL_CASH_ALLCTN_RLS
  WHERE    default_rule = 'YES'
  AND      TRUNC(end_date) IS NULL;

  CURSOR c_get_cust_Acct_num(cp_acct_id in number) IS
  SELECT account_number
  from hz_cust_accounts
  where cust_Account_id = cp_acct_id;

  -------------------------------------------------------------------------------

BEGIN
    log_file('reapplic_rcpt_w_cntrct');
    log_file('l_customer_num = '||l_customer_num);
    log_file('l_contract_num = '||l_contract_num);
        ------------------------------------------------------------
        -- Start processing
        ------------------------------------------------------------

        x_return_status := Okl_Api.G_RET_STS_SUCCESS;

        l_return_status := Okl_Api.START_ACTIVITY(
                p_api_name      => l_api_name,
                p_pkg_name      => G_PKG_NAME,
                p_init_msg_list => p_init_msg_list,
                l_api_version   => l_api_version,
                p_api_version   => p_api_version,
                p_api_type      => '_PVT',
                x_return_status => l_return_status);

        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

    IF l_customer_acct_id IS NULL AND
       l_contract_num IS NULL THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-------------------------------------');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'ERROR - No input parameters specified');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-------------------------------------');
        GOTO END_PROCESS;
    END IF;

     IF l_customer_acct_id IS NOT NULL THEN
         OPEN c_get_cust_Acct_num(l_customer_acct_id);
         FETCH c_get_cust_Acct_num INTO l_customer_num;
         CLOSE c_get_cust_Acct_num;
     END IF;

    -- get default cash application rule
    OPEN c_dflt_cash_applic_rule;
    FETCH c_dflt_cash_applic_rule INTO  l_dflt_days_to_hold_adv_pay;
    CLOSE c_dflt_cash_applic_rule;

    log_file('l_dflt_days_to_hold_adv_pay = '||l_dflt_days_to_hold_adv_pay);
    ---------------------------------------------------------------
    -- First do a clean up ...
        -- Find all expired receipts and make them available to all ...
    -- BEGIN CLEAN UP PROCESS
        ---------------------------------------------------------------


    FOR c_get_all_adv_rcpt_rec IN c_get_all_adv_rcpt
    LOOP

        l_temp_receipt_id   := c_get_all_adv_rcpt_rec.icr_id;
        log_file('l_temp_receipt_id = '||l_temp_receipt_id);
     --   l_xcr_id            := c_get_all_adv_rcpt_rec.xcr_id;
        l_rct_id            := c_get_all_adv_rcpt_rec.rct_id;
        l_temp_contract_id  := c_get_all_adv_rcpt_rec.khr_id;
        l_temp_rcpt_date    := c_get_all_adv_rcpt_rec.receipt_date;

        OPEN  c_ver_on_acct_amt(l_temp_receipt_id);
        FETCH c_ver_on_acct_amt INTO l_actual_remittance_amount;
        CLOSE c_ver_on_acct_amt;
        log_file('l_actual_remittance_amount = '||l_actual_remittance_amount);
        IF l_actual_remittance_amount > 0 THEN

            -- get cash application rule
            OPEN c_cash_rle_id_csr (l_temp_contract_id);
            FETCH c_cash_rle_id_csr INTO l_cau_id;
            CLOSE c_cash_rle_id_csr;

            IF l_cau_id IS NOT NULL THEN
                OPEN c_cash_rule_csr (l_cau_id);
                FETCH c_cash_rule_csr INTO  l_days_to_hold_adv_pay;
                CLOSE c_cash_rule_csr;

                IF l_days_to_hold_adv_pay IS NULL THEN
                    l_days_to_hold_adv_pay  := l_dflt_days_to_hold_adv_pay;
                END IF;
            ELSE -- use default rule
                l_days_to_hold_adv_pay  := l_dflt_days_to_hold_adv_pay;
            END IF;

            IF TRUNC(l_temp_rcpt_date) + l_days_to_hold_adv_pay < TRUNC(SYSDATE) THEN
                l_rctv_rec.expired_flag := 'Y';
            ELSE
                l_rctv_rec.expired_flag := 'N';
            END IF;

        END IF;

        IF l_actual_remittance_amount = 0 OR l_actual_remittance_amount IS NULL THEN
            l_rctv_rec.fully_applied_flag := 'Y';
            l_rctv_rec.expired_flag := 'Y';
        ELSE
            l_rctv_rec.fully_applied_flag := 'N';
        END IF;

        l_rctv_rec.id := l_rct_id;
        log_file('l_rctv_rec.id = '||l_rctv_rec.id);
        log_file('l_rctv_rec.fully_applied_flag = '||l_rctv_rec.fully_applied_flag);
        log_file('l_rctv_rec.expired_flag = '||l_rctv_rec.expired_flag);
        OKL_RCT_PVT.update_row( p_api_version   =>  l_api_version
                               ,p_init_msg_list =>  l_init_msg_list
                               ,x_return_status =>  l_return_status
                               ,x_msg_count     =>  l_msg_count
                               ,x_msg_data      =>  l_msg_data
                               ,p_rctv_rec      =>  l_rctv_rec
                               ,x_rctv_rec      =>  x_rctv_rec);
        SELECT count(id) INTO l_rct_id
        FROM okl_trx_csh_rcpt_all_b
        WHERE receipt_type= 'ADV';
        log_file('after update adv count = '|| l_rct_id);
        x_return_status := l_return_status;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    END LOOP;

     SELECT count(id) INTO l_rct_id
        FROM okl_trx_csh_rcpt_all_b
        WHERE receipt_type= 'ADV';
        log_file('*** adv count = '|| l_rct_id);
    FOR c_get_all_adv_rcpt_rec IN c_get_all_adv_rcpt
    LOOP
      log_file('c_get_all_adv_rcpt_rec.icr_id = '||c_get_all_adv_rcpt_rec.icr_id);
    END LOOP;
    ---------------------------------------------------------------
    -- END CLEAN UP PROCESS
        ---------------------------------------------------------------

    IF l_contract_num IS NOT NULL THEN

        IF l_customer_num IS NULL THEN

            OPEN c_open_invs (l_contract_num);
            FETCH c_open_invs INTO l_customer_num;
            CLOSE c_open_invs;

            IF l_customer_num IS NULL THEN
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'CONTRACT '||l_contract_num|| 'HAS NO OPEN INVOICES - EXITING PROCESS ... ');
                GOTO END_PROCESS;
            END IF;

        END IF;
        log_file('calling advanced_cash_app');
        advanced_cash_app ( p_api_version    => l_api_version
                           ,p_init_msg_list  => l_init_msg_list
                           ,x_return_status  => l_return_status
                           ,x_msg_count          => l_msg_count
                           ,x_msg_data           => l_msg_data
                           ,p_contract_num   => l_contract_num
--                           ,p_customer_num   => l_customer_num
                           ,p_customer_num   => p_customer_num -- cklee 7036445
                           ,p_receipt_num    => NULL
			   ,p_cross_currency_allowed => l_cross_currency_allowed
                          );

        x_return_status := l_return_status;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    ELSE

        FOR c_get_cont_for_cust_rec IN c_get_cont_for_cust (l_customer_num, NULL)
        LOOP

            l_contract_num := c_get_cont_for_cust_rec.contract_number;
            l_contract_id  := c_get_cont_for_cust_rec.khr_id;
            log_file('l_contract_id = '||l_contract_id);
            log_file('l_contract_num ='||l_contract_num);
            log_file('advanced_cash_app');
            advanced_cash_app ( p_api_version    => l_api_version
                               ,p_init_msg_list  => l_init_msg_list
                               ,x_return_status  => l_return_status
                               ,x_msg_count      => l_msg_count
                               ,x_msg_data       => l_msg_data
                               ,p_contract_num   => l_contract_num
--                               ,p_customer_num   => l_customer_num
                               ,p_customer_num   => p_customer_num -- cklee 7036445
                               ,p_receipt_num    => NULL
			       ,p_cross_currency_allowed => l_cross_currency_allowed
                              );

            x_return_status := l_return_status;

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        END LOOP;

        GOTO END_PROCESS;

    END IF;

    <<END_PROCESS>>

        ------------------------------------------------------------
        -- End processing
        ------------------------------------------------------------

        Okl_Api.END_ACTIVITY (
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);
     log_file('end reapplic_rcpt_w_cntrct');

EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := okl_api.G_RET_STS_ERROR;


    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        OKL_API.G_RET_STS_ERROR,
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
        x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

END reapplic_rcpt_w_cntrct;
/*

PROCEDURE REAPPLIC_RCPT_W_CNTRCT_CONC  (  errbuf  		       OUT NOCOPY VARCHAR2
                                         ,retcode 		       OUT NOCOPY NUMBER
                                         ,p_contract_num       IN  VARCHAR2 DEFAULT NULL
                                         ,p_customer_acct_id       IN  NUMBER DEFAULT NULL
                                         ) IS

  l_api_version     NUMBER := 1;
  l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_msg_count     	NUMBER;
  l_msg_data    	VARCHAR2(450);
  l_init_msg_list   VARCHAR2(1) := 'T';

  l_msg_index_out   NUMBER :=0;
  l_error_msg_rec   Okl_Accounting_Util.Error_message_Type;

  l_contract_num            VARCHAR2(250) := p_contract_num;
  l_customer_acct_id        NUMBER := p_customer_acct_id;

  l_request_id      NUMBER;
  l_data                varchar2(2000);


  CURSOR req_id_csr IS
  SELECT DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID)
  FROM dual;

BEGIN

    -- Get the request Id
    l_request_id := NULL;
    OPEN  req_id_csr;
    FETCH req_id_csr INTO l_request_id;
    CLOSE req_id_csr;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Process Advanced Monies');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date: '||SYSDATE||' Request Id: '||l_request_id);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'PARAMETERS');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Contract Number = ' ||l_contract_num);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Customer Account Id = ' ||l_customer_acct_id);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
     log_file('calling reapplic_rcpt_w_cntrct');
	reapplic_rcpt_w_cntrct (  p_api_version    => l_api_version
	                         ,p_init_msg_list  => l_init_msg_list
	                         ,x_return_status  => l_return_status
	                         ,x_msg_count	    => l_msg_count
	                         ,x_msg_data	    => l_msg_data
                                 ,p_contract_num   => l_contract_num
                                 ,p_customer_num   => l_customer_acct_id
                                 );
          log_file('l_return_status= '||l_return_status);
         IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          fnd_file.put_line(fnd_file.log
                           ,'Unexpected error in call to OKL_BPD_ADVANCED_CASH_APP_PUB.REAPPLIC_RCPT_W_CNTRCT');
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          fnd_file.put_line(fnd_file.log
                           ,'Error in call to OKL_BPD_ADVANCED_CASH_APP_PUB.REAPPLIC_RCPT_W_CNTRCT');
        END IF;



    BEGIN

        Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
            FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
            LOOP
                FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
                FND_FILE.PUT_LINE (FND_FILE.LOG, '----------------------------------------------------------------------------');
            END LOOP;
        END IF;

    EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
    END;
    retcode := 0;
EXCEPTION
          WHEN okl_api.g_exception_error THEN
        retcode := 2;
       -- print the error message in the output file

        IF (fnd_msg_pub.count_msg > 0) THEN

          FOR l_counter IN 1..fnd_msg_pub.count_msg LOOP
            fnd_msg_pub.get(p_msg_index     =>  l_counter
                           ,p_encoded       =>  'F'
                           ,p_data          =>  l_data
                           ,p_msg_index_out =>  l_msg_index_out);
            fnd_file.put_line(fnd_file.log, l_data);
          END LOOP;

        END IF;

      WHEN okl_api.g_exception_unexpected_error THEN
        retcode := 2;

        -- print the error message in the output file

        IF (fnd_msg_pub.count_msg > 0) THEN

          FOR l_counter IN 1..fnd_msg_pub.count_msg LOOP
            fnd_msg_pub.get(p_msg_index     =>  l_counter
                           ,p_encoded       =>  'F'
                           ,p_data          =>  l_data
                           ,p_msg_index_out =>  l_msg_index_out);
            fnd_file.put_line(fnd_file.log, l_data);
          END LOOP;

        END IF;

      WHEN OTHERS THEN
        retcode := 2;
        errbuf := sqlerrm;

        -- print the error message in the output file

        IF (fnd_msg_pub.count_msg > 0) THEN

          FOR l_counter IN 1..fnd_msg_pub.count_msg LOOP
            fnd_msg_pub.get(p_msg_index     =>  l_counter
                           ,p_encoded       =>  'F'
                           ,p_data          =>  l_data
                           ,p_msg_index_out =>  l_msg_index_out);
            fnd_file.put_line(fnd_file.log, l_data);
          END LOOP;

        END IF;
        fnd_file.put_line(fnd_file.log, sqlerrm);
END REAPPLIC_RCPT_W_CNTRCT_CONC;
*/
---------------------------------------------------------------------------
-- PROCEDURE AR_advance_receipt
-- This routine handles receivables interaction.
---------------------------------------------------------------------------

PROCEDURE AR_advance_receipt     (   p_api_version       IN  NUMBER
	                                ,p_init_msg_list     IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE
	                                ,x_return_status     OUT NOCOPY VARCHAR2
	                                ,x_msg_count	     OUT NOCOPY NUMBER
	                                ,x_msg_data	         OUT NOCOPY VARCHAR2
                                    ,p_xcav_tbl          IN  xcav_tbl_type
                                    ,p_receipt_id        IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                    ,p_receipt_amount    IN OUT NOCOPY AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE
                                    ,p_receipt_date      IN  AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT NULL
                                    ,p_receipt_currency  IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                    ,p_currency_code     IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                                  ,p_ar_inv_tbl        IN  OKL_BPD_ADVANCED_BILLING_PVT.ar_inv_tbl_type
                                  ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

  l_ar_inv_tbl                  OKL_BPD_ADVANCED_BILLING_PVT.ar_inv_tbl_type DEFAULT p_ar_inv_tbl;

  l_api_version	                NUMBER := 1.0;
  l_init_msg_list		        VARCHAR2(1) := Okc_Api.g_false;
  l_return_status		        VARCHAR2(1);
  l_msg_count			        NUMBER;
  l_msg_data			        VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'AR_advance_receipt';

  l_receipt_date                AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT p_receipt_date;
  l_receipt_currency_code       OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT p_receipt_currency;
  l_receipt_amount              OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT p_receipt_amount;

  l_customer_trx_id             AR_PAYMENT_SCHEDULES_ALL.CUSTOMER_TRX_ID%TYPE DEFAULT NULL;
  l_cash_receipt_id             AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_receipt_id;

  l_currency_code               OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT p_currency_code;  -- entered currency code

  l_applied_amount              AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL;
  l_applied_amount_from         AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED_FROM%TYPE DEFAULT NULL;

  l_prev_applied_amt            AR_RECEIVABLE_APPLICATIONS_ALL.AMOUNT_APPLIED%TYPE DEFAULT NULL;

  l_receivable_application_id   AR_RECEIVABLE_APPLICATIONS_ALL.RECEIVABLE_APPLICATION_ID%TYPE DEFAULT NULL;

  l_invoice_balance             AR_PAYMENT_SCHEDULES_ALL.AMOUNT_DUE_REMAINING%TYPE DEFAULT NULL;

  l_gl_date                     OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
  l_apply_date                  OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;

  l_ar_inv_id                   RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE DEFAULT NULL;
  l_ar_inv_date                 RA_CUSTOMER_TRX_ALL.TRX_DATE%TYPE DEFAULT NULL;

  i         		            NUMBER DEFAULT NULL;
  l_exit_loop                   NUMBER DEFAULT 0;

  l_counter                     NUMBER;
  l_unapply                     VARCHAR2(3);

  l_record_count                NUMBER DEFAULT NULL;

  l_org_id                      OKL_TRX_CSH_RECEIPT_V.ORG_ID%TYPE DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();

  -- abindal start bug#4897580 --
  l_inv_gl_date               OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
  l_rec_gl_date               OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
  ar_invoice_num              RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE DEFAULT NULL;
  ar_invoice_date             OKL_BPD_LEASING_PAYMENT_TRX_V.INVOICE_DATE%TYPE DEFAULT NULL;
  -- abindal end bug#4897580 --

  -------------------------------------------------------------------------------
  -- DECLARE Record/Table Types
  -------------------------------------------------------------------------------

  -- External Trans

  l_xcav_rec Okl_Xca_Pvt.xcav_rec_type;
  l_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

  x_xcav_rec Okl_Xca_Pvt.xcav_rec_type;
  x_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

  -------------------------------------------------------------------------------
  -- DEFINE CURSORS
  -------------------------------------------------------------------------------

    -- abindal start bug#4897580 --

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

    -- abindal end bug#4897580 --

 -------------------------------------------------------------------------------

  -- verify on account receipt amount
  CURSOR   c_ver_on_acct_amt(cp_csh_rcpt_id IN NUMBER) IS
  SELECT   onaccount_amount amount_available
  FROM     okl_receipt_Details_uv
  WHERE   cash_receipt_id = cp_csh_rcpt_id;

  -------------------------------------------------------------------------------

  --   nikshah -- Bug # 5484903 Fixed,
  --   Changed c_ver_inv_amt(cp_receivables_invoice_id IN NUMBER) SQL definition
  -- verify receivables invoice amount
  CURSOR   c_ver_inv_amt(cp_receivables_invoice_id IN NUMBER) IS
  SELECT   amount_due_remaining
  FROM     AR_PAYMENT_SCHEDULES_ALL
  WHERE    customer_trx_id = cp_receivables_invoice_id;

  -------------------------------------------------------------------------------

  -- check receipt applic
  CURSOR   c_ver_dup_applic( cp_customer_trx_id IN NUMBER
                            ,cp_cash_receipt_id IN NUMBER) IS
  SELECT   amount_applied, receivable_application_id
  FROM     AR_RECEIVABLE_APPLICATIONS_ALL
  WHERE    applied_customer_trx_id = cp_customer_trx_id
  AND      cash_receipt_id = cp_cash_receipt_id
  AND      status = 'APP'
  ORDER BY creation_date desc;

  -------------------------------------------------------------------------------

  -- get the ar invoice date
  CURSOR   c_get_inv_date(cp_inv_id IN NUMBER) IS
  SELECT   trx_date,org_id
  FROM     RA_CUSTOMER_TRX_ALL
  WHERE    customer_trx_id = cp_inv_id;

  -------------------------------------------------------------------------------
  CURSOR c_get_inv_lines(cp_inv_id IN NUMBER) IS
   SELECT customer_trx_line_id invoice_line_id, amount_due_remaining
   FROM ra_customer_trx_lines_All
   WHERE customer_trx_id = cp_inv_id
   AND   line_type ='LINE'
   AND nvl(amount_due_remaining,0) > 0;
  l_ar_llca_tbl                 ar_receipt_api_pub.llca_trx_lines_tbl_type;

BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

        l_return_status := Okl_Api.START_ACTIVITY(
                p_api_name      => l_api_name,
                p_pkg_name      => G_PKG_NAME,
                p_init_msg_list => p_init_msg_list,
                l_api_version   => l_api_version,
                p_api_version   => p_api_version,
                p_api_type      => '_PVT',
                x_return_status => l_return_status);

        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
    l_xcav_tbl := p_xcav_tbl;

    l_record_count := l_xcav_tbl.COUNT;

    -- abindal start bug#4897580 --
    OPEN c_get_gl_date(l_receipt_date);
    FETCH c_get_gl_date INTO l_rec_gl_date, l_counter;
    -- abindal end bug#4897580 --

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

    IF l_ar_inv_tbl.COUNT <> 0 THEN

        -- unapply receipt from account
        -- apply to receipt one by one until it runs out
        -- place remaining receipt amount back on account
        -- end;

        OPEN  c_ver_on_acct_amt(l_cash_receipt_id);
        FETCH c_ver_on_acct_amt INTO l_receipt_amount;
        CLOSE c_ver_on_acct_amt;

        IF l_receipt_amount > 0 THEN

            Ar_receipt_api_pub.unapply_on_account(p_api_version        => l_api_version
                                                 ,p_init_msg_list      => l_init_msg_list
                                           --    ,p_commit             => l_commit
                                           --    ,p_validation_level   => l_validation_level
                                                 ,x_return_status      => l_return_status
                                                 ,x_msg_count          => l_msg_count
                                                 ,x_msg_data           => l_msg_data
                                                 ,p_cash_receipt_id    => l_cash_receipt_id
                                               -- abindal start bug#4897580 --
                                                 ,p_reversal_gl_date   => null
                                               --,p_reversal_gl_date   => l_gl_date
                                               -- abindal end bug#4897580 --
                                                 );


            x_return_status := l_return_status;

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            -- abindal start bug#4897580 --
            IF l_receipt_date <= SYSDATE THEN
               l_apply_date := TRUNC(SYSDATE);
            END IF;

            IF l_receipt_date > SYSDATE THEN
               l_apply_date := l_receipt_date;
            END IF;
           -- abindal end bug#4897580 --


            i := l_ar_inv_tbl.FIRST;

            LOOP

                l_customer_trx_id := l_ar_inv_tbl(i).receivables_invoice_id;
                -- debug_proc('l_customer_trx_id = '||l_customer_trx_id);
                -- varao 14-Feb-2006 bug 5032427 start
                OPEN c_get_inv_date(l_customer_trx_id);
                FETCH c_get_inv_date INTO l_ar_inv_date,l_org_id;
                EXIT WHEN c_get_inv_date%NOTFOUND;
                CLOSE c_get_inv_date;

                IF l_ar_inv_date > l_receipt_date THEN
                  IF l_ar_inv_date > SYSDATE THEN
                    l_apply_date := l_ar_inv_date;
                  END IF;
                END IF;

                OPEN c_get_gl_date(l_apply_date);
                FETCH c_get_gl_date INTO l_inv_gl_date, l_counter;

                IF c_get_gl_date%NOTFOUND THEN
                  CLOSE c_get_gl_date;
                  OKC_API.set_message( p_app_name    => G_APP_NAME,
                                         p_msg_name    =>'OKL_BPD_GL_PERIOD_ERROR',
                                         p_token1       => 'TRX_DATE',
                                         p_token1_value => l_apply_date);

                  l_return_status := OKC_API.G_RET_STS_ERROR;
                  RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
                CLOSE c_get_gl_date;
                -- varao 14-Feb-2006 bug 5032427 end
                i := 0;
                l_ar_llca_tbl.DELETE;

                FOR line_rec IN c_get_inv_lines(l_customer_trx_id) LOOP
                  i := i +1;
                  l_ar_llca_tbl(i).customer_trx_line_id := line_rec.invoice_line_id;
                  IF line_rec.amount_due_remaining > l_receipt_amount THEN
                    l_ar_llca_tbl(i).amount_applied := l_receipt_amount;
                    l_receipt_amount := 0;
                  ELSE
                    l_ar_llca_tbl(i).amount_applied := line_rec.amount_due_remaining;
                    l_receipt_amount := l_receipt_amount - line_rec.amount_due_remaining;
                  END IF;
                  EXIT WHEN l_receipt_amount = 0;
                END LOOP;
                --FOR ll in l_ar_llca_tbl.FIRST..l_ar_llca_tbl.LAST LOOP
                 -- debug_proc('l_ar_llca_tbl(i).customer_trx_line_id = '||l_ar_llca_tbl(i).customer_trx_line_id);
                 -- debug_proc('l_ar_llca_tbl(i).amount_applied = '||l_ar_llca_tbl(i).amount_applied);
               -- END LOOP;
                --debug_proc('l_apply_date =' ||l_apply_date);
                --debug_proc('l_inv_gl_date =' ||l_inv_gl_date);
                --debug_proc('l_org_id =' ||l_org_id);
                --debug_proc('l_cash_receipt_id =' ||l_cash_receipt_id);
                --debug_proc('l_customer_trx_id =' ||l_customer_trx_id);
                IF l_ar_llca_tbl.COUNT > 0 THEN
                      AR_RECEIPT_API_PUB.apply_in_detail( p_api_version    => l_api_version
                                               ,p_init_msg_list          => l_init_msg_list
                                               ,x_return_status          => l_return_status
                                               ,x_msg_count              => l_msg_count
                                               ,x_msg_data               => l_msg_data
                                               ,p_cash_receipt_id        => l_cash_receipt_id
                                               ,p_customer_trx_id        => l_customer_trx_id
                                               ,p_llca_type              => 'L'
                                               ,p_llca_trx_lines_tbl     => l_ar_llca_tbl
                                               ,p_apply_date             => l_apply_date
                                               ,p_apply_gl_date          => l_inv_gl_date
                                               ,p_org_id                 => l_org_id
                                              );
                    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                       RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                END IF;

                EXIT WHEN i = l_ar_inv_tbl.LAST  OR l_receipt_amount = 0;
                i := l_ar_inv_tbl.NEXT(i);

            END LOOP;

        END IF;

    END IF;

    IF l_receipt_amount > 0 THEN

        Ar_receipt_api_pub.Apply_on_account( p_api_version     => l_api_version
                                            ,p_init_msg_list   => l_init_msg_list
                                            ,x_return_status   => l_return_status
                                            ,x_msg_count       => l_msg_count
                                            ,x_msg_data        => l_msg_data
                                            ,p_cash_receipt_id => l_cash_receipt_id
                                          -- abindal start bug#4897580 --
                                          --,p_apply_date      => TRUNC(SYSDATE) -- l_receipt_date
                                          --,p_apply_gl_date   => l_gl_date
                                            ,p_apply_date      => l_receipt_date
                                            ,p_apply_gl_date   => l_rec_gl_date
                                          -- abindal end bug#4897580 --
                                           );

        x_return_status := l_return_status;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        p_receipt_amount := l_receipt_amount;

    END IF;

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;


    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        OKL_API.G_RET_STS_ERROR,
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        OKL_API.G_RET_STS_UNEXP_ERROR,
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

END AR_advance_receipt;


END OKL_BPD_ADVANCED_CASH_APP_PVT;

/
