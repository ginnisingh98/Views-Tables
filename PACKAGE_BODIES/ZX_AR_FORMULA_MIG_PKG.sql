--------------------------------------------------------
--  DDL for Package Body ZX_AR_FORMULA_MIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_AR_FORMULA_MIG_PKG" AS
/* $Header: zxarformulamigb.pls 120.16.12010000.3 2009/08/03 10:34:42 ssanka ship $ */

PROCEDURE FORMULA_MIGRATION_MAIN
(x_return_status     OUT NOCOPY  VARCHAR2) IS
i number;

l_child_taxable_basis		ar_vat_tax_all.taxable_basis%TYPE;
l_tax_code			ar_vat_tax_all.tax_code%TYPE;
l_enabled_flag			ar_vat_tax_all.enabled_flag%TYPE;
l_start_date			ar_vat_tax_all.start_date%TYPE;
l_end_date			ar_vat_tax_all.end_date%TYPE;
l_tax_constraint_id		ar_vat_tax_all.tax_constraint_id%TYPE;

l_tax				zx_rates_b.tax%TYPE;
l_tax_regime_code		zx_rates_b.tax_regime_code%TYPE;

l_content_owner_id		zx_tax_relations_t.content_owner_id%TYPE;
l_group_id			zx_tax_relations_t.tax_group_id%TYPE;
l_tax_group_code		zx_tax_relations_t.tax_group_code%TYPE;
l_parent_tax_code		zx_tax_relations_t.parent_tax_code %TYPE;
l_parent_precedence		zx_tax_relations_t.parent_precedence%TYPE;
l_parent_regime_code		zx_tax_relations_t.parent_regime_code %TYPE;
l_child_tax_code		zx_tax_relations_t.child_tax_code %TYPE;
l_child_precedence		zx_tax_relations_t.child_precedence%TYPE;
l_child_regime_code		zx_tax_relations_t.child_regime_code %TYPE;
l_branch			zx_tax_relations_t.branch_flag%TYPE;

l_tax_condition_id		ar_tax_group_codes_all.tax_condition_id%TYPE;
l_tax_exception_id		ar_tax_group_codes_all.tax_exception_id%TYPE;
l_tax_group_id			ar_tax_group_codes_all.tax_group_id%TYPE;


l_formula_code 			zx_formula_b.formula_code%TYPE;

l_discount_flag			CHAR;
l_charge_flag			CHAR;

l_alphanumeric_result		zx_process_results.alphanumeric_result%TYPE;

g_group_id			zx_tax_relations_t.tax_group_id%TYPE;
g_child_tax_code		zx_tax_relations_t.child_tax_code%TYPE;
g_child_regime_code		zx_tax_relations_t.child_regime_code%TYPE;

l_condition_grp_id		zx_condition_groups_b.condition_group_id%TYPE;
l_condition_grp_cd		zx_condition_groups_b.condition_group_code%TYPE;

x_msg_data			VARCHAR2(30);



--(case 1 cur)-----------------------------------
-- Tax codes with taxable basis 'AFTER_EPD' or 'QUANTITY' and tax_class 'O' and which do not have tax_type = 'TAX_GROUP'
-- added join with zx_rates to fetch tax, tax_regime_code
-- which are passed to create_rules()
CURSOR 	get_tax_cur IS
	SELECT	vat.taxable_basis	,
		vat.tax_code		,
		vat.enabled_flag	,
		vat.start_date		,
		vat.end_date		,
		rate.tax		,
		rate.tax_regime_code	,
		rate.content_owner_id
	FROM	ar_vat_tax_all vat, zx_rates_b rate
	WHERE 	vat.taxable_basis IN ('AFTER_EPD', 'QUANTITY')
	AND 	vat.tax_class = 'O'
	AND	vat.tax_type <> 'TAX_GROUP'
	AND 	vat.vat_tax_id = NVL(rate.source_id, rate.tax_rate_id);





--(case 3 cur)-----------------------------------
-- Tax groups which have compounding precedence but do not have compounding branches
CURSOR 	get_taxgrp_cur IS
	SELECT 	tax_rel_upg.tax_group_id		,
		tax_rel_upg.tax_group_code	,
		zx_par_rate.tax	                ,  -- 8726049
		tax_rel_upg.parent_precedence	,
		tax_rel_upg.parent_regime_code	,
		tax_rel_upg.child_tax_code	,
		tax_rel_upg.child_precedence	,
		tax_rel_upg.child_regime_code	,
		tax_rel_upg.child_taxable_basis	,
		tax_rel_upg.branch_flag		,
		tax_rel_upg.content_owner_id	,
		grp.enabled_flag		, -- for create_formula() and create_rules()
		grp.start_date			, -- for create_rules
		grp.end_date			, -- for create_rules
		grp.tax_condition_id		,
		grp.tax_exception_id		,
		grp.tax_group_id		,
		zx_rate.tax_regime_code		,
		zx_rate.tax
	FROM 	zx_tax_relations_t tax_rel_upg, ar_tax_group_codes_all grp, zx_rates_b zx_rate,
	        zx_rates_b zx_par_rate  -- 8726049
	WHERE 	tax_rel_upg.tax_group_id NOT IN (SELECT	tax_group_id
				 		FROM  	zx_tax_relations_t
				 		WHERE 	TRUNC(child_precedence) <> child_precedence )
	AND	grp.tax_group_id = tax_rel_upg.tax_group_id
	AND 	grp.tax_code_id = NVL(zx_rate.source_id, zx_rate.tax_rate_id)
	AND 	grp.tax_code_id = tax_rel_upg.child_tax_code_id		--* new condition added
	AND     tax_rel_upg.parent_tax_code_id = NVL(zx_par_rate.source_id, zx_par_rate.tax_rate_id) -- 8726049
	ORDER BY tax_rel_upg.tax_group_id, child_precedence DESC;

--(case 4 cur)-----------------------------------
-- Tax groups which have compounding branches
CURSOR 	get_taxgrp_cmp_cur IS

	SELECT	tax_rel_upg.tax_group_id		,
		tax_rel_upg.tax_group_code	,
		zx_par_rate.tax	                , -- 8726049
		tax_rel_upg.Parent_precedence	,
		tax_rel_upg.Parent_regime_code	,
		tax_rel_upg.Child_tax_code	,
		tax_rel_upg.Child_precedence	,
		tax_rel_upg.Child_regime_code	,
		tax_rel_upg.Child_Taxable_basis	,
		tax_rel_upg.branch_flag		,
		tax_rel_upg.content_owner_id	,
		grp.enabled_flag		,
		grp.start_date			,
		grp.end_date			,
		grp.tax_condition_id		,
		grp.tax_exception_id		,
		grp.tax_group_id		,
		zx_rate.tax_regime_code		,
		zx_rate.tax
	FROM	zx_tax_relations_t tax_rel_upg, ar_tax_group_codes_all grp, zx_rates_b zx_rate,
	        zx_rates_b zx_par_rate  -- 8726049
	WHERE 	tax_rel_upg.tax_group_id IN (SELECT tax_group_id
					 FROM  	zx_tax_relations_t
					 WHERE 	child_precedence > TRUNC(child_precedence) )
	AND	grp.tax_group_id = tax_rel_upg.tax_group_id
	AND 	grp.tax_code_id = NVL(zx_rate.source_id, zx_rate.tax_rate_id)
	AND 	grp.tax_code_id = tax_rel_upg.child_tax_code_id
	AND     tax_rel_upg.parent_tax_code_id = NVL(zx_par_rate.source_id, zx_par_rate.tax_rate_id) -- 8726049
	ORDER BY tax_rel_upg.tax_group_id, child_precedence DESC;



/****************(dropped this hierarchical query)********************
	SELECT	group_id		,
		tax_group_code		,
		Parent_tax_code		,
		Parent_precedence	,
		Parent_regime_code	,
		Child_tax_id		,
		Child_tax_code		,
		Child_precedence	,
		Child_regime_code	,
		Child_Taxable_basis	,
		branch			,
		content_owner_id
	FROM	zx_tax_relations_t
--	START WITH Parent_Regime_code IS NULL				--* changed crsr
	CONNECT BY PRIOR child_tax_code = parent_Tax_code
	ORDER BY group_id, child_tax_code, child_precedence DESC;
*/

-- for conflicting tax groups---------------------

BEGIN

arp_util_tax.debug('ZX_AR_FORMULA_MIG_PKG.FORMULA_MIGRATION_MAIN(+)');

--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Case 1 Tax Codes in AR_VAT_TAX

OPEN get_tax_cur;
i := 0;
arp_util_tax.debug('CASE 1: open cursor');

LOOP

arp_util_tax.debug('i='||i);
i := i+1;

	FETCH get_tax_cur INTO
		l_child_taxable_basis	,
		l_tax_code		,
		l_enabled_flag		,
		l_start_date		,
		l_end_date		,
		l_tax			,
		l_tax_regime_code	,
		l_content_owner_id	;


	-- Check if the condition group code exists with condition group code as follows
	-- if exists populate it in local variables

	l_condition_grp_cd := NULL;
	l_condition_grp_id := NULL;

	arp_util_tax.debug('case1:l_child_taxable_basis:'||l_child_taxable_basis);
	arp_util_tax.debug('case1:l_tax_code:'||l_tax_code);
	arp_util_tax.debug('case1:l_tax:'||l_tax);
	arp_util_tax.debug('case1:l_tax_regime_code:'||l_tax_regime_code);
	arp_util_tax.debug('case1:l_content_owner_id:'||l_content_owner_id);


	arp_util_tax.debug('CASE 1: before select');


        BEGIN

		SELECT 	condition_group_id, condition_group_code
		INTO	l_condition_grp_id, l_condition_grp_cd
		FROM 	zx_condition_groups_b
		WHERE 	condition_group_code = l_tax_code;


	EXCEPTION WHEN OTHERS THEN
		arp_util_tax.debug('Case1: error for tax '||l_tax_code||' Error:'||sqlerrm);
		x_return_status := FND_API.G_RET_STS_ERROR;
	END;


	arp_util_tax.debug('case1:l_condition_grp_id:'||l_condition_grp_id);
	arp_util_tax.debug('case1:l_condition_grp_cd:'||l_condition_grp_cd);

     	IF l_child_taxable_basis = 'AFTER_EPD' THEN

		l_alphanumeric_result := 'STANDARD_TB_DISCOUNT';

	ELSIF l_child_taxable_basis = 'QUANTITY' THEN

		l_alphanumeric_result := 'STANDARD_QUANTITY';

	END IF;



	IF (l_child_taxable_basis = 'AFTER_EPD' OR l_child_taxable_basis = 'QUANTITY')
		AND (l_condition_grp_cd IS NOT NULL) THEN

		arp_util_tax.debug('CASE 1: in if.before create_rules');

		create_rules (	l_tax			,
				l_tax_regime_code	,
				l_start_date		,
				l_end_date		,
				l_enabled_flag		,
				l_content_owner_id	,
				l_condition_grp_cd	,
				l_alphanumeric_result	, --'STANDARD_TB_DISCOUNT' or 'STANDARD_QUANTITY'
				l_condition_grp_id	,
				NULL			,-- for tax_condition_id
				NULL			, -- for tax_exception_id
				x_msg_data
				);
		arp_util_tax.debug('CASE 1:after create_rules');
	END IF;

	IF l_child_taxable_basis = 'PL/SQL formula' THEN

		-- open issue
		NULL;

	END IF;

	EXIT WHEN get_tax_cur%NOTFOUND;

END LOOP;

CLOSE get_tax_cur;


-- Case 2 Tax Groups, which have, null precedence
/**********************(This case is not required)***************/


-- Case 3 Tax groups, which have compounding precedence but do not have compounding branches
arp_util_tax.debug('ZX_AR_FORMULA_MIG_PKG.fORMULA_MIGRATION_MAIN()--> in CASE 3');
i:=0	;
OPEN get_taxgrp_cur;

 -- Assigning variable g_tax_group to null
 g_group_id := NULL;

LOOP

	FETCH get_taxgrp_cur INTO
		l_group_id		,
		l_tax_group_code	,
		l_parent_tax_code	,
		l_parent_precedence	,
		l_parent_regime_code	,
		l_child_tax_code	,
		l_child_precedence	,
		l_child_regime_code	,
		l_child_taxable_basis	,
		l_branch		,
		l_content_owner_id	,
		l_enabled_flag		,
		l_start_date		,
		l_end_date		,
		l_tax_condition_id	,
		l_tax_exception_id	,
		l_tax_group_id		,
		l_tax_regime_code	,
		l_tax			;

	--(for precedence 1, there is no need for formula, we can use the STANDARD_TB formula)
	-- so working for precedence <> 1

	arp_util_tax.debug('i='||i);
	arp_util_tax.debug('l_group_id'||l_group_id);
	arp_util_tax.debug('l_tax_group_code '||l_tax_group_code);
	arp_util_tax.debug('l_parent_tax_code '||l_parent_tax_code);
	arp_util_tax.debug('l_parent_precedence '||l_parent_precedence);
	arp_util_tax.debug('l_parent_regime_code '||l_parent_regime_code);
	arp_util_tax.debug('l_child_tax_code '||l_child_tax_code );
	arp_util_tax.debug('l_child_precedence '||l_child_precedence );
	arp_util_tax.debug('l_child_regime_code '||l_child_regime_code);
	arp_util_tax.debug('l_child_taxable_basis '||l_child_taxable_basis);
	arp_util_tax.debug('l_branch '||l_branch);
	arp_util_tax.debug('l_enabled_flag '||l_enabled_flag);
	arp_util_tax.debug('l_start_date '||l_start_date);
	arp_util_tax.debug('l_end_date '||l_end_date);
	arp_util_tax.debug('l_tax_condition_id '||l_tax_condition_id);
	arp_util_tax.debug('l_tax_exception_id '||l_tax_exception_id);
	arp_util_tax.debug('l_content_owner_id '||l_content_owner_id);
	arp_util_tax.debug('l_tax_regime_code  '||l_tax_regime_code);
	arp_util_tax.debug('l_tax '||l_tax);
	i := i+1;

	IF l_child_precedence <> 1 THEN

		SELECT DECODE( SIGN( LENGTH(l_tax_group_code||'_'||l_child_tax_code||'_TB') - 30),
				1,
				SUBSTRB(l_tax_group_code||'_'||l_child_tax_code,1,24) ||'_TB'||ZX_MIGRATE_UTIL.GET_NEXT_SEQID('ZX_FORMULA_B_S'),
				l_tax_group_code||'_'||l_child_tax_code||'_TB')
		INTO	l_formula_code
		FROM 	DUAL;

		-- For width Issue (formula_code is VARCHAR2(30) only)

		arp_util_tax.debug('case 3:l_formula_code:'||l_formula_code);

		l_charge_flag	:= 'N';

		IF l_child_taxable_basis  = 'AFTER_EPD' THEN
			-- If the taxable_basis is After Discount then set the
			-- flag 'Discounts' in Formula header to Y.
			l_discount_flag	:= 'Y';
		ELSE

			l_discount_flag	:= 'N';

		END IF;

		arp_util_tax.debug('case 3:before create_formula');

		create_formula (l_child_taxable_basis	, -- values can be equal to or <> to 'PRIOR_TAX'
				l_formula_code		,
				l_child_regime_code	,
				l_child_tax_code	,
				l_enabled_flag		,
				l_discount_flag		,
				l_charge_flag		,
				l_parent_regime_code	,
				l_parent_tax_code	,
				l_group_id		,
				l_content_owner_id	,
				l_start_date		,
				l_end_date		,
				l_tax_regime_code	,
				l_tax			,
				x_msg_data
				);

		arp_util_tax.debug('case 3:after create_formula');

		-- For creation of rules


		--Check if the condition group code exists with condition group code as follows
		-- if exists populate it in local variables

		l_condition_grp_cd := NULL;
		l_condition_grp_id := NULL;


		BEGIN
			arp_util_tax.debug('case 3:bef select');

			SELECT  vat.tax_constraint_id
			INTO    l_tax_constraint_id
			FROM    ar_vat_tax_all vat
			WHERE   vat.vat_tax_id = l_tax_group_id;

			SELECT 	condition_group_id, condition_group_code
			INTO	l_condition_grp_id, l_condition_grp_cd
			FROM 	zx_condition_groups_b
			WHERE 	condition_group_code = l_tax_group_code|| decode(l_tax_constraint_id,NULL, '', '~'||l_tax_constraint_id);


		EXCEPTION WHEN OTHERS THEN
			arp_util_tax.debug('Case 3:error for tax '||l_child_tax_code||' error:'||sqlerrm);
			x_return_status := FND_API.G_RET_STS_ERROR;

		END;

		-- result of taxable basis det is l_formula_code determined just before create_formula()
		l_alphanumeric_result := l_formula_code;



		IF l_condition_grp_cd IS NOT NULL THEN

		arp_util_tax.debug('case 3:before create_rules ');
			create_rules (	l_tax			,
					l_tax_regime_code	,
					l_start_date		,
					l_end_date		,
					l_enabled_flag		,
					l_content_owner_id	,
					l_condition_grp_cd	,
					l_alphanumeric_result	,-- l_formula_code
					l_condition_grp_id	,
					l_tax_condition_id	,-- for tax_condition_id
					l_tax_exception_id	,-- for tax_exception_id
					x_msg_data
					);
		END IF;

		arp_util_tax.debug('case 3: ');
	END IF;
EXIT WHEN get_taxgrp_cur%NOTFOUND;
END LOOP;

CLOSE get_taxgrp_cur;







-- Case 4 Tax groups which have compounding branches


OPEN get_taxgrp_cmp_cur;

i:=0;
arp_util_tax.debug('case 4: IN CASE4');
 -- Assigning variable g_group_id to null
 g_group_id 		:= NULL;
 g_child_tax_code	:= NULL;
 g_child_regime_code	:= NULL;

LOOP

arp_util_tax.debug('case 4: i='||i);
i := i+1;

	FETCH get_taxgrp_cmp_cur INTO
		l_group_id		,
		l_tax_group_code	,
		l_parent_tax_code	,
		l_parent_precedence	,
		l_parent_regime_code	,
		l_child_tax_code	,
		l_child_precedence	,
		l_child_regime_code	,
		l_child_taxable_basis	,
		l_branch		,
		l_content_owner_id	,
		l_enabled_flag 		,
		l_start_date		,
		l_end_date		,
		l_tax_condition_id	,
		l_tax_exception_id	,
		l_tax_group_id		,
		l_tax_regime_code	,
		l_tax;



	arp_util_tax.debug('case 4: l_group_id:'||l_group_id);
	arp_util_tax.debug('case 4: l_child_tax_code:'||l_child_tax_code);
	arp_util_tax.debug('case 4: l_child_regime_code:'||l_child_regime_code);
	arp_util_tax.debug('case 4: l_child_precedence:'||l_child_precedence);



	--Assigning value for new group
	IF l_group_id <> g_group_id THEN
		arp_util_tax.debug('case 4:in if g_group_id IS NULL->'||g_group_id);
		g_group_id := l_group_id;
	END IF;

	arp_util_tax.debug('case 4:g_group_id:'||g_group_id);
	arp_util_tax.debug('case 4:g_child_tax_code:'||g_child_tax_code);
 	arp_util_tax.debug('case 4:g_child_regime_code:'||g_child_regime_code);

	IF 	(l_group_id = g_group_id) AND
	   	(l_child_tax_code = g_child_tax_code) AND
	   	(l_child_regime_code = g_child_regime_code) THEN

		-- formula and formula details are already created for this childtax
		-- when the previous row was processed. process the next row
			arp_util_tax.debug('case 4: 1st if');
			NULL;

	-- added OR condition "g_group_id IS NULL" in ELSIF
	-- for running the first record of cursor
	ELSIF 	(l_group_id = g_group_id OR g_group_id IS NULL)
		AND ((l_child_tax_code <> g_child_tax_code)
		OR  (g_child_tax_code IS NULL AND g_child_regime_code IS NULL)) THEN

		-- If taxgroup is the same as previous taxgroup but child tax and child regime is different
		-- from previous childtax. hence create a formula header

		arp_util_tax.debug('case 4: 2nd if');

		l_condition_grp_cd := NULL;
		l_condition_grp_id := NULL;


		BEGIN

			arp_util_tax.debug('case 4:before select of cond grp');

			SELECT  vat.tax_constraint_id
			INTO    l_tax_constraint_id
			FROM    ar_vat_tax_all vat
			WHERE   vat.vat_tax_id = l_tax_group_id;

			SELECT 	condition_group_id, condition_group_code
			INTO	l_condition_grp_id, l_condition_grp_cd
			FROM 	zx_condition_groups_b
			WHERE 	condition_group_code = l_tax_group_code|| decode(l_tax_constraint_id,NULL, '', '~'||l_tax_constraint_id);

		EXCEPTION WHEN OTHERS THEN
			arp_util_tax.debug('Case 4:error for tax '||l_child_tax_code||' error:'||sqlerrm);
			x_return_status := FND_API.G_RET_STS_ERROR;

		END;

		arp_util_tax.debug('Case 4:l_condition_grp_id->'||l_condition_grp_id);
		arp_util_tax.debug('Case 4:l_condition_grp_cd->'||l_condition_grp_cd);

		IF l_child_taxable_basis  = 'PRIOR_TAX' THEN
			-- the taxable_basis_type in the formula will be prior_tax and
			-- there will be only one record in the Formula Details
			-- which will be that of the ParentRegime / ParentTax.

			SELECT DECODE(SIGN(LENGTH(l_tax_group_code||'_'||l_child_tax_code||'_TB') - 30),
					1,
					SUBSTRB(l_tax_group_code||'_'||l_child_tax_code,1,24) ||'_TB'||ZX_MIGRATE_UTIL.GET_NEXT_SEQID('ZX_FORMULA_B_S' ),
					l_tax_group_code||'_'||l_child_tax_code||'_TB')
			INTO	l_formula_code
			FROM 	DUAL;

			arp_util_tax.debug('case 4: l_formula_code1'||l_formula_code);


			l_discount_flag	:= 'N';
			l_charge_flag	:= 'N';

			arp_util_tax.debug('Case 4:before create_formula');

			create_formula (l_child_taxable_basis	,
					l_formula_code		,
					l_child_regime_code	,
					l_child_tax_code	,
					l_enabled_flag		,
					l_discount_flag		,
					l_charge_flag		,
					l_parent_regime_code	,
					l_parent_tax_code	,
					l_group_id		,
					l_content_owner_id	,
					l_start_date		,
					l_end_date		,
					l_tax_regime_code	,
					l_tax			,
					x_msg_data
					);

			arp_util_tax.debug('Case 4:after create_formula');

			l_alphanumeric_result := l_formula_code;

			IF l_condition_grp_cd IS NOT NULL THEN

				arp_util_tax.debug('Case 4:before create_rules');

				create_rules (	l_tax			,
						l_tax_regime_code	,
						l_start_date		,
						l_end_date		,
						l_enabled_flag		,
						l_content_owner_id	,
						l_condition_grp_cd	,
						l_alphanumeric_result	,-- l_formula_code
						l_condition_grp_id	,
						l_tax_condition_id	,-- for tax_condition_id
						l_tax_exception_id	,-- for tax_exception_id
						x_msg_data
						);
			END IF;


			arp_util_tax.debug('Case 4:after create_rules');

		ELSIF l_child_taxable_basis  <> 'PRIOR_TAX' THEN
			-- then create formula header with taxable basis type as LineAmount.
			-- INSERT INTO zx_formula_b with taxable_basis_type = 'LINE_AMOUNT';
			-- it is in decode of create_formula()

			SELECT DECODE(SIGN(LENGTH(l_tax_group_code||'_'||l_child_tax_code||'_TB') - 30),
					1,
					SUBSTRB(l_tax_group_code||'_'||l_child_tax_code,1,24) ||'_TB'||ZX_MIGRATE_UTIL.GET_NEXT_SEQID('ZX_FORMULA_B_S' ),
					l_tax_group_code||'_'||l_child_tax_code||'_TB')
			INTO	l_formula_code
			FROM 	DUAL;

			l_discount_flag	:= 'N';
			l_charge_flag	:= 'N';

			arp_util_tax.debug('case 4: l_formula_code2'||l_formula_code);

			IF l_child_taxable_basis  = 'AFTER_EPD' THEN

				-- If the taxable_basis is After Discount then set the
				-- flag 'Discounts' in Formula header to Y.

				l_discount_flag	:= 'Y';


			END IF; -- end l_taxable_basis  = 'AFTER_EPD'


			arp_util_tax.debug('Case 4:before create_formula');
			create_formula (l_child_taxable_basis	,
					l_formula_code		,
					l_child_regime_code	,
					l_child_tax_code	,
					l_enabled_flag		,
					l_discount_flag		,
					l_charge_flag		,
					l_parent_regime_code	,
					l_parent_tax_code	,
					l_group_id		,
					l_content_owner_id	,
					l_start_date		,
					l_end_date		,
					l_tax_regime_code	,
					l_tax			,
					x_msg_data
					);


			arp_util_tax.debug('Case 4:after create_formula');




			l_alphanumeric_result := l_formula_code;

			IF l_condition_grp_cd IS NOT NULL THEN

				arp_util_tax.debug('Case 4:before create_rules');

				create_rules (	l_tax			,
						l_tax_regime_code	,
						l_start_date		,
						l_end_date		,
						l_enabled_flag		,
						l_content_owner_id	,
						l_condition_grp_cd	,
						l_alphanumeric_result	,-- l_formula_code
						l_condition_grp_id	,
						l_tax_condition_id	,-- for tax_condition_id
						l_tax_exception_id	,-- for tax_exception_id
						x_msg_data
						);
			END IF;

		arp_util_tax.debug('Case 4:after create_rules');
		END IF;  --end l_taxable_basis  = 'PRIOR_TAX'

		arp_util_tax.debug('Case 4:aftr end if of --> l_taxable_basis ');

	END IF;

	-- Assigning values to variables
	g_group_id 		:= l_group_id;
	g_child_tax_code 	:= l_child_tax_code;
	g_child_regime_code 	:= l_child_regime_code;

	EXIT WHEN get_taxgrp_cmp_cur%NOTFOUND;


END LOOP; -- end Main Loop

CLOSE get_taxgrp_cmp_cur;

arp_util_tax.debug('LAST');

EXCEPTION WHEN OTHERS THEN

	x_return_status := FND_API.G_RET_STS_ERROR;

END FORMULA_MIGRATION_MAIN;


/****************************************************************************************
*	Procedure: CREATE_FORMULA	                                        	*
*	Based on the input parameters, row(s) would be created in to ,	*
*    ZX_FORMULA_TL and ZX_FORMULA_DETAILS.			    			*
*****************************************************************************************/


PROCEDURE CREATE_FORMULA
		(--for zx_formula_b
		p_taxable_basis		IN	ar_vat_tax_all.taxable_basis%TYPE,
		p_formula_code		IN	zx_formula_b.formula_code%TYPE,
		p_child_regime_code	IN	zx_tax_relations_t.child_regime_code %TYPE,
		p_child_tax_code	IN	zx_tax_relations_t.child_tax_code %TYPE,
		p_enabled_flag		IN	ar_vat_tax_all.enabled_flag%TYPE,
		p_discount_flag		IN	CHAR,
		p_charge_flag		IN	CHAR,
		-- for zx_formula_details
		p_parent_regime_code	IN	zx_tax_relations_t.parent_regime_code %TYPE,
		p_parent_tax_code	IN	zx_tax_relations_t.parent_tax_code %TYPE,
		p_group_id		IN	zx_tax_relations_t.tax_group_id%TYPE, --(used in where condition)
		p_content_owner_id	IN	zx_rates_b.content_owner_id%TYPE,
		p_start_date		IN	ar_vat_tax_all.start_date%TYPE,
		p_end_date		IN	ar_vat_tax_all.end_date%TYPE,
		p_tax_regime_code	IN	zx_rates_b.tax_regime_code %TYPE,
		p_tax_code		IN	zx_rates_b.tax %TYPE,
		x_return_status 	OUT NOCOPY VARCHAR2) IS

l_formula_id			zx_formula_b.formula_id%TYPE;

BEGIN

	-- Inserting values in table zx_formula_b

	arp_util_tax.debug('in create_formula() for : '||p_tax_code);
	BEGIN
		--bug#	4610260 : Changed the ZX_FORMULA_B_TMP to ZX_FORMULA_B
		INSERT INTO zx_formula_b_tmp (
				formula_type_code		,
				formula_code			,
				tax_regime_code			,
				tax				,
				effective_from			,
				effective_to			,
				enabled_flag			,
				taxable_basis_type_code		,
				record_type_code		,
				base_rate_modifier		,
				cash_discount_appl_flag		,
				volume_discount_appl_flag	,
				trading_discount_appl_flag	,
				transfer_charge_appl_flag	,
				transport_charge_appl_flag	,
				insurance_charge_appl_flag	,
				other_charge_appl_flag		,
				formula_id			,
				content_owner_id		,
				created_by			,
				creation_date			,
				last_updated_by			,
				last_update_date		,
				last_update_login		,
				request_id			,
				program_application_id		,
				program_id			,
				program_login_id		,
				object_version_number)
			SELECT
				'TAXABLE_BASIS'			,
				p_formula_code			, --tax_group_code||'_'||tax_code||'_TB'
				p_tax_regime_code		,
				p_tax_code				,
				p_start_date			,
				p_end_date			,
				p_enabled_flag			,
				DECODE(p_taxable_basis,'PRIOR_TAX','PRIOR_TAX','LINE_AMOUNT'),  --Bug Fix 5691957
				'MIGRATED'			,
				0				,-- bug6718736
				DECODE(p_taxable_basis, 'AFTER_EPD','Y','N'),
				p_discount_flag			,
				p_discount_flag			,
				p_charge_flag			,
				p_charge_flag			,
				p_charge_flag			,
				p_charge_flag			,
				zx_formula_b_s.NEXTVAL	l_formula_id,
				p_content_owner_id		,
				fnd_global.user_id		,
				SYSDATE				,
				fnd_global.user_id		,
				SYSDATE				,
				fnd_global.conc_login_id	,
				fnd_global.conc_request_id     	,--Request Id
				fnd_global.prog_appl_id        	,--Program Application ID
				fnd_global.conc_program_id    	,--Program Id
				fnd_global.conc_login_id        ,--Program Login ID
				1
			FROM	DUAL
			WHERE
			--Re-runnability
			NOT EXISTS (	SELECT 	1
					FROM 	zx_formula_b
					WHERE	SUBSTRB(formula_code,1,24) = SUBSTRB(p_formula_code,1,24)
					AND 	(effective_from BETWEEN
							p_start_date and nvl(p_end_date,SYSDATE)
							OR
						 NVL(effective_to,sysdate) BETWEEN
						      p_start_date and nvl(p_end_date,sysdate)
						)
					AND	enabled_flag   = 'Y'
						 );

	EXCEPTION WHEN OTHERS THEN
		arp_util_tax.debug('In create_formula().formula_b: error-'||sqlerrm);
		x_return_status := FND_API.G_RET_STS_ERROR;

	END ;

	-- Inserting values in table zx_formula_tl
 	BEGIN

		 INSERT INTO zx_formula_tl (
			formula_id		,
			formula_name		,
			created_by		,
			creation_date		,
			last_updated_by		,
			last_update_date	,
			last_update_login	,
			language		,
			source_lang
			)
		  SELECT
			formula_id		,
			    CASE WHEN formula_code = UPPER(formula_code)
			     THEN    Initcap(formula_code)
			     ELSE
				     formula_code
			     END,
			fnd_global.user_id	,
			SYSDATE			,
			fnd_global.user_id	,
			SYSDATE			,
			fnd_global.conc_login_id,
			l.language_code		,
			userenv('LANG')
		  FROM 	fnd_languages l, zx_formula_b formula
		  WHERE	l.installed_flag IN ('I', 'B')
		  AND  	formula.record_type_code = 'MIGRATED'
		  AND 	formula.formula_code = p_formula_code
		  AND  	NOT EXISTS(SELECT	NULL
				   FROM 	zx_formula_tl t
				   WHERE 	t.formula_id = formula.formula_id
				   AND 		t.language = l.language_code);

	EXCEPTION WHEN OTHERS THEN
		arp_util_tax.debug('In create_formula().formula_tl: error-'||sqlerrm);
		x_return_status := FND_API.G_RET_STS_ERROR;

	END;


	-- Inserting values in table zx_formula_details

	arp_util_tax.debug('l_formula_id:'|| l_formula_id);


	IF p_taxable_basis = 'PRIOR_TAX' THEN

		BEGIN

			  INSERT INTO zx_formula_details (
				formula_detail_id		,
				formula_id			,
				compounding_tax_regime_code	,
				compounding_tax			,
				compounding_type_code		,
				record_type_code 		,
				creation_date			,
				last_update_date		,
				created_by			,
				last_updated_by			,
				last_update_login		,
				request_id			,
				program_application_id		,
				program_id			,
				program_login_id		,
				object_version_number
				)
			SELECT
				zx_formula_details_s.NEXTVAL	,
				zx_formula_b_s.CURRVAL		,
				p_parent_regime_code		,
				p_parent_tax_code		,
				'ADD'				,
				'MIGRATED'			,
				SYSDATE				,
				SYSDATE				,
				fnd_global.user_id		,
				fnd_global.user_id		,
				fnd_global.conc_login_id	,
				fnd_global.conc_request_id     	,--Request Id
				fnd_global.prog_appl_id        	,--Program Application ID
				fnd_global.conc_program_id    	,--Program Id
				fnd_global.conc_login_id        ,--Program Login ID
				1

			FROM 	DUAL
			WHERE
			--Re-runnability
			NOT EXISTS 	(SELECT 1
					 FROM 	zx_formula_details, zx_formula_b
					 WHERE	zx_formula_details.formula_id = zx_formula_b.formula_id
					 AND	compounding_tax_regime_code = p_parent_regime_code
					 AND 	compounding_tax = p_parent_tax_code);

		EXCEPTION WHEN OTHERS THEN
			arp_util_tax.debug('In create_formula().formula_details: error-'||sqlerrm);

			x_return_status := FND_API.G_RET_STS_ERROR;

		END;



	ELSIF p_taxable_basis <> 'PRIOR_TAX' THEN

		BEGIN
		-- Bug 8429806
		 SELECT formula_id
		        INTO l_formula_id
		 FROM zx_formula_b zx_formula_b
		   	WHERE content_owner_id=p_content_owner_id
			    AND SUBSTRB(formula_code,1,24) = SUBSTRB(p_formula_code,1,24)
			    AND (effective_from BETWEEN p_start_date and nvl(p_end_date,SYSDATE)
			    OR  NVL(effective_to,sysdate) BETWEEN p_start_date and nvl(p_end_date,sysdate))
			    AND tax_regime_code=p_child_regime_code
			    AND tax=p_tax_code;  -- 8726049
		 -- Bug 8429806


			INSERT INTO zx_formula_details (
				formula_detail_id		,
				formula_id			,
				compounding_tax			,
				compounding_tax_regime_code	,
				compounding_type_code		,
				record_type_code 		,
				creation_date			,
				last_update_date		,
				created_by			,
				last_updated_by			,
				last_update_login		,
				request_id			,
				program_application_id		,
				program_id			,
				program_login_id		,
				object_version_number
				)
				SELECT zx_formula_details_s.NEXTVAL	,
					l_formula_id	, -- Bug 8429806
					p_parent_tax_code		, -- 8726049
					parent_regime_code		,
					'ADD'			,
					'MIGRATED'		,
					SYSDATE			,
					SYSDATE			,
					fnd_global.user_id		,
					fnd_global.user_id		,
					fnd_global.conc_login_id	,
					fnd_global.conc_request_id     	,--Request Id
					fnd_global.prog_appl_id        	,--Program Application ID
					fnd_global.conc_program_id    	,--Program Id
					fnd_global.conc_login_id        ,--Program Login ID
					1
				FROM 	zx_tax_relations_t t
				WHERE 	t.child_regime_code = p_child_regime_code
				AND 	t.child_tax_code = p_child_tax_code
				AND	t.tax_group_id = p_group_id
				AND	NOT EXISTS 	(SELECT 1
							 FROM 	zx_formula_details, zx_formula_b
							 WHERE	zx_formula_details.formula_id = l_formula_id			-- Bug 8429806
							 AND	compounding_tax_regime_code = p_parent_regime_code
							 AND 	compounding_tax = p_parent_tax_code
               AND contains(zx_formula_b.formula_code, t.tax_group_code) > 0
							)
 and rownum = 1;

-- the above contains clause is introduced as part of 6718736

		EXCEPTION WHEN OTHERS THEN
			arp_util_tax.debug('In create_formula().formula_b: error-'||sqlerrm);
			x_return_status := FND_API.G_RET_STS_ERROR;

		END;

	END IF;

END CREATE_FORMULA;

/****************************************************************************************
*	Procedure: CREATE_RULES	                                         		*
*	Based on the input parameters, row(s) would be created in to ZX_RULES_B,	*
*    ZX_RULES_TL and ZX_PROCESS_RESULTS.			   			*
*****************************************************************************************/

PROCEDURE CREATE_RULES
(	--parameters rqrd  for zx_rules_b
	p_tax			IN	zx_rates_b.tax%TYPE	,
	p_tax_regime_code	IN	zx_rates_b.tax_regime_code%TYPE	,
	p_effective_from	IN	ar_vat_tax_all.start_date%TYPE	,
	p_effective_to		IN	ar_vat_tax_all.end_date%TYPE	,
	p_enabled_flag		IN	ar_tax_group_codes.enabled_flag%TYPE	,
	p_content_owner_id	IN	zx_rates_b.content_owner_id%TYPE,		 -- for zx_process_results
	p_condition_grp_cd 	IN	fnd_lookups.lookup_code%TYPE	,
	p_alphanumeric_result	IN	zx_process_results.alphanumeric_result%TYPE,
	p_condition_group_id	IN	zx_condition_groups_b.condition_group_id%TYPE,
	p_tax_condition_id	IN	ar_tax_group_codes_all.tax_condition_id%TYPE,
	p_tax_exception_id	IN	ar_tax_group_codes_all.tax_exception_id%TYPE,
	x_return_status 	OUT NOCOPY VARCHAR2		 ) IS

--l_tax_rule_id		zx_rules_b.tax_rule_id%TYPE;
l_tax_rule_code		zx_rules_b.tax_rule_code%TYPE;
l_tax_rule_id NUMBER;

BEGIN

	arp_util_tax.debug('in create_rules() for : '||p_tax);




	SELECT DECODE(SIGN(LENGTHB('O_TB_' || p_tax) - 30),
			1,
			SUBSTRB('O_TB_' || p_tax,1,24)||ZX_MIGRATE_UTIL.GET_NEXT_SEQID('ZX_RULES_B_S'),
			'O_TB_' || p_tax)
	INTO l_tax_rule_code
	FROM DUAL;

	arp_util_tax.debug('l_tax_rule_code'||l_tax_rule_code);

-- Inserting values in table zx_rules_b

	BEGIN
		--bug#	4610260 : Changed the ZX_RULES_B to ZX_RULES_B_TMP
		INSERT INTO zx_rules_b_tmp
			(tax_rule_code		,
			 tax          		,
			 tax_regime_code	,
			 service_type_code	,
			 application_id   	,
			 recovery_type_code 	,
			 priority		,
			 system_default_flag	,
			 effective_from		,
			 effective_to		,
			 enabled_flag		,
			 record_type_code	,
			 det_factor_templ_code	,
			 content_owner_id	,
			 tax_rule_id		,
			 created_by		,
			 creation_date          	,
			 last_updated_by        	,
			 last_update_date       	,
			 last_update_login      	,
			 request_id             	,
			 program_application_id,
			 program_id             	,
			 program_login_id		,
			 object_version_number)

		SELECT
			l_tax_rule_code 	,
			p_tax			,
			p_tax_regime_code	,
			'DET_TAXABLE_BASIS'	,
			NULL			,
			NULL			,
			1			,
			'N'			,  -- Bug 4590290
			p_effective_from	,
			p_effective_to		,
			p_enabled_flag		,
			'MIGRATED'		,
			'STCC'	,
			p_content_owner_id	,
			zx_rules_b_s.NEXTVAL	,
			fnd_global.user_id	,
			SYSDATE			,
			fnd_global.user_id	,
			SYSDATE			,
			fnd_global.conc_login_id,
			fnd_global.conc_request_id     		,--Request Id
			fnd_global.prog_appl_id        		,--Program Application ID
			fnd_global.conc_program_id    		,--Program Id
			fnd_global.conc_login_id        	,--Program Login ID
			1
		FROM 	DUAL
		WHERE
		--Re-runnability

		NOT EXISTS	(SELECT 1
				 FROM 	zx_rules_B
				 WHERE	substrb(tax_rule_code,1,24)      = (SELECT DECODE(SIGN(LENGTHB('O_TB_' || p_tax) - 30),
														1,
														SUBSTRB('O_TB_' || p_tax,1,24),
														SUBSTRB('O_TB_' || p_tax,1,24))
											FROM DUAL)
				 AND content_owner_id = p_content_owner_id
				 AND tax_regime_code = p_tax_regime_code
				 AND (effective_from BETWEEN p_effective_from AND NVL(p_effective_to,SYSDATE)
					OR
					NVL(effective_to,SYSDATE) BETWEEN p_effective_from AND NVL(p_effective_to,SYSDATE)
					)
				 AND enabled_flag   = 'Y'
				);

	EXCEPTION WHEN OTHERS THEN
		arp_util_tax.debug('In create_rules().rules_b: error-'||sqlerrm);
		x_return_status := FND_API.G_RET_STS_ERROR;

	END;

 	-- Inserting values in table zx_rules_tl
	BEGIN
		INSERT INTO zx_rules_tl (
			tax_rule_id		,
			tax_rule_name	,
			created_by		,
			creation_date	,
			last_updated_by	,
			last_update_date	,
			last_update_login	,
			language		,
			source_lang

			)
		SELECT
			tax_rule_id		,
			    CASE WHEN tax_rule_code = UPPER(tax_rule_code)
			     THEN    Initcap(tax_rule_code)
			     ELSE
				     tax_rule_code
			     END,
			fnd_global.user_id	,
			SYSDATE		,
			fnd_global.user_id	,
			SYSDATE		,
			fnd_global.conc_login_id,
			l.language_code	,
			userenv('LANG')
		FROM 	fnd_languages l, zx_rules_b rules
		WHERE	l.installed_flag IN ('I', 'B')
		AND  	rules.record_type_code = 'MIGRATED'
		AND 	rules.tax_rule_code =  l_tax_rule_code
		AND  	NOT EXISTS (SELECT	NULL
				    FROM 	zx_rules_tl t
				    WHERE 	t.tax_rule_id = rules.tax_rule_id
				    AND 	t.language = l.language_code);

	EXCEPTION WHEN OTHERS THEN
		arp_util_tax.debug('In create_rules().rules_tl: error-'||sqlerrm);
		x_return_status := FND_API.G_RET_STS_ERROR;

	END;

	 -- Inserting values in table zx_process_results
         -- Bug 8429806
	 SELECT tax_rule_id
              INTO l_tax_rule_id
         FROM zx_rules_b
           WHERE tax_rule_code = l_tax_rule_code
		 AND tax_regime_code = p_tax_regime_code
		 AND tax = p_tax
		 AND content_owner_id = p_content_owner_id
		 AND service_type_code = 'DET_TAXABLE_BASIS'
		 AND enabled_flag   = p_enabled_flag
                 AND (effective_from BETWEEN p_effective_from and nvl(p_effective_to,SYSDATE)
                            OR  NVL(effective_to,sysdate) BETWEEN p_effective_from and nvl(p_effective_to,sysdate));
       -- Bug 8429806

	BEGIN

		INSERT INTO 	zx_process_results
				(condition_group_code		,
				 priority			,
				 result_type_code		,
				 tax_status_code 		,
				 numeric_result  		,
				 alphanumeric_result		,
				 status_result      		,
				 rate_result        		,
				 legal_message_code 		,
				 min_tax_amt        		,
				 max_tax_amt        		,
				 min_taxable_basis  		,
				 max_taxable_basis  		,
				 min_tax_rate       		,
				 max_tax_rate       		,
				 enabled_flag           	,
				 allow_exemptions_flag  	,
				 allow_exceptions_flag  	,
				 record_type_code       	,
				 result_api             	,
				 result_id              	,
				 content_owner_id       	,
				 condition_group_id     	,
				 tax_rule_id            	,
				 condition_set_id		,
				 exception_set_id		,
				 created_by             	,
				 creation_date          	,
				 last_updated_by        	,
				 last_update_date       	,
				 last_update_login      	,
				 request_id             	,
				 program_application_id 	,
				 program_id             	,
				 program_login_id		,
				 object_version_number)
			SELECT
				p_condition_grp_cd		,
				1			,
				'CODE'			,
				NULL			,
				NULL			,
				p_alphanumeric_result	,-- STANDARD_TB_DISCOUNT,STANDARD_QUANTITY or TAX_GROUP_CODE||'_'||TAX_CODE||'_TB'
				NULL			,
				NULL			,
				NULL			,
				NULL			,
				NULL			,
				NULL			,
				NULL			,
				NULL			,
				NULL			,
				p_enabled_flag		, -- also used in insert of zx_rules_b
				'N'			,
				'N'			,
				'MIGRATED'		,
				NULL			,
				zx_process_results_s.NEXTVAL	,
				p_content_owner_id		, -- also used in insert of zx_rules_b also
				p_condition_group_id		,
				l_tax_rule_id	, -- zx_rules_b.tax_rule_id(based on rule created above)8429806
				p_tax_condition_id	, --condition set id
				p_tax_exception_id	, --exception set id
				fnd_global.user_id           	,
				SYSDATE      		,
				fnd_global.user_id           	,
				SYSDATE			,
				fnd_global.conc_login_id	,
				fnd_global.conc_request_id     	,--Request Id
				fnd_global.prog_appl_id        	,--Program Application ID
				fnd_global.conc_program_id    	,--Program Id
				fnd_global.conc_login_id        ,--Program Login ID
				1

			FROM	dual
			WHERE
			--Re-runnability
			NOT EXISTS 	(SELECT 1
					 FROM 	zx_process_results
					 WHERE	zx_process_results.tax_rule_id = l_tax_rule_id --Bug 8429806
					 AND	zx_process_results.content_owner_id = p_content_owner_id
					 AND 	zx_process_results.condition_group_code = p_condition_grp_cd
					 AND 	zx_process_results.alphanumeric_result  = p_alphanumeric_result
		       );


	EXCEPTION WHEN OTHERS THEN
		arp_util_tax.debug('In create_rules().process_results: error-'||sqlerrm);
		x_return_status := FND_API.G_RET_STS_ERROR;

	END;

END CREATE_RULES;

END	ZX_AR_FORMULA_MIG_PKG;

/
