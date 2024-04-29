--------------------------------------------------------
--  DDL for Package Body OKL_GENERATE_PV_RENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_GENERATE_PV_RENT_PVT" AS
/* $Header: OKLRTPVB.pls 120.1 2008/05/22 23:40:31 snizam noship $ */

l_debug_level NUMBER :=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
l_proc_level NUMBER  :=FND_LOG.LEVEL_PROCEDURE;
l_stat_level NUMBER  :=FND_LOG.LEVEL_STATEMENT;

-- Start of comments
--	API name 	:  generate_total_pv_rent
--	Pre-reqs	: None
--	Function	:
--	Parameters	:
--	Version	: 1.0
--	History   : Durga Janaswamy created
-- End of comments

PROCEDURE generate_total_pv_rent
        (p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,p_khr_id               IN  NUMBER
	,x_total_pv_rent        OUT NOCOPY      NUMBER
	,x_return_status	OUT NOCOPY      VARCHAR2
	,x_msg_count		OUT NOCOPY      NUMBER
	,x_msg_data	        OUT NOCOPY      VARCHAR2
        )
IS

    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
  l_api_version	    CONSTANT NUMBER         := 1;
  l_api_name	    CONSTANT VARCHAR2(30)   := 'GENERATE_TOTAL_PV_RENT';
  l_return_status   VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;

    ------------------------------------------------------------
    -- Declare records: Extension Headers, Extension Lines
    ------------------------------------------------------------

CURSOR c_hdr_csr (p_khr_id NUMBER)  IS
      SELECT chr.template_yn,
             chr.currency_code,
             chr.start_date,
             chr.end_date,
             khr.deal_type,
             khr.term_duration,
	     nvl(rpar.base_rate, 10) base_rate
      FROM   okc_k_headers_b chr,
             okl_k_headers khr,
             OKL_K_RATE_PARAMS rpar
      WHERE  khr.id = p_khr_id
        AND  chr.id = khr.id
	AND  rpar.khr_id(+) = khr.id;

 l_hdr_csr_rec                    c_hdr_csr%ROWTYPE;

--  UNSCHEDULED_PRINCIPAL_PAYMENT, PRINCIPAL_PAYMENT  these are for LOAN only
--  UNSCHEDULED_INTEREST_PAYMENT

CURSOR c_asset_id_csr (p_khr_id NUMBER) IS
     SELECT  cle.id, sty.stream_type_purpose,
             NVL(kle.capital_amount,0)  capital_amount,
             NVL(kle.residual_value, 0) residual_value
      FROM   okc_rule_groups_b rgp,
             okc_rules_b rul1,
             okc_k_lines_b cle,
             okl_k_lines kle,
             okc_line_styles_b lse,
	     okl_strm_type_b sty
      WHERE  rul1.dnz_chr_id = p_khr_id
        AND  rul1.rule_information_category = 'LASLH'
        AND  rul1.rgp_id = rgp.id
        AND  rgp.cle_id = cle.id
        AND  cle.sts_code in ('INCOMPLETE','ENTERED','NEW')
        AND  cle.id = kle.id
        AND  cle.lse_id = lse.id
        AND  lse.lty_code = 'FREE_FORM1'
	AND  sty.id = to_number(rul1.object1_id1)
        AND  (sty.stream_type_purpose =  'RENT'
               or sty.stream_type_purpose = 'DOWN_PAYMENT');

l_asset_id_tbl             asset_id_tbl_type;

l_total_cash_inflow_tbl    cash_flow_tbl;

l_total_rent_inflow_tbl    cash_flow_tbl;
lx_total_rent_inflow_tbl    cash_flow_tbl;

l_pricing_engine           okl_st_gen_tmpt_sets.pricing_engine%TYPE;

l_day_convention_month     okl_st_gen_tmpt_sets.days_in_month_code%TYPE;

l_day_convention_year      okl_st_gen_tmpt_sets.days_in_yr_code%TYPE;

l_arrears_pay_dates_option  okl_st_gen_tmpt_sets.isg_arrears_pay_dates_option%type;

l_time_zero_cost           NUMBER            := 0;

l_cost                     NUMBER;

l_residual_value           NUMBER            := 0;
l_guess_iir                NUMBER;

l_iir                      NUMBER;

l_pv_rent                  NUMBER           := 0;

l_pv_residual_value        NUMBER           := 0;

l_period_residual_value        NUMBER;

lx_total_rent_inflow_tbl_count  NUMBER := 0;

l_end_date                 DATE;

l_dpp                NUMBER;

l_ppy                NUMBER;

l_precision         fnd_currencies.precision%TYPE;

i                          BINARY_INTEGER := 0;


BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (l_proc_level >= l_debug_level) THEN
       FND_LOG.STRING(l_proc_level,'OKL_GENERATE_PV_RENT_PVT','Begin(+)');
    END IF;

    l_return_status := OKL_API.START_ACTIVITY(
                p_api_name      => l_api_name,
                p_pkg_name      => g_pkg_name,
                p_init_msg_list => p_init_msg_list,
                l_api_version   => l_api_version,
                p_api_version   => p_api_version,
                p_api_type      => '_PVT',
                x_return_status => l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		  RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN  c_hdr_csr (p_khr_id);
    FETCH c_hdr_csr INTO l_hdr_csr_rec;
    CLOSE c_hdr_csr;

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','khr_id:'||to_char(p_khr_id));
    END IF;

    l_guess_iir := l_hdr_csr_rec.base_rate / 100.0;

-- Fetch pricing engine value which will be used to determine arrears payment date for ESG
     OKL_STREAMS_UTIL.get_pricing_engine(
	                                     p_khr_id => p_khr_id,
	                                     x_pricing_engine => l_pricing_engine,
	                                     x_return_status => x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

--    l_pricing_engine = 'EXTERNAL'

 -- Fetch the day convention ..
-- p_source cannot be ESG because it returns  days_in_month as 360
    OKL_PRICING_UTILS_PVT.get_day_convention(
     p_id              => p_khr_id,
     p_source          => 'ISG',
     x_days_in_month   => l_day_convention_month,
     x_days_in_year    => l_day_convention_year,
     x_return_status   => l_return_status);


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,
             'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','Month / Year = '||to_char(l_day_convention_month) || '/' || to_char(l_day_convention_year));
    END IF;

    IF l_pricing_engine = 'INTERNAL' THEN
    OKL_ISG_UTILS_PVT.get_arrears_pay_dates_option(
        p_khr_id                   => p_khr_id,
        x_arrears_pay_dates_option => l_arrears_pay_dates_option,
        x_return_status            => l_return_status);
   END IF;


    IF l_pricing_engine = 'EXTERNAL' THEN
        l_arrears_pay_dates_option := 'FIRST_DAY_OF_NEXT_PERIOD';
      ELSE
        l_arrears_pay_dates_option := 'LAST_DAY_OF_PERIOD';
    END IF;

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','l_arrears_pay_dates_option :'||l_arrears_pay_dates_option);
    END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    SELECT NVL(precision,0)
    INTO   l_precision
    FROM   fnd_currencies
    WHERE  currency_code = l_hdr_csr_rec.currency_code;

    i := 0;
    l_asset_id_tbl.delete;
    l_total_rent_inflow_tbl.delete;
    lx_total_rent_inflow_tbl.delete;

    OPEN  c_asset_id_csr (p_khr_id);
    FETCH c_asset_id_csr BULK COLLECT INTO l_asset_id_tbl;

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','Number of records in l_asset_id_tbl :'||to_char(l_asset_id_tbl.COUNT));
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','Calling procedure generate_asset_rent.');
    END IF;

--Bug 7015073: Start
  IF l_asset_id_tbl.COUNT > 0 THEN
    FOR a in l_asset_id_tbl.FIRST..l_asset_id_tbl.LAST LOOP
        i := i + 1;
    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','l_asset_id_tbl(i).id :'||to_char(l_asset_id_tbl(i).id));
    END IF;

        -- generating the cash inflows
        OKL_GENERATE_PV_RENT_PVT.generate_asset_rent
        (p_api_version          => p_api_version,
        p_init_msg_list         => p_init_msg_list,
        p_khr_id                => p_khr_id,
        p_kle_id                => l_asset_id_tbl(i).id,
        p_contract_start_date   => l_hdr_csr_rec.start_date,
        p_day_convention_month  =>  l_day_convention_month,
        p_day_convention_year   =>  l_day_convention_year,
        p_arrears_pay_dates_option => l_arrears_pay_dates_option,
        p_total_rent_inflow_tbl => l_total_rent_inflow_tbl,
        x_total_rent_inflow_tbl => lx_total_rent_inflow_tbl,
        x_dpp                   => l_dpp,
        x_ppy                   => l_ppy,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data
        );

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

        l_total_rent_inflow_tbl := lx_total_rent_inflow_tbl;



--      IF l_asset_cost.start_date <= p_start_date THEN
 --       l_cost := nvl(l_asset_cost.capital_amount, 0) + nvl(l_asset_cost.capitalized_interest,0);
        l_cost := NVL(l_asset_id_tbl(i).capital_amount, 0);
        l_time_zero_cost := l_time_zero_cost + NVL(l_cost, 0);
  --     END IF;

        l_residual_value := NVL(l_asset_id_tbl(i).residual_value, 0) + l_residual_value;

  END LOOP;
 END IF;
--Bug 7015073: End

 l_end_date      := (ADD_MONTHS(l_hdr_csr_rec.start_date,l_hdr_csr_rec.term_duration) - 1);

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','l_residual_value:'||to_char(l_residual_value));
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','l_time_zero_cost:'||to_char(l_time_zero_cost));
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','l_end_date :'||to_char(l_end_date));
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','Total_rent_inflow_tbl_count :'||to_char(l_total_rent_inflow_tbl.COUNT));
    END IF;

  -- l_total_cash_inflow_tbl = lx_total_rent_inflow_tbl + residual value

  l_total_cash_inflow_tbl := lx_total_rent_inflow_tbl;

  lx_total_rent_inflow_tbl_count  :=lx_total_rent_inflow_tbl.count;


  IF l_residual_value > 0 THEN
    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','l_dpp:'||to_char(l_dpp));
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','l_ppy:'||to_char(l_ppy));
    END IF;

         l_total_cash_inflow_tbl(lx_total_rent_inflow_tbl_count + 1).cf_amount         := l_residual_value;
         l_total_cash_inflow_tbl(lx_total_rent_inflow_tbl_count + 1).cf_number         := lx_total_rent_inflow_tbl_count+1;        -- TBD
         l_total_cash_inflow_tbl(lx_total_rent_inflow_tbl_count + 1).cf_date           := l_end_date;
         l_total_cash_inflow_tbl(lx_total_rent_inflow_tbl_count + 1).cf_arrears        := 'Y';
         l_total_cash_inflow_tbl(lx_total_rent_inflow_tbl_count + 1).cf_stub           := 'N';
         l_total_cash_inflow_tbl(lx_total_rent_inflow_tbl_count + 1).cf_purpose        := 'RESIDUAL';
         l_total_cash_inflow_tbl(lx_total_rent_inflow_tbl_count + 1).cf_dpp            := l_dpp;
         l_total_cash_inflow_tbl(lx_total_rent_inflow_tbl_count + 1).cf_ppy            := l_ppy;
         l_total_cash_inflow_tbl(lx_total_rent_inflow_tbl_count + 1).kleId             := -1;

         l_total_cash_inflow_tbl(lx_total_rent_inflow_tbl_count + 1).cf_days           := OKL_PRICING_UTILS_PVT.get_day_count(
                                                 p_start_date    => l_hdr_csr_rec.start_date,
                                                 p_days_in_month => l_day_convention_month,
                                                 p_days_in_year  => l_day_convention_year,
                                                 p_end_date      => l_end_date,
                                                 p_arrears       =>  'Y',
                                                 x_return_status => l_return_status);


        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    END IF;

    IF l_stat_level >= l_debug_level THEN
      IF l_total_rent_inflow_tbl.COUNT > 0 THEN
          FOR j IN l_total_rent_inflow_tbl.FIRST .. l_total_rent_inflow_tbl.LAST
           LOOP
             fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent',
               TO_CHAR(l_total_rent_inflow_tbl(j).cf_number||' '||l_total_rent_inflow_tbl(j).cf_date || ' ' || l_total_rent_inflow_tbl(j).cf_amount));
         END LOOP;
      END IF;
    END IF;

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','Total_cash_inflow_tbl_count:'||to_char(l_total_cash_inflow_tbl.count));
    END IF;

    IF l_stat_level >= l_debug_level THEN
       IF l_total_cash_inflow_tbl.COUNT > 0 THEN
         FOR j IN l_total_cash_inflow_tbl.FIRST .. l_total_cash_inflow_tbl.LAST
         LOOP
         fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent',
           TO_CHAR(l_total_cash_inflow_tbl(j).cf_number||' '||l_total_cash_inflow_tbl(j).cf_date || ' ' || l_total_cash_inflow_tbl(j).cf_amount));
         END LOOP;
      END IF;
    END IF;


-- calculating IIR
    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','Calling procedure compute_iir');
    END IF;

 OKL_GENERATE_PV_RENT_PVT.compute_iir ( p_khr_id => p_khr_id,
                       p_cash_in_flows_tbl   => l_total_cash_inflow_tbl,
                       p_cash_out_flows  => l_time_zero_cost,
                       p_initial_iir     =>  l_guess_iir,
                       p_precision       =>  l_precision,
                       x_iir             =>  l_iir,
                       x_return_status   =>  x_return_status,
                       x_msg_count       => x_msg_count,
                       x_msg_data        => x_msg_data
                       );

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','l_iir: '||TO_CHAR(l_iir));
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','calculating the PV rent');
    END IF;

-- calculating the PV rent

IF l_residual_value > 0 THEN
    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','calculating the PV of residual value');
    END IF;

 l_period_residual_value  :=  l_total_cash_inflow_tbl(lx_total_rent_inflow_tbl_count + 1).cf_days/l_dpp;

 l_pv_residual_value := l_residual_value / POWER( 1 + (l_iir/(l_ppy)), l_period_residual_value);

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent',
                         'PV of residual value: '||TO_CHAR(l_pv_residual_value));
    END IF;
END IF;

l_pv_rent  := l_time_zero_cost - nvl(l_pv_residual_value,0);



   x_total_pv_rent := ROUND(l_pv_rent,l_precision);

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent','x_total_pv_rent: '||TO_CHAR(x_total_pv_rent));
    END IF;


    IF (l_proc_level >= l_debug_level) THEN
       FND_LOG.STRING(l_proc_level,'OKL_GENERATE_PV_RENT_PVT','End(-)');
    END IF;

   okl_api.end_activity(x_msg_count => x_msg_count
                      ,x_msg_data => x_msg_data);


EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN OKL_API.G_EXCEPTION_ERROR THEN

           IF c_asset_id_csr%ISOPEN THEN
              CLOSE c_asset_id_csr;
           END IF;

           x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

 	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

           IF c_asset_id_csr%ISOPEN THEN
              CLOSE c_asset_id_csr;
           END IF;

           x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN

           IF c_asset_id_csr%ISOPEN THEN
              CLOSE c_asset_id_csr;
           END IF;

	   x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

END generate_total_pv_rent;


-- Start of comments
--      API name        :
--      Pre-reqs        : None
--      Function        :
--      Parameters      :
--      Version : 1.0
--      History   : Durga Janaswamy created
-- End of comments


PROCEDURE generate_asset_rent
        (p_api_version           IN  NUMBER
        ,p_init_msg_list         IN  VARCHAR2
        ,p_khr_id                IN  NUMBER
        ,p_kle_id                IN  NUMBER
        ,p_contract_start_date   IN  DATE
        ,p_day_convention_month  IN  VARCHAR2
        ,p_day_convention_year   IN  VARCHAR2
        ,p_arrears_pay_dates_option IN VARCHAR2
        ,p_total_rent_inflow_tbl IN  OKL_GENERATE_PV_RENT_PVT.cash_flow_tbl
        ,x_total_rent_inflow_tbl OUT NOCOPY     OKL_GENERATE_PV_RENT_PVT.cash_flow_tbl
        ,x_dpp                   OUT NOCOPY      NUMBER
        ,x_ppy                   OUT NOCOPY      NUMBER
        ,x_return_status         OUT NOCOPY      VARCHAR2
        ,x_msg_count             OUT NOCOPY      NUMBER
        ,x_msg_data              OUT NOCOPY      VARCHAR2
        )
IS

    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
  l_api_version     CONSTANT NUMBER         := 1;
  l_api_name        CONSTANT VARCHAR2(30)   := 'GENERATE_ASSET_PV_RENT';
  l_return_status   VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;


  ------------------------------------------------------------
    -- Declare records: Extension Headers, Extension Lines
  ------------------------------------------------------------

CURSOR c_payment_details_csr (p_khr_id NUMBER, p_kle_id NUMBER) IS
    SELECT   rgp.cle_id cle_id,  sty.stream_type_purpose, sty.id sty_id,
             FND_DATE.canonical_to_date(sll.rule_information2) start_date,
             TO_NUMBER(SLL.rule_information3) periods,
             sll.object1_id1 frequency,
             sll.rule_information5 structure,
             NVL(sll.rule_information10, 'N') arrears_yn,
             DECODE(sll.object1_id1, 'M', 30, 'Q', 120, 'S', 180, 'A', 360) days_per_period,
             DECODE(sll.object1_id1, 'M', 12, 'Q', 4, 'S', 2, 'A', 1) periods_per_year,
             DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) months_per_period,
             FND_NUMBER.canonical_to_number(sll.rule_information6) amount,
             TO_NUMBER(sll.rule_information7) stub_days,
             TO_NUMBER(sll.rule_information8) stub_amount
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
	AND  (sty.stream_type_purpose =  'RENT'
               or sty.stream_type_purpose = 'DOWN_PAYMENT')
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
      ORDER BY fnd_date.canonical_to_date(sll.rule_information2);

 l_payment_details_csr_rec   c_payment_details_csr%ROWTYPE;

 l_cash_inflow_tbl    cash_flow_tbl;
 l_rent_inflow_tbl    cash_flow_tbl;
 lx_rent_inflow_tbl    cash_flow_tbl;
 lx_rent_inflow_tbl_count  NUMBER := 0;

 l_recurrence_date    DATE := NULL;
 l_old_cle_id         NUMBER;
 l_old_sty_id         NUMBER;

l_dpp                NUMBER;

l_ppy                NUMBER;

BEGIN

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_asset_rent','Begin(+)');
    END IF;

  l_return_status := OKL_API.START_ACTIVITY(
                p_api_name      => l_api_name,
                p_pkg_name      => g_pkg_name,
                p_init_msg_list => p_init_msg_list,
                l_api_version   => l_api_version,
                p_api_version   => p_api_version,
                p_api_type      => '_PVT',
                x_return_status => l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



        l_rent_inflow_tbl.delete;
        lx_rent_inflow_tbl.delete;
        l_rent_inflow_tbl := p_total_rent_inflow_tbl;

   FOR l_payment_details_csr_rec IN c_payment_details_csr (p_khr_id, p_kle_id)
   LOOP

            IF l_payment_details_csr_rec.start_date IS NULL
            THEN
              OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                   p_msg_name     => 'OKL_NO_SLL_SDATE');
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;

           IF((l_payment_details_csr_rec.periods IS NULL) AND (l_payment_details_csr_rec.stub_days IS NOT NULL)) THEN
             --Set the recurrence date to null for stub payment
             l_recurrence_date := NULL;
           ELSIF(l_recurrence_date IS NULL
              OR l_old_cle_id <> l_payment_details_csr_rec.cle_id
              OR l_old_sty_id <> l_payment_details_csr_rec.sty_id) THEN
             --Set the recurrence date as periodic payment level start date
             l_recurrence_date := l_payment_details_csr_rec.start_date;
           END IF;
           l_old_cle_id := l_payment_details_csr_rec.cle_id;
           l_old_sty_id := l_payment_details_csr_rec.sty_id;


        OKL_GENERATE_PV_RENT_PVT.generate_stream_elements(
                            p_start_date          =>   l_payment_details_csr_rec.start_date,
                            p_periods             =>   l_payment_details_csr_rec.periods,
                            p_frequency           =>   l_payment_details_csr_rec.frequency,
                            p_structure           =>   l_payment_details_csr_rec.structure,
                            p_arrears_yn          =>   l_payment_details_csr_rec.arrears_yn,
                            p_amount              =>   l_payment_details_csr_rec.amount,
                            p_stub_days           =>   l_payment_details_csr_rec.stub_days,
                            p_stub_amount         =>   l_payment_details_csr_rec.stub_amount,
                            p_khr_id              =>   p_khr_id,
                            p_kle_id              =>   p_kle_id,
                            p_purpose_code        =>   l_payment_details_csr_rec.stream_type_purpose,
                            p_recurrence_date     =>   l_recurrence_date,
                            p_dpp                 =>   l_payment_details_csr_rec.days_per_period,
                            p_ppy                 =>   l_payment_details_csr_rec.periods_per_year,
                            p_months_factor       =>   l_payment_details_csr_rec.months_per_period,
                            p_contract_start_date =>   p_contract_start_date,
                            p_day_convention_month =>  p_day_convention_month,
                            p_day_convention_year =>   p_day_convention_year,
                            p_arrears_pay_dates_option => p_arrears_pay_dates_option,
                            p_rent_inflow_tbl     =>   l_rent_inflow_tbl,
                            x_rent_inflow_tbl     =>   lx_rent_inflow_tbl,
                            x_return_status       =>   l_return_status,
                            x_msg_count           =>   x_msg_count,
                            x_msg_data            =>   x_msg_data
                            );

        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

                            l_rent_inflow_tbl    :=   lx_rent_inflow_tbl;

                            l_dpp                :=   l_payment_details_csr_rec.days_per_period;
                            l_ppy                :=   l_payment_details_csr_rec.periods_per_year;

  END LOOP;

   x_total_rent_inflow_tbl := lx_rent_inflow_tbl;

   x_dpp  := l_dpp;

   x_ppy := l_ppy;


    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_asset_rent',
                      'x_total_rent_inflow_tbl.count :'||TO_CHAR(x_total_rent_inflow_tbl.count));
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_asset_rent','End(-)');
    END IF;


    okl_api.end_activity(x_msg_count => x_msg_count
                         ,x_msg_data => x_msg_data);



EXCEPTION
        ------------------------------------------------------------
        -- Exception handling
        ------------------------------------------------------------

        WHEN OKL_API.G_EXCEPTION_ERROR THEN

            IF c_payment_details_csr%ISOPEN THEN
                CLOSE c_payment_details_csr;
            END IF;

            x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => G_PKG_NAME,
                                        p_exc_name      => 'OKL_API.G_RET_STS_ERROR',
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_api_type      => '_PVT');

        WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

            IF c_payment_details_csr%ISOPEN THEN
               CLOSE c_payment_details_csr;
            END IF;

            x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => G_PKG_NAME,
                                        p_exc_name      => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_api_type      => '_PVT');

      WHEN OTHERS THEN

            IF c_payment_details_csr%ISOPEN THEN
                CLOSE c_payment_details_csr;
            END IF;

            x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => G_PKG_NAME,
                                        p_exc_name      => 'OTHERS',
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_api_type      => '_PVT');

END generate_asset_rent;



-- Start of comments
--      API name        :
--      Pre-reqs        : None
--      Function        :
--      Parameters      :
--      Version : 1.0
--      History   : Durga Janaswamy created
-- End of comments

PROCEDURE generate_stream_elements( p_start_date       IN      DATE,
                                 p_periods             IN      NUMBER,
                                 p_frequency           IN      VARCHAR2,
                                 p_structure           IN      VARCHAR2,
                                 p_arrears_yn          IN      VARCHAR2,
                                 p_amount              IN      NUMBER,
                                 p_stub_days           IN      NUMBER,
                                 p_stub_amount         IN      NUMBER,
                                 p_khr_id              IN      NUMBER,
                                 p_kle_id              IN      NUMBER,
                                 p_purpose_code        IN      VARCHAR2,
                                 p_recurrence_date     IN      DATE,
                                 p_dpp                 IN      NUMBER,
                                 p_ppy                 IN      NUMBER,
                                 p_months_factor       IN      NUMBER,
                                 p_contract_start_date IN      DATE,
                                 p_day_convention_month IN     VARCHAR2,
                                 p_day_convention_year  IN     VARCHAR2,
                                 p_arrears_pay_dates_option IN VARCHAR2,
                                 p_rent_inflow_tbl     IN      OKL_GENERATE_PV_RENT_PVT.cash_flow_tbl,
                                 x_rent_inflow_tbl     OUT     NOCOPY OKL_GENERATE_PV_RENT_PVT.cash_flow_tbl,
                                 x_return_status       OUT     NOCOPY VARCHAR2,
                                 x_msg_count           OUT     NOCOPY NUMBER,
                                 x_msg_data            OUT     NOCOPY VARCHAR2
) IS


    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
  l_api_version     CONSTANT NUMBER         := 1;
  l_api_name        CONSTANT VARCHAR2(30)   := 'GENERATE_STREAM_ELEMENTS';
  l_return_status   VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;


    ------------------------------------------------------------
    -- Declare records: Extension Headers, Extension Lines
    ------------------------------------------------------------

    l_rent_inflow_tbl        cash_flow_tbl;


    l_element_count              NUMBER;
    l_amount                     NUMBER;

    i                          BINARY_INTEGER := 0;
    l_rent_inflow_tbl_count      NUMBER := 0;

BEGIN


    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_stream_elements','Begin(+)');
    END IF;

    x_rent_inflow_tbl := p_rent_inflow_tbl;

    l_rent_inflow_tbl_count := nvl(p_rent_inflow_tbl.count,0);

    IF ( p_amount IS NULL )
    THEN
        l_amount := NULL;
    ELSE
        l_amount := p_amount;
    END IF;


    IF ( p_periods IS NULL ) AND ( p_stub_days IS NOT NULL )
    THEN
        x_rent_inflow_tbl(l_rent_inflow_tbl_count + 1).cf_amount          := p_stub_amount;
        x_rent_inflow_tbl(l_rent_inflow_tbl_count + 1).cf_number          := l_rent_inflow_tbl_count + 1;           -- TBD

        IF p_arrears_yn = 'Y' THEN
               IF p_arrears_pay_dates_option = 'FIRST_DAY_OF_NEXT_PERIOD' THEN
                   x_rent_inflow_tbl(l_rent_inflow_tbl_count + 1).cf_date        := p_start_date + p_stub_days;
               ELSE
                   x_rent_inflow_tbl(l_rent_inflow_tbl_count + 1).cf_date        := p_start_date + p_stub_days - 1;
               END IF;
        ELSE
            x_rent_inflow_tbl(l_rent_inflow_tbl_count + 1).cf_date        := p_start_date;
        END IF;

         x_rent_inflow_tbl(l_rent_inflow_tbl_count + 1).cf_arrears        := p_arrears_yn;
         x_rent_inflow_tbl(l_rent_inflow_tbl_count + 1).cf_stub           := 'Y';
         x_rent_inflow_tbl(l_rent_inflow_tbl_count + 1).cf_purpose        := p_purpose_code;
         x_rent_inflow_tbl(l_rent_inflow_tbl_count + 1).cf_dpp            := p_dpp;
         x_rent_inflow_tbl(l_rent_inflow_tbl_count + 1).cf_ppy            := p_ppy;
         x_rent_inflow_tbl(l_rent_inflow_tbl_count + 1).kleId             := p_kle_id;

         x_rent_inflow_tbl(l_rent_inflow_tbl_count + 1).cf_days           := OKL_PRICING_UTILS_PVT.get_day_count(
                                                 p_start_date    => p_contract_start_date,
                                                 p_days_in_month => p_day_convention_month,
                                                 p_days_in_year => p_day_convention_year,
                                                 p_end_date      => x_rent_inflow_tbl(l_rent_inflow_tbl_count + 1).cf_date,
                                                 p_arrears       => x_rent_inflow_tbl(l_rent_inflow_tbl_count + 1).cf_arrears,
                                                 x_return_status => l_return_status);
         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

    ELSE


        l_element_count := p_periods;
        IF l_stat_level >= l_debug_level THEN
            fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_stream_elements',
                      'creating elements:'||TO_CHAR(l_element_count));
        END IF;

        FOR i IN (l_rent_inflow_tbl_count+1) .. (l_rent_inflow_tbl_count+l_element_count)
        LOOP
            x_rent_inflow_tbl(i).cf_amount      := l_amount;


            OKL_STREAM_GENERATOR_PVT.get_sel_date(
              p_start_date         => p_start_date,
              p_advance_or_arrears => p_arrears_yn,
              p_periods_after      => i - l_rent_inflow_tbl_count,
              p_months_per_period  => p_months_factor,
              x_date               => x_rent_inflow_tbl(i).cf_date,
              x_return_status      => l_return_status,
              p_recurrence_date    => p_recurrence_date,
              p_arrears_pay_dates_option => p_arrears_pay_dates_option);

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_stream_elements',
'get_sel_date-p_start_date:'||to_char(p_start_date)||' p_arrears_yn:'||p_arrears_yn||' i:'||i||' p_months_factor:'||p_months_factor||
' cf_date:'|| x_rent_inflow_tbl(i).cf_date||' p_recurrence_date:'||
p_recurrence_date||' p_arrears_pay_dates_option:'||p_arrears_pay_dates_option);



    END IF;

            IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

         x_rent_inflow_tbl(i).cf_number         := i;                            -- TBD
         x_rent_inflow_tbl(i).cf_arrears        := p_arrears_yn;
         x_rent_inflow_tbl(i).cf_stub           := 'N';
         x_rent_inflow_tbl(i).cf_purpose        := p_purpose_code;
         x_rent_inflow_tbl(i).cf_dpp            := p_dpp;
         x_rent_inflow_tbl(i).cf_ppy            := p_ppy;
         x_rent_inflow_tbl(i).kleId             := p_kle_id;

         x_rent_inflow_tbl(i).cf_days           := OKL_PRICING_UTILS_PVT.get_day_count(
                                                 p_start_date    => p_contract_start_date,
                                                 p_days_in_month => p_day_convention_month,
                                                 p_days_in_year => p_day_convention_year,
                                                 p_end_date      => x_rent_inflow_tbl(i).cf_date,
                                                 p_arrears       => x_rent_inflow_tbl(i).cf_arrears,
                                                 x_return_status => l_return_status);

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;


        END LOOP;
     END IF;

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_stream_elements',
                      'x_rent_inflow_tbl.count :'||TO_CHAR(x_rent_inflow_tbl.count));
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.generate_stream_elements','End(-)');
    END IF;



EXCEPTION
        ------------------------------------------------------------
        -- Exception handling
        ------------------------------------------------------------


       WHEN OKL_API.G_EXCEPTION_ERROR THEN

                x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => G_PKG_NAME,
                                        p_exc_name      => 'OKL_API.G_RET_STS_ERROR',
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_api_type      => '_PVT');

       WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

                x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => G_PKG_NAME,
                                        p_exc_name      => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_api_type      => '_PVT');


       WHEN OTHERS THEN

                x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => G_PKG_NAME,
                                        p_exc_name      => 'OTHERS',
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_api_type      => '_PVT');

END generate_stream_elements;



-- Start of comments
--      API name        :
--      Pre-reqs        : None
--      Function        :
--      Parameters      :
--      Version : 1.0
--      History   : Durga Janaswamy created
-- End of comments


PROCEDURE compute_iir (p_khr_id             IN      NUMBER,
                       p_cash_in_flows_tbl  IN      OKL_GENERATE_PV_RENT_PVT.cash_flow_tbl,
                       p_cash_out_flows     IN      NUMBER,
                       p_initial_iir        IN      NUMBER,
                       p_precision          IN      NUMBER,
                       x_iir                OUT     NOCOPY NUMBER,
                       x_return_status      OUT     NOCOPY VARCHAR2,
                       x_msg_count          OUT     NOCOPY NUMBER,
                       x_msg_data           OUT     NOCOPY VARCHAR2
)
IS
   -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
  l_api_version     CONSTANT NUMBER         := 1;
  l_api_name        CONSTANT VARCHAR2(30)   := 'COMPUTE_IIR';
  l_return_status   VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;


    ------------------------------------------------------------
    -- Declare records: Extension Headers, Extension Lines
    ------------------------------------------------------------

    a                 BINARY_INTEGER := 0;
    i                 BINARY_INTEGER := 0;

    l_iir             NUMBER         := NVL(p_initial_iir, 0);

    l_npv             NUMBER;

    l_prev_npv        NUMBER;
    l_prev_npv_sign   NUMBER;

    l_crossed_zero    VARCHAR2(1)     := 'N';

    -- l_increment       NUMBER         := 1.1;
    l_increment       NUMBER          := 0.11;
    l_abs_incr        NUMBER;
    l_prev_incr_sign  NUMBER;

    l_prev_iir        NUMBER          := 0;
    l_positive_npv_iir NUMBER         := 0;
    l_negative_npv_iir NUMBER         := 0;
    l_positive_npv    NUMBER          := 0;
    l_negative_npv    NUMBER          := 0;

    l_iir_decided     VARCHAR2(1)     := 'F';


    l_initial_incr    NUMBER;

    l_cf_dpp          NUMBER;
    l_cf_ppy          NUMBER;
    l_cf_amount       NUMBER;
    l_cf_date         DATE;
    l_cf_arrear       VARCHAR2(1);
    l_days_in_future  NUMBER;
    l_periods         NUMBER;


BEGIN

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.compute_iir','Begin(+)');
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.compute_iir','Initial iir estimated ' || TO_CHAR(l_iir));
    END IF;


    l_initial_incr := nvl(l_increment, 0);

    LOOP   -- first
      i                 :=  i + 1;
      l_npv             :=  -(p_cash_out_flows);

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.compute_iir','ITERATION # '||i||'  IIR Guess '||l_iir||' starting l_npv'||l_npv);
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.compute_iir','p_cash_in_flows_tbl.count ' || TO_CHAR(p_cash_in_flows_tbl.count));
    END IF;

    IF p_cash_in_flows_tbl.count > 0 THEN

--DEBUG
a :=0;

     FOR j in p_cash_in_flows_tbl.FIRST .. p_cash_in_flows_tbl.LAST LOOP
--DEBUG
a := a+1;

          l_cf_dpp          :=  p_cash_in_flows_tbl(j).cf_dpp;
          l_cf_ppy          :=  p_cash_in_flows_tbl(j).cf_ppy;
          l_cf_amount       :=  p_cash_in_flows_tbl(j).cf_amount;
          l_cf_date         :=  p_cash_in_flows_tbl(j).cf_date;
          l_days_in_future  :=  p_cash_in_flows_tbl(j).cf_days;
          l_periods         :=  l_days_in_future / l_cf_dpp;

          IF (l_periods < 1) AND (l_iir/l_cf_ppy <= -1) THEN

            OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_IRR_ZERO_DIV');

            RAISE OKL_API.G_EXCEPTION_ERROR;

          END IF;

          l_npv             := l_npv + (l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods));


    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.compute_iir',
                       TO_CHAR(a, '99')||'  '||TO_CHAR(l_cf_date, 'DD-MON-YYYY')||'  '||TO_CHAR(l_days_in_future, '9999')||'  '||TO_CHAR(l_periods, '99.999')||'  '||TO_CHAR(l_cf_amount, '999.999')||
  ' '||TO_CHAR((l_cf_amount / POWER((1 + l_iir/l_cf_ppy), l_periods)), '999.990'));
    END IF;

     END LOOP;

     END IF;

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.compute_iir','NPV ' || TO_CHAR(L_NPV));
    END IF;

     IF ROUND(l_npv, p_precision+1) = 0 THEN
        x_iir    := l_iir;  -- LLA API multiples by 100 before updating KHR implicit_interest_rate column
            IF l_stat_level >= l_debug_level THEN
                 fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.compute_iir','final l_iir : ' || TO_CHAR(l_iir));
            END IF;
        RETURN;
     END IF;

     IF i > 1 AND SIGN(l_npv) <> SIGN(l_prev_npv) AND l_crossed_zero = 'N' THEN

        l_crossed_zero := 'Y';

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

      l_prev_iir        := l_iir;

      IF l_iir_decided = 'F'
      THEN
      	l_iir             :=  l_iir + l_increment;
      ELSE
        l_iir_decided := 'F';
      END IF;

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.compute_iir',
                        i || '-Loop l_npv ' || to_char(l_npv) );
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.compute_iir',
                        i || '-Loop l_increment ' || to_char(l_increment) );
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.compute_iir',
                        i || '-Loop iir  '  || to_char(l_iir) );
    END IF;


      l_prev_incr_sign  :=  SIGN(l_increment);
      l_prev_npv_sign   :=  SIGN(l_npv);
      l_prev_npv        :=  l_npv;


END LOOP; -- first

    IF l_stat_level >= l_debug_level THEN
        fnd_log.STRING(l_stat_level,'OKL_GENERATE_PV_RENT_PVT.compute_iir','End(-)');
    END IF;


EXCEPTION
        ------------------------------------------------------------
        -- Exception handling
        ------------------------------------------------------------

        WHEN OKL_API.G_EXCEPTION_ERROR THEN

                x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => G_PKG_NAME,
                                        p_exc_name      => 'OKL_API.G_RET_STS_ERROR',
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_api_type      => '_PVT');

        WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

                x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => G_PKG_NAME,
                                        p_exc_name      => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_api_type      => '_PVT');

        WHEN OTHERS THEN

                x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => G_PKG_NAME,
                                        p_exc_name      => 'OTHERS',
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_api_type      => '_PVT');
END COMPUTE_IIR;


END OKL_GENERATE_PV_RENT_PVT;

/
