--------------------------------------------------------
--  DDL for Package Body OKL_SEEDED_FUNCTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SEEDED_FUNCTIONS_PVT" AS
/* $Header: OKLRSFFB.pls 120.125.12010000.11 2010/01/18 08:05:47 sosharma ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

-- mvasudev, 10/10/2003
----------------------------------------------------------------------------
-- Global Constants
----------------------------------------------------------------------------
 G_FINAL_DATE   CONSTANT    DATE    	:= TO_DATE('1','j') + 5300000;

----------------------------------------------------------------------------
-- Procedures and Functions
----------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Start of Comments
--  FUNCTION: INS_MONTHLY_PREMIUM
--  DESC   : It returns monthly insurance premium
--  IN     : p_contract_id ,p_contract_line_id
--  OUT    : Monthly Premium
-- Created By: Dalip Khandel        (dkhandel)
-- Version: 1.0
-- End of Commnets
----------------------------------------------------------------------------------------------------

FUNCTION INS_MONTHLY_PREMIUM(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
) RETURN NUMBER
IS
  l_amount NUMBER := 0;
  ls_payment_freq VARCHAR2(30) ;
  l_monthly_premium NUMBER := 0;
  l_freq_factor  NUMBER := 0;
  date_to   DATE ;
  date_from DATE ;

  CURSOR c_monthly_premium (p_contract_id  NUMBER,p_contract_line_id NUMBER )
  IS
  SELECT PREMIUM , IPF_CODE, DATE_TO , DATE_FROM
  FROM OKL_INS_POLICIES_B IPYB
  WHERE IPYB.kle_id = p_contract_line_id
  AND IPYB.khr_id = p_contract_id  ;

BEGIN

  OPEN c_monthly_premium (p_contract_id,p_contract_line_id );
    FETCH c_monthly_premium INTO l_amount, ls_payment_freq, date_to, date_from;
    IF(c_monthly_premium%NOTFOUND) THEN
         Okc_Api.set_message(G_APP_NAME, G_INVALID_CONTRACT_LINE,
         G_COL_NAME_TOKEN,p_contract_line_id);
        -- x_return_status := OKC_API.G_RET_STS_ERROR ;
         CLOSE c_monthly_premium ;
         RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF ;
   CLOSE c_monthly_premium;

  	IF(ls_payment_freq = 'MONTHLY') THEN
		l_freq_factor := 1;
	ELSIF(ls_payment_freq = 'BI_MONTHLY') THEN
		l_freq_factor := 1/2;
	ELSIF(ls_payment_freq = 'HALF_YEARLY') THEN
	   l_freq_factor := 6;	--- ETC.
	ELSIF(ls_payment_freq = 'QUARTERLY') THEN
	 	l_freq_factor := 3;
	ELSIF(ls_payment_freq = 'YEARLY') THEN
	 	l_freq_factor := 12;
	ELSIF(ls_payment_freq = 'LUMP_SUM') THEN
                -- Bug# 4056484 PAGARG removing rounding
	 	l_freq_factor :=   MONTHS_BETWEEN( date_to,date_from);
	END IF;
    l_monthly_premium   := l_amount / l_freq_factor ;
  RETURN l_monthly_premium;
  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;

  ----------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Start of Comments
--  FUNCTION: INS_REFUNDABLE_MONTHS
--  DESC   : It returns number of months to be refunded
--  IN     : p_contract_id ,p_contract_line_id
--  OUT    : Number of months
-- Created By: Dalip Khandel        (dkhandel)
-- Version: 1.0
-- End of Commnets
----------------------------------------------------------------------------------------------------

FUNCTION INS_REFUNDABLE_MONTHS(
 p_contract_id                   IN NUMBER
 -- ,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ,p_contract_line_id             IN NUMBER
)
RETURN NUMBER
 IS


   CURSOR c_total_amount_paid (p_sty_id NUMBER)
   IS
   SELECT COUNT(*)
   FROM  okl_strm_elements STRE, OKL_STREAMS STR
   WHERE STR.ID =  STRE.STM_ID
    AND STR.STY_ID = p_sty_id
    AND STRE.DATE_BILLED IS NOT NULL
    AND STR.KHR_ID = p_contract_id
    AND STR.KLE_ID = p_contract_line_id;

     CURSOR  C_OKL_STRM_TYPE_REC_V IS
      SELECT ID
      FROM OKL_STRM_TYPE_TL
      WHERE NAME = 'INSURANCE RECEIVABLE'
      AND LANGUAGE = 'US';

  CURSOR c_monthly_premium (p_contract_id  NUMBER,p_contract_line_id NUMBER )
  IS
  SELECT  IPF_CODE, DATE_TO , DATE_FROM --, CANCELLATION_DATE --++Effective DatedTermination ++---
  FROM OKL_INS_POLICIES_B IPYB
  WHERE IPYB.kle_id = p_contract_line_id
  AND IPYB.khr_id = p_contract_id  ;


  ls_payment_freq  OKL_INS_POLICIES_B.IPF_CODE%TYPE;
  date_to   OKL_INS_POLICIES_B.DATE_TO%TYPE ;
  date_from OKL_INS_POLICIES_B.DATE_FROM%TYPE ;
  cancel_date OKL_INS_POLICIES_B.CANCELLATION_DATE%TYPE;
  l_stm_type_id     OKL_STRM_TYPE_TL.ID%TYPE := 0;


  l_profile_value NUMBER := 0;
  l_months_to_refund NUMBER := 0;

  l_no_of_rec      NUMBER := 0;
  l_freq_factor NUMBER;
  l_total_num_months_paid NUMBER;
  l_total_consumed_months NUMBER;
  l_unconsumed_months NUMBER;
  l_cancellation_date DATE; ---++ Ins Effective Dated Term Changes ++----
  l_cancellation_reason VARCHAR2(30);---++ Ins Effective Dated Term Changes ++----
  l_return_status                        VARCHAR2(3) := Okl_Api.G_RET_STS_SUCCESS;

BEGIN
        -- ********************************************
	-- Extract Insurance Cancellation Date from global variables
	-- ********************************************
	IF  okl_execute_formula_pub.g_additional_parameters.EXISTS(1)
	AND okl_execute_formula_pub.g_additional_parameters(1).name = ' CANCELLATION DATE'
	AND okl_execute_formula_pub.g_additional_parameters(1).value IS NOT NULL
	THEN
		l_cancellation_date := TO_DATE
			(okl_execute_formula_pub.g_additional_parameters(1).value, 'MM/DD/YYYY');
	END IF;
IF  okl_execute_formula_pub.g_additional_parameters.EXISTS(2)
	AND okl_execute_formula_pub.g_additional_parameters(2).name = ' CANCELLATION REASON'
	AND okl_execute_formula_pub.g_additional_parameters(2).value IS NOT NULL
	THEN
		l_cancellation_reason := TO_char
			(okl_execute_formula_pub.g_additional_parameters(2).value);
	END IF;
        ---++ Ins Effective Dated Term Changes End ++----

  -- GET profile value
  l_profile_value := fnd_profile.value('OKLINMAXTERMFORINS');

  IF(( l_profile_value =  NULL) OR (l_profile_value = OKC_API.G_MISS_NUM )) THEN
     l_unconsumed_months := 0 ;
  END IF;

    /*OPEN C_OKL_STRM_TYPE_REC_V ;
    FETCH C_OKL_STRM_TYPE_REC_V INTO l_stm_type_id;
    IF(C_OKL_STRM_TYPE_REC_V%NOTFOUND) THEN
         Okc_Api.set_message(G_APP_NAME, 'OKL_NO_TRANSACTION',
         G_COL_NAME_TOKEN,'Billing');
         CLOSE C_OKL_STRM_TYPE_REC_V ;
         RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF ;
    CLOSE C_OKL_STRM_TYPE_REC_V;*/
  -- cursor fetch replaced with the streams util call, change
  -- done for user defined streams impacts, bug 3924300
  -- begin changes for bug 3924300

   OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                                   'INSURANCE_RECEIVABLE',
                                                   l_return_status,
                                                   l_stm_type_id);
   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          Okc_Api.set_message(G_APP_NAME, 'OKL_NO_STREAM_TYPE', G_PURPOSE_TOKEN,'INSURANCE_RECEIVABLE'); -- bug 4024785
                   RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;
  -- end changes for bug 3924300


     OPEN c_total_amount_paid(l_stm_type_id) ;
    FETCH c_total_amount_paid INTO l_no_of_rec;
    IF(c_total_amount_paid%NOTFOUND) THEN
         l_no_of_rec := 0;
   END IF ;
   CLOSE c_total_amount_paid;


   OPEN c_monthly_premium (p_contract_id,p_contract_line_id );
    FETCH c_monthly_premium INTO  ls_payment_freq, date_to, date_from;--, cancel_date;--++ Effective Dated TErmination ++--
    IF(c_monthly_premium%NOTFOUND) THEN
         Okc_Api.set_message(G_APP_NAME, G_INVALID_CONTRACT_LINE,
         G_COL_NAME_TOKEN,p_contract_line_id);
        -- x_return_status := OKC_API.G_RET_STS_ERROR ;
         CLOSE c_monthly_premium ;
         RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF ;
   CLOSE c_monthly_premium;

   ---++ Ins Effective Dated Term Changes Start ++----
  IF(( l_cancellation_date IS  NULL) OR (l_cancellation_date = OKC_API.G_MISS_DATE )) THEN
     cancel_date := SYSDATE ;
   ELSE
     cancel_date := l_cancellation_date;
   END IF;
   ---++ Ins Effective Dated Term Changes End ++----

     IF(ls_payment_freq = 'MONTHLY') THEN
		l_freq_factor := 1;
	ELSIF(ls_payment_freq = 'BI_MONTHLY') THEN
		l_freq_factor := 1/2;
	ELSIF(ls_payment_freq = 'HALF_YEARLY') THEN
			   l_freq_factor := 6;	--- ETC.
	ELSIF(ls_payment_freq = 'QUARTERLY') THEN
			 	l_freq_factor := 3;
	ELSIF(ls_payment_freq = 'YEARLY') THEN
			 	l_freq_factor := 12;
	ELSIF(ls_payment_freq = 'LUMP_SUM') THEN
                 --Bug# 4056484 PAGARG removing rounding
	 	l_freq_factor :=   MONTHS_BETWEEN( date_to,date_from);
	END IF;

    l_total_num_months_paid := l_freq_factor * l_no_of_rec;
    IF(( l_total_num_months_paid IS NULL) OR (l_total_num_months_paid = OKC_API.G_MISS_NUM )) THEN
     l_total_num_months_paid := 0 ;
   END IF;
        --- ++++ Eff Dated Term Qte Changes +++++ ----------
                    IF cancel_date < date_from THEN
                    --** If Eff date of Termination is earlier than Policy start date then
                    --** calculate consumed months as insurance start to SYSDATE
                     IF date_from < SYSDATE THEN
                        l_total_consumed_months := MONTHS_BETWEEN(SYSDATE ,date_from);
                     ELSIF date_from > SYSDATE THEN
                        l_total_consumed_months := 0;
                     ELSE
                     -- Bug# 4056484 PAGARG removing rounding
                        l_total_consumed_months := MONTHS_BETWEEN( cancel_date,date_from);
                     END IF;
                    ELSE
                      -- Bug# 4056484 PAGARG removing rounding
                     l_total_consumed_months := MONTHS_BETWEEN( cancel_date,date_from);
                    END IF;
        --- ++++ Eff Dated Term Qte Changes +++++ ----------

    IF(( l_total_consumed_months IS  NULL) OR (l_total_consumed_months = OKC_API.G_MISS_NUM )) THEN
         l_total_consumed_months := 0 ;
   END IF;

    l_unconsumed_months := l_total_num_months_paid - l_total_consumed_months ;
   IF(( l_unconsumed_months IS  NULL) OR (l_unconsumed_months = OKC_API.G_MISS_NUM )) THEN
     l_unconsumed_months := 0 ;
   END IF;

    IF (l_unconsumed_months > l_profile_value) AND
           (l_cancellation_reason = 'CANCELED_BY_CUSTOMER') THEN --Eff Dated Term Changes ++---
      RETURN l_profile_value;
    ELSE
     RETURN  l_unconsumed_months;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;

------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    sechawla 6651621
  -- Function Name: line_taxable_basis
  -- Description:   Returns taxable basis amount for a transaction line.
  --                For header level Booking, Rebook and Sales Quote transactions,
  --                0 amount is returned. For line level transactions, the default
  --                taxable basis amount is returned. Default taxable basis amount
  --                is passed to this function from okl_process_sales_tax_pvt, by
  --                populating default_taxable_basis additional parameter. This function
  --                extracts the amount from this parameter and returns it back.
  -- Parameters:    IN:  p_khr_id, p_kle_id
  --                     additional parameters stored in g_additional_parameters
  --                OUT: amount
  -- Version:       1.0
  -- History      : 03-Jan-07 sechawla 6651621 - Created
  -- End of Commnets
------------------------------------------------------------------------------

FUNCTION line_taxable_basis (
	p_khr_id		IN NUMBER,
	p_kle_id	    IN NUMBER)
	RETURN NUMBER IS

    l_source_trx_name               VARCHAR2(150);
    l_line_name                     VARCHAR2(150);
    l_line_taxable_basis            NUMBER;
BEGIN

   --  Validate additional parameters availability
    IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'SOURCE_TRX_NAME'
           AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_source_trx_name := okl_execute_formula_pub.g_additional_parameters(I).value;
        ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'LINE_NAME'
           AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_line_name :=okl_execute_formula_pub.g_additional_parameters(I).value;
        ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'DEFAULT_TAXABLE_BASIS'
           AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_line_taxable_basis := to_number(okl_execute_formula_pub.g_additional_parameters(I).value);
        END IF;
      END LOOP;
	ELSE
	     -- Additional parameters are needed to evaluate taxable basis override formula LINE_TAXABLE_BASIS.
         OKL_API.set_message(p_app_name      => 'OKL',
                             p_msg_name      => 'OKL_TX_NO_TBO_PARAMS');
         RAISE Okl_Api.G_EXCEPTION_ERROR;

	END IF;

    IF l_source_trx_name IS NULL THEN
       OKL_API.set_message( p_app_name      => 'OKC',
                            p_msg_name      => G_REQUIRED_VALUE,
                            p_token1        => G_COL_NAME_TOKEN,
                            p_token1_value  => 'SOURCE_TRX_NAME');

       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    IF  l_line_taxable_basis IS NULL THEN
        OKL_API.set_message( p_app_name     => 'OKC',
                            p_msg_name      => G_REQUIRED_VALUE,
                            p_token1        => G_COL_NAME_TOKEN,
                            p_token1_value  => 'DEFAULT_TAXABLE_BASIS');

        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    IF l_source_trx_name IN ('Booking','Rebook','Sales Quote') AND l_line_name IS NULL THEN
        --Contract Header or Sales Quote Header level tax call
          RETURN 0;
    ELSE
          RETURN l_line_taxable_basis;
    END IF;

EXCEPTION

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
          RETURN NULL;

	WHEN OTHERS THEN

		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_CONTRACTS_UNEXPECTED_ERROR',
			p_token1	=> 'SQLCODE',
			p_token1_value	=> SQLCODE,
			p_token2	=> 'SQLERRM',
			p_token2_value	=> SQLERRM);

		RETURN NULL;

END line_taxable_basis;

  ----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  contract_sumofrents
    -- Description:   returns the sum of amount on stream type - Rent.
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION contract_sum_of_rents(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'RETURN_CONTRACT_SUM_OF_RENTS';
    l_api_version	CONSTANT NUMBER	      := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_rents NUMBER := 0;

    CURSOR l_line_rents_csr (chrId NUMBER ) IS
    SELECT NVL(str.link_hist_stream_id,-1) link_hist_stream_id,
           NVL(SUM(sele.amount),0) amount
    FROM okl_strm_elements sele,
         okl_streams str,
         --okl_strm_type_tl sty,
         okl_strm_type_v sty,
         okl_K_lines_full_v kle,
         okc_statuses_b sts
    WHERE sele.stm_id = str.id
       AND str.sty_id = sty.id
       --AND UPPER(sty.name) = 'RENT'
       AND sty.stream_type_purpose = 'RENT'
       --AND sty.LANGUAGE = 'US'
       AND str.say_code = 'CURR'
       AND str.active_yn = 'Y'
       AND NVL( str.purpose_code, 'XXXX' ) = 'XXXX'
       AND str.khr_id = chrId
       AND str.kle_id = kle.id
       AND kle.chr_id = chrId
       AND kle.sts_code = sts.code
       AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD')
    GROUP BY str.link_hist_stream_id;

    CURSOR l_line_rents_adj_csr (p_stm_id NUMBER) IS
    SELECT NVL(SUM(sele.amount),0) amount
    FROM   okl_strm_elements sele
    WHERE  stm_id = p_stm_id
    AND    date_billed IS NOT NULL;

    CURSOR l_chr_rents_csr (chrId NUMBER ) IS
    SELECT NVL(SUM(sele.amount),0) amount
    FROM okl_strm_elements sele,
         okl_streams str,
         --okl_strm_type_tl sty
         okl_strm_type_v sty
    WHERE sele.stm_id = str.id
       AND str.sty_id = sty.id
       --AND UPPER(sty.name) = 'RENT'
       AND sty.stream_type_purpose = 'RENT'
       --AND sty.LANGUAGE = 'US'
       AND str.say_code = 'CURR'
       AND str.active_yn = 'Y'
       AND NVL( str.purpose_code, 'XXXX' ) = 'XXXX'
       AND str.khr_id = chrId
       AND NVL(str.kle_id, -1) = -1;

    l_chr_rents_rec l_chr_rents_csr%ROWTYPE;
    l_line_rents_amount NUMBER;
    l_rent_adj_amount   NUMBER;

  BEGIN

       IF ( p_chr_id IS NULL ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       l_line_rents_amount := 0;
       FOR l_line_rents_rec IN l_line_rents_csr (p_chr_id)
       LOOP
          l_line_rents_amount := NVL(l_line_rents_amount,0) + l_line_rents_rec.amount;

          IF (l_line_rents_rec.link_hist_stream_id <> -1) THEN
             l_rent_adj_amount := 0;
             OPEN l_line_rents_adj_csr (l_line_rents_rec.link_hist_stream_id);
             FETCH l_line_rents_adj_csr INTO l_rent_adj_amount;
             CLOSE l_line_rents_adj_csr;

             l_line_rents_amount := l_line_rents_amount - NVL(l_rent_adj_amount,0);
          END IF;
       END LOOP;

       /*
       OPEN l_chr_rents_csr( p_chr_id );
       FETCH l_chr_rents_csr INTO l_chr_rents_rec;
       CLOSE l_chr_rents_csr;
       */

       l_rents := l_line_rents_amount;

      RETURN l_rents;


    EXCEPTION
	WHEN OTHERS  THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;

  END contract_sum_of_rents;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  contract_income
    -- Description:   returns sum of all incomes of financial asset lines of a contract
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION contract_income(
            p_chr_id          IN  NUMBER,
            p_line_id          IN  NUMBER) RETURN NUMBER  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'RETURN_CONTRACT_INCOME';
    l_api_version	CONSTANT NUMBER	      := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_income NUMBER := 0;

  BEGIN

       IF ( p_chr_id IS NULL ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
--
-- Note: User defined stream: This stream type has been identified as
--       "Not being used" and hence not modified with its purpose
--
      SELECT NVL(SUM(sele.amount),0) INTO l_income
      FROM okl_strm_elements sele,
           okl_streams str,
           okl_strm_type_v sty,
	   okl_K_lines_full_v kle,
	   okc_statuses_b sts
      WHERE sele.stm_id = str.id
           AND str.sty_id = sty.id
           AND UPPER(sty.name) = 'UNEARNED INCOME'
           AND str.khr_id = p_chr_id
	   AND kle.sts_code = sts.code
	   AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');

      RETURN l_income;


    EXCEPTION

	WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;


  END contract_income;

--Bug# 3638568 : Function modifieed to conditionally include TERMINATED lines if called from pricing
----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  line_residualvalue
    -- Description:   returns the residual_value of the a financial asset line.
    -- Dependencies:
    -- Parameters: contract id and line id
    -- Version: 1.0
    -- SECHAWLA 05-MAY-04 3578894 : Modified to accomodate additional parameters for Reporting product
    -- SECHAWLA 02-FEB-05 4141411 : Added unexpected error exception handling block
    -- PRASJAIN Bug 6030917 : Added Proration Logic
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION line_residual_value(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(30) := 'RETURN_LINE_RESIDUAL_VALUE';
    l_api_version       CONSTANT NUMBER       := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_residual_value NUMBER := 0.0;
    l_oec            NUMBER := 0.0;

    CURSOR residual_csr( chrId NUMBER, lineId NUMBER ) IS
    SELECT NVL(kle.residual_value,0) Value,
           NVL(kle.residual_percentage,0) Percent
          ,ls.lty_code lty_Code --added bug 7439724
    FROM OKC_LINE_STYLES_B LS,
         okl_K_lines_full_v kle,
         okc_statuses_b sts
    WHERE  LS.ID = KLE.LSE_ID
         --Modified bug 7439724
          AND LS.LTY_CODE in ('FREE_FORM1',
                                  'FEE',
                                  'SOLD_SERVICE'
                             )
         AND KLE.ID = lineId
         AND KLE.DNZ_CHR_ID = chrId
         AND kle.sts_code = sts.code
         AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');

    CURSOR residual_csr_incl_terminated( chrId NUMBER, lineId NUMBER ) IS
    SELECT NVL(kle.residual_value,0) Value,
           NVL(kle.residual_percentage,0) Percent
                    ,ls.lty_code lty_Code --added bug 7439724
    FROM OKC_LINE_STYLES_B LS,
         okl_K_lines_full_v kle,
         okc_statuses_b sts
    WHERE  LS.ID = KLE.LSE_ID
     --Modified bug 7439724
          AND LS.LTY_CODE in ('FREE_FORM1',
                                  'FEE',
                                  'SOLD_SERVICE'
                              )
         AND KLE.ID = lineId
         AND KLE.DNZ_CHR_ID = chrId
         AND kle.sts_code = sts.code
         AND sts.ste_code NOT IN ('EXPIRED', 'CANCELLED', 'HOLD');

   residual_rec residual_csr%ROWTYPE;
   --SECHAWLA 05-MAY-04 3578894 : new declarations
    l_rep_prod_streams_yn   VARCHAR2(1) := 'N';
    l_trx_date   DATE;
    l_k_end_date  DATE;

    -- get the K end date
    CURSOR  l_contract_csr(cp_chr_id IN NUMBER) IS
    SELECT  END_DATE
    FROM    okc_k_headers_b
    WHERE   id = cp_chr_id;

    l_discount_incl_terminated BOOLEAN := FALSE;
    l_proration_factor         NUMBER;

  BEGIN

      IF ( ( p_chr_id IS NULL ) OR ( p_line_id IS NULL ) ) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;

      END IF;

      -- SECHAWLA 05-MAY-04 3578894 : check the additional parameter for rep product
      --Validate additional parameters availability
      IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
        FOR I IN
Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.FIRST..Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.LAST LOOP
           IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(I).NAME = 'REP_PRODUCT_STRMS_YN'
               AND  Okl_Execute_Formula_Pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_rep_prod_streams_yn := Okl_Execute_Formula_Pub.g_additional_parameters(I).value;
           ELSIF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(I).NAME = 'OFF_LSE_TRX_DATE'
               AND  Okl_Execute_Formula_Pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_trx_date := TO_DATE(Okl_Execute_Formula_Pub.g_additional_parameters(I).value, 'MM/DD/YYYY');

           -- Start : Bug 6030917 : prasjain
           --added for getting the proration factor for partial unit termination
           ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'proration_factor'
           AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
           l_proration_factor := to_number(okl_execute_formula_pub.g_additional_parameters(I).value);
           -- End : Bug 6030917 : prasjain

           END IF;
        END LOOP;
          ELSE
         l_rep_prod_streams_yn := 'N';
          END IF;

      IF l_rep_prod_streams_yn = 'Y' THEN
         IF l_trx_date IS NULL THEN
         -- Can not calculate Net Investment for the reporting product as the transaction date is missing.
            Okl_Api.Set_Message(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_AM_AMORT_NO_TRX_DATE');
            RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;
      END IF;

      IF l_rep_prod_streams_yn = 'Y' THEN
         OPEN  l_contract_csr(p_chr_id);
         FETCH l_contract_csr INTO l_k_end_date;
         CLOSE l_contract_csr;

         IF l_k_end_date <= l_trx_date THEN
            RETURN 0;
         END IF;
      END IF;

    ----------

       -- IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0
       --AND Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(0).NAME = 'TERMINATED_LINES_YN'
       --AND  Okl_Execute_Formula_Pub.g_additional_parameters(0).value = 'Y' THEN

    -- rmunjulu 4042892
    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_discount_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;
           -- rmunjulu 4042892
       IF l_discount_incl_terminated THEN
         OPEN residual_csr_incl_terminated( p_chr_id, p_line_id );
         FETCH residual_csr_incl_terminated INTO residual_rec;
         IF( residual_csr_incl_terminated%NOTFOUND ) THEN
             RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;
         CLOSE residual_csr_incl_terminated;
    ELSE
         OPEN residual_csr( p_chr_id, p_line_id );
         FETCH residual_csr INTO residual_rec;
         IF( residual_csr%NOTFOUND ) THEN
             RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;
         CLOSE residual_csr;
    END IF;

     -- BUG 7439724 -- evaluate l_oec only for asset line
     --because l_oec will return null for fee and service lines
   IF residual_rec.lty_code = 'FREE_FORM1' THEN
     IF ( residual_rec.Value <> 0 ) THEN
        l_residual_value := residual_rec.Value;
      ELSE
        l_oec := line_oec( p_chr_id, p_line_id );
        IF ( l_oec IS NULL ) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
        l_residual_value := residual_rec.Percent * l_oec / 100.00;
      END IF;
   END IF; --BUG 7439724
     -- Start : Bug 6030917 : prasjain
     IF nvl(l_proration_factor,1) <> 1 THEN
       l_residual_value := l_residual_value * l_proration_factor;
     END IF;
     -- End : Bug 6030917 : prasjain

      RETURN l_residual_value;

    EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        IF residual_csr%ISOPEN THEN
           CLOSE residual_csr;
        END IF;

        IF l_contract_csr%ISOPEN THEN
           CLOSE l_contract_csr;
        END IF;

        RETURN NULL;
    -- SECHAWLA 02-FEB-05 4141411 : Added unexpected error exception handling block
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF residual_csr%ISOPEN THEN
           CLOSE residual_csr;
        END IF;

        IF l_contract_csr%ISOPEN THEN
           CLOSE l_contract_csr;
        END IF;

        RETURN NULL;
    WHEN OTHERS THEN
        IF residual_csr%ISOPEN THEN
           CLOSE residual_csr;
        END IF;

        IF l_contract_csr%ISOPEN THEN
           CLOSE l_contract_csr;
        END IF;

        Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
        RETURN NULL;


  END line_residual_value;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  contract_residualvalue
    -- Description:   returns the sum of residual_value of all financial asset lines of a contract.
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION contract_residual_value(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'RETURN_CONTRACT_RESIDUAL_VALUE';
    l_api_version	CONSTANT NUMBER	      := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_residual_value NUMBER := 0.0;
    l_lne_res_value  NUMBER := 0.0;

    CURSOR lines_csr( chrId NUMBER ) IS
    SELECT kle.id lineId
    FROM OKC_LINE_STYLES_B LS,
	 okl_K_lines_full_v kle,
	 okc_statuses_b sts
    WHERE LS.ID = KLE.LSE_ID
         AND LS.LTY_CODE ='FREE_FORM1'
         AND KLE.DNZ_CHR_ID = chrId
	 AND kle.sts_code = sts.code
	 AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');

    line_rec lines_csr%ROWTYPE;

  BEGIN

       IF ( p_chr_id IS NULL ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       FOR line_rec IN lines_csr( p_chr_id )
       LOOP
           IF( lines_csr%NOTFOUND ) THEN
               RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
           END IF;
           l_lne_res_value := line_residual_value( p_chr_id, line_rec.lineId );
           IF ( l_lne_res_value IS NULL ) THEN
               RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
           END IF;
           l_residual_value := l_residual_value + l_lne_res_value;
       END LOOP;

      RETURN l_residual_value;

    EXCEPTION

	WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;

  END contract_residual_value;


----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  contract_oec
    -- Description:   returns the OEC of a contract.
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION contract_oec(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'RETURN_CONTRACT_OEC';
    l_api_version	CONSTANT NUMBER	      := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

  BEGIN
      IF ( p_line_id IS NULL ) THEN
          RETURN line_oec( p_chr_id, NULL);
      ELSE
          RETURN line_oec( p_chr_id, p_line_id);
      END IF;
  END;

--Bug# 3638568 : This formula modified to conditionally include terminated lines
-----------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta

-- Procedure Name       : FUNCTION_oec_calc
-- Description          : FUNCTION_oec_calc
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Commnets

  FUNCTION  line_oec(p_dnz_chr_id IN  OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
                     --p_cle_id     IN  OKC_K_LINES_V.CLE_ID%TYPE DEFAULT Okl_Api.G_MISS_NUM)
                     p_cle_id     IN  OKC_K_LINES_V.CLE_ID%TYPE )
  RETURN NUMBER IS
    G_APP_NAME                   CONSTANT  VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
    G_PKG_NAME                   CONSTANT  VARCHAR2(200) := 'OKL_FORMULA_PVT';
    G_UNEXPECTED_ERROR           CONSTANT  VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
    G_COL_NAME_TOKEN             CONSTANT  VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
    G_SQLERRM_TOKEN              CONSTANT  VARCHAR2(200) := 'SQLerrm';
    G_SQLCODE_TOKEN              CONSTANT  VARCHAR2(200) := 'SQLcode';
    G_REQUIRED_VALUE             CONSTANT  VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
    G_NO_MATCHING_RECORD         CONSTANT  VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
    G_LINE_RECORD                CONSTANT  VARCHAR2(200) := 'OKL_LLA_LINE_RECORD';
    G_INVALID_CRITERIA           CONSTANT  VARCHAR2(200) := 'OKL_LLA_INVALID_CRITERIA';
    G_EXCEPTION_HALT_VALIDATION            EXCEPTION;
    G_EXCEPTION_STOP_VALIDATION            EXCEPTION;
    G_FIN_LINE_LTY_CODE                    OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM1';
    G_MODEL_LINE_LTY_CODE                  OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ITEM';
    G_ADDON_LINE_LTY_CODE                  OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ADD_ITEM';
    G_LEASE_SCS_CODE                       OKC_K_HEADERS_V.SCS_CODE%TYPE := 'LEASE';
    G_LOAN_SCS_CODE                        OKC_K_HEADERS_V.SCS_CODE%TYPE := 'LOAN';
    l_return_status                        VARCHAR2(3) := Okl_Api.G_RET_STS_SUCCESS;
    l_api_name                   CONSTANT  VARCHAR2(30)  := 'FUNCTION_OEC_CALC';
    ln_contract_oec                        OKL_K_LINES_V.OEC%TYPE := 0;
    lv_lty_code                            OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    ln_model_line_oec                      OKL_K_LINES_V.OEC%TYPE := 0;
    ln_addon_line_oec                      OKL_K_LINES_V.OEC%TYPE := 0;
    ln_total_line_oec                      OKL_K_LINES_V.OEC%TYPE := 0;
        l_capred_incl_terminated BOOLEAN := FALSE;
    -- Cursor to get the lty_code
    CURSOR get_lty_code(p_cle_id IN OKC_K_LINES_V.ID%TYPE) IS
    SELECT lse.lty_code
    FROM okc_k_lines_b cle,
         okc_line_styles_b lse
    WHERE cle.id = p_cle_id
    AND cle.lse_id = lse.id;
    -- Cursor to sum up oec for contract
    CURSOR c_contract_oec_calc(p_dnz_chr_id   OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT SUM(kle.oec) oec
    FROM OKL_K_LINES_V kle,
         OKC_K_LINES_V cle,
         OKC_K_HEADERS_V CHR
    WHERE CHR.id = p_dnz_chr_id
    AND CHR.id = cle.dnz_chr_id
    AND cle.sts_code NOT IN ( 'ABANDONED', 'TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD')
    AND cle.id = kle.id;

    CURSOR c_contract_oec_calc_incl_term(p_dnz_chr_id   OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT SUM(kle.oec) oec
    FROM OKL_K_LINES_V kle,
         OKC_K_LINES_V cle,
         OKC_K_HEADERS_V CHR
    WHERE CHR.id = p_dnz_chr_id
    AND CHR.id = cle.dnz_chr_id
    AND cle.sts_code NOT IN ( 'ABANDONED', 'EXPIRED', 'CANCELLED', 'HOLD')
    AND cle.id = kle.id;
    -- Cursor to sum up oec for given model line
    CURSOR c_model_oec_calc(p_top_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                            p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT SUM(cle.price_unit * cim.number_of_items) oec
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_items_v cim,
         okc_k_lines_v cle
    WHERE cle.cle_id = p_top_cle_id
    AND cle.dnz_chr_id = p_dnz_chr_id
    AND cle.id = cim.cle_id
    AND cle.dnz_chr_id = cim.dnz_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code IN (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);
    -- Cursor to sum up oec of addon line for a given top line
    CURSOR c_addon_oec_calc(p_top_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                            p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT SUM(cle.price_unit* cim.number_of_items) oec
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse3,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_items_v cim,
         okc_k_lines_b cle
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.dnz_chr_id = cim.dnz_chr_id
    AND cle.id = cim.cle_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_ADDON_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse2.lse_parent_id = lse3.id
    AND lse3.lty_code = G_FIN_LINE_LTY_CODE
    AND lse3.id = stl.lse_id
    AND stl.scs_code IN (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE)
    --AND cle.cle_id IN (SELECT cle.id
    AND exists (SELECT 1   --cle.id
                       FROM okc_subclass_top_line stlx,
                            okc_line_styles_b lse2x,
                            okc_line_styles_b lse1x,
                            okc_k_lines_b clex
                       WHERE clex.cle_id = p_top_cle_id
                       AND clex.dnz_chr_id = p_dnz_chr_id

                       AND clex.lse_id = lse1x.id
                       AND lse1x.lty_code = G_MODEL_LINE_LTY_CODE
                       AND lse1x.lse_parent_id = lse2x.id
                       AND lse2x.lty_code = G_FIN_LINE_LTY_CODE
                       AND lse2x.id = stlx.lse_id
                       AND stlx.scs_code IN (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE)
                       AND clex.id = cle.cle_id);

  --Bug 4631549
  --cursor to find if this is a re-lease contract
  Cursor l_chrb_csr (p_chr_id in number) is
  SELECT chrb.orig_system_source_code
  FROM   okc_k_headers_b chrb
  where  chrb.id = p_chr_id;

  l_chrb_rec l_chrb_csr%ROWTYPE;

  --cursor to get expected asset value for contract
  cursor l_chr_expcost_trmn_csr(p_chr_id in number) is
  SELECT SUM(kle.expected_asset_cost) expected_asset_cost
  FROM   OKL_K_LINES kle,
         OKC_K_LINES_B cleb
  WHERE  kle.id = cleb.id
  AND    cleb.dnz_chr_id = p_chr_id
  AND    cleb.lse_id     = 33
  AND    cleb.sts_code NOT IN ( 'ABANDONED', 'EXPIRED', 'CANCELLED', 'HOLD');

  cursor l_chr_expcost_csr(p_chr_id in number) is
  SELECT SUM(kle.expected_asset_cost) expected_asset_cost
  FROM   OKL_K_LINES kle,
         OKC_K_LINES_B cleb
  WHERE  kle.id = cleb.id
  AND    cleb.dnz_chr_id = p_chr_id
  AND    cleb.lse_id     = 33
  AND    cleb.sts_code NOT IN ( 'ABANDONED', 'TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');


  --cursor to get expected asset value for asset
  cursor l_cle_expcost_csr (p_cle_id in number) is
  Select nvl(kle.expected_asset_cost,0) expected_asset_cost
  from   okl_k_lines kle
  where  kle.id  = p_cle_id;


----------------------------------------------------------------------------------------------------
  -- Start of Commnets
  -- Badrinath Kuchibholta
  -- Procedure Name       : validate_dnz_chr_id
  -- Description          : validation with OKC_K_LINES_V
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- End of Commnets

  PROCEDURE validate_dnz_chr_id(p_dnz_chr_id IN OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
                                x_return_status OUT NOCOPY VARCHAR2) IS
    ln_dummy      NUMBER := 0;
    CURSOR c_dnz_chr_id_validate(p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT 1
                  FROM OKC_K_HEADERS_B CHR
                  WHERE CHR.id = p_dnz_chr_id; --);
  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_dnz_chr_id = Okl_Api.G_MISS_NUM) OR
       (p_dnz_chr_id IS NULL) THEN
       -- store SQL error message on message stack
      Okl_Api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'P_DNZ_CHR_ID');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    -- since we are creating a asset line
    -- we assume the cle_id will not null
    -- as the same is not top line and it will be sub line
    OPEN  c_dnz_chr_id_validate(p_dnz_chr_id);
    IF c_dnz_chr_id_validate%NOTFOUND THEN
      Okl_Api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'P_DNZ_CHR_ID');
      -- halt validation as it has no parent record
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_dnz_chr_id_validate INTO ln_dummy;
    CLOSE c_dnz_chr_id_validate;
    IF (ln_dummy = 0) THEN
      Okl_Api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'P_DNZ_CHR_ID');
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    -- We are here since the field is required
    -- Notify Error
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
     -- If the cursor is open then it has to be closed
     IF c_dnz_chr_id_validate%ISOPEN THEN
       CLOSE c_dnz_chr_id_validate;
     END IF;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_dnz_chr_id_validate%ISOPEN THEN
       CLOSE c_dnz_chr_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
  END validate_dnz_chr_id;
----------------------------------------------------------------------------------------------------
  BEGIN
    -- We need to validate the dnz_chr_id first
    -- We are taking care of the validating p_cle_id via cursor we use for calculations of oec
    validate_dnz_chr_id(p_dnz_chr_id    => p_dnz_chr_id,
                        x_return_status => l_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --Bug# 4631549
    --Find out if re-lease contract
    open l_chrb_csr(p_chr_id => p_dnz_chr_id);
    fetch l_chrb_csr into l_chrb_rec;
    close l_chrb_csr;
    --Bug# 4631549

        --Check whether terminated lines should be included
       -- IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
       --IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(0).NAME = 'TERMINATED_LINES_YN'
         -- AND  Okl_Execute_Formula_Pub.g_additional_parameters(0).value = 'Y' THEN
                  --l_capred_incl_terminated := TRUE;
           --END IF;

           -- rmunjulu 4042892
    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_capred_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;

    -- Now we start calculations of the OEC
    IF (p_dnz_chr_id IS NOT NULL OR
       p_dnz_chr_id <> Okl_Api.G_MISS_NUM) AND
      (p_cle_id IS NULL OR
       p_cle_id = Okl_Api.G_MISS_NUM) THEN
      -- To get the OEC of the contract

          --Bug# 4631549 :
          If nvl(l_chrb_rec.orig_system_source_code,okl_api.g_miss_char) = 'OKL_RELEASE' Then
             If l_capred_incl_terminated = TRUE Then
                OPEN l_chr_expcost_trmn_csr (p_chr_id => p_dnz_chr_id);
                FETCH l_chr_expcost_trmn_csr into ln_contract_oec;
                If l_chr_expcost_trmn_csr%NOTFOUND then
                    Okl_Api.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_NO_MATCHING_RECORD,
                               p_token1       => G_COL_NAME_TOKEN,
                               p_token1_value => 'p_dnz_chr_id');
                    RAISE Okl_Api.G_EXCEPTION_ERROR;
                End If;
                Close l_chr_expcost_trmn_csr;
             Else
                OPEN l_chr_expcost_csr (p_chr_id => p_dnz_chr_id);
                FETCH l_chr_expcost_csr into ln_contract_oec;
                If l_chr_expcost_csr%NOTFOUND then
                    Okl_Api.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_NO_MATCHING_RECORD,
                               p_token1       => G_COL_NAME_TOKEN,
                               p_token1_value => 'p_dnz_chr_id');
                    RAISE Okl_Api.G_EXCEPTION_ERROR;
                End If;
                Close l_chr_expcost_csr;
             End If;
          Else
          --End Bug 4631549
          IF l_capred_incl_terminated = TRUE THEN
             OPEN  c_contract_oec_calc_incl_term(p_dnz_chr_id => p_dnz_chr_id);
         IF c_contract_oec_calc_incl_term%NOTFOUND THEN
           Okl_Api.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_NO_MATCHING_RECORD,
                               p_token1       => G_COL_NAME_TOKEN,
                               p_token1_value => 'p_dnz_chr_id');
           RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;
         FETCH c_contract_oec_calc_incl_term INTO ln_contract_oec;
         CLOSE c_contract_oec_calc_incl_term;
          ELSE
         OPEN  c_contract_oec_calc(p_dnz_chr_id => p_dnz_chr_id);
         IF c_contract_oec_calc%NOTFOUND THEN
           Okl_Api.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_NO_MATCHING_RECORD,
                               p_token1       => G_COL_NAME_TOKEN,
                               p_token1_value => 'p_dnz_chr_id');
           RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;
         FETCH c_contract_oec_calc INTO ln_contract_oec;
         CLOSE c_contract_oec_calc;
          END IF;
      End If; -- Bug# 4631549
      -- Final Total Contract OEC
      ln_contract_oec := NVL(ln_contract_oec,0);
      RETURN(ln_contract_oec);
    ELSIF (p_dnz_chr_id IS NOT NULL OR
       p_dnz_chr_id <> Okl_Api.G_MISS_NUM) AND
      (p_cle_id IS NOT NULL OR
       p_cle_id <> Okl_Api.G_MISS_NUM) THEN
      -- To get the Line Style Code
      OPEN  get_lty_code(p_cle_id => p_cle_id);
      IF get_lty_code%NOTFOUND THEN
        Okl_Api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Financial Asset Line');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
      FETCH get_lty_code INTO lv_lty_code;
      CLOSE get_lty_code;
      IF lv_lty_code = G_FIN_LINE_LTY_CODE THEN
        --Bug# 4631549
        If l_chrb_rec.orig_system_source_code = 'OKL_RELEASE' then
           Open l_cle_expcost_csr (p_cle_id => p_cle_id);
           Fetch l_cle_expcost_csr into ln_total_line_oec;
           If l_cle_expcost_csr%NOTFOUND Then
               Okl_Api.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_NO_MATCHING_RECORD,
                                   p_token1       => G_COL_NAME_TOKEN,
                                   p_token1_value => 'Financial Asset Line');
               RAISE Okl_Api.G_EXCEPTION_ERROR;
           End If;
           Close l_cle_expcost_csr;
           ln_total_line_oec := nvl(ln_total_line_oec,0);
        Else --Bug# 4631549 end
        -- To get the OEC of the model Line
        OPEN c_model_oec_calc(p_top_cle_id => p_cle_id,
                              p_dnz_chr_id => p_dnz_chr_id);
        IF c_model_oec_calc%NOTFOUND THEN
          Okl_Api.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'Model Line');
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;
        FETCH c_model_oec_calc INTO ln_model_line_oec;
        CLOSE c_model_oec_calc;
        -- To get the OEC of the Addon line
-- DJANASWA change begin 11/12/08
/*        OPEN c_addon_oec_calc(p_top_cle_id => p_cle_id,
                              p_dnz_chr_id => p_dnz_chr_id);
        FETCH c_addon_oec_calc INTO ln_addon_line_oec;
        CLOSE c_addon_oec_calc;
*/
        ln_addon_line_oec := Okl_Seeded_Functions_Pvt.total_asset_addon_cost(
                              p_contract_id => p_dnz_chr_id, p_contract_line_id => p_cle_id);
-- DJANASWA change end 11/12/08

        ln_total_line_oec := NVL(ln_model_line_oec,0) + NVL(ln_addon_line_oec,0);
      End If; --Bug# 4631549
      ELSE
        Okl_Api.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_LINE_RECORD);
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
      RETURN(ln_total_line_oec);
    ELSE
      Okl_Api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_CRITERIA);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    -- If the cursor is open then it has to be closed
    IF get_lty_code%ISOPEN THEN
       CLOSE get_lty_code;
    END IF;
    IF c_contract_oec_calc%ISOPEN THEN
       CLOSE c_contract_oec_calc;
    END IF;
    IF c_contract_oec_calc_incl_term%ISOPEN THEN
       CLOSE c_contract_oec_calc_incl_term;
    END IF;
    IF c_model_oec_calc%ISOPEN THEN
       CLOSE c_model_oec_calc;
    END IF;
    IF c_addon_oec_calc%ISOPEN THEN
       CLOSE c_addon_oec_calc;
    END IF;
    RETURN(0);
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    -- If the cursor is open then it has to be closed
    IF get_lty_code%ISOPEN THEN
       CLOSE get_lty_code;
    END IF;
    IF c_contract_oec_calc%ISOPEN THEN
       CLOSE c_contract_oec_calc;
    END IF;
    IF c_contract_oec_calc_incl_term%ISOPEN THEN
       CLOSE c_contract_oec_calc_incl_term;
    END IF;
    IF c_model_oec_calc%ISOPEN THEN
       CLOSE c_model_oec_calc;
    END IF;
    IF c_addon_oec_calc%ISOPEN THEN
       CLOSE c_addon_oec_calc;
    END IF;
    RETURN(0);
    WHEN OTHERS THEN

    -- If the cursor is open then it has to be closed
    IF get_lty_code%ISOPEN THEN
       CLOSE get_lty_code;
    END IF;
    IF c_contract_oec_calc%ISOPEN THEN
       CLOSE c_contract_oec_calc;
    END IF;
    IF c_contract_oec_calc_incl_term%ISOPEN THEN
       CLOSE c_contract_oec_calc_incl_term;
    END IF;
    IF c_model_oec_calc%ISOPEN THEN
       CLOSE c_model_oec_calc;
    END IF;
    IF c_addon_oec_calc%ISOPEN THEN
       CLOSE c_addon_oec_calc;
    END IF;
    RETURN(0);
  END line_oec;

--Bug# 3638568 : This formula modified to conditionally include terminated lines
----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  contract_tradein
    -- Description:   returns the sum of tradein values of all financial asset lines of a contract.
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION contract_tradein(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(30) := 'RETURN_CONTRACT_TRADEIN_VALUE';
    l_api_version       CONSTANT NUMBER       := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_tradeIn_value NUMBER := 0;

    l_discount_incl_terminated BOOLEAN := FALSE;

  BEGIN

       IF ( p_chr_id IS NULL ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

           -- rmunjulu 4042892
    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_discount_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;

    --IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0
      -- AND Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(0).NAME = 'TERMINATED_LINES_YN'
      -- AND  Okl_Execute_Formula_Pub.g_additional_parameters(0).value = 'Y' THEN
           -- rmunjulu 4042892
	IF l_discount_incl_terminated THEN
      SELECT NVL(SUM(kle.tradein_amount),0) INTO l_tradeIn_value
      FROM OKC_LINE_STYLES_B LS,
           okl_K_lines_full_v kle,
           okc_statuses_b sts
      WHERE LS.ID = KLE.LSE_ID
           AND LS.LTY_CODE ='FREE_FORM1'
           AND KLE.dnz_chr_iD = p_chr_id
           AND kle.sts_code = sts.code
           AND sts.ste_code NOT IN ('EXPIRED', 'CANCELLED', 'HOLD');
    ELSE
      SELECT NVL(SUM(kle.tradein_amount),0) INTO l_tradeIn_value
      FROM OKC_LINE_STYLES_B LS,
           okl_K_lines_full_v kle,
           okc_statuses_b sts
      WHERE LS.ID = KLE.LSE_ID
           AND LS.LTY_CODE ='FREE_FORM1'
           AND KLE.dnz_chr_iD = p_chr_id
           AND kle.sts_code = sts.code
           AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');
        END IF;

    RETURN l_tradeIn_value;


    EXCEPTION

        WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;


  END contract_tradein;

--Bug# 3638568 : This function modified to conditionally include terminated lines if called from pricing
----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  line_tradein
    -- Description:   returns the tradein of a financial asset line.
    -- Dependencies:
    -- Parameters: contract id and line id.
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION line_tradein(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(30) := 'RETURN_LINE_TRADEIN_VALUE';
    l_api_version       CONSTANT NUMBER       := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_tradeIn_value NUMBER := 0.0;

    CURSOR trdinval_csr( chrID NUMBER, lineID NUMBER) IS
    SELECT NVL(kle.tradein_amount,0.0) amnt,
           kle.dnz_chr_id chrId,
           kle.id lneId
      FROM OKC_LINE_STYLES_B LS,
           okl_K_lines_full_v kle,
           okc_statuses_b sts
      WHERE LS.ID = kLE.LSE_ID
           AND LS.LTY_CODE ='FREE_FORM1'
           AND kLE.dnz_chr_id = chrID
           AND kLE.ID = lineID
           AND kle.sts_code = sts.code
           AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');

    CURSOR trdinval_csr_incl_terminated( chrID NUMBER, lineID NUMBER) IS
    SELECT NVL(kle.tradein_amount,0.0) amnt,
           kle.dnz_chr_id chrId,
           kle.id lneId
      FROM OKC_LINE_STYLES_B LS,
           okl_K_lines_full_v kle,
           okc_statuses_b sts
      WHERE LS.ID = kLE.LSE_ID
           AND LS.LTY_CODE ='FREE_FORM1'
           AND kLE.dnz_chr_id = chrID
           AND kLE.ID = lineID
           AND kle.sts_code = sts.code
           AND sts.ste_code NOT IN ('EXPIRED', 'CANCELLED', 'HOLD');

   l_trdinval_rec trdinval_csr%ROWTYPE;

   l_discount_incl_terminated BOOLEAN := FALSE;

  BEGIN

    IF (( p_chr_id IS NULL ) OR (p_line_id IS NULL))THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

           -- rmunjulu 4042892
    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_discount_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;

    --IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0
          --AND Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(0).NAME = 'TERMINATED_LINES_YN'
          --AND  Okl_Execute_Formula_Pub.g_additional_parameters(0).value = 'Y' THEN

    IF  l_discount_incl_terminated THEN
                  OPEN  trdinval_csr_incl_terminated ( p_chr_id, p_line_id );
              FETCH trdinval_csr_incl_terminated INTO l_trdinval_rec;
              IF( trdinval_csr_incl_terminated%NOTFOUND ) THEN
                 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
              END IF;
              CLOSE trdinval_csr_incl_terminated;
    ELSE
          OPEN  trdinval_csr ( p_chr_id, p_line_id );
          FETCH trdinval_csr INTO l_trdinval_rec;
          IF( trdinval_csr%NOTFOUND ) THEN
             RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
          CLOSE trdinval_csr;
        END IF;

    l_tradeIn_value := l_trdinval_rec.amnt;
    RETURN l_tradeIn_value;


   EXCEPTION
        WHEN OTHERS THEN
      IF trdinval_csr_incl_terminated%ISOPEN THEN
             CLOSE trdinval_csr_incl_terminated;
          END IF;
      IF trdinval_csr%ISOPEN THEN
             CLOSE trdinval_csr;
          END IF;
            Okl_Api.SET_MESSAGE(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => G_UNEXPECTED_ERROR,
                      p_token1       => G_SQLCODE_TOKEN,
                      p_token1_value => SQLCODE,
                      p_token2       => G_SQLERRM_TOKEN,
                      p_token2_value => SQLERRM);
             RETURN NULL;

  END line_tradein;

--Bug# 3638568 : This function modified to conditionally include terminated lines if called from pricing
----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  contract_capreduction
    -- Description:   returns the sum of capital reduction of financial asset lines of a contract.
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION contract_capital_reduction(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(60) := 'RETURN_CONTRACT_CAPITAL_REDUCTION_VALUE';
    l_api_version       CONSTANT NUMBER       := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_capred_value NUMBER := 0;

     CURSOR l_lines_csr( chrId NUMBER ) IS
     SELECT kle.id
     FROM  okc_line_styles_b ls,
           okl_K_lines_full_v kle,
           okc_statuses_b sts
     WHERE ls.id = kle.lse_id
          AND ls.lty_code = 'FREE_FORM1'
          AND kle.dnz_chr_id = chrId
          AND kle.sts_code = sts.code
-- start: cklee: okl.h Sales Quote IA Authoring
          AND kle.CAPITALIZE_DOWN_PAYMENT_YN = 'Y'
-- end: cklee: okl.h Sales Quote IA Authoring
          AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');


     CURSOR l_lines_csr_incl_terminated( chrId NUMBER ) IS
     SELECT kle.id
     FROM  okc_line_styles_b ls,
           okl_K_lines_full_v kle,
           okc_statuses_b sts
     WHERE ls.id = kle.lse_id
          AND ls.lty_code = 'FREE_FORM1'
          AND kle.dnz_chr_id = chrId
          AND kle.sts_code = sts.code
-- start: cklee: okl.h Sales Quote IA Authoring
          AND kle.CAPITALIZE_DOWN_PAYMENT_YN = 'Y'
-- end: cklee: okl.h Sales Quote IA Authoring
          AND sts.ste_code NOT IN ('EXPIRED', 'CANCELLED', 'HOLD');


    l_lines_rec l_lines_csr%ROWTYPE;

    l_discount_incl_terminated BOOLEAN := FALSE;
  BEGIN

       IF ( p_chr_id IS NULL ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

           -- rmunjulu 4042892
    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_discount_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;

   -- IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0
        --  AND Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(0).NAME = 'TERMINATED_LINES_YN'
         -- AND  Okl_Execute_Formula_Pub.g_additional_parameters(0).value = 'Y' THEN
    IF l_discount_incl_terminated THEN
       FOR l_lines_rec IN l_lines_csr_incl_terminated ( p_chr_id )
       LOOP

           l_capred_value := l_capred_value + line_capital_reduction(p_chr_id, l_lines_rec.id);

       END LOOP;
    ELSE
       FOR l_lines_rec IN l_lines_csr ( p_chr_id )
       LOOP

           l_capred_value := l_capred_value + line_capital_reduction(p_chr_id, l_lines_rec.id);

       END LOOP;
    END IF;

    RETURN l_capred_value;


    EXCEPTION

        WHEN OTHERS THEN
            IF l_lines_csr_incl_terminated%ISOPEN THEN
                   CLOSE l_lines_csr_incl_terminated;
                END IF;
            IF l_lines_csr%ISOPEN THEN
                   CLOSE l_lines_csr;
                END IF;
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;

  END contract_capital_reduction;

--Bug# 3638568 : This function modified to conditionally include TERMINATED lines if called from pricing
----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  line_capreduction
    -- Description:   returns the capital reduction of a financial asset line.
    -- Dependencies:
    -- Parameters: contract id and line id
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION line_capital_reduction(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS


    l_api_name          CONSTANT VARCHAR2(60) := 'RETURN_LINE_CAPITAL_REDUCTION_VALUE';
    l_api_version       CONSTANT NUMBER       := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_capred_value NUMBER := 0;
    l_capred_percent NUMBER := 0;
        l_capred_incl_terminated BOOLEAN := FALSE;
        l_caplitalize_flag varchar2(3);

-- start: cklee: okl.h Sales Quote IA Authoring
     CURSOR l_lines_csr(p_chr_id  number,
                        p_line_id number)
          IS
      SELECT NVL(kle.capital_reduction,0) capital_reduction,
             NVL(kle.capital_reduction_percent,0) capital_reduction_percent,
             NVL(kle.CAPITALIZE_DOWN_PAYMENT_YN, 'N') CAPITALIZE_DOWN_PAYMENT_YN,
             sts.ste_code
      FROM OKC_LINE_STYLES_B LS,
           okl_K_lines_full_v kle,
           okc_statuses_b sts
      WHERE LS.ID = KLE.LSE_ID
           AND LS.LTY_CODE ='FREE_FORM1'
           AND KLE.dnz_chr_id = p_chr_id
           AND KLE.ID = p_line_id
           AND kle.sts_code = sts.code
           ;
-- end: cklee: okl.h Sales Quote IA Authoring

  BEGIN

    IF (( p_chr_id IS NULL ) OR (p_line_id IS NULL))THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

   -- IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0
       --AND Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(0).NAME = 'TERMINATED_LINES_YN'
       --AND  Okl_Execute_Formula_Pub.g_additional_parameters(0).value = 'Y' THEN
                  --l_capred_incl_terminated := TRUE;
    --END IF;

           -- rmunjulu 4042892
    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_capred_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;

    IF l_capred_incl_terminated = TRUE THEN

-- start: cklee: okl.h Sales Quote IA Authoring
      FOR this_row IN l_lines_csr(p_chr_id, p_line_id) LOOP
        IF this_row.ste_code NOT IN ('EXPIRED', 'CANCELLED', 'HOLD') AND
           this_row.CAPITALIZE_DOWN_PAYMENT_YN = 'Y' THEN
           l_capred_value := this_row.capital_reduction;
        END IF;
      END LOOP;
/*      SELECT NVL(kle.capital_reduction,0) INTO l_capred_value
      FROM OKC_LINE_STYLES_B LS,
           okl_K_lines_full_v kle,
           okc_statuses_b sts
      WHERE LS.ID = KLE.LSE_ID
           AND LS.LTY_CODE ='FREE_FORM1'
           AND KLE.dnz_chr_id = p_chr_id
           AND KLE.ID = p_line_id
           AND kle.sts_code = sts.code
           AND sts.ste_code NOT IN ('EXPIRED', 'CANCELLED', 'HOLD');
*/
-- end: cklee: okl.h Sales Quote IA Authoring
    ELSE
-- start: cklee: okl.h Sales Quote IA Authoring
      FOR this_row IN l_lines_csr(p_chr_id, p_line_id) LOOP
        IF this_row.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD') AND
           this_row.CAPITALIZE_DOWN_PAYMENT_YN = 'Y' THEN
           l_capred_value := this_row.capital_reduction;
        END IF;
      END LOOP;

/*      SELECT NVL(kle.capital_reduction,0) INTO l_capred_value
      FROM OKC_LINE_STYLES_B LS,
           okl_K_lines_full_v kle,
           okc_statuses_b sts
      WHERE LS.ID = KLE.LSE_ID
           AND LS.LTY_CODE ='FREE_FORM1'
           AND KLE.dnz_chr_id = p_chr_id
           AND KLE.ID = p_line_id
           AND kle.sts_code = sts.code
           AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');
*/
    END IF;

-- end: cklee: okl.h Sales Quote IA Authoring
    IF( l_capred_value = 0) THEN
       IF l_capred_incl_terminated = TRUE THEN
-- start: cklee: okl.h Sales Quote IA Authoring
      FOR this_row IN l_lines_csr(p_chr_id, p_line_id) LOOP
        IF this_row.ste_code NOT IN ('EXPIRED', 'CANCELLED', 'HOLD') AND
           this_row.CAPITALIZE_DOWN_PAYMENT_YN = 'Y' THEN
           l_capred_percent := this_row.capital_reduction_percent;
        END IF;
      END LOOP;

/*          SELECT NVL(kle.capital_reduction_percent,0) INTO l_capred_percent
          FROM OKC_LINE_STYLES_B LS,
               okl_K_lines_full_v kle,
               okc_statuses_b sts
          WHERE LS.ID = KLE.LSE_ID
             AND LS.LTY_CODE ='FREE_FORM1'
             AND KLE.dnz_chr_id = p_chr_id
             AND KLE.ID = p_line_id
             AND kle.sts_code = sts.code
             AND sts.ste_code NOT IN ('EXPIRED', 'CANCELLED', 'HOLD');
*/
-- end: cklee: okl.h Sales Quote IA Authoring
       ELSE
-- start: cklee: okl.h Sales Quote IA Authoring
      FOR this_row IN l_lines_csr(p_chr_id, p_line_id) LOOP
        IF this_row.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD') AND
           this_row.CAPITALIZE_DOWN_PAYMENT_YN = 'Y' THEN
           l_capred_percent := this_row.capital_reduction_percent;
        END IF;
      END LOOP;

/*          SELECT NVL(kle.capital_reduction_percent,0) INTO l_capred_percent
          FROM OKC_LINE_STYLES_B LS,
               okl_K_lines_full_v kle,
               okc_statuses_b sts
          WHERE LS.ID = KLE.LSE_ID
             AND LS.LTY_CODE ='FREE_FORM1'
             AND KLE.dnz_chr_id = p_chr_id
             AND KLE.ID = p_line_id
             AND kle.sts_code = sts.code
             AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');
*/
-- end: cklee: okl.h Sales Quote IA Authoring
       END IF;

       IF( l_capred_percent <> 0) THEN
         l_capred_value := line_oec( p_chr_id, p_line_id ) * l_capred_percent / 100.00;
       END IF;

     END IF;

     RETURN l_capred_value;


    EXCEPTION

        WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

                RETURN NULL;

  END line_capital_reduction;

--Bug# 3638568 : This function modified to conditionally include TERMINATED lines if called from pricing
----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  line_feescapitalized
    -- Description:   returns the capitalized fees of a financial asset line.
    -- Dependencies:
    -- Parameters: contract id and line id
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION line_fees_capitalized(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(60) := 'RETURN_LINE_FEES_CAPITAL_AMOUNT_VALUE';
    l_api_version       CONSTANT NUMBER       := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_fees_value NUMBER := 0;

    CURSOR l_fee_csr( kleId NUMBER) IS
    SELECT NVL(SUM(kle_cov.capital_amount),0) CapAmountLines
       FROM   OKC_LINE_STYLES_B  LSEB,
              OKC_K_ITEMS        CIM,
              OKL_K_LINES        KLE_COV,
              OKC_K_LINES_B      CLEB_COV,
              OKC_STATUSES_B     STSB
        WHERE LSEB.ID               = CLEB_COV.LSE_ID
        AND   LSEB.lty_code         = 'LINK_FEE_ASSET'
        AND   CIM.jtot_object1_code = 'OKX_COVASST'
        AND   CLEB_COV.id           =  CIM.cle_id
        AND   KLE_COV.id            =  CLEB_COV.ID
        AND   CLEB_COV.DNZ_CHR_ID   =  CIM.DNZ_CHR_ID
        AND   cim.object1_id1       =  to_char(kleId)
        AND   CLEB_COV.sts_code     =  STSB.code
        AND   STSB.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');

    CURSOR l_fee_csr_incl_terminated( kleId NUMBER) IS
    SELECT NVL(SUM(kle_cov.capital_amount),0) CapAmountLines
       FROM   OKC_LINE_STYLES_B  LSEB,
              OKC_K_ITEMS        CIM,
              OKL_K_LINES        KLE_COV,
              OKC_K_LINES_B      CLEB_COV,
              OKC_STATUSES_B     STSB
        WHERE LSEB.ID               = CLEB_COV.LSE_ID
        AND   LSEB.lty_code         = 'LINK_FEE_ASSET'
        AND   CIM.jtot_object1_code = 'OKX_COVASST'
        AND   CLEB_COV.id           =  CIM.cle_id
        AND   KLE_COV.id            =  CLEB_COV.ID
        AND   CLEB_COV.DNZ_CHR_ID   =  CIM.DNZ_CHR_ID
        AND   cim.object1_id1       =  to_char(kleId)
        AND   CLEB_COV.sts_code     =  STSB.code
        AND   STSB.ste_code NOT IN ('EXPIRED', 'CANCELLED', 'HOLD');

--Bug# 5150150 -- start
    CURSOR l_sys_source_code_csr (p_chr_id NUMBER) IS
    SELECT ID,ORIG_SYSTEM_SOURCE_CODE
    FROM OKC_K_HEADERS_B
    WHERE ID = p_chr_id;

   l_chr_id okc_k_headers_b.id%type;
   l_orig_systm_source_code okc_k_headers_b.orig_system_source_code%type;
--Bug# 5150150 -- end
   l_feeline_rec l_fee_csr%ROWTYPE;
   l_discount_incl_terminated BOOLEAN := FALSE;

  BEGIN

       IF (( p_chr_id IS NULL ) OR (p_line_id IS NULL)) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

--Bug# 5150150 -- start
       OPEN  l_sys_source_code_csr ( p_chr_id );
       FETCH l_sys_source_code_csr INTO l_chr_id, l_orig_systm_source_code;
       CLOSE l_sys_source_code_csr;

       if ((l_orig_systm_source_code is not null) and (l_orig_systm_source_code = 'OKL_RELEASE')) then
                l_fees_value := 0.0;
       else
--Bug# 5150150 -- end
           -- rmunjulu 4042892
    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_discount_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;

    --IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0
      -- AND Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(0).NAME = 'TERMINATED_LINES_YN'
       --AND  Okl_Execute_Formula_Pub.g_additional_parameters(0).value = 'Y' THEN
    IF l_discount_incl_terminated THEN
                  OPEN  l_fee_csr_incl_terminated ( p_line_id );
              FETCH l_fee_csr_incl_terminated INTO l_feeline_rec;
          IF( l_fee_csr_incl_terminated%NOTFOUND ) THEN
             l_fees_value := 0.0;
          END IF;
              CLOSE l_fee_csr_incl_terminated;
    ELSE
          OPEN  l_fee_csr( p_line_id );
          FETCH l_fee_csr INTO l_feeline_rec;
          IF( l_fee_csr%NOTFOUND ) THEN
             l_fees_value := 0.0;
          END IF;
          CLOSE l_fee_csr;
        END IF;

    l_fees_value := l_feeline_rec.CapAmountLines;

   end if;
    RETURN l_fees_value;


    EXCEPTION

        WHEN OTHERS THEN
            IF l_fee_csr_incl_terminated%ISOPEN THEN
          CLOSE l_fee_csr_incl_terminated;
        END IF;
            IF l_fee_csr%ISOPEN THEN
          CLOSE l_fee_csr;
        END IF;

                Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
        RETURN NULL;

  END line_fees_capitalized;

--Bug# 3638568 : This function modified to conditionally include TERMINATED lines if called from pricing
----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  contract_feescapitalized
    -- Description:   returns the sum of capitalized fees of all financial asset lines of a contract.
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION contract_fees_capitalized(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(60) := 'RETURN_LINE_FEES_CAPITAL_AMOUNT_VALUE';
    l_api_version       CONSTANT NUMBER       := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);


     CURSOR l_lines_csr( chrId NUMBER ) IS
     SELECT kle.id
     FROM   okc_line_styles_b ls,
            okl_K_lines_full_v kle,
            okc_statuses_b sts
     WHERE ls.id = kle.lse_id
          AND ls.lty_code = 'FREE_FORM1'
          AND kle.dnz_chr_id = chrId
          AND kle.sts_code = sts.code
          AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');

     CURSOR l_lines_csr_incl_terminated( chrId NUMBER ) IS
     SELECT kle.id
     FROM   okc_line_styles_b ls,
            okl_K_lines_full_v kle,
            okc_statuses_b sts
     WHERE ls.id = kle.lse_id
          AND ls.lty_code = 'FREE_FORM1'
          AND kle.dnz_chr_id = chrId
          AND kle.sts_code = sts.code
          AND sts.ste_code NOT IN ('EXPIRED', 'CANCELLED', 'HOLD');



    l_lines_rec l_lines_csr%ROWTYPE;

    l_fees_value NUMBER := 0;

    l_discount_incl_terminated BOOLEAN := FALSE;

  BEGIN

       IF ( p_chr_id IS NULL ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

           -- rmunjulu 4042892
    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_discount_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;

    --IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0
      -- AND Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(0).NAME = 'TERMINATED_LINES_YN'
       --AND  Okl_Execute_Formula_Pub.g_additional_parameters(0).value = 'Y' THEN
    IF l_discount_incl_terminated THEN
           FOR l_lines_rec IN l_lines_csr_incl_terminated ( p_chr_id )
       LOOP

           l_fees_value := l_fees_value + line_fees_capitalized(p_chr_id, l_lines_rec.id);

       END LOOP;
    ELSE
       FOR l_lines_rec IN l_lines_csr ( p_chr_id )
       LOOP

           l_fees_value := l_fees_value + line_fees_capitalized(p_chr_id, l_lines_rec.id);

       END LOOP;
    END IF;

    RETURN l_fees_value;


    EXCEPTION

        WHEN OTHERS THEN
           IF l_lines_csr_incl_terminated%ISOPEN THEN
             CLOSE l_lines_csr_incl_terminated;
           END IF;
           IF l_lines_csr%ISOPEN THEN
             CLOSE l_lines_csr;
           END IF;
       Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);
       RETURN NULL;

  END contract_fees_capitalized;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  line_servicecapitalized
    -- Description:   returns the capitalized service fees of a financial asset line.
    -- Dependencies:
    -- Parameters: contract id and line id
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION line_service_capitalized(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_name		CONSTANT VARCHAR2(60) := 'RETURN_LINE_SVC_CAP_AMNT_VALUE';
    l_api_version	CONSTANT NUMBER	      := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_srvcs_value NUMBER := 0;


    CURSOR l_srvcline_csr ( kleId NUMBER ) IS
    SELECT NVL(SUM(kle.capital_amount),0) CapAmountSubLines
    FROM OKC_LINE_STYLES_B LS,
         okc_k_items cim,
	 okl_K_lines_full_v kle,
	 okc_statuses_b sts
    WHERE LS.ID = KLE.LSE_ID
          AND ls.lty_code = 'LINK_SERV_ASSET'
          AND cim.jtot_object1_code = 'OKX_COVASST'
          AND kle.id = cim.cle_id
          AND cim.object1_id1 = to_char(kleId)
	  AND kle.sts_code = sts.code
	  AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');

    CURSOR srvc_strm_type_csr ( kleid NUMBER ) IS
    SELECT sty.capitalize_yn,
           sty.name
    FROM okl_strm_type_v sty,
         okc_k_items cim,
         okc_line_styles_b ls,
	 okl_K_lines_full_v kle,
	 okc_statuses_b sts
    WHERE cim.cle_id = kle.id
         AND ls.id = kle.lse_id
         AND ls.lty_code = 'SOLD_SERVICE'
         AND cim.object1_id1 = sty.id
         AND cim.object1_id2 = '#'
         AND kle.id = kleid
	 AND kle.sts_code = sts.code
	 AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');


   l_srvcline_rec l_srvcline_csr%ROWTYPE;
   l_srvcstrm_rec srvc_strm_type_csr%ROWTYPE;

  BEGIN

       IF (( p_chr_id IS NULL ) OR (p_line_id IS NULL))THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

      OPEN  srvc_strm_type_csr( p_line_id );
      FETCH srvc_strm_type_csr INTO l_srvcstrm_rec;
      IF( srvc_strm_type_csr%NOTFOUND ) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;
      CLOSE srvc_strm_type_csr;

      IF( UPPER(l_srvcstrm_rec.capitalize_YN) = 'N' ) THEN
          RETURN 0.0;
      END IF;

      OPEN  l_srvcline_csr( p_line_id );
      FETCH l_srvcline_csr INTO l_srvcline_rec;
      IF( l_srvcline_csr%NOTFOUND ) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;
      CLOSE l_srvcline_csr;

      l_srvcs_value := l_srvcline_rec.CapAmountSubLines;

      RETURN l_srvcs_value;


    EXCEPTION

	WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;


  END line_service_capitalized;

------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : contract_total_adjustments
-- Description     : Sum of all approved requests for specfiic contract where type = prefunding
--                   and amount is negative
-- Business Rules  :
-- Parameters      :IN: p_contract_id, OUT: amount
-- Version         : 1.0
-- History         : 20-MAY-02 ChenKuang.Lee@oracle.com -- Created
--
-- End of comments
------------------------------------------------------------------------------
FUNCTION contract_total_adjustments(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
) RETURN NUMBER
IS
  l_amount NUMBER := 0;
  -- sjalasut, modified the cursor to have khr_id referred from okl_txl_ap_inv_lns_all_b
  -- changes made as part of OKLR12B project.
--start:|           21-Sep-07 cklee Bug: 6438934                                     |
/*
  CURSOR C (p_contract_id  NUMBER)
  IS
  SELECT NVL(SUM(A.amount),0)
  FROM okl_trx_ap_invoices_b A
      ,okl_txl_ap_inv_lns_all_b B
  WHERE A.id = B.tap_id
    AND B.khr_id = p_contract_id
    AND A.funding_type_code = 'PREFUNDING'
    AND A.trx_status_code IN ('APPROVED', 'PROCESSED')
    AND A.amount < 0;
*/
--end:|           21-Sep-07 cklee Bug: 6438934                                     |

BEGIN

--start:|           21-Sep-07 cklee Bug: 6438934                                     |
/*
  OPEN C (p_contract_id);
  FETCH C INTO l_amount;
  CLOSE C;
*/
  l_amount := okl_funding_pvt.get_chr_funded_adjs(p_contract_id);
--end:|           21-Sep-07 cklee Bug: 6438934                                     |

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;

------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : contract_amount_prefunded
-- Description     : Sum of all approved requests for specfiic contract where type = prefunding
-- Business Rules  :
-- Parameters      :IN: p_contract_id, OUT: amount
-- Version         : 1.0
-- History         :13-JAN-02 ChenKuang.Lee@oracle.com -- Created
--                  22-Jan-07 sjalasut modified cursor c to have khr_id referred
--                  from okl_txl_Ap_inv_lns_all_b
--
-- End of comments
------------------------------------------------------------------------------
FUNCTION contract_amount_prefunded(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  -- sjalasut, modified the cursor to include khr_id from the okl_Txl_ap_inv_lns_all_b
  -- changes made as part of OKLR12B disbursements project
--start:|           21-Sep-07 cklee Bug: 6438934                                     |
/*
  CURSOR C (p_contract_id  NUMBER)
  IS
  SELECT NVL(SUM(A.amount),0)
  FROM okl_trx_ap_invoices_b A
      ,okl_Txl_ap_inv_lns_all_b B
  WHERE A.id = B.tap_id
  AND B.khr_id = p_contract_id
  AND A.funding_type_code = 'PREFUNDING'
  AND A.trx_status_code IN ('APPROVED', 'PROCESSED')
  AND A.amount > 0;
*/
--end:|           21-Sep-07 cklee Bug: 6438934                                     |

BEGIN

--start:|           21-Sep-07 cklee Bug: 6438934                                     |
/*
  OPEN C (p_contract_id);
  FETCH C INTO l_amount;
  CLOSE C;*/
  l_amount := okl_funding_pvt.get_amount_prefunded(p_contract_id);
--end:|           21-Sep-07 cklee Bug: 6438934                                     |

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;
------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : contract_total_funded
-- Description     : Sum of all approved requests for specific contract
-- Business Rules  :
-- Parameters      :IN: p_contract_id, OUT: amount
-- Version         : 1.0
-- History         :13-JAN-02 ChenKuang.Lee@oracle.com -- Created
--                  22-Jan-07 sjalasut modified cursor c to have khr_id referred
--                  from okl_txl_Ap_inv_lns_all_b
--
-- End of comments
------------------------------------------------------------------------------
FUNCTION contract_total_funded(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  -- sjalasut, modified the cursor to include khr_id from the okl_Txl_ap_inv_lns_all_b
  -- changes made as part of OKLR12B disbursements project
--start:|           21-Sep-07 cklee Bug: 6438934                                     |
/*
  CURSOR C (p_contract_id  NUMBER)
  IS
  SELECT NVL(SUM(A.amount),0)
  FROM okl_trx_ap_invoices_b A
      ,okl_txl_ap_inv_lns_all_b B
  WHERE A.id = B.TAP_ID
  AND A.khr_id = p_contract_id
  AND A.funding_type_code NOT IN ('SUPPLIER_RETENTION', 'MANUAL_DISB')
  AND A.trx_status_code IN ('APPROVED', 'PROCESSED');
*/
--end:|           21-Sep-07 cklee Bug: 6438934                                     |

BEGIN

--start:|           21-Sep-07 cklee Bug: 6438934                                     |
/*  OPEN C (p_contract_id);
  FETCH C INTO l_amount;
  CLOSE C;*/
  l_amount := okl_funding_pvt.get_total_funded(p_contract_id);
--end:|           21-Sep-07 cklee Bug: 6438934                                     |

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;
------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : contract_total_debits
-- Description     : Sum of all approved requests for specific contract where amount is negative (A/P debits)
-- Business Rules  :
-- Parameters      :IN: p_contract_id, OUT: amount
-- Version         : 1.0
-- History         :13-JAN-02 ChenKuang.Lee@oracle.com -- Created
--                  22-Jan-07 sjalasut modified cursor c to have khr_id referred
--                  from okl_txl_Ap_inv_lns_all_b
--
-- End of comments
------------------------------------------------------------------------------
FUNCTION contract_total_debits(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  -- sjalasut, modified the cursor to include khr_id from the okl_Txl_ap_inv_lns_all_b
  -- changes made as part of OKLR12B disbursements project
--start:|           21-Sep-07 cklee Bug: 6438934                                     |
/*
  CURSOR C (p_contract_id  NUMBER)
  IS
  SELECT NVL(SUM(B.amount),0)
  FROM okl_trx_ap_invoices_b A,
       okl_txl_ap_inv_lns_all_b B
  WHERE A.id = B.tap_id
  AND B.khr_id = p_contract_id
  AND A.trx_status_code IN ('APPROVED', 'PROCESSED')
  AND A.funding_type_code = 'SUPPLIER_RETENTION';
*/
--end:|           21-Sep-07 cklee Bug: 6438934                                     |
BEGIN

--start:|           21-Sep-07 cklee Bug: 6438934                                     |
/*
  OPEN C (p_contract_id);
  FETCH C INTO l_amount;
  CLOSE C;*/
  l_amount := okl_funding_pvt.get_total_retention(p_contract_id);
--end:|           21-Sep-07 cklee Bug: 6438934                                     |

  RETURN l_amount;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;
-----------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : creditline_total_limit
-- Description     : Sum of all credit limit (contract line) for specfiic
--                   contract entity scs_code = 'CREDITLINE_CONTRACT'
-- Business Rules  :
-- Parameters      :IN: p_contract_id, OUT: amount
-- Version         : 1.0
-- History         :13-JAN-02 ChenKuang.Lee@oracle.com -- Created
--
-- End of comments
------------------------------------------------------------------------------
 FUNCTION creditline_total_limit(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;
  l_amount_add NUMBER := 0;
  l_amount_new NUMBER := 0;
  l_amount_reduce NUMBER := 0;

BEGIN

  l_amount_add := NVL(creditline_total_addition(p_contract_id),0);
  l_amount_new := NVL(creditline_total_new_limit(p_contract_id),0);
  l_amount_reduce := NVL(creditline_total_reduction(p_contract_id),0);

  l_amount := l_amount_new + l_amount_add - l_amount_reduce;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;
------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : creditline_total_remaining
-- Description     : Sum of all credit limit (contract line) for specfiic contract
--                   scs_code = 'CREDITLINE_CONTRACT' and substract from Funding total
-- Business Rules  :
-- Parameters      :IN: p_contract_id, OUT: amount
-- Version         : 1.0
-- History         :13-JAN-02 ChenKuang.Lee@oracle.com -- Created
--
-- End of comments
------------------------------------------------------------------------------
 FUNCTION creditline_total_remaining(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;
--  l_amount_funded NUMBER := 0;
--  l_amount_limit NUMBER := 0;
--  l_amount_remain NUMBER := 0;

  x_return_status	 VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  l_api_version      NUMBER	:= 1.0;
  x_msg_count		 NUMBER;
  x_msg_data	        VARCHAR2(4000);
  l_init_msg_list    VARCHAR2(10) := OKL_API.G_FALSE;

  x_value NUMBER := 0;

BEGIN

/*
  --l_amount_funded := nvl(creditline_total_funded(p_contract_id),0);
  l_amount_limit := NVL(creditline_total_limit(p_contract_id),0);

--  l_amount_remain := OKL_PAY_INVOICES_DISB_PVT.credit_check
  l_amount_remain := OKL_BPD_CREDIT_CHECK_PVT.credit_check -- cklee 08/28/03
                 (p_api_version    => l_api_version
                  ,p_init_msg_list => l_init_msg_list
                  ,x_return_status => x_return_status
                  ,x_msg_count     => x_msg_count
                  ,x_msg_data      => x_msg_data
                  ,p_creditline_id => p_contract_id
                  ,p_credit_max    => l_amount_limit);

  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    --RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    l_amount_remain := 0;
  ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
    --RAISE OKL_API.G_EXCEPTION_ERROR;
    l_amount_remain := 0;
  END IF;

  l_amount := l_amount_remain;

*/

    --------------------------------------------------
    -- Credit limt Remaining check
    --------------------------------------------------
  OKL_EXECUTE_FORMULA_PUB.EXECUTE(
      p_api_version   => l_api_version,
      p_init_msg_list => l_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_formula_name  => 'CREDIT_CHECK',
      p_contract_id   => p_contract_id,
      x_value         => x_value);

  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      --RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      x_value := 0;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      --RAISE OKL_API.G_EXCEPTION_ERROR;
      x_value := 0;
  END IF;

  l_amount := x_value;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;
------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : creditline_total_new_limit
-- Description     : Sum of all credit new limit (contract line) for specfiic contract
--                   scs_code = 'CREDITLINE_CONTRACT'
-- Business Rules  :
-- Parameters      :IN: p_contract_id, OUT: amount
-- Version         : 1.0
-- History         :13-JAN-02 ChenKuang.Lee@oracle.com -- Created
--
-- End of comments
------------------------------------------------------------------------------
 FUNCTION creditline_total_new_limit(
 p_contract_id                   IN NUMBER
 --,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  CURSOR C (p_contract_id  NUMBER)
  IS
  SELECT NVL(SUM(A.amount),0)
  FROM OKL_K_LINES_FULL_V A
  WHERE A.dnz_chr_id = p_contract_id
  AND   A.credit_nature = 'NEW'
  AND   NVL(TRUNC(A.start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE) -- fixed trunc issues
  ;

BEGIN

  OPEN C (p_contract_id);
  FETCH C INTO l_amount;
  CLOSE C;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;
------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : creditline_total_addition
-- Description     : Sum of all credit addition (contract line) for specfiic contract
--                   scs_code = 'CREDITLINE_CONTRACT'
-- Business Rules  :
-- Parameters      :IN: p_contract_id, OUT: amount
-- Version         : 1.0
-- History         :13-JAN-02 ChenKuang.Lee@oracle.com -- Created
--
-- End of comments
------------------------------------------------------------------------------
 FUNCTION creditline_total_addition(
 p_contract_id                   IN NUMBER
 --,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  CURSOR C (p_contract_id  NUMBER)
  IS
  SELECT NVL(SUM(A.amount),0)
  FROM OKL_K_LINES_FULL_V A
  WHERE A.dnz_chr_id = p_contract_id
  AND   A.credit_nature = 'ADD'
  AND   NVL(TRUNC(A.start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE) -- fixed trunc issues
  ;

BEGIN

  OPEN C (p_contract_id);
  FETCH C INTO l_amount;
  CLOSE C;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;
------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : creditline_total_reduction
-- Description     : Sum of all credit addition (contract line) for specfiic contract
--                   scs_code = 'CREDITLINE_CONTRACT'
-- Business Rules  :
-- Parameters      :IN: p_contract_id, OUT: amount
-- Version         : 1.0
-- History         :13-JAN-02 ChenKuang.Lee@oracle.com -- Created
--
-- End of comments
------------------------------------------------------------------------------
 FUNCTION creditline_total_reduction(
 p_contract_id                   IN NUMBER
 --,p_contract_line_id             IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  CURSOR C (p_contract_id  NUMBER)
  IS
  SELECT NVL(SUM(A.amount),0)
  FROM OKL_K_LINES_FULL_V A
  WHERE A.dnz_chr_id = p_contract_id
  AND   A.credit_nature = 'REDUCE'
  AND   NVL(TRUNC(A.start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE) -- fixed trunc issues
  ;

BEGIN

  OPEN C (p_contract_id);
  FETCH C INTO l_amount;
  CLOSE C;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;

 /*FUNCTION line_capitalcost(
            p_chr_id           IN  NUMBER,
            p_line_id          IN  NUMBER,
            p_capred         IN  NUMBER,
            p_capred_per         IN  NUMBER,
            p_trd_amnt         IN  NUMBER) RETURN NUMBER  IS

    l_api_name		CONSTANT VARCHAR2(60) := 'RETURN_LINE_CAP_AMNT_VALUE';
    l_api_version	CONSTANT NUMBER	      := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_capamnt_value NUMBER := 0;
    l_oec_value NUMBER := 0;
    l_oec           NUMBER;
    l_tradeIn       NUMBER;
    l_capred        NUMBER;
    l_feecap        NUMBER;
    l_servc         NUMBER;


  BEGIN

      IF ( ( p_chr_id IS NULL ) OR ( p_line_id IS NULL ) ) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      l_oec_value := line_oec( p_chr_id, p_line_id);
      IF (  l_oec_value IS NULL  ) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      l_capred := p_capred;
      IF(( p_capred IS NULL ) OR ( p_capred = 0)) THEN
          IF (( p_capred_per IS NULL) OR ( p_capred_per = 0)) THEN
              l_capred := 0.0;
          ELSE
              l_capred := ( l_oec_value * p_capred_per ) / 100.00;
          END IF;
      END IF;

      IF (p_trd_amnt IS NULL) THEN
          l_tradeIn := 0.0;
      ELSE
          l_tradeIn := p_trd_amnt;
      END IF;

      l_capamnt_value := l_oec_value - l_capred - l_tradeIn;

      RETURN l_capamnt_value;

    EXCEPTION
	WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;


  END line_capitalcost;

*/

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By     : Shri Iyer
    -- Function Name  : CONTRACT_DAYS_TO_ACCRUE
    -- Description    : This function returns the number of days to accrue
    -- Dependencies   : None
    -- Parameters     : contract id, contract line id
    -- Version        : 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------

FUNCTION CONTRACT_DAYS_TO_ACCRUE(p_khr_id IN NUMBER, p_kle_id IN NUMBER) RETURN NUMBER IS

    l_days_to_accrue     NUMBER;
    l_last_int_calc_date DATE;
    l_period_end_date    DATE;
    l_period_start_date  DATE;
    l_days_in_month      VARCHAR2(100);
    l_contract_number    VARCHAR2(2000);
    l_days_in_year       VARCHAR2(100);
    l_advance_arrears    VARCHAR2(1);
    l_return_status      VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- Fetch contract days in a month
    CURSOR days_in_month IS
    SELECT days_in_a_month_code
    FROM OKL_K_RATE_PARAMS
    WHERE khr_id = p_khr_id
	AND parameter_type_code = 'ACTUAL'
    AND effective_to_date IS NULL;

    -- cursor to get the contract number
    CURSOR contract_num_csr IS
    SELECT  contract_number
    FROM OKC_K_HEADERS_B
    WHERE id = p_khr_id;

    -- Fetch contract days in a year
    CURSOR days_in_year IS
    SELECT days_in_a_year_code
    FROM OKL_K_RATE_PARAMS
    WHERE khr_id = p_khr_id
	AND parameter_type_code = 'ACTUAL'
    AND effective_to_date IS NULL;

    CURSOR adv_arr_csr IS
    SELECT
    rulb2.RULE_INFORMATION10 arrears_yn
    FROM   okc_k_lines_b     cleb,
           okc_rule_groups_b rgpb,
           okc_rules_b       rulb,
           okc_rules_b       rulb2,
           okl_strm_type_b   styb
    WHERE  rgpb.chr_id     IS NULL
    AND    rgpb.dnz_chr_id = cleb.dnz_chr_id
    AND    rgpb.cle_id     = cleb.id
    AND    cleb.dnz_chr_id = p_khr_id
    AND    rgpb.rgd_code   = 'LALEVL'
    AND    rulb.rgp_id     = rgpb.id
    AND    rulb.rule_information_category  = 'LASLH'
    AND    TO_CHAR(styb.id)                = rulb.object1_id1
    AND    rulb2.object2_id1                = TO_CHAR(rulb.id)
    AND    rulb2.rgp_id                    = rgpb.id
    AND    rulb2.rule_information_category = 'LASLL';

  BEGIN
    --Validate additional parameters availability
    IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
      FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
	  LOOP
        IF Okl_Execute_Formula_Pub.g_additional_parameters(i).name = 'p_last_int_calc_date' THEN
          l_last_int_calc_date := TO_DATE(Okl_Execute_Formula_Pub.g_additional_parameters(i).value, 'MM/DD/YYYY');
        ELSIF Okl_Execute_Formula_Pub.g_additional_parameters(i).name = 'p_period_end_date' THEN
          l_period_end_date := TO_DATE(Okl_Execute_Formula_Pub.g_additional_parameters(i).value, 'MM/DD/YYYY');
        END IF;
      END LOOP;
	ELSE
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_ADD_PARAMS');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    -- Validate parameters
    IF l_period_end_date IS NULL THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_PERD_END_DATE');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    IF l_last_int_calc_date IS NULL THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_INT_CALC_DATE');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    --Bug 5081876. Adding a day to last int calc date.
    --Bug 5162929. Undoing changes made for bug 5081876. One day is being added in accrual program
    --l_last_int_calc_date := l_last_int_calc_date + 1;

    --Bug 5046184. ***Additional Code START***
    FOR y in contract_num_csr
    LOOP
      l_contract_number := y.contract_number;
    END LOOP;

    IF l_contract_number IS NULL THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR x IN days_in_month
    LOOP
      l_days_in_month := x.days_in_a_month_code;
    END LOOP;

    IF l_days_in_month IS NULL THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_DAYSIN_MTH',
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value => l_contract_number);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    FOR z IN days_in_year
    LOOP
      l_days_in_year := z.days_in_a_year_code;
    END LOOP;

    IF l_days_in_year IS NULL THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_DAYSIN_YR',
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value => l_contract_number);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    FOR i in adv_arr_csr
    LOOP
      l_advance_arrears := NVL(i.arrears_yn, 'N');
    END LOOP;

    l_days_to_accrue := okl_pricing_utils_pvt.get_day_count
                         (l_days_in_month,
                          l_days_in_year,
                          l_last_int_calc_date,
                          l_period_end_date,
                          l_advance_arrears,
                          l_return_status);

    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_GET_DAY_CNT_ERROR');

      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug 5046184. ***Additional Code START***

    --Bug 5046184. Commenting below calculation
    --l_days_to_accrue := l_period_end_date - l_last_int_calc_date;

    RETURN l_days_to_accrue;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      RETURN NULL;

	WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
      RETURN NULL;

  END CONTRACT_DAYS_TO_ACCRUE;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By     : Shri Iyer
    -- Function Name  : CONTRACT_DAYS_IN_YEAR
    -- Description    : This function returns the number of days in a year
    -- Dependencies   : None
    -- Parameters     : contract id, contract line id
    -- Version        : 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------

  FUNCTION CONTRACT_DAYS_IN_YEAR(p_khr_id IN NUMBER, p_kle_id IN NUMBER) RETURN NUMBER IS
    l_days NUMBER;
    l_lookup_code VARCHAR2(2000);
    l_accrual_date DATE;
	l_year NUMBER;
    l_contract_number VARCHAR2(2000);

    -- cursor to get the contract number
    CURSOR contract_num_csr (p_ctr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
    SELECT  contract_number
    FROM OKC_K_HEADERS_B
    WHERE id = p_ctr_id;

--     BUG 4730646. Changing cursor.
--     CURSOR lookup_csr(p_ctr_id NUMBER) IS
--     SELECT rule_information1
--     FROM okc_rules_b okc
--     WHERE okc.dnz_chr_id = p_ctr_id
--     AND okc.rule_information_category = 'LAICLC';

    -- Fetch contract days in a year
    CURSOR lookup_csr(p_ctr_id NUMBER) IS
    SELECT days_in_a_year_code
    FROM OKL_K_RATE_PARAMS
    WHERE khr_id = p_ctr_id
	AND parameter_type_code = 'ACTUAL'
    AND effective_to_date IS NULL;

  BEGIN
    OPEN contract_num_csr(p_khr_id);
    FETCH contract_num_csr INTO l_contract_number;
    IF contract_num_csr%NOTFOUND THEN
      CLOSE contract_num_csr;
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
    CLOSE contract_num_csr;

    OPEN lookup_csr(p_khr_id);
	FETCH lookup_csr INTO l_lookup_code;
    CLOSE lookup_csr;

    IF l_lookup_code IS NULL THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_DAYSIN_YR',
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value => l_contract_number);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    IF l_lookup_code = 'ACTUAL' THEN
      IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
        FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
	    LOOP
          IF Okl_Execute_Formula_Pub.g_additional_parameters(i).name = 'p_accrual_date' THEN
            l_accrual_date := TO_DATE(Okl_Execute_Formula_Pub.g_additional_parameters(i).value, 'MM/DD/YYYY');
	      END IF;
        END LOOP;
	  ELSE
        Okl_Api.Set_Message(p_app_name     => g_app_name,


                            p_msg_name     => 'OKL_AGN_FE_ADD_PARAMS');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
	  END IF;

      IF l_accrual_date IS NULL THEN
        Okl_Api.Set_Message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_FE_ACCRUAL_DATE');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
	  END IF;


	  l_year := TO_NUMBER(TO_CHAR(l_accrual_date, 'RRRR'));

	  IF MOD(l_year,4) = 0 THEN
	    l_days := 366;
	  ELSE
	    l_days := 365;
	  END IF;
	ELSE
	  l_days := TO_NUMBER(l_lookup_code);
	END IF;

    RETURN l_days;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      RETURN NULL;

	WHEN OTHERS THEN
      IF lookup_csr%ISOPEN THEN
        CLOSE lookup_csr;
      END IF;
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;

  END CONTRACT_DAYS_IN_YEAR;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By     : Shri Iyer
    -- Function Name  : CONTRACT_INTEREST_RATE
    -- Description    : This function returns the rate of interest on the given date or closest to that date
    -- Dependencies   : None
    -- Parameters     : contract id, contract line id
    -- Version        : 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------

  FUNCTION CONTRACT_INTEREST_RATE(p_khr_id IN NUMBER, p_kle_id IN NUMBER) RETURN NUMBER IS
    l_accrual_date DATE;
    l_interest_rate NUMBER;
    l_adder_rate NUMBER;
    l_total_rate NUMBER;
    l_contract_number VARCHAR2(2000);

    -- cursor to get the contract number
    CURSOR contract_num_csr (p_ctr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
    SELECT  contract_number
    FROM OKC_K_HEADERS_B
    WHERE id = p_ctr_id;


--     Bug 4737551. Commenting below cursor and writing new select statement. SGIYER.
--     CURSOR interest_rate_csr(p_ctr_id NUMBER, p_accrual_date DATE) IS
--     SELECT idv.value
--     FROM OKC_RULES_B rule,
--          OKL_INDEX_VALUES idv,
--          OKL_INDICES idx
--     WHERE rule.rule_information_category = 'LAIVAR'
--       AND rule.dnz_chr_id = p_ctr_id
--       AND TO_NUMBER(rule.rule_information2) = idx.id
--       AND idx.ID   = idv.idx_id
--       AND idv.datetime_valid = (SELECT MAX(idv.datetime_valid)
--                              FROM OKL_INDEX_VALUES idv ,
--                                   OKL_INDICES idx,
--                                   OKC_RULES_B rules
--                              WHERE rules.rule_information_category = 'LAIVAR'
--                              AND rules.dnz_chr_id = p_ctr_id
--                              AND rules.rule_information2 = idx.id
--                              AND idx.id =  idv.idx_id
--                              AND   idv.datetime_valid <= p_accrual_date);

    -- cursor to get interest rate
    CURSOR interest_rate_csr(p_ctr_id NUMBER, p_accrual_date DATE) IS
    SELECT idv.value
    FROM OKL_K_RATE_PARAMS okl,
         OKL_INDEX_VALUES idv,
         OKL_INDICES idx
    WHERE okl.khr_id = p_ctr_id
      AND okl.parameter_type_code = 'ACTUAL'
      AND okl.effective_to_date IS NULL
      AND okl.interest_index_id = idx.id
      AND idx.ID   = idv.idx_id
      AND idv.datetime_valid = (SELECT MAX(idv.datetime_valid)
                             FROM OKL_INDEX_VALUES idv ,
                                  OKL_INDICES idx,
                                  OKL_K_RATE_PARAMS rate
                             WHERE rate.khr_id = p_ctr_id
                             AND rate.parameter_type_code = 'ACTUAL'
                             AND rate.effective_to_date IS NULL
                             AND rate.interest_index_id = idx.id
                             AND idx.id =  idv.idx_id
                             AND idv.datetime_valid <= p_accrual_date);

    -- Bug# 2920174
    -- cursor to get adder rate
--     Bug 4737551. Commenting below cursor and writing new select statement. SGIYER.
--     CURSOR adder_rate_csr(p_ctr_id NUMBER) IS
--     SELECT TO_NUMBER(rule_information4)
--     FROM OKC_RULES_B
--     WHERE rule_information_category = 'LAIVAR'
--     AND dnz_chr_id = p_ctr_id;

    -- cursor to get adder rate
    -- Bug 4737551.
     CURSOR adder_rate_csr(p_ctr_id NUMBER) IS
     SELECT adder_rate
     FROM OKL_K_RATE_PARAMS
     WHERE khr_id = p_ctr_id
     AND parameter_type_code = 'ACTUAL'
     AND effective_to_date IS NULL;

  BEGIN

	OPEN contract_num_csr(p_khr_id);
    FETCH contract_num_csr INTO l_contract_number;
    IF contract_num_csr%NOTFOUND THEN
      CLOSE contract_num_csr;
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
    CLOSE contract_num_csr;

    IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
      FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
	  LOOP
  	  IF Okl_Execute_Formula_Pub.g_additional_parameters(i).name = 'p_accrual_date' THEN
        l_accrual_date := TO_DATE(Okl_Execute_Formula_Pub.g_additional_parameters(i).value, 'MM/DD/YYYY');
	  END IF;
      END LOOP;
	ELSE
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_ADD_PARAMS');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    IF l_accrual_date IS NULL THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_ACCRUAL_DATE');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

	OPEN interest_rate_csr(p_khr_id, l_accrual_date);
	FETCH interest_rate_csr INTO l_interest_rate;
    IF interest_rate_csr %NOTFOUND THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_INT_RATE',
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value => l_contract_number);
      CLOSE interest_rate_csr;
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;
	CLOSE interest_rate_csr;

	OPEN adder_rate_csr(p_khr_id);
	FETCH adder_rate_csr INTO l_adder_rate;
    IF adder_rate_csr %NOTFOUND THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_ADDER_RATE',
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value => l_contract_number);
      CLOSE interest_rate_csr;
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;
	CLOSE adder_rate_csr;

    -- Bug# 2920174
    -- get adder rate, add to interest rate and return total.
    l_total_rate := (l_interest_rate + l_adder_rate)/100;

    RETURN l_total_rate;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      RETURN NULL;

	WHEN OTHERS THEN
      IF interest_rate_csr%ISOPEN THEN
	    CLOSE interest_rate_csr;
      END IF;

      IF adder_rate_csr%ISOPEN THEN
	    CLOSE adder_rate_csr;
      END IF;

      IF contract_num_csr%ISOPEN THEN
	    CLOSE contract_num_csr;
      END IF;

      Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
      RETURN NULL;

  END CONTRACT_INTEREST_RATE;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By     : Shri Iyer
    -- Function Name  : CONTRACT_PRINCIPAL_BALANCE
    -- Description    : This function returns the principal balance for a contract as of that date
    -- Dependencies   : None
    -- Parameters     : contract id, contract line id
    -- Version        : 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------

  FUNCTION CONTRACT_PRINCIPAL_BALANCE(p_khr_id IN NUMBER, p_kle_id IN NUMBER) RETURN NUMBER IS

    l_period_start_date   DATE;
    l_period_end_date     DATE;
    l_principal_bal       NUMBER;
    l_contract_number     VARCHAR2(2000);
    l_last_int_calc_date  DATE;
    l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_kle_id              NUMBER;
--  Bug 5055714.
--  l_prin_bal_id         NUMBER;

    -- cursor to get the contract number
    CURSOR contract_num_csr IS
    SELECT  contract_number
    FROM OKC_K_HEADERS_B
    WHERE id = p_khr_id;

-- Bug 5055714. Commenting below derivation. Using utility provided instead.
-- 	CURSOR principal_bal_csr(p_ctr_id NUMBER, p_start_date DATE, p_end_date DATE, p_prin_bal_id NUMBER) IS
--     SELECT SUM(ste.amount)
--       FROM OKL_STRM_TYPE_B sty,
--            OKL_STREAMS stm,
--            OKL_STRM_ELEMENTS ste
--         WHERE stm.khr_id = p_ctr_id
--           AND stm.active_yn = 'Y'
--           AND stm.say_code = 'CURR'
--           AND sty.id = p_prin_bal_id
--           AND stm.sty_id = sty.id
--           AND ste.stm_id = stm.id
--           AND ste.stream_element_date BETWEEN p_start_date AND p_end_date;

-- cursor for retrieveing earlier principal balance amount if principal balance
-- for given period is not found
-- 	CURSOR prior_prin_bal_csr(p_ctr_id NUMBER, p_start_date DATE, p_prin_bal_id NUMBER) IS
--     SELECT SUM(ste.amount)
--     FROM OKL_STRM_TYPE_B sty,
--          OKL_STREAMS stm,
--          OKL_STRM_ELEMENTS ste
--     WHERE stm.khr_id = p_ctr_id
--     AND stm.active_yn = 'Y'
--     AND stm.say_code = 'CURR'
--     AND sty.id = p_prin_bal_id
--     AND stm.sty_id = sty.id
--     AND ste.stm_id = stm.id
--     AND ste.stream_element_date = (SELECT MAX(stream_element_date)
-- 		                           FROM OKL_STRM_TYPE_B sty,
--                                         OKL_STREAMS stm,
--                                         OKL_STRM_ELEMENTS ste
--                                    WHERE stm.khr_id = p_ctr_id
--                                    AND stm.active_yn = 'Y'
-- 								   AND stm.say_code = 'CURR'
--                                    AND sty.id = p_prin_bal_id
--                                    AND stm.sty_id = sty.id
--                                    AND ste.stm_id = stm.id
--                                    AND stream_element_date < p_start_date);

  BEGIN

	FOR i IN contract_num_csr
    LOOP
      l_contract_number := i.contract_number;
    END LOOP;

    IF l_contract_number IS NULL THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
      FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
	  LOOP
--      Bug 5055714. Commenting below. Need Last int calc date
-- 	    IF Okl_Execute_Formula_Pub.g_additional_parameters(i).name = 'p_period_start_date' THEN
--           l_period_start_date := TO_DATE(Okl_Execute_Formula_Pub.g_additional_parameters(i).value, 'MM/DD/YYYY');
-- 	    ELSIF Okl_Execute_Formula_Pub.g_additional_parameters(i).name = 'p_period_end_date' THEN
--           l_period_end_date := TO_DATE(Okl_Execute_Formula_Pub.g_additional_parameters(i).value, 'MM/DD/YYYY');
--         END IF;
        IF Okl_Execute_Formula_Pub.g_additional_parameters(i).name = 'p_last_int_calc_date' THEN
          l_last_int_calc_date := TO_DATE(Okl_Execute_Formula_Pub.g_additional_parameters(i).value, 'MM/DD/YYYY');
        END IF;
      END LOOP;
	ELSE
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_ADD_PARAMS');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    IF l_last_int_calc_date IS NULL THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_INT_CALC_DATE');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

-- Bug 5055714.No validation needed.
--     IF l_period_end_date IS NULL THEN
--       Okl_Api.Set_Message(p_app_name     => g_app_name,
--                           p_msg_name     => 'OKL_AGN_FE_PERD_END_DATE');
--       RAISE Okl_Api.G_EXCEPTION_ERROR;
-- 	END IF;
--
--     IF l_period_start_date IS NULL THEN
--       Okl_Api.Set_Message(p_app_name     => g_app_name,
--                           p_msg_name     => 'OKL_AGN_FE_PERD_START_DATE');
--       RAISE Okl_Api.G_EXCEPTION_ERROR;
-- 	END IF;

    -- SGIYER
    -- UDS Impact
-- Bug 5055714.
--     OKL_STREAMS_UTIL.get_dependent_stream_type(
--             p_khr_id  		   	    => p_khr_id,
--             p_primary_sty_purpose   => 'RENT',
--             p_dependent_sty_purpose => 'PRINCIPAL_BALANCE',
--             x_return_status		    => l_return_status,
--             x_dependent_sty_id      => l_prin_bal_id);
--
--     IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
--       Okl_Api.set_message(p_app_name     => g_app_name,
--                           p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
--                           p_token1       => 'STREAM_NAME',
-- 	                      p_token1_value => 'PRINCIPAL BALANCE');
--       RAISE Okl_Api.G_EXCEPTION_ERROR;
--     END IF;

--  Bug 5055714. Commenting below derivation. Using utility provided instead.
--  OPEN principal_bal_csr (p_khr_id, l_period_start_date, l_period_end_date, l_prin_bal_id);
--  FETCH principal_bal_csr INTO l_principal_bal;
--  CLOSE principal_bal_csr;

    -- Bug 5060624. Passing l_kle_id which is null and not okl_api.g_miss_num
    l_principal_bal := OKL_VARIABLE_INT_UTIL_PVT.get_principal_bal(
         x_return_status  => l_return_status,
         p_khr_id         => p_khr_id,
         p_kle_id         => l_kle_id,
         p_date           => l_last_int_calc_date);

    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_VAR_PB_ERROR');
    END IF;

    IF l_principal_bal IS NULL THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_PRIN_BAL',
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value => l_contract_number);
	  RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

      -- Bug#2920344. Commenting error message.
      -- If principal balance for period range not found then retrieve
      -- principal balance for available prior period. MMITTAL.
      --Okl_Api.Set_Message(p_app_name     => g_app_name,
      --                    p_msg_name     => 'OKL_AGN_FE_PRIN_BAL',
      --                    p_token1       => 'CONTRACT_NUMBER',
      --                    p_token1_value => l_contract_number);
      --CLOSE principal_bal_csr;
	  --RAISE Okl_Api.G_EXCEPTION_ERROR;

      -- If principal balance not found for date range, get prior principal balance.
      -- As per MMITTAL.
--       OPEN prior_prin_bal_csr(p_khr_id, l_period_start_date,l_prin_bal_id);
--       FETCH prior_prin_bal_csr INTO l_principal_bal;
--       CLOSE prior_prin_bal_csr;
--       IF l_principal_bal IS NULL THEN
--         Okl_Api.Set_Message(p_app_name     => g_app_name,
--                             p_msg_name     => 'OKL_AGN_FE_PRIN_BAL',
--                             p_token1       => 'CONTRACT_NUMBER',
--                             p_token1_value => l_contract_number);
-- 	    RAISE Okl_Api.G_EXCEPTION_ERROR;
--       END IF;
--	END IF;

    RETURN l_principal_bal;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      RETURN NULL;

	WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
      RETURN NULL;
  END CONTRACT_PRINCIPAL_BALANCE;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By     : Shri Iyer
    -- Function Name  : CONTRACT_UNBILLED_RECEIVABLES
    -- Description    : This function returns the unbilled receivables balance for a contract as of a given date
    -- Dependencies   : None
    -- Parameters     : contract id, contract line id
    -- Version        : 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------

  FUNCTION CONTRACT_UNBILLED_RECEIVABLES(p_khr_id IN NUMBER, p_kle_id IN NUMBER) RETURN NUMBER IS
    l_rent_strm_bal       NUMBER := 0;
    l_contract_number     VARCHAR2(2000);
    l_provision_date      DATE;
    l_sty_id              NUMBER;
    l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- cursor to get the contract number
    -- 02-Oct-2003. SGIYER. Added condition ste.stream_element_date >= p_date
    -- on product management's instructions.
    CURSOR contract_num_csr (p_ctr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
    SELECT  contract_number
    FROM OKL_K_HEADERS_FULL_V
    WHERE id = p_ctr_id;

    -- SGIYER
    -- modifying cursor for user defind streams project
    CURSOR get_unb_rec_csr(p_ctr_id NUMBER, p_date DATE, p_sty_id NUMBER) IS
    SELECT SUM(ste.amount)
    FROM OKL_STREAMS stm,
         OKL_STRM_ELEMENTS ste,
         OKL_STRM_TYPE_B sty
    WHERE stm.khr_id = p_ctr_id
    AND stm.sty_id = sty.id
    AND sty.id = p_sty_id
    AND stm.active_yn = 'Y'
    AND stm.say_code ='CURR'
    AND ste.stm_id = stm.id
    AND ste.stream_element_date >= p_date
    AND ste.date_billed IS NULL;

  BEGIN
	OPEN contract_num_csr(p_khr_id);
    FETCH contract_num_csr INTO l_contract_number;
    CLOSE contract_num_csr;

    IF l_contract_number IS NULL THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
      FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
	  LOOP
	    IF Okl_Execute_Formula_Pub.g_additional_parameters(i).name = 'p_provision_date' THEN
          l_provision_date := TO_DATE(Okl_Execute_Formula_Pub.g_additional_parameters(i).value, 'MM/DD/YYYY');
        END IF;
      END LOOP;
	ELSE
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_ADD_PARAMS');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    IF l_provision_date IS NULL THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_GLP_PROV_DATE_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    -- SGIYER
    -- UDS Impact
    OKL_STREAMS_UTIL.get_primary_stream_type(
      p_khr_id  		   	=> p_khr_id,
      p_primary_sty_purpose => 'RENT',
      x_return_status		=> l_return_status,
      x_primary_sty_id 		=> l_sty_id);

    IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                          p_token1       => 'STREAM_NAME',
                          p_token1_value => 'RENT');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    OPEN get_unb_rec_csr(p_khr_id, l_provision_date, l_sty_id);
	FETCH get_unb_rec_csr INTO l_rent_strm_bal;
    CLOSE get_unb_rec_csr;

    -- Bug 2969989. Return zero explicitly if nothing found.
    IF l_rent_strm_bal IS NULL THEN
      l_rent_strm_bal := 0;
	END IF;
    RETURN l_rent_strm_bal;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      RETURN NULL;

	WHEN OTHERS THEN
      IF get_unb_rec_csr%ISOPEN THEN
        CLOSE get_unb_rec_csr;
      END IF;
      IF contract_num_csr%ISOPEN THEN
        CLOSE contract_num_csr;
      END IF;
      Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
      RETURN NULL;
  END CONTRACT_UNBILLED_RECEIVABLES;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By     : Shri Iyer
    -- Function Name  : CONTRACT_UNEARNED_REVENUE
    -- Description    : This function returns the unearned income for a contract as of a given date
    -- Dependencies   : None
    -- Parameters     : contract id, contract line id
    -- Version        : 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------

  FUNCTION CONTRACT_UNEARNED_REVENUE(p_khr_id IN NUMBER, p_kle_id IN NUMBER) RETURN NUMBER IS
    l_income_strm_bal       NUMBER := 0;
    l_contract_number       VARCHAR2(2000);
    l_provision_date        DATE;
    l_rent_sty_id           NUMBER;
    l_lease_inc_sty_id      NUMBER;
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- cursor to get the contract number
    CURSOR contract_num_csr (p_ctr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
    SELECT  contract_number
    FROM OKL_K_HEADERS_FULL_V
    WHERE id = p_ctr_id;

    -- changing stream type name from INCOME to PRE TAX INCOME as suggested by PM. BUG# 2671223
    -- correcting name. Its hould be PRE-TAX INCOME (with hyphen)
    -- Bug 2969989. Pre-Tax amount is negative by default. So taking absolute value.
    -- Bug 3126427. Removing absolute function.
    -- 02-Oct-2003. SGIYER. Added condition ste.stream_element_date >= p_date
    -- on product management's instructions.
    -- SGIYER. User defined streams project changes.09/22/04
    CURSOR get_unearn_rev_csr (p_ctr_id NUMBER, p_date DATE, p_rent_sty_id NUMBER, p_lease_inc_sty_id NUMBER) IS
    SELECT SUM(ste.amount)
    FROM OKL_STREAMS stm,
         OKL_STRM_ELEMENTS ste,
         OKL_STRM_TYPE_B sty
    WHERE stm.khr_id = p_ctr_id
    AND stm.sty_id = sty.id
    AND sty.id = p_lease_inc_sty_id
    AND stm.active_yn = 'Y'
    AND stm.say_code = 'CURR'
    AND ste.stm_id = stm.id
    AND ste.stream_element_date >=
      (SELECT TRUNC(MIN(ste.stream_element_date),'MM')
       FROM OKL_STREAMS stm,
            OKL_STRM_ELEMENTS ste,
            OKL_STRM_TYPE_B sty
       WHERE stm.khr_id = p_ctr_id
       AND stm.sty_id = sty.id
       AND sty.id = l_rent_sty_id
       AND stm.active_yn = 'Y'
       AND ste.stm_id = stm.id
	   AND ste.stream_element_date >= p_date
       AND ste.date_billed IS NULL)
    AND ste.stream_element_date <=
       (SELECT LAST_DAY(MAX(ste.stream_element_date))
       FROM OKL_STREAMS stm,
            OKL_STRM_ELEMENTS ste,
            OKL_STRM_TYPE_B sty
       WHERE stm.khr_id = p_ctr_id
       AND stm.sty_id = sty.id
	   AND sty.id = l_rent_sty_id
       AND stm.active_yn = 'Y'
       AND ste.stm_id = stm.id
       AND ste.stream_element_date >= p_date
       AND ste.date_billed IS NULL);

  BEGIN
	OPEN contract_num_csr(p_khr_id);
    FETCH contract_num_csr INTO l_contract_number;
    CLOSE contract_num_csr;
    IF l_contract_number IS NULL THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
      FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
	  LOOP
	    IF Okl_Execute_Formula_Pub.g_additional_parameters(i).name = 'p_provision_date' THEN
          l_provision_date := TO_DATE(Okl_Execute_Formula_Pub.g_additional_parameters(i).value, 'MM/DD/YYYY');
        END IF;
      END LOOP;
	ELSE
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_ADD_PARAMS');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    IF l_provision_date IS NULL THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_GLP_PROV_DATE_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    -- SGIYER
    -- UDS Impact
    OKL_STREAMS_UTIL.get_primary_stream_type(
      p_khr_id  		   	=> p_khr_id,
      p_primary_sty_purpose => 'RENT',
      x_return_status		=> l_return_status,
      x_primary_sty_id 		=> l_rent_sty_id);
    IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                          p_token1       => 'STREAM_NAME',
                          p_token1_value => 'RENT');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- SGIYER
    -- UDS Impact
    OKL_STREAMS_UTIL.get_dependent_stream_type(
            p_khr_id  		   	    => p_khr_id,
            p_primary_sty_purpose   => 'RENT',
            p_dependent_sty_purpose => 'LEASE_INCOME',
            x_return_status		    => l_return_status,
            x_dependent_sty_id      => l_lease_inc_sty_id);
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      -- store SQL error message on message stack for caller and entry in log file
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
	                      p_token1       => 'STREAM_NAME',
	                      p_token1_value => 'LEASE INCOME');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    OPEN get_unearn_rev_csr (p_khr_id, l_provision_date, l_rent_sty_id, l_lease_inc_sty_id);
    FETCH get_unearn_rev_csr INTO l_income_strm_bal;
    CLOSE get_unearn_rev_csr;

    -- Bug 2969989. Return zero explicitly if nothing found.
    IF l_income_strm_bal IS NULL THEN
      l_income_strm_bal := 0;
	END IF;

    RETURN l_income_strm_bal;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	RETURN NULL;

	WHEN OTHERS THEN
      IF get_unearn_rev_csr%ISOPEN THEN
        CLOSE get_unearn_rev_csr;
      END IF;
      IF contract_num_csr%ISOPEN THEN
        CLOSE contract_num_csr;
      END IF;
      Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
      RETURN NULL;
  END CONTRACT_UNEARNED_REVENUE;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By     : Shri Iyer
    -- Function Name  : CONTRACT_UNGUARANTEED_RESIDUAL
    -- Description    : This function returns the unguaranteed residual for a contract
    -- Dependencies   : None
    -- Parameters     : contract id, contract line id
    -- Version        : 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------

  FUNCTION CONTRACT_UNGUARANTEED_RESIDUAL(p_khr_id IN NUMBER, p_kle_id IN NUMBER) RETURN NUMBER IS
    l_unguaranteed_residual  NUMBER := 0;
    l_contract_number VARCHAR2(2000);

    -- cursor to get the contract number
    CURSOR contract_num_csr (p_ctr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
    SELECT  contract_number
    FROM OKL_K_HEADERS_FULL_V
    WHERE id = p_ctr_id;

    CURSOR get_ung_res_csr(p_ctr_id NUMBER) IS
    SELECT SUM(NVL(RESIDUAL_VALUE,0)) - SUM(NVL(RESIDUAL_GRNTY_AMOUNT, 0))
    FROM OKL_K_LINES_FULL_V
    WHERE DNZ_CHR_ID = p_ctr_id;

  BEGIN
	OPEN contract_num_csr(p_khr_id);
    FETCH contract_num_csr INTO l_contract_number;
    IF contract_num_csr%NOTFOUND THEN
      CLOSE contract_num_csr;
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
    CLOSE contract_num_csr;

    OPEN get_ung_res_csr(p_khr_id);
    FETCH get_ung_res_csr INTO l_unguaranteed_residual;
    IF get_ung_res_csr%NOTFOUND THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_LPV_FE_UNG_RES',
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value => l_contract_number);
      CLOSE get_ung_res_csr;
	  RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	CLOSE get_ung_res_csr;

    -- Bug 2969989. Return zero explicitly if nothing found.
    IF l_unguaranteed_residual IS NULL THEN
      l_unguaranteed_residual := 0;
	END IF;

    RETURN l_unguaranteed_residual;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
	RETURN NULL;

	WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;
  END CONTRACT_UNGUARANTEED_RESIDUAL;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By     : Shri Iyer
    -- Function Name  : CONTRACT_UNACCRUED_SUBSIDY
    -- Description    : This function returns the unaccrued portion of the subsidy streams for a
    --                  given contract on a particular date
    -- Dependencies   : None
    -- Parameters     : contract id, contract line id
    -- Version        : 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------

  FUNCTION CONTRACT_UNACCRUED_SUBSIDY(p_khr_id IN NUMBER, p_kle_id IN NUMBER) RETURN NUMBER IS
    l_unaccrued_subsidy       NUMBER := 0;
    l_contract_number         VARCHAR2(2000);
	l_provision_date          DATE;
    l_subsidy_inc_id          NUMBER;
    l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- cursor to get the contract number
    CURSOR contract_num_csr (p_ctr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
    SELECT  contract_number
    FROM OKL_K_HEADERS_FULL_V
    WHERE id = p_ctr_id;

    -- cursor to get unaccrued subsidy for a contract
    CURSOR unaccrued_subsidy_csr(p_ctr_id OKL_K_HEADERS_FULL_V.ID%TYPE, p_date DATE, p_subsidy_inc_id NUMBER) IS
    SELECT SUM(ste.amount)
    FROM OKL_STRM_ELEMENTS ste,
         OKL_STRM_TYPE_B sty,
         OKL_STREAMS stm
    WHERE stm.khr_id = p_ctr_id
    AND stm.sty_id = sty.id
    AND sty.id = p_subsidy_inc_id
    AND stm.active_yn = 'Y'
    AND stm.say_code = 'CURR'
    AND stm.id = ste.stm_id
    AND ste.accrued_yn IS NULL
    AND ste.stream_element_date <= p_date;


  BEGIN

	OPEN contract_num_csr(p_khr_id);
    FETCH contract_num_csr INTO l_contract_number;
    CLOSE contract_num_csr;

    IF l_contract_number IS NULL THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
      FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
	  LOOP
	    IF Okl_Execute_Formula_Pub.g_additional_parameters(i).name = 'p_provision_date' THEN
          l_provision_date := TO_DATE(Okl_Execute_Formula_Pub.g_additional_parameters(i).value, 'MM/DD/YYYY');
        END IF;
      END LOOP;
	ELSE
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_ADD_PARAMS');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    IF l_provision_date IS NULL THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_GLP_PROV_DATE_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    -- Bug 4053623.
	-- Modifying error handling.
    OKL_STREAMS_UTIL.get_dependent_stream_type(
            p_khr_id  		   	    => p_khr_id,
            p_primary_sty_purpose   => 'SUBSIDY',
            p_dependent_sty_purpose => 'SUBSIDY_INCOME',
            x_return_status		    => l_return_status,
            x_dependent_sty_id      => l_subsidy_inc_id);
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        -- subsidy income stream not defined for the contract
        l_unaccrued_subsidy := 0;
        RETURN l_unaccrued_subsidy;
      ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        -- store SQL error message on message stack for caller and entry in log file
        Okl_Api.set_message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
	                        p_token1       => 'STREAM_NAME',
	                        p_token1_value => 'SUBSIDY INCOME');
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF l_subsidy_inc_id IS NOT NULL THEN
      OPEN unaccrued_subsidy_csr (p_khr_id, l_provision_date, l_subsidy_inc_id);
      FETCH unaccrued_subsidy_csr INTO l_unaccrued_subsidy;
      CLOSE unaccrued_subsidy_csr;
    END IF;
    IF l_unaccrued_subsidy IS NULL THEN
      l_unaccrued_subsidy := 0;
	END IF;

    RETURN l_unaccrued_subsidy;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      RETURN NULL;

	WHEN OTHERS THEN
      IF unaccrued_subsidy_csr%ISOPEN THEN
        CLOSE unaccrued_subsidy_csr;
      END IF;
      IF contract_num_csr%ISOPEN THEN
        CLOSE contract_num_csr;
      END IF;
      Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
      RETURN NULL;
  END CONTRACT_UNACCRUED_SUBSIDY;

  FUNCTION CONTRACT_TOTAL_ACTUAL_INT(p_khr_id IN NUMBER, p_kle_id IN NUMBER) RETURN NUMBER IS

	l_accrual_date            DATE;
    l_total_actual_int      NUMBER;
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN


    IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
      FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
	  LOOP
	    IF Okl_Execute_Formula_Pub.g_additional_parameters(i).name = 'p_accrual_date' THEN
          l_accrual_date := TO_DATE(Okl_Execute_Formula_Pub.g_additional_parameters(i).value, 'MM/DD/YYYY');
        END IF;
      END LOOP;
	ELSE
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_ADD_PARAMS');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    IF l_accrual_date IS NULL THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_DATE_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    l_total_actual_int := OKL_VARIABLE_INT_UTIL_PVT.get_interest_due(
                               x_return_status => l_return_status,
                               p_khr_id => p_khr_id,
                               p_to_date => l_accrual_date);

    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      -- store SQL error message on message stack for caller and entry in log file
      Okl_Api.set_message(p_app_name     => g_app_name,
                         p_msg_name     => 'OKL_AGN_VAR_INT_UTIL_ERROR',
                         p_token1       => 'ERROR_STATUS',
                         p_token1_value => l_return_status);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSE
      IF (l_total_actual_int IS NULL) OR (l_total_actual_int = 0) THEN
        Okl_Api.Set_Message(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_AGN_TOT_VAR_INT_ERROR');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    RETURN l_total_actual_int;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      RETURN NULL;

	WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
      RETURN NULL;

  END CONTRACT_TOTAL_ACTUAL_INT;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By     : Shri Iyer
    -- Function Name  : CONTRACT_TOTAL_ACCRUED_INT
    -- Description    : This function returns the total accrued amount for a
    --                  given contract on a particular date
    -- Dependencies   : None
    -- Parameters     : contract id, contract line id
    -- Version        : 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------

  FUNCTION CONTRACT_TOTAL_ACCRUED_INT(p_khr_id IN NUMBER, p_kle_id IN NUMBER) RETURN NUMBER IS
    l_total_accrued           NUMBER := 0;
    l_contract_number         VARCHAR2(2000);
	l_accrual_date            DATE;
    l_sty_id                  NUMBER;
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- cursor to get the contract number
    CURSOR contract_num_csr (p_ctr_id OKL_K_HEADERS_FULL_V.ID%TYPE) IS
    SELECT  contract_number
    FROM OKL_K_HEADERS_FULL_V
    WHERE id = p_ctr_id;


    -- cursor to get unaccrued subsidy for a contract
    --sechawla 19-sep-09 8830506 : added new parameter cp_rep_type
    CURSOR total_accrued_csr(p_ctr_id NUMBER, p_date DATE, p_sty_id NUMBER, cp_rep_type IN VARCHAR2) IS
    SELECT SUM(trx.amount)
    FROM OKL_TRX_CONTRACTS trx,
         OKL_TRX_TYPES_V try,
         OKL_TXL_CNTRCT_LNS txl
    WHERE trx.khr_id = p_ctr_id
 --Fixed Bug 5707866 SLA Uptake Project by nikshah, changed tsu_code to PROCESSED from ENTERED
    AND trx.tsu_code ='PROCESSED'
    AND trx.try_id = try.id
    --AND trx.representation_type = 'PRIMARY' -- MGAAP OTHER 7263041 --sechawla 19-sep-09 8830506
    AND trx.representation_type = cp_rep_type --sechawla 19-sep-09 8830506
    AND try.name = 'Accrual'
    AND trx.date_transaction_occurred <= p_date
    AND trx.id = txl.tcn_id
    AND txl.sty_id = p_sty_id;

    l_rep_type   VARCHAR2(20); --sechawla 19-Sep-09 8830506 :added

  BEGIN

	OPEN contract_num_csr(p_khr_id);
    FETCH contract_num_csr INTO l_contract_number;
    CLOSE contract_num_csr;

    IF l_contract_number IS NULL THEN
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_REV_LPV_CNTRCT_NUM_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
      FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
	  LOOP
	    IF Okl_Execute_Formula_Pub.g_additional_parameters(i).name = 'p_accrual_date' THEN
          l_accrual_date := TO_DATE(Okl_Execute_Formula_Pub.g_additional_parameters(i).value, 'MM/DD/YYYY');
        END IF;
        --sechawla 19-Sep-09 8830506 : added a new parameter
        IF Okl_Execute_Formula_Pub.g_additional_parameters(i).name = 'p_rep_type' THEN
          l_rep_type := Okl_Execute_Formula_Pub.g_additional_parameters(i).value;
        END IF;
      END LOOP;
	ELSE
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_FE_ADD_PARAMS');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

	--sechawla 21-sep-09 8830506
	IF    l_rep_type = 'PRIMARY' THEN
          OKL_STREAMS_UTIL.get_dependent_stream_type(
            p_khr_id  		   	    => p_khr_id,
            p_primary_sty_purpose   => 'RENT',
            p_dependent_sty_purpose => 'ACTUAL_INCOME_ACCRUAL',
            x_return_status		    => l_return_status,
            x_dependent_sty_id      => l_sty_id);
    ELSIF l_rep_type = 'SECONDARY' THEN
          OKL_STREAMS_UTIL.get_dependent_stream_type_rep(
            p_khr_id  		   	    => p_khr_id,
            p_primary_sty_purpose   => 'RENT',
            p_dependent_sty_purpose => 'ACTUAL_INCOME_ACCRUAL',
            x_return_status		    => l_return_status,
            x_dependent_sty_id      => l_sty_id);
    END IF;

    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      -- store SQL error message on message stack for caller and entry in log file
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_STRM_TYPE_ERROR',
                          p_token1       => 'STREAM_NAME',
	                      p_token1_value => 'Actual Income Accrual');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;



    IF l_accrual_date IS NULL THEN
      Okl_Api.Set_Message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AGN_DATE_ERROR');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

	OPEN total_accrued_csr(p_khr_id, l_accrual_date, l_sty_id, l_rep_type); --sechawla 19-Sep-09 8830506 : added l_rep_type
    FETCH total_accrued_csr INTO l_total_accrued;
    CLOSE total_accrued_csr;

    IF l_total_accrued IS NULL THEN
      l_total_accrued := 0;
    END IF;

    RETURN l_total_accrued;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      RETURN NULL;

	WHEN OTHERS THEN
      IF total_accrued_csr%ISOPEN THEN
        CLOSE total_accrued_csr;
      END IF;
      Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
      RETURN NULL;
  END CONTRACT_TOTAL_ACCRUED_INT;

------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    Roman.Draguilev@oracle.com - 20-FEB-2002
  -- Function Name: contract_estimate_tax
  -- Description:   Estimate tax using ARP-CRM integration routines
  -- Dependencies:  OKL building blocks AMTX and AMUV,
  -- Parameters:    IN:  p_contract_id, p_contract_line_id,
  --                     taxable_amount (stored in g_additional_parameters(1))
  --                OUT: amount
  -- History        : RMUNJULU 3394507 Get the loc_id for location_id and pass to Tax engine
  --                : RMUNJULU 3394507 Performance fix, changed cursor to query fron base tables
  --                  instead of _uv
  --                : RMUNJULU 3394507 added code
  --                  to reset the arp_tax.tax_info_rec before it is called
  --                  Also added code to set the location_id based on bill_to_site
  --                  for contract level quote line tax calculation
  --                : GKADARKA 3569441 Added union in cursor l_item_loc_csr
  --                : rmunjulu 3682465 Changed to get and set the bill_to_postal_code
  -- Version:       1.0
  -- End of Commnets
------------------------------------------------------------------------------

FUNCTION contract_estimate_tax (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS

	-- Get location of all Installed Base items
	-- linked to the Financial Asset Line
    -- RMUNJULU 3394507 Changed the cursor to get the loc_id (location ccid) for
    -- org_id and location_id
    -- RMUNJULU 3394507 Performance fix, query from base tables instead of
    -- from _uv
/*
	CURSOR l_item_loc_csr (cp_fin_asset_cle_id NUMBER) IS
    SELECT DISTINCT LOA.loc_id location_id, LOC.postal_code -- 3682465
    FROM OKC_K_LINES_B        KLE_FA,
         OKC_LINE_STYLES_B    LSE_FA,
         OKC_K_LINES_B        KLE_IL,
         OKC_LINE_STYLES_B    LSE_IL,
         OKC_K_LINES_B        KLE_IB,
         OKC_LINE_STYLES_B    LSE_IB,
         OKC_K_ITEMS          ITE,
         CSI_ITEM_INSTANCES   CII,
         HZ_PARTY_SITES       PSI,
         HZ_LOCATIONS         LOC,
      --   HZ_PARTIES           PAR,
         HZ_PARTY_SITE_USES   PSU,
         HZ_LOC_ASSIGNMENTS   LOA
    WHERE kle_fa.id	=  cp_fin_asset_cle_id
    AND   lse_fa.id = kle_fa.lse_id
    AND   lse_fa.lty_code = 'FREE_FORM1'
    AND   kle_il.cle_id = kle_fa.id
    AND   lse_il.id = kle_il.lse_id
    AND   lse_il.lty_code = 'FREE_FORM2'
    AND   kle_ib.cle_id = kle_il.id
    AND   lse_ib.id = kle_ib.lse_id
    AND   lse_ib.lty_code = 'INST_ITEM'
    AND   ite.cle_id = kle_ib.id
    AND   ite.jtot_object1_code = 'OKX_IB_ITEM'
    AND   cii.instance_id = ite.object1_id1
    AND   cii.install_location_type_code = 'HZ_PARTY_SITES'
    AND   psi.party_site_id = cii.install_location_id
    AND   loc.location_id = psi.location_id
 --   AND   par.party_id = psi.party_id
    AND   psu.party_site_id = psi.party_site_id
    AND   psu.site_use_type = 'INSTALL_AT'
    AND   loc.location_id = loa.location_id
    UNION
    SELECT DISTINCT LOA.loc_id location_id, LOC.postal_code -- 3682465
    FROM OKC_K_LINES_B        KLE_FA,
         OKC_LINE_STYLES_B    LSE_FA,
         OKC_K_LINES_B        KLE_IL,
         OKC_LINE_STYLES_B    LSE_IL,
         OKC_K_LINES_B        KLE_IB,
         OKC_LINE_STYLES_B    LSE_IB,
         OKC_K_ITEMS          ITE,
         CSI_ITEM_INSTANCES   CII,
         --HZ_PARTY_SITES       PSI,
         HZ_LOCATIONS         LOC,
         --HZ_PARTIES           PAR,
         --HZ_PARTY_SITE_USES   PSU,
         HZ_LOC_ASSIGNMENTS   LOA
    WHERE kle_fa.id	=  cp_fin_asset_cle_id
    AND   lse_fa.id = kle_fa.lse_id
    AND   lse_fa.lty_code = 'FREE_FORM1'
    AND   kle_il.cle_id = kle_fa.id
    AND   lse_il.id = kle_il.lse_id
    AND   lse_il.lty_code = 'FREE_FORM2'
    AND   kle_ib.cle_id = kle_il.id
    AND   lse_ib.id = kle_ib.lse_id
    AND   lse_ib.lty_code = 'INST_ITEM'
    AND   ite.cle_id = kle_ib.id
    AND   ite.jtot_object1_code = 'OKX_IB_ITEM'
    AND   cii.instance_id = ite.object1_id1
    AND   cii.install_location_type_code = 'HZ_LOCATIONS'
    AND   loc.location_id = cii.install_location_id
    --AND   loc.location_id = psi.location_id
    --AND   par.party_id = psi.party_id
    --AND   psu.party_site_id = psi.party_site_id
    --AND   psu.site_use_type = 'INSTALL_AT'
    AND   loc.location_id = loa.location_id
    AND   EXISTS (SELECT 1
                  FROM   HZ_PARTY_SITES psi,
                         HZ_PARTY_SITE_USES psu
                  WHERE  psi.location_id = loc.location_id
                  AND    psu.party_site_id = psi.party_site_id
                  AND    psu.site_use_type = 'INSTALL_AT');

  -- RMUNJULU 3394507 Added cursor to get the location for the LESSEE bill to
  -- Get the location_id (location_ccid) for the customer bill_to
  CURSOR  item_loc_csr ( p_bill_to_site_use_id IN NUMBER, p_cust_acct_id IN NUMBER) IS
  SELECT  loc_assign.loc_id  location_id, LOC.postal_code -- 3682465
  FROM    HZ_PARTY_SITES            party_site,
          HZ_LOC_ASSIGNMENTS        loc_assign,
          HZ_LOCATIONS              loc,
          HZ_CUST_ACCT_SITES_ALL    acct_site,
          HZ_PARTIES                party,
          HZ_CUST_ACCOUNTS          cust_acct,
          HZ_CUST_SITE_USES         cust_site_uses
  WHERE   acct_site.party_site_id     = party_site.party_site_id
  AND     loc.location_id             = party_site.location_id
  AND     loc.location_id             = loc_assign.location_id
  AND     acct_site.cust_acct_site_id = cust_site_uses.cust_acct_site_id
  AND     party.party_id              = cust_acct.party_id
  AND     cust_site_uses.site_use_id  = p_bill_to_site_use_id
  AND     cust_acct.cust_account_id   = p_cust_acct_id;

	-- Get line name to use in the error messages
	CURSOR l_cle_csr (cp_cle_id NUMBER) IS
		SELECT	l.name
		FROM	okc_k_lines_v l
		WHERE	l.id = cp_cle_id;

	-- Get header number to use in error messages
	CURSOR l_chr_csr (cp_chr_id NUMBER) IS
		SELECT	h.contract_number
		FROM	okc_k_headers_v h
		WHERE	h.id = cp_chr_id;

	l_result_amount		NUMBER		:= 0;
	l_no_taxable_amount	EXCEPTION;
	l_no_sys_params		EXCEPTION;
	l_tax_tbl		ARP_TAX.om_tax_out_tab_type;
	l_bill_to_rec		okx_cust_site_uses_v%ROWTYPE;
	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_object_name		VARCHAR2(200);
	l_token			VARCHAR2(30);

	-- Variables to pass to taxation API
	l_taxable_amount	NUMBER		:= NULL;
	l_org_id		NUMBER		:= NULL;
	l_sob_id		NUMBER		:= NULL;
	l_currency		VARCHAR2(15)	:= NULL;
	l_precision		NUMBER		:= NULL;
	l_min_acc_unit		NUMBER		:= NULL;
	l_cust_site_use_id	NUMBER		:= NULL;
	l_cust_account_id	NUMBER		:= NULL;
	l_location_id		NUMBER		:= NULL;

    -- RMUNJULU 3394507 Declared variable for tax_info_rec_type which will be used
    -- to reset the global variable
    l_tax_rec   arp_tax.tax_info_rec_type;
    l_postal_code HZ_LOCATIONS.postal_code%TYPE; -- 3682465
*/
BEGIN

	-- ***********************************
	-- Get Object to use in error messages
	-- ***********************************
/*
	IF p_contract_line_id IS NOT NULL THEN
		OPEN	l_cle_csr (p_contract_line_id);
		FETCH	l_cle_csr INTO l_object_name;
		CLOSE	l_cle_csr;
		l_token	:= 'contract_line_id';
	ELSE
		OPEN	l_chr_csr (p_contract_id);
		FETCH	l_chr_csr INTO l_object_name;
		CLOSE	l_chr_csr;
		l_token	:= 'contract_id';
	END IF;

	IF l_object_name IS NULL THEN
		l_overall_status := OKL_API.G_RET_STS_ERROR;
		OKC_API.SET_MESSAGE (
			p_app_name	=> OKC_API.G_APP_NAME,
			p_msg_name	=> OKC_API.G_INVALID_VALUE,
			p_token1	=> OKC_API.G_COL_NAME_TOKEN,
			p_token1_value	=> l_token);
	END IF;

	-- ********************************************
	-- Extract Taxable Amount from global variables
	-- ********************************************

	BEGIN

	    IF  okl_execute_formula_pub.g_additional_parameters(1).name
			= 'TAXABLE AMOUNT'
	    AND okl_execute_formula_pub.g_additional_parameters(1).value
			IS NOT NULL
	    THEN
		l_taxable_amount := TO_NUMBER
			(okl_execute_formula_pub.g_additional_parameters(1).value);
	    ELSE
		RAISE l_no_taxable_amount;
	    END IF;

	    IF  NVL (l_taxable_amount, 0) = 0 THEN
		RAISE l_no_taxable_amount;
	    END IF;

	EXCEPTION
	    WHEN OTHERS THEN
		l_overall_status := OKL_API.G_RET_STS_ERROR;
		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_AM_TAX_NO_TAXABLE_AMOUNT',
			p_token1	=> 'OBJECT',
			p_token1_value	=> l_object_name);
	END;

	-- **************************************************
	-- Get all generic parameters required by taxation API
	-- **************************************************

	BEGIN

	    l_org_id   := okl_am_util_pvt.get_chr_org_id (p_contract_id);
	    l_sob_id   := okc_currency_api.get_ou_sob (l_org_id);
	    l_currency := okc_currency_api.get_sob_currency (l_sob_id);
	    okl_am_util_pvt.get_currency_info
			(l_currency, l_precision, l_min_acc_unit);

	    IF l_sob_id IS NULL OR l_precision IS NULL THEN
		RAISE l_no_sys_params;
	    END IF;

	EXCEPTION
	    WHEN OTHERS THEN
		l_overall_status := OKL_API.G_RET_STS_ERROR;
		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_AM_TAX_NO_PARAMS',
			p_token1	=> 'OBJECT',
			p_token1_value	=> l_object_name);
	END;

	-- *****************************************************
	-- Get line specific parameters required by taxation API
	-- *****************************************************

	IF  (p_contract_line_id IS NOT NULL)
	AND (l_object_name IS NOT NULL) THEN

		OPEN	l_item_loc_csr (p_contract_line_id);

		LOOP
			FETCH	l_item_loc_csr INTO l_location_id, l_postal_code; -- 3682465
			EXIT  WHEN l_item_loc_csr%NOTFOUND
				OR l_item_loc_csr%ROWCOUNT > 1;
		END LOOP;

		IF l_item_loc_csr%ROWCOUNT <> 1
		OR l_location_id IS NULL THEN
			l_overall_status := OKL_API.G_RET_STS_ERROR;
			OKL_API.SET_MESSAGE (
				p_app_name	=> OKL_API.G_APP_NAME,
				p_msg_name	=> 'OKL_AM_TAX_NO_LOCATION',
				p_token1	=> 'OBJECT',
				p_token1_value	=> l_object_name);
		END IF;

		CLOSE	l_item_loc_csr;

	-- *********************************************************
	-- Get contract specific parameters required by taxation API
	-- *********************************************************

	ELSIF (p_contract_line_id IS NULL) THEN

		okl_am_util_pvt.get_bill_to_address (
			p_contract_id		=> p_contract_id,
			p_message_yn		=> FALSE,
			x_bill_to_address_rec	=> l_bill_to_rec,
			x_return_status		=> l_return_status);

		IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
			l_cust_site_use_id := l_bill_to_rec.id1;
			l_cust_account_id  := l_bill_to_rec.cust_account_id;
		END IF;

		IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
		OR l_cust_site_use_id IS NULL
		OR l_cust_account_id  IS NULL THEN
			l_overall_status := OKL_API.G_RET_STS_ERROR;
			OKL_API.SET_MESSAGE (
				p_app_name	=> OKL_API.G_APP_NAME,
				p_msg_name	=> 'OKL_AM_TAX_NO_BILL_TO',
				p_token1	=> 'OBJECT',
				p_token1_value	=> l_object_name);
		END IF;

	END IF;

	-- *****************
	-- Call taxation API
	-- *****************

    -- RMUNJULU 3394507 Reset the GLOBAL tax_info_rec rec type with empty rec type
    arp_tax.tax_info_rec := l_tax_rec;

	-- Calculate tax for positive amounts
	IF  l_overall_status = OKL_API.G_RET_STS_SUCCESS
	AND l_taxable_amount > 0 THEN

	    arp_tax.tax_info_rec.trx_date		:= SYSDATE;
	    arp_tax.tax_info_rec.extended_amount	:= l_taxable_amount;
	    arp_tax.tax_info_rec.trx_currency_code	:= l_currency;
	    arp_tax.tax_info_rec.PRECISION		:= l_precision;
	    arp_tax.tax_info_rec.minimum_accountable_unit := l_min_acc_unit;

	    IF p_contract_line_id IS NOT NULL THEN

		    arp_tax.tax_info_rec.bill_to_location_id := l_location_id;

            arp_tax.tax_info_rec.bill_to_postal_code := l_postal_code; -- 3682465

	    ELSE
		    arp_tax.tax_info_rec.bill_to_site_use_id := l_cust_site_use_id;
		    arp_tax.tax_info_rec.bill_to_cust_id	 := l_cust_account_id;

            -- RMUNJULU  3394507 Found that Tax engine also needs the location_id
            -- for the bill to location, added code to get and set that value
            -- get the location for the LESSEE bill to
            OPEN item_loc_csr ( l_cust_site_use_id, l_cust_account_id);
            FETCH item_loc_csr INTO l_location_id, l_postal_code; -- 3682465
            CLOSE item_loc_csr;

            -- raise message if site location not found
            IF l_location_id IS NULL THEN
			 OKL_API.SET_MESSAGE (
				p_app_name	=> OKL_API.G_APP_NAME,
				p_msg_name	=> 'OKL_AM_TAX_NO_LOCATION',
				p_token1	=> 'OBJECT',
				p_token1_value	=> l_object_name);
            END IF;

            -- set the tax_info_rec with location id
		    arp_tax.tax_info_rec.bill_to_location_id := l_location_id;

            arp_tax.tax_info_rec.bill_to_postal_code := l_postal_code; -- 3682465

	    END IF;

	    BEGIN
		arp_tax_crm_integration_pkg.summary
			(p_set_of_books_id 	=>	l_sob_id
			,x_crm_tax_out_tbl	=>	l_tax_tbl
			,p_new_tax_amount	=>	l_result_amount);
	    EXCEPTION
		WHEN OTHERS THEN
		    l_overall_status := OKL_API.G_RET_STS_ERROR;
		    OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_AM_TAX_ARP_FAILED',
			p_token1	=> 'OBJECT',
			p_token1_value	=> l_object_name);
	    END;

	END IF;

	RETURN NVL (l_result_amount, 0);
*/
return 0;
EXCEPTION
	WHEN OTHERS THEN
/*
		-- Close open cursors

		IF l_item_loc_csr%ISOPEN THEN
			CLOSE l_item_loc_csr;
		END IF;

		IF l_cle_csr%ISOPEN THEN
			CLOSE l_cle_csr;
		END IF;

		IF l_chr_csr%ISOPEN THEN
			CLOSE l_chr_csr;
		END IF;

        -- RMUNJULU 3394507 close cursor if open
		IF item_loc_csr%ISOPEN THEN
			CLOSE item_loc_csr;
		END IF;

		-- store SQL error message on message stack for caller

		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_CONTRACTS_UNEXPECTED_ERROR',
			p_token1	=> 'SQLCODE',
			p_token1_value	=> SQLCODE,
			p_token2	=> 'SQLERRM',
			p_token2_value	=> SQLERRM);
*/
		RETURN NULL;

END contract_estimate_tax;


------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    Roman.Draguilev@oracle.com - 20-FEB-2002
  -- Function Name: line_estimate_tax
  -- Description:   Estimate tax using ARP-CRM integration routines
  -- Dependencies:  OKL building blocks AMTX and AMUV,
  -- Parameters:    IN:  p_contract_id, p_contract_line_id,
  --                     taxable_amount (stored in g_additional_parameters(1))
  --                OUT: amount
  -- Version:       1.0
  -- End of Commnets
------------------------------------------------------------------------------

FUNCTION line_estimate_tax (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS
BEGIN
	-- To avoid code repetition, both header
	-- and line are handled in one routine
	RETURN (contract_estimate_tax (p_contract_id, p_contract_line_id));
END line_estimate_tax;


------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    Roman.Draguilev@oracle.com - 20-FEB-2002
  -- Function Name: line_estimated_property_tax
  -- Description:   Estimate property tax based on previous records
  -- Dependencies:  OKL building blocks AMTX and AMUV,
  -- Parameters:    IN:  p_contract_id, p_contract_line_id,
  --                OUT: amount
  -- Version:       1.0
  -- History:       21-MAR-2002 RDRAGUIL - Cursor based on Billing TRXs
  --                05 Nov 2004 PAGARG Bug# 3925492
  --                Modified the procedure to call BPD API for formula value.
  -- End of Commnets
------------------------------------------------------------------------------

FUNCTION line_estimated_property_tax (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS

	l_result_amount		NUMBER;

    --Bug# 3925492: pagarg +++ Estd. Prop Tax +++++++ Start ++++++++++
    CURSOR get_quote_date_csr (p_quote_id IN NUMBER) IS
    SELECT trunc(qte.date_effective_from) date_effective_from
    FROM   okl_trx_quotes_b  qte
    WHERE  qte.id = p_quote_id;

    l_quote_id        NUMBER;
    l_quote_date_eff  DATE;
    l_sysdate         DATE;
    l_api_version     NUMBER;
    l_init_msg_list   VARCHAR2(1);
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    l_input_tbl       OKL_BPD_TERMINATION_ADJ_PVT.input_tbl_type;
    lx_baj_tbl        OKL_BPD_TERMINATION_ADJ_PVT.baj_tbl_type;
    l_tbl_cnt         NUMBER;
BEGIN
    l_api_version := '1.0';
    l_init_msg_list := OKL_API.G_FALSE;
    l_result_amount := 0;

    IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
      FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
      LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).name = 'quote_id' THEN
           l_quote_id := TO_NUMBER(OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).value);
        END IF;
      END LOOP;
    END IF;

    IF  l_quote_id IS NOT NULL
    AND l_quote_id <> OKL_API.G_MISS_NUM THEN
       OPEN get_quote_date_csr (l_quote_id);
       FETCH get_quote_date_csr INTO l_quote_date_eff;
       CLOSE get_quote_date_csr;
    END IF;

    SELECT SYSDATE INTO l_sysdate FROM DUAL;

    IF l_quote_date_eff IS NULL
    OR l_quote_date_eff = OKL_API.G_MISS_DATE
    THEN
       l_quote_date_eff := l_sysdate;
    END IF;

    l_input_tbl(0).khr_id := p_contract_id;
    l_input_tbl(0).kle_id := p_contract_line_id;
    l_input_tbl(0).term_date_from := l_quote_date_eff;

    OKL_BPD_TERMINATION_ADJ_PVT.get_unbilled_prop_tax(
        p_api_version        => l_api_version,
        p_init_msg_list      => l_init_msg_list,
        p_input_tbl          => l_input_tbl,
        x_baj_tbl            => lx_baj_tbl,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data);

    IF lx_baj_tbl.COUNT > 0
    THEN
        FOR l_tbl_cnt IN lx_baj_tbl.FIRST..lx_baj_tbl.LAST
        LOOP
            l_result_amount := l_result_amount + lx_baj_tbl(l_tbl_cnt).amount;
        END LOOP;
    END IF;
    --Bug# 3925492: pagarg +++ Estd. Prop Tax +++++++ End ++++++++++

	RETURN NVL (l_result_amount, 0);
EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_CONTRACTS_UNEXPECTED_ERROR',
			p_token1	=> 'SQLCODE',
			p_token1_value	=> SQLCODE,
			p_token2	=> 'SQLERRM',
			p_token2_value	=> SQLERRM);

		RETURN NULL;
END line_estimated_property_tax;

------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    Roman.Draguilev@oracle.com - 20-FEB-2002
  -- Function Name: contract_remaining_sec_dep
  -- Description:   If security deposit disposition is allowed to be included
  --                into a quote, return original security deposit amount
  --                minus any credit memos against security deposit invoices
  -- Dependencies:  OKL building blocks AMTX and AMUV,
  -- Parameters:    IN:  p_contract_id
  --                OUT: amount
  -- Version:       1.0
  -- End of Commnets
------------------------------------------------------------------------------

FUNCTION contract_remaining_sec_dep (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS

	l_sdd_tbl		okl_am_invoices_pvt.sdd_tbl_type;
	l_tld_tbl		okl_am_invoices_pvt.tld_tbl_type;
	l_total_amount		NUMBER;

BEGIN

	okl_am_invoices_pvt.contract_remaining_sec_dep (
		p_contract_id	=> p_contract_id,
		p_contract_line_id => p_contract_line_id,
		x_sdd_tbl	=> l_sdd_tbl,
		x_tld_tbl	=> l_tld_tbl,
		x_total_amount	=> l_total_amount);

	RETURN NVL (l_total_amount, 0);

EXCEPTION

	WHEN OTHERS THEN

		-- store SQL error message on message stack for caller

		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_CONTRACTS_UNEXPECTED_ERROR',
			p_token1	=> 'SQLCODE',
			p_token1_value	=> SQLCODE,
			p_token2	=> 'SQLERRM',
			p_token2_value	=> SQLERRM);

		RETURN NULL;

END contract_remaining_sec_dep;


------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    Roman.Draguilev@oracle.com - 10-JUL-2002
  -- Function Name: line_unbilled_streams
  -- Description:   Calculate unbilled streams
  -- Dependencies:  OKL building blocks AMTX and AMUV,
  -- Parameters:    IN:  p_contract_id, p_contract_line_id,
  --                     stream_type_id (stored in g_additional_parameters(1))
  --                OUT: amount
  -- Version:       1.0
  -- History        SECHAWLA 04-MAR-03 : Restrict the calculation of unbilled
  --                receivables to only billable streams
  -- End of Commnets
------------------------------------------------------------------------------

FUNCTION line_unbilled_streams (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS

	-- Get Unbilled Streams
	CURSOR l_unbill_stream_csr (
			cp_contract_id			NUMBER,
			cp_contract_line_id		NUMBER,
			cp_stream_type_id		NUMBER) IS
		SELECT	SUM (NVL (ste.amount, 0))	amount_due
	   	FROM	okl_streams			stm,
                okl_strm_type_b     sty, -- SECHAWLA 04-MAR-03 Added this table to get the billable_yn flag
			    okl_strm_elements		ste
		WHERE	stm.khr_id			= cp_contract_id
		AND	stm.kle_id			= cp_contract_line_id
		AND	stm.sty_id			= NVL (cp_stream_type_id, stm.sty_id)
		AND	stm.active_yn			= 'Y'
		AND	stm.say_code			= 'CURR'
		AND	ste.stm_id			= stm.id
		AND	ste.date_billed			IS NULL
		AND	NVL (ste.amount, 0)	<> 0
  -- SECHAWLA 04-MAR-03 Added the following 3 conditions to restrict the unbilled receivables calculation to only
  -- billable streams
        AND sty.id              = stm.sty_id
        AND sty.billable_yn     = 'Y';
       -- AND sty.capitalize_yn   = 'N'

	l_result_amount		NUMBER		:= 0;
	l_stream_type_id	NUMBER;

BEGIN

	-- ********************************************
	-- Extract Stream Type Id from global variables
	-- ********************************************

	IF  okl_execute_formula_pub.g_additional_parameters.EXISTS(1)
	AND okl_execute_formula_pub.g_additional_parameters(1).name = 'STREAM TYPE'
	AND okl_execute_formula_pub.g_additional_parameters(1).value IS NOT NULL
	THEN
		l_stream_type_id := TO_NUMBER
			(okl_execute_formula_pub.g_additional_parameters(1).value);
	ELSE
		l_stream_type_id := NULL;
	END IF;

	-- ****************
	-- Calculate result
	-- ****************

	OPEN	l_unbill_stream_csr (p_contract_id, p_contract_line_id, l_stream_type_id);
	FETCH	l_unbill_stream_csr INTO l_result_amount;
	CLOSE	l_unbill_stream_csr;

	RETURN NVL (l_result_amount, 0);

EXCEPTION

	WHEN OTHERS THEN

		-- Close open cursors

		IF l_unbill_stream_csr%ISOPEN THEN
			CLOSE l_unbill_stream_csr;
		END IF;


		-- store SQL error message on message stack for caller

		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_CONTRACTS_UNEXPECTED_ERROR',
			p_token1	=> 'SQLCODE',
			p_token1_value	=> SQLCODE,
			p_token2	=> 'SQLERRM',
			p_token2_value	=> SQLERRM);

		RETURN NULL;

END line_unbilled_streams;


------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    Roman.Draguilev@oracle.com - 24-APR-2002
  -- Function Name: line_unbilled_rent
  -- Description:   Returns the unbilled rent amount for a given contract line
  -- Dependencies:  OKL building blocks AMTX and AMUV
  -- Parameters:    IN:  p_contract_id, p_line_id
  --                     stream_type_id (stored in g_additional_parameters(1))
  --                OUT: amount
  -- Version:       1.0
  -- History  : SECHAWLA 05-MAY-04 3578894 : Modified to evaluate reporting streams
  --                based upon additional parameters
  --              : 31-Dec-2004 PAGARG Bug# 4097591
  --              : UDS impact to obtain stream type id
  -- End of Commnets
------------------------------------------------------------------------------

FUNCTION line_unbilled_rent (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS

    --SECHAWLA 05-MAY-04 3578894 : new declarations
    -- Get Unbilled Streams (moved from line_unbilled_streams)
	CURSOR  l_unbill_stream_csr (
			cp_contract_id			NUMBER,
			cp_contract_line_id		NUMBER,
			cp_stream_type_id		NUMBER) IS
	SELECT	SUM (NVL (ste.amount, 0))	amount_due
	FROM	okl_streams			stm,
            okl_strm_type_b     sty, -- SECHAWLA 04-MAR-03 Added this table to get the billable_yn flag
			okl_strm_elements		ste
	WHERE	stm.khr_id			= cp_contract_id
	AND	stm.kle_id			= cp_contract_line_id
	AND	stm.sty_id			= NVL (cp_stream_type_id, stm.sty_id)
	AND	stm.active_yn			= 'Y'
	AND	stm.say_code			= 'CURR'
	AND	ste.stm_id			= stm.id
	AND	ste.date_billed			IS NULL
	AND	NVL (ste.amount, 0)	<> 0
    -- SECHAWLA 04-MAR-03 Added the following 3 conditions to restrict the unbilled receivables calculation to only
    -- billable streams
    AND sty.id              = stm.sty_id
    AND sty.billable_yn     = 'Y';
       -- AND sty.capitalize_yn   = 'N'

    -- Get Unbilled Streams for Reporting product
	CURSOR l_unbill_reporting_stream_csr (
			cp_contract_id			NUMBER,
			cp_contract_line_id		NUMBER,
			cp_stream_type_id		NUMBER,
            cp_trx_date             DATE) IS
	SELECT	SUM (NVL (ste.amount, 0))	amount_due
	FROM	okl_streams			stm,
                okl_strm_type_b     sty,
			    okl_strm_elements		ste
	WHERE	stm.khr_id			= cp_contract_id
	AND	stm.kle_id			= cp_contract_line_id
	AND	stm.sty_id			= NVL (cp_stream_type_id, stm.sty_id)
	AND	stm.active_yn			= 'N'  -- reporting strems are inactive
	AND	stm.say_code			= 'CURR'  -- reporting streams are current
	AND	ste.stm_id			= stm.id
	AND	ste.date_billed			IS NULL  -- reporting streams never get billed
	AND	NVL (ste.amount, 0)	<> 0
    AND sty.id              = stm.sty_id
    AND sty.billable_yn     = 'Y' -- reporting streams are billable
       -- AND sty.capitalize_yn   = 'N'
    AND stm.purpose_code = 'REPORT'
    AND ste.STREAM_ELEMENT_DATE > cp_trx_date;

    l_rep_prod_streams_yn   VARCHAR2(1) := 'N';
    l_trx_date   DATE;

    ---SECHAWLA 05-MAY-04 3578894 : end new declarations

	l_result_amount		NUMBER		:= 0;
	l_stream_type_id	NUMBER;
	l_return_status     VARCHAR2(3) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN
    --PAGARG 31-Dec-2004 Bug# 4097591 Start
    --UDS impact. Obtain stream type id and pass it to cursor

    OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                             'RENT',
                                             l_return_status,
                                             l_stream_type_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --PAGARG 31-Dec-2004 Bug# 4097591 End

    /*  SECHAWLA 05-MAY-04 3578894
	okl_execute_formula_pub.g_additional_parameters(1).name  := 'STREAM TYPE';
	okl_execute_formula_pub.g_additional_parameters(1).value := l_stream_type_id;

	l_result_amount	:= line_unbilled_streams (p_contract_id, p_contract_line_id);

	RETURN NVL (l_result_amount, 0);
    */

    --Validate additional parameters availability
    IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'REP_PRODUCT_STRMS_YN'
           AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_rep_prod_streams_yn := okl_execute_formula_pub.g_additional_parameters(I).value;
        ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'OFF_LSE_TRX_DATE'
           AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_trx_date := TO_DATE(okl_execute_formula_pub.g_additional_parameters(I).value, 'MM/DD/YYYY');
        END IF;
      END LOOP;
	ELSE
      l_rep_prod_streams_yn := 'N';

	END IF;

    IF l_rep_prod_streams_yn = 'Y' THEN
       IF l_trx_date IS NULL THEN
       -- Can not calculate Net Investment for the reporting product as the transaction date is missing.
          Okl_Api.Set_Message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AM_AMORT_NO_TRX_DATE');
          RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;
    END IF;


	-- ****************
	-- Calculate result
	-- ****************

    IF l_rep_prod_streams_yn = 'Y' THEN
       OPEN  l_unbill_reporting_stream_csr(p_contract_id, p_contract_line_id, l_stream_type_id,l_trx_date );
       FETCH l_unbill_reporting_stream_csr INTO  l_result_amount;
       CLOSE l_unbill_reporting_stream_csr;
    ELSE

	   OPEN  l_unbill_stream_csr (p_contract_id, p_contract_line_id, l_stream_type_id);
	   FETCH l_unbill_stream_csr INTO l_result_amount;
	   CLOSE l_unbill_stream_csr;
    END IF;

	RETURN NVL (l_result_amount, 0);


EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        -- Close open cursors
        IF l_unbill_stream_csr%ISOPEN THEN
            CLOSE l_unbill_stream_csr;
        END IF;

        IF l_unbill_reporting_stream_csr%ISOPEN THEN
            CLOSE l_unbill_reporting_stream_csr;
        END IF;

        RETURN NULL;

	WHEN OTHERS THEN
		-- Close open cursors
        IF l_unbill_stream_csr%ISOPEN THEN
            CLOSE l_unbill_stream_csr;
        END IF;

        IF l_unbill_reporting_stream_csr%ISOPEN THEN
            CLOSE l_unbill_reporting_stream_csr;
        END IF;
		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_CONTRACTS_UNEXPECTED_ERROR',
			p_token1	=> 'SQLCODE',
			p_token1_value	=> SQLCODE,
			p_token2	=> 'SQLERRM',
			p_token2_value	=> SQLERRM);

		RETURN NULL;

END line_unbilled_rent;


-- Start of comments
--
-- Procedure Name  : get_reporting_product
-- Description     : This procedure checks if there is a reporting product attached to the contract and returns
--                   the deal type of the reporting product and MG reporting book
-- Business Rules  :
-- Parameters      :  p_contract_id - Contract ID
-- Version         : 1.0
-- History         : sechawla 12-Dec-07  - 6671849 Created
-- End of comments

PROCEDURE get_reporting_product(p_api_version           IN  	NUMBER,
           		 	              p_init_msg_list         IN  	VARCHAR2,
           			              x_return_status         OUT 	NOCOPY VARCHAR2,
           			              x_msg_count             OUT 	NOCOPY NUMBER,
           			              x_msg_data              OUT 	NOCOPY VARCHAR2,
                                  p_contract_id 		  IN 	NUMBER,
                                  x_rep_product_id           OUT   NOCOPY VARCHAR2) IS


  -- Get the financial product of the contract
  CURSOR l_get_fin_product(cp_khr_id IN NUMBER) IS
  SELECT a.start_date, a.contract_number, b.pdt_id
  FROM   okc_k_headers_b a, okl_k_headers b
  WHERE  a.id = b.id
  AND    a.id = cp_khr_id;

  SUBTYPE pdtv_rec_type IS OKL_SETUPPRODUCTS_PUB.pdtv_rec_type;
  SUBTYPE pdt_parameters_rec_type IS OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;

  l_fin_product_id          NUMBER;
  l_start_date              DATE;
  lp_pdtv_rec               pdtv_rec_type;
  lp_empty_pdtv_rec         pdtv_rec_type;
  lx_no_data_found          BOOLEAN;
  lx_pdt_parameter_rec      pdt_parameters_rec_type ;
  l_contract_number         VARCHAR2(120);

  --mg_error                  EXCEPTION;
  l_reporting_product       OKL_PRODUCTS_V.NAME%TYPE;
  l_reporting_product_id    NUMBER;



  BEGIN
    -- get the financial product of the contract
    OPEN  l_get_fin_product(p_contract_id);
    FETCH l_get_fin_product INTO l_start_date, l_contract_number, l_fin_product_id;
    CLOSE l_get_fin_product;

    lp_pdtv_rec.id := l_fin_product_id;

    -- check if the fin product has a reporting product
    OKL_SETUPPRODUCTS_PUB.Getpdt_parameters( p_api_version                  => p_api_version,
  				  			               p_init_msg_list                => OKC_API.G_FALSE,
						                   x_return_status                => x_return_status,
							               x_no_data_found                => lx_no_data_found,
							               x_msg_count                    => x_msg_count,
							               x_msg_data                     => x_msg_data,
							               p_pdtv_rec                     => lp_pdtv_rec,
							               p_product_date                 => l_start_date,
							               p_pdt_parameter_rec            => lx_pdt_parameter_rec);

    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        -- Error getting financial product parameters for contract CONTRACT_NUMBER.
        OKC_API.set_message(  p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_AM_FIN_PROD_PARAM_ERR',
                           p_token1        =>  'CONTRACT_NUMBER',
                           p_token1_value  =>  l_contract_number);

    ELSE

        l_reporting_product := lx_pdt_parameter_rec.reporting_product;
        l_reporting_product_id := lx_pdt_parameter_rec.reporting_pdt_id;

        IF l_reporting_product IS NOT NULL AND l_reporting_product <> OKC_API.G_MISS_CHAR THEN
            -- Contract has a reporting product
            x_rep_product_id :=  l_reporting_product_id;
        END IF;
    END IF;
  EXCEPTION
      --WHEN mg_error THEN
      --   IF l_get_fin_product%ISOPEN THEN
      --      CLOSE l_get_fin_product;
      --   END IF;
      --   x_return_status := OKL_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
         IF l_get_fin_product%ISOPEN THEN
            CLOSE l_get_fin_product;
         END IF;
         OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END get_reporting_product;


------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    Roman.Draguilev@oracle.com - 24-APR-2002
  -- Function Name: line_unearned_income
  -- Description:   Returns the unearned income amount for a given contract line
  -- Dependencies:  OKL building blocks AMTX and AMUV
  -- Parameters:    IN:  p_contract_id, p_line_id
  --                     stream_type_id (stored in g_additional_parameters(1))
  --                OUT: amount
  -- Version:       1.0
  --                SECHAWLA 05-MAY-04 3578894 : Modified to accomodate additional parameters for reporting product
  --              : 31-Dec-2004 PAGARG Bug# 4097591
  --              : UDS impact to obtain stream type id
  --                sechawla 05-dec-07 6671849 : Modified the dependent stream type check
  -- End of Commnets
------------------------------------------------------------------------------
FUNCTION line_unearned_income (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS

        l_unearned_income       NUMBER  := 0;
        --Code changed by rvaduri for bug 3536862
        --This code will return the Pre-tax income at line level
        -- and will return values only contracts booked using ISG.
    --PAGARG 31-Dec-2004 Bug# 4097591
    --Instead of using stream name, join the sty id passed to cursor
    CURSOR line_csr (c_contract_line_id NUMBER, p_sty_id NUMBER) IS
      SELECT NVL(SUM(sel.amount),0)
      FROM okl_strm_elements sel,
           okl_streams stm,
           okl_strm_type_v sty
      WHERE sty.id = p_sty_id
        AND stm.sty_id = sty.id
        AND stm.say_code = 'CURR'
        AND stm.active_yn = 'Y'
        AND stm.purpose_code IS NULL
        AND stm.kle_id = c_contract_line_id
        AND sel.stm_id = stm.id;

    --SECHAWLA 05-MAY-04 3578894 : new declarations
    l_rep_prod_streams_yn   VARCHAR2(1) := 'N';
    l_trx_date   DATE;

    -- SECHAWLA 05-MAY-04 3578894 : Created this cursor to evaluat ereporting streams based upon additional parameters
    --PAGARG 31-Dec-2004 Bug# 4097591
    --Instead of using stream name, join the sty id passed to cursor
    CURSOR line_reporting_csr (c_contract_line_id IN NUMBER, cp_trx_date IN DATE, p_sty_id NUMBER) IS
      SELECT NVL(SUM(sel.amount),0)
      FROM okl_strm_elements sel,
           okl_streams stm,
           okl_strm_type_v sty
      WHERE sty.id = p_sty_id
        AND stm.sty_id = sty.id
        AND stm.say_code = 'CURR' -- reporting streams are current
        AND stm.active_yn = 'N'  -- reporting strems are inactive
        AND stm.purpose_code IS NULL
        AND	sel.date_billed	IS NULL  -- reporting streams never get billed
        --AND sty.billable_yn     = 'N'  -- PRE-TAX streams are not billable
        AND stm.kle_id = c_contract_line_id
        AND sel.stm_id = stm.id
        AND stm.purpose_code = 'REPORT'
        AND sel.STREAM_ELEMENT_DATE > cp_trx_date;

	l_stream_type_id	NUMBER;
	l_return_status     VARCHAR2(3) := Okl_Api.G_RET_STS_SUCCESS;

	-- sechawla 05-dec-07 6057301 - Added
	lx_rep_product_id           OKL_PRODUCTS_V.ID%TYPE;
    l_api_version               NUMBER := 1;
    l_init_msg_list             VARCHAR2(1) := OKL_API.G_FALSE;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(100);
BEGIN
    -- SECHAWLA 05-MAY-04 3578894 : Validate additional parameters availability
    IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'REP_PRODUCT_STRMS_YN'
           AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_rep_prod_streams_yn := okl_execute_formula_pub.g_additional_parameters(I).value;
        ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'OFF_LSE_TRX_DATE'
           AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_trx_date := TO_DATE(okl_execute_formula_pub.g_additional_parameters(I).value, 'MM/DD/YYYY');
        END IF;
      END LOOP;
	ELSE

      l_rep_prod_streams_yn := 'N';

	END IF;

    -- sechawla 05-dec-07 6671849 : START
	IF l_rep_prod_streams_yn = 'Y' THEN

	      get_reporting_product(
                                  p_api_version           => l_api_version,
           		 	              p_init_msg_list         => OKC_API.G_FALSE,
           			              x_return_status         => l_return_status,
           			              x_msg_count             => l_msg_count,
           			              x_msg_data              => l_msg_data,
                                  p_contract_id 		  => p_contract_id,
                                  x_rep_product_id        => lx_rep_product_id);


          OKL_STREAMS_UTIL.get_dependent_stream_type(p_khr_id            => p_contract_id,
                                               p_product_id            => lx_rep_product_id,
                                               p_primary_sty_purpose   => 'RENT',
                                               p_dependent_sty_purpose => 'LEASE_INCOME',
                                               x_return_status         => l_return_status,
                                               x_dependent_sty_id      => l_stream_type_id);
     ELSE
     -- sechawla 05-dec-07 6671849 : END

        --PAGARG 31-Dec-2004 Bug# 4097591 Start
        --UDS impact. Obtain stream type id and pass it to cursor
         OKL_STREAMS_UTIL.get_dependent_stream_type(p_khr_id                => p_contract_id,
                                               p_primary_sty_purpose   => 'RENT',
                                               p_dependent_sty_purpose => 'LEASE_INCOME',
                                               x_return_status         => l_return_status,
                                               x_dependent_sty_id      => l_stream_type_id);

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         --PAGARG 31-Dec-2004 Bug# 4097591 End

    END IF; -- sechawla 05-dec-07 6671849 : added

    IF l_rep_prod_streams_yn = 'Y' THEN
       IF l_trx_date IS NULL THEN
       -- Can not calculate Net Investment for the reporting product as the transaction date is missing.
          Okl_Api.Set_Message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AM_AMORT_NO_TRX_DATE');
          RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;
    END IF;

    --SECHAWLA 05-MAY-04 3578894 : check if streams required for reporting  product
    IF l_rep_prod_streams_yn = 'Y' THEN
       --PAGARG 31-Dec-2004 Bug# 4097591, Pass stream type id to cursor
       OPEN  line_reporting_csr(p_contract_line_id, l_trx_date, l_stream_type_id);
       FETCH line_reporting_csr INTO l_unearned_income;
	   CLOSE line_reporting_csr;
    ELSE
    -- SECHAWLA 05-MAY-04 3578894 : end new code
       --PAGARG 31-Dec-2004 Bug# 4097591, Pass stream type id to cursor
	   OPEN  line_csr(p_contract_line_id, l_stream_type_id);
	   FETCH line_csr INTO l_unearned_income;
	   CLOSE line_csr;
    END IF;

        --Code commented by rvaduri.
/*
	OPEN	l_str_type_csr ('UNEARNED INCOME');
	FETCH	l_str_type_csr INTO l_stream_type_id;
	CLOSE	l_str_type_csr;

	okl_execute_formula_pub.g_additional_parameters(1).name  := 'STREAM TYPE';
	okl_execute_formula_pub.g_additional_parameters(1).value := l_stream_type_id;

	l_result_amount	:= line_unbilled_streams (p_contract_id, p_contract_line_id);

	RETURN NVL (l_result_amount, 0);
*/
        RETURN NVL(l_unearned_income,0);

EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        IF line_csr%ISOPEN THEN
			CLOSE line_csr;
		END IF;

        IF line_reporting_csr%ISOPEN THEN
            CLOSE line_reporting_csr;
        END IF;

        RETURN NULL;

	WHEN OTHERS THEN

		-- Close open cursors

		IF line_csr%ISOPEN THEN
			CLOSE line_csr;
		END IF;

        IF line_reporting_csr%ISOPEN THEN
            CLOSE line_reporting_csr;
        END IF;

		-- store SQL error message on message stack for caller

		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_CONTRACTS_UNEXPECTED_ERROR',
			p_token1	=> 'SQLCODE',
			p_token1_value	=> SQLCODE,
			p_token2	=> 'SQLERRM',
			p_token2_value	=> SQLERRM);

		RETURN NULL;

END line_unearned_income;


------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    Daypesh.Patel@oracle.com - 24-APR-2002
  -- Function Name: line_calculate_fmv
  -- Description:   Returns the fair market value for a given contract line
  --                using an hook to an external system.
  --                Just a shell for now
  -- Dependencies:
  -- Parameters:    IN:  p_contract_id, p_line_id
  --                OUT: amount
  -- Version:       1.0
  -- End of Commnets
------------------------------------------------------------------------------

FUNCTION line_calculate_fmv (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS
BEGIN
	RETURN 0;
END line_calculate_fmv;

------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    Daypesh.Patel@oracle.com - 24-APR-2002
  -- Function Name: line_calculate_residual_value
  -- Description:   Returns the residual value for a given contract line
  --                using an hook to an external system.
  --                Just a shell for now
  -- Dependencies:
  -- Parameters:    IN:  p_contract_id, p_line_id
  --                OUT: amount
  -- Version:       1.0
  -- End of Commnets
------------------------------------------------------------------------------

FUNCTION line_calculate_residual_value (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS
BEGIN
	RETURN 0;
END line_calculate_residual_value;

---------------------------------------------
-- CS Functions
---------------------------------------------

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ranu Srivastava (rsrivast)
    -- Function Name  contract_security_deposit
    -- Description:   returns the security deposit for given contract
    -- Dependencies:
    -- Parameters: contract id,contract line id
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------

FUNCTION contract_security_deposit( p_contract_id           IN  NUMBER
                                   ,p_contract_line_id      IN NUMBER) RETURN NUMBER
    IS
  l_security_deposit NUMBER := 0;

-- select changed to filter streams based on purpose instead of on type
-- enhancement done for user defined streams impacts, bug 3924303

  CURSOR C (p_contract_id  NUMBER)
  IS
   SELECT NVL(SUM(sele.amount),0)
         FROM okl_strm_elements sele,
           okl_streams str,
           okl_strm_type_v sty
      WHERE sele.stm_id = str.id
           AND str.sty_id = sty.id
           AND UPPER(sty.stream_type_purpose) = 'SECURITY_DEPOSIT'
           AND str.say_code = 'CURR'
	   --multigaap changes
           AND STR.ACTIVE_YN = 'Y'
           AND STR.PURPOSE_CODE IS NULL
	   --end multigaap changes
           AND str.khr_id = p_contract_id;

BEGIN

  OPEN C (p_contract_id);
  FETCH C INTO l_security_deposit;
  CLOSE C;

  RETURN l_security_deposit;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ranu Srivastava (rsrivast)
    -- Function Name  contract_residual_amount
    -- Description:   returns the residual value for given contract
    -- Dependencies:
    -- Parameters: contract id,contract line id
    -- Version: 1.0
    -- 20-Dec-02 rsrivast Added new cursor line to calculate contract residual amount for line
    -- 27-Oct-04 PAGARG bug# 3974997 -- check for G_MISS when checking for NULL
    -- End of Commnets
----------------------------------------------------------------------------------------------------

FUNCTION contract_residual_amount( p_contract_id           IN  NUMBER
                                 ,p_contract_line_id      IN NUMBER) RETURN NUMBER
    IS
  l_residual_value NUMBER := 0;

  CURSOR C (p_contract_id  NUMBER)

  IS
           SELECT NVL(SUM(RESIDUAL_VALUE),0)
           FROM  okl_k_lines_full_v
           WHERE dnz_chr_id= p_contract_id
           AND sts_code <> 'TERMINATED';

 --Commented this code by rvaduri for bug 3487920
  /*
 SELECT NVL(SUM(cs.amount),0)
 FROM okl_streams_v asv,okl_strm_type_v bs,
 okl_strm_elements_v cs,
 okl_streams str,
 okl_strm_type_v sty
 WHERE cs.stm_id = asv.id AND bs.id = asv.sty_id
 AND str.sty_id = sty.id
 AND UPPER(sty.name) = 'RESIDUAL VALUE'
 AND str.say_code = 'CURR'
 --multigaap changes
 AND STR.ACTIVE_YN = 'Y'
 AND STR.PURPOSE_CODE is NULL --end multigaap changes AND
 cs.stream_element_date >= SYSDATE AND
 asv.khr_id = p_contract_id; */

    CURSOR line(p_contract_line_id   NUMBER)
    IS
    SELECT NVL(RESIDUAL_VALUE,0)
    FROM okl_k_lines
    WHERE id = p_contract_line_id;


BEGIN
  IF p_contract_line_id IS NOT NULL
  AND p_contract_line_id <> OKL_API.G_MISS_NUM THEN -- PAGARG bug#3974997 -- check for G_MISS when checking for NULL
    OPEN line (p_contract_line_id);
    FETCH line INTO l_residual_value;
    CLOSE line;
  ELSE
    OPEN C (p_contract_id);
    FETCH C INTO l_residual_value;
    CLOSE C;
  END IF;
  RETURN l_residual_value;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ranu Srivastava (rsrivast)
    -- Function Name  contract_Rent_amount
    -- Description:   returns the rent amount for given contract
    -- Dependencies:
    -- Parameters: contract id,contract line id
    -- Version: 1.0
    -- 20-Dec-02 rsrivast Added new cursor line to calculate contract rent amount for line
    -- 27-Oct-04 PAGARG bug# 3974997 -- check for G_MISS when checking for NULL
    -- 04-dec-08 sechawla : Updated curosr 'line', to query for stream type purpsoe instead of stream type,
    --	                        added p_contract_id parameter to cursor 'line'
    -- End of Commnets
----------------------------------------------------------------------------------------------------

FUNCTION contract_rent_amount( p_contract_id           IN  NUMBER
                              ,p_contract_line_id      IN NUMBER) RETURN NUMBER
    IS
  l_rent_amount NUMBER := 0;

  --Get all the future unbilled receivables for the contract.

 -- select changed to filter streams based on purpose instead of on name
 -- enhancement done for user defined streams impacts, bug 3924303

  CURSOR C (p_contract_id  NUMBER)
  IS
  SELECT NVL(SUM(sele.amount),0)
  FROM okl_strm_elements sele,
           okl_streams str,
           okl_strm_type_v sty
      WHERE sele.stm_id = str.id
           AND str.sty_id = sty.id
           AND UPPER(sty.stream_type_purpose) = 'RENT'
           AND str.say_code = 'CURR'
           AND STR.ACTIVE_YN = 'Y'
           AND STR.PURPOSE_CODE IS NULL
           AND SELE.DATE_BILLED IS NULL
           AND SELE.STREAM_ELEMENT_DATE > SYSDATE
           AND str.khr_id = p_contract_id;


  --Get all the future unbilled receivables for the line.
  CURSOR line (p_contract_id NUMBER, p_contract_line_id NUMBER)  IS --sechawla 04-dec-08 : added p_contract_id
  SELECT NVL(SUM(sele.amount),0)
  FROM okl_strm_elements sele,
           okl_streams str,
           okl_strm_type_v sty
      WHERE sele.stm_id = str.id
           AND str.sty_id = sty.id
           --AND UPPER(sty.name) = 'RENT' --sechawla 04-dec-08 : remoevd
           AND UPPER(sty.stream_type_purpose) = 'RENT' --sechawla 04-dec-08 : added
           AND str.say_code = 'CURR'
           AND STR.ACTIVE_YN = 'Y'
           AND STR.PURPOSE_CODE IS NULL
           AND SELE.DATE_BILLED IS NULL
           AND SELE.STREAM_ELEMENT_DATE > SYSDATE
           AND str.khr_id = p_contract_id --sechawla 04-dec-08 : added
           AND str.kle_id = p_contract_line_id;
BEGIN
  IF p_contract_line_id IS NOT NULL
  AND p_contract_line_id <> OKL_API.G_MISS_NUM THEN -- PAGARG bug# 3974997 -- check for G_MISS when checking for NULL
    OPEN line (p_contract_id, p_contract_line_id); --sechawla 04-dec-08 : added p_contract_id
    FETCH line INTO l_rent_amount;
    CLOSE line;
  ELSE
    OPEN C (p_contract_id);
    FETCH C INTO l_rent_amount;
    CLOSE C;
  END IF;
  RETURN l_rent_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ranu Srivastava (rsrivast)
    -- Function Name  contract_unearned_income
    -- Description:   returns the security deposit for given contract
    -- Dependencies:
    -- Parameters: contract id,contract line id
    -- Version: 1.0
    -- 20-Dec-02 rsrivast Added new cursor line to calculate contract unearned income for line
    -- 27-Oct-04 PAGARG bug# 3974997 -- check for G_MISS when checking for NULL
    -- End of Commnets
----------------------------------------------------------------------------------------------------

FUNCTION contract_unearned_income( p_contract_id IN  NUMBER
                                  ,p_contract_line_id      IN NUMBER) RETURN NUMBER
    IS
  l_unearned_income NUMBER := 0;

  -- select changed to filter streams based on purpose 'LEASE_INCOME' instead of on type
  -- 'PRE-TAX INCOME', changes done for user defined streams impacts, bug 3924303

  CURSOR C (p_contract_id  NUMBER)
  IS
  SELECT NVL(SUM(sele.amount),0)
  FROM okl_strm_elements sele,
           --okl_streams str,  MGAAP 7263041
           okl_streams_rep_v str,
           okl_strm_type_v sty
      WHERE sele.stm_id = str.id
           AND str.sty_id = sty.id
           AND UPPER(sty.stream_type_purpose) = 'LEASE_INCOME'
           AND str.say_code = 'CURR'
           AND STR.ACTIVE_YN = 'Y'
           AND (STR.PURPOSE_CODE IS NULL OR STR.PURPOSE_CODE='REPORT')
           AND (sele.accrued_yn IS NULL OR sele.accrued_yn = 'N')
           AND SELE.STREAM_ELEMENT_DATE > SYSDATE
           AND str.khr_id = p_contract_id;

  --Commented by rvaduri for bug 3536862
/*
   SELECT NVL(SUM(sele.amount),0)
         FROM okl_strm_elements sele,
           okl_streams str,
           okl_strm_type_v sty
      WHERE sele.stm_id = str.id
           AND str.sty_id = sty.id
           AND UPPER(sty.name) = 'UNEARNED INCOME'
           AND str.say_code = 'CURR'
	   --multigaap changes
           AND STR.ACTIVE_YN = 'Y'
           AND STR.PURPOSE_CODE IS NULL
	   --end multigaap changes
           AND str.khr_id = p_contract_id;
*/

    CURSOR line (p_contract_line_id      NUMBER) IS
  SELECT NVL(SUM(sele.amount),0)
  FROM okl_strm_elements sele,
           --okl_streams str,  MGAAP 7263041
           okl_streams_rep_v str,
           okl_strm_type_v sty
      WHERE sele.stm_id = str.id
           AND str.sty_id = sty.id
           AND UPPER(sty.name) = 'PRE-TAX INCOME'
           AND str.say_code = 'CURR'
           AND STR.ACTIVE_YN = 'Y'
           AND STR.PURPOSE_CODE IS NULL
           AND (sele.accrued_yn IS NULL OR sele.accrued_yn = 'N')
           AND SELE.STREAM_ELEMENT_DATE > SYSDATE
           AND str.kle_id = p_contract_line_id;
  --Commented by rvaduri for bug 3536862
/*
 *
      SELECT NVL(SUM(sel.amount),0)
      FROM okl_strm_elements sel,
           okl_streams stm,
           okl_strm_type_v sty
      WHERE sty.name = 'PRE-TAX INCOME'
        AND stm.sty_id = sty.id
        AND stm.say_code = 'CURR'
        AND stm.active_yn = 'Y'
        AND stm.kle_id = p_contract_line_id
        AND sel.stm_id = stm.id
        AND sel.stream_element_date > SYSDATE;
*/

BEGIN
  IF p_contract_line_id IS NOT NULL
  AND p_contract_line_id <> OKL_API.G_MISS_NUM THEN -- PAGARG bug# 3974997 -- check for G_MISS when checking for NULL
    OPEN line (p_contract_line_id);
    FETCH line INTO l_unearned_income;
    CLOSE line;
  ELSE
    OPEN C (p_contract_id);
    FETCH C INTO l_unearned_income;
    CLOSE C;
  END IF;
  RETURN l_unearned_income;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ranu Srivastava (rsrivast)
    -- Function Name  contract_depriciation_amount
    -- Description:   returns the depriciation amount for given contract
    -- Dependencies:
    -- Parameters: contract id,contract line id
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------

FUNCTION contract_depriciation_amount( p_contract_id IN  NUMBER
                                      ,p_contract_line_id      IN NUMBER) RETURN NUMBER
    IS
/** NOTE: This Function is exactly the same as contract_acc_depreciation,
 * since the existing function code was wrong. Changed the code in pls
 * instead of changing the formula to use a different operand due to
 * operational issues of following up for getting the new operand seeded
 * Done for bug 3646679 */


        l_unearned_income NUMBER := 0;
        l_depreciation NUMBER := 0;
        l_depn_contract NUMBER := 0;
        l_converted_amount NUMBER := 0;
        p_return_status VARCHAR2(1);
        p_contract_start_date DATE;
        p_contract_currency             okl_k_headers_full_v.currency_code%TYPE;
        p_currency_conversion_type     okl_k_headers_full_v.currency_conversion_type%TYPE;
        p_currency_conversion_rate     okl_k_headers_full_v.currency_conversion_rate%TYPE;
        p_currency_conversion_date     okl_k_headers_full_v.currency_conversion_date%TYPE;

   --Cursor to get the parent line id for a contract
  CURSOR parent_line_id_csr (p_contract_id  NUMBER)
  IS
   SELECT line.id parent_line_id
    FROM okc_k_lines_b line
     ,okc_line_styles_v lse
    WHERE line.lse_id=lse.id
        AND lse.lty_code= 'FREE_FORM1'
        AND line.sts_code <> 'ABANDONED'
        AND dnz_chr_id = p_contract_id;


 -- line asset id and corporate book from FA
 CURSOR asset_details_csr(p_contract_line_id  NUMBER)
 IS
 SELECT CORPORATE_BOOK, ASSET_ID
 FROM OKX_ASSET_LINES_V
 WHERE OKX_ASSET_LINES_V.PARENT_LINE_ID = p_contract_line_id;

 -- total depreciation for the corporate book from FA
 CURSOR deprn_details_csr(p_asset_id  NUMBER, p_corporate_book_code VARCHAR2)
 IS
 SELECT NVL(SUM(deprn_amount), 0) deprn_amount
 FROM   OKX_AST_DPRTNS_V
 WHERE  Asset_id = p_asset_id
 AND    book_type_code = p_corporate_book_code
 AND    status = 'A'
 AND    NVL(start_date_active,SYSDATE) <= SYSDATE
 AND    NVL(end_date_active,SYSDATE + 1) > SYSDATE;


 -- contract start date
 CURSOR contract_start_date_csr(p_khr_id NUMBER)
 IS
 SELECT start_date FROM okc_k_headers_b
 WHERE id = p_khr_id;

 l_streams_repo_policy VARCHAR2(80); -- MGAAP 7263041

BEGIN

  l_streams_repo_policy := OKL_STREAMS_SEC_PVT.GET_STREAMS_POLICY;

  -- calculate asset line level depreciation
  IF(p_contract_line_id IS NOT NULL) THEN
   FOR p_asset_details_csr IN asset_details_csr(p_contract_line_id)
   LOOP
        FOR p_deprn_details_csr IN deprn_details_csr(p_asset_details_csr.ASSET_ID,
                                                p_asset_details_csr.CORPORATE_BOOK)
        LOOP
                l_depreciation := p_deprn_details_csr.deprn_amount;
        END LOOP;

   END LOOP;


   -- convert amount into contract currency
   OPEN contract_start_date_csr(p_contract_id);
   FETCH contract_start_date_csr INTO p_contract_start_date;
   CLOSE contract_start_date_csr;

   okl_accounting_util.convert_to_contract_currency(
                                p_khr_id  => p_contract_id,
                                p_from_currency  => NULL,
                                p_transaction_date => p_contract_start_date,
                                p_amount => l_depreciation,
                                x_return_status => p_return_status,
                                x_contract_currency => p_contract_currency,
                                x_currency_conversion_type => p_currency_conversion_type,
                                x_currency_conversion_rate => p_currency_conversion_rate,
                                x_currency_conversion_date => p_currency_conversion_date,
                                x_converted_amount => l_converted_amount);

   IF(p_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
           Okl_Api.Set_Message(p_app_name     => Okl_Api.G_APP_NAME,
                               p_msg_name     => 'OKL_CONV_TO_FUNC_CURRENCY_FAIL');
           RAISE Okl_Api.G_EXCEPTION_ERROR;
   END IF;

   RETURN l_converted_amount;

  ELSE
  FOR p_parent_line_id_csr  IN parent_line_id_csr(p_contract_id) LOOP
     --Get the Parent_line_id based on the contract id
   FOR p_asset_details_csr IN asset_details_csr(p_parent_line_id_csr.parent_line_id)
   LOOP
        FOR p_deprn_details_csr IN deprn_details_csr(p_asset_details_csr.ASSET_ID,
                                                        p_asset_details_csr.CORPORATE_BOOK)
        LOOP
                --Depreciation Amount from FA
                l_depreciation := p_deprn_details_csr.deprn_amount;
        END LOOP;
   END LOOP;
   l_depn_contract := l_depn_contract + l_depreciation;
  END LOOP;
   -- convert amount into contract currency
   OPEN contract_start_date_csr(p_contract_id);
   FETCH contract_start_date_csr INTO p_contract_start_date;
   CLOSE contract_start_date_csr;

   okl_accounting_util.convert_to_contract_currency(
                                p_khr_id  => p_contract_id,
                                p_from_currency  => NULL,
                                p_transaction_date => p_contract_start_date,
                                p_amount => l_depn_contract,
                                x_return_status => p_return_status,
                                x_contract_currency => p_contract_currency,
                                x_currency_conversion_type => p_currency_conversion_type,
                                x_currency_conversion_rate => p_currency_conversion_rate,
                                x_currency_conversion_date => p_currency_conversion_date,
                                x_converted_amount => l_converted_amount);

   IF(p_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
           Okl_Api.Set_Message(p_app_name     => Okl_Api.G_APP_NAME,
                               p_msg_name     => 'OKL_CONV_TO_FUNC_CURRENCY_FAIL');
           RAISE Okl_Api.G_EXCEPTION_ERROR;
   END IF;
   RETURN l_converted_amount;

  END IF;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        RETURN 0;

    WHEN OTHERS THEN
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END contract_depriciation_amount;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ranu Srivastava (rsrivast)
    -- Function Name  contract_principal_amount
    -- Description:   returns the Principal amount for given contract
    -- Dependencies:
    -- Parameters: contract id,contract line id
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------

FUNCTION contract_principal_amount( p_contract_id           IN  NUMBER

                                 ,p_contract_line_id      IN NUMBER) RETURN NUMBER
    IS
  l_amount NUMBER := 0;

/*
  CURSOR c (p_contract_id  NUMBER)
  IS
   SELECT NVL(cs.amount,0)
   FROM okl_streams_v asv,okl_strm_type_v bs,
        okl_strm_elements_v cs,
        okl_streams str,
        okl_strm_type_v sty,
	okc_k_headers_v okh
   WHERE cs.stm_id = asv.id AND bs.id = asv.sty_id
     AND str.sty_id = sty.id
     AND UPPER(sty.name) = 'PRINCIPAL BALANCE'
     AND str.say_code = 'CURR'
   --multigaap changes
     AND STR.ACTIVE_YN = 'Y'
     AND STR.PURPOSE_CODE is NULL
   --end multigaap changes
     AND cs.stream_element_date >= SYSDATE
	 AND  cs.stream_element_date BETWEEN okh.start_date AND okh.end_date
	 AND asv.khr_id = okh.id
	 AND asv.khr_id =  p_contract_id;
*/
-- query changed to filter streams based on purpose instead of on type
-- changes done for user defined streams impacts, bug 3924303

  CURSOR C (p_contract_id  NUMBER)
  IS
    --It should be sum because we have to get the Principal balance on
    -- all the assets for the contract
      SELECT NVL(SUM(sel.amount),0)
      FROM okl_strm_elements sel,
           okl_streams stm,
           okl_strm_type_v sty
      WHERE sty.stream_type_purpose = 'PRINCIPAL_BALANCE'
        AND stm.sty_id = sty.id
        AND stm.say_code = 'CURR'
        AND stm.active_yn = 'Y'
        AND stm.purpose_code IS NULL
        AND stm.khr_id = p_contract_id
        AND sel.stm_id = stm.id
        AND sel.stream_element_date =
                   ( SELECT NVL(MAX(sel.stream_element_date), SYSDATE)
                     FROM okl_strm_elements sel,okl_streams stm,
                          okl_strm_type_v sty
                     WHERE sty.stream_type_purpose = 'PRINCIPAL_BALANCE'
                       AND stm.sty_id = sty.id
                       AND stm.say_code = 'CURR'
                       AND stm.active_yn = 'Y'
                       AND stm.purpose_code IS NULL
                       AND stm.khr_id = p_contract_id
                       AND sel.stm_id = stm.id
                       AND sel.stream_element_date <= SYSDATE);
BEGIN

  OPEN C (p_contract_id);
  FETCH C INTO l_amount;
  CLOSE C;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;

--rkraya added
----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Reeshma Kuttiyat (rkuttiya/rkraya)
    -- Function Name:   Unpaid Invoices
    -- Description:     Function returns the sum of unpaid invoices for the asset line
    -- Dependencies:
    -- Parameters: contract id,contract line id
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------

FUNCTION unpaid_invoices( p_contract_id           IN  NUMBER
                         ,p_contract_line_id      IN NUMBER) RETURN NUMBER
    IS
  l_unpaid_inv   NUMBER := 0;
  CURSOR c_unpaid_inv(p_contract_line_id IN NUMBER) IS
  SELECT SUM(APS.AMOUNT_DUE_REMAINING)
  FROM
  AR_PAYMENT_SCHEDULES_ALL APS,
/*
  16-Aug-2007, ankushar Bug# 5499193
  start changes, modified the cursor to replace reference to okl_cnsld_ar_strms_b
 */
  okl_bpd_tld_ar_lines_v LSM,
--  OKC_K_HEADERS_B CHR, commenting unused table, ankushar Bug# 5499193
/* 16-Aug-2007 ankushar end changes */
  OKC_K_LINES_B CLE,
  OKC_LINE_STYLES_B LSE
  WHERE
  LSM.KLE_ID = p_contract_line_id
  AND LSM.CUSTOMER_TRX_ID = APS.CUSTOMER_TRX_ID
  AND APS.STATUS = 'OP'
  AND APS.CLASS IN ('INV')
  AND LSM.KLE_ID = CLE.CLE_ID
  AND CLE.LSE_ID = LSE.ID
  AND LSE.LTY_CODE = 'FIXED_ASSET';

BEGIN

  OPEN c_unpaid_inv (p_contract_line_id);
  FETCH c_unpaid_inv INTO l_unpaid_inv;
  CLOSE c_unpaid_inv;

  RETURN l_unpaid_inv;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Reeshma Kuttiyat (rkuttiya/rkraya)
    -- Function Name:   Unapplied Credit Memos
    -- Description:     Function returns the sum of unapplied credit memos for the asset line
    -- Dependencies:
    -- Parameters: contract id,contract line id
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------

 FUNCTION unapplied_credit_memos( p_contract_id           IN  NUMBER
                                ,p_contract_line_id      IN NUMBER) RETURN NUMBER
  IS

  l_unapplied_credit  NUMBER :=0;
  CURSOR c_unapplied_credit(p_contract_line_id IN NUMBER) IS
  SELECT SUM(APS.AMOUNT_DUE_REMAINING)
  FROM
  AR_PAYMENT_SCHEDULES_ALL APS,
/*
  16-Aug-2007, ankushar Bug# 5499193
  start changes, modified the cursor to replace reference to okl_cnsld_ar_strms_b
 */
  okl_bpd_tld_ar_lines_v LSM,
--  OKC_K_HEADERS_B CHR, commenting unused table, ankushar Bug# 5499193
/* 16-Aug-2007 ankushar end changes */
  OKC_K_LINES_B CLE,
  OKC_LINE_STYLES_B LSE
  WHERE
  LSM.KLE_ID = p_contract_line_id
  AND LSM.CUSTOMER_TRX_ID = APS.CUSTOMER_TRX_ID
  AND APS.STATUS = 'OP'
  AND APS.CLASS IN ('CM')
  AND LSM.KLE_ID = CLE.CLE_ID
  AND CLE.LSE_ID = LSE.ID
  AND LSE.LTY_CODE = 'FIXED_ASSET';

BEGIN

  OPEN c_unapplied_credit(p_contract_line_id);
  FETCH c_unapplied_credit INTO l_unapplied_credit;
  CLOSE c_unapplied_credit;

  l_unapplied_credit := 0 - l_unapplied_credit;

  RETURN l_unapplied_credit;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;


----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ravikumar Vaduri
    -- Function Name  contract_prin_balance
    -- Description:   returns the Principal balance for given contract
    -- Dependencies:
    -- Parameters: contract id,contract line id
    --  the parameter Contract line id is not used for anything.
    -- Version: 1.0
    -- 20-Dec-02 rsrivast Added new cursor line to calculate contract principal balance for line
    -- 01-Dec-04 rmunjulu Modified to get quote id and from that the quote eff from date and use that
    -- End of Commnets

----------------------------------------------------------------------------------------------------
FUNCTION contract_prin_balance( p_contract_id           IN  NUMBER
                                 ,p_contract_line_id      IN NUMBER) RETURN NUMBER

IS
-- select changed to filter streams based on purpose instead of on type
-- enhancement done for user defined streams impacts, bug 3924303

  CURSOR C (p_contract_id  NUMBER, p_date DATE) -- rmunjulu EDAT
  IS
    --It should be sum because we have to get the Principal balance on
    -- all the assets for the contract
      SELECT NVL(SUM(sel.amount),0)
      FROM okl_strm_elements sel,
           okl_streams stm,
           okl_strm_type_v sty
      WHERE sty.stream_type_purpose = 'PRINCIPAL_BALANCE'
        AND stm.sty_id = sty.id
        AND stm.say_code = 'CURR'
        AND stm.active_yn = 'Y'
        AND stm.purpose_code IS NULL
        AND stm.khr_id = p_contract_id
        AND sel.stm_id = stm.id
        AND sel.stream_element_date =
                   ( SELECT NVL(MAX(sel.stream_element_date), SYSDATE)
                     FROM okl_strm_elements sel,okl_streams stm,
                          okl_strm_type_v sty
                     WHERE sty.stream_type_purpose = 'PRINCIPAL_BALANCE'
                       AND stm.sty_id = sty.id
                       AND stm.say_code = 'CURR'
                       AND stm.active_yn = 'Y'
                       AND stm.purpose_code IS NULL
                       AND stm.khr_id = p_contract_id
                       AND sel.stm_id = stm.id
                       AND sel.stream_element_date <= p_date); -- rmunjulu EDAT

-- select changed to filter streams based on purpose instead of on type
-- enhancement done for user defined streams impacts, bug 3924303

     CURSOR line (p_contract_line_id NUMBER, p_date DATE) IS
      SELECT NVL(sel.amount,0)
      FROM okl_strm_elements sel,
           okl_streams stm,
           okl_strm_type_v sty
      WHERE sty.stream_type_purpose = 'PRINCIPAL_BALANCE'
        AND stm.sty_id = sty.id
        AND stm.say_code = 'CURR'
        AND stm.active_yn = 'Y'
        AND stm.purpose_code IS NULL
        AND stm.kle_id = p_contract_line_id
        AND sel.stm_id = stm.id
        AND sel.stream_element_date =
                   ( SELECT NVL(MAX(sel.stream_element_date), SYSDATE)
                     FROM okl_strm_elements sel,okl_streams stm,
                          okl_strm_type_v sty
                     WHERE sty.stream_type_purpose = 'PRINCIPAL_BALANCE'
                       AND stm.sty_id = sty.id
                       AND stm.say_code = 'CURR'
                       AND stm.active_yn = 'Y'
                       AND stm.kle_id = p_contract_line_id
                       AND stm.purpose_code IS NULL
                       AND sel.stm_id = stm.id
                       AND sel.stream_element_date <= p_date); -- rmunjulu EDAT

    l_principal_balance NUMBER;

        -- rmunjulu EDAT
        CURSOR get_quote_date_csr (p_quote_id IN NUMBER) IS
        SELECT trunc(qte.date_effective_from) date_effective_from
        FROM   okl_trx_quotes_b  qte
        WHERE  qte.id = p_quote_id;

		-- rmunjulu EDAT
        l_quote_id NUMBER;
        l_quote_date DATE;
        l_sysdate DATE;

BEGIN

  -- rmunjulu EDAT  Get additional parameter if found
  IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        -- rmunjulu EDAT -- get quote id
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'quote_id' THEN
          l_quote_id := OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE;
        END IF;
      END LOOP;
  END IF;

  -- rmunjulu EDAT
  SELECT SYSDATE INTO l_sysdate FROM dual;

  -- rmunjulu EDAT  -- get eff date for quote
  IF  l_quote_id IS NOT NULL
  AND l_quote_id <> OKL_API.G_MISS_NUM THEN

	   FOR get_quote_date_rec IN get_quote_date_csr (l_quote_id) LOOP
	      l_quote_date := get_quote_date_rec.date_effective_from;
	   END LOOP;

  END IF;

  -- rmunjulu EDAT Default the l_quote_date to sysdate if quote id not found
  IF l_quote_date IS NULL
  OR l_quote_date = OKL_API.G_MISS_DATE THEN
       l_quote_date := l_sysdate;
  END IF;

  IF p_contract_line_id IS NOT NULL THEN
    OPEN line (p_contract_line_id, l_quote_date); -- rmunjulu EDAT
    FETCH line INTO l_principal_balance;
    CLOSE line;
  ELSE

    OPEN C(p_contract_id, l_quote_date); -- rmunjulu EDAT
    FETCH C INTO l_principal_balance;
    CLOSE C;

  END IF;

  RETURN l_principal_balance;
END contract_prin_balance;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Sridhar Moduga
    -- Function Name  get_asset_subsidy_amount
    -- Description:   returns the asset subsidy amount for given contract
    -- Dependencies:
    -- Parameters: contract id,accounting method
    --
    -- Version: 1.0
    --
    -- End of Comments

----------------------------------------------------------------------------------------------------
FUNCTION get_asset_subsidy_amount(
    p_contract_id                 IN  NUMBER,
    p_accounting_method           IN  VARCHAR2)
RETURN NUMBER IS

    lx_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     VARCHAR2(30) := 'GET_ASSET_SUBSIDY';
    l_api_version          CONSTANT     NUMBER := 1.0;
    l_init_msg_list                     VARCHAR2(1) := OKL_API.G_FALSE;
    lx_msg_count                        NUMBER := OKL_API.G_MISS_NUM;
    lx_msg_data                         VARCHAR2(2000);

    x_subsidy_amount       NUMBER;

    l_asset_subsidy_amount NUMBER;

    --cursor to fetch all the subsidies attached to financial asset
    --smoduga modified to set 0 when sub_kle.amount is null
    -- passing accounting method as input parameter
    CURSOR l_sub_csr(c_contract_id IN NUMBER,c_accounting_method IN  VARCHAR2) IS
    SELECT NVL(SUM(NVL(sub_kle.subsidy_override_amount, sub_kle.amount)),0)
    FROM   okl_subsidies_b    subb,
           okl_k_lines        sub_kle,
           okc_k_lines_b      sub_cle,
           okc_line_styles_b  sub_lse
    WHERE  subb.id                     = sub_kle.subsidy_id
    AND    subb.accounting_method_code = NVL(UPPER(c_accounting_method),subb.accounting_method_code)
    AND    sub_kle.id                  = sub_cle.id
    AND    sub_cle.lse_id              = sub_lse.id
    AND    sub_lse.lty_code            = 'SUBSIDY'
    AND    sub_cle.sts_code            <> 'ABANDONED'
    AND    sub_cle.dnz_chr_id          = c_contract_id
    AND    subb.customer_visible_yn    = 'Y'
    ;

-- START: cklee bug#4437995 if p_accounting_method has G_MISS then make it NULL
    l_accounting_method okl_subsidies_b.accounting_method_code%TYPE;
-- END: cklee bug#4437995 if p_accounting_method has G_MISS then make it NULL
    l_subsidy_cle_id NUMBER;
BEGIN

	l_asset_subsidy_amount := 0;
-- START: cklee bug#4437995 if p_accounting_method has G_MISS then make it NULL
    IF(p_accounting_method = OKL_API.G_MISS_NUM OR p_accounting_method = OKL_API.G_MISS_CHAR) THEN
        l_accounting_method := NULL;
    END IF;
-- END: cklee bug#4437995 if p_accounting_method has G_MISS then make it NULL
    --------------------------------------------------------------
    --get all the subsidies associated to asset and get amount
    --------------------------------------------------------------
    --smoduga added accountingmethod as in parameter
--    OPEN l_sub_csr(p_contract_id , p_accounting_method);
-- START: cklee bug#4437995 if p_accounting_method has G_MISS then make it NULL
    OPEN l_sub_csr(p_contract_id , l_accounting_method);
-- END: cklee bug#4437995 if p_accounting_method has G_MISS then make it NULL
    LOOP
        FETCH l_sub_csr INTO l_asset_subsidy_amount;
        EXIT WHEN l_sub_csr%NOTFOUND;
    END LOOP;
    CLOSE l_sub_csr;

    x_subsidy_amount := l_asset_subsidy_amount;

    RETURN x_subsidy_amount;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    lx_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               lx_msg_count,
                               lx_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    lx_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              lx_msg_count,
                              lx_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF l_sub_csr%ISOPEN THEN
        CLOSE l_sub_csr;
    END IF;
    lx_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              lx_msg_count,
                              lx_msg_data,
                              '_PVT');

END get_asset_subsidy_amount;


----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ravikumar Vaduri
    -- Function Name  contract_acc_depreciation
    -- Description:   returns the acc depreciation for a contract from FA
    --                this function is used in calculation of NET INVESTMENT for
    --                  OP LEASE
    -- Dependencies:
    -- Parameters: contract id,contract line id
    -- Version: 1.0
    -- 17-MAR-04 rvaduri  Created the Function
    -- End of Commnets

----------------------------------------------------------------------------------------------------

FUNCTION contract_acc_depreciation( p_contract_id IN  NUMBER
                                    ,p_contract_line_id      IN NUMBER)
         RETURN NUMBER IS

        l_unearned_income NUMBER := 0;
        l_depreciation NUMBER := 0;
        l_depn_contract NUMBER := 0;
        l_converted_amount NUMBER := 0;
        p_return_status VARCHAR2(1);
        p_contract_start_date DATE;
        p_contract_currency             okl_k_headers_full_v.currency_code%TYPE;
        p_currency_conversion_type okl_k_headers_full_v.currency_conversion_type%TYPE;
        p_currency_conversion_rate okl_k_headers_full_v.currency_conversion_rate%TYPE;
        p_currency_conversion_date okl_k_headers_full_v.currency_conversion_date%TYPE;

   --Cursor to get the parent line id for a contract
  CURSOR parent_line_id_csr (p_contract_id  NUMBER)
  IS
   SELECT line.id parent_line_id
    FROM okc_k_lines_b line
     ,okc_line_styles_v lse
    WHERE line.lse_id=lse.id
        AND lse.lty_code= 'FREE_FORM1'
        AND line.sts_code <> 'ABANDONED'
        AND dnz_chr_id = p_contract_id;


 -- line asset id and corporate book from FA
 CURSOR asset_details_csr(p_contract_line_id  NUMBER)
 IS
 SELECT CORPORATE_BOOK, ASSET_ID
 FROM OKX_ASSET_LINES_V
 WHERE OKX_ASSET_LINES_V.PARENT_LINE_ID = p_contract_line_id;

 -- total depreciation for the corporate book from FA
 CURSOR deprn_details_csr(p_asset_id  NUMBER, p_corporate_book_code VARCHAR2)
 IS
 SELECT NVL(SUM(deprn_amount), 0) deprn_amount
 FROM   OKX_AST_DPRTNS_V
 WHERE  Asset_id = p_asset_id
 AND    book_type_code = p_corporate_book_code
 AND    status = 'A'
 AND    NVL(start_date_active,SYSDATE) <= SYSDATE
 AND    NVL(end_date_active,SYSDATE + 1) > SYSDATE;


 -- contract start date
 CURSOR contract_start_date_csr(p_khr_id NUMBER)
 IS
 SELECT start_date FROM okc_k_headers_b
 WHERE id = p_khr_id;

 l_streams_repo_policy VARCHAR2(80); -- MGAAP 7263041
BEGIN

  l_streams_repo_policy := OKL_STREAMS_SEC_PVT.GET_STREAMS_POLICY;
  -- calculate asset line level depreciation
  IF(p_contract_line_id IS NOT NULL) THEN
   FOR p_asset_details_csr IN asset_details_csr(p_contract_line_id)
   LOOP
        FOR p_deprn_details_csr IN deprn_details_csr(p_asset_details_csr.ASSET_ID,
                                                p_asset_details_csr.CORPORATE_BOOK)
        LOOP
                l_depreciation := p_deprn_details_csr.deprn_amount;
        END LOOP;

   END LOOP;


   -- convert amount into contract currency
   OPEN contract_start_date_csr(p_contract_id);
   FETCH contract_start_date_csr INTO p_contract_start_date;
   CLOSE contract_start_date_csr;

   okl_accounting_util.convert_to_contract_currency(
                                p_khr_id  => p_contract_id,
                                p_from_currency  => NULL,
                                p_transaction_date => p_contract_start_date,
                                p_amount => l_depreciation,
                                x_return_status => p_return_status,
                                x_contract_currency => p_contract_currency,
                                x_currency_conversion_type => p_currency_conversion_type,
                                x_currency_conversion_rate => p_currency_conversion_rate,
                                x_currency_conversion_date => p_currency_conversion_date,
                                x_converted_amount => l_converted_amount);

   IF(p_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
           Okl_Api.Set_Message(p_app_name     => Okl_Api.G_APP_NAME,
                               p_msg_name     => 'OKL_CONV_TO_FUNC_CURRENCY_FAIL');
           RAISE Okl_Api.G_EXCEPTION_ERROR;
   END IF;

   RETURN l_converted_amount;

  ELSE
  FOR p_parent_line_id_csr  IN parent_line_id_csr(p_contract_id) LOOP
     --Get the Parent_line_id based on the contract id
   FOR p_asset_details_csr IN asset_details_csr(p_parent_line_id_csr.parent_line_id)
   LOOP
        FOR p_deprn_details_csr IN deprn_details_csr(p_asset_details_csr.ASSET_ID,
                                                        p_asset_details_csr.CORPORATE_BOOK)
        LOOP
                --Depreciation Amount from FA
                l_depreciation := p_deprn_details_csr.deprn_amount;
        END LOOP;
   END LOOP;
   l_depn_contract := l_depn_contract + l_depreciation;
  END LOOP;
   -- convert amount into contract currency
   OPEN contract_start_date_csr(p_contract_id);
   FETCH contract_start_date_csr INTO p_contract_start_date;
   CLOSE contract_start_date_csr;

--rkuttiya modified for bug#4367682 changed l_depreciation to l_depn_contract
   okl_accounting_util.convert_to_contract_currency(
                                p_khr_id  => p_contract_id,
                                p_from_currency  => NULL,
                                p_transaction_date => p_contract_start_date,
                                p_amount => l_depn_contract,
                                x_return_status => p_return_status,
                                x_contract_currency => p_contract_currency,
                                x_currency_conversion_type => p_currency_conversion_type,
                                x_currency_conversion_rate => p_currency_conversion_rate,
                                x_currency_conversion_date => p_currency_conversion_date,
                                x_converted_amount => l_converted_amount);

   IF(p_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
           Okl_Api.Set_Message(p_app_name     => Okl_Api.G_APP_NAME,
                               p_msg_name     => 'OKL_CONV_TO_FUNC_CURRENCY_FAIL');
           RAISE Okl_Api.G_EXCEPTION_ERROR;
   END IF;
   RETURN l_converted_amount;

  END IF;

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        RETURN 0;

    WHEN OTHERS THEN
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN 0;

END contract_acc_depreciation;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Ravikumar Vaduri
    -- Function Name  pv_of_unbilled_rents
    -- Description:   returns the Present value of Unbilled Rent for a contract
    --                this function is used in calculation of NET INVESTMENT for
    --                  DF LEASE
    -- Dependencies:
    -- Parameters: contract id,contract line id
    -- Version: 1.0
    -- 17-MAR-04 rvaduri  Created the Function
    -- End of Commnets

----------------------------------------------------------------------------------------------------

FUNCTION pv_of_unbilled_rents(
            p_contract_id           IN  NUMBER
           ,p_contract_line_id      IN NUMBER) RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(30) := 'PV_OF_UNBILLED_RENTS';
    l_api_version       CONSTANT NUMBER       := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);
    l_cash_flow_tbl     OKL_STREAM_GENERATOR_PVT.cash_flow_tbl;
    i                   NUMBER := 0;
    l_total_rent        NUMBER := 0;
    l_rent              NUMBER := 0;
    l_rate              NUMBER := 0;
    x_pv_amount         NUMBER := 0;
    l_due_date          DATE;
    l_currency          VARCHAR2(30);
    l_kle_id              NUMBER := 0;
    l_slh_id              NUMBER := 0;
    l_freq             VARCHAR2(10);

-- select changed to filter streams based on purpose instead of on type
-- enhancement done for user defined streams impacts, bug 3924303

    CURSOR contract_unbilled_rent_csr(c_contract_id NUMBER)
    IS
      SELECT sel.amount rent
            ,sel.stream_element_date due_date
            ,stm.kle_id
      FROM okl_strm_elements sel,
           okl_streams stm,
           okl_strm_type_v sty
      WHERE sty.stream_type_purpose = 'RENT'
        AND stm.sty_id = sty.id
        AND stm.say_code = 'CURR'
        AND stm.active_yn = 'Y'
        AND stm.purpose_code IS NULL
        AND stm.khr_id = c_contract_id
        AND sel.stm_id = stm.id
        AND sel.date_billed IS NULL;


-- select changed to filter streams based on purpose instead of on type
-- enhancement done for user defined streams impacts, bug 3924303

    CURSOR line_unbilled_rent_csr(c_contract_line_id NUMBER)
    IS
     SELECT sel.amount rent
            ,sel.stream_element_date due_date
      FROM okl_strm_elements sel,
           okl_streams stm,
           okl_strm_type_v sty
      WHERE sty.stream_type_purpose = 'RENT'
        AND stm.sty_id = sty.id
        AND stm.say_code = 'CURR'
        AND stm.active_yn = 'Y'
        AND stm.purpose_code IS NULL
        AND stm.kle_id = c_contract_line_id
        AND sel.stm_id = stm.id
        AND sel.date_billed IS NULL;



    CURSOR c_get_rent_slh_id(c_line_id NUMBER,c_khr_id NUMBER)
    IS
        SELECT rl.id
        FROM okc_rule_groups_v rg,
             okc_rules_v rl
        WHERE rl.rgp_id = rg.id
          AND rl.dnz_chr_id = rg.dnz_chr_id
          AND rg.cle_id = c_line_id
          AND rg.rgd_code = 'LALEVL'
          AND rl.rule_information_category = 'LASLH'
          AND rl.dnz_chr_id = c_khr_id
          AND rl.object1_id1=(SELECT id FROM okl_strm_type_b WHERE code='RENT');

    CURSOR c_get_freq(c_line_id NUMBER,c_khr_id NUMBER,c_rent_slh_id NUMBER)
    IS
        SELECT rl.object1_id1 frequency
        FROM okc_rule_groups_v rg,
             okc_rules_v rl
        WHERE rl.rgp_id = rg.id
          AND rl.dnz_chr_id = rg.dnz_chr_id
          AND rg.cle_id = c_line_id
          AND rg.rgd_code = 'LALEVL'
          AND rl.rule_information_category = 'LASLL'
          AND rl.dnz_chr_id = c_khr_id
          AND rl.object2_id1=c_rent_slh_id
          AND ROWNUM = 1;


    CURSOR contract_rate_csr (c_contract_id NUMBER)
    IS
    SELECT implicit_interest_rate
    FROM okl_k_headers
    WHERE id=c_contract_id;


    CURSOR k_curr_code (c_contract_id NUMBER)
    IS
    SELECT currency_code
    FROM okc_k_headers_b
    WHERE id=c_contract_id;



    BEGIN

        --Get the contract currency Code.
        OPEN k_curr_code(p_contract_id);
        FETCH k_curr_code INTO l_currency;
        CLOSE k_curr_code;

        --Get the Interest Rate on the contract.
        OPEN contract_rate_csr(p_contract_id);
        FETCH contract_rate_csr INTO l_rate;
        CLOSE contract_rate_csr;

        IF l_rate IS NULL THEN
           Okl_Api.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'RATE');

           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        IF p_contract_line_id IS NOT NULL THEN

            FOR cur_rec IN line_unbilled_rent_csr(p_contract_line_id) LOOP
                l_due_date := cur_rec.due_date;
                l_rent     := cur_rec.rent;

                IF l_due_date < SYSDATE THEN
                --The Due date is in the past, i.e no billing has been run
                --so the present value of the rent is the actual value
                --that is present in the streams table.
                        l_total_rent := l_total_rent + l_rent;
                ELSE
                    i := i + 1;
                --The Due date is in the future, so we have to calculate the
                --present value of the rent.
                    OPEN c_get_rent_slh_id(p_contract_line_id,p_contract_id);
                    FETCH c_get_rent_slh_id INTO l_slh_id;
                    CLOSE c_get_rent_slh_id;


                    OPEN c_get_freq(p_contract_line_id,p_contract_id,l_slh_id);
                    FETCH c_get_freq INTO l_freq;
                    CLOSE c_get_freq;



                --Populate the pl/sql table for the calculation of PV of rent.

                        l_cash_flow_tbl(i).cf_date   := l_due_date;
                        l_cash_flow_tbl(i).cf_amount := l_rent;
                        l_cash_flow_tbl(i).cf_frequency   := l_freq;
                END IF;
            END LOOP;
                --Call the API that does the PV calculation.

             IF  l_cash_flow_tbl.COUNT > 0 THEN
                  OKL_STREAM_GENERATOR_PVT.get_present_value(
                                   p_api_version          => l_api_version,
                                   p_init_msg_list        => OKL_API.G_TRUE,
                                   p_cash_flow_tbl        => l_cash_flow_tbl,
                                   p_rate                 => l_rate,
                                   p_pv_date              => SYSDATE,
                                   x_pv_amount            => x_pv_amount,
                                   x_return_status        => x_return_status,
                                   x_msg_count            => x_msg_count,
                                   x_msg_data             => x_msg_data);

                IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
                    RAISE okl_api.G_EXCEPTION_ERROR;
                END IF;
             END IF;

                l_total_rent := l_total_rent + NVL(x_pv_amount,0);

        ELSE

            FOR cur_rec IN contract_unbilled_rent_csr(p_contract_id) LOOP

                l_due_date := cur_rec.due_date;
                l_rent     := cur_rec.rent;
                l_kle_id   := cur_rec.kle_id;
                IF l_due_date < SYSDATE THEN
                --The Due date is in the past, i.e no billing has been run
                --so the present value of the rent is the actual value
                --that is present in the streams table.
                        l_total_rent := l_total_rent + l_rent;
                ELSE
                    i := i + 1;
                --The Due date is in the future, so we have to calculate the
                --present value of the rent.
                    OPEN c_get_rent_slh_id(l_kle_id,p_contract_id);
                    FETCH c_get_rent_slh_id INTO l_slh_id;
                    CLOSE c_get_rent_slh_id;


                    OPEN c_get_freq(l_kle_id,p_contract_id,l_slh_id);
                    FETCH c_get_freq INTO l_freq;
                    CLOSE c_get_freq;


                --Populate the pl/sql table for the calculation of PV of rent.
                        l_cash_flow_tbl(i).cf_date   := l_due_date;
                        l_cash_flow_tbl(i).cf_amount := l_rent;
                        l_cash_flow_tbl(i).cf_frequency   := l_freq;
                END IF;
            END LOOP;
                --Call the API that does the PV calculation.
             IF  l_cash_flow_tbl.COUNT > 0 THEN
                    OKL_STREAM_GENERATOR_PVT.get_present_value(
                                   p_api_version          => l_api_version,
                                   p_init_msg_list        => OKL_API.G_TRUE,
                                   p_cash_flow_tbl        => l_cash_flow_tbl,
                                   p_rate                 => l_rate,
                                   p_pv_date              => SYSDATE,
                                   x_pv_amount            => x_pv_amount,
                                   x_return_status        => x_return_status,
                                   x_msg_count            => x_msg_count,
                                   x_msg_data             => x_msg_data);

                IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
                    RAISE okl_api.G_EXCEPTION_ERROR;
                END IF;
            END IF;
                l_total_rent := l_total_rent + NVL(x_pv_amount,0);
        END IF;

        --Round the amount before returning it.
        RETURN  OKL_ACCOUNTING_UTIL.round_amount(l_total_rent,l_currency);


   EXCEPTION
   WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
END pv_of_unbilled_rents;


---------------------------------------------
-- End CS Functions
---------------------------------------------

-----------------------------------------------------------------------
-- Functions By pdevaraj -start
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Start of Comments
-- Created By:    Punitharaj Devaraju (pdevaraj)
-- Function Name: contract_net_investment
-- Description:   Get net investment for a contract.
-- Dependencies:  OKL_SEEDED_FUNCTIONS_PVT.contract_residual_value
--                OKL_SEEDED_FUNCTIONS_PVT.contract_sum_of_rents
--                OKL_SEEDED_FUNCTIONS_PVT.contract_income
-- Parameters:    contract id.
-- Version:       1.0
-- End of Commnets
-----------------------------------------------------------------------

FUNCTION contract_net_investment
  (
     p_chr_id     IN NUMBER
    ,p_line_id    IN NUMBER
  )
RETURN NUMBER IS
  l_api_version      NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_rent             NUMBER := 0;
  l_residual         NUMBER := 0;
  l_income           NUMBER := 0;
  l_net_investment   NUMBER := 0;

BEGIN

  -- Get Residual Value
  l_residual := Okl_Seeded_Functions_Pvt.contract_residual_value(p_chr_id => p_chr_id, p_line_id => NULL);

  -- Get Rent
  l_rent := Okl_Seeded_Functions_Pvt.contract_sum_of_rents(p_chr_id, NULL);

  -- Get Rent
  l_income := Okl_Seeded_Functions_Pvt.contract_income(p_chr_id, NULL);

  -- Calculate Net Investment
  l_net_investment := l_rent + l_residual - l_income;

  RETURN l_net_investment;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);

       RETURN NULL;
END contract_net_investment;

-----------------------------------------------------------------------
-- Start of Comments
-- Created By:    Punitharaj Devaraju (pdevaraj)
-- Function Name: contract_cures_in_possession
-- Description:   Get cures in possession a contract.
-- Dependencies:
-- Parameters:    contract id.
-- Version:       1.0
-- End of Commnets
-----------------------------------------------------------------------
FUNCTION contract_cures_in_possession
  (
    p_chr_id     IN NUMBER
  )
RETURN NUMBER IS
  -- Cursor to get Cures in Possession
  CURSOR cures_in_possession_csr(p_chr_id IN NUMBER) IS
    SELECT NVL(SUM(amount),0)
    FROM   OKL_CURE_PAYMENT_LINES
    WHERE  chr_id = p_chr_id
    AND    status = 'CURES_IN_POSSESSION'
    AND    cured_flag = 'Y';

  l_cures_in_possession   NUMBER := 0;

BEGIN

  OPEN  cures_in_possession_csr(p_chr_id);
  FETCH cures_in_possession_csr INTO l_cures_in_possession;
  CLOSE cures_in_possession_csr;

  RETURN l_cures_in_possession;

  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN

                          ,p_token2_value => SQLERRM);
      RETURN NULL;

END contract_cures_in_possession;

-----------------------------------------------------------------------
-- Start of Comments
-- Created By:    Punitharaj Devaraju (pdevaraj)
-- Function Name: contract_outstanding_amount
-- Description:   Get contract outstanding amount.
-- Dependencies:
-- Parameters:    contract id, contract line id.
-- Version:       1.0
-- End of Commnets
-----------------------------------------------------------------------
FUNCTION contract_outstanding_amount
  (
    p_chr_id     IN NUMBER,
    p_line_id    IN NUMBER
  )

RETURN NUMBER IS
  -- Cursor for outstanding amount
    -- Bug 5897792
  /*CURSOR outstanding_amount_csr (p_chr_id IN NUMBER) IS
    SELECT NVL(SUM(amount_due_remaining), 0)
    FROM   okl_bpd_leasing_payment_trx_v
    WHERE  contract_id = p_chr_id;*/

  CURSOR outstanding_amount_csr (p_chr_id IN NUMBER) IS
    SELECT NVL(SUM(amount_due_remaining), 0)
    FROM   okl_bpd_ar_inv_lines_v
    WHERE  contract_id = p_chr_id;


  l_outstanding_amount  NUMBER := 0;

BEGIN

  OPEN  outstanding_amount_csr (p_chr_id);
  FETCH outstanding_amount_csr INTO l_outstanding_amount;
  CLOSE outstanding_amount_csr;

  RETURN l_outstanding_amount;

  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      RETURN NULL;

END contract_outstanding_amount;

-----------------------------------------------------------------------
-- Start of Comments
-- Created By:    Punitharaj Devaraju (pdevaraj)
-- Function Name: contract_full_cure
-- Description:   Get full cure amount for a contract.
-- Dependencies:  OKL_SEEDED_FUNCTIONS_PVT.contract_rent_amount
--                OKL_SEEDED_FUNCTIONS_PVT.contract_outstanding_amount
--                OKL_SEEDED_FUNCTIONS_PVT.contract_cures_in_possession
-- Parameters:    contract id.
-- Version:       1.0
-- End of Commnets
-----------------------------------------------------------------------
FUNCTION contract_full_cure
  (
     p_chr_id     IN NUMBER
  )
RETURN NUMBER IS
  l_api_version         NUMBER;
  l_return_status       VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_current_rent        NUMBER;
  l_cures_in_possession NUMBER := 0;
  l_outstanding_amount  NUMBER := 0;
  l_full_cure           NUMBER := 0;

BEGIN

  -- Get Current Rent
  l_current_rent := Okl_Seeded_Functions_Pvt.contract_rent_amount(p_chr_id, NULL);

  -- Get Cures in Possession
  l_cures_in_possession := Okl_Seeded_Functions_Pvt.contract_cures_in_possession
                             (p_chr_id);

  l_outstanding_amount := Okl_Seeded_Functions_Pvt.contract_outstanding_amount
                                       ( p_chr_id
                                        ,NULL );

  l_full_cure := l_outstanding_amount -
                 l_current_rent -
                 l_cures_in_possession;

  RETURN l_full_cure;

  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
       RETURN NULL;
END contract_full_cure;

-----------------------------------------------------------------------
-- Start of Comments
-- Created By:    Punitharaj Devaraju (pdevaraj)
-- Function Name: contract_interest_cure
-- Description:   Get interest cure amount for a contract.
-- Dependencies:  okl_contract_info.get_rule_value
--                okl_contract_info_pvt.get_days_past_due
-- Parameters:    contract id.
-- Version:       1.0
-- End of Commnets
-----------------------------------------------------------------------
FUNCTION contract_interest_cure
  (
     p_chr_id     IN NUMBER
  )
RETURN NUMBER IS
  l_api_version      NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_contract_rate    NUMBER := 0.0;
  l_net_investment   NUMBER := 0;
  l_interest_cure    NUMBER := 0;
  l_current_date     DATE := TRUNC(SYSDATE);
  l_days_past_due    NUMBER := 0;
  l_last_due_date    DATE;
  l_months_requiring_cure   NUMBER := 0;
  l_value            VARCHAR2(200);
  l_id1              VARCHAR2(40);
  l_id2              VARCHAR2(200);


BEGIN

-- Get Net Investment
  l_net_investment := Okl_Seeded_Functions_Pvt.contract_net_investment
                           (p_chr_id, NULL);

-- Get Contract rate from rule
  l_return_status := okl_contract_info.get_rule_value
                                          (
                                             p_contract_id => p_chr_id
                                            ,p_rule_group_code => 'COCURP'
                                            ,p_rule_code => 'COCURE'
                                            ,p_segment_number => 7
                                            ,x_id1 => l_id1
                                            ,x_id2 => l_id2
                                            ,x_value => l_value
                                          );

  IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
    RAISE okl_api.G_EXCEPTION_ERROR;
  END IF;

  l_contract_rate := ROUND(TO_NUMBER(l_value)/100, 3);

  l_return_status := okl_contract_info.get_days_past_due
                                          (  p_chr_id
                                            ,l_days_past_due );

  IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
    RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
    RAISE okl_api.G_EXCEPTION_ERROR;
  END IF;

  -- Get the furthest due date from current date
  -- when customer stopped paying
  l_last_due_date := l_current_date - l_days_past_due;
  l_months_requiring_cure :=
                 FLOOR(MONTHS_BETWEEN(l_current_date,l_last_due_date));

  l_interest_cure := (( l_net_investment * l_contract_rate )/12) *
                       l_months_requiring_cure;

  RETURN l_interest_cure;

  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
       RETURN NULL;

END contract_interest_cure;

  ---------------------------------------------------------------------------
  -- FUNCTION get_unrefunded_cures
  ---------------------------------------------------------------------------
  FUNCTION get_unrefunded_cures(
     p_contract_id		IN NUMBER,
     x_unrefunded_cures	      OUT NOCOPY NUMBER)
  RETURN VARCHAR2
  IS

    -- Get unrefunded cures for a contract
    /*CURSOR unrefunded_cures_csr(p_contract_id NUMBER) IS
      SELECT SUM(amount)
      FROM   OKL_cure_payment_lines_v
      WHERE  chr_id = p_contract_id
      AND    status = 'CURES_IN_POSSESSION'; */

    l_unrefunded_cures NUMBER := 0;
    l_api_version      NUMBER;
    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);

  BEGIN

    --OPEN  unrefunded_cures_csr(p_contract_id);
    --FETCH unrefunded_cures_csr INTO l_unrefunded_cures;
    --CLOSE unrefunded_cures_csr;

    x_unrefunded_cures := l_unrefunded_cures;

    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END get_unrefunded_cures;

  ---------------------------------------------------------------------------
  -- FUNCTION get_unrefunded_cures
  ---------------------------------------------------------------------------
  FUNCTION get_cured_status (p_contract_number IN NUMBER)
    RETURN VARCHAR2 IS
  CURSOR c_cured (p_chr_id NUMBER)  IS
    SELECT 'Y'
    FROM    OKL_CURE_PAYMENT_LINES
    WHERE EXISTS (SELECT 1
                  FROM   OKL_CURE_PAYMENT_LINES
                  WHERE  status = 'CURES_IN_POSSESSION'
                  AND    cured_flag = 'Y'
                  AND    chr_id = p_chr_id);
    ls_cured_flag  VARCHAR2(1) := 'N';
  BEGIN
    OPEN c_cured(p_contract_number );
    FETCH c_cured INTO ls_cured_flag;
    IF(c_cured%NOTFOUND) THEN
       ls_cured_flag := 'N' ;
         CLOSE c_cured ;
         RETURN(ls_cured_flag);
    END IF ;
    CLOSE c_cured;
      RETURN(ls_cured_flag);
  END get_cured_status;

-----------------------------------------------------------------------
-- Functions By pdevaraj -end
-----------------------------------------------------------------------

  ----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  investor_account_amount
    -- Description:   returns the investor account amount for the syndication.
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION investor_account_amount(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'RETURN_CONTRACT_SUM_OF_RENTS';
    l_api_version	CONSTANT NUMBER	      := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_inv_accnt_amnt NUMBER := 0;
    l_cap_amnt       NUMBER := 0;
    l_pcnt_inv       NUMBER := 0;
    l_stake_amnt     NUMBER := 0;

    CURSOR l_hdrrl_csr( rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                       rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                       chrId NUMBER) IS
    SELECT crl.object1_id1,
           crl.RULE_INFORMATION1,
           crl.RULE_INFORMATION2,
           crl.RULE_INFORMATION3,
           crl.RULE_INFORMATION4,
           crl.RULE_INFORMATION5,
           crl.RULE_INFORMATION6,
           crl.RULE_INFORMATION10,
           crl.RULE_INFORMATION11
    FROM   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl
    WHERE  crl.rgp_id = crg.id
           AND crg.RGD_CODE = rgcode
           AND crl.RULE_INFORMATION_CATEGORY = rlcat
           AND crg.dnz_chr_id = chrId;

    l_hdrrl_rec l_hdrrl_csr%ROWTYPE;

  BEGIN

       IF ( p_chr_id IS NULL ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       l_cap_amnt := contract_oec( p_chr_id, NULL)
                     - contract_tradein( p_chr_id, NULL)
                     - contract_capital_reduction( p_chr_id, NULL)
                     + contract_fees_capitalized( p_chr_id, NULL);

       OPEN l_hdrrl_csr( 'LASYND', 'LASYST',p_chr_id );
       FETCH l_hdrrl_csr INTO l_hdrrl_rec;
       CLOSE l_hdrrl_csr;

       l_stake_amnt := TO_NUMBER(NVL( l_hdrrl_rec.RULE_INFORMATION1, 0.0));
       l_pcnt_inv   := TO_NUMBER(NVL( l_hdrrl_rec.RULE_INFORMATION2, 0.0)) / 100.00;
       l_inv_accnt_amnt := l_stake_amnt - l_cap_amnt * l_pcnt_inv;

       RETURN l_inv_accnt_amnt;

    EXCEPTION
	WHEN OTHERS  THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;

  END investor_account_amount;


  ----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  contract_capitalized_interest
    -- Description:   returns the total capitalized interest for the contract.
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION contract_capitalized_interest(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_name		CONSTANT VARCHAR2(256) := 'RETURN_CONTRACT_CAPITALIZED_INTEREST';
    l_api_version	CONSTANT NUMBER	      := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_capz_int NUMBER := 0.0;

    CURSOR capz_csr( chrId NUMBER ) IS
    SELECT NVL( SUM(kle.capitalized_interest), 0.0)
    FROM OKC_LINE_STYLES_B LS,
         OKL_K_LINES_FULL_V KLE,
         okc_statuses_b sts
    WHERE  LS.ID = KLE.LSE_ID
         AND LS.LTY_CODE ='FREE_FORM1'
         AND KLE.DNZ_CHR_ID = chrId
-- start: cklee 05/18/2004 fixed for bug#3625609
         AND KLE.sts_code     = sts.code
         AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');
-- end: cklee 05/18/2004 fixed for bug#3625609

  BEGIN

       IF ( p_chr_id IS NULL ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       OPEN capz_csr( p_chr_id );
       FETCH capz_csr INTO l_capz_int;
       CLOSE capz_csr;

       RETURN l_capz_int;

    EXCEPTION

	WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;

  END contract_capitalized_interest;

  ----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Santhosh Siruvole (ssiruvol)
    -- Function Name  line_capitalized_interest
    -- Description:   returns the total capitalized interest for the contract.
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION line_capitalized_interest(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_name		CONSTANT VARCHAR2(256) := 'RETURN_CONTRACT_CAPITALIZED_INTEREST';
    l_api_version	CONSTANT NUMBER	      := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_capz_int NUMBER := 0.0;

    CURSOR capz_csr( chrId NUMBER, kleId NUMBER ) IS
    SELECT NVL( kle.capitalized_interest, 0.0)
    FROM OKC_LINE_STYLES_B LS,
         OKL_K_LINES_FULL_V KLE
    WHERE  LS.ID = KLE.LSE_ID
         AND LS.LTY_CODE ='FREE_FORM1'
         AND KLE.DNZ_CHR_ID = chrId
         AND KLE.id = kleId;

  BEGIN

       IF (( p_chr_id IS NULL ) OR ( p_line_id IS NULL ) ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       OPEN capz_csr( p_chr_id, p_line_id );
       FETCH capz_csr INTO l_capz_int;
       CLOSE capz_csr;

       RETURN l_capz_int;

    EXCEPTION

	WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;

  END line_capitalized_interest;

  ---------------------------------------------
  -- Functions for Securitization
  -- mvasudev, 04/02/2003
  ---------------------------------------------

  FUNCTION ASSET_UNDISBURSED_STREAMS(p_dnz_chr_id IN NUMBER -- Lease Contract ID
                                             ,p_kle_id     IN NUMBER -- Lease Contract-Asset ID
                                             )
  RETURN NUMBER
  IS
    CURSOR l_okl_inv_payment_event_csr(p_khr_id IN NUMBER)
    IS
    SELECT rulb.rule_information2 payment_event
    FROM   okc_rules_b rulb
          ,okc_rule_groups_b rgpb
    WHERE  rgpb.dnz_chr_id                = p_khr_id
	AND    rgpb.chr_id                    = p_khr_id
    AND    rgpb.rgd_code                  = 'LASEIR'
    AND    rgpb.id                        = rulb.rgp_id
    AND    rulb.rule_information_category = 'LASEIR';

    CURSOR l_okl_unbilled_streams_csr(p_dnz_chr_id IN NUMBER
                                     ,p_kle_id IN NUMBER
                                     ,p_sty_id IN NUMBER)
    IS
    SELECT NVL(SUM(selb.amount),0) total_amount
    FROM   okl_strm_elements selb
          ,okl_streams       stmb
          ,okl_pool_contents pocb
          ,okl_strm_type_v styv --ankushar --Bug 6594724
          ,okc_k_headers_b chrb --ankushar --Bug 6594724
    WHERE stmb.khr_id = p_dnz_chr_id
    AND   stmb.kle_id = p_kle_id
    AND   stmb.sty_id = p_sty_id
    AND   selb.stm_id = stmb.id
	AND   stmb.active_yn = 'Y'
	AND   stmb.say_code = 'CURR'
    AND   selb.date_billed IS NULL
    AND   pocb.kle_id = p_kle_id
    AND   pocb.sty_id = p_sty_id
	-- mvasudev, 03/30/2004
	AND   pocb.status_Code = 'ACTIVE'
  /*
    ankushar --Bug 6594724: Unable to terminate Investor Agreement with Residual Streams
    Start changes
   */
    AND stmb.sty_id = styv.id
    AND pocb.khr_id = chrb.id
    AND(selb.stream_element_date > SYSDATE
        OR
          (styv.stream_type_subclass = 'RESIDUAL'
           and chrb.STS_CODE IN ('TERMINATED','EXPIRED')
          )
       )
  /* ankushar Bug 6594724
     End Changes
   */
	-- end, mvasudev, 03/30/2004
    AND   (selb.stream_element_date BETWEEN pocb.streams_from_date
                                    AND NVL(pocb.streams_to_date,G_FINAL_DATE)
           );

    CURSOR l_okl_unreceived_streams_csr(p_dnz_chr_id IN NUMBER
                                       ,p_kle_id IN NUMBER
                                       ,p_sty_id IN NUMBER)
    IS
    SELECT NVL(SUM(amount_due_original - amount_due_remaining),0) total_amount
    FROM   okl_bpd_leasing_payment_trx_v
	WHERE  contract_id = p_dnz_chr_id
	AND    contract_line_id = p_kle_id
	AND    stream_type_id = p_sty_id
	AND    amount_due_original <> amount_due_remaining;

 CURSOR l_okl_unbilled_strms_pndg_csr(p_dnz_chr_id IN NUMBER
                                     ,p_kle_id IN NUMBER
                                     ,p_sty_id IN NUMBER)
    IS
    SELECT NVL(SUM(selb.amount),0) total_amount
    FROM   okl_strm_elements selb
          ,okl_streams       stmb
          ,okl_pool_contents pocb
    WHERE stmb.khr_id = p_dnz_chr_id
    AND   stmb.kle_id = p_kle_id
    AND   stmb.sty_id = p_sty_id
    AND   selb.stm_id = stmb.id
    AND   stmb.active_yn = 'Y'
    AND   stmb.say_code = 'CURR'
    AND   selb.date_billed IS NULL
    AND   pocb.kle_id = p_kle_id
    AND   pocb.sty_id = p_sty_id
    AND   pocb.status_code = 'PENDING'
    AND   selb.stream_element_date > SYSDATE
    AND   (selb.stream_element_date BETWEEN pocb.streams_from_date
                                    AND NVL(pocb.streams_to_date,G_FINAL_DATE) );

	l_total_amount NUMBER := 0;
	l_khr_id NUMBER;
	l_sty_id NUMBER;
	l_try_rsn OKL_POOL_TRANSACTIONS.TRANSACTION_REASON%TYPE;

  BEGIN

    --Validate additional parameters availability
    IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'p_khr_id' THEN
          l_khr_id := OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE;
        ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'p_sty_id' THEN
          l_sty_id := OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE;
        ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'p_transaction_reason' THEN
          l_try_rsn := OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE;
        END IF;
      END LOOP;
      ELSE
      Okl_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_AGN_FE_ADD_PARAMS');
      RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

	FOR l_okl_inv_payment_event_rec IN l_okl_inv_payment_event_csr(l_khr_id)
	LOOP
	  IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
	    FOR l_okl_unbilled_strms_pndg_rec IN l_okl_unbilled_strms_pndg_csr(p_dnz_chr_id,p_kle_id,l_sty_id)
            LOOP
		l_total_amount := l_total_amount + l_okl_unbilled_strms_pndg_rec.total_amount;
	  END LOOP; -- unbilled streams for pending pool contents
	  ELSE
	  FOR l_okl_unbilled_streams_rec IN l_okl_unbilled_streams_csr(p_dnz_chr_id,p_kle_id,l_sty_id)
          LOOP
		l_total_amount := l_total_amount + l_okl_unbilled_streams_rec.total_amount;
	  END LOOP; -- unbilled streams
	  END IF;

	  IF l_okl_inv_payment_event_rec.payment_event = 'RECEIPT' THEN
	    FOR l_okl_unreceived_streams_rec IN l_okl_unreceived_streams_csr(p_dnz_chr_id,p_kle_id,l_sty_id)
	    LOOP
    	    l_total_amount := l_total_amount + l_okl_unreceived_streams_rec.total_amount;
		END LOOP; -- unreceived streams
	  END IF;

	END LOOP; -- payment basis

	RETURN l_total_amount;

  EXCEPTION
  WHEN OTHERS THEN
    IF l_okl_inv_payment_event_csr%ISOPEN THEN
      CLOSE l_okl_inv_payment_event_csr;
    END IF;
    IF l_okl_unbilled_streams_csr%ISOPEN THEN
      CLOSE l_okl_unbilled_streams_csr;
    END IF;
    IF l_okl_unreceived_streams_csr%ISOPEN THEN
      CLOSE l_okl_unreceived_streams_csr;
    END IF;
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    RETURN NULL;
  END ASSET_UNDISBURSED_STREAMS;

  -- mvasudev, 10/14/2003
  FUNCTION INVESTORS_PV_AMOUNT(p_chr_id IN NUMBER -- Investor Agreement ID
                                    ,p_line_id     IN NUMBER)
  RETURN NUMBER
  IS
  -- mvasudev, 09/29/2004, Bug#3909240
  CURSOR l_okl_pv_amounts_csr(p_sty_purpose IN VARCHAR2)
      IS
      SELECT NVL(SUM(selb.amount),0) total_amount
      FROM   okl_strm_elements selb
                  ,okl_streams       stmb
                  ,okl_strm_type_v   styv
                  ,okl_pool_contents pocb
      WHERE stmb.source_id = p_chr_id
      AND   styv.stream_type_purpose = p_sty_purpose
      AND   stmb.sty_id = styv.id
      AND   selb.stm_id = stmb.id
      AND   stmb.active_yn = 'Y'
      AND   stmb.say_code = 'CURR'
     AND   pocb.status_code <> 'PENDING'
     AND pocb.khr_id = stmb.khr_id
     AND pocb.kle_id = stmb.kle_id;

    CURSOR l_okl_pv_amounts_pending_csr(p_sty_purpose IN VARCHAR2)
      IS
      SELECT NVL(SUM(selb.amount),0) total_amount
      FROM  okl_strm_elements selb
                 ,okl_streams       stmb
                 ,okl_strm_type_v   styv
                 ,okl_pool_contents pocb
      WHERE stmb.source_id = p_chr_id
      AND   styv.stream_type_purpose = p_sty_purpose
      AND   stmb.sty_id = styv.id
      AND   selb.stm_id = stmb.id
      AND   stmb.active_yn = 'Y'
      AND   stmb.say_code = 'CURR'
      AND   pocb.status_code = 'PENDING'
      AND pocb.khr_id = stmb.khr_id
      AND pocb.kle_id = stmb.kle_id;

   /* fmiao , 09/6/2005 , Bug#4561645
        cursor change for stream_type_subclass filtering
    */
   CURSOR l_okl_percent_stake_csr(p_sty_subclass IN VARCHAR2)
   IS
   SELECT DISTINCT kleb.percent_stake,clet.id
   FROM   okl_k_lines kleb,
          okc_k_lines_b clet,
          okc_k_lines_b cles
   WHERE  kleb.id = cles.id
   AND    cles.cle_id = clet.id
   AND    clet.dnz_chr_id = p_chr_id
   --AND    kleb.sty_id = styb.id
   AND    kleb.stream_type_subclass = p_sty_subclass;

   l_total_amount NUMBER := 0;
   l_total_percent NUMBER := 0;
   l_try_rsn OKL_POOL_TRANSACTIONS.TRANSACTION_REASON%TYPE;

  BEGIN

     l_total_percent := 0;

    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
      LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'p_transaction_reason' THEN
          l_try_rsn := OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE;
        END IF;
      END LOOP;
     END IF;

      /* fmiao , 09/6/2005 , Bug#4561645
        change the stream_type_purpose PV_RENT_SECURITIZED and PV_RV_SECURITIZED
      */
      IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
        FOR l_okl_pv_amounts_pending_rec IN l_okl_pv_amounts_pending_csr('PV_RENT_SECURITIZED')
        LOOP
          FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('RENT')
          LOOP
            l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
          END LOOP;
          IF (l_total_percent >0 AND l_total_percent <=100) THEN
            l_total_amount := l_total_amount + (l_total_percent/100)*l_okl_pv_amounts_pending_rec.total_amount;
          END IF;
        END LOOP; -- PV_RENT_SECURITIZED
      ELSE
      FOR l_okl_pv_amounts_rec IN l_okl_pv_amounts_csr('PV_RENT_SECURITIZED')
      LOOP
        FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('RENT')
        LOOP
          l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
        END LOOP;
        IF (l_total_percent >0 AND l_total_percent <=100) THEN
          l_total_amount := l_total_amount + (l_total_percent/100)*l_okl_pv_amounts_rec.total_amount;
        END IF;
      END LOOP; -- PV_RENT_SECURITIZED
     END IF;
     l_total_percent := 0;

     IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
       FOR l_okl_pv_amounts_pending_rec IN l_okl_pv_amounts_pending_csr('PV_RV_SECURITIZED')
       LOOP
         FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('RESIDUAL')
         LOOP
           l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
         END LOOP;
         IF (l_total_percent >0 AND l_total_percent <=100) THEN
           l_total_amount := l_total_amount + (l_total_percent/100)*l_okl_pv_amounts_pending_rec.total_amount;
         END IF;
       END LOOP; -- PV_RV_SECURITIZED
     ELSE
       FOR l_okl_pv_amounts_rec IN l_okl_pv_amounts_csr('PV_RV_SECURITIZED')
       LOOP
         FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('RESIDUAL')
         LOOP
           l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
         END LOOP;
         IF (l_total_percent >0 AND l_total_percent <=100) THEN
           l_total_amount := l_total_amount + (l_total_percent/100)*l_okl_pv_amounts_rec.total_amount;
         END IF;
       END LOOP; -- PV_RV_SECURITIZED
     END IF;
  --Bug # 6740000 ssdeshpa Added for Addition of Loan Contract into the Pool
  --Calculate the PV Amount for Principal Sec of Loan Contracts
  l_total_percent := 0;
  IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
     FOR l_okl_pv_amounts_pending_rec IN l_okl_pv_amounts_pending_csr('PV_PRINCIPAL_SECURITIZED')
     LOOP
        FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('LOAN_PAYMENT')
        LOOP
            l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
        END LOOP;
        IF (l_total_percent >0 AND l_total_percent <=100) THEN
            l_total_amount := l_total_amount + (l_total_percent/100)*l_okl_pv_amounts_pending_rec.total_amount;
        END IF;
     END LOOP; -- PV_PRINCIPAL_SECURITIZED
  ELSE
     FOR l_okl_pv_amounts_rec IN l_okl_pv_amounts_csr('PV_PRINCIPAL_SECURITIZED')
     LOOP
        FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('LOAN_PAYMENT')
        LOOP
          l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
        END LOOP;
        IF (l_total_percent >0 AND l_total_percent <=100) THEN
          l_total_amount := l_total_amount + (l_total_percent/100)*l_okl_pv_amounts_rec.total_amount;
        END IF;
     END LOOP; -- PV_PRINCIPAL_SECURITIZED
  END IF;
   --Calculate the PV Amount for Interest Sec of Loan Contracts
  l_total_percent := 0;
  IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
     FOR l_okl_pv_amounts_pending_rec IN l_okl_pv_amounts_pending_csr('PV_INTEREST_SECURITIZED')
     LOOP
        FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('LOAN_PAYMENT')
        LOOP
            l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
        END LOOP;
        IF (l_total_percent >0 AND l_total_percent <=100) THEN
            l_total_amount := l_total_amount + (l_total_percent/100)*l_okl_pv_amounts_pending_rec.total_amount;
        END IF;
     END LOOP; -- PV_INTEREST_SECURITIZED
  ELSE
     FOR l_okl_pv_amounts_rec IN l_okl_pv_amounts_csr('PV_INTEREST_SECURITIZED')
     LOOP
        FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('LOAN_PAYMENT')
        LOOP
          l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
        END LOOP;
        IF (l_total_percent >0 AND l_total_percent <=100) THEN
          l_total_amount := l_total_amount + (l_total_percent/100)*l_okl_pv_amounts_rec.total_amount;
        END IF;
     END LOOP; -- PV_INTEREST_SECURITIZED
  END IF;
  --Calculate the PV Value for Unscheduled Principal Paydown(PPD) Payment
  l_total_percent := 0;
  IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
     FOR l_okl_pv_amounts_pending_rec IN l_okl_pv_amounts_pending_csr('PV_UNSCHEDULED_PMT_SECURITIZED')
     LOOP
          FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('LOAN_PAYMENT')
          LOOP
              l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
          END LOOP;
          IF (l_total_percent >0 AND l_total_percent <=100) THEN
              l_total_amount := l_total_amount + (l_total_percent/100)*l_okl_pv_amounts_pending_rec.total_amount;
          END IF;
       END LOOP; -- PV_UNSCHEDULED_PMT_SECURITIZED
  ELSE
     FOR l_okl_pv_amounts_rec IN l_okl_pv_amounts_csr('PV_UNSCHEDULED_PMT_SECURITIZED')
     LOOP
          FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('LOAN_PAYMENT')
          LOOP
             l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
          END LOOP;
          IF (l_total_percent >0 AND l_total_percent <=100) THEN
             l_total_amount := l_total_amount + (l_total_percent/100)*l_okl_pv_amounts_rec.total_amount;
          END IF;
     END LOOP; -- PV_UNSCHEDULED_PMT_SECURITIZED
  END IF;
   --Bug # 6740000 ssdeshpa Added for Addition of Loan Contract into the Pool

  RETURN l_total_amount;

  EXCEPTION
  WHEN OTHERS THEN
    IF l_okl_pv_amounts_csr%ISOPEN THEN
      CLOSE l_okl_pv_amounts_csr;
    END IF;
    IF l_okl_pv_amounts_pending_csr%ISOPEN THEN
      CLOSE l_okl_pv_amounts_pending_csr;
    END IF;
    IF l_okl_percent_stake_csr%ISOPEN THEN
      CLOSE l_okl_percent_stake_csr;
    END IF;

    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    RETURN NULL;
  END INVESTORS_PV_AMOUNT;


  ---------------------------------------------
  -- END,Functions for Securitization
  -- mvasudev, 04/02/2003
  ---------------------------------------------

-- 06/02/03 cklee start
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : investor_rent_accural_amout
-- Description     : get total rent accural amount by associated agreement's pool contracts
-- Business Rules  :
-- Parameters      :
-- Created By      : chenkuang.lee
-- last modified by: ssdeshpa
-- Version         : 2.0 modified to use Accrual Adjustment streams instead of Accrual streams
--                 : 3.0 modified for Addition of Loan Contract into the Pool
-- End of comments
----------------------------------------------------------------------------------
FUNCTION investor_rent_accural_amout(
   p_contract_id         IN okc_k_headers_b.id%TYPE
  ,p_contract_line_id    IN NUMBER
  ) RETURN NUMBER
 IS

     l_rent_accrual          NUMBER;

   -- mvasudev, 09/29/2004, Bug#3909240
 CURSOR c_rent_accrual(p_contract_id okc_k_headers_b.id%TYPE) IS
 SELECT NVL(SUM(SELB.AMOUNT),0)
 FROM
   OKL_STREAMS STMB,
   OKL_STRM_ELEMENTS SELB,
   OKL_STRM_TYPE_V STYV
 WHERE STMB.ID = SELB.STM_ID
 AND STMB.STY_ID = STYV.ID
 AND STYV.STREAM_TYPE_PURPOSE IN ('INVESTOR_PRETAX_INCOME','INVESTOR_RENTAL_ACCRUAL','INVESTOR_INTEREST_INCOME')
 AND STMB.SAY_CODE = 'CURR'
 AND STMB.ACTIVE_YN = 'Y'
 AND EXISTS (SELECT 1
             FROM OKL_POOL_CONTENTS POC,
                  OKL_POOLS POL,
                  OKL_STRM_TYPE_V STYS
             WHERE  POC.POL_ID = POL.ID
             AND    POC.KHR_ID = STMB.KHR_ID
             AND    POL.KHR_ID = P_CONTRACT_ID
             AND    POC.STY_ID = STYS.ID
             AND    STYS.STREAM_TYPE_SUBCLASS IN ('RENT','LOAN_PAYMENT') --Bug # 6740000 ssdeshpa--For Loan Contracts Addition into the Pool
             AND  POC.status_code <> Okl_Pool_Pvt.G_POC_STS_PENDING  --Added by VARANGAN -Pool Contents Impact(Bug#6658065)
	     );

 CURSOR c_rent_accrual_pending(p_contract_id okc_k_headers_b.id%TYPE) IS
 SELECT NVL(SUM(SELB.AMOUNT),0)
 FROM
   OKL_STREAMS STMB,
   OKL_STRM_ELEMENTS SELB,
   OKL_STRM_TYPE_V STYV
 WHERE STMB.ID = SELB.STM_ID
 AND STMB.STY_ID = STYV.ID
 AND STYV.STREAM_TYPE_PURPOSE IN ('INVESTOR_PRETAX_INCOME','INVESTOR_RENTAL_ACCRUAL','INVESTOR_INTEREST_INCOME')
 AND STMB.SAY_CODE = 'CURR'
 AND STMB.ACTIVE_YN = 'Y'
 AND EXISTS (SELECT 1 FROM OKL_POOL_CONTENTS POC,
                           OKL_POOLS POL,
                           OKL_STRM_TYPE_V STYS
             WHERE  POC.POL_ID = POL.ID
             AND    POC.KHR_ID = STMB.KHR_ID
             AND    POL.KHR_ID = P_CONTRACT_ID
             AND    POC.STY_ID = STYS.ID
             AND    STYS.STREAM_TYPE_SUBCLASS IN ('RENT','LOAN_PAYMENT') --Bug # 6740000 ssdeshpa--For Loan Contracts Addition into the Pool
             AND  POC.status_code = Okl_Pool_Pvt.G_POC_STS_PENDING);

 l_try_rsn OKL_POOL_TRANSACTIONS.TRANSACTION_REASON%TYPE;

 BEGIN
    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
      LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'p_transaction_reason' THEN
          l_try_rsn := OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE;
        END IF;
      END LOOP;
    END IF;

    IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
     OPEN c_rent_accrual_pending (p_contract_id);
     FETCH c_rent_accrual_pending INTO l_rent_accrual;
     CLOSE c_rent_accrual_pending;
    ELSE
     OPEN c_rent_accrual (p_contract_id);
     FETCH c_rent_accrual INTO l_rent_accrual;
     CLOSE c_rent_accrual;
    END IF;

   RETURN l_rent_accrual;

   EXCEPTION
     WHEN OTHERS THEN
      --Bug # 6740000 ssdeshpa added Start
      IF c_rent_accrual_pending%ISOPEN THEN
         CLOSE c_rent_accrual_pending;
      END IF;
      IF c_rent_accrual%ISOPEN THEN
         CLOSE c_rent_accrual;
      END IF;
      --Bug # 6740000 ssdeshpa added End
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                           p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                           p_token1        => 'OKL_SQLCODE',
                           p_token1_value  => SQLCODE,
                           p_token2        => 'OKL_SQLERRM',
                           p_token2_value  => SQLERRM);
       RETURN NULL;

END investor_rent_accural_amout;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : investor_user_amount_stake
-- Description     : get total investor stake by associated agreement from user enter amount
-- Business Rules  :
-- Parameters      :
-- Created By      : chenkuang.lee
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION investor_user_amount_stake(
  p_contract_id         IN okc_k_headers_b.id%TYPE
 ,p_contract_line_id    IN NUMBER
 ) RETURN NUMBER
IS
    l_amount         NUMBER;

CURSOR c_amt_stake(p_contract_id okc_k_headers_b.id%TYPE) IS
SELECT
  NVL(SUM(NVL(KLEB.AMOUNT,0)),0)
FROM
  OKL_K_LINES KLEB,
  OKC_K_LINES_B CLEB,
  OKC_LINE_STYLES_B LSEB
WHERE
  CLEB.ID = KLEB.ID AND
  CLEB.LSE_ID = LSEB.ID AND
  LSEB.LTY_CODE = 'INVESTMENT'   AND
  CLEB.DNZ_CHR_ID = p_contract_id;
-- akjain 01-28-2004
-- modified the cursor to simplify the query, removed join with OKX_PARTY

CURSOR c_add_amt_stake(p_contract_id okc_k_headers_b.id%TYPE) IS
SELECT
  NVL(SUM(NVL(KLEB.AMOUNT_STAKE,0)),0)
FROM
  OKL_K_LINES KLEB,
  OKC_K_LINES_B CLEB,
  OKC_LINE_STYLES_B LSEB
WHERE
  CLEB.ID = KLEB.ID AND
  CLEB.LSE_ID = LSEB.ID AND
  LSEB.LTY_CODE = 'INVESTMENT'   AND
  CLEB.DNZ_CHR_ID = p_contract_id;

l_try_rsn OKL_POOL_TRANSACTIONS.TRANSACTION_REASON%TYPE;

BEGIN

    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
      LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'p_transaction_reason' THEN
          l_try_rsn := OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE;
        END IF;
     END LOOP;
  END IF;

  IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
    OPEN c_add_amt_stake (p_contract_id);
    FETCH c_add_amt_stake INTO l_amount;
    CLOSE c_add_amt_stake;
  ELSE
    OPEN c_amt_stake (p_contract_id);
    FETCH c_amt_stake INTO l_amount;
    CLOSE c_amt_stake;
  END IF;

  RETURN l_amount;

  EXCEPTION
    WHEN OTHERS THEN
    --Bug # 6740000 ssdeshpa added Start
    IF c_add_amt_stake%ISOPEN THEN
       CLOSE c_add_amt_stake;
    END IF;
    --Bug # 6740000 ssdeshpa added End
    --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
    OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END investor_user_amount_stake;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : investor_stream_amount
-- Description     : get total investor stream amount by associated agreement's pool contents
-- Business Rules  :
-- Parameters      : p_contract_id
-- Created By      : chenkuang.lee
-- last modified by: ssdeshpa
-- Version         : 2.0
-- comments        : modified for the subclass changes 01-28-2004
-- returns         : Total securitized streams amount * revenue share percent
-- Version         : 3.0
-- comments        : Bug # 6740000 modified for the Addition of Loan Contracts into the Pool changes
-- End of comments
----------------------------------------------------------------------------------
  FUNCTION investor_stream_amount(
   p_contract_id         IN okc_k_headers_b.id%TYPE
  ,p_contract_line_id    IN NUMBER
  ) RETURN NUMBER
 IS

   x_value          NUMBER;
   l_pol_id         okl_pools.id%TYPE;
   l_percent_stake  NUMBER;
   G_FINAL_DATE   CONSTANT    DATE    	:= TO_DATE('1','j') + 5300000;


 CURSOR l_khr_csr(p_khr_id okc_k_headers_b.id%TYPE) IS
   SELECT polb.id
 FROM okl_pools polb
 WHERE polb.khr_id = p_khr_id;

 -- get revenue share by subclass
 CURSOR l_okl_percent_stake_csr(p_sty_subclass IN VARCHAR2)
    IS
    SELECT DISTINCT kleb.percent_stake,clet.id
    FROM   okl_k_lines kleb,
           okc_k_lines_b clet,
           okc_k_lines_b cles
    WHERE  kleb.id = cles.id
    AND    cles.cle_id = clet.id
    AND    clet.dnz_chr_id = p_contract_id
    AND    kleb.stream_type_subclass = p_sty_subclass;

 -- get pool streams amount by subclass
   CURSOR l_streams_amount_csr (p_pol_id  NUMBER, p_stm_sub_class VARCHAR2)
   IS
 SELECT
  NVL(SUM(NVL(selb.AMOUNT,0)),0) AMOUNT
 FROM
       okl_strm_type_v  styv,
       okl_streams       stmb,
       okl_strm_elements selb,
       okl_pool_contents pocb
 WHERE  styv.stream_type_subclass = p_stm_sub_class
 AND    styv.id = stmb.sty_id
 AND    stmb.id       = selb.stm_id
 AND    pocb.pol_id   = p_pol_id
 AND    stmb.ID   = pocb.STM_ID
 AND    stmb.say_code = 'CURR'
 AND    stmb.active_yn = 'Y'
 AND    selb.STREAM_ELEMENT_DATE
        BETWEEN pocb.STREAMS_FROM_DATE AND NVL(pocb.STREAMS_TO_DATE, G_FINAL_DATE)
  AND  pocb.status_code <> Okl_Pool_Pvt.G_POC_STS_PENDING ; --Added by VARANGAN -Pool Contents Impact(Bug#6658065)

 -- get pool streams amount by subclass
   CURSOR l_streams_amount_pending_csr (p_pol_id  NUMBER, p_stm_sub_class VARCHAR2)
   IS
 SELECT
  NVL(SUM(NVL(selb.AMOUNT,0)),0) AMOUNT
 FROM
       okl_strm_type_v  styv,
       okl_streams       stmb,
       okl_strm_elements selb,
       okl_pool_contents pocb
 WHERE  styv.stream_type_subclass = p_stm_sub_class
 AND    styv.id = stmb.sty_id
 AND    stmb.id       = selb.stm_id
 AND    pocb.pol_id   = p_pol_id
 AND    stmb.ID   = pocb.STM_ID
 AND    stmb.say_code = 'CURR'
 AND    stmb.active_yn = 'Y'
 AND    selb.STREAM_ELEMENT_DATE
        BETWEEN pocb.STREAMS_FROM_DATE AND NVL(pocb.STREAMS_TO_DATE, G_FINAL_DATE)
  AND  pocb.status_code = Okl_Pool_Pvt.G_POC_STS_PENDING ;

 l_total_percent NUMBER := 0;
 l_total_sec_amount  NUMBER := 0;
 l_per_subclass_amount NUMBER := 0;
 l_try_rsn OKL_POOL_TRANSACTIONS.TRANSACTION_REASON%TYPE;

 BEGIN

   FOR l_khr_csr_rec IN l_khr_csr(p_contract_id)
   LOOP
     l_pol_id := l_khr_csr_rec.id;
   END LOOP;

   IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
       FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
       LOOP
         IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'p_transaction_reason' THEN
           l_try_rsn := OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE;
         END IF;
       END LOOP;
     END IF;

   IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
      FOR l_streams_amount_pending_rec IN l_streams_amount_pending_csr(l_pol_id, 'RENT')
     LOOP
       l_per_subclass_amount := l_streams_amount_pending_rec.amount;
       FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('RENT')
       LOOP
         l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
       END LOOP;
     END LOOP;
   ELSE
     FOR l_streams_amount_csr_rec IN l_streams_amount_csr(l_pol_id, 'RENT')
     LOOP
       l_per_subclass_amount := l_streams_amount_csr_rec.amount;
       FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('RENT')
       LOOP
         l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
       END LOOP;
     END LOOP;
    END IF;
     l_total_sec_amount := (l_total_percent/100) * l_per_subclass_amount;
     l_total_percent := 0;
     l_per_subclass_amount := 0;

   IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
     FOR l_streams_amount_pending_rec IN l_streams_amount_pending_csr(l_pol_id, 'RESIDUAL')
     LOOP
       l_per_subclass_amount := l_streams_amount_pending_rec.amount;
       FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('RESIDUAL')
       LOOP
         l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
       END LOOP;
      END LOOP;
   ELSE
     FOR l_streams_amount_csr_rec IN l_streams_amount_csr(l_pol_id, 'RESIDUAL')
     LOOP
       l_per_subclass_amount := l_streams_amount_csr_rec.amount;
       FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('RESIDUAL')
       LOOP
         l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
       END LOOP;
      END LOOP;
    END IF;
    --Bug # 6740000 Changes for Adding the Loan Contracts Into Pool
    l_total_sec_amount := l_total_sec_amount + ((l_total_percent/100) * l_per_subclass_amount);
    l_total_percent := 0;
    l_per_subclass_amount := 0;

    IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
      FOR l_streams_amount_pending_rec IN l_streams_amount_pending_csr(l_pol_id, 'LOAN_PAYMENT')
      LOOP
        l_per_subclass_amount := l_streams_amount_pending_rec.amount;
        FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('LOAN_PAYMENT')
        LOOP
          l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
        END LOOP;
      END LOOP;
    ELSE
      FOR l_streams_amount_csr_rec IN l_streams_amount_csr(l_pol_id, 'LOAN_PAYMENT')
      LOOP
        l_per_subclass_amount := l_streams_amount_csr_rec.amount;
        FOR l_okl_percent_stake_rec IN l_okl_percent_stake_csr('LOAN_PAYMENT')
        LOOP
          l_total_percent := l_total_percent + l_okl_percent_stake_rec.percent_stake;
        END LOOP;
      END LOOP;
    END IF;
   l_total_sec_amount := l_total_sec_amount + ((l_total_percent/100) * l_per_subclass_amount);
    --Bug # 6740000 Changes for Adding the Loan Contracts Into Pool End
   x_value := l_total_sec_amount;

   RETURN x_value;

   EXCEPTION
     WHEN OTHERS THEN
      --Bug # 6740000 ssdeshpa added Start
      IF l_khr_csr%ISOPEN THEN
         CLOSE l_khr_csr;
      END IF;
      IF l_okl_percent_stake_csr%ISOPEN THEN
         CLOSE l_okl_percent_stake_csr;
      END IF;
      IF l_streams_amount_csr%ISOPEN THEN
         CLOSE l_streams_amount_csr;
      END IF;
      IF l_streams_amount_pending_csr%ISOPEN THEN
         CLOSE l_streams_amount_pending_csr;
      END IF;
      --Bug # 6740000 ssdeshpa added End
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
       OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                           p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                           p_token1        => 'OKL_SQLCODE',
                           p_token1_value  => SQLCODE,
                           p_token2        => 'OKL_SQLERRM',
                           p_token2_value  => SQLERRM);
       RETURN NULL;

END investor_stream_amount;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : fee_idc_amount
-- Description     : gets the sum of fee idc amount for a given contract
-- Business Rules  :
-- Parameters      :
-- Created By      : smereddy
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION fee_idc_amount(
  p_dnz_chr_id         IN NUMBER
 ,p_kle_id             IN NUMBER
 ) RETURN NUMBER
IS

l_sum_idc_amt  NUMBER;

-- smereddy 06/17/03 calculates sum of fee idc
CURSOR sum_idc_csr(l_dnz_chr_id okc_k_headers_b.id%TYPE) IS
SELECT
  NVL(SUM(NVL(KLEB.initial_direct_cost,0)),0)
FROM
  OKL_K_LINES KLEB,
  OKC_K_LINES_B CLEB,
  OKC_LINE_STYLES_B LSEB
WHERE
  KLEB.ID = CLEB.ID AND
  CLEB.LSE_ID = LSEB.ID AND
  LSEB.LTY_CODE = 'FEE' AND
  KLEB.FEE_TYPE IN ('EXPENSE','MISCELLANEOUS') AND
  CLEB.CHR_ID = l_dnz_chr_id AND
  CLEB.STS_CODE IN ('APPROVED', 'COMPLETE');
-- added COMPLETE to resolve bug # 3152093

BEGIN

  OPEN sum_idc_csr (p_dnz_chr_id);
  FETCH sum_idc_csr INTO l_sum_idc_amt;
  CLOSE sum_idc_csr;

  RETURN l_sum_idc_amt;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END fee_idc_amount;


-- 09/05/03 jsanju start
--for cure calculation

 FUNCTION contract_delinquent_amt (
  p_contract_id         IN okc_k_headers_b.id%TYPE
 ,p_contract_line_id    IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER IS

-- ASHIM CHANGE - START

/*
  CURSOR c_amount_past_due(p_contract_id IN NUMBER,
                           p_grace_days  IN NUMBER) IS
    SELECT SUM(NVL(aps.amount_due_remaining, 0)) past_due_amount
    FROM   okl_cnsld_ar_strms_b ocas
           ,ar_payment_schedules aps
           , okl_strm_type_v sm
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.receivables_invoice_id = aps.customer_trx_id
    AND    aps.class ='INV'
    AND    (aps.due_date + p_grace_days) < SYSDATE
    AND    NVL(aps.amount_due_remaining, 0) > 0
    AND    sm.id = ocas.STY_ID
    AND    sm.name <> 'CURE';*/

  CURSOR c_amount_past_due(p_contract_id IN NUMBER,
                           p_grace_days  IN NUMBER) IS
    SELECT SUM(NVL(aps.amount_due_remaining, 0)) past_due_amount
    FROM   okl_bpd_tld_ar_lines_v ocas
           ,ar_payment_schedules aps
           , okl_strm_type_v sm
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.customer_trx_id = aps.customer_trx_id
    AND    aps.class ='INV'
    AND    (aps.due_date + p_grace_days) < SYSDATE
    AND    NVL(aps.amount_due_remaining, 0) > 0
    AND    sm.id = ocas.STY_ID
    AND    sm.name <> 'CURE';

-- ASHIM CHANGE - END

  l_contract_number okc_k_headers_b.contract_number%TYPE;
  l_rule_name     VARCHAR2(200);
  l_rule_value    VARCHAR2(2000);
  l_return_Status VARCHAR2(1):=FND_Api.G_RET_STS_SUCCESS;
  l_id1           VARCHAR2(40);
  l_id2           VARCHAR2(200);
  l_days_allowed  NUMBER :=0;
  l_program_id okl_k_headers.khr_id%TYPE;
  l_delinquent_amount NUMBER :=0;


 BEGIN
   IF (G_DEBUG_ENABLED = 'Y') THEN
     G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
   END IF;

       SELECT khr_id INTO l_program_id
       FROM okl_k_headers
       WHERE id=p_contract_id;


      l_return_status := okl_contract_info.get_rule_value(
                              p_contract_id     => l_program_id
                             ,p_rule_group_code => 'COCURP'
                             ,p_rule_code		=> 'COCURE'
                             ,p_segment_number	=> 3
                             ,x_id1             => l_id1
                             ,x_id2             => l_id2
                             ,x_value           => l_rule_value);

         l_days_allowed :=NVL(l_rule_value,0);



      -- Get Past Due Amount with maximium days allowed
      OPEN  c_amount_past_due (p_contract_id,l_days_allowed);
      FETCH c_amount_past_due INTO l_delinquent_amount;
      CLOSE c_amount_past_due;
      RETURN l_delinquent_amount;

 EXCEPTION
 WHEN OTHERS THEN

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, ' in   contract_delinquent_amt'||SQLERRM);
     END IF;
     OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN l_delinquent_amount;

 END contract_delinquent_amt;

 FUNCTION cumulative_vendor_invoice_amt (
  p_contract_id         IN okc_k_headers_b.id%TYPE
 ,p_contract_line_id    IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER IS

  CURSOR c_vendor_invoice_amt (p_contract_id IN NUMBER) IS
  SELECT NVL(SUM(negotiated_amount),0)
  FROM  okl_cure_amounts
  WHERE chr_id =p_contract_id
  AND   status ='CURESINPROGRESS';

  l_vendor_invoice_amt NUMBER;

 BEGIN
      OPEN  c_vendor_invoice_amt(p_contract_id);
      FETCH c_vendor_invoice_amt INTO l_vendor_invoice_amt;
      CLOSE c_vendor_invoice_amt;

      RETURN l_vendor_invoice_amt;

 END cumulative_vendor_invoice_amt;


 FUNCTION contract_short_fund_amt (
  p_contract_id         IN okc_k_headers_b.id%TYPE
 ,p_contract_line_id    IN NUMBER  DEFAULT OKL_API.G_MISS_NUM
 ) RETURN NUMBER IS

  CURSOR c_get_short_fund_amt (p_contract_id IN NUMBER) IS
  SELECT NVL(SUM(short_fund_amount),0)
  FROM  okl_cure_amounts
  WHERE chr_id =p_contract_id
  AND   status ='CURESINPROGRESS';

  l_short_fund_amt NUMBER;

 BEGIN
      OPEN  c_get_short_fund_amt(p_contract_id);
      FETCH c_get_short_fund_amt INTO l_short_fund_amt;
      CLOSE c_get_short_fund_amt;

      RETURN l_short_fund_amt;

 END contract_short_fund_amt;

-- 09/05/03 jsanju end

------------------------------------------
--Bug# 3143522 avsingh : 11.5.10 Subsidies
------------------------------------------
--Bug# 3638568 : Modified function to conditionally include terminated lines if called from pricing
--------------------------------------------------------------------------------
--start of comments
--Name        : line_discount
--Purpose     : To calculate total discount on a financial asset line
--Parameters  : IN - p_chr_id  contract header id
--                 - p_line id financial asset line id
-- Return     : Total line discount
-- History    : 16-SEP-2003  avsingh Creation
--end of comments
--------------------------------------------------------------------------------
FUNCTION line_discount(
           p_chr_id    IN NUMBER,
           p_line_id   IN NUMBER) RETURN NUMBER IS

l_api_version    NUMBER DEFAULT 1.0;
l_return_status  VARCHAR2(1) DEFAULT Okl_Api.G_RET_STS_SUCCESS;
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);

l_line_discount NUMBER;
l_discount      NUMBER;
l_discount_incl_terminated BOOLEAN := FALSE;

  --cursor to get line_sts
  CURSOR l_line_sts_csr (p_cle_id IN NUMBER) IS
  SELECT stsb.ste_code
  FROM   okc_statuses_b stsb,
         okc_k_lines_b  cleb
  WHERE  stsb.code      = cleb.sts_code
  AND    cleb.id        = p_cle_id;

  l_line_sts_rec     l_line_sts_csr%ROWTYPE;

  --cursor to get financial asset lines on a contract (without terminated lines)
  CURSOR l_cleb_csr (p_chr_id IN NUMBER) IS
  SELECT cleb.id
  FROM   okc_k_lines_b cleb,
         okc_statuses_b stsb,
         okc_line_styles_b lseb
  WHERE  cleb.chr_id     = p_chr_id
  AND    cleb.lse_id     = lseb.id
  AND    lseb.lty_code   = 'FREE_FORM1'
  AND    cleb.sts_code   = stsb.code
  AND    stsb.ste_code   NOT IN ('HOLD','EXPIRED','TERMINATED','CANCELLED');

  --cursor to get financial asset lines on a contract (with terminated lines)
  CURSOR l_cleb_termn_csr (p_chr_id IN NUMBER) IS
  SELECT cleb.id
  FROM   okc_k_lines_b cleb,
         okc_statuses_b stsb,
         okc_line_styles_b lseb
  WHERE  cleb.chr_id     = p_chr_id
  AND    cleb.lse_id     = lseb.id
  AND    lseb.lty_code   = 'FREE_FORM1'
  AND    cleb.sts_code   = stsb.code
  AND    stsb.ste_code   NOT IN ('HOLD','EXPIRED','CANCELLED');

  l_cle_id    okc_k_lines_b.ID%TYPE;


BEGIN

    --IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0
       --AND Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(0).NAME = 'TERMINATED_LINES_YN'
       --AND  Okl_Execute_Formula_Pub.g_additional_parameters(0).value = 'Y' THEN
		 -- l_discount_incl_terminated := TRUE;
    --END IF;

           -- rmunjulu 4042892
    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_discount_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;

     IF p_line_id IS NOT NULL THEN
         --Get the line status
         OPEN l_line_sts_csr(p_cle_id => p_line_id);
         FETCH l_line_sts_csr INTO l_line_sts_rec;
         CLOSE l_line_sts_csr;

         IF l_line_sts_rec.ste_code IS NULL THEN
             l_line_discount := 0;
         ELSIF (l_line_sts_rec.ste_code IN ('HOLD','EXPIRED','CANCELLED'))
               OR   (l_line_sts_rec.ste_code = 'TERMINATED' AND
                     NOT (l_discount_incl_terminated)) THEN
             l_line_discount := 0;
         ELSIF (l_line_sts_rec.ste_code NOT IN ('HOLD','EXPIRED','TERMINATED''CANCELLED'))
                OR (l_line_sts_rec.ste_code = 'TERMINATED' AND
                    (l_discount_incl_terminated)) THEN

             Okl_Subsidy_Process_Pvt.get_asset_subsidy_amount
                                     (p_api_version       => l_api_version,
                                      p_init_msg_list     => Okl_Api.G_FALSE,
                                      x_msg_data           => l_msg_data,
                                      x_msg_count          => l_msg_count,
                                      x_return_status      => l_return_status,
                                      p_asset_cle_id       => p_line_id,
                                      p_accounting_method  => 'NET',
                                      x_subsidy_amount     => l_line_discount);
             IF l_return_status  <> Okl_Api.G_RET_STS_SUCCESS THEN
                RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
             END IF;
         END IF;

      ELSIF (p_line_id IS NULL) AND (p_chr_id IS NOT NULL) THEN
         l_line_discount := 0;
         IF (l_discount_incl_terminated) THEN
             OPEN l_cleb_termn_csr(p_chr_id => p_chr_id);
             LOOP
                 FETCH l_cleb_termn_csr INTO l_cle_id;
                 EXIT WHEN l_cleb_termn_csr%NOTFOUND;
                 Okl_Subsidy_Process_Pvt.get_asset_subsidy_amount
                                 (p_api_version       => l_api_version,
                                  p_init_msg_list     => Okl_Api.G_FALSE,
                                  x_msg_data           => l_msg_data,
                                  x_msg_count          => l_msg_count,
                                  x_return_status      => l_return_status,
                                  p_asset_cle_id       => l_cle_id,
                                  p_accounting_method  => 'NET',
                                  x_subsidy_amount     => l_discount);
                 IF l_return_status  <> Okl_Api.G_RET_STS_SUCCESS THEN
                     RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                 END IF;
                 l_line_discount := l_line_discount + l_discount;
             END LOOP;
             CLOSE l_cleb_termn_csr;
         ELSIF NOT  (l_discount_incl_terminated) THEN
             OPEN l_cleb_csr(p_chr_id => p_chr_id);
             LOOP
                 FETCH l_cleb_csr INTO l_cle_id;
                 EXIT WHEN l_cleb_csr%NOTFOUND;
                 Okl_Subsidy_Process_Pvt.get_asset_subsidy_amount
                                 (p_api_version       => l_api_version,
                                  p_init_msg_list     => Okl_Api.G_FALSE,
                                  x_msg_data           => l_msg_data,
                                  x_msg_count          => l_msg_count,
                                  x_return_status      => l_return_status,
                                  p_asset_cle_id       => l_cle_id,
                                  p_accounting_method  => 'NET',
                                  x_subsidy_amount     => l_discount);
                 IF l_return_status  <> Okl_Api.G_RET_STS_SUCCESS THEN
                     RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                 END IF;
                 l_line_discount := l_line_discount + l_discount;
             END LOOP;
             CLOSE l_cleb_csr;
         END IF;
      ELSIF (p_line_id IS NULL) AND (p_chr_id IS NULL) THEN
             RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
      RETURN (l_line_discount);

     EXCEPTION
     WHEN OTHERS THEN
     IF l_cleb_csr%ISOPEN THEN
         CLOSE l_cleb_csr;
     END IF;
     IF l_cleb_termn_csr%ISOPEN THEN
         CLOSE l_cleb_termn_csr;
     END IF;
     IF l_line_sts_csr%ISOPEN THEN
         CLOSE l_line_sts_csr;
     END IF;
     Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;
END line_discount;
--------------------------------------------------------------------------------
--start of comments
--Name        : contract_discount
--Purpose     : To calculate total discount on a contract
--Parameters  : IN - p_chr_id  contract header id
--                 - p_line id financial asset line id
-- Return     : Total contract discount
-- History    : 16-SEP-2003  avsingh Creation
--end of comments
--------------------------------------------------------------------------------
FUNCTION contract_discount(
           p_chr_id    IN NUMBER,
           p_line_id   IN NUMBER) RETURN NUMBER IS

l_api_version    NUMBER DEFAULT 1.0;
l_return_status  VARCHAR2(1) DEFAULT OKL_API.G_RET_STS_SUCCESS;
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);

l_contract_discount NUMBER;
BEGIN
     IF (p_line_id IS NOT NULL) OR (p_chr_id IS NOT NULL)  THEN
        l_contract_discount := line_discount(p_chr_id,p_line_id);
      ELSIF (p_line_id IS NULL) AND (p_chr_id IS NULL) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      RETURN (l_contract_discount);
     EXCEPTION
     WHEN OTHERS THEN
     OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;
END contract_discount;
----------------------------------------------
--End Bug# 3143522 avsingh : 11.5.10 Subsidies
----------------------------------------------
-----------------------------------------------------------------------
--Start Bug# 3036581 : avsingh new formula CONTRACT_AMORTIZED_EXPENSES
-----------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:    avsingh
    -- Function Name  contract_amortized_expenses
    -- Description:   returns the sum of amount on stream type - Amortized Expense.
    -- Dependencies:
    -- Parameters: contract id.
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION contract_amortized_expenses(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(30) := 'CONTRACT_AMORTIZED_EXPENSES';
    l_api_version       CONSTANT NUMBER       := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(2000);

    l_amortized_expenses NUMBER := 0;

    ---------------------------------------------------
    --cursor to get sum of line level amortized expenses
    ---------------------------------------------------
    CURSOR l_line_amortexp_csr (chrId NUMBER ) IS
    SELECT NVL(SUM(sele.amount),0) amount
    FROM okl_strm_elements sele,
         okl_streams str,
         --okl_strm_type_tl sty,
         okl_strm_type_v sty,
         okl_K_lines_full_v kle,
         okc_statuses_b sts
    WHERE sele.stm_id = str.id
       AND str.sty_id = sty.id
       --AND UPPER(sty.name)  = 'AMORTIZED EXPENSE'
       AND sty.stream_type_purpose = 'AMORTIZED_FEE_EXPENSE'
       --AND sty.LANGUAGE = 'US'
       AND str.say_code = 'CURR'
       AND str.active_yn = 'Y'
       AND NVL( str.purpose_code, 'XXXX' ) <>  'REPORT'
       AND str.khr_id = chrId
       AND NVL(str.kle_id,-9999) = kle.id
       AND kle.dnz_chr_id = chrId
       AND kle.sts_code = sts.code
       AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');

        l_line_amortexp_rec l_line_amortexp_csr%ROWTYPE;

    -----------------------------------------------------
    --Cursor to get sum of contract level amortized expenses
    -----------------------------------------------------
    CURSOR l_chr_amortexp_csr (chrId NUMBER) IS
    SELECT NVL(SUM(sele.amount),0) amount
    FROM okl_strm_elements sele,
         okl_streams str,
         --okl_strm_type_tl sty
         okl_strm_type_v sty
    WHERE sele.stm_id = str.id
       AND str.sty_id = sty.id
       --AND UPPER(sty.name) = 'AMORTIZED EXPENSE'
       AND sty.stream_type_purpose = 'AMORTIZED_FEE_EXPENSE'
       --AND sty.LANGUAGE = 'US'
       AND str.say_code = 'CURR'
       AND str.active_yn = 'Y'
       AND NVL( str.purpose_code, 'XXXX' ) <> 'REPORT'
       AND str.khr_id = chrId
       AND NVL(str.kle_id, -9999) = -9999;

    l_chr_amortexp_rec    l_chr_amortexp_csr%ROWTYPE;

BEGIN

       IF ( NVL(p_chr_id,OKL_API.G_MISS_NUM)  = OKL_API.G_MISS_NUM ) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       OPEN l_line_amortexp_csr( p_chr_id );
       FETCH l_line_amortexp_csr INTO l_line_amortexp_rec;
       CLOSE l_line_amortexp_csr;

       OPEN l_chr_amortexp_csr( p_chr_id );
       FETCH l_chr_amortexp_csr INTO l_chr_amortexp_rec;
       CLOSE l_chr_amortexp_csr;

       l_amortized_expenses := l_line_amortexp_rec.amount + l_chr_amortexp_rec.amount;

      RETURN l_amortized_expenses;


    EXCEPTION
        WHEN OTHERS  THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;

END contract_amortized_expenses;
-------------------------------------------------
--End Bug# 3036581 avsingh : 11.5.10
-------------------------------------------------

-------------------------------------------------
--Bug# 3143522 mdokal : 11.5.10 AM Securitization
-------------------------------------------------

------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    Manjit Dokal - 18-JUL-2003
  -- Function Name: investor_rent_factor
  -- Description:   Calculate Investor Rent Factor
  -- Dependencies:  OKL building blocks AMTX and AMUV,
  -- Parameters:    IN:  p_contract_id, p_contract_line_id (optional)
  --                OUT: amount
  -- History        rmunjulu EDAT Changed to get unbilled streams after
  --                quote eff date and ALL undisbursed amount
  --              : PAGARG Bug# 4012614 User Defined Streams impact
  --              : 06-Dec-2004 PAGARG Bug# 3948473
  --              : obtain investor agreement id from additional parameters and
  --              : and use it to get stream id for INVESTOR_RENT_DISB_BASIS
  --              : 07-Jan-2004 PAGARG Bug# 3948473. Removed the billable_yn
  --              : accrual_yn joins from undisbursed investor rent streams cursor
  --              : gboomina bug 4775555 Modified to get FUTURE BILLS (billed and not billed from term date onwards)
  --                and FUTURE DISBURSEMENTS (disbursed and not disbursed from term date onwards)

  -- Version:       1.0
  -- End of Commnets
------------------------------------------------------------------------------

FUNCTION investor_rent_factor (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS

    --Bug# 4012614 PAGARG modified the cursor for User Defined Streams Impact
	-- Get Unbilled Streams
	-- rmunjulu EDAT unbilled after quote eff from date
CURSOR l_unbill_stream_csr (
                                             cp_contract_id NUMBER,
                                             cp_contract_line_id NUMBER,
                                             cp_date DATE,
                                             cp_sty_id NUMBER) IS
SELECT NVL(SUM (NVL (ste.amount, 0)),0) amount_due
FROM okl_streams stm,
           okl_strm_type_b sty,
           okl_strm_elements ste
          ,okl_pool_contents pocb
WHERE stm.khr_id      = cp_contract_id
AND	stm.kle_id	= NVL(cp_contract_line_id, stm.kle_id)
AND	stm.active_yn = 'Y'
AND	stm.say_code = 'CURR'
AND	ste.stm_id	= stm.id
AND NVL (ste.amount, 0)	<> 0
AND sty.id              = stm.sty_id
AND sty.id              = cp_sty_id
AND sty.billable_yn     = 'Y'
AND ste.stream_element_date > cp_date -- rmunjulu EDAT
AND pocb.status_Code <> 'PENDING'
AND pocb.khr_id = stm.khr_id
AND pocb.kle_id = stm.kle_id
AND pocb.sty_id = stm.sty_id;

    --Bug# 4012614 PAGARG modified the cursor for User Defined Streams Impact
-- Get Undisbursed Investor Rent Streams
CURSOR l_undisb_rent_stream_csr (
                                                      cp_contract_id NUMBER,
                                                      cp_contract_line_id NUMBER,
                                                      cp_sty_id NUMBER,
                                                      cp_date  DATE) IS --gboomina bug 4775555
SELECT NVL(SUM (NVL (ste.amount, 0)),0) amount_payable
FROM okl_streams stm,
          okl_strm_type_b     sty,
          okl_strm_elements ste
         -- ,okl_pool_contents pocb
WHERE stm.khr_id  = cp_contract_id
AND stm.kle_id = NVL(cp_contract_line_id, stm.kle_id)
AND stm.active_yn = 'Y'
AND stm.say_code= 'CURR'
AND	ste.stm_id	= stm.id
AND NVL (ste.amount, 0)	<> 0
AND sty.id              = stm.sty_id
AND sty.id              = cp_sty_id
AND ste.stream_element_date > cp_date -- gboomina bug 4775555 -- check for disbs after termination
--AND pocb.status_Code <> 'PENDING' -- commented by sosharma for bug 9284305
--AND pocb.khr_id = stm.khr_id
--AND pocb.kle_id = stm.kle_id
--AND pocb.sty_id = stm.sty_id
;

CURSOR l_unbill_stream_pending_csr (
                                                         cp_contract_id NUMBER,
                                                         cp_contract_line_id NUMBER,
                                                         cp_date DATE,
                                                         cp_sty_id NUMBER) IS
SELECT NVL(SUM (NVL (ste.amount, 0)),0) amount_due
FROM okl_streams stm,
           okl_strm_type_b sty,
           okl_strm_elements ste
           ,okl_pool_contents pocb
WHERE stm.khr_id = cp_contract_id
AND stm.kle_id = NVL(cp_contract_line_id, stm.kle_id)
AND stm.active_yn = 'Y'
AND stm.say_code = 'CURR'
AND ste.stm_id = stm.id
AND NVL (ste.amount, 0) <> 0
AND sty.id  = stm.sty_id
AND sty.id              = cp_sty_id
AND sty.billable_yn     = 'Y'
AND ste.stream_element_date > cp_date
AND pocb.status_Code = 'PENDING'
AND pocb.khr_id = stm.khr_id
AND pocb.kle_id = stm.kle_id
AND pocb.sty_id = stm.sty_id;

  -- Get Undisbursed Investor Rent Streams
CURSOR l_undisb_rent_strm_pndg_csr (
                                                                   cp_contract_id NUMBER,
                                                                   cp_contract_line_id NUMBER,
                                                                   cp_sty_id NUMBER,
                                                                   cp_date DATE) IS
SELECT	NVL(SUM (NVL (ste.amount, 0)),0)  amount_payable
FROM okl_streams stm,
           okl_strm_type_b sty,
           okl_strm_elements ste
           --,okl_pool_contents pocb
WHERE stm.khr_id = cp_contract_id
AND stm.kle_id = NVL(cp_contract_line_id, stm.kle_id)
AND	stm.active_yn = 'Y'
AND stm.say_code = 'CURR'
AND	ste.stm_id = stm.id
AND NVL (ste.amount, 0)	<> 0
AND sty.id = stm.sty_id
AND sty.id              = cp_sty_id
AND ste.stream_element_date > cp_date
--AND pocb.status_Code = 'PENDING' -- commented by sosharma for bug 9284305
--AND pocb.khr_id = stm.khr_id
--AND pocb.kle_id = stm.kle_id
--AND pocb.sty_id = stm.sty_id
;


l_unbill_rent_amount		NUMBER		:= 0;
l_undisb_rent_amount		NUMBER		:= 0;
l_result_amount             NUMBER      := 0;
l_try_rsn OKL_POOL_TRANSACTIONS.TRANSACTION_REASON%TYPE;

-- rmunjulu EDAT
CURSOR get_quote_date_csr (p_quote_id IN NUMBER) IS
SELECT trunc(qte.date_effective_from) date_effective_from
FROM   okl_trx_quotes_b  qte
WHERE  qte.id = p_quote_id;

 -- rmunjulu EDAT
        l_quote_id NUMBER;
        l_quote_date DATE;
        l_sysdate DATE;
        l_sty_id            OKL_STRM_TYPE_TL.ID%TYPE := 0;
        l_return_status     VARCHAR2(3) := Okl_Api.G_RET_STS_SUCCESS;
    --06-Dec-2004 PAGARG Bug# 3948473 variable to store investor agreement id
    l_inv_agr_id    NUMBER;
BEGIN
	-- ****************
	-- Calculate result
	-- ****************
	-- rmunjulu EDAT
    IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
      FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
      LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).name = 'quote_id' THEN
           l_quote_id := TO_NUMBER(OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).value);
        --06-Dec-2004 PAGARG Bug# 3948473 obtain investor agreement id
        ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).name = 'inv_agr_id' THEN
           l_inv_agr_id := TO_NUMBER(OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).value);
        ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'p_transaction_reason' THEN
          l_try_rsn := OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE;
        END IF;
      END LOOP;
    END IF;

    -- rmunjulu EDAT
    select sysdate into l_sysdate from dual;

    -- rmunjulu EDAT
	IF  l_quote_id IS NOT NULL
	AND l_quote_id <> OKL_API.G_MISS_NUM THEN

	   FOR get_quote_date_rec IN get_quote_date_csr (l_quote_id) LOOP
	      l_quote_date := get_quote_date_rec.date_effective_from;
	   END LOOP;
    END IF;

	-- rmunjulu EDAT
    IF l_quote_date IS NULL
    OR l_quote_date = OKL_API.G_MISS_DATE THEN
       l_quote_date := l_sysdate;
    END IF;

    --PAGARG 19-Nov-2004 Bug# 4012614
    --UDS impact. Obtain stream type id and pass it to cursor
    OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                            'RENT',
                                            l_return_status,
                                            l_sty_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

        IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
          OPEN l_unbill_stream_pending_csr (p_contract_id, p_contract_line_id,l_quote_date, l_sty_id);
          FETCH l_unbill_stream_pending_csr INTO l_unbill_rent_amount;
          CLOSE l_unbill_stream_pending_csr;
        ELSE
          OPEN l_unbill_stream_csr (p_contract_id, p_contract_line_id,l_quote_date, l_sty_id);
          FETCH l_unbill_stream_csr INTO l_unbill_rent_amount;
          CLOSE l_unbill_stream_csr;
        END IF;

    --06-Dec-2004 PAGARG Bug# 3948473 Pass investor agreement id to obtain stream id
    OKL_STREAMS_UTIL.get_primary_stream_type(l_inv_agr_id,
                                            'INVESTOR_RENT_DISB_BASIS',
                                            l_return_status,
                                            l_sty_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
      OPEN	l_undisb_rent_strm_pndg_csr (p_contract_id, p_contract_line_id, l_sty_id,l_quote_date);
      FETCH l_undisb_rent_strm_pndg_csr INTO l_undisb_rent_amount;
      CLOSE l_undisb_rent_strm_pndg_csr;
    ELSE
      OPEN	l_undisb_rent_stream_csr (p_contract_id, p_contract_line_id, l_sty_id,l_quote_date); -- gboomina bug 4775555 pass term date
      FETCH l_undisb_rent_stream_csr INTO l_undisb_rent_amount;
      CLOSE l_undisb_rent_stream_csr;
    END IF;

    -- this condition is included to prevent 'ORA-01476: divisor is equal to zero' error
    -- need to seed a new message
    IF l_unbill_rent_amount = 0 THEN
        l_result_amount := 0;
    ELSE
        l_result_amount := l_undisb_rent_amount/l_unbill_rent_amount;
    END IF;

 RETURN l_result_amount;

EXCEPTION

	WHEN OTHERS THEN

           -- Close open cursors
           IF l_unbill_stream_csr%ISOPEN THEN
		CLOSE l_unbill_stream_csr;
           END IF;
           IF l_undisb_rent_stream_csr%ISOPEN THEN
           	CLOSE l_undisb_rent_stream_csr;
           END IF;
           IF l_unbill_stream_pending_csr%ISOPEN THEN
		CLOSE l_unbill_stream_pending_csr;
           END IF;
           IF l_undisb_rent_strm_pndg_csr%ISOPEN THEN
		CLOSE l_undisb_rent_strm_pndg_csr;
           END IF;
	-- store SQL error message on message stack for caller
	OKL_API.SET_MESSAGE (
		p_app_name	=> OKL_API.G_APP_NAME,
		p_msg_name	=> 'OKL_CONTRACTS_UNEXPECTED_ERROR',
		p_token1	=> 'SQLCODE',
		p_token1_value	=> SQLCODE,
		p_token2	=> 'SQLERRM',
		p_token2_value	=> SQLERRM);

		RETURN NULL;

END investor_rent_factor;


------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    Manjit Dokal - 18-JUL-2003
  -- Function Name: investor_rv_factor
  -- Description:   Calculate Investor Residual Value Factor
  -- Dependencies:  OKL building blocks AMTX and AMUV,
  -- Parameters:    IN:  p_contract_id, p_contract_line_id (optional)
  --                OUT: amount
  -- History        rmunjulu EDAT Changed to get all residual streams amount
  --              : PAGARG 19-Nov-2004 Bug# 4012614
  --              : Fetching the l_unbill_stream_csr value into correct variable
  --              : UDS impact and modified to use correct stream type purpose
  -- Version:       1.0
  -- End of Commnets
------------------------------------------------------------------------------

FUNCTION investor_rv_factor (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS

    --Bug# 4012614 PAGARG modified the cursor for User Defined Streams Impact
-- Get Residual Streams
-- Get Residual Streams
CURSOR l_unbill_stream_csr (
                                             cp_contract_id NUMBER,
                                             cp_contract_line_id NUMBER,
                                             cp_sty_id NUMBER) IS
SELECT NVL(SUM (NVL (ste.amount, 0)), 0) amount_due
FROM okl_streams stm,
           okl_strm_type_b sty,
           okl_strm_elements ste,
           okl_pool_contents pocb
WHERE stm.khr_id = cp_contract_id
AND stm.kle_id = NVL(cp_contract_line_id, stm.kle_id)
AND stm.active_yn = 'Y'
AND stm.say_code = 'CURR'
AND	ste.stm_id	= stm.id
AND ste.date_billed IS NULL
AND	NVL (ste.amount, 0)	<> 0
AND sty.id              = stm.sty_id
AND sty.id              = cp_sty_id
AND sty.billable_yn     = 'N'
AND pocb.status_Code <> 'PENDING'
AND pocb.khr_id = stm.khr_id
AND pocb.kle_id = stm.kle_id
AND pocb.sty_id = stm.sty_id;

-- Get Residual Streams
CURSOR l_unbill_stream_pending_csr (
                                             cp_contract_id NUMBER,
                                             cp_contract_line_id NUMBER,
                                             cp_sty_id NUMBER) IS
SELECT NVL(SUM (NVL (ste.amount, 0)), 0) amount_due
FROM okl_streams stm,
           okl_strm_type_b sty,
           okl_strm_elements ste,
           okl_pool_contents pocb
WHERE stm.khr_id = cp_contract_id
AND stm.kle_id = NVL(cp_contract_line_id, stm.kle_id)
AND stm.active_yn = 'Y'
AND stm.say_code = 'CURR'
AND	ste.stm_id	= stm.id
AND ste.date_billed IS NULL
AND	NVL (ste.amount, 0)	<> 0
AND sty.id              = stm.sty_id
AND sty.id              = cp_sty_id
AND sty.billable_yn     = 'N'
AND pocb.status_Code = 'PENDING'
AND pocb.khr_id = stm.khr_id
AND pocb.kle_id = stm.kle_id
AND pocb.sty_id = stm.sty_id;

l_try_rsn OKL_POOL_TRANSACTIONS.TRANSACTION_REASON%TYPE;
l_residual_amount	NUMBER		:= 0;
l_result_amount		NUMBER		:= 0;
l_sty_id            OKL_STRM_TYPE_TL.ID%TYPE := 0;
l_return_status     VARCHAR2(3) := Okl_Api.G_RET_STS_SUCCESS;

BEGIN
	-- ****************
	-- Calculate result
	-- ****************
    --PAGARG 19-Nov-2004 Bug# 4012614
    --UDS impact. Obtain stream type id and pass it to cursor
    OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                            'RESIDUAL_VALUE',
                                            l_return_status,
                                            l_sty_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
      LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'p_transaction_reason' THEN
          l_try_rsn := OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE;
        END IF;
      END LOOP;
     END IF;

    IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
      OPEN l_unbill_stream_pending_csr (p_contract_id, p_contract_line_id, l_sty_id);
       FETCH l_unbill_stream_pending_csr INTO l_residual_amount;
       CLOSE l_unbill_stream_pending_csr;
    ELSE
    --PAGARG 19-Nov-2004 Bug# 4012614
    --Fetch cursor value into correct variable l_residual_amount
       OPEN	l_unbill_stream_csr (p_contract_id, p_contract_line_id, l_sty_id);
       FETCH	l_unbill_stream_csr INTO l_residual_amount;
       CLOSE	l_unbill_stream_csr;
      END IF;

    -- this condition is included to prevent 'ORA-01476: divisor is equal to zero' error
    -- need to seed a new message
    IF l_residual_amount = 0 THEN
        l_result_amount := 0;
    ELSE
        l_result_amount := l_residual_amount/l_residual_amount;
    END IF;

	RETURN l_result_amount;

EXCEPTION

	WHEN OTHERS THEN

		-- Close open cursors

		IF l_unbill_stream_csr%ISOPEN THEN
		   CLOSE l_unbill_stream_csr;
		END IF;
		IF l_unbill_stream_pending_csr%ISOPEN THEN
		   CLOSE l_unbill_stream_pending_csr;
		END IF;

		-- store SQL error message on message stack for caller

		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_CONTRACTS_UNEXPECTED_ERROR',
			p_token1	=> 'SQLCODE',
			p_token1_value	=> SQLCODE,
			p_token2	=> 'SQLERRM',
			p_token2_value	=> SQLERRM);

		RETURN NULL;

END investor_rv_factor;


------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    Sushil Deshpande
  -- Function Name: investor_loan_factor
  -- Description:   Calculate Investor Loan Factor
  -- Dependencies:  OKL building blocks AMTX and AMUV,
  -- Parameters:    IN:  p_contract_id, p_contract_line_id (optional)
  --                OUT: amount
  -- History
  -- Version:       1.0
  -- End of Commnets
------------------------------------------------------------------------------

 FUNCTION investor_loan_factor (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS

  CURSOR l_unbill_stream_csr (cp_contract_id NUMBER,
                              cp_contract_line_id NUMBER,
                              cp_date DATE,
                              cp_sty_id NUMBER) IS
  SELECT NVL(SUM (NVL (ste.amount, 0)),0) amount_due
  FROM okl_streams stm,
       okl_strm_type_b sty,
       okl_strm_elements ste
      ,okl_pool_contents pocb
  WHERE stm.khr_id      = cp_contract_id
  AND	stm.kle_id	= NVL(cp_contract_line_id, stm.kle_id)
  AND	stm.active_yn = 'Y'
  AND	stm.say_code = 'CURR'
  AND	ste.stm_id	= stm.id
  AND NVL (ste.amount, 0)	<> 0
  AND sty.id              = stm.sty_id
  AND sty.id              = cp_sty_id
  AND sty.billable_yn     = 'Y'
  AND ste.stream_element_date > cp_date -- rmunjulu EDAT
  AND pocb.status_Code <> 'PENDING'
  AND pocb.khr_id = stm.khr_id
  AND pocb.kle_id = stm.kle_id
  AND pocb.sty_id = stm.sty_id;

  -- Get Undisbursed Investor Rent Streams
  CURSOR l_undisb_rent_stream_csr (cp_contract_id NUMBER,
                                   cp_contract_line_id NUMBER,
                                   cp_sty_id NUMBER,
                                   cp_date  DATE) IS --gboomina bug 4775555
  SELECT NVL(SUM (NVL (ste.amount, 0)),0) amount_payable
  FROM okl_streams stm,
       okl_strm_type_b     sty,
       okl_strm_elements ste
       ,okl_pool_contents pocb
  WHERE stm.khr_id  = cp_contract_id
  AND stm.kle_id = NVL(cp_contract_line_id, stm.kle_id)
  AND stm.active_yn = 'Y'
  AND stm.say_code= 'CURR'
  AND	ste.stm_id	= stm.id
  AND NVL (ste.amount, 0)	<> 0
  AND sty.id              = stm.sty_id
  AND sty.id              = cp_sty_id
  AND ste.stream_element_date > cp_date -- gboomina bug 4775555 -- check for disbs after termination
  AND pocb.status_Code <> 'PENDING'
  AND pocb.khr_id = stm.khr_id
  AND pocb.kle_id = stm.kle_id
  AND pocb.sty_id = stm.sty_id;

  CURSOR l_unbill_stream_pending_csr (cp_contract_id NUMBER,
                                      cp_contract_line_id NUMBER,
                                      cp_date DATE,
                                      cp_sty_id NUMBER) IS
  SELECT NVL(SUM (NVL (ste.amount, 0)),0) amount_due
  FROM okl_streams stm,
       okl_strm_type_b sty,
       okl_strm_elements ste,
       okl_pool_contents pocb
  WHERE stm.khr_id = cp_contract_id
  AND stm.kle_id = NVL(cp_contract_line_id, stm.kle_id)
  AND stm.active_yn = 'Y'
  AND stm.say_code = 'CURR'
  AND ste.stm_id = stm.id
  AND NVL (ste.amount, 0) <> 0
  AND sty.id  = stm.sty_id
  AND sty.id              = cp_sty_id
  AND sty.billable_yn     = 'Y'
  AND ste.stream_element_date > cp_date
  AND pocb.status_Code = 'PENDING'
  AND pocb.khr_id = stm.khr_id
  AND pocb.kle_id = stm.kle_id
  AND pocb.sty_id = stm.sty_id;

  -- Get Undisbursed Investor Rent Streams
  CURSOR l_undisb_rent_strm_pndg_csr (cp_contract_id NUMBER,
                                      cp_contract_line_id NUMBER,
                                      cp_sty_id NUMBER,
                                      cp_date DATE) IS
  SELECT	NVL(SUM (NVL (ste.amount, 0)),0)  amount_payable
  FROM okl_streams stm,
       okl_strm_type_b sty,
       okl_strm_elements ste,
       okl_pool_contents pocb
  WHERE stm.khr_id = cp_contract_id
  AND stm.kle_id = NVL(cp_contract_line_id, stm.kle_id)
  AND	stm.active_yn = 'Y'
  AND stm.say_code = 'CURR'
  AND	ste.stm_id = stm.id
  AND NVL (ste.amount, 0)	<> 0
  AND sty.id = stm.sty_id
  AND sty.id              = cp_sty_id
  AND ste.stream_element_date > cp_date
  AND pocb.status_Code = 'PENDING'
  AND pocb.khr_id = stm.khr_id
  AND pocb.kle_id = stm.kle_id
  AND pocb.sty_id = stm.sty_id;


  l_unbill_principal_amount	NUMBER	:= 0;
  l_unbill_interest_amount	NUMBER	:= 0;
  l_unbill_ppd_amount	        NUMBER	:= 0;
  l_unbill_loan_amount	    NUMBER	:= 0;
  l_undisb_principal_amount	NUMBER	:= 0;
  l_undisb_interest_amount	NUMBER	:= 0;
  l_undisb_ppd_amount	        NUMBER	:= 0;
  l_undisb_loan_amount	    NUMBER	:= 0;
  l_result_amount           NUMBER  := 0;
  l_try_rsn OKL_POOL_TRANSACTIONS.TRANSACTION_REASON%TYPE;

  -- rmunjulu EDAT
  CURSOR get_quote_date_csr (p_quote_id IN NUMBER) IS
   SELECT trunc(qte.date_effective_from) date_effective_from
   FROM   okl_trx_quotes_b  qte
   WHERE  qte.id = p_quote_id;

  -- rmunjulu EDAT
  l_quote_id NUMBER;
  l_quote_date DATE;
  l_sysdate DATE;
  l_sty_id            OKL_STRM_TYPE_TL.ID%TYPE := 0;
  l_return_status     VARCHAR2(3) := Okl_Api.G_RET_STS_SUCCESS;
  --06-Dec-2004 PAGARG Bug# 3948473 variable to store investor agreement id
  l_inv_agr_id    NUMBER;
  BEGIN
	-- ****************
	-- Calculate result
	-- ****************
	-- rmunjulu EDAT
    IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
      FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
      LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).name = 'quote_id' THEN
           l_quote_id := TO_NUMBER(OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).value);
        --06-Dec-2004 PAGARG Bug# 3948473 obtain investor agreement id
        ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).name = 'inv_agr_id' THEN
           l_inv_agr_id := TO_NUMBER(OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).value);
        ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'p_transaction_reason' THEN
          l_try_rsn := OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE;
        END IF;
      END LOOP;
    END IF;

    -- rmunjulu EDAT
    select sysdate into l_sysdate from dual;

    -- rmunjulu EDAT
	IF  l_quote_id IS NOT NULL
	AND l_quote_id <> OKL_API.G_MISS_NUM THEN

	   FOR get_quote_date_rec IN get_quote_date_csr (l_quote_id) LOOP
	      l_quote_date := get_quote_date_rec.date_effective_from;
	   END LOOP;
    END IF;

	-- rmunjulu EDAT
    IF l_quote_date IS NULL
    OR l_quote_date = OKL_API.G_MISS_DATE THEN
       l_quote_date := l_sysdate;
    END IF;

    --PAGARG 19-Nov-2004 Bug# 4012614
    --UDS impact. Obtain stream type id and pass it to cursor
    OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                            'PRINCIPAL_PAYMENT',
                                            l_return_status,
                                            l_sty_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
       OPEN l_unbill_stream_pending_csr (p_contract_id, p_contract_line_id,l_quote_date, l_sty_id);
       FETCH l_unbill_stream_pending_csr INTO l_unbill_principal_amount;
       CLOSE l_unbill_stream_pending_csr;
    ELSE
       OPEN l_unbill_stream_csr (p_contract_id, p_contract_line_id,l_quote_date, l_sty_id);
       FETCH l_unbill_stream_csr INTO l_unbill_principal_amount;
       CLOSE l_unbill_stream_csr;
    END IF;

    --PAGARG 19-Nov-2004 Bug# 4012614
    --UDS impact. Obtain stream type id and pass it to cursor
    OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                            'INTEREST_PAYMENT',
                                            l_return_status,
                                            l_sty_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
       OPEN l_unbill_stream_pending_csr (p_contract_id, p_contract_line_id,l_quote_date, l_sty_id);
       FETCH l_unbill_stream_pending_csr INTO l_unbill_interest_amount;
       CLOSE l_unbill_stream_pending_csr;
    ELSE
       OPEN l_unbill_stream_csr (p_contract_id, p_contract_line_id,l_quote_date, l_sty_id);
       FETCH l_unbill_stream_csr INTO l_unbill_interest_amount;
       CLOSE l_unbill_stream_csr;
    END IF;

    --PAGARG 19-Nov-2004 Bug# 4012614
    --UDS impact. Obtain stream type id and pass it to cursor
    OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                            'UNSCHEDULED_PRINCIPAL_PAYMENT',
                                            l_return_status,
                                            l_sty_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
       OPEN l_unbill_stream_pending_csr (p_contract_id, p_contract_line_id,l_quote_date, l_sty_id);
       FETCH l_unbill_stream_pending_csr INTO l_unbill_ppd_amount;
       CLOSE l_unbill_stream_pending_csr;
    ELSE
       OPEN l_unbill_stream_csr (p_contract_id, p_contract_line_id,l_quote_date, l_sty_id);
       FETCH l_unbill_stream_csr INTO l_unbill_ppd_amount;
       CLOSE l_unbill_stream_csr;
    END IF;

    --Calculate Total Unbilled Interest Amount
    l_unbill_loan_amount := l_unbill_principal_amount+l_unbill_interest_amount+l_unbill_ppd_amount;

   --06-Dec-2004 PAGARG Bug# 3948473 Pass investor agreement id to obtain stream id
    OKL_STREAMS_UTIL.get_primary_stream_type(l_inv_agr_id,
                                            'INVESTOR_PRINCIPAL_DISB_BASIS',
                                            l_return_status,
                                            l_sty_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
      OPEN	l_undisb_rent_strm_pndg_csr (p_contract_id, p_contract_line_id, l_sty_id,l_quote_date);
      FETCH l_undisb_rent_strm_pndg_csr INTO l_undisb_principal_amount;
      CLOSE l_undisb_rent_strm_pndg_csr;
    ELSE
      OPEN	l_undisb_rent_stream_csr (p_contract_id, p_contract_line_id, l_sty_id,l_quote_date); -- gboomina bug 4775555 pass term date
      FETCH l_undisb_rent_stream_csr INTO l_undisb_principal_amount;
      CLOSE l_undisb_rent_stream_csr;
    END IF;

    OKL_STREAMS_UTIL.get_primary_stream_type(l_inv_agr_id,
                                            'INVESTOR_INTEREST_DISB_BASIS',
                                            l_return_status,
                                            l_sty_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
      OPEN	l_undisb_rent_strm_pndg_csr (p_contract_id, p_contract_line_id, l_sty_id,l_quote_date);
      FETCH l_undisb_rent_strm_pndg_csr INTO l_undisb_interest_amount;
      CLOSE l_undisb_rent_strm_pndg_csr;
    ELSE
      OPEN	l_undisb_rent_stream_csr (p_contract_id, p_contract_line_id, l_sty_id,l_quote_date); -- gboomina bug 4775555 pass term date
      FETCH l_undisb_rent_stream_csr INTO l_undisb_interest_amount;
      CLOSE l_undisb_rent_stream_csr;
    END IF;

    OKL_STREAMS_UTIL.get_primary_stream_type(l_inv_agr_id,
                                            'INVESTOR_PPD_DISB_BASIS',
                                            l_return_status,
                                            l_sty_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_try_rsn IS NOT NULL AND l_try_rsn = 'ADJUSTMENTS' THEN
      OPEN	l_undisb_rent_strm_pndg_csr (p_contract_id, p_contract_line_id, l_sty_id,l_quote_date);
      FETCH l_undisb_rent_strm_pndg_csr INTO l_undisb_ppd_amount;
      CLOSE l_undisb_rent_strm_pndg_csr;
    ELSE
      OPEN	l_undisb_rent_stream_csr (p_contract_id, p_contract_line_id, l_sty_id,l_quote_date); -- gboomina bug 4775555 pass term date
      FETCH l_undisb_rent_stream_csr INTO l_undisb_ppd_amount;
      CLOSE l_undisb_rent_stream_csr;
    END IF;

    l_undisb_loan_amount := l_undisb_principal_amount + l_undisb_interest_amount+l_undisb_ppd_amount;

    -- this condition is included to prevent 'ORA-01476: divisor is equal to zero' error
    -- need to seed a new message
    IF l_unbill_loan_amount = 0 THEN
       l_result_amount := 0;
    ELSE
        l_result_amount := l_undisb_loan_amount/l_unbill_loan_amount;
    END IF;

 RETURN l_result_amount;

EXCEPTION

	WHEN OTHERS THEN
		-- Close open cursors
		IF l_unbill_stream_csr%ISOPEN THEN
			CLOSE l_unbill_stream_csr;
		END IF;
		IF l_undisb_rent_stream_csr%ISOPEN THEN
			CLOSE l_undisb_rent_stream_csr;
		END IF;
		IF l_unbill_stream_pending_csr%ISOPEN THEN
			CLOSE l_unbill_stream_pending_csr;
		END IF;
		IF l_undisb_rent_strm_pndg_csr%ISOPEN THEN
			CLOSE l_undisb_rent_strm_pndg_csr;
		END IF;
		-- store SQL error message on message stack for caller

		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_CONTRACTS_UNEXPECTED_ERROR',
			p_token1	=> 'SQLCODE',
			p_token1_value	=> SQLCODE,
			p_token2	=> 'SQLERRM',
			p_token2_value	=> SQLERRM);

		RETURN NULL;

END investor_loan_factor;


-----------------------------------------------------
--End Bug# 3143522 mdokal : 11.5.10 AM Securitization
-----------------------------------------------------


------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    Reeshma Kuttiyat - 15-SEP-2003
  -- Function Name: Net_Gain_Loss
  -- Description:   Returns the Net Gain Loss for a Termination Quote
  -- Dependencies:
  -- Parameters:    IN:  p_contract_id, p_contract_line_id ,p_additional_paams(quote_id)
  --                OUT: amount
  --                rmunjulu 3842101 changed for proper calculation
  --                rmunjulu 3900814
  -- Version:       1.0
  -- End of Commnets
------------------------------------------------------------------------------

FUNCTION NET_GAIN_LOSS_QUOTE(p_khr_id IN NUMBER, p_kle_id IN NUMBER) RETURN NUMBER IS

--Cusor to obtain the asset line id
  CURSOR c_quote_asset_line(p_quote_id IN NUMBER) IS
  SELECT kle_id
  FROM OKL_TXL_QUOTE_LINES_B
  WHERE QTE_ID = p_quote_id
  AND QLT_CODE = 'AMCFIA';

--Cusor to obtain the quote net investment
  CURSOR c_quote_net_invst_csr(p_quote_id IN NUMBER) IS
  SELECT asset_value net_investment
  FROM OKL_TRX_QUOTES_V qte
  WHERE qte.id = p_quote_id;

--Cursor to obtain the total quote amount , excluding the billed quote lines
  CURSOR c_total_qt_amt(p_quote_id IN NUMBER) IS
  SELECT SUM(amount)
  FROM OKL_TXL_QUOTE_LINES_B
  WHERE qte_id = p_quote_id
  AND qlt_code NOT IN ('AMCFIA','AMCTAX', 'AMYOUB', 'AMCSDD'); -- rmunjulu 3842101 Added security deposit

 l_quote_id            NUMBER;
 l_net_gain_loss       NUMBER;
 l_total_qte_amt       NUMBER;
 l_total_invest        NUMBER := 0;
 l_line_asset_invest   NUMBER := 0 ;
 l_return_status       VARCHAR2(1);
 l_unbilled_rent       NUMBER;
 l_residual_value      NUMBER;
 l_unearned_income     NUMBER;

BEGIN

  IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
     FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
     LOOP
       -- Start : PRASJAIN : Bug 6472724
       -- IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).name = 'QUOTE_ID' THEN
       IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).name = 'quote_id' THEN
       -- End : PRASJAIN : Bug 6472724
          l_quote_id := TO_NUMBER(OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).value);
       END IF;
     END LOOP;
  END IF;

/* rmunjulu 3842101 get net investment from quote
  -- get the line asset investment by calling the formula engine
  FOR l_line IN c_quote_asset_line(l_quote_id)
  LOOP

    l_unbilled_rent    := line_unbilled_rent(p_khr_id,l_line.kle_id);
    l_residual_value   := line_residual_value(p_khr_id,l_line.kle_id);
    l_unearned_income  := line_unearned_income(p_khr_id,l_line.kle_id);

    l_line_asset_invest := l_unbilled_rent + l_residual_value -l_unearned_income;

	l_total_invest := l_total_invest + l_line_asset_invest;

  END LOOP;
*/
  --get the total quote amount excluding billed quote lines
  OPEN c_total_qt_amt(l_quote_id);
  FETCH c_total_qt_amt INTO l_total_qte_amt;
    IF c_total_qt_amt%NOTFOUND THEN
       OKC_API.set_message( p_app_name      => 'OKC',
                            p_msg_name      => G_INVALID_VALUE,
                            p_token1        => G_COL_NAME_TOKEN,
                            p_token1_value  => 'KLE_ID');
       l_total_qte_amt := 0;
    END IF;
  CLOSE c_total_qt_amt;

  -- rmunjulu 3842101 added this code to get net investment from quote
  OPEN c_quote_net_invst_csr(l_quote_id);
  FETCH c_quote_net_invst_csr INTO l_total_invest;
  CLOSE c_quote_net_invst_csr;

  -- Net Gain/Loss = Total Quote Amount - Net Investment for quoted assets
  -- rmunjulu 3842101 added nvls or else values are being set with null and does not get calculated
  l_net_gain_loss := NVL(l_total_qte_amt,0) - NVL(l_total_invest,0);

  RETURN l_net_gain_loss;
EXCEPTION
    WHEN OTHERS THEN
   -- Close open cursors

   IF c_total_qt_amt%ISOPEN THEN
     CLOSE c_total_qt_amt;
   END IF;

  -- store SQL error message on message stack for caller

   Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                       p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                       p_token1        => 'OKL_SQLCODE',
                       p_token1_value  => SQLCODE,
                       p_token2        => 'OKL_SQLERRM',
                       p_token2_value  => SQLERRM);
   RETURN NULL;
END NET_GAIN_LOSS_QUOTE;


--end rkuttiya

------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    Manjit Dokal - 22-Oct-2003
  -- Function Name: contract_fee_amount
  -- Description:   Calculate Financed Fee during termination
  -- Dependencies:  OKL building blocks AMTX and AMUV,
  -- Parameters:    IN:  p_contract_id, p_contract_line_id (optional)
  --                     p_operand (required additional parameter)
  --                OUT: amount
  -- History       : 29-Aug-04 PAGARG Bug #3921591: Consider link fee assets
  --                 while calculating amount. Include link fee assets also
  --                 for both full and partial termination
  --                 p_contract_line_id is used to obtain asset id
  --               : rmunjulu EDAT Made changes so that only unbilled fees from
  --                 quote eff date onwards is calculated
  -- Version:       1.0
  -- End of Commnets
------------------------------------------------------------------------------
FUNCTION contract_fee_amount (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS

	CURSOR l_unbilled_fee_streams_csr (
		cp_chr_id	NUMBER,
		cp_fee_type	VARCHAR2,
		cp_date DATE ) IS -- rmunjulu EDAT
		SELECT	SUM(ste.amount)     amount
	   	FROM	okl_streams			stm,
			okl_strm_type_b			sty,
			okc_k_lines_b			kle,
			okc_statuses_b			kls,
			okc_line_styles_b		lse,
            okl_strm_elements       ste,
            okl_k_lines             cle
		WHERE	stm.khr_id			= cp_chr_id
		AND	stm.active_yn			= 'Y'
		AND	stm.say_code			= 'CURR'
        AND	ste.stm_id			    = stm.id
		AND	sty.id			    	= stm.sty_id
		AND	sty.billable_yn			= 'Y'
		AND	kle.id			    	= stm.kle_id
		AND	kls.code		    	= kle.sts_code
		AND	kls.ste_code			= 'ACTIVE'
		AND	lse.id			    	= kle.lse_id
        AND kle.id                  = cle.id
		AND	lse.lty_code	        = 'FEE'
		AND ste.date_billed         IS NULL -- rmunjulu EDAT
		AND trunc(ste.stream_element_date) > trunc(cp_date) -- rmunjulu EDAT
        AND cle.fee_type            = cp_fee_type;

    --Bug #3921591: pagarg +++ Rollover +++++++ Start ++++++++++
    -- Following cursor finds the total payments with all the assets associated
    -- to the given fee type for the given contract. This cursor will be used in
    -- case of full termination along with the above cursor.
    CURSOR l_unbilled_feeassets_strms_csr(
	        cp_chr_id   NUMBER,
	        cp_fee_type VARCHAR2,
		    cp_date DATE ) IS -- rmunjulu EDAT
        SELECT SUM(ste.amount)     amount
        FROM okl_streams         stm
            ,okl_strm_type_b    sty
            ,okc_k_lines_b      kle
            ,okc_statuses_b     kls
            ,okc_line_styles_b  lse
            ,okl_strm_elements  ste
            ,okl_k_lines        cle
            ,okc_k_lines_b      cles
        WHERE  stm.khr_id          = cp_chr_id
          AND  stm.active_yn       = 'Y'
          AND  stm.say_code        = 'CURR'
          AND  ste.stm_id          = stm.id
          AND  sty.id              = stm.sty_id
          AND  sty.billable_yn     = 'Y'
          AND  cles.id             = stm.kle_id
          AND  cles.cle_id         = kle.id
          AND  kls.code            = kle.sts_code
          AND  kls.ste_code        = 'ACTIVE'
          AND  lse.id              = cles.lse_id
          AND  kle.id              = cle.id
          AND  lse.lty_code        = 'LINK_FEE_ASSET'
   		  AND ste.date_billed         IS NULL -- rmunjulu EDAT
		  AND trunc(ste.stream_element_date) > trunc(cp_date) -- rmunjulu EDAT
          AND  cle.fee_type        = cp_fee_type;

    -- Following cursor obtains the total payments of a given asset associated
    -- to the given fee of the given contract. This will used in case of partial
    -- termination when we are processing formula for each link fee asset.
    CURSOR l_unbilled_feeasset_strms_csr(
            cp_chr_id   NUMBER,
            cp_fee_type VARCHAR2,
            cp_asset_id   NUMBER,
		    cp_date DATE ) IS -- rmunjulu EDAT
       SELECT SUM(ste.amount)     amount
       FROM   okl_streams         stm
             ,okl_strm_type_b    sty
             ,okc_k_lines_b      kle
             ,okc_statuses_b     kls
             ,okc_line_styles_b  lse
             ,okl_strm_elements  ste
             ,okl_k_lines        cle
             ,okc_k_lines_b      cles
             ,okc_k_items        cim
       WHERE  stm.khr_id          = cp_chr_id
         AND  stm.active_yn       = 'Y'
         AND  stm.say_code        = 'CURR'
         AND  ste.stm_id          = stm.id
         AND  sty.id              = stm.sty_id
         AND  sty.billable_yn     = 'Y'
         AND  cles.id             = stm.kle_id
         AND  lse.id              = cles.lse_id
         AND  lse.lty_code        = 'LINK_FEE_ASSET'
         AND  cles.cle_id         = kle.id
         AND  kls.code            = kle.sts_code
         AND  kls.ste_code        = 'ACTIVE'
         AND  kle.id              = cle.id
         AND  cle.fee_type        = cp_fee_type
         AND  cim.object1_id1     = cp_asset_id
		 AND ste.date_billed         IS NULL -- rmunjulu EDAT
		 AND trunc(ste.stream_element_date) > trunc(cp_date) -- rmunjulu EDAT
         AND  cim.cle_id          = cles.id;
    --Bug #3921591: pagarg +++ Rollover +++++++ End ++++++++++
        --mdokal assign fee type names to variables
        l_amafee          CONSTANT VARCHAR2(30)   := 'ABSORBED';
        l_amefee          CONSTANT VARCHAR2(30)   := 'EXPENSE';
        l_amffee          CONSTANT VARCHAR2(30)   := 'FINANCED';
        l_amgfee          CONSTANT VARCHAR2(30)   := 'GENERAL';
        l_amifee          CONSTANT VARCHAR2(30)   := 'INCOME';
        l_ammfee          CONSTANT VARCHAR2(30)   := 'MISCELLANEOUS';
        l_ampfee          CONSTANT VARCHAR2(30)   := 'PASSTHROUGH';
        l_amsfee          CONSTANT VARCHAR2(30)   := 'SECDEPOSIT';
        --Bug #3921591: pagarg +++ Rollover +++
        -- Constant for Rollover Fee
        l_amrfee          CONSTANT VARCHAR2(30)   := 'ROLLOVER';

        l_operand               VARCHAR2(30);
        l_fee_type              VARCHAR2(50);
        l_unbilled_fee_amount   NUMBER  := 0;
        --Bug #3921591: pagarg +++ Rollover +++
        -- Variable to store fee asset amount
        l_unbilled_fee_assets_amt  NUMBER  := 0;

        -- rmunjulu EDAT
        CURSOR get_quote_date_csr (p_quote_id IN NUMBER) IS
        SELECT trunc(qte.date_effective_from) date_effective_from
        FROM   okl_trx_quotes_b  qte
        WHERE  qte.id = p_quote_id;

        -- rmunjulu EDAT
        l_quote_id NUMBER;
        l_quote_date DATE;
        l_sysdate DATE;
BEGIN

   --Validate additional parameters availability
    IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'p_operand' THEN
          l_operand := OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE;
        END IF;

        -- rmunjulu EDAT -- get quote id
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'quote_id' THEN
          l_quote_id := OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE;
        END IF;
      END LOOP;
	ELSE
      Okl_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_AGN_FE_ADD_PARAMS');
      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    -- Determine the fee type passed

    IF l_operand = 'AMAFEE' THEN
        l_fee_type := l_amafee;
    ELSIF l_operand = 'AMEFEE' THEN
        l_fee_type := l_amefee;
    ELSIF l_operand = 'AMFFEE' THEN
        l_fee_type := l_amffee;
    ELSIF l_operand = 'AMGFEE' THEN
        l_fee_type := l_amgfee;
    ELSIF l_operand = 'AMIFEE' THEN
        l_fee_type := l_amifee;
    ELSIF l_operand = 'AMMFEE' THEN
        l_fee_type := l_ammfee;
    ELSIF l_operand = 'AMPFEE' THEN
        l_fee_type := l_ampfee;
    ELSIF l_operand = 'AMSFEE' THEN
        l_fee_type := l_amsfee;
    --Bug #3921591: pagarg +++ Rollover +++
    -- Set the fee type based on operand value for Rollover
    ELSIF l_operand = 'AMRFEE' THEN
        l_fee_type := l_amrfee;
    END IF;

	-- rmunjulu EDAT
	select sysdate into l_sysdate from dual;

	-- rmunjulu EDAT
	IF  l_quote_id IS NOT NULL
	AND l_quote_id <> OKL_API.G_MISS_NUM THEN

	   FOR get_quote_date_rec IN get_quote_date_csr (l_quote_id) LOOP
	      l_quote_date := get_quote_date_rec.date_effective_from;
	   END LOOP;
    END IF;

	-- rmunjulu EDAT
    IF l_quote_date IS NULL
    OR l_quote_date = OKL_API.G_MISS_DATE THEN
       l_quote_date := l_sysdate;
    END IF;
	-- ****************
	-- Calculate result
	-- ****************
	OPEN	l_unbilled_fee_streams_csr (p_contract_id, l_fee_type, l_quote_date); -- rmunjulu EDAT
	FETCH	l_unbilled_fee_streams_csr INTO l_unbilled_fee_amount;
	CLOSE	l_unbilled_fee_streams_csr;
    --Bug #3921591: pagarg +++ Rollover +++++++ Start ++++++++++
    -- Find the sum of all the asset level streams for a given fee if asset id is null
    -- else if asset id is not null then sum all the asset level streams for that asset
    -- for the given fee.
    -- p_contract_line_id stores the asset id
    IF p_contract_line_id is NULL or p_contract_line_id = OKL_API.G_MISS_NUM THEN
       -- Find the total payments of all the assets associated to the given
       -- fee type of given contract.
       OPEN   l_unbilled_feeassets_strms_csr (p_contract_id, l_fee_type, l_quote_date); -- rmunjulu EDAT
       FETCH  l_unbilled_feeassets_strms_csr INTO l_unbilled_fee_assets_amt;
       CLOSE  l_unbilled_feeassets_strms_csr;
       l_unbilled_fee_amount := NVL(l_unbilled_fee_amount, 0) + NVL(l_unbilled_fee_assets_amt, 0);
    ELSIF p_contract_line_id is NOT NULL THEN
       -- Find the total payments of given asset associated to the given
       -- fee type of given contract.
       OPEN	  l_unbilled_feeasset_strms_csr (p_contract_id, l_fee_type, p_contract_line_id, l_quote_date); -- rmunjulu EDAT
       FETCH  l_unbilled_feeasset_strms_csr INTO l_unbilled_fee_assets_amt;
       CLOSE  l_unbilled_feeasset_strms_csr;
       l_unbilled_fee_amount := NVL(l_unbilled_fee_assets_amt, 0);

    END IF;
    --Bug #3921591: pagarg +++ Rollover +++++++ End ++++++++++

	RETURN l_unbilled_fee_amount;

EXCEPTION
	WHEN OTHERS THEN
		-- Close open cursors
		IF l_unbilled_fee_streams_csr%ISOPEN THEN
			CLOSE l_unbilled_fee_streams_csr;
		END IF;
		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_CONTRACTS_UNEXPECTED_ERROR',
			p_token1	=> 'SQLCODE',
			p_token1_value	=> SQLCODE,
			p_token2	=> 'SQLERRM',
			p_token2_value	=> SQLERRM);
		RETURN NULL;
END contract_fee_amount;
-----------------------------------------------------
--End Bug# 3061765 mdokal : 11.5.10 AM Financed Fees
-----------------------------------------------------

-- Bug# 3316994 start : 12-Jan-2004 cklee
------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    13-Jan-2004 cklee
  -- Function Name: subsidy_amount
  -- Description:   demo subsidy amount formula function
  -- Dependencies:
  -- Parameters:    IN:  p_contract_id, p_contract_line_id (FREE_FORM1)
  --                OUT: amount
  -- Version:       1.0
  -- End of Commnets
------------------------------------------------------------------------------
 FUNCTION SUBSIDY_AMOUNT(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS

  l_amount          NUMBER;

/* case not available
CURSOR c_subsidy_amount(p_cle_id okc_k_lines_b.id%TYPE) IS
select (case
        when ROUND(MONTHS_BETWEEN(chr.end_date, cle.start_date)) <= 12 then NVL(kle.oec,0) * .2
        else NVL(kle.oec,0) * .1
        end) subsidy_amount
from okc_k_lines_b     cle,
     okl_k_lines       kle,
     okc_k_headers_b   chr
where chr.id         = cle.dnz_chr_id
and   kle.id         = cle.id
and   cle.id         = p_cle_id -- FREE_FORM1 (FIN)
;
*/
CURSOR c_subsidy_amount(p_cle_id okc_k_lines_b.id%TYPE) IS
SELECT ROUND(MONTHS_BETWEEN(CHR.end_date, cle.start_date)) months,
       NVL(kle.oec,0) oec
FROM okc_k_lines_b     cle,
     okl_k_lines       kle,
     okc_k_headers_b   CHR
WHERE CHR.id         = cle.dnz_chr_id
AND   kle.id         = cle.id
AND   cle.id         = p_cle_id -- FREE_FORM1 (FIN)
;

  r_subsidy_amount c_subsidy_amount%ROWTYPE;


BEGIN

  OPEN c_subsidy_amount (p_contract_line_id);
  FETCH c_subsidy_amount INTO r_subsidy_amount;
  CLOSE c_subsidy_amount;

  -- Bug 3487167
  IF r_subsidy_amount.months <= 12 THEN
    l_amount := r_subsidy_amount.oec * .02;
  ELSE
    l_amount := r_subsidy_amount.oec * .01;
  END IF;

  RETURN l_amount;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END SUBSIDY_AMOUNT;

------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    13-Jan-2004 cklee
  -- Function Name: refund_subsidy
  -- Description:   refund subsidy amount if asset terminated
  -- Dependencies:
  -- Parameters:    IN:  p_contract_id, p_contract_line_id (FREE_FORM1)
  --                OUT: amount
  -- Version:       1.0
  -- End of Commnets
------------------------------------------------------------------------------
 FUNCTION REFUND_SUBSIDY(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS

  l_amount          NUMBER := 0;
  l_tot_amount      NUMBER := 0;
  l_return_status   VARCHAR2(1);

CURSOR c_subsidy_lines(p_cle_id okc_k_lines_b.id%TYPE) IS
  SELECT sub.accounting_method_code,
         top_cle.date_terminated,
         --TO_NUMBER(sgn.value) sty_id
         sub_kle.sty_id sty_id, /* Bug 6353756 */
         top_cle.dnz_chr_id chr_id
FROM --okl_sgn_translations sgn,
     okl_subsidies_b      sub,
     okl_k_lines          sub_kle,
     okc_k_lines_b        sub_cle,
     okc_k_lines_b        top_cle
WHERE --sgn.jtot_object1_code = 'OKL_STRMTYP'
--AND sgn.object1_id1         = TO_CHAR(sub_kle.sty_id) AND
sub.id                  = sub_kle.subsidy_id
AND sub_cle.cle_id          = top_cle.id
AND sub_kle.id              = sub_cle.id
AND sub_cle.cle_id          = p_cle_id -- FREE_FORM1
;

CURSOR c_refund_subsidy(p_cle_id okc_k_lines_b.id%TYPE,
                        p_date_terminated okc_k_lines_b.date_terminated%TYPE,
                        p_sty_id okl_strm_type_b.id%TYPE) IS
  SELECT NVL(SUM(selb.amount),0)
FROM
  okl_streams       stmb,
  okl_strm_elements selb
WHERE stmb.id          = selb.stm_id
AND stmb.say_code      = 'CURR'
AND stmb.active_yn     = 'Y'
AND selb.date_billed IS NULL
AND TRUNC(selb.stream_element_date) > TRUNC(p_date_terminated)
AND stmb.kle_id        = p_cle_id -- FREE_FORM1
AND stmb.sty_id        = p_sty_id
;

    r_subsidy_line c_subsidy_lines%ROWTYPE;
    l_dependent_sty_id OKL_STRM_TYPE_B.ID%TYPE; -- Bug 6353756

BEGIN

  FOR r_subsidy_line IN c_subsidy_lines(p_contract_line_id) LOOP

--    CASE r_subsidy_line.accounting_method_code

--      WHEN 'NET' THEN
      IF r_subsidy_line.accounting_method_code = 'NET' THEN

        l_tot_amount := l_tot_amount + 0; -- through funding

--      WHEN 'AMORTIZE' THEN
      ELSIF r_subsidy_line.accounting_method_code = 'AMORTIZE' THEN

        IF (r_subsidy_line.date_terminated IS NOT NULL) THEN

          /* Bug 6353756 Get dependent stream type from r_subsidy_line.sty_id */
          okl_streams_util.get_dependent_stream_type(
              p_khr_id                => r_subsidy_line.chr_id,
              p_primary_sty_id        => r_subsidy_line.sty_id,
              p_dependent_sty_purpose => 'SUBSIDY_INCOME',
              x_return_status         => l_return_status,
              x_dependent_sty_id      => l_dependent_sty_id);
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          OPEN c_refund_subsidy(p_contract_line_id,
                                r_subsidy_line.date_terminated,
                                --r_subsidy_line.sty_id);
                                l_dependent_sty_id); -- Bug 6353756
          FETCH c_refund_subsidy INTO l_amount;
          CLOSE c_refund_subsidy;
          l_tot_amount := l_tot_amount + l_amount;

        ELSE
          l_tot_amount := NULL; -- error
          OKL_API.Set_Message(p_app_name     => OKL_API.G_APP_NAME,
                              p_msg_name     => 'OKL_DATE_TERMINATED_REQUIRED');

          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

      ELSE -- error
        l_tot_amount := NULL;
        OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                            p_msg_name      => 'OKL_INVALID_ACCT_METHOD_CODE',
                            p_token2        => 'COL_NAME',
                            p_token2_value  => r_subsidy_line.accounting_method_code);

        RAISE OKC_API.G_EXCEPTION_ERROR;
--    END CASE;
      END IF;

  END LOOP;

  RETURN l_tot_amount;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END REFUND_SUBSIDY;

-- Bug# 3316994 end: 12-Jan-2004 cklee

-- Fix Bug 3417313, dedey 01/29/2004
----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:    dedey
    -- Function Name: contract_pretaxinc_book
    -- Description:   Returns sum of all incomes of financial asset lines of a contract
    -- Dependencies:
    -- Parameters: contract id, line id
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION contract_pretaxinc_book(
                                   p_chr_id  IN  NUMBER
                                  ,p_kle_id  IN NUMBER
                                  )
  RETURN NUMBER  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CONTRACT_PRETAXINC_BOOK';
    l_api_version	CONSTANT NUMBER	      := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_income NUMBER := 0;

    CURSOR l_line_income_csr (p_chr_id NUMBER) IS
      SELECT NVL(str.link_hist_stream_id,-1) link_hist_stream_id,
             NVL(SUM(sele.amount),0) amount
      FROM okl_strm_elements sele,
           --okl_streams str, MGAAP 7263041
           okl_streams_rep_v str,
           okl_strm_type_v sty,
           okc_k_headers_b CHR,
           okc_statuses_b sts
      WHERE sele.stm_id      = str.id
      AND   str.sty_id       = sty.id
      --AND   UPPER(sty.name)  = 'PRE-TAX INCOME'
      AND   sty.stream_type_purpose  = 'LEASE_INCOME'
      AND   (NVL(str.purpose_code,'XXXX') = 'XXXX' OR
             NVL(str.purpose_code,'XXXX') = 'REPORT')
      AND   str.say_code     = 'CURR'
      AND   str.active_yn    = 'Y'
      AND   CHR.id           = p_chr_id
      AND   CHR.sts_code     = sts.code
      AND   CHR.id           = str.khr_id
      AND   sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD')
      GROUP BY str.link_hist_stream_id;

    CURSOR l_line_income_adj_csr (p_stm_id NUMBER) IS
    SELECT NVL(SUM(sele.amount),0) amount
    FROM   okl_strm_elements sele
    WHERE  stm_id = p_stm_id
    AND    NVL(accrued_yn,'N') = 'Y';

    l_line_income_amount NUMBER;
    l_income_adj_amount  NUMBER;

  BEGIN

      IF ( p_chr_id IS NULL ) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      l_line_income_amount := 0;
      FOR l_line_income_rec IN l_line_income_csr (p_chr_id)
      LOOP
         l_line_income_amount := NVL(l_line_income_amount,0) + l_line_income_rec.amount;

         IF (l_line_income_rec.link_hist_stream_id <> -1) THEN
            l_income_adj_amount := 0;
            OPEN l_line_income_adj_csr (l_line_income_rec.link_hist_stream_id);
            FETCH l_line_income_adj_csr INTO l_income_adj_amount;
            CLOSE l_line_income_adj_csr;

            l_line_income_amount := l_line_income_amount - NVL(l_income_adj_amount,0);
         END IF;
      END LOOP;

       l_income := l_line_income_amount;

      RETURN l_income;


    EXCEPTION

	WHEN OTHERS THEN
               Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
                RETURN NULL;


  END contract_pretaxinc_book;

----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:    arun.jain
    -- Function Name: CONTRACT_FINANCED_FEE
    -- Description:   Returns the sum of Financed fee lines amount of a contract
    -- Dependencies:
    -- Parameters: contract id, line id
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION CONTRACT_FINANCED_FEE(
  p_dnz_chr_id         IN NUMBER
 ,p_kle_id             IN NUMBER
 ) RETURN NUMBER
IS

l_sum_financed_fee_amt  NUMBER;

CURSOR sum_fin_fee_csr(l_dnz_chr_id okc_k_headers_b.id%TYPE) IS
SELECT
  NVL(SUM(NVL(KLEB.amount,0)),0)
FROM
  OKL_K_LINES KLEB,
  OKC_K_LINES_B CLEB,
  OKC_LINE_STYLES_B LSEB,
  okc_statuses_b sts
WHERE
  KLEB.ID = CLEB.ID AND
  CLEB.LSE_ID = LSEB.ID AND
  LSEB.LTY_CODE = 'FEE' AND
  KLEB.FEE_TYPE IN ('FINANCED') AND
  CLEB.DNZ_CHR_ID = l_dnz_chr_id AND
  CLEB.sts_code = sts.code AND
  sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');

BEGIN

  OPEN sum_fin_fee_csr (p_dnz_chr_id);
  FETCH sum_fin_fee_csr INTO l_sum_financed_fee_amt;
  CLOSE sum_fin_fee_csr;

  RETURN l_sum_financed_fee_amt;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END CONTRACT_FINANCED_FEE;


----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:    arun.jain
    -- Function Name: CONTRACT_ABSORBED_FEE
    -- Description:   Returns the sum of Absorbed fee lines amount of a contract
    -- Dependencies:
    -- Parameters: contract id, line id
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION CONTRACT_ABSORBED_FEE(
  p_dnz_chr_id         IN NUMBER
 ,p_kle_id             IN NUMBER
 ) RETURN NUMBER
IS

l_sum_absorbed_fee_amt  NUMBER;

CURSOR sum_abs_fee_csr(l_dnz_chr_id okc_k_headers_b.id%TYPE) IS
SELECT
  NVL(SUM(NVL(KLEB.amount,0)),0)
FROM
  OKL_K_LINES KLEB,
  OKC_K_LINES_B CLEB,
  OKC_LINE_STYLES_B LSEB,
  okc_statuses_b sts
WHERE
  KLEB.ID = CLEB.ID AND
  CLEB.LSE_ID = LSEB.ID AND
  LSEB.LTY_CODE = 'FEE' AND
  KLEB.FEE_TYPE IN ('ABSORBED') AND
  CLEB.DNZ_CHR_ID = l_dnz_chr_id AND
  CLEB.sts_code = sts.code AND
  sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');

BEGIN

  OPEN sum_abs_fee_csr (p_dnz_chr_id);
  FETCH sum_abs_fee_csr INTO l_sum_absorbed_fee_amt;
  CLOSE sum_abs_fee_csr;

  RETURN l_sum_absorbed_fee_amt;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END CONTRACT_ABSORBED_FEE;

------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : credit_check
-- Description     : Caculate total credit remaining
--
-- Business Rules  :
-- Parameters      :IN: p_contract_id, OUT: amount
-- Version         : 1.0
-- History         :27-Aug-04 ChenKuang.Lee@oracle.com -- Created
--
-- End of comments
------------------------------------------------------------------------------
--START:           14-Feb-06 cklee    Fixed bug#5017158                             |
/*|           14-Feb-06 cklee    Fixed bug#5017158                             |
 FUNCTION credit_check(
 p_contract_id                   IN NUMBER -- credit line contract id
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS

CURSOR c_disb_tot IS
  SELECT TAP.AMOUNT,
         TAP.KHR_ID
FROM   OKL_TRX_AP_INVOICES_B TAP
WHERE  TAP.TRX_STATUS_CODE IN ('APPROVED','PROCESSED') -- push to AP
AND    TAP.FUNDING_TYPE_CODE IS NOT NULL
-- start: cklee - okl.h ER 05/25/2005
AND    NOT EXISTS (SELECT 1
                   FROM   OKC_K_HEADERS_B KHR
                   WHERE  KHR.ID = TAP.KHR_ID
                   AND    ORIG_SYSTEM_SOURCE_CODE = 'OKL_LEASE_APP')
-- end: cklee - okl.h ER 05/25/2005
;

-- STRAT: cklee - bug#4655437 10/06/2005
CURSOR c_principal_payments_tot IS
  SELECT TAR.AMOUNT,
         TAR.KHR_ID
FROM   okl_cnsld_ar_strms_b TAR
WHERE  TAR.receivables_invoice_id <> -99999
AND    exists (SELECT STY.ID
               FROM   okl_strm_type_b STY
               WHERE  STY.STREAM_TYPE_PURPOSE = 'UNSCHEDULED_PRINCIPAL_PAYMENT'
               AND    STY.ID = TAR.STY_ID);

  l_payment_tot    NUMBER := 0;
-- END: cklee - bug#4655437 10/06/2005


  l_amount_limit        NUMBER := 0;
  l_credit_remain       NUMBER := 0;
  l_disbursement_tot    NUMBER := 0;

  l_amount NUMBER := 0;
  x_return_status	     VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  l_api_version       NUMBER	:= 1.0;
  x_msg_count		NUMBER;
  x_msg_data	     VARCHAR2(4000);
  l_init_msg_list     VARCHAR2(10) := OKL_API.G_FALSE;

BEGIN

   FOR r_ast IN c_disb_tot LOOP

     IF (OKL_CREDIT_PUB.get_creditline_by_chrid(r_ast.KHR_ID) = p_contract_id) THEN
       l_disbursement_tot := l_disbursement_tot + NVL(r_ast.AMOUNT,0);
     END IF;

   END LOOP;

-- START: cklee - bug#4655437 10/06/2005
   FOR r_pst IN c_principal_payments_tot LOOP

     IF (OKL_CREDIT_PUB.get_creditline_by_chrid(r_pst.KHR_ID) = p_contract_id) THEN
       l_payment_tot := l_payment_tot + NVL(r_pst.AMOUNT,0);
     END IF;

   END LOOP;
-- END: cklee - bug#4655437 10/06/2005

   l_credit_remain := NVL(creditline_total_limit(p_contract_id),0) - l_disbursement_tot
-- START: cklee - bug#4655437 10/06/2005
    + l_payment_tot;
-- END: cklee - bug#4655437 10/06/2005

  RETURN l_credit_remain;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;
*/
 FUNCTION credit_check(
 p_contract_id                   IN NUMBER -- credit line contract id
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS

-- sjalasut, modified the cursor to have khr_id referred from okl_txl_ap_inv_lns_all_b
-- changes made as part of OKLR12B disbursements project.
-- cklee : 09/21/2007 restored the khr_id back to okl_trx_ap_invs_all_b
-- reason: 1. line.khr_id will be always = header.khr_id
--         2. the modified code will multiply the header amount if mutliple lines found

CURSOR c_disb_tot(p_credit_id number) IS
  SELECT NVL(SUM(TAP.AMOUNT),0)
FROM   OKL_TRX_AP_INVOICES_B TAP,
--       okl_txl_ap_inv_lns_all_b tpl,
       (
  select gov.dnz_chr_id chr_id,
         crd.ID credit_id
  from   OKC_K_HEADERS_B crd,
         okc_Governances gov
  where  crd.id = gov.chr_id_referred
  and    crd.sts_code = 'ACTIVE'
  and    crd.scs_code = 'CREDITLINE_CONTRACT'
union
  select mla_g.dnz_chr_id chr_id,
         crd.ID credit_id
  from   OKC_K_HEADERS_B crd,
         okc_Governances gov,
         OKC_K_HEADERS_B mla,
         okc_Governances mla_g
  where  crd.id         = gov.chr_id_referred
  and    crd.sts_code   = 'ACTIVE'
  and    crd.scs_code   = 'CREDITLINE_CONTRACT'
  and    gov.dnz_chr_id = mla.id
  and    mla.id         = mla_g.chr_id_referred
  and    mla.scs_code   = 'MASTER_LEASE'
       ) ccg
--WHERE  TAP.id = TPL.tap_id
   where ccg.chr_id       = Tap.KHR_ID
AND    ccg.credit_id    = p_credit_id
AND    TAP.TRX_STATUS_CODE IN ('APPROVED','PROCESSED') -- push to AP
AND    TAP.FUNDING_TYPE_CODE IS NOT NULL
AND    NOT EXISTS (SELECT 1
                   FROM   OKC_K_HEADERS_B KHR
                   WHERE  KHR.ID = tap.KHR_ID
                   AND    ORIG_SYSTEM_SOURCE_CODE = 'OKL_LEASE_APP')
;

/* ankushar, modified the cursor to replace reference to okl_cnsld_ar_strms_b
   OKL R12B billing changes
*/
CURSOR c_principal_payments_tot(p_credit_id number) IS
  SELECT NVL(SUM(ARL.AMOUNT),0)
  FROM  okl_bpd_ar_inv_lines_v ARL,
       (
  select gov.dnz_chr_id chr_id,
         crd.ID credit_id
  from   OKC_K_HEADERS_B crd,
         okc_Governances gov
  where  crd.id = gov.chr_id_referred
  and    crd.sts_code = 'ACTIVE'
  and    crd.scs_code = 'CREDITLINE_CONTRACT'
union
  select mla_g.dnz_chr_id chr_id,
         crd.ID credit_id
  from   OKC_K_HEADERS_B crd,
         okc_Governances gov,
         OKC_K_HEADERS_B mla,
         okc_Governances mla_g
  where  crd.id         = gov.chr_id_referred
  and    crd.sts_code   = 'ACTIVE'
  and    crd.scs_code   = 'CREDITLINE_CONTRACT'
  and    gov.dnz_chr_id = mla.id
  and    mla.id         = mla_g.chr_id_referred
  and    mla.scs_code   = 'MASTER_LEASE'
       ) ccg
WHERE  ccg.chr_id = ARL.CONTRACT_ID
AND    ccg.credit_id    = p_credit_id
AND    ARL.receivables_invoice_id <> -99999
AND    ARL.interface_line_context = 'OKL_CONTRACTS'
AND    exists (SELECT STY.ID
               FROM   okl_strm_type_b STY
               WHERE  STY.STREAM_TYPE_PURPOSE = 'UNSCHEDULED_PRINCIPAL_PAYMENT'
               AND    STY.ID = ARL.STY_ID);

  l_payment_tot         NUMBER := 0;
  l_credit_remain       NUMBER := 0;
  l_disbursement_tot    NUMBER := 0;

BEGIN

   open c_disb_tot(p_contract_id);
   fetch c_disb_tot into l_disbursement_tot;
   close c_disb_tot;

   open c_principal_payments_tot(p_contract_id);
   fetch c_principal_payments_tot into l_payment_tot;
   close c_principal_payments_tot;

   l_credit_remain := NVL(creditline_total_limit(p_contract_id),0) - l_disbursement_tot + l_payment_tot;

  RETURN l_credit_remain;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;
--END:|           14-Feb-06 cklee    Fixed bug#5017158                             |

--------------------------------------------------------------------------------

-- STRAT: cklee - bug#4655437 10/06/2005
------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : tot_credit_funding_pmt
-- Description     : Caculate total credit funding payments
--
-- Business Rules  :
-- Parameters      :IN: p_contract_id, OUT: amount
-- Version         : 1.0
-- History         :07-Oct-05 ChenKuang.Lee@oracle.com -- Created
--
-- End of comments
------------------------------------------------------------------------------
 FUNCTION tot_credit_funding_pmt(
 p_contract_id                   IN NUMBER -- credit line contract id
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS
-- sjalasut, modified the cursor to include khr_id from the okl_Txl_ap_inv_lns_all_b
-- changes made as part of OKLR12B disbursements project
/*
CURSOR c_disb_tot IS
SELECT TAP.AMOUNT,
       TPL.KHR_ID
FROM   OKL_TRX_AP_INVOICES_B TAP
      ,OKL_TXL_AP_INV_LNS_ALL_B TPL
WHERE TAP.ID = TPL.TAP_ID
  AND TAP.TRX_STATUS_CODE IN ('APPROVED','PROCESSED') -- push to AP
  AND TAP.FUNDING_TYPE_CODE IS NOT NULL
-- start: cklee - okl.h ER 05/25/2005
AND    NOT EXISTS (SELECT 1
                   FROM   OKC_K_HEADERS_B KHR
                   WHERE  KHR.ID = TPL.KHR_ID
                   AND    ORIG_SYSTEM_SOURCE_CODE = 'OKL_LEASE_APP')
-- end: cklee - okl.h ER 05/25/2005
;
*/
-- cklee : 09/20/2007 change khr_id refer back to okl_trx_ap_invs_all_b instead
-- reason: 1. The modified code will return duplicated header amount
--         2. line.khr_id will be always = header.khr_id

CURSOR c_disb_tot IS
SELECT TAP.AMOUNT,
       TAP.KHR_ID
FROM   OKL_TRX_AP_INVOICES_B TAP
  where TAP.TRX_STATUS_CODE IN ('APPROVED','PROCESSED') -- push to AP
  AND TAP.FUNDING_TYPE_CODE IS NOT NULL
-- start: cklee - okl.h ER 05/25/2005
AND    NOT EXISTS (SELECT 1
                   FROM   OKC_K_HEADERS_B KHR
                   WHERE  KHR.ID = tap.KHR_ID
                   AND    ORIG_SYSTEM_SOURCE_CODE = 'OKL_LEASE_APP')
;
-- end: cklee - okl.h ER 05/25/2005

  l_amount_limit        NUMBER := 0;
  l_credit_remain       NUMBER := 0;
  l_disbursement_tot    NUMBER := 0;

  l_amount NUMBER := 0;
  x_return_status	     VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  l_api_version       NUMBER	:= 1.0;
  x_msg_count		NUMBER;
  x_msg_data	     VARCHAR2(4000);
  l_init_msg_list     VARCHAR2(10) := OKL_API.G_FALSE;

BEGIN

   FOR r_ast IN c_disb_tot LOOP

     IF (OKL_CREDIT_PUB.get_creditline_by_chrid(r_ast.KHR_ID) = p_contract_id) THEN
       l_disbursement_tot := l_disbursement_tot + NVL(r_ast.AMOUNT,0);
     END IF;

   END LOOP;

  RETURN l_disbursement_tot;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;

------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : tot_credit_principal_pmt
-- Description     : Caculate total credit principal payments
--
-- Business Rules  :
-- Parameters      :IN: p_contract_id, OUT: amount
-- Version         : 1.0
-- History         :07-Oct-05 ChenKuang.Lee@oracle.com -- Created
--
-- End of comments
------------------------------------------------------------------------------
 FUNCTION tot_credit_principal_pmt(
 p_contract_id                   IN NUMBER -- credit line contract id
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS

 /* ankushar 09-Feb-2007 OKL R12B Billing enhancement
    Replaced reference of okl_cnsld_ar_strms_b with Billing Util API call
    start changes
 */
    --Initialize standard API parameters
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    -- Intialize contract_invoice_tbl variable
    x_contract_invoice_tbl OKL_BILLING_UTIL_PVT.contract_invoice_tbl;
 /* ankushar end changes */

  l_payment_tot    NUMBER := 0;
  i                NUMBER;


BEGIN

  -- Call to the Billing Util API replacing reference to okl_cnsld_ar_strms_b
   OKL_BILLING_UTIL_PVT.INVOICE_AMOUNT_FOR_STREAM(
                        p_api_version              =>  1.0
                       ,p_init_msg_list            =>  OKL_API.G_FALSE
                       ,x_return_status            =>  x_return_status
                       ,x_msg_count                =>  x_msg_count
                       ,x_msg_data                 =>  x_msg_data
                       ,p_stream_purpose           =>  'UNSCHEDULED_PRINCIPAL_PAYMENT'
                       ,x_contract_invoice_tbl     =>  x_contract_invoice_tbl);

   --rkuttiya added for bug 6313562
   IF x_contract_invoice_tbl.count > 0 THEN
     i := x_contract_invoice_tbl.FIRST;
     LOOP
        IF (OKL_CREDIT_PUB.get_creditline_by_chrid(x_contract_invoice_tbl(i).KHR_ID) = p_contract_id) THEN
           l_payment_tot := l_payment_tot + NVL(x_contract_invoice_tbl(i).AMOUNT, 0);
        END IF;
        EXIT WHEN i = x_contract_invoice_tbl.LAST;
        i := x_contract_invoice_tbl.NEXT(i);
     END LOOP;
   END IF;

 /* ankushar end changes */
  RETURN l_payment_tot;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END;
--------------------------------------------------------------------------------
-- END: cklee - bug#4655437 10/06/2005


--Bug# 3872534: start
--------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:    Rekha Pillay (rpillay)
    -- Function Name: line_asset_cost
    -- Description:   Returns the current cost of an asset in its Corporate Book
    --                from Oracle Assets
    -- Dependencies:
    -- Parameters: contract id, line id
    -- Version: 1.0
    -- End of Comments

--------------------------------------------------------------------------------
  FUNCTION line_asset_cost(
                            p_contract_id       IN NUMBER
                           ,p_contract_line_id  IN NUMBER
                          )
  RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(30) := 'LINE_ASSET_COST';
    l_api_version       CONSTANT NUMBER	      := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
    l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;

    l_converted_amount         NUMBER;
    l_contract_start_date      DATE;
    l_contract_currency        OKL_K_HEADERS_FULL_V.currency_code%TYPE;
    l_currency_conversion_type OKL_K_HEADERS_FULL_V.currency_conversion_type%TYPE;
    l_currency_conversion_rate OKL_K_HEADERS_FULL_V.currency_conversion_rate%TYPE;
    l_currency_conversion_date OKL_K_HEADERS_FULL_V.currency_conversion_date%TYPE;

    -- Bug# 4061058:
    -- Changes to ensure that the query works for Release Asset
    -- and Release Contract
    CURSOR l_asset_csr(p_chr_id  IN NUMBER
                      ,p_cle_id  IN NUMBER
                      ,p_book_class  IN VARCHAR2
                      ,p_book_type_code  IN VARCHAR2) IS
    SELECT fab.asset_id,
           fab.book_type_code
    FROM okc_k_lines_v fin_ast_cle,
         okc_statuses_b stsb,
         fa_additions fad,
         fa_book_controls fbc,
         fa_books fab
    WHERE fin_ast_cle.id = p_cle_id
    AND   fin_ast_cle.dnz_chr_id = p_chr_id
    AND   fin_ast_cle.chr_id = p_chr_id
    AND   fin_ast_cle.sts_code = stsb.code
    AND   stsb.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED','TERMINATED')
    AND   fad.asset_number = fin_ast_cle.name
    AND   fab.asset_id = fad.asset_id
    AND   fab.book_type_code = fbc.book_type_code
    AND   fab.transaction_header_id_out IS NULL
    --AND   fbc.book_class = 'CORPORATE'
    AND   fbc.book_class = p_book_class
    AND   fab.book_type_code = NVL(p_book_type_code,fab.book_type_code);

    l_asset_rec  l_asset_csr%ROWTYPE;

    -- Bug# 4061058:
    -- Changes to ensure that the query works for Release Asset
    -- and Release Contract
    CURSOR l_asset_csr_incl_terminated
                           (p_chr_id  IN NUMBER
                           ,p_cle_id  IN NUMBER
                           ,p_book_class  IN VARCHAR2
                           ,p_book_type_code  IN VARCHAR2) IS
    SELECT fab.asset_id,
           fab.book_type_code
    FROM okc_k_lines_v fin_ast_cle,
         okc_statuses_b stsb,
         fa_additions fad,
         fa_book_controls fbc,
         fa_books fab
    WHERE fin_ast_cle.id = p_cle_id
    AND   fin_ast_cle.dnz_chr_id = p_chr_id
    AND   fin_ast_cle.chr_id = p_chr_id
    AND   fin_ast_cle.sts_code = stsb.code
    AND   stsb.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED')
    AND   fad.asset_number = fin_ast_cle.name
    AND   fab.asset_id = fad.asset_id
    AND   fab.book_type_code = fbc.book_type_code
    AND   fab.transaction_header_id_out IS NULL
    --AND   fbc.book_class = 'CORPORATE'
    AND   fbc.book_class = p_book_class
    AND   fab.book_type_code = NVL(p_book_type_code,fab.book_type_code);

    CURSOR contract_start_date_csr(p_chr_id NUMBER) IS
    SELECT start_date
    FROM okc_k_headers_b
    WHERE id = p_chr_id;

    l_discount_incl_terminated BOOLEAN := FALSE;
    l_streams_repo_policy VARCHAR2(80); -- MGAAP 7263041
    l_book_class FA_BOOK_CONTROLS.BOOK_CLASS%TYPE;
    l_book_type_code FA_BOOK_CONTROLS.BOOK_TYPE_CODE%TYPE;
  BEGIN

      IF (( p_contract_id IS NULL ) OR ( p_contract_line_id IS NULL )) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      l_streams_repo_policy := OKL_STREAMS_SEC_PVT.GET_STREAMS_POLICY;
      l_book_type_code := NULL;
      IF (l_streams_repo_policy = 'PRIMARY') THEN
        l_book_class := 'CORPORATE';
      ELSE
        l_book_class := 'TAX';
        l_book_type_code := OKL_ACCOUNTING_UTIL.get_fa_reporting_book(
                              p_kle_id => p_contract_line_id);
      END IF;
           -- rmunjulu 4042892
    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_discount_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;


      --IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0
        --AND Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(0).NAME = 'TERMINATED_LINES_YN'
        --AND  Okl_Execute_Formula_Pub.g_additional_parameters(0).value = 'Y' THEN

      IF l_discount_incl_terminated THEN
          OPEN  l_asset_csr_incl_terminated(p_chr_id => p_contract_id,
                                            p_cle_id => p_contract_line_id,
                                            p_book_class => l_book_class,
                                            p_book_type_code => l_book_type_code);
          FETCH l_asset_csr_incl_terminated INTO l_asset_rec;
          IF( l_asset_csr_incl_terminated%NOTFOUND ) THEN
            CLOSE l_asset_csr_incl_terminated;
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
          CLOSE l_asset_csr_incl_terminated;
      ELSE
          OPEN  l_asset_csr(p_chr_id => p_contract_id,
                            p_cle_id => p_contract_line_id,
                            p_book_class => l_book_class,
                            p_book_type_code => l_book_type_code);
          FETCH l_asset_csr INTO l_asset_rec;
          IF( l_asset_csr%NOTFOUND ) THEN
             CLOSE l_asset_csr;
             RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
          CLOSE l_asset_csr;
      END IF;

      l_asset_hdr_rec.asset_id          := l_asset_rec.asset_id;
      l_asset_hdr_rec.book_type_code    := l_asset_rec.book_type_code;

      IF NOT fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code) THEN
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_LLA_FA_CACHE_ERROR'
                           );
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- To fetch Asset Current Cost
      IF NOT FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec         => l_asset_hdr_rec,
               px_asset_fin_rec        => l_asset_fin_rec,
               p_transaction_header_id => NULL,
               p_mrc_sob_type_code     => 'P'
              ) THEN

        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_LLA_FA_ASSET_FIN_REC_ERROR'
                           );
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- convert amount into contract currency
      OPEN contract_start_date_csr(p_chr_id => p_contract_id);
      FETCH contract_start_date_csr INTO l_contract_start_date;
      CLOSE contract_start_date_csr;

      l_converted_amount := 0;
      OKL_ACCOUNTING_UTIL.CONVERT_TO_CONTRACT_CURRENCY(
        p_khr_id                   => p_contract_id,
        p_from_currency            => NULL,
        p_transaction_date         => l_contract_start_date,
        p_amount                   => l_asset_fin_rec.cost,
        x_return_status            => x_return_status,
        x_contract_currency        => l_contract_currency,
        x_currency_conversion_type => l_currency_conversion_type,
        x_currency_conversion_rate => l_currency_conversion_rate,
        x_currency_conversion_date => l_currency_conversion_date,
        x_converted_amount         => l_converted_amount);

      IF(x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        Okl_Api.Set_Message(p_app_name     => Okl_Api.G_APP_NAME,
                            p_msg_name     => 'OKL_CONV_TO_FUNC_CURRENCY_FAIL');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      RETURN l_converted_amount;

    EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        RETURN NULL;

	WHEN OTHERS THEN
        Okl_Api.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
       RETURN NULL;

  END line_asset_cost;

--------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:    Rekha Pillay (rpillay)
    -- Function Name: line_accumulated_deprn
    -- Description:   Returns the accumulated depreciation on an asset in
    --                its Corporate Book from Oracle Assets
    -- Dependencies:
    -- Parameters: contract id, line id
    -- Version: 1.0
    -- End of Comments

--------------------------------------------------------------------------------
  FUNCTION line_accumulated_deprn(
                            p_contract_id       IN  NUMBER
                           ,p_contract_line_id  IN NUMBER
                          )
  RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(30) := 'LINE_ACCUMULATED_DEPRN';
    l_api_version       CONSTANT NUMBER	      := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
    l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;

    l_converted_amount         NUMBER;
    l_contract_start_date      DATE;
    l_contract_currency        OKL_K_HEADERS_FULL_V.currency_code%TYPE;
    l_currency_conversion_type OKL_K_HEADERS_FULL_V.currency_conversion_type%TYPE;
    l_currency_conversion_rate OKL_K_HEADERS_FULL_V.currency_conversion_rate%TYPE;
    l_currency_conversion_date OKL_K_HEADERS_FULL_V.currency_conversion_date%TYPE;

    -- Bug# 4061058:
    -- Changes to ensure that the query works for Release Asset
    -- and Release Contract
    CURSOR l_asset_csr(p_chr_id  IN NUMBER
                      ,p_cle_id  IN NUMBER
                      ,p_book_class  IN VARCHAR2
                      ,p_book_type_code  IN VARCHAR2) IS
    SELECT fab.asset_id,
           fab.book_type_code
    FROM okc_k_lines_v fin_ast_cle,
         okc_statuses_b stsb,
         fa_additions fad,
         fa_book_controls fbc,
         fa_books fab
    WHERE fin_ast_cle.id = p_cle_id
    AND   fin_ast_cle.dnz_chr_id = p_chr_id
    AND   fin_ast_cle.chr_id = p_chr_id
    AND   fin_ast_cle.sts_code = stsb.code
    AND   stsb.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED','TERMINATED')
    AND   fad.asset_number = fin_ast_cle.name
    AND   fab.asset_id = fad.asset_id
    AND   fab.book_type_code = fbc.book_type_code
    AND   fab.transaction_header_id_out IS NULL
    --AND   fbc.book_class = 'CORPORATE';
    AND   fbc.book_class = p_book_class
    AND   fab.book_type_code = NVL(p_book_type_code,fab.book_type_code);

    l_asset_rec  l_asset_csr%ROWTYPE;

    -- Bug# 4061058:
    -- Changes to ensure that the query works for Release Asset
    -- and Release Contract
    CURSOR l_asset_csr_incl_terminated
                           (p_chr_id  IN NUMBER
                           ,p_cle_id  IN NUMBER
                           ,p_book_class  IN VARCHAR2
                           ,p_book_type_code  IN VARCHAR2) IS
    SELECT fab.asset_id,
           fab.book_type_code
    FROM okc_k_lines_v fin_ast_cle,
         okc_statuses_b stsb,
         fa_additions fad,
         fa_book_controls fbc,
         fa_books fab
    WHERE fin_ast_cle.id = p_cle_id
    AND   fin_ast_cle.dnz_chr_id = p_chr_id
    AND   fin_ast_cle.chr_id = p_chr_id
    AND   fin_ast_cle.sts_code = stsb.code
    AND   stsb.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED')
    AND   fad.asset_number = fin_ast_cle.name
    AND   fab.asset_id = fad.asset_id
    AND   fab.book_type_code = fbc.book_type_code
    AND   fab.transaction_header_id_out IS NULL
    --AND   fbc.book_class = 'CORPORATE';
    AND   fbc.book_class = p_book_class
    AND   fab.book_type_code = NVL(p_book_type_code,fab.book_type_code);

    CURSOR contract_start_date_csr(p_chr_id NUMBER) IS
    SELECT start_date
    FROM okc_k_headers_b
    WHERE id = p_chr_id;

    l_discount_incl_terminated BOOLEAN := FALSE;
    l_streams_repo_policy VARCHAR2(80); -- MGAAP 7263041
    l_book_class FA_BOOK_CONTROLS.BOOK_CLASS%TYPE;
    l_book_type_code FA_BOOK_CONTROLS.BOOK_TYPE_CODE%TYPE;

  BEGIN

      IF (( p_contract_id IS NULL ) OR ( p_contract_line_id IS NULL )) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      l_streams_repo_policy := OKL_STREAMS_SEC_PVT.GET_STREAMS_POLICY;
      l_book_type_code := NULL;
      IF (l_streams_repo_policy = 'PRIMARY') THEN
        l_book_class := 'CORPORATE';
      ELSE
        l_book_class := 'TAX';
        l_book_type_code := OKL_ACCOUNTING_UTIL.get_fa_reporting_book(
                              p_kle_id => p_contract_line_id);
      END IF;
           -- rmunjulu 4042892
    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_discount_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;

     -- IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0
       -- AND Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(0).NAME = 'TERMINATED_LINES_YN'
       --AND  Okl_Execute_Formula_Pub.g_additional_parameters(0).value = 'Y' THEN

     IF l_discount_incl_terminated THEN
          OPEN  l_asset_csr_incl_terminated(p_chr_id => p_contract_id,
                                            p_cle_id => p_contract_line_id,
                                            p_book_class => l_book_class,
                                            p_book_type_code => l_book_type_code);
          FETCH l_asset_csr_incl_terminated INTO l_asset_rec;
          IF( l_asset_csr_incl_terminated%NOTFOUND ) THEN
            CLOSE l_asset_csr_incl_terminated;
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
          CLOSE l_asset_csr_incl_terminated;
      ELSE
          OPEN  l_asset_csr(p_chr_id => p_contract_id,
                            p_cle_id => p_contract_line_id,
                            p_book_class => l_book_class,
                            p_book_type_code => l_book_type_code);
          FETCH l_asset_csr INTO l_asset_rec;
          IF( l_asset_csr%NOTFOUND ) THEN
             CLOSE l_asset_csr;
             RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
          CLOSE l_asset_csr;
      END IF;

      l_asset_hdr_rec.asset_id          := l_asset_rec.asset_id;
      l_asset_hdr_rec.book_type_code    := l_asset_rec.book_type_code;

      IF NOT fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code) THEN
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_LLA_FA_CACHE_ERROR'
                           );
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- To fetch Depreciation Reserve
      IF NOT FA_UTIL_PVT.get_asset_deprn_rec
              (p_asset_hdr_rec         => l_asset_hdr_rec ,
               px_asset_deprn_rec      => l_asset_deprn_rec,
               p_period_counter        => NULL,
               p_mrc_sob_type_code     => 'P'
               ) THEN
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_LLA_FA_DEPRN_REC_ERROR'
                           );
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- convert amount into contract currency
      OPEN contract_start_date_csr(p_chr_id => p_contract_id);
      FETCH contract_start_date_csr INTO l_contract_start_date;
      CLOSE contract_start_date_csr;

      l_converted_amount := 0;
      OKL_ACCOUNTING_UTIL.CONVERT_TO_CONTRACT_CURRENCY(
        p_khr_id                   => p_contract_id,
        p_from_currency            => NULL,
        p_transaction_date         => l_contract_start_date,
        p_amount                   => l_asset_deprn_rec.deprn_reserve,
        x_return_status            => x_return_status,
        x_contract_currency        => l_contract_currency,
        x_currency_conversion_type => l_currency_conversion_type,
        x_currency_conversion_rate => l_currency_conversion_rate,
        x_currency_conversion_date => l_currency_conversion_date,
        x_converted_amount         => l_converted_amount);

      IF(x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        Okl_Api.Set_Message(p_app_name     => Okl_Api.G_APP_NAME,
                            p_msg_name     => 'OKL_CONV_TO_FUNC_CURRENCY_FAIL');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      RETURN l_converted_amount;

    EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        RETURN NULL;

	WHEN OTHERS THEN
        Okl_Api.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
       RETURN NULL;

  END line_accumulated_deprn;

--------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:    Rekha Pillay (rpillay)
    -- Function Name: contract_asset_cost
    -- Description:   Returns the sum of current cost of all assets
    --                in the contract from Oracle Assets
    -- Dependencies:
    -- Parameters: contract id, line id
    -- Version: 1.0
    -- End of Comments

--------------------------------------------------------------------------------
  FUNCTION contract_asset_cost(
                            p_contract_id       IN NUMBER
                           ,p_contract_line_id  IN NUMBER
                          )
  RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(30) := 'CONTRACT_ASSET_COST';
    l_api_version       CONSTANT NUMBER	      := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    CURSOR l_finast_csr(p_chr_id  IN NUMBER) IS
    SELECT fin_cle.id
    FROM okc_k_lines_b fin_cle,
         okc_line_styles_b lse,
         okc_statuses_b stsb
    WHERE fin_cle.dnz_chr_id = p_chr_id
    AND   fin_cle.chr_id = p_chr_id
    AND   fin_cle.lse_id = lse.id
    AND   lse.lty_code = 'FREE_FORM1'
    AND   fin_cle.sts_code = stsb.code
    AND   stsb.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED','TERMINATED');

    CURSOR l_finast_csr_incl_terminated(p_chr_id  IN NUMBER) IS
    SELECT fin_cle.id
    FROM okc_k_lines_b fin_cle,
         okc_line_styles_b lse,
         okc_statuses_b stsb
    WHERE fin_cle.dnz_chr_id = p_chr_id
    AND   fin_cle.chr_id = p_chr_id
    AND   fin_cle.lse_id = lse.id
    AND   lse.lty_code = 'FREE_FORM1'
    AND   fin_cle.sts_code = stsb.code
    AND   stsb.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED');

    l_sum_asset_cost NUMBER;
    l_asset_cost NUMBER;

    l_discount_incl_terminated BOOLEAN := FALSE;

  BEGIN

      IF ( p_contract_id IS NULL ) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      l_sum_asset_cost := 0;

           -- rmunjulu 4042892
    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_discount_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;


     -- IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0
      --  AND Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(0).NAME = 'TERMINATED_LINES_YN'
       -- AND  Okl_Execute_Formula_Pub.g_additional_parameters(0).value = 'Y' THEN

     IF l_discount_incl_terminated THEN
        FOR l_finast_rec IN l_finast_csr_incl_terminated(p_chr_id => p_contract_id) LOOP
          l_asset_cost := line_asset_cost(p_contract_id,l_finast_rec.id);
          IF (l_asset_cost IS NULL) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
          l_sum_asset_cost := l_sum_asset_cost + l_asset_cost;
        END LOOP;

      ELSE

         FOR l_finast_rec IN l_finast_csr(p_chr_id => p_contract_id) LOOP
          l_asset_cost := line_asset_cost(p_contract_id,l_finast_rec.id);
          IF (l_asset_cost IS NULL) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
          l_sum_asset_cost := l_sum_asset_cost + l_asset_cost;
        END LOOP;

      END IF;

      RETURN l_sum_asset_cost;

    EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        RETURN NULL;

	WHEN OTHERS THEN
        Okl_Api.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
       RETURN NULL;

  END contract_asset_cost;

--------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:    Rekha Pillay (rpillay)
    -- Function Name: contract_accumulated_deprn
    -- Description:   Returns the sum of accumulated depreciation
    --                for all assets in the contract from Oracle Assets
    -- Dependencies:
    -- Parameters: contract id, line id
    -- Version: 1.0
    -- End of Comments

--------------------------------------------------------------------------------
  FUNCTION contract_accumulated_deprn(
                            p_contract_id       IN NUMBER
                           ,p_contract_line_id  IN NUMBER
                          )
  RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(30) := 'CONTRACT_ACCUMULATED_DEPRN';
    l_api_version       CONSTANT NUMBER	      := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    CURSOR l_finast_csr(p_chr_id  IN NUMBER) IS
    SELECT fin_cle.id
    FROM okc_k_lines_b fin_cle,
         okc_line_styles_b lse,
         okc_statuses_b stsb
    WHERE fin_cle.dnz_chr_id = p_chr_id
    AND   fin_cle.chr_id = p_chr_id
    AND   fin_cle.lse_id = lse.id
    AND   lse.lty_code = 'FREE_FORM1'
    AND   fin_cle.sts_code = stsb.code
    AND   stsb.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED','TERMINATED');

    CURSOR l_finast_csr_incl_terminated(p_chr_id  IN NUMBER) IS
    SELECT fin_cle.id
    FROM okc_k_lines_b fin_cle,
         okc_line_styles_b lse,
         okc_statuses_b stsb
    WHERE fin_cle.dnz_chr_id = p_chr_id
    AND   fin_cle.chr_id = p_chr_id
    AND   fin_cle.lse_id = lse.id
    AND   lse.lty_code = 'FREE_FORM1'
    AND   fin_cle.sts_code = stsb.code
    AND   stsb.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED');

    l_sum_accumulated_deprn NUMBER;
    l_accumulated_deprn NUMBER;

    l_discount_incl_terminated BOOLEAN := FALSE;

  BEGIN

      IF ( p_contract_id IS NULL ) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      l_sum_accumulated_deprn := 0;

           -- rmunjulu 4042892
    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_discount_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;


      --IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0
        --AND Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS(0).NAME = 'TERMINATED_LINES_YN'
        --AND  Okl_Execute_Formula_Pub.g_additional_parameters(0).value = 'Y' THEN

      IF l_discount_incl_terminated THEN
        FOR l_finast_rec IN l_finast_csr_incl_terminated(p_chr_id => p_contract_id) LOOP
          l_accumulated_deprn := line_accumulated_deprn(p_contract_id,l_finast_rec.id);
          IF (l_accumulated_deprn IS NULL) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
          l_sum_accumulated_deprn := l_sum_accumulated_deprn + l_accumulated_deprn;
        END LOOP;

      ELSE

         FOR l_finast_rec IN l_finast_csr(p_chr_id => p_contract_id) LOOP
          l_accumulated_deprn := line_accumulated_deprn(p_contract_id,l_finast_rec.id);
          IF (l_accumulated_deprn IS NULL) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
          l_sum_accumulated_deprn := l_sum_accumulated_deprn + l_accumulated_deprn;
        END LOOP;

      END IF;

      RETURN l_sum_accumulated_deprn;

    EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        RETURN NULL;

	WHEN OTHERS THEN
        Okl_Api.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
       RETURN NULL;

  END contract_accumulated_deprn;

--Bug# 3872534: end

--------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:    avsingh
    -- Function Name: contract_financed_amount
    -- Description:   Returns the contract financed amount for
    --                  booking page
    -- Dependencies:
    -- Parameters: contract id, line id
    -- Version: 1.0
    -- End of Comments

--------------------------------------------------------------------------------
  FUNCTION contract_financed_amount(
                            p_contract_id       IN NUMBER
                           ,p_contract_line_id  IN NUMBER
                          )
  RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(30) := 'CONTRACT_CAPITAL_AMOUNT';
    l_api_version       CONSTANT NUMBER       := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

      --cursor to find total capital amount
    CURSOR l_cap_amnt_csr( ChrId NUMBER) IS
    SELECT NVL(SUM(kle.capital_amount),0)
           --bug# 4899328
           --+ NVL(SUM(kle.capitalized_interest),0) CapAmountLines
    FROM   OKC_LINE_STYLES_B  LSEB,
           OKL_K_LINES        KLE,
           OKC_K_LINES_B      CLEB,
           OKC_STATUSES_B     STSB
    WHERE  LSEB.ID               = CLEB.LSE_ID
    AND    LSEB.lty_code         = 'FREE_FORM1'
    AND    KLE.id                = CLEB.ID
    AND    CLEB.CHR_ID           = ChrId
    AND    CLEB.DNZ_CHR_ID       = ChrId
    AND    CLEB.sts_code         = STSB.code
    AND    STSB.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');

-- fixed bug 4134296
    -- cursor to find total Rollover Fee Amount for a Contract
    CURSOR l_rollover_fee_csr(l_dnz_chr_id okc_k_headers_b.id%TYPE) IS
    SELECT
      NVL(SUM(NVL(KLEB.amount,0)),0) ROLLOVER_AMOUNT
    FROM
      OKL_K_LINES KLEB,
      OKC_K_LINES_B CLEB,
      OKC_LINE_STYLES_B LSEB,
      OKC_STATUSES_B STS
    WHERE
      KLEB.ID = CLEB.ID AND
      CLEB.LSE_ID = LSEB.ID AND
      LSEB.LTY_CODE = 'FEE' AND
      KLEB.FEE_TYPE = 'ROLLOVER' AND
      CLEB.DNZ_CHR_ID = l_dnz_chr_id AND
      CLEB.STS_CODE = STS.CODE AND
      STS.STE_CODE NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');


    l_rollover_fee_amount NUMBER;

    l_capital_amount NUMBER;

    l_financed_fee NUMBER;

    l_contract_financed_amount NUMBER;


  BEGIN

      IF ( p_contract_id IS NULL ) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      l_capital_amount := 0;
      l_financed_fee   := 0;
      l_contract_financed_amount := 0;
      l_rollover_fee_amount := 0;

      OPEN l_cap_amnt_csr(ChrId => p_contract_id);
      FETCH l_cap_amnt_csr INTO l_capital_amount;
      IF l_cap_amnt_csr%NOTFOUND THEN
          NULL;
      END IF;
      CLOSE l_cap_amnt_csr;

      FOR l_rollover_fee in l_rollover_fee_csr(p_contract_id)
      LOOP

        l_rollover_fee_amount := l_rollover_fee.rollover_amount;

      END LOOP;


      l_financed_fee := contract_financed_fee(p_contract_id, NULL);
      l_contract_financed_amount := l_capital_amount + l_financed_fee + l_rollover_fee_amount;

      RETURN l_contract_financed_amount;

   EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        RETURN NULL;

        WHEN OTHERS THEN
        Okl_Api.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
       RETURN NULL;
  END contract_financed_amount;

--start:cklee
--------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:    cklee
    -- Function Name: rollover fee
    -- Description:   Returns the credit line total rollover fee
    --
    -- Dependencies:
    -- Parameters: contract id, line id
    -- Version: 1.0
    -- End of Comments

--------------------------------------------------------------------------------
  FUNCTION rollover_fee(
                            p_contract_id       IN NUMBER
                           ,p_contract_line_id  IN NUMBER
                          )
  RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(30) := 'ROLLOVER_FEE';
    l_api_version       CONSTANT NUMBER       := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

      --cursor to find...
    Cursor l_csr( ChrId NUMBER) IS
    SELECT NVL(chr.TOT_CL_TRANSFER_AMT,0)
    FROM   OKL_K_HEADERS  chr
    WHERE  chr.ID       = ChrId;

    l_amount number := 0;

  BEGIN

      open l_csr(ChrId => p_contract_id);
      fetch l_csr into l_amount;
      close l_csr;

      RETURN l_amount;

   EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        RETURN NULL;

        WHEN OTHERS THEN
        Okl_Api.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
       RETURN NULL;
  END rollover_fee;

--------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:    cklee
    -- Function Name: tot_net_transfers
    -- Description:   Returns the credit line total net transfers (T and A)
    --
    -- Dependencies:
    -- Parameters: contract id, line id
    -- Version: 1.0
    -- End of Comments

--------------------------------------------------------------------------------
  FUNCTION tot_net_transfers(
                            p_contract_id       IN NUMBER
                           ,p_contract_line_id  IN NUMBER
                          )
  RETURN NUMBER  IS

    l_api_name          CONSTANT VARCHAR2(30) := 'TOT_NET_TRANSFERS';
    l_api_version       CONSTANT NUMBER       := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

      --cursor to find...
    Cursor l_csr( ChrId NUMBER) IS
    SELECT NVL(chr.TOT_CL_NET_TRANSFER_AMT,0)
    FROM   OKL_K_HEADERS  chr
    WHERE  chr.ID       = ChrId;

    l_amount number := 0;

  BEGIN

      open l_csr(ChrId => p_contract_id);
      fetch l_csr into l_amount;
      close l_csr;

      RETURN l_amount;

   EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        RETURN NULL;

        WHEN OTHERS THEN
        Okl_Api.SET_MESSAGE(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);
       RETURN NULL;
  END tot_net_transfers;
--end:cklee


------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    rmunjulu 3816891
  -- Function Name: line_future_rent
  -- Description:   Returns the future rent amount for a given contract line
  -- Dependencies:  OKL building blocks AMTX and AMUV
  -- Parameters:    IN:  p_contract_id, p_line_id
  --                     stream_type_id (stored in g_additional_parameters(1))
  --                OUT: amount
  -- Version:       1.0
  -- History      : 31-Dec-2004 PAGARG Bug# 4097591
  --              : UDS impact to obtain stream type id
  --              : 15-Oct-07 prasjain Bug 6030917
  --              : Added proration logic
  -- End of Commnets
------------------------------------------------------------------------------

FUNCTION line_future_rent (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS

    -- Get future Streams
    -- Guru added trx_date

	CURSOR l_future_stream_csr (
			cp_contract_id			NUMBER,
			cp_contract_line_id		NUMBER,
			cp_stream_type_id		NUMBER,
            cp_trx_date             DATE) IS
	SELECT	SUM (NVL (ste.amount, 0))	amount_due
	--FROM	okl_streams			stm,
	FROM	okl_streams_rep_v		stm,
                okl_strm_type_b     sty,
			    okl_strm_elements		ste
	WHERE	stm.khr_id			= cp_contract_id
	AND	stm.kle_id			= cp_contract_line_id
	AND	stm.sty_id			= NVL (cp_stream_type_id, stm.sty_id)
	AND	stm.active_yn			= 'Y'
	AND	stm.say_code			= 'CURR'
	AND	ste.stm_id			= stm.id
	AND	NVL (ste.amount, 0)	<> 0
  -- Added the following 3 conditions to restrict the unbilled receivables calculation to only
  -- billable streams
    AND sty.id              = stm.sty_id
    AND sty.billable_yn     = 'Y'
    AND ste.STREAM_ELEMENT_DATE > nvl(cp_trx_date,sysdate);   -- gkadarka added this null check

     -- Get future Streams for Reporting product
	CURSOR l_future_reporting_stream_csr (
			cp_contract_id			NUMBER,
			cp_contract_line_id		NUMBER,
			cp_stream_type_id		NUMBER,
            cp_trx_date             DATE) IS
	SELECT	SUM (NVL (ste.amount, 0))	amount_due
	FROM	okl_streams			stm,
                okl_strm_type_b     sty, --  Added this table to get the billable_yn flag
			    okl_strm_elements		ste
	WHERE	stm.khr_id			= cp_contract_id
	AND	stm.kle_id			= cp_contract_line_id
	AND	stm.sty_id			= NVL (cp_stream_type_id, stm.sty_id)
	AND	stm.active_yn			= 'N'  -- reporting strems are inactive
	AND	stm.say_code			= 'CURR'  -- reporting streams are current
	AND	ste.stm_id			= stm.id
	--AND	ste.date_billed			IS NULL  -- reporting streams never get billed
	AND	NVL (ste.amount, 0)	<> 0
    AND sty.id              = stm.sty_id
    AND sty.billable_yn     = 'Y' -- reporting streams are billable
    AND stm.purpose_code = 'REPORT'
    AND ste.STREAM_ELEMENT_DATE > nvl(cp_trx_date,sysdate);  -- gkadarka added this null check

    l_rep_prod_streams_yn   VARCHAR2(1) := 'N';
    l_trx_date   DATE;

	l_result_amount		NUMBER		:= 0;
	l_stream_type_id	NUMBER;

	-- rmunjulu
	l_quote_eff_date DATE;
	l_term_date DATE;
	l_return_status     VARCHAR2(3) := Okl_Api.G_RET_STS_SUCCESS;

    -- Start : Bug 6030917 : prasjain
    --new cursor introduced for prorating and rounding the stream element amount
    --incase of partial unit termination
          CURSOR stream_element_csr (
                          cp_contract_id                        NUMBER,
                          cp_contract_line_id                NUMBER,
                          cp_stream_type_id                NUMBER,
              cp_trx_date             DATE) IS
          SELECT nvl(ste.amount, 0)        amount
          FROM        okl_streams                        stm,
          okl_strm_type_b     sty,
                            okl_strm_elements                ste
          WHERE        stm.khr_id                        = cp_contract_id
          AND          stm.kle_id                        = cp_contract_line_id
          AND          stm.sty_id                        = NVL (cp_stream_type_id, stm.sty_id)
          AND          stm.active_yn                        = 'Y'
          AND          stm.say_code                        = 'CURR'
          AND          ste.stm_id                        = stm.id
          AND          NVL (ste.amount, 0)        <> 0
    AND   sty.id              = stm.sty_id
    AND   sty.billable_yn     = 'Y'
    AND   ste.stream_element_date > nvl(cp_trx_date,sysdate);

    stream_element_rec stream_element_csr%ROWTYPE;
    --currency code cursor added to derive currency code for the particular line
    --which will be used for rounding amount
    CURSOR currency_code_csr (p_kle_id     NUMBER ) IS
    SELECT currency_code
    FROM   okc_k_lines_b
    WHERE  id = p_kle_id;
    --declaring proration factor , currency code and rounding rule variables
    l_proration_factor           NUMBER;
    l_currency_code              okc_k_lines_b.currency_code%TYPE;
    l_parent_strm_amt               NUMBER;
    l_parent_strm_rounded_amt       NUMBER;
    l_parent_strm_rounded_tot_amt   NUMBER;
    --declaring other local variables
    i                           NUMBER;
    l_api_version               NUMBER := 1;
    l_init_msg_list             VARCHAR2(1) := OKL_API.G_FALSE;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(100);
    -- End : Bug 6030917 : prasjain

BEGIN
    --PAGARG 31-Dec-2004 Bug# 4097591 Start
    --UDS impact. Obtain stream type id and pass it to cursor

    OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                             'RENT',
                                             l_return_status,
                                             l_stream_type_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --PAGARG 31-Dec-2004 Bug# 4097591 End

	-- ********************************************
	-- Extract Stream Type Id from global variables
	-- ********************************************

    --Validate additional parameters availability
    IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'REP_PRODUCT_STRMS_YN'
           AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_rep_prod_streams_yn := okl_execute_formula_pub.g_additional_parameters(I).value;
        ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'OFF_LSE_TRX_DATE'
           AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_trx_date := to_date(okl_execute_formula_pub.g_additional_parameters(I).value, 'MM/DD/YYYY');
        -- rmunjulu -- this formula is called for amortization which will pass quote eff date
        ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'quote_effective_from_date'
           AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_quote_eff_date := to_date(okl_execute_formula_pub.g_additional_parameters(I).value, 'MM/DD/YYYY');

          -- Start : Bug 6030917 : prasjain
          --added for getting the proration factor for partial unit termination
          ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'proration_factor'
             AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                  l_proration_factor := to_number(okl_execute_formula_pub.g_additional_parameters(I).value);
          -- End : Bug 6030917 : prasjain

        END IF;
      END LOOP;
	ELSE
      l_rep_prod_streams_yn := 'N';

	END IF;

    IF l_rep_prod_streams_yn = 'Y' THEN
       IF l_trx_date IS NULL THEN
       -- Can not calculate Net Investment for the reporting product as the transaction date is missing.
          Okl_Api.Set_Message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AM_AMORT_NO_TRX_DATE');
          RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;
    END IF;

    -- rmunjulu
    IF l_quote_eff_date IS NULL THEN
         l_term_date := SYSDATE;
    ELSE
         l_term_date := l_quote_eff_date;
    END IF;
	-- ****************
	-- Calculate result
	-- ****************

    IF l_rep_prod_streams_yn = 'Y' THEN  -- MGAAP 7263041
       --OPEN  l_future_reporting_stream_csr(p_contract_id, p_contract_line_id, l_stream_type_id,l_trx_date );
       OPEN  l_future_stream_csr(p_contract_id, p_contract_line_id, l_stream_type_id,l_trx_date );
       FETCH l_future_stream_csr INTO  l_result_amount;
       CLOSE l_future_stream_csr;
    ELSE
-- Guru added trx_date here
        -- Start : Bug 6030917 : prasjain
        --added for prorating incase of partial unit termination
        IF nvl(l_proration_factor,1) = 1 THEN

	   OPEN  l_future_stream_csr (p_contract_id, p_contract_line_id, l_stream_type_id,l_term_date); -- rmunjulu changed to quote eff date
	   FETCH l_future_stream_csr INTO l_result_amount;
	   CLOSE l_future_stream_csr;
       ELSE
         --get curerncy code for the line
          OPEN  currency_code_csr(p_contract_line_id);
          FETCH currency_code_csr INTO l_currency_code ;
          CLOSE currency_code_csr;
          --initializing l_parent_strm_rounded_tot_amt variable with 0
          l_parent_strm_rounded_tot_amt := 0;

          FOR stream_element_rec IN stream_element_csr(p_contract_id,
                                                       p_contract_line_id,
                                                       l_stream_type_id,
                                                       l_term_date)
          LOOP
             --prorate the amount, to derive the parent stream amount
              l_parent_strm_amt := stream_element_rec.amount * l_proration_factor;
             --round amount with streams option for paren stream element amounts
             okl_accounting_util.round_amount(
                         p_api_version    => l_api_version,
                         p_init_msg_list  => l_init_msg_list,
                         x_return_status  => l_return_status,
                         x_msg_count      => l_msg_count,
                         x_msg_data       => l_msg_data,
                         p_amount         => l_parent_strm_amt,
                         p_currency_code  => l_currency_code,
                         p_round_option   => 'STM',
                         x_rounded_amount => l_parent_strm_rounded_amt
                         );
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
             -- calculate the parent stream rounded total
             l_parent_strm_rounded_tot_amt := l_parent_strm_rounded_tot_amt
                                                 + l_parent_strm_rounded_amt;

          END LOOP;
            l_result_amount := l_parent_strm_rounded_tot_amt;
        END IF;
       -- End : Bug 6030917 : prasjain
    END IF;

	RETURN NVL (l_result_amount, 0);

EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        -- Close open cursors
        IF l_future_stream_csr%ISOPEN THEN
            CLOSE l_future_stream_csr;
        END IF;

        IF l_future_reporting_stream_csr%ISOPEN THEN
            CLOSE l_future_reporting_stream_csr;
        END IF;

         -- Start : Bug 6030917 : prasjain
          IF currency_code_csr%ISOPEN THEN
              CLOSE currency_code_csr;
          END IF;
          IF stream_element_csr%ISOPEN THEN
              CLOSE stream_element_csr;
          END IF;
          -- End : Bug 6030917 : prasjain

        RETURN NULL;

	WHEN OTHERS THEN
		-- Close open cursors
        IF l_future_stream_csr%ISOPEN THEN
            CLOSE l_future_stream_csr;
        END IF;

        IF l_future_reporting_stream_csr%ISOPEN THEN
            CLOSE l_future_reporting_stream_csr;
        END IF;

          -- Start : Bug 6030917 : prasjain
          IF currency_code_csr%ISOPEN THEN
              CLOSE currency_code_csr;
          END IF;
          IF stream_element_csr%ISOPEN THEN
              CLOSE stream_element_csr;
          END IF;
          -- End : Bug 6030917 : prasjain

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_CONTRACTS_UNEXPECTED_ERROR',
			p_token1	=> 'SQLCODE',
			p_token1_value	=> SQLCODE,
			p_token2	=> 'SQLERRM',
			p_token2_value	=> SQLERRM);

		RETURN NULL;

END line_future_rent;

------------------------------------------------------------------------------
  -- Start of Comments
  -- Created By:    rmunjulu 3816891
  -- Function Name: line_future_income
  -- Description:   Returns the future income amount for a given contract line
  -- Dependencies:  OKL building blocks AMTX and AMUV
  -- Parameters:    IN:  p_contract_id, p_line_id
  --                     stream_type_id (stored in g_additional_parameters(1))
  --                OUT: amount
  -- Version:       1.0
  -- History      : 31-Dec-2004 PAGARG Bug# 4097591
  --              : UDS impact to obtain stream type id
  --              : 11-May-2006 gboomina Bug 5215019
  --              : check CHK_ACCRUAL_PREVIOUS_MNTH_YN
  --              : 15-Oct-07 prasjain Bug 6030917
  --              : Added proration logic
  --              : sechawla 05-dec-07 6671849 : Modified the dependent stream type check
  -- End of Commnets
------------------------------------------------------------------------------

FUNCTION line_future_income (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER)
	RETURN NUMBER IS

	l_unearned_income	NUMBER 	:= 0;
-- 26-Aug-2004 Guru declared the following variables for bug 3849355
    l_term_date DATE;
    l_period_name VARCHAR2(30);
    l_start_date DATE;
    l_end_date DATE;

	--Code changed by rvaduri for bug 3487920
	--This code will return the Pre-tax income at line level
	-- and will return values only contracts booked using ISG.
-- Guru Added trx date
    --PAGARG 31-Dec-2004 Bug# 4097591
    --Instead of using stream name, join the sty id passed to cursor
    CURSOR line_csr (c_contract_line_id      NUMBER,
                     cp_trx_date             DATE,
                     p_sty_id                NUMBER) IS
      SELECT NVL(SUM(sel.amount),0)
      FROM okl_strm_elements sel,
           --okl_streams stm, MGAAP 7263041
           okl_streams_rep_v stm,
           okl_strm_type_v sty
      WHERE sty.id = p_sty_id
        AND stm.sty_id = sty.id
        AND stm.say_code = 'CURR'
        AND stm.active_yn = 'Y'
        AND (stm.purpose_code IS NULL OR stm.purpose_code='REPORT')
        AND stm.kle_id = c_contract_line_id
        AND sel.stm_id = stm.id
        -- guru Added
    AND sel.STREAM_ELEMENT_DATE >  nvl(cp_trx_date,sysdate);    -- gkadarka added this null check

    l_rep_prod_streams_yn   VARCHAR2(1) := 'N';
    l_trx_date   DATE;

    -- Created this cursor to evaluat ereporting streams based upon additional parameters
    --PAGARG 31-Dec-2004 Bug# 4097591
    --Instead of using stream name, join the sty id passed to cursor
    CURSOR line_reporting_csr (c_contract_line_id IN NUMBER, cp_trx_date IN DATE, p_sty_id NUMBER) IS
      SELECT NVL(SUM(sel.amount),0)
      FROM okl_strm_elements sel,
           --okl_streams stm, MGAAP 7263041
           okl_streams_rep_v stm,
           okl_strm_type_v sty
      WHERE sty.id = p_sty_id
        AND stm.sty_id = sty.id
        AND stm.say_code = 'CURR' -- reporting streams are current
        AND stm.active_yn = 'N'  -- reporting strems are inactive
        AND stm.purpose_code IS NULL
     --   AND	sel.date_billed	IS NULL  -- reporting streams never get billed
        --AND sty.billable_yn     = 'N'  -- PRE-TAX streams are not billable
        AND stm.kle_id = c_contract_line_id
        AND sel.stm_id = stm.id
        AND stm.purpose_code = 'REPORT'
        AND sel.STREAM_ELEMENT_DATE >  nvl(cp_trx_date,sysdate);   -- gkadarka added this null check

     -- gboomina Bug 5215019 - Start
     CURSOR check_accrual_previous_csr IS
       SELECT NVL(CHK_ACCRUAL_PREVIOUS_MNTH_YN,'N')
       FROM OKL_SYSTEM_PARAMS;

       l_accrual_previous_mnth_yn VARCHAR2(3);
       l_accrual_adjst_date DATE;
     -- gboomina Bug 5215019 - End

    -- rmunjulu
    l_quote_eff_date DATE;
	l_stream_type_id	NUMBER;
	l_return_status     VARCHAR2(3) := Okl_Api.G_RET_STS_SUCCESS;

    l_debug_unearned_income        NUMBER         := 0;
    -- Start : Bug 6030917 : prasjain
    --new cursor introduced for prorating and rounding the stream element amount
    --incase of partial unit termination
    CURSOR stream_element_csr (c_contract_line_id      NUMBER,
                               cp_trx_date             DATE,
                               p_sty_id                NUMBER) IS
    SELECT NVL(sel.amount,0) amount
    FROM okl_strm_elements sel,
         --okl_streams stm, MGAAP 7263041
         okl_streams_rep_v stm,
         okl_strm_type_v sty
    WHERE sty.id = p_sty_id
      AND stm.sty_id = sty.id
      AND stm.say_code = 'CURR'
      AND stm.active_yn = 'Y'
      AND (stm.purpose_code IS NULL OR stm.purpose_code='REPORT')
      AND stm.kle_id = c_contract_line_id
      AND sel.stm_id = stm.id
      AND sel.STREAM_ELEMENT_DATE >  nvl(cp_trx_date,sysdate);
    stream_element_rec stream_element_csr%ROWTYPE;
    --currency code cursor added to derive currency code for the particular line
    --which will be used for rounding amount
    CURSOR currency_code_csr (p_kle_id     NUMBER ) IS
    SELECT currency_code
    FROM   okc_k_lines_b
    WHERE  id = p_kle_id;
    --declaring proration factor , currency code and rounding rule variables
    l_proration_factor           NUMBER;
    l_currency_code              okc_k_lines_b.currency_code%TYPE;
    l_parent_strm_amt               NUMBER;
    l_parent_strm_rounded_amt       NUMBER;
    l_parent_strm_rounded_tot_amt   NUMBER;
    --declaring other local variables
    l_api_version               NUMBER := 1;
    l_init_msg_list             VARCHAR2(1) := OKL_API.G_FALSE;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(100);
    -- End : Bug 6030917 : prasjain

    lx_rep_product_id               OKL_PRODUCTS_V.ID%TYPE;

BEGIN

   --  Validate additional parameters availability
    IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'REP_PRODUCT_STRMS_YN'
           AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_rep_prod_streams_yn := okl_execute_formula_pub.g_additional_parameters(I).value;
        ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'OFF_LSE_TRX_DATE'
           AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_trx_date := to_date(okl_execute_formula_pub.g_additional_parameters(I).value, 'MM/DD/YYYY');
        -- rmunjulu -- this formula is called for amortization which will pass quote eff date
        ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'quote_effective_from_date'
           AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                l_quote_eff_date := to_date(okl_execute_formula_pub.g_additional_parameters(I).value, 'MM/DD/YYYY');

          -- Start : Bug 6030917 : prasjain
          --added for getting the proration factor for partial unit termination
          ELSIF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'proration_factor'
             AND  okl_execute_formula_pub.g_additional_parameters(I).value IS NOT NULL THEN
                  l_proration_factor := to_number(okl_execute_formula_pub.g_additional_parameters(I).value);
          -- End : Bug 6030917 : prasjain

        END IF;
      END LOOP;
	ELSE

      l_rep_prod_streams_yn := 'N';

	END IF;

    -- sechawla 05-dec-07 6671849 -- START
	IF l_rep_prod_streams_yn = 'Y' THEN

	      get_reporting_product(
                                  p_api_version           => l_api_version,
           		 	              p_init_msg_list         => OKC_API.G_FALSE,
           			              x_return_status         => l_return_status,
           			              x_msg_count             => l_msg_count,
           			              x_msg_data              => l_msg_data,
                                  p_contract_id 		  => p_contract_id,
                                  x_rep_product_id        => lx_rep_product_id);

         OKL_STREAMS_UTIL.get_dependent_stream_type(p_khr_id            => p_contract_id,
                                               p_product_id            => lx_rep_product_id,
                                               p_primary_sty_purpose   => 'RENT',
                                               p_dependent_sty_purpose => 'LEASE_INCOME',
                                               x_return_status         => l_return_status,
                                               x_dependent_sty_id      => l_stream_type_id);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    ELSE
    -- sechawla 05-dec-07 6671849 -- START
       --PAGARG 31-Dec-2004 Bug# 4097591 Start
       --UDS impact. Obtain stream type id and pass it to cursor
       OKL_STREAMS_UTIL.get_dependent_stream_type(p_khr_id                => p_contract_id,
                                               p_primary_sty_purpose   => 'RENT',
                                               p_dependent_sty_purpose => 'LEASE_INCOME',
                                               x_return_status         => l_return_status,
                                               x_dependent_sty_id      => l_stream_type_id);

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       --PAGARG 31-Dec-2004 Bug# 4097591 End

    END IF; -- sechawla 05-dec-07 6671849 -- added

    IF l_rep_prod_streams_yn = 'Y' THEN
       IF l_trx_date IS NULL THEN
       -- Can not calculate Net Investment for the reporting product as the transaction date is missing.
          Okl_Api.Set_Message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_AM_AMORT_NO_TRX_DATE');
          RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;
    END IF;

 -- 26-Aug-2004 3849355 Guru added the following code to get current accural period end date

       /* -- rmunjulu
      IF l_trx_date IS NULL THEN
            l_term_date := SYSDATE;
       ELSE
           l_term_date := l_trx_date;

       END IF;
       */

    -- rmunjulu
    IF l_quote_eff_date IS NULL THEN
         l_term_date := SYSDATE;
    ELSE
         l_term_date := l_quote_eff_date;
    END IF;

    -- gboomina Bug 5215019 - Start
    -- Based on CHK_ACCRUAL_PREVIOUS_MNTH_YN setup check accruals
    -- till quote eff date OR previous month last date
    OPEN  check_accrual_previous_csr;
    FETCH check_accrual_previous_csr INTO l_accrual_previous_mnth_yn;
    CLOSE check_accrual_previous_csr;

    IF nvl(l_accrual_previous_mnth_yn,'N') = 'N' THEN
      l_accrual_adjst_date :=   l_term_date;
    ELSE
      l_accrual_adjst_date :=   LAST_DAY(TRUNC(l_term_date, 'MONTH')-1);
    END IF;

    okl_accounting_util.get_period_info(l_accrual_adjst_date,l_period_name, l_start_date,l_end_date);
    -- gboomina Bug 5215019 - End

    --check if streams required for reporting  product
    IF l_rep_prod_streams_yn = 'Y' THEN
       OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS; --MGAAP 7263041
       --PAGARG 31-Dec-2004 Bug# 4097591, Pass stream type id to cursor
       --OPEN  line_reporting_csr(p_contract_line_id, l_end_date, l_stream_type_id);   -- now passing l_end_date 26-Aug-2004 3849355
       OPEN  line_csr(p_contract_line_id, l_end_date, l_stream_type_id);   -- now passing l_end_date 26-Aug-2004 3849355
       FETCH line_csr INTO l_unearned_income;
	   CLOSE line_csr;
       OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
    ELSE
       OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;
        -- Start : Bug 6030917 : prasjain
        --added for prorating incase of partial unit termination

        IF nvl(l_proration_factor,1) = 1 THEN
       --PAGARG 31-Dec-2004 Bug# 4097591, Pass stream type id to cursor
	   OPEN  line_csr(p_contract_line_id,l_end_date, l_stream_type_id);   -- now passing l_end_date 26-Aug-2004 3849355
	   FETCH line_csr INTO l_unearned_income;
	   CLOSE line_csr;
       ELSE
          --get curerncy code for the line
          OPEN  currency_code_csr(p_contract_line_id);
          FETCH currency_code_csr INTO l_currency_code ;
          CLOSE currency_code_csr;
          --initializing l_parent_strm_rounded_tot_amt variable with 0
          l_parent_strm_rounded_tot_amt := 0;

          FOR stream_element_rec IN stream_element_csr(p_contract_line_id, l_end_date, l_stream_type_id)
          LOOP
             --prorate the amount, to derive the parent stream amount
              l_parent_strm_amt := stream_element_rec.amount * l_proration_factor;
             --round amount with streams option for paren stream element amounts
             okl_accounting_util.round_amount(
                         p_api_version    => l_api_version,
                         p_init_msg_list  => l_init_msg_list,
                         x_return_status  => l_return_status,
                         x_msg_count      => l_msg_count,
                         x_msg_data       => l_msg_data,
                         p_amount         => l_parent_strm_amt,
                         p_currency_code  => l_currency_code,
                         p_round_option   => 'STM',
                         x_rounded_amount => l_parent_strm_rounded_amt
                         );
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

            -- calculate the parent stream rounded total
             l_parent_strm_rounded_tot_amt := l_parent_strm_rounded_tot_amt
                                                 + l_parent_strm_rounded_amt;

          END LOOP;
            l_unearned_income := l_parent_strm_rounded_tot_amt;
        END IF;
       -- End : Bug 6030917 : prasjain
      END IF;


	RETURN NVL(l_unearned_income,0);

EXCEPTION

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        IF line_csr%ISOPEN THEN
			CLOSE line_csr;
		END IF;

        IF line_reporting_csr%ISOPEN THEN
            CLOSE line_reporting_csr;
        END IF;

          -- Start : Bug 6030917 : prasjain
          IF currency_code_csr%ISOPEN THEN
              CLOSE currency_code_csr;
          END IF;
          IF stream_element_csr%ISOPEN THEN
              CLOSE stream_element_csr;
          END IF;
          -- End : Bug 6030917 : prasjain

        RETURN NULL;

	WHEN OTHERS THEN

		-- Close open cursors

		IF line_csr%ISOPEN THEN
			CLOSE line_csr;
		END IF;

        IF line_reporting_csr%ISOPEN THEN
            CLOSE line_reporting_csr;
        END IF;

         -- Start : Bug 6030917 : prasjain
          IF currency_code_csr%ISOPEN THEN
              CLOSE currency_code_csr;
          END IF;
          IF stream_element_csr%ISOPEN THEN
              CLOSE stream_element_csr;
          END IF;
          -- End : Bug 6030917 : prasjain

		-- store SQL error message on message stack for caller

		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_CONTRACTS_UNEXPECTED_ERROR',
			p_token1	=> 'SQLCODE',
			p_token1_value	=> SQLCODE,
			p_token2	=> 'SQLERRM',
			p_token2_value	=> SQLERRM);

		RETURN null;

END line_future_income;

  -- Start of Comments
  -- Function Name: Asset_Residual
  -- Description:   Returns the Residual value for an asset
  -- Dependencies:
  -- Parameters:    IN:  p_contract_id, p_contract_line_id ,p_additional_paams(quote_id, kle_id)
  --                OUT: amount
  --                rmunjulu 3816891 created
  -- Version:       1.0
  -- End of Commnets
------------------------------------------------------------------------------

  FUNCTION asset_residual(
    p_khr_id IN NUMBER,
    p_kle_id IN NUMBER)
    RETURN NUMBER IS

     Expected_error EXCEPTION;

     -- get the quote type
     CURSOR get_qte_type_csr (p_quote_id IN NUMBER) IS
     SELECT  qte.qtp_code qtp_code
     FROM    okl_trx_quotes_v qte
     WHERE   qte.id = p_quote_id;

     -- get asset niv from quote lines
     CURSOR get_asset_niv_csr (p_kle_id IN NUMBER, p_quote_id IN NUMBER) IS
     SELECT nvl(tql.asset_value,0) residual_value
     FROM   okl_txl_quote_lines_v tql
     WHERE  tql.qte_id = p_quote_id
     AND    tql.qlt_code = 'AMCFIA'
     AND    tql.kle_id  = p_kle_id;

     -- get deprn cost from off-lease trn (SECHAWLA)
     CURSOR get_deprn_cost_csr (p_kle_id IN NUMBER) IS
     SELECT depreciation_cost, ID
     FROM   okl_txl_assets_b
     WHERE  kle_id = p_kle_id
     AND    tal_type = 'AML'
     AND    ROWNUM < 2;

     l_quote_id NUMBER;
     l_asset_residual NUMBER;
     l_quote_type VARCHAR2(300);
     l_residual NUMBER;
     l_corp_book_cost NUMBER;

  BEGIN

    IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
       FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
       LOOP
         IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).name = 'QUOTE_ID' THEN
            l_quote_id := TO_NUMBER(OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).value);
         END IF;
       END LOOP;
    END IF;

    IF l_quote_id IS NULL
	OR l_quote_id = OKL_API.G_MISS_NUM
	OR p_khr_id IS NULL
	OR p_khr_id = OKL_API.G_MISS_NUM
	OR p_kle_id IS NULL
	OR p_kle_id = OKL_API.G_MISS_NUM THEN

      RAISE Expected_error;
    END IF;

    -- get the quote type
    OPEN get_qte_type_csr(l_quote_id);
    FETCH get_qte_type_csr INTO l_quote_type;
    CLOSE get_qte_type_csr;

    IF l_quote_type IN ( 'TER_MAN_PURCHASE',
                         'TER_PURCHASE',
                         'TER_RECOURSE',
                         'TER_ROLL_PURCHASE') THEN

       -- Get the asset NIV from the quoted quote line
       FOR get_asset_niv_rec IN get_asset_niv_csr (p_kle_id,l_quote_id ) LOOP

           l_asset_residual := get_asset_niv_rec.residual_value;
       END LOOP;

    ELSE -- termination without purchase

       -- Get the Off-lease trn value
       FOR get_deprn_cost_rec IN get_deprn_cost_csr (p_kle_id ) LOOP

           l_asset_residual := get_deprn_cost_rec.depreciation_cost;
       END LOOP;
    END IF;

    IF l_asset_residual IS NULL THEN

      l_asset_residual := 0;
    END IF;

    RETURN l_asset_residual;

  EXCEPTION

    WHEN Expected_error THEN

    RETURN 0;
    WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                        p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                        p_token1        => 'OKL_SQLCODE',
                        p_token1_value  => SQLCODE,
                        p_token2        => 'OKL_SQLERRM',
                        p_token2_value  => SQLERRM);
    RETURN NULL;
  END asset_residual;

  -- rfedane 4058562
  FUNCTION principal_balance_fee_line (p_contract_id      IN NUMBER,
                                       p_contract_line_id IN NUMBER) RETURN NUMBER IS

    l_fee_payment_id NUMBER;
    l_quote_eff_date DATE;
    l_date           DATE;
    l_prin_bal_id    NUMBER;
    l_balance        NUMBER;
    l_return_status  VARCHAR2(1);
    l_prog_name      VARCHAR2(61) := 'OKL_SEEDED_FUNCTIONS_PVT.principal_balance_fee_line';

    CURSOR c_balance (p_sty_id NUMBER, p_date DATE) IS
    SELECT
    sel.amount
    FROM
    okl_strm_elements sel,
    okl_streams stm
    WHERE
    stm.sty_id = p_sty_id
    AND   stm.khr_id = p_contract_id
    AND   stm.kle_id = p_contract_line_id
    AND   sel.stream_element_date <= p_date
    AND   stm.say_code = 'CURR'
    AND   stm.id = sel.stm_id
    ORDER BY sel.stream_element_date DESC;

  BEGIN

      IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
        FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST LOOP

        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.EXISTS(i) THEN

          IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'quote_effective_from_date'
             AND  okl_execute_formula_pub.g_additional_parameters(i).value IS NOT NULL THEN
             l_quote_eff_date := okl_execute_formula_pub.g_additional_parameters(i).value;
          END IF;

        END IF;
        END LOOP;
      END IF;

      IF l_quote_eff_date IS NOT NULL THEN
        l_date := l_quote_eff_date;
      ELSE
        l_date := TRUNC(SYSDATE);
      END IF;

      SELECT TO_NUMBER(laslh.object1_id1)
      INTO   l_fee_payment_id
      FROM   okc_rule_groups_b lalevl,
             okc_rules_b laslh
      WHERE  lalevl.cle_id = p_contract_line_id
      AND    lalevl.rgd_code = 'LALEVL'
      AND    lalevl.id = laslh.rgp_id
      AND    laslh.rule_information_category = 'LASLH';

      OKL_STREAMS_UTIL.get_dependent_stream_type(
              p_khr_id                => p_contract_id,
              p_primary_sty_id        => l_fee_payment_id,
              p_dependent_sty_purpose => 'PRINCIPAL_BALANCE',
              x_return_status         => l_return_status,
              x_dependent_sty_id      => l_prin_bal_id);

      OPEN c_balance (p_sty_id => l_prin_bal_id, p_date => l_date);
      FETCH c_balance INTO l_balance;
      CLOSE c_balance;

      RETURN l_balance;

    EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        RAISE;

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        RAISE;

      WHEN OTHERS THEN

        OKL_API.SET_MESSAGE (p_app_name     => 'OKL',
                             p_msg_name     => 'OKL_DB_ERROR',
                             p_token1       => 'PROG_NAME',
                             p_token1_value => l_prog_name,
                             p_token2       => 'SQLCODE',
                             p_token2_value => sqlcode,
                             p_token3       => 'SQLERRM',
                             p_token3_value => sqlerrm);

        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

  END principal_balance_fee_line;


  -- rfedane 4058562
  FUNCTION principal_balance_financed (p_contract_id IN NUMBER,
                                       p_contract_line_id IN NUMBER) RETURN NUMBER IS

    CURSOR c_fin_fees IS
      SELECT cle.id
      FROM
      okc_k_lines_b cle,
      okl_k_lines kle,
      okc_k_headers_b chr
      WHERE
      chr.id = p_contract_id
      AND cle.chr_id = chr.id
      AND cle.sts_code = chr.sts_code
      AND cle.id = kle.id
      AND kle.fee_type = 'FINANCED';

    l_total_balance NUMBER := 0;
    l_prog_name      VARCHAR2(61) := 'OKL_SEEDED_FUNCTIONS_PVT.principal_balance_financed';

  BEGIN

    FOR l_fin_fee IN c_fin_fees LOOP

    l_total_balance  :=  l_total_balance + NVL(principal_balance_fee_line(p_contract_id => p_contract_id, p_contract_line_id => l_fin_fee.id), 0);

    END LOOP;

    RETURN l_total_balance;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_DB_ERROR',
                           p_token1       => 'PROG_NAME',
                           p_token1_value => l_prog_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

  END principal_balance_financed;


  -- rfedane 4058562
  FUNCTION principal_balance_rollover (p_contract_id      IN NUMBER,
                                       p_contract_line_id IN NUMBER) RETURN NUMBER IS

    CURSOR c_fin_fees IS
      SELECT cle.id
      FROM
      okc_k_lines_b cle,
      okl_k_lines kle,
      okc_k_headers_b chr
      WHERE
      chr.id = p_contract_id
      AND cle.chr_id = chr.id
      AND cle.sts_code = chr.sts_code
      AND cle.id = kle.id
      AND kle.fee_type = 'ROLLOVER';

    l_total_balance NUMBER := 0;
    l_prog_name      VARCHAR2(61) := 'OKL_SEEDED_FUNCTIONS_PVT.principal_balance_rollover';

  BEGIN

    FOR l_fin_fee IN c_fin_fees LOOP

    l_total_balance  :=  l_total_balance + NVL(principal_balance_fee_line(p_contract_id => p_contract_id, p_contract_line_id => l_fin_fee.id), 0);

    END LOOP;

    RETURN l_total_balance;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => 'OKL',
                           p_msg_name     => 'OKL_DB_ERROR',
                           p_token1       => 'PROG_NAME',
                           p_token1_value => l_prog_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

  END principal_balance_rollover;

  -- rmunjulu 4299668 Added -- modified to call line_accumulated_deprn
  FUNCTION asset_net_book_value(
    p_khr_id IN NUMBER,
    p_kle_id IN NUMBER)
    RETURN NUMBER IS

     Expected_error EXCEPTION;

     l_quote_id NUMBER;
     l_nbv NUMBER;

     CURSOR get_quote_date_csr (p_qte_id IN NUMBER) IS
     SELECT qte.date_effective_from
     FROM   okl_trx_quotes_b  qte
	 WHERE  qte.id = p_qte_id;

     l_quote_eff_date DATE;

   CURSOR get_asset_cost_csr (p_kle_id IN NUMBER) IS
   SELECT nvl(fab.cost,0) current_cost
   FROM   fa_books fab,
          fa_book_controls fbc,
          okc_k_items_v itm,
          okc_k_lines_b kle,
          okc_line_styles_v lse
   WHERE  fbc.book_class = 'CORPORATE'
   AND    fab.book_type_code = fbc.book_type_code
   AND    fab.asset_id = itm.object1_id1
   AND    itm.cle_id = kle.id
   AND    kle.cle_id = p_kle_id
   AND    kle.lse_id = lse.id
   AND    lse.lty_code = 'FIXED_ASSET'
   AND    fab.transaction_header_id_out IS NULL;

   l_asset_deprn NUMBER;
   l_current_cost NUMBER;
   l_asset_net_book_value NUMBER;

  BEGIN

    IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
       FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
       LOOP
         IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).name = 'QUOTE_ID' THEN
            l_quote_id := TO_NUMBER(OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).value);
         END IF;
       END LOOP;
    END IF;

    IF p_khr_id IS NULL
	OR p_khr_id = OKL_API.G_MISS_NUM
	OR p_kle_id IS NULL
	OR p_kle_id = OKL_API.G_MISS_NUM THEN

      RAISE Expected_error;
    END IF;

    IF l_quote_id IS NOT NULL
    AND l_quote_id <> OKL_API.G_MISS_NUM THEN

      OPEN get_quote_date_csr (l_quote_id);
      FETCH get_quote_date_csr INTO l_quote_eff_date;
      CLOSE get_quote_date_csr;

    ELSE

      l_quote_eff_date := sysdate;

    END IF;

    l_asset_deprn := line_accumulated_deprn(
      						p_contract_id       => p_khr_id,
      						p_contract_line_id  => p_kle_id);


    --OPEN get_asset_cost_csr (p_kle_id); -- rmunjulu modified
    --FETCH get_asset_cost_csr INTO l_current_cost;
    --CLOSE get_asset_cost_csr;

    -- Update to mainline only -- gets converted current cost amount
    l_current_cost := line_asset_cost(
      						p_contract_id       => p_khr_id,
      						p_contract_line_id  => p_kle_id);

    l_asset_net_book_value :=  l_current_cost - l_asset_deprn;

    RETURN l_asset_net_book_value;

  EXCEPTION

    WHEN Expected_error THEN

    IF get_quote_date_csr%ISOPEN THEN
      CLOSE get_quote_date_csr;
    END IF;
    IF get_asset_cost_csr%ISOPEN THEN
      CLOSE get_asset_cost_csr;
    END IF;
    RETURN Null;
    WHEN OTHERS THEN
    IF get_quote_date_csr%ISOPEN THEN
      CLOSE get_quote_date_csr;
    END IF;
    IF get_asset_cost_csr%ISOPEN THEN
      CLOSE get_asset_cost_csr;
    END IF;
    -- store SQL error message on message stack for caller
    Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                        p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                        p_token1        => 'OKL_SQLCODE',
                        p_token1_value  => SQLCODE,
                        p_token2        => 'OKL_SQLERRM',
                        p_token2_value  => SQLERRM);
    RETURN NULL;
  END asset_net_book_value;
 -- varangan Added for Bug#5036582 start
  ----------------------------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:      Vaijayanthi Ranganathan (varangan)
    -- Function Name:   Contract Unpaid Invoices
    -- Description:     Returns the sum of all unpaid invoices for leases/loans,
    --                  including taxes, with due date prior to current system date
    -- Dependencies:
    -- Parameters: contract id,contract line id
    -- Version: 1.0
    -- End of Commnets
  ----------------------------------------------------------------------------------------------------

  FUNCTION contract_unpaid_invoices(
    p_contract_id IN NUMBER,
    p_contract_line_id IN NUMBER)
    RETURN NUMBER IS
    --dkagrawa changed the follwong cursor for billing impact
    --changed query for Bug#6826370
    CURSOR cr_unpaid_invoices(c_contract_id IN NUMBER) IS
    SELECT nvl(sum(amount_remaining),0)
    FROM   okl_cs_bpd_inv_dtl_v
    WHERE  chr_id = c_contract_id
    AND    due_date <= SYSDATE;

    l_unpaid_invoices NUMBER;

  BEGIN
    OPEN cr_unpaid_invoices (p_contract_id);
    FETCH cr_unpaid_invoices INTO l_unpaid_invoices;
    CLOSE cr_unpaid_invoices;

    RETURN l_unpaid_invoices;
  EXCEPTION
    WHEN OTHERS THEN
    IF cr_unpaid_invoices%ISOPEN THEN
      CLOSE cr_unpaid_invoices;
    END IF;
    -- store SQL error message on message stack for caller
    Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                        p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                        p_token1        => 'OKL_SQLCODE',
                        p_token1_value  => SQLCODE,
                        p_token2        => 'OKL_SQLERRM',
                        p_token2_value  => SQLERRM);
    RETURN NULL;
  END contract_unpaid_invoices;

  ----------------------------------------------------------------------------------------------------
    -- Start of Comments
    -- Created By:      Vaijayanthi Ranganathan (varangan)
    -- Function Name:   Contract Unbilled Streams amount
    -- Description:     Returns the sum of all Unbilled Streams for leases/loans,
    --                  including taxes, with due date prior to current system date
    -- Dependencies:
    -- Parameters: contract id,contract line id
    -- Version: 1.0
    -- End of Commnets
  ----------------------------------------------------------------------------------------------------
  FUNCTION contract_unbilled_streams(
    p_contract_id IN NUMBER,
    p_contract_line_id IN NUMBER)
    RETURN NUMBER IS

    CURSOR cr_unbilled_streams(c_contract_id IN NUMBER) IS
    SELECT NVL(sum(sel.amount),0)
    FROM   okl_strm_elements sel,
           okl_streams stm,
           okl_strm_type_b sty
    WHERE  stm.say_code = 'CURR'
    AND    stm.active_yn = 'Y'
    AND    stm.purpose_code is NULL
    AND    stm.khr_id = c_contract_id
    AND    sty.id = stm.sty_id
    AND    sty.billable_yn = 'Y'
    AND    sel.stm_id = stm.id
    AND    date_billed is null
    AND    stream_element_date <= SYSDATE;

    l_unbilled_streams NUMBER;

  BEGIN
    OPEN cr_unbilled_streams (p_contract_id);
    FETCH cr_unbilled_streams INTO l_unbilled_streams;
    CLOSE cr_unbilled_streams;

    RETURN l_unbilled_streams;
  EXCEPTION
    WHEN OTHERS THEN
    IF cr_unbilled_streams%ISOPEN THEN
      CLOSE cr_unbilled_streams;
    END IF;
    -- store SQL error message on message stack for caller
    Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                        p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                        p_token1        => 'OKL_SQLCODE',
                        p_token1_value  => SQLCODE,
                        p_token2        => 'OKL_SQLERRM',
                        p_token2_value  => SQLERRM);
    RETURN NULL;
  END contract_unbilled_streams;
  -- varangan Bug#5036582 end


  -- rmunjulu VENDOR_RESIDUAL_SHARE PROJECT
  FUNCTION vendor_residual_share_amount(
    p_khr_id IN NUMBER,
    p_kle_id IN NUMBER)
    RETURN NUMBER IS

    CURSOR get_asset_residual_csr (p_kle_id IN NUMBER) IS
    SELECT nvl(KLE.residual_value,0) residual_value
    FROM   OKL_K_LINES KLE
    WHERE  KLE.id = p_kle_id;

    CURSOR get_asset_sales_proceeds_csr (p_retirement_id IN NUMBER) IS
    SELECT nvl(RET.proceeds_of_sale,0) sales_proceeds
    FROM   --OKX_ASSET_LINES_V OAL,
           FA_RETIREMENTS RET
    WHERE  RET.RETIREMENT_ID = p_retirement_id;
    --WHERE  OAL.parent_line_id = p_kle_id
    --AND    OAL.corporate_book IS NOT NULL
    --AND    OAL.asset_id = FAR.asset_id
    --AND    OAL.corporate_book = FAR.book_type_code;

     EXPECTED_ERROR EXCEPTION;

     l_sales_proceeds NUMBER;
     l_share_percent NUMBER;
     l_residual_value NUMBER;
     l_share_amount NUMBER;
     l_currency_code VARCHAR2(15);
     l_contract_currency_code VARCHAR2(15);
     l_currency_conversion_type VARCHAR2(30);
     l_currency_conversion_rate NUMBER;
     l_currency_conversion_date DATE;
     l_converted_sales_proceeds NUMBER;
     l_return_status VARCHAR2(3);
     l_retirement_id NUMBER;

  BEGIN

    IF p_khr_id IS NULL
	OR p_khr_id = OKL_API.G_MISS_NUM
	OR p_kle_id IS NULL
	OR p_kle_id = OKL_API.G_MISS_NUM THEN

      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_INVALID_VALUE',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'P_KHR_ID OR P_KLE_ID');

      RAISE EXPECTED_ERROR;
    END IF;

    IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
       FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
       LOOP
         IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).name = 'retirement_id' THEN
            l_retirement_id := TO_NUMBER(OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).value);
         END IF;
       END LOOP;
    END IF;

    IF l_retirement_id IS NULL
	OR l_retirement_id = OKL_API.G_MISS_NUM THEN

      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_INVALID_VALUE',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'retirement_id');

      RAISE EXPECTED_ERROR;
    END IF;

    l_sales_proceeds := 0;
    l_residual_value := 0;
    l_share_percent  := 0;
    l_share_amount   := 0;

    OPEN  get_asset_residual_csr (p_kle_id);
    FETCH get_asset_residual_csr INTO l_residual_value;
    CLOSE get_asset_residual_csr;

    -- get sales proceeds for the retirement id
    OPEN  get_asset_sales_proceeds_csr (l_retirement_id);
    FETCH get_asset_sales_proceeds_csr INTO l_sales_proceeds;
    CLOSE get_asset_sales_proceeds_csr;

    -- Get the contract currency code
    l_currency_code := OKL_AM_UTIL_PVT.get_chr_currency(p_khr_id);

    -- Convert sales_proceeds from functional_currency to contract_currency
    OKL_ACCOUNTING_UTIL.convert_to_contract_currency(
                     p_khr_id  		  	          => p_khr_id,
                     p_from_currency   		      => l_currency_code,
                     p_transaction_date 		  => sysdate,
                     p_amount 			          => l_sales_proceeds,
                     x_return_status              => l_return_status,
                     x_contract_currency		  => l_contract_currency_code,
                     x_currency_conversion_type	  => l_currency_conversion_type,
                     x_currency_conversion_rate	  => l_currency_conversion_rate,
                     x_currency_conversion_date	  => l_currency_conversion_date,
                     x_converted_amount 		  => l_converted_sales_proceeds);

    IF  l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      RAISE EXPECTED_ERROR;
    END IF;

    l_share_amount := nvl(l_converted_sales_proceeds,0) - nvl(l_residual_value,0);

    RETURN l_share_amount; -- has no share percent included, percent will be applied later

  EXCEPTION

    WHEN EXPECTED_ERROR THEN

    IF get_asset_residual_csr%ISOPEN THEN
      CLOSE get_asset_residual_csr;
    END IF;

    IF get_asset_sales_proceeds_csr%ISOPEN THEN
      CLOSE get_asset_sales_proceeds_csr;
    END IF;

    RETURN NULL;

    WHEN OTHERS THEN

    IF get_asset_residual_csr%ISOPEN THEN
      CLOSE get_asset_residual_csr;
    END IF;

    IF get_asset_sales_proceeds_csr%ISOPEN THEN
      CLOSE get_asset_sales_proceeds_csr;
    END IF;

    -- store SQL error message on message stack for caller
    Okl_Api.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                        p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                        p_token1        => 'OKL_SQLCODE',
                        p_token1_value  => SQLCODE,
                        p_token2        => 'OKL_SQLERRM',
                        p_token2_value  => SQLERRM);
    RETURN NULL;
  END vendor_residual_share_amount;

  -- rmunjulu LOANS_ENHANCEMENTS PROJECT
  FUNCTION loan_asset_prin_bal(
    p_khr_id IN NUMBER,
    p_kle_id IN NUMBER)
    RETURN NUMBER IS

     CURSOR get_quote_date_csr (p_qte_id IN NUMBER) IS
     SELECT qte.date_effective_from
     FROM   okl_trx_quotes_b  qte
	 WHERE  qte.id = p_qte_id;

     EXPECTED_ERROR EXCEPTION;

     l_return_status VARCHAR2(3);
     l_quote_id NUMBER;
     l_quote_eff_from DATE;
     l_prin_bal NUMBER;

  BEGIN

    IF p_khr_id IS NULL
	OR p_khr_id = OKL_API.G_MISS_NUM
	OR p_kle_id IS NULL
	OR p_kle_id = OKL_API.G_MISS_NUM THEN

      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_INVALID_VALUE',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'P_KHR_ID OR P_KLE_ID');

      RAISE EXPECTED_ERROR;
    END IF;

    IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
       FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
       LOOP
         IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).name = 'quote_id' THEN
            l_quote_id := TO_NUMBER(OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).value);
         END IF;
       END LOOP;
    END IF;

    IF l_quote_id IS NULL THEN

      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_INVALID_VALUE',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'quote_id');

      RAISE EXPECTED_ERROR;
    END IF;

    OPEN get_quote_date_csr (l_quote_id);
    FETCH get_quote_date_csr INTO l_quote_eff_from;
    CLOSE get_quote_date_csr;


    -- call util to get actual principal balance
    l_prin_bal := OKL_VARIABLE_INT_UTIL_PVT.get_principal_bal(
        x_return_status  => l_return_status,
        p_khr_id         => p_khr_id,
        p_kle_id         => p_kle_id,
        p_date           => l_quote_eff_from);

    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       RAISE EXPECTED_ERROR;
    END IF;


    RETURN l_prin_bal;

  EXCEPTION

    WHEN EXPECTED_ERROR THEN

    IF get_quote_date_csr%ISOPEN THEN
      CLOSE get_quote_date_csr;
    END IF;

    RETURN NULL;

    WHEN OTHERS THEN

    IF get_quote_date_csr%ISOPEN THEN
      CLOSE get_quote_date_csr;
    END IF;

    -- store SQL error message on message stack for caller
    Okl_Api.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                        p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                        p_token1        => 'OKL_SQLCODE',
                        p_token1_value  => SQLCODE,
                        p_token2        => 'OKL_SQLERRM',
                        p_token2_value  => SQLERRM);
    RETURN NULL;
  END loan_asset_prin_bal;

  -- rmunjulu LOANS_ENHANCEMENTS PROJECT
  --SECHAWLA 30-NOV-05 4753429 : Modified to return perdiem amount for only LOANS/REVOLVING-LOANS
  --SECHAWLA 03-JAN-06 4920149 : Treat interest rate returned by the API OKL_VARIABLE_INT_UTIL_PVT
  --                             as a percentage
  FUNCTION quote_perdiem_amount(
    p_khr_id IN NUMBER,
    p_kle_id IN NUMBER)
    RETURN NUMBER IS



     CURSOR get_tot_outstanding_bal_csr (p_qte_id IN NUMBER) IS
     SELECT sum(TQL.asset_value) outstanding_bal
     FROM   OKL_TXL_QUOTE_LINES_B TQL
     WHERE  TQL.qte_id = p_qte_id
	 AND    TQL.qlt_code = 'AMCFIA';

     CURSOR get_quote_date_csr (p_qte_id IN NUMBER) IS
     SELECT qte.date_effective_from
     FROM   okl_trx_quotes_b  qte
	 WHERE  qte.id = p_qte_id;

     CURSOR get_base_interest_rate_csr (p_khr_id IN NUMBER) IS
     SELECT base_rate
     FROM   okl_k_rate_params_v
	 WHERE  khr_id = p_khr_id;

	 --SECHAWLA 30-NOV-05 4753429 : New declarations begin
     CURSOR l_dealtype_csr (cp_khr_id IN NUMBER) IS
	 SELECT deal_type
	 FROM   OKL_K_HEADERS
	 WHERE  id = cp_khr_id;

	 l_deal_type		VARCHAR2(30);
	 --SECHAWLA 30-NOV-05 4753429 : New declarations end

     EXPECTED_ERROR EXCEPTION;

     l_outstanding_bal NUMBER;
     l_return_status VARCHAR2(3);
     l_quote_id NUMBER;
     l_quote_eff_from DATE;
     l_interest_rate NUMBER;
     l_quote_perdiem NUMBER;

	 IsLeapYear BOOLEAN;
     iYear NUMBER;

     l_days_in_year NUMBER;
     --gboomina Bug#4703521 27-Oct-05 start
     lx_days_in_month OKL_K_RATE_PARAMS.days_in_a_month_code%type; --gboomina Bug#4703521 27-Oct-05 - changed VARCHAR2(5) to OKL_K_RATE_PARAMS.days_in_a_month_code%type
     lx_days_in_year OKL_K_RATE_PARAMS.days_in_a_month_code%type; --gboomina Bug#4703521 27-Oct-05 - changed  VARCHAR2(5) to OKL_K_RATE_PARAMS.days_in_a_month_code%type
     --gboomina Bug#4703521 27-Oct-05 end
     lx_return_status VARCHAR2(3);



  BEGIN

    --SECHAWLA 30-NOV-05 4753429 : begin

    l_quote_perdiem := 0;

    OPEN  l_dealtype_csr(p_khr_id);
    FETCH l_dealtype_csr INTO l_deal_type;
    CLOSE l_dealtype_csr;

    IF l_deal_type LIKE 'LOAN%' THEN
       --SECHAWLA 30-NOV-05 4753429 : end

    	l_outstanding_bal := 0;



    	IF Okl_Execute_Formula_Pub.g_additional_parameters.COUNT > 0 THEN
       	FOR i IN Okl_Execute_Formula_Pub.g_additional_parameters.FIRST..Okl_Execute_Formula_Pub.g_additional_parameters.LAST
       		LOOP
         		IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).name = 'QUOTE_ID' THEN
            		l_quote_id := TO_NUMBER(OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(i).value);
         		END IF;
       		END LOOP;
    	END IF;

    	IF l_quote_id IS NULL THEN

      		OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_INVALID_VALUE',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'QUOTE_ID');

      		RAISE EXPECTED_ERROR;
    	END IF;

    	OPEN  get_tot_outstanding_bal_csr (l_quote_id);
    	FETCH get_tot_outstanding_bal_csr INTO l_outstanding_bal;
    	CLOSE get_tot_outstanding_bal_csr;

    	OPEN get_quote_date_csr (l_quote_id);
    	FETCH get_quote_date_csr INTO l_quote_eff_from;
    	CLOSE get_quote_date_csr;

    	-- get effective interest rate
    	l_interest_rate := OKL_VARIABLE_INT_UTIL_PVT.get_effective_int_rate(
                             x_return_status  => l_return_status,
                             p_khr_id         => p_khr_id,
                             p_effective_date => l_quote_eff_from);

    	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      		RAISE EXPECTED_ERROR;
    	END IF;

		-- use utility for getting the days (from SGT or Contract)
    	OKL_PRICING_UTILS_PVT.get_day_convention(
               p_id              => p_khr_id,   -- ID of the contract/quote
               p_source          => 'ESG', -- 'ESG'/'ISG' are acceptable values
               x_days_in_month   => lx_days_in_month,
               x_days_in_year    => lx_days_in_year,
               x_return_status   => lx_return_status);

    	IF lx_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	   		RAISE EXPECTED_ERROR;
		END IF;

    	IF lx_days_in_year = 'ACTUAL' THEN

      		-- get year of termination
      		iYear := to_number(substr(to_char(trunc(l_quote_eff_from),'YYYY/DD/MON'),1,4));

	  		-- check if leap year
      		If (iYear Mod 4 = 0) And
      		((iYear Mod 100 <> 0) Or (iYear Mod 400 = 0)) Then
         		IsLeapYear := True;
      		Else
         		IsLeapYear := False;
      		End If;

      		IF IsLeapYear THEN
         		l_days_in_year := 366;
     		ELSE
         		l_days_in_year := 365;
      		END IF;

    	ELSE
	   		l_days_in_year := to_number(lx_days_in_year);
		END IF;

		IF l_days_in_year IS NULL OR l_days_in_year = 0 THEN
	  		l_days_in_year := 365;
		END IF;

    	--l_quote_perdiem := nvl(l_outstanding_bal,0) * nvl(l_interest_rate,0) /l_days_in_year;
    	-- SECHAWLA 03-JAN-06 4920149 l_interest_rate is a percentage
    	l_quote_perdiem := nvl(l_outstanding_bal,0) * nvl((l_interest_rate/100),0) /l_days_in_year;
    END IF; --SECHAWLA 30-NOV-05 4753429

    RETURN l_quote_perdiem;

  EXCEPTION

    WHEN EXPECTED_ERROR THEN

    IF get_tot_outstanding_bal_csr%ISOPEN THEN
      CLOSE get_tot_outstanding_bal_csr;
    END IF;

    IF get_quote_date_csr%ISOPEN THEN
      CLOSE get_quote_date_csr;
    END IF;

    --SECHAWLA 30-NOV-05 4753429 : Added
    IF l_dealtype_csr%ISOPEN THEN
      CLOSE l_dealtype_csr;
    END IF;

    RETURN NULL;

    WHEN OTHERS THEN

    IF get_tot_outstanding_bal_csr%ISOPEN THEN
      CLOSE get_tot_outstanding_bal_csr;
    END IF;

    IF get_quote_date_csr%ISOPEN THEN
      CLOSE get_quote_date_csr;
    END IF;

    --SECHAWLA 30-NOV-05 4753429 : Added
    IF l_dealtype_csr%ISOPEN THEN
      CLOSE l_dealtype_csr;
    END IF;

    -- store SQL error message on message stack for caller
    Okl_Api.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                        p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                        p_token1        => 'OKL_SQLCODE',
                        p_token1_value  => SQLCODE,
                        p_token2        => 'OKL_SQLERRM',
                        p_token2_value  => SQLERRM);
    RETURN NULL;
  END quote_perdiem_amount;

  -- sjalasut, Rebook Change Control Enhancement START

  -- function that returns the sum of unbilled RENT for all active assets on the rebook copy of the contract
  FUNCTION cont_rbk_unbilled_receivables(p_contract_id okc_k_headers_b.id%TYPE
                                        ,p_contract_line_id okc_k_lines_b.id%TYPE DEFAULT OKL_API.G_MISS_NUM) RETURN NUMBER IS

    -- get all unbilled receivables for all ACTIVE assets
    CURSOR cle_rents_csr(cp_contract_id okc_k_headers_b.id%TYPE) IS
    SELECT NVL(SUM(sele.amount),0)
      FROM okl_strm_elements sele
          ,okl_streams str
          ,okl_strm_type_v sty
          ,okc_k_lines_v line
          ,okc_statuses_b sts
          ,okc_line_styles_b style
     WHERE sele.stm_id = str.id
       AND str.sty_id = sty.id
       AND sty.stream_type_purpose = 'RENT'
       AND str.say_code = 'CURR'
       AND str.active_yn = 'Y'
       AND str.purpose_code IS NULL
       AND sele.date_billed IS NULL
       AND line.chr_id = str.khr_id
       AND line.id = str.kle_id
       AND line.lse_id = style.id
       AND style.lty_code = 'FREE_FORM1'
       AND line.sts_code = sts.code
       AND sts.ste_code = 'ACTIVE'
       AND str.khr_id = cp_contract_id;
    lv_rent_assets NUMBER;

    lv_unbilled_recv NUMBER;
  BEGIN
    IF(p_contract_id IS NOT NULL AND p_contract_id <> OKL_API.G_MISS_NUM)THEN
      -- initialize
      lv_unbilled_recv := 0;
      lv_rent_assets := 0;

       -- ASSET level RENTS
       OPEN cle_rents_csr(cp_contract_id => p_contract_id); FETCH cle_rents_csr INTO lv_rent_assets;
       CLOSE cle_rents_csr;

       lv_unbilled_recv := lv_rent_assets;
    END IF;
    RETURN lv_unbilled_recv;
  EXCEPTION
 	WHEN OTHERS THEN
    IF(cle_rents_csr%ISOPEN)THEN
      CLOSE cle_rents_csr;
    END IF;
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_UNEXPECTED_ERROR
                       ,p_token1       => G_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);
    RETURN NULL;
  END cont_rbk_unbilled_receivables;

  -- function that returns the sum of pre-tax income that was not accrued for all active assets on the rebook copy of the contract
  FUNCTION cont_rbk_unearned_income(p_contract_id okc_k_headers_b.id%TYPE
                                   ,p_contract_line_id okc_k_lines_b.id%TYPE DEFAULT OKL_API.G_MISS_NUM) RETURN NUMBER IS

    CURSOR c_pre_tax_csr(cp_contract_id okc_k_headers_b.id%TYPE) IS
    SELECT NVL(SUM(sele.amount),0)
      FROM okl_strm_elements sele
          --,okl_streams str  MGAAP 7263041
          ,okl_streams_rep_v str
          ,okl_strm_type_v sty
          ,okc_k_lines_b line
          ,okc_line_styles_b style
          ,okc_statuses_b sts
     WHERE sele.stm_id = str.id
       AND str.sty_id = sty.id
       AND UPPER(sty.stream_type_purpose) = 'LEASE_INCOME'     -- pre-tax income has steam type purpose as lease_income
       AND str.say_code = 'CURR'
       AND STR.ACTIVE_YN = 'Y'
       AND (STR.PURPOSE_CODE IS NULL OR STR.PURPOSE_CODE='REPORT')
       AND nvl(sele.accrued_yn,'N') = 'N'
       AND str.kle_id = line.id
       AND line.lse_id = style.id
       AND style.lty_code = 'FREE_FORM1'
       AND line.sts_code = sts.code
       AND sts.ste_code = 'ACTIVE'
       AND line.chr_id = cp_contract_id;
    lv_pre_tax_income NUMBER;
  BEGIN
    IF(p_contract_id IS NOT NULL AND p_contract_id <> OKL_API.G_MISS_NUM)THEN
      lv_pre_tax_income := 0;
      OPEN c_pre_tax_csr(cp_contract_id => p_contract_id); FETCH c_pre_tax_csr INTO lv_pre_tax_income;
      CLOSE c_pre_tax_csr;
    END IF;
    RETURN lv_pre_tax_income;
  EXCEPTION
 	WHEN OTHERS THEN
    IF(c_pre_tax_csr%ISOPEN)THEN
      CLOSE c_pre_tax_csr;
    END IF;
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_UNEXPECTED_ERROR
                       ,p_token1       => G_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);
    RETURN NULL;
  END cont_rbk_unearned_income;

  -- returns sum of rent not billed for all terminated assets
  -- do not send p_contract_line_id as okl_api.g_miss_num
  FUNCTION cont_tmt_unbilled_receivables(p_contract_id okc_k_headers_b.id%TYPE
                                        ,p_contract_line_id okc_k_lines_b.id%TYPE DEFAULT OKL_API.G_MISS_NUM) RETURN NUMBER IS
    -- get all unbilled receivables for all TERMINATED assets
    CURSOR cle_rents_csr(cp_contract_id okc_k_headers_b.id%TYPE
                        ,cp_contract_line_id okc_k_lines_b.id%TYPE) IS
    SELECT NVL(SUM(sele.amount),0)
      FROM okl_strm_elements sele
          ,okl_streams str
          ,okl_strm_type_v sty
          ,okc_k_lines_v line
          -- ,okc_statuses_b sts
          ,okc_line_styles_b style
     WHERE sele.stm_id = str.id
       AND str.sty_id = sty.id
       AND sty.stream_type_purpose = 'RENT'
       AND str.say_code = 'CURR'
       AND str.active_yn = 'Y'
       AND str.purpose_code IS NULL
       AND sele.date_billed IS NULL
       AND line.chr_id = str.khr_id
       AND line.id = str.kle_id
       AND line.lse_id = style.id
       AND style.lty_code = 'FREE_FORM1'
       -- AND line.sts_code = sts.code
       -- AND sts.ste_code = 'TERMINATED'
       AND str.khr_id = cp_contract_id
       AND line.id = NVL(cp_contract_line_id, line.id);
    lv_rent_assets NUMBER;

    lv_unbilled_recv NUMBER;
  BEGIN
    IF(p_contract_id IS NOT NULL AND p_contract_id <> OKL_API.G_MISS_NUM)THEN
      -- initialize
      lv_unbilled_recv := 0;
      lv_rent_assets := 0;

       -- ASSET level RENTS
       OPEN cle_rents_csr(cp_contract_id => p_contract_id, cp_contract_line_id => p_contract_line_id); FETCH cle_rents_csr INTO lv_rent_assets;
       CLOSE cle_rents_csr;

       lv_unbilled_recv := lv_rent_assets;
    END IF;
    RETURN lv_unbilled_recv;
  EXCEPTION
 	WHEN OTHERS THEN
    IF(cle_rents_csr%ISOPEN)THEN
      CLOSE cle_rents_csr;
    END IF;
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_UNEXPECTED_ERROR
                       ,p_token1       => G_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);
    RETURN NULL;
  END cont_tmt_unbilled_receivables;

  -- returns sum of  pre tax income not accrued for all terminated assets
  -- do not send p_contract_line_id as okl_api.g_miss_num
  FUNCTION cont_tmt_unearned_income(p_contract_id okc_k_headers_b.id%TYPE
                                   ,p_contract_line_id okc_k_lines_b.id%TYPE DEFAULT OKL_API.G_MISS_NUM) RETURN NUMBER IS
    CURSOR c_pre_tax_csr(cp_contract_id okc_k_headers_b.id%TYPE ,cp_contract_line_id okc_k_lines_b.id%TYPE) IS
    SELECT NVL(SUM(sele.amount),0)
      FROM okl_strm_elements sele
          --,okl_streams str  MGAAP 7263041
          ,okl_streams_rep_v str
          ,okl_strm_type_v sty
          ,okc_k_lines_b line
          ,okc_line_styles_b style
          -- ,okc_statuses_b sts
     WHERE sele.stm_id = str.id
       AND str.sty_id = sty.id
       AND UPPER(sty.stream_type_purpose) = 'LEASE_INCOME'     -- pre-tax income has steam type purpose as lease_income
       AND str.say_code = 'CURR'
       AND STR.ACTIVE_YN = 'Y'
       AND (STR.PURPOSE_CODE IS NULL OR STR.PURPOSE_CODE='REPORT')
       AND nvl(sele.accrued_yn,'N') = 'N'
       AND str.kle_id = line.id
       AND line.lse_id = style.id
       AND style.lty_code = 'FREE_FORM1'
       -- AND line.sts_code = sts.code
       -- AND sts.ste_code = 'TERMINATED'
       AND line.chr_id = cp_contract_id
       AND line.id = NVL(cp_contract_line_id, line.id);
    lv_pre_tax_income NUMBER;
  BEGIN
    IF(p_contract_id IS NOT NULL AND p_contract_id <> OKL_API.G_MISS_NUM)THEN
      lv_pre_tax_income := 0;
      OPEN c_pre_tax_csr(cp_contract_id => p_contract_id, cp_contract_line_id => p_contract_line_id); FETCH c_pre_tax_csr INTO lv_pre_tax_income;
      CLOSE c_pre_tax_csr;
    END IF;
    RETURN lv_pre_tax_income;
  EXCEPTION
 	WHEN OTHERS THEN
    IF(c_pre_tax_csr%ISOPEN)THEN
      CLOSE c_pre_tax_csr;
    END IF;
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_UNEXPECTED_ERROR
                       ,p_token1       => G_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);
    RETURN NULL;
  END cont_tmt_unearned_income;

  -- sjalasut, Rebook Change Control Enhancement END

-- Begin - varangan-Bug#5009351
 ----------------------------------------------------------------------------------------------------
   -- Start of Comments
   -- Created By:      Vaijayanthi (varangan)
   -- Function Name:   contract_next_payment_amount
   -- Description:    Returns the sum of all billable stream elements,
   --                 excluding taxes, which fall on the next payment date
   -- Dependencies:
   -- Parameters: contract id,contract line id
   -- Version: 1.0
   -- End of Commnets
 ----------------------------------------------------------------------------------------------------
 FUNCTION contract_next_payment_amount(
   p_contract_id IN NUMBER,
   p_contract_line_id IN NUMBER)
   RETURN NUMBER IS

   CURSOR cr_next_payment_date(c_contract_id IN NUMBER) IS
   SELECT MIN(sel.stream_element_date)
   FROM   okl_strm_elements sel,
          okl_streams stm,
          okl_strm_type_v sty
   WHERE  stm.sty_id = sty.id
   AND    stm.say_code = 'CURR'
   AND    stm.active_yn = 'Y'
   AND    sty.billable_yn = 'Y'
   AND    sty.code NOT LIKE '%TAX%'
   AND    stm.purpose_code is NULL
   AND    stm.khr_id = c_contract_id
   AND    sel.stm_id = stm.id
   AND    sel.stream_element_date > sysdate;

   CURSOR cr_next_payment_amt(c_contract_id IN NUMBER,
                              c_next_due_date IN DATE) IS
   SELECT NVL(sum(sel.amount),0)
   FROM okl_strm_elements sel,
            okl_streams stm,
            okl_strm_type_v sty
   WHERE stm.sty_id = sty.id
   AND stm.say_code = 'CURR'
   AND stm.active_yn = 'Y'
   AND sty.billable_yn = 'Y'
   AND sty.code NOT LIKE '%TAX%'
   AND stm.purpose_code is NULL
   AND stm.khr_id = c_contract_id
   AND sel.stm_id = stm.id
   AND sel.stream_element_date = c_next_due_date;

   l_next_payment_date    DATE;
   l_next_payment_amt     NUMBER;
 BEGIN
   OPEN cr_next_payment_date(p_contract_id);
   FETCH cr_next_payment_date INTO l_next_payment_date;
   CLOSE cr_next_payment_date;

   OPEN cr_next_payment_amt(p_contract_id,l_next_payment_date);
   FETCH cr_next_payment_amt INTO l_next_payment_amt;
   CLOSE cr_next_payment_amt;
   RETURN l_next_payment_amt;

 EXCEPTION
   WHEN OTHERS THEN
     IF cr_next_payment_date%ISOPEN THEN
       CLOSE cr_next_payment_date;
     END IF;
     IF cr_next_payment_amt%ISOPEN THEN
       CLOSE cr_next_payment_amt;
     END IF;
     -- store SQL error message on message stack for caller
     Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                         p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                         p_token1        => 'OKL_SQLCODE',
                         p_token1_value  => SQLCODE,
                         p_token2        => 'OKL_SQLERRM',
                         p_token2_value  => SQLERRM);
     RETURN NULL;
 END contract_next_payment_amount;
 -- End - varangan-Bug#5009351

  -- Added by rravikir -- Bug 5055835

  -- ############################################################
  -- FUNCTION get_leaseapp_id
  -- This function fetches the Lease Application Info
  -- associated to the Contract
  -- ############################################################
  FUNCTION get_leaseapp_id(p_contract_id IN NUMBER)
    RETURN NUMBER IS

    CURSOR c_get_lease_app IS
    SELECT orig_system_id1
    FROM okc_k_headers_b
    WHERE id = p_contract_id
    AND orig_system_source_code = 'OKL_LEASE_APP';

    ln_lease_app_id	NUMBER;
  BEGIN
    OPEN c_get_lease_app;
    FETCH c_get_lease_app INTO ln_lease_app_id;
    CLOSE c_get_lease_app;

    RETURN ln_lease_app_id;
  EXCEPTION
   WHEN OTHERS THEN
     IF c_get_lease_app%ISOPEN THEN
       CLOSE c_get_lease_app;
     END IF;
     RETURN NULL;
  END get_leaseapp_id;

  -- ######################################################################
  -- FUNCTION check_contract_fin_amount
  -- This function checks for total financed amount on contract is
  -- equal to or less than the total amount approved on a Lease Application
  -- ######################################################################
  FUNCTION check_contract_fin_amount(p_contract_id IN NUMBER,
  									 p_contract_line_id IN NUMBER DEFAULT OKL_API.G_MISS_NUM)
    RETURN VARCHAR2 IS

    ln_contract_financed_amount	NUMBER;
    ln_leaseapp_financed_amount NUMBER;
    ln_lease_app_id	NUMBER;
    ln_quote_id		NUMBER;

    CURSOR c_get_primary_quote(p_leaseapp_id IN NUMBER) IS
    SELECT id
    FROM okl_lease_quotes_b
    WHERE parent_object_id = p_leaseapp_id
    AND parent_object_code = 'LEASEAPP'
    AND primary_quote = 'Y';

  BEGIN
    ln_contract_financed_amount := contract_financed_amount(p_contract_id  =>  p_contract_id,
														    p_contract_line_id  => null);

    -- Get Lease Application Info
    ln_lease_app_id := get_leaseapp_id(p_contract_id	=>	p_contract_id);

    IF (ln_lease_app_id IS NOT NULL) THEN
      OPEN c_get_primary_quote(p_leaseapp_id  =>  ln_lease_app_id);
      FETCH c_get_primary_quote INTO ln_quote_id;
      CLOSE c_get_primary_quote;
    END IF;

    IF (ln_quote_id IS NOT NULL) THEN
      ln_leaseapp_financed_amount := okl_lease_app_pvt.get_financed_amount(p_lease_qte_id  => ln_quote_id);
    END IF;

    IF (ln_contract_financed_amount IS NOT NULL AND ln_leaseapp_financed_amount IS NOT NULL) THEN
      IF ln_contract_financed_amount <= ln_leaseapp_financed_amount THEN
        RETURN 'P';
      ELSE
	    RETURN 'F';
      END IF;
	ELSE
	  RETURN NULL;
    END IF;

  EXCEPTION
   WHEN OTHERS THEN
     IF c_get_primary_quote%ISOPEN THEN
       CLOSE c_get_primary_quote;
     END IF;
     RETURN NULL;
  END  check_contract_fin_amount;

  -- ######################################################################
  -- FUNCTION check_fund_amount
  -- This function checks for total amount funded on a contract is
  -- equal to or less than the total amount approved on a Lease Application
  -- ######################################################################
  FUNCTION check_fund_amount(p_contract_id IN NUMBER,
  							 p_contract_line_id IN NUMBER DEFAULT OKL_API.G_MISS_NUM)
    RETURN VARCHAR2 IS

    ln_contract_funded_amount	NUMBER;
    ln_leaseapp_financed_amount NUMBER;
    ln_lease_app_id				NUMBER;
    ln_quote_id					NUMBER;
    ln_fund_amount				NUMBER	:= 0;

    CURSOR c_get_primary_quote(p_leaseapp_id IN NUMBER) IS
    SELECT id
    FROM okl_lease_quotes_b
    WHERE parent_object_id = p_leaseapp_id
    AND parent_object_code = 'LEASEAPP'
    AND primary_quote = 'Y';

    CURSOR c_get_fund_amount(p_contract_line_id IN NUMBER) IS
    SELECT nvl(amount, 0)
    FROM okl_trx_ap_invoices_b
    WHERE id = p_contract_line_id;
    --AND trx_status_code = 'ENTERED'
    --AND FUNDING_TYPE_CODE IN ('PREFUNDING', 'ASSET', 'EXPENSE');

  BEGIN
    ln_contract_funded_amount := okl_funding_pvt.get_total_funded(p_contract_id  => p_contract_id);

    IF (p_contract_line_id IS NOT NULL AND p_contract_line_id <> OKL_API.G_MISS_NUM) THEN
      OPEN c_get_fund_amount(p_contract_line_id	=> p_contract_line_id);
      FETCH c_get_fund_amount INTO ln_fund_amount;
      CLOSE c_get_fund_amount;
    END IF;

    ln_contract_funded_amount := ln_contract_funded_amount + ln_fund_amount;

	-- Get Lease Application Info
    ln_lease_app_id := get_leaseapp_id(p_contract_id	=>	p_contract_id);

    IF (ln_lease_app_id IS NOT NULL) THEN
      OPEN c_get_primary_quote(p_leaseapp_id   =>  ln_lease_app_id);
      FETCH c_get_primary_quote INTO ln_quote_id;
      CLOSE c_get_primary_quote;
    END IF;

    IF (ln_quote_id IS NOT NULL) THEN
      ln_leaseapp_financed_amount := okl_lease_app_pvt.get_financed_amount(p_lease_qte_id  => ln_quote_id);
    END IF;

    IF (ln_contract_funded_amount IS NOT NULL AND ln_leaseapp_financed_amount IS NOT NULL) THEN
      IF ln_contract_funded_amount <= ln_leaseapp_financed_amount THEN
        RETURN 'P';
      ELSE
	    RETURN 'F';
      END IF;
	ELSE
	  RETURN NULL;
    END IF;

  EXCEPTION
   WHEN OTHERS THEN
     IF c_get_primary_quote%ISOPEN THEN
       CLOSE c_get_primary_quote;
     END IF;
     RETURN NULL;
  END  check_fund_amount;

  -- ######################################################################
  -- FUNCTION check_party_custacct_match
  -- This function checks for Party and Customer Account on Lease Application
  -- and Contract are same
  -- ######################################################################
  FUNCTION check_party_custacct_match(p_contract_id IN NUMBER,
  									  p_contract_line_id IN NUMBER DEFAULT OKL_API.G_MISS_NUM)
    RETURN VARCHAR2 IS

    ln_lease_app_id			NUMBER;
    ln_k_party_id			NUMBER;
	ln_k_cust_acct_id		NUMBER;
    ln_lap_party_id			NUMBER;
	ln_lap_cust_acct_id		NUMBER;

    CURSOR c_k_get_party_custacct_info IS
	SELECT kp.object1_id1, okc.cust_acct_id
	FROM okc_k_party_roles_b kp, okc_k_headers_b okc
	WHERE kp.dnz_chr_id = p_contract_id
	AND kp.rle_code = 'LESSEE'
	AND kp.dnz_chr_id = okc.id;

    CURSOR c_lap_get_party_custacct_info(p_lease_app_id  IN NUMBER) IS
	SELECT prospect_id, cust_acct_id
	FROM okl_lease_applications_b
	WHERE id = p_lease_app_id;
  BEGIN

    -- Get Lease Application Info
    ln_lease_app_id := get_leaseapp_id(p_contract_id	=>	p_contract_id);

    OPEN c_k_get_party_custacct_info;
    FETCH c_k_get_party_custacct_info INTO ln_k_party_id, ln_k_cust_acct_id;
    CLOSE c_k_get_party_custacct_info;

    OPEN c_lap_get_party_custacct_info(p_lease_app_id  => ln_lease_app_id) ;
    FETCH c_lap_get_party_custacct_info INTO ln_lap_party_id, ln_lap_cust_acct_id;
    CLOSE c_lap_get_party_custacct_info;

    IF (ln_k_party_id = ln_lap_party_id  AND ln_k_cust_acct_id = ln_lap_cust_acct_id) THEN
      RETURN 'P';
    ELSE
      RETURN 'F';
    END IF;

  EXCEPTION
   WHEN OTHERS THEN
     IF c_k_get_party_custacct_info%ISOPEN THEN
       CLOSE c_k_get_party_custacct_info;
     END IF;
     IF c_lap_get_party_custacct_info%ISOPEN THEN
       CLOSE c_lap_get_party_custacct_info;
     END IF;
     RETURN NULL;
  END  check_party_custacct_match;

  -- ######################################################################
  -- FUNCTION check_vendor_prog_match
  -- This function checks for Vendor Program on Lease Application and
  -- Contract are same
  -- ######################################################################
  FUNCTION check_vendor_prog_match(p_contract_id IN NUMBER,
  								   p_contract_line_id IN NUMBER DEFAULT OKL_API.G_MISS_NUM)
    RETURN VARCHAR2 IS

    CURSOR c_k_vendor_prog_info IS
    SELECT khr_id
	FROM okl_k_headers
	WHERE id = p_contract_id;

    CURSOR c_lap_vendor_prog_info(p_lease_app_id  IN NUMBER) IS
    SELECT program_agreement_id
	FROM okl_lease_applications_b
	WHERE id = p_lease_app_id;

	ln_k_prog_id				NUMBER;
	ln_lap_prog_id				NUMBER;
	ln_lease_app_id				NUMBER;
  BEGIN

    -- Get Lease Application Info
    ln_lease_app_id := get_leaseapp_id(p_contract_id	=>	p_contract_id);

    OPEN c_k_vendor_prog_info;
    FETCH c_k_vendor_prog_info INTO ln_k_prog_id;
    CLOSE c_k_vendor_prog_info;

    OPEN c_lap_vendor_prog_info(p_lease_app_id  => ln_lease_app_id);
    FETCH c_lap_vendor_prog_info INTO ln_lap_prog_id;
    CLOSE c_lap_vendor_prog_info;

    IF (ln_k_prog_id IS NULL AND ln_lap_prog_id IS NULL) THEN
      RETURN 'P';
    ELSIF (ln_k_prog_id = ln_lap_prog_id) THEN
      RETURN 'P';
    ELSE
      RETURN 'F';
    END IF;

  EXCEPTION
   WHEN OTHERS THEN
     IF c_k_vendor_prog_info%ISOPEN THEN
       CLOSE c_k_vendor_prog_info;
     END IF;
     IF c_lap_vendor_prog_info%ISOPEN THEN
       CLOSE c_lap_vendor_prog_info;
     END IF;
     RETURN NULL;
  END  check_vendor_prog_match;

  -- ######################################################################
  -- FUNCTION check_booking_date
  -- This function checks for Activation date of contract is within the
  -- effective dates of Lease Application
  -- ######################################################################
  FUNCTION check_booking_date(p_contract_id IN NUMBER,
  							  p_contract_line_id IN NUMBER DEFAULT OKL_API.G_MISS_NUM)
    RETURN VARCHAR2 IS

    CURSOR c_k_booking_date IS
    SELECT date_transaction_occurred
	FROM okl_trx_contracts
	WHERE khr_id = p_contract_id
	AND   representation_type = 'PRIMARY';	 -- MGAAP OTHER 7263041

	ld_k_booking_date	DATE;
	ld_lap_app_exp_date	DATE;
	ln_lease_app_id		NUMBER;
  BEGIN

    -- Get Lease Application Info
    ln_lease_app_id := get_leaseapp_id(p_contract_id	=>	p_contract_id);

    OPEN c_k_booking_date;
    FETCH c_k_booking_date INTO ld_k_booking_date;
    CLOSE c_k_booking_date;

    ld_lap_app_exp_date := okl_lease_app_pvt.get_approval_exp_date(p_lease_app_id	=> ln_lease_app_id);

    IF (ld_k_booking_date IS NULL) THEN
      ld_k_booking_date := SYSDATE;
    END IF;

    IF (ld_lap_app_exp_date IS NOT NULL) THEN
	  IF (ld_k_booking_date <= ld_lap_app_exp_date ) THEN
        RETURN 'P';
      ELSE
        RETURN 'F';
      END IF;
    ELSE
      RETURN 'P';
    END IF;

  EXCEPTION
   WHEN OTHERS THEN
     IF c_k_booking_date%ISOPEN THEN
       CLOSE c_k_booking_date;
     END IF;
     RETURN NULL;
  END  check_booking_date;

  -- ######################################################################
  -- FUNCTION check_funding_date
  -- This function checks for Funding date of Funding request is within the
  -- effective dates of Lease Application
  -- ######################################################################
  FUNCTION check_funding_date(p_contract_id IN NUMBER,
  							  p_contract_line_id IN NUMBER DEFAULT OKL_API.G_MISS_NUM)
    RETURN VARCHAR2 IS

    -- sjalasut, modified the cursor to have p_contract_id mapped to okl_txl_ap_inv_lns_all_b
    -- changes made as part of OKLR12B disbursements project.
    CURSOR c_k_funding_date IS
    SELECT a.date_invoiced
     	FROM okl_trx_ap_invoices_b a
--          ,okl_txl_ap_inv_lns_all_b b --cklee 09/21/07
--	    WHERE a.id = b.tap_id
       where a.khr_id = p_contract_id;

	ld_k_funded_date	DATE;
	ld_lap_app_exp_date	DATE;
	ln_lease_app_id		NUMBER;
  BEGIN
    -- Get Lease Application Info
    ln_lease_app_id := get_leaseapp_id(p_contract_id	=>	p_contract_id);

    OPEN c_k_funding_date;
    FETCH c_k_funding_date INTO ld_k_funded_date;
    CLOSE c_k_funding_date;

    ld_lap_app_exp_date := okl_lease_app_pvt.get_approval_exp_date(p_lease_app_id	=> ln_lease_app_id);

    IF (ld_lap_app_exp_date IS NOT NULL) THEN
	  IF (ld_k_funded_date <= ld_lap_app_exp_date ) THEN
        RETURN 'P';
      ELSE
        RETURN 'F';
      END IF;
    ELSE
      RETURN 'P';
    END IF;

  EXCEPTION
   WHEN OTHERS THEN
     IF c_k_funding_date%ISOPEN THEN
       CLOSE c_k_funding_date;
     END IF;
     RETURN NULL;
  END  check_funding_date;
  -- rravikir End -- Bug 5055835

   -- ######################################################################
   -- FUNCTION asset_accu_deprn_reserve
   -- Returns fixed asset accumulated depreciation reserve for a financial asset
   -- line.
   -- ######################################################################
  FUNCTION asset_accu_deprn_reserve(
                             p_contract_id       IN  NUMBER
                            ,p_contract_line_id  IN NUMBER
                           )
   RETURN NUMBER  IS

     l_api_name          CONSTANT VARCHAR2(30) := 'ASSET_ACCU_DEPRN_RESERVE';
     l_api_version       CONSTANT NUMBER	      := 1;
     x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
     x_msg_count         NUMBER;
     x_msg_data          VARCHAR2(256);

     l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
     l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;

     l_converted_amount         NUMBER;
     l_contract_start_date      DATE;
     l_contract_currency        OKL_K_HEADERS_FULL_V.currency_code%TYPE;
     l_currency_conversion_type OKL_K_HEADERS_FULL_V.currency_conversion_type%TYPE;
     l_currency_conversion_rate OKL_K_HEADERS_FULL_V.currency_conversion_rate%TYPE;
     l_currency_conversion_date OKL_K_HEADERS_FULL_V.currency_conversion_date%TYPE;

     CURSOR l_asset_csr(p_chr_id  IN NUMBER
                       ,p_cle_id  IN NUMBER
                       ,p_book_class  IN VARCHAR2  -- 7626121
                       ,p_book_type_code  IN VARCHAR2) IS
     SELECT fab.asset_id,
            fab.book_type_code
     FROM okc_k_lines_v fin_ast_cle,
          okc_statuses_b stsb,
          fa_additions fad,
          fa_book_controls fbc,
          fa_books fab
     WHERE fin_ast_cle.id = p_cle_id
     AND   fin_ast_cle.dnz_chr_id = p_chr_id
     AND   fin_ast_cle.chr_id = p_chr_id
     AND   fin_ast_cle.sts_code = stsb.code
     AND   stsb.ste_code NOT IN ('HOLD','CANCELLED')
     AND   fad.asset_number = fin_ast_cle.name
     AND   fab.asset_id = fad.asset_id
     AND   fab.book_type_code = fbc.book_type_code
     AND   fab.transaction_header_id_out IS NULL
     --AND   fbc.book_class = 'CORPORATE';
     AND   fbc.book_class = p_book_class
     AND   fab.book_type_code = NVL(p_book_type_code,fab.book_type_code);


     l_asset_rec  l_asset_csr%ROWTYPE;


     CURSOR contract_start_date_csr(p_chr_id NUMBER) IS
     SELECT start_date
     FROM okc_k_headers_b
     WHERE id = p_chr_id;

    l_streams_repo_policy VARCHAR2(80); -- 7626121
    l_book_class FA_BOOK_CONTROLS.BOOK_CLASS%TYPE := null;
    l_book_type_code FA_BOOK_CONTROLS.BOOK_TYPE_CODE%TYPE := null;


   BEGIN

       IF (( p_contract_id IS NULL ) OR ( p_contract_line_id IS NULL )) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

      -- 7626121
      l_streams_repo_policy := OKL_STREAMS_SEC_PVT.GET_STREAMS_POLICY;
      l_book_type_code := NULL;
      IF (l_streams_repo_policy = 'PRIMARY') THEN
        l_book_class := 'CORPORATE';
      ELSE
        l_book_class := 'TAX';
        l_book_type_code := OKL_ACCOUNTING_UTIL.get_fa_reporting_book(
                              p_kle_id => p_contract_line_id);
      END IF;

       OPEN  l_asset_csr(p_chr_id => p_contract_id,
                         p_cle_id => p_contract_line_id,
                         p_book_class => l_book_class, -- 7626121
                         p_book_type_code => l_book_type_code);
        FETCH l_asset_csr INTO l_asset_rec;
        IF( l_asset_csr%NOTFOUND ) THEN

              CLOSE l_asset_csr;
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
           END IF;
           CLOSE l_asset_csr;

       l_asset_hdr_rec.asset_id          := l_asset_rec.asset_id;
       l_asset_hdr_rec.book_type_code    := l_asset_rec.book_type_code;

       IF NOT fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code) THEN
         OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LLA_FA_CACHE_ERROR'
                            );
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;


       -- To fetch Depreciation Reserve
       IF NOT FA_UTIL_PVT.get_asset_deprn_rec
               (p_asset_hdr_rec         => l_asset_hdr_rec ,
                px_asset_deprn_rec      => l_asset_deprn_rec,
                p_period_counter        => NULL,
                p_mrc_sob_type_code     => 'P'
                ) THEN
         OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LLA_FA_DEPRN_REC_ERROR'
                            );
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;



       -- convert amount into contract currency
       OPEN contract_start_date_csr(p_chr_id => p_contract_id);
       FETCH contract_start_date_csr INTO l_contract_start_date;
       CLOSE contract_start_date_csr;

       l_converted_amount := 0;
       OKL_ACCOUNTING_UTIL.CONVERT_TO_CONTRACT_CURRENCY(
         p_khr_id                   => p_contract_id,
         p_from_currency            => NULL,
         p_transaction_date         => l_contract_start_date,
         p_amount                   => l_asset_deprn_rec.deprn_reserve,
         x_return_status            => x_return_status,
         x_contract_currency        => l_contract_currency,
         x_currency_conversion_type => l_currency_conversion_type,
         x_currency_conversion_rate => l_currency_conversion_rate,
         x_currency_conversion_date => l_currency_conversion_date,
         x_converted_amount         => l_converted_amount);


       IF(x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
         Okl_Api.Set_Message(p_app_name     => Okl_Api.G_APP_NAME,
                             p_msg_name     => 'OKL_CONV_TO_FUNC_CURRENCY_FAIL');
         RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;

       RETURN l_converted_amount;

     EXCEPTION

       WHEN OKL_API.G_EXCEPTION_ERROR THEN
         RETURN NULL;

 	WHEN OTHERS THEN
         Okl_Api.SET_MESSAGE(
           p_app_name     => G_APP_NAME,
           p_msg_name     => G_UNEXPECTED_ERROR,
           p_token1       => G_SQLCODE_TOKEN,
           p_token1_value => SQLCODE,
           p_token2       => G_SQLERRM_TOKEN,
           p_token2_value => SQLERRM);
        RETURN NULL;

   END asset_accu_deprn_reserve;

 -- Added by mansrini for ER Bug#6011738
   -- ---------------------------------------------------------------
   -- FUNCTION   : lease_quote_financed_amount
   --
   -- DESC       : Returns Financed Amount for an asset on a sales
   --              quote which is calculated as ->
   --              Asset Cost + Add-ons + Capitalized Fees
   --              - Capitalized Down Payments - Trade Ins.
   --
   -- PARAMETERS : Passed NONE, requires ASSET_ID to be passed as
   --              additional parameter from okl_execute_formula_pub
   --              which is the asset on quote for which to calculate
   --              financed amount.
   -- ---------------------------------------------------------------
   FUNCTION lease_quote_financed_amount
   RETURN NUMBER  IS
   --cursor to get asset cost
     CURSOR c_asset_cost (p_asset_id IN NUMBER) IS
           SELECT  (ASSETCOMP.NUMBER_OF_UNITS * ASSETCOMP.UNIT_COST) AST_COST
           FROM    OKL_ASSET_COMPONENTS_B ASSETCOMP
           WHERE   ASSETCOMP.PRIMARY_COMPONENT = 'YES'
           AND     ASSETCOMP.ASSET_ID =  p_asset_id;

   --cursor to get asset Add-On amount
     CURSOR c_addOn_cost (p_asset_id IN NUMBER) IS
       SELECT  sum(ASSETCOMP.NUMBER_OF_UNITS * ASSETCOMP.UNIT_COST) ADDON_AMNT
           FROM    OKL_ASSET_COMPONENTS_B ASSETCOMP
           WHERE   ASSETCOMP.PRIMARY_COMPONENT = 'NO'
           AND     ASSETCOMP.ASSET_ID = p_asset_id;

   -- cursor to get capitalized fee amount for the asset
     CURSOR c_cap_fee_amnt (p_asset_id IN NUMBER) IS
           SELECT  SUM(amount) capitalized_fee_amount
           FROM    okl_line_relationships_v lre
           WHERE   source_line_type = 'ASSET'
           AND     related_line_type = 'CAPITALIZED'
           AND     source_line_id = p_asset_id;

   --cursor to get capitalized down payment for the asset
     CURSOR c_cap_down_pmnt (p_asset_id IN NUMBER) IS
           SELECT  sum(adj.value) cap_down_payment
       FROM    okl_assets_b ast, okl_cost_adjustments_b adj
       WHERE   ast.parent_object_code = 'LEASEQUOTE'
       AND     adj.parent_object_id = ast.id
       AND     adj.ADJUSTMENT_SOURCE_TYPE = 'DOWN_PAYMENT'
       AND     adj.PROCESSING_TYPE = 'CAPITALIZE'
       AND     ast.id =  p_asset_id;

   --cursor to get trade-in amount for the asset
     CURSOR c_tradein_amnt (p_asset_id IN NUMBER) IS
           SELECT  sum(adj.value) tradeIn_amount
       FROM    okl_assets_b ast,  okl_cost_adjustments_b adj
       WHERE   ast.parent_object_code = 'LEASEQUOTE'
       AND     adj.parent_object_id = ast.id
       AND     adj.adjustment_source_type = 'TRADEIN'
       AND     ast.id = p_asset_id;

       l_asset_id         NUMBER;

       l_financed_amount  NUMBER;
       l_asset_cost       NUMBER;
       l_add_on_amnt      NUMBER;
       l_cap_fee_amnt     NUMBER;
       l_cap_down_pmnt    NUMBER;
       l_trade_in_amnt    NUMBER;

    BEGIN

       -- get asset id passed as additional parameters
       IF  okl_execute_formula_pub.g_additional_parameters.EXISTS(1)
           AND okl_execute_formula_pub.g_additional_parameters(1).name =
'ASSET_ID'
           AND okl_execute_formula_pub.g_additional_parameters(1).value IS NOT
NULL
           THEN
              l_asset_id :=
to_number(okl_execute_formula_pub.g_additional_parameters(1).value);
       END IF;

       IF (l_asset_id IS NULL) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- get asset cost
       l_asset_cost := 0;
       OPEN   c_asset_cost(l_asset_id);
       FETCH  c_asset_cost INTO l_asset_cost;
       IF( c_asset_cost%NOTFOUND ) THEN
           CLOSE c_asset_cost;
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
       CLOSE c_asset_cost;

       -- get add-on amount
       OPEN   c_addOn_cost(l_asset_id);
       FETCH  c_addOn_cost INTO l_add_on_amnt;
       CLOSE c_addOn_cost;
       IF l_add_on_amnt is null then
           l_add_on_amnt := 0;
       END IF;

       -- get capitalized fee amount
       OPEN   c_cap_fee_amnt(l_asset_id);
       FETCH  c_cap_fee_amnt INTO l_cap_fee_amnt;
       CLOSE c_cap_fee_amnt;
       IF l_cap_fee_amnt is null then
           l_cap_fee_amnt := 0;
       END IF;

       -- get capitalized down payment amount
       OPEN   c_cap_down_pmnt(l_asset_id);
       FETCH  c_cap_down_pmnt INTO l_cap_down_pmnt;
       CLOSE c_cap_down_pmnt;
       IF l_cap_down_pmnt is null then
           l_cap_down_pmnt := 0;
       END IF;

       -- get trade-in amount
       OPEN   c_tradein_amnt(l_asset_id);
       FETCH  c_tradein_amnt INTO l_trade_in_amnt;
       CLOSE c_tradein_amnt;
       IF l_trade_in_amnt is null then
           l_trade_in_amnt := 0;
       END IF;

       l_financed_amount := l_asset_cost + l_add_on_amnt + l_cap_fee_amnt -
l_cap_down_pmnt - l_trade_in_amnt;

       RETURN l_financed_amount;
   EXCEPTION
   WHEN OKL_API.G_EXCEPTION_ERROR THEN
       IF c_asset_cost%ISOPEN THEN
          CLOSE c_asset_cost;
       END IF;
       IF c_addOn_cost%ISOPEN THEN
          CLOSE c_addOn_cost;
       END IF;
       IF c_cap_fee_amnt%ISOPEN THEN
          CLOSE c_cap_fee_amnt;
       END IF;
       IF c_cap_down_pmnt%ISOPEN THEN
          CLOSE c_cap_down_pmnt;
       END IF;
       IF c_tradein_amnt%ISOPEN THEN
          CLOSE c_tradein_amnt;
       END IF;
       RETURN NULL;
   WHEN OTHERS THEN
       Okl_Api.SET_MESSAGE(
             p_app_name     => G_APP_NAME,
             p_msg_name     => G_UNEXPECTED_ERROR,
             p_token1       => G_SQLCODE_TOKEN,
             p_token1_value => SQLCODE,
             p_token2       => G_SQLERRM_TOKEN,
             p_token2_value => SQLERRM);
       IF c_asset_cost%ISOPEN THEN
          CLOSE c_asset_cost;
       END IF;
       IF c_addOn_cost%ISOPEN THEN
          CLOSE c_addOn_cost;
       END IF;
       IF c_cap_fee_amnt%ISOPEN THEN
          CLOSE c_cap_fee_amnt;
       END IF;
       IF c_cap_down_pmnt%ISOPEN THEN
          CLOSE c_cap_down_pmnt;
       END IF;
       IF c_tradein_amnt%ISOPEN THEN
          CLOSE c_tradein_amnt;
       END IF;
       RETURN NULL;
   END lease_quote_financed_amount;
   -- End by mansrini for ER Bug#6011738

   -- Start : Added by mansrini for ER Bug#6011738
   -- -----------------------------------------------------------------------
   -- FUNCTION   : line_financed_amount
   --
   -- DESC       : Returns Financed Amount for an asset line of a contract
   --              which is calculated as
   --              Financed Amount =  Asset Cost
   --                               + Add-On to the asset
   --                               + Capitalized Fee associated to the asset
   --                               - Capitalized Down Payment for the asset
   --                               - Trade-In Amount associated to the asset
   --
   -- PARAMETERS : IN p_contract_id, p_contract_line_id
   -- -----------------------------------------------------------------------
   FUNCTION line_financed_amount(p_contract_id IN NUMBER
                                ,p_contract_line_id IN NUMBER)
   RETURN NUMBER  IS
      G_APP_NAME                   CONSTANT  VARCHAR2(3)   :=
OKL_API.G_APP_NAME;
      G_PKG_NAME                   CONSTANT  VARCHAR2(200) := 'OKL_FORMULA_PVT';
      G_COL_NAME_TOKEN             CONSTANT  VARCHAR2(200) :=
OKL_API.G_COL_NAME_TOKEN;
      G_NO_MATCHING_RECORD         CONSTANT  VARCHAR2(200) :=
'OKL_LLA_NO_MATCHING_RECORD';
      G_SQLERRM_TOKEN              CONSTANT  VARCHAR2(200) := 'SQLERRM';
      G_SQLCODE_TOKEN              CONSTANT  VARCHAR2(200) := 'SQLCODE';
      G_LINE_RECORD                CONSTANT  VARCHAR2(200) :=
'OKL_LLA_LINE_RECORD';
      G_INVALID_CRITERIA           CONSTANT  VARCHAR2(200) :=
'OKL_LLA_INVALID_CRITERIA';
      l_return_status                        VARCHAR2(3)   :=
OKL_API.G_RET_STS_SUCCESS;

      l_lty_code                             OKC_LINE_STYLES_V.LTY_CODE%TYPE;
      l_financed_amount                      NUMBER;
      l_asset_cost                           NUMBER;
      l_addon                                NUMBER;
      l_cap_fee                              NUMBER;
      l_trade_in                             NUMBER;
      l_cap_down_pmnt                        NUMBER;
      l_cap_down_pct                         NUMBER;
      l_cap_down_pmnt_yn                     VARCHAR2(3);

      -- Cursor to get the lty_code
      CURSOR get_lty_code(p_line_id NUMBER) IS
       SELECT lse.lty_code
         FROM okc_k_lines_b cle,
              okc_line_styles_b lse
        WHERE cle.id = p_line_id
          AND cle.lse_id = lse.id;

      -- Cursor to sum up asset cost for given Asset line
      CURSOR c_asset_cost(p_line_id NUMBER,
                          p_dnz_chr_id NUMBER) IS
       SELECT SUM(cle.price_unit * cim.number_of_items) asset_cost
         FROM okc_subclass_top_line stl,
              okc_line_styles_b lse2,
              okc_line_styles_b lse1,
              okc_k_items_v cim,
              okc_k_lines_v cle
        WHERE cle.cle_id = p_line_id
          AND cle.dnz_chr_id = p_dnz_chr_id
          AND cle.id = cim.cle_id
          AND cle.dnz_chr_id = cim.dnz_chr_id
          AND cle.lse_id = lse1.id
          AND lse1.lty_code = 'ITEM'
          AND lse1.lse_parent_id = lse2.id
          AND lse2.lty_code = 'FREE_FORM1'
          AND lse2.id = stl.lse_id
          AND stl.scs_code IN ('LEASE','LOAN');

      -- Cursor to sum up addon amount for a given line
      CURSOR c_addon(p_line_id NUMBER,
                     p_dnz_chr_id NUMBER) IS
       SELECT SUM(cle.price_unit* cim.number_of_items) add_on
         FROM okc_subclass_top_line stl,
              okc_line_styles_b lse3,
              okc_line_styles_b lse2,
              okc_line_styles_b lse1,
              okc_k_items_v cim,
              okc_k_lines_b cle
        WHERE cle.dnz_chr_id = p_dnz_chr_id
          AND cle.dnz_chr_id = cim.dnz_chr_id
          AND cle.id = cim.cle_id
          AND cle.lse_id = lse1.id
          AND lse1.lty_code = 'ADD_ITEM'
          AND lse1.lse_parent_id = lse2.id
          AND lse2.lty_code = 'ITEM'
          AND lse2.lse_parent_id = lse3.id
          AND lse3.lty_code = 'FREE_FORM1'
          AND lse3.id = stl.lse_id
          AND stl.scs_code IN ('LEASE','LOAN')
          AND exists (SELECT 1
                        FROM okc_subclass_top_line stlx,
                             okc_line_styles_b lse2x,
                             okc_line_styles_b lse1x,
                             okc_k_lines_b clex
                       WHERE clex.cle_id = p_line_id
                         AND clex.dnz_chr_id = p_dnz_chr_id
                         AND clex.lse_id = lse1x.id
                         AND lse1x.lty_code = 'ITEM'
                         AND lse1x.lse_parent_id = lse2x.id
                         AND lse2x.lty_code = 'FREE_FORM1'
                         AND lse2x.id = stlx.lse_id
                         AND stlx.scs_code IN ('LEASE','LOAN')
                         AND clex.id = cle.cle_id);

      --Cursor for Capitalized Fee
      CURSOR c_cap_fee(p_line_id VARCHAR2,
                       p_dnz_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
       SELECT SUM(kle_cov.capital_amount) Cap_fee
         FROM okc_line_styles_b  lseb,
              okc_k_items        cim,
              okl_k_lines        kle_cov,
              okc_k_lines_b      cleb_cov,
              okc_statuses_b     stsb
        WHERE lseb.id               = cleb_cov.lse_id
          AND lseb.lty_code         = 'LINK_FEE_ASSET'
          AND cim.jtot_object1_code = 'OKX_COVASST'
          AND cleb_cov.id           =  cim.cle_id
          AND kle_cov.id            =  cleb_cov.id
          AND cleb_cov.dnz_chr_id   =  cim.dnz_chr_id
          AND cleb_cov.dnz_chr_id   =  p_dnz_chr_id
          AND cim.object1_id1       =  p_line_id
          AND cleb_cov.sts_code     =  stsb.code
          AND stsb.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED',
'HOLD');

      --Cursor for Trade-in Amount and Capital Down Payment
      CURSOR c_asset_adjust(p_line_id NUMBER,
                            p_dnz_chr_id NUMBER) IS
       SELECT NVL(kle.capital_reduction,0) capital_reduction,
              NVL(kle.tradein_amount,0) tradein_amount,
              NVL(kle.capital_reduction_percent,0) capital_reduction_percent,
              kle.capitalize_down_payment_yn capitalize_down_payment_yn
         FROM okc_line_styles_b ls,
              okl_k_lines_full_v kle,
              okc_statuses_b sts
        WHERE kle.dnz_chr_id = p_dnz_chr_id
          AND kle.id = p_line_id
          AND ls.id = kle.lse_id
          AND ls.lty_code ='FREE_FORM1'
          AND kle.sts_code = sts.code
          AND sts.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED',
'HOLD');

   BEGIN
          -- To get the Line Style Code
          OPEN  get_lty_code(p_line_id => p_contract_line_id);
             IF get_lty_code%NOTFOUND THEN
                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_NO_MATCHING_RECORD,
                                    p_token1       => G_COL_NAME_TOKEN,
                                    p_token1_value => 'Financial Asset Line');
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
          FETCH get_lty_code INTO l_lty_code;
          CLOSE get_lty_code;

          IF l_lty_code = 'FREE_FORM1' THEN
             -- To get the asset cost
             OPEN c_asset_cost(p_line_id => p_contract_line_id,
                               p_dnz_chr_id => p_contract_id);
                IF c_asset_cost%NOTFOUND THEN
                   OKL_API.set_message(p_app_name     => G_APP_NAME,
                                       p_msg_name     => G_NO_MATCHING_RECORD,
                                       p_token1       => G_COL_NAME_TOKEN,
                                       p_token1_value => 'Model Line');
                   RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
             FETCH c_asset_cost INTO l_asset_cost;
             CLOSE c_asset_cost;

             -- To get the Addon
-- DJANASWA change begin 11/12/08

/*             OPEN c_addon(p_line_id => p_contract_line_id,
                          p_dnz_chr_id => p_contract_id);
             FETCH c_addon INTO l_addon;
             CLOSE c_addon;
*/
            l_addon :=  Okl_Seeded_Functions_Pvt.total_asset_addon_cost(
                        p_contract_id => p_contract_id, p_contract_line_id => p_contract_line_id);

-- DJANASWA change end 11/12/08

            l_addon := NVL(l_addon,0);

             -- To get the Capitalized Fee
             OPEN c_cap_fee(p_line_id => TO_CHAR(p_contract_line_id),
                            p_dnz_chr_id => p_contract_id);
             FETCH c_cap_fee INTO l_cap_fee;
             CLOSE c_cap_fee;
             l_cap_fee := NVL(l_cap_fee,0);

             -- To get the Trade-in and Capitalized Down Payment
             OPEN c_asset_adjust(p_line_id => p_contract_line_id,
                          p_dnz_chr_id => p_contract_id);
             FETCH c_asset_adjust INTO
l_cap_down_pmnt,l_trade_in,l_cap_down_pct,l_cap_down_pmnt_yn;
             CLOSE c_asset_adjust;
             l_trade_in := NVL(l_trade_in,0);
             l_cap_down_pmnt := NVL(l_cap_down_pmnt,0);
             l_cap_down_pct := NVL(l_cap_down_pct,0);
             l_cap_down_pmnt_yn := NVL(l_cap_down_pmnt_yn,'N');

             IF l_cap_down_pct<>0 THEN
                 l_cap_down_pmnt := (l_asset_cost + l_addon) *
l_cap_down_pct/100;
             END IF;

             --Calculation of Financed Amount
             --on the basis of Capitalized Down Payment Flag
             IF l_cap_down_pmnt_yn = 'N' THEN
               l_financed_amount := l_asset_cost + l_addon + l_cap_fee  -
l_trade_in;
             ELSE
               l_financed_amount := l_asset_cost + l_addon + l_cap_fee  -
l_cap_down_pmnt - l_trade_in;
             END IF;

          ELSE
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_LINE_RECORD);
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          RETURN l_financed_amount;
   EXCEPTION
       WHEN OKL_API.G_EXCEPTION_ERROR THEN
        -- If the cursor is open then it has to be closed
          IF get_lty_code%ISOPEN THEN
            CLOSE get_lty_code;
          END IF;
          IF c_asset_cost%ISOPEN THEN
            CLOSE c_asset_cost;
          END IF;
          IF c_addon%ISOPEN THEN
            CLOSE c_addon;
          END IF;
          IF c_cap_fee%ISOPEN THEN
            CLOSE c_cap_fee;
          END IF;
          IF c_asset_adjust%ISOPEN THEN
            CLOSE c_asset_adjust;
          END IF;
          RETURN NULL;
       WHEN OTHERS THEN
        -- If the cursor is open then it has to be closed
          IF get_lty_code%ISOPEN THEN
            CLOSE get_lty_code;
          END IF;
          IF c_asset_cost%ISOPEN THEN
            CLOSE c_asset_cost;
          END IF;
          IF c_addon%ISOPEN THEN
            CLOSE c_addon;
          END IF;
          IF c_cap_fee%ISOPEN THEN
            CLOSE c_cap_fee;
          END IF;
          IF c_asset_adjust%ISOPEN THEN
            CLOSE c_asset_adjust;
          END IF;
          RETURN NULL;
   END line_financed_amount;

   -- --------------------------------------------------------------------
   -- FUNCTION   : front_end_financed_amount
   --
   -- DESC       : Returns Financed Amount for a financial asset line
   --              depending upon the parameters passed
   --
   --              If p_contract_id and p_contract_line_id are NULL,
   --              it implies that the function is called from LEASE
   --              QUOTE process and the financed amount is calculated
   --              using the function lease_quote_financed_amount().
   --
   --              And if p_contract_id and p_contract_line_id are not
   --              NULL, then it implies that the function is called
   --              from AUTHORING process and the financed amount is then
   --              calculated using the function line_financed_amount().
   --
   -- PARAMETERS : IN p_contract_id, p_contract_line_id
   -- --------------------------------------------------------------------
   FUNCTION front_end_financed_amount( p_contract_id IN NUMBER
                                      ,p_contract_line_id IN NUMBER)
   RETURN NUMBER IS
      G_APP_NAME                   CONSTANT  VARCHAR2(3)   :=
OKL_API.G_APP_NAME;
      G_PKG_NAME                   CONSTANT  VARCHAR2(200) := 'OKL_FORMULA_PVT';
      G_SQLERRM_TOKEN              CONSTANT  VARCHAR2(200) := 'SQLERRM';
      G_SQLCODE_TOKEN              CONSTANT  VARCHAR2(200) := 'SQLCODE';
      G_INVALID_CRITERIA           CONSTANT  VARCHAR2(200) :=
'OKL_LLA_INVALID_CRITERIA';
      l_api_name                   CONSTANT  VARCHAR2(30)  :=
'FRONT_END_FINANCED_AMOUNT';

      l_financed_amt                         NUMBER        := 0;

   BEGIN
      -- Call from LEASE QUOTE
      IF p_contract_id IS NULL AND p_contract_line_id IS NULL THEN
         l_financed_amt := lease_quote_financed_amount;

      -- Call from AUTHORING
      ELSIF (p_contract_id IS NOT NULL OR
             p_contract_id <> Okl_Api.G_MISS_NUM) AND
            (p_contract_line_id IS NOT NULL OR
             p_contract_line_id <> Okl_Api.G_MISS_NUM) THEN
         l_financed_amt := line_financed_amount(p_contract_id => p_contract_id,
                                                p_contract_line_id =>
p_contract_line_id);

      ELSE
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      RETURN l_financed_amt;

   EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
         OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_INVALID_CRITERIA);
         RETURN NULL;
      WHEN OTHERS THEN
         OKL_API.SET_MESSAGE(
                             p_app_name     => G_APP_NAME,
                             p_msg_name     => G_UNEXPECTED_ERROR,
                             p_token1       => G_SQLCODE_TOKEN,
                             p_token1_value => SQLCODE,
                             p_token2       => G_SQLERRM_TOKEN,
                             p_token2_value => SQLERRM);
         RETURN NULL;
   END front_end_financed_amount;
   --End by mansrini for Bug#6011738


   -- --------------------------------------------------------------------
   -- FUNCTION   : total_asset_addon_cost
   --
   -- DESC       : Returns total asset addon cost.
   --
   -- PARAMETERS : IN p_contract_id, p_contract_line_id
   -- Added by Durga Janaswamy
   -- --------------------------------------------------------------------
   FUNCTION total_asset_addon_cost ( p_contract_id IN NUMBER
                                      ,p_contract_line_id IN NUMBER)
   RETURN NUMBER IS
      G_APP_NAME                   CONSTANT  VARCHAR2(3)   := OKL_API.G_APP_NAME;
      G_PKG_NAME                   CONSTANT  VARCHAR2(200) := 'OKL_FORMULA_PVT';
      G_SQLERRM_TOKEN              CONSTANT  VARCHAR2(200) := 'SQLERRM';
      G_SQLCODE_TOKEN              CONSTANT  VARCHAR2(200) := 'SQLCODE';
      G_INVALID_CRITERIA           CONSTANT  VARCHAR2(200) := 'OKL_LLA_INVALID_CRITERIA';
      l_api_name                   CONSTANT  VARCHAR2(30)  := 'TOTAL_ASSET_ADDON_COST';

      l_addon_cost                         NUMBER        := 0;

   CURSOR c_addon_cost_csr (p_contract_id IN NUMBER,
                            p_contract_line_id IN NUMBER) IS
         SELECT SUM(cle.price_unit* cim.number_of_items) add_on_cost
         FROM okc_subclass_top_line stl,
              okc_line_styles_b lse3,
              okc_line_styles_b lse2,
              okc_line_styles_b lse1,
              okc_k_items_v cim,
              okc_k_lines_b cle
        WHERE cle.dnz_chr_id = p_contract_id
          AND cle.dnz_chr_id = cim.dnz_chr_id
          AND cle.id = cim.cle_id
          AND cle.lse_id = lse1.id
          AND lse1.lty_code = 'ADD_ITEM'    -- G_ADDON_LINE_LTY_CODE
          AND lse1.lse_parent_id = lse2.id
          AND lse2.lty_code = 'ITEM'          -- G_MODEL_LINE_LTY_CODE
          AND lse2.lse_parent_id = lse3.id
          AND lse3.lty_code = 'FREE_FORM1'   --  G_FIN_LINE_LTY_CODE
          AND lse3.id = stl.lse_id
          AND stl.scs_code IN ('LEASE','LOAN')
          AND exists (SELECT 1
                        FROM okc_subclass_top_line stlx,
                             okc_line_styles_b lse2x,
                             okc_line_styles_b lse1x,
                             okc_k_lines_b clex
                       WHERE clex.cle_id = p_contract_line_id   -- lse_id = 33>
                         AND clex.dnz_chr_id = p_contract_id
                         AND clex.lse_id = lse1x.id
                         AND lse1x.lty_code = 'ITEM'  -- G_MODEL_LINE_LTY_CODE
                         AND lse1x.lse_parent_id = lse2x.id
                         AND lse2x.lty_code = 'FREE_FORM1' -- G_FIN_LINE_LTY_CODE
                         AND lse2x.id = stlx.lse_id
                         AND stlx.scs_code IN ('LEASE','LOAN')
                         AND clex.id = cle.cle_id);


   BEGIN

        IF (p_contract_id IS NOT NULL OR
             p_contract_id <> Okl_Api.G_MISS_NUM) AND
            (p_contract_line_id IS NOT NULL OR
             p_contract_line_id <> Okl_Api.G_MISS_NUM) THEN

           OPEN  c_addon_cost_csr ( p_contract_id => p_contract_id,
                                    p_contract_line_id => p_contract_line_id);

                   IF c_addon_cost_csr%NOTFOUND THEN
                          NULL;
                   END IF;

           FETCH c_addon_cost_csr INTO l_addon_cost;
           CLOSE c_addon_cost_csr;
        END IF;

      l_addon_cost := NVL(l_addon_cost,0);

      RETURN(l_addon_cost);


   EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        IF c_addon_cost_csr%ISOPEN THEN
              CLOSE c_addon_cost_csr;
        END IF;

         OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_INVALID_CRITERIA);
         RETURN NULL;


      WHEN OTHERS THEN
         --sechawla 18-nov-08 : close cursor
         IF c_addon_cost_csr%ISOPEN THEN
              CLOSE c_addon_cost_csr;
         END IF;
         OKL_API.SET_MESSAGE(
                             p_app_name     => G_APP_NAME,
                             p_msg_name     => G_UNEXPECTED_ERROR,
                             p_token1       => G_SQLCODE_TOKEN,
                             p_token1_value => SQLCODE,
                             p_token2       => G_SQLERRM_TOKEN,
                             p_token2_value => SQLERRM);
         RETURN NULL;
   END TOTAL_ASSET_ADDON_COST;


----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Durga Janaswamy
    -- Function Name  get_line_subsidy_amount
    -- Description:   returns the asset line subsidy amount for given contract
    -- Dependencies:
    -- Parameters: contract id,contract line id, accounting method
    --
    -- Version: 1.0
    --
    -- End of Comments

----------------------------------------------------------------------------------------------------
FUNCTION get_line_subsidy_amount(
    p_contract_id                 IN  NUMBER,
    p_fin_asset_line_id           IN  NUMBER,
    p_accounting_method           IN  VARCHAR2)
RETURN NUMBER IS

    lx_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     VARCHAR2(30) := 'GET_LINE_ASSET_SUBSIDY';
    l_api_version          CONSTANT     NUMBER := 1.0;
    l_init_msg_list                     VARCHAR2(1) := OKL_API.G_FALSE;
    lx_msg_count                        NUMBER := OKL_API.G_MISS_NUM;
    lx_msg_data                         VARCHAR2(2000);

    x_subsidy_amount       NUMBER;

    l_asset_line_subsidy_amount NUMBER;

    --cursor to fetch all the subsidies attached to financial asset
    -- passing accounting method as input parameter
    CURSOR l_sub_csr(p_contract_id IN NUMBER,
                     p_fin_asset_line_id IN  NUMBER,
                     p_accounting_method IN  VARCHAR2) IS
    SELECT NVL(SUM(sub_kle.amount),0)
    FROM   okl_subsidies_b    subb,
           okl_k_lines        sub_kle,
           okc_k_lines_b      sub_cle,
           okc_line_styles_b  sub_lse
    WHERE  subb.id                     = sub_kle.subsidy_id
    AND    subb.accounting_method_code = NVL(UPPER(p_accounting_method),subb.accounting_method_code)
    AND    sub_kle.id                  = sub_cle.id
    AND    sub_cle.lse_id              = sub_lse.id
    AND    sub_lse.lty_code            = 'SUBSIDY'
    AND    sub_cle.sts_code            <> 'ABANDONED'
    AND    sub_cle.dnz_chr_id          = p_contract_id
    AND    sub_cle.cle_id              = p_fin_asset_line_id
    AND    subb.customer_visible_yn    = 'Y'
    ;

    l_accounting_method        okl_subsidies_b.accounting_method_code%TYPE;
    l_subsidy_cle_id           NUMBER;

BEGIN

	l_asset_line_subsidy_amount := 0;

    x_subsidy_amount := 0;


    IF(p_accounting_method IS NULL OR p_accounting_method = OKL_API.G_MISS_CHAR) THEN
        l_accounting_method := NULL;
    ELSE
        l_accounting_method := p_accounting_method;
    END IF;

    --------------------------------------------------------------
    --get all the subsidies associated to asset and get amount
    --------------------------------------------------------------
    OPEN l_sub_csr(p_contract_id , p_fin_asset_line_id, l_accounting_method);
    --LOOP  --sechawla 18-nov
    FETCH l_sub_csr INTO l_asset_line_subsidy_amount;
    --    EXIT WHEN l_sub_csr%NOTFOUND;
    -- END LOOP;
    CLOSE l_sub_csr;

    x_subsidy_amount := NVL(l_asset_line_subsidy_amount,0);

    RETURN x_subsidy_amount;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF l_sub_csr%ISOPEN THEN
        CLOSE l_sub_csr;
    END IF;
    lx_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               lx_msg_count,
                               lx_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF l_sub_csr%ISOPEN THEN
        CLOSE l_sub_csr;
    END IF;
    lx_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              lx_msg_count,
                              lx_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF l_sub_csr%ISOPEN THEN
        CLOSE l_sub_csr;
    END IF;
    lx_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              lx_msg_count,
                              lx_msg_data,
                              '_PVT');

END get_line_subsidy_amount;


----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:       Durga Janaswamy
    -- Function Name  get_line_subsidy_ovrd_amount
    -- Description:   returns the asset line subsidy amount for given contract
    -- Dependencies:
    -- Parameters: contract id,contract line id, accounting method
    --
    -- Version: 1.0
    --
    -- End of Comments

----------------------------------------------------------------------------------------------------
FUNCTION get_line_subsidy_ovrd_amount(
    p_contract_id                 IN  NUMBER,
    p_fin_asset_line_id           IN  NUMBER,
    p_accounting_method           IN  VARCHAR2)
RETURN NUMBER IS

    lx_return_status        VARCHAR2(1)  DEFAULT OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     VARCHAR2(30) := 'GET_LINE_ASSET_SUBSIDY_OVRD';
    l_api_version          CONSTANT     NUMBER := 1.0;
    l_init_msg_list                     VARCHAR2(1) := OKL_API.G_FALSE;
    lx_msg_count                        NUMBER := OKL_API.G_MISS_NUM;
    lx_msg_data                         VARCHAR2(2000);

    x_subsidy_amount       NUMBER;

    l_asset_line_subs_ovrd_amn NUMBER;

    --cursor to fetch all the subsidies attached to financial asset
    -- passing accounting method as input parameter
    CURSOR l_sub_csr(p_contract_id IN NUMBER,
                     p_fin_asset_line_id IN  NUMBER,
                     p_accounting_method IN  VARCHAR2) IS
    SELECT NVL(SUM(sub_kle.subsidy_override_amount),0)
    FROM   okl_subsidies_b    subb,
           okl_k_lines        sub_kle,
           okc_k_lines_b      sub_cle,
           okc_line_styles_b  sub_lse
    WHERE  subb.id                     = sub_kle.subsidy_id
    AND    subb.accounting_method_code = NVL(UPPER(p_accounting_method),subb.accounting_method_code)
    AND    sub_kle.id                  = sub_cle.id
    AND    sub_cle.lse_id              = sub_lse.id
    AND    sub_lse.lty_code            = 'SUBSIDY'
    AND    sub_cle.sts_code            <> 'ABANDONED'
    AND    sub_cle.dnz_chr_id          = p_contract_id
    AND    sub_cle.cle_id              = p_fin_asset_line_id
    AND    subb.customer_visible_yn    = 'Y'
    ;

    l_accounting_method        okl_subsidies_b.accounting_method_code%TYPE;
    l_subsidy_cle_id           NUMBER;

BEGIN

	l_asset_line_subs_ovrd_amn := 0;

    x_subsidy_amount := 0;

    IF(p_accounting_method IS NULL OR p_accounting_method = OKL_API.G_MISS_CHAR) THEN
        l_accounting_method := NULL;
    ELSE
        l_accounting_method := p_accounting_method;
    END IF;

    --------------------------------------------------------------
    --get all the subsidies associated to asset and get amount
    --------------------------------------------------------------
    OPEN l_sub_csr(p_contract_id , p_fin_asset_line_id, l_accounting_method);
    --LOOP  --sechawla 18-nov-08
    FETCH l_sub_csr INTO l_asset_line_subs_ovrd_amn;
    --    EXIT WHEN l_sub_csr%NOTFOUND;
    --END LOOP;
    CLOSE l_sub_csr;

    x_subsidy_amount := NVL(l_asset_line_subs_ovrd_amn,0);

    RETURN x_subsidy_amount;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF l_sub_csr%ISOPEN THEN
        CLOSE l_sub_csr;
    END IF;
    lx_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               lx_msg_count,
                               lx_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF l_sub_csr%ISOPEN THEN
        CLOSE l_sub_csr;
    END IF;
    lx_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              lx_msg_count,
                              lx_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF l_sub_csr%ISOPEN THEN
        CLOSE l_sub_csr;
    END IF;
    lx_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              lx_msg_count,
                              lx_msg_data,
                              '_PVT');

END get_line_subsidy_ovrd_amount;


----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:    Seema Chawla
    -- Function Name  Total_Asset_Financed_Fee_Amt
    -- Description:   Returns total financed fee amount associated to an asset line
    -- Dependencies:
    -- Parameters: contract id and line id
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION Total_Asset_Financed_Fee_Amt(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_version       CONSTANT NUMBER       := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_Asset_Fin_fees_amt    NUMBER := 0;

    CURSOR l_fee_csr( c_chr_id IN NUMBER, c_fin_asset_line_id IN NUMBER) IS
    SELECT sum(kle_cov.amount) asset_fin_fee_amt
       FROM   OKC_LINE_STYLES_B  LSEB,
              OKC_K_ITEMS        CIM,
              OKL_K_LINES        KLE_COV,
              okl_k_lines        fee_line,
              OKC_K_LINES_B      CLEB_COV,
              OKC_STATUSES_B     STSB
        WHERE LSEB.ID               = CLEB_COV.LSE_ID
        AND   LSEB.lty_code         = 'LINK_FEE_ASSET'
        AND   CIM.jtot_object1_code = 'OKX_COVASST'
        AND   CLEB_COV.id           =  CIM.cle_id
        AND   KLE_COV.id            =  CLEB_COV.ID
        AND   CLEB_COV.DNZ_CHR_ID   =  CIM.DNZ_CHR_ID
        AND   CLEB_COV.dnz_chr_id   =  c_chr_id
        AND   cim.object1_id1       =  to_char(c_fin_asset_line_id) --lse_id = 33
        AND   CLEB_COV.sts_code     =  STSB.code
        and   CLEB_COV.cle_id       =  fee_line.id
        and   fee_line.fee_type     =  'FINANCED'
        AND   STSB.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');


    CURSOR l_fee_csr_incl_terminated( c_chr_id IN NUMBER, c_fin_asset_line_id IN NUMBER) IS
    SELECT sum(kle_cov.amount) asset_fin_fee_amt
       FROM   OKC_LINE_STYLES_B  LSEB,
              OKC_K_ITEMS        CIM,
              OKL_K_LINES        KLE_COV,
              okl_k_lines        fee_line,
              OKC_K_LINES_B      CLEB_COV,
              OKC_STATUSES_B     STSB
        WHERE LSEB.ID               = CLEB_COV.LSE_ID
        AND   LSEB.lty_code         = 'LINK_FEE_ASSET'
        AND   CIM.jtot_object1_code = 'OKX_COVASST'
        AND   CLEB_COV.id           =  CIM.cle_id
        AND   KLE_COV.id            =  CLEB_COV.ID
        AND   CLEB_COV.DNZ_CHR_ID   =  CIM.DNZ_CHR_ID
        AND   CLEB_COV.dnz_chr_id   =  c_chr_id
        AND   cim.object1_id1       =  to_char(c_fin_asset_line_id) --lse_id = 33
        AND   CLEB_COV.sts_code     =  STSB.code
        and   CLEB_COV.cle_id       =  fee_line.id
        and   fee_line.fee_type     =  'FINANCED'
        AND   STSB.ste_code NOT IN ( 'EXPIRED', 'CANCELLED', 'HOLD');



   l_discount_incl_terminated 	BOOLEAN := FALSE;

  BEGIN

    IF (( p_chr_id IS NULL ) OR (p_line_id IS NULL)) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;


    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_discount_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;


    IF l_discount_incl_terminated THEN
       OPEN  l_fee_csr_incl_terminated (p_chr_id, p_line_id );
       FETCH l_fee_csr_incl_terminated INTO l_Asset_Fin_fees_amt;
       CLOSE l_fee_csr_incl_terminated;
    ELSE
       OPEN  l_fee_csr( p_chr_id, p_line_id );
       FETCH l_fee_csr INTO l_Asset_Fin_fees_amt;
       CLOSE l_fee_csr;
    END IF;

    l_Asset_Fin_fees_amt := nvl(l_Asset_Fin_fees_amt,0);

    RETURN l_Asset_Fin_fees_amt;

    EXCEPTION

        WHEN OTHERS THEN
            IF l_fee_csr_incl_terminated%ISOPEN THEN
               CLOSE l_fee_csr_incl_terminated;
            END IF;
            IF l_fee_csr%ISOPEN THEN
               CLOSE l_fee_csr;
            END IF;

                Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
            RETURN NULL;

  END Total_Asset_Financed_Fee_Amt;


  ----------------------------------------------------------------------------------------------------

    -- Start of Comments
    -- Created By:    Seema Chawla
    -- Function Name  Total_Asset_Rollover_Fee_Amt
    -- Description:   Returns total Rollover fee amount associated to an asset line
    -- Dependencies:
    -- Parameters: contract id and line id
    -- Version: 1.0
    -- End of Commnets

----------------------------------------------------------------------------------------------------
  FUNCTION Total_Asset_Rollover_Fee_Amt(
            p_chr_id          IN  NUMBER,
            p_line_id         IN  NUMBER) RETURN NUMBER  IS

    l_api_version       CONSTANT NUMBER       := 1;
    x_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(256);

    l_Asset_Roll_fees_amt    NUMBER := 0;

    CURSOR l_fee_csr( c_chr_id IN NUMBER, c_fin_asset_line_id IN NUMBER) IS
    SELECT sum(kle_cov.amount) asset_roll_fee_amt
       FROM   OKC_LINE_STYLES_B  LSEB,
              OKC_K_ITEMS        CIM,
              OKL_K_LINES        KLE_COV,
              okl_k_lines        fee_line,
              OKC_K_LINES_B      CLEB_COV,
              OKC_STATUSES_B     STSB
        WHERE LSEB.ID               = CLEB_COV.LSE_ID
        AND   LSEB.lty_code         = 'LINK_FEE_ASSET'
        AND   CIM.jtot_object1_code = 'OKX_COVASST'
        AND   CLEB_COV.id           =  CIM.cle_id
        AND   KLE_COV.id            =  CLEB_COV.ID
        AND   CLEB_COV.DNZ_CHR_ID   =  CIM.DNZ_CHR_ID
        AND   CLEB_COV.dnz_chr_id   =  c_chr_id
        AND   cim.object1_id1       =  to_char(c_fin_asset_line_id) --lse_id = 33
        AND   CLEB_COV.sts_code     =  STSB.code
        and   CLEB_COV.cle_id       =  fee_line.id
        and   fee_line.fee_type     =  'ROLLOVER'
        AND   STSB.ste_code NOT IN ('TERMINATED', 'EXPIRED', 'CANCELLED', 'HOLD');


    CURSOR l_fee_csr_incl_terminated( c_chr_id IN NUMBER, c_fin_asset_line_id IN NUMBER) IS
    SELECT sum(kle_cov.amount) asset_roll_fee_amt
       FROM   OKC_LINE_STYLES_B  LSEB,
              OKC_K_ITEMS        CIM,
              OKL_K_LINES        KLE_COV,
              okl_k_lines        fee_line,
              OKC_K_LINES_B      CLEB_COV,
              OKC_STATUSES_B     STSB
        WHERE LSEB.ID               = CLEB_COV.LSE_ID
        AND   LSEB.lty_code         = 'LINK_FEE_ASSET'
        AND   CIM.jtot_object1_code = 'OKX_COVASST'
        AND   CLEB_COV.id           =  CIM.cle_id
        AND   KLE_COV.id            =  CLEB_COV.ID
        AND   CLEB_COV.DNZ_CHR_ID   =  CIM.DNZ_CHR_ID
        AND   CLEB_COV.dnz_chr_id   =  c_chr_id
        AND   cim.object1_id1       =  to_char(c_fin_asset_line_id) --lse_id = 33
        AND   CLEB_COV.sts_code     =  STSB.code
        and   CLEB_COV.cle_id       =  fee_line.id
        and   fee_line.fee_type     =  'ROLLOVER'
        AND   STSB.ste_code NOT IN ( 'EXPIRED', 'CANCELLED', 'HOLD');



   l_discount_incl_terminated 	BOOLEAN := FALSE;

  BEGIN

    IF (( p_chr_id IS NULL ) OR (p_line_id IS NULL)) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;


    IF Okl_Execute_Formula_Pub.G_ADDITIONAL_PARAMETERS.COUNT > 0 THEN
      FOR I IN OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.FIRST..OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS.LAST
	  LOOP
        IF OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).NAME = 'TERMINATED_LINES_YN' AND
          OKL_EXECUTE_FORMULA_PUB.G_ADDITIONAL_PARAMETERS(I).VALUE = 'Y' THEN
		  l_discount_incl_terminated := TRUE;
        END IF;
      END LOOP;
    END IF;


    IF l_discount_incl_terminated THEN
       OPEN  l_fee_csr_incl_terminated (p_chr_id, p_line_id );
       FETCH l_fee_csr_incl_terminated INTO l_Asset_roll_fees_amt;
       CLOSE l_fee_csr_incl_terminated;
    ELSE
       OPEN  l_fee_csr( p_chr_id, p_line_id );
       FETCH l_fee_csr INTO l_Asset_roll_fees_amt;
       CLOSE l_fee_csr;
    END IF;

    l_Asset_roll_fees_amt := nvl(l_Asset_roll_fees_amt,0);

    RETURN l_Asset_roll_fees_amt;

    EXCEPTION

        WHEN OTHERS THEN
            IF l_fee_csr_incl_terminated%ISOPEN THEN
               CLOSE l_fee_csr_incl_terminated;
            END IF;
            IF l_fee_csr%ISOPEN THEN
               CLOSE l_fee_csr;
            END IF;

                Okl_Api.SET_MESSAGE(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
            RETURN NULL;

  END Total_Asset_Rollover_Fee_Amt;


END Okl_Seeded_Functions_Pvt;

/
