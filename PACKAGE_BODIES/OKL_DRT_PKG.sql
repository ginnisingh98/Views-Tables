--------------------------------------------------------
--  DDL for Package Body OKL_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DRT_PKG" as
/* $Header: OKLDRTPB.pls 120.0.12010000.11 2018/07/19 07:24:18 amansinh noship $ */
--
-- Package Variables
--

g_module VARCHAR2(255) := 'okl.la.plsql.okl_drt_pkg';
g_debug_enabled CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
g_is_debug_statement_on BOOLEAN;
g_app_name         VARCHAR2(3) :='OKL';
g_invalid_value    VARCHAR2(30) :='OKL_NOT_VALID_PARTY';
g_party_not_person VARCHAR2(30) :='OKL_PARTY_NOT_PERSON';
g_open_contracts   VARCHAR2(30) :='OKL_OPEN_LEASE_CONTRACT';
g_open_asset_return VARCHAR2(30) :='OKL_OPEN_ASSET_RETURN';
g_open_template     VARCHAR2(30) :='OKL_OPEN_CON_TEMPLATE';
g_open_lease_quote  VARCHAR2(30) :='OKL_OPEN_LEASE_QUOTE';
g_open_lease_app    VARCHAR2(30):= 'OKL_OPEN_LEASE_APP';
g_open_mast_lease_agtrmnt VARCHAR2(30) :='OKL_OPEN_MASTER_LEASE_AGRMNT';
g_open_credit_line  VARCHAR2(30) :='OKL_OPEN_CREDIT_LINE';
g_open_ta_contract VARCHAR2(30) :='OKL_OPEN_TA_CONTRACT';
g_open_subsidy VARCHAR2(30) :='OKL_OEPN_SUBSIDY';
g_open_subsidy_pool VARCHAR2(30) :='OKL_OPEN_SUBSIDY_POOL';
g_open_prog_agtrmnt VARCHAR2(30) :='OKL_OPEN_VEND_PRG_AGRMNT';
g_open_oper_agrmnt VARCHAR2(30) :='OKL_OPEN_OPER_AGRMNT';
g_open_pre_fund_pool VARCHAR2(30) :='OKL_OPEN_PREFUND_POOL';
g_open_third_party_ins  VARCHAR2(30) :='OKL_OPEN_THIRD_PARTY_INS';
g_open_investor_agrmnt VARCHAR2(30) :='OKL_OPEN_INVESTOR_AGRMNT';
g_open_funding_request VARCHAR2(30) :='OKL_OPEN_FUNDING_REQUEST';
g_open_contract_sup VARCHAR2(30) :='OKL_OPEN_LEASE_CONTRACT_SUP';
g_open_template_sup VARCHAR2(30) :='OKL_OPEN_CON_TEMPLATE_SUP';
g_open_lease_qte_sup VARCHAR2(30) :='OKL_OPEN_LEASE_QUOTE_SUP';
g_open_lease_app_sup VARCHAR2(30) :='OKL_OPEN_LEASE_APP_SUP';
g_open_ta_contract_sup VARCHAR2(30) :='OKL_OPEN_TA_CONTRACT_SUP';
g_open_contract_lh VARCHAR2(30) :='OKL_OPEN_LEASE_CONTRACT_LH';
g_open_template_lh VARCHAR2(30) :='OKL_OPEN_CON_TEMPLATE_LH';
g_open_ta_contract_lh VARCHAR2(30) :='OKL_OPEN_TA_CONTRACT_LH';
g_open_contract_th VARCHAR2(30) :='OKL_OPEN_LEASE_CONTRACT_TH';
g_open_template_th VARCHAR2(30) :='OKL_OPEN_CON_TEMPLATE_TH';
g_open_ta_contract_th VARCHAR2(30) :='OKL_OPEN_TA_CONTRACT_TH';
g_open_contract_tc VARCHAR2(30) :='OKL_OPEN_LEASE_CONTRACT_TC';
g_open_template_tc VARCHAR2(30) :='OKL_OPEN_CON_TEMPLATE_TC';
g_open_ta_contract_tc VARCHAR2(30) :='OKL_OPEN_TA_CONTRACT_TC';
g_open_contract_pl VARCHAR2(30) :='OKL_OPEN_LEASE_CONTRACT_PL';
g_open_template_pl VARCHAR2(30) :='OKL_OPEN_CON_TEMPLATE_PL';
g_open_ta_contract_pl VARCHAR2(30) :='OKL_OPEN_TA_CONTRACT_PL';

------------------------------------------------------------------------------
-- PROCEDURE print_debug
--
--  This procedure logs debug message
--
------------------------------------------------------------------------------
PROCEDURE print_debug (p_message IN VARCHAR2) IS
BEGIN
  IF (G_DEBUG_ENABLED = 'Y' AND G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, p_message);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG, '** EXCEPTION IN print_line: '||SQLERRM);
END print_debug;

-- ----------------------------------------------------------------------------
-- Description:
--  Data removal contraints (DRC) procedure for person type : TCA
-- Business Logic validations before deleting a TCA person like customer or vendor or title custodian
-- or title holder or lien holder or agent or private label
-- --------------------------------------------------------------------------------------
PROCEDURE okl_tca_drc
  (p_person_id						IN			NUMBER,
  result_tbl             OUT NOCOPY per_drt_pkg.result_tbl_type
 )
 IS
  --
  -- Declare cursors and local variables
  --
   l_proc							varchar2(72) :='okl_tca_drc';
	 l_temp							varchar2(20);
   n									number;
   l_vendor_id        number;
   l_pre_fund_tbl_cnt number;

   CURSOR get_per_vendor_id IS
   SELECT  asp.vendor_id
   FROM    ap_suppliers asp
         , hz_parties hp
   WHERE   asp.party_id = hp.party_id
   AND     hp.party_id = p_person_id;

CURSOR chk_pre_fund_app IS
   SELECT  count(1)
   FROM    all_tables
   WHERE   owner = (SELECT  application_short_name
                    FROM    fnd_application
                    WHERE   application_id = 540)
   AND     table_name = 'OKL_PREFUND_POOLS_ALL';
 TYPE l_ref_csr_type IS REF CURSOR;
 l_pre_fund_csr        l_ref_csr_type;
 l_query_string varchar2(2000);
 l_row_not_found             BOOLEAN := FALSE;

BEGIN

  IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  print_debug('Entering: '||l_proc);
  print_debug('p_person_id: '||p_person_id);


  -- Validate p_person_id param
 	begin
		SELECT  NULL
		INTO    l_temp
		FROM    sys.dual
		WHERE   EXISTS
					(
					   SELECT  NULL
						FROM    hz_parties
						WHERE   party_id = p_person_id
					);
	exception
    when NO_DATA_FOUND then
        print_debug('Status : E, msgcode : '||g_invalid_value);
        per_drt_pkg.add_to_results (person_id => p_person_id,
                                    entity_type => 'TCA',
                                    status => 'E',
                                    msgcode => g_invalid_value,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        return;
  end;

  -- Rule : Cannot mask if party=organization
 	begin
		SELECT  NULL
		INTO    l_temp
		FROM    sys.dual
		WHERE   EXISTS
					(
					   SELECT  NULL
						FROM    hz_parties
						WHERE   party_id = p_person_id
						AND     party_type = 'PERSON'
					);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_party_not_person,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_party_not_person);
        return;
  end;

  -- Rule : Mask if contract status is expired, terminated, cancelled, or abandoned for customer
	begin
		SELECT  NULL
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
					(
					      SELECT  NULL
								FROM  okc_k_headers_all_b okc
									  , hz_cust_accounts hca
									  , hz_parties hp
								WHERE   okc.cust_acct_id = hca.cust_account_id
								AND     hca.party_id = hp.party_id
								AND     hp.party_id = p_person_id
								AND     okc.scs_code = 'LEASE'
								AND     okc.sts_code NOT IN ('EXPIRED','TERMINATED','CANCELLED','ABANDONED')
					);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_contracts,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_contracts);
  end;


  --Check whether the Asset status = Available for sale, Manual Release, Released, Remarketed,
  -- Repurchased, Scrapped or not for customer
	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
        		(
        		SELECT NULL
						FROM  okc_k_headers_all_b okc
							  , hz_cust_accounts hca
							  , hz_parties hp
							  , okc_k_lines_b okl
							  , okl_asset_returns_all_b oar
						WHERE   okc.cust_acct_id = hca.cust_account_id
						AND     hca.party_id = hp.party_id
						AND     hp.party_id = p_person_id
						AND     okc.id = okl.dnz_chr_id
						AND     okc.scs_code = 'LEASE'
						AND     okl.lse_id = 33
						AND     okl.id = oar.kle_id
						AND     oar.ars_code NOT IN ('AVAILABLE_FOR_SALE','RE_LEASE','RELEASE_IN_PROCESS'
													,'REMARKETED','REPURCHASE','SCRAPPED','RETURNED'
													,'REPOSSESSED', 'CANCELLED')
        		);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_asset_return,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_asset_return);
  end;

  -- Rule : Mask if contract template is abandoned
	begin
		SELECT  NULL
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
					(
					    SELECT NULL
							FROM  okc_k_headers_all_b okc
								  , hz_cust_accounts hca
								  , hz_parties hp
							WHERE   okc.cust_acct_id = hca.cust_account_id
							AND     hca.party_id = hp.party_id
							AND     hp.party_id = p_person_id
							AND     okc.scs_code = 'LEASE'
							AND     okc.template_yn = 'Y'
							AND     okc.sts_code NOT IN ('ABANDONED')
					);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_template,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_template);
  end;


   -- Rule : Mask if lease quote status is accepted and converted to contract for customer
	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						    SELECT NULL
								FROM    okl_lease_quotes_b lsq
									    , okl_lease_opps_all_b lop
								WHERE   lsq.parent_object_code = 'LEASEOPP'
								AND     lop.id = lsq.parent_object_id
								AND     lsq.status = 'CT-ACCEPTED'
								AND     lop.prospect_id = p_person_id
								AND     NOT EXISTS
											(
											SELECT  1
											FROM    OKL_LEASE_APPS_ALL_B
											WHERE   lease_opportunity_id = lop.id
											AND     application_status <> 'WITHDRAWN'
											)
								AND     NOT EXISTS
											(
											SELECT  1
											FROM    okc_k_headers_all_b
											WHERE   orig_system_source_code = 'OKL_QUOTE'
											AND     orig_system_id1 = lsq.id
											AND     sts_code <> 'ABANDONED'
											)
						);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_lease_quote,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_lease_quote);
  end;


  -- Rule : Mask if  status is converted to contract or withdrawn for customer
 /*	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						  SELECT  NULL
							FROM    okl_lease_apps_all_b lap
							      , okl_lease_quotes_b lsq
							      , okl_assets_b oab
							      , okl_asset_components_b oabc
							      , po_vendors vend
							WHERE   oab.parent_object_code = 'LEASEQUOTE'
							AND     oab.parent_object_id = lsq.id
							AND     lap.application_status <> 'WITHDRAWN'
							AND     oab.id = oabc.asset_id
							AND     oabc.primary_component = 'YES'
							AND     oabc.supplier_id = vend.vendor_id
							AND     lsq.parent_object_code = 'LEASEAPP'
							AND     lsq.parent_object_id = lap.id
							AND     oabc.supplier_id = l_vendor_id
							UNION
							SELECT  NULL
							FROM    okl_lease_quotes_b lsq
							      , okl_lease_apps_all_b lap
							      , okl_fees_b ofe
							      , po_vendors vend
							WHERE   ofe.parent_object_code = 'LEASEQUOTE'
							AND     ofe.parent_object_id = lsq.id
							AND     ofe.supplier_id = vend.vendor_id
							AND     lsq.parent_object_code = 'LEASEAPP'
							AND     lsq.parent_object_id = lap.id
							AND     lap.application_status <> 'WITHDRAWN'
							AND     ofe.supplier_id = l_vendor_id
						);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_lease_app,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_lease_app);
  end;
  */

   -- Rule : Mask if MLA status is abandoned, expired or terminated.
	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						SELECT  NULL
						FROM    okc_k_headers_all_b chrb
							  , okl_k_headers khr
							  , okc_k_party_roles_b prole
						WHERE   khr.id = chrb.id
						AND     chrb.scs_code = 'MASTER_LEASE'
						AND     prole.chr_id = chrb.id
						AND     prole.jtot_object1_code = 'OKX_PARTY'
						AND     prole.object1_id1 = to_char(p_person_id) --changed by amansinh for bug 28205711
						AND     chrb.STS_CODE NOT IN ('ABANDONED','EXPIRED','TERMINATED')
					  );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_mast_lease_agtrmnt,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_mast_lease_agtrmnt);
  end;


   --Rule: Mask if credit line status is rejected for customer
	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						 SELECT NULL
							FROM    okc_k_headers_all_b chrb
									  , okl_k_headers khr
									  , okx_customer_accounts_v cust_acct
									  , okc_rules_b rul
									  , okx_parties_v party
									  , okc_k_party_roles_b cpl
									  , okx_cust_site_uses_v site
									  , okc_statuses_v status
									  , fnd_currencies_vl curr
									  , gl_daily_conversion_types_v dct
									  , fnd_lookups okl_yn
								WHERE   chrb.id = khr.id
								AND     chrb.scs_code = 'CREDITLINE_CONTRACT'
								AND     cust_acct.id1 (+) = chrb.cust_acct_id
								AND     cust_acct.id2 (+) = '#'
								AND     rul.rule_information_category (+) = 'LACCLT'
								AND     rul.dnz_chr_id (+) = chrb.id
								AND     party.id1 = to_number(trim(cpl.object1_id1)) --changed by amansinh for bug 28205711
								AND     party.id2 = cpl.object1_id2
								AND     cpl.rle_code = 'LESSEE'
								AND     cpl.chr_id = chrb.id
								AND     cpl.dnz_chr_id = chrb.id -- added by amansinh for bug 28205711
								AND     site.site_use_code (+) = 'LEGAL'
								AND     site.cust_account_id (+) = cust_acct.id1
								AND     cust_acct.party_id = p_person_id
								AND     chrb.sts_code = status.code
								AND     (chrb.sts_code NOT IN ('APPROVAL_REJECTED')
								         AND  chrb.end_date >= sysdate)
								AND     chrb.currency_code = curr.currency_code
								AND     dct.conversion_type (+) = khr.currency_conversion_type
								AND     okl_yn.lookup_code = khr.revolving_credit_yn
								AND     okl_yn.lookup_type = 'OKL_YES_NO' --Changed by amansinh for bug 28205711
						);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_credit_line,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_credit_line);
  end;

    --Rule: Mask original contract if T and A contract is inactive for customer
    begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
							SELECT  NULL
							FROM    okc_k_headers_all_b old_khr
								  , okc_k_headers_all_b new_khr
								  , hz_cust_accounts hca
								  , hz_parties hp
							WHERE   old_khr.id = new_khr.orig_system_id1
							AND     old_khr.cust_acct_id = hca.cust_account_id
							AND     hca.party_id = hp.party_id
							AND     hp.party_id = p_person_id
							AND     old_khr.scs_code = 'LEASE'
							AND     new_khr.orig_system_source_code = 'OKL_RELEASE'
							AND     new_khr.scs_code = 'LEASE'
							AND     new_khr.sts_code NOT IN ('EXPIRED', 'TERMINATED', 'CANCELLED', 'ABANDONED')
						);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_ta_contract,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_ta_contract);
    end;



    -- Validate vendor contraints
	  l_vendor_id :=NULL;

    OPEN  get_per_vendor_id;
    FETCH get_per_vendor_id INTO l_vendor_id;
    CLOSE get_per_vendor_id;
    -- start of vendor contrainsts check
  IF l_vendor_id IS NOT NULL THEN
	-- Rule : Mask if contract status is expired, terminated, cancelled, or abandoned for vendor
	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						SELECT  NULL
						  FROM    okc_k_headers_all_b okc
								    , okc_k_party_roles_b kpr
						  WHERE   okc.id = kpr.dnz_chr_id
						  AND     kpr.rle_code = 'OKL_VENDOR'
						  AND     kpr.object1_id1 = to_char(l_vendor_id) --changed by amansinh for bug 28205711
						  AND     okc.scs_code = 'LEASE'
						  AND     okc.sts_code NOT IN ('EXPIRED', 'TERMINATED', 'CANCELLED', 'ABANDONED')
					  );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_contract_sup,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_contract_sup);
    end;

  -- Rule : Mask if contract template is abandoned for vendor
	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						  SELECT  NULL
						  FROM    okc_k_headers_all_b okc
								    , okc_k_party_roles_b kpr
						  WHERE   okc.id = kpr.dnz_chr_id
						  AND     kpr.rle_code = 'OKL_VENDOR'
						  AND     kpr.object1_id1 = to_char(l_vendor_id) --changed by amansinh for bug 28205711
						  AND     okc.scs_code = 'LEASE'
						  AND     okc.template_yn = 'Y'
						  AND     okc.sts_code NOT IN ('ABANDONED')
		                );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_template_sup,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_template_sup);
  end;

    -- Rule : Mask if lease quote status is accepted and converted to contract for vendor
	begin
	SELECT  NULL
        INTO    l_temp
        FROM    sys.dual
        WHERE   NOT EXISTS
            (
            SELECT  NULL
            FROM    (
                    SELECT  lop.id lease_opp_id
                          , lsq.parent_object_id lease_quote_id
                    FROM    okl_lease_quotes_b lsq
                          , okl_lease_opps_all_b lop
                    WHERE   lsq.parent_object_code = 'LEASEOPP'
                    AND     lop.id = lsq.parent_object_id
                    AND     lsq.status = 'CT-ACCEPTED'
                    AND     lop.supplier_id = l_vendor_id
                    UNION
                    SELECT  lop.id lease_opp_id
                          , lsq.parent_object_id lease_quote_id
                    FROM    okl_lease_quotes_b lsq
                          , okl_lease_opps_all_b lop
                          , okl_assets_b oab
                          , okl_asset_components_b oabc
                          , po_vendors vend
                    WHERE   lsq.parent_object_code = 'LEASEOPP'
                    AND     lop.id = lsq.parent_object_id
                    AND     oab.parent_object_id = lsq.id
                    AND     lsq.status = 'CT-ACCEPTED'
                    AND     oab.parent_object_code = 'LEASEQUOTE'
                    AND     oab.id = oabc.asset_id
                    AND     oabc.supplier_id = vend.vendor_id
                    AND     oabc.supplier_id = l_vendor_id
                    UNION
                    SELECT  lop.id lease_opp_id
                          , lsq.parent_object_id lease_quote_id
                    FROM    okl_lease_quotes_b lsq
                          , okl_lease_opps_all_b lop
                          , okl_fees_b ofe
                          , po_vendors vend
                    WHERE   lsq.parent_object_code = 'LEASEOPP'
                    AND     lop.id = lsq.parent_object_id
                    AND     lsq.status = 'CT-ACCEPTED'
                    AND     ofe.parent_object_id = lsq.id
                    AND     ofe.parent_object_code = 'LEASEQUOTE'
                    AND     ofe.supplier_id = vend.vendor_id
                    AND     ofe.supplier_id = l_vendor_id
                    UNION
                    SELECT  lop.id lease_opp_id
                          , lsq.parent_object_id lease_quote_id
                    FROM    okl_lease_quotes_b lsq
                          , okl_lease_opps_all_b lop
                          , okl_services_b osb
                          , po_vendors vend
                    WHERE  lsq.parent_object_code = 'LEASEOPP'
                    AND     lop.id = lsq.parent_object_id
                    AND     osb.parent_object_id = lsq.id
                    AND     osb.parent_object_code = 'LEASEQUOTE'
                    AND     lsq.status = 'CT-ACCEPTED'
                    AND    vend.vendor_id   = osb.supplier_id
                    AND    osb.supplier_id = l_vendor_id
                    ) llq
            WHERE   NOT EXISTS
                        (
                        SELECT  1
                        FROM    okl_lease_apps_all_b
                        WHERE   lease_opportunity_id = llq.lease_opp_id
                        AND     application_status NOT IN ('WITHDRAWN','CANCELED')
                        UNION
                        SELECT  1
                        FROM    okc_k_headers_all_b
                        WHERE   orig_system_source_code = 'OKL_QUOTE'
                        AND     orig_system_id1 = llq.lease_quote_id
                        AND     sts_code <> 'ABANDONED')
            );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_lease_qte_sup,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_lease_qte_sup);
    end;

	-- Rule : Mask if Lease App status is converted to contract or withdrawn for vendor
	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
							SELECT  NULL
							FROM    okl_lease_apps_all_b lap
							      , okl_lease_quotes_b lsq
							      , okl_assets_b oab
							      , okl_asset_components_b oabc
							      , po_vendors vend
							WHERE   oab.parent_object_code = 'LEASEQUOTE'
							AND     oab.parent_object_id = lsq.id
							AND     lap.application_status NOT IN ('WITHDRAWN', 'CONV-K', 'CANCELED')
							AND     oab.id = oabc.asset_id
							AND     oabc.primary_component = 'YES'
							AND     oabc.supplier_id = vend.vendor_id
							AND     lsq.parent_object_code = 'LEASEAPP'
							AND     lsq.parent_object_id = lap.id
							AND     oabc.supplier_id = l_vendor_id
							UNION
							SELECT  NULL
							FROM    okl_lease_quotes_b lsq
							      , okl_lease_apps_all_b lap
							      , okl_fees_b ofe
							      , po_vendors vend
							WHERE   ofe.parent_object_code = 'LEASEQUOTE'
							AND     ofe.parent_object_id = lsq.id
							AND     ofe.supplier_id = vend.vendor_id
							AND     lsq.parent_object_code = 'LEASEAPP'
							AND     lsq.parent_object_id = lap.id
							AND     lap.application_status NOT IN ('WITHDRAWN', 'CONV-K', 'CANCELED')
							AND     ofe.supplier_id = l_vendor_id
							UNION
							SELECT  NULL
							FROM    okl_lease_quotes_b lsq
							      , okl_lease_apps_all_b lap
							      , okl_services_b osb
							      , po_vendors vend
							WHERE   osb.parent_object_code = 'LEASEQUOTE'
							AND     osb.parent_object_id = lsq.id
							AND     osb.supplier_id = vend.vendor_id
							AND     lsq.parent_object_code = 'LEASEAPP'
							AND     lsq.parent_object_id = lap.id
							AND     lap.application_status NOT IN ('WITHDRAWN', 'CONV-K', 'CANCELED')
							AND     osb.supplier_id = l_vendor_id
		        );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_lease_app_sup,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_lease_app_sup);
    end;

	--Rule: Cannot mask if Subsidy effective dates or expired date for vendor
	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						   SELECT  NULL
							FROM    okl_subsidies_all_b sub
								    , po_vendors pov
							WHERE   pov.vendor_id = l_vendor_id
							AND     pov.vendor_id = sub.vendor_id
							AND     (sub.effective_to_date >= sysdate
									 OR sub.effective_from_date + sub.expire_after_days >= sysdate)
 		                );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_subsidy,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_subsidy);
    end;

	--Rule:  Subsidy Pool <> cancelled, rejected or expired for vendor
	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						   SELECT  NULL
							FROM   okl_subsidy_pools_b subp
								  , okl_subsidy_pools_b report_pool
								  , fnd_lookups flk1
							WHERE   subp.subsidy_pool_id = report_pool.id (+)
							AND     flk1.lookup_type (+) = 'OKL_SUBSIDY_POOL_STATUS'
							AND     flk1.lookup_code (+) = subp.decision_status_code
								AND     subp.decision_status_code NOT IN ('EXPIRED', 'CANCELED', 'REJECTED')
							AND  EXISTS
								(SELECT  'x'
								 FROM    okl_subsidies_all_b sub,
										     po_vendors pov
								 WHERE   subsidy_pool_id = subp.id
								 AND     pov.vendor_id = sub.vendor_id
								 AND     pov.vendor_id = l_vendor_id
								 AND     (sub.effective_to_date >= SYSDATE
                   OR sub.effective_from_date + sub.expire_after_days >= sysdate)
								)
 		                );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_subsidy_pool,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_subsidy_pool);
    end;


	--Rule: Mask if VPA status is abandoned, expired or terminated for vendor
	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						   SELECT   NULL
						   FROM okc_k_headers_all_b chrb
								  , okc_statuses_b stsb
								  , okc_k_party_roles_b kpr
								  , po_vendors pov
								  , fnd_lookups fnd
								  , okl_k_headers khr
							WHERE   stsb.code (+) = chrb.sts_code
							AND     (       chrb.id = kpr.dnz_chr_id (+)
									AND     kpr.rle_code (+) = 'OKL_VENDOR'
									)
							AND     to_number(trim(kpr.object1_id1)) = pov.vendor_id (+) --changed by amansinh for bug 28205711
							AND     pov.vendor_id = l_vendor_id
							AND     scs_code = 'PROGRAM'
							AND     fnd.lookup_type = 'OKC_YN'
							AND     fnd.lookup_code = chrb.template_yn
							AND     chrb.id = khr.id
							AND     khr.crs_id IS NULL
							AND     chrb.sts_code NOT IN ('ABANDONED','EXPIRED','TERMINATED')
 		                );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_prog_agtrmnt,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_prog_agtrmnt);
    end;

	    --Rule : Mask if Op Agmt is abandoned or expired for vendor
	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						   SELECT  NULL
							FROM    okc_k_headers_all_b chrb
								  , okc_statuses_b stsb
								  , okc_k_party_roles_b kpr
								  , po_vendors pov
								  , fnd_lookups fnd
								  , okl_k_headers khr
							WHERE   stsb.code (+) = chrb.sts_code
							 AND     (
											chrb.id = kpr.dnz_chr_id (+)
									AND     kpr.rle_code (+) = 'OKL_VENDOR'
									)
							AND     to_number(trim(kpr.object1_id1)) = pov.vendor_id (+) --changed by amansinh for bug 28205711
							AND     pov.vendor_id = l_vendor_id
							AND     scs_code = 'OPERATING'
							AND     fnd.lookup_type = 'OKC_YN'
							AND     fnd.lookup_code = chrb.template_yn
							AND     chrb.id = khr.id
							AND     khr.crs_id IS NULL
							AND     chrb.sts_code NOT IN ('ABANDONED','EXPIRED')

 		                );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_oper_agrmnt,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_oper_agrmnt);
    end;

  -- Verify pre fund pool constraint check is applicable. Prefund pool is applicable from 12.2.5 onwards
  l_pre_fund_tbl_cnt :=0;
  OPEN chk_pre_fund_app;
  FETCH chk_pre_fund_app INTO l_pre_fund_tbl_cnt;
  CLOSE chk_pre_fund_app;
  --Rule: Mask if prefunding pool is cancalled, rejected or terminated for vendor
  IF l_pre_fund_tbl_cnt > 0 THEN
    l_query_string :='SELECT  null '||
  		' FROM   sys.dual '||
		  ' WHERE   NOT EXISTS ( '||
							' SELECT  NULL '||
							' FROM    okl_prefund_pools_all opfp '||
							'	  , po_vendors povpp '||
							'	  , xle_le_ou_ledger_v xle '||
							'	  , hz_cust_accounts custacct '||
							'	  , okx_payables_terms_v payterm '||
							'	  , ra_terms_vl billterm '||
							'	  , okx_vendor_sites_v vsite '||
						  '	  , okx_cust_site_uses_v billaddr '||
							'	  , okc_k_headers_all_b chr '||
							'	  , okx_rcpt_method_accounts_v rcp_mth '||
							'	  , ar_receipt_methods rcpt '||
							'  WHERE   opfp.vendor_id = povpp.vendor_id '||
							'  AND     povpp.vendor_id = :l_vendor_id '||
							'  AND     opfp.legal_entity_id = xle.legal_entity_id '||
							'  AND     opfp.cust_account_id = custacct.cust_account_id '||
							'  AND     opfp.disb_payment_term_id = payterm.id1 '||
							'  AND     opfp.billing_pay_term_id = billterm.term_id '||
							'  AND     opfp.disb_pay_site_id = vsite.id1 '||
							'  AND     opfp.bill_to_site_use_id = billaddr.id1 '||
							'  AND     opfp.khr_id = chr.id '||
							'  AND     rcpt.name = opfp.billing_pay_method_code '||
							'  AND     opfp.payment_instr_id = rcp_mth.id1 (+) '||
							'  AND     opfp.pool_status NOT IN (''REJECTED'''||','||'''CANCELLED'''||','||'''TERMINATED'''||'))';

    OPEN l_pre_fund_csr FOR l_query_string USING l_vendor_id;
    FETCH l_pre_fund_csr INTO l_temp;
    l_row_not_found := l_pre_fund_csr%NOTFOUND;
    CLOSE l_pre_fund_csr;

    IF l_row_not_found THEN
        per_drt_pkg.add_to_results (person_id => l_vendor_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => 'g_open_pre_fund_pool',
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_pre_fund_pool);
    END IF;
  END IF;
  /*IF l_pre_fund_tbl_cnt > 0 THEN
	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
							SELECT  NULL
							FROM    okl_prefund_pools_all opfp
								  , po_vendors povpp
								  , xle_le_ou_ledger_v xle
								  , hz_cust_accounts custacct
								  , okx_payables_terms_v payterm
								  , ra_terms_vl billterm
								  , okx_vendor_sites_v vsite
								  , okx_cust_site_uses_v billaddr
								  , okc_k_headers_all_b chr
								  , okx_rcpt_method_accounts_v rcp_mth
								  , ar_receipt_methods rcpt
							  WHERE   opfp.vendor_id = povpp.vendor_id
							  AND     povpp.vendor_id = l_vendor_id
							  AND     opfp.legal_entity_id = xle.legal_entity_id
							  AND     opfp.cust_account_id = custacct.cust_account_id
							  AND     opfp.disb_payment_term_id = payterm.id1
							  AND     opfp.billing_pay_term_id = billterm.term_id
							  AND     opfp.disb_pay_site_id = vsite.id1
							  AND     opfp.bill_to_site_use_id = billaddr.id1
							  AND     opfp.khr_id = chr.id
							  AND     rcpt.name = opfp.billing_pay_method_code
							  AND     opfp.payment_instr_id = rcp_mth.id1 (+)
							  AND     opfp.pool_status NOT IN ('REJECTED', 'CANCELLED', 'TERMINATED')
		           );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_pre_fund_pool,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_pre_fund_pool);
    end;
    END IF; */

    --Rule:  Mask original contract if T and A contract is inactive for vendor
    begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
							SELECT  NULL
							FROM    okc_k_headers_all_b old_khr
								  , okc_k_headers_all_b new_khr
								  , okc_k_party_roles_b kpr
							WHERE   old_khr.id = new_khr.orig_system_id1
							AND     old_khr.id = kpr.dnz_chr_id
							AND     kpr.rle_code = 'OKL_VENDOR'
							AND     kpr.object1_id1 = to_char(l_vendor_id) --changed by amansinh for bug 28205711
							AND     old_khr.scs_code = 'LEASE'
							AND     new_khr.orig_system_source_code = 'OKL_RELEASE'
							AND     new_khr.scs_code = 'LEASE'
							AND     new_khr.sts_code NOT IN ('EXPIRED', 'TERMINATED', 'CANCELLED', 'ABANDONED')
						);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_ta_contract_sup,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_ta_contract_sup);
    end;

    --Rule:  Mask if the funding request is cancelled or processed
    begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
							SELECT NULL
								FROM    OKL_TRX_AP_INVS_ALL_B h
								      , okl_trx_ap_invoices_tl hl
								      , po_vendors v
								      , po_vendor_sites_all vs
								      , fnd_currencies_tl lct
								      , fnd_lookups look1
								      , fnd_lookups look2
								      , fnd_lookups look3
								      , fnd_lookups look4
								      , ap_terms_v trm
								      , po_lookup_codes look5
								WHERE   h.id = hl.id
								AND     hl.language = userenv ('LANG')
								AND     h.ipvs_id = vs.vendor_site_id
								AND     vs.vendor_id = v.vendor_id
								AND     v.vendor_id  = l_vendor_id
								AND     h.currency_code = lct.currency_code
								AND     lct.language = userenv ('LANG')
								AND     h.payment_method_code = look1.lookup_code
								AND     look1.lookup_type = 'OKL_AP_PAYMENT_METHOD'
								AND     h.funding_type_code = look2.lookup_code
								AND     look2.lookup_type = 'OKL_FUNDING_TYPE'
								AND     h.trx_status_code = look3.lookup_code
								AND     look3.lookup_type = 'OKL_TRANSACTION_STATUS'
								AND     nvl (h.invoice_type, decode (h.funding_type_code, 'SUPPLIER_RETENTION'
								                                   , 'CREDIT', 'STANDARD')) = look4.lookup_code
								AND     look4.lookup_type = 'OKL_PAYABLES_INVOICE_TYPE'
								AND     h.pay_group_lookup_code = look5.lookup_code (+)
								AND     look5.lookup_type (+) = 'PAY GROUP'
								AND     h.ippt_id = trm.term_id (+)
								AND     h.funding_type_code NOT IN ('ASSET_SUBSIDY', 'EXPENSE_SUBSIDY')
								AND     h.TRX_STATUS_CODE NOT IN ('CANCELED','PROCESSED')
						);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_funding_request,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_funding_request);
    end;

    --Rule: Investor Agreement, Status <> Expired
	  begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
							SELECT  NULL
							FROM    okc_k_headers_all_b chrb
							      , okc_statuses_b stsb
							      , okc_statuses_tl stst
							      , okc_k_headers_tl chrt
							      , okl_k_headers khrb
							      , okl_products pdtb
							      , okl_pools_all polb
							      , fnd_currencies_vl curr
							      , fnd_lookups secl
							      , fnd_lookups serl
							      , fnd_lookups recl
							      , okx_vendors_v vend
							      , okc_k_party_roles_b cplb
							      , po_vendors pov
							WHERE   chrt.id = chrb.id
							AND     stst.code = chrb.sts_code
							AND     stst.code = stsb.code
							AND     stst.language = userenv ('LANG')
							AND     chrt.language = userenv ('LANG')
							AND     khrb.id = chrb.id
							AND     pdtb.id = khrb.pdt_id
							AND     chrb.currency_code = curr.currency_code
							AND     chrb.scs_code = 'INVESTOR'
							AND     chrb.id = polb.khr_id
							AND     polb.status_code NOT IN ('EXPIRED')
							AND     secl.lookup_type = 'OKL_SECURITIZATION_TYPE'
							AND     decode (khrb.securitization_type, 'SALE'
							              , 'SECURITIZATION', 'LOAN'
							              , 'SYNDICATION', 'SECURITIZATION'
							              , 'SECURITIZATION', 'SYNDICATION'
							              , 'SYNDICATION') = secl.lookup_code
							AND     serl.lookup_type = 'OKL_SEC_SERVICE_ORG'
							AND     khrb.lessor_serv_org_code = serl.lookup_code
							AND     recl.lookup_type = 'OKL_SEC_RECOURSE'
							AND     khrb.recourse_code = recl.lookup_code
							AND     chrb.id = cplb.chr_id
							AND     chrb.id = cplb.dnz_chr_id -- added by amansinh for bug 28205711
							AND     cplb.rle_code = 'TRUSTEE'
							AND     cplb.jtot_object1_code = 'OKX_VENDOR'
							AND     vend.id1 = to_number(trim(cplb.object1_id1)) --changed by amansinh for bug 28205711
							AND     vend.id2 = cplb.object1_id2
							AND     pov.vendor_id = vend.id1
							AND     pov.vendor_id = l_vendor_id
							AND     chrb.sts_code NOT IN ('EXPIRED')
						);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_investor_agrmnt,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_investor_agrmnt);
    end;

	END IF;


  --Rule: Contract <> Expired, Terminated, Cancelled or Abandoned for Lien Holder

	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						     SELECT NULL
							   FROM okc_k_headers_all_b okc,
									    okc_rule_groups_b orgb,
									    okc_rules_b orb
							  WHERE orb.object1_id1 = to_char(p_person_id) --changed by amansinh for bug 28205711
							  AND orb.jtot_object1_code = 'OKX_PARTY'
							  AND orb.rule_information_category = 'LAFLLN'
							  AND orgb.id = orb.rgp_id
							  AND orgb.rgd_code = 'LAAFLG'
							  AND okc.id = orgb.dnz_chr_id
							  AND okc.scs_code = 'LEASE'
							  AND okc.sts_code NOT IN ('EXPIRED','TERMINATED','CANCELLED','ABANDONED')
 		                );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_contract_lh,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_contract_lh);
    end;


	--Rule: Contract template  Abandoned for Lien Holder

	begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						     SELECT NULL
							   FROM okc_k_headers_all_b okc,
									    okc_rule_groups_b orgb,
									    okc_rules_b orb
							  WHERE orb.object1_id1 = to_char(p_person_id) --changed by amansinh for bug 28205711
							  AND orb.jtot_object1_code = 'OKX_PARTY'
							  AND orb.rule_information_category = 'LAFLLN'
							  AND orgb.id = orb.rgp_id
							  AND orgb.rgd_code = 'LAAFLG'
							  AND okc.id = orgb.dnz_chr_id
							  AND okc.scs_code = 'LEASE'
                              AND okc.template_yn = 'Y'
                              AND okc.sts_code NOT IN ('ABANDONED')
 		                );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_template_lh,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
 	    print_debug('Status : E, msgcode : '||g_open_template_lh);
    end;


	-- Rule : Mask original contract if T and A contract is inactive for Lien holder
	  begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
							SELECT  NULL
							FROM    okc_k_headers_all_b old_khr,
							    		okc_k_headers_all_b new_khr,
								    	okc_rule_groups_b orgb,
								    	okc_rules_b orb
							WHERE  orb.object1_id1 = to_char(p_person_id) --changed by amansinh for bug 28205711
							AND orb.jtot_object1_code = 'OKX_PARTY'
							AND orb.rule_information_category = 'LAFLLN'
							AND orgb.id = orb.rgp_id
							AND orgb.rgd_code = 'LAAFLG'
							AND old_khr.id = orgb.dnz_chr_id
							AND old_khr.id = new_khr.orig_system_id1
							AND old_khr.scs_code = 'LEASE'
							AND new_khr.orig_system_source_code = 'OKL_RELEASE'
							AND new_khr.scs_code = 'LEASE'
							AND new_khr.sts_code NOT IN ('EXPIRED', 'TERMINATED', 'CANCELLED', 'ABANDONED')
						);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_ta_contract_lh,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_ta_contract_lh);
    end;
    --Rule: Contract <> Expired, Terminated, Cancelled or Abandoned for Title Holder
    begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						     SELECT NULL
							   FROM okc_k_headers_all_b okc,
									    okc_rule_groups_b orgb,
									    okc_rules_b orb
							  WHERE orb.object1_id1 = to_char(p_person_id) --changed by amansinh for bug 28205711
							  AND orb.jtot_object1_code = 'OKX_PARTY'
							  AND orb.rule_information_category = 'LAFLTL'
							  AND orgb.id = orb.rgp_id
							  AND orgb.rgd_code = 'LAAFLG'
							  AND okc.id = orgb.dnz_chr_id
							  AND okc.scs_code = 'LEASE'
							  AND okc.sts_code NOT IN ('EXPIRED','TERMINATED','CANCELLED','ABANDONED')
 		                );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_contract_th,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_contract_th);
    end;

    --Rule: Title holder : Contract Template <> Abandoned
    begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						     SELECT NULL
							   FROM okc_k_headers_all_b okc,
									    okc_rule_groups_b orgb,
									    okc_rules_b orb
							  WHERE orb.object1_id1 = to_char(p_person_id) --changed by amansinh for bug 28205711
							  AND orb.jtot_object1_code = 'OKX_PARTY'
							  AND orb.rule_information_category = 'LAFLTL'
							  AND orgb.id = orb.rgp_id
							  AND orgb.rgd_code = 'LAAFLG'
							  AND okc.id = orgb.dnz_chr_id
							  AND okc.scs_code = 'LEASE'
                              AND okc.template_yn = 'Y'
                              AND okc.sts_code NOT IN ('ABANDONED')
 		                );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_template_th,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_template_th);
    end;

	 --Rule: Mask original contract if T and A contract is inactive for Title holder
	    begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
							SELECT  NULL
							FROM    okc_k_headers_all_b old_khr,
									    okc_k_headers_all_b new_khr,
									    okc_rule_groups_b orgb,
									    okc_rules_b orb
							WHERE  orb.object1_id1 = to_char(p_person_id) --changed by amansinh for bug 28205711
							AND orb.jtot_object1_code = 'OKX_PARTY'
							AND orb.rule_information_category = 'LAFLTL'
							AND orgb.id = orb.rgp_id
						 	AND orgb.rgd_code = 'LAAFLG'
							AND old_khr.id = orgb.dnz_chr_id
							AND old_khr.id = new_khr.orig_system_id1
							AND old_khr.scs_code = 'LEASE'
							AND new_khr.orig_system_source_code = 'OKL_RELEASE'
							AND new_khr.scs_code = 'LEASE'
							AND new_khr.sts_code NOT IN ('EXPIRED', 'TERMINATED', 'CANCELLED', 'ABANDONED')
						);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_ta_contract_th,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_ta_contract_th);
    end;

	--Rule: Title Custodian - Contract <> Expired, Terminated, Cancelled or Abandoned
    begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						  SELECT NULL
						   FROM okc_k_headers_all_b okc,
								   okc_rule_groups_b orgb,
								   okc_rules_b orb
						  WHERE orb.object2_id1 = p_person_id
						  AND orb.jtot_object2_code = 'OKX_PARTY'
						  AND orb.rule_information_category = 'LAFLTL'
						  AND orgb.id = orb.rgp_id
						  AND orgb.rgd_code = 'LAAFLG'
						  AND okc.id = orgb.dnz_chr_id
						  AND okc.scs_code = 'LEASE'
						  AND okc.sts_code NOT IN ('EXPIRED','TERMINATED','CANCELLED','ABANDONED')
 		                );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_contract_tc,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_contract_tc);

    end;

    --Rule: Title Custodian - Contract Template <> Abandoned
    begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						  SELECT NULL
						   FROM okc_k_headers_all_b okc,
								    okc_rule_groups_b orgb,
								    okc_rules_b orb
						  WHERE orb.object2_id1 = p_person_id
						  AND orb.jtot_object2_code = 'OKX_PARTY'
						  AND orb.rule_information_category = 'LAFLTL'
						  AND orgb.id = orb.rgp_id
						  AND orgb.rgd_code = 'LAAFLG'
						  AND okc.id = orgb.dnz_chr_id
						  AND okc.scs_code = 'LEASE'
                          AND okc.template_yn = 'Y'
                          AND okc.sts_code NOT IN ('ABANDONED')
 		                );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_template_tc,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_template_tc);
    end;

    --Rule: Mask original contract if T and A contract is inactive for Title Custodian
	  begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
							SELECT  NULL
							FROM    okc_k_headers_all_b old_khr,
									    okc_k_headers_all_b new_khr,
									    okc_rule_groups_b orgb,
									    okc_rules_b orb
							WHERE  orb.object2_id1 = p_person_id
							AND orb.jtot_object2_code = 'OKX_PARTY'
							AND orb.rule_information_category = 'LAFLTL'
							AND orgb.id = orb.rgp_id
							AND orgb.rgd_code = 'LAAFLG'
							AND old_khr.id = orgb.dnz_chr_id
							AND old_khr.id = new_khr.orig_system_id1
							AND old_khr.scs_code = 'LEASE'
							AND new_khr.orig_system_source_code = 'OKL_RELEASE'
							AND new_khr.scs_code = 'LEASE'
							AND new_khr.sts_code NOT IN ('EXPIRED', 'TERMINATED', 'CANCELLED', 'ABANDONED')
						);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_ta_contract_tc,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_ta_contract_tc);
    end;


	  --Rule: Mask if third party insurance is expired for agent
    begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						  SELECT  NULL
							FROM    okl_ins_policies_all_b ipb,
									    hz_parties hp
							WHERE   ipb.int_id = hp.party_id
							AND     hp.category_code = 'INSURANCE_AGENT'
							AND     ipb.ipy_type = 'THIRD_PARTY_POLICY'
							AND     NVL(ipb.date_to,SYSDATE) >= sysdate
							AND     ipb.int_id = p_person_id
 		                );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_third_party_ins,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_third_party_ins);
    end;


	 --Rule: Mask if contract status is expired, terminated, cancelled, or abandoned for private label party
    begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						  SELECT  NULL
						  FROM    okc_k_headers_all_b okc
								    , okc_k_party_roles_b kpr
						  WHERE   okc.id = kpr.dnz_chr_id
						  AND     kpr.rle_code = 'PRIVATE_LABEL'
						  AND     kpr.object1_id1 = to_char(p_person_id) --changed by amansinh for bug 28205711
						  AND     okc.scs_code = 'LEASE'
						  AND     okc.sts_code NOT IN ('EXPIRED', 'TERMINATED', 'CANCELLED', 'ABANDONED')
 		                );
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_contract_pl,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_contract_pl);
    end;


	 --Rule: Mask if contract template is abandoned for private label party
   begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
						  SELECT  NULL
						  FROM    okc_k_headers_all_b okc
								    , okc_k_party_roles_b kpr
						  WHERE   okc.id = kpr.dnz_chr_id
						  AND     kpr.rle_code = 'PRIVATE_LABEL'
						  AND     kpr.object1_id1 = to_char(p_person_id) --changed by amansinh for bug 28205711
						  AND     okc.scs_code = 'LEASE'
						  AND     okc.template_yn = 'Y'
						  AND     okc.sts_code NOT IN ('ABANDONED')
						);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_template_pl,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
        print_debug('Status : E, msgcode : '||g_open_template_pl);
    end;

    -- Mask original contract if T and A contract is inactive for private label
	  begin
		SELECT  null
		INTO    l_temp
		FROM    sys.dual
		WHERE   NOT EXISTS
						(
							SELECT  NULL
							FROM    okc_k_headers_all_b old_khr,
									    okc_k_headers_all_b new_khr,
                      okc_k_party_roles_b kpr
							WHERE   kpr.rle_code = 'PRIVATE_LABEL'
						  AND     kpr.object1_id1 = to_char(p_person_id) --changed by amansinh for bug 28205711
							AND old_khr.id = kpr.dnz_chr_id
							AND old_khr.id = new_khr.orig_system_id1
							AND old_khr.scs_code = 'LEASE'
							AND new_khr.orig_system_source_code = 'OKL_RELEASE'
							AND new_khr.scs_code = 'LEASE'
							AND new_khr.sts_code NOT IN ('EXPIRED', 'TERMINATED', 'CANCELLED', 'ABANDONED')
						);
	exception
    when NO_DATA_FOUND then
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => g_open_ta_contract_pl,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
         print_debug('Status : E, msgcode : '||g_open_ta_contract_pl);
    end;

 /* IF(result_tbl.count < 1) THEN
    print_debug('All constraints are validated successfully. ');
    per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'S' ,
                                    msgcode => NULL,
                                    msgaplid => 540,
                                    result_tbl => result_tbl);
  END IF; */
  print_debug('All constraints are validated successfully. ');
  print_debug('Leaving: '||l_proc);
	return;

 EXCEPTION

  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occured
    --
    print_debug('OTHERS : '||SQLCODE||'-'||SQLERRM);
    print_debug('Leaving: OTHERS : '||l_proc);
    per_drt_pkg.add_to_results (person_id => p_person_id ,
                                    entity_type => 'TCA' ,
                                    status => 'E' ,
                                    msgcode => 'OKL_CONTRACTS_UNEXPECTED_ERROR',
                                    msgaplid => 540,
                                    result_tbl => result_tbl);

    raise;

END okl_tca_drc;



------------------------------------------------------------------------------
-- Description:
--  Post processing function for person type : TCA
--  This function masks email id of vendor in OKL_QUOTE_PARTIES table
-- and return 'S' for Success, 'W' for Warning and 'E' for Error
------------------------------------------------------------------------------
PROCEDURE okl_tca_post
  (p_person_id IN	NUMBER)
 IS
  --
  -- Declare cursors and local variables
  --
   l_proc							varchar2(72) :='okl_tca_post';
BEGIN

  IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  print_debug('Entering: '||l_proc);
  print_debug('p_person_id: '||p_person_id);
  print_debug('Updating the table okl_quote_parties');
      UPDATE okl_quote_parties
	  SET EMAIL_ADDRESS=nvl2(EMAIL_ADDRESS,per_drt_udf.overwrite_email(ROWID,'OKL_QUOTE_PARTIES','EMAIL_ADDRESS',p_person_id),EMAIL_ADDRESS)
	  WHERE party_object1_id1 in
	     (select to_char(asp.vendor_id) --changed for amansinh for bug 28205711
	     from ap_suppliers asp,
	          hz_parties hp
	     where asp.party_id = hp.party_id
	    -- and asp.vendor_name = hp.party_name
	     and hp.party_id = p_person_id)
	     and party_jtot_object1_code = 'OKX_VENDOR';

  print_debug('Updating the table okl_trx_csh_rcpt_all_b');
      -- Bug 27998762
      UPDATE  okl_trx_csh_rcpt_all_b
      SET     ACCOUNT=nvl2(ACCOUNT,per_drt_rules.ranstr(5,240),ACCOUNT),
              CUSTOMER_BANK_NAME=nvl2(CUSTOMER_BANK_NAME,per_drt_rules.ranstr(10,240),CUSTOMER_BANK_NAME)
      WHERE   id IN
        (
        SELECT  rcpt.rct_id_details
        FROM    okl_txl_rcpt_apps_all_b rcpt
              , ra_customer_trx_all trx
              , hz_cust_accounts hca
              , hz_parties hp
        WHERE   rcpt.ar_invoice_id = trx.customer_trx_id
        AND     hca.cust_account_id = trx.bill_to_customer_id
        AND     hp.party_id = hca.party_id
        AND     hp.party_id = p_person_id
        );

  print_debug('Leaving: '||l_proc);

 EXCEPTION

  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occured
    --
    print_debug('OTHERS : '||SQLCODE||'-'||SQLERRM);
    print_debug('Leaving: OTHERS : '||l_proc);
    RAISE;

END okl_tca_post;

END OKL_DRT_PKG;

/
