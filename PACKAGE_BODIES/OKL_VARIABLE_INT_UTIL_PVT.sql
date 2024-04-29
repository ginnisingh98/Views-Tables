--------------------------------------------------------
--  DDL for Package Body OKL_VARIABLE_INT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VARIABLE_INT_UTIL_PVT" AS
/* $Header: OKLRVIUB.pls 120.29 2008/05/02 20:07:55 sechawla noship $ */
  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:    get_interest_billed
    -- Description:      This Function is called to get interest billed for a date range
    --                   Inputs :
    --                   Output : Interest Billed
    -- Dependencies:
    -- Parameters:       Contract id, Start Date, End Date
    -- Version:          1.0
    -- End of Comments
  ------------------------------------------------------------------------------

  FUNCTION get_interest_billed(
     x_return_status  OUT NOCOPY VARCHAR2,
     p_khr_id         IN NUMBER,
     p_from_date      IN DATE,
     p_to_date        IN DATE DEFAULT SYSDATE) RETURN NUMBER IS

    l_debug_enabled         VARCHAR2(1);
    l_module    CONSTANT    fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_INTEREST_BILLED';
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);

    l_interest_billed       NUMBER;

-- Begin - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007
    CURSOR l_interest_billed_csr(cp_khr_id IN NUMBER, cp_from_date IN DATE, cp_to_date IN DATE) IS
    -- Begin bug 6456733
    -- dcshanmu bug 6734738 start
    --SELECT NVL(SUM(AMOUNT),0) interest_billed_amount
    --FROM okl_bpd_ar_inv_lines_v lpt1
    --where contract_id=cp_khr_id
    --and  RECEIVABLES_INVOICE_ID in
    --(
      SELECT NVL(SUM(AMOUNT),0) interest_billed_amount -- lpt.RECEIVABLES_INVOICE_ID
      --dcshanmu bug 6734738 end
      FROM   okl_bpd_ar_inv_lines_v lpt,
           okl_strm_type_b sty,
           ar_payment_schedules_all aps,
           okl_k_headers_full_v khr
      --dcshanmu bug 6734738 start
      WHERE  lpt.contract_id  = cp_khr_id
      --dcshanmu bug 6734738 end
      AND    lpt.contract_number  = khr.contract_number
      AND    lpt.sty_id  = sty.id
      AND    lpt.RECEIVABLES_INVOICE_ID = aps.customer_trx_id
      AND    sty.stream_type_purpose
                   IN ('INTEREST_PAYMENT', 'VARIABLE_INTEREST','INTEREST_CATCHUP')
      AND    TRUNC(aps.trx_date) BETWEEN TRUNC(NVL(cp_from_date, khr.start_date))
      AND TRUNC(NVL(cp_to_date,SYSDATE))
      --dcshanmu bug 6734738 start
     --)
     ;
     --dcshanmu bug 6734738 end
    -- End bug 6456733


--    SELECT SUM(interest_billed_amount) interest_billed_amount FROM
--    (
    -- SELECT NVL(SUM(aps.amount_due_original), 0) interest_billed_amount
--    SELECT NVL(SUM(aps.amount_line_items_original),0) interest_billed_amount --End bug# 5767426
--    FROM    okl_bpd_tld_ar_lines_v tld,
--           okl_strm_type_b sty,
--           ar_payment_schedules_all aps,
--           okl_k_headers_full_v khr
--    WHERE	 tld.khr_id  = cp_khr_id
--    AND    tld.khr_id  = khr.id
--    AND	   tld.sty_id  = sty.id
--    AND    sty.stream_type_purpose   IN ('INTEREST_PAYMENT', 'VARIABLE_INTEREST','INTEREST_CATCHUP')
--    AND    tld.customer_trx_id = aps.customer_trx_id
--    AND    TRUNC(aps.trx_date) BETWEEN TRUNC(NVL(cp_from_date, khr.start_date))
--    AND TRUNC(NVL(cp_to_date, SYSDATE)) );
-- End - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007


    -- 4933500
/*
    UNION
    SELECT sum(aps.amount_due_original) interest_billed_amount
    FROM  okl_cnsld_ar_strms_b lsm,
          okl_strm_type_v sty,
          okl_strm_elements sel,
          ar_payment_schedules_all aps,
          okl_k_headers_full_v khr
    WHERE lsm.khr_id = cp_khr_id
    AND lsm.khr_id = khr.id
    AND lsm.sty_id = sty.id
    AND sty.stream_type_purpose = 'VARIABLE_LOAN_PAYMENT'
    AND lsm.sel_id = sel.id
    AND sel.sel_id IS NULL
    AND lsm.receivables_invoice_id = aps.customer_trx_id
    AND TRUNC(aps.trx_date) BETWEEN TRUNC(NVL(cp_from_date, khr.start_date)) AND TRUNC(NVL(cp_to_date, SYSDATE)));
*/
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_interest_billed');
    END IF;

    l_interest_billed := 0;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN l_interest_billed_csr(p_khr_id, p_from_date, p_to_date);
    FETCH l_interest_billed_csr INTO l_interest_billed;
    CLOSE l_interest_billed_csr;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_interest_billed');
    END IF;

    RETURN l_interest_billed;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_interest_billed;
    WHEN OTHERS THEN
      IF l_interest_billed_csr%ISOPEN THEN
        CLOSE l_interest_billed_csr;
      END IF;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
      RETURN l_interest_billed;
  END get_interest_billed;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:    get_interest_paid
    -- Description:      This Function is called to get interest paid for a date range
    --                   Inputs :
    --                   Output : Interest Paid
    -- Dependencies:
    -- Parameters:       Contract id, Start Date, End Date
    -- Version:          1.0
    -- End of Comments
  ------------------------------------------------------------------------------

  FUNCTION get_interest_paid(
     x_return_status  OUT NOCOPY VARCHAR2,
     p_khr_id         IN NUMBER,
     p_from_date      IN DATE,
     p_to_date        IN DATE DEFAULT SYSDATE) RETURN NUMBER IS

    l_debug_enabled         VARCHAR2(1);
    l_module    CONSTANT    fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_INTEREST_PAID';
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);

    l_interest_paid          NUMBER;

--Begin - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007

CURSOR l_interest_paid_csr(cp_khr_id IN NUMBER, cp_from_date IN DATE, cp_to_date IN DATE) IS
-- Begin bug 6456733
  SELECT NVL(SUM(interest_paid_amount),0) interest_paid_amount
  FROM
  (
    SELECT NVL(SUM(AMOUNT),0)- NVL(SUM(AMOUNT_LINE_ITEMS_REMAINING),0) interest_paid_amount
    FROM okl_bpd_ar_inv_lines_v lpt1
    where contract_id=cp_khr_id
    and  RECEIVABLES_INVOICE_ID in
    (
      SELECT  RECEIVABLES_INVOICE_ID
      FROM
        okl_bpd_ar_inv_lines_v lpt,
        okl_strm_type_b sty,
        ar_payment_schedules_all aps,
        okl_k_headers_full_v khr
      WHERE
           lpt.contract_id  = lpt1.contract_id
      AND  lpt.contract_number  = khr.contract_number
      AND  lpt.sty_id  = sty.id
      AND  lpt.RECEIVABLES_INVOICE_ID = aps.customer_trx_id
      AND  sty.stream_type_purpose   IN
      ('INTEREST_PAYMENT', 'VARIABLE_INTEREST','INTEREST_CATCHUP')
      AND    TRUNC(aps.trx_date)
        BETWEEN TRUNC(NVL(cp_from_date, khr.start_date)) AND TRUNC(NVL(cp_to_date, SYSDATE))
    )
    group by RECEIVABLES_INVOICE_ID
    having NVL(SUM(AMOUNT),0) < NVL(SUM(AMOUNT_LINE_ITEMS_REMAINING),0)
    UNION ALL
    SELECT   NVL(SUM(sel.amount),0) interest_paid_amount
    FROM     okl_strm_type_v sty,
             okl_streams_v stm,
             okl_strm_elements sel,
             okc_k_headers_b khr
    WHERE    stm.khr_id = cp_khr_id
    AND      stm.kle_id = NVL(null, stm.kle_id)
    AND      stm.khr_id = khr.id
    AND      stm.sty_id                  = sty.id
    AND      sty.stream_type_purpose     = 'DAILY_INTEREST_INTEREST'
    AND      stm.id = sel.stm_id
    AND      TRUNC(sel.stream_element_date)
        BETWEEN TRUNC(NVL(cp_from_date, khr.start_date)) AND TRUNC(NVL(cp_to_date, SYSDATE))
    );

    --SELECT SUM(interest_paid_amount) FROM
    --(SELECT   NVL(SUM(app.line_applied),0) interest_paid_amount
    --FROM     ar_receivable_applications_all app,
             --ar_cash_receipts_all cra,
             --ar_payment_schedules_all sch,
             --okl_bpd_tld_ar_lines_v tld,
             --okl_strm_type_v sty,
             --okl_k_headers_full_v khr
    --WHERE    TRUNC(cra.receipt_date)       BETWEEN TRUNC(NVL(cp_from_date, cra.receipt_date)) AND TRUNC(NVL(cp_to_date, SYSDATE))
    --AND      app.status                  = 'APP'
    --AND      app.applied_payment_schedule_id = sch.payment_schedule_id
    --AND      app.cash_receipt_id = cra.cash_receipt_id
    --AND      sch.class                   = 'INV'
    --AND      sch.customer_trx_id         = tld.customer_trx_id
    --AND      tld.khr_id                  = cp_khr_id
    --AND      tld.khr_id                  = khr.id
    --AND      tld.sty_id                  = sty.id
    --AND      sty.stream_type_purpose    IN ('INTEREST_PAYMENT', 'VARIABLE_INTEREST','INTEREST_CATCHUP')
    --UNION
    ----fix for bug # 4746404
    --SELECT   NVL(SUM(sel.amount),0) interest_paid_amount
    --FROM     okl_strm_type_v sty,
             --okl_streams_v stm,
             --okl_strm_elements sel,
             --okc_k_headers_b khr
    --WHERE    stm.khr_id = cp_khr_id
    --AND      stm.khr_id = khr.id
    --AND      stm.sty_id                  = sty.id
    --AND      sty.stream_type_purpose     = 'DAILY_INTEREST_INTEREST'
    --AND      stm.id = sel.stm_id
    --AND      TRUNC(sel.stream_element_date)       BETWEEN TRUNC(NVL(cp_from_date, khr.start_date)) AND TRUNC(NVL(cp_to_date, SYSDATE)));
-- End - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007

-- End bug 6456733

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_interest_paid');
    END IF;

    l_interest_paid := 0;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN l_interest_paid_csr(p_khr_id, p_from_date, p_to_date);
    FETCH l_interest_paid_csr INTO l_interest_paid;
    CLOSE l_interest_paid_csr;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_interest_paid');
    END IF;

    RETURN l_interest_paid;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_interest_paid;
    WHEN OTHERS THEN
      IF l_interest_paid_csr%ISOPEN THEN
        CLOSE l_interest_paid_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
      RETURN l_interest_paid;
  END get_interest_paid;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:    get_interest_due
    -- Description:      This Function is called to get interest due for a date range
    --                   Inputs :
    --                   Output : Interest Due
    -- Dependencies:
    -- Parameters:       Contract id, Effective Date
    -- Version:          1.0
    -- End of Comments
  ------------------------------------------------------------------------------

  FUNCTION get_interest_due(
     x_return_status  OUT NOCOPY VARCHAR2,
     p_khr_id         IN NUMBER,
     p_to_date        IN DATE DEFAULT SYSDATE) RETURN NUMBER IS

    l_api_version   CONSTANT  NUMBER := 1.0;
    x_msg_count               NUMBER;
    x_msg_data                VARCHAR2(2000);
    l_debug_enabled           VARCHAR2(1);
    l_module        CONSTANT  fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_INTEREST_DUE';

    l_principal_basis         okl_k_rate_params.principal_basis_code%TYPE;
    l_start_date              DATE;
    l_end_date                DATE;
    l_to_date                 DATE;
    l_due_date                DATE;
    l_next_period_start_date  DATE;
    l_next_period_end_date    DATE;
    l_interest_amt            NUMBER;
    l_interest_due            NUMBER;
    l_int_calc_basis          OKL_PRODUCT_PARAMETERS_V.interest_calculation_basis%TYPE;
    l_rev_rec_mthd            OKL_PRODUCT_PARAMETERS_V.revenue_recognition_method%TYPE;

    CURSOR l_principal_basis_csr(cp_khr_id IN NUMBER) IS
    SELECT principal_basis_code
    FROM   okl_k_rate_params
    WHERE  khr_id = cp_khr_id
    AND    parameter_type_code = 'ACTUAL'
    AND    TRUNC(SYSDATE) BETWEEN effective_from_date AND NVL(effective_to_date, TRUNC(SYSDATE));

    CURSOR l_contract_info_csr(cp_khr_id IN NUMBER) IS
    SELECT chr.start_date,
	       chr.currency_code,
	       chr.end_date
    FROM   OKC_K_HEADERS_B chr,
           OKL_K_HEADERS khr
    WHERE  chr.id     = khr.id
    AND    khr.id = cp_khr_id;

    CURSOR l_int_calc_basis_csr(cp_khr_id IN NUMBER) IS
    SELECT ppm.interest_calculation_basis
          ,ppm.revenue_recognition_method
    FROM   okl_k_headers   khr,
           okl_product_parameters_v ppm
    WHERE  khr.id = cp_khr_id
    AND    khr.pdt_id = ppm.id;

    CURSOR l_interest_due_csr (cp_khr_id NUMBER,
                               p_due_date  DATE) IS
        SELECT NVL(SUM(amount),0)
        FROM  okl_strm_elements sel,
              okl_streams str,
              okl_strm_type_v sty
            WHERE  sel.stm_id = str.id
              AND  str.khr_id = cp_khr_id
              AND  str.say_code = 'CURR'
              AND  str.active_yn = 'Y'
              AND  sel.stream_element_date <= p_due_date
              AND  str.sty_id = sty.id
              AND  sty.stream_type_purpose = 'INTEREST_PAYMENT';

    l_contract_info_rec   l_contract_info_csr%ROWTYPE;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_interest_due');
    END IF;

    l_interest_amt := 0;
    l_interest_due := 0;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN l_principal_basis_csr(p_khr_id);
    FETCH l_principal_basis_csr INTO l_principal_basis;
    CLOSE l_principal_basis_csr;

    --change for bug fix 4905791
    IF (l_principal_basis IS NULL) THEN
      --this is set to SCHEDULED so that the code works for Fixed Loans as well
      l_principal_basis := 'SCHEDULED';
    END IF;

    OPEN l_contract_info_csr(p_khr_id);
    FETCH l_contract_info_csr INTO l_contract_info_rec;
    CLOSE l_contract_info_csr;

    l_start_date := l_contract_info_rec.start_date;
    l_end_date   := l_contract_info_rec.end_date;

    IF (l_end_date <= p_to_date) THEN
      l_to_date := l_end_date;
    ELSE
  	  l_to_date := p_to_date;
  	END IF;

    OPEN  l_int_calc_basis_csr(p_khr_id);
    FETCH l_int_calc_basis_csr INTO l_int_calc_basis, l_rev_rec_mthd;
    CLOSE l_int_calc_basis_csr;


    --change for bug fix 4905791
    IF (l_rev_rec_mthd = 'ACTUAL') THEN
      l_interest_due := OKL_VARIABLE_INTEREST_PVT.calculate_total_interest_due(
                                      p_api_version     => l_api_version,
                                      p_init_msg_list   => OKL_API.G_FALSE,
                                      x_return_status   => x_return_status,
                                      x_msg_count       => x_msg_count,
                                      x_msg_data        => x_msg_data,
                                      p_contract_id     => p_khr_id,
                                      p_currency_code   => l_contract_info_rec.currency_code,
                                      p_start_date      => l_start_date,
                                      p_due_date        => l_to_date,
                                      p_principal_basis => 'ACTUAL');

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSE

      IF l_principal_basis = 'ACTUAL' THEN
        l_interest_due := OKL_VARIABLE_INTEREST_PVT.calculate_total_interest_due(
                                        p_api_version     => l_api_version,
                                        p_init_msg_list   => OKL_API.G_FALSE,
                                        x_return_status   => x_return_status,
                                        x_msg_count       => x_msg_count,
                                        x_msg_data        => x_msg_data,
                                        p_contract_id     => p_khr_id,
                                        p_currency_code   => l_contract_info_rec.currency_code,
                                        p_start_date      => l_start_date,
                                        p_due_date        => l_to_date,
                                        p_principal_basis => 'ACTUAL');
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSIF l_principal_basis = 'SCHEDULED' THEN
        /*OPEN  l_int_calc_basis_csr(p_khr_id);
        FETCH l_int_calc_basis_csr INTO l_int_calc_basis;
        CLOSE l_int_calc_basis_csr;*/

        --change for bug fix 4905791
        IF (l_int_calc_basis IN ('REAMORT', 'FIXED')) THEN
          OPEN  l_interest_due_csr(p_khr_id, l_to_date);
          FETCH l_interest_due_csr INTO l_interest_due;
          CLOSE l_interest_due_csr;
        ELSIF (l_int_calc_basis = 'FLOAT') THEN
          LOOP
            OKL_STREAM_GENERATOR_PVT.get_next_billing_date(
                                          p_api_version            => l_api_version,
                                          p_init_msg_list          => OKL_API.G_FALSE,
                                          p_khr_id                 => p_khr_id,
                                          p_billing_date           => l_start_date,
                                          x_next_due_date          => l_due_date,
                                          x_next_period_start_date => l_next_period_start_date,
                                          x_next_period_end_date   => l_next_period_end_date,
                                          x_return_status          => x_return_status,
                                          x_msg_count              => x_msg_count,
                                          x_msg_data               => x_msg_data);
            IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            --dkagrawa changed condition from > to >= for bug 4742907
            --dkagrawa handled nvl for fully billed contract bug#6660659
            IF nvl(l_due_date,l_to_date) >= l_to_date THEN
              l_due_date := l_to_date;
            END IF;
            l_interest_amt := OKL_VARIABLE_INTEREST_PVT.calculate_total_interest_due(
                                          p_api_version     => l_api_version,
                                          p_init_msg_list   => OKL_API.G_FALSE,
                                          x_return_status   => x_return_status,
                                          x_msg_count       => x_msg_count,
                                          x_msg_data        => x_msg_data,
                                          p_contract_id     => p_khr_id,
                                          p_currency_code   => l_contract_info_rec.currency_code,
                                          p_start_date      => l_next_period_start_date,
                                          p_due_date        => l_due_date,
                                          p_principal_basis => 'SCHEDULED');

            IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_interest_due := l_interest_due + l_interest_amt;
            IF l_due_date >= l_to_date THEN
              EXIT;
            END IF;
            l_start_date := l_due_date;
          END LOOP;
        END IF;
      END IF;
    END IF;
  IF(NVL(l_debug_enabled,'N')='Y') THEN
    okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_interest_due');
  END IF;

  RETURN l_interest_due;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_interest_due;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_interest_due;
    WHEN OTHERS THEN
      IF l_principal_basis_csr%ISOPEN THEN
        CLOSE l_principal_basis_csr;
      END IF;
      IF l_contract_info_csr%ISOPEN THEN
        CLOSE l_contract_info_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
      RETURN l_interest_due;
  END get_interest_due;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:    get_principal_bal
    -- Description:      This Function is called to get principal balance on a
    --                   contract for a loan as of a given date
    --                   Inputs :
    --                   Output : Principal Balance
    -- Dependencies:
    -- Parameters:       Contract id, Effective Date
    -- Version:          1.0
	-- History      :    sechawla 02-may-08 6939451  Set the contract id and deal type
	--                   when default proncipal basis is used.
    -- End of Comments
  -----------------------------------------------------------------------------

  FUNCTION get_principal_bal(
     x_return_status  OUT NOCOPY VARCHAR2,
     p_khr_id         IN NUMBER,
     p_kle_id         IN NUMBER,
     p_date           IN DATE) RETURN NUMBER IS

    l_api_version           CONSTANT NUMBER := 1.0;
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);
    l_debug_enabled         VARCHAR2(1);
    l_module    CONSTANT    fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_PRINCIPAL_BAL';

    l_start_date            DATE;
    l_principal_basis       okl_k_rate_params.principal_basis_code%TYPE;
    l_principal_balance_tbl okl_variable_interest_pvt.principal_balance_tbl_typ;
    l_principal_bal         NUMBER;
    l_stream_element_date   DATE;

    CURSOR l_principal_basis_csr(cp_khr_id IN NUMBER) IS
    SELECT chr.start_date, rpm.principal_basis_code
    FROM   okc_k_headers_b chr,
           okl_k_headers khr,
           okl_k_rate_params rpm
    WHERE  chr.id     = khr.id
    AND    rpm.khr_id = khr.id
    AND    rpm.parameter_type_code = 'ACTUAL'
    AND    TRUNC(SYSDATE) BETWEEN rpm.effective_from_date AND NVL(rpm.effective_to_date, TRUNC(SYSDATE))
    AND    khr.id = cp_khr_id;

  Cursor sch_asset_prin_bal_date_csr (p_contract_id NUMBER,
                                      p_line_id     NUMBER,
                                      p_due_date  DATE) IS

        SELECT MAX(sel.stream_element_date)
        FROM
             okl_strm_elements sel
             ,okl_streams str
             ,okl_strm_type_v sty
            WHERE  sel.stm_id = str.id
              AND  str.khr_id = p_contract_id
              AND  str.kle_id = p_line_id
              AND  str.say_code = 'CURR'
              AND  str.active_yn = 'Y'
              AND  sel.stream_element_date <= p_due_date
              AND  str.sty_id = sty.id
              AND  sty.stream_type_purpose = 'PRINCIPAL_BALANCE';

  Cursor sch_ctr_prin_bal_date_csr (p_contract_id NUMBER,
                                    p_due_date  DATE) IS
        SELECT MAX(sel.stream_element_date)
        FROM
             okl_strm_elements sel
             ,okl_streams str
             ,okl_strm_type_v sty
            WHERE  sel.stm_id = str.id
              AND  str.khr_id = p_contract_id
              AND  str.say_code = 'CURR'
              AND  str.active_yn = 'Y'
              AND  sel.stream_element_date <= p_due_date
              AND  str.sty_id = sty.id
              AND  sty.stream_type_purpose = 'PRINCIPAL_BALANCE';

    --change for bug fix 4905791
    CURSOR l_int_calc_basis_csr(cp_khr_id IN NUMBER) IS
    SELECT ppm.interest_calculation_basis
          ,ppm.revenue_recognition_method
    FROM   okl_k_headers   khr,
           okl_product_parameters_v ppm
    WHERE  khr.id = cp_khr_id
    AND    khr.pdt_id = ppm.id;

	-- sechawla 02-may-08 6939451 Addec this cursor
	Cursor contract_csr (p_contract_id NUMBER) IS
      SELECT deal_type
      FROM   okl_k_headers
      WHERE  id = p_contract_id;

    l_int_calc_basis          OKL_PRODUCT_PARAMETERS_V.interest_calculation_basis%TYPE;
    l_rev_rec_mthd            OKL_PRODUCT_PARAMETERS_V.revenue_recognition_method%TYPE;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_principal_bal');
    END IF;

    l_principal_bal := 0;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN l_principal_basis_csr(p_khr_id);
    FETCH l_principal_basis_csr INTO l_start_date,l_principal_basis;
    CLOSE l_principal_basis_csr;

    --change for bug fix 4905791
    IF (l_principal_basis IS NULL) THEN
      --this is set to SCHEDULED so that the code works for Fixed Loans as well
      l_principal_basis := 'SCHEDULED';

	  -- sechawla 02-may-08 6939451 : When interest rate parametrs are not defined on the contract,
	  -- default principal basis 'SCHEDULED' is used, as per the existing assignment above
	  -- But in OKL_VARIABLE_INTEREST_PVT, the code tries to fetch principal basis again from the
	  -- interst rate paramaters on the contract, and fails when not found. This check is done based upon the
	  -- value of OKL_VARIABLE_INTEREST_PVT.G_CONTRACT_ID. If this global is not set, validation is done, but
	  -- If it is set, validation is by passed. Since in this case, validation is not needed, setting the
	  -- following 2 globals here, so OKL_VARIABLE_INTEREST_PVT can proceed with the default principal basis.
	  OKL_VARIABLE_INTEREST_PVT.G_CONTRACT_ID := p_khr_id;
	  OPEN  contract_csr (p_khr_id);
	  FETCH contract_csr INTO OKL_VARIABLE_INTEREST_PVT.G_DEAL_TYPE;
	  CLOSE contract_csr;
	  -- sechawla 02-may-08 6939451 : end

    END IF;


    --change for bug fix 4905791
    OPEN  l_int_calc_basis_csr(p_khr_id);
    FETCH l_int_calc_basis_csr INTO l_int_calc_basis, l_rev_rec_mthd;
    CLOSE l_int_calc_basis_csr;

    --change for bug fix 4905791
    IF (l_principal_basis = 'ACTUAL' OR l_rev_rec_mthd = 'ACTUAL') THEN
      OKL_VARIABLE_INTEREST_PVT.prin_date_range_var_rate_ctr (
                p_api_version        => l_api_version,
                p_init_msg_list      => OKL_API.G_FALSE,
                x_return_status      => x_return_status,
                x_msg_count          => x_msg_count,
                x_msg_data           => x_msg_data,
                p_contract_id        => p_khr_id,
                p_line_id            => p_kle_id,
                p_start_date         => l_start_date,
                p_due_date           => p_date,
                p_principal_basis    => 'ACTUAL',
                x_principal_balance_tbl => l_principal_balance_tbl);

    ELSIF l_principal_basis = 'SCHEDULED' THEN
      IF (p_kle_id IS NOT NULL) THEN
        OPEN sch_asset_prin_bal_date_csr(p_khr_id, p_kle_id,p_date);
        FETCH sch_asset_prin_bal_date_csr INTO l_stream_element_date;
        CLOSE sch_asset_prin_bal_date_csr;
      ELSE
        OPEN sch_ctr_prin_bal_date_csr(p_khr_id, p_date);
        FETCH sch_ctr_prin_bal_date_csr INTO l_stream_element_date;
        CLOSE sch_ctr_prin_bal_date_csr;
      END IF;

      IF (l_stream_element_date IS NULL) THEN
        RETURN 0;
      END IF;

      OKL_VARIABLE_INTEREST_PVT.prin_date_range_var_rate_ctr (
                p_api_version        => l_api_version,
                p_init_msg_list      => OKL_API.G_FALSE,
                x_return_status      => x_return_status,
                x_msg_count          => x_msg_count,
                x_msg_data           => x_msg_data,
                p_contract_id        => p_khr_id,
                p_line_id            => p_kle_id,
                p_start_date         => l_stream_element_date,
                p_due_date           => l_stream_element_date,
                p_principal_basis    => 'SCHEDULED',
                x_principal_balance_tbl => l_principal_balance_tbl);
    END IF;

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_principal_balance_tbl.COUNT > 0 THEN
      l_principal_bal := l_principal_balance_tbl(l_principal_balance_tbl.COUNT).principal_balance;
    END IF;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_principal_bal');
    END IF;

    RETURN l_principal_bal;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

	  -- sechawla 02-may-08 6939451
	  IF contract_csr%ISOPEN THEN
	     CLOSE contract_csr;
	  END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_principal_bal;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

	  -- sechawla 02-may-08 6939451
	  IF contract_csr%ISOPEN THEN
	     CLOSE contract_csr;
	  END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_principal_bal;
    WHEN OTHERS THEN

	  -- sechawla 02-may-08 6939451
	  IF contract_csr%ISOPEN THEN
	     CLOSE contract_csr;
	  END IF;

      IF l_principal_basis_csr%ISOPEN THEN
        CLOSE l_principal_basis_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
      RETURN l_principal_bal;
  END get_principal_bal;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:    get_principal_paid
    -- Description:      This Function is called to get principal paid for a
    --                   date range for revolving loan
    --                   Inputs :
    --                   Output : Principal Paid
    -- Dependencies:
    -- Parameters:       Contract id, Asset Line id, From Date, To Date
    -- Version:          1.0
    -- End of Comments
  -----------------------------------------------------------------------------

  FUNCTION get_principal_paid(
     x_return_status  OUT NOCOPY VARCHAR2,
     p_khr_id         IN NUMBER,
     p_kle_id         IN NUMBER,
     p_from_date      IN DATE,
     p_to_date        IN DATE DEFAULT SYSDATE) RETURN NUMBER IS

    l_debug_enabled         VARCHAR2(1);
    l_module    CONSTANT    fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_PRINCIPAL_PAID';
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);

    l_principal_paid        NUMBER;

-- Begin - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007
  -- Begin bug 6456733
  -- CURSOR l_principal_paid_csr(cp_khr_id IN NUMBER, cp_kle_id IN NUMBER, cp_from_date IN DATE, cp_to_date IN DATE) IS
    CURSOR l_principal_paid_csr(cp_khr_id IN NUMBER, cp_from_date IN DATE, cp_to_date IN DATE) IS
  SELECT SUM(principal_paid_amount) principal_paid_amount
  FROM
  (
    SELECT SUM(AMOUNT)- SUM(AMOUNT_LINE_ITEMS_REMAINING) principal_paid_amount
    FROM okl_bpd_ar_inv_lines_v lpt1
    where contract_id=cp_khr_id
    and  RECEIVABLES_INVOICE_ID in
    (
      SELECT  RECEIVABLES_INVOICE_ID
      FROM
        okl_bpd_ar_inv_lines_v lpt,
        okl_strm_type_b sty,
        ar_payment_schedules_all aps,
        okl_k_headers_full_v khr
      WHERE
           lpt.contract_id  = lpt1.contract_id
      AND  lpt.contract_number  = khr.contract_number
      AND  lpt.sty_id  = sty.id
      AND  lpt.RECEIVABLES_INVOICE_ID = aps.customer_trx_id
      AND  sty.stream_type_purpose   IN
      ('PRINCIPAL_PAYMENT', 'UNSCHEDULED_PRINCIPAL_PAYMENT','PRINCIPAL_CATCHUP')
      AND    TRUNC(aps.trx_date)
        BETWEEN TRUNC(NVL(cp_from_date, khr.start_date)) AND TRUNC(NVL(cp_to_date, SYSDATE))
    )
    group by RECEIVABLES_INVOICE_ID
    having SUM(AMOUNT_LINE_ITEMS_REMAINING)< SUM(AMOUNT)
    UNION ALL
    SELECT   NVL(SUM(sel.amount),0) principal_paid_amount
    FROM     okl_strm_type_v sty,
             okl_streams_v stm,
             okl_strm_elements sel,
             okc_k_headers_b khr
    WHERE    stm.khr_id = cp_khr_id
    AND      stm.kle_id = NVL(null, stm.kle_id)
    AND      stm.khr_id = khr.id
    AND      stm.sty_id                  = sty.id
    AND      sty.stream_type_purpose     = 'DAILY_INTEREST_PRINCIPAL'
    AND      stm.id = sel.stm_id
    AND      TRUNC(sel.stream_element_date)
        BETWEEN TRUNC(NVL(cp_from_date, khr.start_date)) AND TRUNC(NVL(cp_to_date, SYSDATE))
    );

  -- End bug 6456733
    --SELECT SUM(principal_paid_amount) FROM
    --(
      -- SELECT NVL(SUM(app.amount_applied),0) principal_paid_amount
    --SELECT NVL(SUM(app.line_applied),0)  principal_paid_amount --End bug# 5767426
    --FROM   ar_receivable_applications_all app,
           --ar_cash_receipts_all cra,
           --ar_payment_schedules_all sch,
           --okl_bpd_tld_ar_lines_v tld,
           --okl_strm_type_v sty,
           --okl_k_headers_full_v khr
    --WHERE  TRUNC(cra.receipt_date)       BETWEEN TRUNC(NVL(cp_from_date, cra.receipt_date)) AND TRUNC(NVL(cp_to_date, SYSDATE))
    --AND    app.cash_receipt_id = cra.cash_receipt_id
    --AND    app.status                  = 'APP'
    --AND    app.applied_payment_schedule_id = sch.payment_schedule_id
    --AND    sch.class                   = 'INV'
    --AND    sch.customer_trx_id         = tld.customer_trx_id
    --AND    tld.khr_id                  = cp_khr_id
    --AND    tld.kle_id                  = NVL(cp_kle_id, tld.kle_id)
    --AND    tld.khr_id                  = khr.id
    --AND    tld.sty_id                  = sty.id
    --AND    sty.stream_type_purpose    IN ('PRINCIPAL_PAYMENT', 'UNSCHEDULED_PRINCIPAL_PAYMENT', 'PRINCIPAL_CATCHUP')
    --UNION
    --SELECT   NVL(SUM(sel.amount),0) principal_paid_amount
    --FROM     okl_strm_type_v sty,
             --okl_streams_v stm,
             --okl_strm_elements sel,
             --okc_k_headers_b khr
    --WHERE    stm.khr_id = cp_khr_id
    --AND      stm.kle_id = NVL(cp_kle_id, stm.kle_id)
    --AND      stm.khr_id = khr.id
    --AND      stm.sty_id                  = sty.id
    --AND      sty.stream_type_purpose     = 'DAILY_INTEREST_PRINCIPAL'
    --AND      stm.id = sel.stm_id
    --AND      TRUNC(sel.stream_element_date) BETWEEN TRUNC(NVL(cp_from_date, khr.start_date)) AND TRUNC(NVL(cp_to_date, SYSDATE)));
-- End - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007


  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_principal_paid');
    END IF;

    l_principal_paid := 0;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    -- Begin bug 6456733
    --OPEN l_principal_paid_csr(p_khr_id, p_kle_id, p_from_date, p_to_date);
    OPEN l_principal_paid_csr(p_khr_id, p_from_date, p_to_date);
    -- End bug 6456733
    FETCH l_principal_paid_csr INTO l_principal_paid;
    CLOSE l_principal_paid_csr;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_principal_paid');
    END IF;

    RETURN l_principal_paid;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_principal_paid;
    WHEN OTHERS THEN
      IF l_principal_paid_csr%ISOPEN THEN
        CLOSE l_principal_paid_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
      RETURN l_principal_paid;
  END get_principal_paid;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:
    -- Description:      This Function is called to get an indicator Y/N if
    --                   the interest rate has changed
    --                   Inputs :
    --                   Output : interest rate change falg
    -- Dependencies:
    -- Parameters:       Contract id
    -- Version:          1.0
    -- End of Comments
  -----------------------------------------------------------------------------

  FUNCTION get_interest_rate_change_flag(
     x_return_status  OUT NOCOPY VARCHAR2,
     p_khr_id         IN NUMBER) RETURN VARCHAR2 IS

    l_debug_enabled          VARCHAR2(1);
    l_module    CONSTANT     fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_INTEREST_RATE_CHANGE_FLAG';
    x_msg_count              NUMBER;
    x_msg_data               VARCHAR2(2000);

    l_interest_rate_change_flag     VARCHAR2(1);
    l_effective_int_rate            NUMBER;

    CURSOR l_var_int_params_csr(cp_khr_id IN NUMBER) IS
    SELECT interest_calc_end_date, interest_rate
    FROM   okl_var_int_params
    WHERE  khr_id = cp_khr_id
    ORDER BY interest_calc_end_date DESC;

    l_var_int_params_rec     l_var_int_params_csr%ROWTYPE;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_interest_rate_change_flag');
    END IF;

    l_interest_rate_change_flag := 'N';
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN l_var_int_params_csr(p_khr_id);
    FETCH l_var_int_params_csr INTO l_var_int_params_rec;
    CLOSE l_var_int_params_csr;
    l_effective_int_rate := get_effective_int_rate(
                                              x_return_status  => x_return_status,
                                              p_khr_id         => p_khr_id,
                                              p_effective_date => l_var_int_params_rec.interest_calc_end_date + 1);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF l_effective_int_rate <> l_var_int_params_rec.interest_rate THEN
      l_interest_rate_change_flag := 'Y';
    END IF;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_interest_rate_change_flag');
    END IF;

    RETURN l_interest_rate_change_flag;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_interest_rate_change_flag;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_interest_rate_change_flag;
    WHEN OTHERS THEN
      IF l_var_int_params_csr%ISOPEN THEN
        CLOSE l_var_int_params_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
      RETURN l_interest_rate_change_flag;
  END get_interest_rate_change_flag;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:    get_effective_int_rate
    -- Description:      This Function is called to get effective interest rate
    --                   as of a given date
    --                   Inputs :
    --                   Output : Effective interest rate
    -- Dependencies:
    -- Parameters:       Contract id, Effective Date
    -- Version:          1.0
    -- End of Comments
  -----------------------------------------------------------------------------

  FUNCTION get_effective_int_rate(
     x_return_status  OUT NOCOPY VARCHAR2,
     p_khr_id         IN NUMBER,
     p_effective_date IN DATE) RETURN NUMBER IS
    --dkagrawa changed cursor to use view OKL_PROD_QLTY_VAL_UV than okl_product_parameters_v
    CURSOR l_calc_basis_csr(cp_khr_id IN NUMBER) IS
    SELECT ppm.quality_val interest_calculation_basis
    , end_date
    FROM   okl_k_headers_full_v khr,
           okl_prod_qlty_val_uv ppm
    WHERE  khr.pdt_id = ppm.pdt_id
    AND    ppm.quality_name = 'INTEREST_CALCULATION_BASIS'
    AND    khr.id = cp_khr_id;

    l_api_version           CONSTANT NUMBER := 1.0;
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);
    l_debug_enabled         VARCHAR2(1);
    l_module    CONSTANT    fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_EFFECTIVE_INT_RATE';

    l_interest_rate_tbl     okl_variable_interest_pvt.interest_rate_tbl_type;
    l_effective_int_rate    NUMBER;
    l_process_flag          okl_product_parameters_v.interest_calculation_basis%TYPE;
    l_end_date              okl_k_headers_full_v.end_date%TYPE;
    l_effective_date        DATE := NULL;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_effective_int_rate');
    END IF;

    l_effective_int_rate := 0;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN l_calc_basis_csr(p_khr_id);
    FETCH l_calc_basis_csr INTO l_process_flag, l_end_date;
    CLOSE l_calc_basis_csr;

    l_effective_date := p_effective_date;
    IF (l_effective_date > l_end_date) THEN
      l_effective_date := l_end_date;
    END IF;

    OKL_VARIABLE_INTEREST_PVT.interest_date_range (
               p_api_version        => l_api_version,
               p_init_msg_list      => OKL_API.G_FALSE,
               x_return_status      => x_return_status,
               x_msg_count          => x_msg_count,
               x_msg_data           => x_msg_data,
               p_contract_id        => p_khr_id,
               p_start_date         => l_effective_date,
               p_end_date           => l_effective_date,
               p_process_flag       => l_process_flag,
               x_interest_rate_tbl  => l_interest_rate_tbl);

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_interest_rate_tbl.COUNT > 0 THEN
      l_effective_int_rate := l_interest_rate_tbl(l_interest_rate_tbl.COUNT).rate;
    END IF;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_effective_int_rate');
    END IF;

    RETURN l_effective_int_rate;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_effective_int_rate;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_effective_int_rate;
    WHEN OTHERS THEN
      IF l_calc_basis_csr%ISOPEN THEN
        CLOSE l_calc_basis_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
      RETURN l_effective_int_rate;
  END get_effective_int_rate;

   ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:    get_interest_due_unbilled
    -- Description:      This Function is called to get Interest due but not billed
    --                   as of a given date for a Loan
    --                   Inputs :
    --                   Output : Unbilled Interest due
    -- Dependencies:
    -- Parameters:       Contract id, Effective Date
    -- Version:          1.0
    -- End of Comments
  -----------------------------------------------------------------------------

  FUNCTION get_interest_due_unbilled(
     x_return_status    OUT NOCOPY VARCHAR2,
     p_khr_id           IN NUMBER,
     p_effective_date   IN DATE) RETURN NUMBER IS

    l_debug_enabled         VARCHAR2(1);
    l_module    CONSTANT    fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_INTEREST_DUE_UNBILLED';
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);

    l_interest_billed       NUMBER;
    l_interest_due          NUMBER;
    l_interest_due_unbilled NUMBER;
    l_start_date            DATE;

    CURSOR l_start_date_csr(cp_khr_id IN NUMBER) IS
    SELECT chr.start_date
    FROM   OKC_K_HEADERS_B chr,
           OKL_K_HEADERS khr
    WHERE  chr.id    = khr.id
    AND   khr.id = cp_khr_id;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_interest_due_unbilled');
    END IF;

    l_interest_billed := 0;
    l_interest_due := 0;
    l_interest_due_unbilled := 0;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN l_start_date_csr(p_khr_id);
    FETCH l_start_date_csr INTO l_start_date;
    CLOSE l_start_date_csr;
    l_interest_due := get_interest_due(
                                      x_return_status  => x_return_status,
                                      p_khr_id         => p_khr_id,
                                      p_to_date        => p_effective_date);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_interest_billed := get_interest_billed(
                                      x_return_status  => x_return_status,
                                      p_khr_id         => p_khr_id,
                                      p_from_date      => l_start_date,
                                      p_to_date        => p_effective_date);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_interest_due_unbilled :=  l_interest_due -  l_interest_billed;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_interest_due_unbilled');
    END IF;

    RETURN l_interest_due_unbilled;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_interest_due_unbilled;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_interest_due_unbilled;
    WHEN OTHERS THEN
      IF l_start_date_csr%ISOPEN THEN
        CLOSE l_start_date_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
      RETURN l_interest_due_unbilled;
  END get_interest_due_unbilled;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:    get_principal_billed
    -- Description:      This Function is called to get Principal Billed for a loan contract
    --                   as of a given date range
    --                   Inputs :
    --                   Output : Principal billed
    -- Dependencies:
    -- Parameters:       Contract id, Asset Line id, From Date, To Date
    -- Version:          1.0
    -- End of Comments
  -----------------------------------------------------------------------------

  FUNCTION get_principal_billed(
     x_return_status  OUT NOCOPY VARCHAR2,
     p_khr_id         IN NUMBER,
     p_kle_id         IN NUMBER,
     p_from_date      IN DATE,
     p_to_date        IN DATE DEFAULT SYSDATE) RETURN NUMBER IS

    l_debug_enabled         VARCHAR2(1);
    l_module    CONSTANT    fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_PRINCIPAL_BILLED';
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);

    l_principal_billed      NUMBER;

-- Begin - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007
  -- Begin bug 6456733
    --CURSOR l_principal_billed_csr(cp_khr_id IN NUMBER, cp_kle_id IN NUMBER, cp_from_date IN DATE, cp_to_date IN DATE) IS
    CURSOR l_principal_billed_csr(cp_khr_id IN NUMBER, cp_from_date IN DATE, cp_to_date IN DATE) IS
    -- dcshanmu bug 6734738 start
    --SELECT  NVL(SUM(AMOUNT),0) principal_billed_amount
    --FROM okl_bpd_ar_inv_lines_v lpt1
    --where contract_id=cp_khr_id
    --and  RECEIVABLES_INVOICE_ID in
    --(
       SELECT  NVL(SUM(AMOUNT),0) principal_billed_amount --RECEIVABLES_INVOICE_ID
    -- dcshanmu bug 6734738 end
       FROM  okl_bpd_ar_inv_lines_v lpt,
             okl_strm_type_b sty,
             ar_payment_schedules_all aps,
             okl_k_headers_full_v khr
       WHERE
       -- dcshanmu bug 6734738 start
            lpt.contract_id  = cp_khr_id
       -- dcshanmu bug 6734738 end
       AND    lpt.contract_number  = khr.contract_number
       AND    lpt.sty_id  = sty.id
       AND    lpt.RECEIVABLES_INVOICE_ID = aps.customer_trx_id
       AND    sty.stream_type_purpose   IN
          ('PRINCIPAL_PAYMENT', 'UNSCHEDULED_PRINCIPAL_PAYMENT','PRINCIPAL_CATCHUP')
       AND    TRUNC(aps.trx_date) BETWEEN TRUNC(NVL(cp_from_date, khr.start_date))
       AND TRUNC(NVL(cp_to_date, SYSDATE))
    -- dcshanmu bug 6734738 start
    --)
    ;
    -- dcshanmu bug 6734738 end
    -- End bug 6456733

    -- SELECT NVL(SUM(aps.amount_due_original), 0) principal_billed_amount
    --SELECT NVL(sum(aps.amount_line_items_original), 0) principal_billed_amount --End bug#5767426
    --FROM   okl_bpd_tld_ar_lines_v tld,
           --okl_strm_type_b sty,
           --ar_payment_schedules_all aps,
           --okl_k_headers_full_v khr
    --WHERE  tld.khr_id  = cp_khr_id
    --AND    tld.kle_id  = NVL(cp_kle_id, tld.kle_id)
    --AND    tld.khr_id  = khr.id
    --AND    tld.sty_id  = sty.id
    --AND    sty.stream_type_purpose   IN ('PRINCIPAL_PAYMENT', 'UNSCHEDULED_PRINCIPAL_PAYMENT','PRINCIPAL_CATCHUP')
    --AND    tld.customer_trx_id = aps.customer_trx_id
    --AND    TRUNC(aps.trx_date) BETWEEN TRUNC(NVL(cp_from_date, khr.start_date)) AND TRUNC(NVL(cp_to_date, SYSDATE));
---- End - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_principal_billed');
    END IF;

    l_principal_billed := 0;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Begin bug 6456733
    --OPEN l_principal_billed_csr(p_khr_id, p_kle_id, p_from_date, p_to_date);
    OPEN l_principal_billed_csr(p_khr_id, p_from_date, p_to_date);
    -- End bug 6456733
    FETCH l_principal_billed_csr INTO l_principal_billed;
    CLOSE l_principal_billed_csr;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_principal_billed');
    END IF;

    RETURN l_principal_billed;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_principal_billed;
    WHEN OTHERS THEN
      IF l_principal_billed_csr%ISOPEN THEN
        CLOSE l_principal_billed_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
      RETURN l_principal_billed;
  END get_principal_billed;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:    get_float_factor_billed
    -- Description:      This Function is called to get Float Factor Billing Amount
    --                   for a float factor contract as of a given date
    --                   Inputs :
    --                   Output : Float Factor Billed
    -- Dependencies:
    -- Parameters:       Contract id, Effective Date
    -- Version:          1.0
    -- End of Comments
  -----------------------------------------------------------------------------

  FUNCTION get_float_factor_billed(
     x_return_status    OUT NOCOPY VARCHAR2,
     p_khr_id           IN NUMBER,
     p_effective_date   IN DATE) RETURN NUMBER IS

    l_debug_enabled         VARCHAR2(1);
    l_module    CONSTANT    fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_FLOAT_FACTOR_BILLED';
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);

    l_float_factor_billed   NUMBER;

-- Begin - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007
    CURSOR l_float_billed_csr(cp_khr_id IN NUMBER, cp_effective_date IN DATE) IS
    -- Begin bug 6456733
    SELECT NVL(SUM(AMOUNT_DUE_ORIGINAL),0) interest_billed_amount
    FROM okl_bpd_ar_inv_lines_v lpt1
    where contract_id=cp_khr_id
    and  RECEIVABLES_INVOICE_ID in
    (
      SELECT lpt.RECEIVABLES_INVOICE_ID
      FROM   okl_bpd_ar_inv_lines_v lpt,
           okl_strm_type_b sty,
           ar_payment_schedules_all aps,
           okl_k_headers_full_v khr
      WHERE  lpt.contract_id  = lpt1.contract_id
      AND    lpt.contract_number  = khr.contract_number
      AND    lpt.sty_id  = sty.id
      AND    lpt.RECEIVABLES_INVOICE_ID = aps.customer_trx_id
      AND    sty.stream_type_purpose = 'FLOAT_FACTOR_ADJUSTMENT'
      AND    TRUNC(aps.trx_date)  <= cp_effective_date
    );

    --SELECT NVL(SUM(aps.amount_due_original), 0) interest_billed_amount
    --FROM   okl_bpd_tld_ar_lines_v tld,
           --okl_strm_type_b sty,
           --ar_payment_schedules_all aps,
           --okc_k_headers_b khr
    --WHERE  tld.khr_id = cp_khr_id
    --AND    tld.khr_id = khr.id
    --AND    tld.sty_id = sty.id
    --AND    sty.stream_type_purpose    = 'FLOAT_FACTOR_ADJUSTMENT'
    --AND    tld.customer_trx_id = aps.customer_trx_id
    --AND    TRUNC(aps.trx_date) <= cp_effective_date;

    -- End bug 6456733
-- End - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_float_factor_billed');
    END IF;

    l_float_factor_billed := 0;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN l_float_billed_csr(p_khr_id, p_effective_date);
    FETCH l_float_billed_csr INTO l_float_factor_billed;
    CLOSE l_float_billed_csr;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_float_factor_billed');
    END IF;

    RETURN l_float_factor_billed;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_float_factor_billed;
    WHEN OTHERS THEN
      IF l_float_billed_csr%ISOPEN THEN
        CLOSE l_float_billed_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
     RETURN l_float_factor_billed;
  END get_float_factor_billed;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:    get_loan_payment_billed
    -- Description:      Loan Payment Billed for a loan contract with
    --                   a revenue recognition method of Actual
    --                   Inputs :
    --                   Output : Loan payment billed
    -- Dependencies:
    -- Parameters:       Contract id, Effective Date
    -- Version:          1.0
    -- End of Comments
  -----------------------------------------------------------------------------

  FUNCTION get_loan_payment_billed(
     x_return_status    OUT NOCOPY VARCHAR2,
     p_khr_id           IN NUMBER,
     p_effective_date   IN DATE) RETURN NUMBER IS

    l_debug_enabled         VARCHAR2(1);
    l_module    CONSTANT    fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_LOAN_PAYMENT_BILLED';
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);

    l_loan_payment_billed   NUMBER;

-- Begin - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007
    CURSOR l_loan_payment_billed_csr(cp_khr_id IN NUMBER, cp_effective_date IN DATE) IS
    --Begin bug 6456733
    SELECT NVL(SUM(lpt1.AMOUNT_DUE_ORIGINAL),0) loan_billed_amount
    FROM okl_bpd_ar_inv_lines_v lpt1
    where contract_id=cp_khr_id
    and  RECEIVABLES_INVOICE_ID in
    (
      SELECT lpt.RECEIVABLES_INVOICE_ID
      FROM   okl_bpd_ar_inv_lines_v lpt,
           okl_strm_type_b sty,
           ar_payment_schedules_all aps,
           okl_k_headers_full_v khr
      WHERE  lpt.contract_id  = lpt1.contract_id
      AND    lpt.contract_number  = khr.contract_number
      AND    lpt.sty_id  = sty.id
      AND    lpt.RECEIVABLES_INVOICE_ID = aps.customer_trx_id
      AND    sty.stream_type_purpose IN  ('LOAN_PAYMENT', 'VARIABLE_LOAN_PAYMENT', 'UNSCHEDULED_LOAN_PAYMENT')
      AND    TRUNC(aps.trx_date)  <= cp_effective_date
    );

    --SELECT NVL(SUM(aps.amount_due_original), 0) loan_billed_amount
    --FROM   okl_bpd_tld_ar_lines_v tld,
           --okl_strm_type_b sty,
           --ar_payment_schedules_all aps,
           --okl_k_headers_full_v khr
    --WHERE  tld.khr_id = cp_khr_id
    --AND    tld.khr_id = khr.id
    --AND    tld.sty_id = sty.id
    --AND    sty.stream_type_purpose   IN ('LOAN_PAYMENT', 'VARIABLE_LOAN_PAYMENT', 'UNSCHEDULED_LOAN_PAYMENT')
    --AND    tld.customer_trx_id = aps.customer_trx_id
    --AND    TRUNC(aps.trx_date) <= cp_effective_date;

    --End bug 6456733
-- End - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_loan_payment_billed');
    END IF;

    l_loan_payment_billed := 0;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN l_loan_payment_billed_csr(p_khr_id, p_effective_date);
    FETCH l_loan_payment_billed_csr INTO l_loan_payment_billed;
    CLOSE l_loan_payment_billed_csr;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_loan_payment_billed');
    END IF;

    RETURN l_loan_payment_billed;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_loan_payment_billed;
    WHEN OTHERS THEN
      IF l_loan_payment_billed_csr%ISOPEN THEN
        CLOSE l_loan_payment_billed_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
      RETURN l_loan_payment_billed;
  END get_loan_payment_billed;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:    get_loan_payment_paid
    -- Description:      Loan Payment Received for a loan contract with
    --                   a revenue recognition method of Actual
    --                   Inputs :
    --                   Output : Loan payment Paid
    -- Dependencies:
    -- Parameters:       Contract id, Effective Date
    -- Version:          1.0
    -- End of Comments
  -----------------------------------------------------------------------------

  FUNCTION get_loan_payment_paid(
     x_return_status    OUT NOCOPY VARCHAR2,
     p_khr_id           IN NUMBER,
     p_effective_date   IN DATE) RETURN NUMBER IS

    l_debug_enabled         VARCHAR2(1);
    l_module    CONSTANT    fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_LOAN_PAYMENT_PAID';
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);

    l_loan_payment_paid     NUMBER;

-- Begin - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007
    CURSOR l_laon_payment_csr(cp_khr_id IN NUMBER, cp_effective_date IN DATE) IS
    -- Begin Bug 6456733
    SELECT
    (NVL(SUM(AMOUNT_DUE_ORIGINAL),0)- NVL(SUM(AMOUNT_LINE_ITEMS_REMAINING),0)) loan_paid_amount
    FROM okl_bpd_ar_inv_lines_v lpt1
    where contract_id=cp_khr_id
    and  RECEIVABLES_INVOICE_ID in
    (
      SELECT lpt.RECEIVABLES_INVOICE_ID
      FROM   okl_bpd_ar_inv_lines_v lpt,
           okl_strm_type_b sty,
           ar_payment_schedules_all aps,
           okl_k_headers_full_v khr
      WHERE  lpt.contract_id  = lpt1.contract_id
      AND    lpt.contract_number  = khr.contract_number
      AND    lpt.sty_id  = sty.id
      AND    lpt.RECEIVABLES_INVOICE_ID = aps.customer_trx_id
      AND    sty.stream_type_purpose IN
                ('LOAN_PAYMENT', 'VARIABLE_LOAN_PAYMENT', 'UNSCHEDULED_LOAN_PAYMENT')
      AND    TRUNC(aps.trx_date)  <= cp_effective_date
    );

    --SELECT NVL(SUM(app.amount_applied),0) loan_paid_amount
    --FROM   ar_receivable_applications_all app,
           --ar_payment_schedules_all sch,
           --okl_bpd_tld_ar_lines_v tld,
           --okl_strm_type_v sty,
           --okl_k_headers_full_v khr
    --WHERE  TRUNC(app.apply_date)       <= cp_effective_date
    --AND    app.status                  = 'APP'
    --AND    app.applied_payment_schedule_id = sch.payment_schedule_id
    --AND    sch.class                   = 'INV'
    --AND    sch.customer_trx_id         = tld.customer_trx_id
    --AND    tld.khr_id                  = cp_khr_id
    --AND    tld.khr_id                  = khr.id
    --AND    tld.sty_id                  = sty.id
    --AND    sty.stream_type_purpose    IN ('LOAN_PAYMENT', 'VARIABLE_LOAN_PAYMENT', 'UNSCHEDULED_LOAN_PAYMENT');

    -- End bug 6456733

-- End - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_loan_payment_paid');
    END IF;

    l_loan_payment_paid := 0;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN l_laon_payment_csr(p_khr_id, p_effective_date);
    FETCH l_laon_payment_csr INTO l_loan_payment_paid;
    CLOSE l_laon_payment_csr;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_loan_payment_paid');
    END IF;

    RETURN l_loan_payment_paid;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_loan_payment_paid;
    WHEN OTHERS THEN
      IF l_laon_payment_csr%ISOPEN THEN
        CLOSE l_laon_payment_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
      RETURN l_loan_payment_paid;
  END get_loan_payment_paid;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:    get_excess_loan_payment
    -- Description:      Excess Loan Payment Received for a loan contract with
    --                   a revenue recognition method of Actual
    --                   Inputs :
    --                   Output : Loan payment Paid
    -- Dependencies:
    -- Parameters:       Contract id
    -- Version:          1.0
    -- End of Comments
  -----------------------------------------------------------------------------

  FUNCTION get_excess_loan_payment(
     x_return_status    OUT NOCOPY VARCHAR2,
     p_khr_id           IN NUMBER) RETURN NUMBER IS

    l_debug_enabled         VARCHAR2(1);
    l_module    CONSTANT    fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_EXCESS_LOAN_PAYMENT';
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);

    l_excess_loan_payment   NUMBER;

    CURSOR l_laon_payment_csr(cp_khr_id IN NUMBER) IS
    SELECT NVL(SUM(sel.amount), 0) loan_excess_amount
    FROM   okl_streams_v stm,
           okl_strm_type_v sty,
           okl_strm_elements_v sel
    WHERE  stm.khr_id              = cp_khr_id
    AND    stm.id                  = sel.stm_id
    AND    stm.sty_id              = sty.id
    AND    sty.stream_type_purpose = 'EXCESS_LOAN_PAYMENT_PAID';

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_excess_loan_payment');
    END IF;

    l_excess_loan_payment := 0;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN l_laon_payment_csr(p_khr_id);
    FETCH l_laon_payment_csr INTO l_excess_loan_payment;
    CLOSE l_laon_payment_csr;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_excess_loan_payment');
    END IF;

    RETURN l_excess_loan_payment;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_excess_loan_payment;
    WHEN OTHERS THEN
      IF l_laon_payment_csr%ISOPEN THEN
        CLOSE l_laon_payment_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
      RETURN l_excess_loan_payment;
  END get_excess_loan_payment;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:    get_last_interim_int_calc_date
    -- Description:      Returns the date last interim interest calculated
    --                   for variable rate contract
    --                   Inputs :
    --                   Output : last interim interest calculated Date
    -- Dependencies:
    -- Parameters:       Contract id
    -- Version:          1.0
    -- End of Comments
  -----------------------------------------------------------------------------

  FUNCTION get_last_interim_int_calc_date(
     x_return_status    OUT NOCOPY VARCHAR2,
     p_khr_id           IN NUMBER) RETURN DATE IS

    l_debug_enabled         VARCHAR2(1);
    l_module    CONSTANT    fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_LAST_INTERIM_INT_CALC_DATE';
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);
    l_last_interest_date    DATE;

    CURSOR l_interest_calc_date_csr (cp_khr_id IN NUMBER) IS
    SELECT date_last_interim_interest_cal
    FROM   okl_k_headers
    WHERE  id = cp_khr_id;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_last_interim_int_calc_date');
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN l_interest_calc_date_csr(p_khr_id);
    FETCH l_interest_calc_date_csr INTO l_last_interest_date;
    CLOSE l_interest_calc_date_csr;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_last_interim_int_calc_date');
    END IF;
    RETURN l_last_interest_date;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_last_interest_date;
    WHEN OTHERS THEN
      IF l_interest_calc_date_csr%ISOPEN THEN
        CLOSE l_interest_calc_date_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
      RETURN l_last_interest_date;

  END get_last_interim_int_calc_date;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Function Name:    get_last_sch_int_calc_date
    -- Description:      Returns the last scheduled interest calculation date prior
    --                   to the Termination Date
    --                   Inputs :
    --                   Output : last scheduled interest calculated Date
    -- Dependencies:
    -- Parameters:       Contract id, Effective Date
    -- Version:          1.0
    -- End of Comments
  -----------------------------------------------------------------------------

  FUNCTION get_last_sch_int_calc_date(
     x_return_status    OUT NOCOPY VARCHAR2,
     p_khr_id           IN NUMBER,
     p_effective_date   IN DATE) RETURN DATE IS

    l_debug_enabled          VARCHAR2(1);
    l_module       CONSTANT  fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_LAST_SCH_INT_CALC_DATE';
    x_msg_count              NUMBER;
    x_msg_data               VARCHAR2(2000);
    x_no_data_found          BOOLEAN;
    l_api_version  CONSTANT  NUMBER := 1.0;

    l_last_interest_date     DATE;
    l_pdtv_rec               OKL_PRODUCTS_PUB.pdtv_rec_type;
    x_pdt_parameter_rec      OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
    l_pay_freq               NUMBER;
    l_start_date             DATE;
    l_end_date               DATE;
    l_date_terminated        DATE;
    l_due_date               DATE;
    l_next_period_start_date DATE;
    l_next_period_end_date   DATE;

    CURSOR l_pdt_csr(cp_khr_id IN NUMBER) IS
    SELECT pdt_id
    FROM   okl_k_headers
    WHERE  id = cp_khr_id;

    CURSOR l_payment_freq_csr(cp_khr_id IN NUMBER) IS
    SELECT DECODE(sll.object1_id1,'M',1,'Q',3,'S',6,'A',12) pay_freq
    FROM   okc_rules_b sll,
           okc_rules_b slh,
           okl_strm_type_v styp,
           okc_rule_groups_b rgp
    WHERE  TO_NUMBER(sll.object2_id1)    = slh.id
    AND    sll.rule_information_category = 'LASLL'
    AND    sll.dnz_chr_id                =  rgp.dnz_chr_id
    AND    sll.rgp_id                    = rgp.id
    AND    slh.rule_information_category = 'LASLH'
    AND    slh.dnz_chr_id                =  rgp.dnz_chr_id
    AND    slh.rgp_id                    = rgp.id
    AND    slh.object1_id1               = styp.id
    AND    styp.stream_type_purpose      = 'RENT'
    AND    rgp.rgd_code                  = 'LALEVL'
    AND    rgp.dnz_chr_id                = cp_khr_id
    AND    ROWNUM                        < 2;

    CURSOR l_date_csr(cp_khr_id IN NUMBER) IS
    SELECT chr.start_date,
           chr.end_date
    FROM   OKC_K_HEADERS_B chr,
           OKL_K_HEADERS khr
    WHERE  chr.id    = khr.id
    AND    khr.id = cp_khr_id;

    CURSOR l_stream_csr(cp_khr_id IN NUMBER, cp_term_date IN DATE) IS
    SELECT max(sel.stream_element_date)
    FROM   okl_streams_v stm,
           okl_strm_type_v sty,
           okl_strm_elements_v sel
    WHERE  stm.khr_id              = cp_khr_id
    AND    stm.id                  = sel.stm_id
    AND    stm.sty_id              = sty.id
    AND    sty.stream_type_purpose = 'RENT'
    AND    sel.stream_element_date <= cp_term_date;

    CURSOR l_catchup_csr (cp_khr_id IN NUMBER) IS
    SELECT catchup_start_date,DECODE(catchup_frequency_code,'MONTHLY',1,'QUARTERLY',3,'SEMI_ANNUAL',6,'ANNUAL',12) pay_freq
    FROM   okl_k_rate_params
    WHERE  khr_id = cp_khr_id;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_last_sch_int_calc_date');
    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN l_pdt_csr(p_khr_id);
    FETCH l_pdt_csr INTO l_pdtv_rec.id;
    CLOSE l_pdt_csr;

    OKL_SETUPPRODUCTS_PVT.getpdt_parameters(
                                            p_api_version       =>  l_api_version,
                                            p_init_msg_list     =>  OKL_API.G_FALSE,
                                            x_return_status     =>  x_return_status,
                                            x_no_data_found     =>  x_no_data_found,
                                            x_msg_count         =>  x_msg_count,
                                            x_msg_data          =>  x_msg_data,
                                            p_pdtv_rec          =>  l_pdtv_rec,
                                            p_pdt_parameter_rec =>  x_pdt_parameter_rec );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OPEN l_date_csr(p_khr_id);
    FETCH l_date_csr INTO l_start_date,l_end_date;
    CLOSE l_date_csr;

    l_date_terminated := p_effective_date;
    IF (l_date_terminated IS NULL) THEN
      l_date_terminated := l_end_date;
    END IF;

    IF x_pdt_parameter_rec.interest_calculation_basis = 'REAMORT' THEN
      IF (l_date_terminated > l_end_date) THEN
        l_date_terminated := l_end_date;
      END IF;

      OPEN l_payment_freq_csr(p_khr_id);
      FETCH l_payment_freq_csr INTO l_pay_freq;
      CLOSE l_payment_freq_csr;
      LOOP
        l_last_interest_date := l_start_date;
        l_start_date := add_months(l_start_date,l_pay_freq);
        EXIT WHEN(l_start_date > l_date_terminated);
      END LOOP;
    ELSIF x_pdt_parameter_rec.interest_calculation_basis = 'FLOAT_FACTORS' THEN
      OPEN l_stream_csr(p_khr_id,l_date_terminated);
      FETCH l_stream_csr INTO l_last_interest_date;
      CLOSE l_stream_csr;
    ELSIF x_pdt_parameter_rec.interest_calculation_basis = 'FLOAT' THEN
      IF (l_date_terminated > l_end_date) THEN
        l_date_terminated := l_end_date;
      END IF;

     LOOP
        OKL_STREAM_GENERATOR_PVT.get_next_billing_date(
                                      p_api_version            => l_api_version,
                                      p_init_msg_list          => OKL_API.G_FALSE,
                                      p_khr_id                 => p_khr_id,
                                      p_billing_date           => l_start_date,
                                      x_next_due_date          => l_due_date,
                                      x_next_period_start_date => l_next_period_start_date,
                                      x_next_period_end_date   => l_next_period_end_date,
                                      x_return_status          => x_return_status,
                                      x_msg_count              => x_msg_count,
                                      x_msg_data               => x_msg_data);
        IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF (l_due_date > l_date_terminated OR l_due_date IS NULL) THEN
          l_last_interest_date := l_start_date;
          EXIT;
        END IF;
        l_start_date := l_due_date;
      END LOOP;
    ELSIF x_pdt_parameter_rec.interest_calculation_basis = 'CATCHUP/CLEANUP' THEN
      IF (l_date_terminated >= l_end_date) THEN
        l_last_interest_date := l_end_date;
      ELSE
        OPEN l_catchup_csr(p_khr_id);
        FETCH l_catchup_csr INTO l_start_date,l_pay_freq;
        CLOSE l_catchup_csr;
        LOOP
          l_last_interest_date := l_start_date;
          l_start_date := add_months(l_start_date,l_pay_freq);
          EXIT WHEN(l_start_date > l_date_terminated);
         END LOOP;

         IF (l_last_interest_date >= l_end_date) THEN
           l_last_interest_date := l_end_date;
         END IF;
      END IF;
    END IF;

    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_last_sch_int_calc_date');
    END IF;

  RETURN l_last_interest_date;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_last_interest_date;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_last_interest_date;
    WHEN OTHERS THEN
      IF l_pdt_csr%ISOPEN THEN
        CLOSE l_pdt_csr;
      END IF;
       IF l_payment_freq_csr%ISOPEN THEN
         CLOSE l_payment_freq_csr;
       END IF;
      IF l_date_csr%ISOPEN THEN
        CLOSE l_date_csr;
      END IF;
      IF l_stream_csr%ISOPEN THEN
        CLOSE l_stream_csr;
      END IF;
      IF l_catchup_csr%ISOPEN THEN
        CLOSE l_catchup_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
      RETURN l_last_interest_date;
  END get_last_sch_int_calc_date;

  ------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:       dkagrawa
    -- Procedure Name:   get_open_invoices
    -- Description:      Derive a list, consisting of number, Invoice date, Remaining amount
    --                   for open invoices for a Loan contract
    --                   Inputs :
    --                   Output : Invoice information table
    -- Dependencies:
    -- Parameters:       Contract id
    -- Version:          1.0
    -- End of Comments
  -----------------------------------------------------------------------------
  PROCEDURE get_open_invoices(
      x_return_status    OUT NOCOPY VARCHAR2,
      p_khr_id           IN NUMBER,
      x_invoice_tbl      OUT NOCOPY invoice_info_tbl_type) IS

    l_debug_enabled         VARCHAR2(1);
    l_module    CONSTANT    fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_VARIABLE_INT_UTIL_PVT.GET_OPEN_INVOICES';
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);

--Begin - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007
    CURSOR l_invoice_info_csr (cp_khr_id IN NUMBER) IS
    -- Begin bug 6456733
      SELECT
           lpt.amount_due_remaining,
           lpt.due_date INVOICE_DATE,
           lpt.TXD_ID LSM_ID,
           lpt.TXD_ID  tld_id,
           aps.customer_trx_id  receivables_invoice_id
      FROM
        okl_bpd_ar_inv_lines_v lpt,
        okl_strm_type_b sty,
        ar_payment_schedules_all aps,
        okl_k_headers_full_v khr
      WHERE
           lpt.CONTRACT_ID            = cp_khr_id
      AND  lpt.contract_number        = khr.contract_number
      AND  lpt.sty_id                 = sty.id
      AND  lpt.RECEIVABLES_INVOICE_ID = aps.customer_trx_id
      AND    aps.status               = 'OP'
      AND    aps.class                = 'INV'
      AND    sty.stream_type_purpose
                IN ('LOAN_PAYMENT', 'VARIABLE_LOAN_PAYMENT', 'UNSCHEDULED_LOAN_PAYMENT');


    --SELECT sch.amount_due_remaining,
           --TLD.INVOICE_DATE INVOICE_DATE,
           --TLD.TLD_ID LSM_ID,
           --tld.TLD_id tld_id,
--           lsm.receivables_invoice_id
           --sch.customer_trx_id  receivables_invoice_id
    --FROM   okl_bpd_tld_ar_lines_v tld,
           --ar_payment_schedules_all sch,
           --okl_strm_type_b sty
    --WHERE  sch.customer_trx_id      = tld.customer_trx_id
    --AND    sch.status               = 'OP'
    --AND    sch.class                = 'INV'
    --AND    tld.khr_id               = cp_khr_id
    --AND    tld.sty_id               = sty.id
    --AND    sty.stream_type_purpose  IN ('LOAN_PAYMENT', 'VARIABLE_LOAN_PAYMENT', 'UNSCHEDULED_LOAN_PAYMENT');

    -- End bug 6456733

-- End - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRVIUB.pls call get_open_invoices');
    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF ( p_khr_id IS NULL ) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    OPEN l_invoice_info_csr(p_khr_id);
    FETCH l_invoice_info_csr BULK COLLECT INTO x_invoice_tbl;
    CLOSE l_invoice_info_csr;
    IF(NVL(l_debug_enabled,'N')='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRVIUB.pls call get_open_invoices');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      IF l_invoice_info_csr%ISOPEN THEN
        CLOSE l_invoice_info_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
  END get_open_invoices;

  ------------------------------------------------------------------------------

END OKL_VARIABLE_INT_UTIL_PVT;

/
