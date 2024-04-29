--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_STREAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_STREAMS_PVT" AS
/* $Header: OKLRPSRB.pls 120.46.12010000.2 2009/12/04 08:43:01 rgooty ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.STREAMS';
  L_DEBUG_ENABLED VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator
--|         : 10-08-04 GKADARKA  -- Fixes for bug 3909261    -Start                  |

 G_WF_EVT_KHR_GEN_STRMS CONSTANT VARCHAR2(61) := 'oracle.apps.okl.la.lease_contract.stream_generation_completed';
 G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(15) := 'CONTRACT_ID';
 G_WF_ITM_CONTRACT_PROCESS CONSTANT VARCHAR2(20) := 'CONTRACT_PROCESS';
--|         : 10-08-04 GKADARKA  -- Fixes for bug 3909261    -Start                  |

 --Added by kthiruva on 11-Nov-2005 for the VR build
 --Bug 4726209 - Start of Changes
 G_MINUS_ONE        CONSTANT NUMBER := -1;
 G_MINUS_THREE      CONSTANT NUMBER := -3;
 G_MINUS_SIX        CONSTANT NUMBER := -6;
 G_MINUS_TWELVE     CONSTANT NUMBER := -12;
 --Bug 4726209 - End of Changes

FUNCTION Format_Number
    (p_amount 	   IN NUMBER,
     p_contract_id IN NUMBER)
  RETURN NUMBER
  AS
    l_rounding_rule VARCHAR2(30);
    l_rounded_amount NUMBER := 0;
    l_currency_code  VARCHAR2(30);
    l_precision	NUMBER;
    l_pos_dot NUMBER;
    l_to_add NUMBER := 1;
-- modify this parameter to apply rounding to the amount
	l_apply_rounding_rule BOOLEAN := FALSE;
CURSOR rule_cur IS
SELECT ael_rounding_rule
FROM OKL_SYS_ACCT_OPTS;
CURSOR currency_cur IS
SELECT currency_code
FROM okc_k_headers_v
WHERE id = p_contract_id;
CURSOR prec_cur (l_currency_code VARCHAR2) IS
SELECT precision
FROM fnd_currencies_vl
WHERE currency_code = l_currency_code
AND enabled_flag = 'Y'
AND NVL(start_date_active, SYSDATE) <= SYSDATE
AND NVL(end_date_active, SYSDATE) >= SYSDATE;
BEGIN
l_rounded_amount := p_amount;
FOR rule_rec IN rule_cur LOOP
  l_rounding_rule := rule_rec.ael_rounding_rule;
END LOOP;
FOR currency_rec IN currency_cur LOOP
  l_currency_code := currency_rec.currency_code;
END LOOP;
FOR prec_rec IN prec_cur (l_currency_code) LOOP
  l_precision := prec_rec.precision;
END LOOP;
   IF( l_apply_rounding_rule = TRUE )
   THEN
	   IF (l_rounding_rule = 'UP') THEN
	      l_pos_dot := INSTR(TO_CHAR(p_amount),'.') ;
		  IF (l_pos_dot > 0) AND (SUBSTR(p_amount, l_pos_dot + l_precision+1, 1) IS NOT NULL) THEN
		        FOR i IN 1..l_precision	 LOOP
		          l_to_add := l_to_add/10;
		        END LOOP;
		       l_rounded_amount := p_amount + l_to_add;
		  ELSE
		          l_rounded_amount := p_amount;

		  END IF;
		  l_rounded_amount := TRUNC(l_rounded_amount,l_precision );
	   ELSIF l_rounding_rule = 'DOWN' THEN
		 l_rounded_amount := TRUNC(p_amount, l_precision);
	   ELSIF  l_rounding_rule = 'NEAREST' THEN
		 l_rounded_amount := ROUND(p_amount, l_precision );
	   END IF;
   ELSE
      l_rounded_amount := TRUNC(l_rounded_amount,l_precision );
   END IF;
   RETURN l_rounded_amount;
EXCEPTION
    WHEN OTHERS THEN
	  RETURN TO_NUMBER(NULL);
END Format_Number;
  FUNCTION calculate_present_value(p_future_amount    IN NUMBER,
                                   p_discount_rate    IN NUMBER,
                                   p_periods_per_year IN NUMBER,
                                   p_total_periods    IN NUMBER
  )
  RETURN NUMBER
  AS
    l_temp_amount NUMBER;
    l_denominator NUMBER := 1;
    l_present_value NUMBER;
    l_counter NUMBER;
  BEGIN
    l_temp_amount := 1 + p_discount_rate / p_periods_per_year;
	l_denominator := POWER(l_temp_amount, p_total_periods);
    l_present_value := p_future_amount / l_denominator;
    RETURN l_present_value;
  EXCEPTION
    WHEN OTHERS THEN
	  RETURN TO_NUMBER(NULL);
  END calculate_present_value;
-- added to generate SECURITY DEPOSIT streams
-- akjain 08-10-2002
   PROCEDURE GEN_SEC_DEP_STRMS(p_api_version      IN     NUMBER
                                   ,p_init_msg_list      IN     VARCHAR2
								   ,p_khr_id             IN NUMBER
                                   ,p_transaction_number IN NUMBER
								   ,p_reporting_streams  IN VARCHAR2
                                   ,x_return_status      OUT NOCOPY VARCHAR2
                                   ,x_msg_count          OUT NOCOPY NUMBER
                                   ,x_msg_data           OUT NOCOPY VARCHAR2)
   IS
     cursor k_line_id_csr(p_khr_id NUMBER) is
	 select cle.id kle_id
     from
	   okc_k_headers_b chr,
	   okc_k_lines_b cle,
       okc_line_styles_b lse,
       okc_k_items cim,
	   okl_strm_type_b sty
     where
            chr.id = p_khr_id
     and    chr.id = cle.dnz_chr_id
	 and    cle.lse_id = lse.id
     and    lse.lty_code = 'FEE'
     and    cim.cle_id = cle.id
     and    cim.dnz_chr_id = cle.dnz_chr_id
     and    sty.code        = 'SECURITY DEPOSIT'
     and    cim.object1_id1 = sty.id;
     cursor rule_grp_csr(p_khr_id NUMBER, p_kle_id NUMBER) is
	 SELECT
      KHRB.ID                CHR_ID,
      KHRB.CONTRACT_NUMBER   CONTRACT_NUMBER,
      KLIN.ID                SERVICE_FEE_ID,
      CRLB.OBJECT1_ID1       STY_ID,
      CRGB.ID                RULE_GROUP_ID,
      CRLB.ID                SLH_ID
    FROM
      OKC_K_HEADERS_B KHRB,
      OKC_RULE_GROUPS_B CRGB,
      OKC_RULES_B CRLB,
      OKC_K_LINES_V KLIN,
	  OKL_STRM_TYPE_B STYB
    WHERE
	  KHRB.ID                               = p_khr_id
      AND CRGB.DNZ_CHR_ID                   = KHRB.ID
      AND CRGB.RGD_CODE                     = 'LALEVL'
      AND CRLB.RULE_INFORMATION_CATEGORY    = 'SLH'
      AND CRLB.RGP_ID                       = CRGB.ID
      AND KLIN.ID                           = p_kle_id
      AND CRGB.CLE_ID                       = KLIN.ID
	  AND STYB.CODE                         = 'SECURITY DEPOSIT'
	  AND STYB.ID                           = CRLB.OBJECT1_ID1;
    cursor rules_csr( rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                            rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                            chrId NUMBER,
							slh_id NUMBER
                            )
	IS
    SELECT CRLB.ID SLL_ID,
           CRLB.OBJECT1_ID1,
           CRLB.RULE_INFORMATION1,
           CRLB.RULE_INFORMATION2,
           CRLB.RULE_INFORMATION3,
           CRLB.RULE_INFORMATION5,

           CRLB.RULE_INFORMATION6,
           CRLB.RULE_INFORMATION10
    FROM   OKC_RULE_GROUPS_B CRGB,
           OKC_RULES_B CRLB
    WHERE  CRGB.ID = slh_id
	       AND CRLB.RGP_ID = CRGB.ID
           AND CRGB.RGD_CODE = RGCODE
           AND CRLB.RULE_INFORMATION_CATEGORY = RLCAT
           AND CRGB.DNZ_CHR_ID = CHRID
    ORDER BY CRLB.RULE_INFORMATION1;
    l_kle_id NUMBER;
    l_slh_id NUMBER;
	l_sty_id NUMBER;
	l_stmv_rec               stmv_rec_type;
    l_selv_tbl               selv_tbl_type;
    x_stmv_rec               stmv_rec_type;
    x_selv_tbl               selv_tbl_type;
    dummy_selv_tbl           selv_tbl_type;
	l_frequency              VARCHAR2(40);
	l_number_of_periods      NUMBER;
	l_amount                 NUMBER;
	l_arrear_yn             VARCHAR2(30);
	l_date_start             DATE;
    l_months_per_period      NUMBER := 1;
	l_num_of_adv_payments    NUMBER;
	i                        NUMBER;
	j                        NUMBER := 0;
	k                        NUMBER ;
   BEGIN
   FOR k_line_id_data_csr in k_line_id_csr(p_khr_id)
   LOOP
	 l_kle_id :=    k_line_id_data_csr.kle_id;
	 -- select the Rule Group ID ( SLH_ID) for SERVICE AND MAINTAINCE LINE
     FOR rule_grp_data_csr in rule_grp_csr(p_khr_id, l_kle_id)
	 LOOP
       l_slh_id := rule_grp_data_csr.RULE_GROUP_ID;
       -- populate the header record
       l_stmv_rec.sty_id                 :=  rule_grp_data_csr.STY_ID;
       l_stmv_rec.khr_id                 :=  p_khr_id;
	   l_stmv_rec.kle_id                 :=  rule_grp_data_csr.SERVICE_FEE_ID;
       l_stmv_rec.sgn_code               :=  G_STREAM_GENERATOR_MANL;
       l_stmv_rec.say_code               :=  G_STREAM_ACTIVITY_WORK;
       l_stmv_rec.active_yn              :=  G_STREAM_ACTIVE_YN;
       l_stmv_rec.date_working           :=  SYSDATE  ;
       l_stmv_rec.transaction_number     :=  p_transaction_number;
       l_stmv_rec.comments    := null;
       -- smahapat 11/10/02 multi-gaap -- addition
	   IF (p_reporting_streams = OKL_API.G_TRUE)
	   THEN
	     l_stmv_rec.purpose_code := G_PURPOSE_CODE_REPORT;
	   END IF;
       -- smahapat addition end

	   FOR rules_data_csr in rules_csr('LALEVL', 'SLL', p_khr_id, l_slh_id)
	   LOOP
  	     IF( rules_data_csr.RULE_INFORMATION2 IS NOT NULL and rules_data_csr.RULE_INFORMATION2 <> OKL_API.G_MISS_CHAR)
		 THEN
           -- Get all the Rules for this rule group
           l_frequency           := rules_data_csr.object1_id1 ;
	       l_date_start          := FND_DATE.CANONICAL_TO_DATE(rules_data_csr.RULE_INFORMATION2);
	       l_number_of_periods   := TO_NUMBER(rules_data_csr.RULE_INFORMATION3) ;
	       l_amount              := TO_NUMBER(rules_data_csr.RULE_INFORMATION6) ;
           l_arrear_yn          := NVL(rules_data_csr.RULE_INFORMATION10, 'N');
		   l_num_of_adv_payments := TO_NUMBER(rules_data_csr.RULE_INFORMATION5) ;
           -- if the payments are in ARREAR then adjust the start date
	  	   IF(l_frequency = 'A')
		   THEN
		     l_months_per_period := 12;
		   ELSIF(l_frequency = 'S')
		   THEN
  		     l_months_per_period := 6;
		   ELSIF(l_frequency = 'Q')
		   THEN
  		     l_months_per_period := 3;
		   ELSIF(l_frequency = 'M')
		   THEN
  		     l_months_per_period := 1;
		   END IF ;
	       IF(l_arrear_yn = 'N')
	       THEN
	         l_date_start          :=  l_date_start;
	       ELSE
   	         l_date_start := ADD_MONTHS(l_date_start, l_months_per_period);
	       END IF;
	       -- expand the Payment Levels into Streams
	       FOR i in 1..l_number_of_periods
	       LOOP
	         j := j + 1;
             IF(i = 1)
		     THEN
		       l_selv_tbl(j).stream_element_date := l_date_start;
		     ELSE
		       l_selv_tbl(j).stream_element_date := ADD_MONTHS(l_selv_tbl(j - 1).stream_element_date, l_months_per_period);
		     END IF;
 		     l_selv_tbl(j).amount                := l_amount;
             l_selv_tbl(j).se_line_number        := j;
             k := i;
	       END LOOP;
		   -- modify the payment amounts based on number of advance payments

		   IF(l_num_of_adv_payments IS NOT NULL)
		   THEN
		     IF(l_num_of_adv_payments = 1)
		     THEN
		       l_selv_tbl(j - k + 1).amount := l_selv_tbl(j - k + 1).amount * 2;
               --  last payment should be 0
               l_selv_tbl(j).amount := 0;
		     ELSIF(l_num_of_adv_payments = 2)
		     THEN
   		       l_selv_tbl(j - k + 1).amount := l_selv_tbl(j - k + 1).amount * 3;
               -- last 2 payments should be 0
               l_selv_tbl(j -1).amount := 0;
               l_selv_tbl(j).amount := 0;
		     ELSIF(l_num_of_adv_payments = 3)
		     THEN
   		       l_selv_tbl(j - k + 1).amount := l_selv_tbl(j - k + 1).amount * 4;
               -- last 3 payments should be 0
               l_selv_tbl(j - 2).amount := 0;
               l_selv_tbl(j - 1).amount := 0;
			   l_selv_tbl(j ).amount    := 0;
		     END IF;
		   END IF;
	     END IF;
       END LOOP;
-- Start of wraper code generated automatically by Debug code generator for Okl_Streams_Pub.create_streams
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call Okl_Streams_Pub.create_streams ');
    END;
  END IF;
       Okl_Streams_Pub.create_streams(p_api_version
                                     ,p_init_msg_list
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data
                                     ,l_stmv_rec
                                     ,l_selv_tbl
                                     ,x_stmv_rec
                                     ,x_selv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call Okl_Streams_Pub.create_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Streams_Pub.create_streams
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_ERROR;
       END IF;
	 END LOOP;
	END LOOP;
     EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
       x_return_status := G_RET_STS_ERROR;
       OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
       OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
     WHEN OTHERS THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
       OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
   END   GEN_SEC_DEP_STRMS;

-- Added procedure to resolve Bug #  2389224
-- Procedure to calculate Streams for the Service lines of a contract
 PROCEDURE GEN_SERV_MAIN_LINE_STRMS(p_api_version      IN     NUMBER
                                   ,p_init_msg_list      IN     VARCHAR2
								   ,p_khr_id             IN NUMBER
                                   ,p_transaction_number IN NUMBER
								   ,p_reporting_streams  IN VARCHAR2
                                   ,x_return_status      OUT NOCOPY VARCHAR2
                                   ,x_msg_count          OUT NOCOPY NUMBER
                                   ,x_msg_data           OUT NOCOPY VARCHAR2)
   IS
     cursor rule_grp_csr(p_khr_id NUMBER) is
	 SELECT
      KHRB.ID                CHR_ID,
      KHRB.CONTRACT_NUMBER   CONTRACT_NUMBER,
      KLIN.ID                SERVICE_FEE_ID,
      CRLB.OBJECT1_ID1       STY_ID,
      CRGB.ID                RULE_GROUP_ID,
      CRLB.ID                SLH_ID
    FROM
      OKC_K_HEADERS_B KHRB,
      OKC_RULE_GROUPS_B CRGB,
      OKC_RULES_B CRLB,
      OKC_K_LINES_V KLIN,
      OKC_LINE_STYLES_V LSTL
    WHERE
	  KHRB.ID                               = p_khr_id
      AND CRGB.DNZ_CHR_ID                   = KHRB.ID
      AND CRGB.RGD_CODE                     = 'LALEVL'
      AND CRLB.RULE_INFORMATION_CATEGORY    = 'SLH'
      AND CRLB.RGP_ID                       = CRGB.ID
      AND CRGB.CLE_ID                       = KLIN.ID
      AND KLIN.LSE_ID                       = LSTL.ID
      AND LSTL.LTY_CODE                     = 'SOLD_SERVICE'
      --smahapat 03/04/03 bug 2823581
      AND KLIN.STS_CODE IN ('PASSED','COMPLETE');
    cursor rules_csr( rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                            rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                            chrId NUMBER,
							slh_id NUMBER
                            )
	IS
    SELECT CRLB.ID SLL_ID,
           CRLB.OBJECT1_ID1,
           CRLB.RULE_INFORMATION1,

           CRLB.RULE_INFORMATION2,
           CRLB.RULE_INFORMATION3,
           CRLB.RULE_INFORMATION5,
           CRLB.RULE_INFORMATION6,
           CRLB.RULE_INFORMATION10
    FROM   OKC_RULE_GROUPS_B CRGB,
           OKC_RULES_B CRLB
    WHERE  CRGB.ID = slh_id
	       AND CRLB.RGP_ID = CRGB.ID
           AND CRGB.RGD_CODE = RGCODE
           AND CRLB.RULE_INFORMATION_CATEGORY = RLCAT
           AND CRGB.DNZ_CHR_ID = CHRID
    ORDER BY CRLB.RULE_INFORMATION1;
    l_slh_id NUMBER;
	l_sty_id NUMBER;
	l_stmv_rec               stmv_rec_type;
    l_selv_tbl               selv_tbl_type;
    x_stmv_rec               stmv_rec_type;
    x_selv_tbl               selv_tbl_type;
    dummy_selv_tbl           selv_tbl_type;
	l_frequency              VARCHAR2(40);
	l_number_of_periods      NUMBER;
	l_amount                 NUMBER;
	l_arrear_yn             VARCHAR2(30);
	l_date_start             DATE;
    l_months_per_period      NUMBER := 1;
	l_num_of_adv_payments    NUMBER;
	i                        NUMBER;
	j                        NUMBER := 0;
	k                        NUMBER ;
   BEGIN
     -- select the Rule Group ID ( SLH_ID) for SERVICE AND MAINTAINCE LINE
     FOR rule_grp_data_csr in rule_grp_csr(p_khr_id)
	 LOOP
       l_slh_id := rule_grp_data_csr.RULE_GROUP_ID;
       -- populate the header record
       l_stmv_rec.sty_id                 :=  rule_grp_data_csr.STY_ID;
       l_stmv_rec.khr_id                 :=  p_khr_id;
	   l_stmv_rec.kle_id                 :=  rule_grp_data_csr.SERVICE_FEE_ID;
       l_stmv_rec.sgn_code               :=  G_STREAM_GENERATOR_MANL;
       l_stmv_rec.say_code               :=  G_STREAM_ACTIVITY_WORK;
       l_stmv_rec.active_yn              :=  G_STREAM_ACTIVE_YN;
       l_stmv_rec.date_working           :=  SYSDATE  ;
       l_stmv_rec.transaction_number     :=  p_transaction_number;
       l_stmv_rec.comments    := null;
       -- smahapat 11/10/02 multi-gaap -- addition
	   IF (p_reporting_streams = OKL_API.G_TRUE)
	   THEN
	     l_stmv_rec.purpose_code := G_PURPOSE_CODE_REPORT;
	   END IF;
       -- smahapat addition end

	   FOR rules_data_csr in rules_csr('LALEVL', 'SLL', p_khr_id, l_slh_id)
	   LOOP
  	     IF( rules_data_csr.RULE_INFORMATION2 IS NOT NULL and rules_data_csr.RULE_INFORMATION2 <> OKL_API.G_MISS_CHAR)
		 THEN
           -- Get all the Rules for this rule group
           l_frequency           := rules_data_csr.object1_id1 ;
	       l_date_start          := FND_DATE.CANONICAL_TO_DATE(rules_data_csr.RULE_INFORMATION2);
	       l_number_of_periods   := TO_NUMBER(rules_data_csr.RULE_INFORMATION3) ;
	       l_amount              := TO_NUMBER(rules_data_csr.RULE_INFORMATION6) ;
           l_arrear_yn          := NVL(rules_data_csr.RULE_INFORMATION10, 'N');
		   l_num_of_adv_payments := TO_NUMBER(rules_data_csr.RULE_INFORMATION5) ;
           -- if the payments are in ARREAR then adjust the start date
	  	   IF(l_frequency = 'A')
		   THEN
		     l_months_per_period := 12;
		   ELSIF(l_frequency = 'S')
		   THEN
  		     l_months_per_period := 6;
		   ELSIF(l_frequency = 'Q')
		   THEN
  		     l_months_per_period := 3;
		   ELSIF(l_frequency = 'M')
		   THEN
  		     l_months_per_period := 1;
		   END IF ;
	       IF(l_arrear_yn = 'N')
	       THEN
	         l_date_start          :=  l_date_start;
	       ELSE
   	         l_date_start := ADD_MONTHS(l_date_start, l_months_per_period);
	       END IF;
               -- Bug#2821088 BAKUCHIB Start
               l_selv_tbl.delete;
               j := 0;
               -- Bug#2821088 BAKUCHIB End
	       -- expand the Payment Levels into Streams
	       FOR i in 1..l_number_of_periods
	       LOOP
	         j := j + 1;
             IF(i = 1)
		     THEN
		       l_selv_tbl(j).stream_element_date := l_date_start;
		     ELSE
		       l_selv_tbl(j).stream_element_date := ADD_MONTHS(l_selv_tbl(j - 1).stream_element_date, l_months_per_period);
		     END IF;
 		     l_selv_tbl(j).amount                := l_amount;
             l_selv_tbl(j).se_line_number        := j;

             k := i;
	       END LOOP;
		   -- modify the payment amounts based on number of advance payments
		   IF(l_num_of_adv_payments IS NOT NULL)
		   THEN
		     IF(l_num_of_adv_payments = 1)
		     THEN
		       l_selv_tbl(j - k + 1).amount := l_selv_tbl(j - k + 1).amount * 2;
               --  last payment should be 0
               l_selv_tbl(j).amount := 0;
		     ELSIF(l_num_of_adv_payments = 2)
		     THEN
   		       l_selv_tbl(j - k + 1).amount := l_selv_tbl(j - k + 1).amount * 3;
               -- last 2 payments should be 0
               l_selv_tbl(j -1).amount := 0;
               l_selv_tbl(j).amount := 0;
		     ELSIF(l_num_of_adv_payments = 3)
		     THEN
   		       l_selv_tbl(j - k + 1).amount := l_selv_tbl(j - k + 1).amount * 4;
               -- last 3 payments should be 0
               l_selv_tbl(j - 2).amount := 0;
               l_selv_tbl(j - 1).amount := 0;
			   l_selv_tbl(j ).amount    := 0;
		     END IF;
		   END IF;
	     END IF;
       END LOOP;
-- Start of wraper code generated automatically by Debug code generator for Okl_Streams_Pub.create_streams
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call Okl_Streams_Pub.create_streams ');
    END;
  END IF;
       Okl_Streams_Pub.create_streams(p_api_version
                                     ,p_init_msg_list
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data
                                     ,l_stmv_rec
                                     ,l_selv_tbl
                                     ,x_stmv_rec
                                     ,x_selv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call Okl_Streams_Pub.create_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Streams_Pub.create_streams
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_ERROR;
       END IF;
	 END LOOP;
     EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
       x_return_status := G_RET_STS_ERROR;
       OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
       OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
     WHEN OTHERS THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
       OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
   END GEN_SERV_MAIN_LINE_STRMS;
PROCEDURE PROCESS_STREAM_RESULTS(p_api_version        IN     NUMBER
                                ,p_init_msg_list      IN     VARCHAR2
	                            ,p_transaction_number IN     NUMBER
                                ,x_return_status      OUT    NOCOPY VARCHAR2
                                ,x_msg_count          OUT    NOCOPY NUMBER
                                ,x_msg_data           OUT    NOCOPY VARCHAR2)
IS
  l_api_name          CONSTANT VARCHAR2(40) := 'PROCESS_STREAM_RESULTS';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_row_count         NUMBER;
  l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_stmv_rec          stmv_rec_type;
  l_selv_tbl          selv_tbl_type;
  lx_selv_tbl         selv_tbl_type;
  x_stmv_rec          stmv_rec_type;

  x_selv_tbl          selv_tbl_type;
  dummy_selv_tbl      selv_tbl_type;
  l_khr_yields_rec    Okl_la_Stream_Pvt.yields_rec_type;
  l_khr_id            VARCHAR2(240);
  l_strm_type_id      OKL_STRM_TYPE_V.ID%TYPE;
  i                   NUMBER := 0;
  j                   NUMBER := 0;
  p_line_number       NUMBER := 1;
  p_first_line_number NUMBER := 1;
  l_yield_data_flag   NUMBER := 0;
  lp_sifv_rec          OKL_STREAM_INTERFACES_PUB.SIFV_REC_TYPE;
  lx_sifv_rec          OKL_STREAM_INTERFACES_PUB.SIFV_REC_TYPE;
  l_sirv_rec           sirv_rec_type;
  p_sirv_rec           sirv_rec_type;
  l_no_data_found BOOLEAN := FALSE;
  l_exception_data_found BOOLEAN := FALSE;
  l_comments         VARCHAR2(4000) := NULL;
  l_msg_text  fnd_new_messages.MESSAGE_TEXT%TYPE;
  l_error_message_line VARCHAR2(4000) := NULL;
  l_error_message_tbl  LOG_MSG_TBL_TYPE;
  l_message_count NUMBER := 0;
--  l_formatted_amount NUMBER := 0;
  p_deal_type     VARCHAR2(30);
  l_security_deposit_amt NUMBER;

  x_pre_tax_irr NUMBER; --smahapat bugfix# 2790695

  CURSOR stream_data_csr(p_trx_number NUMBER)
  IS
-- contract level bare minimum streams
SELECT
    STREAM_TYPE.CODE,
    RETURN_STREAMS.SEQUENCE_NUMBER,
    RETURN_STREAMS.SRE_DATE,
    RETURN_STREAMS.AMOUNT,
    RETURN_STREAMS.INDEX_NUMBER ASSET_INDEX_NUMBER,
    STREAM_TYPE.ID stream_type_id,
    HEADER.KHR_ID,
    TO_NUMBER(NULL) KLE_ID
FROM
  OKL_SIF_RET_STRMS RETURN_STREAMS,
  OKL_SIF_RETS RETURN_HEADER,
  OKL_STRM_TYPE_B STREAM_TYPE,
  OKL_STREAM_INTERFACES HEADER
WHERE
  RETURN_HEADER.id  = RETURN_STREAMS.sir_id
AND RETURN_HEADER.transaction_number  =p_trx_number
AND RETURN_STREAMS.stream_type_name = STREAM_TYPE.CODE
AND HEADER.transaction_number = p_trx_number
AND HEADER.transaction_number = RETURN_HEADER.transaction_number
AND RETURN_STREAMS.index_number IS NULL
AND SYSDATE BETWEEN STREAM_TYPE.START_DATE AND NVL(STREAM_TYPE.END_DATE, SYSDATE)
UNION ALL
-- contract level fees
  SELECT distinct
    STREAM_TYPE.CODE,
    RETURN_STREAMS.SEQUENCE_NUMBER,
    RETURN_STREAMS.SRE_DATE,
    RETURN_STREAMS.AMOUNT,
    RETURN_STREAMS.INDEX_NUMBER ASSET_INDEX_NUMBER,
    STREAM_TYPE.ID stream_type_id,
    HEADER.KHR_ID,
-- added akjain 06-13-2002
-- select kle_fee_id as well from the OKL_SIF_FEES table
    FEES.KLE_ID KLE_ID
--    TO_NUMBER(NULL)
  FROM
    OKL_STRM_TYPE_B STREAM_TYPE,
    OKL_SIF_RET_STRMS RETURN_STREAMS,
    OKL_SIF_RETS RETURN_HEADER,
    OKL_STREAM_INTERFACES HEADER,
--    OKL_SIF_LINES LINES,
    OKL_SIF_FEES  FEES
  WHERE
    RETURN_HEADER.transaction_number  = p_trx_number
  AND
     RETURN_HEADER.id  = RETURN_STREAMS.sir_id
    AND
  RETURN_STREAMS.stream_type_name = STREAM_TYPE.CODE
  AND RETURN_STREAMS.index_number = FEES.fee_index_number
  AND
        FEES.SIL_ID IS NULL
  --Modified by kthiruva on 05-May-2005 for the backporting of mainline bug 4294425
  --Start of Changes
  --AND FEES.DESCRIPTION = RETURN_STREAMS.STREAM_TYPE_NAME
  --End of Changes
--srsreeni Bug 5890437 start
 -- added for bug # 2498794
-- AND (FEES.LEVEL_INDEX_NUMBER = 0 OR (FEES.LEVEL_INDEX_NUMBER IS NULL OR FEES.SFE_TYPE = 'SFO'))
--srsreeni Bug 5890437 end
 AND
        FEES.sif_id = 	HEADER.id
    AND
    HEADER.transaction_number = p_trx_number
   AND HEADER.transaction_number = RETURN_HEADER.transaction_number
    AND SYSDATE BETWEEN STREAM_TYPE.START_DATE AND NVL(STREAM_TYPE.END_DATE, SYSDATE)
  -- Added by kthiruva on 05-May-2005 for the backporting of mainline Bug 4294425
  -- Start of Changes
     AND EXISTS(
      SELECT 1
      FROM
            OKL_SIF_STREAM_TYPES REQUESTED_STREAMS
      WHERE
             REQUESTED_STREAMS.sfe_id = fees.id
      AND REQUESTED_STREAMS.sil_id is NULL
      AND stream_type.id = REQUESTED_STREAMS.sty_id
      AND HEADER.ID = REQUESTED_STREAMS.sif_id ) --dkagrawa added for bug# 4638281
  --End of Changes
UNION ALL
-- asset level streams
  SELECT distinct
    STREAM_TYPE.CODE,
    RETURN_STREAMS.SEQUENCE_NUMBER,
    RETURN_STREAMS.SRE_DATE,
    RETURN_STREAMS.AMOUNT,
    RETURN_STREAMS.INDEX_NUMBER ASSET_INDEX_NUMBER,
    STREAM_TYPE.ID stream_type_id,
    HEADER.KHR_ID,

    LINES.KLE_ID  KLE_ID
  FROM
    OKL_STRM_TYPE_B STREAM_TYPE,
    OKL_SIF_RET_STRMS RETURN_STREAMS,
    OKL_SIF_RETS RETURN_HEADER,
    OKL_STREAM_INTERFACES HEADER,
    OKL_SIF_LINES LINES,
    OKL_SIF_FEES  FEES
  WHERE
    RETURN_HEADER.transaction_number  = p_trx_number
  AND
     RETURN_HEADER.id  = RETURN_STREAMS.sir_id
 --Modified by kthiruva on 12-May-2005 for Streams Performance
 --Bug 4346646 - Start of changes
 AND FEES.DESCRIPTION = STREAM_TYPE.CODE
 --Bug 4346646 - End of Changes
 AND RETURN_STREAMS.index_number =  FEES.fee_index_number
 AND FEES.DESCRIPTION = RETURN_STREAMS.STREAM_TYPE_NAME
  AND
        FEES.SIL_ID = LINES.ID
    AND
    HEADER.transaction_number = p_trx_number
    AND  HEADER.transaction_number = RETURN_HEADER.transaction_number
  AND
	  LINES.SIF_ID = 	HEADER.ID
    AND SYSDATE BETWEEN STREAM_TYPE.START_DATE AND NVL(STREAM_TYPE.END_DATE, SYSDATE)
     AND EXISTS(
      SELECT 1
      FROM
            OKL_SIF_STREAM_TYPES REQUESTED_STREAMS
      WHERE
             REQUESTED_STREAMS.sfe_id = fees.id
      AND stream_type.id = REQUESTED_STREAMS.sty_id
      AND HEADER.ID = REQUESTED_STREAMS.sif_id
      AND ( REQUESTED_STREAMS.sil_id IS NULL OR LINES.ID = REQUESTED_STREAMS.sil_id )
      )
-- added for bare Asset level streams
UNION ALL
SELECT distinct
      STREAM_TYPE.CODE,
      RETURN_STREAMS.SEQUENCE_NUMBER,
      RETURN_STREAMS.SRE_DATE,
      RETURN_STREAMS.AMOUNT,
      RETURN_STREAMS.INDEX_NUMBER ASSET_INDEX_NUMBER,
      STREAM_TYPE.ID stream_type_id,
      HEADER.KHR_ID,
      LINES.KLE_ID  KLE_ID
    FROM
      OKL_STRM_TYPE_B STREAM_TYPE,
      OKL_SIF_RET_STRMS RETURN_STREAMS,
      OKL_SIF_RETS RETURN_HEADER,
      OKL_STREAM_INTERFACES HEADER,
      OKL_SIF_LINES LINES
    WHERE
     RETURN_HEADER.transaction_number  = p_trx_number
    AND
     HEADER.transaction_number = p_trx_number
    AND HEADER.transaction_number = RETURN_HEADER.transaction_number
    AND
      LINES.SIF_ID =         HEADER.ID
    AND
       RETURN_HEADER.id  = RETURN_STREAMS.sir_id
    AND
       RETURN_STREAMS.stream_type_name = STREAM_TYPE.CODE
    --Added by RGOOTY for bug 9004849
    AND
       STREAM_TYPE.STREAM_TYPE_PURPOSE <> 'ESTIMATED_PROPERTY_TAX'
    --end RGOOTY
    AND
       RETURN_STREAMS.index_number =  LINES.index_number
    AND
       SYSDATE BETWEEN STREAM_TYPE.START_DATE AND NVL(STREAM_TYPE.END_DATE, SYSDATE)
and exists(
select 1
from
          OKL_SIF_STREAM_TYPES REQUESTED_STREAMS
where
           REQUESTED_STREAMS.sil_id = lines.id
and REQUESTED_STREAMS.sfe_id is NULL
and stream_type.id = REQUESTED_STREAMS.sty_id)
--Added by RGOOTY for bug 9004849
--Estimated Property Tax streams
UNION ALL
SELECT distinct
      STREAM_TYPE.CODE,
      RETURN_STREAMS.SEQUENCE_NUMBER,
      RETURN_STREAMS.SRE_DATE,
      RETURN_STREAMS.AMOUNT,
      LINES.INDEX_NUMBER ASSET_INDEX_NUMBER,
      STREAM_TYPE.ID stream_type_id,
      HEADER.KHR_ID,
      LINES.KLE_ID  KLE_ID
    FROM
      OKL_STRM_TYPE_B STREAM_TYPE,
      OKL_SIF_RET_STRMS RETURN_STREAMS,
      OKL_SIF_RETS RETURN_HEADER,
      OKL_STREAM_INTERFACES HEADER,
      OKL_SIF_LINES LINES,
      OKL_SIF_FEES  FEES
    WHERE
     RETURN_HEADER.transaction_number  = p_trx_number
    AND
     HEADER.transaction_number = p_trx_number
    AND HEADER.transaction_number = RETURN_HEADER.transaction_number
    AND
      LINES.SIF_ID =         HEADER.ID
    AND
       RETURN_HEADER.id  = RETURN_STREAMS.sir_id
    AND
       RETURN_STREAMS.stream_type_name = STREAM_TYPE.CODE
    AND
       STREAM_TYPE.STREAM_TYPE_PURPOSE = 'ESTIMATED_PROPERTY_TAX'
    AND
       RETURN_STREAMS.index_number =  FEES.FEE_index_number
    AND
       FEES.SIL_ID = LINES.ID
    AND
       STREAM_TYPE.STREAM_TYPE_PURPOSE = FEES.DESCRIPTION
    AND
       SYSDATE BETWEEN STREAM_TYPE.START_DATE AND NVL(STREAM_TYPE.END_DATE, SYSDATE)
and exists(
select 1
from
          OKL_SIF_STREAM_TYPES REQUESTED_STREAMS
where
           REQUESTED_STREAMS.sil_id = lines.id
and REQUESTED_STREAMS.sfe_id is NULL
and stream_type.id = REQUESTED_STREAMS.sty_id)
--end RGOOTY for bug 9004849
   -- Begin mansrini for Bug 5111058 (Fwd port Bug 5061024)
   -- This query will pick the primary streams of purpose Subsidy
   UNION ALL
     SELECT distinct
       STREAM_TYPE.CODE,
       RETURN_STREAMS.SEQUENCE_NUMBER,
       RETURN_STREAMS.SRE_DATE,
       RETURN_STREAMS.AMOUNT,
       RETURN_STREAMS.INDEX_NUMBER ASSET_INDEX_NUMBER,
       STREAM_TYPE.ID stream_type_id,
       HEADER.KHR_ID,

       LINES.KLE_ID  KLE_ID
     FROM
       OKL_STRM_TYPE_B STREAM_TYPE,
       OKL_SIF_RET_STRMS RETURN_STREAMS,
       OKL_SIF_RETS RETURN_HEADER,
       OKL_STREAM_INTERFACES HEADER,
       OKL_SIF_LINES LINES,
       OKL_SIF_FEES  FEES
     WHERE
        RETURN_HEADER.transaction_number  = p_trx_number
     AND
        RETURN_HEADER.id  = RETURN_STREAMS.sir_id
     AND
        RETURN_STREAMS.index_number =  FEES.fee_index_number
     AND
        FEES.SIL_ID = LINES.ID
     AND
        HEADER.transaction_number = RETURN_HEADER.transaction_number
     AND
        LINES.SIF_ID =     HEADER.ID
     AND
        STREAM_TYPE.CODE = RETURN_STREAMS.STREAM_TYPE_NAME
     AND
        STREAM_TYPE.STREAM_TYPE_PURPOSE = 'SUBSIDY'
     AND
        SYSDATE BETWEEN STREAM_TYPE.START_DATE AND NVL(STREAM_TYPE.END_DATE, SYSDATE)
     AND EXISTS(
         SELECT 1
         FROM
               OKL_SIF_STREAM_TYPES REQUESTED_STREAMS
         WHERE
                REQUESTED_STREAMS.sfe_id = fees.id
         AND stream_type.id = REQUESTED_STREAMS.sty_id
         AND HEADER.ID = REQUESTED_STREAMS.sif_id
         AND (REQUESTED_STREAMS.sil_id IS NULL OR LINES.ID = REQUESTED_STREAMS.sil_id)
         )
   -- end mansrini for Bug 5111058 (Fwd port Bug 5061024)

    ORDER BY  stream_type_id, ASSET_INDEX_NUMBER, kle_id;
-- added order by to resolve Asset Mapping
-- modified order by for Bug # 2403426
  CURSOR yield_data_csr(p_trx_number NUMBER) IS
  SELECT
    YIELD_NAME,
    EFFECTIVE_PRE_TAX_YIELD,
	EFFECTIVE_AFTER_TAX_YIELD,
	NOMINAL_PRE_TAX_YIELD,
	NOMINAL_AFTER_TAX_YIELD,
    IMPLICIT_INTEREST_RATE
  FROM
    OKL_SIF_RETS
  WHERE
    transaction_number = p_trx_number;
-- define cursor to check any Exceptions in the Inbound Interface Tables
CURSOR exception_data_csr(p_trx_number NUMBER)
  IS
  SELECT
  SRMB.ID,
  SRMB.ERROR_CODE,
  SRMB.ERROR_MESSAGE,
  SRMB.TAG_NAME,
  SRMB.TAG_ATTRIBUTE_NAME,
  SRMB.TAG_ATTRIBUTE_VALUE,
  SRMB.DESCRIPTION
  FROM
  OKL_SIF_RETS SIRB,
  OKL_SIF_RET_ERRORS SRMB
  WHERE
  SIRB.TRANSACTION_NUMBER = p_trx_number
  AND
  SIRB.ID = SRMB.SIR_ID;
-- cursor to update transaction status in the OKL_STREAM_INTERFACES table
    CURSOR sif_data_csr (p_transaction_number                 IN NUMBER) IS
    SELECT

            ID,
			ORP_CODE,
		        LOG_FILE,
		        SECURITY_DEPOSIT_AMOUNT
      FROM Okl_Stream_Interfaces
     WHERE okl_stream_interfaces.transaction_number = p_transaction_number;
    CURSOR sirv_data_csr (p_trnsaction_numner                 IN NUMBER) IS
    SELECT
            ID,
            TRANSACTION_NUMBER,
            SRT_CODE,
            EFFECTIVE_PRE_TAX_YIELD,
            YIELD_NAME,
            INDEX_NUMBER,
            EFFECTIVE_AFTER_TAX_YIELD,
            NOMINAL_PRE_TAX_YIELD,
            NOMINAL_AFTER_TAX_YIELD,
			STREAM_INTERFACE_ATTRIBUTE01,
			STREAM_INTERFACE_ATTRIBUTE02,
			STREAM_INTERFACE_ATTRIBUTE03,
			STREAM_INTERFACE_ATTRIBUTE04,
			STREAM_INTERFACE_ATTRIBUTE05,
			STREAM_INTERFACE_ATTRIBUTE06,
			STREAM_INTERFACE_ATTRIBUTE07,
			STREAM_INTERFACE_ATTRIBUTE08,
			STREAM_INTERFACE_ATTRIBUTE09,
			STREAM_INTERFACE_ATTRIBUTE10,
			STREAM_INTERFACE_ATTRIBUTE11,
			STREAM_INTERFACE_ATTRIBUTE12,
			STREAM_INTERFACE_ATTRIBUTE13,
			STREAM_INTERFACE_ATTRIBUTE14,
   			STREAM_INTERFACE_ATTRIBUTE15,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            IMPLICIT_INTEREST_RATE,
            DATE_PROCESSED,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE
      FROM Okl_Sif_Rets
     WHERE okl_sif_rets.transaction_number   = p_trnsaction_numner;
-- smahapat 11/10/02 multi-gaap -- addition
  CURSOR reporting_streams_csr(p_trx_number NUMBER) IS
  SELECT purpose_code
    FROM okl_stream_interfaces
	WHERE transaction_number = p_trx_number;

   CURSOR reporting_product_csr(p_trx_number NUMBER) IS
   SELECT c.reporting_pdt_id
     FROM okl_k_headers a, okl_stream_interfaces b, okl_products_v c
         WHERE b.transaction_number = p_trx_number
         AND a.id = b.khr_id
         AND c.id = a.pdt_id;
   reporting_product_rec reporting_product_csr%ROWTYPE;

  lx_pdt_parameter_rec  pdt_param_rec_type;
  l_pdtv_rec pdtv_rec_type;
  lx_no_data_found BOOLEAN;

CURSOR chk_for_subsidy_csr(p_trx_number NUMBER) IS
SELECT
'1'
FROM
  OKL_SIF_FEES SFEB,
  OKL_STREAM_INTERFACES SIFB
WHERE
  SIFB.ID = SFEB.SIF_ID AND
  transaction_number = p_trx_number AND
  SFE_TYPE = 'SFB' ORDER BY FEE_INDEX_NUMBER;

  l_reporting_streams VARCHAR2(1) := OKL_API.G_FALSE;
  l_process_yn VARCHAR2(1) := OKL_API.G_TRUE;
  l_chk_subsidy VARCHAR2(1) := 'x';
-- smahapat addition end
  yield_csr           yield_data_csr%ROWTYPE;
  stream_csr          stream_data_csr%ROWTYPE;
  --first_stream_rec    stream_data_csr%ROWTYPE;
  exception_data      exception_data_csr%ROWTYPE;

  l_msg_index_out NUMBER;
  -- Bug 4196515: Start
  CURSOR get_org_id(p_chr_id  okc_k_headers_b.id%TYPE)
  IS
    SELECT authoring_org_id,
           currency_code
    FROM okc_k_headers_b
    WHERE id = p_chr_id;

  CURSOR get_precision(p_currency_code OKC_K_HEADERS_B.CURRENCY_CODE%TYPE)
  IS
      SELECT PRECISION
      FROM fnd_currencies_vl
      WHERE currency_code = p_currency_code
        AND enabled_flag = 'Y'
        AND NVL(start_date_active, SYSDATE) <= SYSDATE
        AND NVL(end_date_active, SYSDATE) >= SYSDATE;

  CURSOR get_rounding_rule
  IS
      SELECT stm_rounding_rule
      FROM OKL_SYS_ACCT_OPTS;

  CURSOR get_rnd_diff_lookup(p_lookup_type  fnd_lookups.lookup_type%TYPE)
  IS
    SELECT b.stm_apply_rounding_difference
    FROM fnd_lookups a,
         OKL_SYS_ACCT_OPTS b
    WHERE a.lookup_type = p_lookup_type
    AND a.lookup_code = b.stm_apply_rounding_difference;

  --Added by KTHIRUVA for ESG Performance Imporvement on 03-May-2005
  --Bug 4346646 - Start of Changes
  CURSOR SERVICE_LINES_EXIST(P_KHR_ID OKC_K_HEADERS_B.ID%TYPE)
  IS
  SELECT 1
  FROM OKC_K_HEADERS_B KHR,
       OKC_K_LINES_B CLE,
       OKC_LINE_STYLES_B LSE
  WHERE CLE.CHR_ID = KHR.ID
  AND  KHR.ID = p_khr_id
  AND  CLE.LSE_ID = LSE.ID
  AND  LSE.LTY_CODE IN ('SOLD_SERVICE','LINK_SERV_ASSET');

  l_service_line_found  NUMBER;
  --Bug 4346646 - End of Changes

  l_org_id              okc_k_headers_b.authoring_org_id%TYPE;
  l_currency_code       okc_k_headers_b.currency_code%TYPE;
  l_diff_lookup_code    fnd_lookups.lookup_code%TYPE;
  l_precision           NUMBER;
  l_rounding_rule    okl_sys_acct_opts.ael_rounding_rule%TYPE;
  l_first_rec CHAR := 'T';

  G_RND_DIFF_LOOKUP_TYPE   CONSTANT fnd_lookups.lookup_type%TYPE := 'OKL_STRM_APPLY_ROUNDING_DIFF';
  G_NO_MATCH_REC           CONSTANT VARCHAR2(30) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_COL_NAME_TOKEN         CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  -- Bug 4196515: End

  --Added by kthiruva on 15-May-2005 for Streams Performance
  --Bug 4346646-Start of Changes
  l_stmv_tbl          stmv_tbl_type;
  x_stmv_tbl          stmv_tbl_type;
  full_selv_tbl            selv_tbl_type;
  l_selv_count             NUMBER;
  k                        NUMBER;
  --Bug 4346646-End of Changes

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
   --Added by kthiruva for Debugging
   L_DEBUG_ENABLED := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Transaction number is :'||p_transaction_number);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside procedure process_stream_results');
   END IF;


  l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => 'OKL_PROCESS_STREAMS_PVT',
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PVT',
                                              x_return_status  => l_return_status);
  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  END IF;

  x_return_status := G_RET_STS_SUCCESS;
  --Before Processing Stream Results check for any exceptions in the Inbound Interface Tables
  FOR exception_data in exception_data_csr(p_transaction_number)
  LOOP
    IF(l_message_count = 0)
    THEN
       l_error_message_line :=   'REQUEST ID = '  || p_transaction_number || ' TIME PROCESSED = '|| to_char(SYSDATE,'YYYYMMDD HH24MISS');
       l_error_message_line :=   l_error_message_line || G_NEW_LINE;
       l_error_message_line :=   l_error_message_line || 'Errors returned from Pricing Engine :-  ';
       l_error_message_line :=   l_error_message_line || G_NEW_LINE;
       l_error_message_line :=   l_error_message_line || 'ERROR CODE    :: ' ||  exception_data.ERROR_CODE;
       l_error_message_line :=   l_error_message_line || G_NEW_LINE;
       l_error_message_line :=   l_error_message_line || 'ERROR MESSAGE :: ' || exception_data.ERROR_MESSAGE;
       l_error_message_line :=   l_error_message_line || G_NEW_LINE;
       l_error_message_line :=   l_error_message_line || 'XML TAG       :: ' ||  exception_data.TAG_NAME ;
       l_error_message_line :=   l_error_message_line || G_NEW_LINE;
       l_message_count := l_message_count + 1;
    ELSE
       l_error_message_line := NULL;
       l_error_message_line :=   l_error_message_line || 'ERROR CODE    :: ' ||  exception_data.ERROR_CODE;
       l_error_message_line :=   l_error_message_line || G_NEW_LINE;
       l_error_message_line :=   l_error_message_line || 'ERROR MESSAGE :: ' || exception_data.ERROR_MESSAGE;
       l_error_message_line :=   l_error_message_line || G_NEW_LINE;
       l_error_message_line :=   l_error_message_line || 'XML TAG       :: ' ||  exception_data.TAG_NAME ;
       l_error_message_line :=   l_error_message_line || G_NEW_LINE;
       -- Not used in this release
       /*

       l_error_message_line :=   l_error_message_line || 'XML TAG ATTRIBUTE :: ' ||  exception_data.TAG_ATTRIBUTE_NAME  ;
       l_error_message_line :=   l_error_message_line || G_NEW_LINE;
       l_error_message_line :=   l_error_message_line || 'XML TAG ATTRIBUTE VALUE  :: ' ||  exception_data.TAG_ATTRIBUTE_VALUE ;
       l_error_message_line :=   l_error_message_line || G_NEW_LINE;
      l_error_message_line :=   l_error_message_line || 'DETAILS :: ' ||  exception_data.DESCRIPTION ;
      l_error_message_line :=   l_error_message_line || G_NEW_LINE;
      */
      l_message_count := l_message_count + 1;
    END IF;
    l_error_message_tbl(l_message_count) :=   l_error_message_line;
  END LOOP;

  IF(   l_message_count > 0)
  THEN
	l_exception_data_found := TRUE;
    FND_MESSAGE.SET_NAME ( G_APP_NAME, 'OKL_STREAM_GENERATION_ERROR');
    FND_MESSAGE.SET_TOKEN(TOKEN => 'FILE_NAME',
                          VALUE => 'OKLSTXMLG_' || p_transaction_number || '.log',
                          TRANSLATE => TRUE);
    l_msg_text  := FND_MESSAGE.GET;
    l_comments :=  l_msg_text;
    l_error_message_tbl(l_message_count + 1) :=   'End Errors returned from Pricing Engine'  ;

    OKL_STREAMS_UTIL.LOG_MESSAGE(p_msgs_tbl => l_error_message_tbl,
                                 p_translate => G_FALSE,
                                 p_file_name => 'OKLSTXMLG_' || p_transaction_number || '.log' ,
             		          	 x_return_status => l_return_status );
  ELSE
    l_comments :=  NULL;
  END IF;

  FOR reporting_streams_data IN reporting_streams_csr(p_transaction_number)
  LOOP
    IF (reporting_streams_data.purpose_code = G_PURPOSE_CODE_REPORT)
	THEN
	  l_reporting_streams := OKL_API.G_TRUE;
	END IF;
  END LOOP;

    -- Bug 4196515: Start
    -- Making sure that no records are present
    i := 0;
    l_selv_tbl := dummy_selv_tbl;
    l_stmv_rec := NULL;
    l_khr_id := NULL;
    FOR stream_csr IN stream_data_csr(p_transaction_number)
	LOOP
       -- Checking whether if this rec is the first rec.
       IF( l_first_rec = 'T' )
       THEN
           l_stmv_rec.sty_id        :=  stream_csr.stream_type_id;
           l_stmv_rec.khr_id        :=  stream_csr.khr_id;
           l_stmv_rec.kle_id        :=  stream_csr.kle_id;
           l_stmv_rec.sgn_code      :=  G_STREAM_GENERATOR;
           l_stmv_rec.say_code      :=  G_STREAM_ACTIVITY_WORK;
           l_stmv_rec.active_yn     :=  G_STREAM_ACTIVE_YN;
           l_stmv_rec.date_working  :=  SYSDATE  ;
           l_stmv_rec.comments      :=  l_comments   ;
           IF (l_reporting_streams = OKL_API.G_TRUE)
           THEN
            	l_stmv_rec.purpose_code := G_PURPOSE_CODE_REPORT;
           END IF;
           l_khr_id := TO_CHAR(stream_csr.khr_id);
           l_stmv_rec.transaction_number     :=  p_transaction_number;

           --Added by kthiruva on 15-May-2005 for Streams Performance
           --Bug 4346646 - Start of Changes
           i := i + 1;
           l_stmv_tbl(i) := l_stmv_rec ;
           --Bug 4346646 - End of Changes

           -- Got the First Record, change the Flag
           l_first_rec := 'F';
       END IF;

       IF (l_stmv_rec.sty_id = stream_csr.stream_type_id AND (l_stmv_rec.kle_id IS NULL OR l_stmv_rec.kle_id =  stream_csr.kle_id))
       THEN
           -- populate the child records
           j := j + 1;
           l_selv_tbl(j).stream_element_date := stream_csr.sre_date;
    	   l_selv_tbl(j).amount := stream_csr.amount;
    	   l_selv_tbl(j).se_line_number := p_line_number;
           --Added by kthiruva on 15-May-2005 for Streams Performance
           --Bug 4346646 - Start of Changes
           l_selv_tbl(j).parent_index := i;
           --Bug 4346646 - End of Changes
           p_line_number := p_line_number + 1;
        ELSE
             -- call the insert API for STREAMS
             IF(IS_DEBUG_PROCEDURE_ON) THEN
                BEGIN
                    OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call Okl_Streams_Pub.create_streams ');
                END;
              END IF;

             --Modified by kthiruva for Streams Performance on 15-May-2005
             --Bug 4346646 - Start of Changes

             --Obtaining the values of the system options that need to be passed to the rounding call
             okl_streams_util.get_acc_options(   p_khr_id         => l_khr_id,
                                x_org_id         => l_org_id,
                                x_precision      => l_precision,
                                x_currency_code  => l_currency_code,
                                x_rounding_rule  => l_rounding_rule,
                                x_apply_rnd_diff => l_diff_lookup_code,
                                x_return_status  => x_return_status );

              IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE G_EXCEPTION_ERROR;
              END IF;

              x_return_status := Okl_Streams_Util.round_streams_amount_esg(p_api_version   => p_api_version,
                                                    p_init_msg_list  => p_init_msg_list,
                                                    x_msg_count      => x_msg_count,
                                                    x_msg_data       => x_msg_data,
                                                    p_chr_id         => l_khr_id,
                                                    p_selv_tbl       => l_selv_tbl,
                                                    x_selv_tbl       => lx_selv_tbl,
                                                    p_org_id         => l_org_id,
                                                    p_precision      => l_precision,
                                                    p_currency_code  => l_currency_code,
                                                    p_rounding_rule  => l_rounding_rule,
                                                    p_apply_rnd_diff => l_diff_lookup_code);
              IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE G_EXCEPTION_ERROR;
              END IF;

              -- This call basically accepts the stream element table returned by the rounding procedure
              -- and accumulates all the stream elements in full_selv_tbl that is passed to the create streams call
              okl_streams_util.accumulate_strm_elements(p_stm_index_no => null,
                                       p_selv_tbl       => lx_selv_tbl,
                                       x_full_selv_tbl  => full_selv_tbl,
                                       x_return_status  => x_return_status
                                       );

              IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE G_EXCEPTION_ERROR;
              END IF;

              --Bug 4346646 - End of Changes

              IF(IS_DEBUG_PROCEDURE_ON) THEN
                BEGIN
                    OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call Okl_Streams_Pub.create_streams ');
                END;
              END IF;

              j := 1 ;
              l_selv_tbl := dummy_selv_tbl;
              -- populate the header record
        	  l_stmv_rec.sty_id     :=  stream_csr.stream_type_id;
              l_stmv_rec.khr_id     :=  stream_csr.khr_id;
              l_stmv_rec.kle_id     :=  stream_csr.kle_id;
              l_stmv_rec.sgn_code   :=  G_STREAM_GENERATOR;
              l_stmv_rec.say_code   :=  G_STREAM_ACTIVITY_WORK;
              l_stmv_rec.active_yn  :=  G_STREAM_ACTIVE_YN;
         	  l_stmv_rec.date_working           := SYSDATE  ;
              l_stmv_rec.transaction_number     :=  p_transaction_number;
              l_stmv_rec.comments    := l_comments;
              --Added by kthiruva on 15-May-2005 for Streams Performance
              --Bug 4346646 - Start of Changes
              i := i + 1;
              l_stmv_tbl(i) := l_stmv_rec ;
              --Bug 4346646 - End of Changes

              -- smahapat 11/10/02 multi-gaap -- addition
    	      IF (l_reporting_streams = OKL_API.G_TRUE)
    	      THEN
    	        l_stmv_rec.purpose_code := G_PURPOSE_CODE_REPORT;
    	      END IF;
              -- smahapat addition end
              -- populate the first line of this header record
              l_selv_tbl(j).stream_element_date := stream_csr.sre_date;
    	      l_selv_tbl(j).amount := stream_csr.amount;
              --Added by kthiruva on 15-May-2005 for Streams Performance
              --Bug 4346646 - Start of Changes
              l_selv_tbl(j).parent_index := i;
              --Bug 4346646 - End of Changes
              l_selv_tbl(j).se_line_number := p_first_line_number;
              p_line_number := p_first_line_number + 1;
        END IF;
    END LOOP;
    -- insert the last record from the CURSOR
    -- Start of wraper code generated automatically by Debug code generator for Okl_Streams_Pub.create_streams
    IF( l_khr_id IS NOT NULL )
    THEN
      IF(IS_DEBUG_PROCEDURE_ON) THEN
            BEGIN
                OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call Okl_Streams_Pub.create_streams ');
            END;
      END IF;

     --Modified by kthiruva on 15-May-2005 for Streams Performance
     --Bug 4346646 - Start of Changes

     --Added by kthiruva for Debug Logging
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to Okl_Streams_Util.round_streams_amount_esg');
     END IF;
     --Making the round amount call for the stream elements of the last stream header
      x_return_status := Okl_Streams_Util.round_streams_amount_esg(p_api_version   => p_api_version,
                                                    p_init_msg_list  => p_init_msg_list,
                                                    x_msg_count      => x_msg_count,
                                                    x_msg_data       => x_msg_data,
                                                    p_chr_id         => l_khr_id,
                                                    p_selv_tbl       => l_selv_tbl,
                                                    x_selv_tbl       => lx_selv_tbl,
                                                    p_org_id         => l_org_id,
                                                    p_precision      => l_precision,
                                                    p_currency_code  => l_currency_code,
                                                    p_rounding_rule  => l_rounding_rule,
                                                    p_apply_rnd_diff => l_diff_lookup_code);

     --Added by kthiruva for Debug Logging
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Streams_Util.round_streams_amount_esg, return status is :'||x_return_status);
     END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_ERROR;
       END IF;

      --Accumulating the stream elements of the last stream header to the existing full_selv_tbl
      okl_streams_util.accumulate_strm_elements(p_stm_index_no => null,
                               p_selv_tbl       => lx_selv_tbl,
                               x_full_selv_tbl  => full_selv_tbl,
                               x_return_status  => x_return_status
                               );
     --Added by kthiruva for Debug Logging
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Streams_Util.accumulate_strm_elements, return status is :'||x_return_status);
     END IF;

      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_ERROR;
      END IF;

      --Calling the new method that accepts a table of stream headers and a table of stream elements
      -- Bulk insert calls are made for both the stream headers and stream elements.
       Okl_Streams_Pub.create_streams_perf(p_api_version
                                              ,p_init_msg_list
                                              ,x_return_status
                                              ,x_msg_count
                                              ,x_msg_data
                                              ,l_stmv_tbl -- arajagop changed
                                              ,full_selv_tbl --satya changed 10/17/03
                                              ,x_stmv_tbl
                                              ,x_selv_tbl);
     --Bug 4346646 - End of Changes
      --Added by kthiruva for Debug Logging
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Streams_Pub.create_streams_perf, return status is :'||x_return_status);
     END IF;


      IF(IS_DEBUG_PROCEDURE_ON) THEN
            BEGIN
                OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call Okl_Streams_Pub.create_streams ');
            END;
      END IF;
      -- End of wraper code generated automatically by Debug code generator for Okl_Streams_Pub.create_streams
      IF (x_return_status = G_RET_STS_UNEXP_ERROR)
      THEN
                RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = G_RET_STS_ERROR)
      THEN
                RAISE G_EXCEPTION_ERROR;
      END IF;

      OPEN chk_for_subsidy_csr(p_transaction_number);
      FETCH chk_for_subsidy_csr INTO l_chk_subsidy;
      CLOSE chk_for_subsidy_csr;
      --Added by kthiruva for Debug Logging
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Value of l_chk_subsidy is :'||l_chk_subsidy);
      END IF;

      -- TODO : check what yield has to be assigned
      -- Update Yields at contract header
      FOR yield_csr IN   yield_data_csr(p_transaction_number)
      LOOP
        l_yield_data_flag := 1;
        -- assign the value of implicit_interest_rate :Only exactly 1 record will have value of implicit_interest_rate
        IF (l_chk_subsidy = '1')
          THEN
          --  YIELD NAMES ARE HARD CODED HERE , NEED TO VERIFY WITH THE RETURNING YIELDS NAMES FROM ST
      	  IF(yield_csr.yield_name = 'PTIRRWS' )
    	  THEN
    		l_khr_yields_rec.PRE_TAX_IRR :=   yield_csr.effective_pre_tax_yield;
		IF(yield_csr.implicit_interest_rate IS NOT NULL)
                THEN
                     l_khr_yields_rec.implicit_interest_rate :=  yield_csr.implicit_interest_rate;
                 END IF;
          ELSIF(yield_csr.yield_name = 'NATWS')
          THEN
            l_khr_yields_rec.AFTER_TAX_IRR :=   yield_csr.effective_pre_tax_yield;
          ELSIF(yield_csr.yield_name = 'BookingWS')
    	  THEN
    	    l_khr_yields_rec.AFTER_TAX_YIELD :=   yield_csr.effective_pre_tax_yield;
            l_khr_yields_rec.PRE_TAX_YIELD :=   NULL;
          ELSIF(yield_csr.yield_name = 'PTIRR' )
    	  THEN
    		l_khr_yields_rec.SUB_PRE_TAX_IRR :=   yield_csr.effective_pre_tax_yield;
		IF(yield_csr.implicit_interest_rate IS NOT NULL)
                THEN
                   l_khr_yields_rec.sub_impl_interest_rate :=   yield_csr.IMPLICIT_INTEREST_RATE;
                END IF;
          ELSIF(yield_csr.yield_name = 'NAT')
          THEN
            l_khr_yields_rec.SUB_AFTER_TAX_IRR :=   yield_csr.effective_pre_tax_yield;
          ELSIF(yield_csr.yield_name = 'Booking')
    	  THEN
    	    l_khr_yields_rec.SUB_AFTER_TAX_YIELD :=   yield_csr.effective_pre_tax_yield;
            l_khr_yields_rec.PRE_TAX_YIELD :=   NULL;
          END IF;
        ELSE
           IF(yield_csr.implicit_interest_rate IS NOT NULL)
    	  THEN
            l_khr_yields_rec.implicit_interest_rate :=  yield_csr.implicit_interest_rate;
    	  END IF;
          --  YIELD NAMES ARE HARD CODED HERE , NEED TO VERIFY WITH THE RETURNING YIELDS NAMES FROM ST
      	  IF(yield_csr.yield_name = 'PTIRR' )
    	  THEN
    		l_khr_yields_rec.PRE_TAX_IRR :=   yield_csr.effective_pre_tax_yield;
		l_khr_yields_rec.implicit_interest_rate :=  yield_csr.implicit_interest_rate;
    	  ELSIF(yield_csr.yield_name = 'NAT')
          THEN
            l_khr_yields_rec.AFTER_TAX_IRR :=   yield_csr.effective_pre_tax_yield;
          ELSIF(yield_csr.yield_name = 'Booking')
    	  THEN
    	    l_khr_yields_rec.AFTER_TAX_YIELD :=   yield_csr.effective_pre_tax_yield;
            l_khr_yields_rec.PRE_TAX_YIELD :=   NULL;
          END IF;
         END IF;
        END LOOP;
         -- generate streams for the SERVICE LINES
         -- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_STREAMS_PVT.GEN_SERV_MAIN_LINE_STRMS
      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call OKL_PROCESS_STREAMS_PVT.GEN_SERV_MAIN_LINE_STRMS ');
        END;
      END IF;

     --start smahapat bugfix# 2790695
     --Generate accrual streams for service lines
     lx_pdt_parameter_rec := NULL;
     IF (l_reporting_streams = OKL_API.G_TRUE) THEN
              OPEN reporting_product_csr(p_transaction_number);
              FETCH reporting_product_csr INTO reporting_product_rec;
              CLOSE reporting_product_csr;
                 --Added by kthiruva for Debug Logging
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Reporting Product present.Calling OKL_SETUPPRODUCTS_PVT.Getpdt_parameters');
                 END IF;

                 l_pdtv_rec.id := reporting_product_rec.reporting_pdt_id;
                 OKL_SETUPPRODUCTS_PVT.Getpdt_parameters(
                          p_api_version       => p_api_version,
                          p_init_msg_list     => p_init_msg_list,
                          x_return_status     => x_return_status,
                          x_msg_count         => x_msg_count,
                          x_msg_data          => x_msg_data,
                          p_pdtv_rec          => l_pdtv_rec,
                          x_no_data_found     => lx_no_data_found,
                          p_pdt_parameter_rec => lx_pdt_parameter_rec);

                 --Added by kthiruva for Debug Logging
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to OKL_SETUPPRODUCTS_PVT.Getpdt_parameters, return status is :'|| x_return_status);
                 END IF;
                 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
     END IF;

     --Added by kthiruva for ESG Performance Improvement on 03-May-2005
     --Bug 4346646 - Start of Changes
     --This cursordetermines whether there are any Service Lines defined on the contract.
     OPEN SERVICE_LINES_EXIST(l_khr_id);
     FETCH SERVICE_LINES_EXIST INTO l_service_line_found;
     --Make the call to the ISG API to generate Service Line Streams only if service lines
     --are defined on the contract
     IF SERVICE_LINES_EXIST%FOUND THEN
     --Bug 4346646 - End of Changes
         --Added by  kthiruva for Debug Logging
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Service Lines Exist');
         END IF;
         okl_stream_generator_pub.GENERATE_STREAMS(
                                    p_api_version      => p_api_version,
                                    p_init_msg_list    => p_init_msg_list,
                                    p_khr_id           => l_khr_id,
                                    p_compute_irr      => OKL_API.G_FALSE,
                                    p_generation_type  => 'SERVICE_LINES',
                                    p_reporting_book_class => lx_pdt_parameter_rec.deal_type,
                                    x_pre_tax_irr      => x_pre_tax_irr,
                                    x_return_status    => x_return_status,
                                    x_msg_count        => x_msg_count,
                                    x_msg_data         => x_msg_data);
          --Added by kthiruva for Debug Logging
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to okl_stream_generator_pub.GENERATE_STREAMS, return status is :'|| x_return_status);
          END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR)
        THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = G_RET_STS_ERROR)
        THEN
          RAISE G_EXCEPTION_ERROR;
        END IF;
        --end smahapat bugfix# 2790695
    --Bug 4346646 - Start of Changes
	END IF;
	CLOSE SERVICE_LINES_EXIST;
	--Bug 4346646 - End of Changes
         --Added by kthiruva for Debug Logging
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to generating Residual Value streams');
         END IF;
         --Generate accrual streams for residual streams internally
    	 okl_stream_generator_pub.GENERATE_STREAMS(
                                    p_api_version      => p_api_version,
                                    p_init_msg_list    => p_init_msg_list,
                                    p_khr_id           => l_khr_id,
                                    p_compute_irr      => OKL_API.G_FALSE,
                                    p_generation_type  => 'RESIDUAL VALUE',
                                    p_reporting_book_class => lx_pdt_parameter_rec.deal_type,
                                    x_pre_tax_irr      => x_pre_tax_irr,
                                    x_return_status    => x_return_status,
                                    x_msg_count        => x_msg_count,
                                    x_msg_data         => x_msg_data);
          --Added by kthiruva for Debug Logging
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to okl_stream_generator_pub.GENERATE_STREAMS, return status is :'|| x_return_status);
          END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR)
        THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = G_RET_STS_ERROR)
        THEN
          RAISE G_EXCEPTION_ERROR;
        END IF;
        --end Generate accrual streams for residual streams internally

            FOR sif_data in sif_data_csr(p_transaction_number)
            LOOP
              lp_sifv_rec.id := sif_data.id;
              lp_sifv_rec.ORP_CODE := sif_data.ORP_CODE;
        	  l_security_deposit_amt := sif_data.SECURITY_DEPOSIT_AMOUNT;
            END LOOP;
            -- generate SECURITY DEPOSIT Streams
            IF(l_security_deposit_amt IS NOT NULL)
        	THEN
               -- generate streams for the SECURITY DEPOSIT FEES
    -- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_STREAMS_PVT.GEN_SEC_DEP_STRMS
      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call OKL_PROCESS_STREAMS_PVT.GEN_SEC_DEP_STRMS ');
        END;
      END IF;
              --Added by kthiruva for Debug Logging
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Security deposit amount is not null');
              END IF;

              OKL_PROCESS_STREAMS_PVT.GEN_SEC_DEP_STRMS(p_api_version   => p_api_version
                                               ,p_init_msg_list     => p_init_msg_list
          		  	  				  	       ,p_khr_id             => l_khr_id
                                               ,p_transaction_number => p_transaction_number
    										   ,p_reporting_streams  => l_reporting_streams
                                               ,x_return_status      => x_return_status
                                               ,x_msg_count          => x_msg_count
                                               ,x_msg_data           => x_msg_data);
             --Added by kthiruva for Debug Logging
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to OKL_PROCESS_STREAMS_PVT.GEN_SEC_DEP_STRMS, return status is :'|| x_return_status);
             END IF;

      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call OKL_PROCESS_STREAMS_PVT.GEN_SEC_DEP_STRMS ');
        END;
      END IF;
    -- End of wraper code generated automatically by Debug code generator for OKL_PROCESS_STREAMS_PVT.GEN_SEC_DEP_STRMS
          IF (x_return_status = G_RET_STS_UNEXP_ERROR)
          THEN
            RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR)
          THEN
            RAISE G_EXCEPTION_ERROR;
          END IF;
    	END IF;

    --Added by srsreeni for bug 5699923
    -- Invoke the procedure OKL_LA_STREAM_PVT.RECREATE_TMT_LN_STRMS
    -- Streams are no longer requested through Pricing Engine
    -- for TERMINATED LOAN COMPONENTS like FINANCED, ROLLOVER FEE
    -- and LOAN ASSET LINES. Instead, the CURRENT streams are copied
    -- over as WORKING STREAMS. On creating WORKING streams here, the
    -- code after this takes care of HISTORIZING current streams and
    -- making the newly created WORK streams to CURRENT.
    OKL_LA_STREAM_PVT.RECREATE_TMT_LN_STRMS(
            p_api_version     => p_api_version,
            p_init_msg_list   => p_init_msg_list,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_chr_id          => l_khr_id,
            p_trx_number      => p_transaction_number);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    --end srsreeni for bug 5699923

-- Start of wraper code generated automatically by Debug code generator for OKL_LA_STREAM_PVT.process_streams
  IF(IS_DEBUG_PROCEDURE_ON) THEN

    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call OKL_LA_STREAM_PVT.process_streams ');
    END;
  END IF;
    --Added by kthiruva for Debug Logging
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to OKL_LA_STREAM_PVT.process_streams');
    END IF;

	OKL_LA_STREAM_PVT.process_streams(
            p_api_version,
            p_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data,
            l_khr_id,
            l_process_yn,
            l_khr_yields_rec);
     --Added by kthiruva for Debug Logging
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to OKL_LA_STREAM_PVT.process_streams, return status is :'|| x_return_status);
     END IF;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call OKL_LA_STREAM_PVT.process_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_LA_STREAM_PVT.process_streams
/*
    Okl_la_Stream_Pub.update_contract_yields(p_api_version,
                                           p_init_msg_list ,
                                           x_return_status ,
                                           x_msg_count,
                                           x_msg_data,
                                           l_khr_id ,
                                           l_khr_yields_rec);
*/
    IF (x_return_status = G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR)
    THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

-- update the status in the Out bound Interface Tables
	FOR sir_data in sirv_data_csr(p_transaction_number)
	LOOP
      l_sirv_rec.id := sir_data.id;
	  IF(	  l_exception_data_found = TRUE)
	  THEN
	          l_sirv_rec.srt_code := 'PROCESS_COMPLETE_ERRORS';
	  ELSE
         	  l_sirv_rec.srt_code := 'PROCESS_COMPLETE';
	  END IF;
	  l_sirv_rec.date_processed := to_date(to_char(SYSDATE,'YYYYMMDD HH24MISS'), 'YYYYMMDD HH24MISS');
-- Start of wraper code generated automatically by Debug code generator for OKL_SIF_RETS_PUB.update_sif_rets
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call OKL_SIF_RETS_PUB.update_sif_rets ');
    END;
  END IF;
      --Added by kthiruva for Debug Logging
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to OKL_SIF_RETS_PUB.update_sif_rets');
      END IF;
	  OKL_SIF_RETS_PUB.update_sif_rets(p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     x_return_status => l_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_sirv_rec      => l_sirv_rec,
                                     x_sirv_rec      => p_sirv_rec);
     --Added by kthiruva for Debug Logging
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to OKL_SIF_RETS_PUB.update_sif_rets, return status is :'|| x_return_status);
     END IF;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call OKL_SIF_RETS_PUB.update_sif_rets ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_SIF_RETS_PUB.update_sif_rets

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
	  THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
	END LOOP;
    -- update the status in the In bound Interface Tables
    lp_sifv_rec.date_processed := to_date(to_char(SYSDATE,'YYYYMMDD HH24MISS'), 'YYYYMMDD HH24MISS');
    IF( l_exception_data_found = TRUE)
    THEN
      lp_sifv_rec.sis_code := 'PROCESS_COMPLETE_ERRORS';
      lp_sifv_rec.log_file := 'OKLSTXMLG_' || p_transaction_number || '.log ';
    ELSE
      lp_sifv_rec.sis_code := 'PROCESS_COMPLETE';
    END IF;
  -- Start of wraper code generated automatically by Debug code generator for OKL_STREAM_INTERFACES_PUB.update_stream_interfaces
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call OKL_STREAM_INTERFACES_PUB.update_stream_interfaces ');
    END;
  END IF;
    --Added by kthiruva for Debug Logging
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to OKL_STREAM_INTERFACES_PUB.update_stream_interfaces');
    END IF;
    OKL_STREAM_INTERFACES_PUB.update_stream_interfaces(
	                    	        p_api_version => p_api_version
	 	                       ,p_init_msg_list => p_init_msg_list
                     	 	       ,x_return_status => l_return_status
                    	 	       ,x_msg_count => x_msg_count
	 	                           ,x_msg_data => x_msg_data
	 	                           ,p_sifv_rec => lp_sifv_rec
	 	                           ,x_sifv_rec => lx_sifv_rec);
     --Added by kthiruva for Debug Logging
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to OKL_STREAM_INTERFACES_PUB.update_stream_interfaces, return status is :'|| x_return_status);
     END IF;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call OKL_STREAM_INTERFACES_PUB.update_stream_interfaces ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAM_INTERFACES_PUB.update_stream_interfaces
	 	IF l_return_status = G_RET_STS_ERROR THEN
	 		RAISE G_EXCEPTION_ERROR;
	 	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	 		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	 	END IF;

  END IF;
  -- Bug 4196515: Emd

     OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
	  					 x_msg_data	  => x_msg_data);

    EXCEPTION
      WHEN G_EXCEPTION_ERROR
	  THEN
        IF(stream_data_csr%ISOPEN)
	    THEN
	      CLOSE stream_data_csr;
	    END IF;
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF(stream_data_csr%ISOPEN)
	    THEN
	      CLOSE stream_data_csr;
	    END IF;
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
      WHEN OTHERS THEN
        IF(stream_data_csr%ISOPEN)
	    THEN
	      CLOSE stream_data_csr;
	    END IF;
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
END PROCESS_STREAM_RESULTS;
-- INFO:
--  This Procedure updates the SAY_CODE of existing Streams for a Contract to HISTORY from WORKING
-- END INFO
PROCEDURE UPDATE_STREAMS_ACTIVITY(p_api_version        IN     NUMBER
                                 ,p_init_msg_list      IN     VARCHAR2
                                 ,x_return_status      OUT    NOCOPY VARCHAR2
                                 ,x_msg_count          OUT    NOCOPY NUMBER
                                 ,x_msg_data           OUT    NOCOPY VARCHAR2
	                             ,p_khr_id             IN     NUMBER)
IS
  l_api_name          CONSTANT VARCHAR2(40) := 'UPDATE_STREAMS_ACTIVITY';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
  i                   NUMBER;
  stmv_tbl            stmv_tbl_type;
  x_stmv_tbl          stmv_tbl_type;
 CURSOR streams_csr(l_khr_id NUMBER)
 IS
 SELECT
   ID,

   SAY_CODE
 FROM
   OKL_STREAMS_V
 WHERE
   KHR_ID = l_khr_id
 AND
   SAY_CODE = G_STREAM_ACTIVITY_WORK;
   stm_csr      streams_csr%ROWTYPE;
   stm_csr_rec  streams_csr%ROWTYPE;
BEGIN
  x_return_status := G_RET_STS_SUCCESS;
-- populate all the records with new Activity Code
  FOR stm_csr IN streams_csr(p_khr_id ) LOOP
-- Update the activity code to HISTORY
  stmv_tbl(i).id :=    stm_csr.id;
  stmv_tbl(i).say_code :=  G_STREAM_ACTIVITY_HIST ;
  stmv_tbl(i).date_history := SYSDATE;
  END LOOP;
-- call the update for all the records
-- Start of wraper code generated automatically by Debug code generator for Okl_Streams_Pub.update_streams
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call Okl_Streams_Pub.update_streams ');
    END;
  END IF;
  Okl_Streams_Pub.update_streams(l_api_version
                                ,p_init_msg_list
                                ,x_return_status
                                ,x_msg_count
                                ,x_msg_data
                                ,stmv_tbl
                                ,x_stmv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call Okl_Streams_Pub.update_streams ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Streams_Pub.update_streams
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
     x_return_status := G_RET_STS_UNEXP_ERROR;
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
--	  x_msg_data := 'Unexpected Database Error';
END UPDATE_STREAMS_ACTIVITY;
  ------------------------------------------------------------------------------------------
  -- PROCEDURE
  -- Creates a logfile based upon the exceptions found in the inbound interface tables
  -- These exceptions are the ones returned by the Pricing Engine. To understand the logfile
  -- some exposure to XML is a must.
  -- Inputs: p_transaction_number - the id of the transaction
  -- Output: A file by the name 'OKLSTXMLG_1234.log' where 1234 is the id of the transaction
  ------------------------------------------------------------------------------------------
  PROCEDURE GENERATE_ERROR_LOGFILE(p_transaction_number NUMBER
	                               ,x_return_status VARCHAR2
  ) IS
    -- define cursor to check any Exceptions in the Inbound Interface Tables
    CURSOR exception_data_csr(p_trx_number NUMBER) IS
    SELECT
      SRMB.ID,
      SRMB.ERROR_CODE,
      SRMB.ERROR_MESSAGE,
      SRMB.TAG_NAME,
      SRMB.TAG_ATTRIBUTE_NAME,
      SRMB.TAG_ATTRIBUTE_VALUE,
      SRMB.DESCRIPTION
    FROM
      OKL_SIF_RETS SIRB,
      OKL_SIF_RET_ERRORS SRMB
    WHERE
      SIRB.TRANSACTION_NUMBER = p_trx_number
    AND
      SIRB.ID = SRMB.SIR_ID;
    l_message_count NUMBER := 0;
    l_error_message_line VARCHAR2(4000) := NULL;
    l_error_message_tbl  LOG_MSG_TBL_TYPE;
    l_exception_data_found BOOLEAN := FALSE;
    l_msg_text  fnd_new_messages.MESSAGE_TEXT%TYPE;
    l_comments VARCHAR2(4000) := NULL;
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  BEGIN
    FOR exception_data in exception_data_csr(p_transaction_number)
    LOOP
      IF(l_message_count = 0)
      THEN
        l_error_message_line :=   'REQUEST ID = '  || p_transaction_number || ' TIME PROCESSED = '|| to_char(SYSDATE,'YYYYMMDD HH24MISS');

        l_error_message_line :=   l_error_message_line || G_NEW_LINE;
        l_error_message_line :=   l_error_message_line || 'Errors returned from Pricing Engine :-  ';
        l_error_message_line :=   l_error_message_line || G_NEW_LINE;
        l_error_message_line :=   l_error_message_line || 'ERROR CODE    :: ' ||  exception_data.ERROR_CODE;
        l_error_message_line :=   l_error_message_line || G_NEW_LINE;
        l_error_message_line :=   l_error_message_line || 'ERROR MESSAGE :: ' || exception_data.ERROR_MESSAGE;
        l_error_message_line :=   l_error_message_line || G_NEW_LINE;
        l_error_message_line :=   l_error_message_line || 'XML TAG       :: ' ||  exception_data.TAG_NAME ;
        l_error_message_line :=   l_error_message_line || G_NEW_LINE;
        l_message_count := l_message_count + 1;
      ELSE
        l_error_message_line := NULL;
        l_error_message_line :=   l_error_message_line || 'ERROR CODE    :: ' ||  exception_data.ERROR_CODE;
        l_error_message_line :=   l_error_message_line || G_NEW_LINE;
        l_error_message_line :=   l_error_message_line || 'ERROR MESSAGE :: ' || exception_data.ERROR_MESSAGE;
        l_error_message_line :=   l_error_message_line || G_NEW_LINE;
        l_error_message_line :=   l_error_message_line || 'XML TAG       :: ' ||  exception_data.TAG_NAME ;
        l_error_message_line :=   l_error_message_line || G_NEW_LINE;
        -- Not used in this release
        /*
        l_error_message_line :=   l_error_message_line || 'XML TAG ATTRIBUTE :: ' ||  exception_data.TAG_ATTRIBUTE_NAME  ;
        l_error_message_line :=   l_error_message_line || G_NEW_LINE;
        l_error_message_line :=   l_error_message_line || 'XML TAG ATTRIBUTE VALUE  :: ' ||  exception_data.TAG_ATTRIBUTE_VALUE ;
        l_error_message_line :=   l_error_message_line || G_NEW_LINE;
        l_error_message_line :=   l_error_message_line || 'DETAILS :: ' ||  exception_data.DESCRIPTION ;
        l_error_message_line :=   l_error_message_line || G_NEW_LINE;
        */
        l_message_count := l_message_count + 1;
      END IF;
      l_error_message_tbl(l_message_count) :=   l_error_message_line;
    END LOOP;
    IF(   l_message_count > 0)
    THEN
	  l_exception_data_found := TRUE;
      FND_MESSAGE.SET_NAME ( G_APP_NAME, 'OKL_STREAM_GENERATION_ERROR');
      FND_MESSAGE.SET_TOKEN(TOKEN => 'FILE_NAME',
                            VALUE => 'OKLSTXMLG_' || p_transaction_number || '.log',
                            TRANSLATE => TRUE);
      l_msg_text  := FND_MESSAGE.GET;
      l_comments :=  l_msg_text;
	  l_error_message_tbl(l_message_count + 1) :=   'End Errors returned from Pricing Engine'  ;
	  OKL_STREAMS_UTIL.LOG_MESSAGE(p_msgs_tbl => l_error_message_tbl,
                                   p_translate => G_FALSE,
                                   p_file_name => 'OKLSTXMLG_' || p_transaction_number || '.log' ,
                                   x_return_status => l_return_status );
    ELSE
      l_comments :=  NULL;
    END IF;
   END GENERATE_ERROR_LOGFILE;
  ------------------------------------------------------------------------------------------
  -- PROCEDURE
  ------------------------------------------------------------------------------------------
  PROCEDURE UPDATE_STATUSES(p_transaction_number NUMBER
	                       ,x_return_status VARCHAR2
  ) IS
    lp_sirv_rec           sirv_rec_type;
    lx_sirv_rec           sirv_rec_type;
	lx_msg_data VARCHAR2(400);
	lp_api_version NUMBER := 1.0;
	lp_init_msg_list VARCHAR2(1) := 'F';
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_exception_data_found BOOLEAN := FALSE;
	lx_msg_count NUMBER;
    lp_sifv_rec OKL_STREAM_INTERFACES_PUB.SIFV_REC_TYPE;
	lx_sifv_rec	OKL_STREAM_INTERFACES_PUB.SIFV_REC_TYPE;
    CURSOR sirv_data_csr (p_trx_number IN NUMBER) IS
    SELECT
      ID,
      TRANSACTION_NUMBER,
      SRT_CODE,
      EFFECTIVE_PRE_TAX_YIELD,
      YIELD_NAME,
      INDEX_NUMBER,
      EFFECTIVE_AFTER_TAX_YIELD,
      NOMINAL_PRE_TAX_YIELD,
      NOMINAL_AFTER_TAX_YIELD,
	  STREAM_INTERFACE_ATTRIBUTE01,
	  STREAM_INTERFACE_ATTRIBUTE02,
      STREAM_INTERFACE_ATTRIBUTE03,
      STREAM_INTERFACE_ATTRIBUTE04,
	  STREAM_INTERFACE_ATTRIBUTE05,
	  STREAM_INTERFACE_ATTRIBUTE06,
	  STREAM_INTERFACE_ATTRIBUTE07,
	  STREAM_INTERFACE_ATTRIBUTE08,
	  STREAM_INTERFACE_ATTRIBUTE09,
	  STREAM_INTERFACE_ATTRIBUTE10,
	  STREAM_INTERFACE_ATTRIBUTE11,
	  STREAM_INTERFACE_ATTRIBUTE12,
	  STREAM_INTERFACE_ATTRIBUTE13,
	  STREAM_INTERFACE_ATTRIBUTE14,
	  STREAM_INTERFACE_ATTRIBUTE15,
	  OBJECT_VERSION_NUMBER,
	  CREATED_BY,
	  LAST_UPDATED_BY,
	  CREATION_DATE,
	  LAST_UPDATE_DATE,
	  LAST_UPDATE_LOGIN,
	  IMPLICIT_INTEREST_RATE,
	  DATE_PROCESSED,

	  REQUEST_ID,
	  PROGRAM_APPLICATION_ID,
	  PROGRAM_ID,
	  PROGRAM_UPDATE_DATE
    FROM Okl_Sif_Rets
    WHERE okl_sif_rets.transaction_number = p_trx_number;
    CURSOR sif_data_csr (p_transaction_number IN NUMBER) IS
    SELECT
      ID,
	  ORP_CODE,
	  LOG_FILE
    FROM Okl_Stream_Interfaces
    WHERE okl_stream_interfaces.transaction_number = p_transaction_number;
       -- define cursor to check any Exceptions in the Inbound Interface Tables
        CURSOR exception_data_csr(p_trx_number NUMBER) IS
    	SELECT
          SRMB.ID
        FROM
          OKL_SIF_RETS SIRB,
          OKL_SIF_RET_ERRORS SRMB
        WHERE
          SIRB.TRANSACTION_NUMBER = p_trx_number
        AND
          SIRB.ID = SRMB.SIR_ID;
      BEGIN
        --check for errors
    	FOR exception_data in exception_data_csr(p_transaction_number)
    	LOOP
    	  l_exception_data_found := TRUE;
    	  EXIT;
    	END LOOP;
    -- update the status in the Out bound Interface Tables
	FOR sir_data in sirv_data_csr(p_transaction_number)
	LOOP
      lp_sirv_rec.id := sir_data.id;
	  IF(l_exception_data_found = TRUE)
	  THEN
	    lp_sirv_rec.srt_code := 'PROCESS_COMPLETE_ERRORS';
	  ELSE
        lp_sirv_rec.srt_code := 'PROCESS_COMPLETE';
	  END IF;
	  lp_sirv_rec.date_processed := to_date(to_char(SYSDATE,'YYYYMMDD HH24MISS'), 'YYYYMMDD HH24MISS');
-- Start of wraper code generated automatically by Debug code generator for OKL_SIF_RETS_PUB.update_sif_rets
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call OKL_SIF_RETS_PUB.update_sif_rets ');
    END;
  END IF;
      OKL_SIF_RETS_PUB.update_sif_rets(p_api_version   => lp_api_version,
                                       p_init_msg_list => lp_init_msg_list,
                                       x_return_status => l_return_status,
                                       x_msg_count     => lx_msg_count,
                                       x_msg_data      => lx_msg_data,
                                       p_sirv_rec      => lp_sirv_rec,
                                       x_sirv_rec      => lx_sirv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call OKL_SIF_RETS_PUB.update_sif_rets ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_SIF_RETS_PUB.update_sif_rets
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
	END LOOP;
    -- update the status in the In bound Interface Tables
    FOR sif_data in sif_data_csr(p_transaction_number)
    LOOP
      lp_sifv_rec.id := sif_data.id;
      lp_sifv_rec.ORP_CODE := sif_data.ORP_CODE;
    END LOOP;
    lp_sifv_rec.date_processed := to_date(to_char(SYSDATE,'YYYYMMDD HH24MISS'), 'YYYYMMDD HH24MISS');
    IF(l_exception_data_found = TRUE)
    THEN
    --        lp_sifv_rec.sis_code := 'PROCESS_COMPLETE';
      lp_sifv_rec.sis_code := 'PROCESS_COMPLETE_ERRORS';
      lp_sifv_rec.stream_interface_attribute03 := 'OKLSTXMLG_' || p_transaction_number || '.log ';
    ELSE
      lp_sifv_rec.sis_code := 'PROCESS_COMPLETE';
    END IF;
-- Start of wraper code generated automatically by Debug code generator for OKL_STREAM_INTERFACES_PUB.update_stream_interfaces
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call OKL_STREAM_INTERFACES_PUB.update_stream_interfaces ');
    END;
  END IF;
    OKL_STREAM_INTERFACES_PUB.update_stream_interfaces(p_api_version => lp_api_version
                                                      ,p_init_msg_list => lp_init_msg_list
                                                      ,x_return_status => l_return_status
                                                      ,x_msg_count => lx_msg_count
                                                      ,x_msg_data => lx_msg_data
                                                      ,p_sifv_rec => lp_sifv_rec
                                                      ,x_sifv_rec => lx_sifv_rec);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call OKL_STREAM_INTERFACES_PUB.update_stream_interfaces ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_STREAM_INTERFACES_PUB.update_stream_interfaces
    IF l_return_status = G_RET_STS_ERROR THEN
	  RAISE G_EXCEPTION_ERROR;
	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;
  END UPDATE_STATUSES;
    ------------------------------------------------------------------------------------------
    -- PROCEDURE
    ------------------------------------------------------------------------------------------
    PROCEDURE PROCESS_REST_STRM_RESLTS(p_api_version        IN     NUMBER
                                          ,p_init_msg_list      IN     VARCHAR2
  	                                    ,p_transaction_number IN     NUMBER
                                          ,x_return_status      OUT    NOCOPY VARCHAR2
                                          ,x_msg_count          OUT    NOCOPY NUMBER
                                          ,x_msg_data           OUT    NOCOPY VARCHAR2)
    IS
      l_return_status VARCHAR(1) := G_RET_STS_SUCCESS;
      l_api_name          CONSTANT VARCHAR2(40) := 'PROCESS_REST_STRM_RESLTS';
      l_api_version       CONSTANT NUMBER       := 1.0;
  	l_srlv_tbl srlv_tbl_type;
  	l_yields_tbl yields_tbl_type;
  --    l_yields_tbl OKL_CREATE_STREAMS_PUB.csm_yields_tbl_type;
  	l_sir_id NUMBER;
  	i NUMBER;
  	l_chr_id NUMBER;
      l_object1_id1 VARCHAR2(40);
  	CURSOR sirv_data_csr (p_trx_number NUMBER) IS
  	SELECT
  	  ID
  	FROM okl_sif_rets
  	WHERE okl_sif_rets.transaction_number = p_trx_number
  	AND
  	INDEX_NUMBER = 0;
  	CURSOR srlv_data_csr (p_sir_id IN NUMBER) IS
  	SELECT
        ID,
  	  LEVEL_INDEX_NUMBER,
  	  NUMBER_OF_PERIODS,
  	  SIR_ID,
  	  INDEX_NUMBER,
  	  LEVEL_TYPE,
  	  AMOUNT,
  	  ADVANCE_OR_ARREARS,
  	  PERIOD,
  	  LOCK_LEVEL_STEP,
  	  DAYS_IN_PERIOD,
  	  FIRST_PAYMENT_DATE,
  	  STREAM_INTERFACE_ATTRIBUTE1,
  	  STREAM_INTERFACE_ATTRIBUTE2,
  	  STREAM_INTERFACE_ATTRIBUTE3,
  	  STREAM_INTERFACE_ATTRIBUTE4,
  	  STREAM_INTERFACE_ATTRIBUTE5,
  	  STREAM_INTERFACE_ATTRIBUTE6,
  	  STREAM_INTERFACE_ATTRIBUTE7,
  	  STREAM_INTERFACE_ATTRIBUTE8,
  	  STREAM_INTERFACE_ATTRIBUTE9,
  	  STREAM_INTERFACE_ATTRIBUTE10,
  	  STREAM_INTERFACE_ATTRIBUTE11,
  	  STREAM_INTERFACE_ATTRIBUTE12,
  	  STREAM_INTERFACE_ATTRIBUTE13,
  	  STREAM_INTERFACE_ATTRIBUTE14,
  	  STREAM_INTERFACE_ATTRIBUTE15
  	FROM OKL_SIF_RET_LEVELS
  	WHERE SIR_ID = p_sir_id;
  	CURSOR yields_data_csr (p_trx_number NUMBER) IS
  	SELECT
          SIRB.EFFECTIVE_PRE_TAX_YIELD,
  	  SIRB.EFFECTIVE_AFTER_TAX_YIELD,
  	  SIRB.NOMINAL_PRE_TAX_YIELD,
  	  SIRB.NOMINAL_AFTER_TAX_YIELD,
        SIRB.IMPLICIT_INTEREST_RATE,
        SIYB.YIELD_NAME,
        SIYB.METHOD,
  	  SIYB.ARRAY_TYPE,
  	  SIYB.ROE_TYPE,
  	  SIYB.ROE_BASE,
        SIYB.COMPOUNDED_METHOD,
  	  SIYB.TARGET_VALUE,
  	  SIYB.INDEX_NUMBER,
  	  SIYB.NOMINAL_YN,
        SIYB.PRE_TAX_YN
  	FROM OKL_SIF_RETS SIRB, OKL_SIF_YIELDS SIYB, OKL_STREAM_INTERFACES SIFB
  	WHERE SIRB.TRANSACTION_NUMBER = p_trx_number
  	AND SIFB.TRANSACTION_NUMBER = p_trx_number
  	AND SIYB.SIF_ID = SIFB.ID
  	AND SIRB.INDEX_NUMBER = SIYB.INDEX_NUMBER;
  	CURSOR sif_data_csr (p_trx_number NUMBER ) IS
  	SELECT
  	  SIFB.OBJECT1_ID1,
  	  SIFB.KHR_ID
  	FROM
  	  OKL_STREAM_INTERFACES SIFB
  	WHERE

  	  SIFB.TRANSACTION_NUMBER = p_trx_number;
    BEGIN
      l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                                p_pkg_name	   => 'OKL_PROCESS_STREAMS_PVT',
                                                p_init_msg_list  => p_init_msg_list,
                                                l_api_version	   => l_api_version,
                                                p_api_version	   => p_api_version,
                                                p_api_type	   => '_PVT',
                                                x_return_status  => l_return_status);
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
      --Before Processing Stream Results check for any exceptions in the Inbound Interface Tables
  	GENERATE_ERROR_LOGFILE(p_transaction_number => p_transaction_number
  	                      ,x_return_status      => l_return_status);
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
  	FOR sifv_data in sif_data_csr(p_transaction_number)
  	LOOP
  	  l_chr_id := sifv_data.khr_id;
  	  l_object1_id1 := sifv_data.object1_id1;
  	END LOOP;
  	-- fetch records from
  	FOR sirv_data in sirv_data_csr(p_transaction_number)
  	LOOP
  	  l_sir_id := sirv_data.id;
  	END LOOP;
  	i := 1;
  	FOR srlv_data in srlv_data_csr(l_sir_id)
  	LOOP
  	  l_srlv_tbl(i) := null;
        l_srlv_tbl(i).ID := srlv_data.ID;
  	  l_srlv_tbl(i).LEVEL_INDEX_NUMBER := srlv_data.LEVEL_INDEX_NUMBER;
  	  l_srlv_tbl(i).NUMBER_OF_PERIODS := srlv_data.NUMBER_OF_PERIODS;
  	  l_srlv_tbl(i).SIR_ID := srlv_data.SIR_ID;
  	  l_srlv_tbl(i).INDEX_NUMBER := srlv_data.INDEX_NUMBER;
  	  l_srlv_tbl(i).LEVEL_TYPE := srlv_data.LEVEL_TYPE;
  	  l_srlv_tbl(i).AMOUNT := srlv_data.AMOUNT;
  	  l_srlv_tbl(i).ADVANCE_OR_ARREARS := srlv_data.ADVANCE_OR_ARREARS;
  	  l_srlv_tbl(i).PERIOD := srlv_data.PERIOD;
  	  l_srlv_tbl(i).LOCK_LEVEL_STEP := srlv_data.LOCK_LEVEL_STEP;
  	  l_srlv_tbl(i).DAYS_IN_PERIOD := srlv_data.DAYS_IN_PERIOD;
  	  l_srlv_tbl(i).FIRST_PAYMENT_DATE := srlv_data.FIRST_PAYMENT_DATE;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE1 := srlv_data.STREAM_INTERFACE_ATTRIBUTE1;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE2 := srlv_data.STREAM_INTERFACE_ATTRIBUTE2;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE3 := srlv_data.STREAM_INTERFACE_ATTRIBUTE3;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE4 := srlv_data.STREAM_INTERFACE_ATTRIBUTE4;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE5 := srlv_data.STREAM_INTERFACE_ATTRIBUTE5;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE6 := srlv_data.STREAM_INTERFACE_ATTRIBUTE6;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE7 := srlv_data.STREAM_INTERFACE_ATTRIBUTE7;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE8 := srlv_data.STREAM_INTERFACE_ATTRIBUTE8;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE9 := srlv_data.STREAM_INTERFACE_ATTRIBUTE9;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE10 := srlv_data.STREAM_INTERFACE_ATTRIBUTE10;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE11 := srlv_data.STREAM_INTERFACE_ATTRIBUTE11;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE12 := srlv_data.STREAM_INTERFACE_ATTRIBUTE12;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE13 := srlv_data.STREAM_INTERFACE_ATTRIBUTE13;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE14 := srlv_data.STREAM_INTERFACE_ATTRIBUTE14;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE15 := srlv_data.STREAM_INTERFACE_ATTRIBUTE15;
  	  i := i + 1;
  	END LOOP;
  	i := 1;
  	FOR yields_data in yields_data_csr(p_transaction_number)
  	LOOP
  	  l_yields_tbl(i) := null;
  	  l_yields_tbl(i).yield_name := yields_data.yield_name;
  --	  l_yields_tbl(i).yield_name := 'PTIRR';
        l_yields_tbl(i).value := yields_data.effective_pre_tax_yield;
  --	  l_yields_tbl(i).effective_after_tax_yield := yields_data.effective_after_tax_yield;
  --	  l_yields_tbl(i).nominal_pre_tax_yield := yields_data.nominal_pre_tax_yield;
  --	  l_yields_tbl(i).nominal_after_tax_yield := yields_data.nominal_after_tax_yield;
        l_yields_tbl(i).implicit_interest_rate := yields_data.implicit_interest_rate;
        l_yields_tbl(i).method := yields_data.method;
        l_yields_tbl(i).array_type := yields_data.array_type;
        l_yields_tbl(i).roe_type := yields_data.roe_type;
        l_yields_tbl(i).roe_base := yields_data.roe_base;
        l_yields_tbl(i).compounded_method := yields_data.compounded_method;
        l_yields_tbl(i).target_value := yields_data.target_value;
        l_yields_tbl(i).index_number := yields_data.index_number;
        l_yields_tbl(i).nominal_yn := yields_data.nominal_yn;
        l_yields_tbl(i).pre_tax_yn := yields_data.pre_tax_yn;
  	  i := i + 1;
  	END LOOP;
  	-- call the restructure api for processing results
-- Start of wraper code generated automatically by Debug code generator for OKL_AM_RESTRUCTURE_RENTS_PVT.process_results
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call OKL_AM_RESTRUCTURE_RENTS_PVT.process_results ');
    END;
  END IF;
  	 OKL_AM_RESTRUCTURE_RENTS_PVT.process_results(p_api_version         => l_api_version,

  	                                          p_init_msg_list       => p_init_msg_list,
              								  p_generation_context  => 'RSAM',
  	                                          p_jtot_object1_code   => 'OKL_TRX_QUOTES_B',
                       						  p_object1_id1         => l_object1_id1,
  						                      p_chr_id              => l_chr_id,
                      						  p_rent_tbl            => l_srlv_tbl,
  					                    	  p_yield_tbl           => l_yields_tbl,
                        						  x_return_status       => l_return_status,
  						                      x_msg_count           => x_msg_count,
                           					  x_msg_data            => x_msg_data);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call OKL_AM_RESTRUCTURE_RENTS_PVT.process_results ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_AM_RESTRUCTURE_RENTS_PVT.process_results
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
      -- update statuses in the inbound and outbound interface tables
  	UPDATE_STATUSES(p_transaction_number => p_transaction_number
  	                ,x_return_status      => l_return_status);
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
  	x_return_status := l_return_status;
      OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
  						 x_msg_data	  => x_msg_data);
    EXCEPTION
      WHEN G_EXCEPTION_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
  	  				  	 						   p_pkg_name	=> G_PKG_NAME,
  												   p_exc_name   => G_EXC_NAME_ERROR,
  												   x_msg_count	=> x_msg_count,
  												   x_msg_data	=> x_msg_data,
  												   p_api_type	=> '_PVT');
      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
  	  				  	 						   p_pkg_name	=> G_PKG_NAME,
  												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
  												   x_msg_count	=> x_msg_count,
  												   x_msg_data	=> x_msg_data,
  												   p_api_type	=> '_PVT');
      WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
  	  				  	 						   p_pkg_name	=> G_PKG_NAME,
  												   p_exc_name   => G_EXC_NAME_OTHERS,
  												   x_msg_count	=> x_msg_count,
  												   x_msg_data	=> x_msg_data,
  												   p_api_type	=> '_PVT');
    END PROCESS_REST_STRM_RESLTS;
    ------------------------------------------------------------------------------------------
    -- PROCEDURE
    ------------------------------------------------------------------------------------------
    PROCEDURE PROCESS_QUOT_STRM_RESLTS(p_api_version        IN     NUMBER
                                          ,p_init_msg_list      IN     VARCHAR2
  	                                    ,p_transaction_number IN     NUMBER
                                          ,x_return_status      OUT    NOCOPY VARCHAR2
                                          ,x_msg_count          OUT    NOCOPY NUMBER
                                          ,x_msg_data           OUT    NOCOPY VARCHAR2)
    IS
      l_return_status VARCHAR(1) := G_RET_STS_SUCCESS;
      l_api_name          CONSTANT VARCHAR2(40) := 'PROCESS_QUOT_STRM_RESLTS';
      l_api_version       CONSTANT NUMBER       := 1.0;
  	l_srlv_tbl srlv_tbl_type;
  	l_yields_tbl yields_tbl_type;
  	l_sir_id NUMBER;
  	i NUMBER;
  	l_chr_id NUMBER;
  	l_sis_code VARCHAR2(30);
  	l_amount NUMBER;
  	CURSOR sirv_data_csr (p_trx_number NUMBER) IS
  	SELECT
  	  ID
  	FROM okl_sif_rets
  	WHERE okl_sif_rets.transaction_number = p_trx_number
  	AND INDEX_NUMBER = 0;
  	CURSOR srlv_data_csr (p_sir_id IN NUMBER) IS
  	SELECT
        ID,
  	  LEVEL_INDEX_NUMBER,
  	  NUMBER_OF_PERIODS,
  	  SIR_ID,
  	  INDEX_NUMBER,
  	  LEVEL_TYPE,
  	  AMOUNT,
  	  ADVANCE_OR_ARREARS,
  	  PERIOD,
  	  LOCK_LEVEL_STEP,
  	  DAYS_IN_PERIOD,
  	  FIRST_PAYMENT_DATE,
  	  STREAM_INTERFACE_ATTRIBUTE1,
  	  STREAM_INTERFACE_ATTRIBUTE2,
  	  STREAM_INTERFACE_ATTRIBUTE3,
  	  STREAM_INTERFACE_ATTRIBUTE4,

  	  STREAM_INTERFACE_ATTRIBUTE5,
  	  STREAM_INTERFACE_ATTRIBUTE6,
  	  STREAM_INTERFACE_ATTRIBUTE7,
  	  STREAM_INTERFACE_ATTRIBUTE8,
  	  STREAM_INTERFACE_ATTRIBUTE9,
  	  STREAM_INTERFACE_ATTRIBUTE10,
  	  STREAM_INTERFACE_ATTRIBUTE11,
  	  STREAM_INTERFACE_ATTRIBUTE12,
  	  STREAM_INTERFACE_ATTRIBUTE13,
  	  STREAM_INTERFACE_ATTRIBUTE14,
  	  STREAM_INTERFACE_ATTRIBUTE15
  	FROM OKL_SIF_RET_LEVELS
  	WHERE SIR_ID = p_sir_id;
  	CURSOR yields_data_csr (p_trx_number NUMBER) IS
  	SELECT
          SIRB.EFFECTIVE_PRE_TAX_YIELD,
  	  SIRB.EFFECTIVE_AFTER_TAX_YIELD,
  	  SIRB.NOMINAL_PRE_TAX_YIELD,
  	  SIRB.NOMINAL_AFTER_TAX_YIELD,
        SIRB.IMPLICIT_INTEREST_RATE,
        SIYB.YIELD_NAME,
          SIYB.METHOD,
  	  SIYB.ARRAY_TYPE,
  	  SIYB.ROE_TYPE,
  	  SIYB.ROE_BASE,
        SIYB.COMPOUNDED_METHOD,
  	  SIYB.TARGET_VALUE,
  	  SIYB.INDEX_NUMBER,
  	  SIYB.NOMINAL_YN,
        SIYB.PRE_TAX_YN
  	FROM OKL_SIF_RETS SIRB, OKL_SIF_YIELDS SIYB, OKL_STREAM_INTERFACES SIFB
  	WHERE SIRB.TRANSACTION_NUMBER = p_trx_number
  	AND SIFB.TRANSACTION_NUMBER = p_trx_number
  	AND SIYB.SIF_ID = SIFB.ID
  	AND SIRB.INDEX_NUMBER = SIYB.INDEX_NUMBER;
      CURSOR sif_data_csr (p_trx_number NUMBER ) IS
  	SELECT
  	  SIFB.SIS_CODE,
  	  SIFB.KHR_ID
  	FROM
  	  OKL_STREAM_INTERFACES SIFB
  	WHERE
  	  SIFB.TRANSACTION_NUMBER = p_trx_number;
    BEGIN
      l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                                p_pkg_name	   => 'OKL_PROCESS_STREAMS_PVT',
                                                p_init_msg_list  => p_init_msg_list,
                                                l_api_version	   => l_api_version,
                                                p_api_version	   => p_api_version,
                                                p_api_type	   => '_PVT',
                                                x_return_status  => l_return_status);
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
  	FOR sifv_data in sif_data_csr(p_transaction_number)
  	LOOP
  	  l_chr_id := sifv_data.khr_id;
  	  l_sis_code := sifv_data.sis_code;
  	END LOOP;
      --Before Processing Stream Results check for any exceptions in the Inbound Interface Tables
  	GENERATE_ERROR_LOGFILE(p_transaction_number => p_transaction_number
  	                      ,x_return_status      => l_return_status);
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
  	-- fetch records from
  	FOR sirv_data in sirv_data_csr(p_transaction_number)
  	LOOP
  	  l_sir_id := sirv_data.id;
  	END LOOP;
  	i := 1;
  	FOR srlv_data in srlv_data_csr(l_sir_id)
  	LOOP
  	  l_srlv_tbl(i) := null;
        l_srlv_tbl(i).ID := srlv_data.ID;
  	  l_srlv_tbl(i).LEVEL_INDEX_NUMBER := srlv_data.LEVEL_INDEX_NUMBER;
  	  l_srlv_tbl(i).NUMBER_OF_PERIODS := srlv_data.NUMBER_OF_PERIODS;
  	  l_srlv_tbl(i).SIR_ID := srlv_data.SIR_ID;
  	  l_srlv_tbl(i).INDEX_NUMBER := srlv_data.INDEX_NUMBER;
  	  l_srlv_tbl(i).LEVEL_TYPE := srlv_data.LEVEL_TYPE;
  	  -- akjain 08/30/2002
  	  -- added to format the amount
  	  l_amount := srlv_data.AMOUNT;
  	  l_srlv_tbl(i).AMOUNT := format_number(l_amount, l_chr_id);
  	  l_srlv_tbl(i).ADVANCE_OR_ARREARS := srlv_data.ADVANCE_OR_ARREARS;
  	  l_srlv_tbl(i).PERIOD := srlv_data.PERIOD;
  	  l_srlv_tbl(i).LOCK_LEVEL_STEP := srlv_data.LOCK_LEVEL_STEP;
  	  l_srlv_tbl(i).DAYS_IN_PERIOD := srlv_data.DAYS_IN_PERIOD;
  	  l_srlv_tbl(i).FIRST_PAYMENT_DATE := srlv_data.FIRST_PAYMENT_DATE;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE1 := srlv_data.STREAM_INTERFACE_ATTRIBUTE1;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE2 := srlv_data.STREAM_INTERFACE_ATTRIBUTE2;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE3 := srlv_data.STREAM_INTERFACE_ATTRIBUTE3;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE4 := srlv_data.STREAM_INTERFACE_ATTRIBUTE4;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE5 := srlv_data.STREAM_INTERFACE_ATTRIBUTE5;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE6 := srlv_data.STREAM_INTERFACE_ATTRIBUTE6;

  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE7 := srlv_data.STREAM_INTERFACE_ATTRIBUTE7;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE8 := srlv_data.STREAM_INTERFACE_ATTRIBUTE8;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE9 := srlv_data.STREAM_INTERFACE_ATTRIBUTE9;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE10 := srlv_data.STREAM_INTERFACE_ATTRIBUTE10;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE11 := srlv_data.STREAM_INTERFACE_ATTRIBUTE11;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE12 := srlv_data.STREAM_INTERFACE_ATTRIBUTE12;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE13 := srlv_data.STREAM_INTERFACE_ATTRIBUTE13;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE14 := srlv_data.STREAM_INTERFACE_ATTRIBUTE14;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE15 := srlv_data.STREAM_INTERFACE_ATTRIBUTE15;
  	  i := i + 1;
  	END LOOP;
  	i := 1;
  	FOR yields_data in yields_data_csr(p_transaction_number)
  	LOOP
  	  l_yields_tbl(i) := null;
  	  l_yields_tbl(i).yield_name := yields_data.yield_name;
      l_yields_tbl(i).value := yields_data.effective_pre_tax_yield;


      --l_yields_tbl(i).effective_after_tax_yield := yields_data.effective_after_tax_yield;
      --l_yields_tbl(i).nominal_pre_tax_yield := yields_data.nominal_pre_tax_yield;
      --l_yields_tbl(i).nominal_after_tax_yield := yields_data.nominal_after_tax_yield;
      l_yields_tbl(i).implicit_interest_rate := yields_data.implicit_interest_rate;
      l_yields_tbl(i).method := yields_data.method;
      l_yields_tbl(i).array_type := yields_data.array_type;
      l_yields_tbl(i).roe_type := yields_data.roe_type;
      l_yields_tbl(i).roe_base := yields_data.roe_base;
      l_yields_tbl(i).compounded_method := yields_data.compounded_method;
      l_yields_tbl(i).target_value := yields_data.target_value;
      l_yields_tbl(i).index_number := yields_data.index_number;
      l_yields_tbl(i).nominal_yn := yields_data.nominal_yn;
      l_yields_tbl(i).pre_tax_yn := yields_data.pre_tax_yn;
  	  i := i + 1;
  	END LOOP;
  	-- call the restructure api for processing results
-- Start of wraper code generated automatically by Debug code generator for okl_solve_for_rent_pvt.process_results
/*
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call okl_solve_for_rent_pvt.process_results ');
    END;
  END IF;
         okl_solve_for_rent_pvt.process_results(p_api_version         => l_api_version,
  	                                          p_init_msg_list     => p_init_msg_list,
  	                                          p_chr_id            => l_chr_id,
  			                          p_trans_status      => l_sis_code,
						  p_trans_number      => p_transaction_number,
  			                          p_rent_tbl          => l_srlv_tbl,
  			                          p_yield_tbl         => l_yields_tbl,
  			                          x_return_status     => l_return_status,
  			                          x_msg_count         => x_msg_count,
  			                          x_msg_data          => x_msg_data);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call okl_solve_for_rent_pvt.process_results ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_solve_for_rent_pvt.process_results
  	IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
*/
      -- update statuses in the inbound and outbound interface tables
  	UPDATE_STATUSES(p_transaction_number => p_transaction_number
  	                ,x_return_status      => l_return_status);
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
  	x_return_status := l_return_status;
      OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
  						 x_msg_data	  => x_msg_data);
    EXCEPTION
      WHEN G_EXCEPTION_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
  	  				  	 						   p_pkg_name	=> G_PKG_NAME,
  												   p_exc_name   => G_EXC_NAME_ERROR,
  												   x_msg_count	=> x_msg_count,
  												   x_msg_data	=> x_msg_data,
  												   p_api_type	=> '_PVT');
      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
  	  				  	 						   p_pkg_name	=> G_PKG_NAME,
  												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
  												   x_msg_count	=> x_msg_count,
  												   x_msg_data	=> x_msg_data,
  												   p_api_type	=> '_PVT');
      WHEN OTHERS THEN

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
  	  				  	 						   p_pkg_name	=> G_PKG_NAME,
  												   p_exc_name   => G_EXC_NAME_OTHERS,
  												   x_msg_count	=> x_msg_count,
  												   x_msg_data	=> x_msg_data,

  												   p_api_type	=> '_PVT');
    END PROCESS_QUOT_STRM_RESLTS;
    ------------------------------------------------------------------------------------------
    -- PROCEDURE
    ------------------------------------------------------------------------------------------
    PROCEDURE PROCESS_RENW_STRM_RESLTS(p_api_version        IN     NUMBER
                                          ,p_init_msg_list      IN     VARCHAR2
  	                                    ,p_transaction_number IN     NUMBER
                                          ,x_return_status      OUT    NOCOPY VARCHAR2
                                          ,x_msg_count          OUT    NOCOPY NUMBER
                                          ,x_msg_data           OUT    NOCOPY VARCHAR2)
    IS
      l_return_status VARCHAR(1) := G_RET_STS_SUCCESS;
      l_api_name          CONSTANT VARCHAR2(40) := 'PROCESS_RENW_STRM_RESLTS';
      l_api_version       CONSTANT NUMBER       := 1.0;
  	l_srlv_tbl srlv_tbl_type;
  	l_yields_tbl yields_tbl_type;
  	l_sir_id NUMBER;
  	i NUMBER;
  	p_trqv_rec trqv_rec_type;
    x_trqv_rec trqv_rec_type;
	p_payment_tbl payment_tbl_type;
	l_khr_id NUMBER;
	l_object1_id1 okl_stream_interfaces.OBJECT1_ID1%TYPE;
	l_sis_code  okl_stream_interfaces.SIS_CODE%TYPE;
	l_number_months NUMBER;

    --Modified by kthiruva for the VR build
  	CURSOR ppd_data_csr (p_trx_number NUMBER) IS
  	SELECT
      SRLB.ID,
  	  SRLB.LEVEL_INDEX_NUMBER,
  	  SRLB.NUMBER_OF_PERIODS,
  	  SRLB.SIR_ID,
  	  SRLB.INDEX_NUMBER,
  	  SRLB.LEVEL_TYPE,
  	  SRLB.AMOUNT,
  	  SRLB.ADVANCE_OR_ARREARS,
  	  SRLB.PERIOD,
  	  SRLB.LOCK_LEVEL_STEP,
  	  SRLB.DAYS_IN_PERIOD,
  	  SRLB.FIRST_PAYMENT_DATE,
	  SIFB.KHR_ID,
	  SILB.KLE_ID
  	FROM OKL_SIF_RET_LEVELS SRLB, OKL_SIF_RETS SIRB, OKL_STREAM_INTERFACES SIFB,
         OKL_SIF_LINES SILB
  	WHERE SIFB.TRANSACTION_NUMBER = p_trx_number
	AND SIRB.TRANSACTION_NUMBER = SIFB.TRANSACTION_NUMBER
	AND SILB.SIF_ID = SIFB.ID
  	AND SRLB.SIR_ID = SIRB.ID
	AND SRLB.INDEX_NUMBER = SILB.INDEX_NUMBER
	AND SRLB.LEVEL_TYPE in ('Payment','Principal')
	AND SRLB.LOCK_LEVEL_STEP = 'N';

  	CURSOR srlv_data_csr (p_trx_number NUMBER) IS
  	SELECT
      OKL_SIF_RET_LEVELS.ID,
  	  OKL_SIF_RET_LEVELS.LEVEL_INDEX_NUMBER,
  	  OKL_SIF_RET_LEVELS.NUMBER_OF_PERIODS,
  	  OKL_SIF_RET_LEVELS.SIR_ID,
  	  OKL_SIF_RET_LEVELS.INDEX_NUMBER,
  	  OKL_SIF_RET_LEVELS.LEVEL_TYPE,
  	  OKL_SIF_RET_LEVELS.AMOUNT,
  	  OKL_SIF_RET_LEVELS.ADVANCE_OR_ARREARS,
  	  OKL_SIF_RET_LEVELS.PERIOD,
  	  OKL_SIF_RET_LEVELS.LOCK_LEVEL_STEP,
  	  OKL_SIF_RET_LEVELS.DAYS_IN_PERIOD,
  	  OKL_SIF_RET_LEVELS.FIRST_PAYMENT_DATE,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE1,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE2,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE3,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE4,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE5,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE6,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE7,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE8,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE9,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE10,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE11,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE12,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE13,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE14,
  	  OKL_SIF_RET_LEVELS.STREAM_INTERFACE_ATTRIBUTE15
  	FROM OKL_SIF_RET_LEVELS, OKL_SIF_RETS
  	WHERE OKL_SIF_RETS.transaction_number = p_trx_number
  	AND OKL_SIF_RETS.INDEX_NUMBER = 0
  	AND   OKL_SIF_RET_LEVELS.SIR_ID = OKL_SIF_RETS.ID
	AND OKL_SIF_RET_LEVELS.LEVEL_TYPE = 'Payment'
	AND OKL_SIF_RET_LEVELS.LOCK_LEVEL_STEP = 'N';
  	CURSOR sirv_data_csr (p_trx_number NUMBER) IS
  	SELECT
  	  ID
  	FROM okl_sif_rets
  	WHERE okl_sif_rets.transaction_number = p_trx_number;
  	CURSOR sifv_data_csr (p_trx_number IN NUMBER) IS
  	SELECT
  	  OBJECT1_ID1,
  	  SIS_CODE
  	FROM OKL_STREAM_INTERFACES
  	WHERE TRANSACTION_NUMBER = p_trx_number;

    --Added by kthiruva for VR build
    --This cursor checks if the adjusting stub returned by the Inbound XML
    --was created for a stub or for a period ic payment
    CURSOR check_stub_csr(p_chr_id   NUMBER,
                          p_cle_id   NUMBER,
                          p_date     DATE,
                          p_slh_id   NUMBER)
    IS
    SELECT TO_NUMBER(crl.rule_information7) stub_days
    FROM okc_rule_groups_b crg,
       okc_rules_b crl
    WHERE crl.rgp_id = crg.id
    AND crl.object2_id1 = p_slh_id
    AND crg.rgd_code = 'LALEVL'
    AND crl.rule_information_category = 'LASLL'
    AND crg.dnz_chr_id = p_chr_id
    AND crg.cle_id = p_cle_id
    AND FND_DATE.canonical_to_date(crl.rule_information2)+TO_NUMBER(crl.rule_information7) = p_date;

    --Added by kthiruva on 12-Dec-2005
    --This cursor obtains the SLH id of the payment corresponding to a kle_id
    --Bug 4878162 - Start of Changes
    CURSOR get_slh_csr(p_chr_id   NUMBER,
                       p_cle_id   NUMBER)
    IS
    SELECT crl.id slh_id
    FROM okc_rule_groups_b crg,
         okc_rules_b crl
    WHERE crl.rgp_id = crg.id
    AND crg.rgd_code = 'LALEVL'
    AND crl.rule_information_category = 'LASLH'
    AND crg.dnz_chr_id = p_chr_id
    AND crg.cle_id = p_cle_id
    ORDER BY crl.rule_information1;

    CURSOR get_freq_csr(p_chr_id   NUMBER,
                        p_cle_id   NUMBER,
                        p_slh_id   NUMBER)
    IS
    SELECT crl.object1_id1 frequency
    FROM okc_rule_groups_b crg,
       okc_rules_b crl
    WHERE crl.rgp_id = crg.id
    AND crl.object2_id1 = p_slh_id
    AND crg.rgd_code = 'LALEVL'
    AND crl.rule_information_category = 'LASLL'
    AND crg.dnz_chr_id = p_chr_id
    AND crg.cle_id = p_cle_id;

    l_slh_id                    NUMBER;
    l_frequency                 VARCHAR2(1);
    --Bug 4878162 - End of Changes

    l_end_accrual_date          DATE;
    l_stub_days                 NUMBER;
    --kthiruva - End of Changes for VR build

    BEGIN
      l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                                p_pkg_name	   => 'OKL_PROCESS_STREAMS_PVT',
                                                p_init_msg_list  => p_init_msg_list,
                                                l_api_version	   => l_api_version,
                                                p_api_version	   => p_api_version,
                                                p_api_type	   => '_PVT',
                                                x_return_status  => l_return_status);
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
      --Before Processing Stream Results check for any exceptions in the Inbound Interface Tables
  	GENERATE_ERROR_LOGFILE(p_transaction_number => p_transaction_number
  	                      ,x_return_status      => l_return_status);
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
      -- update statuses in the inbound and outbound interface tables
  	UPDATE_STATUSES(p_transaction_number => p_transaction_number
  	                ,x_return_status      => l_return_status);
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
    -- check if request is for Principal Paydown
    OPEN sifv_data_csr(p_transaction_number);
	FETCH sifv_data_csr INTO l_object1_id1, l_sis_code;
	CLOSE sifv_data_csr;

	IF (okl_cs_principal_paydown_pvt.check_if_ppd(l_object1_id1)='Y') THEN
	    i := 1;
       	FOR ppd_data in ppd_data_csr(p_transaction_number)
       	LOOP
          l_khr_id := ppd_data.KHR_ID;
          p_payment_tbl(i).khr_id := ppd_data.KHR_ID;
          p_payment_tbl(i).kle_id := ppd_data.KLE_ID;
          --Modified by kthiruva on 12-Dec-2005
          -- A value of 'Y' for advance_or_arrears denotes that
          --the paynent is in Arrears
          --Bug 4878162 - Start of Changes
          IF (ppd_data.ADVANCE_OR_ARREARS = 'Y') THEN
            p_payment_tbl(i).arrears_yn := 'Y';
          ELSE
            p_payment_tbl(i).arrears_yn := 'N';
          END IF;
          --Bug 4878162 - End of Changes
          okl_st_code_conversions.reverse_translate_periodicity(
		                                     ppd_data.PERIOD,
											 p_payment_tbl(i).frequency);
          IF (ppd_data.PERIOD = 'Stub') THEN
              IF (ppd_data.ADVANCE_OR_ARREARS = 'N') THEN
                 l_end_accrual_date := ppd_data.first_payment_date + ppd_data.days_in_period;
              ELSE
                 l_end_accrual_date := ppd_data.first_payment_date ;
              END IF;
              --Added by kthiruva on 12-Dec-2005
              --Obtaining the payment header information
              --Bug 4878162 - Start of Changes
              OPEN get_slh_csr(ppd_data.khr_id,
                               ppd_data.kle_id);
              FETCH get_slh_csr INTO l_slh_id;
              IF get_slh_csr%FOUND THEN
                --A stub encountered could be the adjusting stub created for
                --either a periodic payment or for a stub.
                OPEN check_Stub_csr(ppd_data.khr_id,
                                    ppd_data.kle_id,
                                    l_end_accrual_date,
                                    l_slh_id);
                FETCH check_stub_csr INTO l_stub_days;
                --If the cursor returns a value then the adjusting stub is due to a stub in
                --the original payment plan.
                --Else it is a stub created for a periodic payment plan.
                IF check_stub_csr%FOUND THEN
                  p_payment_tbl(i).stub_days := l_stub_days;
                  p_payment_tbl(i).stub_amount := ppd_data.AMOUNT;
                ELSE
                  p_payment_tbl(i).periods := ppd_data.NUMBER_OF_PERIODS;
                  p_payment_tbl(i).amount := ppd_data.AMOUNT;
                  OPEN get_freq_csr(ppd_data.khr_id,
                                         ppd_data.kle_id,
                                         l_slh_id);
                  FETCH get_freq_csr INTO l_frequency;
                  IF get_freq_csr%FOUND THEN
                     p_payment_tbl(i).frequency := l_frequency;
                  END IF;
                  CLOSE get_freq_csr;
                END IF;
                --Added by kthiruva on 02-Dec-2005
                --Bug 4777531 - Start of Changes
                CLOSE check_Stub_csr;
                --Bug 4777531 - End of changes
              END IF;
              CLOSE get_slh_csr;
              --Bug 4878162 - End of Changes
          ELSE
            p_payment_tbl(i).periods := ppd_data.NUMBER_OF_PERIODS;
            p_payment_tbl(i).amount := ppd_data.AMOUNT;
          END IF;
          -- Bug 4047717 back out payment dates if in arrears to match SLL dates
		  IF (p_payment_tbl(i).arrears_yn = 'Y' AND
		      p_payment_tbl(i).frequency <> 'T') THEN
		    IF (p_payment_tbl(i).frequency = 'M') THEN
			  l_number_months := -1;
			ELSIF (p_payment_tbl(i).frequency = 'Q') THEN
			  l_number_months := -3;
			ELSIF (p_payment_tbl(i).frequency = 'S') THEN
			  l_number_months := -6;
			ELSIF (p_payment_tbl(i).frequency = 'A') THEN
			  l_number_months := -12;
			END IF;
            p_payment_tbl(i).start_date := ADD_MONTHS(ppd_data.FIRST_PAYMENT_DATE,l_number_months);
          ELSIF (p_payment_tbl(i).arrears_yn = 'Y' AND
		         p_payment_tbl(i).frequency = 'T') THEN
            p_payment_tbl(i).start_date := ppd_data.FIRST_PAYMENT_DATE - p_payment_tbl(i).stub_days;
		  ELSE
            p_payment_tbl(i).start_date := ppd_data.FIRST_PAYMENT_DATE;
	      END IF;
		  i := i + 1;
       	END LOOP;
           okl_cs_principal_paydown_pvt.store_esg_payments(p_api_version         =>  p_api_version
                                                          ,p_init_msg_list       =>  p_init_msg_list
                                                          ,x_return_status       =>  l_return_status
                                                          ,x_msg_count           =>  x_msg_count
                                                          ,x_msg_data            =>  x_msg_data
                                                          ,p_ppd_request_id      =>  l_object1_id1
                                                          ,p_ppd_khr_id          =>  l_khr_id
														  ,p_payment_tbl         =>  p_payment_tbl);
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_ERROR;
       END IF;
	ELSE
  	-- fetch records for the RENT LEVELS
       	FOR srlv_data in srlv_data_csr(p_transaction_number)
       	LOOP
       	  p_trqv_rec.amount := srlv_data.AMOUNT;
           END LOOP;

       	FOR sifv_data in sifv_data_csr(p_transaction_number)
       	LOOP
             p_trqv_rec.id    := sifv_data.OBJECT1_ID1;
       	  p_trqv_rec.request_status_code := sifv_data.SIS_CODE;
       	END LOOP;
       	-- call the restructure api for processing results
     -- Start of wraper code generated automatically by Debug code generator for okl_cs_lease_renewal_pub.update_lrnw_request
       IF(L_DEBUG_ENABLED='Y') THEN
         L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
         IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
       END IF;
       IF(IS_DEBUG_PROCEDURE_ON) THEN
         BEGIN
             OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call okl_cs_lease_renewal_pub.update_lrnw_request ');
         END;
       END IF;
           okl_cs_lease_renewal_pub.update_lrnw_request(p_api_version         =>  p_api_version
                                                   ,p_init_msg_list       =>  p_init_msg_list
                                                   ,x_return_status       =>  l_return_status
                                                   ,x_msg_count           =>  x_msg_count
                                                   ,x_msg_data            =>  x_msg_data
                                                   ,p_trqv_rec            =>  p_trqv_rec
                                                   ,x_trqv_rec            =>  x_trqv_rec);
       IF(IS_DEBUG_PROCEDURE_ON) THEN
         BEGIN
             OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call okl_cs_lease_renewal_pub.update_lrnw_request ');
         END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_cs_lease_renewal_pub.update_lrnw_request
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
	 END IF;
  	x_return_status := l_return_status;
      OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
  						 x_msg_data	  => x_msg_data);
    EXCEPTION
      WHEN G_EXCEPTION_ERROR THEN
        --Added by kthiruva on 02-Dec-2005
        --Bug 4777531 - Start of Changes
        IF(check_stub_csr%ISOPEN)
	    THEN
	      CLOSE check_stub_csr;
	    END IF;
        --Bug 4777531 - End of Changes
        --Added by kthiruva on 02-Dec-2005
        --Bug 4878162 - Start of Changes
        IF(get_slh_csr%ISOPEN)
	    THEN
	      CLOSE get_slh_csr;
	    END IF;
        IF(get_freq_csr%ISOPEN)
	    THEN
	      CLOSE get_freq_csr;
	    END IF;
        --Bug 4878162 - End of Changes
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
  	  				  	 						   p_pkg_name	=> G_PKG_NAME,
  												   p_exc_name   => G_EXC_NAME_ERROR,
  												   x_msg_count	=> x_msg_count,
  												   x_msg_data	=> x_msg_data,
  												   p_api_type	=> '_PVT');
      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
        --Added by kthiruva on 02-Dec-2005
        --Bug 4777531 - Start of Changes
        IF(check_stub_csr%ISOPEN)
            THEN
              CLOSE check_stub_csr;
            END IF;
        --Bug 4777531 - End of Changes
        --Added by kthiruva on 02-Dec-2005
        --Bug 4878162 - Start of Changes
        IF(get_slh_csr%ISOPEN)
	    THEN
	      CLOSE get_slh_csr;
	    END IF;
        IF(get_freq_csr%ISOPEN)
	    THEN
	      CLOSE get_freq_csr;
	    END IF;
        --Bug 4878162 - End of Changes
       x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
  	  				  	 						   p_pkg_name	=> G_PKG_NAME,
  												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
  												   x_msg_count	=> x_msg_count,
  												   x_msg_data	=> x_msg_data,
  												   p_api_type	=> '_PVT');
      WHEN OTHERS THEN
        --Added by kthiruva on 02-Dec-2005
        --Bug 4777531 - Start of Changes
        IF(check_stub_csr%ISOPEN)
            THEN
              CLOSE check_stub_csr;
            END IF;
        --Bug 4777531 - End of Changes
        --Added by kthiruva on 02-Dec-2005
        --Bug 4878162 - Start of Changes
        IF(get_slh_csr%ISOPEN)
	    THEN
	      CLOSE get_slh_csr;
	    END IF;
        IF(get_freq_csr%ISOPEN)
	    THEN
	      CLOSE get_freq_csr;
	    END IF;
        --Bug 4878162 - End of Changes
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
  	  				  	 						   p_pkg_name	=> G_PKG_NAME,
  												   p_exc_name   => G_EXC_NAME_OTHERS,
  												   x_msg_count	=> x_msg_count,
  												   x_msg_data	=> x_msg_data,
  												   p_api_type	=> '_PVT');
    END PROCESS_RENW_STRM_RESLTS;

    PROCEDURE reorganise_payment_tbl(p_srlv_tbl  IN srlv_tbl_type
                                     ,x_srlv_tbl  OUT NOCOPY srlv_tbl_type)
    IS
      l_srlv_tbl                 srlv_tbl_type := p_srlv_tbl;
      l_temp_srlv_tbl            srlv_tbl_type ;
      i                          NUMBER := 0;
      j                          NUMBER := 0;
    BEGIN
      j := l_srlv_tbl.FIRST;
      IF l_srlv_tbl.COUNT > 0 THEN
        --Assigning the first record as is
        l_temp_srlv_tbl(i).ID := l_srlv_tbl(j).ID;
  	    l_temp_srlv_tbl(i).LEVEL_INDEX_NUMBER := l_srlv_tbl(j).LEVEL_INDEX_NUMBER;
  	    l_temp_srlv_tbl(i).NUMBER_OF_PERIODS := l_srlv_tbl(j).NUMBER_OF_PERIODS;
  	    l_temp_srlv_tbl(i).SIR_ID := l_srlv_tbl(j).SIR_ID;
  	    l_temp_srlv_tbl(i).INDEX_NUMBER := l_srlv_tbl(j).INDEX_NUMBER;
  	    l_temp_srlv_tbl(i).LEVEL_TYPE := l_srlv_tbl(j).LEVEL_TYPE;
  	    l_temp_srlv_tbl(i).AMOUNT := l_srlv_tbl(j).AMOUNT;
  	    l_temp_srlv_tbl(i).ADVANCE_OR_ARREARS := l_srlv_tbl(j).ADVANCE_OR_ARREARS;
  	    l_temp_srlv_tbl(i).PERIOD := l_srlv_tbl(j).PERIOD;
  	    l_temp_srlv_tbl(i).LOCK_LEVEL_STEP := l_srlv_tbl(j).LOCK_LEVEL_STEP;
  	    l_temp_srlv_tbl(i).DAYS_IN_PERIOD := l_srlv_tbl(j).DAYS_IN_PERIOD;
        l_temp_srlv_tbl(i).FIRST_PAYMENT_DATE := l_srlv_tbl(j).FIRST_PAYMENT_DATE;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE1 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE1;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE2 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE2;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE3 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE3;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE4 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE4;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE5 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE5;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE6 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE6;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE7 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE7;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE8 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE8;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE9 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE9;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE10 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE10;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE11 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE11;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE12 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE12;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE13 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE13;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE14 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE14;
  	    l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE15 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE15;
      END IF;

      LOOP
          j := l_srlv_tbl.NEXT(j);
          --Added by kthiruva on 15-Jun-2006 for Bug 5286917
          EXIT WHEN j is NULL;
          --End of Changes
          IF (l_temp_srlv_tbl(i).INDEX_NUMBER = l_srlv_tbl(j).INDEX_NUMBER AND
                l_temp_srlv_tbl(i).AMOUNT = l_srlv_tbl(j).AMOUNT AND
                l_temp_srlv_tbl(i).PERIOD = l_srlv_tbl(j).PERIOD) THEN
             l_temp_srlv_tbl(i).NUMBER_OF_PERIODS := l_temp_srlv_tbl(i).NUMBER_OF_PERIODS +
                                                                    l_srlv_tbl(j).NUMBER_OF_PERIODS;
          ELSE
             i := i + 1;
             l_temp_srlv_tbl(i).ID := l_srlv_tbl(j).ID;
      	     l_temp_srlv_tbl(i).LEVEL_INDEX_NUMBER := l_srlv_tbl(j).LEVEL_INDEX_NUMBER;
      	     l_temp_srlv_tbl(i).NUMBER_OF_PERIODS := l_srlv_tbl(j).NUMBER_OF_PERIODS;
       	     l_temp_srlv_tbl(i).SIR_ID := l_srlv_tbl(j).SIR_ID;
      	     l_temp_srlv_tbl(i).INDEX_NUMBER := l_srlv_tbl(j).INDEX_NUMBER;
      	     l_temp_srlv_tbl(i).LEVEL_TYPE := l_srlv_tbl(j).LEVEL_TYPE;
     	     l_temp_srlv_tbl(i).AMOUNT := l_srlv_tbl(j).AMOUNT;
     	     l_temp_srlv_tbl(i).ADVANCE_OR_ARREARS := l_srlv_tbl(j).ADVANCE_OR_ARREARS;
  	         l_temp_srlv_tbl(i).PERIOD := l_srlv_tbl(j).PERIOD;
  	         l_temp_srlv_tbl(i).LOCK_LEVEL_STEP := l_srlv_tbl(j).LOCK_LEVEL_STEP;
  	         l_temp_srlv_tbl(i).DAYS_IN_PERIOD := l_srlv_tbl(j).DAYS_IN_PERIOD;
             l_temp_srlv_tbl(i).FIRST_PAYMENT_DATE := l_srlv_tbl(j).FIRST_PAYMENT_DATE;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE1 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE1;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE2 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE2;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE3 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE3;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE4 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE4;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE5 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE5;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE6 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE6;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE7 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE7;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE8 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE8;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE9 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE9;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE10 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE10;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE11 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE11;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE12 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE12;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE13 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE13;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE14 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE14;
  	         l_temp_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE15 := l_srlv_tbl(j).STREAM_INTERFACE_ATTRIBUTE15;
          END IF;
      END LOOP;
      x_srlv_tbl   := l_temp_srlv_tbl;
    END reorganise_payment_tbl;

      ------------------------------------------------------------------------------------------
    -- PROCEDURE
    ------------------------------------------------------------------------------------------
    PROCEDURE PROCESS_VIRP_STRM_RESLTS(p_api_version        IN     NUMBER
                                          ,p_init_msg_list      IN     VARCHAR2
  	                                    ,p_transaction_number IN     NUMBER
                                          ,x_return_status      OUT    NOCOPY VARCHAR2
                                          ,x_msg_count          OUT    NOCOPY NUMBER
                                          ,x_msg_data           OUT    NOCOPY VARCHAR2)
    IS
      l_return_status VARCHAR(1) := G_RET_STS_SUCCESS;
      l_api_name          CONSTANT VARCHAR2(40) := 'PROCESS_VIRP_STRM_RESLTS';
      l_api_version       CONSTANT NUMBER       := 1.0;
  	l_srlv_tbl srlv_tbl_type;
    --Added by kthiruva for Bug 5161075
    l_tmp_srlv_tbl srlv_tbl_type;
    l_yields_tbl yields_tbl_type;
  	l_sir_id NUMBER;
  	l_chr_id NUMBER;
  	l_transaction_status varchar2(30);
  	i NUMBER;

        --Modified by kthiruva on 13-Apr-2006 for Bug 5090060
        -- Where condition added
  	CURSOR srlv_data_csr (p_sir_id NUMBER,
                          p_trx_number NUMBER) IS
  	SELECT
        SRLB.ID,
  	  SRLB.LEVEL_INDEX_NUMBER,
  	  SRLB.NUMBER_OF_PERIODS,
  	  SRLB.SIR_ID,
  	  SRLB.INDEX_NUMBER,
  	  SRLB.LEVEL_TYPE,
  	  SRLB.AMOUNT,
  	  SRLB.ADVANCE_OR_ARREARS,
  	  SRLB.PERIOD,
  	  SRLB.LOCK_LEVEL_STEP,
  	  SRLB.DAYS_IN_PERIOD,
  	  SRLB.FIRST_PAYMENT_DATE,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE1,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE2,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE3,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE4,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE5,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE6,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE7,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE8,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE9,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE10,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE11,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE12,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE13,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE14,
  	  SRLB.STREAM_INTERFACE_ATTRIBUTE15,
      SIFB.KHR_ID,
      SILB.KLE_ID
    FROM OKL_SIF_RET_LEVELS SRLB, OKL_SIF_RETS SIRB,
         OKL_STREAM_INTERFACES SIFB,OKL_SIF_LINES SILB
  	WHERE SRLB.SIR_ID = p_sir_id
  	AND  SIFB.TRANSACTION_NUMBER = p_trx_number
	AND SIRB.TRANSACTION_NUMBER = SIFB.TRANSACTION_NUMBER
	AND SILB.SIF_ID = SIFB.ID
  	AND SRLB.SIR_ID = SIRB.ID
	AND SRLB.INDEX_NUMBER = SILB.INDEX_NUMBER
    AND SRLB.LEVEL_TYPE IN ('Payment','Principal')
    AND SRLB.LOCK_LEVEL_STEP = 'N';

  	CURSOR sirv_data_csr (p_trx_number NUMBER) IS
  	SELECT
  	  ID
  	FROM okl_sif_rets
  	WHERE okl_sif_rets.transaction_number = p_trx_number
  	AND OKL_SIF_RETS.INDEX_NUMBER = 0;
  	CURSOR sifv_data_csr (p_trx_number IN NUMBER) IS
  	SELECT
  	  SIS_CODE,
  	  KHR_ID
  	FROM OKL_STREAM_INTERFACES
  	WHERE TRANSACTION_NUMBER = p_trx_number;

    --Added by kthiruva for Bug 5161075
    --This cursor checks if the adjusting stub returned by the Inbound XML
    --was created for a stub or for a period ic payment
    CURSOR check_stub_csr(p_chr_id   NUMBER,
                          p_cle_id   NUMBER,
                          p_date     DATE,
                          p_slh_id   NUMBER)
    IS
    SELECT TO_NUMBER(crl.rule_information7) stub_days
    FROM okc_rule_groups_b crg,
       okc_rules_b crl
    WHERE crl.rgp_id = crg.id
    AND crl.object2_id1 = p_slh_id
    AND crg.rgd_code = 'LALEVL'
    AND crl.rule_information_category = 'LASLL'
    AND crg.dnz_chr_id = p_chr_id
    AND crg.cle_id = p_cle_id
    AND FND_DATE.canonical_to_date(crl.rule_information2)+TO_NUMBER(crl.rule_information7) = p_date;

    --This cursor obtains the SLH id of the payment corresponding to a kle_id
    CURSOR get_slh_csr(p_chr_id   NUMBER,
                       p_cle_id   NUMBER)
    IS
    SELECT crl.id slh_id
    FROM okc_rule_groups_b crg,
         okc_rules_b crl
    WHERE crl.rgp_id = crg.id
    AND crg.rgd_code = 'LALEVL'
    AND crl.rule_information_category = 'LASLH'
    AND crg.dnz_chr_id = p_chr_id
    AND crg.cle_id = p_cle_id
    ORDER BY crl.rule_information1;

    CURSOR get_freq_csr(p_chr_id   NUMBER,
                        p_cle_id   NUMBER,
                        p_slh_id   NUMBER)
    IS
    SELECT crl.object1_id1 frequency
    FROM okc_rule_groups_b crg,
       okc_rules_b crl
    WHERE crl.rgp_id = crg.id
    AND crl.object2_id1 = p_slh_id
    AND crg.rgd_code = 'LALEVL'
    AND crl.rule_information_category = 'LASLL'
    AND crg.dnz_chr_id = p_chr_id
    AND crg.cle_id = p_cle_id;

    l_slh_id                    NUMBER;
    l_frequency                 VARCHAR2(1);
    l_end_accrual_date          DATE;
    l_stub_days                 NUMBER;
    --kthiruva - End of Changes for Bug 5161075


    --Added by kthiruva on 11-Nov-2005 for the VR build
    --Bug 4726209 - Start of Changes
    l_payment_start_date   DATE;
    l_number_of_months     NUMBER := 0;
    --Bug 4726209 - End of Changes
    --Added by kthiruva on 13-Apr-2006 for Bug 5090060
    level_indx_count       NUMBER := 1;
    asset_indx_number      NUMBER ;

    BEGIN
      l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                                p_pkg_name	   => 'OKL_PROCESS_STREAMS_PVT',
                                                p_init_msg_list  => p_init_msg_list,
                                                l_api_version	   => l_api_version,
                                                p_api_version	   => p_api_version,
                                                p_api_type	   => '_PVT',
                                                x_return_status  => l_return_status);
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
      --Before Processing Stream Results check for any exceptions in the Inbound Interface Tables
  	GENERATE_ERROR_LOGFILE(p_transaction_number => p_transaction_number
  	                      ,x_return_status      => l_return_status);
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
      -- update statuses in the inbound and outbound interface tables
  	UPDATE_STATUSES(p_transaction_number => p_transaction_number
  	                ,x_return_status      => l_return_status);
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
  	-- fetch records from
  	FOR sirv_data in sirv_data_csr(p_transaction_number)
  	LOOP
  	  l_sir_id := sirv_data.id;
  	END LOOP;
  	i := 1;
  	FOR srlv_data in srlv_data_csr(l_sir_id,p_transaction_number)
        LOOP
  	  l_srlv_tbl(i) := null;
          l_srlv_tbl(i).ID := srlv_data.ID;
  	  l_srlv_tbl(i).LEVEL_INDEX_NUMBER := srlv_data.LEVEL_INDEX_NUMBER;
  	  l_srlv_tbl(i).NUMBER_OF_PERIODS := srlv_data.NUMBER_OF_PERIODS;
  	  l_srlv_tbl(i).SIR_ID := srlv_data.SIR_ID;
  	  l_srlv_tbl(i).INDEX_NUMBER := srlv_data.INDEX_NUMBER;
  	  l_srlv_tbl(i).LEVEL_TYPE := srlv_data.LEVEL_TYPE;
  	  l_srlv_tbl(i).AMOUNT := srlv_data.AMOUNT;
  	  l_srlv_tbl(i).ADVANCE_OR_ARREARS := srlv_data.ADVANCE_OR_ARREARS;
  	  l_srlv_tbl(i).PERIOD := srlv_data.PERIOD;
  	  l_srlv_tbl(i).LOCK_LEVEL_STEP := srlv_data.LOCK_LEVEL_STEP;
  	  l_srlv_tbl(i).DAYS_IN_PERIOD := srlv_data.DAYS_IN_PERIOD;
      --We are interested in querying up and passing back all unlocked payment
      --If a PPD has been made on the contract, it would be locked, but the ajdusting stub created
      --for the PPD would be unlocked.
      IF (srlv_data.PERIOD = 'Stub') THEN
         IF (srlv_data.ADVANCE_OR_ARREARS = 'N') THEN
             l_end_accrual_date := srlv_data.first_payment_date + srlv_data.days_in_period;
         ELSE
             l_end_accrual_date := srlv_data.first_payment_date ;
         END IF;
         --Obtaining the payment header information
         OPEN get_slh_csr(srlv_data.khr_id,
                          srlv_data.kle_id);
         FETCH get_slh_csr INTO l_slh_id;
         IF get_slh_csr%FOUND THEN
            --A stub encountered could be the adjusting stub created for
            --either a periodic payment or for a stub.
            OPEN check_Stub_csr(srlv_data.khr_id,
                                srlv_data.kle_id,
                                l_end_accrual_date,
                                l_slh_id);
            FETCH check_stub_csr INTO l_stub_days;
            --If the cursor returns a value then the adjusting stub is due to a stub in
            --the original payment plan.
            --Else it is a stub created for a periodic payment plan.
            IF check_stub_csr%FOUND THEN
               l_srlv_tbl(i).DAYS_IN_PERIOD := l_stub_days;
            ELSE
               l_srlv_tbl(i).NUMBER_OF_PERIODS := srlv_data.NUMBER_OF_PERIODS;
               OPEN get_freq_csr(srlv_data.khr_id,
                                 srlv_data.kle_id,
                                 l_slh_id);
               FETCH get_freq_csr INTO l_frequency;
               IF get_freq_csr%FOUND THEN
                  IF l_frequency = 'M' THEN
                    l_srlv_tbl(i).PERIOD := 'Monthly';
                  ELSIF l_frequency = 'Q' THEN
                    l_srlv_tbl(i).PERIOD := 'Quarterly';
                  ELSIF l_frequency = 'S' THEN
                    l_srlv_tbl(i).PERIOD := 'Semiannual';
                  ELSIF l_frequency = 'A' THEN
                    l_srlv_tbl(i).PERIOD := 'Annual';
                  END IF;
               END IF;
               CLOSE get_freq_csr;
            END IF;
            CLOSE check_Stub_csr;
         END IF;
         CLOSE get_slh_csr;
      END IF;

          --Modified by kthiruva on 11-Nov-2005 for the VR build
          --When the payment is in ARREARS, SuperTrump returns the due date
          --The requirement is however to pass the contract start date
          --Bug 4726209 - Start of Changes
         IF l_srlv_tbl(i).ADVANCE_OR_ARREARS = 'N' THEN
            l_srlv_tbl(i).FIRST_PAYMENT_DATE := srlv_data.FIRST_PAYMENT_DATE;
         ELSIF l_srlv_tbl(i).ADVANCE_OR_ARREARS = 'Y' THEN

            IF l_srlv_tbl(i).PERIOD = 'Stub' THEN
              l_srlv_tbl(i).FIRST_PAYMENT_DATE := srlv_data.FIRST_PAYMENT_DATE  - l_srlv_tbl(i).DAYS_IN_PERIOD;
            ELSE
              IF l_srlv_tbl(i).PERIOD = 'Annual' THEN
                 l_number_of_months := G_MINUS_TWELVE;
              ELSIF l_srlv_tbl(i).PERIOD = 'Semiannual' THEN
                 l_number_of_months := G_MINUS_SIX;
              ELSIF l_srlv_tbl(i).PERIOD = 'Quarterly' THEN
                 l_number_of_months := G_MINUS_THREE;
              ELSIF l_srlv_tbl(i).PERIOD = 'Monthly' THEN
                 l_number_of_months := G_MINUS_ONE;
              END IF;

              Okl_Stream_Generator_Pvt.add_months_new(p_start_Date => srlv_data.FIRST_PAYMENT_DATE,
                                                 p_months_after => l_number_of_months,
                                                 x_date => l_payment_start_date,
                                                 x_return_Status => l_return_status);

              IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                 RAISE G_EXCEPTION_ERROR;
              END IF;
              l_srlv_tbl(i).FIRST_PAYMENT_DATE := l_payment_start_date;
            END IF;
         END IF;
         --Bug 4726209 - End of Changes

  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE1 := srlv_data.STREAM_INTERFACE_ATTRIBUTE1;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE2 := srlv_data.STREAM_INTERFACE_ATTRIBUTE2;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE3 := srlv_data.STREAM_INTERFACE_ATTRIBUTE3;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE4 := srlv_data.STREAM_INTERFACE_ATTRIBUTE4;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE5 := srlv_data.STREAM_INTERFACE_ATTRIBUTE5;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE6 := srlv_data.STREAM_INTERFACE_ATTRIBUTE6;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE7 := srlv_data.STREAM_INTERFACE_ATTRIBUTE7;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE8 := srlv_data.STREAM_INTERFACE_ATTRIBUTE8;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE9 := srlv_data.STREAM_INTERFACE_ATTRIBUTE9;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE10 := srlv_data.STREAM_INTERFACE_ATTRIBUTE10;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE11 := srlv_data.STREAM_INTERFACE_ATTRIBUTE11;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE12 := srlv_data.STREAM_INTERFACE_ATTRIBUTE12;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE13 := srlv_data.STREAM_INTERFACE_ATTRIBUTE13;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE14 := srlv_data.STREAM_INTERFACE_ATTRIBUTE14;
  	  l_srlv_tbl(i).STREAM_INTERFACE_ATTRIBUTE15 := srlv_data.STREAM_INTERFACE_ATTRIBUTE15;
  	  i := i + 1;
  	END LOOP;

        asset_indx_number := l_srlv_tbl(l_srlv_tbl.FIRST).index_number;
        FOR i in l_srlv_tbl.FIRST..l_srlv_tbl.LAST
        LOOP
          IF (asset_indx_number = l_srlv_tbl(i).INDEX_NUMBER) THEN
             l_srlv_tbl(i).LEVEL_INDEX_NUMBER := level_indx_count;
             level_indx_count := level_indx_count + 1;
          ELSE
             asset_indx_number := l_srlv_tbl(i).INDEX_NUMBER;
             level_indx_count := 1;
             l_srlv_tbl(i).LEVEL_INDEX_NUMBER := level_indx_count;
             level_indx_count := level_indx_count + 1;
          END IF;
        END LOOP;

  	i := 1;
  	FOR sifv_data in sifv_data_csr(p_transaction_number)
  	LOOP
        l_chr_id    := sifv_data.khr_id;
  	l_transaction_status := sifv_data.SIS_CODE;
  	END LOOP;

    --Reorganising the payment table
    reorganise_payment_tbl(p_srlv_tbl  => l_srlv_tbl,
                           x_srlv_tbl  => l_tmp_srlv_tbl);


  	-- call the restructure api for processing results
-- Start of wraper code generated automatically by Debug code generator for OKL_VARIABLE_INTEREST_PUB.var_int_rent_level

  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRPSRB.pls call OKL_VARIABLE_INTEREST_PUB.var_int_rent_level ');
    END;
  END IF;
      OKL_VARIABLE_INTEREST_PUB.var_int_rent_level(p_api_version    =>  p_api_version
                                                  ,p_init_msg_list  =>  p_init_msg_list
                                                  ,x_return_status  =>  l_return_status
                                                  ,x_msg_count      =>  x_msg_count
                                                  ,x_msg_data       =>  x_msg_data
                                                  ,p_chr_id         =>  l_chr_id
                                                  ,p_trx_id         =>  p_transaction_number
                                                  ,p_trx_status     =>  l_transaction_status
                                                  ,p_rent_tbl       =>  l_tmp_srlv_tbl );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRPSRB.pls call OKL_VARIABLE_INTEREST_PUB.var_int_rent_level ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_VARIABLE_INTEREST_PUB.var_int_rent_level
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
      END IF;
  	x_return_status := l_return_status;
      OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
  						 x_msg_data	  => x_msg_data);
    EXCEPTION
      WHEN G_EXCEPTION_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
  	  				  	 						   p_pkg_name	=> G_PKG_NAME,
  												   p_exc_name   => G_EXC_NAME_ERROR,
  												   x_msg_count	=> x_msg_count,
  												   x_msg_data	=> x_msg_data,
  												   p_api_type	=> '_PVT');
      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
  	  				  	 						   p_pkg_name	=> G_PKG_NAME,
  												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
  												   x_msg_count	=> x_msg_count,
  												   x_msg_data	=> x_msg_data,
  												   p_api_type	=> '_PVT');
      WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
  	  				  	 						   p_pkg_name	=> G_PKG_NAME,
  												   p_exc_name   => G_EXC_NAME_OTHERS,
  												   x_msg_count	=> x_msg_count,
  												   x_msg_data	=> x_msg_data,
  												   p_api_type	=> '_PVT');
    END PROCESS_VIRP_STRM_RESLTS;
   PROCEDURE ENQUEUE_MESSAGE(  p_transaction_type IN varchar2,
  			    p_transaction_subtype IN varchar2,
      		    p_doc_number IN varchar2,
		    p_prc_eng_url IN VARCHAR2,
  			    x_return_status OUT NOCOPY varchar2)
  IS
  i_tmp                   clob;
  v_message               system.ecxmsg;
  v_enqueueoptions        dbms_aq.enqueue_options_t;
  v_messageproperties     dbms_aq.message_properties_t;
  v_msgid                 raw(16);
  c_nummessages           CONSTANT INTEGER :=1;
  i_amount                number;
  i_message               raw(32767);
  i_buffer                varchar2(32767);
  i_chunksize             pls_integer := 32767;
  i_offset                pls_integer;
  l_party_id              varchar2(10) := null;
  l_party_type            varchar2(10) := '';
  l_party_site_id         varchar2(100);
  l_prc_eng_url           varchar2(100);
  cursor xml_data_csr( p_trx_number NUMBER) IS
  SELECT
    IN_XML
  FROM
    OKL_STREAM_TRX_DATA
  WHERE
  transaction_number = p_trx_number;
  BEGIN
    savepoint enq_message;
        x_return_status := G_RET_STS_ERROR;
    FOR xml_data in xml_data_csr(p_doc_number)
    LOOP
      i_tmp := xml_data.in_xml;
    END LOOP;
    IF (p_prc_eng_url is null) THEN
     l_prc_eng_url := G_PROTOCOL_ADDRESS;
    ELSE
     l_prc_eng_url := p_prc_eng_url;
    END IF;
  --	  select xmlfile into i_tmp from clobtest where ID = p_doc_number;
  	  l_party_site_id := FND_PROFILE.VALUE('OKL_ST_PRCENG_NAME');
           v_message := system.ecxmsg (message_type        => G_MSG_TYPE,
                              message_standard    => G_MSG_STD,

                              transaction_type    => p_transaction_type,
                              transaction_subtype => p_transaction_subtype,
                              document_number     => p_doc_number,
                              partyid             => l_party_id,
                              party_site_id       => l_party_site_id,
                              party_type          => l_party_type,
                              protocol_type       => G_PROTOCOL_TYPE,
                              protocol_address    => l_prc_eng_url,
                              username            => NULL,
                              password            => NULL,
                              payload             => i_tmp,
                              attribute1          => NULL,
                              attribute2          => NULL,
                              attribute3          => NULL,
                              attribute4          => NULL,
                              attribute5          => NULL);
       for v_counter in 1..c_nummessages
       loop
          -- Enqueue
                  dbms_aq.enqueue
                          (
                          queue_name=> G_INBOUND_QUEUE,
                          enqueue_options=>v_enqueueoptions,
                          message_properties=>v_messageproperties,
                          payload=>v_message,
                          msgid=>v_msgid
                          );
        end loop;
     -- start listener for inbound queue
    wf_event.listen(G_INBOUND_QUEUE);
    -- start listener on transaction queue
    wf_event.listen(G_TRANSACTION_QUEUE);
    --delete from OKL_STREAM_TRX_DATA where transaction_number = p_doc_number;
    x_return_status := G_RET_STS_SUCCESS;
    commit;
  exception
    when others then
  	  rollback to enq_message;
            x_return_status := G_RET_STS_ERROR;
  END ENQUEUE_MESSAGE;
END OKL_PROCESS_STREAMS_PVT;

/
