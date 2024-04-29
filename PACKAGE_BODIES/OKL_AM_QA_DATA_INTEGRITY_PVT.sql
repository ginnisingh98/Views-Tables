--------------------------------------------------------
--  DDL for Package Body OKL_AM_QA_DATA_INTEGRITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_QA_DATA_INTEGRITY_PVT" AS
/* $Header: OKLRAMQB.pls 120.3.12010000.5 2009/11/06 11:49:44 smadhava ship $ */


-- Start of comments
-- The list of AM Packges which use rules:
-- "Validated" means that a rule is validated in this API
-- "Not Validated" means that a rule is optional and does not need to be checked
--
-- OKLRAMIB.pls - OKL_AM_INVOICES_PVT
-- 	Validated:	Program Vendor Billing Info	- Only for Repurchase Agreements
--	Validated:	Lease Vendor Billing Info	- Warnings only if rule setup is not correct
--	Validated:	Security Deposit Disposition	- If rule exist, check correct dates
-- OKLRAMPB.pls - OKL_AM_PARTIES_PVT
--	Validated:	Termination Quote Recipients	- Warnings only if rule setup is not correct
--	Validated:	Repurchase Quote Recipient	- Only for Repurchase Agreements, Not a Rule
-- OKLRAMUB.pls - OKL_AM_UTIL_PVT
--	Validated:	Bill To Address			- Mandatory; non-AM rule
-- OKLRARRB.pls - OKL_AM_ASSET_RETURN_PVT
--	Not Validated:	Floor and Item Price Formulas	- Optional
--	Not Validated:	Repurchase Agreement Flag	- Optional
--	Not Validated:	3rd Party Custodian		- Optional (non-AM rule)
-- OKLRCQTB.pls - OKL_AM_CREATE_QUOTE_PVT
--	Not Validated:	Early Termination Allowed	- Optional
--	Not Validated:	Partial Termination Allowed	- Optional
--	Validated:	Term Status			- Mandatory
--	Validated:	Quote Effectivity		- Mandatory plus check correct values
-- OKLRCQUB.pls - OKL_AM_CALCULATE_QUOTE_PVT
--	Not Validated:	Top Repurchase Formula		- Optional  (3 operands)
--	Not Validated:	Top Early Termination Formula	- Optional  (8 operands)
--	Not Validated:	Top EOT Termination Formula	- Optional  (8 operands)
--	Not Validated	Top Early Purch. Option Formula	- Optional  (1 operand)
--	Validated:	Top EOT Purchase Option Formula	- Mandatory (1 operand)
--	Validated:	Formula Operands		- Optional, but check correct setup
-- OKLRLTNB.pls - OKL_AM_LEASE_TRMNT_PVT
--	Not Validated:	Evegreen Eligibility		- Optional; non-AM rule
--	Not Validated:	Tax Owner			- Optional; currently not used; non-AM rule
-- OKLRPTFB.pls - OKL_AM_CONTRACT_PRTFL_PVT
--	Validated:	Budget Amount			- Mandatory plus check correct setup
--	Validated:	Strategy			- Mandatory
--	Validated:	Assignment Group		- Mandatory
--	Validated:	Execution Due Date		- Mandatory
--	Not Validated:	Approval Requirement		- Optional
-- OKLRQWFB.pls - OKL_AM_QUOTES_WF
--	Not Validated:	Bill of Sale			- Optional
--	Not Validated:	Title Filing			- Optional
--	Not Validated:	Partial Quote			- Optional
--	Validated:	Gain and Loss			- Optional, but check correct setup
-- OKLRRQUB.pls - OKL_AM_REPURCHASE_ASSET_PVT
--	Validated:	Quote Effectivity		- Mandatory, validated in CREATE_QUOTE
-- OKLRRWFB.pls - OKL_AM_ASSET_RETURN_WF
--	Not Validated:	3rd Party Custodian		- Optional; non-AM rule
-- OKLRTATB.pls - OKL_AM_AMORTIZE_PVT
--	Not Validated:	Tax Owner			- Optional; currently not used; non-AM rule
--
-- End of comments

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_STATEMENT            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(500) :=
'okl.am.plsql.okl_am_qa_data_integrity_pvt.';

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  SUBTYPE taiv_rec_type IS okl_trx_ar_invoices_pub.taiv_rec_type;
  SUBTYPE rulv_rec_type IS okl_rule_pub.rulv_rec_type;
  SUBTYPE qtev_rec_type IS okl_trx_quotes_pub.qtev_rec_type;
  SUBTYPE qpyv_tbl_type IS okl_quote_parties_pub.qpyv_tbl_type;


-- Start of comments
--
-- Procedure Name	: get_repurchase_agreement
-- Description		: Get the repurchase agreement Y/N flag
-- Note			: Copied from OKL_AM_ASSET_RETURN_PVT
-- Business Rules	:
-- Parameters		: Contract Id
-- Version		: 1.0
-- End of comments

FUNCTION get_repurchase_agreement (
		p_chr_id	IN NUMBER)
		RETURN		VARCHAR2 AS

	--Check if Vendor program is attached to the Lease contract
	CURSOR  l_khr_csr (cp_chr_id IN NUMBER) IS
		SELECT  khr.khr_id	prog_khr_id
		FROM    okl_k_headers	khr
		WHERE	khr.id		= cp_chr_id;

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_rep_agreement_yn	VARCHAR2(1)	:= 'N';
	l_program_khr_id	NUMBER := NULL;
	l_rulv_rec		rulv_rec_type;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'get_repurchase_agreement';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
    END IF;

	OPEN	l_khr_csr (p_chr_id);
	FETCH	l_khr_csr INTO l_program_khr_id;
	CLOSE	l_khr_csr;

	IF l_program_khr_id IS NOT NULL THEN

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
        END IF;
		okl_am_util_pvt.get_rule_record(
			p_rgd_code	=> 'AMREPQ',
			p_rdf_code	=> 'AMARQC',
			p_chr_id	=> p_chr_id,
			p_cle_id	=> NULL,
			p_message_yn	=> FALSE,
			x_rulv_rec	=> l_rulv_rec,
			x_return_status	=> l_return_status);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record , return status: ' || l_return_status);
        END IF;

		IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
			IF  l_rulv_rec.rule_information1 IS NOT NULL
			AND l_rulv_rec.rule_information1 <> OKL_API.G_MISS_CHAR
THEN
				l_rep_agreement_yn	:=
l_rulv_rec.rule_information1;
			END IF;
		END IF;
	END IF;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Returning l_rep_agreement_yn : ' || l_rep_agreement_yn);
     END IF;

	RETURN l_rep_agreement_yn;

EXCEPTION

	WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

		-- close open cursors
		IF l_khr_csr%ISOPEN THEN
			CLOSE l_khr_csr;
		END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		RETURN 'N';

END get_repurchase_agreement;


-- Start of comments
--
-- Procedure Name	: check_quote_effectivity
-- Description		: Check correct values entered for Quote Effectivity rules
-- Business Rules	:
-- Parameters		: Quote Effective Days, Quote Maximum Effective Days
-- Version		: 1.0
-- End of comments

PROCEDURE check_quote_effectivity (
	p_rule_info1		IN VARCHAR2,
	p_rule_info2		IN VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2) IS

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_quote_eff_days	NUMBER		:= NULL;
	l_quote_eff_max_days	NUMBER		:= NULL;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_quote_effectivity';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rule_info1: '||p_rule_info1);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rule_info2: '||p_rule_info2);
    END IF;

	IF  p_rule_info1 IS NOT NULL
	AND p_rule_info1 <> G_MISS_CHAR THEN
		l_quote_eff_days	:= to_number (p_rule_info1);
	ELSE
		l_return_status := OKL_API.G_RET_STS_ERROR;
		OKC_API.SET_MESSAGE (
			p_app_name	=> G_OKC_APP_NAME,
			p_msg_name	=> G_REQUIRED_VALUE,
			p_token1	=> G_COL_NAME_TOKEN,
			p_token1_value	=> 'Quote Effective Days');
	END IF;

	IF l_quote_eff_days <= 0 THEN
		l_return_status := OKL_API.G_RET_STS_ERROR;
		OKC_API.SET_MESSAGE (
			p_app_name	=> G_OKC_APP_NAME,
			p_msg_name	=> G_INVALID_VALUE,
			p_token1	=> G_COL_NAME_TOKEN,
			p_token1_value	=> 'Quote Effective Days');
	END IF;

	IF  p_rule_info2 IS NOT NULL
	AND p_rule_info2 <> G_MISS_CHAR THEN
		l_quote_eff_max_days	:= p_rule_info2;
	ELSE
		l_return_status := OKL_API.G_RET_STS_ERROR;
		OKC_API.SET_MESSAGE (
			p_app_name	=> G_OKC_APP_NAME,
			p_msg_name	=> G_REQUIRED_VALUE,
			p_token1	=> G_COL_NAME_TOKEN,
			p_token1_value	=> 'Quote Effective Maximum Days');
	END IF;

	IF l_quote_eff_max_days <= 0 THEN
		l_return_status := OKL_API.G_RET_STS_ERROR;
		OKC_API.SET_MESSAGE (
			p_app_name	=> G_OKC_APP_NAME,
			p_msg_name	=> G_INVALID_VALUE,
			p_token1	=> G_COL_NAME_TOKEN,
			p_token1_value	=> 'Quote Effective Maximum Days');
	END IF;

	IF l_quote_eff_days > l_quote_eff_max_days THEN

		l_return_status := OKL_API.G_RET_STS_ERROR;
		-- Please enter a value in Column COL_NAME1
		-- that is less than the value of Column COL_NAME2.
		OKC_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> 'OKL_LESS_THAN'
			,p_token1	=> 'COL_NAME1'
			,p_token1_value	=> 'Quote Effective Days'
			,p_token2	=> 'COL_NAME2'
			,p_token2_value	=> 'Quote Effective Maximum Days');

	END IF;

	x_return_status	:= l_return_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END check_quote_effectivity;


-- Start of comments
--
-- Procedure Name	: check_rule_value
-- Description		: Check Formula/Amount type rules are setup correctly
-- Business Rules	:
-- Parameters		: Contract Id, Rule Group Code, Rule Code
-- Version		: 1.0
-- 09-02-2008 rbruno bug 6471193, added optional new parameter p_option_type and
--logic to handle invalid
-- combinations of options under TC "End of Term Purchase Option, Contract"
-- 11-13-2008 rbruno bug 7569441, added logic to proper handle purchase option values for
-- "Fair Market Value" purchase option
-- End of comments

PROCEDURE check_rule_value (
	p_calc_option		IN VARCHAR2,
	p_fixed_value		IN VARCHAR2,
	p_formula_name		IN VARCHAR2,
        p_option_type           IN VARCHAR2 := G_MISS_CHAR, -- rbruno
	p_rgd_code		IN VARCHAR2,
	p_rdf_code		IN VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2) IS

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_rule_value';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_calc_option: '||p_calc_option);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_fixed_value: '||p_fixed_value);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_formula_name: '||p_formula_name);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rgd_code: '||p_rgd_code);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rdf_code: '||p_rdf_code);
    END IF;



  -- begin rbruno bug fix 6471193
   IF (NVL(p_rdf_code,G_MISS_CHAR) = 'AMBPOC') and  p_option_type <> G_MISS_CHAR THEN


    --  If purchase option type = $1 Buyout
    --  then Purchase Option         :Use Fixed Amount
    --  Purchase Option Amount  :1

        IF p_option_type = '$1BO'
         AND p_calc_option = 'USE_FIXED_AMOUNT'
         AND p_fixed_value = '1' AND nvl(p_formula_name,G_MISS_CHAR)  =
G_MISS_CHAR THEN

        l_return_status	:= OKL_API.G_RET_STS_SUCCESS;

  --  If purchase option type = Fair Market Value
  --  then Purchase Option         :Use Fixed Amount or Use Formula
  --  Purchase Option Amount  :any amount except zero if Purchase
  --  Option=Use Fixed Amount


	ELSIF p_option_type = 'FMV' THEN
  -- rbruno   7569441 change begin
 -- rbruno 7591732 --commented if
  --If (p_calc_option = 'USE_FIXED_AMOUNT' AND nvl(p_fixed_value,G_MISS_NUM)  <> G_MISS_NUM AND nvl(p_formula_name,G_MISS_CHAR)  = G_MISS_CHAR)
  --   OR (p_calc_option = 'USE_FORMULA' AND nvl(p_formula_name,G_MISS_CHAR)  <> G_MISS_CHAR AND nvl(p_fixed_value,G_MISS_NUM)  = G_MISS_NUM) THEN


  -- rbruno   7591732 change begin
  -- If (p_calc_option = 'NOT_APPLICABLE' AND nvl(p_fixed_value,G_MISS_NUM)  = G_MISS_NUM AND nvl(p_formula_name,G_MISS_CHAR)  = G_MISS_CHAR) THEN
  -- rbruno   7591732 change end
  -- smadhava Added - Bug# 9044139
 	   if (((p_calc_option = 'USE_FORMULA' AND nvl(p_formula_name,G_MISS_CHAR)  <> G_MISS_CHAR AND nvl(p_fixed_value,G_MISS_NUM)  = G_MISS_NUM))
 	        or (p_calc_option = 'NOT_APPLICABLE')) THEN
     l_return_status	:= OKL_API.G_RET_STS_SUCCESS;

     Else

     okl_am_util_pvt.set_invalid_rule_message (
			p_rgd_code	=> p_rgd_code,
			p_rdf_code	=> p_rdf_code);

     l_return_status	:= OKL_API.G_RET_STS_ERROR;

   END IF;
  -- rbruno 7569441 change end

  -- If purchase option type = Fixed Purchase Option
  -- then Purchase Option         :Use Fixed Amount
  -- Purchase Option Amount  : Any amount except zero


    -- smadhava - Modified for - Bug# 9044139
	--ELSIF p_option_type = 'FPO'
	--AND p_calc_option = 'USE_FIXED_AMOUNT'
	--AND to_number(NVL (p_fixed_value,'0')) > 0 AND
    --   nvl(p_formula_name,G_MISS_CHAR)  = G_MISS_CHAR THEN
    ELSIF p_option_type = 'FPO'
    AND ((p_calc_option = 'USE_FIXED_AMOUNT'
	           AND to_number(NVL (p_fixed_value,'0')) > 0
	           AND nvl(p_formula_name,G_MISS_CHAR)  = G_MISS_CHAR)
            OR  (((p_calc_option = 'USE_FORMULA' AND nvl(p_formula_name,G_MISS_CHAR)  <> G_MISS_CHAR AND nvl(p_fixed_value,G_MISS_NUM)  = G_MISS_NUM)))
	        OR (p_calc_option = 'NOT_APPLICABLE')) THEN

		l_return_status	:= OKL_API.G_RET_STS_SUCCESS;

  -- If purchase option type = None
  -- then Purchase Option         :Not Applicable

      ELSIF p_option_type =  'NONE'
      AND  p_calc_option = 'NOT_APPLICABLE' THEN

         l_return_status	:= OKL_API.G_RET_STS_SUCCESS;



      ELSE -- Invalid combination of values

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.set_invalid_rule_message');
        END IF;
		okl_am_util_pvt.set_invalid_rule_message (
			p_rgd_code	=> p_rgd_code,
			p_rdf_code	=> p_rdf_code);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.set_invalid_rule_message');
        END IF;

		l_return_status	:= OKL_API.G_RET_STS_ERROR;

	END IF;



   ELSE -- end rbruno bug fix 6471193


	IF    p_calc_option = 'NOT_APPLICABLE'
	AND   NVL (p_fixed_value,  G_MISS_CHAR) =  G_MISS_CHAR
	AND   NVL (p_formula_name, G_MISS_CHAR) =  G_MISS_CHAR THEN

		l_return_status	:= OKL_API.G_RET_STS_SUCCESS;

	ELSIF p_calc_option = 'USE_FIXED_AMOUNT'
	AND   NVL (p_fixed_value,  G_MISS_CHAR) <> G_MISS_CHAR
	AND   NVL (p_formula_name, G_MISS_CHAR) =  G_MISS_CHAR THEN

		l_return_status	:= OKL_API.G_RET_STS_SUCCESS;

	ELSIF p_calc_option = 'USE_FORMULA'
	AND   NVL (p_fixed_value,  G_MISS_CHAR) =  G_MISS_CHAR
	AND   NVL (p_formula_name, G_MISS_CHAR) <> G_MISS_CHAR THEN

		l_return_status	:= OKL_API.G_RET_STS_SUCCESS;

	ELSE

		-- Invalid combination of values
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.set_invalid_rule_message');
        END IF;
		okl_am_util_pvt.set_invalid_rule_message (
			p_rgd_code	=> p_rgd_code,
			p_rdf_code	=> p_rdf_code);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.set_invalid_rule_message');
        END IF;

		l_return_status	:= OKL_API.G_RET_STS_ERROR;

	END IF;
   END IF;

	x_return_status	:= l_return_status;
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
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END check_rule_value;


-- Start of comments
--
-- Procedure Name	: check_rule_setup
-- Description		: Check Formula/Amount type rules are setup correctly
-- Business Rules	:
-- Parameters		: Contract Id, Rule Group Code, Rule Code
-- Version		: 1.0
-- End of comments

PROCEDURE check_rule_setup (
	p_rgd_code		IN VARCHAR2,
	p_rdf_code		IN VARCHAR2,
	p_chr_id		IN  NUMBER,
	x_return_status		OUT NOCOPY VARCHAR2) IS

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_rulv_rec		rulv_rec_type;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_rule_setup';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rgd_code: '||p_rgd_code);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rdf_code: '||p_rdf_code);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
    END IF;

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
    END IF;
	okl_am_util_pvt.get_rule_record (
			p_rgd_code	=> p_rgd_code,
			p_rdf_code	=> p_rdf_code,
			p_chr_id	=> p_chr_id,
			p_cle_id	=> NULL,
			p_message_yn	=> FALSE,
			x_rulv_rec	=> l_rulv_rec,
			x_return_status	=> l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record , return status: ' || l_return_status);
    END IF;

	-- If rule is not found, return Success
	-- If rule is found, check its setup
	IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN

		-- ********************************************************
		-- Evalute rule record: not_applicable, constant or formula
		-- The field INFO1 indicated if the rule is either
		-- not applicable (evaluated to null), equals to a
		-- constant value, or equals to a value of a formula.
		-- The field INFO2 allows to specify the value of a
		-- the constant. The field INFO3 allows to specify a
		-- formula to use for calculations.
		-- ********************************************************

		check_rule_value (
			p_calc_option	=> l_rulv_rec.rule_information1,
			p_fixed_value	=> l_rulv_rec.rule_information2,
			p_formula_name	=> l_rulv_rec.rule_information3,

			p_rgd_code	=> p_rgd_code,
			p_rdf_code	=> p_rdf_code,
			x_return_status	=> l_return_status);

		IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR
THEN
				l_overall_status := l_return_status;
			END IF;
		END IF;

		-- Some rules store maximum allowed value
		IF p_rdf_code IN ('AMCTPE','AMBPOC') THEN

		    check_rule_value (
			p_calc_option	=> l_rulv_rec.rule_information5,
			p_fixed_value	=> l_rulv_rec.rule_information6,
			p_formula_name	=> l_rulv_rec.rule_information7,
			p_rgd_code	=> p_rgd_code,
			p_rdf_code	=> p_rdf_code,
			x_return_status	=> l_return_status);

		    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR
THEN
				l_overall_status := l_return_status;
			END IF;
		    END IF;

		END IF;

		-- Some rules store minimum allowed value
		IF p_rdf_code IN ('AMBPOC') THEN

		    check_rule_value (
			p_calc_option	=> l_rulv_rec.rule_information8,
			p_fixed_value	=> l_rulv_rec.rule_information9,
			p_formula_name	=> l_rulv_rec.rule_information10,
			p_rgd_code	=> p_rgd_code,
			p_rdf_code	=> p_rdf_code,
			x_return_status	=> l_return_status);

		    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR
THEN
				l_overall_status := l_return_status;
			END IF;
		    END IF;

		END IF;

	END IF;

	x_return_status	:= l_overall_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END check_rule_setup;


-- Start of comments
--
-- Procedure Name	: check_contract_portfolio
-- Description		: Check contract portfolio rules
-- Business Rules	:
-- Parameters		: Contract Id
-- Version		: 1.0
-- End of comments

PROCEDURE check_contract_portfolio (
	x_return_status		OUT NOCOPY VARCHAR2,
	p_chr_id		IN  NUMBER) IS

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_rulv_rec		rulv_rec_type;
	l_rgd_code		VARCHAR2(30)	:= 'AMCOPO';	-- Contract Portfolio RG
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_contract_portfolio';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
    END IF;

	-- *************
	-- Budget Amount
	-- *************

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
    END IF;
	okl_am_util_pvt.get_rule_record (
			p_rgd_code	=> l_rgd_code,
			p_rdf_code	=> 'AMPRBA',
			p_chr_id	=> p_chr_id,
			p_cle_id	=> NULL,
			p_message_yn	=> TRUE,
			x_rulv_rec	=> l_rulv_rec,
			x_return_status	=> l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record , return status: ' || l_return_status);
    END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	check_rule_setup (
			p_rgd_code	=> l_rgd_code,
			p_rdf_code	=> 'AMPRBA',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- ********
	-- Strategy
	-- ********

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
    END IF;
	okl_am_util_pvt.get_rule_record(
			p_rgd_code	=> l_rgd_code,
			p_rdf_code	=> 'AMPRST',
			p_chr_id	=> p_chr_id,
			p_cle_id	=> NULL,
			p_message_yn	=> TRUE,
			x_rulv_rec	=> l_rulv_rec,
			x_return_status	=> l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record , return status: ' || l_return_status);
    END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- ****************
	-- Assignment Group
	-- ****************

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
    END IF;
	okl_am_util_pvt.get_rule_record(
			p_rgd_code	=> l_rgd_code,
			p_rdf_code	=> 'AMPRAG',
			p_chr_id	=> p_chr_id,
			p_cle_id	=> NULL,
			p_message_yn	=> TRUE,
			x_rulv_rec	=> l_rulv_rec,
			x_return_status	=> l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record , return status: ' || l_return_status);
    END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- ******************
	-- Execution Due Date
	-- ******************

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
    END IF;
	okl_am_util_pvt.get_rule_record(
			p_rgd_code	=> l_rgd_code,
			p_rdf_code	=> 'AMPRED',
			p_chr_id	=> p_chr_id,
			p_cle_id	=> NULL,
			p_message_yn	=> TRUE,
			x_rulv_rec	=> l_rulv_rec,
			x_return_status	=> l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record , return status: ' || l_return_status);
    END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	x_return_status		:= l_overall_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' ||
sqlerrm);
      END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END check_contract_portfolio;


-- Start of comments
--
-- Procedure Name	: check_calculate_quote
-- Description		: Check rules for quote calculations
-- Business Rules	:
-- Parameters		: Contract Id
-- Version		: 1.0
-- End of comments

PROCEDURE check_calculate_quote (
	x_return_status		OUT NOCOPY VARCHAR2,
	p_chr_id		IN  NUMBER) IS

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_rulv_rec		rulv_rec_type;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_calculate_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
    END IF;

	-- ***************************************
	-- Top End of Term Purchase Option Formula
	-- ***************************************

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
    END IF;
	okl_am_util_pvt.get_rule_record(
			p_rgd_code	=> 'AMTFOC',
			p_rdf_code	=> 'AMBPOC',
			p_chr_id	=> p_chr_id,
			p_cle_id	=> NULL,
			p_message_yn	=> TRUE,
			x_rulv_rec	=> l_rulv_rec,
			x_return_status	=> l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record , return status: ' || l_return_status);
    END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- **********************************************************
	-- Setup of Rules included into Top Early Termination Formula
	-- **********************************************************

	-- Contract Obligation
	check_rule_setup (
			p_rgd_code	=> 'AMTEWC',
			p_rdf_code	=> 'AMBCOC',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Return Fee
	check_rule_setup (
			p_rgd_code	=> 'AMTEWC',
			p_rdf_code	=> 'AMCRFE',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Rollover Incentive
	check_rule_setup (
			p_rgd_code	=> 'AMTEWC',
			p_rdf_code	=> 'AMCRIN',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Estimated Property Tax
	check_rule_setup (
			p_rgd_code	=> 'AMTEWC',
			p_rdf_code	=> 'AMPRTX',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Security Deposit Disposition
	check_rule_setup (
			p_rgd_code	=> 'AMTEWC',
			p_rdf_code	=> 'AMCSDD',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Quote Fee
	check_rule_setup (
			p_rgd_code	=> 'AMTEWC',
			p_rdf_code	=> 'AMCQFE',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Quote Discount Rate
	check_rule_setup (
			p_rgd_code	=> 'AMTEWC',
			p_rdf_code	=> 'AMCQDR',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Termination Penalty
	check_rule_setup (
			p_rgd_code	=> 'AMTEWC',
			p_rdf_code	=> 'AMCTPE',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- ****************************************************************
	-- Setup of Rules included into Top End of Term Termination Formula
	-- ****************************************************************

	-- Contract Obligation
	check_rule_setup (
			p_rgd_code	=> 'AMTFWC',
			p_rdf_code	=> 'AMBCOC',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Return Fee
	check_rule_setup (
			p_rgd_code	=> 'AMTFWC',
			p_rdf_code	=> 'AMCRFE',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Rollover Incentive
	check_rule_setup (
			p_rgd_code	=> 'AMTFWC',
			p_rdf_code	=> 'AMCRIN',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Estimated Property Tax
	check_rule_setup (
			p_rgd_code	=> 'AMTFWC',
			p_rdf_code	=> 'AMPRTX',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Security Deposit Disposition
	check_rule_setup (
			p_rgd_code	=> 'AMTFWC',
			p_rdf_code	=> 'AMCSDD',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Quote Fee
	check_rule_setup (
			p_rgd_code	=> 'AMTFWC',
			p_rdf_code	=> 'AMCQFE',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Quote Discount Rate
	check_rule_setup (
			p_rgd_code	=> 'AMTFWC',
			p_rdf_code	=> 'AMCQDR',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Termination Penalty
	check_rule_setup (
			p_rgd_code	=> 'AMTFWC',
			p_rdf_code	=> 'AMCTPE',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- **************************************************************
	-- Setup of Rules included into Top Early Purchase Option Formula
	-- **************************************************************

	-- Purchase Option Amount
	check_rule_setup (
			p_rgd_code	=> 'AMTEOC',
			p_rdf_code	=> 'AMBPOC',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- ********************************************************************
	-- Setup of Rules included into Top End of Term Purchase Option Formula
	-- ********************************************************************

	-- Purchase Option Amount
	check_rule_setup (
			p_rgd_code	=> 'AMTFOC',
			p_rdf_code	=> 'AMBPOC',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- ***************************************************
	-- Setup of Rules included into Top Repurchase Formula
	-- ***************************************************

	-- Sale Price
	check_rule_setup (
			p_rgd_code	=> 'AMREPQ',
			p_rdf_code	=> 'AMBSPR',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Quote Fee
	check_rule_setup (
			p_rgd_code	=> 'AMREPQ',
			p_rdf_code	=> 'AMCQFE',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- Quote Discount Rate
	check_rule_setup (
			p_rgd_code	=> 'AMREPQ',
			p_rdf_code	=> 'AMCQDR',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	x_return_status		:= l_overall_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END check_calculate_quote;


-- Start of comments
--
-- Procedure Name	: check_create_quote
-- Description		: Check termination and repurchase quote creation rules
-- Business Rules	:
-- Parameters		: Contract Id
-- Version		: 1.0
-- End of comments

PROCEDURE check_create_quote (
	x_return_status		OUT NOCOPY VARCHAR2,
	p_chr_id		IN  NUMBER) IS

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_rulv_rec		rulv_rec_type;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_create_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
    END IF;

	-- *******************************************************
	-- Quote Effectivity for Termination and Repurchase Quotes
	-- *******************************************************

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
    END IF;
	okl_am_util_pvt.get_rule_record(
			p_rgd_code	=> 'AMTQPR',
			p_rdf_code	=> 'AMQTEF',
			p_chr_id	=> p_chr_id,
			p_cle_id	=> NULL,
			p_message_yn	=> TRUE,
			x_rulv_rec	=> l_rulv_rec,
			x_return_status	=> l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record , return status: ' || l_return_status);
    END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN

		check_quote_effectivity (
			p_rule_info1	=> l_rulv_rec.rule_information1,
			p_rule_info2	=> l_rulv_rec.rule_information2,
			x_return_status	=> l_return_status);

	END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- *********************************
	-- Term Status for Termination Quote
	-- *********************************

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
    END IF;
	okl_am_util_pvt.get_rule_record(
			p_rgd_code	=> 'AMTQPR',
			p_rdf_code	=> 'AMTSET',
			p_chr_id	=> p_chr_id,
			p_cle_id	=> NULL,
			p_message_yn	=> TRUE,
			x_rulv_rec	=> l_rulv_rec,
			x_return_status	=> l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record , return status: ' || l_return_status);
    END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	x_return_status		:= l_overall_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END check_create_quote;


-- Start of comments
--
-- Procedure Name	: check_quote_wf
-- Description		: Check quote workflow rules
-- Business Rules	:
-- Parameters		: Contract Id
-- Version		: 1.0
-- End of comments

PROCEDURE check_quote_wf (
	x_return_status		OUT NOCOPY VARCHAR2,
	p_chr_id		IN  NUMBER) IS

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_quote_wf';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
    END IF;

	-- *************
	-- Gain and Loss
	-- *************

	check_rule_setup (
			p_rgd_code	=> 'AMTGAL',
			p_rdf_code	=> 'AMGALO',
			p_chr_id	=> p_chr_id,
			x_return_status	=> l_return_status);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	x_return_status		:= l_overall_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END check_quote_wf;


-- Start of comments
--
-- Procedure Name	: check_termin_quote_parties
-- Description		: Check Termination Quote Parties
-- Business Rules	:
-- Parameters		: Contract Id
-- Version		: 1.0
-- End of comments

PROCEDURE check_termin_quote_parties (
	x_return_status		OUT NOCOPY VARCHAR2,
	p_chr_id		IN  NUMBER) IS

	-- Get vendors attached to Lease contract
	CURSOR l_vendor_csr (cp_chr_id NUMBER) IS
		SELECT	pr.id			cpl_id
		FROM	okc_k_party_roles_b	pr
		WHERE	pr.rle_code		= 'OKL_VENDOR'
		AND	pr.cle_id		IS NULL
		AND	pr.chr_id		= cp_chr_id
		AND	pr.dnz_chr_id		= cp_chr_id;

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;

	l_qtev_rec		qtev_rec_type;	-- Quote Header
	l_qpyv_tbl		qpyv_tbl_type;	-- Quote Parties
	l_taiv_rec		taiv_rec_type;	-- Billing Header
	e_taiv_rec		taiv_rec_type;	-- Empty Billing Header
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_termin_quote_parties';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
    END IF;

	-- ********************************************
	-- Validate all quote parties using setup rules
	-- ********************************************

	l_qtev_rec.khr_id	:= p_chr_id;

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_parties_pvt.create_quote_parties');
    END IF;
	-- The procedure will issue warning messages
	okl_am_parties_pvt.create_quote_parties (
		p_qtev_rec	=> l_qtev_rec,
		p_validate_only	=> TRUE,
		x_qpyv_tbl	=> l_qpyv_tbl,
		x_return_status	=> l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_parties_pvt.create_quote_parties , return status: ' || l_return_status);
    END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- ********************************************************
	-- Check if vendor billiing rules are set for Lease Vendors
	-- ********************************************************

	FOR l_vendor_rec IN l_vendor_csr (p_chr_id) LOOP

		l_taiv_rec		:= e_taiv_rec;
		l_taiv_rec.khr_id	:= p_chr_id;

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_invoices_pvt.get_vendor_billing_info');
        END IF;
		-- The procedure will issue warning messages
		okl_am_invoices_pvt.get_vendor_billing_info (
			p_cpl_id	=> l_vendor_rec.cpl_id,
			px_taiv_rec	=> l_taiv_rec,
			x_return_status	=> l_return_status);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_invoices_pvt.get_vendor_billing_info , return status: ' || l_return_status);
        END IF;

		IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR
THEN
				l_overall_status := l_return_status;
			END IF;
		END IF;

	END LOOP;

	x_return_status		:= l_overall_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

		-- close open cursors
		IF l_vendor_csr%ISOPEN THEN
			CLOSE l_vendor_csr;
		END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END check_termin_quote_parties;


-- Start of comments
--
-- Procedure Name	: check_repurch_quote_parties
-- Description		: Check Repurchase Quote Parties
-- Business Rules	:
-- Parameters		: Contract Id
-- Version		: 1.0
-- End of comments

PROCEDURE check_repurch_quote_parties (
	x_return_status		OUT NOCOPY VARCHAR2,
	p_chr_id		IN  NUMBER) IS

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;

	l_qtev_rec		qtev_rec_type;	-- Quote Header
	l_qpyv_tbl		qpyv_tbl_type;	-- Quote Parties
	l_taiv_rec		taiv_rec_type;	-- Billing Header
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_repurch_quote_parties';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
    END IF;

	IF get_repurchase_agreement (p_chr_id) = 'Y' THEN

		-- **********************************************
		-- Validate a vendor partner as a quote recipient
		-- **********************************************

		l_qtev_rec.khr_id	:= p_chr_id;

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_parties_pvt.create_partner_as_recipient');
        END IF;
		-- The procedure will issue error messages if needed
		okl_am_parties_pvt.create_partner_as_recipient (
			p_qtev_rec	=> l_qtev_rec,
			p_validate_only	=> TRUE,
			x_qpyv_tbl	=> l_qpyv_tbl,
			x_return_status	=> l_return_status);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_parties_pvt.create_partner_as_recipient , return status: ' || l_return_status);
        END IF;

		IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := l_return_status;
			END IF;
		END IF;

		-- *********************************************************
		-- Check if vendor billiing rules are set for Program Vendor
		-- *********************************************************

		l_taiv_rec.khr_id	:= p_chr_id;

        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_invoices_pvt.get_vendor_billing_info');
        END IF;
		-- The procedure will issue error messages if needed
		okl_am_invoices_pvt.get_vendor_billing_info (
			px_taiv_rec	=> l_taiv_rec,
			x_return_status	=> l_return_status);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_invoices_pvt.get_vendor_billing_info , return status: ' || l_return_status);
        END IF;

		IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR
THEN
				l_overall_status := l_return_status;
			END IF;
		END IF;

	END IF;

	x_return_status		:= l_overall_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END check_repurch_quote_parties;


-- Start of comments
--
-- Procedure Name	: check_bill_to_address
-- Description		: Check Customer Bill To Address
-- Business Rules	:
-- Parameters		: Contract Id
-- Version		: 1.0
-- End of comments

PROCEDURE check_bill_to_address (
	x_return_status		OUT NOCOPY VARCHAR2,
	p_chr_id		IN  NUMBER) IS

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_bill_to_address_rec	okx_cust_site_uses_v%ROWTYPE;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_bill_to_address';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
    END IF;

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_bill_to_address');
    END IF;
	okl_am_util_pvt.get_bill_to_address (
		p_contract_id		=> p_chr_id,
		x_bill_to_address_rec	=> l_bill_to_address_rec,
		x_return_status		=> l_return_status);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_bill_to_address , return status: ' || l_return_status);
 END IF;

	x_return_status		:= l_return_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END check_bill_to_address;


-- Start of comments
--
-- Procedure Name	: check_sec_dep_disp
-- Description		: Check Security Deposit Disposition Rule
-- Business Rules	:
-- Parameters		: Contract Id
-- Version		: 1.0
-- End of comments

PROCEDURE check_sec_dep_disp (
	x_return_status		OUT NOCOPY VARCHAR2,
	p_chr_id		IN  NUMBER) IS

	-- Get default date format
	CURSOR l_date_format_csr IS
		SELECT	SYS_CONTEXT ('USERENV','NLS_DATE_FORMAT')
		FROM	dual;

	-- Get contract end date
	CURSOR l_contract_csr (cp_chr_id NUMBER) IS
		SELECT	end_date
		FROM	okc_k_headers_b
		WHERE	id = cp_chr_id;

	l_rulv_rec		rulv_rec_type;
	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;

	-- Values stored in Security Deposit Rule
	l_held_until_maturity	VARCHAR2(1);
	l_held_until_date	DATE;

	l_date_format		VARCHAR2(100);
	l_contract_end_date	DATE;
	l_sysdate		DATE		:= SYSDATE;
	l_calculate_sdd		BOOLEAN;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_sec_dep_disp';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
    END IF;

	-- *************************
	-- Get Security Deposit Rule
	-- *************************

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling okl_am_util_pvt.get_rule_record');
    END IF;
	okl_am_util_pvt.get_rule_record (
		p_rgd_code	=> 'LASDEP',
		p_rdf_code	=> 'LASDEP',
		p_chr_id	=> p_chr_id,
		p_cle_id	=> NULL,
		x_rulv_rec	=> l_rulv_rec,
		x_return_status	=> l_return_status,
		p_message_yn	=> FALSE);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_util_pvt.get_rule_record , return status: ' || l_return_status);
    END IF;

	IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN

		OPEN	l_contract_csr (p_chr_id);
		FETCH	l_contract_csr INTO l_contract_end_date;
		CLOSE	l_contract_csr;

		l_held_until_maturity	:= l_rulv_rec.rule_information2;

		OPEN	l_date_format_csr;
		FETCH	l_date_format_csr INTO l_date_format;
		CLOSE	l_date_format_csr;

		-- Security Deposit is hold till pre-defined date
		l_held_until_date := to_date (
			l_rulv_rec.rule_information5, l_date_format);

		-- If held_until_date is given, it should be greater then contract end_date
		-- If held_until_date is not given, it will be defaulted to contract_end_date
		IF  l_held_until_maturity = 'Y'
		AND l_held_until_date IS NOT NULL
		AND l_held_until_date <> G_MISS_DATE
		AND l_held_until_date < l_contract_end_date THEN

			l_return_status	:= OKL_API.G_RET_STS_ERROR;
			OKC_API.SET_MESSAGE (
				p_app_name	=> G_OKC_APP_NAME,
				p_msg_name	=> G_INVALID_VALUE,
				p_token1	=> G_COL_NAME_TOKEN,
				p_token1_value	=> 'Security Deposit Held Until Date');

		END IF;

	ELSE
		-- The rule is optional
		l_return_status := OKL_API.G_RET_STS_SUCCESS;
	END IF;

	x_return_status		:= l_return_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

		-- Close open cursors

		IF l_date_format_csr%ISOPEN THEN
			CLOSE l_date_format_csr;
		END IF;

		IF l_contract_csr%ISOPEN THEN
			CLOSE l_contract_csr;
		END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			p_app_name	=> OKL_API.G_APP_NAME,
			p_msg_name	=> 'OKL_CONTRACTS_UNEXPECTED_ERROR',
			p_token1	=> 'SQLCODE',
			p_token1_value	=> SQLCODE,
			p_token2	=> 'SQLERRM',
			p_token2_value	=> SQLERRM);

END check_sec_dep_disp;


-- Start of comments
--
-- Procedure Name	: check_am_rule_format
-- Description		: Check correct format of rules used by AM
-- Business Rules	:
-- Parameters		: Contract Id, Rule record
-- Version		: 1.0
-- End of comments

PROCEDURE check_am_rule_format (
	x_return_status	OUT NOCOPY VARCHAR2,
	p_chr_id	IN  NUMBER,
	p_rgr_rec	IN  rgr_rec_type) IS

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_am_rule_format';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rgr_rec.rule_information_category: ' || p_rgr_rec.rule_information_category);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rgr_rec.rgd_code: ' || p_rgr_rec.rgd_code);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rgr_rec.rule_information1: ' || p_rgr_rec.rule_information1);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rgr_rec.rule_information2: ' || p_rgr_rec.rule_information2);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rgr_rec.rule_information3: ' || p_rgr_rec.rule_information3);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rgr_rec.rule_information4: ' || p_rgr_rec.rule_information4);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rgr_rec.rule_information5: ' || p_rgr_rec.rule_information5);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rgr_rec.rule_information6: ' || p_rgr_rec.rule_information6);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rgr_rec.rule_information7: ' || p_rgr_rec.rule_information7);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rgr_rec.rule_information8: ' || p_rgr_rec.rule_information8);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rgr_rec.rule_information9: ' || p_rgr_rec.rule_information9);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_rgr_rec.rule_information10: ' || p_rgr_rec.rule_information10);
    END IF;


	-- **************************************************
	-- Formula-Amount rules used for various calculations
	-- **************************************************

	IF p_rgr_rec.rule_information_category IN
		('AMPRBA','AMGALO','AMBCOC','AMCRFE','AMCRIN','AMPRTX',
		 'AMCSDD','AMCQFE','AMCQDR','AMCTPE','AMBPOC','AMBSPR') THEN

		-- ********************************************************
		-- Evalute rule record: not_applicable, constant or formula
		-- The field INFO1 indicated if the rule is either
		-- not applicable (evaluated to null), equals to a
		-- constant value, or equals to a value of a formula.
		-- The field INFO2 allows to specify the value of a
		-- the constant. The field INFO3 allows to specify a
		-- formula to use for calculations.
		-- ********************************************************


-- Changed this call to add new parameter p_option_type
-- rbruno bug fix 6471193

		check_rule_value (
			p_calc_option	=> p_rgr_rec.rule_information1,
			p_fixed_value	=> p_rgr_rec.rule_information2,
			p_formula_name	=> p_rgr_rec.rule_information3,
                        p_option_type   => p_rgr_rec.rule_information11,
			p_rgd_code	=> p_rgr_rec.rgd_code,
			p_rdf_code	=> p_rgr_rec.rule_information_category,
			x_return_status	=> l_return_status);

		IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := l_return_status;
			END IF;
		END IF;

		-- Some rules store maximum allowed value
		IF p_rgr_rec.rule_information_category IN ('AMCTPE','AMBPOC') THEN

		    check_rule_value (
			p_calc_option	=> p_rgr_rec.rule_information5,
			p_fixed_value	=> p_rgr_rec.rule_information6,
			p_formula_name	=> p_rgr_rec.rule_information7,
			p_rgd_code	=> p_rgr_rec.rgd_code,
			p_rdf_code	=> p_rgr_rec.rule_information_category,
			x_return_status	=> l_return_status);

		    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := l_return_status;
			END IF;
		    END IF;

		END IF;

		-- Some rules store minimum allowed value
		IF p_rgr_rec.rule_information_category IN ('AMBPOC') THEN

		    check_rule_value (
			p_calc_option	=> p_rgr_rec.rule_information8,
			p_fixed_value	=> p_rgr_rec.rule_information9,
			p_formula_name	=> p_rgr_rec.rule_information10,
			p_rgd_code	=> p_rgr_rec.rgd_code,
			p_rdf_code	=> p_rgr_rec.rule_information_category,
			x_return_status	=> l_return_status);

		    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := l_return_status;
			END IF;
		    END IF;

		END IF;

    -- rkuttiya 16-SEP-2003  added following code for Bug:2794685
    --Some rules store tolerance values
                IF p_rgr_rec.rule_information_category IN ('AMGALO') THEN
		    check_rule_value (
			p_calc_option	=> p_rgr_rec.rule_information7,
			p_fixed_value	=> p_rgr_rec.rule_information4,
			p_formula_name	=> p_rgr_rec.rule_information6,
			p_rgd_code	=> p_rgr_rec.rgd_code,
			p_rdf_code	=> p_rgr_rec.rule_information_category,
			x_return_status	=> l_return_status);

		    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := l_return_status;
			END IF;
		    END IF;

	        END IF;
      --rkuttiya end;

	END IF;

	-- *******************************************************
	-- Quote Effectivity for Termination and Repurchase Quotes
	-- *******************************************************

	IF p_rgr_rec.rule_information_category = 'AMQTEF' THEN

		check_quote_effectivity (
			p_rule_info1	=> p_rgr_rec.rule_information1,
			p_rule_info2	=> p_rgr_rec.rule_information2,
			x_return_status	=> l_return_status);

	END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	x_return_status		:= l_overall_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END check_am_rule_format;


-- Start of comments
--
-- Procedure Name	: check_rule_constraints
-- Description		: Mandatory checks for values of contract rules used by AM
-- Business Rules	:
-- Parameters		: Contract Id
-- Version		: 1.0
-- End of comments

PROCEDURE check_rule_constraints (
	x_return_status		OUT NOCOPY VARCHAR2,
	p_chr_id		IN  NUMBER) IS

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_rule_constraints';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
    END IF;

	check_bill_to_address (
		x_return_status	=> l_return_status,
		p_chr_id	=> p_chr_id);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	check_create_quote (
		x_return_status	=> l_return_status,
		p_chr_id	=> p_chr_id);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	check_calculate_quote (
		x_return_status	=> l_return_status,
		p_chr_id	=> p_chr_id);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	check_repurch_quote_parties (
		x_return_status	=> l_return_status,
		p_chr_id	=> p_chr_id);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	check_sec_dep_disp (
		x_return_status	=> l_return_status,
		p_chr_id	=> p_chr_id);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	check_contract_portfolio (
		x_return_status	=> l_return_status,
		p_chr_id	=> p_chr_id);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	check_quote_wf (
		x_return_status	=> l_return_status,
		p_chr_id	=> p_chr_id);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	x_return_status		:= l_overall_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END check_rule_constraints;


-- Start of comments
--
-- Procedure Name	: check_warning_constraints
-- Description		: Optional checks for values of contract rules used by AM
-- Business Rules	:
-- Parameters		: Contract Id
-- Version		: 1.0
-- End of comments

PROCEDURE check_warning_constraints (
	x_return_status		OUT NOCOPY VARCHAR2,
	p_chr_id		IN  NUMBER) IS

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_warning_constraints';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name,
G_LEVEL_STATEMENT);

BEGIN
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_chr_id: '||p_chr_id);
    END IF;

	check_termin_quote_parties (
		x_return_status	=> l_return_status,
		p_chr_id	=> p_chr_id);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	x_return_status		:= l_overall_status;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: ' || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END check_warning_constraints;


END okl_am_qa_data_integrity_pvt;

/
