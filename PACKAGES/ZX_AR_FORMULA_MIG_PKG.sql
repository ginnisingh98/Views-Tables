--------------------------------------------------------
--  DDL for Package ZX_AR_FORMULA_MIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_AR_FORMULA_MIG_PKG" AUTHID CURRENT_USER AS
/* $Header: zxarformulamigs.pls 120.2.12010000.1 2008/07/28 13:28:27 appldev ship $ */

PROCEDURE FORMULA_MIGRATION_MAIN(x_return_status     OUT NOCOPY  VARCHAR2) ;

PROCEDURE CREATE_FORMULA
		(--for zx_formula_b
		p_taxable_basis		IN	ar_vat_tax_all.taxable_basis%TYPE,
		p_formula_code		IN	zx_formula_b.formula_code%TYPE,	-- tax_group_code||'_'||tax_code||'_TB'
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
		x_return_status 	OUT NOCOPY VARCHAR2);

PROCEDURE CREATE_RULES
		(--parameters rqrd  for zx_rules_b
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
			x_return_status 	OUT NOCOPY VARCHAR2 );

END ZX_AR_FORMULA_MIG_PKG;


/
