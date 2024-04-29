--------------------------------------------------------
--  DDL for Package Body OKL_GENERATE_ACCRUALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_GENERATE_ACCRUALS_PVT" AS
/* $Header: OKLRACRB.pls 120.66.12010000.12 2010/03/01 19:15:03 sachandr ship $ */

  --Added by kthiruva for Logging Purposes
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;

  -- Bug 4884618
  l_sty_select_basis       VARCHAR2(2000);
  -- Bug 4884618

  -- MGAAP start 7263041
  G_TRY_ID                         OKL_TRX_TYPES_V.id%TYPE;
  G_PERIOD_NAME_REP                VARCHAR2(2000);
  G_PERIOD_START_DATE_REP          DATE;
  G_PERIOD_END_DATE_REP            DATE;
  G_SOB_ID_REP                     OKL_SYS_ACCT_OPTS.set_of_books_id%TYPE;
  G_SOB_NAME_REP                   VARCHAR2(2000);
  G_ORG_ID                         NUMBER;
  G_ORG_NAME                       VARCHAR2(2000);
  G_ACCRUAL_REVERSAL_DAYS          OKL_SYS_ACCT_OPTS.accrual_reversal_days%TYPE;
  G_FUNC_CURRENCY_CODE_REP         OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
  G_ACCRUAL_DATE                   DATE;

  TYPE trx_rec_type IS RECORD (
    old_trx_number okl_trx_contracts_all.trx_number%TYPE := OKL_API.G_MISS_CHAR,
    new_trx_number okl_trx_contracts_all.trx_number%TYPE := OKL_API.G_MISS_CHAR,
    ID             okl_trx_contracts_all.ID%TYPE := OKL_API.G_MISS_NUM
  );

  TYPE trx_tbl_type IS TABLE OF trx_rec_type INDEX BY BINARY_INTEGER;
  G_trx_number_tbl trx_tbl_type;
  G_trx_number_tbl_cnt number; -- MGAAP

  -- MGAAP end 7263041

  -- Cursor to select the number of days for a reverse transaction
  CURSOR sty_select_basis_csr IS
  SELECT validate_khr_start_date
  FROM OKL_SYS_ACCT_OPTS;

--Added by dpsingh for SLA Uptake (Bug 5707866)
  -- Cursor to select accrual reversal date for an accrual transaction
  CURSOR get_accrual_reversal_date(p_ledger_id NUMBER,p_accrual_date Date) IS
  SELECT   end_date +1 accrual_reversal_date
  FROM gl_period_statuses
  WHERE application_id = 540
  AND set_of_books_id =p_ledger_id
  AND p_accrual_date BETWEEN start_date AND end_date;

  -- Process accrual rec type
  TYPE process_accrual_rec_type IS RECORD (
    contract_id               OKL_K_HEADERS_FULL_V.ID%TYPE,
    contract_number           OKL_K_HEADERS_FULL_V.CONTRACT_NUMBER%TYPE,
    sts_code                  OKL_K_HEADERS_FULL_V.STS_CODE%TYPE,
    product_id                OKL_K_HEADERS_FULL_V.PDT_ID%TYPE,
    accrual_status            OKL_TRX_CONTRACTS.ACCRUAL_STATUS_YN%TYPE,
    override_status           OKL_TRX_CONTRACTS.UPDATE_STATUS_YN%TYPE,
    start_date                OKL_K_HEADERS_FULL_V.CONTRACT_NUMBER%TYPE,
    deal_type                 OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE,
    khr_currency_code         OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE,
    currency_conv_type        OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_TYPE%TYPE,
    currency_conv_date        OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_DATE%TYPE,
    currency_conv_rate        OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_RATE%TYPE,
    func_currency_code        OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE,
    try_id                    OKL_TRX_TYPES_V.ID%TYPE,
    reverse_date_to           DATE,
    batch_name                VARCHAR2(2000),
    sob_id                    OKL_TRX_CONTRACTS.SET_OF_BOOKS_ID%TYPE,
    accrual_date              DATE,
    period_end_date           DATE,
    period_start_date	      DATE,
    source_trx_id             OKL_TRX_CONTRACTS.SOURCE_TRX_ID%TYPE,
    source_trx_type           OKL_TRX_CONTRACTS.SOURCE_TRX_TYPE%TYPE,
    submission_mode           VARCHAR2(2000),
    rev_rec_method            OKL_PRODUCT_PARAMETERS_V.REVENUE_RECOGNITION_METHOD%TYPE);

    --Added by kthiruva on 02-Mar-2006 for logging purposes
    --Start of Changes
    PROCEDURE WRITE_TO_LOG(p_message	IN	VARCHAR2)
    IS
    BEGIN

      IF (L_DEBUG_ENABLED='Y' and fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.string(fnd_log.level_statement,
                        'okl_generate_accruals',
                        p_message );

      END IF;

      IF L_DEBUG_ENABLED = 'Y' then
        fnd_file.put_line (fnd_file.log,p_message);
        okl_debug_pub.logmessage(p_message);
      END IF;

    END WRITE_TO_LOG;

-- Function which calculates the receivable value for a contract
   FUNCTION CALCULATE_CNTRCT_REC(p_ctr_id IN NUMBER) RETURN NUMBER IS

     l_sysdate            DATE := SYSDATE;
     l_rent_sty_id        NUMBER;
     l_receivable_balance NUMBER := 0;
     l_sty_name           VARCHAR2(2000) := 'RENT';
     l_return_status      VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

     -- SGIYER
     -- Commenting Cursor below as not needed. user Defined Streams Project.
     --CURSOR get_sty_id_csr IS
     --SELECT id FROM OKL_STRM_TYPE_TL
     --WHERE name = l_sty_name
	 --AND language = 'US';

     CURSOR get_unb_rec_csr(p_sty_id NUMBER) IS
     SELECT NVL(SUM(ste.amount),0)
     FROM OKL_STREAMS stm,
          OKL_STRM_ELEMENTS ste
     WHERE stm.khr_id = p_ctr_id
     AND stm.sty_id = p_sty_id
     AND stm.active_yn = 'Y'
     AND ste.stm_id = stm.id
     AND TRUNC(ste.stream_element_date) > TRUNC(l_sysdate)
     GROUP BY stm.sty_id;

   BEGIN
    -- Get the stream type id for the rent stream
    -- Commenting below as not needed. User Defined Streams Project.
    --OPEN get_sty_id_csr;
    --FETCH get_sty_id_csr INTO l_rent_sty_id;
    --  IF get_sty_id_csr%NOTFOUND THEN
	--    RAISE NO_DATA_FOUND;
	--  END IF;
    --CLOSE get_sty_id_csr;
    OKL_STREAMS_UTIL.get_primary_stream_type(
      p_khr_id  		   	=> p_ctr_id,
      p_primary_sty_purpose => 'RENT',
      x_return_status		=> l_return_status,
      x_primary_sty_id 		=> l_rent_sty_id);

    IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
      RAISE NO_DATA_FOUND;
    END IF;

    -- Open the cursor to get the receivable balance
    OPEN get_unb_rec_csr(l_rent_sty_id);
	FETCH get_unb_rec_csr INTO l_receivable_balance;
    CLOSE get_unb_rec_csr;

    IF l_receivable_balance IS NULL THEN
      RAISE NO_DATA_FOUND;
	END IF;

    RETURN l_receivable_balance;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       --IF get_sty_id_csr%ISOPEN THEN
	   --  CLOSE get_sty_id_csr;
	   --END IF;
	   RETURN NULL;
     WHEN OTHERS THEN
	   IF get_unb_rec_csr%ISOPEN THEN
	     CLOSE get_unb_rec_csr;
	   END IF;
	   RETURN NULL;
   END CALCULATE_CNTRCT_REC;



-- Function which calculates values for the operand i.e. Limit Days or Bills Unpaid
  FUNCTION CALCULATE_OPERAND_VALUE(p_ctr_id IN OKL_K_HEADERS_FULL_V.ID%TYPE
                                  ,p_operand_code IN VARCHAR2) RETURN NUMBER IS

	l_sysdate				DATE := SYSDATE;
	l_return_value			NUMBER := 0;
	l_oldest_due_date       DATE;
	l_outstanding_invoices  NUMBER;

    -- Bug 4058948. Changing view from okl_bpd_leasing_payment_trx_v to okl_bpd_contract_invoices_v.
    -- Also adding new where condition to exclude invoices subject to cash receipt.
    CURSOR operand_values_csr IS
-- Bug 9394602
--    SELECT MIN(DUE_DATE) min_due_date, COUNT(*) total_os
--    FROM OKL_BPD_CONTRACT_INVOICES_V
--    WHERE contract_id = p_ctr_id
--    AND revenue_rec_basis <> 'CASH_RECEIPT'
--    AND status = 'OP';
    SELECT MIN(DUE_DATE) min_due_date, COUNT(*) total_os from (
        SELECT
              PS.DUE_DATE DUE_DATE
        FROM AR_PAYMENT_SCHEDULES_ALL PS,
             OKL_CNSLD_AR_STRMS_B ST          ,
             OKL_CNSLD_AR_LINES_B LN          ,
             OKL_CNSLD_AR_HDRS_B HD           ,
             OKL_STRM_TYPE_B SP               ,
             OKC_K_HEADERS_ALL_B CN
        WHERE PS.CLASS             IN ('INV', 'CM')
        AND ST.RECEIVABLES_INVOICE_ID = PS.CUSTOMER_TRX_ID
        AND LN.ID                     = ST.LLN_ID
        AND HD.ID                     = LN.CNR_ID
        AND SP.ID                     = ST.STY_ID
        AND CN.ID                     = ST.KHR_ID
        and st.khr_id = p_ctr_id
        and SP.ACCRUAL_YN <> 'CASH_RECEIPT'
        AND status = 'OP'
        UNION
        SELECT
             APS.DUE_DATE DUE_DATE
        FROM RA_CUSTOMER_TRX_LINES_ALL RACTRL,
             OKL_TXD_AR_LN_DTLS_B TXD              ,
             RA_CUSTOMER_TRX_ALL RACTRX            ,
             OKL_STRM_TYPE_B SM                    ,
             OKL_TXL_AR_INV_LNS_B TIL              ,
             AR_PAYMENT_SCHEDULES_ALL APS
        WHERE
  --to_char(TXD.ID )= RACTRL.interface_line_attribute14
            RACTRL.interface_line_attribute14 = (select to_char(TXD.ID)
                                                 from OKL_TXD_AR_LN_DTLS_B a
                                                 where a.id     = txd.ID)
  /*-- assume TXD ID MAP*/
        AND RACTRL.CUSTOMER_TRX_ID = RACTRX.CUSTOMER_TRX_ID
        AND SM.ID                  = TXD.STY_ID
        AND TXD.TIL_ID_DETAILS     = TIL.ID
        AND RACTRX.CUSTOMER_TRX_ID = APS.CUSTOMER_TRX_ID
        AND APS.CLASS              IN ('INV', 'CM')
        and txd.khr_Id = p_ctr_id
        and SM.ACCRUAL_YN <> 'CASH_RECEIPT'
        AND status = 'OP'
);
-- End bug 9394602
  BEGIN
    FOR x IN operand_values_csr
    LOOP
      l_oldest_due_date := x.min_due_date;
      l_outstanding_invoices := x.total_os;
    END LOOP;

	IF p_operand_code = 'LDYS' THEN
      l_return_value := NVL(TO_NUMBER(l_sysdate - l_oldest_due_date),0);

    ELSIF p_operand_code = 'BUNP' THEN
      l_return_value := NVL(l_outstanding_invoices,0);
    ELSE
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

	RETURN l_return_value;
  EXCEPTION

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_INVALID_OPERAND_CODE');

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
  END CALCULATE_OPERAND_VALUE;

  ---------------------------------------------------------------------------
  -- FUNCTION get_syndicate_flag
  ---------------------------------------------------------------------------
  FUNCTION GET_SYNDICATE_FLAG(
     p_contract_id	IN NUMBER,
     x_syndicate_flag	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    -- A complex query to find out if a contract has syndication
    CURSOR syndicate_flag_csr(p_contract_id NUMBER) IS
      SELECT 'Y'  FROM okc_k_headers_b chr
      WHERE id = p_contract_id
      AND EXISTS
          (
           SELECT 'x' FROM okc_k_items cim
           WHERE  cim.object1_id1 = to_char(chr.id)
           AND    EXISTS
                  (
                   SELECT 'x' FROM okc_k_lines_b cle, okc_line_styles_b lse
                   WHERE  cle.lse_id = lse.id
                   AND    lse.lty_code = 'SHARED'
                   AND    cle.id = cim.cle_id
                  )
           AND    EXISTS
                  (
                   SELECT 'x' FROM okc_k_headers_b chr2
                   WHERE  chr2.id = cim.dnz_chr_id
                   AND    chr2.scs_code = 'SYNDICATION'
                   AND    chr2.sts_code not in ('TERMINATED','ABANDONED')
                  )
          )
      AND chr.scs_code in ('LEASE','LOAN');

    l_syndicate_flag	VARCHAR2(1) := 'N';
    l_api_version       NUMBER;
    l_return_status     VARCHAR2(1) := Okl_API.G_RET_STS_SUCCESS;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);

  BEGIN

    OPEN  syndicate_flag_csr(p_contract_id);
    FETCH syndicate_flag_csr INTO l_syndicate_flag;
    CLOSE syndicate_flag_csr;

    x_syndicate_flag := l_syndicate_flag;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END GET_SYNDICATE_FLAG;

  ---------------------------------------------------------------------------
  -- FUNCTION get_factoring_flag
  ---------------------------------------------------------------------------
  FUNCTION GET_FACTORING_FLAG(
     p_contract_id	IN NUMBER,
     x_factoring_flag	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
	-- Cursor to check factoring
    CURSOR factoring_csr(p_ctr_id NUMBER) IS
    SELECT rule_information1
    FROM OKC_RULES_B r
    WHERE r.dnz_chr_id = p_ctr_id
	AND r.rule_information_category = 'LAFCTG';

    l_rule_information1 VARCHAR2(2000);
    l_return_status     VARCHAR2(1) := Okl_API.G_RET_STS_SUCCESS;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);

  BEGIN

    OPEN  factoring_csr(p_contract_id);
    FETCH factoring_csr INTO l_rule_information1;
    CLOSE factoring_csr;

    IF l_rule_information1 IS NOT NULL THEN
      x_factoring_flag := 'Y';
	ELSE
      x_factoring_flag := 'N';
    END IF;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END GET_FACTORING_FLAG;

  FUNCTION CHECK_DATE_ACCRUED_TILL(p_khr_id IN OKL_K_HEADERS_FULL_V.ID%TYPE
                                  ,p_date IN DATE) RETURN VARCHAR2 IS

    --dkagrawa changed cursor to use view OKL_PROD_QLTY_VAL_UV than okl_product_parameters_v
    CURSOR get_rev_rec_method_csr(p_chr_id NUMBER) IS
    SELECT pdt.quality_val revenue_recognition_method
    FROM OKL_PROD_QLTY_VAL_UV pdt,
         OKL_K_HEADERS_FULL_V khr
    WHERE khr.id = p_chr_id
    AND   khr.pdt_id = pdt.pdt_id
    AND   pdt.quality_name = 'REVENUE_RECOGNITION_METHOD'
    AND khr.scs_code = 'LEASE'
    UNION
    SELECT 'STREAMS' revenue_recognition_method
    FROM OKL_K_HEADERS_FULL_V khr
    WHERE khr.id = p_chr_id
    AND khr.scs_code = 'INVESTOR'
    ;

    CURSOR get_contract_number_csr(p_chr_id NUMBER) IS
    SELECT a.contract_number,
           nvl(b.multi_gaap_yn, 'N') multi_gaap_yn,
		   c.reporting_pdt_id -- MGAAP 7263041
    FROM OKC_K_HEADERS_B a, OKL_K_HEADERS B,
         OKL_PRODUCTS C
    WHERE A.id = p_chr_id
    AND   A.id = B.id
    AND   B.PDT_ID = C.ID;

    l_reporting_pdt_id OKL_PRODUCTS.REPORTING_PDT_ID%TYPE := null;
    l_multi_gaap_yn    OKL_K_HEADERS.MULTI_GAAP_YN%TYPE;

	-- bug 7577628
	cursor get_sec_rep_method IS
	select secondary_rep_method
	  from okl_sys_acct_opts;

    l_sec_rep_method    okl_sys_acct_opts.secondary_rep_method%TYPE := null;

    --Bug 4740605.Added TRUNC
    CURSOR check_streams_accrual_csr(p_chr_id NUMBER, p_accrue_till_date DATE,
                                     p_reporting_pdt_id NUMBER) IS -- MGAAP
    SELECT 'N'
    FROM OKC_K_HEADERS_B CHR
    WHERE id = p_chr_id
    AND EXISTS (
             SELECT 1
             FROM        OKL_STRM_TYPE_B          sty,
                         --OKL_STREAMS              stm,
                         OKL_STREAMS_REP_V        stm, -- MGAAP 7263041
                         OKL_STRM_ELEMENTS        ste,
                         OKL_PROD_STRM_TYPES      psty,
                         OKL_K_HEADERS            khr,
                         OKL_PRODUCTS              pdt
             WHERE khr.id = p_chr_id
			 AND stm.khr_id = khr.id
             AND stm.say_code = 'CURR'
             AND stm.active_yn = 'Y'
             --AND stm.purpose_code IS NULL  --MGAAP
             AND ( stm.purpose_code IS NULL OR stm.purpose_code = 'REPORT' )
             AND stm.sty_id = sty.id
             AND sty.id = psty.sty_id
             AND psty.accrual_yn = 'Y'
             AND psty.pdt_id = DECODE(p_reporting_pdt_id,
                                NULL, pdt.id, p_reporting_pdt_id) -- MGAAP
             AND pdt.id = khr.pdt_id
             AND stm.id = ste.stm_id
             AND TRUNC(ste.stream_element_date) <= TRUNC(p_accrue_till_date)
             AND ste.amount <> 0
             AND ste.accrued_yn IS NULL);

	CURSOR last_int_date_csr IS
	SELECT TRUNC(DATE_LAST_INTERIM_INTEREST_CAL)
	FROM OKL_K_HEADERS
	WHERE ID = p_khr_id;

	CURSOR khr_start_date_csr IS
	SELECT TRUNC(start_date)
	FROM OKC_K_HEADERS_B
	WHERE ID = p_khr_id;

    --Bug 5036337
    CURSOR check_actual_trx(p_khr_id NUMBER) IS
    SELECT TRUNC(MAX(trx.date_transaction_occurred)) last_accrual_date
    FROM OKL_TRX_CONTRACTS trx,
         OKL_TRX_TYPES_V try,
         OKL_TXL_CNTRCT_LNS txl,
         OKL_STRM_TYPE_V sty
    WHERE trx.khr_id = p_khr_id
    AND trx.try_id = try.id
    AND try.name = 'Accrual'
    --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
    AND trx.tsu_code = 'PROCESSED'
    AND trx.id = txl.tcn_id
    AND trx.representation_type = 'PRIMARY' -- MGAAP 7263041
    AND txl.sty_id = sty.id
    AND sty.stream_type_purpose = 'ACTUAL_INCOME_ACCRUAL';

    l_contract_number	  	OKL_K_HEADERS_FULL_V.contract_number%TYPE;
    l_rev_rec_method		OKL_PRODUCT_PARAMETERS_V.revenue_recognition_method%TYPE;
    l_accrual_status		VARCHAR2(1);
    x_result				VARCHAR2(1);
--    Bug 5036337.Commenting below as no longer needed.
--    l_formula_name           CONSTANT VARCHAR2(30) := 'CONTRACT_ACTUAL_INCOME_ACCRUAL';
    l_api_version            CONSTANT NUMBER       := 1.0;
    l_init_msg_list          VARCHAR2(20) DEFAULT Okl_Api.G_FALSE;
    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
--    l_formula_amount         NUMBER := 0;
--    l_ctxt_val_tbl           Okl_Account_Dist_Pub.ctxt_val_tbl_type;
    l_last_int_calc_date     DATE;
    l_next_int_calc_date     DATE;
    l_khr_start_date         DATE;
    l_period_start_date      DATE;
    l_period_end_date        DATE;
    l_last_accrual_date      DATE;

  BEGIN

	-- bug 7577628
	if l_sec_rep_method is null then
     open  get_sec_rep_method;
	 fetch get_sec_rep_method into l_sec_rep_method;
	 close get_sec_rep_method;
	end if;

    FOR i IN get_contract_number_csr(p_khr_id)
    LOOP
      l_contract_number := i.contract_number;
      l_reporting_pdt_id := i.reporting_pdt_id;
      l_multi_gaap_yn := i.multi_gaap_yn;
    END LOOP;

	-- bug 7577628
	if l_sec_rep_method <> 'AUTOMATED' then
       l_multi_gaap_yn := 'N';
	end if;

    IF l_contract_number IS NULL THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR j IN get_rev_rec_method_csr(p_khr_id)
    LOOP
      l_rev_rec_method := j.revenue_recognition_method;
    END LOOP;

    IF l_rev_rec_method IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'REVENUE_RECOGNITION_METHOD');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_rev_rec_method = 'STREAMS' THEN

      OPEN check_streams_accrual_csr(p_khr_id, p_date, null); -- MGAAP
      FETCH check_streams_accrual_csr INTO l_accrual_status;
      CLOSE check_streams_accrual_csr;

      IF l_accrual_status = 'N' THEN
        x_result := l_accrual_status;
      ELSE

        -- MGAAP start 7263041
        IF (l_multi_gaap_yn = 'Y') THEN
          OPEN check_streams_accrual_csr(p_khr_id, p_date, l_reporting_pdt_id); -- MGAAP
          FETCH check_streams_accrual_csr INTO l_accrual_status;
          CLOSE check_streams_accrual_csr;

          IF l_accrual_status = 'N' THEN
            x_result := l_accrual_status;
          ELSE
            x_result := 'Y';
          END IF;
        ELSE
        -- MGAAP end 7263041
          x_result := 'Y';
        END IF;

      END IF;

    ELSIF l_rev_rec_method = 'ESTIMATED_AND_BILLED' THEN

      -- Bug 4959609. Modified check for E and B based on PM feedback
      OPEN last_int_date_csr;
	  FETCH last_int_date_csr INTO l_last_int_calc_date;
	  CLOSE last_int_date_csr;

      OPEN khr_start_date_csr;
	  FETCH khr_start_date_csr INTO l_khr_start_date;
	  CLOSE khr_start_date_csr;


      IF l_khr_start_date IS NULL THEN
        OKL_API.set_message
		  (G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'START_DATE');
      END IF;

      OKL_STREAM_GENERATOR_PVT.get_next_billing_date(
                   p_api_version            => l_api_version,
                   p_init_msg_list          => l_init_msg_list,
                   p_khr_id                 => p_khr_id,
                   p_billing_date           => nvl(l_last_int_calc_date, l_khr_start_date),
                   x_next_due_date          => l_next_int_calc_date,
                   x_next_period_start_date => l_period_start_date,
                   x_next_period_end_date   => l_period_end_date,
                   x_return_status          => l_return_status,
                   x_msg_count              => l_msg_count,
                   x_msg_data               => l_msg_data);

      -- store the highest degree of error
      IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSE
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

	  -- If the next due date returned by okl_stream_generator_pvt.get_next_billing_date is null,
	  -- it is assumed that this is the last period for the contract. Verify if the streams are
	  -- all accrued and pass the result to the caller.. racheruv Bug 6274870.

      IF l_next_int_calc_date IS NULL THEN
        -- check if streams marked for accrual are accrued
        OPEN check_streams_accrual_csr(p_khr_id, p_date, null); -- MGAAP
        FETCH check_streams_accrual_csr INTO l_accrual_status;
        CLOSE check_streams_accrual_csr;

        IF l_accrual_status = 'N' THEN
          x_result := l_accrual_status;
        ELSE

        -- MGAAP start 7263041
        IF (l_multi_gaap_yn = 'Y') THEN
          OPEN check_streams_accrual_csr(p_khr_id, p_date, l_reporting_pdt_id); -- MGAAP
          FETCH check_streams_accrual_csr INTO l_accrual_status;
          CLOSE check_streams_accrual_csr;

          IF l_accrual_status = 'N' THEN
            x_result := l_accrual_status;
          ELSE
            x_result := 'Y';
          END IF;
        ELSE
        -- MGAAP end 7263041
          x_result := 'Y';
        END IF;
        END IF;
	  -- end of bug fix 6274870.
      ELSIF l_next_int_calc_date <= p_date THEN
        x_result := 'N';

      ELSIF l_next_int_calc_date > p_date THEN
        -- check if streams marked for accrual are accrued
        OPEN check_streams_accrual_csr(p_khr_id, p_date, null); -- MGAAP
        FETCH check_streams_accrual_csr INTO l_accrual_status;
        CLOSE check_streams_accrual_csr;

        IF l_accrual_status = 'N' THEN
          x_result := l_accrual_status;
        ELSE
        -- MGAAP start 7263041
        IF (l_multi_gaap_yn = 'Y') THEN
          OPEN check_streams_accrual_csr(p_khr_id, p_date, l_reporting_pdt_id); -- MGAAP
          FETCH check_streams_accrual_csr INTO l_accrual_status;
          CLOSE check_streams_accrual_csr;

          IF l_accrual_status = 'N' THEN
            x_result := l_accrual_status;
          ELSE
            x_result := 'Y';
          END IF;
        ELSE
        -- MGAAP end 7263041
          x_result := 'Y';
        END IF;
        END IF;

      END IF;

    ELSIF l_rev_rec_method = 'ACTUAL' THEN
      -- Bug 4959609. Modified check for ACTUAL based on PM feedback
      OPEN check_streams_accrual_csr(p_khr_id, p_date, null); -- MGAAP
      FETCH check_streams_accrual_csr INTO l_accrual_status;
      CLOSE check_streams_accrual_csr;

      IF l_accrual_status = 'N' THEN
        x_result := l_accrual_status;
      ELSE
--    Bug 5036337.New method to check accrual completion as mentioned in the bug.
        FOR y IN check_actual_trx(p_khr_id)
        LOOP
          l_last_accrual_date := y.last_accrual_date;
        END LOOP;

        -- Bug 5100210. When accrual has never been run, last_trx_date will be null
        IF l_last_accrual_date IS NULL THEN
           x_result := 'N';
        ELSIF TRUNC(l_last_accrual_date) < TRUNC(p_date) THEN
          x_result := 'N';
        ELSE
        -- MGAAP start 7263041
        IF (l_multi_gaap_yn = 'Y') THEN
          OPEN check_streams_accrual_csr(p_khr_id, p_date, l_reporting_pdt_id); -- MGAAP
          FETCH check_streams_accrual_csr INTO l_accrual_status;
          CLOSE check_streams_accrual_csr;

          IF l_accrual_status = 'N' THEN
            x_result := l_accrual_status;
          ELSE
            x_result := 'Y';
          END IF;
        ELSE
        -- MGAAP end 7263041
          x_result := 'Y';
        END IF;
        END IF;
--    Bug 5036337.Commenting below as method to check has changed as per bug.
--         l_ctxt_val_tbl(1).NAME := 'p_accrual_date';
--         l_ctxt_val_tbl(1).VALUE := TO_CHAR(p_date, 'MM/DD/YYYY');
--
--         Okl_Execute_Formula_Pub.EXECUTE
--         (p_api_version           => l_api_version
--         ,p_init_msg_list         => l_init_msg_list
--         ,x_return_status         => l_return_status
--         ,x_msg_count             => l_msg_count
--         ,x_msg_data              => l_msg_data
--         ,p_formula_name          => l_formula_name
--         ,p_contract_id           => p_khr_id
--         ,p_line_id               => NULL
--         ,p_additional_parameters => l_ctxt_val_tbl
--         ,x_value                 => l_formula_amount);
--
--         -- store the highest degree of error
--         IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
--           IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
--           -- need to leave
--              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
--           ELSE
--              RAISE OKL_API.G_EXCEPTION_ERROR;
--           END IF;
--         END IF;

--         IF l_formula_amount = 0 THEN
--           x_result := 'Y';
--         ELSE
--           x_result := 'N';
--         END IF;
      END IF;

    ELSE
      OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'REVENUE_RECOGNITION_METHOD');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    RETURN x_result;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      RETURN NULL;

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      RETURN NULL;

    WHEN OTHERS THEN
      IF check_streams_accrual_csr%ISOPEN THEN
        CLOSE check_streams_accrual_csr;
      END IF;

      IF last_int_date_csr%ISOPEN THEN
        CLOSE last_int_date_csr;
      END IF;

      IF khr_start_date_csr%ISOPEN THEN
        CLOSE khr_start_date_csr;
      END IF;

      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      RETURN NULL;

  END CHECK_DATE_ACCRUED_TILL;

  -- procedure to create report header for each individual report
  PROCEDURE report_header(p_sob_name IN VARCHAR2
                         ,p_org_name IN VARCHAR2
                         ,p_accrual_date IN DATE
                         ,p_batch_name IN VARCHAR2
                         ,p_func_curr_code IN VARCHAR2
                         ,x_return_status OUT NOCOPY VARCHAR2) IS

    l_sysdate           DATE := sysdate;
    l_space             VARCHAR2(1) := ' ';
    l_dash              VARCHAR2(1) := '-';

  BEGIN

    -- Create report header
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_space,43)||
	         SUBSTR(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_HEADER'),1)||LPAD(l_space,43));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_space,43)||
	         SUBSTR(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_HEADER_UNDERLINE'),1)||LPAD(l_space,43));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');

--    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                                       '||FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_HEADER'));
--    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                                       '||FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_HEADER_UNDERLINE'));
--    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                       --FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_SOB_TITLE')
	                  --||' '||RPAD(p_sob_name, 65)  MGAAP 7263041
	                  RPAD(' ', 80)
					  ||FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_OU_TITLE')
					  ||' '||p_org_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_PROG_DATE_TITLE')
	                  ||' '||RPAD(to_char(l_sysdate,'DD-MON-RRRR HH24:MI:SS'), 61)||FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ACCRUAL_DATE')
					  ||' '||p_accrual_date);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_CURR_TITLE')
	                  ||' '||RPAD(p_func_curr_code,58)||FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_BATCH_NAME')
					  ||' '||p_batch_name);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');

    -- Create Report Content
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_CTR_NUM_TITLE'),28)
	                  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_TRX_NUM_TITLE'),22)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ACTIVITY'),17)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_RULE_STATUS'),20)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_OVRD_STATUS'),16)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CURRENCY'),9)
					  ||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_TITLE'),17) ||
LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_REPRESENTATION_TYPE'),15)); -- MGAAP 7263041

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_CTR_LINE'),28)
	                  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_TRX_LINE'),22)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ACTIVITY_UNDERLINE'),17)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_RUL_STAT_UNDERLINE'),20)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_OVD_STAT_UNDERLINE'),16)
					  ||RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CURR_UNDERLINE'),9)
					  ||LPAD(FND_MESSAGE.GET_STRING('OKL','OKL_GLP_RPT_AMT_LINE'),17) ||
LPAD('==============',15)); -- MGAAP 7263041

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END REPORT_HEADER;

  -- Function to validate contract against accrual rule
  PROCEDURE VALIDATE_ACCRUAL_RULE(x_return_status OUT NOCOPY VARCHAR2
                                 ,x_result OUT NOCOPY VARCHAR2
                                 ,p_ctr_id IN OKL_K_HEADERS.id%TYPE) IS


--  Bug 4576668. SGIYER. Only English lang meaning required.Commented cursor.
-- 	CURSOR accrual_rule_csr IS
-- 	  SELECT logical_op_meaning
--               ,left_parentheses_meaning
--               ,aro_code
--               ,relational_op_meaning
--               ,right_operand_literal
--               ,right_parentheses_meaning
--               ,from_date
--               ,TO_DATE
--         FROM OKL_ACCRUAL_GNRTNS_UV
--         WHERE VERSION = (SELECT MAX(TO_NUMBER(version))
-- 		                 FROM OKL_ACCRUAL_GNRTNS_UV)
-- 		AND TO_DATE IS NULL
-- 		ORDER BY LINE_NUMBER;

	CURSOR accrual_rule_csr IS
    SELECT OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING_LANG('OKL_ACCRUAL_RULE_LOGICAL_OP',arlo_code,540,0,'US') logical_op_meaning
          ,OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING_LANG('OKL_PARENTHESIS',left_parentheses,540,0,'US') left_parentheses_meaning
          ,aro_code
          ,OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING_LANG('OKL_ACCRUAL_RULE_OPERATOR',acro_code,540,0,'US') relational_op_meaning
          ,right_operand_literal
          ,OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING_LANG('OKL_PARENTHESIS',right_parentheses,540,0,'US') right_parentheses_meaning
          ,from_date
          ,to_date
    FROM OKL_ACCRUAL_GNRTNS
    WHERE to_number(VERSION) = (SELECT MAX(to_number(version))
	                            FROM OKL_ACCRUAL_GNRTNS)
    AND TO_DATE IS NULL
    ORDER BY LINE_NUMBER;

	l_string    VARCHAR2(2000);
	l_rule      accrual_rule_csr%ROWTYPE;

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- open cursor for processing
    OPEN accrual_rule_csr;
    LOOP
      FETCH accrual_rule_csr INTO l_rule;
      IF accrual_rule_csr%NOTFOUND THEN
        IF accrual_rule_csr%ROWCOUNT = 0 THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_RULE_NOT_FOUND');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          EXIT;
		END IF;
      END IF;
      -- create the string for SQL execution
	  l_string := l_string||' '||l_rule.logical_op_meaning||' '||l_rule.left_parentheses_meaning||
                  ' OKL_GENERATE_ACCRUALS_PVT.CALCULATE_OPERAND_VALUE('||p_ctr_id||','''|| l_rule.aro_code||''')'||' '
                  ||l_rule.relational_op_meaning||' '||l_rule.right_operand_literal||' '||l_rule.right_parentheses_meaning;
    END LOOP;
    CLOSE accrual_rule_csr;

    l_string := 'SELECT '||'''N'''||' FROM DUAL WHERE '|| l_string;
    EXECUTE IMMEDIATE l_string INTO x_result;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_result := 'Y';

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- close the cursor if it is open
      IF accrual_rule_csr%ISOPEN THEN
        CLOSE accrual_rule_csr;
      END IF;
      x_return_status := Okl_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
  END VALIDATE_ACCRUAL_RULE;

  -- Procedure to select streams that need to be accrued
  PROCEDURE GET_ACCRUAL_STREAMS(x_return_status OUT NOCOPY VARCHAR2
                               ,x_stream_tbl OUT NOCOPY stream_tbl_type
                               ,p_khr_id IN OKL_K_HEADERS.ID%TYPE
							   ,p_product_id IN OKL_PRODUCTS_V.ID%TYPE
                               ,p_ctr_start_date IN DATE
                               ,p_period_end_date IN DATE
							   ,p_accrual_rule_yn IN VARCHAR2) IS


    -- modified cursor where clause and removed accrue_yn attribute check
    -- on okl_strm_type_b for bug# 2475123
    -- added sty.accrual_yn = 'Y' for ER 2872216.
    CURSOR select_streams_csr(p_ctr_id NUMBER, p_accrue_from_date DATE, p_accrue_till_date DATE) IS
      SELECT sty.id,
             stytl.name,
             stm.id stream_id,
             ste.id stream_element_id,
             ste.amount,
             stm.kle_id
        FROM OKL_STRM_TYPE_B sty,
             OKL_STRM_TYPE_TL stytl,
             --OKL_STREAMS stm,
             OKL_STREAMS_REP_V stm,  -- MGAAP 7263041
             OKL_STRM_ELEMENTS ste,
			 OKL_PROD_STRM_TYPES psty,
			 OKL_K_HEADERS khr
          WHERE stm.khr_id = p_ctr_id
            AND khr.id = stm.khr_id
            AND stm.active_yn = 'Y'
			AND stm.say_code = 'CURR'
            --AND stm.purpose_code IS NULL  MGAAP 7263041
            AND (stm.purpose_code IS NULL OR stm.purpose_code='REPORT')
            AND stm.sty_id = sty.id
            AND sty.id = stytl.id
            AND stytl.LANGUAGE = USERENV('LANG')
            AND sty.accrual_yn = p_accrual_rule_yn
			AND sty.id = psty.sty_id
			--AND psty.pdt_id = khr.pdt_id
			AND psty.pdt_id = p_product_id -- MGAAP 7263041
            AND psty.accrual_yn = 'Y'
            AND stm.id = ste.stm_id
            AND TRUNC(ste.stream_element_date) BETWEEN TRUNC(p_accrue_from_date) AND TRUNC(p_accrue_till_date)
            AND ste.amount <> 0 -- bug 2804913
            AND ste.accrued_yn IS NULL;

    CURSOR select_streams_csr2(p_ctr_id NUMBER, p_accrue_from_date DATE, p_accrue_till_date DATE) IS
      SELECT sty.id,
             stytl.name,
             stm.id stream_id,
             ste.id stream_element_id,
             ste.amount,
             stm.kle_id
        FROM OKL_STRM_TYPE_B sty,
             OKL_STRM_TYPE_TL stytl,
             --OKL_STREAMS stm,
             OKL_STREAMS_REP_V stm,  -- MGAAP 7263041
             OKL_STRM_ELEMENTS ste,
			 OKL_PROD_STRM_TYPES psty,
			 OKL_K_HEADERS khr
          WHERE stm.khr_id = p_ctr_id
            AND khr.id = stm.khr_id
            AND stm.active_yn = 'Y'
			AND stm.say_code = 'CURR'
            --AND stm.purpose_code IS NULL MGAAP 7263041
            AND ( stm.purpose_code IS NULL OR stm.purpose_code='REPORT')
            AND stm.sty_id = sty.id
            AND sty.id = stytl.id
            AND stytl.LANGUAGE = USERENV('LANG')
            AND sty.accrual_yn = p_accrual_rule_yn
			AND sty.id = psty.sty_id
			--AND psty.pdt_id = khr.pdt_id
			AND psty.pdt_id = p_product_id -- MGAAP 7263041
            AND psty.accrual_yn = 'Y'
            AND stm.id = ste.stm_id
            AND ste.stream_element_date <= p_accrue_till_date
            AND ste.amount <> 0 -- bug 2804913
            AND ste.accrued_yn IS NULL;


      i     NUMBER :=1;
      l_stream_tbl stream_tbl_type;
  BEGIN

  write_to_log('In Get_Accrual_Streams:p_accrual_rule_yn=' || p_accrual_rule_yn);
  write_to_log('In Get_Accrual_Streams:p_khr_id=' || p_khr_id);
  write_to_log('In Get_Accrual_Streams:p_product_id=' || p_product_id);
  write_to_log('In Get_Accrual_Streams:p_ctr_start_date=' || p_ctr_start_date);
  write_to_log('In Get_Accrual_Streams:p_period_end_date=' || p_period_end_date);
-- Open select_streams_csr cursor for processing
--     FOR l_streams IN select_streams_csr(p_khr_id, p_ctr_start_date, p_period_end_date)
--     LOOP
--       x_stream_tbl(i).stream_type_id := l_streams.id;
--       -- Bug 3126427. Removing ABS as AE can handle negative accounting now (bug 2815972)
--       x_stream_tbl(i).stream_amount := l_streams.amount;
--       x_stream_tbl(i).stream_element_id := l_streams.stream_element_id;
--       x_stream_tbl(i).stream_id := l_streams.stream_id;
--       x_stream_tbl(i).kle_id := l_streams.kle_id;
--       i := i+1;
--     END LOOP;

--     Commenting for Bug 4884618
--     OPEN select_streams_csr(p_khr_id, p_ctr_start_date, p_period_end_date);
--     FETCH select_streams_csr BULK COLLECT INTO l_stream_tbl;
--     CLOSE select_streams_csr;

    -- Bug 4884618. Refering to new profile option.
    IF l_sty_select_basis IS NULL THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_KHR_VALD_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Bug 4884618.
    IF l_sty_select_basis = 'KHR_START_DATE' THEN
      OPEN select_streams_csr(p_khr_id, p_ctr_start_date, p_period_end_date);
      FETCH select_streams_csr BULK COLLECT INTO l_stream_tbl;
      CLOSE select_streams_csr;
	ELSIF l_sty_select_basis = 'BEFORE_KHR_START_DATE' THEN
      OPEN select_streams_csr2(p_khr_id, p_ctr_start_date, p_period_end_date);
      FETCH select_streams_csr2 BULK COLLECT INTO l_stream_tbl;
      CLOSE select_streams_csr2;
    END IF;

    x_stream_tbl := l_stream_tbl;

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
  END GET_ACCRUAL_STREAMS;

  PROCEDURE GET_ACCOUNT_GEN_DETAILS(
    p_contract_id  IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_acc_gen_primary_key_tbl OUT NOCOPY Okl_Account_Dist_Pub.acc_gen_primary_key) IS

    -- Get Contract Salesperson
    -- 30-Apr-2004. Bug 3596651. Cursor provided by Sarvanan.
    CURSOR l_salesperson_csr (cp_chr_id IN NUMBER) IS
    SELECT con.object1_id1
    FROM OKC_K_HEADERS_B  CHR,
         OKC_CONTACT_SOURCES cso,
         OKC_K_PARTY_ROLES_B kpr,
         OKC_CONTACTS  con
    WHERE CHR.id   = cp_chr_id
    AND cso.cro_code  = 'SALESPERSON'
    AND cso.rle_code  = 'LESSOR'
    AND cso.buy_or_sell  = CHR.buy_or_sell
    AND kpr.chr_id  = CHR.id
    AND kpr.dnz_chr_id  = CHR.id
    AND kpr.rle_code  = cso.rle_code
    AND con.cpl_id  = kpr.id
    AND con.dnz_chr_id  = CHR.id
    AND con.cro_code  = cso.cro_code
    AND con.jtot_object1_code = cso.jtot_object_code;

    CURSOR l_fin_sys_parms_csr IS
    SELECT mo_global.get_current_org_id()
    FROM dual;

	-- Get Receivables Transaction Type
	CURSOR	l_cust_trx_type_csr IS
    SELECT	ctt.cust_trx_type_id
    FROM	ra_cust_trx_types	ctt
    WHERE	ctt.name		= 'Invoice-OKL';

    -- cursor to get bill-to-site of customer at contract level
    CURSOR chr_bill_to_site_csr (p_chr_id NUMBER) IS
    SELECT bill_to_site_use_id
    FROM OKC_K_HEADERS_B
    WHERE id = p_chr_id;

    l_sales_person_id              OKC_CONTACTS_V.OBJECT1_ID1%TYPE;
    l_counter                      NUMBER := 1;
    l_org_id                       NUMBER;
    l_receivables_trx_type         VARCHAR2(2000);
    l_bill_to_site                 VARCHAR2(2000);

  BEGIN

	x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Bug 3596651
    -- **************************************************
    -- Populate the account generator table with Contract Salesperson
    -- **************************************************

    OPEN  l_salesperson_csr (p_contract_id);
    FETCH l_salesperson_csr INTO l_sales_person_id;
    CLOSE l_salesperson_csr;

    IF l_sales_person_id IS NOT NULL THEN
      x_acc_gen_primary_key_tbl(l_counter).source_table := 'JTF_RS_SALESREPS_MO_V';
      x_acc_gen_primary_key_tbl(l_counter).primary_key_column := l_sales_person_id;
      l_counter := l_counter + 1;
    END IF;

    -- Bug 3596651
    -- **************************************************
    -- Populate the account generator table with Operating Unit Identifier
    -- **************************************************

    OPEN l_fin_sys_parms_csr;
    FETCH l_fin_sys_parms_csr INTO l_org_id;
    CLOSE l_fin_sys_parms_csr;

    IF l_org_id IS NOT NULL THEN
      x_acc_gen_primary_key_tbl(l_counter).source_table:= 'FINANCIALS_SYSTEM_PARAMETERS';
      x_acc_gen_primary_key_tbl(l_counter).primary_key_column := to_char(l_org_id);
      l_counter := l_counter + 1;
    END IF;

	-- ********************************
	-- Get Receivables Transaction Type
	-- ********************************

	OPEN	l_cust_trx_type_csr;
	FETCH	l_cust_trx_type_csr INTO l_receivables_trx_type;
	CLOSE	l_cust_trx_type_csr;

	IF l_receivables_trx_type IS NOT NULL THEN
		x_acc_gen_primary_key_tbl(l_counter).source_table:= 'RA_CUST_TRX_TYPES';
		x_acc_gen_primary_key_tbl(l_counter).primary_key_column := l_receivables_trx_type;
        l_counter := l_counter + 1;
	END IF;

    OPEN	chr_bill_to_site_csr(p_contract_id);
    FETCH	chr_bill_to_site_csr INTO l_bill_to_site;
    CLOSE	chr_bill_to_site_csr;

    IF l_bill_to_site IS NOT NULL THEN
       x_acc_gen_primary_key_tbl(l_counter).source_table:= 'AR_SITE_USES_V';
       x_acc_gen_primary_key_tbl(l_counter).primary_key_column := l_bill_to_site;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF l_salesperson_csr%ISOPEN THEN
        CLOSE l_salesperson_csr;
      END IF;

      IF l_fin_sys_parms_csr%ISOPEN THEN
        CLOSE l_fin_sys_parms_csr;
      END IF;

      IF l_cust_trx_type_csr%ISOPEN THEN
        CLOSE l_cust_trx_type_csr;
      END IF;

      IF chr_bill_to_site_csr%ISOPEN THEN
        CLOSE chr_bill_to_site_csr;
      END IF;


      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

  END GET_ACCOUNT_GEN_DETAILS;

  PROCEDURE GET_COMMON_INFO (p_accrual_date IN DATE,
                             p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY',
                             x_try_id OUT NOCOPY OKL_TRX_TYPES_V.id%TYPE,
                             x_period_name OUT NOCOPY VARCHAR2,
                             x_period_start_date OUT NOCOPY DATE,
                             x_period_end_date OUT NOCOPY DATE,
                             x_sob_id OUT NOCOPY OKL_SYS_ACCT_OPTS.set_of_books_id%TYPE,
                             x_sob_name OUT NOCOPY VARCHAR2,
                             x_org_id OUT NOCOPY OKL_SYS_ACCT_OPTS.org_id%TYPE,
                             x_org_name OUT NOCOPY VARCHAR2,
                             x_accrual_reversal_days OUT NOCOPY NUMBER,
                             x_func_currency_code OUT NOCOPY OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE,
                             x_return_status OUT NOCOPY VARCHAR2
                             ) IS

    l_period_name               VARCHAR2(2000);
    l_period_start_date         DATE;
    l_period_end_date           DATE;
    l_period_status             VARCHAR2(2000);
    l_sob_id                    OKL_SYS_ACCT_OPTS.set_of_books_id%TYPE;
    l_sob_name                  VARCHAR2(2000);
	l_try_id                    OKL_TRX_TYPES_V.id%TYPE;
    l_func_currency_code        OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
    l_org_id                    OKL_SYS_ACCT_OPTS.org_id%TYPE;
    l_org_name                  VARCHAR2(2000);
    l_accrual_reversal_days     NUMBER;

    -- Cursor to select the transaction type id for the accrual transaction
    CURSOR trx_type_id_csr IS
    SELECT id
    FROM OKL_TRX_TYPES_TL
    WHERE name = 'Accrual'
    AND LANGUAGE = 'US';

	-- Cursor to select the number of days for a reverse transaction
    CURSOR accrual_reversal_days_csr IS
    SELECT accrual_reversal_days
    FROM OKL_SYS_ACCT_OPTS;

    -- cursor to get org name
    CURSOR org_name_csr(p_org_id NUMBER) IS
    SELECT name
    FROM hr_operating_units
    WHERE organization_id = p_org_id;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Find set of books id
    IF (p_representation_type = 'PRIMARY') THEN -- MGAAP 7263041
    l_sob_id := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID(
                                     p_representation_type => 'PRIMARY');
    ELSE
      l_sob_id := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID(
                                     p_representation_type => 'SECONDARY');
    END IF;
    IF (l_sob_id IS NULL) THEN
    -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_SOB_ID_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    x_sob_id := l_sob_id;

    -- Find set of books name
    l_sob_name := Okl_Accounting_Util.GET_SET_OF_BOOKS_NAME(l_sob_id);
    x_sob_name := l_sob_name;

    -- Get period end date
    Okl_Accounting_Util.GET_PERIOD_INFO(
                         p_date => p_accrual_date,
                         p_period_name => l_period_name,
                         p_start_date => l_period_start_date,
                         p_end_date => l_period_end_date,
                         p_ledger_id => l_sob_id);  --MGAAP 7263041
    IF l_period_end_date IS NULL THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_PERIOD_END_DATE');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    x_period_end_date    := l_period_end_date;
    x_period_name        := l_period_name;
    x_period_start_date := l_period_start_date;

    -- validate accrual date for open period check
	-- Bug# 2781593
    l_period_status := Okl_Accounting_Util.GET_OKL_PERIOD_STATUS(
                          p_period_name => l_period_name,
                          p_ledger_id   => l_sob_id); --MGAAP 7263041
    IF l_period_status IS NULL THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_PERIOD_STATUS_ERROR',
							p_token1       => 'PERIOD_NAME',
							p_token1_value => l_period_name);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    IF l_period_status NOT IN ('O','F') THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_OPEN_PERIOD_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Find set of books id
    /* Call moved at the top
    IF (p_representation_type = 'PRIMARY') THEN -- MGAAP 7263041
    l_sob_id := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID;
    ELSE
      l_sob_id := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID('SECONDARY');
    END IF;
    IF (l_sob_id IS NULL) THEN
    -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_SOB_ID_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    x_sob_id := l_sob_id;

    -- Find set of books name
    l_sob_name := Okl_Accounting_Util.GET_SET_OF_BOOKS_NAME(l_sob_id);
    x_sob_name := l_sob_name; */

    -- Find org name for report
    l_org_id := mo_global.get_current_org_id();
    IF l_org_id IS NULL THEN
      -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_ORG_ID_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_org_id := l_org_id;

    OPEN org_name_csr(l_org_id);
    FETCH org_name_csr INTO l_org_name;
    CLOSE org_name_csr;

    IF l_org_name IS NULL THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'ORG_NAME');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
    x_org_name := l_org_name;

    -- Open accrual reversal days cursor to find out number of days to reverse in case of non-accrual processing
    OPEN accrual_reversal_days_csr;
    FETCH accrual_reversal_days_csr INTO l_accrual_reversal_days;
    CLOSE accrual_reversal_days_csr;

    IF l_accrual_reversal_days IS NULL THEN
      -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_REVERSAL_DAYS');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    x_accrual_reversal_days := l_accrual_reversal_days;

    -- Find currency code for the set of books id
    l_func_currency_code := Okl_Accounting_Util.GET_FUNC_CURR_CODE(
                                     p_ledger_id => l_sob_id); --MGAAP 7263041
    IF (l_func_currency_code IS NULL) THEN
    -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_CURR_CODE_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
	x_func_currency_code := l_func_currency_code;

    -- Open cursor to find the transaction type id for accruals
    OPEN trx_type_id_csr;
    FETCH trx_type_id_csr INTO l_try_id;
    CLOSE trx_type_id_csr;
    IF l_try_id IS NULL THEN
      -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_TRX_TYPE_ERROR',
	                      p_token1       => 'TRANSACTION_TYPE',
                          p_token1_value => 'Accrual');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    x_try_id := l_try_id;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF trx_type_id_csr%ISOPEN THEN
        CLOSE trx_type_id_csr;
      END IF;
	  IF accrual_reversal_days_csr%ISOPEN THEN
        CLOSE accrual_reversal_days_csr;
      END IF;

      IF org_name_csr%ISOPEN THEN
        CLOSE org_name_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      IF trx_type_id_csr%ISOPEN THEN
        CLOSE trx_type_id_csr;
      END IF;
	  IF accrual_reversal_days_csr%ISOPEN THEN
        CLOSE accrual_reversal_days_csr;
      END IF;

      IF org_name_csr%ISOPEN THEN
        CLOSE org_name_csr;
      END IF;
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

  END GET_COMMON_INFO;


  PROCEDURE CREATE_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_tcnv_rec OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_rec_type,
    x_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    p_accrual_rec IN accrual_rec_type,
	p_stream_tbl IN stream_tbl_type,
	p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY') IS --MGAAP 7263041

    -- cursor to get Master Item from Financial Asset Line
    CURSOR	l_mtl_sys_item_csr (cp_chr_id NUMBER, cp_cle_id NUMBER) IS
    SELECT	RPAD (ite.object1_id1, 50, ' ') || khr.inv_organization_id
    FROM	okc_k_lines_b        kle_fa,
            okc_line_styles_b    lse_fa,
            okc_k_lines_b        kle_ml,
            okc_line_styles_b    lse_ml,
            okc_k_items          ite,
            okl_k_headers_full_v khr
    WHERE	kle_fa.id		= cp_cle_id
    AND	kle_fa.chr_id		= cp_chr_id
    AND	lse_fa.id		= kle_fa.lse_id
    AND	lse_fa.lty_code		= 'FREE_FORM1'
    AND	kle_ml.cle_id		= kle_fa.id
    AND	lse_ml.id		= kle_ml.lse_id
    AND	lse_ml.lty_code		= 'ITEM'
    AND	ite.cle_id		= kle_ml.id
    AND kle_fa.dnz_chr_id = khr.id
    AND	ite.jtot_object1_code	= 'OKX_SYSITEM';

    -- cursor to get bill-to-site of customer at line level
    CURSOR line_bill_to_site_csr (p_chr_id NUMBER, p_cle_id NUMBER) IS
    SELECT bill_to_site_use_id
    FROM OKC_K_LINES_B
    WHERE id = p_cle_id
    AND dnz_chr_id = p_chr_id;

    --cursor to get lty_code
    CURSOR get_lty_code_csr(p_khr_id NUMBER, p_kle_id NUMBER) IS
    SELECT lsy.lty_code
    FROM  OKC_K_LINES_B cle,
          OKC_LINE_STYLES_B lsy
    WHERE cle.dnz_chr_id = p_khr_id
    AND cle.id = p_kle_id
    AND cle.lse_id = lsy.id;

    -- cursor to get parent kle_id
    CURSOR get_parent_kle_id_csr (p_kle_id NUMBER) IS
    SELECT object1_id1
    FROM okc_k_items
    WHERE cle_id = p_kle_id;

   --Added by kthiruva on 14-May-2007
   --cursor to fetch the contract dff information for SLA Uptake
   CURSOR get_contract_dff_csr(p_khr_id IN NUMBER)
   IS
   SELECT khr.attribute_category
      ,khr.attribute1
      ,khr.attribute2
      ,khr.attribute3
      ,khr.attribute4
      ,khr.attribute5
      ,khr.attribute6
      ,khr.attribute7
      ,khr.attribute8
      ,khr.attribute9
      ,khr.attribute10
      ,khr.attribute11
      ,khr.attribute12
      ,khr.attribute13
      ,khr.attribute14
      ,khr.attribute15
    FROM  okl_k_headers  khr
    WHERE khr.id = p_khr_id;

   --Added by kthiruva on 14-May-2007
   --cursor to fetch the line dff information for SLA Uptake
   CURSOR get_line_dff_csr(p_kle_id IN NUMBER)
   IS
   SELECT kle.attribute_category
      ,kle.attribute1
      ,kle.attribute2
      ,kle.attribute3
      ,kle.attribute4
      ,kle.attribute5
      ,kle.attribute6
      ,kle.attribute7
      ,kle.attribute8
      ,kle.attribute9
      ,kle.attribute10
      ,kle.attribute11
      ,kle.attribute12
      ,kle.attribute13
      ,kle.attribute14
      ,kle.attribute15
    FROM  okl_k_lines  kle
    WHERE kle.id = p_kle_id;


    --local variables
    l_tcnv_rec                  OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
    l_tclv_tbl                  OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
    l_api_name                  VARCHAR2(20) := 'CREATE_ACCRUALS';
    l_api_version               CONSTANT NUMBER := 1.0;
        --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
	l_tsu_code_ent              OKL_TRX_CONTRACTS.TSU_CODE%TYPE := 'PROCESSED';
	l_tcn_type                  OKL_TRX_CONTRACTS.TCN_TYPE%TYPE;
	l_tcl_type                  OKL_TXL_CNTRCT_LNS.TCL_TYPE%TYPE;
    l_source_table              OKL_TRNS_ACC_DSTRS.SOURCE_TABLE%TYPE := 'OKL_TXL_CNTRCT_LNS';
    l_tmpl_identify_rec         Okl_Account_Dist_Pvt.tmpl_identify_rec_type;
    --START: change by nikshah, for SLA Uptake Bug 5705866
    l_dist_info_tbl             Okl_Account_Dist_Pvt.dist_info_tbl_type;
    --END: change by nikshah, for SLA Uptake Bug 5705866
    l_acc_gen_primary_key_tbl   Okl_Account_Dist_Pub.acc_gen_primary_key;
	l_khrv_rec                  Okl_Contract_Pub.khrv_rec_type;
	l_chrv_rec                  Okl_Okc_Migration_Pvt.chrv_rec_type;
	x_khrv_rec                  Okl_Contract_Pub.khrv_rec_type;
	x_chrv_rec                  Okl_Okc_Migration_Pvt.chrv_rec_type;
	x_selv_tbl                  Okl_Streams_Pub.selv_tbl_type;
    l_inv_item_id               VARCHAR2(2000);
    l_line_bill_to_site         VARCHAR2(2000);
    l_counter                   NUMBER;
    l_lty_code                  VARCHAR2(2000);
    l_kle_id                    NUMBER;
    l_parent_kle_id             NUMBER;
    l_kle_id_status             VARCHAR2(2000);
    l_fact_sync_code            VARCHAR2(2000);
    l_inv_acct_code             VARCHAR2(2000);
    l_scs_code                  VARCHAR2(2000) := 'LEASE';
    --START: Added by nikshah 20-Feb-2007 for SLA Uptake, Bug #5707866
    l_tcn_id NUMBER;
    l_tmpl_identify_tbl          Okl_Account_Dist_Pvt.tmpl_identify_tbl_type;
    l_ctxt_tbl                   Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
    l_acc_gen_tbl            Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;
    l_template_out_tbl           Okl_Account_Dist_Pvt.avlv_out_tbl_type;
    l_amount_out_tbl             Okl_Account_Dist_Pvt.amount_out_tbl_type;
    --END: Added by nikshah 20-Feb-2007 for SLA Uptake, Bug #5707866


    TYPE selv_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	l_selv_tbl                  selv_tbl_type;

	TYPE sty_tbl_typ is TABLE OF OKL_STRM_TYPE_V.ID%TYPE INDEX BY BINARY_INTEGER;
	l_sty_tbl                   sty_tbl_typ;

    l_record_exists             VARCHAR2(1);
    l_count                     NUMBER;
    --Added by dpsingh for LE Uptake
    l_legal_entity_id NUMBER;

    -- MGAAP 7263041
    CURSOR primary_rep_trx_id_csr(p_trx_number IN VARCHAR2) IS
    SELECT ID
    FROM   OKL_TRX_CONTRACTS
    WHERE  TRX_NUMBER = p_trx_number
    AND    REPRESENTATION_TYPE = 'PRIMARY';

    l_primary_rep_trx_id OKL_TRX_CONTRACTS.ID%TYPE;

  BEGIN
    -- Set save point

    --write_to_log('In Create_accruals: p_representation_type=' || p_representation_type);
    IF (p_representation_type = 'SECONDARY') THEN
      OPEN primary_rep_trx_id_csr(p_accrual_rec.trx_number);
      FETCH primary_rep_trx_id_csr INTO l_primary_rep_trx_id;
      CLOSE primary_rep_trx_id_csr;
      /*IF l_primary_rep_trx_id IS NULL THEN
        -- store SQL error message on message stack for caller
        okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'PRIMARY_REP_TRX_ID');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;*/
    END IF;

    WRITE_TO_LOG('');
    WRITE_TO_LOG('Inside the call to CREATE_ACCRUALS');
    x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- set tcn and tcl types.
    IF p_accrual_rec.accrual_rule_yn = 'N' THEN
      l_tcn_type := 'NACL';
	  l_tcl_type := 'NACL';
	ELSE
      l_tcn_type := 'ACL';
	  l_tcl_type := 'ACL';
	END IF;
   --Added by dpsingh for LE Uptake
     l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_accrual_rec.contract_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_tcnv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  p_accrual_rec.contract_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Build the transaction record
    l_tcnv_rec.khr_id := p_accrual_rec.contract_id;
    l_tcnv_rec.pdt_id := p_accrual_rec.product_id;
    l_tcnv_rec.try_id := p_accrual_rec.trx_type_id;
    l_tcnv_rec.set_of_books_id := p_accrual_rec.set_of_books_id;
    l_tcnv_rec.tcn_type := l_tcn_type;
    l_tcnv_rec.description := p_accrual_rec.description;
    l_tcnv_rec.date_accrual := p_accrual_rec.accrual_date;
    l_tcnv_rec.date_transaction_occurred := p_accrual_rec.trx_date;
    -- adding ABS function for bug# 2459205 as super trump generates negative amounts for income streams
    -- Bug 3126427. Removing ABS as AE can handle negative accounting now (bug 2815972)
    l_tcnv_rec.amount := p_accrual_rec.amount;
    l_tcnv_rec.currency_code := p_accrual_rec.currency_code;
    l_tcnv_rec.currency_conversion_type := p_accrual_rec.currency_conversion_type;
    l_tcnv_rec.currency_conversion_rate := p_accrual_rec.currency_conversion_rate;
    l_tcnv_rec.currency_conversion_date := p_accrual_rec.currency_conversion_date;
    l_tcnv_rec.accrual_status_yn := p_accrual_rec.rule_result;
    l_tcnv_rec.update_status_yn := p_accrual_rec.override_status;
    l_tcnv_rec.tsu_code := l_tsu_code_ent;
    -- added accrual_activity for bug# 2455956
	l_tcnv_rec.accrual_activity := p_accrual_rec.accrual_activity;
    l_tcnv_rec.source_trx_id := p_accrual_rec.source_trx_id;
    l_tcnv_rec.source_trx_type := p_accrual_rec.source_trx_type;
    l_tcnv_rec.representation_type := p_representation_type; -- MGAAP 7263041
    l_tcnv_rec.trx_number := p_accrual_rec.trx_number; -- MGAAP 7263041
    IF (p_representation_type = 'SECONDARY') THEN -- MGAAP 7263041
      l_tcnv_rec.primary_rep_trx_id  := l_primary_rep_trx_id;
    END IF;

    --Fetching the contract dff information
    FOR get_contract_dff_rec IN get_contract_dff_csr(p_accrual_rec.contract_id)
    LOOP
      l_tcnv_rec.attribute_category := get_contract_dff_rec.attribute_category;
      l_tcnv_rec.attribute1         := get_contract_dff_rec.attribute1;
      l_tcnv_rec.attribute2         := get_contract_dff_rec.attribute2;
      l_tcnv_rec.attribute3         := get_contract_dff_rec.attribute3;
      l_tcnv_rec.attribute4         := get_contract_dff_rec.attribute4;
      l_tcnv_rec.attribute5         := get_contract_dff_rec.attribute5;
      l_tcnv_rec.attribute6         := get_contract_dff_rec.attribute6;
      l_tcnv_rec.attribute7         := get_contract_dff_rec.attribute7;
      l_tcnv_rec.attribute8         := get_contract_dff_rec.attribute8;
      l_tcnv_rec.attribute9         := get_contract_dff_rec.attribute9;
      l_tcnv_rec.attribute10        := get_contract_dff_rec.attribute10;
      l_tcnv_rec.attribute11        := get_contract_dff_rec.attribute11;
      l_tcnv_rec.attribute12        := get_contract_dff_rec.attribute12;
      l_tcnv_rec.attribute13        := get_contract_dff_rec.attribute13;
      l_tcnv_rec.attribute14        := get_contract_dff_rec.attribute14;
      l_tcnv_rec.attribute15        := get_contract_dff_rec.attribute15;
    END LOOP;

     -- Build the transaction line table of records
    FOR i IN p_stream_tbl.FIRST..p_stream_tbl.LAST
    LOOP
      l_tclv_tbl(i).line_number := i;
      l_tclv_tbl(i).khr_id := p_accrual_rec.contract_id;
      l_tclv_tbl(i).kle_id := p_stream_tbl(i).kle_id;
      l_tclv_tbl(i).sty_id := p_stream_tbl(i).stream_type_id;
      l_tclv_tbl(i).tcl_type := l_tcl_type;
      l_tclv_tbl(i).description := p_accrual_rec.description;
      -- Bug 3126427. Removing ABS as AE can handle negative accounting now (bug 2815972)
      l_tclv_tbl(i).amount := p_stream_tbl(i).stream_amount;
      l_tclv_tbl(i).currency_code := p_accrual_rec.currency_code;
      l_tclv_tbl(i).accrual_rule_yn := p_accrual_rec.accrual_rule_yn;
      --Assigning the line DFF fields
      FOR get_line_dff_rec IN get_line_dff_csr( p_stream_tbl(i).kle_id)
      LOOP
        l_tclv_tbl(i).attribute_category := get_line_dff_rec.attribute_category;
        l_tclv_tbl(i).attribute1         := get_line_dff_rec.attribute1;
        l_tclv_tbl(i).attribute2         := get_line_dff_rec.attribute2;
        l_tclv_tbl(i).attribute3         := get_line_dff_rec.attribute3;
        l_tclv_tbl(i).attribute4         := get_line_dff_rec.attribute4;
        l_tclv_tbl(i).attribute5         := get_line_dff_rec.attribute5;
        l_tclv_tbl(i).attribute6         := get_line_dff_rec.attribute6;
        l_tclv_tbl(i).attribute7         := get_line_dff_rec.attribute7;
        l_tclv_tbl(i).attribute8         := get_line_dff_rec.attribute8;
        l_tclv_tbl(i).attribute9         := get_line_dff_rec.attribute9;
        l_tclv_tbl(i).attribute10        := get_line_dff_rec.attribute10;
        l_tclv_tbl(i).attribute11        := get_line_dff_rec.attribute11;
        l_tclv_tbl(i).attribute12        := get_line_dff_rec.attribute12;
        l_tclv_tbl(i).attribute13        := get_line_dff_rec.attribute13;
        l_tclv_tbl(i).attribute14        := get_line_dff_rec.attribute14;
        l_tclv_tbl(i).attribute15        := get_line_dff_rec.attribute15;
      END LOOP;
    END LOOP;

    WRITE_TO_LOG('Prior to the call to Okl_Trx_Contracts_Pub.create_trx_contracts');
    WRITE_TO_LOG('The contents of l_tcnv_rec being passed to the create call ');
    WRITE_TO_LOG('===========================================================');
    WRITE_TO_LOG('l_tcnv_rec.khr_id                    :'||l_tcnv_rec.khr_id);
    WRITE_TO_LOG('l_tcnv_rec.pdt_id                    :'||l_tcnv_rec.pdt_id);
    WRITE_TO_LOG('l_tcnv_rec.try_id                    :'||l_tcnv_rec.try_id);
    WRITE_TO_LOG('l_tcnv_rec.set_of_books_id           :'||l_tcnv_rec.set_of_books_id);
    WRITE_TO_LOG('l_tcnv_rec.tcn_type                  :'||l_tcnv_rec.tcn_type);
    WRITE_TO_LOG('l_tcnv_rec.description               :'||l_tcnv_rec.description);
    WRITE_TO_LOG('l_tcnv_rec.date_accrual              :'||l_tcnv_rec.date_accrual);
    WRITE_TO_LOG('l_tcnv_rec.date_transaction_occurred :'||l_tcnv_rec.date_transaction_occurred);
    WRITE_TO_LOG('l_tcnv_rec.amount                    :'||l_tcnv_rec.amount);
    WRITE_TO_LOG('l_tcnv_rec.currency_code             :'||l_tcnv_rec.currency_code);
    WRITE_TO_LOG('l_tcnv_rec.currency_conversion_type  :'||l_tcnv_rec.currency_conversion_type);
    WRITE_TO_LOG('l_tcnv_rec.currency_conversion_rate  :'||l_tcnv_rec.currency_conversion_rate);
    WRITE_TO_LOG('l_tcnv_rec.currency_conversion_date  :'||l_tcnv_rec.currency_conversion_date);
    WRITE_TO_LOG('l_tcnv_rec.accrual_status_yn         :'||l_tcnv_rec.accrual_status_yn);
    WRITE_TO_LOG('l_tcnv_rec.update_status_yn          :'||l_tcnv_rec.update_status_yn);
    WRITE_TO_LOG('l_tcnv_rec.tsu_code                  :'||l_tcnv_rec.tsu_code);
	WRITE_TO_LOG('l_tcnv_rec.accrual_activity          :'||l_tcnv_rec.accrual_activity);
    WRITE_TO_LOG('l_tcnv_rec.source_trx_id             :'||l_tcnv_rec.source_trx_id);
    WRITE_TO_LOG('l_tcnv_rec.source_trx_type           :'||l_tcnv_rec.source_trx_type);
    WRITE_TO_LOG('l_tcnv_rec.accrual_reversal_date     :'||l_tcnv_rec.accrual_reversal_date);
    WRITE_TO_LOG('l_tcnv_rec.representation_type       :'||l_tcnv_rec.representation_type);
    WRITE_TO_LOG('l_tcnv_rec.trx_number                :'||l_tcnv_rec.trx_number);
    WRITE_TO_LOG('l_tcnv_rec.primary_rep_trx_id        :'||l_tcnv_rec.primary_rep_trx_id);

    WRITE_TO_LOG('');
    WRITE_TO_LOG('The contents of l_tcnv_tbl being passed to the create call ');
    WRITE_TO_LOG('===========================================================');

    FOR i IN l_tclv_tbl.FIRST..l_tclv_tbl.LAST
    LOOP
      WRITE_TO_LOG('l_tclv_tbl(i).line_number     :'||l_tclv_tbl(i).line_number);
      WRITE_TO_LOG('l_tclv_tbl(i).khr_id          :'||l_tclv_tbl(i).khr_id);
      WRITE_TO_LOG('l_tclv_tbl(i).kle_id          :'||l_tclv_tbl(i).kle_id);
      WRITE_TO_LOG('l_tclv_tbl(i).sty_id          :'||l_tclv_tbl(i).sty_id);
      WRITE_TO_LOG('l_tclv_tbl(i).tcl_type        :'||l_tclv_tbl(i).tcl_type);
      WRITE_TO_LOG('l_tclv_tbl(i).description     :'||l_tclv_tbl(i).description);
      WRITE_TO_LOG('l_tclv_tbl(i).amount          :'||l_tclv_tbl(i).amount);
      WRITE_TO_LOG('l_tclv_tbl(i).currency_code   :'||l_tclv_tbl(i).currency_code);
      WRITE_TO_LOG('l_tclv_tbl(i).accrual_rule_yn :'||l_tclv_tbl(i).accrual_rule_yn);
    END LOOP;

    -- Call Transaction Public API to insert transaction header and line records
    Okl_Trx_Contracts_Pub.create_trx_contracts
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,p_tcnv_rec => l_tcnv_rec
                           ,p_tclv_tbl => l_tclv_tbl
                           ,x_tcnv_rec => x_tcnv_rec
                           ,x_tclv_tbl => x_tclv_tbl );
    WRITE_TO_LOG('The status after creating Transaction Header and Transaction Lines is :'||x_return_status);
    -- store the highest degree of error
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      -- need to leave
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => p_accrual_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => p_accrual_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    --START: change by nikshah, for SLA Uptake Bug 5705866

    l_tcn_id := x_tcnv_rec.id;

    --get acc gen sources and value. Bug 3596651
    GET_ACCOUNT_GEN_DETAILS(
        p_contract_id => p_accrual_rec.contract_id,
        x_return_status => x_return_status,
        x_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl);
    --check for error
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_ACC_GEN_ERROR',
                          p_token1       => g_contract_number_token,
                          p_token1_value => p_accrual_rec.contract_number);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

      l_count := 1;

      -- Build Account Generator Sources
      l_count := 0;
      l_kle_id := NULL;

      FOR x IN x_tclv_tbl.FIRST..x_tclv_tbl.LAST
      LOOP
        l_acc_gen_tbl(x).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
	l_acc_gen_tbl(x).source_id := x_tclv_tbl(x).id;
        -- Check if kle_id is not null
        --If kle_id is not null then find out the type of kle_id
        IF x_tclv_tbl(x).kle_id is NOT NULL THEN
          --check if kle_id is new, same or changed
          IF l_kle_id IS NULL THEN
            l_kle_id := x_tclv_tbl(x).kle_id;
            l_kle_id_status := 'NEW';
          ELSE
            IF x_tclv_tbl(x).kle_id = l_kle_id THEN
              l_kle_id_status := 'REPEAT';
            ELSE
              l_kle_id := x_tclv_tbl(x).kle_id;
              l_kle_id_status := 'CHANGED';
            END IF;
          END IF;

          IF l_kle_id_status IN ('NEW','CHANGED') THEN

            --re-initialize variables to null
            l_lty_code           := NULL;
            l_line_bill_to_site  := NULL;
            l_inv_item_id        := NULL;
            l_parent_kle_id      := NULL;

            -- figure out the type of kle_id
            FOR y IN get_lty_code_csr(p_accrual_rec.contract_id, x_tclv_tbl(x).kle_id)
            LOOP
              l_lty_code := y.lty_code;
            END LOOP;

            IF l_lty_code IS NOT NULL THEN
              IF l_lty_code = 'FREE_FORM1' THEN

                OPEN	line_bill_to_site_csr(p_accrual_rec.contract_id, x_tclv_tbl(x).kle_id);
                FETCH	line_bill_to_site_csr INTO l_line_bill_to_site;
                CLOSE	line_bill_to_site_csr;

                IF l_line_bill_to_site IS NOT NULL THEN
                  -- override contratc level bill to site
                  FOR i IN l_acc_gen_tbl(x).acc_gen_key_tbl.FIRST..l_acc_gen_tbl(x).acc_gen_key_tbl.LAST
                  LOOP
                      IF l_acc_gen_tbl(x).acc_gen_key_tbl(i).source_table = 'AR_SITE_USES_V' THEN
                        l_acc_gen_tbl(x).acc_gen_key_tbl(i).primary_key_column := l_line_bill_to_site;
                      END IF;
                  END LOOP;
                END IF;

                -- Get Inv Item Id
                OPEN	l_mtl_sys_item_csr(p_accrual_rec.contract_id, x_tclv_tbl(x).kle_id);
                FETCH	l_mtl_sys_item_csr INTO l_inv_item_id;
                CLOSE	l_mtl_sys_item_csr;

                IF l_inv_item_id IS NOT NULL THEN
                     l_count := l_acc_gen_tbl(x).acc_gen_key_tbl.LAST + 1;
                     l_acc_gen_tbl(x).acc_gen_key_tbl(l_count).source_table:= 'MTL_SYSTEM_ITEMS_VL';
                     l_acc_gen_tbl(x).acc_gen_key_tbl(l_count).primary_key_column := l_inv_item_id;
                ELSE
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_INV_ITEM_ID_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => p_accrual_rec.contract_number,
                                      p_token2       => 'LINE_ID',
                                      p_token2_value => x_tclv_tbl(x).kle_id);
				  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              ELSIF l_lty_code = 'LINK_SERV_ASSET' THEN
                --get kle_id of parent line
                OPEN get_parent_kle_id_csr(x_tclv_tbl(x).kle_id);
                FETCH get_parent_kle_id_csr INTO l_parent_kle_id;
                CLOSE get_parent_kle_id_csr;

                IF l_parent_kle_id IS NULL THEN
                  --raise exception
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_PARENT_KLE_ID_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => p_accrual_rec.contract_number,
                                      p_token2       => 'LINE_ID',
                                      p_token2_value => x_tclv_tbl(x).kle_id);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                OPEN	l_mtl_sys_item_csr(p_accrual_rec.contract_id, l_parent_kle_id);
                FETCH	l_mtl_sys_item_csr INTO l_inv_item_id;
                CLOSE	l_mtl_sys_item_csr;

                IF l_inv_item_id IS NOT NULL THEN

                    l_count := l_acc_gen_tbl(x).acc_gen_key_tbl.LAST + 1;
                    l_acc_gen_tbl(x).acc_gen_key_tbl(l_count).source_table:= 'MTL_SYSTEM_ITEMS_VL';
                    l_acc_gen_tbl(x).acc_gen_key_tbl(l_count).primary_key_column := l_inv_item_id;
                ELSE
                  -- if it is linked service asset, then corresponding inv item id
                  -- of associated asset MUST be available. if not, raise exception.
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_INV_ITEM_ID_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => p_accrual_rec.contract_number,
                                      p_token2       => 'LINE_ID',
                                      p_token2_value => l_parent_kle_id);
				  RAISE OKL_API.G_EXCEPTION_ERROR;

                END IF;
			  END IF; --IF l_lty_code = 'FREE_FORM1' THEN
            END IF; -- IF lty_code IS NOT NULL
          ELSIF l_kle_id_status = 'REPEAT' THEN
            -- use previous values instead f opening cursor again

            IF l_lty_code IN ('FREE_FORM1','LINK_SERV_ASSET') THEN
              -- override contratc level bill to site if asset level info avl
              IF l_line_bill_to_site IS NOT NULL THEN

                FOR i IN l_acc_gen_tbl(x).acc_gen_key_tbl.FIRST..l_acc_gen_tbl(x).acc_gen_key_tbl.LAST
                LOOP
                    IF l_acc_gen_tbl(x).acc_gen_key_tbl(i).source_table = 'AR_SITE_USES_V' THEN
                      l_acc_gen_tbl(x).acc_gen_key_tbl(i).primary_key_column := l_line_bill_to_site;
                    END IF;
                END LOOP;
              END IF;

              IF l_inv_item_id IS NOT NULL THEN
                l_count := l_acc_gen_tbl(x).acc_gen_key_tbl.LAST + 1;
                l_acc_gen_tbl(x).acc_gen_key_tbl(l_count).source_table:= 'MTL_SYSTEM_ITEMS_VL';
                l_acc_gen_tbl(x).acc_gen_key_tbl(l_count).primary_key_column := l_inv_item_id;
              ELSE
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_kle_id_status is REPEAT but l_inv_item_id is NULL. So no value to assign.');
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
            END IF; --IF l_lty_code IN ('FREE_FORM1','LINK_SERV_ASSET') THEN
          END IF; -- IF kle_id_status = 'NEW'
        END IF; --IF x_tclv_tbl(x).kle_id is NOT NULL THEN

      l_tmpl_identify_tbl(x).product_id := x_tcnv_rec.pdt_id;
      l_tmpl_identify_tbl(x).stream_type_id := x_tclv_tbl(x).sty_id;
      l_tmpl_identify_tbl(x).transaction_type_id := x_tcnv_rec.try_id;
      l_tmpl_identify_tbl(x).advance_arrears := p_accrual_rec.advance_arrears;
      l_tmpl_identify_tbl(x).prior_year_yn := 'N';
      l_tmpl_identify_tbl(x).memo_yn := p_accrual_rec.memo_yn;
      --Bug 4622198.
      l_tmpl_identify_tbl(x).factoring_synd_flag := l_fact_sync_code;
      l_tmpl_identify_tbl(x).investor_code := l_inv_acct_code;

        l_dist_info_tbl(x).amount := x_tclv_tbl(x).amount;
        l_dist_info_tbl(x).accounting_date := x_tcnv_rec.date_transaction_occurred;
        l_dist_info_tbl(x).source_id := x_tclv_tbl(x).id;
        l_dist_info_tbl(x).source_table := l_source_table;
        l_dist_info_tbl(x).currency_code := x_tcnv_rec.currency_code;
        l_dist_info_tbl(x).currency_conversion_type := x_tcnv_rec.currency_conversion_type;
        l_dist_info_tbl(x).currency_conversion_rate := x_tcnv_rec.currency_conversion_rate;
        l_dist_info_tbl(x).currency_conversion_date := x_tcnv_rec.currency_conversion_date;
        l_dist_info_tbl(x).post_to_gl := p_accrual_rec.post_to_gl;
        l_dist_info_tbl(x).gl_reversal_flag := p_accrual_rec.gl_reversal_flag;
        --Added by kthiruva on 07-Oct-2005
        --Populating the contract and line id.
        -- Added by sgiyer on 07-Oct-2005. Populating only if not null, else explicit assgn to null.
        l_dist_info_tbl(x).contract_id := x_tclv_tbl(x).khr_id;
        IF x_tclv_tbl(x).kle_id IS NOT NULL THEN
          l_dist_info_tbl(x).contract_line_id := x_tclv_tbl(x).kle_id;
        ELSE
          l_dist_info_tbl(x).contract_line_id := NULL;
        END IF;
      END LOOP;
--       --Bug 4622198.
      OKL_SECURITIZATION_PVT.check_khr_ia_associated(
        p_api_version                  => p_api_version
       ,p_init_msg_list                => p_init_msg_list
       ,x_return_status                => x_return_status
       ,x_msg_count                    => x_msg_count
       ,x_msg_data                     => x_msg_data
       ,p_khr_id                       => p_accrual_rec.contract_id
       ,p_scs_code                     => l_scs_code
       ,p_trx_date                     => p_accrual_rec.accrual_date
       ,x_fact_synd_code               => l_fact_sync_code
       ,x_inv_acct_code                => l_inv_acct_code
       );

       -- store the highest degree of error
       IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         -- need to leave
           Okl_Api.set_message(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_ACC_SEC_PVT_ERROR');
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
           Okl_Api.set_message(p_app_name     => g_app_name,
                               p_msg_name     => 'OKL_ACC_SEC_PVT_ERROR');
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;


        WRITE_TO_LOG('Prior to the call to Create Distributions');
        WRITE_TO_LOG('');
        WRITE_TO_LOG('The contents of l_tmpl_identify_tbl     :');
        WRITE_TO_LOG('=========================================');
        FOR i in l_tmpl_identify_tbl.FIRST..l_tmpl_identify_tbl.LAST
        LOOP
	  WRITE_TO_LOG('l_tmpl_identify_tbl(i).product_id          :'||l_tmpl_identify_tbl(i).product_id);
          WRITE_TO_LOG('l_tmpl_identify_tbl(i).stream_type_id      :'||l_tmpl_identify_tbl(i).stream_type_id);
          WRITE_TO_LOG('l_tmpl_identify_tbl(i).transaction_type_id :'||l_tmpl_identify_tbl(i).transaction_type_id);
          WRITE_TO_LOG('l_tmpl_identify_tbl(i).advance_arrears     :'||l_tmpl_identify_tbl(i).advance_arrears);
          WRITE_TO_LOG('l_tmpl_identify_tbl(i).prior_year_yn       :'||l_tmpl_identify_tbl(i).prior_year_yn);
          WRITE_TO_LOG('l_tmpl_identify_tbl(i).memo_yn             :'||l_tmpl_identify_tbl(i).memo_yn);
          WRITE_TO_LOG('l_tmpl_identify_tbl(i).factoring_synd_flag :'||l_tmpl_identify_tbl(i).factoring_synd_flag);
          WRITE_TO_LOG('l_tmpl_identify_tbl(i).investor_code       :'||l_tmpl_identify_tbl(i).investor_code);
        END LOOP;

        WRITE_TO_LOG('The contents of l_dist_info_Tbl are :');
        WRITE_TO_LOG('=========================================');
        FOR i in l_dist_info_tbl.FIRST..l_dist_info_tbl.LAST
        LOOP
          WRITE_TO_LOG('l_dist_info_tbl(i).amount                   :'||l_dist_info_tbl(i).amount);
          WRITE_TO_LOG('l_dist_info_tbl(i).accounting_date          :'||l_dist_info_tbl(i).accounting_date);
          WRITE_TO_LOG('l_dist_info_tbl(i).source_id                :'||l_dist_info_tbl(i).source_id);
          WRITE_TO_LOG('l_dist_info_tbl(i).source_table             :'||l_dist_info_tbl(i).source_table);
          WRITE_TO_LOG('l_dist_info_tbl(i).currency_code            :'||l_dist_info_tbl(i).currency_code);
          WRITE_TO_LOG('l_dist_info_tbl(i).currency_conversion_type :'||l_dist_info_tbl(i).currency_conversion_type);
          WRITE_TO_LOG('l_dist_info_tbl(i).currency_conversion_rate :'||l_dist_info_tbl(i).currency_conversion_rate);
          WRITE_TO_LOG('l_dist_info_tbl(i).currency_conversion_date :'||l_dist_info_tbl(i).currency_conversion_date);
          WRITE_TO_LOG('l_dist_info_tbl(i).post_to_gl               :'||l_dist_info_tbl(i).post_to_gl);
          WRITE_TO_LOG('l_dist_info_tbl(i).gl_reversal_flag         :'||l_dist_info_tbl(i).gl_reversal_flag);
          WRITE_TO_LOG('l_dist_info_tbl(i).contract_id              :'||l_dist_info_tbl(i).contract_id);
          WRITE_TO_LOG('l_dist_info_tbl(i).contract_line_id         :'||l_dist_info_tbl(i).contract_line_id);
        END LOOP;

        -- Call Okl_Account_Dist_Pub API to create accounting entries for this transaction
	--Call new accounting signature
        Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
                                  p_api_version        => p_api_version,
                                  p_init_msg_list      => p_init_msg_list,
                                  x_return_status      => x_return_status,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data,
                                  p_tmpl_identify_tbl  => l_tmpl_identify_tbl,
                                  p_dist_info_tbl      => l_dist_info_tbl,
                                  p_ctxt_val_tbl       => l_ctxt_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                  x_template_tbl       => l_template_out_tbl,
                                  x_amount_tbl         => l_amount_out_tbl,
				  p_trx_header_id      => l_tcn_id);

        -- store the highest degree of error
        IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to leave
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_CRE_DIST_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => p_accrual_rec.contract_number);
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            -- record that there was an error
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_CRE_DIST_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => p_accrual_rec.contract_number);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

        l_dist_info_tbl.DELETE;
        l_acc_gen_primary_key_tbl.DELETE;

	--END: change by nikshah, for SLA Uptake Bug 5705866


    -- Call Streams Update API to mark the stream elements as accrued
    FOR i IN p_stream_tbl.FIRST..p_stream_tbl.LAST
    LOOP
      l_selv_tbl(i) := p_stream_tbl(i).stream_element_id;
    END LOOP;

    -- Do bulk update
    FORALL i IN l_selv_tbl.FIRST..l_selv_tbl.LAST
      UPDATE okl_strm_elements
      SET accrued_yn = 'Y' where id = l_selv_tbl(i);

--
-- Bug 4662173. Commenting below call for performance reasons.
--
--     Okl_Streams_Pub.UPDATE_STREAM_ELEMENTS
-- 						(p_api_version                  => p_api_version
--                         ,p_init_msg_list                => p_init_msg_list
--                         ,x_return_status                => x_return_status
--                         ,x_msg_count                    => x_msg_count
--                         ,x_msg_data                     => x_msg_data
--                         ,p_selv_tbl                     => l_selv_tbl
--                         ,x_selv_tbl                     => x_selv_tbl );
--     -- store the highest degree of error
--     IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
--       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
--        -- need to leave
--         Okl_Api.set_message(p_app_name     => g_app_name,
--                             p_msg_name     => 'OKL_AGN_STE_UPD_ERROR',
--                             p_token1       => g_contract_number_token,
--                             p_token1_value => p_accrual_rec.contract_number);
--         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
--       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
--         Okl_Api.set_message(p_app_name     => g_app_name,
--                             p_msg_name     => 'OKL_AGN_STE_UPD_ERROR',
--                             p_token1       => g_contract_number_token,
--                             p_token1_value => p_accrual_rec.contract_number);
--         RAISE OKL_API.G_EXCEPTION_ERROR;
--       END IF;
--     END IF;

--
-- Bug 4662173.
-- Commenting below call. There is no need to update contract header.
-- Value of latest accrual rule evaluation is available and used from transaction header.
--
--     IF p_accrual_rec.accrual_rule_yn = 'Y' THEN
--       -- Set current accrual and override status on contract header
--       -- Build the contract header record
--       l_khrv_rec.id := p_accrual_rec.contract_id;
--       l_chrv_rec.id :=  p_accrual_rec.contract_id;
--       l_khrv_rec.generate_accrual_yn := x_tcnv_rec.accrual_status_yn;
--       l_khrv_rec.generate_accrual_override_yn := x_tcnv_rec.update_status_yn;
--
--   	  -- Call Contract Update API to set accrual status
--       Okl_Contract_Pub.update_contract_header
--                              (p_api_version => p_api_version
--                              ,p_init_msg_list => p_init_msg_list
--                              ,x_return_status => x_return_status
--                              ,x_msg_count => x_msg_count
--                              ,x_msg_data => x_msg_data
--                              ,p_restricted_update => 'OKL_API.G_TRUE'
--                              ,p_chrv_rec => l_chrv_rec
--                              ,p_khrv_rec => l_khrv_rec
--                              ,x_chrv_rec => x_chrv_rec
--                              ,x_khrv_rec => x_khrv_rec );
--       -- store the highest degree of error
--       IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
--         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
--           -- need to leave
--           Okl_Api.set_message(p_app_name     => g_app_name,
--                               p_msg_name     => 'OKL_AGN_KHR_UPD_ERROR',
--                               p_token1       => g_contract_number_token,
--                               p_token1_value => p_accrual_rec.contract_number);
--           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
--         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
--           -- record that there was an error
--           Okl_Api.set_message(p_app_name     => g_app_name,
--                               p_msg_name     => 'OKL_AGN_KHR_UPD_ERROR',
--                               p_token1       => g_contract_number_token,
--                               p_token1_value => p_accrual_rec.contract_number);
--           RAISE OKL_API.G_EXCEPTION_ERROR;
--         END IF;
--       END IF;
--     END IF;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN OTHERS THEN
      IF line_bill_to_site_csr%ISOPEN THEN
        CLOSE line_bill_to_site_csr;
      END IF;

      IF l_mtl_sys_item_csr%ISOPEN THEN
        CLOSE l_mtl_sys_item_csr;
      END IF;

      IF get_parent_kle_id_csr%ISOPEN THEN
        CLOSE get_parent_kle_id_csr;
      END IF;

      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END CREATE_ACCRUALS;

  --T and A impact incorporated. Bug 4060794
  PROCEDURE ADJUST_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    --x_trx_number OUT NOCOPY VARCHAR2, -- bug 9191475
	x_trx_tbl  IN OUT NOCOPY trxnum_tbl_type,
    p_accrual_rec IN adjust_accrual_rec_type,
	p_stream_tbl IN stream_tbl_type,
	p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY') IS

    --local variables
    l_api_name                  VARCHAR2(20) := 'CREATE_ACCRUALS';
    l_api_version               CONSTANT NUMBER := 1.0;
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_period_name               VARCHAR2(2000);
    l_period_start_date         DATE;
    l_period_end_date           DATE;
    l_period_status             VARCHAR2(1);
    l_sob_id                    NUMBER;
    l_accrual_rec               accrual_rec_type;
    l_contract_number           OKL_K_HEADERS_FULL_V.contract_number%TYPE;
    l_product_id                OKL_K_HEADERS_FULL_V.pdt_id%TYPE;
    l_reporting_pdt_id          OKL_PRODUCTS.REPORTING_PDT_ID%TYPE;
    l_total1                    NUMBER := 0;
    l_total2                    NUMBER := 0;
	l_try_id                    NUMBER;
    l_currency_conversion_type  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_TYPE%TYPE;
    l_currency_conversion_rate  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_RATE%TYPE;
    l_currency_conversion_date	OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_DATE%TYPE;
    l_func_currency_code        OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
	l_khr_currency_code         OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
    l_factoring_synd_flag       VARCHAR2(2000) := NULL;
	l_tcnv_rec                  OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
    l_tclv_tbl                  OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
    l_start_date                OKL_K_HEADERS_FULL_V.start_date%TYPE;
    l_sts_code                  OKL_K_HEADERS_FULL_V.sts_code%TYPE;
    l_generate_accrual_yn       OKL_K_HEADERS_FULL_V.generate_accrual_yn%TYPE;
    l_generate_accrual_override_yn OKL_K_HEADERS_FULL_V.generate_accrual_override_yn%TYPE;
    l_deal_type                 OKL_K_HEADERS_FULL_V.deal_type%TYPE;
    l_accrual_strm_tbl          stream_tbl_type;
    l_non_accrual_strm_tbl      stream_tbl_type;
    l_accrual_rule_value        OKL_STRM_TYPE_V.accrual_yn%TYPE;
    l_counter1                  NUMBER := 1;
    l_counter2                  NUMBER := 1;
	l_rule_result		        VARCHAR2(1);
    l_sob_name                  VARCHAR2(2000);
    l_org_id                    OKL_SYS_ACCT_OPTS.org_id%TYPE;
    l_org_name                  VARCHAR2(2000);
    l_accrual_reversal_days     NUMBER;



    -- Cursor to select the contract number for the given contract id
    CURSOR contract_details_csr (p_ctr_id VARCHAR2) IS
    SELECT  chr.contract_number,
            chr.currency_code,
            khr.currency_conversion_type,
            khr.currency_conversion_date,
            khr.currency_conversion_rate,
            khr.pdt_id,
            chr.start_date,
            chr.sts_code,
            khr.generate_accrual_yn,
            khr.generate_accrual_override_yn,
            khr.deal_type,
            pdt.reporting_pdt_id  -- MGAAP 7263014
    FROM OKC_K_HEADERS_B chr, OKL_K_HEADERS khr,
         OKL_PRODUCTS pdt
    WHERE chr.id = p_ctr_id
    AND chr.id = khr.id
    AND  khr.pdt_id = pdt.id;

    -- cursor to retrieve accrual rule value
    CURSOR accrual_rule_csr (p_sty_id NUMBER) IS
    SELECT accrual_yn
    FROM OKL_STRM_TYPE_B
    WHERE id = p_sty_id;


  BEGIN

    -- Set save point
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- validate input parameters
    IF (p_accrual_rec.contract_id IS NULL) OR (p_accrual_rec.contract_id = OKL_API.G_MISS_NUM) THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_ACN_KHR_ID_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    IF (p_accrual_rec.accrual_date IS NULL) OR (p_accrual_rec.accrual_date = Okl_Api.G_MISS_DATE) THEN
       Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_AGN_DATE_ERROR');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    IF (p_accrual_rec.source_trx_id IS NULL) OR (p_accrual_rec.source_trx_id = Okl_Api.G_MISS_NUM) THEN
       Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_AGN_SRC_TRX_ID_ERROR');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    IF (p_accrual_rec.source_trx_type IS NULL) OR (p_accrual_rec.source_trx_type = Okl_Api.G_MISS_CHAR) THEN
       Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_AGN_SRC_TRX_TYPE_ERROR');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- get common info
    GET_COMMON_INFO (p_accrual_date => p_accrual_rec.accrual_date,
                     p_representation_type => p_representation_type,
                     x_try_id => l_try_id,
                     x_period_name => l_period_name,
                     x_period_start_date => l_period_start_date,
                     x_period_end_date => l_period_end_date,
                     x_sob_id => l_sob_id,
                     x_sob_name => l_sob_name,
                     x_org_id => l_org_id,
                     x_org_name => l_org_name,
                     x_accrual_reversal_days => l_accrual_reversal_days,
                     x_func_currency_code => l_func_currency_code,
                     x_return_status => l_return_status
                     );
    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_COM_INFO_ERROR');
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_COM_INFO_ERROR');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    IF l_period_status NOT IN ('O','F') THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_OPEN_PERIOD_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- get the contract number
    OPEN contract_details_csr(p_accrual_rec.contract_id);
    FETCH contract_details_csr INTO
          l_contract_number,
          l_khr_currency_code,
          l_currency_conversion_type,
          l_currency_conversion_date,
          l_currency_conversion_rate,
          l_product_id,
          l_start_date,
          l_sts_code,
          l_generate_accrual_yn,
          l_generate_accrual_override_yn,
          l_deal_type,
          l_reporting_pdt_id;  -- MGAAP 7263014
    CLOSE contract_details_csr;

    IF l_contract_number IS NULL THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_product_id IS NULL THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'PDT_ID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_representation_type = 'SECONDARY' THEN  -- MGAAP 7263041
      IF l_reporting_pdt_id IS NULL THEN
        -- store SQL error message on message stack for caller
        okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'REPORTING_PDT_ID');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    IF l_khr_currency_code IS NULL THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'CURRENCY_CODE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_start_date IS NULL THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'START_DATE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_sts_code IS NULL THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'STS_CODE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_sts_code NOT IN ('BOOKED', 'EVERGREEN', 'ACTIVE') THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_AGN_STS_CODE_ERROR',
                          p_token1       => g_contract_number_token,
                          p_token1_value => l_contract_number);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_generate_accrual_yn IS NULL THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'GENERATE_ACCRUAL_YN');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_generate_accrual_override_yn IS NULL THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'GENERATE_ACCRUAL_OVERRIDE_YN');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
-- modified by zrehman for Bug#6788005 on 11-Feb-2008 start
    IF l_deal_type IS NULL AND l_sts_code in ('BOOKED', 'EVERGREEN') THEN
-- modified by zrehman for Bug#6788005 on 11-Feb-2008 end
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'DEAL_TYPE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Check contract currency against functional currency
    IF l_func_currency_code <> l_khr_currency_code THEN
      --validate data
      IF l_currency_conversion_type IS NULL THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_CURR_TYPE_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => l_contract_number);
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
      IF l_currency_conversion_date IS NULL THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_CURR_DATE_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => l_contract_number);
        RAISE Okl_Api.G_EXCEPTION_ERROR;
	  END IF;
      IF l_currency_conversion_type = 'User' THEN
        IF l_currency_conversion_rate IS NULL THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_CURR_USER_RATE_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => l_contract_number);
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
      ELSE
        l_currency_conversion_rate := OKL_ACCOUNTING_UTIL.get_curr_con_rate
              (p_from_curr_code => l_khr_currency_code,
               p_to_curr_code => l_func_currency_code,
               p_con_date => p_accrual_rec.accrual_date, --Bug #5410825
               p_con_type => l_currency_conversion_type);


        IF l_currency_conversion_rate IS NULL THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_CURR_RATE_ERROR',
                              p_token1       => 'CONVERSION_TYPE',
                              p_token1_value => l_currency_conversion_type,
                              p_token2       => 'FROM_CURRENCY',
                              p_token2_value => l_khr_currency_code,
                              p_token3       => 'TO_CURRENCY',
                              p_token3_value => l_func_currency_code
            				  );
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
      l_currency_conversion_date := p_accrual_rec.accrual_date; --Bug #5410825
      END IF;
    END IF;

    IF p_stream_tbl.COUNT > 0 THEN

        -- Calculate total amount for transaction header and sort
        FOR i IN p_stream_tbl.FIRST..p_stream_tbl.LAST
        LOOP

          FOR x in accrual_rule_csr(p_stream_tbl(i).stream_type_id)
          LOOP
            l_accrual_rule_value := x.accrual_yn;
          END LOOP;

          IF l_accrual_rule_value IS NULL THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_ACCRUAL_VAL_ERROR',
                                p_token1       => 'STREAM_TYPE',
                                p_token1_value => p_stream_tbl(i).stream_type_name);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          IF l_accrual_rule_value = 'ACRL_WITH_RULE' THEN
            l_accrual_strm_tbl(l_counter1).stream_type_id := p_stream_tbl(i).stream_type_id;
            l_accrual_strm_tbl(l_counter1).stream_amount  := p_stream_tbl(i).stream_amount;
            l_accrual_strm_tbl(l_counter1).kle_id         := p_stream_tbl(i).kle_id;
            l_total1 := l_total1 + p_stream_tbl(i).stream_amount;
            l_counter1 := l_counter1 + 1;
          ELSIF l_accrual_rule_value = 'ACRL_WITHOUT_RULE' THEN
            l_non_accrual_strm_tbl(l_counter2).stream_type_id := p_stream_tbl(i).stream_type_id;
            l_non_accrual_strm_tbl(l_counter2).stream_amount  := p_stream_tbl(i).stream_amount;
            l_non_accrual_strm_tbl(l_counter2).kle_id         := p_stream_tbl(i).kle_id;
            l_total2 := l_total2 + p_stream_tbl(i).stream_amount;
            l_counter2 := l_counter2 + 1;
          ELSE
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ACCRUAL_YN');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END LOOP;

        IF l_accrual_strm_tbl.COUNT > 0 THEN
          -- identify whether to take into income or non-income
          -- Validate contract against accrual rule and get the result
          VALIDATE_ACCRUAL_RULE(x_return_status => l_return_status
                               ,x_result => l_rule_result
                               ,p_ctr_id => p_accrual_rec.contract_id);
          -- store the highest degree of error
          IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_RULE_VALD_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_contract_number);
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;

          -- Build the accrual record
          l_accrual_rec.contract_id         := p_accrual_rec.contract_id;
          l_accrual_rec.set_of_books_id     := l_sob_id;
          l_accrual_rec.accrual_date        := p_accrual_rec.accrual_date;
          l_accrual_rec.trx_date            := p_accrual_rec.accrual_date;
          l_accrual_rec.contract_number     := l_contract_number;
          l_accrual_rec.description         := p_accrual_rec.description;
          l_accrual_rec.currency_code       := l_khr_currency_code;
          l_accrual_rec.currency_conversion_type := l_currency_conversion_type;
          l_accrual_rec.currency_conversion_rate := l_currency_conversion_rate;
          l_accrual_rec.currency_conversion_date := l_currency_conversion_date;
          l_accrual_rec.product_id          := l_product_id;
          IF (p_representation_type = 'SECONDARY') THEN  -- MGAAP 7263041
            l_accrual_rec.product_id          := l_reporting_pdt_id;
          END IF;
          -- MGAAP 7263041
          -- bug 9191475 .. start
          begin
            if x_trx_tbl('ACRL_WITH_RULE') is not null then
              l_accrual_rec.trx_number      := x_trx_tbl('ACRL_WITH_RULE');
            end if;
          exception
            when no_data_found then
              l_accrual_rec.trx_number      := p_accrual_rec.trx_number;
          end; -- bug 9191475 end

          --l_accrual_rec.trx_number          := p_accrual_rec.trx_number;
          l_accrual_rec.trx_type_id         := l_try_id;
          l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
          l_accrual_rec.post_to_gl          := 'Y';
          l_accrual_rec.gl_reversal_flag    := 'N';
          l_accrual_rec.accrual_rule_yn     := 'Y';
          l_accrual_rec.source_trx_id       := p_accrual_rec.source_trx_id;
          l_accrual_rec.source_trx_type     := p_accrual_rec.source_trx_type;
          l_accrual_rec.amount              := l_total1;

          IF l_generate_accrual_override_yn = 'N' THEN
            IF l_rule_result = 'Y' THEN
              -- create income entries
              l_accrual_rec.rule_result         := l_rule_result;
              l_accrual_rec.override_status     := l_generate_accrual_override_yn;
              l_accrual_rec.memo_yn             := 'N';
              l_accrual_rec.accrual_activity    := 'ACCRUAL';
            ELSIF l_rule_result = 'N' THEN
              -- create memo entries
              l_accrual_rec.rule_result         := l_rule_result;
              l_accrual_rec.override_status     := l_generate_accrual_override_yn;
              l_accrual_rec.memo_yn             := 'Y';
              l_accrual_rec.accrual_activity    := 'NON-ACCRUAL';
            ELSE
              -- invalid value
              OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'l_rule_result');
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          ELSIF l_generate_accrual_override_yn = 'Y' THEN
            -- create memo entires
            l_accrual_rec.rule_result         := l_rule_result;
            l_accrual_rec.override_status     := l_generate_accrual_override_yn;
            l_accrual_rec.memo_yn             := 'Y';
            l_accrual_rec.accrual_activity    := 'NON-ACCRUAL';
          ELSE
            -- invalid value
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'l_generate_accrual_override_yn');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
          CREATE_ACCRUALS (
               p_api_version => l_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               x_tcnv_rec => l_tcnv_rec,
               x_tclv_tbl => l_tclv_tbl,
               p_accrual_rec => l_accrual_rec,
               p_stream_tbl => l_accrual_strm_tbl,
               p_representation_type => p_representation_type);

          IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              -- need to leave
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                  p_token1       => g_contract_number_token,
                                  p_token1_value => l_contract_number);
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                  p_token1       => g_contract_number_token,
                                  p_token1_value => l_contract_number);
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

          x_trx_tbl('ACRL_WITH_RULE') := l_tcnv_rec.trx_number; -- bug 9191475

        END IF;

        IF l_non_accrual_strm_tbl.COUNT > 0 THEN

          -- Build the accrual record
          l_accrual_rec.contract_id         := p_accrual_rec.contract_id;
          l_accrual_rec.set_of_books_id     := l_sob_id;
          l_accrual_rec.accrual_date        := p_accrual_rec.accrual_date;
          l_accrual_rec.trx_date            := p_accrual_rec.accrual_date;
          l_accrual_rec.contract_number     := l_contract_number;
          l_accrual_rec.description         := p_accrual_rec.description;
          l_accrual_rec.currency_code       := l_khr_currency_code;
          l_accrual_rec.currency_conversion_type := l_currency_conversion_type;
          l_accrual_rec.currency_conversion_rate := l_currency_conversion_rate;
          l_accrual_rec.currency_conversion_date := l_currency_conversion_date;
          l_accrual_rec.product_id          := l_product_id;
          IF (p_representation_type = 'SECONDARY') THEN  -- MGAAP 7263041
            l_accrual_rec.product_id          := l_reporting_pdt_id;
          END IF;
          -- MGAAP 7263041

          -- bug 9191475 .. start
          --l_accrual_rec.trx_number          := p_accrual_rec.trx_number;
          begin
            if x_trx_tbl('ACRL_WITHOUT_RULE') is not null then
              l_accrual_rec.trx_number      := x_trx_tbl('ACRL_WITHOUT_RULE');
            end if;
          exception
            when no_data_found then
              l_accrual_rec.trx_number      := p_accrual_rec.trx_number;
          end; -- bug 9191475 end

          l_accrual_rec.trx_type_id         := l_try_id;
          l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
          l_accrual_rec.post_to_gl          := 'Y';
          l_accrual_rec.gl_reversal_flag    := 'N';
          l_accrual_rec.accrual_rule_yn     := 'N';
          l_accrual_rec.source_trx_id       := p_accrual_rec.source_trx_id;
          l_accrual_rec.source_trx_type     := p_accrual_rec.source_trx_type;
          l_accrual_rec.amount              := l_total2;
          l_accrual_rec.rule_result         := NULL;
          l_accrual_rec.override_status     := NULL;
          l_accrual_rec.memo_yn             := 'N';
          l_accrual_rec.accrual_activity    := 'ACCRUAL';


          -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
          CREATE_ACCRUALS (
               p_api_version => l_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               x_tcnv_rec => l_tcnv_rec,
               x_tclv_tbl => l_tclv_tbl,
               p_accrual_rec => l_accrual_rec,
               p_stream_tbl => l_non_accrual_strm_tbl,
               p_representation_type => p_representation_type);

          IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              -- need to leave
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                  p_token1       => g_contract_number_token,
                                  p_token1_value => l_contract_number);
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                  p_token1       => g_contract_number_token,
                                  p_token1_value => l_contract_number);
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

          x_trx_tbl('ACRL_WITHOUT_RULE') := l_tcnv_rec.trx_number; -- bug 9191475

        END IF;
    ELSE
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_STRM_TBL_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF; -- IF l_stream_tbl.COUNT >0

    --x_trx_number := l_tcnv_rec.trx_number; -- bug 9191475

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN OTHERS THEN

      IF contract_details_csr%ISOPEN THEN
        CLOSE contract_details_csr;
      END IF;

      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END ADJUST_ACCRUALS;

  PROCEDURE ACCELERATE_ACCRUALS (
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
	p_acceleration_rec IN acceleration_rec_type,
	p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY', --MGAAP 7263041
        x_trx_number OUT NOCOPY OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE) IS --MGAAP 7263041

    -- local collections
    TYPE accelerate_ref_cursor IS REF CURSOR;
	TYPE stream_rec IS RECORD
	  (sty_id OKL_STRM_TYPE_V.ID%TYPE,
	   ste_id OKL_STRM_ELEMENTS_V.ID%TYPE,
	   amount NUMBER,
	   kle_id OKL_STREAMS.kle_ID%TYPE
          ,stm_id OKL_STREAMS.ID%TYPE ); -- 9001154

    --local variables
    l_api_name                  VARCHAR2(20) := 'ACCELERATE_ACCRUALS';
    l_api_version               CONSTANT NUMBER := 1.0;
    l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_try_name                  CONSTANT VARCHAR2(7) := 'Accrual';
    l_period_name               VARCHAR2(2000);
    l_period_start_date         DATE;
    l_period_end_date           DATE;
    l_period_status             VARCHAR2(1);
    l_sob_id                    NUMBER;
	l_stream_tbl                stream_tbl_type;
    l_accrual_rec               accrual_rec_type;
    l_contract_number           OKL_K_HEADERS_FULL_V.contract_number%TYPE;
    l_product_id                OKL_K_HEADERS_FULL_V.pdt_id%TYPE;
    l_reporting_pdt_id          OKL_PRODUCTS.reporting_pdt_id%TYPE; --MGAAP 7263041
    l_apply_accrual_rule        VARCHAR2(1) := '?';
	l_rule_result		        VARCHAR2(1);
    l_override_status           VARCHAR2(1);
    l_total                     NUMBER := 0;
	l_try_id                    NUMBER;
    l_currency_code             OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
    l_currency_conversion_type  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_TYPE%TYPE;
    l_currency_conversion_rate  OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_RATE%TYPE;
    l_currency_conversion_date	OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_DATE%TYPE;
    l_func_currency_code        OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
    l_factoring_synd_flag       VARCHAR2(2000) := NULL;
    l_billing_type              VARCHAR2(2000) := NULL;
	l_tcnv_rec                  OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
    l_tclv_tbl                  OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
    acceleration_streams_csr    accelerate_ref_cursor;
    l_stream_rec                stream_rec;
    l_counter                   NUMBER := 1;

    -- Bug 9001154 : Start
    l_stm_id         OKL_STREAMS.ID%TYPE;
    l_max_se_line_no OKL_STRM_ELEMENTS.SE_LINE_NUMBER%TYPE;
    lp_selv_rec      Okl_Streams_pub.selv_rec_type;
    lx_selv_rec      Okl_Streams_pub.selv_rec_type;

    CURSOR max_line_num_csr (p_stm_id NUMBER) IS
      SELECT max(se_line_number)
       FROM okl_strm_elements
     WHERE stm_id = p_stm_id;
    -- Bug 9001154 :  End
    -- Cursor to select the transaction type id for the accrual transaction
    CURSOR trx_type_id_csr IS
    SELECT id
    FROM OKL_TRX_TYPES_TL
    WHERE name = l_try_name
    AND LANGUAGE = 'US';

    -- cursor to get the contract number
    CURSOR contract_details_csr (p_khr_id NUMBER) IS
    SELECT chr.contract_number
	      ,khr.pdt_id
		  ,NVL(khr.generate_accrual_override_yn, 'N') override_yn
		  ,chr.currency_code
		  ,khr.currency_conversion_type
		  ,khr.currency_conversion_rate
		  ,khr.currency_conversion_date
		  ,pdt.reporting_pdt_id
	FROM OKC_K_HEADERS_B chr, OKL_K_HEADERS khr,
             OKL_PRODUCTS pdt  --MGAAP 7263041
	WHERE chr.id = p_khr_id
	AND chr.id = khr.id
        AND khr.pdt_id = pdt.id;

--     Cursor to select currency conversion information
--     CURSOR currency_conv_csr(p_conversion_type VARCHAR2, p_from_currency VARCHAR2, p_to_currency VARCHAR2, p_conversion_date DATE) IS
--     SELECT conversion_rate
--     FROM GL_DAILY_RATES
--     WHERE conversion_type = p_conversion_type
--     AND conversion_date = p_conversion_date
--     AND from_currency = p_from_currency
--     AND to_currency = p_to_currency
--     AND status_code = 'C';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Set save point
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- validate input parameters
    IF (p_acceleration_rec.khr_id IS NULL) OR (p_acceleration_rec.khr_id = OKL_API.G_MISS_NUM) THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_ACN_KHR_ID_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    IF (p_acceleration_rec.acceleration_date IS NULL) OR (p_acceleration_rec.acceleration_date = OKL_API.G_MISS_DATE) THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_ACN_DATE_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    -- Changes for Bug 4040248
	-- remove validation and run accruals for specified stream type if provided and
	-- for all stream types marked for accrual if not provided.
--     IF (p_acceleration_rec.sty_id IS NULL) OR (p_acceleration_rec.sty_id = OKL_API.G_MISS_NUM) THEN
--       Okl_Api.set_message(p_app_name     => g_app_name,
--                           p_msg_name     => 'OKL_AGN_ACN_STY_ERROR');
--       RAISE Okl_Api.G_EXCEPTION_ERROR;
-- 	END IF;

    IF (p_acceleration_rec.accrual_rule_yn IS NULL) OR (p_acceleration_rec.accrual_rule_yn = OKL_API.G_MISS_CHAR) THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_ACN_RULE_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    IF (p_acceleration_rec.accelerate_till_date IS NULL) OR (p_acceleration_rec.accelerate_till_date = OKL_API.G_MISS_DATE) THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_ACN_TILL_DATE_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    -- check for kle_id
        --akrangan  cursor modified for bug 5526955 begin
        IF (p_acceleration_rec.kle_id IS NOT NULL AND p_acceleration_rec.accelerate_from_date IS NOT NULL) THEN
 	       OPEN acceleration_streams_csr FOR
 	           SELECT sty.id sty_id,
 	                  ste.id ste_id,
 	              ste.amount amount,
 	              stm.kle_id
                     ,stm.id stm_id -- Bug : 9001154
 	       FROM OKL_STRM_TYPE_B sty,
 	            --OKL_STREAMS stm,
 	            OKL_STREAMS_REP_V stm, --MGAAP 7263041
 	            OKL_STRM_ELEMENTS ste,
 	            OKL_PROD_STRM_TYPES psty,
 	                    OKL_K_HEADERS khr,
 	            OKL_PRODUCTS pdt
 	       WHERE sty.id = p_acceleration_rec.sty_id
 	           AND stm.khr_id = p_acceleration_rec.khr_id
 	       AND stm.kle_id = p_acceleration_rec.kle_id
 	       AND khr.id = stm.khr_id
 	       AND stm.sty_id = sty.id
 	       AND sty.id = psty.sty_id
               --AND psty.pdt_id = khr.pdt_id
 	       AND ((psty.pdt_id = khr.pdt_id AND  --MGAAP 7263041
                     khr.pdt_id = pdt.ID AND
                     p_representation_type = 'PRIMARY') OR
                    (khr.pdt_id = pdt.ID AND
                     pdt.reporting_pdt_id = psty.pdt_id AND
                     p_representation_type = 'SECONDARY')
                   )
 	       AND khr.id = stm.khr_id
 	       AND stm.id = ste.stm_id
 	       AND ste.amount <> 0
 	   --    AND ste.accrued_yn IS NULL
 	       AND stm.active_yn = 'Y'
 	       AND stm.say_code = 'CURR'
 	       AND psty.accrual_yn = 'Y'
 	       AND TRUNC(ste.stream_element_date) >= TRUNC(p_acceleration_rec.accelerate_from_date)
 	       AND TRUNC(ste.stream_element_date) <= TRUNC(p_acceleration_rec.accelerate_till_date);
      ELSIF (p_acceleration_rec.kle_id IS NOT NULL AND p_acceleration_rec.accelerate_from_date IS  NULL) THEN
      OPEN acceleration_streams_csr FOR
	  SELECT sty.id sty_id,
	         ste.id ste_id,
             ste.amount amount,
             stm.kle_id
          ,stm.id stm_id -- Bug : 9001154

      FROM OKL_STRM_TYPE_B sty,
           --OKL_STREAMS stm,
           OKL_STREAMS_REP_V stm,  --MGAAP 7263041
           OKL_STRM_ELEMENTS ste,
           OKL_PROD_STRM_TYPES psty,
		   OKL_K_HEADERS khr,
	   OKL_PRODUCTS pdt
      WHERE sty.id = p_acceleration_rec.sty_id
	  AND stm.khr_id = p_acceleration_rec.khr_id
      AND stm.kle_id = p_acceleration_rec.kle_id
      AND khr.id = stm.khr_id
      AND stm.sty_id = sty.id
      AND sty.id = psty.sty_id
      --AND psty.pdt_id = khr.pdt_id
 	       AND ((psty.pdt_id = khr.pdt_id AND  --MGAAP 7263041
                     khr.pdt_id = pdt.ID AND
                     p_representation_type = 'PRIMARY') OR
                    (khr.pdt_id = pdt.ID AND
                     pdt.reporting_pdt_id = psty.pdt_id AND
                     p_representation_type = 'SECONDARY')
                   )
      AND khr.id = stm.khr_id
      AND stm.id = ste.stm_id
      AND ste.amount <> 0
      AND ste.accrued_yn IS NULL
      AND stm.active_yn = 'Y'
      AND stm.say_code = 'CURR'
      AND psty.accrual_yn = 'Y'
      AND TRUNC(ste.stream_element_date) <= TRUNC(p_acceleration_rec.accelerate_till_date);

 	    ELSIF  (p_acceleration_rec.kle_id IS NULL AND p_acceleration_rec.accelerate_from_date IS NOT NULL) THEN

 	       OPEN acceleration_streams_csr FOR
 	           SELECT sty.id sty_id,
 	                  ste.id ste_id,
 	              ste.amount amount,
 	              stm.kle_id
                     ,stm.id stm_id -- Bug : 9001154
 	       FROM OKL_STRM_TYPE_B sty,
 	            --OKL_STREAMS stm,
 	            OKL_STREAMS_REP_V stm, --MGAAP 7263041
 	            OKL_STRM_ELEMENTS ste,
 	            OKL_PROD_STRM_TYPES psty,
 	                    OKL_K_HEADERS khr,
		    OKL_PRODUCTS pdt
 	       WHERE stm.khr_id = p_acceleration_rec.khr_id
 	           AND khr.id = stm.khr_id
 	       AND sty.id = p_acceleration_rec.sty_id
 	       AND stm.sty_id = sty.id
 	       AND sty.id = psty.sty_id
 	       --AND psty.pdt_id = khr.pdt_id
 	       AND ((psty.pdt_id = khr.pdt_id AND  --MGAAP 7263041
                     khr.pdt_id = pdt.ID AND
                     p_representation_type = 'PRIMARY') OR
                    (khr.pdt_id = pdt.ID AND
                     pdt.reporting_pdt_id = psty.pdt_id AND
                     p_representation_type = 'SECONDARY')
                   )
 	       AND khr.id = stm.khr_id
 	       AND stm.id = ste.stm_id
 	       AND ste.amount <> 0
 	 --      AND ste.accrued_yn IS NULL
 	       AND stm.active_yn = 'Y'
 	       AND stm.say_code = 'CURR'
 	       AND psty.accrual_yn = 'Y'
 	       AND TRUNC(ste.stream_element_date) >= TRUNC(p_acceleration_rec.accelerate_from_date)
 	       AND TRUNC(ste.stream_element_date) <= TRUNC(p_acceleration_rec.accelerate_till_date);

	ELSE

      OPEN acceleration_streams_csr FOR
	  SELECT sty.id sty_id,
	         ste.id ste_id,
             ste.amount amount,
             stm.kle_id
            ,stm.id stm_id -- Bug : 9001154
      FROM OKL_STRM_TYPE_B sty,
           --OKL_STREAMS stm,
           OKL_STREAMS_REP_V stm,  --MGAAP 7263041
           OKL_STRM_ELEMENTS ste,
           OKL_PROD_STRM_TYPES psty,
		   OKL_K_HEADERS khr,
		   OKL_PRODUCTS pdt
      WHERE stm.khr_id = p_acceleration_rec.khr_id
	  AND khr.id = stm.khr_id
      AND sty.id = p_acceleration_rec.sty_id
      AND stm.sty_id = sty.id
      AND sty.id = psty.sty_id
      --AND psty.pdt_id = khr.pdt_id
 	       AND ((psty.pdt_id = khr.pdt_id AND  --MGAAP 7263041
                     khr.pdt_id = pdt.ID AND
                     p_representation_type = 'PRIMARY') OR
                    (khr.pdt_id = pdt.ID AND
                     pdt.reporting_pdt_id = psty.pdt_id AND
                     p_representation_type = 'SECONDARY')
                   )
      AND khr.id = stm.khr_id
      AND stm.id = ste.stm_id
      AND ste.amount <> 0
      AND ste.accrued_yn IS NULL
      AND stm.active_yn = 'Y'
      AND stm.say_code = 'CURR'
      AND psty.accrual_yn = 'Y'
      AND TRUNC(ste.stream_element_date) <= TRUNC(p_acceleration_rec.accelerate_till_date);

    END IF;
    -- akrangan cursor modified for bug 5526955 end
	IF acceleration_streams_csr%ISOPEN THEN
      LOOP
        FETCH acceleration_streams_csr INTO l_stream_rec;
        EXIT WHEN acceleration_streams_csr%NOTFOUND;
	    l_stream_tbl(l_counter).stream_type_id := l_stream_rec.sty_id;
	    l_stream_tbl(l_counter).stream_element_id := l_stream_rec.ste_id;
	    l_stream_tbl(l_counter).stream_amount := l_stream_rec.amount;
	    l_stream_tbl(l_counter).kle_id := l_stream_rec.kle_id;
        l_total := l_total + l_stream_rec.amount;
        -- Bug: 9001154
        l_stm_id := l_stream_rec.stm_id;
        l_counter := l_counter + 1;
      END LOOP;
      CLOSE acceleration_streams_csr;
    END IF;
    -- Bug 9001154 : Start
	-- Only on presence of the date from which acceleration is to happen, should we create a new stream element. Otherwise, donot change the acceleration logic
	IF p_acceleration_rec.accelerate_from_date IS NOT NULL
	     AND l_stream_tbl.COUNT > 0
		 AND l_total > 0 THEN
       -- Create a new stream element that represents the amount to be accelerated.
	   lp_selv_rec.amount := l_total;
	   lp_selv_rec.stm_id := l_stm_id;
	   -- create new stream element on the day just before acceleration will start. Termination APIs will request for acceleration to begin
	   -- from the day next to the termination month end.
	   lp_selv_rec.stream_element_date := p_acceleration_rec.accelerate_from_date -1 ;
        -- --------------------------------
        -- fetch max se_line_number from
         -- sel table
        -- --------------------------------
        l_max_se_line_no := 0;
        OPEN  max_line_num_csr ( l_stm_id );
          FETCH max_line_num_csr INTO l_max_se_line_no;
        CLOSE max_line_num_csr;
	lp_selv_rec.se_line_number := NVL(l_max_se_line_no,0) + 1;
      	-- Call the create stream element API
         Okl_Streams_Pub.create_stream_elements(
                           p_api_version   => l_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_selv_rec      => lp_selv_rec
                          ,x_selv_rec      => lx_selv_rec);
        IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => l_contract_number);
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => l_contract_number);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
       -- Ensure that only this new stream element is accelerated
	   l_stream_tbl.delete;
	    l_stream_tbl(1).stream_type_id := p_acceleration_rec.sty_id;
	    l_stream_tbl(1).stream_element_id := lx_selv_rec.id;
	    l_stream_tbl(1).stream_amount := lx_selv_rec.amount;
	    l_stream_tbl(1).kle_id := p_acceleration_rec.kle_id;
	END IF;
	-- Bug 9001154 : End


    -- process only if stream elements exist
    IF l_stream_tbl.COUNT > 0 THEN

      -- get transaction type id
	  OPEN trx_type_id_csr;
	  FETCH trx_type_id_csr INTO l_try_id;
	  CLOSE trx_type_id_csr;
      IF l_try_id IS NULL THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_TRY_ID_ERROR');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      -- Find set of books id
      l_sob_id := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID(
                            p_representation_type => p_representation_type);
      IF (l_sob_id IS NULL) THEN
      -- store SQL error message on message stack for caller
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_SOB_ID_ERROR');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      -- Get period end date
      --Okl_Accounting_Util.GET_PERIOD_INFO(p_acceleration_rec.acceleration_date,l_period_name,l_period_start_date,l_period_end_date);
      Okl_Accounting_Util.GET_PERIOD_INFO(
                         p_date => p_acceleration_rec.acceleration_date,
                         p_period_name => l_period_name,
                         p_start_date => l_period_start_date,
                         p_end_date => l_period_end_date,
                         p_ledger_id => l_sob_id);  --MGAAP 7263041
      IF l_period_name IS NULL THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_PERIOD_END_DATE');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      -- validate accrual date for open period check
      l_period_status := Okl_Accounting_Util.GET_OKL_PERIOD_STATUS(
                          p_period_name => l_period_name,
                          p_ledger_id   => l_sob_id); --MGAAP 7263041
      IF l_period_status IS NULL THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_PERIOD_STATUS_ERROR',
			  				  p_token1       => 'PERIOD_NAME',
				  			  p_token1_value => l_period_name);
        RAISE Okl_Api.G_EXCEPTION_ERROR;
	  END IF;

      IF l_period_status NOT IN ('O','F') THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_OPEN_PERIOD_ERROR');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      -- Find set of books id
      /* Moved before call to get period info
      l_sob_id := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID(
                            p_representation_type => p_representation_type);
      IF (l_sob_id IS NULL) THEN
      -- store SQL error message on message stack for caller
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_SOB_ID_ERROR');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF; */

      -- Find currency code for the set of books id
      l_func_currency_code := Okl_Accounting_Util.GET_FUNC_CURR_CODE(
                                     p_ledger_id => l_sob_id); --MGAAP 7263041
      IF (l_func_currency_code IS NULL) THEN
      -- store SQL error message on message stack for caller
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_CURR_CODE_ERROR');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      -- get contract details
	  FOR x IN contract_details_csr(p_acceleration_rec.khr_id)
      LOOP
        l_contract_number := x.contract_number;
        l_product_id := x.pdt_id;
		l_override_status := x.override_yn;
        l_currency_code := x.currency_code;
        l_currency_conversion_type := x.currency_conversion_type;
        l_currency_conversion_rate := x.currency_conversion_rate;
        l_currency_conversion_date := x.currency_conversion_date;
        l_reporting_pdt_id := x.reporting_pdt_id;
      END LOOP;

      -- Check contract currency against functional currency
      IF l_func_currency_code <> l_currency_code THEN
        --validate data
        IF l_currency_conversion_type IS NULL THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_CURR_TYPE_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => l_contract_number);
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        IF l_currency_conversion_date IS NULL THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_CURR_DATE_ERROR',
                               p_token1       => g_contract_number_token,
                              p_token1_value => l_contract_number);
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        IF l_currency_conversion_type = 'User' THEN
          IF l_currency_conversion_rate IS NULL THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_CURR_USER_RATE_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_contract_number);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
        ELSE
          l_currency_conversion_rate := OKL_ACCOUNTING_UTIL.get_curr_con_rate
                                          (p_from_curr_code => l_currency_code,
                                           p_to_curr_code => l_func_currency_code,
                                           p_con_date => p_acceleration_rec.acceleration_date, --Bug #5410825
                                           p_con_type => l_currency_conversion_type);
          IF l_currency_conversion_rate IS NULL THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_CURR_RATE_ERROR',
                                p_token1       => 'CONVERSION_TYPE',
                                p_token1_value => l_currency_conversion_type,
                                p_token2       => 'FROM_CURRENCY',
                                p_token2_value => l_currency_code,
                                p_token3       => 'TO_CURRENCY',
                                p_token3_value => l_func_currency_code
                               );
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
        l_currency_conversion_date := p_acceleration_rec.acceleration_date; --Bug #5410825
	END IF;
      END IF;

      -- build the transaction record
      l_accrual_rec.contract_id         := p_acceleration_rec.khr_id;
      l_accrual_rec.set_of_books_id     := l_sob_id;
      l_accrual_rec.accrual_date        := p_acceleration_rec.acceleration_date;
 	  l_accrual_rec.trx_date            := p_acceleration_rec.acceleration_date;
      l_accrual_rec.contract_number     := l_contract_number;
      l_accrual_rec.description         := p_acceleration_rec.description;
  	  l_accrual_rec.amount              := l_total;
      l_accrual_rec.currency_code       := l_currency_code;
      l_accrual_rec.currency_conversion_type := l_currency_conversion_type;
      l_accrual_rec.currency_conversion_rate := l_currency_conversion_rate;
      l_accrual_rec.currency_conversion_date := l_currency_conversion_date;
      l_accrual_rec.product_id          := l_product_id;
      IF (p_representation_type = 'SECONDARY') THEN --MGAAP 7263041
        l_accrual_rec.product_id          := l_reporting_pdt_id;
      END IF;
      l_accrual_rec.trx_type_id         := l_try_id;
      l_accrual_rec.advance_arrears     := l_billing_type;
      l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
      l_accrual_rec.post_to_gl          := 'Y';
      l_accrual_rec.gl_reversal_flag    := 'N';
      l_accrual_rec.accrual_rule_yn     := p_acceleration_rec.accrual_rule_yn;
      l_accrual_rec.trx_number := p_acceleration_rec.trx_number; --MGAAP 7263041

      IF p_acceleration_rec.accrual_rule_yn = 'Y' THEN
        -- Validate contract against accrual rule and get the result
        VALIDATE_ACCRUAL_RULE(x_return_status => l_return_status
                             ,x_result => l_rule_result
                             ,p_ctr_id => p_acceleration_rec.khr_id);
        -- store the highest degree of error
        IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_RULE_VALD_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => l_contract_number);
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        l_accrual_rec.rule_result         := l_rule_result;
        l_accrual_rec.override_status     := l_override_status;

        IF l_override_status = 'N' THEN
          IF l_rule_result = 'Y' THEN
          -- create accruals
            l_accrual_rec.memo_yn             := 'N';
            l_accrual_rec.accrual_activity    := 'ACCRUAL';
          ELSIF l_rule_result = 'N' THEN
          -- create non-accruals
            l_accrual_rec.memo_yn             := 'Y';
            l_accrual_rec.accrual_activity    := 'NON-ACCRUAL';
		  END IF;
        ELSIF l_override_status = 'Y' THEN
        -- create non-accruals
          l_accrual_rec.memo_yn             := 'Y';
          l_accrual_rec.accrual_activity    := 'NON-ACCRUAL';
        END IF;
      ELSE
        -- create accruals
        l_accrual_rec.memo_yn             := 'N';
        l_accrual_rec.accrual_activity    := 'ACCRUAL';
	  END IF;

      -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
      CREATE_ACCRUALS (
                    p_api_version => l_api_version,
                	p_init_msg_list => p_init_msg_list,
                    x_return_status => l_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data,
                    x_tcnv_rec => l_tcnv_rec,
                    x_tclv_tbl => l_tclv_tbl,
                    p_accrual_rec => l_accrual_rec,
                    p_stream_tbl => l_stream_tbl,
                    p_representation_type => p_representation_type); --MGAAP 7263041

      x_trx_number := l_tcnv_rec.trx_number; --MGAAP 7263041
      IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    END IF; -- IF l_stream_tbl.COUNT > 0

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END ACCELERATE_ACCRUALS;

  PROCEDURE REVERSE_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    p_reverse_rec IN accrual_rec_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_rev_tcnv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
    x_rev_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    x_memo_tcnv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
    x_memo_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY'  -- MGAAP 7263041
  ) IS

    -- local variables
    l_tcnv_rec                  OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
    l_tcnv_tbl                  OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type;
    l_tclv_tbl                  OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
    l_source_id_tbl             Okl_Reversal_Pub.source_id_tbl_type;
    l_api_name                  VARCHAR2(20) := 'REVERSE_ACCRUALS';
    l_api_version               CONSTANT NUMBER := 1.0;
	l_tcn_type                  OKL_TRX_CONTRACTS.TCN_TYPE%TYPE := 'ACL';
	l_tcl_type                  OKL_TXL_CNTRCT_LNS.TCL_TYPE%TYPE := 'ACL';
        --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
	l_tsu_code_ent              OKL_TRX_CONTRACTS.TSU_CODE%TYPE := 'PROCESSED';
	l_tsu_code_can              OKL_TRX_CONTRACTS.TSU_CODE%TYPE := 'CANCELED';
	l_accrual_activity          OKL_TRX_CONTRACTS.ACCRUAL_ACTIVITY%TYPE := 'ACCRUAL';
	l_non_accrual_activity      OKL_TRX_CONTRACTS.ACCRUAL_ACTIVITY%TYPE := 'NON-ACCRUAL';
	l_reversal_activity         OKL_TRX_CONTRACTS.ACCRUAL_ACTIVITY%TYPE := 'REVERSAL';
    l_source_table              OKL_TRNS_ACC_DSTRS.SOURCE_TABLE%TYPE := 'OKL_TXL_CNTRCT_LNS';
    l_tmpl_identify_rec         Okl_Account_Dist_Pub.tmpl_identify_rec_type;
    l_dist_info_rec             Okl_Account_Dist_Pub.dist_info_rec_type;
    l_ctxt_val_tbl              Okl_Account_Dist_Pub.ctxt_val_tbl_type;
    l_template_tbl              Okl_Account_Dist_Pub.avlv_tbl_type;
    l_amount_tbl                Okl_Account_Dist_Pub.amount_tbl_type;
    l_acc_gen_primary_key_tbl   Okl_Account_Dist_Pub.acc_gen_primary_key;
    l_accrual_rec               accrual_rec_type;
    l_stream_tbl                stream_tbl_type;
	l_count                     NUMBER := 1;
    i                           NUMBER := 1;

	-- Cursor to select transaction headers for reversal
    -- modified cursor for bug# 2455956
    -- removed to_date function in between statement as parameters are already of date datatype.
    CURSOR reverse_trx_csr(p_khr_id NUMBER,  p_reversal_date_to DATE, p_reversal_date_from DATE) IS
    SELECT id, transaction_date,
           trx_number  -- MGAAP 7263041
    FROM OKL_TRX_CONTRACTS
    WHERE khr_id = p_khr_id
    AND TRUNC(date_transaction_occurred) BETWEEN TRUNC(p_reversal_date_to) AND TRUNC(p_reversal_date_from)
    AND tsu_code = l_tsu_code_ent
    AND tcn_type = l_tcn_type
	/* AND accrual_activity = l_accrual_activity */ -- MGAAP 7263041
    AND representation_type = p_representation_type; -- MGAAP 7263041

    -- Cursor to select transaction lines for reversal (for source id)
    -- Modifying below cursor for Bug# 2455956
    CURSOR reverse_txl_csr(p_tcn_id NUMBER) IS
    SELECT id
    FROM OKL_TXL_CNTRCT_LNS
    WHERE tcn_id = p_tcn_id;

    -- Cursor to populate stream table with amounts and sty_id for creating memo Revenue
	CURSOR stream_tbl_csr (p_tcn_id NUMBER) IS
	SELECT sty_id, amount, kle_id
	FROM OKL_TXL_CNTRCT_LNS
	WHERE tcn_id = p_tcn_id;

  BEGIN
    -- Set save point
    WRITE_TO_LOG('Inside the REVERSE_ACCRUALS call');
    WRITE_TO_LOG('Printing out the contents of p_reverse_rec :');
    WRITE_TO_LOG('============================================');
    WRITE_TO_LOG('p_reverse_rec.contract_id         :'||p_reverse_rec.contract_id);
	WRITE_TO_LOG('p_reverse_rec.accrual_date        :'||p_reverse_rec.accrual_date);
    WRITE_TO_LOG('p_reverse_rec.contract_number     :'||p_reverse_rec.contract_number);
	WRITE_TO_LOG('p_reverse_rec.rule_result         :'||p_reverse_rec.rule_result);
	WRITE_TO_LOG('p_reverse_rec.override_status     :'||p_reverse_rec.override_status);
	WRITE_TO_LOG('p_reverse_rec.product_id          :'||p_reverse_rec.product_id);
	WRITE_TO_LOG('p_reverse_rec.trx_type_id         :'||p_reverse_rec.trx_type_id);
    WRITE_TO_LOG('p_reverse_rec.advance_arrears     :'||p_reverse_rec.advance_arrears);
	WRITE_TO_LOG('p_reverse_rec.factoring_synd_flag :'||p_reverse_rec.factoring_synd_flag);
	WRITE_TO_LOG('p_reverse_rec.post_to_gl          :'||p_reverse_rec.post_to_gl);
	WRITE_TO_LOG('p_reverse_rec.gl_reversal_flag    :'||p_reverse_rec.gl_reversal_flag);
	WRITE_TO_LOG('p_reverse_rec.memo_yn             :'||p_reverse_rec.memo_yn);
	WRITE_TO_LOG('p_reverse_rec.description         :'||p_reverse_rec.description);
	WRITE_TO_LOG('p_reverse_rec.accrual_activity    :'||p_reverse_rec.accrual_activity);

    x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- Reverse transactions and accounting for number of days setup by the user
    -- Open reverse trx cursor to find out transaction id's TO REVERSE IN CASE OF non-accrual
    FOR l_reverse_trx_csr IN reverse_trx_csr(p_reverse_rec.contract_id, p_reverse_rec.reverse_date_to, p_reverse_rec.accrual_date )
    LOOP
      l_tcnv_tbl(i).id := l_reverse_trx_csr.id;
      l_tcnv_tbl(i).tsu_code := l_tsu_code_can;
      l_tcnv_tbl(i).accrual_activity := l_reversal_activity;
       -- sosharma added for income recon report
          l_tcnv_tbl(i).transaction_reversal_date := SYSDATE;
	  l_tcnv_tbl(i).canceled_date := p_reverse_rec.accrual_date;
      l_tcnv_tbl(i).transaction_date := l_reverse_trx_csr.transaction_date;
      IF (p_representation_type = 'PRIMARY') THEN
        G_trx_number_tbl(i).old_trx_number := l_reverse_trx_csr.trx_number;
      END IF;
      i := i + 1;
      -- Open reverse txl cursor to find out transaction line id's for reversal
      FOR l_reverse_txl_csr IN reverse_txl_csr(l_reverse_trx_csr.id)
      LOOP
        l_source_id_tbl(l_count) := l_reverse_txl_csr.id;
        l_count := l_count + 1;
      END LOOP;
    END LOOP;

    -- Check if records were found for reversal
    IF l_tcnv_tbl.COUNT > 0 THEN

        WRITE_TO_LOG('Records were identified for reversal');
        WRITE_TO_LOG('Prior to the call to Okl_Reversal_Pub.REVERSE_ENTRIES');
      -- Call the Reverse Accounting API
      Okl_Reversal_Pub.REVERSE_ENTRIES(
          p_api_version => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data,
          p_source_table => l_source_table,
	      p_acct_date => p_reverse_rec.accrual_date,
          p_source_id_tbl => l_source_id_tbl);
        WRITE_TO_LOG('Return status after the call to Okl_Reversal_Pub.REVERSE_ENTRIES :'||x_return_status);
      -- store the highest degree of error
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_REV_DIST_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => p_reverse_rec.contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          -- record that there was an error
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_REV_DIST_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_reverse_rec.contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      WRITE_TO_LOG('Prior to the call to Okl_Trx_Contracts_Pub.update_trx_contracts');
      --Call the transaction public api for update
      Okl_Trx_Contracts_Pub.update_trx_contracts
                     (p_api_version => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count => x_msg_count,
                      x_msg_data => x_msg_data,
                      p_tcnv_tbl => l_tcnv_tbl,
                      x_tcnv_tbl => x_rev_tcnv_tbl);
      WRITE_TO_LOG('Return status after the call to Okl_Trx_Contracts_Pub.update_trx_contracts :'||x_return_status);

      -- store the highest degree of error
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_TRX_UPD_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_reverse_rec.contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          -- record that there was an error
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_TRX_UPD_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_reverse_rec.contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      -- Create a new trasaction for the reversed transaction to reflect memo entries
      FOR i IN x_rev_tcnv_tbl.FIRST..x_rev_tcnv_tbl.LAST
	  LOOP
        -- Build the accrual record
        l_accrual_rec.contract_id         := x_rev_tcnv_tbl(i).khr_id;
        l_accrual_rec.set_of_books_id     := x_rev_tcnv_tbl(i).set_of_books_id;
        l_accrual_rec.accrual_date        := x_rev_tcnv_tbl(i).date_accrual;
  	    l_accrual_rec.trx_date            := p_reverse_rec.accrual_date;
        l_accrual_rec.contract_number     := p_reverse_rec.contract_number;
        l_accrual_rec.rule_result         := p_reverse_rec.rule_result;
        l_accrual_rec.override_status     := p_reverse_rec.override_status;
        l_accrual_rec.description         := p_reverse_rec.description||' '||
	                                       FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE');
        l_accrual_rec.amount              := x_rev_tcnv_tbl(i).amount;
   	    l_accrual_rec.currency_code       := x_rev_tcnv_tbl(i).currency_code;
   	    l_accrual_rec.currency_conversion_type := x_rev_tcnv_tbl(i).currency_conversion_type;
   	    l_accrual_rec.currency_conversion_rate := x_rev_tcnv_tbl(i).currency_conversion_rate;
   	    l_accrual_rec.currency_conversion_date := x_rev_tcnv_tbl(i).currency_conversion_date;
        l_accrual_rec.product_id          := x_rev_tcnv_tbl(i).pdt_id;
        l_accrual_rec.trx_type_id         := x_rev_tcnv_tbl(i).try_id;
        l_accrual_rec.advance_arrears     := p_reverse_rec.advance_arrears;
        l_accrual_rec.factoring_synd_flag := p_reverse_rec.factoring_synd_flag;
        l_accrual_rec.post_to_gl          := p_reverse_rec.post_to_gl;
        l_accrual_rec.gl_reversal_flag    := p_reverse_rec.gl_reversal_flag;
        l_accrual_rec.memo_yn             := p_reverse_rec.memo_yn;
        l_accrual_rec.accrual_activity    := l_non_accrual_activity;
        l_accrual_rec.accrual_rule_yn     := 'Y';
        -- MGAAP start 7263041
        --l_accrual_rec.trx_number          := p_reverse_rec.trx_number;
        --l_accrual_rec.primary_rep_trx_id  := p_reverse_rec.primary_rep_trx_id;
      -- MGAAP start
      IF (p_representation_type = 'SECONDARY') THEN
      /* Get new trx number and primary rep trx id using old_trx_number
         from  x_rev_tcnv_tbl(i).trx_number */
         null;
         G_trx_number_tbl_cnt := G_trx_number_tbl.count;
         IF (G_trx_number_tbl_cnt > 0) THEN
           FOR rcnt IN G_trx_number_tbl.FIRST..G_trx_number_tbl.LAST
           LOOP
             IF (G_trx_number_tbl(rcnt).old_trx_number=x_rev_tcnv_tbl(i).trx_number) THEN
               l_accrual_rec.trx_number:= G_trx_number_tbl(rcnt).new_trx_number;
               l_accrual_rec.primary_rep_trx_id:= G_trx_number_tbl(rcnt).id;
               EXIT;
             END IF;
           END LOOP;
         END IF;
      END IF;
       -- MGAAP end 7263041

        l_count := 1;
        -- Populate stream table for CREATE_ACCRUALS procedure
	    FOR x IN stream_tbl_csr(x_rev_tcnv_tbl(i).id)
	    LOOP
          l_stream_tbl(l_count).stream_type_id := x.sty_id;
          l_stream_tbl(l_count).stream_amount := x.amount;
          l_stream_tbl(l_count).kle_id := x.kle_id;
          l_count := l_count + 1;
	    END LOOP;

        -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
        CREATE_ACCRUALS (
                    p_api_version => l_api_version,
                	p_init_msg_list => p_init_msg_list,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data,
                    x_tcnv_rec => l_tcnv_rec,
                    x_tclv_tbl => l_tclv_tbl,
                    p_accrual_rec => l_accrual_rec,
                    p_stream_tbl => l_stream_tbl,
                    p_representation_type => p_representation_type); -- MGAAP 7263041
        -- store the highest degree of error
        IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => p_reverse_rec.contract_number);
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => p_reverse_rec.contract_number);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

      -- MGAAP start 7263041
      IF (p_representation_type = 'PRIMARY') THEN
        G_trx_number_tbl(i).new_trx_number := l_tcnv_rec.trx_number;
        G_trx_number_tbl(i).ID := l_tcnv_rec.ID;
      END IF;
      -- MGAAP end 7263041

        -- 26-Sep-2005. SGIYER. Bug 4616770
        -- re-initialize l_stream_tbl everytime.
        l_stream_tbl.DELETE;

        x_memo_tcnv_tbl(i) := l_tcnv_rec;

	  END LOOP;
    END IF; -- for l_tcnv_tbl.count > 0;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END REVERSE_ACCRUALS;

  PROCEDURE REVERSE_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    p_reverse_rec IN accrual_rec_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_tcnv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
    x_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY'
  ) IS

    x_rev_tcnv_tbl OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type;
	x_rev_tclv_tbl OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;

  BEGIN

    REVERSE_ACCRUALS (
	    p_api_version => p_api_version,
		p_init_msg_list => p_init_msg_list,
		p_reverse_rec => p_reverse_rec,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data,
		x_rev_tcnv_tbl => x_rev_tcnv_tbl,
		x_rev_tclv_tbl => x_rev_tclv_tbl,
		x_memo_tcnv_tbl => x_tcnv_tbl,
		x_memo_tclv_tbl => x_tclv_tbl,
		p_representation_type => p_representation_type); -- MGAAP 7263041

  END;

  -- for prior dated and future dated reversal
  PROCEDURE REVERSE_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_khr_id IN NUMBER,
    p_reversal_date IN DATE,
    p_accounting_date IN DATE,
    p_reverse_from IN DATE,
    p_reverse_to IN DATE,
    p_tcn_type IN VARCHAR2) IS

    -- local variables
    l_api_name                  CONSTANT VARCHAR2(30) := 'REVERSE_ACCRUALS';
    l_api_version               CONSTANT NUMBER := 1.0;
        --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
	l_tsu_code_ent              OKL_TRX_CONTRACTS.TSU_CODE%TYPE := 'PROCESSED';
	l_tsu_code_can              OKL_TRX_CONTRACTS.TSU_CODE%TYPE := 'CANCELED';
	l_reversal_activity         OKL_TRX_CONTRACTS.ACCRUAL_ACTIVITY%TYPE := 'REVERSAL';
    l_source_id_tbl             Okl_Reversal_Pub.source_id_tbl_type;
    l_source_table              OKL_TRNS_ACC_DSTRS.SOURCE_TABLE%TYPE := 'OKL_TXL_CNTRCT_LNS';
    l_tcnv_tbl                  OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type;
    x_tcnv_tbl                  OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type;
    l_contract_number           VARCHAR2(2000);
    l_tcn_type                  VARCHAR2(2000) := p_tcn_type;
    l_count1                    NUMBER := 1;
	l_count2                    NUMBER := 1;

	-- Cursor to select Contract Number
	CURSOR get_contract_number_csr(p_ctr_id NUMBER) IS
    SELECT contract_number
    FROM OKC_K_HEADERS_B
    WHERE id = p_ctr_id;

	-- Cursor to select accrual transactions for cancellation using specified tcn_type
    CURSOR reverse_trx_csr IS
    SELECT trx.id,trx.transaction_date
    FROM OKL_TRX_CONTRACTS trx, okl_trx_types_v typ
    WHERE trx.khr_id = p_khr_id
    AND trx.tsu_code = l_tsu_code_ent
    AND trx.tcn_type = NVL(p_tcn_type,trx.tcn_type)
    AND trx.try_id = typ.id
    AND typ.name = 'Accrual'
    AND TRUNC(trx.date_transaction_occurred) >= TRUNC(p_reverse_from)
    AND TRUNC(trx.date_transaction_occurred) <= NVL(TRUNC(p_reverse_to), TRUNC(trx.date_transaction_occurred));
    --AND trx.REPRESENTATION_TYPE = 'PRIMARY'; --MGAAP 7263041

    -- Cursor to select transaction lines for reversal (for source id)
    CURSOR reverse_txl_csr(p_tcn_id NUMBER) IS
    SELECT id
    FROM OKL_TXL_CNTRCT_LNS
    WHERE tcn_id = p_tcn_id;

  BEGIN
    -- Set save point
    x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --Validate in parameters
    IF p_khr_id IS NULL OR p_khr_id = OKL_API.G_MISS_NUM THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_KHR_ID_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_reversal_date IS NULL OR p_reversal_date = OKL_API.G_MISS_DATE THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_REV_DATE_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_accounting_date IS NULL OR p_accounting_date = OKL_API.G_MISS_DATE THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_ACC_DATE_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_reverse_from IS NULL OR p_reverse_from = OKL_API.G_MISS_DATE THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FROM_DATE_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get contract_number
    OPEN get_contract_number_csr(p_khr_id);
	FETCH get_contract_number_csr INTO l_contract_number;
	CLOSE get_contract_number_csr;

    IF l_contract_number IS NULL THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Open reverse trx cursor
    FOR l_reverse_trx_csr IN reverse_trx_csr
    LOOP

      l_tcnv_tbl(l_count1).id := l_reverse_trx_csr.id;
      l_tcnv_tbl(l_count1).tsu_code := l_tsu_code_can;
      l_tcnv_tbl(l_count1).accrual_activity := l_reversal_activity;
        -- sosharma added for income recon report
          l_tcnv_tbl(l_count1).transaction_reversal_date := SYSDATE;
	  l_tcnv_tbl(l_count1).canceled_date := p_reversal_date;
      l_tcnv_tbl(l_count1).transaction_date := l_reverse_trx_csr.transaction_date;
      l_count1 := l_count1 + 1;
      -- Open reverse txl cursor to find out transaction line id's for reversal
      FOR l_reverse_txl_csr IN reverse_txl_csr(l_reverse_trx_csr.id)
      LOOP
        l_source_id_tbl(l_count2) := l_reverse_txl_csr.id;
        l_count2 := l_count2 + 1;
      END LOOP;
    END LOOP;

    -- Check if records were found for reversal
    IF l_tcnv_tbl.COUNT > 0 THEN
      -- Call the Reverse Accounting API
      Okl_Reversal_Pub.REVERSE_ENTRIES(
          p_api_version => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data,
          p_source_table => l_source_table,
	      p_acct_date => p_accounting_date,
          p_source_id_tbl => l_source_id_tbl);
      -- store the highest degree of error
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_REV_DIST_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          -- record that there was an error
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_REV_DIST_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      --Call the transaction public api for update
      Okl_Trx_Contracts_Pub.update_trx_contracts
                     (p_api_version => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count => x_msg_count,
                      x_msg_data => x_msg_data,
                      p_tcnv_tbl => l_tcnv_tbl,
                      x_tcnv_tbl => x_tcnv_tbl);
      -- store the highest degree of error
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_TRX_UPD_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          -- record that there was an error
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_TRX_UPD_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    END IF; -- for l_tcnv_tbl.count > 0;

    -- MGAAP 7263041
    /*
    IF l_tcnv_tbl.COUNT > 0 THEN

          OKL_MULTIGAAP_ENGINE_PVT.REVERSE_SEC_REP_TRX
                         (p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_tcnv_tbl => l_tcnv_tbl);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

       END IF; */

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END REVERSE_ACCRUALS;

--Bug 2838167. Creating new procedure for call within rebook.
  PROCEDURE REVERSE_ALL_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    p_khr_id IN NUMBER,
    p_reverse_date IN DATE,
    p_description IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2
  ) IS

    -- local variables
    l_api_name                  CONSTANT VARCHAR2(30) := 'REVERSE_ALL_ACCRUALS';
    l_api_version               CONSTANT NUMBER := 1.0;
	l_tcn_type                  OKL_TRX_CONTRACTS.TCN_TYPE%TYPE := 'ACL';
	l_tcl_type                  OKL_TXL_CNTRCT_LNS.TCL_TYPE%TYPE := 'ACL';
        --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
	l_tsu_code_ent              OKL_TRX_CONTRACTS.TSU_CODE%TYPE := 'PROCESSED';
	l_tsu_code_can              OKL_TRX_CONTRACTS.TSU_CODE%TYPE := 'CANCELED';
	l_reversal_activity         OKL_TRX_CONTRACTS.ACCRUAL_ACTIVITY%TYPE := 'REVERSAL';
    l_source_id_tbl             Okl_Reversal_Pub.source_id_tbl_type;
    l_source_table              OKL_TRNS_ACC_DSTRS.SOURCE_TABLE%TYPE := 'OKL_TXL_CNTRCT_LNS';
    l_tcnv_tbl                  OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type;
    x_tcnv_tbl                  OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type;
	l_count                     NUMBER := 1;
	l_count2                    NUMBER := 1;
    l_contract_number           VARCHAR2(2000);

	-- Cursor to select Contract Number
	CURSOR get_contract_number_csr(p_ctr_id NUMBER) IS
    SELECT contract_number
    FROM OKC_K_HEADERS_B
    WHERE id = p_ctr_id;

	-- Cursor to select accrual transactions for cancellation
    CURSOR reverse_trx_csr(p_khr_id NUMBER) IS
    SELECT id, transaction_date
    FROM OKL_TRX_CONTRACTS
    WHERE khr_id = p_khr_id
    AND tsu_code = l_tsu_code_ent
    AND tcn_type = l_tcn_type;
    --AND representation_type = 'PRIMARY';  --MGAAP 7263041

    -- Cursor to select transaction lines for reversal (for source id)
    CURSOR reverse_txl_csr(p_tcn_id NUMBER) IS
    SELECT id
    FROM OKL_TXL_CNTRCT_LNS
    WHERE tcn_id = p_tcn_id;

  BEGIN
    -- Set save point
    x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --Validate in parameters
    IF p_khr_id IS NULL OR p_khr_id = OKL_API.G_MISS_NUM THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_KHR_ID_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_reverse_date IS NULL OR p_reverse_date = OKL_API.G_MISS_DATE THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_ACC_DATE_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get contract_number
    OPEN get_contract_number_csr(p_khr_id);
	FETCH get_contract_number_csr INTO l_contract_number;
	CLOSE get_contract_number_csr;

    -- Reverse all transactions and accounting
    -- Open reverse trx cursor
    FOR l_reverse_trx_csr IN reverse_trx_csr(p_khr_id)
    LOOP

      l_tcnv_tbl(l_count).id := l_reverse_trx_csr.id;
      l_tcnv_tbl(l_count).tsu_code := l_tsu_code_can;
      l_tcnv_tbl(l_count).accrual_activity := l_reversal_activity;
       -- sosharma added for income recon report
         l_tcnv_tbl(l_count).transaction_reversal_date := SYSDATE;
      l_tcnv_tbl(l_count).description := p_description;
	  l_tcnv_tbl(l_count).canceled_date := p_reverse_date;
      l_tcnv_tbl(l_count).transaction_date := l_reverse_trx_csr.transaction_date;
      l_count := l_count + 1;
      -- Open reverse txl cursor to find out transaction line id's for reversal
      FOR l_reverse_txl_csr IN reverse_txl_csr(l_reverse_trx_csr.id)
      LOOP
        l_source_id_tbl(l_count2) := l_reverse_txl_csr.id;
        l_count2 := l_count2 + 1;
      END LOOP;
    END LOOP;

    -- Check if records were found for reversal
    IF l_tcnv_tbl.COUNT > 0 THEN
      -- Call the Reverse Accounting API
      Okl_Reversal_Pub.REVERSE_ENTRIES(
          p_api_version => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data,
          p_source_table => l_source_table,
	      p_acct_date => p_reverse_date,
          p_source_id_tbl => l_source_id_tbl);
      -- store the highest degree of error
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_REV_DIST_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          -- record that there was an error
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_REV_DIST_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      --Call the transaction public api for update
      Okl_Trx_Contracts_Pub.update_trx_contracts
                     (p_api_version => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count => x_msg_count,
                      x_msg_data => x_msg_data,
                      p_tcnv_tbl => l_tcnv_tbl,
                      x_tcnv_tbl => x_tcnv_tbl);
      -- store the highest degree of error
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_TRX_UPD_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          -- record that there was an error
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_TRX_UPD_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    END IF; -- for l_tcnv_tbl.count > 0;

    -- MGAAP 7263041
    /*
    IF l_tcnv_tbl.COUNT > 0 THEN

          OKL_MULTIGAAP_ENGINE_PVT.REVERSE_SEC_REP_TRX
                         (p_api_version => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_tcnv_tbl => l_tcnv_tbl);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

    END IF; */

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END REVERSE_ALL_ACCRUALS;

  PROCEDURE CATCHUP_ACCRUALS (
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_catchup_rec IN accrual_rec_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_rev_tcnv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
    x_rev_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    x_catch_tcnv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
    x_catch_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY' --MGAAP 7263041
    ) IS

    -- local variables
    l_tcnv_rec                   OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
    l_tcnv_tbl                   OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type;
    l_tclv_tbl                   OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
    l_source_id_tbl              Okl_Reversal_Pub.source_id_tbl_type;
    l_tmpl_identify_rec          Okl_Account_Dist_Pub.tmpl_identify_rec_type;
    l_dist_info_rec              Okl_Account_Dist_Pub.dist_info_rec_type;
    l_ctxt_val_tbl               Okl_Account_Dist_Pub.ctxt_val_tbl_type;
    l_template_tbl               Okl_Account_Dist_Pub.avlv_tbl_type;
    l_amount_tbl                 Okl_Account_Dist_Pub.amount_tbl_type;
    l_acc_gen_primary_key_tbl    Okl_Account_Dist_Pub.acc_gen_primary_key;
    l_catchup_trx_tbl            Okl_Trx_Contracts_Pub.tcnv_tbl_type;
	l_tcn_type                   OKL_TRX_CONTRACTS.TCN_TYPE%TYPE := 'ACL';
	l_tcl_type                   OKL_TXL_CNTRCT_LNS.TCL_TYPE%TYPE := 'ACL';
        --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
	l_tsu_code_ent               OKL_TRX_CONTRACTS.TSU_CODE%TYPE := 'PROCESSED';
	l_tsu_code_can               OKL_TRX_CONTRACTS.TSU_CODE%TYPE := 'CANCELED';
	l_non_accrual_activity       OKL_TRX_CONTRACTS.ACCRUAL_ACTIVITY%TYPE := 'NON-ACCRUAL';
	l_catchup_activity           OKL_TRX_CONTRACTS.ACCRUAL_ACTIVITY%TYPE := 'CATCH-UP';
	l_reversal_activity          OKL_TRX_CONTRACTS.ACCRUAL_ACTIVITY%TYPE := 'REVERSAL';
    l_source_table               OKL_TRNS_ACC_DSTRS.SOURCE_TABLE%TYPE := 'OKL_TXL_CNTRCT_LNS';
    l_api_name                  VARCHAR2(20) := 'CATCHUP_ACCRUALS';
    l_api_version               CONSTANT NUMBER := 1.0;
    l_accrual_rec               accrual_rec_type;
    l_stream_tbl                stream_tbl_type;
	l_count                     NUMBER := 1;
	l_count2                    NUMBER := 1;

	-- Cursor to select transaction headers for accrual catchup
    CURSOR catchup_trx_csr(p_khr_id NUMBER) IS
    SELECT id, transaction_date,
           trx_number -- MGAAP 7263041
    FROM OKL_TRX_CONTRACTS
    WHERE khr_id = p_khr_id
    AND tcn_type = l_tcn_type
	AND tsu_code = l_tsu_code_ent
	AND accrual_activity = l_non_accrual_activity
    AND representation_type = p_representation_type; -- MGAAP 7263041

    -- Cursor to select transaction lines for accrual catchup
    CURSOR catchup_txl_csr(p_tcn_id NUMBER) IS
    SELECT id
    FROM OKL_TXL_CNTRCT_LNS
    WHERE tcn_id = p_tcn_id;

    -- Cursor to populate stream table with amounts ad sty_id for creating memo Revenue
	CURSOR stream_tbl_csr (p_tcn_id NUMBER) IS
	SELECT sty_id, amount, kle_id
	FROM OKL_TXL_CNTRCT_LNS
	WHERE tcn_id = p_tcn_id;

  BEGIN
    WRITE_TO_LOG('Inside the CATCHUP_ACCRUALS call');
    WRITE_TO_LOG('Printing out the contents of p_catchup_rec :');
    WRITE_TO_LOG('============================================');
    WRITE_TO_LOG('p_catchup_rec.contract_id         :'||p_catchup_rec.contract_id);
	WRITE_TO_LOG('p_catchup_rec.accrual_date        :'||p_catchup_rec.accrual_date);
    WRITE_TO_LOG('p_catchup_rec.contract_number     :'||p_catchup_rec.contract_number);
	WRITE_TO_LOG('p_catchup_rec.rule_result         :'||p_catchup_rec.rule_result);
	WRITE_TO_LOG('p_catchup_rec.override_status     :'||p_catchup_rec.override_status);
	WRITE_TO_LOG('p_catchup_rec.product_id          :'||p_catchup_rec.product_id);
	WRITE_TO_LOG('p_catchup_rec.trx_type_id         :'||p_catchup_rec.trx_type_id);
    WRITE_TO_LOG('p_catchup_rec.advance_arrears     :'||p_catchup_rec.advance_arrears);
	WRITE_TO_LOG('p_catchup_rec.factoring_synd_flag :'||p_catchup_rec.factoring_synd_flag);
	WRITE_TO_LOG('p_catchup_rec.post_to_gl          :'||p_catchup_rec.post_to_gl);
	WRITE_TO_LOG('p_catchup_rec.gl_reversal_flag    :'||p_catchup_rec.gl_reversal_flag);
	WRITE_TO_LOG('p_catchup_rec.memo_yn             :'||p_catchup_rec.memo_yn);
	WRITE_TO_LOG('p_catchup_rec.description         :'||p_catchup_rec.description);
	WRITE_TO_LOG('p_catchup_rec.accrual_activity    :'||p_catchup_rec.accrual_activity);
    -- Set save point
    x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    FOR l_catchup_trx_csr IN catchup_trx_csr(p_catchup_rec.contract_id)
    LOOP
      l_tcnv_tbl(l_count).id := l_catchup_trx_csr.id;
      l_tcnv_tbl(l_count).tsu_code := l_tsu_code_can;
      l_tcnv_tbl(l_count).accrual_activity := l_reversal_activity;
       -- sosharma added for income recon report
         l_tcnv_tbl(l_count).transaction_reversal_date := SYSDATE;
	  l_tcnv_tbl(l_count).canceled_date := p_catchup_rec.accrual_date;
      l_tcnv_tbl(l_count).transaction_date := l_catchup_trx_csr.transaction_date;
      IF (p_representation_type = 'PRIMARY') THEN
        G_trx_number_tbl(l_count).old_trx_number := l_catchup_trx_csr.trx_number;
      END IF;
      l_count := l_count + 1;
      -- Process txl id's FOR catchup
      FOR l_catchup_txl_csr IN catchup_txl_csr(l_catchup_trx_csr.id)
      LOOP
        l_source_id_tbl(l_count2) := l_catchup_txl_csr.id;
        l_count2 := l_count2 + 1;
      END LOOP;
    END LOOP;

    -- Proceed if records are available for processing
    IF l_tcnv_tbl.COUNT > 0 THEN
        WRITE_TO_LOG('Records were identified for catchup');
        WRITE_TO_LOG('Prior to the call to Okl_Reversal_Pub.REVERSE_ENTRIES');

    -- Call the Reverse Accounting API
    Okl_Reversal_Pub.REVERSE_ENTRIES(
          p_api_version => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data,
          p_source_table => l_source_table,
	      p_acct_date => p_catchup_rec.accrual_date,
          p_source_id_tbl => l_source_id_tbl);
         WRITE_TO_LOG('Return status after the call to Okl_Reversal_Pub.REVERSE_ENTRIES :'||x_return_status);

    -- store the highest degree of error
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_REV_DIST_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_catchup_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        -- record that there was an error
        Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_REV_DIST_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_catchup_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    WRITE_TO_LOG('Prior to the call to Okl_Trx_Contracts_Pub.update_trx_contracts');
    --Call the transaction public api for update
    Okl_Trx_Contracts_Pub.update_trx_contracts
                     (p_api_version => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count => x_msg_count,
                      x_msg_data => x_msg_data,
                      p_tcnv_tbl => l_tcnv_tbl,
                      x_tcnv_tbl => x_rev_tcnv_tbl);
    WRITE_TO_LOG('Return status after the call to Okl_Trx_Contracts_Pub.update_trx_contracts :'||x_return_status);

    -- store the highest degree of error
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_TRX_UPD_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => p_catchup_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        -- record that there was an error
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_TRX_UPD_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => p_catchup_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- Bug 4634293. Moving below initialization inside loop. Commenting below line.
    --l_count := 1;
    -- Create a new trasaction for the reversed transaction to reflect actual revenue entries
    FOR i IN x_rev_tcnv_tbl.FIRST..x_rev_tcnv_tbl.LAST
	LOOP
      -- Build the accrual record
      l_accrual_rec.contract_id         := x_rev_tcnv_tbl(i).khr_id;
      l_accrual_rec.set_of_books_id     := x_rev_tcnv_tbl(i).set_of_books_id;
      l_accrual_rec.accrual_date        := x_rev_tcnv_tbl(i).date_accrual;
  	  l_accrual_rec.trx_date            := p_catchup_rec.accrual_date;
      l_accrual_rec.contract_number     := p_catchup_rec.contract_number;
      l_accrual_rec.rule_result         := p_catchup_rec.rule_result;
      l_accrual_rec.override_status     := p_catchup_rec.override_status;
      l_accrual_rec.description         := p_catchup_rec.description||' '||
	                                       FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CATCHUP_REVENUE');
	  l_accrual_rec.amount              := x_rev_tcnv_tbl(i).amount;
   	  l_accrual_rec.currency_code       := x_rev_tcnv_tbl(i).currency_code;
      l_accrual_rec.currency_conversion_type := x_rev_tcnv_tbl(i).currency_conversion_type;
      l_accrual_rec.currency_conversion_rate := x_rev_tcnv_tbl(i).currency_conversion_rate;
      l_accrual_rec.currency_conversion_date := x_rev_tcnv_tbl(i).currency_conversion_date;
      l_accrual_rec.product_id          := x_rev_tcnv_tbl(i).pdt_id;
      l_accrual_rec.trx_type_id         := x_rev_tcnv_tbl(i).try_id;
      l_accrual_rec.advance_arrears     := p_catchup_rec.advance_arrears;
      l_accrual_rec.factoring_synd_flag := p_catchup_rec.factoring_synd_flag;
   	  l_accrual_rec.post_to_gl          := p_catchup_rec.post_to_gl;
   	  l_accrual_rec.gl_reversal_flag    := p_catchup_rec.gl_reversal_flag;
   	  l_accrual_rec.memo_yn             := p_catchup_rec.memo_yn;
   	  l_accrual_rec.accrual_activity    := l_catchup_activity;
      l_accrual_rec.accrual_rule_yn     := 'Y';
      -- MGAAP start
      IF (p_representation_type = 'SECONDARY') THEN
        /*l_accrual_rec.trx_number          := p_catchup_rec.trx_number;
        l_accrual_rec.primary_rep_trx_id  := p_catchup_rec.primary_rep_trx_id;*/
      /* Get new trx number and primary rep trx id using old_trx_number
         from  x_rev_tcnv_tbl(i).trx_number */
         null;
         G_trx_number_tbl_cnt := G_trx_number_tbl.count;
         IF (G_trx_number_tbl_cnt > 0) THEN
           FOR rcnt IN G_trx_number_tbl.FIRST..G_trx_number_tbl.LAST
           LOOP
             IF (G_trx_number_tbl(rcnt).old_trx_number=x_rev_tcnv_tbl(i).trx_number) THEN
               l_accrual_rec.trx_number:= G_trx_number_tbl(rcnt).new_trx_number;
               l_accrual_rec.primary_rep_trx_id:= G_trx_number_tbl(rcnt).id;
               EXIT;
             END IF;
           END LOOP;
         END IF;
      END IF;
      -- MGAAP end

      l_count := 1;
      -- Populate stream table for CREATE_ACCRUALS procedure
	  FOR x IN stream_tbl_csr(x_rev_tcnv_tbl(i).id)
	  LOOP
        l_stream_tbl(l_count).stream_type_id := x.sty_id;
        l_stream_tbl(l_count).stream_amount := x.amount;
        l_stream_tbl(l_count).kle_id := x.kle_id;
        l_count := l_count + 1;
	  END LOOP;

      -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
      CREATE_ACCRUALS (
                    p_api_version => l_api_version,
                	p_init_msg_list => p_init_msg_list,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data,
                    x_tcnv_rec => l_tcnv_rec,
                    x_tclv_tbl => l_tclv_tbl,
                    p_accrual_rec => l_accrual_rec,
                    p_stream_tbl => l_stream_tbl,
                    p_representation_type => p_representation_type); -- MGAAP 7263041
      -- store the highest degree of error
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_catchup_rec.contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_catchup_rec.contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      -- MGAAP start 7263041
      IF (p_representation_type = 'PRIMARY') THEN
        G_trx_number_tbl(i).new_trx_number := l_tcnv_rec.trx_number;
        G_trx_number_tbl(i).ID := l_tcnv_rec.ID;
      END IF;
      -- MGAAP end 7263041

      -- 26-Sep-2005. SGIYER. Bug 4616770
      -- re-initialize l_stream_tbl everytime.
      l_stream_tbl.DELETE;

      x_catch_tcnv_tbl(i) := l_tcnv_rec;

      END LOOP;
    END IF; -- for IF x_tclv_tbl.COUNT > 0

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END CATCHUP_ACCRUALS;

  PROCEDURE CATCHUP_ACCRUALS (
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_catchup_rec IN accrual_rec_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_tcnv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
    x_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY' --MGAAP 7263041
  ) IS

    x_rev_tcnv_tbl OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type;
	x_rev_tclv_tbl OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;

  BEGIN

    CATCHUP_ACCRUALS (
	    p_api_version => p_api_version,
	    p_init_msg_list => p_init_msg_list,
        p_catchup_rec => p_catchup_rec,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        x_rev_tcnv_tbl => x_rev_tcnv_tbl,
        x_rev_tclv_tbl => x_rev_tclv_tbl,
        x_catch_tcnv_tbl => x_tcnv_tbl,
        x_catch_tclv_tbl => x_tclv_tbl,
        p_representation_type => p_representation_type); --MGAAP 7263041);

  END;

  PROCEDURE CREATE_ACCRUALS_FORMULA (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_tcnv_rec OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_rec_type,
    x_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    p_accrual_rec IN accrual_rec_type,
	p_ctxt_val_tbl IN Okl_Account_dist_Pub.ctxt_val_tbl_type,
    p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY') IS --MGAAP 7263041


   --Added by kthiruva on 14-May-2007
   --cursor to fetch the contract dff information for SLA Uptake
   CURSOR get_contract_dff_csr(p_khr_id IN NUMBER)
   IS
   SELECT khr.attribute_category
      ,khr.attribute1
      ,khr.attribute2
      ,khr.attribute3
      ,khr.attribute4
      ,khr.attribute5
      ,khr.attribute6
      ,khr.attribute7
      ,khr.attribute8
      ,khr.attribute9
      ,khr.attribute10
      ,khr.attribute11
      ,khr.attribute12
      ,khr.attribute13
      ,khr.attribute14
      ,khr.attribute15
    FROM  okl_k_headers  khr
    WHERE khr.id = p_khr_id;

    --local variables
    l_tcnv_rec                  OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
    l_tclv_tbl                  OKL_TRX_CONTRACTS_PUB.tclv_tbl_type;
    l_api_name                  VARCHAR2(30) := 'CREATE_ACCRUALS_FORMULA';
    l_api_version               CONSTANT NUMBER := 1.0;
	l_tcn_type                  OKL_TRX_CONTRACTS.TCN_TYPE%TYPE;
	l_tcl_type                  OKL_TXL_CNTRCT_LNS.TCL_TYPE%TYPE;
        --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
	l_tsu_code_ent              OKL_TRX_CONTRACTS.TSU_CODE%TYPE := 'PROCESSED';
    l_source_table              OKL_TRNS_ACC_DSTRS.SOURCE_TABLE%TYPE := 'OKL_TXL_CNTRCT_LNS';
    l_tmpl_identify_rec         Okl_Account_Dist_Pub.tmpl_identify_rec_type;
    l_dist_info_rec             Okl_Account_Dist_Pub.dist_info_rec_type;
    l_ctxt_val_tbl              Okl_Account_Dist_Pub.ctxt_val_tbl_type;
    l_template_tbl              Okl_Account_Dist_Pub.avlv_tbl_type;
    l_amount_tbl                Okl_Account_Dist_Pub.amount_tbl_type;
    l_acc_gen_primary_key_tbl   Okl_Account_Dist_Pub.acc_gen_primary_key;
	l_khrv_rec                  Okl_Contract_Pub.khrv_rec_type;
	l_chrv_rec                  Okl_Okc_Migration_Pvt.chrv_rec_type;
	x_khrv_rec                  Okl_Contract_Pub.khrv_rec_type;
	x_chrv_rec                  Okl_Okc_Migration_Pvt.chrv_rec_type;
	l_selv_tbl                  Okl_Streams_Pub.selv_tbl_type;
	x_selv_tbl                  Okl_Streams_Pub.selv_tbl_type;
    l_trx_header_amt            NUMBER :=0;
    l_fact_sync_code            VARCHAR2(2000);
    l_inv_acct_code             VARCHAR2(2000);
    l_scs_code                  VARCHAR2(2000) := 'LEASE';
    --Added by dpsingh for LE Uptake
    l_legal_entity_id     NUMBER;
    --START: Added by nikshah 21-Feb-2007 for SLA Uptake, Bug #5707866
    l_tcn_id NUMBER;
    l_tmpl_identify_tbl          Okl_Account_Dist_Pvt.tmpl_identify_tbl_type;
    l_dist_info_tbl             Okl_Account_Dist_Pvt.dist_info_tbl_type;
    l_ctxt_tbl                   Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
    l_acc_gen_tbl            Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;
    l_template_out_tbl           Okl_Account_Dist_Pvt.avlv_out_tbl_type;
    l_amount_out_tbl             Okl_Account_Dist_Pvt.amount_out_tbl_type;
    l_count NUMBER;
    --END: Added by nikshah 21-Feb-2007 for SLA Uptake, Bug #5707866


  BEGIN
    -- Set save point
    WRITE_TO_LOG('Inside procedure CREATE_ACCRUALS_FORMULA');
    x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- set tcn and tcl types.
    IF p_accrual_rec.accrual_rule_yn = 'N' THEN
      l_tcn_type := 'NACL';
	  l_tcl_type := 'NACL';
	ELSE
      l_tcn_type := 'ACL';
	  l_tcl_type := 'ACL';
	END IF;

    WRITE_TO_LOG('Prior to the call to OKL_SECURITIZATION_PVT.check_khr_ia_associated');


    --Bug 4622198.
    OKL_SECURITIZATION_PVT.check_khr_ia_associated(
        p_api_version                  => p_api_version
       ,p_init_msg_list                => p_init_msg_list
       ,x_return_status                => x_return_status
       ,x_msg_count                    => x_msg_count
       ,x_msg_data                     => x_msg_data
       ,p_khr_id                       => p_accrual_rec.contract_id
       ,p_scs_code                     => l_scs_code
       ,p_trx_date                     => p_accrual_rec.accrual_date
       ,x_fact_synd_code               => l_fact_sync_code
       ,x_inv_acct_code                => l_inv_acct_code
       );
    WRITE_TO_LOG('Return status after the call to OKL_SECURITIZATION_PVT.check_khr_ia_associated is :'|| x_return_status);
    WRITE_TO_LOG('The parameters returned from this call are :');
    WRITE_TO_LOG('============================================');
    WRITE_TO_LOG('x_fact_synd_code   :'||l_fact_sync_code);
    WRITE_TO_LOG('x_inv_acct_code    :'||l_inv_acct_code);

     -- store the highest degree of error
     IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       -- need to leave
         Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_ACC_SEC_PVT_ERROR');
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
         Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_ACC_SEC_PVT_ERROR');
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;

    -- determine number of transaction lines to create
    l_tmpl_identify_rec.product_id := p_accrual_rec.product_id;
    l_tmpl_identify_rec.stream_type_id := p_accrual_rec.sty_id;
    l_tmpl_identify_rec.transaction_type_id := p_accrual_rec.trx_type_id;
    l_tmpl_identify_rec.advance_arrears := p_accrual_rec.advance_arrears;
    l_tmpl_identify_rec.prior_year_yn := 'N';
    l_tmpl_identify_rec.memo_yn := p_accrual_rec.memo_yn;
    --Bug 4622198.
    l_tmpl_identify_rec.factoring_synd_flag := l_fact_sync_code;
    l_tmpl_identify_rec.investor_code := l_inv_acct_code;

    -- added parameter p_validity_date for bug 2902876.
	Okl_Account_Dist_Pub.GET_TEMPLATE_INFO(p_api_version        => p_api_version,
                      p_init_msg_list      => p_init_msg_list,
                      x_return_status      => x_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data,
                      p_tmpl_identify_rec  => l_tmpl_identify_rec,
                      x_template_tbl       => l_template_tbl,
					  p_validity_date      => p_accrual_rec.accrual_date);
    -- store the highest degree of error
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      -- need to leave
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_GET_TMPL_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => p_accrual_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_GET_TMPL_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => p_accrual_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- If templates are not found, then raise an error. Get_template_info will not return error.
    IF l_template_tbl.COUNT = 0 THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_TMPL_NOT_FOUND');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSE
    -- Build the transaction record
    --Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_accrual_rec.contract_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_tcnv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  p_accrual_rec.contract_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_tcnv_rec.khr_id := p_accrual_rec.contract_id;
    l_tcnv_rec.pdt_id := p_accrual_rec.product_id;
    l_tcnv_rec.try_id := p_accrual_rec.trx_type_id;
    l_tcnv_rec.set_of_books_id := p_accrual_rec.set_of_books_id;
    l_tcnv_rec.tcn_type := l_tcn_type;
    l_tcnv_rec.description := p_accrual_rec.description;
    l_tcnv_rec.date_accrual := p_accrual_rec.accrual_date;
    l_tcnv_rec.date_transaction_occurred := p_accrual_rec.accrual_date;
    l_tcnv_rec.amount := p_accrual_rec.amount;
    l_tcnv_rec.currency_code := p_accrual_rec.currency_code;
    l_tcnv_rec.currency_conversion_type := p_accrual_rec.currency_conversion_type;
    l_tcnv_rec.currency_conversion_rate := p_accrual_rec.currency_conversion_rate;
    l_tcnv_rec.currency_conversion_date := p_accrual_rec.currency_conversion_date;
    l_tcnv_rec.accrual_status_yn := p_accrual_rec.rule_result;
    l_tcnv_rec.update_status_yn := p_accrual_rec.override_status;
    l_tcnv_rec.tsu_code := l_tsu_code_ent;
	l_tcnv_rec.accrual_activity := p_accrual_rec.accrual_activity;
    l_tcnv_rec.source_trx_id := p_accrual_rec.source_trx_id;
    l_tcnv_rec.source_trx_type := p_accrual_rec.source_trx_type;
    -- MGAAP 7263041 start
    l_tcnv_rec.representation_type := p_representation_type;
    l_tcnv_rec.trx_number          := p_accrual_rec.trx_number;
    l_tcnv_rec.primary_rep_trx_id  := p_accrual_rec.primary_rep_trx_id;
    -- MGAAP 7263041 end

    --Fetching the contract dff information
    FOR get_contract_dff_rec IN get_contract_dff_csr(p_accrual_rec.contract_id)
    LOOP
      l_tcnv_rec.attribute_category := get_contract_dff_rec.attribute_category;
      l_tcnv_rec.attribute1         := get_contract_dff_rec.attribute1;
      l_tcnv_rec.attribute2         := get_contract_dff_rec.attribute2;
      l_tcnv_rec.attribute3         := get_contract_dff_rec.attribute3;
      l_tcnv_rec.attribute4         := get_contract_dff_rec.attribute4;
      l_tcnv_rec.attribute5         := get_contract_dff_rec.attribute5;
      l_tcnv_rec.attribute6         := get_contract_dff_rec.attribute6;
      l_tcnv_rec.attribute7         := get_contract_dff_rec.attribute7;
      l_tcnv_rec.attribute8         := get_contract_dff_rec.attribute8;
      l_tcnv_rec.attribute9         := get_contract_dff_rec.attribute9;
      l_tcnv_rec.attribute10        := get_contract_dff_rec.attribute10;
      l_tcnv_rec.attribute11        := get_contract_dff_rec.attribute11;
      l_tcnv_rec.attribute12        := get_contract_dff_rec.attribute12;
      l_tcnv_rec.attribute13        := get_contract_dff_rec.attribute13;
      l_tcnv_rec.attribute14        := get_contract_dff_rec.attribute14;
      l_tcnv_rec.attribute15        := get_contract_dff_rec.attribute15;
    END LOOP;

   --Added by dpsingh for SLA Uptake (Bug 5707866)
   l_tcnv_rec.accrual_reversal_date := p_accrual_rec.accrual_reversal_date;
    -- Build the transaction line table of records
    FOR i IN l_template_tbl.FIRST..l_template_tbl.LAST
	LOOP
      l_tclv_tbl(i).line_number := i;
      l_tclv_tbl(i).khr_id := p_accrual_rec.contract_id;
      l_tclv_tbl(i).sty_id := p_accrual_rec.sty_id;
      l_tclv_tbl(i).tcl_type := l_tcl_type;
      l_tclv_tbl(i).description := p_accrual_rec.description;
      l_tclv_tbl(i).amount := p_accrual_rec.amount;
      l_tclv_tbl(i).currency_code := p_accrual_rec.currency_code;
      l_tclv_tbl(i).accrual_rule_yn := p_accrual_rec.accrual_rule_yn;
    END LOOP;

    WRITE_TO_LOG('Prior to the call to Okl_Trx_Contracts_Pub.create_trx_contracts');
    WRITE_TO_LOG('The contents of l_tcnv_rec being passed to the create call ');
    WRITE_TO_LOG('===========================================================');
    WRITE_TO_LOG('l_tcnv_rec.khr_id                    :'||l_tcnv_rec.khr_id);
    WRITE_TO_LOG('l_tcnv_rec.pdt_id                    :'||l_tcnv_rec.pdt_id);
    WRITE_TO_LOG('l_tcnv_rec.try_id                    :'||l_tcnv_rec.try_id);
    WRITE_TO_LOG('l_tcnv_rec.set_of_books_id           :'||l_tcnv_rec.set_of_books_id);
    WRITE_TO_LOG('l_tcnv_rec.tcn_type                  :'||l_tcnv_rec.tcn_type);
    WRITE_TO_LOG('l_tcnv_rec.description               :'||l_tcnv_rec.description);
    WRITE_TO_LOG('l_tcnv_rec.date_accrual              :'||l_tcnv_rec.date_accrual);
    WRITE_TO_LOG('l_tcnv_rec.date_transaction_occurred :'||l_tcnv_rec.date_transaction_occurred);
    WRITE_TO_LOG('l_tcnv_rec.amount                    :'||l_tcnv_rec.amount);
    WRITE_TO_LOG('l_tcnv_rec.currency_code             :'||l_tcnv_rec.currency_code);
    WRITE_TO_LOG('l_tcnv_rec.currency_conversion_type  :'||l_tcnv_rec.currency_conversion_type);
    WRITE_TO_LOG('l_tcnv_rec.currency_conversion_rate  :'||l_tcnv_rec.currency_conversion_rate);
    WRITE_TO_LOG('l_tcnv_rec.currency_conversion_date  :'||l_tcnv_rec.currency_conversion_date);
    WRITE_TO_LOG('l_tcnv_rec.accrual_status_yn         :'||l_tcnv_rec.accrual_status_yn);
    WRITE_TO_LOG('l_tcnv_rec.update_status_yn          :'||l_tcnv_rec.update_status_yn);
    WRITE_TO_LOG('l_tcnv_rec.tsu_code                  :'||l_tcnv_rec.tsu_code);
	WRITE_TO_LOG('l_tcnv_rec.accrual_activity          :'||l_tcnv_rec.accrual_activity);
    WRITE_TO_LOG('l_tcnv_rec.source_trx_id             :'||l_tcnv_rec.source_trx_id);
    WRITE_TO_LOG('l_tcnv_rec.source_trx_type           :'||l_tcnv_rec.source_trx_type);
    WRITE_TO_LOG('l_tcnv_rec.accrual_reversal_date           :'||l_tcnv_rec.accrual_reversal_date);
    WRITE_TO_LOG('l_tcnv_rec.representation_type       :'||l_tcnv_rec.representation_type);
    WRITE_TO_LOG('l_tcnv_rec.trx_number                :'||l_tcnv_rec.trx_number);
    WRITE_TO_LOG('l_tcnv_rec.primary_rep_trx_id        :'||l_tcnv_rec.primary_rep_trx_id);

    WRITE_TO_LOG('');
    WRITE_TO_LOG('The contents of l_tcnv_tbl being passed to the create call ');
    WRITE_TO_LOG('===========================================================');

    FOR i IN l_tclv_tbl.FIRST..l_tclv_tbl.LAST
    LOOP
      WRITE_TO_LOG('l_tclv_tbl(i).line_number     :'||l_tclv_tbl(i).line_number);
      WRITE_TO_LOG('l_tclv_tbl(i).khr_id          :'||l_tclv_tbl(i).khr_id);
      WRITE_TO_LOG('l_tclv_tbl(i).kle_id          :'||l_tclv_tbl(i).kle_id);
      WRITE_TO_LOG('l_tclv_tbl(i).sty_id          :'||l_tclv_tbl(i).sty_id);
      WRITE_TO_LOG('l_tclv_tbl(i).tcl_type        :'||l_tclv_tbl(i).tcl_type);
      WRITE_TO_LOG('l_tclv_tbl(i).description     :'||l_tclv_tbl(i).description);
      WRITE_TO_LOG('l_tclv_tbl(i).amount          :'||l_tclv_tbl(i).amount);
      WRITE_TO_LOG('l_tclv_tbl(i).currency_code   :'||l_tclv_tbl(i).currency_code);
      WRITE_TO_LOG('l_tclv_tbl(i).accrual_rule_yn :'||l_tclv_tbl(i).accrual_rule_yn);
    END LOOP;

    -- Call Transaction Public API to insert transaction header and line records
    Okl_Trx_Contracts_Pub.create_trx_contracts
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,p_tcnv_rec => l_tcnv_rec
                           ,p_tclv_tbl => l_tclv_tbl
                           ,x_tcnv_rec => x_tcnv_rec
                           ,x_tclv_tbl => x_tclv_tbl );
    -- store the highest degree of error
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      -- need to leave
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => p_accrual_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_TRX_CRE_ERROR',
                            p_token1       => g_contract_number_token,
                            p_token1_value => p_accrual_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    l_ctxt_val_tbl := p_ctxt_val_tbl;

    --get acc gen sources and value. Bug 3596651
    GET_ACCOUNT_GEN_DETAILS(
        p_contract_id => p_accrual_rec.contract_id,
        x_return_status => x_return_status,
        x_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl);
    --check for error
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_ACC_GEN_ERROR',
                          p_token1       => g_contract_number_token,
                          p_token1_value => p_accrual_rec.contract_number);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --START: Changes by nikshah 21-Feb-2007 for SLA Uptake, Bug #5707866
    l_tcn_id := x_tcnv_rec.id;

    -- Build Accounting Record for creating entries
    FOR i IN x_tclv_tbl.FIRST..x_tclv_tbl.LAST
    LOOP
      l_acc_gen_tbl(i).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
      l_acc_gen_tbl(i).source_id := x_tclv_tbl(i).id;

      IF (l_ctxt_val_tbl.COUNT > 0) THEN
        l_ctxt_tbl(i).ctxt_val_tbl := l_ctxt_val_tbl;
        l_ctxt_tbl(i).source_id := x_tclv_tbl(i).id;
      END IF;

      l_tmpl_identify_tbl(i).product_id := x_tcnv_rec.pdt_id;
      l_tmpl_identify_tbl(i).stream_type_id := x_tclv_tbl(i).sty_id;
      l_tmpl_identify_tbl(i).transaction_type_id := x_tcnv_rec.try_id;
      l_tmpl_identify_tbl(i).advance_arrears := p_accrual_rec.advance_arrears;
      l_tmpl_identify_tbl(i).prior_year_yn := 'N';
      l_tmpl_identify_tbl(i).memo_yn := p_accrual_rec.memo_yn;
      --Bug 4622198.
      l_tmpl_identify_tbl(i).factoring_synd_flag := l_fact_sync_code;
      l_tmpl_identify_tbl(i).investor_code := l_inv_acct_code;

      l_dist_info_tbl(i).contract_id := p_accrual_rec.contract_id;
      l_dist_info_tbl(i).accounting_date := x_tcnv_rec.date_transaction_occurred;
      l_dist_info_tbl(i).source_table := l_source_table;
      l_dist_info_tbl(i).currency_code := x_tcnv_rec.currency_code;
      l_dist_info_tbl(i).currency_conversion_type := x_tcnv_rec.currency_conversion_type;
      l_dist_info_tbl(i).currency_conversion_rate := x_tcnv_rec.currency_conversion_rate;
      l_dist_info_tbl(i).currency_conversion_date := x_tcnv_rec.currency_conversion_date;
      l_dist_info_tbl(i).source_id := x_tclv_tbl(i).id;
      l_dist_info_tbl(i).post_to_gl := p_accrual_rec.post_to_gl;
      l_dist_info_tbl(i).gl_reversal_flag := p_accrual_rec.gl_reversal_flag;

      WRITE_TO_LOG('Prior to the call to Create Distributions');
      WRITE_TO_LOG('');
      WRITE_TO_LOG('The contents of l_tmpl_identify_tbl     :');
      WRITE_TO_LOG('=========================================');
      WRITE_TO_LOG('l_tmpl_identify_tbl(i).product_id          :'||l_tmpl_identify_tbl(i).product_id);
      WRITE_TO_LOG('l_tmpl_identify_tbl(i).stream_type_id      :'||l_tmpl_identify_tbl(i).stream_type_id);
      WRITE_TO_LOG('l_tmpl_identify_tbl(i).transaction_type_id :'||l_tmpl_identify_tbl(i).transaction_type_id);
      WRITE_TO_LOG('l_tmpl_identify_tbl(i).advance_arrears     :'||l_tmpl_identify_tbl(i).advance_arrears);
      WRITE_TO_LOG('l_tmpl_identify_tbl(i).prior_year_yn       :'||l_tmpl_identify_tbl(i).prior_year_yn);
      WRITE_TO_LOG('l_tmpl_identify_tbl(i).memo_yn             :'||l_tmpl_identify_tbl(i).memo_yn);
      WRITE_TO_LOG('l_tmpl_identify_tbl(i).factoring_synd_flag :'||l_tmpl_identify_tbl(i).factoring_synd_flag);
      WRITE_TO_LOG('l_tmpl_identify_tbl(i).investor_code       :'||l_tmpl_identify_tbl(i).investor_code);

      WRITE_TO_LOG('The contents of l_dist_info_tbl are :');
      WRITE_TO_LOG('=========================================');
      WRITE_TO_LOG('l_dist_info_tbl(i).amount                   :'||l_dist_info_tbl(i).amount);
      WRITE_TO_LOG('l_dist_info_tbl(i).accounting_date          :'||l_dist_info_tbl(i).accounting_date);
      WRITE_TO_LOG('l_dist_info_tbl(i).source_id                :'||l_dist_info_tbl(i).source_id);
      WRITE_TO_LOG('l_dist_info_tbl(i).source_table             :'||l_dist_info_tbl(i).source_table);
      WRITE_TO_LOG('l_dist_info_tbl(i).currency_code            :'||l_dist_info_tbl(i).currency_code);
      WRITE_TO_LOG('l_dist_info_tbl(i).currency_conversion_type :'||l_dist_info_tbl(i).currency_conversion_type);
      WRITE_TO_LOG('l_dist_info_tbl(i).currency_conversion_rate :'||l_dist_info_tbl(i).currency_conversion_rate);
      WRITE_TO_LOG('l_dist_info_tbl(i).currency_conversion_date :'||l_dist_info_tbl(i).currency_conversion_date);
      WRITE_TO_LOG('l_dist_info_tbl(i).post_to_gl               :'||l_dist_info_tbl(i).post_to_gl);
      WRITE_TO_LOG('l_dist_info_tbl(i).gl_reversal_flag         :'||l_dist_info_tbl(i).gl_reversal_flag);
      WRITE_TO_LOG('l_dist_info_tbl(i).contract_id              :'||l_dist_info_tbl(i).contract_id);
      WRITE_TO_LOG('l_dist_info_tbl(i).contract_line_id         :'||l_dist_info_tbl(i).contract_line_id);
    END LOOP;

      -- Call Okl_Account_Dist_Pub API to create accounting entries for this transaction
      --Call new signature
      Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
                                  p_api_version        => p_api_version,
                                  p_init_msg_list      => p_init_msg_list,
                                  x_return_status      => x_return_status,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data,
                                  p_tmpl_identify_tbl  => l_tmpl_identify_tbl,
                                  p_dist_info_tbl      => l_dist_info_tbl,
                                  p_ctxt_val_tbl       => l_ctxt_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                  x_template_tbl       => l_template_out_tbl,
                                  x_amount_tbl         => l_amount_out_tbl,
				  p_trx_header_id      => l_tcn_id);

      -- store the highest degree of error
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_CRE_DIST_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_accrual_rec.contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          -- record that there was an error
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_CRE_DIST_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_accrual_rec.contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    IF l_template_out_tbl.COUNT > 0 THEN
      FOR i IN l_template_out_tbl.FIRST..l_template_out_tbl.LAST
      LOOP
        -- verify template tbl count with amount tbl count
	IF l_template_out_tbl(i).template_tbl.COUNT <> l_amount_out_tbl(i).amount_tbl.COUNT THEN
	  Okl_Api.set_message(p_app_name     => g_app_name,
					      p_msg_name     => 'OKL_AGN_TMP_AMTCOUNT_MISMATCH');
	  RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
      END LOOP;
    END IF;
    --END: Changes by nikshah 21-Feb-2007 for SLA Uptake, Bug #5707866
    l_tclv_tbl := x_tclv_tbl;
    l_tcnv_rec := x_tcnv_rec;
    -- Total the amount for trx header and assign amount to lines
    --START: Changes by nikshah 13-Mar-2007, Bug 5707866
    l_count := l_amount_out_tbl.FIRST;
    FOR i in l_tclv_tbl.FIRST..l_tclv_tbl.LAST LOOP
      IF l_tclv_tbl(i).id = l_amount_out_tbl(l_count).source_id THEN
        l_amount_tbl := l_amount_out_tbl(l_count).amount_tbl;
        IF l_amount_tbl.COUNT > 0 THEN
            FOR j in l_amount_tbl.FIRST..l_amount_tbl.LAST LOOP
                l_tclv_tbl(i).amount := l_tclv_tbl(i).amount + l_amount_tbl(j);
            END LOOP;
        END IF;
        l_trx_header_amt := l_trx_header_amt + l_tclv_tbl(i).amount;
        l_count := l_count + 1;
     END IF;
    END LOOP;
    --END: Changes by nikshah 13-Mar-2007, Bug 5707866
	l_tcnv_rec.amount := l_trx_header_amt;


      -- update the transaction header and line records with amounts
      WRITE_TO_LOG('Prior to the call to Okl_Trx_Contracts_Pub.update_trx_contracts');
      Okl_Trx_Contracts_Pub.update_trx_contracts
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,p_tcnv_rec => l_tcnv_rec
                           ,p_tclv_tbl => l_tclv_tbl
                           ,x_tcnv_rec => x_tcnv_rec
                           ,x_tclv_tbl => x_tclv_tbl );
      WRITE_TO_LOG('Return Status after the call to Okl_Trx_Contracts_Pub.update_trx_contracts is '||x_return_status);
      -- store the highest degree of error
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_TRX_UPD_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_accrual_rec.contract_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_TRX_UPD_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_accrual_rec.contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      -- Modified by kthiruva on 16-Jul-2007 as part of SLA Uptake Impact.
      -- Else portion of the condition removed as part of Bug 6137099. When the amount returned by the accounting engine
      -- is zero, the transaction header and lines are not deleted. Howerver, there is no accounting done.
      -- As part of this bug fix, the changes made through bug 4937105 are reversed.
--
-- Bug 4662173.
-- Commenting below call. There is no need to update contract header.
-- Value of latest accrual rule evaluation is available and used from transaction header.
--
--     l_khrv_rec.id := p_accrual_rec.contract_id;
--     l_chrv_rec.id :=  p_accrual_rec.contract_id;
--     l_khrv_rec.generate_accrual_yn := x_tcnv_rec.accrual_status_yn;
--     l_khrv_rec.generate_accrual_override_yn := l_tcnv_rec.update_status_yn;
--     -- Call Contract Update API to set accrual status
--     Okl_Contract_Pub.update_contract_header
--                              (p_api_version => p_api_version
--                              ,p_init_msg_list => p_init_msg_list
--                              ,x_return_status => x_return_status
--                              ,x_msg_count => x_msg_count
--                              ,x_msg_data => x_msg_data
--                              ,p_restricted_update => 'OKL_API.G_TRUE'
--                              ,p_chrv_rec => l_chrv_rec
--                              ,p_khrv_rec => l_khrv_rec
--                              ,x_chrv_rec => x_chrv_rec
--                              ,x_khrv_rec => x_khrv_rec );
--     -- store the highest degree of error
--     IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
--       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
--         -- need to leave
--         Okl_Api.set_message(p_app_name     => g_app_name,
--                             p_msg_name     => 'OKL_AGN_KHR_UPD_ERROR',
--                             p_token1       => g_contract_number_token,
--                             p_token1_value => p_accrual_rec.contract_number);
--         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
--       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
--         -- record that there was an error
--         Okl_Api.set_message(p_app_name     => g_app_name,
--                             p_msg_name     => 'OKL_AGN_KHR_UPD_ERROR',
--                             p_token1       => g_contract_number_token,
--                             p_token1_value => p_accrual_rec.contract_number);
--         RAISE OKL_API.G_EXCEPTION_ERROR;
--       END IF;
--     END IF;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	END IF; -- For l_template_tbl.COUNT > 0

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END CREATE_ACCRUALS_FORMULA;

  PROCEDURE UPDATE_BALANCES (p_khr_id IN NUMBER
                            ,p_khr_number IN VARCHAR2
                            ,p_amount IN NUMBER
                            ,p_date   IN DATE
                            ,x_return_status OUT NOCOPY VARCHAR2
                            ,x_msg_count OUT NOCOPY NUMBER
                            ,x_msg_data OUT NOCOPY VARCHAR2

    ) IS

    CURSOR get_balances_id_csr (p_khr_id NUMBER) IS
    SELECT id
    FROM OKL_CONTRACT_BALANCES
    WHERE khr_id = p_khr_id
    AND kle_id IS NULL;

    l_balances_id           OKL_CONTRACT_BALANCES.ID%TYPE;
    l_cblv_rec              OKL_CONTRACT_BALANCES_PVT.okl_cblv_rec;
    x_cblv_rec              OKL_CONTRACT_BALANCES_PVT.okl_cblv_rec;
	l_api_version           CONSTANT NUMBER := 1.0;
	l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_BALANCES';
	l_init_msg_list         VARCHAR2(2000) := OKL_API.G_FALSE;
	l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(2000);


  BEGIN
    -- Set save point
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,l_init_msg_list
                                             ,l_api_version
                                             ,l_api_version
                                             ,'_PVT'
                                             ,l_return_status);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    OPEN get_balances_id_csr(p_khr_id);
    FETCH get_balances_id_csr INTO l_balances_id;
    CLOSE get_balances_id_csr;

    l_cblv_rec.khr_id := p_khr_id;
    l_cblv_rec.interest_accrued_amt := p_amount;
    l_cblv_rec.interest_accrued_date := p_date;

    IF l_balances_id IS NOT NULL THEN
      l_cblv_rec.id := l_balances_id;
      OKL_CONTRACT_BALANCES_PVT.update_contract_balance(
                         p_api_version      => l_api_version
                       , p_init_msg_list    => l_init_msg_list
                       , x_return_status    => l_return_status
                       , x_msg_count        => l_msg_count
                       , x_msg_data         => l_msg_data
                       , p_cblv_rec         => l_cblv_rec
                       , x_cblv_rec         => x_cblv_rec);

      -- store the highest degree of error
      IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_UPD_BAL_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_khr_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_UPD_BAL_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_khr_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    ELSE
      OKL_CONTRACT_BALANCES_PVT.create_contract_balance(
                         p_api_version      => l_api_version
                       , p_init_msg_list    => l_init_msg_list
                       , x_return_status    => l_return_status
                       , x_msg_count        => l_msg_count
                       , x_msg_data         => l_msg_data
                       , p_cblv_rec         => l_cblv_rec
                       , x_cblv_rec         => x_cblv_rec);
      -- store the highest degree of error
      IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_CRE_BAL_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_khr_number);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_CRE_BAL_ERROR',
                              p_token1       => g_contract_number_token,
                              p_token1_value => p_khr_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN OTHERS THEN

      IF get_balances_id_csr%ISOPEN THEN
        CLOSE get_balances_id_csr;
      END IF;

      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END UPDATE_BALANCES;

  PROCEDURE PROCESS_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_process_accrual_rec IN process_accrual_rec_type

  )IS

	l_contract_id		    OKL_K_HEADERS_FULL_V.id%TYPE;
	l_contract_number       OKL_K_HEADERS_FULL_V.contract_number%TYPE;
	l_accrual_status		OKL_K_HEADERS_FULL_V.generate_accrual_yn%TYPE;
	l_override_status		OKL_K_HEADERS_FULL_V.generate_accrual_override_yn%TYPE;
	l_start_date    		OKL_K_HEADERS_FULL_V.start_date%TYPE;
	l_sts_code			    OKL_K_HEADERS_FULL_V.sts_code%TYPE;
	l_product_id            OKL_K_HEADERS_FULL_V.pdt_id%TYPE;
	l_deal_type             OKL_K_HEADERS_FULL_V.deal_type%TYPE;
	l_try_id                OKL_TRX_TYPES_V.id%TYPE;
	l_func_currency_code    OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
	l_khr_currency_code     OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
	l_currency_conv_type    OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_TYPE%TYPE;
	l_currency_conv_rate    OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_RATE%TYPE;
	l_currency_conv_date    OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_DATE%TYPE;
    l_sob_id                OKL_SYS_ACCT_OPTS.set_of_books_id%TYPE;
        --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
	l_tsu_code_ent          OKL_TRX_CONTRACTS.TSU_CODE%TYPE := 'PROCESSED';
    l_tcn_type              OKL_TRX_CONTRACTS.TCN_TYPE%TYPE := 'ACL';
    l_batch_name            OKL_TRX_CONTRACTS.DESCRIPTION%TYPE := p_process_accrual_rec.batch_name;
	l_reverse_date_to       DATE;
    l_sob_name              VARCHAR2(2000);
	l_sysdate               DATE := SYSDATE;
	l_api_version           CONSTANT NUMBER := 1.0;
	l_api_name              CONSTANT VARCHAR2(30) := 'PROCESS_ACCRUALS';
	l_init_msg_list         VARCHAR2(2000) := OKL_API.G_FALSE;
	l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(2000);
	l_period_name           VARCHAR2(2000);
	l_period_start_date     DATE;
	l_period_end_date       DATE;
    l_org_id                NUMBER;
    l_org_name              VARCHAR2(2000);
    l_accrual_date          DATE;
    l_rule_info_cat          VARCHAR2(2000) := 'LAINTP';
    l_period_status         VARCHAR2(1);

    l_previous_accrual_status OKL_TRX_CONTRACTS.accrual_status_yn%TYPE;
    l_previous_override_status OKL_TRX_CONTRACTS.update_status_yn%TYPE;
    l_last_interest_calc_date DATE;
        -- bug 2490346
		-- changed l_interest_fixed to l_variable_rate
		--l_variable_rate		VARCHAR2(2000);
		-- assigning NULL for bug#2388940
    l_billing_type     	    VARCHAR2(2000) := NULL;
        -- moved l_total from outer block to inner block for bug# 2648718
    l_total                 NUMBER := 0;
    l_rule_result		    VARCHAR2(1);
    l_sty_id                OKL_STRM_TYPE_V.id%TYPE;
    l_stream_tbl            stream_tbl_type;
    l_stream_tbl_rep        stream_tbl_type; -- MGAAP 7263041
    l_tcnv_rec              Okl_Trx_Contracts_Pub.tcnv_rec_type;
    l_tcnv_tbl              Okl_Trx_Contracts_Pub.tcnv_tbl_type;
    l_can_tcnv_tbl          Okl_Trx_Contracts_Pub.tcnv_tbl_type;
    l_tclv_tbl              Okl_Trx_Contracts_Pub.tclv_tbl_type;
    l_can_tclv_tbl          Okl_Trx_Contracts_Pub.tclv_tbl_type;
    l_ctxt_val_tbl          Okl_Account_Dist_Pub.ctxt_val_tbl_type;
    l_accrual_rec           accrual_rec_type;
    l_reverse_rec           accrual_rec_type;
    l_catchup_rec           accrual_rec_type;
		-- commenting for bug# 2388940
		--l_billing_rule_csr_v    billing_rule_csr%ROWTYPE;

    l_agn_activity          VARCHAR2(1);
    l_factoring_synd_flag   VARCHAR2(2000) := NULL;
    l_syndication_flag      VARCHAR2(2000);
    l_factoring_flag        VARCHAR2(2000);
    l_trx_exists            VARCHAR2(1) := '?';
    l_error_msg_tbl 		Okl_Accounting_Util.Error_Message_Type;
    l_rev_rec_method        VARCHAR2(2000);
    l_rev_rec_basis         OKL_STRM_TYPE_V.ACCRUAL_YN%TYPE;
    l_last_accrual_date     DATE;

-- Commenting for Bug 4659467
-- Cursor to select the interest rule i.e. whether fixed interest or variable interest
--     CURSOR interest_rule_csr(p_ctr_id NUMBER) IS
--     SELECT rule_information1
--     FROM OKC_RULES_B
--     WHERE dnz_chr_id = p_ctr_id
-- 	AND rule_information_category = l_rule_info_cat;


	-- Cursor to select the previous accrual and override statuses
	-- bug 2474969, modified subquery from okl_trx_contracts to okl_trx_contracts_v
    -- bug 2870449, 25-Mar-03, SGIYER, added khr_id = p_khr_id to outer query.
    CURSOR last_status_csr(p_khr_id NUMBER) IS
    SELECT accrual_status_yn, update_status_yn
    FROM OKL_TRX_CONTRACTS
    WHERE date_transaction_occurred = (SELECT MAX(date_transaction_occurred)
          FROM OKL_TRX_CONTRACTS
          WHERE khr_id = p_khr_id
          AND tcn_type = l_tcn_type
          AND tsu_code = l_tsu_code_ent
          AND representation_type = 'PRIMARY') -- MGAAP 7263041
    AND tcn_type = l_tcn_type
    AND khr_id = p_khr_id
	AND tsu_code = l_tsu_code_ent
    AND representation_type = 'PRIMARY'; -- MGAAP 7263041

	-- Cursor to identify if any accrual activity has occurred
	-- bug# 2474969
	-- bug# 2852781. Added tsu_code check for rebook error.
	CURSOR check_agn_csr(p_khr_id NUMBER) IS
    SELECT 'Y'
    FROM OKL_TRX_CONTRACTS
    WHERE tcn_type = l_tcn_type
    AND khr_id = p_khr_id
    AND tsu_code = l_tsu_code_ent
    AND representation_type = 'PRIMARY'; -- MGAAP 7263041


    -- Cursor to select the last interest calculated date
	CURSOR last_int_date_csr(p_khr_id NUMBER) IS
	SELECT TRUNC(DATE_LAST_INTERIM_INTEREST_CAL)
	FROM OKL_K_HEADERS
	WHERE ID = p_khr_id;


    -- Cursor to select the stream type id for the streams being accrued in case of variable interest rate contracts
    --SGIYER. Commenting below. Not needed for User Defined Streams Project.
    --CURSOR sty_id_csr(p_sty_name VARCHAR2) IS
    --SELECT id
    --FROM okl_strm_type_tl
    --WHERE name = p_sty_name
    --AND language = 'US';

    -- Cursor to select currency conversion information
    --Bug 3875747
    -- Use util to identify rate and not own query
	--Commenting below
    /*
    CURSOR currency_conv_csr(p_conversion_type VARCHAR2, p_from_currency VARCHAR2, p_to_currency VARCHAR2, p_conversion_date DATE) IS
    SELECT conversion_rate
    FROM GL_DAILY_RATES
    WHERE conversion_type = p_conversion_type
    AND conversion_date = p_conversion_date
	AND from_currency = p_from_currency
	AND to_currency = p_to_currency
	AND status_code = 'C';
    */

    -- cursor to check for accrual trx for a given period for variable rate contracts
    -- 12/5/05. Bug 4862620. Check for trx with variable interest income only
    CURSOR check_variable_trx(p_khr_id NUMBER, p_date DATE) IS
    SELECT 'Y'
    FROM OKL_TRX_CONTRACTS trx, OKL_TRX_TYPES_V try, OKL_TXL_CNTRCT_LNS txl, OKL_STRM_TYPE_V sty
    WHERE trx.khr_id = p_khr_id
    AND trx.try_id = try.id
    AND try.name = 'Accrual'
    --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
    AND trx.tsu_code = 'PROCESSED'
    AND TRUNC(last_day(trx.date_transaction_occurred)) = TRUNC(p_date)
    AND trx.id = txl.tcn_id
    AND txl.sty_id = sty.id
    AND sty.stream_type_purpose = 'VARIABLE_INTEREST_INCOME'
    AND trx.representation_type = 'PRIMARY';

    -- 12/5/05. Bug 4862620. Check for trx with actual income accrual only
--    CURSOR check_actual_trx(p_khr_id NUMBER, p_date DATE) IS
--    SELECT 'Y'
    CURSOR check_actual_trx(p_khr_id NUMBER) IS
    SELECT TRUNC(MAX(trx.date_transaction_occurred)) last_accrual_date
    FROM OKL_TRX_CONTRACTS trx,
         OKL_TRX_TYPES_V try,
         OKL_TXL_CNTRCT_LNS txl,
         OKL_STRM_TYPE_V sty
    WHERE trx.khr_id = p_khr_id
    AND trx.try_id = try.id
    AND try.name = 'Accrual'
    --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
    AND trx.tsu_code = 'PROCESSED'
--    AND TRUNC(trx.date_transaction_occurred) = TRUNC(p_date)
    AND trx.id = txl.tcn_id
    AND txl.sty_id = sty.id
    AND sty.stream_type_purpose = 'ACTUAL_INCOME_ACCRUAL'
    AND trx.representation_type = 'PRIMARY';

    CURSOR  get_rev_rec_basis_csr (p_sty_id NUMBER) IS
    SELECT accrual_yn
    FROM OKL_STRM_TYPE_V
    WHERE id = p_sty_id;

    l_last_status_csr_v     last_status_csr%ROWTYPE;

    -- MGAAP start 7263041
    CURSOR contract_multigaap_csr (p_contract_id NUMBER) IS
    SELECT NVL(a.multi_gaap_yn,'N') multi_gaap_yn,
	       b.reporting_pdt_id
    FROM  OKL_K_HEADERS a,
          OKL_PRODUCTS b
    WHERE a.ID = p_contract_id
    AND   a.PDT_ID = b.ID;

    l_multi_gaap_yn  OKL_K_HEADERS.MULTI_GAAP_YN%TYPE;
    l_reporting_pdt_id  OKL_PRODUCTS.REPORTING_PDT_ID%TYPE;
    l_tcnv_tbl_cnt      NUMBER;
    l_sty_id_rep        OKL_STRM_TYPE_V.id%TYPE;
    -- MGAAP end 7263041

	-- bug 7577628
	cursor get_sec_rep_method is
	select secondary_rep_method
	  from okl_sys_acct_opts;

    l_sec_rep_method    okl_sys_acct_opts.secondary_rep_method%TYPE := null;

  BEGIN
        WRITE_TO_LOG('');
        WRITE_TO_LOG('Inside procedure PROCESS_ACCRUALS');
        -- Set save point
        l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,l_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);

        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          IF p_process_accrual_rec.submission_mode='BATCH' THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in Start Activity');
          END IF;
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
          IF p_process_accrual_rec.submission_mode='BATCH' THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in Start Activity');
          END IF;
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

	    l_contract_id 			:=     p_process_accrual_rec.contract_id;
	    l_contract_number  		:=     p_process_accrual_rec.contract_number;
	    l_sts_code 				:=     p_process_accrual_rec.sts_code;
	    l_product_id 			:=     p_process_accrual_rec.product_id;
	    l_accrual_status 		:=     p_process_accrual_rec.accrual_status;
	    l_override_status 		:=     p_process_accrual_rec.override_status;
	    l_start_date 			:=     p_process_accrual_rec.start_date;
	    l_deal_type 			:=     p_process_accrual_rec.deal_type;
	    l_khr_currency_code 	:=     p_process_accrual_rec.khr_currency_code;
	    l_currency_conv_type 	:=     p_process_accrual_rec.currency_conv_type;
	    l_currency_conv_date 	:=     p_process_accrual_rec.currency_conv_date;
	    l_currency_conv_rate 	:=     p_process_accrual_rec.currency_conv_rate;
	    l_func_currency_code 	:=     p_process_accrual_rec.func_currency_code;
	    l_try_id 				:=     p_process_accrual_rec.try_id;
	    l_reverse_date_to 		:=     p_process_accrual_rec.reverse_date_to;
	    l_sob_id 				:=     p_process_accrual_rec.sob_id;
	    l_accrual_date 			:=     p_process_accrual_rec.accrual_date;
	    l_period_end_date 		:=     p_process_accrual_rec.period_end_date;
	    l_period_start_date 	:=     p_process_accrual_rec.period_start_date;
        l_rev_rec_method        := 	   p_process_accrual_rec.rev_rec_method;

        -- Check contract currency against functional currency
        IF l_func_currency_code <> l_khr_currency_code THEN
          --validate data
          IF l_currency_conv_type IS NULL THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_CURR_TYPE_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_contract_number);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
          IF l_currency_conv_date IS NULL THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_CURR_DATE_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_contract_number);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
		  END IF;
          IF l_currency_conv_type = 'User' THEN
            IF l_currency_conv_rate IS NULL THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_CURR_USER_RATE_ERROR',
                                  p_token1       => g_contract_number_token,
                                  p_token1_value => l_contract_number);
              RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
          ELSE
            --Bug 3875747
            -- Use util to identify rate and not own query
            l_currency_conv_rate := OKL_ACCOUNTING_UTIL.get_curr_con_rate (p_from_curr_code => l_khr_currency_code,
                                                                           p_to_curr_code => l_func_currency_code,
                                                                           p_con_date => l_accrual_date, -- Bug#5410825
                                                                           p_con_type => l_currency_conv_type);

            IF l_currency_conv_rate IS NULL THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_CURR_RATE_ERROR',
                                  p_token1       => 'CONVERSION_TYPE',
                                  p_token1_value => l_currency_conv_type,
                                  p_token2       => 'FROM_CURRENCY',
                                  p_token2_value => l_khr_currency_code,
                                  p_token3       => 'TO_CURRENCY',
                                  p_token3_value => l_func_currency_code
								  );
              RAISE Okl_Api.G_EXCEPTION_ERROR;
            END IF;
          l_currency_conv_date := l_accrual_date; --Bug 5410825
	  END IF;
        END IF;
--         -- Open cursor to find the billing status of the selected contract
--         -- commenting for bug# 2388940
--
--         OPEN billing_rule_csr(l_contract_id);
--         FETCH billing_rule_csr INTO l_billing_rule_csr_v;
--         IF billing_rule_csr%NOTFOUND THEN
--           CLOSE billing_rule_csr;
--           Okl_Api.set_message(p_app_name     => g_app_name,
--                               p_msg_name     => 'OKL_AGN_BILLING_RULE_ERROR',
--                               p_token1       => g_contract_number_token,
--                               p_token1_value => l_contract_number);
--           RAISE G_EXCEPTION_HALT_VALIDATION;
--         END IF;
--         IF l_billing_rule_csr_v.object1_id1 = '-3' THEN
--           l_billing_type := 'ARREARS';
--         ELSIF l_billing_rule_csr_v.object1_id1 = '-2' THEN
--           l_billing_type := 'ADVANCE';
--         ELSE
--           -- store SQL error message on message stack for caller
--           Okl_Api.set_message(p_app_name     => g_app_name,
--                               p_msg_name     => 'OKL_AGN_INVALID_BILLING_RULE',
--                               p_token1       => g_contract_number_token,
--                               p_token1_value => l_contract_number);
--           RAISE G_EXCEPTION_HALT_VALIDATION;
--         END IF;
--         CLOSE billing_rule_csr;
--
--         -- Open cursor to find the interest type of the selected contract
--         -- Deviating from the original logic. Interest rule is not mandatory as per
-- 		-- discussion with PM and DM. If interest rule has no value then assume contract
-- 		-- to be fixed interest rate contract. Bug# 2451627
--         OPEN interest_rule_csr(l_contract_id);
--         FETCH interest_rule_csr INTO l_variable_rate;
-- 		CLOSE interest_rule_csr;
--         -- Changed logic for bug# 2490346
-- 		-- Rule changed from LAIIND to LAINTP
--
--         --IF interest_rule_csr%NOTFOUND THEN
--           -- commenting for bug# 2451627
--           --CLOSE interest_rule_csr;
--           ---- store SQL error message on message stack for caller
--           --Okl_Api.set_message(p_app_name     => g_app_name,
--           --                    p_msg_name     => 'OKL_AGN_INT_RULE_ERROR',
--           --                    p_token1       => g_contract_number_token,
--           --                    p_token1_value => l_contract_number);
--           --RAISE G_EXCEPTION_HALT_VALIDATION;
--           --l_interest_fixed := 'N';
--         --END IF;
--
--         -- If variable rate is not defined for a contract, assume contract to be fixed.
--         -- bug 2490346.
--         IF l_variable_rate IS NULL THEN
-- 		  l_variable_rate := 'N';
-- 		END IF;

	    -- Open cursor to find out if the contract has had any accrual activity
		OPEN check_agn_csr(l_contract_id);
		FETCH check_agn_csr INTO l_agn_activity;
        CLOSE check_agn_csr;
        WRITE_TO_LOG('The value of the Accrual Activity Flag is :'||l_agn_activity);

	    -- bug 7577628
		if l_sec_rep_method is null then
          open  get_sec_rep_method;
		  fetch get_sec_rep_method into l_sec_rep_method;
		  close get_sec_rep_method;
		end if;

        -- MGAAP start 7263041
        OPEN contract_multigaap_csr(l_contract_id);
        FETCH contract_multigaap_csr INTO l_multi_gaap_yn, l_reporting_pdt_id;
        CLOSE contract_multigaap_csr;

	    -- bug 7577628
	    if l_sec_rep_method <> 'AUTOMATED' then
          l_multi_gaap_yn := 'N';
	    end if;

        IF (l_multi_gaap_yn = 'Y') THEN
	  GET_COMMON_INFO (p_accrual_date => p_process_Accrual_rec.accrual_date,
	                   x_try_id => G_TRY_ID,
	                   x_period_name => G_PERIOD_NAME_REP,
	                   x_period_start_date => G_PERIOD_START_DATE_REP,
	                   x_period_end_date => G_PERIOD_END_DATE_REP,
	                   x_sob_id => G_SOB_ID_REP,
	                   x_sob_name => G_SOB_NAME_REP,
	                   x_org_id => G_ORG_ID,
	                   x_org_name => G_ORG_NAME,
	                   x_accrual_reversal_days => G_ACCRUAL_REVERSAL_DAYS,
	                   x_func_currency_code => G_FUNC_CURRENCY_CODE_REP,
	                   x_return_status => l_return_status,
	                   p_representation_type => 'SECONDARY'
	                   );
      WRITE_TO_LOG('The parameters returned after the GET_COMMON_INFO call');
      WRITE_TO_LOG('======================================================');
      WRITE_TO_LOG('Return Status     :'||l_return_status);
      WRITE_TO_LOG('Transaction Id    :'||G_TRY_ID);
      WRITE_TO_LOG('Period Name       :'||G_period_name_rep);
      WRITE_TO_LOG('Period Start Date :'||G_period_start_date_rep);
      WRITE_TO_LOG('Period End Date   :'||G_period_end_date_rep);
      WRITE_TO_LOG('Set Of Books Id   :'||G_sob_id_rep);
      WRITE_TO_LOG('Set Of Books Name :'||G_sob_name_rep);
      WRITE_TO_LOG('Org Id            :'||G_org_id);
      WRITE_TO_LOG('Org Name          :'||G_org_name);
      WRITE_TO_LOG('Accrual Rev Days  :'||G_accrual_reversal_days);
      WRITE_TO_LOG('Func Currency Code:'||G_func_currency_code_rep);

      IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
	IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
	                      p_msg_name     => 'OKL_AGN_COM_INFO_ERROR');
  	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
	  Okl_Api.set_message(p_app_name     => g_app_name,
	                      p_msg_name     => 'OKL_AGN_COM_INFO_ERROR');
	  RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      END IF;

        -- MGAAP end 7263041

        IF l_agn_activity ='Y' THEN
          -- There has been accrual activity. So get last status
          -- Open cursor to find the previous override status of the selected contract
          OPEN last_status_csr(l_contract_id);
          FETCH last_status_csr INTO l_previous_accrual_status, l_previous_override_status;
          CLOSE last_status_csr;

          IF l_previous_accrual_status IS NULL THEN
            -- Bug 2852781
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_LAST_STATUS_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_contract_number);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
          IF l_previous_override_status IS NULL THEN
            -- Bug 2852781
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_LAST_STATUS_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_contract_number);
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
        ELSE
          -- No accrual activity. First run. So assign values from contract header.
          l_previous_accrual_status := l_accrual_status;
          l_previous_override_status := l_override_status;
        END IF;


--         -- Check if contract is syndicated
-- 		l_return_status := GET_SYNDICATE_FLAG(l_contract_id,l_syndication_flag);
--         IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
--           Okl_Api.set_message(p_app_name         => g_app_name,
--                                   p_msg_name     => 'OKL_AGN_FAC_SYND_ERROR',
--                                   p_token1       => g_contract_number_token,
--                                   p_token1_value => l_contract_number);
--           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
--         END IF;
--
-- 		IF l_syndication_flag = 'Y' THEN
-- 		  l_factoring_synd_flag := 'SYNDICATION';
-- 		ELSE
--           -- check if contract is factored
-- 		  l_return_status := GET_FACTORING_FLAG(l_contract_id,l_factoring_flag);
--           IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
--             Okl_Api.set_message(p_app_name         => g_app_name,
--                                 p_msg_name     => 'OKL_AGN_FAC_SYND_ERROR',
--                                 p_token1       => g_contract_number_token,
--                                 p_token1_value => l_contract_number);
--             RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
--           END IF;
-- 		  IF l_factoring_flag = 'Y' THEN
-- 		    l_factoring_synd_flag := 'FACTORING';
-- 		  END IF;
-- 		END IF;

        -- Validate contract against accrual rule and get the result
        VALIDATE_ACCRUAL_RULE(x_return_status => l_return_status
                                 ,x_result => l_rule_result
                                 ,p_ctr_id => l_contract_id);
        -- store the highest degree of error
        IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_RULE_VALD_ERROR',
                                  p_token1       => g_contract_number_token,
                                  p_token1_value => l_contract_number);
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

--
-- Commenting for variable rate project. basis has changed.
--
--      IF l_deal_type IN ('LEASEDF','LEASEOP','LEASEST','LOAN','LOAN-REVOLVING') THEN
        IF l_rev_rec_method IN ('STREAMS', 'ESTIMATED_AND_BILLED', 'ACTUAL') THEN
          --Get the stream amounts for this contract which are subject to accrual rules
          -- Bug 4011843. Modified p_accrual_rule_yn value for UDS.
          GET_ACCRUAL_STREAMS(x_return_status => l_return_status
                         ,x_stream_tbl => l_stream_tbl
                         ,p_khr_id => l_contract_id
                         ,p_product_id => l_product_id
                         ,p_ctr_start_date => l_start_date
                         ,p_period_end_date => l_period_end_date
                         ,p_accrual_rule_yn => 'ACRL_WITH_RULE');
          -- store the highest degree of error
          IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_STREAM_ERROR',
                                  p_token1       => g_contract_number_token,
                                  p_token1_value => l_contract_number);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          WRITE_TO_LOG('The count of stream elements that need to be accrued for PRIMARY is :'||l_stream_tbl.COUNT);
          IF (l_stream_tbl.COUNT = 0)
          THEN
            WRITE_TO_LOG('There are no stream elements to be accrued');
          END IF;

          -- MGAAP start 7263041
          IF (l_multi_gaap_yn = 'Y') THEN
          OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
          GET_ACCRUAL_STREAMS(x_return_status => l_return_status
                         ,x_stream_tbl => l_stream_tbl_rep
                         ,p_khr_id => l_contract_id
                         ,p_product_id => l_reporting_pdt_id
                         ,p_ctr_start_date => l_start_date
                         ,p_period_end_date => G_PERIOD_END_DATE_REP
                         ,p_accrual_rule_yn => 'ACRL_WITH_RULE');
          OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
          -- store the highest degree of error
          IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
            Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_STREAM_ERROR',
                                  p_token1       => g_contract_number_token,
                                  p_token1_value => l_contract_number);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          WRITE_TO_LOG('The count of stream elements that need to be accrued for SECONDARY is :'||l_stream_tbl_rep.COUNT);
          IF (l_stream_tbl_rep.COUNT = 0)
          THEN
            WRITE_TO_LOG('There are no stream elements to be accrued');
          END IF;
          END IF;
          -- MGAAP end 7263041

          WRITE_TO_LOG('The following are the values for the various flags :');
          WRITE_TO_LOG('l_override_status          :'||l_override_status);
          WRITE_TO_LOG('l_previous_override_status :'||l_previous_override_status);
          WRITE_TO_LOG('l_rule_result              :'||l_rule_result);
          WRITE_TO_LOG('l_previous_accrual_status  :'||l_previous_accrual_status);

          -- Check the values of the following flags and process accordingly
          -- 1. Accrual Override Status
          -- 2. Accrual Rule Status
          -- 3. Previous Override Status
          -- 4. Previous Accrual Status
          IF l_override_status = 'N' THEN
            IF l_previous_override_status = 'N' THEN
              IF l_rule_result = 'Y' THEN
                IF l_previous_accrual_status = 'N' THEN
                  -- Create catch up entries
                  -- populate the catchup record
                  l_catchup_rec.contract_id := l_contract_id;
				  l_catchup_rec.accrual_date := l_accrual_date;
				  l_catchup_rec.contract_number := l_contract_number;
				  l_catchup_rec.rule_result := l_rule_result;
				  l_catchup_rec.override_status := l_override_status;
				  l_catchup_rec.product_id := l_product_id;
				  l_catchup_rec.trx_type_id := l_try_id;
                  l_catchup_rec.advance_arrears := l_billing_type;
				  l_catchup_rec.factoring_synd_flag := l_factoring_synd_flag;
				  l_catchup_rec.post_to_gl := 'Y';
				  l_catchup_rec.gl_reversal_flag := 'N';
				  l_catchup_rec.memo_yn := 'N';
				  l_catchup_rec.description := l_batch_name;
				  l_catchup_rec.accrual_activity := 'CATCH-UP';

                  -- call the CATCHUP_ACCRUALS procedure
                  CATCHUP_ACCRUALS(p_api_version => l_api_version,
                                     p_init_msg_list => l_init_msg_list,
                                     x_return_status => l_return_status,
				                     x_msg_count => l_msg_count,
                                     x_msg_data => l_msg_data,
                                     x_rev_tcnv_tbl => l_can_tcnv_tbl,
                                     x_rev_tclv_tbl => l_can_tclv_tbl,
                                     x_catch_tcnv_tbl => l_tcnv_tbl,
                                     x_catch_tclv_tbl => l_tclv_tbl,
                                     p_catchup_rec => l_catchup_rec );
                  -- store the highest degree of error
                  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                      -- need to leave
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CAT_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                      -- Select the contract for error reporting
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CAT_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                  END IF;

                  --Report content for reversal of non-accrual
                  IF p_process_accrual_rec.submission_mode='BATCH' THEN
	                  IF l_can_tcnv_tbl.COUNT > 0 THEN
	                  FOR x IN l_can_tcnv_tbl.FIRST..l_can_tcnv_tbl.LAST
					  LOOP
	                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                     RPAD(l_can_tcnv_tbl(x).trx_number,22)||
		                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVERSE'),17)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).update_status_yn,0,0),16)||
	                                         RPAD(l_can_tcnv_tbl(x).currency_code,9)||
	                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_can_tcnv_tbl(x).amount,l_can_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
	                  END LOOP;
	                  END IF;

    				  -- Report content for catchup activity
	                  IF l_tcnv_tbl.COUNT > 0 THEN
	                  FOR x IN l_tcnv_tbl.FIRST..l_tcnv_tbl.LAST
					  LOOP
	                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                     RPAD(l_tcnv_tbl(x).trx_number,22)||
		                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CATCHUP_REVENUE'),17)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).update_status_yn,0,0),16)||
		                                     RPAD(l_tcnv_tbl(x).currency_code,9)||
	                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_tbl(x).amount,l_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
	                  END LOOP;
	                  END IF;
                  END IF; -- if p_process_accrual_rec.submission_mode...

          -- MGAAP start 7263041
          IF (l_multi_gaap_yn = 'Y') THEN
                  -- call the CATCHUP_ACCRUALS procedure for SECONDARY
                  l_catchup_rec.product_id := l_reporting_pdt_id;
                  CATCHUP_ACCRUALS(p_api_version => l_api_version,
                                     p_init_msg_list => l_init_msg_list,
                                     x_return_status => l_return_status,
				     x_msg_count => l_msg_count,
                                     x_msg_data => l_msg_data,
                                     x_rev_tcnv_tbl => l_can_tcnv_tbl,
                                     x_rev_tclv_tbl => l_can_tclv_tbl,
                                     x_catch_tcnv_tbl => l_tcnv_tbl,
                                     x_catch_tclv_tbl => l_tclv_tbl,
                                     p_catchup_rec => l_catchup_rec ,
                                     p_representation_type => 'SECONDARY' );
                  -- store the highest degree of error
                  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                      -- need to leave
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                     p_msg_name     => 'OKL_AGN_CAT_ACR_ERROR',
                                     p_token1       => g_contract_number_token,
                                     p_token1_value => l_contract_number);
                      -- Select the contract for error reporting
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CAT_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                  END IF;

                  --Report content for reversal of non-accrual
                  IF p_process_accrual_rec.submission_mode='BATCH' THEN
	                  IF l_can_tcnv_tbl.COUNT > 0 THEN
	                  FOR x IN l_can_tcnv_tbl.FIRST..l_can_tcnv_tbl.LAST
					  LOOP
	                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                     RPAD(l_can_tcnv_tbl(x).trx_number,22)||
		                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVERSE'),17)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).update_status_yn,0,0),16)||
	                                         RPAD(l_can_tcnv_tbl(x).currency_code,9)||
	                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_can_tcnv_tbl(x).amount,l_can_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
	                  END LOOP;
	                  END IF;

    				  -- Report content for catchup activity
	                  IF l_tcnv_tbl.COUNT > 0 THEN
	                  FOR x IN l_tcnv_tbl.FIRST..l_tcnv_tbl.LAST
					  LOOP
	                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                     RPAD(l_tcnv_tbl(x).trx_number,22)||
		                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CATCHUP_REVENUE'),17)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).update_status_yn,0,0),16)||
		                                     RPAD(l_tcnv_tbl(x).currency_code,9)||
	                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_tbl(x).amount,l_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
	                  END LOOP;
	                  END IF;
                  END IF; -- if p_process_accrual_rec.submission_mode...
          END IF;
          G_trx_number_tbl.DELETE;
          -- MGAAP end 7263041

				END IF;
     		    --Create Revenue Entries
                l_tcnv_rec.trx_number := null;  -- Bug 7555143
                l_tcnv_rec.ID := null;
                IF l_stream_tbl.COUNT > 0 THEN
                  -- Calculate total amount for transaction header
                  FOR i IN l_stream_tbl.FIRST..l_stream_tbl.LAST
                  LOOP
                    l_total := l_total + l_stream_tbl(i).stream_amount;
                  END LOOP;
                  -- Build the accrual record
                  l_accrual_rec.contract_id         := l_contract_id;
                  l_accrual_rec.set_of_books_id     := l_sob_id;
                  l_accrual_rec.accrual_date        := l_accrual_date;
             	  l_accrual_rec.trx_date            := l_accrual_date;
                  l_accrual_rec.contract_number     := l_contract_number;
                  l_accrual_rec.rule_result         := l_rule_result;
                  l_accrual_rec.override_status     := l_override_status;
                  l_accrual_rec.description         := l_batch_name;
             	  l_accrual_rec.amount              := l_total;
              	  l_accrual_rec.currency_code       := l_khr_currency_code;
              	  l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	  l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	  l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                  l_accrual_rec.product_id          := l_product_id;
                  l_accrual_rec.trx_type_id         := l_try_id;
                  l_accrual_rec.advance_arrears     := l_billing_type;
                  l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
            	  l_accrual_rec.post_to_gl          := 'Y';
             	  l_accrual_rec.gl_reversal_flag    := 'N';
             	  l_accrual_rec.memo_yn             := 'N';
             	  l_accrual_rec.accrual_activity    := 'ACCRUAL';
                  l_accrual_rec.accrual_rule_yn     := 'Y';

-- rmunjulu bug 6736148 -- start
                  l_accrual_rec.source_trx_id := p_process_accrual_rec.source_trx_id;
                  l_accrual_rec.source_trx_type := p_process_accrual_rec.source_trx_type;
-- rmunjulu bug 6736148 -- end

                  -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
                  CREATE_ACCRUALS (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_stream_tbl => l_stream_tbl);

                  -- store the highest degree of error
                  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                      -- need to leave
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                  END IF;
                  IF p_process_accrual_rec.submission_mode='BATCH' THEN
	                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                     RPAD(l_tcnv_rec.trx_number,22)||
		                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVENUE'),17)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
		                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
                  END IF;

                END IF; -- IF l_stream_tbl.COUNT >0

                -- MGAAP start 7263041
     		    --Create Revenue Entries
                IF l_stream_tbl_rep.COUNT > 0 THEN
                  -- Calculate total amount for transaction header
                  l_total := 0;
                  FOR i IN l_stream_tbl_rep.FIRST..l_stream_tbl_rep.LAST
                  LOOP
                    l_total := l_total + l_stream_tbl_rep(i).stream_amount;
                  END LOOP;
                  -- Build the accrual record
                  l_accrual_rec.contract_id         := l_contract_id;
                  l_accrual_rec.set_of_books_id     := G_sob_id_rep;
                  l_accrual_rec.accrual_date        := l_accrual_date;
             	  l_accrual_rec.trx_date            := l_accrual_date;
                  l_accrual_rec.contract_number     := l_contract_number;
                  l_accrual_rec.rule_result         := l_rule_result;
                  l_accrual_rec.override_status     := l_override_status;
                  l_accrual_rec.description         := l_batch_name;
             	  l_accrual_rec.amount              := l_total;
              	  l_accrual_rec.currency_code       := l_khr_currency_code;
              	  l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	  l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	  l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                  l_accrual_rec.product_id          := l_reporting_pdt_id;
                  l_accrual_rec.trx_type_id         := l_try_id;
                  l_accrual_rec.advance_arrears     := l_billing_type;
                  l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
            	  l_accrual_rec.post_to_gl          := 'Y';
             	  l_accrual_rec.gl_reversal_flag    := 'N';
             	  l_accrual_rec.memo_yn             := 'N';
             	  l_accrual_rec.accrual_activity    := 'ACCRUAL';
                  l_accrual_rec.accrual_rule_yn     := 'Y';
                  l_accrual_rec.trx_number          := l_tcnv_rec.trx_number;
                  l_accrual_rec.primary_rep_trx_id  := l_tcnv_rec.ID;

-- rmunjulu bug 6736148 -- start
                  l_accrual_rec.source_trx_id := p_process_accrual_rec.source_trx_id;
                  l_accrual_rec.source_trx_type := p_process_accrual_rec.source_trx_type;
-- rmunjulu bug 6736148 -- end

                  -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
                  CREATE_ACCRUALS (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_stream_tbl => l_stream_tbl_rep,
                            p_representation_type => 'SECONDARY'); --MGAAP

                  -- store the highest degree of error
                  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                      -- need to leave
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                  END IF;
                  IF p_process_accrual_rec.submission_mode='BATCH' THEN
	                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                     RPAD(l_tcnv_rec.trx_number,22)||
		                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVENUE'),17)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
		                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
                  END IF;

                END IF; -- IF l_stream_tbl_rep.COUNT >0
                -- MGAAP end 7263041

                ELSE
                  IF l_previous_accrual_status = 'Y' THEN
                    -- populate the reverse record
	 			    l_reverse_rec.contract_id := l_contract_id;
				    l_reverse_rec.reverse_date_to := l_reverse_date_to;
				    l_reverse_rec.accrual_date := l_accrual_date;
				    l_reverse_rec.contract_number := l_contract_number;
				    l_reverse_rec.rule_result := l_rule_result;
				    l_reverse_rec.override_status := l_override_status;
				    l_reverse_rec.product_id := l_product_id;
				    l_reverse_rec.trx_type_id := l_try_id;
					l_reverse_rec.advance_arrears := l_billing_type;
				    l_reverse_rec.factoring_synd_flag := l_factoring_synd_flag;
				    l_reverse_rec.post_to_gl := 'Y';
				    l_reverse_rec.gl_reversal_flag := 'N';
				    l_reverse_rec.memo_yn := 'Y';
                    l_reverse_rec.description := l_batch_name;
                    l_reverse_rec.accrual_activity := 'REVERSAL';

                    -- call the REVERSE_ACCRUALS procedure
                    REVERSE_ACCRUALS(p_api_version => l_api_version,
                                    p_init_msg_list => l_init_msg_list,
				                    x_return_status => l_return_status,
				                    x_msg_count => l_msg_count,
                                    x_msg_data => l_msg_data,
                                    x_rev_tcnv_tbl => l_can_tcnv_tbl,
                                    x_rev_tclv_tbl => l_can_tclv_tbl,
									x_memo_tcnv_tbl => l_tcnv_tbl,
									x_memo_tclv_tbl => l_tclv_tbl,
                                    p_reverse_rec => l_reverse_rec );
                    -- store the highest degree of error
                    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                        -- need to leave
                        Okl_Api.set_message(p_app_name     => g_app_name,
                                           p_msg_name     => 'OKL_AGN_REV_ACR_ERROR',
                                           p_token1       => g_contract_number_token,
                                           p_token1_value => l_contract_number);
                        -- Select the contract for error reporting
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                        Okl_Api.set_message(p_app_name     => g_app_name,
                                           p_msg_name     => 'OKL_AGN_REV_ACR_ERROR',
                                           p_token1       => g_contract_number_token,
                                           p_token1_value => l_contract_number);
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;
                    END IF;
                    -- Report Content for reverse accruals
                    IF p_process_accrual_rec.submission_mode='BATCH' THEN
	                    IF l_can_tcnv_tbl.COUNT > 0 THEN
	                    FOR x IN l_can_tcnv_tbl.FIRST..l_can_tcnv_tbl.LAST
						LOOP
	                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                     RPAD(l_can_tcnv_tbl(x).trx_number,22)||
		                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVERSE'),17)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).update_status_yn,0,0),16)||
		                                     RPAD(l_can_tcnv_tbl(x).currency_code,9)||
	                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_can_tcnv_tbl(x).amount,l_can_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
	                    END LOOP;
	                    END IF; --IF l_can_tcnv_tbl.COUNT > 0 THEN

	                    -- Report Content for non-accruals
	                    IF l_tcnv_tbl.COUNT > 0 THEN
	                    FOR x IN l_tcnv_tbl.FIRST..l_tcnv_tbl.LAST
						LOOP
	                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                     RPAD(l_tcnv_tbl(x).trx_number,22)||
		                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).update_status_yn,0,0),16)||
		                                     RPAD(l_tcnv_tbl(x).currency_code,9)||
	                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_tbl(x).amount,l_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
	                    END LOOP;
	                    END IF; --IF l_tcnv_tbl.COUNT > 0 THEN
                    END IF; -- if p_process_accrual_rec.submission_mode = 'BATCH'

                    -- MGAAP start 7263041
                    IF (l_multi_gaap_yn = 'Y') THEN
                    -- call the REVERSE_ACCRUALS procedure for SECONDARY
                    l_reverse_rec.product_id := l_reporting_pdt_id;
                    /*l_tcnv_tbl_cnt := l_tcnv_tbl.count;
                    l_reverse_rec.trx_number := l_tcnv_tbl(l_tcnv_tbl_cnt).trx_number;
                    l_reverse_rec.primary_rep_trx_id := l_tcnv_tbl(l_tcnv_tbl_cnt).ID;*/
                    REVERSE_ACCRUALS(p_api_version => l_api_version,
                                    p_init_msg_list => l_init_msg_list,
				    x_return_status => l_return_status,
				    x_msg_count => l_msg_count,
                                    x_msg_data => l_msg_data,
                                    x_rev_tcnv_tbl => l_can_tcnv_tbl,
                                    x_rev_tclv_tbl => l_can_tclv_tbl,
			            x_memo_tcnv_tbl => l_tcnv_tbl,
				    x_memo_tclv_tbl => l_tclv_tbl,
                                    p_reverse_rec => l_reverse_rec,
                                    p_representation_type => 'SECONDARY' );
                    -- store the highest degree of error
                    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                        -- need to leave
                        Okl_Api.set_message(p_app_name     => g_app_name,
                                           p_msg_name     => 'OKL_AGN_REV_ACR_ERROR',
                                           p_token1       => g_contract_number_token,
                                           p_token1_value => l_contract_number);
                        -- Select the contract for error reporting
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                        Okl_Api.set_message(p_app_name     => g_app_name,
                                           p_msg_name     => 'OKL_AGN_REV_ACR_ERROR',
                                           p_token1       => g_contract_number_token,
                                           p_token1_value => l_contract_number);
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;
                    END IF;
                    -- Report Content for reverse accruals
                    IF p_process_accrual_rec.submission_mode='BATCH' THEN
	                    IF l_can_tcnv_tbl.COUNT > 0 THEN
	                    FOR x IN l_can_tcnv_tbl.FIRST..l_can_tcnv_tbl.LAST
						LOOP
	                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                     RPAD(l_can_tcnv_tbl(x).trx_number,22)||
		                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVERSE'),17)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).update_status_yn,0,0),16)||
		                                     RPAD(l_can_tcnv_tbl(x).currency_code,9)||
	                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_can_tcnv_tbl(x).amount,l_can_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
	                    END LOOP;
	                    END IF; --IF l_can_tcnv_tbl.COUNT > 0 THEN

	                    -- Report Content for non-accruals
	                    IF l_tcnv_tbl.COUNT > 0 THEN
	                    FOR x IN l_tcnv_tbl.FIRST..l_tcnv_tbl.LAST
						LOOP
	                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                     RPAD(l_tcnv_tbl(x).trx_number,22)||
		                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).update_status_yn,0,0),16)||
		                                     RPAD(l_tcnv_tbl(x).currency_code,9)||
	                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_tbl(x).amount,l_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
	                    END LOOP;
	                    END IF; --IF l_tcnv_tbl.COUNT > 0 THEN
                    END IF; -- if p_process_accrual_rec.submission_mode = 'BATCH'

                    END IF;
                    G_trx_number_tbl.DELETE;
                    -- MGAAP end 7263041
                  END IF;
				  -- Create Memo Entries
                l_tcnv_rec.trx_number := null;  -- Bug 7555143
                l_tcnv_rec.ID := null;
                  IF l_stream_tbl.COUNT > 0 THEN
                    -- Calculate total amount for transaction header
                    FOR i IN l_stream_tbl.FIRST..l_stream_tbl.LAST
                    LOOP
                      l_total := l_total + l_stream_tbl(i).stream_amount;
                    END LOOP;
                    -- Build the accrual record
                    l_accrual_rec.contract_id         := l_contract_id;
                    l_accrual_rec.set_of_books_id     := l_sob_id;
                    l_accrual_rec.accrual_date        := l_accrual_date;
                    l_accrual_rec.trx_date            := l_accrual_date;
                    l_accrual_rec.contract_number     := l_contract_number;
                    l_accrual_rec.rule_result         := l_rule_result;
                    l_accrual_rec.override_status     := l_override_status;
                    l_accrual_rec.description         := l_batch_name;
                    l_accrual_rec.amount              := l_total;
                    l_accrual_rec.currency_code       := l_khr_currency_code;
              	    l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	    l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	    l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                    l_accrual_rec.product_id          := l_product_id;
                    l_accrual_rec.trx_type_id         := l_try_id;
					l_accrual_rec.advance_arrears     := l_billing_type;
                    l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
              	    l_accrual_rec.post_to_gl          := 'Y';
               	    l_accrual_rec.gl_reversal_flag    := 'N';
               	    l_accrual_rec.memo_yn             := 'Y';
               	    l_accrual_rec.accrual_activity    := 'NON-ACCRUAL';
                    l_accrual_rec.accrual_rule_yn     := 'Y';

-- rmunjulu bug 6736148 -- start
                  l_accrual_rec.source_trx_id := p_process_accrual_rec.source_trx_id;
                  l_accrual_rec.source_trx_type := p_process_accrual_rec.source_trx_type;
-- rmunjulu bug 6736148 -- end

                    WRITE_TO_LOG('Before calling CREATE_ACCRUALS');
                    -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
                    CREATE_ACCRUALS (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_stream_tbl => l_stream_tbl);

                    -- store the highest degree of error
                    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                        -- need to leave
                        Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                        Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;
                    END IF;

	                    IF p_process_accrual_rec.submission_mode='BATCH' THEN
		                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
			                                     RPAD(l_tcnv_rec.trx_number,22)||
			                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
		                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
		                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
			                                     RPAD(l_tcnv_rec.currency_code,9)||
		                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
	                    END IF; -- if p_process_accrual_rec.submission_mode ....
                    END IF; -- IF l_stream_tbl.COUNT > 0
                    -- MGAAP start 7263041
                  IF l_stream_tbl_rep.COUNT > 0 THEN
                    -- Calculate total amount for transaction header
                    l_total := 0;
                    FOR i IN l_stream_tbl_rep.FIRST..l_stream_tbl_rep.LAST
                    LOOP
                      l_total := l_total + l_stream_tbl_rep(i).stream_amount;
                    END LOOP;
                    -- Build the accrual record
                    l_accrual_rec.contract_id         := l_contract_id;
                    l_accrual_rec.set_of_books_id     := G_SOB_ID_REP;
                    l_accrual_rec.accrual_date        := l_accrual_date;
                    l_accrual_rec.trx_date            := l_accrual_date;
                    l_accrual_rec.contract_number     := l_contract_number;
                    l_accrual_rec.rule_result         := l_rule_result;
                    l_accrual_rec.override_status     := l_override_status;
                    l_accrual_rec.description         := l_batch_name;
                    l_accrual_rec.amount              := l_total;
                    l_accrual_rec.currency_code       := l_khr_currency_code;
              	    l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	    l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	    l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                    l_accrual_rec.product_id          := l_reporting_pdt_id;
                    l_accrual_rec.trx_type_id         := l_try_id;
		    l_accrual_rec.advance_arrears     := l_billing_type;
                    l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
              	    l_accrual_rec.post_to_gl          := 'Y';
               	    l_accrual_rec.gl_reversal_flag    := 'N';
               	    l_accrual_rec.memo_yn             := 'Y';
               	    l_accrual_rec.accrual_activity    := 'NON-ACCRUAL';
                    l_accrual_rec.accrual_rule_yn     := 'Y';
                    l_accrual_rec.trx_number          := l_tcnv_rec.trx_number;
                    l_accrual_rec.primary_rep_trx_id  := l_tcnv_rec.ID;

-- rmunjulu bug 6736148 -- start
                  l_accrual_rec.source_trx_id := p_process_accrual_rec.source_trx_id;
                  l_accrual_rec.source_trx_type := p_process_accrual_rec.source_trx_type;
-- rmunjulu bug 6736148 -- end

                    WRITE_TO_LOG('Before calling CREATE_ACCRUALS');
                    -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
                    CREATE_ACCRUALS (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_stream_tbl => l_stream_tbl_rep,
                            p_representation_type => 'SECONDARY'); --MGAAP

                    -- store the highest degree of error
                    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                        -- need to leave
                        Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                        Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;
                    END IF;

	                    IF p_process_accrual_rec.submission_mode='BATCH' THEN
		                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
			                                     RPAD(l_tcnv_rec.trx_number,22)||
			                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
		                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
		                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
			                                     RPAD(l_tcnv_rec.currency_code,9)||
		                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
	                    END IF; -- if p_process_accrual_rec.submission_mode ....
                    END IF; -- IF l_stream_tbl_rep.COUNT > 0
                    -- MGAAP end 7263041
                  END IF;
			    ELSE
			      IF l_rule_result = 'Y' THEN
                    -- Create catch up entries
                    -- populate the catchup record
			        l_catchup_rec.contract_id := l_contract_id;
				    l_catchup_rec.accrual_date := l_accrual_date;
				    l_catchup_rec.contract_number := l_contract_number;
				    l_catchup_rec.rule_result := l_rule_result;
				    l_catchup_rec.override_status := l_override_status;
				    l_catchup_rec.product_id := l_product_id;
				    l_catchup_rec.trx_type_id := l_try_id;
				    l_catchup_rec.advance_arrears := l_billing_type;
				    l_catchup_rec.factoring_synd_flag := l_factoring_synd_flag;
				    l_catchup_rec.post_to_gl := 'Y';
				    l_catchup_rec.gl_reversal_flag := 'N';
				    l_catchup_rec.memo_yn := 'N';
                    l_catchup_rec.description := l_batch_name;
                    l_catchup_rec.accrual_activity := 'CATCH-UP';

                    -- call the CATCHUP_ACCRUALS procedure
                    CATCHUP_ACCRUALS(p_api_version => l_api_version,
                                    p_init_msg_list => l_init_msg_list,
                                    x_return_status => l_return_status,
				                    x_msg_count => l_msg_count,
                                    x_msg_data => l_msg_data,
                                    x_rev_tcnv_tbl => l_can_tcnv_tbl,
                                    x_rev_tclv_tbl => l_can_tclv_tbl,
                                    x_catch_tcnv_tbl => l_tcnv_tbl,
                                    x_catch_tclv_tbl => l_tclv_tbl,
                                    p_catchup_rec => l_catchup_rec );
                    -- store the highest degree of error
                    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                        -- need to leave
                        Okl_Api.set_message(p_app_name     => g_app_name,
                                           p_msg_name     => 'OKL_AGN_CAT_ACR_ERROR',
                                           p_token1       => g_contract_number_token,
                                           p_token1_value => l_contract_number);
                        -- Select the contract for error reporting
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                        Okl_Api.set_message(p_app_name     => g_app_name,
                                           p_msg_name     => 'OKL_AGN_CAT_ACR_ERROR',
                                           p_token1       => g_contract_number_token,
                                           p_token1_value => l_contract_number);
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;
                    END IF; -- bug 2474969 moved end if which was after fnd_file
					        -- as a result catchup entries were not printing.

                   IF p_process_accrual_rec.submission_mode='BATCH' THEN
	                    --Report content for reversal of non-accrual entries
	                    IF l_can_tcnv_tbl.COUNT > 0 THEN
	                    FOR x IN l_can_tcnv_tbl.FIRST..l_can_tcnv_tbl.LAST
	                    LOOP
	                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                    RPAD(l_can_tcnv_tbl(x).trx_number,22)||
		                                    RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVERSE'),17)||
	                                        RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                        RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).update_status_yn,0,0),16)||
		                                    RPAD(l_can_tcnv_tbl(x).currency_code,9)||
	                                        LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_can_tcnv_tbl(x).amount,l_can_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
	                    END LOOP;
	                    END IF; --IF l_can_tcnv_tbl.COUNT > 0 THEN

	                    -- Report content for catchup entries
	                    IF l_tcnv_tbl.COUNT > 0 THEN
	                    FOR x IN l_tcnv_tbl.FIRST..l_tcnv_tbl.LAST
	                    LOOP
	                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                    RPAD(l_tcnv_tbl(x).trx_number,22)||
		                                    RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CATCHUP_REVENUE'),17)||
	                                        RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                        RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).update_status_yn,0,0),16)||
		                                    RPAD(l_tcnv_tbl(x).currency_code,9)||
	                                        LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_tbl(x).amount,l_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
	                    END LOOP;
	                    END IF; --IF l_tcnv_tbl.COUNT > 0 THEN
                    END IF; -- if p_process_accrual_rec.submission_mode=...
                    -- MGAAP start 7263041
                    IF (l_multi_gaap_yn = 'Y') THEN
			        l_catchup_rec.contract_id := l_contract_id;
				    l_catchup_rec.accrual_date := l_accrual_date;
				    l_catchup_rec.contract_number := l_contract_number;
				    l_catchup_rec.rule_result := l_rule_result;
				    l_catchup_rec.override_status := l_override_status;
				    l_catchup_rec.product_id := l_reporting_pdt_id;
				    l_catchup_rec.trx_type_id := l_try_id;
				    l_catchup_rec.advance_arrears := l_billing_type;
				    l_catchup_rec.factoring_synd_flag := l_factoring_synd_flag;
				    l_catchup_rec.post_to_gl := 'Y';
				    l_catchup_rec.gl_reversal_flag := 'N';
				    l_catchup_rec.memo_yn := 'N';
                    l_catchup_rec.description := l_batch_name;
                    l_catchup_rec.accrual_activity := 'CATCH-UP';
                    -- MGAAP start
                    /*l_tcnv_tbl_cnt := l_tcnv_tbl.count;
                    l_catchup_rec.trx_number := l_tcnv_tbl(l_tcnv_tbl_cnt).trx_number;
                    l_catchup_rec.primary_rep_trx_id := l_tcnv_tbl(l_tcnv_tbl_cnt).ID;*/
                    -- MGAAP end

                    -- call the CATCHUP_ACCRUALS procedure
                    CATCHUP_ACCRUALS(p_api_version => l_api_version,
                                    p_init_msg_list => l_init_msg_list,
                                    x_return_status => l_return_status,
				    x_msg_count => l_msg_count,
                                    x_msg_data => l_msg_data,
                                    x_rev_tcnv_tbl => l_can_tcnv_tbl,
                                    x_rev_tclv_tbl => l_can_tclv_tbl,
                                    x_catch_tcnv_tbl => l_tcnv_tbl,
                                    x_catch_tclv_tbl => l_tclv_tbl,
                                    p_catchup_rec => l_catchup_rec,
                                    p_representation_type => 'SECONDARY' );
                    -- store the highest degree of error
                    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                        -- need to leave
                        Okl_Api.set_message(p_app_name     => g_app_name,
                                           p_msg_name     => 'OKL_AGN_CAT_ACR_ERROR',
                                           p_token1       => g_contract_number_token,
                                           p_token1_value => l_contract_number);
                        -- Select the contract for error reporting
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                      ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                        Okl_Api.set_message(p_app_name     => g_app_name,
                                           p_msg_name     => 'OKL_AGN_CAT_ACR_ERROR',
                                           p_token1       => g_contract_number_token,
                                           p_token1_value => l_contract_number);
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                      END IF;
                    END IF; -- bug 2474969 moved end if which was after fnd_file
					        -- as a result catchup entries were not printing.

                   IF p_process_accrual_rec.submission_mode='BATCH' THEN
	                    --Report content for reversal of non-accrual entries
	                    IF l_can_tcnv_tbl.COUNT > 0 THEN
	                    FOR x IN l_can_tcnv_tbl.FIRST..l_can_tcnv_tbl.LAST
	                    LOOP
	                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                    RPAD(l_can_tcnv_tbl(x).trx_number,22)||
		                                    RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVERSE'),17)||
	                                        RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                        RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).update_status_yn,0,0),16)||
		                                    RPAD(l_can_tcnv_tbl(x).currency_code,9)||
	                                        LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_can_tcnv_tbl(x).amount,l_can_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
	                    END LOOP;
	                    END IF; --IF l_can_tcnv_tbl.COUNT > 0 THEN

	                    -- Report content for catchup entries
	                    IF l_tcnv_tbl.COUNT > 0 THEN
	                    FOR x IN l_tcnv_tbl.FIRST..l_tcnv_tbl.LAST
	                    LOOP
	                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                    RPAD(l_tcnv_tbl(x).trx_number,22)||
		                                    RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CATCHUP_REVENUE'),17)||
	                                        RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                        RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).update_status_yn,0,0),16)||
		                                    RPAD(l_tcnv_tbl(x).currency_code,9)||
	                                        LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_tbl(x).amount,l_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
	                    END LOOP;
	                    END IF; --IF l_tcnv_tbl.COUNT > 0 THEN
                    END IF; -- if p_process_accrual_rec.submission_mode=...
                    END IF;
                    G_trx_number_tbl.DELETE;
                    -- MGAAP end 7263041

                l_tcnv_rec.trx_number := null;  -- Bug 7555143
                l_tcnv_rec.ID := null;
                    -- Create Accrual entries
                    IF l_stream_tbl.COUNT > 0 THEN
                      -- Calculate total amount for transaction header
                      FOR i IN l_stream_tbl.FIRST..l_stream_tbl.LAST
                      LOOP
                        l_total := l_total + l_stream_tbl(i).stream_amount;
                      END LOOP;
				      -- Build the accrual record
                      l_accrual_rec.contract_id         := l_contract_id;
                      l_accrual_rec.set_of_books_id     := l_sob_id;
                      l_accrual_rec.accrual_date        := l_accrual_date;
                      l_accrual_rec.trx_date            := l_accrual_date;
                      l_accrual_rec.contract_number     := l_contract_number;
                      l_accrual_rec.rule_result         := l_rule_result;
                      l_accrual_rec.override_status     := l_override_status;
                      l_accrual_rec.description         := l_batch_name;
             	      l_accrual_rec.amount              := l_total;
              	      l_accrual_rec.currency_code       := l_khr_currency_code;
              	      l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	      l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	      l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                      l_accrual_rec.product_id          := l_product_id;
                      l_accrual_rec.trx_type_id         := l_try_id;
                      l_accrual_rec.advance_arrears     := l_billing_type;
                      l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
                	  l_accrual_rec.post_to_gl          := 'Y';
               	      l_accrual_rec.gl_reversal_flag    := 'N';
               	      l_accrual_rec.memo_yn             := 'N';
               	      l_accrual_rec.accrual_activity    := 'ACCRUAL';
                      l_accrual_rec.accrual_rule_yn     := 'Y';

-- rmunjulu bug 6736148 -- start
                  l_accrual_rec.source_trx_id := p_process_accrual_rec.source_trx_id;
                  l_accrual_rec.source_trx_type := p_process_accrual_rec.source_trx_type;
-- rmunjulu bug 6736148 -- end

                      -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
                      CREATE_ACCRUALS (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_stream_tbl => l_stream_tbl);
                      -- store the highest degree of error
                      IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                          -- need to leave
                          Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                          Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;
                      END IF;
                      IF p_process_accrual_rec.submission_mode='BATCH' THEN
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
                       END IF; -- if p_process_accrual_rec.submission_mode..
                    END IF; -- IF l_stream_tbl.COUNT > 0
                    -- MGAAP start 7263041
                    IF l_stream_tbl_rep.COUNT > 0 THEN
                      -- Calculate total amount for transaction header
                      l_total := 0;
                      FOR i IN l_stream_tbl_rep.FIRST..l_stream_tbl_rep.LAST
                      LOOP
                        l_total := l_total + l_stream_tbl_rep(i).stream_amount;
                      END LOOP;
				      -- Build the accrual record
                      l_accrual_rec.contract_id         := l_contract_id;
                      l_accrual_rec.set_of_books_id     := G_SOB_ID_REP;
                      l_accrual_rec.accrual_date        := l_accrual_date;
                      l_accrual_rec.trx_date            := l_accrual_date;
                      l_accrual_rec.contract_number     := l_contract_number;
                      l_accrual_rec.rule_result         := l_rule_result;
                      l_accrual_rec.override_status     := l_override_status;
                      l_accrual_rec.description         := l_batch_name;
             	      l_accrual_rec.amount              := l_total;
              	      l_accrual_rec.currency_code       := l_khr_currency_code;
              	      l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	      l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	      l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                      l_accrual_rec.product_id          := l_reporting_pdt_id;
                      l_accrual_rec.trx_type_id         := l_try_id;
                      l_accrual_rec.advance_arrears     := l_billing_type;
                      l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
                      l_accrual_rec.post_to_gl          := 'Y';
               	      l_accrual_rec.gl_reversal_flag    := 'N';
               	      l_accrual_rec.memo_yn             := 'N';
               	      l_accrual_rec.accrual_activity    := 'ACCRUAL';
                      l_accrual_rec.accrual_rule_yn     := 'Y';
                      -- MGAAP start
                      l_accrual_rec.trx_number     := l_tcnv_rec.trx_number;
                      l_accrual_rec.primary_rep_trx_id     := l_tcnv_rec.ID;
                      -- MGAAP end

-- rmunjulu bug 6736148 -- start
                  l_accrual_rec.source_trx_id := p_process_accrual_rec.source_trx_id;
                  l_accrual_rec.source_trx_type := p_process_accrual_rec.source_trx_type;
-- rmunjulu bug 6736148 -- end

                      -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
                      CREATE_ACCRUALS (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_stream_tbl => l_stream_tbl_rep,
                            p_representation_type => 'SECONDARY');
                      -- store the highest degree of error
                      IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                          -- need to leave
                          Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                          Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                          RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;
                      END IF;
                      IF p_process_accrual_rec.submission_mode='BATCH' THEN
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
                       END IF; -- if p_process_accrual_rec.submission_mode..
                    END IF; -- IF l_stream_tbl_rep.COUNT > 0
                    -- MGAAP end 7263041
				  ELSE
				  -- Create Memo Entries
                l_tcnv_rec.trx_number := null;  -- Bug 7555143
                l_tcnv_rec.ID := null;
                  IF l_stream_tbl.COUNT > 0 THEN
                    -- Calculate total amount for transaction header
                    FOR i IN l_stream_tbl.FIRST..l_stream_tbl.LAST
                    LOOP
                      l_total := l_total + l_stream_tbl(i).stream_amount;
                    END LOOP;
                    -- Build the accrual record
                    l_accrual_rec.contract_id         := l_contract_id;
                    l_accrual_rec.set_of_books_id     := l_sob_id;
                    l_accrual_rec.accrual_date        := l_accrual_date;
                 	l_accrual_rec.trx_date            := l_accrual_date;
                    l_accrual_rec.contract_number     := l_contract_number;
                    l_accrual_rec.rule_result         := l_rule_result;
                    l_accrual_rec.override_status     := l_override_status;
                    l_accrual_rec.description         := l_batch_name;
                 	l_accrual_rec.amount              := l_total;
              	    l_accrual_rec.currency_code       := l_khr_currency_code;
              	    l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	    l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	    l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                    l_accrual_rec.product_id          := l_product_id;
                    l_accrual_rec.trx_type_id         := l_try_id;
					l_accrual_rec.advance_arrears     := l_billing_type;
                    l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
            	    l_accrual_rec.post_to_gl          := 'Y';
               	    l_accrual_rec.gl_reversal_flag    := 'N';
                    l_accrual_rec.memo_yn             := 'Y';
                    l_accrual_rec.accrual_activity    := 'NON-ACCRUAL';
                    l_accrual_rec.accrual_rule_yn     := 'Y';

-- rmunjulu bug 6736148 -- start
                  l_accrual_rec.source_trx_id := p_process_accrual_rec.source_trx_id;
                  l_accrual_rec.source_trx_type := p_process_accrual_rec.source_trx_type;
-- rmunjulu bug 6736148 -- end

                    -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
                    CREATE_ACCRUALS (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_stream_tbl => l_stream_tbl);

                  -- store the highest degree of error
                  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                      -- need to leave
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                  END IF;

                  IF p_process_accrual_rec.submission_mode='BATCH' THEN
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
  	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
                  END IF; -- if p_process_accrual_rec.submission_mode..
                  END IF; -- IF l_stream_tbl.COUNT > 0
                  -- MGAAP start 7263041
                  IF l_stream_tbl_rep.COUNT > 0 THEN
                    -- Calculate total amount for transaction header
                    l_total := 0;
                    FOR i IN l_stream_tbl_rep.FIRST..l_stream_tbl_rep.LAST
                    LOOP
                      l_total := l_total + l_stream_tbl_rep(i).stream_amount;
                    END LOOP;
                    -- Build the accrual record
                    l_accrual_rec.contract_id         := l_contract_id;
                    l_accrual_rec.set_of_books_id     := G_SOB_ID_REP;
                    l_accrual_rec.accrual_date        := l_accrual_date;
                    l_accrual_rec.trx_date            := l_accrual_date;
                    l_accrual_rec.contract_number     := l_contract_number;
                    l_accrual_rec.rule_result         := l_rule_result;
                    l_accrual_rec.override_status     := l_override_status;
                    l_accrual_rec.description         := l_batch_name;
                    l_accrual_rec.amount              := l_total;
              	    l_accrual_rec.currency_code       := l_khr_currency_code;
              	    l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	    l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	    l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                    l_accrual_rec.product_id          := l_reporting_pdt_id;
                    l_accrual_rec.trx_type_id         := l_try_id;
		    l_accrual_rec.advance_arrears     := l_billing_type;
                    l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
            	    l_accrual_rec.post_to_gl          := 'Y';
               	    l_accrual_rec.gl_reversal_flag    := 'N';
                    l_accrual_rec.memo_yn             := 'Y';
                    l_accrual_rec.accrual_activity    := 'NON-ACCRUAL';
                    l_accrual_rec.accrual_rule_yn     := 'Y';

                      -- MGAAP start
                      l_accrual_rec.trx_number     := l_tcnv_rec.trx_number;
                      l_accrual_rec.primary_rep_trx_id     := l_tcnv_rec.ID;
                      -- MGAAP end

-- rmunjulu bug 6736148 -- start
                  l_accrual_rec.source_trx_id := p_process_accrual_rec.source_trx_id;
                  l_accrual_rec.source_trx_type := p_process_accrual_rec.source_trx_type;
-- rmunjulu bug 6736148 -- end

                    -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
                    CREATE_ACCRUALS (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_stream_tbl => l_stream_tbl_rep,
                            p_representation_type => 'SECONDARY');

                  -- store the highest degree of error
                  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                      -- need to leave
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                  END IF;

                  IF p_process_accrual_rec.submission_mode='BATCH' THEN
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
  	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
                  END IF; -- if p_process_accrual_rec.submission_mode..
                  END IF; -- IF l_stream_tbl.COUNT > 0
                  -- MGAAP end 7263041
                END IF;
              END IF;
            ELSE
			  IF l_previous_override_status = 'N' THEN
			    IF l_previous_accrual_status = 'Y' THEN
                  -- populate the reverse record
				  l_reverse_rec.contract_id := l_contract_id;
				  l_reverse_rec.reverse_date_to := l_reverse_date_to;
				  l_reverse_rec.accrual_date := l_accrual_date;
				  l_reverse_rec.contract_number := l_contract_number;
				  l_reverse_rec.rule_result := l_rule_result;
				  l_reverse_rec.override_status := l_override_status;
				  l_reverse_rec.product_id := l_product_id;
				  l_reverse_rec.trx_type_id := l_try_id;
				  l_reverse_rec.advance_arrears := l_billing_type;
				  l_reverse_rec.factoring_synd_flag := l_factoring_synd_flag;
				  l_reverse_rec.post_to_gl := 'Y';
				  l_reverse_rec.gl_reversal_flag := 'N';
				  l_reverse_rec.memo_yn := 'Y';
                  l_reverse_rec.description := l_batch_name;
                  l_reverse_rec.accrual_activity := 'REVERSAL';

                  -- call the REVERSE_ACCRUALS procedure
                  REVERSE_ACCRUALS(p_api_version => l_api_version,
                                    p_init_msg_list => l_init_msg_list,
				                    x_return_status => l_return_status,
				                    x_msg_count => l_msg_count,
                                    x_msg_data => l_msg_data,
                                    x_rev_tcnv_tbl => l_can_tcnv_tbl,
                                    x_rev_tclv_tbl => l_can_tclv_tbl,
									x_memo_tcnv_tbl => l_tcnv_tbl,
									x_memo_tclv_tbl => l_tclv_tbl,
                                    p_reverse_rec => l_reverse_rec );
                  -- store the highest degree of error
                  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                       -- need to leave
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                           p_msg_name     => 'OKL_AGN_REV_ACR_ERROR',
                                           p_token1       => g_contract_number_token,
                                           p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                           p_msg_name     => 'OKL_AGN_REV_ACR_ERROR',
                                           p_token1       => g_contract_number_token,
                                           p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
				  END IF;

                  IF p_process_accrual_rec.submission_mode='BATCH' THEN
	                  -- Report Content for reverse accruals
	                  IF l_tcnv_tbl.COUNT > 0 THEN
	                  FOR x IN l_can_tcnv_tbl.FIRST..l_can_tcnv_tbl.LAST
	                  LOOP
	                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                     RPAD(l_can_tcnv_tbl(x).trx_number,22)||
		                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVERSE'),17)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).update_status_yn,0,0),16)||
		                                     RPAD(l_can_tcnv_tbl(x).currency_code,9)||
	                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_can_tcnv_tbl(x).amount,l_can_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
	                  END LOOP;
	                  END IF; --IF l_tcnv_tbl.COUNT > 0 THEN

	                  -- Report Content for non-accruals
	                  IF l_tcnv_tbl.COUNT > 0 THEN
	                  FOR x IN l_tcnv_tbl.FIRST..l_tcnv_tbl.LAST
	                  LOOP
	                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                     RPAD(l_tcnv_tbl(x).trx_number,22)||
		                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).update_status_yn,0,0),16)||
		                                     RPAD(l_tcnv_tbl(x).currency_code,9)||
	                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_tbl(x).amount,l_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
	                  END LOOP;
	                  END IF; --IF l_tcnv_tbl.COUNT > 0 THEN
                   END IF; -- IF p_process_accrual_rec.submission_mode=...
                   -- MGAAP start 7263041
                  -- call the REVERSE_ACCRUALS procedure
                  IF (l_multi_gaap_yn = 'Y') THEN
                    l_reverse_rec.product_id := l_reporting_pdt_id;
                    /*l_tcnv_tbl_cnt := l_tcnv_tbl.count;
                    l_reverse_rec.trx_number := l_tcnv_tbl(l_tcnv_tbl_cnt).trx_number;
                    l_reverse_rec.primary_rep_trx_id := l_tcnv_tbl(l_tcnv_tbl_cnt).ID;*/
                  REVERSE_ACCRUALS(p_api_version => l_api_version,
                                    p_init_msg_list => l_init_msg_list,
				    x_return_status => l_return_status,
				    x_msg_count => l_msg_count,
                                    x_msg_data => l_msg_data,
                                    x_rev_tcnv_tbl => l_can_tcnv_tbl,
                                    x_rev_tclv_tbl => l_can_tclv_tbl,
				    x_memo_tcnv_tbl => l_tcnv_tbl,
				    x_memo_tclv_tbl => l_tclv_tbl,
                                    p_reverse_rec => l_reverse_rec,
                                    p_representation_type => 'SECONDARY' );
                  -- store the highest degree of error
                  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                       -- need to leave
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                           p_msg_name     => 'OKL_AGN_REV_ACR_ERROR',
                                           p_token1       => g_contract_number_token,
                                           p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                           p_msg_name     => 'OKL_AGN_REV_ACR_ERROR',
                                           p_token1       => g_contract_number_token,
                                           p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
				  END IF;

                  IF p_process_accrual_rec.submission_mode='BATCH' THEN
	                  -- Report Content for reverse accruals
	                  IF l_tcnv_tbl.COUNT > 0 THEN
	                  FOR x IN l_can_tcnv_tbl.FIRST..l_can_tcnv_tbl.LAST
	                  LOOP
	                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                     RPAD(l_can_tcnv_tbl(x).trx_number,22)||
		                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVERSE'),17)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_can_tcnv_tbl(x).update_status_yn,0,0),16)||
		                                     RPAD(l_can_tcnv_tbl(x).currency_code,9)||
	                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_can_tcnv_tbl(x).amount,l_can_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
	                  END LOOP;
	                  END IF; --IF l_tcnv_tbl.COUNT > 0 THEN

	                  -- Report Content for non-accruals
	                  IF l_tcnv_tbl.COUNT > 0 THEN
	                  FOR x IN l_tcnv_tbl.FIRST..l_tcnv_tbl.LAST
	                  LOOP
	                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
		                                     RPAD(l_tcnv_tbl(x).trx_number,22)||
		                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).accrual_status_yn,0,0),20)||
	                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_tbl(x).update_status_yn,0,0),16)||
		                                     RPAD(l_tcnv_tbl(x).currency_code,9)||
	                                         LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_tbl(x).amount,l_tcnv_tbl(x).currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
	                  END LOOP;
	                  END IF; --IF l_tcnv_tbl.COUNT > 0 THEN
                   END IF; -- IF p_process_accrual_rec.submission_mode=...
                  END IF;
                  G_trx_number_tbl.DELETE;
                   -- MGAAP end 7263041
				END IF;
              END IF;

              l_tcnv_rec.trx_number := null;  -- Bug 7555143
              l_tcnv_rec.ID := null;
			  -- Create Memo Entries
              IF l_stream_tbl.COUNT > 0 THEN
                -- Calculate total amount for transaction header
                FOR i IN l_stream_tbl.FIRST..l_stream_tbl.LAST
                LOOP
                  l_total := l_total + l_stream_tbl(i).stream_amount;
                END LOOP;
                -- Build the accrual record
                l_accrual_rec.contract_id         := l_contract_id;
                l_accrual_rec.set_of_books_id     := l_sob_id;
                l_accrual_rec.accrual_date        := l_accrual_date;
                l_accrual_rec.trx_date            := l_accrual_date;
                l_accrual_rec.contract_number     := l_contract_number;
                l_accrual_rec.rule_result         := l_rule_result;
                l_accrual_rec.override_status     := l_override_status;
                l_accrual_rec.description         := l_batch_name;
                l_accrual_rec.amount              := l_total;
            	l_accrual_rec.currency_code       := l_khr_currency_code;
              	l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                l_accrual_rec.product_id          := l_product_id;
                l_accrual_rec.trx_type_id         := l_try_id;
				l_accrual_rec.advance_arrears     := l_billing_type;
                l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
                l_accrual_rec.post_to_gl          := 'Y';
                l_accrual_rec.gl_reversal_flag    := 'N';
                l_accrual_rec.memo_yn             := 'Y';
                l_accrual_rec.accrual_activity    := 'NON-ACCRUAL';
                l_accrual_rec.accrual_rule_yn     := 'Y';

-- rmunjulu bug 6736148 -- start
                  l_accrual_rec.source_trx_id := p_process_accrual_rec.source_trx_id;
                  l_accrual_rec.source_trx_type := p_process_accrual_rec.source_trx_type;
-- rmunjulu bug 6736148 -- end

                -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
                CREATE_ACCRUALS (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_stream_tbl => l_stream_tbl);

                -- store the highest degree of error
                IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                   -- need to leave
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;
                IF p_process_accrual_rec.submission_mode='BATCH' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
                END IF; -- if p_process_accrual_rec.submission_mode...
              END IF; -- IF l_stream_tbl.COUNT > 0
              -- MGAAP start 7263041
              IF l_stream_tbl_rep.COUNT > 0 THEN
                -- Calculate total amount for transaction header
                l_total := 0;
                FOR i IN l_stream_tbl_rep.FIRST..l_stream_tbl_rep.LAST
                LOOP
                  l_total := l_total + l_stream_tbl_rep(i).stream_amount;
                END LOOP;
                -- Build the accrual record
                l_accrual_rec.contract_id         := l_contract_id;
                l_accrual_rec.set_of_books_id     := G_SOB_ID_REP;
                l_accrual_rec.accrual_date        := l_accrual_date;
                l_accrual_rec.trx_date            := l_accrual_date;
                l_accrual_rec.contract_number     := l_contract_number;
                l_accrual_rec.rule_result         := l_rule_result;
                l_accrual_rec.override_status     := l_override_status;
                l_accrual_rec.description         := l_batch_name;
                l_accrual_rec.amount              := l_total;
            	l_accrual_rec.currency_code       := l_khr_currency_code;
              	l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                l_accrual_rec.product_id          := l_reporting_pdt_id;
                l_accrual_rec.trx_type_id         := l_try_id;
		l_accrual_rec.advance_arrears     := l_billing_type;
                l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
                l_accrual_rec.post_to_gl          := 'Y';
                l_accrual_rec.gl_reversal_flag    := 'N';
                l_accrual_rec.memo_yn             := 'Y';
                l_accrual_rec.accrual_activity    := 'NON-ACCRUAL';
                l_accrual_rec.accrual_rule_yn     := 'Y';

                -- MGAAP start
                l_accrual_rec.trx_number     := l_tcnv_rec.trx_number;
                l_accrual_rec.primary_rep_trx_id     := l_tcnv_rec.ID;
                -- MGAAP end

-- rmunjulu bug 6736148 -- start
                  l_accrual_rec.source_trx_id := p_process_accrual_rec.source_trx_id;
                  l_accrual_rec.source_trx_type := p_process_accrual_rec.source_trx_type;
-- rmunjulu bug 6736148 -- end

                -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
                CREATE_ACCRUALS (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_stream_tbl => l_stream_tbl_rep,
                            p_representation_type => 'SECONDARY');

                -- store the highest degree of error
                IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                   -- need to leave
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;
                IF p_process_accrual_rec.submission_mode='BATCH' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
                END IF; -- if p_process_accrual_rec.submission_mode...
              END IF; -- IF l_stream_tbl_rep.COUNT > 0
              -- MGAAP end 7263041
  			END IF;

			-- ER 2872216 Option to ignore accrual rules.
            --Get the stream amounts for this contract which are subject to accrual rules
            -- Bug 4011843. Modified p_accrual_rule_yn value for UDS.
            l_stream_tbl.DELETE(l_stream_tbl.COUNT);
            GET_ACCRUAL_STREAMS(x_return_status => l_return_status
                               ,x_stream_tbl => l_stream_tbl
                               ,p_khr_id => l_contract_id
                               ,p_product_id => l_product_id
                               ,p_ctr_start_date => l_start_date
                               ,p_period_end_date => l_period_end_date
                               ,p_accrual_rule_yn => 'ACRL_WITHOUT_RULE');
            -- store the highest degree of error
            IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_STREAM_ERROR',
                                  p_token1       => g_contract_number_token,
                                  p_token1_value => l_contract_number);
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            l_tcnv_rec.trx_number := null;  -- Bug 7555143
            l_tcnv_rec.ID := null;
            IF l_stream_tbl.COUNT > 0 THEN

			  -- re-initialize necessary variables
			  l_total := 0;
              l_accrual_rec := NULL;

              -- Calculate total amount for transaction header
              FOR i IN l_stream_tbl.FIRST..l_stream_tbl.LAST
              LOOP
                l_total := l_total + l_stream_tbl(i).stream_amount;
              END LOOP;
              -- Build the accrual record
              -- Bug 3644681. Don't populate values for accrual rule and override flags
              l_accrual_rec.contract_id         := l_contract_id;
              l_accrual_rec.set_of_books_id     := l_sob_id;
              l_accrual_rec.accrual_date        := l_accrual_date;
         	  l_accrual_rec.trx_date            := l_accrual_date;
              l_accrual_rec.contract_number     := l_contract_number;
              l_accrual_rec.rule_result         := NULL;
              l_accrual_rec.override_status     := NULL;
              l_accrual_rec.description         := l_batch_name;
          	  l_accrual_rec.amount              := l_total;
          	  l_accrual_rec.currency_code       := l_khr_currency_code;
          	  l_accrual_rec.currency_conversion_type := l_currency_conv_type;
          	  l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
          	  l_accrual_rec.currency_conversion_date := l_currency_conv_date;
              l_accrual_rec.product_id          := l_product_id;
              l_accrual_rec.trx_type_id         := l_try_id;
              l_accrual_rec.advance_arrears     := l_billing_type;
              l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
        	  l_accrual_rec.post_to_gl          := 'Y';
          	  l_accrual_rec.gl_reversal_flag    := 'N';
          	  l_accrual_rec.memo_yn             := 'N';
          	  l_accrual_rec.accrual_activity    := 'ACCRUAL';
        	  l_accrual_rec.accrual_rule_yn     := 'N';

-- rmunjulu bug 6736148 -- start
                  l_accrual_rec.source_trx_id := p_process_accrual_rec.source_trx_id;
                  l_accrual_rec.source_trx_type := p_process_accrual_rec.source_trx_type;
-- rmunjulu bug 6736148 -- end

              -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
              CREATE_ACCRUALS (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_stream_tbl => l_stream_tbl);

              IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  -- need to leave
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => l_contract_number);
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;
              IF p_process_accrual_rec.submission_mode='BATCH' THEN
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','NOT APPLICABLE',540,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','NOT APPLICABLE',540,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
              END IF; -- if p_process_accrual_rec.submission_mode =...

            END IF; -- IF l_stream_tbl.COUNT > 0
            -- MGAAP start 7263041
            IF (l_Multi_gaap_yn = 'Y') THEN
            l_stream_tbl_rep.DELETE(l_stream_tbl_rep.COUNT); -- MGAAP 7263041

			OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;

            GET_ACCRUAL_STREAMS(x_return_status => l_return_status
                               ,x_stream_tbl => l_stream_tbl_rep
                               ,p_khr_id => l_contract_id
                               ,p_product_id => l_reporting_pdt_id
                               ,p_ctr_start_date => l_start_date
                               ,p_period_end_date => G_PERIOD_END_DATE_REP
                               ,p_accrual_rule_yn => 'ACRL_WITHOUT_RULE');
            -- store the highest degree of error

			OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;

            IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
              Okl_Api.set_message(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AGN_STREAM_ERROR',
                                  p_token1       => g_contract_number_token,
                                  p_token1_value => l_contract_number);
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            IF l_stream_tbl_rep.COUNT > 0 THEN

			  -- re-initialize necessary variables
			  l_total := 0;
              l_accrual_rec := NULL;

              -- Calculate total amount for transaction header
              l_total := 0;
              FOR i IN l_stream_tbl_rep.FIRST..l_stream_tbl_rep.LAST
              LOOP
                l_total := l_total + l_stream_tbl_rep(i).stream_amount;
              END LOOP;
              -- Build the accrual record
              -- Bug 3644681. Don't populate values for accrual rule and override flags
              l_accrual_rec.contract_id         := l_contract_id;
              l_accrual_rec.set_of_books_id     := G_sob_id_rep;
              l_accrual_rec.accrual_date        := l_accrual_date;
              l_accrual_rec.trx_date            := l_accrual_date;
              l_accrual_rec.contract_number     := l_contract_number;
              l_accrual_rec.rule_result         := NULL;
              l_accrual_rec.override_status     := NULL;
              l_accrual_rec.description         := l_batch_name;
              l_accrual_rec.amount              := l_total;
              l_accrual_rec.currency_code       := l_khr_currency_code;
              l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              l_accrual_rec.currency_conversion_date := l_currency_conv_date;
              l_accrual_rec.product_id          := l_reporting_pdt_id;
              l_accrual_rec.trx_type_id         := l_try_id;
              l_accrual_rec.advance_arrears     := l_billing_type;
              l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
              l_accrual_rec.post_to_gl          := 'Y';
              l_accrual_rec.gl_reversal_flag    := 'N';
              l_accrual_rec.memo_yn             := 'N';
              l_accrual_rec.accrual_activity    := 'ACCRUAL';
              l_accrual_rec.accrual_rule_yn     := 'N';

              -- MGAAP start
              l_accrual_rec.trx_number     := l_tcnv_rec.trx_number;
              l_accrual_rec.primary_rep_trx_id     := l_tcnv_rec.ID;
              -- MGAAP end

-- rmunjulu bug 6736148 -- start
                  l_accrual_rec.source_trx_id := p_process_accrual_rec.source_trx_id;
                  l_accrual_rec.source_trx_type := p_process_accrual_rec.source_trx_type;
-- rmunjulu bug 6736148 -- end

              -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
              CREATE_ACCRUALS (
                            p_api_version => l_api_version,
                            p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_stream_tbl => l_stream_tbl_rep,
                            p_representation_type => 'SECONDARY');

              IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  -- need to leave
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => l_contract_number);
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                          p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                          p_token1       => g_contract_number_token,
                                          p_token1_value => l_contract_number);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;
              IF p_process_accrual_rec.submission_mode='BATCH' THEN
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','NOT APPLICABLE',540,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','NOT APPLICABLE',540,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
              END IF; -- if p_process_accrual_rec.submission_mode =...

            END IF; -- IF l_stream_tbl_rep.COUNT > 0

            END IF;
            -- MGAAP end 7263041

          END IF; -- IF l_rev_rec_method IN ...


       IF l_rev_rec_method = 'ESTIMATED_AND_BILLED' THEN

          OPEN check_variable_trx(l_contract_id, l_period_end_date);
		  FETCH check_variable_trx INTO l_trx_exists;
		  CLOSE check_variable_trx;

		  IF l_trx_exists <> 'Y' THEN

--           OPEN sty_id_csr('VARIABLE INCOME ACCRUAL');
--           FETCH sty_id_csr INTO l_sty_id;
--             IF sty_id_csr%NOTFOUND THEN
--               CLOSE sty_id_csr;
--               -- store SQL error message on message stack for caller and entry in log file
--               Okl_Api.set_message(p_app_name     => g_app_name,
--                                   p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
-- 			                      p_token1       => g_stream_name_token,
-- 								  p_token1_value => 'VARIABLE INCOME ACCRUAL');
--               RAISE Okl_Api.G_EXCEPTION_ERROR;
--             END IF;
--           CLOSE sty_id_csr;

          -- Get the stream type id for variable interest rate product
          OKL_STREAMS_UTIL.get_dependent_stream_type(
            p_khr_id  		   	    => l_contract_id,
            p_primary_sty_purpose   => 'VARIABLE_INTEREST',
            p_dependent_sty_purpose => 'VARIABLE_INTEREST_INCOME',
            x_return_status		    => l_return_status,
            x_dependent_sty_id      => l_sty_id);

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            -- store SQL error message on message stack for caller and entry in log file
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
	                            p_token1       => g_stream_name_token,
			                    p_token1_value => 'VARIABLE INTEREST INCOME');
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;

          -- MGAAP 7263041 start
          IF (l_multi_gaap_yn = 'Y') THEN
          -- Get the stream type id for variable interest rate product
          OKL_STREAMS_UTIL.get_dependent_stream_type_rep(
            p_khr_id  		   	    => l_contract_id,
            p_primary_sty_purpose   => 'VARIABLE_INTEREST',
            p_dependent_sty_purpose => 'VARIABLE_INTEREST_INCOME',
            x_return_status		    => l_return_status,
            x_dependent_sty_id      => l_sty_id_rep);

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            -- store SQL error message on message stack for caller and entry in log file
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
	                            p_token1       => g_stream_name_token,
			                    p_token1_value => 'VARIABLE INTEREST INCOME');
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
          END IF;
          -- MGAAP 7263041 end

          -- Get last interest calculated date
		  OPEN last_int_date_csr(l_contract_id);
		  FETCH last_int_date_csr INTO l_last_interest_calc_date;
		  CLOSE last_int_date_csr;

          -- Get revenue recognition basis from stream type
		  FOR x IN get_rev_rec_basis_csr(l_sty_id)
          LOOP
            l_rev_rec_basis := x.accrual_yn;
          END LOOP;

          -- if last interest date is null then calculate from contract start date
          -- recommended as per PM on 07-31-02
          -- Bug 5136000. Subtracting one day from contract start date since
          -- one day is being added to the last int calc date in the function contract
          -- days to accrue.
          -- Bug 5162929.
          -- Undoing changes made in bug 5136000 as per PM recommendation.14-Apr-2006.
          -- Adding a day to the last interest calculation date.
		  IF l_last_interest_calc_date IS NULL THEN
		    l_last_interest_calc_date := l_start_date;
          ELSE
		    l_last_interest_calc_date := l_last_interest_calc_date+1;
          END IF;

		  -- process only for balance period, else do nothing
          IF l_accrual_date - l_last_interest_calc_date > 0 THEN
            IF l_rev_rec_basis = 'ACRL_WITH_RULE' THEN
            IF l_override_status = 'N' THEN
              -- Check the override status and current accrual status and process accordingly
              IF l_rule_result = 'Y' THEN
                --Create Accrual Entries and Corresponding Reversal Entries
                l_ctxt_val_tbl(1).NAME := 'p_accrual_date';
                l_ctxt_val_tbl(1).VALUE := TO_CHAR(l_accrual_date, 'MM/DD/YYYY');
                l_ctxt_val_tbl(2).NAME := 'p_last_int_calc_date';
                l_ctxt_val_tbl(2).VALUE := TO_CHAR(l_last_interest_calc_date, 'MM/DD/YYYY');
                l_ctxt_val_tbl(3).NAME := 'p_period_start_date';
                l_ctxt_val_tbl(3).VALUE := TO_CHAR(l_period_start_date, 'MM/DD/YYYY');
                l_ctxt_val_tbl(4).NAME := 'p_period_end_date';
                l_ctxt_val_tbl(4).VALUE := TO_CHAR(l_period_end_date, 'MM/DD/YYYY');
    		    --Create Accrual Entries
                -- Build the accrual record
                l_accrual_rec.contract_id         := l_contract_id;
                l_accrual_rec.set_of_books_id     := l_sob_id;
                l_accrual_rec.accrual_date        := l_accrual_date;
                l_accrual_rec.trx_date            := l_accrual_date;
                l_accrual_rec.contract_number     := l_contract_number;
                l_accrual_rec.rule_result         := l_rule_result;
                l_accrual_rec.override_status     := l_override_status;
                l_accrual_rec.description         := l_batch_name;
                l_accrual_rec.amount              := 0;
              	l_accrual_rec.currency_code       := l_khr_currency_code;
              	l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                l_accrual_rec.product_id          := l_product_id;
                l_accrual_rec.trx_type_id         := l_try_id;
                l_accrual_rec.sty_id              := l_sty_id;
				l_accrual_rec.advance_arrears     := l_billing_type;
                l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
                l_accrual_rec.post_to_gl          := 'Y';
                l_accrual_rec.gl_reversal_flag    := 'Y';
                l_accrual_rec.memo_yn             := 'N';
                l_accrual_rec.accrual_activity    := 'ACCRUAL';
                l_accrual_rec.accrual_rule_yn     := 'Y';
                --Added by dpsingh for SLA Uptake (Bug 5707866)
                OPEN get_accrual_reversal_date(l_accrual_rec.set_of_books_id, l_accrual_rec.accrual_date);
                FETCH get_accrual_reversal_date into l_accrual_rec.accrual_reversal_date;
                CLOSE get_accrual_reversal_date;

                -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
                l_tcnv_rec.trx_number := null;  -- Bug 7555143
                l_tcnv_rec.ID := null;
                CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl);

                -- store the highest degree of error
                IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    -- need to leave
                     Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;
                IF p_process_accrual_rec.submission_mode='BATCH' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
		         END IF; -- if p_process_accrual_rec.submission_mode=...
                -- MGAAP 7263041 start
                IF (l_multi_gaap_yn = 'Y') THEN
                  l_accrual_rec.set_of_books_id     := G_SOB_ID_REP;
                  l_accrual_rec.product_id          := l_reporting_pdt_id;
                  l_accrual_rec.sty_id              := l_sty_id_rep;
                  l_accrual_rec.trx_number := l_tcnv_rec.trx_number;
                  l_accrual_rec.primary_rep_trx_id := l_tcnv_rec.id;
                OPEN get_accrual_reversal_date(l_accrual_rec.set_of_books_id, l_accrual_rec.accrual_date);
                FETCH get_accrual_reversal_date into l_accrual_rec.accrual_reversal_date;
                CLOSE get_accrual_reversal_date;

                -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries for SECONDARY
                CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl,
                            p_representation_type => 'SECONDARY'); -- MGAAP

                -- store the highest degree of error
                IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    -- need to leave
                     Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;
                IF p_process_accrual_rec.submission_mode='BATCH' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
		         END IF; -- if p_process_accrual_rec.submission_mode=...
                END IF;
                -- MGAAP 7263041 end
              ELSE
                -- Create Non-Accrual(memo) entries and Corresponding Reversal entries
                l_ctxt_val_tbl(1).NAME := 'p_accrual_date';
                l_ctxt_val_tbl(1).VALUE := TO_CHAR(l_accrual_date, 'MM/DD/YYYY');
                l_ctxt_val_tbl(2).NAME := 'p_last_int_calc_date';
                l_ctxt_val_tbl(2).VALUE := TO_CHAR(l_last_interest_calc_date, 'MM/DD/YYYY');
                l_ctxt_val_tbl(3).NAME := 'p_period_start_date';
                l_ctxt_val_tbl(3).VALUE := TO_CHAR(l_period_start_date, 'MM/DD/YYYY');
                l_ctxt_val_tbl(4).NAME := 'p_period_end_date';
                l_ctxt_val_tbl(4).VALUE := TO_CHAR(l_period_end_date, 'MM/DD/YYYY');

                --Create Accrual Entries
                -- Build the accrual record
                l_accrual_rec.contract_id         := l_contract_id;
                l_accrual_rec.set_of_books_id     := l_sob_id;
                l_accrual_rec.accrual_date        := l_accrual_date;
             	l_accrual_rec.trx_date            := l_accrual_date;
                l_accrual_rec.contract_number     := l_contract_number;
                l_accrual_rec.rule_result         := l_rule_result;
                l_accrual_rec.override_status     := l_override_status;
                l_accrual_rec.description         := l_batch_name;
           	    l_accrual_rec.amount              := 0;
              	l_accrual_rec.currency_code       := l_khr_currency_code;
              	l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                l_accrual_rec.product_id          := l_product_id;
                l_accrual_rec.trx_type_id         := l_try_id;
                l_accrual_rec.sty_id              := l_sty_id;
                l_accrual_rec.advance_arrears     := l_billing_type;
                l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
          	    l_accrual_rec.post_to_gl          := 'Y';
           	    l_accrual_rec.gl_reversal_flag    := 'Y';
           	    l_accrual_rec.memo_yn             := 'Y';
                l_accrual_rec.accrual_activity    := 'NON-ACCRUAL';
                l_accrual_rec.accrual_rule_yn     := 'Y';
                 --Added by dpsingh for SLA Uptake (Bug 5707866)
                OPEN get_accrual_reversal_date(l_accrual_rec.set_of_books_id, l_accrual_rec.accrual_date);
                FETCH get_accrual_reversal_date into l_accrual_rec.accrual_reversal_date;
                CLOSE get_accrual_reversal_date;

                l_tcnv_rec.trx_number := null;  -- Bug 7555143
                l_tcnv_rec.ID := null;
                -- Call CREATE_ACCRUAL_FORMULA procedure to create accrual transactions and entries
                CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl);

                -- store the highest degree of error
                IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    -- need to leave
                     Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;

                IF p_process_accrual_rec.submission_mode='BATCH' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
                END IF; -- if p_process_accrual_rec.submission_mode=..

              -- MGAAP 7263041 start
              IF (l_multi_gaap_yn = 'Y') THEN
                  l_accrual_rec.set_of_books_id     := G_SOB_ID_REP;
                  l_accrual_rec.product_id          := l_reporting_pdt_id;
                  l_accrual_rec.sty_id              := l_sty_id_rep;
                  l_accrual_rec.trx_number := l_tcnv_rec.trx_number;
                  l_accrual_rec.primary_rep_trx_id := l_tcnv_rec.id;
                OPEN get_accrual_reversal_date(l_accrual_rec.set_of_books_id, l_accrual_rec.accrual_date);
                FETCH get_accrual_reversal_date into l_accrual_rec.accrual_reversal_date;
                CLOSE get_accrual_reversal_date;
                -- Call CREATE_ACCRUAL_FORMULA procedure to create accrual transactions and entries for SECONDARY
                CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl,
                            p_representation_type => 'SECONDARY'); -- MGAAP

                -- store the highest degree of error
                IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    -- need to leave
                     Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;

                IF p_process_accrual_rec.submission_mode='BATCH' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
                END IF; -- if p_process_accrual_rec.submission_mode=..

              END IF;
              -- MGAAP 7263041 end
              END IF;
            ELSE
              -- Create MEMO entries
              l_ctxt_val_tbl(1).NAME := 'p_accrual_date';
              l_ctxt_val_tbl(1).VALUE := TO_CHAR(l_accrual_date, 'MM/DD/YYYY');
              l_ctxt_val_tbl(2).NAME := 'p_last_int_calc_date';
              l_ctxt_val_tbl(2).VALUE := TO_CHAR(l_last_interest_calc_date, 'MM/DD/YYYY');
              l_ctxt_val_tbl(3).NAME := 'p_period_start_date';
              l_ctxt_val_tbl(3).VALUE := TO_CHAR(l_period_start_date, 'MM/DD/YYYY');
              l_ctxt_val_tbl(4).NAME := 'p_period_end_date';
              l_ctxt_val_tbl(4).VALUE := TO_CHAR(l_period_end_date, 'MM/DD/YYYY');
              --Create Accrual Entries
              -- Build the accrual record
              l_accrual_rec.contract_id         := l_contract_id;
              l_accrual_rec.set_of_books_id     := l_sob_id;
              l_accrual_rec.accrual_date        := l_accrual_date;
              l_accrual_rec.trx_date            := l_accrual_date;
              l_accrual_rec.contract_number     := l_contract_number;
              l_accrual_rec.rule_result         := l_rule_result;
              l_accrual_rec.override_status     := l_override_status;
              l_accrual_rec.description         := l_batch_name;
              l_accrual_rec.amount              := 0;
              l_accrual_rec.currency_code       := l_khr_currency_code;
              l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              l_accrual_rec.currency_conversion_date := l_currency_conv_date;
              l_accrual_rec.product_id          := l_product_id;
              l_accrual_rec.trx_type_id         := l_try_id;
              l_accrual_rec.sty_id              := l_sty_id;
              l_accrual_rec.advance_arrears     := l_billing_type;
              l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
              l_accrual_rec.post_to_gl          := 'Y';
              l_accrual_rec.gl_reversal_flag    := 'Y';
              l_accrual_rec.memo_yn             := 'Y';
              l_accrual_rec.accrual_activity    := 'NON-ACCRUAL';
              l_accrual_rec.accrual_rule_yn     := 'Y';
               --Added by dpsingh for SLA Uptake (Bug 5707866)
                OPEN get_accrual_reversal_date(l_accrual_rec.set_of_books_id, l_accrual_rec.accrual_date);
                FETCH get_accrual_reversal_date into l_accrual_rec.accrual_reversal_date;
                CLOSE get_accrual_reversal_date;

              l_tcnv_rec.trx_number := null;  -- Bug 7555143
              l_tcnv_rec.ID := null;
              -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
              CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl);

              -- store the highest degree of error
              IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  -- need to leave
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => l_contract_number);
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => l_contract_number);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;
              IF p_process_accrual_rec.submission_mode='BATCH' THEN
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
              END IF; -- if p_process_accrual_rec.submission_mode=...
              -- MGAAP 7263041 start
              IF (l_multi_gaap_yn = 'Y') THEN
                l_accrual_rec.set_of_books_id     := G_SOB_ID_REP;
                l_accrual_rec.product_id          := l_reporting_pdt_id;
                l_accrual_rec.sty_id              := l_sty_id_rep;
                l_accrual_rec.trx_number := l_tcnv_rec.trx_number;
                l_accrual_rec.primary_rep_trx_id := l_tcnv_rec.id;
                OPEN get_accrual_reversal_date(l_accrual_rec.set_of_books_id, l_accrual_rec.accrual_date);
                FETCH get_accrual_reversal_date into l_accrual_rec.accrual_reversal_date;
                CLOSE get_accrual_reversal_date;
              -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries for SECONDARY
              CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl,
                            p_representation_type => 'SECONDARY');

              -- store the highest degree of error
              IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  -- need to leave
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => l_contract_number);
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => l_contract_number);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;
              IF p_process_accrual_rec.submission_mode='BATCH' THEN
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
              END IF; -- if p_process_accrual_rec.submission_mode=...
              END IF;
              -- MGAAP 7263041 end
            END IF; -- If override_status = 'N'

          ELSIF l_rev_rec_basis = 'ACRL_WITHOUT_RULE' THEN
                --Create Accrual Entries and Corresponding Reversal Entries
                l_ctxt_val_tbl(1).NAME := 'p_accrual_date';
                l_ctxt_val_tbl(1).VALUE := TO_CHAR(l_accrual_date, 'MM/DD/YYYY');
                l_ctxt_val_tbl(2).NAME := 'p_last_int_calc_date';
                l_ctxt_val_tbl(2).VALUE := TO_CHAR(l_last_interest_calc_date, 'MM/DD/YYYY');
                l_ctxt_val_tbl(3).NAME := 'p_period_start_date';
                l_ctxt_val_tbl(3).VALUE := TO_CHAR(l_period_start_date, 'MM/DD/YYYY');
                l_ctxt_val_tbl(4).NAME := 'p_period_end_date';
                l_ctxt_val_tbl(4).VALUE := TO_CHAR(l_period_end_date, 'MM/DD/YYYY');
    		    --Create Accrual Entries
                -- Build the accrual record
                l_accrual_rec.contract_id         := l_contract_id;
                l_accrual_rec.set_of_books_id     := l_sob_id;
                l_accrual_rec.accrual_date        := l_accrual_date;
                l_accrual_rec.trx_date            := l_accrual_date;
                l_accrual_rec.contract_number     := l_contract_number;
                l_accrual_rec.rule_result         := NULL;
                l_accrual_rec.override_status     := NULL;
                l_accrual_rec.description         := l_batch_name;
                l_accrual_rec.amount              := 0;
              	l_accrual_rec.currency_code       := l_khr_currency_code;
              	l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                l_accrual_rec.product_id          := l_product_id;
                l_accrual_rec.trx_type_id         := l_try_id;
                l_accrual_rec.sty_id              := l_sty_id;
				l_accrual_rec.advance_arrears     := l_billing_type;
                l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
                l_accrual_rec.post_to_gl          := 'Y';
                l_accrual_rec.gl_reversal_flag    := 'Y';
                l_accrual_rec.memo_yn             := 'N';
                l_accrual_rec.accrual_activity    := 'ACCRUAL';
                l_accrual_rec.accrual_rule_yn     := 'N';
                 --Added by dpsingh for SLA Uptake (Bug 5707866)
                OPEN get_accrual_reversal_date(l_accrual_rec.set_of_books_id, l_accrual_rec.accrual_date);
                FETCH get_accrual_reversal_date into l_accrual_rec.accrual_reversal_date;
                CLOSE get_accrual_reversal_date;

                l_tcnv_rec.trx_number := null;  -- Bug 7555143
                l_tcnv_rec.ID := null;
                -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
                CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl);

                -- store the highest degree of error
                IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    -- need to leave
                     Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;
                IF p_process_accrual_rec.submission_mode='BATCH' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','NOT APPLICABLE',540,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','NOT APPLICABLE',540,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
		         END IF; -- if p_process_accrual_rec.submission_mode=...
             -- MGAAP 7263041 start
             IF (l_multi_gaap_yn = 'Y') THEN
                l_accrual_rec.set_of_books_id     := G_SOB_ID_REP;
                l_accrual_rec.product_id          := l_reporting_pdt_id;
                l_accrual_rec.sty_id              := l_sty_id_rep;
                l_accrual_rec.trx_number := l_tcnv_rec.trx_number;
                l_accrual_rec.primary_rep_trx_id := l_tcnv_rec.id;
                OPEN get_accrual_reversal_date(l_accrual_rec.set_of_books_id, l_accrual_rec.accrual_date);
                FETCH get_accrual_reversal_date into l_accrual_rec.accrual_reversal_date;
                CLOSE get_accrual_reversal_date;
                -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries for SECONDARY
                CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl,
                            p_representation_type => 'SECONDARY'); -- MGAAP

                -- store the highest degree of error
                IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    -- need to leave
                     Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;
                IF p_process_accrual_rec.submission_mode='BATCH' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','NOT APPLICABLE',540,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','NOT APPLICABLE',540,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
		         END IF; -- if p_process_accrual_rec.submission_mode=...
             END IF;
             -- MGAAP 7263041 end

            END IF; -- l_rev_rec_basis =
          END IF ; -- IF l_accrual_date - l_last_interest_calc_date > 0

          ELSE -- If l_trx_exists <> 'Y'
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_EST_BILL_DATE_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_contract_number,
                                p_token2       => 'PERIOD',
                                p_token2_value => to_char(l_accrual_date,'Mon-YY')
    							  );
              RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF; -- If l_trx_exists <> 'Y'
        ELSIF l_rev_rec_method = 'ACTUAL' THEN

          --    Bug 5036337.Commenting below as method t check has changed.
          --        OPEN check_actual_trx(l_contract_id, l_accrual_date);
          --        FETCH check_actual_trx INTO l_trx_exists;
          --        CLOSE check_actual_trx;

          FOR y IN check_actual_trx(l_contract_id)
          LOOP
            l_last_accrual_date := y.last_accrual_date;
          END LOOP;

          --BUG 5060624. Assigning contract start date in case accrual was never run
          --SGIYER 24-Feb-2006
		  IF l_last_accrual_date IS NULL THEN
		    l_last_accrual_date := l_start_date;
          END IF;

		  IF TRUNC(l_accrual_date) >= TRUNC(l_last_accrual_date) THEN

          OKL_STREAMS_UTIL.get_dependent_stream_type(
            p_khr_id  		   	    => l_contract_id,
            p_primary_sty_purpose   => 'RENT',
            p_dependent_sty_purpose => 'ACTUAL_INCOME_ACCRUAL',
            x_return_status		    => l_return_status,
            x_dependent_sty_id      => l_sty_id);

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            -- store SQL error message on message stack for caller and entry in log file
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
	                            p_token1       => g_stream_name_token,
			                    p_token1_value => 'ACTUAL INCOME ACCRUAL');
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;

          IF (l_multi_gaap_yn = 'Y') THEN
          OKL_STREAMS_UTIL.get_dependent_stream_type_rep(
            p_khr_id  		   	    => l_contract_id,
            p_primary_sty_purpose   => 'RENT',
            p_dependent_sty_purpose => 'ACTUAL_INCOME_ACCRUAL',
            x_return_status		    => l_return_status,
            x_dependent_sty_id      => l_sty_id_rep);

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            -- store SQL error message on message stack for caller and entry in log file
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
	                            p_token1       => g_stream_name_token,
			                    p_token1_value => 'ACTUAL INCOME ACCRUAL');
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;
          END IF;

          -- Get revenue recognition basis from stream type
		  FOR x IN get_rev_rec_basis_csr(l_sty_id)
          LOOP
            l_rev_rec_basis := x.accrual_yn;
          END LOOP;

          IF l_rev_rec_basis = 'ACRL_WITH_RULE' THEN
            IF l_override_status = 'N' THEN
              -- Check the override status and current accrual status and process accordingly
              IF l_rule_result = 'Y' THEN
                --Create Accrual Entries and Corresponding Reversal Entries
                l_ctxt_val_tbl(1).NAME := 'p_accrual_date';
                l_ctxt_val_tbl(1).VALUE := TO_CHAR(l_accrual_date, 'MM/DD/YYYY');
                l_ctxt_val_tbl(2).NAME := 'p_rep_type';
                l_ctxt_val_tbl(2).VALUE := 'PRIMARY';
    		    --Create Accrual Entries
                -- Build the accrual record
                l_accrual_rec.contract_id         := l_contract_id;
                l_accrual_rec.set_of_books_id     := l_sob_id;
                l_accrual_rec.accrual_date        := l_accrual_date;
                l_accrual_rec.trx_date            := l_accrual_date;
                l_accrual_rec.contract_number     := l_contract_number;
                l_accrual_rec.rule_result         := l_rule_result;
                l_accrual_rec.override_status     := l_override_status;
                l_accrual_rec.description         := l_batch_name;
                l_accrual_rec.amount              := 0;
              	l_accrual_rec.currency_code       := l_khr_currency_code;
              	l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                l_accrual_rec.product_id          := l_product_id;
                l_accrual_rec.trx_type_id         := l_try_id;
                l_accrual_rec.sty_id              := l_sty_id;
				l_accrual_rec.advance_arrears     := l_billing_type;
                l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
                l_accrual_rec.post_to_gl          := 'Y';
                l_accrual_rec.gl_reversal_flag    := 'N';
                l_accrual_rec.memo_yn             := 'N';
                l_accrual_rec.accrual_activity    := 'ACCRUAL';
                l_accrual_rec.accrual_rule_yn     := 'Y';

                l_tcnv_rec.trx_number := null;  -- Bug 7555143
                l_tcnv_rec.ID := null;
                -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
                CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl);

                -- store the highest degree of error
                IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    -- need to leave
                     Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;
                -- Update balances table
                IF l_tcnv_rec.amount IS NOT NULL THEN
                  UPDATE_BALANCES (l_contract_id
                                  ,l_contract_number
                                  ,l_tcnv_rec.amount
                                  ,l_tcnv_rec.date_transaction_occurred
                                  ,l_return_status
                                  ,l_msg_count
                                  ,l_msg_data);
                  -- store the highest degree of error
                  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                      -- need to leave
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_BAL_UPD_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_BAL_UPD_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                  END IF;
                END IF;

                IF p_process_accrual_rec.submission_mode='BATCH' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
		         END IF; -- if p_process_accrual_rec.submission_mode=...
                -- MGAAP 7263041 start
                IF (l_multi_gaap_yn = 'Y') THEN
                  l_accrual_rec.set_of_books_id     := G_SOB_ID_REP;
                  l_accrual_rec.product_id          := l_reporting_pdt_id;
                  l_accrual_rec.sty_id              := l_sty_id_rep;
                  l_accrual_rec.trx_number := l_tcnv_rec.trx_number;
                  l_accrual_rec.primary_rep_trx_id := l_tcnv_rec.id;
                  l_ctxt_val_tbl(2).VALUE := 'SECONDARY';
                -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries for SECONDARY
                CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl,
                            p_representation_type => 'SECONDARY');

                -- store the highest degree of error
                IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    -- need to leave
                     Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;

                IF p_process_accrual_rec.submission_mode='BATCH' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
		         END IF; -- if p_process_accrual_rec.submission_mode=...
                END IF;
                -- MGAAP 7263041 end
              ELSE
                -- Create Non-Accrual(memo) entries and Corresponding Reversal entries
                l_ctxt_val_tbl(1).NAME := 'p_accrual_date';
                l_ctxt_val_tbl(1).VALUE := TO_CHAR(l_accrual_date, 'MM/DD/YYYY');
                l_ctxt_val_tbl(2).NAME := 'p_rep_type';
                l_ctxt_val_tbl(2).VALUE := 'PRIMARY';
                --Create Accrual Entries
                -- Build the accrual record
                l_accrual_rec.contract_id         := l_contract_id;
                l_accrual_rec.set_of_books_id     := l_sob_id;
                l_accrual_rec.accrual_date        := l_accrual_date;
             	l_accrual_rec.trx_date            := l_accrual_date;
                l_accrual_rec.contract_number     := l_contract_number;
                l_accrual_rec.rule_result         := l_rule_result;
                l_accrual_rec.override_status     := l_override_status;
                l_accrual_rec.description         := l_batch_name;
           	    l_accrual_rec.amount              := 0;
              	l_accrual_rec.currency_code       := l_khr_currency_code;
              	l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                l_accrual_rec.product_id          := l_product_id;
                l_accrual_rec.trx_type_id         := l_try_id;
                l_accrual_rec.sty_id              := l_sty_id;
                l_accrual_rec.advance_arrears     := l_billing_type;
                l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
          	    l_accrual_rec.post_to_gl          := 'Y';
           	    l_accrual_rec.gl_reversal_flag    := 'N';
           	    l_accrual_rec.memo_yn             := 'Y';
                l_accrual_rec.accrual_activity    := 'NON-ACCRUAL';
                l_accrual_rec.accrual_rule_yn     := 'Y';

                l_tcnv_rec.trx_number := null;  -- Bug 7555143
                l_tcnv_rec.ID := null;
                -- Call CREATE_ACCRUAL_FORMULA procedure to create accrual transactions and entries
                CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl);

                -- store the highest degree of error
                IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    -- need to leave
                     Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;

                -- Update balances table
                IF l_tcnv_rec.amount IS NOT NULL THEN
                  UPDATE_BALANCES (l_contract_id
                                  ,l_contract_number
                                  ,l_tcnv_rec.amount
                                  ,l_tcnv_rec.date_transaction_occurred
                                  ,l_return_status
                                  ,l_msg_count
                                  ,l_msg_data);
                  -- store the highest degree of error
                  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                      -- need to leave
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_BAL_UPD_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_BAL_UPD_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                  END IF;
                END IF;

                IF p_process_accrual_rec.submission_mode='BATCH' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
                END IF; -- if p_process_accrual_rec.submission_mode=..
                -- MGAAP 7263041 start
                IF (l_multi_gaap_yn = 'Y') THEN
                  l_accrual_rec.set_of_books_id     := G_SOB_ID_REP;
                  l_accrual_rec.product_id          := l_reporting_pdt_id;
                  l_accrual_rec.sty_id              := l_sty_id_rep;
                  l_accrual_rec.trx_number := l_tcnv_rec.trx_number;
                  l_accrual_rec.primary_rep_trx_id := l_tcnv_rec.id;
                  l_ctxt_val_tbl(2).VALUE := 'SECONDARY';
                -- Call CREATE_ACCRUAL_FORMULA procedure to create accrual transactions and entries for SECONDARY
                CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl,
                            p_representation_type => 'SECONDARY'); -- MGAAP

                -- store the highest degree of error
                IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    -- need to leave
                     Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;

                IF p_process_accrual_rec.submission_mode='BATCH' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
                END IF; -- if p_process_accrual_rec.submission_mode=..
                END IF;
                -- MGAAP 7263041 end

              END IF;
            ELSE
              -- Create MEMO entries
              l_ctxt_val_tbl(1).NAME := 'p_accrual_date';
              l_ctxt_val_tbl(1).VALUE := TO_CHAR(l_accrual_date, 'MM/DD/YYYY');
              l_ctxt_val_tbl(2).NAME := 'p_rep_type';
              l_ctxt_val_tbl(2).VALUE := 'PRIMARY';
              --Create Accrual Entries
              -- Build the accrual record
              l_accrual_rec.contract_id         := l_contract_id;
              l_accrual_rec.set_of_books_id     := l_sob_id;
              l_accrual_rec.accrual_date        := l_accrual_date;
              l_accrual_rec.trx_date            := l_accrual_date;
              l_accrual_rec.contract_number     := l_contract_number;
              l_accrual_rec.rule_result         := l_rule_result;
              l_accrual_rec.override_status     := l_override_status;
              l_accrual_rec.description         := l_batch_name;
              l_accrual_rec.amount              := 0;
              l_accrual_rec.currency_code       := l_khr_currency_code;
              l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              l_accrual_rec.currency_conversion_date := l_currency_conv_date;
              l_accrual_rec.product_id          := l_product_id;
              l_accrual_rec.trx_type_id         := l_try_id;
              l_accrual_rec.sty_id              := l_sty_id;
              l_accrual_rec.advance_arrears     := l_billing_type;
              l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
              l_accrual_rec.post_to_gl          := 'Y';
              l_accrual_rec.gl_reversal_flag    := 'N';
              l_accrual_rec.memo_yn             := 'Y';
              l_accrual_rec.accrual_activity    := 'NON-ACCRUAL';
              l_accrual_rec.accrual_rule_yn     := 'Y';

              l_tcnv_rec.trx_number := null;  -- Bug 7555143
              l_tcnv_rec.ID := null;
              -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
              CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl);

              -- store the highest degree of error
              IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  -- need to leave
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => l_contract_number);
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => l_contract_number);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;
                -- Update balances table
                IF l_tcnv_rec.amount IS NOT NULL THEN
                  UPDATE_BALANCES (l_contract_id
                                  ,l_contract_number
                                  ,l_tcnv_rec.amount
                                  ,l_tcnv_rec.date_transaction_occurred
                                  ,l_return_status
                                  ,l_msg_count
                                  ,l_msg_data);
                  -- store the highest degree of error
                  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                      -- need to leave
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_BAL_UPD_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_BAL_UPD_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                  END IF;
                END IF;

              IF p_process_accrual_rec.submission_mode='BATCH' THEN
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
              END IF; -- if p_process_accrual_rec.submission_mode=...
              -- MGAAP 7263041 start
              IF (l_multi_gaap_yn = 'Y') THEN
                  l_accrual_rec.set_of_books_id     := G_SOB_ID_REP;
                  l_accrual_rec.product_id          := l_reporting_pdt_id;
                  l_accrual_rec.sty_id              := l_sty_id_rep;
                  l_accrual_rec.trx_number := l_tcnv_rec.trx_number;
                  l_accrual_rec.primary_rep_trx_id := l_tcnv_rec.id;
                  l_ctxt_val_tbl(2).VALUE := 'SECONDARY';
              -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries for SECONDARY
              CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl,
                            p_representation_type => 'SECONDARY');

              -- store the highest degree of error
              IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                  -- need to leave
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => l_contract_number);
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
                  Okl_Api.set_message(p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                      p_token1       => g_contract_number_token,
                                      p_token1_value => l_contract_number);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;

              IF p_process_accrual_rec.submission_mode='BATCH' THEN
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_NON_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.accrual_status_yn,0,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('YES_NO',l_tcnv_rec.update_status_yn,0,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
              END IF; -- if p_process_accrual_rec.submission_mode=...
              END IF;
              -- MGAAP 7263041 end
            END IF; -- If override_status = 'N'

          ELSIF l_rev_rec_basis = 'ACRL_WITHOUT_RULE' THEN
                --Create Accrual Entries and Corresponding Reversal Entries
                l_ctxt_val_tbl(1).NAME := 'p_accrual_date';
                l_ctxt_val_tbl(1).VALUE := TO_CHAR(l_accrual_date, 'MM/DD/YYYY');
                l_ctxt_val_tbl(2).NAME := 'p_rep_type';
                l_ctxt_val_tbl(2).VALUE := 'PRIMARY';
    		    --Create Accrual Entries
                -- Build the accrual record
                l_accrual_rec.contract_id         := l_contract_id;
                l_accrual_rec.set_of_books_id     := l_sob_id;
                l_accrual_rec.accrual_date        := l_accrual_date;
                l_accrual_rec.trx_date            := l_accrual_date;
                l_accrual_rec.contract_number     := l_contract_number;
                l_accrual_rec.rule_result         := NULL;
                l_accrual_rec.override_status     := NULL;
                l_accrual_rec.description         := l_batch_name;
                l_accrual_rec.amount              := 0;
              	l_accrual_rec.currency_code       := l_khr_currency_code;
              	l_accrual_rec.currency_conversion_type := l_currency_conv_type;
              	l_accrual_rec.currency_conversion_rate := l_currency_conv_rate;
              	l_accrual_rec.currency_conversion_date := l_currency_conv_date;
                l_accrual_rec.product_id          := l_product_id;
                l_accrual_rec.trx_type_id         := l_try_id;
                l_accrual_rec.sty_id              := l_sty_id;
				l_accrual_rec.advance_arrears     := l_billing_type;
                l_accrual_rec.factoring_synd_flag := l_factoring_synd_flag;
                l_accrual_rec.post_to_gl          := 'Y';
                l_accrual_rec.gl_reversal_flag    := 'N';
                l_accrual_rec.memo_yn             := 'N';
                l_accrual_rec.accrual_activity    := 'ACCRUAL';
                l_accrual_rec.accrual_rule_yn     := 'N';

                l_tcnv_rec.trx_number := null;  -- Bug 7555143
                l_tcnv_rec.ID := null;
                -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries
                CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl);

                -- store the highest degree of error
                IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    -- need to leave
                     Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;
                -- Update balances table
                IF l_tcnv_rec.amount IS NOT NULL THEN
                  UPDATE_BALANCES (l_contract_id
                                  ,l_contract_number
                                  ,l_tcnv_rec.amount
                                  ,l_tcnv_rec.date_transaction_occurred
                                  ,l_return_status
                                  ,l_msg_count
                                  ,l_msg_data);
                  -- store the highest degree of error
                  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                      -- need to leave
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_BAL_UPD_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                      Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_BAL_UPD_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                  END IF;
                END IF;

                IF p_process_accrual_rec.submission_mode='BATCH' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','NOT APPLICABLE',540,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','NOT APPLICABLE',540,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','PRIMARY'), 8));
		         END IF; -- if p_process_accrual_rec.submission_mode=...

              -- MGAAP 7263041 start
              IF (l_multi_gaap_yn = 'Y') THEN
                  l_accrual_rec.set_of_books_id     := G_SOB_ID_REP;
                  l_accrual_rec.product_id          := l_reporting_pdt_id;
                  l_accrual_rec.sty_id              := l_sty_id_rep;
                  l_accrual_rec.trx_number := l_tcnv_rec.trx_number;
                  l_accrual_rec.primary_rep_trx_id := l_tcnv_rec.id;
                  l_ctxt_val_tbl(2).VALUE := 'SECONDARY';
                -- Call CREATE_ACCRUAL procedure to create accrual transactions and entries for SECONDARY
                CREATE_ACCRUALS_FORMULA (
                            p_api_version => l_api_version,
                        	p_init_msg_list => l_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data,
                            x_tcnv_rec => l_tcnv_rec,
                            x_tclv_tbl => l_tclv_tbl,
                            p_accrual_rec => l_accrual_rec,
                            p_ctxt_val_tbl => l_ctxt_val_tbl,
                            p_representation_type => 'SECONDARY');

                -- store the highest degree of error
                IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    -- need to leave
                     Okl_Api.set_message(p_app_name     => g_app_name,
                                         p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                         p_token1       => g_contract_number_token,
                                         p_token1_value => l_contract_number);
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    Okl_Api.set_message(p_app_name     => g_app_name,
                                        p_msg_name     => 'OKL_AGN_CRE_ACR_ERROR',
                                        p_token1       => g_contract_number_token,
                                        p_token1_value => l_contract_number);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;

                IF p_process_accrual_rec.submission_mode='BATCH' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(l_contract_number,28)||
	                                     RPAD(l_tcnv_rec.trx_number,22)||
	                                     RPAD(FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_REVENUE'),17)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','NOT APPLICABLE',540,0),20)||
                                         RPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_ACCRUAL_ACTIVITY','NOT APPLICABLE',540,0),16)||
	                                     RPAD(l_tcnv_rec.currency_code,9)||
	                                 LPAD(Okl_Accounting_Util.FORMAT_AMOUNT(l_tcnv_rec.amount,l_tcnv_rec.currency_code),17) ||
      LPAD(Okl_Accounting_Util.Get_Lookup_Meaning('OKL_REPRESENTATION_TYPE','SECONDARY'), 10));
		         END IF; -- if p_process_accrual_rec.submission_mode=...

              END IF;
              -- MGAAP 7263041 end
            END IF; -- l_rev_rec_basis =

          ELSE
            Okl_Api.set_message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AGN_ACTUAL_DATE_ERROR',
                                p_token1       => g_contract_number_token,
                                p_token1_value => l_contract_number,
                                p_token2       => 'ACCRUAL_DATE',
                                p_token2_value => to_char(l_last_accrual_date,'DD-Mon-YYYY')
    							  );
              RAISE Okl_Api.G_EXCEPTION_ERROR;

          END IF; --IF TRUNC(l_accrual_date) >= TRUNC(l_last_accrual_date) THEN

        END IF; -- IF l_rev_rec_method = 'ACTUAL' THEN'

        x_return_status := l_return_status;
        Okl_Api.END_ACTIVITY(l_msg_count, l_msg_data);

        EXCEPTION

	      WHEN Okl_Api.G_EXCEPTION_ERROR THEN
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,l_msg_count
                                 ,l_msg_data
                                 ,'_PVT');

            IF p_process_accrual_rec.submission_mode='BATCH' THEN
	            -- Select the contract for error reporting
	            FND_FILE.PUT_LINE(FND_FILE.LOG,l_contract_number||', '||
				                  FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ERROR_STATUS')||' '||
								  x_return_status);
                -- Bug 4700105. Using get_error_msg.
	            Okl_Accounting_Util.GET_ERROR_MSG(l_error_msg_tbl);
	            IF (l_error_msg_tbl.COUNT > 0) THEN
	              FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
	              LOOP
	                IF l_error_msg_tbl(i) IS NOT NULL THEN
	                  FND_FILE.PUT_LINE(FND_FILE.LOG,l_error_msg_tbl(i));
	                END IF;
	              END LOOP;
	              FND_FILE.PUT_LINE(FND_FILE.LOG,'');
	            END IF;
            END IF;
            -- Bug 4700105.
            FND_MSG_PUB.Delete_Msg;

	      WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
            -- Select the contract for error reporting
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,l_msg_count
                                 ,l_msg_data
                                 ,'_PVT');
            IF p_process_accrual_rec.submission_mode='BATCH' THEN
	            -- Select the contract for error reporting
	            FND_FILE.PUT_LINE(FND_FILE.LOG,l_contract_number||', '||
				                  FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ERROR_STATUS')||' '||
	                              x_return_status);
                -- Bug 4700105. Using get_error_msg.
	            Okl_Accounting_Util.GET_ERROR_MSG(l_error_msg_tbl);
	            IF (l_error_msg_tbl.COUNT > 0) THEN
	              FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
	              LOOP
	                IF l_error_msg_tbl(i) IS NOT NULL THEN
	                  FND_FILE.PUT_LINE(FND_FILE.LOG,l_error_msg_tbl(i));
	                END IF;
	              END LOOP;
	              FND_FILE.PUT_LINE(FND_FILE.LOG,'');
	            END IF;
            END IF;
            -- Bug 4700105.
            FND_MSG_PUB.Delete_Msg;

	      WHEN OTHERS THEN

            IF check_agn_csr%ISOPEN THEN
              CLOSE check_agn_csr;
            END IF;

            IF last_status_csr%ISOPEN THEN
              CLOSE last_status_csr;
            END IF;


            IF last_int_date_csr%ISOPEN THEN
              CLOSE last_int_date_csr;
            END IF;

            -- Select the contract for error reporting
            x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,l_msg_count
                                 ,l_msg_data
                                 ,'_PVT');

            IF p_process_accrual_rec.submission_mode='BATCH' THEN
	            -- Select the contract for error reporting
	            FND_FILE.PUT_LINE(FND_FILE.LOG,l_contract_number||', '||
				                  FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ERROR_STATUS')||' '||
	                              x_return_status);
                -- Bug 4700105. Using get_error_msg.
	            Okl_Accounting_Util.GET_ERROR_MSG(l_error_msg_tbl);
	            IF (l_error_msg_tbl.COUNT > 0) THEN
	              FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
	              LOOP
	                IF l_error_msg_tbl(i) IS NOT NULL THEN
	                  FND_FILE.PUT_LINE(FND_FILE.LOG,l_error_msg_tbl(i));
	                END IF;
	              END LOOP;
	              FND_FILE.PUT_LINE(FND_FILE.LOG,'');
	            END IF;
            END IF;
            -- Bug 4700105.
            FND_MSG_PUB.Delete_Msg;

  END PROCESS_ACCRUALS;

-- Function to call the GENERATE_ACCRUALS Procedure
  FUNCTION SUBMIT_ACCRUALS(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_api_version IN NUMBER,
    p_accrual_date IN DATE,
    p_batch_name IN VARCHAR2 ) RETURN NUMBER IS

    x_request_id            NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_api_name              VARCHAR2(2000) := 'SUBMIT_ACCRUALS';
    l_api_version           CONSTANT NUMBER := 1.0;
	l_init_msg_list         VARCHAR2(20) DEFAULT Okl_Api.G_FALSE;
    l_accrual_date          VARCHAR2(2000);
  BEGIN
    -- Set save point
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,l_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- check for data before processing
    IF (p_accrual_date IS NULL OR p_accrual_date = Okl_Api.G_MISS_DATE) THEN
       Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_AGN_DATE_ERROR');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSE
      l_accrual_date := FND_DATE.DATE_TO_CANONICAL(p_accrual_date);
    END IF;

    -- Submit Concurrent Program Request
    FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
    x_request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'OKL',
                                               program => 'OKLAGNCALC',
                                               argument1 => l_accrual_date,
                                               argument2 => p_batch_name,
                                               argument3 => NULL);

    IF x_request_id = 0 THEN
    -- Handle submission error
    -- Raise Error if the request has not been submitted successfully.
      Okl_Api.SET_MESSAGE(G_APP_NAME, 'OKL_ERROR_SUB_CONC_PROG', 'CONC_PROG', 'Generate Accrual');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSE
     --set return status
      x_return_status := l_return_status;
      RETURN x_request_id;
    END IF;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
      RETURN x_request_id;
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
      RETURN x_request_id;
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
      RETURN x_request_id;
  END SUBMIT_ACCRUALS;

PROCEDURE GENERATE_ACCRUALS(errbuf OUT NOCOPY VARCHAR2
                           ,retcode OUT NOCOPY NUMBER
                           ,p_accrual_date IN VARCHAR2
                           ,p_batch_name IN VARCHAR2
                           ,p_contract_number IN VARCHAR2
                           ,p_rev_rec_method IN VARCHAR2) IS

    -- declare local variables
	l_contract_id		    OKL_K_HEADERS_FULL_V.id%TYPE;
	l_contract_number       OKL_K_HEADERS_FULL_V.contract_number%TYPE;
	l_accrual_status		OKL_K_HEADERS_FULL_V.generate_accrual_yn%TYPE;
	l_override_status		OKL_K_HEADERS_FULL_V.generate_accrual_override_yn%TYPE;
	l_start_date    		OKL_K_HEADERS_FULL_V.start_date%TYPE;
	l_sts_code			    OKL_K_HEADERS_FULL_V.sts_code%TYPE;
	l_product_id            OKL_K_HEADERS_FULL_V.pdt_id%TYPE;
	l_deal_type             OKL_K_HEADERS_FULL_V.deal_type%TYPE;
	l_try_id                OKL_TRX_TYPES_V.id%TYPE;
	l_accrual_reversal_days OKL_SYS_ACCT_OPTS.accrual_reversal_days%TYPE;
	l_func_currency_code    OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
	l_khr_currency_code     OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
	l_currency_conv_type    OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_TYPE%TYPE;
	l_currency_conv_rate    OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_RATE%TYPE;
	l_currency_conv_date    OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_DATE%TYPE;
    l_sob_id                OKL_SYS_ACCT_OPTS.set_of_books_id%TYPE;
	l_reverse_date_to       DATE;
    l_sob_name              VARCHAR2(2000);
	l_api_version           CONSTANT NUMBER := 1.0;
	p_api_version           CONSTANT NUMBER := 1.0;
	l_api_name              CONSTANT VARCHAR2(30) := 'GENERATE_ACCRUALS';
	l_init_msg_list         VARCHAR2(2000) := OKL_API.G_FALSE;
	l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(2000);
	l_period_name           VARCHAR2(2000);
	l_period_start_date     DATE;
	l_period_end_date       DATE;
    l_outer_error_msg_tbl 	Okl_Accounting_Util.Error_Message_Type;
    l_org_id                NUMBER;
    l_org_name              VARCHAR2(2000);
    l_contract_error_count  NUMBER := 1;
    l_period_status         VARCHAR2(1);
    l_counter               NUMBER := 1;
    l_contract_counter      NUMBER := 0;
    l_source_trx_type       OKL_TRX_CONTRACTS.SOURCE_TRX_TYPE%TYPE;
    l_source_trx_id         OKL_TRX_CONTRACTS.SOURCE_TRX_ID%TYPE;

    l_reqid                 FND_CONCURRENT_REQUESTS.request_id%TYPE;
    req_data                VARCHAR2(10);
    i                       NUMBER;
    l_accrual_date          DATE := FND_DATE.CANONICAL_TO_DATE(p_accrual_date);

    -- START MDOKAL CODE
    l_int_counter       INTEGER;
    l_max_lines         NUMBER;
    l_init_loop         BOOLEAN := TRUE;
    l_sort_int_counter  INTEGER;
    l_next_highest_val  NUMBER;
    l_lightest_worker   NUMBER;
    l_lightest_load     NUMBER;
    l_seq_next          NUMBER;
    l_data_found        BOOLEAN := FALSE;
    l_num_workers       NUMBER;
    l_worker_id			VARCHAR2(2000);

    --dkagrawa changed cursor to use view OKL_PROD_QLTY_VAL_UV than okl_product_parameters_v
    CURSOR chk_update_header_csr is
    SELECT chr.contract_number
    FROM OKC_K_HEADERS_B chr,
         OKL_K_HEADERS khr,
         OKL_PROD_QLTY_VAL_UV pdt
    WHERE chr.scs_code = 'LEASE'
    AND chr.sts_code IN ('BOOKED','EVERGREEN')
    AND chr.id = khr.id
    AND khr.pdt_id = pdt.pdt_id
    AND pdt.quality_name = 'REVENUE_RECOGNITION_METHOD'
    AND pdt.quality_val = p_rev_rec_method
-- modified by zrehman for Bug#6788005 on 04-Feb-2008 start
    UNION
    SELECT chr.contract_number
    FROM OKC_K_HEADERS_B chr,
         OKL_K_HEADERS khr
    WHERE chr.scs_code = 'INVESTOR'
    AND chr.sts_code = 'ACTIVE'
    AND chr.id = khr.id
    ;
-- modified by zrehman for Bug#6788005 on 04-Feb-2008 end

    CURSOR chk_data_volume_csr(p_seq_next VARCHAR2 )  IS
    SELECT chr.contract_number contract_number
          ,count(cle.id) line_count
    FROM OKC_K_HEADERS_B chr, OKC_K_LINES_B cle, okl_parallel_processes opp
    WHERE opp.object_value = chr.contract_number
    AND   opp.assigned_process = p_seq_next
    AND   opp.object_type = 'ACCRUAL_CONTRACT'
    AND  chr.scs_code = 'LEASE'
    AND chr.sts_code IN ('BOOKED','EVERGREEN')
    AND chr.id = cle.chr_id
    GROUP BY chr.contract_number
-- modified by zrehman for Bug#6788005 on 04-Feb-2008 start
    UNION
    SELECT chr.contract_number contract_number
          ,count(cle.id) line_count
    FROM OKC_K_HEADERS_B chr, OKC_K_LINES_B cle, okl_parallel_processes opp
    WHERE opp.object_value = chr.contract_number
    AND   opp.assigned_process = p_seq_next
    AND   opp.object_type = 'ACCRUAL_CONTRACT'
    AND  chr.scs_code = 'INVESTOR'
    AND chr.sts_code = 'ACTIVE'
    AND chr.id = cle.chr_id
    GROUP BY chr.contract_number;
-- modified by zrehman for Bug#6788005 on 04-Feb-2008 end;

    type l_contract_rec is
      record (batch_number     VARCHAR2(60),
	          contract_number  VARCHAR2(60),
		  	  line_count       NUMBER,
              worker_number    NUMBER);

    type contract_tab is table of l_contract_rec index by BINARY_INTEGER;

    type worker_load_rec is
      record (worker_number    NUMBER,
	          worker_load      NUMBER);

    type worker_load_tab IS TABLE OF worker_load_rec index by BINARY_INTEGER;

    type contract_list is
      record (contract_number  VARCHAR2(60));

    type contract_list_tab is table of contract_list index by BINARY_INTEGER;


    l_contract_list     contract_list_tab;
    l_worker_load       worker_load_tab;
    l_contract_tab      contract_tab;
    l_sort_tab1         contract_tab;
    l_temp_tab          contract_tab;

    -- END MDOKAL CODE

-- 	-- Cursor to select contracts for accrual processing
--     -- modified cursor to select only lease contracts
--     -- bug#2618966
    --dkagrawa changed cursor to use view OKL_PROD_QLTY_VAL_UV than okl_product_parameters_v
    CURSOR accrual_contract_csr IS
    SELECT chr.id
          ,chr.contract_number
          ,chr.start_date
          ,chr.sts_code
          ,khr.pdt_id
          ,khr.generate_accrual_yn
          ,khr.generate_accrual_override_yn
          ,khr.deal_type
		  ,chr.currency_code
		  ,khr.currency_conversion_type
		  ,khr.currency_conversion_rate
		  ,khr.currency_conversion_date
    FROM OKC_K_HEADERS_B chr,
         OKL_K_HEADERS khr,
         OKL_PROD_QLTY_VAL_UV pdt
    WHERE chr.contract_number = p_contract_number
    AND chr.id = khr.id
    AND chr.scs_code = 'LEASE'
	AND chr.sts_code IN ('BOOKED','EVERGREEN')
    AND khr.pdt_id = pdt.pdt_id
    AND pdt.quality_name = 'REVENUE_RECOGNITION_METHOD'
    AND pdt.quality_val = p_rev_rec_method
-- modified by zrehman for Bug#6788005 on 04-Feb-2008 start
    UNION
    SELECT chr.id
          ,chr.contract_number
          ,chr.start_date
          ,chr.sts_code
          ,khr.pdt_id
          ,khr.generate_accrual_yn
          ,khr.generate_accrual_override_yn
          ,khr.deal_type
		  ,chr.currency_code
		  ,khr.currency_conversion_type
		  ,khr.currency_conversion_rate
		  ,khr.currency_conversion_date
    FROM OKC_K_HEADERS_B chr,
         OKL_K_HEADERS khr
    WHERE chr.contract_number = p_contract_number
    AND chr.id = khr.id
    AND chr.scs_code = 'INVESTOR'
    AND chr.sts_code = 'ACTIVE'
-- modified by zrehman for Bug#6788005 on 04-Feb-2008 end
;

	-- Cursor to select the billing rule i.e. whether advance or arrears
    -- commenting for bug# 2388940 04-Jun-02 SGIYER
	-- as per discussion with PM. Advance/arrears must get a value NULL.
    --CURSOR billing_rule_csr(p_ctr_id NUMBER) IS
    --SELECT object1_id1
    --FROM OKC_RULES_B r
    --WHERE r.dnz_chr_id = p_ctr_id
    --AND r.jtot_object1_code = 'OKX_INVRULE'
	--AND r.rule_information_category = 'IRE';

    -- declare error placeholders
	TYPE contract_error_tbl_type IS TABLE OF okl_k_headers_full_v.CONTRACT_NUMBER%TYPE INDEX BY BINARY_INTEGER;
    -- Bug 3020763
    TYPE accrual_contracts_rec_type IS RECORD(
      contract_id                  OKL_K_HEADERS_FULL_V.ID%TYPE,
      contract_number              OKL_K_HEADERS_FULL_V.CONTRACT_NUMBER%TYPE,
      start_date                   OKL_K_HEADERS_FULL_V.START_DATE%TYPE,
	  sts_code                     OKL_K_HEADERS_FULL_V.STS_CODE%TYPE,
	  product_id                   OKL_K_HEADERS_FULL_V.PDT_ID%TYPE,
      accrual_status               OKL_K_HEADERS_FULL_V.GENERATE_ACCRUAL_YN%TYPE,
      override_status              OKL_K_HEADERS_FULL_V.GENERATE_ACCRUAL_OVERRIDE_YN%TYPE,
      deal_type                    OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE,
      khr_currency_code            OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE,
      currency_conv_type           OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_TYPE%TYPE,
      currency_conv_rate           OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_RATE%TYPE,
      currency_conv_date           OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_DATE%TYPE,
      org_id                       OKL_K_HEADERS_FULL_V.AUTHORING_ORG_ID%TYPE);

    TYPE accrual_contracts_tbl_type IS TABLE OF accrual_contracts_rec_type INDEX BY BINARY_INTEGER;

    l_contract_error_tbl          contract_error_tbl_type;
	l_accrual_contracts_tbl       accrual_contracts_tbl_type; -- Bug# 3020763
    l_accrual_contracts           accrual_contract_csr%ROWTYPE;
    l_process_accrual_rec         process_accrual_rec_type;

BEGIN

  IF p_contract_number IS NULL THEN

    req_data := fnd_conc_global.request_data;

    IF req_data IS NOT NULL THEN
      errbuf:='Done';
      retcode := 0;
      return;
    ELSE
      -- Parent request. Do necessary action
      i := 1;

     -- START MDOKAL CODE
     l_int_counter := 0;
     l_max_lines   := 0;

     --START SGIYER
	 l_num_workers := FND_PROFILE.VALUE('OKL_AGN_WORKERS');

     IF l_num_workers IS NULL THEN
       Okl_Api.set_message(p_app_name     => g_app_name,
	                       p_msg_name     => 'OKL_AGN_WORKER_ERROR');
       fnd_file.put_line(fnd_file.log, 'Please specify a value for the profile option OKL: Generate Accrual Concurrent Workers');
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     -- END SGIYER

     -- Select sequence for marking processes
     select okl_opp_seq.nextval
     into l_seq_next
     from dual ;

     -- mark records for processing
     for chk_update_header_csr_rec in chk_update_header_csr loop

       INSERT INTO OKL_PARALLEL_PROCESSES
       (object_type, object_value, assigned_process, process_status, start_date)
       VALUES
       ('ACCRUAL_CONTRACT',chk_update_header_csr_rec.contract_number, to_char(l_seq_next),'PENDING_ASSIGNMENT', sysdate);
       COMMIT;
       l_data_found := TRUE;
     end loop;

     if l_data_found then
       for chk_data_volume_csr_rec in chk_data_volume_csr(l_seq_next) loop

         l_int_counter := l_int_counter + 1;

         if l_init_loop then -- initialize minimum and maximum lines
           l_init_loop := FALSE;
           l_max_lines := chk_data_volume_csr_rec.line_count;
         end if;

         l_contract_tab(l_int_counter).contract_number := chk_data_volume_csr_rec.contract_number;
         l_contract_tab(l_int_counter).line_count := chk_data_volume_csr_rec.line_count;
         if chk_data_volume_csr_rec.line_count > l_max_lines then
           l_max_lines := chk_data_volume_csr_rec.line_count;
         end if;
       end loop;

       -- reset, ready for use again
       l_init_loop := TRUE;

       if l_int_counter = 0 then
         FND_FILE.PUT_LINE(FND_FILE.log, 'No Data Found for criteria passed');
       end if;

       -- find the maximum line count from the original table and delete it
       -- put this as the first element of the new sorted table
       l_sort_int_counter := 0;
       for i in 1..l_int_counter loop
         if l_contract_tab(i).line_count = l_max_lines then
           l_sort_int_counter := l_sort_int_counter+1;
           l_sort_tab1(l_sort_int_counter).contract_number := l_contract_tab(i).contract_number;
           l_sort_tab1(l_sort_int_counter).line_count := l_contract_tab(i).line_count;
           l_contract_tab.DELETE(i);
         end if;
       end loop;

       -- start sorting
       if l_contract_tab.FIRST is not null then

         for i in 1..l_contract_tab.COUNT loop
           -- find the next highest value in original table
           for i in 1..l_contract_tab.LAST loop
             if l_init_loop  then
               if l_contract_tab.EXISTS(i) then
                 l_next_highest_val := l_contract_tab(i).line_count;
                 l_init_loop := FALSE;
               end if;
             end if;
             if l_contract_tab.EXISTS(i) and l_contract_tab(i).line_count > l_next_highest_val then
              l_next_highest_val := l_contract_tab(i).line_count;
             end if;
           end loop;

           -- reset flag, ready for use again
           l_init_loop := TRUE;
           -- continue populating sort table in order
           for i in 1..l_contract_tab.LAST loop
             if l_contract_tab.EXISTS(i) and l_contract_tab(i).line_count = l_next_highest_val then
               l_sort_int_counter := l_sort_int_counter+1;
               l_sort_tab1(l_sort_int_counter).contract_number := l_contract_tab(i).contract_number;
               l_sort_tab1(l_sort_int_counter).line_count := l_contract_tab(i).line_count;
               l_contract_tab.DELETE(i);
             end if;
           end loop;
           exit when l_contract_tab.LAST is null;
         end loop;
       end if; -- end sorting

       -- begin processing load for workers
       for i in 1..l_num_workers loop -- put all workers into a table
         l_worker_load(i).worker_number := i;
         l_worker_load(i).worker_load := 0; -- initialize load with zero
       end loop;

       if l_num_workers > 0 then

         l_lightest_worker := 1;
         -- loop through the sorted table and ensure each contract has a worker
         for i in 1..l_sort_tab1.COUNT loop
           l_sort_tab1(i).worker_number := l_lightest_worker;
           -- put current contract into the lightest worker
           if l_worker_load.EXISTS(l_lightest_worker) then
             l_worker_load(l_lightest_worker).worker_load := l_worker_load(l_lightest_worker).worker_load + l_sort_tab1(i).line_count;
           end if;
           -- default the lighest load with the first element as a starting point
           if l_worker_load.EXISTS(1) then
             l_lightest_load := l_worker_load(1).worker_load;
             l_lightest_worker := l_worker_load(1).worker_number;
             -- logic to find lightest load
             for i in 1..l_worker_load.COUNT loop
               if (l_worker_load(i).worker_load = 0) or (l_worker_load(i).worker_load < l_lightest_load) then
                 l_lightest_load   := l_worker_load(i).worker_load;
                 l_lightest_worker := l_worker_load(i).worker_number;
               end if;
             end loop;
           end if;
         end loop;
       end if;

       l_sort_int_counter := 0;

       for j in 1..l_worker_load.LAST loop
         for i in 1..l_sort_tab1.LAST loop
           if l_sort_tab1.EXISTS(i) and(l_sort_tab1(i).worker_number = l_worker_load(j).worker_number )then

             UPDATE OKL_PARALLEL_PROCESSES
             SET
               assigned_process =  l_seq_next||'-'||l_sort_tab1(i).worker_number,
               volume = l_sort_tab1(i).line_count,
               process_status = 'ASSIGNED'
             WHERE object_Type = 'ACCRUAL_CONTRACT'
             AND   object_value = l_sort_tab1(i).contract_number
             AND   process_status = 'PENDING_ASSIGNMENT';

             COMMIT;
             l_sort_tab1.DELETE(i);
           end if;
         end loop;
       end loop;

       for j in 1..l_worker_load.LAST loop
          --START SGIYER
          l_worker_id := NULL;
          l_worker_id := to_char(l_seq_next)||'-'||to_char(j);

          FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
          l_reqid := FND_REQUEST.submit_request(application => 'OKL',
                                         program => 'OKLAGNCALCW',
                                         sub_request => TRUE,
                                         argument1 => p_accrual_date,
                                         argument2 => p_batch_name,
                                         argument3 => l_worker_id,
                                         argument4 => p_rev_rec_method);
          IF l_reqid = 0 THEN
            -- If request submission failed, exit with error.
            errbuf := fnd_message.get;
            retcode := 2;
          ELSE
            errbuf := 'Sub-Request submitted successfully';
            retcode := 0 ;
          END IF;
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Launching Process '||l_worker_id||' with Request ID '||l_reqid);
       end loop;

       FND_CONC_GLOBAL.set_req_globals(conc_status => 'PAUSED',
                                       request_data => to_char(i)) ;
       -- END SGIYER

       -- clean up
       -- Delete records from in chk_update_header_csr that were unassigned
       --DELETE FROM OKL_PARALLEL_PROCESSES
       --WHERE process_status = 'PENDING_ASSIGNMENT'
       --AND assigned_process =  to_char(l_seq_next);
       --COMMIT;
     else
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'No workers assigned due to no data found for prcocesing');
     end if; -- l_data_found
     -- END MDOKAL CODE
   END IF;
  ELSE

      --Added by kthiruva on 02-Mar-2006 for Logging Purposes
      WRITE_TO_LOG('Generate_accruals:Before the call to Get_Common_Info');
      WRITE_TO_LOG('Accrual Date :'||l_accrual_date);
      -- get common info
	  GET_COMMON_INFO (p_accrual_date => l_accrual_date,
	                   x_try_id => l_try_id,
	                   x_period_name => l_period_name,
	                   x_period_start_date => l_period_start_date,
	                   x_period_end_date => l_period_end_date,
	                   x_sob_id => l_sob_id,
	                   x_sob_name => l_sob_name,
	                   x_org_id => l_org_id,
	                   x_org_name => l_org_name,
	                   x_accrual_reversal_days => l_accrual_reversal_days,
	                   x_func_currency_code => l_func_currency_code,
	                   x_return_status => l_return_status
	                   );
      --Added by kthiruva on 02-Mar-2006 for Logging Purposes
      --Start of Changes
      WRITE_TO_LOG('The parameters returned after the GET_COMMON_INFO call');
      WRITE_TO_LOG('======================================================');
      WRITE_TO_LOG('Return Status     :'||l_return_status);
      WRITE_TO_LOG('Transaction Id    :'||l_try_id);
      WRITE_TO_LOG('Period Name       :'||l_period_name);
      WRITE_TO_LOG('Period Start Date :'||l_period_start_date);
      WRITE_TO_LOG('Period End Date   :'||l_period_end_date);
      WRITE_TO_LOG('Set Of Books Id   :'||l_sob_id);
      WRITE_TO_LOG('Set Of Books Name :'||l_sob_name);
      WRITE_TO_LOG('Org Id            :'||l_org_id);
      WRITE_TO_LOG('Org Name          :'||l_org_name);
      WRITE_TO_LOG('Accrual Rev Days  :'||l_accrual_reversal_days);
      WRITE_TO_LOG('Func Currency Code:'||l_func_currency_code);
	  --kthiruva - End of Changes

	  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
	    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
	      -- need to leave
          Okl_Api.set_message(p_app_name     => g_app_name,
	                          p_msg_name     => 'OKL_AGN_COM_INFO_ERROR');
  	      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
	      Okl_Api.set_message(p_app_name     => g_app_name,
	                          p_msg_name     => 'OKL_AGN_COM_INFO_ERROR');
	      RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
	  END IF;

	  -- Calculate the number of days (to_date) to reverse in case of non-accrual
	  l_reverse_date_to := l_accrual_date - l_accrual_reversal_days;

	  -- Create Report Header
      REPORT_HEADER(l_sob_name
	               ,l_org_name
	               ,l_accrual_date
	               ,p_batch_name
	               ,l_func_currency_code
                   ,l_return_status);

	  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_REPORT_ERROR');
  	    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  END IF;


      l_counter := 1;
      FOR l_accrual_contracts IN accrual_contract_csr
      LOOP
          l_accrual_contracts_tbl(l_counter).contract_id := l_accrual_contracts.id;
          l_accrual_contracts_tbl(l_counter).contract_number := l_accrual_contracts.contract_number;
	      l_accrual_contracts_tbl(l_counter).sts_code := l_accrual_contracts.sts_code;
  	      l_accrual_contracts_tbl(l_counter).product_id := l_accrual_contracts.pdt_id;
          l_accrual_contracts_tbl(l_counter).accrual_status := l_accrual_contracts.generate_accrual_yn;
          l_accrual_contracts_tbl(l_counter).override_status := l_accrual_contracts.generate_accrual_override_yn;
          l_accrual_contracts_tbl(l_counter).start_date := l_accrual_contracts.start_date;
          l_accrual_contracts_tbl(l_counter).deal_type := l_accrual_contracts.deal_type;
          l_accrual_contracts_tbl(l_counter).khr_currency_code := l_accrual_contracts.currency_code;
          l_accrual_contracts_tbl(l_counter).currency_conv_type := l_accrual_contracts.currency_conversion_type;
          l_accrual_contracts_tbl(l_counter).currency_conv_date := l_accrual_contracts.currency_conversion_date;
          l_accrual_contracts_tbl(l_counter).currency_conv_rate := l_accrual_contracts.currency_conversion_rate;
          l_counter := l_counter+1;
      END LOOP;

      --Added by kthiruva on 02-Mar-2006 for Logging Purposes
      --Start of Changes
      WRITE_TO_LOG('The contents of the l_accrual_contracts_tbl');
      WRITE_TO_LOG('===========================================');
      FOR y IN l_accrual_contracts_tbl.FIRST..l_accrual_contracts_tbl.LAST
      LOOP
          WRITE_TO_LOG('Contract Id              :'||l_accrual_contracts_tbl(y).contract_id );
          WRITE_TO_LOG('Contract Number          :'||l_accrual_contracts_tbl(y).contract_number);
	      WRITE_TO_LOG('Contract Code            :'||l_accrual_contracts_tbl(y).sts_code);
  	      WRITE_TO_LOG('Product Id               :'||l_accrual_contracts_tbl(y).product_id);
          WRITE_TO_LOG('Accrual Status           :'||l_accrual_contracts_tbl(y).accrual_status);
          WRITE_TO_LOG('Override Status          :'||l_accrual_contracts_tbl(y).override_status);
          WRITE_TO_LOG('Start Date               :'||l_accrual_contracts_tbl(y).start_date);
          WRITE_TO_LOG('Deal Type                :'||l_accrual_contracts_tbl(y).deal_type);
          WRITE_TO_LOG('Cuurency Code            :'||l_accrual_contracts_tbl(y).khr_currency_code);
          WRITE_TO_LOG('Currency Conversion Type :'||l_accrual_contracts_tbl(y).currency_conv_type);
          WRITE_TO_LOG('Currency Conversion Date :'||l_accrual_contracts_tbl(y).currency_conv_date);
          WRITE_TO_LOG('Currency Conversion Rate :'||l_accrual_contracts_tbl(y).currency_conv_rate);
      END LOOP;
      --kthiruva : end of Changes

        -- for performance. Bug 3020763
	    IF l_accrual_contracts_tbl.COUNT > 0 THEN

	      FOR y IN l_accrual_contracts_tbl.FIRST..l_accrual_contracts_tbl.LAST
          LOOP
              l_process_accrual_rec := NULL;

  	          l_process_accrual_rec.contract_id := l_accrual_contracts_tbl(y).contract_id;
	          l_process_accrual_rec.contract_number := l_accrual_contracts_tbl(y).contract_number;
		      l_process_accrual_rec.sts_code := l_accrual_contracts_tbl(y).sts_code;
		      l_process_accrual_rec.product_id := l_accrual_contracts_tbl(y).product_id;
	          l_process_accrual_rec.accrual_status := l_accrual_contracts_tbl(y).accrual_status;
	          l_process_accrual_rec.override_status := l_accrual_contracts_tbl(y).override_status;
	          l_process_accrual_rec.start_date := l_accrual_contracts_tbl(y).start_date;
	          l_process_accrual_rec.deal_type := l_accrual_contracts_tbl(y).deal_type;
	          l_process_accrual_rec.khr_currency_code := l_accrual_contracts_tbl(y).khr_currency_code;
	          l_process_accrual_rec.currency_conv_type := l_accrual_contracts_tbl(y).currency_conv_type;
	          l_process_accrual_rec.currency_conv_date := l_accrual_contracts_tbl(y).currency_conv_date;
	          l_process_accrual_rec.currency_conv_rate := l_accrual_contracts_tbl(y).currency_conv_rate;

			  l_process_accrual_rec.func_currency_code := l_func_currency_code;
			  l_process_accrual_rec.try_id := l_try_id;
			  l_process_accrual_rec.reverse_date_to := l_reverse_date_to;
			  l_process_accrual_rec.batch_name := p_batch_name;
			  l_process_accrual_rec.sob_id := l_sob_id;
			  l_process_accrual_rec.accrual_date := l_accrual_date;
			  l_process_accrual_rec.period_end_date := l_period_end_date;
			  l_process_accrual_rec.period_start_date	:= l_period_start_date;
	          l_process_accrual_rec.source_trx_id := l_source_trx_id;
	          l_process_accrual_rec.source_trx_type := l_source_trx_type;
	          l_process_accrual_rec.submission_mode := 'BATCH';
	          l_process_accrual_rec.rev_rec_method := p_rev_rec_method;

	        PROCESS_ACCRUALS(
			    p_api_version => l_api_version,
				p_init_msg_list => l_init_msg_list,
			    x_return_status => l_return_status,
			    x_msg_count => l_msg_count,
			    x_msg_data => l_msg_data,
			    p_process_accrual_rec => l_process_accrual_rec
				);

	        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	          l_contract_error_tbl(l_contract_error_count) := l_process_accrual_rec.contract_number;
	          l_contract_error_count := l_contract_error_count + 1;
	        END IF;

	      END LOOP; -- For y IN l_accrual_contracts_tbl.FIRST
		    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
		    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
		    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
		    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
		    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CNTRCT_ERROR_TITLE'));
		    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CNT_ERR_UNDERLINE'));
		    IF l_contract_error_tbl.COUNT > 0 THEN
		      FOR x IN l_contract_error_tbl.FIRST..l_contract_error_tbl.LAST
		      LOOP
		        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_contract_error_tbl(x));
		      END LOOP;
		      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
		      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ADD_INFO'));
		    END IF;

	    END IF; --IF l_accrual_contracts_tbl.COUNT > 0 THEN

    END IF; -- IF p_contract_number IS NULL THEN


    retcode := 0;
    l_return_status := OKL_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      l_return_status := Okl_Api.G_RET_STS_ERROR;

      -- print the error message in the log file and output files
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_ERROR'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
      IF (l_outer_error_msg_tbl.COUNT > 0) THEN
        FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
        LOOP
           FND_FILE.PUT_LINE(FND_FILE.LOG, l_outer_error_msg_tbl(i));
        END LOOP;
      END IF;

    retcode := 2;

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      -- print the error message in the log file
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_ERROR'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
        IF (l_outer_error_msg_tbl.COUNT > 0) THEN
          FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_outer_error_msg_tbl(i));
          END LOOP;
        END IF;

      retcode := 2;

    WHEN OTHERS THEN

      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      -- print the error message in the log file
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_ERROR'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
        IF (l_outer_error_msg_tbl.COUNT > 0) THEN
          FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_outer_error_msg_tbl(i));
          END LOOP;
        END IF;

       errbuf := SQLERRM;
       retcode := 2;


  END GENERATE_ACCRUALS;


  PROCEDURE GENERATE_ACCRUALS_PARALLEL
                             (errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY NUMBER
                             ,p_accrual_date IN VARCHAR2
                             ,p_batch_name IN VARCHAR2
                             ,p_worker_id IN VARCHAR2
                             ,p_rev_rec_method IN VARCHAR2) IS

	l_contract_id		    OKL_K_HEADERS_FULL_V.id%TYPE;
	l_contract_number       OKL_K_HEADERS_FULL_V.contract_number%TYPE;
	l_accrual_status		OKL_K_HEADERS_FULL_V.generate_accrual_yn%TYPE;
	l_override_status		OKL_K_HEADERS_FULL_V.generate_accrual_override_yn%TYPE;
	l_start_date    		OKL_K_HEADERS_FULL_V.start_date%TYPE;
	l_sts_code			    OKL_K_HEADERS_FULL_V.sts_code%TYPE;
	l_product_id            OKL_K_HEADERS_FULL_V.pdt_id%TYPE;
	l_deal_type             OKL_K_HEADERS_FULL_V.deal_type%TYPE;
	l_try_id                OKL_TRX_TYPES_V.id%TYPE;
	l_accrual_reversal_days OKL_SYS_ACCT_OPTS.accrual_reversal_days%TYPE;
	l_func_currency_code    OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
	l_khr_currency_code     OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
	l_currency_conv_type    OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_TYPE%TYPE;
	l_currency_conv_rate    OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_RATE%TYPE;
	l_currency_conv_date    OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_DATE%TYPE;
    l_sob_id                OKL_SYS_ACCT_OPTS.set_of_books_id%TYPE;
    l_try_name              OKL_TRX_TYPES_V.NAME%TYPE := 'Accrual';
        --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
	l_tsu_code_ent          OKL_TRX_CONTRACTS.TSU_CODE%TYPE := 'PROCESSED';
    l_tcn_type              OKL_TRX_CONTRACTS.TCN_TYPE%TYPE := 'ACL';
	l_reverse_date_to       DATE;
    l_sob_name              VARCHAR2(2000);
	l_sysdate               DATE := SYSDATE;
	l_api_version           CONSTANT NUMBER := 1.0;
	p_api_version           CONSTANT NUMBER := 1.0;
	l_api_name              CONSTANT VARCHAR2(30) := 'GENERATE_ACCRUALS_PARALLEL';
	l_init_msg_list         VARCHAR2(2000) := OKL_API.G_FALSE;
	l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(2000);
	l_period_name           VARCHAR2(2000);
	l_period_start_date     DATE;
	l_period_end_date       DATE;
    l_outer_error_msg_tbl 	Okl_Accounting_Util.Error_Message_Type;
    l_org_id                NUMBER;
    l_org_name              VARCHAR2(2000);
    l_contract_error_count  NUMBER := 1;
    l_accrual_date          DATE;
    l_rule_info_cat          VARCHAR2(2000) := 'LAINTP';
    l_period_status         VARCHAR2(1);
    l_counter               NUMBER := 1;
    l_contract_counter      NUMBER := 0;
    l_source_trx_type       OKL_TRX_CONTRACTS.SOURCE_TRX_TYPE%TYPE;
    l_source_trx_id         OKL_TRX_CONTRACTS.SOURCE_TRX_ID%TYPE;
    l_lower_limit           NUMBER := 1;
    l_upper_limit           NUMBER;
    l_process_records       NUMBER := 30;
    l_total_records         NUMBER;
    l_reqid                 FND_CONCURRENT_REQUESTS.request_id%TYPE;
    req_data                VARCHAR2(10);
    i                       NUMBER;

    -- Cursor to select contract for accrual processing
	CURSOR process_accruals_csr	IS
	SELECT OBJECT_VALUE
	FROM OKL_PARALLEL_PROCESSES
    WHERE assigned_process = p_worker_id;


    CURSOR accrual_contracts_csr (p_khr_num VARCHAR2) IS
    SELECT chr.id
          ,chr.contract_number
          ,chr.start_date
          ,chr.sts_code
          ,khr.pdt_id
          ,khr.generate_accrual_yn
          ,khr.generate_accrual_override_yn
          ,khr.deal_type
		  ,chr.currency_code
		  ,khr.currency_conversion_type
		  ,khr.currency_conversion_rate
		  ,khr.currency_conversion_date
    FROM OKC_K_HEADERS_B chr, OKL_K_HEADERS khr
    WHERE chr.contract_number = p_khr_num
    AND chr.id = khr.id
    AND chr.scs_code = 'LEASE'
	AND chr.sts_code IN ('BOOKED','EVERGREEN')
-- modified by zrehman for Bug#6788005 on 11-Feb-2008 start
    UNION
    SELECT chr.id
          ,chr.contract_number
          ,chr.start_date
          ,chr.sts_code
          ,khr.pdt_id
          ,khr.generate_accrual_yn
          ,khr.generate_accrual_override_yn
          ,khr.deal_type
	  ,chr.currency_code
	  ,khr.currency_conversion_type
	  ,khr.currency_conversion_rate
	  ,khr.currency_conversion_date
    FROM OKC_K_HEADERS_B chr, OKL_K_HEADERS khr
    WHERE chr.contract_number = p_khr_num
    AND chr.id = khr.id
    AND chr.scs_code = 'INVESTOR'
    AND chr.sts_code = 'ACTIVE'
-- modified by zrehman for Bug#6788005 on 11-Feb-2008 end
    ;


    -- declare error placeholders
	TYPE contract_error_tbl_type IS TABLE OF okl_k_headers_full_v.CONTRACT_NUMBER%TYPE INDEX BY BINARY_INTEGER;
    -- Bug 3020763
    TYPE accrual_contracts_rec_type IS RECORD(
      contract_id                  OKL_K_HEADERS_FULL_V.ID%TYPE,
      contract_number              OKL_K_HEADERS_FULL_V.CONTRACT_NUMBER%TYPE,
      start_date                   OKL_K_HEADERS_FULL_V.START_DATE%TYPE,
	  sts_code                     OKL_K_HEADERS_FULL_V.STS_CODE%TYPE,
	  product_id                   OKL_K_HEADERS_FULL_V.PDT_ID%TYPE,
      accrual_status               OKL_K_HEADERS_FULL_V.GENERATE_ACCRUAL_YN%TYPE,
      override_status              OKL_K_HEADERS_FULL_V.GENERATE_ACCRUAL_OVERRIDE_YN%TYPE,
      deal_type                    OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE,
      khr_currency_code            OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE,
      currency_conv_type           OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_TYPE%TYPE,
      currency_conv_rate           OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_RATE%TYPE,
      currency_conv_date           OKL_K_HEADERS_FULL_V.CURRENCY_CONVERSION_DATE%TYPE);

    TYPE accrual_contracts_tbl_type IS TABLE OF accrual_contracts_rec_type INDEX BY BINARY_INTEGER;
    TYPE req_id_tbl_type IS TABLE OF FND_CONCURRENT_REQUESTS.request_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE contract_number_tbl_type IS TABLE OF OKC_K_HEADERS_B.contract_number%TYPE INDEX BY BINARY_INTEGER;

    l_contract_num_tbl            contract_number_tbl_type;
    l_contract_error_tbl          contract_error_tbl_type;
	l_accrual_contracts_tbl       accrual_contracts_tbl_type; -- Bug# 3020763
    l_reqid_tbl                   req_id_tbl_type;
    l_process_accrual_rec         process_accrual_rec_type;

  BEGIN

        -- request is a child request
        IF p_accrual_date IS NULL THEN
	      --set message
          Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_DATE_ERROR');
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
        l_accrual_date := FND_DATE.CANONICAL_TO_DATE(p_accrual_date);

        IF p_worker_id IS NULL THEN
	      --set message
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_WORKER_ID_ERROR');
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        IF p_rev_rec_method IS NULL THEN
	      --set message
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_REV_REC_ERROR');
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

	 	-- get common info
	    GET_COMMON_INFO (p_accrual_date => l_accrual_date,
	                     x_try_id => l_try_id,
	                     x_period_name => l_period_name,
	                     x_period_start_date => l_period_start_date,
	                     x_period_end_date => l_period_end_date,
	                     x_sob_id => l_sob_id,
	                     x_sob_name => l_sob_name,
	                     x_org_id => l_org_id,
	                     x_org_name => l_org_name,
	                     x_accrual_reversal_days => l_accrual_reversal_days,
	                     x_func_currency_code => l_func_currency_code,
	                     x_return_status => l_return_status
	                     );

	    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
	      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
	        -- need to leave
            Okl_Api.set_message(p_app_name     => g_app_name,
	                            p_msg_name     => 'OKL_AGN_COM_INFO_ERROR');
  	        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
	        Okl_Api.set_message(p_app_name     => g_app_name,
	                            p_msg_name     => 'OKL_AGN_COM_INFO_ERROR');
	        RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
	    END IF;

	    -- Calculate the number of days (to_date) to reverse in case of non-accrual
	    l_reverse_date_to := l_accrual_date - l_accrual_reversal_days;

        -- Create Report Header
        REPORT_HEADER(l_sob_name
	                 ,l_org_name
	                 ,l_accrual_date
	                 ,p_batch_name
	                 ,l_func_currency_code
                     ,l_return_status);
        IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          Okl_Api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AGN_REPORT_ERROR');
  	      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    END IF;

        -- Open cursor to select contracts for accrual processing
        -- Bug 4602404.
        -- Fixing exit clause. Reducing LIMIT to 100 as recommended.
	  	OPEN process_accruals_csr;
	    LOOP
	      FETCH process_accruals_csr BULK COLLECT INTO l_contract_num_tbl LIMIT 100;
          EXIT WHEN l_contract_num_tbl.COUNT = 0;

          -- Proceed only if data found
          IF l_contract_num_tbl.COUNT > 0 THEN
            -- initialize variables for next set of contracts
            IF l_accrual_contracts_tbl.COUNT > 0 THEN
              l_accrual_contracts_tbl.DELETE;
            END IF;
            l_counter := 1;

            -- For each contract number get contract details
            FOR i IN l_contract_num_tbl.FIRST..l_contract_num_tbl.LAST
            LOOP

		      FOR l_accrual_contracts IN accrual_contracts_csr(l_contract_num_tbl(i))
		      LOOP
		        l_accrual_contracts_tbl(l_counter).contract_id := l_accrual_contracts.id;
		        l_accrual_contracts_tbl(l_counter).contract_number := l_accrual_contracts.contract_number;
			    l_accrual_contracts_tbl(l_counter).sts_code := l_accrual_contracts.sts_code;
		  	    l_accrual_contracts_tbl(l_counter).product_id := l_accrual_contracts.pdt_id;
		        l_accrual_contracts_tbl(l_counter).accrual_status := l_accrual_contracts.generate_accrual_yn;
		        l_accrual_contracts_tbl(l_counter).override_status := l_accrual_contracts.generate_accrual_override_yn;
		        l_accrual_contracts_tbl(l_counter).start_date := l_accrual_contracts.start_date;
		        l_accrual_contracts_tbl(l_counter).deal_type := l_accrual_contracts.deal_type;
		        l_accrual_contracts_tbl(l_counter).khr_currency_code := l_accrual_contracts.currency_code;
		        l_accrual_contracts_tbl(l_counter).currency_conv_type := l_accrual_contracts.currency_conversion_type;
		        l_accrual_contracts_tbl(l_counter).currency_conv_date := l_accrual_contracts.currency_conversion_date;
		        l_accrual_contracts_tbl(l_counter).currency_conv_rate := l_accrual_contracts.currency_conversion_rate;
			    l_counter := l_counter + 1;
		      END LOOP; --FOR l_accrual_contracts IN accrual_contracts_csr

            END LOOP;


              -- Call process accruals for ech contract
              IF l_accrual_contracts_tbl.COUNT > 0 THEN

                FOR y IN l_accrual_contracts_tbl.FIRST..l_accrual_contracts_tbl.LAST
                LOOP

                l_process_accrual_rec := NULL;

                l_process_accrual_rec.contract_id := l_accrual_contracts_tbl(y).contract_id;
	            l_process_accrual_rec.contract_number := l_accrual_contracts_tbl(y).contract_number;
	            l_process_accrual_rec.sts_code := l_accrual_contracts_tbl(y).sts_code;
	            l_process_accrual_rec.product_id := l_accrual_contracts_tbl(y).product_id;
	            l_process_accrual_rec.accrual_status := l_accrual_contracts_tbl(y).accrual_status;
	            l_process_accrual_rec.override_status := l_accrual_contracts_tbl(y).override_status;
  	            l_process_accrual_rec.start_date := l_accrual_contracts_tbl(y).start_date;
	            l_process_accrual_rec.deal_type := l_accrual_contracts_tbl(y).deal_type;
	            l_process_accrual_rec.khr_currency_code := l_accrual_contracts_tbl(y).khr_currency_code;
	            l_process_accrual_rec.currency_conv_type := l_accrual_contracts_tbl(y).currency_conv_type;
	            l_process_accrual_rec.currency_conv_date := l_accrual_contracts_tbl(y).currency_conv_date;
	            l_process_accrual_rec.currency_conv_rate := l_accrual_contracts_tbl(y).currency_conv_rate;

	            l_process_accrual_rec.func_currency_code := l_func_currency_code;
	            l_process_accrual_rec.try_id := l_try_id;
	            l_process_accrual_rec.reverse_date_to := l_reverse_date_to;
	            l_process_accrual_rec.batch_name := p_batch_name;
	            l_process_accrual_rec.sob_id := l_sob_id;
	            l_process_accrual_rec.accrual_date := l_accrual_date;
	            l_process_accrual_rec.period_end_date := l_period_end_date;
	            l_process_accrual_rec.period_start_date	:= l_period_start_date;
	            l_process_accrual_rec.source_trx_id := l_source_trx_id;
	            l_process_accrual_rec.source_trx_type := l_source_trx_type;
	            l_process_accrual_rec.submission_mode := 'BATCH';
	            l_process_accrual_rec.rev_rec_method := p_rev_rec_method;

   	            l_contract_counter := l_contract_counter + 1;
                IF (l_contract_counter = g_commit_cycle) THEN
	              COMMIT;
                  l_contract_counter := 0;
                END IF;

                PROCESS_ACCRUALS(
	    	      p_api_version => l_api_version,
				  p_init_msg_list => l_init_msg_list,
			      x_return_status => l_return_status,
			      x_msg_count => l_msg_count,
			      x_msg_data => l_msg_data,
			      p_process_accrual_rec => l_process_accrual_rec);

                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                  l_contract_error_tbl(l_contract_error_count) := l_process_accrual_rec.contract_number;
        	      l_contract_error_count := l_contract_error_count + 1;
        	    END IF;

                END LOOP; -- FOR y IN l_accrual_contracts_tbl.FIRST
              END IF; --IF l_accrual_contracts_tbl.COUNT > 0 THEN

            -- delete processed records from parallel process table
            FORALL i IN l_contract_num_tbl.FIRST..l_contract_num_tbl.LAST
              DELETE FROM OKL_PARALLEL_PROCESSES
              WHERE OBJECT_VALUE = l_contract_num_tbl(i);

            l_contract_num_tbl.DELETE;
          END IF; --IF l_contract_num_tbl.COUNT > 0 THEN

          EXIT WHEN process_accruals_csr%NOTFOUND;
	    END LOOP;
		CLOSE process_accruals_csr;


        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CNTRCT_ERROR_TITLE'));
	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_CNT_ERR_UNDERLINE'));
	    IF l_contract_error_tbl.COUNT > 0 THEN
	      FOR x IN l_contract_error_tbl.FIRST..l_contract_error_tbl.LAST
	      LOOP
	        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_contract_error_tbl(x));
	      END LOOP;
	      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
	      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_ADD_INFO'));
	    END IF;

    retcode := 0;
    l_return_status := OKL_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      l_return_status := Okl_Api.G_RET_STS_ERROR;

      -- print the error message in the log file and output files
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_ERROR'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
      IF (l_outer_error_msg_tbl.COUNT > 0) THEN
        FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
        LOOP
           FND_FILE.PUT_LINE(FND_FILE.LOG, l_outer_error_msg_tbl(i));
        END LOOP;
      END IF;

    retcode := 2;

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      -- print the error message in the log file
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_ERROR'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
        IF (l_outer_error_msg_tbl.COUNT > 0) THEN
          FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_outer_error_msg_tbl(i));
          END LOOP;
        END IF;

      retcode := 2;

    WHEN OTHERS THEN

      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      -- print the error message in the log file
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_ERROR'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
        IF (l_outer_error_msg_tbl.COUNT > 0) THEN
          FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_outer_error_msg_tbl(i));
          END LOOP;
        END IF;

       errbuf := SQLERRM;
       retcode := 2;

  END GENERATE_ACCRUALS_PARALLEL;


  PROCEDURE GENERATE_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_accrual_rec IN adjust_accrual_rec_type) IS

    -- declare local variables
	l_contract_id		    OKL_K_HEADERS_FULL_V.id%TYPE;
	l_contract_number       OKL_K_HEADERS_FULL_V.contract_number%TYPE;
	l_accrual_status		OKL_K_HEADERS_FULL_V.generate_accrual_yn%TYPE;
	l_override_status		OKL_K_HEADERS_FULL_V.generate_accrual_override_yn%TYPE;
	l_start_date    		OKL_K_HEADERS_FULL_V.start_date%TYPE;
	l_sts_code			    OKL_K_HEADERS_FULL_V.sts_code%TYPE;
	l_product_id            OKL_K_HEADERS_FULL_V.pdt_id%TYPE;
	l_deal_type             OKL_K_HEADERS_FULL_V.deal_type%TYPE;
	l_try_id                OKL_TRX_TYPES_V.id%TYPE;
	l_accrual_reversal_days OKL_SYS_ACCT_OPTS.accrual_reversal_days%TYPE;
	l_func_currency_code    OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
	l_khr_currency_code     OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE;
	l_currency_conv_type    OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_TYPE%TYPE;
	l_currency_conv_rate    OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_RATE%TYPE;
	l_currency_conv_date    OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_DATE%TYPE;
    l_sob_id                OKL_SYS_ACCT_OPTS.set_of_books_id%TYPE;
    l_source_trx_type       OKL_TRX_CONTRACTS.SOURCE_TRX_TYPE%TYPE;
    l_source_trx_id         OKL_TRX_CONTRACTS.SOURCE_TRX_ID%TYPE;
    l_try_name              OKL_TRX_TYPES_V.NAME%TYPE := 'Accrual';
	l_reverse_date_to       DATE;
    l_sob_name              VARCHAR2(2000);
	l_api_version           CONSTANT NUMBER := 1.0;
	l_api_name              CONSTANT VARCHAR2(30) := 'GENERATE_ACCRUALS';
	l_init_msg_list         VARCHAR2(2000) := OKL_API.G_FALSE;
	l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(2000);
	l_period_name           VARCHAR2(2000);
	l_period_start_date     DATE;
	l_period_end_date       DATE;
    l_org_id                NUMBER;
    l_org_name              VARCHAR2(2000);
    l_period_status         VARCHAR2(1);
    l_accrual_date          DATE;
    l_process_accrual_rec   process_accrual_rec_type;
    l_rev_rec_method        VARCHAR2(2000);

    --dkagrawa changed cursor to use view OKL_PROD_QLTY_VAL_UV than okl_product_parameters_v
    CURSOR accrual_contract_csr (p_khr_id NUMBER) IS
    SELECT chr.contract_number
          ,chr.start_date
          ,chr.sts_code
          ,khr.pdt_id
          ,khr.generate_accrual_yn
          ,khr.generate_accrual_override_yn
          ,khr.deal_type
		  ,chr.currency_code
		  ,khr.currency_conversion_type
		  ,khr.currency_conversion_rate
		  ,khr.currency_conversion_date
          ,pdt.quality_val revenue_recognition_method
    FROM OKC_K_HEADERS_B chr,
         OKL_K_HEADERS khr,
         OKL_PROD_QLTY_VAL_UV pdt
    WHERE chr.id = p_khr_id
    AND chr.id = khr.id
    AND chr.scs_code = 'LEASE'
    AND chr.sts_code IN ('BOOKED','EVERGREEN')
    AND khr.pdt_id = pdt.pdt_id
    AND pdt.quality_name = 'REVENUE_RECOGNITION_METHOD'
-- modified by zrehman for Bug#6788005 on 04-Feb-2008 start
    UNION
    SELECT chr.contract_number
          ,chr.start_date
          ,chr.sts_code
          ,khr.pdt_id
          ,khr.generate_accrual_yn
          ,khr.generate_accrual_override_yn
          ,khr.deal_type
		  ,chr.currency_code
		  ,khr.currency_conversion_type
		  ,khr.currency_conversion_rate
		  ,khr.currency_conversion_date
          ,'STREAMS' revenue_recognition_method
    FROM OKC_K_HEADERS_B chr,
         OKL_K_HEADERS khr
    WHERE chr.id = p_khr_id
    AND chr.id = khr.id
    AND chr.scs_code = 'INVESTOR'
    AND chr.sts_code = 'ACTIVE'
-- modified by zrehman for Bug#6788005 on 04-Feb-2008 end
;


    l_accrual_contracts           accrual_contract_csr%ROWTYPE;

  BEGIN

    -- Set save point
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- validate input parameters
    IF (p_accrual_rec.contract_id IS NULL) OR (p_accrual_rec.contract_id = OKL_API.G_MISS_NUM) THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_ACN_KHR_ID_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;
    l_contract_id := p_accrual_rec.contract_id;

    IF (p_accrual_rec.accrual_date IS NULL) OR (p_accrual_rec.accrual_date = Okl_Api.G_MISS_DATE) THEN
       Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_AGN_DATE_ERROR');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_accrual_date := p_accrual_rec.accrual_date;

    IF (p_accrual_rec.source_trx_id IS NULL) OR (p_accrual_rec.source_trx_id = Okl_Api.G_MISS_NUM) THEN
       Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_AGN_SRC_TRX_ID_ERROR');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_source_trx_id := p_accrual_rec.source_trx_id;

    IF (p_accrual_rec.source_trx_type IS NULL) OR (p_accrual_rec.source_trx_type = Okl_Api.G_MISS_CHAR) THEN
       Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_AGN_SRC_TRX_TYPE_ERROR');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_source_trx_type := p_accrual_rec.source_trx_type;

    -- get common info
    GET_COMMON_INFO (p_accrual_date => l_accrual_date,
                     x_try_id => l_try_id,
                     x_period_name => l_period_name,
                     x_period_start_date => l_period_start_date,
                     x_period_end_date => l_period_end_date,
                     x_sob_id => l_sob_id,
                     x_sob_name => l_sob_name,
                     x_org_id => l_org_id,
                     x_org_name => l_org_name,
                     x_accrual_reversal_days => l_accrual_reversal_days,
                     x_func_currency_code => l_func_currency_code,
                     x_return_status => l_return_status
                     );
      WRITE_TO_LOG('The parameters returned after the GET_COMMON_INFO call');
      WRITE_TO_LOG('======================================================');
      WRITE_TO_LOG('Return Status     :'||l_return_status);
      WRITE_TO_LOG('Transaction Id    :'||l_try_id);
      WRITE_TO_LOG('Period Name       :'||l_period_name);
      WRITE_TO_LOG('Period Start Date :'||l_period_start_date);
      WRITE_TO_LOG('Period End Date   :'||l_period_end_date);
      WRITE_TO_LOG('Set Of Books Id   :'||l_sob_id);
      WRITE_TO_LOG('Set Of Books Name :'||l_sob_name);
      WRITE_TO_LOG('Org Id            :'||l_org_id);
      WRITE_TO_LOG('Org Name          :'||l_org_name);
      WRITE_TO_LOG('Accrual Rev Days  :'||l_accrual_reversal_days);
      WRITE_TO_LOG('Func Currency Code:'||l_func_currency_code);
    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_COM_INFO_ERROR');
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_COM_INFO_ERROR');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- Calculate the number of days (to_date) to reverse in case of non-accrual
    l_reverse_date_to := l_accrual_date - l_accrual_reversal_days;
    IF l_reverse_date_to IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'REVERSE_DATE_TO');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR l_accrual_contracts IN accrual_contract_csr (l_contract_id)
    LOOP
      l_contract_number := l_accrual_contracts.contract_number;
  	  l_sts_code := l_accrual_contracts.sts_code;
      l_product_id := l_accrual_contracts.pdt_id;
      l_accrual_status := l_accrual_contracts.generate_accrual_yn;
      l_override_status := l_accrual_contracts.generate_accrual_override_yn;
      l_start_date := l_accrual_contracts.start_date;
      l_deal_type := l_accrual_contracts.deal_type;
      l_khr_currency_code := l_accrual_contracts.currency_code;
      l_currency_conv_type := l_accrual_contracts.currency_conversion_type;
      l_currency_conv_date := l_accrual_contracts.currency_conversion_date;
      l_currency_conv_rate := l_accrual_contracts.currency_conversion_rate;
      l_rev_rec_method := l_accrual_contracts.revenue_recognition_method;
    END LOOP;

    IF l_contract_number IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CONTRACT_NUMBER');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_sts_code IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'STS_CODE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_sts_code NOT IN ('BOOKED', 'EVERGREEN', 'ACTIVE') THEN
      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_AGN_STS_CODE_ERROR',
                          p_token1       => g_contract_number_token,
                          p_token1_value => l_contract_number);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_product_id IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PRODUCT_ID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_accrual_status IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'GENERATE_ACCRUAL_YN');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_override_status IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'GENERATE_ACCRUAL_OVERRIDE_YN');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_start_date IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'START_DATE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
-- modified by zrehman for Bug#6788005 on 11-Feb-2008 start
    IF l_deal_type IS NULL AND l_sts_code NOT IN ('ACTIVE') THEN
-- modified by zrehman for Bug#6788005 on 11-Feb-2008 end
      OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DEAL_TYPE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_khr_currency_code IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CURRENCY_CODE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_rev_rec_method IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'REVENUE_RECOGNITION_METHOD');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    l_process_accrual_rec := NULL;

    l_process_accrual_rec.contract_id := l_contract_id;
    l_process_accrual_rec.contract_number := l_contract_number;
    l_process_accrual_rec.sts_code := l_sts_code;
    l_process_accrual_rec.product_id := l_product_id;
    l_process_accrual_rec.accrual_status := l_accrual_status;
    l_process_accrual_rec.override_status := l_override_status;
    l_process_accrual_rec.start_date := l_start_date;
    l_process_accrual_rec.deal_type := l_deal_type;
    l_process_accrual_rec.khr_currency_code := l_khr_currency_code;
    l_process_accrual_rec.currency_conv_type := l_currency_conv_type;
    l_process_accrual_rec.currency_conv_date := l_currency_conv_date;
    l_process_accrual_rec.currency_conv_rate := l_currency_conv_rate;

    l_process_accrual_rec.func_currency_code := l_func_currency_code;
    l_process_accrual_rec.try_id := l_try_id;
    l_process_accrual_rec.reverse_date_to := l_reverse_date_to;
    l_process_accrual_rec.batch_name := p_accrual_rec.description;
    l_process_accrual_rec.sob_id := l_sob_id;
    l_process_accrual_rec.accrual_date := l_accrual_date;
    l_process_accrual_rec.period_end_date := l_period_end_date;
    l_process_accrual_rec.period_start_date	:= l_period_start_date;
    l_process_accrual_rec.source_trx_id := l_source_trx_id;
    l_process_accrual_rec.source_trx_type := l_source_trx_type;
    l_process_accrual_rec.submission_mode := 'ONLINE';
    --l_process_accrual_rec.submission_mode := 'BATCH';
    l_process_accrual_rec.rev_rec_method := l_rev_rec_method;

    PROCESS_ACCRUALS(
		    p_api_version => l_api_version,
			p_init_msg_list => l_init_msg_list,
		    x_return_status => l_return_status,
		    x_msg_count => l_msg_count,
		    x_msg_data => l_msg_data,
            p_process_accrual_rec => l_process_accrual_rec
			);

    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
	  -- need to leave
 	    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

    WHEN OTHERS THEN

      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END GENERATE_ACCRUALS;

-- Bug 4884618
-- Caching system option value
BEGIN

  FOR x IN sty_select_basis_csr
  LOOP
    l_sty_select_basis := x.validate_khr_start_date;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => SQLCODE,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => SQLERRM);

END OKL_GENERATE_ACCRUALS_PVT;

/
