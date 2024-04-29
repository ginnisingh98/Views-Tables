--------------------------------------------------------
--  DDL for Package Body OKL_STREAM_GENERATOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STREAM_GENERATOR_PVT" AS
/* $Header: OKLRSGPB.pls 120.101.12010000.14 2010/02/05 05:07:24 rgooty ship $ */

  --Added for debug_logging
  L_DEBUG_ENABLED VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;

  TYPE interim_interest_rec_type IS RECORD (cf_days NUMBER, cf_amount NUMBER, cf_dpp NUMBER);
  TYPE interim_interest_tbl_type IS TABLE OF interim_interest_rec_type INDEX BY BINARY_INTEGER;
  -- Added by RGOOTY : Start

  CURSOR G_SRV_ASSETS_EXISTS_CSR( chrId NUMBER ) IS
  select 'T' flag
  from dual where exists
   (
    select 1
    from  okc_k_lines_b kle,
          okc_line_styles_b lse,
          okc_statuses_b sts
    where KLE.LSE_ID = LSE.ID
      and lse.lty_code = 'SOLD_SERVICE'
      and kle.chr_id = chrId
      and sts.code = kle.sts_code
      and sts.ste_code not in ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
   );

  G_ORG_ID              OKC_K_HEADERS_B.AUTHORING_ORG_ID%TYPE;
  G_CURRENCY_CODE       OKC_K_HEADERS_B.CURRENCY_CODE%TYPE;
  G_DIFF_LOOKUP_CODE    FND_LOOKUPS.LOOKUP_CODE%TYPE;
  G_PRECISION           NUMBER;
  G_ROUNDING_RULE       OKL_SYS_ACCT_OPTS.AEL_ROUNDING_RULE%TYPE;

  CURSOR G_HDR( p_khr_id OKC_K_HEADERS_V.ID%TYPE) IS
    select chr.orig_system_source_code,
        chr.start_date,
        chr.end_date,
        chr.template_yn,
	    chr.authoring_org_id,
        chr.inv_organization_id,
        khr.deal_type,
        to_char(pdt.id)  pid,
        nvl(pdt.reporting_pdt_id, -1) report_pdt_id,
        chr.currency_code currency_code,
        khr.term_duration term
    from  okc_k_headers_v chr,
          okl_k_headers khr,
          okl_products_v pdt
    where khr.id = chr.id
      and chr.id = p_khr_id
      and khr.pdt_id = pdt.id(+);
    r_hdr G_HDR%ROWTYPE;

    Cursor G_ROLLOVER_PMNTS(p_khr_id  OKC_RULE_GROUPS_B.dnz_chr_id%type ) IS
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

    r_rollover_pmnts G_ROLLOVER_PMNTS%ROWTYPE;
  -- Added by RGOOTY : End

  G_API_TYPE                CONSTANT  VARCHAR2(4) := '_PVT';
  G_IA_STS_NEW              CONSTANT VARCHAR2(6)  := okl_pool_pvt.G_POL_STS_NEW;
  G_IA_STS_ACTIVE           CONSTANT VARCHAR2(6)  := okl_pool_pvt.G_POL_STS_ACTIVE;
  G_IA_STS_INACTIVE         CONSTANT VARCHAR2(8)  := okl_pool_pvt.G_POL_STS_INACTIVE;
  G_IA_STS_EXPIRED          CONSTANT VARCHAR2(10) := okl_pool_pvt.G_POL_STS_EXPIRED;
  --sosharma 14-12-2007 ,Added pending status
    G_PC_STS_PENDING         CONSTANT VARCHAR2(8)  := 'PENDING';

  -- Added by RGOOTY: Start  4371472
  -- This add_months_new is modified to handle even the
  --   negative p_months_after ...
  -- Hence, we can use add_months_new to calculate the months before
  --  p_start_date
  PROCEDURE add_months_new(
    p_start_date     IN  DATE,
    p_months_after   IN  NUMBER,
    x_date           OUT NOCOPY DATE,
    x_return_status  OUT NOCOPY VARCHAR2)
  IS
    l_day              NUMBER;
    l_month            NUMBER;
    l_year             NUMBER;
    l_year_inc         NUMBER;

    l_api_name         VARCHAR2(30) := 'add_months_new';
    l_return_status    VARCHAR2(1);
  BEGIN
    -- Initialize the status
    l_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_month := to_char( p_start_date, 'MM'   );
    l_year  := to_char( p_start_date, 'YYYY' );
    l_day   := to_char( p_start_date, 'DD'   );
    --print( l_api_name || ': ' || 'l_month | l_year | l_day | p_months_after' );
    --print( l_api_name || ': ' || '1 |' || l_month || '|' ||  l_year || '|' ||  l_day || '|' || p_months_after );

    l_month := l_month + nvl(p_months_after,0);
    --print( l_api_name || ': ' ||  '2 |' || l_month || '|' ||  l_year || '|' ||  l_day || '|' || p_months_after );

    IF l_month > 0
    THEN
      l_year := l_year + floor( (l_month - 1) / 12);
      --print( l_api_name || ': ' || '3 |' || l_month || '|' ||  l_year || '|' ||  l_day || '|' || p_months_after );
      l_month := mod(l_month ,12 );
      --print( l_api_name || ': ' || '4 |' || l_month || '|' ||  l_year || '|' ||  l_day || '|' || p_months_after );
      IF l_month = 0
      THEN
        l_month := 12;
      END IF;
    ELSE
      l_year_inc := ceil( (ABS(l_month) + 1 ) / 12 );
      l_year := l_year - l_year_inc;
      --print( l_api_name || ': ' || '3 |' || l_month || '|' ||  l_year || '|' ||  l_day || '|' || p_months_after );
      l_month := 12 * l_year_inc  - ABS(l_month);
      IF l_month = 13
      THEN
        l_month := 1;
      END IF;
      --print( l_api_name || ': ' || '4 |' || l_month || '|' ||  l_year || '|' ||  l_day || '|' || p_months_after );
    END IF;
    CASE
      -- Considering the cases where 30 is the last day in the month
      WHEN  ( l_month = 4  OR l_month = 6 OR
              l_month = 9  OR l_month = 11 ) AND
            l_day > 30
      THEN
        l_day := 30;
      WHEN l_month = 2
       AND l_day > 28
      THEN
        -- Considering the cases where day > 28 and month is February in a leap/Non Leap Year
        IF  mod(l_year,400 ) = 0 OR
             ( mod(l_year, 100) <> 0 AND mod(l_year,4) = 0 )
        THEN
          -- Leap Year is divisible by 4, but not with 100 except for the years which are divisible by 400
          -- Like 1900 is not leap year, but 2000 is a leap year
          l_day := 29;
        ELSE
          -- Its a non Leap Year
          l_day := 28;
        END IF;
      ELSE
        -- Do Nothing
        NULL;
    END CASE;
    --print( l_api_name || ': ' || '5 |' || l_month || '|' ||  l_year || '|' ||  l_day || '|' || p_months_after );
    -- Return things
    x_date := to_date( l_day || '-' || l_month || '-' || l_year, 'DD-MM-YYYY' );
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_DB_ERROR,
        p_token1       => G_PROG_NAME_TOKEN,
        p_token1_value => l_api_name,
        p_token2       => G_SQLCODE_TOKEN,
        p_token2_value => sqlcode,
        p_token3       => G_SQLERRM_TOKEN,
        p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END add_months_new;

  -- API calculating the Stream element date after
  --  (p_periods_after * p_months_per_period ) months
  --  from p_start_date, also considering the payments are
  --  Advance/Arrears !!

-- Added parameter p_recurrence_date by djanaswa for bug 6007644
-- Added parameter p_arrears_pay_dates_option DJANASWA ER6274342
  PROCEDURE get_sel_date(
    p_start_date         IN  DATE,
    p_advance_or_arrears IN  VARCHAR2,
    p_periods_after      IN  NUMBER,
    p_months_per_period  IN  NUMBER,
    x_date               OUT NOCOPY DATE,
    x_return_status      OUT NOCOPY VARCHAR2,
    p_recurrence_date    IN  DATE,
    p_arrears_pay_dates_option IN VARCHAR2)
  AS
    l_start_date         DATE;
    l_start_day          NUMBER;
    l_temp_day           NUMBER;
    l_temp_date          DATE;
    l_month              NUMBER;
    l_api_name           VARCHAR2(30) := 'get_sel_date';
    l_return_status      VARCHAR2(1);

    -- Added by djanaswa for bug 6007644
    l_recurrence_day     NUMBER;
    l_temp_month         NUMBER;
    l_temp_year          NUMBER;
    --end djanaswa




  BEGIN
    -- Initialize Things ...
    l_start_date := p_start_date;
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_start_date := trunc(p_start_date);
    l_start_day  := to_char( l_start_date, 'DD');
    l_month := to_char(p_start_date, 'MM');

    -- Added by djanaswa for bug 6007644
    l_month := to_char(p_recurrence_date, 'MM');
    l_recurrence_day := to_char(p_recurrence_date, 'DD');
    --end djanaswa

    IF p_advance_or_arrears = 'ARREARS' OR
       p_advance_or_arrears = 'Y'
    THEN
       add_months_new(
          p_start_date     => l_start_date,
          p_months_after   => p_periods_after * p_months_per_period,
          x_date           => l_temp_date,
          x_return_status  => l_return_status);
       IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    --   IF to_char( l_temp_date, 'DD' ) >= l_start_day
    --   THEN
    --     l_temp_date := l_temp_date - 1;
    --   END IF;
    ELSE
      add_months_new(
        p_start_date     => l_start_date,
        p_months_after   => (p_periods_after-1)* p_months_per_period,
        x_date           => l_temp_date,
        x_return_status  => l_return_status);
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;   -- changed by djanaswa for bug 6007644

      -- Note:
      --   The logic below is to address the rule, that if the start date is last day of a month
      --    then the succeeding advance payments should be on the last day of the month..
      --   Please remove the below IF clause, if the above mentioned rule is not applicable.

      -- Added p_recurrence_date in IF clause by djanaswa for bug 6007644

      IF l_month in (1,  3 , 5 , 7, 8, 10, 12) THEN
        IF p_recurrence_date = LAST_DAY( p_recurrence_date )
        THEN
          l_temp_date := LAST_DAY( l_temp_date );
        END IF;
      END IF;

      -- Added by djanaswa for bug 6007644
    IF(l_recurrence_day in(29, 30)) THEN
        l_temp_month := to_char(l_temp_date, 'MM');
        l_temp_year  := to_char(l_temp_date, 'YYYY');
        IF(l_temp_month = 2) THEN
          IF  mod(l_temp_year,400 ) = 0 OR (mod(l_temp_year, 100) <> 0 AND mod(l_temp_year,4) = 0)
          THEN
            -- Leap Year is divisible by 4, but not with 100 except for the years which are divisible by 400
            -- Like 1900 is not leap year, but 2000 is a leap year
            l_temp_day := 29;
          ELSE
            -- Its a non Leap Year
            l_temp_day := 28;
          END IF;
        ELSE
          l_temp_day := l_recurrence_day;
        END IF;
        l_temp_date := to_date(l_temp_day || '-' || l_temp_month || '-' || l_temp_year, 'DD-MM-YYYY');
      END IF;

 -- djanaswa 6274342 start
     IF p_advance_or_arrears = 'ARREARS' OR
         p_advance_or_arrears = 'Y'
      THEN
          IF p_arrears_pay_dates_option = 'FIRST_DAY_OF_NEXT_PERIOD' THEN
                l_temp_date := l_temp_date;
          ELSE
                l_temp_date := l_temp_date - 1;
          END IF;
      END IF;
 -- djanaswa 6274342 end
      --end djanaswa


    -- Return the things
    x_date := l_temp_date;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_DB_ERROR,
        p_token1       => G_PROG_NAME_TOKEN,
        p_token1_value => l_api_name,
        p_token2       => G_SQLCODE_TOKEN,
        p_token2_value => sqlcode,
        p_token3       => G_SQLERRM_TOKEN,
        p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END get_sel_date;
 -- Added by RGOOTY: End  4371472

 ---------------------------------------------------------------------------
  -- PROCEDURE get_mapped_stream
  --
  -- DESC
  -- Repository of hard-coded stream type mapping
  --
  -- USAGE
  -- Driven by mapping type.  Must provide mapping type
  ---------------------------------------------------------------------------
  PROCEDURE get_mapped_stream(p_sty_purpose       IN         VARCHAR2  DEFAULT NULL,
                               p_line_style        IN         VARCHAR2,
                               p_mapping_type      IN         VARCHAR2,
                               p_deal_type         IN         VARCHAR2,
                               p_primary_sty_id    IN         NUMBER DEFAULT NULL,
                               p_fee_type          IN         VARCHAR2 DEFAULT NULL,
                               p_recurr_yn         IN         VARCHAR2 DEFAULT NULL,
                               p_pt_yn             IN         VARCHAR2  DEFAULT 'N',
                               p_khr_id            IN         NUMBER,
                               x_mapped_stream     OUT NOCOPY VARCHAR2,
                               x_return_status     OUT NOCOPY VARCHAR2,
                               p_hdr IN G_HDR%ROWTYPE,
                               p_rollover_pmnts IN G_ROLLOVER_PMNTS%ROWTYPE) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_mapped_stream';
    l_sty_id NUMBER;
    l_primary_sty_id    NUMBER;
    p_get_k_info_csr    OKL_ISG_UTILS_PVT.G_GET_K_INFO_CSR%ROWTYPE;
  BEGIN
    -- Enhancement pending to remove hard coding dependency (TBD by MCHAKRAB, SRAWLING)
    -- Accrual Stream Type will be specified during setup of Payment Stream Type
    IF p_rollover_pmnts.styId IS NULL
    THEN
        OPEN G_ROLLOVER_PMNTS(p_khr_id);
        FETCH G_ROLLOVER_PMNTS INTO r_rollover_pmnts;
        CLOSE G_ROLLOVER_PMNTS;
    ELSE
        r_rollover_pmnts := p_rollover_pmnts;
    END IF;

    OPEN OKL_ISG_UTILS_PVT.G_GET_K_INFO_CSR (p_khr_id);
    FETCH OKL_ISG_UTILS_PVT.G_GET_K_INFO_CSR INTO p_get_k_info_csr;
    CLOSE OKL_ISG_UTILS_PVT.G_GET_K_INFO_CSR;

    l_primary_sty_id := nvl(p_primary_sty_id, r_rollover_pmnts.styId);

   -- print( l_prog_name, 'begin' );
   -- print( l_prog_name, ' mapping type ' || p_mapping_type || ' sty ame ' || p_sty_purpose || ' deal type ' || p_deal_type );
    IF p_mapping_type = 'ACCRUAL' THEN
          IF p_sty_purpose = 'RENT' AND p_deal_type = 'LEASEOP' AND
             (p_line_style = 'FREE_FORM1' OR p_line_style IS NULL) THEN
                --x_mapped_stream  :=  'RENTAL ACCRUAL';
                --  print( l_prog_name, '##1##' );
                OKL_ISG_UTILS_PVT.get_dep_stream_type(
                         p_khr_id                => p_khr_id,
                   					 p_deal_type             => p_deal_type,
                   					 p_primary_sty_id        => l_primary_sty_id,
                         p_dependent_sty_purpose => 'RENT_ACCRUAL',
                         x_return_status         => x_return_status,
                         x_dependent_sty_id      => l_sty_id,
                         x_dependent_sty_name    => x_mapped_stream,
                         p_get_k_info_rec        => p_get_k_info_csr);

          ELSIF p_sty_purpose = 'RENT' AND p_deal_type <> 'LEASEOP' AND
                (p_line_style = 'FREE_FORM1' OR p_line_style IS NULL) THEN
                -- print( l_prog_name, '##2##' );
                x_mapped_stream  :=  NULL;
          ELSIF p_pt_yn = 'Y' THEN
                --  print( l_prog_name, '##3##' );
                --x_mapped_stream := 'PASS THROUGH REVENUE ACCRUAL';
                --Bug 4434343 - Start of Changes
                IF (p_line_style = 'FEE') THEN
                    OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
                                   					 p_deal_type             => p_deal_type,
                                   					 p_primary_sty_id        => l_primary_sty_id,
                                         p_dependent_sty_purpose => 'PASS_THRU_REV_ACCRUAL',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => x_mapped_stream);
                ELSIF (p_line_style = 'SOLD_SERVICE') OR (p_line_style = 'LINK_SERV_ASSET') THEN
                     OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
                                   					 p_deal_type             => p_deal_type,
                                   					 p_primary_sty_id        => l_primary_sty_id,
                                         p_dependent_sty_purpose => 'PASS_THRU_SVC_REV_ACCRUAL',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => x_mapped_stream);
               END IF;
               --Bug 4434343 - End of Changes
          ELSIF ((p_line_style = 'SOLD_SERVICE') OR (p_line_style = 'LINK_SERV_ASSET')) THEN
                --  print( l_prog_name, '##4##' );
                --x_mapped_stream  :=  'SERVICE INCOME';
                OKL_ISG_UTILS_PVT.get_dep_stream_type(
                        p_khr_id                => p_khr_id,
                   					p_deal_type             => p_deal_type,
                   					p_primary_sty_id        => l_primary_sty_id,
                        p_dependent_sty_purpose => 'SERVICE_INCOME',
                        x_return_status         => x_return_status,
                        x_dependent_sty_id      => l_sty_id,
                        x_dependent_sty_name    => x_mapped_stream,
                        p_get_k_info_rec        => p_get_k_info_csr);

          ELSIF (p_line_style IN ('FEE', 'FREE_FORM1') OR p_line_style IS NULL) AND
                (p_sty_purpose <> 'SECURITY_DEPOSIT') THEN

            If ( p_fee_type = 'INCOME' AND p_recurr_yn = OKL_API.G_FALSE ) Then
                --x_mapped_stream := 'AMORTIZED FEE INCOME';
                OKL_ISG_UTILS_PVT.get_dep_stream_type(
                        p_khr_id                => p_khr_id,
                   					p_deal_type             => p_deal_type,
                   					p_primary_sty_id        => l_primary_sty_id,
                        p_dependent_sty_purpose => 'AMORTIZE_FEE_INCOME',
                        x_return_status         => x_return_status,
                        x_dependent_sty_id      => l_sty_id,
                        x_dependent_sty_name    => x_mapped_stream,
                        p_get_k_info_rec        => p_get_k_info_csr);

    	   elsif ( p_fee_type = 'FINANCED' OR p_fee_type = 'ROLLOVER') Then
    	       x_mapped_stream := NULL;
    	   else
                --x_mapped_stream  :=  'FEE INCOME';
                 OKL_ISG_UTILS_PVT.get_dep_stream_type(
                         p_khr_id                => p_khr_id,
                   					 p_deal_type             => p_deal_type,
                   					 p_primary_sty_id        => l_primary_sty_id,
                         p_dependent_sty_purpose => 'ACCRUED_FEE_INCOME',
                         x_return_status         => x_return_status,
                         x_dependent_sty_id      => l_sty_id,
                         x_dependent_sty_name    => x_mapped_stream,
                         p_get_k_info_rec        => p_get_k_info_csr);

    	   end if;
        ELSE
            x_mapped_stream  :=  NULL;
        END IF;

    ELSIF p_mapping_type = 'PRE-TAX INCOME' THEN

      IF (p_deal_type IN ('LOAN', 'LOAN-REVOLVING')) OR
         ( p_fee_type in ('FINANCED', 'ROLLOVER','LINK_FEE_ASSET') ) THEN
            --x_mapped_stream  :=  'PRE-TAX INCOME';
            OKL_ISG_UTILS_PVT.get_dep_stream_type(
                    p_khr_id                => p_khr_id,
               					p_deal_type             => p_deal_type,
               					p_primary_sty_id        => l_primary_sty_id,
                    p_dependent_sty_purpose => 'INTEREST_INCOME',
                    x_return_status         => x_return_status,
                    x_dependent_sty_id      => l_sty_id,
                    x_dependent_sty_name    => x_mapped_stream,
                    p_get_k_info_rec        => p_get_k_info_csr);

      ELSIF (p_deal_type IN ('LEASEDF', 'LEASEST')) THEN
            --x_mapped_stream  :=  'PRE-TAX INCOME';
            OKL_ISG_UTILS_PVT.get_dep_stream_type(
                    p_khr_id                => p_khr_id,
               					p_deal_type             => p_deal_type,
                				p_primary_sty_id        => l_primary_sty_id,
                    p_dependent_sty_purpose => 'LEASE_INCOME',
                    x_return_status         => x_return_status,
                    x_dependent_sty_id      => l_sty_id,
                    x_dependent_sty_name    => x_mapped_stream,
                    p_get_k_info_rec        => p_get_k_info_csr);

      ELSE
        x_mapped_stream  :=  NULL;
      END IF;

    ELSIF p_mapping_type = 'PAYMENT' THEN
      IF p_sty_purpose = 'RENT' AND p_deal_type IN ('LOAN', 'LOAN-REVOLVING') THEN
        x_mapped_stream  := 'LOAN PAYMENT';
      ELSE
        x_mapped_stream  :=  p_sty_purpose;
      END IF;

    ELSIF p_mapping_type = 'CAPITAL RECOVERY' THEN
      IF p_deal_type IN ('LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING') THEN
        x_mapped_stream  :=  'PRINCIPAL PAYMENT';
      ELSE
        x_mapped_stream  :=  NULL;
      END IF;

    ELSIF p_mapping_type = 'INTEREST PAYMENT' THEN
      IF p_deal_type IN ('LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING') THEN
        x_mapped_stream  :=  'INTEREST PAYMENT';
      ELSE
        x_mapped_stream  :=  NULL;
      END IF;

    ELSIF p_mapping_type = 'CLOSE BOOK' THEN
      IF p_deal_type IN ('LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING') THEN
        x_mapped_stream  :=  'PRINCIPAL BALANCE';
      ELSE
        x_mapped_stream  :=  NULL;
      END IF;

    ELSIF p_mapping_type = 'DISBURSEMENT' THEN
        IF p_hdr.pid IS NULL
        THEN
          OPEN G_HDR(p_khr_id);
          FETCH G_HDR INTO r_hdr;
          CLOSE G_HDR;
        ELSE
          r_hdr := p_hdr;
        END IF;

      If ( p_sty_purpose = 'RENT' ) THen
            --x_mapped_stream  :=  'INVESTOR RENT DISBURSEMENT BASIS';
            OKL_ISG_UTILS_PVT.get_primary_stream_type(
                    p_khr_id              => p_khr_id,
               					p_pdt_id              => r_hdr.pid,
                    p_primary_sty_purpose => 'INVESTOR_RENT_DISB_BASIS',
                    x_return_status       => x_return_status,
                    x_primary_sty_id      => l_sty_id,
                    x_primary_sty_name    => x_mapped_stream);
      ElsIf ( p_sty_purpose = 'RESIDUAL' ) Then
            --x_mapped_stream  :=  'INVESTOR RESIDUAL DISBURSEMENT BASIS';
            OKL_ISG_UTILS_PVT.get_primary_stream_type(
                    p_khr_id              => p_khr_id,
               					p_pdt_id              => r_hdr.pid,
                    p_primary_sty_purpose => 'INVESTOR_RESIDUAL_DISB_BASIS',
                    x_return_status       => x_return_status,
                    x_primary_sty_id      => l_sty_id,
                    x_primary_sty_name    => x_mapped_stream);
      End If;

    ELSIF p_mapping_type = 'PV_DISBURSEMENT' THEN
        IF p_hdr.pid IS NULL
        THEN
          OPEN G_HDR(p_khr_id);
          FETCH G_HDR INTO r_hdr;
          CLOSE G_HDR;
        ELSE
          r_hdr := p_hdr;
        END IF;

      If ( p_sty_purpose = 'RENT' ) THen
            --x_mapped_stream  :=  'PRESENT VALUE SECURITIZED RENT';
            OKL_ISG_UTILS_PVT.get_primary_stream_type(
                    p_khr_id              => p_khr_id,
               					p_pdt_id              => r_hdr.pid,
                    p_primary_sty_purpose => 'PV_RENT_SECURITIZED',
                    x_return_status       => x_return_status,
                    x_primary_sty_id      => l_sty_id,
                    x_primary_sty_name    => x_mapped_stream);
      ElsIf ( p_sty_purpose = 'RESIDUAL' ) Then
            --x_mapped_stream  :=  'PRESENT VALUE SECURITIZED RESIDUAL';
            OKL_ISG_UTILS_PVT.get_primary_stream_type(
                    p_khr_id              => p_khr_id,
               					p_pdt_id              => r_hdr.pid,
                    p_primary_sty_purpose => 'PV_RV_SECURITIZED',
                    x_return_status       => x_return_status,
                    x_primary_sty_id      => l_sty_id,
                    x_primary_sty_name    => x_mapped_stream);
      End If;

    ELSE
        x_mapped_stream  :=  NULL;
    END IF;
    x_return_status  :=  G_RET_STS_SUCCESS;
   -- print( l_prog_name, 'end' );
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

  END get_mapped_stream;

  Procedure print( p_proc_name     IN VARCHAR2,
                   p_message       IN VARCHAR2,
                   x_return_status IN VARCHAR2) IS
  Begin
     IF L_DEBUG_ENABLED = 'Y' then
       fnd_file.put_line (fnd_file.log, p_proc_name || ':' || p_message);
     END IF;
     --dbms_output.put_line( p_proc_name||':'||p_message||':'||x_return_status );
  End;

  Procedure print( p_proc_name     IN VARCHAR2,
                   p_message       IN VARCHAR2) IS
  Begin
     -- print(p_proc_name, p_message, 'S' );
     IF L_DEBUG_ENABLED = 'Y' then
       fnd_file.put_line (fnd_file.log, p_proc_name || ':' || p_message);
     END IF;
  End;

  Procedure generate_stub_element(p_khr_id   IN NUMBER,
                                  p_deal_type     IN VARCHAR2,
                                  p_api_version   IN  NUMBER,
                                  p_init_msg_list IN  VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
				  x_se_id         OUT NOCOPY NUMBER) Is

    l_prog_name     CONSTANT VARCHAR2(100) := G_PKG_NAME||'.'||'generate_stub_element';
    p_selv_tbl      OKL_STREAMS_PUB.selv_tbl_type;
    x_selv_tbl      OKL_STREAMS_PUB.selv_tbl_type;
    p_stmv_rec      OKL_STREAMS_PUB.stmv_rec_type;
    x_stmv_rec      OKL_STREAMS_PUB.stmv_rec_type;
    l_sty_id        NUMBER;

--prasjain:start for bug 5474827
/*
    Cursor c_sty IS
        SELECT sel.id
        FROM  okl_streams stm,
              okl_strm_elements sel
        where stm.khr_id = p_khr_id
          and stm.say_code     =  'HIST'
          and stm.SGN_CODE     =  'MANL'
          and stm.active_yn    =  'N'
          and stm.purpose_code =  'STUBS'
          and stm.comments     =  'STUB STREAMS'
          and sel.stm_id = stm.id;
*/
--prasjain:End


    error           VARCHAR2(256);
    l_stream_name   VARCHAR2(256);

  Begin
    --print( l_prog_name, ' deal type ' || p_deal_type );
    -- Utility API to get the Stream Type Id of the RENT Stream Type.
    OKL_ISG_UTILS_PVT.get_primary_stream_type(
        p_khr_id              => p_khr_id,
        p_deal_type           => p_deal_type,
        p_primary_sty_purpose => 'RENT',
        x_return_status       => x_return_status,
        x_primary_sty_id      => l_sty_id,
        x_primary_sty_name    => l_stream_name);
--     print( l_prog_name, ' stream name ' || l_stream_name );
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Creates a new Stream Header record populating the input values passed
    -- and generates a transaction number for the header.
    get_stream_header(
        p_khr_id         =>   p_khr_id,
        p_kle_id         =>   NULL,
        p_sty_id         =>   l_sty_id,
        p_purpose_code   =>   'STUBS',
        x_stmv_rec       =>   p_stmv_rec,
        x_return_status  =>   x_return_status);
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Updating the Stream Header Details as per the need
    p_stmv_rec.date_history := sysdate  ;
    p_stmv_rec.say_code     :=  'HIST' ;
    p_stmv_rec.SGN_CODE     :=  'MANL';
    p_stmv_rec.active_yn    :=  'N';
    p_stmv_rec.purpose_code :=  'STUBS';
    p_stmv_rec.comments     :=  'STUB STREAMS';
    p_stmv_rec.date_history := SYSDATE;
    -- Updating the Stream Element Details as per the need
    p_selv_tbl(0).stream_element_date := sysdate;
    p_selv_tbl(0).amount := 0.0;
    p_selv_tbl(0).se_line_number := 1 ;
    p_selv_tbl(0).comments := 'STUB STREAM ELEMENT' ;
    p_selv_tbl(0).parent_index := 1 ;

    -- Create the Stream Header along with one stream element.
    --print( l_prog_name, ' b4 create_stub ' || to_char(l_sty_id) );
    okl_streams_pub.create_streams(
            p_api_version,
            p_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data,
            p_stmv_rec,
            p_selv_tbl,
            x_stmv_rec,
            x_selv_tbl);
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --print( l_prog_name, ' after create_stub ', x_return_status );
    --print( l_prog_name, ' # of stubf created ' || to_chaR( x_selv_tbl.COUNT ) );
    --x_se_id := x_selv_tbl(x_selv_tbl.FIRST).id;

--prasjain:start for bug 5474827
--Populating the stream element id from parameter x_selv_tbl instead of getting from cursor c_sty
    x_se_id := x_selv_tbl(0).id;

    --Returns the id of the new Stream Created ?????
/*
    OPEN    c_sty;
    FETCH   c_sty INTO x_se_id;
    CLOSE   c_sty;
*/
--prasjain:End
    --print( l_prog_name, ' stub Id  ' || to_chaR( x_se_id ) );
  end generate_stub_element;
  ---------------------------------------------------------------------------
  -- PROCEDURE generate_quote_streams
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  PROCEDURE generate_quote_streams(
                             p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2,
                             p_khr_id        IN  NUMBER,
                             p_kle_id        IN  NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2) IS

    lx_return_status              VARCHAR2(1);


    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'generate_quote_streams';

  --Added sll.rule_information2 in order by clause by djanaswa for bug 6007644
    Cursor c_rollover_fee_pmnts ( feeId NUMBER ) IS
    SELECT DISTINCT
           cle.id kleId,
	   kle.amount fee_amount,
           cle.start_date fee_start_date,
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
    AND kle.id = feeId
    AND trunc(cle.START_DATE) = trunc(chr_so.START_DATE)
    AND cle.lse_id = lse.id
    AND ((lse.lty_code = 'FEE' AND kle.fee_type = 'ROLLOVER') OR lse.lty_code = 'LINK_FEE_ASSET')
    AND kle.fee_type <> 'CAPITALIZED'
    AND cle.id = rgp.cle_id
    AND rgp.rgd_code = 'LALEVL'
    AND rgp.id = slh.rgp_id
    AND slh.rule_information_category = 'LASLH'
    AND slh.object1_id1 = TO_CHAR(stm.id)
    AND TO_CHAR(slh.id) = sll.object2_id1
    AND sll.rule_information_category = 'LASLL'
    order by cle.id,stm.id, FND_DATE.canonical_to_date(sll.rule_information2);

    r_rollover_fee_pmnts c_rollover_fee_pmnts%ROWTYPE;

    Cursor c_rollover_fee IS
    SELECT DISTINCT
           to_char(cle.id) kleId,
	   kle.amount fee_amount,
           cle.start_date fee_start_date
    FROM okc_k_headers_b chr_so,
         okc_k_lines_b cle,
         okl_k_lines kle,
         okc_line_styles_b lse
    WHERE chr_so.id = p_khr_id
    and cle.sts_code in( 'COMPLETE', 'INCOMPLETE')--'ENTERED'
    AND cle.dnz_chr_id = chr_so.id
    AND cle.id = kle.id
    AND trunc(cle.START_DATE) = trunc(chr_so.START_DATE)
    AND cle.lse_id = lse.id
    AND ((lse.lty_code = 'FEE' AND kle.fee_type = 'ROLLOVER') OR lse.lty_code = 'LINK_FEE_ASSET')
    AND kle.fee_type <> 'CAPITALIZED';

    r_rollover_fee c_rollover_fee%ROWTYPE;

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_tmp_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_pt_tbl                 okl_streams_pub.selv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    l_pt_rec                 okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

    l_capital_cost           NUMBER;

    i                        BINARY_INTEGER := 0;
    j                        BINARY_INTEGER := 0;

    l_cle_id                 NUMBER;
    l_sty_id                 NUMBER;

    l_deal_type varchar2(30);

    CURSOR c_hdr IS
      SELECT chr.template_yn,
             chr.currency_code,
             chr.start_date,
             khr.deal_type,
             khr.term_duration,
             NVL(khr.generate_accrual_yn, 'Y')
      FROM   okc_k_headers_b chr,
             okl_k_headers khr
      WHERE  khr.id = p_khr_id
        AND  chr.id = khr.id;

    l_hdr c_hdr%ROWTYPE;

    l_se_id NUMBER;
    l_fee_start_date DATE;

    l_principal_tbl          okl_streams_pub.selv_tbl_type;
    l_interest_tbl           okl_streams_pub.selv_tbl_type;
    l_prin_bal_tbl           okl_streams_pub.selv_tbl_type;
    l_termination_tbl        okl_streams_pub.selv_tbl_type;
    l_pre_tax_inc_tbl        okl_streams_pub.selv_tbl_type;

    l_interim_interest       NUMBER;
    l_interim_days           NUMBER;
    l_interim_dpp            NUMBER;
    l_asset_iir              NUMBER;
    l_asset_guess_iir        NUMBER;
    l_bkg_yield_guess        NUMBER;
    l_asset_booking_yield    NUMBER;

    l_interim_tbl            OKL_PRICING_PVT.interim_interest_tbl_type;
    l_sub_interim_tbl            OKL_PRICING_PVT.interim_interest_tbl_type;

    l_principal_id           NUMBER;
    l_interest_id            NUMBER;
    l_prin_bal_id            NUMBER;
    l_termination_id         NUMBER;
    l_pre_tax_inc_id         NUMBER;

    l_sty_name VARCHAR2(256);
    l_has_pmnts VARCHAR2(1);

  --Added by djanaswa for bug 6007644
    l_recurrence_date    DATE := NULL;
    l_old_sty_id         NUMBER;
    --end djanaswa



  BEGIN

     OPEN c_hdr;
     FETCH c_hdr into l_hdr;
     CLOSE c_hdr;

     l_deal_type := l_hdr.deal_type;

    generate_stub_element( p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
			   p_deal_type     => l_deal_type,
                           p_khr_id        => p_khr_id,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_se_id         => l_se_id );

    print( l_prog_name, 'stub', x_return_status );
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     For r_rollover_fee in c_rollover_fee
     LOOP

    print( l_prog_name, ' found a roll fee ', to_char(r_rollover_fee.kleId) );

        update okl_streams
        set say_code = 'HIST'
        ,date_history = SYSDATE
        where khr_id = p_khr_id
           and kle_id = r_rollover_fee.kleId;

        update okl_streams
        set active_yn = 'N'
        where khr_id = p_khr_id
           and kle_id = r_rollover_fee.kleId;


     r_rollover_fee_pmnts := NULL;
     l_has_pmnts := 'N';

     For r_rollover_fee_pmnts in c_rollover_fee_pmnts ( r_rollover_fee.kleId )
     LOOP
    print( l_prog_name, ' foudn a roll fee pmnts ', to_char(r_rollover_fee_pmnts.kleId) );

        l_has_pmnts := 'Y';

        l_cle_id := r_rollover_fee_pmnts.kleId;
       	l_sty_id := r_rollover_fee_pmnts.styId;
        l_capital_cost := r_rollover_fee_pmnts.fee_amount;

        l_fee_start_date := r_rollover_fee_pmnts.fee_start_date;

        --Added by djanaswa for bug 6007644
        IF((r_rollover_fee_pmnts.periods IS NULL) AND (r_rollover_fee_pmnts.stub_days IS NOT NULL)) THEN
          --Set the recurrence date to null for stub payment
          l_recurrence_date := NULL;
        ELSIF(l_recurrence_date IS NULL OR l_old_sty_id <> r_rollover_fee_pmnts.styId) THEN
          --Set the recurrence date as periodic payment level start date
          l_recurrence_date := r_rollover_fee_pmnts.start_date;
        END IF;
        l_old_sty_id := r_rollover_fee_pmnts.styId;
        --end djanaswa

        --Added parameter p_recurrence_date by djanaswa for bug 6007644
        get_stream_elements( p_start_date          =>   r_rollover_fee_pmnts.start_date,
                             p_periods             =>   r_rollover_fee_pmnts.periods,
                             p_frequency           =>   r_rollover_fee_pmnts.frequency,
                             p_structure           =>   r_rollover_fee_pmnts.structure,
                             p_advance_or_arrears  =>   r_rollover_fee_pmnts.advance_arrears,
                             p_amount              =>   r_rollover_fee_pmnts.amount,
                     			     p_stub_days           =>   r_rollover_fee_pmnts.stub_days,
                     			     p_stub_amount         =>   r_rollover_fee_pmnts.stub_amount,
                             p_currency_code       =>   l_hdr.currency_code,
                             p_khr_id              =>   p_khr_id,
                             p_kle_id              =>   r_rollover_fee_pmnts.kleId,
                             p_purpose_code        =>   NULL,
                             x_selv_tbl            =>   l_tmp_selv_tbl,
                             x_pt_tbl              =>   l_pt_tbl,
                             x_return_status       =>   lx_return_status,
                             x_msg_count           =>   x_msg_count,
                             x_msg_data            =>   x_msg_data,
                             p_recurrence_date     =>   l_recurrence_date);
        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        j := l_selv_tbl.COUNT;
        For i in l_tmp_selv_tbl.FIRST..l_tmp_selv_tbl.LAST
	LOOP

	    l_selv_tbl(i+j) := l_tmp_selv_tbl(i);
            If (  r_rollover_fee_pmnts.stub_days IS NOT NULL ) AND (  r_rollover_fee_pmnts.periods IS NULL ) Then
	        l_selv_tbl(i+j).sel_id := l_se_id;
	    End If;

	END LOOP;
	l_tmp_selv_tbl.DELETE;

     END LOOP;

     If ( l_has_pmnts = 'Y') Then

        get_stream_header(p_khr_id         =>   p_khr_id,
                          p_kle_id         =>   l_cle_id,
                          p_sty_id         =>   l_sty_id,
                          p_purpose_code   =>   NULL,
                          x_stmv_rec       =>   l_stmv_rec,
                          x_return_status  =>   lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


        lx_return_status := Okl_Streams_Util.round_streams_amount(
                            p_api_version   => g_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
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

        l_stmv_rec.say_code := 'CURR';
        l_stmv_rec.active_yn := 'Y';
        l_stmv_rec.date_current := SYSDATE;

        okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                       p_init_msg_list   =>   G_FALSE,
                                       x_return_status   =>   lx_return_status,
                                       x_msg_count       =>   x_msg_count,
                                       x_msg_data        =>   x_msg_data,
                                       p_stmv_rec        =>   l_stmv_rec,
                                       p_selv_tbl        =>   l_selv_tbl,
                                       x_stmv_rec        =>   lx_stmv_rec,
                                       x_selv_tbl        =>   lx_selv_tbl);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

print( l_prog_name, 'amortize with capital cost ' || to_char(l_capital_cost) );

             OKL_PRICING_PVT.get_quote_amortization(
	                        p_khr_id           => p_khr_id,
                                p_kle_id           => l_cle_id,
                                p_investment       => l_capital_cost,
                                p_residual_value   => 0,
                                p_start_date       => l_hdr.start_date,
                                p_asset_start_date => l_fee_start_date,
                                p_term_duration    => l_hdr.term_duration,
                                x_principal_tbl    => l_principal_tbl,
                                x_interest_tbl     => l_interest_tbl,
                                x_prin_bal_tbl     => l_prin_bal_tbl,
                                x_termination_tbl  => l_termination_tbl,
                                x_pre_tax_inc_tbl  => l_pre_tax_inc_tbl,
                                x_interim_interest => l_interim_interest,
                                x_interim_days     => l_interim_days,
                                x_interim_dpp      => l_interim_dpp,
                                x_iir              => l_asset_iir,
                                x_booking_yield    => l_asset_booking_yield,
                                x_return_status    => lx_return_status);

print( l_prog_name, 'amortize ',  lx_return_status );

             IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;


          OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
                                   					 p_deal_type             => l_deal_type,
                                         p_dependent_sty_purpose => 'INTEREST_INCOME',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_pre_tax_inc_id,
                                         x_dependent_sty_name    => l_sty_name);

          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                    p_khr_id  		    => p_khr_id,
	            p_deal_type             => l_deal_type,
                    p_dependent_sty_purpose => 'INTEREST_PAYMENT',
                    x_return_status         => lx_return_status,
                    x_dependent_sty_id      => l_interest_id,
                    x_dependent_sty_name    => l_sty_name);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                    p_khr_id  		    => p_khr_id,
	            p_deal_type             => l_deal_type,
                    p_dependent_sty_purpose => 'PRINCIPAL_PAYMENT',
                    x_return_status         => lx_return_status,
                    x_dependent_sty_id      => l_principal_id,
                    x_dependent_sty_name    => l_sty_name);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                    p_khr_id  		    => p_khr_id,
                    p_deal_type             => l_deal_type,
                    p_dependent_sty_purpose => 'PRINCIPAL_BALANCE',
                    x_return_status         => lx_return_status,
                    x_dependent_sty_id      => l_prin_bal_id,
                    x_dependent_sty_name    => l_sty_name);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                    p_khr_id  		    => p_khr_id,
	            p_deal_type             => l_deal_type,
                    p_dependent_sty_purpose => 'TERMINATION_VALUE',
                    x_return_status         => lx_return_status,
                    x_dependent_sty_id      => l_termination_id,
                    x_dependent_sty_name    => l_sty_name);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

          IF l_principal_tbl.COUNT > 0 AND (l_principal_id IS NOT NULL) Then

            get_stream_header(p_khr_id         =>   p_khr_id,
                              p_kle_id         =>   l_cle_id,
                              p_sty_id         =>   l_principal_id,
                              p_purpose_code   =>   NULL,
                              x_stmv_rec       =>   l_stmv_rec,
                              x_return_status  =>   lx_return_status);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;


            l_stmv_rec.say_code := 'CURR';
            l_stmv_rec.active_yn := 'Y';
            l_stmv_rec.date_current := SYSDATE;

            lx_return_status := Okl_Streams_Util.round_streams_amount(
                                p_api_version   => g_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => p_khr_id,
                                p_selv_tbl      => l_principal_tbl,
                                x_selv_tbl      => lx_selv_tbl);

            IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_principal_tbl.DELETE;
            l_principal_tbl := lx_selv_tbl;

            okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                           p_init_msg_list   =>   G_FALSE,
                                           x_return_status   =>   lx_return_status,
                                           x_msg_count       =>   x_msg_count,
                                           x_msg_data        =>   x_msg_data,
                                           p_stmv_rec        =>   l_stmv_rec,
                                           p_selv_tbl        =>   l_principal_tbl,
                                           x_stmv_rec        =>   lx_stmv_rec,
                                           x_selv_tbl        =>   lx_selv_tbl);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

          END IF;

          IF l_interest_tbl.COUNT > 0 AND ( l_interest_id IS NOT NULL) Then

            get_stream_header(p_khr_id         =>   p_khr_id,
                              p_kle_id         =>   l_cle_id,
                              p_sty_id         =>   l_interest_id,
                              p_purpose_code   =>   NULL,
                              x_stmv_rec       =>   l_stmv_rec,
                              x_return_status  =>   lx_return_status);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;


            l_stmv_rec.say_code := 'CURR';
            l_stmv_rec.active_yn := 'Y';
            l_stmv_rec.date_current := SYSDATE;

            lx_return_status := Okl_Streams_Util.round_streams_amount(
                                p_api_version   => g_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => p_khr_id,
                                p_selv_tbl      => l_interest_tbl,
                                x_selv_tbl      => lx_selv_tbl);

            IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_interest_tbl.DELETE;
            l_interest_tbl := lx_selv_tbl;

            okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                           p_init_msg_list   =>   G_FALSE,
                                           x_return_status   =>   lx_return_status,
                                           x_msg_count       =>   x_msg_count,
                                           x_msg_data        =>   x_msg_data,
                                           p_stmv_rec        =>   l_stmv_rec,
                                           p_selv_tbl        =>   l_interest_tbl,
                                           x_stmv_rec        =>   lx_stmv_rec,
                                           x_selv_tbl        =>   lx_selv_tbl);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

          END IF;

          IF l_prin_bal_tbl.COUNT > 0 AND (l_prin_bal_id IS NOT NULL) Then

            get_stream_header(p_khr_id         =>   p_khr_id,
                              p_kle_id         =>   l_cle_id,
                              p_sty_id         =>   l_prin_bal_id,
                              p_purpose_code   =>   NULL,
                              x_stmv_rec       =>   l_stmv_rec,
                              x_return_status  =>   lx_return_status);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;


            l_stmv_rec.say_code := 'CURR';
            l_stmv_rec.active_yn := 'Y';
            l_stmv_rec.date_current := SYSDATE;

            lx_return_status := Okl_Streams_Util.round_streams_amount(
                                p_api_version   => g_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => p_khr_id,
                                p_selv_tbl      => l_prin_bal_tbl,
                                x_selv_tbl      => lx_selv_tbl);

            IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_prin_bal_tbl.DELETE;
            l_prin_bal_tbl := lx_selv_tbl;

            okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                           p_init_msg_list   =>   G_FALSE,
                                           x_return_status   =>   lx_return_status,
                                           x_msg_count       =>   x_msg_count,
                                           x_msg_data        =>   x_msg_data,
                                           p_stmv_rec        =>   l_stmv_rec,
                                           p_selv_tbl        =>   l_prin_bal_tbl,
                                           x_stmv_rec        =>   lx_stmv_rec,
                                           x_selv_tbl        =>   lx_selv_tbl);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

          END IF;

          IF l_termination_tbl.COUNT > 0 AND (l_termination_id IS NOT NULL) THEN

            get_stream_header(p_khr_id         =>   p_khr_id,
                              p_kle_id         =>   l_cle_id,
                              p_sty_id         =>   l_termination_id,
                              p_purpose_code   =>   NULL,
                              x_stmv_rec       =>   l_stmv_rec,
                              x_return_status  =>   lx_return_status);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;


            l_stmv_rec.say_code := 'CURR';
            l_stmv_rec.active_yn := 'Y';
            l_stmv_rec.date_current := SYSDATE;

            lx_return_status := Okl_Streams_Util.round_streams_amount(
                                p_api_version   => g_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => p_khr_id,
                                p_selv_tbl      => l_termination_tbl,
                                x_selv_tbl      => lx_selv_tbl);

            IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_termination_tbl.DELETE;
            l_termination_tbl := lx_selv_tbl;

            okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                           p_init_msg_list   =>   G_FALSE,
                                           x_return_status   =>   lx_return_status,
                                           x_msg_count       =>   x_msg_count,
                                           x_msg_data        =>   x_msg_data,
                                           p_stmv_rec        =>   l_stmv_rec,
                                           p_selv_tbl        =>   l_termination_tbl,
                                           x_stmv_rec        =>   lx_stmv_rec,
                                           x_selv_tbl        =>   lx_selv_tbl);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

          END IF;

          IF l_pre_tax_inc_tbl.COUNT > 0 AND l_pre_tax_inc_id IS NOT NULL THEN

            get_stream_header(p_khr_id         =>   p_khr_id,
                              p_kle_id         =>   l_cle_id,
                              p_sty_id         =>   l_pre_tax_inc_id,
                              p_purpose_code   =>   NULL,
                              x_stmv_rec       =>   l_stmv_rec,
                              x_return_status  =>   lx_return_status);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_stmv_rec.say_code := 'CURR';
            l_stmv_rec.active_yn := 'Y';
            l_stmv_rec.date_current := SYSDATE;


            lx_return_status := Okl_Streams_Util.round_streams_amount(
                                p_api_version   => g_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => p_khr_id,
                                p_selv_tbl      => l_pre_tax_inc_tbl,
                                x_selv_tbl      => lx_selv_tbl);

            IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_pre_tax_inc_tbl.DELETE;
            l_pre_tax_inc_tbl := lx_selv_tbl;

            okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                           p_init_msg_list   =>   G_FALSE,
                                           x_return_status   =>   lx_return_status,
                                           x_msg_count       =>   x_msg_count,
                                           x_msg_data        =>   x_msg_data,
                                           p_stmv_rec        =>   l_stmv_rec,
                                           p_selv_tbl        =>   l_pre_tax_inc_tbl,
                                           x_stmv_rec        =>   lx_stmv_rec,
                                           x_selv_tbl        =>   lx_selv_tbl);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

          END IF;

          -- Clear out data structures

          l_principal_tbl.delete;
          l_interest_tbl.delete;
          l_prin_bal_tbl.delete;
          l_termination_tbl.delete;
          l_pre_tax_inc_tbl.delete;

       End If;

     END LOOP;

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

  END generate_quote_streams;

  PROCEDURE get_present_value(     p_api_version            IN NUMBER,
                                   p_init_msg_list          IN VARCHAR2,
				   p_amount_date            IN DATE,
				   p_amount                 IN NUMBER,
				   p_frequency              IN VARCHAR2 DEFAULT 'M',
				   p_rate                   IN NUMBER,
                                   p_pv_date                IN DATE,
				   p_day_convention_month    IN VARCHAR2 DEFAULT '30',
				   p_day_convention_year    IN VARCHAR2 DEFAULT '360',
				   x_pv_amount              OUT NOCOPY NUMBER,
                                   x_return_status          OUT NOCOPY VARCHAR2,
                                   x_msg_count              OUT NOCOPY NUMBER,
                                   x_msg_data               OUT NOCOPY VARCHAR2) IS

    l_days NUMBER;
    l_periods NUMBER;
    l_cf_dpp NUMBER;
    l_cf_ppy NUMBER;

    l_prog_name CONSTANT VARCHAR2(61) := 'get_present_value';

  Begin
     --print(l_prog_name, 'begin' );
    l_days := OKL_PRICING_UTILS_PVT.get_day_count (p_start_date => p_pv_date,
                                 p_days_in_month => p_day_convention_month,
                                 p_days_in_year => p_day_convention_year,
                                 p_end_date   => p_amount_date,
                                 p_arrears    => 'N',
                                 x_return_status => x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


        IF p_frequency = 'M' THEN
          l_cf_dpp  :=  30;
          l_cf_ppy  :=  12;
        ELSIF p_frequency = 'Q' THEN
       	  l_cf_dpp := 90;
          l_cf_ppy  :=  4;
        ELSIF p_frequency = 'S' THEN
       	  l_cf_dpp := 180;
          l_cf_ppy  :=  2;
        ELSIF p_frequency = 'A' THEN
       	  l_cf_dpp := 360;
          l_cf_ppy  :=  1;
        ELSE
          l_cf_dpp  :=  30;
          l_cf_ppy  :=  12;
        END IF;

        l_periods         := l_days/l_cf_dpp;
        x_pv_amount :=  p_amount / POWER( 1 + (p_rate/(l_cf_ppy*100)), l_periods );

        --print(l_prog_name, 'end' );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
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

  End get_present_value;

  PROCEDURE get_present_value(
               p_api_version            IN NUMBER,
               p_init_msg_list          IN VARCHAR2,
               p_cash_flow_tbl          IN cash_flow_tbl,
               p_rate                   IN NUMBER,
               p_pv_date                IN DATE,
               p_day_convention_month    IN VARCHAR2 DEFAULT '30',
               p_day_convention_year    IN VARCHAR2 DEFAULT '360',
         			   x_pv_amount              OUT NOCOPY NUMBER,
               x_return_status          OUT NOCOPY VARCHAR2,
               x_msg_count              OUT NOCOPY NUMBER,
               x_msg_data               OUT NOCOPY VARCHAR2) IS

    l_prog_name CONSTANT VARCHAR2(61) := 'get_present_value';
    i BINARY_INTEGER;

    l_pv_amount NUMBER := 0;

  BEGIN
   --print(l_prog_name, 'begin' );
   x_pv_amount := 0;
   FOR i in p_cash_flow_tbl.FIRST..p_cash_flow_tbl.LAST
   LOOP
      get_present_value(
         p_api_version   => p_api_version,
         p_init_msg_list => p_init_msg_list,
         p_amount_date   => p_cash_flow_tbl(i).cf_date,
         p_amount        => p_cash_flow_tbl(i).cf_amount,
         p_frequency     => nvl(p_cash_flow_tbl(i).cf_frequency, 'M'),
         p_rate          => p_rate,
         p_pv_date       => p_pv_date,
  				   p_day_convention_month => p_day_convention_month,
         p_day_convention_year => p_day_convention_year,
   			   x_pv_amount     => l_pv_amount,
         x_return_status => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data      => x_msg_data);
        x_pv_amount := x_pv_amount + l_pv_amount;
    	END LOOP;
     --print(l_prog_name, 'end' );

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
  END get_present_value;

  PROCEDURE get_amortized_accruals ( p_khr_id         IN NUMBER,
                                     p_currency_code  IN  VARCHAR2,
                                     p_start_date     IN  DATE,
                            				     p_end_date       IN  DATE,
                                     p_deal_type      IN  VARCHAR2,
                            				     p_amount         IN  NUMBER,
                                     x_selv_tbl       OUT NOCOPY okl_sel_pvt.selv_tbl_type,
                                     x_return_status  OUT NOCOPY VARCHAR2) IS

    l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_amortized_accruals';

    CURSOR c_k_income (p_sty_name VARCHAR2) IS
      SELECT sel.amount income_amount,
             sel.stream_element_date income_date
      FROM   okl_strm_elements sel,
             okl_streams stm,
             okl_strm_type_b sty,
             okl_strm_type_tl styt
      WHERE  stm.khr_id = p_khr_id
        AND  stm.say_code = 'WORK'
        AND  stm.id = sel.stm_id
        AND  stm.sty_id = sty.id
        AND  sty.version = '1.0'
        AND  sty.id = styt.id
        AND  styt.language = 'US'
        AND  styt.name = p_sty_name
	AND  sel.stream_element_date >= p_start_date
	AND  sel.stream_element_date <= LAST_DAY(p_end_date) --bug# 3379436
      ORDER BY sel.stream_element_date;

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

    l_amortized_exp_id       NUMBER;
    l_sty_name               VARCHAR2(150);
    l_sty_id                 NUMBER;
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
  BEGIN
    print( l_prog_name, 'begin' );

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

          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
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

          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

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

          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

    END IF;

    print( l_prog_name, ' income stream ' || l_sty_name );

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


    print( l_prog_name, ' l_total_rent_income ' || to_char( l_total_rent_income) );
    print( l_prog_name, ' amount 2 b amort ' || to_char( p_amount) );
      IF NVL(p_amount, 0) > 0 THEN


      FOR i IN 1..inc_strms_tbl.count
      LOOP


        l_selv_tbl(i).stream_element_date := inc_strms_tbl(i).ele_date;
        l_selv_tbl(i).se_line_number      := i;

        --bug 6751635 veramach start
        IF(inc_strms_tbl(i).amount = 0 OR l_total_rent_income = 0) THEN
          l_selv_tbl(i).amount := 0;
        ELSE
          l_selv_tbl(i).amount :=
               (inc_strms_tbl(i).amount/l_total_rent_income)*p_amount;
        END IF;
        --bug 6751635 veramach end

      END LOOP;

      x_selv_tbl := l_selv_tbl;

      i := 0;

      END IF;

    x_return_status := G_RET_STS_SUCCESS;
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

  END get_amortized_accruals;

  Function Is_Var_Rate_Contract (p_chr_id in number) Return Varchar2 is
  Cursor get_rul_csr(p_chr_id in Number, p_rule_code in varchar2, p_rgd_code in varchar2) is
  Select rul.*
  from   okc_rules_b rul,
         okc_rule_groups_b rgp
  where  rul.rgp_id  = rgp.id
  and    rul.rule_information_category = p_rule_code
  and    rul.dnz_chr_id  = rgp.dnz_chr_id
  and    rgp.chr_id      = p_chr_id
  and    rgp.rgd_code    = p_rgd_code
  and    rgp.dnz_chr_id  = p_chr_id;

  l_rul_rec             get_rul_csr%ROWTYPE;
  l_var_int             varchar2(1) default 'N';
  l_is_k_var_rate       varchar2(1) default 'N';

  begin

    print( 'is var rate', 'begin');
    l_is_k_var_rate := 'N';
    l_var_int := 'N';
    Open get_rul_csr(p_chr_id,'LAINTP','LAIIND');
    Fetch get_rul_csr into l_rul_rec;
    If get_rul_csr%NOTFOUND Then
        Null;
    Elsif nvl(l_rul_rec.rule_information1,'N') = 'Y' Then
        l_var_int := 'Y';
    End If;
    Close get_rul_csr;

    If l_var_int = 'Y' Then
        Open get_rul_csr(p_chr_id,'LAICLC','LAIIND');
        Fetch get_rul_csr into l_rul_rec;
        If get_rul_csr%NOTFOUND Then
            Null;
        Elsif nvl(l_rul_rec.rule_information5,'NONE') = 'FORMULA' Then
            l_is_k_var_rate := 'Y';
        End If;
        Close get_rul_csr;
    End If;
    Return(l_is_k_var_rate);

  End Is_Var_Rate_Contract;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_sty_details
  --
  -- Check status of stream
  -- Return Stream Type ID or Name as requested
  ---------------------------------------------------------------------------
  PROCEDURE get_sty_details (p_sty_id        IN  NUMBER   DEFAULT NULL,
                             p_sty_name      IN  VARCHAR2 DEFAULT NULL,
                             x_sty_id        OUT NOCOPY NUMBER,
                             x_sty_name      OUT NOCOPY VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2) IS

    CURSOR c_sty_name IS
      SELECT styt.name
      FROM   okl_strm_type_b sty,
             okl_strm_type_tl styt
      WHERE  sty.id = p_sty_id
        AND  sty.version = '1.0'  -- not really needed in 1159
        AND  sty.id = styt.id
        AND  styt.language = 'US'
        AND  sty.start_date <= TRUNC(SYSDATE)
        AND  NVL(sty.end_date, SYSDATE) >= TRUNC(SYSDATE);

    CURSOR c_sty_id IS
      SELECT sty.id
      FROM   okl_strm_type_b sty,
             okl_strm_type_tl styt
      WHERE  styt.name = p_sty_name
        AND  styt.language = 'US'
        AND  styt.id = sty.id
        AND  sty.version = '1.0'  -- not really needed in 1159
        AND  sty.start_date <= TRUNC(SYSDATE)
        AND  NVL(sty.end_date, SYSDATE) >= TRUNC(SYSDATE);

    l_sty_id          NUMBER;
    l_sty_name        VARCHAR2(150);

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_sty_details';

  BEGIN

    print( l_prog_name, 'begin' );

    IF p_sty_id IS NOT NULL THEN

      OPEN c_sty_name;
      FETCH c_sty_name INTO l_sty_name;
      CLOSE c_sty_name;

      IF l_sty_name IS NOT NULL THEN

        x_sty_name := l_sty_name;
        x_sty_id   := p_sty_id;

      ELSE

        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_STREAM_ID_NOT_FOUND',
                            p_token1       => 'STY_ID',
                            p_token1_value => p_sty_id);

        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

      END IF;

    ELSIF p_sty_name IS NOT NULL THEN

      OPEN c_sty_id;
      FETCH c_sty_id INTO l_sty_id;
      CLOSE c_sty_id;

      IF l_sty_id IS NOT NULL THEN

        x_sty_id   := l_sty_id;
        x_sty_name := p_sty_name;

      ELSE

        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_STREAM_TYPE_NOT_FOUND',
                            p_token1       => 'STY_NAME',
                            p_token1_value => p_sty_name);

        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

      END IF;

    END IF;

    x_return_status  :=  G_RET_STS_SUCCESS;
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

  END get_sty_details;


  ---------------------------------------------------------------------------
  -- PROCEDURE get_mapped_stream
  --
  -- DESC
  -- Repository of hard-coded stream type mapping
  --
  -- USAGE
  -- Driven by mapping type.  Must provide mapping type
  ---------------------------------------------------------------------------
  PROCEDURE get_mapped_stream (p_sty_purpose       IN         VARCHAR2  DEFAULT NULL,
                               p_line_style        IN         VARCHAR2,
                               p_mapping_type      IN         VARCHAR2,
                               p_deal_type         IN         VARCHAR2,
                               p_primary_sty_id    IN         NUMBER DEFAULT NULL,
                               p_fee_type          IN         VARCHAR2 DEFAULT NULL,
                               p_recurr_yn         IN         VARCHAR2 DEFAULT NULL,
                               p_pt_yn             IN         VARCHAR2  DEFAULT 'N',
                               p_khr_id            IN         NUMBER,
                               p_stream_type_purpose        IN         VARCHAR2  DEFAULT NULL,
                               x_mapped_stream     OUT NOCOPY VARCHAR2,
                               x_return_status     OUT NOCOPY VARCHAR2) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_mapped_stream';
    l_sty_id NUMBER;

    CURSOR c_hdr IS
		    select chr.orig_system_source_code,
           chr.start_date,
           chr.end_date,
           chr.template_yn,
	   chr.authoring_org_id,
	   chr.inv_organization_id,
           khr.deal_type,
           to_char(pdt.id)  pid, --358660899972842057983133434721270318297
	   nvl(pdt.reporting_pdt_id, -1) report_pdt_id,
           chr.currency_code currency_code,
           khr.term_duration term
    from   okc_k_headers_v chr,
           okl_k_headers khr,
           okl_products_v pdt
    where khr.id = chr.id
        and chr.id = p_khr_id
        and khr.pdt_id = pdt.id(+);

    r_hdr c_hdr%ROWTYPE;

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


			       l_primary_sty_id    NUMBER;
  BEGIN

    -- Enhancement pending to remove hard coding dependency (TBD by MCHAKRAB, SRAWLING)
    -- Accrual Stream Type will be specified during setup of Payment Stream Type

            OPEN c_rollover_pmnts;
            FETCH c_rollover_pmnts INTO r_rollover_pmnts;
            CLOSE c_rollover_pmnts;

	    l_primary_sty_id := nvl(p_primary_sty_id, r_rollover_pmnts.styId);

    print( l_prog_name, 'begin' );
    print( l_prog_name, ' mapping type ' || p_mapping_type || ' sty ame ' || p_sty_purpose || ' deal type ' || p_deal_type );
    IF p_mapping_type = 'ACCRUAL' THEN

      IF p_sty_purpose = 'RENT' AND p_deal_type = 'LEASEOP' AND
         (p_line_style = 'FREE_FORM1' OR p_line_style IS NULL) THEN
         --x_mapped_stream  :=  'RENTAL ACCRUAL';
    print( l_prog_name, '##1##' );
             OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
					 p_deal_type             => p_deal_type,
					 p_primary_sty_id        => l_primary_sty_id,
                                         p_dependent_sty_purpose => 'RENT_ACCRUAL',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => x_mapped_stream);

      ELSIF p_sty_purpose = 'RENT' AND p_deal_type <> 'LEASEOP' AND
         (p_line_style = 'FREE_FORM1' OR p_line_style IS NULL) THEN
    print( l_prog_name, '##2##' );
         x_mapped_stream  :=  NULL;
      ELSIF p_pt_yn = 'Y' THEN
    print( l_prog_name, '##3##' );
         --x_mapped_stream := 'PASS THROUGH REVENUE ACCRUAL';
         --If condition added by mansrini on 10-Jun-2005 for generating accrual streams for Service Lines
         --Bug 4434343 -Start of Changes

	 IF (p_line_style = 'FEE') THEN
             OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
					 p_deal_type             => p_deal_type,
					 p_primary_sty_id        => l_primary_sty_id,
                                         p_dependent_sty_purpose => 'PASS_THRU_REV_ACCRUAL',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => x_mapped_stream);

        ELSIF ((p_line_style = 'SOLD_SERVICE') OR (p_line_style = 'LINK_SERV_ASSET')) THEN
             OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
					 p_deal_type             => p_deal_type,
					 p_primary_sty_id        => l_primary_sty_id,
                                         p_dependent_sty_purpose => 'PASS_THRU_SVC_REV_ACCRUAL',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => x_mapped_stream);
         END IF;
         --Bug 4434343 -End of Changes

      ELSIF ((p_line_style = 'SOLD_SERVICE') OR (p_line_style = 'LINK_SERV_ASSET')) THEN
    print( l_prog_name, '##4##' );
        --x_mapped_stream  :=  'SERVICE INCOME';
             OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
					 p_deal_type             => p_deal_type,
					 p_primary_sty_id        => l_primary_sty_id,
                                         p_dependent_sty_purpose => 'SERVICE_INCOME',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => x_mapped_stream);

      ELSIF (p_line_style IN ('FEE', 'FREE_FORM1') OR p_line_style IS NULL) AND
            (p_sty_purpose <> 'SECURITY_DEPOSIT') THEN

        If ( p_fee_type = 'INCOME' AND p_recurr_yn = OKL_API.G_FALSE ) Then
	    --x_mapped_stream := 'AMORTIZED FEE INCOME';
             OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
					 p_deal_type             => p_deal_type,
					 p_primary_sty_id        => l_primary_sty_id,
                                         p_dependent_sty_purpose => 'AMORTIZE_FEE_INCOME',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => x_mapped_stream);

	elsif ( p_fee_type = 'FINANCED' OR p_fee_type = 'ROLLOVER') Then
	    x_mapped_stream := NULL;
	else
            --x_mapped_stream  :=  'FEE INCOME';
             OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
					 p_deal_type             => p_deal_type,
					 p_primary_sty_id        => l_primary_sty_id,
                                         p_dependent_sty_purpose => 'ACCRUED_FEE_INCOME',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => x_mapped_stream);

	end if;

      ELSE
        x_mapped_stream  :=  NULL;
      END IF;

    ELSIF p_mapping_type = 'PRE-TAX INCOME' THEN

      IF (p_deal_type IN ('LEASEDF', 'LEASEST')) THEN
        --x_mapped_stream  :=  'PRE-TAX INCOME';
             OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
					 p_deal_type             => p_deal_type,
					 p_primary_sty_id        => l_primary_sty_id,
                                         p_dependent_sty_purpose => 'LEASE_INCOME',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => x_mapped_stream);

      ElsIF (p_deal_type IN ('LOAN', 'LOAN-REVOLVING')) OR ( p_fee_type in ('FINANCED', 'ROLLOVER','LINK_FEE_ASSET') ) THEN
        --x_mapped_stream  :=  'PRE-TAX INCOME';
             OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
					 p_deal_type             => p_deal_type,
					 p_primary_sty_id        => l_primary_sty_id,
                                         p_dependent_sty_purpose => 'INTEREST_INCOME',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => x_mapped_stream);
      ELSE
        x_mapped_stream  :=  NULL;
      END IF;

    ELSIF p_mapping_type = 'PAYMENT' THEN

      IF p_sty_purpose = 'RENT' AND p_deal_type IN ('LOAN', 'LOAN-REVOLVING') THEN
        x_mapped_stream  := 'LOAN PAYMENT';
      ELSE
        x_mapped_stream  :=  p_sty_purpose;
      END IF;

    ELSIF p_mapping_type = 'CAPITAL RECOVERY' THEN

      IF p_deal_type IN ('LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING') THEN
        x_mapped_stream  :=  'PRINCIPAL PAYMENT';
      ELSE
        x_mapped_stream  :=  NULL;
      END IF;

    ELSIF p_mapping_type = 'INTEREST PAYMENT' THEN

      IF p_deal_type IN ('LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING') THEN
        x_mapped_stream  :=  'INTEREST PAYMENT';
      ELSE
        x_mapped_stream  :=  NULL;
      END IF;

    ELSIF p_mapping_type = 'CLOSE BOOK' THEN

      IF p_deal_type IN ('LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING') THEN
        x_mapped_stream  :=  'PRINCIPAL BALANCE';
      ELSE
        x_mapped_stream  :=  NULL;
      END IF;

   ELSIF p_mapping_type = 'DISBURSEMENT' THEN

      OPEN c_hdr;
      FETCH c_hdr INTO r_hdr;
      CLOSE c_hdr;
      IF p_deal_type = 'LEASE' THEN
      If ( p_sty_purpose = 'RENT' ) THen
        --x_mapped_stream  :=  'INVESTOR RENT DISBURSEMENT BASIS';
               OKL_ISG_UTILS_PVT.get_primary_stream_type(
                                                p_khr_id              => p_khr_id,
					        p_pdt_id              => r_hdr.pid,
                                                p_primary_sty_purpose => 'INVESTOR_RENT_DISB_BASIS',
                                                x_return_status       => x_return_status,
                                                x_primary_sty_id      => l_sty_id,
                                                x_primary_sty_name    => x_mapped_stream);

      ElsIf ( p_sty_purpose = 'RESIDUAL' ) Then
        --x_mapped_stream  :=  'INVESTOR RESIDUAL DISBURSEMENT BASIS';
               OKL_ISG_UTILS_PVT.get_primary_stream_type(
                                                p_khr_id              => p_khr_id,
					        p_pdt_id              => r_hdr.pid,
                                                p_primary_sty_purpose => 'INVESTOR_RESIDUAL_DISB_BASIS',
                                                x_return_status       => x_return_status,
                                                x_primary_sty_id      => l_sty_id,
                                                x_primary_sty_name    => x_mapped_stream);
       End If;
       ELSIF p_deal_type = 'LOAN' THEN
         If ( p_sty_purpose = 'LOAN_PAYMENT' ) Then
            IF p_stream_type_purpose = 'PRINCIPAL_PAYMENT' THEN
              OKL_ISG_UTILS_PVT.get_primary_stream_type(
                                                p_khr_id              => p_khr_id,
                                                p_pdt_id              => r_hdr.pid,
                                                p_primary_sty_purpose => 'INVESTOR_PRINCIPAL_DISB_BASIS',
                                                x_return_status       => x_return_status,
                                                x_primary_sty_id      => l_sty_id,
                                                x_primary_sty_name    => x_mapped_stream);
           ELSIF p_stream_type_purpose = 'INTEREST_PAYMENT' THEN
               OKL_ISG_UTILS_PVT.get_primary_stream_type(
                                                p_khr_id              => p_khr_id,
                                                p_pdt_id              => r_hdr.pid,
                                                p_primary_sty_purpose => 'INVESTOR_INTEREST_DISB_BASIS',
                                                x_return_status       => x_return_status,
                                                x_primary_sty_id      => l_sty_id,
                                                x_primary_sty_name    => x_mapped_stream);
             ELSIF p_stream_type_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT' THEN
               OKL_ISG_UTILS_PVT.get_primary_stream_type(
                                                p_khr_id              => p_khr_id,
                                                p_pdt_id              => r_hdr.pid,
                                                p_primary_sty_purpose => 'INVESTOR_PPD_DISB_BASIS',
                                                x_return_status       => x_return_status,
                                                x_primary_sty_id      => l_sty_id,
                                                x_primary_sty_name    => x_mapped_stream);

            End If;
          End If;
        End If;
    ELSIF p_mapping_type = 'PV_DISBURSEMENT' THEN

      OPEN c_hdr;
      FETCH c_hdr INTO r_hdr;
      CLOSE c_hdr;
      IF p_deal_type = 'LEASE' THEN
      If ( p_sty_purpose = 'RENT' ) THen
               OKL_ISG_UTILS_PVT.get_primary_stream_type(
                                                p_khr_id              => p_khr_id,
                                                p_pdt_id              => r_hdr.pid,
                                                p_primary_sty_purpose => 'PV_RENT_SECURITIZED',
                                                x_return_status       => x_return_status,
                                                x_primary_sty_id      => l_sty_id,
                                                x_primary_sty_name    => x_mapped_stream);

      ElsIf ( p_sty_purpose = 'RESIDUAL' ) Then
               OKL_ISG_UTILS_PVT.get_primary_stream_type(
                                                p_khr_id              => p_khr_id,
                                                p_pdt_id              => r_hdr.pid,
                                                p_primary_sty_purpose => 'PV_RV_SECURITIZED',
                                                x_return_status       => x_return_status,
                                                x_primary_sty_id      => l_sty_id,
                                                x_primary_sty_name    => x_mapped_stream);
       End If;
       ELSIF p_deal_type = 'LOAN' THEN
         If ( p_sty_purpose = 'LOAN_PAYMENT' ) Then
            IF p_stream_type_purpose = 'PRINCIPAL_PAYMENT' THEN
              OKL_ISG_UTILS_PVT.get_primary_stream_type(
                                                p_khr_id              => p_khr_id,
                                                p_pdt_id              => r_hdr.pid,
                                                p_primary_sty_purpose => 'PV_PRINCIPAL_SECURITIZED',
                                                x_return_status       => x_return_status,
                                                x_primary_sty_id      => l_sty_id,
                                                x_primary_sty_name    => x_mapped_stream);
           ELSIF p_stream_type_purpose = 'INTEREST_PAYMENT' THEN
               OKL_ISG_UTILS_PVT.get_primary_stream_type(
                                                p_khr_id              => p_khr_id,
                                                p_pdt_id              => r_hdr.pid,
                                                p_primary_sty_purpose => 'PV_INTEREST_SECURITIZED',
                                                x_return_status       => x_return_status,
                                                x_primary_sty_id      => l_sty_id,
                                                x_primary_sty_name    => x_mapped_stream);
            ELSIF p_stream_type_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT' THEN
               OKL_ISG_UTILS_PVT.get_primary_stream_type(
                                                p_khr_id              => p_khr_id,
                                                p_pdt_id              => r_hdr.pid,
                                                p_primary_sty_purpose => 'PV_UNSCHEDULED_PMT_SECURITIZED',
                                                x_return_status       => x_return_status,
                                                x_primary_sty_id      => l_sty_id,
                                                x_primary_sty_name    => x_mapped_stream);

            End If;
          End If;
        End If;

    ELSE

      x_mapped_stream  :=  NULL;

    END IF;

    x_return_status  :=  G_RET_STS_SUCCESS;
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

  END get_mapped_stream;



  ---------------------------------------------------------------------------
  -- FUNCTION get_months_factor
  ---------------------------------------------------------------------------
  FUNCTION get_months_factor( p_frequency     IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER IS
    l_months  NUMBER;
    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_months_factor';
  BEGIN
    IF p_frequency = 'M' THEN
      l_months := 1;
    ELSIF p_frequency = 'Q' THEN
      l_months := 3;
    ELSIF p_frequency = 'S' THEN
      l_months := 6;
    ELSIF p_frequency = 'A' THEN
      l_months := 12;
    END IF;
    --print( 'get_months_factor: p_frequency, l_months = ' || p_frequency || ',' || l_months );
    IF l_months IS NOT NULL THEN
      x_return_status := G_RET_STS_SUCCESS;
      RETURN l_months;
    ELSE
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_INVALID_FREQUENCY_CODE',
                          p_token1       => 'FRQ_CODE',
                          p_token1_value => p_frequency);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS
    THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END get_months_factor;


  ---------------------------------------------------------------------------
  -- FUNCTION get_first_sel_date
  ---------------------------------------------------------------------------
-- djanaswa ER6274342 added parameter p_arrears_pay_dates_option

  FUNCTION get_first_sel_date( p_start_date          IN    DATE,
                               p_advance_or_arrears  IN    VARCHAR2,
                               p_months_increment    IN    NUMBER,
                               p_arrears_pay_dates_option IN VARCHAR2,
                               x_return_status       OUT NOCOPY VARCHAR2) RETURN DATE IS
    l_date  DATE;

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_first_sel_date';

  BEGIN


    print( l_prog_name, 'begin' );

    --Added by kthiruva on 04-01-2005
    --Bug 4100610 - Start of Changes
    IF ((p_advance_or_arrears = 'ADVANCE') OR (p_advance_or_arrears = 'N')) THEN
      l_date  :=  TRUNC(p_start_date);
    ELSIF ((p_advance_or_arrears = 'ARREARS') OR (p_advance_or_arrears = 'Y')) THEN
    -- djanaswa ER 6274342 Added IF condition
         IF p_arrears_pay_dates_option = 'FIRST_DAY_OF_NEXT_PERIOD' THEN
                l_date  :=  ADD_MONTHS(TRUNC(p_start_date), p_months_increment);
            ELSE
               l_date  :=  ADD_MONTHS(TRUNC(p_start_date), p_months_increment) - 1;
         END IF;
    END IF;
    --Bug 4100610 - End Of Changes
    IF l_date IS NOT NULL THEN
      x_return_status := G_RET_STS_SUCCESS;
      RETURN l_date;
    ELSE
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

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

  END get_first_sel_date;


  ---------------------------------------------------------------------------
  -- FUNCTION get_advance_count
  ---------------------------------------------------------------------------
  FUNCTION get_advance_count( p_structure       IN   VARCHAR2,
                              x_return_status   OUT NOCOPY VARCHAR2) RETURN NUMBER IS

    l_count  NUMBER;
    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_advance_count';


  BEGIN

    print( l_prog_name, 'begin' );
    IF NVL(p_structure, 'LEVEL') IN ('LEVEL', '0') THEN
      l_count := 0;
    ELSIF p_structure IN ('1STLAST', '1') THEN
      l_count := 1;
    ELSIF p_structure IN ('1STLAST2', '2')  THEN
      l_count := 2;
    ELSIF p_structure IN ('1STLAST3', '3')  THEN
      l_count := 3;
    ELSE
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_INVALID_PAYMENT_STRUCTURE',
                          p_token1       => 'STRUCTURE_CODE',
                          p_token1_value => p_structure);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;
    print( l_prog_name, 'end' );
    RETURN l_count;

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

  END get_advance_count;


  ---------------------------------------------------------------------------
  -- FUNCTION get_fractional_month
  ---------------------------------------------------------------------------
  FUNCTION get_fractional_month( p_start_date    IN  DATE,
                                 x_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER IS

    l_fraction  NUMBER;

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_fractional_month';

  BEGIN

    print( l_prog_name, 'begin' );
    IF TO_CHAR(p_start_date, 'DD') IN ('30', '31') OR
       (TO_CHAR(p_start_date, 'MON') = 'FEB' AND TO_CHAR(p_start_date, 'DD') IN ('28', '29')) THEN
      l_fraction := 0;
    ELSIF p_start_date = (ADD_MONTHS(LAST_DAY(p_start_date), -1) + 1) THEN
      l_fraction :=1;
    ELSE
      l_fraction := (30 - TO_CHAR(p_start_date-1, 'DD')) / 30;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;
    print( l_prog_name, 'end' );
    RETURN l_fraction;

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

  END get_fractional_month;


  ---------------------------------------------------------------------------
  -- PROCEDURE get_stream_header
  ---------------------------------------------------------------------------
  PROCEDURE get_stream_header(p_purpose_code   IN  VARCHAR2,
                              p_khr_id         IN  NUMBER,
                              p_kle_id         IN  NUMBER,
                              p_sty_id         IN  NUMBER,
                              x_stmv_rec       OUT NOCOPY okl_stm_pvt.stmv_rec_type,
                              x_return_status  OUT NOCOPY VARCHAR2) IS

    l_stmv_rec                okl_stm_pvt.stmv_rec_type;
    l_transaction_number      NUMBER;

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_stream_header';


  BEGIN

    --print( l_prog_name, 'begin' );
    SELECT okl_sif_seq.nextval INTO l_transaction_number FROM DUAL;

    -- NOTE: UV for Streams inquiry (OKL_ASSET_STREAMS_UV) assumes a denormalized use of KHR_ID

    l_stmv_rec.khr_id  :=  p_khr_id;
    l_stmv_rec.kle_id              :=  p_kle_id;
    l_stmv_rec.sty_id              :=  p_sty_id;
    l_stmv_rec.sgn_code            :=  'MANL';
    l_stmv_rec.say_code            :=  'WORK';                    --  calling API will update to CURR as required
    l_stmv_rec.active_yn           :=  'N';                       --  calling API will update to Y as required
    l_stmv_rec.transaction_number  :=  l_transaction_number;      --  approved by AKJAIN
    -- l_stmv_rec.date_current        :=  NULL;                                    --  TBD
    l_stmv_rec.date_working        :=  SYSDATE;                                    --  TBD
    -- l_stmv_rec.date_history        :=  NULL;                                    --  TBD
    -- l_stmv_rec.comments            :=  NULL;                                    --  TBD

    IF p_purpose_code = 'REPORT' THEN

      l_stmv_rec.purpose_code := 'REPORT';

    END IF;

    x_stmv_rec                     := l_stmv_rec;
    x_return_status                := G_RET_STS_SUCCESS;

    --print( l_prog_name, 'end' );
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

  END get_stream_header;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_stream_elements
  --
  -- Description
  -- Populates Stream Elements array for contiguous periodic charges/expenses
  --
  -- Added parameter p_recurrence_date by djanaswa for bug 6007644
  ---------------------------------------------------------------------------
  PROCEDURE get_stream_elements( p_start_date          IN      DATE,
                                 p_periods             IN      NUMBER,
                                 p_frequency           IN      VARCHAR2,
                                 p_structure           IN      VARCHAR2,
                                 p_advance_or_arrears  IN      VARCHAR2,
                                 p_amount              IN      NUMBER,
                                 p_stub_days           IN      NUMBER,
                                 p_stub_amount         IN      NUMBER,
                                 p_currency_code       IN      VARCHAR2,
                                 p_khr_id              IN      NUMBER,
                                 p_kle_id              IN      NUMBER,
                                 p_purpose_code        IN      VARCHAR2,
                                 x_selv_tbl            OUT NOCOPY okl_sel_pvt.selv_tbl_type,
                                 x_pt_tbl              OUT NOCOPY okl_sel_pvt.selv_tbl_type,
                                 x_pt_pro_fee_tbl      OUT NOCOPY okl_sel_pvt.selv_tbl_type,
                                 x_return_status       OUT NOCOPY VARCHAR2,
                                 x_msg_count           OUT NOCOPY NUMBER,
                                 x_msg_data            OUT NOCOPY VARCHAR2,
                                 p_recurrence_date     IN      DATE) IS


    top_svc_rec top_svc_csr%ROWTYPE;

    lx_return_status             VARCHAR2(1);

    l_months_factor              NUMBER;
    l_first_sel_date             DATE;
    l_element_count              NUMBER;
    l_base_amount                NUMBER;
    l_amount                     NUMBER;

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_stream_elements';

-- djanaswa ER6274342 start
    l_arrears_pay_dates_option  okl_st_gen_tmpt_sets_all.isg_arrears_pay_dates_option%type;
-- djanaswa ER6274342 end


  BEGIN

    print( l_prog_name, 'begin' );
    l_months_factor := get_months_factor( p_frequency       =>   p_frequency,
                                          x_return_status   =>   lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


-- djanaswa ER6274342 start
     IF p_advance_or_arrears = 'ARREARS' THEN
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

-- djanaswa ER6274342 end


    IF ( p_amount IS NULL )
    THEN
        l_amount := NULL;
    ELSE
        l_amount := p_amount;
    END IF;

    IF ( p_periods IS NULL ) AND ( p_stub_days IS NOT NULL )
    THEN
        x_selv_tbl(1).amount                     := p_stub_amount;
        x_selv_tbl(1).se_line_number             := 1;                            -- TBD
        x_selv_tbl(1).accrued_yn                 := NULL;                         -- TBD

        IF p_advance_or_arrears = 'ARREARS' THEN
-- djanaswa  ER6274342 start
           --  x_selv_tbl(1).stream_element_date        := p_start_date + p_stub_days - 1;
            x_selv_tbl(1).comments                   := 'Y';

            IF l_arrears_pay_dates_option = 'FIRST_DAY_OF_NEXT_PERIOD' THEN
                    x_selv_tbl(1).stream_element_date        := p_start_date + p_stub_days;
            ELSE
                    x_selv_tbl(1).stream_element_date        := p_start_date + p_stub_days - 1;
            END IF;
-- djanaswa  ER6274342 end

        ELSE
            x_selv_tbl(1).stream_element_date        := p_start_date;
            x_selv_tbl(1).comments                   := 'N';
        END IF;

    ELSE

        l_element_count := p_periods;
        --print( l_prog_name, 'creating elements: ' || to_char(l_element_count) );


        FOR i IN 1 .. l_element_count
        LOOP
            x_selv_tbl(i).amount                     := l_amount;

            IF p_advance_or_arrears = 'ARREARS'
            THEN
              x_selv_tbl(i).comments := 'Y';
            ELSE
              x_selv_tbl(i).comments := 'N';
            END IF;

            -- Modified by RGOOTY: Start 4371472
         --Added parameter p_recurrence_date by djanaswa for bug 6007644
         -- added p_arrears_pay_dates_option by DJANASWA ER 6274342
            get_sel_date(
              p_start_date         => p_start_date,
              p_advance_or_arrears => p_advance_or_arrears,
              p_periods_after      => i,
              p_months_per_period  => l_months_factor,
              x_date               => x_selv_tbl(i).stream_element_date,
              x_return_status      => lx_return_status,
              p_recurrence_date    => p_recurrence_date,
              p_arrears_pay_dates_option => l_arrears_pay_dates_option);
            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Modified by RGOOTY: End

            x_selv_tbl(i).se_line_number             := i;                            -- TBD
            x_selv_tbl(i).accrued_yn                 := NULL;                         -- TBD
        END LOOP;
     END IF;

    x_return_status := G_RET_STS_SUCCESS ;
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

  END get_stream_elements;


  ---------------------------------------------------------------------------
  -- PROCEDURE get_stream_elements
  --
  -- Description
  -- Populates Stream Elements array for contiguous periodic charges/expenses
  --
  -- Added parameter p_recurrence_date by djanaswa for bug 6007644
  ---------------------------------------------------------------------------
  PROCEDURE get_stream_elements( p_start_date          IN      DATE,
                                 p_periods             IN      NUMBER,
                                 p_frequency           IN      VARCHAR2,
                                 p_structure           IN      VARCHAR2,
                                 p_advance_or_arrears  IN      VARCHAR2,
                                 p_amount              IN      NUMBER,
                                 p_stub_days           IN      NUMBER,
                                 p_stub_amount         IN      NUMBER,
                                 p_currency_code       IN      VARCHAR2,
                                 p_khr_id              IN      NUMBER,
                                 p_kle_id              IN      NUMBER,
                                 p_purpose_code        IN      VARCHAR2,
                                 x_selv_tbl            OUT NOCOPY okl_sel_pvt.selv_tbl_type,
                                 x_pt_tbl              OUT NOCOPY okl_sel_pvt.selv_tbl_type,
                                 x_return_status       OUT NOCOPY VARCHAR2,
                                 x_msg_count           OUT NOCOPY NUMBER,
                                 x_msg_data            OUT NOCOPY VARCHAR2,
                                 p_recurrence_date     IN      DATE) IS

     CURSOR c_pt_perc( kleid NUMBER) IS
      SELECT NVL(TO_NUMBER(rul.rule_information1), 100) pass_through_percentage
      FROM   okc_rule_groups_b rgp,
             okc_rules_b rul
      WHERE  rgp.cle_id = kleid
        AND  rgp.rgd_code = 'LAPSTH'
        AND  rgp.id = rul.rgp_id
        AND  rul.rule_information_category = 'LAPTPR';

    rec_pt_perc c_pt_perc%ROWTYPE;

    top_svc_rec top_svc_csr%ROWTYPE;

    l_pt_perc                    NUMBER;

    lx_return_status             VARCHAR2(1);

    l_months_factor              NUMBER;
    l_first_sel_date             DATE;
    l_element_count              NUMBER;
    l_base_amount                NUMBER;
    l_amount                     NUMBER;

-- djanaswa ER6274342 start
    l_arrears_pay_dates_option  okl_st_gen_tmpt_sets_all.isg_arrears_pay_dates_option%type;
-- djanaswa ER6274342 end

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_stream_elements';

  BEGIN

    print( l_prog_name, 'begin' );
    l_months_factor := get_months_factor( p_frequency       =>   p_frequency,
                                          x_return_status   =>   lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

-- djanaswa ER6274342 start
     IF p_advance_or_arrears = 'ARREARS' THEN
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

-- djanaswa ER6274342 end

    IF ( p_amount IS NULL )
    THEN
        l_amount := NULL;
    ELSE
        l_amount := p_amount;
    END IF;

    IF ( p_periods IS NULL ) AND ( p_stub_days IS NOT NULL )
    THEN
        x_selv_tbl(1).amount                     := p_stub_amount;
        x_selv_tbl(1).se_line_number             := 1;                            -- TBD
        x_selv_tbl(1).accrued_yn                 := NULL;                         -- TBD

        IF p_advance_or_arrears = 'ARREARS' THEN
        -- djanaswa  ER6274342 start
            -- x_selv_tbl(1).stream_element_date        := p_start_date + p_stub_days - 1;
            x_selv_tbl(1).comments                   := 'Y';

            IF l_arrears_pay_dates_option = 'FIRST_DAY_OF_NEXT_PERIOD' THEN
                    x_selv_tbl(1).stream_element_date        := p_start_date + p_stub_days;
            ELSE
                    x_selv_tbl(1).stream_element_date        := p_start_date + p_stub_days - 1;
            END IF;
        -- djanaswa  ER6274342 end

        ELSE
            x_selv_tbl(1).stream_element_date        := p_start_date;
            x_selv_tbl(1).comments                   := 'N';
        END IF;

    ELSE

        l_element_count := p_periods;
        --print( l_prog_name, 'creating elements: ' || to_char(l_element_count) );


        FOR i IN 1 .. l_element_count
        LOOP
            x_selv_tbl(i).amount                     := l_amount;

            IF p_advance_or_arrears = 'ARREARS'
            THEN
              x_selv_tbl(i).comments := 'Y';
            ELSE
              x_selv_tbl(i).comments := 'N';
            END IF;

            -- Modified by RGOOTY: Start 4371472
            --Added parameter p_recurrence_date by djanaswa for bug 6007644
           -- added p_arrears_pay_dates_option by DJANASWA ER 6274342
            get_sel_date(
              p_start_date         => p_start_date,
              p_advance_or_arrears => p_advance_or_arrears,
              p_periods_after      => i,
              p_months_per_period  => l_months_factor,
              x_date               => x_selv_tbl(i).stream_element_date,
              x_return_status      => lx_return_status,
              p_recurrence_date    => p_recurrence_date,
              p_arrears_pay_dates_option => l_arrears_pay_dates_option);
            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            -- Modified by RGOOTY: End

            x_selv_tbl(i).se_line_number             := i;                            -- TBD
            x_selv_tbl(i).accrued_yn                 := NULL;                         -- TBD
        END LOOP;
     END IF;

    OPEN top_svc_csr( p_khr_id, p_kle_id );
    FETCH top_svc_csr INTO top_svc_rec;
    If ( top_svc_csr%FOUND ) Then
        print( l_prog_name, ' found top svc line ' || to_char( p_kle_id ));
        OPEN c_pt_perc( top_svc_rec.top_svc_id);
    Else
        print( l_prog_name, ' not found top svc line ' || to_char( p_kle_id ));
        OPEN c_pt_perc( p_kle_id);
    End If;
    CLOSE top_svc_csr;

    FETCH c_pt_perc INTO rec_pt_perc;
    CLOSE c_pt_perc;

    l_pt_perc := rec_pt_perc.pass_through_percentage;

    print( l_prog_name, ' pass thru percent ' || to_char( l_pt_perc ) );
    print( l_prog_name, ' payment amount ' || to_char( p_amount ) );

    IF (l_pt_perc IS NOT NULL) THEN

        get_accrual_elements (p_start_date          => p_start_date,
                              p_periods             => p_periods,
                              p_frequency           => p_frequency,
                              p_structure           => p_structure,
                              p_advance_or_arrears  => p_advance_or_arrears,
                              p_amount              => nvl(p_amount,0)*(l_pt_perc/100),
			      p_stub_days           => p_stub_days,
                              p_stub_amount         => nvl(p_stub_amount,0)*(l_pt_perc/100),
                              p_currency_code       => p_currency_code,
                              x_selv_tbl            => x_pt_tbl,
                              x_return_status       => lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


    END IF;

    x_return_status := G_RET_STS_SUCCESS ;
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

  END get_stream_elements;


  ---------------------------------------------------------------------------
  -- PROCEDURE get_accrual_elements
  --
  -- Description
  -- Populates Stream Elements array for Accurals
  -- such as RENT ACCRUAL
  ---------------------------------------------------------------------------
  PROCEDURE get_accrual_elements (p_start_date          IN         DATE,
                                  p_periods             IN         NUMBER,
                                  p_frequency           IN         VARCHAR2,
                                  p_structure           IN         NUMBER,
                                  p_advance_or_arrears  IN         VARCHAR2,
                                  p_amount              IN         NUMBER,
                                  p_stub_days           IN         NUMBER,
                                  p_stub_amount         IN         NUMBER,
                                  p_currency_code       IN         VARCHAR2,
                                  p_day_convention_month    IN VARCHAR2 DEFAULT '30',
				  p_day_convention_year    IN VARCHAR2 DEFAULT '360',
                                  x_selv_tbl            OUT NOCOPY okl_streams_pub.selv_tbl_type,
                                  x_return_status       OUT NOCOPY VARCHAR2) IS

    lx_return_status             VARCHAR2(1);

    l_fractional_month           NUMBER;
    l_months_factor              NUMBER;
    l_element_count              NUMBER;
    l_day_count                  NUMBER;
    l_se_date                    DATE;
    l_amount                     NUMBER;

    i  BINARY_INTEGER := 0;
    l_temp_start_date DATE;
    l_amount_per_day NUMBER;
    l_stream_amount NUMBER;
    l_remaining_amount NUMBER;
    l_remaining_days NUMBER;
    l_temp_end_date DATE;
    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_accrual_elements';

  BEGIN

--    print( l_prog_name, 'begin' );
    l_fractional_month := get_fractional_month(p_start_date    => p_start_date,
                                               x_return_status => lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_months_factor := get_months_factor(p_frequency     =>   p_frequency,
                                         x_return_status =>   lx_return_status);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  If ( p_periods IS NULL ) AND ( p_stub_days IS NOT NULL ) THen

     l_se_date    :=  LAST_DAY(p_start_date);

     l_remaining_days := p_stub_days;
     l_temp_start_date := p_start_date;
     l_temp_end_date := l_temp_start_date + l_remaining_days - 1;
     l_amount_per_day := p_stub_amount/p_stub_days;
     IF l_temp_end_date > l_se_date THEN
       l_temp_end_date := l_se_date;
     END IF;

     l_remaining_amount := p_stub_amount;
     while l_remaining_days > 0  loop
       i := i + 1;
       IF l_temp_end_date < l_se_date THEN
         l_day_count := l_remaining_days;
       ELSE
         l_day_count := OKL_PRICING_UTILS_PVT.get_day_count (p_start_date => l_temp_start_date,
                                   p_days_in_month => 'ACTUAL', --p_day_convention_month,
                                   p_days_in_year => 'ACTUAL', --p_day_convention_year,
                                   p_end_date   => l_temp_end_date,
                                   p_arrears    => 'Y',
                                   x_return_status => lx_return_status);
       END IF;

     IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

       l_stream_amount := l_amount_per_day * l_day_count;
       x_selv_tbl(i).amount                     := l_stream_amount;
       x_selv_tbl(i).stream_element_date        := l_se_date;
       x_selv_tbl(i).se_line_number             := i;
       l_remaining_amount := l_remaining_amount - l_stream_amount;
       l_temp_start_date := l_se_date + 1;
       l_se_date :=  add_months(l_se_date, 1);
       l_remaining_days := l_remaining_days - l_day_count;
       l_temp_end_date := l_temp_start_date + l_remaining_days - 1;
       IF l_temp_end_date > l_se_date THEN
         l_temp_end_date := l_se_date;
       END IF;
    end loop;
    /* If ( l_day_count < p_stub_days ) Then

         x_selv_tbl(1).amount                     := (p_stub_amount*l_day_count)/p_stub_days;
         x_selv_tbl(1).stream_element_date        := l_se_date;
         x_selv_tbl(1).se_line_number             := 1;

         l_se_date    :=  ADD_MONTHS(LAST_DAY(p_start_date) , 1);
         IF TO_CHAR(l_se_date, 'MON') IN ('JAN', 'MAR', 'MAY', 'JUL', 'AUG', 'OCT', 'DEC') THEN
             l_se_date  :=  l_se_date - 1;
         END IF;

         x_selv_tbl(2).amount                     := p_stub_amount - x_selv_tbl(1).amount;
         x_selv_tbl(2).stream_element_date        := l_se_date;
         x_selv_tbl(2).se_line_number             := 2;

     Else

         x_selv_tbl(1).amount                     := p_stub_amount;
         x_selv_tbl(1).stream_element_date        := l_se_date;
         x_selv_tbl(1).se_line_number             := 1;

     End If; */

  Else

    l_element_count := (p_periods * l_months_factor) + 1;
    FOR i IN 1 .. l_element_count LOOP

      l_se_date    :=  ADD_MONTHS(LAST_DAY(p_start_date) , (i - 1));
      IF TO_CHAR(l_se_date, 'MON') IN ('JAN', 'MAR', 'MAY', 'JUL', 'AUG', 'OCT', 'DEC') THEN

        l_se_date  :=  l_se_date - 1;

      END IF;

      IF i = 1 THEN

        l_amount := (p_amount/l_months_factor) * l_fractional_month;

/*
        l_amount := okl_accounting_util.validate_amount(
                      p_amount         =>  ((p_amount/l_months_factor) * l_fractional_month),
                      p_currency_code  =>  p_currency_code);

*/
      ELSIF i = l_element_count THEN

        l_amount :=  (p_amount/l_months_factor) * (1 - l_fractional_month);
/*
        l_amount :=  okl_accounting_util.validate_amount(
                      p_amount         =>  ((p_amount/l_months_factor) * (1 - l_fractional_month)),
                      p_currency_code  =>  p_currency_code);
		      */

      ELSE

        l_amount := p_amount/l_months_factor;
/*
        l_amount := okl_accounting_util.validate_amount(p_amount         =>  (p_amount/l_months_factor),
                                                        p_currency_code  =>  p_currency_code);
							*/

      END IF;

      IF (i < l_element_count) OR (i = l_element_count AND l_amount <> 0) THEN

        x_selv_tbl(i).amount                     := l_amount;
        x_selv_tbl(i).stream_element_date        := l_se_date;
        x_selv_tbl(i).se_line_number             := i;

      END IF;

    END LOOP;

  End If;

    print( l_prog_name, 'end' );
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
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

  END get_accrual_elements;


  ---------------------------------------------------------------------------
  -- FUNCTION get_day_count
  ---------------------------------------------------------------------------
  FUNCTION get_day_count (p_start_date     IN   DATE,
                          p_end_date       IN   DATE,
                          p_arrears        IN   VARCHAR2,
                          x_return_status  OUT NOCOPY VARCHAR2) RETURN NUMBER IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_day_count';

    l_days       NUMBER  :=  0;

    l_sd_ld      VARCHAR2(1) := 'N';
    l_cf_ld      VARCHAR2(1) := 'N';

    l_fom        DATE;
    i            NUMBER := 0;
    l_mon_Date   DATE;
    l_char_days varchar2(4);

    l_start_date DATE;
    l_end_date DATE;
    l_months NUMBER;
    -- Bug 4626837 : Start
    l_start_mon VARCHAR2(15);
    l_end_mon VARCHAR2(15);
    -- Bug 4626837 : End
  BEGIN

   l_start_date := trunc( p_start_date );
   l_end_date := trunc( p_end_date );

    --print( l_prog_name, 'begin' );
    x_return_status  :=  G_RET_STS_SUCCESS;
    l_months := 0;
   IF l_start_date > l_end_date THEN
      RETURN 0;
    END IF;

    l_fom := LAST_DAY(l_start_date) + 1;
    l_mon_date := ADD_MONTHS(LAST_DAY(p_end_date) + 1, -1);

    IF l_fom < l_mon_date THEN

 /*     LOOP
        IF l_fom = l_mon_date THEN
          EXIT;
        ELSE
          l_days := l_days + 30;
          l_fom  := ADD_MONTHS(l_fom, 1);
          i      := i + 1;
        END IF;

      END LOOP;*/
      i := 1;
      l_months := trunc(months_between( l_mon_date, l_fom ));
      l_days := l_months * 30;
      l_fom := add_months( l_fom, l_months );


    END IF;

   l_start_mon := TO_CHAR(l_start_date, 'MON');
   l_end_mon := TO_CHAR(l_end_date, 'MON');

   l_char_days := TO_CHAR(l_end_date, 'DD');
    IF l_char_days IN ('30', '31') OR
       (l_end_mon = 'FEB' AND l_char_days IN ('28', '29')) THEN
      l_cf_ld := 'Y';
    END IF;

   l_char_days := TO_CHAR(l_start_date, 'DD');
    IF  l_char_days IN ('30', '31') OR
       ( l_start_mon = 'FEB' AND l_char_days IN ('28', '29')) THEN
      l_sd_ld := 'Y';
    END IF;

    -- Starting date is always counted
    -- CF date is only counted if payment is in arrears (SRAWLING)

    IF i > 0 THEN

      IF l_sd_ld = 'Y' THEN
        l_days := l_days + 1;
      ELSE
        l_days := l_days + 30 - l_char_days + 1;
      END IF;

      IF l_cf_ld = 'Y' THEN
        l_days := l_days + 30;
      ELSE
        l_days := l_days + (l_end_date - l_fom) + 1;
      END IF;

    ELSE

      IF l_end_mon <> l_start_mon THEN  -- i=0 so YYYY will be the same

        IF l_sd_ld = 'Y' THEN
          l_days := l_days + 1;
        ELSE
          l_days := l_days + 30 - l_char_days + 1;
        END IF;

        IF l_cf_ld = 'Y' THEN
          l_days := l_days + 30;
        ELSE
          l_days := l_days + (l_end_date - l_fom) + 1;
        END IF;

      ELSE

        IF l_sd_ld = 'Y' AND l_cf_ld = 'Y' THEN
          l_days := 1;
        ELSIF l_cf_ld = 'Y' THEN
          l_days := 30 - l_char_days + 1;
        ELSE
          l_days := (l_end_date - l_start_date) + 1;
        END IF;

      END IF;

    END IF;

    IF p_arrears <> 'Y' THEN
      l_days := l_days - 1;
    END IF;

  --print( l_prog_name, 'end' );
    RETURN l_days;

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

  END get_day_count;



  ---------------------------------------------------------------------------
  -- PROCEDURE consolidate_header_streams
  ---------------------------------------------------------------------------
  PROCEDURE consolidate_header_streams(p_khr_id         IN NUMBER,
                                     p_purpose_code   IN VARCHAR2,
                                     x_return_status  OUT NOCOPY VARCHAR2) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'consolidate_header_streams';

    CURSOR c_stm_count IS
      SELECT COUNT(stm.id),
             stm.sty_id
      FROM   okl_streams stm
      WHERE  stm.khr_id = p_khr_id
        AND  stm.say_code = 'WORK'
        AND  NVL(stm.purpose_code, '-99') = p_purpose_code
        AND  stm.kle_id IS NULL
      HAVING COUNT(stm.id) > 1
      GROUP BY stm.kle_id, stm.sty_id;

    CURSOR c_stm_first (p_sty_id NUMBER) IS
      SELECT id
      FROM   okl_streams
      WHERE  khr_id = p_khr_id
        AND  kle_id IS NULL
        AND  say_code = 'WORK'
        AND  sty_id = p_sty_id
        AND  NVL(purpose_code, '-99') = p_purpose_code;

    CURSOR c_stm (p_sty_id NUMBER, p_stm_id NUMBER) IS
      SELECT id
      FROM   okl_streams
      WHERE  khr_id = p_khr_id
        AND  kle_id IS NULL
        AND  sty_id = p_sty_id
        AND  say_code = 'WORK'
        AND  NVL(purpose_code, '-99') = p_purpose_code
        AND  id <> p_stm_id;

    CURSOR c_last_sel (p_stm_id NUMBER) IS
      SELECT se_line_number
      FROM   okl_strm_elements
      WHERE  stm_id = p_stm_id
      ORDER BY se_line_number DESC;

    CURSOR c_sel (p_stm_id NUMBER) IS
      SELECT id
      FROM   okl_strm_elements
      WHERE  stm_id = p_stm_id
      ORDER BY stream_element_date;

    l_stm_first         NUMBER;
    l_line_num          NUMBER;
    n                   NUMBER := 0;

  BEGIN

    print( l_prog_name, 'begin' );
    FOR l_stm_count IN c_stm_count LOOP

      OPEN c_stm_first (p_sty_id => l_stm_count.sty_id);
      FETCH c_stm_first INTO l_stm_first;
      CLOSE c_stm_first;

      OPEN c_last_sel (p_stm_id => l_stm_first);
      FETCH c_last_sel INTO l_line_num;
      CLOSE c_last_sel;

      FOR l_stm IN c_stm (l_stm_count.sty_id, l_stm_first) LOOP

        DELETE FROM okl_streams WHERE id = l_stm.id
          and khr_id = p_khr_id;

        FOR l_sel IN c_sel (l_stm.id) LOOP

          n := n + 1;

          UPDATE okl_strm_elements
          SET stm_id = l_stm_first, se_line_number = (l_line_num + n) WHERE id = l_sel.id;

        END LOOP;


      END LOOP;

    END LOOP;


    DELETE FROM OKL_STREAMS WHERE purpose_code = 'STUBS'
     and khr_id = p_khr_id;
    x_return_status := G_RET_STS_SUCCESS;
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

  END consolidate_header_streams;

  ---------------------------------------------------------------------------
  -- PROCEDURE consolidate_line_streams
  ---------------------------------------------------------------------------
  PROCEDURE consolidate_line_streams(p_khr_id         IN NUMBER,
                                     p_purpose_code   IN VARCHAR2,
                                     x_return_status  OUT NOCOPY VARCHAR2) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'consolidate_line_streams';

    CURSOR c_stm_count IS
      SELECT COUNT(stm.id),
             stm.kle_id,
             stm.sty_id
      FROM   okl_streams stm,
             okc_k_lines_b cle,
             okc_line_styles_b lse
      WHERE  stm.khr_id = p_khr_id
        AND  stm.say_code = 'WORK'
        AND  NVL(stm.purpose_code, '-99') = p_purpose_code
        AND  stm.kle_id IS NOT NULL
        AND  stm.kle_id = cle.id
        AND  cle.lse_id = lse.id
        AND  lse.lty_code IN ('FEE', 'SOLD_SERVICE', 'LINK_SERV_ASSET', 'FREE_FORM1', 'LINK_FEE_ASSET')
      HAVING COUNT(stm.id) > 1
      GROUP BY stm.kle_id, stm.sty_id;

    CURSOR c_stm_first (p_kle_id NUMBER, p_sty_id NUMBER) IS
      SELECT id
      FROM   okl_streams
      WHERE  khr_id = p_khr_id
        AND  kle_id = p_kle_id
        AND  sty_id = p_sty_id
        AND  say_code = 'WORK'
        AND  NVL(purpose_code, '-99') = p_purpose_code;

    CURSOR c_stm (p_kle_id NUMBER, p_sty_id NUMBER, p_stm_id NUMBER) IS
      SELECT id
      FROM   okl_streams
      WHERE  khr_id = p_khr_id
        AND  kle_id = p_kle_id
        AND  sty_id = p_sty_id
        AND  say_code = 'WORK'
        AND  NVL(purpose_code, '-99') = p_purpose_code
        AND  id <> p_stm_id;

    CURSOR c_last_sel (p_stm_id NUMBER) IS
      SELECT se_line_number
      FROM   okl_strm_elements
      WHERE  stm_id = p_stm_id
      ORDER BY se_line_number DESC;

    CURSOR c_sel (p_stm_id NUMBER) IS
      SELECT id
      FROM   okl_strm_elements
      WHERE  stm_id = p_stm_id
      ORDER BY stream_element_date;

    l_stm_first         NUMBER;
    l_line_num          NUMBER;
    n                   NUMBER := 0;

  BEGIN

    print( l_prog_name, 'begin' );

    FOR l_stm_count IN c_stm_count LOOP

      OPEN c_stm_first (p_kle_id => l_stm_count.kle_id, p_sty_id => l_stm_count.sty_id);
      FETCH c_stm_first INTO l_stm_first;
      CLOSE c_stm_first;

      OPEN c_last_sel (p_stm_id => l_stm_first);
      FETCH c_last_sel INTO l_line_num;
      CLOSE c_last_sel;

      FOR l_stm IN c_stm (l_stm_count.kle_id, l_stm_count.sty_id, l_stm_first) LOOP

        DELETE FROM okl_streams WHERE id = l_stm.id
         and khr_id = p_khr_id;

        FOR l_sel IN c_sel (l_stm.id) LOOP

          n := n + 1;

          UPDATE okl_strm_elements SET stm_id = l_stm_first, se_line_number = (l_line_num + n) WHERE id = l_sel.id;

        END LOOP;

      END LOOP;

    END LOOP;


    DELETE FROM OKL_STREAMS WHERE purpose_code = 'STUBS'
     and khr_id = p_khr_id;

    x_return_status := G_RET_STS_SUCCESS;
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

  END consolidate_line_streams;

  ---------------------------------------------------------------------------
  -- PROCEDURE consolidate_acc_streams
  ---------------------------------------------------------------------------
  PROCEDURE consolidate_acc_streams(p_khr_id         IN NUMBER,
                                     p_purpose_code   IN VARCHAR2,
                                     x_return_status  OUT NOCOPY VARCHAR2) IS

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'consolidate_acc_streams';

   --Modified by kthiruva on 30-May-2005
   --Bug 4374085 - Start of Changes
   -- The purpose 'SUBSIDY_INCOME' was added to the cursor
   --For Bug 4434343 - Purposes 'PASS_THRU_SVC_REV_ACCRUAL' and 'PASS_THRU_SVC_EXP_ACCRUAL'
   --added by mansrini on 10-Jun-2005 to the cursor

   --Bug 5503678 - order by clause modified by dpsingh on 18-Sep-2006
   -- Order on sty_id and not stream_Type_purpose

    CURSOR c_acc_stm IS
      SELECT ele.stream_element_date,
             ele.id element_id,
             stm.id stream_id,
             stm.kle_id kle_id,
             stm.sty_id,
             sty.stream_type_purpose stm_purpose,
             ele.amount amount
      FROM   okl_streams stm,
             okl_strm_elements ele,
	     okl_strm_type_b sty
      WHERE  stm.khr_id = p_khr_id
        AND  ele.stm_id = stm.id
        AND  stm.say_code = 'WORK'
        AND  NVL(stm.purpose_code, '-99') = p_purpose_code
	AND  sty.id = stm.sty_id
	AND  sty.stream_type_purpose in ( 'RENT_ACCRUAL','PASS_THRU_PRO_FEE_ACCRUAL',
	                   'PASS_THRU_REV_ACCRUAL', 'SERVICE_INCOME',
	                   'AMORTIZE_FEE_INCOME', 'ACCRUED_FEE_INCOME', 'LEASE_INCOME','INTEREST_INCOME',
			   'PASS_THRU_EXP_ACCRUAL', 'ACCOUNTING', 'AMORTIZED_FEE_EXPENSE','SUBSIDY_INCOME',
                           'PASS_THRU_SVC_EXP_ACCRUAL','PASS_THRU_SVC_REV_ACCRUAL')
--Added by dpsingh for consolidation to happen only for ISG streams 5949810
        AND (stm.sgn_code <> 'STMP' and stm.sgn_code <> 'STMP-REBK')
 --dpsingh 5949810 ends

    ORDER BY stm.sty_id,stm.kle_id,ele.stream_element_date;
    -- Bug 4374085 - End of Changes

    r_acc_stm c_acc_stm%ROWTYPE;


    l_stm_first         NUMBER;
    l_line_num          NUMBER;
    n                   NUMBER := 0;

    -- Added by RGOOTY
    eleid_tbl Okl_Streams_Util.NumberTabTyp;
    streamid_tbl Okl_Streams_Util.NumberTabTyp;
    sel_date Okl_Streams_Util.DateTabTyp;

    lom_date DATE;
    i   NUMBER;
    -- Added by RGOOTY: 4403311
    m   NUMBER;
    d   NUMBER;
    j   NUMBER;
    r   NUMBER;


    l_ele_id_all_tbl        Okl_Streams_Util.NumberTabTyp;
    l_streamid_all_tbl      Okl_Streams_Util.NumberTabTyp;
    l_sel_date_all_tbl      Okl_Streams_Util.DateTabTyp;
    l_kle_id_all_tbl        Okl_Streams_Util.NumberTabTyp;
    l_amt_all_tbl           Okl_Streams_Util.NumberTabTyp;
    l_stm_purpose_all_tbl   Okl_Streams_Util.Var150TabTyp;

    --Added by dpsingh for bug 5503678
    l_sty_id_all_tbl        Okl_Streams_Util.NumberTabTyp;

    l_ele_id_mod_tbl        Okl_Streams_Util.NumberTabTyp;
    l_streamid_mod_tbl      Okl_Streams_Util.NumberTabTyp;
    l_sel_date_mod_tbl      Okl_Streams_Util.DateTabTyp;
    l_kle_id_mod_tbl        Okl_Streams_Util.NumberTabTyp;
    l_amt_mod_tbl           Okl_Streams_Util.NumberTabTyp;
    l_stm_purpose_mod_tbl   Okl_Streams_Util.Var150TabTyp;

    l_ele_id_del_tbl        Okl_Streams_Util.NumberTabTyp;
    l_streamid_del_tbl      Okl_Streams_Util.NumberTabTyp;
    l_sel_date_del_tbl      Okl_Streams_Util.DateTabTyp;
    l_kle_id_del_tbl        Okl_Streams_Util.NumberTabTyp;
    l_amt_del_tbl           Okl_Streams_Util.NumberTabTyp;
    l_stm_purpose_del_tbl   Okl_Streams_Util.Var150TabTyp;

    l_sum_amount   NUMBER;
  BEGIN

--    print( l_prog_name, 'begin' );

    i := 1;
    r := 1;
    FOR l_acc_stm IN c_acc_stm
    LOOP
        lom_date := LAST_DAY(l_acc_stm.stream_element_date);
        l_sel_date_all_tbl(r)    := trunc(lom_date);
        l_streamid_all_tbl(r)    := l_acc_stm.stream_id;
        l_ele_id_all_tbl(r)      := l_acc_stm.element_id;
        l_kle_id_all_tbl(r)      := l_acc_stm.kle_id;
        l_amt_all_tbl(r)         := l_acc_stm.amount;
        l_stm_purpose_all_tbl(r) := l_acc_stm.stm_purpose;
	--Added by dpsingh for bug 5503678
           l_sty_id_all_tbl(r)      := l_acc_stm.sty_id;

        r := r + 1;
    END LOOP;

--print( l_prog_name, 'Number of accrual Stream Elements ' || l_amt_all_tbl.COUNT );
    -- Consolidation of Rental Accruals ..
    IF l_ele_id_all_tbl.count > 0
    THEN
      i := 1; -- Index to loop through all the Accrual Streams
      m := 1; -- Index for PL/SQL table for storing the modifed and updatable records only.
      d := 1; -- Index for PL/SQL table for storing the streams which have to be deleted.
      WHILE i <= l_ele_id_all_tbl.LAST
      LOOP
        l_sum_amount := l_amt_all_tbl(i);

        j := i + 1;
        WHILE j >= 2 AND
              j <= l_ele_id_all_tbl.COUNT AND
              l_kle_id_all_tbl(j)    = l_kle_id_all_tbl(i) AND
              l_sel_date_all_tbl(j)  = l_sel_date_all_tbl(i) AND
              --Modified by dpsingh for bug 5503678.
                 --Check if sty_id remains the same not purpose
                 l_sty_id_all_tbl(j) = l_sty_id_all_tbl(i)
        LOOP
          l_sum_amount := l_sum_amount + l_amt_all_tbl(j);

          -- Put the record in the to be deleted table
          l_ele_id_del_tbl(d)      := l_ele_id_all_tbl(j);
          l_streamid_del_tbl(d)    := l_streamid_all_tbl(j);
          l_sel_date_del_tbl(d)    := l_sel_date_all_tbl(j);
          l_kle_id_del_tbl(d)      := l_kle_id_all_tbl(j);
          l_amt_del_tbl(d)         := l_amt_all_tbl(j);
          l_stm_purpose_del_tbl(d) := l_stm_purpose_all_tbl(d);
          d := d + 1;

          -- Increment j, k
          j := j + 1;
        END LOOP; -- Loop on j
        -- Put the record in to be Updated Table
        l_ele_id_mod_tbl(m)      := l_ele_id_all_tbl(i);
        l_streamid_mod_tbl(m)    := l_streamid_all_tbl(i);
        l_sel_date_mod_tbl(m)    := l_sel_date_all_tbl(i);
        l_kle_id_mod_tbl(m)      := l_kle_id_all_tbl(i);
        l_amt_mod_tbl(m)         := l_sum_amount;
        l_stm_purpose_mod_tbl(d) := l_stm_purpose_all_tbl(d);
        m := m + 1;
        -- proceed to unprocessed record !!
        i := j;
      END LOOP; -- Loop on i
    END IF; -- IF l_ele_id_all_tbl.count > 0

--print( l_prog_name, 'Updateable Stream Elements ' || l_ele_id_mod_tbl.COUNT );
--print( l_prog_name, 'To be Deleted Stream Elements ' || l_ele_id_del_tbl.COUNT );

    -- Delete the Redundant Rental Accrual Stream Elements
    IF l_ele_id_del_tbl.COUNT > 0
    THEN
--print( l_prog_name, 'Deleting  ' || l_ele_id_del_tbl.COUNT   || ' Stream Elements ' );
      BEGIN
        FORALL indx in l_ele_id_del_tbl.FIRST .. l_ele_id_del_tbl.LAST
          DELETE okl_strm_elements
             WHERE id = l_ele_id_del_tbl(indx) AND
                   stm_id = l_streamid_del_tbl(indx);
      EXCEPTION
      	WHEN OTHERS THEN
	      okl_api.set_message (
	        p_app_name     => G_APP_NAME,
	        p_msg_name     => G_DB_ERROR,
	        p_token1       => G_PROG_NAME_TOKEN,
	        p_token1_value => 'consolidate_acc_streams',
	        p_token2       => G_SQLCODE_TOKEN,
	        p_token2_value => sqlcode,
	        p_token3       => G_SQLERRM_TOKEN,
	        p_token3_value => sqlerrm);
	        x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    END;
    END IF; -- IF l_ele_id_del_tbl.COUNT > 0

--print( l_prog_name, 'Deleted Redundant Stream Elements ' );

    -- Update the Rental Accrual Stream Elements
    IF l_ele_id_mod_tbl.COUNT > 0
    THEN
--print( l_prog_name, 'Modifiying  ' || l_ele_id_mod_tbl.COUNT   || ' Stream Elements ' );
      BEGIN
        FORALL indx in l_ele_id_mod_tbl.FIRST .. l_ele_id_mod_tbl.LAST
          UPDATE okl_strm_elements
             SET stream_element_date = l_sel_date_mod_tbl(indx),
                 amount = l_amt_mod_tbl(indx)
             WHERE id = l_ele_id_mod_tbl(indx) AND
                   stm_id = l_streamid_mod_tbl(indx);
      EXCEPTION
      	WHEN OTHERS THEN
	      okl_api.set_message (
	        p_app_name     => G_APP_NAME,
	        p_msg_name     => G_DB_ERROR,
	        p_token1       => G_PROG_NAME_TOKEN,
	        p_token1_value => 'consolidate_acc_streams',
	        p_token2       => G_SQLCODE_TOKEN,
	        p_token2_value => sqlcode,
	        p_token3       => G_SQLERRM_TOKEN,
	        p_token3_value => sqlerrm);
	        x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    END;
    END IF; -- IF l_ele_id_mod_tbl.COUNT > 0

    x_return_status := G_RET_STS_SUCCESS;
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

  END consolidate_acc_streams;

  ---------------------------------------------------------------------------
  -- PROCEDURE gen_non_cash_flows
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  PROCEDURE gen_non_cash_flows
                            ( p_api_version                IN         NUMBER,
                              p_init_msg_list              IN         VARCHAR2,
                              p_khr_id                     IN         NUMBER,
			      p_pre_tax_irr                IN         NUMBER,
                              p_generation_type            IN         VARCHAR2,
                              p_reporting_book_class       IN         VARCHAR2,
			      p_subsidies_yn               IN         VARCHAR2,
                              x_return_status              OUT NOCOPY VARCHAR2,
                              x_msg_count                  OUT NOCOPY NUMBER,
                              x_msg_data                   OUT NOCOPY VARCHAR2) IS

    lx_return_status              VARCHAR2(1);

    lx_isAllowed                  BOOLEAN;
    lx_passStatus                 VARCHAR2(30);
    lx_failStatus                 VARCHAR2(30);


    CURSOR c_hdr IS
      SELECT chr.template_yn,
             chr.currency_code,
             chr.start_date,
             chr.end_date,
             khr.deal_type,
             khr.term_duration,
             khr.pre_tax_irr,
             NVL(khr.generate_accrual_yn, 'Y')
      FROM   okc_k_headers_b chr,
             okl_k_headers khr
      WHERE  khr.id = p_khr_id
        AND  chr.id = khr.id;

    cursor l_line_csr( chrid NUMBER, lnetype VARCHAR2 ) is
    select kle.id,
           kle.oec,
           kle.residual_code,
           kle.capital_amount,
           kle.delivered_date,
           kle.date_funding_required,
           kle.residual_grnty_amount,
           kle.date_funding,
           kle.residual_value,
           kle.amount,
           kle.price_negotiated,
           kle.start_date,
           kle.end_date,
           kle.orig_system_id1,
           kle.fee_type,
           kle.initial_direct_cost,
           kle.capital_reduction,
           kle.capital_reduction_percent,
           NVL(kle.capitalize_down_payment_yn, 'N') capitalize_down_payment_yn
        /*   ,tl.item_description,
           tl.name  */
     from  okl_k_lines_full_v kle,
           okc_line_styles_b lse,
--           okc_k_lines_tl tl,
	   okc_statuses_b sts
     where KLE.LSE_ID = LSE.ID
          and lse.lty_code = lnetype
--	  and tl.id = kle.id
--          and tl.language = userenv('LANG')
          and kle.dnz_chr_id = chrid
	  and sts.code = kle.sts_code
	  and sts.ste_code not in ('HOLD', 'EXPIRED', 'CANCELLED');

     l_line_rec l_line_csr%ROWTYPE;

    l_hdr                    c_hdr%ROWTYPE;
    l_deal_type              VARCHAR2(30);
    l_purpose_code           VARCHAR2(30);

    l_sty_id                 NUMBER;
    l_sty_name               VARCHAR2(150);
    l_mapped_sty_name        VARCHAR2(150);

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_tmp_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_pt_tbl                 okl_streams_pub.selv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    l_pt_rec                 okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

    l_capital_cost           NUMBER;

    i                        BINARY_INTEGER := 0;
    j                        BINARY_INTEGER := 0;


    Cursor c_rollover_pmnts( chrId NUMBER, kleId NUMBER ) IS
    Select nvl(slh.object1_id1, -1) styId
    From   OKC_RULE_GROUPS_B rgp,
           OKC_RULES_B sll,
           okc_rules_b slh,
	   okl_strm_type_b sty
    Where  slh.rgp_id = rgp.id
       and rgp.RGD_CODE = 'LALEVL'
       and sll.RULE_INFORMATION_CATEGORY = 'LASLL'
       and slh.RULE_INFORMATION_CATEGORY = 'LASLH'
       AND TO_CHAR(slh.id) = sll.object2_id1
       and rgp.dnz_chr_id = chrId
       and rgp.cle_id = kleId
       and sty.id = to_number(slh.object1_id1)
       and sty.stream_type_purpose NOT IN ('ESTIMATED_PROPERTY_TAX', 'UNSCHEDULED_PRINCIPAL_PAYMENT', 'DOWN_PAYMENT');
       --Added DOWN_PAYMENT by rgooty for bug 7536131
       --bug# 4092324 bug# 4122385

    r_rollover_pmnts c_rollover_pmnts%ROWTYPE;

    CURSOR c_inflows( khrId NUMBER, kleId NUMBER) IS
    SELECT rul2.object1_id1 frequency,
           DECODE(rul2.rule_information10, 'Y', 'ARREARS', 'ADVANCE') advance_arrears
    FROM   okc_rule_groups_b rgp,
           okc_rules_b rul1,
           okc_rules_b rul2,
           okc_k_lines_b cle,
           okl_k_lines kle,
           okc_line_styles_b lse,
	   okl_strm_type_b sty
    WHERE  rul1.rgp_id= rgp.id
      ANd  rgp.rgd_code = 'LALEVL'
      AND  rul2.rule_information_category = 'LASLL'
      and  rul1.RULE_INFORMATION_CATEGORY = 'LASLH'
      AND  TO_NUMBER(rul2.object2_id1) = rul1.id
      AND  rul2.rgp_id = rgp.id
      AND  rgp.dnz_chr_id = khrid
      AND  rgp.cle_id = kleid
      AND  cle.id = rgp.cle_id
      AND  cle.sts_code IN ('PASSED', 'COMPLETE')
      AND  cle.id = kle.id
      AND  cle.lse_id = lse.id
      and  sty.id = to_number(rul1.object1_id1)
      and sty.stream_type_purpose NOT IN ('ESTIMATED_PROPERTY_TAX', 'UNSCHEDULED_PRINCIPAL_PAYMENT' );
       --bug# 4092324 bug# 4122385

    r_inflows c_inflows%ROWTYPE;

    l_asbv_tbl  OKL_SUBSIDY_PROCESS_PVT.asbv_tbl_type;
    l_first_sel_date DATE;
    l_months_factor  NUMBER;
    l_end_date       DATE;

    l_primary_sty_id NUMBER;

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'gen_non_cash_flows';

    Cursor c_subsidy_strm ( styId NUMBER ) IS
    Select to_number(Value)
    from okl_sgn_translations
    where jtot_object1_code = 'OKL_STRMTYP'
      and object1_id1 = to_char( styId );

    Cursor c_strm_name ( styId NUMBER ) IS
    Select name
    from okl_strm_type_tl
    where language = 'US'
     and id = styId;

    l_subsidy_stream VARCHAR2(256);
    l_accrual_sty_id NUMBER;

    CURSOR c_inflows_line ( khrId NUMBER, kleId NUMBER, pCode VARCHAR2 ) IS
      SELECT DISTINCT
             sel.id id,
             sel.amount cf_amount,
             sel.stream_element_date cf_date,
             sel.comments cf_arrear,
             sty.stream_type_purpose cf_purpose,
             sll.object1_id1 cf_frequency,
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
      WHERE  stm.khr_id = khrId
        AND  stm.kle_id = kleId
        AND  stm.say_code = 'WORK'
        AND  nvl(stm.purpose_code, '-99') = pCode
        AND  stm.sty_id = sty.id
        AND  stm.id = sel.stm_id
	AND  sty.stream_type_purpose IN ( 'RENT', 'LOAN_PAYMENT')
        AND  sel.comments IS NOT NULL
        AND  stm.kle_id = cle.id
        AND  NOT EXISTS (SELECT 1
                         FROM   okc_rule_groups_b rgp2
                         WHERE  rgp2.dnz_chr_id = khrId
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
        AND  sll.rule_information_category = 'LASLL'
        AND  cle.id = kleid;

    r_inflows_line c_inflows_line%ROWTYPE;
    TYPE r_inflow_line_tbl_type is table of c_inflows_line%ROWTYPE
      INDEX BY BINARY_INTEGER;
    r_inflow_line_tbl r_inflow_line_tbl_type;
    l_pv_date DATE;
    l_pv_amount NUMBER;
    x_pv_amount NUMBER;

    P_FIRST VARCHAR2(1);
    L NUMBER := 0;

    -- Added by RGOOTY : Start
    l_rv_sty_id              NUMBER;
    l_rv_sty_name            VARCHAR2(150);

    l_capred_sty_id              NUMBER;
    l_capred_sty_name            VARCHAR2(150);

    -- Added by RGOOTY : End
    -- Added by RGOOTY for perf.: Bug Number 4346646 Start
    l_stmv_tbl              Okl_Streams_Pub.stmv_tbl_type;
    l_full_selv_tbl         Okl_Streams_Pub.selv_tbl_type;

    lx_stmv_tbl              Okl_Streams_Pub.stmv_tbl_type;
    lx_full_selv_tbl         Okl_Streams_Pub.selv_tbl_type;
    -- Added by RGOOTY for perf.: End

-- djanaswa ER6274342 start
    l_arrears_pay_dates_option  okl_st_gen_tmpt_sets_all.isg_arrears_pay_dates_option%type;
-- djanaswa ER6274342 end

  BEGIN

    -- print( l_prog_name, 'begin' );
    OPEN  c_hdr;
    FETCH c_hdr INTO l_hdr;
    CLOSE c_hdr;

    IF p_reporting_book_class IS NOT NULL THEN
      l_deal_type    :=  p_reporting_book_class;
      l_purpose_code := 'REPORT';
    ELSE
      l_deal_type    :=  l_hdr.deal_type;
      l_purpose_code := '-99';
    END IF;

    OKL_ISG_UTILS_PVT.get_primary_stream_type(
            p_khr_id              => p_khr_id,
	    p_deal_type           => l_deal_type,
            p_primary_sty_purpose => 'RESIDUAL_VALUE',
            x_return_status       => lx_return_status,
            x_primary_sty_id      => l_rv_sty_id,
            x_primary_sty_name    => l_rv_sty_name);

-- djanaswa ER6274342 start

   IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   OKL_ISG_UTILS_PVT.get_arrears_pay_dates_option(
        p_khr_id                   => p_khr_id,
        x_arrears_pay_dates_option => l_arrears_pay_dates_option,
        x_return_status            => lx_return_status);

       IF(lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (lx_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

-- djanaswa ER6274342 end

    --   print( l_prog_name, ' generating streams - begin');
    -- Added by RGOOTY: Start
    IF ( p_generation_type <> 'SERVICE_LINES' )
    THEN
      FOR l_line_rec in l_line_csr( p_khr_id, 'FREE_FORM1' )
      LOOP
        -- Residual Value Streams are getting generated here ....
        IF ( (p_generation_type = 'FULL' OR p_generation_type = 'RESIDUAL VALUE') ) AND
             ( nvl(l_line_rec.residual_value, 0) > 0 )
        THEN

            l_selv_tbl.delete;
            -- Moving the execution of the RV Stream out of loop
            IF ( l_rv_sty_id IS NOT NULL ) THEN
               get_stream_header(
                          p_khr_id         =>   p_khr_id,
                          p_kle_id         =>   l_line_rec.id,
                          p_sty_id         =>   l_rv_sty_id,
                          p_purpose_code   =>   l_purpose_code,
                          x_stmv_rec       =>   l_stmv_rec,
                          x_return_status  =>   lx_return_status);

               IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               l_selv_tbl(1).amount                     := l_line_rec.residual_value;
               l_selv_tbl(1).stream_element_date        := l_hdr.end_date;
               l_selv_tbl(1).se_line_number             := 1;
               l_selv_tbl(1).accrued_yn                 := NULL;

               lx_return_status := Okl_Streams_Util.round_streams_amount_esg(
	                                p_api_version   => g_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_chr_id        => p_khr_id,
                                        p_selv_tbl      => l_selv_tbl,
                                        x_selv_tbl      => lx_selv_tbl,
                                        p_org_id        => G_ORG_ID,
                                        p_precision     => G_PRECISION,
                                        p_currency_code => G_CURRENCY_CODE,
                                        p_rounding_rule => G_ROUNDING_RULE,
                                        p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

               IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
               l_selv_tbl.DELETE;
               l_selv_tbl := lx_selv_tbl;
               --Accumulate Stream Header: 4346646
               OKL_STREAMS_UTIL.accumulate_strm_headers(
                 p_stmv_rec       => l_stmv_rec,
                 x_full_stmv_tbl  => l_stmv_tbl,
                 x_return_status  => lx_return_status );
               IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
               --Accumulate Stream Elements
               OKL_STREAMS_UTIL.accumulate_strm_elements(
                 p_stm_index_no  =>  l_stmv_tbl.LAST,
                 p_selv_tbl       => l_selv_tbl,
                 x_full_selv_tbl  => l_full_selv_tbl,
                 x_return_status  => lx_return_status );
               IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
               l_stmv_rec := NULL;
               l_selv_tbl.delete;
               lx_stmv_rec := NULL;
               lx_selv_tbl.delete;
          END IF;
        END IF;

        -- Capital Reduction Streams are getting generated here ....
        IF ( l_line_rec.capitalize_down_payment_yn = 'Y' AND
             ( nvl(l_line_rec.capital_reduction, l_line_rec.capital_reduction_percent) > 0 ) ) AND
           (p_generation_type = 'FULL' OR p_generation_type = 'CAPITAL REDUCTION')
        THEN
            OKL_ISG_UTILS_PVT.get_primary_stream_type(
              p_khr_id              => p_khr_id,
              p_deal_type           => l_deal_type,
              p_primary_sty_purpose => 'CAPITAL_REDUCTION',
              x_return_status       => lx_return_status,
              x_primary_sty_id      => l_capred_sty_id,
              x_primary_sty_name    => l_capred_sty_name);
            IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_selv_tbl.delete;
            IF ( l_capred_sty_id IS NOT NULL ) THEN
               get_stream_header(
                          p_khr_id         =>   p_khr_id,
                          p_kle_id         =>   l_line_rec.id,
                          p_sty_id         =>   l_capred_sty_id,
                          p_purpose_code   =>   l_purpose_code,
                          x_stmv_rec       =>   l_stmv_rec,
                          x_return_status  =>   lx_return_status);

               IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               IF (l_line_rec.capital_reduction IS NULL ) Then
                 l_selv_tbl(1).amount                     := l_line_rec.oec * l_line_rec.capital_reduction_percent * 0.01;
               Else
                 l_selv_tbl(1).amount                     := l_line_rec.capital_reduction;
               END IF;

               l_selv_tbl(1).stream_element_date        := l_hdr.start_date;
               l_selv_tbl(1).se_line_number             := 1;
               l_selv_tbl(1).accrued_yn                 := NULL;

               lx_return_status := Okl_Streams_Util.round_streams_amount_esg(
	                                p_api_version   => g_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_chr_id        => p_khr_id,
                                        p_selv_tbl      => l_selv_tbl,
                                        x_selv_tbl      => lx_selv_tbl,
                                        p_org_id        => G_ORG_ID,
                                        p_precision     => G_PRECISION,
                                        p_currency_code => G_CURRENCY_CODE,
                                        p_rounding_rule => G_ROUNDING_RULE,
                                        p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

               IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               l_selv_tbl.DELETE;
               l_selv_tbl := lx_selv_tbl;

               --Accumulate Stream Header: 4346646
               OKL_STREAMS_UTIL.accumulate_strm_headers(
                 p_stmv_rec       => l_stmv_rec,
                 x_full_stmv_tbl  => l_stmv_tbl,
                 x_return_status  => lx_return_status );
               IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               --Accumulate Stream Elements
               OKL_STREAMS_UTIL.accumulate_strm_elements(
                 p_stm_index_no  =>  l_stmv_tbl.LAST,
                 p_selv_tbl       => l_selv_tbl,
                 x_full_selv_tbl  => l_full_selv_tbl,
                 x_return_status  => lx_return_status );
               IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               l_stmv_rec := NULL;
               l_selv_tbl.delete;
               lx_stmv_rec := NULL;
               lx_selv_tbl.delete;
          END IF;

        END IF;

        IF (p_generation_type = 'FULL' OR p_generation_type = 'SUBSIDY') AND ( p_subsidies_yn = 'Y' ) THEN

            OKL_SUBSIDY_PROCESS_PVT.get_asset_subsidy_amount(
                                       p_api_version     =>   G_API_VERSION,
                                       p_init_msg_list   =>   G_FALSE,
                                       p_asset_cle_id    =>   l_line_rec.id,
                                       x_return_status   =>   lx_return_status,
                                       x_msg_count       =>   x_msg_count,
                                       x_msg_data        =>   x_msg_data,
                                       x_asbv_tbl        =>   l_asbv_tbl);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            print( l_prog_name, ' count ' || to_char(l_asbv_tbl.count));



        FOR i in 1..l_asbv_tbl.COUNT
	    LOOP
                --print( l_prog_name, ' method ' || l_asbv_tbl(i).accounting_method_code);

                If ( l_asbv_tbl(i).accounting_method_code = 'AMORTIZE' )
                THEN
	               l_end_date := l_hdr.end_date;
	               IF ( l_asbv_tbl(i).maximum_term < l_hdr.term_duration )
                   THEN
                        OPEN c_inflows( p_khr_id, l_line_rec.id);
                        FETCH c_inflows INTO r_inflows;
                        CLOSE c_inflows;
                        l_months_factor := get_months_factor(
                                                p_frequency     => r_inflows.frequency,
                                                x_return_status => lx_return_status );

                        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;

-- djanaswa ER6274342 added parameter p_arrears_pay_dates_option

                        l_first_sel_date := get_first_sel_date( p_start_date          => l_hdr.start_date,
                                                                p_advance_or_arrears  => r_inflows.advance_arrears,
                                                                p_months_increment    => l_months_factor,
                                                                p_arrears_pay_dates_option => l_arrears_pay_dates_option,
                                                                x_return_status       => lx_return_status );

                        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;
                        l_end_date := ADD_MONTHS(l_first_sel_date,
                                            l_months_factor*(l_asbv_tbl(i).maximum_term-1));

		    End If;

	            get_amortized_accruals (
		                     p_khr_id         => p_khr_id,
	                             p_currency_code  => l_hdr.currency_code,
                                     p_start_date     => l_line_rec.start_date,
				     p_end_date       => l_end_date,
                                     p_deal_type      => l_hdr.deal_type,
				     p_amount         => l_asbv_tbl(i).amount,
                                     x_selv_tbl       => l_selv_tbl,
                                     x_return_status  => lx_return_status);

                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
	            END IF;

		ElsIf (l_asbv_tbl(i).accounting_method_code = 'NET' ) Then

                    get_accrual_elements (
		                p_start_date          =>   l_hdr.start_date,
                                p_periods             =>   1,
                                p_frequency           =>   'M',
                                p_structure           =>   0,
                                p_advance_or_arrears  =>   'ARREARS',
                                p_amount              =>   l_asbv_tbl(i).amount,
				p_stub_days           =>   NULL,
				p_stub_amount         =>   NULL,
                                p_currency_code       =>   l_hdr.currency_code,
                                x_selv_tbl            =>   l_selv_tbl,
                                x_return_status       =>   lx_return_status);

                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    -- bug# 3330636
		    l_tmp_selv_tbl := l_selv_tbl;
		    l_selv_tbl.DELETE;
		    l_selv_tbl(1) := l_tmp_selv_tbl(1);
		    l_selv_tbl(1).amount := l_asbv_tbl(i).amount;
		    l_tmp_selv_tbl.DELETE;

		End If;

                -- get the accrual stream type;
		/*

		OPEN c_subsidy_strm ( l_asbv_tbl(i).stream_type_id );
		FETCH c_subsidy_strm INTO l_accrual_sty_id;


		IF ( c_subsidy_strm%NOTFOUND ) THen

		    OPEN c_strm_name ( l_asbv_tbl(i).stream_type_id );
		    FETCH c_strm_name INTO l_subsidy_stream;
		    CLOSE c_strm_name;

                    OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                         p_msg_name     => 'OKL_NO_SUBSIDY_MAP',
                                         p_token1       => 'SUBS',
                                         p_token1_value => l_subsidy_stream);

		    CLOSE c_subsidy_strm;
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

	        END IF;
		CLOSE c_subsidy_strm;

		*/

                -- bug# 4041666
                OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                        p_khr_id  		=> p_khr_id,
			p_deal_type             => l_deal_type,
			p_primary_sty_id        => l_asbv_tbl(i).stream_type_id,
                        p_dependent_sty_purpose => 'SUBSIDY_INCOME',
                        x_return_status         => lx_return_status,
                        x_dependent_sty_id      => l_accrual_sty_id,
                        x_dependent_sty_name    => l_sty_name);

             If ( l_accrual_sty_id is not null ) Then

                get_stream_header(p_khr_id         =>   p_khr_id,
                                  p_kle_id         =>   l_line_rec.id,
                                  p_sty_id         =>   l_accrual_sty_id,
                                  p_purpose_code   =>   l_purpose_code,
                                  x_stmv_rec       =>   l_stmv_rec,
                                  x_return_status  =>   lx_return_status);

                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;


               lx_return_status := Okl_Streams_Util.round_streams_amount_esg(
	                                p_api_version   => g_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_chr_id        => p_khr_id,
                                        p_selv_tbl      => l_selv_tbl,
                                        x_selv_tbl      => lx_selv_tbl,
                                        p_org_id        => G_ORG_ID,
                                        p_precision     => G_PRECISION,
                                        p_currency_code => G_CURRENCY_CODE,
                                        p_rounding_rule => G_ROUNDING_RULE,
                                        p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

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
                                               x_msg_count       =>   x_msg_count,
                                               x_msg_data        =>   x_msg_data,
                                               p_stmv_rec        =>   l_stmv_rec,
                                               p_selv_tbl        =>   l_selv_tbl,
                                               x_stmv_rec        =>   lx_stmv_rec,
                                               x_selv_tbl        =>   lx_selv_tbl);

                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                l_selv_tbl.delete;

	     End If;

	    END LOOP;

	    l_asbv_tbl.delete;

	End If;

        IF (p_generation_type = 'FULL' ) AND (l_purpose_code = '-99' ) THEN


            OPEN c_rollover_pmnts( p_khr_id, l_line_rec.id);
            FETCH c_rollover_pmnts INTO r_rollover_pmnts;
            CLOSE c_rollover_pmnts;


	    l_primary_sty_id := r_rollover_pmnts.styId;

            OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                        p_khr_id  		=> p_khr_id,
			p_deal_type           => l_deal_type,
			p_primary_sty_id        => l_primary_sty_id,
                        p_dependent_sty_purpose => 'PV_RENT',
                        x_return_status         => lx_return_status,
                        x_dependent_sty_id      => l_sty_id,
                        x_dependent_sty_name    => l_sty_name);


        IF ( l_sty_id is not null ) THEN

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            get_stream_header(p_khr_id   =>   p_khr_id,
                        p_kle_id         =>   l_line_rec.id,
                        p_sty_id         =>   l_sty_id,
                        p_purpose_code   =>   l_purpose_code,
                        x_stmv_rec       =>   l_stmv_rec,
                        x_return_status  =>   lx_return_status);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_selv_tbl.delete;


             P_FIRST := 'T';
             L := 0;
	         i := 0;

            r_inflow_line_tbl.delete;
            For r_inflows_line_rec in c_inflows_line( p_khr_id, l_line_rec.id, l_purpose_code )
            LOOP
               i := i + 1;
               r_inflow_line_tbl(i) := r_inflows_line_rec;
            END LOOP;
            i := 1;

          FOR i IN r_inflow_line_tbl.first .. r_inflow_line_tbl.last
          LOOP
    	        l_pv_date := r_inflow_line_tbl(i).cf_date;
    	        l_pv_amount := 0;

              FOR L IN r_inflow_line_tbl.first .. r_inflow_line_tbl.last
              LOOP
                 IF trunc(r_inflow_line_tbl(l).cf_date) >= trunc(l_pv_date)
                 THEN

                    get_present_value( p_api_version   =>   G_API_VERSION,
    				        p_init_msg_list =>   G_FALSE,
    				        p_amount_date   =>   r_inflow_line_tbl(l).cf_date,
    				        p_amount        =>   r_inflow_line_tbl(l).cf_amount,
    				        p_frequency     =>   r_inflow_line_tbl(l).cf_frequency,
    				        p_rate          =>   p_pre_tax_irr,
                                        p_pv_date       =>   l_pv_date,
    				        x_pv_amount     =>   x_pv_amount,
                                        x_return_status =>   lx_return_status,
                            x_msg_count     =>   x_msg_count,
                            x_msg_data      =>   x_msg_data);

                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                    l_pv_amount := l_pv_amount + x_pv_amount;
                END IF;
            END LOOP;

    	    l_selv_tbl(i).stream_element_date := l_pv_date;
            l_selv_tbl(i).amount := l_pv_amount;

            l_selv_tbl(i).se_line_number := i;
    		l_selv_tbl(i).accrued_yn := NULL;
            l_selv_tbl(i).comments   := r_inflow_line_tbl(i).cf_arrear;
	    END LOOP;


            lx_return_status := Okl_Streams_Util.round_streams_amount_esg(
                                p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => p_khr_id,
                                p_selv_tbl      => l_selv_tbl,
                                x_selv_tbl      => lx_selv_tbl,
                                p_org_id        => G_ORG_ID,
                                p_precision     => G_PRECISION,
                                p_currency_code => G_CURRENCY_CODE,
                                p_rounding_rule => G_ROUNDING_RULE,
                                p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_selv_tbl.DELETE;
            l_selv_tbl := lx_selv_tbl;

            okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                           p_init_msg_list   =>   G_FALSE,
                                           x_return_status   =>   lx_return_status,
                                           x_msg_count       =>   x_msg_count,
                                           x_msg_data        =>   x_msg_data,
                                           p_stmv_rec        =>   l_stmv_rec,
                                           p_selv_tbl        =>   l_selv_tbl,
                                           x_stmv_rec        =>   lx_stmv_rec,
                                           x_selv_tbl        =>   lx_selv_tbl);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
	  END IF;

        END IF;
     END LOOP;
         --Create all the accumulated Streams at one shot ..
         IF l_stmv_tbl.COUNT > 0 AND
            l_full_selv_tbl.COUNT > 0
         THEN
Okl_Streams_Pub.create_streams_perf(
                               p_api_version,
                               p_init_msg_list,
                               lx_return_status,
                               x_msg_count,
                               x_msg_data,
                               l_stmv_tbl,
                               l_full_selv_tbl,
                               lx_stmv_tbl,
                               lx_full_selv_tbl);

           IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         END IF;

       END IF;
       x_return_status := OKL_API.G_RET_STS_SUCCESS;

       -- Added by RGOOTY: End
       --    print( l_prog_name, 'end');

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

  END  gen_non_cash_flows;


  ---------------------------------------------------------------------------
  -- PROCEDURE generate_cash_flows
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  PROCEDURE generate_cash_flows(
                             p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2,
                             p_khr_id        IN  NUMBER,
			     p_kle_id        IN  NUMBER,
			     p_sty_id        IN  NUMBER,
			     p_payment_tbl   IN  payment_tbl_type,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             x_payment_count OUT NOCOPY BINARY_INTEGER) IS

    lx_return_status              VARCHAR2(1);

    lx_isAllowed                  BOOLEAN;
    lx_passStatus                 VARCHAR2(30);
    lx_failStatus                 VARCHAR2(30);

    CURSOR c_hdr IS
      SELECT chr.template_yn,
             chr.currency_code,
             chr.start_date,
             khr.deal_type,
             khr.term_duration,
             NVL(khr.generate_accrual_yn, 'Y')
      FROM   okc_k_headers_b chr,
             okl_k_headers khr
      WHERE  khr.id = p_khr_id
        AND  chr.id = khr.id;

    l_hdr                    c_hdr%ROWTYPE;
    l_deal_type              VARCHAR2(30);
    l_purpose_code           VARCHAR2(30) := 'FLOW';

    l_pt_yn                  VARCHAR2(1);
    l_passthrough_id         NUMBER;

    l_sty_id                 NUMBER;
    l_sty_name               VARCHAR2(150);
    l_mapped_sty_name        VARCHAR2(150);

    l_pre_tax_inc_id         NUMBER;
    l_principal_id           NUMBER;
    l_interest_id            NUMBER;
    l_prin_bal_id            NUMBER;
    l_termination_id         NUMBER;

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_pt_tbl                 okl_streams_pub.selv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    l_pt_rec                 okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

    i                        BINARY_INTEGER := 0;
    j                        BINARY_INTEGER := 0;
    l_ele_count              BINARY_INTEGER := 0;

    l_adv_arr                VARCHAR2(30);



    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'generate_cash_flows';
    l_se_id NUMBER;

    --Added by djanaswa for bug 6007644
    l_recurrence_date    DATE := NULL;
    --end djanaswa

  BEGIN

    -- print( l_prog_name, 'begin' );
    -- c_hdr cursor fetches the contract/quote details
    OPEN  c_hdr;
    FETCH c_hdr INTO l_hdr;
    CLOSE c_hdr;

    l_deal_type := l_hdr.deal_type;
    -- Generates a Stub Element and returns the id of the
    -- new Stream Created into x_se_id
    generate_stub_element( p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           p_khr_id        => p_khr_id,
			               p_deal_type     => l_deal_type,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_se_id         => l_se_id );
    --print( l_prog_name, 'stub', x_return_status );
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    ---------------------------------------------
    -- STEP 1: Spread cash INFLOW
    ---------------------------------------------
    --print( l_prog_name, ' generating streams - begin');
    get_stream_header(
        p_khr_id         =>   p_khr_id,
        p_kle_id         =>   p_kle_id,  -- p_kle_id is passed to generate_cash_flows
        p_sty_id         =>   p_sty_id,  -- p_sty_id is passed
        p_purpose_code   =>   l_purpose_code, -- 'FLOW'
        x_stmv_rec       =>   l_stmv_rec,
        x_return_status  =>   lx_return_status);
    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_stmv_rec.purpose_code := 'FLOW';
    -- Proceed with Creating the RENT Stream Header
okl_streams_pub.create_streams(
        p_api_version     =>   G_API_VERSION,
        p_init_msg_list   =>   G_FALSE,
        x_return_status   =>   lx_return_status,
        x_msg_count       =>   x_msg_count,
        x_msg_data        =>   x_msg_data,
        p_stmv_rec        =>   l_stmv_rec,
        x_stmv_rec        =>   lx_stmv_rec);
    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --print( l_prog_name, 'created header' );
    x_payment_count  :=  0;
    l_ele_count := 0;
    -- Creating Stream lines based on the Payments Received ...
    -- p_payment_tbl will be having the information similiar to rules..
    FOR i IN p_payment_tbl.FIRST..p_payment_tbl.LAST
    LOOP
        IF p_payment_tbl(i).start_date IS NULL
        THEN
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_NO_SLL_SDATE');
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
        /*
         * calculate stream elements for each payment level
         * also means that if there are multiple payment levels for an asset, streams are
         * calculated at different points.
         * the streams amounts are they are entered in payments. In case of passthru, a
         * new set of streams are created with amounts that are passthru'ed - l_pt_tbl.
         */
        IF ( p_payment_tbl(i).arrears_yn = 'Y' )
        THEN
            l_adv_arr := 'ARREARS';
	    ELSE
            l_adv_arr := 'ADVANCE';
	    End If;

       --Added by djanaswa for bug 6007644
        IF((p_payment_tbl(i).periods IS NULL) AND (p_payment_tbl(i).stub_days IS NOT NULL)) THEN
          --Set the recurrence date to null for stub payment
          l_recurrence_date := NULL;
        ELSIF(l_recurrence_date IS NULL) THEN
          --Set the recurrence date as Periodic payment level start date
          l_recurrence_date := p_payment_tbl(i).start_date;
        END IF;
        --end djanaswa

        --print( l_prog_name, 'start date ' || p_payment_tbl(i).start_date );
        -- get_stream_elements create the Stream elements records based on the
        -- payments scheduled.
        --Added parameter p_recurrence_date by djanaswa for bug 6007644
        get_stream_elements(
            p_start_date          =>   p_payment_tbl(i).start_date,
            p_periods             =>   p_payment_tbl(i).periods,
            p_frequency           =>   p_payment_tbl(i).frequency,
            p_structure           =>   p_payment_tbl(i).structure,
            p_advance_or_arrears  =>   l_adv_arr,
            p_amount              =>   p_payment_tbl(i).amount,
            p_stub_days           =>   p_payment_tbl(i).stub_days,
            p_stub_amount         =>   p_payment_tbl(i).stub_amount,
            p_currency_code       =>   l_hdr.currency_code,
            p_khr_id              =>   p_khr_id,
            p_kle_id              =>   p_kle_id,
            p_purpose_code        =>   l_purpose_code,
            x_selv_tbl            =>   l_selv_tbl,
            x_pt_tbl              =>   l_pt_tbl,
            x_return_status       =>   lx_return_status,
            x_msg_count           =>   x_msg_count,
            x_msg_data            =>   x_msg_data,
            p_recurrence_date     =>   l_recurrence_date);
        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --print( l_prog_name, 'created elements ' || to_char(l_selv_tbl.COUNT) );
        FOR j in 1..l_selv_tbl.COUNT
        LOOP
    	    l_ele_count := l_ele_count + 1;
    	    l_selv_tbl(j).stm_id := lx_stmv_rec.id;
    	    l_selv_tbl(j).se_line_number := l_ele_count;
    	    l_selv_tbl(j).id := NULL;
        END LOOP;

        -- Case of Stub days is given
        IF ( p_payment_tbl(i).stub_days IS NOT NULL ) AND ( p_payment_tbl(i).periods IS NULL )
        THEN
    	    FOR i in 1..l_selv_tbl.COUNT
    	    LOOP
    	        l_selv_tbl(i).sel_id := l_se_id;
    	    END LOOP;

    	    FOR i in 1..l_pt_tbl.COUNT
    	    LOOP
    	        l_pt_tbl(i).sel_id := l_se_id;
    	    END LOOP;
    	END IF;
        --print( l_prog_name, 'start date ' || l_selv_tbl(1).stream_element_date );
        -- Create the Stream Elements in the OKL_STRM_ELEMENTS table
        -- feels like the join between stream header and stream elements here is
        -- sel_id, we are populating it in the above for loop.
okl_streams_pub.create_stream_elements(
	                               p_api_version     =>   G_API_VERSION,
                                   p_init_msg_list   =>   G_FALSE,
                                   x_return_status   =>   lx_return_status,
                                   x_msg_count       =>   x_msg_count,
                                   x_msg_data        =>   x_msg_data,
                                   p_selv_tbl        =>   l_selv_tbl,
                                   x_selv_tbl        =>   lx_selv_tbl);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --print( l_prog_name, 'created elements ' || to_char(l_ele_count) );
        -- Deleting the Stream Elements for next iteration.
        l_selv_tbl.DELETE;

        FOR j in 1..lx_selv_tbl.COUNT
        LOOP
    	    l_ele_count := l_ele_count + 1;
    	    l_selv_tbl(j) := lx_selv_tbl(j);
    	    -- If Payment rate is not present, then initialize the amount with -999999
    	    l_selv_tbl(j).amount := nvl(p_payment_tbl(i).rate, -9999999);
    	    l_selv_tbl(j).sel_id := lx_selv_tbl(j).id;
    	    l_selv_tbl(j).se_line_number := l_ele_count;
    	    l_selv_tbl(j).id := NULL;
    	    -- Store in stream elements comments whether that represents the
    	    -- missing payments or not.
    	    IF ( lx_selv_tbl(j).amount = -9999999 )
            THEN
	           l_selv_tbl(j).comments := 'Y';
            ELSE
	           l_selv_tbl(j).comments := 'N';
	       END IF;
        END LOOP;
        lx_selv_tbl.DELETE;
        -- Create/Update Stream Elements with the above modification.
okl_streams_pub.create_stream_elements(
	                               p_api_version     =>   G_API_VERSION,
                                   p_init_msg_list   =>   G_FALSE,
                                   x_return_status   =>   lx_return_status,
                                   x_msg_count       =>   x_msg_count,
                                   x_msg_data        =>   x_msg_data,
                                   p_selv_tbl        =>   l_selv_tbl,
                                   x_selv_tbl        =>   lx_selv_tbl);
        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        --print( l_prog_name, 'created elements rates ' || to_char(l_ele_count) );
        --print( l_prog_name, ' pass thru count ' || to_char(l_pt_tbl.COUNT) );

        -- Code for handling Passthroughs Follows
        IF l_pt_tbl.COUNT > 0
        THEN
          IF l_passthrough_id IS NULL
          THEN
                OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                    p_khr_id                => p_khr_id,
                                    p_deal_type             => l_deal_type,
                                    p_dependent_sty_purpose => 'PASS_THRU_EXP_ACCRUAL',
                                    x_return_status         => lx_return_status,
                                    x_dependent_sty_id      => l_passthrough_id,
                                    x_dependent_sty_name    => l_sty_name);
                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
            END IF;
            IF l_passthrough_id IS NOT NULL
            THEN
                get_stream_header(p_khr_id         =>   p_khr_id,
                            p_kle_id         =>   p_kle_id,
                            p_sty_id         =>   l_passthrough_id,
                            p_purpose_code   =>   l_purpose_code,
                            x_stmv_rec       =>   l_pt_rec,
                            x_return_status  =>   lx_return_status);

                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                l_pt_rec.purpose_code := 'PLOW';
                lx_return_status := Okl_Streams_Util.round_streams_amount(
                              p_api_version   => g_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_chr_id        => p_khr_id,
                              p_selv_tbl      => l_pt_tbl,
                              x_selv_tbl      => lx_selv_tbl);

                IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                l_pt_tbl.DELETE;
                l_pt_tbl := lx_selv_tbl;
                -- Create additional Pass Through Streams
okl_streams_pub.create_streams(
                            p_api_version     =>   G_API_VERSION,
                            p_init_msg_list   =>   G_FALSE,
                            x_return_status   =>   lx_return_status,
                            x_msg_count       =>   x_msg_count,
                            x_msg_data        =>   x_msg_data,
                            p_stmv_rec        =>   l_pt_rec,
                            p_selv_tbl        =>   l_pt_tbl,
                            x_stmv_rec        =>   lx_stmv_rec,
                            x_selv_tbl        =>   lx_selv_tbl);

                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
            END IF;
        END IF;
        -- Clear out reusable data structures
        l_pt_rec := NULL;
        l_selv_tbl.delete;
        l_pt_tbl.delete;
        lx_selv_tbl.delete;
        x_payment_count  :=  x_payment_count + 1;
        --print( l_prog_name, ' payment count ' || to_char(x_payment_count) );
    END LOOP;
    --print( l_prog_name, ' done ' );
    l_sty_name  :=  NULL;
    l_sty_id    :=  NULL;
    l_stmv_rec := NULL;
    lx_stmv_rec := NULL;
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

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END generate_cash_flows;

  ---------------------------------------------------------------------------
  -- PROCEDURE generate_cash_flows
  ---------------------------------------------------------------------------
  -- Added output parameter x_se_id by prasjain for bug 5474827
  ---------------------------------------------------------------------------
  PROCEDURE generate_cash_flows
                            ( p_api_version                IN         NUMBER,
                              p_init_msg_list              IN         VARCHAR2,
                              p_khr_id                     IN         NUMBER,
                              p_generation_type            IN         VARCHAR2,
                              p_reporting_book_class       IN         VARCHAR2,
                              x_payment_count              OUT NOCOPY BINARY_INTEGER,
                              x_return_status              OUT NOCOPY VARCHAR2,
                              x_msg_count                  OUT NOCOPY NUMBER,
                              x_msg_data                   OUT NOCOPY VARCHAR2,
			      x_se_id                      OUT NOCOPY NUMBER) IS

    lx_return_status              VARCHAR2(1);

    lx_isAllowed                  BOOLEAN;
    lx_passStatus                 VARCHAR2(30);
    lx_failStatus                 VARCHAR2(30);


    CURSOR c_hdr IS
      SELECT chr.template_yn,
             chr.currency_code,
             chr.start_date,
             khr.deal_type,
             khr.term_duration,
             NVL(khr.generate_accrual_yn, 'Y')
      FROM   okc_k_headers_b chr,
             okl_k_headers khr
      WHERE  khr.id = p_khr_id
        AND  chr.id = khr.id;

    l_hdr                    c_hdr%ROWTYPE;
    l_deal_type              VARCHAR2(30);
    l_purpose_code           VARCHAR2(30);

 --Added order by cle_id, sty_id, start_date by djanaswa for bug 6007644
    CURSOR c_inflows IS
      (SELECT rgp.cle_id cle_id,
             TO_NUMBER(rul1.object1_id1) sty_id,
             FND_DATE.canonical_to_date(rul2.rule_information2) start_date,
             TO_NUMBER(rul2.rule_information3) periods,
             rul2.object1_id1 frequency,
             rul2.rule_information5 structure,
             DECODE(rul2.rule_information10, 'Y', 'ARREARS', 'ADVANCE') advance_arrears,
             FND_NUMBER.canonical_to_number(rul2.rule_information6) amount,
             TO_NUMBER(rul2.rule_information7) stub_days,
             TO_NUMBER(rul2.rule_information8) stub_amount,
             lse.lty_code lty_code,
             kle.capital_amount capital_amount,
             kle.residual_value residual_value,
             kle.fee_type fee_type
      FROM   okc_rule_groups_b rgp,
             okc_rules_b rul1,
             okc_rules_b rul2,
             okc_k_lines_b cle,
             okl_k_lines kle,
             okc_line_styles_b lse
      WHERE
             rul2.dnz_chr_id = p_khr_id
        AND  rul2.rule_information_category = 'LASLL'
        AND  rul1.rule_information_category = 'LASLH'
        AND  rul1.jtot_object1_code = 'OKL_STRMTYP'
        AND  rul2.rgp_id = rgp.id
        AND  TO_NUMBER(rul2.object2_id1) = rul1.id
        AND  rgp.cle_id = cle.id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.id = kle.id
        AND  cle.lse_id = lse.id)
      UNION
      (SELECT TO_NUMBER(NULL) cle_id,
             TO_NUMBER(rul1.object1_id1) sty_id,
             FND_DATE.canonical_to_date(rul2.rule_information2) start_date,
             TO_NUMBER(rul2.rule_information3) periods,
             rul2.object1_id1 frequency,
             rul2.rule_information5 structure,
             DECODE(rul2.rule_information10, 'Y', 'ARREARS', 'ADVANCE') advance_arrears,
             FND_NUMBER.canonical_to_number(rul2.rule_information6) amount,
             TO_NUMBER(rul2.rule_information7) stub_days,
             TO_NUMBER(rul2.rule_information8) stub_amount,
             NULL lty_code,
             TO_NUMBER(NULL) capital_amount,
             TO_NUMBER(NULL) residual_value,
             NULL fee_type
      FROM   okc_rule_groups_b rgp,
             okc_rules_b rul1,
             okc_rules_b rul2
      WHERE
             rul2.dnz_chr_id = p_khr_id
        AND  rul2.rule_information_category = 'LASLL'
        AND  rul1.rule_information_category = 'LASLH'
        AND  rul1.jtot_object1_code = 'OKL_STRMTYP'
        AND  rul2.rgp_id = rgp.id
        AND  rgp.cle_id IS NULL
        AND  TO_NUMBER(rul2.object2_id1) = rul1.id)
        ORDER BY cle_id, sty_id, start_date;

  l_inflow c_inflows%rowtype;

    CURSOR c_fin_assets IS
      SELECT kle.id,
             NVL(kle.residual_value, 0) residual_value,
             cle.start_date
      FROM   okc_k_lines_b cle,
             okl_k_lines kle,
             okc_line_styles_b lse
      WHERE  cle.chr_id = p_khr_id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.lse_id = lse.id
        AND  lse.lty_code = 'FREE_FORM1'
        AND  cle.id = kle.id;


    CURSOR c_pt_yn (p_cle_id NUMBER) IS
      SELECT 'Y'
      FROM   okc_rule_groups_b
      WHERE  cle_id = p_cle_id
        AND  rgd_code = 'LAPSTH';

    l_pt_yn                  VARCHAR2(1);
    l_passthrough_id         NUMBER;

    l_sty_id                 NUMBER;
    l_sty_name               VARCHAR2(150);
    l_mapped_sty_name        VARCHAR2(150);

    l_pre_tax_inc_id         NUMBER;
    l_principal_id           NUMBER;
    l_interest_id            NUMBER;
    l_prin_bal_id            NUMBER;
    l_termination_id         NUMBER;

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_pt_tbl                 okl_streams_pub.selv_tbl_type;
    l_pt_pro_fee_tbl         okl_streams_pub.selv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    l_pt_rec                 okl_streams_pub.stmv_rec_type;
    l_pt_pro_fee_rec         okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

    -- Loan Amortization
    l_principal_tbl          okl_streams_pub.selv_tbl_type;
    l_interest_tbl           okl_streams_pub.selv_tbl_type;
    l_prin_bal_tbl           okl_streams_pub.selv_tbl_type;
    l_termination_tbl        okl_streams_pub.selv_tbl_type;
    l_pre_tax_inc_tbl        okl_streams_pub.selv_tbl_type;

    l_capital_cost           NUMBER;
    l_interim_interest       NUMBER;
    l_interim_days           NUMBER;
    l_interim_dpp            NUMBER;
    l_asset_iir              NUMBER;
    l_asset_booking_yield    NUMBER;

    i                        BINARY_INTEGER := 0;


    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'generate_cash_flows';
    l_pay_tbl OKL_STREAM_GENERATOR_PVT.payment_tbl_type;

    l_se_id NUMBER;

   l_passthrough_pro_fee_id NUMBER;

    -- Added by RGOOTY for perf.: Bug Number 4346646 Start
    l_stmv_tbl              Okl_Streams_Pub.stmv_tbl_type;
    l_full_selv_tbl         Okl_Streams_Pub.selv_tbl_type;

    lx_stmv_tbl              Okl_Streams_Pub.stmv_tbl_type;
    lx_full_selv_tbl         Okl_Streams_Pub.selv_tbl_type;
    -- Added by RGOOTY for perf.: End

    cursor fee_strm_type_csr ( kleid NUMBER,
                               linestyle VARCHAR2 ) is
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

    top_svc_rec top_svc_csr%ROWTYPE;

  --Added by djanaswa for bug 6007644
    l_recurrence_date    DATE := NULL;
    l_old_cle_id         NUMBER;
    l_old_sty_id         NUMBER;
    --end djanaswa


  BEGIN

--    print( l_prog_name, 'begin' );
    OPEN  c_hdr;
    FETCH c_hdr INTO l_hdr;
    CLOSE c_hdr;

    IF p_reporting_book_class IS NOT NULL THEN
      l_deal_type    :=  p_reporting_book_class;
      l_purpose_code := 'REPORT';
    ELSE
      l_deal_type    :=  l_hdr.deal_type;
      l_purpose_code := '-99';
    END IF;

   generate_stub_element( p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          p_khr_id        => p_khr_id,
			  p_deal_type     => l_deal_type,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
			              x_se_id         => l_se_id );
 --       print( l_prog_name, ' generate_stub_elements ', x_return_status );

   IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

      --Added by prasjain for bug 5474827
      x_se_id := l_se_id;
      --end prasjain

      ---------------------------------------------
      -- STEP 1: Spread cash INFLOW
      ---------------------------------------------

        print( l_prog_name, ' generating streams - begin');
      x_payment_count  :=  0;
      FOR l_inflow IN c_inflows LOOP
        IF ( (l_inflow.lty_code = 'SOLD_SERVICE' OR l_inflow.lty_code = 'LINK_SERV_ASSET') AND
           p_generation_type = 'SERVICE_LINES') OR (p_generation_type = 'FULL') THEN
            IF l_inflow.start_date IS NULL
            THEN
              OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                   p_msg_name     => 'OKL_NO_SLL_SDATE');
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;

        --Added by djanaswa for bug 6007644
           IF((l_inflow.periods IS NULL) AND (l_inflow.stub_days IS NOT NULL)) THEN
             --Set the recurrence date to null for stub payment
             l_recurrence_date := NULL;
           ELSIF(l_recurrence_date IS NULL
              OR l_old_cle_id <> l_inflow.cle_id
              OR l_old_sty_id <> l_inflow.sty_id) THEN
             --Set the recurrence date as periodic payment level start date
             l_recurrence_date := l_inflow.start_date;
           END IF;
           l_old_cle_id := l_inflow.cle_id;
           l_old_sty_id := l_inflow.sty_id;
           --end djanaswa

        /*
         * calculate stream elements for each payment level
         * also means that if there are multiple payment levels for an asset, streams are
         * calculated at different points.
         * the streams amounts are they are entered in payments. In case of passthru, a
         * new set of streams are created with amounts that are passthru'ed - l_pt_tbl.
         */
        --Added parameter p_recurrence_date by djanaswa for bug 6007644

         get_stream_elements( p_start_date          =>   l_inflow.start_date,
                            p_periods             =>   l_inflow.periods,
                            p_frequency           =>   l_inflow.frequency,
                            p_structure           =>   l_inflow.structure,
                            p_advance_or_arrears  =>   l_inflow.advance_arrears,
                            p_amount              =>   l_inflow.amount,
                            p_stub_days           =>   l_inflow.stub_days,
                            p_stub_amount         =>   l_inflow.stub_amount,
                            p_currency_code       =>   l_hdr.currency_code,
                            p_khr_id              =>   p_khr_id,
                            p_kle_id              =>   l_inflow.cle_id,
                            p_purpose_code        =>   l_purpose_code,
                            x_selv_tbl            =>   l_selv_tbl,
                            x_pt_tbl              =>   l_pt_tbl,
                            x_pt_pro_fee_tbl      =>   l_pt_pro_fee_tbl,
                            x_return_status       =>   lx_return_status,
                            x_msg_count           =>   x_msg_count,
                            x_msg_data            =>   x_msg_data,
                            p_recurrence_date     =>   l_recurrence_date);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF ( l_inflow.stub_days IS NOT NULL ) AND ( l_inflow.periods IS NULL )
        THEN
    	    FOR i in 1..l_selv_tbl.COUNT
    	    LOOP
    	        l_selv_tbl(i).sel_id := l_se_id;
    	    END LOOP;
    	    FOR i in 1..l_pt_tbl.COUNT
    	    LOOP
    	        l_pt_tbl(i).sel_id := l_se_id;
	        l_pt_pro_fee_tbl(i).sel_id := l_se_id;
    	    END LOOP;
        End If;

        /*
        * will get multiple headers for same ( khr_id, kle_id, sty_id ) :-()
        */

        get_stream_header(p_khr_id         =>   p_khr_id,
                          p_kle_id         =>   l_inflow.cle_id,
                          p_sty_id         =>   l_inflow.sty_id,
                          p_purpose_code   =>   l_purpose_code,
                          x_stmv_rec       =>   l_stmv_rec,
                          x_return_status  =>   lx_return_status);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        lx_return_status := Okl_Streams_Util.round_streams_amount_esg(
                            p_api_version   => g_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_chr_id        => p_khr_id,
                            p_selv_tbl      => l_selv_tbl,
                            x_selv_tbl      => lx_selv_tbl,
                            p_org_id        => G_ORG_ID,
                            p_precision     => G_PRECISION,
                            p_currency_code => G_CURRENCY_CODE,
                            p_rounding_rule => G_ROUNDING_RULE,
                            p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

        IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_selv_tbl.DELETE;
        l_selv_tbl := lx_selv_tbl;

        --Accumulate Stream Header
        OKL_STREAMS_UTIL.accumulate_strm_headers(
          p_stmv_rec       => l_stmv_rec,
          x_full_stmv_tbl  => l_stmv_tbl,
          x_return_status  => lx_return_status );
        IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Accumulate Stream Elements
        OKL_STREAMS_UTIL.accumulate_strm_elements(
          p_stm_index_no  =>  l_stmv_tbl.LAST,
          p_selv_tbl       => l_selv_tbl,
          x_full_selv_tbl  => l_full_selv_tbl,
          x_return_status  => lx_return_status );
        IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
/*
        okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                       p_init_msg_list   =>   G_FALSE,
                                       x_return_status   =>   lx_return_status,
                                       x_msg_count       =>   x_msg_count,
                                       x_msg_data        =>   x_msg_data,
                                       p_stmv_rec        =>   l_stmv_rec,
                                       p_selv_tbl        =>   l_selv_tbl,
                                       x_stmv_rec        =>   lx_stmv_rec,
                                       x_selv_tbl        =>   lx_selv_tbl);

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
*/
        IF l_pt_tbl.COUNT > 0 THEN
          --Added by mansrini on 30-Jun-2005 for generating pass through accrual streams for service lines
          --Bug 4434343 - Start of Changes
          IF (l_inflow.lty_code = 'FEE') OR (l_inflow.lty_code = 'LINK_FEE_ASSET')  THEN
            OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                   p_khr_id                => p_khr_id,
                                         p_deal_type             => l_deal_type,
                                   p_primary_sty_id        => l_inflow.sty_id,
                                   p_dependent_sty_purpose => 'PASS_THRU_EXP_ACCRUAL',
                                   x_return_status         => lx_return_status,
                                   x_dependent_sty_id      => l_passthrough_id,
                                   x_dependent_sty_name    => l_sty_name);
            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
         ELSIF (l_inflow.lty_code = 'SOLD_SERVICE') OR (l_inflow.lty_code = 'LINK_SERV_ASSET') THEN
            OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                   p_khr_id                => p_khr_id,
                                         p_deal_type             => l_deal_type,
                                   p_primary_sty_id        => l_inflow.sty_id,
                                   p_dependent_sty_purpose => 'PASS_THRU_SVC_EXP_ACCRUAL',
                                   x_return_status         => lx_return_status,
                                   x_dependent_sty_id      => l_passthrough_id,
                                   x_dependent_sty_name    => l_sty_name);
            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
         END IF;
         --Bug 4434343 - End of Changes


            If l_passthrough_id IS NOT NULL then

                get_stream_header(p_khr_id         =>   p_khr_id,
                                p_kle_id         =>   l_inflow.cle_id,
                                p_sty_id         =>   l_passthrough_id,
                                p_purpose_code   =>   l_purpose_code,
                                x_stmv_rec       =>   l_pt_rec,
                                x_return_status  =>   lx_return_status);

                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;


                lx_return_status := Okl_Streams_Util.round_streams_amount_esg(
                                  p_api_version   => g_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_chr_id        => p_khr_id,
                                  p_selv_tbl      => l_pt_tbl,
                                  x_selv_tbl      => lx_selv_tbl,
                                  p_org_id        => G_ORG_ID,
                                  p_precision     => G_PRECISION,
                                  p_currency_code => G_CURRENCY_CODE,
                                  p_rounding_rule => G_ROUNDING_RULE,
                                  p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

                IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                l_pt_tbl.DELETE;
                l_pt_tbl := lx_selv_tbl;
               --Accumulate Stream Header: 4346646
                OKL_STREAMS_UTIL.accumulate_strm_headers(
                  p_stmv_rec       => l_pt_rec,
                  x_full_stmv_tbl  => l_stmv_tbl,
                  x_return_status  => lx_return_status );
                IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                --Accumulate Stream Elements
                OKL_STREAMS_UTIL.accumulate_strm_elements(
                  p_stm_index_no  =>  l_stmv_tbl.LAST,
                  p_selv_tbl       => l_pt_tbl,
                  x_full_selv_tbl  => l_full_selv_tbl,
                  x_return_status  => lx_return_status );
                IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
/*
               okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                             p_init_msg_list   =>   G_FALSE,
                                             x_return_status   =>   lx_return_status,
                                             x_msg_count       =>   x_msg_count,
                                             x_msg_data        =>   x_msg_data,
                                             p_stmv_rec        =>   l_pt_rec,
                                             p_selv_tbl        =>   l_pt_tbl,
                                             x_stmv_rec        =>   lx_stmv_rec,
                                             x_selv_tbl        =>   lx_selv_tbl);

                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
*/
            End If;
        END IF;

        IF l_pt_pro_fee_tbl.COUNT > 0 THEN

          IF l_passthrough_pro_fee_id IS NULL THEN

             If ( l_inflow.lty_code = 'LINK_FEE_ASSET') Then

	       OPEN top_svc_csr( p_khr_id, l_inflow.cle_id );
               FETCH top_svc_csr INTO top_svc_rec;
               CLOSE top_svc_csr;

               OPEN  fee_strm_type_csr  ( top_svc_rec.top_svc_id, 'FEE' );
               FETCH fee_strm_type_csr into fee_strm_type_rec;
               CLOSE fee_strm_type_csr;

	     Else

               OPEN  fee_strm_type_csr  ( l_inflow.cle_id, 'FEE' );
               FETCH fee_strm_type_csr into fee_strm_type_rec;
               CLOSE fee_strm_type_csr;

             End If;

             OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
					 p_deal_type             => l_deal_type,
                                         p_primary_sty_id        => fee_strm_type_rec.styp_id,
                                         p_dependent_sty_purpose => 'PASS_THRU_PRO_FEE_ACCRUAL',
                                         x_return_status         => lx_return_status,
                                         x_dependent_sty_id      => l_passthrough_pro_fee_id,
                                         x_dependent_sty_name    => l_sty_name);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

          END IF;

        If l_passthrough_pro_fee_id IS NOT NULL then

          get_stream_header(p_khr_id         =>   p_khr_id,
                            p_kle_id         =>   l_inflow.cle_id,
                            p_sty_id         =>   l_passthrough_pro_fee_id,
                            p_purpose_code   =>   l_purpose_code,
                            x_stmv_rec       =>   l_pt_pro_fee_rec,
                            x_return_status  =>   lx_return_status);

          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;


               lx_return_status := Okl_Streams_Util.round_streams_amount_esg(
                                  p_api_version   => g_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_chr_id        => p_khr_id,
                                  p_selv_tbl      => l_pt_pro_fee_tbl,
                                  x_selv_tbl      => lx_selv_tbl,
                                  p_org_id        => G_ORG_ID,
                                  p_precision     => G_PRECISION,
                                  p_currency_code => G_CURRENCY_CODE,
                                  p_rounding_rule => G_ROUNDING_RULE,
                                  p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

          IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          l_pt_pro_fee_tbl.DELETE;
          l_pt_pro_fee_tbl := lx_selv_tbl;

                OKL_STREAMS_UTIL.accumulate_strm_headers(
                  p_stmv_rec       => l_pt_pro_fee_rec,
                  x_full_stmv_tbl  => l_stmv_tbl,
                  x_return_status  => lx_return_status );

                IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                --Accumulate Stream Elements
                OKL_STREAMS_UTIL.accumulate_strm_elements(
                  p_stm_index_no  =>  l_stmv_tbl.LAST,
                  p_selv_tbl       => l_pt_pro_fee_tbl,
                  x_full_selv_tbl  => l_full_selv_tbl,
                  x_return_status  => lx_return_status );

          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

	 End If;

        END IF;


        -- Clear out reusable data structures

        l_sty_name  :=  NULL;
        l_sty_id    :=  NULL;

        l_stmv_rec := NULL;
        l_pt_rec := NULL;
        l_selv_tbl.delete;
        l_pt_tbl.delete;

        l_pt_pro_fee_rec := NULL;
        l_pt_pro_fee_tbl.delete;


        lx_stmv_rec := NULL;
        lx_selv_tbl.delete;

        x_payment_count  :=  x_payment_count + 1;
    END IF;
    END LOOP;
    --Create all the accumulated Streams at one shot ..
Okl_Streams_Pub.create_streams_perf(
                    p_api_version,
                    p_init_msg_list,
                    lx_return_status,
                    x_msg_count,
                    x_msg_data,
                    l_stmv_tbl,
                    l_full_selv_tbl,
                    lx_stmv_tbl,
                    lx_full_selv_tbl);
    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
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

  END generate_cash_flows;

  -- Added by rgooty for bug 9305846
  ---------------------------------------------------------------------------
  -- PROCEDURE gen_rental_accr_streams
  ----This procedure generates Rental Accrual Streams------------------------
  ---------------------------------------------------------------------------
  PROCEDURE gen_rental_accr_streams (p_api_version        IN    NUMBER,
                                     p_init_msg_list      IN    VARCHAR2,
                                     p_khr_id             IN    NUMBER,
                                     p_purpose_code       IN    VARCHAR2,
                                     x_return_status      OUT   NOCOPY VARCHAR2,
                                     x_msg_count          OUT   NOCOPY NUMBER,
                                     x_msg_data           OUT   NOCOPY VARCHAR2) IS

    --To get all the assets for the contract
    CURSOR c_assets IS
      SELECT cle.id cle_id,
             cle.start_date start_date,
             NVL(cle.date_terminated, cle.end_date) end_date
      FROM   okc_k_lines_b cle,
             okc_line_styles_b lse
      WHERE  cle.dnz_chr_id = p_khr_id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.lse_id = lse.id
        AND  lse.lty_code = 'FREE_FORM1';

    --To get payment information for antr asset line
    CURSOR c_inflows(p_cle_id  NUMBER)
        IS
      SELECT TO_NUMBER(rul1.object1_id1) sty_id,
             TO_NUMBER(rul2.rule_information3) periods,
             FND_NUMBER.canonical_to_number(rul2.rule_information6) amount,
             TO_NUMBER(rul2.rule_information7) stub_days,
             TO_NUMBER(rul2.rule_information8) stub_amount
        FROM okc_rule_groups_b rgp,
             okc_rules_b rul1,
             okc_rules_b rul2,
             okc_k_lines_b cle,
             okl_strm_type_b sty
       WHERE rul2.dnz_chr_id = p_khr_id
         AND rul2.rule_information_category = 'LASLL'
         AND rul2.rgp_id = rgp.id
         AND TO_NUMBER(rul2.object2_id1) = rul1.id
         AND rgp.cle_id = cle.id
         AND cle.id = p_cle_id
         AND cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
         AND sty.id = rul1.object1_id1
         AND sty.stream_type_purpose = 'RENT';

    l_prog_name   CONSTANT  VARCHAR2(100) := G_PKG_NAME||'.'||'gen_rental_accr_streams';
    l_sum_of_rents          NUMBER := 0;
    l_currency_code         OKC_K_HEADERS_B.CURRENCY_CODE%TYPE;
    l_day_convention_month  VARCHAR2(30);
    l_day_convention_year   VARCHAR2(30);
    l_end_date              DATE;
    l_total_days            NUMBER;
    l_daily_amt             NUMBER;
    l_start_date            DATE;
    l_month_end             DATE;
    l_stmv_tbl              Okl_Streams_Pub.stmv_tbl_type;
    l_stmv_rec              Okl_Streams_Pub.stmv_rec_type;
    l_full_selv_tbl         Okl_Streams_Pub.selv_tbl_type;
    l_selv_tbl              Okl_Streams_Pub.selv_tbl_type;
    lx_selv_tbl             Okl_Streams_Pub.selv_tbl_type;
    lx_stmv_tbl             Okl_Streams_Pub.stmv_tbl_type;
    lx_full_selv_tbl        Okl_Streams_Pub.selv_tbl_type;
    l_dep_sty_id            NUMBER;
    p_get_k_info_csr        OKL_ISG_UTILS_PVT.G_GET_K_INFO_CSR%ROWTYPE;
    l_mapped_sty_name       VARCHAR2(150);
    l_days                  NUMBER;
    i                       BINARY_INTEGER := 0;
    l_start_day             NUMBER;
    l_end_day               NUMBER;

  BEGIN

    --Get the day convention
    OKL_PRICING_UTILS_PVT.get_day_convention(
         p_id              => p_khr_id,
         p_source          => 'ISG',
         x_days_in_month   => l_day_convention_month,
         x_days_in_year    => l_day_convention_year,
         x_return_status   => x_return_status);
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN OKL_ISG_UTILS_PVT.G_GET_K_INFO_CSR (p_khr_id);
    FETCH OKL_ISG_UTILS_PVT.G_GET_K_INFO_CSR INTO p_get_k_info_csr;
    CLOSE OKL_ISG_UTILS_PVT.G_GET_K_INFO_CSR;

    FOR l_asset_rec IN c_assets LOOP
       l_sum_of_rents := 0;
       FOR l_inflow IN c_inflows(l_asset_rec.cle_id) LOOP

         IF(l_mapped_sty_name IS NULL) THEN
            OKL_ISG_UTILS_PVT.get_dep_stream_type(
                   p_khr_id                => p_khr_id,
                   p_deal_type             => 'LEASEOP',
                   p_primary_sty_id        => l_inflow.sty_id,
                   p_dependent_sty_purpose => 'RENT_ACCRUAL',
                   x_return_status         => x_return_status,
                   x_dependent_sty_id      => l_dep_sty_id,
                   x_dependent_sty_name    => l_mapped_sty_name,
                   p_get_k_info_rec        => p_get_k_info_csr);
            IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            --If Rental Accrual stream is not present in the SGT, then exit the procedure
            IF(l_mapped_sty_name IS NULL) THEN
              EXIT;
            END IF;
         END IF;

         IF (l_inflow.periods IS NOT NULL) AND (l_inflow.amount IS NOT NULL) THEN
            l_sum_of_rents := l_sum_of_rents + (l_inflow.periods * l_inflow.amount);
         ELSE
            l_sum_of_rents := l_sum_of_rents + l_inflow.stub_amount;
         END IF;
       END LOOP;

       l_start_date  :=  l_asset_rec.start_date;
       l_end_date    :=  l_asset_rec.end_date;
       l_month_end   :=  LAST_DAY(l_start_date);

       l_total_days  := OKL_PRICING_UTILS_PVT.get_day_count(
                            p_start_date    => l_start_date,
                            p_days_in_month => l_day_convention_month,
                            p_days_in_year  => l_day_convention_year,
                            p_end_date      => l_end_date,
                            p_arrears       => 'Y',
                            x_return_status => x_return_status);
       IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF(l_day_convention_month = '30' AND l_day_convention_year = '360') THEN
         l_start_day := to_char(l_start_date, 'DD' );
         l_end_day   := to_char(l_end_date, 'DD' );
         IF(l_start_day = l_end_day) THEN
            l_total_days := l_total_days + 1;
         END IF;
       END IF;

       l_daily_amt  :=  l_sum_of_rents / l_total_days;

       l_stmv_rec := NULL;
       l_selv_tbl.delete;
       i := 0;

       LOOP
         i := i + 1;
         IF TO_CHAR(l_month_end, 'MON') IN ('JAN', 'MAR', 'MAY', 'JUL', 'AUG', 'OCT', 'DEC') THEN
           l_selv_tbl(i).stream_element_date := l_month_end - 1;
         ELSE
           l_selv_tbl(i).stream_element_date := l_month_end;
         END IF;

         l_selv_tbl(i).se_line_number :=  i;

         IF l_month_end > l_end_date THEN
           l_month_end := l_end_date;
         END IF;

         l_days := OKL_PRICING_UTILS_PVT.get_day_count(
                        p_start_date    => l_start_date,
                        p_days_in_month => l_day_convention_month,
                        p_days_in_year  => l_day_convention_year,
                        p_end_date      => l_month_end,
                        p_arrears       => 'Y',
                        x_return_status => x_return_status);
         IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_selv_tbl(i).amount := l_days * l_daily_amt;

         IF l_month_end >= l_end_date THEN
           EXIT;
         END IF;

         l_start_date   := LAST_DAY(l_start_date) + 1;
         l_month_end    := ADD_MONTHS(l_month_end, 1);
       END LOOP;

       IF (l_selv_tbl.COUNT > 0 ) THEN
          x_return_status := Okl_Streams_Util.round_streams_amount_esg(
                                 p_api_version   => g_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 p_chr_id        => p_khr_id,
                                 p_selv_tbl      => l_selv_tbl,
                                 x_selv_tbl      => lx_selv_tbl,
                                 p_org_id        => G_ORG_ID,
                                 p_precision     => G_PRECISION,
                                 p_currency_code => G_CURRENCY_CODE,
                                 p_rounding_rule => G_ROUNDING_RULE,
                                 p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          l_selv_tbl.DELETE;
          l_selv_tbl := lx_selv_tbl;

          get_stream_header(p_khr_id         =>   p_khr_id,
                            p_kle_id         =>   l_asset_rec.cle_id,
                            p_sty_id         =>   l_dep_sty_id,
                            p_purpose_code   =>   p_purpose_code,
                            x_stmv_rec       =>   l_stmv_rec,
                            x_return_status  =>   x_return_status);
          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          --Accumulate Stream Header
          OKL_STREAMS_UTIL.accumulate_strm_headers(
                p_stmv_rec       => l_stmv_rec,
                x_full_stmv_tbl  => l_stmv_tbl,
                x_return_status  => x_return_status );
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          --Accumulate Stream Elements
          OKL_STREAMS_UTIL.accumulate_strm_elements(
                p_stm_index_no  =>  l_stmv_tbl.LAST,
                p_selv_tbl       => l_selv_tbl,
                x_full_selv_tbl  => l_full_selv_tbl,
                x_return_status  => x_return_status );
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END IF;

    END LOOP; --Assets loop

    --Create all the accumulated Streams
    IF l_stmv_tbl.COUNT > 0 AND
       l_full_selv_tbl.COUNT > 0
    THEN
      Okl_Streams_Pub.create_streams_perf(
                               p_api_version,
                               p_init_msg_list,
                               x_return_status,
                               x_msg_count,
                               x_msg_data,
                               l_stmv_tbl,
                               l_full_selv_tbl,
                               lx_stmv_tbl,
                               lx_full_selv_tbl);
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

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
  END gen_rental_accr_streams;
  -- end rgooty for bug 9305846


/*****************************************************************************************
  * API introduced as part of the Prospective Rebooking Enhancement
  * Author: Ravindranath Gooty
  * Description: This API fetches all the elgibile Accrual Streams generated
  *              and adjusts the change of the Accrual amount till Last Accrued
  *              date to the remaining Accrual elements.
  *              [For both Algorithms: Straight Line Algorithm and Spread By Income]
  *              sechawla 8/7/09 : support both 'FULL' and 'SERVICE_LINES' as the generation
  *                                context for the Service Income/Expense Accrual Streams
  *****************************************************************************************/
  PROCEDURE prosp_adj_acc_strms(
              p_api_version         IN         NUMBER
             ,p_init_msg_list       IN         VARCHAR2
             ,p_rebook_type         IN         VARCHAR2
             ,p_rebook_date         IN         DATE
             ,p_khr_id              IN         NUMBER
             ,p_deal_type           IN         VARCHAR2
             ,p_currency_code       IN         VARCHAR2
             ,p_start_date          IN         DATE
             ,p_end_date            IN         DATE
             ,p_context             IN         VARCHAR2
             ,p_purpose_code        IN         VARCHAR2
             ,x_return_status       OUT NOCOPY VARCHAR2
             ,x_msg_count           OUT NOCOPY NUMBER
             ,x_msg_data            OUT NOCOPY VARCHAR2)
  IS

    -- Cursor to fetch all the related Accrual Streams
    -- Introducing new column called Priority, because, in case of a OP Lease
    --  we need to make sure that the Rental Accrual Streams are first adjusted prospectively
    --  before we adjust any other Accrual Stream using the Spread By Income Logic
    CURSOR lcu_get_accrual_streams(
              p_khr_id        NUMBER
             ,p_say_code      VARCHAR2
             ,p_purpose       VARCHAR2 )
    IS
      SELECT  stm.id                  stm_id
             ,stm.kle_id              kle_id
             ,stm.sty_id              sty_id
             ,sty.stream_type_purpose stm_purpose
             ,stm.say_code            say_code
             ,stm.purpose_code        purpose_code
             ,sty.stream_type_purpose sty_purpose
             ,sty.code                sty_code
             ,DECODE(
               sty.stream_type_purpose,
               'RENT_ACCRUAL', 1,
               99 )                   sty_priority
      FROM    okl_streams        stm,
              okl_strm_type_b    sty
      WHERE   stm.khr_id = p_khr_id
        AND   stm.say_code = p_say_code
        AND   NVL(stm.purpose_code, '-99') = p_purpose
        AND   sty.id = stm.sty_id
        AND   sty.stream_type_purpose IN (
              -- Accrual Streams generated using Straight Line Algorithm
               ( SELECT 'RENT_ACCRUAL' FROM DUAL WHERE p_context IN ( 'FULL' ) )
              ,( SELECT 'ACCRUED_FEE_INCOME' FROM DUAL WHERE p_context IN ( 'FULL' ) )
              ,( SELECT 'ACCRUED_FEE_EXPENSE' FROM DUAL WHERE p_context IN ( 'FULL' ) )

              --sechawla 10-aug-09 Added 'SERVICE_LINES' context for Service Income and Service Expense
              --streams to support Prospective Rebooking for these streams
              ,( SELECT 'SERVICE_INCOME'  FROM DUAL WHERE p_context IN ( 'FULL','SERVICE_LINES' ) )
              ,( SELECT 'SERVICE_EXPENSE'  FROM DUAL WHERE p_context IN ( 'FULL', 'SERVICE_LINES') )

              ,( SELECT 'PASS_THRU_REV_ACCRUAL'  FROM DUAL WHERE p_context IN ('FULL', 'PASSTHRU_ONLY' ) )
              ,( SELECT 'PASS_THRU_EXP_ACCRUAL'  FROM DUAL WHERE p_context IN ('FULL', 'PASSTHRU_ONLY' ) )
              -- Accrual Streams generated using Spread By Income Logic
              ,( SELECT 'AMORTIZE_FEE_INCOME'  FROM DUAL WHERE p_context IN ('FULL' ) )
              ,( SELECT 'AMORTIZED_FEE_EXPENSE'  FROM DUAL WHERE p_context IN ('FULL') )
              ,( SELECT 'SUBSIDY_INCOME' FROM DUAL WHERE p_context IN ('FULL') )
          )
        AND stm.sgn_code NOT IN ( 'STMP' , 'STMP-REBK')
      ORDER BY  DECODE( sty.stream_type_purpose, 'RENT_ACCRUAL', 1, 99 ) ASC;
    TYPE l_accrual_streams_tbl_type  IS TABLE OF lcu_get_accrual_streams%ROWTYPE
      INDEX BY PLS_INTEGER;

    -- Cursor to fetch the Stream Elements and its details
    CURSOR get_strms_csr (
       p_khr_id       IN NUMBER
      ,p_kle_id       IN NUMBER
      ,p_sty_id       IN NUMBER
      ,p_purpose_code IN VARCHAR2
      ,p_say_code     IN VARCHAR2
    )
    IS
       SELECT sel.id                  sel_id,
              sel.amount              se_amount,
              sel.stream_element_date se_date,
              sel.comments            se_arrears,
              sel.sel_id              se_sel_id,
              stm.id                  stm_id,
              stm.khr_id              khr_id,
              stm.kle_id              kle_id,
              stm.sty_id              sty_id,
              stm.say_code            say_code,
              stm.purpose_code        purpose_code
       FROM   okl_strm_elements sel,
              okl_streams       stm
       WHERE  stm.kle_id = p_kle_id
         AND  stm.khr_id = p_khr_id
         AND  stm.sty_id = p_sty_id
         AND  DECODE(stm.purpose_code,
                     NULL, '-99',
                     'REPORT'
                    ) = p_purpose_code
         AND  stm.say_code = p_say_code
         AND  stm.id = sel.stm_id
       ORDER BY sel.stream_element_date;
    TYPE l_acc_strm_ele_tbl_type IS TABLE OF get_strms_csr%ROWTYPE
      INDEX BY BINARY_INTEGER;

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

    -- Cursor to fetch the Payment Level Information for the Lines
    CURSOR get_payment_sll_dtls_csr(
              p_khr_id   IN   NUMBER
             ,p_kle_id   IN   NUMBER
           )
    IS
      SELECT TO_NUMBER(slh.object1_id1)                            sty_id,
             sty.stream_type_purpose                               sty_purpose,
             FND_DATE.canonical_to_date(sll.rule_information2)     start_date,
             TO_NUMBER(sll.rule_information3)                      periods,
             sll.object1_id1                                       frequency,
             sll.rule_information5                                 structure,
             DECODE(sll.rule_information10,
             'Y', 'ARREARS',
                  'ADVANCE')                                       advance_arrears,
             FND_NUMBER.canonical_to_number(sll.rule_information6) amount,
             TO_NUMBER(sll.rule_information7)                      stub_days,
             TO_NUMBER(sll.rule_information8)                      stub_amount,
             DECODE( sll.rule_information7
               -- Case: When Payment Level is Regular Periods
               ,NULL
                ,( ADD_MONTHS
                   ( FND_DATE.canonical_to_date(sll.rule_information2),
                      NVL(TO_NUMBER(sll.rule_information3),1)
                      * DECODE(sll.object1_id1, 'M',1,'Q',3,'S',6,'A',12)
                   ) - 1
                 )
               -- Case: When Payment Level is Regular Periods
               ,FND_DATE.canonical_to_date(sll.rule_information2)
                 + TO_NUMBER(sll.rule_information7) - 1
             )                                                    end_date
      FROM   okc_rule_groups_b  rgp,
             okc_rules_b        slh,
             okc_rules_b        sll,
             okl_strm_type_b    sty
      WHERE  sll.dnz_chr_id                = p_khr_id
        AND  sll.rule_information_category = 'LASLL'
        AND  sll.rgp_id                    = rgp.id
        AND  TO_NUMBER(sll.object2_id1)    = slh.id
        AND  rgp.cle_id                    = p_kle_id
        AND  sty.id                        = slh.object1_id1
        AND  sty.stream_type_purpose NOT IN
             ( 'DOWN_PAYMENT'
               ,'ESTIMATED_PROPERTY_TAX'
               ,'UNSCHEDULED_PRINCIPAL_PAYMENT'
             )
     ORDER BY sty.id, FND_DATE.canonical_to_date(sll.rule_information2);

    -- Cursor to find the End Date of the Expense Fee
    CURSOR get_exp_end_date_csr(
              p_khr_id   IN   NUMBER
             ,p_kle_id   IN   NUMBER
           )
    IS
     SELECT TO_NUMBER(rul.rule_information1) periods,
            TO_NUMBER(rul.rule_information2) amount,
            DECODE(rul2.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12, NULL) mpp,
            cle.start_date,
            cle.sts_code,
            kle.fee_type,
            ( ADD_MONTHS(cle.start_date,
               TO_NUMBER(rul.rule_information1)  -- Periods
               * DECODE(rul2.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12, NULL)
            ) - 1 ) end_date
     FROM   okc_rules_b       rul,
            okc_rules_b       rul2,
            okc_rule_groups_b rgp,
            okc_k_lines_b     cle,
            okl_k_lines       kle
     WHERE  cle.id         = p_kle_id
       AND  cle.sts_code IN ('NEW', 'INCOMPLETE', 'PASSED', 'COMPLETE')
       AND  kle.id         = cle.id
       AND  kle.fee_type NOT IN
            (
               'FINANCED'
              ,'ABSORBED'
              ,'ROLLOVER'
            )
       AND  rgp.cle_id     = cle.id
       AND  rgp.dnz_chr_id = p_khr_id
       AND  rgp.rgd_code = 'LAFEXP'
       AND  rgp.id = rul.rgp_id
       AND  rgp.id = rul2.rgp_id
       AND  rul.rule_information_category = 'LAFEXP'
       AND  rul2.rule_information_category = 'LAFREQ';

    -- Cursor: Spread By Income Logic: To fetch all the eligible Income Streams
    CURSOR c_k_income (
              p_sty_name     IN VARCHAR2
             ,p_start_date   IN DATE
             ,p_end_date     IN DATE
             ,p_purpose_code IN VARCHAR2
    )
    IS
      SELECT  TRUNC(sel.stream_element_date) income_date
             ,SUM(sel.amount)                income_amount
        FROM  okl_strm_elements       sel
             ,okl_streams             stm
             ,okl_strm_type_b         sty
             ,okl_strm_type_tl        styt
      WHERE  stm.khr_id      = p_khr_id
        AND  stm.say_code    = 'WORK'
        AND  stm.id          = sel.stm_id
        AND  stm.sty_id      = sty.id
        AND  sty.version     = '1.0'
        AND  sty.id          = styt.id
        AND  styt.language   = 'US'
        AND  styt.name       = p_sty_name
        AND  sel.stream_element_date >= p_start_date
        AND  sel.stream_element_date <= LAST_DAY(p_end_date)
        AND  DECODE(stm.purpose_code, NULL, '-99', 'REPORT') = p_purpose_code
    GROUP BY TRUNC(sel.stream_element_date)
    ORDER BY TRUNC(sel.stream_element_date) ASC;

    TYPE income_streams_rec_type is RECORD
    (
        income_amount      NUMBER
       ,income_date        DATE
       ,income_proportion  NUMBER

    );

    TYPE income_streams_tbl_type is TABLE OF income_streams_rec_type
    INDEX BY BINARY_INTEGER;
    income_streams_tbl         income_streams_tbl_type;
    inx_tot_inc                NUMBER;
    ln_tot_inc_amount          NUMBER;

    -- Cursor: Spread By Income Logic: To identify the Stream Type used for Authoring the Asset Payments
    CURSOR l_rent_pri_sty_name_csr
    IS
      SELECT DISTINCT NVL(slh.object1_id1, -1) styid
        FROM OKC_RULE_GROUPS_B rgp,
             OKC_RULES_B       sll,
             okc_rules_b       slh,
             okl_strm_type_b   sty
       WHERE slh.rgp_id   = rgp.id
         AND rgp.RGD_CODE = 'LALEVL'
         AND sll.RULE_INFORMATION_CATEGORY = 'LASLL'
         AND slh.RULE_INFORMATION_CATEGORY = 'LASLH'
         AND TO_CHAR(slh.id) = sll.object2_id1
         AND slh.object1_id1 = sty.id
         AND sty.stream_type_purpose = 'RENT'
         AND rgp.dnz_chr_id  = p_khr_id;
    l_rent_pri_sty_name_rec    l_rent_pri_sty_name_csr%ROWTYPE;

    l_accrual_streams_tbl      l_accrual_streams_tbl_type;
    l_work_acc_strms_tbl       l_acc_strm_ele_tbl_type;
    l_curr_acc_strms_tbl       l_acc_strm_ele_tbl_type;
    l_api_name                 VARCHAR2(30)  := 'prosp_adj_acc_strms';
    l_prog_name       CONSTANT VARCHAR2(100) := G_PKG_NAME || '.' || l_api_name;
    l_return_status            VARCHAR2(1);
    l_rebook_type              VARCHAR2(30);
    l_rebook_date              DATE;
    l_last_accrued_date        DATE;
    l_rebook_eff_date          DATE;
    l_term_end_date            DATE;
    inx_work                   NUMBER;
    inx_curr                   NUMBER;
    l_kle_id                   NUMBER;
    l_sty_id                   NUMBER;
    l_stm_id                   NUMBER;
    l_stm_purpose              VARCHAR2(150);
    l_orig_khr_id              NUMBER;
    l_orig_kle_id              NUMBER;
    l_flip_prb_rbk_reason      VARCHAR2(150);
    ln_work_acc_amount         NUMBER;
    ln_curr_acc_amount         NUMBER;
    l_acc_adjustment           NUMBER;
    l_rem_days                 NUMBER;
    l_day_convention_month     VARCHAR2(30);
    l_day_convention_year      VARCHAR2(30);
    l_per_start_date           DATE;   -- Period Start Date
    l_per_end_date             DATE;   -- Period End Date
    l_per_days                 NUMBER; -- Days in the Period
    l_per_adjustment           NUMBER; -- Adjustment in the period
    l_per_rounded_adjustment   NUMBER;
    l_tot_per_adjustment       NUMBER; -- Total of the Period Adjustments
    l_un_modified_amount       NUMBER;

    -- Spread By Income Logic Modifications
    ln_tot_work_acc_amt        NUMBER;
    l_pri_rent_sty_id          NUMBER;
    l_inc_stream_id            NUMBER;
    l_inc_stream_name          VARCHAR2(300);
    ln_amt_before_adjustment   NUMBER;
    l_need_to_fetch_inc_strms  VARCHAR2(3);

    TYPE l_num_tbl_type IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;
    l_sel_id_tbl               l_num_tbl_type;
    l_stm_id_tbl               l_num_tbl_type;
    l_sel_amt_tbl              l_num_tbl_type;
    i                          NUMBER;
  BEGIN
    -- Added by RGOOTY: For Debugging purposes
    L_DEBUG_ENABLED := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_return_status := OKL_API.START_ACTIVITY(
                         p_api_name      => l_api_name,
                         p_pkg_name      => g_pkg_name,
                         p_init_msg_list => p_init_msg_list,
                         l_api_version   => p_api_version,
                         p_api_version   => p_api_version,
                         p_api_type      => G_API_TYPE,
                         x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Initialize the things
    l_rebook_date := TRUNC(p_rebook_date);
    l_rebook_type := p_rebook_type;

    print(l_prog_name, 'p_rebook_type  = ' || l_rebook_type );
    print(l_prog_name, 'p_rebook_date  = ' || l_rebook_date );
    print(l_prog_name, 'p_khr_id       = ' || p_khr_id );
    print(l_prog_name, 'p_deal_type    = ' || p_deal_type );
    print(l_prog_name, 'p_currency_code= ' || p_currency_code );
    print(l_prog_name, 'p_start_date   = ' || p_start_date );
    print(l_prog_name, 'p_end_date     = ' || p_end_date );
    print(l_prog_name, 'p_context      = ' || p_context );
    print(l_prog_name, 'p_purpose_code = ' || p_purpose_code );
    print(l_prog_name, 'Rebook Date    = ' || p_rebook_date );

    -- Derieve the Rebook Effective Date
    l_flip_prb_rbk_reason := 'NO_REASON';
    IF l_rebook_date IS NULL
    THEN
      l_flip_prb_rbk_reason := 'NO_REBOOK_DATE';
    END IF;
    IF l_rebook_type IS NULL
    THEN
      l_flip_prb_rbk_reason := 'NO_REBOOK_TYPE_MENTIONED';
    END IF;
    IF p_currency_code IS NULL
    THEN
      l_flip_prb_rbk_reason := 'NO_CURRENCY_CODE_MENTIONED';
    END IF;
    IF p_deal_type IS NULL
    THEN
      l_flip_prb_rbk_reason := 'NO_DEAL_TYPE_MENTIONED';
    END IF;

    -- Calculate the Last Accrued Date
    l_last_accrued_date := TRUNC( LAST_DAY(ADD_MONTHS(l_rebook_date, -1) ) );
    print( l_prog_name,'Contract Start Date | Rebook Date | Last Accrued Date | End Date');
    print( l_prog_name, p_start_date || ' | ' || l_rebook_date
                      || ' | ' || l_last_accrued_date || ' | ' || p_end_date );
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

    -- Fetch the day convention ..
    IF l_flip_prb_rbk_reason = 'NO_REASON'
    THEN
      l_flip_prb_rbk_reason := 'INVALID_DAY_CONVENTION';
      OKL_PRICING_UTILS_PVT.get_day_convention(
         p_id              => p_khr_id
        ,p_source          => 'ISG'
        ,x_days_in_month   => l_day_convention_month
        ,x_days_in_year    => l_day_convention_year
        ,x_return_status   => x_return_status);
      print(l_prog_name, 'Day Convention Month/Year = ' || l_day_convention_month || '/' || l_day_convention_year );
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_flip_prb_rbk_reason := 'NO_REASON';
    END IF;

    -- Modifications: Spread By Income Logic
    --  Step: First identify the Rent Primary Stream Type name associated to Asset Payments
    -- Find the Primary Rent Stream Id
    OPEN  l_rent_pri_sty_name_csr;
    FETCH l_rent_pri_sty_name_csr INTO l_rent_pri_sty_name_rec;
    CLOSE l_rent_pri_sty_name_csr;
    -- Assign the Rent Primary Sty Id to l_pri_rent_sty_id
    l_pri_rent_sty_id := l_rent_pri_sty_name_rec.styid;
    print(l_prog_name, 'Primary Rent Stream ID = ' || l_pri_rent_sty_id );

    -- Using the l_pri_rent_sty_id, identify the Dependent Income Stream Name,
    --  based on the Lease Contract Book Classification
    print(l_prog_name, 'Identifying the Dependent Income Stream Type Name' );
    IF p_deal_type = 'LEASEOP'
    THEN
      OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                          p_khr_id                => p_khr_id,
                          p_deal_type             => p_deal_type,
                          p_primary_sty_id        => l_pri_rent_sty_id,
                          p_dependent_sty_purpose => 'RENT_ACCRUAL',
                          x_return_status         => x_return_status,
                          x_dependent_sty_id      => l_inc_stream_id,
                          x_dependent_sty_name    => l_inc_stream_name);
      print(l_prog_name, '1. ' || p_deal_type || ': Income Stream Name = ' || l_inc_stream_name );
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF p_deal_type IN ('LEASEDF', 'LEASEST')
    THEN
      OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                          p_khr_id                => p_khr_id,
                          p_deal_type             => p_deal_type,
                          p_primary_sty_id        => l_pri_rent_sty_id,
                          p_dependent_sty_purpose => 'LEASE_INCOME',
                          x_return_status         => x_return_status,
                          x_dependent_sty_id      => l_inc_stream_id,
                          x_dependent_sty_name    => l_inc_stream_name);
      print(l_prog_name, '2. ' || p_deal_type || ': Income Stream Name = ' || l_inc_stream_name );
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF p_deal_type IN ('LOAN', 'LOAN-REVOLVING')
    THEN
      OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                         p_khr_id                => p_khr_id,
                         p_deal_type             => p_deal_type,
                         p_primary_sty_id        => l_pri_rent_sty_id,
                         p_dependent_sty_purpose => 'INTEREST_INCOME',
                         x_return_status         => x_return_status,
                         x_dependent_sty_id      => l_inc_stream_id,
                         x_dependent_sty_name    => l_inc_stream_name);
      print(l_prog_name, '3. ' || p_deal_type || ': Income Stream Name = ' || l_inc_stream_name );
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- Initialize the variable l_need_to_fetch_inc_strms
    l_need_to_fetch_inc_strms := 'Y';

    IF p_deal_type NOT IN ('LEASEOP' )
    THEN
      -- Fetch all the Income Streams of the Contract
      -- Consolidate and calculate the Income Proportions for all
      --  the Income Stream Elements after the Last Accrued Date
      print(l_prog_name, 'Executing the Cursor c_k_income: (p_sty_name | p_start_date | p_end_date | p_purpose_code )'  );
      print(l_prog_name, '(' || l_inc_stream_name || '|' || p_start_date || '|' || p_end_date || '|' ||
                              p_purpose_code || ')' );
      print(l_prog_name, 'WORK: Contract Level Income Streams After' ||
                          l_last_accrued_date || '[Last Accrued Date] '  );
      print(l_prog_name, 'Date | Amount ' );
      inx_tot_inc       := 1;
      ln_tot_inc_amount := 0;
      FOR inc_rec IN c_k_income(
              p_sty_name     => l_inc_stream_name
             ,p_start_date   => p_start_date
             ,p_end_date     => p_end_date
             ,p_purpose_code => p_purpose_code
          )
      LOOP
        IF inc_rec.income_date > l_last_accrued_date
        THEN
          print(l_prog_name, inc_rec.income_date || '|' || inc_rec.income_amount );
          -- Store it in the Income Streams Tbl
          income_streams_tbl(inx_tot_inc).income_date   := inc_rec.income_date;
          income_streams_tbl(inx_tot_inc).income_amount := inc_rec.income_amount;
          -- Calculate the Total Income Amount
          ln_tot_inc_amount := ln_tot_inc_amount + income_streams_tbl(inx_tot_inc).income_amount;
          -- Increment the inx_tot_inc index
          inx_tot_inc := inx_tot_inc + 1;
        END IF;
      END LOOP;
      -- Calculate the Income Proportions for the Income Streams fetched above
      print(l_prog_name, 'Calculating the Income Proporitions for the Income Streams ' );
      IF income_streams_tbl.COUNT > 0
      THEN
        print(l_prog_name, 'Date | Amount | Total Income Amount | Income Proportion ' );
        FOR inx_tot_inc IN income_streams_tbl.FIRST .. income_streams_tbl.LAST
        LOOP
          income_streams_tbl(inx_tot_inc).income_proportion :=
            income_streams_tbl(inx_tot_inc).income_amount / ln_tot_inc_amount;
          print(l_prog_name, income_streams_tbl(inx_tot_inc).income_date || '|' ||
                             income_streams_tbl(inx_tot_inc).income_amount || '|' ||
                             ln_tot_inc_amount || '|' ||
                             income_streams_tbl(inx_tot_inc).income_proportion );
        END LOOP;
      END IF; -- IF income_streams_tbl.COUNT > 0
      -- Flaging off the variable l_need_to_fetch_inc_strms
      l_need_to_fetch_inc_strms := 'N';
    END IF;

    -- Fetch all the streams for this Accrual Streams already generated
    --   and eligible for Prospective Rebooking
    IF l_flip_prb_rbk_reason = 'NO_REASON'
    THEN
      -- Initialize the Index i for the Bulk Update of all the Eligible Streams
      i := 1;
      print(l_prog_name, 'Fetching all the Eligible Accrual Stream Elements '
            || 'p_khr_id=' || p_khr_id || 'p_say_code=WORK p_purpose='|| p_purpose_code );
      FOR t_rec IN lcu_get_accrual_streams(
                      p_khr_id        => p_khr_id
                     ,p_say_code      => 'WORK'
                     ,p_purpose       => p_purpose_code )
      LOOP
        -- For each Accrual Stream Header, proceed to adjust the streams
        --  prospectively
        l_kle_id  := t_rec.kle_id;
        l_sty_id  := t_rec.sty_id;
        l_stm_id  := t_rec.stm_id;
        l_stm_purpose := t_rec.stm_purpose;
        -- Delete the Old Streams Collection for each iteration
        l_accrual_streams_tbl.DELETE;
        l_work_acc_strms_tbl.DELETE;
        l_curr_acc_strms_tbl.DELETE;

        print(l_prog_name, 'Handling the Stream (Stream Name, Purpose, khr_id, kle_id, sty_id, stm_id) = ' ||
           t_rec.sty_code || ' | ' || t_rec.sty_purpose || ' | ' ||
           p_khr_id || ',' || l_kle_id || ',' || l_sty_id || ',' || l_stm_id );
        l_flip_prb_rbk_reason   := 'WORK_STRMS_NOT_FOUND';
        -- Step 1:
        --   Fetch the Stream Elements for the current version. [Status = WORK]
        print(l_prog_name, 'WORK Streams ' );
        print(l_prog_name, 'Date|Amount|Arrears ');
        -- Re-Initialize the variables related to the WORK Accrual Streams
        inx_work := 1;
        ln_work_acc_amount  := 0;
        ln_tot_work_acc_amt := 0;
        FOR t_rec IN get_strms_csr(
               p_khr_id       => p_khr_id
              ,p_kle_id       => l_kle_id
              ,p_sty_id       => l_sty_id
              ,p_purpose_code => p_purpose_code
              ,p_say_code     => 'WORK')
        LOOP
          l_work_acc_strms_tbl(inx_work) := t_rec;
          print(l_prog_name, l_work_acc_strms_tbl(inx_work).se_date
                || '|' || l_work_acc_strms_tbl(inx_work).se_amount
                || '|' || l_work_acc_strms_tbl(inx_work).se_arrears );
          IF TRUNC(l_work_acc_strms_tbl(inx_work).se_date) <= l_last_accrued_date
          THEN
            ln_work_acc_amount := ln_work_acc_amount +
                                  l_work_acc_strms_tbl(inx_work).se_amount;
          END IF;
          ln_tot_work_acc_amt := ln_tot_work_acc_amt + l_work_acc_strms_tbl(inx_work).se_amount;
          -- Increment the inx_work
          inx_work := inx_work + 1;
        END LOOP;
        IF l_work_acc_strms_tbl.COUNT > 0
        THEN
          l_flip_prb_rbk_reason   := 'NO_REASON';
        END IF;

        -- Step 2:
        --   Fetch the Original Contract Id and Kle_id and fetch CURR status streams
        -- First, fetch the Original Contract and Configuration Line ID
        IF l_flip_prb_rbk_reason = 'NO_REASON'
        THEN
          -- Only in case of Online Rebook, we need to fetch the
          --  Streams using the Original contract and Line Id
          IF l_rebook_type = 'ONLINE_REBOOK'
          THEN
            print( l_prog_name, 'Fetching Original Line and Contract Id. Rebook Type' || l_rebook_type );
            l_flip_prb_rbk_reason := 'ORIG_KHR_KLE_ID_NOT_FOUND';
            FOR t1_rec IN get_orig_khr_dtls_csr  (
                           p_kle_id => l_kle_id )
            LOOP
              l_orig_khr_id := t1_rec.orig_khr_id;
              l_orig_kle_id := t1_rec.orig_kle_id;
              l_flip_prb_rbk_reason := 'NO_REASON';
            END LOOP;
          ELSE
            -- Mass Rebook flows
            print( l_prog_name, 'Using current Line and Contract Id. Rebook Type=' || l_rebook_type );
            l_orig_khr_id := p_khr_id;
            l_orig_kle_id := l_kle_id;
          END IF;
          print( l_prog_name, 'Original Contract Id | Original Line Id ' );
          print( l_prog_name, l_orig_khr_id || ' | ' || l_orig_kle_id );
        END IF; -- IF l_flip_prb_rbk_reason = 'NO_REASON'

        IF l_flip_prb_rbk_reason = 'NO_REASON'
        THEN
          l_flip_prb_rbk_reason   := 'CURR_STRMS_NOT_FOUND';
          print( l_prog_name, 'Fetching the Original CURR Streams ');
          -- Fetch the Original Streams, status = CURR
          print(l_prog_name, 'CURR Streams ' );
          print(l_prog_name, 'Date|Amount|Arrears ');
          inx_curr := 1;
          ln_curr_acc_amount := 0;
          FOR t_rec IN get_strms_csr(
                 p_khr_id       => l_orig_khr_id
                ,p_kle_id       => l_orig_kle_id
                ,p_sty_id       => l_sty_id
                ,p_purpose_code => p_purpose_code
                ,p_say_code     => 'CURR')
          LOOP
            l_curr_acc_strms_tbl(inx_curr) := t_rec;
            print(l_prog_name, l_curr_acc_strms_tbl(inx_curr).se_date
                  || '|' || l_curr_acc_strms_tbl(inx_curr).se_amount
                  || '|' || l_curr_acc_strms_tbl(inx_curr).se_arrears );
            IF TRUNC(l_curr_acc_strms_tbl(inx_curr).se_date) <= l_last_accrued_date
            THEN
              ln_curr_acc_amount := ln_curr_acc_amount +
                                    l_curr_acc_strms_tbl(inx_curr).se_amount;
            END IF;
            -- Increment the inx_curr
            inx_curr := inx_curr + 1;
          END LOOP;
          IF l_curr_acc_strms_tbl.COUNT > 0
          THEN
            l_flip_prb_rbk_reason   := 'NO_REASON';
          END IF;
        END IF;

        IF l_stm_purpose IN (
              'AMORTIZE_FEE_INCOME'
             ,'AMORTIZED_FEE_EXPENSE'
             ,'SUBSIDY_INCOME'
           )
        THEN
          -- Handle the Case when the Contract is a Operating Lease
          --   and the Current Accrual is a Non-Rental Accrual Stream
          --   and till now we have not fetched and calculated the Income Proportions
          IF p_deal_type IN ('LEASEOP' )  -- Operating Lease Contract
             AND t_rec.sty_priority = 99  -- Non Rental Accrual Streams
             AND l_need_to_fetch_inc_strms = 'Y' -- Till Now the Income Streams are not fetched
          THEN
            print(l_prog_name, '!!!!! First of all, fetching the Income Proportions of the Rental Accruals !!!!! ' );
            -- First Step: Bulk Update all the Prospectively adjusted Rental Accrual Streams till now
            print(l_prog_name, 'Total Number of Rental Accrual Stream Elements to be updated ' || l_sel_id_tbl.COUNT );
            IF l_sel_id_tbl.COUNT > 0
            THEN
              print(l_prog_name, 'Start: Performaing the Bulk Update of ' || l_sel_id_tbl.COUNT || ' Streams. '
                                 || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
              -- Bulk update
              FORALL i in l_sel_id_tbl.FIRST .. l_sel_id_tbl.LAST
                 UPDATE okl_strm_elements
                    SET amount = l_sel_amt_tbl(i)
                  WHERE id     = l_sel_id_tbl(i)
                    AND stm_id = l_stm_id_tbl(i);
              print(l_prog_name, 'Done: Performaing the Bulk Update of ' || l_sel_id_tbl.COUNT || ' Streams '
                                 || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
            END IF;
            -- Re-Initialize the collections used for the Bulk Update
            i := 1;
            l_sel_id_tbl.DELETE;
            l_sel_amt_tbl.DELETE;
            -- Next time onwards, we dont need to fetch the Rental Income Streams again
            l_need_to_fetch_inc_strms := 'N';

            -- Fetch all the Income Streams of the Contract
            -- Consolidate and calculate the Income Proportions for all
            --  the Income Stream Elements after the Last Accrued Date
            print(l_prog_name, 'Executing the Cursor c_k_income: (p_sty_name | p_start_date | p_end_date | p_purpose_code )'  );
            print(l_prog_name, '(' || l_inc_stream_name || '|' || p_start_date || '|' || p_end_date || '|' ||
                                    p_purpose_code || ')' );
            print(l_prog_name, 'WORK: Contract Level Income Streams After' ||
                                l_last_accrued_date || '[Last Accrued Date] '  );
            print(l_prog_name, 'Date | Amount ' );
            inx_tot_inc       := 1;
            ln_tot_inc_amount := 0;
            FOR inc_rec IN c_k_income(
                    p_sty_name     => l_inc_stream_name
                   ,p_start_date   => p_start_date
                   ,p_end_date     => p_end_date
                   ,p_purpose_code => p_purpose_code
                )
            LOOP
              IF inc_rec.income_date > l_last_accrued_date
              THEN
                print(l_prog_name, inc_rec.income_date || '|' || inc_rec.income_amount );
                -- Store it in the Income Streams Tbl
                income_streams_tbl(inx_tot_inc).income_date   := inc_rec.income_date;
                income_streams_tbl(inx_tot_inc).income_amount := inc_rec.income_amount;
                -- Calculate the Total Income Amount
                ln_tot_inc_amount := ln_tot_inc_amount + income_streams_tbl(inx_tot_inc).income_amount;
                -- Increment the inx_tot_inc index
                inx_tot_inc := inx_tot_inc + 1;
              END IF;
            END LOOP;
            -- Calculate the Income Proportions for the Income Streams fetched above
            print(l_prog_name, 'Calculating the Income Proporitions for the Income Streams ' );
            IF income_streams_tbl.COUNT > 0
            THEN
              print(l_prog_name, 'Date | Amount | Total Income Amount | Income Proportion ' );
              FOR inx_tot_inc IN income_streams_tbl.FIRST .. income_streams_tbl.LAST
              LOOP
                income_streams_tbl(inx_tot_inc).income_proportion :=
                  income_streams_tbl(inx_tot_inc).income_amount / ln_tot_inc_amount;
                print(l_prog_name, income_streams_tbl(inx_tot_inc).income_date || '|' ||
                                   income_streams_tbl(inx_tot_inc).income_amount || '|' ||
                                   ln_tot_inc_amount || '|' ||
                                   income_streams_tbl(inx_tot_inc).income_proportion );
              END LOOP;
            END IF; -- IF income_streams_tbl.COUNT > 0
          END IF;

          print(l_prog_name, '**************************************************' );
          print(l_prog_name, '******** Using Spread By Income Algorithm ********' );
          print(l_prog_name, '**************************************************' );

          -- Prospectively Adjusting those Accrual Streams
          --   which are generated using the Spread By Income Logic
          IF l_flip_prb_rbk_reason = 'NO_REASON'
          THEN
            print( l_prog_name, 'WORK: Total Accurual Income Amount = ' || ln_tot_work_acc_amt );
            print( l_prog_name, 'CURR: Total Accrual Amount before Last Accrued Date = ' || ln_curr_acc_amount );
            -- Calculating the Remaining Accrual Amount to be Spread after the Rebook Effective Date
            l_acc_adjustment := ln_tot_work_acc_amt - ln_curr_acc_amount;
            print(l_prog_name, 'Date | WORK: SEL Amount | Income Amount | Income Total | Income Proportion | ' ||
						                   'CURR: SEL Amount | Prosp. Adjusted Amount');
            FOR inx_work IN l_work_acc_strms_tbl.FIRST .. l_work_acc_strms_tbl.LAST
            LOOP
              -- For reporting purposes store the current stream element amount
              ln_amt_before_adjustment :=  l_work_acc_strms_tbl(inx_work).se_amount;
              -- Step : {Prospective Adjustment}
              --  For Stream Element whose Date <= Last Accrued Date, update the amount
              --   with that of the CURR Accrual Amount.
              -- If the Stream Element is Accrued on or Before the Last Accrued Date
              IF l_work_acc_strms_tbl(inx_work).se_date <= l_last_accrued_date
              THEN
                FOR inx_curr IN l_curr_acc_strms_tbl.FIRST .. l_curr_acc_strms_tbl.LAST
                LOOP
                  IF TRUNC( l_curr_acc_strms_tbl(inx_curr).se_date ) =
                     TRUNC( l_work_acc_strms_tbl(inx_work).se_date )
                  THEN
                    l_work_acc_strms_tbl(inx_work).se_amount := l_curr_acc_strms_tbl(inx_curr).se_amount ;
                    print(l_prog_name,
                       l_work_acc_strms_tbl(inx_work).se_date || '|' ||  -- SEL Date
                       ln_amt_before_adjustment || ' | ' || -- WORK SEL Amount
                       ' - ' || ' | ' ||  -- Income Amount
                       ' - ' || ' | ' ||  -- Income Total
                       ' - ' || ' | ' ||  -- Income Proportion
                       l_curr_acc_strms_tbl(inx_curr).se_amount || ' | ' ||  -- CURR SEL Amount
                       l_work_acc_strms_tbl(inx_work).se_amount -- Prospectively Adjusted SEL Amount
                    );
                    EXIT; -- Break it now, no further iterations required
                  END IF;
                END LOOP;
              ELSE
                -- Stream Element has been accrued after the Last Accrued Date
                FOR inx_tot_inc IN income_streams_tbl.FIRST .. income_streams_tbl.LAST
                LOOP
                  IF income_streams_tbl(inx_tot_inc).income_date =
                     l_work_acc_strms_tbl(inx_work).se_date
                  THEN
                    -- Modify the Accrual Amount as Income Proportion *
                    --  Remaining Accrual Amount to Be Spread
                    l_work_acc_strms_tbl(inx_work).se_amount :=
                      income_streams_tbl(inx_tot_inc).income_proportion * l_acc_adjustment;
                    print(l_prog_name,
                           l_work_acc_strms_tbl(inx_work).se_date || '|' ||  -- SEL Date
                           ln_amt_before_adjustment || ' | ' || -- WORK SEL Amount
                           income_streams_tbl(inx_tot_inc).income_amount || ' | ' ||  -- Income Amount
                           ln_tot_inc_amount || ' | ' ||  -- Income Total
                           income_streams_tbl(inx_tot_inc).income_proportion || ' | ' ||  -- Income Proportion
                           '_' || ' | ' ||  -- CURR SEL Amount
                           l_work_acc_strms_tbl(inx_work).se_amount -- Prospectively Adjusted SEL Amount
                    );
                    EXIT; -- Break it now, no further iterations required
                  END IF;
                END LOOP; -- End Loop on the income_streams_tbl.
              END IF; -- If stream element date <= Last Accured Date
              -- Store this updated amount and ids for bulk updation later
              l_sel_id_tbl(i)     := l_work_acc_strms_tbl(inx_work).sel_id;
              l_stm_id_tbl(i)     := l_work_acc_strms_tbl(inx_work).stm_id;
              l_sel_amt_tbl(i)    := l_work_acc_strms_tbl(inx_work).se_amount;
              -- Increment the index
              i := i + 1;
            END LOOP; -- FOR inx_work IN l_work_acc_strms_tbl.FIRST ..
          END IF;
          print(l_prog_name, '****** Done: Using Spread By Income Algorithm ****' );
        ELSE
          -- Prospectively Adjusting those Accrual Streams
          --   which are generated using the Straight Line Algorithm
          -- Calculate the Total Accrual Adjustment that needs to be proportionately distributed
          print(l_prog_name, '**************************************************' );
          print(l_prog_name, '********** Using Straight Line Algorithm *********' );
          print(l_prog_name, '**************************************************' );
          l_acc_adjustment := NVL( ( ln_work_acc_amount - ln_curr_acc_amount ), 0 );
          print(l_prog_name, 'SUM(Acc Before Revision) | SUM(Acc After Revision) | Adjustment Amount' );
          print(l_prog_name, ln_curr_acc_amount || ' | ' || ln_work_acc_amount || ' | ' || l_acc_adjustment );

          IF NVL(l_acc_adjustment,0) = 0
          THEN
             l_flip_prb_rbk_reason  := 'NOTHING_TO_ADJUST';
          END IF;

          IF l_flip_prb_rbk_reason = 'NO_REASON'
          THEN
            -- Rebook Effective Day is the next of the Last Accrued Day
            l_rebook_eff_date := l_last_accrued_date + 1;
            -- End Date: Considered it as Minimum (Last Accrual Element Date, Contract End Date)
            -- l_term_end_date := TRUNC(p_end_date);
            -- IF  TRUNC(l_work_acc_strms_tbl(l_work_acc_strms_tbl.LAST).se_date) < l_term_end_date
            -- THEN
            --  l_term_end_date := TRUNC(l_work_acc_strms_tbl(l_work_acc_strms_tbl.LAST).se_date);
            -- END IF;
            l_term_end_date := TRUNC(p_end_date);
            IF l_stm_purpose IN (
                  'RENT_ACCRUAL' )
            THEN
              -- As part of the bug 9305846, Rental accruals are always generated
              --  till the end of the contract term
              l_term_end_date := TRUNC(p_end_date);
            ELSIF l_stm_purpose IN (
                  'ACCRUED_FEE_INCOME'
                 ,'SERVICE_INCOME'
                 ,'PASS_THRU_REV_ACCRUAL' )
            THEN
              print(l_prog_name, 'get_payment_sll_dtls_csr: Fetching the Payment Level Details for (khr_id, kle_id)= ('
                    || p_khr_id || ' , ' || l_kle_id || ')' );
              --  Fetch the End Date for the Last Payment Level of the RENT/Fee Payment/Service Payment
              --  and consider that as the l_term_end_date
              FOR t_sll_rec IN get_payment_sll_dtls_csr(
                              p_khr_id => p_khr_id
                             ,p_kle_id => l_kle_id )
              LOOP
                l_term_end_date := t_sll_rec.end_date;
              END LOOP;
            ELSIF l_stm_purpose IN ( 'ACCRUED_FEE_EXPENSE' )
            THEN
              print(l_prog_name, 'get_exp_end_date_csr: Fetching the Payment Level Details for (khr_id, kle_id)= ('
                    || p_khr_id || ' , ' || l_kle_id || ')' );
              --  Fetch the End Date for the Last Payment Level of the RENT/Fee Payment/Service Payment
              --  and consider that as the l_term_end_date
              FOR t_exp_rec IN get_exp_end_date_csr(
                              p_khr_id => p_khr_id
                             ,p_kle_id => l_kle_id )
              LOOP
                l_term_end_date := t_exp_rec.end_date;
                print(l_prog_name,'Line Type = Fee. Fee Type =  ' || t_exp_rec.fee_type
                      || ' Start Date = ' || t_exp_rec.start_date
                      || 'Month
                      nn:/s/Period = ' || t_exp_rec.mpp
                      || 'Periods = '  || t_exp_rec.periods
                      || 'Amouont = '  || t_exp_rec.amount
                      || 'End Date = ' || t_exp_rec.end_date);
              END LOOP;
            END IF;
            -- Step: Calculate the Number of the Remaining Days
            --       For time being assuming that the end is till Contract End Date
            l_rem_days := OKL_PRICING_UTILS_PVT.get_day_count(
                             p_start_date    => l_rebook_eff_date
                            ,p_days_in_month => l_day_convention_month
                            ,p_days_in_year  => l_day_convention_year
                            ,p_end_date      => l_term_end_date
                            ,p_arrears       => 'Y'
                            ,x_return_status => x_return_status);
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            print(l_prog_name, 'Rebook Effective Date | End Date | Days Remaining' );
            print(l_prog_name,l_rebook_eff_date ||' | ' || l_term_end_date || ' | ' || l_rem_days);

            IF l_rem_days IS NULL OR l_rem_days <= 0
            THEN
              l_flip_prb_rbk_reason := 'INVALID_REM_DAYS';
              print(l_prog_name,'Invalid # of Remaining Days ' || l_rem_days );
            END IF;
          END IF;
          -- Check and Proceed
          IF l_flip_prb_rbk_reason = 'NO_REASON'
          THEN
            -- Step Modify the WORK Accrual Stream to the CURR Accrual Stream Amount
            -- If Accrual is before the Last Accrual Date:
            --     then copy the Old Accrual Amount
            -- If Accrual is after the Last Accrual Date:
            --     then Add the accrual adjustment amount also
            print(l_prog_name, '# | Start Date | End Date | Days/Period | Total Days | Amount | Adj Amount | Modified Amount | Cummulative Adj Total');
            inx_work := 1;
            l_tot_per_adjustment := 0;
            FOR inx_work IN l_work_acc_strms_tbl.FIRST .. l_work_acc_strms_tbl.LAST
            LOOP
              -- Derieve the Period Start Date. First of the Current Accrual Month.
              l_per_start_date :=
                LAST_DAY( ADD_MONTHS(l_work_acc_strms_tbl(inx_work).se_date, -1) ) + 1;
              -- Derieve the Period End Date
              l_per_end_date := l_work_acc_strms_tbl(inx_work).se_date;
              IF inx_work = l_work_acc_strms_tbl.LAST
              THEN
                -- Last Accrual Stream Element
                l_per_end_date := l_term_end_date;
              END IF;
              IF l_work_acc_strms_tbl(inx_work).se_date <= l_last_accrued_date
              THEN
                l_un_modified_amount := l_work_acc_strms_tbl(inx_work).se_amount;
                -- Accrual Element is On or Before the Last Accrual Date
                -- Find the Accrual Amount before revision and update the amount on it
                FOR t_in IN l_curr_acc_strms_tbl.FIRST .. l_curr_acc_strms_tbl.LAST
                LOOP
                  IF l_work_acc_strms_tbl(inx_work).se_date = l_curr_acc_strms_tbl(t_in).se_date
                  THEN
                    -- Modify the Work Accrual Stream Amount to as that of the Current one
                    l_work_acc_strms_tbl(inx_work).se_amount := l_curr_acc_strms_tbl(t_in).se_amount;
                    EXIT;
                  END IF;
                END LOOP; -- Loop on the l_curr_acc_strms_tbl
                print(l_prog_name, inx_work || ' | ' || l_per_start_date || ' | ' || l_per_end_date || ' | ' ||
                      '-  | -  | ' || l_un_modified_amount
                      || ' | - | ' || l_work_acc_strms_tbl(inx_work).se_amount
                      || ' | - | ' );
              ELSE
                -- Accrual Amount after the Last Accrued Date
                l_per_days := OKL_PRICING_UTILS_PVT.get_day_count(
                               p_start_date    => l_per_start_date
                              ,p_days_in_month => l_day_convention_month
                              ,p_days_in_year  => l_day_convention_year
                              ,p_end_date      => l_per_end_date
                              ,p_arrears       => 'Y'
                              ,x_return_status => x_return_status);
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                l_per_adjustment := l_acc_adjustment * l_per_days / l_rem_days;

                -- Store the Accrual Adjustment prior modifications for reporting purposes
                l_un_modified_amount := l_work_acc_strms_tbl(inx_work).se_amount;
                IF inx_work = l_work_acc_strms_tbl.LAST
                THEN
                  -- Calculate the Remaining Accrual Adjustment Amount
                  l_per_rounded_adjustment := l_acc_adjustment - l_tot_per_adjustment;
                  -- Add the remaining Accrual Adjustment to the Last Accrual Stream Element
                  l_work_acc_strms_tbl(inx_work).se_amount := l_work_acc_strms_tbl(inx_work).se_amount
                    + l_per_rounded_adjustment;
                ELSE
                  -- Round the Accrual Adjustment Amount
                  okl_accounting_util.round_amount(
                     p_api_version   => p_api_version
                    ,p_init_msg_list => OKL_API.G_FALSE
                    ,x_return_status => x_return_status
                    ,x_msg_count     => x_msg_count
                    ,x_msg_data      => x_msg_data
                    ,p_amount        => l_per_adjustment
                    ,p_currency_code => p_currency_code
                    ,p_round_option  => 'STM'
                    ,x_rounded_amount => l_per_rounded_adjustment);
                  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                  -- Add the Accrual Adjustment amount
                  l_work_acc_strms_tbl(inx_work).se_amount := l_work_acc_strms_tbl(inx_work).se_amount
                    + l_per_rounded_adjustment;
                  -- Accumulate the Accrual Adjustment Amount
                  l_tot_per_adjustment := l_tot_per_adjustment + l_per_rounded_adjustment;
                END IF;
                print(l_prog_name, inx_work || ' | ' || l_per_start_date || ' | ' || l_per_end_date || ' | ' ||
                      l_per_days || ' | ' || l_rem_days || ' | ' || l_un_modified_amount
                      || ' | ' || l_per_rounded_adjustment || ' | ' || l_work_acc_strms_tbl(inx_work).se_amount
                      || ' | ' || l_tot_per_adjustment );
              END IF;
              -- Store this updated amount and ids for bulk updation later
              l_sel_id_tbl(i)     := l_work_acc_strms_tbl(inx_work).sel_id;
              l_stm_id_tbl(i)     := l_work_acc_strms_tbl(inx_work).stm_id;
              l_sel_amt_tbl(i)    := l_work_acc_strms_tbl(inx_work).se_amount;
              -- Increment the index
              i := i + 1;
            END LOOP; -- Loop on the l_work_acc_strms_tbl
          END IF;
          print(l_prog_name, '******* Done: Using Straight Line Algorithm ******' );
        END IF; -- IF: Split on the Spread By Income/Straight Line Logic
      END LOOP; -- Loop on the eligible Accrual Streams

      -- Step:
      --   For all the updated streams, perform the bulk update in one go
      print(l_prog_name, 'Total Number of Stream Elements to be updated ' || l_sel_id_tbl.COUNT );
      IF l_sel_id_tbl.COUNT > 0
      THEN
        print(l_prog_name, 'Start: Performaing the Bulk Update of ' || l_sel_id_tbl.COUNT || ' Streams. '
                           || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
        -- Bulk update
        FORALL i in l_sel_id_tbl.FIRST .. l_sel_id_tbl.LAST
           UPDATE okl_strm_elements
              SET amount = l_sel_amt_tbl(i)
            WHERE id     = l_sel_id_tbl(i)
              AND stm_id = l_stm_id_tbl(i);
        print(l_prog_name, 'Done: Performaing the Bulk Update of ' || l_sel_id_tbl.COUNT || ' Streams '
                           || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') );
      END IF;

    ELSE
      print(l_prog_name, 'Switched Back to Retrospective Method. Reason= ' || l_flip_prb_rbk_reason);
    END IF;  -- If l_flip_prb_rbk_reason = 'NO_REASON'
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);
    print( l_api_name, 'end' );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

    WHEN OTHERS
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OTHERS',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);
  END prosp_adj_acc_strms;

  ---------------------------------------------------------------------------
  -- PROCEDURE generate_streams
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  /*
   *  single point entry for streams generation.
   *  p_compute_irr : boolean to calculate irr.
   *  p_gen.._type  : FULL, SERVICE_ACCRUAL, etc
   *  p_repor..class: streams for reporting product. yields are not calculated for report.
   */
  PROCEDURE generate_streams( p_api_version                IN         NUMBER,
                              p_init_msg_list              IN         VARCHAR2,
                              p_khr_id                     IN         NUMBER,
                              p_compute_rates              IN         VARCHAR2,
                              p_generation_type            IN         VARCHAR2,
                              p_reporting_book_class       IN         VARCHAR2,
                              x_contract_rates             OUT NOCOPY rate_rec_type,
                              x_return_status              OUT NOCOPY VARCHAR2,
                              x_msg_count                  OUT NOCOPY NUMBER,
                              x_msg_data                   OUT NOCOPY VARCHAR2) IS

    lx_return_status              VARCHAR2(1);

    lx_isAllowed                  BOOLEAN;
    lx_passStatus                 VARCHAR2(30);
    lx_failStatus                 VARCHAR2(30);


    CURSOR c_hdr IS
      SELECT chr.template_yn,
             chr.currency_code,
             chr.start_date,
             chr.end_date,
             khr.deal_type,
             khr.term_duration,
             NVL(khr.generate_accrual_yn, 'Y'),
	     nvl(rpar.base_rate, 10) base_rate
      FROM   okc_k_headers_b chr,
             okl_k_headers khr,
             OKL_K_RATE_PARAMS rpar
      WHERE  khr.id = p_khr_id
        AND  chr.id = khr.id
	AND  rpar.khr_id(+) = khr.id;

    l_hdr                    c_hdr%ROWTYPE;
    l_deal_type              VARCHAR2(30);
    l_purpose_code           VARCHAR2(30);

    p_compute_irr VARCHAR2(1) :=  p_compute_rates;

    CURSOR c_niv (kleId NUMBER) IS
      SELECT FND_NUMBER.canonical_to_number(rul2.rule_information6) amount,
             TO_NUMBER(rul2.rule_information8) stub_amount
      FROM   okc_rule_groups_b rgp,
             okc_rules_b rul1,
             okc_rules_b rul2,
             okc_k_lines_b cle,
             okl_k_lines kle,
             okc_line_styles_b lse,
	     okl_strm_type_b sty
      WHERE  rul2.dnz_chr_id = p_khr_id
        AND  rul2.rule_information_category = 'LASLL'
        AND  rul2.rgp_id = rgp.id
        AND  TO_NUMBER(rul2.object2_id1) = rul1.id
        AND  rgp.cle_id = cle.id
        AND  cle.sts_code = 'TERMINATED'
        AND  cle.id = kle.id
        AND  cle.lse_id = lse.id
	AND  cle.id = kleId
	AND  sty.id = rul1.object1_id1
	AND  sty.stream_type_purpose = 'TERMINATION_VALUE';

    r_niv c_niv%ROWTYPE;


    CURSOR c_inflows IS
      SELECT rgp.cle_id cle_id,
             TO_NUMBER(rul1.object1_id1) sty_id,
	     sty.stream_type_purpose,
             FND_DATE.canonical_to_date(rul2.rule_information2) start_date,
             TO_NUMBER(rul2.rule_information3) periods,
             rul2.object1_id1 frequency,
             rul2.rule_information5 structure,
             DECODE(rul2.rule_information10, 'Y', 'ARREARS', 'ADVANCE') advance_arrears,
             FND_NUMBER.canonical_to_number(rul2.rule_information6) amount,
             TO_NUMBER(rul2.rule_information7) stub_days,
             TO_NUMBER(rul2.rule_information8) stub_amount,
             lse.lty_code lty_code,
             kle.capital_amount capital_amount,
             kle.residual_value residual_value,
	     kle.fee_type fee_type
      FROM   okc_rule_groups_b rgp,
             okc_rules_b rul1,
             okc_rules_b rul2,
             okc_k_lines_b cle,
             okl_k_lines kle,
             okc_line_styles_b lse,
	     okl_strm_type_b sty
      WHERE
             rul2.dnz_chr_id = p_khr_id
        AND  rul2.rule_information_category = 'LASLL'
        AND  rul2.rgp_id = rgp.id
        AND  TO_NUMBER(rul2.object2_id1) = rul1.id
        AND  rgp.cle_id = cle.id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.id = kle.id
        AND  cle.lse_id = lse.id
	AND  sty.id = rul1.object1_id1
      UNION
      SELECT TO_NUMBER(NULL) cle_id,
             TO_NUMBER(rul1.object1_id1) sty_id,
	     sty.stream_type_purpose,
             FND_DATE.canonical_to_date(rul2.rule_information2) start_date,
             TO_NUMBER(rul2.rule_information3) periods,
             rul2.object1_id1 frequency,
             rul2.rule_information5 structure,
             DECODE(rul2.rule_information10, 'Y', 'ARREARS', 'ADVANCE') advance_arrears,
             FND_NUMBER.canonical_to_number(rul2.rule_information6) amount,
             TO_NUMBER(rul2.rule_information7) stub_days,
             TO_NUMBER(rul2.rule_information8) stub_amount,
             NULL lty_code,
             TO_NUMBER(NULL) capital_amount,
             TO_NUMBER(NULL) residual_value,
	     NULL fee_type
      FROM   okc_rule_groups_b rgp,
             okc_rules_b rul1,
             okc_rules_b rul2,
	     okl_strm_type_b sty
      WHERE
             rul2.dnz_chr_id = p_khr_id
        AND  rul2.rule_information_category = 'LASLL'
        AND  rul2.rgp_id = rgp.id
        AND  rgp.cle_id IS NULL
	AND  sty.id = rul1.object1_id1
        AND  TO_NUMBER(rul2.object2_id1) = rul1.id;

    -- Added by RGOOTY. Bug 4403311
    TYPE l_inflows_tbl_type IS TABLE OF c_inflows%ROWTYPE
      INDEX BY BINARY_INTEGER;
    l_inflows_tbl                   l_inflows_tbl_type;
    inf_index                       NUMBER;
    inf_start_date                  DATE;
    l_use_first_pmnt_date           VARCHAR2(1);

    -- Added by RGOOTY. Bug 4403311: End

    CURSOR c_fin_assets IS
      SELECT kle.id,
             NVL(kle.residual_value, 0) residual_value,
             cle.start_date,
	     cle.sts_code,
	     kle.fee_type,
	     lse.lty_code,
	     kle.amount,
	     kle.capital_amount,
	     kle.capitalized_interest
      FROM   okc_k_lines_b cle,
             okl_k_lines kle,
             okc_line_styles_b lse
      WHERE  cle.dnz_chr_id = p_khr_id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
        AND  cle.lse_id = lse.id
        AND  (lse.lty_code = 'FREE_FORM1' OR
	      kle.fee_type = 'FINANCED' OR
	      kle.fee_type = 'ROLLOVER' OR
	      lse.lty_code = 'LINK_FEE_ASSET')
        AND  cle.id = kle.id;

    top_svc_rec top_svc_csr%ROWTYPE;

    Cursor c_rollover_pmnts( chrId NUMBER, kleId NUMBER ) IS
    Select nvl(slh.object1_id1, -1) styId
    From   OKC_RULE_GROUPS_B rgp,
           OKC_RULES_B sll,
           okc_rules_b slh,
	   okl_strm_type_b sty
    Where  slh.rgp_id = rgp.id
       and rgp.RGD_CODE = 'LALEVL'
       and sll.RULE_INFORMATION_CATEGORY = 'LASLL'
       and slh.RULE_INFORMATION_CATEGORY = 'LASLH'
       AND TO_CHAR(slh.id) = sll.object2_id1
       and rgp.dnz_chr_id = chrId
       and rgp.cle_id = kleId
       and sty.id = to_number(slh.object1_id1)
       and sty.stream_type_purpose NOT IN ('ESTIMATED_PROPERTY_TAX', 'UNSCHEDULED_PRINCIPAL_PAYMENT', 'DOWN_PAYMENT');
       --Added DOWN_PAYMENT by rgooty for bug 7536131
       --bug# 4092324 bug# 4122385

    r_rollover_pmnts c_rollover_pmnts%ROWTYPE;

    Cursor c_link_pmnts( chrId NUMBER, kleId NUMBER ) IS
    Select nvl(slh.object1_id1, -1) styId
    From   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl,
           okc_rules_b slh,
           okc_K_lines_b cle_lnk,
	   okl_K_lines kle_roll
    Where  slh.rgp_id = crg.id
       and crg.RGD_CODE = 'LALEVL'
       and crl.RULE_INFORMATION_CATEGORY = 'LASLL'
       and slh.RULE_INFORMATION_CATEGORY = 'LASLH'
       AND TO_CHAR(slh.id) = crl.object2_id1
       and crg.dnz_chr_id = chrId
       and crg.cle_id = kleId
       and crg.cle_id = cle_lnk.id
       and cle_lnk.cle_id = kle_roll.id
       and kle_roll.fee_type in ('ROLLOVER', 'FINANCED');

    r_link_pmnts c_link_pmnts%ROWTYPE;

    CURSOR c_pt_yn (p_cle_id NUMBER) IS
    Select 'Y'
    from dual
    where Exists (
    select vDtls.DISBURSEMENT_BASIS,
           vDtls.DISBURSEMENT_FIXED_AMOUNT,
	   vDtls.DISBURSEMENT_PERCENT,
	   vDtls.PROCESSING_FEE_BASIS,
	   vDtls.PROCESSING_FEE_FIXED_AMOUNT,
	   vDtls.PROCESSING_FEE_PERCENT
    from okl_party_payment_hdr vHdr,
         okl_party_payment_dtls vDtls
    where vDtls.payment_hdr_id = vHdr.id
      and vHdr.CLE_ID = p_cle_id);

    CURSOR c_financed_fees IS
    SELECT kle.id,
           nvl(kle.fee_type, 'LINK_FEE_ASSET') fee_type,
	   lse.lty_code
    FROM   okc_k_lines_b cle,
           okl_k_lines kle,
           okc_line_styles_b lse
    WHERE  cle.dnz_chr_id = p_khr_id
      AND  cle.sts_code IN ('PASSED', 'COMPLETE', 'TERMINATED')
      AND  cle.id = kle.id
      AND  cle.lse_id = lse.id
      AND  (kle.fee_type='FINANCED' OR kle.fee_type='ROLLOVER' OR lse.lty_code='LINK_FEE_ASSET');

    r_financed_fees c_financed_fees%ROWTYPE;

    l_primary_sty_id         NUMBER;

    l_pt_yn                  VARCHAR2(1);
    l_passthrough_id         NUMBER;

    l_sty_id                 NUMBER;
    l_sty_name               VARCHAR2(150);
    l_mapped_sty_name        VARCHAR2(150);

    l_pre_tax_inc_id         NUMBER;
    l_principal_id           NUMBER;
    l_interest_id            NUMBER;
    l_prin_bal_id            NUMBER;
    l_termination_id         NUMBER;

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_pt_tbl                 okl_streams_pub.selv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    l_pt_rec                 okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

    -- Loan Amortization
    l_principal_tbl          okl_streams_pub.selv_tbl_type;
    l_interest_tbl           okl_streams_pub.selv_tbl_type;
    l_prin_bal_tbl           okl_streams_pub.selv_tbl_type;
    l_termination_tbl        okl_streams_pub.selv_tbl_type;
    l_pre_tax_inc_tbl        okl_streams_pub.selv_tbl_type;

    l_capital_cost           NUMBER;
    l_interim_interest       NUMBER;
    l_interim_days           NUMBER;
    l_interim_dpp            NUMBER;
    l_asset_iir              NUMBER;
    l_asset_guess_iir        NUMBER;
    l_bkg_yield_guess        NUMBER;
    l_asset_booking_yield    NUMBER;

    l_interim_tbl            OKL_PRICING_PVT.interim_interest_tbl_type;
    l_sub_interim_tbl            OKL_PRICING_PVT.interim_interest_tbl_type;
    i                        BINARY_INTEGER := 0;

    l_payment_count          BINARY_INTEGER := 0;

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'generate_streams';

    prof_rate                   VARCHAR2(256);
    contract_comments VARCHAR2(256);

    l_recurr_yn  VARCHAR2(1) := NULL;
    l_blnHasFinFees VARCHAR2(1) := OKL_API.G_FALSE;

    l_clev_tbl okl_okc_migration_pvt.clev_tbl_type;
    l_klev_tbl okl_contract_pub.klev_tbl_type;
    x_clev_tbl okl_okc_migration_pvt.clev_tbl_type;
    x_klev_tbl okl_contract_pub.klev_tbl_type;

    l_PRE_TAX_IRR            NUMBER;
    l_IMPLICIT_INTEREST_RATE NUMBER;
    l_SUB_IMPL_INTEREST_RATE NUMBER;
    l_SUB_PRE_TAX_IRR        NUMBER;

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
	  and sts.ste_code not in ('HOLD', 'EXPIRED', 'CANCELLED'));

    r_subs c_subs%ROWTYPE;
    l_subsidies_yn VARCHAR2(1);
    l_subsidy_amount  NUMBER;
    l_residual_value  NUMBER;

    l_fee_type VARCHAR2(256);

    l_additional_parameters  OKL_EXECUTE_FORMULA_PUB.ctxt_val_tbl_type;

    l_sty_purpose VARCHAR2(256);

	     l_rent_sty_id NUMBER;


     CURSOR c_rent_sty_id (finfeesId NUMBER) IS
                       SELECT slh.object1_id1
                       FROM   okc_rules_b slh,
                              okc_rule_groups_b rgp
                       WHERE  rgp.dnz_chr_id = p_khr_id
                          AND  rgp.cle_id = finfeesId
                          AND  rgp.rgd_code= 'LALEVL'
                          AND  rgp.id = slh.rgp_id
                          AND  slh.rule_information_category = 'LASLH';
   -- Added by RGOOTY
   -- Assuming that there are no Services initially.
   exec_svc_csr VARCHAR2(1) := 'F';
   l_tmp_cle_id NUMBER;
   p_get_k_info_csr    OKL_ISG_UTILS_PVT.G_GET_K_INFO_CSR%ROWTYPE;

   l_initial_irr NUMBER := 0;
   l_asset_count NUMBER := 0;

    -- Added by RGOOTY for perf.: Bug Number 4346646 Start
    l_stmv_tbl              Okl_Streams_Pub.stmv_tbl_type;
    l_full_selv_tbl         Okl_Streams_Pub.selv_tbl_type;

    lx_stmv_tbl              Okl_Streams_Pub.stmv_tbl_type;
    lx_full_selv_tbl         Okl_Streams_Pub.selv_tbl_type;
    -- Added by RGOOTY for perf.: End

--Added by prasjain for bug 5474827
    l_se_id  NUMBER;
--end prasjain
    -- Prospective Rebooking Enhancement
    -- Applicabke for both ESG and ISG
    CURSOR isg_during_rbk_csr( p_khr_id    IN NUMBER)
    IS
    SELECT rbk_chr.contract_number       rbk_contract_number,
           rbk_chr.orig_system_id1       original_chr_id,
           trx.rbr_code                  rbk_reason_code,
           trx.date_transaction_occurred revision_date,
           'ONLINE_REBOOK'               rebook_type
           ,rbk_chr.start_date           rbk_chr_start_date
           ,orig_chr.start_date          orig_chr_start_date
      FROM okc_k_headers_all_b   rbk_chr,
           okc_k_headers_all_b   orig_chr,
           okl_trx_contracts_all trx
     WHERE rbk_chr.id = p_khr_id
       AND rbk_chr.orig_system_source_code = 'OKL_REBOOK'
       AND trx.khr_id_new = rbk_chr.id
       AND trx.tsu_code = 'ENTERED'
       AND trx.tcn_type = 'TRBK'
       AND rbk_chr.orig_system_id1 = orig_chr.id
    UNION
    SELECT orig_chr.contract_number       rbk_contract_number,
           orig_chr.id                    original_chr_id,
           trx.rbr_code                   rbk_reason_code,
           trx.date_transaction_occurred  revision_date,
           'MASS_REBOOK'                  rebook_type
           ,orig_chr.start_date           rbk_chr_start_date
           ,orig_chr.start_date           orig_chr_start_date
      FROM okc_k_headers_all_b orig_chr,
           okl_trx_contracts_all trx
     WHERE  orig_chr.id    =  p_khr_id
      AND  trx.khr_id     =  orig_chr.id
      AND  trx.tsu_code   = 'ENTERED'
      AND  trx.tcn_type   = 'TRBK'
      AND  EXISTS
           (
            SELECT '1'
              FROM okl_rbk_selected_contract rbk_chr
             WHERE rbk_chr.khr_id = orig_chr.id
               AND rbk_chr.status <> 'PROCESSED'
            );

   -- Cursor to fetch the Prospective Rebooking Option from System Options
   CURSOR is_prospective_rbk_csr(p_khr_id  NUMBER)
   IS
   SELECT amort_inc_adj_rev_dt_yn   rbk_prospectively
     FROM okl_sys_acct_opts_all     sysop
         ,okc_k_headers_b           chr
    WHERE sysop.org_id = chr.authoring_org_id;

   l_rebook_date              DATE;
   l_prb_orig_khr_id          NUMBER;
   l_prosp_rebook_flag        VARCHAR2(3);
   l_is_during_rebook_yn      VARCHAR2(3);
   l_rebook_type              VARCHAR2(100);
   l_orig_khr_start_date      DATE;
   l_rbk_khr_start_date       DATE;
   l_rental_accr_stream       VARCHAR2(1):= 'N';  --Added by RGOOTY for bug 9305846
BEGIN
    -- Added by RGOOTY: For Debugging purposes
    L_DEBUG_ENABLED := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
--    print( l_prog_name, 'begin' );
    -- Added by RGOOTY: Start
    OKL_STREAMS_UTIL.get_acc_options(
                            p_khr_id         => p_khr_id,
                            x_org_id         => G_ORG_ID,
                            x_precision      => G_PRECISION,
                            x_currency_code  => G_CURRENCY_CODE,
                            x_rounding_rule  => G_ROUNDING_RULE,
                            x_apply_rnd_diff => G_DIFF_LOOKUP_CODE,
                            x_return_status  => x_return_status);
     IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    OPEN G_HDR(p_khr_id);
    FETCH G_HDR INTO r_hdr;
    CLOSE G_HDR;

    OPEN G_ROLLOVER_PMNTS(p_khr_id);
    FETCH G_ROLLOVER_PMNTS INTO r_rollover_pmnts;
    CLOSE G_ROLLOVER_PMNTS;

    OPEN OKL_ISG_UTILS_PVT.G_GET_K_INFO_CSR (p_khr_id);
    FETCH OKL_ISG_UTILS_PVT.G_GET_K_INFO_CSR INTO p_get_k_info_csr;
    CLOSE OKL_ISG_UTILS_PVT.G_GET_K_INFO_CSR;

    -- Added by RGOOTY : End
    OPEN  c_hdr;
    FETCH c_hdr INTO l_hdr;
    CLOSE c_hdr;

    IF p_reporting_book_class IS NOT NULL THEN
      l_deal_type    :=  p_reporting_book_class;
      l_purpose_code := 'REPORT';
    ELSE
      l_deal_type    :=  l_hdr.deal_type;
      l_purpose_code := '-99';
    END IF;

    l_asset_guess_iir := l_hdr.base_rate / 100.0;

    OKL_ISG_UTILS_PVT.validate_strm_gen_template(
                                  p_api_version          => p_api_version,
                                  p_init_msg_list        => p_init_msg_list,
                                  x_return_status        => x_return_status,
                                  x_msg_count            => x_msg_count,
                                  x_msg_data             => x_msg_data,
                                  p_khr_id               => p_khr_id);

     IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- Get the Prospective Rebooking Option from System Options
     l_prosp_rebook_flag := 'N';
     FOR t_rec IN is_prospective_rbk_csr( p_khr_id => p_khr_id )
     LOOP
       l_prosp_rebook_flag := NVL( t_rec.rbk_prospectively, 'N' );
     END LOOP;

     IF l_prosp_rebook_flag = 'Y'
     THEN
       -- Inquire whether the Contract being processed is during Rebook or not
       l_is_during_rebook_yn := 'N';
       FOR t_rec IN isg_during_rbk_csr( p_khr_id => p_khr_id )
       LOOP
         l_is_during_rebook_yn := 'Y';
         l_rebook_date         := t_rec.revision_date;
         l_prb_orig_khr_id     := t_rec.original_chr_id;
         l_rebook_type         := t_rec.rebook_type;
         l_orig_khr_start_date := TRUNC(t_rec.orig_chr_start_date);
         l_rbk_khr_start_date  := TRUNC(t_rec.rbk_chr_start_date);
       END LOOP;
     END IF;
     print( l_prog_name, ' l_prosp_rebook_flag   = ' || l_prosp_rebook_flag );
     print( l_prog_name, ' l_is_during_rebook_yn = ' || l_is_during_rebook_yn );
     print( l_prog_name, ' l_rebook_date         = ' || l_rebook_date );
     print( l_prog_name, ' l_prb_orig_khr_id     = ' || l_prb_orig_khr_id );
     print( l_prog_name, ' l_orig_khr_start_date = ' || l_orig_khr_start_date );
     print( l_prog_name, ' l_rbk_khr_start_date  = ' || l_rbk_khr_start_date );
     IF l_rebook_type = 'ONLINE_REBOOK' AND
        l_orig_khr_start_date <> l_rbk_khr_start_date
     THEN
       -- Case: During Online Revision, Contract Start Date has been Changed
       --       Hence, consider this as a Retrospective Case only
       l_prosp_rebook_flag := 'N';
     END IF;
-- Added by RGOOTY: Start. Not accepting this as its giving problem for ISG Streams
IF ( p_generation_type = 'SERVICE_LINES' OR p_generation_type = 'FULL' )
THEN

--        print( l_prog_name, ' validating stream templates - done');
    generate_cash_flows (     p_api_version          => p_api_version,
                              p_init_msg_list        => p_init_msg_list,
                              p_khr_id               => p_khr_id,
                              p_generation_type      => p_generation_type,
                              p_reporting_book_class => p_reporting_book_class,
                              x_payment_count        => l_payment_count,
                              x_return_status        => x_return_status,
                              x_msg_count            => x_msg_count,
                              x_msg_data             => x_msg_data,
			      x_se_id                => l_se_id); --Added by prasjain for bug 5474827
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

END IF;
-- Added by RGOOTY: End

/*      print( l_prog_name, ' generating streams - done');
      print( l_prog_name, '  payment count ' || l_payment_count);
*/

    -- cursor to check for existense of financed fee
    l_blnHasFinFees := OKL_API.G_FALSE;
    l_fee_type := NULL;
    OPEN c_financed_fees;
    FETCH c_financed_fees INTO r_financed_fees;
    IF ( c_financed_fees%FOUND ) Then
        l_blnHasFinFees := OKL_API.G_TRUE;
	l_fee_type := r_financed_fees.fee_type;
	--'FINANCED';
    End If;
    CLOSE c_financed_fees;

    OPEN c_subs;
    FETCH c_subs INTO l_subsidies_yn;
    CLOSE c_subs;

    IF p_generation_type = 'FULL' THEN
      ---------------------------------------------
      -- STEP 2: Generate Pre-Tax Income
      ---------------------------------------------
      get_mapped_stream (p_mapping_type   =>  'PRE-TAX INCOME',
            p_line_style     =>  NULL,
            p_deal_type      =>  l_deal_type,
			p_fee_type       =>  l_fee_type,
			p_khr_id         =>  p_khr_id,
            x_mapped_stream  =>  l_mapped_sty_name,
            x_return_status  =>  lx_return_status,
            p_hdr            =>  r_hdr,
            p_rollover_pmnts =>  r_rollover_pmnts);
    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

      print( l_prog_name, ' mapped sty name' || l_mapped_sty_name || ' has fees ' || l_blnHasFinFees );


    IF (l_mapped_sty_name IS NOT NULL) OR ( l_blnHasFinFees = OKL_API.G_TRUE ) THEN
--        print( l_prog_name, ' loop calc amort o');

        FOR l_fin_asset IN c_fin_assets LOOP

            r_rollover_pmnts := NULL;
            r_link_pmnts := NULL;


            If ( l_fin_asset.fee_type = 'ROLLOVER' ) Then
                OPEN c_rollover_pmnts( p_khr_id, l_fin_asset.id);
                FETCH c_rollover_pmnts INTO r_rollover_pmnts;
                CLOSE c_rollover_pmnts;
                l_primary_sty_id := nvl(r_rollover_pmnts.styId, -1);
            Elsif ( l_fin_asset.lty_code = 'LINK_FEE_ASSET' ) Then
                OPEN c_link_pmnts( p_khr_id, l_fin_asset.id);
                FETCH c_link_pmnts INTO r_link_pmnts;
                CLOSE c_link_pmnts;
                l_primary_sty_id := nvl(r_link_pmnts.styId, -1);
            Else
                OPEN c_rollover_pmnts( p_khr_id, l_fin_asset.id);
                FETCH c_rollover_pmnts INTO r_rollover_pmnts;
                CLOSE c_rollover_pmnts;
                l_primary_sty_id := nvl(r_rollover_pmnts.styId, -1);
                l_rent_sty_id := l_primary_sty_id;
            End If;

               if (l_fin_asset.lty_code = 'FREE_FORM1') Then
                get_mapped_stream (p_mapping_type   =>  'PRE-TAX INCOME',
                        p_line_style     =>  NULL,
            			p_primary_sty_id =>  l_primary_sty_id,
                        p_deal_type      =>  l_deal_type,
            			p_fee_type       =>  NULL,
            			p_khr_id         =>  p_khr_id,
                        x_mapped_stream  =>  l_mapped_sty_name,
                        x_return_status  =>  lx_return_status,
                        p_hdr            =>  r_hdr,
                        p_rollover_pmnts =>  r_rollover_pmnts);
	       Else
                get_mapped_stream (p_mapping_type   =>  'PRE-TAX INCOME',
                        p_line_style     =>  NULL,
            			p_primary_sty_id =>  l_primary_sty_id,
                        p_deal_type      =>  l_deal_type,
            			p_fee_type       =>  l_fee_type,
            			p_khr_id         =>  p_khr_id,
                        x_mapped_stream  =>  l_mapped_sty_name,
                        x_return_status  =>  lx_return_status,
                        p_hdr            =>  r_hdr,
                        p_rollover_pmnts =>  r_rollover_pmnts);
	       End if;

            IF ( l_fin_asset.lty_code = 'FREE_FORM1' OR
                 (l_fin_asset.fee_type = 'FINANCED' AND nvl(r_rollover_pmnts.styId, -1) <> -1) OR
                 (l_fin_asset.fee_type = 'ROLLOVER' AND nvl(r_rollover_pmnts.styId, -1) <> -1) OR
                 (l_fin_asset.lty_code = 'LINK_FEE_ASSET' and nvl(r_link_pmnts.styId, -1) <> -1)) Then

        print( l_prog_name, ' amortize fee type ' ||   nvl(l_fin_asset.fee_type, 'XXX') );
        print( l_prog_name, ' amortize lty code ' ||   nvl(l_fin_asset.lty_code, 'XXX') );
        print( l_prog_name, ' rollover  pmnts ' ||   nvl(r_rollover_pmnts.styId, -1) );
        print( l_prog_name, ' link  pmnts ' ||   nvl(r_link_pmnts.styId, -1) );
        print( l_prog_name, ' l_mapped_sty_name ' ||   l_mapped_sty_name );

                l_capital_cost := 0;
                IF ( nvl(l_fin_asset.fee_type, 'XXX') = 'FINANCED' ) OR
                     ( nvl(l_fin_asset.lty_code, 'XXX') = 'LINK_FEE_ASSET' ) OR
                     ( nvl(l_fin_asset.fee_type, 'XXX') = 'ROLLOVER' ) THEN
                     l_capital_cost := l_fin_asset.amount;
                ELSIF (l_mapped_sty_name IS NOT NULL) THEN
                    l_capital_cost := nvl(l_fin_asset.capital_amount, 0) +
                                      nvl(l_fin_asset.capitalized_interest,0);
                END IF;

                IF ( l_capital_cost > 0 ) THEN
                    IF l_fin_asset.sts_code = 'TERMINATED' THEN
                        l_residual_value := OKL_AM_UTIL_PVT.get_actual_asset_residual(
                                                p_khr_id => p_khr_id,
                                                p_kle_id => l_fin_asset.id);
                    ELSE
                        l_residual_value := l_fin_asset.residual_value;
                    END IF;
                    --print( l_prog_name, ' subsidies_yn ' || l_subsidies_yn );


                    IF ( l_subsidies_yn = 'Y' ) THEN

                        OKL_SUBSIDY_PROCESS_PVT.get_asset_subsidy_amount(
                                p_api_version   => G_API_VERSION,
                                p_init_msg_list => G_FALSE,
                                x_return_status => lx_return_status,
                                x_msg_data      => x_msg_data,
                                x_msg_count     => x_msg_count,
                                p_asset_cle_id  => l_fin_asset.id,
                                x_subsidy_amount=> l_subsidy_amount);

                                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                                    RAISE OKL_API.G_EXCEPTION_ERROR;
                                END IF;
                                l_capital_cost := l_capital_cost + l_subsidy_amount;
                    END IF;

		    print( l_prog_name, ' lty code ' || l_fin_asset.lty_code );
                    print( l_prog_name, ' mapped stream PRE-TAX INCOME ' || l_mapped_sty_name );
                    print( l_prog_name, ' prim ' || to_char(l_primary_sty_id) );
                    print( l_prog_name, ' deal type  ' || l_deal_type );
                    print( l_prog_name, ' fee type  ' || l_fee_type );
                    print( l_prog_name, ' count  ' || l_pre_tax_inc_tbl.COUNT);

                    -- Fetch the Relevant Stream Ids first
                    -- Modification required for Prospective Rebooking
                    --get_sty_details (p_sty_name      => 'PRE-TAX INCOME',
                    get_sty_details (p_sty_name       => l_mapped_sty_name,
                                      x_sty_id        => l_pre_tax_inc_id,
                                      x_sty_name      => l_sty_name,
                                      x_return_status => lx_return_status);

                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    OKL_ISG_UTILS_PVT.get_dep_stream_type(
                        p_khr_id                => p_khr_id,
                        p_deal_type           => l_deal_type,
                        p_primary_sty_id =>  l_primary_sty_id,
                        p_dependent_sty_purpose => 'INTEREST_PAYMENT',
                        x_return_status         => lx_return_status,
                        x_dependent_sty_id      => l_interest_id,
                        x_dependent_sty_name    => l_sty_name,
                        p_get_k_info_rec        => p_get_k_info_csr);

                    print( l_prog_name, ' INTEREST_PAYMENT ' || l_sty_name );

                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    OKL_ISG_UTILS_PVT.get_dep_stream_type(
                        p_khr_id                => p_khr_id,
                        p_deal_type           => l_deal_type,
                        p_primary_sty_id =>  l_primary_sty_id,
                        p_dependent_sty_purpose => 'PRINCIPAL_PAYMENT',
                        x_return_status         => lx_return_status,
                        x_dependent_sty_id      => l_principal_id,
                        x_dependent_sty_name    => l_sty_name,
                        p_get_k_info_rec        => p_get_k_info_csr);


                    print( l_prog_name, ' PRINCIPAL_PAYMENT ' || l_sty_name );

                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    OKL_ISG_UTILS_PVT.get_dep_stream_type(
                        p_khr_id                => p_khr_id,
                        p_deal_type           => l_deal_type,
                        p_primary_sty_id =>  l_primary_sty_id,
                        p_dependent_sty_purpose => 'PRINCIPAL_BALANCE',
                        x_return_status         => lx_return_status,
                        x_dependent_sty_id      => l_prin_bal_id,
                        x_dependent_sty_name    => l_sty_name,
                        p_get_k_info_rec        => p_get_k_info_csr);

                    print( l_prog_name, ' PRINCIPAL_BALANCE ' || l_sty_name );

                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    OKL_ISG_UTILS_PVT.get_dep_stream_type(
                        p_khr_id                => p_khr_id,
                        p_deal_type           => l_deal_type,
                        p_primary_sty_id =>  l_primary_sty_id,
                        p_dependent_sty_purpose => 'TERMINATION_VALUE',
                        x_return_status         => lx_return_status,
                        x_dependent_sty_id      => l_termination_id,
                        x_dependent_sty_name    => l_sty_name,
                        p_get_k_info_rec        => p_get_k_info_csr);

                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;


             print( l_prog_name, ' calling loan amort ' );
                    OKL_PRICING_PVT.get_loan_amortization(p_khr_id           => p_khr_id,
                                p_kle_id           => l_fin_asset.id,
                                p_purpose_code     => l_purpose_code,
                                p_investment       => l_capital_cost,
                                p_residual_value   => l_residual_value,
                                p_start_date       => l_hdr.start_date,
                                p_asset_start_date => l_fin_asset.start_date,
                                p_term_duration    => l_hdr.term_duration,
                                p_currency_code    => l_hdr.currency_code,
                                p_deal_type        => l_deal_type,
                                p_asset_iir_guess  => l_asset_guess_iir,
                                p_bkg_yield_guess  => l_bkg_yield_guess,
                                x_principal_tbl    => l_principal_tbl,
                                x_interest_tbl     => l_interest_tbl,
                                x_prin_bal_tbl     => l_prin_bal_tbl,
                                x_termination_tbl  => l_termination_tbl,
                                x_pre_tax_inc_tbl  => l_pre_tax_inc_tbl,
                                x_interim_interest => l_interim_interest,
                                x_interim_days     => l_interim_days,
                                x_interim_dpp      => l_interim_dpp,
                                x_iir              => l_asset_iir,
                                x_booking_yield    => l_asset_booking_yield,
                                x_return_status    => lx_return_status,
                                p_se_id            => l_se_id
                                -- parameters added for Prospective Rebooking Enhancement
                                ,p_during_rebook_yn   => l_is_during_rebook_yn
                                ,p_rebook_type        => l_rebook_type
                                ,p_prosp_rebook_flag  => l_prosp_rebook_flag
                                ,p_rebook_date        => l_rebook_date
                                ,p_income_strm_sty_id => l_pre_tax_inc_id
                               ); --Added by bkatraga for bug 5370233


                    prof_rate := fnd_profile.value('OKL_BOOK_CONTRACT_WITHOUT_IRR');
                    IF ((lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) OR
                        (lx_return_status = OKL_API.G_RET_STS_ERROR)) AND
                        (nvl(prof_rate, 'N') = 'Y')
                    THEN
                        lx_return_status := OKL_API.G_RET_STS_SUCCESS;
                        OKL_API.init_msg_list( 'T' );
                        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                           p_msg_name     => 'OKL_CANNOT_CALC_IIR');
                        contract_comments := fnd_message.get_string(OKL_API.G_APP_NAME,
                                                 'OKL_CANNOT_CALC_IIR');

                        UPDATE OKC_K_HEADERS_TL
                            SET COMMENTS = CONTRACT_COMMENTS
                        WHERE ID = P_KHR_ID
                        AND LANGUAGE = USERENV('LANG');
                    END IF;

                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    IF l_interim_interest <> 0 THEN
                        i := i + 1;
                        l_interim_tbl(i).cf_days   := l_interim_days;
                        l_interim_tbl(i).cf_amount := l_interim_interest;
                        l_interim_tbl(i).cf_dpp    := l_interim_dpp;
                    END IF;

                    IF ( l_subsidies_yn = 'Y' ) THEN
                        l_capital_cost := l_capital_cost - l_subsidy_amount;
                        l_principal_tbl.DELETE;
                        l_interest_tbl.DELETE;
                        l_prin_bal_tbl.DELETE;
                        l_termination_tbl.DELETE;
                        l_pre_tax_inc_tbl.DELETE;

                        OKL_PRICING_PVT.get_loan_amortization(
                            p_khr_id           => p_khr_id,
                            p_kle_id           => l_fin_asset.id,
                            p_purpose_code     => l_purpose_code,
                            p_investment       => l_capital_cost,
                            p_residual_value   => l_residual_value,
                            p_start_date       => l_hdr.start_date,
                            p_asset_start_date => l_fin_asset.start_date,
                            p_term_duration    => l_hdr.term_duration,
                            p_currency_code    => l_hdr.currency_code,
                            p_deal_type        => l_deal_type,
                            p_asset_iir_guess  => l_asset_guess_iir,
                            p_bkg_yield_guess  => l_bkg_yield_guess,
                            x_principal_tbl    => l_principal_tbl,
                            x_interest_tbl     => l_interest_tbl,
                            x_prin_bal_tbl     => l_prin_bal_tbl,
                            x_termination_tbl  => l_termination_tbl,
                            x_pre_tax_inc_tbl  => l_pre_tax_inc_tbl,
                            x_interim_interest => l_interim_interest,
                            x_interim_days     => l_interim_days,
                            x_interim_dpp      => l_interim_dpp,
                            x_iir              => l_asset_iir,
                            x_booking_yield    => l_asset_booking_yield,
                            x_return_status    => lx_return_status,
                            p_se_id            => l_se_id
                            -- parameters added for Prospective Rebooking Enhancement
                            ,p_during_rebook_yn   => l_is_during_rebook_yn
                            ,p_rebook_type        => l_rebook_type
                            ,p_prosp_rebook_flag  => l_prosp_rebook_flag
                            ,p_rebook_date        => l_rebook_date
                            ,p_income_strm_sty_id => l_pre_tax_inc_id
                           ); --Added by bkatraga for bug 5370233

                        prof_rate := fnd_profile.value('OKL_BOOK_CONTRACT_WITHOUT_IRR');
                        IF ((lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) OR
                            (lx_return_status = OKL_API.G_RET_STS_ERROR)) AND
                            (nvl(prof_rate, 'N') = 'Y') THEN

                                lx_return_status := OKL_API.G_RET_STS_SUCCESS;
                                OKL_API.init_msg_list( 'T' );
                                OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME,
                                            p_msg_name     => 'OKL_CANNOT_CALC_IIR');
                                contract_comments := fnd_message.get_string(OKL_API.G_APP_NAME,
                                            'OKL_CANNOT_CALC_IIR');

                                UPDATE OKC_K_HEADERS_TL
                                SET COMMENTS = CONTRACT_COMMENTS
                                WHERE ID = P_KHR_ID
                                AND LANGUAGE = USERENV('LANG');
                        END IF;
                        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;

                        IF l_interim_interest <> 0 THEN
                            i := i + 1;
                            l_sub_interim_tbl(i).cf_days   := l_interim_days;
                            l_sub_interim_tbl(i).cf_amount := l_interim_interest;
                            l_sub_interim_tbl(i).cf_dpp    := l_interim_dpp;
                        END IF;
                    End If;
                    i := i + 1;
                    --l_clev_tbl(i).dnz_chr_id := p_khr_id;
                    --l_clev_tbl(i).chr_id := p_khr_id;
                    l_clev_tbl(i).id := l_fin_asset.id;
                    l_klev_tbl(i).id := l_fin_asset.id;
                    l_klev_tbl(i).implicit_interest_rate := l_asset_iir * 100.0;
                    l_asset_guess_iir := l_asset_iir;
                    l_bkg_yield_guess := l_asset_booking_yield;
                End If;



             print( l_prog_name, ' lty code ' || l_fin_asset.lty_code );
             print( l_prog_name, ' mapped stream PRE-TAX INCOME ' || l_mapped_sty_name );
             print( l_prog_name, ' prim ' || to_char(l_primary_sty_id) );
             print( l_prog_name, ' deal type  ' || l_deal_type );
             print( l_prog_name, ' fee type  ' || l_fee_type );
             print( l_prog_name, ' count  ' || l_pre_tax_inc_tbl.COUNT);

                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;


            --print( l_prog_name, ' inserting principal ' );
                IF l_principal_tbl.COUNT > 0 AND (l_principal_id IS NOT NULL) AND
                    ( (l_deal_type IN ('LOAN', 'LOAN-REVOLVING')) OR
                    ( l_fin_asset.fee_type = 'FINANCED' OR
		      l_fin_asset.fee_type = 'ROLLOVER' OR
		      l_fin_asset.lty_code = 'LINK_FEE_ASSET') )
                THEN
                    get_stream_header(
                        p_khr_id         =>   p_khr_id,
                        p_kle_id         =>   l_fin_asset.id,
                        p_sty_id         =>   l_principal_id,
                        p_purpose_code   =>   l_purpose_code,
                        x_stmv_rec       =>   l_stmv_rec,
                        x_return_status  =>   lx_return_status);

                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    lx_return_status := Okl_Streams_Util.round_streams_amount_esg(
                                            p_api_version   => g_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_chr_id        => p_khr_id,
                                            p_selv_tbl      => l_principal_tbl,
                                            x_selv_tbl      => lx_selv_tbl,
                                            p_org_id        => G_ORG_ID,
                                            p_precision     => G_PRECISION,
                                            p_currency_code => G_CURRENCY_CODE,
                                            p_rounding_rule => G_ROUNDING_RULE,
                                            p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

                    IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    l_principal_tbl.DELETE;
                    l_principal_tbl := lx_selv_tbl;

                    okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                                    p_init_msg_list   =>   G_FALSE,
                                                    x_return_status   =>   lx_return_status,
                                                    x_msg_count       =>   x_msg_count,
                                                    x_msg_data        =>   x_msg_data,
                                                    p_stmv_rec        =>   l_stmv_rec,
                                                    p_selv_tbl        =>   l_principal_tbl,
                                                    x_stmv_rec        =>   lx_stmv_rec,
                                                    x_selv_tbl        =>   lx_selv_tbl);
                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
              END IF;
--print( l_prog_name, ' inserting interest ' );
            IF l_interest_tbl.COUNT > 0 AND ( l_interest_id IS NOT NULL) AND
                ( (l_deal_type IN ('LOAN', 'LOAN-REVOLVING')) OR
                ( l_fin_asset.fee_type = 'FINANCED' OR l_fin_asset.fee_type = 'ROLLOVER' OR
		      l_fin_asset.lty_code = 'LINK_FEE_ASSET') )
                THEN



                get_stream_header(
                    p_khr_id         =>   p_khr_id,
                    p_kle_id         =>   l_fin_asset.id,
                    p_sty_id         =>   l_interest_id,
                    p_purpose_code   =>   l_purpose_code,
                    x_stmv_rec       =>   l_stmv_rec,
                    x_return_status  =>   lx_return_status);

                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                lx_return_status := Okl_Streams_Util.round_streams_amount_esg(
                                p_api_version   => g_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => p_khr_id,
                                p_selv_tbl      => l_interest_tbl,
                                x_selv_tbl      => lx_selv_tbl,
                                p_org_id        => G_ORG_ID,
                                p_precision     => G_PRECISION,
                                p_currency_code => G_CURRENCY_CODE,
                                p_rounding_rule => G_ROUNDING_RULE,
                                p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

                IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                l_interest_tbl.DELETE;
                l_interest_tbl := lx_selv_tbl;

                okl_streams_pub.create_streams(
                    p_api_version     =>   G_API_VERSION,
                    p_init_msg_list   =>   G_FALSE,
                    x_return_status   =>   lx_return_status,
                    x_msg_count       =>   x_msg_count,
                    x_msg_data        =>   x_msg_data,
                    p_stmv_rec        =>   l_stmv_rec,
                    p_selv_tbl        =>   l_interest_tbl,
                    x_stmv_rec        =>   lx_stmv_rec,
                    x_selv_tbl        =>   lx_selv_tbl);

                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
            END IF;
--             print( l_prog_name, ' inserting prin bal ' );
            IF l_prin_bal_tbl.COUNT > 0 AND (l_prin_bal_id IS NOT NULL) AND
                ( (l_deal_type IN ('LOAN', 'LOAN-REVOLVING')) OR
                ( l_fin_asset.fee_type = 'FINANCED'
                    OR l_fin_asset.fee_type = 'ROLLOVER' OR
		      l_fin_asset.lty_code = 'LINK_FEE_ASSET') )
                THEN
                get_stream_header(
                    p_khr_id         =>   p_khr_id,
                    p_kle_id         =>   l_fin_asset.id,
                    p_sty_id         =>   l_prin_bal_id,
                    p_purpose_code   =>   l_purpose_code,
                    x_stmv_rec       =>   l_stmv_rec,
                    x_return_status  =>   lx_return_status);

                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                lx_return_status := Okl_Streams_Util.round_streams_amount_esg(
                                p_api_version   => g_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => p_khr_id,
                                p_selv_tbl      => l_prin_bal_tbl,
                                x_selv_tbl      => lx_selv_tbl,
                                p_org_id        => G_ORG_ID,
                                p_precision     => G_PRECISION,
                                p_currency_code => G_CURRENCY_CODE,
                                p_rounding_rule => G_ROUNDING_RULE,
                                p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

                IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                l_prin_bal_tbl.DELETE;
                l_prin_bal_tbl := lx_selv_tbl;

                okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                               p_init_msg_list   =>   G_FALSE,
                                               x_return_status   =>   lx_return_status,
                                               x_msg_count       =>   x_msg_count,
                                               x_msg_data        =>   x_msg_data,
                                               p_stmv_rec        =>   l_stmv_rec,
                                               p_selv_tbl        =>   l_prin_bal_tbl,
                                               x_stmv_rec        =>   lx_stmv_rec,
                                               x_selv_tbl        =>   lx_selv_tbl);

                IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;

    --             print( l_prog_name, ' inserting termin  ' );
              IF l_termination_tbl.COUNT > 0 AND (l_termination_id IS NOT NULL) THEN
                    get_stream_header(p_khr_id         =>   p_khr_id,
                                  p_kle_id         =>   l_fin_asset.id,
                                  p_sty_id         =>   l_termination_id,
                                  p_purpose_code   =>   l_purpose_code,
                                  x_stmv_rec       =>   l_stmv_rec,
                                  x_return_status  =>   lx_return_status);

                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    lx_return_status := Okl_Streams_Util.round_streams_amount_esg(
                                    p_api_version   => g_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_chr_id        => p_khr_id,
                                    p_selv_tbl      => l_termination_tbl,
                                    x_selv_tbl      => lx_selv_tbl,
                                    p_org_id        => G_ORG_ID,
                                    p_precision     => G_PRECISION,
                                    p_currency_code => G_CURRENCY_CODE,
                                    p_rounding_rule => G_ROUNDING_RULE,
                                    p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

                    IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    l_termination_tbl.DELETE;
                    l_termination_tbl := lx_selv_tbl;

                    okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                                   p_init_msg_list   =>   G_FALSE,
                                                   x_return_status   =>   lx_return_status,
                                                   x_msg_count       =>   x_msg_count,
                                                   x_msg_data        =>   x_msg_data,
                                                   p_stmv_rec        =>   l_stmv_rec,
                                                   p_selv_tbl        =>   l_termination_tbl,
                                                   x_stmv_rec        =>   lx_stmv_rec,
                                                   x_selv_tbl        =>   lx_selv_tbl);
                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                END IF;
 --            print( l_prog_name, ' inserting pre-tax  ' );
                IF l_pre_tax_inc_tbl.COUNT > 0 AND (l_pre_tax_inc_id is NOT NULL) THEN
                    get_stream_header(p_khr_id         =>   p_khr_id,
                                    p_kle_id         =>   l_fin_asset.id,
                                    p_sty_id         =>   l_pre_tax_inc_id,
                                    p_purpose_code   =>   l_purpose_code,
                                    x_stmv_rec       =>   l_stmv_rec,
                                    x_return_status  =>   lx_return_status);

                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    lx_return_status := Okl_Streams_Util.round_streams_amount_esg(
                                    p_api_version   => g_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_chr_id        => p_khr_id,
                                    p_selv_tbl      => l_pre_tax_inc_tbl,
                                    x_selv_tbl      => lx_selv_tbl,
                                    p_org_id        => G_ORG_ID,
                                    p_precision     => G_PRECISION,
                                    p_currency_code => G_CURRENCY_CODE,
                                    p_rounding_rule => G_ROUNDING_RULE,
                                    p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

                    IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;

                    l_pre_tax_inc_tbl.DELETE;
                    l_pre_tax_inc_tbl := lx_selv_tbl;

                    okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                                   p_init_msg_list   =>   G_FALSE,
                                                   x_return_status   =>   lx_return_status,
                                                   x_msg_count       =>   x_msg_count,
                                                   x_msg_data        =>   x_msg_data,
                                                   p_stmv_rec        =>   l_stmv_rec,
                                                   p_selv_tbl        =>   l_pre_tax_inc_tbl,
                                                   x_stmv_rec        =>   lx_stmv_rec,
                                                   x_selv_tbl        =>   lx_selv_tbl);

                    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                END IF;
                -- Clear out data structures
                l_principal_tbl.delete;
                l_interest_tbl.delete;
                l_prin_bal_tbl.delete;
                l_termination_tbl.delete;
                l_pre_tax_inc_tbl.delete;
                l_stmv_rec              :=  NULL;
                l_interim_interest      :=  NULL;
                l_interim_days          :=  NULL;
                l_asset_iir             :=  NULL;
                l_asset_booking_yield   :=  NULL;
                l_capital_cost          :=  NULL;

            END IF;
        END LOOP;


        IF ( l_clev_tbl.COUNT > 0 OR l_klev_tbl.COUNT > 0 ) THEN

            okl_contract_pub.update_contract_line(
                p_api_version   => p_api_version,
                p_init_msg_list => p_init_msg_list,
                x_return_status => lx_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_clev_tbl      => l_clev_tbl,
                p_klev_tbl      => l_klev_tbl,
                p_edit_mode     => 'N',
                x_clev_tbl      => x_clev_tbl,
                x_klev_tbl      => x_klev_tbl);
            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        End If;
    END IF;
  END IF;

    --print( l_prog_name, ' compute irr ' || p_compute_irr );

    IF (p_compute_irr = G_TRUE) AND (l_purpose_code <> 'REPORT') THEN

      ---------------------------------------------
      -- STEP 3: Compute IRR
      ---------------------------------------------

      IF l_payment_count = 0 THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_NO_SLL_DEFINED');

        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

      END IF;

      -- Calculate IRR after all inflow stream elements have been generated but before accrual
      -- and collateral streams have been generated because IRR cursors will not be able to
      -- distinguish between Payment and Accrual stream elements.

      --print( l_prog_name, ' subsidies_yn ' || l_subsidies_yn );
      If ( nvl(l_subsidies_yn, 'N') = 'Y' ) Then

          OKL_PRICING_PVT.compute_irr (p_khr_id          =>  p_khr_id,
                       p_start_date      =>  l_hdr.start_date,
                       p_term_duration   =>  l_hdr.term_duration,
                       p_interim_tbl     =>  l_sub_interim_tbl,
		               p_subsidies_yn    =>  'Y',
                       p_initial_irr     =>  0,
                       x_irr             =>  l_sub_pre_tax_irr,
                       x_return_status   =>  lx_return_status);

      prof_rate := fnd_profile.value('OKL_BOOK_CONTRACT_WITHOUT_IRR');

      IF ((lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) OR
          (lx_return_status = OKL_API.G_RET_STS_ERROR)) AND
	 (nvl(prof_rate, 'N') = 'Y') THEN

         lx_return_status := OKL_API.G_RET_STS_SUCCESS;
          OKL_API.init_msg_list( 'T' );
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_CANNOT_CALC_IIR');

--	 select nvl(comments, '') into contract_comments
--	 from   okc_K_headers_tl
--	 where id = p_khr_id
--	   and language = userenv('LANG');

      --   contract_comments := concat(contract_comments, ' : ');
         contract_comments := fnd_message.get_string(OKL_API.G_APP_NAME,'OKL_CANNOT_CALC_IIR');

	 update okc_K_headers_tl
	 set comments = contract_comments
	 where id = p_khr_id
	   and language = userenv('LANG');

      End If;

          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          x_contract_rates.sub_pre_tax_irr := l_sub_pre_tax_irr;

          OKL_PRICING_PVT.compute_iir (p_khr_id          =>  p_khr_id,
                       p_start_date      =>  l_hdr.start_date,
                       p_term_duration   =>  l_hdr.term_duration,
                       p_interim_tbl     =>  l_sub_interim_tbl,
		               p_subsidies_yn    =>  'Y',
                       -- Bug 77641094 - Pass 0 for p_initial_iir
                       p_initial_iir     =>  0, --l_sub_pre_tax_irr,
                       x_iir             =>  l_sub_pre_tax_irr,
                       x_return_status   =>  lx_return_status);

      prof_rate := fnd_profile.value('OKL_BOOK_CONTRACT_WITHOUT_IRR');

      IF ((lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) OR
          (lx_return_status = OKL_API.G_RET_STS_ERROR)) AND
	 (nvl(prof_rate, 'N') = 'Y') THEN

         lx_return_status := OKL_API.G_RET_STS_SUCCESS;
          OKL_API.init_msg_list( 'T' );
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_CANNOT_CALC_IIR');

--	 select nvl(comments, '') into contract_comments
--	 from   okc_K_headers_tl
--	 where id = p_khr_id
--	   and language = userenv('LANG');

      --   contract_comments := concat(contract_comments, ' : ');
         contract_comments := fnd_message.get_string(OKL_API.G_APP_NAME,'OKL_CANNOT_CALC_IIR');

	 update okc_K_headers_tl
	 set comments = contract_comments
	 where id = p_khr_id
	   and language = userenv('LANG');

      End If;

          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          x_contract_rates.sub_impl_interest_rate := l_sub_pre_tax_irr;

      End If;


        OKL_PRICING_PVT.compute_irr (p_khr_id          =>  p_khr_id,
                       p_start_date      =>  l_hdr.start_date,
                       p_term_duration   =>  l_hdr.term_duration,
                       p_interim_tbl     =>  l_interim_tbl,
        		       p_subsidies_yn    =>  'N',
        		       p_initial_irr     =>  l_initial_irr,  -- Added by RGOOTY
                       x_irr             =>  l_pre_tax_irr,
                       x_return_status   =>  lx_return_status);

      prof_rate := fnd_profile.value('OKL_BOOK_CONTRACT_WITHOUT_IRR');

      IF ((lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) OR
          (lx_return_status = OKL_API.G_RET_STS_ERROR)) AND
	 (nvl(prof_rate, 'N') = 'Y') THEN

         lx_return_status := OKL_API.G_RET_STS_SUCCESS;
          OKL_API.init_msg_list( 'T' );
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_CANNOT_CALC_IIR');

--	 select nvl(comments, '') into contract_comments
--	 from   okc_K_headers_tl
--	 where id = p_khr_id
--	   and language = userenv('LANG');

      --   contract_comments := concat(contract_comments, ' : ');
         contract_comments := fnd_message.get_string(OKL_API.G_APP_NAME,'OKL_CANNOT_CALC_IIR');

	 update okc_K_headers_tl
	 set comments = contract_comments
	 where id = p_khr_id
	   and language = userenv('LANG');

      End If;

      print( l_prog_name, ' compute irr ', lx_return_status );
      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      print( l_prog_name, ' pre tax irr ' || to_char( nvl(l_pre_tax_irr, -999) ) , lx_return_status );
      x_contract_rates.pre_tax_irr := l_pre_tax_irr;

      OKL_PRICING_PVT.compute_iir (p_khr_id          =>  p_khr_id,
                       p_start_date      =>  l_hdr.start_date,
                       p_term_duration   =>  l_hdr.term_duration,
                       p_interim_tbl     =>  l_interim_tbl,
        	       p_subsidies_yn    =>  'N',
                       -- Bug 7641094 - Pass 0 for p_initial_iir
                       p_initial_iir     =>  0, --x_contract_rates.pre_tax_irr,
                       x_iir             =>  l_pre_tax_irr,
                       x_return_status   =>  lx_return_status);

      prof_rate := fnd_profile.value('OKL_BOOK_CONTRACT_WITHOUT_IRR');

      IF ((lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) OR
          (lx_return_status = OKL_API.G_RET_STS_ERROR)) AND
	 (nvl(prof_rate, 'N') = 'Y') THEN

         lx_return_status := OKL_API.G_RET_STS_SUCCESS;
          OKL_API.init_msg_list( 'T' );
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_CANNOT_CALC_IIR');

--	 select nvl(comments, '') into contract_comments
--	 from   okc_K_headers_tl
--	 where id = p_khr_id
--	   and language = userenv('LANG');

      --   contract_comments := concat(contract_comments, ' : ');
         contract_comments := fnd_message.get_string(OKL_API.G_APP_NAME,'OKL_CANNOT_CALC_IIR');

	 update okc_K_headers_tl
	 set comments = contract_comments
	 where id = p_khr_id
	   and language = userenv('LANG');

      End If;

--      print( l_prog_name, ' compute iir ', lx_return_status );
      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      print( l_prog_name, ' pre tax iir ' || to_char( nvl(l_pre_tax_irr, -999) ) , lx_return_status );
      x_contract_rates.implicit_interest_rate := l_pre_tax_irr;

    END IF;

    ---------------------------------------------
    -- STEP 4: Generate Income Accrual
    ---------------------------------------------
--    print( l_prog_name, ' accruals '  );

 -- Added by RGOOTY: Start
 IF (p_generation_type = 'SERVICE_LINES') OR (p_generation_type = 'FULL') THEN
    -- Added by RGOOTY for bug 9305846
    IF(l_deal_type =  'LEASEOP') THEN
      --Call the new api to generate Rental Accrual Streams
      gen_rental_accr_streams(p_api_version   => g_api_version,
                              p_init_msg_list => p_init_msg_list,
                              p_khr_id        => p_khr_id,
                              p_purpose_code  => l_purpose_code,
                              x_return_status => lx_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data);
      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    --end bkatraga

    FOR l_inflow IN c_inflows LOOP

      l_sty_purpose := l_inflow.stream_type_purpose;

      get_sty_details (p_sty_id        => l_inflow.sty_id,
                       x_sty_id        => l_sty_id,
                       x_sty_name      => l_sty_name,
                       x_return_status => lx_return_status);

      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_primary_sty_id := l_sty_id;
      -- Changed by RGOOTY: Start
      -- Condition added by mansrini on 13-Jun-2005 for Bug 4434343
      -- If the line is a serviced asset line, the service line id needs to be determined. Otherwise, the line_id is passed as it is
      IF ( l_inflow.lty_code = 'LINK_SERV_ASSET' )
      THEN
          OPEN top_svc_csr( p_khr_id, l_inflow.cle_id );
          FETCH top_svc_csr INTO top_svc_rec;
          l_tmp_cle_id := top_svc_rec.top_svc_id;
          CLOSE top_svc_csr;
      ELSE
          l_tmp_cle_id := l_inflow.cle_id;
      END IF;
      OPEN c_pt_yn (p_cle_id => l_tmp_cle_id);

      FETCH c_pt_yn INTO l_pt_yn;
      CLOSE c_pt_yn;
      -- Changed by RGOOTY: End

      -- Ignoring billable_yn AND stream_type_class attributes of the SLH stream type.
      -- Per MKMITTAL, payments defined from LLA UI are implicitly billable. And
      -- every billable payment must generate accrual (MKMITTAL, SRAWLING)

      If( TO_NUMBER(nvl(l_inflow.periods, 0)) > 1 ) Then
          l_recurr_yn := OKL_API.G_TRUE;
      ElsIf( TO_NUMBER(nvl(l_inflow.periods, 0)) = 1 ) Then
          l_recurr_yn := OKL_API.G_FALSE;
      ENd If;
/*
      print( l_prog_name, ' l_recurr_yn ' || l_recurr_yn  );
      print( l_prog_name, ' lty_code ' || l_inflow.lty_code  );
      print( l_prog_name, ' l_primary_sty_id ' || to_char(l_primary_sty_id)  );
      print( l_prog_name, ' l_deal_type ' || to_char(l_deal_type)  );
*/

        get_mapped_stream ( p_sty_purpose    =>  l_sty_purpose,
                            p_line_style     =>  l_inflow.lty_code,
			    p_primary_sty_id =>  l_primary_sty_id,
                            p_mapping_type   =>  'ACCRUAL',
                            p_deal_type      =>  l_deal_type,
		            p_fee_type       =>  l_inflow.fee_type,
			    p_recurr_yn      =>  l_recurr_yn,
                            p_pt_yn          =>  l_pt_yn,
			    p_khr_id         =>  p_khr_id,
                            x_mapped_stream  =>  l_mapped_sty_name,
                            x_return_status  =>  lx_return_status,
                            p_hdr            =>  r_hdr,
                            p_rollover_pmnts =>  r_rollover_pmnts);

      print( l_prog_name, ' l_mapped_sty_name ' || to_char(l_mapped_sty_name)  );

      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      inf_start_date := l_inflow.start_date;
      l_rental_accr_stream := 'N'; --Added by RGOOTY for bug 9305846
      -- Fix to write the Rental Accruals seperately
      IF p_generation_type = 'FULL' AND
         l_deal_type =  'LEASEOP' AND
         l_inflow.lty_code = 'FREE_FORM1' AND
         l_inflow.stream_type_purpose = 'RENT' AND
         l_mapped_sty_name IS NOT NULL
      THEN
        l_rental_accr_stream := 'Y'; --Added by RGOOTY for bug 9305846
        -- You are about to generate the RENTAL ACCRUAL Streams
        -- Accumulate into the l_inflow_tbl for later generation of Rental Accruals
        -- If the table doesn't exists until, then create one
        IF l_inflows_tbl.COUNT = 0
        THEN
          inf_index := 1;
          l_inflows_tbl( inf_index ) := l_inflow;
          inf_index := inf_index + 1;
        ELSE
          -- Inflows table is already present,
          --  if the payment levels belong to the same cle_id, sty_id then accumulate
          IF l_inflows_tbl(1).cle_id = l_inflow.cle_id AND
             l_inflows_tbl(1).sty_id = l_inflow.sty_id
          THEN
             -- Inflows belong to the same Asset line and same stream
             -- so accumulate
             l_inflows_tbl( inf_index ) := l_inflow;
             inf_index := inf_index + 1;
          ELSE
             -- New Payment Levels for another asset / another Payment Stream
             -- Hence, destroy the payment levels
             l_inflows_tbl.DELETE;
             -- Create new table and then store into that
             inf_index := 1;
             l_inflows_tbl( inf_index ) := l_inflow;
             inf_index := inf_index + 1;
          END IF;
        END IF;
        -- Now check whether to pick the contract date
        --  instead of the start_date stored @ payment level.
        -- Fix Explanation:
        --   We will use the contract start_date only for a Payment level
        --    which is after one or more stubs with zero amount.
        l_use_first_pmnt_date := 'N';
        IF l_inflows_tbl.COUNT >= 2 AND
           l_inflow.periods IS NOT NULL OR
           l_inflow.amount IS NOT NULL
        THEN
          -- If the current Payment level is not the first one
          --  and also the current payment level is a regular payment
          --  and now, loop through the all the payment levels before
          --  this, if all of them are stubs with zero amount, then
          -- change the date, else keep the start date at the payment itself.
          l_use_first_pmnt_date := 'Y';
          FOR t_index in l_inflows_tbl.FIRST .. (l_inflows_tbl.LAST - 1 )
          LOOP
            IF l_inflows_tbl(t_index).STUB_DAYS IS NOT NULL AND
               l_inflows_tbl(t_index).STUB_AMOUNT = 0 AND
               l_use_first_pmnt_date = 'Y'
            THEN
              -- No problem, continue checking
              NULL;
            ELSE
              l_use_first_pmnt_date := 'N';
            END IF;
          END LOOP;
        END IF; -- IF l_inflows_tbl.COUNT >= 2
        IF l_use_first_pmnt_date = 'Y'
        THEN
          -- Pick the first Payment Level Start Date
          inf_start_date := l_inflows_tbl(1).start_date;
        ELSE
           -- Use the payment date stored in this level itself !
          inf_start_date := l_inflow.start_date;
        END IF;  -- IF l_use_first_pmnt_date = 'Y'
      END IF;

      IF l_mapped_sty_name IS NOT NULL THEN

        IF ((l_inflow.lty_code = 'SOLD_SERVICE' OR l_inflow.lty_code = 'LINK_SERV_ASSET') AND
	             p_generation_type = 'SERVICE_LINES') OR (p_generation_type = 'FULL') THEN

          IF ( l_inflow.fee_type = 'INCOME' AND l_recurr_yn = OKL_API.G_FALSE ) THEN
                print( l_prog_name, ' creatig income amort '  );


            get_amortized_accruals (
              p_khr_id         => p_khr_id,
              p_currency_code  => l_hdr.currency_code,
              p_start_date     => l_inflow.start_date,
              p_end_date       => l_hdr.end_date,
              p_deal_type      => l_hdr.deal_type,
              p_amount         => l_inflow.amount,
              x_selv_tbl       => l_selv_tbl,
              x_return_status  => lx_return_status);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          ELSE
           IF (l_rental_accr_stream = 'N') THEN  --Added by RGOOTY for bug 9305846
            get_accrual_elements (
              p_start_date          =>   l_inflow.start_date,
              p_periods             =>   l_inflow.periods,
              p_frequency           =>   l_inflow.frequency,
              p_structure           =>   l_inflow.structure,
              p_advance_or_arrears  =>   l_inflow.advance_arrears,
              p_amount              =>   l_inflow.amount,
              p_stub_days           =>   l_inflow.stub_days,
              p_stub_amount         =>   l_inflow.stub_amount,
              p_currency_code       =>   l_hdr.currency_code,
              x_selv_tbl            =>   l_selv_tbl,
              x_return_status       =>   lx_return_status);

            IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
           END IF; --Added by RGOOTY for bug 9305846
	END IF;

          get_sty_details (p_sty_name      => l_mapped_sty_name,
                           x_sty_id        => l_sty_id,
                           x_sty_name      => l_sty_name,
                           x_return_status => lx_return_status);

          IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          --Modified by kthiruva on 27-May-2005
          --Bug 4371472 - Start of Changes
          --Added the condition to check of the l_selv_tbl.count >0
          IF (l_selv_tbl.COUNT > 0 ) THEN
            get_stream_header(p_khr_id         =>   p_khr_id,
                              p_kle_id         =>   l_inflow.cle_id,
                              p_sty_id         =>   l_sty_id,
                              p_purpose_code   =>   l_purpose_code,
                              x_stmv_rec       =>   l_stmv_rec,
                              x_return_status  =>   lx_return_status);

             IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

          --
          -- call process API to create parent Stream Header and its child Stream Elements
          --

              lx_return_status := Okl_Streams_Util.round_streams_amount_esg(
                                  p_api_version   => g_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_chr_id        => p_khr_id,
                                  p_selv_tbl      => l_selv_tbl,
                                  x_selv_tbl      => lx_selv_tbl,
                                  p_org_id        => G_ORG_ID,
                                  p_precision     => G_PRECISION,
                                  p_currency_code => G_CURRENCY_CODE,
                                  p_rounding_rule => G_ROUNDING_RULE,
                                  p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

              IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              l_selv_tbl.DELETE;
              l_selv_tbl := lx_selv_tbl;
              --Accumulate Stream Header
              OKL_STREAMS_UTIL.accumulate_strm_headers(
                p_stmv_rec       => l_stmv_rec,
                x_full_stmv_tbl  => l_stmv_tbl,
                x_return_status  => lx_return_status );
              IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
              --Accumulate Stream Elements
              OKL_STREAMS_UTIL.accumulate_strm_elements(
                p_stm_index_no  =>  l_stmv_tbl.LAST,
                p_selv_tbl       => l_selv_tbl,
                x_full_selv_tbl  => l_full_selv_tbl,
                x_return_status  => lx_return_status );
              IF (lx_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (lx_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

           END IF;
           --Bug 4371472 - End of Changes
        END IF;

      END IF;

      -- Clear out reusable data structures

      l_mapped_sty_name := NULL;
      l_sty_name        :=  NULL;
      l_sty_id          :=  NULL;

      l_stmv_rec := NULL;
      l_selv_tbl.delete;

      lx_stmv_rec := NULL;
      lx_selv_tbl.delete;

      l_pt_yn := NULL;

    END LOOP;
    --Create all the accumulated Streams at one shot ..
    IF l_stmv_tbl.COUNT > 0 AND
       l_full_selv_tbl.COUNT > 0
    THEN
Okl_Streams_Pub.create_streams_perf(
                               p_api_version,
                               p_init_msg_list,
                               lx_return_status,
                               x_msg_count,
                               x_msg_data,
                               l_stmv_tbl,
                               l_full_selv_tbl,
                               lx_stmv_tbl,
                               lx_full_selv_tbl);
      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
END IF;
-- Added by RGOOTY: End

    -- streams like RESIDUAL VALUE, etc.
    gen_non_cash_flows (    p_api_version          => p_api_version,
                            p_init_msg_list        => p_init_msg_list,
                            p_khr_id               => p_khr_id,
			    p_pre_tax_irr          => (l_pre_tax_irr*100.00),
                            p_generation_type      => p_generation_type,
                            p_subsidies_yn         => nvl(l_subsidies_yn, 'N'),
                            p_reporting_book_class => p_reporting_book_class,
                            x_return_status        => x_return_status,
                            x_msg_count            => x_msg_count,
                            x_msg_data             => x_msg_data);

     IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    print( l_prog_name, ' non gen cash flows ', x_return_status );
    print( l_prog_name, ' gen type ' || p_generation_type );

    IF p_generation_type = 'FULL' THEN

      ---------------------------------------------
      -- STEP 5: Generate Fee Expense Accrual
      ---------------------------------------------

      okl_expense_streams_pvt.generate_expense_streams(p_api_version    => G_API_VERSION,
                                                       p_init_msg_list  => G_FALSE,
                                                       p_khr_id         => p_khr_id,
                                                       p_purpose_code   => l_purpose_code,
                                                       p_deal_type      => l_deal_type,
                                                       x_return_status  => lx_return_status,
                                                       x_msg_count      => x_msg_count,
                                                       x_msg_data       => x_msg_data);

      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;



    print( l_prog_name, ' updating loan payment ' );


    IF l_deal_type IN ('LOAN', 'LOAN-REVOLVING') THEN

          OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
                    					 p_deal_type             => l_deal_type,
                    					 p_primary_sty_id        => l_rent_sty_id,
                                         p_dependent_sty_purpose => 'LOAN_PAYMENT',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => l_sty_name);

          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

   If ( l_sty_id IS NOT NULL ) Then

      UPDATE okl_streams
      SET sty_id = l_sty_id
      WHERE khr_id = p_khr_id
        AND say_code = 'WORK'
        AND NVL(purpose_code, '-99') = l_purpose_code
        AND sty_id = l_rent_sty_id;

    End if;
  END IF;


    If ( nvl(l_blnHasFinFees, OKL_API.G_FALSE) = OKL_APi.G_TRUE ) Then
--    print( l_prog_name, ' updating financed fees ' );

     FOR r_financed_fees in c_financed_fees
     LOOP
--print( l_prog_name, ' getting financed fees ' || to_char( r_financed_fees.id ));

       l_rent_sty_id := NULL; --bug# 4096605.
       OPEN c_rent_sty_id(r_financed_fees.id);
       FETCH  c_rent_sty_id INTO l_rent_sty_id;
       CLOSE  c_rent_sty_id;


       If ( l_rent_sty_id is NOT NULL ) Then

          OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                                         p_khr_id                => p_khr_id,
					 p_deal_type             => l_deal_type,
					 p_primary_sty_id        => l_rent_sty_id,
                                         p_dependent_sty_purpose => 'LOAN_PAYMENT',
                                         x_return_status         => x_return_status,
                                         x_dependent_sty_id      => l_sty_id,
                                         x_dependent_sty_name    => l_sty_name);

          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

   If ( l_sty_id IS NOT NULL ) Then

--    print( l_prog_name, ' updating financed fees ' || to_char( r_financed_fees.id ));

      UPDATE okl_streams
      SET sty_id = l_sty_id
      WHERE khr_id = p_khr_id
        AND kle_id = r_financed_fees.id
        AND say_code = 'WORK'
        AND NVL(purpose_code, '-99') = l_purpose_code
        AND sty_id =  l_rent_sty_id;

   End If;

      END IF ;

     END LOOP;

    End If;


      END IF;

--    print( l_prog_name, ' updating ' );

    UPDATE okl_strm_elements
    SET comments=NULL
    WHERE stm_id IN
    (SELECT id from okl_streams WHERE khr_id = p_khr_id and say_code = 'WORK');
--    print( l_prog_name, ' done ' );

 /*
 * delete the duplicates from the okl_streams header table.
 */
-- Modified by RGOOTY: Start
IF (p_generation_type <> 'RESIDUAL VALUE' AND p_generation_type <> 'CAPITAL REDUCTION')
THEN

    consolidate_line_streams(p_khr_id         => p_khr_id,
                             p_purpose_code   => l_purpose_code,
                             x_return_status  => lx_return_status);
--    print( l_prog_name, ' consolidated ', lx_return_status );

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
END IF;

IF (p_generation_type <> 'SERVICE_LINES' AND
    p_generation_type <> 'RESIDUAL VALUE' AND
    p_generation_type <> 'CAPITAL REDUCTION')
THEN

    consolidate_header_streams(p_khr_id         => p_khr_id,
                             p_purpose_code   => l_purpose_code,
                             x_return_status  => lx_return_status);

--   print( l_prog_name, ' consolidated ', lx_return_status );

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--bakuchib changes
END IF;

IF (p_generation_type <> 'RESIDUAL VALUE' AND p_generation_type <> 'CAPITAL REDUCTION')
THEN
        consolidate_acc_streams(p_khr_id         => p_khr_id,
                                 p_purpose_code   => l_purpose_code,
                                 x_return_status  => lx_return_status);
--        print( l_prog_name, ' consolidated ', lx_return_status );

        IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

END IF;

--Call API to generate passthrough expense accrual streams
--Call this API only for ISG, because there is already a call
--for ESG in OKL_LA_STREAM_PVT
--Bug 8624532  by NIKSHAH
 IF p_generation_type = 'FULL' THEN
   OKL_LA_STREAM_PVT.GENERATE_PASSTHRU_EXP_STREAMS
   (
     p_api_version      => p_api_version
    ,p_init_msg_list    => p_init_msg_list
    ,P_CHR_ID           => p_khr_id
    ,P_PURPOSE_CODE     => l_purpose_code
    ,x_return_status    => lx_return_status
    ,x_msg_count        => x_msg_count
    ,x_msg_data         => x_msg_data
   );
   IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
 END IF;

    -- Just Before completing the Stream Generation Process, adjust the
    --  Accrual Streams based on the Straight Line Logic for Prospective Rebooking
    -- IF Prospective Rebooking Options is switched On
    --   And Stream Generation is during Rebook process,
    --   And is by ISG process
    --   And the Rebook Date <> Contract Start Date
    print(l_prog_name, '--------------------------------------------------------' );
    print(l_prog_name, '--------------- Prospective Rebooking Changes ----------' );
    print(l_prog_name, '--------------------------------------------------------' );
    print(l_prog_name, 'l_prosp_rebook_flag   : ' || l_prosp_rebook_flag );
    print(l_prog_name, 'l_is_during_rebook_yn : ' || l_is_during_rebook_yn);
    print(l_prog_name, 'l_rebook_date         : ' || l_rebook_date );
    print(l_prog_name, 'l_hdr.start_date      : ' || l_hdr.start_date );
    print(l_prog_name, 'p_generation_type     : ' || p_generation_type );
    IF l_prosp_rebook_flag = 'Y'
       AND l_is_during_rebook_yn = 'Y'
       AND l_rebook_date <> TRUNC(l_hdr.start_date)
       AND p_generation_type IN ('SERVICE_LINES' , 'FULL')
    THEN
      prosp_adj_acc_strms(
              p_api_version         => p_api_version
             ,p_init_msg_list       => p_init_msg_list
             ,p_rebook_type         => l_rebook_type
             ,p_rebook_date         => l_rebook_date
             ,p_khr_id              => p_khr_id
             ,p_deal_type           => l_deal_type -- l_hdr.deal_type
             ,p_currency_code       => l_hdr.currency_code
             ,p_start_date          => l_hdr.start_date
             ,p_end_date            => l_hdr.end_date
             ,p_context             => p_generation_type
             ,p_purpose_code        => l_purpose_code
             ,x_return_status       => lx_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data);
      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                         p_msg_name     => 'OKL_STREAM_GENERATION_SUCCESS');

    x_return_status := G_RET_STS_SUCCESS;
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

  END generate_streams;

  PROCEDURE generate_streams( p_api_version                IN         NUMBER,
                              p_init_msg_list              IN         VARCHAR2,
                              p_khr_id                     IN         NUMBER,
                              p_compute_irr                IN         VARCHAR2,
                              p_generation_type            IN         VARCHAR2,
                              p_reporting_book_class       IN         VARCHAR2,
                              x_pre_tax_irr                OUT NOCOPY NUMBER,
                              x_return_status              OUT NOCOPY VARCHAR2,
                              x_msg_count                  OUT NOCOPY NUMBER,
                              x_msg_data                   OUT NOCOPY VARCHAR2) IS

   l_contract_rates rate_rec_type;

  Begin


            generate_streams( p_api_version          => p_api_version,
                              p_init_msg_list        => p_init_msg_list,
                              p_khr_id               => p_khr_id,
                              p_compute_rates        => p_compute_irr,
                              p_generation_type      => p_generation_type,
                              p_reporting_book_class => p_reporting_book_class,
                              x_contract_rates       => l_contract_rates,
                              x_return_status        => x_return_status,
                              x_msg_count            => x_msg_count,
                     			      x_msg_data             => x_msg_data);

            x_pre_tax_irr := l_contract_rates.pre_tax_irr;


  End generate_streams;

 PROCEDURE  GEN_VAR_INT_SCHEDULE(  p_api_version         IN      NUMBER,
                                   p_init_msg_list       IN      VARCHAR2,
                                   p_khr_id              IN      NUMBER,
				   p_purpose_code        IN      VARCHAR2,
                                   x_return_status       OUT NOCOPY VARCHAR2,
                                   x_msg_count           OUT NOCOPY NUMBER,
                                   x_msg_data            OUT NOCOPY VARCHAR2) IS

      CURSOR l_varint_sll_csr( khrid NUMBER ) IS
      SELECT TO_NUMBER(NULL) cle_id,
             TO_NUMBER(rul1.object1_id1) sty_id,
             FND_DATE.canonical_to_date(rul2.rule_information2) start_date,
             TO_NUMBER(rul2.rule_information3) periods,
             rul2.object1_id1 frequency,
             rul2.rule_information5 structure,
             DECODE(rul2.rule_information10, 'Y', 'ARREARS', 'ADVANCE') advance_arrears,
             FND_NUMBER.canonical_to_number(rul2.rule_information6) amount,
             TO_NUMBER(rul2.rule_information7) stub_days,
             TO_NUMBER(rul2.rule_information8) stub_amount,
             NULL lty_code,
             TO_NUMBER(NULL) capital_amount,
             TO_NUMBER(NULL) residual_value
      FROM   okc_rule_groups_b rgp,
             okc_rules_b rul1,
             okc_rules_b rul2,
	     okl_strm_type_tl sty
      WHERE  rul2.dnz_chr_id = khrid
        AND  rul2.rule_information_category = 'LASLL'
        AND  rul2.rgp_id = rgp.id
        AND  rul1.rgp_id = rgp.id
        AND  rgp.cle_id IS NULL
        AND  rul2.object2_id1 = rul1.id
	AND  rul1.object1_id1 = sty.id
	AND  sty.language = USERENV('LANG')
	AND  sty.name = 'VARIABLE INTEREST SCHEDULE';

      l_varint_sll_rec l_varint_sll_csr%ROWTYPE;

        l_advance_or_arrears VARCHAR2(10) := 'ARREARS';

   Cursor l_strms_csr ( chrId NUMBER, styId NUMBER ) IS
   Select str.id  strm_id
   From okl_streams str
   Where str.sty_id = styId
       and str.khr_id = chrId
       and str.say_code = 'WORK';

    l_strms_rec l_strms_csr%ROWTYPE;

    CURSOR c_hdr IS
      SELECT chr.template_yn,
             chr.currency_code,
             chr.start_date,
             khr.deal_type,
             khr.term_duration,
             NVL(khr.generate_accrual_yn, 'Y')
      FROM   okc_k_headers_b chr,
             okl_k_headers khr
      WHERE  khr.id = p_khr_id
        AND  chr.id = khr.id;

    l_hdr                    c_hdr%ROWTYPE;
    l_deal_type              VARCHAR2(30);
    l_purpose_code           VARCHAR2(30);

    l_sty_id                 NUMBER;
    l_sty_name               VARCHAR2(150);
    l_mapped_sty_name        VARCHAR2(150);

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_pt_tbl                 okl_streams_pub.selv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    l_stmv_tbl               okl_streams_pub.stmv_tbl_type;
    lx_stmv_tbl               okl_streams_pub.stmv_tbl_type;
    x_stmv_tbl               okl_streams_pub.stmv_tbl_type;
    l_pt_rec                 okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

    i                        BINARY_INTEGER := 0;

    l_api_name         CONSTANT VARCHAR2(61) := 'GEN_VAR_INT_SCHEDULE';

   BEGIN
    print( l_api_name, 'begin' );

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => p_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    print( l_api_name, 'checking for var rate' );
    If (Is_Var_Rate_Contract( p_khr_id ) = 'N' ) THEN
         print( l_api_name, 'checking for var rate - nah' );
	 return;
    END IF;
    print( l_api_name, 'checking for var rate - yah' );

    get_sty_details (p_sty_name      => 'VARIABLE INTEREST SCHEDULE',
                     x_sty_id        => l_sty_id,
                     x_sty_name      => l_sty_name,
		     x_return_status => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    print( l_api_name, 'got stream type' );
    i := 0;
    FOR  l_strms_rec in l_strms_csr ( p_khr_id, l_sty_id)
    LOOP

        i := i + 1;
        l_stmv_tbl(i).id := l_strms_rec.STRM_ID;
        l_stmv_tbl(i).say_code := 'HIST';
        l_stmv_tbl(i).active_yn := 'N';
        l_stmv_tbl(i).date_history := sysdate;

    END LOOP;

    If ( l_stmv_tbl.COUNT > 0 ) Then

        Okl_Streams_pub.update_streams(
                         p_api_version => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data,
                         p_stmv_tbl => l_stmv_tbl,
                         x_stmv_tbl => x_stmv_tbl);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

     End If;

/*
     OPEN  c_hdr;
     FETCH c_hdr INTO l_hdr;
     CLOSE c_hdr;

     FOR l_varint_sll_rec in l_varint_sll_csr( p_khr_id )
     LOOP

         IF ( lx_selv_tbl.COUNT > 0 ) Then
             lx_selv_tbl.delete;
	 END IF;

         get_stream_elements(
	                   p_start_date          =>   l_varint_sll_rec.start_date,
                           p_periods             =>   l_varint_sll_rec.periods,
			   p_frequency           =>   l_varint_sll_rec.frequency,
			   p_structure           =>   l_varint_sll_rec.structure,
			   p_advance_or_arrears  =>   l_varint_sll_rec.advance_arrears,
			   p_amount              =>   l_varint_sll_rec.amount,
			   p_stub_days           =>   l_varint_sll_rec.stub_days,
			   p_stub_amount         =>   l_varint_sll_rec.stub_amount,
			   p_currency_code       =>   l_hdr.currency_code,
			   p_khr_id              =>   p_khr_id,
			   p_kle_id              =>   NULL,
			   p_purpose_code        =>   p_purpose_code,
			   x_selv_tbl            =>   lx_selv_tbl,
			   x_pt_tbl              =>   l_pt_tbl,
			   x_return_status       =>   x_return_status,
			   x_msg_count           =>   x_msg_count,
			   x_msg_data            =>   x_msg_data);

         IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         FOR i in 1..lx_selv_tbl.COUNT
	 LOOP
	     l_selv_tbl( l_selv_tbl.COUNT + 1) := lx_selv_tbl(i);
	 END LOOP;

       END LOOP;

            get_stream_header(p_khr_id      =>   p_khr_id,
	                      p_kle_id         =>   NULL,
			      p_sty_id         =>   l_sty_id,
			      p_purpose_code   =>   p_purpose_code,
			      x_stmv_rec       =>   l_stmv_rec,
			      x_return_status  =>   x_return_status);

            IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;


            x_return_status := Okl_Streams_Util.round_streams_amount(
                                p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => p_khr_id,
                                p_selv_tbl      => l_selv_tbl,
                                x_selv_tbl      => lx_selv_tbl);

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_selv_tbl.DELETE;
            l_selv_tbl := lx_selv_tbl;

            okl_streams_pub.create_streams(p_api_version     =>   p_api_version,
                                       p_init_msg_list   =>   p_init_msg_list,
                                       x_return_status   =>   x_return_status,
                                       x_msg_count       =>   x_msg_count,
                                       x_msg_data        =>   x_msg_data,
                                       p_stmv_rec        =>   l_stmv_rec,
                                       p_selv_tbl        =>   l_selv_tbl,
                                       x_stmv_rec        =>   lx_stmv_rec,
                                       x_selv_tbl        =>   lx_selv_tbl);

            IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

*/
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    print( l_api_name, 'end' );
    Exception

	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

   END GEN_VAR_INT_SCHEDULE;

   PROCEDURE  gen_pv_streams(p_api_version         IN      NUMBER,
                               p_init_msg_list       IN      VARCHAR2,
                               p_pool_status         IN      VARCHAR2,
                               p_agreement_id        IN      NUMBER,
                               p_contract_id         IN      NUMBER,
                               p_kle_id              IN      NUMBER,
                               p_sty_id              IN      NUMBER,
                               p_mode                IN      VARCHAR2,
                               x_stmv_rec            OUT NOCOPY okl_streams_pub.stmv_rec_type,
                               x_selv_tbl            OUT NOCOPY okl_streams_pub.selv_tbl_type,
                               x_return_status       OUT NOCOPY VARCHAR2,
                               x_msg_count           OUT NOCOPY NUMBER,
                               x_msg_data            OUT NOCOPY VARCHAR2) IS


    l_api_name         CONSTANT VARCHAR2(61) := 'gen_pv_streams';

    Cursor sec_strms_csr IS
    select pol.khr_id agreement_id,
           pcn.khr_id contract_id,
	   pcn.kle_id asset_id,
           pcn.sty_id stream_type_id,
           pcn.streams_from_date,
	   pcn.streams_to_date,
	   ele.STREAM_ELEMENT_DATE,
	   ele.se_line_number,
	   ele.id stream_ele_id,
	   ele.amount stream_ele_amount,
	   sty.name stream_name,
	   stm.id stm_id
    from   okl_pools pol,
           okl_pool_contents pcn,
           okl_strm_type_v sty,
	   okl_streams stm,
	   okl_strm_elements ele
     where pcn.sty_id = sty.id
       and pcn.pol_id = pol.id
       and stm.kle_id = pcn.kle_id
       and stm.khr_id = pcn.khr_id
       and stm.sty_id = pcn.sty_id
       and stm.say_code = 'CURR'
       and stm.active_yn = 'Y'
       and ele.stm_id = stm.id
       and pol.khr_id = p_agreement_id
       and stm.khr_id = p_contract_id
       and stm.kle_id = p_kle_id
       and stm.sty_id = p_sty_id
       and pol.status_code = p_pool_status
       and ele.stream_element_date >= nvl(pcn.streams_from_date, ele.stream_element_date-1)
       and ele.stream_element_date <= nvl(pcn.STREAMS_TO_DATE, OKL_POOL_PVT.G_FINAL_DATE)
       AND pcn.status_code IN (G_IA_STS_ACTIVE,G_IA_STS_NEW) -- Added by VARANGAN -Pool Contents Impact - 26/11/07
       order by pcn.khr_id, pcn.kle_id, pcn.sty_id;

      sec_strms_rec sec_strms_csr%ROWTYPE;

    Cursor ylds_csr( agmntID NUMBER, khrId NUMBER) IS
    select pol.khr_id agreement_id,
	   pcn.khr_id contract_id,
	   pkhr.start_date contract_start_date,
	   pkhr.contract_number agreement_number,
	   nvl(pkhr.after_tax_yield, -1) agmnt_yield,
	   nvl(khr.PRE_TAX_IRR, -1) contract_yield
    from  okl_pools pol,
	  okl_pool_contents pcn,
	  okl_K_headers_full_v pkhr,
	  okl_k_headers khr
    where pcn.pol_id = pol.id
      and pcn.khr_id = khr.id
      and pol.khr_id = pkhr.id
      and pol.khr_id = agmntID
      and pcn.khr_id = khrId
      AND pcn.status_CODE IN (G_IA_STS_ACTIVE,G_IA_STS_NEW) ; -- Added by VARANGAN -Pool Contents Impact - 26/11/07
/* sosharma ,14-12-2007
Bug 6691554
Changed cursors for pending pool
Start Changes*/
    Cursor sec_strms_pend_csr IS
    select pol.khr_id agreement_id,
           pcn.khr_id contract_id,
	   pcn.kle_id asset_id,
           pcn.sty_id stream_type_id,
           pcn.streams_from_date,
	   pcn.streams_to_date,
	   ele.STREAM_ELEMENT_DATE,
	   ele.se_line_number,
	   ele.id stream_ele_id,
	   ele.amount stream_ele_amount,
	   sty.name stream_name,
	   stm.id stm_id
    from   okl_pools pol,
           okl_pool_contents pcn,
           okl_strm_type_v sty,
	   okl_streams stm,
	   okl_strm_elements ele
     where pcn.sty_id = sty.id
       and pcn.pol_id = pol.id
       and stm.kle_id = pcn.kle_id
       and stm.khr_id = pcn.khr_id
       and stm.sty_id = pcn.sty_id
       and stm.say_code = 'CURR'
       and stm.active_yn = 'Y'
       and ele.stm_id = stm.id
       and pol.khr_id = p_agreement_id
       and stm.khr_id = p_contract_id
       and stm.kle_id = p_kle_id
       and stm.sty_id = p_sty_id
       and pol.status_code = p_pool_status
       and ele.stream_element_date >= nvl(pcn.streams_from_date, ele.stream_element_date-1)
       and ele.stream_element_date <= nvl(pcn.STREAMS_TO_DATE, OKL_POOL_PVT.G_FINAL_DATE)
       AND pcn.status_code = G_PC_STS_PENDING
       order by pcn.khr_id, pcn.kle_id, pcn.sty_id;



    Cursor ylds_pend_csr( agmntID NUMBER, khrId NUMBER) IS
    select pol.khr_id agreement_id,
	   pcn.khr_id contract_id,
	   pkhr.start_date contract_start_date,
	   pkhr.contract_number agreement_number,
	   nvl(pkhr.after_tax_yield, -1) agmnt_yield,
	   nvl(khr.PRE_TAX_IRR, -1) contract_yield
    from  okl_pools pol,
	  okl_pool_contents pcn,
	  okl_K_headers_full_v pkhr,
	  okl_k_headers khr
    where pcn.pol_id = pol.id
      and pcn.khr_id = khr.id
      and pol.khr_id = pkhr.id
      and pol.khr_id = agmntID
      and pcn.khr_id = khrId
      AND pcn.status_CODE = G_PC_STS_PENDING ;
/* sosharma end changes*/

    ylds_rec ylds_csr%ROWTYPE;

    l_day_convention_month VARCHAR2(30);
    l_day_convention_year VARCHAR2(30);

    l_agt_yld NUMBER;
    l_khr_yld NUMBER;

    l_sty_id NUMBER;
    l_sty_name               VARCHAR2(150);
    l_mapped_sty_name        VARCHAR2(150);

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_stmv_tbl               okl_streams_pub.stmv_tbl_type;
    x_stmv_tbl               okl_streams_pub.stmv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

   cursor l_hdrrl_csr IS
   select crl.RULE_INFORMATION1 method
   from   OKC_RULE_GROUPS_B crg,
          OKC_RULES_B crl
   where  crl.rgp_id = crg.id
          and crg.RGD_CODE = 'LASEIR'
          and crl.RULE_INFORMATION_CATEGORY = 'LASEIR'
          and crg.dnz_chr_id = p_agreement_id;

   l_hdrrl_rec l_hdrrl_csr%ROWTYPE;

   Cursor c_stm_name IS
   Select sty.stream_type_subclass name,
              sty.stream_type_purpose stream_type_purpose
   from okl_strm_type_tl tl,
        okl_strm_type_v sty
   where tl.language = 'US'
     and sty.id = tl.id
     and tl.id = p_sty_id;

   r_stm_name c_stm_name%ROWTYPE;

   i NUMBER;
   n NUMBER;

   l_rentsty_id NUMBER;
   l_rvsty_id   NUMBER;
   l_rentsty_name VARCHAR2(256);
   l_rvsty_name   VARCHAR2(256);

   l_days NUMBER;

   l_start_date DATE;
   l_end_date   DATE;

   BEGIN

    print( l_api_name, 'begin' );

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => p_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OPEN l_hdrrl_csr;
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    CLOSE l_hdrrl_csr;
    print( l_api_name, ' method ' || l_hdrrl_rec.method );

IF p_mode IS NULL THEN

    OPEN sec_strms_csr;
    FETCH sec_strms_csr INTO sec_strms_rec;
    CLOSE sec_strms_csr;

    OPEN ylds_csr( p_agreement_id, sec_strms_rec.contract_id );
    FETCH ylds_csr INTO ylds_rec;
    CLOSE ylds_csr;

    If (nvl(ylds_rec.contract_yield, -360)/360 = -1 ) Then

        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_AGMNT_NOYLD',
                            p_token1       => 'AGMNT',
                            p_token1_value => ylds_rec.agreement_number);

        RAISE OKL_API.G_EXCEPTION_ERROR;

    End If;

    l_khr_yld := ylds_rec.contract_yield / 100.00;

    OPEN c_stm_name;
    FETCH c_stm_name INTO r_stm_name;
    CLOSE c_stm_name;

    IF r_stm_name.name = 'LOAN_PAYMENT' THEN
    get_mapped_stream (p_sty_purpose       =>  r_stm_name.name,
                       p_mapping_type   =>  'PV_DISBURSEMENT',
                       p_line_style     =>  NULL,
                       p_deal_type      =>  'LOAN',
                       p_khr_id         =>  p_agreement_id,
                       p_stream_type_purpose => r_stm_name.stream_type_purpose,
                       x_mapped_stream  =>  l_mapped_sty_name,
                       x_return_status  =>  x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
      If l_mapped_sty_name is NOT NULL THen

    get_sty_details (p_sty_name      => l_mapped_sty_name,
                     x_sty_id        => l_sty_id,
                     x_sty_name      => l_sty_name,
                     x_return_status => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_stmv_rec := NULL;
    get_stream_header(p_purpose_code   => NULL,
                      p_khr_id         => p_contract_id,
                      p_kle_id         => p_kle_id,
                      p_sty_id         => l_sty_id,
                      x_stmv_rec       => l_stmv_rec,
                      x_return_status  => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_selv_tbl(1).stream_element_date := ylds_rec.contract_start_date;
    l_selv_tbl(1).se_line_number := 1;
    l_start_date := ylds_rec.contract_start_date;

    l_selv_tbl(1).amount := 0.0;
    print( l_api_name, ' khr_yld ' || to_char( l_khr_yld ) );

    -- Fetch the day convention ..
    OKL_PRICING_UTILS_PVT.get_day_convention(
      p_id              => p_contract_id,
      p_source          => 'ISG',
      x_days_in_month   => l_day_convention_month,
      x_days_in_year    => l_day_convention_year,
      x_return_status   => x_return_status);
    print( 'gen_pv_streams', 'Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR sec_strms_rec IN sec_strms_csr
    LOOP

        l_end_date := sec_strms_rec.stream_element_date;

       l_days := OKL_PRICING_UTILS_PVT.get_day_count (p_start_date => l_start_date,
                                 p_days_in_month => l_day_convention_month,
                                 p_days_in_year => l_day_convention_year,
                                 p_end_date   => l_end_date,
                                 p_arrears    => 'N',
                                 x_return_status => x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_selv_tbl(1).amount := l_selv_tbl(1).amount +
	              sec_strms_rec.stream_ele_amount / POWER( 1 + (l_khr_yld/360), l_days );

    print( l_api_name, ' amount ' || to_char( l_selv_tbl(1).amount ) );
    END LOOP;


    x_stmv_rec := l_stmv_rec;
    x_selv_tbl := l_selv_tbl;

  End If;

    ELSE
      get_mapped_stream (p_sty_purpose       =>  r_stm_name.name,
                       p_mapping_type   =>  'PV_DISBURSEMENT',
                       p_line_style     =>  NULL,
                       p_deal_type      =>  'LEASE',
			 p_khr_id         =>  p_agreement_id, --p_khr_id         =>  p_contract_id,
                       x_mapped_stream  =>  l_mapped_sty_name,
                       x_return_status  =>  x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    If l_mapped_sty_name is NOT NULL THen

    get_sty_details (p_sty_name      => l_mapped_sty_name,
                     x_sty_id        => l_sty_id,
                     x_sty_name      => l_sty_name,
                     x_return_status => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_stmv_rec := NULL;
    get_stream_header(p_purpose_code   => NULL,
                      p_khr_id         => p_contract_id,
                      p_kle_id         => p_kle_id,
                      p_sty_id         => l_sty_id,
                      x_stmv_rec       => l_stmv_rec,
                      x_return_status  => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_selv_tbl(1).stream_element_date := ylds_rec.contract_start_date;
    l_selv_tbl(1).se_line_number := 1;
    l_start_date := ylds_rec.contract_start_date;

    l_selv_tbl(1).amount := 0.0;
    print( l_api_name, ' khr_yld ' || to_char( l_khr_yld ) );

    -- Fetch the day convention ..
    OKL_PRICING_UTILS_PVT.get_day_convention(
      p_id              => p_contract_id,
      p_source          => 'ISG',
      x_days_in_month   => l_day_convention_month,
      x_days_in_year    => l_day_convention_year,
      x_return_status   => x_return_status);
    print( 'gen_pv_streams', 'Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR sec_strms_rec IN sec_strms_csr
    LOOP

        l_end_date := sec_strms_rec.stream_element_date;

       l_days := OKL_PRICING_UTILS_PVT.get_day_count (p_start_date => l_start_date,
                                 p_days_in_month => l_day_convention_month,
                                 p_days_in_year => l_day_convention_year,
                                 p_end_date   => l_end_date,
                                 p_arrears    => 'N',
                                 x_return_status => x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_selv_tbl(1).amount := l_selv_tbl(1).amount +
	              sec_strms_rec.stream_ele_amount / POWER( 1 + (l_khr_yld/360), l_days );

    print( l_api_name, ' amount ' || to_char( l_selv_tbl(1).amount ) );
    END LOOP;


    x_stmv_rec := l_stmv_rec;
    x_selv_tbl := l_selv_tbl;

  End If;

    END IF;


  ELSE

   OPEN sec_strms_pend_csr;
    FETCH sec_strms_pend_csr INTO sec_strms_rec;
    CLOSE sec_strms_pend_csr;

    OPEN ylds_pend_csr( p_agreement_id, sec_strms_rec.contract_id );
    FETCH ylds_pend_csr INTO ylds_rec;
    CLOSE ylds_pend_csr;

    If (nvl(ylds_rec.contract_yield, -360)/360 = -1 ) Then

        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_AGMNT_NOYLD',
                            p_token1       => 'AGMNT',
                            p_token1_value => ylds_rec.agreement_number);

        RAISE OKL_API.G_EXCEPTION_ERROR;

    End If;

    l_khr_yld := ylds_rec.contract_yield / 100.00;

    OPEN c_stm_name;
    FETCH c_stm_name INTO r_stm_name;
    CLOSE c_stm_name;
     IF r_stm_name.name = 'LOAN_PAYMENT' THEN
       get_mapped_stream (p_sty_purpose       =>  r_stm_name.name,
                       p_mapping_type   =>  'PV_DISBURSEMENT',
                       p_line_style     =>  NULL,
                       p_deal_type      =>  'LOAN',
                       p_khr_id         =>  p_agreement_id,
                       p_stream_type_purpose => r_stm_name.stream_type_purpose,
                       x_mapped_stream  =>  l_mapped_sty_name,
                       x_return_status  =>  x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
      If l_mapped_sty_name is NOT NULL THen

    get_sty_details (p_sty_name      => l_mapped_sty_name,
                     x_sty_id        => l_sty_id,
                     x_sty_name      => l_sty_name,
                     x_return_status => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_stmv_rec := NULL;
    get_stream_header(p_purpose_code   => NULL,
                      p_khr_id         => p_contract_id,
                      p_kle_id         => p_kle_id,
                      p_sty_id         => l_sty_id,
                      x_stmv_rec       => l_stmv_rec,
                      x_return_status  => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_selv_tbl(1).stream_element_date := ylds_rec.contract_start_date;
    l_selv_tbl(1).se_line_number := 1;
    l_start_date := ylds_rec.contract_start_date;

    l_selv_tbl(1).amount := 0.0;
    print( l_api_name, ' khr_yld ' || to_char( l_khr_yld ) );

    -- Fetch the day convention ..
    OKL_PRICING_UTILS_PVT.get_day_convention(
      p_id              => p_contract_id,
      p_source          => 'ISG',
      x_days_in_month   => l_day_convention_month,
      x_days_in_year    => l_day_convention_year,
      x_return_status   => x_return_status);
    print( 'gen_pv_streams', 'Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR sec_strms_rec IN sec_strms_pend_csr
    LOOP

        l_end_date := sec_strms_rec.stream_element_date;

       l_days := OKL_PRICING_UTILS_PVT.get_day_count (p_start_date => l_start_date,
                                 p_days_in_month => l_day_convention_month,
                                 p_days_in_year => l_day_convention_year,
                                 p_end_date   => l_end_date,
                                 p_arrears    => 'N',
                                 x_return_status => x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_selv_tbl(1).amount := l_selv_tbl(1).amount +
	              sec_strms_rec.stream_ele_amount / POWER( 1 + (l_khr_yld/360), l_days );

    print( l_api_name, ' amount ' || to_char( l_selv_tbl(1).amount ) );
    END LOOP;
  END IF;
    ELSE
      get_mapped_stream (p_sty_purpose       =>  r_stm_name.name,
                       p_mapping_type   =>  'PV_DISBURSEMENT',
                       p_line_style     =>  NULL,
                       p_deal_type      =>  'LEASE',
			 p_khr_id         =>  p_agreement_id, --p_khr_id         =>  p_contract_id,
                       x_mapped_stream  =>  l_mapped_sty_name,
                       x_return_status  =>  x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    If l_mapped_sty_name is NOT NULL THen

    get_sty_details (p_sty_name      => l_mapped_sty_name,
                     x_sty_id        => l_sty_id,
                     x_sty_name      => l_sty_name,
                     x_return_status => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_stmv_rec := NULL;
    get_stream_header(p_purpose_code   => NULL,
                      p_khr_id         => p_contract_id,
                      p_kle_id         => p_kle_id,
                      p_sty_id         => l_sty_id,
                      x_stmv_rec       => l_stmv_rec,
                      x_return_status  => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_selv_tbl(1).stream_element_date := ylds_rec.contract_start_date;
    l_selv_tbl(1).se_line_number := 1;
    l_start_date := ylds_rec.contract_start_date;

    l_selv_tbl(1).amount := 0.0;
    print( l_api_name, ' khr_yld ' || to_char( l_khr_yld ) );

    -- Fetch the day convention ..
    OKL_PRICING_UTILS_PVT.get_day_convention(
      p_id              => p_contract_id,
      p_source          => 'ISG',
      x_days_in_month   => l_day_convention_month,
      x_days_in_year    => l_day_convention_year,
      x_return_status   => x_return_status);
    print( 'gen_pv_streams', 'Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR sec_strms_rec IN sec_strms_pend_csr
    LOOP

        l_end_date := sec_strms_rec.stream_element_date;

       l_days := OKL_PRICING_UTILS_PVT.get_day_count (p_start_date => l_start_date,
                                 p_days_in_month => l_day_convention_month,
                                 p_days_in_year => l_day_convention_year,
                                 p_end_date   => l_end_date,
                                 p_arrears    => 'N',
                                 x_return_status => x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_selv_tbl(1).amount := l_selv_tbl(1).amount +
	              sec_strms_rec.stream_ele_amount / POWER( 1 + (l_khr_yld/360), l_days );

    print( l_api_name, ' amount ' || to_char( l_selv_tbl(1).amount ) );
    END LOOP;
  END IF;
 END IF;
    x_stmv_rec := l_stmv_rec;
    x_selv_tbl := l_selv_tbl;

  END IF;

    print( l_api_name, 'end' );
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    Exception

	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

   END gen_pv_streams;

   PROCEDURE  gen_disb_streams(p_api_version         IN      NUMBER,
                               p_init_msg_list       IN      VARCHAR2,
                               p_pool_status         IN      VARCHAR2,
                               p_agreement_id        IN      NUMBER,
                               p_contract_id         IN      NUMBER,
                               p_kle_id              IN      NUMBER,
                               p_sty_id              IN      NUMBER,
--sosharma added, bug 6691554
                               p_mode                IN      VARCHAR2,
                               x_stmv_rec            OUT NOCOPY okl_streams_pub.stmv_rec_type,
                               x_selv_tbl            OUT NOCOPY okl_streams_pub.selv_tbl_type,
                               x_return_status       OUT NOCOPY VARCHAR2,
                               x_msg_count           OUT NOCOPY NUMBER,
                               x_msg_data            OUT NOCOPY VARCHAR2) IS


    l_api_name         CONSTANT VARCHAR2(61) := 'gen_disb_streams';

    Cursor sec_strms_csr IS
    select pol.khr_id agreement_id,
           pcn.khr_id contract_id,
	   pcn.kle_id asset_id,
           pcn.sty_id stream_type_id,
           pcn.streams_from_date,
	   pcn.streams_to_date,
	   ele.STREAM_ELEMENT_DATE,
	   ele.se_line_number,
	   ele.id stream_ele_id,
	   ele.amount stream_ele_amount,
	   sty.name stream_name,
	   stm.id stm_id
    from   okl_pools pol,
           okl_pool_contents pcn,
           okl_strm_type_v sty,
	   okl_streams stm,
	   okl_strm_elements ele
     where pcn.sty_id = sty.id
       and pcn.pol_id = pol.id
       and stm.kle_id = pcn.kle_id
       and stm.khr_id = pcn.khr_id
       and stm.sty_id = pcn.sty_id
       and pcn.status_code IN (G_IA_STS_ACTIVE,G_IA_STS_NEW)
       and stm.say_code = 'CURR'
       and stm.active_yn = 'Y'
       and ele.stm_id = stm.id
       and pol.khr_id = p_agreement_id
       and stm.khr_id = p_contract_id
       and stm.kle_id = p_kle_id
       and stm.sty_id = p_sty_id
       and pol.status_code = p_pool_status
       and ele.stream_element_date >= nvl(pcn.streams_from_date, ele.stream_element_date-1)
       and ele.stream_element_date <= nvl(pcn.STREAMS_TO_DATE, OKL_POOL_PVT.G_FINAL_DATE)
       order by ele.stream_element_date,pcn.khr_id, pcn.kle_id, pcn.sty_id;

      sec_strms_rec sec_strms_csr%ROWTYPE;

    Cursor ylds_csr( agmntID NUMBER, khrId NUMBER) IS
    select pol.khr_id agreement_id,
	   pcn.khr_id contract_id,
	   nvl(pkhr.after_tax_yield, -1) agmnt_yield,
	   pkhr.contract_number agreement_number,
	   nvl(khr.PRE_TAX_IRR, -1) contract_yield
    from  okl_pools pol,
	  okl_pool_contents pcn,
	  okl_K_headers_full_v pkhr,
	  okl_k_headers khr
    where pcn.pol_id = pol.id
      and pcn.khr_id = khr.id
      and pol.khr_id = pkhr.id
      and pol.khr_id = agmntID
      and pcn.khr_id = khrId
      AND pcn.status_code IN (G_IA_STS_ACTIVE,G_IA_STS_NEW) ; -- Added by VARANGAN -Pool Contents Impact - 26/11/07

    ylds_rec ylds_csr%ROWTYPE;

    /* sosharma, 14-12-2007
    Added Cursors for handling pending status for pool contents
    Start changes
    */

    Cursor sec_strms_pend_csr IS
    select pol.khr_id agreement_id,
           pcn.khr_id contract_id,
	   pcn.kle_id asset_id,
           pcn.sty_id stream_type_id,
           pcn.streams_from_date,
	   pcn.streams_to_date,
	   ele.STREAM_ELEMENT_DATE,
	   ele.se_line_number,
	   ele.id stream_ele_id,
	   ele.amount stream_ele_amount,
	   sty.name stream_name,
	   stm.id stm_id
    from   okl_pools pol,
           okl_pool_contents pcn,
           okl_strm_type_v sty,
	   okl_streams stm,
	   okl_strm_elements ele
     where pcn.sty_id = sty.id
       and pcn.pol_id = pol.id
       and stm.kle_id = pcn.kle_id
       and stm.khr_id = pcn.khr_id
       and stm.sty_id = pcn.sty_id
       and pcn.status_code IN (G_PC_STS_PENDING)
       and stm.say_code = 'CURR'
       and stm.active_yn = 'Y'
       and ele.stm_id = stm.id
       and pol.khr_id = p_agreement_id
       and stm.khr_id = p_contract_id
       and stm.kle_id = p_kle_id
       and stm.sty_id = p_sty_id
       and pol.status_code = p_pool_status
       and ele.stream_element_date >= nvl(pcn.streams_from_date, ele.stream_element_date-1)
       and ele.stream_element_date <= nvl(pcn.STREAMS_TO_DATE, OKL_POOL_PVT.G_FINAL_DATE)
       order by ele.stream_element_date,pcn.khr_id, pcn.kle_id, pcn.sty_id;


       Cursor ylds_pend_csr( agmntID NUMBER, khrId NUMBER) IS
       select pol.khr_id agreement_id,
       pcn.khr_id contract_id,
       nvl(pkhr.after_tax_yield, -1) agmnt_yield,
       pkhr.contract_number agreement_number,
       nvl(khr.PRE_TAX_IRR, -1) contract_yield
       from  okl_pools pol,
      okl_pool_contents pcn,
      okl_K_headers_full_v pkhr,
      okl_k_headers khr
       where pcn.pol_id = pol.id
        and pcn.khr_id = khr.id
        and pol.khr_id = pkhr.id
        and pol.khr_id = agmntID
        and pcn.khr_id = khrId
        and pcn.status_code IN (G_PC_STS_PENDING) ;

    /* Sosharma End changes*/

    l_agt_yld NUMBER;
    l_khr_yld NUMBER;

    l_sty_id NUMBER;
    l_sty_name               VARCHAR2(150);
    l_mapped_sty_name        VARCHAR2(150);

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_stmv_tbl               okl_streams_pub.stmv_tbl_type;
    x_stmv_tbl               okl_streams_pub.stmv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

   cursor l_hdrrl_csr IS
   select crl.RULE_INFORMATION1 method
   from   OKC_RULE_GROUPS_B crg,
          OKC_RULES_B crl
   where  crl.rgp_id = crg.id
          and crg.RGD_CODE = 'LASEIR'
          and crl.RULE_INFORMATION_CATEGORY = 'LASEIR'
          and crg.dnz_chr_id = p_agreement_id;

   l_hdrrl_rec l_hdrrl_csr%ROWTYPE;

   Cursor c_stm_name IS
   Select sty.stream_type_subclass name,
             sty.stream_type_purpose stream_type_purpose
   from okl_strm_type_tl tl,
        okl_strm_type_v sty
   where tl.language = 'US'
     and sty.id = tl.id
     and tl.id = p_sty_id;

   r_stm_name c_stm_name%ROWTYPE;

   i NUMBER;
   n NUMBER;

   l_rentsty_id NUMBER;
   l_rvsty_id   NUMBER;
   l_rentsty_name VARCHAR2(256);
   l_rvsty_name   VARCHAR2(256);

   BEGIN

    print( l_api_name, 'begin' );

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => p_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OPEN l_hdrrl_csr;
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    CLOSE l_hdrrl_csr;
    print( l_api_name, ' method ' || l_hdrrl_rec.method );

/* sosharma ,14-12-2007
Bug 6691554
Start Changes*/

--Based on the p_mode passed to the procedure two flows have been defined
IF p_mode IS NULL THEN
--(1) When Streams are getting generated on activation of Investor Agreement/Changes in contract
    OPEN sec_strms_csr;
    FETCH sec_strms_csr INTO sec_strms_rec;
    CLOSE sec_strms_csr;


    If  ( l_hdrrl_rec.method = 'YIELD' )  Then

        OPEN ylds_csr( p_agreement_id, sec_strms_rec.contract_id );
        FETCH ylds_csr INTO ylds_rec;
        CLOSE ylds_csr;

        If (( ylds_rec.agmnt_yield = -1 ) OR (ylds_rec.contract_yield = -1 )) Then

            OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKL_AGMNT_NOYLD',
                                p_token1       => 'AGMNT',
                                p_token1_value => ylds_rec.agreement_number);

            RAISE OKL_API.G_EXCEPTION_ERROR;

        End If;

	l_agt_yld := ylds_rec.agmnt_yield/100.0;
	l_khr_yld := ylds_rec.contract_yield/100.0;

    ElsIf  ( nvl(l_hdrrl_rec.method, 'XYZ') = 'XYZ' )  Then

        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_INVALID_METHOD',
                            p_token1       => 'AGMNT',
                            p_token1_value => ylds_rec.agreement_number);

        RAISE OKL_API.G_EXCEPTION_ERROR;

    End If;

    OPEN c_stm_name;
    FETCH c_stm_name INTO r_stm_name;
    CLOSE c_stm_name;
    IF r_stm_name.name = 'LOAN_PAYMENT' THEN
      get_mapped_stream (p_sty_purpose       =>  r_stm_name.name,
                       p_mapping_type   =>  'DISBURSEMENT',
                       p_line_style     =>  NULL,
                       p_deal_type      =>  'LOAN',
                       p_khr_id         =>  p_agreement_id,
                       p_stream_type_purpose => r_stm_name.stream_type_purpose,
                       x_mapped_stream  =>  l_mapped_sty_name,
                       x_return_status  =>  x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
      If l_mapped_sty_name IS NOT NULL Then

    get_sty_details (p_sty_name      => l_mapped_sty_name,
                     x_sty_id        => l_sty_id,
                     x_sty_name      => l_sty_name,
                     x_return_status => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_stmv_rec := NULL;
    get_stream_header(p_purpose_code   => NULL,
                      p_khr_id         => p_contract_id,
                      p_kle_id         => p_kle_id,
                      p_sty_id         => l_sty_id,
                      x_stmv_rec       => l_stmv_rec,
                      x_return_status  => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR sec_strms_rec IN sec_strms_csr
    LOOP

	i := l_selv_tbl.COUNT + 1;
	l_selv_tbl(i).se_line_number := i;
	l_selv_tbl(i).sel_id := sec_strms_rec.stream_ele_id;

	l_selv_tbl(i).stream_element_date := sec_strms_rec.stream_element_date;
	If ( l_hdrrl_rec.method = 'CASH_FLOW' ) Then
	    l_selv_tbl(i).amount := sec_strms_rec.stream_ele_amount;
	Elsif ( l_hdrrl_rec.method = 'YIELD' ) Then
	    l_selv_tbl(i).amount := sec_strms_rec.stream_ele_amount *
	                 POWER(( 1+l_agt_yld )/(1+l_khr_yld), i);
	ENd If;
	l_stmv_rec.stm_id := sec_strms_rec.stm_id;

    END LOOP;

    x_stmv_rec := l_stmv_rec;
    x_selv_tbl := l_selv_tbl;

  End If;

    ELSE
        get_mapped_stream (p_sty_purpose       =>  r_stm_name.name,
                       p_mapping_type   =>  'DISBURSEMENT',
                       p_line_style     =>  NULL,
                       p_deal_type      =>  'LEASE',
		       p_khr_id         =>  p_agreement_id,
                       x_mapped_stream  =>  l_mapped_sty_name,
                       x_return_status  =>  x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
      If l_mapped_sty_name IS NOT NULL Then

    get_sty_details (p_sty_name      => l_mapped_sty_name,
                     x_sty_id        => l_sty_id,
                     x_sty_name      => l_sty_name,
                     x_return_status => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_stmv_rec := NULL;
    get_stream_header(p_purpose_code   => NULL,
                      p_khr_id         => p_contract_id,
                      p_kle_id         => p_kle_id,
                      p_sty_id         => l_sty_id,
                      x_stmv_rec       => l_stmv_rec,
                      x_return_status  => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR sec_strms_rec IN sec_strms_csr
    LOOP

	i := l_selv_tbl.COUNT + 1;
	l_selv_tbl(i).se_line_number := i;
	l_selv_tbl(i).sel_id := sec_strms_rec.stream_ele_id;

	l_selv_tbl(i).stream_element_date := sec_strms_rec.stream_element_date;
	If ( l_hdrrl_rec.method = 'CASH_FLOW' ) Then
	    l_selv_tbl(i).amount := sec_strms_rec.stream_ele_amount;
	Elsif ( l_hdrrl_rec.method = 'YIELD' ) Then
	    l_selv_tbl(i).amount := sec_strms_rec.stream_ele_amount *
	                 POWER(( 1+l_agt_yld )/(1+l_khr_yld), i);
	ENd If;
	l_stmv_rec.stm_id := sec_strms_rec.stm_id;

    END LOOP;

    x_stmv_rec := l_stmv_rec;
    x_selv_tbl := l_selv_tbl;

  End If;

   END IF;

ELSE

    OPEN sec_strms_pend_csr;
    FETCH sec_strms_pend_csr INTO sec_strms_rec;
    CLOSE sec_strms_pend_csr;


    If  ( l_hdrrl_rec.method = 'YIELD' )  Then

        OPEN ylds_pend_csr( p_agreement_id, sec_strms_rec.contract_id );
        FETCH ylds_pend_csr INTO ylds_rec;
        CLOSE ylds_pend_csr;

        If (( ylds_rec.agmnt_yield = -1 ) OR (ylds_rec.contract_yield = -1 )) Then

            OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKL_AGMNT_NOYLD',
                                p_token1       => 'AGMNT',
                                p_token1_value => ylds_rec.agreement_number);

            RAISE OKL_API.G_EXCEPTION_ERROR;

        End If;

	l_agt_yld := ylds_rec.agmnt_yield/100.0;
	l_khr_yld := ylds_rec.contract_yield/100.0;

    ElsIf  ( nvl(l_hdrrl_rec.method, 'XYZ') = 'XYZ' )  Then

        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_INVALID_METHOD',
                            p_token1       => 'AGMNT',
                            p_token1_value => ylds_rec.agreement_number);

        RAISE OKL_API.G_EXCEPTION_ERROR;

    End If;

    OPEN c_stm_name;
    FETCH c_stm_name INTO r_stm_name;
    CLOSE c_stm_name;
     IF r_stm_name.name = 'LOAN_PAYMENT' THEN
      get_mapped_stream (p_sty_purpose       =>  r_stm_name.name,
                       p_mapping_type   =>  'DISBURSEMENT',
                       p_line_style     =>  NULL,
                       p_deal_type      =>  'LOAN',
                       p_khr_id         =>  p_agreement_id,
                       p_stream_type_purpose => r_stm_name.stream_type_purpose,
                       x_mapped_stream  =>  l_mapped_sty_name,
                       x_return_status  =>  x_return_status);

      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      If l_mapped_sty_name IS NOT NULL Then

    get_sty_details (p_sty_name      => l_mapped_sty_name,
                     x_sty_id        => l_sty_id,
                     x_sty_name      => l_sty_name,
                     x_return_status => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_stmv_rec := NULL;
    get_stream_header(p_purpose_code   => NULL,
                      p_khr_id         => p_contract_id,
                      p_kle_id         => p_kle_id,
                      p_sty_id         => l_sty_id,
                      x_stmv_rec       => l_stmv_rec,
                      x_return_status  => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR sec_strms_rec IN sec_strms_pend_csr
    LOOP

       i := l_selv_tbl.COUNT + 1;
       l_selv_tbl(i).se_line_number := i;
       l_selv_tbl(i).sel_id := sec_strms_rec.stream_ele_id;

       l_selv_tbl(i).stream_element_date := sec_strms_rec.stream_element_date;
       If ( l_hdrrl_rec.method = 'CASH_FLOW' ) Then
           l_selv_tbl(i).amount := sec_strms_rec.stream_ele_amount;
       Elsif ( l_hdrrl_rec.method = 'YIELD' ) Then
           l_selv_tbl(i).amount := sec_strms_rec.stream_ele_amount *
                        POWER(( 1+l_agt_yld )/(1+l_khr_yld), i);
       End If;
       l_stmv_rec.stm_id := sec_strms_rec.stm_id;

    END LOOP;

    x_stmv_rec := l_stmv_rec;
    x_selv_tbl := l_selv_tbl;

  End If;
  ELSE
         get_mapped_stream (p_sty_purpose       =>  r_stm_name.name,
                       p_mapping_type   =>  'DISBURSEMENT',
                       p_line_style     =>  NULL,
                       p_deal_type      =>  'LEASE',
		                     p_khr_id         =>  p_agreement_id,
                       x_mapped_stream  =>  l_mapped_sty_name,
                       x_return_status  =>  x_return_status);

      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      If l_mapped_sty_name IS NOT NULL Then

    get_sty_details (p_sty_name      => l_mapped_sty_name,
                     x_sty_id        => l_sty_id,
                     x_sty_name      => l_sty_name,
                     x_return_status => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_stmv_rec := NULL;
    get_stream_header(p_purpose_code   => NULL,
                      p_khr_id         => p_contract_id,
                      p_kle_id         => p_kle_id,
                      p_sty_id         => l_sty_id,
                      x_stmv_rec       => l_stmv_rec,
                      x_return_status  => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR sec_strms_rec IN sec_strms_pend_csr
    LOOP

       i := l_selv_tbl.COUNT + 1;
       l_selv_tbl(i).se_line_number := i;
       l_selv_tbl(i).sel_id := sec_strms_rec.stream_ele_id;

       l_selv_tbl(i).stream_element_date := sec_strms_rec.stream_element_date;
       If ( l_hdrrl_rec.method = 'CASH_FLOW' ) Then
           l_selv_tbl(i).amount := sec_strms_rec.stream_ele_amount;
       Elsif ( l_hdrrl_rec.method = 'YIELD' ) Then
           l_selv_tbl(i).amount := sec_strms_rec.stream_ele_amount *
                        POWER(( 1+l_agt_yld )/(1+l_khr_yld), i);
       End If;
       l_stmv_rec.stm_id := sec_strms_rec.stm_id;

    END LOOP;

    x_stmv_rec := l_stmv_rec;
    x_selv_tbl := l_selv_tbl;

  End If;
 END IF;
END IF;
/* sosharma End Changes*/

  print( l_api_name, 'end' );
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    Exception

	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

   END gen_disb_streams;


  PROCEDURE  gen_pv_disb_streams(p_api_version         IN      NUMBER,
                                       p_init_msg_list       IN      VARCHAR2,
                                       p_contract_id         IN      NUMBER,
                                       p_agreement_id        IN      NUMBER,
                               	       p_pool_status         IN      VARCHAR2,
                                       p_mode                IN      VARCHAR2 DEFAULT NULL,
                                       x_return_status       OUT NOCOPY VARCHAR2,
                                       x_msg_count           OUT NOCOPY NUMBER,
                                       x_msg_data            OUT NOCOPY VARCHAR2) IS


    l_api_name         CONSTANT VARCHAR2(61) := 'gen_pv_disb_streams';

    Cursor l_strms_csr ( khrId NUMBER, kleId NUMBER, strmname VARCHAR2) IS
    select stm.id strm_id
    from   okl_strm_type_v sty,
	   okl_strm_type_tl stl,
	   okl_streams stm
     where stl.language = 'US'
       and stl.name = strmname
       and sty.id = stl.id
       and stm.sty_id = sty.id
       and stm.kle_id = kleId
       and stm.khr_id = khrId
       and stm.say_code = 'CURR';

    l_strms_rec l_strms_csr%ROWTYPE;

    Cursor sec_strms_csr ( poolstat VARCHAR2 ) IS
    select pol.khr_id agreement_id,
           pcn.khr_id contract_id,
           pcn.kle_id asset_id,
           pcn.sty_id stream_type_id,
           sty.stream_type_subclass stream_type_subclass,
           sty.stream_type_purpose stream_type_purpose
    from   okl_pools pol,
           okl_pool_contents pcn,
	   okl_strm_type_v sty,
	   okl_streams stm
     where pcn.sty_id = sty.id
       and pcn.pol_id = pol.id
       and stm.kle_id = pcn.kle_id
       and stm.khr_id = pcn.khr_id
       and stm.sty_id = pcn.sty_id
       and stm.say_code = 'CURR'
       and stm.active_yn = 'Y'
       and pol.status_code = poolstat
       and nvl(stm.khr_id, 0) = nvl(p_contract_id, -1)
       and pcn.status_code IN (G_IA_STS_NEW,G_IA_STS_ACTIVE)
    Union
    select pol.khr_id agreement_id,
           pcn.khr_id contract_id,
           pcn.kle_id asset_id,
           pcn.sty_id stream_type_id,
           sty.stream_type_subclass stream_type_subclass,
           sty.stream_type_purpose stream_type_purpose
    from   okl_pools pol,
           okl_pool_contents pcn,
	   okl_strm_type_v sty,
	   okl_streams stm
     where pcn.sty_id = sty.id
       and pcn.pol_id = pol.id
       and stm.kle_id = pcn.kle_id
       and stm.khr_id = pcn.khr_id
       and stm.sty_id = pcn.sty_id
       and stm.say_code = 'CURR'
       and stm.active_yn = 'Y'
       and pol.status_code = poolstat
       and nvl(pol.khr_id, 0) = nvl(p_agreement_id, -1)
       and pcn.status_code IN (G_IA_STS_NEW,G_IA_STS_ACTIVE)
       order by agreement_id, contract_id, asset_id, stream_type_id;

/* sosharma ,14-12-2007
Bug 6691554
Start Changes*/

    Cursor sec_strms_pend_csr ( poolstat VARCHAR2 ) IS
    select pol.khr_id agreement_id,
           pcn.khr_id contract_id,
           pcn.kle_id asset_id,
           pcn.sty_id stream_type_id,
          sty.stream_type_subclass stream_type_subclass,
           sty.stream_type_purpose stream_type_purpose
    from   okl_pools pol,
           okl_pool_contents pcn,
           okl_strm_type_v sty,
           okl_streams stm
     where pcn.sty_id = sty.id
       and pcn.pol_id = pol.id
       and stm.kle_id = pcn.kle_id
       and stm.khr_id = pcn.khr_id
       and stm.sty_id = pcn.sty_id
       and stm.say_code = 'CURR'
       and stm.active_yn = 'Y'
       and pol.status_code = poolstat
       and nvl(stm.khr_id, 0) = nvl(p_contract_id, -1)
       and pcn.status_code=G_PC_STS_PENDING
    Union
    select pol.khr_id agreement_id,
           pcn.khr_id contract_id,
           pcn.kle_id asset_id,
           pcn.sty_id stream_type_id,
           sty.stream_type_subclass stream_type_subclass,
           sty.stream_type_purpose stream_type_purpose
    from   okl_pools pol,
           okl_pool_contents pcn,
           okl_strm_type_v sty,
           okl_streams stm
     where pcn.sty_id = sty.id
       and pcn.pol_id = pol.id
       and stm.kle_id = pcn.kle_id
       and stm.khr_id = pcn.khr_id
       and stm.sty_id = pcn.sty_id
       and stm.say_code = 'CURR'
       and stm.active_yn = 'Y'
       and pol.status_code = poolstat
       and nvl(pol.khr_id, 0) = nvl(p_agreement_id, -1)
       and pcn.status_code=G_PC_STS_PENDING
       order by agreement_id, contract_id, asset_id, stream_type_id;

/* sosharma End Changes*/
      sec_strms_rec sec_strms_csr%ROWTYPE;

    l_sty_id NUMBER;

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_stmv_tbl               okl_streams_pub.stmv_tbl_type;
    x_stmv_tbl               okl_streams_pub.stmv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

   i NUMBER;
   n NUMBER;

   l_sty_id NUMBER;
   l_sty_name VARCHAR2(256);

   l_pool_status VARCHAR2(256);
   l_mapped_sty_name        VARCHAR2(150);

   BEGIN

    print( l_api_name, 'begin' );

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => p_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    print( l_api_name, 'save point' );

    If ( nvl(p_pool_status, 'XXX') = 'XXX' ) AND ( nvl(p_agreement_id, -1) <> -1  ) Then
        l_pool_status := 'NEW';
    ELsif( nvl(p_pool_status, 'XXX') = 'XXX' ) AND ( nvl(p_contract_id, -1) <> -1) Then
        l_pool_status := 'ACTIVE';
    Else
        l_pool_status := p_pool_status;
    End If;

    print( l_api_name, 'pool stat' || l_pool_status );

  IF p_mode IS NULL THEN
    FOR sec_strms_rec IN sec_strms_csr( l_pool_status )
    LOOP
         IF sec_strms_rec.stream_type_subclass = 'LOAN_PAYMENT' THEN
            get_mapped_stream (p_sty_purpose       =>  sec_strms_rec.stream_type_subclass,
                           p_mapping_type   =>  'PV_DISBURSEMENT',
                           p_line_style     =>  NULL,
                           p_deal_type      =>  'LOAN',
                           p_khr_id         =>  sec_strms_rec.agreement_id,
                           p_stream_type_purpose => sec_strms_rec.stream_type_purpose,
                           x_mapped_stream  =>  l_mapped_sty_name,
                           x_return_status  =>  x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      If ( l_mapped_sty_name IS NOT NULL ) Then

        print( l_api_name, ' mapped stream ' || l_mapped_sty_name, x_return_status );
        i := 0;
        FOR  l_strms_rec in l_strms_csr( sec_strms_rec.contract_id,
	                                 sec_strms_rec.asset_id,
					 l_mapped_sty_name )
        LOOP

            i := i + 1;
            l_stmv_tbl(i).id := l_strms_rec.STRM_ID;
            l_stmv_tbl(i).say_code := 'HIST';
            l_stmv_tbl(i).active_yn := 'N';
            l_stmv_tbl(i).date_history := sysdate;

        END LOOP;

        If ( l_stmv_tbl.COUNT > 0 ) Then

            Okl_Streams_pub.update_streams(
                             p_api_version => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data,
                             p_stmv_tbl => l_stmv_tbl,
                             x_stmv_tbl => x_stmv_tbl);

            IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        End If;
        l_stmv_tbl.delete;

      End If;

      ELSE
        get_mapped_stream (p_sty_purpose       =>  sec_strms_rec.stream_type_subclass,
                           p_mapping_type   =>  'PV_DISBURSEMENT',
                           p_line_style     =>  NULL,
                           p_deal_type      =>  'LEASE',
                       	   p_khr_id         =>  sec_strms_rec.agreement_id,
                           x_mapped_stream  =>  l_mapped_sty_name,
                           x_return_status  =>  x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      If ( l_mapped_sty_name IS NOT NULL ) Then

        print( l_api_name, ' mapped stream ' || l_mapped_sty_name, x_return_status );
        i := 0;
        FOR  l_strms_rec in l_strms_csr( sec_strms_rec.contract_id,
	                                 sec_strms_rec.asset_id,
					 l_mapped_sty_name )
        LOOP

            i := i + 1;
            l_stmv_tbl(i).id := l_strms_rec.STRM_ID;
            l_stmv_tbl(i).say_code := 'HIST';
            l_stmv_tbl(i).active_yn := 'N';
            l_stmv_tbl(i).date_history := sysdate;

        END LOOP;

        If ( l_stmv_tbl.COUNT > 0 ) Then

            Okl_Streams_pub.update_streams(
                             p_api_version => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data,
                             p_stmv_tbl => l_stmv_tbl,
                             x_stmv_tbl => x_stmv_tbl);

            IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        End If;
        l_stmv_tbl.delete;

      End If;
      END IF;

    END LOOP;

    FOR sec_strms_rec IN sec_strms_csr( l_pool_status )
    LOOP

        l_stmv_rec := NULL;
        gen_pv_streams(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         p_pool_status   => l_pool_status,
                         p_agreement_id  => sec_strms_rec.agreement_id,
                         p_contract_id   => sec_strms_rec.contract_id,
                         p_kle_id        => sec_strms_rec.asset_id,
                         p_sty_id        => sec_strms_rec.stream_type_id,
                         p_mode          => p_mode,
                         x_stmv_rec      => l_stmv_rec,
                         x_selv_tbl      => l_selv_tbl,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data);

         IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_stmv_rec.say_code := 'CURR';
	 l_stmv_rec.date_current := sysdate;
	 l_stmv_rec.active_yn := 'Y';
         l_stmv_rec.source_table := 'OKL_K_HEADERS';
         l_stmv_rec.source_id := sec_strms_rec.agreement_id;

         print( l_api_name, ' # of streams ' || to_char( l_selv_tbl.COUNT ) );
         If( l_selv_tbl.COUNT > 0 AND (l_stmv_rec.sty_id IS NOT NULL) ) Then

             print( l_api_name, ' creating pv disb streams ' );

            x_return_status := Okl_Streams_Util.round_streams_amount(
                                p_api_version   => g_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => l_stmv_Rec.khr_id,
                                p_selv_tbl      => l_selv_tbl,
                                x_selv_tbl      => lx_selv_tbl);

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_selv_tbl.DELETE;
            l_selv_tbl := lx_selv_tbl;

             okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                            p_init_msg_list   =>   G_FALSE,
                                            x_return_status   =>   x_return_status,
                                            x_msg_count       =>   x_msg_count,
                                            x_msg_data        =>   x_msg_data,
                                            p_stmv_rec        =>   l_stmv_rec,
                                            p_selv_tbl        =>   l_selv_tbl,
                                            x_stmv_rec        =>   lx_stmv_rec,
                                            x_selv_tbl        =>   lx_selv_tbl);

             print( l_api_name, ' creating pv disb streams  : done ', x_return_status );
               IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

                l_selv_tbl.delete;

	  End if;

    END LOOP;
 ELSE
  FOR sec_strms_rec IN sec_strms_pend_csr( l_pool_status )
    LOOP
        IF sec_strms_rec.stream_type_subclass = 'LOAN_PAYMENT' THEN
          get_mapped_stream (p_sty_purpose       =>  sec_strms_rec.stream_type_subclass,
                           p_mapping_type   =>  'PV_DISBURSEMENT',
                           p_line_style     =>  NULL,
                           p_deal_type      =>  'LOAN',
                           p_stream_type_purpose => sec_strms_rec.stream_type_purpose,
                           p_khr_id         =>  sec_strms_rec.agreement_id,
                           x_mapped_stream  =>  l_mapped_sty_name,
                           x_return_status  =>  x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      If ( l_mapped_sty_name IS NOT NULL ) Then

        print( l_api_name, ' mapped stream ' || l_mapped_sty_name, x_return_status );
        i := 0;
        FOR  l_strms_rec in l_strms_csr( sec_strms_rec.contract_id,
	                                 sec_strms_rec.asset_id,
					 l_mapped_sty_name )
        LOOP

            i := i + 1;
            l_stmv_tbl(i).id := l_strms_rec.STRM_ID;
            l_stmv_tbl(i).say_code := 'HIST';
            l_stmv_tbl(i).active_yn := 'N';
            l_stmv_tbl(i).date_history := sysdate;

        END LOOP;

        If ( l_stmv_tbl.COUNT > 0 ) Then

            Okl_Streams_pub.update_streams(
                             p_api_version => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data,
                             p_stmv_tbl => l_stmv_tbl,
                             x_stmv_tbl => x_stmv_tbl);

            IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        End If;
        l_stmv_tbl.delete;

      End If;
      ELSE
        get_mapped_stream (p_sty_purpose       =>  sec_strms_rec.stream_type_subclass,
                           p_mapping_type   =>  'PV_DISBURSEMENT',
                           p_line_style     =>  NULL,
                           p_deal_type      =>  'LEASE',
                       	   p_khr_id         =>  sec_strms_rec.agreement_id,
                           x_mapped_stream  =>  l_mapped_sty_name,
                           x_return_status  =>  x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      If ( l_mapped_sty_name IS NOT NULL ) Then

        print( l_api_name, ' mapped stream ' || l_mapped_sty_name, x_return_status );
        i := 0;
        FOR  l_strms_rec in l_strms_csr( sec_strms_rec.contract_id,
	                                 sec_strms_rec.asset_id,
					 l_mapped_sty_name )
        LOOP

            i := i + 1;
            l_stmv_tbl(i).id := l_strms_rec.STRM_ID;
            l_stmv_tbl(i).say_code := 'HIST';
            l_stmv_tbl(i).active_yn := 'N';
            l_stmv_tbl(i).date_history := sysdate;

        END LOOP;

        If ( l_stmv_tbl.COUNT > 0 ) Then

            Okl_Streams_pub.update_streams(
                             p_api_version => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data,
                             p_stmv_tbl => l_stmv_tbl,
                             x_stmv_tbl => x_stmv_tbl);

            IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        End If;
        l_stmv_tbl.delete;

      End If;
END IF;

    END LOOP;

    FOR sec_strms_rec IN sec_strms_pend_csr( l_pool_status )
    LOOP

        l_stmv_rec := NULL;
        gen_pv_streams(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         p_pool_status   => l_pool_status,
                         p_agreement_id  => sec_strms_rec.agreement_id,
                         p_contract_id   => sec_strms_rec.contract_id,
                         p_kle_id        => sec_strms_rec.asset_id,
                         p_sty_id        => sec_strms_rec.stream_type_id,
                         p_mode          => p_mode,
                         x_stmv_rec      => l_stmv_rec,
                         x_selv_tbl      => l_selv_tbl,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data);

         IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_stmv_rec.say_code := 'CURR';
	 l_stmv_rec.date_current := sysdate;
	 l_stmv_rec.active_yn := 'Y';
         l_stmv_rec.source_table := 'OKL_K_HEADERS';
         l_stmv_rec.source_id := sec_strms_rec.agreement_id;

         print( l_api_name, ' # of streams ' || to_char( l_selv_tbl.COUNT ) );
         If( l_selv_tbl.COUNT > 0 AND (l_stmv_rec.sty_id IS NOT NULL) ) Then

             print( l_api_name, ' creating pv disb streams ' );

            x_return_status := Okl_Streams_Util.round_streams_amount(
                                p_api_version   => g_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => l_stmv_Rec.khr_id,
                                p_selv_tbl      => l_selv_tbl,
                                x_selv_tbl      => lx_selv_tbl);

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_selv_tbl.DELETE;
            l_selv_tbl := lx_selv_tbl;

             okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                            p_init_msg_list   =>   G_FALSE,
                                            x_return_status   =>   x_return_status,
                                            x_msg_count       =>   x_msg_count,
                                            x_msg_data        =>   x_msg_data,
                                            p_stmv_rec        =>   l_stmv_rec,
                                            p_selv_tbl        =>   l_selv_tbl,
                                            x_stmv_rec        =>   lx_stmv_rec,
                                            x_selv_tbl        =>   lx_selv_tbl);

             print( l_api_name, ' creating pv disb streams  : done ', x_return_status );
               IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

                l_selv_tbl.delete;

	  End if;

    END LOOP;

 END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    print( l_api_name, 'end' );

    Exception

	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

   END gen_pv_disb_streams;

   PROCEDURE  gen_disbursement_streams(p_api_version         IN      NUMBER,
                                       p_init_msg_list       IN      VARCHAR2,
                                       p_contract_id         IN      NUMBER,
                                       p_agreement_id        IN      NUMBER,
                                       p_pool_status         IN      VARCHAR2,
/* sosharma 14-12-2007 Added p_mode to the signature to pass mode
from calling procedure*/
                                       p_mode                IN      VARCHAR2 DEFAULT NULL,
                                       x_return_status       OUT NOCOPY VARCHAR2,
                                       x_msg_count           OUT NOCOPY NUMBER,
                                       x_msg_data            OUT NOCOPY VARCHAR2) IS


    l_api_name         CONSTANT VARCHAR2(61) := 'gen_disbursement_streams';

    Cursor l_strms_csr ( khrId NUMBER, kleId NUMBER, strmname VARCHAR2) IS
    select stm.id strm_id
    from   okl_strm_type_v sty,
	   okl_strm_type_tl stl,
	   okl_streams stm
     where stl.language = 'US'
       and stl.name = strmname
       and sty.id = stl.id
       and stm.sty_id = sty.id
       and stm.kle_id = kleId
       and stm.khr_id = khrId
       and stm.say_code = 'CURR';

    l_strms_rec l_strms_csr%ROWTYPE;

    Cursor sec_strms_csr ( poolstat VARCHAR2 ) IS
    select pol.khr_id agreement_id,
           pcn.khr_id contract_id,
           pcn.kle_id asset_id,
           pcn.sty_id stream_type_id,
           sty.stream_type_subclass stream_type_subclass,
           sty.stream_type_purpose stream_type_purpose
    from   okl_pools pol,
           okl_pool_contents pcn,
           okl_strm_type_v sty,
           okl_streams stm
     where pcn.sty_id = sty.id
       and pcn.pol_id = pol.id
       and stm.kle_id = pcn.kle_id
       and stm.khr_id = pcn.khr_id
       and stm.sty_id = pcn.sty_id
       and stm.say_code = 'CURR'
       and stm.active_yn = 'Y'
       and pol.status_code = poolstat
       and nvl(stm.khr_id, 0) = nvl(p_contract_id, -1)
       and pcn.status_code IN(G_IA_STS_NEW,G_IA_STS_ACTIVE)
    Union
    select pol.khr_id agreement_id,
           pcn.khr_id contract_id,
           pcn.kle_id asset_id,
           pcn.sty_id stream_type_id,
          sty.stream_type_subclass stream_type_subclass,
          sty.stream_type_purpose stream_type_purpose
    from   okl_pools pol,
           okl_pool_contents pcn,
           okl_strm_type_v sty,
           okl_streams stm
     where pcn.sty_id = sty.id
       and pcn.pol_id = pol.id
       and stm.kle_id = pcn.kle_id
       and stm.khr_id = pcn.khr_id
       and stm.sty_id = pcn.sty_id
       and stm.say_code = 'CURR'
       and stm.active_yn = 'Y'
       and pol.status_code = poolstat
       and nvl(pol.khr_id, 0) = nvl(p_agreement_id, -1)
       and pcn.status_code IN(G_IA_STS_NEW,G_IA_STS_ACTIVE)
       order by agreement_id, contract_id, asset_id, stream_type_id;

/* sosharma ,14-12-2007
Bug 6691554
Start Changes*/
--Changed Cursor to pich up pending requests

    Cursor sec_strms_pend_csr ( poolstat VARCHAR2 ) IS
    select pol.khr_id agreement_id,
           pcn.khr_id contract_id,
           pcn.kle_id asset_id,
           pcn.sty_id stream_type_id,
           sty.stream_type_subclass stream_type_subclass,
           sty.stream_type_purpose stream_type_purpose
    from   okl_pools pol,
           okl_pool_contents pcn,
           okl_strm_type_v sty,
           okl_streams stm
     where pcn.sty_id = sty.id
       and pcn.pol_id = pol.id
       and stm.kle_id = pcn.kle_id
       and stm.khr_id = pcn.khr_id
       and stm.sty_id = pcn.sty_id
       and stm.say_code = 'CURR'
       and stm.active_yn = 'Y'
       and pol.status_code = poolstat
       and nvl(stm.khr_id, 0) = nvl(p_contract_id, -1)
       and pcn.status_code=G_PC_STS_PENDING
    Union
    select pol.khr_id agreement_id,
           pcn.khr_id contract_id,
           pcn.kle_id asset_id,
           pcn.sty_id stream_type_id,
           sty.stream_type_subclass stream_type_subclass,
           sty.stream_type_purpose stream_type_purpose
    from   okl_pools pol,
           okl_pool_contents pcn,
           okl_strm_type_v sty,
           okl_streams stm
     where pcn.sty_id = sty.id
       and pcn.pol_id = pol.id
       and stm.kle_id = pcn.kle_id
       and stm.khr_id = pcn.khr_id
       and stm.sty_id = pcn.sty_id
       and stm.say_code = 'CURR'
       and stm.active_yn = 'Y'
       and pol.status_code = poolstat
       and nvl(pol.khr_id, 0) = nvl(p_agreement_id, -1)
       and pcn.status_code=G_PC_STS_PENDING
       order by agreement_id, contract_id, asset_id, stream_type_id;


/*soharma End Changes*/

      sec_strms_rec sec_strms_csr%ROWTYPE;

    l_sty_id NUMBER;

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_stmv_tbl               okl_streams_pub.stmv_tbl_type;
    x_stmv_tbl               okl_streams_pub.stmv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

   i NUMBER;
   n NUMBER;

   l_sty_id NUMBER;
   l_sty_name VARCHAR2(256);

   l_pool_status VARCHAR2(256);
   l_mapped_sty_name        VARCHAR2(150);

   BEGIN

    print( l_api_name, 'begin' );

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => p_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    print( l_api_name, 'save point' );

    If ( nvl(p_pool_status, 'XXX') = 'XXX' ) AND ( nvl(p_agreement_id, -1) <> -1  ) Then
        l_pool_status := 'NEW';
    ELsif( nvl(p_pool_status, 'XXX') = 'XXX' ) AND ( nvl(p_contract_id, -1) <> -1) Then
        l_pool_status := 'ACTIVE';
    Else
        l_pool_status := p_pool_status;
    End If;

    print( l_api_name, 'pool stat' || l_pool_status );
/* sosharma ,14-12-2007
Bug 6691554
Start Changes*/

--Based on the p_mode passed to the procedure two flows have been defined
 IF p_mode IS NULL THEN
    i := 0;
    FOR sec_strms_rec IN sec_strms_csr( l_pool_status )
    LOOP
        IF sec_strms_rec.stream_type_subclass = 'LOAN_PAYMENT' THEN
          get_mapped_stream (p_sty_purpose       =>  sec_strms_rec.stream_type_subclass,
                           p_mapping_type   =>  'DISBURSEMENT',
                           p_line_style     =>  NULL,
                           p_deal_type      =>  'LOAN',
                           p_stream_type_purpose => sec_strms_rec.stream_type_purpose,
                           p_khr_id         =>  sec_strms_rec.agreement_id,
                           x_mapped_stream  =>  l_mapped_sty_name,
                           x_return_status  =>  x_return_status);

    print( l_api_name, ' mapped sty ' || l_mapped_sty_name );

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      If l_mapped_sty_name IS NOT NULL Then

        FOR  l_strms_rec in l_strms_csr( sec_strms_rec.contract_id,
                                         sec_strms_rec.asset_id,
                                         l_mapped_sty_name )
        LOOP

            i := i + 1;
            l_stmv_tbl(i).id := l_strms_rec.STRM_ID;
            l_stmv_tbl(i).say_code := 'HIST';
            l_stmv_tbl(i).active_yn := 'N';
            l_stmv_tbl(i).date_history := sysdate;

        END LOOP;

        If ( l_stmv_tbl.COUNT > 0 ) Then

            Okl_Streams_pub.update_streams(
                             p_api_version => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data,
                             p_stmv_tbl => l_stmv_tbl,
                             x_stmv_tbl => x_stmv_tbl);

            IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        End If;
        l_stmv_tbl.delete;

      End If;

        ELSE
           get_mapped_stream (p_sty_purpose       =>  sec_strms_rec.stream_type_subclass,
                           p_mapping_type   =>  'DISBURSEMENT',
                           p_line_style     =>  NULL,
                           p_deal_type      =>  'LEASE',
	                          p_khr_id         =>  sec_strms_rec.agreement_id,
                           x_mapped_stream  =>  l_mapped_sty_name,
                           x_return_status  =>  x_return_status);

    print( l_api_name, ' mapped sty ' || l_mapped_sty_name );

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      If l_mapped_sty_name IS NOT NULL Then

        FOR  l_strms_rec in l_strms_csr( sec_strms_rec.contract_id,
                                         sec_strms_rec.asset_id,
                                         l_mapped_sty_name )
        LOOP

            i := i + 1;
            l_stmv_tbl(i).id := l_strms_rec.STRM_ID;
            l_stmv_tbl(i).say_code := 'HIST';
            l_stmv_tbl(i).active_yn := 'N';
            l_stmv_tbl(i).date_history := sysdate;

        END LOOP;

        If ( l_stmv_tbl.COUNT > 0 ) Then

            Okl_Streams_pub.update_streams(
                             p_api_version => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data,
                             p_stmv_tbl => l_stmv_tbl,
                             x_stmv_tbl => x_stmv_tbl);

            IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        End If;
        l_stmv_tbl.delete;

      End If;

        END IF;
    END LOOP;

    FOR sec_strms_rec IN sec_strms_csr( l_pool_status )
    LOOP

        print( l_api_name, ' mapped stream ' || l_mapped_sty_name, x_return_status );

        l_stmv_rec := NULL;
        gen_disb_streams(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         p_pool_status   => l_pool_status,
                         p_agreement_id  => sec_strms_rec.agreement_id,
                         p_contract_id   => sec_strms_rec.contract_id,
                         p_kle_id        => sec_strms_rec.asset_id,
                         p_sty_id        => sec_strms_rec.stream_type_id,
                         p_mode          => p_mode,
                         x_stmv_rec      => l_stmv_rec,
                         x_selv_tbl      => l_selv_tbl,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data);

         IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_stmv_rec.say_code := 'CURR';
	 l_stmv_rec.date_current := sysdate;
	 l_stmv_rec.active_yn := 'Y';
         l_stmv_rec.source_table := 'OKL_K_HEADERS';
         l_stmv_rec.source_id := sec_strms_rec.agreement_id;

         If( l_selv_tbl.COUNT > 0  AND l_stmv_rec.sty_id IS NOT NULL) Then

             print( l_api_name, ' creating disb streams ' );

            x_return_status := Okl_Streams_Util.round_streams_amount(
                                p_api_version   => g_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => l_stmv_Rec.khr_id,
                                p_selv_tbl      => l_selv_tbl,
                                x_selv_tbl      => lx_selv_tbl);

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_selv_tbl.DELETE;
            l_selv_tbl := lx_selv_tbl;

             okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                            p_init_msg_list   =>   G_FALSE,
                                            x_return_status   =>   x_return_status,
                                            x_msg_count       =>   x_msg_count,
                                            x_msg_data        =>   x_msg_data,
                                            p_stmv_rec        =>   l_stmv_rec,
                                            p_selv_tbl        =>   l_selv_tbl,
                                            x_stmv_rec        =>   lx_stmv_rec,
                                            x_selv_tbl        =>   lx_selv_tbl);

               IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

                l_selv_tbl.delete;

	  End if;

    END LOOP;
 ELSE
    i := 0;
    FOR sec_strms_rec IN sec_strms_pend_csr( l_pool_status )
    LOOP
        IF sec_strms_rec.stream_type_subclass = 'LOAN_PAYMENT' THEN
          get_mapped_stream (p_sty_purpose       =>  sec_strms_rec.stream_type_subclass,
                           p_mapping_type   =>  'DISBURSEMENT',
                           p_line_style     =>  NULL,
                           p_deal_type      =>  'LOAN',
                           p_stream_type_purpose => sec_strms_rec.stream_type_purpose,
                           p_khr_id         =>  sec_strms_rec.agreement_id,
                           x_mapped_stream  =>  l_mapped_sty_name,
                           x_return_status  =>  x_return_status);

    print( l_api_name, ' mapped sty ' || l_mapped_sty_name );

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      If l_mapped_sty_name IS NOT NULL Then

        FOR  l_strms_rec in l_strms_csr( sec_strms_rec.contract_id,
                                         sec_strms_rec.asset_id,
                                         l_mapped_sty_name )
        LOOP

            i := i + 1;
            l_stmv_tbl(i).id := l_strms_rec.STRM_ID;
            l_stmv_tbl(i).say_code := 'HIST';
            l_stmv_tbl(i).active_yn := 'N';
            l_stmv_tbl(i).date_history := sysdate;

        END LOOP;

        If ( l_stmv_tbl.COUNT > 0 ) Then

            Okl_Streams_pub.update_streams(
                             p_api_version => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data,
                             p_stmv_tbl => l_stmv_tbl,
                             x_stmv_tbl => x_stmv_tbl);

            IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        End If;
        l_stmv_tbl.delete;

      End If;

      ELSE
         get_mapped_stream (p_sty_purpose       =>  sec_strms_rec.stream_type_subclass,
                           p_mapping_type   =>  'DISBURSEMENT',
                           p_line_style     =>  NULL,
                           p_deal_type      =>  'LEASE',
			   p_khr_id         =>  sec_strms_rec.agreement_id,
                           x_mapped_stream  =>  l_mapped_sty_name,
                           x_return_status  =>  x_return_status);

    print( l_api_name, ' mapped sty ' || l_mapped_sty_name );

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      If l_mapped_sty_name IS NOT NULL Then

        FOR  l_strms_rec in l_strms_csr( sec_strms_rec.contract_id,
                                         sec_strms_rec.asset_id,
                                         l_mapped_sty_name )
        LOOP

            i := i + 1;
            l_stmv_tbl(i).id := l_strms_rec.STRM_ID;
            l_stmv_tbl(i).say_code := 'HIST';
            l_stmv_tbl(i).active_yn := 'N';
            l_stmv_tbl(i).date_history := sysdate;

        END LOOP;

        If ( l_stmv_tbl.COUNT > 0 ) Then

            Okl_Streams_pub.update_streams(
                             p_api_version => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data,
                             p_stmv_tbl => l_stmv_tbl,
                             x_stmv_tbl => x_stmv_tbl);

            IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        End If;
        l_stmv_tbl.delete;

      End If;
      END IF;

    END LOOP;



    FOR sec_strms_rec IN sec_strms_pend_csr( l_pool_status )
    LOOP

        print( l_api_name, ' mapped stream ' || l_mapped_sty_name, x_return_status );

        l_stmv_rec := NULL;
        gen_disb_streams(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         p_pool_status   => l_pool_status,
                         p_agreement_id  => sec_strms_rec.agreement_id,
                         p_contract_id   => sec_strms_rec.contract_id,
                         p_kle_id        => sec_strms_rec.asset_id,
                         p_sty_id        => sec_strms_rec.stream_type_id,
                         p_mode          => p_mode,
                         x_stmv_rec      => l_stmv_rec,
                         x_selv_tbl      => l_selv_tbl,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data);

         IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_stmv_rec.say_code := 'CURR';
	 l_stmv_rec.date_current := sysdate;
	 l_stmv_rec.active_yn := 'Y';
         l_stmv_rec.source_table := 'OKL_K_HEADERS';
         l_stmv_rec.source_id := sec_strms_rec.agreement_id;

         If( l_selv_tbl.COUNT > 0  AND l_stmv_rec.sty_id IS NOT NULL) Then

             print( l_api_name, ' creating disb streams ' );

            x_return_status := Okl_Streams_Util.round_streams_amount(
                                p_api_version   => g_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_chr_id        => l_stmv_Rec.khr_id,
                                p_selv_tbl      => l_selv_tbl,
                                x_selv_tbl      => lx_selv_tbl);

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            l_selv_tbl.DELETE;
            l_selv_tbl := lx_selv_tbl;

             okl_streams_pub.create_streams(p_api_version     =>   G_API_VERSION,
                                            p_init_msg_list   =>   G_FALSE,
                                            x_return_status   =>   x_return_status,
                                            x_msg_count       =>   x_msg_count,
                                            x_msg_data        =>   x_msg_data,
                                            p_stmv_rec        =>   l_stmv_rec,
                                            p_selv_tbl        =>   l_selv_tbl,
                                            x_stmv_rec        =>   lx_stmv_rec,
                                            x_selv_tbl        =>   lx_selv_tbl);

               IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

                l_selv_tbl.delete;

	  End if;

    END LOOP;

 END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    print( l_api_name, 'end' );

    Exception

	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

   END gen_disbursement_streams;


   PROCEDURE  create_disb_streams(p_api_version      IN      NUMBER,
                                       p_init_msg_list       IN      VARCHAR2,
                                       p_agreement_id        IN      NUMBER,
                                       p_pool_status         IN      VARCHAR2 DEFAULT 'NEW',
-- sosharma bug 6691554 ,added p_mode call for content status pending
                                       p_mode                IN       VARCHAR2 DEFAULT NULL,
                                       x_return_status       OUT NOCOPY VARCHAR2,
                                       x_msg_count           OUT NOCOPY NUMBER,
                                       x_msg_data            OUT NOCOPY VARCHAR2) IS


    l_api_name         CONSTANT VARCHAR2(61) := 'create_disb_streams';

   BEGIN

    print( l_api_name, 'begin' );

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => p_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    gen_disbursement_streams(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             p_contract_id   => NULL,
                             p_agreement_id  => p_agreement_id,
                             p_pool_status   => p_pool_status,
-- sosharma 14-12-2007 bug 6691554 ,added p_mode to pass mode pending for downstream processing
                             p_mode          => p_mode,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);

    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    print( l_api_name, 'end' );
    Exception

	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

   END create_disb_streams;


   PROCEDURE  create_disb_streams(p_api_version     IN      NUMBER,
                                       p_init_msg_list      IN      VARCHAR2,
                                       p_contract_id        IN      NUMBER,
                                       p_pool_status        IN      VARCHAR2 DEFAULT 'ACTIVE',
                                       x_return_status       OUT NOCOPY VARCHAR2,
                                       x_msg_count           OUT NOCOPY NUMBER,
                                       x_msg_data            OUT NOCOPY VARCHAR2) IS


    l_api_name         CONSTANT VARCHAR2(61) := 'create_disb_streams';

   BEGIN

    print( l_api_name, 'begin' );

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => p_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    gen_disbursement_streams(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             p_contract_id   => p_contract_id,
                             p_agreement_id  => NULL,
                             p_pool_status   => p_pool_status,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);

    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    print( l_api_name, 'end' );
    Exception

	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

   END create_disb_streams;

   PROCEDURE  create_pv_streams(p_api_version      IN      NUMBER,
                                       p_init_msg_list       IN      VARCHAR2,
                                       p_agreement_id        IN      NUMBER,
                                       p_pool_status         IN      VARCHAR2 DEFAULT 'NEW',
                                       p_mode                IN      VARCHAR2 DEFAULT NULL,
                                       x_return_status       OUT NOCOPY VARCHAR2,
                                       x_msg_count           OUT NOCOPY NUMBER,
                                       x_msg_data            OUT NOCOPY VARCHAR2) IS


    l_api_name         CONSTANT VARCHAR2(61) := 'create_pv_streams';

   BEGIN

    print( l_api_name, 'begin' );

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => p_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    gen_pv_disb_streams(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             p_contract_id   => NULL,
                             p_agreement_id  => p_agreement_id,
                             p_pool_status   => p_pool_status,
                             p_mode          => p_mode,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);

    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    print( l_api_name, 'end' );
    Exception

      when OKL_API.G_EXCEPTION_ERROR then
       x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

       when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
         p_api_name  => l_api_name,
         p_pkg_name  => g_pkg_name,
         p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
         x_msg_count => x_msg_count,
         x_msg_data  => x_msg_data,
         p_api_type  => g_api_type);

      when OTHERS then
            x_return_status := OKL_API.HANDLE_EXCEPTIONS(
        p_api_name  => l_api_name,
        p_pkg_name  => g_pkg_name,
        p_exc_name  => 'OTHERS',
        x_msg_count => x_msg_count,
        x_msg_data  => x_msg_data,
        p_api_type  => g_api_type);

   END create_pv_streams;


   PROCEDURE  create_pv_streams(p_api_version     IN      NUMBER,
                                       p_init_msg_list      IN      VARCHAR2,
                                       p_contract_id        IN      NUMBER,
                                       p_pool_status        IN      VARCHAR2 DEFAULT 'ACTIVE',
                                       x_return_status       OUT NOCOPY VARCHAR2,
                                       x_msg_count           OUT NOCOPY NUMBER,
                                       x_msg_data            OUT NOCOPY VARCHAR2) IS


    l_api_name         CONSTANT VARCHAR2(61) := 'create_pv_streams';

   BEGIN

    print( l_api_name, 'begin' );

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => p_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    gen_pv_disb_streams(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             p_contract_id   => p_contract_id,
                             p_agreement_id  => NULL,
                             p_pool_status   => p_pool_status,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);

    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    print( l_api_name, 'end' );
    Exception

	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

   END create_pv_streams;

  PROCEDURE  get_line_principal_bal( p_api_version         IN      NUMBER,
                                    p_init_msg_list       IN      VARCHAR2,
                                    p_khr_id              IN      NUMBER,
                                    p_kle_id              IN      NUMBER,
                                    p_date                IN      DATE,
				    x_principal_balance   OUT NOCOPY NUMBER,
				    x_accumulated_int     OUT NOCOPY NUMBER,
                                    x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                                    x_msg_data            OUT NOCOPY VARCHAR2) IS


    CURSOR c_hdr IS
    SELECT  nvl(khr.implicit_interest_rate, 0),
            khr.deal_type
    FROM   okc_k_headers_b chr,
           okl_k_headers khr
    WHERE  khr.id = p_khr_id
      AND  chr.id = khr.id;

    r_hdr c_hdr%ROWTYPE;


    CURSOR c_pbal IS
    SELECT ele.amount,
           ele.stream_element_date
    FROM okl_streams stm,
         okl_strm_elements ele,
     	 okl_strm_type_b sty
    WHERE sty.stream_type_purpose = 'PRINCIPAL_BALANCE'
      AND stm.sty_id = sty.id
      AND stm.khr_id = p_khr_id
      AND stm.kle_id = p_kle_id
      AND stm.say_code = 'CURR'
      AND stm.active_yn = 'Y'
      AND ele.stm_id = stm.id
      AND ele.stream_element_date =
                    ( SELECT max( ele.stream_element_date)
                      FROM okl_streams stm,
                           okl_strm_elements ele,
	                   okl_strm_type_b sty
                      WHERE sty.stream_type_purpose = 'PRINCIPAL_BALANCE'
                        AND stm.sty_id = sty.id
                        AND stm.khr_id = p_khr_id
                        AND stm.kle_id = p_kle_id
                        AND stm.say_code = 'CURR'
                    	AND stm.active_yn = 'Y'
                        AND ele.stm_id = stm.id
                        AND ele.stream_element_date <= p_date );

    r_pbal c_pbal%ROWTYPE;

    CURSOR c_inflows ( styId NUMBER) IS
    SELECT DISTINCT
           sll.object1_id1 frequency,
	   nvl(sll.rule_information10, 'N') advance_arrears
    FROM   okc_rules_b sll,
           okc_rules_b slh,
           okc_rule_groups_b rgp
    WHERE  rgp.rgd_code = 'LALEVL'
      AND  rgp.id = slh.rgp_id
      AND  slh.rule_information_category = 'LASLH'
      AND  slh.object1_id1 = styId
      AND  slh.id = sll.object2_id1
      AND  sll.rule_information_category = 'LASLL'
      AND  sll.dnz_chr_id = p_khr_id
      AND  rgp.cle_id = p_kle_id;

    r_inflows c_inflows%ROWTYPE;

    l_iir NUMBER;
    l_days NUMBER;
    l_principal_balance NUMBER;
    l_principal_bal_date DATE;
    l_accumulated_int NUMBER;


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
    SELECT sty.id
      FROM   okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp,
             okl_strm_type_b sty
      WHERE  rgp.dnz_chr_id = p_khr_id
        AND  rgp.cle_id = p_kle_id
        AND  rgp.rgd_code= 'LALEVL'
        AND  rgp.id = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  slh.object1_id1 = TO_CHAR(sty.id)
        AND  TO_CHAR(slh.id) = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
      ORDER BY fnd_date.canonical_to_date(sll.rule_information2);

    l_deal_type VARCHAR2(30);

    l_api_name         CONSTANT VARCHAR2(61) := 'GET_SCHED_PRINCIPAL_BAL';

    l_day_convention_month VARCHAR2(30);
    l_day_convention_year VARCHAR2(30);

   Begin

       print( l_api_name, 'end' );

       OPEN c_pbal;
       FETCH c_pbal INTO r_pbal;
       CLOSE c_pbal;

       l_principal_balance := nvl( r_pbal.amount, 0 );
       l_principal_bal_date := nvl( r_pbal.stream_element_date, p_date );

       print( l_api_name, ' prince date ' || to_char( l_principal_bal_date) );
       OPEN c_hdr;
       FETCH c_hdr INTO l_iir, l_deal_type;
       CLOSE c_hdr;
       l_iir := l_iir/100.0;

       OPEN fee_type_csr;
       FETCH fee_type_csr INTO fee_type_rec;
       CLOSE fee_type_csr;

       If nvl(fee_type_rec.What, 'N') = 'Y' Then

           OPEN fee_strm_type_csr;
           FETCH fee_strm_type_csr INTO l_sty_id;
   	   CLOSE fee_strm_type_csr;

       Else
           OKL_ISG_UTILS_PVT.get_primary_stream_type(
                                                p_khr_id              => p_khr_id,
						p_deal_type           => l_deal_type,
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

       OPEN c_inflows ( l_sty_id );
       FETCH c_inflows INTO r_inflows;
       CLOSE c_inflows;

       print( l_api_name, ' bal datae ' || to_char( l_principal_bal_date ), x_return_status );
       print( l_api_name, ' p_days ' || to_char( p_date ), x_return_status );

       -- Fetch the day convention ..
       OKL_PRICING_UTILS_PVT.get_day_convention(
         p_id              => p_khr_id,
         p_source          => 'ISG',
         x_days_in_month   => l_day_convention_month,
         x_days_in_year    => l_day_convention_year,
         x_return_status   => x_return_status);
       print( 'get_line_principal_bal', 'Month / Year = ' || l_day_convention_month || '/' || l_day_convention_year );
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       l_days := OKL_PRICING_UTILS_PVT.get_day_count (p_start_date => trunc(l_principal_bal_date),
                                p_days_in_month => l_day_convention_month,
                                p_days_in_year => l_day_convention_year,
                                p_end_date   => trunc(p_date),
                                p_arrears    => r_inflows.advance_arrears,
                                x_return_status => x_return_status);

       print( l_api_name, ' n days ' || to_char( l_days), x_return_status );

       IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       l_accumulated_int := l_principal_balance * l_days * l_iir/360;

       x_principal_balance := l_principal_balance;
       x_accumulated_int   := l_accumulated_int;

       print( l_api_name, ' line ' || to_char(p_kle_id) );
       print( l_api_name, '     iir ' || to_char(l_iir) );
       print( l_api_name, '     prince ' || to_char(l_principal_balance) );
       print( l_api_name, '     days ' || to_char(l_days) );
       print( l_api_name, '     accu ' || to_char(l_accumulated_int) );

       print( l_api_name, 'end');
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

   End get_line_principal_bal;

  PROCEDURE  get_sched_principal_bal( p_api_version         IN      NUMBER,
                                    p_init_msg_list       IN      VARCHAR2,
                                    p_khr_id              IN      NUMBER,
                                    p_kle_id              IN      NUMBER DEFAULT NULL,
                                    p_date                IN      DATE,
				    x_principal_balance   OUT NOCOPY NUMBER,
				    x_accumulated_int     OUT NOCOPY NUMBER,
                                    x_return_status       OUT NOCOPY VARCHAR2,
                                    x_msg_count           OUT NOCOPY NUMBER,
                                    x_msg_data            OUT NOCOPY VARCHAR2) IS

    cursor l_line_csr IS
    select kle.id
     from  okl_k_lines_full_v kle,
           okc_line_styles_b lse,
	   okc_statuses_b sts
     where KLE.LSE_ID = LSE.ID
          and lse.lty_code in  ('FREE_FORM1', 'FEE')
	  AND nvl(kle.fee_type,'-99') in ( '-99', 'FINANCED', 'ROLLOVER')
          and kle.dnz_chr_id = p_khr_id
	  and sts.code = kle.sts_code
	  and sts.ste_code not in ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

     l_line_rec l_line_csr%ROWTYPE;

     l_principal_balance NUMBER;
     l_principal_bal_date DATE;
     l_accumulated_int NUMBER;

    l_api_name         CONSTANT VARCHAR2(61) := 'GET_SCHED_PRINCIPAL_BAL';

   Begin

       print( l_api_name, 'begin');
       If (p_kle_id IS NOT NULL ) Then

           get_line_principal_bal( p_api_version         => p_api_version,
                                    p_init_msg_list       => p_init_msg_list,
                                    p_khr_id              => p_khr_id,
                                    p_kle_id              => p_kle_id,
                                    p_date                => p_date,
				    x_principal_balance   => x_principal_balance,
				    x_accumulated_int     => x_accumulated_int,
                                    x_return_status       => x_return_status,
                                    x_msg_count           => x_msg_count,
                                    x_msg_data            => x_msg_data);

           IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           return;

       End If;

       l_principal_balance := 0;
       l_accumulated_int := 0;

       FOR l_line_rec IN l_line_csr
       LOOP

           get_line_principal_bal( p_api_version         => p_api_version,
                                    p_init_msg_list       => p_init_msg_list,
                                    p_khr_id              => p_khr_id,
                                    p_kle_id              => l_line_rec.id,
                                    p_date                => p_date,
				    x_principal_balance   => x_principal_balance,
				    x_accumulated_int     => x_accumulated_int,
                                    x_return_status       => x_return_status,
                                    x_msg_count           => x_msg_count,
                                    x_msg_data            => x_msg_data);

           IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           l_principal_balance := l_principal_balance + x_principal_balance;
           l_accumulated_int := l_accumulated_int + x_accumulated_int;

       END LOOP;

       x_principal_balance := l_principal_balance;
       x_accumulated_int := l_accumulated_int;

       print( l_api_name, 'end');

 EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

   End get_sched_principal_bal;

  PROCEDURE get_next_billing_date( p_api_version            IN NUMBER,
                                   p_init_msg_list          IN VARCHAR2,
                                   p_khr_id                 IN NUMBER,
                                   p_billing_date           IN DATE DEFAULT NULL,
                                   x_next_due_date          OUT NOCOPY DATE,
                                   x_next_period_start_date OUT NOCOPY DATE,
                                   x_next_period_end_date   OUT NOCOPY  DATE,
                                   x_return_status          OUT NOCOPY VARCHAR2,
                                   x_msg_count              OUT NOCOPY NUMBER,
                                   x_msg_data               OUT NOCOPY VARCHAR2) IS


  --Added order by rul2.rule_information2 by djanaswa for bug 6007644
      CURSOR l_varint_sll_csr( khrid NUMBER ) IS
      SELECT TO_NUMBER(NULL) cle_id,
             TO_NUMBER(rul1.object1_id1) sty_id,
             FND_DATE.canonical_to_date(rul2.rule_information2) start_date,
             TO_NUMBER(rul2.rule_information3) periods,
             rul2.object1_id1 frequency,
             rul2.rule_information5 structure,
             DECODE(rul2.rule_information10, 'Y', 'ARREARS', 'ADVANCE') advance_arrears,
             FND_NUMBER.canonical_to_number(rul2.rule_information6) amount,
             TO_NUMBER(rul2.rule_information7) stub_days,
             TO_NUMBER(rul2.rule_information8) stub_amount,
             NULL lty_code,
             TO_NUMBER(NULL) capital_amount,
             TO_NUMBER(NULL) residual_value
      FROM   okc_rule_groups_b rgp,
             okc_rules_b rul1,
             okc_rules_b rul2,
	     okl_strm_type_b sty
      WHERE  rul2.dnz_chr_id = khrid
        AND  rul2.rule_information_category = 'LASLL'
        AND  rul2.rgp_id = rgp.id
        AND  rgp.cle_id IS NULL
        AND  TO_NUMBER(rul2.object2_id1) = rul1.id
	AND  TO_NUMBER(rul1.object1_id1) = sty.id
	AND  sty.stream_type_purpose = 'VARIABLE_INTEREST_SCHEDULE'
       ORDER BY FND_DATE.canonical_to_date(rul2.rule_information2);

      l_varint_sll_rec l_varint_sll_csr%ROWTYPE;

        l_advance_or_arrears VARCHAR2(10) := 'ARREARS';

   Cursor l_strms_csr ( chrId NUMBER, styId NUMBER ) IS
   Select str.id  strm_id
   From okl_streams str
   Where str.sty_id = styId
       and str.khr_id = chrId
       and str.say_code = 'WORK';

    l_strms_rec l_strms_csr%ROWTYPE;

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

    l_hdr                    c_hdr%ROWTYPE;
    l_deal_type              VARCHAR2(30);
    l_purpose_code           VARCHAR2(30);

    l_sty_id                 NUMBER;
    l_sty_name               VARCHAR2(150);
    l_mapped_sty_name        VARCHAR2(150);

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_pt_tbl                 okl_streams_pub.selv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    l_stmv_tbl               okl_streams_pub.stmv_tbl_type;
    lx_stmv_tbl               okl_streams_pub.stmv_tbl_type;
    x_stmv_tbl               okl_streams_pub.stmv_tbl_type;
    l_pt_rec                 okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

    i                        BINARY_INTEGER := 0;

    l_api_name         CONSTANT VARCHAR2(61) := 'GET_NEXT_BILL_DATE';

   --Added by djanaswa for bug 6007644
    l_recurrence_date    DATE := NULL;
    --end djanaswa

   BEGIN

    print( l_api_name, 'begin' );

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => p_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

/*
    get_sty_details (p_sty_name      => 'VARIABLE INTEREST SCHEDULE',
                     x_sty_id        => l_sty_id,
                     x_sty_name      => l_sty_name,
		     x_return_status => x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

*/
     OPEN  c_hdr;
     FETCH c_hdr INTO l_hdr;
     CLOSE c_hdr;

     x_next_due_date := NULL;
     x_next_period_end_date := NULL;

     FOR l_varint_sll_rec in l_varint_sll_csr( p_khr_id )
     LOOP

         IF ( lx_selv_tbl.COUNT > 0 ) Then
             lx_selv_tbl.delete;
	 END IF;

       --Added by djanaswa for bug 6007644
         IF((l_varint_sll_rec.periods IS NULL) AND (l_varint_sll_rec.stub_days IS NOT NULL)) THEN
           --Set the recurrence date to null for stub payment
           l_recurrence_date := NULL;
         ELSIF(l_recurrence_date IS NULL) THEN
           --Set the recurrence date as periodic payment level start date
           l_recurrence_date := l_varint_sll_rec.start_date;
         END IF;
         --end djanaswa

         --Added parameter p_recurrence_date by djanaswa for bug 6007644
         get_stream_elements(
	                   p_start_date          =>   l_varint_sll_rec.start_date,
                           p_periods             =>   l_varint_sll_rec.periods,
			   p_frequency           =>   l_varint_sll_rec.frequency,
			   p_structure           =>   l_varint_sll_rec.structure,
			   p_advance_or_arrears  =>   l_varint_sll_rec.advance_arrears,
			   p_amount              =>   l_varint_sll_rec.amount,
			   p_stub_days           =>   l_varint_sll_rec.stub_days,
			   p_stub_amount         =>   l_varint_sll_rec.stub_amount,
			   p_currency_code       =>   l_hdr.currency_code,
			   p_khr_id              =>   p_khr_id,
			   p_kle_id              =>   NULL,
			   p_purpose_code        =>   NULL,
			   x_selv_tbl            =>   lx_selv_tbl,
			   x_pt_tbl              =>   l_pt_tbl,
			   x_return_status       =>   x_return_status,
			   x_msg_count           =>   x_msg_count,
			   x_msg_data            =>   x_msg_data,
                           p_recurrence_date     =>   l_recurrence_date);

         IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         FOR i in 1..lx_selv_tbl.COUNT
	 LOOP

	     If  trunc(lx_selv_tbl(i).stream_element_date) > trunc(nvl(p_billing_date, (l_hdr.start_date-1)))Then

	       If ( x_next_due_date IS NULL ) Then

		 x_next_due_date := lx_selv_tbl(i).stream_element_date;
		 if ( l_varint_sll_Rec.advance_arrears = 'ADVANCE' ) Then
		     x_next_period_start_date := lx_selv_tbl(i).stream_element_date;
		     If ( i < lx_selv_tbl.COUNT ) Then
                         x_next_period_end_date := lx_selv_tbl(i+1).stream_element_date - 1;
                         IF TO_CHAR(x_next_period_end_date, 'DD') = '31' OR
                            (TO_CHAR(x_next_period_end_date, 'MON') = 'FEB' AND
			     TO_CHAR(x_next_period_end_date, 'DD') = '29') THEN
                             x_next_period_end_date := x_next_period_end_date  - 1;
                         END IF;
                         return;
		     End If;
		 Else
                     x_next_period_end_date := lx_selv_tbl(i).stream_element_date;
		     If ( i > 1 ) Then
                         x_next_period_start_date := lx_selv_tbl(i-1).stream_element_date + 1;
		     Else
                         x_next_period_start_date := l_hdr.start_date;
		     End If;
                     IF TO_CHAR(x_next_period_start_date, 'DD') = '31' OR
                        (TO_CHAR(x_next_period_start_date, 'MON') = 'FEB' AND
		         TO_CHAR(x_next_period_start_date, 'DD') = '29') THEN
                         x_next_period_start_date := x_next_period_start_date  + 1;
                     END IF;
                     return;
		 End If;

	      Else
                 x_next_period_end_date := lx_selv_tbl(i).stream_element_date - 1;
                 IF TO_CHAR(x_next_period_end_date, 'DD') = '31' OR
                    (TO_CHAR(x_next_period_end_date, 'MON') = 'FEB' AND
		     TO_CHAR(x_next_period_end_date, 'DD') = '29') THEN
                     x_next_period_end_date := x_next_period_end_date  - 1;
                 END IF;
                 return;
	      ENd If;

	     End If;

	 END LOOP;

       END LOOP;

       if(x_next_period_end_date IS NULL) Then
           x_next_period_end_date := l_hdr.end_date;
       End If;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    print( l_api_name, 'end' );

    Exception

	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  end get_next_billing_date;


/** gboomina created GEN_CASH_FLOWS_FOR_IA API for Bug 6763287
------------------------------------------------------------------
      PROCEDURE GEN_CASH_FLOWS_FOR_IA
------------------------------------------------------------------
Description: This procedure is used to generate streams for Fees defined in
             Investor Agreement
**/

PROCEDURE gen_cash_flows_for_IA( p_api_version       IN NUMBER
                               , p_init_msg_list     IN VARCHAR2
                               , p_khr_id            IN NUMBER
                               , x_return_status     OUT NOCOPY VARCHAR2
                               , x_msg_count         OUT NOCOPY NUMBER
                               , x_msg_data          OUT NOCOPY VARCHAR2
                               )
  IS
    CURSOR c_inflows IS
      SELECT rgp.cle_id cle_id,
             TO_NUMBER(rul1.object1_id1) sty_id,
             FND_DATE.canonical_to_date(rul2.rule_information2) start_date,
             TO_NUMBER(rul2.rule_information3) periods,
             rul2.object1_id1 frequency,
             rul2.rule_information5 structure,
             DECODE(rul2.rule_information10, 'Y', 'ARREARS', 'ADVANCE') advance_arrears,
             FND_NUMBER.canonical_to_number(rul2.rule_information6) amount,
             TO_NUMBER(rul2.rule_information7) stub_days,
             TO_NUMBER(rul2.rule_information8) stub_amount,
             lse.lty_code lty_code,
             kle.capital_amount capital_amount,
             kle.residual_value residual_value,
             kle.fee_type fee_type
      FROM   okc_rule_groups_b rgp,
             okc_rules_b rul1,
             okc_rules_b rul2,
             okc_k_lines_b cle,
             okl_k_lines kle,
             okc_line_styles_b lse
      WHERE
             rul2.dnz_chr_id = p_khr_id
        AND  rul2.rule_information_category = 'LASLL'
        AND  rul1.rule_information_category = 'LASLH'
        AND  rul1.jtot_object1_code = 'OKL_STRMTYP'
        AND  rul2.rgp_id = rgp.id
        AND  TO_NUMBER(rul2.object2_id1) = rul1.id
        AND  rgp.cle_id = cle.id
        AND  cle.id = kle.id
        AND  cle.lse_id = lse.id
        ORDER BY cle_id, sty_id, start_date;

    l_inflow c_inflows%rowtype;

    CURSOR c_hdr IS
      SELECT chr.currency_code
      FROM   okc_k_headers_b chr
      WHERE  chr.id = p_khr_id;

    l_curreny_code okc_k_headers_all_b.currency_code%type;

    l_recurrence_date    DATE := NULL;
    l_old_cle_id         NUMBER;
    l_old_sty_id         NUMBER;
    l_purpose_code           VARCHAR2(30);

    l_pt_tbl                 okl_streams_pub.selv_tbl_type;
    l_pt_pro_fee_tbl         okl_streams_pub.selv_tbl_type;

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    l_stmv_tbl              Okl_Streams_Pub.stmv_tbl_type;
    lx_stmv_tbl              Okl_Streams_Pub.stmv_tbl_type;

    l_full_selv_tbl         Okl_Streams_Pub.selv_tbl_type;
    lx_full_selv_tbl         Okl_Streams_Pub.selv_tbl_type;

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'gen_cash_flows_for_IA';

  BEGIN

    -- Generate streams for the payments
    FOR l_inflow IN c_inflows LOOP
      IF l_inflow.start_date IS NULL THEN
        OKL_API.SET_MESSAGE ( p_app_name     => G_APP_NAME
                            , p_msg_name     => 'OKL_NO_SLL_SDATE');
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      IF((l_inflow.periods IS NULL) AND (l_inflow.stub_days IS NOT NULL)) THEN
        --Set the recurrence date to null for stub payment
        l_recurrence_date := NULL;
      ELSIF(l_recurrence_date IS NULL
         OR l_old_cle_id <> l_inflow.cle_id
         OR l_old_sty_id <> l_inflow.sty_id) THEN
        --Set the recurrence date as periodic payment level start date
        l_recurrence_date := l_inflow.start_date;
      END IF;
      l_old_cle_id := l_inflow.cle_id;
      l_old_sty_id := l_inflow.sty_id;

      OPEN c_hdr;
      FETCH c_hdr INTO l_curreny_code;
      CLOSE c_hdr;

      get_stream_elements( p_start_date          =>   l_inflow.start_date,
                           p_periods             =>   l_inflow.periods,
                           p_frequency           =>   l_inflow.frequency,
                           p_structure           =>   l_inflow.structure,
                           p_advance_or_arrears  =>   l_inflow.advance_arrears,
                           p_amount              =>   l_inflow.amount,
                           p_stub_days           =>   l_inflow.stub_days,
                           p_stub_amount         =>   l_inflow.stub_amount,
                           p_currency_code       =>   l_curreny_code,
                           p_khr_id              =>   p_khr_id,
                           p_kle_id              =>   l_inflow.cle_id,
                           p_purpose_code        =>   l_purpose_code,
                           x_selv_tbl            =>   l_selv_tbl,
                           x_pt_tbl              =>   l_pt_tbl,
                           x_pt_pro_fee_tbl      =>   l_pt_pro_fee_tbl,
                           x_return_status       =>   x_return_status,
                           x_msg_count           =>   x_msg_count,
                           x_msg_data            =>   x_msg_data,
                           p_recurrence_date     =>   l_recurrence_date);

      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      get_stream_header(p_khr_id         =>   p_khr_id,
                        p_kle_id         =>   l_inflow.cle_id,
                        p_sty_id         =>   l_inflow.sty_id,
                        p_purpose_code   =>   l_purpose_code,
                        x_stmv_rec       =>   l_stmv_rec,
                        x_return_status  =>   x_return_status);

      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      x_return_status := Okl_Streams_Util.round_streams_amount_esg(
                          p_api_version   => g_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_chr_id        => p_khr_id,
                          p_selv_tbl      => l_selv_tbl,
                          x_selv_tbl      => lx_selv_tbl,
                          p_org_id        => G_ORG_ID,
                          p_precision     => G_PRECISION,
                          p_currency_code => G_CURRENCY_CODE,
                          p_rounding_rule => G_ROUNDING_RULE,
                          p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_selv_tbl.DELETE;
      l_selv_tbl := lx_selv_tbl;

      --Accumulate Stream Header
      OKL_STREAMS_UTIL.accumulate_strm_headers( p_stmv_rec       => l_stmv_rec,
                                                x_full_stmv_tbl  => l_stmv_tbl,
                                                x_return_status  => x_return_status );
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      --Accumulate Stream Elements
      OKL_STREAMS_UTIL.accumulate_strm_elements( p_stm_index_no  =>  l_stmv_tbl.LAST,
                                                 p_selv_tbl       => l_selv_tbl,
                                                 x_full_selv_tbl  => l_full_selv_tbl,
                                                 x_return_status  => x_return_status );
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_stmv_rec := NULL;
      l_selv_tbl.delete;
      lx_selv_tbl.delete;

    END LOOP;

    --Create all the accumulated Streams at one shot ..
    Okl_Streams_Pub.create_streams_perf( p_api_version,
                                         p_init_msg_list,
                                         x_return_status,
                                         x_msg_count,
                                         x_msg_data,
                                         l_stmv_tbl,
                                         l_full_selv_tbl,
                                         lx_stmv_tbl,
                                         lx_full_selv_tbl);
    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
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
  END gen_cash_flows_for_IA;


  /** gboomina created GEN_INCOME_ACCRUAL_FOR_IA API for Bug 6763287
  ------------------------------------------------------------------
        PROCEDURE GEN_INCOME_ACCRUAL_FOR_IA
  ------------------------------------------------------------------
  Description: This procedure is used to generate income accrual streams
                for Fees defined in Investor Agreement
  **/

  PROCEDURE gen_income_accruals_for_IA( p_api_version  IN NUMBER
                               , p_init_msg_list  IN VARCHAR2
                               , p_khr_id         IN NUMBER
                               , x_return_status  OUT NOCOPY VARCHAR2
                               , x_msg_count      OUT NOCOPY NUMBER
                               , x_msg_data       OUT NOCOPY VARCHAR2
                               )
    IS

    CURSOR c_inflows IS
      SELECT rgp.cle_id cle_id,
             TO_NUMBER(rul1.object1_id1) sty_id,
	            sty.stream_type_purpose,
             FND_DATE.canonical_to_date(rul2.rule_information2) start_date,
             TO_NUMBER(rul2.rule_information3) periods,
             rul2.object1_id1 frequency,
             rul2.rule_information5 structure,
             DECODE(rul2.rule_information10, 'Y', 'ARREARS', 'ADVANCE') advance_arrears,
             FND_NUMBER.canonical_to_number(rul2.rule_information6) amount,
             TO_NUMBER(rul2.rule_information7) stub_days,
             TO_NUMBER(rul2.rule_information8) stub_amount,
             lse.lty_code lty_code,
             kle.capital_amount capital_amount,
             kle.residual_value residual_value,
       	     kle.fee_type fee_type
      FROM   okc_rule_groups_b rgp,
             okc_rules_b rul1,
             okc_rules_b rul2,
             okc_k_lines_b cle,
             okl_k_lines kle,
             okc_line_styles_b lse,
	            okl_strm_type_b sty
      WHERE
             rul2.dnz_chr_id = p_khr_id
        AND  rul2.rule_information_category = 'LASLL'
        AND  rul2.rgp_id = rgp.id
        AND  TO_NUMBER(rul2.object2_id1) = rul1.id
        AND  rgp.cle_id = cle.id
        AND  cle.id = kle.id
        AND  cle.lse_id = lse.id
       	AND  sty.id = rul1.object1_id1;

      l_inflow c_inflows%rowtype;

      CURSOR c_hdr IS
        SELECT to_char(pdt.id)  pid,
               chr.currency_code currency_code,
               khr.multi_gaap_yn multi_gaap_yn -- R12.1.2
        FROM okc_k_headers_v chr,
             okl_k_headers khr,
             okl_products_v pdt
        WHERE khr.id = chr.id
          AND chr.id = p_khr_id
          AND khr.pdt_id = pdt.id(+);

      -- racheruv.. R12.1.2: start
      l_multi_gaap_yn      okl_k_headers.multi_gaap_yn%TYPE;

      cursor rep_pdt_csr(p_pdt_id number) is
      select reporting_pdt_id
        from okl_products
       where id = p_pdt_id;

      l_rep_pdt_id        okl_products.id%TYPE;
      TYPE t_pdt_tbl is table of number index by binary_integer;
      l_pdt_tbl           t_pdt_tbl;
      l_rep_flag          t_pdt_tbl;
      -- R12.1.2 end.

      l_sty_purpose       okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE;
      l_sty_id            okl_strm_type_b.ID%TYPE;
      l_sty_name          OKL_STRM_TYPE_v.name%TYPE;
      l_mapped_sty_name   OKL_STRM_TYPE_v.name%TYPE;
      l_pdt_id            okl_products.id%type;
      l_currency_code     okc_k_headers_all_b.currency_code%type;
      l_purpose_code      VARCHAR2(30) := '-99';

      l_selv_tbl          okl_streams_pub.selv_tbl_type;
      lx_selv_tbl         okl_streams_pub.selv_tbl_type;
      l_full_selv_tbl     okl_streams_pub.selv_tbl_type;
      lx_full_selv_tbl    okl_streams_pub.selv_tbl_type;

      l_stmv_rec          okl_streams_pub.stmv_rec_type;
      l_stmv_tbl          okl_Streams_Pub.stmv_tbl_type;
      lx_stmv_tbl         okl_Streams_Pub.stmv_tbl_type;

      l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'gen_income_accruals_for_IA';

    BEGIN

        -- R12.1.2 .. racheruv.. get the reporting product
        OPEN c_hdr;
        FETCH c_hdr INTO l_pdt_id, l_currency_code, l_multi_gaap_yn;
        CLOSE c_hdr;
        l_pdt_tbl(1) := l_pdt_id;
        l_rep_flag(1) := 0;

        if nvl(l_multi_gaap_yn, 'N') = 'Y' then
          open rep_pdt_csr(l_pdt_id);
          fetch rep_pdt_csr into l_rep_pdt_id;
          close rep_pdt_csr;
          if l_rep_pdt_id is not null then
            l_pdt_tbl(2):= l_rep_pdt_id;
            l_rep_flag(2) := 1;
          end if;
        end if;

      for i in l_pdt_tbl.first..l_pdt_tbl.last loop
      -- R12.1.2 .. racheruv .. end

      FOR l_inflow IN c_inflows LOOP

        l_sty_purpose := l_inflow.stream_type_purpose;

        get_sty_details (p_sty_id        => l_inflow.sty_id,
                         x_sty_id        => l_sty_id,
                         x_sty_name      => l_sty_name,
                         x_return_status => x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        /* R12.1.2 .. racheruv ..commented out the below.
        OPEN c_hdr;
        FETCH c_hdr INTO l_pdt_id, l_currency_code;
        CLOSE c_hdr;
        */

        OKL_ISG_UTILS_PVT.get_dependent_stream_type(
                p_khr_id                => p_khr_id,
                p_pdt_id                => l_pdt_tbl(i), -- R12.1.2
                p_dependent_sty_purpose => 'ACCRUED_FEE_INCOME',
                x_return_status         => x_return_status,
                x_dependent_sty_id      => l_sty_id,
                x_dependent_sty_name    => l_mapped_sty_name);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF l_mapped_sty_name IS NOT NULL THEN
          get_accrual_elements (
            p_start_date          =>   l_inflow.start_date,
            p_periods             =>   l_inflow.periods,
            p_frequency           =>   l_inflow.frequency,
            p_structure           =>   l_inflow.structure,
            p_advance_or_arrears  =>   l_inflow.advance_arrears,
            p_amount              =>   l_inflow.amount,
            p_stub_days           =>   l_inflow.stub_days,
            p_stub_amount         =>   l_inflow.stub_amount,
            p_currency_code       =>   l_currency_code,
            x_selv_tbl            =>   l_selv_tbl,
            x_return_status       =>   x_return_status);

          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

        get_sty_details (p_sty_name      => l_mapped_sty_name,
                         x_sty_id        => l_sty_id,
                         x_sty_name      => l_sty_name,
                         x_return_status => x_return_status);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF (l_selv_tbl.COUNT > 0 ) THEN

          -- R12.1.2 ..start
          if l_multi_gaap_yn = 'Y' and l_rep_flag(i) = 1 then
            l_purpose_code := 'REPORT';
          end if;
          -- R12.1.2 .. end

          get_stream_header(p_khr_id         =>   p_khr_id,
                            p_kle_id         =>   l_inflow.cle_id,
                            p_sty_id         =>   l_sty_id,
                            p_purpose_code   =>   l_purpose_code,
                            x_stmv_rec       =>   l_stmv_rec,
                            x_return_status  =>   x_return_status);

          IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          x_return_status := Okl_Streams_Util.round_streams_amount_esg(
                              p_api_version   => g_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_chr_id        => p_khr_id,
                              p_selv_tbl      => l_selv_tbl,
                              x_selv_tbl      => lx_selv_tbl,
                              p_org_id        => G_ORG_ID,
                              p_precision     => G_PRECISION,
                              p_currency_code => G_CURRENCY_CODE,
                              p_rounding_rule => G_ROUNDING_RULE,
                              p_apply_rnd_diff=> G_DIFF_LOOKUP_CODE);

          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          l_selv_tbl.DELETE;
          l_selv_tbl := lx_selv_tbl;

          --Accumulate Stream Header
          OKL_STREAMS_UTIL.accumulate_strm_headers(
            p_stmv_rec       => l_stmv_rec,
            x_full_stmv_tbl  => l_stmv_tbl,
            x_return_status  => x_return_status );
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          --Accumulate Stream Elements
          OKL_STREAMS_UTIL.accumulate_strm_elements(
            p_stm_index_no  =>  l_stmv_tbl.LAST,
            p_selv_tbl       => l_selv_tbl,
            x_full_selv_tbl  => l_full_selv_tbl,
            x_return_status  => x_return_status );
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF;

        l_mapped_sty_name := NULL;
        l_sty_name        :=  NULL;
        l_sty_id          :=  NULL;

        l_stmv_rec := NULL;
        l_selv_tbl.delete;

        lx_selv_tbl.delete;

      END LOOP;

      --Create all the accumulated Streams at one shot ..
      IF l_stmv_tbl.COUNT > 0 AND
         l_full_selv_tbl.COUNT > 0
      THEN
        Okl_Streams_Pub.create_streams_perf(
                                 p_api_version,
                                 p_init_msg_list,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data,
                                 l_stmv_tbl,
                                 l_full_selv_tbl,
                                 lx_stmv_tbl,
                                 lx_full_selv_tbl);
        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      l_stmv_tbl.delete; -- R12.1.2
      l_full_selv_tbl.delete; -- R12.1.2

    end loop; -- l_pdt_tbl(i) R12.1.2

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

  END gen_income_accruals_for_IA;


  /** gboomina created GEN_INCOME_ACCRUAL_FOR_IA API for Bug 6763287
  ------------------------------------------------------------------
        PROCEDURE GEN_INCOME_ACCRUAL_FOR_IA
  ------------------------------------------------------------------
  Description: This procedure is used to generate income accrual streams
                for Fees defined in Investor Agreement
  **/

  PROCEDURE adjust_IA_streams( p_api_version  IN NUMBER
                               , p_init_msg_list  IN VARCHAR2
                               , p_khr_id         IN NUMBER
                               , x_return_status  OUT NOCOPY VARCHAR2
                               , x_msg_count      OUT NOCOPY NUMBER
                               , x_msg_data       OUT NOCOPY VARCHAR2
                               )
    IS

      l_strm_id_tbl okl_streams_util.NumberTabTyp;
     	l_say_code_tbl okl_streams_util.Var10TabTyp;
    	 l_active_yn_tbl okl_streams_util.Var10TabTyp;
     	l_date_history_tbl okl_streams_util.DateTabTyp;
     	l_date_curr_tbl okl_streams_util.DateTabTyp;

      CURSOR strms_csr  IS
        SELECT strm.id
             , strm.say_code
             , purpose_code -- R12.1.2
        FROM okl_streams strm
        WHERE khr_id = p_khr_id;
      l_strms_rec strms_csr%rowtype;

      i NUMBER;
      l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'adjust_IA_streams';
    BEGIN

      i := 0;
      FOR l_strms_rec IN strms_csr
      LOOP
        -- Make WORK streams CURR and CURR streams WORK
        IF l_strms_rec.say_code = 'WORK' THEN
          i := i+1;
          l_strm_id_tbl(i):= l_strms_rec.id;
          l_say_code_tbl(i) := 'CURR';
          l_date_curr_tbl(i) := sysdate;
          l_date_history_tbl(i) := NULL;
          l_active_yn_tbl(i) := 'Y';
          -- R12.1.2 .. racheruv .. change the active_yn for rpt pdt
          if l_strms_rec.purpose_code = 'REPORT' then
            l_active_yn_tbl(i) := 'N';
          end if;
          -- R12.1.2 end .. racheruv.
        ELSIF l_strms_rec.say_code = 'CURR' THEN
          i := i+1;
          l_strm_id_tbl(i):= l_strms_rec.id;
          l_say_code_tbl(i) := 'HIST';
          l_date_curr_tbl(i) := sysdate;
          l_date_history_tbl(i) := NULL;
          l_active_yn_tbl(i) := 'N';
        END IF;
      END LOOP;

     -- Update all streams at once...
     FORALL i IN l_strm_id_tbl.FIRST..l_strm_id_tbl.LAST
       UPDATE OKL_STREAMS
       SET 	say_code = l_say_code_tbl(i),
       active_yn = l_active_yn_tbl(i),
       date_history = l_date_history_tbl(i),
       date_current = l_date_curr_tbl(i)
       WHERE 	ID = l_strm_id_tbl(i);

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

  END adjust_IA_streams;


  /** gboomina created GENERATE_STREAMS_FOR_IA API for Bug 6763287
  ------------------------------------------------------------------
        PROCEDURE GENERATE_STREAMS_FOR_IA
  ------------------------------------------------------------------
  Description: This procedure is used to generate streams
                for Fees defined in Investor Agreement
  **/

  PROCEDURE generate_streams_for_IA( p_api_version    IN NUMBER
                                   , p_init_msg_list  IN VARCHAR2
                                   , p_khr_id         IN NUMBER
                                   , x_return_status  OUT NOCOPY VARCHAR2
                                   , x_msg_count      OUT NOCOPY NUMBER
                                   , x_msg_data       OUT NOCOPY VARCHAR2
                                   )
    IS
      l_api_name         CONSTANT VARCHAR2(61) := 'generate_streams_for_IA';

      CURSOR c_hdr IS
      SELECT chr.currency_code
      FROM okc_k_headers_b chr
      WHERE chr.id = p_khr_id;

      l_currency_code okc_k_headers_all_b.currency_code%type;
      l_purpose_code VARCHAR2(10) := '-99';
      l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

      -- R12.1.2 .. start
      CURSOR get_multi_gaap_yn(p_khr_id number) IS
      select multi_gaap_yn
        from okl_k_headers
       where id = p_khr_id;

      l_multi_gaap_yn   okl_k_headers.multi_gaap_yn%TYPE;
      -- R12.1.2 .. end

    BEGIN
      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      l_return_status := OKL_API.START_ACTIVITY(
                                  p_api_name      => l_api_name,
                                  p_pkg_name      => g_pkg_name,
                                  p_init_msg_list => p_init_msg_list,
                                  l_api_version   => p_api_version,
                                  p_api_version   => p_api_version,
                                  p_api_type      => G_API_TYPE,
                                  x_return_status => l_return_status);

      -- check if activity started successfully
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ElSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      ---------------------------------------------
      -- STEP 1: Generate Income Streams
      ---------------------------------------------
      gen_cash_flows_for_IA( p_api_version   => p_api_version
                           , p_init_msg_list => p_init_msg_list
                           , p_khr_id        => p_khr_id
                           , x_return_status => l_return_status
                           , x_msg_count     => x_msg_count
                           , x_msg_data      => x_msg_data);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ElSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      ---------------------------------------------
      -- STEP 2: Generate Income Accrual Streams
      ---------------------------------------------
      gen_income_accruals_for_IA( p_api_version   => p_api_version
                                , p_init_msg_list => p_init_msg_list
                                , p_khr_id        => p_khr_id
                                , x_return_status => l_return_status
                                , x_msg_count     => x_msg_count
                                , x_msg_data      => x_msg_data);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ElSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      ---------------------------------------------
      -- STEP 3: Generate Expense Accrual Streams
      ---------------------------------------------
      OPEN c_hdr;
      FETCH c_hdr INTO l_currency_code;
      CLOSE c_hdr;

      okl_expense_streams_pvt.generate_rec_exp(
                                 p_khr_id        => p_khr_id
                               , p_deal_type     => NULL -- NULL for Investor
                               , p_purpose_code  => l_purpose_code
                               , p_currency_code => l_currency_code
                               , x_return_status => l_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ElSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- R12.1.2 .. racheruv .. generate expense for rpt.
      open get_multi_gaap_yn(p_khr_id);
      fetch get_multi_gaap_yn into l_multi_gaap_yn;
      close get_multi_gaap_yn;

      if l_multi_gaap_yn = 'Y' then
         l_purpose_code := 'REPORT';

         okl_expense_streams_pvt.generate_rec_exp(
                                 p_khr_id        => p_khr_id
                               , p_deal_type     => NULL -- NULL for Investor
                               , p_purpose_code  => l_purpose_code
                               , p_currency_code => l_currency_code
                               , x_return_status => l_return_status);

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ElSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

      end if;
      -- R12.1.2 .. racheruv .. generate expense for rpt.. end

      -- one streams header per the payment line (LASLL) will be
      -- created by the previous API's. So we need to consolidate
      -- those stream headers into one stream header per fee line
      ---------------------------------------------------------------
      -- STEP 4: Consolidate Income Fee streams into one stream header
      --         per fee line
      ---------------------------------------------------------------
      l_purpose_code := '-99';
      consolidate_line_streams( p_khr_id         => p_khr_id
                              , p_purpose_code   => l_purpose_code
                              , x_return_status  => l_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ElSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- R12.1.2 .. racheruv ..
      if l_multi_gaap_yn = 'Y' then
         l_purpose_code := 'REPORT';

         consolidate_line_streams( p_khr_id         => p_khr_id
                                 , p_purpose_code   => l_purpose_code
                                 , x_return_status  => l_return_status);

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ElSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
     end if;
      -- R12.1.2 .. racheruv ..

      ------------------------------------------------------------------
      -- STEP 5: Consolidate Income Accrual Fee streams into one stream
      --         header per fee line
      ------------------------------------------------------------------
      l_purpose_code := '-99';
      consolidate_acc_streams( p_khr_id         => p_khr_id
                             , p_purpose_code   => l_purpose_code
                             , x_return_status  => l_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ElSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- R12.1.2 .. racheruv ..
      if l_multi_gaap_yn = 'Y' then
         l_purpose_code := 'REPORT';

         consolidate_acc_streams( p_khr_id         => p_khr_id
                                , p_purpose_code   => l_purpose_code
                                , x_return_status  => l_return_status);

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ElSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
     end if;
      -- R12.1.2 .. racheruv ..

      ---------------------------------------------
      -- STEP 6: Adjust Streams
      ---------------------------------------------
      -- Move the Working status streams to Current
      -- and the existing Current status streams to History
      adjust_IA_streams( p_api_version   => p_api_version
                       , p_init_msg_list => p_init_msg_list
                       , p_khr_id        => p_khr_id
                       , x_return_status => l_return_status
                       , x_msg_count     => x_msg_count
                       , x_msg_data      => x_msg_data);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ElSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        l_return_status := G_RET_STS_ERROR;
      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        l_return_status := G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_DB_ERROR,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_api_name,
                             p_token2       => G_SQLCODE_TOKEN,
                             p_token2_value => sqlcode,
                             p_token3       => G_SQLERRM_TOKEN,
                             p_token3_value => sqlerrm);
        l_return_status := G_RET_STS_UNEXP_ERROR;

  END generate_streams_for_IA;

END OKL_STREAM_GENERATOR_PVT;

/
