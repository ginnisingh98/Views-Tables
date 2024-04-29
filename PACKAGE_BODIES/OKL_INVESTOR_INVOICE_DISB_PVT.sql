--------------------------------------------------------
--  DDL for Package Body OKL_INVESTOR_INVOICE_DISB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INVESTOR_INVOICE_DISB_PVT" AS
/* $Header: OKLRIDBB.pls 120.36.12010000.5 2010/04/15 11:08:15 sosharma ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

-- gboomina Bug 6788005 - Start
-- Moving cursors globaly so that this can be used in different API's

-----------------------------------------------------------------
-- Cursor to fetch Payout Attributes
-----------------------------------------------------------------
CURSOR payout_attrs_csr ( p_khr_id NUMBER ) IS
SELECT RULE_INFORMATION1,
       RULE_INFORMATION2
FROM  OKC_RULES_B       rul,
      Okc_rule_groups_B rgp
WHERE   rul.rgp_id     = rgp.id                  AND
	rgp.rgd_code   = 'LASEIR'                AND
	rul.rule_information_category = 'LASEIR' AND
	rgp.dnz_chr_id = p_khr_id;

-----------------------------------------------------------------
-- Cursor to fetch Vendor Or Investor Name
-----------------------------------------------------------------
CURSOR vendor_name_csr ( p_vendor_id NUMBER ) IS
SELECT VENDOR_NAME
FROM po_vendors
WHERE VENDOR_ID = p_vendor_id;

-----------------------------------------------------------------
-- Cursor to fetch Vendor Site
-----------------------------------------------------------------
CURSOR vendor_site_csr ( p_vendor_site_id NUMBER ) IS
SELECT VENDOR_SITE_CODE
FROM po_vendor_sites
WHERE VENDOR_SITE_ID = p_vendor_site_id;

-----------------------------------------------------------------
-- Cursor to fetch Org Id
-----------------------------------------------------------------
CURSOR org_id_csr ( p_chr_id NUMBER ) IS
   SELECT chr.authoring_org_id
   FROM okc_k_headers_b chr
   WHERE id =  p_chr_id;

-----------------------------------------------------------------
-- Cursor to fetch Set Of Books
-----------------------------------------------------------------
CURSOR sob_csr ( p_org_id  NUMBER ) IS
   SELECT hru.set_of_books_id
   FROM HR_OPERATING_UNITS HRU
   WHERE ORGANIZATION_ID = p_org_id;

-----------------------------------------------------------------
-- Cursor to fetch Try Id
-----------------------------------------------------------------
CURSOR try_id_csr IS
   SELECT id
   FROM okl_trx_types_tl
   WHERE name = 'Disbursement'
   AND language= 'US';


-----------------------------------------------------------------
-- Cursor to fetch Investor Attributes
-----------------------------------------------------------------
CURSOR vendor_attrs_csr ( p_khr_id NUMBER, p_kle_id NUMBER  ) IS
SELECT rul.object1_id1, -- Pay To Vendor Name
       rul.object2_id1, -- Pay Site
       rul.OBJECT3_ID1, -- Payment Term
       RULE_INFORMATION1, -- Payment Method
       RULE_INFORMATION2 -- Pay Group
FROM  OKC_RULES_B       rul,
      Okc_rule_groups_B rgp
WHERE   rul.rgp_id     = rgp.id                  AND
	rgp.rgd_code   = 'LASEDB'                AND
	rul.rule_information_category = 'LASEDB' AND
	rgp.dnz_chr_id = p_khr_id                AND
	rgp.cle_id = p_kle_id;


-----------------------------------------------------------------
-- Cursor to fetch Ap Interface Sequence Number
-----------------------------------------------------------------
CURSOR seq_csr IS
SELECT ap_invoices_interface_s.nextval
FROM dual;

-----------------------------------------------------------------
-- Cursor to fetch Stream Name
-----------------------------------------------------------------
CURSOR disb_strm_csr( p_sty_id NUMBER ) IS
SELECT name
FROM OKL_STRM_TYPE_V
WHERE id = p_sty_id;

-- gboomina Bug 6788005 - End

FUNCTION get_disb_amt(p_ia_id    NUMBER
                     ,p_rbk_khr_id NUMBER
                     ,p_rbk_kle_id NUMBER)
         RETURN NUMBER
AS

CURSOR disb_sel_amt_csr ( p_ia_id      NUMBER,
                          p_rbk_khr_id NUMBER,
                          p_rbk_kle_id NUMBER ) IS
    SELECT NVL(SUM(SEL.AMOUNT),0)
    FROM OKL_STREAMS STM,
         OKL_STRM_ELEMENTS SEL,
         OKL_STRM_TYPE_V STY
    WHERE STM.KHR_ID =  p_rbk_khr_id
    AND   NVL(STM.KLE_ID,-99) = NVL ( p_rbk_kle_id,-99 )
    AND  STM.STY_ID = STY.ID
    AND   stm.source_table = 'OKL_K_HEADERS'
    AND   stm.source_id    = p_ia_id
    AND  STM.SAY_CODE = 'CURR'
    AND (STY.STREAM_TYPE_SUBCLASS = 'INVESTOR_DISBURSEMENT'
      OR STY.stream_type_purpose in ( 'INVESTOR_RENT_DISB_BASIS','INVESTOR_PRINCIPAL_DISB_BASIS','INVESTOR_INTEREST_DISB_BASIS','INVESTOR_PPD_DISB_BASIS'))
    AND SEL.STM_ID = STM.ID
    AND SEL.DATE_BILLED IS NOT NULL;

    l_rbk_adjst_amt NUMBER;
BEGIN

  l_rbk_adjst_amt := 0;

  OPEN  disb_sel_amt_csr ( p_ia_id, p_rbk_khr_id, p_rbk_kle_id  );
  FETCH disb_sel_amt_csr INTO l_rbk_adjst_amt;
  CLOSE disb_sel_amt_csr;

  return NVL(l_rbk_adjst_amt,0);

EXCEPTION
  WHEN others THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '** EXCEPTION IN get_disb_amt: '||SQLERRM);
       /*   dbms_output.put_line('** EXCEPTION IN get_disb_amt: '||SQLERRM);  */
    return 0;
END get_disb_amt;

---------------------------------------------------------------------------
-- FUNCTION get_seq_id
---------------------------------------------------------------------------
FUNCTION get_seq_id RETURN NUMBER IS
 BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
END get_seq_id;

FUNCTION get_next_pymt_date(p_start_date IN Date
                           ,p_frequency IN VARCHAR2
                  	   ,p_offset_date IN DATE DEFAULT SYSDATE) RETURN DATE
AS
  -- sechawla 26-Jun-09 8459929 - Modified logic to calculate next payout date
 -- l_next_date DATE := to_date(to_char(p_start_date, 'MM/DD') || to_char(p_offset_date, 'RRRR'), 'MM/DD/RRRR');

  l_next_date DATE := p_start_date;
  l_months_between NUMBER := 0;
  l_next_payout_factor NUMBER;

  l_mnth_adder NUMBER := 0;
BEGIN
  if(UPPER(p_frequency) = 'A') then
    l_mnth_adder := 12;
  elsif(UPPER(p_frequency) = 'Q') then
    l_mnth_adder := 3;
  elsif(UPPER(p_frequency) = 'M') then
    l_mnth_adder := 1;
  else
    return null;
  end if;
  /*  -- sechawla 26-Jun-09 8459929 : begin
  loop
    select add_months(l_next_date, l_mnth_adder) INTO l_next_date from dual;
    exit when l_next_date >= p_offset_date;
  end loop;
  */
  l_months_between := months_between(p_offset_date,p_start_date);
  IF (l_months_between <= 0) THEN
   l_next_payout_factor := 0;
  ELSE
   l_next_payout_factor := CEIL(l_months_between/l_mnth_adder);
  END IF;
  l_next_date := add_months(p_start_date, (l_next_payout_factor*l_mnth_adder));
  -- sechawla 26-Jun-09 8459929 : end
return l_next_date;
EXCEPTION
  WHEN others THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '** EXCEPTION IN get_next_pymt_date: '||SQLERRM);
    return null;
END get_next_pymt_date;

FUNCTION check_sel_billed( p_ref_sel_id NUMBER ) RETURN VARCHAR2

AS

 /*
 CURSOR lsm_csr ( p_ref_sel_id NUMBER ) IS
    SELECT receivables_invoice_id
    FROM okl_cnsld_ar_strms_b
    WHERE sel_id = p_ref_sel_id AND
          receivables_invoice_id IS NOT NULL;

    */
--start:|           14-Mar-2007  cklee      Bug fixed for billing impact             |
-- CURSOR lsm_csr ( p_ref_sel_id NUMBER ) IS
 CURSOR tld_csr ( p_ref_sel_id NUMBER ) IS
--end:|           14-Mar-2007  cklee      Bug fixed for billing impact             |
   SELECT customer_trx_id
   FROM okl_bpd_tld_ar_lines_v
   WHERE sel_id = p_ref_sel_id AND
          customer_trx_id IS NOT NULL;

--start:|           14-Mar-2007  cklee      Bug fixed for billing impact             |
-- l_recv_id      okl_cnsld_ar_strms_b.receivables_invoice_id%TYPE;
 l_recv_id      okl_bpd_tld_ar_lines_v.customer_trx_id%TYPE;
--end:|           14-Mar-2007  cklee      Bug fixed for billing impact             |

BEGIN

    IF p_ref_sel_id IS NULL THEN
        return 'Y';
    END IF;

    l_recv_id := NULL;

--start:|           14-Mar-2007  cklee      Bug fixed for billing impact             |
--    OPEN  lsm_csr ( p_ref_sel_id );
--    FETCH lsm_csr INTO l_recv_id;
--    CLOSE lsm_csr;
    OPEN  tld_csr ( p_ref_sel_id );
    FETCH tld_csr INTO l_recv_id;
    CLOSE tld_csr;
--end:|           14-Mar-2007  cklee      Bug fixed for billing impact             |

    IF l_recv_id > 0 THEN
       return 'Y';
    ELSE
       return 'N';
    END IF;


EXCEPTION
  WHEN others THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '** EXCEPTION IN check_sel_billed: '||p_ref_sel_id||SQLERRM);
    /*  dbms_output.PUT_LINE ('** EXCEPTION IN check_sel_billed: '||p_ref_sel_id||SQLERRM);      */
    return 'N';
END check_sel_billed;



FUNCTION check_rcpts( p_ref_sel_id NUMBER ) RETURN VARCHAR2

AS

 /*
    CURSOR total_rcpts_csr ( p_lsm_id  NUMBER ) IS
           SELECT  NVL(SUM(ARAPP.amount_applied),0)
           FROM
                 OKL_CNSLD_AR_STRMS_V LSM,
                 AR_PAYMENT_SCHEDULES_ALL PMTSCH,
                 AR_RECEIVABLE_APPLICATIONS_ALL ARAPP
           WHERE
                 LSM.ID = p_lsm_id  AND
                 PMTSCH.customer_trx_id  = LSM.receivables_invoice_id AND
                 ARAPP.applied_payment_schedule_id = PMTSCH.payment_schedule_id AND
                 PMTSCH.class            = 'INV' AND
                 exists (
                  SELECT '1'
                  FROM OKL_INVESTOR_PAYOUT_SUMMARY_B pay
                  WHERE pay.receivable_application_id = ARAPP.receivable_application_id AND
                  pay.lsm_id = LSM.ID
                 );

    */
   CURSOR total_rcpts_csr ( p_tld_id  NUMBER ) IS
          SELECT  NVL(SUM(ARAPP.amount_applied),0)
          FROM
--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
--                 OKL_CNSLD_AR_STRMS_V LSM,
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK
               okl_bpd_tld_ar_lines_v TLD,
                AR_PAYMENT_SCHEDULES_ALL PMTSCH,
                AR_RECEIVABLE_APPLICATIONS_ALL ARAPP
	  WHERE
--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
--                 LSM.ID = p_lsm_id  AND
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK
                TLD.TLD_ID = p_tld_id  AND
                PMTSCH.customer_trx_id  = TLD.customer_trx_id AND
                ARAPP.applied_payment_schedule_id = PMTSCH.payment_schedule_id AND
                PMTSCH.class            = 'INV' AND
                exists (
                 SELECT '1'
                 FROM OKL_INVESTOR_PAYOUT_SUMMARY_B pay
		 WHERE pay.receivable_application_id = ARAPP.receivable_application_id AND
--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
--                 pay.lsm_id = TLD.TLD_ID );
                 pay.TLD_ID = TLD.TLD_ID );
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK


/*
    CURSOR total_bill_amt_csr ( p_lsm_id  NUMBER ) IS
           SELECT  PMTSCH.amount_due_original
           FROM  OKL_CNSLD_AR_STRMS_V LSM,
                 AR_PAYMENT_SCHEDULES_ALL PMTSCH
           WHERE LSM.ID = p_lsm_id  AND
                 PMTSCH.customer_trx_id    = LSM.receivables_invoice_id AND
                 PMTSCH.class              = 'INV';

    */

   CURSOR total_bill_amt_csr ( p_tld_id  NUMBER ) IS
   SELECT  PMTSCH.amount_due_original
--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
--           FROM  OKL_CNSLD_AR_STRMS_V LSM,
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK
          FROM  okl_bpd_tld_ar_lines_v TLD,
                AR_PAYMENT_SCHEDULES_ALL PMTSCH
--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
--           WHERE LSM.ID = p_lsm_id  AND
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK
          WHERE TLD.TLD_ID = p_tld_id  AND
                PMTSCH.customer_trx_id    = TLD.customer_trx_id AND
                PMTSCH.class              = 'INV';
/*
     CURSOR get_tld_id ( p_ref_sel_id NUMBER ) IS
          SELECT  TLD_ID
          FROM  okl_bpd_tld_ar_lines_v
          WHERE sel_id = p_ref_sel_id;
*/

/*
    CURSOR get_lsm_id ( p_ref_sel_id NUMBER ) IS
           SELECT  ID
           FROM  OKL_CNSLD_AR_STRMS_V
           WHERE sel_id = p_ref_sel_id;

 */

--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
--    CURSOR get_lsm_id ( p_ref_sel_id NUMBER ) IS
    CURSOR get_tld_id ( p_ref_sel_id NUMBER ) IS
--           SELECT  customer_trx_id
           SELECT  tld_id
           FROM  okl_bpd_tld_ar_lines_v
--           WHERE tld_id = p_ref_sel_id;
           WHERE sel_id = p_ref_sel_id;
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK

--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
--    l_lsm_id             okl_bpd_tld_ar_lines_v.customer_trx_id%TYPE;
    l_tld_id             OKL_TXD_AR_LN_DTLS_B.id%TYPE;
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK
    l_total_rcpt_amt     AR_RECEIVABLE_APPLICATIONS_ALL.amount_applied%TYPE;
    l_total_bill_amt     AR_PAYMENT_SCHEDULES_ALL.amount_due_original%TYPE;

BEGIN
--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
--        OPEN  get_lsm_id ( p_ref_sel_id );
--        FETCH get_lsm_id INTO l_lsm_id;
--        CLOSE get_lsm_id;
        OPEN  get_tld_id ( p_ref_sel_id );
        FETCH get_tld_id INTO l_tld_id;
        CLOSE get_tld_id;
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK

        l_total_bill_amt := NULL;
--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
--        OPEN  total_bill_amt_csr( l_lsm_id );
        OPEN  total_bill_amt_csr( l_tld_id );
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK
        FETCH total_bill_amt_csr INTO l_total_bill_amt;
        CLOSE total_bill_amt_csr;

        l_total_rcpt_amt := NULL;
--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
--        OPEN  total_rcpts_csr( l_lsm_id );
        OPEN  total_rcpts_csr( l_tld_id );
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK
        FETCH total_rcpts_csr INTO l_total_rcpt_amt;
        CLOSE total_rcpts_csr;

        IF ( l_total_rcpt_amt >= l_total_bill_amt ) THEN
            return 'FULL';
        ELSE
            return 'PARTIAL';
        END IF;


EXCEPTION
  WHEN others THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '** EXCEPTION IN check_rcpts: '||p_ref_sel_id||SQLERRM);
    /*  dbms_output.put_line('** EXCEPTION IN check_rcpts: '||p_ref_sel_id||SQLERRM);  */
    return NULL;
END check_rcpts;

-- gboomina Created for Bug 6788005 - Start
-------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : okl_investor_fee_disb
-- Description     : This API is used to create disbursement transactions
--                   for the fees defined in the Investor Agreement
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
--
-- End of comments
-------------------------------------------------------------------------
PROCEDURE okl_investor_fee_disb(
                                p_api_version		       IN  NUMBER
                              , p_init_msg_list	      IN  VARCHAR2
                              , x_return_status	      OUT NOCOPY VARCHAR2
                             	, x_msg_count	         	OUT NOCOPY NUMBER
                             	, x_msg_data		          OUT NOCOPY VARCHAR2
                              , p_investor_agreement  IN  VARCHAR2
                             	, p_to_date		           IN  DATE)
  IS

    -- Cursor to get Investor Agreement details
    CURSOR ia_info_csr IS
      SELECT ia.id,
             ia.authoring_org_id,
             ia.currency_code,
             ia_okl.currency_conversion_type,
             ia_okl.currency_conversion_rate,
             ia_okl.currency_conversion_date,
             ia_okl.legal_entity_id
      FROM okc_k_headers_b ia,
           okl_k_headers ia_okl
      WHERE ia.contract_number = p_investor_agreement
        AND ia_okl.id = ia.id;

      ia_info_rec ia_info_csr%rowtype;

      -- Cursor to get Investors defined in an Investor Agreement
      CURSOR investor_line_csr( p_ia_id NUMBER) IS
        SELECT
         clet.id , -- investor line id
         clet.cust_acct_id,
         clet.bill_to_site_use_id,
         klet.pay_investor_event,
         klet.pay_investor_frequency,
         klet.date_pay_investor_start,
         klet.pay_investor_remittance_days
        FROM okl_k_headers_full_v khr,
             okl_k_lines          klet,
             okc_k_lines_b        clet,
             okc_line_styles_b    lset
        WHERE khr.id              = p_ia_id
        AND   klet.id             = clet.id
        AND   khr.id              = clet.dnz_chr_id
        AND   clet.lse_id         = lset.id
        AND   lset.lty_code       = 'INVESTMENT'
        ORDER BY 1;

      investor_line_rec investor_line_csr%rowtype;

      -- Cursor to get Fee lines defined for an Investor in an Investor Agreement
      CURSOR investor_fee_line_csr ( p_ia_id NUMBER, p_investor_line_id NUMBER) IS
        SELECT okc_fee_line.id
 						      , okc_fee_line.start_date
             , NVL(okl_fee_line.amount,0) amount
													, okl_fee_line.fee_type
        FROM okc_k_lines_b okc_fee_line ,
             okl_k_lines okl_fee_line ,
             okc_line_styles_b lse ,
             okc_k_party_roles_b inv_line_role ,
             okc_k_party_roles_b fee_line_role
        WHERE inv_line_role.cle_id = p_investor_line_id
          AND inv_line_role.dnz_chr_id = p_ia_id
          AND inv_line_role.object1_id1 = fee_line_role.object1_id1
          AND inv_line_role.rle_code = fee_line_role.rle_code
          AND inv_line_role.dnz_chr_id = fee_line_role.dnz_chr_id
          AND fee_line_role.cle_id = okc_fee_line.id
          AND okc_fee_line.lse_id = lse.id
          AND lse.lty_code = 'FEE'
          AND okc_fee_line.chr_id = fee_line_role.dnz_chr_id
          AND okc_fee_line.id = okl_fee_line.id
          AND okl_fee_line.fee_type = 'EXPENSE'
          AND trunc(okc_fee_line.start_date) <= trunc(NVL(p_to_date, SYSDATE));

      investor_fee_line_rec investor_fee_line_csr%rowtype;

      -- Cursor to get the total amount already disbursed to the investor
      CURSOR c_tot_amt_disbursed (p_ia_id  NUMBER, p_vendor_site_id  NUMBER, p_fee_line_id NUMBER)
      IS
      SELECT NVL(SUM(b.amount),0)
        FROM okl_trx_ap_invoices_b a,
             okl_txl_ap_inv_lns_b b
        WHERE a.id = b.tap_id
        AND a.trx_status_code in ('ENTERED', 'APPROVED', 'PROCESSED')
        AND b.amount > 0
        AND b.khr_id = p_ia_id
        AND b.kle_id = p_fee_line_id
        AND EXISTS (SELECT NULL
                    FROM   okx_vendor_sites_v vs
                    WHERE  vs.id1 = a.ipvs_id
                    AND    vs.id1 = p_vendor_site_id);


    -- Cursor to get the fee stream type id
    CURSOR fee_sty_id_csr(p_fee_line_id NUMBER) IS
      SELECT object1_id1 fee_sty_id
      FROM okc_k_items
      WHERE cle_id = p_fee_line_id;

   	l_api_version	  CONSTANT NUMBER         := 1;
   	l_api_name	     CONSTANT VARCHAR2(30)   := 'okl_investor_fee_disb';
   	l_return_status	VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;

    l_pay_to_id NUMBER;
    l_pay_site_id NUMBER;
    l_payment_term_id okl_trx_ap_invoices_v.ippt_id%TYPE;
    l_payment_method okl_trx_ap_invoices_v.payment_method_code%TYPE;
    l_pay_group_code okl_trx_ap_invoices_v.pay_group_lookup_code%TYPE;
    l_fee_line_amount NUMBER;
    l_amount_disbursed NUMBER;
    l_amnt_to_be_disbursed NUMBER;
    l_sty_id                okl_strm_type_v.id%TYPE;
    l_try_id                okl_trx_types_v.id%TYPE;
    l_payout_date           DATE;
				l_investor_name         PO_VENDORS.vendor_name%TYPE;
				l_investor_site_code    PO_VENDOR_SITES.vendor_site_code%TYPE;
    l_strm_name             OKL_STRM_TYPE_V.name%TYPE;

    l_ia_id                 okl_k_headers_full_v.id%type;
    l_currency_code         okl_k_headers_full_v.currency_code%TYPE;
    l_currency_conv_type    okl_k_headers_full_v.currency_conversion_type%TYPE;
    l_currency_conv_rate    okl_k_headers_full_v.currency_conversion_rate%TYPE;
    l_currency_conv_date    okl_k_headers_full_v.currency_conversion_date%TYPE;

    i_tapv_rec          Okl_Trx_Ap_Invoices_Pub.tapv_rec_type;
    i_tplv_rec          OKL_TXL_AP_INV_LNS_PUB.tplv_rec_type;
    i_tplv_tbl          okl_tpl_pvt.tplv_tbl_type;
    r_tapv_rec          Okl_Trx_Ap_Invoices_Pub.tapv_rec_type;
    r_tplv_tbl          okl_tpl_pvt.tplv_tbl_type;

  BEGIN

    ------------------------------------------------------------
    -- Start Processing
    ------------------------------------------------------------
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_return_status := OKL_API.START_ACTIVITY(
                              p_api_name	     => l_api_name,
                              p_pkg_name	     => g_pkg_name,
                              p_init_msg_list	=> p_init_msg_list,
                              l_api_version	  => l_api_version,
                              p_api_version	  => p_api_version,
                              p_api_type  	   => '_PVT',
                              x_return_status	=> l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Get Investor Agreement details
    OPEN 	ia_info_csr;
    FETCH	ia_info_csr INTO ia_info_rec;
    CLOSE	ia_info_csr;
    l_ia_id := ia_info_rec.id;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Processing for Disbursement of Fees :');
				FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '  Investor Agreement :'||p_investor_agreement );
    -- Get the investors defined on an Investor Agreement
    FOR investor_line_rec IN investor_line_csr( l_ia_id)
    LOOP
      -- Get all the expense fees defined for an Investor
      FOR investor_fee_line_rec IN investor_fee_line_csr( l_ia_id
                                          , investor_line_rec.id )
      LOOP
								-- Check whether the fee is already disbursed or not.
        l_fee_line_amount := investor_fee_line_rec.amount;

        OPEN vendor_attrs_csr( l_ia_id, investor_line_rec.id );
        FETCH vendor_attrs_csr INTO l_pay_to_id, l_pay_site_id,
                                    l_payment_term_id, l_payment_method,
                                    l_pay_group_code;
        CLOSE vendor_attrs_csr;

								----------------------------------------
								-- Get Vendor Name from PO_Vendors_All
								----------------------------------------
								l_investor_name := NULL;
								OPEN  vendor_name_csr ( l_pay_to_id );
								FETCH vendor_name_csr INTO l_investor_name;
								CLOSE vendor_name_csr;

								----------------------------------------
								-- Get Vendor Site from po_vendor_sites
								----------------------------------------
								l_investor_site_code := NULL;
								OPEN  vendor_site_csr ( l_pay_site_id );
								FETCH vendor_site_csr INTO l_investor_site_code;
								CLOSE vendor_site_csr;

        -- Get the fee amount that has been disbursed already
        OPEN c_tot_amt_disbursed( l_ia_id, l_pay_site_id, investor_fee_line_rec.id );
        FETCH c_tot_amt_disbursed INTO l_amount_disbursed;
        CLOSE c_tot_amt_disbursed;

        -- Get the remaining amount to be disbursed
        -- For the first time, amount to be disbursed will be same as the
        -- fee line amount
        l_amnt_to_be_disbursed := l_fee_line_amount - l_amount_disbursed;
        IF ( l_amnt_to_be_disbursed > 0) THEN

          -- Get Try Id
          OPEN  try_id_csr;
          FETCH try_id_csr INTO l_try_id;
          CLOSE try_id_csr;

          -- Get Sty Id
          OPEN fee_sty_id_csr ( investor_fee_line_rec.id );
          FETCH fee_sty_id_csr INTO l_sty_id;
          CLOSE fee_sty_id_csr;

										-- Get Sty Id
          OPEN disb_strm_csr ( l_sty_id );
          FETCH disb_strm_csr INTO l_strm_name;
          CLOSE disb_strm_csr;


          -- Calculate Payout Date
          l_payout_date := trunc(SYSDATE) + investor_line_rec.pay_investor_remittance_days;
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-------------------------------------------------------------');
										FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '            Investor: '||l_investor_name);
										FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '       Investor Site: '||l_investor_site_code);
										FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '            Fee Name: '||l_strm_name);
										FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '            Fee Type: '||investor_fee_line_rec.fee_type);
										FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '              Amount: '||investor_fee_line_rec.amount);
										FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '  Fee Effective From: '||investor_fee_line_rec.start_date);
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Payout Event: '||investor_line_rec.PAY_INVESTOR_EVENT);
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '   Payout Start Date: '||investor_line_rec.DATE_PAY_INVESTOR_START);
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '     Remittance Days: '||investor_line_rec.pay_investor_remittance_days);
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '    Payout Frequency: '||investor_line_rec.PAY_INVESTOR_FREQUENCY);
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-------------------------------------------------------------');
										-- Populate Investor Disbursement Header
          i_tapv_rec.org_id                   := ia_info_rec.authoring_org_id;
          i_tapv_rec.currency_code	           := ia_info_rec.currency_code;
          i_tapv_rec.CURRENCY_CONVERSION_TYPE := ia_info_rec.currency_conversion_type;
          i_tapv_rec.CURRENCY_CONVERSION_RATE := ia_info_rec.currency_conversion_rate;
          i_tapv_rec.CURRENCY_CONVERSION_DATE := ia_info_rec.currency_conversion_date;
          i_tapv_rec.legal_entity_id          := ia_info_rec.legal_entity_id;
          i_tapv_rec.try_id                   := l_try_id;
          i_tapv_rec.invoice_type             := 'STANDARD';

          -- The following parameters will be populated in
          -- Okl_Create_Disb_Trans_Pvt if NULL is passed
          i_tapv_rec.set_of_books_id          := NULL;
          i_tapv_rec.invoice_number           := NULL;
          i_tapv_rec.vendor_invoice_number    := NULL;

          i_tapv_rec.vendor_id		              := l_pay_to_id;
          i_tapv_rec.ipvs_id			               := l_pay_site_id;
          i_tapv_rec.khr_id			                := l_ia_id;

          i_tapv_rec.payment_method_code	     := l_payment_method;
          i_tapv_rec.date_entered	            := l_payout_date;
          i_tapv_rec.date_invoiced	           := l_payout_date;
          i_tapv_rec.invoice_category_code    := NULL;
          i_tapv_rec.ippt_id			               := l_payment_term_id;
          i_tapv_rec.DATE_GL                  := l_payout_date;
          i_tapv_rec.Pay_Group_lookup_code    := l_pay_group_code;
          i_tapv_rec.trx_status_code	         := 'ENTERED';
          i_tapv_rec.nettable_yn		            := 'N';

          i_tapv_rec.amount := okl_accounting_util.cross_currency_round_amount
                                 (p_amount => l_amnt_to_be_disbursed
                                 ,p_currency_code => ia_info_rec.currency_code);

          -- Populate Investor Disbursement Lines
          i_tplv_rec.tap_id		            :=  NULL;
          i_tplv_rec.amount		            :=  i_tapv_rec.amount;
          i_tplv_rec.inv_distr_line_code	:=  'INVESTOR';
          i_tplv_rec.line_number        	:=  1;
          i_tplv_rec.org_id	            	:=  ia_info_rec.authoring_org_id;
          i_tplv_rec.disbursement_basis_code := 'BILL_DATE';
          i_tplv_rec.khr_id              :=  l_ia_id;
          i_tplv_rec.kle_id              :=  investor_fee_line_rec.id;
		        i_tplv_rec.sty_id		            :=  l_sty_id;

          -- Add tpl_rec to table
          i_tplv_tbl(1) := i_tplv_rec;

          --Call the commong disbursement API to create transactions
          Okl_Create_Disb_Trans_Pvt.create_disb_trx(
                           p_api_version      =>   p_api_version
                           ,p_init_msg_list    =>   p_init_msg_list
                           ,x_return_status    =>   l_return_status
                           ,x_msg_count        =>   x_msg_count
                           ,x_msg_data         =>   x_msg_data
                           ,p_tapv_rec         =>   i_tapv_rec
                           ,p_tplv_tbl         =>   i_tplv_tbl
                           ,x_tapv_rec         =>   r_tapv_rec
                           ,x_tplv_tbl         =>   r_tplv_tbl);

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF;
      END LOOP;
    END LOOP;

    ------------------------------------------------------------
    -- End Processing
    ------------------------------------------------------------
    x_return_status := l_return_status;

    Okl_Api.END_ACTIVITY (
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data);

  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,' ERROR 1: '||SQLERRM);
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
        p_api_name	=> l_api_name,
        p_pkg_name	=> G_PKG_NAME,
        p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
        x_msg_count	=> x_msg_count,
        x_msg_data	=> x_msg_data,
        p_api_type	=> '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,' ERROR 2: '||SQLERRM);
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
        p_api_name	=> l_api_name,
        p_pkg_name	=> G_PKG_NAME,
        p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count	=> x_msg_count,
        x_msg_data	=> x_msg_data,
        p_api_type	=> '_PVT');

    WHEN OTHERS THEN
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,' ERROR 3: '||SQLERRM);
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
        p_api_name	=> l_api_name,
        p_pkg_name	=> G_PKG_NAME,
        p_exc_name	=> 'OTHERS',
        x_msg_count	=> x_msg_count,
        x_msg_data	=> x_msg_data,
        p_api_type	=> '_PVT');

END okl_investor_fee_disb;
-- gboomina Bug 6788005 - End

PROCEDURE OKL_INVESTOR_DISBURSEMENT
    (p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY      VARCHAR2
	,x_msg_count		OUT NOCOPY      NUMBER
	,x_msg_data		    OUT NOCOPY      VARCHAR2
    ,p_investor_agreement  IN  VARCHAR2
	,p_to_date		    IN  DATE)
IS
	------------------------------------------------------------
	-- Declare Variables required by APIs
	------------------------------------------------------------
   	l_api_version	CONSTANT NUMBER         := 1;
	l_api_name	    CONSTANT VARCHAR2(30)   := 'OKL_INVESTOR_DISBURSEMENT';
	l_return_status	VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;

	-----------------------------------------------------------------
	-- To pick up Investor Invoice Stream elements
	-----------------------------------------------------------------
    CURSOR inv_lease_k_csr ( p_inv_agr   VARCHAR2 ) IS
            SELECT DISTINCT
                    IA.contract_number  Investor_Agreement,
                    IA.id               Investor_Agreement_ID,
                    IA.pdt_id          pdt_id,
                    IA.currency_code,
                    IA.currency_conversion_type,
                    IA.currency_conversion_rate,
                    IA.currency_conversion_date,
                    Poc.khr_id
 -- 02-NOV-2006 ANSETHUR  R12B - Legal Entity
                    ,IA.legal_entity_id
            FROM OKL_POOLS pol,
                 okl_k_headers_full_v IA,
                 okl_pool_contents_v poc,
                 okl_k_headers_full_v LK_KHR
           WHERE IA.Contract_number = NVL( p_inv_agr, IA.Contract_number)
           AND   IA.ID = POL.khr_id
           AND   pol.id = poc.pol_id
           AND   poc.khr_id = LK_KHR.id;
 -- Bug#7009075 - Commented to ensure that IA that have inactive pool contents are also
 -- considered for disbursement. Securtization of future streams and termination of contract
-- will inactivate the pool contents. In this case, the INVESTOR CONTRACT OBLIGATION streams
-- will never get disbursed if pool status is checked for Active.
 --        AND   POC.status_code = 'ACTIVE';

	-----------------------------------------------------------------
	-- To pick up Investor Invoice Stream elements
	-----------------------------------------------------------------
    CURSOR inv_disb_main_csr ( p_ia_id     NUMBER,
                               p_lk_khr_id NUMBER,
                               p_date_to   DATE ) IS
		SELECT
            stm.khr_id		    khr_id,
			TRUNC (ste.stream_element_date)	bill_date,
			stm.kle_id			kle_id,
			ste.id				sel_id,
            ste.sel_id          ref_sel_id,
			stm.sty_id			sty_id,
			khr.contract_number lease_contract,
            khr.currency_code   currency_code,
            khr.authoring_org_id authoring_org_id,
			sty.stream_type_purpose stream_purpose,
			sty.name            stream_name,
            sty.taxable_default_yn  taxable_default_yn,
            sty.stream_type_subclass subclass,
			ste.amount			amount,
            khr.sts_code        sts_code
            --ssiruvol Bug 5000886 start
            ,(select id
            from OKL_TXD_AR_LN_DTLS_B   cnsld
            where  cnsld.khr_id=p_lk_khr_id
            AND cnsld.sel_id =ste.sel_id
            --AND cnsld.receivables_invoice_id IS NOT NULL
            )
            cnsld_id,
	    --ssiruvol Bug 5000886 end
	    oklh.deal_type deal_type
	   	FROM
            okl_strm_elements		ste,
			okl_streams			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			okl_k_headers                  oklh
		WHERE trunc(ste.stream_element_date) <= trunc(NVL(p_date_to, SYSDATE))
        AND   ste.amount    <> 0
		AND	  stm.id		= ste.stm_id
        AND   sty.stream_type_subclass IN ('INVESTOR_DISBURSEMENT','LATE_CHARGE')
        --Added by bkatraga for bug 6983321
        AND   sty.stream_type_purpose NOT IN('INVESTOR_RENT_DISB_BASIS')
        --end bkatraga
		AND	  ste.date_billed	IS NULL
		AND	  stm.active_yn	= 'Y'
		AND	  stm.say_code	= 'CURR'
        --    New Criteria added for further refining the
        --    search criteria
        AND   stm.source_table = 'OKL_K_HEADERS'
        AND   stm.source_id = p_ia_id
        --    End new criteria
	AND	  sty.id		= stm.sty_id
	AND	  khr.id		= stm.khr_id
        AND   khr.ID        = p_lk_khr_id
	AND khr.id = oklh.id
	--Added by bkatraga for bug 6983321
        UNION ALL
	--end bkatraga
		SELECT
            stm.khr_id		    khr_id,
			TRUNC (ste.stream_element_date)	bill_date,
			stm.kle_id			kle_id,
			ste.id				sel_id,
            ste.sel_id          ref_sel_id,
			stm.sty_id			sty_id,
			khr.contract_number lease_contract,
            khr.currency_code   currency_code,
            khr.authoring_org_id authoring_org_id,
			sty.stream_type_purpose stream_purpose,
			sty.name            stream_name,
            sty.taxable_default_yn  taxable_default_yn,
            sty.stream_type_subclass subclass,
			ste.amount			amount,
            khr.sts_code        sts_code
            --ssiruvol Bug 5000886 start
            ,(select id
            from OKL_TXD_AR_LN_DTLS_B   cnsld
            where  cnsld.khr_id=p_lk_khr_id
            AND cnsld.sel_id =ste.sel_id
            --AND cnsld.receivables_invoice_id IS NOT NULL
            )
            cnsld_id,
	    --ssiruvol Bug 5000886 end
	    khl.deal_type deal_type
	   	FROM
            okl_strm_elements		ste,
            -- Bug 4550607
            okl_strm_elements		ste1,
            -- End Bug 4550607
			okl_streams			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			okl_k_headers			khl,
			okc_statuses_b			khs ,
			--Added by bkatraga for bug 6983321
			okl_pools pl,
			okl_pool_contents plcont
    --pgomes fix for bug 4430377
		WHERE trunc(ste.stream_element_date) <= trunc(NVL(p_date_to, SYSDATE))
        AND   ste.amount    <> 0
		AND	  stm.id		= ste.stm_id
        AND   sty.stream_type_subclass IS NULL
        AND   sty.stream_type_purpose  in ( 'INVESTOR_RENT_DISB_BASIS','INVESTOR_PRINCIPAL_DISB_BASIS','INVESTOR_INTEREST_DISB_BASIS','INVESTOR_PPD_DISB_BASIS')
		AND	  ste.date_billed	IS NULL
	        --    New Criteria added for further refining the
        --    search criteria
        AND   stm.source_table = 'OKL_K_HEADERS'
        AND   stm.source_id    = p_ia_id
        --    End new criteria
		AND	  sty.id		= stm.sty_id
		AND	  sty.billable_yn	= 'N'
		AND	  khr.id		= stm.khr_id
		AND	  khr.scs_code	IN ('LEASE', 'LOAN')
 --       AND   khr.sts_code  IN ( 'BOOKED','EVERGREEN')
         --Added TERMINATED, EXPIRED statuses by bkatraga for bug 7120711
           AND   khr.sts_code  IN ( 'BOOKED','EVERGREEN','TERMINATED','EXPIRED')
		AND	  khl.id		= stm.khr_id
		AND	  khl.deal_type	IS NOT NULL
		AND	  khs.code		= khr.sts_code
--		AND	  khs.ste_code	= 'ACTIVE'
          --Added TERMINATED, EXPIRED statuses by bkatraga for bug 7120711
                   AND          khs.ste_code        IN ('ACTIVE','TERMINATED','EXPIRED')
		--AND	  kle.id	 (+)= stm.kle_id
		--AND	  kls.code 	 (+)= kle.sts_code
		--AND	  NVL (kls.ste_code, 'ACTIVE')	= 'ACTIVE'
        AND   khr.ID        = p_lk_khr_id
        -- Bug 4550607
        AND   ste1.id = ste.sel_id
        AND khl.id= khr.id
        AND   ste1.date_billed is not null
        -- End Bug 4550607
        --Added by bkatraga for bug 6983321
        AND   pl.khr_id     = p_ia_id
        AND   pl.id         = plcont.pol_id
        AND   plcont.khr_id = p_lk_khr_id
        AND   plcont.STATUS_CODE = 'ACTIVE'
        AND   plcont.stm_id = stm.stm_id
        AND   (trunc(ste.stream_element_date) <= trunc(plcont.streams_to_date)  OR
               plcont.streams_to_date IS NULL)
	--end bkatraga
		ORDER	BY 1, 2, 3;

	-----------------------------------------------------------------
	-- To fetch revenue share lines
	-----------------------------------------------------------------
    CURSOR share_csr ( p_ia_id NUMBER ) IS
           SELECT
            CLET.ID TOP_LINE_ID,
            CLET.cust_acct_id,
            CLET.bill_to_site_use_id,
            KLET.pay_investor_event,
            KLET.pay_investor_frequency,
            KLET.date_pay_investor_start,
            KLET.pay_investor_remittance_days
           FROM OKL_K_HEADERS_FULL_V KHR,
                OKL_K_LINES          KLET,
                OKC_K_LINES_B        CLET,
                OKC_LINE_STYLES_B    LSET
           WHERE KHR.ID              = p_ia_id
           AND   KLET.ID             = CLET.ID
           AND   KHR.ID              = CLET.DNZ_CHR_ID
           AND   CLET.LSE_ID         = LSET.ID
           AND   LSET.LTY_CODE       = 'INVESTMENT'
           ORDER BY 1;

        l_investor_name             PO_VENDORS.vendor_name%TYPE;
        l_investor_site_code        PO_VENDOR_SITES.vendor_site_code%TYPE;

--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
--    CURSOR rcpts_csr ( p_lsm_id  NUMBER,
--start:|           25-Jun-2008 cklee      Fixed bug: 6784252                        |
/*
   CURSOR rcpts_csr ( p_tld_id  NUMBER,
                      p_inv_agr_id NUMBER,
                      p_inv_agr_line_id NUMBER ) IS
          SELECT   ARAPP.receivable_application_id,
         ARAPP.cash_receipt_id,
         ARAPP.LINE_APPLIED AMOUNT_APPLIED,
         ARAPP.apply_date,
         ARAPP.applied_customer_trx_id,
         PMTSCH.trx_number,
	PMTSCH.trx_date,
         PMTSCH.amount_due_original,
         PMTSCH.amount_due_remaining,
         TLD.TLD_ID TLD_ID,
         TLD.LINE_amount AMOUNT
FROM
      okl_bpd_tld_ar_lines_v TLD,
      AR_PAYMENT_SCHEDULES_ALL PMTSCH,
      AR_RECEIVABLE_APPLICATIONS_ALL ARAPP,
      ra_Customer_trx_Lines_All cUst_trx_Lines ,
      ar_Activity_Details arl
WHERE
                TLD.TLD_ID = p_tld_id  AND
                PMTSCH.customer_trx_id    = TLD.customer_trx_id AND
                ARAPP.LINE_APPLIED > 0                                 AND
                ARAPP.applied_payment_schedule_id = PMTSCH.payment_schedule_id AND
                PMTSCH.class  = 'INV' AND
                NOT EXISTS (
                 SELECT '1'
                 FROM OKL_INVESTOR_PAYOUT_SUMMARY_B pay
                 WHERE pay.receivable_application_id = ARAPP.receivable_application_id AND
                       pay.investor_agreement_id = p_inv_agr_id AND
                       pay.investor_line_id = p_inv_agr_line_id AND
                       pay.TLD_ID = TLD.TLD_ID) AND
                TLD.Customer_trx_Line_Id = cUst_trx_Lines.Customer_trx_Line_Id AND cUst_trx_Lines.Line_Type = 'LINE' AND
                ARAPP.Receivable_Application_Id = arl.Source_Id AND arl.Source_Table = 'RA' AND arl.Customer_trx_Line_Id = cUst_trx_Lines.Customer_trx_Line_Id AND cUst_trx_Lines.Line_Type = 'LINE'
                AND PMTSCH.Payment_Schedule_Id = ARAPP.Applied_Payment_Schedule_Id ;*/
-- sosharma commented for bug 9578399
/*   CURSOR rcpts_csr ( p_tld_id  NUMBER,
                      p_inv_agr_id NUMBER,
                      p_inv_agr_line_id NUMBER ) IS
          SELECT   ARAPP.receivable_application_id,
         ARAPP.cash_receipt_id,
         ARAPP.LINE_APPLIED AMOUNT_APPLIED,
         ARAPP.apply_date,
         ARAPP.applied_customer_trx_id,
         PMTSCH.trx_number,
	PMTSCH.trx_date,
         PMTSCH.amount_due_original,
         PMTSCH.amount_due_remaining,
         TLD.TLD_ID TLD_ID,
         TLD.LINE_amount AMOUNT
FROM
      okl_bpd_tld_ar_lines_v TLD,
      AR_PAYMENT_SCHEDULES_ALL PMTSCH,
      AR_RECEIVABLE_APPLICATIONS_ALL ARAPP
WHERE
                TLD.TLD_ID = p_tld_id  AND
                PMTSCH.customer_trx_id    = TLD.customer_trx_id AND
                ARAPP.LINE_APPLIED > 0                                 AND
                ARAPP.applied_payment_schedule_id = PMTSCH.payment_schedule_id AND
                PMTSCH.class  = 'INV' AND
                PMTSCH.customer_trx_id = TLD.customer_trx_id AND -- cklee 06/25/08
                NOT EXISTS (
                 SELECT '1'
                 FROM OKL_INVESTOR_PAYOUT_SUMMARY_B pay
                 WHERE pay.receivable_application_id = ARAPP.receivable_application_id AND
                       pay.investor_agreement_id = p_inv_agr_id AND
                       pay.investor_line_id = p_inv_agr_line_id AND
                       pay.TLD_ID = TLD.TLD_ID);
--end:|           25-Jun-2008 cklee      Fixed bug: 6784252                        |
*/
-- sosharma added for bug 9578399
CURSOR rcpts_csr ( p_tld_id  NUMBER,
                      p_inv_agr_id NUMBER,
                      p_inv_agr_line_id NUMBER ) IS
select
ARAPP.receivable_application_id,
ARAPP.cash_receipt_id,
ARAPP.LINE_APPLIED AMOUNT_APPLIED,
ARAPP.apply_date,
ARAPP. customer_trx_id applied_customer_trx_id,
ARAPP.invoice_number trx_number,
ARAPP.invoice_date trx_date,
TLD.amount_due_original amount_due_original,
TLD.amount_due_remaining amount_due_remaining,
TLD.TLD_ID TLD_ID,
TLD.LINE_amount AMOUNT
FROM
okl_bpd_tld_ar_lines_v TLD,
okl_receipt_applications_uv ARAPP
WHERE
TLD.TLD_ID = p_tld_id  AND
ARAPP.LINE_APPLIED > 0   AND
Nvl(ARAPP.customer_trx_line_id, TLD.customer_trx_line_id) = TLD.customer_trx_line_id AND
ARAPP.customer_trx_id = TLD.customer_trx_id AND
NOT EXISTS (
SELECT '1'
FROM OKL_INVESTOR_PAYOUT_SUMMARY_B pay
WHERE pay.receivable_application_id = ARAPP.receivable_application_id AND
pay.investor_agreement_id = p_inv_agr_id AND
pay.investor_line_id = p_inv_agr_line_id AND
pay.TLD_ID = TLD.TLD_ID);

    CURSOR get_receipt_number(p_cash_receipt_id  NUMBER) IS
            SELECT RECEIPT_NUMBER
            FROM ar_cash_receipts_all
            WHERE cash_receipt_id = p_cash_receipt_id;

    CURSOR cm_number ( p_app_trx_id NUMBER ) IS
           SELECT trx_number
           FROM ra_customer_trx_all
           WHERE customer_trx_id = p_app_trx_id;

--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
   CURSOR total_bill_amt_csr ( p_tld_id  NUMBER ) IS
          SELECT  PMTSCH.amount_due_original
          FROM  okl_bpd_tld_ar_lines_v TLD,
                AR_PAYMENT_SCHEDULES_ALL PMTSCH
          WHERE TLD.TLD_ID = p_tld_id  AND
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK
                PMTSCH.customer_trx_id    = TLD.customer_trx_id AND
                PMTSCH.class              = 'INV';


	-----------------------------------------------------------------
	-- Record definitions
	-----------------------------------------------------------------
    i_tapv_rec          Okl_Trx_Ap_Invoices_Pub.tapv_rec_type;
    l_init_tapv_rec     Okl_Trx_Ap_Invoices_Pub.tapv_rec_type;
    r_tapv_rec          Okl_Trx_Ap_Invoices_Pub.tapv_rec_type;

    i_tplv_rec          OKL_TXL_AP_INV_LNS_PUB.tplv_rec_type;
    l_init_tplv_rec     OKL_TXL_AP_INV_LNS_PUB.tplv_rec_type;
    r_tplv_rec          OKL_TXL_AP_INV_LNS_PUB.tplv_rec_type;

    /*ankushar 11-Jan-2007
    added table definitions
    Start Changes*/
    i_tplv_tbl          okl_tpl_pvt.tplv_tbl_type;
    l_init_tplv_tbl     okl_tpl_pvt.tplv_tbl_type;
    r_tplv_tbl          okl_tpl_pvt.tplv_tbl_type;
    /*ankushar end changes*/

	-----------------------------------------------------------------
	-- Local Variables
	-----------------------------------------------------------------
    l_commit_cnt           NUMBER;
    l_MAX_commit_cnt       NUMBER := 500;
    l_break_khr_id         NUMBER;
    l_break_top_line_id    NUMBER;
--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
--    l_break_lsm_id         NUMBER;
    l_break_tld_id         NUMBER;
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK
    l_break_disb_type      VARCHAR2(50);

	-----------------------------------------------------------------
	-- Error Processing Variables
	-----------------------------------------------------------------
    l_error_status      VARCHAR2(1);
    l_error_message     VARCHAR2(300);

--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
--    TYPE lsm_err_rec_type IS RECORD (
    TYPE tld_err_rec_type IS RECORD (
--            lsm_id              okl_cnsld_ar_strms_v.id%TYPE,
            tld_id              OKL_TXD_AR_LN_DTLS_B.id%TYPE,
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK
            tap_id              okl_trx_ap_invoices_v.id%TYPE,
            tpl_id              okl_txl_ap_inv_lns_v.id%TYPE,
          --  xpi_id              okl_ext_pay_invs_v.id%TYPE,
          --  xlp_id              okl_xtl_pay_invs_v.id%TYPE,
            proc_sel_id         okl_strm_elements.id%TYPE,
			bill_date           DATE,
			contract_number     okc_k_headers_b.contract_number%type,
			stream_name         okl_strm_type_v.name%type,
			amount              okl_strm_elements.amount%type,
            error_message       Varchar2(2000)
	);

--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
--    TYPE lsm_succ_rec_type IS RECORD (
--            lsm_id              okl_cnsld_ar_strms_v.id%TYPE,
    TYPE tld_succ_rec_type IS RECORD (
            tld_id              OKL_TXD_AR_LN_DTLS_B.id%TYPE,
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK
            tap_id              okl_trx_ap_invoices_v.id%TYPE,
            tpl_id              okl_txl_ap_inv_lns_v.id%TYPE,
          --  xpi_id              okl_ext_pay_invs_v.id%TYPE,
          --  xlp_id              okl_xtl_pay_invs_v.id%TYPE,
            proc_sel_id         okl_strm_elements.id%TYPE,
			bill_date           DATE,
			contract_number     okc_k_headers_b.contract_number%type,
			stream_name         okl_strm_type_v.name%type,
			amount              okl_strm_elements.amount%type,
            error_message       Varchar2(2000)
	);

    TYPE tld_err_tbl_type IS TABLE OF tld_err_rec_type
            INDEX BY BINARY_INTEGER;

    TYPE tld_succ_tbl_type IS TABLE OF tld_succ_rec_type
            INDEX BY BINARY_INTEGER;

    tld_error_log_table 	    tld_err_tbl_type;
    l_init_tld_table            tld_err_tbl_type;

    tld_succ_log_table 	        tld_succ_tbl_type;
    l_init_succ_table           tld_succ_tbl_type;

    l_succ_tab_index             NUMBER;
    l_tld_tab_index             NUMBER;
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK

	-----------------------------------------------------------------
	-- Process Variables And Cursors
	-----------------------------------------------------------------
    l_org_id                okc_k_headers_b.authoring_org_id%TYPE;
    l_sob_id                HR_OPERATING_UNITS.set_of_books_id%TYPE;
    l_try_id                okl_trx_types_v.id%TYPE;
    l_sty_id                okl_strm_type_v.id%TYPE;
    l_pdt_id                okl_products_v.id%TYPE;

    l_payout_date           DATE;

    l_rct_num               ar_cash_receipts_all.receipt_number%TYPE;
    l_trx_num               ra_customer_trx_all.trx_number%TYPE;

    l_total_rcpt_amt        NUMBER;
    l_total_bill_amt        NUMBER;

    l_update_flag           VARCHAR2(1);

    l_investor_id           NUMBER;
    l_investor_site_id      NUMBER;
    l_pay_terms             okl_trx_ap_invoices_v.ippt_id%TYPE;
    l_pay_method            okl_trx_ap_invoices_v.payment_method_code%TYPE;
    l_pay_group_code        okl_trx_ap_invoices_v.pay_group_lookup_code%TYPE;

    l_payment_basis         fnd_lookups.meaning%TYPE;
    l_payment_event         fnd_lookups.meaning%TYPE;

    l_currency_code         okl_k_headers_full_v.currency_code%TYPE;
    l_currency_conv_type    okl_k_headers_full_v.currency_conversion_type%TYPE;
    l_currency_conv_rate    okl_k_headers_full_v.currency_conversion_rate%TYPE;
    l_currency_conv_date    okl_k_headers_full_v.currency_conversion_date%TYPE;

    l_code_combination_id   OKL_AE_TMPT_LNES.code_combination_id%TYPE;
    l_ae_line_type          OKL_AE_TMPT_LNES.ae_line_type%TYPE;
    l_crd_code              OKL_AE_TMPT_LNES.crd_code%TYPE;
    l_account_builder_yn    OKL_AE_TMPT_LNES.account_builder_yn%TYPE;
    l_percentage            OKL_AE_TMPT_LNES.percentage%TYPE;

	l_okl_application_id    NUMBER(3) := 540;
	l_document_category     VARCHAR2(100):= 'OKL Lease Pay Invoices';
	lX_dbseqnm              VARCHAR2(2000):= '';
	lX_dbseqid              NUMBER(38):= NULL;

    l_invoice_number        okl_trx_ap_invoices_v.invoice_number%TYPE;

    -- Create Distributions
    CURSOR dstrs_csr( p_pdt_id NUMBER, p_try_id NUMBER, p_sty_id NUMBER,
                      p_cr_dr_flag VARCHAR2,
                      p_payout_date DATE ) IS
           SELECT
            C.CODE_COMBINATION_ID,
            C.AE_LINE_TYPE,
            C.CRD_CODE,
            C.ACCOUNT_BUILDER_YN,
            C.PERCENTAGE
           FROM OKL_AE_TEMPLATES A,
                OKL_PRODUCTS_V     B,
                OKL_AE_TMPT_LNES C
           WHERE A.aes_id = b.aes_id AND
                 A.start_date <= p_payout_date AND
                 A.memo_yn  = 'N'  AND
                (A.end_date IS NULL OR
                 A.end_date >= p_payout_date ) AND
                b.id     = p_pdt_id AND
                a.sty_id = p_sty_id AND
                a.try_id = p_try_id AND
                C.avl_id = A.id     AND
                C.CRD_CODE = p_cr_dr_flag;

--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
   CURSOR get_ref_tld_id ( p_ref_sel_id NUMBER ) IS
   SELECT tld_Id
          FROM okl_bpd_tld_ar_lines_v
          WHERE sel_id = p_ref_sel_id
          AND CUSTOMER_TRX_ID IS NOT NULL;
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK


	-----------------------------------------------------------------
	-- Get parent sty Id for an SEL_ID
	-----------------------------------------------------------------
    CURSOR get_parent_sty ( p_ref_sel_id NUMBER ) IS
        SELECT STM.STY_ID
        FROM OKL_STRM_ELEMENTS SEL,
             OKL_STREAMS       STM
        WHERE SEL.ID      =  p_ref_sel_id
        AND   SEL.STM_ID  = STM.ID;

    CURSOR get_parent_stake ( p_top_line_id NUMBER
                             ,p_sty_subclass    VARCHAR2 ) IS
        SELECT
            KLES.percent_stake
        FROM OKL_K_LINES          KLES,
             OKC_K_LINES_B        CLES,
             OKC_LINE_STYLES_B    LSES
        WHERE CLES.cle_id         = p_top_line_id
        AND   KLES.stream_type_subclass        = p_sty_subclass
        AND   KLES.ID             = CLES.ID
        AND   CLES.LSE_ID         = LSES.ID
        AND   LSES.LTY_CODE       = 'REVENUE_SHARE';


--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
    l_ref_tld_id          OKL_TXD_AR_LN_DTLS_B.id%TYPE;
--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK

    l_percent_stake       okl_k_lines.percent_stake%TYPE;

    l_parent_sty_id       okl_strm_type_v.id%TYPE;

    l_dstr_cnt            NUMBER;

    l_idh_id              NUMBER;

    l_rcpt_cnt            NUMBER;

    l_parent_sty_subclass OKL_STRM_TYPE_V.stream_type_subclass%TYPE;

    l_disb_strm_name      OKL_STRM_TYPE_V.name%TYPE;

    -- Start Bug 4648410
    l_tmpl_identify_rec         Okl_Account_Dist_Pvt.TMPL_IDENTIFY_REC_TYPE;
    l_init_tmpl_identify_rec    Okl_Account_Dist_Pvt.TMPL_IDENTIFY_REC_TYPE;

    l_dist_info_rec             Okl_Account_Dist_Pvt.dist_info_REC_TYPE;
    l_init_dist_info_rec        Okl_Account_Dist_Pvt.dist_info_REC_TYPE;

    l_ctxt_val_tbl              okl_execute_formula_pvt.ctxt_val_tbl_type;

    l_acc_gen_primary_key_tbl   Okl_Account_Generator_Pvt.primary_key_tbl;
    l_template_tbl         	    Okl_Account_Dist_Pub.AVLV_TBL_TYPE;
    l_amount_tbl         	    Okl_Account_Dist_Pub.AMOUNT_TBL_TYPE;

    CURSOR acc_dstrs_csr ( p_source_id NUMBER, p_source_table VARCHAR2 ) IS
        SELECT  CR_DR_FLAG,
                CODE_COMBINATION_ID,
                SOURCE_ID,
                AMOUNT,
                PERCENTAGE,
                NVL(COMMENTS,'-99') COMMENTS
        FROM okl_trns_acc_dstrs
        WHERE source_id = p_source_id
        AND source_table = p_source_table
		--fmiao bug 5079244
        ORDER BY CR_DR_FLAG;

    CURSOR inv_code_csr(p_inv_agr_id NUMBER) IS
        select RULE_INFORMATION1
        from okc_rule_groups_v rgp,
             okc_rules_b rul
        where rgp.id = rul.rgp_id
        and rgp.dnz_chr_id = p_inv_agr_id
        and rul.RULE_INFORMATION_CATEGORY = 'LASEAC'
        and rgp.RGD_CODE = 'LASEAC';
    -- End Bug 4648410

    --fmiao for bug 4961860: check whether residual exists
	CURSOR check_res_in_pool(p_khr_id NUMBER) IS
	SELECT 'Y'
	FROM dual
	WHERE EXISTS
	( SELECT 1
	FROM OKL_POOLS pool, okl_pool_contents_v poc, okl_strm_type_v sty
	WHERE pool.khr_id = p_khr_id
	AND pool.id = poc.pol_id
	AND poc.sty_id = sty.id
	AND sty.stream_type_purpose = 'RESIDUAL_VALUE'
        AND poc.status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE);  --Added by VARANGAN -Pool Contents Impact(Bug#6658065)

	l_res_in_pool VARCHAR2(1);
	l_evrgrn_psthrgh_flg NUMBER := 0;
	-- end fmiao for bug 4961860

    --ssiruvol Bug 5000886 start
    TYPE l_ele_id_tbl_type IS TABLE OF okl_strm_elements.id%TYPE
            INDEX BY BINARY_INTEGER;

    strm_ele_idx NUMBER;
    inv_ele_idx NUMBER;
    l_strm_ele_id_tbl l_ele_id_tbl_type;
    l_inv_ele_id_tbl  l_ele_id_tbl_type;
    l_temp_ele_id_tbl l_ele_id_tbl_type;
    inv_ele_prtl_idx NUMBER;
    l_inv_prtl_id_tbl l_ele_id_tbl_type;
    l_billed                VARCHAR2(1);
    --ssiruvol Bug 5000886 end

    TYPE lsm_succ_rec_type IS RECORD (
            lsm_id              OKL_TXD_AR_LN_DTLS_B.id%TYPE,
            tap_id              okl_trx_ap_invoices_v.id%TYPE,
            tpl_id              okl_txl_ap_inv_lns_v.id%TYPE,
            xpi_id              okl_ext_pay_invs_v.id%TYPE,
            xlp_id              okl_xtl_pay_invs_v.id%TYPE,
            proc_sel_id         okl_strm_elements.id%TYPE,
			bill_date           DATE,
			contract_number     okc_k_headers_b.contract_number%type,
			stream_name         okl_strm_type_v.name%type,
			amount              okl_strm_elements.amount%type,
            error_message       Varchar2(2000)
	);

    TYPE lsm_succ_tbl_type IS TABLE OF lsm_succ_rec_type
            INDEX BY BINARY_INTEGER;

    lsm_succ_log_table 	        lsm_succ_tbl_type;

BEGIN

   /*   dbms_application_info.set_client_info('204');  */
	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '=====*** START PROCEDURE OKL_INVESTOR_DISBURSEMENT ***=====');

    --dbms_output.PUT_LINE ('=====*** START PROCEDURE OKL_INVESTOR_DISBURSEMENT ***=====');

	x_return_status := OKL_API.G_RET_STS_SUCCESS;

	l_return_status := OKL_API.START_ACTIVITY(
		p_api_name	    => l_api_name,
    	p_pkg_name	    => g_pkg_name,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type  	=> '_PVT',
		x_return_status	=> l_return_status);

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    ------------------------------------
    -- Initialize Variables
    ------------------------------------
    l_commit_cnt        := 0;

    -----------------------------------------------------------------
    -- Pick up lease contracts
    -- in an Investor Agreement
    -----------------------------------------------------------------

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 1 ### ');

    FOR inv_lease_k_rec IN inv_lease_k_csr ( p_investor_agreement ) LOOP
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 2 ### ');
    --ssiruvol Bug 5000886 start
	strm_ele_idx :=1;
        inv_ele_idx :=1;
        l_inv_ele_id_tbl:=l_temp_ele_id_tbl;
        inv_ele_prtl_idx := 1;
        l_inv_prtl_id_tbl := l_temp_ele_id_tbl;
    --ssiruvol Bug 5000886 end


    -----------------------------------------------------------------
    -- Pick up disbursable stream elements for lease contracts
    -- in an Investor Agreement
    -----------------------------------------------------------------
    FOR inv_disb_rec IN inv_disb_main_csr( inv_lease_k_rec.Investor_Agreement_ID
                                          ,inv_lease_k_rec.khr_id
                                          ,p_to_date) LOOP

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 3 ### ');
        ------------------------------------
        -- Initialize Variables
        ------------------------------------
        l_break_khr_id      := -1;
        l_break_top_line_id := -1;

		-- Added by fmiao for bug 4961860
		l_evrgrn_psthrgh_flg := 0;
		IF(inv_disb_rec.STREAM_PURPOSE = 'INVESTOR_EVERGREEN_RENT_PAY') THEN
		  OPEN check_res_in_pool(inv_lease_k_rec.Investor_Agreement_ID);
		  FETCH check_res_in_pool INTO l_res_in_pool;
		  CLOSE check_res_in_pool;
		  IF(l_res_in_pool IS NULL OR l_res_in_pool <> 'Y') THEN
		    l_evrgrn_psthrgh_flg := 1;
		  END IF;
		END IF;
		-- end fmiao for bug 4961860

	--ssiruvol Bug 5000886 start
        l_billed := 'N';
        if(inv_disb_rec.ref_sel_id is NULL) then
           l_billed :='Y';
        elsif (inv_disb_rec.cnsld_id is NULL) then
           l_billed :='N';
        else
           l_billed :='Y';
        end if;
        --ssiruvol Bug 5000886 end

         -----------------------------------------------------------------
        -- Check if the parent stream element has been billed
        -----------------------------------------------------------------
        -- Added condition l_evrgrn_psthrgh_flg by bkatraga for bug 4922294
        -- ssiruvol Bug 5000886 start
	--IF ((check_sel_billed( inv_disb_rec.ref_sel_id ) = 'Y') AND l_evrgrn_psthrgh_flg = 0) THEN
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 4 ### ');
	IF (l_billed = 'Y' AND l_evrgrn_psthrgh_flg = 0) THEN
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 5 ### ');
        -- ssiruvol Bug 5000886 end


        -----------------------------------------------------------------
        -- Reset Error Status
        -----------------------------------------------------------------
        l_error_status  := 'S';

        -----------------------------------------------------------------
        -- Reset Error Table and counter
        -----------------------------------------------------------------
--start:|           09-Mar-2007  cklee      code fixed to refer to proper FK
        tld_error_log_table := l_init_tld_table;
        l_tld_tab_index     := 0;

        tld_succ_log_table 	:= l_init_succ_table;
        l_succ_tab_index    := 0;

--end:|           09-Mar-2007  cklee      code fixed to refer to proper FK

       -----------------------------------------------------------------
       -- Determine investor and share
       -----------------------------------------------------------------
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 6 ### ');
       FOR share_rec IN share_csr ( inv_lease_k_rec.Investor_Agreement_ID ) LOOP
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 7 ### ');

        l_sty_id := NULL;
        IF inv_disb_rec.Stream_purpose = 'INVESTOR_RENT_DISB_BASIS' THEN

            Okl_Streams_Util.get_primary_stream_type(
		               p_khr_id => inv_lease_k_rec.Investor_Agreement_ID,
		               p_primary_sty_purpose => 'INVESTOR_RENT_PAYABLE',
		               x_return_status => l_return_status,
		               x_primary_sty_id => l_sty_id );
            IF l_sty_id IS NULL THEN
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '    -*- No attached INVESTOR_RENT_PAYABLE stream type found.');
            END IF;
	  ELSIF inv_disb_rec.Stream_purpose = 'INVESTOR_PRINCIPAL_DISB_BASIS' THEN

            Okl_Streams_Util.get_primary_stream_type(
		               p_khr_id => inv_lease_k_rec.Investor_Agreement_ID,
		               p_primary_sty_purpose => 'INVESTOR_PRINCIPAL_PAYABLE',
		               x_return_status => l_return_status,
		               x_primary_sty_id => l_sty_id );
            IF l_sty_id IS NULL THEN
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '    -*- No attached INVESTOR_PRINCIPAL_PAYABLE stream type found.');
            END IF;
         ELSIF inv_disb_rec.Stream_purpose = 'INVESTOR_INTEREST_DISB_BASIS' THEN

            Okl_Streams_Util.get_primary_stream_type(
		               p_khr_id => inv_lease_k_rec.Investor_Agreement_ID,
		               p_primary_sty_purpose => 'INVESTOR_INTEREST_PAYABLE',
		               x_return_status => l_return_status,
		               x_primary_sty_id => l_sty_id );
            IF l_sty_id IS NULL THEN
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '    -*- No attached INVESTOR_INTEREST_PAYABLE stream type found.');
            END IF;
           ELSIF inv_disb_rec.Stream_purpose = 'INVESTOR_PPD_DISB_BASIS' THEN

            Okl_Streams_Util.get_primary_stream_type(
		               p_khr_id => inv_lease_k_rec.Investor_Agreement_ID,
		               p_primary_sty_purpose => 'INVESTOR_PAYDOWN_PAYABLE',
		               x_return_status => l_return_status,
		               x_primary_sty_id => l_sty_id );
            IF l_sty_id IS NULL THEN
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '    -*- No attached INVESTOR_PAYDOWN_PAYABLE stream type found.');
            END IF;
        ELSIF inv_disb_rec.Stream_purpose IN ('INVESTOR_LATE_FEE_PAYABLE',
                                              'INVESTOR_LATE_INTEREST_PAY',
                                              'INVESTOR_RENT_BUYBACK',
                                              'INVESTOR_PRINCIPAL_BUYBACK',
                                              'INVESTOR_INTEREST_BUYBACK',
                                               'INVESTOR_PAYDOWN_BUYBACK',
                                              'INVESTOR_RESIDUAL_BUYBACK',
                                              'INVESTOR_EVERGREEN_RENT_PAY',
                                              'INVESTOR_RESIDUAL_PAY',
                                              'INVESTOR_CNTRCT_OBLIGATION_PAY',
                                              'INVESTOR_DISB_ADJUSTMENT')
        THEN
            l_sty_id := inv_disb_rec.sty_id;
        ELSE
            l_sty_id := NULL;
        END IF;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 8 ### ');
        -- Get Disbursement Stream Name
        l_disb_strm_name := NULL;
        OPEN  disb_strm_csr( l_sty_id );
        FETCH disb_strm_csr INTO l_disb_strm_name;
        CLOSE disb_strm_csr;
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 9 ### ');
        ------------------------------------------------------------------
        -- Work out common variables
        ------------------------------------------------------------------
        IF ( inv_lease_k_rec.Investor_Agreement_id <> l_break_khr_id OR
             share_rec.TOP_LINE_ID <> l_break_top_line_id ) THEN

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 10 ### ');
            -------------------------------------------------------
            -- Reset Break detection variables
            -------------------------------------------------------
            l_break_khr_id      := inv_lease_k_rec.Investor_Agreement_id;
            l_break_top_line_id := share_rec.TOP_LINE_ID;

            -----------------------------------------------
            -- Resolve common data on break detection
            -----------------------------------------------

            -- Set Local Variables to Null

            l_org_id              := NULL;
            l_sob_id              := NULL;
            l_try_id              := NULL;

            l_pdt_id              := NULL;
            l_currency_code       := NULL;
            l_currency_conv_type  := NULL;
            l_currency_conv_rate  := NULL;
            l_currency_conv_date  := NULL;
            l_investor_id         := NULL;
            l_investor_site_id    := NULL;
            l_pay_terms           := NULL;
            l_pay_method          := NULL;
            l_pay_group_code      := NULL;
            l_payment_basis       := NULL;
            l_payment_event       := NULL;

            -----------------------------------------------
            -- Fetch Org Id into Local Variable
            -----------------------------------------------
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 11 ### ');
           	OPEN 	org_id_csr ( inv_lease_k_rec.Investor_Agreement_id );
	        FETCH	org_id_csr INTO l_org_id;
	        CLOSE	org_id_csr;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 12 ### ');
            -----------------------------------------------
            -- Fetch Set Of Books into Local Variable
            -----------------------------------------------
           	OPEN 	sob_csr (l_org_id) ;
	        FETCH	sob_csr INTO l_sob_id;
	        CLOSE	sob_csr;
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 13 ### ');

            -----------------------------------------------
            -- Fetch try_id into Local Variable
            -----------------------------------------------
	        OPEN  try_id_csr;
	        FETCH try_id_csr INTO l_try_id;
	        CLOSE try_id_csr;
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 14 ### ');

            -----------------------------------------------
            -- Select Investor attributes
            -----------------------------------------------
            OPEN  vendor_attrs_csr ( inv_lease_k_rec.Investor_Agreement_id, share_rec.TOP_LINE_ID );
            FETCH vendor_attrs_csr INTO     l_investor_id,
                                            l_investor_site_id,
                                            l_pay_terms,
                                            l_pay_method,
                                            l_pay_group_code;
            CLOSE vendor_attrs_csr;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 15 ### ');
            ----------------------------------------
            -- Get Vendor Name from PO_Vendors_All
            ----------------------------------------
            l_investor_name := NULL;
            OPEN  vendor_name_csr ( l_investor_id );
            FETCH vendor_name_csr INTO l_investor_name;
            CLOSE vendor_name_csr;
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 16 ### ');

            ----------------------------------------
            -- Get Vendor Site from po_vendor_sites
            ----------------------------------------
            l_investor_site_code := NULL;
            OPEN  vendor_site_csr ( l_investor_site_id );
            FETCH vendor_site_csr INTO l_investor_site_code;
            CLOSE vendor_site_csr;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 17 ### ');
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Processing Investor Agreement: '
                                                 ||inv_lease_k_rec.Investor_Agreement
                                                 ||' Investor: '||l_investor_name
                                                 ||' Investor Site: '||l_investor_site_code);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Lease Contract: '||inv_disb_rec.Lease_Contract);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Source Stream Name: '||inv_disb_rec.Stream_Name);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Source Stream Purpose: '||inv_disb_rec.Stream_purpose);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Disbursed Stream: '||l_disb_strm_name);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Stream Amount: '||inv_disb_rec.amount);
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Stream Date: '||inv_disb_rec.bill_date);

            -----------------------------------------------
            -- Select Basis and Event
            -----------------------------------------------
            l_pdt_id              := inv_lease_k_rec.pdt_id;
            l_currency_code       := inv_lease_k_rec.currency_code;
            l_currency_conv_type  := inv_lease_k_rec.currency_conversion_type;
            l_currency_conv_rate  := inv_lease_k_rec.currency_conversion_rate;
            l_currency_conv_date  := inv_lease_k_rec.currency_conversion_date;

            -- Resolve Currency Convesion Parameters for Multi-Currency
            IF l_currency_conv_type IS NULL THEN
                l_currency_conv_type  := 'User';
                l_currency_conv_rate  := 1;
                l_currency_conv_date  := SYSDATE;
            END IF;
            -- For date
            IF l_currency_conv_date IS NULL THEN
	           l_currency_conv_date := SYSDATE;
            END IF;

            -- For rate -- Work out the rate in a Spot or Corporate
            IF (l_currency_conv_type = 'User') THEN
                IF l_currency_conv_rate IS NULL THEN
                    l_currency_conv_rate := 1;
                END IF;
            END IF;
            IF (l_currency_conv_type = 'Spot'
            OR l_currency_conv_type = 'Corporate') THEN
                    l_currency_conv_rate := NULL;
            END IF;
        END IF; -- Investor Agreement Level Break


	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 20 ### ');

       -----------------------------------------------------------------
       -- Determine Basis and Event
       -----------------------------------------------------------------
       OPEN  payout_attrs_csr ( inv_lease_k_rec.Investor_Agreement_ID );
       FETCH payout_attrs_csr INTO l_payment_basis, l_payment_event;
       CLOSE payout_attrs_csr;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 21 ### ');
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Payout Basis: '||l_payment_event);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Payout Event: '||share_rec.PAY_INVESTOR_EVENT
                                            ||' Start Date: '||share_rec.DATE_PAY_INVESTOR_START
                                            ||' Remittance Days: '||share_rec.pay_investor_remittance_days);
       FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Payout Frequency: '||share_rec.PAY_INVESTOR_FREQUENCY);

            l_percent_stake := NULL;

           -- --------------------------------------------------------------
           -- Get the Parent Subclass corresponding to the sty purpose that
           -- we are dealing with
           -- --------------------------------------------------------------
            l_parent_sty_subclass := NULL;

            IF inv_disb_rec.Stream_purpose IN ('INVESTOR_RENT_BUYBACK',
                                               'INVESTOR_RENT_DISB_BASIS')
            THEN
               l_parent_sty_subclass := 'RENT';
             ELSIF inv_disb_rec.Stream_purpose IN  ('INVESTOR_CNTRCT_OBLIGATION_PAY',
                                                                        'INVESTOR_DISB_ADJUSTMENT')   AND inv_disb_rec.deal_type IN ('LEASEDF','LEASEOP','LEASEST') THEN
               l_parent_sty_subclass := 'RENT';
             ELSIF inv_disb_rec.Stream_purpose IN  ('INVESTOR_CNTRCT_OBLIGATION_PAY',
                                                                        'INVESTOR_DISB_ADJUSTMENT')   AND inv_disb_rec.deal_type = 'LOAN' THEN
               l_parent_sty_subclass := 'LOAN_PAYMENT';
             ELSIF inv_disb_rec.Stream_purpose IN ('INVESTOR_PRINCIPAL_BUYBACK',
                                                                        'INVESTOR_INTEREST_BUYBACK',
                                                                        'INVESTOR_PAYDOWN_BUYBACK',
                                                                        'INVESTOR_PRINCIPAL_DISB_BASIS',
                                                                        'INVESTOR_INTEREST_DISB_BASIS',
                                                                        'INVESTOR_PPD_DISB_BASIS')
            THEN
               l_parent_sty_subclass := 'LOAN_PAYMENT';
            ELSIF inv_disb_rec.Stream_purpose IN ('INVESTOR_RESIDUAL_DISB_BASIS',
                                                  'INVESTOR_RESIDUAL_BUYBACK',
                                                  'INVESTOR_EVERGREEN_RENT_PAY',
                                                  --pgomes fix for bug 4430377
                                                  'INVESTOR_RESIDUAL_PAY')
            THEN
               l_parent_sty_subclass := 'RESIDUAL';
            ELSIF inv_disb_rec.Stream_purpose = 'INVESTOR_LATE_FEE_PAYABLE' THEN
               l_parent_sty_subclass := 'LATE_CHARGE';
            ELSIF inv_disb_rec.Stream_purpose = 'INVESTOR_LATE_INTEREST_PAY' THEN
               l_parent_sty_subclass := 'LATE_INTEREST';
            END IF;

            l_percent_stake := NULL;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 22 ### ');
            OPEN  get_parent_stake ( share_rec.TOP_LINE_ID
                                   ,l_parent_sty_subclass );
            FETCH get_parent_stake INTO l_percent_stake;
            CLOSE get_parent_stake;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 23 ### ');

            IF l_percent_stake IS NULL THEN
                l_percent_stake := 0;
            END IF;

            ----------------------------------------------------
            -- Process Based on Billing Or Receipt
            -- Residual Subclass to be treated as Billing Based
            ----------------------------------------------------
            -- -----------------------------------------
            -- Bug 4040202 - Treat all cases of missing
            -- parent sel_id as a case of billing
            -- -----------------------------------------
            IF ( (NVL( l_payment_event,'BILLING' ) = 'BILLING') OR
                 (inv_disb_rec.subclass = 'RESIDUAL') OR
                 (inv_disb_rec.ref_sel_id IS NULL)
               ) THEN
                ----------------------------------------------------
                -- Billing Based disbursement
                ----------------------------------------------------

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 24 ### ');
                IF ( NVL(share_rec.PAY_INVESTOR_EVENT,'SCHEDULE' ) = 'SCHEDULE' ) THEN
                  -- sechawla 26-jun-09 8459929 - Investor Contract Oblg and and Inv Disb Adjustment to be on same date as AR contract
                  -- Oblg invoice : begin
                  -- Note here that for Inv Contract Obl and Inv Disb Adj streams
                  -- ref_sel_id will be NULL and hence payout event does not matter.
                  IF inv_disb_rec.Stream_purpose IN ('INVESTOR_CNTRCT_OBLIGATION_PAY','INVESTOR_DISB_ADJUSTMENT') THEN
                     l_payout_date := inv_disb_rec.bill_date;
                  ELSE -- sechawla 26-jun-09 8459929 : end
				  --

                    l_payout_date :=  get_next_pymt_date (
                                share_rec.DATE_PAY_INVESTOR_START,
                                share_rec.PAY_INVESTOR_FREQUENCY,
                                inv_disb_rec.bill_date );
                  END IF; -- sechawla 26-jun-09 8459929

                ELSE
                    l_payout_date := trunc(SYSDATE) + share_rec.pay_investor_remittance_days;
                END IF;


                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Payout Date: '||l_payout_date);
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Percent Stake: '||l_percent_stake);

                -- *********************************************** --
                -- Insert into TAP TPL
                -- *********************************************** --

                 -- Null Out record definitions
                i_tapv_rec := l_init_tapv_rec;
                r_tapv_rec := l_init_tapv_rec;

                i_tplv_rec := l_init_tplv_rec;
                r_tplv_rec := l_init_tplv_rec;

                /* ankushar 12-JAN-2007
                  Null out table definitions
                  start changes */
                i_tplv_tbl := l_init_tplv_tbl;
                r_tplv_tbl := l_init_tplv_tbl;
                /* ankushar end changes */

                -- Increment Commit counter
                l_commit_cnt := l_commit_cnt + 1;

                -- Reset Error Message
                l_error_message := NULL;

                -- Get Next sequence
                l_invoice_number := NULL;

                -- Create Investor Disbursement Header
                i_tapv_rec.org_id                 := l_org_id;
                i_tapv_rec.set_of_books_id        := l_sob_id;
                i_tapv_rec.invoice_number         := l_invoice_number;
                i_tapv_rec.vendor_invoice_number  := l_invoice_number;
                i_tapv_rec.try_id                 := l_try_id;
                i_tapv_rec.invoice_type           := 'STANDARD';

	            i_tapv_rec.vendor_id		      :=  l_investor_id;
	            i_tapv_rec.ipvs_id			      :=  l_investor_site_id;
	            i_tapv_rec.khr_id			      :=  inv_lease_k_rec.Investor_Agreement_id;
	            i_tapv_rec.currency_code	      :=  l_currency_code;
	            i_tapv_rec.CURRENCY_CONVERSION_TYPE := l_currency_conv_type;
	            i_tapv_rec.CURRENCY_CONVERSION_RATE := l_currency_conv_rate;
	            i_tapv_rec.CURRENCY_CONVERSION_DATE := l_currency_conv_date;

	            i_tapv_rec.payment_method_code	  :=  l_pay_method;
	            i_tapv_rec.date_entered	          :=  l_payout_date;
	            i_tapv_rec.date_invoiced	      :=  l_payout_date;
	            i_tapv_rec.invoice_category_code  :=  NULL;
	            i_tapv_rec.ippt_id			      :=  l_pay_terms;
	            i_tapv_rec.DATE_GL                :=  l_payout_date;
	            i_tapv_rec.Pay_Group_lookup_code  :=  l_pay_group_code;
	            i_tapv_rec.trx_status_code	      :=  'ENTERED';--'PROCESSED'; --cklee 5/24/07
	            i_tapv_rec.nettable_yn		      :=  'N';
 -- 02-NOV-2006 ANSETHUR  R12B - Legal Entity
            i_tapv_rec.legal_entity_id     :=  inv_lease_k_rec.legal_entity_id;
                --------------------------------------------------------------
                -- Work out the amount
                --------------------------------------------------------------
                i_tapv_rec.amount  := (inv_disb_rec.amount*l_percent_stake/100 );

                i_tapv_rec.amount := okl_accounting_util.cross_currency_round_amount
                           (p_amount => i_tapv_rec.amount
                           ,p_currency_code => inv_disb_rec.currency_code);

                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Amount Payable: '||i_tapv_rec.amount);

                -- Create Investor Disbursement Lines
		        i_tplv_rec.tap_id		:=  r_tapv_rec.id;
		        i_tplv_rec.amount		:=  i_tapv_rec.amount;
                -- Start Bug 4648410
		        i_tplv_rec.sty_id		:=  l_sty_id; --inv_disb_rec.sty_id;
                -- End Bug 4648410
		        i_tplv_rec.inv_distr_line_code	:=  'INVESTOR';
		        i_tplv_rec.line_number	:=  1;
		        i_tplv_rec.org_id		:=  l_org_id;
		        i_tplv_rec.disbursement_basis_code := 'BILL_DATE';

                i_tplv_rec.sel_id       :=  inv_disb_rec.sel_id;
                --inv_disb_rec.pay_investor_event;
--start:|           09-Mar-2007  cklee      Change khr_id from header to line        |
	            i_tplv_rec.khr_id      :=  inv_lease_k_rec.Investor_Agreement_id;
--end:|           09-Mar-2007  cklee      Change khr_id from header to line        |


                /* ankushar 17-JAN-2007
                   Call to the common Disbursement API
                   start changes */

                -- Add tpl_rec to table
                 i_tplv_tbl(1) := i_tplv_rec;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 25 ### ');
                --Call the commong disbursement API to create transactions
                Okl_Create_Disb_Trans_Pvt.create_disb_trx(
                     p_api_version      =>   p_api_version
                    ,p_init_msg_list    =>   p_init_msg_list
                    ,x_return_status    =>   x_return_status
                    ,x_msg_count        =>   x_msg_count
                    ,x_msg_data         =>   x_msg_data
                    ,p_tapv_rec         =>   i_tapv_rec
                    ,p_tplv_tbl         =>   i_tplv_tbl
                    ,x_tapv_rec         =>   r_tapv_rec
                    ,x_tplv_tbl         =>   r_tplv_tbl);

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 26 ### ');
                 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    l_error_status  := 'E';
                    l_error_message := l_error_message||'Error creating Investor Disbursement Transactions. ';
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Error creating Investor Disbursement Transactions.');
                 ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    l_error_status  := 'E';
                    l_error_message := l_error_message||'Error creating Investor Disbursement Transactions ';
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Error creating Investor Disbursement Transactions.');
                 ELSIF (x_return_status = 'S') THEN
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Created Investor Disbursement Transactions.');
                 ELSE
                    NULL;
                 END IF;

                /*ankushar end changes */

                -- *********************************************** --
                --  Build an error Table
                -- *********************************************** --
--start:|           09-Mar-2007  cklee      Change khr_id from header to line        |

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 26.1 ### ');
                IF 	l_error_status = 'E' THEN
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 26.2 ### ');
                    l_tld_tab_index := l_tld_tab_index + 1;

                    tld_error_log_table(l_tld_tab_index).tap_id
                            := r_tapv_rec.id;
                    tld_error_log_table(l_tld_tab_index).tpl_id
                            := r_tplv_rec.id;
                    tld_error_log_table(l_tld_tab_index).error_message
                            := l_error_message;
                ELSE
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 26.3 ### ');
                    l_succ_tab_index := l_succ_tab_index + 1;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 26.3.1 ### ' || to_char(r_tapv_rec.id));

                    tld_succ_log_table( l_succ_tab_index ).tap_id
                            := r_tapv_rec.id;
                    tld_succ_log_table( l_succ_tab_index ).tpl_id
                            := r_tplv_rec.id;
                    tld_succ_log_table( l_succ_tab_index ).proc_sel_id
                            := inv_disb_rec.sel_id;
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 26.4 ### ');

                END IF;
--end:|           09-Mar-2007  cklee      Change khr_id from header to line        |

            ELSE -- If the basis is receipt

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 27 ### ');
             --dbms_output.PUT_LINE ('        Receipt Based Processing ');
--start:|           09-Mar-2007  cklee      Change khr_id from header to line        |
                l_ref_tld_id := NULL;
--end:|           09-Mar-2007  cklee      Change khr_id from header to line        |

--start:|           09-Mar-2007  cklee      Change khr_id from header to line        |
               --ssiruvol Bug 5000886 start
        OPEN  get_ref_tld_id ( inv_disb_rec.ref_sel_id  );
        FETCH get_ref_tld_id INTO l_ref_tld_id;
        CLOSE get_ref_tld_id;
                --ssiruvol Bug 5000886 end
--end:|           09-Mar-2007  cklee      Change khr_id from header to line        |

                 ----------------------------------------------------
                -- Receipt Based disbursement
                ----------------------------------------------------
                l_rcpt_cnt := 0;
--start:|           09-Mar-2007  cklee      Change khr_id from header to line        |
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 28 ### ');
                FOR rcpts_rec IN rcpts_csr (l_ref_tld_id,
--end:|           09-Mar-2007  cklee      Change khr_id from header to line        |
                                            inv_lease_k_rec.Investor_Agreement_id,
                                            share_rec.TOP_LINE_ID
                                             ) LOOP

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 29 ### ');
                    l_rcpt_cnt := l_rcpt_cnt + 1;



                    l_payout_date := NULL;

                    IF ( NVL(share_rec.PAY_INVESTOR_EVENT,'SCHEDULE' ) = 'SCHEDULE' ) THEN
                      -- sechawla 26-Jun-09 8459929 - Investor Contract Oblg to be on same date as AR contract
                       -- Oblg invoice : begin
                       IF inv_disb_rec.Stream_purpose = 'INVESTOR_CNTRCT_OBLIGATION_PAY' THEN
                         l_payout_date := inv_disb_rec.bill_date;
                       ELSE -- sechawla 26-Jun-09 8459929 : end

                        l_payout_date :=  get_next_pymt_date (
                                share_rec.DATE_PAY_INVESTOR_START,
                                share_rec.PAY_INVESTOR_FREQUENCY,
                                rcpts_rec.apply_date );
                       END IF; -- sechawla 26-Jun-09 8459929
                    ELSE
                        -------------------------------------------------------
                        -- Should this be apply date instead of sysdate
                        -- Check with PM
                        -------------------------------------------------------
                        l_payout_date := trunc(SYSDATE) + share_rec.pay_investor_remittance_days;
                    END IF;

                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Payout Date: '||l_payout_date);
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Percent Stake: '||l_percent_stake);

                    --dbms_output.PUT_LINE ('        Payout Date: '||l_payout_date);
                    --dbms_output.PUT_LINE ('        Percent Stake: '||l_percent_stake);


                    -- *********************************************** --
                    -- Insert into TAP TPL
                    -- *********************************************** --

                    -- Null Out record definitions
                    i_tapv_rec := l_init_tapv_rec;
                    r_tapv_rec := l_init_tapv_rec;

                    i_tplv_rec := l_init_tplv_rec;
                    r_tplv_rec := l_init_tplv_rec;

                    /* ankushar 17-JAN-2007
                       Null out table definitions
                       start changes */
                    i_tplv_tbl := l_init_tplv_tbl;
                    r_tplv_tbl := l_init_tplv_tbl;
                    /* ankushar end changes */

                    -- Increment Commit counter
                    l_commit_cnt := l_commit_cnt + 1;

                    -- Reset Error Message
                    l_error_message := NULL;

                    -- Get Next sequence
                    l_invoice_number := NULL;

                    -- Create Investor Disbursement Header
                    i_tapv_rec.org_id                 := l_org_id;
                    i_tapv_rec.set_of_books_id        := l_sob_id;
                    i_tapv_rec.invoice_number         := l_invoice_number;
                    i_tapv_rec.vendor_invoice_number  := l_invoice_number;
                    i_tapv_rec.try_id                 := l_try_id;
                    i_tapv_rec.invoice_type           := 'STANDARD';

	                i_tapv_rec.vendor_id		      :=  l_investor_id;
	                i_tapv_rec.ipvs_id			      :=  l_investor_site_id;
	                i_tapv_rec.khr_id			      :=  inv_lease_k_rec.Investor_Agreement_id;
	                i_tapv_rec.currency_code	      :=  l_currency_code;
	                i_tapv_rec.CURRENCY_CONVERSION_TYPE := l_currency_conv_type;
	                i_tapv_rec.CURRENCY_CONVERSION_RATE := l_currency_conv_rate;
	                i_tapv_rec.CURRENCY_CONVERSION_DATE := l_currency_conv_date;

	                i_tapv_rec.payment_method_code	  :=  l_pay_method;
	                i_tapv_rec.date_entered	          :=  l_payout_date;
	                i_tapv_rec.date_invoiced	      :=  l_payout_date;
	                i_tapv_rec.invoice_category_code  :=  NULL;
	                i_tapv_rec.ippt_id			      :=  l_pay_terms;
	                i_tapv_rec.DATE_GL                :=  l_payout_date;
	                i_tapv_rec.Pay_Group_lookup_code  :=  l_pay_group_code;
     	            i_tapv_rec.trx_status_code	      :=  'ENTERED';--'PROCESSED'; --cklee 5/24/07
	                i_tapv_rec.nettable_yn		      :=  'N';
 -- 02-NOV-2006 ANSETHUR  R12B - Legal Entity
                 i_tapv_rec.legal_entity_id     :=  inv_lease_k_rec.legal_entity_id;
                    -----------------------------------------------------------
                    -- Work out the amount
                    -----------------------------------------------------------
                    i_tapv_rec.amount
                    := (inv_disb_rec.amount*rcpts_rec.AMOUNT_APPLIED/rcpts_rec.amount)*(l_percent_stake/100 );

                    i_tapv_rec.amount := okl_accounting_util.cross_currency_round_amount
                           (p_amount => i_tapv_rec.amount
                           ,p_currency_code => inv_disb_rec.currency_code);

                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Amount Payable: '||i_tapv_rec.amount);

                    --dbms_output.PUT_LINE ('        Amount Payable: '||i_tapv_rec.amount);

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 30 ### ');
                    -- Create Investor Disbursement Lines
		            i_tplv_rec.tap_id		:=  r_tapv_rec.id;
		            i_tplv_rec.amount		:=  i_tapv_rec.amount;
		            i_tplv_rec.sty_id		:=  l_sty_id; --inv_disb_rec.sty_id;
		            i_tplv_rec.inv_distr_line_code	:=  'INVESTOR';
		            i_tplv_rec.line_number	:=  1;
		            i_tplv_rec.org_id		:=  l_org_id;
		            i_tplv_rec.disbursement_basis_code := 'CASH_RECEIPT';
                    i_tplv_rec.sel_id       :=  inv_disb_rec.sel_id;
--start:|           09-Mar-2007  cklee      Change khr_id from header to line        |
	            i_tplv_rec.khr_id      :=  inv_lease_k_rec.Investor_Agreement_id;
--end:|           09-Mar-2007  cklee      Change khr_id from header to line        |
                --inv_disb_rec.pay_investor_event;

                /* ankushar 17-JAN-2007
                   Call the common Disbursement API for creating disbursemant transactions
                   start changes */

                -- Add tpl_rec to table
                 i_tplv_tbl(1) := i_tplv_rec;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 31 ### ');
                --Call the commong disbursement API to create transactions
                Okl_Create_Disb_Trans_Pvt.create_disb_trx(
                     p_api_version      =>   p_api_version
                    ,p_init_msg_list    =>   p_init_msg_list
                    ,x_return_status    =>   x_return_status
                    ,x_msg_count        =>   x_msg_count
                    ,x_msg_data         =>   x_msg_data
                    ,p_tapv_rec         =>   i_tapv_rec
                    ,p_tplv_tbl         =>   i_tplv_tbl
                    ,x_tapv_rec         =>   r_tapv_rec
                    ,x_tplv_tbl         =>   r_tplv_tbl);

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 32 ### ');
                 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    l_error_status  := 'E';
                    l_error_message := l_error_message||'Error creating Investor Disbursement Transactions. ';
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Error creating Investor Disbursement Transactions.');
                 ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    l_error_status  := 'E';
                    l_error_message := l_error_message||'Error creating Investor Disbursement Transactions ';
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Error creating Investor Disbursement Transactions.');
                 ELSIF (x_return_status = 'S') THEN
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        Created Investor Disbursement Transactions.');
                 ELSE
                    NULL;
                 END IF;
                /* ankushar end changes */

                    -- *********************************************** --
                    --  Build an error Table
                    -- *********************************************** --
--start:|           09-Mar-2007  cklee      Change khr_id from header to line        |

                   IF 	l_error_status = 'E' THEN
                        l_tld_tab_index := l_tld_tab_index + 1;
                        tld_error_log_table(l_tld_tab_index).tap_id
                             := r_tapv_rec.id;
                        --tld_error_log_table(l_tld_tab_index).tpl_id
                        --     := r_tplv_rec.id;
                        tld_error_log_table(l_tld_tab_index).error_message
                             := l_error_message;
                    ELSE
                        l_succ_tab_index := l_succ_tab_index + 1;

                        tld_succ_log_table( l_succ_tab_index ).tap_id
                                := r_tapv_rec.id;
                        tld_succ_log_table( l_succ_tab_index ).tpl_id
                                := r_tplv_rec.id;
                        tld_succ_log_table( l_succ_tab_index ).proc_sel_id
                                := inv_disb_rec.sel_id;
                    END IF;
--end:|           09-Mar-2007  cklee      Change khr_id from header to line        |

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 33 ### ');

                    IF l_error_status = 'S' THEN
                        ------------------------------
                        -- Populate PK from sequence
                        ------------------------------
                        l_idh_id := NULL;
                        l_idh_id := get_seq_id;
                        INSERT INTO okl_investor_payout_summary_b
                        (   ID,
                            OBJECT_VERSION_NUMBER,
                            CREATED_BY,
                            CREATION_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATE_LOGIN,
                            INVESTOR_AGREEMENT_ID,
                            INVESTOR_LINE_ID,
                            TLD_ID,
                            RECEIVABLE_APPLICATION_ID,
                            ORG_ID
                        )
                        VALUES
                        (
                            l_idh_id,
                            1,
                            Fnd_Global.USER_ID,
                            SYSDATE,
                            Fnd_Global.USER_ID,
                            SYSDATE,
                            Fnd_Global.LOGIN_ID,
                            inv_lease_k_rec.Investor_Agreement_id,
                            share_rec.TOP_LINE_ID,
                            rcpts_rec.tld_id,
                            rcpts_rec.receivable_application_id,
                            l_org_id
                        );


                    END IF;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 34 ### ');
                END LOOP; -- For each receipt undisbursed

                -- --------------------------------
                -- Check If receipts processed
                -- --------------------------------
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 35 ### ');
                IF l_rcpt_cnt <= 0 THEN
                   FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        **** No Receipts to Process ***');
                END IF;

            END IF;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 36 ### ');
       END LOOP; -- Determine Investor Share

--dbms_output.put_line(' HERE 007: NEVER BEEN HERE ');


       -----------------------------------------------------
       -- Error Processing
       -----------------------------------------------------
       -- if ret_status = error then
       --    flag created txns in TAP and XPI as error
       -- else
       --    if event is Billing then
       --       update sel date billed with sysdate
       --       update lsm inv disb status to processed
       --    else
       --       if invoice has been paid in full
       --          update sel date billed with sysdate
       --          update lsm inv disb status to processed
       --       else
       --          update lsm inv disb status to partial
       -----------------------------------------------------

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 37 ### ');
        IF 	l_error_status = 'E' THEN
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 38 ### ');
--dbms_output.put_line(' HERE 99: '||SQLERRM);
--start:|           09-Mar-2007  cklee      Change khr_id from header to line        |
--            IF lsm_error_log_table.COUNT > 0 THEN
            IF tld_error_log_table.COUNT > 0 THEN
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 39 ### ');
--            FOR i IN lsm_error_log_table.FIRST..lsm_error_log_table.LAST LOOP
            FOR i IN tld_error_log_table.FIRST..tld_error_log_table.LAST LOOP
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 40 ### ');
                     UPDATE okl_trx_ap_invoices_b
                     SET trx_status_code = 'ERROR'
                     WHERE Id = tld_error_log_table(i).tap_id;

            END LOOP;
--end:|           09-Mar-2007  cklee      Change khr_id from header to line        |
            -----------------------------------------------------------------
            -- Reset Error Table and counter
            -----------------------------------------------------------------
--start:|           09-Mar-2007  cklee      Change khr_id from header to line        |
            tld_error_log_table := l_init_tld_table;
            l_tld_tab_index     := 0;
--end:|           09-Mar-2007  cklee      Change khr_id from header to line        |

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 41 ### ');
            END IF;
--dbms_output.put_line(' HERE 991: '||SQLERRM);
        ELSE
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 42 ### ');
--dbms_output.put_line(' HERE 100: '||SQLERRM||lsm_succ_log_table.COUNT);
--start:|           09-Mar-2007  cklee      Change khr_id from header to line        |
            IF tld_succ_log_table.COUNT > 0 THEN
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 43 ### ');
            FOR i IN tld_succ_log_table.FIRST..tld_succ_log_table.LAST LOOP
--end:|           09-Mar-2007  cklee      Change khr_id from header to line        |
            IF ( NVL( l_payment_event,'BILLING' ) = 'BILLING' ) OR
            --pgomes fix for bug 4430377
                 (inv_disb_rec.subclass = 'RESIDUAL') OR
                 (inv_disb_rec.ref_sel_id IS NULL) THEN

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 43.1 ### ');
		--ssiruvol Bug 5000886 start
                 UPDATE okl_strm_elements
                 SET date_billed = SYSDATE
                 WHERE id = tld_succ_log_table(i).proc_sel_id;

                 UPDATE OKL_TXD_AR_LN_DTLS_B
                 SET investor_disb_status = 'PROCESSED'
                 WHERE sel_id = inv_disb_rec.ref_sel_id;

		 l_strm_ele_id_tbl(strm_ele_idx):=tld_succ_log_table(i).proc_sel_id;
                  l_inv_ele_id_tbl(inv_ele_idx) :=inv_disb_rec.ref_sel_id;
                  strm_ele_idx:=strm_ele_idx+1;
                  inv_ele_idx:=inv_ele_idx+1;
		  --ssiruvol Bug 5000886 end;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 43.2 ### ');
            ELSE
		 --ssiruvol Bug 5000886 start
		 -- IF (check_rcpts( inv_disb_rec.ref_sel_id ) = 'FULL') THEN
                 IF (check_rcpts( inv_disb_rec.cnsld_id ) = 'FULL') THEN
	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 43.3 ### ');

                     UPDATE okl_strm_elements
                     SET date_billed = SYSDATE
                     WHERE id = tld_succ_log_table(i).proc_sel_id;

                     UPDATE OKL_TXD_AR_LN_DTLS_B
                     SET investor_disb_status = 'PROCESSED'
                     WHERE sel_id = inv_disb_rec.ref_sel_id;

		     l_strm_ele_id_tbl(strm_ele_idx):=tld_succ_log_table(i).proc_sel_id;
                      l_inv_ele_id_tbl(inv_ele_idx) :=inv_disb_rec.ref_sel_id;
                      strm_ele_idx:=strm_ele_idx+1;
                      inv_ele_idx:=inv_ele_idx+1;

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 43.4 ### ');
                 --ELSIF (check_rcpts( inv_disb_rec.ref_sel_id ) = 'PARTIAL') THEN
                 ELSIF (check_rcpts( inv_disb_rec.cnsld_id ) = 'PARTIAL') THEN

	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ### 43.5 ### ');

		     l_inv_prtl_id_tbl(inv_ele_prtl_idx) := inv_disb_rec.ref_sel_id;
                     inv_ele_prtl_idx := inv_ele_prtl_idx + 1;
                     --ssiruvol Bug 5000886 end


                 ELSE
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '** WARNING: Unhandled Condition');
                    --dbms_output.put_line('** WARNING: Unhandled Condition');
                 END IF;

            END IF;
            END LOOP; -- Loop thru success table

--start:|           09-Mar-2007  cklee      Change khr_id from header to line        |
--           lsm_succ_log_table 	:= l_init_succ_table;
            tld_succ_log_table 	:= l_init_succ_table;
--end:|           09-Mar-2007  cklee      Change khr_id from header to line        |
            l_succ_tab_index    := 0;

            END IF;
--dbms_output.put_line(' HERE 1001: '||SQLERRM);
       END IF;  -- Check error status Code

       END IF;  -- Check if Billed

       IF l_commit_cnt > l_MAX_commit_cnt THEN
	 --ssiruvol Bug 5000886 start
	 IF l_strm_ele_id_tbl.COUNT > 0 THEN
		FORALL indx in l_strm_ele_id_tbl.FIRST .. l_strm_ele_id_tbl.LAST
		UPDATE okl_strm_elements
		SET date_billed = SYSDATE--l_date_billed_tbl(indx);
		 WHERE id = l_strm_ele_id_tbl(indx);
		l_strm_ele_id_tbl:=l_temp_ele_id_tbl;
		strm_ele_idx:=1;
	 END IF;

	  IF l_inv_ele_id_tbl.COUNT > 0 THEN
		 FORALL indx in l_inv_ele_id_tbl.FIRST .. l_inv_ele_id_tbl.LAST
		 UPDATE OKL_TXD_AR_LN_DTLS_B
		 SET investor_disb_status = 'PROCESSED'
		 WHERE sel_id = l_inv_ele_id_tbl(indx)
		 and khr_id =inv_lease_k_rec.khr_id;
		l_inv_ele_id_tbl:=l_temp_ele_id_tbl;
		 inv_ele_idx:=1;
	 END IF;

        IF l_inv_prtl_id_tbl.COUNT > 0 THEN
		 FORALL indx in l_inv_prtl_id_tbl.FIRST .. l_inv_prtl_id_tbl.LAST
                 UPDATE OKL_TXD_AR_LN_DTLS_B
                 SET investor_disb_status = 'PARTIAL'
                 WHERE sel_id = l_inv_prtl_id_tbl(indx)
                 and khr_id =inv_lease_k_rec.khr_id;
               l_inv_prtl_id_tbl := l_temp_ele_id_tbl;
               inv_ele_prtl_idx := 1;
       END IF;
      --ssiruvol Bug 5000886 end
         l_commit_cnt := 0;
         COMMIT;
       END IF;

    END LOOP; -- Pick Up Disbursable stream elements

    --ssiruvol Bug 5000886 start
    IF l_strm_ele_id_tbl.COUNT > 0 THEN
        FORALL indx in l_strm_ele_id_tbl.FIRST .. l_strm_ele_id_tbl.LAST
        UPDATE okl_strm_elements
           SET date_billed = SYSDATE
            WHERE id = l_strm_ele_id_tbl(indx);
            l_strm_ele_id_tbl:=l_temp_ele_id_tbl;
            strm_ele_idx:=1;
      END IF;

     IF l_inv_ele_id_tbl.COUNT > 0 THEN
        FORALL indx in l_inv_ele_id_tbl.FIRST .. l_inv_ele_id_tbl.LAST
             UPDATE OKL_TXD_AR_LN_DTLS_B
              SET investor_disb_status = 'PROCESSED'
              WHERE sel_id = l_inv_ele_id_tbl(indx)
              and khr_id = inv_lease_k_rec.khr_id;
            l_inv_ele_id_tbl:=l_temp_ele_id_tbl;
            inv_ele_idx:=1;
     END IF;

    IF l_inv_prtl_id_tbl.COUNT > 0 THEN
        FORALL indx in l_inv_prtl_id_tbl.FIRST .. l_inv_prtl_id_tbl.LAST
                UPDATE OKL_TXD_AR_LN_DTLS_B
                SET investor_disb_status = 'PARTIAL'
                WHERE sel_id = l_inv_prtl_id_tbl(indx)
                and khr_id =inv_lease_k_rec.khr_id;
              l_inv_prtl_id_tbl := l_temp_ele_id_tbl;
              inv_ele_prtl_idx := 1;
     END IF;
     --ssiruvol Bug 5000886 end

    END LOOP; -- Pick up LK for an INvestor agreement

    -- gboomina added for Bug 6788005 - Start
    -----------------------------------------------------------------
    -- Create disbursement for fees defined in the Investor Agreement
    -----------------------------------------------------------------
    okl_investor_fee_disb( p_api_version        => p_api_version,
                           p_init_msg_list      => p_init_msg_list,
                           x_return_status      => l_return_status,
                           x_msg_count          => x_msg_count,
                           x_msg_data           => x_msg_data,
                           p_investor_agreement => p_investor_agreement,
                           p_to_date            => p_to_date);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- gboomina added for Bug 6788005 - End

    ------------------------------------------------------------
    -- End processing
    ------------------------------------------------------------

    Okl_Api.END_ACTIVITY (
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data);



FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '=====*** EXITING PROCEDURE OKL_INVESTOR_DISBURSEMENT ***=====');

--dbms_output.put_line('=====*** EXITING PROCEDURE OKL_INVESTOR_DISBURSEMENT ***=====');
EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN OKL_API.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,' ERROR 1: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,' ERROR 2: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,' ERROR 3: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');


END OKL_INVESTOR_DISBURSEMENT;


END okl_investor_invoice_disb_pvt;

/
