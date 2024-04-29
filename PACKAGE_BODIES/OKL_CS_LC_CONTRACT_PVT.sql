--------------------------------------------------------
--  DDL for Package Body OKL_CS_LC_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CS_LC_CONTRACT_PVT" AS
/* $Header: OKLRLCRB.pls 120.32.12010000.2 2009/06/11 08:14:39 rpillay ship $ */
   g_user_id               NUMBER                           := Okl_Api.G_MISS_NUM;
   g_resp_id               NUMBER                           := Okl_Api.G_MISS_NUM;
   g_user_resource_id      okc_k_accesses.resource_id%TYPE  := Okl_Api.G_MISS_NUM;
   g_resp_access           okc_k_accesses.access_level%TYPE := Okl_Api.G_MISS_CHAR;
   g_reset_access_flag     BOOLEAN                          := FALSE;
   g_scs_code              okc_k_headers_b.scs_code%TYPE    := Okl_Api.G_MISS_CHAR;
   g_groups_processed      BOOLEAN := FALSE;
   g_reset_lang_flag       BOOLEAN                          := FALSE;
   g_reset_resp_flag       BOOLEAN                          := FALSE;
 --varangan added the formula name variable for bug #5036582
   g_formula_out_billed    CONSTANT okl_formulae_v.name%TYPE := 'OKL_LC_OUTSTANDING_BILLED';
   g_formula_out_unbilled  CONSTANT okl_formulae_v.name%TYPE := 'OKL_LC_OUTSTANDING_UNBILLED';
 --varangan added the formula name variable for bug #5036582

  --varangan added the formula name variable for bug #5009351
   g_formula_next_payment_amt CONSTANT okl_formulae_v.name%TYPE := 'OKL_LC_NEXT_PAYMENT_AMOUNT';

   TYPE sec_group_tbl IS TABLE OF okc_k_accesses.group_id%TYPE;
   g_sec_groups  sec_group_tbl;

  PROCEDURE EXECUTE(p_api_version           IN  NUMBER
                   ,p_init_msg_list         IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                   ,x_return_status         OUT NOCOPY VARCHAR2
                   ,x_msg_count             OUT NOCOPY NUMBER
                   ,x_msg_data              OUT NOCOPY VARCHAR2
                   ,p_formula_name          IN  VARCHAR2
                   ,p_contract_id           IN  NUMBER
                   ,x_value                 OUT NOCOPY NUMBER
                   ) IS
    CURSOR deal_type IS
      SELECT khr.deal_type
      FROM okl_k_headers_v khr ,fnd_lookups fnd
      WHERE fnd.lookup_type = 'OKL_BOOK_CLASS'
      AND fnd.lookup_code = khr.deal_type
      AND id = p_contract_id;

  --bug# 5032491 rkuttiya added cursor for revenue recognition
   CURSOR c_revenue_recogn(p_khr_id IN NUMBER) IS
   SELECT revenue_recognition_method
   FROM  okl_product_parameters_v pdt,
         okl_k_headers            khr
   WHERE KHR.ID = p_khr_id
   AND KHR.PDT_ID = PDT.ID;

   l_deal_type           VARCHAR2(30);
 --bug# 5032491
   l_revenue_recogn      VARCHAR2(150);
   l_outstanding_bal     NUMBER;
 --
    l_formula_name        VARCHAR2(100);
  BEGIN
    OPEN deal_type;
    FETCH deal_type INTO l_deal_type;
    CLOSE deal_type;
    OPEN c_revenue_recogn(p_contract_id);
    FETCH c_revenue_recogn INTO l_revenue_recogn;
    CLOSE c_revenue_recogn;

--bug# 5032491 to check for Loan and Loan Revolving
   IF l_deal_type NOT IN ('LOAN','LOAN-REVOLVING') THEN
      IF l_deal_type IN ('LEASEDF','LEASEST') THEN
        l_formula_name := 'CONTRACT_NET_INVESTMENT_DF';
      --bug# 5032491 rkuttiya commenting out following
      --ELSIF l_deal_type IN ('LOAN','LOAN-REVOLVING') THEN
        --l_formula_name := 'CONTRACT_NET_INVESTMENT_LOAN';
      ELSIF l_deal_type IN ('LEASEOP') THEN
        l_formula_name := 'CONTRACT_NET_INVESTMENT_OP';
      END IF;
      Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => p_api_version
                                   ,p_init_msg_list        =>p_init_msg_list
                                   ,x_return_status        =>x_return_status
                                   ,x_msg_count            =>x_msg_count
                                   ,x_msg_data             =>x_msg_data
                                   ,p_formula_name         =>l_formula_name
                                   ,p_contract_id          =>p_contract_id
                                   ,x_value               =>x_value
                                   );
    END IF;

-- bug# 5032491 rkuttiya added the following for Loan and Loan Revolving contracts
    IF l_deal_type  IN ('LOAN','LOAN-REVOLVING') THEN
      OPEN c_revenue_recogn(p_contract_id);
      FETCH c_revenue_recogn INTO l_revenue_recogn;
      CLOSE c_revenue_recogn;

      l_outstanding_bal := OKL_VARIABLE_INT_UTIL_PVT.get_principal_bal(x_return_status => x_return_status,
                                                                   p_khr_id        => p_contract_id,
                                                                   p_kle_id        => NULL,
                                                                   p_date          => SYSDATE);

      IF l_revenue_recogn = 'ACTUAL' AND l_outstanding_bal <> 0 THEN
        x_value := 0;
      ELSE
        l_formula_name := 'CONTRACT_NET_INVESTMENT_LOAN';
        Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => p_api_version
                                       ,p_init_msg_list        =>p_init_msg_list
                                       ,x_return_status        =>x_return_status
                                       ,x_msg_count            =>x_msg_count
                                       ,x_msg_data             =>x_msg_data
                                       ,p_formula_name         =>l_formula_name
                                       ,p_contract_id          =>p_contract_id
                                       ,x_value               =>x_value
                                        );

      END IF;
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
      CLOSE deal_type;
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
  END;


  PROCEDURE next_due(p_contract_id     IN  NUMBER,
                     o_next_due_amt    OUT NOCOPY NUMBER,
                     o_next_due_date   OUT NOCOPY DATE
        		    ) IS
--Begin-varangan-bug#5009351

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

  lx_return_status VARCHAR2(1);
  lx_msg_count     NUMBER;
  lx_msg_data      VARCHAR2(2000);
BEGIN
  OPEN cr_next_payment_date(p_contract_id);
  FETCH cr_next_payment_date INTO o_next_due_date;
  CLOSE cr_next_payment_date;

  Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => 1.0
                                 ,p_init_msg_list        => null
                                 ,x_return_status        => lx_return_status
                                 ,x_msg_count            => lx_msg_count
                                 ,x_msg_data             => lx_msg_data
                                 ,p_formula_name         => g_formula_next_payment_amt
                                 ,p_contract_id          => p_contract_id
                                 ,x_value                => o_next_due_amt
                                 );

--End-varangan-bug#5009351

/*  --Start-commented old code - varangan-Bug#5009351*

  -- rvaduri to fix bug 2949018
  -- and added the following code.
  --NOTE: No Multi currency conversions reqd because amounts in
  --Streams tables are already in Contract Currency.

  --Modified the following cursor by adding c_stream_name
  --for bug fix 2993308
  -- replaced type name with purpose, enhancements for user defined streams bug
  -- 3924303
  CURSOR next_due_date(c_contract_id NUMBER,c_stream_type_purpose VARCHAR2) IS
  SELECT MIN(sel.stream_element_date)
  FROM okl_strm_elements sel
    ,okl_streams stm
    ,okl_strm_type_v sty
  WHERE sty.stream_type_purpose = c_stream_type_purpose
  AND stm.sty_id = sty.id
  AND stm.say_code = 'CURR'
  AND stm.active_yn = 'Y'
  AND stm.purpose_code is NULL
  AND stm.khr_id = c_contract_id
  AND sel.stm_id = stm.id
  and date_billed is null
  AND sel.amount > 0 ;


  --Modified the following cursor by adding c_stream_name
  --for bug fix 2993308
  -- replaced type name with purpose, enhancements for user defined streams bug
  -- 3924303
  CURSOR next_due_amount(c_next_due_date DATE,c_contract_id NUMBER
			,c_stream_type_purpose  VARCHAR2) IS
  SELECT NVL(sum(sel.amount),0)
      FROM okl_strm_elements sel,
           okl_streams stm,
           okl_strm_type_v sty
	--Bug 4084405
      WHERE sty.stream_type_purpose = c_stream_type_purpose
        AND stm.sty_id = sty.id
        AND stm.say_code = 'CURR'
        AND stm.active_yn = 'Y'
        AND stm.purpose_code is NULL
        AND stm.khr_id = c_contract_id
        AND sel.stm_id = stm.id
        AND date_billed is null
        AND sel.stream_element_date = c_next_due_date;

--Added the following cursor for bug fix 2993308

    CURSOR deal_type IS
      SELECT deal_type
      FROM okl_k_headers
      WHERE  id = p_contract_id;

   l_deal_type   VARCHAR2(30);
   l_stream_name   VARCHAR2(30);
   l_stream_type_purpose_for_date VARCHAR2(100);
   l_stream_type_purpose_for_amt VARCHAR2(100);

BEGIN

   OPEN deal_type;
   FETCH deal_type INTO l_deal_type;
   CLOSE deal_type;

   IF l_deal_type IN ('LOAN','LOAN-REVOLVING') THEN
	--l_stream_name := 'LOAN PAYMENT';
	--Bug 4084405
	--For getting the Due date we will use Principal Payment
	--as loan payment is not a billable stream.
	--For getting the next payment amount we will use loan payment
	--as the payment comprises of prin payment + int Payment.
       l_stream_type_purpose_for_date := 'PRINCIPAL_PAYMENT';
       l_stream_type_purpose_for_amt := 'LOAN_PAYMENT';

   ELSE
--	l_stream_name := 'RENT';
	--bug 4084405
        l_stream_type_purpose_for_date := 'RENT';
        l_stream_type_purpose_for_amt := 'RENT';
   END IF;

  OPEN next_due_date(p_contract_id,l_stream_type_purpose_for_date);
  FETCH next_due_date INTO o_next_due_date;
  CLOSE next_due_date;
  IF (o_next_due_date is not null) then
      OPEN next_due_amount(o_next_due_date,p_contract_id
				,l_stream_type_purpose_for_amt);
      FETCH next_due_amount INTO  o_next_due_amt;
      CLOSE next_due_amount;
  ELSE
      o_next_due_amt := 0;
  END IF;
  --End-commented-varangan-Bug#5009351*/
 EXCEPTION
    WHEN OTHERS THEN
     IF cr_next_payment_date%ISOPEN
    THEN
      CLOSE cr_next_payment_date;
    END IF;

    /* Commented-varangan-Bug#5009351
       CLOSE next_due_date;
       CLOSE next_due_amount; */

    Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
END next_due;



PROCEDURE last_due(p_customer_id     IN  NUMBER,
                   p_contract_id     IN NUMBER,
                   o_last_due_amt    OUT NOCOPY NUMBER,
                   o_last_due_date   OUT NOCOPY DATE
        		    ) IS
CURSOR last_due IS
--MultiCurrency Changes.
--mutlipying the amount with exchange rate to convert the currency from
--Transaction currency to Functional Curreny.
--dkagrawa changed the query to adopt new billing architecture
/*SELECT (AR.amount * NVL(AR.exchange_rate,1)), AR.receipt_date
FROM ar_cash_receipts_all ar,
okc_k_headers_b chr,
ar_receivable_applications_all ara,
okl_cnSld_ar_strms_b lsm
WHERE
ar.pay_from_customer = chr.cust_acct_id
and chr.id = p_contract_id
AND ar.cash_receipt_id = ara.cash_receipt_id
AND LSM.RECEIVABLES_INVOICE_ID = ARA.APPLIED_CUSTOMER_TRX_ID
AND lsm.khr_id  = p_contract_id
ORDER BY receipt_date DESC;*/

SELECT (AR.amount * NVL(AR.exchange_rate,1)), AR.receipt_date
FROM ar_cash_receipts_all ar,
okl_receipt_applications_uv app,
okc_k_headers_b chr
WHERE chr.id = p_contract_id
AND ar.cash_receipt_id = app.cash_receipt_id
AND ar.pay_from_customer = p_customer_id
AND CHR.contract_number = app.contract_number
ORDER BY receipt_date DESC;

 BEGIN
  OPEN last_due;
  FETCH last_due INTO  o_last_due_amt,o_last_due_date;
  CLOSE last_due;
    EXCEPTION
    WHEN OTHERS THEN
      CLOSE last_due;
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
END;
PROCEDURE total_asset_cost(p_contract_id     IN  NUMBER,
                           o_asset_cost     OUT NOCOPY NUMBER
                 	  ) IS

--Modified for bug 8533160 to not include ABANDONED assets
CURSOR asset_cost IS
select nvl(sum(okl.oec) ,0)
from okc_k_lines_v okc
    ,okl_k_lines okl
    ,okc_line_styles_v lse
where okc.id=okl.id
and  okc.lse_id = lse.id
and lse.lty_code='FREE_FORM1'
and okc.sts_code NOT IN ('ABANDONED')
and okc.chr_id = p_contract_id;

 BEGIN
  OPEN asset_cost;
  FETCH asset_cost INTO  o_asset_cost;
  CLOSE asset_cost;
    EXCEPTION
    WHEN OTHERS THEN
    CLOSE asset_cost;
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
END;

-- smoduga
-- Added for displaying Total subsidised cost for the Contract on forms Overview tab.
PROCEDURE total_subsidy_cost(p_contract_id     IN  NUMBER,
                           o_subsidy_cost     OUT NOCOPY NUMBER
                 	  ) IS

l_parent_line_id NUMBER;

CURSOR parent_line_id IS
select okc.id
from okc_k_lines_v okc
    ,okl_k_lines okl
    ,okc_line_styles_v lse
where okc.id=okl.id
and  okc.lse_id = lse.id
and lse.lty_code='FREE_FORM1'
and okc.chr_id = p_contract_id;

 CURSOR c_subsidy(c_contract_id IN NUMBER,c_parent_line_id IN NUMBER) IS
  select nvl(sum(nvl(KLE1.subsidy_override_amount,KLE1.amount)),0) amount
  from OKL_K_LINES KLE1,
     OKC_K_LINES_B CLE1,
     OKC_LINE_STYLES_B LS1,
     OKL_ASSET_SUBSIDY_UV SUB,
     OKL_SUBSIDIES_B SUBB,
     OKL_SUBSIDIES_TL SUBT,
     OKC_STATUSES_V STS1
  where KLE1.ID = CLE1.ID
      AND CLE1.LSE_ID = LS1.ID
      AND LS1.LTY_CODE ='SUBSIDY'
      AND cle1.dnz_chr_id = c_contract_id -- from parameter
      AND CLE1.STS_CODE = STS1.CODE
      AND CLE1.STS_CODE <> 'ABANDONED'
      AND SUB.SUBSIDY_ID = KLE1.SUBSIDY_ID
      AND SUB.ASSET_CLE_ID = c_parent_line_id -- parent_line_id from grid
      AND SUB.dnz_chr_id = cle1.dnz_chr_id
      AND SUB.subsidy_cle_id = KLE1.ID
      AND SUBB.ID = KLE1.SUBSIDY_ID
      AND SUBT.ID = SUBB.ID
      And subt.language  = userenv('LANG')
      AND SUBB.accounting_method_code = 'NET'
      AND SUBB.CUSTOMER_VISIBLE_YN = 'Y';



 BEGIN
  OPEN parent_line_id;
  FETCH parent_line_id INTO  l_parent_line_id;
  CLOSE parent_line_id;

  OPEN c_subsidy(p_contract_id,l_parent_line_id);
  FETCH c_subsidy INTO o_subsidy_cost;
   IF (c_subsidy%NOTFOUND) THEN
    CLOSE c_subsidy;
    o_subsidy_cost := 0;
   END IF;
  CLOSE c_subsidy;

    EXCEPTION
    WHEN OTHERS THEN
    CLOSE parent_line_id;
    CLOSE c_subsidy;
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
END;

--varangan bug#5036582, added the procedures to get the billed and unbilled
--outstanding using formulas starts

 PROCEDURE out_standing_rcvble(p_contract_id     IN  NUMBER,
                                o_rcvble_amt     OUT NOCOPY NUMBER) IS
    lx_return_status VARCHAR2(1);
    lx_msg_count     NUMBER;
    lx_msg_data      VARCHAR2(2000);
  BEGIN
    null;
  EXCEPTION
    WHEN OTHERS THEN
     Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);
  END out_standing_rcvble;

  PROCEDURE outstanding_billed_amt(p_contract_id     IN  NUMBER,
                                   o_billed_amt      OUT NOCOPY NUMBER) IS
    lx_return_status VARCHAR2(1);
    lx_msg_count     NUMBER;
    lx_msg_data      VARCHAR2(2000);
  BEGIN
    OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => 1.0,
                                    p_init_msg_list => null,
                                    x_return_status => lx_return_status,
                                    x_msg_count     => lx_msg_count,
                                    x_msg_data      => lx_msg_data,
                                    p_formula_name  => g_formula_out_billed,
                                    p_contract_id   => p_contract_id,
                                    x_value         => o_billed_amt);
  EXCEPTION
    WHEN OTHERS THEN
     Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);
  END outstanding_billed_amt;

  PROCEDURE outstanding_unbilled_amt(p_contract_id     IN  NUMBER,
                                     o_unbilled_amt    OUT NOCOPY NUMBER) IS
    lx_return_status VARCHAR2(1);
    lx_msg_count     NUMBER;
    lx_msg_data      VARCHAR2(2000);
  BEGIN
    OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => 1.0,
                                    p_init_msg_list => null,
                                    x_return_status => lx_return_status,
                                    x_msg_count     => lx_msg_count,
                                    x_msg_data      => lx_msg_data,
                                    p_formula_name  => g_formula_out_unbilled,
                                    p_contract_id   => p_contract_id,
                                    x_value         => o_unbilled_amt);
  EXCEPTION
    WHEN OTHERS THEN
     Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);
  END outstanding_unbilled_amt;

 --varangan bug#5036582 end


PROCEDURE contract_dates(p_contract_id     IN  NUMBER,
                           o_start_date      OUT NOCOPY DATE,
                           o_end_date        OUT NOCOPY DATE,
                           o_term_duration   OUT NOCOPY NUMBER) IS
CURSOR contract_dates IS
SELECT khr.start_date,khr.end_date,okhr.term_duration
FROM OKL_K_HEADERS okhr ,okc_k_headers_v khr
WHERE okhr.id = khr.id
      AND khr.id = p_contract_id;
 BEGIN
  OPEN contract_dates;
  FETCH contract_dates INTO  o_start_date,o_end_date,o_term_duration;
  CLOSE contract_dates ;
  EXCEPTION
    WHEN OTHERS THEN
    CLOSE contract_dates ;
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
END;
  PROCEDURE     rent_security_interest(p_contract_id      IN  NUMBER,
                           o_advance_rent     OUT NOCOPY NUMBER,
                           o_security_deposit OUT NOCOPY NUMBER,
                           o_interest_type    OUT NOCOPY VARCHAR2) IS
CURSOR advance_rent IS
  SELECT SUM(NVL(orv1.rule_information6,0))
  FROM okc_rules_v orv1,
       okc_rule_groups_b org1
  WHERE  org1.dnz_chr_id = p_contract_id
     and org1.dnz_chr_id = org1.chr_id
     AND org1.id = orv1.rgp_id
     AND orv1.rule_information_category = 'LASLL'
     AND exists
        ( SELECT 'x'
          FROM okc_k_headers_v okhdr,
               okc_rule_groups_b org,
               okc_rules_v  orv,
               OKL_STRMTYP_SOURCE_V stm
          WHERE okhdr.id = org1.dnz_chr_id
            and okhdr.id = org.dnz_chr_id
            and org.chr_id = org.dnz_chr_id
            AND org.rgd_code = 'LALEVL'
            AND org.id = orv.rgp_id
            AND orv.rule_information_category ='LASLH'
            AND jtot_object1_code ='OKL_STRMTYP'
            AND object1_id1 = stm.id1
            AND object1_id2 = stm.id2
            AND stm.stream_type_purpose ='RENT');
-- cursor changed to filter the streams based on the purpose 'SECURITY_DEPOSIT'
-- and the amounts summed up, enhancement done for user defined streams impacts, bug 3924303

  CURSOR security_deposit IS
    SELECT	ste.amount		amount
		FROM	okc_k_lines_b		kle,
			okc_line_styles_b	lse,
			okc_k_items		ite,
			okl_strm_type_b		sty1,
			okl_streams		stm,
			okl_strm_type_b		sty2,
			okl_strm_elements	ste
		WHERE	kle.chr_id		= p_contract_id
		AND	lse.id			= kle.lse_id
		AND	lse.lty_code		= 'FEE'
		AND	ite.cle_id		= kle.id
		AND	ite.jtot_object1_code	= 'OKL_STRMTYP'
		AND	sty1.id			= ite.object1_id1
		AND	sty1.stream_type_purpose= 'SECURITY_DEPOSIT'
		AND	stm.kle_id		= kle.id
		AND	stm.khr_id		= p_contract_id
		AND	stm.active_yn		= 'Y'
		AND	stm.say_code		= 'CURR'
           	--multigaap changes
           	AND     stm.PURPOSE_CODE	IS NULL
           	--end multigaap changes
		AND	sty2.id			= stm.sty_id
		AND	sty2.stream_type_purpose= 'SECURITY_DEPOSIT'
		AND	ste.stm_id		= stm.id
		AND	ste.date_billed		IS NOT NULL
		AND	NVL (ste.amount, 0)	<> 0;
--rkuttiya modifed for bug # 5031455 join condition of cursor to use dnz_chr_id instead of chr_id
CURSOR Interest_Type IS
  SELECT DECODE(rule_information1, 'Y', 'Variable', 'N', 'Fixed', 'Unknown')
  FROM OKC_K_HEADERS_B CHR,okc_rule_groups_b RGP,okc_rules_b RUL
  WHERE CHR.ID = RGP.DNZ_CHR_ID AND
   --CHR.ID = RGP.CHR_ID AND
        RGP.ID = RUL.RGP_ID AND
        RUL.rule_information_category = 'LAINTP' AND
		CHR.id = p_contract_id;

 BEGIN
  OPEN advance_rent;
  FETCH advance_rent INTO o_advance_rent;
  CLOSE advance_rent ;
  OPEN security_deposit;
  FETCH security_deposit INTO o_security_deposit;
  CLOSE security_deposit;
  OPEN Interest_type;
  FETCH Interest_type INTO o_interest_type;
  CLOSE Interest_type;
  EXCEPTION
    WHEN OTHERS THEN
    CLOSE advance_rent ;
    CLOSE security_deposit;
    CLOSE Interest_type;
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
END;
  PROCEDURE notes(p_contract_id     IN  NUMBER,
                  o_notes           OUT NOCOPY VARCHAR2
      		    ) IS
CURSOR notes IS
 SELECT notes,last_update_date FROM jtf_notes_vl
 WHERE source_object_id = p_contract_id
       AND SOURCE_OBJECT_CODE = 'OKC_K_HEADER'
 ORDER BY last_update_date DESC;
  l_date  DATE;
   BEGIN
  OPEN notes;
  FETCH notes INTO  o_notes,l_date;
  CLOSE notes;
  EXCEPTION
  WHEN OTHERS THEN
    CLOSE notes;
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
END;
  ---------------------------------------------------------------------------
  -- FUNCTION get_vendor_program
  ---------------------------------------------------------------------------
  FUNCTION get_vendor_program(
     p_contract_id			IN NUMBER,
     x_vendor_program		     	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    CURSOR vendor_program_cur(p_contract_id NUMBER) IS
      SELECT PROGRAM_CONTRACT_NUMBER
      FROM okl_k_hdrs_full_uv
      WHERE  CHR_ID = p_contract_id;
    l_vendor_program		    VARCHAR2(240);
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
  BEGIN
    OPEN  vendor_program_cur(p_contract_id);
    FETCH vendor_program_cur INTO l_vendor_program;
    CLOSE vendor_program_cur;
    x_vendor_program := l_vendor_program;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END get_vendor_program;
  ---------------------------------------------------------------------------
  -- FUNCTION get_private_label
  ---------------------------------------------------------------------------
  FUNCTION get_private_label(
     p_contract_id			IN NUMBER,
     x_private_label          	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    l_api_version           NUMBER :=1;
    l_init_msg_list         VARCHAR2(1) DEFAULT Okl_Api.G_FALSE;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_party_tab             Okl_Jtot_Extract.party_tab_type;
  BEGIN
    -- Procedure to call to get Private Label ID, nothing but
    -- a Role
    Okl_Jtot_Extract.Get_Party (
          l_api_version,
          l_init_msg_list,
          l_return_status,
          l_msg_count,
          l_msg_data,
          p_contract_id,
          NULL,
          'PRIVATE_LABEL',
          'S',
          l_party_tab
          );
    x_private_label := l_party_tab(1).name;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END get_private_label;
  ---------------------------------------------------------------------------
  -- FUNCTION get_currency
  ---------------------------------------------------------------------------
  FUNCTION get_currency(
     p_contract_id			IN NUMBER,
     x_currency			     	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    CURSOR currency_cur(p_contract_id NUMBER) IS
      SELECT currency_code
      FROM   okc_k_headers_b
      WHERE  id = p_contract_id;
    l_currency			    VARCHAR2(240);
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
  BEGIN
    OPEN  currency_cur(p_contract_id);
    FETCH currency_cur INTO l_currency;
    CLOSE currency_cur;
    x_currency := l_currency;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END get_currency;
  ---------------------------------------------------------------------------
  -- FUNCTION get_syndicate_flag
  ---------------------------------------------------------------------------
  FUNCTION get_syndicate_flag(
     p_contract_id			IN NUMBER,
     x_syndicate_flag		     	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    CURSOR syndicate_flag_cur(p_contract_id NUMBER) IS
      SELECT 'Y'  FROM okc_k_headers_b CHR
      WHERE id = p_contract_id
      AND EXISTS
          (
           SELECT 'x' FROM okc_k_items cim
           WHERE  cim.object1_id1 = TO_CHAR(CHR.id)
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
                   AND    chr2.sts_code NOT IN ('TERMINATED','ABANDONED')
                  )
          )
      AND CHR.scs_code IN ('LEASE','LOAN');
    l_syndicate_flag		    VARCHAR2(1) := 'N';
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
  BEGIN
    OPEN  syndicate_flag_cur(p_contract_id);
    FETCH syndicate_flag_cur INTO l_syndicate_flag;
    CLOSE syndicate_flag_cur;
    x_syndicate_flag := l_syndicate_flag;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END get_syndicate_flag;
  ---------------------------------------------------------------------------
  -- FUNCTION GET_ORG_ID
  ---------------------------------------------------------------------------
  FUNCTION GET_ORG_ID(
			     	p_contract_id	IN NUMBER,
				x_org_id		OUT NOCOPY NUMBER
			   )
  RETURN VARCHAR2 AS
  -- get org_id for contract
    CURSOR get_org_id_cur (p_contract_id IN VARCHAR2) IS
      SELECT authoring_org_id
      FROM   okc_k_headers_b
      WHERE  id = p_contract_id;
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
  BEGIN
    OPEN get_org_id_cur(p_contract_id);
    FETCH get_org_id_cur INTO x_org_id;
    CLOSE get_org_id_cur;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
    CLOSE get_org_id_cur;
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END GET_ORG_ID;
  ---------------------------------------------------------------------------
  -- FUNCTION GET_RESOURCE_ID
  ---------------------------------------------------------------------------
  FUNCTION GET_RESOURCE_ID(	x_res_id		OUT NOCOPY NUMBER
 			   )
  RETURN VARCHAR2 AS
  -- get org_id for contract
    CURSOR get_res_id_cur(l_user_id NUMBER) IS
      SELECT resource_id
	  FROM jtf_rs_resource_extns
      WHERE user_id = l_user_id;
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_user_id               NUMBER(10);
  BEGIN
    l_user_id := Fnd_Profile.value('USER_ID');
    OPEN get_res_id_cur(l_user_id );
    FETCH get_res_id_cur INTO x_res_id;
    CLOSE get_res_id_cur;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
    CLOSE get_res_id_cur;
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END GET_resource_ID;
  FUNCTION get_warning_message(
     p_contract_id			IN NUMBER,
     x_delinquent_flag		     	OUT NOCOPY VARCHAR2,
     x_bankrupt_flag		     	OUT NOCOPY VARCHAR2,
     x_syndicate_flag		     	OUT NOCOPY VARCHAR2,
     x_special_handling_flag	     	OUT NOCOPY VARCHAR2
)
  RETURN VARCHAR2
  IS
    CURSOR syndicate_flag_cur(p_contract_id NUMBER) IS
      SELECT 'Y'  FROM okc_k_headers_b CHR
      WHERE id = p_contract_id
      AND EXISTS
          (
           SELECT 'x' FROM okc_k_items cim
           WHERE  cim.object1_id1 = TO_CHAR(CHR.id)
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
                   AND    chr2.sts_code NOT IN ('TERMINATED','ABANDONED')
                  )
          )
      AND CHR.scs_code IN ('LEASE','LOAN');
    l_flag		    VARCHAR2(1) := 'N';
    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
  BEGIN
    OPEN  syndicate_flag_cur(p_contract_id);
    FETCH syndicate_flag_cur INTO l_flag;
    CLOSE syndicate_flag_cur;
    x_syndicate_flag := l_flag;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END get_warning_message;
  PROCEDURE Set_Connection_Context IS
   BEGIN
	IF (g_user_id = Okl_Api.G_MISS_NUM) OR
	   (g_user_id <> Fnd_Global.user_id) THEN
       g_user_id := Fnd_Global.user_id;
	  g_reset_access_flag := TRUE;
	  g_reset_lang_flag := TRUE;
     END IF;
	IF (g_resp_id = Okl_Api.G_MISS_NUM) OR
	   (g_resp_id <> Fnd_Global.resp_id) THEN
       g_resp_id := Fnd_Global.resp_id;
	  g_reset_resp_flag := TRUE;
     END IF;
   END;
  FUNCTION Get_K_Access_Level(p_chr_id IN NUMBER,
                            p_scs_code IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2 IS
  l_scs_code okc_k_headers_b.scs_code%TYPE;
  l_modify_access         CONSTANT VARCHAR2(1) := 'U';
  l_read_access           CONSTANT VARCHAR2(1) := 'R';
  l_no_access             CONSTANT VARCHAR2(1) := 'N';
  l_resp_access           okc_subclass_resps.access_level%TYPE;
  l_resource_access       okc_subclass_resps.access_level%TYPE;
  l_group_access          okc_k_accesses.access_level%TYPE;
  l_group_id              okc_k_accesses.group_id%TYPE;
  l_row_notfound          BOOLEAN;
  l_group_has_read_access BOOLEAN;
  l_date                  DATE := SYSDATE;
  exception_modify_access EXCEPTION;
  exception_read_access   EXCEPTION;
  exception_no_access     EXCEPTION;
  -- This cursor retrieves the sub class code for the contract. This is
  -- executed only if the subclass is not passed in
  CURSOR chr_csr IS
  SELECT scs_code
    FROM okc_k_headers_b
   WHERE id = p_chr_id;
  -- This cursor checks to see the type of access granted to the current
  -- user'S responsibility TO the sub class
  CURSOR resp_csr IS
  SELECT ras.access_level
    FROM okc_subclass_resps ras
   WHERE ras.scs_code = l_scs_code
     AND ras.resp_id  = Fnd_Global.resp_id
     AND l_date BETWEEN ras.start_date AND NVL(ras.end_date, l_date);
  -- This cursor retrieves the resource id corresponding to the logged
  -- in user. The resource has to have a role of CONTRACT for this to be
  -- considered
  CURSOR res_csr IS
  SELECT res.resource_id
    FROM jtf_rs_resource_extns res,
         jtf_rs_role_relations rrr,
         jtf_rs_roles_b        rr
   WHERE res.user_id              = Fnd_Global.user_id
     AND l_date BETWEEN res.start_date_active
                    AND NVL(res.end_date_active, l_date)
     AND res.resource_id          = rrr.role_resource_id
     AND rrr.role_resource_type   = 'RS_INDIVIDUAL'
     AND NVL(rrr.delete_flag,'N') = 'N'
     AND l_date BETWEEN rrr.start_date_active
                     AND NVL(rrr.end_date_active, l_date)
     AND rrr.role_id              = rr.role_id
     AND rr.role_type_code        = 'CONTRACTS';
  -- This checks the access level for the resource and the contract
  CURSOR res_acc_csr IS
  SELECT cas.access_level
    FROM okc_k_accesses cas
   WHERE cas.chr_id = p_chr_id
     AND cas.resource_id = g_user_resource_id;
  -- This cursor selects all the resource groups and the access level
  -- for the contract.
  CURSOR grp_acc_csr IS
  SELECT cas.group_id,
         cas.access_level
    FROM okc_k_accesses cas
   WHERE cas.chr_id = p_chr_id
     AND cas.group_id IS NOT NULL
   ORDER BY 2 DESC;
  -- This cursor selects all the resource groups that the resource
  -- belongs to. Fetched only once per session. The retrieved rows are
  -- stored in pl/sql global table and this table is used for
  -- subsequent contracts in the same session.
  CURSOR res_grp_csr IS
  SELECT rgm.group_id
    FROM jtf_rs_group_members  rgm,
         jtf_rs_role_relations rrr,
         jtf_rs_roles_b        rr,
         jtf_rs_groups_b       rgb
   WHERE rgm.resource_id          = g_user_resource_id
     AND rgm.group_id             = rgb.group_id
     AND l_date BETWEEN NVL(rgb.start_date_active, l_date)
                    AND NVL(rgb.end_date_active, l_date)
     AND rgm.group_id             = rrr.role_resource_id
     AND NVL(rgm.delete_flag,'N') = 'N'
     AND rrr.role_resource_type   = 'RS_GROUP'
     AND NVL(rrr.delete_flag,'N') = 'N'
     AND l_date BETWEEN rrr.start_date_active
                    AND NVL(rrr.end_date_active, l_date)
     AND rrr.role_id              = rr.role_id
     AND rr.role_type_code        = 'CONTRACTS'
   UNION
  SELECT rgd.parent_group_id
    FROM jtf_rs_group_members  rgm,
         jtf_rs_groups_denorm  rgd,
         jtf_rs_role_relations rrr,
         jtf_rs_roles_b        rr,
         jtf_rs_groups_b       rgb
   WHERE rgm.resource_id          = g_user_resource_id
     AND NVL(rgm.delete_flag,'N') = 'N'
     AND rgd.group_id             = rgm.group_id
     AND rgd.parent_group_id      = rgb.group_id
     AND l_date BETWEEN NVL(rgb.start_date_active, l_date)
                    AND NVL(rgb.end_date_active, l_date)
     AND rgd.parent_group_id      = rrr.role_resource_id
     AND rrr.role_resource_type   = 'RS_GROUP'
     AND NVL(rrr.delete_flag,'N') = 'N'
     AND l_date BETWEEN rrr.start_date_active
                     AND NVL(rrr.end_date_active, l_date)
     AND rrr.role_id              = rr.role_id
     AND rr.role_type_code        = 'CONTRACTS';
BEGIN
  -- Global variable g_user_id introduced to resolve the problem of connection pooling.
  -- This variable is not guaranteed to be same for the same user across multiple
  -- web requests. So everytime a global needs to be checked, make sure it was built
  -- by the same user.
  Set_Connection_Context;
  -- If no contract identifier is passed, then do not allow access
  IF p_chr_id IS NULL THEN
    RAISE Exception_No_Access;
  END IF;
  -- If the sub class is not passed in, then derive it using the
  -- contract identifier
  l_scs_code := p_scs_code;
  IF l_scs_code IS NULL THEN
    -- Get the subclass/category from the contracts table
    OPEN chr_csr;
    FETCH chr_csr INTO l_scs_code;
    l_row_notfound := chr_csr%NOTFOUND;
    CLOSE chr_csr;
    IF l_row_notfound THEN
      RAISE Exception_No_Access;
    END IF;
  END IF;
  -- fnd_log.string(1, 'okl', 'l_scs_code : ' || l_scs_code);
  -- Determine if the access for the category and responsibility has
  -- been determined earlier and cached in the global variables. If not,
  -- then determine it using the resp_csr g_resp_access is initialized
  -- to g_miss_char. If this could not be determined the first time
  -- around, the variables are set to null and not examined during the
  -- next round
  IF (l_scs_code <> g_scs_code) OR (g_reset_resp_flag) THEN
    OPEN resp_csr;
    FETCH resp_csr INTO l_resp_access;
    l_row_notfound := resp_csr%NOTFOUND;
    CLOSE resp_csr;
    IF l_row_notfound THEN
      l_resp_access := NULL;
    END IF;
    -- fnd_log.string(1, 'okl', 'l_resp_access : ' || l_resp_access);
    -- Save the current access level into global variables. If no access
    -- was determined, the local variables hold null and so do the global
    -- variables
    g_scs_code    := l_scs_code;
    g_resp_access := l_resp_access;
    IF g_reset_resp_flag THEN
      g_reset_resp_flag := FALSE;
    END IF;
  END IF;
  -- Check the access level at the category and responsibility level first
  IF g_resp_access = l_modify_access THEN
    RAISE Exception_Modify_Access;
  END IF;
  -- If could not find 'Update' access from the user's responsibility,
  -- continue to check if granted any access at the user resource level.
  -- If the user resource id is not determined earlier, then retrieve it
  -- and cache it as it will not change during the current session
  IF (g_user_resource_id = Okl_Api.G_MISS_NUM) OR
	(g_reset_access_flag) THEN
    OPEN res_csr;
    FETCH res_csr INTO g_user_resource_id;
    l_row_notfound := res_csr%NOTFOUND;
    CLOSE res_csr;
    g_groups_processed := FALSE;
    IF l_row_notfound THEN
      g_user_resource_id := NULL;
    END IF;
  END IF;
  -- Determine the access level for the resource id on the contract
  IF g_user_resource_id IS NOT NULL THEN
    OPEN res_acc_csr;
    FETCH res_acc_csr INTO l_resource_access;
    CLOSE res_acc_csr;
    IF l_resource_access = l_modify_access THEN
      RAISE Exception_Modify_Access;
    END IF;
    -- fnd_log.string(1, 'okl', 'l_resource_access : ' || l_resource_access);
    -- Since the resource does not have Update access, we need to get its
    -- parent group and its grand parent groups (recursively). Cache it in
    -- the global pl/sql table since this hierarchy is not going to change
    -- for a resource. So do it only for the first time. Do this by
    -- examining the global variable g_groups_processed. This indicates
    -- that the array of groups has been retrieved for the session
    IF g_groups_processed THEN
	 NULL;
    ELSE
      OPEN res_grp_csr;
      FETCH res_grp_csr BULK COLLECT INTO g_sec_groups;
      CLOSE res_grp_csr;
      g_groups_processed := TRUE;
    END IF;
    -- Finally check for any access granted at the group level.
    -- Do it only if the resource belongs to at least one group
    -- fnd_log.string(1, 'okl', 'g_sec_groups.count : ' || to_char(g_sec_groups.count));
    l_group_has_read_access := FALSE;
    IF g_sec_groups.COUNT > 0 THEN
      OPEN grp_acc_csr;
      LOOP
        -- Get all the groups assigned to the contract
        FETCH grp_acc_csr INTO l_group_id, l_group_access;
	   EXIT WHEN grp_acc_csr%NOTFOUND;
        FOR i IN 1 .. g_sec_groups.LAST
        LOOP
	     IF g_sec_groups(i) = l_group_id THEN
            -- If the groups match and access level is 'U', exit immediately
		  IF l_group_access = l_modify_access THEN
              RAISE Exception_Modify_Access;
            END IF;
		  IF l_group_access = l_read_access THEN
		    l_group_has_read_access := TRUE;
            END IF;
          END IF;
        END LOOP;
      END LOOP;
      CLOSE grp_acc_csr;
    END IF;
  END IF;
  IF (l_read_access IN (g_resp_access, l_resource_access)) OR
     l_group_has_read_access THEN
    RAISE Exception_Read_Access;
  END IF;
  RAISE Exception_No_Access;
EXCEPTION
  WHEN Exception_Modify_Access THEN
    IF grp_acc_csr%ISOPEN THEN
      CLOSE grp_acc_csr;
    END IF;
    IF g_reset_access_flag THEN
      g_reset_access_flag := FALSE;
    END IF;
    RETURN(l_modify_access);
  WHEN Exception_Read_Access THEN
    IF g_reset_access_flag THEN
      g_reset_access_flag := FALSE;
    END IF;
    RETURN(l_read_access);
  WHEN Exception_No_Access THEN
    IF g_reset_access_flag THEN
      g_reset_access_flag := FALSE;
    END IF;
    RETURN(l_no_access);
END get_k_access_level;


PROCEDURE note_context_info (
	p_sql_statement IN VARCHAR2,
-- SPILLAIP - 2689257 - Start
	p_object_info IN OUT NOCOPY VARCHAR2,
	p_object_id IN NUMBER) IS
BEGIN
	EXECUTE IMMEDIATE p_sql_statement INTO p_object_info USING p_object_id;
END note_context_info;

FUNCTION read_clob (
	p_clob CLOB)
RETURN VARCHAR2 IS
  amount BINARY_INTEGER := 32000;
  clob_size INTEGER;
  buffer VARCHAR2(32000);
BEGIN
  IF p_clob IS NULL THEN
	RETURN NULL;
  ELSE
	clob_size := dbms_lob.getlength(p_clob);
	IF clob_size < amount THEN
		amount := clob_size;
	END IF;
	IF clob_size = 0 THEN
		RETURN NULL;
	END IF;
	dbms_lob.READ(p_clob, amount, 1, buffer);
	IF amount > 0 THEN
		RETURN buffer;
	ELSE
		RETURN NULL;
	END IF;
  END IF;
END read_clob;

FUNCTION read_clob (
	p_note_id NUMBER)
RETURN VARCHAR2 IS
  amount BINARY_INTEGER := 32000;
  clob_size INTEGER;
  buffer VARCHAR2(32000);

  p_clob CLOB;
  CURSOR c_clob (p_note_id NUMBER) IS
	SELECT notes_detail
     FROM jtf_notes_tl
     WHERE jtf_note_id = p_note_id
     AND LANGUAGE = USERENV('LANG');

BEGIN
  OPEN c_clob(p_note_id);
  FETCH c_clob INTO p_clob;
  CLOSE c_clob;

  IF p_clob IS NULL THEN
	RETURN NULL;
  ELSE
	clob_size := dbms_lob.getlength(p_clob);
	IF clob_size < amount THEN
		amount := clob_size;
	END IF;
	IF clob_size = 0 THEN
		RETURN NULL;
	END IF;
	dbms_lob.READ(p_clob, amount, 1, buffer);
	IF amount > 0 THEN
		RETURN buffer;
	ELSE
		RETURN NULL;
	END IF;
  END IF;
END read_clob;

FUNCTION party_type_info (
	p_object_id NUMBER)
RETURN VARCHAR2 IS
  l_party_type_name VARCHAR2(2000);
  CURSOR C_party_type_name (p_object_id NUMBER) IS
  SELECT A.meaning
  FROM ar_lookups A, hz_parties p
  WHERE p.party_id = p_object_id
  AND A.lookup_code = p.party_type
  AND A.lookup_type = 'PARTY_TYPE';

BEGIN
  l_party_type_name := 'Party';

  IF p_object_id IS NOT NULL THEN
	OPEN C_party_type_name (p_object_id);
	FETCH C_party_type_name INTO l_party_type_name;
	CLOSE C_party_type_name;
  END IF;

  RETURN l_party_type_name;

END party_type_info;

FUNCTION note_context_info (
	p_select_id VARCHAR2,
	p_select_name VARCHAR2,
	p_select_details VARCHAR2,
	p_from_table VARCHAR2,
	p_where_clause VARCHAR2,
	p_object_id NUMBER)
RETURN VARCHAR2 IS
  l_sql_statement VARCHAR2(2000);
  l_object_info VARCHAR2(2000);
BEGIN
  l_sql_statement := NULL;
  l_object_info := NULL;

  IF p_from_table IS NOT NULL AND p_select_id IS NOT NULL AND p_object_id IS NOT NULL THEN
     IF p_select_name IS NOT NULL THEN
          l_sql_statement := 'SELECT ' || p_select_name || ' ';
     END IF;
     IF p_select_details IS NOT NULL THEN
          IF l_sql_statement IS NOT NULL THEN
               l_sql_statement := l_sql_statement || ' || '' - '' || ';
          ELSE
               l_sql_statement := 'SELECT ';
          END IF;
          l_sql_statement := l_sql_statement || p_select_details || ' ';
     END IF;
     IF l_sql_statement IS NOT NULL THEN
          l_sql_statement := l_sql_statement || 'FROM ' || p_from_table || ' ';
          l_sql_statement := l_sql_statement || 'WHERE ' || p_select_id || ' = :p_object_id ';
	          IF p_where_clause IS NOT NULL THEN
               l_sql_statement := l_sql_statement || 'AND ' || p_where_clause;
          END IF;
     END IF;
  END IF;

  IF l_sql_statement IS NOT NULL THEN
	EXECUTE IMMEDIATE l_sql_statement INTO l_object_info USING p_object_id;
  END IF;

  RETURN l_object_info;

END note_context_info;


  FUNCTION get_contract_status(
     p_contract_id			IN NUMBER,
	 p_working_mode         IN VARCHAR2 DEFAULT 'QUERY',
	 p_contract_status      OUT NOCOPY VARCHAR2,
     x_allowed		     	OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2
  IS
    CURSOR okl_status_cur(p_contract_id NUMBER) IS
      SELECT sts_code FROM okc_k_headers_b
      WHERE  ID = p_contract_id;

    CURSOR okc_status_cur(p_okl_status VARCHAR2) IS
      SELECT ste_code FROM okc_statuses_b
      WHERE  code=p_okl_Status;


    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
	l_user_status           VARCHAR2(100);
   	l_okc_status            VARCHAR2(100);
	l_allowed               VARCHAR2(10) := 'FALSE';
  BEGIN
    OPEN  okl_status_cur(p_contract_id);
    FETCH okl_status_cur INTO l_user_status;
    CLOSE okl_status_cur;

    OPEN  okc_status_cur(l_user_status);
    FETCH okc_status_cur INTO l_okc_status;
    CLOSE okc_status_cur;

	IF p_working_mode = 'QUERY' AND l_user_status IN (--User Status
	            'BOOKED','EVERGREEN','UNDER REVISION','ABANDONED','COMPLETE','INCOMPLETE',
		 'NEW','PASSED','BANKRUPTCY_HOLD','LITIGATION_HOLD','TERMINATION_HOLD','APPROVED',
					'PENDING_APPROVAL','AMENDED','REVERSED','TERMINATED',
-----OKC Status
	                'ACTIVE','CANCELLED','HOLD','SIGNED','TERMINATED','EXPIRED') THEN
		l_allowed := 'TRUE' ;
/**start 11i9 code  */
	ELSIF p_working_mode = 'MODIFY_PARTY' AND  l_okc_status IN ('ACTIVE','HOLD')
	        AND l_user_status IN (--User Status
		                'BOOKED','EVERGREEN','BANKRUPTCY_HOLD','LITIGATION_HOLD',
				'TERMINATION_HOLD')
	               THEN
		l_allowed := 'TRUE' ;
	ELSIF p_working_mode = 'NON_BILLING' AND l_okc_status IN ('ACTIVE','HOLD')
	      AND l_user_status IN (--User Status
	            'BOOKED','EVERGREEN','BANKRUPTCY_HOLD','LITIGATION_HOLD'
			,'TERMINATION_HOLD') THEN
		l_allowed := 'TRUE' ;
	ELSIF p_working_mode = 'RENEW_MIDTERM' AND	l_okc_status IN ('ACTIVE','HOLD')
	      AND l_user_status IN (--User Status
	            'BOOKED','BANKRUPTCY_HOLD','LITIGATION_HOLD','TERMINATION_HOLD') THEN
		l_allowed := 'TRUE' ;
/**end 11i9 code  */
	ELSIF p_working_mode IN ( 'EXCHANGE','RENEWAL','TRANSFER','MODIFY UBB','TAX SCHEDULES') --User Status
          AND l_okc_status IN ('ACTIVE','HOLD')
     	  AND l_user_status IN ('BOOKED','EVERGREEN','BANKRUPTCY_HOLD'
				,'TERMINATION_HOLD','LITIGATION_HOLD','UNDER REVISION') THEN
               l_allowed := 'TRUE' ;
         ELSIF p_working_mode = 'CREDIT MEMO' 	--User Status
          AND l_okc_status IN ('ACTIVE','HOLD','ENTERED','SIGNED','TERMINATED','EXPIRED')
     	  AND l_user_status IN ('BOOKED','EVERGREEN','UNDER REVISION','COMPLETE'
				,'INCOMPLETE','NEW','PASSED', 'BANKRUPTCY_HOLD'
				,'TERMINATION_HOLD','LITIGATION_HOLD','APPROVED'
				,'PENDING_PPROVAL','REVERSED','TERMINATED','EXPIRED') THEN
		l_allowed := 'TRUE' ;

    ELSIF p_working_mode IN ('PAYDOWN','CONVERT INTEREST','MODIFY TC','TERMINATION QUOTE')
     	  AND l_okc_status IN ('ACTIVE','HOLD')
          AND l_user_status IN ('BOOKED','EVERGREEN','BANKRUPTCY_HOLD',
		                   'LITIGATION_HOLD','TERMINATION_HOLD') THEN
		l_allowed := 'TRUE' ;
    ELSIF p_working_mode IN ('ASSET') 	--User Status
     	  AND l_okc_status IN ('ACTIVE','HOLD')
          AND l_user_status IN ('BOOKED','EVERGREEN','BANKRUPTCY_HOLD','APPROVED'
		                   ,'LITIGATION_HOLD','TERMINATION_HOLD') THEN
		l_allowed := 'TRUE' ;

        --Added Code for Payment Schedule for 11i10 ER
        -- Added by rvaduri
	ELSIF p_working_mode IN ( 'REQUEST TERMINATION','PAYMENT_SCHEDULE') 	--User Status
          AND l_okc_status IN ('ACTIVE','HOLD')
     	  AND l_user_status IN ('BOOKED','EVERGREEN','ACTIVE') THEN
		l_allowed := 'TRUE' ;
	ELSIF p_working_mode = 'RESTRUCTURE' 	--User Status
     	  AND l_okc_status IN ('ACTIVE','HOLD')
          AND l_user_status IN ('BOOKED','ACTIVE','BANKRUPTCY_HOLD','HOLD','LITIGATION_HOLD') THEN
		l_allowed := 'TRUE' ;
	ELSIF p_working_mode = 'EXPIRATION' 	--User Status
     	  AND l_okc_status IN ('ACTIVE','HOLD')
          AND l_user_status IN ('BOOKED','ACTIVE') THEN
		l_allowed := 'TRUE' ;
        ELSIF p_working_mode = 'TAX OVERRIDE'
          AND l_user_status NOT IN ('ABANDONED','APPROVED','COMPLETE','INCOMPLETE','NEW','PASSED','PENDING_APPROVAL') THEN
         l_allowed := 'TRUE' ;
    ELSE
		l_allowed := 'FALSE' ;
    END IF;
	p_contract_status := l_user_status;
    x_allowed := l_allowed;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END get_contract_status;


  FUNCTION contract_cust_accounts(	p_cust_acct_id	IN NUMBER,
    				                x_no_contracts	OUT NOCOPY NUMBER
			                      )
  RETURN VARCHAR2 AS
  -- get org_id for contract
    CURSOR get_contract_no (p_cust_acct_id IN VARCHAR2) IS
      SELECT COUNT(*)
      FROM  HZ_CUST_ACCOUNTS CA,
            HZ_PARTIES P,OKC_K_HEADERS_V CHR,OKC_STATUSES_V STAT
      WHERE CHR.scs_code = 'LEASE' AND
            CHR.authoring_org_id = mo_global.get_current_org_id() AND
            ca.cust_account_id =chr.cust_acct_id AND
            ca.party_id = p.party_id AND
            CHR.sts_code = stat.code AND
            stat.code = 'BOOKED' AND
            ca.cust_account_id =  p_cust_acct_id;

    l_api_version           NUMBER;
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
  BEGIN
    OPEN get_contract_no(p_cust_acct_id);
    FETCH get_contract_no INTO x_no_contracts;
    CLOSE get_contract_no;
    RETURN l_return_status;
    EXCEPTION
    WHEN OTHERS THEN
    CLOSE get_contract_no;
      Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END contract_cust_accounts;
  PROCEDURE update_deal(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_durv_tbl                     IN  deal_tbl_type,
      x_durv_tbl                     OUT NOCOPY deal_tbl_type
      ) AS
    i                        number;
    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_overall_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    OKC_API.init_msg_list(p_init_msg_list);
    IF (p_durv_tbl.COUNT > 0) THEN
      i := p_durv_tbl.FIRST;
     LOOP

      okl_deal_create_pub.update_deal(
	    p_api_version                 => p_api_version,
	    p_init_msg_list               => FND_API.G_FALSE,
	    x_return_status               => x_return_status,
	    x_msg_count                   => x_msg_count,
	    x_msg_data                    => x_msg_data,
	    p_durv_rec       			  => p_durv_tbl(i),
	    x_durv_rec			          => x_durv_tbl(i));

        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        EXIT WHEN (i = p_durv_tbl.LAST);
        i := p_durv_tbl.NEXT(i);
      END LOOP;
      x_return_status := l_overall_status;
    END IF;

  END update_deal;

  PROCEDURE commit_update AS
  BEGIN
    commit;
  END;
  PROCEDURE contract_securitized(
                   p_contract_id           IN  NUMBER
                   ,x_value                 OUT NOCOPY VARCHAR2
                   ) IS
   cursor investor_assigned IS
   select SECURITIZED_CODE
   from OKL_K_HEADERS
   where id = p_contract_id;
   l_securitized   VARCHAR2(1);
   BEGIN
     open investor_assigned;
     fetch investor_assigned into l_securitized;
     close investor_assigned;
     x_value := l_securitized;
   EXCEPTION
     WHEN OTHERS THEN
        Okl_Api.SET_MESSAGE( p_app_name     => G_APP_NAME
                           ,p_msg_name     => G_UNEXPECTED_ERROR
                           ,p_token1       => G_SQLCODE_TOKEN
                           ,p_token1_value => SQLCODE
                           ,p_token2       => G_SQLERRM_TOKEN
                           ,p_token2_value => SQLERRM);
  END;

 ---------------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : get_total_tax_amount
  --Purpose               : Returns the total tax amount for the asset tax lines created due to asset location change
  --Modification History  :
  --19-May-2005    Rkuttiya  Created
  --Notes :
  --End of Comments
-------------------------------------------------------------------------------------------
FUNCTION Get_Total_Tax_Amount(p_trx_id IN NUMBER)
RETURN NUMBER
IS
  CURSOR c_tax_amount(p_trx_id IN NUMBER) IS
  SELECT SUM(tax_amt)
  FROM OKL_TAX_TRX_DETAILS
  WHERE txs_id = p_trx_id;
  l_tax_amount      NUMBER;
BEGIN
  OPEN c_tax_amount(p_trx_id);
  FETCH c_tax_amount INTO l_tax_amount;
  CLOSE c_tax_amount;

  RETURN l_tax_amount;
 EXCEPTION

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);

END;

---------------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : get_total_stream_amount
  --Purpose               : Returns the total strm amount at contract or line level
  --Modification History  :
  --15-SEP-2005    Rkuttiya  Created
  --Notes :
  --End of Comments
-------------------------------------------------------------------------------------------
FUNCTION Get_Total_Stream_Amount(p_khr_id  IN NUMBER,
                                  p_kle_id  IN NUMBER,
                                  p_sty_id  IN NUMBER)
RETURN NUMBER
IS
  CURSOR c_strm_amount(p_khr_id IN NUMBER,
                       p_kle_id IN NUMBER,
                       p_sty_id IN NUMBER) IS
  SELECT sum(amount) from okl_cs_payment_detail_uv
  WHERE khr_id = p_khr_id
  AND   sty_id = p_sty_id
  AND   nvl(kle_id,-1) = nvl(p_kle_id,-1) ;
  l_strm_amount      NUMBER;
BEGIN
  OPEN c_strm_amount(p_khr_id,p_kle_id,p_sty_id);
  FETCH c_strm_amount INTO l_strm_amount;
  CLOSE c_strm_amount;

  RETURN l_strm_amount;
 EXCEPTION

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);

END;

--dkagrawa added the function for bug # 4723838
FUNCTION get_asset_number(p_kle_id IN NUMBER)
RETURN VARCHAR2 IS
  CURSOR l_asset_number_csr(cp_kle_id IN NUMBER) IS
  SELECT fat.name
  FROM okc_k_lines_b fa,
       okc_k_lines_tl fat,
       okc_line_styles_b stl,
       okc_k_lines_b top_cle,
       okc_line_styles_b top_stl,
       okc_k_lines_b sub_cle,
       okc_line_styles_b sub_stl,
       okc_k_items   cim
  WHERE top_cle.lse_id = top_stl.id
  AND top_stl.lty_code in ('SOLD_SERVICE','FEE')
  AND top_cle.id = sub_cle.cle_id
  AND sub_cle.lse_id = sub_stl.id
  AND sub_stl.lty_code in ('LINK_SERV_ASSET','LINK FEE ASSET')
  AND cim.cle_id = sub_cle.id
  AND CIM.JTOT_OBJECT1_CODE = 'OKX_COVASST'
  AND CIM.OBJECT1_ID1  = FA.ID
  AND FA.LSE_ID = STL.ID
  AND fa.id = fat.id
  AND fat.language = USERENV('LANG')
  AND STL.LTY_CODE = 'FREE_FORM1'
  AND sub_cle.id = cp_kle_id;
 l_asset_number  okc_k_lines_tl.name%TYPE;
BEGIN
  OPEN l_asset_number_csr(p_kle_id);
  FETCH l_asset_number_csr INTO l_asset_number;
  CLOSE l_asset_number_csr;
  RETURN l_asset_number;
END get_asset_number;
--Bug 4723838 ends

---------------------------------------------------------------------------------------
  --Start of comments
  --
  --function Name         : get_ap_line_tax
  --Purpose               : Returns the total tax amount for an ap invoice at line level
  --Modification History  :
  --12-FEB--2007    dkagrawa  Created
  --Notes :
  --End of Comments
-------------------------------------------------------------------------------------------
FUNCTION get_ap_line_tax(p_invoice_id IN NUMBER, p_line_number IN NUMBER)
RETURN NUMBER IS
  CURSOR c_tax_amount IS
  SELECT SUM(tax_line.tax_amt) TAX_AMOUNT
  FROM ap_invoice_lines_all inv_ln
     , zx_lines tax_line
     , fnd_application app_ap
  WHERE tax_line.application_id = app_ap.application_id
  AND app_ap.application_short_name = 'SQLAP'
  AND tax_line.entity_code = 'AP_INVOICES'
  AND tax_line.event_class_code = 'STANDARD INVOICES'
  AND tax_line.trx_id = inv_ln.invoice_id
  AND tax_line.trx_level_type = 'LINE'
  AND tax_line.trx_line_number = inv_ln.line_number
  AND inv_ln.invoice_id = p_invoice_id
  AND inv_ln.line_number = p_line_number;
  l_tax_amount  NUMBER;
BEGIN
  OPEN c_tax_amount;
  FETCH c_tax_amount INTO l_tax_amount;
  CLOSE c_tax_amount;
  RETURN l_tax_amount;
END get_ap_line_tax;

--asawanka added for ebtax project
  ---------------------------------------------------------------------------
  -- FUNCTION get_private_label
  ---------------------------------------------------------------------------
  FUNCTION get_tax_sch_Req_flag(
     p_contract_id			IN NUMBER)
  RETURN VARCHAR2
  IS
    l_tax_Sch_req           VARCHAR2(30) := 'N';
    CURSOR get_taxsch_rule_csr IS
    select rule_information5
    from okc_rules_b
    where dnz_chr_id = p_contract_id
    and rule_information_category = 'LASTPR';
  BEGIN
    OPEN get_taxsch_rule_csr;
    FETCH get_taxsch_rule_csr INTO l_tax_Sch_req;
    CLOSE get_taxsch_rule_csr;
     RETURN l_tax_Sch_req;

  END get_tax_sch_Req_flag;


---------------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : get_cov_asset_id
  --Purpose               : Returns the asset_id of the asset associated to a service line,
  --                        created to fix bug#5759229
  --Modification History  :
  --27-AUG-2007    Zrehman  Created
  --Notes :
  --End of Comments
-------------------------------------------------------------------------------------------

FUNCTION get_cov_asset_id(p_kle_id IN NUMBER)
   RETURN NUMBER IS
   CURSOR l_asset_id_csr(cp_kle_id IN NUMBER) IS
   SELECT  cim1.object1_id1
   FROM okc_k_lines_b cle,
        okc_k_lines_b cle1,  /* to get all line types associated with free form 1 in that FIXED_ASSET */
        okc_k_items cim,   /* to get the one having covered asset */
        okc_k_lines_b cle2, /* After getting the one having the covered asset take the id of the service line */
        okc_line_styles_b lse, /* to get free_form 1 */
        okc_line_styles_b lse1, /* to get FIXED_ASSET lty_code */
        okc_line_styles_b lse2, /* to get LINK_SERV_ASSET lty_code */
        okc_k_items cim1 /* to take the actual asset id */
   WHERE  lse.id = cle.lse_id
   AND lse1.id = cle1.lse_id
   AND lse1.lty_code = 'FIXED_ASSET'
   AND cle.id = cle1.cle_id
   AND lse.lty_code = 'FREE_FORM1'
   AND cle1.cle_id = cim.object1_id1
   AND cim.jtot_object1_code = 'OKX_COVASST'
   AND cim.cle_id = cle2.id
   AND lse2.id = cle2.lse_id
   AND cle1.id = cim1.cle_id
   AND cim1.jtot_object1_code = 'OKX_ASSET'
   AND cle2.id = cp_kle_id;
   /*
     For clarity in the query result, select the following in the above SELECT statement to see
     the asset_id of the asset associated to a service line, the line id of the associated asset line and
     the service id to which the asset is associated.
     Also the corresponding lty_code is selected to verify the result set of the query.

      SELECT  cim1.object1_id1 "Asset ID",
           cle1.id "FIXED ASSET LINE ID", lse1.lty_code "lty code of fixed asset line",
           cle2.id "SERVICE LINE ID", lse2.lty_code "lty code of service line"

     Note: The input for the above query would be the id of the service line.
   */

   l_asset_id  okc_k_items.object1_id1%TYPE;

   BEGIN

      OPEN l_asset_id_csr(p_kle_id);
      FETCH l_asset_id_csr INTO l_asset_id;
      CLOSE l_asset_id_csr;

      RETURN l_asset_id;

   END get_cov_asset_id;

  ---------------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : get_payment_remaining
  --Purpose               : Returns the No of payment remaining for given contract
  --                        created to enhance usability in sprint 7
  --Modification History  :
  --28-JAN-2008    dkagrawa  Created
  --Notes :
  --End of Comments
  -------------------------------------------------------------------------------------------
  FUNCTION get_payment_remaining(p_khr_id  IN NUMBER) RETURN VARCHAR2
  IS
    CURSOR c_get_unbilled_payment(p_contract_id IN NUMBER,p_cle_id IN NUMBER)
    IS
    SELECT COUNT(1) payment_remaining
    FROM   OKL_STRM_TYPE_v STYT,
           okl_strm_elements sele,
           okl_streams str
    WHERE  sele.stm_id = str.id
    AND str.sty_id = styt.id
    AND str.say_code = 'CURR'
    AND STR.ACTIVE_YN = 'Y'
    AND STR.PURPOSE_CODE IS NULL
    AND SELE.DATE_BILLED IS NULL
    AND styt.billable_yn     = 'Y'
    AND styt.stream_type_purpose IN ('RENT','PRINCIPAL_PAYMENT','LOAN_PAYMENT')
    AND str.khr_id =  p_contract_id
    AND str.kle_id = p_cle_id;

    CURSOR c_get_payment_details(p_contract_id IN NUMBER) IS
    SELECT rgp_lalevl.cle_id,
       RUL_LASLL.RULE_INFORMATION5 STRUCTURE_CODE,
       RUL_LASLL.OBJECT1_ID1 FREQUENCY_CODE,
       NVL(RUL_LASLL.RULE_INFORMATION10,'N') ARREARS_YN,
       FND_DATE.canonical_to_date(rul_lasll.rule_information2) start_date,
       rul_lasll.rule_information7 stub_days,
       rul_lasll.rule_information3 periods
FROM   OKC_RULE_GROUPS_B RGP_LALEVL,
       OKC_RULES_B RUL_LASLH,
       OKC_RULES_B RUL_LASLL,
       OKL_STRM_TYPE_v STYT
WHERE  RGP_LALEVL.RGD_CODE = 'LALEVL'
       AND RUL_LASLH.RGP_ID = RGP_LALEVL.ID
       AND RUL_LASLH.RULE_INFORMATION_CATEGORY = 'LASLH'
       AND RUL_LASLH.DNZ_CHR_ID = RGP_LALEVL.DNZ_CHR_ID
       AND STYT.ID = RUL_LASLH.OBJECT1_ID1
       AND RUL_LASLL.RULE_INFORMATION_CATEGORY = 'LASLL'
       AND RUL_LASLL.RGP_ID = RUL_LASLH.RGP_ID
       AND RUL_LASLL.DNZ_CHR_ID = RUL_LASLH.DNZ_CHR_ID
       AND RUL_LASLL.OBJECT2_ID1 = RUL_LASLH.ID
       AND NVL(RUL_LASLL.OBJECT2_ID2,'#') = '#'
       AND RUL_LASLL.JTOT_OBJECT2_CODE = 'OKL_STRMHDR'
       AND styt.stream_type_purpose IN ('RENT','PRINCIPAL_PAYMENT','LOAN_PAYMENT')
       AND RGP_LALEVL.DNZ_CHR_ID  = p_contract_id;

    l_diff BOOLEAN := FALSE;
    l_in NUMBER :=1;
    l_unbillled_remaining  NUMBER;
    l_structure_code VARCHAR2(30);
    l_frequency_code VARCHAR2(30);
    l_arrears VARCHAR2(30);
    l_start_date DATE;
    l_stub_days  NUMBER;
    l_periods NUMBER;
    l_cle_id NUMBER;
  BEGIN

    FOR rec IN c_get_payment_details(p_khr_id) LOOP
      l_cle_id := rec.cle_id;
      IF l_in = 1 THEN
        l_structure_code := rec.STRUCTURE_CODE;
        l_frequency_code := rec.frequency_code;
        l_arrears := rec.arrears_yn;
        l_start_date := rec.START_DATE;
        l_stub_days := rec.stub_days;
        l_periods := rec.periods;
       ELSE
        IF   l_structure_code <> rec.STRUCTURE_CODE OR
        l_frequency_code <> rec.frequency_code OR
        l_arrears <> rec.arrears_yn OR
        l_start_date <> rec.START_DATE OR
        l_stub_days <> rec.stub_days OR
        l_periods <> rec.periods THEN
          l_diff := TRUE;
          EXIT;
        END IF;
       END IF;
    END LOOP;
    IF l_diff THEN
      RETURN 'Multiple';
    ELSE
      OPEN c_get_unbilled_payment(p_khr_id,l_cle_id);
      FETCH c_get_unbilled_payment INTO l_unbillled_remaining;
      CLOSE c_get_unbilled_payment;

      RETURN to_char(l_unbillled_remaining);
    END IF;
  END;

   ---------------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : get_term_remaining
  --Purpose               : Returns the No terms remaining for given contract
  --                        created to enhance usability in sprint 7
  --Modification History  :
  --28-JAN-2008    dkagrawa  Created
  --Notes :
  --End of Comments
  -------------------------------------------------------------------------------------------

  FUNCTION get_term_remaining(p_khr_id  IN NUMBER) RETURN NUMBER
  IS
    CURSOR c_get_terms_rem (p_contract_id IN NUMBER)
    IS
    SELECT okhr.term_duration-DECODE(sign(sysdate-khr.start_date),-1,0,DECODE(sign(sysdate-khr.end_date),1,okhr.term_duration,TRUNC(MONTHS_BETWEEN(sysdate,khr.start_date))))
           payment_remaining
    FROM okl_k_headers okhr ,
         okc_k_headers_v khr
    WHERE okhr.id = khr.id
    AND khr.id = p_contract_id;

    l_terms_remaining NUMBER;
   BEGIN
     OPEN c_get_terms_rem(p_khr_id);
     FETCH c_get_terms_rem INTO l_terms_remaining;
     CLOSE c_get_terms_rem;
     RETURN l_terms_remaining;
   END;

  FUNCTION get_total_billed(p_khr_id  IN NUMBER) RETURN NUMBER IS
    CURSOR c_get_billed(cp_khr_id IN NUMBER) IS
    SELECT SUM(amount_original+amount_adjusted)
    FROM okl_cs_bpd_inv_dtl_v
    WHERE amount_remaining > 0
    AND chr_id = cp_khr_id;

/*    CURSOR c_get_total_adjusted(cp_khr_id IN NUMBER) IS
    SELECT SUM(NVL(APS.AMOUNT_ADJUSTED,0)) AMOUNT_ADJUSTED
    FROM   AR_PAYMENT_SCHEDULES_ALL APS,
           RA_CUSTOMER_TRX_ALL RACTRX,
           RA_CUSTOMER_TRX_LINES_ALL RACTRX_LINE,
           OKC_K_HEADERS_B OKC
    WHERE  RACTRX.CUSTOMER_TRX_ID = APS.CUSTOMER_TRX_ID
    AND    RACTRX.CUSTOMER_TRX_ID = RACTRX_LINE.CUSTOMER_TRX_ID
    AND    OKC.CONTRACT_NUMBER = RACTRX_LINE.INTERFACE_LINE_ATTRIBUTE6
    AND    OKC.ID = cp_khr_id;
*/
 -- l_total_adjusted    NUMBER;
    l_billed            NUMBER;
  BEGIN

   OPEN c_get_billed(p_khr_id);
   FETCH c_get_billed INTO l_billed;
   CLOSE c_get_billed;

/* OPEN c_get_total_adjusted(p_khr_id);
   FETCH c_get_total_adjusted INTO l_total_adjusted;
   CLOSE c_get_total_adjusted;
*/
-- RETURN NVL(l_billed,0) + NVL(l_total_adjusted,0);
   RETURN NVL(l_billed,0);
  END get_total_billed;

  FUNCTION get_total_paid_credited(p_khr_id  IN NUMBER) RETURN NUMBER IS
    CURSOR c_get_paid_credited(cp_khr_id IN NUMBER) IS
    SELECT SUM(amount_applied) + SUM(amount_credited)
    FROM okl_cs_bpd_inv_dtl_v
    WHERE amount_remaining > 0
    AND chr_id = cp_khr_id;
    l_paid_credited NUMBER;
  BEGIN

   OPEN c_get_paid_credited(p_khr_id);
   FETCH c_get_paid_credited INTO l_paid_credited;
   CLOSE c_get_paid_credited;

   RETURN NVL(l_paid_credited,0);
  END get_total_paid_credited;

  FUNCTION get_total_remaining(p_khr_id  IN NUMBER) RETURN NUMBER IS
    CURSOR c_get_remaining(cp_khr_id IN NUMBER) IS
    SELECT SUM(amount_remaining)
    FROM okl_cs_bpd_inv_dtl_v
    WHERE amount_remaining > 0
    AND chr_id = cp_khr_id;
    l_remaining NUMBER;
  BEGIN

   OPEN c_get_remaining(p_khr_id);
   FETCH c_get_remaining INTO l_remaining;
   CLOSE c_get_remaining;

   RETURN NVL(l_remaining,0);
  END get_total_remaining;
END Okl_Cs_Lc_Contract_Pvt;

/
