--------------------------------------------------------
--  DDL for Package Body OKL_EXPENSE_STREAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EXPENSE_STREAMS_PVT" AS
/* $Header: OKLRSGEB.pls 120.14.12010000.2 2009/06/02 10:49:41 racheruv ship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE generate_idc
  ---------------------------------------------------------------------------
  PROCEDURE generate_idc( p_khr_id         IN         NUMBER,
                          p_purpose_code   IN         VARCHAR2,
                          p_currency_code  IN         VARCHAR2,
                          p_start_date     IN         DATE,
                          p_end_date       IN         DATE,
                          p_deal_type      IN         VARCHAR2,
                          x_return_status  OUT NOCOPY VARCHAR2) IS

    l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'generate_idc';

    CURSOR c_idc_exp IS
      SELECT kle.id,
             kle.initial_direct_cost
      FROM   okl_k_lines kle,
             okc_k_lines_b cle,
             okc_line_styles_b lse
      WHERE  cle.chr_id = p_khr_id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE')
        AND  cle.lse_id = lse.id
        AND  lse.lty_code = 'FEE'
	AND  kle.fee_type <> 'FINANCED'
	AND  kle.fee_type <> 'ROLLOVER'
        AND  cle.id = kle.id;

    CURSOR c_k_income (p_sty_name VARCHAR2) IS
      SELECT sel.amount income_amount,
             sel.stream_element_date income_date
      FROM   okl_strm_elements sel,
             okl_streams stm,
             okl_strm_type_b sty,
             okl_strm_type_tl styt
      WHERE  stm.khr_id = p_khr_id
        AND  stm.say_code = 'WORK'
        AND  DECODE(stm.purpose_code, NULL, '-99', 'REPORT') = p_purpose_code
        AND  stm.id = sel.stm_id
        AND  stm.sty_id = sty.id
        AND  sty.version = '1.0'
        AND  sty.id = styt.id
        AND  styt.language = 'US'
        AND  styt.name = p_sty_name
      ORDER BY sel.stream_element_date;

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

    l_amortized_exp_id       NUMBER;
    l_sty_name               VARCHAR2(150);
    l_name                   VARCHAR2(150);
    l_total_rent_income      NUMBER            := 0;
    i                        BINARY_INTEGER    := 0;

    lx_return_status         VARCHAR2(1);
    lx_msg_data              VARCHAR2(4000);
    lx_msg_count             NUMBER;


    TYPE inc_strms_rec_type is RECORD
    (  amount NUMBER,
       ele_date DATE
    );

    TYPE inc_strms_tbl_type is TABLE OF
             inc_strms_rec_type INDEX BY BINARY_INTEGER;

    inc_strms_tbl inc_strms_tbl_type;

    lastDate DATE := NULL;
    l_sty_id NUMBER;

    Cursor c_rollover_pmnts IS
    Select distinct nvl(slh.object1_id1, -1) styId
    From   OKC_RULE_GROUPS_B rgp,
           OKC_RULES_B sll,
           okc_rules_b slh,
	   okl_strm_type_b sty
    Where  slh.rgp_id = rgp.id
       and rgp.RGD_CODE = 'LALEVL'
       and sll.RULE_INFORMATION_CATEGORY = 'LASLL'
       and slh.RULE_INFORMATION_CATEGORY = 'LASLH'
       AND TO_CHAR(slh.id) = sll.object2_id1
       and slh.object1_id1 = sty.id
       and sty.stream_type_purpose = 'RENT'
       and rgp.dnz_chr_id = p_khr_id;

    r_rollover_pmnts c_rollover_pmnts%ROWTYPE;

    l_primary_sty_id NUMBER;

    cursor fee_strm_type_csr ( kleid NUMBER ) is
    select tl.name strm_name,
           sty.capitalize_yn capitalize_yn,
           kle.id   line_id,
           sty.id   styp_id,
           sty.stream_type_class stream_type_class
    from okl_strm_type_tl tl,
         okl_strm_type_v sty,
         okc_k_items cim,
         okl_k_lines_full_v kle,
         okc_line_styles_b ls
    where tl.id = sty.id
         and tl.language = 'US'
         and cim.cle_id = kle.id
         and ls.id = kle.lse_id
         and ls.lty_code = 'FEE'
         and cim.object1_id1 = sty.id
         and cim.object1_id2 = '#'
         and kle.id = kleid;

    fee_strm_type_rec fee_strm_type_csr%ROWTYPE;


  BEGIN

    OPEN c_rollover_pmnts;
    FETCH c_rollover_pmnts INTO r_rollover_pmnts;
    CLOSE c_rollover_pmnts;

    l_primary_sty_id := r_rollover_pmnts.styId;

    IF p_deal_type = 'LEASEOP' THEN
      --l_sty_name := 'RENTAL ACCRUAL';
      OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
					 p_deal_type             => p_deal_type,
					 p_primary_sty_id        => l_primary_sty_id,
                                         p_dependent_sty_purpose => 'RENT_ACCRUAL',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => l_sty_name);

    ELSIF p_deal_type IN ('LEASEDF', 'LEASEST') THEN
      --l_sty_name := 'PRE-TAX INCOME';
      OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
					 p_deal_type             => p_deal_type,
					 p_primary_sty_id        => l_primary_sty_id,
                                         p_dependent_sty_purpose => 'LEASE_INCOME',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => l_sty_name);

    ELSIF p_deal_type IN ('LOAN', 'LOAN-REVOLVING') THEN
      --l_sty_name := 'PRE-TAX INCOME';
      OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
					 p_deal_type             => p_deal_type,
					 p_primary_sty_id        => l_primary_sty_id,
                                         p_dependent_sty_purpose => 'INTEREST_INCOME',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => l_sty_name);

    END IF;

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

    i := 0;
    FOR l_k_income IN c_k_income(p_sty_name => l_sty_name) LOOP
      l_total_rent_income := l_total_rent_income + l_k_income.income_amount;
      If ( trunc(l_k_income.income_date) =
             trunc(nvl(lastDate, l_k_income.income_date+1) )) Then
          inc_strms_tbl(i).amount := inc_strms_tbl(i).amount + l_k_income.income_amount;
      Else
          i := i + 1;
          inc_strms_tbl(i).amount := l_k_income.income_amount;
          inc_strms_tbl(i).ele_date := l_K_income.income_date;
          lastDate := l_K_income.income_date;
      End If;
    END LOOP;

    FOR l_idc_exp IN c_idc_exp LOOP

         l_amortized_exp_id := NULL;  -- bug 6156337

      IF NVL(l_idc_exp.initial_direct_cost, 0) > 0 THEN

      IF l_amortized_exp_id IS NULL THEN

/*
        okl_stream_generator_pvt.get_sty_details (p_sty_name      => 'AMORTIZED EXPENSE',
                                                  x_sty_id        => l_amortized_exp_id,
                                                  x_sty_name      => l_name,
                                                  x_return_status => lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

*/

        OPEN fee_strm_type_csr( l_idc_exp.id );
	FETCH fee_strm_type_csr INTO fee_strm_type_rec;
	CLOSE fee_strm_type_csr;
	l_primary_sty_id := fee_strm_type_rec.styp_id;

        OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
					 p_deal_type             => p_deal_type,
					 p_primary_sty_id        => l_primary_sty_id,
                                         p_dependent_sty_purpose => 'AMORTIZED_FEE_EXPENSE',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_amortized_exp_id,
                                         x_dependent_sty_name    => l_name);


        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

    If l_amortized_exp_id IS NOT NULL then

      SELECT okl_sif_seq.nextval
      INTO l_stmv_rec.transaction_number
      FROM DUAL;

      l_stmv_rec.khr_id              :=  p_khr_id;
      l_stmv_rec.kle_id              :=  l_idc_exp.id;
      l_stmv_rec.sty_id              :=  l_amortized_exp_id;
      l_stmv_rec.sgn_code            :=  'MANL';
      l_stmv_rec.say_code            :=  'WORK';
      l_stmv_rec.active_yn           :=  'N';
      l_stmv_rec.date_working        :=  SYSDATE;

      IF p_purpose_code = 'REPORT' THEN
        l_stmv_rec.purpose_code := 'REPORT';
      END IF;

      FOR i IN 1..inc_strms_tbl.count
      LOOP


        l_selv_tbl(i).stream_element_date := inc_strms_tbl(i).ele_date;
        l_selv_tbl(i).se_line_number      := i;

        l_selv_tbl(i).amount :=
             (inc_strms_tbl(i).amount/l_total_rent_income)*l_idc_exp.initial_direct_cost;

      END LOOP;


      lx_return_status := Okl_Streams_Util.round_streams_amount(
	                                p_api_version   => g_api_version,
                                        p_init_msg_list => G_FALSE,
                                        x_msg_count     => lx_msg_count,
                                        x_msg_data      => lx_msg_data,
                                        p_chr_id        => p_khr_id,
                                        p_selv_tbl      => l_selv_tbl,
                                        x_selv_tbl      => lx_selv_tbl);

       IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       l_selv_tbl.DELETE;
       l_selv_tbl := lx_selv_tbl;


      okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                     p_init_msg_list   =>   G_FALSE,
                                     x_return_status   =>   lx_return_status,
                                     x_msg_count       =>   lx_msg_count,
                                     x_msg_data        =>   lx_msg_data,
                                     p_stmv_rec        =>   l_stmv_rec,
                                     p_selv_tbl        =>   l_selv_tbl,
                                     x_stmv_rec        =>   lx_stmv_rec,
                                     x_selv_tbl        =>   lx_selv_tbl);

      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_selv_tbl.DELETE;

    End If;

      i := 0;

      END IF;

    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END generate_idc;


  ---------------------------------------------------------------------------
  -- PROCEDURE generate_rec_exp
  ---------------------------------------------------------------------------
  PROCEDURE generate_rec_exp( p_khr_id           IN         NUMBER,
			                  p_deal_type        IN         VARCHAR2,
                              p_purpose_code     IN         VARCHAR2,
                              p_currency_code    IN         VARCHAR2,
                              x_return_status    OUT NOCOPY VARCHAR2) IS

    l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'generate_rec_exp';


    l_primary_sty_id NUMBER;

    cursor fee_strm_type_csr ( kleid NUMBER ) is
    select tl.name strm_name,
           sty.capitalize_yn capitalize_yn,
           kle.id   line_id,
           sty.id   styp_id,
           sty.stream_type_class stream_type_class
    from okl_strm_type_tl tl,
         okl_strm_type_v sty,
         okc_k_items cim,
         okl_k_lines_full_v kle,
         okc_line_styles_b ls
    where tl.id = sty.id
         and tl.language = 'US'
         and cim.cle_id = kle.id
         and ls.id = kle.lse_id
         and ls.lty_code = 'FEE'
         and cim.object1_id1 = sty.id
         and cim.object1_id2 = '#'
         and kle.id = kleid;

    fee_strm_type_rec fee_strm_type_csr%ROWTYPE;

    -- gboomina added for Bug 6763287 - Start
    -- Modified c_rec_exp cursor to select NEW sts_code streams
    -- for Investor Agreement
    CURSOR c_rec_exp IS
      SELECT TO_NUMBER(rul.rule_information1) periods,
             TO_NUMBER(rul.rule_information2) amount,
             DECODE(rul2.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12, NULL) mpp,
             rgp.cle_id,
             cle.start_date,
             cle.sts_code
      FROM   okc_rules_b rul,
             okc_rules_b rul2,
             okc_rule_groups_b rgp,
             okc_k_lines_b cle,
             okl_k_lines kle
      WHERE  rgp.dnz_chr_id = p_khr_id
        AND  rgp.cle_id = cle.id
       	AND  kle.id = cle.id
        AND  cle.sts_code IN ('NEW', 'INCOMPLETE', 'PASSED', 'COMPLETE')
       	AND  kle.fee_type <> 'FINANCED'
       	AND  kle.fee_type <> 'ABSORBED'
       	AND  kle.fee_type <> 'ROLLOVER'
        AND  rgp.rgd_code = 'LAFEXP'
        AND  rgp.id = rul.rgp_id
        AND  rgp.id = rul2.rgp_id
        AND  rul.rule_information_category = 'LAFEXP'
        AND  rul2.rule_information_category = 'LAFREQ';
    -- gboomina added for Bug 6763287 - End

    CURSOR c_fee_idc (p_kle_id NUMBER) IS
      SELECT  NVL(initial_direct_cost, 0)
      FROM    okl_k_lines
      WHERE   id = p_kle_id;

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

    l_end_date               DATE;
    l_periodic_exp_id        NUMBER;
    l_sty_name               VARCHAR2(150);
    l_total_days             NUMBER;
    l_daily_exp              NUMBER;
    l_start_date             DATE;
    l_month_end              DATE;
    l_rec_exp_bal            NUMBER;
    l_days                   NUMBER;
    l_non_idc_exp          NUMBER;
    l_idc_amount             NUMBER;
    l_idc_fraction           NUMBER;

    i                        BINARY_INTEGER    := 0;

    lx_return_status         VARCHAR2(1);
    lx_msg_data              VARCHAR2(4000);
    lx_msg_count             NUMBER;

    Cursor day_conv_csr( khrId NUMBER) IS
    select DAYS_IN_A_YEAR_CODE,
           DAYS_IN_A_MONTH_CODE
    from  OKL_K_RATE_PARAMS
    where khr_id = khrId;

    day_conv_rec day_conv_csr%ROWTYPE;

    l_day_convention_month VARCHAR2(30);
    l_day_convention_year VARCHAR2(30);

    -- gboomina added for Bug 6763287 - Start
    CURSOR c_hdr IS
    SELECT to_char(pdt.id)  pid,
           chr.scs_code,
		   pdt.reporting_pdt_id -- R12.1.2
    FROM okc_k_headers_v chr,
         okl_k_headers khr,
         okl_products_v pdt
    WHERE khr.id = chr.id
      AND chr.id = p_khr_id
      AND khr.pdt_id = pdt.id(+);

    l_pdt_id okl_products.id%type;
    l_scs_code okc_k_headers_all_b.scs_code%type;
	l_rep_pdt_id okl_products.reporting_pdt_id%TYPE; -- R12.1.2
    -- gboomina added for Bug 6763287 - End

  BEGIN

    -- gboomina added for Bug 6763287 - Start
    OPEN c_hdr;
    FETCH c_hdr INTO l_pdt_id, l_scs_code, l_rep_pdt_id;
    CLOSE c_hdr;
    -- gboomina added for Bug 6763287 - End

    OPEN day_conv_csr(p_khr_id);
    FETCH day_conv_csr INTO day_conv_rec;
    CLOSE day_conv_csr;

    l_day_convention_month := day_conv_rec.DAYS_IN_A_MONTH_CODE;
    l_day_convention_year := day_conv_rec.DAYS_IN_A_YEAR_CODE;

    FOR l_rec_exp IN c_rec_exp LOOP

        l_periodic_exp_id := NULL;  -- bug 6156337

      -- gboomina added for Bug 6763287 - Start
      -- Restricting the below processing for fee lines in NEW status for Contracts.
      -- Created expense accrual streams only for Contract lines in status
      -- (PASSED, COMPLETE) and Investor Agreement lines in status NEW.
      IF ( (l_rec_exp.sts_code IN ('NEW', 'INCOMPLETE') AND l_scs_code = 'INVESTOR') OR
           (l_rec_exp.sts_code NOT IN ('NEW', 'INCOMPLETE') AND l_scs_code <> 'INVESTOR') ) THEN
      -- gboomina added for Bug 6763287 - End

        -- LLA UI does not allow deletion of Recurring Expense definitions
        -- The only way to know whether this is a valid definition is to check all 3 attributes
        IF (l_rec_exp.periods IS NOT NULL) AND
           (l_rec_exp.amount IS NOT NULL) AND
           (l_rec_exp.mpp IS NOT NULL) AND
           l_rec_exp.amount <> 0 THEN

          OPEN c_fee_idc(p_kle_id => l_rec_exp.cle_id);
          FETCH c_fee_idc INTO l_idc_amount;
          CLOSE c_fee_idc;

          l_idc_fraction   :=  l_idc_amount / (l_rec_exp.amount*l_rec_exp.periods);
          l_non_idc_exp    :=  (l_rec_exp.amount*l_rec_exp.periods)*(1-l_idc_fraction);
          l_end_date       :=  ADD_MONTHS(l_rec_exp.start_date, l_rec_exp.periods*l_rec_exp.mpp) - 1;

          l_total_days := okl_stream_generator_pvt.get_day_count(p_start_date    =>  l_rec_exp.start_date,
                                                                 p_end_date      =>  l_end_date,
                                                                 p_arrears       =>  'Y',
                                                                 x_return_status =>  lx_return_status);

          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          IF l_periodic_exp_id IS NULL THEN

            OPEN fee_strm_type_csr( l_rec_exp.cle_id );
     FETCH fee_strm_type_csr INTO fee_strm_type_rec;
     CLOSE fee_strm_type_csr;

     l_primary_sty_id := fee_strm_type_rec.styp_id;

    -- gboomina added for Bug 6763287 - Start
     IF( l_scs_code = 'INVESTOR' ) THEN

	    if p_purpose_code = 'REPORT' then
           l_pdt_id := l_rep_pdt_id;
		end if;

        OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                p_khr_id                => p_khr_id,
                p_pdt_id                => l_pdt_id,
                p_dependent_sty_purpose => 'ACCRUED_FEE_EXPENSE',
                x_return_status         => x_return_status,
                x_dependent_sty_id      => l_periodic_exp_id,
                x_dependent_sty_name    => l_sty_name);
     ELSE
       OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                p_khr_id                => p_khr_id,
                p_deal_type             => p_deal_type,
                p_primary_sty_id        => l_primary_sty_id,
                p_dependent_sty_purpose => 'ACCRUED_FEE_EXPENSE', --bug# 4105286
                x_return_status         => lx_return_status,
                x_dependent_sty_id      => l_periodic_exp_id,
                x_dependent_sty_name    => l_sty_name);
     END IF;
    -- gboomina added for Bug 6763287 - End

     IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

  /*
            okl_stream_generator_pvt.get_sty_details (p_sty_name      => 'PERIODIC EXPENSE PAYABLE',
                                                      x_sty_id        => l_periodic_exp_id,
                                                      x_sty_name      => l_sty_name,
                                                      x_return_status => lx_return_status);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
     */

          END IF;

       If l_periodic_exp_id IS NOT NULL Then

          SELECT okl_sif_seq.nextval
          INTO l_stmv_rec.transaction_number
          FROM DUAL;

          l_stmv_rec.khr_id              :=  p_khr_id;
          l_stmv_rec.kle_id              :=  l_rec_exp.cle_id;
          l_stmv_rec.sty_id              :=  l_periodic_exp_id;
          l_stmv_rec.sgn_code            :=  'MANL';
          l_stmv_rec.say_code            :=  'WORK';
          l_stmv_rec.active_yn           :=  'N';
          l_stmv_rec.date_working        :=  SYSDATE;

          IF p_purpose_code = 'REPORT' THEN
            l_stmv_rec.purpose_code := 'REPORT';
          END IF;

          -- LOOP to get amortization of Recurring Expense

          l_daily_exp   :=  l_non_idc_exp / l_total_days;
          l_start_date  :=  l_rec_exp.start_date;
          l_month_end   :=  LAST_DAY(l_rec_exp.start_date);
          l_rec_exp_bal :=  l_non_idc_exp;

  --DBMS_OUTPUT.PUT_LINE('TOTAL FEE EXPENSE '||l_rec_exp.amount*l_rec_exp.periods||' NON-IDC PART '||l_non_idc_exp);
  --DBMS_OUTPUT.PUT_LINE('TOTAL DAYS '||l_total_days||' DAILY EXPENSE '||l_daily_exp);

          LOOP

            i := i + 1;

            IF TO_CHAR(l_month_end, 'MON') IN ('JAN', 'MAR', 'MAY', 'JUL', 'AUG', 'OCT', 'DEC') THEN
              l_selv_tbl(i).stream_element_date := l_month_end - 1;
            ELSE
              l_selv_tbl(i).stream_element_date := l_month_end;
            END IF;

            l_selv_tbl(i).se_line_number      :=  i;

            IF l_month_end >= l_end_date THEN

              l_selv_tbl(i).amount := okl_accounting_util.validate_amount(p_amount         =>  l_rec_exp_bal,
                                                                          p_currency_code  => p_currency_code);
              EXIT;

            ELSE

              l_days := okl_stream_generator_pvt.get_day_count(p_start_date    =>  l_start_date,
                                                               p_end_date      =>  l_month_end,
                                                               p_arrears       =>  'Y',
                                                               x_return_status =>  lx_return_status);

              IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              l_selv_tbl(i).amount := okl_accounting_util.validate_amount(p_amount         =>  l_days * l_daily_exp,
                                                                          p_currency_code  =>  p_currency_code);
            END IF;

            l_rec_exp_bal    := l_rec_exp_bal - l_selv_tbl(i).amount;
            l_start_date     := LAST_DAY(l_start_date) + 1;
            l_month_end      := ADD_MONTHS(l_month_end, 1);

          END LOOP;


        lx_return_status := Okl_Streams_Util.round_streams_amount(
                                   p_api_version   => g_api_version,
                                          p_init_msg_list => G_FALSE,
                                          x_msg_count     => lx_msg_count,
                                          x_msg_data      => lx_msg_data,
                                          p_chr_id        => p_khr_id,
                                          p_selv_tbl      => l_selv_tbl,
                                          x_selv_tbl      => lx_selv_tbl);

         IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_selv_tbl.DELETE;
         l_selv_tbl := lx_selv_tbl;

          okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                         p_init_msg_list   =>   G_FALSE,
                                         x_return_status   =>   lx_return_status,
                                         x_msg_count       =>   lx_msg_count,
                                         x_msg_data        =>   lx_msg_data,
                                         p_stmv_rec        =>   l_stmv_rec,
                                         p_selv_tbl        =>   l_selv_tbl,
                                         x_stmv_rec        =>   lx_stmv_rec,
                                         x_selv_tbl        =>   lx_selv_tbl);

          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          l_selv_tbl.DELETE;

         End If;

        END IF;

        i := 0;

      END IF;

    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END generate_rec_exp;


  ---------------------------------------------------------------------------
  -- PROCEDURE generate_expense_streams
  ---------------------------------------------------------------------------
  PROCEDURE generate_expense_streams( p_api_version      IN         NUMBER,
                                      p_init_msg_list    IN         VARCHAR2,
                                      p_khr_id           IN         NUMBER,
                                      p_purpose_code     IN         VARCHAR2,
                                      p_deal_type        IN         VARCHAR2,
                                      x_return_status    OUT NOCOPY VARCHAR2,
                                      x_msg_count        OUT NOCOPY NUMBER,
                                      x_msg_data         OUT NOCOPY VARCHAR2) IS

    l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'generate_expense_streams';

    CURSOR c_hdr IS
      SELECT chr.start_date,
             chr.end_date,
             chr.currency_code
      FROM   okc_k_headers_b chr
      WHERE  chr.id = p_khr_id;

    l_hdr                c_hdr%ROWTYPE;

    lx_return_status     VARCHAR2(1);

  BEGIN

    OPEN c_hdr;
    FETCH c_hdr INTO l_hdr;
    CLOSE c_hdr;

    generate_idc(p_khr_id        => p_khr_id,
                 p_purpose_code  => p_purpose_code,
                 p_currency_code => l_hdr.currency_code,
                 p_start_date    => l_hdr.start_date,
                 p_end_date      => l_hdr.end_date,
                 p_deal_type     => p_deal_type,
                 x_return_status => lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    generate_rec_exp(p_khr_id        => p_khr_id,
                     p_deal_type     => p_deal_type,
                     p_purpose_code  => p_purpose_code,
                     p_currency_code => l_hdr.currency_code,
                     x_return_status => lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END generate_expense_streams;


END OKL_EXPENSE_STREAMS_PVT;

/
