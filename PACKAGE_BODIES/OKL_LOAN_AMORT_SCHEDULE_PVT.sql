--------------------------------------------------------
--  DDL for Package Body OKL_LOAN_AMORT_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LOAN_AMORT_SCHEDULE_PVT" AS
/* $Header: OKLRLASB.pls 120.8 2008/02/20 22:06:11 sechawla noship $ */
  ------------------------------------------------------------------------------
  -- Global Variables
  ------------------------------------------------------------------------------
  G_BULK_SIZE NUMBER := 10000;
  G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
  G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  G_IS_DEBUG_STATEMENT_ON BOOLEAN;
 ------------------------------------------------------------------------------
 -- Record Type
 ------------------------------------------------------------------------------

  TYPE periods_rec_type IS RECORD (
    start_date         DATE,
    end_date           DATE
  );

  TYPE periods_tbl_type is table of periods_rec_type INDEX BY BINARY_INTEGER;

  TYPE pymt_sched_rec_type IS RECORD (
    start_date         DATE,
    stub_days          NUMBER,
    periods            NUMBER,
    frequency          NUMBER,
    arrears_yn         VARCHAR2(1)
  );

  TYPE pymt_sched_tbl_type is table of pymt_sched_rec_type INDEX BY BINARY_INTEGER;

  TYPE receipts_rec_type IS RECORD (
    receipt_date       DATE,
    principal          NUMBER,
    interest           NUMBER
  );

  TYPE receipts_tbl_type is table of receipts_rec_type INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  -- Start of comments
  --
  -- API name       : get_pymt_sched_periods
  -- Pre-reqs       : None
  -- Function       : This procedure fetches the start and end dates
  --                  for all periods/stubs in the input contract's
  --                  payment schedule
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id - Contract Id
  -- Version        : 1.0
  -- History        : rpillay created.
  -- End of comments

  PROCEDURE  get_pymt_sched_periods
                 (p_api_version     IN  NUMBER,
                  p_init_msg_list   IN  VARCHAR2,
                  x_return_status   OUT NOCOPY VARCHAR2,
                  x_msg_count       OUT NOCOPY NUMBER,
                  x_msg_data        OUT NOCOPY VARCHAR2,
                  p_chr_id          IN  NUMBER,
                  x_arrears_yn      OUT NOCOPY VARCHAR2,
                  x_periods_tbl     OUT NOCOPY periods_tbl_type) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'GET_PYMT_SCHED_PERIODS';
    l_api_version     CONSTANT NUMBER     := 1.0;

    CURSOR fin_cle_csr(p_chr_id IN NUMBER) IS
    SELECT cleb_fin.id
    FROM okc_k_lines_b cleb_fin,
         okc_statuses_b sts
    WHERE cleb_fin.dnz_chr_id = p_chr_id
    AND   cleb_fin.chr_id = p_chr_id
    AND   cleb_fin.lse_id = 33
    AND   cleb_fin.sts_code = sts.code
    AND   sts.ste_code <> 'CANCELLED';

    fin_cle_rec fin_cle_csr%ROWTYPE;

    CURSOR pymt_sched_csr(p_chr_id IN NUMBER,
                          p_cle_id IN NUMBER) IS
    SELECT FND_DATE.canonical_to_date(sll.rule_information2) start_date,
           TO_NUMBER(sll.rule_information7) stub_days,
           TO_NUMBER(sll.rule_information3) periods,
           DECODE(sll.object1_id1, 'M',1,'Q',3,'S',6,'A',12) frequency,
           sll.rule_information10   arrears_yn
    FROM okc_rules_b sll,
         okc_rules_b slh,
         okc_rule_groups_b rgp,
         okl_strm_type_b sty
    WHERE rgp.dnz_chr_id = p_chr_id
    AND rgp.cle_id = p_cle_id
    AND rgp.rgd_code = 'LALEVL'
    AND slh.rgp_id = rgp.id
    AND slh.rule_information_category = 'LASLH'
    AND sll.object2_id1 = slh.id
    AND sll.rule_information_category = 'LASLL'
    AND sll.rgp_id = rgp.id
    AND slh.object1_id1 = sty.id
    AND sty.stream_type_purpose IN ('RENT','PRINCIPAL_PAYMENT')
    ORDER BY start_date;

    l_temp_pymt_sched_tbl pymt_sched_tbl_type;
    l_pymt_sched_tbl      pymt_sched_tbl_type;
    l_periods_tbl         periods_tbl_type;
    l_temp_counter        NUMBER;

    l_counter      NUMBER;
    l_start_day    NUMBER;
  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OPEN fin_cle_csr(p_chr_id => p_chr_id);
    FETCH fin_cle_csr INTO fin_cle_rec;
    CLOSE fin_cle_csr;

    l_temp_counter := 0;
    OPEN pymt_sched_csr(p_chr_id => p_chr_id,
                        p_cle_id => fin_cle_rec.id);
    LOOP
      FETCH pymt_sched_csr BULK COLLECT INTO l_temp_pymt_sched_tbl LIMIT G_BULK_SIZE;
      EXIT WHEN l_temp_pymt_sched_tbl.COUNT = 0;

      FOR i IN l_temp_pymt_sched_tbl.FIRST..l_temp_pymt_sched_tbl.LAST
      LOOP
        l_temp_counter := l_temp_counter + 1;
        l_pymt_sched_tbl(l_temp_counter).start_date  := l_temp_pymt_sched_tbl(i).start_date;
        l_pymt_sched_tbl(l_temp_counter).stub_days   := l_temp_pymt_sched_tbl(i).stub_days;
        l_pymt_sched_tbl(l_temp_counter).periods     := l_temp_pymt_sched_tbl(i).periods;
        l_pymt_sched_tbl(l_temp_counter).frequency   := l_temp_pymt_sched_tbl(i).frequency;
        l_pymt_sched_tbl(l_temp_counter).arrears_yn  := l_temp_pymt_sched_tbl(i).arrears_yn;

      END LOOP;
    END LOOP;
    CLOSE pymt_sched_csr;

    IF l_pymt_sched_tbl.COUNT > 0 THEN

      l_counter := 1;
      FOR i IN l_pymt_sched_tbl.FIRST..l_pymt_sched_tbl.LAST
      LOOP

        l_periods_tbl(l_counter).start_date := l_pymt_sched_tbl(i).start_date;

        IF l_pymt_sched_tbl(i).stub_days IS NOT NULL THEN

          l_periods_tbl(l_counter).end_date := l_periods_tbl(l_counter).start_date + l_pymt_sched_tbl(i).stub_days - 1;

          l_counter := l_counter + 1;

        ELSIF l_pymt_sched_tbl(i).periods IS NOT NULL THEN

          FOR j IN 1..l_pymt_sched_tbl(i).periods
          LOOP

            l_start_day := TO_CHAR(l_periods_tbl(l_counter).start_date,'DD');
            l_periods_tbl(l_counter).end_date :=
                                    OKL_LLA_UTIL_PVT.calculate_end_date(p_start_date => l_periods_tbl(l_counter).start_date,
                                                                        p_months     => l_pymt_sched_tbl(i).frequency,
                                                                        p_start_day  => l_start_day,
                                                                        p_contract_end_date => NULL);
            l_counter := l_counter + 1;

            IF (j <  l_pymt_sched_tbl(i).periods) THEN
              l_periods_tbl(l_counter).start_date := l_periods_tbl(l_counter - 1).end_date + 1;
            END IF;
          END LOOP;

        END IF;

      END LOOP;

      x_arrears_yn  := l_pymt_sched_tbl(l_pymt_sched_tbl.FIRST).arrears_yn;
    END IF;

    x_periods_tbl := l_periods_tbl;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR Then
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END get_pymt_sched_periods;


  -- Start of comments
  --
  -- API name       : load_ln_streams_dtl
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Detail report - Detail report- both past and projected,
  --                  based on the billed and unbilled stream elements for the input contract,
  --                  as of the date on which Amortization schedule is requested
  --                  This schedule applies to Loans with Interest Calculation Basis = FIXED' or 'REAMORT' and
  --                  Revenue Recognition - STREAMS
  --
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : sechawla created.
  --                  sechawla 19-feb-08 6831074 :changed payment type G_PPD to G_BILLED/G_PROJECTED
  -- End of comments

  PROCEDURE load_ln_streams_dtl(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_amort_sched_tbl            OUT NOCOPY amort_sched_tbl_type) IS

      l_api_name            CONSTANT    VARCHAR2(30) := 'load_ln_streams_dtl';
      l_api_version         CONSTANT    NUMBER       := 1.0;



      l_amort_sched_tbl     amort_sched_tbl_type;
      indx                  NUMBER;
      l_princ_bal           NUMBER;
      k                     NUMBER;
      --l_last_billing_date   DATE;

      --This cursor fetches the total billed 'PRINCIPAL_PAYMENT' and 'INTEREST_PAYMENT'
      --streams for the contract. Amounts are derived at the contract level i.e streams are
      --summedup for all the assets and teh total amounts are returned as the header level amounts
      CURSOR c_amort_sch_dtl_csr(cp_khr_id in number) is
      SELECT bill_date
       ,SUM(principal) principal
       ,SUM(interest) interest
       , 0 princ_pay_down,
       payment_type
      FROM
     (
        SELECT sel.stream_element_date bill_date
        ,sel.amount principal
        ,0 interest
        ,decode(sel.date_billed,NULL,G_PROJECTED,G_BILLED) payment_type
        FROM okl_strm_elements sel,
             okl_streams stm,
             okl_strm_type_b sty
        WHERE stm.khr_id = cp_khr_id
        AND   sty.id = stm.sty_id
        AND   sty.stream_type_purpose = 'PRINCIPAL_PAYMENT'
        AND   sel.stm_id = stm.id
       -- AND   sel.date_billed IS NOT NULL --Billing is done in OKL
        AND   stm.SAY_CODE = 'CURR'
        AND   stm.active_yn = 'Y'
       UNION ALL
        SELECT sel.stream_element_date bill_date
        ,0 principal
        ,sel.amount interest
        ,decode(sel.date_billed,NULL,G_PROJECTED,G_BILLED) payment_type
       FROM okl_strm_elements sel,
            okl_streams stm,
            okl_strm_type_b sty
       WHERE stm.khr_id = cp_khr_id
       AND   sty.id = stm.sty_id
       AND   sty.stream_type_purpose = 'INTEREST_PAYMENT'
       AND   sel.stm_id = stm.id
     --  AND   sel.date_billed IS NOT NULL --Billing is done in OKL
       AND   stm.SAY_CODE = 'CURR'
       AND   stm.active_yn = 'Y'
      )
    GROUP BY bill_date,payment_type
    UNION ALL
    SELECT bill_date,
           0 principal,
           0 interest,
           SUM(princ_pay_down) princ_pay_down,
           payment_type
    FROM
    (
     SELECT sel.stream_element_date bill_date,
           0 principal,
           0 interest,
           sel.amount princ_pay_down,
           decode(sel.date_billed,NULL,G_PROJECTED,G_BILLED) payment_type
       FROM okl_strm_elements sel,
            okl_streams stm,
            okl_strm_type_b sty
       WHERE stm.khr_id = cp_khr_id
       AND   sty.id = stm.sty_id
       AND   sty.stream_type_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT'
       AND   sel.stm_id = stm.id
       AND   stm.SAY_CODE = 'CURR'
       AND   stm.active_yn = 'Y'
       )
       -- principal paydown rebooks the contract and all streams are regenerated
       -- Loan Payment Paydown is not permitted with Rev Rec = 'STREAMS'
    GROUP BY bill_date, payment_type
    ORDER BY bill_date;

    TYPE temp_tbl_type IS TABLE OF c_amort_sch_dtl_csr%ROWTYPE INDEX BY BINARY_INTEGER;
    l_temp_tbl      temp_tbl_type;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Derive starting Principal Balance
    Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => p_api_version,
                                    p_init_msg_list        => p_init_msg_list,
                                    x_return_status        => x_return_status,
                                    x_msg_count            => x_msg_count,
                                    x_msg_data             => x_msg_data,
                                    p_formula_name         => 'CONTRACT_FINANCED_AMOUNT',
                                    p_contract_id          => p_chr_id,
                                    p_line_id              => NULL,
                                    x_value               =>  l_princ_bal
                                    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    indx := 1;
    l_amort_sched_tbl(indx).principal_balance := l_princ_bal;
    OPEN  c_amort_sch_dtl_csr(p_chr_id);
    LOOP
         l_temp_tbl.DELETE;
         FETCH c_amort_sch_dtl_csr BULK COLLECT INTO l_temp_tbl LIMIT G_BULK_SIZE;
         IF l_temp_tbl.COUNT > 0 THEN
            FOR k IN l_temp_tbl.FIRST..l_temp_tbl.LAST LOOP
                indx := indx + 1;

                l_amort_sched_tbl(indx).start_date := l_temp_tbl(k).bill_date;
                l_amort_sched_tbl(indx).loan_payment  := l_temp_tbl(k).principal + l_temp_tbl(k).princ_pay_down + l_temp_tbl(k).interest;
                l_amort_sched_tbl(indx).principal  := l_temp_tbl(k).principal + l_temp_tbl(k).princ_pay_down;
                l_amort_sched_tbl(indx).interest := l_temp_tbl(k).interest;
                l_amort_sched_tbl(indx).principal_balance := l_amort_sched_tbl(indx - 1).principal_balance - l_temp_tbl(k).principal - l_temp_tbl(k).princ_pay_down;
                l_amort_sched_tbl(indx).payment_type      := l_temp_tbl(k).payment_type;

            END LOOP;
         END IF;
         EXIT WHEN c_amort_sch_dtl_csr%NOTFOUND;
     END LOOP;
     CLOSE c_amort_sch_dtl_csr;

     x_amort_sched_tbl := l_amort_sched_tbl;
     OKL_API.END_ACTIVITY (x_msg_count,x_msg_data);

  EXCEPTION

    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF c_amort_sch_dtl_csr%ISOPEN THEN
           CLOSE c_amort_sch_dtl_csr;
        END IF;


      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

        IF c_amort_sch_dtl_csr%ISOPEN THEN
           CLOSE c_amort_sch_dtl_csr;
        END IF;


      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OTHERS THEN
        IF c_amort_sch_dtl_csr%ISOPEN THEN
           CLOSE c_amort_sch_dtl_csr;
        END IF;


      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OTHERS',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

  END load_ln_streams_dtl;



 -- This function matches the input date with period start/end dates
 -- and returns the start/end date. If input date matches with a start date,
 -- the corresponding end date is returned. If input date matches with an end date,
 -- the corresponding start date is returned.
  FUNCTION  get_period_start_end_date
            (p_periods_tbl       IN  periods_tbl_type,
             p_period_date       IN  DATE) RETURN DATE IS

             k      NUMBER;
  BEGIN
            IF p_periods_tbl.COUNT > 0 THEN
              FOR k IN p_periods_tbl.FIRST..p_periods_tbl.LAST LOOP
                 IF    p_periods_tbl(k).end_date = p_period_date THEN
                       RETURN p_periods_tbl(k).start_date;
                 ELSIF p_periods_tbl(k).start_date = p_period_date THEN
                       RETURN p_periods_tbl(k).end_date;
                 END IF;
              END LOOP;
              -- Control will come here when payments are in Arrears and stream element date is the first day of the
              -- next period, and the next period falls outside the payment periods. For e.g if K term is
              -- 01-jan-07  to 31-Dec-07, the last stream element date will be 01-jan-08, which is outside the
              -- contract payment periods.  In this case, amort schedule period end date will be same as the amort schedule period start date
              RETURN p_period_date;
            END IF;

            RETURN NULL;

 EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
 END;
   -- Start of comments
  --
  -- API name       : load_ln_streams_summ
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Summary report- both past and projected,
  --                  based on the billed and unbilled stream elements for the input contract,
  --                  as of the date on which Amortization schedule is requested
  --                  This schedule applies to Loans with Interest Calculation Basis = FIXED' or 'REAMORT' and
  --                  Revenue Recognition - STREAMS
  --
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : sechawla created.
  -- End of comments

  PROCEDURE load_ln_streams_summ(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_chr_id                     IN  NUMBER,
      x_amort_sched_tbl            OUT NOCOPY amort_sched_tbl_type) IS

      l_api_name            CONSTANT    VARCHAR2(30) := 'load_ln_streams_summ';
      l_api_version         CONSTANT    NUMBER       := 1.0;



      l_amort_sched_tbl     amort_sched_tbl_type;
      indx                  NUMBER;
      l_princ_bal           NUMBER;
      k                     NUMBER;


      --This cursor fetches the total billed 'PRINCIPAL_PAYMENT' and 'INTEREST_PAYMENT'
      --streams for the contract. Amounts are derived at the contract level i.e streams are
      --summedup for all the assets and teh total amounts are returned as the header level amounts
      CURSOR c_amort_sch_summ_csr(cp_khr_id IN NUMBER) IS
      SELECT bill_date
       ,(SUM(principal) + SUM(interest)) total_amount
       ,SUM(principal) principal
       ,SUM(interest) interest
      FROM
     (
        SELECT sel.stream_element_date bill_date
        ,sel.amount principal
        ,0 interest
        FROM okl_strm_elements sel,
             okl_streams stm,
             okl_strm_type_b sty
        WHERE stm.khr_id = cp_khr_id
        AND   sty.id = stm.sty_id
        AND   sty.stream_type_purpose = 'PRINCIPAL_PAYMENT'
        AND   sel.stm_id = stm.id
      --  AND   sel.date_billed IS NOT NULL --Billing is done in OKL
        AND   stm.SAY_CODE = 'CURR'
        AND   stm.active_yn = 'Y'
       UNION ALL
        SELECT sel.stream_element_date bill_date
        ,0 principal
        ,sel.amount interest
       FROM okl_strm_elements sel,
            okl_streams stm,
            okl_strm_type_b sty
       WHERE stm.khr_id = cp_khr_id
       AND   sty.id = stm.sty_id
       AND   sty.stream_type_purpose = 'INTEREST_PAYMENT'
       AND   sel.stm_id = stm.id
      -- AND   sel.date_billed IS NOT NULL --Billing is done in OKL
       AND   stm.SAY_CODE = 'CURR'
       AND   stm.active_yn = 'Y'

    )
    GROUP BY bill_date
    ORDER BY bill_date;

    --This cursor selects the past principal paydown streams for a contract.
    CURSOR c_amort_sch_ppd_csr(cp_khr_id IN NUMBER) IS
       SELECT sel.stream_element_date bill_date
        ,sum(sel.amount) ppd_amount
       FROM okl_strm_elements sel,
            okl_streams stm,
            okl_strm_type_b sty
       WHERE stm.khr_id = cp_khr_id
       AND   sty.id = stm.sty_id
       AND   sty.stream_type_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT'
       AND   sel.stm_id = stm.id
     --  AND   sel.date_billed IS NOT NULL --Billing is done in OKL
       AND   stm.SAY_CODE = 'CURR'
       AND   stm.active_yn = 'Y'
       GROUP BY sel.stream_element_date
       ORDER BY bill_date;


    TYPE temp_tbl_type IS TABLE OF c_amort_sch_summ_csr%ROWTYPE INDEX BY BINARY_INTEGER;
    l_temp_tbl      temp_tbl_type;


    l_periods_tbl         periods_tbl_type;
    l_arrears_yn          VARCHAR2(1);

    l_summ_total_amount  NUMBER;
    l_summ_principal      NUMBER;

    l_period_date         DATE;
  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



     --Derive Payment Schedule Periods
     get_pymt_sched_periods(p_api_version          => p_api_version,
                            p_init_msg_list        => p_init_msg_list,
                            x_return_status        => x_return_status,
                            x_msg_count            => x_msg_count,
                            x_msg_data             => x_msg_data,
                            p_chr_id               => p_chr_id,
                            x_arrears_yn           => l_arrears_yn,
                            x_periods_tbl          => l_periods_tbl
                            );

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --Derive starting Principal Balance
    Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => p_api_version,
                                    p_init_msg_list        => p_init_msg_list,
                                    x_return_status        => x_return_status,
                                    x_msg_count            => x_msg_count,
                                    x_msg_data             => x_msg_data,
                                    p_formula_name         => 'CONTRACT_FINANCED_AMOUNT',
                                    p_contract_id          => p_chr_id,
                                    p_line_id              => NULL,
                                    x_value               =>  l_princ_bal
                                    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    indx := 1;
    l_amort_sched_tbl(indx).principal_balance := l_princ_bal;

    OPEN  c_amort_sch_summ_csr(p_chr_id);
    LOOP
         l_temp_tbl.DELETE;
         FETCH c_amort_sch_summ_csr BULK COLLECT INTO l_temp_tbl LIMIT G_BULK_SIZE;
         IF l_temp_tbl.COUNT > 0 THEN
            FOR k IN l_temp_tbl.FIRST..l_temp_tbl.LAST LOOP
                indx := indx + 1;

                IF l_arrears_yn = 'N' THEN -- Payments in Advance
                   l_amort_sched_tbl(indx).start_date := l_temp_tbl(k).bill_date;
                   l_amort_sched_tbl(indx).end_date := get_period_start_end_date(l_periods_tbl, l_amort_sched_tbl(indx).start_date);
                ELSE --Payment in Arrears, stream element date will either be the last day of the period, or first day of the next period
                    l_period_date := get_period_start_end_date(l_periods_tbl,l_temp_tbl(k).bill_date); --l_temp_tbl(k).bill_date is the stream element date
                    IF  l_period_date < l_temp_tbl(k).bill_date THEN
                        --stream element date (l_temp_tbl(k).bill_date) is the last day of the period
                        l_amort_sched_tbl(indx).start_date :=l_period_date;
                        l_amort_sched_tbl(indx).end_date := l_temp_tbl(k).bill_date;
                    ELSIF l_period_date > l_temp_tbl(k).bill_date THEN
                        --stream element date (l_temp_tbl(k).bill_date) is the first day of the next period
                        l_amort_sched_tbl(indx).start_date := l_temp_tbl(k).bill_date;
                        l_amort_sched_tbl(indx).end_date := l_period_date;
                    ELSE
                        -- l_period_date = l_temp_tbl(k).bill_date
                        -- stream element date falls outside the payment period
                        l_amort_sched_tbl(indx).start_date := l_temp_tbl(k).bill_date;
                        l_amort_sched_tbl(indx).end_date := l_temp_tbl(k).bill_date;
                    END IF;
                END IF;
                l_summ_total_amount := 0;
                l_summ_principal := 0;

                l_summ_total_amount := l_summ_total_amount + l_temp_tbl(k).total_amount;
                l_summ_principal := l_summ_principal + l_temp_tbl(k).principal;

                FOR c_amort_sch_ppd_rec IN c_amort_sch_ppd_csr(p_chr_id) LOOP
                    IF c_amort_sch_ppd_rec.bill_date BETWEEN l_amort_sched_tbl(indx).start_date AND l_amort_sched_tbl(indx).end_date THEN
                       l_summ_principal := l_summ_principal +  c_amort_sch_ppd_rec.ppd_amount;
                       l_summ_total_amount := l_summ_total_amount + c_amort_sch_ppd_rec.ppd_amount;
                    END IF;
                END LOOP;

                l_amort_sched_tbl(indx).loan_payment  := l_summ_total_amount ;
                l_amort_sched_tbl(indx).principal  := l_summ_principal;
                l_amort_sched_tbl(indx).interest := l_temp_tbl(k).interest;
                l_amort_sched_tbl(indx).principal_balance := l_amort_sched_tbl(indx - 1).principal_balance - l_amort_sched_tbl(indx).principal;
               --  l_amort_sched_tbl(indx).payment_type      := G_BILLED;

            END LOOP;
         END IF;
         EXIT WHEN c_amort_sch_summ_csr%NOTFOUND;
     END LOOP;
     CLOSE c_amort_sch_summ_csr;
     x_amort_sched_tbl := l_amort_sched_tbl;
     OKL_API.END_ACTIVITY (x_msg_count,x_msg_data);

  EXCEPTION

    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF c_amort_sch_summ_csr%ISOPEN THEN
           CLOSE c_amort_sch_summ_csr;
        END IF;

        IF c_amort_sch_ppd_csr%ISOPEN THEN
           CLOSE c_amort_sch_ppd_csr;
        END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

        IF c_amort_sch_summ_csr%ISOPEN THEN
           CLOSE c_amort_sch_summ_csr;
        END IF;

        IF c_amort_sch_ppd_csr%ISOPEN THEN
           CLOSE c_amort_sch_ppd_csr;
        END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OTHERS THEN
        IF c_amort_sch_summ_csr%ISOPEN THEN
           CLOSE c_amort_sch_summ_csr;
        END IF;

        IF c_amort_sch_ppd_csr%ISOPEN THEN
           CLOSE c_amort_sch_ppd_csr;
        END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OTHERS',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

  END load_ln_streams_summ;


  -- Start of comments
  --
  -- API name       : load_ln_actual_dtl
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Detail report
  --                  based on all receipts that have been processed by the Daily
  --                  Interest Program and projected payments for the remaining
  --                  loan term for the input contract. This schedule applies
  --                  to Loans with Revenue Recognition - ACTUAL
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : rpillay created.
  -- End of comments

  PROCEDURE load_ln_actual_dtl(
              p_api_version         IN  NUMBER,
              p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
              x_return_status       OUT NOCOPY VARCHAR2,
              x_msg_count           OUT NOCOPY NUMBER,
              x_msg_data            OUT NOCOPY VARCHAR2,
              p_chr_id              IN  NUMBER,
              x_proj_interest_rate  OUT NOCOPY NUMBER,
              x_amort_sched_tbl     OUT NOCOPY amort_sched_tbl_type) IS

    l_api_name            CONSTANT    VARCHAR2(30) := 'LOAD_LN_ACTUAL_DTL';
    l_api_version         CONSTANT    NUMBER       := 1.0;

    CURSOR amort_sched_dtl_csr(p_chr_id IN NUMBER) IS
    SELECT receipt_date,
           SUM(principal) principal,
           SUM(interest) interest
    FROM
    (
     SELECT sel_dii.stream_element_date receipt_date,
            0 principal,
            sel_dii.amount interest,
            sel_dii.request_id
     FROM okl_strm_elements sel_dii,
          okl_streams stm_dii,
          okl_strm_type_b sty_dii
     WHERE stm_dii.khr_id = p_chr_id
     AND   sty_dii.id = stm_dii.sty_id
     AND   sty_dii.stream_type_purpose = 'DAILY_INTEREST_INTEREST'
     AND   sel_dii.stm_id = stm_dii.id
     AND   stm_dii.say_code = 'CURR'
     AND   stm_dii.active_yn = 'Y'
     UNION ALL
     SELECT sel_dip.stream_element_date receipt_date,
            sel_dip.amount principal,
            0 interest,
            sel_dip.request_id
     FROM okl_strm_elements sel_dip,
          okl_streams stm_dip,
          okl_strm_type_b sty_dip
     WHERE stm_dip.khr_id = p_chr_id
     AND   sty_dip.id = stm_dip.sty_id
     AND   sty_dip.stream_type_purpose = 'DAILY_INTEREST_PRINCIPAL'
     AND   sel_dip.stm_id = stm_dip.id
     AND   stm_dip.say_code = 'CURR'
     AND   stm_dip.active_yn = 'Y'
    )
    GROUP BY receipt_date,request_id
    ORDER BY receipt_date;

    l_temp_tbl   receipts_tbl_type;

    l_principal_balance NUMBER;
    l_amort_sched_tbl  amort_sched_tbl_type;
    l_counter NUMBER;

    l_schedule_tbl       OKL_PRICING_PVT.schedule_table_type;
    l_last_int_calc_date DATE;
    l_proj_interest_rate NUMBER;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Derive Principal Balance
    Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => p_api_version,
                                    p_init_msg_list        => p_init_msg_list,
                                    x_return_status        => x_return_status,
                                    x_msg_count            => x_msg_count,
                                    x_msg_data             => x_msg_data,
                                    p_formula_name         => 'CONTRACT_FINANCED_AMOUNT',
                                    p_contract_id          => p_chr_id,
                                    p_line_id              => NULL,
                                    x_value               =>  l_principal_balance
                                    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_counter := 1;
    l_amort_sched_tbl(l_counter).principal_balance := l_principal_balance;

    OPEN amort_sched_dtl_csr(p_chr_id => p_chr_id);
    LOOP
      FETCH amort_sched_dtl_csr BULK COLLECT INTO l_temp_tbl LIMIT G_BULK_SIZE;
      EXIT WHEN l_temp_tbl.COUNT = 0;

      FOR i IN l_temp_tbl.FIRST..l_temp_tbl.LAST
      LOOP
          l_counter := l_counter + 1;
          l_amort_sched_tbl(l_counter).start_date        := l_temp_tbl(i).receipt_date;
          l_amort_sched_tbl(l_counter).principal         := l_temp_tbl(i).principal;
          l_amort_sched_tbl(l_counter).interest          := l_temp_tbl(i).interest;
          l_amort_sched_tbl(l_counter).loan_payment      := l_temp_tbl(i).principal + l_temp_tbl(i).interest;
          l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter - 1).principal_balance - l_temp_tbl(i).principal;
          l_amort_sched_tbl(l_counter).payment_type      := G_RECEIVED;
      END LOOP;
    END LOOP;
    CLOSE amort_sched_dtl_csr;

    IF (l_amort_sched_tbl(l_counter).principal_balance > 0) THEN

      l_last_int_calc_date := OKL_VARIABLE_INTEREST_PVT.get_last_int_calc_date(p_khr_id => p_chr_id);

      --Generate Projected Schedule
      OKL_PRICING_PVT.generate_loan_schedules
       (p_khr_id         => p_chr_id,
        p_investment     => l_amort_sched_tbl(l_counter).principal_balance,
        p_start_date     => l_last_int_calc_date + 1,
        x_interest_rate  => l_proj_interest_rate,
        x_schedule_table => l_schedule_tbl,
        x_return_status  => x_return_status);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_schedule_tbl.COUNT > 0) THEN

        FOR i IN l_schedule_tbl.FIRST..l_schedule_tbl.LAST
        LOOP
          l_counter := l_counter + 1;
          l_amort_sched_tbl(l_counter).start_date        := l_schedule_tbl(i).schedule_date;
          l_amort_sched_tbl(l_counter).principal         := l_schedule_tbl(i).schedule_principal;
          l_amort_sched_tbl(l_counter).interest          := l_schedule_tbl(i).schedule_interest;
          l_amort_sched_tbl(l_counter).loan_payment      := l_schedule_tbl(i).schedule_principal + l_schedule_tbl(i).schedule_interest;
          l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter - 1).principal_balance - l_schedule_tbl(i).schedule_principal;
          l_amort_sched_tbl(l_counter).payment_type      := G_PROJECTED;
        END LOOP;

      END IF;

    END IF;

    x_amort_sched_tbl    := l_amort_sched_tbl;
    x_proj_interest_rate := l_proj_interest_rate;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data);

  EXCEPTION

    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OTHERS THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OTHERS',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

  END load_ln_actual_dtl;

  -- Start of comments
  -- API name       : load_ln_actual_summ
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Summary report
  --                  based on all receipts that have been processed by the Daily
  --                  Interest Program and projected payments for the remaining
  --                  loan term for the input contract. This schedule applies
  --                  to Loans with Revenue Recognition - ACTUAL
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : rpillay created.
  -- End of comments

  PROCEDURE load_ln_actual_summ(
              p_api_version         IN  NUMBER,
              p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
              x_return_status       OUT NOCOPY VARCHAR2,
              x_msg_count           OUT NOCOPY NUMBER,
              x_msg_data            OUT NOCOPY VARCHAR2,
              p_chr_id              IN  NUMBER,
              x_proj_interest_rate  OUT NOCOPY NUMBER,
              x_amort_sched_tbl     OUT NOCOPY amort_sched_tbl_type) IS

    l_api_name            CONSTANT    VARCHAR2(30) := 'LOAD_LN_ACTUAL_SUMM';
    l_api_version         CONSTANT    NUMBER       := 1.0;

    CURSOR amort_sched_dtl_csr(p_chr_id IN NUMBER) IS
    SELECT receipt_date,
           SUM(principal) principal,
           SUM(interest) interest
    FROM
    (
     SELECT sel_dii.stream_element_date receipt_date,
            0 principal,
            sel_dii.amount interest
     FROM okl_strm_elements sel_dii,
          okl_streams stm_dii,
          okl_strm_type_b sty_dii
     WHERE stm_dii.khr_id = p_chr_id
     AND   sty_dii.id = stm_dii.sty_id
     AND   sty_dii.stream_type_purpose = 'DAILY_INTEREST_INTEREST'
     AND   sel_dii.stm_id = stm_dii.id
     AND   stm_dii.say_code = 'CURR'
     AND   stm_dii.active_yn = 'Y'
     UNION ALL
     SELECT sel_dip.stream_element_date receipt_date,
            sel_dip.amount principal,
            0 interest
     FROM okl_strm_elements sel_dip,
          okl_streams stm_dip,
          okl_strm_type_b sty_dip
     WHERE stm_dip.khr_id = p_chr_id
     AND   sty_dip.id = stm_dip.sty_id
     AND   sty_dip.stream_type_purpose = 'DAILY_INTEREST_PRINCIPAL'
     AND   sel_dip.stm_id = stm_dip.id
     AND   stm_dip.say_code = 'CURR'
     AND   stm_dip.active_yn = 'Y'
    )
    GROUP BY receipt_date
    ORDER BY receipt_date;

    l_temp_tbl   receipts_tbl_type;
    l_temp1_tbl  receipts_tbl_type;
    l_temp_counter       NUMBER;

    l_principal_balance  NUMBER;
    l_amort_sched_tbl    amort_sched_tbl_type;
    l_counter            NUMBER;
    i                    NUMBER;
    l_max_receipt_date   DATE;

    l_periods_tbl        periods_tbl_type;
    l_arrears_yn         VARCHAR2(1);

    l_schedule_tbl       OKL_PRICING_PVT.schedule_table_type;
    l_min_schedule_date  DATE;
    l_last_int_calc_date DATE;
    l_proj_interest_rate NUMBER;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Derive Principal Balance
    Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => p_api_version,
                                    p_init_msg_list        => p_init_msg_list,
                                    x_return_status        => x_return_status,
                                    x_msg_count            => x_msg_count,
                                    x_msg_data             => x_msg_data,
                                    p_formula_name         => 'CONTRACT_FINANCED_AMOUNT',
                                    p_contract_id          => p_chr_id,
                                    p_line_id              => NULL,
                                    x_value               =>  l_principal_balance
                                    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_temp_counter := 0;
    OPEN amort_sched_dtl_csr(p_chr_id => p_chr_id);
    LOOP
      FETCH amort_sched_dtl_csr BULK COLLECT INTO l_temp_tbl LIMIT G_BULK_SIZE;
      EXIT WHEN l_temp_tbl.COUNT = 0;

      FOR i IN l_temp_tbl.FIRST..l_temp_tbl.LAST
      LOOP
        l_temp_counter := l_temp_counter + 1;
        l_temp1_tbl(l_temp_counter).receipt_date := l_temp_tbl(i).receipt_date;
        l_temp1_tbl(l_temp_counter).principal    := l_temp_tbl(i).principal;
        l_temp1_tbl(l_temp_counter).interest     := l_temp_tbl(i).interest;
      END LOOP;
    END LOOP;
    CLOSE amort_sched_dtl_csr;

     --Derive Payment Schedule Periods
     get_pymt_sched_periods(p_api_version          => p_api_version,
                            p_init_msg_list        => p_init_msg_list,
                            x_return_status        => x_return_status,
                            x_msg_count            => x_msg_count,
                            x_msg_data             => x_msg_data,
                            p_chr_id               => p_chr_id,
                            x_arrears_yn           => l_arrears_yn,
                            x_periods_tbl          => l_periods_tbl
                            );

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_counter := 1;
    l_amort_sched_tbl(l_counter).principal_balance := l_principal_balance;

    IF (l_temp1_tbl.COUNT > 0 AND l_periods_tbl.COUNT > 0) THEN

      i := l_temp1_tbl.FIRST;
      l_max_receipt_date := l_temp1_tbl(l_temp1_tbl.LAST).receipt_date;

      FOR j IN l_periods_tbl.FIRST..l_periods_tbl.LAST
      LOOP

        EXIT WHEN l_periods_tbl(j).start_date > l_max_receipt_date;

        l_counter := l_counter + 1;
        l_amort_sched_tbl(l_counter).start_date        := l_periods_tbl(j).start_date;
        l_amort_sched_tbl(l_counter).end_date          := l_periods_tbl(j).end_date;
        l_amort_sched_tbl(l_counter).principal         := 0;
        l_amort_sched_tbl(l_counter).interest          := 0;
        l_amort_sched_tbl(l_counter).loan_payment      := 0;
        l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter - 1).principal_balance;

        WHILE ((i <= l_temp1_tbl.COUNT) AND
              (l_temp1_tbl(i).receipt_date BETWEEN l_periods_tbl(j).start_date AND l_periods_tbl(j).end_date))
        LOOP
          l_amort_sched_tbl(l_counter).principal := l_amort_sched_tbl(l_counter).principal +  l_temp1_tbl(i).principal;
          l_amort_sched_tbl(l_counter).interest := l_amort_sched_tbl(l_counter).interest +  l_temp1_tbl(i).interest;
          l_amort_sched_tbl(l_counter).loan_payment := l_amort_sched_tbl(l_counter).loan_payment +  l_temp1_tbl(i).principal + l_temp1_tbl(i).interest;
          l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter).principal_balance - l_temp1_tbl(i).principal;
          i := i + 1;
        END LOOP;

      END LOOP;

      -- Handle receipts that fall outside the payment schedule
      IF (i <= l_temp1_tbl.COUNT) THEN

        l_counter := l_counter + 1;
        l_amort_sched_tbl(l_counter).start_date        := l_periods_tbl(l_periods_tbl.LAST).end_date + 1;
        l_amort_sched_tbl(l_counter).principal         := 0;
        l_amort_sched_tbl(l_counter).interest          := 0;
        l_amort_sched_tbl(l_counter).loan_payment      := 0;
        l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter - 1).principal_balance;

        WHILE (i <= l_temp1_tbl.COUNT)
        LOOP
          l_amort_sched_tbl(l_counter).end_date          := l_temp1_tbl(i).receipt_date;
          l_amort_sched_tbl(l_counter).principal         := l_amort_sched_tbl(l_counter).principal +  l_temp1_tbl(i).principal;
          l_amort_sched_tbl(l_counter).interest          := l_amort_sched_tbl(l_counter).interest +  l_temp1_tbl(i).interest;
          l_amort_sched_tbl(l_counter).loan_payment      := l_amort_sched_tbl(l_counter).loan_payment +  l_temp1_tbl(i).principal + l_temp1_tbl(i).interest;
          l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter).principal_balance - l_temp1_tbl(i).principal;
          i := i + 1;
         END LOOP;
      END IF;

    END IF;

    IF (l_amort_sched_tbl(l_counter).principal_balance > 0) THEN

      l_last_int_calc_date := OKL_VARIABLE_INTEREST_PVT.get_last_int_calc_date(p_khr_id => p_chr_id);

      --Generate Projected Schedule
      OKL_PRICING_PVT.generate_loan_schedules
      (p_khr_id         => p_chr_id,
       p_investment     => l_amort_sched_tbl(l_counter).principal_balance,
       p_start_date     => l_last_int_calc_date + 1,
       x_interest_rate  => l_proj_interest_rate,
       x_schedule_table => l_schedule_tbl,
       x_return_status  => x_return_status);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_schedule_tbl.COUNT > 0 AND l_periods_tbl.COUNT > 0) THEN

        i := l_schedule_tbl.FIRST;
        l_min_schedule_date := l_schedule_tbl(i).schedule_date;

        FOR j IN l_periods_tbl.FIRST..l_periods_tbl.LAST
        LOOP

          IF (l_periods_tbl(j).end_date <  l_min_schedule_date)  OR (i > l_schedule_tbl.COUNT) THEN
            NULL;
          ELSE

            IF (l_counter > 1) AND (l_amort_sched_tbl(l_counter).start_date = l_periods_tbl(j).start_date) THEN
              NULL;
            ELSE
              l_counter := l_counter + 1;
              l_amort_sched_tbl(l_counter).start_date        := l_periods_tbl(j).start_date;
              l_amort_sched_tbl(l_counter).end_date          := l_periods_tbl(j).end_date;
              l_amort_sched_tbl(l_counter).principal         := 0;
              l_amort_sched_tbl(l_counter).interest          := 0;
              l_amort_sched_tbl(l_counter).loan_payment      := 0;
              l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter - 1).principal_balance;
            END IF;

            WHILE ((i <= l_schedule_tbl.COUNT) AND
                  (l_schedule_tbl(i).schedule_date BETWEEN l_periods_tbl(j).start_date AND l_periods_tbl(j).end_date))
            LOOP
              l_amort_sched_tbl(l_counter).principal         := l_amort_sched_tbl(l_counter).principal + l_schedule_tbl(i).schedule_principal;
              l_amort_sched_tbl(l_counter).interest          := l_amort_sched_tbl(l_counter).interest + l_schedule_tbl(i).schedule_interest;
              l_amort_sched_tbl(l_counter).loan_payment      := l_amort_sched_tbl(l_counter).loan_payment + l_schedule_tbl(i).schedule_principal + l_schedule_tbl(i).schedule_interest;
              l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter).principal_balance - l_schedule_tbl(i).schedule_principal;
              i := i + 1;
            END LOOP;
          END IF;

        END LOOP;

        -- Handle projected payments that fall outside the payment schedule
        IF (i <= l_schedule_tbl.COUNT) THEN

          IF (l_counter > 1) AND (l_amort_sched_tbl(l_counter).start_date = (l_periods_tbl(l_periods_tbl.LAST).end_date + 1)) THEN
              NULL;
          ELSE
            l_counter := l_counter + 1;
            l_amort_sched_tbl(l_counter).start_date        := l_periods_tbl(l_periods_tbl.LAST).end_date + 1;
            l_amort_sched_tbl(l_counter).principal         := 0;
            l_amort_sched_tbl(l_counter).interest          := 0;
            l_amort_sched_tbl(l_counter).loan_payment      := 0;
            l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter - 1).principal_balance;
          END IF;

          WHILE (i <= l_schedule_tbl.COUNT)
          LOOP
            l_amort_sched_tbl(l_counter).principal         := l_amort_sched_tbl(l_counter).principal + l_schedule_tbl(i).schedule_principal;
            l_amort_sched_tbl(l_counter).interest          := l_amort_sched_tbl(l_counter).interest + l_schedule_tbl(i).schedule_interest;
            l_amort_sched_tbl(l_counter).loan_payment      := l_amort_sched_tbl(l_counter).loan_payment + l_schedule_tbl(i).schedule_principal + l_schedule_tbl(i).schedule_interest;
            l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter).principal_balance - l_schedule_tbl(i).schedule_principal;
            l_amort_sched_tbl(l_counter).end_date          := l_schedule_tbl(i).schedule_date;
            i := i + 1;
          END LOOP;

        END IF;

      END IF;

    END IF;

    x_amort_sched_tbl    := l_amort_sched_tbl;
    x_proj_interest_rate := l_proj_interest_rate;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data);

  EXCEPTION

    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OTHERS THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OTHERS',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

  END load_ln_actual_summ;

  -- Start of comments
  --
  -- API name       : load_ln_float_eb_dtl
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Detail report
  --                  based on the billed and unbilled stream elements for the input contract,
  --                  as of the date on which Amortization schedule is requested.
  --                  This schedule applies to Loans with Interest Calculation Basis - FLOAT and
  --                  Revenue Recognition - ESTIMATED_AND_BILLED
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : rpillay created.
  --                  rpillay 20-Feb-08 Bug# 6831074 :Changed payment type G_PPD to G_BILLED/G_PROJECTED
  -- End of comments

  PROCEDURE load_ln_float_eb_dtl(
              p_api_version         IN  NUMBER,
              p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
              x_return_status       OUT NOCOPY VARCHAR2,
              x_msg_count           OUT NOCOPY NUMBER,
              x_msg_data            OUT NOCOPY VARCHAR2,
              p_chr_id              IN  NUMBER,
              x_amort_sched_tbl     OUT NOCOPY amort_sched_tbl_type) IS

    l_api_name            CONSTANT    VARCHAR2(30) := 'LOAD_LN_FLOAT_EB_DTL';
    l_api_version         CONSTANT    NUMBER       := 1.0;

    CURSOR last_bill_date_csr(p_chr_id IN NUMBER) IS
    SELECT MAX(sel.stream_element_date)
    FROM okl_streams stm,
         okl_strm_elements sel,
         okl_strm_type_b sty
     WHERE stm.khr_id = p_chr_id
     AND   sty.id = stm.sty_id
     AND   sty.stream_type_purpose = 'PRINCIPAL_PAYMENT'
     AND   sel.stm_id = stm.id
     AND   stm.say_code = 'CURR'
     AND   stm.active_yn = 'Y'
     AND   sel.date_billed IS NOT NULL;

    l_last_bill_date OKL_STRM_ELEMENTS.stream_element_date%TYPE;

    CURSOR chr_csr(p_chr_id IN NUMBER) IS
    SELECT chr.start_date
    FROM okc_k_headers_b chr
    WHERE  chr.id = p_chr_id;

    CURSOR amort_sched_dtl_csr(p_chr_id         IN NUMBER,
                               p_last_bill_date IN DATE) IS
    SELECT bill_date,
           SUM(principal) principal,
           SUM(interest) interest,
           0 princ_pay_down,
           payment_type
    FROM
    (
     SELECT sel.stream_element_date bill_date,
            0 principal,
            sel.amount interest,
            G_BILLED payment_type
     FROM okl_strm_elements sel,
          okl_streams stm,
          okl_strm_type_b sty
     WHERE stm.khr_id = p_chr_id
     AND   sty.id = stm.sty_id
     AND   sty.stream_type_purpose = 'VARIABLE_INTEREST'
     AND   sel.stm_id = stm.id
     AND   stm.say_code = 'CURR'
     AND   stm.active_yn = 'Y'
     AND   sel.date_billed IS NOT NULL
     UNION ALL
     SELECT sel.stream_element_date bill_date,
            sel.amount principal,
            0 interest,
            decode(sel.date_billed,NULL,G_PROJECTED,G_BILLED) payment_type
     FROM okl_strm_elements sel,
          okl_streams stm,
          okl_strm_type_b sty
     WHERE stm.khr_id = p_chr_id
     AND   sty.id = stm.sty_id
     AND   sty.stream_type_purpose = 'PRINCIPAL_PAYMENT'
     AND   sel.stm_id = stm.id
     AND   stm.say_code = 'CURR'
     AND   stm.active_yn = 'Y'
     UNION ALL
     SELECT sel.stream_element_date bill_date,
            0 principal,
            sel.amount interest,
            G_PROJECTED payment_type
     FROM okl_strm_elements sel,
          okl_streams stm,
          okl_strm_type_b sty
     WHERE stm.khr_id = p_chr_id
     AND   sty.id = stm.sty_id
     AND   sty.stream_type_purpose = 'INTEREST_PAYMENT'
     AND   sel.stm_id = stm.id
     AND   stm.say_code = 'CURR'
     AND   stm.active_yn = 'Y'
     AND   sel.date_billed IS NULL
     AND   sel.stream_element_date > p_last_bill_date
    )
    GROUP BY bill_date,payment_type
    UNION ALL
    SELECT bill_date,
           0 principal,
           0 interest,
           SUM(princ_pay_down) princ_pay_down,
           payment_type
    FROM
    (
    SELECT sel.stream_element_date bill_date,
           0 principal,
           0 interest,
           sel.amount princ_pay_down,
           decode(sel.date_billed,NULL,G_PROJECTED,G_BILLED) payment_type
    FROM okl_strm_elements sel,
         okl_streams stm,
         okl_strm_type_b sty
    WHERE stm.khr_id = p_chr_id
    AND   sty.id = stm.sty_id
    AND   sty.stream_type_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT'
    AND   sel.stm_id = stm.id
    AND   stm.say_code = 'CURR'
    AND   stm.active_yn = 'Y'
    )
    GROUP BY bill_date,payment_type
    ORDER BY bill_date;

    TYPE temp_tbl_type IS TABLE OF amort_sched_dtl_csr%ROWTYPE INDEX BY BINARY_INTEGER;
    l_temp_tbl      temp_tbl_type;

    l_principal_balance NUMBER;
    l_amort_sched_tbl  amort_sched_tbl_type;
    l_counter NUMBER;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Derive Principal Balance
    Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => p_api_version,
                                    p_init_msg_list        => p_init_msg_list,
                                    x_return_status        => x_return_status,
                                    x_msg_count            => x_msg_count,
                                    x_msg_data             => x_msg_data,
                                    p_formula_name         => 'CONTRACT_FINANCED_AMOUNT',
                                    p_contract_id          => p_chr_id,
                                    p_line_id              => NULL,
                                    x_value               =>  l_principal_balance
                                    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN last_bill_date_csr(p_chr_id => p_chr_id);
    FETCH last_bill_date_csr INTO l_last_bill_date;
    CLOSE last_bill_date_csr;

    IF l_last_bill_date IS NULL THEN
      OPEN chr_csr(p_chr_id => p_chr_id);
      FETCH chr_csr INTO l_last_bill_date;
      CLOSE chr_csr;
    END IF;

    l_counter := 1;
    l_amort_sched_tbl(l_counter).principal_balance := l_principal_balance;

    OPEN amort_sched_dtl_csr(p_chr_id => p_chr_id,
                             p_last_bill_date => l_last_bill_date);
    LOOP
      FETCH amort_sched_dtl_csr BULK COLLECT INTO l_temp_tbl LIMIT G_BULK_SIZE;
      EXIT WHEN l_temp_tbl.COUNT = 0;

      FOR i IN l_temp_tbl.FIRST..l_temp_tbl.LAST
      LOOP
          l_counter := l_counter + 1;
          l_amort_sched_tbl(l_counter).start_date        := l_temp_tbl(i).bill_date;
          l_amort_sched_tbl(l_counter).principal         := l_temp_tbl(i).principal + l_temp_tbl(i).princ_pay_down;
          l_amort_sched_tbl(l_counter).interest          := l_temp_tbl(i).interest;
          l_amort_sched_tbl(l_counter).loan_payment      := l_temp_tbl(i).principal + l_temp_tbl(i).princ_pay_down + l_temp_tbl(i).interest;
          l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter - 1).principal_balance - l_temp_tbl(i).principal - l_temp_tbl(i).princ_pay_down;
          l_amort_sched_tbl(l_counter).payment_type      := l_temp_tbl(i).payment_type;
      END LOOP;
    END LOOP;
    CLOSE amort_sched_dtl_csr;

    x_amort_sched_tbl := l_amort_sched_tbl;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data);

  EXCEPTION

    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OTHERS THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OTHERS',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

  END load_ln_float_eb_dtl;

  -- Start of comments
  --
  -- API name       : load_ln_float_eb_summ
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Summary report
  --                  based on the billed and unbilled stream elements for the input contract,
  --                  as of the date on which Amortization schedule is requested.
  --                  This schedule applies to Loans with Interest Calculation Basis - FLOAT and
  --                  Revenue Recognition - ESTIMATED_AND_BILLED
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : rpillay created.
  -- End of comments

  PROCEDURE load_ln_float_eb_summ(
              p_api_version         IN  NUMBER,
              p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
              x_return_status       OUT NOCOPY VARCHAR2,
              x_msg_count           OUT NOCOPY NUMBER,
              x_msg_data            OUT NOCOPY VARCHAR2,
              p_chr_id              IN  NUMBER,
              x_amort_sched_tbl     OUT NOCOPY amort_sched_tbl_type) IS

    l_api_name            CONSTANT    VARCHAR2(30) := 'LOAD_LN_FLOAT_EB_SUMM';
    l_api_version         CONSTANT    NUMBER       := 1.0;

    CURSOR last_bill_date_csr(p_chr_id IN NUMBER) IS
    SELECT MAX(sel.stream_element_date)
    FROM okl_streams stm,
         okl_strm_elements sel,
         okl_strm_type_b sty
     WHERE stm.khr_id = p_chr_id
     AND   sty.id = stm.sty_id
     AND   sty.stream_type_purpose = 'PRINCIPAL_PAYMENT'
     AND   sel.stm_id = stm.id
     AND   stm.say_code = 'CURR'
     AND   stm.active_yn = 'Y'
     AND   sel.date_billed IS NOT NULL;

    l_last_bill_date OKL_STRM_ELEMENTS.stream_element_date%TYPE;

    CURSOR chr_csr(p_chr_id IN NUMBER) IS
    SELECT chr.start_date
    FROM okc_k_headers_b chr
    WHERE  chr.id = p_chr_id;

    CURSOR amort_sched_dtl_csr(p_chr_id         IN NUMBER,
                               p_last_bill_date IN DATE) IS
    SELECT bill_date,
           SUM(principal) principal,
           SUM(interest) interest
    FROM
    (
     SELECT sel.stream_element_date bill_date,
            0 principal,
            sel.amount interest
     FROM okl_strm_elements sel,
          okl_streams stm,
          okl_strm_type_b sty
     WHERE stm.khr_id = p_chr_id
     AND   sty.id = stm.sty_id
     AND   sty.stream_type_purpose = 'VARIABLE_INTEREST'
     AND   sel.stm_id = stm.id
     AND   stm.say_code = 'CURR'
     AND   stm.active_yn = 'Y'
     AND   sel.date_billed IS NOT NULL
     UNION ALL
     SELECT sel.stream_element_date bill_date,
            0 principal,
            sel.amount interest
     FROM okl_strm_elements sel,
          okl_streams stm,
          okl_strm_type_b sty
     WHERE stm.khr_id = p_chr_id
     AND   sty.id = stm.sty_id
     AND   sty.stream_type_purpose = 'INTEREST_PAYMENT'
     AND   sel.stm_id = stm.id
     AND   stm.say_code = 'CURR'
     AND   stm.active_yn = 'Y'
     AND   sel.date_billed IS NULL
     AND   sel.stream_element_date > p_last_bill_date
     UNION ALL
     SELECT sel.stream_element_date bill_date,
            sel.amount principal,
            0 interest
     FROM okl_strm_elements sel,
          okl_streams stm,
          okl_strm_type_b sty
     WHERE stm.khr_id = p_chr_id
     AND   sty.id = stm.sty_id
     AND   sty.stream_type_purpose IN ('PRINCIPAL_PAYMENT','UNSCHEDULED_PRINCIPAL_PAYMENT')
     AND   sel.stm_id = stm.id
     AND   stm.say_code = 'CURR'
     AND   stm.active_yn = 'Y'
    )
    GROUP BY bill_date
    ORDER BY bill_date;

    TYPE temp_tbl_type IS TABLE OF amort_sched_dtl_csr%ROWTYPE INDEX BY BINARY_INTEGER;
    l_temp_tbl          temp_tbl_type;
    l_temp1_tbl         temp_tbl_type;
    l_temp_counter      NUMBER;

    l_principal_balance NUMBER;
    l_amort_sched_tbl   amort_sched_tbl_type;
    l_counter           NUMBER;
    i                   NUMBER;
    l_max_bill_date     DATE;

    l_periods_tbl       periods_tbl_type;
    l_arrears_yn        VARCHAR2(1);
  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Derive Principal Balance
    Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => p_api_version,
                                    p_init_msg_list        => p_init_msg_list,
                                    x_return_status        => x_return_status,
                                    x_msg_count            => x_msg_count,
                                    x_msg_data             => x_msg_data,
                                    p_formula_name         => 'CONTRACT_FINANCED_AMOUNT',
                                    p_contract_id          => p_chr_id,
                                    p_line_id              => NULL,
                                    x_value               =>  l_principal_balance
                                    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN last_bill_date_csr(p_chr_id => p_chr_id);
    FETCH last_bill_date_csr INTO l_last_bill_date;
    CLOSE last_bill_date_csr;

    IF l_last_bill_date IS NULL THEN
      OPEN chr_csr(p_chr_id => p_chr_id);
      FETCH chr_csr INTO l_last_bill_date;
      CLOSE chr_csr;
    END IF;

    l_temp_counter := 0;
    OPEN amort_sched_dtl_csr(p_chr_id         => p_chr_id,
                             p_last_bill_date => l_last_bill_date);
    LOOP
      FETCH amort_sched_dtl_csr BULK COLLECT INTO l_temp_tbl LIMIT G_BULK_SIZE;
      EXIT WHEN l_temp_tbl.COUNT = 0;

      FOR i IN l_temp_tbl.FIRST..l_temp_tbl.LAST
      LOOP
        l_temp_counter := l_temp_counter + 1;
        l_temp1_tbl(l_temp_counter).bill_date    := l_temp_tbl(i).bill_date;
        l_temp1_tbl(l_temp_counter).principal    := l_temp_tbl(i).principal;
        l_temp1_tbl(l_temp_counter).interest     := l_temp_tbl(i).interest;
      END LOOP;
    END LOOP;
    CLOSE amort_sched_dtl_csr;

     --Derive Payment Schedule Periods
     get_pymt_sched_periods(p_api_version          => p_api_version,
                            p_init_msg_list        => p_init_msg_list,
                            x_return_status        => x_return_status,
                            x_msg_count            => x_msg_count,
                            x_msg_data             => x_msg_data,
                            p_chr_id               => p_chr_id,
                            x_arrears_yn           => l_arrears_yn,
                            x_periods_tbl          => l_periods_tbl
                            );

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_counter := 1;
    l_amort_sched_tbl(l_counter).principal_balance := l_principal_balance;

    IF (l_temp1_tbl.COUNT > 0 AND l_periods_tbl.COUNT > 0) THEN

      i := l_temp1_tbl.FIRST;
      l_max_bill_date := l_temp1_tbl(l_temp1_tbl.LAST).bill_date;

      FOR j IN l_periods_tbl.FIRST..l_periods_tbl.LAST
      LOOP

        EXIT WHEN l_periods_tbl(j).start_date > l_max_bill_date;

        l_counter := l_counter + 1;
        l_amort_sched_tbl(l_counter).start_date        := l_periods_tbl(j).start_date;
        l_amort_sched_tbl(l_counter).end_date          := l_periods_tbl(j).end_date;
        l_amort_sched_tbl(l_counter).principal         := 0;
        l_amort_sched_tbl(l_counter).interest          := 0;
        l_amort_sched_tbl(l_counter).loan_payment      := 0;
        l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter - 1).principal_balance;

        WHILE ((i <= l_temp1_tbl.COUNT) AND
              (l_temp1_tbl(i).bill_date BETWEEN l_periods_tbl(j).start_date AND l_periods_tbl(j).end_date))
        LOOP
          l_amort_sched_tbl(l_counter).principal := l_amort_sched_tbl(l_counter).principal +  l_temp1_tbl(i).principal;
          l_amort_sched_tbl(l_counter).interest := l_amort_sched_tbl(l_counter).interest +  l_temp1_tbl(i).interest;
          l_amort_sched_tbl(l_counter).loan_payment := l_amort_sched_tbl(l_counter).loan_payment +  l_temp1_tbl(i).principal + l_temp1_tbl(i).interest;
          l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter).principal_balance - l_temp1_tbl(i).principal;
          i := i + 1;
        END LOOP;

      END LOOP;

      -- Handle payments that fall outside the payment schedule
      IF (i <= l_temp1_tbl.COUNT) THEN

        l_counter := l_counter + 1;
        l_amort_sched_tbl(l_counter).start_date        := l_periods_tbl(l_periods_tbl.LAST).end_date + 1;
        l_amort_sched_tbl(l_counter).principal         := 0;
        l_amort_sched_tbl(l_counter).interest          := 0;
        l_amort_sched_tbl(l_counter).loan_payment      := 0;
        l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter - 1).principal_balance;

        WHILE (i <= l_temp1_tbl.COUNT)
        LOOP
          l_amort_sched_tbl(l_counter).end_date          := l_temp1_tbl(i).bill_date;
          l_amort_sched_tbl(l_counter).principal         := l_amort_sched_tbl(l_counter).principal +  l_temp1_tbl(i).principal;
          l_amort_sched_tbl(l_counter).interest          := l_amort_sched_tbl(l_counter).interest +  l_temp1_tbl(i).interest;
          l_amort_sched_tbl(l_counter).loan_payment      := l_amort_sched_tbl(l_counter).loan_payment +  l_temp1_tbl(i).principal + l_temp1_tbl(i).interest;
          l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter).principal_balance - l_temp1_tbl(i).principal;
          i := i + 1;
         END LOOP;
      END IF;

    END IF;

    x_amort_sched_tbl := l_amort_sched_tbl;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data);

  EXCEPTION

    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OTHERS THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OTHERS',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

  END load_ln_float_eb_summ;

  -- Start of comments
  --
  -- API name       : load_ln_cc_strm_dtl
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Detail report
  --                  based on the billed and unbilled stream elements for the input contract,
  --                  as of the date on which Amortization schedule is requested.
  --                  This schedule applies to Loans with Interest Calculation Basis -
  --                  CATCHUP/CLEANUP and Revenue Recognition - STREAMS
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : rpillay created.
  --                  rpillay 20-Feb-08 Bug# 6831074 :Changed payment type G_PPD to G_BILLED/G_PROJECTED
  --
  -- End of comments

  PROCEDURE load_ln_cc_strm_dtl(
              p_api_version         IN  NUMBER,
              p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
              x_return_status       OUT NOCOPY VARCHAR2,
              x_msg_count           OUT NOCOPY NUMBER,
              x_msg_data            OUT NOCOPY VARCHAR2,
              p_chr_id              IN  NUMBER,
              x_amort_sched_tbl     OUT NOCOPY amort_sched_tbl_type) IS

    l_api_name            CONSTANT    VARCHAR2(30) := 'LOAD_LN_CC_STRM_DTL';
    l_api_version         CONSTANT    NUMBER       := 1.0;

    CURSOR amort_sched_dtl_csr(p_chr_id IN NUMBER) IS
    SELECT bill_date,
           SUM(principal) principal,
           SUM(interest) interest,
           0 princ_pay_down,
           payment_type
    FROM
    (
     SELECT sel.stream_element_date bill_date,
            0 principal,
            sel.amount interest,
            decode(sel.date_billed,NULL,G_PROJECTED,G_BILLED) payment_type
     FROM okl_strm_elements sel,
          okl_streams stm,
          okl_strm_type_b sty
     WHERE stm.khr_id = p_chr_id
     AND   sty.id = stm.sty_id
     AND   sty.stream_type_purpose = 'INTEREST_PAYMENT'
     AND   sel.stm_id = stm.id
     AND   stm.say_code = 'CURR'
     AND   stm.active_yn = 'Y'
     UNION ALL
     SELECT sel.stream_element_date bill_date,
            sel.amount principal,
            0 interest,
            decode(sel.date_billed,NULL,G_PROJECTED,G_BILLED) payment_type
     FROM okl_strm_elements sel,
          okl_streams stm,
          okl_strm_type_b sty
     WHERE stm.khr_id = p_chr_id
     AND   sty.id = stm.sty_id
     AND   sty.stream_type_purpose = 'PRINCIPAL_PAYMENT'
     AND   sel.stm_id = stm.id
     AND   stm.say_code = 'CURR'
     AND   stm.active_yn = 'Y'
    )
    GROUP BY bill_date,payment_type
    UNION ALL
    SELECT sel.stream_element_date bill_date,
           SUM(sel.amount) principal,
           0 interest,
           0 princ_pay_down,
           G_BILLED payment_type
    FROM okl_strm_elements sel,
         okl_streams stm,
         okl_strm_type_b sty
    WHERE stm.khr_id = p_chr_id
    AND   sty.id = stm.sty_id
    AND   sty.stream_type_purpose = 'PRINCIPAL_CATCHUP'
    AND   sel.stm_id = stm.id
    AND   stm.say_code = 'CURR'
    AND   stm.active_yn = 'Y'
    AND   sel.date_billed IS NOT NULL
    GROUP BY sel.stream_element_date
    UNION ALL
    SELECT sel.stream_element_date bill_date,
           0 principal,
           SUM(sel.amount) interest,
           0 princ_pay_down,
           G_BILLED payment_type
    FROM okl_strm_elements sel,
         okl_streams stm,
         okl_strm_type_b sty
    WHERE stm.khr_id = p_chr_id
    AND   sty.id = stm.sty_id
    AND   sty.stream_type_purpose = 'INTEREST_CATCHUP'
    AND   sel.stm_id = stm.id
    AND   stm.say_code = 'CURR'
    AND   stm.active_yn = 'Y'
    AND   sel.date_billed IS NOT NULL
    GROUP BY sel.stream_element_date
    UNION ALL
    SELECT bill_date,
           0 principal,
           0 interest,
           SUM(princ_pay_down) princ_pay_down,
           payment_type
    FROM
    (
    SELECT sel.stream_element_date bill_date,
           0 principal,
           0 interest,
           sel.amount princ_pay_down,
           decode(sel.date_billed,NULL,G_PROJECTED,G_BILLED) payment_type
    FROM okl_strm_elements sel,
         okl_streams stm,
         okl_strm_type_b sty
    WHERE stm.khr_id = p_chr_id
    AND   sty.id = stm.sty_id
    AND   sty.stream_type_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT'
    AND   sel.stm_id = stm.id
    AND   stm.say_code = 'CURR'
    AND   stm.active_yn = 'Y'
    )
    GROUP BY bill_date,payment_type
    ORDER BY bill_date;

    TYPE temp_tbl_type IS TABLE OF amort_sched_dtl_csr%ROWTYPE INDEX BY BINARY_INTEGER;
    l_temp_tbl      temp_tbl_type;

    l_principal_balance NUMBER;
    l_amort_sched_tbl  amort_sched_tbl_type;
    l_counter NUMBER;

    l_temp_counter     NUMBER;
    l_temp1_tbl        temp_tbl_type;
    l_max_bill_counter NUMBER;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Derive Principal Balance
    Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => p_api_version,
                                    p_init_msg_list        => p_init_msg_list,
                                    x_return_status        => x_return_status,
                                    x_msg_count            => x_msg_count,
                                    x_msg_data             => x_msg_data,
                                    p_formula_name         => 'CONTRACT_FINANCED_AMOUNT',
                                    p_contract_id          => p_chr_id,
                                    p_line_id              => NULL,
                                    x_value               =>  l_principal_balance
                                    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_max_bill_counter := 0;
    l_temp_counter := 0;
    OPEN amort_sched_dtl_csr(p_chr_id => p_chr_id);
    LOOP
      FETCH amort_sched_dtl_csr BULK COLLECT INTO l_temp_tbl LIMIT G_BULK_SIZE;
      EXIT WHEN l_temp_tbl.COUNT = 0;

      FOR i IN l_temp_tbl.FIRST..l_temp_tbl.LAST
      LOOP
        l_temp_counter := l_temp_counter + 1;
        l_temp1_tbl(l_temp_counter).bill_date      := l_temp_tbl(i).bill_date;
        l_temp1_tbl(l_temp_counter).principal      := l_temp_tbl(i).principal;
        l_temp1_tbl(l_temp_counter).interest       := l_temp_tbl(i).interest;
        l_temp1_tbl(l_temp_counter).princ_pay_down := l_temp_tbl(i).princ_pay_down;
        l_temp1_tbl(l_temp_counter).payment_type   := l_temp_tbl(i).payment_type;

        IF (l_temp1_tbl(l_temp_counter).payment_type = G_BILLED) THEN
          l_max_bill_counter := l_temp_counter;
        END IF;
      END LOOP;
    END LOOP;
    CLOSE amort_sched_dtl_csr;

    l_counter := 1;
    l_amort_sched_tbl(l_counter).principal_balance := l_principal_balance;

    IF (l_temp1_tbl.COUNT > 0) THEN
      FOR i IN l_temp1_tbl.FIRST..l_temp1_tbl.LAST
      LOOP
        IF (l_temp1_tbl(i).payment_type = G_BILLED OR l_amort_sched_tbl(l_counter).principal_balance > 0) THEN
          l_counter := l_counter + 1;
          l_amort_sched_tbl(l_counter).start_date        := l_temp1_tbl(i).bill_date;
          l_amort_sched_tbl(l_counter).principal         := l_temp1_tbl(i).principal + l_temp1_tbl(i).princ_pay_down;
          l_amort_sched_tbl(l_counter).interest          := l_temp1_tbl(i).interest;
          l_amort_sched_tbl(l_counter).loan_payment      := l_temp1_tbl(i).principal + l_temp1_tbl(i).princ_pay_down + l_temp1_tbl(i).interest;
          l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter - 1).principal_balance - l_temp1_tbl(i).principal - l_temp1_tbl(i).princ_pay_down;
          l_amort_sched_tbl(l_counter).payment_type      := l_temp1_tbl(i).payment_type;

          IF (l_amort_sched_tbl(l_counter).principal_balance < 0 AND l_amort_sched_tbl(l_counter).payment_type = G_PROJECTED) THEN
            l_amort_sched_tbl(l_counter).principal         := l_amort_sched_tbl(l_counter).principal + l_amort_sched_tbl(l_counter).principal_balance;
            l_amort_sched_tbl(l_counter).loan_payment      := l_amort_sched_tbl(l_counter).principal + l_amort_sched_tbl(l_counter).interest;
            l_amort_sched_tbl(l_counter).principal_balance := 0;

            EXIT WHEN (i > l_max_bill_counter);
          END IF;
        END IF;
      END LOOP;
    END IF;

    x_amort_sched_tbl := l_amort_sched_tbl;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data);

  EXCEPTION

    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OTHERS THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OTHERS',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

  END load_ln_cc_strm_dtl;

  -- Start of comments
  --
  -- API name       : load_ln_cc_strm_summ
  -- Pre-reqs       : None
  -- Function       : This procedure loads the Amortization Schedule - Summary report
  --                  based on the billed and unbilled stream elements for the input contract,
  --                  as of the date on which Amortization schedule is requested.
  --                  This schedule applies to Loans with Interest Calculation Basis -
  --                  CATCHUP/CLEANUP and Revenue Recognition - STREAMS
  --
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_chr_id  - Contract ID
  -- Version        : 1.0
  -- History        : rpillay created.
  -- End of comments

  PROCEDURE load_ln_cc_strm_summ(
              p_api_version         IN  NUMBER,
              p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
              x_return_status       OUT NOCOPY VARCHAR2,
              x_msg_count           OUT NOCOPY NUMBER,
              x_msg_data            OUT NOCOPY VARCHAR2,
              p_chr_id              IN  NUMBER,
              x_amort_sched_tbl     OUT NOCOPY amort_sched_tbl_type) IS

    l_api_name            CONSTANT    VARCHAR2(30) := 'LOAD_LN_CC_STRM_SUMM';
    l_api_version         CONSTANT    NUMBER       := 1.0;

    CURSOR amort_sched_dtl_csr(p_chr_id IN NUMBER) IS
    SELECT bill_date,
           SUM(principal) principal,
           SUM(interest) interest,
           payment_type
    FROM
    (
     SELECT sel.stream_element_date bill_date,
            0 principal,
            sel.amount interest,
            DECODE(sel.date_billed,NULL,G_PROJECTED,G_BILLED) payment_type
     FROM okl_strm_elements sel,
          okl_streams stm,
          okl_strm_type_b sty
     WHERE stm.khr_id = p_chr_id
     AND   sty.id = stm.sty_id
     AND   sty.stream_type_purpose IN ('INTEREST_PAYMENT','INTEREST_CATCHUP')
     AND   sel.stm_id = stm.id
     AND   stm.say_code = 'CURR'
     AND   stm.active_yn = 'Y'
     UNION ALL
     SELECT sel.stream_element_date bill_date,
            sel.amount principal,
            0 interest,
            DECODE(sel.date_billed,NULL,G_PROJECTED,G_BILLED) payment_type
     FROM okl_strm_elements sel,
          okl_streams stm,
          okl_strm_type_b sty
     WHERE stm.khr_id = p_chr_id
     AND   sty.id = stm.sty_id
     AND   sty.stream_type_purpose IN ('PRINCIPAL_PAYMENT','PRINCIPAL_CATCHUP','UNSCHEDULED_PRINCIPAL_PAYMENT')
     AND   sel.stm_id = stm.id
     AND   stm.say_code = 'CURR'
     AND   stm.active_yn = 'Y'
    )
    GROUP BY bill_date,payment_type
    ORDER BY bill_date;

    TYPE temp_tbl_type IS TABLE OF amort_sched_dtl_csr%ROWTYPE INDEX BY BINARY_INTEGER;
    l_temp_tbl          temp_tbl_type;
    l_temp1_tbl         temp_tbl_type;
    l_temp_counter      NUMBER;

    l_principal_balance NUMBER;
    l_amort_sched_tbl   amort_sched_tbl_type;
    l_counter           NUMBER;
    i                   NUMBER;
    l_max_bill_date     DATE;

    l_periods_tbl       periods_tbl_type;
    l_arrears_yn        VARCHAR2(1);
    l_max_bill_counter  NUMBER;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Derive Principal Balance
    Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => p_api_version,
                                    p_init_msg_list        => p_init_msg_list,
                                    x_return_status        => x_return_status,
                                    x_msg_count            => x_msg_count,
                                    x_msg_data             => x_msg_data,
                                    p_formula_name         => 'CONTRACT_FINANCED_AMOUNT',
                                    p_contract_id          => p_chr_id,
                                    p_line_id              => NULL,
                                    x_value               =>  l_principal_balance
                                    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_temp_counter := 0;
    OPEN amort_sched_dtl_csr(p_chr_id => p_chr_id);
    LOOP
      FETCH amort_sched_dtl_csr BULK COLLECT INTO l_temp_tbl LIMIT G_BULK_SIZE;
      EXIT WHEN l_temp_tbl.COUNT = 0;

      FOR i IN l_temp_tbl.FIRST..l_temp_tbl.LAST
      LOOP
        l_temp_counter := l_temp_counter + 1;
        l_temp1_tbl(l_temp_counter).bill_date    := l_temp_tbl(i).bill_date;
        l_temp1_tbl(l_temp_counter).principal    := l_temp_tbl(i).principal;
        l_temp1_tbl(l_temp_counter).interest     := l_temp_tbl(i).interest;
        l_temp1_tbl(l_temp_counter).payment_type := l_temp_tbl(i).payment_type;

        IF (l_temp1_tbl(l_temp_counter).payment_type = G_BILLED) THEN
          l_max_bill_counter := l_temp_counter;
        END IF;

     END LOOP;
    END LOOP;
    CLOSE amort_sched_dtl_csr;

     --Derive Payment Schedule Periods
     get_pymt_sched_periods(p_api_version          => p_api_version,
                            p_init_msg_list        => p_init_msg_list,
                            x_return_status        => x_return_status,
                            x_msg_count            => x_msg_count,
                            x_msg_data             => x_msg_data,
                            p_chr_id               => p_chr_id,
                            x_arrears_yn           => l_arrears_yn,
                            x_periods_tbl          => l_periods_tbl
                            );

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_counter := 1;
    l_amort_sched_tbl(l_counter).principal_balance := l_principal_balance;

    IF (l_temp1_tbl.COUNT > 0 AND l_periods_tbl.COUNT > 0) THEN

      i := l_temp1_tbl.FIRST;
      l_max_bill_date := l_temp1_tbl(l_temp1_tbl.LAST).bill_date;

      FOR j IN l_periods_tbl.FIRST..l_periods_tbl.LAST
      LOOP

        EXIT WHEN (l_periods_tbl(j).start_date > l_max_bill_date) OR
                  (l_amort_sched_tbl(l_counter).principal_balance <= 0 AND i > l_max_bill_counter);

        l_counter := l_counter + 1;
        l_amort_sched_tbl(l_counter).start_date        := l_periods_tbl(j).start_date;
        l_amort_sched_tbl(l_counter).end_date          := l_periods_tbl(j).end_date;
        l_amort_sched_tbl(l_counter).principal         := 0;
        l_amort_sched_tbl(l_counter).interest          := 0;
        l_amort_sched_tbl(l_counter).loan_payment      := 0;
        l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter - 1).principal_balance;

        WHILE ((i <= l_temp1_tbl.COUNT) AND
              (l_temp1_tbl(i).bill_date BETWEEN l_periods_tbl(j).start_date AND l_periods_tbl(j).end_date))
        LOOP

          IF (l_temp1_tbl(i).payment_type = G_BILLED OR l_amort_sched_tbl(l_counter).principal_balance > 0) THEN

            l_amort_sched_tbl(l_counter).principal := l_amort_sched_tbl(l_counter).principal +  l_temp1_tbl(i).principal;
            l_amort_sched_tbl(l_counter).interest := l_amort_sched_tbl(l_counter).interest +  l_temp1_tbl(i).interest;
            l_amort_sched_tbl(l_counter).loan_payment := l_amort_sched_tbl(l_counter).loan_payment +  l_temp1_tbl(i).principal + l_temp1_tbl(i).interest;
            l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter).principal_balance - l_temp1_tbl(i).principal;

            IF (l_amort_sched_tbl(l_counter).principal_balance < 0 AND l_temp1_tbl(i).payment_type = G_PROJECTED) THEN
              l_amort_sched_tbl(l_counter).principal         := l_amort_sched_tbl(l_counter).principal + l_amort_sched_tbl(l_counter).principal_balance;
              l_amort_sched_tbl(l_counter).loan_payment      := l_amort_sched_tbl(l_counter).principal + l_amort_sched_tbl(l_counter).interest;
              l_amort_sched_tbl(l_counter).principal_balance := 0;
            END IF;
          END IF;
          i := i + 1;
        END LOOP;

      END LOOP;

      -- Handle payments that fall outside the payment schedule
      IF (i <= l_temp1_tbl.COUNT) AND (l_temp1_tbl(i).bill_date > l_periods_tbl(l_periods_tbl.LAST).end_date) THEN

        IF (l_amort_sched_tbl(l_counter).principal_balance <= 0 AND i > l_max_bill_counter) THEN
          NULL;
        ELSE

          l_counter := l_counter + 1;
          l_amort_sched_tbl(l_counter).start_date        := l_periods_tbl(l_periods_tbl.LAST).end_date + 1;
          l_amort_sched_tbl(l_counter).principal         := 0;
          l_amort_sched_tbl(l_counter).interest          := 0;
          l_amort_sched_tbl(l_counter).loan_payment      := 0;
          l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter - 1).principal_balance;

          WHILE (i <= l_temp1_tbl.COUNT)
          LOOP
            IF (l_temp1_tbl(i).payment_type = G_BILLED OR l_amort_sched_tbl(l_counter).principal_balance > 0) THEN
              l_amort_sched_tbl(l_counter).end_date          := l_temp1_tbl(i).bill_date;
              l_amort_sched_tbl(l_counter).principal         := l_amort_sched_tbl(l_counter).principal +  l_temp1_tbl(i).principal;
              l_amort_sched_tbl(l_counter).interest          := l_amort_sched_tbl(l_counter).interest +  l_temp1_tbl(i).interest;
              l_amort_sched_tbl(l_counter).loan_payment      := l_amort_sched_tbl(l_counter).loan_payment +  l_temp1_tbl(i).principal + l_temp1_tbl(i).interest;
              l_amort_sched_tbl(l_counter).principal_balance := l_amort_sched_tbl(l_counter).principal_balance - l_temp1_tbl(i).principal;

              IF (l_amort_sched_tbl(l_counter).principal_balance < 0 AND l_temp1_tbl(i).payment_type = G_PROJECTED) THEN
                l_amort_sched_tbl(l_counter).principal         := l_amort_sched_tbl(l_counter).principal + l_amort_sched_tbl(l_counter).principal_balance;
                l_amort_sched_tbl(l_counter).loan_payment      := l_amort_sched_tbl(l_counter).principal + l_amort_sched_tbl(l_counter).interest;
                l_amort_sched_tbl(l_counter).principal_balance := 0;
              END IF;
            END IF;
            i := i + 1;
          END LOOP;

        END IF;
      END IF;

    END IF;

    x_amort_sched_tbl := l_amort_sched_tbl;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data);

  EXCEPTION

    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OTHERS THEN

      IF amort_sched_dtl_csr%ISOPEN THEN
        CLOSE amort_sched_dtl_csr;
      END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OTHERS',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

  END load_ln_cc_strm_summ;

  PROCEDURE check_payment_schedule
                 (p_api_version       IN  NUMBER,
                  p_init_msg_list     IN  VARCHAR2,
                  x_return_status     OUT NOCOPY VARCHAR2,
                  x_msg_count         OUT NOCOPY NUMBER,
                  x_msg_data          OUT NOCOPY VARCHAR2,
                  p_chr_id            IN  NUMBER,
                  x_schedule_match_yn OUT NOCOPY VARCHAR2) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'CHECK_PAYMENT_SCHEDULE';
    l_api_version     CONSTANT NUMBER     := 1.0;

    TYPE l_payment_details_rec IS RECORD (
      start_date         DATE         := NULL,
      number_of_periods  NUMBER       := NULL,
      stub_days          NUMBER       := NULL,
      stub_amount        NUMBER       := NULL,
      advance_or_arrears VARCHAR2(1)  := NULL
    );

    TYPE l_payment_details_tbl IS TABLE OF l_payment_details_rec INDEX BY BINARY_INTEGER;

    TYPE l_tbl_rec IS RECORD (
      kle_id             NUMBER,
      l_payment_details l_payment_details_tbl
    );

    TYPE l_tbl_type IS TABLE OF l_tbl_rec INDEX BY BINARY_INTEGER;

    l_pmnt_tab l_tbl_type;
    l_pmnt_tab_counter NUMBER;
    l_payment_details_counter NUMBER;

    CURSOR l_payment_lines_csr IS
    SELECT
    rgpb.cle_id kle_id,
    rulb2.rule_information2 start_date,
    rulb2.rule_information3 level_periods,
    rulb2.rule_information7 stub_days,
    rulb2.rule_information8 stub_amount,
    rulb2.rule_information10 arrear_yn
    FROM   okc_k_lines_b     cleb,
           okc_rule_groups_b rgpb,
           okc_rules_b       rulb,
           okc_rules_b       rulb2,
           okl_strm_type_b   styb,
           okc_statuses_b    sts
    WHERE  rgpb.chr_id     IS NULL
    AND    rgpb.dnz_chr_id = cleb.dnz_chr_id
    AND    rgpb.cle_id     = cleb.id
    AND    cleb.dnz_chr_id = p_chr_id
    AND    sts.code        = cleb.sts_code
    AND    sts.ste_code    <> 'CANCELLED'
    AND    rgpb.rgd_code   = 'LALEVL'
    AND    rulb.rgp_id     = rgpb.id
    AND    rulb.rule_information_category  = 'LASLH'
    AND    TO_CHAR(styb.id)                = rulb.object1_id1
    AND    rulb2.object2_id1                = TO_CHAR(rulb.id)
    AND    rulb2.rgp_id                    = rgpb.id
    AND    rulb2.rule_information_category = 'LASLL'
    AND    styb.stream_type_purpose IN ('RENT','PRINCIPAL_PAYMENT')
    ORDER BY kle_id, start_date, level_periods;

    TYPE payment_rec_type IS RECORD (
      kle_id             NUMBER,
      start_date         VARCHAR2(450),
      number_of_periods  VARCHAR2(450),
      stub_days          VARCHAR2(450),
      stub_amount        VARCHAR2(450),
      advance_or_arrears VARCHAR2(450)
    );

   TYPE payment_table IS TABLE OF payment_rec_type INDEX BY BINARY_INTEGER;

   l_payment_table payment_table;
   l_payment_table2 payment_table;
   l_payment_table_counter NUMBER;
   l_limit NUMBER := 10000;
   l_prev_kle_id NUMBER;
   l_num_schedules NUMBER;
   schedule_mismatch EXCEPTION;
   l_start_date DATE;
   l_number_of_periods NUMBER;
   l_stub_days NUMBER;
   l_advance_or_arrears VARCHAR2(30);

  PROCEDURE print_tab(p_table IN l_tbl_type) IS
  BEGIN
   NULL;
   FOR i IN p_table.first..p_table.last
   LOOP
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i='||i || '->kle_id='|| p_table(i).kle_id);
    END IF;
    FOR j IN p_table(i).l_payment_details.first..p_table(i).l_payment_details.last
    LOOP
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-->j=' || j );
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'------>start_date=' || p_table(i).l_payment_details(j).start_date);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'------>number_of_periods=' || p_table(i).l_payment_details(j).number_of_periods);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'------>stub_days=' || p_table(i).l_payment_details(j).stub_days);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'------>stub_amount=' || p_table(i).l_payment_details(j).stub_amount);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'------>advance_or_arrears=' || p_table(i).l_payment_details(j).advance_or_arrears);
      END IF;
    END LOOP;
   END LOOP;
  END;

  PROCEDURE print_payment_orig_table(p_table IN payment_table) IS
  BEGIN
   NULL;
   IF (p_table.COUNT > 0) THEN
   FOR i IN p_table.first..p_table.last
   LOOP
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i='||i || '->kle_id='|| p_table(i).kle_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'start_date=' || p_table(i).start_date);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'number_of_periods=' || p_table(i).number_of_periods);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'stub_days=' || p_table(i).stub_days);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'stub_amount=' || p_table(i).stub_amount);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'advance_or_arrears=' || p_table(i).advance_or_arrears);
    END IF;
   END LOOP;
   END IF;
  END;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_schedule_match_yn := 'N';

    l_payment_table_counter := 1;
    OPEN l_payment_lines_csr;
    LOOP
      FETCH l_payment_lines_csr BULK COLLECT INTO l_payment_table2 LIMIT l_limit;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_payment_table2.count=' || l_payment_table2.COUNT);
      END IF;
      IF (l_payment_table2.COUNT > 0) THEN
        FOR i IN l_payment_table2.FIRST..l_payment_table2.LAST
        LOOP
          l_payment_table(l_payment_table_counter) := l_payment_table2(i);
          l_payment_table_counter := l_payment_table_counter + 1;
        END LOOP;
      ELSE
        EXIT;
      END IF;
    END LOOP;
    CLOSE l_payment_lines_csr;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_payment_table_counter=' || l_payment_table_counter);
      print_payment_orig_table(l_payment_table);
    END IF;

    IF (l_payment_table.COUNT > 0) THEN
      -- Prepare formatted table from l_payment_table
      l_pmnt_tab_counter := 0;
      l_payment_details_counter := 1;
      l_prev_kle_id := 0;

      FOR i IN l_payment_table.first..l_payment_table.last
      LOOP
        IF (l_prev_kle_id <> l_payment_table(i).kle_id) THEN
          l_pmnt_tab_counter := l_pmnt_tab_counter + 1;
          l_payment_details_counter := 1;
          l_pmnt_tab(l_pmnt_tab_counter).kle_id := l_payment_table(i).kle_id;

          l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).start_date := Fnd_Date.canonical_to_date(l_payment_table(i).start_date);
          l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).number_of_periods := l_payment_table(i).number_of_periods;
          l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).stub_days := l_payment_table(i).stub_days;
          l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).stub_amount := l_payment_table(i).stub_amount;
          l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).advance_or_arrears := l_payment_table(i).advance_or_arrears;

          l_prev_kle_id := l_payment_table(i).kle_id;
          l_payment_details_counter := l_payment_details_counter + 1;
       ELSE
          l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).start_date := Fnd_Date.canonical_to_date(l_payment_table(i).start_date);
          l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).number_of_periods := l_payment_table(i).number_of_periods;
          l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).stub_days := l_payment_table(i).stub_days;
          l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).stub_amount := l_payment_table(i).stub_amount;
          l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).advance_or_arrears := l_payment_table(i).advance_or_arrears;

          l_prev_kle_id := l_payment_table(i).kle_id;
          l_payment_details_counter := l_payment_details_counter + 1;
        END IF;
      END LOOP;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Now Printing l_pmnt_tab...');
          print_tab(l_pmnt_tab);
      END IF;

      -- Check only if there are at least two asset lines
      IF (l_pmnt_tab.COUNT > 1) THEN

        l_num_schedules := l_pmnt_tab(1).l_payment_details.COUNT;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_num_schedules=' || l_num_schedules);
        END IF;
        FOR i IN 2..l_pmnt_tab.LAST
        LOOP
          IF (l_num_schedules <> l_pmnt_tab(i).l_payment_details.COUNT) THEN
            RAISE schedule_mismatch;
          END IF;
        END LOOP;


        FOR j IN l_pmnt_tab(1).l_payment_details.first..l_pmnt_tab(1).l_payment_details.last
        LOOP
          l_start_date := l_pmnt_tab(1).l_payment_details(j).start_date;
          l_number_of_periods := l_pmnt_tab(1).l_payment_details(j).number_of_periods;
          l_stub_days := l_pmnt_tab(1).l_payment_details(j).stub_days;
          l_advance_or_arrears := l_pmnt_tab(1).l_payment_details(j).advance_or_arrears;
          FOR i IN 2..l_pmnt_tab.LAST
          LOOP
            IF (Fnd_Date.canonical_to_date(l_start_date) <> Fnd_Date.canonical_to_date(l_pmnt_tab(i).l_payment_details(j).start_date)) OR
             (NVL(l_number_of_periods,0) <> NVL(l_pmnt_tab(i).l_payment_details(j).number_of_periods,0)) OR
             (NVL(l_stub_days,0) <> NVL(l_pmnt_tab(i).l_payment_details(j).stub_days,0)) OR
             (NVL(l_advance_or_arrears,'N') <> NVL(l_pmnt_tab(i).l_payment_details(j).advance_or_arrears,'N')) THEN

              RAISE schedule_mismatch;
            END IF;
          END LOOP; -- i
        END LOOP; -- j
      END IF;

      x_schedule_match_yn := 'Y';
    END IF;

  EXCEPTION
    WHEN schedule_mismatch THEN
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      x_schedule_match_yn := 'N';

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_schedule_match_yn := 'N';

  END check_payment_schedule;

  PROCEDURE load_loan_amort_schedule(
              p_api_version           IN  NUMBER,
              p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
              x_return_status         OUT NOCOPY VARCHAR2,
              x_msg_count             OUT NOCOPY NUMBER,
              x_msg_data              OUT NOCOPY VARCHAR2,
              p_chr_id                IN  NUMBER,
              p_report_type           IN  VARCHAR2,
              x_proj_interest_rate    OUT NOCOPY NUMBER,
              x_amort_sched_tbl       OUT NOCOPY amort_sched_tbl_type) IS

    l_api_name            CONSTANT    VARCHAR2(30) := 'LOAD_LOAN_AMORT_SCHEDULE';
    l_api_version         CONSTANT    NUMBER       := 1.0;

    CURSOR chr_product_csr(p_chr_id IN NUMBER) IS
    SELECT ppm_rrm.quality_val rev_rec_method,
           ppm_icb.quality_val int_calc_basis,
           khr.implicit_interest_rate,
           chrb.start_date
    FROM okl_k_headers khr,
         okl_prod_qlty_val_uv ppm_rrm,
         okl_prod_qlty_val_uv ppm_icb,
         okc_k_headers_b chrb
    WHERE chrb.id = p_chr_id
    AND   khr.id = chrb.id
    AND   ppm_rrm.pdt_id = khr.pdt_id
    AND   ppm_rrm.quality_name = 'REVENUE_RECOGNITION_METHOD'
    AND   ppm_icb.pdt_id = khr.pdt_id
    AND   ppm_icb.quality_name = 'INTEREST_CALCULATION_BASIS';

    chr_product_rec chr_product_csr%ROWTYPE;

    x_last_billing_date    DATE;
    l_schedule_match_yn    VARCHAR2(1);
    l_principal_balance    NUMBER;
    l_proj_interest_rate   NUMBER;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Summary Report: Check whether all assets have same Payment Schedule
    IF p_report_type = G_REPORT_TYPE_SUMMARY THEN

      check_payment_schedule(
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_chr_id              => p_chr_id,
        x_schedule_match_yn   => l_schedule_match_yn);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    IF (p_report_type = G_REPORT_TYPE_DETAIL OR
        p_report_type = G_REPORT_TYPE_SUMMARY AND l_schedule_match_yn = 'Y') THEN

      OPEN chr_product_csr(p_chr_id => p_chr_id);
      FETCH chr_product_csr INTO chr_product_rec;
      CLOSE chr_product_csr;

      IF chr_product_rec.int_calc_basis IN (G_ICB_FIXED,G_ICB_REAMORT) AND chr_product_rec.rev_rec_method = G_RRM_STREAMS THEN
        IF p_report_type = G_REPORT_TYPE_SUMMARY THEN
        -- Fetch Past and Projected Schedule - Summary
            load_ln_streams_summ(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_chr_id              => p_chr_id,
              x_amort_sched_tbl     => x_amort_sched_tbl);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;


        ELSIF p_report_type = G_REPORT_TYPE_DETAIL THEN
            -- Fetch Past and Projected Schedule - Detail
            load_ln_streams_dtl(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_chr_id              => p_chr_id,
              x_amort_sched_tbl     => x_amort_sched_tbl);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;


        END IF;
        x_proj_interest_rate := chr_product_rec.implicit_interest_rate;

      ELSIF chr_product_rec.rev_rec_method = G_RRM_ACTUAL THEN

        IF p_report_type = G_REPORT_TYPE_SUMMARY THEN

          -- Fetch Past and Projected Schedule - Summary
          load_ln_actual_summ(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_chr_id              => p_chr_id,
              x_proj_interest_rate  => l_proj_interest_rate,
              x_amort_sched_tbl     => x_amort_sched_tbl);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        ELSIF p_report_type = G_REPORT_TYPE_DETAIL THEN

          -- Fetch Past and Projected Schedule - Detail
          load_ln_actual_dtl(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_chr_id              => p_chr_id,
              x_proj_interest_rate  => l_proj_interest_rate,
              x_amort_sched_tbl     => x_amort_sched_tbl);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF;
        x_proj_interest_rate :=l_proj_interest_rate;

      ELSIF chr_product_rec.int_calc_basis = G_ICB_FLOAT AND chr_product_rec.rev_rec_method = G_RRM_ESTIMATED_AND_BILLED THEN

        IF p_report_type = G_REPORT_TYPE_SUMMARY THEN

          -- Fetch Past and Projected Schedule - Summary
          load_ln_float_eb_summ(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_chr_id              => p_chr_id,
              x_amort_sched_tbl     => x_amort_sched_tbl);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        ELSIF p_report_type = G_REPORT_TYPE_DETAIL THEN

          -- Fetch Past and Projected Schedule - Detail
          load_ln_float_eb_dtl(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_chr_id              => p_chr_id,
              x_amort_sched_tbl     => x_amort_sched_tbl);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF;
        x_proj_interest_rate := chr_product_rec.implicit_interest_rate;

      ELSIF chr_product_rec.int_calc_basis = G_ICB_CATCHUP_CLEANUP AND chr_product_rec.rev_rec_method = G_RRM_STREAMS THEN

        IF p_report_type = G_REPORT_TYPE_SUMMARY THEN

          -- Fetch Past and Projected Schedule - Summary
          load_ln_cc_strm_summ(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_chr_id              => p_chr_id,
              x_amort_sched_tbl     => x_amort_sched_tbl);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        ELSIF p_report_type = G_REPORT_TYPE_DETAIL THEN

          -- Fetch Past and Projected Schedule - Detail
          load_ln_cc_strm_dtl(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_chr_id              => p_chr_id,
              x_amort_sched_tbl     => x_amort_sched_tbl);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF;
        x_proj_interest_rate := chr_product_rec.implicit_interest_rate;

      END IF;

      --Bug# 6831074: Assign contract start date to the opening principal
      --              balance row in both summary and detail schedule
      IF (x_amort_sched_tbl.COUNT > 0) THEN
        IF (p_report_type = G_REPORT_TYPE_DETAIL) THEN

          x_amort_sched_tbl(x_amort_sched_tbl.FIRST).start_date := chr_product_rec.start_date;

        ELSIF (p_report_type = G_REPORT_TYPE_SUMMARY) THEN

          x_amort_sched_tbl(x_amort_sched_tbl.FIRST).start_date := chr_product_rec.start_date;
          x_amort_sched_tbl(x_amort_sched_tbl.FIRST).end_date   := chr_product_rec.start_date;

        END IF;
      END IF;

    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data);

  EXCEPTION

    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OTHERS THEN

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OTHERS',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

  END load_loan_amort_schedule;

END OKL_LOAN_AMORT_SCHEDULE_PVT;

/
