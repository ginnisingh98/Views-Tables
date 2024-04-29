--------------------------------------------------------
--  DDL for Package Body PAY_JP_CUSTOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_CUSTOM_PKG" AS
/* $Header: pyjpcust.pkb 120.2.12010000.3 2008/08/06 07:35:44 ubhat ship $ */
	-- Element Type IDs and Input Value IDs for Result Value and Entry Value.
	TYPE itax_rec IS RECORD(
		sal_elm_id			NUMBER,
		sal_iv_id			NUMBER,
		bon_elm_id			NUMBER,
		bon_iv_id			NUMBER,
		sp_bon_elm_id			NUMBER,
		sp_bon_iv_id			NUMBER,
		yea_elm_id			NUMBER,
		yea_category_iv_id		NUMBER,
		yea_iv_id			NUMBER,
		gen_elm_id			NUMBER,
		gen_iv_id			NUMBER,
		gen_nr_iv_id			NUMBER,
		non_res_elm_id			NUMBER,
		non_res_date_iv_id		NUMBER,
		res_date_iv_id			NUMBER,
		ci_prem_sal_ee_elm_id		NUMBER,
		ci_prem_sal_ee_iv_id		NUMBER,
		ci_prem_sal_ee_elm_nonres_id	NUMBER,
		ci_prem_sal_ee_iv_nonres_id	NUMBER,
		ci_prem_sal_er_elm_id		NUMBER,
		ci_prem_sal_er_iv_id		NUMBER,
		ci_prem_sal_ee_elm_n_id		NUMBER,
		ci_prem_sal_ee_iv_n_id		NUMBER,
		ci_prem_sal_ee_elm_nonres_n_id	NUMBER,
		ci_prem_sal_ee_iv_nonres_n_id	NUMBER,
		ci_prem_sal_er_elm_n_id		NUMBER,
		ci_prem_sal_er_iv_n_id		NUMBER,
		ci_prem_bon_ee_elm_id		NUMBER,
		ci_prem_bon_ee_iv_id		NUMBER,
		ci_prem_bon_ee_elm_nonres_id	NUMBER,
		ci_prem_bon_ee_iv_nonres_id	NUMBER,
		ci_prem_bon_er_elm_id		NUMBER,
		ci_prem_bon_er_iv_id		NUMBER);
	-- Input Value IDs for Entry Value.
	TYPE iv_rec IS RECORD(
		itax_org		NUMBER,
		hi_org			NUMBER,
		wp_org			NUMBER,
		wpf_org			NUMBER,
		ui_org			NUMBER,
		wai_org			NUMBER,
		gen_ltax_district_code	NUMBER,
		term_ltax_district_code	NUMBER,
		ui_category		NUMBER,
		wai_category		NUMBER);
	-- Defined Balance IDs.
	TYPE bal_rec IS RECORD(
		-- Taxable Amount
		sal_taxable_sal		NUMBER,
		sal_taxable_mat		NUMBER,
		sal_taxable_sal_nr	NUMBER,
		sal_taxable_mat_nr	NUMBER,
		bon_taxable_sal		NUMBER,
		bon_taxable_mat		NUMBER,
		bon_taxable_sal_nr	NUMBER,
		bon_taxable_mat_nr	NUMBER,
		sp_bon_taxable_sal	NUMBER,
		sp_bon_taxable_mat	NUMBER,
		sp_bon_taxable_sal_nr	NUMBER,
		sp_bon_taxable_mat_nr	NUMBER,
		term_taxable_sal	NUMBER,
		term_taxable_mat	NUMBER,
		term_taxable_sal_nr	NUMBER,
		term_taxable_mat_nr	NUMBER,
		-- Health Ins Premium
		sal_hi_prem_ee		NUMBER,
		bon_hi_prem_ee		NUMBER,
		gen_hi_prem_er		NUMBER,
		-- Welfare Pension Ins Premium
		sal_wp_prem_ee		NUMBER,
		bon_wp_prem_ee		NUMBER,
		gen_wp_prem_er		NUMBER,
		-- Welfare Pension Fund Premium
		sal_wpf_prem_ee		NUMBER,
		bon_wpf_prem_ee		NUMBER,	-- added for bug 3803871
		gen_wpf_prem_er		NUMBER,
		-- Unemployment Ins Premium
		sal_ui_prem_ee		NUMBER,
		sal_ui_sal		NUMBER,
		bon_ui_prem_ee		NUMBER,
		bon_ui_sal		NUMBER,
		sp_bon_ui_prem_ee	NUMBER,
		sp_bon_ui_sal		NUMBER,
		-- Work Accident Ins Premium
		sal_wai_sal		NUMBER,
		bon_wai_sal		NUMBER,
		sp_bon_wai_sal		NUMBER,
		-- Income Tax
		sal_itax		NUMBER,
		bon_itax		NUMBER,
		sp_bon_itax		NUMBER,
		term_itax		NUMBER,
		yea_itax		NUMBER,
		-- Local Tax
		sal_ltax		NUMBER,
		gen_ltax_lumpsum	NUMBER,
		term_ltax		NUMBER,
		term_ltax_income	NUMBER,
		term_ltax_shi		NUMBER,
		term_ltax_to		NUMBER,
		-- Defined Contribution Premum
		sal_mutual_aid		NUMBER,
		bon_mutual_aid		NUMBER,
		sp_bon_mutual_aid	NUMBER,
		-- Disaster Tax Reduction
		disaster_tax_reduction	NUMBER);
	TYPE name_tl IS RECORD(
		salary		VARCHAR2(80),
		bonus		VARCHAR2(80),
		sp_bonus	VARCHAR2(80),
		sp_bonus2	VARCHAR2(80),
		yea		VARCHAR2(80),
		yea2		VARCHAR2(80),
		re_yea		VARCHAR2(80),
		term		VARCHAR2(80),
		term2		VARCHAR2(80),
		santei		VARCHAR2(80),
		geppen		VARCHAR2(80),
		na		VARCHAR2(80),
		bal_init_prefix	VARCHAR2(80),
		itax_category	VARCHAR2(80),
		yea_category	VARCHAR2(80),
		yea_category2	VARCHAR2(80),
		non_res		VARCHAR2(80),
		non_res_date	VARCHAR2(80),
		res_date	VARCHAR2(80),
		yea_element	pay_element_types_f.element_name%type,
		reyea_element	pay_element_types_f.element_name%type);
	g_itax			itax_rec;
	g_iv			iv_rec;
	g_bal			bal_rec;
	g_name_tl		name_tl;
	g_business_group_id	NUMBER;
	g_legislation_code	VARCHAR2(2);
	g_owner			CONSTANT VARCHAR2(30) := 'PAYJPPRT';
--------------------------------------------------------------
	PROCEDURE SETUP_GLOBALS(
--------------------------------------------------------------
		p_business_group_id	IN NUMBER)
	IS
		l_legislation_code	VARCHAR2(2);
	BEGIN
		hr_utility.set_location('pay_jp_custom_pkg.set_globals',10);

		if nvl(g_business_group_id,-1) <> p_business_group_id then
			hr_utility.set_location('pay_jp_custom_pkg.set_globals',20);

			-- Name Translation
			g_name_tl.salary		:= fnd_message.get_string('PAY','PAY_JP_SALARY');
			g_name_tl.bonus			:= fnd_message.get_string('PAY','PAY_JP_BONUS');
			g_name_tl.sp_bonus		:= fnd_message.get_string('PAY','PAY_JP_SP_BONUS');
			g_name_tl.sp_bonus2		:= fnd_message.get_string('PAY','PAY_JP_SP_BON');
			g_name_tl.yea			:= fnd_message.get_string('PAY','PAY_JP_YEAR_END_ADJ');
			g_name_tl.yea2			:= fnd_message.get_string('PAY','PAY_JP_YEA');
			g_name_tl.re_yea		:= fnd_message.get_string('PAY','PAY_JP_RE_YEAR_END_ADJ');
			g_name_tl.term			:= fnd_message.get_string('PAY','PAY_JP_TERM_PAY');
			g_name_tl.term2			:= fnd_message.get_string('PAY','PAY_JP_TERM');
			g_name_tl.santei		:= fnd_message.get_string('PAY','PAY_JP_SANTEI');
			g_name_tl.geppen		:= fnd_message.get_string('PAY','PAY_JP_GEPPEN');
			g_name_tl.na			:= fnd_message.get_string('PAY','PAY_JP_AMBIGUOUS');
			g_name_tl.bal_init_prefix	:= fnd_message.get_string('PAY','PAY_JP_INIT_PREFIX');
			g_name_tl.itax_category		:= 'ITX_TYPE';
			g_name_tl.yea_category		:= 'INCLUDE_FLAG';
			g_name_tl.yea_category2		:= 'INCLUDE_FLAG';
			g_name_tl.non_res		:= 'NRES_FLAG';
			g_name_tl.yea_element		:= 'YEA_ITX';
			g_name_tl.reyea_element		:= 'REY_ITX';

			l_legislation_code	:= hr_jp_id_pkg.legislation_code(p_business_group_id);
			if l_legislation_code is NULL then
				fnd_message.set_name(800,'HR_51255_PYP_INVALID_BUS_GROUP');
				fnd_message.raise_error;
			end if;

			g_business_group_id	:= p_business_group_id;
			g_legislation_code	:= l_legislation_code;

			g_itax.sal_elm_id		:= hr_jp_id_pkg.element_type_id('SAL_ITX',NULL,l_legislation_code);
			g_itax.sal_iv_id		:= hr_jp_id_pkg.input_value_id(g_itax.sal_elm_id,g_name_tl.itax_category);
			g_itax.bon_elm_id		:= hr_jp_id_pkg.element_type_id('BON_ITX',NULL,l_legislation_code);
			g_itax.bon_iv_id		:= hr_jp_id_pkg.input_value_id(g_itax.bon_elm_id,g_name_tl.itax_category);
			g_itax.sp_bon_elm_id		:= hr_jp_id_pkg.element_type_id('SPB_ITX',NULL,l_legislation_code);
			g_itax.sp_bon_iv_id		:= hr_jp_id_pkg.input_value_id(g_itax.sp_bon_elm_id,g_name_tl.itax_category);
			g_itax.yea_elm_id		:= hr_jp_id_pkg.element_type_id('YEA_AMT_AFTER_EMP_INCOME_DCT_RSLT',NULL,l_legislation_code);
			g_itax.yea_category_iv_id	:= hr_jp_id_pkg.input_value_id(g_itax.yea_elm_id,g_name_tl.yea_category);
			g_itax.yea_iv_id		:= hr_jp_id_pkg.input_value_id(g_itax.yea_elm_id,g_name_tl.itax_category);
			g_itax.gen_elm_id		:= hr_jp_id_pkg.element_type_id('COM_ITX_INFO',NULL,l_legislation_code);
			g_itax.gen_iv_id		:= hr_jp_id_pkg.input_value_id(g_itax.gen_elm_id,g_name_tl.itax_category);
			g_itax.gen_nr_iv_id		:= hr_jp_id_pkg.input_value_id(g_itax.gen_elm_id,g_name_tl.non_res);

			g_itax.non_res_elm_id		:= hr_jp_id_pkg.element_type_id('COM_NRES_INFO',NULL,l_legislation_code);
			g_name_tl.non_res_date		:= 'NRES_START_DATE';
			g_name_tl.res_date		:= 'PROJECTED_RES_DATE';
			g_itax.non_res_date_iv_id	:= hr_jp_id_pkg.input_value_id(g_itax.non_res_elm_id,g_name_tl.non_res_date);
			g_itax.res_date_iv_id		:= hr_jp_id_pkg.input_value_id(g_itax.non_res_elm_id,g_name_tl.res_date);


			g_iv.itax_org			:= hr_jp_id_pkg.input_value_id('COM_ITX_INFO','WITHHOLD_AGENT',NULL,l_legislation_code);
			g_iv.hi_org			:= hr_jp_id_pkg.input_value_id('COM_SI_INFO','HI_LOCATION',NULL,l_legislation_code);
			g_iv.wp_org			:= hr_jp_id_pkg.input_value_id('COM_SI_INFO','WP_LOCATION',NULL,l_legislation_code);
			g_iv.wpf_org			:= hr_jp_id_pkg.input_value_id('COM_SI_INFO','WPF_LOCATION',NULL,l_legislation_code);
			g_iv.ui_org			:= hr_jp_id_pkg.input_value_id('COM_LI_INFO','EI_LOCATION',NULL,l_legislation_code);
			g_iv.wai_org			:= hr_jp_id_pkg.input_value_id('COM_LI_INFO','WAI_LOCATION',NULL,l_legislation_code);
			g_iv.gen_ltax_district_code	:= hr_jp_id_pkg.input_value_id('COM_LTX_INFO','MUNICIPAL_CODE',NULL,l_legislation_code);
			g_iv.term_ltax_district_code	:= hr_jp_id_pkg.input_value_id('TRM_LTX_SP_WITHHOLD_PROC','MUNICIPAL_CODE',NULL,l_legislation_code);
			g_iv.ui_category		:= hr_jp_id_pkg.input_value_id('COM_LI_INFO','EI_TYPE',NULL,l_legislation_code);
			g_iv.wai_category		:= hr_jp_id_pkg.input_value_id('COM_LI_INFO','WAI_TYPE',NULL,l_legislation_code);

			-- Taxable Amount
			g_bal.sal_taxable_sal		:= hr_jp_id_pkg.balance_type_id('B_SAL_TXBL_ERN_MONEY',NULL,l_legislation_code);
			g_bal.sal_taxable_mat		:= hr_jp_id_pkg.balance_type_id('B_SAL_TXBL_ERN_KIND',NULL,l_legislation_code);
			g_bal.sal_taxable_sal_nr	:= hr_jp_id_pkg.balance_type_id('B_SAL_TXBL_ERN_MONEY_NRES',NULL,l_legislation_code);
			g_bal.sal_taxable_mat_nr	:= hr_jp_id_pkg.balance_type_id('B_SAL_TXBL_ERN_KIND_NRES',NULL,l_legislation_code);
			g_bal.bon_taxable_sal		:= hr_jp_id_pkg.balance_type_id('B_BON_TXBL_ERN_MONEY',NULL,l_legislation_code);
			g_bal.bon_taxable_mat		:= hr_jp_id_pkg.balance_type_id('B_BON_TXBL_ERN_KIND',NULL,l_legislation_code);
			g_bal.bon_taxable_sal_nr	:= hr_jp_id_pkg.balance_type_id('B_BON_TXBL_ERN_MONEY_NRES',NULL,l_legislation_code);
			g_bal.bon_taxable_mat_nr	:= hr_jp_id_pkg.balance_type_id('B_BON_TXBL_ERN_KIND_NRES',NULL,l_legislation_code);
			g_bal.sp_bon_taxable_sal	:= hr_jp_id_pkg.balance_type_id('B_SPB_TXBL_ERN_MONEY',NULL,l_legislation_code);
			g_bal.sp_bon_taxable_mat	:= hr_jp_id_pkg.balance_type_id('B_SPB_TXBL_ERN_KIND',NULL,l_legislation_code);
			g_bal.sp_bon_taxable_sal_nr	:= hr_jp_id_pkg.balance_type_id('B_SPB_TXBL_ERN_MONEY_NRES',NULL,l_legislation_code);
			g_bal.sp_bon_taxable_mat_nr	:= hr_jp_id_pkg.balance_type_id('B_SPB_TXBL_ERN_KIND_NRES',NULL,l_legislation_code);
			g_bal.term_taxable_sal		:= hr_jp_id_pkg.balance_type_id('B_TRM_TXBL_ERN_MONEY',NULL,l_legislation_code);
			g_bal.term_taxable_mat		:= hr_jp_id_pkg.balance_type_id('B_TRM_TXBL_ERN_KIND',NULL,l_legislation_code);
			g_bal.term_taxable_sal_nr	:= hr_jp_id_pkg.balance_type_id('B_TRM_TXBL_ERN_MONEY_NRES',NULL,l_legislation_code);
			g_bal.term_taxable_mat_nr	:= hr_jp_id_pkg.balance_type_id('B_TRM_TXBL_ERN_KIND_NRES',NULL,l_legislation_code);
			-- Health Ins Premium
			g_bal.sal_hi_prem_ee		:= hr_jp_id_pkg.balance_type_id('B_SAL_HI_PREM',NULL,l_legislation_code);
			g_bal.bon_hi_prem_ee		:= hr_jp_id_pkg.balance_type_id('B_BON_HI_PREM',NULL,l_legislation_code);
			g_bal.gen_hi_prem_er		:= hr_jp_id_pkg.balance_type_id('B_COM_HI_PREM_ER',NULL,l_legislation_code);
			-- Care Ins Premium
			g_itax.ci_prem_sal_ee_elm_id	:= hr_jp_id_pkg.element_type_id('SAL_CI_PREM_EE',NULL,l_legislation_code);
			g_itax.ci_prem_sal_ee_iv_id		:= hr_jp_id_pkg.input_value_id('SAL_CI_PREM_EE','Pay Value',NULL,l_legislation_code);
			g_itax.ci_prem_sal_ee_elm_nonres_id	:= hr_jp_id_pkg.element_type_id('SAL_CI_PREM_EE_NRES',NULL,l_legislation_code);
			g_itax.ci_prem_sal_ee_iv_nonres_id	:= hr_jp_id_pkg.input_value_id('SAL_CI_PREM_EE_NRES','Pay Value',NULL,l_legislation_code);
			g_itax.ci_prem_sal_er_elm_id	:= hr_jp_id_pkg.element_type_id('SAL_CI_PREM_ER',NULL,l_legislation_code);
			g_itax.ci_prem_sal_er_iv_id		:= hr_jp_id_pkg.input_value_id('SAL_CI_PREM_ER','Pay Value',NULL,l_legislation_code);
			g_itax.ci_prem_sal_ee_elm_n_id		:= hr_jp_id_pkg.element_type_id('SAL_CI_PREM_EE_TRM',NULL,l_legislation_code);
			g_itax.ci_prem_sal_ee_iv_n_id		:= hr_jp_id_pkg.input_value_id('SAL_CI_PREM_EE_TRM','Pay Value',NULL,l_legislation_code);
			g_itax.ci_prem_sal_ee_elm_nonres_n_id	:= hr_jp_id_pkg.element_type_id('SAL_CI_PREM_EE_NRES_TRM',NULL,l_legislation_code);
			g_itax.ci_prem_sal_ee_iv_nonres_n_id	:= hr_jp_id_pkg.input_value_id('SAL_CI_PREM_EE_NRES_TRM','Pay Value',NULL,l_legislation_code);
			g_itax.ci_prem_sal_er_elm_n_id		:= hr_jp_id_pkg.element_type_id('SAL_CI_PREM_ER_TRM',NULL,l_legislation_code);
			g_itax.ci_prem_sal_er_iv_n_id		:= hr_jp_id_pkg.input_value_id('SAL_CI_PREM_ER_TRM','Pay Value',NULL,l_legislation_code);
			g_itax.ci_prem_bon_ee_elm_id	:= hr_jp_id_pkg.element_type_id('BON_CI_PREM_EE',NULL,l_legislation_code);
			g_itax.ci_prem_bon_ee_iv_id		:= hr_jp_id_pkg.input_value_id('BON_CI_PREM_EE','Pay Value',NULL,l_legislation_code);
			g_itax.ci_prem_bon_ee_elm_nonres_id	:= hr_jp_id_pkg.element_type_id('BON_CI_PREM_EE_NRES',NULL,l_legislation_code);
			g_itax.ci_prem_bon_ee_iv_nonres_id	:= hr_jp_id_pkg.input_value_id('BON_CI_PREM_EE_NRES','Pay Value',NULL,l_legislation_code);
			g_itax.ci_prem_bon_er_elm_id	:= hr_jp_id_pkg.element_type_id('BON_CI_PREM_ER',NULL,l_legislation_code);
			g_itax.ci_prem_bon_er_iv_id		:= hr_jp_id_pkg.input_value_id('BON_CI_PREM_ER','Pay Value',NULL,l_legislation_code);
			-- Welfare Pension Ins Premium
			g_bal.sal_wp_prem_ee		:= hr_jp_id_pkg.balance_type_id('B_SAL_WP_PREM',NULL,l_legislation_code);
			g_bal.bon_wp_prem_ee		:= hr_jp_id_pkg.balance_type_id('B_BON_WP_PREM',NULL,l_legislation_code);
			g_bal.gen_wp_prem_er		:= hr_jp_id_pkg.balance_type_id('B_COM_WP_PREM_ER',NULL,l_legislation_code);
			-- Welfare Pension Fund Premium
			g_bal.sal_wpf_prem_ee		:= hr_jp_id_pkg.balance_type_id('B_SAL_WPF_PREM',NULL,l_legislation_code);
			-- added for bug 3803871
			g_bal.bon_wpf_prem_ee		:= hr_jp_id_pkg.balance_type_id('B_BON_WPF_PREM',NULL,l_legislation_code);
			g_bal.gen_wpf_prem_er		:= hr_jp_id_pkg.balance_type_id('B_COM_WPF_PREM_ER',NULL,l_legislation_code);
			-- Unemployment Ins Premium
			g_bal.sal_ui_prem_ee		:= hr_jp_id_pkg.balance_type_id('B_SAL_EI_PREM',NULL,l_legislation_code);
			g_bal.sal_ui_sal		:= hr_jp_id_pkg.balance_type_id('B_SAL_ERN_SUBJ_EI',NULL,l_legislation_code);
			g_bal.bon_ui_prem_ee		:= hr_jp_id_pkg.balance_type_id('B_BON_EI_PREM',NULL,l_legislation_code);
			g_bal.bon_ui_sal		:= hr_jp_id_pkg.balance_type_id('B_BON_ERN_SUBJ_EI',NULL,l_legislation_code);
			g_bal.sp_bon_ui_prem_ee		:= hr_jp_id_pkg.balance_type_id('B_SPB_EI_PREM',NULL,l_legislation_code);
			g_bal.sp_bon_ui_sal		:= hr_jp_id_pkg.balance_type_id('B_SPB_ERN_SUBJ_EI',NULL,l_legislation_code);
			-- Work Accident Ins Premium
			g_bal.sal_wai_sal		:= hr_jp_id_pkg.balance_type_id('B_SAL_ERN_SUBJ_WAI',NULL,l_legislation_code);
			g_bal.bon_wai_sal		:= hr_jp_id_pkg.balance_type_id('B_BON_ERN_SUBJ_WAI',NULL,l_legislation_code);
			g_bal.sp_bon_wai_sal		:= hr_jp_id_pkg.balance_type_id('B_SPB_ERN_SUBJ_WAI',NULL,l_legislation_code);
			-- Income Tax
			g_bal.sal_itax			:= hr_jp_id_pkg.balance_type_id('B_SAL_ITX',NULL,l_legislation_code);
			g_bal.bon_itax			:= hr_jp_id_pkg.balance_type_id('B_BON_ITX',NULL,l_legislation_code);
			g_bal.sp_bon_itax		:= hr_jp_id_pkg.balance_type_id('B_SPB_ITX',NULL,l_legislation_code);
			g_bal.term_itax			:= hr_jp_id_pkg.balance_type_id('B_TRM_ITX',NULL,l_legislation_code);
			g_bal.yea_itax			:= hr_jp_id_pkg.balance_type_id('B_YEA_TAX_PAY',NULL,l_legislation_code);
			-- Local Tax
			g_bal.sal_ltax			:= hr_jp_id_pkg.balance_type_id('B_SAL_LTX',NULL,l_legislation_code);
			g_bal.gen_ltax_lumpsum		:= hr_jp_id_pkg.balance_type_id('B_COM_LTX_LUMP_SUM_WITHHOLD',NULL,l_legislation_code);
			g_bal.term_ltax			:= hr_jp_id_pkg.balance_type_id('B_TRM_LTX_SP_WITHHOLD_TAX',NULL,l_legislation_code);
			g_bal.term_ltax_income		:= hr_jp_id_pkg.balance_type_id('B_TRM_LTX_SP_WITHHOLD_TRM_INCOME',NULL,l_legislation_code);
			g_bal.term_ltax_shi		:= hr_jp_id_pkg.balance_type_id('B_TRM_LTX_SP_WITHHOLD_MUNICIPAL_TAX',NULL,l_legislation_code);
			g_bal.term_ltax_to		:= hr_jp_id_pkg.balance_type_id('B_TRM_LTX_SP_WITHHOLD_PREFECTURAL_TAX',NULL,l_legislation_code);
			-- Mutual Aid
			g_bal.sal_mutual_aid		:= hr_jp_id_pkg.balance_type_id('B_SAL_SMALL_COMPANY_MUTUAL_AID_PREM',NULL,l_legislation_code);
			g_bal.bon_mutual_aid		:= hr_jp_id_pkg.balance_type_id('B_BON_SMALL_COMPANY_MUTUAL_AID_PREM',NULL,l_legislation_code);
			g_bal.sp_bon_mutual_aid		:= hr_jp_id_pkg.balance_type_id('B_SPB_SMALL_COMPANY_MUTUAL_AID_PREM',NULL,l_legislation_code);
			-- Disaster Tax Reduction
			g_bal.disaster_tax_reduction	:= hr_jp_id_pkg.balance_type_id('B_YEA_GRACE_ITX',NULL,l_legislation_code);
		end if;

		hr_utility.set_location('pay_jp_custom_pkg.set_globals',30);
	END SETUP_GLOBALS;

-----------------------------------------------------------------------
	PROCEDURE VALIDATE_RECORD(
-----------------------------------------------------------------------
			p_value		IN value_rec,
			p_action_status OUT NOCOPY VARCHAR2,
			p_message OUT NOCOPY VARCHAR2)
	IS
	BEGIN
		hr_utility.set_location('pay_jp_custom_pkg.validate_record',10);

		p_action_status := 'C';

		-- Write your own validation here.
		-- 1) Health Insurance Premium Validation
		if not(p_value.hi_prem_ee = 0 or p_value.hi_prem_er = 0 or p_value.ci_prem_ee = 0 or p_value.ci_prem_er = 0) and (p_value.hi_org_id is NULL) then
			p_action_status := 'I';
			fnd_message.set_name('PAY','PAY_JP_INVALID_HI_UNION');
			p_message := fnd_message.get;
			return;
		end if;

		-- 2) Welfare Pension Insurance Premium Validation
		if not(p_value.wp_prem_ee = 0 or p_value.wp_prem_er = 0) and (p_value.wp_org_id is NULL) then
			p_action_status := 'I';
			fnd_message.set_name('PAY','PAY_JP_INVALID_WP_UNION');
			p_message := fnd_message.get;
			return;
		end if;

		-- 3) Welfare Pension Fund Premium Validation
		if not(p_value.wpf_prem_ee = 0 or p_value.wpf_prem_er = 0) and (p_value.wpf_org_id is NULL) then
			p_action_status := 'I';
			fnd_message.set_name('PAY','PAY_JP_INVALID_WP_FUND');
			p_message := fnd_message.get;
			return;
		end if;

		-- 4) Unemployment Insurance Premium Validation
		if not(p_value.ui_prem_ee = 0) and (nvl(p_value.ui_category,'E') = 'E' or p_value.ui_org_id is NULL) then
			p_action_status := 'I';
			fnd_message.set_name('PAY','PAY_JP_INVALID_UI_UNION');
			p_message := fnd_message.get;
			return;
		end if;

		-- 5) Income Tax Validation
		if not(p_value.taxable_sal_amt = 0 and p_value.taxable_mat_amt = 0 and p_value.itax = 0 and p_value.itax_adjustment = 0)
		and (p_value.itax_org_id is NULL or nvl(p_value.itax_category,'E') = 'E') then
			p_action_status := 'I';
			fnd_message.set_name('PAY','PAY_JP_INVALID_ITAX_SWOT');
			p_message := fnd_message.get;
			return;
		end if;

		-- 6) Local Tax Validation
        if (p_value.sp_ltax = 0
            and (not(p_value.ltax = 0 and p_value.ltax_lumpsum = 0)
                 and (p_value.itax_org_id is NULL or p_value.ltax_district_code is NULL)))
           or
           (p_value.sp_ltax <> 0
            and (p_value.sp_ltax_district_code is NULL
                or p_value.itax_org_id is NULL
                or (p_value.ltax_lumpsum <> 0 and p_value.ltax_district_code is NULL))) then
		--if not(p_value.ltax = 0 and p_value.ltax_lumpsum = 0 and p_value.sp_ltax = 0)
		--and (p_value.itax_org_id is NULL or p_value.ltax_district_code is NULL) then
			p_action_status := 'I';
			fnd_message.set_name('PAY','PAY_JP_INVALID_LTAX_SWOT');
			p_message := fnd_message.get;
			return;
		end if;

		hr_utility.set_location('pay_jp_custom_pkg.validate_record',20);
	END VALIDATE_RECORD;
--------------------------------------------------------------
	PROCEDURE GET_ITAX_CATEGORY(
--------------------------------------------------------------
			p_assignment_action_id	IN NUMBER,
			p_salary_category OUT NOCOPY VARCHAR2,
			p_itax_category	 OUT NOCOPY VARCHAR2,
			p_itax_yea_category OUT NOCOPY VARCHAR2)
	IS
		l_business_group_id	NUMBER;
		l_effective_date	DATE;
--		l_date_earned		DATE;
		l_assignment_id		NUMBER;
		l_element_set_id	number;
		l_element_type_id	number;
		l_element_name		pay_element_types_f.element_name%type;
		l_element_set_name	PAY_ELEMENT_SETS.ELEMENT_SET_NAME%TYPE;
    l_legislation_code  pay_element_sets.legislation_code%type;
		l_classification_name	pay_element_classifications.classification_name%type;
		l_salary_category	VARCHAR2(30) := NULL;
		l_itax_category		VARCHAR2(30) := NULL;
		l_itax_yea_category	VARCHAR2(30) := NULL;
		l_nonresident		VARCHAR2(30) := NULL;
		l_non_res_date		DATE;
		l_res_date		DATE;
/*
		CURSOR csr_element_set_name(p_assignment_action_id IN NUMBER) IS
			select	pes.element_set_name,
				ppa.business_group_id,
				ppa.date_earned,
				paa.assignment_id,
				ppa.effective_date
			from	pay_element_sets	pes,
				pay_payroll_actions	ppa,
				pay_assignment_actions	paa
			where	paa.assignment_action_id=p_assignment_action_id
			and	ppa.payroll_action_id=paa.payroll_action_id
			and	pes.element_set_id(+)=ppa.element_set_id;
*/
		CURSOR csr_classification_name(p_assignment_action_id IN NUMBER) IS
			select	pec.balance_initialization_flag,
				pec.classification_name,
				pet.element_name,
        pec.legislation_code
			from	pay_element_classifications	pec,
				pay_element_types_f		pet,
				pay_run_results			prr,
				pay_payroll_actions		ppa,
				pay_assignment_actions		paa
			where	paa.assignment_action_id=p_assignment_action_id
			and	ppa.payroll_action_id=paa.payroll_action_id
			and	prr.assignment_action_id=paa.assignment_action_id
			and	pet.element_type_id=prr.element_type_id
			and	ppa.effective_date
				between pet.effective_start_date and pet.effective_end_date
			and	pec.classification_id=pet.classification_id;
		CURSOR csr_itax_yea_category(p_assignment_action_id IN NUMBER) IS
			select	prrv.result_value
			from	pay_input_values_f	piv,
				pay_element_types_f	pet,
				pay_run_result_values	prrv,
				pay_run_results		prr,
				pay_payroll_actions	ppa2,
				pay_assignment_actions	paa2,
				pay_payroll_actions	ppa,
				pay_assignment_actions	paa
			where	paa.assignment_action_id=p_assignment_action_id
			and	ppa.payroll_action_id=paa.payroll_action_id
			and	ppa.action_type='I'
			and	paa2.assignment_id=paa.assignment_id
			and	ppa2.payroll_action_id=paa2.payroll_action_id
			and	ppa2.effective_date=ppa.effective_date
			and	ppa2.action_type='I'
			and	prr.assignment_action_id=paa2.assignment_action_id
			and	prrv.run_result_id=prr.run_result_id
			and	prrv.result_value is not NULL
			and	pet.element_type_id=prr.element_type_id
			and	ppa2.effective_date
				between pet.effective_start_date and pet.effective_end_date
			and	(pet.element_name = g_name_tl.bal_init_prefix || g_name_tl.yea || '2'
          or (pet.element_name = 'INI_YEA2' and pet.legislation_code = 'JP'))
			and	piv.input_value_id=prrv.input_value_id
			and	ppa2.effective_date
				between piv.effective_start_date and piv.effective_end_date
			and	piv.name=g_name_tl.yea_category2;
		--
		function get_salary_category(
               p_classification_name in varchar2,
               p_legislation_code    in varchar2 default g_legislation_code) return varchar2
		is
			l_sal_category	varchar2(30) := 'NA';
		begin
			if (p_classification_name like '% ' || g_name_tl.salary || ' %'
         or (p_classification_name like 'SAL_%' and p_legislation_code = 'JP')) then
				l_sal_category := 'SALARY';
			elsif (p_classification_name like '% ' || g_name_tl.bonus || ' %'
         or (p_classification_name like 'BON_%' and p_legislation_code = 'JP')) then
				l_sal_category := 'BONUS';
			elsif (p_classification_name like '% ' || g_name_tl.sp_bonus || ' %'
         or (p_classification_name like 'SPB_%' and p_legislation_code = 'JP')) then
				l_sal_category := 'SP_BONUS';
			elsif (p_classification_name like '% ' || g_name_tl.yea || '%'
         or (p_classification_name like 'YEA_%' and p_legislation_code = 'JP')) then
				l_sal_category := 'YEA';
			elsif (p_classification_name like '% ' || g_name_tl.term || ' %'
         or (p_classification_name like 'TRM_%' and p_legislation_code = 'JP')) then
				l_sal_category := 'TERM';
			elsif (p_classification_name like '% ' || g_name_tl.santei
         or (p_classification_name = 'SAN' and p_legislation_code = 'JP')) then
				l_sal_category := 'SANTEI';
			elsif (p_classification_name like '% ' || g_name_tl.geppen
         or (p_classification_name = 'GEP' and p_legislation_code = 'JP')) then
				l_sal_category := 'GEPPEN';
			end if;
			--
			return l_sal_category;
		end get_salary_category;
	BEGIN
		hr_utility.set_location('pay_jp_custom_pkg.get_itax_category',10);
/*
		open csr_element_set_name(p_assignment_action_id);
		fetch csr_element_set_name into l_element_set_name,l_business_group_id,l_date_earned,l_assignment_id,l_effective_date;
		if csr_element_set_name%NOTFOUND then
			close csr_element_set_name;
			return;
		end if;
		close csr_element_set_name;
*/
		--
		begin
			select	ppa.business_group_id,
				ppa.effective_date,
--				ppa.date_earned,
				paa.assignment_id,
				ppa.element_set_id,
				ppa.element_type_id
			into	l_business_group_id,
				l_effective_date,
--				l_date_earned,
				l_assignment_id,
				l_element_set_id,
				l_element_type_id
			from	pay_assignment_actions	paa,
				pay_payroll_actions	ppa
			where	paa.assignment_action_id = p_assignment_action_id
			and	ppa.payroll_action_id = paa.payroll_action_id;
		exception
			when others then
				return;
		end;
		--
		-- Initialize IDs.
		--
		setup_globals(l_business_group_id);
		--
		-- Identify "Salary Category" and "YEA Category"
		--
--		if l_element_set_name is not NULL then
		if l_element_set_id is not NULL then
			hr_utility.set_location('pay_jp_custom_pkg.get_itax_category',20);
			--
			select	element_set_name,
              legislation_code
			into	l_element_set_name, l_legislation_code
			from	pay_element_sets
			where	element_set_id = l_element_set_id;
			--
			if (l_element_set_name like g_name_tl.salary || '%'
         or (l_element_set_name = 'SAL' and l_legislation_code = 'JP')) then
				l_salary_category := 'SALARY';
			elsif (l_element_set_name like g_name_tl.bonus || '%'
         or (l_element_set_name = 'BON' and l_legislation_code = 'JP')) then
				l_salary_category := 'BONUS';
			elsif (l_element_set_name like g_name_tl.sp_bonus || '%'
         or (l_element_set_name = 'SPB' and l_legislation_code = 'JP')) then
				l_salary_category := 'SP_BONUS';
			elsif (l_element_set_name like g_name_tl.yea || '%'
         or (l_element_set_name = 'YEA' and l_legislation_code = 'JP')) then
				l_salary_category := 'YEA';
			elsif (l_element_set_name like g_name_tl.re_yea || '%'
         or (l_element_set_name = 'REY' and l_legislation_code = 'JP')) then
				l_salary_category := 'RE_YEA';
			elsif (l_element_set_name like g_name_tl.term || '%'
         or (l_element_set_name = 'TRM' and l_legislation_code = 'JP')) then
				l_salary_category := 'TERM';
			elsif (l_element_set_name like g_name_tl.santei || '%'
         or (l_element_set_name = 'SAN' and l_legislation_code = 'JP')) then
				l_salary_category := 'SANTEI';
			elsif (l_element_set_name like g_name_tl.geppen || '%'
         or (l_element_set_name = 'GEP' and l_legislation_code = 'JP')) then
				l_salary_category := 'GEPPEN';
			else
				l_salary_category := 'NA';
			end if;
		else
			hr_utility.set_location('pay_jp_custom_pkg.get_itax_category',30);
			--
			if l_element_type_id is not null then
				select	pet.element_name,
					pec.classification_name,
          pec.legislation_code
				into	l_element_name,
					l_classification_name,
          l_legislation_code
				from	pay_element_types_f		pet,
					pay_element_classifications	pec
				where	pet.element_type_id = l_element_type_id
				and	l_effective_date
					between pet.effective_start_date and pet.effective_end_date
				and	pec.classification_id = pet.classification_id;
				--
				-- This is special code branch for YEA by Balance Adjustment.
				--
				if l_element_name = g_name_tl.yea_element then
					l_salary_category := 'YEA';
				elsif l_element_name = g_name_tl.reyea_element then
					l_salary_category := 'RE_YEA';
				else
					l_salary_category := get_salary_category(l_classification_name,l_legislation_code);
				end if;
				--
			else
				-- This routine can't judge whether YEA and RE-YEA.
				-- So it's not recommended to use QuickPay Run and Balance Adjustment.
				for l_rec in csr_classification_name(p_assignment_action_id) loop
					if nvl(l_rec.balance_initialization_flag,'N') = 'Y' then
						hr_utility.set_location('pay_jp_custom_pkg.get_itax_category',40);
						--
						if (l_rec.element_name like g_name_tl.bal_init_prefix || g_name_tl.salary || '%'
               and (l_rec.element_name like 'INI_SAL%' and l_rec.legislation_code = 'JP')) then
							l_salary_category := 'SALARY';
							exit;
						elsif (l_rec.element_name like g_name_tl.bal_init_prefix || g_name_tl.bonus || '%'
               and (l_rec.element_name like 'INI_BON%' and l_rec.legislation_code = 'JP')) then
							l_salary_category := 'BONUS';
							exit;
						elsif (l_rec.element_name like g_name_tl.bal_init_prefix || g_name_tl.sp_bonus2 || '%'
               and (l_rec.element_name like 'INI_SPB%' and l_rec.legislation_code = 'JP')) then
							l_salary_category := 'SP_BONUS';
							exit;
						elsif (l_rec.element_name like g_name_tl.bal_init_prefix || g_name_tl.yea2 || '%'
               and (l_rec.element_name like 'INI_YEA%' and l_rec.legislation_code = 'JP')) then
							if (l_rec.element_name = g_name_tl.bal_init_prefix || g_name_tl.yea2 || '1'
                 and (l_rec.element_name = 'INI_YEA1' and l_rec.legislation_code = 'JP')) then
								open csr_itax_yea_category(p_assignment_action_id);
								fetch csr_itax_yea_category into l_itax_yea_category;
								if csr_itax_yea_category%FOUND then
									l_salary_category	:= 'YEA';
								else
									l_salary_category	:= 'NA';
									l_itax_yea_category	:= NULL;
								end if;
								close csr_itax_yea_category;
							else
								l_salary_category := 'NA';
							end if;
							exit;
						elsif (l_rec.element_name like g_name_tl.bal_init_prefix || g_name_tl.term2 || '%'
               and (l_rec.element_name like 'INI_YEA%' and l_rec.legislation_code = 'JP')) then
							l_salary_category := 'TERM';
							exit;
						elsif (l_rec.element_name like g_name_tl.bal_init_prefix || g_name_tl.santei || g_name_tl.geppen || '%'
               and (l_rec.element_name like 'INI_SAN_GEP%' and l_rec.legislation_code = 'JP')) then
							l_salary_category := 'SANTEI';
							exit;
						else
							l_salary_category := 'NA';
							exit;
						end if;
					else
						hr_utility.set_location('pay_jp_custom_pkg.get_itax_category',50);
						--
						l_salary_category := get_salary_category(l_rec.classification_name, l_rec.legislation_code);
						if l_salary_category <> 'NA' then
							exit;
						end if;
					end if;
				end loop;
			end if;
		end if;

		-- Initialize "Income Tax Category" and "YEA Category(If not initialized.)".
		if l_salary_category='SALARY' then
			l_itax_category	:= pay_jp_balance_pkg.get_result_value_char(g_itax.sal_elm_id,g_itax.sal_iv_id,p_assignment_action_id);
		elsif l_salary_category='BONUS' then
			l_itax_category	:= pay_jp_balance_pkg.get_result_value_char(g_itax.bon_elm_id,g_itax.bon_iv_id,p_assignment_action_id);
		elsif l_salary_category='SP_BONUS' then
			l_itax_category	:= pay_jp_balance_pkg.get_result_value_char(g_itax.sp_bon_elm_id,g_itax.sp_bon_iv_id,p_assignment_action_id);
		elsif l_salary_category in ('YEA','RE_YEA') then
			if l_itax_yea_category is NULL then
				l_itax_yea_category := nvl(pay_jp_balance_pkg.get_result_value_char(g_itax.yea_elm_id,g_itax.yea_category_iv_id,p_assignment_action_id),7);
			end if;
			--
			if l_itax_yea_category = '5' then
				l_itax_category := 'NON_RES';
			else
				--
				-- This is short term solution for non-resident case.
				-- Formula "KyuyoShotokuKoujogonoKingaku" should be fixed instead of this SQL.
				--
				if pay_jp_balance_pkg.get_entry_value_char(g_itax.gen_nr_iv_id,l_assignment_id,l_effective_date) = 'Y' then
					l_itax_category := 'NON_RES';
				else
					l_itax_category	:= pay_jp_balance_pkg.get_result_value_char(g_itax.yea_elm_id,g_itax.yea_iv_id,p_assignment_action_id);
				end if;
			end if;
		elsif l_salary_category = 'TERM' then
			l_itax_category := NULL;
		else
			l_itax_category := 'NA';
		end if;

		if l_itax_category is NULL then
			hr_utility.set_location('pay_jp_custom_pkg.get_itax_category',60);

--			l_nonresident := pay_jp_balance_pkg.get_entry_value_char(g_itax.gen_nr_iv_id,l_assignment_id,l_date_earned);

			l_non_res_date := pay_jp_balance_pkg.get_entry_value_date(g_itax.non_res_date_iv_id,l_assignment_id,l_effective_date);
			l_res_date := pay_jp_balance_pkg.get_entry_value_date(g_itax.res_date_iv_id,l_assignment_id,l_effective_date);

			if l_non_res_date is not null then
				if (l_non_res_date <= l_effective_date) and (l_effective_date < NVL(l_res_date,TO_DATE('47121231','yyyymmdd'))) then
					l_nonresident := 'Y';
				else
					l_nonresident := 'N';
				end if;
			else
				l_nonresident := pay_jp_balance_pkg.get_entry_value_char(g_itax.gen_nr_iv_id,l_assignment_id,l_effective_date);
			end if;

			if nvl(l_nonresident,'N') = 'Y' then
				l_itax_category	:= 'NON_RES';
			else
				l_itax_category	:= nvl(pay_jp_balance_pkg.get_entry_value_char(g_itax.gen_iv_id,l_assignment_id,l_effective_date),'E');
			end if;
		elsif l_itax_category = 'NA' then
			hr_utility.set_location('pay_jp_custom_pkg.get_itax_category',70);

			l_itax_category := NULL;
		end if;

		p_salary_category	:= l_salary_category;
		p_itax_category		:= l_itax_category;
		p_itax_yea_category	:= l_itax_yea_category;

		hr_utility.set_location('pay_jp_custom_pkg.get_itax_category',80);
	END GET_ITAX_CATEGORY;

-----------------------------------------------------------------------
	PROCEDURE FETCH_VALUES(
-----------------------------------------------------------------------
			P_BUSINESS_GROUP_ID	IN NUMBER,
			P_ASSIGNMENT_ACTION_ID	IN NUMBER,
			P_ASSIGNMENT_ID		IN NUMBER,
			P_DATE_EARNED		IN DATE,
			P_VALUE		 OUT NOCOPY value_rec)
	IS
		l_value	value_rec;
	BEGIN
		hr_utility.set_location('pay_jp_custom_pkg.get_itax_category',10);

		-- Get Salary Category, Itax Category and Itax Year-End-Adjustment Process Category.
		pay_jp_custom_pkg.get_itax_category(
			P_ASSIGNMENT_ACTION_ID	=> p_assignment_action_id,
			P_SALARY_CATEGORY	=> l_value.salary_category,
			P_ITAX_CATEGORY		=> l_value.itax_category,
			P_ITAX_YEA_CATEGORY	=> l_value.itax_yea_category);

		if l_value.salary_category = 'SALARY' then
			if l_value.itax_category = 'NON_RES' then
				l_value.taxable_sal_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sal_taxable_sal_nr,p_assignment_action_id);
				l_value.taxable_mat_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sal_taxable_mat_nr,p_assignment_action_id);
			else
				l_value.taxable_sal_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sal_taxable_sal,p_assignment_action_id);
				l_value.taxable_mat_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sal_taxable_mat,p_assignment_action_id);
				--
				-- Disaster Tax Reduction is available only for Residents.
				--
				l_value.disaster_tax_reduction := pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.disaster_tax_reduction,p_assignment_action_id);
			end if;
			l_value.hi_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.hi_org,p_assignment_id,p_date_earned);
			l_value.hi_prem_ee		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sal_hi_prem_ee,p_assignment_action_id);
			l_value.hi_prem_er		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.gen_hi_prem_er,p_assignment_action_id);
--			l_value.ci_prem_ee		:= nvl(pay_jp_balance_pkg.get_result_value_number(g_itax.ci_prem_sal_ee_elm_id,g_itax.ci_prem_sal_ee_iv_id,p_assignment_action_id),0)
--                                                        + nvl(pay_jp_balance_pkg.get_result_value_number(g_itax.ci_prem_sal_ee_elm_nonres_id,g_itax.ci_prem_sal_ee_iv_nonres_id,p_assignment_action_id),0);
--			l_value.ci_prem_er		:= nvl(pay_jp_balance_pkg.get_result_value_number(g_itax.ci_prem_sal_er_elm_id,g_itax.ci_prem_sal_er_iv_id,p_assignment_action_id),0);
			l_value.ci_prem_ee		:= nvl(pay_jp_balance_pkg.get_result_value_number(g_itax.ci_prem_sal_ee_elm_id,g_itax.ci_prem_sal_ee_iv_id,p_assignment_action_id),0)
                                                          + nvl(pay_jp_balance_pkg.get_result_value_number(g_itax.ci_prem_sal_ee_elm_nonres_id,g_itax.ci_prem_sal_ee_iv_nonres_id,p_assignment_action_id),0)
                                                          + nvl(pay_jp_balance_pkg.get_result_value_number(g_itax.ci_prem_sal_ee_elm_n_id,g_itax.ci_prem_sal_ee_iv_n_id,p_assignment_action_id),0)
                                                          + nvl(pay_jp_balance_pkg.get_result_value_number(g_itax.ci_prem_sal_ee_elm_nonres_n_id,g_itax.ci_prem_sal_ee_iv_nonres_n_id,p_assignment_action_id),0);
			l_value.ci_prem_er		:= nvl(pay_jp_balance_pkg.get_result_value_number(g_itax.ci_prem_sal_er_elm_id,g_itax.ci_prem_sal_er_iv_id,p_assignment_action_id),0)
                                                          + nvl(pay_jp_balance_pkg.get_result_value_number(g_itax.ci_prem_sal_er_elm_n_id,g_itax.ci_prem_sal_er_iv_n_id,p_assignment_action_id),0);
			l_value.wp_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.wp_org,p_assignment_id,p_date_earned);
			l_value.wp_prem_ee		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sal_wp_prem_ee,p_assignment_action_id);
			l_value.wp_prem_er		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.gen_wp_prem_er,p_assignment_action_id);
			l_value.wpf_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.wpf_org,p_assignment_id,p_date_earned);
			l_value.wpf_prem_ee		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sal_wpf_prem_ee,p_assignment_action_id);
			l_value.wpf_prem_er		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.gen_wpf_prem_er,p_assignment_action_id);
			l_value.ui_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.ui_org,p_assignment_id,p_date_earned);
			l_value.ui_category		:= pay_jp_balance_pkg.get_entry_value_char(g_iv.ui_category,p_assignment_id,p_date_earned);
			l_value.ui_prem_ee		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sal_ui_prem_ee,p_assignment_action_id);
			l_value.ui_sal_amt		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sal_ui_sal,p_assignment_action_id);
			l_value.wai_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.wai_org,p_assignment_id,p_date_earned);
			l_value.wai_category		:= pay_jp_balance_pkg.get_entry_value_char(g_iv.wai_category,p_assignment_id,p_date_earned);
			l_value.wai_sal_amt		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sal_wai_sal,p_assignment_action_id);
			l_value.itax_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.itax_org,p_assignment_id,p_date_earned);
			l_value.itax			:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sal_itax,p_assignment_action_id);
			l_value.ltax_district_code	:= pay_jp_balance_pkg.get_entry_value_char(g_iv.gen_ltax_district_code,p_assignment_id,p_date_earned);
			l_value.ltax			:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sal_ltax,p_assignment_action_id);
			l_value.ltax_lumpsum		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.gen_ltax_lumpsum,p_assignment_action_id);
			l_value.mutual_aid		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sal_mutual_aid,p_assignment_action_id);
		elsif l_value.salary_category = 'BONUS' then
			if l_value.itax_category = 'NON_RES' then
				l_value.taxable_sal_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.bon_taxable_sal_nr,p_assignment_action_id);
				l_value.taxable_mat_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.bon_taxable_mat_nr,p_assignment_action_id);
			else
				l_value.taxable_sal_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.bon_taxable_sal,p_assignment_action_id);
				l_value.taxable_mat_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.bon_taxable_mat,p_assignment_action_id);
				--
				-- Disaster Tax Reduction is available only for Residents.
				--
				l_value.disaster_tax_reduction := pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.disaster_tax_reduction,p_assignment_action_id);
			end if;
			l_value.hi_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.hi_org,p_assignment_id,p_date_earned);
			l_value.hi_prem_ee		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.bon_hi_prem_ee,p_assignment_action_id);
			l_value.hi_prem_er		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.gen_hi_prem_er,p_assignment_action_id);
			l_value.ci_prem_ee		:= nvl(pay_jp_balance_pkg.get_result_value_number(g_itax.ci_prem_bon_ee_elm_id,g_itax.ci_prem_bon_ee_iv_id,p_assignment_action_id),0)
                                                        + nvl(pay_jp_balance_pkg.get_result_value_number(g_itax.ci_prem_bon_ee_elm_nonres_id,g_itax.ci_prem_bon_ee_iv_nonres_id,p_assignment_action_id),0);
			l_value.ci_prem_er		:= nvl(pay_jp_balance_pkg.get_result_value_number(g_itax.ci_prem_bon_er_elm_id,g_itax.ci_prem_bon_er_iv_id,p_assignment_action_id),0);
			l_value.wp_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.wp_org,p_assignment_id,p_date_earned);
			l_value.wp_prem_ee		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.bon_wp_prem_ee,p_assignment_action_id);
			l_value.wp_prem_er		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.gen_wp_prem_er,p_assignment_action_id);
			-- added for bug 3803871
			l_value.wpf_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.wpf_org,p_assignment_id,p_date_earned);
			l_value.wpf_prem_ee		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.bon_wpf_prem_ee,p_assignment_action_id);
			l_value.wpf_prem_er		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.gen_wpf_prem_er,p_assignment_action_id);
			--
			l_value.ui_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.ui_org,p_assignment_id,p_date_earned);
			l_value.ui_category		:= pay_jp_balance_pkg.get_entry_value_char(g_iv.ui_category,p_assignment_id,p_date_earned);
			l_value.ui_prem_ee		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.bon_ui_prem_ee,p_assignment_action_id);
			l_value.ui_sal_amt		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.bon_ui_sal,p_assignment_action_id);
			l_value.wai_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.wai_org,p_assignment_id,p_date_earned);
			l_value.wai_category		:= pay_jp_balance_pkg.get_entry_value_char(g_iv.wai_category,p_assignment_id,p_date_earned);
			l_value.wai_sal_amt		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.bon_wai_sal,p_assignment_action_id);
			l_value.itax_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.itax_org,p_assignment_id,p_date_earned);
			l_value.itax			:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.bon_itax,p_assignment_action_id);
			l_value.ltax_district_code	:= pay_jp_balance_pkg.get_entry_value_char(g_iv.gen_ltax_district_code,p_assignment_id,p_date_earned);
			l_value.ltax_lumpsum		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.gen_ltax_lumpsum,p_assignment_action_id);
			l_value.mutual_aid		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.bon_mutual_aid,p_assignment_action_id);
		elsif l_value.salary_category = 'SP_BONUS' then
			if l_value.itax_category = 'NON_RES' then
				l_value.taxable_sal_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sp_bon_taxable_sal_nr,p_assignment_action_id);
				l_value.taxable_mat_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sp_bon_taxable_mat_nr,p_assignment_action_id);
			else
				l_value.taxable_sal_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sp_bon_taxable_sal,p_assignment_action_id);
				l_value.taxable_mat_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sp_bon_taxable_mat,p_assignment_action_id);
				--
				-- Disaster Tax Reduction is available only for Residents.
				--
				l_value.disaster_tax_reduction := pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.disaster_tax_reduction,p_assignment_action_id);
			end if;
			l_value.ui_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.ui_org,p_assignment_id,p_date_earned);
			l_value.ui_category		:= pay_jp_balance_pkg.get_entry_value_char(g_iv.ui_category,p_assignment_id,p_date_earned);
			l_value.ui_prem_ee		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sp_bon_ui_prem_ee,p_assignment_action_id);
			l_value.ui_sal_amt		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sp_bon_ui_sal,p_assignment_action_id);
			l_value.wai_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.wai_org,p_assignment_id,p_date_earned);
			l_value.wai_category		:= pay_jp_balance_pkg.get_entry_value_char(g_iv.wai_category,p_assignment_id,p_date_earned);
			l_value.wai_sal_amt		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sp_bon_wai_sal,p_assignment_action_id);
			l_value.itax_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.itax_org,p_assignment_id,p_date_earned);
			l_value.itax			:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sp_bon_itax,p_assignment_action_id);
			l_value.mutual_aid		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.sp_bon_mutual_aid,p_assignment_action_id);
		elsif l_value.salary_category in ('YEA','RE_YEA') then
			l_value.itax_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.itax_org,p_assignment_id,p_date_earned);
			l_value.itax_adjustment		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.yea_itax,p_assignment_action_id);
		elsif l_value.salary_category = 'TERM' then
			if l_value.itax_category = 'NON_RES' then
				l_value.taxable_sal_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.term_taxable_sal_nr,p_assignment_action_id);
				l_value.taxable_mat_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.term_taxable_mat_nr,p_assignment_action_id);
			else
				l_value.taxable_sal_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.term_taxable_sal,p_assignment_action_id);
				l_value.taxable_mat_amt	:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.term_taxable_mat,p_assignment_action_id);
			end if;
			l_value.itax_org_id		:= pay_jp_balance_pkg.get_entry_value_number(g_iv.itax_org,p_assignment_id,p_date_earned);
			l_value.itax			:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.term_itax,p_assignment_action_id);
			l_value.ltax_district_code	:= pay_jp_balance_pkg.get_entry_value_char(g_iv.gen_ltax_district_code,p_assignment_id,p_date_earned);
			l_value.ltax_lumpsum		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.gen_ltax_lumpsum,p_assignment_action_id);
			l_value.sp_ltax_district_code	:= pay_jp_balance_pkg.get_entry_value_char(g_iv.term_ltax_district_code,p_assignment_id,p_date_earned);
			l_value.sp_ltax			:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.term_ltax,p_assignment_action_id);
			l_value.sp_ltax_income		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.term_ltax_income,p_assignment_action_id);
			l_value.sp_ltax_shi		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.term_ltax_shi,p_assignment_action_id);
			l_value.sp_ltax_to		:= pay_jp_balance_pkg.get_balance_value_asg_run(g_bal.term_ltax_to,p_assignment_action_id);
		else -- in case 'GEPPEN', 'SANTEI', 'NA'.
			NULL;
		end if;

		p_value := l_value;

		hr_utility.set_location('pay_jp_custom_pkg.get_itax_category',20);
	END FETCH_VALUES;
END PAY_JP_CUSTOM_PKG;

/
