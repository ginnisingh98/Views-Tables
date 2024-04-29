--------------------------------------------------------
--  DDL for Package Body OKL_AM_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_UTIL_PVT" AS
/* $Header: OKLRAMUB.pls 120.39.12010000.2 2008/09/09 21:36:35 rkuttiya ship $ */


  -- Global Private Variables and Types

  TYPE lenchk_rec_type  IS RECORD (
    VName                         VARCHAR2(30),
    CName                         VARCHAR2(30),
    CDType			              VARCHAR2(20),
    CLength                       number,
    CScale                        number);

  TYPE lenchk_tbl_type  IS TABLE OF lenchk_rec_type
    INDEX by BINARY_INTEGER;

  G_lenchk_tbl    lenchk_tbl_type;
  g_ptm_code      VARCHAR2(50);

-- Start of comments
--
-- Procedure Name	: get_rule_chr_id
-- Description		: Depending on Quote Type, returns contract_id
--			  of either Lease contract or its Program
-- Business Rules	:
-- Parameters		: quote header record
-- Version		: 1.0
-- End of comments

FUNCTION get_rule_chr_id (
		p_qtev_rec	IN qtev_rec_type)
		RETURN		NUMBER IS

	CURSOR	l_program_csr (cp_chr_id NUMBER) IS
		SELECT	h.khr_id
		FROM	okl_k_headers	h
		WHERE	h.id		= cp_chr_id;

	l_formula_chr_id	NUMBER;

BEGIN

	IF p_qtev_rec.qtp_code LIKE 'TER_RECOURSE%' THEN
		OPEN	l_program_csr (p_qtev_rec.khr_id);
		FETCH	l_program_csr INTO l_formula_chr_id;
		CLOSE	l_program_csr;
	ELSE
		l_formula_chr_id := p_qtev_rec.khr_id;
	END IF;

	RETURN	l_formula_chr_id;

EXCEPTION

	WHEN OTHERS THEN
		IF l_program_csr%ISOPEN THEN
	 		CLOSE l_program_csr;
		END IF;
		RETURN	NULL;

END get_rule_chr_id;


-- Start of comments
--
-- Procedure Name	: initialize_txn_rec
-- Description		: Initialize transaction record for IB calls
-- Business Rules	:
-- Parameters		: transaction record
-- Version		: 1.0
-- End of comments

-- Fulfillment Specific Subtypes

PROCEDURE initialize_txn_rec (
	px_txn_rec IN OUT NOCOPY csi_datastructures_pub.transaction_rec) IS
BEGIN

	px_txn_rec.transaction_id		:= NULL;
	px_txn_rec.transaction_date		:= SYSDATE;
	px_txn_rec.source_transaction_date	:= SYSDATE;
	px_txn_rec.transaction_type_id		:= 1;
	px_txn_rec.txn_sub_type_id		:= NULL;
	px_txn_rec.source_group_ref_id		:= NULL;
	px_txn_rec.source_group_ref		:= '';
	px_txn_rec.source_header_ref_id		:= NULL;
	px_txn_rec.source_header_ref		:= '';
	px_txn_rec.source_line_ref_id		:= NULL;
	px_txn_rec.source_line_ref		:= '';
	px_txn_rec.source_dist_ref_id1		:= NULL;
	px_txn_rec.source_dist_ref_id2		:= NULL;
	px_txn_rec.inv_material_transaction_id	:= NULL;
	px_txn_rec.transaction_quantity		:= NULL;
	px_txn_rec.transaction_uom_code		:= '';
	px_txn_rec.transacted_by		:= NULL;
	px_txn_rec.transaction_status_code	:= '';
	px_txn_rec.transaction_action_code	:= '';
	px_txn_rec.message_id			:= NULL;
	px_txn_rec.context			:= '';
	px_txn_rec.attribute1			:= '';
	px_txn_rec.attribute2			:= '';
	px_txn_rec.attribute3			:= '';
	px_txn_rec.attribute4			:= '';
	px_txn_rec.attribute5			:= '';
	px_txn_rec.attribute6			:= '';
	px_txn_rec.attribute7			:= '';
	px_txn_rec.attribute8			:= '';
	px_txn_rec.attribute9			:= '';
	px_txn_rec.attribute10			:= '';
	px_txn_rec.attribute11			:= '';
	px_txn_rec.attribute12			:= '';
	px_txn_rec.attribute13			:= '';
	px_txn_rec.attribute14			:= '';
	px_txn_rec.attribute15			:= '';
	px_txn_rec.object_version_number	:= NULL;
	px_txn_rec.split_reason_code		:= '';

END initialize_txn_rec;


-- Start of comments
--
-- Procedure Name	: get_okl_org_id
-- Description		: Return system org_id
-- Business Rules	:
-- Parameters		: none
-- Version		: 1.0
-- End of comments

FUNCTION get_okl_org_id RETURN NUMBER IS
BEGIN
	RETURN (okc_context.get_okc_org_id);
	-- the same as: RETURN (sys_context('OKC_CONTEXT','ORG_ID'));
END get_okl_org_id;


-- Start of comments
--
-- Procedure Name	: get_chr_org_id
-- Description		: Return contract org_id
-- Business Rules	:
-- Parameters		: contract id
-- Version		: 1.0
-- End of comments

FUNCTION get_chr_org_id (p_chr_id IN NUMBER) RETURN NUMBER IS

	-- Get contract org_id
	CURSOR l_chr_csr (cp_chr_id NUMBER) IS
		SELECT	h.authoring_org_id
		FROM	okc_k_headers_b h
		WHERE	h.id = cp_chr_id;

	l_result	okc_k_headers_b.authoring_org_id%TYPE;

BEGIN

	OPEN	l_chr_csr (p_chr_id);
	FETCH	l_chr_csr INTO l_result;
	CLOSE	l_chr_csr;

	RETURN	l_result;

EXCEPTION

	WHEN OTHERS THEN
		IF (l_chr_csr%ISOPEN) THEN
			CLOSE l_chr_csr;
		END IF;
		RETURN NULL;

END get_chr_org_id;


-- Start of comments
--
-- Procedure Name	: get_chr_currency
-- Description		: Return contract currency_code
-- Business Rules	:
-- Parameters		: contract id
-- Version		: 1.0
-- End of comments

FUNCTION get_chr_currency (p_chr_id IN NUMBER) RETURN VARCHAR2 IS

	-- Get contract org_id
	CURSOR l_chr_csr (cp_chr_id NUMBER) IS
		SELECT	h.currency_code
		FROM	okc_k_headers_b h
		WHERE	h.id = cp_chr_id;

	l_result	okc_k_headers_b.currency_code%TYPE;

BEGIN

	OPEN	l_chr_csr (p_chr_id);
	FETCH	l_chr_csr INTO l_result;
	CLOSE	l_chr_csr;

	RETURN	l_result;

EXCEPTION

	WHEN OTHERS THEN
		IF (l_chr_csr%ISOPEN) THEN
			CLOSE l_chr_csr;
		END IF;
		RETURN NULL;

END get_chr_currency;


-- Start of comments
--
-- Procedure Name	: get_asset_quantity
-- Description		: Return asset quantity
-- Business Rules	:
-- Parameters		: contract line id
-- Version		: 1.0
-- End of comments

FUNCTION get_asset_quantity (p_cle_id IN NUMBER) RETURN NUMBER IS

	-- Get asset quantity
	CURSOR l_quantity_csr (cp_cle_id NUMBER) IS
		SELECT	cim.number_of_items	asset_quantity
		FROM	okc_k_lines_b		cle,
			okc_line_styles_b	lse,
			okc_k_items		cim
		WHERE	cle.cle_id		= cp_cle_id
		AND	lse.id			= cle.lse_id
		AND	lse.lty_code		= 'ITEM'
		AND	cim.cle_id		= cle.id;

	l_result	okc_k_items.number_of_items%TYPE	:= NULL;

BEGIN

	OPEN	l_quantity_csr (p_cle_id);
	FETCH	l_quantity_csr INTO l_result;
	CLOSE	l_quantity_csr;

	RETURN	l_result;

EXCEPTION

	WHEN OTHERS THEN
		IF (l_quantity_csr%ISOPEN) THEN
			CLOSE l_quantity_csr;
		END IF;
		RETURN NULL;

END get_asset_quantity;


-- Start of comments
--
-- Procedure Name	: get_currency_info
-- Description		: Gets information about currency
-- Business Rules	:
-- Parameters		: currency code
-- Version		: 1.0
-- End of comments

PROCEDURE get_currency_info (
	p_currency_code		IN VARCHAR2,
	x_precision		OUT NOCOPY NUMBER,
	x_min_acc_unit		OUT NOCOPY NUMBER) IS

	-- Get currency attributes
	CURSOR l_curr_csr (cp_currency_code VARCHAR2) IS
		SELECT	c.minimum_accountable_unit, c.precision
		FROM	fnd_currencies c
		WHERE	c.currency_code = cp_currency_code;

BEGIN

	OPEN	l_curr_csr (p_currency_code);
	FETCH	l_curr_csr INTO x_min_acc_unit, x_precision;
	CLOSE	l_curr_csr;

EXCEPTION

	WHEN OTHERS THEN
		IF (l_curr_csr%ISOPEN) THEN
			CLOSE l_curr_csr;
		END IF;
		x_precision	:= NULL;
		x_min_acc_unit	:= NULL;

END get_currency_info;


-- Start of comments
--
-- Procedure Name	: get_ak_attribute
-- Description		: Returns attribute label
-- Business Rules	:
-- Parameters		: attribute code
-- Version		: 1.0
-- End of comments

FUNCTION get_ak_attribute (
	p_code		IN VARCHAR2)
	RETURN		VARCHAR2 IS

	l_attr_label	ak_attributes_vl.attribute_label_long%TYPE := NULL;

	CURSOR l_attribute_csr (cp_code VARCHAR2) IS
		SELECT	attribute_label_long
		FROM	ak_attributes_vl	attr
		WHERE	attr.attribute_application_id	= 540
		AND	attr.attribute_code		= cp_code;

BEGIN

	OPEN	l_attribute_csr (p_code);
	FETCH	l_attribute_csr INTO l_attr_label;
	CLOSE	l_attribute_csr;

	RETURN (l_attr_label);

EXCEPTION

	WHEN OTHERS THEN

		IF l_attribute_csr%ISOPEN THEN
			CLOSE l_attribute_csr;
		END IF;

		RETURN (NULL);

END get_ak_attribute;


-- Start of comments
--
-- Procedure Name	: get_trx_msgs_yn
-- Description		: Indicates if any messages exist
-- Business Rules	:
-- Parameters		: Source table name, source id
-- Version		: 1.0
-- End of comments

FUNCTION get_trx_msgs_yn (
	p_trx_table	IN VARCHAR2,
	p_trx_id	IN NUMBER)
	RETURN		VARCHAR2 IS

	l_msg_count	NUMBER := 0;
	l_result	VARCHAR2(1);

	CURSOR l_messages_csr (cp_trx_table VARCHAR2, cp_trx_id NUMBER) IS
		SELECT	count (*)
		FROM	okl_trx_msgs		m
		WHERE	m.trx_source_table	= cp_trx_table
		AND	m.trx_id		= cp_trx_id;

BEGIN

	OPEN	l_messages_csr (p_trx_table, p_trx_id);
	FETCH	l_messages_csr INTO l_msg_count;
	CLOSE	l_messages_csr;

	IF l_msg_count = 0 THEN
		l_result := 'N';
	ELSE
		l_result := 'Y';
	END IF;

	RETURN (l_result);

EXCEPTION

	WHEN OTHERS THEN

		IF l_messages_csr%ISOPEN THEN
			CLOSE l_messages_csr;
		END IF;

		RETURN (NULL);

END get_trx_msgs_yn;


-- Start of comments
--
-- Procedure Name	: get_quote_amount
-- Description		: Return quote amount : Modified to get tax amount from tax entity, and original quote amount excluding tax lines
-- Business Rules	:
-- Parameters		: Quote id
-- Version		: 1.0
-- End of comments

FUNCTION get_quote_amount (
	p_quote_id	IN NUMBER)
	RETURN		NUMBER IS

	l_result	NUMBER := 0;

	CURSOR l_q_lines_csr (cp_quote_id NUMBER) IS
		SELECT	sum (nvl (l.amount,0))
		FROM	okl_txl_qte_lines_all_b	l
		WHERE	l.qte_id		= cp_quote_id
		AND     l.qlt_code <> 'AMCTAX'; -- rmunjulu sales_tax_enhancement exclude tax line as tax is coming from tax entities

    -- rmunjulu sales_tax_enhancement
    l_tax_amount NUMBER;

BEGIN

	OPEN	l_q_lines_csr (p_quote_id);
	FETCH	l_q_lines_csr INTO l_result;
	CLOSE	l_q_lines_csr;

    -- rmunjulu sales_tax_enhancement Get the tax amount
    l_tax_amount := get_tax_amount (p_quote_id);

    -- rmunjulu sales_tax_enhancement
    l_result := nvl(l_result,0) + nvl(l_tax_amount,0);

	RETURN (NVL (l_result, 0));

EXCEPTION

	WHEN OTHERS THEN

		IF l_q_lines_csr%ISOPEN THEN
			CLOSE l_q_lines_csr;
		END IF;

		RETURN (0);

END get_quote_amount;


-- Start of comments
--
-- Procedure Name	: get_lookup_meaning
-- Description		: Returns lookup meaning
-- Business Rules	:
-- Parameters		: lookup type, lookup code, validate flag
-- Version		: 1.0
-- End of comments

FUNCTION get_lookup_meaning (
	p_lookup_type	IN VARCHAR2,
	p_lookup_code	IN VARCHAR2,
	p_validate_yn	IN VARCHAR2)
	RETURN		VARCHAR2 IS

	l_lookup_rec	fnd_lookups%ROWTYPE;
	l_meaning	fnd_lookups.meaning%TYPE := NULL;
	l_sysdate	DATE := SYSDATE ;

	CURSOR l_lookup_csr
			(cp_lookup_type		VARCHAR2,
			cp_lookup_code		VARCHAR2) IS
		SELECT	*
		FROM	fnd_lookups		fndlup
		WHERE	fndlup.lookup_type	= cp_lookup_type
		AND	fndlup.lookup_code	= cp_lookup_code;

BEGIN

	OPEN	l_lookup_csr (p_lookup_type, p_lookup_code);
	FETCH	l_lookup_csr INTO l_lookup_rec;
	CLOSE	l_lookup_csr;

	l_meaning := l_lookup_rec.meaning;

	IF p_validate_yn = 'Y' AND l_meaning IS NOT NULL THEN
		IF l_lookup_rec.enabled_flag = 'N'
		OR l_sysdate < NVL (l_lookup_rec.start_date_active, l_sysdate)
		OR l_sysdate > NVL (l_lookup_rec.end_date_active,   l_sysdate)
		THEN
			l_meaning := NULL;
		END IF;
	END IF;

	RETURN (l_meaning);

EXCEPTION

	WHEN OTHERS THEN

		IF l_lookup_csr%ISOPEN THEN
			CLOSE l_lookup_csr;
		END IF;

		RETURN (NULL);

END get_lookup_meaning;


-- Start of comments
--
-- Procedure Name	: set_token
-- Description		: Return full description for message tokens
-- Business Rules	:
-- Parameters		: token type, token value
-- Version		    : 1.0
-- History          : 07-FEB-03 DAPATEL 115.47 2780466 - Modified message token
--                    value when a message for no operand value is set by create
--                    quote.
-- End of comments

FUNCTION set_token (
	p_token1_type		IN VARCHAR2,
	p_token1_value		IN VARCHAR2,
	p_token2_type		IN VARCHAR2,
	p_token2_value		IN VARCHAR2,
	p_token2_new_value	IN VARCHAR2)
	RETURN			VARCHAR2 IS

	-- Get operand description
	CURSOR l_operand_csr
		(cp_formula_name VARCHAR2
		,cp_operand_name VARCHAR2) IS
		SELECT	o.description
		FROM	okl_formulae_v		f,
			okl_fmla_oprnds_v	fo,
			okl_operands_v		o
		WHERE	f.name		= cp_formula_name
		AND	f.start_date		  <= SYSDATE
		AND	NVL (f.end_date, SYSDATE) >= SYSDATE
		AND	fo.fma_id	= f.id
		AND	fo.label	= cp_operand_name
		AND	o.id		= fo.opd_id;

	-- Get rule description
	CURSOR l_rule_csr (cp_rule_code VARCHAR2) IS
		SELECT	rd.meaning
		FROM	okc_rule_defs_v		rd
		WHERE	rd.application_id	= 540
		AND	rd.rule_code		= cp_rule_code;

	l_lookup_type		fnd_lookups.lookup_type%TYPE := NULL;
	l_token_value		fnd_lookups.description%TYPE := NULL;

BEGIN

	IF  p_token1_type  IS NOT NULL
	AND p_token1_value IS NOT NULL
	AND p_token2_type  IS NULL
	AND p_token2_value IS NULL THEN

		IF    p_token1_type = 'RULE' THEN
			OPEN	l_rule_csr (p_token1_value);
			FETCH	l_rule_csr INTO l_token_value;
			CLOSE	l_rule_csr;
		ELSIF p_token1_type = 'GROUP' THEN
			l_lookup_type	:= 'OKC_RULE_GROUP_DEF';
		ELSIF p_token1_type = 'QLT_CODE' THEN
			l_lookup_type	:= 'OKL_QUOTE_LINE_TYPE';
		ELSIF p_token1_type = 'QTP_CODE' THEN
			l_lookup_type	:= 'OKL_QUOTE_TYPE';
		ELSIF p_token1_type = 'QUOTE_PARTY_TYPE' THEN
			l_lookup_type	:= 'OKL_QUOTE_PARTY_TYPE';
		ELSIF p_token1_type = 'FORMULA' THEN
			l_token_value	:= p_token1_value;
		END IF;

		IF l_lookup_type IS NOT NULL THEN
			l_token_value := get_lookup_meaning
				(l_lookup_type, p_token1_value, 'N');
		END IF;

        --2780466 - Commented out
--		IF l_token_value IS NOT NULL THEN
--			l_token_value := '"' || l_token_value || '"';
--		END IF;

		l_token_value	:= NVL (l_token_value, p_token1_value);

	END IF;

	IF  p_token1_type  IS NOT NULL
	AND p_token1_value IS NOT NULL
	AND p_token2_type  IS NOT NULL
	AND p_token2_value IS NOT NULL THEN

		IF  p_token1_type = 'FORMULA'
		AND p_token2_type = 'OPERAND' THEN

--			OPEN	l_operand_csr (p_token1_value, p_token2_value);
--			FETCH	l_operand_csr INTO l_token_value;
--			CLOSE	l_operand_csr;

            --2780466 - Modified message token to display rule value for operand
			OPEN	l_rule_csr (p_token2_value);
			FETCH	l_rule_csr INTO l_token_value;
			CLOSE	l_rule_csr;

            --2780466 - Commented out
			--l_token_value := p_token2_new_value;

            --2780466 - Commented out
--			IF l_token_value IS NOT NULL THEN
--				l_token_value := '"' || l_token_value || '"';
--			END IF;

		END IF;

		l_token_value	:= NVL (l_token_value, p_token2_new_value);

	END IF;
/*
	IF  l_token_value IS NOT NULL
	AND l_token_value NOT LIKE '"%"' THEN
		l_token_value	:= '"' || l_token_value || '"';
	END IF;
*/
	RETURN	l_token_value;

EXCEPTION

	WHEN OTHERS THEN

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		IF (l_operand_csr%ISOPEN) THEN
			CLOSE l_operand_csr;
		END IF;

		IF (l_rule_csr%ISOPEN) THEN
			CLOSE l_rule_csr;
		END IF;

		RETURN NVL (p_token2_new_value, p_token1_value);

END set_token;


-- Start of comments
--
-- Procedure Name	: get_transaction_id
-- Description		: Gets transaction type id for transaction name
-- Business Rules	:
-- Parameters		: transaction name
-- Version		: 1.0
-- End of comments

PROCEDURE get_transaction_id (
	p_try_name		IN VARCHAR2,
	p_language		IN VARCHAR2 DEFAULT 'US',
	x_return_status		OUT NOCOPY VARCHAR2,
	x_try_id		OUT NOCOPY NUMBER) IS

	 -- Cursor to get the try_id for the name passed
	 CURSOR l_try_id_csr (
			cp_try_name	IN VARCHAR2,
			cp_language	IN VARCHAR2) IS
	 	SELECT	id
	 	FROM	okl_trx_types_tl t
	 	WHERE   Upper (t.name)	LIKE Upper (cp_try_name)
		AND	t.language	= Upper (cp_language);

	l_return_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_try_id	NUMBER		:= NULL;

BEGIN

	-- Get the try_id for the name passed
	OPEN	l_try_id_csr (p_try_name, p_language);
	FETCH	l_try_id_csr INTO l_try_id;
	IF l_try_id_csr%NOTFOUND THEN
		l_return_status := OKL_API.G_RET_STS_ERROR;
	END IF;
	CLOSE	l_try_id_csr;

	x_return_status	:= l_return_status;
	x_try_id	:= l_try_id;

EXCEPTION

	WHEN OTHERS THEN

		IF l_try_id_csr%ISOPEN THEN
	 		CLOSE l_try_id_csr;
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

END get_transaction_id;


-- Start of comments
--
-- Procedure Name	: get_stream_type_id
-- Description		: Gets stream type id for stream type code
-- Business Rules	:
-- Parameters		: transaction name
-- Version		: 1.0
-- End of comments

PROCEDURE get_stream_type_id (
	p_sty_code		IN VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_sty_id		OUT NOCOPY NUMBER) IS

	 -- Cursor to get the sty_id for the code passed
	 CURSOR l_sty_id_csr (cp_sty_code IN VARCHAR2) IS
	 	SELECT	id
	 	FROM	okl_strm_type_b	s
	 	WHERE   s.code		= cp_sty_code;

	l_return_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_sty_id	NUMBER		:= NULL;

BEGIN

	-- Get the sty_id for the code passed
	OPEN	l_sty_id_csr (p_sty_code);
	FETCH	l_sty_id_csr INTO l_sty_id;
	IF l_sty_id_csr%NOTFOUND THEN
		l_return_status := OKL_API.G_RET_STS_ERROR;
	END IF;
	CLOSE	l_sty_id_csr;

	x_return_status	:= l_return_status;
	x_sty_id	:= l_sty_id;

EXCEPTION

	WHEN OTHERS THEN

		IF l_sty_id_csr%ISOPEN THEN
	 		CLOSE l_sty_id_csr;
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

END get_stream_type_id;


-- Start of comments
--
-- Procedure Name	: set_message
-- Description		: Put messages on stack
-- Business Rules	:
-- Parameters		: application, message name, tokens
-- Version		: 1.0
-- End of comments

PROCEDURE set_message (
	p_app_name		IN VARCHAR2,
	p_msg_name		IN VARCHAR2,
	p_msg_level		IN NUMBER,
	p_token1		IN VARCHAR2,
	p_token1_value		IN VARCHAR2,
	p_token2		IN VARCHAR2,
	p_token2_value		IN VARCHAR2,
	p_token3		IN VARCHAR2,
	p_token3_value		IN VARCHAR2,
	p_token4		IN VARCHAR2,
	p_token4_value		IN VARCHAR2,
	p_token5		IN VARCHAR2,
	p_token5_value		IN VARCHAR2,
	p_token6		IN VARCHAR2,
	p_token6_value		IN VARCHAR2,
	p_token7		IN VARCHAR2,
	p_token7_value		IN VARCHAR2,
	p_token8		IN VARCHAR2,
	p_token8_value		IN VARCHAR2,
	p_token9		IN VARCHAR2,
	p_token9_value		IN VARCHAR2,
	p_token10		IN VARCHAR2,
	p_token10_value		IN VARCHAR2) IS

	l_token1_value		VARCHAR2(256);
	l_token2_value		VARCHAR2(256);
	l_token3_value		VARCHAR2(256);
	l_token4_value		VARCHAR2(256);
	l_token5_value		VARCHAR2(256);
	l_token6_value		VARCHAR2(256);
	l_token7_value		VARCHAR2(256);
	l_token8_value		VARCHAR2(256);
	l_token9_value		VARCHAR2(256);
	l_token10_value		VARCHAR2(256);

BEGIN

    IF fnd_msg_pub.check_msg_level (p_msg_level) THEN

	-- ************************
	-- Check independent tokens
	-- ************************

	l_token1_value	:= set_token (p_token1, p_token1_value);
	l_token2_value	:= set_token (p_token2, p_token2_value);
	l_token3_value	:= set_token (p_token3, p_token3_value);
	l_token4_value	:= set_token (p_token4, p_token4_value);
	l_token5_value	:= set_token (p_token5, p_token5_value);
	l_token6_value	:= set_token (p_token6, p_token6_value);
	l_token7_value	:= set_token (p_token7, p_token7_value);
	l_token8_value	:= set_token (p_token8, p_token8_value);
	l_token9_value	:= set_token (p_token9, p_token9_value);
	l_token10_value	:= set_token (p_token10, p_token10_value);

	-- ************************************
	-- Check tokens which have parent token
	-- ************************************

	l_token2_value	:= set_token
	  (p_token1, p_token1_value, p_token2, p_token2_value, l_token2_value);
	l_token4_value	:= set_token
	  (p_token3, p_token3_value, p_token4, p_token4_value, l_token4_value);
	l_token6_value	:= set_token
	  (p_token5, p_token5_value, p_token6, p_token6_value, l_token6_value);
	l_token8_value	:= set_token
	  (p_token7, p_token7_value, p_token8, p_token8_value, l_token8_value);
	l_token10_value	:= set_token
	  (p_token9, p_token9_value, p_token10, p_token10_value, l_token10_value);

	-- **************
	-- Create message
	-- **************

	OKL_API.SET_MESSAGE(
		 p_app_name	=> p_app_name
		,p_msg_name	=> p_msg_name
		,p_token1	=> p_token1
		,p_token1_value	=> l_token1_value
		,p_token2	=> p_token2
		,p_token2_value	=> l_token2_value
		,p_token3	=> p_token3
		,p_token3_value	=> l_token3_value
		,p_token4	=> p_token4
		,p_token4_value	=> l_token4_value
		,p_token5	=> p_token5
		,p_token5_value	=> l_token5_value
		,p_token6	=> p_token6
		,p_token6_value	=> l_token6_value
		,p_token7	=> p_token7
		,p_token7_value	=> l_token7_value
		,p_token8	=> p_token8
		,p_token8_value	=> l_token8_value
		,p_token9	=> p_token9
		,p_token9_value	=> l_token9_value
		,p_token10	=> p_token10
		,p_token10_value => l_token10_value);

    END IF;

EXCEPTION

	WHEN OTHERS THEN

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

END set_message;


-- Start of comments
--
-- Procedure Name	: set_invalid_rule_message
-- Description		: Add message indicating invalid rule setup
-- Business Rules	:
-- Parameters		: contract, contract line, rule group, rule code
-- Version		: 1.0
-- End of comments

PROCEDURE set_invalid_rule_message (
		p_rgd_code	IN VARCHAR2,
		p_rdf_code	IN VARCHAR2) IS

	-- Get rule description
	CURSOR l_rule_csr (cp_rule_code VARCHAR2) IS
		SELECT	rd.meaning
		FROM	okc_rule_defs_v		rd
		WHERE	rd.application_id	= 540
		AND	rd.rule_code		= cp_rule_code;

	l_rule_meaning		okc_rule_defs_v.meaning%TYPE;
	l_group_meaning		fnd_lookups.meaning%TYPE;
	l_label_value		VARCHAR2(2000)	:= NULL;

BEGIN

	l_label_value	:= get_ak_attribute ('OKL_' || p_rgd_code || '-' || p_rdf_code);

	IF l_label_value IS NULL THEN
		l_label_value	:= get_ak_attribute ('OKL_' || p_rgd_code);
	END IF;

	IF l_label_value IS NULL THEN

		OPEN	l_rule_csr (p_rdf_code);
		FETCH	l_rule_csr INTO l_rule_meaning;
		CLOSE	l_rule_csr;

		l_group_meaning := get_lookup_meaning ('OKC_RULE_GROUP_DEF', p_rgd_code, 'N');

		l_label_value	:= l_group_meaning || ' - ' || l_rule_meaning;

	END IF;

	OKL_API.SET_MESSAGE (
		 p_app_name	=> G_APP_NAME
		,p_msg_name	=> 'OKL_AM_INVALID_RULE_SETUP'
		,p_token1	=> 'LABEL'
		,p_token1_value	=> l_label_value);

EXCEPTION

	WHEN OTHERS THEN

		IF (l_rule_csr%ISOPEN) THEN
			CLOSE l_rule_csr;
		END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

END set_invalid_rule_message;


-- Start of comments
--
-- Procedure Name	: get_rule_record
-- Description		: Get rule information for a rule
-- Business Rules	:
-- Parameters		: contract, contract line, rule group, rule code
-- Version		: 1.0
-- End of comments

PROCEDURE get_rule_record (
		p_rgd_code	IN VARCHAR2,
		p_rdf_code	IN VARCHAR2,
		p_chr_id	IN NUMBER,
		p_cle_id	IN NUMBER,
		p_rgd_id	IN NUMBER,
		p_message_yn	IN BOOLEAN,
		x_rulv_rec	OUT NOCOPY okl_rule_pub.rulv_rec_type,
		x_return_status	OUT NOCOPY VARCHAR2) IS

	l_rgpv_tbl		okl_rule_pub.rgpv_tbl_type;
	l_rulv_tbl		okl_rule_pub.rulv_tbl_type;

	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;

	l_api_version		CONSTANT NUMBER	:= g_api_version;
	l_msg_count		NUMBER		:= OKL_API.G_MISS_NUM;
	l_msg_data		VARCHAR2(2000);

	l_rg_count		NUMBER;
	l_rule_count		NUMBER;

	l_no_rule_data		EXCEPTION;

        --gboomina Bug 4734134 - Added - to get SCS_CODE - Start
	l_msg_name              VARCHAR2(30);
	l_scs_code              okc_k_headers_b.scs_code%type;
        -- cursor to get scs_code
        CURSOR scs_code_csr IS
          SELECT scs_code
          FROM okc_k_headers_b
          WHERE id = p_chr_id;
        --gboomina Bug 4734134 - End
BEGIN

	-- *****************
	-- Get Rule Category
	-- *****************

	IF p_rgd_id IS NOT NULL THEN

		l_rgpv_tbl(1).id := p_rgd_id;

	ELSE

		okl_rule_apis_pub.get_contract_rgs (
			p_api_version	=> l_api_version,
			p_init_msg_list	=> OKL_API.G_FALSE,
			p_chr_id	=> p_chr_id,
			p_cle_id	=> p_cle_id,
			p_rgd_code	=> p_rgd_code,
			x_return_status	=> l_return_status,
			x_msg_count	=> l_msg_count,
			x_msg_data	=> l_msg_data,
			x_rgpv_tbl	=> l_rgpv_tbl,
			x_rg_count	=> l_rg_count);

		IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
			RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
			RAISE OKL_API.G_EXCEPTION_ERROR;
		ELSIF (NVL (l_rg_count, 0) <> 1) THEN
			RAISE l_no_rule_data;
		END IF;

	END IF;

	-- ***************
	-- Get Rule Record
	-- ***************

	okl_rule_apis_pub.get_contract_rules (
			p_api_version	=> l_api_version,
			p_init_msg_list	=> OKL_API.G_FALSE,
			p_rgpv_rec	=> l_rgpv_tbl(1),
			p_rdf_code	=> p_rdf_code,
			x_return_status	=> l_return_status,
			x_msg_count	=> l_msg_count,
			x_msg_data	=> l_msg_data,
			x_rulv_tbl	=> l_rulv_tbl,
			x_rule_count	=> l_rule_count);

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	ELSIF (NVL (l_rule_count, 0) <> 1) THEN
		RAISE l_no_rule_data;
	END IF;

	x_rulv_rec	:= l_rulv_tbl(1);
	x_return_status	:= l_overall_status;

 EXCEPTION

   WHEN l_no_rule_data THEN
     IF p_message_yn THEN
       -- Unable to complete process due to missing
       -- information (RULE rule in GROUP group)

       --gboomina Bug 4734134 - Changing the Error msg appropriate to
       -- Contract and Vendor Program based on SCS_CODE - Start

       -- get scs_code
       FOR x IN scs_code_csr
       LOOP
         l_scs_code := x.scs_code;
       END LOOP;

       IF l_scs_code = 'PROGRAM' THEN
         l_msg_name	:= 'OKL_AM_NO_VP_RULE_DATA';
       ELSE
         l_msg_name	:= 'OKL_AM_NO_RULE_DATA' ;
       END IF;

       set_message (
         p_app_name	=> G_APP_NAME
        ,p_msg_name	=> l_msg_name
        ,p_token1	=> 'GROUP'
        ,p_token1_value	=> p_rgd_code
        ,p_token2	=> 'RULE'
        ,p_token2_value	=> p_rdf_code);
                   --gboomina Bug 4734134 - End
     END IF;

     x_return_status := OKL_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

     -- error message will come from called APIs
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_rule_record;


-- Start of comments
--
-- Procedure Name	: get_rule_record
-- Description		: Get rule information for a rule and return the message stack
-- Business Rules	:
-- Parameters		: contract, contract line, rule group, rule code
-- Version		: 1.0
-- End of comments

PROCEDURE get_rule_record (
		p_rgd_code	IN VARCHAR2,
		p_rdf_code	IN VARCHAR2,
		p_chr_id	IN NUMBER,
		p_cle_id	IN NUMBER,
		p_message_yn	IN BOOLEAN,
		x_rulv_rec	OUT NOCOPY okl_rule_pub.rulv_rec_type,
		x_return_status	OUT NOCOPY VARCHAR2,
		x_msg_count	OUT NOCOPY VARCHAR2,
		x_msg_data	OUT NOCOPY VARCHAR2) IS

BEGIN

	get_rule_record (
		p_rgd_code	=> p_rgd_code,
		p_rdf_code	=> p_rdf_code,
		p_chr_id	=> p_chr_id,
		p_cle_id	=> p_cle_id,
		x_rulv_rec	=> x_rulv_rec,
		x_return_status	=> x_return_status,
		p_message_yn	=> p_message_yn);

	okc_api.end_activity (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);

EXCEPTION

	WHEN OTHERS THEN

		-- error message will come from called APIs
		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_rule_record;


-- Start of comments
--
-- Procedure Name	: get_bill_to_address
-- Description		: Return Bill_To address record for a contract
-- Business Rules	:
-- Parameters		: contract id
-- History          : RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
--                  : RMUNJULU 22-JAN-04 3394507 corrected cursor to get correct Bill To Address
--                    and pass it properly to the next cursor
-- Version		: 1.0
-- End of comments

PROCEDURE get_bill_to_address (
	p_contract_id		IN NUMBER,
	p_message_yn		IN BOOLEAN,
	x_bill_to_address_rec	OUT NOCOPY okx_cust_site_uses_v%ROWTYPE,
	x_return_status		OUT NOCOPY VARCHAR2) IS

    -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
    -- Get Bill to Values for LESSEE
    CURSOR l_bto_values_csr(p_chr_id IN NUMBER) IS
    SELECT CHR.bill_to_site_use_id, -- RMUNJULU 3394507 get bill to site id from K Header
           CPL.ROLE party_role,
           CPL.jtot_object1_code jtot_object1_code,
           CPL.object1_id1 object1_id1,
           CPL.object1_id2 object1_id2
    FROM   OKC_K_HEADERS_B CHR,
           OKC_K_PARTY_ROLES_V CPL
    WHERE  CHR.id = p_chr_id
    AND    CHR.id = CPL.chr_id
    AND    CPL.rle_code = 'LESSEE';


    -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
    -- Removed    cp_id2 from parameters and from WHERE
	-- Select bill_to record
	CURSOR l_bill_to_address_csr (cp_id1 NUMBER) IS
		SELECT *
		FROM   okx_cust_site_uses_v cst
		WHERE  cst.id1	= cp_id1;
--		AND    cst.id2	= cp_id2;

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_rulv_rec		okl_rule_pub.rulv_rec_type;
	l_bill_to_address_rec	okx_cust_site_uses_v%ROWTYPE;

    -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
    l_bto_values_rec l_bto_values_csr%ROWTYPE;
    l_party_name VARCHAR2(320);


BEGIN

/* -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
	get_rule_record (
		p_rgd_code	=> 'LABILL',
		p_rdf_code	=> 'BTO',
		p_chr_id	=> p_contract_id,
		p_cle_id	=> NULL,
		p_message_yn	=> TRUE,
		x_rulv_rec	=> l_rulv_rec,
		x_return_status	=> l_return_status);

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
*/

    -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
    -- Added code to get BTO values from table not rule
	OPEN 	l_bto_values_csr
		(p_contract_id);
	FETCH	l_bto_values_csr INTO l_bto_values_rec;

	IF l_bto_values_csr%NOTFOUND THEN

        -- Set the message
		OKL_API.set_message (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_INVALID_VALUE1
			,p_token1	=> 'COL_NAME'
			,p_token1_value	=> 'contract_id');

		l_return_status := OKL_API.G_RET_STS_ERROR;

    ELSIF l_bto_values_rec.bill_to_site_use_id IS NULL THEN

        -- Get party name
        l_party_name := get_jtf_object_name
			               (l_bto_values_rec.jtot_object1_code
			               ,l_bto_values_rec.object1_id1
			               ,l_bto_values_rec.object1_id2);
        -- Billing information is not found for party PARTY having role PARTY_ROLE.
        -- Set the message
        OKC_API.SET_MESSAGE (
				p_app_name	=> G_APP_NAME,
				p_msg_name	=> 'OKL_AM_NO_BILLING_INFO_NEW',
				p_token1	=> 'PARTY',
				p_token1_value	=> l_party_name,
				p_token2	=> 'PARTY_ROLE',
				p_token2_value	=> l_bto_values_rec.party_role);

		l_return_status := OKL_API.G_RET_STS_ERROR;
	END IF;

	CLOSE	l_bto_values_csr;

    -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
    -- Removed  l_rulv_rec.object1_id2 from passing to cursor
	OPEN 	l_bill_to_address_csr
		(l_bto_values_rec.bill_to_site_use_id); -- RMUNJULU 3394507 Pass the right bill to site id
	FETCH	l_bill_to_address_csr INTO l_bill_to_address_rec;

	IF (l_bill_to_address_csr%NOTFOUND) THEN
		l_return_status := Okl_Api.G_RET_STS_ERROR;
	END IF;

	CLOSE	l_bill_to_address_csr;

	x_return_status		:= l_return_status;
	x_bill_to_address_rec	:= l_bill_to_address_rec;

EXCEPTION

	WHEN OTHERS THEN

		IF l_bill_to_address_csr%ISOPEN THEN
	 		CLOSE l_bill_to_address_csr;
		END IF;

        -- RMUNJULU 29-AUG-03 OKC RULES MIGRATION changes
		IF l_bto_values_csr%ISOPEN THEN
	 		CLOSE l_bto_values_csr;
		END IF;

		IF p_message_yn THEN
		    -- store SQL error message on message stack for caller
		    OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);
		END IF;

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_bill_to_address;


-- Start of comments
--
-- Procedure Name	: get_formula_value
-- Description		: Request Formula Engine to execute a formula
-- Business Rules	:
-- Parameters		: formula_name, contract, contract line
-- Version		: 1.0
-- End of comments

PROCEDURE get_formula_value (
		p_formula_name	IN  OKL_FORMULAE_B.name%TYPE,
		p_chr_id	IN  OKC_K_HEADERS_B.id%TYPE,
		p_cle_id	IN  OKL_K_LINES.id%TYPE,
		p_additional_parameters IN
			okl_execute_formula_pub.ctxt_val_tbl_type,
		x_formula_value	OUT NOCOPY NUMBER,
		x_return_status	OUT NOCOPY VARCHAR2) IS

	l_api_version		CONSTANT NUMBER	:= g_api_version;
	l_msg_count		NUMBER		:= OKL_API.G_MISS_NUM;
	l_msg_data		VARCHAR2(2000);
	l_formula_value		NUMBER		:= 0;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;

BEGIN

         okl_execute_formula_pub.execute (
		p_api_version	=> l_api_version,
		p_init_msg_list	=> OKL_API.G_FALSE,
		x_return_status	=> l_return_status,
		x_msg_count	=> l_msg_count,
		x_msg_data	=> l_msg_data,
		p_formula_name	=> p_formula_name,
		p_contract_id	=> p_chr_id,
		p_line_id	=> p_cle_id,
		p_additional_parameters => p_additional_parameters,
		x_value		=> l_formula_value);

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	x_formula_value	:= l_formula_value;
	x_return_status	:= l_overall_status;

EXCEPTION

	WHEN OTHERS THEN

		-- error message will come from called APIs
		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_formula_value;


-- Start of comments
--
-- Procedure Name	: get_formula_string
-- Description		: Return formula string of a formula
--			  It can be used for validation - if NULL
--			  is returned, then a formula does not
--			  exist or can not be evaluated
-- Business Rules	:
-- Parameters		: formula name
-- Version		: 1.0
-- End of comments

FUNCTION get_formula_string (
	p_formula_name		IN VARCHAR2)
	RETURN			VARCHAR2 IS

	-- Extract evaluation string for a formula
	CURSOR l_formula_csr
		(cp_formula_name IN okl_formulae_v.name%TYPE) IS
		SELECT	f.formula_string
		FROM	okl_formulae_v f
		WHERE	f.name = cp_formula_name
		AND	f.start_date <= SYSDATE
		AND	NVL (f.end_date, sysdate) >= SYSDATE;

	l_formula_string	okl_formulae_v.formula_string%TYPE := NULL;

BEGIN

	OPEN	l_formula_csr (p_formula_name);
	FETCH	l_formula_csr INTO l_formula_string;
	CLOSE	l_formula_csr;

	RETURN	l_formula_string;

EXCEPTION

	WHEN OTHERS THEN

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		IF (l_formula_csr%ISOPEN) THEN
			CLOSE l_formula_csr;
		END IF;

		RETURN NULL;

END get_formula_string;


-- Start of comments
--
-- Procedure Name	: process_massages
-- Description		: Save messages from stack into
--			  transaction message table
-- Business Rules	:
-- Parameters		: source table name, referenced id
-- Version		: 1.0
-- End of comments

PROCEDURE process_messages(
	p_trx_source_table	IN OKL_TRX_MSGS.trx_source_table%TYPE,
	p_trx_id		IN OKL_TRX_MSGS.trx_id%TYPE,
	x_return_status		OUT NOCOPY VARCHAR2) IS

	px_error_rec		okl_api.error_rec_type;
	lp_tmgv_tbl		okl_trx_msgs_pub.tmgv_tbl_type;
	lx_tmgv_tbl		okl_trx_msgs_pub.tmgv_tbl_type;

	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;

	l_api_version		CONSTANT NUMBER	:= g_api_version;
	l_msg_count		NUMBER		:= OKL_API.G_MISS_NUM;
	l_msg_data		VARCHAR2(2000);

	l_seq			INTEGER := NVL(lp_tmgv_tbl.LAST, 0) + 1;
	last_msg_idx		INTEGER := FND_MSG_PUB.COUNT_MSG;
	l_msg_idx		INTEGER := FND_MSG_PUB.G_FIRST;

BEGIN

	-- ***************************
	-- Get messages from the stack
	-- ***************************

	LOOP

		fnd_msg_pub.get(
			p_msg_index     => l_msg_idx,
			p_encoded       => fnd_api.g_false,
			p_data          => px_error_rec.msg_data,
			p_msg_index_out => px_error_rec.msg_count);

		IF (px_error_rec.msg_count IS NOT NULL) THEN
		    lp_tmgv_tbl(l_seq).sequence_number	:= l_seq;
		    lp_tmgv_tbl(l_seq).message_text	:= px_error_rec.msg_data;
		    lp_tmgv_tbl(l_seq).trx_source_table	:= p_trx_source_table;
		    lp_tmgv_tbl(l_seq).trx_id		:= p_trx_id;
		END IF;

		EXIT WHEN ((px_error_rec.msg_count = last_msg_idx)
			OR (px_error_rec.msg_count IS NULL));

		l_msg_idx	:= FND_MSG_PUB.G_NEXT;
		l_seq		:= l_seq + 1;

	END LOOP;

	-- **************************
	-- Save messagess in TRX_MSGS
	-- **************************

	IF (lp_tmgv_tbl.COUNT > 0) THEN

		OKL_TRX_MSGS_PUB.insert_trx_msgs (
			p_api_version	=> l_api_version,
			p_init_msg_list	=> OKL_API.G_FALSE,
			x_return_status	=> l_return_status,
			x_msg_count	=> l_msg_count,
			x_msg_data	=> l_msg_data,
			p_tmgv_tbl	=> lp_tmgv_tbl,
			x_tmgv_tbl	=> lx_tmgv_tbl);

		IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
			RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
			RAISE OKL_API.G_EXCEPTION_ERROR;
		END IF;

	END IF;

	x_return_status	:= l_overall_status;

EXCEPTION

	WHEN OTHERS THEN
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

END process_messages;


-- Start of comments
--
-- Procedure Name	: get_object_details
-- Description		: Return details of JTF object
-- Business Rules	:
-- Parameters		: code, id1, id2, select columns, where clause
-- Version		: 1.0
-- End of comments

PROCEDURE get_object_details (
	p_object_code		IN VARCHAR2,
	p_object_id1		IN VARCHAR2,
	p_object_id2		IN VARCHAR2,
	p_check_status		IN VARCHAR2,
	p_other_select		IN select_tbl_type,
	p_other_where		IN where_tbl_type,
	x_object_tbl		OUT NOCOPY jtf_object_tbl_type,
	x_return_status		OUT NOCOPY VARCHAR2) IS

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_cnt			NUMBER := 0;

	TYPE			object_curs_type IS REF CURSOR;
	l_object_curs		object_curs_type;
	l_object_tbl		jtf_object_tbl_type;

	l_from_table		jtf_objects_b.from_table%TYPE;
	l_where_clause		jtf_objects_b.where_clause%TYPE;
	l_query_string		VARCHAR2(4000)	:= NULL;

	-- Get the Object definition parameters required to build the query
	CURSOR l_object_csr (cp_object_code IN VARCHAR2) IS
		SELECT	ob.from_table,
			ob.where_clause
		FROM	jtf_objects_b ob
		WHERE	ob.object_code = cp_object_code;

BEGIN

	IF p_object_id1 IS NULL AND p_other_where.COUNT = 0 THEN
		null; -- invalid parameters
	END IF;

	IF okl_context.get_okc_org_id IS NULL THEN
		 -- Read from profile
		okl_context.set_okc_org_context (NULL, NULL);
	END IF;

	OPEN	l_object_csr (p_object_code);
	FETCH	l_object_csr INTO l_from_table, l_where_clause;
	CLOSE	l_object_csr;

	l_query_string := l_query_string 	||
		'SELECT ''' ||	p_object_code	|| ''', '		||
				p_object_code	|| '.ID1, '		||
				p_object_code	|| '.ID2, '		||
				p_object_code	|| '.NAME, '		||
				p_object_code	|| '.DESCRIPTION, '	;

	IF p_other_select.COUNT > 0 THEN

	    FOR l_ind IN p_other_select.FIRST..p_other_select.LAST LOOP
		l_query_string :=  l_query_string ||
			' REPLACE ( '	||
				p_object_code || '.' || p_other_select (l_ind) ||
				', ''' || G_DELIM || ''',''' || G_DELIM || G_DELIM || ''') ' ||
			'|| ''' || G_DELIM || ''' ||';
	    END LOOP;
	    l_query_string := RTRIM (l_query_string, '|| ''' || G_DELIM || ''' ||');

	ELSE
	    l_query_string :=  l_query_string || 'NULL';
	END IF;

	l_query_string := l_query_string				||
		' FROM  '	||	l_from_table			||
		' WHERE ('	||	NVL (l_where_clause, '1=1')	|| ')';

	IF p_object_id1 IS NOT NULL THEN
            l_query_string := l_query_string        ||
                --Added by rajnisku 6669820
                ' AND '                || p_object_code || '.ID1 = :1'        ||
                --end rajnisku bug 6669820
                ' AND NVL ('        || p_object_code || '.ID2, ''#'') = '        ||
                     'NVL ('''  || p_object_id2  || ''',   ''#'')';


	ELSIF p_other_where.COUNT > 0 THEN
	    FOR l_ind IN p_other_where.FIRST..p_other_where.LAST LOOP
		l_query_string :=  l_query_string ||
			'AND '	|| p_object_code			||
			'.'	|| p_other_where(l_ind).column_name	||
			' '	|| p_other_where(l_ind).operation	||
			' '''	|| p_other_where(l_ind).condition_value	|| '''';
	    END LOOP;
	END IF;

	IF p_check_status = 'Y' THEN
	    l_query_string := l_query_string ||
		' AND NVL ('	|| p_object_code || '.STATUS, ''A'') = ''A''' ||
		' AND NVL ('	|| p_object_code || '.START_DATE_ACTIVE, SYSDATE) <= SYSDATE'	||
		' AND NVL ('	|| p_object_code || '.END_DATE_ACTIVE, SYSDATE) >= SYSDATE'	;
	END IF;
	 --Added by rajnisku for bug 6488267
        IF p_object_id1 IS NOT NULL THEN
           OPEN        l_object_curs FOR l_query_string USING p_object_id1;
           LOOP
              l_cnt        := l_cnt + 1;
              FETCH        l_object_curs INTO l_object_tbl(l_cnt);
              EXIT WHEN l_object_curs%NOTFOUND;
           END LOOP;
        ELSE
           OPEN        l_object_curs FOR l_query_string;
           LOOP
              l_cnt        := l_cnt + 1;
              FETCH        l_object_curs INTO l_object_tbl(l_cnt);
              EXIT WHEN l_object_curs%NOTFOUND;
           END LOOP;
        END IF;
        CLOSE l_object_curs;
        --end rajnisku for bug 6669820

/* -- rmunjulu 6902328 - do not need this piece of code as it is taken care in the ELSE of above IF
Otherwise it is causing issue with the data fetched and Termination quote Send Quote WF - Validate Request fails

	OPEN	l_object_curs FOR l_query_string;
	LOOP
		l_cnt	:= l_cnt + 1;
		FETCH	l_object_curs INTO l_object_tbl(l_cnt);
		EXIT WHEN l_object_curs%NOTFOUND;
	END LOOP;
	CLOSE	l_object_curs;
*/

	x_object_tbl		:= l_object_tbl;
	x_return_status		:= l_return_status;

EXCEPTION

	WHEN OTHERS THEN

		-- error message will come from called APIs
		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_object_details;


-- Start of comments
--
-- Procedure Name	: get_jtf_object_name
-- Description		: Return Name of JTF Object
-- Business Rules	:
-- Parameters		: code, id1, id2
-- Version		: 1.0
-- End of comments

FUNCTION get_jtf_object_name (
	p_object_code	IN VARCHAR2,
	p_object_id1	IN VARCHAR2,
	p_object_id2	IN VARCHAR2)
	RETURN		VARCHAR2 IS

	l_object_tbl		jtf_object_tbl_type;
	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;

BEGIN

	get_object_details (
		p_object_code	=> p_object_code,
		p_object_id1	=> p_object_id1,
		p_object_id2	=> p_object_id2,
		x_object_tbl	=> l_object_tbl,
		x_return_status	=> l_return_status);

	IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
		RETURN	l_object_tbl(1).name;
	ELSE
		RETURN	NULL;
	END IF;

EXCEPTION

	WHEN OTHERS THEN

		RETURN NULL;

END get_jtf_object_name;


-- Start of comments
--
-- Procedure Name	: get_jtf_object_column
-- Description		: Return a value of a column in JTF Object
-- Business Rules	:
-- Parameters		: column, code, id1, id2
-- Version		: 1.0
-- End of comments

FUNCTION get_jtf_object_column (
	p_column	IN VARCHAR2,
	p_object_code	IN VARCHAR2,
	p_object_id1	IN VARCHAR2,
	p_object_id2	IN VARCHAR2)
	RETURN		VARCHAR2 IS

	l_object_tbl		jtf_object_tbl_type;
	l_other_cols		select_tbl_type;
	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;

BEGIN

	l_other_cols(1)	:= p_column;

	okl_am_util_pvt.get_object_details (
		p_object_code	=> p_object_code,
		p_object_id1	=> p_object_id1,
		p_object_id2	=> p_object_id2,
		p_other_select	=> l_other_cols,
		x_object_tbl	=> l_object_tbl,
		x_return_status	=> l_return_status);

	IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
		RETURN	l_object_tbl(1).other_values;
	ELSE
		RETURN	NULL;
	END IF;

EXCEPTION

	WHEN OTHERS THEN

		RETURN NULL;

END get_jtf_object_column;


-- Start of comments
--
-- Procedure Name	: get_rule_field_value
-- Description		: Return Name of JTF Object pointed by Contract Rule
-- Business Rules	:
-- Parameters		: Rule Group, Rule Code, Contract Id, Line Id, Object Type
-- Note			: Unable to use Rules APIs since this function is called
--			  from SQL. SQL does not allow SAVEPOINT.
-- Version		: 1.0
-- End of comments

FUNCTION get_rule_field_value (
	p_rgd_code	IN VARCHAR2,
	p_rdf_code	IN VARCHAR2,
	p_chr_id	IN NUMBER,
	p_cle_id	IN NUMBER,
	p_object_type	IN VARCHAR2)
	RETURN		VARCHAR2 IS

	-- Get rule
	CURSOR l_rule_csr (
			cp_rgd_code	IN VARCHAR2,
			cp_rdf_code	IN VARCHAR2,
			cp_dnz_chr_id	IN NUMBER,
			cp_chr_id	IN NUMBER,
			cp_cle_id	IN NUMBER) IS
		SELECT	rdf.object1_id1,
			rdf.object2_id1,
			rdf.object3_id1,
			rdf.object1_id2,
			rdf.object2_id2,
			rdf.object3_id2,
			rdf.jtot_object1_code,
			rdf.jtot_object2_code,
			rdf.jtot_object3_code
		FROM	okc_rule_groups_b		rgp,
			okc_rules_b			rdf
		WHERE	rgp.chr_id		= cp_chr_id
		AND	rgp.cle_id		= cp_cle_id
		AND	(cp_chr_id= -9999 or rgp.dnz_chr_id = cp_dnz_chr_id)
		AND	rgp.rgd_code			= cp_rgd_code
		AND	rdf.rgp_id			= rgp.id
		AND	rdf.rule_information_category	= cp_rdf_code;

	l_rule_rec		l_rule_csr%ROWTYPE;
	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;

	l_chr_id		NUMBER;
	l_cle_id		NUMBER;
	l_dnz_chr_id		NUMBER;

	l_object_code		VARCHAR2(30);
	l_object_id1		VARCHAR2(40);
	l_object_id2		VARCHAR2(200);

BEGIN

	IF    p_chr_id IS NULL AND p_cle_id IS NOT NULL THEN
		l_chr_id	:= -9999;
		l_cle_id	:= p_cle_id;
		l_dnz_chr_id	:= -9999;
	ELSIF p_chr_id IS NULL AND p_cle_id IS NULL THEN
		l_chr_id     := -9999;
		l_cle_id     := -9999;
		l_dnz_chr_id := -9999;
	ELSIF p_chr_id IS NOT NULL AND p_cle_id IS NULL THEN
		l_chr_id := p_chr_id;
		l_cle_id := -9999;
		l_dnz_chr_id := p_chr_id;
	ELSIF p_chr_id IS NOT NULL AND p_cle_id IS NOT NULL THEN
		l_chr_id     := -9999;
		l_cle_id     := p_cle_id;
		l_dnz_chr_id := p_chr_id;
	END IF;

	OPEN	l_rule_csr (p_rgd_code, p_rdf_code, l_dnz_chr_id, l_chr_id, l_cle_id);
	FETCH	l_rule_csr INTO l_rule_rec;
	IF l_rule_csr%NOTFOUND THEN
		l_return_status := OKL_API.G_RET_STS_ERROR;
	END IF;
	CLOSE	l_rule_csr;

	IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN

	    IF    p_object_type = 'OBJECT1' THEN
		l_object_code	:= l_rule_rec.jtot_object1_code;
		l_object_id1	:= l_rule_rec.object1_id1;
		l_object_id2	:= l_rule_rec.object1_id2;

	    ELSIF p_object_type = 'OBJECT2' THEN
		l_object_code	:= l_rule_rec.jtot_object2_code;
		l_object_id1	:= l_rule_rec.object2_id1;
		l_object_id2	:= l_rule_rec.object2_id2;

	    ELSIF p_object_type = 'OBJECT3' THEN
		l_object_code	:= l_rule_rec.jtot_object3_code;
		l_object_id1	:= l_rule_rec.object3_id1;
		l_object_id2	:= l_rule_rec.object3_id2;

	    ELSE
		l_return_status := OKL_API.G_RET_STS_ERROR;
	    END IF;

	END IF;

	IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
		RETURN get_jtf_object_name
			(l_object_code, l_object_id1, l_object_id2);
	ELSE
		RETURN	NULL;
	END IF;

EXCEPTION

	WHEN OTHERS THEN
		IF (l_rule_csr%ISOPEN) THEN
			CLOSE l_rule_csr;
		END IF;

END get_rule_field_value;


-- Start of comments
--
-- Procedure Name	: get_program_partner
-- Description		: Return contract program partner
-- Business Rules :
-- Parameters 		: contract id
-- Version		: 1.0
-- End of comments

FUNCTION get_program_partner (p_chr_id IN NUMBER) RETURN VARCHAR2 IS

	-- Get contract program partner
	CURSOR l_partner_csr (cp_chr_id NUMBER) IS
		SELECT	kpr.jtot_object1_code,
			kpr.object1_id1,
			kpr.object1_id2
		FROM	okl_k_headers		khr,
			okc_k_headers_b		par,
			okc_k_party_roles_b	kpr
		WHERE	khr.id		= cp_chr_id
		AND	par.id		= khr.khr_id
		AND	par.scs_code	= 'PROGRAM'
		AND	kpr.chr_id	= par.id
		AND	kpr.rle_code	= 'OKL_VENDOR'
		AND	kpr.object1_id1	IS NOT NULL;

	l_partner_rec	l_partner_csr%ROWTYPE;

BEGIN

	OPEN	l_partner_csr (p_chr_id);
	FETCH	l_partner_csr INTO l_partner_rec;
	CLOSE	l_partner_csr;

	RETURN	get_jtf_object_name
			(l_partner_rec.jtot_object1_code
			,l_partner_rec.object1_id1
			,l_partner_rec.object1_id2);

EXCEPTION

	WHEN OTHERS THEN
		IF (l_partner_csr%ISOPEN) THEN
			CLOSE l_partner_csr;
		END IF;
		RETURN NULL;

END get_program_partner;


-- Start Fulfillment Specific

------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	:get_content_id
-- Description		:Private Fulfillment Procedure, returns template content id
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of comments
------------------------------------------------------------------------------
  PROCEDURE get_content_id (
                        p_ptm_code      IN  VARCHAR2,
                        x_content_id    OUT NOCOPY NUMBER,
                        x_subject       OUT NOCOPY VARCHAR2,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2 ) IS

  --Changed the following cursor to query on the uv instead of
  --the _v because the Template for the particular org
  --should be picked up.
  --Changed by rvaduri for bug 3571668

  CURSOR c_content_csr(c_ptm_code  VARCHAR2) IS

    SELECT   opt.jtf_amv_item_id, opt.email_subject_line
    FROM     OKL_CS_PROCESS_TMPLTS_UV opt
    WHERE    opt.ptm_code = c_ptm_code
    AND      opt.start_date < sysdate
    AND      nvl(opt.end_date, sysdate+1) > sysdate;

  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_content_id      jtf_amv_items_vl.item_id%type;
  l_default_subject okl_process_tmplts_v.email_subject_line%type;

  BEGIN

    OPEN c_content_csr(p_ptm_code);
    FETCH c_content_csr INTO l_content_id,
                             l_default_subject;
    IF c_content_csr%NOTFOUND THEN

        OKL_API.set_message( p_app_name      => 'OKL',
                             p_msg_name      => 'OKL_AM_MISSING_PTM_CODE',
                             p_token1        => 'PTM_CODE',
                             p_token1_value  => get_lookup_meaning(p_lookup_type => 'OKL_PROCESSES',
                                                                   p_lookup_code => p_ptm_code));
      l_return_status := OKC_API.G_RET_STS_ERROR;

    END IF;
    CLOSE c_content_csr;

    x_return_status := l_return_status;
    x_content_id    := l_content_id;
    x_subject       := l_default_subject;

  EXCEPTION

    WHEN OTHERS THEN
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END get_content_id;

------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	:get_agent_details
-- Description		:Private Fulfillment Procedure, returns sender details
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of comments
------------------------------------------------------------------------------

  PROCEDURE get_agent_details( p_agent_id        IN NUMBER,
                               x_agent_id        OUT NOCOPY NUMBER,
                               x_email           OUT NOCOPY VARCHAR2,
                               x_server_id       OUT NOCOPY VARCHAR2,
                               x_return_status   OUT NOCOPY VARCHAR2,
                               x_msg_count       OUT NOCOPY NUMBER,
                               x_msg_data        OUT NOCOPY VARCHAR2  ) IS

  l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  CURSOR c_agent_csr (c_agent_id NUMBER) IS
    SELECT nvl(ppf.email_address , fu.email_address) email
    FROM   fnd_user fu,
           per_people_f ppf
    WHERE  fu.employee_id = ppf.person_id (+)
    AND    fu.user_id = c_agent_id;


  CURSOR c_server_csr(c_agent_id NUMBER, c_server_id NUMBER) IS
    -- Re-written cursor due to Bug 3375932
    SELECT server.server_name server_name
    FROM jtf_fm_group_fnd_user_v users
       , jtf_fm_group groups
       , jtf_fm_service server
    WHERE users.user_id = c_agent_id
    AND   users.group_id = groups.group_id
    AND   server.server_id = groups.server_id
    AND   server.server_id = c_server_id;


  CURSOR c_server_name_csr(c_server_id NUMBER) IS
    SELECT 	 server.server_name server_name
	FROM     jtf_fm_service  server
 	WHERE 	 server.server_id = c_server_id;

  l_agent_id   NUMBER;
  l_email      VARCHAR2(1000);
  l_server_id  NUMBER;
  l_server_name  VARCHAR2(50);

  l_user_name   VARCHAR2(100);
  l_user_desc   VARCHAR2(100);
  l_ptm_meaning VARCHAR2(250);

  BEGIN

    l_server_id := fnd_profile.value('OKL_FM_SERVER');
    l_email     := fnd_profile.value('OKL_EMAIL_IDENTITY');

     okl_am_wf.get_notification_agent(itemtype      =>'',
                                      itemkey       =>'',
                                      actid         =>NULL,
                                      funcmode      =>'',
                                      p_user_id     => p_agent_id,
                                      x_name        => l_user_name,
                                      x_description => l_user_desc);
    IF l_email IS NULL THEN

        OPEN c_agent_csr(p_agent_id);
        FETCH c_agent_csr INTO l_email;
        CLOSE c_agent_csr;

        IF l_email IS NULL THEN

            OKL_API.set_message( p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_FM_DEFAULT_ERROR',
                                 p_token1        => 'PTM_MEANING',
                                 p_token1_value  => get_lookup_meaning(p_lookup_type => 'OKL_PROCESSES',
                                                                       p_lookup_code => g_ptm_code
                                                                       )
                                );

            OKL_API.set_message( p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_FM_AGENT',
                                 p_token1        => 'USERNAME',
                                 p_token1_value  => l_user_name);

            l_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF l_server_id IS NULL THEN

        OKL_API.set_message( p_app_name      => 'OKL',
                             p_msg_name      => 'OKL_AM_FM_DEFAULT_ERROR',
                             p_token1        => 'PTM_MEANING',
                             p_token1_value  => get_lookup_meaning(p_lookup_type => 'OKL_PROCESSES',
                                                                   p_lookup_code => g_ptm_code
                                                                   )
                           );

        OKL_API.set_message( p_app_name      => 'OKL',
                             p_msg_name      => 'OKL_AM_FM_SERVER_NOT_FOUND');

        l_return_status := OKC_API.G_RET_STS_ERROR;

    ELSE

        OPEN c_server_csr(p_agent_id, l_server_id);
        FETCH c_server_csr INTO l_server_name;
        CLOSE c_server_csr;

        IF l_server_name IS NULL THEN  -- This agent is not associated to the server

            OKL_API.set_message( p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_FM_DEFAULT_ERROR',
                                 p_token1        => 'PTM_MEANING',
                                 p_token1_value  => get_lookup_meaning(p_lookup_type => 'OKL_PROCESSES',
                                                                       p_lookup_code => g_ptm_code
                                                                       )
                                );
	 	    OPEN  c_server_name_csr(l_server_id);
	        FETCH c_server_name_csr INTO l_server_name;
	        CLOSE c_server_name_csr;

            OKL_API.set_message( p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_FM_AGENT_NOT_FOUND',
                                 p_token1        => 'USERNAME',
                                 p_token1_value  => l_user_name,
                                 p_token2        => 'SERVER_NAME',
                                 p_token2_value  => l_server_name);

            l_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    x_return_status := l_return_status;
    x_agent_id      := p_agent_id;
    x_email         := l_email;
    x_server_id     := l_server_id;

  EXCEPTION

    WHEN OTHERS THEN

		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END get_agent_details;

------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	:get_recipient_details
-- Description		:Private Fulfillment Procedure, returns recipient details
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of comments
------------------------------------------------------------------------------

  PROCEDURE get_recipient_details (
                        p_recipient_id    IN  VARCHAR2,
                        p_recipient_type  IN  VARCHAR2,
                        p_expand_roles    IN  VARCHAR2,
                        x_email           OUT NOCOPY recipient_tbl,
                        x_return_status   OUT NOCOPY VARCHAR2,
                        x_msg_count       OUT NOCOPY NUMBER,
                        x_msg_data        OUT NOCOPY VARCHAR2 ) IS

  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_content_id      jtf_amv_items_vl.item_id%type;
  l_default_subject okl_process_tmplts_v.email_subject_line%type;

  l_email_tbl                recipient_tbl;
  l_party_object_tbl         okl_am_parties_pvt.party_object_tbl_type;
  i                          NUMBER := 0;
  j number;
  l_email  varchar2(300);
  BEGIN

    -- check expand roles, make sure we are not at contact level already
    --  IF p_expand_roles = 'N' and p_recipient_type NOT IN ('PC', 'VC');

    -- Get email addresses for recipients
    okl_am_parties_pvt.get_party_details (
                                        	p_id_code		    => p_recipient_type,
                                        	p_id_value		    => p_recipient_id,
                                           	x_party_object_tbl	=> l_party_object_tbl,
                                        	x_return_status		=> l_return_status);

    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

            OKL_API.set_message( p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_FM_DEFAULT_ERROR',
                                 p_token1        => 'PTM_MEANING',
                                 p_token1_value  => get_lookup_meaning(p_lookup_type => 'OKL_PROCESSES',
                                                                       p_lookup_code => g_ptm_code
                                                                       )
                                );

            OKL_API.set_message( p_app_name      => 'OKL',
                             p_msg_name      => 'OKL_AM_INVALID_RECIPIENT',
                             p_token1        => 'PARTY_TYPE',
                             p_token1_value  => p_recipient_type,
                             p_token2        => 'PARTY_ID',
                             p_token2_value  => p_recipient_id);

    ELSIF (l_party_object_tbl.COUNT > 0) THEN

      i := l_party_object_tbl.FIRST;
      LOOP

       l_email :=  nvl(l_party_object_tbl(i).pcp_email, l_party_object_tbl(i).c_email);

       IF l_email IS NOT NULL THEN

          l_email_tbl(i) := nvl(l_party_object_tbl(i).pcp_email, l_party_object_tbl(i).c_email);

       END IF;

       EXIT WHEN (i = l_party_object_tbl.LAST);
       i := l_party_object_tbl.NEXT(i);

      END LOOP;

    ELSE
        OKL_API.set_message( p_app_name      => 'OKL',
                             p_msg_name      => 'OKL_AM_FM_DEFAULT_ERROR',
                             p_token1        => 'PTM_MEANING',
                             p_token1_value  => get_lookup_meaning(p_lookup_type => 'OKL_PROCESSES',
                                                                   p_lookup_code => g_ptm_code
                                                                       )
                                );

        OKL_API.set_message( p_app_name      => 'OKL',
                             p_msg_name      => 'OKL_AM_INVALID_RECIPIENT',
                             p_token1        => 'PARTY_TYPE',
                             p_token1_value  => p_recipient_type,
                             p_token2        => 'PARTY_ID',
                             p_token2_value  => p_recipient_id);

      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    j := l_email_tbl.FIRST;

    IF  (j IS NOT NULL) AND (l_email_tbl(j) <> OKL_API.G_MISS_CHAR AND l_email_tbl(j) IS NOT NULL)  THEN

      x_email         := l_email_tbl;

    ELSE
      OKL_API.set_message( p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_AM_FM_DEFAULT_ERROR',
                           p_token1        => 'PTM_MEANING',
                           p_token1_value  => get_lookup_meaning(p_lookup_type => 'OKL_PROCESSES',
                                                                 p_lookup_code => g_ptm_code
                                                                 )
                          );

      OKL_API.set_message(   p_app_name      => 'OKL',
                             p_msg_name      => 'OKL_AM_INVALID_RECIPIENT',
                             p_token1        => 'PARTY_TYPE',
                             p_token1_value  => p_recipient_type,
                             p_token2        => 'PARTY_ID',
                             p_token2_value  => p_recipient_id);

      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OTHERS THEN

		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END get_recipient_details;

------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	:EXECUTE_FULFILLMENT_REQUEST
-- Description		:Public Fulfillment Procedure,calls okl fulfillment wrapper
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of comments
------------------------------------------------------------------------------
  PROCEDURE EXECUTE_FULFILLMENT_REQUEST (
      p_api_version                  IN  NUMBER
    , p_init_msg_list                IN  VARCHAR2
    , x_return_status                OUT NOCOPY VARCHAR2
    , x_msg_count                    OUT NOCOPY NUMBER
    , x_msg_data                     OUT NOCOPY VARCHAR2
    , p_ptm_code                     IN  VARCHAR2
    , p_agent_id                     IN  NUMBER
    , p_transaction_id               IN  NUMBER
    , p_recipient_type               IN  VARCHAR2
    , p_recipient_id                 IN  VARCHAR2
    , p_expand_roles                 IN  VARCHAR2
    , p_subject_line                 IN  VARCHAR2
    , p_sender_email                 IN  VARCHAR2
    , p_recipient_email              IN  VARCHAR2
    , p_pt_bind_names                IN p_bind_var_tbl
    , p_pt_bind_values               IN p_bind_val_tbl
    , p_pt_bind_types                IN p_bind_type_tbl
    ) IS

	l_api_version		     CONSTANT NUMBER	:= G_API_VERSION;
	l_msg_count		         NUMBER		        := OKL_API.G_MISS_NUM;
	l_msg_data		         VARCHAR2(8000);

    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_agent_id               NUMBER;
    l_content_id             NUMBER;
    l_default_subject        VARCHAR2(2000);
    l_default_sender         VARCHAR2(2000);
    l_agent_email            VARCHAR2(1000);
    l_recipient_email        recipient_tbl;
    l_loop_counter           NUMBER;


    l_bind_var_tbl           p_bind_var_tbl;
    l_bind_val_tbl           p_bind_val_tbl;
    l_bind_type_tbl          p_bind_type_tbl;
    l_request_id             NUMBER;
    l_email                  VARCHAR2(1000);
    l_server_id     		 NUMBER;
    l_api_name               CONSTANT VARCHAR2(300) := 'exe_ful_req';

    i number;
    j number;
    k number;
  BEGIN

    --Check API version, initialize message list and create savepoint.

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);



    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Check all mandatory parameters have been passed
    IF p_ptm_code IS NULL OR p_ptm_code = OKL_API.G_MISS_CHAR THEN
        OKC_API.SET_MESSAGE (
			 p_app_name	    => 'OKC'
			,p_msg_name 	=> OKC_API.G_REQUIRED_VALUE
			,p_token1	    => G_COL_NAME_TOKEN
			,p_token1_value	=> 'P_PTM_CODE');

        l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSE
		g_ptm_code := p_ptm_code;
    END IF;

    IF p_agent_id IS NULL OR p_agent_id = OKL_API.G_MISS_NUM THEN
        OKC_API.SET_MESSAGE (
			 p_app_name	    => 'OKC'
			,p_msg_name 	=> OKC_API.G_REQUIRED_VALUE
			,p_token1	    => G_COL_NAME_TOKEN
			,p_token1_value	=> 'P_AGENT_ID');

        l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

    -- check mandatory parameters for the call type made

    IF p_transaction_id IS NOT NULL AND p_transaction_id <> OKL_API.G_MISS_NUM THEN

        IF p_recipient_email IS NULL OR p_recipient_email = OKL_API.G_MISS_CHAR THEN

            IF p_recipient_type IS NULL OR p_recipient_type = OKL_API.G_MISS_CHAR THEN
                OKC_API.SET_MESSAGE (
    			    p_app_name	    => 'OKC'
    			    ,p_msg_name 	=> OKC_API.G_REQUIRED_VALUE
    			    ,p_token1	    => G_COL_NAME_TOKEN
    			    ,p_token1_value	=> 'P_RECIPIENT_TYPE');

                l_return_status := OKL_API.G_RET_STS_ERROR;
            END IF;

            IF p_recipient_id IS NULL OR p_recipient_id = OKL_API.G_MISS_CHAR THEN
                OKC_API.SET_MESSAGE (
    			    p_app_name	    => 'OKC'
    			    ,p_msg_name 	=> OKC_API.G_REQUIRED_VALUE
    			    ,p_token1	    => G_COL_NAME_TOKEN
    			    ,p_token1_value	=> 'P_RECIPIENT_ID');

                l_return_status := OKL_API.G_RET_STS_ERROR;
            END IF;
        END IF;
    ELSE -- Called from AM Send Fulfillment screen

        IF p_pt_bind_names.COUNT > 0 THEN

           IF p_pt_bind_names(p_pt_bind_names.FIRST) IS NULL OR p_pt_bind_names(p_pt_bind_names.FIRST)= OKL_API.G_MISS_CHAR THEN
                OKC_API.SET_MESSAGE (
    			    p_app_name	    => 'OKC'
    			    ,p_msg_name 	=> OKC_API.G_REQUIRED_VALUE
    			    ,p_token1	    => G_COL_NAME_TOKEN
    			    ,p_token1_value	=> 'P_PT_BIND_NAMES');

                l_return_status := OKL_API.G_RET_STS_ERROR;
            END IF;
        ELSE

            OKC_API.SET_MESSAGE (
    			    p_app_name	    => 'OKC'
    			    ,p_msg_name 	=> OKC_API.G_REQUIRED_VALUE
    			    ,p_token1	    => G_COL_NAME_TOKEN
    			    ,p_token1_value	=> 'P_TRANSACTION_ID');

                l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;

        IF p_recipient_email IS NULL OR p_recipient_email = OKL_API.G_MISS_CHAR THEN
            OKC_API.SET_MESSAGE (
    			 p_app_name	    => 'OKC'
    			,p_msg_name 	=> OKC_API.G_REQUIRED_VALUE
    			,p_token1	    => G_COL_NAME_TOKEN
    			,p_token1_value	=> 'P_RECIPIENT_EMAIL');

            l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- validate content and get default subject line
    get_content_id(     p_ptm_code      => p_ptm_code,
                        x_content_id    => l_content_id,
                        x_subject       => l_default_subject,
                        x_return_status => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data );


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Check if a subject line is given, if not use the default line returned from get_content_id
    IF length(trim(p_subject_line)) = 0 OR trim(p_subject_line) <> OKL_API.G_MISS_CHAR THEN
      l_default_subject :=  p_subject_line;
    END IF;

    -- get agent id, from agents email
    get_agent_details(  x_agent_id       => l_agent_id,
                        p_agent_id       => p_agent_id,
                        x_email          => l_agent_email,
                        x_server_id      => l_server_id,
                        x_return_status  => l_return_status,
                        x_msg_count      => l_msg_count,
                        x_msg_data       => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- Check if a sender email is given, if not use the email returned from get_agent_details
    IF length(trim(p_sender_email))= 0 OR trim(p_sender_email) <> OKL_API.G_MISS_CHAR THEN
      l_agent_email :=  p_sender_email;
    END IF;


   IF p_recipient_email IS NOT NULL AND p_recipient_email <> OKL_API.G_MISS_CHAR THEN

        l_recipient_email(1) := p_recipient_email;

   ELSE
       -- get recipient(s) email
       get_recipient_details (
                        p_recipient_id   => p_recipient_id,
                        p_recipient_type => p_recipient_type,
                        p_expand_roles   => p_expand_roles,
                        x_email          => l_recipient_email,
                        x_return_status  => l_return_status,
                        x_msg_count      => l_msg_count,
                        x_msg_data       => l_msg_data);

    END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- compile fulfillment bind parameters

    IF  p_pt_bind_names.COUNT > 0 AND p_pt_bind_values.COUNT > 0 AND p_pt_bind_types.COUNT > 0 THEN

       i := p_pt_bind_names.FIRST;
       j := p_pt_bind_values.FIRST;
       k := p_pt_bind_types.FIRST;

       IF  p_pt_bind_names(i) <> OKL_API.G_MISS_CHAR AND p_pt_bind_names(i) IS NOT NULL
       AND p_pt_bind_values(j) <> OKL_API.G_MISS_CHAR AND p_pt_bind_values(j) IS NOT NULL
       AND p_pt_bind_types(k) <> OKL_API.G_MISS_CHAR AND p_pt_bind_types(k) IS NOT NULL THEN
         l_bind_var_tbl      := p_pt_bind_names;
         l_bind_val_tbl      := p_pt_bind_values;
         l_bind_type_tbl     := p_pt_bind_types;

       ELSE
           l_bind_var_tbl(1)      := 'p_id';
           l_bind_val_tbl(1)      := to_char(p_transaction_id);
           l_bind_type_tbl(1)     := 'NUMBER';
       END IF;
    ELSE

       l_bind_var_tbl(1)      := 'p_id';
       l_bind_val_tbl(1)      := to_char(p_transaction_id);
       l_bind_type_tbl(1)     := 'NUMBER';
    END IF;

    -- loop if more than 0 recipient
    IF (l_recipient_email.COUNT > 0) THEN

      l_loop_counter  := l_recipient_email.FIRST;

      l_email := l_recipient_email(l_loop_counter);

      LOOP

        okl_fulfillment_pvt.create_fulfillment(
                              p_api_version   => p_api_version,
                              p_init_msg_list => FND_API.G_FALSE,
                              p_agent_id      => l_agent_id,
                              p_server_id     => l_server_id,
                              p_content_id    => l_content_id,
                              p_from          => l_agent_email,
                              p_subject       => l_default_subject,
                              p_email         => l_email,
                              p_bind_var      => l_bind_var_tbl,
                              p_bind_val      => l_bind_val_tbl,
                              p_bind_var_type => l_bind_type_tbl,
                              p_commit        => FND_API.G_FALSE,
                              x_request_id    => l_request_id,
                              x_return_status => l_return_status,
                              x_msg_count     => l_msg_count,
                              x_msg_data      => l_msg_data);


        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

            OKL_API.set_message( p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_FM_DEFAULT_ERROR',
                                 p_token1        => 'PTM_MEANING',
                                 p_token1_value  => get_lookup_meaning(p_lookup_type => 'OKL_PROCESSES',
                                                                       p_lookup_code => g_ptm_code
                                                                       )
                                );

            OKL_API.set_message(
                             p_app_name      => 'OKL',
                             p_msg_name      => 'OKL_AM_UNEXP_FM_ERROR',
                             p_token1        => 'EMAIL',
                             p_token1_value  => l_recipient_email(l_loop_counter));

          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

            OKL_API.set_message( p_app_name      => 'OKL',
                                 p_msg_name      => 'OKL_AM_FM_DEFAULT_ERROR',
                                 p_token1        => 'PTM_MEANING',
                                 p_token1_value  => get_lookup_meaning(p_lookup_type => 'OKL_PROCESSES',
                                                                       p_lookup_code => g_ptm_code
                                                                       )
                                );
            OKL_API.set_message(
                             p_app_name      => 'OKL',
                             p_msg_name      => 'OKL_AM_EXP_FM_ERROR',
                             p_token1        => 'EMAIL',
                             p_token1_value  => l_recipient_email(l_loop_counter));

          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        EXIT WHEN (l_loop_counter  = l_recipient_email.LAST);
        l_loop_counter  := l_recipient_email.NEXT(l_loop_counter );
        l_email := l_recipient_email(l_loop_counter);
      END LOOP;
    END IF;

    x_return_status:= l_return_status;
    x_msg_count    := l_msg_count;
    x_msg_data     := l_msg_data;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
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
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

END EXECUTE_FULFILLMENT_REQUEST;
-- End Fulfillment Specific


/*   Procedure add_view populates the global table for checking lengths.
     x_return_status has  'S' if successful else 'E'
*/
----------------------------------------------------------------------------
-- Procedure to add a view for checking length into global table
----------------------------------------------------------------------------
Procedure  add_view(
    p_view_name                    IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2) IS
   cursor av_csr is select  table_name,Column_Name ,data_type,data_length,NVL(data_precision,OKC_API.G_MISS_NUM)
        data_precision,NVL(data_scale,0) data_scale
        FROM  user_tab_columns
        WHERE table_name = UPPER( p_view_name) and (data_type='VARCHAR2' OR data_type='NUMBER');
    var1    av_csr%rowtype;
    i      number:=1;
    found   Boolean:=FALSE;
   Begin
        x_return_status:=OKC_API.G_RET_STS_SUCCESS;
     i:=G_lenchk_tbl.First;
       If G_lenchk_tbl.Count>0 Then
          Loop
           if (UPPER(p_view_name)=UPPER(G_lenchk_tbl(i).vname)) Then
                         found:=TRUE;
                Exit;
           End if;
                 Exit when i=G_lenchk_tbl.Last;
                 i:=G_lenchk_tbl.Next(i);
         End Loop;
       End if;
    If NOT found Then
         OPEN av_csr;
         i:=G_lenchk_tbl.count;
        LOOP
         FETCH av_csr into var1;
         EXIT   WHEN   av_csr%NOTFOUND;
          i:=i+1;
          G_lenchk_tbl(i).vname:=var1.table_name;
          G_lenchk_tbl(i).cname:=var1.column_name;
                        G_lenchk_tbl(i).cdtype:=var1.data_type;
                        if var1.data_type='NUMBER' Then
                          G_lenchk_tbl(i).clength:=var1.data_precision;
                          G_lenchk_tbl(i).cscale:=var1.data_scale;
                        else
                           G_lenchk_tbl(i).clength:=var1.data_length;
                        end if;
        END LOOP;
        If av_csr%ROWCOUNT<1 Then
	     x_return_status:=OKC_API.G_RET_STS_ERROR;
             OKC_API.SET_MESSAGE(p_app_name      =>  G_APP2_NAME,
			         p_msg_name      =>  G_NOTFOUND,
                                 p_token1        =>  G_VIEW_TOKEN,
			         p_token1_value  =>  UPPER(p_view_name));

        End If;

        CLOSE av_csr;
    End If;

 Exception
        when others then
          x_return_status:=OKC_API.G_RET_STS_UNEXP_ERROR;
          OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			      p_msg_name      =>  G_UNEXPECTED_ERROR,
                              p_token1        =>  G_SQLCODE_TOKEN,
			      p_token1_value  =>  sqlcode,
                              p_token2        =>  G_SQLERRM_TOKEN,
			      p_token2_value  =>  sqlerrm);

End add_view;


----------------------------------------------------------------------------
--  checks length of a number column (private procedure)
----------------------------------------------------------------------------
Procedure  checknumlen(
    p_view_name                    IN VARCHAR2,
    p_col_name                     IN VARCHAR2,
    p_col_value                    IN Number,
    x_return_status                OUT NOCOPY VARCHAR2,
    ind        IN Number) IS
    i     Number:=ind;
    l_pre    Number :=0;
    l_scale   Number :=0;
    l_str_pos   Varchar2(40):='';
    l_pos    Number :=0;
    l_neg    Number :=0;
    l_value  Number :=0;
    l_val    varchar2(64):='.';
    cursor c1 is select value from v$nls_parameters where parameter='NLS_NUMERIC_CHARACTERS';
   Begin
   -- get the character specified for decimal right now in the database
      open c1;
      fetch c1 into l_val;
      close c1;
         x_return_status:=OKC_API.G_RET_STS_UNEXP_ERROR;
         l_value:=NVL(p_col_value,0);
	    IF (G_lenchk_tbl(i).clength=OKC_API.G_MISS_NUM) Then
                     x_return_status:=OKC_API.G_RET_STS_SUCCESS;
         ELSE
             l_pre:=G_lenchk_tbl(i).clength-ABS(G_lenchk_tbl(i).cscale);
             for j in 1..l_pre loop
                 l_str_pos:=l_str_pos||'9';
             end loop;
             l_scale:=G_lenchk_tbl(i).cscale;
             If (l_scale>0) Then
     	    	    --l_str_pos:=l_str_pos||'.';
     	    	    l_str_pos:=l_str_pos||substr(l_val,1,1);
      		    for j in 1..l_scale loop
                          l_str_pos:=l_str_pos||'9';
       		    end loop;
             ElsIf (l_scale<0) Then
      		    for j in 1..ABS(l_scale) loop
                          l_str_pos:=l_str_pos||'0';
       		    end loop;
     	    end if;
            l_pos:=to_number(l_str_pos);
            l_neg:=(-1)*l_pos;
            if l_value<=l_pos and l_value>=l_neg then
                 x_return_status:=OKC_API.G_RET_STS_SUCCESS;
            else
                 x_return_status:=OKC_API.G_RET_STS_ERROR;
                 OKC_API.SET_MESSAGE(p_app_name      =>  G_APP2_NAME,
			             p_msg_name      =>  G_LEN_CHK,
                                     p_token1        =>  G_COL_NAME_TOKEN,
			             p_token1_value  =>  p_col_name,
                                     p_token2        =>  'COL_LEN',
			             p_token2_value  =>  G_lenchk_tbl(i).clength||','||ABS(G_lenchk_tbl(i).cscale));
            end if;
         End If;
        EXCEPTION
           when others then
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			            p_msg_name      =>  G_UNEXPECTED_ERROR,
                                    p_token1        =>  G_SQLCODE_TOKEN,
			            p_token1_value  =>  sqlcode,
                                    p_token2        =>  G_SQLERRM_TOKEN,
			            p_token2_value  =>  sqlerrm);
End checknumlen;


/*   Procedure check_length checks the length of the passed in value of column
     x_return_status has  'S' if length is less than or equal to maximum length for that column
     x_return_status has  'E' if length is more than  maximum length for that column
     x_return_status has  'U' if it cannot find the column in the global table populated trough add_view
*/
----------------------------------------------------------------------------
--  checks length of a varchar2 column
----------------------------------------------------------------------------
Procedure  check_length(
    p_view_name                    IN VARCHAR2,
    p_col_name                     IN VARCHAR2,
    p_col_value                    IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2) IS
    i number:=0;
    col_len number:=0;
   Begin
         x_return_status:=OKC_API.G_RET_STS_UNEXP_ERROR;
         i:=G_lenchk_tbl.First;
         Loop
          if ((UPPER(p_view_name)=UPPER(G_lenchk_tbl(i).vname)) and
              (UPPER(p_col_name)=UPPER(G_lenchk_tbl(i).cname)) ) Then
               If  (UPPER(G_lenchk_tbl(i).cdtype)='VARCHAR2') Then
                      col_len:=nvl(length(p_col_value),0);
                      if col_len<=TRUNC((G_lenchk_tbl(i).CLength)/3) then
                            x_return_status:=OKC_API.G_RET_STS_SUCCESS;
                      else
                            x_return_status:= OKC_API.G_RET_STS_ERROR;
                            OKC_API.SET_MESSAGE(p_app_name      =>  G_APP2_NAME,
			                        p_msg_name      =>  G_LEN_CHK,
                                                p_token1        =>  G_COL_NAME_TOKEN,
			                        p_token1_value  =>  p_col_name,
                                                p_token2        =>  'COL_LEN',
			                        p_token2_value  =>  '('||trunc((G_lenchk_tbl(i).clength)/3)||')');
                      end if;
               ElsIf (UPPER(G_lenchk_tbl(i).cdtype)='NUMBER') Then
	               checknumlen(p_view_name,p_col_name,to_number(p_col_value),x_return_status,i);

               End If;
               Exit;
           End if;
           Exit when i=G_lenchk_tbl.Last;
           i:=G_lenchk_tbl.Next(i);
         End Loop;

         EXCEPTION
         when others then
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

                OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			            p_msg_name      =>  G_UNEXPECTED_ERROR,
                                    p_token1        =>  G_SQLCODE_TOKEN,
			            p_token1_value  =>  sqlcode,
                                    p_token2        =>  G_SQLERRM_TOKEN,
			            p_token2_value  =>  sqlerrm);
End check_length;


----------------------------------------------------------------------------
--  checks length of a number column
----------------------------------------------------------------------------
Procedure  check_length(
    p_view_name                    IN VARCHAR2,
    p_col_name                     IN VARCHAR2,
    p_col_value                    IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2) IS
   Begin
         check_length(p_view_name,p_col_name, to_char(p_col_value) , x_return_status);
End check_length;


  -- Start of comments
  --
  -- Function Name	: get_wf_event_name
  -- Description	  : Get the event name for the workflow
  -- Business Rules	:
  -- Parameters		  : p_wf_process_type -- 8 letter shortcode of the WF process
  --                  p_wf_process_name -- internal name of the WF process
  -- Version		    : 1.0
  --
  -- End of comments
  FUNCTION get_wf_event_name(
    p_wf_process_type            	IN VARCHAR2,
    p_wf_process_name            	IN VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2) RETURN VARCHAR2 AS

    -- Cursor to get the event name of WF
    CURSOR okl_get_event_name_csr ( p_process_type IN VARCHAR2,
                                    p_process_name IN VARCHAR2) IS
    SELECT   WFEV.display_name
    FROM     WF_EVENTS_VL             WFEV,
             WF_EVENT_SUBSCRIPTIONS   WFES
    WHERE    WFEV.guid = WFES.event_filter_guid
    AND      WFES.wf_process_type = p_process_type
    AND      UPPER(WFES.wf_process_name) = UPPER(p_process_name);

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_name                         VARCHAR2(200);

  BEGIN

    OPEN  okl_get_event_name_csr ( p_wf_process_type, p_wf_process_name);
    FETCH okl_get_event_name_csr INTO l_name;
    CLOSE okl_get_event_name_csr;

    x_return_status := l_return_status;

    RETURN l_name;

  EXCEPTION
    WHEN OTHERS THEN
      IF okl_get_event_name_csr%ISOPEN THEN
        CLOSE okl_get_event_name_csr;
      END IF;

      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      x_return_status := l_return_status;

      RETURN l_return_status;

  END get_wf_event_name;




  -- Start of comments
  --
  -- Function Name	: get_contract_quotes
  -- Description	  : Get the accepted quotes for the contract
  -- Business Rules	:
  -- Parameters		  : p_khr_id -- contract id
  --                  x_quote_tbl -- Quote details table
  --                  x_return_status -- return status
  -- History        : RMUNJULU -- Bug # 2484327 Created
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE get_contract_quotes (
   p_khr_id        IN  NUMBER,
   x_quote_tbl     OUT NOCOPY quote_tbl_type,
   x_return_status OUT NOCOPY VARCHAR2) IS


     -- Get the accepted quotes for the contract -- both full and partial
     CURSOR get_qte_csr ( p_khr_id IN NUMBER ) IS
        SELECT  QTE.id  id,
                QTE.quote_number quote_number,
                KHR.contract_number contract_number,
                QTE.partial_yn partial_yn,
                QTE.qst_code qst_code,
                QTE.qtp_code qtp_code
        FROM    OKL_TRX_QUOTES_V  QTE,
                OKC_K_HEADERS_V   KHR
        WHERE   QTE.khr_id = KHR.id
        AND     NVL(QTE.accepted_yn,'N') = 'Y'
        AND     NVL(QTE.consolidated_yn,'N') = 'N' -- non consolidated
        AND     QTE.khr_id = p_khr_id;




     l_quote_tbl  quote_tbl_type;
     l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     i NUMBER;


  BEGIN


     i := 1;

     --Loop thru the quotes for the contract and set the quote_tbl
     FOR get_qte_rec IN get_qte_csr(p_khr_id) LOOP

       l_quote_tbl(i).id := get_qte_rec.id;
       l_quote_tbl(i).quote_number := get_qte_rec.quote_number;
       l_quote_tbl(i).contract_number := get_qte_rec.contract_number;
       l_quote_tbl(i).partial_yn := get_qte_rec.partial_yn;
       l_quote_tbl(i).qst_code := get_qte_rec.qst_code;
       l_quote_tbl(i).qtp_code := get_qte_rec.qtp_code;

       i := i + 1;

     END LOOP;

     -- Set the return variables
     x_quote_tbl := l_quote_tbl;
     x_return_status := l_return_status;

  EXCEPTION

    WHEN OTHERS THEN

      IF get_qte_csr%ISOPEN THEN
         CLOSE get_qte_csr;
      END IF;

      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


  END get_contract_quotes;


  -- Start of comments
  --
  -- Function Name	: get_line_quotes
  -- Description	  : Get the accepted quotes for the asset
  -- Business Rules	:
  -- Parameters		  : p_kle_id -- Line id
  --                  x_quote_tbl -- Quote details table
  --                  x_return_status -- return status
  -- History        : RMUNJULU -- Bug # 2484327 Created
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE get_line_quotes (
   p_kle_id        IN  NUMBER,
   x_quote_tbl     OUT NOCOPY quote_tbl_type,
   x_return_status OUT NOCOPY VARCHAR2) IS


     -- Get the accepted quotes for the asset -- both full and partial
     CURSOR get_qte_csr ( p_kle_id IN NUMBER ) IS
        SELECT  QTE.id  id,
                QTE.quote_number quote_number,
                KHR.contract_number contract_number,
                QTE.partial_yn partial_yn,
                QTE.qst_code qst_code,
                QTE.qtp_code qtp_code
        FROM    OKL_TRX_QUOTES_V      QTE,
                OKL_TXL_QUOTE_LINES_V TQL,
                OKC_K_LINES_V         KLE,
                OKC_K_HEADERS_V       KHR
        WHERE   TQL.kle_id = KLE.id
        AND     TQL.qte_id = QTE.id
        AND     KLE.chr_id = KHR.id
        AND     TQL.qlt_code = 'AMCFIA'
        AND     NVL(QTE.accepted_yn,'N') = 'Y'
        AND     NVL(QTE.consolidated_yn,'N') = 'N' -- non consolidated
        AND     TQL.kle_id = p_kle_id;


     l_quote_tbl  quote_tbl_type;
     l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     i NUMBER;


  BEGIN


     i := 1;

     --Loop thru the quotes for the asset and set the quote_tbl
     FOR get_qte_rec IN get_qte_csr(p_kle_id) LOOP

       l_quote_tbl(i).id := get_qte_rec.id;
       l_quote_tbl(i).quote_number := get_qte_rec.quote_number;
       l_quote_tbl(i).contract_number := get_qte_rec.contract_number;
       l_quote_tbl(i).partial_yn := get_qte_rec.partial_yn;
       l_quote_tbl(i).qst_code := get_qte_rec.qst_code;
       l_quote_tbl(i).qtp_code := get_qte_rec.qtp_code;

       i := i + 1;

     END LOOP;

     -- Set the return variables
     x_quote_tbl := l_quote_tbl;
     x_return_status := l_return_status;


  EXCEPTION

    WHEN OTHERS THEN

      IF get_qte_csr%ISOPEN THEN
         CLOSE get_qte_csr;
      END IF;

      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END get_line_quotes;




  -- Start of comments
  --
  -- Function Name	: get_contract_transactions
  -- Description	  : Get unprocessed termination transactions for the contract
  -- Business Rules	:
  -- Parameters		  : p_khr_id -- Contract id
  --                  x_trn_tbl -- transactions details table
  --                  x_return_status -- return status
  -- History        : RMUNJULU -- Bug # 2484327 Created
  --                        nikshah -- Bug # 5484903 Fixed,
  --                                         Changed CURSOR get_trn_csr ( p_khr_id IN NUMBER ) SQL definition
  --                   akrangan - Changed tsu_code to tmt_status_code in get_trn_csr
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE get_contract_transactions (
   p_khr_id        IN  NUMBER,
   x_trn_tbl       OUT NOCOPY trn_tbl_type,
   x_return_status OUT NOCOPY VARCHAR2) IS



     -- Get the unprocessed termination transactions for the contract -- both full and partial
     CURSOR get_trn_csr ( p_khr_id IN NUMBER ) IS
        select  tcn.id  id,
                tcn.trx_number trx_number,
                tcn.tmt_status_code tsu_code, --akrangan changed tsu_code to tmt_status_code
                tcn.tcn_type tcn_type,
                khr.contract_number contract_number,
                qteb.quote_number quote_number,
                qteb.partial_yn partial_yn,
                qteb.qst_code qst_code,
                qteb.qtp_code qtp_code
        from    okl_trx_contracts   tcn,
                   okl_trx_quotes_all_b      qteb,
                   okl_trx_quotes_tl     qte,
                   okc_k_headers_all_b       khr
        where   tcn.khr_id = khr.id
        and     tcn.qte_id = qteb.id(+)
        and     qteb.id = qte.id(+)
        and     qte.language(+) = userenv('LANG')
        and     tcn.tcn_type in ('TMT','ALT','EVG')-- akrangan bug 5354501 fix added 'EVG'
        and     tcn.tmt_status_code not in ('CANCELED','PROCESSED') --akrangan changed
	                                      --tsu_code to tmt_status code
        and     tcn.khr_id = p_khr_id
        --rkuttiya added for 12.1.1 multi gaap project
        and     tcn.representation_type = 'PRIMARY';
        --


     l_trn_tbl  trn_tbl_type;
     l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     i NUMBER;


  BEGIN


     i := 1;

     --Loop thru the quotes for the contract and set the trn_tbl
     FOR get_trn_rec IN get_trn_csr(p_khr_id) LOOP

       l_trn_tbl(i).id := get_trn_rec.id;
       l_trn_tbl(i).trx_number := get_trn_rec.trx_number;
       l_trn_tbl(i).tsu_code := get_trn_rec.tsu_code;
       l_trn_tbl(i).tcn_type := get_trn_rec.tcn_type;
       l_trn_tbl(i).contract_number := get_trn_rec.contract_number;
       l_trn_tbl(i).quote_number := get_trn_rec.quote_number;
       l_trn_tbl(i).partial_yn := get_trn_rec.partial_yn;
       l_trn_tbl(i).qst_code := get_trn_rec.qst_code;
       l_trn_tbl(i).qtp_code := get_trn_rec.qtp_code;

       i := i + 1;

     END LOOP;

     -- Set the return variables
     x_trn_tbl := l_trn_tbl;
     x_return_status := l_return_status;


  EXCEPTION

    WHEN OTHERS THEN

      IF get_trn_csr%ISOPEN THEN
         CLOSE get_trn_csr;
      END IF;

      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END get_contract_transactions;




  -- Start of comments
  --
  -- Function Name	: get_line_transactions
  -- Description	  : Get unprocessed termination transactions for asset
  --                  transactions for the Line
  -- Business Rules	:
  -- Parameters		  : p_kle_id -- Line id
  --                  x_trn_tbl -- transactions details table
  --                  x_return_status -- return status
  -- History        : RMUNJULU -- Bug # 2484327 Created
  --                  AKRANGAN -- Changed tssu_code to tmt_status_cde in get_trn_csr
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE get_line_transactions (
   p_kle_id        IN  NUMBER,
   x_trn_tbl       OUT NOCOPY trn_tbl_type,
   x_return_status OUT NOCOPY VARCHAR2) IS


     -- Get the unprocessed termination transactions for the asset
     CURSOR get_trn_csr ( p_kle_id IN NUMBER ) IS
        SELECT  TCN.id  id,
                TCN.trx_number trx_number,
                TCN.tmt_status_code tsu_code, --akrangan changed tsu_code to tmt_status_code
                TCN.tcn_type tcn_type,
                QTE.quote_number quote_number,
                QTE.partial_yn partial_yn,
                QTE.qst_code qst_code,
                QTE.qtp_code qtp_code
        FROM    OKL_TRX_CONTRACTS   TCN,
                OKL_TRX_QUOTES_B      QTE,
                OKL_TXL_QUOTE_LINES_B TQL
        WHERE   TCN.qte_id = QTE.id
        AND     TQL.qte_id  = QTE.id
        AND     TCN.tcn_type IN ('TMT','ALT' , 'EVG')-- akrangan bug 5354501 fix added 'EVG'
--rkuttiya added for 12.1.1 multi gaap project
        AND     TCN.representation_type = 'PRIMARY'
--
        AND     TQL.qlt_code = 'AMCFIA'
        AND     TCN.tmt_status_code  NOT IN ( 'PROCESSED','CANCELED') --akrangan changed tsu_code to tmt_status_code
        AND     TQL.kle_id = p_kle_id;


     l_trn_tbl  trn_tbl_type;
     l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     i NUMBER;

  BEGIN


     i := 1;

     --Loop thru the quotes for the asset and set the quote_tbl
     FOR get_trn_rec IN get_trn_csr(p_kle_id) LOOP

       l_trn_tbl(i).id := get_trn_rec.id;
       l_trn_tbl(i).trx_number := get_trn_rec.trx_number;
       l_trn_tbl(i).tsu_code := get_trn_rec.tsu_code;
       l_trn_tbl(i).tcn_type := get_trn_rec.tcn_type;
       l_trn_tbl(i).quote_number := get_trn_rec.quote_number;
       l_trn_tbl(i).partial_yn := get_trn_rec.partial_yn;
       l_trn_tbl(i).qst_code := get_trn_rec.qst_code;
       l_trn_tbl(i).qtp_code := get_trn_rec.qtp_code;

       i := i + 1;


     END LOOP;

     -- Set the return variables
     x_trn_tbl := l_trn_tbl;
     x_return_status := l_return_status;


  EXCEPTION

    WHEN OTHERS THEN

      IF get_trn_csr%ISOPEN THEN
         CLOSE get_trn_csr;
      END IF;

      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END get_line_transactions;



  -- Start of comments
  --
  -- Function Name	: get_non_trn_contract_quotes
  -- Description	  : Get accepted non transaction quotes for the Contract
  -- Business Rules	:
  -- Parameters		  : p_khr_id -- Contract id
  --                  x_quote_tbl -- quote details table
  --                  x_return_status -- return status
  -- History        : RMUNJULU -- Bug # 2484327 Created
  --                : RMUNJULU 15-MAR-04 3485854 Added code to reset the l_id value in loop
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE get_non_trn_contract_quotes (
   p_khr_id        IN  NUMBER,
   x_quote_tbl     OUT NOCOPY quote_tbl_type,
   x_return_status OUT NOCOPY VARCHAR2) IS


     -- Get the accepted quotes for the contract  -- both full and partial
     CURSOR get_qte_csr ( p_khr_id IN NUMBER ) IS
        SELECT  QTE.id  id,
                QTE.quote_number quote_number,
                KHR.contract_number contract_number,
                QTE.partial_yn partial_yn,
                QTE.qst_code qst_code,
                QTE.qtp_code qtp_code
        FROM    OKL_TRX_QUOTES_V      QTE,
                OKC_K_HEADERS_V       KHR
        WHERE   QTE.khr_id = KHR.id
        AND     NVL(QTE.accepted_yn,'N') = 'Y'
        AND     QTE.qtp_code LIKE 'TER%'  -- ansethur 07-aug-2007 Added for bug 5932098
        AND     NVL(QTE.consolidated_yn,'N') = 'N' -- non consolidated
        AND     QTE.khr_id = p_khr_id;


     -- Get the transaction for the quote -- both full and partial
     CURSOR get_trn_csr ( p_qte_id IN NUMBER) IS
        SELECT  TRX.id id
        FROM    OKL_TRX_CONTRACTS TRX
        WHERE  TRX.tcn_type IN ('TMT','ALT' , 'EVG')-- akrangan bug 5354501 fix added 'EVG'
--rkuttiya added for 12.1.1 multi gaap
        AND     TRX.representation_type = 'PRIMARY'
--
        AND     TRX.qte_id = p_qte_id;


     l_quote_tbl  quote_tbl_type;
     l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     i NUMBER;
     l_id NUMBER := -9999;

  BEGIN


     i := 1;

     --Loop thru the quotes for the contract
     FOR get_qte_rec IN get_qte_csr(p_khr_id) LOOP

       -- RMUNJULU 15-MAR-04 3485854 reset the l_id value in loop
       l_id := -9999;

       -- get the transaction for the quote
       OPEN get_trn_csr(get_qte_rec.id);
       FETCH get_trn_csr INTO l_id;
       CLOSE get_trn_csr;


       -- If no transaction present for the quote then set it in the quote_tbl
       IF l_id IS NULL OR l_id = -9999 THEN

          l_quote_tbl(i).id := get_qte_rec.id;
          l_quote_tbl(i).quote_number := get_qte_rec.quote_number;
          l_quote_tbl(i).contract_number := get_qte_rec.contract_number;
          l_quote_tbl(i).partial_yn := get_qte_rec.partial_yn;
          l_quote_tbl(i).qst_code := get_qte_rec.qst_code;
          l_quote_tbl(i).qtp_code := get_qte_rec.qtp_code;

          i := i + 1;

       END IF;

     END LOOP;

     -- Set the return variables
     x_quote_tbl := l_quote_tbl;
     x_return_status := l_return_status;


  EXCEPTION

    WHEN OTHERS THEN

      IF get_qte_csr%ISOPEN THEN
         CLOSE get_qte_csr;
      END IF;

      IF get_trn_csr%ISOPEN THEN
         CLOSE get_trn_csr;
      END IF;

      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END get_non_trn_contract_quotes;



    -- Start of comments
    --
    -- Procedure Name	: get_currency_code
    -- Description		: Returns the currency code for a given ORG
    -- Business Rules	:
    -- Parameters		: p_org_id
    -- Version		    : 1.0
    -- History          : 10-DEC-02 DAPATEL - Created
    --                        nikshah -- Bug # 5484903 Fixed,
    --                                         Changed CURSOR l_curr_csr (p_org_id NUMBER) SQL definition
    -- End of comments

    FUNCTION get_currency_code(p_org_id IN NUMBER)
      RETURN VARCHAR2 IS

        l_curr_code VARCHAR2(15);

    	-- Get currency code for the set_of_books
    	CURSOR l_curr_csr (p_org_id NUMBER) IS
            SELECT gl.currency_code
            FROM   GL_LEDGERS_PUBLIC_V gl, HR_ALL_ORGANIZATION_UNITS O, HR_ORGANIZATION_INFORMATION O3
            WHERE  gl.ledger_id = O3.ORG_INFORMATION3
               AND o.organization_id = p_org_id
               AND O.ORGANIZATION_ID = O3.ORGANIZATION_ID
               AND O3.ORG_INFORMATION_CONTEXT = 'Operating Unit Information';

    BEGIN

    	OPEN	l_curr_csr (p_org_id);
    	FETCH	l_curr_csr INTO l_curr_code;
    	CLOSE	l_curr_csr;

        RETURN l_curr_code;

    EXCEPTION

    	WHEN OTHERS THEN
    		IF (l_curr_csr%ISOPEN) THEN
    			CLOSE l_curr_csr;
    		END IF;
    		RETURN (NULL);

    END get_currency_code;


    -- Start of comments
    --
    -- Procedure Name	: get_functional_currency
    -- Description		: Returns the functional currency code for the user ORG
    -- Business Rules	:
    -- Parameters		:
    -- Version		    : 1.0
    -- History          : 10-DEC-02 DAPATEL - Created
    -- End of comments

    FUNCTION get_functional_currency
        RETURN VARCHAR2 IS
        l_org_id NUMBER;
    BEGIN

        l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
        RETURN get_currency_code(l_org_id);

    EXCEPTION

    	WHEN OTHERS THEN
    		RETURN (NULL);

    END get_functional_currency;


    -- Start of comments
    --
    -- Procedure  Name : get_func_currency_org
    -- Description     : Return the functional currency code and ORG ID
    -- Business Rules  :
    -- Parameters      : Input parameters : p_chr_id
    --                 : Output parameters : x_org_id, x_currency_code
    -- Version         : 1.0
    -- History         : 10-DEC-02 DAPATEL - Created
    -- End of comments

    PROCEDURE get_func_currency_org(x_org_id OUT NOCOPY NUMBER
                                   ,x_currency_code OUT NOCOPY VARCHAR2) IS

    BEGIN

        x_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
        x_currency_code := get_currency_code(x_org_id);

    EXCEPTION
      WHEN OTHERS THEN
         -- unexpected error
         OKC_API.set_message(p_app_name  => 'OKC',
                         p_msg_name      => 'OKC_CONTRACTS_UNEXPECTED_ERROR',
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
    END get_func_currency_org;


    -- Start of comments
    --
    -- Procedure  Name : get_chr_currency_org
    -- Description     : Return the contract currency code and ORG ID for a given Contract ID
    -- Business Rules  :
    -- Parameters      : Input parameters : p_chr_id
    --                 : Output parameters : x_org_id, x_currency_code
    -- Version         : 1.0
    -- History         : 10-DEC-02 DAPATEL - Created
    -- End of comments

    PROCEDURE get_chr_currency_org(p_chr_id IN NUMBER
                                  ,x_org_id OUT NOCOPY NUMBER
                                  ,x_currency_code OUT NOCOPY VARCHAR2) IS

    BEGIN
        x_org_id := get_chr_org_id(p_chr_id => p_chr_id);
        x_currency_code := get_chr_currency(p_chr_id => p_chr_id);

    EXCEPTION
      WHEN OTHERS THEN
         -- unexpected error
         OKC_API.set_message(p_app_name  => 'OKC',
                         p_msg_name      => 'OKC_CONTRACTS_UNEXPECTED_ERROR',
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
    END get_chr_currency_org;


    -- Start of comments
    --
    -- Function  Name  : get_user_profile_option_name
    -- Description     : This function returns the user profile option name for a profile
    -- Business Rules  :
    -- Parameters      : Input parameters : p_profile_option_name
    --                 : Output parameters : x_return_status
    -- Version         : 1.0
    -- History         : 10-DEC-02 DAPATEL - Created
    -- End of comments

    FUNCTION get_user_profile_option_name(p_profile_option_name IN VARCHAR2,
                           x_return_status       OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

    CURSOR l_profileoptionsvl_csr IS
    SELECT user_profile_option_name
    FROM   fnd_profile_options_vl
    WHERE  profile_option_name = p_profile_option_name;

    l_user_profile_name   VARCHAR2(240);
    BEGIN
       x_return_status := OKL_API.G_RET_STS_SUCCESS;

       OPEN  l_profileoptionsvl_csr;
       FETCH l_profileoptionsvl_csr INTO l_user_profile_name;
       IF l_profileoptionsvl_csr%NOTFOUND THEN
           x_return_status := OKL_API.G_RET_STS_ERROR;
       END IF;
       CLOSE l_profileoptionsvl_csr;

       RETURN l_user_profile_name;

    EXCEPTION
      WHEN OTHERS THEN

         IF l_profileoptionsvl_csr%ISOPEN THEN
            CLOSE l_profileoptionsvl_csr;
         END IF;
         -- unexpected error
         OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => 'OKC_CONTRACTS_UNEXPECTED_ERROR',
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
          RETURN NULL;
    END get_user_profile_option_name;

    -- Start of comments
    --
    -- Function  Name  : convert_to_contract_currency
    -- Description     : This function converts an amount to the contract currency
    -- Business Rules  :
    -- Parameters      : Input parameters : p_khr_id
    --                 :                  : p_trx_date
    --                 :                  : p_amount
    --                 : Output parameters: RETURN NUMBER
    -- Version         : 1.0
    -- History         : 23-DEC-02 DAPATEL 2667636 Created for multi-currency
    --                 : 07-FEB-03 DAPATEL 115.47 2780466 - Modified
    --                 : okl_accounting_util usage to use
    --                 : new procedures containing error handling.
    -- End of comments
    FUNCTION convert_to_contract_currency(p_khr_id IN NUMBER
                                         ,p_trx_date IN DATE
                                         ,p_amount IN NUMBER) RETURN NUMBER IS

        l_contract_currency VARCHAR2(15);
        l_currency_conversion_type	VARCHAR2(30);
        l_currency_conversion_rate	NUMBER;
        l_currency_conversion_date	DATE;
        l_converted_amount			NUMBER;
        l_return_status             VARCHAR2(3);

    BEGIN

        OKL_ACCOUNTING_UTIL.convert_to_contract_currency
            (p_khr_id                   => p_khr_id,
             p_from_currency            => NULL,
             p_transaction_date         => NVL(p_trx_date, sysdate),
             p_amount 			        => p_amount,
             x_return_status            => l_return_status,
             x_contract_currency        => l_contract_currency,
             x_currency_conversion_type	=> l_currency_conversion_type,
             x_currency_conversion_rate	=> l_currency_conversion_rate,
             x_currency_conversion_date	=> l_currency_conversion_date,
             x_converted_amount 		=> l_converted_amount);

    	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            l_converted_amount := 0;
        END IF;
        RETURN l_converted_amount;

    EXCEPTION

      WHEN OTHERS THEN

         -- unexpected error
         OKL_API.set_message(p_app_name  => 'OKC',
                         p_msg_name      => 'OKC_CONTRACTS_UNEXPECTED_ERROR',
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          RETURN 0;
    END convert_to_contract_currency;


  -- Start of comments
  --
  -- Function Name	: get_all_term_quotes_for_line
  -- Description	  : Get all termination quotes for the asset
  -- Business Rules	:
  -- Parameters		  : p_kle_id -- Line id
  --                  x_quote_tbl -- Quote details table
  --                  x_return_status -- return status
  -- History        : RMUNJULU 30-DEC-02 2699412 Created
  --                        nikshah -- Bug # 5484903 Fixed,
  --                                         Changed CURSOR get_qte_csr ( p_kle_id IN NUMBER ) SQL definition
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE get_all_term_quotes_for_line (
   p_kle_id        IN  NUMBER,
   x_quote_tbl     OUT NOCOPY quote_tbl_type,
   x_return_status OUT NOCOPY VARCHAR2) IS


     -- Get all non-consolidated quotes for the asset -- both full and partial
     CURSOR get_qte_csr ( p_kle_id IN NUMBER ) IS
        SELECT  QTE.id  id,
                QTE.quote_number quote_number,
                KHR.contract_number contract_number,
                QTE.partial_yn partial_yn,
                QTE.consolidated_yn consolidated_yn,
                QTE.qst_code qst_code,
                QTE.qtp_code qtp_code
        FROM    OKL_TRX_QUOTES_B      QTE,
                OKL_TXL_QTE_LINES_ALL_B TQL,
                OKC_K_LINES_B         KLE,
                OKC_K_HEADERS_ALL_B       KHR
        WHERE   TQL.kle_id = KLE.id
        AND     TQL.qte_id = QTE.id
        AND     KLE.chr_id = KHR.id
        AND     TQL.qlt_code = 'AMCFIA'
        AND     QTE.qtp_code LIKE 'TER%'
        AND     TQL.kle_id = p_kle_id;


     l_quote_tbl  quote_tbl_type;
     l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     i NUMBER;


  BEGIN


     i := 1;

     --Loop thru the quotes for the asset and set the quote_tbl
     FOR get_qte_rec IN get_qte_csr(p_kle_id) LOOP

       l_quote_tbl(i).id := get_qte_rec.id;
       l_quote_tbl(i).quote_number := get_qte_rec.quote_number;
       l_quote_tbl(i).contract_number := get_qte_rec.contract_number;
       l_quote_tbl(i).partial_yn := get_qte_rec.partial_yn;
       l_quote_tbl(i).consolidated_yn := get_qte_rec.consolidated_yn;
       l_quote_tbl(i).qst_code := get_qte_rec.qst_code;
       l_quote_tbl(i).qtp_code := get_qte_rec.qtp_code;

       i := i + 1;

     END LOOP;

     -- Set the return variables
     x_quote_tbl := l_quote_tbl;
     x_return_status := l_return_status;


  EXCEPTION

    WHEN OTHERS THEN

      IF get_qte_csr%ISOPEN THEN
         CLOSE get_qte_csr;
      END IF;

      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END get_all_term_quotes_for_line;


  -- Start of comments
  --
  -- Function  Name  : get_net_investment
  -- Description     : This function calculates the net investment value
  -- Business Rules  :
  -- Parameters      : Input parameters : contract id, contract line id
  --                 : Output parameters : x_return_status
  -- Version         : 1.0
  -- History         : SECHAWLA 14-FEB-03 2749690 - Created
  --                   SECHAWLA 14-JUN-04 3449645 - Added check for LEASEST
  --                   rmunjulu 17-May-05 4299668 - Changed to call New Formula for OP Leases.
  --                   rmunjulu LOANS_ENHACEMENTS
  --                   RMUNJULU 4699340 CALCULATE NET INVESTMENT FOR DF LEASES USING LINE_ASSET_NET_INVESTMENT
  --                   prasjain 6030917 Added new parameter p_proration_factor to the function
  --                   adding proration for all other cases which is not using formula LINE_ASSET_NET_INVESTMENT
  --                   sending l_proration_factor as additional parameter to this formula LINE_ASSET_NET_INVESTMENT
  -- End of comments

  FUNCTION get_net_investment( p_khr_id         IN  NUMBER,
                               p_kle_id         IN  NUMBER,
                               p_quote_id       IN  NUMBER, -- rmunjulu LOANS_ENHANCEMENT
                               p_message_yn     IN  BOOLEAN,
                               p_proration_factor IN NUMBER DEFAULT NULL,
                               x_return_status  OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  l_deal_type                   okl_k_headers.deal_type%TYPE;
  l_formula_name                VARCHAR2(150) ;
  l_net_investment              okl_txl_quote_lines_b.asset_value%TYPE;
  l_asset_value	                ak_attributes_vl.attribute_label_long%TYPE;

  --SECHAWLA 09-AUG-05 4304230 : new declarations
  l_asset_net_book_value        okl_txl_quote_lines_b.asset_value%TYPE;
  l_sts_code                    VARCHAR2(30);

   -- This cursor is used to get the deal type for a contract.
  CURSOR l_oklheaders_csr(p_khr_id IN NUMBER) IS
  SELECT chr.sts_code,khr.deal_type
  FROM   okl_k_headers khr, okc_k_headers_b chr
  WHERE  khr.id = p_khr_id
  AND    KHR.ID = CHR.ID;

   -- SECHAWLA 09-AUG-05 4304230 : new declaraions end

  /* SECHAWLA 09-AUG-05 4304230
  -- This cursor is used to get the deal type for a contract.
  CURSOR l_oklheaders_csr(p_khr_id IN NUMBER) IS
  SELECT deal_type
  FROM   okl_k_headers
  WHERE  id = p_khr_id;
  */

    -- -- rmunjulu LOANS_ENHANCEMENT
    l_add_params		okl_execute_formula_pub.ctxt_val_tbl_type;

    -- rmunjulu bug 4699340
    l_date_effective_from DATE;

    -- rmunjulu bug 4699340
	CURSOR get_qte_date_csr (p_quote_id IN NUMBER) IS
	SELECT date_effective_from
	FROM   OKL_TRX_QUOTES_B
	WHERE  id = p_quote_id;

    -- Start : Bug 6030917 : prasjain
    l_proration_factor  NUMBER;
    l_proration_flag    VARCHAR2(1) := 'N';
    -- End : Bug 6030917 : prasjain

  BEGIN

   x_return_status := OKL_API.G_RET_STS_SUCCESS ;

   OPEN  l_oklheaders_csr(p_khr_id);
   FETCH l_oklheaders_csr INTO l_sts_code, l_deal_type; -- SECHAWLA 09-AUG-05 4304230 : added sts_code
   IF l_oklheaders_csr%NOTFOUND THEN
      OKC_API.set_message( p_app_name      => 'OKC',
                           p_msg_name      => G_INVALID_VALUE,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'KHR_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN 0;
   END IF;
   CLOSE l_oklheaders_csr;

     -- -- rmunjulu LOANS_ENHANCEMENT set the operands for formula engine with quote_id
    l_add_params(1).name := 'quote_id';
    l_add_params(1).value := to_char(p_quote_id);

    l_add_params(2).name := 'QUOTE_ID';
    l_add_params(2).value := to_char(p_quote_id);

    -- rmunjulu bug 4699340
    OPEN get_qte_date_csr (p_quote_id);
    FETCH get_qte_date_csr INTO l_date_effective_from;
    CLOSE get_qte_date_csr;

    -- rmunjulu bug 4699340
    l_add_params(3).name := 'quote_effective_from_date';
    l_add_params(3).value := to_char(l_date_effective_from,'MM/DD/YYYY');

    -- Start : Bug 6030917 : prasjain
    l_proration_factor  := p_proration_factor;
    -- End : Bug 6030917 : prasjain

   IF    l_deal_type = 'LEASEOP' THEN
         --l_formula_name := 'CONTRACT_NET_INVESTMENT_OP';
         l_formula_name := 'ASSET_NET_INVESTMENT_OP';     -- rmunjulu 4299668
   ELSIF l_deal_type IN ('LEASEDF', 'LEASEST') THEN  -- SECHAWLA 14-JUN-04 3449645 : Added check for LEASEST
         -- -- SECHAWLA 09-AUG-05 4304230 - added the following condition to use diff formula
         -- to calcualte net investment when contract goes to evergreen status.
        IF l_sts_code ='EVERGREEN' THEN
           l_formula_name := 'ASSET_NET_BOOK_VALUE';
        ELSE
          l_formula_name := 'LINE_ASSET_NET_INVESTMENT'; --'CONTRACT_NET_INVESTMENT_DF'; --rmunjulu bug 4699340 use this formula which calculates based on future values.
          -- Start : Bug 6030917 : prasjain
          -- adding additional parameter to the formula
          l_add_params(4).name := 'proration_factor';
          l_add_params(4).value := to_char(l_proration_factor);
          l_proration_flag := 'Y';
          -- End : Bug 6030917 : prasjain
        END IF;

   ElSIF l_deal_type LIKE 'LOAN%' THEN
        -- l_formula_name := 'CONTRACT_NET_INVESTMENT_LOAN';
         l_formula_name := 'ASSET_NET_INVESTMENT_LOAN'; -- rmunjulu LOANS_ENHACEMENTS -- call this new formula
   END IF;

   okl_am_util_pvt.get_formula_value(
                  p_formula_name	       => l_formula_name,
                  p_chr_id	               => p_khr_id,
                  p_cle_id	               => p_kle_id,
                  p_additional_parameters  => l_add_params, -- rmunjulu LOANS_ENHANCEMENT
		          x_formula_value	       => l_net_investment,
		          x_return_status	       => x_return_status);

   IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      IF p_message_yn THEN
            l_asset_value := get_ak_attribute(p_code => 'OKL_NET_INVESTMENT');
            -- Unable to calculate ASSET_VALUE
            OKL_API.set_message(  p_app_name      => 'OKL',
                              p_msg_name      => 'OKL_AM_FORMULA_ERROR',
                              p_token1        => 'ASSET_VALUE',
                              p_token1_value  => l_asset_value);
      END IF;
      RETURN 0;
   END IF;

   IF l_net_investment IS NULL THEN
      l_net_investment := 0;
   END IF;

   -- Start : Bug 6030917 : prasjain
   IF  l_proration_flag <> 'Y'
   AND l_proration_factor < 1  THEN
     l_net_investment := l_net_investment * l_proration_factor;
   END IF;
   -- End : Bug 6030917 : prasjain

   RETURN l_net_investment;

   EXCEPTION
      WHEN OTHERS THEN
         IF l_oklheaders_csr%ISOPEN THEN
            CLOSE l_oklheaders_csr;
         END IF;
         -- unexpected error
         OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => 'OKC_CONTRACTS_UNEXPECTED_ERROR',
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);

          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

          RETURN 0;
  END  get_net_investment;
--
-- BAKUCHIB Bug 2757368 start
--
--------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Get Party Name
-- Description          : Returns the Name of the Party Role
-- Business Rules       :
-- Parameters           : P_chr_id, p_kle_id(optional), p_rle_code
-- Version              : 1.0
-- History              : BAKUCHIB  19-FEB-2003 - 2757368 created
--                        BAKUCHIB  21-FEB-2303 - 2757368 - Modified  to reomve
--                        Message stack population of invaid value, and removed
--                        checking of OKL_API.g_miss_* validation in the
--                        c_party_csr%not_found if condition. Added logic in
--                        exception section to close the cursor if open.
-- End of Commnets

  FUNCTION get_party_name(
            p_chr_id               IN  OKC_K_HEADERS_B.ID%TYPE,
            p_rle_code             IN  OKC_K_PARTY_ROLES_B.RLE_CODE%TYPE,
            p_kle_id               IN  OKL_K_HEADERS.ID%TYPE)
  RETURN VARCHAR2 IS
    lv_object1_id1     OKC_K_PARTY_ROLES_B.OBJECT1_ID1%TYPE;
    lv_object1_id2     OKC_K_PARTY_ROLES_B.OBJECT1_ID2%TYPE;
    lv_object1_code    OKC_K_PARTY_ROLES_B.JTOT_OBJECT1_CODE%TYPE;
    lv_name            VARCHAR2(2000) := NULL;
    excp_party_error   EXCEPTION;

    -- Get the Party role details
    CURSOR c_party_csr(p_chr_id OKC_K_HEADERS_B.ID%TYPE,
                       p_kle_id OKL_K_LINES.ID%TYPE,
                       p_rle_code OKC_K_PARTY_ROLES_B.RLE_CODE%TYPE)
    IS
    SELECT object1_id1,
           object1_id2,
           jtot_object1_code
    FROM okc_k_party_roles_b
    WHERE dnz_chr_id  = p_chr_id
    AND rle_code = p_rle_code
    AND nvl(cle_id,1) = nvl(p_Kle_id,nvl(cle_id,1));

  BEGIN
    IF (p_chr_id IS NULL OR
       p_chr_id = OKL_API.G_MISS_NUM) OR
       (p_rle_code IS NULL OR
       p_rle_code = OKL_API.G_MISS_CHAR) THEN
      RAISE excp_party_error;
    END IF;
    OPEN c_party_csr(p_chr_id   => p_chr_id,
                     p_kle_id   => p_kle_id,
                     p_rle_code => p_rle_code);
    FETCH c_party_csr INTO lv_object1_id1,
                           lv_object1_id2,
                           lv_object1_code;
    IF c_party_csr%NOTFOUND THEN
      RAISE excp_party_error;
    END IF;
    CLOSE c_party_csr;
    IF lv_object1_id1 IS NOT NULL AND
       lv_object1_code IS NOT NULL THEN
      lv_name := OKL_AM_UTIL_PVT.get_jtf_object_name(
                                 p_object_code => lv_object1_code,
                                 p_object_id1  => lv_object1_id1,
                                 p_object_id2  => lv_object1_id2);
    ELSE
      RAISE excp_party_error;
    END IF;
    RETURN lv_name;
  EXCEPTION
    WHEN excp_party_error THEN
      IF c_party_csr%ISOPEN THEN
        CLOSE c_party_csr;
      END IF;
      RETURN NULL;
    WHEN OTHERS THEN
      IF c_party_csr%ISOPEN THEN
        CLOSE c_party_csr;
      END IF;
      RETURN NULL;
  END get_party_name;
--
-- BAKUCHIB Bug 2757368 end
--


  -- Start of comments
  --
  -- Function Name	: get_all_term_quotes_for_contract
  -- Description	  : Get all termination quotes for the contract
  -- Business Rules	:
  -- Parameters		  : p_khr_id -- Line id
  --                  x_quote_tbl -- Quote details table
  --                  x_return_status -- return status
  -- History        : SPILLIAIP 06-OCT-03 3115478 Created
  -- Version		    : 1.0
  --
  -- End of comments
  PROCEDURE get_all_term_qte_for_contract (
   p_khr_id        IN  NUMBER,
   x_quote_tbl     OUT NOCOPY quote_tbl_type,
   x_return_status OUT NOCOPY VARCHAR2) IS


     -- Get all non-consolidated quotes for the asset -- both full and partial
     CURSOR get_qte_csr ( p_khr_id IN NUMBER ) IS
        SELECT  QTE.id  id,
                QTE.quote_number quote_number,
                KHR.contract_number contract_number,
                QTE.partial_yn partial_yn,
                QTE.consolidated_yn consolidated_yn,
                QTE.qst_code qst_code,
                QTE.qtp_code qtp_code
        FROM    OKL_TRX_QUOTES_B      QTE,
                OKC_K_HEADERS_B       KHR
        WHERE   qte.khr_id = khr.id
        AND     qte.khr_id = p_khr_id
        AND     QTE.qtp_code LIKE 'TER%';


     l_quote_tbl  quote_tbl_type;
     l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     i NUMBER;


  BEGIN


     i := 1;
     --Loop thru the quotes for the asset and set the quote_tbl
     FOR get_qte_rec IN get_qte_csr(p_khr_id) LOOP

       l_quote_tbl(i).id := get_qte_rec.id;
       l_quote_tbl(i).quote_number := get_qte_rec.quote_number;
       l_quote_tbl(i).contract_number := get_qte_rec.contract_number;
       l_quote_tbl(i).partial_yn := get_qte_rec.partial_yn;
       l_quote_tbl(i).consolidated_yn := get_qte_rec.consolidated_yn;
       l_quote_tbl(i).qst_code := get_qte_rec.qst_code;
       l_quote_tbl(i).qtp_code := get_qte_rec.qtp_code;

       i := i + 1;

     END LOOP;

     -- Set the return variables
     x_quote_tbl := l_quote_tbl;
     x_return_status := l_return_status;


  EXCEPTION

    WHEN OTHERS THEN

      IF get_qte_csr%ISOPEN THEN
         CLOSE get_qte_csr;
      END IF;

      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END  get_all_term_qte_for_contract;

  -- Start of comments
  --
  -- Function Name	  : get_actual_asset_residual
  -- Description	  : Get actual residual value for an asset
  -- Business Rules	  : Should be called with only terminated line
  --                    Should be for OP/DF/SALES type Lease contract only -- which has FA values
  -- Parameters		  : p_khr_id -- Contract id
  --                    p_kle_id -- Line Id
  -- History          : RMUNJULU 18-MAY-04 3510740 Created
  --                    rmunjulu 3816891 FORWARDPORT changed logic when termination with purchase
  --                    rmunjulu 3816891 call formula ASSET_DF_TERMINATION_NIV for DF/ST term with/without purchase
  --                    rmunjulu 4399736 For LOANS residual is the net investment calculated on quote
  --                        nikshah -- Bug # 5484903 Fixed,
  --                                         Changed CURSOR get_acc_deprn1_csr (p_kle_id IN NUMBER) SQL definition
  --                     akrangan -- changed tsu_code to tmt_status_code in get_quote_type_csr
  -- Version		  : 1.0
  --
  -- End of comments
  FUNCTION get_actual_asset_residual (
   p_khr_id        IN  NUMBER,
   p_kle_id        IN  NUMBER) RETURN NUMBER IS

   -- get asset termination date
   CURSOR get_term_date_csr (p_kle_id IN NUMBER) IS
   SELECT kle.date_terminated
   FROM   OKC_K_LINES_B kle
   WHERE  kle.id = p_kle_id;

   -- get termination trn for the contract and asset
   CURSOR get_quote_type_csr (p_khr_id IN NUMBER, p_kle_id IN NUMBER) IS
   SELECT qte.id,
          qte.qtp_code, -- quote type
          qte.date_accepted, -- quote acceptance date
          nvl(tql.asset_value,0) net_investment -- rmunjulu 4399736
   FROM   OKL_TRX_CONTRACTS trn,
          OKL_TRX_QUOTES_B qte,
          OKL_TXL_QUOTE_LINES_B tql
   WHERE  trn.khr_id = p_khr_id
   AND    trn.tmt_status_code <> 'CANCELED' --akrangan changed tsu_code to tmt_status_code
   AND    trn.qte_id = qte.id
--rkuttiya added for 12.1.1 Multi GAAAP Project
   AND    trn.representation_type = 'PRIMARY'
--
   AND    qte.id = tql.qte_id
   AND    tql.qlt_code = 'AMCFIA'
   AND    tql.kle_id  = p_kle_id;

   -- get purchase amount for asset
   CURSOR get_purchase_amt_csr (p_qte_id IN NUMBER, p_kle_id IN NUMBER) IS
   SELECT tql.amount
   FROM   OKL_TXL_QUOTE_LINES_B tql
   WHERE  tql.qte_id = p_qte_id
   AND    tql.kle_id = p_kle_id
   AND    tql.qlt_code = 'AMBPOC';

   -- get purchase amount for asset
   CURSOR get_khr_deal_csr (p_khr_id IN NUMBER) IS
   SELECT khr.deal_type
   FROM   OKL_K_HEADERS khr
   WHERE  khr.id = p_khr_id;

   -- get accumulated depreciation for the asset on the termination date(AVSINGH)
   -- if the FA book period is closed
   CURSOR get_acc_deprn_csr (p_kle_id IN NUMBER, p_ter_date IN DATE) IS
   SELECT fds.deprn_reserve  deprn_amt
   FROM   fa_deprn_summary fds,
          fa_deprn_periods fdp,
          fa_book_controls fbc,
          fa_calendar_periods fcp,
          okc_k_items_v itm,
          okc_k_lines_b kle,
          okc_line_styles_v lse
   WHERE  fdp.book_type_code = fds.book_type_code
   AND    fdp.period_counter = fds.period_counter
   AND    fbc.book_class = 'CORPORATE'
   AND    fds.book_type_code = fbc.book_type_code
   AND    fds.asset_id = itm.object1_id1
   AND    itm.cle_id = kle.id
   AND    kle.cle_id = p_kle_id
   AND    kle.lse_id = lse.id
   AND    lse.lty_code = 'FIXED_ASSET'
   AND    fbc.deprn_calendar  = fcp.calendar_type
   AND    fcp.period_name     = fdp.period_name
   AND    TRUNC(p_ter_date) BETWEEN  fcp.START_DATE AND fcp.end_date;

   -- get accumulated depreciation for the asset on the termination date(AVSINGH)
   -- if the FA Book period is open
   CURSOR get_acc_deprn1_csr (p_kle_id IN NUMBER) IS
   select fds.deprn_reserve  deprn_amt
   from   fa_deprn_summary fds,
          fa_deprn_periods fdp,
          fa_book_controls fbc,
          okc_k_items itm,
          okc_k_lines_b kle,
          okc_line_styles_b lse
   where  fdp.book_type_code = fds.book_type_code
   and    fdp.period_counter - 1 = fds.period_counter
   and    fdp.period_close_date is null
   and    fbc.book_class = 'CORPORATE'
   and    fds.book_type_code = fbc.book_type_code
   and    fds.asset_id = itm.object1_id1
   and    itm.cle_id = kle.id
   and    kle.cle_id = p_kle_id
   and    kle.lse_id = lse.id
   and    lse.lty_code = 'FIXED_ASSET';

   -- get asset cost
   CURSOR get_asset_cost_csr (p_kle_id IN NUMBER) IS
   SELECT fab.original_cost
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

   -- get deprn cost from off-lease trn (SECHAWLA)
   CURSOR get_deprn_cost_csr (p_kle_id IN NUMBER) IS
   SELECT depreciation_cost
   FROM   okl_txl_assets_b
   WHERE  kle_id = p_kle_id
   AND    tal_type = 'AML'
   AND    ROWNUM < 2;

   -- rmunjulu 3735773
   -- get asset residual value (RMUNJULU)
   CURSOR get_asset_residual_csr (p_kle_id IN NUMBER) IS
   SELECT nvl(residual_value,0) residual_value
   FROM   okl_k_lines
   WHERE  id = p_kle_id;

   -- rmunjulu 3735773
   -- get asset cost for corporate book (RMUNJULU)
   CURSOR get_corp_book_cost_csr (p_kle_id IN NUMBER) IS
   SELECT a.COST cost
   FROM   okx_asset_lines_v o, fa_books a, fa_book_controls b
   WHERE  o.parent_line_id = p_kle_id
   AND    o.asset_id = a.asset_id
   AND    a.book_type_code = b.book_type_code
   AND    a.date_ineffective IS NULL
   AND    a.transaction_header_id_out IS NULL
   AND    b.book_class = 'CORPORATE';

   l_date_terminated DATE;
   l_quote_id NUMBER;
   l_quote_type OKL_TRX_QUOTES_B.qtp_code%TYPE;
   l_asset_residual NUMBER;
   l_deprn_amt NUMBER;
   l_deal_type OKL_K_HEADERS.deal_type%TYPE;
   l_cost NUMBER;
   l_period_open VARCHAR2(1);

   Expected_error EXCEPTION;

   -- rmunjulu 3735773
   l_residual NUMBER;
   l_corp_book_cost NUMBER;

   l_params		okl_execute_formula_pub.ctxt_val_tbl_type;
   l_formula_name VARCHAR2(300);
   l_return_status VARCHAR2(3);

   -- rmunjulu 4399736
   l_net_investment NUMBER;

  BEGIN

     -- Get the termination date for the asset
     -- Get the termination quote type for asset(with/without purchase)
     -- If with purchase then
        -- Get the purchase amount quote line
     -- If without purchase and NON OP LEASE then
        -- Get the Off-lease trn value
     -- If without purchase and OP LEASE then
        -- get the net book value on the termination date

     -- Check for data validity
     IF p_khr_id IS NULL OR p_khr_id = OKL_API.G_MISS_NUM
     OR p_khr_id IS NULL OR p_khr_id = OKL_API.G_MISS_NUM  THEN

        RAISE Expected_Error;

     END IF;

     l_asset_residual := 0;
     l_cost := 0;
     l_deprn_amt := 0;

     -- rmunjulu 3735773
     l_residual := 0;
     l_corp_book_cost := 0;

     l_formula_name := 'ASSET_DF_TERMINATION_NIV';

     -- Get the termination date for the asset
     FOR get_term_date_rec IN get_term_date_csr (p_kle_id) LOOP
        l_date_terminated := get_term_date_rec.date_terminated;
     END LOOP;

     -- Get the termination quote type for asset(with/without purchase)
     FOR get_quote_type_rec IN get_quote_type_csr (p_khr_id, p_kle_id) LOOP
        l_quote_id := get_quote_type_rec.id;
        l_quote_type := get_quote_type_rec.qtp_code;
        l_net_investment := get_quote_type_rec.net_investment; -- rmunjulu 4399736
        --l_date_terminated := get_quote_type_rec.date_accepted;
     END LOOP;

     -- If termination with purchase
     IF l_quote_type IN ('TER_MAN_PURCHASE',
                         'TER_PURCHASE',
                         'TER_RECOURSE',
                         'TER_ROLL_PURCHASE') THEN -- with purchase

        -- rmunjulu 3735773
        -- Get the deal type for the contract
        FOR get_khr_deal_rec IN get_khr_deal_csr (p_khr_id) LOOP
           l_deal_type :=  get_khr_deal_rec.deal_type;
        END LOOP;

        -- rmunjulu 3735773
        -- If DF/ST Lease then the asset residual is residual value
        IF l_deal_type IN ('LEASEDF', 'LEASEST') THEN -- non OP lease

/* -- rmunjulu This piece of logic now resides in seeded formula, so call formula to get value
            -- Same logic as used in Retirement to update corporate book cost
            -- get the asset residual value
            FOR get_asset_residual_rec IN get_asset_residual_csr (p_kle_id) LOOP
                l_residual := get_asset_residual_rec.residual_value;
            END LOOP;

            -- get the asset cost from corporate book -- will be 0 normally
            FOR get_corp_book_cost_rec IN get_corp_book_cost_csr (p_kle_id) LOOP
                l_corp_book_cost := get_corp_book_cost_rec.cost;
            END LOOP;

            -- asset residual will be same calculation used in asset disposal
            l_asset_residual := l_residual - l_corp_book_cost + l_corp_book_cost;
*/

            -- rmunjulu Call the seeded formula to get residual value
            l_params(1).name := 'QUOTE_ID';
            l_params(1).value := l_quote_id;

    	    get_formula_value (
			    	p_formula_name	        => l_formula_name,
			    	p_chr_id	            => p_khr_id,
			    	p_cle_id	            => p_kle_id,
			    	p_additional_parameters => l_params,
			    	x_formula_value	        => l_asset_residual,
			    	x_return_status	        => l_return_status);

		    IF l_asset_residual IS NULL THEN

		      l_asset_residual := 0;
		    END IF;

        ELSIF l_deal_type IN ('LEASEOP') THEN   -- OP Lease

--            -- Get the purchase amount quote line which will be the asset residual
--            FOR get_purchase_amt_rec IN get_purchase_amt_csr (l_quote_id, p_kle_id) LOOP
--               l_asset_residual :=  get_purchase_amt_rec.amount;
--            END LOOP;

           -- rmunjulu 3735773 -- use the same logic as used for term without purchase
           -- Calculate the Net Book Value for the asset on termination date

           -- Net Book Value = Asset Cost - Accumulated Deprn

           -- Get the deprn amount
           OPEN get_acc_deprn_csr(p_kle_id, l_date_terminated);
           FETCH get_acc_deprn_csr INTO l_deprn_amt;
           IF get_acc_deprn_csr%NOTFOUND THEN
              l_period_open := 'Y';
           END IF;
           CLOSE get_acc_deprn_csr;

           -- if FA Book period is open get it from there
           IF l_period_open = 'Y' THEN
              -- Get the deprn amount
              FOR get_acc_deprn1_rec IN get_acc_deprn1_csr (p_kle_id) LOOP
                 l_deprn_amt :=  get_acc_deprn1_rec.deprn_amt;
              END LOOP;
           END IF;

           -- Get the asset cost
           FOR get_asset_cost_rec IN get_asset_cost_csr (p_kle_id) LOOP
              l_cost :=  get_asset_cost_rec.original_cost;
           END LOOP;

           -- Calculate net book value which will be residual
           l_asset_residual :=  l_cost - l_deprn_amt;

        ELSIF  l_deal_type IN ('LOAN','LOAN-REVOLVING') THEN  -- rmunjulu 4399736

            -- get residual value as the one populated on the quote
            l_asset_residual := l_net_investment;

        ELSE

            l_asset_residual := 0;

        END IF;

     ELSE -- without purchase

        -- Get the deal type for the contract
        FOR get_khr_deal_rec IN get_khr_deal_csr (p_khr_id) LOOP
           l_deal_type :=  get_khr_deal_rec.deal_type;
        END LOOP;

        IF l_deal_type IN ('LEASEDF', 'LEASEST') THEN -- NON OP LEASE

/* -- rmunjulu This piece of logic now resides in seeded formula, so call formula to get value
           -- Get the Off-lease trn value
           FOR get_deprn_cost_rec IN get_deprn_cost_csr (p_kle_id ) LOOP

              l_asset_residual := get_deprn_cost_rec.depreciation_cost;

           END LOOP;
*/
            -- rmunjulu Call the seeded formula to get residual value
            l_params(1).name := 'QUOTE_ID';
            l_params(1).value := l_quote_id;

    	    get_formula_value (
			    	p_formula_name	        => l_formula_name,
			    	p_chr_id	            => p_khr_id,
			    	p_cle_id	            => p_kle_id,
			    	p_additional_parameters => l_params,
			    	x_formula_value	        => l_asset_residual,
			    	x_return_status	        => l_return_status);

		    IF l_asset_residual IS NULL THEN

		      l_asset_residual := 0;
		    END IF;

        ELSIF l_deal_type IN ('LEASEOP') THEN -- OP LEASE

           -- Calculate the Net Book Value for the asset on termination date

           -- Net Book Value = Asset Cost - Accumulated Deprn

           -- Get the deprn amount
           OPEN get_acc_deprn_csr(p_kle_id, l_date_terminated);
           FETCH get_acc_deprn_csr INTO l_deprn_amt;
           IF get_acc_deprn_csr%NOTFOUND THEN
              l_period_open := 'Y';
           END IF;
           CLOSE get_acc_deprn_csr;

           -- if FA Book period is open get it from there
           IF l_period_open = 'Y' THEN
              -- Get the deprn amount
              FOR get_acc_deprn1_rec IN get_acc_deprn1_csr (p_kle_id) LOOP
                 l_deprn_amt :=  get_acc_deprn1_rec.deprn_amt;
              END LOOP;
           END IF;

           -- Get the asset cost
           FOR get_asset_cost_rec IN get_asset_cost_csr (p_kle_id) LOOP
              l_cost :=  get_asset_cost_rec.original_cost;
           END LOOP;

           -- Calculate net book value which will be residual
           l_asset_residual :=  l_cost - l_deprn_amt;

        ELSIF  l_deal_type IN ('LOAN','LOAN-REVOLVING') THEN  -- rmunjulu 4399736

            -- get residual value as the one populated on the quote
            l_asset_residual := l_net_investment;

        ELSE

           l_asset_residual := 0;

        END IF;

     END IF;

     RETURN l_asset_residual;

  EXCEPTION
     WHEN Expected_error THEN
     IF get_acc_deprn_csr%ISOPEN THEN
       CLOSE get_acc_deprn_csr;
     END IF;
     RETURN 0;

     WHEN OTHERS THEN
     IF get_acc_deprn_csr%ISOPEN THEN
       CLOSE get_acc_deprn_csr;
     END IF;
     RETURN 0;

  END get_actual_asset_residual;

  -- Start of comments
  --
  -- Function Name	  : get_anticipated_bill
  -- Description	  : Get anticipated bill total for quote
  -- Business Rules	  : Dependent on new table okl_txd_qte_antcpt_bill
  -- Parameters		  : p_qte_id -- Quote Id
  -- History          : RMUNJULU EDAT CREATED
  -- Version		  : 1.0
  --
  -- End of comments
  FUNCTION get_anticipated_bill (p_qte_id IN NUMBER) RETURN NUMBER IS

     -- get sum of anticipated billing for quote
     CURSOR get_ant_bill_csr(p_qte_id IN NUMBER) IS
     SELECT nvl(sum(tqa.amount),0) amount
     FROM   okl_txd_qte_antcpt_bill tqa
     WHERE  tqa.qte_id = p_qte_id;

     l_ant_bill number;

  BEGIN

    l_ant_bill := 0;

    -- get anticipated billing
    OPEN get_ant_bill_csr(p_qte_id);
    FETCH get_ant_bill_csr INTO l_ant_bill;
    CLOSE get_ant_bill_csr;

    RETURN l_ant_bill;

  EXCEPTION
    WHEN OTHERS THEN
        IF get_ant_bill_csr%ISOPEN THEN
           CLOSE get_ant_bill_csr;
        END IF;
        RETURN 0;

  END get_anticipated_bill;

-- Start of comments
  --
  -- Function Name	  : get_asset_net_book_value
  -- Description	  : Get Net Book value from FA for a particular date
  -- Business Rules	  : Should be for OP/DF/SALES type Lease contract only -- which has FA values
  -- Parameters		  : p_kle_id -- Financial Line Id
  --                    p_transaction_date Date for which you want FA NBV
  -- History          : RMUNJULU 4299668 Created
  --                        nikshah -- Bug # 5484903 Fixed,
  --                                         Changed CURSOR get_acc_deprn1_csr (p_kle_id IN NUMBER) SQL definition
  -- Version		  : 1.0
  --
  -- End of comments
  FUNCTION get_asset_net_book_value (
   p_kle_id           IN  NUMBER,
   p_transaction_date IN  DATE DEFAULT NULL) RETURN NUMBER IS

   -- get accumulated depreciation for the asset on the termination date(AVSINGH)
   -- if the FA book period is closed
   CURSOR get_acc_deprn_csr (p_kle_id IN NUMBER, p_trn_date IN DATE) IS
   SELECT nvl(fds.deprn_reserve,0)  deprn_amt
   FROM   fa_deprn_summary fds,
          fa_deprn_periods fdp,
          fa_book_controls fbc,
          fa_calendar_periods fcp,
          okc_k_items_v itm,
          okc_k_lines_b kle,
          okc_line_styles_v lse
   WHERE  fdp.book_type_code = fds.book_type_code
   AND    fdp.period_counter = fds.period_counter
   AND    fbc.book_class = 'CORPORATE'
   AND    fds.book_type_code = fbc.book_type_code
   AND    fds.asset_id = itm.object1_id1
   AND    itm.cle_id = kle.id
   AND    kle.cle_id = p_kle_id
   AND    kle.lse_id = lse.id
   AND    lse.lty_code = 'FIXED_ASSET'
   AND    fbc.deprn_calendar  = fcp.calendar_type
   AND    fcp.period_name     = fdp.period_name
   AND    TRUNC(p_trn_date) BETWEEN  fcp.start_date AND fcp.end_date;

   -- get accumulated depreciation for the asset on the termination date(AVSINGH)
   -- if the FA Book period is open
   CURSOR get_acc_deprn1_csr (p_kle_id IN NUMBER) IS
   SELECT nvl(fds.deprn_reserve,0)  deprn_amt
   FROM   fa_deprn_summary fds,
          fa_deprn_periods fdp,
          fa_book_controls fbc,
          okc_k_items itm,
          okc_k_lines_b kle,
          okc_line_styles_b lse
   WHERE  fdp.book_type_code = fds.book_type_code
   AND    fdp.period_counter - 1 = fds.period_counter
   AND    fdp.period_close_date IS NULL
   AND    fbc.book_class = 'CORPORATE'
   AND    fds.book_type_code = fbc.book_type_code
   AND    fds.asset_id = itm.object1_id1
   AND    itm.cle_id = kle.id
   AND    kle.cle_id = p_kle_id
   AND    kle.lse_id = lse.id
   AND    lse.lty_code = 'FIXED_ASSET';

   -- get asset cost
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

   l_deprn_amt NUMBER;
   l_cost NUMBER;
   l_period_open VARCHAR2(1);
   l_nbv NUMBER;
   l_return_status VARCHAR2(3);

   Expected_error EXCEPTION;

  BEGIN

     -- Check for data validity
     IF p_kle_id IS NULL OR p_kle_id = OKL_API.G_MISS_NUM THEN

        RAISE Expected_Error;

     END IF;

     l_deprn_amt := 0;
     l_cost := 0;
     l_nbv := 0;

     -- Net Book Value = Asset Cost - Accumulated Deprn
     -- Get the deprn amount for that date
     OPEN get_acc_deprn_csr(p_kle_id, nvl(p_transaction_date,sysdate));
     FETCH get_acc_deprn_csr INTO l_deprn_amt;
     -- if not found then that means the transaction dates period is open
     IF get_acc_deprn_csr%NOTFOUND THEN
         l_period_open := 'Y';
     END IF;
     CLOSE get_acc_deprn_csr;

     -- if FA Book period is open get it from there
     IF nvl(l_period_open,'N') = 'Y' THEN
        -- Get the deprn amount
        OPEN  get_acc_deprn1_csr (p_kle_id);
        FETCH get_acc_deprn1_csr INTO l_deprn_amt;
        CLOSE get_acc_deprn1_csr;
     END IF;

     -- Get the asset cost
     OPEN get_asset_cost_csr (p_kle_id);
     FETCH get_asset_cost_csr INTO l_cost;
     CLOSE get_asset_cost_csr;

     -- Calculate net book value
     l_nbv :=  l_cost - l_deprn_amt;

     RETURN l_nbv;

  EXCEPTION
     WHEN Expected_error THEN
     IF get_acc_deprn_csr%ISOPEN THEN
       CLOSE get_acc_deprn_csr;
     END IF;
     IF get_acc_deprn1_csr%ISOPEN THEN
       CLOSE get_acc_deprn1_csr;
     END IF;
     IF get_asset_cost_csr%ISOPEN THEN
       CLOSE get_asset_cost_csr;
     END IF;
     RETURN NULL;

     WHEN OTHERS THEN
     IF get_acc_deprn_csr%ISOPEN THEN
       CLOSE get_acc_deprn_csr;
     END IF;
     IF get_acc_deprn1_csr%ISOPEN THEN
       CLOSE get_acc_deprn1_csr;
     END IF;
     IF get_asset_cost_csr%ISOPEN THEN
       CLOSE get_asset_cost_csr;
     END IF;
     RETURN NULL;

  END get_asset_net_book_value;

  -- rmunjulu Sales_Tax_Enhancement
  -- This function returns the tax amount for the tax TRX_ID
  -- TRX_ID can be quote_id, ar_inv_trx_id
  FUNCTION get_tax_amount (
   p_tax_trx_id           IN  NUMBER) RETURN NUMBER IS

      --   p_tax_trx_id can be Quote Id, Ar Inv Trx Id
      CURSOR get_tax_amount_csr (p_tax_trx_id IN NUMBER) IS
      SELECT SUM(TAX.tax_amt) tax_amount
        FROM OKL_TAX_SOURCES TXS,
             OKL_TAX_TRX_DETAILS TAX
       WHERE TXS.trx_id = p_tax_trx_id
         AND TAX.txs_id = TXS.id;

     l_tax_amount NUMBER;

   BEGIN

      -- Get the tax amount
      OPEN get_tax_amount_csr (p_tax_trx_id);
      FETCH get_tax_amount_csr INTO l_tax_amount;
      CLOSE get_tax_amount_csr;

      RETURN l_tax_amount;

   EXCEPTION
     WHEN OTHERS THEN
        IF get_tax_amount_csr%ISOPEN THEN
           CLOSE get_tax_amount_csr;
        END IF;
        RETURN null;

   END get_tax_amount;

  -- rmunjulu loans_enhancements get product details
  -- gets the contract product details such as deal type, revenue recognition method,
  -- interest calculation basis and tax owner
  PROCEDURE get_contract_product_details (
   p_khr_id         IN  NUMBER,
   x_deal_type      OUT NOCOPY VARCHAR2,
   x_rev_rec_method OUT NOCOPY VARCHAR2,
   x_int_cal_basis  OUT NOCOPY VARCHAR2,
   x_tax_owner      OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2) IS

   CURSOR get_prd_details_csr (p_khr_id IN NUMBER) IS
   SELECT PQY.NAME QUALITY,
          QVE.VALUE VALUE,
		  KHR.DEAL_TYPE DEAL_TYPE
   FROM   OKL_PDT_PQY_VALS PQV ,
          OKL_PDT_PQYS PDQ ,
		  OKL_PRODUCTS PDT,
		  OKL_PQY_VALUES QVE,
		  OKL_PDT_QUALITYS PQY,
		  OKL_K_HEADERS KHR
   WHERE KHR.ID = p_khr_id
   AND   PQV.PDT_ID = PDT.ID
   AND   PQV.PDQ_ID = PDQ.ID
   AND   PQV.QVE_ID = QVE.ID
   AND   QVE.PQY_ID = PQY.ID
   AND   PDQ.PQY_ID = PQY.ID
   AND   PDT.PTL_ID = PDQ.PTL_ID
   AND   PDT.ID     = KHR.PDT_ID
   AND   PQY.NAME IN ( 'INTEREST_CALCULATION_BASIS', 'REVENUE_RECOGNITION_METHOD', 'TAXOWNER');

  BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     FOR get_prd_details_rec IN get_prd_details_csr(p_khr_id) LOOP
        x_deal_type := get_prd_details_rec.deal_type;
        IF get_prd_details_rec.quality = 'INTEREST_CALCULATION_BASIS' THEN
           x_int_cal_basis := get_prd_details_rec.value;
        ELSIF  get_prd_details_rec.quality = 'REVENUE_RECOGNITION_METHOD' THEN
           x_rev_rec_method := get_prd_details_rec.value;
        ELSIF  get_prd_details_rec.quality = 'TAXOWNER' THEN
           x_tax_owner := get_prd_details_rec.value;
        END IF;
     END LOOP;

     IF x_deal_type IS NULL THEN
	   x_return_status := OKL_API.G_RET_STS_ERROR;
	 END IF;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

	  x_return_status := OKL_API.G_RET_STS_ERROR;

  END get_contract_product_details;

  -- rmunjulu LOANS_ENHANCEMENTS get excess loan payment amount
  FUNCTION get_excess_loan_payment (
   p_khr_id         IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2) RETURN NUMBER IS

    l_loan_refund_amount NUMBER := 0;
    l_deal_type VARCHAR2(300);
    l_rev_rec_method VARCHAR2(300);
	l_int_cal_basis VARCHAR2(300);
	l_tax_owner VARCHAR2(300);

  BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- Get the contract product details
     OKL_AM_UTIL_PVT.get_contract_product_details(
                      p_khr_id           => p_khr_id,
                      x_deal_type        => l_deal_type,
                      x_rev_rec_method   => l_rev_rec_method,
				      x_int_cal_basis    => l_int_cal_basis,
				      x_tax_owner        => l_tax_owner,
				      x_return_status    => x_return_status);

     IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- get refunds only for EstandAct and Act cases
     IF l_deal_type LIKE 'LOAN%'
	 AND l_rev_rec_method IN ('ESTIMATED_AND_BILLED','ACTUAL') THEN

        l_loan_refund_amount := OKL_VARIABLE_INT_UTIL_PVT.get_excess_loan_payment(
                                     x_return_status    => x_return_status,
                                     p_khr_id           => p_khr_id);

        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
	 END IF;
	 RETURN l_loan_refund_amount;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

	  x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN

      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
	  x_return_status := OKL_API.G_RET_STS_ERROR;

  END get_excess_loan_payment;

  -- rmunjulu BUYOUT check full termination transaction being processed.
  -- akrangan changed tsu_code to tmt_status_code
  FUNCTION check_full_term_in_progress (
   p_khr_id         IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

    CURSOR get_termination_trn_csr (p_khr_id IN NUMBER) IS
       SELECT 'Y'
       FROM  DUAL
       WHERE EXISTS (SELECT id
                     FROM   OKL_TRX_CONTRACTS
                     WHERE  khr_id = p_khr_id
                     AND    tmt_status_code NOT IN ('PROCESSED', 'CANCELED') --akrangan changed
		                                                 --tsu_code to tmt_status_code
                     AND    tcn_type IN ('TMT')
                     --rkuttiya added for 12.1.1 Multi GAAP Project
                     AND    representation_type = 'PRIMARY');
                    --

    l_term_in_progress VARCHAR2(3);

  BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     OPEN get_termination_trn_csr (p_khr_id);
     FETCH get_termination_trn_csr INTO l_term_in_progress;
     CLOSE get_termination_trn_csr;

	 RETURN nvl(l_term_in_progress,'N');

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
	  x_return_status := OKL_API.G_RET_STS_ERROR;
	  RETURN NULL;

  END check_full_term_in_progress;
 --asawanka added
  FUNCTION get_latest_alc_tax (
   p_top_line_id  IN  NUMBER) RETURN NUMBER IS

      CURSOR get_tax_amount_csr (cp_top_line_id IN NUMBER) IS
      SELECT tax_amount
        FROM okl_cs_alc_summary_uv
       WHERE dnz_cle_id = cp_top_line_id
       AND   tsu_code = 'PROCESSED';

     l_tax_amount NUMBER;

   BEGIN

      -- Get the tax amount
      OPEN get_tax_amount_csr (p_top_line_id);
      -- FIRST ROW will have latest tax amount for latest processed alc transaction
      FETCH get_tax_amount_csr INTO l_tax_amount;
      IF get_tax_amount_csr%NOTFOUND THEN
        l_tax_amount := NULL;
      END IF;
      CLOSE get_tax_amount_csr;

      RETURN l_tax_amount;

   EXCEPTION
     WHEN OTHERS THEN
        IF get_tax_amount_csr%ISOPEN THEN
           CLOSE get_tax_amount_csr;
        END IF;
        RETURN null;

   END get_latest_alc_tax;
   --asawanka added
   FUNCTION get_latest_alc_req_id (
   p_top_line_id  IN  NUMBER) RETURN NUMBER IS

      CURSOR get_req_id_csr (cp_top_line_id IN NUMBER) IS
      SELECT request_id
        FROM okl_cs_alc_summary_uv
       WHERE dnz_cle_id = cp_top_line_id
       AND   tsu_code = 'PROCESSED';

     l_req_id NUMBER;

   BEGIN

      -- Get the tax amount
      OPEN get_req_id_csr (p_top_line_id);
      -- FIRST ROW will have latest request_id for latest processed alc transaction
      FETCH get_req_id_csr INTO l_req_id;
      IF get_req_id_csr%NOTFOUND THEN
        l_req_id := NULL;
      END IF;
      CLOSE get_req_id_csr;

      RETURN l_req_id;

   EXCEPTION
     WHEN OTHERS THEN
        IF get_req_id_csr%ISOPEN THEN
           CLOSE get_req_id_csr;
        END IF;
        RETURN null;

   END get_latest_alc_req_id;
   --asawanka added, modified zrehman
   FUNCTION get_latest_alc_serialized_flag (
   p_top_line_id  IN  NUMBER) RETURN VARCHAR2 IS

 CURSOR check_item_csr (p_line_id IN NUMBER) IS      -- p_line_id is FREE_FORM1
   SELECT mtl.serial_number_control_code
   FROM   okc_k_lines_b line,
                  okc_line_styles_b style,
                  okc_k_items kitem,
                  mtl_system_items mtl
   WHERE  line.lse_id                    = style.id
   AND    style.lty_code                 = 'ITEM'
   AND    line.id                        = kitem.cle_id
   AND    kitem.jtot_object1_code        = 'OKX_SYSITEM'
   AND    kitem.object1_id1              = mtl.inventory_item_id
   AND    kitem.object1_id2              = TO_CHAR(mtl.organization_id)
   AND    line.cle_id                    = p_line_id;
     l_count NUMBER :=0;

     l_ser_flg VARCHAR2(3);

   BEGIN

   OPEN check_item_csr(p_top_line_id);
   FETCH check_item_csr INTO l_count;
   CLOSE check_item_csr;

   IF l_count = 1 THEN
     l_ser_flg := 'N';
   ELSE
     l_ser_flg := 'Y';

   END IF;
   RETURN l_ser_flg;

   EXCEPTION
     WHEN OTHERS THEN
        IF check_item_csr%ISOPEN THEN
           CLOSE check_item_csr;
        END IF;
        RETURN null;

   END get_latest_alc_serialized_flag;
   --asawanka added
   FUNCTION get_latest_alc_eff_date (
   p_top_line_id  IN  NUMBER) RETURN DATE IS

      CURSOR get_eff_Date_csr (cp_top_line_id IN NUMBER) IS
      SELECT DATE_EFFECTIVE
        FROM okl_cs_alc_summary_uv
       WHERE dnz_cle_id = cp_top_line_id
       AND   tsu_code = 'PROCESSED';

     l_eff_date DATE;

   BEGIN

      -- Get the effective date
      OPEN get_eff_Date_csr (p_top_line_id);
      -- FIRST ROW will have latest effective date for latest processed alc transaction
      FETCH get_eff_Date_csr INTO l_eff_date;
      IF get_eff_Date_csr%NOTFOUND THEN
        l_eff_date := NULL;
      END IF;
      CLOSE get_eff_Date_csr;

      RETURN l_eff_date;

   EXCEPTION
     WHEN OTHERS THEN
        IF get_eff_Date_csr%ISOPEN THEN
           CLOSE get_eff_Date_csr;
        END IF;
        RETURN null;

   END get_latest_alc_eff_date;
     --asawanka added
   FUNCTION get_latest_alc_req_sts (
   p_top_line_id  IN  NUMBER) RETURN VARCHAR2 IS

      CURSOR get_req_sts_csr (cp_top_line_id IN NUMBER) IS
      SELECT TSU_CODE
        FROM okl_cs_alc_summary_uv
       WHERE dnz_cle_id = cp_top_line_id;

     l_req_sts VARCHAR2(30);

   BEGIN

      -- Get the status
      OPEN get_req_sts_csr (p_top_line_id);
      -- FIRST ROW will have latest request_sts
      FETCH get_req_sts_csr INTO l_req_sts;
      IF get_req_sts_csr%NOTFOUND THEN
        l_req_sts := NULL;
      END IF;
      CLOSE get_req_sts_csr;

      RETURN l_req_sts;

   EXCEPTION
     WHEN OTHERS THEN
        IF get_req_sts_csr%ISOPEN THEN
           CLOSE get_req_sts_csr;
        END IF;
        RETURN null;

   END get_latest_alc_req_sts;

-- added by zrehman to get TRX_ID for Non-Serialized Asset
FUNCTION get_latest_alc_trx_id (
        p_top_line_id  IN  NUMBER) RETURN NUMBER IS

      CURSOR get_trx_id_csr (cp_top_line_id IN NUMBER) IS
      SELECT   trx.Id
      FROM     Okl_trx_Assets trx,
               Okl_txl_Itm_Insts txl,
               Okl_trx_Types_v Try
      WHERE    trx.Id = txl.tAs_Id
      AND trx.Try_Id = Try.Id
      AND Try.NAME = 'Asset Relocation'
      AND trx.tsu_code = 'PROCESSED'
      AND txl.dnz_cle_id = cp_top_line_id
      ORDER BY trx.Date_tRans_OccurRed DESC;
     l_trx_id NUMBER := NULL;
     l_ser_flg VARCHAR2(3);

   BEGIN
      -- Get whether is serialized or not
      l_ser_flg := get_latest_alc_serialized_flag(p_top_line_id);
      IF (l_ser_flg IS NOT null AND l_ser_flg <> 'Y' ) THEN
        OPEN get_trx_id_csr(p_top_line_id);
	FETCH get_trx_id_csr INTO l_trx_id;
	CLOSE get_trx_id_csr;
      END IF;

      RETURN l_trx_id;

   EXCEPTION
     WHEN OTHERS THEN
        IF get_trx_id_csr%ISOPEN THEN
           CLOSE get_trx_id_csr;
        END IF;
        RETURN null;

   END get_latest_alc_trx_id;

 -- rbruno bug 6185552 start
 -- Start of comments
 -- Function Name	  : get_fa_nbv
 -- Description	  : Get Net Book value per unit from FA for a particular asset
 -- End of comments

  FUNCTION get_fa_nbv (
    p_chr_id   IN OKC_K_HEADERS_B.ID%TYPE
   ,p_asset_id IN  NUMBER
   ) RETURN NUMBER IS

  CURSOR get_rel_date(p_khr_id IN NUMBER) IS
       SELECT start_date
       FROM  okc_k_headers_b
       WHERE id = p_khr_id;

  CURSOR get_book_type_code(p_ast_id IN NUMBER) IS
     SELECT fbc.book_type_code
     FROM   fa_deprn_summary fds,
            fa_book_controls fbc
     WHERE  fbc.book_class = 'CORPORATE'
     AND    fds.book_type_code = fbc.book_type_code
     AND    fds.asset_id = p_ast_id
     and    rownum = 1;

   CURSOR get_asset_units(p_ast_id IN NUMBER) IS
       SELECT CURRENT_UNITS
       FROM  fa_additions
       WHERE asset_id = p_ast_id;

    l_book_type_code   fa_book_controls.book_type_code%TYPE;
    rel_date         DATE;
    l_units          NUMBER  := 0;

    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_msg_count       NUMBER := OKL_API.G_MISS_NUM;
    x_msg_data        VARCHAR(2000);
    l_api_name        CONSTANT VARCHAR2(30) := 'GET_NBV';
    l_api_version	    CONSTANT NUMBER	:= 1.0;
    l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
    l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
    l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;
    l_nbv                      NUMBER;
    l_converted_amount         NUMBER;
    l_contract_currency        OKL_K_HEADERS_FULL_V.currency_code%TYPE;
    l_currency_conversion_type OKL_K_HEADERS_FULL_V.currency_conversion_type%TYPE;
    l_currency_conversion_rate OKL_K_HEADERS_FULL_V.currency_conversion_rate%TYPE;
    l_currency_conversion_date OKL_K_HEADERS_FULL_V.currency_conversion_date%TYPE;
    p_init_msg_list VARCHAR(1) := 'T';

  BEGIN
   IF p_chr_id IS NULL OR p_chr_id = OKL_API.G_MISS_NUM THEN
      OKL_API.set_message (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_INVALID_VALUE1
			,p_token1	=> 'COL_NAME'
			,p_token1_value	=> 'Contract Id');

       Raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_asset_id IS NULL OR p_asset_id = OKL_API.G_MISS_NUM THEN
        OKL_API.set_message (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_INVALID_VALUE1
			,p_token1	=> 'COL_NAME'
			,p_token1_value	=> 'Asset Id');

        Raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

  open get_rel_date(p_chr_id);
  fetch get_rel_date into rel_date;
  close get_rel_date;

  open get_book_type_code(p_asset_id);
  fetch get_book_type_code into l_book_type_code;
  close get_book_type_code ;

  open get_asset_units(p_asset_id);
  fetch get_asset_units into l_units;
  close get_asset_units;

     l_asset_hdr_rec.asset_id          := p_asset_id;
     l_asset_hdr_rec.book_type_code    := l_book_type_code;

     if NOT fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code) then
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_CACHE_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
     end if;

     -- To fetch Asset Current Cost
     if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec         => l_asset_hdr_rec,
               px_asset_fin_rec        => l_asset_fin_rec,
               p_transaction_header_id => NULL,
               p_mrc_sob_type_code     => 'P'
              ) then

       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_ASSET_FIN_REC_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
     end if;

     -- To fetch Depreciation Reserve
     if not FA_UTIL_PVT.get_asset_deprn_rec
                (p_asset_hdr_rec         => l_asset_hdr_rec ,
                 px_asset_deprn_rec      => l_asset_deprn_rec,
                 p_period_counter        => NULL,
                 p_mrc_sob_type_code     => 'P'
                 ) then
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_DEPRN_REC_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
     end if;

     l_nbv := l_asset_fin_rec.cost - l_asset_deprn_rec.deprn_reserve;

     l_converted_amount := 0;
     OKL_ACCOUNTING_UTIL.CONVERT_TO_CONTRACT_CURRENCY(
        p_khr_id                   => p_chr_id,
        p_from_currency            => NULL,
        p_transaction_date         => rel_date,
        p_amount                   => l_nbv,
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

      l_nbv := l_converted_amount;
        if (l_units > 1) then
            l_nbv := l_nbv/l_units;
        end if;

      RETURN l_nbv;
     --Call end Activity
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION

    WHEN OTHERS THEN
      null;
   END get_fa_nbv;
--rbruno bug 6185552 end

END OKL_AM_UTIL_PVT;

/
