--------------------------------------------------------
--  DDL for Package Body OKL_AM_INVOICES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_INVOICES_PVT" AS
/* $Header: OKLRAMIB.pls 120.47.12010000.3 2010/03/23 05:48:46 sosharma ship $ */

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_STATEMENT            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_invoices_pvt.';
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  SUBTYPE tilv_rec_type IS okl_txl_ar_inv_lns_pub.tilv_rec_type;
  SUBTYPE tilv_tbl_type IS okl_txl_ar_inv_lns_pub.tilv_tbl_type;
  SUBTYPE bpd_acc_rec_type IS okl_acc_call_pub.bpd_acc_rec_type;
  SUBTYPE bpd_acc_tbl_type IS okl_acc_call_pub.bpd_acc_tbl_type;
  SUBTYPE rulv_rec_type IS okl_rule_pub.rulv_rec_type;

-- Start of comments
--
-- Procedure Name : Get_Quote_Line_Stream
-- Description  : Returns stream type id for a quote line code
-- Business Rules :
-- Parameters  : billing record
-- Version  : 1.0
-- End of comments

FUNCTION Get_Quote_Line_Stream (
 p_qlt_code  IN VARCHAR2)
 RETURN   NUMBER IS

 -- Get stream_type_id
 CURSOR l_sty_csr (cp_qlt_code VARCHAR2) IS
  SELECT s.sty_id
  FROM okl_quote_line_strm s
  WHERE s.quote_line_type_code = cp_qlt_code;

 l_stream_type_id NUMBER;
 l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_quote_line_stream';
 is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
 is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
 is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
 END IF;
 IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qlt_code: '||p_qlt_code);
 END IF;

 OPEN l_sty_csr (p_qlt_code);
 FETCH l_sty_csr INTO l_stream_type_id;
 CLOSE l_sty_csr;
 IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Returning l_stream_type_id: '||l_stream_type_id);
 END IF;
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
 END IF;

 RETURN l_stream_type_id;

EXCEPTION

 WHEN OTHERS THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
  END IF;
  IF (l_sty_csr%ISOPEN) THEN
   CLOSE l_sty_csr;
  END IF;
  RETURN NULL;

END Get_Quote_Line_Stream;


-- Start of comments
--
-- Procedure Name : Get_Vendor_Billing_Info
-- Description  : Extract Vendor Billing Information
-- Business Rules :
-- Parameters  : Contract Party Id or Contract Id
-- History          : RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
--                  : RMUNJULU 26-MAR-04 3300594 Changed Cursor l_partner_rg_csr to get
--                    vendor billing info from vendor programs party role table
--                  : PAGARG 14-Feb-2005 Bug 3559535, correct the message used
--                    for no vendor program being there for the given contract
-- Version  : 1.0
-- End of comments

PROCEDURE Get_Vendor_Billing_Info (
 p_cpl_id  IN NUMBER DEFAULT NULL,
 px_taiv_rec  IN OUT NOCOPY taiv_rec_type,
 x_return_status  OUT NOCOPY VARCHAR2) IS

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

 l_contract_id  NUMBER  := px_taiv_rec.khr_id;
 l_khr_id  NUMBER;
 l_par_id  NUMBER;
 l_rgd_id  NUMBER;
 l_party_name  VARCHAR2(1000);

    l_bill_to_site_use_id OKC_K_HEADERS_B.bill_to_site_use_id%TYPE; -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
    l_party_role FND_LOOKUPS.meaning%TYPE; -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes

 --l_bto_rulv_rec  rulv_rec_type; -- Bill To Address Rule
 l_mth_rulv_rec  rulv_rec_type; -- Payment Method Rule


    -- This cursor called from
    -- okl_am_parties_pvt.create_quote_parties when termination quote recipient is OKL_VENDOR(Lease Vendor)
    -- OR
    -- Okl_Am_Invoices_Pvt.validate_populate_quote when termination quote recipient is OKL_VENDOR(Lease Vendor)
    -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
    -- Get bill to site of OKL_VENDOR party
 CURSOR l_k_party_rg_csr (cp_cpl_id IN NUMBER) IS
  SELECT cpl.id   cpl_id,
   cpl.jtot_object1_code object1_code,
   cpl.object1_id1  object1_id1,
   cpl.object1_id2  object1_id2,
   rgd.id   rgd_id,
            cpl.bill_to_site_use_id bill_to_site_use_id,  -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
            cpl.role  party_role -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
  FROM okc_k_party_roles_v cpl,
   okc_rg_party_roles rgpr,
   okc_rule_groups_v rgd
  WHERE cpl.id   = cp_cpl_id
  AND cpl.rle_code  = 'OKL_VENDOR'
  AND rgpr.cpl_id (+) = cpl.id
  AND rgd.id  (+) = rgpr.rgp_id
  AND rgd.rgd_code (+) = 'LAVENB';

    -- This cursor called from REPURCHASE QUOTE
    -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
    -- Get bill to site of vendor PROGRAM
    -- RMUNJULU 3300594 Changed way to get bill_to_site_use_id, get from CPL not PAR
    -- PAGARG Bug 3559535 Make join of okc_k_headers_b par with okc_k_party_roles_v
    -- as outer join so that it returns te record of contract even if vendor program
    -- is not there for that contract
 CURSOR l_partner_rg_csr (cp_khr_id IN NUMBER) IS
  SELECT khr.id   khr_id,
   par.id   par_id,
   rgd.id   rgd_id,
            CPL.bill_to_site_use_id bill_to_site_use_id, -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
            cpl.role party_role -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
  FROM okl_k_headers  khr,
   okc_k_headers_all_b par,
   okc_rule_groups_b rgd,
            okc_k_party_roles_v cpl -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
  WHERE khr.id   = cp_khr_id
  AND par.id  (+) = khr.khr_id
  AND par.scs_code (+) = 'PROGRAM'
  AND rgd.chr_id (+) = par.id
  AND rgd.dnz_chr_id (+) = par.id
  AND rgd.cle_id  IS NULL
  AND rgd.rgd_code (+) = 'LAVENB'
        AND par.id = cpl.dnz_chr_id (+) -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
        AND cpl.rle_code (+) = 'OKL_VENDOR'; -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes

 CURSOR l_rcpt_mthd_csr (cp_cust_rct_mthd IN NUMBER) IS
  SELECT c.receipt_method_id
  FROM ra_cust_receipt_methods  c
  WHERE c.cust_receipt_method_id = cp_cust_rct_mthd;

 CURSOR l_site_use_csr (
   cp_site_use_id  IN NUMBER,
   cp_site_use_code IN VARCHAR2) IS
  SELECT a.cust_account_id cust_account_id,
   a.cust_acct_site_id cust_acct_site_id,
   a.payment_term_id payment_term_id
  FROM    okx_cust_site_uses_v a,
   okx_customer_accounts_v c
  WHERE a.id1   = cp_site_use_id
  AND a.site_use_code  = cp_site_use_code
  AND c.id1   = a.cust_account_id;

 CURSOR l_std_terms_csr (
   cp_cust_id  IN NUMBER,
   cp_site_use_id  IN NUMBER) IS
  SELECT c.standard_terms standard_terms
  FROM hz_customer_profiles c
  WHERE c.cust_account_id = cp_cust_id
  AND c.site_use_id  = cp_site_use_id
  UNION
  SELECT c1.standard_terms standard_terms
  FROM hz_customer_profiles c1
  WHERE c1.cust_account_id = cp_cust_id
  AND c1.site_use_id  IS NULL
  AND NOT EXISTS (
   SELECT '1'
   FROM hz_customer_profiles c2
   WHERE c2.cust_account_id = cp_cust_id
   AND c2.site_use_id  = cp_site_use_id);

 l_site_use_rec  l_site_use_csr%ROWTYPE;
 l_k_party_rg_rec l_k_party_rg_csr%ROWTYPE;
 l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_vendor_billing_info';
 is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
 is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
 is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


BEGIN
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
 END IF;
 IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_cpl_id: '||p_cpl_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.khr_id: ' || px_taiv_rec.khr_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.ibt_id: ' || px_taiv_rec.ibt_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.ixx_id: ' || px_taiv_rec.ixx_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.irt_id: ' || px_taiv_rec.irt_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.irm_id: ' || px_taiv_rec.irm_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.currency_code: ' || px_taiv_rec.currency_code);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.description: ' || px_taiv_rec.description);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.date_entered: ' || px_taiv_rec.date_entered);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.date_invoiced: ' || px_taiv_rec.date_invoiced);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.try_id: ' || px_taiv_rec.try_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.amount: ' || px_taiv_rec.amount);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.OKL_SOURCE_BILLING_TRX: ' || px_taiv_rec.OKL_SOURCE_BILLING_TRX);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.currency_conversion_type: ' || px_taiv_rec.currency_conversion_type);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.currency_conversion_rate: ' || px_taiv_rec.currency_conversion_rate);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.currency_conversion_date: ' || px_taiv_rec.currency_conversion_date);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.legal_entity_id: ' || px_taiv_rec.legal_entity_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.set_of_books_id: ' || px_taiv_rec.set_of_books_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.org_id: ' || px_taiv_rec.org_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.qte_id: ' || px_taiv_rec.qte_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, px_taiv_rec.id: ' || px_taiv_rec.id);
 END IF;

 -- *******************
 -- Validate parameters
 -- *******************

 IF ( p_cpl_id IS NULL
      OR p_cpl_id = G_MISS_NUM)
 AND ( l_contract_id IS NULL
      OR l_contract_id = G_MISS_NUM) THEN

  l_return_status := OKL_API.G_RET_STS_ERROR;

  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => 'OKC_NO_PARAMS',
   p_token1 => 'PARAM',
   p_token1_value => 'Contract Party Id or Contract Id',
   p_token2 => 'PROCESS',
   p_token2_value => 'Get_Vendor_Billing_Info');

 END IF;

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
  IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
   l_overall_status := l_return_status;
  END IF;
 END IF;

 -- ***************
 -- Find Rule Group
 -- ***************

 IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

     IF  p_cpl_id IS NOT NULL
     AND p_cpl_id <> G_MISS_NUM THEN

  OPEN l_k_party_rg_csr (p_cpl_id);
  FETCH l_k_party_rg_csr INTO l_k_party_rg_rec;
  CLOSE l_k_party_rg_csr;
  l_rgd_id := l_k_party_rg_rec.rgd_id;
        -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
        l_bill_to_site_use_id := l_k_party_rg_rec.bill_to_site_use_id ;

  IF l_k_party_rg_rec.cpl_id IS NULL THEN
   l_return_status := OKL_API.G_RET_STS_ERROR;
   OKC_API.SET_MESSAGE (
    p_app_name => G_OKC_APP_NAME,
    p_msg_name => G_INVALID_VALUE,
    p_token1 => G_COL_NAME_TOKEN,
    p_token1_value => 'Contract Party Id');
    /* -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
  ELSIF l_rgd_id IS NULL THEN
   l_return_status := OKL_API.G_RET_STS_ERROR;
   l_party_name := okl_am_util_pvt.get_jtf_object_name (
    l_k_party_rg_rec.object1_code,
    l_k_party_rg_rec.object1_id1,
    l_k_party_rg_rec.object1_id2);
   OKC_API.SET_MESSAGE (
    p_app_name => G_APP_NAME,
    p_msg_name => 'OKL_AM_NO_BILLING_INFO',
    p_token1 => 'PARTY',
    p_token1_value => l_party_name);
      */
        -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
        ELSIF    l_k_party_rg_rec.bill_to_site_use_id IS NULL    THEN
   l_return_status := OKL_API.G_RET_STS_ERROR;
   l_party_name := okl_am_util_pvt.get_jtf_object_name (
    l_k_party_rg_rec.object1_code,
    l_k_party_rg_rec.object1_id1,
    l_k_party_rg_rec.object1_id2);
            -- Billing information is not found for party PARTY having role PARTY_ROLE.
   OKC_API.SET_MESSAGE (
    p_app_name => G_APP_NAME,
    p_msg_name => 'OKL_AM_NO_BILLING_INFO_NEW',
    p_token1 => 'PARTY',
    p_token1_value => l_party_name,
    p_token2 => 'PARTY_ROLE',
    p_token2_value => l_k_party_rg_rec.party_role);
  END IF;


     ELSIF l_contract_id IS NOT NULL
     AND   l_contract_id <> G_MISS_NUM THEN

  OPEN l_partner_rg_csr (l_contract_id);
  FETCH l_partner_rg_csr INTO l_khr_id, l_par_id, l_rgd_id, l_bill_to_site_use_id, l_party_role; -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
  CLOSE l_partner_rg_csr;

  IF l_khr_id IS NULL THEN
   l_return_status := OKL_API.G_RET_STS_ERROR;
   OKC_API.SET_MESSAGE (
    p_app_name => G_OKC_APP_NAME,
    p_msg_name => G_INVALID_VALUE,
    p_token1 => G_COL_NAME_TOKEN,
    p_token1_value => 'Contract Id');
  ELSIF l_par_id IS NULL THEN
   l_return_status := OKL_API.G_RET_STS_ERROR;
   okl_am_util_pvt.set_message(
     p_app_name => G_APP_NAME
-- PAGARG Bug 3559535 Use proper message for no vendor program found
    ,p_msg_name => 'OKL_AM_NO_VENDOR_PROG');

    /* -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
  ELSIF l_rgd_id IS NULL THEN
   l_return_status := OKL_API.G_RET_STS_ERROR;
   l_party_name := okl_am_util_pvt.get_program_partner (l_khr_id);
   OKC_API.SET_MESSAGE (
    p_app_name => G_APP_NAME,
    p_msg_name => 'OKL_AM_NO_BILLING_INFO',
    p_token1 => 'PARTY',
    p_token1_value => l_party_name);
    */

        -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
  ELSIF l_bill_to_site_use_id IS NULL THEN
   l_return_status := OKL_API.G_RET_STS_ERROR;
   l_party_name := okl_am_util_pvt.get_program_partner (l_khr_id);
   IF (is_debug_statement_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_program_partner and got l_party_name : ' || l_party_name);
   END IF;
            -- Billing information is not found for party PARTY having role PARTY_ROLE.
   OKC_API.SET_MESSAGE (
    p_app_name => G_APP_NAME,
    p_msg_name => 'OKL_AM_NO_BILLING_INFO_NEW',
    p_token1 => 'PARTY',
    p_token1_value => l_party_name,
    p_token2 => 'PARTY_ROLE',
    p_token2_value => l_party_role);
  END IF;

     ELSE
  l_return_status := OKL_API.G_RET_STS_ERROR;
     END IF;

 END IF;

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
  IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
   l_overall_status := l_return_status;
  END IF;
 END IF;

 -- ***********************************
 -- Get Rules to set billing attributes
 -- ***********************************

/*  -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes

 IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN


  okl_am_util_pvt.get_rule_record (
   p_rgd_id => l_rgd_id,
   p_rgd_code => 'LAVENB',
   p_rdf_code => 'BTO',
   p_chr_id => l_contract_id,
   p_cle_id => NULL,
   p_message_yn => TRUE,
   x_rulv_rec => l_bto_rulv_rec,
   x_return_status => l_return_status);


 END IF;

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
  IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
   l_overall_status := l_return_status;
  END IF;
 END IF;
*/

 IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN
  IF (is_debug_statement_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
  END IF;

  okl_am_util_pvt.get_rule_record (
   p_rgd_id => l_rgd_id,
   p_rgd_code => 'LAVENB',
   p_rdf_code => 'LAPMTH',
   p_chr_id => l_contract_id,
   p_cle_id => NULL,
   p_message_yn => FALSE, -- Rule is optional - bug 2533080
   x_rulv_rec => l_mth_rulv_rec,
   x_return_status => l_return_status);
  IF (is_debug_statement_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record , return status: ' || l_return_status);
  END IF;

            -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
            -- ADDED SINCE 2533080 not fixed properly
            -- If the above rule is optional then should not check the return status
            l_return_status := OKL_API.G_RET_STS_SUCCESS;


 END IF;

 -- Rule is optional - bug 2533080
 -- IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
 -- IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
 --  l_overall_status := l_return_status;
 -- END IF;
 -- END IF;

 -- *****************************************************
 -- Extract Customer, Bill To and Payment Term from rules
 -- *****************************************************

 IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

        -- RMUNJULU 27-AUG-03 OKC RULE MIGRATION changes
  OPEN l_site_use_csr (l_bill_to_site_use_id, 'BILL_TO');
  FETCH l_site_use_csr INTO l_site_use_rec;
  CLOSE l_site_use_csr;

  px_taiv_rec.ibt_id := l_site_use_rec.cust_acct_site_id;
  px_taiv_rec.ixx_id := l_site_use_rec.cust_account_id;
  px_taiv_rec.irt_id := l_site_use_rec.payment_term_id;

  IF px_taiv_rec.irt_id IS NULL
  OR px_taiv_rec.irt_id = G_MISS_NUM THEN
   OPEN l_std_terms_csr (
     l_site_use_rec.cust_account_id,
     l_bill_to_site_use_id); -- RMUNJULU 27-AUG-03 OKC RULE MIGRATION changes
   FETCH l_std_terms_csr INTO px_taiv_rec.irt_id;
   CLOSE l_std_terms_csr;
  END IF;

 END IF;

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
  IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
   l_overall_status := l_return_status;
  END IF;
 END IF;

 -- *******************************
 -- Extract Payment Term from rules
 -- *******************************

 IF l_overall_status = OKL_API.G_RET_STS_SUCCESS
 AND l_mth_rulv_rec.id IS NOT NULL -- Rule is optional - bug 2533080
 AND l_mth_rulv_rec.id <> G_MISS_NUM THEN

  IF l_mth_rulv_rec.object1_id2 <> '#' THEN
   px_taiv_rec.irm_id := l_mth_rulv_rec.object1_id2;
  ELSE
   -- This cursor needs to be removed when
   -- the view changes to include id2
   OPEN l_rcpt_mthd_csr (l_mth_rulv_rec.object1_id1);
   FETCH l_rcpt_mthd_csr INTO px_taiv_rec.irm_id;
   CLOSE l_rcpt_mthd_csr;
  END IF;

 END IF;

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
  IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
   l_overall_status := l_return_status;
  END IF;
 END IF;

 -- ****************
 -- Validate Results
 -- ****************

 IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

  IF px_taiv_rec.ixx_id IS NULL
  OR px_taiv_rec.ixx_id = G_MISS_NUM THEN
   l_return_status := OKL_API.G_RET_STS_ERROR;
   OKC_API.SET_MESSAGE (
    p_app_name => G_OKC_APP_NAME,
    p_msg_name => G_REQUIRED_VALUE,
    p_token1 => G_COL_NAME_TOKEN,
    p_token1_value => 'Customer Account Id');
  END IF;

  IF px_taiv_rec.ibt_id IS NULL
  OR px_taiv_rec.ibt_id = G_MISS_NUM THEN
   l_return_status := OKL_API.G_RET_STS_ERROR;
   OKC_API.SET_MESSAGE (
    p_app_name => G_OKC_APP_NAME,
    p_msg_name => G_REQUIRED_VALUE,
    p_token1 => G_COL_NAME_TOKEN,
    p_token1_value => 'Bill To Address Id');
  END IF;

  IF px_taiv_rec.irt_id IS NULL
  OR px_taiv_rec.irt_id = G_MISS_NUM THEN
   l_return_status := OKL_API.G_RET_STS_ERROR;
   OKC_API.SET_MESSAGE (
    p_app_name => G_OKC_APP_NAME,
    p_msg_name => G_REQUIRED_VALUE,
    p_token1 => G_COL_NAME_TOKEN,
    p_token1_value => 'Payment Term Id');
  END IF;

  -- Rule is optional - bug 2533080
  -- IF px_taiv_rec.irm_id IS NULL
  -- OR px_taiv_rec.irm_id = G_MISS_NUM THEN
  -- l_return_status := OKL_API.G_RET_STS_ERROR;
  -- OKC_API.SET_MESSAGE (
  --  p_app_name => G_OKC_APP_NAME,
  --  p_msg_name => G_REQUIRED_VALUE,
  --  p_token1 => G_COL_NAME_TOKEN,
  --  p_token1_value => 'Payment Method Id');
  -- END IF;

 END IF;

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
  IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
   l_overall_status := l_return_status;
  END IF;
 END IF;


 x_return_status := l_overall_status;
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
 END IF;

EXCEPTION

 WHEN OTHERS THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
  END IF;

  -- close open cursors
  IF l_k_party_rg_csr%ISOPEN THEN
   CLOSE l_k_party_rg_csr;
  END IF;

  IF l_partner_rg_csr%ISOPEN THEN
   CLOSE l_partner_rg_csr;
  END IF;

  IF l_rcpt_mthd_csr%ISOPEN THEN
   CLOSE l_rcpt_mthd_csr;
  END IF;

  IF l_site_use_csr%ISOPEN THEN
   CLOSE l_site_use_csr;
  END IF;

  IF l_std_terms_csr%ISOPEN THEN
   CLOSE l_std_terms_csr;
  END IF;

  -- store SQL error message on message stack for caller
  OKL_API.SET_MESSAGE (
    p_app_name => G_APP_NAME
   ,p_msg_name => G_UNEXPECTED_ERROR
   ,p_token1 => G_SQLCODE_TOKEN
   ,p_token1_value => sqlcode
   ,p_token2 => G_SQLERRM_TOKEN
   ,p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END Get_Vendor_Billing_Info;

-- Start of comments
--
-- Procedure Name  : Create_billing_invoices
-- Description     : Creates OKL Billing Transaction for AR Invoicing
-- Business Rules  :
-- Parameters      : Transaction Record for AR Invoice
-- Version         : 1.0
-- History         : ANSETHUR 03/02/2007 Created For R12B Billing Enhancement project
--                   To Replace Create_AR_Invoice_Header and Create_AR_Invoice_Lines procedures
--                   with the Enhanced Billing API
-- End of comments

PROCEDURE Create_billing_invoices (
          p_taiv_rec      IN  taiv_rec_type,
          p_pos_amount    IN  NUMBER DEFAULT 0,
          p_neg_amount    IN  NUMBER DEFAULT 0,
          p_quote_type    IN  VARCHAR2 DEFAULT NULL,
          p_trans_type    IN  VARCHAR2 DEFAULT NULL,
          p_tilv_tbl      IN  tilv_tbl_type,
          x_tilv_tbl      OUT NOCOPY tilv_tbl_type,
          x_pos_taiv_rec  OUT NOCOPY taiv_rec_type,
          x_neg_taiv_rec  OUT NOCOPY taiv_rec_type,
          x_return_status OUT NOCOPY VARCHAR2) IS

 l_pos_try_id            NUMBER  := NULL;
 l_neg_try_id            NUMBER  := NULL;
 l_sysdate               DATE  := SYSDATE;
 l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_taiv_rec              taiv_rec_type;

 l_api_version           CONSTANT NUMBER := G_API_VERSION;
 l_msg_count             NUMBER ;-- rmunjulu bug 4341480 := OKL_API.G_MISS_NUM;
 l_msg_data              VARCHAR2(2000);


 l_roll_bill_try_id      NUMBER  DEFAULT NULL;
 l_roll_cm_try_id        NUMBER  DEFAULT NULL;

 l_release_bill_try_id   NUMBER  DEFAULT NULL;
 l_release_cm_try_id     NUMBER  DEFAULT NULL;

 --from lines
 l_tilv_rec              tilv_rec_type;
 l_bpd_acc_rec           bpd_acc_rec_type;

-- Added For Enhanced Billing PVT
  l_tldv_tbl            okl_tld_pvt.tldv_tbl_type;
  lx_tldv_tbl           okl_tld_pvt.tldv_tbl_type;

  l_tilv_tbl            okl_txl_ar_inv_lns_pub.tilv_tbl_type;
  lx_tilv_tbl           okl_txl_ar_inv_lns_pub.tilv_tbl_type;

  l_pos_tilv_tbl        okl_txl_ar_inv_lns_pub.tilv_tbl_type;
  l_neg_tilv_tbl        okl_txl_ar_inv_lns_pub.tilv_tbl_type;

  i number :=0;
  j number :=0;
  k number :=0;
  l_module_name VARCHAR2(500) := G_MODULE_NAME || 'create_billing_invoices';
  is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
  is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
  is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
 END IF;
 IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_pos_amount: '||p_pos_amount);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_neg_amount: '||p_neg_amount);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_quote_type: '||p_quote_type);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_trans_type: '||p_trans_type);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.khr_id: ' || p_taiv_rec.khr_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.ibt_id: ' || p_taiv_rec.ibt_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.ixx_id: ' || p_taiv_rec.ixx_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.irt_id: ' || p_taiv_rec.irt_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.irm_id: ' || p_taiv_rec.irm_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.currency_code: ' || p_taiv_rec.currency_code);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.description: ' || p_taiv_rec.description);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.date_entered: ' || p_taiv_rec.date_entered);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.date_invoiced: ' || p_taiv_rec.date_invoiced);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.try_id: ' || p_taiv_rec.try_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.amount: ' || p_taiv_rec.amount);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.OKL_SOURCE_BILLING_TRX: ' || p_taiv_rec.OKL_SOURCE_BILLING_TRX);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.currency_conversion_type: ' || p_taiv_rec.currency_conversion_type);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.currency_conversion_rate: ' || p_taiv_rec.currency_conversion_rate);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.currency_conversion_date: ' || p_taiv_rec.currency_conversion_date);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.legal_entity_id: ' || p_taiv_rec.legal_entity_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.set_of_books_id: ' || p_taiv_rec.set_of_books_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.org_id: ' || p_taiv_rec.org_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.qte_id: ' || p_taiv_rec.qte_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_taiv_rec.id: ' || p_taiv_rec.id);
   FOR i IN p_tilv_tbl.FIRST..p_tilv_tbl.LAST LOOP
     IF (p_tilv_tbl.exists(i)) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tilv_tbl(' || i || ').amount : ' || p_tilv_tbl(i).amount);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tilv_tbl(' || i || ').sty_id : ' || p_tilv_tbl(i).sty_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tilv_tbl(' || i || ').description : ' || p_tilv_tbl(i).description);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tilv_tbl(' || i || ').inv_receiv_line_code : ' || p_tilv_tbl(i).inv_receiv_line_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tilv_tbl(' || i || ').line_number : ' || p_tilv_tbl(i).line_number);
     END IF;
   END LOOP;
 END IF;

 -- *******************
 -- Validate parameters
 -- *******************

 IF (is_debug_statement_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_transaction_id');
 END IF;
 okl_am_util_pvt.get_transaction_id (
                                    p_try_name       => G_AR_INV_TRX_TYPE,
                                    x_return_status  => l_return_status,
                                    x_try_id         => l_pos_try_id);
 IF (is_debug_statement_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_transaction_id , return status: ' || l_return_status);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_pos_try_id : ' || l_pos_try_id);
 END IF;

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
 OR NVL (l_pos_try_id, G_MISS_NUM) = G_MISS_NUM THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKC_API.SET_MESSAGE (
                             P_APP_NAME => G_OKC_APP_NAME,
                             P_MSG_NAME => G_INVALID_VALUE,
                             P_TOKEN1 => G_COL_NAME_TOKEN,
                             P_TOKEN1_VALUE => 'TRANSACTION TYPE');
 END IF;

   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_transaction_id');
   END IF;
   okl_am_util_pvt.get_transaction_id (
                              p_try_name => G_AR_CM_TRX_TYPE,
                              x_return_status => l_return_status,
                              x_try_id => l_neg_try_id);
   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_transaction_id , return status: ' || l_return_status);
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_neg_try_id : ' || l_neg_try_id);
   END IF;

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
 OR NVL (l_neg_try_id, G_MISS_NUM) = G_MISS_NUM THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKC_API.SET_MESSAGE (
                             p_app_name => G_OKC_APP_NAME,
                             p_msg_name => G_INVALID_VALUE,
                             p_token1 => G_COL_NAME_TOKEN,
                             p_token1_value => 'Transaction Type');
 END IF;

    ----------------------
    -- Obtain transaction id for Rollover transactions
    ----------------------
    --09-Nov-04 PAGARG Bug #4002033 moved the logic to obtain transaction type
    --id inside appropriate condition
  IF p_quote_type LIKE 'TER_ROLL%'
  AND p_trans_type = 'REVERSE' THEN
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_transaction_id');
        END IF;
        okl_am_util_pvt.get_transaction_id (
                                  p_try_name => 'ROLLOVER BILLING',
                                  x_return_status => l_return_status,
                                  x_try_id => l_roll_bill_try_id);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_transaction_id , return status: ' || l_return_status);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_roll_bill_try_id : ' || l_roll_bill_try_id);
        END IF;

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
      OR NVL (l_roll_bill_try_id, G_MISS_NUM) = G_MISS_NUM THEN
                 l_return_status := OKL_API.G_RET_STS_ERROR;
                 OKC_API.SET_MESSAGE (
                                  p_app_name => G_OKC_APP_NAME,
                                  p_msg_name => G_INVALID_VALUE,
                                  p_token1   => G_COL_NAME_TOKEN,
                                  p_token1_value => 'Transaction Type');
      END IF;

      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_transaction_id');
      END IF;
      okl_am_util_pvt.get_transaction_id (
                                  p_try_name      => 'ROLLOVER CREDIT MEMO',
                                  x_return_status => l_return_status,
                                  x_try_id        => l_roll_cm_try_id);
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_transaction_id , return status: ' || l_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_roll_cm_try_id : ' || l_roll_cm_try_id);
      END IF;

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
      OR NVL (l_roll_cm_try_id, G_MISS_NUM) = G_MISS_NUM THEN
                  l_return_status := OKL_API.G_RET_STS_ERROR;
                  OKC_API.SET_MESSAGE (
                                  p_app_name => G_OKC_APP_NAME,
                                  p_msg_name => G_INVALID_VALUE,
                                  p_token1   => G_COL_NAME_TOKEN,
                                  p_token1_value => 'Transaction Type');
      END IF;
  END IF;

    ----------------------
    -- Obtain transaction id for Release transactions
    ----------------------
    --09-Nov-04 PAGARG Bug #4002033 moved the logic to obtain transaction type
    --id inside appropriate condition
    IF p_quote_type = 'TER_RELEASE_WO_PURCHASE'
    AND p_trans_type = 'REVERSE' THEN
                  IF (is_debug_statement_on) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_transaction_id');
                  END IF;
                   okl_am_util_pvt.get_transaction_id (
                                  p_try_name      => 'RELEASE BILLING',
                                  x_return_status => l_return_status,
                                  x_try_id        => l_release_bill_try_id);
                  IF (is_debug_statement_on) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_transaction_id , return status: ' || l_return_status);
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_release_bill_try_id : ' || l_release_bill_try_id);
                   END IF;

          -- 02-Dec-2004 PAGARG Bug# 4043464, check correct variable for G_MISS value
          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
          OR NVL (l_release_bill_try_id, G_MISS_NUM) = G_MISS_NUM THEN
                    l_return_status := OKL_API.G_RET_STS_ERROR;
                    OKC_API.SET_MESSAGE (
                                  p_app_name     => G_OKC_APP_NAME,
                                  p_msg_name     => G_INVALID_VALUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'Transaction Type');
          END IF;
                  IF (is_debug_statement_on) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_transaction_id');
                  END IF;

                    okl_am_util_pvt.get_transaction_id (
                                  p_try_name       => 'RELEASE CREDIT MEMO',
                                  x_return_status  => l_return_status,
                                  x_try_id         => l_release_cm_try_id);
                  IF (is_debug_statement_on) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_transaction_id , return status: ' || l_return_status);
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_release_cm_try_id : ' || l_release_cm_try_id);
                  END IF;

          -- 02-Dec-2004 PAGARG Bug# 4043464, check correct variable for G_MISS value
          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
          OR NVL (l_release_cm_try_id, G_MISS_NUM) = G_MISS_NUM THEN
                     l_return_status := okl_api.g_ret_sts_error;
                     okc_api.set_message (
                                  p_app_name => g_okc_app_name,
                                  p_msg_name => g_invalid_value,
                                  p_token1   => g_col_name_token,
                                  p_token1_value => 'transaction type');
          END IF;
    END IF;


        IF  NVL (p_pos_amount, 0) IN (G_MISS_NUM, 0)
        AND NVL (p_neg_amount, 0) IN (G_MISS_NUM, 0)THEN
                 l_return_status := OKL_API.G_RET_STS_ERROR;
                 OKC_API.SET_MESSAGE (
                                  p_app_name => G_OKC_APP_NAME,
                                  p_msg_name => G_REQUIRED_VALUE,
                                  p_token1   => G_COL_NAME_TOKEN,
                                  p_token1_value => 'Amount');
        END IF;

        IF NVL (p_taiv_rec.khr_id, G_MISS_NUM) = G_MISS_NUM THEN
                l_return_status := OKL_API.G_RET_STS_ERROR;
                OKC_API.SET_MESSAGE (
                                  p_app_name => G_OKC_APP_NAME,
                                  p_msg_name => G_REQUIRED_VALUE,
                                  p_token1   => G_COL_NAME_TOKEN,
                                  p_token1_value => 'Contract_Id');
        END IF;

        IF NVL (p_taiv_rec.currency_code, G_MISS_CHAR) = G_MISS_CHAR THEN
               l_return_status := OKL_API.G_RET_STS_ERROR;
               OKC_API.SET_MESSAGE (
                                  p_app_name => G_OKC_APP_NAME,
                                  p_msg_name => G_REQUIRED_VALUE,
                                  p_token1   => G_COL_NAME_TOKEN,
                                  p_token1_value => 'Currency_Code');
        END IF;

        IF NVL (p_taiv_rec.description, G_MISS_CHAR) = G_MISS_CHAR THEN
               l_return_status := OKL_API.G_RET_STS_ERROR;
               OKC_API.SET_MESSAGE (
                                  p_app_name => G_OKC_APP_NAME,
                                  p_msg_name => G_REQUIRED_VALUE,
                                  p_token1   => G_COL_NAME_TOKEN,
                                  p_token1_value => 'Description');
        END IF;


 l_taiv_rec                 := p_taiv_rec;
 l_taiv_rec.trx_status_code := G_SUBMIT_STATUS;

 IF NVL (l_taiv_rec.date_entered, G_MISS_DATE) = G_MISS_DATE THEN
  l_taiv_rec.date_entered  := l_sysdate;
 END IF;

 IF NVL (l_taiv_rec.date_invoiced, G_MISS_DATE) = G_MISS_DATE THEN
  l_taiv_rec.date_invoiced := l_sysdate;
 END IF;

 -- from lines

 IF p_tilv_tbl.COUNT > 0 THEN
   --akrangan bug 6494341 fix start
   --changed the looping structure from for loop to normal loop
   --this approach gives error while indices are not sequential
   i := p_tilv_tbl.FIRST;
   LOOP
   --akrangan bug 6494341 fix end

       IF NVL (p_tilv_tbl(i).amount, G_MISS_NUM) = G_MISS_NUM THEN
                     l_return_status := OKL_API.G_RET_STS_ERROR;
                     OKC_API.SET_MESSAGE (
                                        p_app_name => G_OKC_APP_NAME,
                                        p_msg_name => G_REQUIRED_VALUE,
                                        p_token1 => G_COL_NAME_TOKEN,
                                        p_token1_value => 'Amount');
       END IF;

/* Begin - Bug#5874824 - Asset Remarketing Fix
	-- Removed the mandatory check for Invoice Header Id in invoice lines table (p_tilv_tbl(i).tai_id)
	-- Since the invoice header and lines will be created from the common billing API call
	-- Invoice header id will be assigned before calling Line creation call in 'okl_internal_billing_pvt'
-- End  - Bug#5874824 - Asset Remarketing Fix  */

       IF NVL (p_tilv_tbl(i).sty_id, G_MISS_NUM) = G_MISS_NUM THEN
                     l_return_status := OKL_API.G_RET_STS_ERROR;
                     OKC_API.SET_MESSAGE (
                                       p_app_name => G_OKC_APP_NAME,
                                       p_msg_name => G_REQUIRED_VALUE,
                                       p_token1 => G_COL_NAME_TOKEN,
                                       p_token1_value => 'Stream_Type_Id');
       END IF;

       IF NVL (p_tilv_tbl(i).description, G_MISS_CHAR) = G_MISS_CHAR THEN
                    l_return_status := OKL_API.G_RET_STS_ERROR;
                    OKC_API.SET_MESSAGE (
                                       p_app_name => G_OKC_APP_NAME,
                                       p_msg_name => G_REQUIRED_VALUE,
                                       p_token1 => G_COL_NAME_TOKEN,
                                       p_token1_value => 'Description');
       END IF;


IF p_tilv_tbl(i).amount > 0 then
     l_pos_tilv_tbl(j):=p_tilv_tbl(i);
      l_pos_tilv_tbl(j).inv_receiv_line_code := G_AR_INV_LINE_CODE;
     j:=j+1;
elsif p_tilv_tbl(i).amount < 0 then
      l_neg_tilv_tbl(k):=p_tilv_tbl(i);
      l_neg_tilv_tbl(k).inv_receiv_line_code := G_AR_INV_LINE_CODE;
      k:=k+1;
end if;
   --akrangan bug 6494341 fix start
    exit when (i = p_tilv_tbl.last);
    i := p_tilv_tbl.next(i);
    --akrangan bug 6494341 fix end
   END LOOP;
 END IF;

 IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
 AND p_pos_amount > 0 THEN

      -- If quote type is rollover and transaction type is rollover then set
      -- set rollover credit memo transaction id for positive amounts
      IF p_quote_type LIKE 'TER_ROLL%'
      AND p_trans_type = 'REVERSE' THEN
          l_taiv_rec.try_id := l_roll_cm_try_id;
      -- pagarg +++ T and A +++
      ELSIF p_quote_type = 'TER_RELEASE_WO_PURCHASE'
      AND p_trans_type = 'REVERSE' THEN
      -- bug 9360601
      --   l_taiv_rec.try_id := l_release_cm_try_id;
          l_taiv_rec.try_id  :=  l_release_bill_try_id;

      ELSE
         l_taiv_rec.try_id := l_pos_try_id;
      END IF;

     l_taiv_rec.amount := p_pos_amount;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_internal_billing_pvt.create_billing_trx');
     END IF;

     okl_internal_billing_pvt.create_billing_trx(p_api_version   => l_api_version,
                                                 p_init_msg_list => OKL_API.G_FALSE,
                                                 x_return_status => l_return_status, -- 6140786
                                                 x_msg_count     => l_msg_count,
                                                 x_msg_data      => l_msg_data,
                                                 p_taiv_rec      => l_taiv_rec,
                                                 p_tilv_tbl      => l_pos_tilv_tbl,
                                                 p_tldv_tbl      => l_tldv_tbl,
                                                 x_taiv_rec      => x_pos_taiv_rec,
                                                 x_tilv_tbl      => lx_tilv_tbl,
                                                 x_tldv_tbl      => lx_tldv_tbl);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_internal_billing_pvt.create_billing_trx , return status: ' || l_return_status);
     END IF;

 END IF;

 IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
 AND p_neg_amount < 0 THEN


      -- If quote type is rollover and transaction type is rollover then set
      -- set rollover billing transaction id for negative amounts
      IF p_quote_type LIKE 'TER_ROLL%'
      AND p_trans_type = 'REVERSE' THEN
        l_taiv_rec.try_id := l_roll_bill_try_id;
           -- pagarg +++ T and A +++
      ELSIF p_quote_type = 'TER_RELEASE_WO_PURCHASE'
      AND p_trans_type = 'REVERSE' THEN
       -- l_taiv_rec.try_id := l_release_bill_try_id;
       -- bug 9360601
          l_taiv_rec.try_id := l_release_cm_try_id;
      ELSE
        l_taiv_rec.try_id := l_neg_try_id;
      END IF;

     l_taiv_rec.amount := p_neg_amount;
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_internal_billing_pvt.create_billing_trx');
     END IF;

     okl_internal_billing_pvt.create_billing_trx(p_api_version   => l_api_version,
                                                 p_init_msg_list => OKL_API.G_FALSE,
                                                 x_return_status => l_return_status, -- 6140786
                                                 x_msg_count     => l_msg_count,
                                                 x_msg_data      => l_msg_data,
                                                 p_taiv_rec      => l_taiv_rec,
                                                 p_tilv_tbl      => l_neg_tilv_tbl,
                                                 p_tldv_tbl      => l_tldv_tbl,
                                                 x_taiv_rec      => x_neg_taiv_rec,
                                                 x_tilv_tbl      => lx_tilv_tbl,
                                                 x_tldv_tbl      => lx_tldv_tbl);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_internal_billing_pvt.create_billing_trx , return status: ' || l_return_status);
     END IF;
 END IF;
x_return_status := l_return_status;
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
 END IF;

EXCEPTION
WHEN OTHERS THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
  END IF;
  -- store SQL error message on message stack for caller
  OKL_API.SET_MESSAGE (
                       p_app_name     => G_APP_NAME
                      ,p_msg_name     => G_UNEXPECTED_ERROR
                      ,p_token1       => G_SQLCODE_TOKEN
                      ,p_token1_value => sqlcode
                      ,p_token2       => G_SQLERRM_TOKEN
                      ,p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END create_billing_invoices ;

-- Start of comments
--
-- Procedure Name : Create_AR_Invoice_Header
-- Description  : Create OKL Transaction for AR Invoicing
-- Business Rules :
-- Parameters  : Transaction Record for AR Invoice
-- Version  : 1.0
-- History          : 18-Aug-04 PAGARG Set different transaction types for
--                  : Rollover transactions
--                  : 21-Oct-04 PAGARG Bug# 3925453 Set different transaction types for
--                  : Release transactions
-- End of comments
/* --ansethur 09-MAR-2007 Commented For Billing Architecture Starts
PROCEDURE Create_AR_Invoice_Header (
 p_taiv_rec  IN  taiv_rec_type,
 p_pos_amount  IN  NUMBER,
 p_neg_amount  IN  NUMBER,
 p_quote_type  IN  VARCHAR2 DEFAULT NULL,
 p_trans_type  IN  VARCHAR2 DEFAULT NULL,
 x_pos_taiv_rec  OUT NOCOPY taiv_rec_type,
 x_neg_taiv_rec  OUT NOCOPY taiv_rec_type,
 x_return_status  OUT NOCOPY VARCHAR2) IS

 l_pos_try_id  NUMBER  := NULL;
 l_neg_try_id  NUMBER  := NULL;
 l_sysdate  DATE  := SYSDATE;
 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_taiv_rec  taiv_rec_type;

 l_api_version  CONSTANT NUMBER := G_API_VERSION;
 l_msg_count  NUMBER ;-- rmunjulu bug 4341480 := OKL_API.G_MISS_NUM;
 l_msg_data  VARCHAR2(2000);

 -- pagarg +++ Rollover +++
 -- Variables to store transaction id for rollover biling and rollover credit memo
 l_roll_bill_try_id      NUMBER  DEFAULT NULL;
 l_roll_cm_try_id NUMBER  DEFAULT NULL;
 -- Bug# 3925453: pagarg +++ T and A +++
 -- Variables to store transaction id for release biling and release credit memo
 l_release_bill_try_id   NUMBER  DEFAULT NULL;
 l_release_cm_try_id     NUMBER  DEFAULT NULL;
BEGIN

 -- *******************
 -- Validate parameters
 -- *******************

 okl_am_util_pvt.get_transaction_id (
  p_try_name => G_AR_INV_TRX_TYPE,
  x_return_status => l_return_status,
  x_try_id => l_pos_try_id);

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
 OR NVL (l_pos_try_id, G_MISS_NUM) = G_MISS_NUM THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Transaction Type');
 END IF;

 okl_am_util_pvt.get_transaction_id (
  p_try_name => G_AR_CM_TRX_TYPE,
  x_return_status => l_return_status,
  x_try_id => l_neg_try_id);

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
 OR NVL (l_neg_try_id, G_MISS_NUM) = G_MISS_NUM THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Transaction Type');
 END IF;

    --+++++++++++ pagarg +++ Rollover +++++++ Start ++++++++++
    ----------------------
    -- Obtain transaction id for Rollover transactions
    ----------------------
    --09-Nov-04 PAGARG Bug #4002033 moved the logic to obtain transaction type
    --id inside appropriate condition
    IF p_quote_type LIKE 'TER_ROLL%'
    AND p_trans_type = 'REVERSE' THEN
      okl_am_util_pvt.get_transaction_id (
  p_try_name => 'ROLLOVER BILLING',
  x_return_status => l_return_status,
  x_try_id => l_roll_bill_try_id);

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
      OR NVL (l_roll_bill_try_id, G_MISS_NUM) = G_MISS_NUM THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Transaction Type');
      END IF;

      okl_am_util_pvt.get_transaction_id (
  p_try_name => 'ROLLOVER CREDIT MEMO',
  x_return_status => l_return_status,
  x_try_id => l_roll_cm_try_id);

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
      OR NVL (l_roll_cm_try_id, G_MISS_NUM) = G_MISS_NUM THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Transaction Type');
      END IF;
    END IF;
    --+++++++++++ pagarg +++ Rollover +++++++ End ++++++++++

    --+++++++++++ Bug# 3925453: pagarg +++ T and A +++++++ Start ++++++++++
    ----------------------
    -- Obtain transaction id for Release transactions
    ----------------------
    --09-Nov-04 PAGARG Bug #4002033 moved the logic to obtain transaction type
    --id inside appropriate condition
    IF p_quote_type = 'TER_RELEASE_WO_PURCHASE'
    AND p_trans_type = 'REVERSE' THEN
      okl_am_util_pvt.get_transaction_id (
  p_try_name => 'RELEASE BILLING',
  x_return_status => l_return_status,
  x_try_id => l_release_bill_try_id);

      -- 02-Dec-2004 PAGARG Bug# 4043464, check correct variable for G_MISS value
      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
      OR NVL (l_release_bill_try_id, G_MISS_NUM) = G_MISS_NUM THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Transaction Type');
      END IF;

      okl_am_util_pvt.get_transaction_id (
  p_try_name => 'RELEASE CREDIT MEMO',
  x_return_status => l_return_status,
  x_try_id => l_release_cm_try_id);

      -- 02-Dec-2004 PAGARG Bug# 4043464, check correct variable for G_MISS value
      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
      OR NVL (l_release_cm_try_id, G_MISS_NUM) = G_MISS_NUM THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Transaction Type');
      END IF;
    END IF;
    --+++++++++++ pagarg +++ T and A +++++++ End ++++++++++

 IF  NVL (p_pos_amount, 0) IN (G_MISS_NUM, 0)
 AND NVL (p_neg_amount, 0) IN (G_MISS_NUM, 0)THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_REQUIRED_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Amount');
 END IF;

 IF NVL (p_taiv_rec.khr_id, G_MISS_NUM) = G_MISS_NUM THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_REQUIRED_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Contract_Id');
 END IF;

 IF NVL (p_taiv_rec.currency_code, G_MISS_CHAR) = G_MISS_CHAR THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_REQUIRED_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Currency_Code');
 END IF;

 IF NVL (p_taiv_rec.description, G_MISS_CHAR) = G_MISS_CHAR THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_REQUIRED_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Description');
 END IF;

 -- *********************
 -- Create Invoice Header
 -- *********************

 l_taiv_rec   := p_taiv_rec;
 l_taiv_rec.trx_status_code := G_SUBMIT_STATUS;

 IF NVL (l_taiv_rec.date_entered, G_MISS_DATE) = G_MISS_DATE THEN
  l_taiv_rec.date_entered  := l_sysdate;
 END IF;

 IF NVL (l_taiv_rec.date_invoiced, G_MISS_DATE) = G_MISS_DATE THEN
  l_taiv_rec.date_invoiced := l_sysdate;
 END IF;

 IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
 AND p_pos_amount > 0 THEN

      --+++++++++++ pagarg +++ Rollover +++++++ Start ++++++++++

      -- If quote type is rollover and transaction type is rollover then set
      -- set rollover credit memo transaction id for positive amounts
      IF p_quote_type LIKE 'TER_ROLL%'
      AND p_trans_type = 'REVERSE' THEN
  l_taiv_rec.try_id := l_roll_cm_try_id;
      -- pagarg +++ T and A +++
      ELSIF p_quote_type = 'TER_RELEASE_WO_PURCHASE'
      AND p_trans_type = 'REVERSE' THEN
  l_taiv_rec.try_id := l_release_cm_try_id;
      ELSE
  l_taiv_rec.try_id := l_pos_try_id;
      END IF;

      --+++++++++++ pagarg +++ Rollover +++++++ End ++++++++++

  l_taiv_rec.amount := p_pos_amount;

  okl_trx_ar_invoices_pub.insert_trx_ar_invoices (
   p_api_version => l_api_version,
   p_init_msg_list => OKL_API.G_FALSE,
   x_return_status => l_return_status,
   x_msg_count => l_msg_count,
   x_msg_data => l_msg_data,
   p_taiv_rec => l_taiv_rec,
   x_taiv_rec => x_pos_taiv_rec);

 END IF;

 IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
 AND p_neg_amount < 0 THEN

      --+++++++++++ pagarg +++ Rollover +++++++ Start ++++++++++

      -- If quote type is rollover and transaction type is rollover then set
      -- set rollover billing transaction id for negative amounts
      IF p_quote_type LIKE 'TER_ROLL%'
      AND p_trans_type = 'REVERSE' THEN
  l_taiv_rec.try_id := l_roll_bill_try_id;
      -- pagarg +++ T and A +++
      ELSIF p_quote_type = 'TER_RELEASE_WO_PURCHASE'
      AND p_trans_type = 'REVERSE' THEN
  l_taiv_rec.try_id := l_release_bill_try_id;
      ELSE
  l_taiv_rec.try_id := l_neg_try_id;
      END IF;

      --+++++++++++ pagarg +++ Rollover +++++++ End ++++++++++

  l_taiv_rec.amount := p_neg_amount;

  okl_trx_ar_invoices_pub.insert_trx_ar_invoices (
   p_api_version => l_api_version,
   p_init_msg_list => OKL_API.G_FALSE,
   x_return_status => l_return_status,
   x_msg_count => l_msg_count,
   x_msg_data => l_msg_data,
   p_taiv_rec => l_taiv_rec,
   x_taiv_rec => x_neg_taiv_rec);

 END IF;

 x_return_status := l_return_status;

EXCEPTION

 WHEN OTHERS THEN
  -- store SQL error message on message stack for caller
  OKL_API.SET_MESSAGE (
    p_app_name => G_APP_NAME
   ,p_msg_name => G_UNEXPECTED_ERROR
   ,p_token1 => G_SQLCODE_TOKEN
   ,p_token1_value => sqlcode
   ,p_token2 => G_SQLERRM_TOKEN
   ,p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END Create_AR_Invoice_Header;


-- Start of comments
--
-- Procedure Name : Create_AR_Invoice_Lines
-- Description  : Create OKL Transaction for AR Invoice Lines
-- Business Rules :
-- Parameters  : Transaction Record for AR Invoice Lines
-- Version  : 1.0
-- End of comments

PROCEDURE Create_AR_Invoice_Lines (
 p_tilv_rec  IN  tilv_rec_type,
 x_tilv_rec  OUT NOCOPY tilv_rec_type,
 x_return_status  OUT NOCOPY VARCHAR2) IS

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_tilv_rec  tilv_rec_type;
 l_bpd_acc_rec  bpd_acc_rec_type;

 l_api_version  CONSTANT NUMBER := G_API_VERSION;
 l_msg_count  NUMBER ;-- rmunjulu bug 4341480  := OKL_API.G_MISS_NUM;
 l_msg_data  VARCHAR2(2000);

BEGIN

 -- *******************
 -- Validate parameters
 -- *******************

 IF NVL (p_tilv_rec.amount, G_MISS_NUM) = G_MISS_NUM THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_REQUIRED_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Amount');
 END IF;

 IF NVL (p_tilv_rec.tai_id, G_MISS_NUM) = G_MISS_NUM THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_REQUIRED_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Invoice_Header_Id');
 END IF;

 IF NVL (p_tilv_rec.sty_id, G_MISS_NUM) = G_MISS_NUM THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_REQUIRED_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Stream_Type_Id');
 END IF;

 IF NVL (p_tilv_rec.description, G_MISS_CHAR) = G_MISS_CHAR THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_REQUIRED_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Description');
 END IF;

 -- *******************
 -- Create Invoice Line
 -- *******************

 IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN

  l_tilv_rec   := p_tilv_rec;
  l_tilv_rec.inv_receiv_line_code := G_AR_INV_LINE_CODE;

  -- Create Invoice Line
  okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns (
   p_api_version => l_api_version,
   p_init_msg_list => OKL_API.G_FALSE,
   x_return_status => l_return_status,
   x_msg_count => l_msg_count,
   x_msg_data => l_msg_data,
   p_tilv_rec => l_tilv_rec,
   x_tilv_rec => x_tilv_rec);

 END IF;

 IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN

  l_bpd_acc_rec.id  := x_tilv_rec.id;
  l_bpd_acc_rec.source_table := G_AR_LINES_SOURCE;

  -- Create Accounting Distribution
  okl_acc_call_pub.create_acc_trans (
   p_api_version => l_api_version,
   p_init_msg_list => OKL_API.G_FALSE,
   x_return_status => l_return_status,
   x_msg_count => l_msg_count,
   x_msg_data => l_msg_data,
   p_bpd_acc_rec => l_bpd_acc_rec);

 END IF;

 x_return_status := l_return_status;

EXCEPTION

 WHEN OTHERS THEN
  -- store SQL error message on message stack for caller
  OKL_API.SET_MESSAGE (
    p_app_name => G_APP_NAME
   ,p_msg_name => G_UNEXPECTED_ERROR
   ,p_token1 => G_SQLCODE_TOKEN
   ,p_token1_value => sqlcode
   ,p_token2 => G_SQLERRM_TOKEN
   ,p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END Create_AR_Invoice_Lines;
*/ --ansethur 09-MAR-2007 Commented For Billing Architecture Ends

-- Start of comments
--
-- Procedure Name : Validate_Populate_Repair
-- Description  : Ensure that invoice is approved, billed first
--                     time, has Bill To Flag and unique Contract Line
--                        Populates Header Fields: Khr Id, Description, Amount,
--                        Currency; populates common line fields: Kle_Id, Sty_Id
-- Business Rules :
-- Parameters    : asset return fields
-- Version      : 1.0
-- History        : RMUNJULU 30-DEC-02 2726739 Changed cursor and taiv_rec
--                        to set currency columns
--                : PAGARG 4044659 25-Jan-2005 Obtain inventory org id from
--                  contract and assign it to tilv_rec if LEASE_INV_ORG_YN
--                  is Y in OKL_SYSTEM_PARAMS_ALL
--                : PAGARG 14-Feb-2005 Bug 3559535, pass l_vendor_status in call
--                  to get_vendor_billing_info and based on the value of l_vendor_status
--                  set the value for l_return_status
-- End of comments

PROCEDURE Validate_Populate_Repair (
 p_ariv_tbl  IN  ariv_tbl_type,
 x_pos_amount  OUT NOCOPY NUMBER,
 x_neg_amount  OUT NOCOPY NUMBER,
 x_taiv_rec  OUT NOCOPY taiv_rec_type,
 x_tilv_rec  OUT NOCOPY tilv_rec_type,
 x_return_status  OUT NOCOPY VARCHAR2) IS

 -- Returns Contract Line IDs For Asset Condition Line
  -- RMUNJULU 30-DEC-02 2726739 -- Added columns for multi-currency get values
  -- from asset_cndtn_lns
  --PAGARG Bug 4044659 Query Contract inventory org id
 CURSOR l_cle_csr (cp_acn_id IN NUMBER) IS
  SELECT kle.chr_id  chr_id,
   kle.id   cle_id,
   kle.name  asset_number,
   acn.currency_code currency_code,
      acn.currency_conversion_type currency_conversion_type,
      acn.currency_conversion_rate currency_conversion_rate,
      acn.currency_conversion_date currency_conversion_date
      ,chr.inv_organization_id inv_organization_id
  FROM okl_asset_cndtn_lns_b acn,
   okl_asset_cndtns acd,
   okc_k_lines_v  kle
   ,okc_k_headers_b chr
  WHERE acn.id   = cp_acn_id
  AND acd.id   = acn.acd_id
  AND kle.id   = acd.kle_id
  AND kle.dnz_chr_id = chr.id;

 -- Get the part name for the asset condition line
 CURSOR l_part_csr (cp_acn_id IN NUMBER) IS
  SELECT acn.part_name
  FROM okl_asset_cndtn_lns_v acn
  WHERE acn.id   = cp_acn_id;

 l_cle_rec  l_cle_csr%ROWTYPE;
 l_taiv_rec  taiv_rec_type;
 l_tilv_rec  tilv_rec_type;

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_bill_to_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_cle_mismatch  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_acn_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_stream_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_amount_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- PAGARG Bug 3559535 variable to store status of vendor billing info call
 l_vendor_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

 l_approval_counter NUMBER  := 0;
 l_invoiced_counter NUMBER  := 0;
 l_sty_id  NUMBER  := NULL;

 l_pos_amount  NUMBER  := 0;
 l_neg_amount  NUMBER  := 0;

 l_cnt   NUMBER;
 l_bill_to_flag  NUMBER;
 l_part_name  VARCHAR2(200);
    --PAGARG Bug 4044659 Cursor to obtain operational options values
    CURSOR l_sys_prms_csr IS
      SELECT NVL(LEASE_INV_ORG_YN, 'N') LEASE_INV_ORG_YN
      FROM OKL_SYSTEM_PARAMS;
    l_sys_prms_rec l_sys_prms_csr%ROWTYPE;

    -- RRAVIKIR Legal Entity Changes
    CURSOR l_assetreturns_csr(cp_kle_id IN NUMBER) IS
    SELECT legal_entity_id
    FROM okl_asset_returns_all_b
    WHERE kle_id = cp_kle_id;

    l_legal_entity_id   NUMBER;
    -- Legal Entity Changes End
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'validate_populate_repair';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
 END IF;
 IF (is_debug_statement_on) THEN
   FOR i IN p_ariv_tbl.FIRST..p_ariv_tbl.LAST LOOP
     IF (p_ariv_tbl.exists(i)) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_ariv_tbl(' || i || ').p_bill_to : ' || p_ariv_tbl(i).p_bill_to);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_ariv_tbl(' || i || ').p_approved_yn : ' || p_ariv_tbl(i).p_approved_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_ariv_tbl(' || i || ').p_acd_id_cost : ' || p_ariv_tbl(i).p_acd_id_cost);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_ariv_tbl(' || i || ').p_acn_id : ' || p_ariv_tbl(i).p_acn_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_ariv_tbl(' || i || ').p_actual_repair_cost : ' || p_ariv_tbl(i).p_actual_repair_cost);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_ariv_tbl(' || i || ').p_condition_type : ' || p_ariv_tbl(i).p_condition_type);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_ariv_tbl(' || i || ').p_damage_type : ' || p_ariv_tbl(i).p_damage_type);
     END IF;
   END LOOP;
 END IF;

 -- *****************
 -- Check all records
 -- *****************

 -- Initialize procedure variables
 l_cnt   := p_ariv_tbl.FIRST;
 l_bill_to_flag  := p_ariv_tbl(l_cnt).p_bill_to;
    --PAGARG Bug 4044659 Open and fetch values from l_sys_prms_csr
    OPEN l_sys_prms_csr;
    FETCH l_sys_prms_csr INTO l_sys_prms_rec;
    -- IF no row fetched from cursor then set the value as N for LEASE_INV_ORG_YN
    IF l_sys_prms_csr%NOTFOUND
    THEN
        l_sys_prms_rec.LEASE_INV_ORG_YN := 'N';
    END IF;

    CLOSE l_sys_prms_csr;

 LOOP

  -- Check that all records have been approved
  IF NVL (p_ariv_tbl(l_cnt).p_approved_yn, G_MISS_CHAR) <> 'Y' THEN
   l_approval_counter := l_approval_counter + 1;
  END IF;

  -- Check that no records have been previously invoiced
  IF NVL (p_ariv_tbl(l_cnt).p_acd_id_cost, G_MISS_NUM) <> G_MISS_NUM THEN
   l_invoiced_counter := l_invoiced_counter + 1;
   -- Get the part no for the asset condition line
   OPEN l_part_csr(p_ariv_tbl(l_cnt).p_acn_id );
   FETCH l_part_csr INTO l_part_name;
   CLOSE l_part_csr;

      l_return_status  := OKL_API.G_RET_STS_ERROR;

                     IF l_part_name IS NULL THEN
                      --Rkuttiya added for bug:3528618
                        --Message Text: Unable to process request for
                        -- a Invoice creation. Invoice(s) already exists for part PART_NUMBER.
                        OKL_API.SET_MESSAGE (
          p_app_name => G_APP_NAME,
          p_msg_name => 'OKL_AM_INV_EXIST');

                     ELSE

      -- Message Text: Unable to process request for
      -- a Invoice creation. Invoice(s) already exists for part PART_NUMBER.
      OKL_API.SET_MESSAGE (
          p_app_name => G_APP_NAME,
          p_msg_name => 'OKL_AM_INVOICES_EXIST',
    p_token1 => 'PART_NUMBER',
    p_token1_value => l_part_name);
                     END IF;

  END IF;

  -- Check that amount is passed and calculate invoice total
  IF p_ariv_tbl(l_cnt).p_actual_repair_cost IS NULL
  OR p_ariv_tbl(l_cnt).p_actual_repair_cost = G_MISS_NUM
  OR p_ariv_tbl(l_cnt).p_actual_repair_cost = 0 THEN
   l_amount_status := OKL_API.G_RET_STS_ERROR;
  ELSIF p_ariv_tbl(l_cnt).p_actual_repair_cost > 0 THEN
   l_pos_amount := l_pos_amount +
    p_ariv_tbl(l_cnt).p_actual_repair_cost;
  ELSIF p_ariv_tbl(l_cnt).p_actual_repair_cost < 0 THEN
   l_neg_amount := l_neg_amount +
    p_ariv_tbl(l_cnt).p_actual_repair_cost;
  END IF;

  -- Check that Bill To has been indicated
  IF NVL (p_ariv_tbl(l_cnt).p_bill_to, G_MISS_NUM) NOT IN (1,2)
  OR p_ariv_tbl(l_cnt).p_bill_to <> l_bill_to_flag THEN
   l_bill_to_status := OKL_API.G_RET_STS_ERROR;
  ELSE

   -- Get Contract IDs
   OPEN l_cle_csr (p_ariv_tbl(l_cnt).p_acn_id);
   FETCH l_cle_csr INTO l_cle_rec;

   IF l_cle_csr%NOTFOUND THEN
       l_acn_status := OKL_API.G_RET_STS_ERROR;

   ELSE
       IF NVL (l_tilv_rec.kle_id, G_MISS_NUM) = G_MISS_NUM THEN
    -- Save Contract information
    l_tilv_rec.kle_id  := l_cle_rec.cle_id;

                                -- RRAVIKIR Legal Entity Changes
                                OPEN l_assetreturns_csr(cp_kle_id => l_cle_rec.cle_id);
                                FETCH l_assetreturns_csr INTO l_legal_entity_id;
                                CLOSE l_assetreturns_csr;

                                IF (l_legal_entity_id is null or l_legal_entity_id = OKC_API.G_MISS_NUM) THEN
                                    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                                        p_msg_name     => g_required_value,
                                                        p_token1       => g_col_name_token,
                                                        p_token1_value => 'legal_entity_id');
                                    RAISE OKC_API.G_EXCEPTION_ERROR;
                                END IF;

                                -- Legal Entity Changes End

                --PAGARG Bug 4044659 If LEASE_INV_ORG_YN is Y then set the value of
                --INVENTORY_ORG_ID in invoice line with contract inv_organization_id
                IF l_sys_prms_rec.LEASE_INV_ORG_YN = 'Y'
                THEN
                    l_tilv_rec.inventory_org_id := l_cle_rec.inv_organization_id;
                END IF;
    l_taiv_rec.khr_id  := l_cle_rec.chr_id;
    l_taiv_rec.description  := l_cle_rec.asset_number;
    l_taiv_rec.currency_code := l_cle_rec.currency_code;
    -- ansethur 05-jun-07 R12B Billing Architecture
    l_taiv_rec.OKL_SOURCE_BILLING_TRX :='ASSET_REPAIR';

    -- RMUNJULU 30-DEC-02 2726739 -- Added for multi-currency
    l_taiv_rec.currency_conversion_type := l_cle_rec.currency_conversion_type;
    l_taiv_rec.currency_conversion_rate := l_cle_rec.currency_conversion_rate;
    l_taiv_rec.currency_conversion_date := l_cle_rec.currency_conversion_date;

    -- RRAVIKIR Legal Entity Changes
    l_taiv_rec.legal_entity_id  := l_legal_entity_id;
    -- Legal Entity Changes End

       ELSE
    IF l_tilv_rec.kle_id <> l_cle_rec.cle_id THEN
        l_cle_mismatch := OKL_API.G_RET_STS_ERROR;
    END IF;
       END IF;
   END IF;

   CLOSE l_cle_csr;

  END IF;

  EXIT WHEN (l_cnt = p_ariv_tbl.LAST);
  l_cnt := p_ariv_tbl.NEXT(l_cnt);

 END LOOP;

 -- ***************
 -- Get stream type
 -- ***************
/* bug 4631541
 okl_am_util_pvt.get_stream_type_id (
  p_sty_code => G_REPAIR_STREAM,
  x_return_status => l_stream_status,
  x_sty_id => l_sty_id);
*/
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_STREAMS_UTIL.get_primary_stream_type');
     END IF;
    OKL_STREAMS_UTIL.get_primary_stream_type(l_cle_rec.chr_id,
                                             G_REPAIR_STREAM,
                                             l_stream_status,
                                             l_sty_id);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_STREAMS_UTIL.get_primary_stream_type , l_stream_status: ' || l_stream_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_sty_id: ' || l_sty_id);
     END IF;

 IF l_stream_status <> OKL_API.G_RET_STS_SUCCESS
 OR NVL (l_sty_id, G_MISS_NUM) = G_MISS_NUM THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Stream_Type');
 ELSE
  l_tilv_rec.sty_id := l_sty_id;
 END IF;

 -- ****************
 -- Get Bill_To info
 -- ****************

 -- Bill Vendor
 IF l_bill_to_flag = 1 THEN
 -- PAGARG Bug 3559535 Pass l_vendor_status instead of l_return_status and if
 -- l_vendor_status is not success then set l_return_status as error
  -- Get Customer and Bill_To linked to a Vendor
  Get_Vendor_Billing_Info (
   px_taiv_rec => l_taiv_rec,
   x_return_status => l_vendor_status);

  IF l_vendor_status <> OKL_API.G_RET_STS_SUCCESS
  THEN
   l_return_status := OKL_API.G_RET_STS_ERROR;
  END IF;

 -- Bill Lessee
 ELSIF l_bill_to_flag = 2
 AND   NVL (l_taiv_rec.khr_id, G_MISS_NUM) <> G_MISS_NUM THEN
  NULL; -- BPD derives billing info using KHR_ID

 ELSE
  l_bill_to_status := OKL_API.G_RET_STS_ERROR;
 END IF;

 -- **************
 -- Display errors
 -- **************

 IF l_approval_counter > 0 THEN
  l_return_status  := OKL_API.G_RET_STS_ERROR;
  -- Message Text: Unable to process the request for a Repair Invoice.
  -- Approval for OUTSTANDING_APPROVALS repair line(s) outstanding.
  OKL_API.SET_MESSAGE (
   p_app_name => G_APP_NAME,
   p_msg_name => 'OKL_AM_APPROVALS_OUTSTANDING',
   p_token1 => 'OUTSTANDING_APPROVALS',
   p_token1_value => l_approval_counter);
 END IF;

/*
        IF l_invoiced_counter > 0 THEN
  l_return_status  := OKL_API.G_RET_STS_ERROR;
  -- Message Text: Unable to process request for
  -- a Invoice creation. Invoice(s) already exists for part PART_NUMBER.
  OKL_API.SET_MESSAGE (
   p_app_name => G_APP_NAME,
   p_msg_name => 'OKL_AM_INVOICES_EXIST');
 END IF;
*/
        IF l_bill_to_status <> OKL_API.G_RET_STS_SUCCESS THEN
  l_return_status  := OKL_API.G_RET_STS_ERROR;
  -- Message Text: Invalid value for the column P_BILL_ID
  OKL_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'p_bill_to');
        END IF;

        IF l_cle_mismatch <> OKL_API.G_RET_STS_SUCCESS THEN
  l_return_status  := OKL_API.G_RET_STS_ERROR;
  -- Message Text: Invalid value for the column CLE_ID
  OKL_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'cle_id');
        END IF;

        IF l_acn_status <> OKL_API.G_RET_STS_SUCCESS THEN
  l_return_status  := OKL_API.G_RET_STS_ERROR;
  -- Message Text: Invalid value for the column P_ACN_ID
  OKL_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'p_acn_id');
        END IF;

        IF l_amount_status <> OKL_API.G_RET_STS_SUCCESS THEN
  l_return_status  := OKL_API.G_RET_STS_ERROR;
/*
  -- Message Text: Invalid value for the column P_ACTUAL_REPAIR_COST
  OKL_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'p_actual_repair_cost');
*/
  -- You must enter a value for PROMPT
  OKL_API.set_message (
   p_app_name => G_APP_NAME,
   p_msg_name => 'OKL_AM_REQ_FIELD_ERR',
   p_token1 => 'PROMPT',
   p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_ACTUAL_REPAIR_COST'));

        END IF;

 x_pos_amount := l_pos_amount;
 x_neg_amount := l_neg_amount;
 x_taiv_rec := l_taiv_rec;
 x_tilv_rec := l_tilv_rec;
 x_return_status := l_return_status;
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
 END IF;

EXCEPTION

 WHEN OTHERS THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
  END IF;

  IF l_cle_csr%ISOPEN THEN
   CLOSE l_cle_csr;
  END IF;
        --PAGARG Bug 4044659 Close the cusrsor if open
  IF l_sys_prms_csr%ISOPEN THEN
   CLOSE l_sys_prms_csr;
  END IF;

  IF l_assetreturns_csr%ISOPEN THEN
                  CLOSE l_assetreturns_csr;
  END IF;

  -- store SQL error message on message stack for caller
  OKL_API.SET_MESSAGE (
    p_app_name => G_APP_NAME
   ,p_msg_name => G_UNEXPECTED_ERROR
   ,p_token1 => G_SQLCODE_TOKEN
   ,p_token1_value => sqlcode
   ,p_token2 => G_SQLERRM_TOKEN
   ,p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END Validate_Populate_Repair;


-- Start of comments
--
-- Procedure Name : Create_Repair_Invoice
-- Description  : Create Invoice for Asset Repair
-- Business Rules :
-- Parameters  : asset return fields
-- Version  : 1.0
-- End of comments

PROCEDURE Create_Repair_Invoice (
 p_api_version    IN  NUMBER,
 p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 p_ariv_tbl       IN  ariv_tbl_type,
 x_taiv_tbl       OUT NOCOPY taiv_tbl_type) IS

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

 l_api_name     CONSTANT VARCHAR2(30) :=
     'Create_Repair_Invoice';
 l_api_version  CONSTANT NUMBER := G_API_VERSION;
 l_msg_count    NUMBER ;-- rmunjulu bug 4341480  := OKL_API.G_MISS_NUM;
 l_msg_data     VARCHAR2(2000);
 l_cnt          NUMBER;

 l_pos_amount   NUMBER  := 0;
 l_neg_amount   NUMBER  := 0;

 l_taiv_rec  taiv_rec_type;
 lx_pos_taiv_rec  taiv_rec_type;
 lx_neg_taiv_rec  taiv_rec_type;
 l_tilv_rec  tilv_rec_type;
 lx_tilv_rec  tilv_rec_type;

-- ANSETHUR 08-MAR-2007 R12B Added For Billing Architecture
 l_tilv_tbl   tilv_tbl_type;
 lx_tilv_tbl  tilv_tbl_type;
-- ANSETHUR 08-MAR-2007 R12B Added For Billing Architecture
 l_module_name VARCHAR2(500) := G_MODULE_NAME || 'create_repair_invoice';
 is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
 is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
 is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
 END IF;
 IF (is_debug_statement_on) THEN
   FOR i IN p_ariv_tbl.FIRST..p_ariv_tbl.LAST LOOP
     IF (p_ariv_tbl.exists(i)) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_ariv_tbl(' || i || ').p_bill_to : ' || p_ariv_tbl(i).p_bill_to);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_ariv_tbl(' || i || ').p_approved_yn : ' || p_ariv_tbl(i).p_approved_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_ariv_tbl(' || i || ').p_acd_id_cost : ' || p_ariv_tbl(i).p_acd_id_cost);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_ariv_tbl(' || i || ').p_acn_id : ' || p_ariv_tbl(i).p_acn_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_ariv_tbl(' || i || ').p_actual_repair_cost : ' || p_ariv_tbl(i).p_actual_repair_cost);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_ariv_tbl(' || i || ').p_condition_type : ' || p_ariv_tbl(i).p_condition_type);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_ariv_tbl(' || i || ').p_damage_type : ' || p_ariv_tbl(i).p_damage_type);
     END IF;
   END LOOP;
 END IF;

 -- ***************************************************************
 -- Check API version, initialize message list and create savepoint
 -- ***************************************************************

 l_return_status := OKL_API.START_ACTIVITY (l_api_name,
                                            G_PKG_NAME,
                                            p_init_msg_list,
                                            l_api_version,
                                            p_api_version,
                                            '_PVT',
                                            x_return_status);

 IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
 END IF;

 -- **********************************************
 -- Validate parameters and populate common fields
 -- **********************************************

 IF p_ariv_tbl.COUNT = 0 THEN

  OKC_API.SET_MESSAGE (
                       p_app_name     => G_OKC_APP_NAME,
                       p_msg_name     => 'OKC_NO_PARAMS',
                       p_token1       => 'PARAM',
                       p_token1_value => 'ARIV_TBL',
                       p_token2       => 'PROCESS',
                       p_token2_value => l_api_name);

  RAISE OKL_API.G_EXCEPTION_ERROR;

 END IF;

 -- Validate all in-records
 -- Populate header: Amount, Description, Currency and Contract_Id
 -- Populate common line fields: Contract_Line_Id and Stream_Type_Id
 Validate_Populate_Repair (
                          p_ariv_tbl      => p_ariv_tbl,
                          x_pos_amount    => l_pos_amount,
                          x_neg_amount    => l_neg_amount,
                          x_taiv_rec      => l_taiv_rec,
                          x_tilv_rec      => l_tilv_rec,
                          x_return_status => l_return_status);
 IF (is_debug_statement_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called Validate_Populate_Repair , return status: ' || l_return_status);
 END IF;

 IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
 END IF;

-- ANSETHUR 08-MAR-2007 R12B Billing Architecture Start Changes
-- Replaced the call of  Create_AR_Invoice_Header and Create_AR_Invoice_Lines
-- with the Create_billing_invoices Procedure which is created as
-- a part of new billing architecture.
-- Added loop to populate l_tilv_tbl which has to be passed to the new procedure

 l_cnt := p_ariv_tbl.FIRST;
 LOOP

     l_tilv_rec.line_number := l_cnt;
     l_tilv_rec.acn_id_cost := p_ariv_tbl(l_cnt).p_acn_id;
     l_tilv_rec.amount  := p_ariv_tbl(l_cnt).p_actual_repair_cost;

     IF  NVL (p_ariv_tbl(l_cnt).p_condition_type, G_MISS_CHAR) <> G_MISS_CHAR
     AND NVL (p_ariv_tbl(l_cnt).p_damage_type, G_MISS_CHAR) <> G_MISS_CHAR THEN
        l_tilv_rec.description := p_ariv_tbl(l_cnt).p_condition_type || ' - ' ||
        p_ariv_tbl(l_cnt).p_damage_type;
     ELSIF NVL (p_ariv_tbl(l_cnt).p_condition_type, G_MISS_CHAR) <> G_MISS_CHAR THEN
        l_tilv_rec.description := p_ariv_tbl(l_cnt).p_condition_type;
     ELSIF NVL (p_ariv_tbl(l_cnt).p_damage_type, G_MISS_CHAR) <> G_MISS_CHAR THEN
        l_tilv_rec.description := p_ariv_tbl(l_cnt).p_damage_type;
     ELSE
        l_tilv_rec.description := NULL;
     END IF;

     l_tilv_tbl(l_cnt):= l_tilv_rec ;

  EXIT WHEN ( l_cnt = p_ariv_tbl.LAST OR l_return_status <> OKL_API.G_RET_STS_SUCCESS);
     l_cnt := p_ariv_tbl.NEXT(l_cnt);
 END LOOP;

   Create_billing_invoices (  p_taiv_rec     =>l_taiv_rec,
                              p_pos_amount   =>l_pos_amount,
                              p_neg_amount   =>l_neg_amount,
                              p_tilv_tbl     =>l_tilv_tbl,
                              x_tilv_tbl     =>lx_tilv_tbl,
                              x_pos_taiv_rec =>lx_pos_taiv_rec ,
                              x_neg_taiv_rec =>lx_neg_taiv_rec,
                              x_return_status=>l_return_status);
   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called Create_billing_invoices , return status: ' || l_return_status);
   END IF;


/* ansethur 08-MAR-2007 R12B Commented for Billing Architecture
 -- *********************
 -- Create Invoice Header
 -- *********************

 Create_AR_Invoice_Header (
  p_taiv_rec => l_taiv_rec,
  p_pos_amount => l_pos_amount,
  p_neg_amount => l_neg_amount,
  x_pos_taiv_rec => lx_pos_taiv_rec,
  x_neg_taiv_rec => lx_neg_taiv_rec,
  x_return_status => l_return_status);

 IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
 END IF;

 -- *********************************************
 -- Create Invoice Lines for each record in table
 -- *********************************************

 l_cnt := p_ariv_tbl.FIRST;

 LOOP

     l_tilv_rec.line_number := l_cnt;
     l_tilv_rec.acn_id_cost := p_ariv_tbl(l_cnt).p_acn_id;
     l_tilv_rec.amount  := p_ariv_tbl(l_cnt).p_actual_repair_cost;

     IF    l_tilv_rec.amount > 0 THEN
       l_tilv_rec.tai_id := lx_pos_taiv_rec.id;
     ELSIF l_tilv_rec.amount < 0 THEN
       l_tilv_rec.tai_id := lx_neg_taiv_rec.id;
     ELSE
       l_tilv_rec.tai_id := NULL;
     END IF;

     IF  NVL (p_ariv_tbl(l_cnt).p_condition_type, G_MISS_CHAR) <> G_MISS_CHAR
     AND NVL (p_ariv_tbl(l_cnt).p_damage_type, G_MISS_CHAR) <> G_MISS_CHAR THEN
        l_tilv_rec.description := p_ariv_tbl(l_cnt).p_condition_type || ' - ' ||
        p_ariv_tbl(l_cnt).p_damage_type;
     ELSIF NVL (p_ariv_tbl(l_cnt).p_condition_type, G_MISS_CHAR) <> G_MISS_CHAR THEN
        l_tilv_rec.description := p_ariv_tbl(l_cnt).p_condition_type;
     ELSIF NVL (p_ariv_tbl(l_cnt).p_damage_type, G_MISS_CHAR) <> G_MISS_CHAR THEN
        l_tilv_rec.description := p_ariv_tbl(l_cnt).p_damage_type;
     ELSE
        l_tilv_rec.description := NULL;
     END IF;

     Create_AR_Invoice_Lines (
                             p_tilv_rec => l_tilv_rec,
                             x_tilv_rec => lx_tilv_rec,
                             x_return_status => l_return_status);

     EXIT WHEN ( l_cnt = p_ariv_tbl.LAST
   OR l_return_status <> OKL_API.G_RET_STS_SUCCESS);
     l_cnt := p_ariv_tbl.NEXT(l_cnt);

 END LOOP;
*/
-- ansethur 08-MAR-2007 R12B Billing Architecture End Changes

 IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
 END IF;

 -- **************
 -- Return results
 -- **************

 l_cnt := 0;

 IF l_pos_amount > 0 THEN
  l_cnt := l_cnt + 1;
  x_taiv_tbl (l_cnt) := lx_pos_taiv_rec;
 END IF;

 IF l_neg_amount < 0 THEN
  l_cnt := l_cnt + 1;
  x_taiv_tbl (l_cnt) := lx_neg_taiv_rec;
 END IF;

 x_return_status := l_overall_status;

 OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
 END IF;

EXCEPTION

 WHEN OKL_API.G_EXCEPTION_ERROR THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
  END IF;
  x_return_status := OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OKL_API.G_RET_STS_ERROR',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

 WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
  END IF;
  x_return_status :=OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OKL_API.G_RET_STS_UNEXP_ERROR',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

 WHEN OTHERS THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
  END IF;

  x_return_status :=OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OTHERS',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

END Create_Repair_Invoice;


-- Start of comments
--
-- Procedure Name : Validate_Populate_Remarket
-- Description  : Ensure order line is coneected to asset return
--                        and has not been billed before
--                        Populates all header fields
--                        Populates all line fields
-- Business Rules :
-- Parameters     : asset return fields
-- Version      : 1.0
-- History          : RMUNJULU 30-DEC-02 2726739 Changed cursor and taiv_rec
--                        to set currency columns
--                  : SECHAWLA 01-NOV-04 3967398 : create remarket invoice for remarket item
--                  : rmunjulu bug 4056364 Removed Quote line alloc message
--                  : PAGARG 4044659 25-Jan-2005 Assign order lines' or header's
--                    sold_from_org_id and assign it to tilv_rec.inventory_org_id
--                    if LEASE_INV_ORG_YN is Y in OKL_SYSTEM_PARAMS_ALL
--                  : rmunjulu 3985369 Added code to get Ship_From Org Id from the order lines and
--                    pass as inventory_org_id when creating invoice transaction lines
-- End of comments

PROCEDURE Validate_Populate_Remarket (
 p_order_line_id  IN  NUMBER,
 x_pos_amount  OUT NOCOPY NUMBER,
 x_neg_amount  OUT NOCOPY NUMBER,
 x_taiv_rec   OUT NOCOPY taiv_rec_type,
 x_tilv_rec   OUT NOCOPY tilv_rec_type,
 x_return_status  OUT NOCOPY VARCHAR2) IS

 -- Returns Contract Line and Asset Return records
  -- RMUNJULU 30-DEC-02 2726739 -- Added columns for multi-currency get values
  -- from asset_returns
 CURSOR l_art_csr (cp_order_line_id IN NUMBER) IS
  SELECT oli.unit_selling_price price,
         oli.ordered_quantity quantity,
         ohe.ordered_date ordered_date,
         kle.chr_id  chr_id,
         kle.id   cle_id,
         kle.name  asset_number,
         kle.item_description asset_description,
         csu.cust_acct_site_id ibt_id,
         csu.cust_account_id ixx_id,
         ohe.transactional_curr_code currency_code,
         ohe.conversion_type_code currency_conversion_type,
         ohe.conversion_rate_date currency_conversion_date,
         ohe.conversion_rate currency_conversion_rate,
         /*art.currency_code  currency_code, -- fix for 6996175
         art.currency_conversion_type currency_conversion_type,
         art.currency_conversion_rate currency_conversion_rate,
         art.currency_conversion_date currency_conversion_date,*/
         NVL (oli.payment_term_id, ohe.payment_term_id)  irt_id,
         NVL (oli.sold_from_org_id, ohe.sold_from_org_id) org_id,
         NVL(oli.ship_from_org_id, ohe.ship_from_org_id) ship_from_org_id,  -- rmunjulu Bug 3985369 Get Ship_From_Org_Id which will be passed to inventory_org_id when creating a invoice transaction.
         NULL   set_of_books_id, -- derived from org_id
         NULL   irm_id, -- defaulted in AR
         art.legal_entity_id
  FROM   oe_order_lines_all oli,
         oe_order_headers_all ohe,
         okl_asset_returns_b art,
         okc_k_lines_v  kle,
         okx_cust_site_uses_v csu
  WHERE oli.line_id  = cp_order_line_id
  AND   ohe.header_id  = oli.header_id
  AND   art.imr_id  = oli.inventory_item_id
  AND   kle.id   = art.kle_id
  AND   csu.id1   = nvl (oli.invoice_to_org_id, ohe.invoice_to_org_id);

 -- Returns previously billed records
  CURSOR l_til_csr (cp_order_line_id IN NUMBER) IS
   SELECT til.id
   FROM   okl_txl_ar_inv_lns_v til
   WHERE  til.isl_id = cp_order_line_id;

  -- SECHAWLA 01-NOV-04 3967398 : get the remarketing inventory item id
  CURSOR  l_orderlines_csr(cp_order_line_id IN NUMBER) IS
   SELECT  inventory_item_id
   FROM    oe_order_lines_all
   WHERE   line_id = cp_order_line_id;

 -- SECHAWLA 01-NOV-04 3967398 : check the item invoiced option from the setup
    -- PAGARG 26-Jan-2005 Bug 4044659 Querying LEASE_INV_ORG_YN also.
   CURSOR l_systemparamsall_csr IS
    SELECT REMK_ITEM_INVOICED_CODE
          ,NVL(LEASE_INV_ORG_YN, 'N') LEASE_INV_ORG_YN
    FROM   OKL_SYSTEM_PARAMS ;

    l_remk_item_invoiced  VARCHAR2(15);
    l_inventory_item_id   NUMBER;
    -- PAGARG 26-Jan-2005 Bug 4044659 variable to store the value of LEASE_INV_ORG_YN
    l_lease_inv_org_yn          OKL_SYSTEM_PARAMS_ALL.lease_inv_org_yn%TYPE;


    l_art_rec  l_art_csr%ROWTYPE;
    l_til_rec  l_til_csr%ROWTYPE;
    l_taiv_rec  taiv_rec_type;
    l_tilv_rec  tilv_rec_type;

    l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lx_remrkt_sty_id        NUMBER; --User Defined Streams
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'validate_populate_remarket';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
 END IF;
 IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_order_line_id: '||p_order_line_id);
 END IF;

 -- ***************************************************
 -- Check that no records have been previously invoiced
 -- ***************************************************

 OPEN l_til_csr (p_order_line_id);
 FETCH l_til_csr INTO l_til_rec;

 IF l_til_csr%FOUND THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  -- Message Text: Unable to process request for
  -- a Invoice creation. Invoice(s) already exist
  OKL_API.SET_MESSAGE (
   p_app_name => G_APP_NAME,
   p_msg_name => 'OKL_AM_INVOICES_EXIST');
 END IF;

 CLOSE l_til_csr;

 -- ******************************************
 -- Get Contract Line and Asset Return Records
 -- ******************************************

 OPEN l_art_csr (p_order_line_id);
 FETCH l_art_csr INTO l_art_rec;

 IF l_art_csr%NOTFOUND THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Order_Line_Id');

 ELSE

                -- RRAVIKIR Legal Entity Changes
                IF (l_art_rec.legal_entity_id is null or l_art_rec.legal_entity_id = OKC_API.G_MISS_NUM) THEN
                    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                        p_msg_name     => g_required_value,
                                        p_token1       => g_col_name_token,
                                        p_token1_value => 'legal_entity_id');
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;
                -- Legal Entity Changes End

  l_taiv_rec.khr_id := l_art_rec.chr_id;
  l_taiv_rec.description := l_art_rec.asset_number || ' - ' ||l_art_rec.asset_description;
  l_taiv_rec.date_invoiced := l_art_rec.ordered_date;
  l_taiv_rec.currency_code := l_art_rec.currency_code;
  l_taiv_rec.set_of_books_id := l_art_rec.set_of_books_id;
  l_taiv_rec.ibt_id := l_art_rec.ibt_id; -- bill_to
  l_taiv_rec.ixx_id := l_art_rec.ixx_id; -- customer
  l_taiv_rec.irm_id := l_art_rec.irm_id; -- payment method
  l_taiv_rec.irt_id := l_art_rec.irt_id; -- payment term
  l_taiv_rec.org_id := l_art_rec.org_id;

                -- RMUNJULU 30-DEC-02 2726739 -- Added for multi-currency
                l_taiv_rec.currency_conversion_type := l_art_rec.currency_conversion_type;
  l_taiv_rec.currency_conversion_rate := l_art_rec.currency_conversion_rate;
  l_taiv_rec.currency_conversion_date := l_art_rec.currency_conversion_date;

                -- RRAVIKIR Legal Entity Changes
                l_taiv_rec.legal_entity_id := l_art_rec.legal_entity_id;
                -- Legal Entity Changes End
-- Begin - varangan- Bug#5874824 - Asset Remarketing Fix

  l_taiv_rec.OKL_SOURCE_BILLING_TRX :='REMARKETING';

-- End - varangan- Bug#5874824 - Asset Remarketing Fix

  l_tilv_rec.line_number := 1;
  l_tilv_rec.kle_id := l_art_rec.cle_id;
  l_tilv_rec.isl_id := p_order_line_id;
  l_tilv_rec.description := l_art_rec.asset_number || ' - ' ||
        l_art_rec.asset_description;
  l_tilv_rec.amount := l_art_rec.price * l_art_rec.quantity;

  -- SECHAWLA 01-NOV-04 3967398 : Added the following piece of code
        -- PAGARG 26-Jan-2005 Bug 4044659 obtain the value of LEASE_INV_ORG_YN
  OPEN   l_systemparamsall_csr;
                FETCH  l_systemparamsall_csr INTO l_remk_item_invoiced, l_lease_inv_org_yn;
                CLOSE  l_systemparamsall_csr;

  IF l_remk_item_invoiced = 'REMARKET_ITEM' THEN
   OPEN   l_orderlines_csr(p_order_line_id);
   FETCH  l_orderlines_csr INTO l_inventory_item_id;
   CLOSE  l_orderlines_csr;

            l_tilv_rec.inventory_item_id := l_inventory_item_id;
        END IF;
        --PAGARG Bug 4044659 If LEASE_INV_ORG_YN is Y then set the value of
        --INVENTORY_ORG_ID in invoice line with org_id of order lines or header
        IF l_lease_inv_org_yn = 'Y'
        THEN
            l_tilv_rec.inventory_org_id := l_art_rec.ship_from_org_id; -- rmunjulu Bug 3985369 Changed to pass ship_from_org_id
        END IF;
        -- SECHAWLA 01-NOV-04 3967398 : Added the following piece of code : end

 END IF;

 CLOSE l_art_csr;

 -- ***************
 -- Get stream type
 -- ***************

        -- ++++ User Defined Streams Change ++++-----
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_STREAMS_UTIL.get_primary_stream_type');
        END IF;
         OKL_STREAMS_UTIL.get_primary_stream_type(l_art_rec.chr_id,
                                                  G_REMARKET_QUOTE_LINE,
                                                  l_return_status,
                                                  lx_remrkt_sty_id);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_STREAMS_UTIL.get_primary_stream_type , return status: ' || l_return_status);
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'lx_remrkt_sty_id: ' || lx_remrkt_sty_id);
        END IF;

 l_tilv_rec.sty_id := lx_remrkt_sty_id;
        -- smoduga +++++++++ User Defined Streams -- end    ++++++++++++++++

 IF NVL (l_tilv_rec.sty_id, G_MISS_NUM) = G_MISS_NUM THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;

/* -- rmunjulu bug 4056364  No need to set this message
  -- Stream Purpose is not setup
  okl_am_util_pvt.set_message (
    p_app_name => G_APP_NAME
   ,p_msg_name => 'OKL_AM_NO_STREAM_TO_QUOTE'
   ,p_token1 => 'QLT_CODE'
   ,p_token1_value => G_REMARKET_QUOTE_LINE);
*/
 END IF;

 -- ***********
 -- Save amount
 -- ***********

 IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
 -- if order line is found

     IF l_tilv_rec.amount IS NULL
     OR l_tilv_rec.amount = G_MISS_NUM
     OR l_tilv_rec.amount = 0 THEN
       l_return_status := OKL_API.G_RET_STS_ERROR;
       -- Message Text: Invalid value for the column Amount
       OKC_API.SET_MESSAGE (
        p_app_name => G_OKC_APP_NAME,
        p_msg_name => G_INVALID_VALUE,
        p_token1 => G_COL_NAME_TOKEN,
        p_token1_value => 'Amount');
     ELSIF l_tilv_rec.amount > 0 THEN
        x_pos_amount  := l_tilv_rec.amount;
        x_neg_amount  := 0;
     ELSIF l_tilv_rec.amount < 0 THEN
        x_neg_amount  := l_tilv_rec.amount;
        x_pos_amount  := 0;
     END IF;

 END IF;

 x_taiv_rec := l_taiv_rec;
 x_tilv_rec := l_tilv_rec;
 x_return_status := l_return_status;
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
 END IF;

EXCEPTION

 WHEN OTHERS THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
  END IF;

  IF l_art_csr%ISOPEN THEN
   CLOSE l_art_csr;
  END IF;

  IF l_til_csr%ISOPEN THEN
   CLOSE l_til_csr;
  END IF;

  -- SECHAWLA 01-NOV-04 3967398
  IF l_systemparamsall_csr%ISOPEN THEN
      CLOSE l_systemparamsall_csr;
  END IF;

  IF l_orderlines_csr%ISOPEN THEN
      CLOSE l_orderlines_csr;
  END IF;


  -- store SQL error message on message stack for caller
  OKL_API.SET_MESSAGE (
    p_app_name => G_APP_NAME
   ,p_msg_name => G_UNEXPECTED_ERROR
   ,p_token1 => G_SQLCODE_TOKEN
   ,p_token1_value => sqlcode
   ,p_token2 => G_SQLERRM_TOKEN
   ,p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END Validate_Populate_Remarket;


-- Start of comments
--
-- Procedure Name : Create_Remarket_Invoice
-- Description  : Create Invoice for Remarket Sale
-- Business Rules :
-- Parameters  : order line id
-- Version  : 1.0
-- End of comments

PROCEDURE Create_Remarket_Invoice (
 p_api_version    IN  NUMBER,
 p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 p_order_line_id  IN  NUMBER,
 x_taiv_tbl       OUT NOCOPY taiv_tbl_type) IS

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

 l_api_name       CONSTANT VARCHAR2(30) :='Create_Remarket_Invoice';
 l_api_version    CONSTANT NUMBER := G_API_VERSION;
 l_msg_count      NUMBER ;-- rmunjulu bug 4341480  := OKL_API.G_MISS_NUM;
 l_msg_data       VARCHAR2(2000);
 l_cnt            NUMBER;

 l_pos_amount     NUMBER  := 0;
 l_neg_amount     NUMBER  := 0;

 l_taiv_rec       taiv_rec_type;
 lx_pos_taiv_rec  taiv_rec_type;
 lx_neg_taiv_rec  taiv_rec_type;
 l_tilv_rec       tilv_rec_type;
 lx_tilv_rec      tilv_rec_type;

--ANSETHUR 08-MAR-2007 R12B Billling Architecture Start Changes
 l_tilv_tbl       tilv_tbl_type;
 lx_tilv_tbl      tilv_tbl_type;
--ANSETHUR 08-MAR-2007 R12B Billling Architecture End Changes
 l_module_name VARCHAR2(500) := G_MODULE_NAME || 'create_remarket_invoice';
 is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
 is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
 is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
 END IF;
 IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_order_line_id: '||p_order_line_id);
 END IF;

 -- ***************************************************************
 -- Check API version, initialize message list and create savepoint
 -- ***************************************************************

 l_return_status := OKL_API.START_ACTIVITY (
                                      l_api_name,
                                      G_PKG_NAME,
                                      p_init_msg_list,
                                      l_api_version,
                                      p_api_version,
                                      '_PVT',
                                      x_return_status);

 IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
 END IF;

 -- *******************
 -- Validate parameters
 -- *******************

 IF p_order_line_id IS NULL
 OR p_order_line_id = G_MISS_NUM THEN

  OKC_API.SET_MESSAGE (
                       p_app_name     => G_OKC_APP_NAME,
                       p_msg_name     => 'OKC_NO_PARAMS',
                       p_token1       => 'PARAM',
                       p_token1_value => 'ORDER_LINE_ID',
                       p_token2       => 'PROCESS',
                       p_token2_value => l_api_name);

  RAISE OKL_API.G_EXCEPTION_ERROR;

 END IF;

 -- Validate order_line_id
 -- Populate all header fields
 -- Populate all line fields for a single line
 Validate_Populate_Remarket (p_order_line_id => p_order_line_id,
                             x_pos_amount    => l_pos_amount,
                             x_neg_amount    => l_neg_amount,
                             x_taiv_rec      => l_taiv_rec,
                             x_tilv_rec      => l_tilv_rec,
                             x_return_status => l_return_status);
 IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called Validate_Populate_Remarket , return status: ' || l_return_status);
 END IF;

 IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
 END IF;


-- ANSETHUR 08-MAR-2007 R12B Billling Architecture Start Changes
-- Replaced the call of  Create_AR_Invoice_Header and Create_AR_Invoice_Lines
-- with the Create_billing_invoices Procedure which is created as
-- a part of new billing architecture.
   l_tilv_tbl(0):= l_tilv_rec;
   Create_billing_invoices (  p_taiv_rec     =>l_taiv_rec,
                              p_pos_amount   =>l_pos_amount,
                              p_neg_amount   =>l_neg_amount,
                              p_tilv_tbl     =>l_tilv_tbl,
                              x_tilv_tbl     =>lx_tilv_tbl,
                              x_pos_taiv_rec =>lx_pos_taiv_rec ,
                              x_neg_taiv_rec =>lx_neg_taiv_rec,
                              x_return_status=>l_return_status);
 IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called Create_billing_invoices , return status: ' || l_return_status);
 END IF;
/*
 -- *********************
 -- Create Invoice Header
 -- *********************

 Create_AR_Invoice_Header (p_taiv_rec      => l_taiv_rec,
                           p_pos_amount    => l_pos_amount,
                           p_neg_amount    => l_neg_amount,
                           x_pos_taiv_rec  => lx_pos_taiv_rec,
                           x_neg_taiv_rec  => lx_neg_taiv_rec,
                           x_return_status => l_return_status);

 IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
 END IF;

 -- *********************************************
 -- Create Invoice Lines for each record in table
 -- *********************************************

 IF    l_tilv_rec.amount > 0 THEN
  l_tilv_rec.tai_id := lx_pos_taiv_rec.id;
 ELSIF l_tilv_rec.amount < 0 THEN
  l_tilv_rec.tai_id := lx_neg_taiv_rec.id;
 ELSE
  l_tilv_rec.tai_id := NULL;
 END IF;

 Create_AR_Invoice_Lines (
                          p_tilv_rec => l_tilv_rec,
                          x_tilv_rec => lx_tilv_rec,
                          x_return_status => l_return_status);
  */
--ANSETHUR 08-MAR-2007 R12B Billling Architecture End Changes
 IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
 END IF;

 -- **************
 -- Return results
 -- **************

 l_cnt := 0;

 IF l_pos_amount > 0 THEN
  l_cnt := l_cnt + 1;
  x_taiv_tbl (l_cnt) := lx_pos_taiv_rec;
 END IF;

 IF l_neg_amount < 0 THEN
  l_cnt := l_cnt + 1;
  x_taiv_tbl (l_cnt) := lx_neg_taiv_rec;
 END IF;

 x_return_status := l_overall_status;

 OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
 END IF;

EXCEPTION

 WHEN OKL_API.G_EXCEPTION_ERROR THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
  END IF;
  x_return_status := OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OKL_API.G_RET_STS_ERROR',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

 WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
  END IF;
  x_return_status :=OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OKL_API.G_RET_STS_UNEXP_ERROR',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

 WHEN OTHERS THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
  END IF;

  x_return_status :=OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OTHERS',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

END Create_Remarket_Invoice;


-- Start of comments
--
-- Procedure Name : Contract_Remaining_Sec_Dep
-- Description  : Calculate Security Deposit Disposition
-- Business Rules :
-- Parameters  : quote id
-- Version  : 1.0
-- End of comments

PROCEDURE Contract_Remaining_Sec_Dep (
 p_contract_id  IN NUMBER,
 p_contract_line_id IN NUMBER,
 x_sdd_tbl  OUT NOCOPY sdd_tbl_type,
 x_tld_tbl  OUT NOCOPY tld_tbl_type,
 x_total_amount  OUT NOCOPY NUMBER) IS

 -- Get default date format
 CURSOR l_date_format_csr IS
  SELECT SYS_CONTEXT ('USERENV','NLS_DATE_FORMAT')
  FROM dual;

 -- Get contract end date
 CURSOR l_contract_csr (cp_contract_id NUMBER) IS
  SELECT end_date
  FROM okc_k_headers_b
  WHERE id = cp_contract_id;

-- ansethur 03/02/2007 For R12B Billing Architecture project Start Changes
-- Modified the cursor to exclude the reference of okl_xtl_sell_invs_b table.

        -- SMODUGA 11-Oct-04 Bug 3925469
        -- Modified cursor by passing sty_id based on the purspose and
        -- removed reference to stream type view.
        -- Get original security deposit stream
  CURSOR l_sdd_stream_csr (cp_contract_id NUMBER,cp_sty_id  NUMBER) IS
  SELECT sel.amount  amount,
         tld.id      tld_id,
         NULL        lsm_id --ansethur 03/02/2007 Added For R12B Billing Architecture project
     --  xls.lsm_id  lsm_id --ansethur 03/02/2007 commented for  R12B Billing Architecture project
  FROM okc_k_lines_b  kle,
       okc_line_styles_b lse,
       okc_k_items  ite,
       okl_streams  stm,
       okl_strm_elements sel,
       okl_txd_ar_ln_dtls_b tld
   --  ,okl_xtl_sell_invs_b xls  --ansethur 03/02/2007 commented for  R12B Billing Architecture project
  WHERE kle.chr_id  = cp_contract_id
  AND lse.id   = kle.lse_id
  AND lse.lty_code  = 'FEE'
  AND ite.cle_id  = kle.id
  AND ite.jtot_object1_code = 'OKL_STRMTYP'
  AND cp_sty_id  = ite.object1_id1
  AND stm.kle_id  = kle.id
  AND stm.khr_id  = cp_contract_id
  AND stm.active_yn  = 'Y'
  AND stm.say_code  = 'CURR'
  AND cp_sty_id  = stm.sty_id
  AND sel.stm_id  = stm.id
  AND sel.date_billed  IS NOT NULL
  AND NVL (sel.amount, 0) <> 0
  AND tld.sel_id  = sel.id
  AND tld.tld_id_reverses IS NULL
--  AND xls.tld_id  = tld.id --ansethur 03/02/2007 commented for  R12B Billing Architecture project
  ORDER BY sel.date_billed;
-- ansethur 03/02/2007 For R12B Billing Architecture project End Changes

 -- Get credit memos against security deposit
 CURSOR l_credit_memo_csr (cp_inv_tld_id NUMBER) IS
  SELECT tld.id, tld.amount
  FROM okl_txd_ar_ln_dtls_b tld
  WHERE tld.tld_id_reverses = cp_inv_tld_id;

 l_rulv_rec  okl_rule_pub.rulv_rec_type;
 l_sdd_tbl  sdd_tbl_type;
 l_tld_tbl  tld_tbl_type;
 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

 -- Calculation results
 l_old_cm_amount  NUMBER;
 l_cnt   NUMBER  := 0;
 l_cnt2   NUMBER  := 0;
 l_total_amount  NUMBER  := 0;

 -- Values stored in Security Deposit Rule
 l_held_until_maturity VARCHAR2(1);
 l_held_until_date DATE;

 l_date_format  VARCHAR2(100);
 l_contract_end_date DATE;
 l_sysdate  DATE  := SYSDATE;
 l_calculate_sdd  BOOLEAN  := TRUE;
 l_non_null_line_id EXCEPTION;
 l_module_name VARCHAR2(500) := G_MODULE_NAME || 'contract_remaining_sec_dep';
 is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
 is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
 is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

        --smoduga added variables for userdefined streams 3925469
        lx_sty_id NUMBER;

BEGIN
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
 END IF;
 IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_id: '||p_contract_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_line_id: '||p_contract_line_id);
 END IF;

 IF p_contract_line_id IS NOT NULL THEN
  -- Security Deposit is calculated on Header Level
  RAISE l_non_null_line_id;
 END IF;

 -- *************************
 -- Get Security Deposit Rule
 -- *************************

 IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
 END IF;
 okl_am_util_pvt.get_rule_record (
  p_rgd_code => 'LASDEP',
  p_rdf_code => 'LASDEP',
  p_chr_id => p_contract_id,
  p_cle_id => NULL,
  x_rulv_rec => l_rulv_rec,
  x_return_status => l_return_status,
  p_message_yn => FALSE);
 IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record , return status: ' || l_return_status);
 END IF;

 IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN

  OPEN l_contract_csr (p_contract_id);
  FETCH l_contract_csr INTO l_contract_end_date;
  CLOSE l_contract_csr;

  l_held_until_maturity := l_rulv_rec.rule_information2;

  OPEN l_date_format_csr;
  FETCH l_date_format_csr INTO l_date_format;
  CLOSE l_date_format_csr;

/* -- rmunjulu bug 4341480
  -- Security Deposit is hold till pre-defined date
  l_held_until_date := to_date (
   l_rulv_rec.rule_information5, l_date_format);
*/

        l_held_until_date :=  FND_DATE.CANONICAL_TO_DATE(l_rulv_rec.rule_information5); -- rmunjulu bug 4341480

  IF l_held_until_date IS NULL
  OR l_held_until_date = G_MISS_DATE THEN
   -- Security Deposit is hold until maturity
   IF  l_held_until_maturity = 'Y' THEN
    l_held_until_date := l_contract_end_date;
   END IF;
  END IF;

  IF  l_held_until_date IS NOT NULL
  AND l_held_until_date <> G_MISS_DATE THEN
   -- Can not release Security Deposit
            -- BEGIN rmunjulu bug 4341480 --


   IF trunc(l_held_until_date) < trunc(l_sysdate) THEN
            -- END rmunjulu bug 4341480 --
   --IF l_held_until_date < l_sysdate THEN
    l_calculate_sdd := FALSE;
   END IF;

  END IF;

 END IF;

 -- ************************************************
 -- Get original security deposit minus credit memos
 -- ************************************************

 IF l_calculate_sdd THEN

            -- smoduga +++++++++ User Defined Streams -- start    ++++++++++++++++
               IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_STREAMS_UTIL.get_primary_stream_type');
               END IF;
               OKL_STREAMS_UTIL.get_primary_stream_type(p_contract_id,
                                                        'SECURITY_DEPOSIT',
                                                        l_return_status,
                                                        lx_sty_id);
               IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_STREAMS_UTIL.get_primary_stream_type , return status: ' || l_return_status);
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'lx_sty_id : ' || lx_sty_id);
               END IF;
            -- smoduga +++++++++ User Defined Streams -- end    ++++++++++++++++

                FOR     l_sdd_stream_rec IN l_sdd_stream_csr (p_contract_id,lx_sty_id)
  LOOP

   l_old_cm_amount   := 0;
   l_cnt   := l_cnt + 1;

   FOR l_cm_rec IN l_credit_memo_csr (l_sdd_stream_rec.tld_id) LOOP
    l_cnt2  := l_cnt2 + 1;
    l_old_cm_amount := l_old_cm_amount +
         NVL (l_cm_rec.amount, 0);
    l_tld_tbl(l_cnt2).inv_tld_id := l_sdd_stream_rec.tld_id;
    l_tld_tbl(l_cnt2).cm_tld_id := l_cm_rec.id;
   END LOOP;

   l_sdd_tbl(l_cnt).lsm_id := l_sdd_stream_rec.lsm_id;
   l_sdd_tbl(l_cnt).tld_id := l_sdd_stream_rec.tld_id;
   -- Add total Sec Dep to negative CMs
   l_sdd_tbl(l_cnt).amount := NVL (l_sdd_stream_rec.amount, 0) +
         NVL (l_old_cm_amount, 0);
   l_total_amount  := l_total_amount +
         l_sdd_tbl(l_cnt).amount;

  END LOOP;

 END IF;

 x_sdd_tbl := l_sdd_tbl;
 x_tld_tbl := l_tld_tbl;
 x_total_amount := l_total_amount;
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
 END IF;

EXCEPTION

 WHEN OTHERS THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
  END IF;

  -- Close open cursors

  IF l_date_format_csr%ISOPEN THEN
   CLOSE l_date_format_csr;
  END IF;

  IF l_contract_csr%ISOPEN THEN
   CLOSE l_contract_csr;
  END IF;

  IF l_sdd_stream_csr%ISOPEN THEN
   CLOSE l_sdd_stream_csr;
  END IF;

  IF l_credit_memo_csr%ISOPEN THEN
   CLOSE l_credit_memo_csr;
  END IF;

  -- store SQL error message on message stack for caller

  OKL_API.SET_MESSAGE (
   p_app_name => OKL_API.G_APP_NAME,
   p_msg_name => 'OKL_CONTRACTS_UNEXPECTED_ERROR',
   p_token1 => 'SQLCODE',
   p_token1_value => SQLCODE,
   p_token2 => 'SQLERRM',
   p_token2_value => SQLERRM);

END contract_remaining_sec_dep;


-- Start of comments
--
-- Procedure Name : Create_Scrt_Dpst_Dsps_Inv
-- Description  : Create Credit Memo for Security Deposit Disposition
-- Business Rules :
-- Parameters  : quote id
-- Version      : 1.0
-- History          : RMUNJULU 11-FEB-03 2793710 changed code to raise excpt when
--                    sec dep disp amt not found or less than disp amt
-- End of comments

PROCEDURE Create_Scrt_Dpst_Dsps_Inv (
 p_api_version  IN  NUMBER,
 p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
 x_msg_count  OUT NOCOPY NUMBER,
 x_msg_data  OUT NOCOPY VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 p_contract_id  IN  NUMBER,
 p_contract_line_id IN  NUMBER DEFAULT NULL,
 p_dispose_amount IN  NUMBER DEFAULT NULL,
 p_quote_id IN  NUMBER DEFAULT NULL, --akrangan added for bug 7036873
 x_taiv_tbl  OUT NOCOPY taiv_tbl_type) IS

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

 l_api_name  CONSTANT VARCHAR2(30) :=
     'Create_Scrt_Dpst_Dsps_Inv';
 l_api_version  CONSTANT NUMBER := G_API_VERSION;
 l_msg_count  NUMBER ;-- rmunjulu bug 4341480  := OKL_API.G_MISS_NUM;
 l_msg_data  VARCHAR2(2000);

 l_taiv_rec  taiv_rec_type;
 l_taiv_tbl  taiv_tbl_type;
 l_cnt   NUMBER := 0;
 l_dispose_amount NUMBER;
 l_sdd_tbl  sdd_tbl_type;
 l_tld_tbl  tld_tbl_type;
 l_total_amount  NUMBER;
 l_tai_id  NUMBER;
 l_description  VARCHAR2(80);
 l_module_name VARCHAR2(500) := G_MODULE_NAME || 'create_scrt_dpst_dsps_inv';
 is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
 is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
 is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

    -- RMUNJULU 11-FEB-03 2793710 Added exception variable
    l_exception_halt_validation EXCEPTION;
--added by akrangan for bug
l_transaction_source VARCHAR2(80);
CURSOR c_set_trn_src
IS
SELECT 'TERMINATION_QUOTE' transaction_source
FROM OKL_TRX_QUOTES_B qte
WHERE qte.id = p_quote_id; --akrangan modified for bug 7036873

BEGIN
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
 END IF;
 IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_id: '||p_contract_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_line_id: '||p_contract_line_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_dispose_amount: '||p_dispose_amount);
 END IF;

 -- ***************************************************************
 -- Check API version, initialize message list and create savepoint
 -- ***************************************************************

 l_return_status := OKL_API.START_ACTIVITY (
  l_api_name,
  G_PKG_NAME,
  p_init_msg_list,
  l_api_version,
  p_api_version,
  '_PVT',
  x_return_status);

 IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
 END IF;

 -- *******************
 -- Validate parameters
 -- *******************

 IF p_contract_id IS NULL
 OR p_contract_id = G_MISS_NUM THEN

  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => 'OKC_NO_PARAMS',
   p_token1 => 'PARAM',
   p_token1_value => 'CONTRACT_ID',
   p_token2 => 'PROCESS',
   p_token2_value => l_api_name);

  RAISE OKL_API.G_EXCEPTION_ERROR;

 END IF;

 -- ***************************
 -- Calculate amount to dispose
 -- ***************************

 contract_remaining_sec_dep (
   p_contract_id => p_contract_id,
   p_contract_line_id => p_contract_line_id,
   x_sdd_tbl => l_sdd_tbl,
   x_tld_tbl => l_tld_tbl,
   x_total_amount => l_total_amount);
 IF (is_debug_statement_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called contract_remaining_sec_dep , l_total_amount : ' || l_total_amount);
 END IF;

    -- RMUNJULU 11-FEB-03 2793710 Raised halt validation if remaining sec dep = 0
    IF l_total_amount IS NULL
   OR l_total_amount = 0
   OR l_total_amount = G_MISS_NUM THEN


        -- There is no security deposit disposition amount remaining for the contract.
    OKL_API.set_message (
       p_app_name     => 'OKL',
        p_msg_name     => 'OKL_AM_INVALID_DEP_AMT');

        -- Raise halt validation so as not to set return status to E
        RAISE l_exception_halt_validation;

    END IF;

    -- RMUNJULU 11-FEB-03 2793710 Raised halt validation if remaining sec dep < line amt
    IF ABS (p_dispose_amount) > ABS (l_total_amount) THEN


        -- The remaining security deposit disposition amount for the contract is less than
        -- the disposition amount specified.
    OKL_API.set_message (
       p_app_name     => 'OKL',
        p_msg_name     => 'OKL_AM_INVALID_INV_AMT');

        -- Raise halt validation so as not to set return status to E
        RAISE l_exception_halt_validation;

    END IF;

 IF p_dispose_amount IS NULL
 OR p_dispose_amount = G_MISS_NUM
 OR p_dispose_amount = 0 THEN
  l_total_amount := abs (l_total_amount);
 ELSE
  l_total_amount := abs (p_dispose_amount);
 END IF;

 -- ******************
 -- Create Credit Memo
 -- ******************

 l_description := okl_am_util_pvt.get_lookup_meaning
  ('OKL_QUOTE_LINE_TYPE','AMCSDD');

 FOR i IN l_sdd_tbl.FIRST..l_sdd_tbl.LAST LOOP

  IF abs (l_sdd_tbl(i).amount) > l_total_amount THEN
   l_dispose_amount := - l_total_amount;
  ELSE
   l_dispose_amount := - abs (l_sdd_tbl(i).amount);
  END IF;

  -- Add negative dispose amount
  l_total_amount := l_total_amount + l_dispose_amount;

  IF NVL (l_dispose_amount, 0) < 0 THEN
   --akrangan added for bug begin
   OPEN c_set_trn_src;
   FETCH c_set_trn_src INTO l_transaction_source;
   CLOSE c_set_trn_src;
   --akrangan added for bug end
   -- rmunjuluu bug 4341480 okl_credit_memo_pub.insert_request (
   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_credit_memo_pub.insert_on_acc_cm_request');
   END IF;
   okl_credit_memo_pub.insert_on_acc_cm_request (
                                        p_api_version   => l_api_version,
                                        p_init_msg_list => OKL_API.G_FALSE,
                                        x_return_status => l_return_status,
                                        x_msg_count     => l_msg_count,
                                        x_msg_data      => l_msg_data,
                                        p_tld_id        => l_sdd_tbl(i).tld_id, -- ansethur 03/02/2007 Added For Billing Architecture Project
 --                                     p_tld_id        => l_sdd_tbl(i).tld_id, -- ansethur 03/02/2007 Commmented For Billing Architecture Project
                                        p_credit_amount => l_dispose_amount,
                                        p_credit_desc   => l_description,
                                        x_tai_id        => l_tai_id,
                                        x_taiv_rec      => l_taiv_rec
				        ,p_transaction_source => l_transaction_source);
   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_credit_memo_pub.insert_on_acc_cm_request , return status: ' || l_return_status);
   END IF;

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
   IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
       l_overall_status := l_return_status;
   END IF;
      ELSE
   l_cnt := l_cnt + 1;
   l_taiv_tbl(l_cnt) := l_taiv_rec;
      END IF;

  END IF;

 END LOOP;

 -- **************
 -- Return results
 -- **************

 x_taiv_tbl := l_taiv_tbl;
 x_return_status := l_overall_status;

 OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
 END IF;

EXCEPTION

    -- RMUNJULU 11-FEB-03 2793710 Raised halt validation so as not to set to E or U
    WHEN l_exception_halt_validation THEN
       IF (is_debug_exception_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'l_exception_halt_validation');
       END IF;

        NULL;

 WHEN OKL_API.G_EXCEPTION_ERROR THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
  END IF;
  x_return_status := OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OKL_API.G_RET_STS_ERROR',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

 WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
  END IF;
  x_return_status :=OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OKL_API.G_RET_STS_UNEXP_ERROR',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

 WHEN OTHERS THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
  END IF;

  x_return_status :=OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OTHERS',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

END Create_Scrt_Dpst_Dsps_Inv;


-- Start of comments
--
-- Procedure Name : Validate_Populate_Quote
-- Description   : Ensure quote exists
--                  Populates all header fields
--                  Populates all line fields
-- Business Rules :
-- Parameters   : asset return fields
-- Version    : 1.0
-- History        : RMUNJULU 30-DEC-02 2726739 Changed cursor and taiv_rec
--                  to set currency columns
--                : RMUNJULU 30-DEC-02 2726739 Added code to set currency columns
--                  when updating credit memos for security deposit dispositions
--                : RMUNJULU 11-FEB-03 2793710 Added code to check if tbl has recs
--                : rmunjulu EDAT Added code to not do processing of billing adjustment
--                  quote lines if partial terminations and
--                  When full term and billing adjustment then use original stream type id
--                : rmunjulu EDAT Ignore above comments
--                  Do billing adjustment processing for full termination and then
--                  CALL BPD API to do disbursements
--                : rmunjulu EDAT 09-Nov-04 Modified to get proper total neg amount
--                : rmunjulu EDAT 07-DEC-04 Set pos and neg amts properly
--                : rmunjulu 4056364 09-DEC-04 Modified to not set Quote Line Allocation message
--                : PAGARG 4044659 25-Jan-2005 Obtain inventory org id from
--                  contract and assign it to tilv_rec if LEASE_INV_ORG_YN
--                  is Y in OKL_SYSTEM_PARAMS_ALL
--                : rmunjulu 27-Jan-05 3985369 Modified to set inv_org_id
--                  when creating transaction for billing adjustment line
--                : rmunjulu 3985369 Modified get_qte_dtls_csr cursor
--                : rmunjulu sales tax enhancement, set quote line id in tilv_rec/tilv_tbl
--                  NOTE ::: Cannot set quote_line_id for billing adjustment quote lines
--                           as they are recalculated during invoicing
--                : rmunjulu 4547765 Added code to handle Future dated billing adjustments
--                : RMUNJULU LOANS_ENHANCEMENTS Bill PERDIEM_AMOUNT
--                : SECHAWLA 30-DEC-05 4917391 Create Invoice for quote per-diem if the amount is positive
--                                             Create Credit Memo for quote per-diem if the amount is negative
--                : SECHAWLA 05-JAN-06 4926740 For prior dated termination quotes, no. of days for per-diem
--                           calculation should be (acceptance date - creation date) and not
--                           (acceptance date - quote effective date)
-- End of comments

PROCEDURE Validate_Populate_Quote (
 p_quote_id  IN  NUMBER,
 x_pos_amount  OUT NOCOPY NUMBER,
 x_neg_amount  OUT NOCOPY NUMBER,
 x_taiv_tbl  OUT NOCOPY taiv_tbl_type,
 x_tilv_tbl  OUT NOCOPY tilv_tbl_type,
 x_sdd_taiv_tbl  OUT NOCOPY taiv_tbl_type,
 x_return_status  OUT NOCOPY VARCHAR2) IS

 -- Returns Quote Header
  -- RMUNJULU 30-DEC-02 2726739 -- Added columns for multi-currency get values
  -- from trx_quotes
 CURSOR l_qte_csr (cp_quote_id IN NUMBER) IS
  SELECT qte.khr_id  khr_id,
   qte.qtp_code  qtp_code,
   flo.meaning  description,
   qte.date_accepted date_invoiced,
   qte.currency_code  currency_code,
                        qte.currency_conversion_type currency_conversion_type,
                        qte.currency_conversion_rate currency_conversion_rate,
                        qte.currency_conversion_date currency_conversion_date
                        --PAGARG Bug 4044659 Query inventory org id
                        ,khr.inv_organization_id inv_organization_id,
                        qte.art_id    -- RRAVIKIR Legal Entity Changes
  FROM okl_trx_quotes_b qte,
   fnd_lookups  flo,
   okc_k_headers_b  khr
  WHERE qte.id   = cp_quote_id
  AND flo.lookup_type  = 'OKL_QUOTE_TYPE'
  AND flo.lookup_code  = qte.qtp_code
  AND khr.id   = qte.khr_id;

 -- Returns Quote Recipients
 CURSOR l_qpt_csr (cp_quote_id IN NUMBER) IS
  SELECT kpr.rle_code   rle_code,
   qpt.cpl_id   cpl_id,
   qpt.qpt_code   qpt_code,
   qpt.party_jtot_object1_code party_code,
   qpt.party_object1_id1  party_id1,
   qpt.party_object1_id2  party_id2,
   qpt.allocation_percentage allc_perc
  FROM okl_quote_parties  qpt,
   okc_k_party_roles_b  kpr
  WHERE qpt.qte_id   = cp_quote_id
  AND qpt.qpt_code     IN ('RECIPIENT','RECIPIENT_ADDITIONAL')
  AND kpr.id   (+) = qpt.cpl_id
        AND qpt.allocation_percentage <> 0;  -- rmunjulu bug 4341480


 -- Returns Quote Lines
 CURSOR l_qlt_csr (cp_quote_id IN NUMBER) IS
  SELECT qlt.kle_id  kle_id,
   qlt.amount  amount,
   qlt.line_number  line_number,
   qlt.sty_id  sty_id,
   qlt.qlt_code  qlt_code,
   flo.meaning  description,
   qlt.id quote_line_id -- rmunjulu sales_tax_enhancement
  FROM okl_txl_quote_lines_b qlt,
   fnd_lookups  flo
  WHERE qlt.qte_id  = cp_quote_id
  AND qlt.amount  NOT IN (G_MISS_NUM, 0)
  AND flo.lookup_type  = 'OKL_QUOTE_LINE_TYPE'
  AND flo.lookup_code  = qlt.qlt_code
  AND qlt.qlt_code  NOT IN (
      'BILL_ADJST',   -- rmunjulu EDAT Added since billing adjustments will be handled separately
   'AMCFIA',  -- Used to save quote assets, not amounts
   'AMCTAX',  -- Estimated tax, AR will recalculate tax
   'AMYOUB');  -- Outstanding balances are already billed

 -- Returns previously billed records
 CURSOR l_tai_csr (cp_quote_id IN NUMBER) IS
  SELECT tai.id
  FROM okl_trx_ar_invoices_v tai
  WHERE tai.qte_id = cp_quote_id;

    -- rmunjulu EDAT -- get if quote partial
    -- rmunjulu 3985369 -- Modified to get contract inv org
    CURSOR get_qte_dtls_csr (p_quote_id IN NUMBER) IS
    SELECT upper(nvl(qte.partial_yn,'N')) partial_yn,
           qte.khr_id khr_id,
           qte.date_effective_from date_eff_from,
           QTE.DATE_ACCEPTED DATE_ACCEPTED, -- RMUNJULU 4547765 FUTURE_BILLS_BUG
           qte.creation_date creation_date, --SECHAWLA 05-JAN-05 4926740 : added creation_date
           chr.inv_organization_id inv_organization_id,
           QTE.perdiem_amount -- rmunjulu LOANS_ENHACEMENTS
    FROM   OKL_TRX_QUOTES_B qte,
           OKC_K_HEADERS_B chr
    WHERE  qte.id = p_quote_id
 AND    qte.khr_id = chr.id;-- rmunjulu 3985369

    -- rmunjulu EDAT -- Get the quote line meaning for BILL_ADJST
    CURSOR get_qte_ln_meaning_csr IS
    SELECT fnd.meaning meaning
    FROM   FND_LOOKUPS fnd
    WHERE  fnd.lookup_type = 'OKL_QUOTE_LINE_TYPE'
    AND    fnd.lookup_code = 'BILL_ADJST';

 l_api_version  CONSTANT NUMBER := G_API_VERSION;
 l_msg_count  NUMBER ;-- rmunjulu bug 4341480  := OKL_API.G_MISS_NUM;
 l_msg_data  VARCHAR2(2000);
 l_cnt   NUMBER;
 l_seq   NUMBER;

 l_qte_rec  l_qte_csr%ROWTYPE;
 l_qlt_rec  l_qlt_csr%ROWTYPE;
 l_tai_rec  l_tai_csr%ROWTYPE;
 l_taiv_rec  taiv_rec_type;
 l_r_taiv_tbl  taiv_tbl_type;
 l_tilv_rec  tilv_rec_type;
 l_tilv_tbl  tilv_tbl_type;

 -- SDD related variables
 l_taiv_tbl  taiv_tbl_type;
 lu_taiv_rec  taiv_rec_type;
 lx_taiv_rec  taiv_rec_type;

 l_pos_amount  NUMBER  := 0;
 l_neg_amount  NUMBER  := 0;

 l_allc_total  NUMBER  := 0; -- Total allocated
 l_no_allc  NUMBER  := 0; -- Recipients without allocation

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_amount_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_stream_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_alloc_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_sdd_invoice   BOOLEAN := FALSE; --added by veramach for bug#6766479
    -- rmunjulu EDAT
    l_partial_yn VARCHAR2(3);
    l_khr_id NUMBER;
    l_date_eff_from DATE;
    l_line_number NUMBER;
    l_input_tbl OKL_BPD_TERMINATION_ADJ_PVT.input_tbl_type;
    lx_baj_tbl  OKL_BPD_TERMINATION_ADJ_PVT.baj_tbl_type;
    l_meaning VARCHAR2(300);

    -- smoduga UDS
    lx_sty_id NUMBER;
    -- rmunjulu Bug 4056364
    l_dummy_status VARCHAR2(3);

    --PAGARG Bug 4044659 Cursor to obtain operational options values
    CURSOR l_sys_prms_csr IS
      SELECT NVL(LEASE_INV_ORG_YN, 'N') LEASE_INV_ORG_YN
      FROM OKL_SYSTEM_PARAMS;
    l_sys_prms_rec l_sys_prms_csr%ROWTYPE;

    -- rmunjulu 3985369
    l_inv_org_id NUMBER;

    l_quote_accpt_date DATE; -- RMUNJULU 4547765 FUTURE_BILLS_BUG
       -- akrangan - BUg#5521354 - Added - Start
 	     l_future_invoices_exists VARCHAR2(3);
       -- akrangan - BUg#5521354 - Added - End

    l_creation_date  DATE;  --SECHAWLA 05-JAN-05 4926740

    -- rmunjulu LOANS_ENHACEMENTS
    l_perdiem_amt NUMBER;
    l_perdiem_sty_id NUMBER;
    l_noofdays NUMBER;
    l_refund_sty_id NUMBER;
    l_loan_refund_amount NUMBER;

    l_regular_qte_line VARCHAR2(3); -- rmunjulu bug 4341480


    -- RRAVIKIR Legal Entity Changes
     CURSOR l_assetreturn_csr (cp_id IN NUMBER) IS
        SELECT legal_entity_id
        FROM okl_asset_returns_all_b
        WHERE id = cp_id;

        l_legal_entity_id   NUMBER;

    -- Legal Entity Changes End
 l_module_name VARCHAR2(500) := G_MODULE_NAME || 'validate_populate_quote';
 is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
 is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
 is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

--bug#6766479 veramach start
 CURSOR check_cont_typ (cp_khr_id IN NUMBER) IS
  SELECT ORIG_SYSTEM_SOURCE_CODE
  FROM   OKC_K_HEADERS_B
  WHERE  id = cp_khr_id;

  l_cont_typ VARCHAR2(30);

--bug#6766479 veramach end.

BEGIN
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
 END IF;
 IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_quote_id: '|| p_quote_id);
 END IF;

 -- ***************************************************
 -- Check that no records have been previously invoiced
 -- ***************************************************

 OPEN l_tai_csr (p_quote_id);
 FETCH l_tai_csr INTO l_tai_rec;

 IF l_tai_csr%FOUND THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  -- Message Text: Unable to process request for
  -- a Invoice creation. Invoice(s) already exist
  OKL_API.SET_MESSAGE (
   p_app_name => G_APP_NAME,
   p_msg_name => 'OKL_AM_INVOICES_EXIST');
 END IF;

 CLOSE l_tai_csr;

 -- ***********************
 -- Get Quote Header Record
 -- ***********************

 OPEN l_qte_csr (p_quote_id);
 FETCH l_qte_csr INTO l_qte_rec;

 IF l_qte_csr%NOTFOUND THEN
  l_return_status := OKL_API.G_RET_STS_ERROR;
  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Quote_Id');

 ELSE
  l_taiv_rec.khr_id  := l_qte_rec.khr_id;
  l_taiv_rec.description  := l_qte_rec.description;
  l_taiv_rec.currency_code := l_qte_rec.currency_code;
  l_taiv_rec.date_invoiced := l_qte_rec.date_invoiced;
  l_taiv_rec.qte_id  := p_quote_id;
 -- ansethur 05-jun-07 R12B Billing Architecture
  l_taiv_rec.OKL_SOURCE_BILLING_TRX :='TERMINATION_QUOTE';

  -- RMUNJULU 30-DEC-02 2726739 -- Added for multi-currency
  l_taiv_rec.currency_conversion_type := l_qte_rec.currency_conversion_type;
  l_taiv_rec.currency_conversion_rate := l_qte_rec.currency_conversion_rate;
  l_taiv_rec.currency_conversion_date := l_qte_rec.currency_conversion_date;

                -- RRAVIKIR Legal Entity Changes
                IF (l_qte_rec.qtp_code LIKE 'REP%') THEN
                  OPEN l_assetreturn_csr(cp_id  =>  l_qte_rec.art_id);
                  FETCH l_assetreturn_csr INTO l_legal_entity_id;
                  CLOSE l_assetreturn_csr;

                  IF (l_legal_entity_id is null or l_legal_entity_id = OKC_API.G_MISS_NUM) THEN
                      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                          p_msg_name     => g_required_value,
                                          p_token1       => g_col_name_token,
                                          p_token1_value => 'legal_entity_id');
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;

                  l_taiv_rec.legal_entity_id := l_legal_entity_id;
                END IF;
                -- Legal Entity Changes End


 END IF;

 CLOSE l_qte_csr;

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
  IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
   l_overall_status := l_return_status;
  END IF;
 END IF;

 -- ***************************
 -- Get Quote Recipient Records
 -- ***************************

 l_cnt := 0;

 FOR l_qpt_rec IN l_qpt_csr (p_quote_id) LOOP

  l_cnt := l_cnt + 1;
  l_r_taiv_tbl(l_cnt) := l_taiv_rec;

  IF  l_qpt_rec.allc_perc IS NOT NULL
  AND l_qpt_rec.allc_perc <> G_MISS_NUM
  AND l_qpt_rec.allc_perc BETWEEN 0 AND 100 THEN
   l_r_taiv_tbl(l_cnt).amount := l_qpt_rec.allc_perc;
   l_allc_total := l_allc_total + l_qpt_rec.allc_perc;
  ELSIF l_qpt_rec.allc_perc < 0
  OR    l_qpt_rec.allc_perc > 100 THEN
   l_alloc_status := OKL_API.G_RET_STS_ERROR;
  ELSE
   l_no_allc := l_no_allc + 1;
  END IF;

  -- Bill Vendor from Vendor Program for Repurchase Quote
  IF l_qte_rec.qtp_code = 'REP_STANDARD' THEN

      -- Get Customer and Bill_To linked to a Vendor
      Get_Vendor_Billing_Info (
   px_taiv_rec => l_r_taiv_tbl(l_cnt),
   x_return_status => l_return_status);

  -- Bill Vendor attached as a Party Role to Lease Contract
  ELSIF l_qpt_rec.rle_code = 'OKL_VENDOR' THEN

      -- Get Customer and Bill_To linked to a Vendor
      Get_Vendor_Billing_Info (
   p_cpl_id => l_qpt_rec.cpl_id,
   px_taiv_rec => l_r_taiv_tbl(l_cnt),
   x_return_status => l_return_status);

  -- Bill Lessee
  ELSIF l_qpt_rec.rle_code = 'LESSEE' THEN

      -- BPD derives billing info using KHR_ID
      l_return_status := OKL_API.G_RET_STS_SUCCESS;

  -- Unidentified Party
  ELSE

      l_return_status  := OKL_API.G_RET_STS_ERROR;
      -- Message Text: Invalid value for the column Allocation Percentage
      OKL_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Quote Recipient');

  END IF;

  IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
   IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
    l_overall_status := l_return_status;
   END IF;
  END IF;

 END LOOP;

 IF     l_r_taiv_tbl.COUNT = 0 THEN
  l_taiv_rec.amount := 100; -- Allocate everything to Lessee
  l_r_taiv_tbl(1)   := l_taiv_rec;
 ELSIF  l_allc_total > 100
 OR    (l_allc_total = 100 AND l_no_allc > 0)
 OR    (l_allc_total < 100 AND l_no_allc = 0) THEN
  l_alloc_status := OKL_API.G_RET_STS_ERROR;
 ELSIF (l_allc_total < 100 AND l_no_allc > 0) THEN
  -- Divide the rest equally
  FOR i IN l_r_taiv_tbl.FIRST..l_r_taiv_tbl.LAST LOOP
      IF l_r_taiv_tbl(i).amount IS NULL
      OR l_r_taiv_tbl(i).amount = G_MISS_NUM THEN
   l_r_taiv_tbl(i).amount := (100 - l_allc_total) / l_no_allc;
      END IF;
  END LOOP;
 END IF;

 IF l_alloc_status <> OKL_API.G_RET_STS_SUCCESS THEN
  l_return_status  := OKL_API.G_RET_STS_ERROR;
  -- Message Text: Invalid value for the column Allocation Percentage
  OKL_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Allocation Percentage');
 END IF;

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
  IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
   l_overall_status := l_return_status;
  END IF;
 END IF;

 -- **********************
 -- Get Quote Line Records
 -- **********************

 IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN
 -- if quote is found
        --PAGARG Bug 4044659 Open and fetch values from l_sys_prms_csr
        OPEN l_sys_prms_csr;
        FETCH l_sys_prms_csr INTO l_sys_prms_rec;
        -- IF no row fetched from cursor then set the value as N for LEASE_INV_ORG_YN
        IF l_sys_prms_csr%NOTFOUND
        THEN
            l_sys_prms_rec.LEASE_INV_ORG_YN := 'N';
        END IF;

        CLOSE l_sys_prms_csr;

     FOR l_qlt_rec IN l_qlt_csr (p_quote_id) LOOP

  IF l_qlt_rec.qlt_code = 'AMCSDD' THEN

      l_sdd_invoice :=TRUE;  --added by veramach for bug#6766479
      -- ****************************
      -- Security deposit disposition
      -- ****************************

            -- RMUNJULU 11-FEB-03 2793710 added code to set the dispose amount
      l_tilv_rec.amount  := l_qlt_rec.amount;

      l_tilv_rec.qte_line_id := l_qlt_rec.quote_line_id; -- rmunjulu sales_tax_enhancement

      Create_Scrt_Dpst_Dsps_Inv (
       p_api_version  => l_api_version,
       p_init_msg_list  => OKL_API.G_FALSE,
       x_return_status  => l_return_status,
       x_msg_count      => l_msg_count,
       x_msg_data      => l_msg_data,
       p_contract_id  => l_taiv_rec.khr_id,
       p_contract_line_id => NULL,
       p_dispose_amount => l_tilv_rec.amount,
       p_quote_id => l_taiv_rec.qte_id, --akrangan added for bug 7036873
       x_taiv_tbl      => l_taiv_tbl);
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called Create_Scrt_Dpst_Dsps_Inv , return status: ' || l_return_status);
       END IF;

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
   IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
       l_overall_status := l_return_status;
   END IF;
      END IF;

      -- Update quote_id and save results
      l_seq := NVL (x_sdd_taiv_tbl.LAST, 0);

            -- RMUNJULU 11-FEB-03 2793710 Added IF to check if tbl has recs
            IF l_taiv_tbl.COUNT > 0 THEN

      l_cnt := l_taiv_tbl.FIRST;

      LOOP
        lu_taiv_rec.id  := l_taiv_tbl(l_cnt).id;
        --akrangan bug 6275650 fix start
        lu_taiv_rec.OKL_SOURCE_BILLING_TRX := l_taiv_tbl(l_cnt).OKL_SOURCE_BILLING_TRX;
        --akrangan bug 6275650 fix end
   lu_taiv_rec.qte_id := p_quote_id;

            -- RMUNJULU 30-DEC-02 2726739 -- Added for multi-currency when doing SDD
            -- set the currency cols for the credit memos created
            lu_taiv_rec.currency_code := l_qte_rec.currency_code;
          lu_taiv_rec.currency_conversion_type := l_qte_rec.currency_conversion_type;
            lu_taiv_rec.currency_conversion_rate := l_qte_rec.currency_conversion_rate;
            lu_taiv_rec.currency_conversion_date := l_qte_rec.currency_conversion_date;


   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_trx_ar_invoices_pub.update_trx_ar_invoices');
   END IF;
   okl_trx_ar_invoices_pub.update_trx_ar_invoices (
    p_api_version => l_api_version,
    p_init_msg_list => OKL_API.G_FALSE,
    x_return_status => l_return_status,
    x_msg_count   => l_msg_count,
    x_msg_data     => l_msg_data,
    p_taiv_rec     => lu_taiv_rec,
    x_taiv_rec     => lx_taiv_rec);
   IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_trx_ar_invoices_pub.update_trx_ar_invoices , return status: ' || l_return_status);
   END IF;

   IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
       IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
    l_overall_status := l_return_status;
       END IF;
    END IF;

   l_seq   := l_seq + 1;
   x_sdd_taiv_tbl(l_seq) := lx_taiv_rec;

   EXIT WHEN (l_cnt = l_taiv_tbl.LAST);
   l_cnt := l_taiv_tbl.NEXT(l_cnt);

      END LOOP;

            END IF;

  ELSE

            l_regular_qte_line := 'Y';   -- rmunjulu bug 4341480

      -- ***********************
      -- All non-SDD quote lines
      -- ***********************

            -- rmunjulu EDAT Get if quote partial
            --OPEN get_partial_quote_yn_csr (p_quote_id);
            --FETCH get_partial_quote_yn_csr INTO l_partial_yn;
            --CLOSE get_partial_quote_yn_csr;

            -- rmunjulu EDAT Added -- Do not do processing of billing adjustment
            -- quote lines if partial termination as rebook will take care of it
            --IF  l_qlt_rec.qlt_code = 'BILL_ADJST' AND nvl(l_partial_yn,'N') = 'Y' THEN
               --null; -- no processing needed for billing adjustment quote lines if partial term
            --ELSE -- all other quote lines except AMCSDD and BILL_ADJST (only when partial)
      l_tilv_rec.line_number := l_qlt_rec.line_number;
      l_tilv_rec.kle_id  := l_qlt_rec.kle_id;
      l_tilv_rec.description := l_qlt_rec.description;
      l_tilv_rec.amount  := l_qlt_rec.amount;

      l_tilv_rec.qte_line_id  := l_qlt_rec.quote_line_id; -- rmunjulu sales_tax_enhancement

            --PAGARG Bug 4044659 If LEASE_INV_ORG_YN is Y then set the value of
            --INVENTORY_ORG_ID in invoice line with contract inv_organization_id
            IF l_sys_prms_rec.LEASE_INV_ORG_YN = 'Y'
            THEN
                l_tilv_rec.inventory_org_id := l_qte_rec.inv_organization_id;
            END IF;

      IF    l_tilv_rec.amount > 0 THEN
   l_pos_amount := l_pos_amount + l_tilv_rec.amount;
      ELSIF l_tilv_rec.amount < 0 THEN
   l_neg_amount := l_neg_amount + l_tilv_rec.amount;
      ELSE
   l_amount_status := OKL_API.G_RET_STS_ERROR;
      END IF;

            -- rmunjulu EDAT for Billing Adjustment the stream type will be same as original stream type
            --IF  l_qlt_rec.qlt_code = 'BILL_ADJST' THEN
                --l_tilv_rec.sty_id := l_qlt_rec.sty_id;
            --ELSE -- all other quote lines
             -- smoduga +++++++++ User Defined Streams -- start    ++++++++++++++++
               IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_STREAMS_UTIL.get_primary_stream_type');
               END IF;
               OKL_STREAMS_UTIL.get_primary_stream_type(l_qte_rec.khr_id,
                                                        l_qlt_rec.qlt_code,
                                                        l_dummy_status, -- rmunjulu Bug 4056364 No need for this return status
                                                        lx_sty_id);
               IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_STREAMS_UTIL.get_primary_stream_type , return status: ' || l_return_status);
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'lx_sty_id : ' || lx_sty_id);
               END IF;

         l_tilv_rec.sty_id := lx_sty_id ; -- User Defined Streams
             -- smoduga +++++++++ User Defined Streams -- end    ++++++++++++++++
            --END IF;

      IF NVL (l_tilv_rec.sty_id, G_MISS_NUM) = G_MISS_NUM THEN
   -- Check if stream type is already assigned
   l_tilv_rec.sty_id := l_qlt_rec.sty_id;
   IF NVL (l_tilv_rec.sty_id, G_MISS_NUM) = G_MISS_NUM THEN
       l_stream_status := OKL_API.G_RET_STS_ERROR;

       /* -- rmunjulu Bug 4056364  Do not set this message, message will be set by OKL_STREAMS_UTIL
       -- Stream Type is not setup in Quote Line Allocation Screen for QLT_CODE
       okl_am_util_pvt.set_message (
     p_app_name => G_APP_NAME
    ,p_msg_name => 'OKL_AM_NO_STREAM_TO_QUOTE'
    ,p_token1 => 'QLT_CODE'
    ,p_token1_value => l_qlt_rec.qlt_code);
    */
    END IF;
      END IF;

      l_tilv_tbl(l_qlt_rec.line_number) := l_tilv_rec;
            --END IF; -- rmunjulu EDAT
  END IF;

     END LOOP;

     -- rmunjulu EDAT -- start ---------------- ++++++++++++++++++++++++++++
     -- Do processing for BILL_ADJST quote lines, get the billing adjustments
  -- again and create -ve invoices and do passthru disbursements too.

        -- rmunjulu EDAT Get if quote dtls
        OPEN  get_qte_dtls_csr (p_quote_id);
        FETCH get_qte_dtls_csr INTO l_partial_yn, l_khr_id, l_date_eff_from, l_quote_accpt_date,
        l_creation_date,  --SECHAWLA 05-JAN-05 4926740 : added creation_date
     l_inv_org_id, l_perdiem_amt; -- rmunjulu 3985369 -- RMUNJULU 4547765 FUTURE_BILLS_BUG -- rmunjulu LOANS_ENHACEMENTS
        CLOSE get_qte_dtls_csr;

        -- rmunjulu INVESTOR_DISB_ADJST
	-- akrangan - Bug#5521354 - Added -Start
	-- Check to ensure that the quote is a partial termination quote.
	-- This check is useful if there is partial termination quote created on a contract
 	-- with one asset with one unit. This case is treated as full termination
        IF nvl(l_partial_yn,'N') = 'Y' THEN

           -- need to check if no more assets
           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.check_true_partial_quote');
           END IF;
           l_partial_yn := OKL_AM_LEASE_LOAN_TRMNT_PVT.check_true_partial_quote(
                                p_quote_id     => p_quote_id,
                                p_contract_id  => l_khr_id);
           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PVT.check_true_partial_quote , l_partial_yn: ' || l_partial_yn);
           END IF;

        END IF;
     /* moving the logic to create quote invoice api for bug 5460271 -- start
  -- Do billing adjustment processing only in case of full termination
  IF nvl(l_partial_yn,'N') = 'N' THEN

           -- get the billing adjustment amounts and bill if full termination
           l_input_tbl(1).khr_id := l_khr_id;
           l_input_tbl(1).term_date_from := l_date_eff_from;

        -- Call BPD API to get billing from quote_effective_from_date onwards
           OKL_BPD_TERMINATION_ADJ_PVT.get_billing_adjust(
        p_api_version     => l_api_version,
        p_init_msg_list   => OKL_API.G_FALSE,
        p_input_tbl       => l_input_tbl,
        x_baj_tbl         => lx_baj_tbl,
        x_return_status   => l_return_status,
        x_msg_count       => l_msg_count,
        x_msg_data        => l_msg_data);

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

           -- Error getting the billing adjustments for the contract.
              OKL_API.set_message(
                   p_app_name      => 'OKL',
                   p_msg_name      => 'OKL_AM_ERROR_BILL_ADJST');

            END IF;

         IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
             l_overall_status := l_return_status;
             END IF;
         END IF;

            -- for each value returned by BPD api create a invoice line
            IF lx_baj_tbl.COUNT > 0 THEN

               -- get the last line number
               IF l_tilv_tbl.COUNT > 0 THEN

                 --l_line_number := l_tilv_tbl.COUNT;
                 l_line_number := l_tilv_tbl(l_tilv_tbl.last).line_number; --rmunjulu 4610850 pick the proper line number

               ELSE

                 l_line_number := 0;

               END IF;

               FOR i IN lx_baj_tbl.FIRST..lx_baj_tbl.LAST LOOP

                  IF lx_baj_tbl(i).amount <> 0
                  AND trunc(lx_baj_tbl(i).stream_element_date) <= trunc(l_quote_accpt_date) THEN -- RMUNJULU 4547765 FUTURE_BILLS_BUG, PROCESS ONLY TILL CURRENT DATE

         l_line_number := l_line_number + 1;

               l_tilv_rec.line_number  := l_line_number;
               l_tilv_rec.kle_id   := lx_baj_tbl(i).kle_id;

               -- get meaning for BILL_ADJST
               OPEN  get_qte_ln_meaning_csr;
               FETCH get_qte_ln_meaning_csr INTO l_meaning;
               CLOSE get_qte_ln_meaning_csr;

               l_tilv_rec.description  := l_meaning;
               l_tilv_rec.amount   := lx_baj_tbl(i).amount * -1; -- rmunjulu EDAT 07-DEC -- negate the amounts

                     IF  l_tilv_rec.amount > 0 THEN
               l_pos_amount  := l_pos_amount + l_tilv_rec.amount; -- rmunjulu EDAT 07-DEC -- + lx_baj_tbl(i).amount;
               ELSIF l_tilv_rec.amount < 0 THEN
               l_neg_amount  := l_neg_amount + l_tilv_rec.amount; -- rmunjulu EDAT 07-DEC -- - lx_baj_tbl(i).amount; -- rmunjulu EDAT 09-Nov-04 Changed since the
                              --l_neg_amount was -ve and we have to add -ve value to it
               END IF;

                     -- for billing adjustments the original stream type will be used
                     -- Do not use quote line allocation streams
                     l_tilv_rec.sty_id := lx_baj_tbl(i).sty_id;

                     -- rmunjulu 3985369 If LEASE_INV_ORG_YN is Y then set the value of
                     -- INVENTORY_ORG_ID in invoice line with contract inv_organization_id
                     IF l_sys_prms_rec.LEASE_INV_ORG_YN = 'Y' THEN
                        l_tilv_rec.inventory_org_id := l_inv_org_id;
                     END IF;

               l_tilv_tbl(l_line_number) := l_tilv_rec;

                  END IF;
               END LOOP;

/*
               -- rmunjulu 4610850 Check if future billing adjustments exists
               IF  l_tilv_tbl.COUNT = 0 THEN
                  FOR i IN lx_baj_tbl.FIRST..lx_baj_tbl.LAST LOOP
                     -- check if future bills exist
                     IF lx_baj_tbl(i).amount <> 0
                     AND trunc(lx_baj_tbl(i).stream_element_date) > trunc(l_quote_accpt_date) THEN

                        l_future_invoices_exists := 'Y';
                        EXIT;

                     END IF;
                  END LOOP;
               END IF;
*/

               -- Do passthru disbursments if full termination and if billing adjustments needed.
               /*OKL_BPD_TERMINATION_ADJ_PVT.create_passthru_adj(
           p_api_version     => l_api_version,
           p_init_msg_list   => OKL_API.G_FALSE,
           p_baj_tbl         => lx_baj_tbl,
           x_return_status   => l_return_status,
           x_msg_count       => l_msg_count,
           x_msg_data        => l_msg_data);

               IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

               -- Error performing passthru disbursments.
                  OKL_API.set_message(
                       p_app_name      => 'OKL',
                       p_msg_name      => 'OKL_AM_ERROR_PASS_THRU_DISB');

               END IF;

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
               l_overall_status := l_return_status;
                END IF;
            END IF;

           END IF;

        END IF;
     -- rmunjulu EDAT -- end    ---------------- ++++++++++++++++++++++++++++
      /* moving the logic to create quote invoice api for bug 5503113 -- End  */
     -- RMUNJULU LOANS_ENHACEMENTS BILL PERDIEM_AMOUNT -- start
     IF l_perdiem_amt <> 0 THEN

           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_STREAMS_UTIL.get_primary_stream_type');
           END IF;
           OKL_STREAMS_UTIL.get_primary_stream_type(
                           p_khr_id              => l_qte_rec.khr_id,
                                    p_primary_sty_purpose => 'QUOTE_PER_DIEM',
                                    x_return_status       => l_return_status,
                                    x_primary_sty_id      => l_perdiem_sty_id);
           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_STREAMS_UTIL.get_primary_stream_type , return status: ' || l_return_status);
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_perdiem_sty_id: ' || l_perdiem_sty_id);
           END IF;

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
               IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := l_return_status;
               END IF;
           END IF;

     IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN

    --SECHAWLA 05-JAN-06 4926740 : added for prior-dated quotes : begin
    IF trunc(l_date_eff_from) < trunc(l_creation_date) THEN -- Prior-dated quotes
        IF trunc(l_quote_accpt_date) = trunc(l_creation_date) THEN
           l_noofdays := 1;
         ELSE
           l_noofdays :=  trunc(l_quote_accpt_date) - trunc(l_creation_date);
         END IF;
       ELSE  --SECHAWLA 05-JAN-06 4926740 : added for prior-dated quotes : end
           --current / future dated quotes
        IF trunc(l_quote_accpt_date) = trunc(l_date_eff_from) THEN
           l_noofdays := 1;
          ELSE
           l_noofdays :=  trunc(l_quote_accpt_date) - trunc(l_date_eff_from);
         END IF;
       END IF;

             -- get the last line number
             IF l_tilv_tbl.COUNT > 0 THEN
               l_line_number := l_tilv_tbl(l_tilv_tbl.last).line_number;
             ELSE
               l_line_number := 0;
             END IF;

       l_line_number := l_line_number + 1;

          l_tilv_rec.line_number  := l_line_number;
             l_tilv_rec.description  := 'Quote Perdiem Amount';

             -- SECHAWLA 30-DEC-05 4917391 : Create Invoice (not credit memo) if quote perdiem is positive
             --                              Create Credit Memo is quote per-diem is negative (e.g -ve value entered by the user)
             -- l_tilv_rec.amount   := ABS(l_perdiem_amt) * -1 * l_noofdays; -- always create a credit memo for perdiem amt
             l_tilv_rec.amount := l_perdiem_amt * l_noofdays;

             IF  l_tilv_rec.amount > 0 THEN
             l_pos_amount  := l_pos_amount + l_tilv_rec.amount;
             ELSIF l_tilv_rec.amount < 0 THEN
             l_neg_amount  := l_neg_amount + l_tilv_rec.amount;
             END IF;

             l_tilv_rec.sty_id := l_perdiem_sty_id;

             IF l_sys_prms_rec.LEASE_INV_ORG_YN = 'Y' THEN
                 l_tilv_rec.inventory_org_id := l_inv_org_id;
             END IF;

          l_tilv_tbl(l_line_number) := l_tilv_rec;
     END IF;
     END IF;
     -- RMUNJULU LOANS_ENHACEMENTS BILL PERDIEM_AMOUNT -- end

        -- RMUNJULU LOANS_ENHACEMENTS BILL REFUND_AMOUNT -- START
        -- create credit memos for loans refund only on full termination
  IF nvl(l_partial_yn,'N') = 'N' THEN

           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_UTIL_PVT.get_excess_loan_payment');
           END IF;
           l_loan_refund_amount := OKL_AM_UTIL_PVT.get_excess_loan_payment(
                                         x_return_status    => l_return_status,
                                         p_khr_id           => l_khr_id);
           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_UTIL_PVT.get_excess_loan_payment , return status: ' || l_return_status);
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_loan_refund_amount: ' || l_loan_refund_amount);
           END IF;

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
               IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := l_return_status;
               END IF;
           END IF;

        IF  l_loan_refund_amount <> 0 THEN

             -- get stream type ID
            --Bug 6266134 veramach start
           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_streams_util.get_dependent_stream_type');
           END IF;
            okl_streams_util.get_dependent_stream_type(
              p_khr_id                     => l_khr_id,
              p_primary_sty_purpose        => 'RENT',
              p_dependent_sty_purpose      => 'EXCESS_LOAN_PAYMENT_PAID',
              x_return_status              => l_return_status,
              x_dependent_sty_id           => l_refund_sty_id
            );
           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_streams_util.get_dependent_stream_type , return status: ' || l_return_status);
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_refund_sty_id: ' || l_refund_sty_id);
           END IF;
            --Bug 6266134 veramach end
             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
               IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                  l_overall_status := l_return_status;
               END IF;
             END IF;


              l_loan_refund_amount := l_loan_refund_amount *-1; -- negate the amount

              -- get the last line number
              IF l_tilv_tbl.COUNT > 0 THEN
                l_line_number := l_tilv_tbl(l_tilv_tbl.last).line_number;
              ELSE
                l_line_number := 0;
              END IF;

         l_line_number := l_line_number + 1;

           l_tilv_rec.line_number     := l_line_number;
              l_tilv_rec.description  := 'Loan Refund Amount';
              l_tilv_rec.amount       := l_loan_refund_amount;

              IF  l_tilv_rec.amount > 0 THEN
              l_pos_amount  := l_pos_amount + l_tilv_rec.amount;
              ELSIF l_tilv_rec.amount < 0 THEN
              l_neg_amount  := l_neg_amount + l_tilv_rec.amount;
              END IF;

              l_tilv_rec.sty_id := l_refund_sty_id;

              IF l_sys_prms_rec.LEASE_INV_ORG_YN = 'Y' THEN
                  l_tilv_rec.inventory_org_id := l_inv_org_id;
              END IF;

            l_tilv_tbl(l_line_number) := l_tilv_rec;

           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
               IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := l_return_status;
               END IF;
              END IF;
           END IF;
        END IF;
     -- RMUNJULU LOANS_ENHACEMENTS BILL REFUND_AMOUNT -- END
              -- akrangan - Bug#5521354 - Added - Start
 	         -- Adding logic to determine if there are any future invoices for billing adjustments

 	         -- Check for existence of billing adjustment only for a full termination quote
 	         IF nvl(l_partial_yn,'N') = 'N' THEN
 	            -- get the billing adjustment amounts and bill if full termination
 	            l_input_tbl(1).khr_id := l_khr_id;
 	            l_input_tbl(1).term_date_from := l_date_eff_from;

 	            -- Call BPD API to get billing from quote_effective_from_date onwards
                IF (is_debug_statement_on) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_BPD_TERMINATION_ADJ_PVT.get_billing_adjust');
                END IF;
 	            OKL_BPD_TERMINATION_ADJ_PVT.get_billing_adjust(
 	                         p_api_version     => l_api_version,
 	                         p_init_msg_list   => OKL_API.G_FALSE,
 	                         p_input_tbl       => l_input_tbl,
 	                         x_baj_tbl         => lx_baj_tbl,
 	                         x_return_status   => l_return_status,
 	                         x_msg_count       => l_msg_count,
 	                         x_msg_data        => l_msg_data);
                IF (is_debug_statement_on) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_BPD_TERMINATION_ADJ_PVT.get_billing_adjust , return status: ' || l_return_status);
                END IF;

 	             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
 	               -- Error getting the billing adjustments for the contract.
 	               OKL_API.set_message(
 	                    p_app_name      => 'OKL',
 	                    p_msg_name      => 'OKL_AM_ERROR_BILL_ADJST');
 	             END IF;
 	             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
 	               IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
 	                   l_overall_status := l_return_status;
 	               END IF;
 	             END IF;

 	             IF  l_tilv_tbl.COUNT = 0 THEN
 	               -- Check if future billing adjustments exists
		       IF lx_baj_tbl.COUNT > 0 THEN --akrangan added for bug 6323852
 	                 FOR i IN lx_baj_tbl.FIRST..lx_baj_tbl.LAST LOOP
 	                  -- check if future bills exist -- future implies future w.r.t quote effective from
 	                    IF lx_baj_tbl(i).amount <> 0 THEN

 	                      l_future_invoices_exists := 'Y';
 	                      EXIT;
 	                    END IF;
 	                 END LOOP;
		       END IF;--end lx_baj_tbl.COUNT > 0   --akrangan added for bug 6323852
 	             END IF; -- end of l_tilv_tbl.COUNT = 0
 	           END IF;

 	         -- akrangan - Bug#5521354 - Added - End

 	         -- akrangan - Bug#5521354 - Modified - Start
 	         -- Added condition to check if there are future bills
     IF  l_tilv_tbl.COUNT = 0
     AND x_sdd_taiv_tbl.COUNT = 0
     AND NVL(l_future_invoices_exists,'N') = 'N'
     THEN
     -- akrangan - Bug#5521354- Modified - End
--        AND nvl(l_future_invoices_exists,'N') = 'N' THEN -- rmunjulu 4610850 Added condition to Check if future billing adjustments exist
  IF NOT l_sdd_invoice THEN --added by veramach for bug#6766479
  l_return_status := OKL_API.G_RET_STS_ERROR;
  -- Message Text: The invoice has a balance of zero.
  OKC_API.SET_MESSAGE (
   p_app_name => G_APP_NAME,
   p_msg_name => 'OKL_BPD_ZERO_INVOICE');
     END IF; --added by veramach for bug#6766479
 	                 IF l_sdd_invoice THEN --veramach bug#6766479

 	                   OPEN check_cont_typ(l_khr_id);
 	                   FETCH check_cont_typ INTO l_cont_typ;
 	                   CLOSE check_cont_typ;

 	                  IF l_cont_typ = 'OKL_IMPORT' THEN
 	                   --display meesage 'OKL_AM_INVALID_DEP_AMT' ie 'There is no security deposit disposition
 	                   --amount remaining for the contract' in termination quote messages screen as per the update
 	                   --by PM *** MCORNEL  01/09/08 11:07 am *** in the bug#6508911 .
 	                   -- This message is already set in Create_Scrt_Dpst_Dsps_Inv.

 	                     OKL_AM_UTIL_PVT.process_messages(
 	                                 p_trx_source_table        => 'OKL_TRX_QUOTES_V',
 	                                  p_trx_id                        => p_quote_id,
 	                                 x_return_status     => l_return_status
 	                              );
 	                 END IF;

 	                END IF; --veramach end bug#6766479
END IF;
            IF l_amount_status <> OKL_API.G_RET_STS_SUCCESS THEN
  l_return_status  := OKL_API.G_RET_STS_ERROR;
  -- Message Text: Invalid value for the column Amount
  OKL_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => G_INVALID_VALUE,
   p_token1 => G_COL_NAME_TOKEN,
   p_token1_value => 'Amount');
            END IF;

            IF l_stream_status <> OKL_API.G_RET_STS_SUCCESS THEN
  l_return_status  := OKL_API.G_RET_STS_ERROR;
           END IF;

 END IF;

 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
     IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
  l_overall_status := l_return_status;
     END IF;
 END IF;

 x_pos_amount := l_pos_amount;
 x_neg_amount := l_neg_amount;

    -- rmunjulu BUG 4341480
    IF NVL(l_regular_qte_line,'N') = 'N' THEN
        l_r_taiv_tbl.DELETE;
    END IF;
    -- end of 4341480

 x_taiv_tbl := l_r_taiv_tbl;
 x_tilv_tbl := l_tilv_tbl;
 x_return_status := l_overall_status;
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
 END IF;

EXCEPTION

 WHEN OTHERS THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
  END IF;

  IF l_qte_csr%ISOPEN THEN
   CLOSE l_qte_csr;
  END IF;

  IF l_qpt_csr%ISOPEN THEN
   CLOSE l_qpt_csr;
  END IF;

  IF l_qlt_csr%ISOPEN THEN
   CLOSE l_qlt_csr;
  END IF;

  IF l_tai_csr%ISOPEN THEN
   CLOSE l_tai_csr;
  END IF;
        --PAGARG Bug 4044659 Close the cusrsor if open
  IF l_sys_prms_csr%ISOPEN THEN
   CLOSE l_sys_prms_csr;
  END IF;

  -- store SQL error message on message stack for caller
  OKL_API.SET_MESSAGE (
    p_app_name => G_APP_NAME
   ,p_msg_name => G_UNEXPECTED_ERROR
   ,p_token1 => G_SQLCODE_TOKEN
   ,p_token1_value => sqlcode
   ,p_token2 => G_SQLERRM_TOKEN
   ,p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END Validate_Populate_Quote;


-- Start of comments
--
-- Procedure Name   : Create_Quote_Invoice
-- Description      : Create Invoice from Termination or Repurchase Quote
-- Business Rules   :
-- Parameters       : quote id
-- Version          : 1.0
-- History          : RMUNJULU 11-FEB-03 2793710 Added code to check if tbl has recs
--                  : PAGARG   18-Aug-04 Create invoices or credit memos with
--                  :          transaction type as rollover for rollover quote
--                  : rmunjulu 4547765 Added code to handle Future dated billing adjustments
--                  : akrangan 5521354 Moved code to create billing adjustments, outside the loop
--                             over non BILL_ADJ quote lines
--                  :RBRUNO 10/10/07 Fixed the l_roll_tilv_tbl(l_l_cnt) assignment

-- End of comments

PROCEDURE Create_Quote_Invoice (
 p_api_version    IN  NUMBER,
 p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 p_quote_id       IN  NUMBER,
 x_taiv_tbl       OUT NOCOPY taiv_tbl_type) IS

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

 l_api_name     CONSTANT VARCHAR2(30)   :=  'Create_Quote_Invoice';
 l_api_version  CONSTANT NUMBER      := G_API_VERSION;
 l_msg_count    NUMBER ;-- rmunjulu bug 4341480  := OKL_API.G_MISS_NUM;
 l_msg_data     VARCHAR2(2000);

 l_h_cnt        NUMBER;
 l_l_cnt        NUMBER;

 l_pos_amount  NUMBER  := 0;
 l_neg_amount  NUMBER  := 0;
 l_allc_pos    NUMBER;
 l_allc_neg    NUMBER;
 l_allc_perc   NUMBER;

 l_taiv_tbl      taiv_tbl_type;
 l_taiv_rec      taiv_rec_type;
 l_tmp_taiv_tbl  taiv_tbl_type;
 lx_pos_taiv_rec taiv_rec_type;
 lx_neg_taiv_rec taiv_rec_type;
 l_sdd_taiv_tbl  taiv_tbl_type;
 l_tilv_tbl      tilv_tbl_type;
 l_tilv_rec      tilv_rec_type;
 lx_tilv_rec     tilv_rec_type;

        --+++++++++++ pagarg +++ Rollover +++++++ Start ++++++++++
 -- Following variables are used for creating counter
 -- invoices/credit memos for Rollover Quote
 l_qtp_code           okl_trx_quotes_b.qtp_code%TYPE DEFAULT NULL;
 l_qlt_mean           fnd_lookups.meaning%TYPE := NULL;
 l_roll_allc_pos      NUMBER;
 l_roll_allc_neg      NUMBER;
 l_roll_taiv_rec      taiv_rec_type;
 lx_pos_roll_taiv_rec taiv_rec_type;
 lx_neg_roll_taiv_rec taiv_rec_type;
 l_roll_tilv_rec      tilv_rec_type;
 lx_roll_tilv_rec     tilv_rec_type;
 l_roll_upd_taiv_rec  taiv_rec_type;
 lx_roll_upd_taiv_rec taiv_rec_type;
 l_roll_pos_adj       NUMBER := 0;
 l_roll_neg_adj       NUMBER := 0;

    -- Following cursor retrieves the quote type for the given quote id
    CURSOR quote_type_csr (p_quote_id IN NUMBER)
    IS
    SELECT qtp_code, khr_id
    FROM okl_trx_quotes_b
    WHERE id = p_quote_id;

    quote_type_rec quote_type_csr%rowtype;

    -- Following cursor retrieves the quote type meaning for given qlt_code
    CURSOR l_qlt_csr (p_qlt_code IN VARCHAR2)
    IS
    select fl.meaning
    from fnd_lookups fl
    where fl.lookup_type = 'OKL_QUOTE_LINE_TYPE'
      and fl.lookup_code = p_qlt_code;

    --+++++++++++ pagarg +++ Rollover +++++++ End ++++++++++

    --+++++++++++++++++++++ rmunjulu 4547765 ++++++++++++++++++++++++++++++++
    -- Cursor to obtain operational options values
    CURSOR l_sys_prms_csr IS
      SELECT NVL(LEASE_INV_ORG_YN, 'N') LEASE_INV_ORG_YN
      FROM OKL_SYSTEM_PARAMS;

    -- Get the quote line meaning for BILL_ADJST
    CURSOR get_qte_ln_meaning_csr IS
    SELECT fnd.meaning meaning
    FROM   FND_LOOKUPS fnd
    WHERE  fnd.lookup_type = 'OKL_QUOTE_LINE_TYPE'
    AND    fnd.lookup_code = 'BILL_ADJST';

    -- get quote details
    CURSOR get_qte_dtls_csr (p_quote_id IN NUMBER) IS
    SELECT upper(nvl(qte.partial_yn,'N')) partial_yn,
           qte.khr_id khr_id,
           qte.date_effective_from date_eff_from,
           qte.date_accepted date_accepted,
           chr.inv_organization_id inv_organization_id
    FROM   OKL_TRX_QUOTES_B qte,
           OKC_K_HEADERS_B chr
    WHERE  qte.id = p_quote_id
    AND    qte.khr_id = chr.id;

    l_partial_yn VARCHAR2(3);
    l_khr_id NUMBER;
    l_khr_le_id NUMBER := NULL;
    l_date_eff_from DATE;
    l_quote_accpt_date DATE;
    l_input_tbl OKL_BPD_TERMINATION_ADJ_PVT.input_tbl_type;
    lx_baj_tbl  OKL_BPD_TERMINATION_ADJ_PVT.baj_tbl_type;
    l_meaning VARCHAR2(300);
    l_sys_prms_rec l_sys_prms_csr%ROWTYPE;
    l_inv_org_id NUMBER;
    l_adj_values_found VARCHAR2(3);
    l_adj_taiv_rec taiv_rec_type;
    lx_pos_adj_taiv_rec taiv_rec_type;
    lx_neg_adj_taiv_rec taiv_rec_type;
    l_adj_allc_pos NUMBER;
    l_adj_allc_neg NUMBER;
    l_adj_tilv_rec tilv_rec_type;
    lx_adj_tilv_rec tilv_rec_type;

  l_adj_tilv_tbl   tilv_tbl_type;
  lx_adj_tilv_tbl  tilv_tbl_type;

  -- ANSETHUR 08-MAR-2007 Added For billing Achitecture Start changes
  -- Added For Enhanced Billing PVT
  l_tldv_tbl          okl_tld_pvt.tldv_tbl_type;
  lx_tldv_tbl         okl_tld_pvt.tldv_tbl_type;

  l_roll_tilv_tbl       tilv_tbl_type;
  lx_roll_tilv_tbl      tilv_tbl_type;

  lx_tilv_tbl      tilv_tbl_type;
  -- ANSETHUR 08-MAR-2007 Added For billing Achitecture End changes
  -- akrangan - Bug#5521354 - Added - Start
     -- Get the quote details to populate the TAIV record for billing adjustment
     CURSOR  l_qte_csr (cp_quote_id IN NUMBER) IS
       SELECT  qte.khr_id              khr_id,
	       qte.qtp_code            qtp_code,
	       flo.meaning             description,
	       qte.date_accepted       date_invoiced,
	       qte.currency_code        currency_code,
	       qte.currency_conversion_type currency_conversion_type,
	       qte.currency_conversion_rate currency_conversion_rate,
	       qte.currency_conversion_date currency_conversion_date,
	       khr.inv_organization_id inv_organization_id
	  FROM okl_trx_quotes_b        qte,
	       fnd_lookups             flo,
	       okc_k_headers_b         khr
       WHERE   qte.id                  = cp_quote_id
       AND     flo.lookup_type         = 'OKL_QUOTE_TYPE'
       AND     flo.lookup_code         = qte.qtp_code
       AND     khr.id                  = qte.khr_id;

     l_qte_rec               l_qte_csr%ROWTYPE;
   -- akrangan - Bug#5521354 - Added - End
   --akrangan BUG 6275650 start
    l_source_billing_trx  okl_trx_ar_invoices_b.okl_source_billing_trx%type := 'TERMINATION_QUOTE';
   --akrangan BUG 6275650 end
 l_module_name VARCHAR2(500) := G_MODULE_NAME || 'create_quote_invoice';
 is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
 is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
 is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  l_tmp_tilv_tbl      tilv_tbl_type; -- rmunjulu bug 6791004
BEGIN
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
 END IF;
 IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_quote_id: '|| p_quote_id);
 END IF;

 -- ***************************************************************
 -- Check API version, initialize message list and create savepoint
 -- ***************************************************************

 l_return_status := OKL_API.START_ACTIVITY (
  l_api_name,
  G_PKG_NAME,
  p_init_msg_list,
  l_api_version,
  p_api_version,
  '_PVT',
  x_return_status);

 IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
 END IF;

 -- *******************
 -- Validate parameters
 -- *******************

 IF p_quote_id IS NULL
 OR p_quote_id = G_MISS_NUM THEN

  OKC_API.SET_MESSAGE (
   p_app_name => G_OKC_APP_NAME,
   p_msg_name => 'OKC_NO_PARAMS',
   p_token1 => 'PARAM',
   p_token1_value => 'QUOTE_ID',
   p_token2 => 'PROCESS',
   p_token2_value => l_api_name);

  RAISE OKL_API.G_EXCEPTION_ERROR;

 END IF;

 -- Validate p_quote_id
 -- Populate all header fields
 -- Populate all invoice line fields for all quote line

 Validate_Populate_Quote (
                         p_quote_id      => p_quote_id,
                         x_pos_amount    => l_pos_amount,
                         x_neg_amount    => l_neg_amount,
                         x_taiv_tbl      => l_tmp_taiv_tbl,
                         x_tilv_tbl      => l_tilv_tbl,
                         x_sdd_taiv_tbl  => l_sdd_taiv_tbl,
                         x_return_status => l_return_status);
 IF (is_debug_statement_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called Validate_Populate_Quote , return status: ' || l_return_status);
 END IF;

 IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
 END IF;

    --+++++++++++ pagarg +++ Rollover +++++++ Start ++++++++++
    OPEN quote_type_csr(p_quote_id);
    FETCH quote_type_csr INTO quote_type_rec;
    CLOSE quote_type_csr;

    l_qtp_code := quote_type_rec.qtp_code;
    l_khr_id   := quote_type_rec.khr_id;

    IF l_qtp_code LIKE 'TER%' then
      l_khr_le_id := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id (l_khr_id);
    End If;

    OPEN l_qlt_csr('BILL_ADJST');
    FETCH l_qlt_csr INTO l_qlt_mean;
    CLOSE l_qlt_csr;
    --+++++++++++ pagarg +++ Rollover +++++++ End ++++++++++

 l_taiv_tbl := l_sdd_taiv_tbl;
 l_h_cnt  := NVL (l_taiv_tbl.COUNT, 0);

 -- *********************
 -- Create Invoice Header
 -- *********************

    -- RMUNJULU 11-FEB-03 2793710 Added check to see if tbl has recs
    IF l_tmp_taiv_tbl.COUNT > 0 THEN

      FOR i IN l_tmp_taiv_tbl.FIRST..l_tmp_taiv_tbl.LAST LOOP

     l_taiv_rec  := l_tmp_taiv_tbl(i);
     l_allc_perc := l_taiv_rec.amount;
     l_allc_pos  := l_pos_amount * (l_allc_perc / 100);
     l_allc_neg  := l_neg_amount * (l_allc_perc / 100);

     l_taiv_rec.legal_entity_id := l_khr_le_id;

     l_tmp_tilv_tbl.delete; -- rmunjulu bug 6791004
     l_tmp_tilv_tbl :=    l_tilv_tbl; -- rmunjulu bug 6791004

  -- ANSETHUR 08-MAR-2007 Added For billing Achitecture Start changes
  -- Included loop to update amount in tilv_tbl and call to Enhanced billing API
     l_l_cnt := l_tilv_tbl.FIRST;
     LOOP
        -- l_tilv_tbl(l_l_cnt).amount := l_tilv_tbl(l_l_cnt).amount * (l_allc_perc / 100); -- rmunjulu bug 6791004
        -- rmunjulu bug 6791004 Use another tmp tbl or else values are incorrect in the second round
        l_tmp_tilv_tbl (l_l_cnt).amount := l_tilv_tbl(l_l_cnt).amount * (l_allc_perc / 100);

     EXIT WHEN ( l_l_cnt = l_tilv_tbl.LAST OR l_return_status <> OKL_API.G_RET_STS_SUCCESS);
     l_l_cnt := l_tilv_tbl.NEXT(l_l_cnt);
     END LOOP;
     --AKRANGAN BUG 6275650 START
      l_taiv_rec.okl_source_billing_trx := l_source_billing_trx;
     --AKRANGAN BUG 6275650 END
  Create_billing_invoices (   p_taiv_rec     => l_taiv_rec ,--changed the rec type associated l_adj_taiv_rec ,
                              p_pos_amount   =>l_allc_pos ,
                              p_neg_amount   =>l_allc_neg,
                              p_tilv_tbl     =>l_tmp_tilv_tbl ,-- rmunjulu bug 6791004 Use tmp_tilv_tbl or else second round tilv values are becoming incorrect.
                              x_tilv_tbl     =>lx_tilv_tbl,
                              x_pos_taiv_rec =>lx_pos_taiv_rec ,
                              x_neg_taiv_rec =>lx_neg_taiv_rec,
                              x_return_status=>l_return_status);
  IF (is_debug_statement_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called Create_billing_invoices , return status: ' || l_return_status);
  END IF;

/*   -- ANSETHUR 08-MAR-2007 Commented For billing Achitecture
     Create_AR_Invoice_Header (
  p_taiv_rec => l_taiv_rec,
  p_pos_amount => l_allc_pos,
  p_neg_amount => l_allc_neg,
  x_pos_taiv_rec => lx_pos_taiv_rec,
  x_neg_taiv_rec => lx_neg_taiv_rec,
  x_return_status => l_return_status);
*/
     IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

  -- ANSETHUR 08-MAR-2007 Added For billing Achitecture End changes

        --+++++++++++ pagarg +++ Rollover +++++++ Start ++++++++++
        -- Create invoice headers for negative and positive quote lines
        -- for rollover transaction.
        -- Use the same processing of rollover quote for Release quote
        -- pagarg +++ T and A +++
        IF l_qtp_code LIKE 'TER_ROLL%' OR l_qtp_code = 'TER_RELEASE_WO_PURCHASE'
        THEN

            l_roll_taiv_rec := l_taiv_rec;
            l_roll_allc_pos := l_allc_neg * -1;
            l_roll_allc_neg := l_allc_pos * -1;

            -- ANSETHUR 08-MAR-2007 Added For billing Achitecture Start changes
            -- Added Loop to assign value to tilv_tbl for roll over quotes and sum up the adjustment
												-- The sum of adjustment is again updated the the amount of taiv_rec for the roll over quote
               l_l_cnt := l_tilv_tbl.FIRST;
               LOOP
             --START RBRUNO 10/10/07 Fixed the l_roll_tilv_tbl(l_l_cnt) assignment
              l_roll_tilv_tbl(l_l_cnt) := l_tilv_tbl(l_l_cnt);
             --END RBRUNO 10/10/07 Fixed the l_roll_tilv_tbl(l_l_cnt) assignment
                      -- l_roll_tilv_tbl(l_l_cnt) := l_tilv_rec;
                      --l_roll_tilv_tbl(l_l_cnt).legal_entity_id := l_khr_le_id;
                        -- l_roll_tilv_tbl(l_l_cnt).amount := l_roll_tilv_tbl(l_l_cnt).amount * -1 ; -- rmunjulu bug 6791004

                        -- rmunjulu bug 6791004 Multiply with allocation percent to get the right rollover values
                        l_roll_tilv_tbl(l_l_cnt).amount := l_roll_tilv_tbl(l_l_cnt).amount * -1 * (l_allc_perc / 100);

                   IF l_roll_tilv_rec.description = l_qlt_mean
                      THEN

                          IF l_roll_tilv_rec.amount > 0
                          THEN
                              l_roll_pos_adj := l_roll_pos_adj + l_roll_tilv_tbl(l_l_cnt).amount;
                          ELSIF l_roll_tilv_rec.amount < 0
                          THEN
                              l_roll_neg_adj := l_roll_neg_adj + l_roll_tilv_tbl(l_l_cnt).amount;
                          END IF;
                      END IF;


               EXIT WHEN ( l_l_cnt = l_tilv_tbl.LAST OR l_return_status <> OKL_API.G_RET_STS_SUCCESS);
               l_l_cnt := l_tilv_tbl.NEXT(l_l_cnt);
               END LOOP;

                 IF l_roll_pos_adj > 0
                  THEN
                     l_roll_taiv_rec.amount := l_roll_taiv_rec.amount - l_roll_pos_adj;
                  END IF;

                  IF l_roll_neg_adj < 0
                  THEN
                     l_roll_taiv_rec.amount := l_roll_taiv_rec.amount - l_roll_neg_adj;
                  END IF;
     --AKRANGAN BUG 6275650 START
      l_roll_taiv_rec.okl_source_billing_trx := l_source_billing_trx;
     --AKRANGAN BUG 6275650 END


                   Create_billing_invoices (   p_taiv_rec     =>l_roll_taiv_rec ,
                                               p_pos_amount   =>l_roll_allc_pos ,
                                               p_neg_amount   =>l_roll_allc_neg,
                                               p_quote_type   =>l_qtp_code ,
                                               p_trans_type  => 'REVERSE',
                                               p_tilv_tbl     =>l_roll_tilv_tbl,
                                               x_tilv_tbl     =>lx_roll_tilv_tbl,
                                               x_pos_taiv_rec =>lx_pos_roll_taiv_rec ,
                                               x_neg_taiv_rec =>lx_neg_roll_taiv_rec,
                                               x_return_status=>l_return_status);
                  IF (is_debug_statement_on) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called Create_billing_invoices , return status: ' || l_return_status);
                  END IF;
            IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        END IF; -- for Rollover quote

/* -- ANSETHUR 08-MAR-2007 Commented For billing Achitecture
            Create_AR_Invoice_Header (
                p_taiv_rec  => l_roll_taiv_rec,
                p_pos_amount  => l_roll_allc_pos,
                p_neg_amount  => l_roll_allc_neg,
                p_quote_type  => l_qtp_code,
                -- pagarg +++ T and A +++
                p_trans_type  => 'REVERSE',
                x_pos_taiv_rec  => lx_pos_roll_taiv_rec,
                x_neg_taiv_rec  => lx_neg_roll_taiv_rec,
                x_return_status => l_return_status);

            IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;




        --+++++++++++ pagarg +++ Rollover +++++++ End ++++++++++

     -- *********************************************
     -- Create Invoice Lines for each record in table
     -- *********************************************

        -- pagarg +++ Rollover +++
        -- intialize the negative and postive adjustment variables
        l_roll_pos_adj := 0;
        l_roll_neg_adj := 0;

     l_l_cnt := l_tilv_tbl.FIRST;
     LOOP

  l_tilv_rec   := l_tilv_tbl(l_l_cnt);
  l_tilv_rec.amount := l_tilv_rec.amount * (l_allc_perc / 100);

  IF l_tilv_rec.amount > 0 THEN
   l_tilv_rec.tai_id := lx_pos_taiv_rec.id;
  ELSIF l_tilv_rec.amount < 0 THEN
   l_tilv_rec.tai_id := lx_neg_taiv_rec.id;
  ELSE
   l_tilv_rec.tai_id := NULL;
  END IF;

  Create_AR_Invoice_Lines (
   p_tilv_rec       => l_tilv_rec,
   x_tilv_rec       => lx_tilv_rec,
   x_return_status => l_return_status);

        --+++++++++++ pagarg +++ Rollover +++++++ Start ++++++++++

-- Process the invoice lines for rollover quote. Negate the amount and set the
-- header id accordingly and call insert for invoice lines for rollover.
-- Use the same processing of rollover quote for Release quote
        -- pagarg +++ T and A +++
        IF l_qtp_code LIKE 'TER_ROLL%' OR l_qtp_code = 'TER_RELEASE_WO_PURCHASE'
        THEN
            l_roll_tilv_rec := l_tilv_rec;
            --l_roll_tilv_rec.legal_entity_id := l_khr_le_id;
            l_roll_tilv_rec.amount := l_tilv_rec.amount * -1;
            IF l_roll_tilv_rec.amount > 0
            THEN
                l_roll_tilv_rec.tai_id := lx_pos_roll_taiv_rec.id;
            ELSIF l_roll_tilv_rec.amount < 0
            THEN
                l_roll_tilv_rec.tai_id := lx_neg_roll_taiv_rec.id;
            ELSE
                l_roll_tilv_rec.tai_id := NULL;
            END IF;

-- If quote line is not Estimated Billing Adjustments then create rollover
-- invoice line else add them in adjusted amount variable and update the header
-- after the loop is over.
            IF l_tilv_rec.description <> l_qlt_mean
            THEN
                Create_AR_Invoice_Lines (
                    p_tilv_rec => l_roll_tilv_rec,
                    x_tilv_rec => lx_roll_tilv_rec,
                    x_return_status => l_return_status);
            ELSE
                IF l_roll_tilv_rec.amount > 0
                THEN
                    l_roll_pos_adj := l_roll_pos_adj + l_roll_tilv_rec.amount;
                ELSIF l_roll_tilv_rec.amount < 0
                THEN
                    l_roll_neg_adj := l_roll_neg_adj + l_roll_tilv_rec.amount;
                END IF;
            END IF;
        END IF;

  EXIT WHEN ( l_l_cnt = l_tilv_tbl.LAST
   OR l_return_status <> OKL_API.G_RET_STS_SUCCESS);
  l_l_cnt := l_tilv_tbl.NEXT(l_l_cnt);
     END LOOP;

-- If there is any amount to be adjusted in the variable then call the procedure
-- to update the corresponding header
        IF l_roll_pos_adj > 0
        THEN
            l_roll_upd_taiv_rec.id := lx_pos_roll_taiv_rec.id;
            l_roll_upd_taiv_rec.legal_entity_id := l_khr_le_id;
            l_roll_upd_taiv_rec.amount := l_roll_upd_taiv_rec.amount - l_roll_pos_adj;
            okl_trx_ar_invoices_pub.update_trx_ar_invoices(
                p_api_version   => l_api_version,
                p_init_msg_list => OKL_API.G_FALSE,
                x_return_status => l_return_status,
                x_msg_count     => l_msg_count,
                x_msg_data      => l_msg_data,
                p_taiv_rec      => l_roll_upd_taiv_rec,
                x_taiv_rec      => lx_roll_upd_taiv_rec);
        END IF;
        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF l_roll_neg_adj < 0
        THEN
            l_roll_upd_taiv_rec.id := lx_neg_roll_taiv_rec.id;
            l_roll_upd_taiv_rec.legal_entity_id := l_khr_le_id;
            l_roll_upd_taiv_rec.amount := l_roll_upd_taiv_rec.amount - l_roll_neg_adj;
            okl_trx_ar_invoices_pub.update_trx_ar_invoices(
                p_api_version   => l_api_version,
                p_init_msg_list => OKL_API.G_FALSE,
                x_return_status => l_return_status,
                x_msg_count     => l_msg_count,
                x_msg_data      => l_msg_data,
                p_taiv_rec      => l_roll_upd_taiv_rec,
                x_taiv_rec      => lx_roll_upd_taiv_rec);
        END IF;
        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
*/
  -- ANSETHUR 08-MAR-2007 Added For billing Achitecture End changes

     -- ************
     -- Save results
     -- ************

     IF l_pos_amount > 0 THEN
  l_h_cnt := l_h_cnt + 1;
  l_taiv_tbl (l_h_cnt) := lx_pos_taiv_rec;
     END IF;

     IF l_neg_amount < 0 THEN
  l_h_cnt := l_h_cnt + 1;
  l_taiv_tbl (l_h_cnt) := lx_neg_taiv_rec;
     END IF;

        --+++++++++++ pagarg +++ Rollover +++++++ Start ++++++++++

        -- pagarg +++ T and A +++
        IF l_qtp_code LIKE 'TER_ROLL%' OR l_qtp_code = 'TER_RELEASE_WO_PURCHASE'
        THEN
            IF l_roll_allc_pos > 0
            THEN
                l_h_cnt := l_h_cnt + 1;
                l_taiv_tbl (l_h_cnt) := lx_pos_roll_taiv_rec;
            END IF;
            IF l_roll_allc_neg < 0 THEN
                l_h_cnt := l_h_cnt + 1;
                l_taiv_tbl (l_h_cnt) := lx_neg_roll_taiv_rec;
            END IF;
        END IF;
        --+++++++++++ pagarg +++ Rollover +++++++ End ++++++++++
        END LOOP;
        END IF;
	-- akrangan - Bug#5521354 - Moved - Start
        -- Moved code to check for future bills outside the block where quote lines other than
        -- billing adjustments are being handled
	 --++++++ START ++++++ rmunjulu 4547765 CREDIT FUTURE BILLS ON FUTURE DATE +++
  -- Do billing adjustment processing only in case of full termination
  --IF nvl(l_partial_yn,'N') = 'N' THEN

         -- GET QUOTE DETAILS
         OPEN get_qte_dtls_csr (p_quote_id);
         FETCH get_qte_dtls_csr INTO l_partial_yn, l_khr_id, l_date_eff_from, l_quote_accpt_date, l_inv_org_id;
         CLOSE get_qte_dtls_csr;

        -- rmunjulu INVESTOR_DISB_ADJST
        IF nvl(l_partial_yn,'N') = 'Y' THEN

           -- need to check if no more assets
           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.check_true_partial_quote');
           END IF;
           l_partial_yn := OKL_AM_LEASE_LOAN_TRMNT_PVT.check_true_partial_quote(
                                p_quote_id     => p_quote_id,
                                p_contract_id  => l_khr_id);
           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PVT.check_true_partial_quote , l_partial_yn: ' || l_partial_yn);
           END IF;

        END IF;

  -- Do billing adjustment processing only in case of full termination
  IF nvl(l_partial_yn,'N') = 'N' THEN

   -- get meaning for BILL_ADJST
   OPEN  get_qte_ln_meaning_csr;
   FETCH get_qte_ln_meaning_csr INTO l_meaning;
   CLOSE get_qte_ln_meaning_csr;

   -- GET SYS OPTIONS SETUP DETAILS
         OPEN l_sys_prms_csr;
         FETCH l_sys_prms_csr INTO l_sys_prms_rec;
         -- IF no row fetched from cursor then set the value as N for LEASE_INV_ORG_YN
         IF l_sys_prms_csr%NOTFOUND THEN
             l_sys_prms_rec.LEASE_INV_ORG_YN := 'N';
         END IF;
         CLOSE l_sys_prms_csr;

           -- get the billing adjustment amounts and bill if full termination
           l_input_tbl(1).khr_id := l_khr_id;
           l_input_tbl(1).term_date_from := l_date_eff_from;

        -- Call BPD API to get billing from quote_effective_from_date onwards
           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_BPD_TERMINATION_ADJ_PVT.get_billing_adjust');
           END IF;
           OKL_BPD_TERMINATION_ADJ_PVT.get_billing_adjust(
                                    p_api_version     => l_api_version,
                                    p_init_msg_list   => OKL_API.G_FALSE,
                                    p_input_tbl       => l_input_tbl,
                                    x_baj_tbl         => lx_baj_tbl,
                                    x_return_status   => l_return_status,
                                    x_msg_count       => l_msg_count,
                                    x_msg_data        => l_msg_data);
           IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_BPD_TERMINATION_ADJ_PVT.get_billing_adjust , return status: ' || l_return_status);
           END IF;

           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

           -- Error getting the billing adjustments for the contract.
              OKL_API.set_message(
                   p_app_name      => 'OKL',
                   p_msg_name      => 'OKL_AM_ERROR_BILL_ADJST');
            END IF;

            IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            -- for each value returned by BPD api
            IF lx_baj_tbl.COUNT > 0 THEN
               FOR i IN lx_baj_tbl.FIRST..lx_baj_tbl.LAST LOOP

                  -- process only if amount <> 0 and future bills
                  IF lx_baj_tbl(i).amount <> 0 then
		  -- akrangan commenting out following condition for bug 5503113 -- start
                  --AND trunc(lx_baj_tbl(i).stream_element_date) > trunc(l_quote_accpt_date) THEN
                  --akrangan commenting for bug 5503113 end
                     l_adj_values_found := 'Y';
                    --akrangan bug#5521354 start
		   IF (l_taiv_rec.qte_id is NULL OR l_taiv_rec.qte_id = G_MISS_NUM )
			and (l_taiv_rec.khr_id is NULL OR l_taiv_rec.khr_id = G_MISS_NUM ) then
			 -- ***********************
			 -- Get Quote Header Record
			 -- ***********************

			 OPEN    l_qte_csr (p_quote_id);
			 FETCH   l_qte_csr INTO l_qte_rec;

			 IF l_qte_csr%NOTFOUND THEN
			    l_return_status := OKL_API.G_RET_STS_ERROR;
			    OKC_API.SET_MESSAGE (
					 p_app_name      => G_OKC_APP_NAME,
					 p_msg_name      => G_INVALID_VALUE,
					 p_token1        => G_COL_NAME_TOKEN,
					 p_token1_value  => 'Quote_Id');
			 ELSE
			   l_taiv_rec.khr_id        := l_qte_rec.khr_id;
			   l_taiv_rec.description   := l_qte_rec.description;
			   l_taiv_rec.currency_code := l_qte_rec.currency_code;
			   l_taiv_rec.date_invoiced := l_qte_rec.date_invoiced;
			   l_taiv_rec.qte_id        := p_quote_id;

			   l_taiv_rec.currency_conversion_type := l_qte_rec.currency_conversion_type;
			   l_taiv_rec.currency_conversion_rate := l_qte_rec.currency_conversion_rate;
			   l_taiv_rec.currency_conversion_date := l_qte_rec.currency_conversion_date;
			 END IF;

			 CLOSE   l_qte_csr;

			 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
			   IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
				   l_overall_status := l_return_status;
			   END IF;
			 END IF;
		       END IF;
		    --akrangan bug#5521354 end
                     -- set header record
                     l_adj_taiv_rec := l_taiv_rec;
                     l_adj_taiv_rec.legal_entity_id := l_khr_le_id;
		     --akrangan bug 5503113 -- start
 	             l_adj_taiv_rec.ibt_id := NULL;
 	             l_adj_taiv_rec.ixx_id := NULL;
 	             l_adj_taiv_rec.irt_id := NULL;

 	             IF (trunc(lx_baj_tbl(i).stream_element_date) <= trunc(l_quote_accpt_date)) THEN -- bug 5503113 -- start
 	                 l_adj_taiv_rec.date_invoiced :=l_adj_taiv_rec.date_invoiced;
 	             ELSE
                     l_adj_taiv_rec.date_invoiced := lx_baj_tbl(i).stream_element_date;
		     END IF;
		     --akrangan bug 5503113 -- end
		      --akrangan bug 5521354 start
                      -- l_adj_taiv_rec.amount := lx_baj_tbl(i).amount * -1 * (l_allc_perc / 100); -- negate amount and set based on allc percent
		      -- reverse the entire amount and bill this to lessee
		      -- allocation not considered as billing adjustments are
		      -- billed only to lessee and not to other recipients
		      l_adj_taiv_rec.amount := lx_baj_tbl(i).amount * -1 ;
                      --akrangan bug 5521354 end
                     IF l_adj_taiv_rec.amount > 0 THEN
                        l_adj_allc_pos := l_adj_taiv_rec.amount;
                     ELSE
                        l_adj_allc_neg := l_adj_taiv_rec.amount;
                     END IF;


-- Added for the tilv rec
                     l_adj_tilv_rec.line_number  := 1;
                     l_adj_tilv_rec.kle_id       := lx_baj_tbl(i).kle_id; -- Asset Id

                     l_adj_tilv_rec.description  := l_meaning; -- Estimated Billing Adjustment
                     l_adj_tilv_rec.amount       := l_adj_taiv_rec.amount;  -- same as header amount

                     -- for billing adjustments the original stream type will be used
                     -- Do not use quote line allocation streams
                     l_adj_tilv_rec.sty_id       := lx_baj_tbl(i).sty_id;

                     -- If LEASE_INV_ORG_YN is Y then set the value of
                     -- INVENTORY_ORG_ID in invoice line with contract inv_organization_id
                     IF l_sys_prms_rec.LEASE_INV_ORG_YN = 'Y' THEN
                        l_adj_tilv_rec.inventory_org_id := l_inv_org_id;
                     END IF;

                     l_adj_tilv_tbl(0) := l_adj_tilv_rec;
     --AKRANGAN BUG 6275650 START
      l_adj_taiv_rec.okl_source_billing_trx := l_source_billing_trx;
     --AKRANGAN BUG 6275650 END

    Create_billing_invoices (
                              p_taiv_rec     =>l_adj_taiv_rec ,
                              p_pos_amount   =>l_adj_allc_pos ,
                              p_neg_amount   =>l_adj_allc_neg,
                              p_quote_type   =>l_qtp_code ,
                              p_tilv_tbl     =>l_adj_tilv_tbl ,
                              x_tilv_tbl     =>lx_adj_tilv_tbl ,
                              x_pos_taiv_rec =>lx_pos_adj_taiv_rec ,
                              x_neg_taiv_rec =>lx_neg_adj_taiv_rec,
                              x_return_status=>l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called Create_billing_invoices , return status: ' || l_return_status);
    END IF;

                     IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                     END IF;
/*
                     -- create invoice header
                     Create_AR_Invoice_Header (
                           p_taiv_rec  => l_adj_taiv_rec,
                           p_pos_amount  => l_adj_allc_pos,
                           p_neg_amount  => l_adj_allc_neg,
                           p_quote_type  => l_qtp_code,
                           x_pos_taiv_rec => lx_pos_adj_taiv_rec,
                           x_neg_taiv_rec => lx_neg_adj_taiv_rec,
                           x_return_status => l_return_status);

                     IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                     END IF;

                     -- set detail record
                     IF l_adj_taiv_rec.amount > 0  THEN
                        l_adj_tilv_rec.tai_id := lx_pos_adj_taiv_rec.id;
                     ELSE
                        l_adj_tilv_rec.tai_id := lx_neg_adj_taiv_rec.id;
                     END IF;
               l_adj_tilv_rec.line_number  := 1;
               l_adj_tilv_rec.kle_id       := lx_baj_tbl(i).kle_id; -- Asset Id

               l_adj_tilv_rec.description  := l_meaning; -- Estimated Billing Adjustment
               l_adj_tilv_rec.amount       := l_adj_taiv_rec.amount;  -- same as header amount

                     -- for billing adjustments the original stream type will be used
                     -- Do not use quote line allocation streams
                     l_adj_tilv_rec.sty_id := lx_baj_tbl(i).sty_id;

                     -- If LEASE_INV_ORG_YN is Y then set the value of
                     -- INVENTORY_ORG_ID in invoice line with contract inv_organization_id
                     IF l_sys_prms_rec.LEASE_INV_ORG_YN = 'Y' THEN
                        l_adj_tilv_rec.inventory_org_id := l_inv_org_id;
                     END IF;

               -- create invoice line
                     Create_AR_Invoice_Lines (
                        p_tilv_rec     => l_adj_tilv_rec,
                        x_tilv_rec     => lx_adj_tilv_rec,
                        x_return_status => l_return_status);

                     IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                     END IF;
*/

                     IF l_adj_allc_pos > 0 THEN
                        l_h_cnt := l_h_cnt + 1;
                        l_taiv_tbl (l_h_cnt) := lx_pos_adj_taiv_rec;
                     END IF;
                     IF l_adj_allc_neg < 0 THEN
                        l_h_cnt := l_h_cnt + 1;
                        l_taiv_tbl (l_h_cnt) := lx_neg_adj_taiv_rec;
                     END IF;
                  END IF;
               END LOOP;
	       --akrangan bug 5503113 start
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_BPD_TERMINATION_ADJ_PVT.create_passthru_adj');
        END IF;
		OKL_BPD_TERMINATION_ADJ_PVT.create_passthru_adj(
			    p_api_version     => l_api_version,
				 p_init_msg_list   => OKL_API.G_FALSE,
			    p_baj_tbl         => lx_baj_tbl,
			    x_return_status   => l_return_status,
			    x_msg_count       => l_msg_count,
			    x_msg_data        => l_msg_data);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_BPD_TERMINATION_ADJ_PVT.create_passthru_adj , return status: ' || l_return_status);
        END IF;


		IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

		       -- Error performing passthru disbursments.
		   OKL_API.set_message(
			p_app_name      => 'OKL',
			p_msg_name      => 'OKL_AM_ERROR_PASS_THRU_DISB');

		END IF;
		IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
			 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
		      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
			 RAISE OKL_API.G_EXCEPTION_ERROR;
		END IF;
		--akrangan bug 5503113 end
           END IF;
        END IF;
        --++++++ END   ++++++ rmunjulu 4547765 CREDIT FUTURE BILLS ON FUTURE DATE +++

   --akrangan Bug#5521354 - Moved - End
    /*  END LOOP;

    END IF; */
   --akrangan Bug#5521354 - Moved - End

 -- **************
 -- Return results
 -- **************

 x_taiv_tbl := l_taiv_tbl;
 x_return_status := l_overall_status;

 OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
 END IF;

EXCEPTION

 WHEN OKL_API.G_EXCEPTION_ERROR THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
  END IF;
  x_return_status := OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OKL_API.G_RET_STS_ERROR',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

 WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
  END IF;
  x_return_status :=OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OKL_API.G_RET_STS_UNEXP_ERROR',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

 WHEN OTHERS THEN
  IF (is_debug_exception_on) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
  END IF;

  x_return_status :=OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OTHERS',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

END Create_Quote_Invoice;

END OKL_AM_INVOICES_PVT;

/
