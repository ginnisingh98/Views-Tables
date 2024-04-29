--------------------------------------------------------
--  DDL for Package Body OKL_RECEIPTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RECEIPTS_PVT" AS
/* $Header: OKLRRCTB.pls 120.39.12010000.3 2009/03/13 11:40:45 racheruv ship $ */
---------------------------------------------------------------------------
-- GLOBAL DATASTRUCTURES
---------------------------------------------------------------------------
TYPE rcpt_curr_conv_rec_type IS RECORD (
        receipt_currency_code   AR_CASH_RECEIPTS.CURRENCY_CODE%TYPE ,
        receipt_date                    AR_CASH_RECEIPTS.RECEIPT_DATE%TYPE ,
        currency_conv_date              AR_CASH_RECEIPTS.EXCHANGE_DATE%TYPE ,
        currency_conv_type              AR_CASH_RECEIPTS.EXCHANGE_RATE_TYPE%TYPE ,
        currency_conv_rate              NUMBER ,
        x_return_status                 VARCHAR2(1)
        );

SUBTYPE  line_appl_tbl_type IS okl_auto_cash_appl_rules_pvt.okl_appl_dtls_tbl_type;
SUBTYPE llca_tbl_type IS okl_auto_cash_appl_rules_pvt.okl_inv_line_tbl_type;
---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- Procedures and Functions
---------------------------------------------------------------------------

PROCEDURE log_debug(p_message IN VARCHAR2) IS
BEGIN
-- dbms_output.put_line(p_message);
--  debug_proc('ssy'||p_message);
  NULL;
END log_debug;

procedure populate_receipt_rec(p_rcpt_rec IN OUT NOCOPY rcpt_rec_type) IS
CURSOR c_rec_dtls(cp_cash_receipt_id IN NUMBER ) IS
SELECT cr.amount,
       cr.currency_code,
       cr.receipt_number,
       cr.receipt_date,
       crh.gl_date
FROM ar_Cash_receipts_all cr, ar_cash_receipt_history_all crh
where cr.cash_Receipt_id = cp_cash_receipt_id
  and cr.cash_receipt_id = crh.cash_receipt_id
  and crh.current_record_flag = 'Y';
BEGIN
  OPEN c_rec_dtls(p_rcpt_rec.cash_receipt_id);
  FETCH c_rec_dtls INTO
p_rcpt_rec.amount,p_rcpt_rec.currency_code,p_rcpt_rec.receipt_number,p_rcpt_rec.receipt_date,p_rcpt_rec.gl_date;
  CLOSE c_rec_dtls;
END populate_receipt_rec;

FUNCTION validate_gl_date(p_gl_date IN DATE)
                                                        RETURN VARCHAR2 IS

        l_applic_month              VARCHAR2(10);
        l_gl_month                  VARCHAR2(10);
        l_counter                                       VARCHAR2(1);
        l_return_status                         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_gl_date                   DATE;

    --get gl date from open accounting period
     CURSOR c_get_gl_date(cp_date IN DATE) IS SELECT * from (
     SELECT end_date gl_date, 1 Counter
     FROM gl_period_statuses
     WHERE application_id = 222
     AND ledger_id = okl_accounting_util.get_set_of_books_id
     AND closing_status IN ('F','O')
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

BEGIN

    OPEN c_get_gl_date(p_gl_date);
    FETCH c_get_gl_date INTO l_gl_date, l_counter;

    log_debug('c_get_gl_date ');

    IF c_get_gl_date%NOTFOUND THEN
        CLOSE c_get_gl_date;

        OKC_API.set_message( p_app_name     => G_APP_NAME,
                             p_msg_name     =>'OKL_BPD_GL_PERIOD_ERROR',
                             p_token1       => 'TRX_DATE',
                             p_token1_value => TRUNC(p_gl_date));

        l_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE c_get_gl_date;

        RETURN l_return_status;

EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;

    WHEN OTHERS THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;
        RETURN l_return_status;

END validate_gl_date;

FUNCTION validate_amount_to_apply(p_amt_to_apply IN nUMBER)
                RETURN VARCHAR2 is

        l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

BEGIN
log_debug( 'In amount to apply');
log_debug( 'In amount to apply: amount to appli is'||p_amt_to_apply);
        IF p_amt_to_apply < 0 THEN
                OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_RCPT_AMT_TO_APPLY_GT_ZERO');

                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        RETURN l_return_status;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;

    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;

END validate_amount_to_apply;

FUNCTION validate_cash_receipt_id(p_cash_receipt_id     IN      NUMBER)
                RETURN VARCHAR2 is

        l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        l_cash_receipt_flag     NUMBER DEFAULT NULL;

        CURSOR csr_validate_cash_rcpt_id(l_cash_rcpt_id IN      NUMBER) IS
        SELECT  '1'
        FROM    AR_CASH_RECEIPTS_ALL
        WHERE   cash_receipt_id = l_cash_rcpt_id;

BEGIN
        OPEN csr_validate_cash_rcpt_id(p_cash_receipt_id);
        FETCH csr_validate_cash_rcpt_id INTO l_cash_receipt_flag;
        CLOSE csr_validate_cash_rcpt_id;

        IF l_cash_receipt_flag IS NULL THEN
                OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_RCPT_INV_CASH_RCPT');
                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        RETURN l_return_status;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;

    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;

END validate_cash_receipt_id;

FUNCTION validate_receipt_attributes(p_rcpt_rec IN rcpt_rec_type)
                RETURN VARCHAR2 IS

        l_currency_code                okl_k_headers_full_v.currency_code%type;
        l_customer_id                   OKL_TRX_CSH_RECEIPT_V.ILE_id%TYPE DEFAULT p_rcpt_rec.customer_id;
        l_customer_num                 HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE DEFAULT p_rcpt_rec.customer_number;
        l_contract_id                            OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL;
        l_currency_conv_type           OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT p_rcpt_rec.exchange_rate_type;
        l_currency_conv_date           OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT p_rcpt_rec.exchange_date;
        l_currency_conv_rate           OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT p_rcpt_rec.exchange_rate;
        l_conversion_rate              GL_DAILY_RATES_V.CONVERSION_RATE%TYPE DEFAULT 0;
        l_functional_conversion_rate   GL_DAILY_RATES_V.CONVERSION_RATE%TYPE DEFAULT 0;
        l_inverse_conversion_rate      GL_DAILY_RATES_V.INVERSE_CONVERSION_RATE%TYPE DEFAULT 0;
        l_functional_currency          OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;
        l_receipt_currency_code        OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT p_rcpt_rec.currency_code;
        l_irm_id                                     OKL_TRX_CSH_RECEIPT_V.IRM_ID%TYPE DEFAULT p_rcpt_rec.receipt_method_id;
        l_check_number                   OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT p_rcpt_rec.receipt_number;
        l_rcpt_amount                            OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT p_rcpt_rec.amount;
        l_converted_receipt_amount     OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL;
        l_rcpt_date                    OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT TRUNC(p_rcpt_rec.receipt_date);
        l_gl_date                      OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE DEFAULT p_rcpt_rec.gl_date;
        l_org_id                       OKL_TRX_CSH_RECEIPT_V.ORG_ID%TYPE DEFAULT p_rcpt_rec.org_id;
        l_dup_rcpt_flag                NUMBER DEFAULT NULL;
        x_return_status                  VARCHAR2(1) DEFAULT OKL_API.G_RET_STS_SUCCESS;
        l_api_name                     CONSTANT VARCHAR2(30) := 'validate_receipt_attributes';
        l_remittance_bank_account_id    NUMBER DEFAULT p_rcpt_rec.remittance_bank_account_id;

        l_rcpt_rec rcpt_rec_type := p_rcpt_rec;


BEGIN
    log_debug('validate_receipt_attributes start');
        l_functional_currency := okl_accounting_util.get_func_curr_code;

        -- check for mandatory fields

        IF      l_receipt_currency_code IS NULL OR
                l_receipt_currency_code = OKC_API.G_MISS_CHAR OR
                l_irm_id IS NULL OR
                l_irm_id = OKC_API.G_MISS_NUM OR
                l_rcpt_date IS NULL OR
                l_rcpt_date = OKC_API.G_MISS_DATE OR
                l_gl_date IS NULL OR
                l_gl_date = OKC_API.G_MISS_DATE OR
                l_org_id IS NULL OR
                l_org_id = OKC_API.G_MISS_NUM OR
                l_rcpt_amount = 0 OR
                l_rcpt_amount = OKC_API.G_MISS_NUM OR
                l_remittance_bank_account_id = OKC_API.G_MISS_NUM OR
                l_remittance_bank_account_id IS NULL THEN

                -- Message Text: Please enter all mandatory fields
                x_return_status := OKC_API.G_RET_STS_ERROR;
                OKC_API.set_message( p_app_name    => G_APP_NAME,
                                    p_msg_name    =>'OKL_BPD_MISSING_FIELDS');

                RAISE G_EXCEPTION_HALT_VALIDATION;
     -- Begin - varangan - Bug#6353486 - Sprint3 -Receipts
       Elsif   ((l_customer_id IS NULL OR l_customer_id = OKL_API.G_MISS_NUM ) AND
                (l_customer_num IS NULL OR l_customer_num  = okl_api.g_miss_char) AND
                (l_rcpt_rec.create_mode <> 'UNAPPLIED' ) ) then

                -- Message Text: A value must be entered for  - COL_NAME.
                 x_return_status := OKC_API.G_RET_STS_ERROR;
                OKC_API.set_message( p_app_name => G_APP_NAME,
                p_msg_name =>'OKL_LLA_INCOMPLETE_RULE',
                p_token1 => 'COL_NAME',
                p_token1_value => 'Customer Name');
                RAISE G_EXCEPTION_HALT_VALIDATION;
     -- End - varangan - Bug#6353486 - Sprint3 -Receipts

        END IF;
    log_debug('Mandatory fieldss validations done');
        -- Check for exceptions
        IF l_rcpt_amount = 0 OR l_rcpt_amount IS NULL THEN
                -- Message Text: The receipt cannot have a value of zero
                x_return_status := OKC_API.G_RET_STS_ERROR;
                OKC_API.set_message( p_app_name      => G_APP_NAME,
                                     p_msg_name      => 'OKL_BPD_ZERO_RECEIPT');
                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    log_debug('Receipt Amount validations are done');

    x_return_status := validate_gl_date(l_gl_date);

    IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    log_debug('GL_DATE validations are done : ' || x_return_status);

        RETURN x_return_status;
        log_debug('validate_receipt_attributes end');
EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN x_return_status;

    WHEN OTHERS THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;
        RETURN x_return_status;
END validate_receipt_attributes;

FUNCTION validate_currency_conv_params(p_curr_conv_rec IN rcpt_curr_conv_rec_type)
                        RETURN rcpt_curr_conv_rec_type IS

        l_currency_conv_type            OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT p_curr_conv_rec.currency_conv_type;
        l_currency_conv_date            OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT p_curr_conv_rec.currency_conv_date;
        l_currency_conv_rate            OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT p_curr_conv_rec.currency_conv_rate;
        l_functional_conversion_rate    GL_DAILY_RATES_V.CONVERSION_RATE%TYPE DEFAULT 0;
        l_inverse_conversion_rate       GL_DAILY_RATES_V.INVERSE_CONVERSION_RATE%TYPE DEFAULT 0;
        l_functional_currency           OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL;
        l_receipt_currency_code         OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT p_curr_conv_rec.receipt_currency_code;
        x_rcpt_curr_conv_rec                    rcpt_curr_conv_rec_type;
        l_return_status                                 VARCHAR2(1);
        l_rcpt_date                                             AR_CASH_RECEIPTS.RECEIPT_DATE%TYPE DEFAULT p_curr_conv_rec.receipt_date;

BEGIN
        log_debug('validate_currency_conv_params start');
        l_functional_currency := okl_accounting_util.get_func_curr_code;

        x_rcpt_curr_conv_rec    :=      p_curr_conv_rec;

    log_debug('l_functional_currency = '||l_functional_currency);
    log_debug('l_receipt_currency_code = '||l_receipt_currency_code);
    log_debug('l_currency_conv_type = '||l_currency_conv_type);
    log_debug('l_currency_conv_rate = '||l_currency_conv_rate);
    log_debug('l_currency_conv_date = '||l_currency_conv_date);
    log_debug('CCV - 1');
        IF l_functional_currency <> l_receipt_currency_code AND
        l_currency_conv_type IS NULL THEN
                -- Message Text: Please enter a currency type.
                l_return_status := OKC_API.G_RET_STS_ERROR;
                OKC_API.set_message( p_app_name      => G_APP_NAME,
                                     p_msg_name      => 'OKL_BPD_PLS_ENT_CUR_TYPE');
                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    log_debug('CCV - 2');
        IF l_functional_currency = l_receipt_currency_code THEN
                IF l_currency_conv_type IS NOT NULL OR
                   nvl(l_currency_conv_rate,0) <> '0' THEN

                    -- Message Text: Currency conversion values are not required when the receipt and invoice currency's are the same.
                    l_return_status := OKC_API.G_RET_STS_ERROR;
                    OKC_API.set_message( p_app_name      => G_APP_NAME,
                                     p_msg_name      => 'OKL_BPD_SAME_CURRENCY');
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
        END IF;

        IF l_functional_currency <> l_receipt_currency_code AND
               l_currency_conv_type NOT IN ('User') THEN
        log_debug('CCV - 3');
                IF l_currency_conv_date IS NULL OR l_currency_conv_date = '' THEN
                    l_currency_conv_date := trunc(l_rcpt_date);
                END IF;
                /*IF l_currency_conv_type = 'CORPORATE' THEN
                    l_currency_conv_type := 'Corporate';
                ELSE
                    l_currency_conv_type := 'Spot';
                END IF;*/

                l_functional_conversion_rate := okl_accounting_util.get_curr_con_rate( l_receipt_currency_code
                                                                          ,l_functional_currency
                                                                              ,l_currency_conv_date
                                                                              ,l_currency_conv_type
                                                                              );

                l_inverse_conversion_rate := okl_accounting_util.get_curr_con_rate( l_functional_currency
                                                                       ,l_receipt_currency_code
                                                                           ,l_currency_conv_date
                                                                           ,l_currency_conv_type
                                                                          );

                IF l_functional_conversion_rate IN (0,-1) THEN
                    --No exchange rate defined
                    l_return_status := OKC_API.G_RET_STS_ERROR;
                    OKC_API.set_message( p_app_name      => G_APP_NAME,
                                         p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

                l_currency_conv_rate := null;

        ELSIF l_functional_currency <> l_receipt_currency_code AND
                  l_currency_conv_type IN ('User') THEN
    log_debug('CCV - 4');
                IF l_currency_conv_rate IS NULL OR l_currency_conv_rate = '0' THEN
                    -- Message Text: No exchange rate defined for currency conversion type USER.
                    l_return_status := OKC_API.G_RET_STS_ERROR;
                    OKC_API.set_message( p_app_name      => G_APP_NAME,
                                         p_msg_name      => 'OKL_BPD_USR_RTE_SUPPLIED');
                    RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
                    l_functional_conversion_rate := l_currency_conv_rate;
                    l_inverse_conversion_rate := l_functional_conversion_rate / 1;
                END IF;

                l_currency_conv_type := 'User';
                l_currency_conv_date := trunc(SYSDATE);
                l_currency_conv_rate := l_functional_conversion_rate;
        ELSE
                -- no currency conversion required
                l_currency_conv_date := NULL;
                l_currency_conv_type := NULL;
                l_currency_conv_rate := NULL;
        END IF;

        x_rcpt_curr_conv_rec.receipt_currency_code      := l_receipt_currency_code;
        x_rcpt_curr_conv_rec.currency_conv_type   := l_currency_conv_type;
        x_rcpt_curr_conv_rec.currency_conv_date   := l_currency_conv_date;
        x_rcpt_curr_conv_rec.currency_conv_rate   := l_currency_conv_rate;
    x_rcpt_curr_conv_rec.x_return_status :=  okl_api.g_ret_sts_success;
    RETURN x_rcpt_curr_conv_rec;
EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_rcpt_curr_conv_rec.x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN x_rcpt_curr_conv_rec;

    WHEN OTHERS THEN
        x_rcpt_curr_conv_rec.x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;
        RETURN x_rcpt_curr_conv_rec;

END validate_currency_conv_params;

  PROCEDURE validate_receipt_details
       ( x_return_status  OUT NOCOPY VARCHAR2,
         p_rcpt_rec       IN OUT NOCOPY RCPT_REC_TYPE
        )
  IS

  l_rcpt_curr_conv_rec rcpt_curr_conv_rec_type;
  x_rcpt_curr_conv_rec rcpt_curr_conv_rec_type;

  BEGIN
    log_debug('validate_receipt_details start +');
    x_return_status := okl_api.g_ret_sts_success;
    log_debug('p_rcpt_rec.cash_receipt_id = '||p_rcpt_rec.cash_receipt_id);
    IF p_rcpt_rec.cash_receipt_id IS NULL THEN
        --do create mode validations
        log_debug('p_rcpt_rec.RECEIPT_NUMBER = '||p_rcpt_rec.RECEIPT_NUMBER);
                IF p_rcpt_rec.RECEIPT_NUMBER IS NULL OR p_rcpt_rec.RECEIPT_NUMBER = OKL_API.G_MISS_CHAR THEN
                        p_rcpt_rec.RECEIPT_NUMBER                    := to_char(sysdate, 'MONDDYYYYHH24MISS');
                END IF;
                log_debug('calling validate_receipt_attributes');
                x_return_status := validate_receipt_attributes(p_rcpt_rec);
                log_debug('RETURN status FROM validate_receipt_attributes = '|| x_return_status);
                IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
                        l_rcpt_curr_conv_rec.receipt_currency_code      :=      p_rcpt_rec.currency_code;
                        l_rcpt_curr_conv_rec.receipt_date       :=      p_rcpt_rec.receipt_date;
                        l_rcpt_curr_conv_rec.currency_conv_date :=      p_rcpt_rec.exchange_date;
                        l_rcpt_curr_conv_rec.currency_conv_type :=      p_rcpt_rec.exchange_rate_type;
                        l_rcpt_curr_conv_rec.currency_conv_rate :=      p_rcpt_rec.exchange_rate;
                        log_debug('calling validate_currency_conv_params');
                        x_rcpt_curr_conv_rec    :=      validate_currency_conv_params(l_rcpt_curr_conv_rec);
                        x_return_status :=      x_rcpt_curr_conv_rec.x_return_status;
                        log_debug('RETURN status FROM validate_currency_conv_params = '|| x_return_status);
                        p_rcpt_rec.exchange_date        :=      x_rcpt_curr_conv_rec.currency_conv_date;
                        p_rcpt_rec.exchange_rate_type   :=      x_rcpt_curr_conv_rec.currency_conv_type;
                        p_rcpt_rec.exchange_rate        :=      x_rcpt_curr_conv_rec.currency_conv_rate;
                        IF p_rcpt_rec.customer_id = okl_api.g_miss_num THEN
                          p_rcpt_rec.customer_id := NULL;
                        END IF;
                        IF p_rcpt_rec.customer_number = okl_api.g_miss_char THEN
                          p_rcpt_rec.customer_number := NULL;
                        END IF;
                ELSE
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

                IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

    ELSE
        --do update  mode validations
        log_debug('calling validate_cash_receipt_id');
                x_return_status :=      validate_cash_receipt_id(p_rcpt_rec.cash_receipt_id);
                log_debug('RETURN status FROM validate_cash_receipt_id = '|| x_return_status);
    END IF;
    log_debug('validate_receipt_details end -');
  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

  END validate_receipt_details;

    PROCEDURE validate_receipt_applications
       ( p_cash_rcpt_id IN NUMBER,
                 p_appl_tbl  IN OUT NOCOPY line_appl_tbl_type,
                 P_onacc_amount IN NUMBER,
                 x_return_status  OUT NOCOPY VARCHAR2
        )
  IS

        l_appl_tbl line_appl_tbl_type;
        l_line_orig_amount      NUMBER DEFAULT 0;
        l_orig_freight_amount NUMBER DEFAULT 0;
        l_orig_charges_amount NUMBER DEFAULT 0;
        l_total_freight_amount NUMBER DEFAULT 0;
        l_total_charges_amount NUMBER DEFAULT 0;
        l_total_outstanding_amount      NUMBER DEFAULT 0;
        l_app_amount    NUMBER DEFAULT 0;
        l_onacc_amount  NUMBER DEFAULT P_onacc_amount;
        l_rcpt_amount   NUMBER DEFAULT 0;

        -- added by dcshanmu for 6326279. Cross currency conversions begins
        l_rcpt_date                             DATE DEFAULT NULL;
        l_invoice_currency_code ar_cash_receipts.currency_code%TYPE DEFAULT NULL;
        l_receipt_currency_code ar_cash_receipts.currency_code%TYPE DEFAULT NULL;
        l_conversion_rate                       NUMBER DEFAULT 0;
        l_converted_receipt_amount      NUMBER DEFAULT 0;
        l_receipt_amount                        NUMBER DEFAULT 0;

        CURSOR c_fetch_receipt_date(p_cash_rcpt_id IN NUMBER) IS
        select receipt_date
        from ar_cash_receipts_all
        where cash_receipt_id=p_cash_rcpt_id;

        CURSOR c_fetch_inv_currency(p_customer_trx_line_id IN NUMBER) IS
        select b.INVOICE_CURRENCY_CODE
        from ra_customer_trx_lines_all a,
            ra_customer_trx_all b
        where a.customer_trx_line_id=p_customer_trx_line_id
        and a.customer_trx_id = b.customer_trx_id;

        CURSOR c_fetch_receipt_currency(p_cash_rcpt_id IN NUMBER) IS
        select currency_code
        from ar_cash_receipts_all
        where cash_receipt_id=p_cash_rcpt_id;

        -- added by dcshanmu for 6326279. Cross currency conversions ends

        CURSOR c_get_app_amount(p_cash_receipt_id IN NUMBER) IS
        SELECT Nvl(SUM(app_Line.Amount_Applied),0)
        FROM   ar_Receivable_Applications_All app_Line
        WHERE  app_Line.Cash_Receipt_Id = p_cash_receipt_id
        AND app_Line.Status = 'APP'
        AND app_Line.Application_Type = 'CASH';

        CURSOR c_get_onacc_amount(p_cash_receipt_id IN NUMBER) IS
        SELECT Nvl(SUM(onAcc_Line.Amount_Applied),0)
        FROM   ar_Receivable_Applications_All onAcc_Line
        WHERE  onAcc_Line.Cash_Receipt_Id = p_cash_receipt_id
        AND onAcc_Line.Status = 'ONACC'
        AND onAcc_Line.Application_Type = 'CASH';

        CURSOR c_get_rcpt_amount(p_cash_receipt_id IN NUMBER) IS
        SELECT Nvl(SUM(rcpt_Line.Amount),0)
        FROM   ar_Cash_Receipts_All rcpt_Line
        WHERE  rcpt_Line.Cash_Receipt_Id = p_cash_receipt_id;

        CURSOR c_get_orig_freight_amount(p_customer_trx_id IN NUMBER) IS
        SELECT NVL(SUM(AMOUNT_DUE_ORIGINAL),0)
        FROM   RA_CUSTOMER_TRX_LINES_ALL
        WHERE  CUSTOMER_TRX_ID = p_customer_trx_id
        AND    LINE_TYPE = 'FREIGHT';

        CURSOR c_get_orig_charges_amount(p_customer_trx_id IN NUMBER) IS
        SELECT NVL(SUM(AMOUNT_DUE_ORIGINAL),0)
        FROM   RA_CUSTOMER_TRX_LINES_ALL
        WHERE  CUSTOMER_TRX_ID = p_customer_trx_id
        AND    LINE_TYPE = 'CHARGES';

  BEGIN
        log_debug( 'In validate receipt applications');
        l_appl_tbl      :=      p_appl_tbl;

        -- added by dcshanmu for 6326279. Cross currency conversions begins
        OPEN c_fetch_receipt_date(p_cash_rcpt_id);
        FETCH c_fetch_receipt_date INTO l_rcpt_date;
        CLOSE c_fetch_receipt_date;

        OPEN c_fetch_receipt_currency(p_cash_rcpt_id);
        FETCH c_fetch_receipt_currency INTO l_receipt_currency_code;
        CLOSE c_fetch_receipt_currency;
        -- added by dcshanmu for 6326279. Cross currency conversions ends

        FOR i in l_appl_tbl.FIRST..l_appl_tbl.LAST LOOP
                IF l_appl_tbl(i).inv_hdr_rec.freight_amount IS NOT NULL THEN
                  OPEN c_get_orig_freight_amount(l_appl_tbl(i).inv_hdr_rec.invoice_id);
                  FETCH c_get_orig_freight_amount INTO l_orig_freight_amount;
                  CLOSE c_get_orig_freight_amount;
                  l_total_freight_amount := l_total_freight_amount + l_appl_tbl(i).inv_hdr_rec.freight_amount;
                  IF l_appl_tbl(i).inv_hdr_rec.freight_amount > l_orig_freight_amount THEN
                    OKL_API.set_message( p_app_name      => G_APP_NAME,
                                         p_msg_name      => 'OKL_RCPT_LN_AMT_GT_OUTSTD_AMT',
                                         p_token1        => 'AMT_TO_APPLY',
                                         p_token1_value   =>  l_appl_tbl(i).inv_hdr_rec.freight_amount,
                                         p_token2        => 'OUTSTD_AMOUNT',
                                         p_token2_value   => l_orig_freight_amount);
                     RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;
                END IF;

                IF l_appl_tbl(i).inv_hdr_rec.charges_amount IS NOT NULL THEN
                  OPEN c_get_orig_charges_amount(l_appl_tbl(i).inv_hdr_rec.invoice_id);
                  FETCH c_get_orig_charges_amount INTO l_orig_charges_amount;
                  CLOSE c_get_orig_charges_amount;
                  l_total_charges_amount := l_total_charges_amount + l_appl_tbl(i).inv_hdr_rec.charges_amount;
                  IF l_appl_tbl(i).inv_hdr_rec.charges_amount > l_orig_charges_amount THEN
                    OKL_API.set_message( p_app_name      => G_APP_NAME,
                                         p_msg_name      => 'OKL_RCPT_LN_AMT_GT_OUTSTD_AMT',
                                         p_token1        => 'AMT_TO_APPLY',
                                         p_token1_value   =>  l_appl_tbl(i).inv_hdr_rec.charges_amount,
                                         p_token2        => 'OUTSTD_AMOUNT',
                                         p_token2_value   => l_orig_charges_amount);
                     RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;
                END IF;

                IF l_appl_tbl(i).inv_lines_tbl.COUNT > 0 THEN
                FOR j in l_appl_tbl(i).inv_lines_tbl.FIRST..l_appl_tbl(i).inv_lines_tbl.LAST LOOP
                        x_return_status :=      validate_amount_to_apply(l_appl_tbl(i).inv_lines_tbl(j).amount_applied);
                        log_debug( 'RETURN Status FROM validate_amount_to_apply = '|| x_return_status);
                        IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN

                                log_debug( 'l_line_orig_amount FROM validate_receipt_applications = '|| l_line_orig_amount);
                                log_debug( 'l_appl_tbl(i).inv_lines_tbl(j).amount_applied FROM validate_receipt_applications = '|| l_appl_tbl(i).inv_lines_tbl(j).amount_applied);

                                IF l_appl_tbl(i).inv_lines_tbl(j).invoice_line_id IS NOT NULL THEN
                                  l_line_orig_amount := Okl_Billing_Util_Pvt.invoice_line_amount_orig(
                                    l_appl_tbl(i).inv_hdr_rec.invoice_id,l_appl_tbl(i).inv_lines_tbl(j).invoice_line_id);

                                  IF l_appl_tbl(i).inv_lines_tbl(j).amount_applied > l_line_orig_amount THEN
                                        OKL_API.set_message( p_app_name      => G_APP_NAME,
                                             p_msg_name      => 'OKL_RCPT_LN_AMT_GT_OUTSTD_AMT',
                                             p_token1        => 'AMT_TO_APPLY',
                                             p_token1_value   =>  l_appl_tbl(i).inv_lines_tbl(j).amount_applied,
                                             p_token2        => 'OUTSTD_AMOUNT',
                                             p_token2_value   => l_line_orig_amount);

                                        RAISE G_EXCEPTION_HALT_VALIDATION;
                                  ELSE
                                        -- added by dcshanmu for 6326279. Cross currency conversions begins
                                        OPEN c_fetch_inv_currency(l_appl_tbl(i).inv_lines_tbl(j).invoice_line_id);
                                        FETCH c_fetch_inv_currency INTO l_invoice_currency_code;
                                        CLOSE c_fetch_inv_currency;

                                        IF l_invoice_currency_code <> l_receipt_currency_code THEN

                                                l_conversion_rate := okl_accounting_util.get_curr_con_rate( l_receipt_currency_code
                                                                                                           ,l_invoice_currency_code
                                                                                                           --,trunc(SYSDATE)
                                                                                                           ,l_rcpt_date
                                                                                                           ,'Corporate'
                                                                                                          );

                                                IF l_conversion_rate IN (0,-1) THEN

                                                    -- Message Text: No exchange rate defined
                                                    x_return_status := OKC_API.G_RET_STS_ERROR;
                                                    OKC_API.set_message( p_app_name      => G_APP_NAME,
                                                                         p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE');

                                                    RAISE G_EXCEPTION_HALT_VALIDATION;

                                                END IF;

                                                -- convert receipt amount to the transaction currency ...
                                                l_converted_receipt_amount := (l_appl_tbl(i).inv_lines_tbl(j).amount_applied * l_conversion_rate);
                                                l_receipt_amount := l_converted_receipt_amount;

                                                -- Check for exceptions

                                                IF l_receipt_amount = 0 OR l_receipt_amount IS NULL THEN

                                                        -- Message Text: The receipt cannot have a value of zero
                                                        x_return_status := OKC_API.G_RET_STS_ERROR;
                                                        OKC_API.set_message( p_app_name      => G_APP_NAME,
                                                                             p_msg_name      => 'OKL_BPD_ZERO_RECEIPT');

                                                        RAISE G_EXCEPTION_HALT_VALIDATION;
                                                END IF;

                                                l_appl_tbl(i).inv_lines_tbl(j).amount_applied_from := l_receipt_amount;
                                        ELSE
                                           l_appl_tbl(i).inv_lines_tbl(j).amount_applied_from := l_appl_tbl(i).inv_lines_tbl(j).amount_applied;
                                        END IF;
                                        p_appl_tbl := l_appl_tbl;

                                        -- added by dcshanmu for 6326279. Cross currency conversions ends

                                        l_total_outstanding_amount      :=      l_total_outstanding_amount + l_appl_tbl(i).inv_lines_tbl(j).amount_applied_from;
                                  END IF;
                                END IF;

                        ELSE
                                RAISE G_EXCEPTION_HALT_VALIDATION;
                        END IF;

                END LOOP;
                END IF;
        END LOOP;

        log_debug( 'p_cash_rcpt_id FROM validate_receipt_applications = '|| p_cash_rcpt_id);
/*
        OPEN c_get_app_amount(p_cash_rcpt_id);
        FETCH c_get_app_amount INTO l_app_amount;
        CLOSE c_get_app_amount;

        OPEN c_get_onacc_amount(p_cash_rcpt_id);
        FETCH c_get_onacc_amount INTO l_onacc_amount;
        CLOSE c_get_onacc_amount;
*/
        OPEN c_get_rcpt_amount(p_cash_rcpt_id);
        FETCH c_get_rcpt_amount INTO l_rcpt_amount;
        CLOSE c_get_rcpt_amount;

        log_debug( 'sum of total outstanding and onaccount amount in validation FROM validate_receipt_applications = '|| (l_total_outstanding_amount + l_onacc_amount));
        log_debug( 'receipt amount in validation FROM validate_receipt_applications = '|| l_rcpt_amount);

        IF (l_total_outstanding_amount + l_onacc_amount +
                    l_total_charges_amount + l_total_freight_amount) > l_rcpt_amount THEN
                OKL_API.set_message( p_app_name      => G_APP_NAME,
                     p_msg_name      => 'OKL_RCPT_TOT_AMT_GT_UNAPP_AMT');

                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;

  END validate_receipt_applications;
-- This procedure will be called for both Unapplied and Unidentified Receipt creation
-- If the customer account passed, then it will  create an Unapplied receipt
-- If the customer account value is null, then it will create an Unidentified receipt
  PROCEDURE create_unapplied_receipt
       (p_api_version      IN NUMBER,
        p_init_msg_list    IN VARCHAR2 DEFAULT okl_api.g_false,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
        p_rcpt_rec         IN RCPT_REC_TYPE,
        x_cash_receipt_id  OUT NOCOPY NUMBER)
  IS
    l_api_version                 NUMBER := 1.0;
    l_init_msg_list               VARCHAR2(1) := okl_api.g_false;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_api_name                    CONSTANT VARCHAR2(30) := 'create_unapplied_receipt';
    l_cash_receipt_id             ar_cash_receipts.cash_receipt_id%TYPE;
    l_rcpt_rec                    RCPT_REC_TYPE;
    l_attribute_rec             AR_RECEIPT_API_PUB.attribute_rec_type;
  BEGIN
    l_return_status := okl_api.start_activity(l_api_name,
                                              g_pkg_name,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
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
    Ar_receipt_api_pub.Create_cash( p_api_version              => l_api_version
                               ,p_init_msg_list                => l_init_msg_list
                               ,x_return_status                => l_return_status
                               ,x_msg_count                    => l_msg_count
                               ,x_msg_data                     => l_msg_data
                               ,p_receipt_number               => l_rcpt_rec.receipt_number
                               ,p_receipt_date                 => l_rcpt_rec.receipt_date
                               ,p_customer_id                  => l_rcpt_rec.customer_id
                               ,p_customer_number              => l_rcpt_rec.customer_number
                               ,p_amount                       => l_rcpt_rec.amount -- in receipt currency ...
                               ,p_currency_code                => l_rcpt_rec.currency_code
                               ,p_exchange_rate_type           => l_rcpt_rec.exchange_rate_type  -- daily exchge rate required ...
                               ,p_exchange_rate                => l_rcpt_rec.exchange_rate       -- daily exchge rate required ...
                               ,p_exchange_rate_date           => l_rcpt_rec.exchange_date  -- daily exchge rate required ...
                               ,p_gl_date                      => l_rcpt_rec.gl_date
                               ,p_receipt_method_id            => l_rcpt_rec.receipt_method_id
                               ,p_org_id                       => l_rcpt_rec.org_id
                               ,p_attribute_rec                => l_attribute_rec
                               ,p_remittance_bank_account_id   => l_rcpt_rec.REMITTANCE_BANK_ACCOUNT_ID
                               ,p_customer_bank_account_id     => l_rcpt_rec.CUSTOMER_BANK_ACCOUNT_ID
                               ,p_payment_trxn_extension_id    => l_rcpt_rec.PAYMENT_TRX_EXTENSION_ID
                               ,p_cr_id                        => l_cash_receipt_id  -- OUT
                               );

    x_cash_receipt_id := l_cash_receipt_id;

    x_return_status := l_return_status;

    IF x_return_status <> okl_api.g_ret_sts_success THEN
    -- Message Text: Error creating receipt in AR

      x_return_status := okl_api.g_ret_sts_error;

      okl_api.set_message(p_app_name => g_app_name,p_msg_name => 'OKL_BPD_ERR_CRT_RCT_AR');

      RAISE g_exception_halt_validation;
    END IF;


    okl_api.end_activity(l_msg_count,l_msg_data);

    x_msg_data := l_msg_data;

    x_msg_count := l_msg_count;
  EXCEPTION
    WHEN g_exception_halt_validation THEN
      x_return_status := okl_api.g_ret_sts_error;
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
  END create_unapplied_receipt;

  PROCEDURE create_onaccount_receipt
       (p_api_version      IN NUMBER,
        p_init_msg_list    IN VARCHAR2 DEFAULT okl_api.g_false,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
        p_cons_bill_id     IN okl_cnsld_ar_hdrs_v.id%TYPE DEFAULT NULL,
        p_ar_inv_id        IN NUMBER DEFAULT NULL,
        p_contract_id      IN okc_k_headers_all_b.id%TYPE DEFAULT NULL,
        p_rcpt_rec         IN RCPT_REC_TYPE,
        x_cash_receipt_id  OUT NOCOPY NUMBER)
  IS
    l_api_version                 NUMBER := 1.0;
    l_init_msg_list               VARCHAR2(1) := okl_api.g_false;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_api_name                    CONSTANT VARCHAR2(30) := 'create_onaccount_receipt';
    l_cash_receipt_id             ar_cash_receipts.cash_receipt_id%TYPE;
    l_rcpt_rec                    RCPT_REC_TYPE;
    l_attribute_rec             AR_RECEIPT_API_PUB.attribute_rec_type;
  BEGIN
    log_debug('create_onaccount_receipt start ');
    l_return_status := okl_api.start_activity(l_api_name,
                                              g_pkg_name,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    l_rcpt_rec := p_rcpt_rec;

       log_debug('calling create_unapplied_receipt');
    create_unapplied_receipt(p_api_version      => l_api_version,
                             p_init_msg_list    => l_init_msg_list,
                             x_return_status    => l_return_status,
                             x_msg_count        => l_msg_count,
                             x_msg_data         => l_msg_data,
                             p_rcpt_rec         => l_rcpt_rec,
                             x_cash_receipt_id  => x_cash_receipt_id);
    log_debug( 'RETURN Status FROM create_unapplied_receipt = '|| l_return_status);
    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_cash_receipt_id:=x_cash_receipt_id;

    Ar_receipt_api_pub.Apply_on_account( p_api_version      => l_api_version
                                                  ,p_init_msg_list    => l_init_msg_list
                                                  ,x_return_status    => l_return_status
                                                  ,x_msg_count        => l_msg_count
                                                  ,x_msg_data         => l_msg_data
                                                  ,p_cash_receipt_id  => l_cash_receipt_id
                                                  ,p_amount_applied   => l_rcpt_rec.amount
                                                  ,p_apply_date       => l_rcpt_rec.receipt_date
                                                  ,p_apply_gl_date    => l_rcpt_rec.gl_date
                                                  ,p_org_id           => l_rcpt_rec.org_id
                                                 );

    x_cash_receipt_id := l_cash_receipt_id;
    log_debug('Return status from  Ar_receipt_api_pub.Create_Apply_On_Acc = '||l_return_status);
    x_cash_receipt_id := l_cash_receipt_id;

    x_return_status := l_return_status;

    IF x_return_status <> okl_api.g_ret_sts_success THEN
    -- Message Text: Error creating receipt in AR

      x_return_status := okl_api.g_ret_sts_error;

   --   okl_api.set_message(p_app_name => g_app_name,p_msg_name => 'OKL_BPD_ERR_CRT_RCT_AR');

      RAISE g_exception_halt_validation;
    END IF;


    okl_api.end_activity(x_msg_count,x_msg_data);

    x_msg_data := l_msg_data;

    x_msg_count := l_msg_count;
  EXCEPTION
    WHEN g_exception_halt_validation THEN
      x_return_status := okl_api.g_ret_sts_error;
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
  END create_onaccount_receipt;

  PROCEDURE unapply_receipt     (  p_api_version         IN  NUMBER
                                    ,p_init_msg_list     IN  VARCHAR2 DEFAULT OkL_Api.G_FALSE
                                    ,x_return_status     OUT NOCOPY VARCHAR2
                                    ,x_msg_count         OUT NOCOPY NUMBER
                                    ,x_msg_data          OUT NOCOPY VARCHAR2
                                    ,p_customer_trx_id   IN  NUMBER DEFAULT NULL -- cash receipt id
                                    ,p_cash_receipt_id   IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL -- cash receipt id
                                    ,p_org_id            IN  NUMBER
                                  ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

  l_api_version                 NUMBER := 1.0;
  l_init_msg_list               VARCHAR2(1) := OKL_API.G_FALSE;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'unapply_receipt';

  l_customer_trx_id             NUMBER DEFAULT p_customer_trx_id;
  l_cash_receipt_id             AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_cash_receipt_id;
  l_receivable_application_id   AR_RECEIVABLE_APPLICATIONS_ALL.RECEIVABLE_APPLICATION_ID%TYPE DEFAULT NULL;
  l_gl_date                     OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
  l_apply_date                  OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
  i                             NUMBER DEFAULT NULL;
  l_counter                     NUMBER;
  l_record_count                NUMBER DEFAULT NULL;
 l_org_id                      NUMBER := p_org_id;

  -- check receipt applic
  CURSOR   c_ver_dup_applic( cp_customer_trx_id IN NUMBER
                            ,cp_cash_receipt_id IN NUMBER) IS
  SELECT   NVL(RECEIVABLE_APPLICATION_ID,0)
  FROM     AR_RECEIVABLE_APPLICATIONS_ALL
  WHERE    APPLIED_CUSTOMER_TRX_ID = cp_customer_trx_id
  AND      CASH_RECEIPT_ID = cp_cash_receipt_id
  AND      STATUS = 'APP'
  AND      APPLICATION_TYPE ='CASH'
  AND      DISPLAY ='Y'
  ORDER BY CREATION_DATE desc;

/*
  -- verify receipt applied amount
  CURSOR   c_ver_app_amt(cp_csh_rcpt_id IN NUMBER) IS
  SELECT   NVL(SUM(AMOUNT_APPLIED),0)
  FROM     AR_RECEIVABLE_APPLICATIONS_ALL
  WHERE    STATUS = 'APP'
  AND      CASH_RECEIPT_ID = cp_csh_rcpt_id;
  -------------------------------------------------------------------------------
*/
BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name
      , p_pkg_name      => G_PKG_NAME
      , p_init_msg_list => p_init_msg_list
      , l_api_version   => l_api_version
      , p_api_version   => p_api_version
      , p_api_type      => '_PVT'
      , x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    OPEN  c_ver_dup_applic (l_customer_trx_id, l_cash_receipt_id);
    FETCH c_ver_dup_applic INTO l_receivable_application_id;
    CLOSE c_ver_dup_applic;

    IF l_receivable_application_id IS NOT NULL THEN
            AR_RECEIPT_API_PUB.Unapply( p_api_version               => l_api_version
                                       ,p_init_msg_list             => l_init_msg_list
                                       ,x_return_status             => l_return_status
                                       ,x_msg_count                 => l_msg_count
                                       ,x_msg_data                  => l_msg_data
                                       ,p_cash_receipt_id           => l_cash_receipt_id
                                       ,p_customer_trx_id           => l_customer_trx_id
                                       ,p_receivable_application_id => l_receivable_application_id
                                       ,p_reversal_gl_date          => null
                                       ,p_org_id                    => l_org_id
                                      );

            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
    END IF;

    -- commit the savepoint
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    x_return_status := l_return_status;

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

  END unapply_receipt;

  PROCEDURE apply_receipt(   p_api_version       IN  NUMBER
                                ,p_init_msg_list     IN  VARCHAR2 DEFAULT OkL_Api.G_FALSE
                                ,x_return_status     OUT NOCOPY VARCHAR2
                                ,x_msg_count         OUT NOCOPY NUMBER
                                ,x_msg_data          OUT NOCOPY VARCHAR2
                                ,p_cash_receipt_id   IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE
                                ,p_customer_trx_id   IN  NUMBER
                                ,p_freight_amount    IN  NUMBER
                                ,p_charges_amount    IN  NUMBER
                                ,p_llca_tbl          IN  llca_tbl_type
                                ,p_apply_gl_date     IN  DATE
                                ,p_org_id            IN  NUMBER
                                ,p_receipt_date IN DATE
                                ,p_gl_date IN DATE
                                ,p_trans_to_receipt_rate IN NUMBER DEFAULT NULL
                         )   IS

---------------------------
-- DECLARE Local Variables
---------------------------

  l_api_version                 NUMBER := 1.0;
  l_init_msg_list               VARCHAR2(1) := OKL_API.G_FALSE;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'apply_receipt';

  l_customer_trx_id             NUMBER DEFAULT p_customer_trx_id;
  l_cash_receipt_id             AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_cash_receipt_id;
  l_llca_tbl                    llca_tbl_type := p_llca_tbl;
  l_ar_llca_tbl                 ar_receipt_api_pub.llca_trx_lines_tbl_type;
  l_receivable_application_id   AR_RECEIVABLE_APPLICATIONS_ALL.RECEIVABLE_APPLICATION_ID%TYPE DEFAULT NULL;
  l_gl_date                     OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE DEFAULT p_gl_date;
  l_org_id                      NUMBER := p_org_id;
  l_apply_date                  OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
  i                             NUMBER DEFAULT NULL;
  k                             NUMBER DEFAULT NULL;
  l_counter                     NUMBER;
  l_record_count                NUMBER DEFAULT NULL;
  l_rcpt_date           DATE DEFAULT NULL;
  l_inv_due_date                DATE DEFAULT NULL;
  l_apply_rcpt_date             DATE DEFAULT NULL;
  l_trans_to_receipt_rate       NUMBER DEFAULT p_trans_to_receipt_rate;
  lla_exists                    VARCHAR2(1) := 'N';
p_count  number;

  -- added by dcshanmu for cross currency conversion as part of 6326279.Begin
        CURSOR c_fetch_receipt_date(p_cash_rcpt_id IN NUMBER) IS
        select receipt_date
        from ar_cash_receipts_all
        where cash_receipt_id=p_cash_rcpt_id;

        CURSOR c_fetch_inv_due_date(p_customer_trx_id IN NUMBER) IS
        select a.due_date
        from ar_payment_schedules_all a
        where a.customer_trx_id=p_customer_trx_id;
  -- added by dcshanmu for cross currency conversion as part of 6326279.End

  --Begain - handle onaccount - varangan - 6353486
  --Application Id for ON-Account record
        CURSOR c_get_onacc_app_id ( p_cash_rcpt_id IN NUMBER) IS
        SELECT   NVL(RECEIVABLE_APPLICATION_ID,0)
        FROM     AR_RECEIVABLE_APPLICATIONS_ALL
        WHERE    CASH_RECEIPT_ID = p_cash_rcpt_id
        AND      STATUS = 'ACC'
        AND      APPLICATION_TYPE ='CASH'
        AND      DISPLAY ='Y'
        ORDER BY CREATION_DATE desc ;

        CURSOR c_get_trans_to_receipt_rate (p_cash_rcpt_id IN NUMBER
                                          , p_customer_trx_id IN NUMBER) IS
        SELECT TRANS_TO_RECEIPT_RATE
        FROM   AR_RECEIVABLE_APPLICATIONS_ALL
        WHERE  CASH_RECEIPT_ID = p_cash_rcpt_id
        AND    APPLIED_CUSTOMER_TRX_ID = p_customer_trx_id
        AND    NVL(DISPLAY,'N') = 'Y';

        CURSOR c_get_cust_trx_id (p_line_id IN NUMBER) IS
        SELECT CUSTOMER_TRX_ID
        FROM   RA_CUSTOMER_TRX_LINES_ALL
        WHERE  CUSTOMER_TRX_LINE_ID = p_line_id;


l_onacc_appplication_id NUMBER;
l_receipt_date DATE DEFAULT  p_receipt_date;
  --End - handle onaccount - varangan - 6353486

  -- bug 6642572 .. get the error messages from gt table .. start
  cursor get_err_csr is
  select CUSTOMER_TRX_ID, error_message
    from ar_llca_trx_errors_gt;

  l_err_rec get_err_csr%ROWTYPE;
  -- bug 6642572 .. get the error messages from gt table .. end

  BEGIN
    log_debug('okl_receipts_pvt.apply_receipt start');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name
      , p_pkg_name      => G_PKG_NAME
      , p_init_msg_list => p_init_msg_list
      , l_api_version   => l_api_version
      , p_api_version   => p_api_version
      , p_api_type      => '_PVT'
      , x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_llca_tbl.COUNT > 0 AND l_llca_tbl(l_llca_tbl.FIRST).invoice_line_id IS NOT NULL THEN
        OPEN c_get_cust_trx_id(l_llca_tbl(l_llca_tbl.FIRST).invoice_line_id);
        FETCH c_get_cust_trx_id INTO l_customer_trx_id;
        CLOSE c_get_cust_trx_id;
    END IF;

    OPEN c_fetch_receipt_date(l_cash_receipt_id);
    FETCH c_fetch_receipt_date INTO l_rcpt_date;
    CLOSE c_fetch_receipt_date;

    OPEN c_fetch_inv_due_date(l_customer_trx_id);
    FETCH c_fetch_inv_due_date INTO l_inv_due_date;
    CLOSE c_fetch_inv_due_date;

    IF trunc(l_inv_due_date) < trunc(l_rcpt_date) THEN
        l_apply_rcpt_date        :=     l_rcpt_date;
    ELSE
        l_apply_rcpt_date        :=     l_inv_due_date;
    END IF;

/*    IF trunc(l_rcpt_date) > trunc(sysdate) THEN
        OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_RCPT_INVLD_APPLN_DATE');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/

    --udhenuko Commented this code as we fetch the conversion rate directly as input.
    /*OPEN c_get_trans_to_receipt_rate(l_cash_receipt_id, l_customer_trx_id);
    FETCH c_get_trans_to_receipt_rate INTO l_trans_to_receipt_rate;
    CLOSE c_get_trans_to_receipt_rate;*/

    log_debug('calling unapply receipt');
     -- unapply any existing application
    unapply_receipt( p_api_version      => l_api_version,
                     p_init_msg_list    => l_init_msg_list,
                     x_return_status    => l_return_status,
                     x_msg_count        => l_msg_count,
                     x_msg_data         => l_msg_data,
                     p_cash_receipt_id  => l_cash_receipt_id,
                     p_customer_trx_id  => l_customer_trx_id,
                     p_org_id           => l_org_id);
    log_debug('return status of unapply_receipt = '||l_return_status);
    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    log_debug('l_llca_tbl.count = '||l_llca_tbl.COUNT);
    IF l_llca_tbl.COUNT > 0 THEN
        FOR i IN l_llca_tbl.FIRST..l_llca_tbl.LAST LOOP
          IF l_llca_tbl.exists(i) THEN
            IF l_llca_tbl(i).amount_applied <> 0 THEN
                l_ar_llca_tbl(i).customer_trx_line_id := l_llca_tbl(i).invoice_line_id;
                l_ar_llca_tbl(i).amount_applied := l_llca_tbl(i).amount_applied;
                l_ar_llca_tbl(i).amount_applied_from := l_llca_tbl(i).amount_applied_from;
		l_ar_llca_tbl(i).line_amount := l_llca_tbl(i).line_applied;  --dkagrawa
		l_ar_llca_tbl(i).tax_amount  := l_llca_tbl(i).tax_applied;
             log_debug('l_ar_llca_tbl('|| i ||').customer_trx_line_id = '||l_ar_llca_tbl(i).customer_trx_line_id);
             log_debug('l_ar_llca_tbl('|| i ||').amount_applied = '||l_ar_llca_tbl(i).amount_applied);
             log_debug('l_ar_llca_tbl('|| i ||').amount_applied_from = '||l_ar_llca_tbl(i).amount_applied_from);
             log_debug('l_ar_llca_tbl('|| i ||').amount_applied_from = '||l_ar_llca_tbl(i).line_amount);
             log_debug('l_ar_llca_tbl('|| i ||').amount_applied_from = '||l_ar_llca_tbl(i).tax_amount);
            END IF;
          END IF;
        END LOOP;


        IF l_ar_llca_tbl.COUNT = 0 AND
           (NVL(p_freight_amount,0) <> 0 OR NVL(p_charges_amount,0) <> 0) THEN
          i := l_llca_tbl.FIRST;
          l_ar_llca_tbl(i).customer_trx_line_id := l_llca_tbl(i).invoice_line_id;
          l_ar_llca_tbl(i).amount_applied := l_llca_tbl(i).amount_applied;
        END IF;
        log_debug('calling AR_RECEIPT_API_PUB.apply_in_detail');
        log_debug('Parameters: p_cash_receipt_id = '||l_cash_receipt_id);
        log_debug('p_customer_trx_id = '||l_customer_trx_id);
        log_debug('p_apply_gl_date = '||p_apply_gl_date);
        log_debug('l_apply_rcpt_date = '||l_apply_rcpt_date);
        log_debug('l_trans_to_receipt_rate = '||l_trans_to_receipt_rate);
        IF l_ar_llca_tbl.COUNT > 0 THEN
            lla_exists := okl_lckbx_csh_app_pvt.get_line_level_app(l_customer_trx_id , l_org_id);
            IF NVL(lla_exists,'N') = 'Y' THEN
              AR_RECEIPT_API_PUB.apply_in_detail( p_api_version    => l_api_version
                                       ,p_init_msg_list          => l_init_msg_list
                                       ,x_return_status          => l_return_status
                                       ,x_msg_count              => l_msg_count
                                       ,x_msg_data               => l_msg_data
                                       ,p_cash_receipt_id        => l_cash_receipt_id
                                       ,p_customer_trx_id        => l_customer_trx_id
                                       ,p_llca_type              => 'L'
                                       ,p_llca_trx_lines_tbl     => l_ar_llca_tbl
                                       ,p_apply_date             => trunc(l_apply_rcpt_date)
                                       ,p_apply_gl_date          => p_apply_gl_date
                                       ,p_org_id                 => l_org_id
                                       ,p_freight_amount         => p_freight_amount
                                       ,p_charges_amount         => p_charges_amount
                                       ,p_trans_to_receipt_rate  => l_trans_to_receipt_rate
                                      );
               log_debug('Return status of AR_RECEIPT_API_PUB.apply_in_detail = '|| l_return_status);
            ELSE
              AR_RECEIPT_API_PUB.apply( p_api_version    => l_api_version
                                       ,p_init_msg_list          => l_init_msg_list
                                       ,x_return_status          => l_return_status
                                       ,x_msg_count              => l_msg_count
                                       ,x_msg_data               => l_msg_data
                                       ,p_cash_receipt_id        => l_cash_receipt_id
                                       ,p_customer_trx_id        => l_customer_trx_id
                                       ,p_apply_date             => trunc(l_apply_rcpt_date)
                                       ,p_apply_gl_date          => p_apply_gl_date
                                       ,p_org_id                 => l_org_id
                                       ,p_trans_to_receipt_rate  => l_trans_to_receipt_rate
                                       ,p_comments               => NULL
                                       ,p_amount_applied         => l_ar_llca_tbl(l_ar_llca_tbl.FIRST).amount_applied
                                      );
              log_debug('Return status of AR_RECEIPT_API_PUB.apply = '|| l_return_status);
            END IF;

            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        END IF;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    x_return_status := l_return_status;
    log_debug('okl_receipts_pvt.apply_receipt end');

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    -- bug 6642572 .. get the error messages and set the stack. start
      if nvl(l_msg_count, 0) = 0 or l_msg_count = OKL_API.g_miss_num then
        open get_err_csr;
        loop
          fetch get_err_csr into l_err_rec;
          exit when get_err_csr%NOTFOUND;

          Okl_Api.SET_MESSAGE(p_app_name     => 'FND',
                              p_msg_name     => 'FND_GENERIC_MESSAGE',
                              p_token1       => 'MESSAGE',
                              p_token1_value => l_err_rec.error_message);

          x_msg_count := x_msg_count + 1;
        end loop;
        close get_err_csr;
      end if;
    -- bug 6642572 .. get the error messages and set the stack . end

      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    -- bug 6642572 .. get the error messages and set the stack. start
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      if nvl(l_msg_count, 0) = 0 or l_msg_count = OKL_API.g_miss_num then
        open get_err_csr;
        loop
          fetch get_err_csr into l_err_rec;
          exit when get_err_csr%NOTFOUND;

          Okl_Api.SET_MESSAGE(p_app_name     => 'FND',
                              p_msg_name     => 'FND_GENERIC_MESSAGE',
                              p_token1       => 'MESSAGE',
                              p_token1_value => l_err_rec.error_message);

          x_msg_count := x_msg_count + 1;
        end loop;
        close get_err_csr;
      end if;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    -- bug 6642572 .. get the error messages and set the stack . end

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

  END apply_receipt;

/************************************************************************************
-- Procedure to Handle Updation of On-Account Amount from Application Page
************************************************************************************/

  PROCEDURE handle_onacc_update( p_api_version       IN  NUMBER
                                ,p_init_msg_list     IN  VARCHAR2 DEFAULT OkL_Api.G_FALSE
                                ,x_return_status     OUT NOCOPY VARCHAR2
                                ,x_msg_count         OUT NOCOPY NUMBER
                                ,x_msg_data          OUT NOCOPY VARCHAR2
                                ,p_cash_receipt_id   IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE
                                ,p_org_id            IN  NUMBER
                                ,p_original_onacc_amount IN NUMBER
                                ,p_apply_onacc_amount IN NUMBER
                                ,p_receipt_date IN DATE
                                ,p_gl_date IN DATE
                         )   IS

---------------------------
-- DECLARE Local Variables
---------------------------

  l_api_version                 NUMBER := 1.0;
  l_init_msg_list               VARCHAR2(1) := OKL_API.G_FALSE;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'handle_onacc_update';

  l_cash_receipt_id             AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_cash_receipt_id;
  l_receivable_application_id   AR_RECEIVABLE_APPLICATIONS_ALL.RECEIVABLE_APPLICATION_ID%TYPE DEFAULT NULL;
  l_gl_date                     OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE DEFAULT p_gl_date;
  l_org_id                      NUMBER := p_org_id;
  l_apply_date                  OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
  i                             NUMBER DEFAULT NULL;
  k                             NUMBER DEFAULT NULL;
  l_counter                     NUMBER;
  l_record_count                NUMBER DEFAULT NULL;
  l_rcpt_date                  DATE DEFAULT p_receipt_date;
  l_inv_due_date                DATE DEFAULT NULL;
  l_apply_rcpt_date             DATE DEFAULT NULL;

  --Begain - handle onaccount - varangan - 6353486
  --Application Id for ON-Account record
        CURSOR c_get_onacc_app_id ( p_cash_rcpt_id IN NUMBER) IS
        SELECT   NVL(RECEIVABLE_APPLICATION_ID,0)
        FROM     AR_RECEIVABLE_APPLICATIONS_ALL
        WHERE    CASH_RECEIPT_ID = p_cash_rcpt_id
        AND      STATUS = 'ACC'
        AND      APPLICATION_TYPE ='CASH'
        AND      DISPLAY ='Y'
        ORDER BY CREATION_DATE desc ;

l_original_onacc_amount NUMBER DEFAULT p_original_onacc_amount;
l_apply_onacc_amount NUMBER DEFAULT p_apply_onacc_amount;
l_onacc_appplication_id NUMBER;
l_receipt_date DATE DEFAULT  p_receipt_date;
  --End - handle onaccount - varangan - 6353486

  BEGIN
    log_debug('okl_receipts_pvt.Unapply_on_account start');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
        p_api_name      => l_api_name
      , p_pkg_name      => G_PKG_NAME
      , p_init_msg_list => p_init_msg_list
      , l_api_version   => l_api_version
      , p_api_version   => p_api_version
      , p_api_type      => '_PVT'
      , x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    --Check if there is existing on-account amount
    If (Nvl(l_original_onacc_amount,0) > 0 ) Then
             -- Get onaccount application Id
             l_onacc_appplication_id := NULL;
             OPEN c_get_onacc_app_id(l_cash_receipt_id);
             FETCH c_get_onacc_app_id INTO l_onacc_appplication_id;
             CLOSE c_get_onacc_app_id;

             IF l_onacc_appplication_id IS NOT NULL THEN
             -- Unapply the on-account amount
               Ar_receipt_api_pub.Unapply_on_account(     p_api_version      => l_api_version,
                                                        p_init_msg_list    => l_init_msg_list,
                                                        x_return_status    => l_return_status ,
                                                        x_msg_count        => l_msg_count ,
                                                        x_msg_data        => l_msg_data,
                                                        p_cash_receipt_id  => l_cash_receipt_id,
                                                        p_receivable_application_id =>l_onacc_appplication_id,
                                                        p_reversal_gl_date => NULL,
                                                        p_org_id            => l_org_id
                                                        );
                log_debug('Return status of AR_RECEIPT_API_PUB.Unapply_on_account = '|| l_return_status);
                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
             END IF;
     END IF;
     -- Check if any On-Account amount to be applied
     If ( Nvl(l_apply_onacc_amount,0) > 0 ) Then
           log_debug('Ar_receipt_api_pub.Apply_on_account l_cash_receipt_id '||l_cash_receipt_id);
           log_debug('Ar_receipt_api_pub.Apply_on_account l_apply_onacc_amount '||l_apply_onacc_amount);
           log_debug('Ar_receipt_api_pub.Apply_on_account l_rcpt_date '||l_rcpt_date);
           log_debug('Ar_receipt_api_pub.Apply_on_account l_gl_date '||l_gl_date);
           -- Apply the on-account amount
           Ar_receipt_api_pub.Apply_on_account( p_api_version      => l_api_version
                                                  ,p_init_msg_list    => l_init_msg_list
                                                  ,x_return_status    => l_return_status
                                                  ,x_msg_count        => l_msg_count
                                                  ,x_msg_data         => l_msg_data
                                                  ,p_cash_receipt_id  => l_cash_receipt_id
                                                  ,p_amount_applied   => l_apply_onacc_amount
                                                  ,p_apply_date       => l_rcpt_date
                                                  ,p_apply_gl_date    => l_gl_date
                                                  ,p_org_id           => l_org_id
                                                 );
          log_debug('Return status of AR_RECEIPT_API_PUB.Apply_on_account = '|| l_return_status);
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
     END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

    x_return_status := l_return_status;
    log_debug('okl_receipts_pvt.handle_onacc_update end');
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

  END handle_onacc_update;


  PROCEDURE handle_receipt
       (p_api_version     IN NUMBER,
        p_init_msg_list   IN VARCHAR2 DEFAULT okl_api.g_false,
        x_return_status   OUT NOCOPY VARCHAR2,
        x_msg_count       OUT NOCOPY NUMBER,
        x_msg_data        OUT NOCOPY VARCHAR2,
        p_rcpt_rec        IN RCPT_REC_TYPE,
        p_appl_tbl         IN APPL_TBL_TYPE,
        x_cash_receipt_id OUT NOCOPY NUMBER)
  IS

  l_rcpt_rec                    RCPT_REC_TYPE DEFAULT p_rcpt_rec;
  l_api_version                 NUMBER := 1.0;
  l_init_msg_list               VARCHAR2(1) := okl_api.g_true;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'handle_receipt';
  l_onacc_appplication_id       NUMBER;

   l_cash_receipt_id            ar_cash_receipts.cash_receipt_id%TYPE DEFAULT p_rcpt_rec.cash_receipt_id;
   p_cash_receipt_id            ar_cash_receipts.cash_receipt_id%TYPE DEFAULT p_rcpt_rec.cash_receipt_id;
   l_header_count               NUMBER;
   l_line_counter               NUMBER;
   l_select_yn                  VARCHAR2(1);
   l_final_count                NUMBER;
   l_call_apply                 BOOLEAN;
   l_call_unapply               BOOLEAN;

   l_currency_code              ar_cash_receipts.currency_code%TYPE:= p_rcpt_rec.currency_code;
   l_customer_number            hz_cust_accounts.account_number%TYPE:=p_rcpt_rec.customer_number;
   l_org_id                     NUMBER:= p_rcpt_rec.org_id;
   l_contract_number            okc_k_headers_all_b.contract_number%TYPE;
   l_cons_inv_number               okl_cnsld_ar_hdrs_all_b.consolidated_invoice_number%TYPE;
   l_ar_inv_number                ra_customer_trx_all.trx_number%TYPE;
   l_ar_invoice_line_id         RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_LINE_ID%TYPE;


   l_appl_tbl                    APPL_TBL_TYPE DEFAULT p_appl_tbl;
   l_okl_rcpt_tbl                line_appl_tbl_type;
   x_okl_rcpt_tbl                line_appl_tbl_type;
   l_final_appl_tbl              line_appl_tbl_type;
   l_inv_lns_tbl                 okl_auto_cash_appl_rules_pvt.okl_inv_line_tbl_type;
   l_init_inv_lines_tbl         okl_auto_cash_appl_rules_pvt.okl_inv_line_tbl_type;

   l_rctv_rec                   Okl_Rct_Pvt.rctv_rec_type;
   l_rcav_tbl                   Okl_Rca_Pvt.rcav_tbl_type;
   x_rctv_rec                   Okl_Rct_Pvt.rctv_rec_type;
   x_rcav_tbl                   Okl_Rca_Pvt.rcav_tbl_type;

   l_rxh_rec                    okl_sla_acc_sources_pvt.rxh_rec_type;

   l_apply_onacc_amount  NUMBER:=0;
   l_unapply_amount NUMBER:=0;
   l_original_onacc_amount NUMBER:=0;
   l_freight_amount NUMBER DEFAULT NULL;
   l_charges_amount NUMBER DEFAULT NULL;
   l_rcpt_status    VARCHAR2(50);
   x_status         VARCHAR2(50);

   l_trans_to_receipt_rate   NUMBER;
   l_exchange_rate_type      VARCHAR2(45);
   l_invoice_currency_code   VARCHAR2(45);


 --Application Id for ON-Account record
   CURSOR c_get_onacc_app_id ( cp_cash_rcpt_id IN NUMBER) IS
   SELECT   NVL(RECEIVABLE_APPLICATION_ID,0)
   FROM     AR_RECEIVABLE_APPLICATIONS_ALL
   WHERE    CASH_RECEIPT_ID = cp_cash_rcpt_id
   AND      STATUS = 'ACC'
   AND      APPLICATION_TYPE ='CASH'
   AND      DISPLAY ='Y'
   ORDER BY CREATION_DATE desc ;

   CURSOR   c_cont_num( cp_contract_id IN NUMBER
                  ,cp_org_id IN NUMBER
                 ) IS
   SELECT  contract_number
   FROM    OKC_K_HEADERS_ALL_B
   WHERE   id = cp_contract_id
   AND     org_id = cp_org_id;

   CURSOR   c_cons_inv_num( cp_con_inv_id IN NUMBER
                     ,cp_org_id IN NUMBER
                     ) IS
   SELECT  consolidated_invoice_number
   FROM    okl_cnsld_ar_hdrs_all_b
   WHERE   id = cp_con_inv_id
   AND     org_id = cp_org_id;

   CURSOR   c_ar_inv_num( cp_ar_inv_id IN NUMBER
                 ,cp_org_id IN NUMBER
                 ) IS
   SELECT  trx_number
   FROM    ra_customer_trx_all
   WHERE   customer_trx_id = cp_ar_inv_id
   AND     org_id = cp_org_id;

   CURSOR c_ar_inv_line_id(cp_ar_inv_id IN NUMBER, cp_org_id IN NUMBER) IS
   SELECT  CUSTOMER_TRX_LINE_ID
   FROM    RA_CUSTOMER_TRX_LINES_ALL
   WHERE   CUSTOMER_TRX_ID = cp_ar_inv_id
   AND     ORG_ID = cp_org_id
   AND     LINE_TYPE = 'LINE'
   AND     ROWNUM = 1;

   CURSOR get_rcpt_sts(cp_cash_receipt_id IN NUMBER) IS
   SELECT  status
   FROM    ar_Cash_receipts_all
   WHERE   cash_receipt_id = cp_cash_receipt_id;

   CURSOR c_fetch_inv_currency (p_customer_trx_id IN NUMBER) IS
   SELECT a.invoice_currency_code
   FROM ra_customer_trx_all a
   WHERE a.customer_trx_id = p_customer_trx_id;

  BEGIN
     log_debug('okl_receipts_pvt.handle_receipts start +');

     l_return_status := okl_api.start_activity(l_api_name,
                                              g_pkg_name,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

     IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
       RAISE okl_api.g_exception_unexpected_error;
     ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
       RAISE okl_api.g_exception_error;
     END IF;
     log_debug('calling validate_receipt_details');
     validate_receipt_details( x_return_status => l_return_status,
                               p_rcpt_rec => l_rcpt_rec);
     log_debug( 'RETURN Status FROM validate_receipt_details = '|| l_return_status);
     IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
       RAISE okl_api.g_exception_unexpected_error;
     ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
       RAISE okl_api.g_exception_error;
     END IF;

     IF l_rcpt_rec.cash_receipt_id is NULL  OR  l_rcpt_rec.cash_receipt_id = okl_api.g_miss_num THEN
             log_debug('l_rcpt_rec.CREATE_MODE = '||l_rcpt_rec.CREATE_MODE);
             IF l_rcpt_rec.CREATE_MODE = 'ONACCOUNT' OR l_rcpt_rec.CREATE_MODE = 'ADVANCED' THEN
               log_debug('calling create_onaccount_receipt');
               create_onaccount_receipt(p_api_version      => l_api_version,
                                        p_init_msg_list    => l_init_msg_list,
                                        x_return_status    => l_return_status,
                                        x_msg_count        => l_msg_count,
                                        x_msg_data         => l_msg_data,
                                        p_rcpt_rec         => l_rcpt_rec,
                                        x_cash_receipt_id  => x_cash_receipt_id);
               log_debug( 'RETURN Status FROM create_onaccount_receipt = '|| l_return_status);
               IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
                 RAISE okl_api.g_exception_unexpected_error;
               ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
                 RAISE okl_api.g_exception_error;
               END IF;
               l_cash_receipt_id:=x_cash_receipt_id;
             ELSIF l_rcpt_rec.CREATE_MODE = 'UNAPPLIED' THEN   -- This mode is for both Unapplied and Unidentified receipts
               log_debug('calling create_unapplied_receipt');
               create_unapplied_receipt(p_api_version      => l_api_version,
                                        p_init_msg_list    => l_init_msg_list,
                                        x_return_status    => l_return_status,
                                        x_msg_count        => l_msg_count,
                                        x_msg_data         => l_msg_data,
                                        p_rcpt_rec         => l_rcpt_rec,
                                        x_cash_receipt_id  => x_cash_receipt_id);
               log_debug( 'RETURN Status FROM create_unapplied_receipt = '|| l_return_status);
               IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
                 RAISE okl_api.g_exception_unexpected_error;
               ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
                 RAISE okl_api.g_exception_error;
               END IF;
               l_cash_receipt_id:=x_cash_receipt_id;
             END IF;

             IF l_rcpt_rec.CREATE_MODE = 'ADVANCED'  THEN
                log_debug( 'GL date not equal = ');
                IF l_appl_tbl.count > 1 THEN
                  OKL_API.set_message( p_app_name      => G_APP_NAME,
                                       p_msg_name      => 'OKL_RCPT_ONE_CONTRACT_REQD');
                  RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
             END IF;
     ELSE
        x_cash_receipt_id := l_rcpt_rec.cash_receipt_id;
        populate_receipt_rec(l_rcpt_rec);
        OPEN get_rcpt_sts(l_rcpt_rec.cash_receipt_id);
        FETCH get_rcpt_sts INTO l_rcpt_status;
        CLOSE get_rcpt_sts;
        IF l_rcpt_status = 'UNID' THEN
          IF l_rcpt_rec.customer_id IS NOT NULL AND l_rcpt_rec.customer_id <> okl_api.g_miss_num THEN

             Ar_receipt_update_api_pub.update_receipt_unid_to_unapp(
                                p_api_version                  => l_api_version
                               ,p_init_msg_list                => l_init_msg_list
                               ,x_return_status                => l_return_status
                               ,x_msg_count                    => l_msg_count
                               ,x_msg_data                     => l_msg_data
                               ,p_cash_receipt_id              => l_rcpt_rec.cash_receipt_id
                               ,p_pay_from_customer            => l_rcpt_rec.customer_id
                               ,x_status                       => x_status
                               ,p_customer_bank_account_id     => l_rcpt_rec.customer_bank_account_id
                               );
             IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
             ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
             END IF;
          END IF;
        END IF;
     END IF;
     -- Capture Original and Updated On-Account Amount
     l_original_onacc_amount:= l_rcpt_rec.p_original_onacc_amount;
     l_apply_onacc_amount := l_rcpt_rec.p_apply_onacc_amount;


    IF l_appl_tbl.count > 0 THEN
      l_header_count:=0;
      l_line_counter:=0;
      FOR i IN l_appl_tbl.FIRST..l_appl_tbl.LAST LOOP
         l_select_yn:='N';
         l_inv_lns_tbl:=l_init_inv_lines_tbl;
         IF l_rcpt_rec.CREATE_MODE = 'ADVANCED' THEN
             l_rctv_rec.IRM_ID              := l_rcpt_rec.receipt_method_id;
             l_rctv_rec.ILE_ID              := l_rcpt_rec.customer_id;
             l_rctv_rec.CHECK_NUMBER        := l_rcpt_rec.receipt_number;
             l_rctv_rec.AMOUNT              := l_rcpt_rec.amount;
             l_rctv_rec.CURRENCY_CODE       := l_rcpt_rec.currency_code;
             l_rctv_rec.EXCHANGE_RATE       := l_rcpt_rec.EXCHANGE_RATE;
             l_rctv_rec.EXCHANGE_RATE_TYPE  := l_rcpt_rec.EXCHANGE_RATE_TYPE;
             l_rctv_rec.EXCHANGE_RATE_DATE  := l_rcpt_rec.EXCHANGE_DATE;
             l_rctv_rec.DATE_EFFECTIVE      := l_rcpt_rec.receipt_Date;
             l_rctv_rec.GL_DATE             := l_rcpt_rec.gl_date;
             l_rctv_rec.ORG_ID              := l_rcpt_rec.org_id;
             l_rctv_rec.RECEIPT_TYPE        := 'ADV';
             l_rctv_rec.cash_receipt_id     := l_cash_receipt_id;
             l_rctv_rec.expired_flag        := 'N';
             l_rctv_rec.fully_Applied_flag  := 'N';

             l_rcav_tbl(1).KHR_ID           := l_appl_tbl(i).contract_id;
             l_rcav_tbl(1).ILE_ID           := l_rcpt_rec.customer_id;
             l_rcav_tbl(1).AMOUNT           := l_rcpt_rec.amount;
             l_rcav_tbl(1).ORG_ID           := l_rcpt_rec.org_id;
             log_debug('calling  Okl_Rct_Pub.create_internal_trans');
             Okl_Rct_Pub.create_internal_trans (l_api_version
                                               ,l_init_msg_list
                                               ,l_return_status
                                               ,l_msg_count
                                               ,l_msg_data
                                               ,l_rctv_rec
                                               ,l_rcav_tbl
                                               ,x_rctv_rec
                                               ,x_rcav_tbl);
             log_debug('Return status of  Okl_Rct_Pub.create_internal_trans = '|| l_return_status);
             IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
             ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
             END IF;
             log_debug('l_appl_tbl(i).contract_id : '||l_appl_tbl(i).contract_id);
             log_debug('l_appl_tbl(i).con_inv_id : '||l_appl_tbl(i).con_inv_id);
             log_debug('l_appl_tbl(i).ar_inv_id : '||l_appl_tbl(i).ar_inv_id);
             IF l_appl_tbl(i).contract_id IS NOT NULL and l_appl_tbl(i).contract_id <> okl_api.g_miss_num THEN
                     l_rxh_rec.source_id := l_cash_receipt_id;
                     l_rxh_rec.khr_id := l_appl_tbl(i).contract_id;
                      log_debug(' okl_sla_acc_sources_pvt.populate_sources');
                     okl_sla_acc_sources_pvt.populate_sources(
                                                            p_api_version    =>  l_api_version
                                                           ,p_init_msg_list  =>  l_init_msg_list
                                                           ,p_rxh_rec        =>  l_rxh_rec
                                                           ,x_return_status  =>  l_return_status
                                                           ,x_msg_count      =>  l_msg_count
                                                           ,x_msg_data       =>  l_msg_data
                                                  );

                      log_debug('Return status of  okl_sla_acc_sources_pvt.populate_sources = '|| l_return_status);
                     IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
                       RAISE okl_api.g_exception_unexpected_error;
                     ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
                       RAISE okl_api.g_exception_error;
                     END IF;
             END IF;
         ELSIF l_appl_tbl(i).contract_id is not null then
          OPEN c_cont_num(l_appl_tbl(i).contract_id,l_org_id);
          FETCH c_cont_num into l_contract_number;
          CLOSE C_cont_num;
             log_debug('Before okl_auto_cash_appl_rules_pvt.auto_cashapp_for_contract');
             okl_auto_cash_appl_rules_pvt.auto_cashapp_for_contract( p_api_version   => l_api_version,
                                                                        p_init_msg_list => l_init_msg_list,
                                                                        x_return_status => l_return_status,
                                                                        x_msg_count     => l_msg_count,
                                                                        x_msg_data      => l_msg_data,
                                                                        p_customer_num  => l_customer_number,
                                                                        p_contract_num  => l_contract_number,
                                                                        p_currency_code => l_currency_code,
                                                                        p_amount_app_to   => l_appl_tbl(i).amount_to_apply,
                                                                        p_amount_app_from   => l_appl_tbl(i).amount_applied_from,
                                                                        p_receipt_date   => l_rcpt_rec.receipt_date,
                                                                        p_org_id        => l_org_id,
                                                                        x_appl_tbl      => x_okl_rcpt_tbl,
                                                                        x_onacc_amount  => l_apply_onacc_amount,
                                                                        x_unapply_amount =>l_unapply_amount
                                                                        );
            log_debug('After  okl_auto_cash_appl_rules_pvt.auto_cashapp_for_contract');
            log_debug('l_apply_onacc_amount = '||l_apply_onacc_amount);
        log_debug('l_unapply_amount = '||l_unapply_amount);
            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
              RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
            END IF;
            l_okl_rcpt_tbl:=x_okl_rcpt_tbl;
 log_debug( 'l_okl_rcpt_tbl= count '|| x_okl_rcpt_tbl.count);
           IF l_final_appl_tbl.COUNT>0 THEN
           l_final_count:=l_final_appl_tbl.LAST+1;
           FOR k IN l_okl_rcpt_tbl.FIRST..l_okl_rcpt_tbl.LAST LOOP
           log_debug('x_okl_rcpt_tbl(k).amount_applied = '||x_okl_rcpt_tbl(k).inv_hdr_rec.amount_applied);
           log_debug('x_okl_rcpt_tbl(k).amount_applied_from = '||x_okl_rcpt_tbl(k).inv_hdr_rec.amount_applied_from);
           l_final_appl_tbl(l_final_count) := x_okl_rcpt_tbl(k);
           l_final_count:=l_final_count+1;
           END LOOP;
           ELSE
           l_final_appl_tbl:=l_okl_rcpt_tbl;
           END IF;
 log_debug( 'l_final_appl_tbl count'|| l_final_appl_tbl.count);
         ELSIF l_appl_tbl(i).con_inv_id is not null then
          OPEN c_cons_inv_num(l_appl_tbl(i).con_inv_id,l_org_id);
          FETCH c_cons_inv_num into l_cons_inv_number;
          CLOSE c_cons_inv_num;
          log_debug('Before okl_auto_cash_appl_rules_pvt.auto_cashapp_for_consinv');
                   okl_auto_cash_appl_rules_pvt.auto_cashapp_for_consinv ( p_api_version   => l_api_version,
                                                                                p_init_msg_list => l_init_msg_list,
                                                                                x_return_status => l_return_status,
                                                                                x_msg_count     => l_msg_count,
                                                                                x_msg_data      => l_msg_data,
                                                                                p_customer_num  => l_customer_number,
                                                                                p_cons_inv      => l_cons_inv_number,
                                                                                p_currency_code => l_currency_code,
                                                                                p_amount_app_to   => l_appl_tbl(i).amount_to_apply,
                                                                                p_amount_app_from   => l_appl_tbl(i).amount_applied_from,
                                                                                p_receipt_date   => l_rcpt_rec.receipt_date,
                                                                                p_org_id        => l_org_id,
                                                                                x_appl_tbl      => x_okl_rcpt_tbl,
                                                                                x_onacc_amount  => l_apply_onacc_amount,
                                                                                x_unapply_amount =>l_unapply_amount
                                                                        );
            log_debug('After okl_auto_cash_appl_rules_pvt.auto_cashapp_for_consinv');
            log_debug('l_apply_onacc_amount = '||l_apply_onacc_amount);
        log_debug('l_unapply_amount = '||l_unapply_amount);
            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
             RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
             RAISE okl_api.g_exception_error;
            END IF;
            l_okl_rcpt_tbl:=x_okl_rcpt_tbl;
           IF l_final_appl_tbl.COUNT>0 THEN
           l_final_count:=l_final_appl_tbl.LAST+1;
           FOR k IN l_okl_rcpt_tbl.FIRST..l_okl_rcpt_tbl.LAST LOOP
           log_debug('x_okl_rcpt_tbl(k).amount_applied = '||x_okl_rcpt_tbl(k).inv_hdr_rec.amount_applied);
           log_debug('x_okl_rcpt_tbl(k).amount_applied_from = '||x_okl_rcpt_tbl(k).inv_hdr_rec.amount_applied_from);
           l_final_appl_tbl(l_final_count) := x_okl_rcpt_tbl(k);
           l_final_count:=l_final_count+1;
           END LOOP;
           ELSE
           l_final_appl_tbl:=l_okl_rcpt_tbl;
           END IF;

         ELSIF l_appl_tbl(i).ar_inv_id is not null and l_appl_tbl(i).line_id is null
           and NVL(l_appl_tbl(i).line_type,'LINE') = 'LINE'
           and l_rcpt_rec.cash_receipt_id IS NULL then
          OPEN c_ar_inv_num(l_appl_tbl(i).ar_inv_id,l_org_id);
          FETCH c_ar_inv_num into l_ar_inv_number;
          CLOSE c_ar_inv_num;
          log_debug('Before okl_auto_cash_appl_rules_pvt.auto_cashapp_for_arinv');
                 okl_auto_cash_appl_rules_pvt.auto_cashapp_for_arinv ( p_api_version   => l_api_version,
                                                                        p_init_msg_list => l_init_msg_list,
                                                                        x_return_status => l_return_status,
                                                                        x_msg_count     => l_msg_count,
                                                                        x_msg_data      => l_msg_data,
                                                                        p_customer_num  => l_customer_number,
                                                                        p_arinv_number  => l_ar_inv_number,
                                                                        p_currency_code => l_currency_code,
                                                                        p_amount_app_to   => l_appl_tbl(i).amount_to_apply,
                                                                        p_amount_app_from   => l_appl_tbl(i).amount_applied_from,
                                                                        p_receipt_date   => l_rcpt_rec.receipt_date,
                                                                        p_org_id        => l_org_id,
                                                                        x_appl_tbl      => x_okl_rcpt_tbl,
                                                                        x_onacc_amount  => l_apply_onacc_amount,
                                                                        x_unapply_amount =>l_unapply_amount
                                                                        );
          log_debug('After okl_auto_cash_appl_rules_pvt.auto_cashapp_for_arinv');
          IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
          ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
          END IF;

        log_debug('l_apply_onacc_amount = '||l_apply_onacc_amount);
        log_debug('l_unapply_amount = '||l_unapply_amount);
          l_okl_rcpt_tbl:=x_okl_rcpt_tbl;
          IF l_final_appl_tbl.COUNT>0 THEN
           l_final_count:=l_final_appl_tbl.LAST+1;
           FOR k IN l_okl_rcpt_tbl.FIRST..l_okl_rcpt_tbl.LAST LOOP
           log_debug('x_okl_rcpt_tbl(k).amount_applied = '||x_okl_rcpt_tbl(k).inv_hdr_rec.amount_applied);
           log_debug('x_okl_rcpt_tbl(k).amount_applied_from = '||x_okl_rcpt_tbl(k).inv_hdr_rec.amount_applied_from);
           l_final_appl_tbl(l_final_count) := x_okl_rcpt_tbl(k);
           l_final_count:=l_final_count+1;
           END LOOP;
           ELSE
           l_final_appl_tbl:=l_okl_rcpt_tbl;
           END IF;
         ELSIF l_appl_tbl(i).ar_inv_id is not null
           and (l_appl_tbl(i).line_id is not null
                OR l_rcpt_rec.cash_receipt_id IS NOT NULL)
           and NVL(l_appl_tbl(i).line_type,'LINE') = 'LINE' then
          --- populate l_final_appl_tbl based on ar inv id
             -- first time condition
          IF l_final_appl_tbl.COUNT <=0 THEN
                l_final_appl_tbl(0).inv_hdr_rec.invoice_id:=l_appl_tbl(i).ar_inv_id;
                l_final_appl_tbl(0).inv_hdr_rec.gl_date:=l_appl_tbl(i).gl_date;
                l_final_appl_tbl(0).inv_hdr_rec.trans_to_receipt_rate:=l_appl_tbl(i).trans_to_receipt_rate;
                l_inv_lns_tbl(0).invoice_line_id := l_appl_tbl(i).line_id;
                l_inv_lns_tbl(0).amount_applied := l_appl_tbl(i).amount_to_apply;
                l_inv_lns_tbl(0).original_applied_amount := l_appl_tbl(i).original_applied_amount;
                l_inv_lns_tbl(0).line_applied := l_appl_tbl(i).line_applied;
		l_inv_lns_tbl(0).tax_applied := l_appl_tbl(i).tax_applied;  --dkagrawa
                l_final_appl_tbl(0).inv_lines_tbl := l_inv_lns_tbl;
            ELSE
               FOR k IN l_final_appl_tbl.first..l_final_appl_tbl.LAST LOOP
                 IF l_final_appl_tbl(k).inv_hdr_rec.invoice_id=l_appl_tbl(i).ar_inv_id THEN
                        IF l_final_appl_tbl(k).inv_hdr_rec.gl_date IS NOT NULL AND
                                l_appl_tbl(i).gl_date IS NOT NULL THEN

                                IF l_final_appl_tbl(k).inv_hdr_rec.gl_date <> l_appl_tbl(i).gl_date THEN
                                        log_debug( 'GL date not equal = ');
                                        OKL_API.set_message( p_app_name      => G_APP_NAME,
                                             p_msg_name      => 'OKL_RCPT_INVLD_GL_DATE_FOR_INV');
                                        RAISE G_EXCEPTION_HALT_VALIDATION;
                                END IF;
                        END IF;
                        IF l_final_appl_tbl(k).inv_hdr_rec.trans_to_receipt_rate IS NOT NULL AND
                                l_appl_tbl(i).trans_to_receipt_rate IS NOT NULL THEN

                                IF l_final_appl_tbl(k).inv_hdr_rec.trans_to_receipt_rate <> l_appl_tbl(i).trans_to_receipt_rate THEN
                                        log_debug( 'GL date not equal = ');
                                        OKL_API.set_message( p_app_name      => G_APP_NAME,
                                             p_msg_name      => 'OKL_RCPT_INVLD_RATE_FOR_INV');
                                        RAISE G_EXCEPTION_HALT_VALIDATION;
                                END IF;
                        END IF;
                  l_header_count:=k;
                  l_line_counter:=(l_final_appl_tbl(k).inv_lines_tbl.LAST+1);
                  l_line_counter := NVL(l_line_counter,0);
                  l_select_yn:='Y';
                  EXIT;
                 END IF;
               END LOOP;

              IF l_select_yn='Y' THEN
                -- header record already present ,get the lines records in table and add new line
                 l_inv_lns_tbl:=l_final_appl_tbl(l_header_count).inv_lines_tbl;
                 l_inv_lns_tbl(l_line_counter).invoice_line_id := l_appl_tbl(i).line_id;
                 l_inv_lns_tbl(l_line_counter).amount_applied := l_appl_tbl(i).amount_to_apply;
                 l_inv_lns_tbl(l_line_counter).original_applied_amount := l_appl_tbl(i).original_applied_amount;
                 l_inv_lns_tbl(l_line_counter).line_applied := l_appl_tbl(i).line_applied;
		 l_inv_lns_tbl(l_line_counter).tax_applied := l_appl_tbl(i).tax_applied;  --dkagrawa
                 --assign the record back to the receipts table
                 l_final_appl_tbl(l_header_count).inv_lines_tbl := l_inv_lns_tbl;
              ELSE
               l_header_count:=(l_final_appl_tbl.LAST+1);
               l_line_counter:=0;
                l_final_appl_tbl(l_header_count).inv_hdr_rec.invoice_id:=l_appl_tbl(i).ar_inv_id;
                l_final_appl_tbl(l_header_count).inv_hdr_rec.gl_date:=l_appl_tbl(i).gl_date;
                l_final_appl_tbl(l_header_count).inv_hdr_rec.trans_to_receipt_rate:=l_appl_tbl(i).trans_to_receipt_rate;
                l_inv_lns_tbl(l_line_counter).invoice_line_id := l_appl_tbl(i).line_id;
                l_inv_lns_tbl(l_line_counter).amount_applied := l_appl_tbl(i).amount_to_apply;
                l_inv_lns_tbl(l_line_counter).original_applied_amount := l_appl_tbl(i).original_applied_amount;
		l_inv_lns_tbl(l_line_counter).line_applied := l_appl_tbl(i).line_applied;
                l_inv_lns_tbl(l_line_counter).tax_applied := l_appl_tbl(i).tax_applied;  --dkagrawa
                l_final_appl_tbl(l_header_count).inv_lines_tbl := l_inv_lns_tbl;
              END IF;

            END IF;
         --If application line belongs to freight then handle it
         --separately
         ELSIF NVL(l_appl_tbl(i).line_type,'LINE') IN ('FREIGHT','CHARGES') THEN
          --- populate l_final_appl_tbl based on ar inv id
             -- first time condition
          IF l_final_appl_tbl.COUNT <=0 THEN
                l_final_appl_tbl(0).inv_hdr_rec.invoice_id:=l_appl_tbl(i).ar_inv_id;
                l_final_appl_tbl(0).inv_hdr_rec.gl_date:=l_appl_tbl(i).gl_date;
                l_final_appl_tbl(0).inv_hdr_rec.trans_to_receipt_rate:=l_appl_tbl(i).trans_to_receipt_rate;
                IF l_appl_tbl(i).line_type = 'FREIGHT' THEN
                                        l_final_appl_tbl(0).inv_hdr_rec.freight_amount := l_appl_tbl(i).amount_to_apply;
                                ELSIF l_appl_tbl(i).line_type = 'CHARGES' THEN
                                        l_final_appl_tbl(0).inv_hdr_rec.charges_amount := l_appl_tbl(i).amount_to_apply;
                                END IF;
            ELSE
               FOR k IN l_final_appl_tbl.first..l_final_appl_tbl.LAST LOOP
                 IF l_final_appl_tbl(k).inv_hdr_rec.invoice_id=l_appl_tbl(i).ar_inv_id THEN
                        IF l_final_appl_tbl(k).inv_hdr_rec.gl_date IS NOT NULL AND
                                l_appl_tbl(i).gl_date IS NOT NULL THEN
                                IF l_final_appl_tbl(k).inv_hdr_rec.gl_date <> l_appl_tbl(i).gl_date THEN
                                        OKL_API.set_message( p_app_name      => G_APP_NAME,
                                             p_msg_name      => 'OKL_RCPT_INVLD_GL_DATE_FOR_INV');
                                        RAISE G_EXCEPTION_HALT_VALIDATION;
                                END IF;
                        END IF;
			IF l_final_appl_tbl(k).inv_hdr_rec.trans_to_receipt_rate IS NOT NULL AND
                                l_appl_tbl(i).trans_to_receipt_rate IS NOT NULL THEN
                                IF l_final_appl_tbl(k).inv_hdr_rec.trans_to_receipt_rate <> l_appl_tbl(i).trans_to_receipt_rate THEN
                                        OKL_API.set_message( p_app_name      => G_APP_NAME,
                                             p_msg_name      => 'OKL_RCPT_INVLD_RATE_FOR_INV');
                                        RAISE G_EXCEPTION_HALT_VALIDATION;
                                END IF;
                        END IF;
                  IF l_appl_tbl(i).line_type = 'FREIGHT' THEN
                        l_final_appl_tbl(k).inv_hdr_rec.freight_amount :=
                                             NVL(l_final_appl_tbl(k).inv_hdr_rec.freight_amount,0) +
                                                 l_appl_tbl(i).amount_to_apply;
                  ELSIF l_appl_tbl(i).line_type = 'CHARGES' THEN
                        l_final_appl_tbl(k).inv_hdr_rec.charges_amount :=
                                             NVL(l_final_appl_tbl(k).inv_hdr_rec.charges_amount,0) +
                                                 l_appl_tbl(i).amount_to_apply;
                  END IF;
                  l_select_yn := 'Y';
                  EXIT;
                 END IF;
               END LOOP;
               IF l_select_yn = 'N' THEN
                l_header_count := l_final_appl_tbl.LAST + 1;
                l_final_appl_tbl(l_header_count).inv_hdr_rec.invoice_id:=l_appl_tbl(i).ar_inv_id;
                l_final_appl_tbl(l_header_count).inv_hdr_rec.gl_date:=l_appl_tbl(i).gl_date;
                l_final_appl_tbl(l_header_count).inv_hdr_rec.trans_to_receipt_rate:=l_appl_tbl(i).trans_to_receipt_rate;
                IF l_appl_tbl(i).line_type = 'FREIGHT' THEN
                  l_final_appl_tbl(l_header_count).inv_hdr_rec.freight_amount := l_appl_tbl(i).amount_to_apply;
                ELSIF l_appl_tbl(i).line_type = 'CHARGES' THEN
                  l_final_appl_tbl(l_header_count).inv_hdr_rec.charges_amount := l_appl_tbl(i).amount_to_apply;
                END IF;
               END IF;

            END IF;
       END IF;
   END LOOP;
  END IF;
-- Updating the On-Acc variables, if it is null/g_miss_num
If (l_original_onacc_amount Is Null) Or (l_original_onacc_amount = okl_api.g_miss_num) Then
        l_original_onacc_amount:= 0;
End If;
If (l_apply_onacc_amount  Is Null) Or (l_apply_onacc_amount = okl_api.g_miss_num) Then
        l_apply_onacc_amount:=0;
End If;

   log_debug('In the final count before looping'||l_final_appl_tbl.COUNT);
  IF l_final_appl_tbl.COUNT > 0 THEN
     log_debug('calling validate_receipt_applications');

     IF p_rcpt_rec.cash_receipt_id IS NOT NULL THEN
        p_cash_receipt_id := p_rcpt_rec.cash_receipt_id;
     ELSE
        p_cash_receipt_id := x_cash_receipt_id;
     END IF;
 /* -- Commenting the Overapplication validation to let AR validate the applications
     validate_receipt_applications(
                                        p_cash_rcpt_id => p_cash_receipt_id,
                                        p_appl_tbl => l_final_appl_tbl,
                                        P_onacc_amount  =>  l_apply_onacc_amount,
                                        x_return_status => l_return_status );

     log_debug( 'RETURN Status FROM validate_receipt_applications = '|| l_return_status);
     IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
           RAISE okl_api.g_exception_unexpected_error;
     ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
           RAISE okl_api.g_exception_error;
     END IF;
*/
      -- unapply all the applications first which are changing, so that the amount is available for application
      FOR i IN l_final_appl_tbl.FIRST..l_final_appl_tbl.LAST LOOP
                --If freight amount or charges amount is there then check whether
                --any invoice lines are there or not. If no then create one invoice line
                --with applied amount 0. Otherwise keep as it is.

                l_freight_amount := l_final_appl_tbl(i).inv_hdr_rec.freight_amount;
                IF l_freight_amount = OKL_API.G_MISS_NUM OR l_freight_amount = 0 THEN
                  l_freight_amount := NULL;
                END IF;
                l_charges_amount := l_final_appl_tbl(i).inv_hdr_rec.charges_amount;
                IF l_charges_amount = OKL_API.G_MISS_NUM OR l_charges_amount = 0 THEN
                  l_charges_amount := NULL;
                END IF;
                IF (l_freight_amount IS NOT NULL OR l_charges_amount IS NOT NULL) AND
                   l_final_appl_tbl(i).inv_lines_tbl.count = 0 THEN
                   l_inv_lns_tbl.delete;
                   OPEN c_ar_inv_line_id(l_final_appl_tbl(i).inv_hdr_rec.invoice_id, l_org_id);
                   FETCH c_ar_inv_line_id INTO l_ar_invoice_line_id;
                   CLOSE c_ar_inv_line_id;
                   l_inv_lns_tbl(0).invoice_line_id := l_ar_invoice_line_id;
                   l_inv_lns_tbl(0).amount_applied := 0;
                   l_final_appl_tbl(i).inv_lines_tbl := l_inv_lns_tbl;
                END IF;
                log_debug('In the final count');

                IF l_final_appl_tbl(i).inv_lines_tbl.count <> 0 then
                   l_call_unapply := FALSE;
                   IF (l_final_appl_tbl(i).inv_hdr_rec.freight_amount IS NOT NULL OR l_final_appl_tbl(i).inv_hdr_rec.charges_amount IS NOT NULL) THEN
                       l_call_unapply := TRUE;
                   ELSE
                     FOR ll IN l_final_appl_tbl(i).inv_lines_tbl.FIRST..l_final_appl_tbl(i).inv_lines_tbl.LAST LOOP
                         IF nvl(l_final_appl_tbl(i).inv_lines_tbl(ll).original_applied_amount,0) <> l_final_appl_tbl(i).inv_lines_tbl(ll).amount_applied THEN
                           l_call_unapply := TRUE;
                         END IF;
                       END LOOP;
                   END IF;

                   IF l_call_unapply = TRUE THEN
                        unapply_receipt( p_api_version      => l_api_version,
                                         p_init_msg_list    => l_init_msg_list,
                                         x_return_status    => l_return_status,
                                         x_msg_count        => l_msg_count,
                                         x_msg_data         => l_msg_data,
                                         p_cash_receipt_id  => l_cash_receipt_id,
                                         p_customer_trx_id  => l_final_appl_tbl(i).inv_hdr_rec.invoice_id,
                                         p_org_id           => l_org_id);
                        log_debug('return status of unapply_receipt = '||l_return_status);
                        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
                          RAISE okl_api.g_exception_unexpected_error;
                        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
                          RAISE okl_api.g_exception_error;
                        END IF;
                   END IF;
                END IF;
      END LOOP;
      --Check if there is existing on-account amount
      If l_original_onacc_amount <> l_apply_onacc_amount Then
        If (Nvl(l_original_onacc_amount,0) > 0 ) Then
             -- Get onaccount application Id
             OPEN c_get_onacc_app_id(l_cash_receipt_id);
             FETCH c_get_onacc_app_id INTO l_onacc_appplication_id;
             CLOSE c_get_onacc_app_id;

             -- Unapply the on-account amount
             Ar_receipt_api_pub.Unapply_on_account(     p_api_version      => l_api_version,
                                                        p_init_msg_list    => l_init_msg_list,
                                                        x_return_status    => l_return_status ,
                                                        x_msg_count        => l_msg_count ,
                                                        x_msg_data        => l_msg_data,
                                                        p_cash_receipt_id  => l_cash_receipt_id,
                                                        p_receivable_application_id =>l_onacc_appplication_id,
                                                        p_reversal_gl_date => NULL,
                                                        p_org_id            => l_org_id
                                                        );
            log_debug('Return status of AR_RECEIPT_API_PUB.Unapply_on_account = '|| l_return_status);
            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        END IF;
      END IF;
      FOR i IN l_final_appl_tbl.FIRST..l_final_appl_tbl.LAST LOOP
                --If freight amount or charges amount is there then check whether
                --any invoice lines are there or not. If no then create one invoice line
                --with applied amount 0. Otherwise keep as it is.
                 --this code has been moved in above loop where we do unapplication, so commenting it out here
       /*         l_freight_amount := l_final_appl_tbl(i).inv_hdr_rec.freight_amount;
                IF l_freight_amount = OKL_API.G_MISS_NUM OR l_freight_amount = 0 THEN
                  l_freight_amount := NULL;
                END IF;
                l_charges_amount := l_final_appl_tbl(i).inv_hdr_rec.charges_amount;
                IF l_charges_amount = OKL_API.G_MISS_NUM OR l_charges_amount = 0 THEN
                  l_charges_amount := NULL;
                END IF;
                IF (l_freight_amount IS NOT NULL OR l_charges_amount IS NOT NULL) AND
                   l_final_appl_tbl(i).inv_lines_tbl.count = 0 THEN
                   l_inv_lns_tbl.delete;
                   OPEN c_ar_inv_line_id(l_final_appl_tbl(i).inv_hdr_rec.invoice_id, l_org_id);
                   FETCH c_ar_inv_line_id INTO l_ar_invoice_line_id;
                   CLOSE c_ar_inv_line_id;
                   l_inv_lns_tbl(0).invoice_line_id := l_ar_invoice_line_id;
                   l_inv_lns_tbl(0).amount_applied := 0;
                   l_final_appl_tbl(i).inv_lines_tbl := l_inv_lns_tbl;
                END IF;*/
                log_debug('In the final count');

                IF l_final_appl_tbl(i).inv_lines_tbl.count <> 0 then
                   l_call_apply := FALSE;
                   IF (l_final_appl_tbl(i).inv_hdr_rec.freight_amount IS NOT NULL OR l_final_appl_tbl(i).inv_hdr_rec.charges_amount IS NOT NULL) THEN
                       l_call_apply := TRUE;
                   ELSE
                     FOR ll IN l_final_appl_tbl(i).inv_lines_tbl.FIRST..l_final_appl_tbl(i).inv_lines_tbl.LAST LOOP
                         IF nvl(l_final_appl_tbl(i).inv_lines_tbl(ll).original_applied_amount,0) <> l_final_appl_tbl(i).inv_lines_tbl(ll).amount_applied THEN
                           l_call_apply := TRUE;
                         END IF;
                       END LOOP;
                   END IF;

                   IF l_call_apply = TRUE THEN
                        -- We need to derive the conversion rate if not provided for cross currency application
                        OPEN c_fetch_inv_currency(l_final_appl_tbl(i).inv_hdr_rec.invoice_id);
                        FETCH c_fetch_inv_currency INTO l_invoice_currency_code;
                        CLOSE c_fetch_inv_currency;

                        IF l_invoice_currency_code <> l_rcpt_rec.currency_code AND l_final_appl_tbl(i).inv_hdr_rec.trans_to_receipt_rate IS NULL
                        THEN
                           --Bug 7613040, by nikshah
                           --Modified usage of profile with AR system options
                           l_exchange_rate_type := cross_currency_rate_type(l_org_id); --fnd_profile.VALUE ('AR_CROSS_CURRENCY_RATE_TYPE');
                           IF l_exchange_rate_type IS NULL
                           THEN
                              okl_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => 'OKL_BPD_CONV_TYPE_NOT_FOUND'
                                 );
                              RAISE g_exception_halt_validation;
                           ELSE
                                l_trans_to_receipt_rate :=
                                   okl_accounting_util.get_curr_con_rate
                                                    (l_invoice_currency_code,
                                                     l_rcpt_rec.currency_code,
                                                     l_rcpt_rec.receipt_Date,
                                                     l_exchange_rate_type
                                                    );
                                IF l_trans_to_receipt_rate IN (0, -1)
                                THEN
                                   -- Message Text: No exchange rate defined
                                   x_return_status := okc_api.g_ret_sts_error;
                                   okc_api.set_message
                                    (p_app_name      => g_app_name,
                                     p_msg_name      => 'OKL_BPD_NO_EXCHANGE_RATE'
                                    );
                                   RAISE g_exception_halt_validation;
                                END IF;
                                l_final_appl_tbl(i).inv_hdr_rec.trans_to_receipt_rate := l_trans_to_receipt_rate;

                             END IF;
                        END IF;

                           apply_receipt( p_api_version   => l_api_version
                               ,p_init_msg_list => l_init_msg_list
                               ,x_return_status => l_return_status
                               ,x_msg_count     => l_msg_count
                               ,x_msg_data      => l_msg_data
                               ,p_cash_receipt_id => l_cash_receipt_id
                               ,p_customer_trx_id => l_final_appl_tbl(i).inv_hdr_rec.invoice_id
                               ,p_freight_amount  => l_freight_amount
                               ,p_charges_amount  => l_charges_amount
                               ,p_llca_tbl        => l_final_appl_tbl(i).inv_lines_tbl
                               ,p_apply_gl_date   => l_final_appl_tbl(i).inv_hdr_rec.gl_date
                               ,p_org_id          => l_org_id
                               ,p_receipt_date => l_rcpt_rec.receipt_date
                               ,p_gl_date => l_rcpt_rec.gl_date
                               ,p_trans_to_receipt_rate  => l_final_appl_tbl(i).inv_hdr_rec.trans_to_receipt_rate
                                        );

                           IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
                             RAISE okl_api.g_exception_unexpected_error;
                           ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
                             RAISE okl_api.g_exception_error;
                           END IF;
                   END IF;
                ELSE
                     l_final_appl_tbl(i).inv_hdr_rec.trans_to_receipt_rate := NULL;
                END IF;



      END LOOP;
    END IF;
log_debug('Before handle_onacc_update l_original_onacc_amount : '||l_original_onacc_amount);
log_debug('Before handle_onacc_update l_apply_onacc_amount : '||l_apply_onacc_amount);
--Begin - Handle On-Account Application
If l_original_onacc_amount <> l_apply_onacc_amount Then
        --Validate the On-Account Amount
        IF l_appl_tbl.count = 0  THEN
                If l_rcpt_rec.amount < l_apply_onacc_amount THEN
                        OKL_API.set_message( p_app_name      => G_APP_NAME,
                                                p_msg_name      => 'OKL_RCPT_TOT_AMT_GT_UNAPP_AMT');

                        RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
        END IF;

        handle_onacc_update(
                                p_api_version    => l_api_version
                                ,p_init_msg_list    => l_init_msg_list
                                ,x_return_status     => l_return_status
                                ,x_msg_count         => l_msg_count
                                ,x_msg_data          => l_msg_data
                                ,p_cash_receipt_id   => l_cash_receipt_id
                                ,p_org_id            => l_org_id
                                ,p_original_onacc_amount => l_original_onacc_amount
                                ,p_apply_onacc_amount =>  l_apply_onacc_amount
                                ,p_receipt_date => l_rcpt_rec.receipt_date
                                ,p_gl_date => l_rcpt_rec.gl_date);

        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
                RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
                RAISE okl_api.g_exception_error;
        END IF;
END IF;

--End - Handle On-Account Application

    okl_api.end_activity(l_msg_count,l_msg_data);
    x_msg_data := l_msg_data;
    x_msg_count := l_msg_count;
    x_return_status := l_return_status;
    log_debug('okl_receipts_pvt.handle_receipt End -');
  EXCEPTION
    WHEN g_exception_halt_validation THEN
      x_return_status := okl_api.g_ret_sts_error;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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
  END handle_receipt;

  FUNCTION cross_currency_rate_type
    (p_org_id IN NUMBER)
  RETURN VARCHAR2
  IS
    l_cc_rate_type VARCHAR2(30);
   CURSOR c_ar_rate_type(p_org_id NUMBER) IS
   SELECT  cross_currency_rate_type
   FROM AR_SYSTEM_PARAMETERS_ALL
   WHERE org_id=p_org_id;

  BEGIN

   OPEN c_ar_rate_type(p_org_id);
   FETCH c_ar_rate_type INTO l_cc_rate_type;
   CLOSE c_ar_rate_type;

  RETURN l_cc_rate_type;
  EXCEPTION
    WHEN OTHERS THEN
	   Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

  END cross_currency_rate_type;

END okl_receipts_pvt;

/
