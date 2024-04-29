--------------------------------------------------------
--  DDL for Package Body OKL_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PRICING_PVT" AS
/* $Header: OKLRPIGB.pls 120.76.12010000.4 2009/12/17 10:44:23 rgooty ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

  -- Added for IRR Approximation
  G_TOT_CAP_AMT NUMBER := 0;
  G_TOT_INFLOW_AMT NUMBER := 0;
  G_TOT_RV_AMT NUMBER := 0;

  G_INVALID_VALUE           CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE ';
  G_LLA_NO_MATCHING_RECORD  CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_COL_NAME_TOKEN          CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_REQUIRED_VALUE              CONSTANT  VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;

  PROCEDURE  get_rate(p_khr_id          IN  NUMBER,
                      p_date            IN  DATE,
		      p_line_type       IN VARCHAR2,
                      x_rate            OUT NOCOPY NUMBER,
                      x_return_status   OUT NOCOPY VARCHAR2) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_rate';

   Cursor c_rate Is
   SELECT rte.amount rate,
          ele.stream_element_date ele_date,
          ele.comments
    FROM okc_k_headers_b chr_so,
         okc_line_styles_b lse_so,
         okc_k_lines_b cle_so,
         okl_strm_type_b sty,
	 okl_streams stm,
	 okl_strm_elements ele,
	 okl_strm_elements rte
    WHERE stm.khr_id = chr_so.id
	  AND chr_so.id = p_khr_id
	  AND stm.kle_id = cle_so.id
	  AND cle_so.dnz_chr_id = chr_so.id
	  AND cle_so.lse_id = lse_so.id
          AND lse_so.lty_code = p_line_type --'SO_PAYMENT'
	  AND stm.sty_id = sty.id
          AND sty.stream_type_purpose = 'RENT'
	  AND stm.say_code = 'WORK'
	  AND stm.purpose_code = 'FLOW'
	  AND ele.stm_id = stm.id
	  AND rte.stm_id = stm.id
	  AND rte.sel_id = ele.id
    ORDER BY ele.stream_element_date;

    r_rate c_rate%ROWTYPE;
    x_prev_rate NUMBER;

  Begin

    FOR r_rate in c_rate
    LOOP

        If ( p_date = r_rate.ele_date ) Then
	    x_rate := r_rate.rate;
	    return;
	ElsIf (( p_date < r_rate.ele_date ) AND (r_rate.comments = 'Y') ) THen -- arrears
	    x_rate := r_rate.rate;
	    return;
	ElsIf (( p_date < r_rate.ele_date ) AND (r_rate.comments = 'N') ) THen -- advance
	    x_rate := x_prev_rate;
	    return;
	Else
	    x_prev_rate := r_rate.rate;
	End If;

    END LOOP;

    x_rate := x_prev_rate; -- rate for the stubs.
    return;

  End get_rate;

  PROCEDURE  get_rate(p_khr_id          IN  NUMBER,
                      p_date            IN  DATE,
                      x_rate            OUT NOCOPY NUMBER,
                      x_return_status   OUT NOCOPY VARCHAR2) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_rate';

   Cursor c_rate Is
   SELECT rte.amount rate,
          ele.stream_element_date ele_date,
          ele.comments
    FROM okc_k_headers_b chr_so,
         okc_line_styles_b lse_so,
         okc_k_lines_b cle_so,
         okl_strm_type_b sty,
	 okl_streams stm,
	 okl_strm_elements ele,
	 okl_strm_elements rte
    WHERE stm.khr_id = chr_so.id
	  AND chr_so.id = p_khr_id
	  AND stm.kle_id = cle_so.id
	  AND cle_so.dnz_chr_id = chr_so.id
	  AND cle_so.lse_id = lse_so.id
          AND lse_so.lty_code = 'SO_PAYMENT'
	  AND stm.sty_id = sty.id
          AND sty.stream_type_purpose = 'RENT'
	  AND stm.say_code = 'WORK'
	  AND stm.purpose_code = 'FLOW'
	  AND ele.stm_id = stm.id
	  AND rte.stm_id = stm.id
	  AND rte.sel_id = ele.id
    ORDER BY ele.stream_element_date;

    r_rate c_rate%ROWTYPE;
    x_prev_rate NUMBER;

  Begin

    FOR r_rate in c_rate
    LOOP

        If ( p_date = r_rate.ele_date ) Then
	    x_rate := r_rate.rate;
	    return;
	ElsIf (( p_date < r_rate.ele_date ) AND (r_rate.comments = 'Y') ) THen -- arrears
	    x_rate := r_rate.rate;
	    return;
	ElsIf (( p_date < r_rate.ele_date ) AND (r_rate.comments = 'N') ) THen -- advance
	    x_rate := x_prev_rate;
	    return;
	Else
	    x_prev_rate := r_rate.rate;
	End If;

    END LOOP;

    x_rate := x_prev_rate; -- rate for the stubs.
    return;

  End get_rate;


  ---------------------------------------------------------------------------
  -- PROCEDURE get_quote_amortization
  --
  -- Description
  -- Populates Stream Element arrays with loan specific streams
  ---------------------------------------------------------------------------
  -- bug 2992184. Added p_purpose_code parameter.
  PROCEDURE get_quote_amortization(p_khr_id              IN  NUMBER,
                                   p_kle_id              IN  NUMBER,
                                   p_investment          IN  NUMBER,
                                   p_residual_value      IN  NUMBER,
                                   p_start_date          IN  DATE,
                                   p_asset_start_date    IN  DATE,
                                   p_term_duration       IN  NUMBER,
                                   x_principal_tbl       OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_interest_tbl        OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_prin_bal_tbl        OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_termination_tbl     OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_pre_tax_inc_tbl     OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_interim_interest    OUT NOCOPY NUMBER,
                                   x_interim_days        OUT NOCOPY NUMBER,
                                   x_interim_dpp         OUT NOCOPY NUMBER,
                                   x_iir                 OUT NOCOPY NUMBER,
                                   x_booking_yield       OUT NOCOPY NUMBER,
                                   x_return_status       OUT NOCOPY VARCHAR2) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_quote_amortization';

    CURSOR c_rent_slls ( streamName VARCHAR2 ) IS
      SELECT FND_DATE.canonical_to_date(sll.rule_information2) start_date,
             TO_NUMBER(SLL.rule_information3) periods,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 120, 'S', 180, 'A', 360) dpp,
             DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) mpp,
             NVL(sll.rule_information10, 'N') arrears_yn,
             FND_NUMBER.canonical_to_number(sll.rule_information6) rent_amount
      FROM   okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp,
             okl_strm_type_b sty,
             okl_strm_type_tl styt
      WHERE  rgp.dnz_chr_id = p_khr_id
        AND  rgp.cle_id = p_kle_id
        AND  rgp.rgd_code= 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  TO_NUMBER(slh.object1_id1) = sty.id
        AND  sty.version = '1.0'
        AND  sty.id = styt.id
        AND STYT.LANGUAGE = USERENV('LANG')  -- Bug 4626837
        AND  styt.name = streamName
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
      ORDER BY fnd_date.canonical_to_date(sll.rule_information2);

    l_rent_sll  c_rent_slls%ROWTYPE;

    -- bug 2992184. Added where condition for multi-gaap reporting streams.
    CURSOR c_rent_flows ( streamName VARCHAR2 ) IS
      SELECT sel.id se_id,
             sel.amount se_amount,
             sel.stream_element_date se_date,
             sel.comments se_arrears,
             sel.sel_id se_sel_id
      FROM   okl_strm_elements sel,
             okl_streams stm,
             okl_strm_type_b sty,
             okl_strm_type_tl styt
      WHERE  stm.kle_id = p_kle_id
        AND  stm.say_code = 'CURR'
        AND  stm.purpose_code IS NULL
        AND  stm.sty_id = sty.id
        AND  sty.version = '1.0'
        AND  sty.id = styt.id
        AND STYT.LANGUAGE = USERENV('LANG')  -- Bug 4626837
        AND  styt.name =  streamName
        AND  stm.id = sel.stm_id
      ORDER BY sel.stream_element_date;

    Cursor c_stub IS
    Select sel.id
    from okl_streams stm,
         okl_strm_elements sel
    where stm.khr_id = p_khr_id
      and stm.say_code     =  'HIST'
      and stm.SGN_CODE     =  'MANL'
      and stm.active_yn    =  'N'
      and stm.purpose_code =  'STUBS'
      and stm.comments     =  'STUB STREAMS'
      and sel.stm_id = stm.id;
    -- get payment next date after stub
    CURSOR c_date_pay_stub(p_khr_id NUMBER,
                           p_kle_id NUMBER,
                           p_date date)
    IS
    SELECT TRUNC(FND_DATE.canonical_to_date(crl.rule_information2))
    FROM okc_rule_groups_b crg,
         okc_rules_b crl
    WHERE crl.rgp_id = crg.id
    AND crg.rgd_code = 'LALEVL'
    AND crl.rule_information_category = 'LASLL'
    AND crg.dnz_chr_id = p_khr_id
    AND crg.cle_id = p_kle_id
    AND TRUNC(FND_DATE.canonical_to_date(crl.rule_information2)) > TRUNC(p_date)
    AND crl.rule_information2 IS NOT NULL
    AND crl.rule_information6 IS NOT NULL
    ORDER BY FND_DATE.canonical_to_date(crl.rule_information2);

    l_stub_id NUMBER;

        TYPE loan_rec IS RECORD (
           se_amount NUMBER,
           se_date DATE,
           se_days NUMBER,
           se_stub VARCHAR2(1),
           se_arrears okl_strm_elements.comments%type);

    TYPE loan_tbl IS TABLE OF loan_rec INDEX BY BINARY_INTEGER;

    asset_rents        loan_tbl;
    loan_payment       loan_tbl;
    pricipal_payment   loan_tbl;
    interest_payment   loan_tbl;
    pre_tax_income     loan_tbl;
    termination_val    loan_tbl;

    l_iir_limit        NUMBER            := NVL(ABS(fnd_profile.value('OKL_PRE_TAX_IIR_LIMIT')), 1000)/100;

    l_start_date       DATE;
    l_sll_start_date   DATE;
    l_end_date         DATE;
    l_interim_days     NUMBER;
    l_interim_interest NUMBER;
    l_open_book        NUMBER;
    l_close_book       NUMBER;
    l_payment          NUMBER;
    l_interest         NUMBER;
    l_principal        NUMBER;
    l_se_date          DATE;
    l_termination_val  NUMBER;
    l_days             NUMBER;
    l_iir              NUMBER            := 0;
    l_bk_yield         NUMBER            := 0;

    l_rent_period_end  DATE;
    l_k_end_date       DATE              := (ADD_MONTHS(p_start_date, p_term_duration) - 1);
    l_total_periods    NUMBER            := 0;
    l_term_complete    VARCHAR2(1)       := 'N';

    l_increment        NUMBER            := 0.1;
    l_abs_incr         NUMBER;
    l_prev_incr_sign   NUMBER;
    l_crossed_zero     VARCHAR2(1)       := 'N';

    l_diff             NUMBER;
    l_prev_diff        NUMBER;
    l_prev_diff_sign   NUMBER;

    i                  BINARY_INTEGER    :=  0;
    j                  BINARY_INTEGER    :=  0;
    k                  BINARY_INTEGER    :=  0;
    m                  BINARY_INTEGER    :=  0;
    l                  BINARY_INTEGER    :=  0;

    lx_return_status   VARCHAR2(1);

    Cursor fee_type_csr IS
    Select nvl(fee_type, 'XYZ' ) fee_type
    from okl_k_lines
    where id = p_kle_id;

    fee_type_rec fee_type_csr%ROWTYPe;


    l_stream_name VARCHAR2(256);

    cursor fee_strm_type_csr is
    SELECT styt.name
      FROM   okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp,
             okl_strm_type_b sty,
             okl_strm_type_tl styt
      WHERE  rgp.dnz_chr_id = p_khr_id
        AND  rgp.cle_id = p_kle_id
        AND  rgp.rgd_code= 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  TO_NUMBER(slh.object1_id1) = sty.id
        AND  sty.version = '1.0'
        AND  sty.id = styt.id
        AND STYT.LANGUAGE = USERENV('LANG')  -- Bug 4626837
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
      ORDER BY fnd_date.canonical_to_date(sll.rule_information2);

    l_was_a_stub_payment VARCHAR2(1) := 'N';

    l_day_convention_month VARCHAR2(30);
    l_day_convention_year VARCHAR2(30);
    l_days_in_year NUMBER;
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'begin' );

    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' Investment ' || to_char( p_investment ));

    END IF;
    OPEN c_stub;
    FETCH c_stub INTO l_stub_id;
    CLOSE c_stub;

    OPEN fee_strm_type_csr;
    FETCH fee_strm_type_csr INTO l_stream_name;
    CLOSE fee_strm_type_csr;

    OPEN c_rent_slls( l_stream_name );
    FETCH c_rent_slls INTO l_rent_sll;
    CLOSE c_rent_slls;

    l_start_date  :=  l_rent_sll.start_date;
    -- Fetch the day convention ..
    OKL_PRICING_UTILS_PVT.get_day_convention(
      p_id              => p_khr_id,
      p_source          => 'ISG',
      x_days_in_month   => l_day_convention_month,
      x_days_in_year    => l_day_convention_year,
      x_return_status   => lx_return_status);
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
    END IF;
    IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'sll start date ' || l_start_date );
    END IF;
    FOR  l_rent_flow IN c_rent_flows( l_stream_name ) LOOP

      k := k + 1;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'rent flow start date ' || l_rent_flow.se_date );
    END IF;
      asset_rents(k).se_days    :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => l_start_date,
                                                  p_days_in_month => l_day_convention_month,
				                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => l_rent_flow.se_date,
                                                  p_arrears       => l_rent_flow.se_arrears,
                                                  x_return_status => lx_return_status);

      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      asset_rents(k).se_amount  :=  l_rent_flow.se_amount;
      asset_rents(k).se_date    :=  l_rent_flow.se_date;
      asset_rents(k).se_arrears :=  l_rent_flow.se_arrears;

      l_start_date  :=  l_rent_flow.se_date;

      IF l_rent_flow.se_arrears = 'Y' THEN
        l_start_date  :=  l_start_date + 1;
      END IF;

      If ( nvl(l_rent_flow.se_sel_id, -1) = l_stub_id ) Then
        asset_rents(k).se_stub := 'Y';
      End If;

    END LOOP;

    l_interim_days  :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_asset_start_date,
                                      p_end_date      => l_rent_sll.start_date,
                                                  p_days_in_month => l_day_convention_month,
				                  p_days_in_year => l_day_convention_year,
                                      p_arrears       => 'N',
                                      x_return_status => lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' asset rent count ' || to_char(asset_rents.COUNT));
    END IF;
    LOOP

      i :=  i + 1;

      l_interim_interest  :=  p_investment * l_interim_days * l_iir/360;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || i||' Implicit Rate '||l_iir||' Interim Interest '||l_interim_interest
                           ||' Interim Days = '||l_interim_days);

    END IF;
      l_open_book  :=  p_investment;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' Investment ' || to_char(l_open_book));

      END IF;
      FOR k IN 1..asset_rents.COUNT LOOP

        l_payment    :=  asset_rents(k).se_amount;
        l_interest   :=  l_open_book*asset_rents(k).se_days*l_iir/360;
        l_principal  :=  l_payment - l_interest;
        l_close_book :=  l_open_book - l_principal;
        l_open_book  :=  l_close_book;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '  '||TO_CHAR(asset_rents(k).se_date, 'DD-MON-YYYY')||'   DAYS '||asset_rents(k).se_DAYS
                              || '   LOAN PAYMENT '||l_payment|| '   INTEREST '||ROUND(l_interest, 3)
  			    || '   PRINCIPAL '||ROUND(l_principal, 3)||'   Next OB '||ROUND(l_open_book, 3));

    END IF;
      END LOOP;

      l_diff  :=  l_open_book;

      IF ROUND(l_diff, 4) = 0 THEN

        l_open_book  :=  p_investment;

        FOR k IN asset_rents.FIRST .. asset_rents.LAST LOOP

          l_payment    :=  asset_rents(k).se_amount;
          l_interest   :=  l_open_book*asset_rents(k).se_days*l_iir/360;
          l_principal  :=  l_payment - l_interest;
          l_close_book :=  l_open_book - l_principal;

          l_se_date    :=  asset_rents(k).se_date;

          x_principal_tbl(k).amount  :=  l_principal;
          x_interest_tbl(k).amount   :=  l_interest;
          x_prin_bal_tbl(k).amount   :=  l_close_book;

          x_principal_tbl(k).se_line_number  :=  k;
          x_interest_tbl(k).se_line_number   :=  k;
          x_prin_bal_tbl(k).se_line_number   :=  k;

          x_principal_tbl(k).stream_element_date  :=  l_se_date;
          x_interest_tbl(k).stream_element_date   :=  l_se_date;
          x_prin_bal_tbl(k).stream_element_date   :=  l_se_date;

          l_open_book  :=  l_close_book;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || asset_rents(k).se_days || ':' || l_close_book || ':' || l_interest || ':' || l_principal || ':' || l_se_date );
          END IF;
        END LOOP;

        IF l_interim_interest > 0 THEN

          IF l_rent_sll.arrears_yn = 'Y' THEN

            x_principal_tbl(asset_rents.FIRST-1).amount  :=  0;
            x_interest_tbl(asset_rents.FIRST-1).amount   :=  l_interim_interest;
            x_prin_bal_tbl(asset_rents.FIRST-1).amount   :=  p_investment;

            x_principal_tbl(asset_rents.FIRST-1).se_line_number  :=  0;
            x_interest_tbl(asset_rents.FIRST-1).se_line_number   :=  0;
            x_prin_bal_tbl(asset_rents.FIRST-1).se_line_number   :=  0;

            x_principal_tbl(asset_rents.FIRST-1).stream_element_date  :=  l_rent_sll.start_date;
            x_interest_tbl(asset_rents.FIRST-1).stream_element_date   :=  l_rent_sll.start_date;
            x_prin_bal_tbl(asset_rents.FIRST-1).stream_element_date   :=  l_rent_sll.start_date;

          ELSE

            x_interest_tbl(asset_rents.FIRST).amount   :=  l_interim_interest;

          END IF;

        END IF;

        x_interim_interest  :=  l_interim_interest;
        x_interim_days      :=  l_interim_days;
        x_interim_dpp       :=  l_rent_sll.dpp;
        x_iir               :=  l_iir;

        EXIT;

      END IF;

      IF SIGN(l_diff) <> SIGN(l_prev_diff) AND l_crossed_zero = 'N' THEN
        l_crossed_zero := 'Y';
      END IF;

      IF l_crossed_zero = 'Y' THEN
        l_abs_incr := ABS(l_increment) / 2;
      ELSE
        l_abs_incr := ABS(l_increment);
      END IF;

      IF i > 1 THEN
        IF SIGN(l_diff) <> l_prev_diff_sign THEN
          IF l_prev_incr_sign = 1 THEN
            l_increment := - l_abs_incr;
          ELSE
            l_increment := l_abs_incr;
          END IF;
        ELSE
          IF l_prev_incr_sign = 1 THEN
            l_increment := l_abs_incr;
          ELSE
            l_increment := - l_abs_incr;
          END IF;
        END IF;
      ELSE
        IF SIGN(l_diff) = 1 THEN
          l_increment := -l_increment;
        ELSE
          l_increment := l_increment;
        END IF;
      END IF;

      l_iir             :=  l_iir + l_increment;

      IF ABS(l_iir) > l_iir_limit THEN

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' irr ' || ABS(l_iir) );
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' irr limit ' || l_iir_limit );

        END IF;
        If k = 1 then

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_CANNOT_CALC_IIR');
        Else

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IIR_CALC_IIR_LIMIT',
                                 p_token1       => 'IIR_LIMIT',
                                 p_token1_value => l_iir_limit*100);
        End If;

        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_prev_incr_sign  :=  SIGN(l_increment);
      l_prev_diff_sign  :=  SIGN(l_diff);
      l_prev_diff       :=  l_diff;

    END LOOP;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' done with iir '  );

        END IF;
    -------------------------------------------
    -- PRE-TAX INCOME
    -------------------------------------------

    -- Reset local variables

    l_start_date       := NULL;
    l_se_date          := NULL;
    l_abs_incr         := NULL;
    l_prev_incr_sign   := NULL;
    l_crossed_zero     := 'N';
    l_diff             := NULL;
    l_prev_diff        := NULL;
    l_prev_diff_sign   := NULL;
    i := 0;
    j := 0;
    k := 0;
    m := 0;

    l_bk_yield         :=  0;
    l_increment        :=  0.1;

    -- handlig residual value at the last payment
    --asset_rents(asset_rents.LAST).se_amount := asset_rents(asset_rents.LAST).se_amount + p_residual_value;
    ---

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' start with bkg yld '  );
        END IF;
    LOOP

--DEBUG
--EXIT WHEN i = 2;

      i :=  i + 1;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '');
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'Booking Yield Iteration # '||i||' Guess Value '||l_bk_yield);

    END IF;
      l_termination_val  :=  p_investment;
      k                  :=  1;
      j                  :=  0;
      m                  :=  0;
      l_start_date       :=  l_rent_sll.start_date;
      l_sll_start_date   :=  TRUNC(asset_rents(asset_rents.FIRST).se_date);
      l_term_complete    := 'N';

      LOOP

        l_was_a_stub_payment := 'N';

        j :=  j + 1;

        l_se_date  :=  asset_rents(k).se_date;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' l_se_date ' || LAST_DAY(l_se_date) || ' l_start_date ' || LAST_DAY(l_start_date) );

        END IF;
        IF TRUNC(LAST_DAY(l_se_date)) <> TRUNC(LAST_DAY(l_start_date)) THEN          -- NON payment month

          l_end_date  :=  LAST_DAY(l_start_date);

          l_days :=   OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => l_start_date,
                                    p_days_in_month => l_day_convention_month,
				    p_days_in_year => l_day_convention_year,
                                    p_end_date      => l_end_date,
                                    p_arrears       => 'Y',
                                    x_return_status => lx_return_status);

          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          pre_tax_income(j).se_amount  :=  l_termination_val*l_days*l_bk_yield/360;
          l_termination_val            :=  l_termination_val*(1 + l_days*l_bk_yield/360);
          termination_val(j).se_amount :=  l_termination_val;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'Non Payment Month '||TO_CHAR(l_start_date, 'MON-YYYY')|| ' DAYS '||l_days|| ' Income '
                          ||ROUND(pre_tax_income(j).se_amount, 3)|| ' Month Ending TV '
  			||ROUND(termination_val(j).se_amount, 3));

    END IF;
          l_se_date := LAST_DAY(l_start_date);


          IF TO_CHAR(LAST_DAY(l_se_date), 'DD') = '31' THEN
            l_se_date  :=  l_se_date - 1;
          END IF;


          termination_val(j).se_date := l_se_date;
          pre_tax_income(j).se_date  := l_se_date;

        ELSE                                                           -- payment month

          -- first half of payment month

          l_end_date := l_se_date;

          l_days :=   OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => l_start_date,
                                    p_days_in_month => l_day_convention_month,
				    p_days_in_year => l_day_convention_year,
                                    p_end_date      => l_end_date,
                                    p_arrears       => l_rent_sll.arrears_yn,
                                    x_return_status => lx_return_status);

          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          IF j = 1 AND l_interim_interest > 0 THEN

            l_days := 0;

          END IF;


          pre_tax_income(j).se_amount  :=  l_termination_val*l_days*l_bk_yield/360;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name ||
  'PAY MO. '||TO_CHAR(l_start_date, 'MON-YYYY')||
  ' Days pre-RENT '||l_days||
  ' TV for CALC '||ROUND(l_termination_val, 3)||
  ' ACC INT '||ROUND(pre_tax_income(j).se_amount, 3)||
  ' TV after RENT '||ROUND(l_termination_val + pre_tax_income(j).se_amount - asset_rents(k).se_amount, 3));

    END IF;
          l_termination_val            :=  l_termination_val + pre_tax_income(j).se_amount;
          l_termination_val            :=  l_termination_val - asset_rents(k).se_amount;

          -- 2nd half of payment month

          IF k = asset_rents.LAST THEN                                 -- check for last payment

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '');
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'Last RENT recieved '||TO_CHAR(asset_rents(k).se_date, 'DD-MON-YYYY'));
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '');

    END IF;
            l_start_date := l_se_date;

            LOOP
--DEBUG
--EXIT WHEN m > 10;
              m := m + 1;

              IF TRUNC(LAST_DAY(l_start_date)) <> TRUNC(LAST_DAY(l_k_end_date)) THEN
                l_end_date := LAST_DAY(l_start_date);
              ELSE
                l_end_date := l_k_end_date;
              END IF;

              l_days :=   OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => l_start_date,
                                        p_days_in_month => l_day_convention_month,
				        p_days_in_year => l_day_convention_year,
                                        p_end_date      => l_end_date,
                                        p_arrears       => 'Y',
                                        x_return_status => lx_return_status);

              IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              IF (l_rent_sll.arrears_yn = 'Y') AND (m = 1) THEN
                l_days := l_days - 1;
              END IF;

              IF m = 1 THEN
                pre_tax_income(j).se_amount := pre_tax_income(j).se_amount+l_termination_val*l_days*l_bk_yield/360;
              ELSE
                pre_tax_income(j).se_amount := l_termination_val*l_days*l_bk_yield/360;
              END IF;

              l_termination_val := l_termination_val*(1 + l_days*l_bk_yield/360);

              IF TRUNC(l_end_date) = TRUNC(l_k_end_date) THEN
                l_termination_val := l_termination_val - p_residual_value;
                l_term_complete   := 'Y';
              END IF;

              termination_val(j).se_amount :=  l_termination_val;

              l_se_date := LAST_DAY(l_start_date);

              IF TO_CHAR(LAST_DAY(l_se_date), 'DD') = '31' THEN
                l_se_date  :=  l_se_date - 1;
              END IF;

              termination_val(j).se_date := l_se_date;
              pre_tax_income(j).se_date  := l_se_date;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name ||
  '('||TO_CHAR(l_start_date, 'DD-MON-YYYY')||
  ' - '||TO_CHAR(l_end_date, 'DD-MON-YYYY')||
  ') Days '||l_days||
  ' Income '||ROUND(pre_tax_income(j).se_amount,3)||
  ' T Val '||ROUND(termination_val(j).se_amount, 3));

    END IF;
              EXIT WHEN TRUNC(l_end_date) = TRUNC(l_k_end_date);

              l_start_date := LAST_DAY(l_start_date) + 1;
              j := j + 1;

            END LOOP;

          ELSE                                                         -- last payment has NOT occurred

            IF NVL(asset_rents(k).se_stub,'N')='Y' THEN
               -- Fetching the next payment date
               -- interested only in the first record
	       l_sll_start_date := TRUNC(asset_rents(k+1).se_date);
            END IF;
            -- if the stub and next payment fall in the same month
            -- then we use the below logic

            IF NVL(asset_rents(k).se_stub,'N')='Y' AND
               LAST_DAY(TRUNC(NVL(l_sll_start_date,l_end_date))) = LAST_DAY(TRUNC(l_end_date)) THEN

              l_was_a_stub_payment := 'Y';
              l_start_date := TRUNC(l_end_date);
              l_end_date := TRUNC(NVL(l_sll_start_date,l_end_Date));
              l_se_date := TRUNC(NVL(l_sll_start_date,l_end_Date));

                l_days :=   OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => l_start_date,
                                                                   p_days_in_month => l_day_convention_month,
				                                   p_days_in_year => l_day_convention_year,
                                                                   p_end_date      => l_end_date,
                                                                   p_arrears       => l_rent_sll.arrears_yn,
                                                                   x_return_status => lx_return_status);

                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                IF j = 1 AND l_interim_interest > 0 THEN
                    l_days := 0;
                END IF;


    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name ||
  'PAY MO. '||TO_CHAR(l_start_date, 'MON-YYYY')||
  ' Days stub '||l_days||
  ' TV for CALC '||ROUND(l_termination_val, 3)||
  ' INC (stub) '||ROUND(l_termination_val*l_days*l_bk_yield/360, 3)||
  ' ME TV '||ROUND(l_termination_val * ( 1 + l_days*l_bk_yield/360) -
  		 asset_rents(k+1).se_amount));

    END IF;
                pre_tax_income(j).se_amount  :=  pre_tax_income(j).se_amount+l_termination_val*l_days*l_bk_yield/360;
                --l_termination_val            :=  l_termination_val + pre_tax_income(j).se_amount;
                l_termination_val            :=  l_termination_val * ( 1 + l_days*l_bk_yield/360);
                l_termination_val            :=  l_termination_val - asset_rents(k+1).se_amount;


                IF (k+1) = asset_rents.LAST THEN

                    l_start_date := l_se_date;
                    LOOP
                      m := m + 1;
			  IF LAST_DAY(l_start_date) <> LAST_DAY(l_k_end_date) THEN
			    l_end_date := LAST_DAY(l_start_date);
			  ELSE
			    l_end_date := l_k_end_date;
			  END IF;
			  l_days :=   OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => l_start_date,
                                                                             p_days_in_month => l_day_convention_month,
				                                             p_days_in_year => l_day_convention_year,
                                                                             p_end_date      => l_end_date,
                                                                             p_arrears       => 'Y',
                                                                             x_return_status => lx_return_status);

                          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                              RAISE OKL_API.G_EXCEPTION_ERROR;
                          END IF;
                          IF (l_rent_sll.arrears_yn = 'Y') AND (m = 1) THEN
                              l_days := l_days - 1;
                          END IF;
                          IF m = 1 THEN
                             pre_tax_income(j).se_amount := pre_tax_income(j).se_amount+
		                                     l_termination_val*l_days*l_bk_yield/360;
                          ELSE
                             pre_tax_income(j).se_amount := l_termination_val*l_days*l_bk_yield/360;
                          END IF;
                          l_termination_val := l_termination_val*(1 + l_days*l_bk_yield/360);
                          IF TRUNC(l_end_date)  = TRUNC(l_k_end_date) THEN
                              l_termination_val := l_termination_val - p_residual_value;
                              l_term_complete   := 'Y';
                          END IF;
                          termination_val(j).se_amount :=  l_termination_val;
                          l_se_date := LAST_DAY(l_start_date);
                          IF TO_CHAR(LAST_DAY(l_se_date), 'DD') = '31' THEN
                              l_se_date  :=  l_se_date - 1;
                          END IF;

                          termination_val(j).se_date := l_se_date;
                          pre_tax_income(j).se_date  := l_se_date;

                          EXIT WHEN TRUNC(l_end_date) = TRUNC(l_k_end_date);
                          l_start_date := LAST_DAY(l_start_date) + 1;
                          j := j + 1;

                    END LOOP;

	        End If;

--	        l_start_date := asset_rents(k).se_date+1;
                k := k + 1;
                l_se_date  :=  asset_rents(k).se_date;

                EXIT WHEN l_term_complete = 'Y';

            ElsIF NVL(asset_rents(k+1).se_stub,'N')='Y' AND
               LAST_DAY(TRUNC(asset_rents(k+1).se_date)) = LAST_DAY(TRUNC(asset_rents(k).se_date)) THEN

              k := k + 1;
              l_start_date := TRUNC(l_end_date);
              l_end_date := TRUNC(asset_rents(k).se_date);
              l_se_date := TRUNC(asset_rents(k).se_date);

                l_days :=   OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => l_start_date,
                                                                   p_days_in_month => l_day_convention_month,
				                                   p_days_in_year => l_day_convention_year,
                                                                   p_end_date      => l_end_date,
                                                                   p_arrears       => l_rent_sll.arrears_yn,
                                                                   x_return_status => lx_return_status);

                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                IF j = 1 AND l_interim_interest > 0 THEN
                    l_days := 0;
                END IF;


                IF (l_rent_sll.arrears_yn = 'Y') AND
                       (TO_CHAR(l_end_date, 'DD') IN ('30', '31') OR
                        (TO_CHAR(l_end_date, 'MON') = 'FEB' AND
		        TO_CHAR(l_end_date, 'DD') IN ('28', '29')) ) THEN

                  l_days := l_days - 1;

                END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name ||
  'PAY MO. '||TO_CHAR(l_start_date, 'MON-YYYY')||
  ' Days stub '||l_days||
  ' TV for CALC '||ROUND(l_termination_val, 3)||
  ' INC (stub) '||ROUND(l_termination_val*l_days*l_bk_yield/360, 3)||
  ' ME TV '||ROUND(l_termination_val * ( 1 + l_days*l_bk_yield/360) -
  		 asset_rents(k).se_amount));

    END IF;
                pre_tax_income(j).se_amount  :=  pre_tax_income(j).se_amount+l_termination_val*l_days*l_bk_yield/360;
                l_termination_val            :=  l_termination_val * ( 1 + l_days*l_bk_yield/360);
                l_termination_val            :=  l_termination_val - asset_rents(k).se_amount;


                IF k = asset_rents.LAST THEN

                    l_start_date := l_se_date;
                    LOOP
                      m := m + 1;
			  IF LAST_DAY(l_start_date) <> LAST_DAY(l_k_end_date) THEN
			    l_end_date := LAST_DAY(l_start_date);
			  ELSE
			    l_end_date := l_k_end_date;
			  END IF;

			  l_days :=   OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => l_start_date,
                                                                             p_days_in_month => l_day_convention_month,
				                                             p_days_in_year => l_day_convention_year,
                                                                             p_end_date      => l_end_date,
                                                                             p_arrears       => 'Y',
                                                                             x_return_status => lx_return_status);

                          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                              RAISE OKL_API.G_EXCEPTION_ERROR;
                          END IF;
                          IF (l_rent_sll.arrears_yn = 'Y') AND (m = 1) THEN
                              l_days := l_days - 1;
                          END IF;
                          IF m = 1 THEN
                             pre_tax_income(j).se_amount := pre_tax_income(j).se_amount+
		                                     l_termination_val*l_days*l_bk_yield/360;
                          ELSE
                             pre_tax_income(j).se_amount := l_termination_val*l_days*l_bk_yield/360;
                          END IF;
                          l_termination_val := l_termination_val*(1 + l_days*l_bk_yield/360);
                          IF TRUNC(l_end_date)  = TRUNC(l_k_end_date) THEN
                              l_termination_val := l_termination_val - p_residual_value;
                              l_term_complete   := 'Y';
                          END IF;
                          termination_val(j).se_amount :=  l_termination_val;
                          l_se_date := LAST_DAY(l_start_date);
                          IF TO_CHAR(LAST_DAY(l_se_date), 'DD') = '31' THEN
                              l_se_date  :=  l_se_date - 1;
                          END IF;

                          termination_val(j).se_date := l_se_date;
                          pre_tax_income(j).se_date  := l_se_date;

                          EXIT WHEN TRUNC(l_end_date) = TRUNC(l_k_end_date);
                          l_start_date := LAST_DAY(l_start_date) + 1;
                          j := j + 1;

                    END LOOP;

	        End If;

	    End If;

            IF TO_CHAR(TRUNC(l_end_date),'MON') = 'FEB' THEN
              IF TO_CHAR(TRUNC(l_sll_start_date),'DD') IN (30,31) OR
                 (TO_CHAR(TRUNC(l_sll_start_date),'DD') = 1 AND
                   (l_was_a_stub_payment = 'Y' OR l_rent_sll.arrears_yn = 'Y')) OR
                 (TO_CHAR(TRUNC(l_sll_start_date),'MON') = 'FEB' AND
                   TO_CHAR(TRUNC(l_sll_start_date),'DD') = 29) OR
                  (TO_CHAR(TRUNC(l_sll_start_date),'MON') = 'FEB' AND
                   TO_CHAR(TRUNC(l_sll_start_date),'DD') = 28) THEN
                l_days := 0;
              ELSE
                l_days := 30 - TO_CHAR(TRUNC(l_end_date), 'DD');
              END IF;
            ELSE
              l_days := 30 - TO_CHAR(TRUNC(l_end_date), 'DD');
            END IF;

            IF l_days <= 0 THEN
              IF l_rent_sll.arrears_yn = 'Y' THEN
                l_days := 0;
              ELSE
                l_days := 1;
              END IF;
            ELSIF l_rent_sll.arrears_yn = 'N' THEN
              l_days := l_days + 1;
            END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name ||
  'PAY MO. '||TO_CHAR(l_start_date, 'MON-YYYY')||
  ' Days post-RENT '||l_days||
  ' TV for CALC '||ROUND(l_termination_val, 3)||
  ' INC (2nd half) '||ROUND(l_termination_val*l_days*l_bk_yield/360, 3)||
  ' ME TV '||ROUND(l_termination_val*(1 + l_days*l_bk_yield/360), 3));

    END IF;
            pre_tax_income(j).se_amount  :=  pre_tax_income(j).se_amount + l_termination_val*l_days*l_bk_yield/360;

            l_termination_val            :=  l_termination_val*(1 + l_days*l_bk_yield/360);
            termination_val(j).se_amount :=  l_termination_val;

            l_se_date := LAST_DAY(l_start_date);

            IF TO_CHAR(LAST_DAY(l_se_date), 'DD') = '31' THEN
              l_se_date  :=  l_se_date - 1;
            END IF;

            termination_val(j).se_date := l_se_date;
            pre_tax_income(j).se_date  := l_se_date;

            k := k + 1;

          END IF;                                              --------- END check last payment

          EXIT WHEN l_term_complete = 'Y';

        END IF;                                                --------- END second half processing

        l_start_date := LAST_DAY(l_start_date) + 1;

      END LOOP;

      --l_diff  :=  l_termination_val - p_residual_value;
      l_diff  :=  l_termination_val;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' L_DIFF ' || l_diff );

      END IF;
      IF ROUND(l_diff, 4) = 0 THEN

        FOR j IN pre_tax_income.FIRST .. pre_tax_income.LAST LOOP

          x_termination_tbl(j).stream_element_date  := termination_val(j).se_date;
          x_pre_tax_inc_tbl(j).stream_element_date  := pre_tax_income(j).se_date;

          x_termination_tbl(j).amount  := termination_val(j).se_amount;
          x_pre_tax_inc_tbl(j).amount  := pre_tax_income(j).se_amount;

          IF l_interim_interest > 0 AND
             (LAST_DAY(pre_tax_income(j).se_date) = LAST_DAY(l_rent_sll.start_date)) THEN

            x_pre_tax_inc_tbl(j).amount  := x_pre_tax_inc_tbl(j).amount + l_interim_interest;

          END IF;

          x_termination_tbl(j).se_line_number  := j;
          x_pre_tax_inc_tbl(j).se_line_number  := j;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || x_pre_tax_inc_tbl(j).amount || ':' ||
                   x_termination_tbl(j).amount || ':' || x_termination_tbl(j).stream_element_date );

      END IF;
        END LOOP;

        --For j in 1..l_rent_sll.mpp LOOP
        --    x_termination_tbl(x_termination_tbl.LAST-j+1).amount  := p_residual_value;
	--END LOOP;

        l_end_date := LAST_DAY(asset_rents(asset_rents.LAST).se_date);
        l_start_date := LAST_DAY(x_termination_tbl(x_termination_tbl.LAST).stream_element_date);

        x_termination_tbl(x_termination_tbl.LAST).amount  := p_residual_value;

      x_booking_yield  := l_bk_yield;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' Booking yield ' || l_bk_yield );

      END IF;
      RETURN;

    END IF;

    IF SIGN(l_diff) <> SIGN(l_prev_diff) AND l_crossed_zero = 'N' THEN
      l_crossed_zero := 'Y';
    END IF;

    IF l_crossed_zero = 'Y' THEN
      l_abs_incr := ABS(l_increment) / 2;
    ELSE
      l_abs_incr := ABS(l_increment);
    END IF;

    IF i > 1 THEN
      IF SIGN(l_diff) <> l_prev_diff_sign THEN
        IF l_prev_incr_sign = 1 THEN
          l_increment :=  - l_abs_incr;
        ELSE
          l_increment := l_abs_incr;
        END IF;
      ELSE
        IF l_prev_incr_sign = 1 THEN
          l_increment := l_abs_incr;
        ELSE
          l_increment := - l_abs_incr;
        END IF;
      END IF;
    ELSE

      IF SIGN(l_diff) = 1 THEN
        l_increment := -l_increment;
      ELSE
        l_increment := l_increment;
      END IF;
    END IF;

    l_bk_yield        :=  l_bk_yield + l_increment;
    l_prev_incr_sign  :=  SIGN(l_increment);
    l_prev_diff_sign  :=  SIGN(l_diff);
    l_prev_diff       :=  l_diff;

  END LOOP;

  x_return_status  :=  lx_return_status;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'end' );

    END IF;
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

  END get_quote_amortization;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_loan_amortization
  --
  -- Description
  -- Populates Stream Element arrays with loan specific streams
  ---------------------------------------------------------------------------
  -- bug 2992184. Added p_purpose_code parameter.
  -- Added input parameter p_se_id by prasjain for bug 5474827
  PROCEDURE get_loan_amortization (p_khr_id              IN  NUMBER,
                                   p_kle_id              IN  NUMBER,
                                   p_purpose_code        IN VARCHAR2,
                                   p_investment          IN  NUMBER,
                                   p_residual_value      IN  NUMBER,
                                   p_start_date          IN  DATE,
                                   p_asset_start_date    IN  DATE,
                                   p_term_duration       IN  NUMBER,
                                   p_currency_code       IN  VARCHAR2,  --USED?
                                   p_deal_type           IN  VARCHAR2,  --USED?
                                   p_asset_iir_guess     IN NUMBER DEFAULT NULL,
                                   p_bkg_yield_guess     IN NUMBER DEFAULT NULL,
                                   x_principal_tbl       OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_interest_tbl        OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_prin_bal_tbl        OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_termination_tbl     OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_pre_tax_inc_tbl     OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                   x_interim_interest    OUT NOCOPY NUMBER,
                                   x_interim_days        OUT NOCOPY NUMBER,
                                   x_interim_dpp         OUT NOCOPY NUMBER,
                                   x_iir                 OUT NOCOPY NUMBER,
                                   x_booking_yield       OUT NOCOPY NUMBER,
                                   x_return_status       OUT NOCOPY VARCHAR2,
                                   p_se_id               IN  NUMBER
                                   -- Params added for Prospective Rebooking
                                  ,p_during_rebook_yn    IN  VARCHAR2
                                  ,p_rebook_type         IN  VARCHAR2
                                  ,p_prosp_rebook_flag   IN  VARCHAR2
                                  ,p_rebook_date         IN  DATE
                                  ,p_income_strm_sty_id  IN  NUMBER
                                   ) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_loan_amortization';

    CURSOR c_rent_slls ( streamName VARCHAR2 ) IS
      SELECT FND_DATE.canonical_to_date(sll.rule_information2) start_date,
             TO_NUMBER(SLL.rule_information3) periods,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 120, 'S', 180, 'A', 360) dpp,
             DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) mpp,
             NVL(sll.rule_information10, 'N') arrears_yn,
             FND_NUMBER.canonical_to_number(sll.rule_information6) rent_amount
      FROM   okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp,
             okl_strm_type_b sty,
             okl_strm_type_tl styt
      WHERE  rgp.dnz_chr_id = p_khr_id
        AND  rgp.cle_id = p_kle_id
        AND  rgp.rgd_code= 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  TO_NUMBER(slh.object1_id1) = sty.id
        AND  sty.version = '1.0'
        AND  sty.id = styt.id
        AND STYT.LANGUAGE = USERENV('LANG')  -- Bug 4626837
        AND  styt.name = streamName
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
      ORDER BY fnd_date.canonical_to_date(sll.rule_information2);

    l_rent_sll  c_rent_slls%ROWTYPE;

    -- bug 2992184. Added where condition for multi-gaap reporting streams.
    CURSOR c_rent_flows ( streamName VARCHAR2 ) IS
      SELECT sel.id se_id,
             sel.amount se_amount,
             sel.stream_element_date se_date,
             sel.comments se_arrears,
             sel.sel_id se_sel_id,
	     sty.stream_type_purpose,
	           DECODE(sty.stream_type_purpose,
	                  'UNSCHEDULED_PRINCIPAL_PAYMENT','UPP',
	                  'UNSCHEDULED_INTEREST_PAYMENT','UIP',
	                  'DOWN_PAYMENT','DOWN_PMNT',
	                  'PRINCIPAL_PAYMENT', 'PRIN_PMNT',
	                  'RENT' ) cf_purpose
      FROM   okl_strm_elements sel,
             okl_streams stm,
             okl_strm_type_b sty,
             okl_strm_type_tl styt
      WHERE  stm.kle_id = p_kle_id
        AND  stm.say_code = 'WORK'
        AND  DECODE(stm.purpose_code, NULL, '-99', 'REPORT') = p_purpose_code
        AND  stm.sty_id = sty.id
        AND  sty.version = '1.0'
        AND  sty.id = styt.id
        AND  STYT.LANGUAGE = USERENV('LANG')  -- Bug 4626837
        AND  (styt.name =  streamName OR
	      sty.stream_type_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT' OR
	      sty.stream_type_purpose = 'UNSCHEDULED_INTEREST_PAYMENT' OR
	      sty.stream_type_purpose = 'DOWN_PAYMENT' OR
	      sty.stream_type_purpose = 'PRINCIPAL_PAYMENT')
        AND  stm.id = sel.stm_id
      ORDER BY sel.stream_element_date;

/* Commented by prasjain for bug 5474827
    Cursor c_stub IS
    Select sel.id
    from okl_streams stm,
         okl_strm_elements sel
    where stm.khr_id = p_khr_id
      and stm.say_code     =  'HIST'
      and stm.SGN_CODE     =  'MANL'
      and stm.active_yn    =  'N'
      and stm.purpose_code =  'STUBS'
      and stm.comments     =  'STUB STREAMS'
      and sel.stm_id = stm.id;
*/

    -- get payment next date after stub
    CURSOR c_date_pay_stub(p_khr_id NUMBER,
                           p_kle_id NUMBER,
                           p_date date)
    IS
    SELECT TRUNC(FND_DATE.canonical_to_date(crl.rule_information2))
    FROM okc_rule_groups_b crg,
         okc_rules_b crl
    WHERE crl.rgp_id = crg.id
    AND crg.rgd_code = 'LALEVL'
    AND crl.rule_information_category = 'LASLL'
    AND crg.dnz_chr_id = p_khr_id
    AND crg.cle_id = p_kle_id
    AND TRUNC(FND_DATE.canonical_to_date(crl.rule_information2)) > TRUNC(p_date)
    AND crl.rule_information2 IS NOT NULL
    AND crl.rule_information6 IS NOT NULL
    ORDER BY FND_DATE.canonical_to_date(crl.rule_information2);

    l_stub_id NUMBER;

    TYPE loan_rec IS RECORD (se_amount NUMBER,
                             se_date DATE,
			     se_days NUMBER,
			     se_arrears VARCHAR2(1),
			     se_stub VARCHAR2(1),
			     se_purpose VARCHAR2(256)
			     ,cf_purpose  VARCHAR2(10)
           );

    TYPE loan_tbl IS TABLE OF loan_rec INDEX BY BINARY_INTEGER;

    asset_rents        loan_tbl;
    loan_payment       loan_tbl;
    pricipal_payment   loan_tbl;
    interest_payment   loan_tbl;
    pre_tax_income     loan_tbl;
    termination_val    loan_tbl;

    l_iir_limit        NUMBER            := NVL(ABS(fnd_profile.value('OKL_PRE_TAX_IIR_LIMIT')), 1000)/100;

    l_start_date       DATE;
    l_sll_start_date   DATE;
    l_end_date         DATE;
    l_interim_days     NUMBER;
    l_interim_interest NUMBER;
    l_open_book        NUMBER;
    l_close_book       NUMBER;
    l_payment          NUMBER;
    l_interest         NUMBER;
    l_principal        NUMBER;
    l_se_date          DATE;
    l_termination_val  NUMBER;
    l_days             NUMBER;
    l_iir              NUMBER            := nvl(p_asset_iir_guess, 0);
    l_bk_yield         NUMBER            := nvl(p_bkg_yield_guess, 0);

    --vthiruva..Fix for bug# 4060958
    --added NVL check on p_residual_value and using the local variable in the
    --calculations to prevent errors due to null being passed in p_residual_value
    l_residual_value   NUMBER            := nvl(p_residual_value, 0);
    l_rent_period_end  DATE;
    l_k_end_date       DATE              := (ADD_MONTHS(p_start_date, p_term_duration) - 1);
    l_total_periods    NUMBER            := 0;
    l_term_complete    VARCHAR2(1)       := 'N';

    l_increment        NUMBER            := 0.1;
    l_abs_incr         NUMBER;
    l_prev_incr_sign   NUMBER;
    l_crossed_zero     VARCHAR2(1)       := 'N';

    l_diff             NUMBER;
    l_prev_diff        NUMBER;
    l_prev_diff_sign   NUMBER;

    i                  BINARY_INTEGER    :=  0;
    j                  BINARY_INTEGER    :=  0;
    l                  BINARY_INTEGER    :=  0;
    k                  BINARY_INTEGER    :=  0;
    m                  BINARY_INTEGER    :=  0;

    lx_return_status   VARCHAR2(1);

    Cursor fee_type_csr IS
    Select 'Y' What
    from dual where Exists(
    SELECT nvl(kle.fee_type, 'XYZ'),
           nvl(lse.lty_code, 'XYZ')
    FROM   okc_k_lines_b cle,
           okl_k_lines kle,
           okc_line_styles_b lse
    WHERE  cle.dnz_chr_id = p_khr_id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.lse_id = lse.id
        AND  (kle.fee_type = 'FINANCED' OR kle.fee_type = 'ROLLOVER' OR lse.lty_code = 'LINK_FEE_ASSET')
        AND  cle.id = kle.id
	AND  cle.id = p_kle_id);


    fee_type_rec fee_type_csr%ROWTYPe;


    l_stream_name VARCHAR2(256);
    l_sty_id NUMBER;

    cursor fee_strm_type_csr is
    SELECT styt.name
      FROM   okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp,
             okl_strm_type_b sty,
             okl_strm_type_tl styt
      WHERE  rgp.dnz_chr_id = p_khr_id
        AND  rgp.cle_id = p_kle_id
        AND  rgp.rgd_code= 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  TO_NUMBER(slh.object1_id1) = sty.id
        AND  sty.version = '1.0'
        AND  sty.id = styt.id
        AND  STYT.LANGUAGE = USERENV('LANG')  -- Bug 4626837
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
      ORDER BY fnd_date.canonical_to_date(sll.rule_information2);

    CURSOR l_terminated_line_csr is
    SELECT kle.ID,
	   sts.STE_CODE,
	   trunc(nvl(kle.DATE_TERMINATED, sysdate)) date_terminated
    FROM  okl_k_lines_full_v kle,
     	   okc_statuses_b sts
    WHERE kle.id = p_kle_id
          and kle.dnz_chr_id = p_khr_id
     	  and sts.code = kle.sts_code
	  and sts.ste_code not in ('HOLD', 'EXPIRED', 'CANCELLED');

    l_terminated_line_rec l_terminated_line_csr%ROWTYPE;

    l_was_a_stub_payment VARCHAR2(1) := 'N';

    -- Added by RGOOTY
    l_prev_iir NUMBER := 0;
    l_positive_diff_iir NUMBER := 0;
    l_negative_diff_iir NUMBER := 0;
    l_positive_diff NUMBER := 0;
    l_negative_diff NUMBER := 0;

    l_prev_bk_yeild NUMBER := 0;
    l_positive_diff_bk_yeild NUMBER := 0;
    l_negative_diff_bk_yeild NUMBER := 0;
    l_day_convention_month VARCHAR2(30);
    l_day_convention_year VARCHAR2(30);
    l_days_in_year NUMBER;

 -- Start : djanaswa : Bug 6274342
    l_arrears_pay_dates_option okl_st_gen_tmpt_sets_all.isg_arrears_pay_dates_option%type;
  -- End : djanaswa : Bug 6274342
    -- Start: Modifications done for the Prospective Rebooking Enhancement
    l_api_version     CONSTANT    NUMBER          DEFAULT 1.0;
    l_api_name        CONSTANT    VARCHAR2(30)    DEFAULT 'get_loan_amortization';
    l_day_count_method            VARCHAR2(30);
    x_msg_count       NUMBER;
    x_msg_data        VARCHAR2(4000);
    lx_pricing_parameter_rec okl_pricing_utils_pvt.pricing_parameter_rec_type;
    l_cf_inflows             okl_pricing_utils_pvt.cash_inflows_tbl_type;
    l_residuals              okl_pricing_utils_pvt.cash_inflows_tbl_type;
    l_termination_tbl        okl_pricing_utils_pvt.cash_inflows_tbl_type;
    l_pre_tax_inc_tbl        okl_pricing_utils_pvt.cash_inflows_tbl_type;
    -- End: Modifications done for the Prospective Rebooking Enhancement

    -- Variables declared for Prospective Rebooking
    -- Cursor to get the Original Contract Id and Line Id Details
    CURSOR get_orig_khr_dtls_csr (
      p_kle_id       IN NUMBER   )
    IS
    SELECT  cle.orig_system_id1   orig_kle_id
           ,chr.orig_system_id1   orig_khr_id
      FROM  okc_k_lines_b         cle
           ,okc_k_headers_b       chr
     WHERE  cle.id          = p_kle_id
       AND  cle.dnz_chr_id  = chr.id
       AND  cle.orig_system_id1 IS NOT NULL;

    CURSOR get_sub_pre_tax_yield_csr( p_kle_id NUMBER)
    IS
      SELECT ( sub_pre_tax_yield / 100 )  sub_pre_tax_yield
        FROM okl_k_lines kle
       WHERE kle.id = p_kle_id;
    -- Cursor to fetch the Stream Elements for a given Contract, Line, Stream and Purpose
    CURSOR get_strms_csr (
       p_khr_id       IN NUMBER
      ,p_kle_id       IN NUMBER
      ,p_sty_id       IN NUMBER
      ,p_purpose_code IN VARCHAR2
    )
    IS
       SELECT sel.id                  se_id,
              sel.amount              se_amount,
              sel.stream_element_date se_date,
              sel.comments            se_arrears,
              sel.sel_id              se_sel_id
       FROM   okl_strm_elements sel,
              okl_streams       stm
       WHERE  stm.kle_id = p_kle_id
         AND  stm.khr_id = p_khr_id
         AND  stm.sty_id = p_sty_id
         AND  DECODE(stm.purpose_code,
                     NULL, '-99',
                     'REPORT'
                    ) = p_purpose_code
         AND  stm.say_code = 'CURR'
         AND  stm.id = sel.stm_id
       ORDER BY sel.stream_element_date;

    -- Additional Variables added during Prospective Rebooking Enhancement
    l_prosp_rebook_flag      VARCHAR2(30);
    l_rebook_date            DATE;
    l_last_accrued_date      DATE;
    l_orig_khr_id            NUMBER;
    l_orig_kle_id            NUMBER;
    cf_index                 NUMBER;
    l_flip_prb_rbk_reason    VARCHAR2(100);
    l_orig_income_streams    okl_pricing_utils_pvt.cash_inflows_tbl_type;
    l_rebook_type            VARCHAR2(100);

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

--    print( l_prog_name, 'begin' );

    OPEN l_terminated_line_csr;
    FETCH l_terminated_line_csr INTO l_terminated_line_rec;
    CLOSE l_terminated_line_csr;
    If ( l_terminated_line_rec.ste_code = 'TERMINATED') Then
        l_k_end_date := LAST_DAY(l_terminated_line_rec.date_terminated);
    End if;

--Added by prasjain for bug 5474827
/*
    OPEN c_stub;
    FETCH c_stub INTO l_stub_id;
    CLOSE c_stub;
*/
    l_stub_id := p_se_id;
--end prasjain


    OPEN fee_type_csr;
    FETCH fee_type_csr INTO fee_type_rec;
    CLOSE fee_type_csr;

   -- Fetch the day convention ..
   OKL_PRICING_UTILS_PVT.get_day_convention(
     p_id              => p_khr_id,
     p_source          => 'ISG',
     x_days_in_month   => l_day_convention_month,
     x_days_in_year    => l_day_convention_year,
     x_return_status   => lx_return_status);
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
   END IF;
   IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

    If nvl(fee_type_rec.What, 'N') = 'Y' Then

    OPEN fee_strm_type_csr;
	FETCH fee_strm_type_csr INTO l_stream_name;
	CLOSE fee_strm_type_csr;

    Else
        OKL_ISG_UTILS_PVT.get_primary_stream_type(
                                                p_khr_id              => p_khr_id,
						p_deal_type           => p_deal_type,
                                                p_primary_sty_purpose => 'RENT',
                                                x_return_status       => x_return_status,
                                                x_primary_sty_id      => l_sty_id,
                                                x_primary_sty_name    => l_stream_name);

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        --l_stream_name := 'RENT';
    End If;

    OPEN c_rent_slls( l_stream_name );
    FETCH c_rent_slls INTO l_rent_sll;
    CLOSE c_rent_slls;


    l_start_date  :=  l_rent_sll.start_date;

-- Bug 6274342 DJANASWA begin
            IF l_rent_sll.arrears_yn = 'Y' THEN
              OKL_ISG_UTILS_PVT.get_arrears_pay_dates_option(
               p_khr_id                   => p_khr_id,
               x_arrears_pay_dates_option => l_arrears_pay_dates_option,
               x_return_status            => lx_return_status);

              IF(lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (lx_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
           END IF;
-- Bug 6274342 DJANASWA end


--    print( l_prog_name, 'sll start date ' || l_start_date );
    FOR  l_rent_flow IN c_rent_flows( l_stream_name ) LOOP

      k := k + 1;

-- Bug 6274342 DJANASWA begin
           IF(l_rent_sll.arrears_yn = 'Y' AND l_arrears_pay_dates_option = 'FIRST_DAY_OF_NEXT_PERIOD') THEN
             l_rent_flow.se_date := l_rent_flow.se_date - 1;
           ELSE
             l_rent_flow.se_date := l_rent_flow.se_date;
           END IF;
-- Bug 6274342 DJANASWA end


--    print( l_prog_name, 'rent flow start date ' || l_rent_flow.se_date );
      asset_rents(k).se_days    :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => l_start_date,
                                                  p_days_in_month => l_day_convention_month,
				                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => l_rent_flow.se_date,
                                                  p_arrears       => l_rent_flow.se_arrears,
                                                  x_return_status => lx_return_status);

      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      asset_rents(k).se_amount  :=  l_rent_flow.se_amount;
      asset_rents(k).se_date    :=  l_rent_flow.se_date;
      asset_rents(k).se_arrears :=  l_rent_flow.se_arrears;

      if ( ( l_rent_flow.stream_type_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT') OR
           ( l_rent_flow.stream_type_purpose = 'DOWN_PAYMENT') OR
	   ( l_rent_flow.stream_type_purpose = 'PRINCIPAL_PAYMENT') ) Then
          asset_rents(k).se_purpose := 'P';
      Elsif ( l_rent_flow.stream_type_purpose = 'UNSCHEDULED_INTEREST_PAYMENT') Then
          asset_rents(k).se_purpose := 'I';
      Else
          asset_rents(k).se_purpose := 'B';
      end if;
      asset_rents(k).cf_purpose := l_rent_flow.cf_purpose;
      l_start_date  :=  l_rent_flow.se_date;

      IF l_rent_flow.se_arrears = 'Y' THEN
        l_start_date  :=  l_start_date + 1;
      END IF;

      If ( nvl(l_rent_flow.se_sel_id, -1) = l_stub_id ) Then
        asset_rents(k).se_stub := 'Y';
      End If;

    END LOOP;

    l_interim_days  :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_asset_start_date,
                                      p_days_in_month => l_day_convention_month,
				      p_days_in_year => l_day_convention_year,
                                      p_end_date      => l_rent_sll.start_date,
                                      p_arrears       => 'N',
                                      x_return_status => lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

--    print( l_prog_name, ' asset rent count ' || to_char(asset_rents.COUNT));
    LOOP

      i :=  i + 1;

      l_interim_interest  :=  p_investment * l_interim_days * l_iir/360;

--    print( l_prog_name, i||' Implicit Rate '||l_iir||' Interim Interest '||l_interim_interest
--                         ||' Interim Days = '||l_interim_days);

      l_open_book  :=  p_investment;
--      print( l_prog_name, ' Investment ' || to_char(l_open_book));

    FOR k IN 1..asset_rents.COUNT LOOP
        l_payment    :=  asset_rents(k).se_amount;

        If ( asset_rents(k).se_purpose = 'B' ) then
            l_interest   :=  l_open_book*asset_rents(k).se_days*l_iir/360;
            l_principal  :=  l_payment - l_interest;
        elsIf ( asset_rents(k).se_purpose = 'P' ) then
            l_interest   :=  l_open_book*asset_rents(k).se_days*l_iir/360;
            l_principal  :=  l_payment;
        elsIf ( asset_rents(k).se_purpose = 'I' ) then
            l_interest   :=  l_payment;
            l_principal  :=  0;
        End if;

        l_close_book :=  l_open_book - l_principal;
        l_open_book  :=  l_close_book;

/*    print( l_prog_name, '  '||TO_CHAR(asset_rents(k).se_date, 'DD-MON-YYYY')||'   DAYS '||asset_rents(k).se_DAYS
                            || '   LOAN PAYMENT '||l_payment|| '   INTEREST '||ROUND(l_interest, 3)
			    || '   PRINCIPAL '||ROUND(l_principal, 3)||'   Next OB '||ROUND(l_open_book, 3));
*/
    END LOOP;

    -- udhenuko Bug 5046430 Fix -start for get_loan_amortization
    -- terminal value of the asset considered in the calculation of IIR
    l_payment    :=  l_residual_value;
    l_days  :=  OKL_PRICING_UTILS_PVT.get_day_count(
                  p_start_date    => asset_rents(asset_rents.LAST).se_date,
                  p_days_in_month => l_day_convention_month,
                  p_days_in_year => l_day_convention_year,
                  p_end_date      => l_k_end_date,
                  p_arrears       => 'Y',
                  x_return_status => lx_return_status);
    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_interest   :=  l_open_book*l_days*l_iir/360;
    l_principal  :=  l_payment - l_interest;
    l_close_book :=  l_open_book - l_principal;
    l_open_book  :=  l_close_book;
    -- udhenuko Bug 5046430 Fix -end for get_loan_amortization

    l_diff  :=  l_open_book;

    IF ROUND(l_diff, 4) = 0 THEN
        l_open_book  :=  p_investment;
        j := 0;
        FOR k IN asset_rents.FIRST .. asset_rents.LAST LOOP
            l_payment    :=  asset_rents(k).se_amount;

            If ( asset_rents(k).se_purpose = 'B' ) then
                l_interest   :=  l_open_book*asset_rents(k).se_days*l_iir/360;
                l_principal  :=  l_payment - l_interest;
            elsIf ( asset_rents(k).se_purpose = 'P' ) then
                l_interest   :=  l_open_book*asset_rents(k).se_days*l_iir/360;
                l_principal  :=  l_payment;
            elsIf ( asset_rents(k).se_purpose = 'I' ) then
                l_interest   :=  l_payment;
                l_principal  :=  0;
            End if;

            --l_principal  :=  l_payment - l_interest;
            l_close_book :=  l_open_book - l_principal;
            l_se_date    :=  asset_rents(k).se_date;
            If asset_rents(k).se_purpose = 'B' Then
                j := j + 1;
                x_principal_tbl(j).amount  :=  l_principal;
                x_interest_tbl(j).amount   :=  l_interest;
                x_prin_bal_tbl(j).amount   :=  l_close_book;
                x_principal_tbl(j).se_line_number  :=  j;
                x_interest_tbl(j).se_line_number   :=  j;
                x_prin_bal_tbl(j).se_line_number   :=  j;
                x_principal_tbl(j).stream_element_date  :=  l_se_date;
                x_interest_tbl(j).stream_element_date   :=  l_se_date;
                x_prin_bal_tbl(j).stream_element_date   :=  l_se_date;
            End If;
            l_open_book  :=  l_close_book;
--          print( l_prog_name, asset_rents(k).se_days || ':' || l_close_book || ':' || l_interest || ':' || l_principal || ':' || l_se_date );
        END LOOP;

        IF l_interim_interest > 0 THEN
          IF l_rent_sll.arrears_yn = 'Y' THEN
            x_principal_tbl(asset_rents.FIRST-1).amount  :=  0;
            x_interest_tbl(asset_rents.FIRST-1).amount   :=  l_interim_interest;
            x_prin_bal_tbl(asset_rents.FIRST-1).amount   :=  p_investment;

            x_principal_tbl(asset_rents.FIRST-1).se_line_number  :=  0;
            x_interest_tbl(asset_rents.FIRST-1).se_line_number   :=  0;
            x_prin_bal_tbl(asset_rents.FIRST-1).se_line_number   :=  0;

            x_principal_tbl(asset_rents.FIRST-1).stream_element_date  :=  l_rent_sll.start_date;
            x_interest_tbl(asset_rents.FIRST-1).stream_element_date   :=  l_rent_sll.start_date;
            x_prin_bal_tbl(asset_rents.FIRST-1).stream_element_date   :=  l_rent_sll.start_date;
          ELSE
            x_interest_tbl(asset_rents.FIRST).amount   :=  l_interim_interest;
          END IF;
        END IF;
        x_interim_interest  :=  l_interim_interest;
        x_interim_days      :=  l_interim_days;
        x_interim_dpp       :=  l_rent_sll.dpp;
        x_iir               :=  l_iir;
        EXIT;
  END IF;

      IF i > 1 AND SIGN(l_diff) <> SIGN(l_prev_diff) AND l_crossed_zero = 'N' THEN
        l_crossed_zero := 'Y';

        -- Added by RGOOTY
        IF ( sign( l_diff) = 1 ) then
          l_positive_diff := l_diff;
          l_negative_diff := l_prev_diff;
          l_positive_diff_iir := l_iir;
          l_negative_diff_iir := l_prev_iir;
       ELSE
         l_positive_diff := l_prev_diff;
         l_negative_diff := l_diff;
         l_positive_diff_iir := l_prev_iir;
         l_negative_diff_iir := l_iir;
       END IF;

      END IF;


      IF( sign(l_diff) = 1) THEN
        l_positive_diff := l_diff;
        l_positive_diff_iir := l_iir;
      ELSE
       l_negative_diff := l_diff;
       l_negative_diff_iir := l_iir;
      END IF;


      IF l_crossed_zero = 'Y' THEN
        -- Added by RGOOTY
        -- Means First time we have got two opposite signed
        IF i > 1 then
           l_abs_incr :=  abs(( l_positive_diff_iir - l_negative_diff_iir ) /
                            ( l_positive_diff - l_negative_diff )  * l_diff);
        ELSE
            l_abs_incr := ABS(l_increment) / 2;
        END IF;

      ELSE
        l_abs_incr := ABS(l_increment);
      END IF;

      IF i > 1 THEN
        IF SIGN(l_diff) <> l_prev_diff_sign THEN
          IF l_prev_incr_sign = 1 THEN
            l_increment := - l_abs_incr;
          ELSE
            l_increment := l_abs_incr;
          END IF;
        ELSE
          IF l_prev_incr_sign = 1 THEN
            l_increment := l_abs_incr;
          ELSE
            l_increment := - l_abs_incr;
          END IF;
        END IF;
      ELSE
        IF SIGN(l_diff) = 1 THEN
          l_increment := -l_increment;
        ELSE
          l_increment := l_increment;
        END IF;
      END IF;


      -- Added by RGOOTY: Start
      l_prev_iir        := l_iir;

      l_iir             :=  l_iir + l_increment;

      IF ABS(l_iir) > l_iir_limit THEN

--        print( l_prog_name, ' irr ' || ABS(l_iir) );
--        print( l_prog_name, ' irr limit ' || l_iir_limit );

        If k = 1 then
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_CANNOT_CALC_IIR');
        Else
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IIR_CALC_IIR_LIMIT',
                                 p_token1       => 'IIR_LIMIT',
                                 p_token1_value => l_iir_limit*100);
        End If;
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_prev_incr_sign  :=  SIGN(l_increment);
      l_prev_diff_sign  :=  SIGN(l_diff);
      l_prev_diff       :=  l_diff;
    END LOOP;
--        print( l_prog_name, ' done with iir '  );
    -- Prospective Rebooking Enhancement
    print( l_prog_name, '----------------------------------------------------------');
    print( l_prog_name, '!! BOOKING YIELD CALCULATION USING NEW SALES ORIG LOGIC !!' );
    print( l_prog_name, '----------------------------------------------------------');
    print( l_prog_name, '(Contract ID | Asset ID) = ('
           || p_khr_id || ' | ' || p_kle_id || ' ) ' );
    -- Modifications done as part of the Prospective Rebooking Enhancement
    -- Logic:
    --  Instead of calling the following peice of code, switching to call
    --   the okl_pricing_utils_pvt.compute_bk_yield API to calculate the
    --   Booking Yield as well as to return the Pre-Tax Income and Termination
    --   value streams.
    -- Step 1:
    -- Need to populate the following in the px_pricing_parameter_rec :
    --  1. (a) Asset Financed Amount
    lx_pricing_parameter_rec.line_type       := 'FREE_FORM1';
    lx_pricing_parameter_rec.line_start_date := l_rent_sll.start_date;
    lx_pricing_parameter_rec.line_end_date   := l_k_end_date; -- passing the end date as an existing value
    -- Pass the p_investment in the financed amount column
    lx_pricing_parameter_rec.financed_amount := p_investment;

    -- No Need to pass the following:
    -- lx_pricing_parameter_rec.payment_type := NULL;
    -- lx_pricing_parameter_rec.trade_in     := NULL;
    -- lx_pricing_parameter_rec.down_payment := NULL;
    -- lx_pricing_parameter_rec.subsidy      := NULL;
    --  1. (b) Asset Payment Rent Stream element details:
    --          Amount, Date, is Arrears flag
    print( l_prog_name, ' Handling the Asset Rent Stream Elements' );
    IF asset_rents IS NOT NULL
       AND asset_rents.count > 0
    THEN
      print( l_prog_name, 'Rent Stream Elements Count=' || asset_rents.COUNT );
      print( l_prog_name, 'Date | Amount | Arrears ' );
      FOR i in asset_rents.FIRST .. asset_rents.LAST
      LOOP
        l_cf_inflows(i).cf_amount  := asset_rents(i).se_amount;
        l_cf_inflows(i).cf_date    := asset_rents(i).se_date;
        l_cf_inflows(i).is_arrears := asset_rents(i).se_arrears;
        l_cf_inflows(i).cf_purpose := asset_rents(i).cf_purpose;
        print( l_prog_name, l_cf_inflows(i).cf_amount || ' | ' ||
          l_cf_inflows(i).cf_date || ' | ' || l_cf_inflows(i).is_arrears
          || ' | ' || l_cf_inflows(i).cf_purpose );
      END LOOP;
    END IF;
    --  1. (c) Asset Residual Values
    print( l_prog_name, 'Handling the Residual Value Stream ');
    IF p_residual_value IS NOT NULL
    THEN
      -- Just need to populate the Amount, nothing else needed
      l_residuals(1).cf_amount := p_residual_value;
    END IF;
    -- Populate the Cash Inflows and Residual Inflows to the Pricing Param Table
    lx_pricing_parameter_rec.cash_inflows     := l_cf_inflows;
    lx_pricing_parameter_rec.residual_inflows := l_residuals;
    -- Step 2:
    --  Get the Day Convention Method, as we have days in year and days in month
    -- Validations here ..
    okl_pricing_utils_pvt.get_day_count_method(
      p_days_in_month    => l_day_convention_month,
      p_days_in_year     => l_day_convention_year,
      x_day_count_method => l_day_count_method,
      x_return_status    => lx_return_status );
    print( l_prog_name, 'After get_days_in_year_and_month ' || lx_return_status);
    IF(lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (lx_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Prospective Rebooking Enhancement
    print( l_prog_name, 'p_prosp_rebook_flag |  p_during_rebook_yn' );
    print( l_prog_name, p_prosp_rebook_flag || ' | ' || p_during_rebook_yn);
    l_prosp_rebook_flag := 'N';
    IF p_during_rebook_yn  = 'Y' AND
       p_prosp_rebook_flag = 'Y'
    THEN
      l_prosp_rebook_flag := 'Y';
    END IF;
    print( l_prog_name, 'Prospective Rebooking : ' || l_prosp_rebook_flag );
    IF l_prosp_rebook_flag = 'Y'
    THEN
      print( l_prog_name, '-------------------------------------------------------');
      print( l_prog_name, '!!! Using Prospective Rebooking for Booking Yield  !!! ');
      print( l_prog_name, '-------------------------------------------------------');
      -- Start with No Reason for flipping from Prospective Rebooking Approach
      l_flip_prb_rbk_reason := 'NO_REASON';
      -- Derieve the Rebook Effective Date
      l_rebook_date := TRUNC(p_rebook_date);
      print( l_prog_name, 'Rebook Date = ' || l_rebook_date );
      IF l_rebook_date IS NULL
      THEN
        l_flip_prb_rbk_reason := 'NO_REBOOK_DATE';
      END IF;
      l_rebook_type := p_rebook_type;
      print( l_prog_name, 'Rebook Type = ' || l_rebook_type );
      IF l_rebook_type IS NULL
      THEN
        l_flip_prb_rbk_reason := 'NO_REBOOK_TYPE_MENTIONED';
      END IF;
      -- Calculate the Last Accrued Date
      l_last_accrued_date := TRUNC( LAST_DAY(ADD_MONTHS(p_rebook_date, -1) ) );
      print( l_prog_name,'Contract Start Date | Rebook Date | Last Accrued Date');
      print( l_prog_name, p_start_date || ' | ' || l_rebook_date|| ' | ' || l_last_accrued_date);
      IF TRUNC(p_start_date) = TRUNC(p_rebook_date)
      THEN
        l_flip_prb_rbk_reason := 'REBOOK_DATE_EQUALS_CONTRACT_START_DATE';
      ELSIF l_last_accrued_date < TRUNC(p_start_date)
      THEN
        -- In cases where the immediately preceding Lease/Interest Income
        --  stream element does not exist, the Rebook is retrospective.
        -- This applies to contract lines where the rebook effective date
        -- is before or on the first calendar month end.
        l_flip_prb_rbk_reason := 'LAST_ACCRUED_DATE_LESS_THAN_CONTRACT_START_DATE';
      END IF;

      -- Step: Fetch the Original Contract and Configuration Line ID
      IF l_flip_prb_rbk_reason = 'NO_REASON'
      THEN
        -- Only in case of Online Rebook, we need to fetch the
        --  Streams using the Original contract and Line Id
        IF l_rebook_type = 'ONLINE_REBOOK'
        THEN
          print( l_prog_name, 'Fetching Original Line and Contract Id. Rebook Type' || l_rebook_type );
          l_flip_prb_rbk_reason := 'ORIG_KHR_KLE_ID_NOT_FOUND';
          FOR t_rec IN get_orig_khr_dtls_csr  (
                         p_kle_id => p_kle_id )
          LOOP
            l_orig_khr_id := t_rec.orig_khr_id;
            l_orig_kle_id := t_rec.orig_kle_id;
            l_flip_prb_rbk_reason := 'NO_REASON';
          END LOOP;
        ELSE
          -- Mass Rebook flows
          print( l_prog_name, 'Using current Line and Contract Id. Rebook Type' || l_rebook_type );
          l_orig_khr_id := p_khr_id;
          l_orig_kle_id := p_kle_id;
        END IF;
        print( l_prog_name, 'Original Contract Id | Original Line Id ' );
        print( l_prog_name, l_orig_khr_id || ' | ' || l_orig_kle_id );
      END IF; -- IF l_flip_prb_rbk_reason = 'NO_REASON'

      -- Step: Fetch the Pre-Tax Income Streams before Revision
      IF l_flip_prb_rbk_reason = 'NO_REASON'
      THEN
        l_flip_prb_rbk_reason := 'ORIG_INCOME_STREAMS_NOT_FOUND';
        print( l_prog_name, 'Fetching the Income Stream Elements Before Revision ' );
        print( l_prog_name, 'p_khr_id | p_kle_id | p_income_strm_sty_id | p_purpose_code' );
        print( l_prog_name, p_khr_id || ' | ' ||  p_kle_id || ' | ' ||
                            p_income_strm_sty_id || ' | ' ||  p_purpose_code );
        print( l_prog_name, ' # | Date | amount ' );
        cf_index := 1;
        FOR cf_rec IN get_strms_csr(
                        p_khr_id       => l_orig_khr_id
                       ,p_kle_id       => l_orig_kle_id
                       ,p_sty_id       => p_income_strm_sty_id
                       ,p_purpose_code => p_purpose_code )
        LOOP
          l_flip_prb_rbk_reason  := 'NO_REASON';
          l_orig_income_streams(cf_index).cf_amount := cf_rec.se_amount;
          l_orig_income_streams(cf_index).cf_date   := cf_rec.se_date;
          print( l_prog_name, cf_index || ' | ' ||
            l_orig_income_streams(cf_index).cf_date || ' | ' ||
            l_orig_income_streams(cf_index).cf_amount
          );
          -- Increment the cf_index
          cf_index := cf_index + 1;
        END LOOP;
      END IF; -- IF l_flip_prb_rbk_reason = 'NO_REASON'
      -- Finally decide whether to continue in Prospective Rebooking or not
      IF l_flip_prb_rbk_reason <> 'NO_REASON'
      THEN
        print( l_prog_name, '!!! **** Unable to proceed using Prospective Rebooking Approach **** !!! ' );
        print( l_prog_name, '!!! ****  Reason : ' || l_flip_prb_rbk_reason );
        l_prosp_rebook_flag := 'N'; -- Use Retrospective Booking Logic only
      END IF;
    END IF;
    print( l_prog_name, 'Before calling okl_pricing_utils_pvt.compute_bk_yield: ');
    print( l_prog_name, 'p_start_date       = ' || l_rent_sll.start_date );
    print( l_prog_name, 'l_day_count_method = ' || l_day_count_method );
    print( l_prog_name, 'p_bkg_yield_guess  = ' || p_bkg_yield_guess );
    print( l_prog_name, 'p_term_duration    = ' || p_term_duration );
    print( l_prog_name, 'p_prosp_rebook_flag= ' || p_prosp_rebook_flag);
    print( l_prog_name, 'p_rebook_date      = ' || l_rebook_date);
    print( l_prog_name, 'l_orig_income_streams.count= ' || l_orig_income_streams.count);
    -- Call the Pricing API to calculate the Booking Yield
    --  and generate the Income Streams
    okl_pricing_utils_pvt.compute_bk_yield(
       p_api_version            => l_api_version
      ,p_init_msg_list          => 'T'
      ,x_return_status          => lx_return_status
      ,x_msg_count              => x_msg_count
      ,x_msg_data               => x_msg_data
      ,p_start_date             => l_rent_sll.start_date
      ,p_day_count_method       => l_day_count_method
      ,p_pricing_method         => 'SY'   -- For Lease Contracts always pass Solve for Yields
      ,p_initial_guess          => p_bkg_yield_guess
      ,p_term                   => p_term_duration
      ,px_pricing_parameter_rec => lx_pricing_parameter_rec
      ,x_bk_yield               => x_booking_yield
      ,x_termination_tbl        => l_termination_tbl
      ,x_pre_tax_inc_tbl        => l_pre_tax_inc_tbl
      -- Params added for Prospective Rebooking Enhancement
      ,p_prosp_rebook_flag      => l_prosp_rebook_flag
      ,p_rebook_date            => l_rebook_date
      ,p_orig_income_streams    => l_orig_income_streams
    );
    print( l_prog_name, 'After okl_pricing_utils_pvt.compute_bk_yield: ' || lx_return_status);
    IF(lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (lx_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    print( l_prog_name, 'Computed Booking Yield = ' || x_booking_yield );
    print( l_prog_name, 'Copying Termination Value Streams ' );
    -- Termination Value Streams: Copy from l_termination_tbl to x_termination_tbl
    IF l_termination_tbl IS NOT NULL
       AND l_termination_tbl.COUNT > 0
    THEN
      FOR i IN l_termination_tbl.FIRST .. l_termination_tbl.LAST
      LOOP
        x_termination_tbl(i).stream_element_date := l_termination_tbl(i).cf_date;
        x_termination_tbl(i).amount              := l_termination_tbl(i).cf_amount;
        x_termination_tbl(i).se_line_number      := l_termination_tbl(i).line_number;
        print( l_prog_name, x_termination_tbl(i).stream_element_date
               || ' | ' || x_termination_tbl(i).amount
               || ' | ' || x_termination_tbl(i).se_line_number );
      END LOOP;
    END IF;
    print( l_prog_name, 'Copying Pre-Tax Income Streams ' );
    -- Pre-Tax Income Streams   : Copy from l_pre_tax_inc_tbl to x_pre_tax_inc_tbl
    IF l_pre_tax_inc_tbl IS NOT NULL
       AND l_pre_tax_inc_tbl.COUNT > 0
    THEN
      FOR i IN l_pre_tax_inc_tbl.FIRST .. l_pre_tax_inc_tbl.LAST
      LOOP
        x_pre_tax_inc_tbl(i).stream_element_date := l_pre_tax_inc_tbl(i).cf_date;
        x_pre_tax_inc_tbl(i).amount              := l_pre_tax_inc_tbl(i).cf_amount;
        x_pre_tax_inc_tbl(i).se_line_number      := l_pre_tax_inc_tbl(i).line_number;
        print( l_prog_name, x_pre_tax_inc_tbl(i).stream_element_date
               || ' | ' || x_pre_tax_inc_tbl(i).amount
               || ' | ' || x_pre_tax_inc_tbl(i).se_line_number );
      END LOOP;
    END IF;

  x_return_status  :=  lx_return_status;
  print( l_prog_name, 'get_loan_amortization: end' );

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

  END get_loan_amortization;


  ---------------------------------------------------------------------------
  -- Start of Commnets
  -- Badrinath Kuchibholta
  -- Procedure Name       : comp_so_bk_yd
  -- Description          : This Procedure will calculate booking yield if the
  --                        there is a amount given
  -- Business Rules       : We need to consider the asset costfor
  --                        this calculation and also will calculated for
  --                        given contract id and so_payment line
  -- Parameters           : p_khr_id -- contract_id
  --                        p_kle_id -- So_payment line id
  --                        p_target -- only RATE
  -- Version              : 1.0
  -- History              : 15-SEP-2003 BAKUHCIB CREATED for Bug# *****
  -- End of Comments
  ---------------------------------------------------------------------------
  PROCEDURE comp_so_bk_yd(p_api_version    IN  NUMBER,
                          p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2,
                          p_khr_id         IN  NUMBER,
                          p_kle_id         IN  NUMBER,
                          p_target         IN VARCHAR2,
                          p_subside_yn     IN VARCHAR2 DEFAULT 'N',
                          x_booking_yield  OUT NOCOPY NUMBER) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'COMP_SO_BK_YD';
    l_start_date                 DATE := NULL;
    l_end_date                   DATE := NULL;
    l_se_date                    DATE := NULL;
    l_termination_val            NUMBER := NULL;
    l_asset_cost                 NUMBER := NULL;
    l_residual_value             NUMBER := NULL;
    l_days                       NUMBER := NULL;
    l_bk_yield                   NUMBER := 0;
    l_k_end_date                 DATE;
    l_term_complete              VARCHAR2(1) := 'N';
    l_increment                  NUMBER := 0.1;
    l_abs_incr                   NUMBER := NULL;
    l_prev_incr_sign             NUMBER := NULL;
    l_crossed_zero               VARCHAR2(1) := 'N';
    l_diff                       NUMBER := NULL;
    l_prev_diff                  NUMBER := NULL;
    l_prev_diff_sign             NUMBER := NULL;
    i                            NUMBER :=  0;
    j                            NUMBER :=  0;
    k                            NUMBER :=  0;
    m                            NUMBER :=  0;
    ld_res_start_date            DATE;
    ld_asset_start_date          DATE;
    l_subside_yn                 VARCHAR2(1) := NVL(p_subside_yn,'N');

    Cursor khr_type_csr IS
    Select SCS_CODE,
           START_DATE
    From   okc_K_headers_b chr
    Where  chr.id = p_khr_id;

    khr_type_rec khr_type_csr%ROWTYPE;
    l_line_type VARCHAR2(256);

    -- We here get the start date of the first SLL though there are
    -- more than one sll and we look for amount not null
    CURSOR c_rent_slls(p_khr_id okc_k_headers_b.id%TYPE,
                       p_Kle_id okc_k_lines_b.id%TYPE,
		       p_line_type VARCHAR2)
    IS
    SELECT trunc(FND_DATE.canonical_to_date(rul_sll.rule_information2)) start_date,
           NVL(rul_sll.rule_information10, 'Y') arrears_yn,
           khr_so.term_duration
    FROM okc_k_headers_b chr_so,
         okl_k_headers khr_so,
         okc_line_styles_b lse_so,
         okc_k_lines_b cle_so,
         okc_rule_groups_b rgp_pay,
         okc_rules_b rul_slh,
         okc_rules_b rul_sll,
         okl_strm_type_b sty
    WHERE cle_so.id = p_Kle_id
    AND cle_so.dnz_chr_id = p_khr_id
    AND cle_so.lse_id = lse_so.id
    AND cle_so.dnz_chr_id = chr_so.id
    AND khr_so.id = chr_so.id
    AND cle_so.START_DATE = chr_so.START_DATE
    AND lse_so.lty_code = p_line_type --'SO_PAYMENT'
    AND rgp_pay.cle_id = cle_so.id
    AND rgp_pay.dnz_chr_id = cle_so.dnz_chr_id
    AND rgp_pay.rgd_code = 'LALEVL'
    AND rgp_pay.id = rul_slh.rgp_id
    AND rul_slh.rule_information_category = 'LASLH'
    AND TO_CHAR(rul_slh.id) = rul_sll.object2_id1
    AND rul_sll.rule_information_category = 'LASLL'
    AND TO_NUMBER(rul_slh.object1_id1) = sty.id
    AND sty.stream_type_purpose = 'RENT'
    ORDER BY rul_sll.rule_information2;
    -- Since the above SLL information are broken down into
    -- Stream we are good enough to consider first start date of the
    -- SLL
    CURSOR c_rent_flows(p_kle_id okc_k_lines_b.id%TYPE,
                        p_khr_id okc_k_headers_b.id%TYPE,
			p_line_type VARCHAR2)
    IS
    SELECT sel_amt.id se_id,
           sel_amt.amount se_amount,
           trunc(sel_amt.stream_element_date) se_date,
           DECODE(sel_amt.sel_id,NULL,'N','Y') stub,
           sel_amt.comments se_arrears,
           sel_rate.comments payment_missing_yn
    FROM okl_streams stm,
         okl_strm_type_b sty,
         okl_strm_elements sel_amt,
         okl_strm_elements sel_rate,
         okc_k_headers_b chr_so,
         okc_k_lines_b cle,
         okc_line_styles_b lse
    WHERE stm.khr_id = p_khr_id
    AND stm.kle_id = p_kle_id
    AND stm.say_code = 'WORK'
    AND stm.purpose_code = 'FLOW'
    AND stm.sty_id = sty.id
    AND stm.id = sel_amt.stm_id
    AND stm.kle_id = cle.id
    AND cle.dnz_chr_id = chr_so.id
    AND cle.START_DATE = chr_so.START_DATE
    AND cle.lse_id = lse.id
    AND sel_rate.comments = 'N' -- bug# 3381706
    AND lse.lty_code = p_line_type --'SO_PAYMENT'
    AND sel_amt.id = sel_rate.sel_id
    ORDER BY sel_amt.stream_element_date;


    TYPE loan_rec IS RECORD (se_amount NUMBER,
                             se_date DATE,
                             se_days NUMBER,
                             stub_yn  VARCHAR2(3),
                             se_arrears VARCHAR2(1));

    TYPE loan_tbl IS TABLE OF loan_rec INDEX BY BINARY_INTEGER;
    asset_rents        loan_tbl;
    l_rent_sll         c_rent_slls%ROWTYPE;

    l_day_convention_month VARCHAR2(30);
    l_day_convention_year VARCHAR2(30);
    l_days_in_year NUMBER;


  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name ||  ' begin');
      END IF;
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
    IF p_target <> 'PMNT' THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_INVALID_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'Target');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN khr_type_csr;
    FETCH khr_type_csr INTO khr_type_rec;
    CLOSE khr_type_csr;

    IF (INSTR( khr_type_rec.scs_code, 'LEASE') > 0) THEN
        l_line_type := 'FREE_FORM1';
    Else
        l_line_type := 'SO_PAYMENT';
    End If;

   -- Fetch the day convention ..
   OKL_PRICING_UTILS_PVT.get_day_convention(
     p_id              => p_khr_id,
     p_source          => 'ISG',
     x_days_in_month   => l_day_convention_month,
     x_days_in_year    => l_day_convention_year,
     x_return_status   => x_return_status);
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'comp_so_bk_yd Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
   END IF;
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

    -- We are now calucuating Booking Yields
    -- Get the SLL payment info for a kle_id and khr_id
    -- We here get the start date of the first SLL though there are
    -- more than one sll and we look for amount not null
    OPEN  c_rent_slls(p_khr_id => p_khr_id,
                      p_kle_id => p_kle_id,
		      p_line_type => l_line_type);
    FETCH c_rent_slls INTO l_rent_sll;
    IF c_rent_slls%NOTFOUND THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_INVALID_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'khr_id/kle_id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE c_rent_slls;
    l_start_date  :=  l_rent_sll.START_DATE;

    -- Get the stream information for the kle_id and purpose code
    -- So that we build the Asset_rents PL/SQL table.
    -- we can assume the rent flows is expanded picture of SLL payments
    -- Since the above SLL information are broken down into
    -- Stream we are good enough to consider first start date of the
    -- SLL
    FOR  l_rent_flow IN c_rent_flows(p_khr_id => p_khr_id,
                                     p_kle_id => p_kle_id,
				     p_line_type => l_line_type) LOOP
      k := k + 1;
      asset_rents(k).se_days := OKL_PRICING_UTILS_PVT.get_day_count(
                                                         p_start_date    => l_start_date,
                                                         p_days_in_month => l_day_convention_month,
				                         p_days_in_year => l_day_convention_year,
                                                         p_end_date      => l_rent_flow.se_date,
                                                         p_arrears       => l_rent_flow.se_arrears,
                                                         x_return_status => x_return_status);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        EXIT WHEN(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        EXIT WHEN(x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      asset_rents(k).se_amount  :=  l_rent_flow.se_amount;
      asset_rents(k).se_date    :=  l_rent_flow.se_date;
      asset_rents(k).se_arrears :=  l_rent_flow.se_arrears;
      asset_rents(k).stub_yn    :=  l_rent_flow.stub;
      l_start_date  :=  l_rent_flow.se_date;
      IF l_rent_flow.se_arrears = 'Y' THEN
        l_start_date  :=  l_start_date + 1;
      END IF;
    END LOOP;
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Getting the asset cost
    OKL_LA_STREAM_PVT.get_so_asset_oec(
                      p_khr_id        => p_khr_id,
                      p_kle_id        => p_kle_id,
                      p_subside_yn    => l_subside_yn,
                      x_return_status => x_return_status,
                      x_asset_oec     => l_asset_cost,
                      x_start_date    => ld_asset_start_date);
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Getting the Residual value
    OKL_LA_STREAM_PVT.get_so_residual_value(
                      p_khr_id         => p_khr_id,
                      p_kle_id         => p_kle_id,
                      p_subside_yn    => l_subside_yn,
                      x_return_status  => x_return_status,
                      x_residual_value => l_residual_value,
                      x_start_date     => ld_res_start_date);
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name ||  ' cost ' || l_asset_cost || ' residual value ' || l_residual_value);
      END IF;
    l_k_end_date  := (ADD_MONTHS(ld_asset_start_date, l_rent_sll.term_duration) - 1);
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name ||  ' # of payments '||TO_CHAR(asset_rents.COUNT));
      END IF;
    LOOP
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name ||  ' interation # '||TO_CHAR(i));
      END IF;
      i                 :=  i + 1;
      k                 :=  1;
      j                 :=  0;
      m                 :=  0;
      l_start_date      :=  l_rent_sll.START_DATE;
      l_term_complete   := 'N';
      l_termination_val := l_asset_cost;
      LOOP
        j :=  j + 1;
        l_se_date  :=  trunc(asset_rents(k).se_date);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name ||  'l_se_date '||TO_CHAR(l_se_date));
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'l_start_date '||TO_CHAR(l_start_date));
        END IF;
        IF LAST_DAY(l_se_date) <> LAST_DAY(l_start_date) THEN
          l_end_date  :=  LAST_DAY(l_start_date);
          l_days := OKL_PRICING_UTILS_PVT.get_day_count(
                                             p_start_date    => l_start_date,
                                             p_days_in_month => l_day_convention_month,
                                             p_days_in_year => l_day_convention_year,
                                             p_end_date      => l_end_date,
                                             p_arrears       => 'Y',
                                             x_return_status => x_return_status);
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' Status 5 '||x_return_status);
          END IF;
          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            EXIT WHEN(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            EXIT WHEN(x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          l_termination_val            :=  l_termination_val*(1 + l_days*l_bk_yield/360);
          l_se_date := LAST_DAY(l_start_date);
          IF TO_CHAR(LAST_DAY(l_se_date), 'DD') = '31' THEN
            l_se_date  :=  l_se_date - 1;
          END IF;
        ELSE
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' Status 6 '||x_return_status);
          END IF;
          l_end_date := l_se_date;
          l_days := OKL_PRICING_UTILS_PVT.get_day_count(
                                             p_start_date    => l_start_date,
                                             p_days_in_month => l_day_convention_month,
                                             p_days_in_year => l_day_convention_year,
                                             p_end_date      => l_end_date,
                                             p_arrears       => l_rent_sll.arrears_yn,
                                             x_return_status => x_return_status);
          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            EXIT WHEN(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            EXIT WHEN(x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' Status 7 '||x_return_status);
          END IF;
          --IF j = 1 THEN
          --  l_days := 0;
          --END IF;
          l_termination_val            :=  l_termination_val*(1 + l_days*l_bk_yield/360);
          l_termination_val            :=  l_termination_val - asset_rents(k).se_amount;
          IF k = asset_rents.LAST THEN
            l_start_date := l_se_date;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' l_start_date::l_k_end_date '||l_start_date||'::'||l_k_end_date);
            END IF;
            LOOP
              m := m + 1;
              IF trunc(LAST_DAY(l_start_date)) <> trunc(LAST_DAY(l_k_end_date)) THEN
                l_end_date := LAST_DAY(l_start_date);
              ELSE
                l_end_date := l_k_end_date;
              END IF;
              l_days := OKL_PRICING_UTILS_PVT.get_day_count(
                                                 p_start_date    => l_start_date,
                                                 p_days_in_month => l_day_convention_month,
                                                 p_days_in_year => l_day_convention_year,
                                                 p_end_date      => l_end_date,
                                                 p_arrears       => 'Y',
                                                 x_return_status => x_return_status);
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' # of days '||to_char(l_days));
            END IF;
              IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                EXIT WHEN(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
              ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                EXIT WHEN(x_return_status = OKL_API.G_RET_STS_ERROR);
              END IF;
              IF (l_rent_sll.arrears_yn = 'Y') AND (m = 1) THEN
                l_days := l_days - 1;
              END IF;
              l_termination_val := l_termination_val*(1 + l_days*l_bk_yield/360);
              --l_termination_val := l_termination_val*(1 + l_days*l_bk_yield/360);
              IF trunc(l_end_date) = trunc(l_k_end_date) THEN
                l_termination_val := l_termination_val - l_residual_value;
                l_term_complete   := 'Y';
              END IF;
              l_se_date := LAST_DAY(l_start_date);
              IF TO_CHAR(LAST_DAY(l_se_date), 'DD') = '31' THEN
                l_se_date  :=  l_se_date - 1;
              END IF;
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' l_end_date::l_k_end_date '||l_end_date||'::'||l_k_end_date);
              END IF;
              EXIT WHEN TRUNC(l_end_date) = TRUNC(l_k_end_date);
              l_start_date := LAST_DAY(l_start_date) + 1;
              j := j + 1;
            END LOOP;
          ELSE

            IF asset_rents(k).stub_yn = 'Y' AND
               LAST_DAY(asset_rents(k).se_date) = LAST_DAY(asset_rents(k+1).se_date) THEN
              k := k  + 1;
              l_se_date  :=  trunc(asset_rents(k).se_date);
              l_end_date := l_se_date;
              l_days := OKL_PRICING_UTILS_PVT.get_day_count(
                                                 p_start_date    => l_start_date,
                                                 p_days_in_month => l_day_convention_month,
                                                 p_days_in_year => l_day_convention_year,
                                                 p_end_date      => l_end_date,
                                                 p_arrears       => l_rent_sll.arrears_yn,
                                                 x_return_status => x_return_status);
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' Status 9 '||x_return_status);
          END IF;
              IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                EXIT WHEN(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
              ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                EXIT WHEN(x_return_status = OKL_API.G_RET_STS_ERROR);
              END IF;
              l_termination_val            :=  l_termination_val*(1 + l_days*l_bk_yield/360);
              l_termination_val            :=  l_termination_val - asset_rents(k).se_amount;
            END IF;
            l_days := 30 - TO_CHAR(l_end_date, 'DD');
            IF l_days <= 0 THEN
              IF l_rent_sll.arrears_yn = 'Y' THEN
                l_days := 0;
              ELSE
                l_days := 1;
              END IF;
            ELSIF l_rent_sll.arrears_yn = 'N' THEN
              l_days := l_days + 1;
            END IF;
            l_termination_val            :=  l_termination_val*(1 + l_days*l_bk_yield/360);
            l_se_date := LAST_DAY(l_start_date);
            IF TO_CHAR(LAST_DAY(l_se_date), 'DD') = '31' THEN
              l_se_date  :=  l_se_date - 1;
            END IF;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' arrears/advanced '|| l_rent_sll.arrears_yn);
            END IF;
            k := k + 1;
          END IF;
          EXIT WHEN l_term_complete = 'Y';
        END IF;
        l_start_date := LAST_DAY(l_start_date) + 1;
      END LOOP;
      l_diff  :=  l_termination_val;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' changed precision ' || l_bk_yield || '::' || l_diff );
      END IF;
      IF ROUND(l_diff, 5) = 0 THEN
        x_booking_yield  := l_bk_yield;
        EXIT;
      END IF;
      IF SIGN(l_diff) <> SIGN(l_prev_diff) AND l_crossed_zero = 'N' THEN
        l_crossed_zero := 'Y';
      END IF;
      IF l_crossed_zero = 'Y' THEN
        l_abs_incr := ABS(l_increment) / 2;
      ELSE
        l_abs_incr := ABS(l_increment);
      END IF;
      IF i > 1 THEN
        IF SIGN(l_diff) <> l_prev_diff_sign THEN
          IF l_prev_incr_sign = 1 THEN
            l_increment :=  - l_abs_incr;
          ELSE
            l_increment := l_abs_incr;
          END IF;
        ELSE
          IF l_prev_incr_sign = 1 THEN
            l_increment := l_abs_incr;
          ELSE
            l_increment := - l_abs_incr;
          END IF;
        END IF;
      ELSE
        IF SIGN(l_diff) = -1 THEN
          l_increment := l_increment;
        ELSIF SIGN(l_diff) = 1 THEN
          l_increment := -l_increment;
        END IF;
      END IF;
      l_bk_yield        :=  l_bk_yield + l_increment;
      l_prev_incr_sign  :=  SIGN(l_increment);
      l_prev_diff_sign  :=  SIGN(l_diff);
      l_prev_diff       :=  l_diff;
    END LOOP;
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF c_rent_slls%ISOPEN THEN
        CLOSE c_rent_slls;
      END IF;
      IF c_rent_flows%ISOPEN THEN
        CLOSE c_rent_flows;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF c_rent_slls%ISOPEN THEN
        CLOSE c_rent_slls;
      END IF;
      IF c_rent_flows%ISOPEN THEN
        CLOSE c_rent_flows;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
      IF c_rent_slls%ISOPEN THEN
        CLOSE c_rent_slls;
      END IF;
      IF c_rent_flows%ISOPEN THEN
        CLOSE c_rent_flows;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END comp_so_bk_yd;
  ---------------------------------------------------------------------------
  -- Start of Commnets
  -- Badrinath Kuchibholta
  -- Procedure Name       : comp_so_pre_tax_irr
  -- Description          : This Procedure will calculate pre_tax_irr if the
  --                        there is a amount given and also will calculate
  --                        payment amount when a pre_tax_irr is given
  -- Business Rules       : We need to consider the asset cost and fee cost for
  --                        this calculation and also will calculated for
  --                        given contract id and so_payment line
  -- Parameters           : p_khr_id -- contract_id
  --                        p_kle_id -- So_payment line id
  --                        p_target -- Either RATE/PMNT
  -- Version              :1.0
  -- History              : 07-SEP-2003 BAKUHCIB CREATED for Bug# *****
  -- End of Comments
  ---------------------------------------------------------------------------
  PROCEDURE  comp_so_pre_tax_irr(p_api_version    IN  NUMBER,
                                 p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,
                                 p_khr_id         IN NUMBER,
                                 p_kle_id         IN NUMBER,
                                 p_target         IN VARCHAR2,
                                 p_subside_yn     IN VARCHAR2 DEFAULT 'N',
                                 p_interim_tbl    IN interim_interest_tbl_type,
                                 x_payment        OUT NOCOPY NUMBER,
                                 x_rate           OUT NOCOPY NUMBER)
  IS
    l_api_name      CONSTANT VARCHAR2(30) := 'COMP_SO_PRE_IRR';
    i                            BINARY_INTEGER    := 0;
    m                            BINARY_INTEGER := 0;
    n                            BINARY_INTEGER := 0;
    p                            BINARY_INTEGER := 0;
    q                            BINARY_INTEGER := 0;
    r                            BINARY_INTEGER := 0;
    s                            BINARY_INTEGER := 0;
    l_time_zero_cost             NUMBER := 0;
    l_cost                       NUMBER;
    l_adv_payment                NUMBER := 0;
    l_currency_code              VARCHAR2(15);
    l_precision                  NUMBER(1);
    l_cf_dpp                     NUMBER;
    l_cf_ppy                     NUMBER;
    l_cf_amount                  NUMBER;
    l_cf_date                    DATE;
    l_cf_arrear                  VARCHAR2(1);
    l_days_in_future             NUMBER;
    l_periods                    NUMBER;
    l_irr                        NUMBER := 0;
    l_npv_rate                   NUMBER;
    l_npv_pay                    NUMBER;
    l_irr_limit                  NUMBER := NVL(ABS(fnd_profile.value('OKL_PRE_TAX_IRR_LIMIT')), 1000)/100;
    l_prev_npv_pay               NUMBER;
    l_prev_npv_sign_pay          NUMBER;
    l_crossed_zero_pay           VARCHAR2(1) := 'N';
    l_increment_pay              NUMBER := 0.1; -- 10% increment
    l_abs_incr_pay               NUMBER;
    l_prev_incr_sign_pay         NUMBER;
    l_prev_npv_rate              NUMBER;
    l_prev_npv_sign_rate         NUMBER;
    l_crossed_zero_rate          VARCHAR2(1) := 'N';
    l_increment_rate             NUMBER := 0.1; -- 10% increment
    l_abs_incr_rate              NUMBER;
    l_prev_incr_sign_rate        NUMBER;
    l_payment_inflow             NUMBER := 0;
    l_payment_inter              NUMBER := 0;
    l_asset_cost                 NUMBER := 0;
    l_residual_value             NUMBER := 0;
    ld_res_pay_start_date        DATE;
    ld_asset_start_date          DATE;
    l_subside_yn                 VARCHAR2(1) := NVL(p_subside_yn,'N');
    l_khr_start_date             DATE;

    Cursor khr_type_csr IS
    Select SCS_CODE,
           START_DATE
    From   okc_K_headers_b chr
    Where  chr.id = p_khr_id;

    khr_type_rec khr_type_csr%ROWTYPE;
    l_line_type VARCHAR2(256);

    -- Gets all the Payment inflow over the SO_PAYMENT lines and Fee Lines
    CURSOR c_security_deposit
    IS
    SELECT DISTINCT
           sel_amt.id id,
           sel_amt.amount cf_amount,
           sel_amt.stream_element_date cf_date,
           sel_rate.amount rate,
           sel_rate.comments miss_amt,
           sel_amt.comments cf_arrear,
           sty.stream_type_purpose cf_purpose,
           DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
           DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
           chr_so.start_date,
           chr_so.end_date
    FROM okl_streams stm,
         okl_strm_type_b sty,
         okl_strm_elements sel_rate,
         okl_strm_elements sel_amt,
         okc_k_headers_b chr_so,
         okc_k_lines_b cle,
         okl_k_lines kle,
         okc_line_styles_b lse,
         okc_rules_b sll,
         okc_rules_b slh,
         okc_rule_groups_b rgp
    WHERE stm.khr_id = p_khr_id
    --AND stm.kle_id = p_kle_id
    AND stm.say_code = 'WORK'
    AND stm.purpose_code = 'FLOW'
    AND stm.sty_id = sty.id
    AND stm.id = sel_amt.stm_id
    AND sel_amt.comments IS NOT NULL
    AND stm.id = sel_rate.stm_id
    AND sel_rate.sel_id = sel_amt.id
    AND stm.kle_id = cle.id
    AND cle.dnz_chr_id = chr_so.id
    AND kle.id = cle.id
    AND trunc(cle.START_DATE) = trunc(chr_so.START_DATE)
    AND cle.lse_id = lse.id
    AND lse.lty_code = 'FEE'
    AND kle.fee_type = 'SECDEPOSIT'
    AND sty.stream_type_purpose = 'SECURITY_DEPOSIT'
    AND cle.id = rgp.cle_id
    AND rgp.rgd_code = 'LALEVL'
    AND rgp.id = slh.rgp_id
    AND slh.rule_information_category = 'LASLH'
    AND slh.object1_id1 = TO_CHAR(stm.sty_id)
    AND TO_CHAR(slh.id) = sll.object2_id1
    AND sll.rule_information_category = 'LASLL';

    l_security_deposit c_security_deposit%ROWTYPE;

    -- Gets all the Payment inflow over the Fee Lines
    CURSOR c_fee_inflows(p_khr_id NUMBER) IS
    SELECT DISTINCT
           sel_amt.id id,
           sel_amt.amount cf_amount,
           sel_amt.stream_element_date cf_date,
           sel_rate.amount rate,
           sel_rate.comments miss_amt,
           sel_amt.comments cf_arrear,
           sty.stream_type_purpose cf_purpose,
           DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
           DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
           chr_so.start_date,
           lse.lty_code
    FROM okl_streams stm,
         okl_strm_type_b sty,
         okl_strm_elements sel_rate,
         okl_strm_elements sel_amt,
         okc_k_headers_b chr_so,
         okc_k_lines_b cle,
         okl_k_lines kle,
         okc_line_styles_b lse,
         okc_rules_b sll,
         okc_rules_b slh,
         okc_rule_groups_b rgp
    WHERE stm.khr_id = p_khr_id
    AND stm.kle_id = cle.id
    AND stm.kle_id = kle.id
    AND stm.say_code = 'WORK'
    AND stm.purpose_code = 'FLOW'
    AND stm.sty_id = sty.id
    AND stm.id = sel_amt.stm_id
    AND sel_amt.comments IS NOT NULL
    AND stm.id = sel_rate.stm_id
    AND sel_rate.sel_id = sel_amt.id
    AND stm.kle_id = cle.id
    AND kle.id = cle.id
    AND cle.dnz_chr_id = chr_so.id
    AND trunc(cle.START_DATE) = trunc(chr_so.START_DATE)
    AND cle.lse_id = lse.id
    AND lse.lty_code = 'FEE'
    AND kle.fee_type NOT IN ('SECDEPOSIT', 'PASSTHROUGH' )
    AND cle.id = rgp.cle_id
    AND rgp.rgd_code = 'LALEVL'
    AND rgp.id = slh.rgp_id
    AND slh.rule_information_category = 'LASLH'
    AND slh.object1_id1 = TO_CHAR(stm.sty_id)
    AND TO_CHAR(slh.id) = sll.object2_id1
    AND sll.rule_information_category = 'LASLL';

    -- Gets all the Payment inflow over the SO_PAYMENT/FREE_FORM1 lines
    CURSOR c_inflows(p_khr_id NUMBER,
                     p_kle_id NUMBER,
		     p_line_type VARCHAR2)
    IS
    SELECT DISTINCT
           sel_amt.id id,
           sel_amt.amount cf_amount,
           sel_amt.stream_element_date cf_date,
           sel_rate.amount rate,
           sel_rate.comments miss_amt,
           sel_amt.comments cf_arrear,
           sty.stream_type_purpose cf_purpose,
           DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
           DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
           chr_so.start_date
    FROM okl_streams stm,
         okl_strm_type_b sty,
         okl_strm_elements sel_rate,
         okl_strm_elements sel_amt,
         okc_k_headers_b chr_so,
         okc_k_lines_b cle,
         okc_line_styles_b lse,
         okc_rules_b sll,
         okc_rules_b slh,
         okc_rule_groups_b rgp
    WHERE stm.khr_id = p_khr_id
    AND stm.kle_id = p_kle_id
    AND stm.kle_id = cle.id
    AND stm.say_code = 'WORK'
    AND stm.purpose_code = 'FLOW'
    AND stm.sty_id = sty.id
    AND stm.id = sel_amt.stm_id
    AND sel_amt.comments IS NOT NULL
    AND stm.id = sel_rate.stm_id
    AND sel_rate.sel_id = sel_amt.id
    AND stm.kle_id = cle.id
    AND cle.dnz_chr_id = chr_so.id
    AND trunc(cle.START_DATE) = trunc(chr_so.START_DATE)
    AND cle.lse_id = lse.id
    AND lse.lty_code = p_line_type --'SO_PAYMENT'
    AND cle.id = rgp.cle_id
    AND rgp.rgd_code = 'LALEVL'
    AND rgp.id = slh.rgp_id
    AND slh.rule_information_category = 'LASLH'
    AND TO_NUMBER(slh.object1_id1) = stm.sty_id
    AND TO_CHAR(slh.id) = sll.object2_id1
    AND sll.rule_information_category = 'LASLL';
    -- Gets the Asset residual value
    CURSOR c_asset_rvs(p_khr_id NUMBER,
                       p_kle_id NUMBER,
		       p_line_type VARCHAR2)
    IS
    SELECT DISTINCT DECODE(rul_sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
           DECODE(rul_sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
           DECODE(rul_sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) months_per_period,
           cle_so.END_DATE
    FROM okc_k_headers_b chr_so,
         okc_line_styles_b lse_so,
         okc_k_lines_b cle_so,
         okc_rule_groups_b rgp_pay,
         okc_rules_b rul_slh,
         okc_rules_b rul_sll,
         okl_strm_type_b sty
    WHERE cle_so.id = p_kle_id
    AND cle_so.dnz_chr_id = p_khr_id
    AND cle_so.lse_id = lse_so.id
    AND cle_so.dnz_chr_id = chr_so.id
    AND trunc(cle_so.START_DATE) = trunc(chr_so.START_DATE )
    AND lse_so.lty_code = p_line_type --'SO_PAYMENT'
    AND cle_so.id = rgp_pay.cle_id
    AND rgp_pay.dnz_chr_id = cle_so.dnz_chr_id
    AND rgp_pay.rgd_code = 'LALEVL'
    AND rgp_pay.id = rul_slh.rgp_id
    AND rul_slh.rule_information_category = 'LASLH'
    AND TO_CHAR(rul_slh.id) = rul_sll.object2_id1
    AND rul_sll.rule_information_category = 'LASLL'
    AND TO_NUMBER(rul_slh.object1_id1) = sty.id
    AND sty.stream_type_purpose = 'RENT';
    -- to get the fee cost
    CURSOR c_fee_cost(p_khr_id NUMBER)
    IS
    SELECT NVL(kle.amount, 0) amount,
           cle.start_date
    FROM okc_k_headers_b chr_so,
         okl_k_lines kle,
         okc_k_lines_b cle,
         okc_line_styles_b lse
    WHERE cle.chr_id = p_khr_id
    AND cle.lse_id = lse.id
    AND nvl(kle.fee_type, 'XXX') not in ( 'SECDEPOSIT', 'INCOME', 'CAPITALIZED' )
    AND lse.lty_code = 'FEE'
    AND cle.id = kle.id
    AND chr_so.id = cle.dnz_chr_id
    AND trunc(chr_so.START_DATE) = trunc(cle.START_DATE)
    AND NOT EXISTS (SELECT 1
                    FROM okc_rule_groups_b rgp
                    WHERE rgp.cle_id = cle.id
                    AND rgp.rgd_code = 'LAPSTH')
    AND NOT EXISTS (SELECT 1
                    FROM okc_rule_groups_b rgp,
                         okc_rules_b rul,
                         okc_rules_b rul2
                    WHERE rgp.cle_id = cle.id
                    AND rgp.rgd_code = 'LAFEXP'
                    AND rgp.id = rul.rgp_id
                    AND rgp.id = rul2.rgp_id
                    AND rul.rule_information_category = 'LAFEXP'
                    AND rul2.rule_information_category = 'LAFREQ'
                    AND rul.rule_information1 IS NOT NULL
                    AND rul.rule_information2 IS NOT NULL
                    AND rul2.object1_id1 IS NOT NULL);
    -- get Pass through Fee info
    CURSOR c_pass_th(p_khr_id NUMBER)
    IS
    SELECT DISTINCT
           sel_amt.id id,
           sel_amt.amount cf_amount,
           sel_amt.stream_element_date cf_date,
           sel.amount rate,
           sel.comments miss_amt,
           sel.comments cf_arrear,
           sty.stream_type_purpose cf_purpose,
           chr_so.START_DATE,
           DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
           DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
           NVL(TO_NUMBER(laptpr.rule_information1), 100) pass_through_percentage,
           sll.rule_information10 arrears_yn
    FROM okl_streams stm,
         okl_strm_type_b sty,
         okl_strm_elements sel_amt,
         okl_strm_elements sel,
         okc_k_headers_b chr_so,
         okc_k_lines_b cle,
         okc_line_styles_b lse,
         okl_k_lines kle,
         okc_rules_b sll,
         okc_rules_b slh,
         okc_rule_groups_b rgp,
         okc_rule_groups_b rgp2,
         okc_rules_b laptpr
    WHERE stm.khr_id = p_khr_id
    AND stm.say_code = 'WORK'
    AND stm.purpose_code = 'FLOW'
    AND stm.sty_id = sty.id
    AND stm.id = sel.stm_id
    AND sel.comments IS NOT NULL
    AND stm.kle_id = cle.id
    AND cle.lse_id = lse.id
    AND chr_so.id = cle.dnz_chr_id
    AND trunc(chr_so.START_DATE) = trunc(cle.START_DATE)
    AND lse.lty_code = 'FEE'
    AND cle.id = kle.id
    AND stm.id = sel_amt.stm_id
    AND sel_amt.comments IS NOT NULL
    AND stm.id = sel.stm_id
    AND sel.sel_id = sel_amt.id
    AND cle.id = rgp.cle_id
    AND rgp.rgd_code = 'LALEVL'
    AND rgp.id = slh.rgp_id
    AND slh.rule_information_category = 'LASLH'
    AND TO_CHAR(slh.id) = sll.object2_id1
    AND sll.rule_information_category = 'LASLL'
    AND stm.kle_id = rgp2.cle_id
    AND rgp2.rgd_code = 'LAPSTH'
    AND rgp2.id = laptpr.rgp_id
    AND laptpr.rule_information_category = 'LAPTPR';
    -- Get recurring expense streams
    CURSOR c_rec_exp(p_khr_id NUMBER)
    IS
    SELECT TO_NUMBER(rul.rule_information1) periods,
           TO_NUMBER(rul.rule_information2) cf_amount,
           DECODE(rul2.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) cf_dpp,
           DECODE(rul2.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) cf_ppy,
           DECODE(rul2.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) cf_mpp,
           cle.start_date start_date
    FROM okc_rules_b rul,
         okc_rules_b rul2,
         okc_rule_groups_b rgp,
         okc_k_headers_b chr_so,
         okc_k_lines_b cle,
         okc_line_styles_b lse
    WHERE cle.chr_id = p_khr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = 'FEE'
    AND cle.id = rgp.cle_id
    AND rgp.rgd_code = 'LAFEXP'
    AND rgp.id = rul.rgp_id
    AND rgp.id = rul2.rgp_id
    AND rul.rule_information_category = 'LAFEXP'
    AND rul2.rule_information_category = 'LAFREQ'
    AND rul.rule_information1 IS NOT NULL
    AND rul.rule_information2 IS NOT NULL
    AND rul2.object1_id1 IS NOT NULL
    AND cle.dnz_chr_id = chr_so.id
    AND trunc(chr_so.START_DATE) = trunc(cle.START_DATE)
    AND NOT EXISTS (SELECT 1
                    FROM okc_rule_groups_b rgp
                    WHERE rgp.cle_id = cle.id
                    AND rgp.rgd_code = 'LAPSTH');
    -- To get the Currency code and Precision
    CURSOR get_curr_code_pre(p_khr_id NUMBER)
    IS
    SELECT NVL(a.precision,0) precision
    FROM fnd_currencies a,
         okc_k_headers_b b
    WHERE b.currency_code = a.currency_code
    AND b.id = p_khr_id;
    -- To get the Contract Start date
    CURSOR get_start_date(p_khr_id NUMBER)
    IS
    SELECT start_date
    FROM okc_k_headers_b b
    WHERE b.id = p_khr_id;

    TYPE cash_flow_rec_type IS RECORD (cf_amount NUMBER,
                                       cf_date   DATE,
                                       cf_purpose   VARCHAR2(150),
                                       cf_dpp    NUMBER,
                                       cf_ppy    NUMBER,
                                       cf_days   NUMBER,
                                       rate      NUMBER,
                                       miss_amt  okl_strm_elements.comments%TYPE);
    TYPE cash_flow_tbl_type IS TABLE OF cash_flow_rec_type INDEX BY BINARY_INTEGER;
    hdr_inflow_tbl  cash_flow_tbl_type;
    inflow_tbl      cash_flow_tbl_type;
    rv_tbl          cash_flow_tbl_type;
    outflow_tbl     cash_flow_tbl_type;
    pass_th_tbl     cash_flow_tbl_type;
    rec_exp_tbl     cash_flow_tbl_type;

    l_term NUMBER;

    l_day_convention_month VARCHAR2(30);
    l_day_convention_year VARCHAR2(30);
    l_days_in_year NUMBER;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'begin' );

    END IF;
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
    -- check if the target is correctly given
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'check if the target is correctly given' || ' ' || p_target );

    END IF;
    IF p_target NOT IN ('RATE','PMNT') THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_INVALID_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'Target');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'check if the target is correctly given - done');
    END IF;
   -- Fetch the day convention ..
   OKL_PRICING_UTILS_PVT.get_day_convention(
     p_id              => p_khr_id,
     p_source          => 'ISG',
     x_days_in_month   => l_day_convention_month,
     x_days_in_year    => l_day_convention_year,
     x_return_status   => x_return_status);
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'comp_so_pre_tax_irr Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
   END IF;
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
    OPEN  get_start_date(P_khr_id => p_khr_id);
    FETCH get_start_date INTO l_khr_start_date;
    IF get_start_date%NOTFOUND THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE get_start_date;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'got start date');

    END IF;
    -- Summing up Asset cost
    -- And since the input is a so_payment line we sum up the asset's cost
    -- to the so_payment line, assuming the start date of the so_payment
    -- and Asset start date are same.
    OKL_LA_STREAM_PVT.get_so_asset_oec(p_khr_id        => p_khr_id,
                  p_kle_id        => p_kle_id,
                  p_subside_yn    => l_subside_yn,
                  x_return_status => x_return_status,
                  x_asset_oec     => l_cost,
                  x_start_date    => ld_asset_start_date);
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' get_so_asset_oec '|| x_return_status);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' get_so_asset_oec - again '|| x_return_status);
    END IF;
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' l_time_zero '|| x_return_status);
    END IF;
    l_time_zero_cost := l_time_zero_cost + NVL(l_cost, 0);
    -- Summing up Fee cost
    -- Here the fee are attached to the contract header
    -- We do not include, security deposit fee, capiatlized fees, Pass through fee
    -- and also expense fees.
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'before fee cost '|| x_return_status);
    END IF;
    FOR l_fee_cost IN c_fee_cost(p_khr_id => p_khr_id) LOOP
      IF l_fee_cost.start_date IS NOT NULL OR
         l_fee_cost.start_date <> OKL_API.G_MISS_DATE THEN
        l_time_zero_cost := l_time_zero_cost + l_fee_cost.amount;
      END IF;
    END LOOP;

    OPEN khr_type_csr;
    FETCH khr_type_csr INTO khr_type_rec;
    CLOSE khr_type_csr;

    IF (INSTR( khr_type_rec.scs_code, 'LEASE') > 0) THEN
        l_line_type := 'FREE_FORM1';
    Else
        l_line_type := 'SO_PAYMENT';
    End If;

    -- Collecting the inflow amounts
    -- from the strm elements table since where the payment associated to the
    -- So_payment lines are broken into stream elements data
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'before inflows '|| x_return_status);
    END IF;
    FOR l_inflow IN c_inflows(p_khr_id => p_khr_id,
                              p_kle_id => p_kle_id,
			      p_line_type => l_line_type) LOOP
      n := n + 1;
      inflow_tbl(n).cf_amount := l_inflow.cf_amount;
      inflow_tbl(n).miss_amt  := l_inflow.miss_amt;
      inflow_tbl(n).cf_date   := l_inflow.cf_date;
      inflow_tbl(n).cf_purpose   := l_inflow.cf_purpose;
      inflow_tbl(n).cf_dpp    := l_inflow.days_per_period;
      inflow_tbl(n).cf_ppy    := l_inflow.periods_per_year;
      inflow_tbl(n).rate      := l_inflow.rate;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' start date::end date ' || l_inflow.start_date || '::' || l_inflow.cf_date|| x_return_status);
        END IF;
      inflow_tbl(n).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(
                                                          p_start_date    => l_inflow.start_date,
                                                          p_days_in_month => l_day_convention_month,
                                                          p_days_in_year => l_day_convention_year,
                                                          p_end_date      => l_inflow.cf_date,
                                                          p_arrears       => l_inflow.cf_arrear,
                                                          x_return_status => x_return_status);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      IF (inflow_tbl(n).rate IS NULL OR
         inflow_tbl(n).rate = OKL_API.G_MISS_NUM) AND
         p_target = 'RATE' THEN
        OKL_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => G_INVALID_VALUE,
                p_token1        => G_COL_NAME_TOKEN,
                p_token1_value  => 'Rate');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;

    FOR l_inflow IN c_fee_inflows(p_khr_id => p_khr_id ) LOOP

      n := n + 1;
      inflow_tbl(n).cf_amount := l_inflow.cf_amount;
      inflow_tbl(n).miss_amt  := l_inflow.miss_amt;
      inflow_tbl(n).cf_date   := l_inflow.cf_date;
      inflow_tbl(n).cf_purpose   := l_inflow.cf_purpose;
      inflow_tbl(n).cf_dpp    := l_inflow.days_per_period;
      inflow_tbl(n).cf_ppy    := l_inflow.periods_per_year;
      inflow_tbl(n).rate      := l_inflow.rate;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' start date::end date ' || l_inflow.start_date || '::' || l_inflow.cf_date|| x_return_status);
        END IF;
      inflow_tbl(n).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(
                                                          p_start_date    => l_inflow.start_date,
                                                          p_days_in_month => l_day_convention_month,
                                                          p_days_in_year => l_day_convention_year,
                                                          p_end_date      => l_inflow.cf_date,
                                                          p_arrears       => l_inflow.cf_arrear,
                                                          x_return_status => x_return_status);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      IF (inflow_tbl(n).rate IS NULL OR
         inflow_tbl(n).rate = OKL_API.G_MISS_NUM) AND
         p_target = 'RATE' THEN
        OKL_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => G_INVALID_VALUE,
                p_token1        => G_COL_NAME_TOKEN,
                p_token1_value  => 'Rate');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;

    END LOOP;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'after inflows # ' || n|| x_return_status);
    END IF;
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Collecting the Residual Value amount
    -- Here since the Assets are associated to one so_payment line
    -- we sum up to get actual residual value , residual value percent
    -- are stored in rules
    FOR l_asset_rv IN c_asset_rvs(p_khr_id => p_khr_id,
                                  p_kle_id => p_kle_id,
			          p_line_type => l_line_type) LOOP
      p := p + 1;
      OKL_LA_STREAM_PVT.get_so_residual_value(p_khr_id         => p_khr_id,
                         p_kle_id         => p_kle_id,
                         p_subside_yn     => l_subside_yn,
                         x_return_status  => x_return_status,
                         x_residual_value => rv_tbl(p).cf_amount,
                         x_start_date     => ld_res_pay_start_date);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      l_residual_value    := rv_tbl(p).cf_amount;
      rv_tbl(p).cf_date   := l_asset_rv.end_date;
      rv_tbl(p).cf_dpp    := l_asset_rv.days_per_period;
      rv_tbl(p).cf_ppy    := l_asset_rv.periods_per_year;
      OKL_PRICING_PVT.get_rate(p_khr_id        => p_khr_id,
                               p_date          => rv_tbl(p).cf_date,
                               x_rate          => rv_tbl(p).rate,
                               x_return_status => x_return_status);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      IF (rv_tbl(p).rate IS NULL OR
         rv_tbl(p).rate = OKL_API.G_MISS_NUM) AND
         p_target = 'RATE' THEN
        OKL_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => G_INVALID_VALUE,
                p_token1        => G_COL_NAME_TOKEN,
                p_token1_value  => 'Rate');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      rv_tbl(p).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(
                                                      p_start_date    => ld_res_pay_start_date,
                                                      p_days_in_month => l_day_convention_month,
                                                      p_days_in_year => l_day_convention_year,
                                                      p_end_date      => rv_tbl(p).cf_date,
                                                      p_arrears       => 'Y',
                                                      x_return_status => x_return_status);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'after residual values  #' || p|| x_return_status);
    END IF;
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Collecting the Outflow amounts of Fee
    -- Here the fee are attached to the contract header
    -- We do not include, security deposit fee, capiatlized fees, Pass through fee
    -- and also expense fees.
    FOR l_outflow IN c_fee_cost(p_khr_id => p_khr_id) LOOP
      IF l_outflow.start_date > l_khr_start_date THEN
        q := q + 1;
        outflow_tbl(q).cf_amount := -(l_outflow.amount);
        outflow_tbl(q).cf_date   := l_outflow.start_date;
        outflow_tbl(q).cf_dpp    := 1;
        outflow_tbl(q).cf_ppy    := 360;
        OKL_PRICING_PVT.get_rate(p_khr_id        => p_khr_id,
                                 p_date          => outflow_tbl(q).cf_date,
                                 x_rate          => outflow_tbl(q).rate,
                                 x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        IF (outflow_tbl(q).rate IS NULL OR
           outflow_tbl(q).rate = OKL_API.G_MISS_NUM) AND
          p_target = 'RATE' THEN
          OKL_API.set_message(
                  p_app_name      => G_APP_NAME,
                  p_msg_name      => G_INVALID_VALUE,
                  p_token1        => G_COL_NAME_TOKEN,
                  p_token1_value  => 'Rate');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        outflow_tbl(q).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(
                                                             p_start_date    => l_outflow.start_date,
                                                             p_days_in_month => l_day_convention_month,
                                                             p_days_in_year => l_day_convention_year,
                                                             p_end_date      => l_outflow.start_date,
                                                             p_arrears       => 'N',
                                                             x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
      END IF;
    END LOOP;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'after outflows  ' || q|| x_return_status);
    END IF;
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Collecting the Outflow amounts of asset
    -- Since we are summing up to the so_payment line
    -- We would have one asset cost
    IF ld_asset_start_date > l_khr_start_date THEN
      q := q + 1;
      OKL_LA_STREAM_PVT.get_so_asset_oec(
                        p_khr_id        => p_khr_id,
                        p_kle_id        => p_kle_id,
                        p_subside_yn    => l_subside_yn,
                        x_return_status => x_return_status,
                        x_asset_oec     => outflow_tbl(q).cf_amount,
                        x_start_date    => ld_asset_start_date);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      outflow_tbl(q).cf_amount := -(outflow_tbl(q).cf_amount);
      outflow_tbl(q).cf_date   := ld_asset_start_date;
      outflow_tbl(q).cf_dpp    := 1;
      outflow_tbl(q).cf_ppy    := 360;
      OKL_PRICING_PVT.get_rate(p_khr_id        => p_khr_id,
                               p_date          => outflow_tbl(q).cf_date,
                               x_rate          => outflow_tbl(q).rate,
                               x_return_status => x_return_status);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (outflow_tbl(q).rate IS NULL OR
          outflow_tbl(q).rate = OKL_API.G_MISS_NUM) AND
        p_target = 'RATE' THEN
        OKL_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => G_INVALID_VALUE,
                p_token1        => G_COL_NAME_TOKEN,
                p_token1_value  => 'Rate');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      outflow_tbl(q).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(
                                                           p_start_date    => ld_asset_start_date,
                                                           p_days_in_month => l_day_convention_month,
                                                           p_days_in_year => l_day_convention_year,
                                                           p_end_date      => ld_asset_start_date,
                                                           p_arrears       => 'N',
                                                           x_return_status => x_return_status);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- Collecting Pass-through Amounts
    FOR l_pass_th IN c_pass_th(p_khr_id => p_khr_id) LOOP

     If ( l_pass_th.pass_through_percentage < 100 ) Then

      r := r + 1;
      pass_th_tbl(r).cf_amount := l_pass_th.cf_amount*(1 - l_pass_th.pass_through_percentage/100);
      pass_th_tbl(r).cf_date   := l_pass_th.cf_date;
      pass_th_tbl(r).cf_purpose   := l_pass_th.cf_purpose;
      pass_th_tbl(r).cf_dpp    := l_pass_th.days_per_period;
      pass_th_tbl(r).cf_ppy    := l_pass_th.periods_per_year;
      pass_th_tbl(r).rate      := l_pass_th.rate;
      IF (pass_th_tbl(r).rate IS NULL OR
         pass_th_tbl(r).rate = OKL_API.G_MISS_NUM) AND
         p_target = 'RATE' THEN
        OKL_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => G_INVALID_VALUE,
                p_token1        => G_COL_NAME_TOKEN,
                p_token1_value  => 'Rate');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      pass_th_tbl(r).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(
                                                           p_start_date    => l_pass_th.start_date,
                                                           p_days_in_month => l_day_convention_month,
                                                           p_days_in_year => l_day_convention_year,
                                                           p_end_date      => l_pass_th.cf_date,
                                                           p_arrears       => l_pass_th.arrears_yn,
							                           --l_pass_th.cf_arrear,
                                                           x_return_status => x_return_status);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;

     END If;

    END LOOP;
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Collecting Reccuring Amounts
    FOR l_rec_exp IN c_rec_exp(p_khr_id => p_khr_id) LOOP
      FOR s1 in 1..l_rec_exp.periods LOOP
        s := s + 1;
        rec_exp_tbl(s).cf_amount := -(l_rec_exp.cf_amount);
        rec_exp_tbl(s).cf_date   := ADD_MONTHS(l_rec_exp.start_date, (s1 -1)*l_rec_exp.cf_mpp);
        rec_exp_tbl(s).cf_dpp    :=  l_rec_exp.cf_dpp;
        rec_exp_tbl(s).cf_ppy    :=  l_rec_exp.cf_ppy;
        OKL_PRICING_PVT.get_rate(p_khr_id        => p_khr_id,
                                 p_date          =>l_rec_exp.start_date,
                                 x_rate          => rec_exp_tbl(s).rate,
                                 x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        IF (rec_exp_tbl(s).rate IS NULL OR
           rec_exp_tbl(s).rate = OKL_API.G_MISS_NUM) AND
           p_target = 'RATE' THEN
          OKL_API.set_message(
                  p_app_name      => G_APP_NAME,
                  p_msg_name      => G_INVALID_VALUE,
                  p_token1        => G_COL_NAME_TOKEN,
                  p_token1_value  => 'Rate');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        rec_exp_tbl(s).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(
                                                             p_start_date    => l_rec_exp.start_date,
                                                             p_days_in_month => l_day_convention_month,
                                                             p_days_in_year => l_day_convention_year,
                                                             p_end_date      => rec_exp_tbl(s).cf_date,
                                                             p_arrears       => 'N',
                                                             x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
      END LOOP;
    END LOOP;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'after expenses  '|| x_return_status);
    END IF;
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validating Sum of all the inflow do not exceed the Total Time zero cost
    IF n > 0 THEN
      FOR n1 IN inflow_tbl.FIRST..inflow_tbl.LAST LOOP
        IF inflow_tbl(n1).cf_date <= ld_asset_start_date THEN
          l_adv_payment  :=  l_adv_payment + inflow_tbl(n1).cf_amount;
        END IF;
      END LOOP;
    END IF;
    IF r > 0 THEN
      FOR r1 IN pass_th_tbl.FIRST..pass_th_tbl.LAST LOOP
        IF pass_th_tbl(r1).cf_date <= ld_asset_start_date THEN
          l_adv_payment  :=  l_adv_payment + pass_th_tbl(r1).cf_amount;
        END IF;
      END LOOP;
    END IF;
    IF l_adv_payment >= l_time_zero_cost THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_IRR_CALC_INF_LOOP',
                           p_token1       => 'ADV_AMOUNT',
                           p_token1_value => l_adv_payment,
                           p_token2       => 'CAPITAL_AMOUNT',
                           p_token2_value => l_time_zero_cost);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To get the Currency code and Precision
    OPEN  get_curr_code_pre(p_khr_id => p_khr_id);
    FETCH get_curr_code_pre INTO l_precision;
    IF get_curr_code_pre%NOTFOUND THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'Currency Code ');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE get_curr_code_pre;
    -- Setting the IRR limit
    l_irr_limit := ROUND(NVL(ABS(fnd_profile.value('OKL_PRE_TAX_IRR_LIMIT')), 1000), 0)/100;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'l_irr_limit  ' ||l_irr_limit);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'b4 getting into the loop  '|| x_return_status);
    END IF;
    LOOP
      i                 :=  i + 1;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' ### ITERATION ### | ### PVALUE ### | ### IRR ###  ');
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || i || ' | ' || l_npv_rate || ' | ' || l_irr);
      END IF;
      l_npv_rate        :=  -(l_time_zero_cost);
      l_npv_pay         :=  -(l_time_zero_cost);

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' time zero : ' || l_npv_pay );

    END IF;
      -------------------------------------------
      -- FEE COST CASH OUTFLOWS
      -------------------------------------------
      IF q > 0 THEN
        FOR w IN outflow_tbl.FIRST..outflow_tbl.LAST LOOP
          l_cf_dpp          :=  outflow_tbl(w).cf_dpp;
          l_cf_ppy          :=  outflow_tbl(w).cf_ppy;
          l_cf_amount       :=  outflow_tbl(w).cf_amount;
          l_cf_date         :=  outflow_tbl(w).cf_date;
          l_days_in_future  :=  outflow_tbl(w).cf_days;
          l_periods         :=  l_days_in_future / l_cf_dpp;
          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' ZERO divide outflows '|| x_return_status);
            END IF;
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          IF p_target = 'RATE' THEN
            l_npv_pay  := l_npv_pay + (l_cf_amount / POWER((1 + outflow_tbl(w).rate/(l_cf_ppy*100)), l_periods));
          ELSIF p_target = 'PMNT' THEN
            l_npv_rate := l_npv_rate + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));
          END IF;
        END LOOP;
      END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' outflow : ' || l_npv_pay );
    END IF;
      -------------------------------------------
      -- PASSTHROUGH CASH INFLOWS
      -------------------------------------------
      IF r > 0 THEN
        FOR v IN pass_th_tbl.FIRST..pass_th_tbl.LAST LOOP
          l_cf_dpp          :=  pass_th_tbl(v).cf_dpp;
          l_cf_ppy          :=  pass_th_tbl(v).cf_ppy;
          l_cf_amount       :=  pass_th_tbl(v).cf_amount;
          l_cf_date         :=  pass_th_tbl(v).cf_date;
          l_days_in_future  :=  pass_th_tbl(v).cf_days;
          l_periods         :=  l_days_in_future / l_cf_dpp;
          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN
          --IF (l_irr/l_cf_ppy = -1) THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' ZERO divide passthru '|| x_return_status);
            END IF;
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;

          IF p_target = 'RATE' THEN
            l_npv_pay  := l_npv_pay + (l_cf_amount / POWER((1 + pass_th_tbl(v).rate/(l_cf_ppy*100)), l_periods));
          ELSIF p_target = 'PMNT' THEN
            l_npv_rate := l_npv_rate + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));
          END IF;
        END LOOP;
      END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' pass thru : ' || l_npv_pay );

    END IF;
      -------------------------------------------
      -- FEE RECURRING EXPENSE CASH OUTFLOWS
      -------------------------------------------
      IF s > 0 THEN
        FOR t IN rec_exp_tbl.FIRST..rec_exp_tbl.LAST LOOP
          l_cf_ppy          :=  rec_exp_tbl(t).cf_ppy;
          l_cf_dpp          :=  rec_exp_tbl(t).cf_dpp;
          l_cf_amount       :=  rec_exp_tbl(t).cf_amount;
          l_cf_date         :=  rec_exp_tbl(t).cf_date;
          l_days_in_future  :=  rec_exp_tbl(t).cf_days;
          l_periods         :=  l_days_in_future / l_cf_dpp;
          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' ZERO divide expenses '|| x_return_status);
            END IF;
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          IF p_target = 'RATE' THEN
            l_npv_pay := l_npv_pay + (l_cf_amount / POWER((1 + rec_exp_tbl(t).rate/(l_cf_ppy*100)), l_periods));
          ELSIF p_target = 'PMNT' THEN
            l_npv_rate := l_npv_rate + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));
          END IF;
        END LOOP;
      END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' exp : ' || l_npv_pay );
    END IF;
      -------------------------------------------
      -- RV CASH INFLOWS
      -------------------------------------------
      IF p > 0 THEN
        FOR z IN rv_tbl.FIRST..rv_tbl.LAST LOOP
          l_cf_dpp          :=  rv_tbl(z).cf_dpp;
          l_cf_ppy          :=  rv_tbl(z).cf_ppy;
          l_cf_amount       :=  rv_tbl(z).cf_amount;
          l_cf_date         :=  rv_tbl(z).cf_date;
          l_days_in_future  :=  rv_tbl(z).cf_days;
          l_periods         :=  l_days_in_future / l_cf_dpp;
          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' ZERO divide rvs '|| x_return_status);
            END IF;
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          IF p_target = 'RATE' THEN
            l_npv_pay := l_npv_pay + (l_cf_amount  / POWER((1 + rv_tbl(z).rate/(l_cf_ppy*100)), l_periods));
          ELSIF p_target = 'PMNT' THEN
            l_npv_rate := l_npv_rate + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));
          END IF;
        END LOOP;
      END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' rv : ' || l_npv_pay );
    END IF;
      ----------------------------------------------
      -- SECURITY DEPOSIT
      ----------------------------------------------
      OPEN c_security_deposit;
      FETCH c_security_deposit INTO l_security_deposit;
      If ( c_security_deposit%FOUND ) Then

          l_days_in_future  :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => l_khr_start_date,
                                                                       p_days_in_month => l_day_convention_month,
                                                                       p_days_in_year => l_day_convention_year,
                                                                       p_end_date      => l_security_deposit.cf_date,
                                                                       p_arrears       => 'N' ,
                                                                       x_return_status => x_return_status);

          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          l_periods := l_days_in_future / l_security_deposit.days_per_period;
          IF p_target = 'RATE' THEN
              l_npv_pay     := l_npv_pay +
	  (l_security_deposit.cf_amount/POWER((1+l_security_deposit.rate/l_security_deposit.periods_per_year),l_periods));
          ELSIF p_target = 'PMNT' THEN
              l_npv_rate     := l_npv_rate +
	  (l_security_deposit.cf_amount / POWER((1 + l_irr/l_security_deposit.periods_per_year), l_periods));
	  End If;

          l_days_in_future  :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => l_khr_start_date,
                                                                       p_days_in_month => l_day_convention_month,
                                                                       p_days_in_year => l_day_convention_year,
                                                                       p_end_date      => l_security_deposit.end_date,
                                                                       p_arrears       => 'N' ,
                                                                       x_return_status => x_return_status);

          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          l_periods := l_days_in_future / l_security_deposit.days_per_period;
          IF p_target = 'RATE' THEN
              l_npv_pay     := l_npv_pay -
	  (l_security_deposit.cf_amount/POWER((1+l_security_deposit.rate/l_security_deposit.periods_per_year),l_periods));
          ELSIF p_target = 'PMNT' THEN
              l_npv_rate     := l_npv_rate -
	  (l_security_deposit.cf_amount / POWER((1 + l_irr/l_security_deposit.periods_per_year), l_periods));
	  End If;

      END If;
      CLOSE c_security_deposit;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' sec dep : ' || l_npv_pay );
    END IF;
      -------------------------------------------
      -- LINE LEVEL CASH INFLOWS
      -------------------------------------------
  IF p_target = 'RATE' THEN
        l_term := 0;
        FOR y IN inflow_tbl.FIRST..inflow_tbl.LAST
	LOOP
          l_cf_dpp          :=  inflow_tbl(y).cf_dpp;
          l_cf_ppy          :=  inflow_tbl(y).cf_ppy;
          l_days_in_future  :=  inflow_tbl(y).cf_days;
          l_periods         :=  l_days_in_future / l_cf_dpp;
          IF inflow_tbl(y).miss_amt = 'Y' THEN
            l_term     :=  l_term + (1  / POWER((1 + inflow_tbl(y).rate/(l_cf_ppy*100)), l_periods));
          ELSIF inflow_tbl(y).miss_amt = 'N'  THEN
            l_cf_amount       :=  inflow_tbl(y).cf_amount;
            l_cf_date         :=  inflow_tbl(y).cf_date;
            IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN
              OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                   p_msg_name     => 'OKL_IRR_ZERO_DIV');
              x_return_status := OKL_API.G_RET_STS_ERROR;
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' ZERO divide indlows '|| x_return_status);
              END IF;
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
            END IF;
            l_npv_pay := l_npv_pay + (l_cf_amount  / POWER((1 + inflow_tbl(y).rate/(l_cf_ppy*100)), l_periods));
	  END IF;
        END LOOP;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' inflo  : ' || l_npv_pay );
    END IF;
	If (l_term <> 0 ) Then
	    l_payment_inflow := (-1 * l_npv_pay ) / l_term;
	else
              OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                   p_msg_name     => 'OKL_IRR_ZERO_DIV');
              x_return_status := OKL_API.G_RET_STS_ERROR;
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' ZERO divide indlows '|| x_return_status);
              END IF;
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        end if;

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' l_npv_pay ' || l_npv_pay );
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' l_term ' || l_term );

              END IF;
	l_npv_pay := 0;

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' l_payment_inflow ' || l_payment_inflow );
              END IF;
  Else

      IF n > 0 THEN
        FOR y IN inflow_tbl.FIRST..inflow_tbl.LAST LOOP
          l_cf_dpp          :=  inflow_tbl(y).cf_dpp;
          l_cf_ppy          :=  inflow_tbl(y).cf_ppy;
          IF inflow_tbl(y).miss_amt = 'Y' AND p_target = 'RATE' THEN
            l_cf_amount     :=  l_payment_inflow;
          ELSIF inflow_tbl(y).miss_amt = 'N'  THEN
            l_cf_amount     :=  inflow_tbl(y).cf_amount;
          END IF;
          l_cf_date         :=  inflow_tbl(y).cf_date;
          l_days_in_future  :=  inflow_tbl(y).cf_days;
          l_periods         :=  l_days_in_future / l_cf_dpp;
          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' ZERO divide indlows '|| x_return_status);
            END IF;
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          IF p_target = 'RATE' THEN
            l_npv_pay := l_npv_pay + (l_cf_amount  / POWER((1 + inflow_tbl(y).rate/(l_cf_ppy*100)), l_periods));
          ELSIF p_target = 'PMNT' THEN
            l_npv_rate := l_npv_rate + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));
          END IF;
        END LOOP;
      END IF;

  End If;

      IF p_target = 'RATE' THEN
        IF ROUND(l_npv_pay, l_precision+4) = 0 THEN
          x_payment    := l_payment_inflow;
          EXIT;
        END IF;
      ELSIF p_target = 'PMNT' THEN
        IF ROUND(l_npv_rate, l_precision+4) = 0 THEN
          x_rate    := l_irr;
          EXIT;
        END IF;
      END IF;
      IF p_target = 'RATE' THEN
        IF SIGN(l_npv_pay) <> SIGN(l_prev_npv_pay) AND l_crossed_zero_pay = 'N' THEN
          l_crossed_zero_pay := 'Y';
        END IF;
        IF l_crossed_zero_pay = 'Y' THEN
          l_abs_incr_pay := ABS(l_increment_pay) / 2;
        ELSE
          l_abs_incr_pay := ABS(l_increment_pay);
        END IF;
        IF i > 1 THEN
          IF SIGN(l_npv_pay) <> l_prev_npv_sign_pay THEN
            IF l_prev_incr_sign_pay = 1 THEN
              l_increment_pay := - l_abs_incr_pay;
            ELSE
              l_increment_pay := l_abs_incr_pay;
            END IF;
          ELSE
            IF l_prev_incr_sign_pay = 1 THEN
              l_increment_pay := l_abs_incr_pay;
            ELSE
              l_increment_pay := - l_abs_incr_pay;
            END IF;
          END IF;
        ELSE
          IF SIGN(l_npv_pay) = -1 THEN
            l_increment_pay := l_increment_pay;
          ELSIF SIGN(l_npv_pay) = 1 THEN
            l_increment_pay := -l_increment_pay;
          END IF;
        END IF;
        l_payment_inflow  := l_payment_inflow + l_increment_pay;
        l_prev_incr_sign_pay  :=  SIGN(l_increment_pay);
        l_prev_npv_sign_pay   :=  SIGN(l_npv_pay);
        l_prev_npv_pay        :=  l_npv_pay;
      ELSIF p_target = 'PMNT' THEN
        IF SIGN(l_npv_rate) <> SIGN(l_prev_npv_rate) AND l_crossed_zero_rate = 'N' THEN
          l_crossed_zero_rate := 'Y';
        END IF;
        IF l_crossed_zero_rate = 'Y' THEN
          l_abs_incr_rate := ABS(l_increment_rate) / 2;
        ELSE
          l_abs_incr_rate := ABS(l_increment_rate);
        END IF;
        IF i > 1 THEN
          IF SIGN(l_npv_rate) <> l_prev_npv_sign_rate THEN
            IF l_prev_incr_sign_rate = 1 THEN
              l_increment_rate := - l_abs_incr_rate;
            ELSE
              l_increment_rate := l_abs_incr_rate;
            END IF;
          ELSE
            IF l_prev_incr_sign_rate = 1 THEN
              l_increment_rate := l_abs_incr_rate;
            ELSE
              l_increment_rate := - l_abs_incr_rate;
            END IF;
          END IF;
        ELSE
          IF SIGN(l_npv_rate) = -1 THEN
            l_increment_rate :=  -l_increment_rate;
          END IF;
        END IF;
        l_irr             :=  l_irr + l_increment_rate;
        IF ABS(l_irr) > l_irr_limit THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_IRR_CALC_IRR_LIMIT',
                               p_token1       => 'IRR_LIMIT',
                               p_token1_value => l_irr_limit*100);
          x_return_status := OKL_API.G_RET_STS_ERROR;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' 100000%  '|| x_return_status);
            END IF;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        l_prev_incr_sign_rate  :=  SIGN(l_increment_rate);
        l_prev_npv_sign_rate   :=  SIGN(l_npv_rate);
        l_prev_npv_rate        :=  l_npv_rate;
      END IF;
    END LOOP;
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF get_curr_code_pre%ISOPEN THEN
        CLOSE get_curr_code_pre;
      END IF;
      IF c_rec_exp%ISOPEN THEN
        CLOSE c_rec_exp;
      END IF;
      IF c_pass_th%ISOPEN THEN
        CLOSE c_pass_th;
      END IF;
      IF c_fee_cost%ISOPEN THEN
        CLOSE c_fee_cost;
      END IF;
      IF c_asset_rvs%ISOPEN THEN
        CLOSE c_asset_rvs;
      END IF;
      IF c_inflows%ISOPEN THEN
        CLOSE c_inflows;
      END IF;
      IF get_start_date%ISOPEN THEN
        CLOSE get_start_date;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF get_curr_code_pre%ISOPEN THEN
        CLOSE get_curr_code_pre;
      END IF;
      IF c_rec_exp%ISOPEN THEN
        CLOSE c_rec_exp;
      END IF;
      IF c_pass_th%ISOPEN THEN
        CLOSE c_pass_th;
      END IF;
      IF c_fee_cost%ISOPEN THEN
        CLOSE c_fee_cost;
      END IF;
      IF c_asset_rvs%ISOPEN THEN
        CLOSE c_asset_rvs;
      END IF;
      IF c_inflows%ISOPEN THEN
        CLOSE c_inflows;
      END IF;
      IF get_start_date%ISOPEN THEN
        CLOSE get_start_date;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
      IF get_curr_code_pre%ISOPEN THEN
        CLOSE get_curr_code_pre;
      END IF;
      IF c_rec_exp%ISOPEN THEN
        CLOSE c_rec_exp;
      END IF;
      IF c_pass_th%ISOPEN THEN
        CLOSE c_pass_th;
      END IF;
      IF c_fee_cost%ISOPEN THEN
        CLOSE c_fee_cost;
      END IF;
      IF c_asset_rvs%ISOPEN THEN
        CLOSE c_asset_rvs;
      END IF;
      IF c_inflows%ISOPEN THEN
        CLOSE c_inflows;
      END IF;
      IF get_start_date%ISOPEN THEN
        CLOSE get_start_date;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END comp_so_pre_tax_irr;



  ---------------------------------------------------------------------------
  -- PROCEDURE compute_irr
  --
  -- Description
  --
  ---------------------------------------------------------------------------
  PROCEDURE  compute_irr (p_khr_id          IN  NUMBER,
                          p_start_date      IN  DATE,
                          p_term_duration   IN  NUMBER,
                          p_interim_tbl     IN  interim_interest_tbl_type,
			  p_subsidies_yn    IN  VARCHAR2,
			  p_initial_irr     IN  NUMBER,
                          x_irr             OUT NOCOPY NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2) IS

    CURSOR c_hdr_inflows IS
      SELECT DISTINCT
             sel.id id,
             sel.amount cf_amount,
             sel.stream_element_date cf_date,
             sel.comments cf_arrear,
             sty.stream_type_purpose cf_purpose,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
             DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year
      FROM   okl_streams stm,
             okl_strm_type_b sty,
             okl_strm_elements sel,
             okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp
      WHERE  stm.khr_id = p_khr_id
        AND  stm.say_code = 'WORK'
        AND  stm.purpose_code IS NULL
        AND  stm.sty_id = sty.id
        AND  stm.id = sel.stm_id
        AND  sel.comments IS NOT NULL
        AND  stm.khr_id = rgp.dnz_chr_id
        AND  rgp.cle_id IS NULL
        AND  rgp.rgd_code = 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  slh.object1_id1 = TO_CHAR(stm.sty_id)
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL';

    Cursor c_link_pmnts( chrId NUMBER, kleId NUMBER ) IS
    Select 'Y' What
    from dual
    Where Exists(Select crl.id slh_id
                 From   OKC_RULE_GROUPS_B crg,
                        OKC_RULES_B crl,
			okc_K_lines_b cle_lnk,
			okl_K_lines kle_roll
                 Where  crl.rgp_id = crg.id
                     and crg.RGD_CODE = 'LALEVL'
                     and crl.RULE_INFORMATION_CATEGORY = 'LASLL'
                     and crg.dnz_chr_id = chrId
                     and crg.cle_id = kleId
	             and crg.cle_id = cle_lnk.id
		     and cle_lnk.cle_id = kle_roll.id
		     and kle_roll.fee_type in ('MISCELLANEOUS', 'FINANCED', 'ROLLOVER', 'PASSTHROUGH'));

    r_link_pmnts c_link_pmnts%ROWTYPE;

    CURSOR c_inflows IS
      SELECT DISTINCT
             sel.id id,
             sel.amount cf_amount,
             sel.stream_element_date cf_date,
             sel.comments cf_arrear,
             sty.stream_type_purpose cf_purpose,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
             DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
	     cle.id kleId,
	     lse.lty_code
      FROM   okl_streams stm,
             okl_strm_type_b sty,
             okl_strm_elements sel,
             okc_k_lines_b cle,
             okc_line_styles_b lse,
             okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp
      WHERE  stm.khr_id = p_khr_id
        AND  stm.say_code = 'WORK'
        AND  stm.purpose_code IS NULL
        AND  stm.sty_id = sty.id
	AND  sty.stream_type_purpose NOT LIKE 'ESTIMATED_PROPERTY_TAX'
        AND  stm.id = sel.stm_id
        AND  sel.comments IS NOT NULL
        AND  stm.kle_id = cle.id
        AND  NOT EXISTS (SELECT 1
                         FROM   okc_rule_groups_b rgp2
                         WHERE  rgp2.dnz_chr_id = p_khr_id
                           AND  rgp2.cle_id = cle.id
                           AND  rgp2.rgd_code = 'LAPSTH')
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.lse_id = lse.id
        AND  lse.lty_code IN ('FREE_FORM1', 'FEE', 'LINK_FEE_ASSET')
        AND  cle.id = rgp.cle_id
        AND  rgp.rgd_code = 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  slh.object1_id1 = TO_CHAR(stm.sty_id)
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL';

    -- Cursor definition implies RENT must be defined at Asset Level

    CURSOR c_asset_rvs IS
      SELECT DISTINCT
             kle.id,
             NVL(kle.residual_value, 0) cf_amount,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
             DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
             DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) months_per_period,
             cle.start_date,
	     cle.date_terminated,
	     cle.sts_code
      FROM   okl_k_lines kle,
             okc_k_lines_b cle,
             okc_line_styles_b lse,
             okc_rule_groups_b rgp,
             okc_rules_b slh,
             okc_rules_b sll,
             okl_strm_type_b  styt
      WHERE  cle.chr_id = p_khr_id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.lse_id = lse.id
        AND  lse.lty_code = 'FREE_FORM1'
        AND  cle.id = kle.id
        AND  kle.id = rgp.cle_id
        AND  rgp.rgd_code = 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
        AND  slh.object1_id1 = TO_CHAR(styt.id)
        AND  styt.stream_type_purpose = 'RENT';

    CURSOR c_deposit_date IS
      SELECT FND_DATE.canonical_to_date(rule_information5)
      FROM   okc_rules_b
      WHERE  dnz_chr_id  = p_khr_id
        AND  rule_information_category = 'LASDEP';

/*    CURSOR c_asset_cost IS
      SELECT cle.id id,
             cle.start_date start_date,
	     kle.capital_amount,
	     kle.capitalized_interest,
	     kle.date_funding_expected
      FROM   okc_k_lines_b cle,
             okl_K_lines kle,
             okc_line_styles_b lse
      WHERE  cle.chr_id = p_khr_id
        AND  cle.id = kle.id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.lse_id = lse.id
        AND  lse.lty_code = 'FREE_FORM1';
*/
    -- Bug 5287279 : 08-Jun-2006 : kbbhavsa
    --  c_asset_cost cursor modified by including distinct
    CURSOR c_asset_cost IS
      SELECT DISTINCT cle.id id,
             cle.start_date start_date,
             kle.capital_amount,
             kle.capitalized_interest,
	           kle.date_funding_expected,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
             DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
             DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) months_per_period,
             cle.date_terminated,
             cle.sts_code
      FROM   okl_k_lines kle,
             okc_k_lines_b cle,
             okc_line_styles_b lse,
             okc_rule_groups_b rgp,
             okc_rules_b slh,
             okc_rules_b sll,
             okl_strm_type_b sty
      WHERE  cle.chr_id = p_khr_id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED') -- Bug 5011438
        AND  cle.lse_id = lse.id
        AND  lse.lty_code = 'FREE_FORM1'
        AND  cle.id = kle.id
        AND  kle.id = rgp.cle_id
        AND  rgp.rgd_code = 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
        AND  slh.object1_id1 = TO_CHAR(sty.id)
        AND  sty.stream_type_purpose = 'RENT';
    --Modified by dkagrawa on 06-Oct-2005 for Bug 4654516
    --Added the nvl check to the capitalise_yn flag
    CURSOR c_fee_cost IS
      SELECT NVL(kle.amount, 0) amount,
             cle.start_date,
	     cle.id kleId,
	     lse.lty_code
      FROM   okl_k_lines kle,
             okc_k_lines_b cle,
             okc_line_styles_b lse,
             okc_k_items cim,
             okl_strm_type_b sty
      WHERE  cle.chr_id = p_khr_id
        AND  cle.lse_id = lse.id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
	AND  kle.fee_type not in ( 'SECDEPOSIT', 'INCOME' )
        AND  lse.lty_code in ( 'FEE', 'LINK_FEE_ASSET')
        AND  cle.id = kle.id
        AND  cle.id = cim.cle_id
        AND  cim.jtot_object1_code = 'OKL_STRMTYP'
        AND  cim.object1_id1 = sty.id
        AND  sty.version = '1.0'
        AND  NVL(sty.capitalize_yn,'N') <> 'Y'
        AND  NOT EXISTS (SELECT 1
                         FROM   okc_rule_groups_b rgp
                         WHERE  rgp.cle_id = cle.id
                           AND  rgp.rgd_code = 'LAPSTH')
        AND  NOT EXISTS (SELECT 1
                         FROM   okc_rule_groups_b rgp,
                                okc_rules_b rul,
                                okc_rules_b rul2
                         WHERE  rgp.cle_id = cle.id
                         AND    rgp.rgd_code = 'LAFEXP'
                         AND    rgp.id = rul.rgp_id
                         AND    rgp.id = rul2.rgp_id
                         AND    rul.rule_information_category = 'LAFEXP'
                         AND    rul2.rule_information_category = 'LAFREQ'
                         AND    rul.rule_information1 IS NOT NULL
                         AND    rul.rule_information2 IS NOT NULL
                         AND    rul2.object1_id1 IS NOT NULL);

    CURSOR c_pass_th IS
      SELECT DISTINCT
             cle.id cleId,
             sel.id id,
             sel.amount cf_amount,
             sel.stream_element_date cf_date,
             sel.comments cf_arrear,
             sty.stream_type_purpose cf_purpose,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
             DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
             NVL(TO_NUMBER(laptpr.rule_information1), 100) pass_through_percentage
      FROM   okl_streams stm,
             okl_strm_type_b sty,
             okl_strm_elements sel,
             okc_k_lines_b cle,
             okc_line_styles_b lse,
             okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp,
             okc_rule_groups_b rgp2,
             okc_rules_b laptpr
      WHERE  stm.khr_id = p_khr_id
        AND  stm.say_code = 'WORK'
        AND  stm.purpose_code IS NULL
        AND  stm.sty_id = sty.id
        AND  stm.id = sel.stm_id
        AND  sel.comments IS NOT NULL
        AND  stm.kle_id = cle.id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.lse_id = lse.id
        AND  lse.lty_code in ('FEE', 'LINK_FEE_ASSET')
        AND  cle.id = rgp.cle_id
        AND  rgp.rgd_code = 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  slh.object1_id1 = TO_CHAR(stm.sty_id)
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
        AND  stm.kle_id = rgp2.cle_id
        AND  rgp2.rgd_code = 'LAPSTH'
        AND  rgp2.id = laptpr.rgp_id
        AND  laptpr.rule_information_category = 'LAPTPR';

    CURSOR c_rec_exp IS
      SELECT TO_NUMBER(rul.rule_information1) periods,
             TO_NUMBER(rul.rule_information2) cf_amount,
             DECODE(rul2.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) cf_dpp,
             DECODE(rul2.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) cf_ppy,
             DECODE(rul2.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) cf_mpp,
             cle.start_date start_date
      FROM   okc_rules_b rul,
             okc_rules_b rul2,
             okc_rule_groups_b rgp,
             okc_k_lines_b cle,
             okc_line_styles_b lse
      WHERE  cle.chr_id = p_khr_id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.lse_id = lse.id
        AND  lse.lty_code = 'FEE'
        AND  NOT EXISTS (SELECT 1
                         FROM   okc_rule_groups_b rgp
                         WHERE  rgp.cle_id = cle.id
                           AND  rgp.rgd_code = 'LAPSTH')
        AND  cle.id = rgp.cle_id
        AND  rgp.rgd_code = 'LAFEXP'
        AND  rgp.id = rul.rgp_id
        AND  rgp.id = rul2.rgp_id
        AND  rul.rule_information_category = 'LAFEXP'
        AND  rul2.rule_information_category = 'LAFREQ'
        AND  rul.rule_information1 IS NOT NULL
        AND  rul.rule_information2 IS NOT NULL
        AND  rul2.object1_id1 IS NOT NULL;

    --------------------------
    -- PERFORMANCE ENHANCEMENT SECTION
    --------------------------
    TYPE cash_flow_rec_type IS RECORD (cf_amount NUMBER,
                                       cf_date   DATE,
                                       cf_purpose   VARCHAR2(150),
                                       cf_dpp    NUMBER,
                                       cf_ppy    NUMBER,
                                       cf_days   NUMBER,
				       kleId     NUMBER);

    TYPE cash_flow_tbl_type IS TABLE OF cash_flow_rec_type INDEX BY BINARY_INTEGER;

    hdr_inflow_tbl  cash_flow_tbl_type;
    inflow_tbl      cash_flow_tbl_type;
    subs_inflow_tbl      cash_flow_tbl_type;
    rv_tbl          cash_flow_tbl_type;
    outflow_tbl     cash_flow_tbl_type;
    pass_th_tbl     cash_flow_tbl_type;
    rec_exp_tbl     cash_flow_tbl_type;
    subsidies_tbl      cash_flow_tbl_type;

    m BINARY_INTEGER := 0;
    n BINARY_INTEGER := 0;
    p BINARY_INTEGER := 0;
    q BINARY_INTEGER := 0;
    r BINARY_INTEGER := 0;
    s BINARY_INTEGER := 0;

    --------------------------
    -- END PERFORMANCE ENHANCEMENT SECTION
    --------------------------
    lx_msg_count      NUMBER;
    lx_msg_data       VARCHAR2(4000);
    l_end_date        DATE              := ADD_MONTHS(p_start_date, p_term_duration) - 1;
    l_time_zero_cost  NUMBER            := 0;
    l_cost            NUMBER;
    l_residual_value  NUMBER;
    l_adv_payment     NUMBER            := 0;
    l_subsidy_amount     NUMBER            := 0;
    l_currency_code   VARCHAR2(15);
    l_precision       NUMBER(1);

    l_cf_dpp          NUMBER;
    l_cf_ppy          NUMBER;
    l_cf_amount       NUMBER;
    l_cf_date         DATE;
    l_cf_arrear       VARCHAR2(1);
    l_days_in_future  NUMBER;
    l_periods         NUMBER;
    l_deposit_date    DATE;

    i                 BINARY_INTEGER    := 0;
    l_irr             NUMBER            := nvl( p_initial_irr, 0 );
    l_npv             NUMBER;

    l_irr_limit       NUMBER            := NVL(ABS(fnd_profile.value('OKL_PRE_TAX_IRR_LIMIT')), 1000)/100;

    l_prev_npv        NUMBER;
    l_prev_npv_sign   NUMBER;

    l_crossed_zero    VARCHAR2(1)       := 'N';

    l_increment       NUMBER            := 0.11;
    l_abs_incr        NUMBER;
    l_prev_incr_sign  NUMBER;

--DEBUG
a binary_integer := 0;
b binary_integer := 0;

    lx_return_status    VARCHAR2(1);

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'compute_irr';

    l_additional_parameters  OKL_EXECUTE_FORMULA_PUB.ctxt_val_tbl_type;

    l_secdep_sty_id NUMBER;
    l_secdep_stream_name VARCHAR2(256);

    Cursor c_pass ( khrId NUMBER, cleId NUMBER) IS
    select vDtls.DISBURSEMENT_BASIS,
           vDtls.DISBURSEMENT_FIXED_AMOUNT,
    	   vDtls.DISBURSEMENT_PERCENT,
    	   vDtls.PROCESSING_FEE_BASIS,
    	   vDtls.PROCESSING_FEE_FIXED_AMOUNT,
    	   vDtls.PROCESSING_FEE_PERCENT
    from okl_party_payment_hdr vHdr,
         okl_party_payment_dtls vDtls
    where vDtls.payment_hdr_id = vHdr.id
      and vHdr.CLE_ID = cleId
      and vHdr.DNZ_CHR_ID = khrId;

    r_pass c_pass%ROWTYPE;

    pass_thru_amount  NUMBER;
    pass_thru_pro_fee NUMBER;

    -- Added by RGOOTY
    l_prev_irr NUMBER := 0;
    l_positive_npv_irr NUMBER := 0;
    l_negative_npv_irr NUMBER := 0;
    l_positive_npv NUMBER := 0;
    l_negative_npv NUMBER := 0;
    l_irr_decided VARCHAR2(1) := 'F';

    l_day_convention_month VARCHAR2(30);
    l_day_convention_year VARCHAR2(30);
    l_days_in_year NUMBER;

    l_link_yn VARCHAR2(1);

    CURSOR top_svc_csr ( chrId NUMBER, linkId NUMBER ) IS
    select to_char(kle1.id) top_svc_id,
           kle1.amount top_amount,
	   kle.amount link_amount
    from  okl_k_lines_full_v kle,
          okl_k_lines_full_v kle1,
          okc_line_styles_b lse,
          okc_statuses_b sts
    where KLE1.LSE_ID = LSE.ID
      and ((lse.lty_code  = 'SOLD_SERVICE') OR (lse.lty_code = 'FEE'and kle1.fee_type ='PASSTHROUGH'))
      and kle.dnz_chr_id = chrId
      and kle1.dnz_chr_id = kle.dnz_chr_id
      and sts.code = kle1.sts_code
      and kle.id = linkId
      and kle.cle_id = kle1.id
      and sts.ste_code not in ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

    top_svc_rec top_svc_csr%ROWTYPE;
    pass_thru_id NUMBER;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'begin' );
    END IF;
    x_return_status := G_RET_STS_SUCCESS;

   lx_return_status := G_RET_STS_ERROR;
   -- Fetch the day convention ..
   OKL_PRICING_UTILS_PVT.get_day_convention(
     p_id              => p_khr_id,
     p_source          => 'ISG',
     x_days_in_month   => l_day_convention_month,
     x_days_in_year    => l_day_convention_year,
     x_return_status   => lx_return_status);
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
   END IF;
   IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
    FOR l_asset_cost IN c_asset_cost LOOP

      --Modified IF clause by rgooty for bug 7577105
      IF(NVL(l_asset_cost.date_funding_expected, l_asset_cost.start_date) = p_start_date)
      THEN
        l_cost := nvl(l_asset_cost.capital_amount, 0) + nvl(l_asset_cost.capitalized_interest,0);

        l_time_zero_cost := l_time_zero_cost + NVL(l_cost, 0);

-- Added for approximation of IRR
G_TOT_CAP_AMT := G_TOT_CAP_AMT + l_cost;

      END IF;
    END LOOP;
--print( ' Total Asset Cost  ' || G_TOT_CAP_AMT );
--    print( l_prog_name, ' time zero cost ' || l_time_zero_cost  );
    FOR l_fee_cost IN c_fee_cost LOOP

      If l_fee_cost.lty_code = 'LINK_FEE_ASSET' THEN
             OPEN c_link_pmnts( p_khr_id, l_fee_cost.kleid);
             FETCH c_link_pmnts INTO r_link_pmnts;
             CLOSE c_link_pmnts;
      ENd If;

      If ( l_fee_cost.lty_code <> 'LINK_FEE_ASSET' OR
          (l_fee_cost.lty_code = 'LINK_FEE_ASSET' and nvl(r_link_pmnts.What,'N')='Y') ) THen
      IF l_fee_cost.start_date <= p_start_date THEN

        l_time_zero_cost := l_time_zero_cost + l_fee_cost.amount;

      END IF;
      END IF;

    END LOOP;
  --  print( l_prog_name, ' time zero cost | fee cost ' || l_time_zero_cost  );

    FOR l_hdr_inflow IN c_hdr_inflows LOOP

        m := m + 1;
        hdr_inflow_tbl(m).cf_amount := l_hdr_inflow.cf_amount;
        hdr_inflow_tbl(m).cf_date   := l_hdr_inflow.cf_date;
        hdr_inflow_tbl(m).cf_purpose   := l_hdr_inflow.cf_purpose;
        hdr_inflow_tbl(m).cf_dpp    := l_hdr_inflow.days_per_period;
        hdr_inflow_tbl(m).cf_ppy    := l_hdr_inflow.periods_per_year;

        hdr_inflow_tbl(m).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date   => p_start_date,
                                                    p_days_in_month => l_day_convention_month,
                                                    p_days_in_year => l_day_convention_year,
                                                    p_end_date      => l_hdr_inflow.cf_date,
                                                    p_arrears       => l_hdr_inflow.cf_arrear,
                                                    x_return_status => lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
-- Added for approximation
G_TOT_INFLOW_AMT := G_TOT_INFLOW_AMT + l_hdr_inflow.cf_amount;
--print( 'Header Inflows amount ' ||  l_hdr_inflow.cf_amount );
    END LOOP;

 --  print( l_prog_name, ' hdr flows ' || m  );

    FOR l_inflow IN c_inflows LOOP

      If l_inflow.lty_code = 'LINK_FEE_ASSET' THEN
             OPEN c_link_pmnts( p_khr_id, l_inflow.kleid);
             FETCH c_link_pmnts INTO r_link_pmnts;
             CLOSE c_link_pmnts;
      ENd If;

      If ( l_inflow.lty_code <> 'LINK_FEE_ASSET' OR
          (l_inflow.lty_code = 'LINK_FEE_ASSET' and nvl(r_link_pmnts.What,'N')='Y') ) THen

        n := n + 1;
        inflow_tbl(n).cf_amount := l_inflow.cf_amount;
        inflow_tbl(n).cf_date   := l_inflow.cf_date;
        inflow_tbl(n).cf_purpose   := l_inflow.cf_purpose;
        inflow_tbl(n).cf_dpp    := l_inflow.days_per_period;
        inflow_tbl(n).cf_ppy    := l_inflow.periods_per_year;

        inflow_tbl(n).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                 p_days_in_month => l_day_convention_month,
                                                 p_days_in_year => l_day_convention_year,
                                                 p_end_date      => l_inflow.cf_date,
                                                 p_arrears       => l_inflow.cf_arrear,
                                                 x_return_status => lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;
-- Added for approximation
G_TOT_INFLOW_AMT := G_TOT_INFLOW_AMT + l_inflow.cf_amount;
--print( 'Inflows amount ' ||  l_inflow.cf_amount);
    END LOOP;
--print( 'Total Inflows amount ' ||  G_TOT_INFLOW_AMT );

 --  print( l_prog_name, ' infl flows ' || n  );

    FOR l_asset_rv IN c_asset_rvs LOOP

        p := p + 1;
        If l_asset_rv.sts_code = 'TERMINATED' Then
            rv_tbl(p).cf_amount := OKL_AM_UTIL_PVT.get_actual_asset_residual(p_khr_id => p_khr_id,
	                                                                     p_kle_id => l_asset_rv.id); --bug# 4184579
            rv_tbl(p).cf_date   := l_asset_rv.date_terminated;

            rv_tbl(p).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                 p_days_in_year => l_day_convention_year,
                                                 p_end_date      => l_asset_rv.date_terminated,
                                                 p_arrears       => 'Y',
                                                 x_return_status => lx_return_status);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

	Else
            rv_tbl(p).cf_amount := l_asset_rv.cf_amount;
            rv_tbl(p).cf_date   := l_end_date;

            rv_tbl(p).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                 p_days_in_year => l_day_convention_year,
                                                 p_end_date      => l_end_date,
                                                 p_arrears       => 'Y',
                                                 x_return_status => lx_return_status);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

	End If;

        rv_tbl(p).cf_dpp    := l_asset_rv.days_per_period;
        rv_tbl(p).cf_ppy    := l_asset_rv.periods_per_year;

-- Added for approximation
G_TOT_RV_AMT := G_TOT_RV_AMT + rv_tbl(p).cf_amount;
--print( 'Residual Value amount ' ||  rv_tbl(p).cf_amount);
    END LOOP;
--print( 'Total Inflows amount ' || G_TOT_RV_AMT );

--    print( l_prog_name, ' asset rvs ' || p  );

    FOR l_outflow IN c_fee_cost LOOP

      IF l_outflow.start_date > p_start_date THEN

        q := q + 1;
        outflow_tbl(q).cf_amount := -(l_outflow.amount);
        outflow_tbl(q).cf_date   := l_outflow.start_date;
        outflow_tbl(q).cf_dpp    := 1;
        outflow_tbl(q).cf_ppy    := 360;

        outflow_tbl(q).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => l_outflow.start_date,
                                                  p_arrears       => 'N',
                                                  x_return_status => lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

    END LOOP;
--    print( l_prog_name, ' out flows ' || q  );

    If ( p_subsidies_yn = 'Y' ) Then
          subsidies_tbl(1).cf_amount := 0;
    End If;

    FOR l_outflow IN c_asset_cost LOOP
     -- Handling the case when contract rebooking has happened and an asset has been
     --  added after the start date of the contract but whose funding starts on the revision date.
     --Modified IF clause by rgooty for bug 7577105
     IF NVL(l_outflow.date_funding_expected, l_outflow.start_date) > p_start_date
     THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '!!! Handling the Assets who are in effect later than the start date !!!');
        END IF;
        q := q + 1;
        outflow_tbl(q).cf_amount := nvl(l_outflow.capital_amount, 0);
        outflow_tbl(q).cf_amount := -(outflow_tbl(q).cf_amount);
        outflow_tbl(q).cf_date   := nvl(l_outflow.date_funding_expected, l_outflow.start_date);
        outflow_tbl(q).cf_dpp    := l_outflow.days_per_period;
        outflow_tbl(q).cf_ppy    := l_outflow.periods_per_year;
        outflow_tbl(q).cf_days   :=
          OKL_PRICING_UTILS_PVT.get_day_count(
            p_start_date    => p_start_date,
            p_days_in_month => l_day_convention_month,
            p_days_in_year => l_day_convention_year,
            p_end_date      => outflow_tbl(q).cf_date,
            p_arrears       => 'N',
            x_return_status => lx_return_status);
        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || outflow_tbl(q).cf_date || '| ' || outflow_tbl(q).cf_days || ' | ' ||
               outflow_tbl(q).cf_amount ||' | ' || outflow_tbl(q).cf_dpp || ' | ' || outflow_tbl(q).cf_ppy );
        END IF;
      ELSIF l_outflow.date_funding_expected < p_start_date THEN
        --Removed = in the above if clause by RGOOTY for bug 7577105
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '!!!!! Handling the Assets who are in effect earlier than the start date !!!!');
        END IF;
        q := q + 1;
        outflow_tbl(q).cf_amount := nvl(l_outflow.capital_amount, 0);
        outflow_tbl(q).cf_amount := -(outflow_tbl(q).cf_amount);
        outflow_tbl(q).cf_date   := l_outflow.date_funding_expected;
        outflow_tbl(q).cf_dpp    := l_outflow.days_per_period;
        outflow_tbl(q).cf_ppy    := l_outflow.periods_per_year;
        outflow_tbl(q).cf_days   :=
          OKL_PRICING_UTILS_PVT.get_day_count(
            p_start_date    => l_outflow.date_funding_expected,
            p_days_in_month => l_day_convention_month,
            p_days_in_year => l_day_convention_year,
            p_end_date      => p_start_date,
            p_arrears       => 'N',
            x_return_status => lx_return_status);
        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        outflow_tbl(q).cf_days := -1 * outflow_tbl(q).cf_days;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || outflow_tbl(q).cf_date || '| ' || outflow_tbl(q).cf_days || ' | ' ||
               outflow_tbl(q).cf_amount ||' | ' || outflow_tbl(q).cf_dpp || ' | ' || outflow_tbl(q).cf_ppy );
        END IF;
      END IF;

      If ( p_subsidies_yn = 'Y' ) Then
      -- Subsidies Begin
          OKL_SUBSIDY_PROCESS_PVT.get_asset_subsidy_amount(
                                        p_api_version   => G_API_VERSION,
                                        p_init_msg_list => G_FALSE,
                                        x_return_status => lx_return_status,
                                        x_msg_data      => lx_msg_data,
                                        x_msg_count     => lx_msg_count,
                                        p_asset_cle_id  => l_outflow.id,
                                        x_subsidy_amount=> l_subsidy_amount);

          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          subsidies_tbl(1).cf_amount := nvl(subsidies_tbl(1).cf_amount, 0) + nvl(l_subsidy_amount,0);

      End If;

    END LOOP;

    If ( p_subsidies_yn = 'Y' ) Then

        subsidies_tbl(1).cf_date  := p_start_date;
        subsidies_tbl(1).cf_dpp   := 1;
        subsidies_tbl(1).cf_ppy   := 360;

        subsidies_tbl(1).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => p_start_date,
                                                  p_arrears       => 'N',
                                                  x_return_status => lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- Subsidies End

    End if;


    FOR l_pass_th IN c_pass_th LOOP

        r := r + 1;

        l_link_yn := 'N';
        OPEN top_svc_csr( p_khr_id, l_pass_th.cleId );
        FETCH top_svc_csr INTO top_svc_rec;
        If ( top_svc_csr%FOUND ) Then
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' found top svc line ' || to_char( l_pass_th.cleId ));
            END IF;
            pass_thru_id := top_svc_rec.top_svc_id;
	    l_link_yn := 'Y';
        Else
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' not found top svc line ' || to_char( l_pass_th.cleId ));
            END IF;
	    l_link_yn := 'N';
            pass_thru_id := l_pass_th.cleId;
        End If;
        CLOSE top_svc_csr;

        pass_thru_amount := 0;
	pass_thru_pro_fee := 0;

        -- RGOOTY: 9218201: Start
        For r_pass in c_pass( p_khr_id, pass_thru_id )
        LOOP

            If ( r_pass.disbursement_basis = 'PERCENT' ) Then
	        pass_thru_amount := pass_thru_amount +
		 NVL( l_pass_th.cf_amount*(r_pass.disbursement_percent/100), 0);
	    Else
   	      If (l_link_yn = 'Y') Then
	        pass_thru_amount := pass_thru_amount +
	              NVL( (r_pass.disbursement_fixed_amount*top_svc_rec.link_amount)/top_svc_rec.top_amount, 0);
	      Else
	        pass_thru_amount := pass_thru_amount +
		      NVL(r_pass.disbursement_fixed_amount, 0);
	      End If;
	    End If;

            --If ( r_pass.INCLUDE_IN_YIELD_FLAG = 'Y' ) Then -- Always equal to 'Y'
                If ( r_pass.processing_fee_basis = 'PERCENT') Then
	            pass_thru_pro_fee := pass_thru_pro_fee +
		      NVL( l_pass_th.cf_amount*(r_pass.processing_fee_percent/100), 0);
	        Else
	          If (l_link_yn = 'Y') Then
	            pass_thru_pro_fee := pass_thru_pro_fee +
	               NVL( (r_pass.processing_fee_fixed_amount*top_svc_rec.link_amount)/top_svc_rec.top_amount, 0);
	          Else
	            pass_thru_pro_fee := pass_thru_pro_fee +
		      NVL( r_pass.processing_fee_fixed_amount, 0);
	          End If;
	        End If;
            --End If;

        END LOOP;
        -- RGOOTY: 9218201: End

        pass_th_tbl(r).cf_amount := l_pass_th.cf_amount - pass_thru_amount + pass_thru_pro_fee;
        pass_th_tbl(r).cf_date   := l_pass_th.cf_date;
        pass_th_tbl(r).cf_purpose   := l_pass_th.cf_purpose;
        pass_th_tbl(r).cf_dpp    := l_pass_th.days_per_period;
        pass_th_tbl(r).cf_ppy    := l_pass_th.periods_per_year;

        pass_th_tbl(r).cf_days   :=OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => l_pass_th.cf_date,
                                                  p_arrears       => l_pass_th.cf_arrear,
                                                  x_return_status => lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    END LOOP;
 --   print( l_prog_name, ' pass thru  ' || r  );

    FOR l_rec_exp IN c_rec_exp LOOP

        FOR s1 in 1..l_rec_exp.periods LOOP

          s := s + 1;

          rec_exp_tbl(s).cf_amount := -(l_rec_exp.cf_amount);
          rec_exp_tbl(s).cf_date   := ADD_MONTHS(l_rec_exp.start_date, (s1 -1)*l_rec_exp.cf_mpp);
          rec_exp_tbl(s).cf_dpp    :=  l_rec_exp.cf_dpp;
          rec_exp_tbl(s).cf_ppy    :=  l_rec_exp.cf_ppy;

          rec_exp_tbl(s).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                    p_days_in_month => l_day_convention_month,
                                                    p_days_in_year => l_day_convention_year,
                                                    p_end_date      => rec_exp_tbl(s).cf_date,
                                                    p_arrears       => 'N',
                                                    x_return_status => lx_return_status);

          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END LOOP;

    END LOOP;
 --   print( l_prog_name, ' recu exp  ' || s  );

    IF m > 0 THEN
      FOR m1 IN 1..hdr_inflow_tbl.COUNT LOOP
        IF hdr_inflow_tbl(m1).cf_date <= p_start_date THEN
          l_adv_payment  :=  l_adv_payment + hdr_inflow_tbl(m1).cf_amount;
 --   print( l_prog_name, hdr_inflow_tbl(m1).cf_date || ':::' || p_start_date || ':::' || l_adv_payment);
        END IF;
      END LOOP;
    END IF;

    IF n > 0 THEN
      FOR n1 IN 1..inflow_tbl.COUNT LOOP
        IF inflow_tbl(n1).cf_date <= p_start_date THEN
          l_adv_payment  :=  l_adv_payment + inflow_tbl(n1).cf_amount;
 --   print( l_prog_name, inflow_tbl(n1).cf_date || ':::' || p_start_date || ':::' || l_adv_payment);
        END IF;
      END LOOP;
    END IF;

    IF r > 0 THEN
      FOR r1 IN 1..pass_th_tbl.COUNT LOOP
        IF pass_th_tbl(r1).cf_date <= p_start_date THEN
          l_adv_payment  :=  l_adv_payment + pass_th_tbl(r1).cf_amount;
 --   print( l_prog_name, pass_th_tbl(r1).cf_date || ':::' || p_start_date || ':::' || l_adv_payment);
        END IF;
      END LOOP;
    END IF;

  --  print( l_prog_name, 'TIME ZERO OUTFLOW '||l_time_zero_cost);
  --  print( l_prog_name, 'INFLOWS ON OR BEFORE TIME ZERO '||l_adv_payment);

    --Commented by RGOOTY for bug 7577105
    /*
    IF l_adv_payment >= l_time_zero_cost THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_IRR_CALC_INF_LOOP',
                           p_token1       => 'ADV_AMOUNT',
                           p_token1_value => l_adv_payment,
                           p_token2       => 'CAPITAL_AMOUNT',
                           p_token2_value => l_time_zero_cost);

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF; */

    SELECT currency_code
    INTO   l_currency_code
    FROM   okc_k_headers_b
    WHERE  id = p_khr_id;

    SELECT NVL(precision,0)
    INTO   l_precision
    FROM   fnd_currencies
    WHERE  currency_code = l_currency_code;


    l_precision := 4;

    l_irr_limit := ROUND(NVL(ABS(fnd_profile.value('OKL_PRE_TAX_IRR_LIMIT')), 1000), 0)/100;


-- Added for IRR Approximation
-- Appr. IRR based on Simple Interest Calculation
IF ( G_TOT_CAP_AMT <> G_TOT_RV_AMT )
THEN
    l_irr := ( G_TOT_INFLOW_AMT +  G_TOT_RV_AMT - G_TOT_CAP_AMT )
    / ( G_TOT_CAP_AMT -  G_TOT_RV_AMT );
ELSE
    l_irr := 0;
END IF;
/*
print( 'G_TOT_INFLOW_AMT ' || G_TOT_INFLOW_AMT );
print( 'G_TOT_RV_AMT ' || G_TOT_RV_AMT );
print( 'G_TOT_CAP_AMT ' || G_TOT_CAP_AMT );
print( 'Approximated IRR' || l_irr );
print( 'IRR Passing actually  ' || l_irr);
*/
    LOOP

      i                 :=  i + 1;
      l_npv             :=  -(l_time_zero_cost);
      l_deposit_date    :=  NULL;

 /*
    print( l_prog_name, ' PRECISION ' || nvl(l_precision, 0) ||  ' time cost ' || nvl(l_npv,0) );
--DEBUG
    print( l_prog_name, ' ');
    print( l_prog_name, 'ITERATION # '||i||'  IRR Guess '||l_irr*100||'   Time Zero is '
                        ||TO_CHAR(p_start_date, 'DD-MON-YYYY'));
    print( l_prog_name,' ');
*/

      -------------------------------------------
      -- INTERIM INTEREST INFLOWS
      -------------------------------------------

      IF p_interim_tbl.COUNT > 0 THEN
 /*
    print( l_prog_name,'INTERIM INTEREST INFLOWS ...');
    print( l_prog_name,'');
    print( l_prog_name, '   '||'    Cash Flow'||'  Days in'||'  Periods'||'  Cash Flow'||'  Discounted');
    print( l_prog_name, '   '||'         Date'||'   Future'||'    (n)  '||'     Amount'||'       Value');
    print( l_prog_name, '');
 */
--DEBUG
a :=0;
        FOR l_temp IN p_interim_tbl.FIRST .. p_interim_tbl.LAST LOOP
--DEBUG
a := a+1;
          l_cf_dpp          :=  p_interim_tbl(l_temp).cf_dpp;

          IF l_cf_dpp = 30 THEN
            l_cf_ppy  :=  12;
          ELSIF l_cf_dpp = 90 THEN
            l_cf_ppy  :=  4;
          ELSIF l_cf_dpp = 180 THEN
            l_cf_ppy  :=  2;
          ELSIF l_cf_dpp = 360 THEN
            l_cf_ppy  :=  1;
          END IF;

          l_cf_amount       :=  p_interim_tbl(l_temp).cf_amount;
          l_days_in_future  :=  p_interim_tbl(l_temp).cf_days;

          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));

 /*
    print( l_prog_name, TO_CHAR(a, '99')||'  '||'NOT AVAILAB'||'    '||TO_CHAR(l_days_in_future, '9999')
                        ||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '999.999')||
                        '     '||TO_CHAR((l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods)), '999.990'));
*/
        END LOOP;

      END IF;

      -------------------------------------------
      -- FEE COST CASH OUTFLOWS
      -------------------------------------------

      IF q > 0 THEN
/*
    print( l_prog_name, 'FEE COST CASHFLOWS ...');
    print( l_prog_name, '');
    print( l_prog_name, '   '||'    Cash Flow'||'  Days in'||'  Periods'||'  Cash Flow'||'  Discounted');
    print( l_prog_name, '   '||'         Date'||'   Future'||'    (n)  '||'     Amount'||'       Value');
    print( l_prog_name, '');
*/
--DEBUG
a :=0;
        FOR w IN 1..outflow_tbl.COUNT LOOP
--DEBUG
a := a+1;
          l_cf_dpp          :=  outflow_tbl(w).cf_dpp;
          l_cf_ppy          :=  outflow_tbl(w).cf_ppy;
          l_cf_amount       :=  outflow_tbl(w).cf_amount;
          l_cf_date         :=  outflow_tbl(w).cf_date;
          l_days_in_future  :=  outflow_tbl(w).cf_days;

          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));

 /*
    print( l_prog_name, TO_CHAR(a, '99')||'  '||TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'    '||TO_CHAR(l_days_in_future, '9999')||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '999.999')||
'     '||TO_CHAR((l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods)), '999.990'));
*/

        END LOOP;

      END IF;


      -------------------------------------------
      -- PASSTHROUGH CASH INFLOWS
      -------------------------------------------

      IF r > 0 THEN
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'PASSTHROUGH CASH INFLOWS ...');
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '');
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '   '||'    Cash Flow'||'  Days in'||'  Periods'||'  Cash Flow'||'  Discounted');
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '   '||'         Date'||'   Future'||'    (n)  '||'     Amount'||'       Value');
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '');
    END IF;
--DEBUG
a :=0;
        FOR v IN 1..pass_th_tbl.COUNT LOOP
--DEBUG
a := a+1;
          l_cf_dpp          :=  pass_th_tbl(v).cf_dpp;
          l_cf_ppy          :=  pass_th_tbl(v).cf_ppy;
          l_cf_amount       :=  pass_th_tbl(v).cf_amount;
          l_cf_date         :=  pass_th_tbl(v).cf_date;
          l_days_in_future  :=  pass_th_tbl(v).cf_days;

          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));

/*
    print( l_prog_name, TO_CHAR(a, '99')||'  '||TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'    '||TO_CHAR(l_days_in_future, '9999')||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '999.999')||
'     '||TO_CHAR((l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods)), '999.990'));
*/

        END LOOP;

      END IF;


      -------------------------------------------
      -- FEE RECURRING EXPENSE CASH OUTFLOWS
      -------------------------------------------

      IF s > 0 THEN
 /*
    print( l_prog_name, 'FEE RECURRING EXPENSE CASH OUTFLOWS ...');
    print( l_prog_name, '');
    print( l_prog_name, '   '||'    Cash Flow'||'  Days in'||'  Periods'||'  Cash Flow'||'  Discounted');
    print( l_prog_name, '   '||'         Date'||'   Future'||'    (n)  '||'     Amount'||'       Value');
    print( l_prog_name, '');
 */
--DEBUG
a :=0;
        FOR t IN 1..rec_exp_tbl.COUNT LOOP
--DEBUG
a := a+1;
          l_cf_ppy          :=  rec_exp_tbl(t).cf_ppy;
          l_cf_dpp          :=  rec_exp_tbl(t).cf_dpp;
          l_cf_amount       :=  rec_exp_tbl(t).cf_amount;
          l_cf_date         :=  rec_exp_tbl(t).cf_date;
          l_days_in_future  :=  rec_exp_tbl(t).cf_days;

          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));

 /*
    print( l_prog_name, TO_CHAR(a, '99')||'  '||TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'    '||TO_CHAR(l_days_in_future, '9999')||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '999.999')||
'     '||TO_CHAR((l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods)), '999.990'));
*/

        END LOOP;

      END IF;

      -------------------------------------------
      -- HEADER LEVEL CASH INFLOWS
      -------------------------------------------

      IF m > 0 THEN
/*
    print( l_prog_name, 'K LEVEL CASH INFLOWS ...');
    print( l_prog_name, '');
    print( l_prog_name, '   '||'    Cash Flow'||'  Days in'||'  Periods'||'  Cash Flow'||'  Discounted');
    print( l_prog_name, '   '||'         Date'||'   Future'||'    (n)  '||'     Amount'||'       Value');
    print( l_prog_name, '');
*/
--DEBUG
a :=0;
        FOR x IN 1..hdr_inflow_tbl.COUNT LOOP
--DEBUG
a := a+1;
          l_cf_dpp          :=  hdr_inflow_tbl(x).cf_dpp;
          l_cf_ppy          :=  hdr_inflow_tbl(x).cf_ppy;
          l_cf_amount       :=  hdr_inflow_tbl(x).cf_amount;
          l_cf_date         :=  hdr_inflow_tbl(x).cf_date;
          l_days_in_future  :=  hdr_inflow_tbl(x).cf_days;

          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));

/*
    print( l_prog_name, TO_CHAR(a, '99')||'  '||TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'    '||TO_CHAR(l_days_in_future, '9999')||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '99.999')||
'     '||TO_CHAR((l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods)), '99.990'));
*/

          -- Security Deposit is both an inflow as well as an outflow

          IF hdr_inflow_tbl(x).cf_purpose = 'SECURITY_DEPOSIT' THEN

            OPEN c_deposit_date;
            FETCH c_deposit_date INTO l_deposit_date;
            CLOSE c_deposit_date;

            IF l_deposit_date IS NOT NULL THEN

              l_days_in_future  :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => l_deposit_date,
                                                  p_arrears       => l_cf_arrear,
                                                  x_return_status => lx_return_status);

              IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            ELSE

              l_days_in_future  :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => l_end_date,
                                                  p_arrears       => l_cf_arrear,
                                                  x_return_status => lx_return_status);

              IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            END IF;

            l_periods := l_days_in_future / l_cf_dpp;
            l_npv     := l_npv - (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));

          END IF;

          l_deposit_date  :=  NULL;

        END LOOP;

      END IF;

      -------------------------------------------
      -- LINE LEVEL CASH INFLOWS
      -------------------------------------------

      IF n > 0 THEN
 /*
    print( l_prog_name, 'LINE LEVEL CASH INFLOWS ...');
    print( l_prog_name, '');
    print( l_prog_name, '   '||'    Cash Flow'||'  Days in'||'  Periods'||'  Cash Flow'||'  Discounted');
    print( l_prog_name, '   '||'         Date'||'   Future'||'    (n)  '||'     Amount'||'       Value');
    print( l_prog_name, '');
 */
--DEBUG
a :=0;
        FOR y IN 1..inflow_tbl.COUNT LOOP
--DEBUG
a := a+1;
          l_cf_dpp          :=  inflow_tbl(y).cf_dpp;
          l_cf_ppy          :=  inflow_tbl(y).cf_ppy;
          l_cf_amount       :=  inflow_tbl(y).cf_amount;
          l_cf_date         :=  inflow_tbl(y).cf_date;
          l_days_in_future  :=  inflow_tbl(y).cf_days;

          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;


          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));

/*
    print( l_prog_name, TO_CHAR(a, '99')||'  '||TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'    '||TO_CHAR(l_days_in_future, '9999')||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '999.999')||
'     '||TO_CHAR((l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods)), '999.990'));
*/

/*print( TO_CHAR(a, '99')||'  '||TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'    '||TO_CHAR(l_days_in_future, '9999')||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '999.999')||
'     '||TO_CHAR((l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods)), '999.990'));
*/
          -- Security Deposit is both an inflow as well as an outflow


          IF inflow_tbl(y).cf_purpose = 'SECURITY_DEPOSIT' THEN

            OPEN c_deposit_date;
            FETCH c_deposit_date INTO l_deposit_date;
            CLOSE c_deposit_date;

            IF l_deposit_date IS NOT NULL THEN

              l_days_in_future  :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => l_deposit_date,
                                                  p_arrears       => l_cf_arrear,
                                                  x_return_status => lx_return_status);

              IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            ELSE

              l_days_in_future  :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => l_end_date,
                                                  p_arrears       => l_cf_arrear,
                                                  x_return_status => lx_return_status);

              IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            END IF;

            l_periods := l_days_in_future / l_cf_dpp;
            l_npv     := l_npv - (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));

          END IF;

          l_deposit_date  :=  NULL;

        END LOOP;

      END IF;

      -------------------------------------------
      -- RV CASH INFLOWS
      -------------------------------------------

      IF p > 0 THEN
 /*
    print( l_prog_name,'RV CASH INFLOWS ...');
    print( l_prog_name, '');
    print( l_prog_name, '   '||'    Cash Flow'||'  Days in'||'  Periods'||'  Cash Flow'||'  Discounted');
    print( l_prog_name, '   '||'         Date'||'   Future'||'    (n)  '||'     Amount'||'       Value');
    print( l_prog_name, '');
 */
--DEBUG
a :=0;
        FOR z IN 1..rv_tbl.COUNT LOOP
--DEBUG
a := a+1;
          l_cf_dpp          :=  rv_tbl(z).cf_dpp;
          l_cf_ppy          :=  rv_tbl(z).cf_ppy;
          l_cf_amount       :=  rv_tbl(z).cf_amount;
          l_cf_date         :=  rv_tbl(z).cf_date;
          l_days_in_future  :=  rv_tbl(z).cf_days;

          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));

 /*
    print( l_prog_name, TO_CHAR(a, '99')||'  '||TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'    '||TO_CHAR(l_days_in_future, '9999')||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '999.999')||
'     '||TO_CHAR((l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods)), '99.990'));
*/

        END LOOP;

      END IF;

-- SUBSIDIES
      FOR y IN 1..subsidies_tbl.COUNT
      LOOP

          l_cf_dpp          :=  subsidies_tbl(y).cf_dpp;
          l_cf_ppy          :=  subsidies_tbl(y).cf_ppy;
          l_cf_amount       :=  subsidies_tbl(y).cf_amount;
          l_cf_date         :=  subsidies_tbl(y).cf_date;
          l_days_in_future  :=  subsidies_tbl(y).cf_days;

          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));

 /*
    print( l_prog_name, TO_CHAR(a, '99')||'  '||TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'    '||TO_CHAR(l_days_in_future, '9999')||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '999.999')||
'     '||TO_CHAR((l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods)), '999.990'));
*/

      END LOOP;
-- SUBSIDIES

  --  print( l_prog_name, 'NPV '||L_NPV);

      IF ROUND(l_npv, l_precision+1) = 0 THEN

        x_irr    := l_irr;  -- LLA API multiples by 100 before updating KHR implicit_interest_rate column
        RETURN;

      END IF;


      IF i > 1 and SIGN(l_npv) <> SIGN(l_prev_npv) AND l_crossed_zero = 'N' THEN

        l_crossed_zero := 'Y';
	IF ( sign( l_npv) = 1 ) then
          l_positive_npv := l_npv;
          l_negative_npv := l_prev_npv;
          l_positive_npv_irr := l_irr;
          l_negative_npv_irr := l_prev_irr;
       ELSE
         l_positive_npv := l_prev_npv;
         l_negative_npv := l_npv;
         l_positive_npv_irr := l_prev_irr;
         l_negative_npv_irr := l_irr;
       END IF;

      END IF;

      IF( sign(l_npv) = 1) THEN
	l_positive_npv := l_npv;
        l_positive_npv_irr := l_irr;
      ELSE
       l_negative_npv := l_npv;
       l_negative_npv_irr := l_irr;
      END IF;

      IF l_crossed_zero = 'Y' THEN
        -- Means First time we have got two opposite signed
        IF i > 1 then
	   l_abs_incr := abs(( l_positive_npv_irr - l_negative_npv_irr )
	                 / ( l_positive_npv - l_negative_npv )  * l_positive_npv) ;
           IF ( l_positive_npv_irr < l_negative_npv_irr ) THEN
		l_irr := l_positive_npv_irr + l_abs_incr;
           ELSE
		l_irr := l_positive_npv_irr - l_abs_incr;

           END IF;
           l_irr_decided := 'T';
        else
            l_abs_incr := ABS(l_increment) / 2;
        END IF;

      ELSE

        l_abs_incr := ABS(l_increment);

      END IF;

      IF i > 1 THEN

        IF SIGN(l_npv) <> l_prev_npv_sign THEN

          IF l_prev_incr_sign = 1 THEN

            l_increment := - l_abs_incr;

          ELSE

            l_increment := l_abs_incr;

          END IF;

        ELSE

          IF l_prev_incr_sign = 1 THEN

            l_increment := l_abs_incr;

          ELSE

            l_increment := - l_abs_incr;

          END IF;

        END IF;

      ELSE  -- i = 1

        IF SIGN(l_npv) = -1 THEN

          l_increment := - l_increment;

        END IF;

      END IF;


      -- Added by RGOOTY: Start
      l_prev_irr        := l_irr;

      IF l_irr_decided = 'F'
      THEN
      	l_irr             :=  l_irr + l_increment;
      ELSE
       l_irr_decided := 'F';
      END IF;


/*
print( i || '-Loop l_npv ' || l_npv );
print( i || '-Loop l_increment ' || l_increment );
print( i || '-Loop irr  '  || l_irr );
*/

      IF ABS(l_irr) > l_irr_limit THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_IRR_CALC_IRR_LIMIT',
                             p_token1       => 'IRR_LIMIT',
                             p_token1_value => l_irr_limit*100);

        RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

      l_prev_incr_sign  :=  SIGN(l_increment);
      l_prev_npv_sign   :=  SIGN(l_npv);
      l_prev_npv        :=  l_npv;


    END LOOP;
--    print( l_prog_name, 'end' );

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

  END compute_irr;

  ---------------------------------------------------------------------------
  -- PROCEDURE target_pay_down
  --
  -- Description
  -- Populates Stream Element arrays with loan specific streams
  ---------------------------------------------------------------------------
  -- bug 2992184. Added p_purpose_code parameter.
  PROCEDURE target_pay_down (
                          p_khr_id          IN  NUMBER,
                          p_ppd_date        IN  DATE,
                          p_ppd_amount      IN  NUMBER,
                          p_iir             IN  NUMBER,
                          x_payment_amount  OUT NOCOPY NUMBER,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'target_pay_down';

  begin

NULL;
  end target_pay_down;


  ---------------------------------------------------------------------------
  -- PROCEDURE target_pay_down
  --
  -- Description
  -- Populates Stream Element arrays with loan specific streams
  ---------------------------------------------------------------------------
  -- bug 2992184. Added p_purpose_code parameter.
  PROCEDURE target_pay_down (
                          p_khr_id          IN  NUMBER,
                          p_kle_id          IN  NUMBER,
                          p_ppd_date        IN  DATE,
                          p_ppd_amount      IN  NUMBER,
                          p_iir             IN  NUMBER,
                          x_payment_amount  OUT NOCOPY NUMBER,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'target_pay_down';


    CURSOR c_hdr IS
      SELECT chr.template_yn,
             chr.currency_code,
             chr.start_date,
             chr.end_date,
             khr.deal_type,
             khr.term_duration,
             NVL(khr.generate_accrual_yn, 'Y')
      FROM   okc_k_headers_b chr,
             okl_k_headers khr
      WHERE  khr.id = p_khr_id
        AND  chr.id = khr.id;

    l_hdr c_hdr%ROWTYPE;

    CURSOR c_rent_slls IS
      SELECT FND_DATE.canonical_to_date(sll.rule_information2) start_date,
             TO_NUMBER(SLL.rule_information3) periods,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 120, 'S', 180, 'A', 360) dpp,
             DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) mpp,
             NVL(sll.rule_information10, 'N') arrears_yn,
             FND_NUMBER.canonical_to_number(sll.rule_information6) rent_amount
      FROM   okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp,
             okl_strm_type_b sty
      WHERE  rgp.dnz_chr_id = p_khr_id
        AND  rgp.cle_id = p_kle_id
        AND  rgp.rgd_code= 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  TO_NUMBER(slh.object1_id1) = sty.id
        AND  sty.version = '1.0'
        AND  sty.stream_type_purpose = 'RENT'
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
      ORDER BY fnd_date.canonical_to_date(sll.rule_information2);

    l_rent_sll  c_rent_slls%ROWTYPE;

    -- bug 2992184. Added where condition for multi-gaap reporting streams.
    CURSOR c_rent_flows IS
      SELECT sel.id se_id,
             sel.amount se_amount,
             sel.stream_element_date se_date,
             sel.comments se_arrears
      FROM   okl_strm_elements sel,
             okl_streams stm,
             okl_strm_type_b sty
      WHERE  stm.kle_id = p_kle_id
        AND  stm.say_code = 'CURR'
        AND  stm.active_yn = 'Y'
        AND  stm.purpose_code IS NULL
        AND  stm.sty_id = sty.id
        AND  sty.version = '1.0'
        AND  sty.stream_type_purpose = 'RENT' --'LOAN PAYMENT'
        AND  stm.id = sel.stm_id
      ORDER BY sel.stream_element_date;

    CURSOR c_kle IS
    select kle.id,
           kle.start_date
     from  okl_k_lines_full_v kle,
	   okc_statuses_b sts
     where kle.dnz_chr_id = p_khr_id
          and kle.id = p_kle_id
	  and sts.code = kle.sts_code
	  and sts.ste_code not in ('HOLD', 'EXPIRED', 'CANCELLED');

    l_kle c_kle%ROWTYPE;

    TYPE loan_rec IS RECORD (se_amount NUMBER, se_date DATE, se_days NUMBER, se_arrears VARCHAR2(1));
    TYPE loan_tbl IS TABLE OF loan_rec INDEX BY BINARY_INTEGER;

    x_principal_tbl okl_streams_pub.selv_tbl_type;
    x_interest_tbl  okl_streams_pub.selv_tbl_type;
    x_prin_bal_tbl  okl_streams_pub.selv_tbl_type;

    x_interim_interest NUMBER;
    x_interim_days     NUMBER;
    x_interim_dpp      NUMBER;

    asset_rents        loan_tbl;
    loan_payment       loan_tbl;
    pricipal_payment   loan_tbl;
    interest_payment   loan_tbl;
    pre_tax_income     loan_tbl;
    termination_val    loan_tbl;

    l_payment_amount   NUMBER := 0.1;

    l_investment       NUMBER;

    l_iir_limit        NUMBER            := NVL(ABS(fnd_profile.value('OKL_PRE_TAX_IIR_LIMIT')), 1000)/100;

    l_start_date       DATE;
    l_end_date         DATE;
    l_interim_days     NUMBER;
    l_interim_interest NUMBER;
    l_open_book        NUMBER;
    l_close_book       NUMBER;
    l_payment          NUMBER;
    l_interest         NUMBER;
    l_principal        NUMBER;
    l_se_date          DATE;
    l_termination_val  NUMBER;
    l_days             NUMBER;
    l_iir              NUMBER            := 0;
    l_bk_yield         NUMBER            := 0;

    l_rent_period_end  DATE;
    l_k_end_date       DATE;
    l_total_periods    NUMBER            := 0;
    l_term_complete    VARCHAR2(1)       := 'N';

    l_increment        NUMBER            := 0.1;
    l_abs_incr         NUMBER;
    l_prev_incr_sign   NUMBER;
    l_crossed_zero     VARCHAR2(1)       := 'N';

    l_diff             NUMBER;
    l_prev_diff        NUMBER;
    l_prev_diff_sign   NUMBER;

    i                  BINARY_INTEGER    :=  0;
    j                  BINARY_INTEGER    :=  0;
    k                  BINARY_INTEGER    :=  0;
    m                  BINARY_INTEGER    :=  0;

    lx_return_status   VARCHAR2(1);

    l_additional_parameters  OKL_EXECUTE_FORMULA_PUB.ctxt_val_tbl_type;

    l_day_convention_month VARCHAR2(30);
    l_day_convention_year VARCHAR2(30);
    l_days_in_year NUMBER;


  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'begin' );

    END IF;
    -- Fetch the day convention ..
    OKL_PRICING_UTILS_PVT.get_day_convention(
      p_id              => p_khr_id,
      p_source          => 'ISG',
      x_days_in_month   => l_day_convention_month,
      x_days_in_year    => l_day_convention_year,
      x_return_status   => lx_return_status);
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
    END IF;
    IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN  c_hdr;
    FETCH c_hdr INTO l_hdr;
    CLOSE c_hdr;

    l_k_end_date := (ADD_MONTHS(l_hdr.start_date, l_hdr.term_duration) - 1);

    OPEN  c_kle;
    FETCH c_kle INTO l_kle;
    CLOSE c_kle;

    OPEN c_rent_slls;
    FETCH c_rent_slls INTO l_rent_sll;
    CLOSE c_rent_slls;

    l_start_date  :=  l_rent_sll.start_date;

    FOR  l_rent_flow IN c_rent_flows LOOP

      k := k + 1;

      asset_rents(k).se_days    :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => l_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => l_rent_flow.se_date,
                                                  p_arrears       => l_rent_flow.se_arrears,
                                                  x_return_status => lx_return_status);

      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      asset_rents(k).se_amount  :=  l_rent_flow.se_amount;
      asset_rents(k).se_date    :=  l_rent_flow.se_date;
      asset_rents(k).se_arrears :=  l_rent_flow.se_arrears;

      l_start_date  :=  l_rent_flow.se_date;

      IF l_rent_flow.se_arrears = 'Y' THEN
        l_start_date  :=  l_start_date + 1;
      END IF;

    END LOOP;

    l_interim_days  :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => l_kle.start_date,
                                      p_days_in_month => l_day_convention_month,
                                      p_days_in_year => l_day_convention_year,
                                      p_end_date      => l_rent_sll.start_date,
                                      p_arrears       => 'N',
                                      x_return_status => lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_additional_parameters(0).name  := 'TERMINATED_LINES_YN';
    l_additional_parameters(0).value := 'Y';

    okl_execute_formula_pub.execute(p_api_version   => G_API_VERSION,
                                    p_init_msg_list => G_FALSE,
                                    x_return_status => lx_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_formula_name  => 'LINE_CAP_AMNT',
                                    p_contract_id   => p_khr_id,
                                    p_line_id       => p_kle_id,
                                    p_additional_parameters => l_additional_parameters,
                                    x_value         => l_investment);

     l_additional_parameters.delete;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' cap amount ' || l_investment);

     END IF;
     IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    l_investment := l_investment - p_ppd_amount;

    LOOP

      i :=  i + 1;

      l_interim_interest  :=  l_investment * l_interim_days * p_iir/360;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || i||' Implicit Rate '||p_iir||' Interim Interest '||l_interim_interest
                           ||' Interim Days = '||l_interim_days);

    END IF;
      l_open_book  :=  l_investment;

      FOR k IN 1..asset_rents.COUNT LOOP

        If ( p_ppd_date <= asset_rents(k).se_date ) Then
            l_payment :=  asset_rents(k).se_amount - l_payment_amount;
        Else
            l_payment :=  asset_rents(k).se_amount;
        End if;

        l_interest   :=  l_open_book*asset_rents(k).se_days*p_iir/360;
        l_principal  :=  l_payment - l_interest;
        l_close_book :=  l_open_book - l_principal;
        l_open_book  :=  l_close_book;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '  '||TO_CHAR(asset_rents(k).se_date, 'DD-MON-YYYY')||'   DAYS '||asset_rents(k).se_DAYS
                              || '   LOAN PAYMENT '||l_payment|| '   INTEREST '||ROUND(l_interest, 3)
  			    || '   PRINCIPAL '||ROUND(l_principal, 3)||'   Next OB '||ROUND(l_open_book, 3));

    END IF;
      END LOOP;

      l_diff  :=  l_open_book;

      IF ROUND(l_diff, 4) = 0 THEN

        l_open_book  :=  l_investment;

        FOR k IN asset_rents.FIRST .. asset_rents.LAST LOOP

          If ( p_ppd_date <= asset_rents(k).se_date ) Then
              l_payment :=  asset_rents(k).se_amount - l_payment_amount;
          Else
              l_payment :=  asset_rents(k).se_amount;
          End if;

          l_interest   :=  l_open_book*asset_rents(k).se_days*p_iir/360;
          l_principal  :=  l_payment - l_interest;
          l_close_book :=  l_open_book - l_principal;

          l_se_date    :=  asset_rents(k).se_date;

          x_principal_tbl(k).amount  :=  l_principal;
          x_interest_tbl(k).amount   :=  l_interest;
          x_prin_bal_tbl(k).amount   :=  l_close_book;

          x_principal_tbl(k).se_line_number  :=  k;
          x_interest_tbl(k).se_line_number   :=  k;
          x_prin_bal_tbl(k).se_line_number   :=  k;

          x_principal_tbl(k).stream_element_date  :=  l_se_date;
          x_interest_tbl(k).stream_element_date   :=  l_se_date;
          x_prin_bal_tbl(k).stream_element_date   :=  l_se_date;

          l_open_book  :=  l_close_book;

        END LOOP;

        IF l_interim_interest > 0 THEN

          IF l_rent_sll.arrears_yn = 'Y' THEN

            x_principal_tbl(asset_rents.FIRST-1).amount  :=  0;
            x_interest_tbl(asset_rents.FIRST-1).amount   :=  l_interim_interest;
            x_prin_bal_tbl(asset_rents.FIRST-1).amount   :=  l_investment;

            x_principal_tbl(asset_rents.FIRST-1).se_line_number  :=  0;
            x_interest_tbl(asset_rents.FIRST-1).se_line_number   :=  0;
            x_prin_bal_tbl(asset_rents.FIRST-1).se_line_number   :=  0;

            x_principal_tbl(asset_rents.FIRST-1).stream_element_date  :=  l_rent_sll.start_date;
            x_interest_tbl(asset_rents.FIRST-1).stream_element_date   :=  l_rent_sll.start_date;
            x_prin_bal_tbl(asset_rents.FIRST-1).stream_element_date   :=  l_rent_sll.start_date;

          ELSE

            x_interest_tbl(asset_rents.FIRST).amount   :=  l_interim_interest;

          END IF;

        END IF;

        x_interim_interest  :=  l_interim_interest;
        x_interim_days      :=  l_interim_days;
        x_interim_dpp       :=  l_rent_sll.dpp;

        EXIT;

      END IF;

      IF SIGN(l_diff) <> SIGN(l_prev_diff) AND l_crossed_zero = 'N' THEN
        l_crossed_zero := 'Y';
      END IF;

      IF l_crossed_zero = 'Y' THEN
        l_abs_incr := ABS(l_increment) / 2;
      ELSE
        l_abs_incr := ABS(l_increment);
      END IF;

      IF i > 1 THEN
        IF SIGN(l_diff) <> l_prev_diff_sign THEN
          IF l_prev_incr_sign = 1 THEN
            l_increment := - l_abs_incr;
          ELSE
            l_increment := l_abs_incr;
          END IF;
        ELSE
          IF l_prev_incr_sign = 1 THEN
            l_increment := l_abs_incr;
          ELSE
            l_increment := - l_abs_incr;
          END IF;
        END IF;
      ELSE
        IF SIGN(l_diff) = 1 THEN
          l_increment := -l_increment;
        ELSE
          l_increment := l_increment;
        END IF;
      END IF;

      l_payment_amount :=  l_payment_amount + l_increment;

      l_prev_incr_sign  :=  SIGN(l_increment);
      l_prev_diff_sign  :=  SIGN(l_diff);
      l_prev_diff       :=  l_diff;

    END LOOP;

  x_return_status  :=  lx_return_status;
  x_payment_amount := l_payment_amount;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'end' );

    END IF;
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

  END target_pay_down;

  PROCEDURE  comp_so_iir(p_api_version    IN  NUMBER,
                                 p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2,
                                 p_khr_id         IN NUMBER,
                                 p_kle_id         IN NUMBER,
                                 p_target         IN VARCHAR2,
                                 p_subside_yn     IN VARCHAR2 DEFAULT 'N',
                                 p_interim_tbl    IN interim_interest_tbl_type,
                                 x_payment        OUT NOCOPY NUMBER,
                                 x_rate           OUT NOCOPY NUMBER)
  IS
    l_api_name      CONSTANT VARCHAR2(30) := 'COMP_SO_IIR';
    i                            BINARY_INTEGER    := 0;
    m                            BINARY_INTEGER := 0;
    n                            BINARY_INTEGER := 0;
    p                            BINARY_INTEGER := 0;
    q                            BINARY_INTEGER := 0;
    r                            BINARY_INTEGER := 0;
    s                            BINARY_INTEGER := 0;
    l_time_zero_cost             NUMBER := 0;
    l_cost                       NUMBER;
    l_adv_payment                NUMBER := 0;
    l_currency_code              VARCHAR2(15);
    l_precision                  NUMBER(1);
    l_cf_dpp                     NUMBER;
    l_cf_ppy                     NUMBER;
    l_cf_amount                  NUMBER;
    l_cf_date                    DATE;
    l_cf_arrear                  VARCHAR2(1);
    l_days_in_future             NUMBER;
    l_periods                    NUMBER;
    l_irr                        NUMBER := 0;
    l_npv_rate                   NUMBER;
    l_npv_pay                    NUMBER;
    l_irr_limit                  NUMBER := NVL(ABS(fnd_profile.value('OKL_PRE_TAX_IRR_LIMIT')), 1000)/100;
    l_prev_npv_pay               NUMBER;
    l_prev_npv_sign_pay          NUMBER;
    l_crossed_zero_pay           VARCHAR2(1) := 'N';
    l_increment_pay              NUMBER := 0.1; -- 10% increment
    l_abs_incr_pay               NUMBER;
    l_prev_incr_sign_pay         NUMBER;
    l_prev_npv_rate              NUMBER;
    l_prev_npv_sign_rate         NUMBER;
    l_crossed_zero_rate          VARCHAR2(1) := 'N';
    l_increment_rate             NUMBER := 0.1; -- 10% increment
    l_abs_incr_rate              NUMBER;
    l_prev_incr_sign_rate        NUMBER;
    l_payment_inflow             NUMBER := 0;
    l_payment_inter              NUMBER := 0;
    l_asset_cost                 NUMBER := 0;
    l_residual_value             NUMBER := 0;
    ld_res_pay_start_date        DATE;
    ld_asset_start_date          DATE;
    l_subside_yn                 VARCHAR2(1) := NVL(p_subside_yn,'N');
    l_khr_start_date             DATE;

    Cursor khr_type_csr IS
    Select SCS_CODE,
           START_DATE
    From   okc_K_headers_b chr
    Where  chr.id = p_khr_id;

    khr_type_rec khr_type_csr%ROWTYPE;
    l_line_type VARCHAR2(256);

    -- Gets all the Payment inflow over the SO_PAYMENT/FREE_FORM1 lines
    CURSOR c_inflows(p_khr_id NUMBER,
                     p_kle_id NUMBER,
		     p_line_type VARCHAR2)
    IS
    SELECT DISTINCT
           sel_amt.id id,
           sel_amt.amount cf_amount,
           sel_amt.stream_element_date cf_date,
           sel_rate.amount rate,
           sel_rate.comments miss_amt,
           sel_amt.comments cf_arrear,
           sty.stream_type_purpose cf_purpose,
           DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
           DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
           chr_so.start_date
    FROM okl_streams stm,
         okl_strm_type_b sty,
         okl_strm_elements sel_rate,
         okl_strm_elements sel_amt,
         okc_k_headers_b chr_so,
         okc_k_lines_b cle,
         okc_line_styles_b lse,
         okc_rules_b sll,
         okc_rules_b slh,
         okc_rule_groups_b rgp
    WHERE stm.khr_id = p_khr_id
    AND stm.kle_id = p_kle_id
    AND stm.kle_id = cle.id
    AND stm.say_code = 'WORK'
    AND stm.purpose_code = 'FLOW'
    AND stm.sty_id = sty.id
    AND stm.id = sel_amt.stm_id
    AND sel_amt.comments IS NOT NULL
    AND stm.id = sel_rate.stm_id
    AND sel_rate.sel_id = sel_amt.id
    AND stm.kle_id = cle.id
    AND cle.dnz_chr_id = chr_so.id
    AND trunc(cle.START_DATE) = trunc(chr_so.START_DATE)
    AND cle.lse_id = lse.id
    AND lse.lty_code = p_line_type --'SO_PAYMENT'
    AND cle.id = rgp.cle_id
    AND rgp.rgd_code = 'LALEVL'
    AND rgp.id = slh.rgp_id
    AND slh.rule_information_category = 'LASLH'
    AND TO_NUMBER(slh.object1_id1) = stm.sty_id
    AND TO_CHAR(slh.id) = sll.object2_id1
    AND sll.rule_information_category = 'LASLL';
    -- Gets the Asset residual value
    CURSOR c_asset_rvs(p_khr_id NUMBER,
                       p_kle_id NUMBER,
		       p_line_type VARCHAR2)
    IS
    SELECT DISTINCT DECODE(rul_sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
           DECODE(rul_sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
           DECODE(rul_sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) months_per_period,
           cle_so.END_DATE
    FROM okc_k_headers_b chr_so,
         okc_line_styles_b lse_so,
         okc_k_lines_b cle_so,
         okc_rule_groups_b rgp_pay,
         okc_rules_b rul_slh,
         okc_rules_b rul_sll,
         okl_strm_type_b styt
    WHERE cle_so.id = p_kle_id
    AND cle_so.dnz_chr_id = p_khr_id
    AND cle_so.lse_id = lse_so.id
    AND cle_so.dnz_chr_id = chr_so.id
    AND trunc(cle_so.START_DATE) = trunc(chr_so.START_DATE )
    AND lse_so.lty_code = p_line_type --'SO_PAYMENT'
    AND cle_so.id = rgp_pay.cle_id
    AND rgp_pay.dnz_chr_id = cle_so.dnz_chr_id
    AND rgp_pay.rgd_code = 'LALEVL'
    AND rgp_pay.id = rul_slh.rgp_id
    AND rul_slh.rule_information_category = 'LASLH'
    AND TO_CHAR(rul_slh.id) = rul_sll.object2_id1
    AND rul_sll.rule_information_category = 'LASLL'
    AND TO_NUMBER(rul_slh.object1_id1) = styt.id
    AND styt.stream_type_purpose = 'RENT';

    -- To get the Currency code and Precision
    CURSOR get_curr_code_pre(p_khr_id NUMBER)
    IS
    SELECT NVL(a.precision,0) precision
    FROM fnd_currencies a,
         okc_k_headers_b b
    WHERE b.currency_code = a.currency_code
    AND b.id = p_khr_id;

    -- To get the Contract Start date
    CURSOR get_start_date(p_khr_id NUMBER)
    IS
    SELECT start_date
    FROM okc_k_headers_b b
    WHERE b.id = p_khr_id;

    TYPE cash_flow_rec_type IS RECORD (cf_amount NUMBER,
                                       cf_date   DATE,
                                       cf_purpose   VARCHAR2(150),
                                       cf_dpp    NUMBER,
                                       cf_ppy    NUMBER,
                                       cf_days   NUMBER,
                                       rate      NUMBER,
                                       miss_amt  okl_strm_elements.comments%TYPE);

    TYPE cash_flow_tbl_type IS TABLE OF cash_flow_rec_type INDEX BY BINARY_INTEGER;
    hdr_inflow_tbl  cash_flow_tbl_type;
    inflow_tbl      cash_flow_tbl_type;
    rv_tbl          cash_flow_tbl_type;
    outflow_tbl     cash_flow_tbl_type;
    pass_th_tbl     cash_flow_tbl_type;
    rec_exp_tbl     cash_flow_tbl_type;

    l_term NUMBER;

    l_day_convention_month VARCHAR2(30);
    l_day_convention_year VARCHAR2(30);
    l_days_in_year NUMBER;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'begin' );

    END IF;
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
    -- check if the target is correctly given
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'check if the target is correctly given' || ' ' || p_target );

    END IF;
    -- Fetch the day convention ..
    OKL_PRICING_UTILS_PVT.get_day_convention(
      p_id              => p_khr_id,
      p_source          => 'ISG',
      x_days_in_month   => l_day_convention_month,
      x_days_in_year    => l_day_convention_year,
      x_return_status   => x_return_status);
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'comp_so_iir Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
    END IF;
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_target NOT IN ('RATE','PMNT') THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_INVALID_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'Target');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'check if the target is correctly given - done');

    END IF;
    OPEN  get_start_date(P_khr_id => p_khr_id);
    FETCH get_start_date INTO l_khr_start_date;
    IF get_start_date%NOTFOUND THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE get_start_date;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'got start date');

    END IF;
    -- Summing up Asset cost
    -- And since the input is a so_payment line we sum up the asset's cost
    -- to the so_payment line, assuming the start date of the so_payment
    -- and Asset start date are same.
    OKL_LA_STREAM_PVT.get_so_asset_oec(p_khr_id        => p_khr_id,
                  p_kle_id        => p_kle_id,
                  p_subside_yn    => l_subside_yn,
                  x_return_status => x_return_status,
                  x_asset_oec     => l_cost,
                  x_start_date    => ld_asset_start_date);
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' get_so_asset_oec ' || l_cost|| x_return_status);
    END IF;
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' l_time_zero '|| x_return_status);
    END IF;
    l_time_zero_cost := l_time_zero_cost + NVL(l_cost, 0);

    OPEN khr_type_csr;
    FETCH khr_type_csr INTO khr_type_rec;
    CLOSE khr_type_csr;

    IF (INSTR( khr_type_rec.scs_code, 'LEASE') > 0) THEN
        l_line_type := 'FREE_FORM1';
    Else
        l_line_type := 'SO_PAYMENT';
    End If;

    -- Collecting the inflow amounts
    -- from the strm elements table since where the payment associated to the
    -- So_payment lines are broken into stream elements data
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'before inflows '|| x_return_status);
    END IF;
    FOR l_inflow IN c_inflows(p_khr_id => p_khr_id,
                              p_kle_id => p_kle_id,
			      p_line_type => l_line_type) LOOP
      n := n + 1;
      inflow_tbl(n).cf_amount := l_inflow.cf_amount;
      inflow_tbl(n).miss_amt  := l_inflow.miss_amt;
      inflow_tbl(n).cf_date   := l_inflow.cf_date;
      inflow_tbl(n).cf_purpose   := l_inflow.cf_purpose;
      inflow_tbl(n).cf_dpp    := l_inflow.days_per_period;
      inflow_tbl(n).cf_ppy    := l_inflow.periods_per_year;
      inflow_tbl(n).rate      := l_inflow.rate;
      inflow_tbl(n).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(
                                                          p_start_date    => l_inflow.start_date,
                                                          p_days_in_month => l_day_convention_month,
                                                          p_days_in_year => l_day_convention_year,
                                                          p_end_date      => l_inflow.cf_date,
                                                          p_arrears       => l_inflow.cf_arrear,
                                                          x_return_status => x_return_status);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      IF (inflow_tbl(n).rate IS NULL OR
         inflow_tbl(n).rate = OKL_API.G_MISS_NUM) AND
         p_target = 'RATE' THEN
        OKL_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => G_INVALID_VALUE,
                p_token1        => G_COL_NAME_TOKEN,
                p_token1_value  => 'Rate');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;

    -- Collecting the Residual Value amount
    -- Here since the Assets are associated to one so_payment line
    -- we sum up to get actual residual value , residual value percent
    -- are stored in rules
    FOR l_asset_rv IN c_asset_rvs(p_khr_id => p_khr_id,
                                  p_kle_id => p_kle_id,
			          p_line_type => l_line_type) LOOP
      p := p + 1;
      OKL_LA_STREAM_PVT.get_so_residual_value(p_khr_id         => p_khr_id,
                         p_kle_id         => p_kle_id,
                         p_subside_yn     => l_subside_yn,
                         x_return_status  => x_return_status,
                         x_residual_value => rv_tbl(p).cf_amount,
                         x_start_date     => ld_res_pay_start_date);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      l_residual_value    := rv_tbl(p).cf_amount;
      rv_tbl(p).cf_date   := l_asset_rv.end_date;
      rv_tbl(p).cf_dpp    := l_asset_rv.days_per_period;
      rv_tbl(p).cf_ppy    := l_asset_rv.periods_per_year;
      OKL_PRICING_PVT.get_rate(p_khr_id        => p_khr_id,
                               p_date          => rv_tbl(p).cf_date,
                               x_rate          => rv_tbl(p).rate,
                               x_return_status => x_return_status);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      IF (rv_tbl(p).rate IS NULL OR
         rv_tbl(p).rate = OKL_API.G_MISS_NUM) AND
         p_target = 'RATE' THEN
        OKL_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => G_INVALID_VALUE,
                p_token1        => G_COL_NAME_TOKEN,
                p_token1_value  => 'Rate');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      rv_tbl(p).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(
                                                      p_start_date    => ld_res_pay_start_date,
                                                      p_days_in_month => l_day_convention_month,
                                                      p_days_in_year => l_day_convention_year,
                                                      p_end_date      => rv_tbl(p).cf_date,
                                                      p_arrears       => 'Y',
                                                      x_return_status => x_return_status);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'after residual values  #' || p|| x_return_status);
    END IF;
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Collecting the Outflow amounts of asset
    -- Since we are summing up to the so_payment line
    -- We would have one asset cost
    IF ld_asset_start_date > l_khr_start_date THEN
      q := q + 1;
      OKL_LA_STREAM_PVT.get_so_asset_oec(
                        p_khr_id        => p_khr_id,
                        p_kle_id        => p_kle_id,
                        p_subside_yn    => l_subside_yn,
                        x_return_status => x_return_status,
                        x_asset_oec     => outflow_tbl(q).cf_amount,
                        x_start_date    => ld_asset_start_date);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      outflow_tbl(q).cf_amount := -(outflow_tbl(q).cf_amount);
      outflow_tbl(q).cf_date   := ld_asset_start_date;
      outflow_tbl(q).cf_dpp    := 1;
      outflow_tbl(q).cf_ppy    := 360;
      OKL_PRICING_PVT.get_rate(p_khr_id        => p_khr_id,
                               p_date          => outflow_tbl(q).cf_date,
                               x_rate          => outflow_tbl(q).rate,
                               x_return_status => x_return_status);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (outflow_tbl(q).rate IS NULL OR
          outflow_tbl(q).rate = OKL_API.G_MISS_NUM) AND
        p_target = 'RATE' THEN
        OKL_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => G_INVALID_VALUE,
                p_token1        => G_COL_NAME_TOKEN,
                p_token1_value  => 'Rate');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      outflow_tbl(q).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(
                                                           p_start_date    => ld_asset_start_date,
                                                           p_days_in_month => l_day_convention_month,
                                                           p_days_in_year => l_day_convention_year,
                                                           p_end_date      => ld_asset_start_date,
                                                           p_arrears       => 'N',
                                                           x_return_status => x_return_status);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- Validating Sum of all the inflow do not exceed the Total Time zero cost
    IF n > 0 THEN
      FOR n1 IN inflow_tbl.FIRST..inflow_tbl.LAST LOOP
        IF inflow_tbl(n1).cf_date <= ld_asset_start_date THEN
          l_adv_payment  :=  l_adv_payment + inflow_tbl(n1).cf_amount;
        END IF;
      END LOOP;
    END IF;
    IF r > 0 THEN
      FOR r1 IN pass_th_tbl.FIRST..pass_th_tbl.LAST LOOP
        IF pass_th_tbl(r1).cf_date <= ld_asset_start_date THEN
          l_adv_payment  :=  l_adv_payment + pass_th_tbl(r1).cf_amount;
        END IF;
      END LOOP;
    END IF;
    IF l_adv_payment >= l_time_zero_cost THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_IRR_CALC_INF_LOOP',
                           p_token1       => 'ADV_AMOUNT',
                           p_token1_value => l_adv_payment,
                           p_token2       => 'CAPITAL_AMOUNT',
                           p_token2_value => l_time_zero_cost);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To get the Currency code and Precision
    OPEN  get_curr_code_pre(p_khr_id => p_khr_id);
    FETCH get_curr_code_pre INTO l_precision;
    IF get_curr_code_pre%NOTFOUND THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'Currency Code ');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE get_curr_code_pre;

    -- Setting the IRR limit
    l_irr_limit := ROUND(NVL(ABS(fnd_profile.value('OKL_PRE_TAX_IRR_LIMIT')), 1000), 0)/100;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'l_irr_limit  ' || l_irr_limit);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || 'b4 getting into the loop  '|| x_return_status);
    END IF;
    LOOP
      i                 :=  i + 1;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' ### ITERATION ### | ### PVALUE ### | ### IRR ###  ');
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || i || ' | ' || l_npv_rate || ' | ' || l_irr);
      END IF;
      l_npv_rate        :=  -(l_time_zero_cost);
      l_npv_pay         :=  -(l_time_zero_cost);

      -------------------------------------------
      -- RV CASH INFLOWS
      -------------------------------------------
      IF p > 0 THEN
        FOR z IN rv_tbl.FIRST..rv_tbl.LAST LOOP
          l_cf_dpp          :=  rv_tbl(z).cf_dpp;
          l_cf_ppy          :=  rv_tbl(z).cf_ppy;
          l_cf_amount       :=  rv_tbl(z).cf_amount;
          l_cf_date         :=  rv_tbl(z).cf_date;
          l_days_in_future  :=  rv_tbl(z).cf_days;
          l_periods         :=  l_days_in_future / l_cf_dpp;
          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' ZERO divide rvs '|| x_return_status);
            END IF;
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          IF p_target = 'RATE' THEN
            l_npv_pay := l_npv_pay + (l_cf_amount  / POWER((1 + rv_tbl(z).rate/(l_cf_ppy*100)), l_periods));
          ELSIF p_target = 'PMNT' THEN
            l_npv_rate := l_npv_rate + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));
          END IF;
        END LOOP;
      END IF;

      -------------------------------------------
      -- LINE LEVEL CASH INFLOWS
      -------------------------------------------
  IF p_target = 'RATE' THEN
        l_term := 0;
        FOR y IN inflow_tbl.FIRST..inflow_tbl.LAST
	LOOP
          l_cf_dpp          :=  inflow_tbl(y).cf_dpp;
          l_cf_ppy          :=  inflow_tbl(y).cf_ppy;
          l_days_in_future  :=  inflow_tbl(y).cf_days;
          l_periods         :=  l_days_in_future / l_cf_dpp;
          IF inflow_tbl(y).miss_amt = 'Y' THEN
            l_term     :=  l_term + (1  / POWER((1 + inflow_tbl(y).rate/(l_cf_ppy*100)), l_periods));
          ELSIF inflow_tbl(y).miss_amt = 'N'  THEN
            l_cf_amount       :=  inflow_tbl(y).cf_amount;
            l_cf_date         :=  inflow_tbl(y).cf_date;
            IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN
              OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                   p_msg_name     => 'OKL_IRR_ZERO_DIV');
              x_return_status := OKL_API.G_RET_STS_ERROR;
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' ZERO divide indlows '|| x_return_status);
              END IF;
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
            END IF;
            l_npv_pay := l_npv_pay + (l_cf_amount  / POWER((1 + inflow_tbl(y).rate/(l_cf_ppy*100)), l_periods));
	  END IF;
        END LOOP;

	If (l_term <> 0 ) Then
	    l_payment_inflow := (-1 * l_npv_pay ) / l_term;
	else
              OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                   p_msg_name     => 'OKL_IRR_ZERO_DIV');
              x_return_status := OKL_API.G_RET_STS_ERROR;
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' ZERO divide indlows '|| x_return_status);
              END IF;
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        end if;

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' l_npv_pay ' || l_npv_pay );
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' l_term ' || l_term );

              END IF;
	l_npv_pay := 0;
  Else

      IF n > 0 THEN
        FOR y IN inflow_tbl.FIRST..inflow_tbl.LAST LOOP
          l_cf_dpp          :=  inflow_tbl(y).cf_dpp;
          l_cf_ppy          :=  inflow_tbl(y).cf_ppy;
          IF inflow_tbl(y).miss_amt = 'Y' AND p_target = 'RATE' THEN
            l_cf_amount     :=  l_payment_inflow;
          ELSIF inflow_tbl(y).miss_amt = 'N'  THEN
            l_cf_amount     :=  inflow_tbl(y).cf_amount;
          END IF;
          l_cf_date         :=  inflow_tbl(y).cf_date;
          l_days_in_future  :=  inflow_tbl(y).cf_days;
          l_periods         :=  l_days_in_future / l_cf_dpp;
          IF (l_periods < 1) AND (l_irr/l_cf_ppy <= -1) THEN
            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' ZERO divide indlows '|| x_return_status);
            END IF;
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          IF p_target = 'RATE' THEN
            l_npv_pay := l_npv_pay + (l_cf_amount  / POWER((1 + inflow_tbl(y).rate/(l_cf_ppy*100)), l_periods));
          ELSIF p_target = 'PMNT' THEN
            l_npv_rate := l_npv_rate + (l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods));
          END IF;
        END LOOP;
      END IF;

  End If;

      IF p_target = 'RATE' THEN
        IF ROUND(l_npv_pay, l_precision+4) = 0 THEN
          x_payment    := l_payment_inflow;
          EXIT;
        END IF;
      ELSIF p_target = 'PMNT' THEN
        IF ROUND(l_npv_rate, l_precision+4) = 0 THEN
          x_rate    := l_irr;
          EXIT;
        END IF;
      END IF;
      IF p_target = 'RATE' THEN
        IF SIGN(l_npv_pay) <> SIGN(l_prev_npv_pay) AND l_crossed_zero_pay = 'N' THEN
          l_crossed_zero_pay := 'Y';
        END IF;
        IF l_crossed_zero_pay = 'Y' THEN
          l_abs_incr_pay := ABS(l_increment_pay) / 2;
        ELSE
          l_abs_incr_pay := ABS(l_increment_pay);
        END IF;
        IF i > 1 THEN
          IF SIGN(l_npv_pay) <> l_prev_npv_sign_pay THEN
            IF l_prev_incr_sign_pay = 1 THEN
              l_increment_pay := - l_abs_incr_pay;
            ELSE
              l_increment_pay := l_abs_incr_pay;
            END IF;
          ELSE
            IF l_prev_incr_sign_pay = 1 THEN
              l_increment_pay := l_abs_incr_pay;
            ELSE
              l_increment_pay := - l_abs_incr_pay;
            END IF;
          END IF;
        ELSE
          IF SIGN(l_npv_pay) = -1 THEN
            l_increment_pay := l_increment_pay;
          ELSIF SIGN(l_npv_pay) = 1 THEN
            l_increment_pay := -l_increment_pay;
          END IF;
        END IF;
        l_payment_inflow  := l_payment_inflow + l_increment_pay;
        l_prev_incr_sign_pay  :=  SIGN(l_increment_pay);
        l_prev_npv_sign_pay   :=  SIGN(l_npv_pay);
        l_prev_npv_pay        :=  l_npv_pay;
      ELSIF p_target = 'PMNT' THEN
        IF SIGN(l_npv_rate) <> SIGN(l_prev_npv_rate) AND l_crossed_zero_rate = 'N' THEN
          l_crossed_zero_rate := 'Y';
        END IF;
        IF l_crossed_zero_rate = 'Y' THEN
          l_abs_incr_rate := ABS(l_increment_rate) / 2;
        ELSE
          l_abs_incr_rate := ABS(l_increment_rate);
        END IF;
        IF i > 1 THEN
          IF SIGN(l_npv_rate) <> l_prev_npv_sign_rate THEN
            IF l_prev_incr_sign_rate = 1 THEN
              l_increment_rate := - l_abs_incr_rate;
            ELSE
              l_increment_rate := l_abs_incr_rate;
            END IF;
          ELSE
            IF l_prev_incr_sign_rate = 1 THEN
              l_increment_rate := l_abs_incr_rate;
            ELSE
              l_increment_rate := - l_abs_incr_rate;
            END IF;
          END IF;
        ELSE
          IF SIGN(l_npv_rate) = -1 THEN
            l_increment_rate :=  -l_increment_rate;
          END IF;
        END IF;
        l_irr             :=  l_irr + l_increment_rate;
        IF ABS(l_irr) > l_irr_limit THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_IRR_CALC_IRR_LIMIT',
                               p_token1       => 'IRR_LIMIT',
                               p_token1_value => l_irr_limit*100);
          x_return_status := OKL_API.G_RET_STS_ERROR;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' 100000%  '|| x_return_status);
            END IF;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        l_prev_incr_sign_rate  :=  SIGN(l_increment_rate);
        l_prev_npv_sign_rate   :=  SIGN(l_npv_rate);
        l_prev_npv_rate        :=  l_npv_rate;
      END IF;
    END LOOP;
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF get_curr_code_pre%ISOPEN THEN
        CLOSE get_curr_code_pre;
      END IF;
      IF c_asset_rvs%ISOPEN THEN
        CLOSE c_asset_rvs;
      END IF;
      IF c_inflows%ISOPEN THEN
        CLOSE c_inflows;
      END IF;
      IF get_start_date%ISOPEN THEN
        CLOSE get_start_date;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF get_curr_code_pre%ISOPEN THEN
        CLOSE get_curr_code_pre;
      END IF;
      IF c_asset_rvs%ISOPEN THEN
        CLOSE c_asset_rvs;
      END IF;
      IF c_inflows%ISOPEN THEN
        CLOSE c_inflows;
      END IF;
      IF get_start_date%ISOPEN THEN
        CLOSE get_start_date;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
      IF get_curr_code_pre%ISOPEN THEN
        CLOSE get_curr_code_pre;
      END IF;
      IF c_asset_rvs%ISOPEN THEN
        CLOSE c_asset_rvs;
      END IF;
      IF c_inflows%ISOPEN THEN
        CLOSE c_inflows;
      END IF;
      IF get_start_date%ISOPEN THEN
        CLOSE get_start_date;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END comp_so_iir;


  PROCEDURE  target_parameter(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2,
                          p_khr_id        IN  NUMBER,
                          p_kle_id        IN  NUMBER,
                          p_rate_type     IN  VARCHAR2,
                          p_target_param  IN  VARCHAR2,
                          p_pay_tbl       IN  OKL_STREAM_GENERATOR_PVT.payment_tbl_type,
                          x_pay_tbl       OUT NOCOPY OKL_STREAM_GENERATOR_PVT.payment_tbl_type,
                          x_overall_rate  OUT NOCOPY NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2) IS

    CURSOR c_hdr IS
      SELECT chr.template_yn,
             chr.currency_code,
             chr.start_date,
             chr.end_date,
             khr.deal_type,
             khr.term_duration,
             NVL(khr.generate_accrual_yn, 'Y')
      FROM   okc_k_headers_b chr,
             okl_k_headers khr
      WHERE  khr.id = p_khr_id
        AND  chr.id = khr.id;

    l_hdr c_hdr%ROWTYPE;

    Cursor c_rv IS
    SELECT SUM(to_number(nvl(rul_rv.rule_information2,rul_rv.rule_information4))) Residual_value,
           DECODE(rul_sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
           DECODE(rul_sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
           DECODE(rul_sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) months_per_period,
           cle_so.id cle_id,
           cle_so.start_date
    FROM okc_k_headers_b chr_rv,
         okc_line_styles_b lse_rv,
         okc_k_lines_b cle_rv,
         okc_rules_b rul_rv,
         okc_rule_groups_b rgp_rv,
         okc_line_styles_b lse_so,
         okc_k_lines_b cle_so,
         okc_rules_b rul_so,
         okc_rule_groups_b rgp_so,
         okc_rule_groups_b rgp_pay,
         okc_rules_b rul_slh,
         okc_rules_b rul_sll,
         okl_strm_type_b styt
    WHERE rgp_so.cle_id = p_kle_id
    AND rgp_so.dnz_chr_id = p_khr_id
    AND rgp_so.rgd_code = 'SOPYSC'
    AND rgp_so.dnz_chr_id = rul_so.dnz_chr_id
    AND rgp_so.id = rul_so.rgp_id
    AND rul_so.rule_information_category = 'SOPMSC'
    AND rgp_so.cle_id = cle_so.id
    AND cle_so.id = p_kle_id
    AND cle_so.dnz_chr_id = rul_so.dnz_chr_id
    AND cle_so.lse_id = lse_so.id
    AND lse_so.lty_code = 'SO_PAYMENT'
    AND rul_rv.object1_id1 = to_char(rul_so.id)
    AND rul_rv.dnz_chr_id = p_khr_id
    AND rul_rv.dnz_chr_id = rul_so.dnz_chr_id
    AND rul_rv.rgp_id = rgp_rv.id
    AND rgp_rv.rgd_code = 'SOPSAD'
    AND rgp_rv.dnz_chr_id = rul_so.dnz_chr_id
    AND rgp_rv.cle_id = cle_rv.id
    AND cle_rv.lse_id = lse_rv.id
    AND lse_rv.lty_code = 'FREE_FORM1'
    AND rgp_rv.dnz_chr_id = chr_rv.id
    AND chr_rv.START_DATE = cle_rv.START_DATE
    AND cle_so.id = rgp_pay.cle_id
    AND rgp_pay.rgd_code = 'LALEVL'
    AND rgp_pay.id = rul_slh.rgp_id
    AND rul_slh.rule_information_category = 'LASLH'
    AND TO_CHAR(rul_slh.id) = rul_sll.object2_id1
    AND rul_sll.rule_information_category = 'LASLL'
    AND rul_slh.object1_id1 = TO_CHAR(styt.id)
    AND styt.stream_type_purpose = 'RENT'
    GROUP BY DECODE(rul_sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360),
             DECODE(rul_sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1),
             DECODE(rul_sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12),
             cle_so.id,
             cle_so.start_date;

    r_rv c_rv%ROWTYPE;

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'target_parameter';

    l_rate NUMBER;
    l_payment NUMBER;
    l_payment_count NUMBER;

    l_capital_cost   NUMBER;
    l_residual_value NUMBER;
    l_start_date     DATE;

    Cursor l_strms_csr Is
    Select id
    from okl_streams
    where khr_id = p_khr_id
      --and kle_id = p_kle_id
      and purpose_code in ('PLOW', 'FLOW', 'STUBS');

    l_strms_rec l_strms_csr%ROWTYPE;

    Cursor c_sty ( n VARCHAR2 ) IS
    Select id
    from okl_strm_type_tl
    where language = 'US'
      and name = n;

    r_sty c_sty%ROWTYPE;
    lt_pay_tbl OKL_STREAM_GENERATOR_PVT.payment_tbl_type;
    l_pay_tbl OKL_STREAM_GENERATOR_PVT.payment_tbl_type;
    l_sty_id NUMBER := -1;

    l_interim_interest NUMBER;
    l_interim_days NUMBER;
    l_interim_dpp NUMBER;

    l_interim_tbl  interim_interest_tbl_type;

    l_stmv_tbl okl_streams_pub.stmv_tbl_type;
    x_stmv_tbl okl_streams_pub.stmv_tbl_type;

  --Added sll.rule_information2 in order by clause by djanaswa for bug 6007644

    Cursor c_fee IS
    SELECT DISTINCT
           cle.id kleId,
	   stm.id styId,
           sll.object1_id1 frequency,
           TO_NUMBER(sll.rule_information3) periods,
           FND_DATE.canonical_to_date(sll.rule_information2) start_date,
           sll.rule_information5 structure,
           sll.rule_information10 advance_arrears,
           FND_NUMBER.canonical_to_number(sll.rule_information6) amount,
           TO_NUMBER(sll.rule_information7) stub_days,
           TO_NUMBER(sll.rule_information8) stub_amount
    FROM okc_k_headers_b chr_so,
         okc_k_lines_b cle,
         okl_k_lines kle,
         okc_line_styles_b lse,
         okc_rules_b sll,
         okc_rules_b slh,
         okc_rule_groups_b rgp,
	 okl_strm_type_tl stm
    WHERE chr_so.id = p_khr_id
    and cle.sts_code in( 'INCOMPLETE', 'COMPLETE')--'ENTERED'
    AND cle.dnz_chr_id = chr_so.id
    AND kle.id = cle.id
    AND trunc(cle.START_DATE) = trunc(chr_so.START_DATE)
    AND cle.lse_id = lse.id
    AND (lse.lty_code = 'FEE' OR lse.lty_code = 'LINK_FEE_ASSET')
    AND ( kle.fee_type <> 'CAPITALIZED' OR kle.fee_type IS NULL )
    AND cle.id = rgp.cle_id
    AND rgp.rgd_code = 'LALEVL'
    AND rgp.id = slh.rgp_id
    AND slh.rule_information_category = 'LASLH'
    AND TO_NUMBER(slh.object1_id1) = stm.id
    AND TO_CHAR(slh.id) = sll.object2_id1
    AND sll.rule_information_category = 'LASLL'
    order by stm.id, FND_DATE.canonical_to_date(sll.rule_information2);

    r_fee c_fee%ROWTYPE;
    i BINARY_INTEGER;
    j BINARY_INTEGER;

    Cursor c_subs Is
    Select 'Y'
    From dual
    where Exists(
    select kle.id
     from  okl_k_lines_full_v kle,
           okc_line_styles_b lse,
	   okc_statuses_b sts
     where KLE.LSE_ID = LSE.ID
          and lse.lty_code = 'SUBSIDY'
          and kle.dnz_chr_id = p_khr_id
	  and sts.code = kle.sts_code
	  and sts.ste_code not in ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED'));

    r_subs c_subs%ROWTYPE;
    l_subsidies_yn VARCHAR2(1);
    l_subsidy_amount  NUMBER;
    l_kle_id NUMBER;
    -- Bug 4626837 : Start
    l_rent_strm_name     VARCHAR2(256);
    l_rent_strm_id       NUMBER;
    -- Bug 4626837 : End

  Begin
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'begin' );

      END IF;
      x_return_status := G_RET_STS_SUCCESS;

      OPEN  c_hdr;
      FETCH c_hdr INTO l_hdr;
      CLOSE c_hdr;

      For i in p_pay_tbl.FIRST..p_pay_tbl.LAST
      LOOP
          l_pay_tbl(i) := p_pay_tbl(i);
	  --l_pay_tbl(i).rate := l_pay_tbl(i).rate / 100.0;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' date ' || l_pay_tbl(i).start_date || ' amout ' || l_pay_tbl(i).amount );
      END IF;
          If ( l_pay_tbl(i).periods IS NOT NULL) AND ( l_pay_tbl(i).amount IS NULL ) Then
	      l_pay_tbl(i).amount := -9999999;
          ElsIf ( l_pay_tbl(i).periods IS NULL) AND ( l_pay_tbl(i).stub_amount IS NULL ) Then
	      l_pay_tbl(i).stub_amount := -9999999;
	  End If;
      END LOOP;

 -- cannot have more than one payment missing.
      OKL_LA_STREAM_PVT.validate_payments(
                             p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             p_khr_id        => p_khr_id,
			     p_paym_tbl      => l_pay_tbl,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'validate payments ' || x_return_status );
      END IF;
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Bug 4626837: Start
      --Fetch the Stream Type ID based on the purpose instead of the name
      OKL_ISG_UTILS_PVT.get_primary_stream_type(
        p_khr_id              => p_khr_id,
        p_deal_type           => l_hdr.deal_type,
        p_primary_sty_purpose => 'RENT',
        x_return_status       => x_return_status,
        x_primary_sty_id      => l_rent_strm_id,
        x_primary_sty_name    => l_rent_strm_name);
     IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     -- Bug 4626837: End
     OKL_STREAM_GENERATOR_PVT.generate_cash_flows(
                             p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             p_khr_id        => p_khr_id,
                             p_kle_id        => p_kle_id,
                             p_sty_id        => l_rent_strm_id,
                             p_payment_tbl   => l_pay_tbl,
                             x_payment_count => l_payment_count,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'generate_cash_flows ' || x_return_status );

      END IF;
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;


      OPEN c_subs;
      FETCH c_subs INTO l_subsidies_yn;
      CLOSE c_subs;
      l_subsidies_yn := nvl( l_subsidies_yn, 'N' );

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' subsidy ' || l_subsidies_yn );

      END IF;
      okl_la_stream_pvt.get_so_asset_oec(p_khr_id,
                                     p_kle_id,
				     l_subsidies_yn,
                                     x_return_status,
				     l_capital_cost,
				     l_start_date);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' get_asset_oec ' || to_char( l_capital_cost)|| x_return_status);
      END IF;
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      Okl_la_stream_pvt.get_so_residual_value(p_khr_id,
                                          p_kle_id,
				          l_subsidies_yn,
                                          x_return_status,
					  l_residual_value,
					  l_start_date);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' get_residual_value  ' || to_char( l_residual_value )|| x_return_status);
      END IF;
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      If ( p_rate_type = 'PRE_TAX_IRR' )  Then

          i := 0;

          FOR r_fee in c_fee
          LOOP

              l_kle_id  := r_fee.kleId;
              If ( l_sty_id = r_fee.styId ) Then

                  i := i + 1;
	          lt_pay_tbl(i).amount     := r_fee.amount;
	          lt_pay_tbl(i).start_date := r_fee.start_date;
	          lt_pay_tbl(i).arrears_yn := r_fee.advance_arrears;
	          lt_pay_tbl(i).periods    := r_fee.periods;
	          lt_pay_tbl(i).frequency  := r_fee.frequency;
	          lt_pay_tbl(i).stub_days    := r_fee.stub_days;
	          lt_pay_tbl(i).stub_amount  := r_fee.stub_amount;

                 If (l_pay_tbl.COUNT = 1 ) THen --bug# 4129476
		  lt_pay_tbl(i).rate := l_pay_tbl(l_pay_tbl.FIRST).rate;
		 Else

                  For j in l_pay_tbl.FIRST..(l_pay_tbl.LAST-1)
	          LOOP

	              If (( TRUNC(r_fee.start_date) >= TRUNC(l_pay_tbl(j).start_date) ) AND
		          ( TRUNC(r_fee.start_date) < TRUNC(l_pay_tbl(j+1).start_date))) Then

			  If ( l_pay_tbl(j).arrears_yn = 'Y' ) Then
		              lt_pay_tbl(i).rate := l_pay_tbl(j+1).rate;
			  else
		              lt_pay_tbl(i).rate := l_pay_tbl(j).rate;
			  End If;
			  exit;

		      End If;
	          END LOOP;

		 End If;

	      Else

	          If ( lt_pay_tbl.COUNT > 0 ) Then


                      OKL_STREAM_GENERATOR_PVT.generate_cash_flows(
                                     p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     p_khr_id        => p_khr_id,
		                     p_kle_id        => r_fee.kleId,
		                     p_sty_id        => l_sty_id,
		            	     p_payment_tbl   => lt_pay_tbl,
			             x_payment_count => l_payment_count,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data);


                      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

	          End If;

                  lt_pay_tbl.DELETE;
	          i := 1;
	          l_sty_id := r_fee.styId;
	          lt_pay_tbl(i).amount     := r_fee.amount;
	          lt_pay_tbl(i).start_date := r_fee.start_date;
	          lt_pay_tbl(i).arrears_yn := r_fee.advance_arrears;
	          lt_pay_tbl(i).periods    := r_fee.periods;
	          lt_pay_tbl(i).frequency  := r_fee.frequency;
	          lt_pay_tbl(i).stub_days    := r_fee.stub_days;
	          lt_pay_tbl(i).stub_amount  := r_fee.stub_amount;

                 If (l_pay_tbl.COUNT = 1 ) THen --bug# 4129476
		  lt_pay_tbl(i).rate := l_pay_tbl(l_pay_tbl.FIRST).rate;
		 Else
                  For j in l_pay_tbl.FIRST..(l_pay_tbl.LAST-1)
	          LOOP
	               If (( TRUNC(r_fee.start_date) >= TRUNC(l_pay_tbl(j).start_date) ) AND
		           ( TRUNC(r_fee.start_date) < TRUNC(l_pay_tbl(j+1).start_date))) Then
		           lt_pay_tbl(i).rate := l_pay_tbl(j).rate;
		       End If;
	          END LOOP;

		 End If;

	      End If;

          END LOOP;

	  If ( lt_pay_tbl.COUNT > 0 ) Then

              OKL_STREAM_GENERATOR_PVT.generate_cash_flows(
                                     p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     p_khr_id        => p_khr_id,
		                     p_kle_id        => l_kle_Id,
		                     p_sty_id        => l_sty_id,
		            	     p_payment_tbl   => lt_pay_tbl,
			             x_payment_count => l_payment_count,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data);


               IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

	  End If;


          OPEN c_sty ( 'RESIDUAL VALUE' );
          FETCH c_sty INTO r_sty;
          CLOSE c_sty;

          OPEN c_rv;
          FETCH c_rv INTO r_rv;
          CLOSE c_rv;

          lt_pay_tbl.DELETE;

          l_interim_tbl(1).cf_days   := l_interim_days;
          l_interim_tbl(1).cf_amount := l_interim_interest;
          l_interim_tbl(1).cf_dpp    := l_interim_dpp;

          comp_so_pre_tax_irr(
	       p_api_version   => p_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_khr_id        => p_khr_id,
	       p_kle_id        => p_kle_id,
	       p_interim_tbl   => l_interim_tbl,
	       p_target        => p_target_param,
	       p_subside_yn    => l_subsidies_yn,
	       x_payment       => l_payment,
	       x_rate          => l_rate);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'comp_so_pre_tax_irr ' || x_return_status );
      END IF;
          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

      ElsIf ( p_rate_type = 'IMPL_INTEREST_RATE' )  Then

          l_interim_tbl(1).cf_days   := l_interim_days;
          l_interim_tbl(1).cf_amount := l_interim_interest;
          l_interim_tbl(1).cf_dpp    := l_interim_dpp;

          comp_so_iir(
	       p_api_version   => p_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_khr_id        => p_khr_id,
	       p_kle_id        => p_kle_id,
	       p_interim_tbl   => l_interim_tbl,
	       p_target        => p_target_param,
	       p_subside_yn    => l_subsidies_yn,
	       x_payment       => l_payment,
	       x_rate          => l_rate);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'comp_so_iir ' || x_return_status );
      END IF;
          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

      ElsIf ( p_rate_type = 'PRE_TAX_YIELD' )  Then
-- Same as Booking Yield whenever there is no interim cost. for SO there are no interim cost

          l_interim_tbl(1).cf_days   := l_interim_days;
          l_interim_tbl(1).cf_amount := l_interim_interest;
          l_interim_tbl(1).cf_dpp    := l_interim_dpp;

          comp_so_iir(
	       p_api_version   => p_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_khr_id        => p_khr_id,
	       p_kle_id        => p_kle_id,
	       p_interim_tbl   => l_interim_tbl,
	       p_target        => p_target_param,
	       p_subside_yn    => l_subsidies_yn,
	       x_payment       => l_payment,
	       x_rate          => l_rate);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'comp_so_iir ' || x_return_status );
      END IF;
          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

      Else

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_INVALID_RATE_TYPE',
                             p_token1       => 'RATE_TYPE',
                             p_token1_value => p_rate_type);

        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;

      End If;

      If (p_target_param = 'RATE') AND (l_payment < 0 ) THen

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_LLAP_CANNOT_PRICE');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;

      End If;

      FOR i in l_pay_tbl.FIRST..l_pay_tbl.LAST
      LOOP
          x_pay_tbl(i) := l_pay_tbl(i);

          If ( x_pay_tbl(i).amount = -9999999 ) Then
	      x_pay_tbl(i).amount := l_payment;
          elsIf ( x_pay_tbl(i).stub_amount = -9999999 ) Then
	      x_pay_tbl(i).stub_amount := l_payment;

	  end If;

          If ( nvl(x_overall_rate, -9999999) = -9999999 ) Then
	      x_overall_rate := l_rate * 100.00;
	  end If;

          --if ( nvl(x_pay_tbl(i).rate, -9999999) <> -9999999 ) then
	  --    x_pay_tbl(i).rate := x_pay_tbl(i).rate * 100.00;
	  --End If;

      END LOOP;

     i := 0;
     FOR l_strms_rec in l_strms_csr
     LOOP

         i := i + 1;
         l_stmv_tbl(i).id := l_strms_rec.ID;

     END LOOP;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' #of streams to delete - ' || i );
     END IF;
     If ( i > 0 ) Then

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || i || '# of streams are getting deleted ' );
         END IF;
         Okl_Streams_pub.delete_streams(
                          p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_stmv_tbl => l_stmv_tbl);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' DONE '|| x_return_status);

         END IF;
    End If;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'end' );

    END IF;
    EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

     i := 0;
     FOR l_strms_rec in l_strms_csr
     LOOP

         i := i + 1;
         l_stmv_tbl(i).id := l_strms_rec.ID;

     END LOOP;

     If ( i > 0 ) Then

         Okl_Streams_pub.delete_streams(
                          p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_stmv_tbl => l_stmv_tbl);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

    End If;
      x_return_status := G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

     i := 0;
     FOR l_strms_rec in l_strms_csr
     LOOP

         i := i + 1;
         l_stmv_tbl(i).id := l_strms_rec.ID;

     END LOOP;

     If ( i > 0 ) Then

         Okl_Streams_pub.delete_streams(
                          p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_stmv_tbl => l_stmv_tbl);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

    End If;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

     i := 0;
     FOR l_strms_rec in l_strms_csr
     LOOP

         i := i + 1;
         l_stmv_tbl(i).id := l_strms_rec.ID;

     END LOOP;

     If ( i > 0 ) Then

         Okl_Streams_pub.delete_streams(
                          p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_stmv_tbl => l_stmv_tbl);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

    End If;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

  End target_parameter;

  ---------------------------------------------------------------------------
  -- PROCEDURE target_pay_down
  --
  -- Description
  --
  ---------------------------------------------------------------------------
  PROCEDURE target_pay_down (
                          p_khr_id          IN  NUMBER,
                          p_ppd_date        IN  DATE,
                          p_ppd_amount      IN  NUMBER,
                          p_pay_start_date  IN  DATE,
                          p_iir             IN  NUMBER,
                          p_term            IN  NUMBER,
                          p_frequency       IN  VARCHAR2,
                          p_arrears_yn      IN  VARCHAR2,
                          x_pay_amount      OUT NOCOPY NUMBER,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2) IS


    -- Cursor definition implies RENT must be defined at Asset Level

    CURSOR c_asset_rvs ( kleId NUMBER ) IS
      SELECT DISTINCT
             kle.id,
             NVL(kle.residual_value, 0) cf_amount,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
             DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
             DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) months_per_period,
             cle.start_date
      FROM   okl_k_lines kle,
             okc_k_lines_b cle,
             okc_line_styles_b lse,
             okc_rule_groups_b rgp,
             okc_rules_b slh,
             okc_rules_b sll,
             okl_strm_type_b styt
      WHERE  cle.chr_id = p_khr_id
        AND  cle.sts_code in ( 'BOOKED', 'TERMINATED' )
        AND  cle.lse_id = lse.id
        AND  cle.id = kleId
        AND  lse.lty_code = 'FREE_FORM1'
        AND  cle.id = kle.id
        AND  kle.id = rgp.cle_id
        AND  rgp.rgd_code = 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
        AND  TO_NUMBER(slh.object1_id1) = styt.id
        AND  styt.stream_type_purpose = 'RENT'; -- Bug 4626837


    CURSOR c_asset_cost IS
      SELECT cle.id id,
             cle.start_date start_date
      FROM   okc_k_lines_b cle,
             okc_line_styles_b lse
      WHERE  cle.chr_id = p_khr_id
        AND  cle.sts_code in ( 'BOOKED', 'TERMINATED' )
        AND  cle.lse_id = lse.id
        AND  lse.lty_code = 'FREE_FORM1'
        AND  cle.id IN (
           SELECT distinct stm.kle_id
            FROM okl_streams stm,
                 okl_strm_elements ele,
                 okl_strm_type_b sty
            WHERE stm.khr_id = p_khr_id
              AND stm.say_code = 'CURR'
              AND stm.active_yn = 'Y'
              AND stm.sty_id = sty.id
              AND sty.stream_type_purpose = 'LOAN PAYMENT'
              AND ele.stm_id = stm.id
              AND ele.stream_element_date > p_ppd_date );

    Cursor c_stub IS
    Select sel.id
    from okl_streams stm,
         okl_strm_elements sel
    where stm.khr_id = p_khr_id
      and stm.say_code     =  'HIST'
      and stm.SGN_CODE     =  'MANL'
      and stm.active_yn    =  'N'
      and stm.purpose_code =  'STUBS'
      and stm.comments     =  'STUB STREAMS'
      and sel.stm_id = stm.id;

    l_stub_id NUMBER;

    --------------------------
    -- PERFORMANCE ENHANCEMENT SECTION
    --------------------------
    TYPE cash_flow_rec_type IS RECORD (cf_amount NUMBER,
                                       cf_date   DATE,
                                       cf_purpose   VARCHAR2(150),
                                       cf_dpp    NUMBER,
                                       cf_ppy    NUMBER,
                                       cf_days   NUMBER,
				       kleId     NUMBER);

    TYPE cash_flow_tbl_type IS TABLE OF cash_flow_rec_type INDEX BY BINARY_INTEGER;

    hdr_inflow_tbl  cash_flow_tbl_type;
    inflow_tbl      cash_flow_tbl_type;
    subs_inflow_tbl      cash_flow_tbl_type;
    rv_tbl          cash_flow_tbl_type;
    outflow_tbl     cash_flow_tbl_type;
    subsidies_tbl      cash_flow_tbl_type;

    m BINARY_INTEGER := 0;
    n BINARY_INTEGER := 0;
    p BINARY_INTEGER := 0;
    q BINARY_INTEGER := 0;
    r BINARY_INTEGER := 0;
    s BINARY_INTEGER := 0;

    cursor l_hdr_csr IS
    select chr.orig_system_source_code,
           chr.start_date,
           chr.end_date,
           chr.template_yn,
	   chr.authoring_org_id,
	   chr.inv_organization_id,
           khr.deal_type,
           khr.implicit_interest_rate,
           pdt.id  pid,
	   nvl(pdt.reporting_pdt_id, -1) report_pdt_id,
           chr.currency_code currency_code,
           khr.term_duration term
    from   okc_k_headers_v chr,
           okl_k_headers khr,
           okl_products_v pdt
    where khr.id = chr.id
        and chr.id = p_khr_id
        and khr.pdt_id = pdt.id(+);

    l_hdr_rec l_hdr_csr%ROWTYPE;
    --------------------------
    -- END PERFORMANCE ENHANCEMENT SECTION
    --------------------------
    lx_msg_count      NUMBER;
    lx_msg_data       VARCHAR2(4000);
    p_start_date      DATE;
    l_end_date        DATE;
    l_time_zero_cost  NUMBER            := 0;
    l_cost            NUMBER;
    l_residual_value  NUMBER;
    l_adv_payment     NUMBER            := 0;
    l_subsidy_amount     NUMBER            := 0;
    l_currency_code   VARCHAR2(15);
    l_precision       NUMBER(1);

    l_cf_dpp          NUMBER;
    l_cf_ppy          NUMBER;
    l_cf_amount       NUMBER;
    l_cf_date         DATE;
    l_cf_arrear       VARCHAR2(1);
    l_days_in_future  NUMBER;
    l_periods         NUMBER;
    l_deposit_date    DATE;

    i                 BINARY_INTEGER    := 0;
    l_nthTerm         BINARY_INTEGER    := 0;
    l_pay_amount      NUMBER := 0;
    l_iir             NUMBER := p_iir/100.0;
    l_npv             NUMBER := 0;

    l_prev_npv        NUMBER;
    l_prev_npv_sign   NUMBER;

    l_crossed_zero    VARCHAR2(1)       := 'N';

    l_increment       NUMBER            := 0.1; -- 10% increment
    l_abs_incr        NUMBER;
    l_prev_incr_sign  NUMBER;

    a binary_integer := 0;
    b binary_integer := 0;

    lx_return_status    VARCHAR2(1);

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'target_pay_down';
    p_subsidies_yn VARCHAR2(1) := 'N';
    l_months NUMBER;
    l_dpp NUMBER;
    l_ppy NUMBER;

    l_blnStretch VARCHAR2(1) := 'N';
    xpay NUMBER := 0;

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_tmp_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_pt_tbl                 okl_streams_pub.selv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    l_pt_rec                 okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

    l_principal_balance NUMBER;
    l_advance_arrears VARCHAR2(256);
    L_ACCUMULATED_INT NUMBER;
    l_term NUMBER := 0;

    l_number_of_assets BINARY_INTEGER := 0;

    l_day_convention_month VARCHAR2(30);
    l_day_convention_year VARCHAR2(30);
    l_days_in_year NUMBER;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'begin' );
    END IF;
    x_return_status := G_RET_STS_SUCCESS;

   -- Fetch the day convention ..
   OKL_PRICING_UTILS_PVT.get_day_convention(
     p_id              => p_khr_id,
     p_source          => 'ISG',
     x_days_in_month   => l_day_convention_month,
     x_days_in_year    => l_day_convention_year,
     x_return_status   => lx_return_status);
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
   END IF;
   IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

    OPEN l_hdr_csr;
    FETCH l_hdr_csr INTO l_hdr_rec;
    CLOSE l_hdr_csr;

    p_start_date := l_hdr_rec.start_date;
    l_end_date   := l_hdr_rec.end_date;

    IF p_frequency = 'M' THEN
      l_months := 1;
      l_dpp    := 30;
      l_ppy    := 12;
    ELSIF p_frequency = 'Q' THEN
      l_months := 3;
      l_dpp    := 90;
      l_ppy    := 4;
    ELSIF p_frequency = 'S' THEN
      l_months := 6;
      l_dpp    := 180;
      l_ppy    := 2;
    ELSIF p_frequency = 'A' THEN
      l_months := 12;
      l_dpp    := 360;
      l_ppy    := 1;
    END IF;

    If ( p_arrears_yn = 'Y' ) then
        l_advance_arrears := 'ARREARS';
    Else
        l_advance_arrears := 'ADVANCE';
    END if;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' getting asset cost ' );
    END IF;
    FOR l_asset_cost IN c_asset_cost LOOP

         l_number_of_assets := l_number_of_assets + 1;

         OKL_STREAM_GENERATOR_PVT.get_sched_principal_bal(
                                    p_api_version   => 1.0,
                                    p_init_msg_list => 'T',
                                    p_khr_id        => p_khr_id,
			            p_kle_id        => l_asset_cost.id,
                                    p_date          => p_pay_start_date,
				    x_principal_balance   => l_principal_balance,
				    x_accumulated_int     => l_accumulated_int,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data);

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' l_principal_balance ' || l_principal_balance
                          || ' l_accumulated_int '||l_accumulated_int|| x_return_status);
    END IF;
        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_npv := l_npv - NVL(l_principal_balance, 0);

        l_days_in_future  := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_ppd_date,
                                                 p_days_in_month => l_day_convention_month,
                                                 p_days_in_year => l_day_convention_year,
                                                 p_end_date      => p_pay_start_date,
                                                 p_arrears       => 'N',
                                                 x_return_status => lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_periods         :=  l_days_in_future / l_dpp;
	l_npv := l_npv + l_accumulated_int / POWER((1 + l_iir/l_ppy), l_periods);

        lx_selv_tbl.DELETE;
          -- Commented the code by djanaswa for bug 6007644
        /*OKL_STREAM_GENERATOR_PVT.get_stream_elements(
	                   p_start_date          =>   p_pay_start_date,
                           p_periods             =>   p_term,
			   p_frequency           =>   p_frequency,
			   p_structure           =>   0,
			   p_advance_or_arrears  =>   l_advance_arrears,
			   p_amount              =>   0,
			   p_stub_days           =>   NULL,
			   p_stub_amount         =>   NULL,
			   p_currency_code       =>   l_hdr_rec.currency_code,
			   p_khr_id              =>   p_khr_id,
			   p_kle_id              =>   l_asset_cost.id,
			   p_purpose_code        =>   NULL,
			   x_selv_tbl            =>   lx_selv_tbl,
			   x_pt_tbl              =>   l_pt_tbl,
			   x_return_status       =>   x_return_status,
			   x_msg_count           =>   x_msg_count,
			   x_msg_data            =>   x_msg_data);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF; */
        -- end djanaswa


    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' stream elements ' || lx_selv_tbl.COUNT );

    END IF;
	FOR i in lx_selv_tbl.FIRST..lx_selv_tbl.LAST
	LOOP

            l_days_in_future  := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_ppd_date,
                                                     p_days_in_month => l_day_convention_month,
                                                     p_days_in_year => l_day_convention_year,
                                                     p_end_date      => lx_selv_tbl(i).stream_element_date,
                                                     p_arrears       => p_arrears_yn,
                                                     x_return_status => lx_return_status);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_periods         :=  l_days_in_future / l_dpp;
	    l_term := l_term + 1 / POWER((1 + l_iir/l_ppy), l_periods);

	END LOOP;

    END LOOP;

    l_npv := l_npv + p_ppd_amount;

    If ( l_term = 0 ) Then
        l_term := 0.0001;
    End If;
    l_pay_amount := -1 * l_npv / l_term;

    x_pay_amount    := l_pay_amount * l_number_of_assets;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'end' );

    END IF;
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

  END target_pay_down;

  ---------------------------------------------------------------------------
  -- PROCEDURE compute_iir
  --
  -- Description
  --
  ---------------------------------------------------------------------------
  PROCEDURE  compute_iir (p_khr_id          IN  NUMBER,
                          p_start_date      IN  DATE,
                          p_term_duration   IN  NUMBER,
                          p_interim_tbl     IN  interim_interest_tbl_type,
			  p_subsidies_yn    IN  VARCHAR2,
			  p_initial_iir     IN  NUMBER DEFAULT NULL,
                          x_iir             OUT NOCOPY NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2) IS

    CURSOR c_hdr_inflows IS
      SELECT DISTINCT
             sel.id id,
             sel.amount cf_amount,
             sel.stream_element_date cf_date,
             sel.comments cf_arrear,
             sty.stream_type_purpose cf_purpose,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
             DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year
      FROM   okl_streams stm,
             okl_strm_type_b sty,
             okl_strm_elements sel,
             okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp
      WHERE  stm.khr_id = p_khr_id
        AND  stm.say_code = 'WORK'
        AND  stm.purpose_code IS NULL
        AND  stm.sty_id = sty.id
        AND  stm.id = sel.stm_id
        AND  sel.comments IS NOT NULL
        AND  stm.khr_id = rgp.dnz_chr_id
        AND  rgp.cle_id IS NULL
        AND  rgp.rgd_code = 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  slh.object1_id1 = TO_CHAR(stm.sty_id)
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL';

    Cursor c_link_pmnts( chrId NUMBER, kleId NUMBER ) IS
    Select 'Y' What
    from dual
    Where Exists(Select crl.id slh_id
                 From   OKC_RULE_GROUPS_B crg,
                        OKC_RULES_B crl,
			okc_K_lines_b cle_lnk,
			okl_K_lines kle_roll
                 Where  crl.rgp_id = crg.id
                     and crg.RGD_CODE = 'LALEVL'
                     and crl.RULE_INFORMATION_CATEGORY = 'LASLL'
                     and crg.dnz_chr_id = chrId
                     and crg.cle_id = kleId
	             and crg.cle_id = cle_lnk.id
		     and cle_lnk.cle_id = kle_roll.id
		     and kle_roll.fee_type = 'FINANCED');

    r_link_pmnts c_link_pmnts%ROWTYPE;

    CURSOR c_inflows IS
      SELECT DISTINCT
             sel.id id,
             sel.amount cf_amount,
             sel.stream_element_date cf_date,
             sel.comments cf_arrear,
             sty.stream_type_purpose cf_purpose,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
             DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year
      FROM   okl_streams stm,
             okl_strm_type_b sty,
             okl_strm_elements sel,
             okc_k_lines_b cle,
             okc_line_styles_b lse,
             okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp
      WHERE  stm.khr_id = p_khr_id
        AND  stm.say_code = 'WORK'
        AND  stm.purpose_code IS NULL
        AND  stm.sty_id = sty.id
        AND  sty.stream_type_purpose NOT LIKE 'ESTIMATED_PROPERTY_TAX'
        AND  stm.id = sel.stm_id
        AND  sel.comments IS NOT NULL
        AND  stm.kle_id = cle.id
        AND  NOT EXISTS (SELECT 1
                         FROM   okc_rule_groups_b rgp2
                         WHERE  rgp2.dnz_chr_id = p_khr_id
                           AND  rgp2.cle_id = cle.id
                           AND  rgp2.rgd_code = 'LAPSTH')
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.lse_id = lse.id
        AND  lse.lty_code = 'FREE_FORM1'
        AND  cle.id = rgp.cle_id
        AND  rgp.rgd_code = 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  slh.object1_id1 = TO_CHAR(stm.sty_id)
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL';

    CURSOR c_fee_inflows IS
      SELECT DISTINCT
             sel.id id,
             sel.amount cf_amount,
             sel.stream_element_date cf_date,
             sel.comments cf_arrear,
             sty.stream_type_purpose cf_purpose,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
             DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
	     cle.id kleId,
	     lse.lty_code,
	     kle.fee_type
      FROM   okl_streams stm,
             okl_strm_type_b sty,
             okl_strm_elements sel,
             okc_k_lines_b cle,
             okl_k_lines kle,
             okc_line_styles_b lse,
             okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp
      WHERE  stm.khr_id = p_khr_id
        AND  stm.say_code = 'WORK'
        AND  stm.purpose_code IS NULL
        AND  stm.sty_id = sty.id
	AND  sty.stream_type_purpose NOT LIKE 'ESTIMATED_PROPERTY_TAX'
        AND  stm.id = sel.stm_id
        AND  sel.comments IS NOT NULL
        AND  stm.kle_id = cle.id
	AND  cle.id = kle.id
        AND  NOT EXISTS (SELECT 1
                         FROM   okc_rule_groups_b rgp2
                         WHERE  rgp2.dnz_chr_id = p_khr_id
                           AND  rgp2.cle_id = cle.id
                           AND  rgp2.rgd_code = 'LAPSTH')
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.lse_id = lse.id
        AND  lse.lty_code IN ('FEE', 'LINK_FEE_ASSET')
        AND  cle.id = rgp.cle_id
        AND  rgp.rgd_code = 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  slh.object1_id1 = TO_CHAR(stm.sty_id)
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL';

    r_fee_inflows c_fee_inflows%ROWTYPE;

    -- Cursor definition implies RENT must be defined at Asset Level

    CURSOR c_asset_rvs IS
      SELECT DISTINCT
             kle.id,
             NVL(kle.residual_value, 0) cf_amount,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
             DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
             DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) months_per_period,
             cle.start_date,
	     cle.date_terminated,
	     cle.sts_code
      FROM   okl_k_lines kle,
             okc_k_lines_b cle,
             okc_line_styles_b lse,
             okc_rule_groups_b rgp,
             okc_rules_b slh,
             okc_rules_b sll,
             okl_strm_type_b sty
      WHERE  cle.chr_id = p_khr_id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED') -- Bug 5011438
        AND  cle.lse_id = lse.id
        AND  lse.lty_code = 'FREE_FORM1'
        AND  cle.id = kle.id
        AND  kle.id = rgp.cle_id
        AND  rgp.rgd_code = 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
        AND  slh.object1_id1 = TO_CHAR(sty.id)
        AND  sty.stream_type_purpose = 'RENT';

    CURSOR c_deposit_date IS
      SELECT FND_DATE.canonical_to_date(rule_information5)
      FROM   okc_rules_b
      WHERE  dnz_chr_id  = p_khr_id
        AND  rule_information_category = 'LASDEP';

/*    CURSOR c_asset_cost IS
      SELECT cle.id id,
             cle.start_date start_date,
	           kle.capital_amount,
  	         kle.capitalized_interest,
	           kle.date_funding_expected
      FROM   okc_k_lines_b cle,
             okl_K_lines kle,
             okc_line_styles_b lse
      WHERE  cle.chr_id = p_khr_id
        AND  cle.id = kle.id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.lse_id = lse.id
        AND  lse.lty_code = 'FREE_FORM1';
*/
    -- Bug 5287279 : 08-Jun-2006 : kbbhavsa
    --  c_asset_cost cursor modified by including distinct
    CURSOR c_asset_cost IS
      SELECT DISTINCT cle.id id,
             cle.start_date start_date,
             kle.capital_amount,
             kle.capitalized_interest,
	           kle.date_funding_expected,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
             DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
             DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) months_per_period,
             cle.date_terminated,
             cle.sts_code
      FROM   okl_k_lines kle,
             okc_k_lines_b cle,
             okc_line_styles_b lse,
             okc_rule_groups_b rgp,
             okc_rules_b slh,
             okc_rules_b sll,
             okl_strm_type_b sty
      WHERE  cle.chr_id = p_khr_id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED') -- Bug 5011438
        AND  cle.lse_id = lse.id
        AND  lse.lty_code = 'FREE_FORM1'
        AND  cle.id = kle.id
        AND  kle.id = rgp.cle_id
        AND  rgp.rgd_code = 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
        AND  slh.object1_id1 = TO_CHAR(sty.id)
        AND  sty.stream_type_purpose = 'RENT';

    CURSOR c_fee_cost IS
      SELECT NVL(kle.amount, 0) amount,
             cle.start_date,
	     cle.id kleid,
	     lse.lty_code lty_code,
	     kle.fee_type fee_type
      FROM   okl_k_lines kle,
             okc_k_lines_b cle,
             okc_line_styles_b lse,
             okc_k_items cim,
             okl_strm_type_b sty
      WHERE  cle.chr_id = p_khr_id
        AND  cle.lse_id = lse.id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
	AND  kle.fee_type not in ( 'SECDEPOSIT', 'INCOME' )
        AND  lse.lty_code in ( 'FEE', 'LINK_FEE_ASSET')
        AND  cle.id = kle.id
        AND  cle.id = cim.cle_id
        AND  cim.jtot_object1_code = 'OKL_STRMTYP'
        AND  cim.object1_id1 = sty.id
        AND  sty.version = '1.0'
        AND  NVL(sty.capitalize_yn,'N') <> 'Y'
        AND  NOT EXISTS (SELECT 1
                         FROM   okc_rule_groups_b rgp
                         WHERE  rgp.cle_id = cle.id
                           AND  rgp.rgd_code = 'LAPSTH')
        AND  NOT EXISTS (SELECT 1
                         FROM   okc_rule_groups_b rgp,
                                okc_rules_b rul,
                                okc_rules_b rul2
                         WHERE  rgp.cle_id = cle.id
                         AND    rgp.rgd_code = 'LAFEXP'
                         AND    rgp.id = rul.rgp_id
                         AND    rgp.id = rul2.rgp_id
                         AND    rul.rule_information_category = 'LAFEXP'
                         AND    rul2.rule_information_category = 'LAFREQ'
                         AND    rul.rule_information1 IS NOT NULL
                         AND    rul.rule_information2 IS NOT NULL
                         AND    rul2.object1_id1 IS NOT NULL);

    l_fee_cost c_fee_cost%ROWTYPE;

    CURSOR c_rec_exp IS
      SELECT TO_NUMBER(rul.rule_information1) periods,
             TO_NUMBER(rul.rule_information2) cf_amount,
             DECODE(rul2.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) cf_dpp,
             DECODE(rul2.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) cf_ppy,
             DECODE(rul2.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) cf_mpp,
             cle.start_date start_date,
	     kle.fee_type
      FROM   okc_rules_b rul,
             okc_rules_b rul2,
             okc_rule_groups_b rgp,
             okc_k_lines_b cle,
             okl_k_lines kle,
             okc_line_styles_b lse
      WHERE  cle.chr_id = p_khr_id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.lse_id = lse.id
        AND  lse.lty_code = 'FEE'
        AND  NOT EXISTS (SELECT 1
                         FROM   okc_rule_groups_b rgp
                         WHERE  rgp.cle_id = cle.id
                           AND  rgp.rgd_code = 'LAPSTH')
        AND  cle.id = rgp.cle_id
        AND  cle.id = kle.id
        AND  rgp.rgd_code = 'LAFEXP'
        AND  rgp.id = rul.rgp_id
        AND  rgp.id = rul2.rgp_id
        AND  rul.rule_information_category = 'LAFEXP'
        AND  rul2.rule_information_category = 'LAFREQ'
        AND  rul.rule_information1 IS NOT NULL
        AND  rul.rule_information2 IS NOT NULL
        AND  rul2.object1_id1 IS NOT NULL;

      r_rec_exp c_rec_exp%ROWTYPE;

    --------------------------
    -- PERFORMANCE ENHANCEMENT SECTION
    --------------------------
    TYPE cash_flow_rec_type IS RECORD (cf_amount NUMBER,
                                       cf_date   DATE,
                                       cf_purpose   VARCHAR2(150),
                                       cf_dpp    NUMBER,
                                       cf_ppy    NUMBER,
                                       cf_days   NUMBER,
				       kleId     NUMBER);

    TYPE cash_flow_tbl_type IS TABLE OF cash_flow_rec_type INDEX BY BINARY_INTEGER;

    hdr_inflow_tbl  cash_flow_tbl_type;
    inflow_tbl      cash_flow_tbl_type;
    subs_inflow_tbl      cash_flow_tbl_type;
    rv_tbl          cash_flow_tbl_type;
    outflow_tbl     cash_flow_tbl_type;
    subsidies_tbl      cash_flow_tbl_type;
    rec_exp_tbl     cash_flow_tbl_type;

    m BINARY_INTEGER := 0;
    n BINARY_INTEGER := 0;
    p BINARY_INTEGER := 0;
    q BINARY_INTEGER := 0;
    r BINARY_INTEGER := 0;
    s BINARY_INTEGER := 0;

    --------------------------
    -- END PERFORMANCE ENHANCEMENT SECTION
    --------------------------
    lx_msg_count      NUMBER;
    lx_msg_data       VARCHAR2(4000);
    l_end_date        DATE              := ADD_MONTHS(p_start_date, p_term_duration) - 1;
    l_time_zero_cost  NUMBER            := 0;
    l_cost            NUMBER;
    l_residual_value  NUMBER;
    l_adv_payment     NUMBER            := 0;
    l_subsidy_amount     NUMBER            := 0;
    l_currency_code   VARCHAR2(15);
    l_precision       NUMBER(1);

    l_cf_dpp          NUMBER;
    l_cf_ppy          NUMBER;
    l_cf_amount       NUMBER;
    l_cf_date         DATE;
    l_cf_arrear       VARCHAR2(1);
    l_days_in_future  NUMBER;
    l_periods         NUMBER;
    l_deposit_date    DATE;

    i                 BINARY_INTEGER    := 0;
    l_iir             NUMBER            := nvl(p_initial_iir, 0);

    l_npv             NUMBER;
    l_iir_limit       NUMBER            := NVL(ABS(fnd_profile.value('OKL_PRE_TAX_IRR_LIMIT')), 1000)/100;

    l_prev_npv        NUMBER;
    l_prev_npv_sign   NUMBER;

    l_crossed_zero    VARCHAR2(1)       := 'N';

    l_increment       NUMBER            := 1.1;
    l_abs_incr        NUMBER;
    l_prev_incr_sign  NUMBER;

--DEBUG
a binary_integer := 0;
b binary_integer := 0;

    lx_return_status    VARCHAR2(1);

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'compute_iir';

    l_additional_parameters  OKL_EXECUTE_FORMULA_PUB.ctxt_val_tbl_type;

    -- Added by RGOOTY
    l_prev_iir NUMBER := 0;
    l_positive_npv_iir NUMBER := 0;
    l_negative_npv_iir NUMBER := 0;
    l_positive_npv NUMBER := 0;
    l_negative_npv NUMBER := 0;

    l_iir_decided VARCHAR2(1) := 'F';

    l_day_convention_month VARCHAR2(30);
    l_day_convention_year VARCHAR2(30);
    l_days_in_year NUMBER;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'begin' );
    END IF;
    x_return_status := G_RET_STS_SUCCESS;

   -- Fetch the day convention ..
   OKL_PRICING_UTILS_PVT.get_day_convention(
     p_id              => p_khr_id,
     p_source          => 'ISG',
     x_days_in_month   => l_day_convention_month,
     x_days_in_year    => l_day_convention_year,
     x_return_status   => lx_return_status);
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
   END IF;
   IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' Computing IIR on the date ' || p_start_Date );
    END IF;
    FOR l_asset_cost IN c_asset_cost LOOP
      --Modified IF clause by RGOOTY for bug 7577105
      IF(NVL(l_asset_cost.date_funding_expected, l_asset_cost.start_date) = p_start_date)
      THEN
        l_cost := nvl(l_asset_cost.capital_amount, 0) + nvl(l_asset_cost.capitalized_interest,0);
        l_time_zero_cost := l_time_zero_cost + NVL(l_cost, 0);
      END IF;
    END LOOP;


    FOR l_fee_cost IN c_fee_cost LOOP

      If l_fee_cost.lty_code = 'LINK_FEE_ASSET' THEN
             OPEN c_link_pmnts( p_khr_id, l_fee_cost.kleid);
             FETCH c_link_pmnts INTO r_link_pmnts;
             CLOSE c_link_pmnts;
      ENd If;

      If ( (l_fee_cost.lty_code <> 'LINK_FEE_ASSET' AND l_fee_cost.fee_type = 'FINANCED') OR
          (l_fee_cost.lty_code = 'LINK_FEE_ASSET' and nvl(r_link_pmnts.What,'N')='Y') ) THen
      IF l_fee_cost.start_date <= p_start_date THEN

        l_time_zero_cost := l_time_zero_cost + l_fee_cost.amount;

      END IF;
      END IF;

    END LOOP;


    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '1/ TIME ZERO COST = ' || round(nvl(l_time_zero_cost, 0), 2) );
    END IF;
    FOR l_hdr_inflow IN c_hdr_inflows LOOP
        m := m + 1;
        hdr_inflow_tbl(m).cf_amount  := l_hdr_inflow.cf_amount;
        hdr_inflow_tbl(m).cf_date    := l_hdr_inflow.cf_date;
        hdr_inflow_tbl(m).cf_purpose := l_hdr_inflow.cf_purpose;
        hdr_inflow_tbl(m).cf_dpp     := l_hdr_inflow.days_per_period;
        hdr_inflow_tbl(m).cf_ppy     := l_hdr_inflow.periods_per_year;

        hdr_inflow_tbl(m).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date   => p_start_date,
                                                    p_days_in_month => l_day_convention_month,
                                                    p_days_in_year => l_day_convention_year,
                                                    p_end_date      => l_hdr_inflow.cf_date,
                                                    p_arrears       => l_hdr_inflow.cf_arrear,
                                                    x_return_status => lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END LOOP;
    -- Third
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '2/ Handling the Asset level inflows '  );
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'Date | Days | Amount | Purpose | DPP | PPY ' );
    END IF;
    FOR l_inflow IN c_inflows LOOP
        n := n + 1;
        inflow_tbl(n).cf_amount := l_inflow.cf_amount;
        inflow_tbl(n).cf_date   := l_inflow.cf_date;
        inflow_tbl(n).cf_purpose   := l_inflow.cf_purpose;
        inflow_tbl(n).cf_dpp    := l_inflow.days_per_period;
        inflow_tbl(n).cf_ppy    := l_inflow.periods_per_year;
        inflow_tbl(n).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                 p_days_in_month => l_day_convention_month,
                                                 p_days_in_year => l_day_convention_year,
                                                 p_end_date      => l_inflow.cf_date,
                                                 p_arrears       => l_inflow.cf_arrear,
                                                 x_return_status => lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || inflow_tbl(n).cf_date || '| ' || inflow_tbl(n).cf_days || ' | ' || inflow_tbl(n).cf_amount ||' | ' ||
                 inflow_tbl(n).cf_dpp || ' | ' || inflow_tbl(n).cf_ppy );
        END IF;
    END LOOP;

    FOR l_fee_inflow IN c_fee_inflows LOOP

      If l_fee_inflow.lty_code = 'LINK_FEE_ASSET' THEN
             OPEN c_link_pmnts( p_khr_id, l_fee_inflow.kleid);
             FETCH c_link_pmnts INTO r_link_pmnts;
             CLOSE c_link_pmnts;
      ENd If;

      If ( (l_fee_inflow.lty_code <> 'LINK_FEE_ASSET' AND l_fee_inflow.fee_type = 'FINANCED') OR
          (l_fee_inflow.lty_code = 'LINK_FEE_ASSET' and nvl(r_link_pmnts.What,'N')='Y') ) THen

        n := n + 1;
        inflow_tbl(n).cf_amount := l_fee_inflow.cf_amount;
        inflow_tbl(n).cf_date   := l_fee_inflow.cf_date;
        inflow_tbl(n).cf_purpose   := l_fee_inflow.cf_purpose;
        inflow_tbl(n).cf_dpp    := l_fee_inflow.days_per_period;
        inflow_tbl(n).cf_ppy    := l_fee_inflow.periods_per_year;

        inflow_tbl(n).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                 p_days_in_month => l_day_convention_month,
                                                 p_days_in_year => l_day_convention_year,
                                                 p_end_date      => l_fee_inflow.cf_date,
                                                 p_arrears       => l_fee_inflow.cf_arrear,
                                                 x_return_status => lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;
-- Added for approximation
G_TOT_INFLOW_AMT := G_TOT_INFLOW_AMT + l_fee_inflow.cf_amount;
--print( 'Inflows amount ' ||  l_inflow.cf_amount);
    END LOOP;



    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '2/ Handling the Residual Values '  );
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'Date | Days | Amount | Purpose | DPP | PPY ' );
    END IF;
    FOR l_asset_rv IN c_asset_rvs LOOP
        p := p + 1;
        If l_asset_rv.sts_code = 'TERMINATED' Then
            rv_tbl(p).cf_amount := OKL_AM_UTIL_PVT.get_actual_asset_residual(p_khr_id => p_khr_id,
	                                                                     p_kle_id => l_asset_rv.id); --bug# 4184579
            rv_tbl(p).cf_date   := l_asset_rv.date_terminated;
            rv_tbl(p).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                 p_days_in_year => l_day_convention_year,
                                                 p_end_date      => l_asset_rv.date_terminated,
                                                 p_arrears       => 'Y',
                                                 x_return_status => lx_return_status);
            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        	ELSE
            rv_tbl(p).cf_amount := l_asset_rv.cf_amount;
            rv_tbl(p).cf_date   := l_end_date;

            rv_tbl(p).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                 p_days_in_year => l_day_convention_year,
                                                 p_end_date      => l_end_date,
                                                 p_arrears       => 'Y',
                                                 x_return_status => lx_return_status);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

	       END IF;
        rv_tbl(p).cf_dpp    := l_asset_rv.days_per_period;
        rv_tbl(p).cf_ppy    := l_asset_rv.periods_per_year;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || rv_tbl(p).cf_date || '| ' || rv_tbl(p).cf_days || ' | ' || rv_tbl(p).cf_amount ||' | ' ||
             rv_tbl(p).cf_dpp || ' | ' || rv_tbl(p).cf_ppy );
        END IF;
    END LOOP;


    FOR l_outflow IN c_fee_cost LOOP

      If l_fee_cost.lty_code = 'LINK_FEE_ASSET' THEN
             OPEN c_link_pmnts( p_khr_id, l_fee_cost.kleid);
             FETCH c_link_pmnts INTO r_link_pmnts;
             CLOSE c_link_pmnts;
      ENd If;

      If ( (l_fee_cost.lty_code <> 'LINK_FEE_ASSET' AND l_fee_cost.fee_type = 'FINANCED') OR
          (l_fee_cost.lty_code = 'LINK_FEE_ASSET' and nvl(r_link_pmnts.What,'N')='Y') ) THen

      IF l_outflow.start_date > p_start_date THEN

        q := q + 1;
        outflow_tbl(q).cf_amount := -(l_outflow.amount);
        outflow_tbl(q).cf_date   := l_outflow.start_date;
        outflow_tbl(q).cf_dpp    := 1;
        outflow_tbl(q).cf_ppy    := 360;

        outflow_tbl(q).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => l_outflow.start_date,
                                                  p_arrears       => 'N',
                                                  x_return_status => lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

      END IF;
    END LOOP;

    If ( p_subsidies_yn = 'Y' ) Then
          subsidies_tbl(1).cf_amount := 0;
    End If;

    FOR l_outflow IN c_asset_cost LOOP
     -- Handling the case when contract rebooking has happened and an asset has been
     --  added after the start date of the contract but whose funding starts on the revision date.
     --Modified IF clause by bkatraga for bug 7577105
     IF NVL(l_outflow.date_funding_expected, l_outflow.start_date) > p_start_date
     THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '!!! Handling the Assets who are in effect later than the start date !!!');
        END IF;
        q := q + 1;
        outflow_tbl(q).cf_amount := nvl(l_outflow.capital_amount, 0);
        outflow_tbl(q).cf_amount := -(outflow_tbl(q).cf_amount);
        outflow_tbl(q).cf_date   := nvl(l_outflow.date_funding_expected, l_outflow.start_date);
        outflow_tbl(q).cf_dpp    := l_outflow.days_per_period;
        outflow_tbl(q).cf_ppy    := l_outflow.periods_per_year;
        outflow_tbl(q).cf_days   :=
          OKL_PRICING_UTILS_PVT.get_day_count(
            p_start_date    => p_start_date,
            p_days_in_month => l_day_convention_month,
            p_days_in_year => l_day_convention_year,
            p_end_date      => outflow_tbl(q).cf_date,
            p_arrears       => 'N',
            x_return_status => lx_return_status);
        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || outflow_tbl(q).cf_date || '| ' || outflow_tbl(q).cf_days || ' | ' ||
               outflow_tbl(q).cf_amount ||' | ' || outflow_tbl(q).cf_dpp || ' | ' || outflow_tbl(q).cf_ppy );
        END IF;
      ELSIF l_outflow.date_funding_expected < p_start_date THEN
        --Removed = in the above if clause by RGOOTY for bug 7577105
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '!!!!! Handling the Assets who are in effect earlier than the start date !!!!');
        END IF;
        q := q + 1;
        outflow_tbl(q).cf_amount := nvl(l_outflow.capital_amount, 0);
        outflow_tbl(q).cf_amount := -(outflow_tbl(q).cf_amount);
        outflow_tbl(q).cf_date   := l_outflow.date_funding_expected;
        outflow_tbl(q).cf_dpp    := l_outflow.days_per_period;
        outflow_tbl(q).cf_ppy    := l_outflow.periods_per_year;
        outflow_tbl(q).cf_days   :=
          OKL_PRICING_UTILS_PVT.get_day_count(
            p_start_date    => l_outflow.date_funding_expected,
            p_days_in_month => l_day_convention_month,
            p_days_in_year => l_day_convention_year,
            p_end_date      => p_start_date,
            p_arrears       => 'N',
            x_return_status => lx_return_status);
        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        outflow_tbl(q).cf_days := -1 * outflow_tbl(q).cf_days;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || outflow_tbl(q).cf_date || '| ' || outflow_tbl(q).cf_days || ' | ' ||
               outflow_tbl(q).cf_amount ||' | ' || outflow_tbl(q).cf_dpp || ' | ' || outflow_tbl(q).cf_ppy );
        END IF;
      END IF;

      If ( p_subsidies_yn = 'Y' ) Then
      -- Subsidies Begin
          OKL_SUBSIDY_PROCESS_PVT.get_asset_subsidy_amount(
                                        p_api_version   => G_API_VERSION,
                                        p_init_msg_list => G_FALSE,
                                        x_return_status => lx_return_status,
                                        x_msg_data      => lx_msg_data,
                                        x_msg_count     => lx_msg_count,
                                        p_asset_cle_id  => l_outflow.id,
                                        x_subsidy_amount=> l_subsidy_amount);

          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          subsidies_tbl(1).cf_amount := nvl(subsidies_tbl(1).cf_amount, 0) + nvl(l_subsidy_amount,0);

      End If;

    END LOOP;

    If ( p_subsidies_yn = 'Y' ) Then

        subsidies_tbl(1).cf_date  := p_start_date;
        subsidies_tbl(1).cf_dpp   := 1;
        subsidies_tbl(1).cf_ppy   := 360;

        subsidies_tbl(1).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(
                                                  p_days_in_month => l_day_convention_month,
                                                  p_days_in_year => l_day_convention_year,
                                                  p_start_date    => p_start_date,
                                                  p_end_date      => p_start_date,
                                                  p_arrears       => 'N',
                                                  x_return_status => lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- Subsidies End

    End if;


    FOR l_rec_exp IN c_rec_exp LOOP

      If ( nvl(l_rec_exp.fee_type, 'XYZ') = 'FINANCED') Then

        FOR s1 in 1..l_rec_exp.periods LOOP

          s := s + 1;

          rec_exp_tbl(s).cf_amount := -(l_rec_exp.cf_amount);
          rec_exp_tbl(s).cf_date   := ADD_MONTHS(l_rec_exp.start_date, (s1 -1)*l_rec_exp.cf_mpp);
          rec_exp_tbl(s).cf_dpp    :=  l_rec_exp.cf_dpp;
          rec_exp_tbl(s).cf_ppy    :=  l_rec_exp.cf_ppy;

          rec_exp_tbl(s).cf_days   := OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                    p_days_in_month => l_day_convention_month,
                                                    p_days_in_year => l_day_convention_year,
                                                    p_end_date      => rec_exp_tbl(s).cf_date,
                                                    p_arrears       => 'N',
                                                    x_return_status => lx_return_status);

          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END LOOP;

      End If;

    END LOOP;


    IF m > 0 THEN
      FOR m1 IN 1..hdr_inflow_tbl.COUNT LOOP
        IF hdr_inflow_tbl(m1).cf_date <= p_start_date THEN
          l_adv_payment  :=  l_adv_payment + hdr_inflow_tbl(m1).cf_amount;
        END IF;
      END LOOP;
    END IF;

    IF n > 0 THEN
      FOR n1 IN 1..inflow_tbl.COUNT LOOP
        IF inflow_tbl(n1).cf_date <= p_start_date THEN
          l_adv_payment  :=  l_adv_payment + inflow_tbl(n1).cf_amount;
        END IF;
      END LOOP;
    END IF;

   -- print( l_prog_name, 'TIME ZERO OUTFLOW '||l_time_zero_cost);
  --  print( l_prog_name, 'INFLOWS ON OR BEFORE TIME ZERO '||l_adv_payment);

    --Commented by RGOOTY for bug 7577105
    /*
    IF l_adv_payment >= l_time_zero_cost THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_IRR_CALC_INF_LOOP',
                           p_token1       => 'ADV_AMOUNT',
                           p_token1_value => l_adv_payment,
                           p_token2       => 'CAPITAL_AMOUNT',
                           p_token2_value => l_time_zero_cost);

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF; */

    SELECT currency_code
    INTO   l_currency_code
    FROM   okc_k_headers_b
    WHERE  id = p_khr_id;

    SELECT NVL(precision,0)
    INTO   l_precision
    FROM   fnd_currencies
    WHERE  currency_code = l_currency_code;

    l_iir_limit := ROUND(NVL(ABS(fnd_profile.value('OKL_PRE_TAX_IRR_LIMIT')), 1000), 0)/100;
--print( 'Initial iir estimated ' || l_iir );
    LOOP
      i                 :=  i + 1;
      l_npv             :=  -(l_time_zero_cost);
      l_deposit_date    :=  NULL;

--DEBUG
 /*
    print( l_prog_name, ' ');
    print( l_prog_name, 'ITERATION # '||i||'  IRR Guess '||l_iir*100||'   Time Zero is '
                        ||TO_CHAR(p_start_date, 'DD-MON-YYYY'));
    print( l_prog_name,' ');
*/

      -------------------------------------------
      -- INTERIM INTEREST INFLOWS
      -------------------------------------------

      IF p_interim_tbl.COUNT > 0 THEN
 /*
    print( l_prog_name,'INTERIM INTEREST INFLOWS ...');
    print( l_prog_name,'');
    print( l_prog_name, '   '||'    Cash Flow'||'  Days in'||'  Periods'||'  Cash Flow'||'  Discounted');
    print( l_prog_name, '   '||'         Date'||'   Future'||'    (n)  '||'     Amount'||'       Value');
    print( l_prog_name, '');
 */
--DEBUG
a :=0;
        FOR l_temp IN p_interim_tbl.FIRST .. p_interim_tbl.LAST LOOP
--DEBUG
a := a+1;
          l_cf_dpp          :=  p_interim_tbl(l_temp).cf_dpp;

          IF l_cf_dpp = 30 THEN
            l_cf_ppy  :=  12;
          ELSIF l_cf_dpp = 90 THEN
            l_cf_ppy  :=  4;
          ELSIF l_cf_dpp = 180 THEN
            l_cf_ppy  :=  2;
          ELSIF l_cf_dpp = 360 THEN
            l_cf_ppy  :=  1;
          END IF;

          l_cf_amount       :=  p_interim_tbl(l_temp).cf_amount;
          l_days_in_future  :=  p_interim_tbl(l_temp).cf_days;

          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_iir/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods));

  /*  print( l_prog_name, TO_CHAR(a, '99')||'  '||'NOT AVAILAB'||'    '||TO_CHAR(l_days_in_future, '9999')
                        ||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '999.999')||
                        '     '||TO_CHAR((l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods)), '999.990'));
*/
        END LOOP;

      END IF;

      -------------------------------------------
      -- HEADER LEVEL CASH INFLOWS
      -------------------------------------------

      IF m > 0 THEN
 /*
    print( l_prog_name, 'K LEVEL CASH INFLOWS ...');
    print( l_prog_name, '');
    print( l_prog_name, '   '||'    Cash Flow'||'  Days in'||'  Periods'||'  Cash Flow'||'  Discounted');
    print( l_prog_name, '   '||'         Date'||'   Future'||'    (n)  '||'     Amount'||'       Value');
    print( l_prog_name, '');
    */
--DEBUG
a :=0;
        FOR x IN 1..hdr_inflow_tbl.COUNT LOOP
--DEBUG
a := a+1;
          l_cf_dpp          :=  hdr_inflow_tbl(x).cf_dpp;
          l_cf_ppy          :=  hdr_inflow_tbl(x).cf_ppy;
          l_cf_amount       :=  hdr_inflow_tbl(x).cf_amount;
          l_cf_date         :=  hdr_inflow_tbl(x).cf_date;
          l_days_in_future  :=  hdr_inflow_tbl(x).cf_days;

          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_iir/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods));

  /*
    print( l_prog_name, TO_CHAR(a, '99')||'  '||TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'    '||TO_CHAR(l_days_in_future, '9999')||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '99.999')||
'     '||TO_CHAR((l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods)), '99.990'));
*/

          -- Security Deposit is both an inflow as well as an outflow

          IF hdr_inflow_tbl(x).cf_purpose = 'SECURITY_DEPOSIT' THEN

            OPEN c_deposit_date;
            FETCH c_deposit_date INTO l_deposit_date;
            CLOSE c_deposit_date;

            IF l_deposit_date IS NOT NULL THEN

              l_days_in_future  :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => l_deposit_date,
                                                  p_arrears       => l_cf_arrear,
                                                  x_return_status => lx_return_status);

              IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            ELSE

              l_days_in_future  :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => l_end_date,
                                                  p_arrears       => l_cf_arrear,
                                                  x_return_status => lx_return_status);

              IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            END IF;

            l_periods := l_days_in_future / l_cf_dpp;
            l_npv     := l_npv - (l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods));

          END IF;

          l_deposit_date  :=  NULL;

        END LOOP;

      END IF;

      -------------------------------------------
      -- LINE LEVEL CASH INFLOWS
      -------------------------------------------

      IF n > 0 THEN
/*    print( l_prog_name, 'LINE LEVEL CASH INFLOWS ...');
    print( l_prog_name, '');
    print( l_prog_name, '   '||'    Cash Flow'||'  Days in'||'  Periods'||'  Cash Flow'||'  Discounted');
    print( l_prog_name, '   '||'         Date'||'   Future'||'    (n)  '||'     Amount'||'       Value');
    print( l_prog_name, '');
*/
--DEBUG
a :=0;
        FOR y IN 1..inflow_tbl.COUNT LOOP
--DEBUG
a := a+1;
          l_cf_dpp          :=  inflow_tbl(y).cf_dpp;
          l_cf_ppy          :=  inflow_tbl(y).cf_ppy;
          l_cf_amount       :=  inflow_tbl(y).cf_amount;
          l_cf_date         :=  inflow_tbl(y).cf_date;
          l_days_in_future  :=  inflow_tbl(y).cf_days;

          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_iir/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods));

/*    print( l_prog_name, TO_CHAR(a, '99')||'  '||TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'    '||TO_CHAR(l_days_in_future, '9999')||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '999.999')||
'     '||TO_CHAR((l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods)), '999.990'));
*/
          -- Security Deposit is both an inflow as well as an outflow

          IF inflow_tbl(y).cf_purpose = 'SECURITY_DEPOSIT' THEN

            OPEN c_deposit_date;
            FETCH c_deposit_date INTO l_deposit_date;
            CLOSE c_deposit_date;

            IF l_deposit_date IS NOT NULL THEN

              l_days_in_future  :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => l_deposit_date,
                                                  p_arrears       => l_cf_arrear,
                                                  x_return_status => lx_return_status);

              IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            ELSE

              l_days_in_future  :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => p_start_date,
                                                  p_days_in_month => l_day_convention_month,
                                                  p_days_in_year => l_day_convention_year,
                                                  p_end_date      => l_end_date,
                                                  p_arrears       => l_cf_arrear,
                                                  x_return_status => lx_return_status);

              IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            END IF;

            l_periods := l_days_in_future / l_cf_dpp;
            l_npv     := l_npv - (l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods));

          END IF;

          l_deposit_date  :=  NULL;

        END LOOP;

      END IF;

      -------------------------------------------
      -- RV CASH INFLOWS
      -------------------------------------------

      IF p > 0 THEN
/*    print( l_prog_name,'RV CASH INFLOWS ...');
    print( l_prog_name, '');
    print( l_prog_name, '   '||'    Cash Flow'||'  Days in'||'  Periods'||'  Cash Flow'||'  Discounted');
    print( l_prog_name, '   '||'         Date'||'   Future'||'    (n)  '||'     Amount'||'       Value');
    print( l_prog_name, ''); */
--DEBUG
a :=0;
        FOR z IN 1..rv_tbl.COUNT LOOP
--DEBUG
a := a+1;
          l_cf_dpp          :=  rv_tbl(z).cf_dpp;
          l_cf_ppy          :=  rv_tbl(z).cf_ppy;
          l_cf_amount       :=  rv_tbl(z).cf_amount;
          l_cf_date         :=  rv_tbl(z).cf_date;
          l_days_in_future  :=  rv_tbl(z).cf_days;

          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_iir/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods));

 /*
    print( l_prog_name, TO_CHAR(a, '99')||'  '||TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'    '||TO_CHAR(l_days_in_future, '9999')||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '999.999')||
'     '||TO_CHAR((l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods)), '99.990'));
*/
        END LOOP;

      END IF;

-- SUBSIDIES
      FOR y IN 1..subsidies_tbl.COUNT
      LOOP

          l_cf_dpp          :=  subsidies_tbl(y).cf_dpp;
          l_cf_ppy          :=  subsidies_tbl(y).cf_ppy;
          l_cf_amount       :=  subsidies_tbl(y).cf_amount;
          l_cf_date         :=  subsidies_tbl(y).cf_date;
          l_days_in_future  :=  subsidies_tbl(y).cf_days;

          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_iir/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods));

/*
    print( l_prog_name, TO_CHAR(a, '99')||'  '||TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'    '||TO_CHAR(l_days_in_future, '9999')||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '999.999')||
'     '||TO_CHAR((l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods)), '999.990'));
*/
      END LOOP;
-- SUBSIDIES

      -- Handle the outflow_tbl
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || '!!!!!!!! HANDLING THE OUT FLOWS !!!!!!!! ' );
      END IF;
      IF outflow_tbl IS NOT NULL AND outflow_tbl.COUNT > 0
      THEN
        FOR q IN outflow_tbl.FIRST .. outflow_tbl.LAST
        LOOP
          l_cf_dpp          :=  outflow_tbl(q).cf_dpp;
          l_cf_ppy          :=  outflow_tbl(q).cf_ppy;
          l_cf_amount       :=  outflow_tbl(q).cf_amount;
          l_cf_date         :=  outflow_tbl(q).cf_date;
          l_days_in_future  :=  outflow_tbl(q).cf_days;
          l_periods         :=  l_days_in_future / l_cf_dpp;
          IF (l_periods < 1) AND (l_iir/l_cf_ppy <= -1)
          THEN
            OKL_API.SET_MESSAGE (
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_IRR_ZERO_DIV');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          l_npv  := l_npv + (l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods));
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || TO_CHAR(a, '99')||'  '|| TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'    '||
              TO_CHAR(l_days_in_future, '9999')||'  '|| TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '9999999.999')||
              '     '||TO_CHAR((l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods)), '99999999.999990'));
          END IF;
        END LOOP; -- FOR q ..
      END IF; -- IF outflow_tbl IS ..

      IF s > 0 THEN
 /*
    print( l_prog_name, 'FEE RECURRING EXPENSE CASH OUTFLOWS ...');
    print( l_prog_name, '');
    print( l_prog_name, '   '||'    Cash Flow'||'  Days in'||'  Periods'||'  Cash Flow'||'  Discounted');
    print( l_prog_name, '   '||'         Date'||'   Future'||'    (n)  '||'     Amount'||'       Value');
    print( l_prog_name, '');
 */
--DEBUG
a :=0;
        FOR t IN 1..rec_exp_tbl.COUNT LOOP
--DEBUG
a := a+1;
          l_cf_ppy          :=  rec_exp_tbl(t).cf_ppy;
          l_cf_dpp          :=  rec_exp_tbl(t).cf_dpp;
          l_cf_amount       :=  rec_exp_tbl(t).cf_amount;
          l_cf_date         :=  rec_exp_tbl(t).cf_date;
          l_days_in_future  :=  rec_exp_tbl(t).cf_days;

          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_iir/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods));

 /*
    print( l_prog_name, TO_CHAR(a, '99')||'  '||TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'    '||TO_CHAR(l_days_in_future, '9999')||'  '||TO_CHAR(l_periods, '99.999')||'    '||TO_CHAR(l_cf_amount, '999.999')||
'     '||TO_CHAR((l_cf_amount / POWER((1 + l_irr/l_cf_ppy), l_periods)), '999.990'));
*/

        END LOOP;

      END IF;

 --   print( l_prog_name, 'NPV '||L_NPV);

      IF ROUND(l_npv, l_precision+1) = 0 THEN

        x_iir    := l_iir;  -- LLA API multiples by 100 before updating KHR implicit_interest_rate column
        RETURN;

      END IF;

      IF i > 1 AND SIGN(l_npv) <> SIGN(l_prev_npv) AND l_crossed_zero = 'N' THEN

        l_crossed_zero := 'Y';

        -- Added by RGOOTY
        IF ( sign( l_npv) = 1 ) then
          l_positive_npv := l_npv;
          l_negative_npv := l_prev_npv;
          l_positive_npv_iir := l_iir;
          l_negative_npv_iir := l_prev_iir;
       ELSE
         l_positive_npv := l_prev_npv;
         l_negative_npv := l_npv;
         l_positive_npv_iir := l_prev_iir;
         l_negative_npv_iir := l_iir;
       END IF;

      END IF;

      IF( sign(l_npv) = 1) THEN
        l_positive_npv := l_npv;
        l_positive_npv_iir := l_iir;
      ELSE
       l_negative_npv := l_npv;
       l_negative_npv_iir := l_iir;
      END IF;


      IF l_crossed_zero = 'Y' THEN
        -- Added by RGOOTY
        -- Means First time we have got two opposite signed
        IF i > 1 then
           l_abs_incr :=  abs(( l_positive_npv_iir - l_negative_npv_iir ) /
                            ( l_positive_npv - l_negative_npv )  * l_positive_npv);

	   IF ( l_positive_npv_iir < l_negative_npv_iir ) THEN
		l_iir := l_positive_npv_iir + l_abs_incr;
           ELSE
		l_iir := l_positive_npv_iir - l_abs_incr;

           END IF;
           l_iir_decided := 'T';

        ELSE
            l_abs_incr := ABS(l_increment) / 2;
        END IF;

      ELSE

        l_abs_incr := ABS(l_increment);

      END IF;

      IF i > 1 THEN

        IF SIGN(l_npv) <> l_prev_npv_sign THEN

          IF l_prev_incr_sign = 1 THEN

            l_increment := - l_abs_incr;

          ELSE

            l_increment := l_abs_incr;

          END IF;

        ELSE

          IF l_prev_incr_sign = 1 THEN

            l_increment := l_abs_incr;

          ELSE

            l_increment := - l_abs_incr;

          END IF;

        END IF;

      ELSE  -- i = 1

        IF SIGN(l_npv) = -1 THEN

          l_increment := - l_increment;

        END IF;

      END IF;

      -- Added by RGOOTY: Start
      l_prev_iir        := l_iir;

      IF l_iir_decided = 'F'
      THEN
      	l_iir             :=  l_iir + l_increment;
      ELSE
        l_iir_decided := 'F';
      END IF;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_prog_name || i || '-Loop l_npv ' || l_npv );
         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_prog_name || i || '-Loop l_increment ' || l_increment );
         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_prog_name || i || '-Loop iir  '  || l_iir );


       END IF;
      IF ABS(l_iir) > l_iir_limit THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_IIR_CALC_IIR_LIMIT',
                             p_token1       => 'IIR_LIMIT',
                             p_token1_value => l_iir_limit*100);

        RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

      l_prev_incr_sign  :=  SIGN(l_increment);
      l_prev_npv_sign   :=  SIGN(l_npv);
      l_prev_npv        :=  l_npv;

    END LOOP;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'end' );

    END IF;
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

  END compute_iir;

   PROCEDURE compute_rates(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2,
                          p_khr_id        IN  NUMBER,
                          p_kle_id        IN  NUMBER,
                          p_pay_tbl       IN  OKL_STREAM_GENERATOR_PVT.payment_tbl_type,
                          x_rates         OUT NOCOPY OKL_STREAM_GENERATOR_PVT.rate_rec_type,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2) IS

       l_rates         OKL_STREAM_GENERATOR_PVT.rate_rec_type;

    CURSOR c_hdr IS
      SELECT chr.template_yn,
             chr.currency_code,
             chr.start_date,
             chr.end_date,
             khr.deal_type,
             khr.term_duration,
             NVL(khr.generate_accrual_yn, 'Y')
      FROM   okc_k_headers_b chr,
             okl_k_headers khr
      WHERE  khr.id = p_khr_id
        AND  chr.id = khr.id;

    l_hdr c_hdr%ROWTYPE;

    Cursor c_rv IS
    SELECT SUM(to_number(nvl(rul_rv.rule_information2,rul_rv.rule_information4))) Residual_value,
           DECODE(rul_sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360) days_per_period,
           DECODE(rul_sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
           DECODE(rul_sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) months_per_period,
           cle_so.id cle_id,
           cle_so.start_date
    FROM okc_k_headers_b chr_rv,
         okc_line_styles_b lse_rv,
         okc_k_lines_b cle_rv,
         okc_rules_b rul_rv,
         okc_rule_groups_b rgp_rv,
         okc_line_styles_b lse_so,
         okc_k_lines_b cle_so,
         okc_rules_b rul_so,
         okc_rule_groups_b rgp_so,
         okc_rule_groups_b rgp_pay,
         okc_rules_b rul_slh,
         okc_rules_b rul_sll,
         okl_strm_type_b sty
    WHERE rgp_so.cle_id = p_kle_id
    AND rgp_so.dnz_chr_id = p_khr_id
    AND rgp_so.rgd_code = 'SOPYSC'
    AND rgp_so.dnz_chr_id = rul_so.dnz_chr_id
    AND rgp_so.id = rul_so.rgp_id
    AND rul_so.rule_information_category = 'SOPMSC'
    AND rgp_so.cle_id = cle_so.id
    AND cle_so.id = p_kle_id
    AND cle_so.dnz_chr_id = rul_so.dnz_chr_id
    AND cle_so.lse_id = lse_so.id
    AND lse_so.lty_code = 'SO_PAYMENT'
    AND rul_rv.object1_id1 = to_char(rul_so.id)
    AND rul_rv.dnz_chr_id = p_khr_id
    AND rul_rv.dnz_chr_id = rul_so.dnz_chr_id
    AND rul_rv.rgp_id = rgp_rv.id
    AND rgp_rv.rgd_code = 'SOPSAD'
    AND rgp_rv.dnz_chr_id = rul_so.dnz_chr_id
    AND rgp_rv.cle_id = cle_rv.id
    AND cle_rv.lse_id = lse_rv.id
    AND lse_rv.lty_code = 'FREE_FORM1'
    AND rgp_rv.dnz_chr_id = chr_rv.id
    AND chr_rv.START_DATE = cle_rv.START_DATE
    AND cle_so.id = rgp_pay.cle_id
    AND rgp_pay.rgd_code = 'LALEVL'
    AND rgp_pay.id = rul_slh.rgp_id
    AND rul_slh.rule_information_category = 'LASLH'
    AND TO_CHAR(rul_slh.id) = rul_sll.object2_id1
    AND rul_sll.rule_information_category = 'LASLL'
    AND TO_NUMBER(rul_slh.object1_id1) = sty.id
    AND sty.stream_type_purpose = 'RENT'
    GROUP BY DECODE(rul_sll.object1_id1, 'M', 30, 'Q', 90, 'S', 180, 'A', 360),
             DECODE(rul_sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1),
             DECODE(rul_sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12),
             cle_so.id,
             cle_so.start_date;

    r_rv c_rv%ROWTYPE;

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'compute_rates';

    l_rate NUMBER;
    l_payment NUMBER;
    l_payment_count NUMBER;

    l_capital_cost   NUMBER;
    l_residual_value NUMBER;
    l_start_date     DATE;

    Cursor l_strms_csr Is
    Select id
    from okl_streams
    where khr_id = p_khr_id
      --and kle_id = p_kle_id
      and purpose_code in ('PLOW', 'FLOW', 'STUBS');

    l_strms_rec l_strms_csr%ROWTYPE;

    Cursor c_sty ( n VARCHAR2 ) IS
    Select id
    from okl_strm_type_tl
    where language = 'US'
      and name = n;

    r_sty c_sty%ROWTYPE;
    lt_pay_tbl OKL_STREAM_GENERATOR_PVT.payment_tbl_type;
    l_pay_tbl OKL_STREAM_GENERATOR_PVT.payment_tbl_type;
    l_sty_id NUMBER := -1;

    l_interim_interest NUMBER;
    l_interim_days NUMBER;
    l_interim_dpp NUMBER;

    l_interim_tbl  interim_interest_tbl_type;

    l_stmv_tbl okl_streams_pub.stmv_tbl_type;
    x_stmv_tbl okl_streams_pub.stmv_tbl_type;

    Cursor c_rollover_fee IS
    SELECT DISTINCT
           cle.id kleId,
	   stm.id styId,
           sll.object1_id1 frequency,
           TO_NUMBER(sll.rule_information3) periods,
           FND_DATE.canonical_to_date(sll.rule_information2) start_date,
           sll.rule_information5 structure,
           sll.rule_information10 advance_arrears,
           FND_NUMBER.canonical_to_number(sll.rule_information6) amount,
           TO_NUMBER(sll.rule_information7) stub_days,
           TO_NUMBER(sll.rule_information8) stub_amount
    FROM okc_k_headers_b chr_so,
         okc_k_lines_b cle,
         okl_k_lines kle,
         okc_line_styles_b lse,
         okc_rules_b sll,
         okc_rules_b slh,
         okc_rule_groups_b rgp,
         okl_strm_type_b stm
    WHERE chr_so.id = p_khr_id
    and cle.sts_code in( 'COMPLETE', 'INCOMPLETE')--'ENTERED'
    AND cle.dnz_chr_id = chr_so.id
    AND cle.id = kle.id
    AND trunc(cle.START_DATE) = trunc(chr_so.START_DATE)
    AND cle.lse_id = lse.id
    AND ((lse.lty_code = 'FEE' AND kle.fee_type = 'ROLLOVER') OR (lse.lty_code = 'LINK_FEE_ASSET'))
    AND nvl(kle.fee_type, 'XXX') <> 'CAPITALIZED'
    AND cle.id = rgp.cle_id
    AND rgp.rgd_code = 'LALEVL'
    AND rgp.id = slh.rgp_id
    AND slh.rule_information_category = 'LASLH'
    AND slh.object1_id1 = TO_CHAR(stm.id)
    AND TO_CHAR(slh.id) = sll.object2_id1
    AND sll.rule_information_category = 'LASLL'
    order by stm.id;

    r_rollover_fee c_rollover_fee%ROWTYPE;
-- -Added sll.rule_information2 in order by clause by djanaswa for bug 6007644
    Cursor c_fee IS
    SELECT DISTINCT
           cle.id kleId,
           stm.id styId,
           sll.object1_id1 frequency,
           TO_NUMBER(sll.rule_information3) periods,
           FND_DATE.canonical_to_date(sll.rule_information2) start_date,
           sll.rule_information5 structure,
           sll.rule_information10 advance_arrears,
           FND_NUMBER.canonical_to_number(sll.rule_information6) amount,
           TO_NUMBER(sll.rule_information7) stub_days,
           TO_NUMBER(sll.rule_information8) stub_amount
    FROM okc_k_headers_b chr_so,
         okc_k_lines_b cle,
         okl_k_lines kle,
         okc_line_styles_b lse,
         okc_rules_b sll,
         okc_rules_b slh,
         okc_rule_groups_b rgp,
	 okl_strm_type_b stm
    WHERE chr_so.id = p_khr_id
    and cle.sts_code in( 'COMPLETE', 'INCOMPLETE')--'ENTERED'
    AND cle.dnz_chr_id = chr_so.id
    AND trunc(cle.START_DATE) = trunc(chr_so.START_DATE)
    AND cle.lse_id = lse.id
    AND kle.id = cle.id
    AND lse.lty_code in ('FEE', 'LINK_FEE_ASSET')
    ANd nvl(kle.fee_type, 'XXX') <> 'CAPITALIZED'
    AND cle.id = rgp.cle_id
    AND rgp.rgd_code = 'LALEVL'
    AND rgp.id = slh.rgp_id
    AND slh.rule_information_category = 'LASLH'
    AND slh.object1_id1 = TO_CHAR(stm.id)
    AND TO_CHAR(slh.id) = sll.object2_id1
    AND sll.rule_information_category = 'LASLL'
    order by stm.id, FND_DATE.canonical_to_date(sll.rule_information2);

    r_fee c_fee%ROWTYPE;
    i BINARY_INTEGER;
    j BINARY_INTEGER;

    Cursor c_subs Is
    Select 'Y'
    From dual
    where Exists(
    select kle.id
     from  okl_k_lines_full_v kle,
           okc_line_styles_b lse,
	   okc_statuses_b sts
     where KLE.LSE_ID = LSE.ID
          and lse.lty_code = 'SUBSIDY'
          and kle.dnz_chr_id = p_khr_id
	  and sts.code = kle.sts_code
	  and sts.ste_code not in ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED'));

    r_subs c_subs%ROWTYPE;
    l_subsidies_yn VARCHAR2(1);
    l_subsidy_amount  NUMBER;

    l_kle_id NUMBER;
    l_has_rollover_fee VARCHAR2(1) := 'N';
    -- Bug 4626837 : Start
    l_rent_strm_name VARCHAR2(256);
    l_rent_strm_id NUMBER;
    -- Bug 4626837 : End
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'begin' );


      END IF;
      For i in p_pay_tbl.FIRST..p_pay_tbl.LAST
      LOOP
          IF ( (p_pay_tbl(i).amount IS NULL) AND (p_pay_tbl(i).stub_amount IS NULL ) ) Then
              OKL_API.set_message(p_app_name      => G_APP_NAME,
                                  p_msg_name      => 'OKL_PE_MISSING_PMNT');
              RAISE OKL_API.G_EXCEPTION_ERROR;
          End If;
      END LOOP;

      For i in p_pay_tbl.FIRST..p_pay_tbl.LAST
      LOOP
          l_pay_tbl(i) := p_pay_tbl(i);
          l_pay_tbl(i).rate := l_pay_tbl(i).rate / 100.0;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' date ' || l_pay_tbl(i).start_date || ' amout ' || l_pay_tbl(i).amount );
          END IF;
          IF ( l_pay_tbl(i).periods IS NOT NULL) AND ( l_pay_tbl(i).amount IS NULL ) Then
            l_pay_tbl(i).amount := -9999999;
          ELSIF ( l_pay_tbl(i).periods IS NULL) AND ( l_pay_tbl(i).stub_amount IS NULL ) Then
            l_pay_tbl(i).stub_amount := -9999999;
          END IF;
      END LOOP;

      -- Bug 4626837 : Start
      -- Get the Deal Type using the c_hdr cursor
      OPEN  c_hdr;
      FETCH c_hdr INTO l_hdr;
      CLOSE c_hdr;
      OKL_ISG_UTILS_PVT.get_primary_stream_type(
        p_khr_id              => p_khr_id,
        p_deal_type           => l_hdr.deal_type,
        p_primary_sty_purpose => 'RENT',
        x_return_status       => x_return_status,
        x_primary_sty_id      => l_rent_strm_id,
        x_primary_sty_name    => l_rent_strm_name);
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Bug 4626837 : End
      OKL_STREAM_GENERATOR_PVT.generate_cash_flows(
                             p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             p_khr_id        => p_khr_id,
                             p_kle_id        => p_kle_id,
                             p_sty_id        => l_rent_strm_id, -- Bug 4626837
                             p_payment_tbl   => l_pay_tbl,
                             x_payment_count => l_payment_count,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'generate_cash_flows ' || x_return_status );

      END IF;
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OPEN c_subs;
      FETCH c_subs INTO l_subsidies_yn;
      CLOSE c_subs;
      l_subsidies_yn := nvl( l_subsidies_yn, 'N' );


      okl_la_stream_pvt.get_so_asset_oec(p_khr_id,
                                     p_kle_id,
				     l_subsidies_yn,
                                     x_return_status,
				     l_capital_cost,
				     l_start_date);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' get_asset_oec ' || to_char( l_capital_cost)|| x_return_status);
      END IF;
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      Okl_la_stream_pvt.get_so_residual_value(p_khr_id,
                                          p_kle_id,
				          l_subsidies_yn,
                                          x_return_status,
					  l_residual_value,
					  l_start_date);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' get_residual_value  ' || to_char( l_residual_value )|| x_return_status);
      END IF;
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --If ( p_rate_type = 'PRE_TAX_IRR' )  Then calcualte pre_tax_irr

          i := 0;
          FOR r_fee in c_fee
          LOOP

	      l_kle_Id := r_fee.kleId;
              If ( l_sty_id = r_fee.styId ) Then

                  i := i + 1;
	          lt_pay_tbl(i).amount     := r_fee.amount;
	          lt_pay_tbl(i).start_date := r_fee.start_date;
	          lt_pay_tbl(i).arrears_yn := r_fee.advance_arrears;
	          lt_pay_tbl(i).periods    := r_fee.periods;
	          lt_pay_tbl(i).frequency  := r_fee.frequency;
	          lt_pay_tbl(i).stub_days    := r_fee.stub_days;
	          lt_pay_tbl(i).stub_amount  := r_fee.stub_amount;

                  For j in l_pay_tbl.FIRST..(l_pay_tbl.LAST-1)
	          LOOP
	              If (( r_fee.start_date >= l_pay_tbl(j).start_date ) AND
		          ( r_fee.start_date < l_pay_tbl(j+1).start_date)) Then

			  If ( l_pay_tbl(j).arrears_yn = 'Y' ) Then
		              lt_pay_tbl(i).rate := l_pay_tbl(j+1).rate;
			  else
		              lt_pay_tbl(i).rate := l_pay_tbl(j).rate;
			  End If;
			  exit;

		      End If;
	          END LOOP;

	      Else

	          If ( lt_pay_tbl.COUNT > 0 ) Then

                      OKL_STREAM_GENERATOR_PVT.generate_cash_flows(
                                     p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     p_khr_id        => p_khr_id,
		                     p_kle_id        => r_fee.kleId,
		                     p_sty_id        => l_sty_id,
		            	     p_payment_tbl   => lt_pay_tbl,
			             x_payment_count => l_payment_count,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data);


                      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;

	          End If;

                  lt_pay_tbl.DELETE;
	          i := 1;
	          l_sty_id := r_fee.styId;
	          lt_pay_tbl(i).amount     := r_fee.amount;
	          lt_pay_tbl(i).start_date := r_fee.start_date;
	          lt_pay_tbl(i).arrears_yn := r_fee.advance_arrears;
	          lt_pay_tbl(i).periods    := r_fee.periods;
	          lt_pay_tbl(i).frequency  := r_fee.frequency;
	          lt_pay_tbl(i).stub_days    := r_fee.stub_days;
	          lt_pay_tbl(i).stub_amount  := r_fee.stub_amount;

                  For j in l_pay_tbl.FIRST..(l_pay_tbl.LAST-1)
	          LOOP
	               If (( r_fee.start_date >= l_pay_tbl(j).start_date ) AND
		           ( r_fee.start_date < l_pay_tbl(j+1).start_date)) Then
		           lt_pay_tbl(i).rate := l_pay_tbl(j).rate;
		       End If;
	          END LOOP;

	      End If;

          END LOOP;

	  If ( lt_pay_tbl.COUNT > 0 ) Then

              OKL_STREAM_GENERATOR_PVT.generate_cash_flows(
                                     p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     p_khr_id        => p_khr_id,
		                     p_kle_id        => l_kle_Id,
		                     p_sty_id        => l_sty_id,
		            	     p_payment_tbl   => lt_pay_tbl,
			             x_payment_count => l_payment_count,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data);


               IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

	  End If;

          OPEN c_sty ( 'RESIDUAL VALUE' );
          FETCH c_sty INTO r_sty;
          CLOSE c_sty;

          OPEN c_rv;
          FETCH c_rv INTO r_rv;
          CLOSE c_rv;

          lt_pay_tbl.DELETE;

          l_interim_tbl(1).cf_days   := l_interim_days;
          l_interim_tbl(1).cf_amount := l_interim_interest;
          l_interim_tbl(1).cf_dpp    := l_interim_dpp;

          comp_so_pre_tax_irr(
	       p_api_version   => p_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_khr_id        => p_khr_id,
	       p_kle_id        => p_kle_id,
	       p_interim_tbl   => l_interim_tbl,
	       p_target        => 'PMNT',
	       p_subside_yn    => 'N',
	       x_payment       => l_payment,
	       x_rate          => l_rate);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'comp_so_pre_tax_irr ' || to_char( l_rate)|| x_return_status);
      END IF;
          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          l_rates.PRE_TAX_IRR := l_rate * 100.00;

          If ( l_subsidies_yn = 'Y' ) Then

              comp_so_pre_tax_irr(
	           p_api_version   => p_api_version,
                   p_init_msg_list => p_init_msg_list,
		       x_return_status => x_return_status,
		       x_msg_count     => x_msg_count,
		       x_msg_data      => x_msg_data,
		       p_khr_id        => p_khr_id,
		       p_kle_id        => p_kle_id,
		       p_interim_tbl   => l_interim_tbl,
		       p_target        => 'PMNT',
		       p_subside_yn    => 'Y',
		       x_payment       => l_payment,
		       x_rate          => l_rate);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'comp_so_pre_tax_irr ' || x_return_status );
      END IF;
		  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
		    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
		  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
		    RAISE OKL_API.G_EXCEPTION_ERROR;
		  END IF;

		  l_rates.SUB_PRE_TAX_IRR := l_rate * 100.00;

	  End If;

      --ElsIf ( p_rate_type = 'IMPL_INTEREST_RATE' )  Then implicit_rates

	  If ( l_subsidies_yn = 'Y' ) Then

              l_interim_tbl(1).cf_days   := l_interim_days;
              l_interim_tbl(1).cf_amount := l_interim_interest;
              l_interim_tbl(1).cf_dpp    := l_interim_dpp;

              comp_so_iir(
	           p_api_version   => p_api_version,
                   p_init_msg_list => p_init_msg_list,
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   p_khr_id        => p_khr_id,
	           p_kle_id        => p_kle_id,
	           p_interim_tbl   => l_interim_tbl,
	           p_target        => 'PMNT',
	           p_subside_yn    => 'Y',
	           x_payment       => l_payment,
	           x_rate          => l_rate);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'comp_so_iir ' || x_return_status );
      END IF;
              IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

                  l_rates.SUB_IMPL_INTEREST_RATE := l_rate * 100.00;

          End If;

              l_interim_tbl(1).cf_days   := l_interim_days;
              l_interim_tbl(1).cf_amount := l_interim_interest;
              l_interim_tbl(1).cf_dpp    := l_interim_dpp;

              comp_so_iir(
	           p_api_version   => p_api_version,
                   p_init_msg_list => p_init_msg_list,
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   p_khr_id        => p_khr_id,
	           p_kle_id        => p_kle_id,
	           p_interim_tbl   => l_interim_tbl,
	           p_target        => 'PMNT',
	           p_subside_yn    => 'N',
	           x_payment       => l_payment,
	           x_rate          => l_rate);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'comp_so_iir ' || x_return_status );
      END IF;
              IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;


                  l_rates.IMPLICIT_INTEREST_RATE := l_rate * 100.00;

      --ElsIf ( p_rate_type = 'PRE_TAX_YIELD' )  Then BKG YLD

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' no subsidies comp_so_pre ' ||  x_return_status );

      END IF;
              l_interim_tbl(1).cf_days   := l_interim_days;
              l_interim_tbl(1).cf_amount := l_interim_interest;
              l_interim_tbl(1).cf_dpp    := l_interim_dpp;

              comp_so_iir(
	           p_api_version   => p_api_version,
                   p_init_msg_list => p_init_msg_list,
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   p_khr_id        => p_khr_id,
	           p_kle_id        => p_kle_id,
	           p_interim_tbl   => l_interim_tbl,
	           p_target        => 'PMNT',
	           p_subside_yn    => 'N',
	           x_payment       => l_payment,
	           x_rate          => l_rate);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'comp_so_iir ' || x_return_status );
      END IF;
              IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

          l_rates.PRE_TAX_YIELD := l_rate * 100.00;

        If ( l_subsidies_yn = 'Y' ) Then

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name ||  ' yes subsidies comp_so_pre '|| x_return_status);
      END IF;
              l_interim_tbl(1).cf_days   := l_interim_days;
              l_interim_tbl(1).cf_amount := l_interim_interest;
              l_interim_tbl(1).cf_dpp    := l_interim_dpp;

              comp_so_iir(
	           p_api_version   => p_api_version,
                   p_init_msg_list => p_init_msg_list,
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   p_khr_id        => p_khr_id,
	           p_kle_id        => p_kle_id,
	           p_interim_tbl   => l_interim_tbl,
	           p_target        => 'PMNT',
	           p_subside_yn    => 'Y',
	           x_payment       => l_payment,
	           x_rate          => l_rate);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'comp_so_iir ' || x_return_status );
      END IF;
              IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

          l_rates.SUB_PRE_TAX_YIELD := l_rate * 100.00;

      END IF;
      --Else
      x_rates := l_rates;

     i := 0;
     FOR l_strms_rec in l_strms_csr
     LOOP

         i := i + 1;
         l_stmv_tbl(i).id := l_strms_rec.ID;

     END LOOP;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' #of streams to delete - ' || i );
     END IF;
     If ( i > 0 ) Then

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || i || '# of streams are getting deleted ' );
         END IF;
         Okl_Streams_pub.delete_streams(
                          p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_stmv_tbl => l_stmv_tbl);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' DONE '|| x_return_status);

         END IF;
    End If;

    For r_rollover_fee in c_rollover_fee
    LOOP

        update okl_streams
        set say_code = 'HIST'
        ,date_history = SYSDATE
        where khr_id = p_khr_id
           and kle_id = p_kle_id;

        update okl_streams
        set active_yn = 'N'
        where khr_id = p_khr_id
           and kle_id = p_kle_id;

        OKL_STREAM_GENERATOR_PVT.generate_quote_streams(
                             p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             p_khr_id        => p_khr_id,
			     p_kle_id        => p_kle_id,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         Exit;

    END LOOP;


    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'end' );

    END IF;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

     i := 0;
     FOR l_strms_rec in l_strms_csr
     LOOP

         i := i + 1;
         l_stmv_tbl(i).id := l_strms_rec.ID;

     END LOOP;

     If ( i > 0 ) Then

         Okl_Streams_pub.delete_streams(
                          p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_stmv_tbl => l_stmv_tbl);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

    End If;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

     i := 0;
     FOR l_strms_rec in l_strms_csr
     LOOP

         i := i + 1;
         l_stmv_tbl(i).id := l_strms_rec.ID;

     END LOOP;

     If ( i > 0 ) Then

         Okl_Streams_pub.delete_streams(
                          p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_stmv_tbl => l_stmv_tbl);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

    End If;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

     i := 0;
     FOR l_strms_rec in l_strms_csr
     LOOP

         i := i + 1;
         l_stmv_tbl(i).id := l_strms_rec.ID;

     END LOOP;

     If ( i > 0 ) Then

         Okl_Streams_pub.delete_streams(
                          p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_stmv_tbl => l_stmv_tbl);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

    End If;

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END compute_rates;


-- Start of comments
--
-- Procedure Name	: get_payment_after_ppd
-- Description		: Returns Payment amount after PPD
-- Business Rules	:
-- Parameters		: p_khr_id,
--                   p_kle_id
--                   p_ppd_amt
--                   p_rate
--                   p_ppd_date
--                  p_pay_level
-- Version		: 1.0
-- End of comments

PROCEDURE get_payment_after_ppd(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_khr_id         IN  NUMBER,
            p_kle_id         IN  NUMBER,
            p_ppd_amt        IN  NUMBER,
            p_rate           IN  NUMBER,
            p_ppd_date       IN  DATE,
            p_pay_level      IN  payment_tbl_type,
            x_pay_level      OUT NOCOPY payment_tbl_type)
    IS
    l_api_name		CONSTANT  VARCHAR2(30) := 'GET_PAYMENT_AFTER_PPD';
    l_first_payment               NUMBER       := 0;
    ln_ob_ppd                     NUMBER       := p_ppd_amt;
    ln_cb_ppd                     NUMBER       := 0;
    ln_intrm_int                  NUMBER       := 0;
    ln_ppd_guess_int              NUMBER       := 0;
    ln_intrm_days                 NUMBER       := 0;
    l_intrm_days                  NUMBER       := 0;
    ln_int_ppd                    NUMBER       := 0;
    ln_int_ppd_days               NUMBER       := 0;
    ln_ppd_guess                  NUMBER       := 0;
    ln_ppd_pay                    NUMBER       := 0;
    l_no_of_periods               NUMBER       := 0;
    l_total_number_of_days        NUMBER       := 0;
    l_advance_arrears             VARCHAR2(30);

    ld_start_date                 DATE;
    l_start_date                  DATE;
    l_term_complete               VARCHAR2(1)  := 'N';
    l_increment                   NUMBER;
    l_abs_incr                    NUMBER;
    l_prev_incr_sign              NUMBER;
    l_crossed_zero                VARCHAR2(1)  := 'N';
    l_diff                        NUMBER;
    l_prev_diff                   NUMBER :=1;
    l_prev_diff_sign              NUMBER ;
    l_purpose_code                VARCHAR2(30) := 'FLOW';
    lv_adv_arr                    VARCHAR2(30);
    lv_currency_code              okc_k_headers_b.currency_code%TYPE;
    l_selv_tbl                    okl_streams_pub.selv_tbl_type;
    l_pt_tbl                      okl_streams_pub.selv_tbl_type;
    l_pay_level                   payment_tbl_type := p_pay_level;
    lx_pay_level                  payment_tbl_type;
    l_cash_flow_tbl               cash_flow_tbl_type;
    k                             NUMBER :=1;
    loop_counter                  BINARY_INTEGER    :=  0;
    l_open_balance                NUMBER :=0;
    l_currency_code              okc_k_headers_b.currency_code%TYPE;

    CURSOR c_hdr_csr(p_khr_id okc_k_headers_b.id%TYPE)
    IS
    SELECT currency_code
    FROM okc_k_headers_b
    WHERE id = p_khr_id;

   --Added by djanaswa for bug 6007644
    l_recurrence_date    DATE := NULL;
    --end djanaswa

    l_day_convention_month VARCHAR2(30);
    l_day_convention_year VARCHAR2(30);
    l_days_in_year NUMBER;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := okl_api.start_activity (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
   -- Fetch the day convention ..
   OKL_PRICING_UTILS_PVT.get_day_convention(
     p_id              => p_khr_id,
     p_source          => 'ISG',
     x_days_in_month   => l_day_convention_month,
     x_days_in_year    => l_day_convention_year,
     x_return_status   => x_return_status);
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'get_payment_after_ppd Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
   END IF;
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

    OPEN  c_hdr_csr(p_khr_id => p_khr_id);
    FETCH c_hdr_csr INTO lv_currency_code;
    IF c_hdr_csr%NOTFOUND THEN
      okl_api.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_LLA_NO_MATCHING_RECORD,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'Currency Code');
      RAISE okl_api.g_exception_error;
    END IF;
    CLOSE c_hdr_csr;

     -- To get the ratio of the existing payment
    -- this would help build future payments after
    -- ppd.

     FOR i IN l_pay_level.FIRST..l_pay_level.LAST LOOP
         IF l_pay_level(i).amount <> 0 AND
           l_pay_level(i).amount <> okl_api.g_miss_num THEN
                    l_first_payment := l_pay_level(i).amount;
         END IF;
         EXIT;
     END LOOP;

     l_start_date := l_pay_level(l_pay_level.FIRST).start_date;
    FOR i IN l_pay_level.FIRST..l_pay_level.LAST LOOP
      IF l_pay_level(i).amount <> 0 AND
         l_pay_level(i).amount <> okl_api.g_miss_num THEN
         l_pay_level(i).ratio := l_pay_level(i).amount/l_first_payment;
         l_no_of_periods      := l_no_of_periods + l_pay_level(i).periods;

      END IF;

      IF ( l_pay_level(i).arrears_yn = 'Y' ) THEN
        l_advance_arrears := 'ARREARS';
      ELSE
         l_advance_arrears := 'ADVANCE';
      END IF;

      --Added by djanaswa for bug 6007644
      IF((l_pay_level(i).periods IS NULL) AND (l_pay_level(i).stub_days IS NOT NULL)) THEN
        --Set the recurrence date to null for stub payment
        l_recurrence_date := NULL;
      ELSIF(l_recurrence_date IS NULL) THEN
        --Set the recurrence date as periodic payment level start date
        l_recurrence_date := l_pay_level(i).start_date;
      END IF;
      --end djanaswa
   -- Added parameter p_recurrence_date by djanaswa for bug 6007644
      okl_stream_generator_pvt.get_stream_elements(
                               p_start_date         => l_pay_level(i).start_date,
                               p_periods            => l_pay_level(i).periods,
                               p_frequency          => l_pay_level(i).frequency,
                               p_structure          => l_pay_level(i).structure,
                               p_advance_or_arrears => l_advance_arrears, --l_pay_level(i).adv_arr,
                               p_amount             => l_pay_level(i).amount,
                               p_stub_days          => l_pay_level(i).stub_days,
                               p_stub_amount        => l_pay_level(i).stub_amount,
                               p_currency_code      => l_currency_code,
                               p_khr_id             => p_khr_id,
                               p_kle_id             => p_kle_id,
                               p_purpose_code       => l_purpose_code,
                               x_selv_tbl           => l_selv_tbl,
                               x_pt_tbl             => l_pt_tbl,
                               x_return_status      => x_return_status,
                               x_msg_count          => x_msg_count,
                               x_msg_data           => x_msg_data,
                               p_recurrence_date    => l_recurrence_date);
      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        EXIT WHEN(x_return_status = okl_api.g_ret_sts_unexp_error);
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        EXIT WHEN(x_return_status = okl_api.g_ret_sts_error);
      END IF;



      FOR j IN l_selv_tbl.FIRST..l_selv_tbl.LAST LOOP

            ln_int_ppd_days  :=  OKL_PRICING_UTILS_PVT.get_day_count(
                                                          p_start_date    => l_start_date,
                                                          p_days_in_month => l_day_convention_month,
							  p_days_in_year => l_day_convention_year,
                                                          p_end_date      => l_selv_tbl(j).stream_element_date,
                                                          p_arrears       => l_pay_level(i).arrears_yn,
                                                          x_return_status => x_return_status);

            IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
              EXIT WHEN(x_return_status = okl_api.g_ret_sts_unexp_error);
            ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
              EXIT WHEN(x_return_status = okl_api.g_ret_sts_error);
            END IF;


            l_cash_flow_tbl(k).cf_days := ln_int_ppd_days;
            l_cash_flow_tbl(k).cf_date := l_selv_tbl(j).stream_element_date;

            l_cash_flow_tbl(k).cf_amount := l_selv_tbl(j).amount;

            l_cash_flow_tbl(k).cf_ratio := l_pay_level(i).ratio;
            l_start_date := l_selv_tbl(j).stream_element_date;
            l_total_number_of_days := l_total_number_of_days +  ln_int_ppd_days;    -- to count total number of days

            k := k+1;


        END LOOP;


   END LOOP;

    IF (l_pay_level(l_pay_level.FIRST).start_date IS NOT NULL OR
           l_pay_level(l_pay_level.FIRST).start_date <> okl_api.g_miss_date) AND
           (p_ppd_date IS NOT NULL OR
           p_ppd_date <> okl_api.g_miss_date) AND
           l_pay_level(l_pay_level.FIRST).start_date > p_ppd_date THEN
          l_intrm_days  :=  OKL_PRICING_UTILS_PVT.get_day_count(
                                                       p_start_date    => p_ppd_date,
                                                       p_days_in_month => l_day_convention_month,
						       p_days_in_year => l_day_convention_year,
                                                       p_end_date      => l_pay_level(l_pay_level.FIRST).start_date,
                                                       p_arrears       => 'N',
                                                       x_return_status => x_return_status);
          IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                 RAISE okl_api.g_exception_unexpected_error;
          ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                 RAISE okl_api.g_exception_error;
          END IF;
          ln_intrm_int  := (p_ppd_amt * l_intrm_days * p_rate)/(100 * 360);
        END IF;

   ln_ppd_guess_int := (p_ppd_amt * l_total_number_of_days * p_rate)/(100 * 360);


   ln_ppd_guess := (p_ppd_amt + ln_ppd_guess_int + ln_intrm_int)/l_no_of_periods;

   l_open_balance := p_ppd_amt + NVL(ln_intrm_int,0);


   ln_ob_ppd := l_open_balance;

   l_increment := ln_ppd_guess /4;

    LOOP

      loop_counter :=  loop_counter + 1;

      ln_ob_ppd := l_open_balance;


      FOR k IN l_cash_flow_tbl.FIRST..l_cash_flow_tbl.LAST LOOP

        ln_int_ppd := (ln_ob_ppd * l_cash_flow_tbl(k).cf_days * p_rate)/(100 * 360);
        ln_ppd_pay := (l_cash_flow_tbl(k).cf_ratio * ln_ppd_guess) - ln_int_ppd;
        ln_cb_ppd  := ln_ob_ppd - ln_ppd_pay;
        ln_ob_ppd  := ln_cb_ppd;
      END LOOP;
       l_diff  :=  ln_ob_ppd;

      IF ROUND(l_diff, 4) = 0 THEN

         FOR i IN l_pay_level.FIRST..l_pay_level.LAST LOOP
                        lx_pay_level(i).start_date  := l_pay_level(i).start_date;
                        lx_pay_level(i).periods     := l_pay_level(i).periods;
                        lx_pay_level(i).frequency   := l_pay_level(i).frequency;
                        lx_pay_level(i).structure   := l_pay_level(i).structure;
                        lx_pay_level(i).arrears_yn  := l_pay_level(i).arrears_yn;
                        lx_pay_level(i).amount      := ln_ppd_guess * l_pay_level(i).ratio;


         END LOOP;
        EXIT;

      END IF;

      IF (SIGN(l_diff) <> SIGN(l_prev_diff)) AND l_crossed_zero = 'N' THEN
        l_crossed_zero := 'Y';
      END IF;

      IF l_crossed_zero = 'Y' THEN
        l_abs_incr := ABS(l_increment) /2 ;
      ELSE
        l_abs_incr := ABS(l_increment);
      END IF;


       IF loop_counter > 1 THEN
        IF SIGN(l_diff) <> l_prev_diff_sign THEN
          IF l_prev_incr_sign = 1 THEN
            l_increment :=  -l_abs_incr;
          ELSE
            l_increment := l_abs_incr;
          END IF;
        ELSE
          IF l_prev_incr_sign = 1 THEN
            l_increment := l_abs_incr;
          ELSE
            l_increment :=  -l_abs_incr;
          END IF;
        END IF;
      ELSE
        IF SIGN(l_diff) = 1 THEN
          l_increment := l_increment;
        ELSE
          l_increment := -l_increment;
        END IF;
      END IF;

      ln_ppd_guess             :=  ln_ppd_guess + l_increment;
      l_prev_incr_sign  :=  SIGN(l_increment);
      l_prev_diff_sign  :=  SIGN(l_diff);
      l_prev_diff       :=  l_diff;
     END LOOP;

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    x_pay_level := lx_pay_level;




       okl_api.end_activity(x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN okl_api.g_exception_error THEN
     IF c_hdr_csr%ISOPEN THEN
	    CLOSE c_hdr_csr;
	 END IF;
      x_return_status := okl_api.handle_exceptions(
                                l_api_name,
                               g_pkg_name,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN okl_api.g_exception_unexpected_error THEN
     IF c_hdr_csr%ISOPEN THEN
	    CLOSE c_hdr_csr;
	 END IF;

      x_return_status :=okl_api.handle_exceptions(
                                l_api_name,
                                g_pkg_name,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN

     IF c_hdr_csr%ISOPEN THEN
	    CLOSE c_hdr_csr;
	 END IF;
      x_return_status :=okl_api.handle_exceptions(
                                l_api_name,
                                g_pkg_name,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END get_payment_after_ppd;

  ---------------------------------------------------------------------------
  -- PROCEDURE generate_loan_schedules
  --
  -- Description
  -- Generate projected loan chedules for actual loans
  ---------------------------------------------------------------------------

 PROCEDURE generate_loan_schedules (p_khr_id              IN  NUMBER,
                                    p_investment          IN  NUMBER,
                                    p_start_date          IN  DATE,
                                    x_interest_rate       OUT NOCOPY  NUMBER,
                                    x_schedule_table      OUT NOCOPY  schedule_table_type,
                                    x_return_status       OUT NOCOPY VARCHAR2)  IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'generate_loan_schedules';

      -- cursor to get the end date of the contract
      cursor c_contract_end_date(khr_id number) IS
      select end_date, CURRENCY_CODE   from okc_k_headers_all_b where id=khr_id;



      -- cursor to get the start date and arrears flag
      CURSOR c_rent_slls IS
      SELECT FND_DATE.canonical_to_date(sll.rule_information2) start_date,
             TO_NUMBER(SLL.rule_information3) periods,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 120, 'S', 180, 'A', 360) dpp,
             DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) mpp,
             NVL(sll.rule_information10, 'N') arrears_yn,
             FND_NUMBER.canonical_to_number(sll.rule_information6) rent_amount
      FROM   okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp,
             okl_strm_type_b sty,
             okl_strm_type_tl styt
      WHERE  rgp.dnz_chr_id = p_khr_id
        AND  rgp.rgd_code= 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  TO_NUMBER(slh.object1_id1) = sty.id
        AND  sty.version = '1.0'
        AND  sty.id = styt.id
        AND  STYT.LANGUAGE = USERENV('LANG')
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
      ORDER BY fnd_date.canonical_to_date(sll.rule_information2);

    l_rent_sll  c_rent_slls%ROWTYPE;

      -- cursor to get the payment streams
    CURSOR c_rent_flows (p_loan_start_date date ,p_end_date date) IS
      SELECT sum(sel.amount)         se_amount,
             sel.stream_element_date se_date,
             sel.comments            se_arrears,
             sty.stream_type_purpose,
             decode(sty.stream_type_purpose,'LOAN_PAYMENT',1,'UNSCHEDULED_PRINCIPAL_PAYMENT',2,'UNSCHEDULED_LOAN_PAYMENT',2,'VARIABLE_LOAN_PAYMENT',3,4) stream_ordr
      FROM   okl_strm_elements     sel,
             okl_streams           stm,
             okl_strm_type_b       sty,
             okl_strm_type_tl      styt
      WHERE  stm.khr_id =p_khr_id
        AND  stm.say_code = 'CURR'
        AND  DECODE(stm.purpose_code, NULL, '-99', 'REPORT') = '-99'
        AND  stm.sty_id = sty.id
        AND  sty.version = '1.0'
        AND  sty.id = styt.id
        AND  STYT.LANGUAGE = USERENV('LANG')  -- Bug 4626837
        AND  sty.stream_type_purpose in ('LOAN_PAYMENT', 'VARIABLE_LOAN_PAYMENT','UNSCHEDULED_PRINCIPAL_PAYMENT','UNSCHEDULED_LOAN_PAYMENT')
        AND  sel.date_billed is null
        AND  stm.id = sel.stm_id
        AND  sel.stream_element_date >=p_loan_start_date
        AND  sel.stream_element_date <=p_end_date
        GROUP BY
             sel.stream_element_date ,
             decode(sty.stream_type_purpose,'LOAN_PAYMENT',1,'UNSCHEDULED_PRINCIPAL_PAYMENT',2,'UNSCHEDULED_LOAN_PAYMENT',2,'VARIABLE_LOAN_PAYMENT',3,4),
             sel.comments,
             sty.stream_type_purpose
        ORDER BY stream_element_date,
               decode(sty.stream_type_purpose,'LOAN_PAYMENT',1,'UNSCHEDULED_PRINCIPAL_PAYMENT',2,'UNSCHEDULED_LOAN_PAYMENT',2,'VARIABLE_LOAN_PAYMENT',3,4);

      CURSOR get_precision(p_currency_code OKC_K_HEADERS_B.CURRENCY_CODE%TYPE) IS
      SELECT PRECISION
      FROM fnd_currencies_vl
      WHERE currency_code = p_currency_code
      AND enabled_flag = 'Y'
      AND NVL(start_date_active, SYSDATE) <= SYSDATE
      AND NVL(end_date_active, SYSDATE) >= SYSDATE;

    TYPE loan_rec IS RECORD (se_amount NUMBER,
                             se_date DATE,
           se_days NUMBER,
           se_arrears okl_strm_elements.comments%type,
           se_purpose okl_strm_type_b.stream_type_purpose%type);

    TYPE loan_tbl IS TABLE OF loan_rec INDEX BY BINARY_INTEGER;

    round_interest_tbl  Okl_Streams_Pub.selv_tbl_type;
    rounded_interest_tbl  Okl_Streams_Pub.selv_tbl_type;

    interest_rate_tbl         OKL_VARIABLE_INTEREST_PVT.interest_rate_tbl_type;

    asset_rents        loan_tbl;

    l_sty_id NUMBER;
    l_stream_name VARCHAR2(256);

    l_start_date       DATE;

    l_open_book        NUMBER;
    l_close_book       NUMBER;
    l_payment          NUMBER;
    l_interest         NUMBER;
    l_interest_unsch_prin_pay NUMBER:=0;
    l_principal        NUMBER;

    l_iir              NUMBER;
    l_rent_period_end  c_contract_end_date%ROWTYPE;
    k                  BINARY_INTEGER    :=  0;
    lx_return_status   VARCHAR2(1);

    l_day_convention_month VARCHAR2(30);
    l_day_convention_year VARCHAR2(30);
    l_days_in_year NUMBER;

    l_exit_loop_flag VARCHAR2(2);

    l_precision        NUMBER;

    p_init_msg_list  varchar2(256);
    x_msg_count   number;
    x_msg_data  varchar2(256);

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    -- Get the interest rate for the start date

    OKL_VARIABLE_INTEREST_PVT.interest_date_range (
            p_api_version   => g_api_version,
            p_init_msg_list => p_init_msg_list,
            x_return_status => lx_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_contract_id   => p_khr_id,
            p_start_date    => p_start_date,
            p_end_date      => p_start_date,
            p_process_flag  => OKL_VARIABLE_INTEREST_PVT.G_INTEREST_CALCULATION_BASIS,
            x_interest_rate_tbl =>interest_rate_tbl);

    IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--    print( l_prog_name, 'interest_rate_tbl.COUNT:' || interest_rate_tbl.COUNT );
--    print( l_prog_name, 'interest_rate_tbl(1).rate:' || interest_rate_tbl(1).rate );
    if interest_rate_tbl.COUNT = 0 THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    IF interest_rate_tbl(1).rate = 0 THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_iir:=interest_rate_tbl(1).rate;
    x_interest_rate:=l_iir;

--    print( l_prog_name, 'l_iir ' || l_iir );

    l_iir:=l_iir/100;

    -- Get the contract last date
    open  c_contract_end_date(p_khr_id);
    fetch c_contract_end_date into l_rent_period_end;
    close c_contract_end_date;

    open get_precision(l_rent_period_end.currency_code);
    fetch get_precision into l_precision;
    close get_precision;

   -- Fetch the day convention ..
   OKL_PRICING_UTILS_PVT.get_day_convention(
     p_id              => p_khr_id,
     p_source          => 'ISG',
     x_days_in_month   => l_day_convention_month,
     x_days_in_year    => l_day_convention_year,
     x_return_status   => lx_return_status);

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
   END IF;
   IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   OPEN c_rent_slls;
   FETCH c_rent_slls INTO l_rent_sll;
   CLOSE c_rent_slls;


--   print( l_prog_name, 'l_rent_sll.arrears_yn ' || l_rent_sll.arrears_yn );

   l_start_date  := p_start_date;

--   print( l_prog_name, 'l_start_date ' || l_start_date );
--   print( l_prog_name, 'l_rent_sll.dpp ' || l_rent_sll.dpp );
--   print( l_prog_name, 'l_rent_period_end ' || l_rent_period_end);
--   print( l_prog_name, 'l_rent_period_end ' || (l_rent_period_end + l_rent_sll.dpp));
     --  print( l_prog_name, 'No of rent flow rows fetched:'||c_rent_flows(p_start_date,l_rent_period_end + l_rent_sll.dpp)%count);

   FOR  l_rent_flow IN c_rent_flows(p_start_date,l_rent_period_end.end_date + l_rent_sll.dpp) LOOP
       k := k + 1;

       print( l_prog_name, 'l_start_date :' || l_start_date );

       asset_rents(k).se_days    :=  OKL_PRICING_UTILS_PVT.get_day_count(p_start_date    => l_start_date,
                                                                         p_days_in_month => l_day_convention_month,
                                                                         p_days_in_year => l_day_convention_year,
                                                                         p_end_date      => l_rent_flow.se_date,
                                                                         p_arrears       => l_rent_flow.se_arrears,
                                                                         x_return_status => lx_return_status);

      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      if ( l_rent_flow.stream_type_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT') then
          asset_rents(k).se_purpose := 'P';
      else
          asset_rents(k).se_purpose := 'B';
      end if;

--      print( l_prog_name, 'asset_rents(k).se_days ' || asset_rents(k).se_days );
--      print( l_prog_name, 'l_rent_flow.se_amount ' || l_rent_flow.se_amount );
      asset_rents(k).se_amount  :=  l_rent_flow.se_amount;
      asset_rents(k).se_date    :=  l_rent_flow.se_date;
      asset_rents(k).se_arrears :=  l_rent_flow.se_arrears;
      l_start_date :=l_rent_flow.se_date;

--      print( l_prog_name, 'l_rent_flow.se_arrears:' || l_rent_flow.se_arrears );

    END LOOP;

--    print( l_prog_name, ' asset rent count ' || to_char(asset_rents.COUNT));

    l_open_book  :=  p_investment;
--    print( l_prog_name, ' Investment ' || to_char(l_open_book));
--    print( l_prog_name, 'asset_rents.COUNT:'||asset_rents.COUNT);

    FOR k IN 1..asset_rents.COUNT LOOP
        l_principal  :=0;
        l_interest   :=0;
        l_payment    :=  asset_rents(k).se_amount;
--        print( l_prog_name, 'asset_rents(k).se_amount:'||asset_rents(k).se_amount);
--        print( l_prog_name, 'asset_rents(k).se_days:'||asset_rents(k).se_days);
--        print( l_prog_name, 'l_open_book:'||l_open_book);

        if (l_open_book < asset_rents(k).se_amount  and k < asset_rents.COUNT )
            or  (k=asset_rents.COUNT and l_open_book > 0) then
           l_close_book :=l_open_book-l_close_book;
           IF ( asset_rents(k).se_purpose = 'B' ) then
              l_interest   :=  l_open_book*asset_rents(k).se_days*l_iir/360;
              l_interest   := ROUND(l_interest, l_precision);
              if l_interest_unsch_prin_pay > 0 then
                 l_interest  :=  l_interest + l_interest_unsch_prin_pay;
                 l_interest_unsch_prin_pay:=0;
              end if;
              l_principal  :=  l_open_book;
           ELSE
              l_interest   :=  l_open_book*asset_rents(k).se_days*l_iir/360;
              l_interest   := ROUND(l_interest, l_precision);
              if l_interest_unsch_prin_pay > 0 then
                 l_interest  :=  l_interest + l_interest_unsch_prin_pay;
                 l_interest_unsch_prin_pay:=0;
              end if;
              l_principal  :=  l_payment;
           END IF;
           l_open_book  :=  l_close_book;
           l_exit_loop_flag:='Y';
        else
           If ( asset_rents(k).se_purpose = 'B' ) then
             l_interest   :=  l_open_book*asset_rents(k).se_days*l_iir/360;
             l_interest   := ROUND(l_interest, l_precision);
             if l_interest_unsch_prin_pay > 0 then
                l_interest  :=  l_interest + l_interest_unsch_prin_pay;
                l_interest_unsch_prin_pay:=0;
             end if;
             l_principal  :=  l_payment - l_interest;
           else
             if ( asset_rents(k).se_purpose = 'L' ) then
                l_interest   :=  l_open_book*asset_rents(k).se_days*l_iir/360;
                l_interest   := ROUND(l_interest, l_precision);
             else
                l_interest_unsch_prin_pay:=l_interest_unsch_prin_pay+l_open_book*asset_rents(k).se_days*l_iir/360;
                l_interest_unsch_prin_pay   := ROUND(l_interest_unsch_prin_pay, l_precision);
             end if;
             l_principal  :=  l_payment;
           end if;
           l_close_book :=  l_open_book - l_principal;
           l_open_book  :=  l_close_book;
        end if;

        x_schedule_table(k).schedule_principal  :=  l_principal;
        x_schedule_table(k).schedule_interest   :=  l_interest;

        x_schedule_table(k).schedule_prin_bal   :=  l_close_book;
        x_schedule_table(k).schedule_date       :=  asset_rents(k).se_date;

        print( l_prog_name, l_principal||'  '||l_interest||'   '||l_close_book);

        print( l_prog_name, 'l_open_book:'||l_open_book);

        IF l_exit_loop_flag='Y' THEN
          EXIT;
        END IF;
    END LOOP;
  x_return_status  :=  lx_return_status;
  print( l_prog_name, 'end' );

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

  END generate_loan_schedules;


 PROCEDURE print(p_progname IN VARCHAR2,p_message  IN  VARCHAR2)
 IS
 BEGIN
     fnd_file.put_line (fnd_file.log,p_progname||'::'||p_message);
     okl_debug_pub.logmessage(p_progname||'::'||p_message);
 END print;

END OKL_PRICING_PVT;

/
