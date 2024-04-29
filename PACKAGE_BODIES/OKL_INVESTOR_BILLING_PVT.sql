--------------------------------------------------------
--  DDL for Package Body OKL_INVESTOR_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INVESTOR_BILLING_PVT" AS
/* $Header: OKLRBCAB.pls 120.17 2007/12/26 10:05:15 kthiruva noship $ */


  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
  END get_seq_id;


  ------------------------------------------------------------------
  -- Procedure create_billing_transaction to bill investor
  -- transactions
  ------------------------------------------------------------------
PROCEDURE create_investor_bill
	(p_api_version		  IN  NUMBER
	,p_init_msg_list	  IN  VARCHAR2
	,x_return_status	  OUT NOCOPY VARCHAR2
	,x_msg_count		  OUT NOCOPY NUMBER
	,x_msg_data		  OUT NOCOPY VARCHAR2
	,p_inv_agr                IN  NUMBER
        ,p_investor_line_id       IN  NUMBER
       )
IS



	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------
	l_api_version	CONSTANT NUMBER := 1;
	l_api_name	    CONSTANT VARCHAR2(30)  := 'create_investor_bill';
	l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

        --   nikshah -- Bug # 5484903 Fixed,
        --   Changed bill_invstr_csr ( p_inv_agr NUMBER ) SQL definition
	------------------------------------------------------------
	-- Get Investors and Investment amount to bill
	------------------------------------------------------------
    CURSOR bill_invstr_csr ( p_inv_agr NUMBER ) IS
         SELECT  KH1.contract_number Investor_Agreement,
                KH1.id              Investor_Agreement_id,
                KH1.pdt_id          pdt_id,
                KH1.currency_code,
                KH1.currency_conversion_type,
                KH1.currency_conversion_rate,
                KH1.currency_conversion_date,
                KH1.authoring_org_id org_id,
                PARTY.name          Investor_Name,
                PARTY.description   Investor_Description,
                --PARTY.id1           Investor_Id,
                TOP_LINE.cust_acct_id Investor_Id,
                PARTY.id2           Investor_Id2,
                TOP_LINE.ID         TOP_LINE_ID,
                TOP_KLE.AMOUNT,
                TOP_LINE.START_DATE,
                nvl(TOP_KLE.AMOUNT_STAKE,0) AMOUNT_STAKE
        FROM
             OKL_K_HEADERS_FULL_V KH1,
             OKC_K_LINES_B        TOP_LINE,
             OKL_K_LINES          TOP_KLE,
             OKC_K_PARTY_ROLES_B  PARTY_ROLE,
             OKX_PARTIES_V        PARTY,
             OKC_LINE_STYLES_B    LSEB,
             OKC_STATUSES_V       STS
        WHERE
             KH1.SCS_CODE              = 'INVESTOR'      AND
--             KH1.STS_CODE              = 'ACTIVE'        AND
             KH1.id                    = p_inv_agr       AND
             TOP_LINE.dnz_chr_id       = KH1.id          AND
--             TOP_LINE.CLE_ID           IS NULL           AND
--             TOP_LINE.STS_CODE         = 'ACTIVE'        AND
             TOP_KLE.ID                = NVL(p_investor_line_id,TOP_KLE.ID) AND
             TOP_KLE.ID                = TOP_LINE.ID     AND
             PARTY_ROLE.cle_id         = TOP_LINE.id     AND
             PARTY_ROLE.dnz_chr_id     = TOP_LINE.dnz_chr_id AND
             PARTY_ROLE.rle_code       = 'INVESTOR'      AND
             PARTY_ROLE.jtot_object1_code = 'OKX_PARTY'  AND
             PARTY.id1                 = PARTY_ROLE.object1_id1 AND
             PARTY.id2                 = PARTY_ROLE.object1_id2 AND
             LSEB.ID                   = TOP_LINE.lse_id AND
             LSEB.lty_code             = 'INVESTMENT'    AND
             STS.CODE                  = TOP_LINE.sts_code;

	------------------------------------------------------------
	-- Get Investor bill to Site
	------------------------------------------------------------
    --COMMENTED OUT FOR RULES MIGRATION
    /*CURSOR bill_site_rul_csr( p_invstr_agr_id NUMBER, p_top_line_id NUMBER ) IS
        SELECT object1_id1
        FROM  OKC_RULES_B       rul,
              Okc_rule_groups_B rgp
        WHERE   rul.rgp_id     = rgp.id               AND
                rgp.rgd_code   = 'LABILL'             AND
                rgp.cle_id     = p_top_line_id        AND
                rul.rule_information_category = 'BTO' AND
                rgp.dnz_chr_id = p_invstr_agr_id;*/

    --ADDED FOR RULES MIGRATION
    CURSOR bill_site_rul_csr( p_invstr_agr_id NUMBER, p_top_line_id NUMBER ) IS
        SELECT B.cust_acct_site_id
        FROM  okc_k_lines_b A
             ,okx_cust_site_uses_v B
        WHERE /*A.chr_id = p_invstr_agr_id
        and A.cle_id     IS NULL
        and*/ A.id = p_top_line_id
        and A.bill_to_site_use_id = B.id1;

    --COMMENTED OUT FOR RULES MIGRATION
    /*CURSOR bill_site_csr(p_id1 NUMBER, p_party_id NUMBER ) IS
        SELECT  cust_acct_site_id
        FROM okx_cust_site_uses_v
        WHERE id1 = p_id1 AND
        PARTY_ID  = p_party_id;*/

  --  nikshah -- Bug # 5484903 Fixed,
  --  Changed CURSOR std_terms_csr SQL definition
	------------------------------------------------------------
	-- Get Term Id
	------------------------------------------------------------
    CURSOR std_terms_csr  IS
        SELECT B.TERM_ID
       FROM RA_TERMS_TL T,  RA_TERMS_B B
      WHERE B.TERM_ID = T.TERM_ID
          and T.LANGUAGE = userenv('LANG')
          and T.name = 'IMMEDIATE';

	------------------------------------------------------------
	-- Get Receipt Method Id
	------------------------------------------------------------
    CURSOR rcpt_mthd_rul_csr( p_invstr_agr_id NUMBER, p_top_line_id NUMBER ) IS
        SELECT  object1_id1
        FROM OKC_RULES_B       rul,
             Okc_rule_groups_B rgp
        WHERE rul.rgp_id     = rgp.id                  AND
              rgp.rgd_code   = 'LABILL'                AND
              rul.rule_information_category = 'LAPMTH' AND
              rgp.cle_id     = p_top_line_id        AND
              rgp.dnz_chr_id = p_invstr_agr_id;

    CURSOR rcpt_mthd_csr (p_id1 NUMBER, p_cust_id NUMBER) IS
        SELECT receipt_method_id
        FROM okx_receipt_methods_v
        WHERE id1 = p_id1 AND
              customer_id = p_cust_id;

   CURSOR pass_or_not_csr ( p_rct_method_id  NUMBER) IS
	   SELECT C.CREATION_METHOD_CODE
	   FROM  AR_RECEIPT_METHODS M,
       		 AR_RECEIPT_CLASSES C
	   WHERE  M.RECEIPT_CLASS_ID = C.RECEIPT_CLASS_ID AND
	   		  M.receipt_method_id = p_rct_method_id;

	------------------------------------------------------------
	-- Get Bank Account Id
	------------------------------------------------------------
    CURSOR bank_acct_rul_csr( p_invstr_agr_id NUMBER, p_top_line_id NUMBER ) IS
        SELECT object1_id1
        FROM OKC_RULES_B       rul,
             Okc_rule_groups_B rgp
        WHERE rul.rgp_id     = rgp.id                  AND
              rgp.rgd_code   = 'LABILL'                AND
              rgp.cle_id     = p_top_line_id        AND
              rul.rule_information_category = 'LABACC' AND
              rgp.dnz_chr_id = p_invstr_agr_id;

    CURSOR bank_acct_id_csr( p_id1 NUMBER ) IS
        SELECT bank_account_id
        FROM OKX_RCPT_METHOD_ACCOUNTS_V
        WHERE id1 = p_id1;

	------------------------------------------------------------
	-- Get trx_id
	------------------------------------------------------------
	CURSOR c_trx_id( p_sob_id   NUMBER, p_org_id   NUMBER ) IS
	   SELECT  ID1
	   FROM OKX_CUST_TRX_TYPES_V
	   WHERE name = 'Investor-OKL' 			AND
	   		 set_of_books_id = p_sob_id 	AND
			 org_id			 = p_org_id;

	------------------------------------------------------------
	-- Get trx_type_id
	------------------------------------------------------------
	CURSOR c_trx_type  IS
		SELECT	id
		FROM	okl_trx_types_tl
		WHERE	name	= 'Billing'
		AND	LANGUAGE	= 'US';

	------------------------------------------------------------
	-- Get sty_id
	------------------------------------------------------------
	CURSOR c_sty_id(cp_sty_id IN NUMBER)  IS
        --SELECT id
        SELECT taxable_default_yn
        FROM okl_strm_type_v
        WHERE id = cp_sty_id;

    /* ankushar OKL R12B Billing Changes
       start Code Comment
	------------------------------------------------------------
    -- Create Distributions
	------------------------------------------------------------
    CURSOR dstrs_csr( p_pdt_id NUMBER, p_try_id NUMBER, p_sty_id NUMBER,  p_inv_code VARCHAR2) IS
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
                 A.start_date <= sysdate AND
                 (A.end_date IS NULL OR A.end_date >= sysdate) AND
                 A.memo_yn = 'N' AND
                 -- #4643924 added filter on special accounting code
                 NVL(A.FACTORING_SYND_FLAG,'INVESTOR') = 'INVESTOR' AND
                 NVL(A.INV_CODE, '-9999') = NVL(p_inv_code,'-9999') AND
                 b.id     = p_pdt_id AND
                 a.sty_id = p_sty_id AND
                 a.try_id = p_try_id AND
                 C.avl_id = A.id;
   -- end Code comment
   ankushar Billing Changes */

    -- BEGIN bvaghela 032305 bug 4256274 --
    CURSOR sales_rep_csr IS
           SELECT SALESREP_ID, SALESREP_NUMBER
           FROM   RA_SALESREPS
           WHERE  NAME = 'No Sales Credit';


    CURSOR sales_type_credit_csr IS
           SELECT SALES_CREDIT_TYPE_ID
           FROM   SO_SALES_CREDIT_TYPES
           WHERE  NAME = 'Quota Sales Credit';
    -- END bvaghela 032305 bug 4256274 --

	--Added by kthiruva for Bug 6691554
	CURSOR get_ia_sts_csr(p_khr_id NUMBER)
	IS
	SELECT khr.STS_CODE
	FROM okc_k_headers_all_b khr
	WHERE khr.ID = p_khr_id
	AND khr.SCS_CODE = 'INVESTOR';

/*
  ankushar code commented, to be moved in the common billing API.
        ------------------------------------------------------------
        -- Get special accounting code
        ------------------------------------------------------------
    -- bug#4643924 start cursor to fetch the special accounting code
    CURSOR spl_acct_code_rul_csr( p_invstr_agr_id NUMBER) IS
       select rul.rule_information1 investor_code
       from okc_rule_groups_b rgp, okc_rules_b rul
       where rgp.chr_id = rgp.dnz_chr_id
       and rgp.dnz_chr_id = p_invstr_agr_id
       and rgp.rgd_code = 'LASEAC'
       and rul.dnz_chr_id = rgp.dnz_chr_id
       and rul.rgp_id = rgp.id
       and rul.rule_information_category = 'LASEAC';
 */

	------------------------------------------------------------
	-- Local Variables
	------------------------------------------------------------

    -- BEGIN bvaghela 032305 bug 4256274 --
    l_salesrep_id          ra_salesreps.SALESREP_ID%TYPE;
    l_salesrep_number      ra_salesreps.SALESREP_NUMBER%TYPE;
    l_sales_type_credit    so_sales_credit_types.sales_credit_type_id%TYPE;
    l_user_id              NUMBER       := FND_global.user_id;
    l_sysdate              DATE         := sysdate;
    -- END bvaghela 032305 bug 4256274 --

    l_customer_id           NUMBER;
    l_cust_site_id          NUMBER;
    l_terms                 NUMBER;
    l_receipt_method_id     NUMBER;
    l_how_created           AR_RECEIPT_CLASSES.creation_method_code%TYPE;
    l_bank_acct_id          NUMBER;
    l_cust_trx_id           NUMBER;

    l_unique_id             NUMBER;

    l_site_id1              NUMBER;
    l_rcpt_id1              NUMBER;
    l_bank_id1              NUMBER;

    -- Multi Currency Compliance
    l_currency_code            okl_k_headers_full_v.currency_code%type;
    l_currency_conversion_type okl_k_headers_full_v.currency_conversion_type%type;
    l_currency_conversion_rate okl_k_headers_full_v.currency_conversion_rate%type;
    l_currency_conversion_date okl_k_headers_full_v.currency_conversion_date%type;

 /* ankushar Billing Enhancement changes
    start code changes */
 -----------------------------------------------------------
 -- Variables for billing API call
 -----------------------------------------------------------
    lp_taiv_rec        okl_tai_pvt.taiv_rec_type;
    lp_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lp_tldv_tbl        okl_tld_pvt.tldv_tbl_type;
    lp_tilv_rec	       okl_til_pvt.tilv_rec_type;
    lx_taiv_rec        okl_tai_pvt.taiv_rec_type;
    lx_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lx_tldv_tbl        okl_tld_pvt.tldv_tbl_type;

 /* ankushar : end code changes */

	------------------------------------------------------------
	-- Variables for accounting Engine
	------------------------------------------------------------
    l_template_tbl       OKL_ACCOUNT_DIST_PVT.avlv_tbl_type;
    l_init_template_tbl  OKL_ACCOUNT_DIST_PVT.avlv_tbl_type;
    l_tmpl_id_rec        OKL_ACCOUNT_DIST_PVT.TMPL_IDENTIFY_REC_TYPE;
    l_init_tmpl_id_rec   OKL_ACCOUNT_DIST_PVT.TMPL_IDENTIFY_REC_TYPE;

    l_try_id             okl_trx_types_tl.id%TYPE;
    l_sty_id             okl_strm_type_v.id%TYPE;
    l_taxable_yn         okl_strm_type_v.taxable_default_yn%TYPE;

    l_amount             NUMBER;

    l_distr_cnt          NUMBER;
    l_distr_err          BOOLEAN := FALSE;
    l_cc_id              ra_interface_distributions_all.CODE_COMBINATION_ID%TYPE;

    -------------------------------------------------------------------------
    -- Account Builder Code
    -------------------------------------------------------------------------
  	l_acc_gen_primary_key_tbl  		Okl_Account_Dist_Pub.acc_gen_primary_key;
  	l_init_acc_gen_primary_key_tbl  Okl_Account_Dist_Pub.acc_gen_primary_key;

    l_acc_gen_wf_sources_rec        OKL_ACCOUNT_GENERATOR_pvt.acc_gen_wf_sources_rec;

    l_inv_code                      okc_rules_b.RULE_INFORMATION1%TYPE;

    -------------------------------------------------------------------------
    -- Legal Entity
    -------------------------------------------------------------------------

    l_legal_entity_id               RA_INTERFACE_LINES.LEGAL_ENTITY_ID%TYPE; -- for LE Uptake project 08-11-2006
    --Added by kthiruva for bug 6691554
    l_status_code                   OKC_K_HEADERS_ALL_B.STS_CODE%TYPE;

BEGIN
     ------------------------------------------------------------
     -- Start processing
     ------------------------------------------------------------
     x_return_status := Okl_Api.G_RET_STS_SUCCESS;

     l_return_status := Okl_Api.START_ACTIVITY(
        p_api_name	=> l_api_name,
		p_pkg_name	=> G_PKG_NAME,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	    => '_PVT',
		x_return_status	=> l_return_status);

    -------------------------------------------
    -- Fetch Transaction Type Id
    -------------------------------------------
    OPEN  c_trx_type;
    FETCH c_trx_type INTO l_try_id;
    CLOSE c_trx_type;

    -------------------------------------------
    -- Fetch Stream Type Id
    -------------------------------------------
    OKL_STREAMS_UTIL.get_primary_stream_type(p_khr_id => p_inv_agr
                     ,p_primary_sty_purpose => 'INVESTOR_RECEIVABLE'
                     ,x_return_status => l_return_status
                     ,x_primary_sty_id => l_sty_id);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Obtaining sty id for: INVESTOR_RECEIVABLE.');
 			RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Obtaining sty id for: INVESTOR_RECEIVABLE.');
 			RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    OPEN  c_sty_id(cp_sty_id=>l_sty_id);
    --FETCH c_sty_id INTO l_sty_id;
    FETCH c_sty_id INTO l_taxable_yn;
    CLOSE c_sty_id;

    --Fetch the investor agreement status
    FOR get_ia_sts_rec IN get_ia_sts_csr(p_inv_agr)
    LOOP
       l_status_code := get_ia_sts_rec.sts_code;
    END LOOP;

    FOR invstr_rec IN bill_invstr_csr ( p_inv_agr ) LOOP

        -- Null out variables
        l_customer_id       := NULL;
        l_cust_site_id      := NULL;
        l_terms             := NULL;
        l_receipt_method_id := NULL;
        l_how_created       := NULL;
        l_bank_acct_id      := NULL;
        l_cust_trx_id       := NULL;
        l_site_id1          := NULL;
        l_rcpt_id1          := NULL;
        l_bank_id1          := NULL;
        l_unique_id         := NULL;

        l_currency_code            := NULL;
        l_currency_conversion_type := NULL;
        l_currency_conversion_rate := NULL;
        l_currency_conversion_date := NULL;

        ---------------------------------------------------
        -- populate variables
        ---------------------------------------------------

        -- Customer Id
        l_customer_id       := invstr_rec.investor_id;

        -- Customer Bill to Site
        --COMMENTED OUT FOR RULES MIGRATION
        /*OPEN  bill_site_rul_csr( invstr_rec.Investor_Agreement_id, invstr_rec.TOP_LINE_ID );
        FETCH bill_site_rul_csr INTO l_site_id1;
        CLOSE bill_site_rul_csr;

        OPEN  bill_site_csr( l_site_id1, l_customer_id );
        FETCH bill_site_csr INTO l_cust_site_id;
        CLOSE bill_site_csr;         */

        --CHANGED CODE FOR RULES MIGRATION
        OPEN  bill_site_rul_csr( invstr_rec.Investor_Agreement_id, invstr_rec.TOP_LINE_ID );
        FETCH bill_site_rul_csr INTO l_cust_site_id;
        CLOSE bill_site_rul_csr;


        IF  (l_cust_site_id IS NULL) THEN
          OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_INVEST_BILL_BTOS_ERR');

          l_return_status := Okl_Api.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- Payment Terms
        OPEN  std_terms_csr;
        FETCH std_terms_csr INTO l_terms;
        CLOSE std_terms_csr;

        -- Receipt Method
        OPEN  rcpt_mthd_rul_csr( invstr_rec.Investor_Agreement_id, invstr_rec.TOP_LINE_ID );
        FETCH rcpt_mthd_rul_csr INTO l_rcpt_id1;
        CLOSE rcpt_mthd_rul_csr;

        OPEN  rcpt_mthd_csr ( l_rcpt_id1, l_customer_id );
        FETCH rcpt_mthd_csr INTO l_receipt_method_id;
        CLOSE rcpt_mthd_csr;

        -- Bank Account
        OPEN  bank_acct_rul_csr( invstr_rec.Investor_Agreement_id, invstr_rec.TOP_LINE_ID );
        FETCH bank_acct_rul_csr INTO l_bank_id1;
        CLOSE bank_acct_rul_csr;

        OPEN  bank_acct_id_csr( l_bank_id1 );
        FETCH bank_acct_id_csr INTO l_bank_acct_id;
        CLOSE bank_acct_id_csr;

        -- To pass bank account Id or not
        OPEN  pass_or_not_csr ( l_receipt_method_id );
        FETCH pass_or_not_csr INTO l_how_created;
        CLOSE pass_or_not_csr;

        -- Get trx_type_id
        OPEN  c_trx_id( Okl_Accounting_Util.GET_SET_OF_BOOKS_ID, invstr_rec.ORG_ID );
        FETCH c_trx_id INTO l_cust_trx_id;
        CLOSE c_trx_id;

        IF  (l_cust_trx_id IS NULL)  THEN
          OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_INVEST_BILL_TRANS_ERR');

          l_return_status := Okl_Api.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- Multi-Currency parameters
        l_currency_code            := invstr_rec.currency_code;
        l_currency_conversion_type := invstr_rec.currency_conversion_type;
        l_currency_conversion_rate := invstr_rec.currency_conversion_rate;
        l_currency_conversion_date := invstr_rec.currency_conversion_date;

        -- Resolve Currency Convesion Parameters for Multi-Currency
        IF l_currency_conversion_type IS NULL THEN
             l_currency_conversion_type  := 'User';
             l_currency_conversion_rate  := 1;
             l_currency_conversion_date  := SYSDATE;
        END IF;
        -- For date
        IF l_currency_conversion_date IS NULL THEN
	        l_currency_conversion_date := SYSDATE;
        END IF;

        -- For rate -- Work out the rate in a Spot or Corporate
        IF (l_currency_conversion_type = 'User') THEN
            IF l_currency_conversion_rate IS NULL THEN
                l_currency_conversion_rate := 1;
            END IF;
        END IF;
        IF (l_currency_conversion_type = 'Spot'
        OR l_currency_conversion_type = 'Corporate') THEN
              l_currency_conversion_rate
                     := okl_accounting_util.get_curr_con_rate
                   (p_from_curr_code => l_currency_code,
	                p_to_curr_code   => okl_accounting_util.get_func_curr_code,
	                p_con_date       => l_currency_conversion_date,
	                p_con_type       => l_currency_conversion_type);

        END IF;

        -- Fetch a unique Id
        l_unique_id   := get_seq_id;
	l_legal_entity_id := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_inv_agr); -- for LE Uptake project 08-11-2006
	/*IF l_legal_entity_id IS NULL THEN
	       Okl_Api.set_message(p_app_name     => g_app_name,
                                   p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
	                           p_token1       => 'CONTRACT_ID',
	                           p_token1_value =>  p_inv_agr);
               RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;*/

       BEGIN
       /* ankushar 05-Feb-2007 Billing R12 project
          start billing changes
       */
       --Assign value to l_currency_conversion_type
       IF l_currency_conversion_type <> 'User' THEN
           l_currency_conversion_rate := NULL;
       END IF;

       -- Populate the header record structure
            --Added by kthiruva for Bug 6691554
            --The receivables invoice during an add request should be created for the additional
            --stake amount stored in amount stake
            --The status code is used to differenciate if the call is recievables invoice
            --is being created during activation of the IA or the activation of an add contract request
            IF l_status_code = 'ACTIVE' THEN
              lp_taiv_rec.amount                    := invstr_rec.amount_stake;
            ELSE
              lp_taiv_rec.amount                    := invstr_rec.amount;
            END IF;
            lp_taiv_rec.currency_conversion_date  := l_currency_conversion_date;
            lp_taiv_rec.currency_conversion_rate  := l_currency_conversion_rate;
            lp_taiv_rec.currency_conversion_type  := l_currency_conversion_type;
            lp_taiv_rec.currency_code             := l_currency_code;
         --ansethur R12 B Billing
         -- lp_taiv_rec.try_id                    := l_cust_trx_id;
            lp_taiv_rec.try_id                    := l_try_id;
         --ansethur R12 B Billing
         /* ankushar 25-Oct-2007 Bug# 6501426, Transaction Type corrected for Investor
            start code changes
          */
            lp_taiv_rec.cust_trx_type_id          := l_cust_trx_id;
         /* ankushar 25-Oct-2007 Bug# 6501426
            End Changes
          */
            lp_taiv_rec.date_entered              := invstr_rec.start_date;
            lp_taiv_rec.date_invoiced             := invstr_rec.start_date;
         --ansethur R12 B Billing changed investor_agreement used for assiginment into Investor_Agreement_id
            lp_taiv_rec.khr_id                    := SUBSTR(LTRIM(RTRIM(invstr_rec.Investor_Agreement_id)),1,30);
         --rkuttiya R12 B Billing changes
            lp_taiv_rec.investor_agreement_number := invstr_rec.investor_agreement;
            lp_taiv_rec.investor_name             := invstr_rec.investor_name;
         --
            lp_taiv_rec.ixx_id                    := l_customer_id;
            lp_taiv_rec.ibt_id                    := l_cust_site_id;
            lp_taiv_rec.irm_id                    := l_receipt_method_id;
            lp_taiv_rec.set_of_books_id           := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID;
            lp_taiv_rec.irt_id                    := l_terms;
            lp_taiv_rec.org_id                    := invstr_rec.org_id;
            lp_taiv_rec.legal_entity_id           := l_legal_entity_id;
            lp_taiv_rec.okl_source_billing_trx    := 'INVESTOR_STAKE';
        -- Bug#6167215  fix - varangan - Begin
            lp_taiv_rec.trx_status_code := 'SUBMITTED';
        -- Bug#6167215  fix - varangan - End

       -- Populate the Line record

            IF l_status_code = 'ACTIVE' THEN
              lp_tilv_rec.amount                    := invstr_rec.amount_stake;
            ELSE
              lp_tilv_rec.amount                    := invstr_rec.amount;
            END IF;
            lp_tilv_rec.description      := SUBSTR(invstr_rec.Investor_Agreement||'-'||invstr_rec.Investor_Name||'-'||invstr_rec.AMOUNT,1,240);
            lp_tilv_rec.quantity         := 1;
         --ansethur R12 B Billing
            lp_tilv_rec.line_number      := 1;
         -- Begin - fix for Bug#6208308 - varangan
	    lp_tilv_rec.sty_id := l_sty_id;
         -- End - fix for Bug#6208308 - varangan


            lp_tilv_tbl(1) := lp_tilv_rec;

           --Make the call to create an invoice only if the amount is >0
           IF lp_taiv_rec.amount > 0 THEN
		     -- Call the Common Billing API to create AR Invoices
             OKL_INTERNAL_BILLING_PVT.create_billing_trx( p_api_version      => l_api_version
                                                        ,p_init_msg_list   => p_init_msg_list
                                                        ,x_return_status   => x_return_status -- Bug#6167215 fix - varangan
                                                        ,x_msg_count       => x_msg_count
                                                        ,x_msg_data        => x_msg_data
                                                        ,p_taiv_rec        => lp_taiv_rec
                                                        ,p_tilv_tbl        => lp_tilv_tbl
                                                        ,p_tldv_tbl        => lp_tldv_tbl
                                                        ,x_taiv_rec        => lx_taiv_rec
                                                        ,x_tilv_tbl        => lx_tilv_tbl
                                                        ,x_tldv_tbl        => lx_tldv_tbl);
            END IF;
       /* ankushar end billing changes */
/*
          INSERT INTO RA_INTERFACE_LINES (
             ACCOUNTING_RULE_ID
            ,ACCOUNTING_RULE_DURATION
            ,AGREEMENT_ID
            ,AMOUNT
            ,BATCH_SOURCE_NAME
            ,COMMENTS
            ,CONVERSION_DATE
            ,CONVERSION_RATE
            ,CONVERSION_TYPE
            ,CREATED_BY
            ,CREATION_DATE
            ,CREDIT_METHOD_FOR_ACCT_RULE
            ,CREDIT_METHOD_FOR_INSTALLMENTS
            ,CURRENCY_CODE
            ,CUST_TRX_TYPE_ID
            ,DESCRIPTION
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_DATE
            ,LINE_TYPE
            ,TRX_NUMBER
            ,TRX_DATE
            ,GL_DATE
            ,PRINTING_OPTION
            ,CONS_BILLING_NUMBER
            ,INTERFACE_LINE_ATTRIBUTE1
            ,INTERFACE_LINE_ATTRIBUTE2
            ,INTERFACE_LINE_ATTRIBUTE3
            ,INTERFACE_LINE_ATTRIBUTE4
            ,INTERFACE_LINE_ATTRIBUTE5
            ,INTERFACE_LINE_ATTRIBUTE6
            ,INTERFACE_LINE_ATTRIBUTE7
            ,INTERFACE_LINE_ATTRIBUTE8
            ,INTERFACE_LINE_ATTRIBUTE9
            ,INTERFACE_LINE_ATTRIBUTE10
            ,INTERFACE_LINE_ATTRIBUTE11
            ,INTERFACE_LINE_ATTRIBUTE12
            ,INTERFACE_LINE_ATTRIBUTE13
            ,INTERFACE_LINE_ATTRIBUTE14
            ,INTERFACE_LINE_ATTRIBUTE15
        --    ,INTERFACE_LINE_ID
            ,INTERFACE_LINE_CONTEXT
            ,INVENTORY_ITEM_ID
            ,INVOICING_RULE_ID
            ,ORIG_SYSTEM_BILL_CUSTOMER_ID
            ,ORIG_SYSTEM_BILL_ADDRESS_ID
            ,ORIG_SYSTEM_SHIP_CUSTOMER_ID
            ,ORIG_SYSTEM_SHIP_ADDRESS_ID
            ,ORIG_SYSTEM_BILL_CONTACT_ID
            ,ORIG_SYSTEM_SOLD_CUSTOMER_ID
            ,PRIMARY_SALESREP_NUMBER
            ,PRIMARY_SALESREP_ID
            ,PURCHASE_ORDER
            ,PURCHASE_ORDER_REVISION
            ,PURCHASE_ORDER_DATE
            ,CUSTOMER_BANK_ACCOUNT_ID
            ,RECEIPT_METHOD_ID
            ,RECEIPT_METHOD_NAME
            ,QUANTITY
            ,QUANTITY_ORDERED
            ,REASON_CODE
            ,REASON_CODE_MEANING
            ,REFERENCE_LINE_ID
            ,RULE_START_DATE
            ,SALES_ORDER
            ,SALES_ORDER_LINE
            ,SALES_ORDER_DATE
            ,SALES_ORDER_SOURCE
            ,SET_OF_BOOKS_ID
            ,TAX_EXEMPT_FLAG
            ,TAX_EXEMPT_NUMBER
            ,TAX_EXEMPT_REASON_CODE
            ,TERM_ID
            ,UNIT_SELLING_PRICE
            ,UNIT_STANDARD_PRICE
            ,UOM_CODE
            ,HEADER_Attribute_CATEGORY
            ,HEADER_Attribute1
            ,HEADER_Attribute2
            ,HEADER_Attribute3
            ,HEADER_Attribute4
            ,HEADER_Attribute5
            ,HEADER_Attribute6
            ,HEADER_Attribute7
            ,HEADER_Attribute8
            ,HEADER_Attribute9
            ,HEADER_Attribute10
            ,HEADER_Attribute11
            ,HEADER_Attribute12
            ,HEADER_Attribute13
            ,HEADER_Attribute14
            ,HEADER_Attribute15
            ,Attribute_CATEGORY
            ,Attribute1
            ,Attribute2
            ,Attribute3
            ,Attribute4
            ,Attribute5
            ,Attribute6
            ,Attribute7
            ,Attribute8
            ,Attribute9
            ,Attribute10
            ,Attribute11
            ,Attribute12
            ,Attribute13
            ,Attribute14
            ,Attribute15
            ,ORG_ID
	    ,LEGAL_ENTITY_ID -- for LE Uptake project 08-11-2006
            )
          VALUES
          ( NULL
          , NULL
          , NULL
          , invstr_rec.AMOUNT
          ,'OKL_INVESTOR'
          , NULL
          , l_currency_conversion_date
          , DECODE(l_currency_conversion_type,'User',l_currency_conversion_rate,NULL)
          , l_currency_conversion_type
          , FND_global.user_id
          , SYSDATE
          , NULL
          , NULL
          , l_currency_code
          , l_cust_trx_id --CUST_TRX_TYPE_ID
          , SUBSTR(invstr_rec.Investor_Agreement||'-'||invstr_rec.Investor_Name||'-'||invstr_rec.AMOUNT,1,240)
          , FND_global.user_id
          , SYSDATE
          , 'LINE' --r_ExtLine.LINE_TYPE
          , NULL --TRX_NUMBER
          , invstr_rec.START_DATE --TRX_DATE
          , invstr_rec.START_DATE --TRX_DATE
          , NULL
          , NULL --XTRX_CONS_INVOICE_NUMBER
          , SUBSTR(LTRIM(RTRIM(invstr_rec.Investor_Agreement)),1,30)
          , SUBSTR(LTRIM(RTRIM(l_unique_id)),1,20)
          , SUBSTR(LTRIM(RTRIM(l_unique_id)),21)
          , SUBSTR(LTRIM(RTRIM(invstr_rec.Investor_Name)),1,30)
          , 'INVESTOR RECEIVABLE' --SUBSTR(LTRIM(RTRIM(r_ExtLine.XTRX_CONS_LINE_NUMBER)),1,30)
          , NULL --SUBSTR(LTRIM(RTRIM(r_ExtLine.XTRX_CONTRACT)),1,30)
          , NULL --SUBSTR(LTRIM(RTRIM(r_ExtLine.XTRX_ASSET)),1,30)
          , NULL --SUBSTR(LTRIM(RTRIM(r_ExtLine.XTRX_STREAM_GROUP)),1,30)
          , NULL --SUBSTR(LTRIM(RTRIM(r_ExtLine.XTRX_STREAM_TYPE)),1,30)
          , NULL --SUBSTR (r_ExtLine.XTRX_CONS_STREAM_ID,  1, 20)
          , NULL --SUBSTR (r_ExtLine.XTRX_CONS_STREAM_ID, 21)
          , NULL
          , NULL
          , NULL
          , NULL
        --  , r_ExtLine.ID
          , 'OKL_INVESTOR'
          , NULL
          , NULL
          , l_customer_id --CUSTOMER_ID
          , l_cust_site_id --CUSTOMER_ADDRESS_ID
          , l_customer_id --CUSTOMER_ID
          , l_cust_site_id --NVL(l_ship_to , r_ExtHdr.CUSTOMER_ADDRESS_ID)
          , NULL
          , NULL
          -- BEGIN bvaghela 032305 bug 4256274
          , -3
          , -3
          -- END bvaghela 032305 bug 4256274
          , NULL
          , NULL
          , NULL
          , decode( l_how_created, 'MANUAL',NULL,l_bank_acct_id ) --CUSTOMER_BANK_ACCOUNT_ID
          , l_receipt_method_id --RECEIPT_METHOD_ID
          , NULL
          , 1 --QUANTITY
          , NULL
          , NULL
          , NULL
          , NULL --REFERENCE_LINE_ID
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , Okl_Accounting_Util.GET_SET_OF_BOOKS_ID
          , decode(l_taxable_yn, 'Y', 'S', 'N', 'E', 'S')
          , NULL
          , decode(l_taxable_yn, 'Y', null, 'N', 'MANUFACTURER', null)
          , l_terms
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , invstr_rec.ORG_ID
          ,l_legal_entity_id   -- for LE Uptake project 08-11-2006
	  ) ;


        -- BEGIN bvaghela 032305 bug 4256274 --

           -- Get Sales Rep Id and Number
        l_salesrep_id     := NULL;
        l_salesrep_number := NULL;

        OPEN  sales_rep_csr;
        FETCH sales_rep_csr INTO l_salesrep_id,l_salesrep_number;
        CLOSE sales_rep_csr;

        l_sales_type_credit := NULL;
        OPEN  sales_type_credit_csr;
        FETCH sales_type_credit_csr INTO l_sales_type_credit;
        CLOSE sales_type_credit_csr;

        -- Insert into sales credits table

        INSERT INTO RA_INTERFACE_SALESCREDITS_ALL (
            INTERFACE_LINE_ATTRIBUTE1
           ,INTERFACE_LINE_ATTRIBUTE2
           ,INTERFACE_LINE_ATTRIBUTE3
           ,INTERFACE_LINE_ATTRIBUTE4
           ,INTERFACE_LINE_ATTRIBUTE5
           ,INTERFACE_LINE_ATTRIBUTE6
           ,INTERFACE_LINE_ATTRIBUTE7
           ,INTERFACE_LINE_ATTRIBUTE8
           ,INTERFACE_LINE_ATTRIBUTE9
           ,INTERFACE_LINE_ATTRIBUTE10
           ,INTERFACE_LINE_ATTRIBUTE11
           ,INTERFACE_LINE_ATTRIBUTE12
           ,INTERFACE_LINE_ATTRIBUTE13
           ,INTERFACE_LINE_ATTRIBUTE14
           ,INTERFACE_LINE_ATTRIBUTE15
           ,INTERFACE_LINE_CONTEXT
           ,SALES_CREDIT_AMOUNT_SPLIT
           ,SALES_CREDIT_PERCENT_SPLIT
           ,SALES_CREDIT_TYPE_ID
           ,SALES_CREDIT_TYPE_NAME
           ,SALESREP_ID
           ,SALESREP_NUMBER
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,ORG_ID
           )
         VALUES (
             SUBSTR(LTRIM(RTRIM(invstr_rec.Investor_Agreement)),1,30)
           , SUBSTR(LTRIM(RTRIM(l_unique_id)),1,20)
           , SUBSTR(LTRIM(RTRIM(l_unique_id)),21)
           , SUBSTR(LTRIM(RTRIM(invstr_rec.Investor_Name)),1,30)
           , NULL
           , NULL
           , NULL
           , NULL
           , NULL
           , NULL
           , NULL
           , NULL
           , NULL
           , NULL
           , NULL
           , 'OKL_INVESTOR'
           , NULL
           , 100
           , l_sales_type_credit
           , 'Quota Sales Credit'
           , -3
           , -3
           ,l_user_id
           ,l_sysdate
           ,l_user_id
           ,l_sysdate
           ,invstr_rec.ORG_ID
           );

           -- END bvaghela 032305 bug 4256274 --

        EXCEPTION
            WHEN OTHERS THEN
                 --modified by pgomes 01-Aug-2003 fix for bug 3078976
                 OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_INVEST_BILL_LINES_ERR');

                 l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
                 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        END;

        -- Create accounting distributions
        BEGIN
        -- bug#4643924 fetch the special accounting code associated to the inv agreement
            l_inv_code := NULL;
            FOR spl_acct_rec IN spl_acct_code_rul_csr(invstr_rec.Investor_Agreement_id) LOOP
                l_inv_code := spl_acct_rec.investor_code;
            END LOOP;

            -- Set Distribution Counter
            l_distr_cnt := 0;
            --modified by pgomes 01-Aug-2003 fix for bug 3078976
            l_distr_err := FALSE;
            -- BUG#4643924 passing special accounting code as parameter
            FOR dstrs_rec IN dstrs_csr( invstr_rec.pdt_id, l_try_id, l_sty_id, l_inv_code) LOOP

                l_distr_cnt := l_distr_cnt + 1;

                IF dstrs_rec.ACCOUNT_BUILDER_YN = 'N' THEN
                    l_cc_id := dstrs_rec.CODE_COMBINATION_ID;
                ELSE
                    l_acc_gen_primary_key_tbl := l_init_acc_gen_primary_key_tbl;
                    OKL_ACC_CALL_PVT.okl_populate_acc_gen
                                (invstr_rec.Investor_Agreement_id,
                                 NULL,
                                 l_acc_gen_primary_key_tbl,
                                 l_return_status);

                    IF (l_return_status = 'S' ) THEN
                        --FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Acc Gen Key Tbl populated.');
                        null;
                    ELSE
                        l_distr_err := TRUE;
                        --FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Error populating Acc Gen Key Tbl.');
	                END IF;

    	            l_cc_id := OKL_ACCOUNT_GENERATOR_PUB.GET_CCID
                                    (p_api_version     => p_api_version,
                                     p_init_msg_list   => p_init_msg_list,
                                     x_return_status   => l_return_status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data,
                                     p_acc_gen_wf_sources_rec => l_acc_gen_wf_sources_rec,
                                     p_ae_line_type    => dstrs_rec.AE_LINE_TYPE,
                                     p_primary_key_tbl => l_acc_gen_primary_key_tbl);
                    IF (l_return_status = 'S' ) THEN
                        --FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Acc Gen Fetched CCID');
                        null;
                    ELSE
                        l_distr_err := TRUE;
                        --FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- Error Acc Gen Fetching CCID.');
	                END IF;
                END IF;

                l_amount := okl_accounting_util.cross_currency_round_amount
                                ( (invstr_rec.AMOUNT*dstrs_rec.PERCENTAGE/100)
                                ,l_currency_code);

                --modified by pgomes 01-Aug-2003 fix for bug 3078976
                IF  (l_distr_err) THEN
                  OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_INVEST_BILL_DISTR_ERR');

                  l_return_status := Okl_Api.G_RET_STS_ERROR;
                  RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

                INSERT INTO RA_INTERFACE_DISTRIBUTIONS
                (ACCOUNT_CLASS
                ,AMOUNT
                ,PERCENT
                ,CODE_COMBINATION_ID
                ,INTERFACE_LINE_CONTEXT
                ,INTERFACE_LINE_ATTRIBUTE1
                ,INTERFACE_LINE_ATTRIBUTE2
                ,INTERFACE_LINE_ATTRIBUTE3
                ,INTERFACE_LINE_ATTRIBUTE4
                ,INTERFACE_LINE_ATTRIBUTE5
                ,INTERFACE_LINE_ATTRIBUTE6
                ,INTERFACE_LINE_ATTRIBUTE7
                ,INTERFACE_LINE_ATTRIBUTE8
                ,INTERFACE_LINE_ATTRIBUTE9
                ,INTERFACE_LINE_ATTRIBUTE10
                ,INTERFACE_LINE_ATTRIBUTE11
                ,INTERFACE_LINE_ATTRIBUTE12
                ,INTERFACE_LINE_ATTRIBUTE13
                ,INTERFACE_LINE_ATTRIBUTE14
                ,INTERFACE_LINE_ATTRIBUTE15
                ,ORG_ID
                )
                VALUES
                ( decode( dstrs_rec.CRD_CODE,'C','REV','REC') --l_account_class
                , l_amount
                , dstrs_rec.PERCENTAGE
                , l_cc_id --r_ExtDistr.CODE_COMBINATION_ID
                , 'OKL_INVESTOR'
                , SUBSTR(LTRIM(RTRIM(invstr_rec.Investor_Agreement)),1,30) --SUBSTR ( r_ExtHdr.XTRX_INVOICE_PULL_YN,1,30 )
                , SUBSTR(LTRIM(RTRIM(l_unique_id)),1,20) --SUBSTR (r_ExtHdr.XTRX_CONS_INVOICE_NUMBER,1,30 )
                , SUBSTR(LTRIM(RTRIM(l_unique_id)),21) --SUBSTR ( r_ExtHdr.XTRX_FORMAT_TYPE,1,30 )
                , SUBSTR(LTRIM(RTRIM(invstr_rec.Investor_Name)),1,30) -- SUBSTR ( r_ExtHdr.XTRX_PRIVATE_LABEL,1,30 )
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , invstr_rec.ORG_ID
                ) ;
          END LOOP; -- Distribution Loop

          IF  (nvl(l_distr_cnt, 0) = 0) THEN
                  OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_INVEST_BILL_DISTR_ERR');

                  l_return_status := Okl_Api.G_RET_STS_ERROR;
                  RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;

        EXCEPTION
            --modified by pgomes 01-Aug-2003 fix for bug 3078976
            WHEN G_EXCEPTION_HALT_VALIDATION THEN
                 x_return_status := l_return_status;
                 RAISE;
            WHEN OTHERS THEN
                 OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_INVEST_BILL_DISTR_ERR');

                 l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
                 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     */

     END;

    END LOOP; -- Investor Loop



     ----------------------------------------------------
	 -- End activity
	 ----------------------------------------------------

     Okl_Api.END_ACTIVITY (
		  x_msg_count	=> x_msg_count,
          x_msg_data	=> x_msg_data);
EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM
                          ,p_token3       => 'Package'
                          ,p_token3_value => G_PKG_NAME
                          ,p_token4       => 'Procedure'
                          ,p_token4_value => l_api_name
                          );
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END create_investor_bill;


PROCEDURE create_bill_txn_conc
        (
         errbuf	 OUT NOCOPY  VARCHAR2
	    ,retcode OUT NOCOPY  NUMBER
	    ,p_inv_agr            IN  NUMBER
        ,p_investor_line_id   IN  NUMBER
        )
IS

    -- Local Variables
    l_api_version      NUMBER := 1;
    lx_msg_count       NUMBER;
    lx_msg_data        VARCHAR2(200);
    l_msg_index_out    NUMBER;
    lx_return_status   VARCHAR(1);

BEGIN

        create_investor_bill
                (p_api_version        => l_api_version
	            ,p_init_msg_list      => OKC_API.G_FALSE
	            ,x_return_status      => lx_return_status
	            ,x_msg_count          => lx_msg_count
	            ,x_msg_data           => errbuf
            	,p_inv_agr            => p_inv_agr
                ,p_investor_line_id   => p_investor_line_id
         );

    IF lx_msg_count >= 1 THEN
        FOR i in 1..lx_msg_count LOOP
            fnd_msg_pub.get (
                       p_msg_index     => i,
                       p_encoded       => 'F',
                       p_data          => lx_msg_data,
                       p_msg_index_out => l_msg_index_out);

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,to_char(i) || ': ' || lx_msg_data);
        END LOOP;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
             FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=>Exception Calling API..'||SQLERRM);
END create_bill_txn_conc;


  ------------------------------------------------------------------
  -- Procedure create_billing_transaction to bill investor
  -- transactions
  ------------------------------------------------------------------

PROCEDURE create_billing_transaction
	(p_api_version		  IN  NUMBER
	,p_init_msg_list	  IN  VARCHAR2
	,x_return_status	  OUT NOCOPY VARCHAR2
	,x_msg_count		  OUT NOCOPY NUMBER
	,x_msg_data			  OUT NOCOPY VARCHAR2
	,p_tai_rec            IN  okl_tai_pvt.taiv_rec_type
	,p_til_tbl            IN  okl_til_pvt.tilv_tbl_type
    )
IS

	------------------------------------------------------------
	-- Extract all External records to be billed
	------------------------------------------------------------

	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------

	l_api_version	CONSTANT NUMBER := 1;
	l_api_name	CONSTANT VARCHAR2(30)  := 'Create_Billing_Transaction';
	l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;


    CURSOR get_try_id_csr IS
        SELECT	id
        FROM	okl_trx_types_v
        WHERE	name	= 'Billing';


	-- ********************************

	-- Transaction Headers
	i_taiv_rec		 Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
	r_taiv_rec		 Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;

	-- Transaction Lines
	i_tilv_rec	Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
	r_tilv_rec	Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;

	------------------------------------------------------------
	-- Declare variables to call Accounting Engine.
	------------------------------------------------------------
	p_bpd_acc_rec					Okl_Acc_Call_Pub.bpd_acc_rec_type;


BEGIN
	       ------------------------------------------------------------
	       -- Start processing
   	       ------------------------------------------------------------

	       x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	       l_return_status := Okl_Api.START_ACTIVITY(
		      p_api_name	=> l_api_name,
		      p_pkg_name	=> G_PKG_NAME,
		      p_init_msg_list	=> p_init_msg_list,
		      l_api_version	=> l_api_version,
		      p_api_version	=> p_api_version,
		      p_api_type	=> '_PVT',
		      x_return_status	=> l_return_status);

	       IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	       ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		      RAISE Okl_Api.G_EXCEPTION_ERROR;
	       END IF;

		   ---------------------------------------------
		   -- Populate Header record
		   ---------------------------------------------
           i_taiv_rec := p_tai_rec;

            --Default trx_status when not supplied
            IF i_taiv_rec.trx_status_code IS NULL THEN
                i_taiv_rec.trx_status_code := 'SUBMITTED';
            END IF;

            --Default try_id when not supplied
            IF i_taiv_rec.try_id IS NULL THEN
                OPEN  get_try_id_csr;
                FETCH get_try_id_csr INTO i_taiv_rec.try_id;
                CLOSE get_try_id_csr;
            END IF;

			---------------------------------------------
			-- Insert transaction header record
			---------------------------------------------
			Okl_Trx_Ar_Invoices_Pub.insert_trx_ar_invoices
				(p_api_version
				,p_init_msg_list
				,l_return_status
				,x_msg_count
				,x_msg_data
				,i_taiv_rec
				,r_taiv_rec);

			IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
				RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
			ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
				RAISE Okl_Api.G_EXCEPTION_ERROR;
			END IF;

			---------------------------------------------
			-- Create Lines and accounting entries for each
            -- billing line
			---------------------------------------------

            FOR i IN  p_til_tbl.first..p_til_tbl.LAST LOOP
			     ---------------------------------------------
			     -- Populate transaction line record
			     ---------------------------------------------

                 i_tilv_rec        := p_til_tbl(i);
                 i_tilv_rec.tai_id := r_taiv_rec.id;

                 --Default Line Number when not supplied
                 IF i_tilv_rec.LINE_NUMBER IS NULL THEN
                    i_tilv_rec.LINE_NUMBER := 1;
                 END IF;

                 --Default Quantity when not supplied
                 IF i_tilv_rec.QUANTITY IS NULL THEN
                    i_tilv_rec.QUANTITY := 1;
                 END IF;
                 --Default Line Code when not supplied
                 IF i_tilv_rec.INV_RECEIV_LINE_CODE IS NULL THEN
                    i_tilv_rec.INV_RECEIV_LINE_CODE := 'LINE';
                 END IF;

			     ---------------------------------------------
			     -- Insert transaction line record
			     ---------------------------------------------
			     Okl_Txl_Ar_Inv_Lns_Pub.insert_txl_ar_inv_lns
				        (p_api_version
				        ,p_init_msg_list
				        ,l_return_status
				        ,x_msg_count
				        ,x_msg_data
				        ,i_tilv_rec
				        ,r_tilv_rec);

			     IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
				        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
			     ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
				        RAISE Okl_Api.G_EXCEPTION_ERROR;
			     END IF;

			     ---------------------------------------------
			     -- Populate Accounting record
			     ---------------------------------------------
			     p_bpd_acc_rec.id 		   := r_tilv_rec.id;
			     p_bpd_acc_rec.source_table := 'OKL_TXL_AR_INV_LNS_B';
			     ----------------------------------------------------
			     -- Create Accounting Distributions
			     ----------------------------------------------------
			         Okl_Acc_Call_Pub.CREATE_ACC_TRANS(
     			        p_api_version
    		           ,p_init_msg_list
    		           ,x_return_status
    		           ,x_msg_count
    		           ,x_msg_data
  			           ,p_bpd_acc_rec
		              );

		          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
			         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
		          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
			         RAISE Okl_Api.G_EXCEPTION_ERROR;
		          END IF;
            END LOOP;

	        ----------------------------------------------------
			-- End activity
			----------------------------------------------------

            Okl_Api.END_ACTIVITY (
		      x_msg_count	=> x_msg_count,
		      x_msg_data	=> x_msg_data);
EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
	WHEN Okl_Api.G_EXCEPTION_ERROR THEN

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=>ERROR: '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=>ERROR: '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=>ERROR: '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

END create_billing_transaction;

END Okl_Investor_Billing_Pvt;

/
