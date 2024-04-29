--------------------------------------------------------
--  DDL for Package Body OKL_ACC_CALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACC_CALL_PVT" AS
/* $Header: OKLRACCB.pls 120.28.12010000.3 2008/10/01 23:33:51 rkuttiya ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.LOCKBOX';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

  ------------------------------------------------------------------
  -- Function GET_TRX_TYPE to extract transaction type
  ------------------------------------------------------------------


  FUNCTION get_trx_type
	(p_name		VARCHAR2,
	p_language	VARCHAR2)
	RETURN		NUMBER IS

	CURSOR c_trx_type (cp_name VARCHAR2, cp_language VARCHAR2) IS
		SELECT	id
		FROM	okl_trx_types_tl
		WHERE	name	= cp_name
		AND	LANGUAGE	= cp_language;

    -- Replace with following query
	CURSOR c_trx_id( p_sob_id   NUMBER, p_org_id   NUMBER ) IS
	   SELECT  ID1
	   FROM OKX_CUST_TRX_TYPES_V
	   WHERE name = 'Invoice-OKL' 			AND
	   		 set_of_books_id = p_sob_id 	AND
			 org_id			 = p_org_id;

	l_trx_type	okl_trx_types_v.id%TYPE;

  BEGIN

	l_trx_type := NULL;

	OPEN	c_trx_type (p_name, p_language);
	FETCH	c_trx_type INTO l_trx_type;
	CLOSE	c_trx_type;

	RETURN	l_trx_type;

  END get_trx_type;


PROCEDURE      Okl_Populate_Acc_Gen (
	p_contract_id		IN NUMBER,
	p_contract_line_id	IN NUMBER,
	x_acc_gen_tbl		OUT NOCOPY Okl_Account_Dist_Pub.acc_gen_primary_key,
	x_return_status	 OUT NOCOPY VARCHAR2) IS

	l_acc_gen_tbl		Okl_Account_Dist_Pub.acc_gen_primary_key;
	l_return_status		VARCHAR2(1)	:= Okl_Api.G_RET_STS_SUCCESS;
	l_ind			NUMBER		:= 0;
	l_value			VARCHAR2(100)	:= NULL;


	-- Get Payables Financial Options
	CURSOR	l_fin_sys_parms_csr IS
		SELECT	fnd_profile.value ('ORG_ID')
		FROM	dual;

	-- Get Receivables Transaction Type
	CURSOR	l_cust_trx_type_csr IS
		SELECT	ctt.cust_trx_type_id
		FROM	ra_cust_trx_types	ctt
		WHERE	ctt.name		= 'Invoice-OKL';

	-- Get Customer Bill_To Address
	CURSOR	l_cust_acct_site_csr (cp_chr_id IN NUMBER) IS
		SELECT	khr.bill_to_site_use_id
		FROM    okc_k_headers_b khr
		WHERE	khr.id = cp_chr_id;

	-- Get Contract Salesperson
	CURSOR	l_salesperson_csr (cp_chr_id IN NUMBER) IS
		SELECT	con.object1_id1
		FROM	okc_k_headers_b 	CHR,
			okc_contact_sources	cso,
			okc_k_party_roles_b	kpr,
			okc_contacts		con
		WHERE	CHR.id			= cp_chr_id
		AND	cso.cro_code		= 'SALESPERSON'
		AND	cso.rle_code		= 'LESSOR'
		AND	cso.buy_or_sell		= CHR.buy_or_sell
		AND	kpr.chr_id		= CHR.id
		AND	kpr.dnz_chr_id		= CHR.id
		AND	kpr.rle_code		= cso.rle_code
		AND	con.cpl_id		= kpr.id
		AND	con.dnz_chr_id		= CHR.id
		AND	con.cro_code		= cso.cro_code
		AND	con.jtot_object1_code	= cso.jtot_object_code;

	-- Get Master Item from Financial Asset Line
	CURSOR	l_mtl_sys_item_csr (cp_chr_id IN NUMBER, cp_cle_id IN NUMBER) IS
		SELECT	--ite.object1_id1
        RPAD (ite.object1_id1, 50, ' ') || khr.inv_organization_id
		FROM	okc_k_lines_b		kle_fa,
			okc_line_styles_b	lse_fa,
			okc_k_lines_b		kle_ml,
			okc_line_styles_b	lse_ml,
			okc_k_items		ite,
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

	-- Get Fixed Asset Info from Financial Asset Line
	CURSOR	l_fa_asset_line_csr (cp_chr_id IN NUMBER, cp_cle_id IN NUMBER) IS
		SELECT	RPAD (oal.depreciation_category, 50, ' ') || oal.corporate_book
		FROM	okx_asset_lines_v	oal
		WHERE	oal.parent_line_id	= cp_cle_id
		AND	oal.dnz_chr_id		= cp_chr_id;

BEGIN

	-- ******************************
	-- Get Payables Financial Options
	-- ******************************

        -- gboomina Bug 5265083 - commented - Start
	/*OPEN	l_fin_sys_parms_csr;
	FETCH	l_fin_sys_parms_csr INTO l_value;
	CLOSE	l_fin_sys_parms_csr;*/

        l_value := OKL_AM_UTIL_PVT.get_chr_org_id(p_contract_id);
        -- gboomina Bug 5265083 - End

	IF l_value IS NOT NULL THEN
		l_ind	:= l_ind + 1;
		l_acc_gen_tbl(l_ind).source_table	:= 'FINANCIALS_SYSTEM_PARAMETERS';
		l_acc_gen_tbl(l_ind).primary_key_column	:= l_value;
		l_value	:= NULL;
	END IF;

	-- ********************************
	-- Get Receivables Transaction Type
	-- ********************************

	OPEN	l_cust_trx_type_csr;
	FETCH	l_cust_trx_type_csr INTO l_value;
	CLOSE	l_cust_trx_type_csr;

	IF l_value IS NOT NULL THEN
		l_ind	:= l_ind + 1;
		l_acc_gen_tbl(l_ind).source_table	:= 'RA_CUST_TRX_TYPES';
		l_acc_gen_tbl(l_ind).primary_key_column	:= l_value;
		l_value	:= NULL;
	END IF;

	-- ****************************
	-- Get Customer Bill TO Address
	-- ****************************

	IF NVL (p_contract_id, G_MISS_NUM) <> G_MISS_NUM THEN

	    OPEN  l_cust_acct_site_csr (p_contract_id);
	    FETCH l_cust_acct_site_csr INTO l_value;
	    CLOSE l_cust_acct_site_csr;

	    IF l_value IS NOT NULL THEN
		l_ind	:= l_ind + 1;
		l_acc_gen_tbl(l_ind).source_table	:= 'AR_SITE_USES_V';
		l_acc_gen_tbl(l_ind).primary_key_column	:= l_value;
		l_value	:= NULL;
	    END IF;

	END IF;

	-- ************************
	-- Get Contract Salesperson
	-- ************************

	IF NVL (p_contract_id, G_MISS_NUM) <> G_MISS_NUM THEN

	    OPEN  l_salesperson_csr (p_contract_id);
	    FETCH l_salesperson_csr INTO l_value;
	    CLOSE l_salesperson_csr;

	    IF l_value IS NOT NULL THEN
		l_ind	:= l_ind + 1;
		l_acc_gen_tbl(l_ind).source_table	:= 'JTF_RS_SALESREPS_MO_V';
		l_acc_gen_tbl(l_ind).primary_key_column	:= l_value;
		l_value	:= NULL;
	    END IF;

	END IF;

	-- *****************************************
	-- Get Master Item from Financial Asset Line
	-- *****************************************

	IF  NVL (p_contract_id,      G_MISS_NUM) <> G_MISS_NUM
	AND NVL (p_contract_line_id, G_MISS_NUM) <> G_MISS_NUM THEN

	    OPEN  l_mtl_sys_item_csr (p_contract_id, p_contract_line_id);
	    FETCH l_mtl_sys_item_csr INTO l_value;
	    CLOSE l_mtl_sys_item_csr;

	    IF l_value IS NOT NULL THEN
		l_ind	:= l_ind + 1;
		l_acc_gen_tbl(l_ind).source_table	:= 'MTL_SYSTEM_ITEMS_VL';
		l_acc_gen_tbl(l_ind).primary_key_column	:= l_value;
		l_value	:= NULL;
	    END IF;

	END IF;

	-- **********************************************
	-- Get Fixed Asset Info from Financial Asset Line
	-- **********************************************

	IF  NVL (p_contract_id,      G_MISS_NUM) <> G_MISS_NUM
	AND NVL (p_contract_line_id, G_MISS_NUM) <> G_MISS_NUM THEN

	    OPEN  l_fa_asset_line_csr (p_contract_id, p_contract_line_id);
	    FETCH l_fa_asset_line_csr INTO l_value;
	    CLOSE l_fa_asset_line_csr;

	    IF l_value IS NOT NULL THEN
		l_ind	:= l_ind + 1;
		l_acc_gen_tbl(l_ind).source_table	:= 'FA_CATEGORY_BOOKS';
		l_acc_gen_tbl(l_ind).primary_key_column	:= l_value;
		l_value	:= NULL;
	    END IF;

	END IF;

	-- **************
	-- Return Results
	-- **************

	x_return_status	:= l_return_status;
	x_acc_gen_tbl	:= l_acc_gen_tbl;

EXCEPTION

	WHEN OTHERS THEN

		-- close open cursors
                -- gboomina Bug 5265083 - Start
		/* IF l_fin_sys_parms_csr%ISOPEN THEN
			CLOSE	l_fin_sys_parms_csr;
		END IF; */
                -- gboomina Bug 5265083 - End
		IF l_cust_trx_type_csr%ISOPEN THEN
			CLOSE	l_cust_trx_type_csr;
		END IF;

		IF l_cust_acct_site_csr%ISOPEN THEN
			CLOSE	l_cust_acct_site_csr;
		END IF;

		IF l_salesperson_csr%ISOPEN THEN
			CLOSE	l_salesperson_csr;
		END IF;

		IF l_mtl_sys_item_csr%ISOPEN THEN
			CLOSE	l_mtl_sys_item_csr;
		END IF;

		IF l_fa_asset_line_csr%ISOPEN THEN
			CLOSE	l_fa_asset_line_csr;
		END IF;

		-- store SQL error message on message stack for caller
		Okl_Api.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> SQLCODE
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> SQLERRM);

		-- notify caller of an UNEXPECTED error
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END Okl_Populate_Acc_Gen;


PROCEDURE create_acc_trans(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
  	,p_bpd_acc_rec  				IN  bpd_acc_rec_type
) IS

-- Local instance of AE rec/tbl Types

  	l_tmpl_identify_rec    		    Okl_Account_Dist_Pub.TMPL_IDENTIFY_REC_TYPE;
  	l_dist_info_rec        			Okl_Account_Dist_Pub.dist_info_REC_TYPE;
  	l_ctxt_val_tbl         			Okl_Account_Dist_Pub.CTXT_VAL_TBL_TYPE;
  	l_acc_gen_primary_key_tbl  		Okl_Account_Dist_Pub.acc_gen_primary_key;
  	l_template_tbl         			Okl_Account_Dist_Pub.AVLV_TBL_TYPE;
  	l_amount_tbl           			Okl_Account_Dist_Pub.AMOUNT_TBL_TYPE;


    p_taiv_rec						taiv_rec_type;
    x_taiv_rec                 		taiv_rec_type;

    l_hd_id							NUMBER;
    i                               NUMBER;
    l_return_status                 VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;
    l_found							BOOLEAN;

    CURSOR l_acc_lines_csr(l_id IN NUMBER) IS
		   SELECT khr.pdt_id pdt_id,
		   		  LN.sty_id sty_id,
				  hd.try_id Try_id,
				  LN.Amount line_amount,
		   		  hd.date_invoiced,
				  hd.currency_code,
--Start code added by pgomes on 11/22/2002
                  hd.currency_conversion_type      currency_conversion_type,
                  hd.currency_conversion_rate      currency_conversion_rate,
                  hd.currency_conversion_date      currency_conversion_date,
--End code added by pgomes on 11/22/2002
				  LN.id line_id,
				  'OKL_TXL_AR_INV_LNS_B' source_table,
				  hd.ID header_id,
				  hd.khr_id,
                  -- Added for bug 4228207
                  hd.qte_id,
				  LN.kle_id,
				  LN.til_id_reverses,
                                  -- Bug# 4488818
                                  LN.qte_line_id
		   FROM   okl_txl_ar_inv_lns_v LN,
		   		  okl_trx_ar_invoices_v hd,
				  okl_k_headers_v khr
		   WHERE  hd.id = LN.Tai_id	   		AND
		   		  khr.id = hd.khr_id			AND
		   		  LN.ID = l_id;

    CURSOR l_acc_dtls_csr(l_id IN NUMBER) IS
		   SELECT khr.pdt_id   pdt_id,
		   		  dtls.sty_id  sty_id,
				  hd.try_id    Try_id,
				  dtls.Amount  line_amount,
		   		  hd.date_invoiced date_invoiced,
				  hd.currency_code,
--Start code added by pgomes on 11/22/2002
                  hd.currency_conversion_type      currency_conversion_type,
                  hd.currency_conversion_rate      currency_conversion_rate,
                  hd.currency_conversion_date      currency_conversion_date,
--End code added by pgomes on 11/22/2002
				  dtls.id line_id,
				  'OKL_TXD_AR_LN_DTLS_B' source_table,
				  hd.ID header_id,
				  hd.khr_id,
                  -- Added for bug 4228207
                  hd.qte_id,
				  LN.kle_id,
                                  --Bug# 4488818
				  dtls.tld_id_reverses,
                                  -- Bug# 4488818
                                  LN.qte_line_id
		   FROM   okl_txl_ar_inv_lns_v LN,
		   		  okl_trx_ar_invoices_v hd,
				  okl_txd_ar_ln_dtls_v dtls,
				  okl_k_headers_v khr
		   WHERE hd.id = LN.Tai_id 	 	   		 AND
		       	 LN.ID = dtls.til_id_details	 AND
		   		 khr.ID = hd.KHR_ID				 AND
		   		 dtls.ID = l_id;

    -- Get currency attributes
    CURSOR l_curr_csr (cp_currency_code VARCHAR2) IS
    	   SELECT c.minimum_accountable_unit, c.precision
    	   FROM fnd_currencies c
    	   WHERE c.currency_code = cp_currency_code;

	-- Get Currency Code
	CURSOR get_curr_code_csr ( p_sob_id NUMBER ) IS
		   SELECT currency_code
		   FROM GL_LEDGERS_PUBLIC_V
		   WHERE ledger_id = p_sob_id;


    l_min_acct_unit 			    fnd_currencies.minimum_accountable_unit%TYPE;
    l_precision     			    fnd_currencies.precision%TYPE;
    l_acct_call_rec                 l_acc_dtls_csr%ROWTYPE;
    l_rounded_amount	            okl_txl_ar_inv_lns_v.amount%type;
	l_sob_id						okl_ext_sell_invs_v.SET_OF_BOOKS_ID%TYPE;
	l_curr_code					    GL_LEDGERS_PUBLIC_V.currency_code%TYPE;
	l_trx_name						VARCHAR2(20);

    --Start code added by pgomes on 11/22/2002
    SUBTYPE khr_id_type IS okl_k_headers_v.khr_id%type;
    l_khr_id khr_id_type;
    l_currency_code okl_ext_sell_invs_b.currency_code%type;
    l_currency_conversion_type okl_ext_sell_invs_b.currency_conversion_type%type;
    l_currency_conversion_rate okl_ext_sell_invs_b.currency_conversion_rate%type;
    l_currency_conversion_date okl_ext_sell_invs_b.currency_conversion_date%type;

    --Get currency conversion attributes for a contract
    CURSOR l_curr_conv_csr(cp_khr_id IN khr_id_type) IS
    SELECT  currency_code
           ,currency_conversion_type
           ,currency_conversion_rate
           ,currency_conversion_date
    FROM    okl_k_headers_full_v
    WHERE   id = cp_khr_id;

    --End code added by pgomes on 11/22/2002

	--Start code changes for rev rec by fmiao on 10/05/2004
    CURSOR l_get_accrual_csr (cp_sty_id IN NUMBER) IS
	       SELECT NVL(accrual_yn, '1')
	       FROM   okl_strm_type_b
	       WHERE  id = cp_sty_id;

    -- stmathew BUG#4547180/ 4573599 start
	CURSOR l_dstrs_count_csr (cp_source_id IN NUMBER, cp_source_table IN VARCHAR2) IS
	       SELECT count(*)
	       FROM   okl_trns_acc_dstrs
	       WHERE  source_id = cp_source_id
		   AND    source_table = cp_source_table;
    -- stmathew BUG#4547180/ 4573599 end

	l_rev_rec_basis okl_strm_type_b.accrual_yn%type;
	l_count NUMBER;
	--End code changes for rev rec by fmiao on 10/05/2004

    --Bug# 4488818: Changes for Upfront Tax Billing: Start
    lp_txsv_rec  OKL_TAX_SOURCES_PUB.txsv_rec_type;
    lx_txsv_rec  OKL_TAX_SOURCES_PUB.txsv_rec_type;

    lp_ttdv_tbl  OKL_TAX_TRX_DETAILS_PUB.ttdv_tbl_type;
    lx_ttdv_tbl  OKL_TAX_TRX_DETAILS_PUB.ttdv_tbl_type;
    --akrangan billing impacts coding start
    /*
    CURSOR upfront_tax_csr(p_khr_id IN NUMBER) IS
    SELECT rl.rule_information1 asset_upfront_tax
    FROM okc_rule_groups_b rg,
         okc_rules_b rl
    WHERE  rg.dnz_chr_id = p_khr_id
    AND    rg.rgd_code = 'LAHDTX'
    AND    rl.rgp_id = rg.id
    AND    rl.dnz_chr_id = rg.dnz_chr_id
    AND    rl.rule_information_category = 'LASTPR';

    upfront_tax_rec upfront_tax_csr%ROWTYPE;

    CURSOR tax_details_line1_csr(p_khr_id IN NUMBER,
                                 p_trx_id IN NUMBER) IS
    SELECT SUM(NVL(tax_amt,0)) tax_amt,
           SUM(NVL(taxable_amt,0)) taxable_amt,
           tax_rate_code
    FROM (
      SELECT NVL(tax_amt,0) tax_amt,
             NVL(taxable_amt,0) taxable_amt,
             tax_rate_code
      FROM   okl_tax_sources txs,
             okl_tax_trx_details txl,
             okc_rule_groups_b rg,
             okc_rules_b rl
      WHERE  txs.khr_id = p_khr_id
      AND    txs.trx_id = p_trx_id
      AND    txs.tax_line_status_code = 'ACTIVE'
      AND    txs.tax_call_type_code = 'UPFRONT_TAX'
      AND    txl.txs_id = txs.id
      AND    rg.dnz_chr_id = txs.khr_id
      AND    rg.cle_id = txs.kle_id
      AND    rg.rgd_code = 'LAASTX'
      AND    rl.rgp_id = rg.id
      AND    rl.dnz_chr_id = txs.khr_id
      AND    rl.rule_information_category = 'LAASTX'
      AND    NVL(rl.rule_information11,'BILLED') = 'BILLED'
      UNION ALL
      SELECT NVL(tax_amt,0) tax_amt,
             NVL(taxable_amt,0) taxable_amt,
             tax_rate_code
      FROM   okl_tax_sources txs,
             okl_tax_trx_details txl
      WHERE  txs.khr_id = p_khr_id
      AND    txs.kle_id IS NULL
      AND    txs.trx_id = p_trx_id
      AND    txs.tax_line_status_code = 'ACTIVE'
      AND    txs.tax_call_type_code = 'UPFRONT_TAX'
      AND    txl.txs_id = txs.id
    )
    GROUP BY tax_rate_code;

    CURSOR tax_details_line2_csr(p_khr_id IN NUMBER,
                                 p_trx_id IN NUMBER) IS
    SELECT SUM(NVL(tax_amt,0)) tax_amt,
           SUM(NVL(taxable_amt,0)) taxable_amt,
           tax_rate_code
    FROM
    (
      SELECT NVL(tax_amt,0) tax_amt,
             NVL(taxable_amt,0) taxable_amt,
             tax_rate_code
      FROM   okl_tax_sources txs,
             okl_tax_trx_details txl,
             okc_rule_groups_b rg,
             okc_rules_b rl
      WHERE  txs.khr_id = p_khr_id
      AND    txs.trx_id = p_trx_id
      AND    txs.tax_line_status_code = 'ACTIVE'
      AND    txs.tax_call_type_code = 'UPFRONT_TAX'
      AND    txl.txs_id = txs.id
      AND    rg.dnz_chr_id = txs.khr_id
      AND    rg.cle_id = txs.kle_id
      AND    rg.rgd_code = 'LAASTX'
      AND    rl.rgp_id = rg.id
      AND    rl.dnz_chr_id = txs.khr_id
      AND    rl.rule_information_category = 'LAASTX'
      AND    rl.rule_information11 = 'BILLED'
      UNION ALL
      SELECT NVL(tax_amt,0) tax_amt,
             NVL(taxable_amt,0) taxable_amt,
             tax_rate_code
      FROM   okl_tax_sources txs,
             okl_tax_trx_details txl
      WHERE  txs.khr_id = p_khr_id
      AND    txs.kle_id IS NULL
      AND    txs.trx_id = p_trx_id
      AND    txs.tax_line_status_code = 'ACTIVE'
      AND    txs.tax_call_type_code = 'UPFRONT_TAX'
      AND    txl.txs_id = txs.id
    )
    GROUP BY tax_rate_code;

    l_ttdv_count NUMBER;
    --Bug# 4488818: Changes for Upfront Tax Billing: End

    --Bug# 4488818: Changes for Rollover, Release Billing: Start

    CURSOR trx_type_csr(p_id NUMBER, p_language VARCHAR2) IS
    SELECT name
    FROM   okl_trx_types_tl
    WHERE  id = p_id
    AND    language = p_language;

    trx_type_rec trx_type_csr%ROWTYPE;
    l_orig_try_id okl_trx_types_tl.id%TYPE;

    CURSOR orig_billing_csr(p_orig_qte_id        NUMBER,
                            p_orig_quote_line_id NUMBER,
                            p_orig_try_id        NUMBER)
    IS
    SELECT til.tai_id orig_tai_id,
           til.id orig_til_id
    FROM  okl_trx_ar_invoices_b tai,
          okl_txl_ar_inv_lns_b til
    WHERE tai.qte_id = p_orig_qte_id
    AND   tai.try_id = p_orig_try_id
    AND   til.tai_id = tai.id
    AND   til.qte_line_id = p_orig_quote_line_id;

    CURSOR orig_txs_csr(p_orig_trx_id        NUMBER,
                        p_orig_trx_line_id   NUMBER)
    IS
    SELECT txs.id,
           txs.khr_id,
           txs.kle_id,
           txs.line_name,
           txs.trx_id,
           txs.trx_line_id,
           txs.entity_code,
           txs.event_class_code,
           txs.trx_level_type,
           txs.adjusted_doc_entity_code,
           txs.adjusted_doc_event_class_code,
           txs.adjusted_doc_trx_id,
           txs.adjusted_doc_trx_line_id,
           txs.adjusted_doc_trx_level_type,
           txs.adjusted_doc_number,
           txs.adjusted_doc_date,
           txs.tax_call_type_code,
           txs.sty_id,
           txs.trx_business_category,
           txs.tax_line_status_code,
           txs.sel_id,
	   -- Modified by dcshanmu for eBTax - modification starts
           txs.tax_reporting_flag,
           txs.application_id,
           txs.default_taxation_country,
           txs.product_category,
           txs.user_defined_fisc_class,
           txs.line_intended_use,
           txs.inventory_item_id,
           txs.bill_to_cust_acct_id,
           txs.org_id,
           txs.legal_entity_id,
           txs.line_amt,
           txs.assessable_value,
           txs.total_tax,
           txs.product_type,
           txs.product_fisc_classification,
           txs.trx_date,
           txs.provnl_tax_determination_date,
           txs.try_id,
           txs.ship_to_location_id,
           txs.ship_from_location_id,
           txs.trx_currency_code,
           txs.currency_conversion_type,
           txs.currency_conversion_rate,
           txs.currency_conversion_date
	   -- Modified by dcshanmu for eBTax - modification end
    FROM  okl_tax_sources txs
    WHERE txs.trx_id = p_orig_trx_id
    AND txs.trx_line_id =p_orig_trx_line_id;

    CURSOR orig_ttd_csr(p_orig_txs_id        NUMBER)
    IS
    SELECT  ttd.txs_id,
            ttd.tax_determine_date,
            ttd.tax_rate_id,
            ttd.tax_rate_code,
            ttd.taxable_amt,
            ttd.tax_exemption_id,
            ttd.tax_rate,
            ttd.tax_amt,
            ttd.billed_yn,
	    -- Modified by dcshanmu for eBTax - modification starts
            ttd.tax_call_type_code,
            ttd.tax_date,
            ttd.line_amt,
            ttd.internal_organization_id,
            ttd.application_id,
            ttd.entity_code,
            ttd.event_class_code,
            ttd.event_type_code,
            ttd.trx_id,
            ttd.trx_line_id,
            ttd.trx_level_type,
            ttd.trx_line_number,
            ttd.tax_line_number,
            ttd.tax_regime_id,
            ttd.tax_regime_code,
            ttd.tax_id,
            ttd.tax,
            ttd.tax_status_id,
            ttd.tax_status_code,
            ttd.tax_apportionment_line_number,
            ttd.legal_entity_id,
            ttd.trx_number,
            ttd.trx_date,
            ttd.tax_jurisdiction_id,
            ttd.tax_jurisdiction_code,
            ttd.tax_type_code,
            ttd.tax_currency_code,
            ttd.taxable_amt_tax_curr,
            ttd.trx_currency_code,
            ttd.minimum_accountable_unit,
            ttd.precision,
            ttd.currency_conversion_type,
            ttd.currency_conversion_rate,
            ttd.currency_conversion_date
	    -- Modified by dcshanmu for eBTax - modification end
    FROM  okl_tax_trx_details ttd
    WHERE ttd.txs_id = p_orig_txs_id;

    --Bug# 4488818: Changes for Rollover, Release Billing: End

    --Bug# 4488818: Changes for Credit Memo processing: Start

    CURSOR orig_til_csr(p_til_id NUMBER)
    IS
    SELECT til.amount,
           til.tai_id
    FROM   okl_txl_ar_inv_lns_b til
    WHERE  til.id = p_til_id;

    CURSOR orig_tld_csr(p_tld_id NUMBER)
    IS
    SELECT tld.amount,
           til.tai_id
    FROM   okl_txd_ar_ln_dtls_b  tld,
           okl_txl_ar_inv_lns_b  til
    WHERE  tld.id = p_tld_id
    AND    til.id = tld.til_id_details;

    orig_til_tld_rec orig_til_csr%ROWTYPE;

    l_cm_ratio       NUMBER;
    l_taxable_amount NUMBER;
    l_tax_amount     NUMBER;

    --Bug# 4488818: Changes for Credit Memo processing: End

    --Bug# 4622963: Changes for Mass Rebook: Start
    CURSOR  l_chk_mass_rbk_csr (p_chr_id IN NUMBER,
                                p_trx_id IN NUMBER) IS
    SELECT '!'
    FROM   okl_trx_contracts ktrx
    WHERE  ktrx.khr_id     = p_chr_id
    AND    ktrx.id         = p_trx_id
    AND    ktrx.tsu_code   = 'ENTERED'
    AND    ktrx.rbr_code   IS NOT NULL
    AND    ktrx.tcn_type   = 'TRBK'
    AND    EXISTS (SELECT '1'
                   FROM   okl_rbk_selected_contract rbk_khr
                   WHERE  rbk_khr.khr_id = ktrx.khr_id
                   AND    rbk_khr.status <> 'PROCESSED');

   l_mass_rbk_khr  VARCHAR2(1);

   CURSOR tax_details_line3_csr(p_khr_id IN NUMBER,
                                p_trx_id IN NUMBER) IS
   SELECT NVL(tax_amt,0) tax_amt,
          NVL(taxable_amt,0) taxable_amt,
          tax_rate_code
   FROM   okl_tax_sources txs,
          okl_tax_trx_details txl
   WHERE  txs.khr_id = p_khr_id
   AND    txs.trx_id = p_trx_id
   AND    txs.tax_line_status_code = 'ACTIVE'
   AND    txs.tax_call_type_code = 'UPFRONT_TAX'
   AND    txl.txs_id = txs.id
   GROUP BY tax_rate_code;
   --Bug# 4622963: Changes for Mass Rebook: End
  --akrangan ebtax  billing imapcts ends
  */
BEGIN

  IF p_bpd_acc_rec.source_table = 'OKL_TXD_AR_LN_DTLS_B' THEN
    OPEN l_acc_dtls_csr(p_bpd_acc_rec.id);
    FETCH l_acc_dtls_csr INTO l_acct_call_rec;
      --l_found := l_acc_dtls_csr%FOUND;
      --dbms_output.put_line('RECORD: '||l_acct_call_rec.line_id);
    CLOSE l_acc_dtls_csr;
  ELSE
    OPEN l_acc_lines_csr(p_bpd_acc_rec.id);
    FETCH l_acc_lines_csr INTO l_acct_call_rec;
    --l_found := l_acc_lines_csr%FOUND;
    --  dbms_output.put_line('RECORD: '||l_acct_call_rec.line_id);
    CLOSE l_acc_lines_csr;
  END IF;

  -- Bug# 4488818: Changes for Upfront Sales Tax
  -- Tax Only invoices to be created for Upfront Sales Tax
  -- are indentified by Zero Line Amounts
  IF (NVL(l_acct_call_rec.line_amount,0) <> 0 ) THEN

  --Start code added by pgomes on 11/22/2002
  --get contract currency parameters
  l_khr_id := l_acct_call_rec.khr_id;

  l_currency_code := null;
  l_currency_conversion_type := null;
  l_currency_conversion_rate := null;
  l_currency_conversion_date := null;

  FOR cur IN l_curr_conv_csr(l_khr_id) LOOP
         l_currency_code := cur.currency_code;
         l_currency_conversion_type := cur.currency_conversion_type;
         l_currency_conversion_rate := cur.currency_conversion_rate;
         l_currency_conversion_date := cur.currency_conversion_date;
  END LOOP;
  --End code added by pgomes on 11/22/2002


  -- Populate Records for Accounting Call.
  l_tmpl_identify_rec.PRODUCT_ID             := l_acct_call_rec.pdt_id;

  -- Changes for bug 3431579
  IF l_acct_call_rec.line_amount > 0 THEN
    l_tmpl_identify_rec.TRANSACTION_TYPE_ID := get_trx_type ('Billing', 'US');
	l_trx_name :=  'Billing';
  ELSE
    l_tmpl_identify_rec.TRANSACTION_TYPE_ID := get_trx_type ('Credit Memo', 'US');
	l_trx_name :=  'Credit Memo';
  END IF;

  -- Changes for bug 4228207
  IF l_acct_call_rec.qte_id IS NOT NULL THEN
      IF l_acct_call_rec.try_id IS NOT NULL THEN
        l_tmpl_identify_rec.TRANSACTION_TYPE_ID
                                             := l_acct_call_rec.try_id;
      END IF;
  END IF;

  l_tmpl_identify_rec.STREAM_TYPE_ID         := l_acct_call_rec.sty_id;
  l_tmpl_identify_rec.ADVANCE_ARREARS        := NULL;
  l_tmpl_identify_rec.FACTORING_SYND_FLAG    := NULL;
  l_tmpl_identify_rec.SYNDICATION_CODE       := NULL;
  l_tmpl_identify_rec.FACTORING_CODE         := NULL;
  l_tmpl_identify_rec.MEMO_YN                := 'N';

  -- Start Bug 4622198
  Okl_Securitization_Pvt.check_khr_ia_associated(p_api_version    => p_api_version
                                                ,p_init_msg_list  => p_init_msg_list
                                                ,x_return_status  => x_return_status
                                                ,x_msg_count      => x_msg_count
                                                ,x_msg_data       => x_msg_data
                                                ,p_khr_id         => l_acct_call_rec.khr_id
                                                ,p_scs_code       => NULL
                                                ,p_trx_date       => l_acct_call_rec.date_invoiced
                                                ,x_fact_synd_code => l_tmpl_identify_rec.FACTORING_SYND_FLAG
                                                ,x_inv_acct_code  => l_tmpl_identify_rec.INVESTOR_CODE);
  -- End Bug 4622198

  --Start code changes for rev rec by fmiao on 10/05/2004
  OPEN l_get_accrual_csr (l_tmpl_identify_rec.STREAM_TYPE_ID);
  FETCH l_get_accrual_csr INTO l_rev_rec_basis;
  CLOSE l_get_accrual_csr;

  IF (l_rev_rec_basis = 'CASH_RECEIPT' ) THEN
    -- bug5046450 Start rseela 03/29/2006
    IF l_acct_call_rec.line_amount >= 0 THEN
            l_tmpl_identify_rec.REV_REC_FLAG           := 'Y';
    ELSE
            l_tmpl_identify_rec.REV_REC_FLAG           := 'N';
    END IF;
    -- bug5046450 End rseela 03/29/2006
  ELSE
	l_tmpl_identify_rec.REV_REC_FLAG           := 'N';
  END IF;
  --End code changes for rev rec by fmiao on 10/05/2004

  l_tmpl_identify_rec.PRIOR_YEAR_YN          := 'N';

  l_dist_info_rec.SOURCE_ID                  := l_acct_call_rec.line_id;
  l_dist_info_rec.SOURCE_TABLE               := l_acct_call_rec.source_table;
  l_dist_info_rec.ACCOUNTING_DATE            := l_acct_call_rec.date_invoiced;
  l_dist_info_rec.GL_REVERSAL_FLAG           := 'N';
  l_dist_info_rec.POST_TO_GL                 := 'N';

  -- *************************************
  -- Get Set of Books and Currency_Code
  -- *************************************
  l_sob_id := NULL;
  l_sob_id := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID;

  l_curr_code := NULL;

  --Start code added by pgomes on 11/22/2002

  --Check for currency code
  IF l_acct_call_rec.currency_code IS NULL THEN
    l_curr_code := l_currency_code;
  ELSE
    l_curr_code := l_acct_call_rec.currency_code;
  END IF;

  --End code added by pgomes on 11/22/2002

  -- *************************************
  -- Rounded Amount
  -- *************************************

  --pgomes, 12/06/2002, commented out below code
  /*OPEN  l_curr_csr ( l_curr_code );
  FETCH l_curr_csr INTO l_min_acct_unit, l_precision;
  CLOSE l_curr_csr;

  IF (nvl(l_min_acct_unit,0) <> 0 ) THEN
       -- Round the amount to the nearest Min Accountable Unit
       l_rounded_amount := ROUND (l_acct_call_rec.line_amount / l_min_acct_unit) * l_min_acct_unit;
  ELSE
       -- Round the amount to the nearest precision
       l_rounded_amount := ROUND (l_acct_call_rec.line_amount, l_precision);
  END IF;*/

  --pgomes, 12/06/2002, code for rounding call
  l_rounded_amount := okl_accounting_util.cross_currency_round_amount(p_amount => l_acct_call_rec.line_amount,
                           p_currency_code => l_curr_code);


  -- *************************************
  -- Rounded Amount
  -- *************************************

  l_dist_info_rec.AMOUNT                     := ABS(l_rounded_amount);
  l_dist_info_rec.CURRENCY_CODE              := l_curr_code;

  l_dist_info_rec.CURRENCY_CONVERSION_TYPE   := NULL;

  --Start code added by pgomes on 11/22/2002

  --Check for currency conversion type
  IF l_acct_call_rec.currency_conversion_type IS NULL THEN
      l_dist_info_rec.currency_conversion_type := l_currency_conversion_type;
  ELSE
      l_dist_info_rec.currency_conversion_type := l_acct_call_rec.currency_conversion_type;
  END IF;


  l_dist_info_rec.CURRENCY_CONVERSION_DATE   := NULL;

  --Check for currency conversion date
  IF l_acct_call_rec.currency_conversion_date IS NULL THEN
      l_dist_info_rec.currency_conversion_date := l_currency_conversion_date;
  ELSE
      l_dist_info_rec.currency_conversion_date := l_acct_call_rec.currency_conversion_date;
  END IF;


  --Uncommented the below block of code to handle currency conversion rate
  IF (l_dist_info_rec.currency_conversion_type = 'User') THEN
    IF (l_dist_info_rec.currency_code = okl_accounting_util.get_func_curr_code) THEN
       l_dist_info_rec.currency_conversion_rate := 1;
    ELSE
      IF l_acct_call_rec.currency_conversion_rate IS NULL THEN
        l_dist_info_rec.currency_conversion_rate := l_currency_conversion_rate;
      ELSE
        l_dist_info_rec.currency_conversion_rate := l_acct_call_rec.currency_conversion_rate;
      END IF;
    END IF;
  --pgomes 01/10/2003 added below code to get curr conv rate
  ELSIF (l_dist_info_rec.currency_conversion_type = 'Spot' OR l_dist_info_rec.currency_conversion_type = 'Corporate') THEN
    l_dist_info_rec.currency_conversion_rate := okl_accounting_util.get_curr_con_rate
                                                (p_from_curr_code => l_dist_info_rec.currency_code,
	                                         p_to_curr_code => okl_accounting_util.get_func_curr_code,
	                                         p_con_date => l_dist_info_rec.currency_conversion_date,
	                                         p_con_type => l_dist_info_rec.currency_conversion_type);
  END IF;

  --pgomes 01/10/2003 added below code to default rate so that acct dist are created
  l_dist_info_rec.currency_conversion_rate := NVL(l_dist_info_rec.currency_conversion_rate, 1);

  --End code added by pgomes on 11/22/2002

  l_dist_info_rec.CONTRACT_ID                := NULL;
  l_dist_info_rec.CONTRACT_LINE_ID           := NULL;

    p_taiv_rec.id := l_acct_call_rec.header_id;


    Okl_Populate_Acc_Gen (
	p_contract_id	     => l_acct_call_rec.khr_id,
	p_contract_line_id	=> l_acct_call_rec.kle_id,
	x_acc_gen_tbl		=> l_acc_gen_primary_key_tbl,
	x_return_status		=> x_return_status);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

-- Start of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
    Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST(
								   p_api_version             => p_api_version
                                  ,p_init_msg_list  		 => p_init_msg_list
                                  ,x_return_status  		 => x_return_status
                                  ,x_msg_count      		 => x_msg_count
                                  ,x_msg_data       		 => x_msg_data
                                  ,p_tmpl_identify_rec 		 => l_tmpl_identify_rec
                                  ,p_dist_info_rec           => l_dist_info_rec
                                  ,p_ctxt_val_tbl            => l_ctxt_val_tbl
                                  ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl
                                  ,x_template_tbl            => l_template_tbl
                                  ,x_amount_tbl              => l_amount_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST

	--Start code changes for rev rec by fmiao on 10/05/2004
	--rseela..bug# 5046450..added AND clause to check for 4 dists only for Billing txns and not CMs
	IF (l_rev_rec_basis = 'CASH_RECEIPT'  AND l_acct_call_rec.line_amount > 0) THEN
	   -- stmathew bug#4547180 / 4573599 start
	   OPEN l_dstrs_count_csr(l_dist_info_rec.SOURCE_ID, l_dist_info_rec.SOURCE_TABLE);
	   -- stmathew bug#4547180 / 4573599 end
	   FETCH l_dstrs_count_csr INTO l_count;
	   CLOSE l_dstrs_count_csr;
	   IF (l_count < 4) THEN
	   	  x_return_status := Okl_Api.G_RET_STS_ERROR;
   	   END IF;
	END IF;
	--End code changes for rev rec by fmiao on 10/05/2004

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    /*IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
         NULL;
       	 --RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
      END IF;
    END IF;

    IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
	   p_taiv_rec.trx_status_code := 'ERROR';
	ELSE
	   p_taiv_rec.trx_status_code := 'SUBMITTED';
	END IF;*/
/*
	Okl_Tai_Pvt.update_row(
    p_api_version              =>    p_api_version,
    p_init_msg_list            =>    p_init_msg_list,
    x_return_status            =>    x_return_status,
    x_msg_count                =>    x_msg_count,
    x_msg_data                 =>    x_msg_data,
    p_taiv_rec                 =>    p_taiv_rec,
    x_taiv_rec                 =>    x_taiv_rec);
*/
--akrangan ebtax billing impacts start here
  /**
  --Bug# 4488818: Changes for Rollover, Release Billing: Start
  OPEN trx_type_csr(p_id => l_acct_call_rec.try_id,
                    p_language => 'US');
  FETCH trx_type_csr INTO trx_type_rec;
  CLOSE trx_type_csr;
  */
  --akrangan ebtax billing impacts end here

--ebtax impact on billing akrangan commented code starts here
/*
  IF trx_type_rec.name IN ('Rollover Billing'    , 'Release Billing',
                           'Rollover Credit Memo', 'Release Credit Memo') THEN

    IF trx_type_rec.name IN ('Rollover Billing', 'Release Billing') THEN
      l_orig_try_id := get_trx_type ('Billing', 'US');

    ELSIF trx_type_rec.name IN ('Rollover Credit Memo', 'Release Credit Memo') THEN
      l_orig_try_id := get_trx_type ('Credit Memo', 'US');

    END IF;
-- akrangan billing impact on ebtax start
    FOR orig_billing_rec IN orig_billing_csr(p_orig_qte_id  => l_acct_call_rec.qte_id,
                                             p_orig_quote_line_id => l_acct_call_rec.qte_line_id,
                                             p_orig_try_id  => l_orig_try_id)
    LOOP
--tax cursor
      FOR orig_txs_rec IN orig_txs_csr(p_orig_trx_id       => orig_billing_rec.orig_tai_id,
                                       p_orig_trx_line_id  => orig_billing_rec.orig_til_id)
      LOOP

        -- Populate Tax Sources Record

        lp_txsv_rec.khr_id                        := orig_txs_rec.khr_id;
        lp_txsv_rec.kle_id                        := orig_txs_rec.kle_id;
        lp_txsv_rec.asset_number                  := orig_txs_rec.line_name;
        lp_txsv_rec.trx_id                        := l_acct_call_rec.header_id;
        lp_txsv_rec.trx_line_id                   := l_acct_call_rec.line_id;
        lp_txsv_rec.entity_code                   := orig_txs_rec.entity_code;
        lp_txsv_rec.event_class_code              := orig_txs_rec.event_class_code;
        lp_txsv_rec.trx_level_type                := orig_txs_rec.trx_level_type;
        lp_txsv_rec.adjusted_doc_entity_code      := orig_txs_rec.adjusted_doc_entity_code;
        lp_txsv_rec.adjusted_doc_event_class_code := orig_txs_rec.adjusted_doc_event_class_code;
        lp_txsv_rec.adjusted_doc_trx_id           := orig_txs_rec.adjusted_doc_trx_id;
        lp_txsv_rec.adjusted_doc_trx_line_id      := orig_txs_rec.adjusted_doc_trx_line_id;
        lp_txsv_rec.adjusted_doc_trx_level_type   := orig_txs_rec.adjusted_doc_trx_level_type;
        lp_txsv_rec.adjusted_doc_number           := orig_txs_rec.adjusted_doc_number;
        lp_txsv_rec.adjusted_doc_date             := orig_txs_rec.adjusted_doc_date;
        lp_txsv_rec.tax_call_type_code            := orig_txs_rec.tax_call_type_code;
        lp_txsv_rec.sty_id                        := orig_txs_rec.sty_id;
        lp_txsv_rec.trx_business_category         := orig_txs_rec.trx_business_category;
        lp_txsv_rec.tax_line_status_code          := orig_txs_rec.tax_line_status_code;
        lp_txsv_rec.sel_id                        := orig_txs_rec.sel_id;
        lp_txsv_rec.reported_yn                   := orig_txs_rec.tax_reporting_flag;
	-- Modified by dcshanmu for eBTax - modification starts
        lp_txsv_rec.application_id := orig_txs_rec.application_id;
        lp_txsv_rec.default_taxation_country := orig_txs_rec.default_taxation_country;
        lp_txsv_rec.product_category := orig_txs_rec.product_category;
        lp_txsv_rec.user_defined_fisc_class := orig_txs_rec.user_defined_fisc_class;
        lp_txsv_rec.line_intended_use := orig_txs_rec.line_intended_use;
        lp_txsv_rec.inventory_item_id := orig_txs_rec.inventory_item_id;
        lp_txsv_rec.bill_to_cust_acct_id := orig_txs_rec.bill_to_cust_acct_id;
        lp_txsv_rec.org_id := orig_txs_rec.org_id;
        lp_txsv_rec.legal_entity_id := orig_txs_rec.legal_entity_id;
        lp_txsv_rec.line_amt := orig_txs_rec.line_amt;
        lp_txsv_rec.assessable_value := orig_txs_rec.assessable_value;
        lp_txsv_rec.total_tax := orig_txs_rec.total_tax;
        lp_txsv_rec.product_type := orig_txs_rec.product_type;
        lp_txsv_rec.product_fisc_classification := orig_txs_rec.product_fisc_classification;
        lp_txsv_rec.trx_date := orig_txs_rec.trx_date;
        lp_txsv_rec.provnl_tax_determination_date := orig_txs_rec.provnl_tax_determination_date;
        lp_txsv_rec.try_id := orig_txs_rec.try_id;
        lp_txsv_rec.ship_to_location_id := orig_txs_rec.ship_to_location_id;
        lp_txsv_rec.ship_from_location_id := orig_txs_rec.ship_from_location_id;
        lp_txsv_rec.trx_currency_code := orig_txs_rec.trx_currency_code;
        lp_txsv_rec.currency_conversion_type := orig_txs_rec.currency_conversion_type;
        lp_txsv_rec.currency_conversion_rate := orig_txs_rec.currency_conversion_rate;
        lp_txsv_rec.currency_conversion_date := orig_txs_rec.currency_conversion_date;
	-- Modified by dcshanmu for eBTax - modification end

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call OKL_TAX_SOURCES_PUB.insert_tax_sources ');
          END;
        END IF;

        -- Create Tax Sources Record
        OKL_TAX_SOURCES_PUB.insert_tax_sources(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_txsv_rec       => lp_txsv_rec,
          x_txsv_rec       => lx_txsv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call OKL_TAX_SOURCES_PUB.insert_tax_sources ');
          END;
        END IF;

        -- Populate Tax Details Record
        l_ttdv_count := 0;

        FOR orig_ttd_rec IN orig_ttd_csr(p_orig_txs_id => orig_txs_rec.id)
        LOOP
          l_ttdv_count :=  l_ttdv_count + 1;
          lp_ttdv_tbl(l_ttdv_count).txs_id                 := lx_txsv_rec.id;
          lp_ttdv_tbl(l_ttdv_count).tax_determine_date := orig_ttd_rec.tax_determine_date;
          lp_ttdv_tbl(l_ttdv_count).tax_rate_id            := orig_ttd_rec.tax_rate_id;
          lp_ttdv_tbl(l_ttdv_count).tax_rate_code          := orig_ttd_rec.tax_rate_code;
          lp_ttdv_tbl(l_ttdv_count).taxable_amt         := (-1 * orig_ttd_rec.taxable_amt);
          lp_ttdv_tbl(l_ttdv_count).tax_exemption_id       := orig_ttd_rec.tax_exemption_id;
          lp_ttdv_tbl(l_ttdv_count).tax_rate               := orig_ttd_rec.tax_rate;
          lp_ttdv_tbl(l_ttdv_count).tax_amt             := (-1 * orig_ttd_rec.tax_amt);
          lp_ttdv_tbl(l_ttdv_count).billed_yn              := orig_ttd_rec.billed_yn;
          lp_ttdv_tbl(l_ttdv_count).tax_call_type_code     := orig_ttd_rec.tax_call_type_code;
	  -- Modified by dcshanmu for eBTax - modification starts
          lp_ttdv_tbl(l_ttdv_count).tax_date	:= orig_ttd_rec.tax_date;
          lp_ttdv_tbl(l_ttdv_count).line_amt	:= orig_ttd_rec.line_amt;
          lp_ttdv_tbl(l_ttdv_count).internal_organization_id               	:= orig_ttd_rec.internal_organization_id;
          lp_ttdv_tbl(l_ttdv_count).application_id                         	:= orig_ttd_rec.application_id;
          lp_ttdv_tbl(l_ttdv_count).entity_code                            	:= orig_ttd_rec.entity_code;
          lp_ttdv_tbl(l_ttdv_count).event_class_code                       	:= orig_ttd_rec.event_class_code;
          lp_ttdv_tbl(l_ttdv_count).event_type_code                        	:= orig_ttd_rec.event_type_code;
          lp_ttdv_tbl(l_ttdv_count).trx_id                                 	:= orig_ttd_rec.trx_id;
          lp_ttdv_tbl(l_ttdv_count).trx_line_id                            	:= orig_ttd_rec.trx_line_id;
          lp_ttdv_tbl(l_ttdv_count).trx_level_type                         	:= orig_ttd_rec.trx_level_type;
          lp_ttdv_tbl(l_ttdv_count).trx_line_number                        	:= orig_ttd_rec.trx_line_number;
          lp_ttdv_tbl(l_ttdv_count).tax_line_number                        	:= orig_ttd_rec.tax_line_number;
          lp_ttdv_tbl(l_ttdv_count).tax_regime_id                          	:= orig_ttd_rec.tax_regime_id;
          lp_ttdv_tbl(l_ttdv_count).tax_regime_code                        	:= orig_ttd_rec.tax_regime_code;
          lp_ttdv_tbl(l_ttdv_count).tax_id                                 	:= orig_ttd_rec.tax_id;
          lp_ttdv_tbl(l_ttdv_count).tax                                    	:= orig_ttd_rec.tax;
          lp_ttdv_tbl(l_ttdv_count).tax_status_id                          	:= orig_ttd_rec.tax_status_id;
          lp_ttdv_tbl(l_ttdv_count).tax_status_code                        	:= orig_ttd_rec.tax_status_code;
          lp_ttdv_tbl(l_ttdv_count).tax_apportionment_line_number          	:= orig_ttd_rec.tax_apportionment_line_number;
          lp_ttdv_tbl(l_ttdv_count).legal_entity_id                        	:= orig_ttd_rec.legal_entity_id;
          lp_ttdv_tbl(l_ttdv_count).trx_number                             	:= orig_ttd_rec.trx_number;
          lp_ttdv_tbl(l_ttdv_count).trx_date                               	:= orig_ttd_rec.trx_date;
          lp_ttdv_tbl(l_ttdv_count).tax_jurisdiction_id                    	:= orig_ttd_rec.tax_jurisdiction_id;
          lp_ttdv_tbl(l_ttdv_count).tax_jurisdiction_code                  	:= orig_ttd_rec.tax_jurisdiction_code;
          lp_ttdv_tbl(l_ttdv_count).tax_type_code                          	:= orig_ttd_rec.tax_type_code;
          lp_ttdv_tbl(l_ttdv_count).tax_currency_code                      	:= orig_ttd_rec.tax_currency_code;
          lp_ttdv_tbl(l_ttdv_count).taxable_amt_tax_curr                   	:= orig_ttd_rec.taxable_amt_tax_curr;
          lp_ttdv_tbl(l_ttdv_count).trx_currency_code                      	:= orig_ttd_rec.trx_currency_code;
          lp_ttdv_tbl(l_ttdv_count).minimum_accountable_unit               	:= orig_ttd_rec.minimum_accountable_unit;
          lp_ttdv_tbl(l_ttdv_count).precision                              	:= orig_ttd_rec.precision;
          lp_ttdv_tbl(l_ttdv_count).currency_conversion_type               	:= orig_ttd_rec.currency_conversion_type;
          lp_ttdv_tbl(l_ttdv_count).currency_conversion_rate               	:= orig_ttd_rec.currency_conversion_rate;
          lp_ttdv_tbl(l_ttdv_count).currency_conversion_date               	:= orig_ttd_rec.currency_conversion_date;
	  -- Modified by dcshanmu for eBTax - modification end
        END LOOP;

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details ');
          END;
        END IF;

        -- Create Tax Details Record
        OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_ttdv_tbl       => lp_ttdv_tbl,
          x_ttdv_tbl       => lx_ttdv_tbl);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details ');
          END;
        END IF;

      END LOOP;
    END LOOP;

  ELSE
    -- Tax processing for Invoice and on-account Credit Memo
    IF l_acct_call_rec.tld_id_reverses IS NULL THEN

      --Start code changes for Tax API call by varao on 05/04/2005
      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax ');
        END;
      END IF;
      -- Call the Tax API for Invoice and on-account Credit Memo

      OKL_PROCESS_SALES_TAX_PVT.calculate_sales_tax(
                          p_api_version             => p_api_version,
                          p_init_msg_list  		    => p_init_msg_list,
                          x_return_status  		    => x_return_status,
                          x_msg_count      		    => x_msg_count,
                          x_msg_data       		    => x_msg_data,
                          p_source_trx_id       	=> p_bpd_acc_rec.id,
                          p_source_trx_name        	=> l_trx_name,
                          p_source_table       		=> p_bpd_acc_rec.source_table);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax ');
        END;
      END IF;

    --Bug# 4488818: Tax Processing for Invoice Based Credit Memo
    ELSE

      IF l_acct_call_rec.source_table = 'OKL_TXL_AR_INV_LNS_B' THEN
        OPEN orig_til_csr(p_til_id => l_acct_call_rec.tld_id_reverses);
        FETCH orig_til_csr INTO orig_til_tld_rec;
        CLOSE orig_til_csr;
      ELSIF l_acct_call_rec.source_table = 'OKL_TXD_AR_LN_DTLS_B' THEN
        OPEN orig_tld_csr(p_tld_id => l_acct_call_rec.tld_id_reverses);
        FETCH orig_tld_csr INTO orig_til_tld_rec;
        CLOSE orig_tld_csr;
      END IF;

      l_cm_ratio := l_acct_call_rec.line_amount/orig_til_tld_rec.amount;

      FOR orig_txs_rec IN orig_txs_csr(p_orig_trx_id       => orig_til_tld_rec.tai_id,
                                       p_orig_trx_line_id  => l_acct_call_rec.tld_id_reverses)
      LOOP

        -- Populate Tax Sources Record

        lp_txsv_rec.khr_id                        := orig_txs_rec.khr_id;
        lp_txsv_rec.kle_id                        := orig_txs_rec.kle_id;
        lp_txsv_rec.asset_number                  := orig_txs_rec.line_name;
        lp_txsv_rec.trx_id                        := l_acct_call_rec.header_id;
        lp_txsv_rec.trx_line_id                   := l_acct_call_rec.line_id;
        lp_txsv_rec.entity_code                   := orig_txs_rec.entity_code;
        lp_txsv_rec.event_class_code              := orig_txs_rec.event_class_code;
        lp_txsv_rec.trx_level_type                := orig_txs_rec.trx_level_type;
        lp_txsv_rec.adjusted_doc_entity_code      := orig_txs_rec.adjusted_doc_entity_code;
        lp_txsv_rec.adjusted_doc_event_class_code := orig_txs_rec.adjusted_doc_event_class_code;
        lp_txsv_rec.adjusted_doc_trx_id           := orig_txs_rec.adjusted_doc_trx_id;
        lp_txsv_rec.adjusted_doc_trx_line_id      := orig_txs_rec.adjusted_doc_trx_line_id;
        lp_txsv_rec.adjusted_doc_trx_level_type   := orig_txs_rec.adjusted_doc_trx_level_type;
        lp_txsv_rec.adjusted_doc_number           := orig_txs_rec.adjusted_doc_number;
        lp_txsv_rec.adjusted_doc_date             := orig_txs_rec.adjusted_doc_date;
        lp_txsv_rec.tax_call_type_code            := orig_txs_rec.tax_call_type_code;
        lp_txsv_rec.sty_id                        := orig_txs_rec.sty_id;
        lp_txsv_rec.trx_business_category         := orig_txs_rec.trx_business_category;
        lp_txsv_rec.tax_line_status_code          := orig_txs_rec.tax_line_status_code;
        lp_txsv_rec.sel_id                        := orig_txs_rec.sel_id;
        lp_txsv_rec.reported_yn                   := orig_txs_rec.tax_reporting_flag;
	-- Modified by dcshanmu for eBTax - modification starts
        lp_txsv_rec.application_id := orig_txs_rec.application_id;
        lp_txsv_rec.default_taxation_country := orig_txs_rec.default_taxation_country;
        lp_txsv_rec.product_category := orig_txs_rec.product_category;
        lp_txsv_rec.user_defined_fisc_class := orig_txs_rec.user_defined_fisc_class;
        lp_txsv_rec.line_intended_use := orig_txs_rec.line_intended_use;
        lp_txsv_rec.inventory_item_id := orig_txs_rec.inventory_item_id;
        lp_txsv_rec.bill_to_cust_acct_id := orig_txs_rec.bill_to_cust_acct_id;
        lp_txsv_rec.org_id := orig_txs_rec.org_id;
        lp_txsv_rec.legal_entity_id := orig_txs_rec.legal_entity_id;
        lp_txsv_rec.line_amt := orig_txs_rec.line_amt;
        lp_txsv_rec.assessable_value := orig_txs_rec.assessable_value;
        lp_txsv_rec.total_tax := orig_txs_rec.total_tax;
        lp_txsv_rec.product_type := orig_txs_rec.product_type;
        lp_txsv_rec.product_fisc_classification := orig_txs_rec.product_fisc_classification;
        lp_txsv_rec.trx_date := orig_txs_rec.trx_date;
        lp_txsv_rec.provnl_tax_determination_date := orig_txs_rec.provnl_tax_determination_date;
        lp_txsv_rec.try_id := orig_txs_rec.try_id;
        lp_txsv_rec.ship_to_location_id := orig_txs_rec.ship_to_location_id;
        lp_txsv_rec.ship_from_location_id := orig_txs_rec.ship_from_location_id;
        lp_txsv_rec.trx_currency_code := orig_txs_rec.trx_currency_code;
        lp_txsv_rec.currency_conversion_type := orig_txs_rec.currency_conversion_type;
        lp_txsv_rec.currency_conversion_rate := orig_txs_rec.currency_conversion_rate;
        lp_txsv_rec.currency_conversion_date := orig_txs_rec.currency_conversion_date;
	-- Modified by dcshanmu for eBTax - modification end

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call OKL_TAX_SOURCES_PUB.insert_tax_sources ');
          END;
        END IF;

        -- Create Tax Sources Record
        OKL_TAX_SOURCES_PUB.insert_tax_sources(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_txsv_rec       => lp_txsv_rec,
          x_txsv_rec       => lx_txsv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call OKL_TAX_SOURCES_PUB.insert_tax_sources ');
          END;
        END IF;

        -- Populate Tax Details Record
        l_ttdv_count := 0;

        FOR orig_ttd_rec IN orig_ttd_csr(p_orig_txs_id => orig_txs_rec.id)
        LOOP
          l_ttdv_count :=  l_ttdv_count + 1;
          lp_ttdv_tbl(l_ttdv_count).txs_id                 := lx_txsv_rec.id;
          lp_ttdv_tbl(l_ttdv_count).tax_determine_date := orig_ttd_rec.tax_determine_date;
          lp_ttdv_tbl(l_ttdv_count).tax_rate_id            := orig_ttd_rec.tax_rate_id;
          lp_ttdv_tbl(l_ttdv_count).tax_rate_code          := orig_ttd_rec.tax_rate_code;
          lp_ttdv_tbl(l_ttdv_count).tax_exemption_id       := orig_ttd_rec.tax_exemption_id;
          lp_ttdv_tbl(l_ttdv_count).tax_rate               := orig_ttd_rec.tax_rate;
          lp_ttdv_tbl(l_ttdv_count).billed_yn              := orig_ttd_rec.billed_yn;
          lp_ttdv_tbl(l_ttdv_count).tax_call_type_code     := orig_ttd_rec.tax_call_type_code;
	  -- Modified by dcshanmu for eBTax - modification starts
          lp_ttdv_tbl(l_ttdv_count).tax_date	:= orig_ttd_rec.tax_date;
          lp_ttdv_tbl(l_ttdv_count).line_amt	:= orig_ttd_rec.line_amt;
          lp_ttdv_tbl(l_ttdv_count).internal_organization_id               	:= orig_ttd_rec.internal_organization_id;
          lp_ttdv_tbl(l_ttdv_count).application_id                         	:= orig_ttd_rec.application_id;
          lp_ttdv_tbl(l_ttdv_count).entity_code                            	:= orig_ttd_rec.entity_code;
          lp_ttdv_tbl(l_ttdv_count).event_class_code                       	:= orig_ttd_rec.event_class_code;
          lp_ttdv_tbl(l_ttdv_count).event_type_code                        	:= orig_ttd_rec.event_type_code;
          lp_ttdv_tbl(l_ttdv_count).trx_id                                 	:= orig_ttd_rec.trx_id;
          lp_ttdv_tbl(l_ttdv_count).trx_line_id                            	:= orig_ttd_rec.trx_line_id;
          lp_ttdv_tbl(l_ttdv_count).trx_level_type                         	:= orig_ttd_rec.trx_level_type;
          lp_ttdv_tbl(l_ttdv_count).trx_line_number                        	:= orig_ttd_rec.trx_line_number;
          lp_ttdv_tbl(l_ttdv_count).tax_line_number                        	:= orig_ttd_rec.tax_line_number;
          lp_ttdv_tbl(l_ttdv_count).tax_regime_id                          	:= orig_ttd_rec.tax_regime_id;
          lp_ttdv_tbl(l_ttdv_count).tax_regime_code                        	:= orig_ttd_rec.tax_regime_code;
          lp_ttdv_tbl(l_ttdv_count).tax_id                                 	:= orig_ttd_rec.tax_id;
          lp_ttdv_tbl(l_ttdv_count).tax                                    	:= orig_ttd_rec.tax;
          lp_ttdv_tbl(l_ttdv_count).tax_status_id                          	:= orig_ttd_rec.tax_status_id;
          lp_ttdv_tbl(l_ttdv_count).tax_status_code                        	:= orig_ttd_rec.tax_status_code;
          lp_ttdv_tbl(l_ttdv_count).tax_apportionment_line_number          	:= orig_ttd_rec.tax_apportionment_line_number;
          lp_ttdv_tbl(l_ttdv_count).legal_entity_id                        	:= orig_ttd_rec.legal_entity_id;
          lp_ttdv_tbl(l_ttdv_count).trx_number                             	:= orig_ttd_rec.trx_number;
          lp_ttdv_tbl(l_ttdv_count).trx_date                               	:= orig_ttd_rec.trx_date;
          lp_ttdv_tbl(l_ttdv_count).tax_jurisdiction_id                    	:= orig_ttd_rec.tax_jurisdiction_id;
          lp_ttdv_tbl(l_ttdv_count).tax_jurisdiction_code                  	:= orig_ttd_rec.tax_jurisdiction_code;
          lp_ttdv_tbl(l_ttdv_count).tax_type_code                          	:= orig_ttd_rec.tax_type_code;
          lp_ttdv_tbl(l_ttdv_count).tax_currency_code                      	:= orig_ttd_rec.tax_currency_code;
          lp_ttdv_tbl(l_ttdv_count).taxable_amt_tax_curr                   	:= orig_ttd_rec.taxable_amt_tax_curr;
          lp_ttdv_tbl(l_ttdv_count).trx_currency_code                      	:= orig_ttd_rec.trx_currency_code;
          lp_ttdv_tbl(l_ttdv_count).minimum_accountable_unit               	:= orig_ttd_rec.minimum_accountable_unit;
          lp_ttdv_tbl(l_ttdv_count).precision                              	:= orig_ttd_rec.precision;
          lp_ttdv_tbl(l_ttdv_count).currency_conversion_type               	:= orig_ttd_rec.currency_conversion_type;
          lp_ttdv_tbl(l_ttdv_count).currency_conversion_rate               	:= orig_ttd_rec.currency_conversion_rate;
          lp_ttdv_tbl(l_ttdv_count).currency_conversion_date               	:= orig_ttd_rec.currency_conversion_date;
	  -- Modified by dcshanmu for eBTax - modification end

          l_taxable_amount := orig_ttd_rec.taxable_amt * l_cm_ratio;
          lp_ttdv_tbl(l_ttdv_count).taxable_amt :=
                               okl_accounting_util.cross_currency_round_amount
                                 (p_amount        => l_taxable_amount,
                                  p_currency_code => l_curr_code);

           l_tax_amount := orig_ttd_rec.tax_amt * l_cm_ratio;
           lp_ttdv_tbl(l_ttdv_count).tax_amt :=
                               okl_accounting_util.cross_currency_round_amount
                                 (p_amount        => l_tax_amount,
                                  p_currency_code => l_curr_code);

        END LOOP;

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details ');
          END;
        END IF;

        -- Create Tax Details Record
        OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_ttdv_tbl       => lp_ttdv_tbl,
          x_ttdv_tbl       => lx_ttdv_tbl);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details ');
          END;
        END IF;

      END LOOP;

    END IF;
    --End code changes for Tax API call by varao on 05/04/2005
  END IF;
   */
    --ebtax impact on billing akrangan commented code ends here
  --Bug# 4488818: Changes for Rollover, Release Billing: End

    /*IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
         NULL;
       	 --RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
      END IF;
    END IF;*/

  --Bug# 4488818: Changes for Upfront Sales Tax: Start
  -- Tax only invoice - Line Amount is equal to zero.
  ELSE
    NULL;
   --Bug# 4622963: Changes for Mass Rebook: Start
   --check for mass rebook contract
   --akrangan ebtax billing impacts start here
   /*
   l_mass_rbk_khr := '?';
   OPEN l_chk_mass_rbk_csr (p_chr_id => l_acct_call_rec.khr_id,
                            p_trx_id => p_bpd_acc_rec.source_trx_id);
   FETCH l_chk_mass_rbk_csr INTO l_mass_rbk_khr;
   CLOSE l_chk_mass_rbk_csr;

   -- Populate Tax Details Record
    l_ttdv_count := 0;

   --If Mass Rebook

   IF l_mass_rbk_khr = '!' THEN

     -- Fetch all Upfront Tax Lines.
     -- Upfront Tax is always to be Billed for Mass Rebook

     FOR tax_details_line_rec IN
         tax_details_line3_csr(p_khr_id => l_acct_call_rec.khr_id,
                               p_trx_id => p_bpd_acc_rec.source_trx_id)
     LOOP
       l_ttdv_count :=  l_ttdv_count + 1;
       lp_ttdv_tbl(l_ttdv_count).tax_amt := tax_details_line_rec.tax_amt;
       lp_ttdv_tbl(l_ttdv_count).taxable_amt := tax_details_line_rec.taxable_amt;
       lp_ttdv_tbl(l_ttdv_count).tax_rate_code := tax_details_line_rec.tax_rate_code;
       lp_ttdv_tbl(l_ttdv_count).tax_call_type_code := 'TAX_ONLY_INVOICE_TAX';
     END LOOP;
   --Bug# 4622963: Changes for Mass Rebook: End

   ELSE

    OPEN upfront_tax_csr(p_khr_id => l_acct_call_rec.khr_id);
    FETCH upfront_tax_csr INTO upfront_tax_rec;
    CLOSE upfront_tax_csr;

    -- Contract Level Asset Upfront Tax is set to 'BILLED'
    IF (upfront_tax_rec.asset_upfront_tax = 'BILLED') THEN

      -- Fetch Tax Lines for Assets having Line level Asset Upfront Tax
      -- Rule undefined or set to 'BILLED'.
      FOR tax_details_line_rec IN
          tax_details_line1_csr(p_khr_id => l_acct_call_rec.khr_id,
                                p_trx_id => p_bpd_acc_rec.source_trx_id)
      LOOP
         l_ttdv_count :=  l_ttdv_count + 1;
         lp_ttdv_tbl(l_ttdv_count).tax_amt := tax_details_line_rec.tax_amt;
         lp_ttdv_tbl(l_ttdv_count).taxable_amt := tax_details_line_rec.taxable_amt;
         lp_ttdv_tbl(l_ttdv_count).tax_rate_code := tax_details_line_rec.tax_rate_code;
         lp_ttdv_tbl(l_ttdv_count).tax_call_type_code := 'TAX_ONLY_INVOICE_TAX';
      END LOOP;

    -- Contract Level Asset Upfront Tax is not set to 'BILLED'
    ELSE

      -- Fetch Tax Lines for Assets having Line level Asset Upfront Tax
      -- Rule set to 'BILLED'.
      FOR tax_details_line_rec IN
          tax_details_line2_csr(p_khr_id => l_acct_call_rec.khr_id,
                                p_trx_id => p_bpd_acc_rec.source_trx_id)
      LOOP
         l_ttdv_count :=  l_ttdv_count + 1;
         lp_ttdv_tbl(l_ttdv_count).tax_amt := tax_details_line_rec.tax_amt;
         lp_ttdv_tbl(l_ttdv_count).taxable_amt := tax_details_line_rec.taxable_amt;
         lp_ttdv_tbl(l_ttdv_count).tax_rate_code := tax_details_line_rec.tax_rate_code;
         lp_ttdv_tbl(l_ttdv_count).tax_call_type_code := 'TAX_ONLY_INVOICE_TAX';
      END LOOP;

    END IF;
   END IF;
   */
   --akrangan ebtax billing impacts end here

 --akrangan ebtax billing impacts start
  /*  IF (l_ttdv_count > 0) THEN

      -- Populate Tax Sources Record
      lp_txsv_rec.khr_id := l_acct_call_rec.khr_id;
      lp_txsv_rec.trx_id := l_acct_call_rec.header_id;
      lp_txsv_rec.trx_line_id := l_acct_call_rec.line_id;
      lp_txsv_rec.entity_code := 'OKL_TXL_AR_INV_LNS_B';
      lp_txsv_rec.event_class_code := 'SALES_TRANSACTION_TAX_QUOTE';
      lp_txsv_rec.trx_level_type := 'LINE';
      lp_txsv_rec.tax_call_type_code := 'TAX_ONLY_INVOICE_TAX';
      lp_txsv_rec.sty_id := l_acct_call_rec.sty_id;
      lp_txsv_rec.tax_line_status_code := 'ACTIVE';
      lp_txsv_rec.reported_yn := 'N';

      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call OKL_TAX_SOURCES_PUB.insert_tax_sources ');
        END;
      END IF;

      -- Create Tax Sources Record
      OKL_TAX_SOURCES_PUB.insert_tax_sources(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_txsv_rec       => lp_txsv_rec,
        x_txsv_rec       => lx_txsv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call OKL_TAX_SOURCES_PUB.insert_tax_sources ');
        END;
      END IF;

      -- Populate txs_id in lp_ttdv_tbl
      FOR l_count IN lp_ttdv_tbl.FIRST..lp_ttdv_tbl.LAST
      LOOP
        lp_ttdv_tbl(l_count).txs_id := lx_txsv_rec.id;
      END LOOP;

      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details ');
        END;
      END IF;

      -- Create Tax Details Record
      OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_ttdv_tbl       => lp_ttdv_tbl,
        x_ttdv_tbl       => lx_ttdv_tbl);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details ');
        END;
      END IF;

    END IF; */
     --akrangan ebtax billing impacts end
  END IF;
  --Bug# 4488818: Changes for Upfront Sales Tax: End

  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      Okl_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END create_acc_trans;

PROCEDURE create_acc_trans(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
  	,p_bpd_acc_tbl  				IN  bpd_acc_tbl_type
) IS

  p_bpd_acc_rec 					bpd_acc_rec_type;

  l_msg_count 						NUMBER ;
  l_msg_data 						VARCHAR2(2000);

BEGIN

  SAVEPOINT bpd_acc_create;

  FOR i IN  p_bpd_acc_tbl.first..p_bpd_acc_tbl.COUNT LOOP
	 	 p_bpd_acc_rec := p_bpd_acc_tbl(i);
		 create_acc_trans(
     	 		 p_api_version
    			,p_init_msg_list
    			,x_return_status
    			,x_msg_count
    			,x_msg_data
  				,p_bpd_acc_rec
		  );
  END LOOP;
EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO bpd_acc_create;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO bpd_acc_create;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO bpd_acc_create;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('Okl_Acc_Call_Pvt','create_acc_trans');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_acc_trans;



PROCEDURE create_acc_trans_new(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
  	,p_bpd_acc_rec  				IN  bpd_acc_rec_type
    ,x_tmpl_identify_rec            OUT NOCOPY Okl_Account_Dist_Pub.TMPL_IDENTIFY_REC_TYPE
    ,x_dist_info_rec                OUT NOCOPY Okl_Account_Dist_Pub.DIST_INFO_REC_TYPE
    ,x_ctxt_val_tbl                 OUT NOCOPY Okl_Account_Dist_Pub.CTXT_VAL_TBL_TYPE
    ,x_acc_gen_primary_key_tbl      OUT NOCOPY Okl_Account_Dist_Pub.ACC_GEN_PRIMARY_KEY
) IS

-- Local instance of AE rec/tbl Types

  	l_tmpl_identify_rec    		    Okl_Account_Dist_Pub.TMPL_IDENTIFY_REC_TYPE;
  	l_dist_info_rec        			Okl_Account_Dist_Pub.DIST_INFO_REC_TYPE;
  	l_ctxt_val_tbl         			Okl_Account_Dist_Pub.CTXT_VAL_TBL_TYPE;
  	l_acc_gen_primary_key_tbl  		Okl_Account_Dist_Pub.ACC_GEN_PRIMARY_KEY;

    l_template_tbl         			Okl_Account_Dist_Pub.AVLV_TBL_TYPE;
  	l_amount_tbl           			Okl_Account_Dist_Pub.AMOUNT_TBL_TYPE;

    p_taiv_rec						taiv_rec_type;
    x_taiv_rec                 		taiv_rec_type;

    l_hd_id							NUMBER;
    i                               NUMBER;
    l_return_status                 VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;
    l_found							BOOLEAN;

    CURSOR l_acc_lines_csr(l_id IN NUMBER) IS
		   SELECT khr.pdt_id pdt_id,
		   		  LN.sty_id sty_id,
				  hd.try_id Try_id,
				  LN.Amount line_amount,
		   		  hd.date_invoiced,
				  hd.currency_code,
--Start code added by pgomes on 11/22/2002
                  hd.currency_conversion_type      currency_conversion_type,
                  hd.currency_conversion_rate      currency_conversion_rate,
                  hd.currency_conversion_date      currency_conversion_date,
--End code added by pgomes on 11/22/2002
				  LN.id line_id,
				  'OKL_TXL_AR_INV_LNS_B' source_table,
				  hd.ID header_id,
				  hd.khr_id,
                  -- Added for bug 4228207
                  hd.qte_id,
				  LN.kle_id,
				  LN.til_id_reverses,
                                  -- Bug# 4488818
                                  LN.qte_line_id
		   FROM   okl_txl_ar_inv_lns_v LN,
		   		  okl_trx_ar_invoices_v hd,
				  okl_k_headers_v khr
		   WHERE  hd.id = LN.Tai_id	   		AND
		   		  khr.id = hd.khr_id			AND
		   		  LN.ID = l_id;

    CURSOR l_acc_dtls_csr(l_id IN NUMBER) IS
		   SELECT khr.pdt_id   pdt_id,
		   		  dtls.sty_id  sty_id,
				  hd.try_id    Try_id,
				  dtls.Amount  line_amount,
		   		  hd.date_invoiced date_invoiced,
				  hd.currency_code,
--Start code added by pgomes on 11/22/2002
                  hd.currency_conversion_type      currency_conversion_type,
                  hd.currency_conversion_rate      currency_conversion_rate,
                  hd.currency_conversion_date      currency_conversion_date,
--End code added by pgomes on 11/22/2002
				  dtls.id line_id,
				  'OKL_TXD_AR_LN_DTLS_B' source_table,
				  hd.ID header_id,
				  hd.khr_id,
                  -- Added for bug 4228207
                  hd.qte_id,
				  LN.kle_id,
                                  --Bug# 4488818
				  dtls.tld_id_reverses,
                                  -- Bug# 4488818
                                  LN.qte_line_id
		   FROM   okl_txl_ar_inv_lns_v LN,
		   		  okl_trx_ar_invoices_v hd,
				  okl_txd_ar_ln_dtls_v dtls,
				  okl_k_headers_v khr
		   WHERE hd.id = LN.Tai_id 	 	   		 AND
		       	 LN.ID = dtls.til_id_details	 AND
		   		 khr.ID = hd.KHR_ID				 AND
		   		 dtls.ID = l_id;

    -- Get currency attributes
    CURSOR l_curr_csr (cp_currency_code VARCHAR2) IS
    	   SELECT c.minimum_accountable_unit, c.precision
    	   FROM fnd_currencies c
    	   WHERE c.currency_code = cp_currency_code;

	-- Get Currency Code
	CURSOR get_curr_code_csr ( p_sob_id NUMBER ) IS
		   SELECT currency_code
		   FROM GL_LEDGERS_PUBLIC_V
		   WHERE ledger_id = p_sob_id;


    l_min_acct_unit 			    fnd_currencies.minimum_accountable_unit%TYPE;
    l_precision     			    fnd_currencies.precision%TYPE;
    l_acct_call_rec                 l_acc_dtls_csr%ROWTYPE;
    l_rounded_amount	            okl_txl_ar_inv_lns_v.amount%type;
	l_sob_id						okl_ext_sell_invs_v.SET_OF_BOOKS_ID%TYPE;
	l_curr_code					    GL_LEDGERS_PUBLIC_V.currency_code%TYPE;
	l_trx_name						VARCHAR2(20);

    --Start code added by pgomes on 11/22/2002
    SUBTYPE khr_id_type IS okl_k_headers_v.khr_id%type;
    l_khr_id khr_id_type;
    l_currency_code okl_ext_sell_invs_b.currency_code%type;
    l_currency_conversion_type okl_ext_sell_invs_b.currency_conversion_type%type;
    l_currency_conversion_rate okl_ext_sell_invs_b.currency_conversion_rate%type;
    l_currency_conversion_date okl_ext_sell_invs_b.currency_conversion_date%type;

    --Get currency conversion attributes for a contract
    CURSOR l_curr_conv_csr(cp_khr_id IN khr_id_type) IS
    SELECT  currency_code
           ,currency_conversion_type
           ,currency_conversion_rate
           ,currency_conversion_date
    FROM    okl_k_headers_full_v
    WHERE   id = cp_khr_id;

    --End code added by pgomes on 11/22/2002

	--Start code changes for rev rec by fmiao on 10/05/2004
    CURSOR l_get_accrual_csr (cp_sty_id IN NUMBER) IS
	       SELECT NVL(accrual_yn, '1')
	       FROM   okl_strm_type_b
	       WHERE  id = cp_sty_id;

    -- stmathew BUG#4547180/ 4573599 start
	CURSOR l_dstrs_count_csr (cp_source_id IN NUMBER, cp_source_table IN VARCHAR2) IS
	       SELECT count(*)
	       FROM   okl_trns_acc_dstrs
	       WHERE  source_id = cp_source_id
		   AND    source_table = cp_source_table;
    -- stmathew BUG#4547180/ 4573599 end

	l_rev_rec_basis okl_strm_type_b.accrual_yn%type;
	l_count NUMBER;
	--End code changes for rev rec by fmiao on 10/05/2004

    --Bug# 4488818: Changes for Upfront Tax Billing: Start
    lp_txsv_rec  OKL_TAX_SOURCES_PUB.txsv_rec_type;
    lx_txsv_rec  OKL_TAX_SOURCES_PUB.txsv_rec_type;

    lp_ttdv_tbl  OKL_TAX_TRX_DETAILS_PUB.ttdv_tbl_type;
    lx_ttdv_tbl  OKL_TAX_TRX_DETAILS_PUB.ttdv_tbl_type;
    --akrangan billing impacts coding start
    /*
    CURSOR upfront_tax_csr(p_khr_id IN NUMBER) IS
    SELECT rl.rule_information1 asset_upfront_tax
    FROM okc_rule_groups_b rg,
         okc_rules_b rl
    WHERE  rg.dnz_chr_id = p_khr_id
    AND    rg.rgd_code = 'LAHDTX'
    AND    rl.rgp_id = rg.id
    AND    rl.dnz_chr_id = rg.dnz_chr_id
    AND    rl.rule_information_category = 'LASTPR';

    upfront_tax_rec upfront_tax_csr%ROWTYPE;

    CURSOR tax_details_line1_csr(p_khr_id IN NUMBER,
                                 p_trx_id IN NUMBER) IS
    SELECT SUM(NVL(tax_amt,0)) tax_amt,
           SUM(NVL(taxable_amt,0)) taxable_amt,
           tax_rate_code
    FROM (
      SELECT NVL(tax_amt,0) tax_amt,
             NVL(taxable_amt,0) taxable_amt,
             tax_rate_code
      FROM   okl_tax_sources txs,
             okl_tax_trx_details txl,
             okc_rule_groups_b rg,
             okc_rules_b rl
      WHERE  txs.khr_id = p_khr_id
      AND    txs.trx_id = p_trx_id
      AND    txs.tax_line_status_code = 'ACTIVE'
      AND    txs.tax_call_type_code = 'UPFRONT_TAX'
      AND    txl.txs_id = txs.id
      AND    rg.dnz_chr_id = txs.khr_id
      AND    rg.cle_id = txs.kle_id
      AND    rg.rgd_code = 'LAASTX'
      AND    rl.rgp_id = rg.id
      AND    rl.dnz_chr_id = txs.khr_id
      AND    rl.rule_information_category = 'LAASTX'
      AND    NVL(rl.rule_information11,'BILLED') = 'BILLED'
      UNION ALL
      SELECT NVL(tax_amt,0) tax_amt,
             NVL(taxable_amt,0) taxable_amt,
             tax_rate_code
      FROM   okl_tax_sources txs,
             okl_tax_trx_details txl
      WHERE  txs.khr_id = p_khr_id
      AND    txs.kle_id IS NULL
      AND    txs.trx_id = p_trx_id
      AND    txs.tax_line_status_code = 'ACTIVE'
      AND    txs.tax_call_type_code = 'UPFRONT_TAX'
      AND    txl.txs_id = txs.id
    )
    GROUP BY tax_rate_code;

    CURSOR tax_details_line2_csr(p_khr_id IN NUMBER,
                                 p_trx_id IN NUMBER) IS
    SELECT SUM(NVL(tax_amt,0)) tax_amt,
           SUM(NVL(taxable_amt,0)) taxable_amt,
           tax_rate_code
    FROM
    (
      SELECT NVL(tax_amt,0) tax_amt,
             NVL(taxable_amt,0) taxable_amt,
             tax_rate_code
      FROM   okl_tax_sources txs,
             okl_tax_trx_details txl,
             okc_rule_groups_b rg,
             okc_rules_b rl
      WHERE  txs.khr_id = p_khr_id
      AND    txs.trx_id = p_trx_id
      AND    txs.tax_line_status_code = 'ACTIVE'
      AND    txs.tax_call_type_code = 'UPFRONT_TAX'
      AND    txl.txs_id = txs.id
      AND    rg.dnz_chr_id = txs.khr_id
      AND    rg.cle_id = txs.kle_id
      AND    rg.rgd_code = 'LAASTX'
      AND    rl.rgp_id = rg.id
      AND    rl.dnz_chr_id = txs.khr_id
      AND    rl.rule_information_category = 'LAASTX'
      AND    rl.rule_information11 = 'BILLED'
      UNION ALL
      SELECT NVL(tax_amt,0) tax_amt,
             NVL(taxable_amt,0) taxable_amt,
             tax_rate_code
      FROM   okl_tax_sources txs,
             okl_tax_trx_details txl
      WHERE  txs.khr_id = p_khr_id
      AND    txs.kle_id IS NULL
      AND    txs.trx_id = p_trx_id
      AND    txs.tax_line_status_code = 'ACTIVE'
      AND    txs.tax_call_type_code = 'UPFRONT_TAX'
      AND    txl.txs_id = txs.id
    )
    GROUP BY tax_rate_code;

    l_ttdv_count NUMBER;
    --Bug# 4488818: Changes for Upfront Tax Billing: End

    --Bug# 4488818: Changes for Rollover, Release Billing: Start

    CURSOR trx_type_csr(p_id NUMBER, p_language VARCHAR2) IS
    SELECT name
    FROM   okl_trx_types_tl
    WHERE  id = p_id
    AND    language = p_language;

    trx_type_rec trx_type_csr%ROWTYPE;
    l_orig_try_id okl_trx_types_tl.id%TYPE;

    CURSOR orig_billing_csr(p_orig_qte_id        NUMBER,
                            p_orig_quote_line_id NUMBER,
                            p_orig_try_id        NUMBER)
    IS
    SELECT til.tai_id orig_tai_id,
           til.id orig_til_id
    FROM  okl_trx_ar_invoices_b tai,
          okl_txl_ar_inv_lns_b til
    WHERE tai.qte_id = p_orig_qte_id
    AND   tai.try_id = p_orig_try_id
    AND   til.tai_id = tai.id
    AND   til.qte_line_id = p_orig_quote_line_id;

    CURSOR orig_txs_csr(p_orig_trx_id        NUMBER,
                        p_orig_trx_line_id   NUMBER)
    IS
    SELECT txs.id,
           txs.khr_id,
           txs.kle_id,
           txs.line_name,
           txs.trx_id,
           txs.trx_line_id,
           txs.entity_code,
           txs.event_class_code,
           txs.trx_level_type,
           txs.adjusted_doc_entity_code,
           txs.adjusted_doc_event_class_code,
           txs.adjusted_doc_trx_id,
           txs.adjusted_doc_trx_line_id,
           txs.adjusted_doc_trx_level_type,
           txs.adjusted_doc_number,
           txs.adjusted_doc_date,
           txs.tax_call_type_code,
           txs.sty_id,
           txs.trx_business_category,
           txs.tax_line_status_code,
           txs.sel_id,
	   -- Modified by dcshanmu for eBTax - modification starts
           txs.tax_reporting_flag,
           txs.application_id,
           txs.default_taxation_country,
           txs.product_category,
           txs.user_defined_fisc_class,
           txs.line_intended_use,
           txs.inventory_item_id,
           txs.bill_to_cust_acct_id,
           txs.org_id,
           txs.legal_entity_id,
           txs.line_amt,
           txs.assessable_value,
           txs.total_tax,
           txs.product_type,
           txs.product_fisc_classification,
           txs.trx_date,
           txs.provnl_tax_determination_date,
           txs.try_id,
           txs.ship_to_location_id,
           txs.ship_from_location_id,
           txs.trx_currency_code,
           txs.currency_conversion_type,
           txs.currency_conversion_rate,
           txs.currency_conversion_date
	   -- Modified by dcshanmu for eBTax - modification end
    FROM  okl_tax_sources txs
    WHERE txs.trx_id = p_orig_trx_id
    AND txs.trx_line_id =p_orig_trx_line_id;

    CURSOR orig_ttd_csr(p_orig_txs_id        NUMBER)
    IS
    SELECT  ttd.txs_id,
            ttd.tax_determine_date,
            ttd.tax_rate_id,
            ttd.tax_rate_code,
            ttd.taxable_amt,
            ttd.tax_exemption_id,
            ttd.tax_rate,
            ttd.tax_amt,
            ttd.billed_yn,
	    -- Modified by dcshanmu for eBTax - modification starts
            ttd.tax_call_type_code,
            ttd.tax_date,
            ttd.line_amt,
            ttd.internal_organization_id,
            ttd.application_id,
            ttd.entity_code,
            ttd.event_class_code,
            ttd.event_type_code,
            ttd.trx_id,
            ttd.trx_line_id,
            ttd.trx_level_type,
            ttd.trx_line_number,
            ttd.tax_line_number,
            ttd.tax_regime_id,
            ttd.tax_regime_code,
            ttd.tax_id,
            ttd.tax,
            ttd.tax_status_id,
            ttd.tax_status_code,
            ttd.tax_apportionment_line_number,
            ttd.legal_entity_id,
            ttd.trx_number,
            ttd.trx_date,
            ttd.tax_jurisdiction_id,
            ttd.tax_jurisdiction_code,
            ttd.tax_type_code,
            ttd.tax_currency_code,
            ttd.taxable_amt_tax_curr,
            ttd.trx_currency_code,
            ttd.minimum_accountable_unit,
            ttd.precision,
            ttd.currency_conversion_type,
            ttd.currency_conversion_rate,
            ttd.currency_conversion_date
	    -- Modified by dcshanmu for eBTax - modification end
    FROM  okl_tax_trx_details ttd
    WHERE ttd.txs_id = p_orig_txs_id;

    --Bug# 4488818: Changes for Rollover, Release Billing: End

    --Bug# 4488818: Changes for Credit Memo processing: Start

    CURSOR orig_til_csr(p_til_id NUMBER)
    IS
    SELECT til.amount,
           til.tai_id
    FROM   okl_txl_ar_inv_lns_b til
    WHERE  til.id = p_til_id;

    CURSOR orig_tld_csr(p_tld_id NUMBER)
    IS
    SELECT tld.amount,
           til.tai_id
    FROM   okl_txd_ar_ln_dtls_b  tld,
           okl_txl_ar_inv_lns_b  til
    WHERE  tld.id = p_tld_id
    AND    til.id = tld.til_id_details;

    orig_til_tld_rec orig_til_csr%ROWTYPE;

    l_cm_ratio       NUMBER;
    l_taxable_amount NUMBER;
    l_tax_amount     NUMBER;

    --Bug# 4488818: Changes for Credit Memo processing: End

    --Bug# 4622963: Changes for Mass Rebook: Start
    CURSOR  l_chk_mass_rbk_csr (p_chr_id IN NUMBER,
                                p_trx_id IN NUMBER) IS
    SELECT '!'
    FROM   okl_trx_contracts ktrx
    WHERE  ktrx.khr_id     = p_chr_id
    AND    ktrx.id         = p_trx_id
    AND    ktrx.tsu_code   = 'ENTERED'
    AND    ktrx.rbr_code   IS NOT NULL
    AND    ktrx.tcn_type   = 'TRBK'
    AND    EXISTS (SELECT '1'
                   FROM   okl_rbk_selected_contract rbk_khr
                   WHERE  rbk_khr.khr_id = ktrx.khr_id
                   AND    rbk_khr.status <> 'PROCESSED');

   l_mass_rbk_khr  VARCHAR2(1);

   CURSOR tax_details_line3_csr(p_khr_id IN NUMBER,
                                p_trx_id IN NUMBER) IS
   SELECT NVL(tax_amt,0) tax_amt,
          NVL(taxable_amt,0) taxable_amt,
          tax_rate_code
   FROM   okl_tax_sources txs,
          okl_tax_trx_details txl
   WHERE  txs.khr_id = p_khr_id
   AND    txs.trx_id = p_trx_id
   AND    txs.tax_line_status_code = 'ACTIVE'
   AND    txs.tax_call_type_code = 'UPFRONT_TAX'
   AND    txl.txs_id = txs.id
   GROUP BY tax_rate_code;
   --Bug# 4622963: Changes for Mass Rebook: End
  --akrangan ebtax  billing imapcts ends
  */
BEGIN

  IF p_bpd_acc_rec.source_table = 'OKL_TXD_AR_LN_DTLS_B' THEN
    OPEN l_acc_dtls_csr(p_bpd_acc_rec.id);
    FETCH l_acc_dtls_csr INTO l_acct_call_rec;
      --l_found := l_acc_dtls_csr%FOUND;
      --dbms_output.put_line('RECORD: '||l_acct_call_rec.line_id);
    CLOSE l_acc_dtls_csr;
  ELSE
    OPEN l_acc_lines_csr(p_bpd_acc_rec.id);
    FETCH l_acc_lines_csr INTO l_acct_call_rec;
    --l_found := l_acc_lines_csr%FOUND;
    --  dbms_output.put_line('RECORD: '||l_acct_call_rec.line_id);
    CLOSE l_acc_lines_csr;
  END IF;

  -- Bug# 4488818: Changes for Upfront Sales Tax
  -- Tax Only invoices to be created for Upfront Sales Tax
  -- are indentified by Zero Line Amounts
  IF (NVL(l_acct_call_rec.line_amount,0) <> 0 ) THEN

  --Start code added by pgomes on 11/22/2002
  --get contract currency parameters
  l_khr_id := l_acct_call_rec.khr_id;

  l_currency_code := null;
  l_currency_conversion_type := null;
  l_currency_conversion_rate := null;
  l_currency_conversion_date := null;

  FOR cur IN l_curr_conv_csr(l_khr_id) LOOP
         l_currency_code := cur.currency_code;
         l_currency_conversion_type := cur.currency_conversion_type;
         l_currency_conversion_rate := cur.currency_conversion_rate;
         l_currency_conversion_date := cur.currency_conversion_date;
  END LOOP;
  --End code added by pgomes on 11/22/2002


  -- Populate Records for Accounting Call.
  l_tmpl_identify_rec.PRODUCT_ID             := l_acct_call_rec.pdt_id;

  -- Changes for bug 3431579
  IF l_acct_call_rec.line_amount > 0 THEN
    l_tmpl_identify_rec.TRANSACTION_TYPE_ID := get_trx_type ('Billing', 'US');
	l_trx_name :=  'Billing';
  ELSE
    l_tmpl_identify_rec.TRANSACTION_TYPE_ID := get_trx_type ('Credit Memo', 'US');
	l_trx_name :=  'Credit Memo';
  END IF;

  -- Changes for bug 4228207
  IF l_acct_call_rec.qte_id IS NOT NULL THEN
      IF l_acct_call_rec.try_id IS NOT NULL THEN
        l_tmpl_identify_rec.TRANSACTION_TYPE_ID
                                             := l_acct_call_rec.try_id;
      END IF;
  END IF;

  l_tmpl_identify_rec.STREAM_TYPE_ID         := l_acct_call_rec.sty_id;
  l_tmpl_identify_rec.ADVANCE_ARREARS        := NULL;
  l_tmpl_identify_rec.FACTORING_SYND_FLAG    := NULL;
  l_tmpl_identify_rec.SYNDICATION_CODE       := NULL;
  l_tmpl_identify_rec.FACTORING_CODE         := NULL;
  l_tmpl_identify_rec.MEMO_YN                := 'N';

  -- Start Bug 4622198
  Okl_Securitization_Pvt.check_khr_ia_associated(p_api_version    => p_api_version
                                                ,p_init_msg_list  => p_init_msg_list
                                                ,x_return_status  => x_return_status
                                                ,x_msg_count      => x_msg_count
                                                ,x_msg_data       => x_msg_data
                                                ,p_khr_id         => l_acct_call_rec.khr_id
                                                ,p_scs_code       => NULL
                                                ,p_trx_date       => l_acct_call_rec.date_invoiced
                                                ,x_fact_synd_code => l_tmpl_identify_rec.FACTORING_SYND_FLAG
                                                ,x_inv_acct_code  => l_tmpl_identify_rec.INVESTOR_CODE);
  -- End Bug 4622198

  --Start code changes for rev rec by fmiao on 10/05/2004
  OPEN l_get_accrual_csr (l_tmpl_identify_rec.STREAM_TYPE_ID);
  FETCH l_get_accrual_csr INTO l_rev_rec_basis;
  CLOSE l_get_accrual_csr;

  IF (l_rev_rec_basis = 'CASH_RECEIPT' ) THEN
    -- bug5046450 Start rseela 03/29/2006
   --gkhuntet added for Forward Port Bug#5946084 Start.
   -- IF l_acct_call_rec.line_amount >= 0 THEN
	l_tmpl_identify_rec.REV_REC_FLAG           := 'Y';
   -- ELSE
   --         l_tmpl_identify_rec.REV_REC_FLAG           := 'N';
   -- END IF;
   --   --gkhuntet added for Forward Port Bug#5946084 End.
   -- bug5046450 End rseela 03/29/2006
  ELSE
	l_tmpl_identify_rec.REV_REC_FLAG           := 'N';
  END IF;
  --End code changes for rev rec by fmiao on 10/05/2004

  l_tmpl_identify_rec.PRIOR_YEAR_YN          := 'N';

  l_dist_info_rec.SOURCE_ID                  := l_acct_call_rec.line_id;
  l_dist_info_rec.SOURCE_TABLE               := l_acct_call_rec.source_table;
  l_dist_info_rec.ACCOUNTING_DATE            := l_acct_call_rec.date_invoiced;
  l_dist_info_rec.GL_REVERSAL_FLAG           := 'N';
  l_dist_info_rec.POST_TO_GL                 := 'N';

  -- *************************************
  -- Get Set of Books and Currency_Code
  -- *************************************
  l_sob_id := NULL;
  l_sob_id := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID;

  l_curr_code := NULL;

  --Start code added by pgomes on 11/22/2002

  --Check for currency code
  IF l_acct_call_rec.currency_code IS NULL THEN
    l_curr_code := l_currency_code;
  ELSE
    l_curr_code := l_acct_call_rec.currency_code;
  END IF;

  --End code added by pgomes on 11/22/2002

  -- *************************************
  -- Rounded Amount
  -- *************************************

  --pgomes, 12/06/2002, commented out below code
  /*OPEN  l_curr_csr ( l_curr_code );
  FETCH l_curr_csr INTO l_min_acct_unit, l_precision;
  CLOSE l_curr_csr;

  IF (nvl(l_min_acct_unit,0) <> 0 ) THEN
       -- Round the amount to the nearest Min Accountable Unit
       l_rounded_amount := ROUND (l_acct_call_rec.line_amount / l_min_acct_unit) * l_min_acct_unit;
  ELSE
       -- Round the amount to the nearest precision
       l_rounded_amount := ROUND (l_acct_call_rec.line_amount, l_precision);
  END IF;*/

  --pgomes, 12/06/2002, code for rounding call
  l_rounded_amount := okl_accounting_util.cross_currency_round_amount(p_amount => l_acct_call_rec.line_amount,
                           p_currency_code => l_curr_code);


  -- *************************************
  -- Rounded Amount
  -- *************************************

  l_dist_info_rec.AMOUNT                     := ABS(l_rounded_amount);
  l_dist_info_rec.CURRENCY_CODE              := l_curr_code;

  l_dist_info_rec.CURRENCY_CONVERSION_TYPE   := NULL;

  --Start code added by pgomes on 11/22/2002

  --Check for currency conversion type
  IF l_acct_call_rec.currency_conversion_type IS NULL THEN
      l_dist_info_rec.currency_conversion_type := l_currency_conversion_type;
  ELSE
      l_dist_info_rec.currency_conversion_type := l_acct_call_rec.currency_conversion_type;
  END IF;


  l_dist_info_rec.CURRENCY_CONVERSION_DATE   := NULL;

  --Check for currency conversion date
  IF l_acct_call_rec.currency_conversion_date IS NULL THEN
      l_dist_info_rec.currency_conversion_date := l_currency_conversion_date;
  ELSE
      l_dist_info_rec.currency_conversion_date := l_acct_call_rec.currency_conversion_date;
  END IF;


  --Uncommented the below block of code to handle currency conversion rate
  IF (l_dist_info_rec.currency_conversion_type = 'User') THEN
    IF (l_dist_info_rec.currency_code = okl_accounting_util.get_func_curr_code) THEN
       l_dist_info_rec.currency_conversion_rate := 1;
    ELSE
      IF l_acct_call_rec.currency_conversion_rate IS NULL THEN
        l_dist_info_rec.currency_conversion_rate := l_currency_conversion_rate;
      ELSE
        l_dist_info_rec.currency_conversion_rate := l_acct_call_rec.currency_conversion_rate;
      END IF;
    END IF;
  --pgomes 01/10/2003 added below code to get curr conv rate
  ELSIF (l_dist_info_rec.currency_conversion_type = 'Spot' OR l_dist_info_rec.currency_conversion_type = 'Corporate') THEN
    l_dist_info_rec.currency_conversion_rate := okl_accounting_util.get_curr_con_rate
                                                (p_from_curr_code => l_dist_info_rec.currency_code,
	                                         p_to_curr_code => okl_accounting_util.get_func_curr_code,
	                                         p_con_date => l_dist_info_rec.currency_conversion_date,
	                                         p_con_type => l_dist_info_rec.currency_conversion_type);
  END IF;

  --pgomes 01/10/2003 added below code to default rate so that acct dist are created
  l_dist_info_rec.currency_conversion_rate := NVL(l_dist_info_rec.currency_conversion_rate, 1);

  --End code added by pgomes on 11/22/2002

  l_dist_info_rec.CONTRACT_ID                := NULL;
  l_dist_info_rec.CONTRACT_LINE_ID           := NULL;

    p_taiv_rec.id := l_acct_call_rec.header_id;


    Okl_Populate_Acc_Gen (
	p_contract_id	     => l_acct_call_rec.khr_id,
	p_contract_line_id	=> l_acct_call_rec.kle_id,
	x_acc_gen_tbl		=> l_acc_gen_primary_key_tbl,
	x_return_status		=> x_return_status);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

-- Start of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;


  x_tmpl_identify_rec   := l_tmpl_identify_rec;
  x_dist_info_rec       := l_dist_info_rec;
  x_ctxt_val_tbl        := l_ctxt_val_tbl;
  x_acc_gen_primary_key_tbl := l_acc_gen_primary_key_tbl;

  /* -- Commented by Vpanwar -- for calling this API with new signature from one single time After the call of create_acc_trans_new in loop.
    Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST(
								   p_api_version             => p_api_version
                                  ,p_init_msg_list  		 => p_init_msg_list
                                  ,x_return_status  		 => x_return_status
                                  ,x_msg_count      		 => x_msg_count
                                  ,x_msg_data       		 => x_msg_data
                                  ,p_tmpl_identify_rec 		 => l_tmpl_identify_rec
                                  ,p_dist_info_rec           => l_dist_info_rec
                                  ,p_ctxt_val_tbl            => l_ctxt_val_tbl
                                  ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl
                                  ,x_template_tbl            => l_template_tbl
                                  ,x_amount_tbl              => l_amount_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST

	--Start code changes for rev rec by fmiao on 10/05/2004
	--rseela..bug# 5046450..added AND clause to check for 4 dists only for Billing txns and not CMs
        /*  -- Bug 6441837
	IF (l_rev_rec_basis = 'CASH_RECEIPT'  AND l_acct_call_rec.line_amount > 0) THEN
	   -- stmathew bug#4547180 / 4573599 start
	   OPEN l_dstrs_count_csr(l_dist_info_rec.SOURCE_ID, l_dist_info_rec.SOURCE_TABLE);
	   -- stmathew bug#4547180 / 4573599 end
	   FETCH l_dstrs_count_csr INTO l_count;
	   CLOSE l_dstrs_count_csr;
	   IF (l_count < 4) THEN
	   	  x_return_status := Okl_Api.G_RET_STS_ERROR;
   	   END IF;
	END IF;
	--End code changes for rev rec by fmiao on 10/05/2004

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF; */

    /*IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
         NULL;
       	 --RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
      END IF;
    END IF;

    IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
	   p_taiv_rec.trx_status_code := 'ERROR';
	ELSE
	   p_taiv_rec.trx_status_code := 'SUBMITTED';
	END IF;*/
/*
	Okl_Tai_Pvt.update_row(
    p_api_version              =>    p_api_version,
    p_init_msg_list            =>    p_init_msg_list,
    x_return_status            =>    x_return_status,
    x_msg_count                =>    x_msg_count,
    x_msg_data                 =>    x_msg_data,
    p_taiv_rec                 =>    p_taiv_rec,
    x_taiv_rec                 =>    x_taiv_rec);
*/
--akrangan ebtax billing impacts start here
  /**
  --Bug# 4488818: Changes for Rollover, Release Billing: Start
  OPEN trx_type_csr(p_id => l_acct_call_rec.try_id,
                    p_language => 'US');
  FETCH trx_type_csr INTO trx_type_rec;
  CLOSE trx_type_csr;
  */
  --akrangan ebtax billing impacts end here

--ebtax impact on billing akrangan commented code starts here
/*
  IF trx_type_rec.name IN ('Rollover Billing'    , 'Release Billing',
                           'Rollover Credit Memo', 'Release Credit Memo') THEN

    IF trx_type_rec.name IN ('Rollover Billing', 'Release Billing') THEN
      l_orig_try_id := get_trx_type ('Billing', 'US');

    ELSIF trx_type_rec.name IN ('Rollover Credit Memo', 'Release Credit Memo') THEN
      l_orig_try_id := get_trx_type ('Credit Memo', 'US');

    END IF;
-- akrangan billing impact on ebtax start
    FOR orig_billing_rec IN orig_billing_csr(p_orig_qte_id  => l_acct_call_rec.qte_id,
                                             p_orig_quote_line_id => l_acct_call_rec.qte_line_id,
                                             p_orig_try_id  => l_orig_try_id)
    LOOP
--tax cursor
      FOR orig_txs_rec IN orig_txs_csr(p_orig_trx_id       => orig_billing_rec.orig_tai_id,
                                       p_orig_trx_line_id  => orig_billing_rec.orig_til_id)
      LOOP

        -- Populate Tax Sources Record

        lp_txsv_rec.khr_id                        := orig_txs_rec.khr_id;
        lp_txsv_rec.kle_id                        := orig_txs_rec.kle_id;
        lp_txsv_rec.asset_number                  := orig_txs_rec.line_name;
        lp_txsv_rec.trx_id                        := l_acct_call_rec.header_id;
        lp_txsv_rec.trx_line_id                   := l_acct_call_rec.line_id;
        lp_txsv_rec.entity_code                   := orig_txs_rec.entity_code;
        lp_txsv_rec.event_class_code              := orig_txs_rec.event_class_code;
        lp_txsv_rec.trx_level_type                := orig_txs_rec.trx_level_type;
        lp_txsv_rec.adjusted_doc_entity_code      := orig_txs_rec.adjusted_doc_entity_code;
        lp_txsv_rec.adjusted_doc_event_class_code := orig_txs_rec.adjusted_doc_event_class_code;
        lp_txsv_rec.adjusted_doc_trx_id           := orig_txs_rec.adjusted_doc_trx_id;
        lp_txsv_rec.adjusted_doc_trx_line_id      := orig_txs_rec.adjusted_doc_trx_line_id;
        lp_txsv_rec.adjusted_doc_trx_level_type   := orig_txs_rec.adjusted_doc_trx_level_type;
        lp_txsv_rec.adjusted_doc_number           := orig_txs_rec.adjusted_doc_number;
        lp_txsv_rec.adjusted_doc_date             := orig_txs_rec.adjusted_doc_date;
        lp_txsv_rec.tax_call_type_code            := orig_txs_rec.tax_call_type_code;
        lp_txsv_rec.sty_id                        := orig_txs_rec.sty_id;
        lp_txsv_rec.trx_business_category         := orig_txs_rec.trx_business_category;
        lp_txsv_rec.tax_line_status_code          := orig_txs_rec.tax_line_status_code;
        lp_txsv_rec.sel_id                        := orig_txs_rec.sel_id;
        lp_txsv_rec.reported_yn                   := orig_txs_rec.tax_reporting_flag;
	-- Modified by dcshanmu for eBTax - modification starts
        lp_txsv_rec.application_id := orig_txs_rec.application_id;
        lp_txsv_rec.default_taxation_country := orig_txs_rec.default_taxation_country;
        lp_txsv_rec.product_category := orig_txs_rec.product_category;
        lp_txsv_rec.user_defined_fisc_class := orig_txs_rec.user_defined_fisc_class;
        lp_txsv_rec.line_intended_use := orig_txs_rec.line_intended_use;
        lp_txsv_rec.inventory_item_id := orig_txs_rec.inventory_item_id;
        lp_txsv_rec.bill_to_cust_acct_id := orig_txs_rec.bill_to_cust_acct_id;
        lp_txsv_rec.org_id := orig_txs_rec.org_id;
        lp_txsv_rec.legal_entity_id := orig_txs_rec.legal_entity_id;
        lp_txsv_rec.line_amt := orig_txs_rec.line_amt;
        lp_txsv_rec.assessable_value := orig_txs_rec.assessable_value;
        lp_txsv_rec.total_tax := orig_txs_rec.total_tax;
        lp_txsv_rec.product_type := orig_txs_rec.product_type;
        lp_txsv_rec.product_fisc_classification := orig_txs_rec.product_fisc_classification;
        lp_txsv_rec.trx_date := orig_txs_rec.trx_date;
        lp_txsv_rec.provnl_tax_determination_date := orig_txs_rec.provnl_tax_determination_date;
        lp_txsv_rec.try_id := orig_txs_rec.try_id;
        lp_txsv_rec.ship_to_location_id := orig_txs_rec.ship_to_location_id;
        lp_txsv_rec.ship_from_location_id := orig_txs_rec.ship_from_location_id;
        lp_txsv_rec.trx_currency_code := orig_txs_rec.trx_currency_code;
        lp_txsv_rec.currency_conversion_type := orig_txs_rec.currency_conversion_type;
        lp_txsv_rec.currency_conversion_rate := orig_txs_rec.currency_conversion_rate;
        lp_txsv_rec.currency_conversion_date := orig_txs_rec.currency_conversion_date;
	-- Modified by dcshanmu for eBTax - modification end

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call OKL_TAX_SOURCES_PUB.insert_tax_sources ');
          END;
        END IF;

        -- Create Tax Sources Record
        OKL_TAX_SOURCES_PUB.insert_tax_sources(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_txsv_rec       => lp_txsv_rec,
          x_txsv_rec       => lx_txsv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call OKL_TAX_SOURCES_PUB.insert_tax_sources ');
          END;
        END IF;

        -- Populate Tax Details Record
        l_ttdv_count := 0;

        FOR orig_ttd_rec IN orig_ttd_csr(p_orig_txs_id => orig_txs_rec.id)
        LOOP
          l_ttdv_count :=  l_ttdv_count + 1;
          lp_ttdv_tbl(l_ttdv_count).txs_id                 := lx_txsv_rec.id;
          lp_ttdv_tbl(l_ttdv_count).tax_determine_date := orig_ttd_rec.tax_determine_date;
          lp_ttdv_tbl(l_ttdv_count).tax_rate_id            := orig_ttd_rec.tax_rate_id;
          lp_ttdv_tbl(l_ttdv_count).tax_rate_code          := orig_ttd_rec.tax_rate_code;
          lp_ttdv_tbl(l_ttdv_count).taxable_amt         := (-1 * orig_ttd_rec.taxable_amt);
          lp_ttdv_tbl(l_ttdv_count).tax_exemption_id       := orig_ttd_rec.tax_exemption_id;
          lp_ttdv_tbl(l_ttdv_count).tax_rate               := orig_ttd_rec.tax_rate;
          lp_ttdv_tbl(l_ttdv_count).tax_amt             := (-1 * orig_ttd_rec.tax_amt);
          lp_ttdv_tbl(l_ttdv_count).billed_yn              := orig_ttd_rec.billed_yn;
          lp_ttdv_tbl(l_ttdv_count).tax_call_type_code     := orig_ttd_rec.tax_call_type_code;
	  -- Modified by dcshanmu for eBTax - modification starts
          lp_ttdv_tbl(l_ttdv_count).tax_date	:= orig_ttd_rec.tax_date;
          lp_ttdv_tbl(l_ttdv_count).line_amt	:= orig_ttd_rec.line_amt;
          lp_ttdv_tbl(l_ttdv_count).internal_organization_id               	:= orig_ttd_rec.internal_organization_id;
          lp_ttdv_tbl(l_ttdv_count).application_id                         	:= orig_ttd_rec.application_id;
          lp_ttdv_tbl(l_ttdv_count).entity_code                            	:= orig_ttd_rec.entity_code;
          lp_ttdv_tbl(l_ttdv_count).event_class_code                       	:= orig_ttd_rec.event_class_code;
          lp_ttdv_tbl(l_ttdv_count).event_type_code                        	:= orig_ttd_rec.event_type_code;
          lp_ttdv_tbl(l_ttdv_count).trx_id                                 	:= orig_ttd_rec.trx_id;
          lp_ttdv_tbl(l_ttdv_count).trx_line_id                            	:= orig_ttd_rec.trx_line_id;
          lp_ttdv_tbl(l_ttdv_count).trx_level_type                         	:= orig_ttd_rec.trx_level_type;
          lp_ttdv_tbl(l_ttdv_count).trx_line_number                        	:= orig_ttd_rec.trx_line_number;
          lp_ttdv_tbl(l_ttdv_count).tax_line_number                        	:= orig_ttd_rec.tax_line_number;
          lp_ttdv_tbl(l_ttdv_count).tax_regime_id                          	:= orig_ttd_rec.tax_regime_id;
          lp_ttdv_tbl(l_ttdv_count).tax_regime_code                        	:= orig_ttd_rec.tax_regime_code;
          lp_ttdv_tbl(l_ttdv_count).tax_id                                 	:= orig_ttd_rec.tax_id;
          lp_ttdv_tbl(l_ttdv_count).tax                                    	:= orig_ttd_rec.tax;
          lp_ttdv_tbl(l_ttdv_count).tax_status_id                          	:= orig_ttd_rec.tax_status_id;
          lp_ttdv_tbl(l_ttdv_count).tax_status_code                        	:= orig_ttd_rec.tax_status_code;
          lp_ttdv_tbl(l_ttdv_count).tax_apportionment_line_number          	:= orig_ttd_rec.tax_apportionment_line_number;
          lp_ttdv_tbl(l_ttdv_count).legal_entity_id                        	:= orig_ttd_rec.legal_entity_id;
          lp_ttdv_tbl(l_ttdv_count).trx_number                             	:= orig_ttd_rec.trx_number;
          lp_ttdv_tbl(l_ttdv_count).trx_date                               	:= orig_ttd_rec.trx_date;
          lp_ttdv_tbl(l_ttdv_count).tax_jurisdiction_id                    	:= orig_ttd_rec.tax_jurisdiction_id;
          lp_ttdv_tbl(l_ttdv_count).tax_jurisdiction_code                  	:= orig_ttd_rec.tax_jurisdiction_code;
          lp_ttdv_tbl(l_ttdv_count).tax_type_code                          	:= orig_ttd_rec.tax_type_code;
          lp_ttdv_tbl(l_ttdv_count).tax_currency_code                      	:= orig_ttd_rec.tax_currency_code;
          lp_ttdv_tbl(l_ttdv_count).taxable_amt_tax_curr                   	:= orig_ttd_rec.taxable_amt_tax_curr;
          lp_ttdv_tbl(l_ttdv_count).trx_currency_code                      	:= orig_ttd_rec.trx_currency_code;
          lp_ttdv_tbl(l_ttdv_count).minimum_accountable_unit               	:= orig_ttd_rec.minimum_accountable_unit;
          lp_ttdv_tbl(l_ttdv_count).precision                              	:= orig_ttd_rec.precision;
          lp_ttdv_tbl(l_ttdv_count).currency_conversion_type               	:= orig_ttd_rec.currency_conversion_type;
          lp_ttdv_tbl(l_ttdv_count).currency_conversion_rate               	:= orig_ttd_rec.currency_conversion_rate;
          lp_ttdv_tbl(l_ttdv_count).currency_conversion_date               	:= orig_ttd_rec.currency_conversion_date;
	  -- Modified by dcshanmu for eBTax - modification end
        END LOOP;

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details ');
          END;
        END IF;

        -- Create Tax Details Record
        OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_ttdv_tbl       => lp_ttdv_tbl,
          x_ttdv_tbl       => lx_ttdv_tbl);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details ');
          END;
        END IF;

      END LOOP;
    END LOOP;

  ELSE
    -- Tax processing for Invoice and on-account Credit Memo
    IF l_acct_call_rec.tld_id_reverses IS NULL THEN

      --Start code changes for Tax API call by varao on 05/04/2005
      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax ');
        END;
      END IF;
      -- Call the Tax API for Invoice and on-account Credit Memo

      OKL_PROCESS_SALES_TAX_PVT.calculate_sales_tax(
                          p_api_version             => p_api_version,
                          p_init_msg_list  		    => p_init_msg_list,
                          x_return_status  		    => x_return_status,
                          x_msg_count      		    => x_msg_count,
                          x_msg_data       		    => x_msg_data,
                          p_source_trx_id       	=> p_bpd_acc_rec.id,
                          p_source_trx_name        	=> l_trx_name,
                          p_source_table       		=> p_bpd_acc_rec.source_table);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax ');
        END;
      END IF;

    --Bug# 4488818: Tax Processing for Invoice Based Credit Memo
    ELSE

      IF l_acct_call_rec.source_table = 'OKL_TXL_AR_INV_LNS_B' THEN
        OPEN orig_til_csr(p_til_id => l_acct_call_rec.tld_id_reverses);
        FETCH orig_til_csr INTO orig_til_tld_rec;
        CLOSE orig_til_csr;
      ELSIF l_acct_call_rec.source_table = 'OKL_TXD_AR_LN_DTLS_B' THEN
        OPEN orig_tld_csr(p_tld_id => l_acct_call_rec.tld_id_reverses);
        FETCH orig_tld_csr INTO orig_til_tld_rec;
        CLOSE orig_tld_csr;
      END IF;

      l_cm_ratio := l_acct_call_rec.line_amount/orig_til_tld_rec.amount;

      FOR orig_txs_rec IN orig_txs_csr(p_orig_trx_id       => orig_til_tld_rec.tai_id,
                                       p_orig_trx_line_id  => l_acct_call_rec.tld_id_reverses)
      LOOP

        -- Populate Tax Sources Record

        lp_txsv_rec.khr_id                        := orig_txs_rec.khr_id;
        lp_txsv_rec.kle_id                        := orig_txs_rec.kle_id;
        lp_txsv_rec.asset_number                  := orig_txs_rec.line_name;
        lp_txsv_rec.trx_id                        := l_acct_call_rec.header_id;
        lp_txsv_rec.trx_line_id                   := l_acct_call_rec.line_id;
        lp_txsv_rec.entity_code                   := orig_txs_rec.entity_code;
        lp_txsv_rec.event_class_code              := orig_txs_rec.event_class_code;
        lp_txsv_rec.trx_level_type                := orig_txs_rec.trx_level_type;
        lp_txsv_rec.adjusted_doc_entity_code      := orig_txs_rec.adjusted_doc_entity_code;
        lp_txsv_rec.adjusted_doc_event_class_code := orig_txs_rec.adjusted_doc_event_class_code;
        lp_txsv_rec.adjusted_doc_trx_id           := orig_txs_rec.adjusted_doc_trx_id;
        lp_txsv_rec.adjusted_doc_trx_line_id      := orig_txs_rec.adjusted_doc_trx_line_id;
        lp_txsv_rec.adjusted_doc_trx_level_type   := orig_txs_rec.adjusted_doc_trx_level_type;
        lp_txsv_rec.adjusted_doc_number           := orig_txs_rec.adjusted_doc_number;
        lp_txsv_rec.adjusted_doc_date             := orig_txs_rec.adjusted_doc_date;
        lp_txsv_rec.tax_call_type_code            := orig_txs_rec.tax_call_type_code;
        lp_txsv_rec.sty_id                        := orig_txs_rec.sty_id;
        lp_txsv_rec.trx_business_category         := orig_txs_rec.trx_business_category;
        lp_txsv_rec.tax_line_status_code          := orig_txs_rec.tax_line_status_code;
        lp_txsv_rec.sel_id                        := orig_txs_rec.sel_id;
        lp_txsv_rec.reported_yn                   := orig_txs_rec.tax_reporting_flag;
	-- Modified by dcshanmu for eBTax - modification starts
        lp_txsv_rec.application_id := orig_txs_rec.application_id;
        lp_txsv_rec.default_taxation_country := orig_txs_rec.default_taxation_country;
        lp_txsv_rec.product_category := orig_txs_rec.product_category;
        lp_txsv_rec.user_defined_fisc_class := orig_txs_rec.user_defined_fisc_class;
        lp_txsv_rec.line_intended_use := orig_txs_rec.line_intended_use;
        lp_txsv_rec.inventory_item_id := orig_txs_rec.inventory_item_id;
        lp_txsv_rec.bill_to_cust_acct_id := orig_txs_rec.bill_to_cust_acct_id;
        lp_txsv_rec.org_id := orig_txs_rec.org_id;
        lp_txsv_rec.legal_entity_id := orig_txs_rec.legal_entity_id;
        lp_txsv_rec.line_amt := orig_txs_rec.line_amt;
        lp_txsv_rec.assessable_value := orig_txs_rec.assessable_value;
        lp_txsv_rec.total_tax := orig_txs_rec.total_tax;
        lp_txsv_rec.product_type := orig_txs_rec.product_type;
        lp_txsv_rec.product_fisc_classification := orig_txs_rec.product_fisc_classification;
        lp_txsv_rec.trx_date := orig_txs_rec.trx_date;
        lp_txsv_rec.provnl_tax_determination_date := orig_txs_rec.provnl_tax_determination_date;
        lp_txsv_rec.try_id := orig_txs_rec.try_id;
        lp_txsv_rec.ship_to_location_id := orig_txs_rec.ship_to_location_id;
        lp_txsv_rec.ship_from_location_id := orig_txs_rec.ship_from_location_id;
        lp_txsv_rec.trx_currency_code := orig_txs_rec.trx_currency_code;
        lp_txsv_rec.currency_conversion_type := orig_txs_rec.currency_conversion_type;
        lp_txsv_rec.currency_conversion_rate := orig_txs_rec.currency_conversion_rate;
        lp_txsv_rec.currency_conversion_date := orig_txs_rec.currency_conversion_date;
	-- Modified by dcshanmu for eBTax - modification end

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call OKL_TAX_SOURCES_PUB.insert_tax_sources ');
          END;
        END IF;

        -- Create Tax Sources Record
        OKL_TAX_SOURCES_PUB.insert_tax_sources(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_txsv_rec       => lp_txsv_rec,
          x_txsv_rec       => lx_txsv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call OKL_TAX_SOURCES_PUB.insert_tax_sources ');
          END;
        END IF;

        -- Populate Tax Details Record
        l_ttdv_count := 0;

        FOR orig_ttd_rec IN orig_ttd_csr(p_orig_txs_id => orig_txs_rec.id)
        LOOP
          l_ttdv_count :=  l_ttdv_count + 1;
          lp_ttdv_tbl(l_ttdv_count).txs_id                 := lx_txsv_rec.id;
          lp_ttdv_tbl(l_ttdv_count).tax_determine_date := orig_ttd_rec.tax_determine_date;
          lp_ttdv_tbl(l_ttdv_count).tax_rate_id            := orig_ttd_rec.tax_rate_id;
          lp_ttdv_tbl(l_ttdv_count).tax_rate_code          := orig_ttd_rec.tax_rate_code;
          lp_ttdv_tbl(l_ttdv_count).tax_exemption_id       := orig_ttd_rec.tax_exemption_id;
          lp_ttdv_tbl(l_ttdv_count).tax_rate               := orig_ttd_rec.tax_rate;
          lp_ttdv_tbl(l_ttdv_count).billed_yn              := orig_ttd_rec.billed_yn;
          lp_ttdv_tbl(l_ttdv_count).tax_call_type_code     := orig_ttd_rec.tax_call_type_code;
	  -- Modified by dcshanmu for eBTax - modification starts
          lp_ttdv_tbl(l_ttdv_count).tax_date	:= orig_ttd_rec.tax_date;
          lp_ttdv_tbl(l_ttdv_count).line_amt	:= orig_ttd_rec.line_amt;
          lp_ttdv_tbl(l_ttdv_count).internal_organization_id               	:= orig_ttd_rec.internal_organization_id;
          lp_ttdv_tbl(l_ttdv_count).application_id                         	:= orig_ttd_rec.application_id;
          lp_ttdv_tbl(l_ttdv_count).entity_code                            	:= orig_ttd_rec.entity_code;
          lp_ttdv_tbl(l_ttdv_count).event_class_code                       	:= orig_ttd_rec.event_class_code;
          lp_ttdv_tbl(l_ttdv_count).event_type_code                        	:= orig_ttd_rec.event_type_code;
          lp_ttdv_tbl(l_ttdv_count).trx_id                                 	:= orig_ttd_rec.trx_id;
          lp_ttdv_tbl(l_ttdv_count).trx_line_id                            	:= orig_ttd_rec.trx_line_id;
          lp_ttdv_tbl(l_ttdv_count).trx_level_type                         	:= orig_ttd_rec.trx_level_type;
          lp_ttdv_tbl(l_ttdv_count).trx_line_number                        	:= orig_ttd_rec.trx_line_number;
          lp_ttdv_tbl(l_ttdv_count).tax_line_number                        	:= orig_ttd_rec.tax_line_number;
          lp_ttdv_tbl(l_ttdv_count).tax_regime_id                          	:= orig_ttd_rec.tax_regime_id;
          lp_ttdv_tbl(l_ttdv_count).tax_regime_code                        	:= orig_ttd_rec.tax_regime_code;
          lp_ttdv_tbl(l_ttdv_count).tax_id                                 	:= orig_ttd_rec.tax_id;
          lp_ttdv_tbl(l_ttdv_count).tax                                    	:= orig_ttd_rec.tax;
          lp_ttdv_tbl(l_ttdv_count).tax_status_id                          	:= orig_ttd_rec.tax_status_id;
          lp_ttdv_tbl(l_ttdv_count).tax_status_code                        	:= orig_ttd_rec.tax_status_code;
          lp_ttdv_tbl(l_ttdv_count).tax_apportionment_line_number          	:= orig_ttd_rec.tax_apportionment_line_number;
          lp_ttdv_tbl(l_ttdv_count).legal_entity_id                        	:= orig_ttd_rec.legal_entity_id;
          lp_ttdv_tbl(l_ttdv_count).trx_number                             	:= orig_ttd_rec.trx_number;
          lp_ttdv_tbl(l_ttdv_count).trx_date                               	:= orig_ttd_rec.trx_date;
          lp_ttdv_tbl(l_ttdv_count).tax_jurisdiction_id                    	:= orig_ttd_rec.tax_jurisdiction_id;
          lp_ttdv_tbl(l_ttdv_count).tax_jurisdiction_code                  	:= orig_ttd_rec.tax_jurisdiction_code;
          lp_ttdv_tbl(l_ttdv_count).tax_type_code                          	:= orig_ttd_rec.tax_type_code;
          lp_ttdv_tbl(l_ttdv_count).tax_currency_code                      	:= orig_ttd_rec.tax_currency_code;
          lp_ttdv_tbl(l_ttdv_count).taxable_amt_tax_curr                   	:= orig_ttd_rec.taxable_amt_tax_curr;
          lp_ttdv_tbl(l_ttdv_count).trx_currency_code                      	:= orig_ttd_rec.trx_currency_code;
          lp_ttdv_tbl(l_ttdv_count).minimum_accountable_unit               	:= orig_ttd_rec.minimum_accountable_unit;
          lp_ttdv_tbl(l_ttdv_count).precision                              	:= orig_ttd_rec.precision;
          lp_ttdv_tbl(l_ttdv_count).currency_conversion_type               	:= orig_ttd_rec.currency_conversion_type;
          lp_ttdv_tbl(l_ttdv_count).currency_conversion_rate               	:= orig_ttd_rec.currency_conversion_rate;
          lp_ttdv_tbl(l_ttdv_count).currency_conversion_date               	:= orig_ttd_rec.currency_conversion_date;
	  -- Modified by dcshanmu for eBTax - modification end

          l_taxable_amount := orig_ttd_rec.taxable_amt * l_cm_ratio;
          lp_ttdv_tbl(l_ttdv_count).taxable_amt :=
                               okl_accounting_util.cross_currency_round_amount
                                 (p_amount        => l_taxable_amount,
                                  p_currency_code => l_curr_code);

           l_tax_amount := orig_ttd_rec.tax_amt * l_cm_ratio;
           lp_ttdv_tbl(l_ttdv_count).tax_amt :=
                               okl_accounting_util.cross_currency_round_amount
                                 (p_amount        => l_tax_amount,
                                  p_currency_code => l_curr_code);

        END LOOP;

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details ');
          END;
        END IF;

        -- Create Tax Details Record
        OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_ttdv_tbl       => lp_ttdv_tbl,
          x_ttdv_tbl       => lx_ttdv_tbl);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF(IS_DEBUG_PROCEDURE_ON) THEN
          BEGIN
            OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details ');
          END;
        END IF;

      END LOOP;

    END IF;
    --End code changes for Tax API call by varao on 05/04/2005
  END IF;
   */
    --ebtax impact on billing akrangan commented code ends here
  --Bug# 4488818: Changes for Rollover, Release Billing: End

    /*IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
         NULL;
       	 --RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
      END IF;
    END IF;*/

  --Bug# 4488818: Changes for Upfront Sales Tax: Start
  -- Tax only invoice - Line Amount is equal to zero.
  ELSE
    NULL;
   --Bug# 4622963: Changes for Mass Rebook: Start
   --check for mass rebook contract
   --akrangan ebtax billing impacts start here
   /*
   l_mass_rbk_khr := '?';
   OPEN l_chk_mass_rbk_csr (p_chr_id => l_acct_call_rec.khr_id,
                            p_trx_id => p_bpd_acc_rec.source_trx_id);
   FETCH l_chk_mass_rbk_csr INTO l_mass_rbk_khr;
   CLOSE l_chk_mass_rbk_csr;

   -- Populate Tax Details Record
    l_ttdv_count := 0;

   --If Mass Rebook

   IF l_mass_rbk_khr = '!' THEN

     -- Fetch all Upfront Tax Lines.
     -- Upfront Tax is always to be Billed for Mass Rebook

     FOR tax_details_line_rec IN
         tax_details_line3_csr(p_khr_id => l_acct_call_rec.khr_id,
                               p_trx_id => p_bpd_acc_rec.source_trx_id)
     LOOP
       l_ttdv_count :=  l_ttdv_count + 1;
       lp_ttdv_tbl(l_ttdv_count).tax_amt := tax_details_line_rec.tax_amt;
       lp_ttdv_tbl(l_ttdv_count).taxable_amt := tax_details_line_rec.taxable_amt;
       lp_ttdv_tbl(l_ttdv_count).tax_rate_code := tax_details_line_rec.tax_rate_code;
       lp_ttdv_tbl(l_ttdv_count).tax_call_type_code := 'TAX_ONLY_INVOICE_TAX';
     END LOOP;
   --Bug# 4622963: Changes for Mass Rebook: End

   ELSE

    OPEN upfront_tax_csr(p_khr_id => l_acct_call_rec.khr_id);
    FETCH upfront_tax_csr INTO upfront_tax_rec;
    CLOSE upfront_tax_csr;

    -- Contract Level Asset Upfront Tax is set to 'BILLED'
    IF (upfront_tax_rec.asset_upfront_tax = 'BILLED') THEN

      -- Fetch Tax Lines for Assets having Line level Asset Upfront Tax
      -- Rule undefined or set to 'BILLED'.
      FOR tax_details_line_rec IN
          tax_details_line1_csr(p_khr_id => l_acct_call_rec.khr_id,
                                p_trx_id => p_bpd_acc_rec.source_trx_id)
      LOOP
         l_ttdv_count :=  l_ttdv_count + 1;
         lp_ttdv_tbl(l_ttdv_count).tax_amt := tax_details_line_rec.tax_amt;
         lp_ttdv_tbl(l_ttdv_count).taxable_amt := tax_details_line_rec.taxable_amt;
         lp_ttdv_tbl(l_ttdv_count).tax_rate_code := tax_details_line_rec.tax_rate_code;
         lp_ttdv_tbl(l_ttdv_count).tax_call_type_code := 'TAX_ONLY_INVOICE_TAX';
      END LOOP;

    -- Contract Level Asset Upfront Tax is not set to 'BILLED'
    ELSE

      -- Fetch Tax Lines for Assets having Line level Asset Upfront Tax
      -- Rule set to 'BILLED'.
      FOR tax_details_line_rec IN
          tax_details_line2_csr(p_khr_id => l_acct_call_rec.khr_id,
                                p_trx_id => p_bpd_acc_rec.source_trx_id)
      LOOP
         l_ttdv_count :=  l_ttdv_count + 1;
         lp_ttdv_tbl(l_ttdv_count).tax_amt := tax_details_line_rec.tax_amt;
         lp_ttdv_tbl(l_ttdv_count).taxable_amt := tax_details_line_rec.taxable_amt;
         lp_ttdv_tbl(l_ttdv_count).tax_rate_code := tax_details_line_rec.tax_rate_code;
         lp_ttdv_tbl(l_ttdv_count).tax_call_type_code := 'TAX_ONLY_INVOICE_TAX';
      END LOOP;

    END IF;
   END IF;
   */
   --akrangan ebtax billing impacts end here

 --akrangan ebtax billing impacts start
  /*  IF (l_ttdv_count > 0) THEN

      -- Populate Tax Sources Record
      lp_txsv_rec.khr_id := l_acct_call_rec.khr_id;
      lp_txsv_rec.trx_id := l_acct_call_rec.header_id;
      lp_txsv_rec.trx_line_id := l_acct_call_rec.line_id;
      lp_txsv_rec.entity_code := 'OKL_TXL_AR_INV_LNS_B';
      lp_txsv_rec.event_class_code := 'SALES_TRANSACTION_TAX_QUOTE';
      lp_txsv_rec.trx_level_type := 'LINE';
      lp_txsv_rec.tax_call_type_code := 'TAX_ONLY_INVOICE_TAX';
      lp_txsv_rec.sty_id := l_acct_call_rec.sty_id;
      lp_txsv_rec.tax_line_status_code := 'ACTIVE';
      lp_txsv_rec.reported_yn := 'N';

      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call OKL_TAX_SOURCES_PUB.insert_tax_sources ');
        END;
      END IF;

      -- Create Tax Sources Record
      OKL_TAX_SOURCES_PUB.insert_tax_sources(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_txsv_rec       => lp_txsv_rec,
        x_txsv_rec       => lx_txsv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call OKL_TAX_SOURCES_PUB.insert_tax_sources ');
        END;
      END IF;

      -- Populate txs_id in lp_ttdv_tbl
      FOR l_count IN lp_ttdv_tbl.FIRST..lp_ttdv_tbl.LAST
      LOOP
        lp_ttdv_tbl(l_count).txs_id := lx_txsv_rec.id;
      END LOOP;

      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRACCB.pls call OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details ');
        END;
      END IF;

      -- Create Tax Details Record
      OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_ttdv_tbl       => lp_ttdv_tbl,
        x_ttdv_tbl       => lx_ttdv_tbl);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRACCB.pls call OKL_TAX_TRX_DETAILS_PUB.insert_tax_trx_details ');
        END;
      END IF;

    END IF; */
     --akrangan ebtax billing impacts end
  END IF;
  --Bug# 4488818: Changes for Upfront Sales Tax: End

  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      Okl_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END create_acc_trans_new;



END Okl_Acc_Call_Pvt;

/
