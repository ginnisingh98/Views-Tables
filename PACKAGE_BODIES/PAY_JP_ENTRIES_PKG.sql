--------------------------------------------------------
--  DDL for Package Body PAY_JP_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_ENTRIES_PKG" as
/* $Header: pyjpetr.pkb 120.1.12010000.2 2010/01/26 07:28:57 keyazawa ship $ */
--
-- Constant values used to remove Japanese characters(Temporary solution).
--
c_si_elm_name          constant pay_element_types_f.element_name%TYPE := 'COM_SI_INFO';
c_li_elm_name          constant pay_element_types_f.element_name%TYPE := 'COM_LI_INFO';
c_ci_elm_name          constant pay_element_types_f.element_name%TYPE := 'COM_CI_EXCLUDE_INFO';
c_hi_elm_name          constant pay_element_types_f.element_name%TYPE := 'COM_HI_QUALIFY_INFO';
c_wp_elm_name          constant pay_element_types_f.element_name%TYPE := 'COM_WP_QUALIFY_INFO';
c_wpf_elm_name         constant pay_element_types_f.element_name%TYPE := 'COM_WPF_QUALIFY_INFO';
c_ui_elm_name          constant pay_element_types_f.element_name%TYPE := 'COM_EI_QUALIFY_INFO';
c_hi_sal_elm_name      constant pay_element_types_f.element_name%TYPE := 'SAL_HI_PREM_PROC';
c_wp_sal_elm_name      constant pay_element_types_f.element_name%TYPE := 'SAL_WP_PREM_PROC';
c_ui_sal_elm_name      constant pay_element_types_f.element_name%TYPE := 'SAL_EI_PREM_PROC';
c_hi_bon_elm_name      constant pay_element_types_f.element_name%TYPE := 'BON_HI_PREM_PROC';
c_hi_bon2_elm_name     constant pay_element_types_f.element_name%TYPE := 'BON_HI_PREM_PROC';
c_wp_bon_elm_name      constant pay_element_types_f.element_name%TYPE := 'BON_WP_PREM_PROC';
c_wp_bon2_elm_name     constant pay_element_types_f.element_name%TYPE := 'BON_WP_PREM_PROC';
c_ui_bon_elm_name      constant pay_element_types_f.element_name%TYPE := 'BON_EI_PREM_PROC';
c_ui_sp_bon_elm_name   constant pay_element_types_f.element_name%TYPE := 'SPB_EI_PREM_PROC';
c_hi_comp_elm_name     constant pay_element_types_f.element_name%TYPE := 'COM_HI_SMR_INFO';
c_wp_comp_elm_name     constant pay_element_types_f.element_name%TYPE := 'COM_WP_SMR_INFO';
c_itax_elm_name        constant pay_element_types_f.element_name%TYPE := 'COM_ITX_INFO';
c_depends_elm_name     constant pay_element_types_f.element_name%TYPE := 'YEA_DEP_EXM_PROC';
c_insprems_elm_name    constant pay_element_types_f.element_name%TYPE := 'YEA_INS_PREM_SPOUSE_SP_EXM_INFO';
c_adj_elm_name         constant pay_element_types_f.element_name%TYPE := 'YEA_ADJ_INFO';
c_housing_elm_name     constant pay_element_types_f.element_name%TYPE := 'YEA_HOUSING_LOAN_TAX_CREDIT';
c_hld_elm_name	constant pay_element_types_f.element_name%TYPE := 'YEA_HOUSING_LOAN_INFO';
c_pjob_elm_name        constant pay_element_types_f.element_name%TYPE := 'YEA_PREV_EMP_INFO';
c_ltax_elm_name        constant pay_element_types_f.element_name%TYPE := 'COM_LTX_INFO';
c_term_elm_name        constant pay_element_types_f.element_name%TYPE := 'COM_TRM_INFO';
c_sp_ltax_elm_name     constant pay_element_types_f.element_name%TYPE := 'TRM_LTX_SP_WITHHOLD_PROC';
c_nonresident_elm_name constant pay_element_types_f.element_name%TYPE := 'COM_NRES_INFO';
--- Used by PAYJPCMA.fmx ---------------
c_cma_train_elm_name   constant pay_element_types_f.element_name%TYPE := 'SAL_CMA_PUBLIC_TRANSPORT_INFO';
c_cma_car_elm_name     constant pay_element_types_f.element_name%TYPE := 'SAL_CMA_PRIVATE_TRANSPORT_INFO';
--
-- Current Element Entry Row Hander "pay_ele_shd" does not comply with API
-- strategy. "pay_ele_shd" is like API, but not API. So this package
-- used in PAYJPTAX form implement part of real API to use DTCSAPI library.
--
g_old_rec		pay_element_entries_f%ROWTYPE;             -- Global record definition
g_package		varchar2(33) := '  pay_jp_entries_pkg.';   -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< element_name >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns element_name corresponding to element_code.
-- This is temporary solution in R11i.
--
Function element_name(
	p_element_code		in  varchar2) return varchar2
Is
	l_element_name	pay_element_types_f.element_name%TYPE;
Begin
	--- Used by PAYJPTAX.fmx ---------------
	if p_element_code = 'SI' then
		l_element_name := c_si_elm_name;
	elsif p_element_code = 'LI' then
		l_element_name := c_li_elm_name;
	elsif p_element_code = 'CI' then
		l_element_name := c_ci_elm_name;
	elsif p_element_code = 'HI' then
		l_element_name := c_hi_elm_name;
	elsif p_element_code = 'WP' then
		l_element_name := c_wp_elm_name;
	elsif p_element_code = 'WPF' then
		l_element_name := c_wpf_elm_name;
	elsif p_element_code = 'UI' then
		l_element_name := c_ui_elm_name;
	elsif p_element_code = 'HI_SAL' then
		l_element_name := c_hi_sal_elm_name;
	elsif p_element_code = 'WP_SAL' then
		l_element_name := c_wp_sal_elm_name;
	elsif p_element_code = 'UI_SAL' then
		l_element_name := c_ui_sal_elm_name;
	elsif p_element_code IN ('HI_BON', 'HI_BON2') then
		IF pay_jp_formula_function_pkg.get_jp_parameter('MIGRATION', 'TOTAL_REWARD_SYSTEM') = 'Y' THEN
			l_element_name := c_hi_bon2_elm_name;
		ELSE
			l_element_name := c_hi_bon_elm_name;
		END IF;
	elsif p_element_code IN ('WP_BON', 'WP_BON2') then
		IF pay_jp_formula_function_pkg.get_jp_parameter('MIGRATION', 'TOTAL_REWARD_SYSTEM') = 'Y' THEN
			l_element_name := c_wp_bon2_elm_name;
		ELSE
			l_element_name := c_wp_bon_elm_name;
		END IF;
	elsif p_element_code = 'UI_BON' then
		l_element_name := c_ui_bon_elm_name;
	elsif p_element_code = 'UI_SP_BON' then
		l_element_name := c_ui_sp_bon_elm_name;
	elsif p_element_code = 'HI_COMP' then
		l_element_name := c_hi_comp_elm_name;
	elsif p_element_code = 'WP_COMP' then
		l_element_name := c_wp_comp_elm_name;
	elsif p_element_code = 'ITAX' then
		l_element_name := c_itax_elm_name;
	elsif p_element_code = 'NONRESIDENT' then
		l_element_name := c_nonresident_elm_name;
	elsif p_element_code = 'DEPENDS' then
		l_element_name := c_depends_elm_name;
	elsif p_element_code = 'INSPREMS' then
		l_element_name := c_insprems_elm_name;
        elsif p_element_code = 'ADJ' then
                l_element_name := c_adj_elm_name;
	elsif p_element_code = 'HOUSING' then
		l_element_name := c_housing_elm_name;
	elsif p_element_code = 'HLD' then
		l_element_name := c_hld_elm_name;
	elsif p_element_code = 'PJOB' then
		l_element_name := c_pjob_elm_name;
	elsif p_element_code = 'LTAX' then
		l_element_name := c_ltax_elm_name;
	elsif p_element_code = 'TERM' then
		l_element_name := c_term_elm_name;
	elsif p_element_code = 'SP_LTAX' then
		l_element_name := c_sp_ltax_elm_name;
	--- Used by PAYJPCMA.fmx ---------------
	elsif p_element_code = 'TRAIN_VALUES' then
		l_element_name := c_cma_train_elm_name;
	elsif p_element_code = 'CAR_VALUES' then
		l_element_name := c_cma_car_elm_name;
	end if;
	--
	-- Return.
	--
	return	l_element_name;
End element_name;
--
-- ----------------------------------------------------------------------------
-- |------------------------< derive_attributes >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure returns element and input value attributes for p_elm_code_tbl
-- input parameters like INPUT_CURRENCY_CODE, UOM etc.
-- p_business_group_id must be not null.
--
Procedure derive_attributes(
	p_elm_code_tbl		in     elm_code_tbl,
	p_effective_date	in     date,
	p_business_group_id	in     number,
	p_elm_rec_tbl	 out nocopy    elm_rec_tbl,
	p_iv_rec_tbl	 out nocopy    iv_rec_tbl)
Is
	l_index		number;
	l_elm_rec	pay_element_types_f%ROWTYPE;
  l_effective_date date;
	Cursor csr_iv(
    p_element_type_id number,
    p_eff_date date) is
		select	piv.input_value_id,
			piv.display_sequence,
			piv.uom,
			piv.mandatory_flag
		from	pay_input_values_f	piv
		where	piv.element_type_id = p_element_type_id
		and	p_eff_date
			between piv.effective_start_date and piv.effective_end_date;
Begin
	l_index := p_elm_code_tbl.first;
	--
	-- Fetch element attributes.
	--
	while l_index is not NULL loop
  --
    l_effective_date := p_effective_date;
    if p_elm_code_tbl(l_index) = 'HLD' then
    --
      l_effective_date := greatest(p_effective_date,to_date('2009/04/01','YYYY/MM/DD'));
    --
    end if;
  --
		l_elm_rec := hr_jp_id_pkg.element_type_rec(element_name(p_elm_code_tbl(l_index)),
						p_business_group_id,NULL,l_effective_date,'FALSE');
		--
		-- When not found, raise error.
		--
		if l_elm_rec.element_type_id is NULL then
			hr_utility.set_message(801,'HR_7478_PLK_INCONSISTENT_ELE');
			hr_utility.set_message_token('ELEMENT_TYPE_ID',NULL);
			hr_utility.set_message_token('ELEMENT_NAME',p_elm_code_tbl(l_index));
			hr_utility.raise_error;
		else
			p_elm_rec_tbl(l_elm_rec.element_type_id).element_code			:= p_elm_code_tbl(l_index);
			p_elm_rec_tbl(l_elm_rec.element_type_id).input_currency_code		:= l_elm_rec.input_currency_code;
			p_elm_rec_tbl(l_elm_rec.element_type_id).multiple_entries_allowed_flag	:= l_elm_rec.multiple_entries_allowed_flag;
		end if;
		--
		-- Fetch input value attributes.
		--
		for l_rec in csr_iv(
      l_elm_rec.element_type_id,
      l_effective_date) loop
			p_iv_rec_tbl(l_rec.input_value_id).element_type_id	:= l_elm_rec.element_type_id;
			p_iv_rec_tbl(l_rec.input_value_id).display_sequence	:= l_rec.display_sequence;
			p_iv_rec_tbl(l_rec.input_value_id).uom			:= l_rec.uom;
			p_iv_rec_tbl(l_rec.input_value_id).mandatory_flag	:= l_rec.mandatory_flag;
		end loop;
		--
		-- Increment counter.
		--
		l_index := p_elm_code_tbl.next(l_index);
	end loop;
End derive_attributes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< derive_format_mask >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Derive format mask for p_iv_rec_tbl input parameter.
-- This procedure is designed to reduce network traffic because
-- fnd_currency.get_format_mask function accesses to DB.
--
Procedure derive_format_mask(
	p_elm_rec_tbl		in     elm_rec_tbl,
	p_iv_rec_tbl		in out nocopy iv_rec_tbl)
Is
	l_index		number;
Begin
	l_index := p_iv_rec_tbl.first;
	while l_index is not NULL loop
		--
		-- Only supported with uom = 'M'(Money) currently.
		--
		if p_iv_rec_tbl(l_index).uom = 'M' then
			if p_iv_rec_tbl(l_index).max_length is not NULL then
				p_iv_rec_tbl(l_index).format_mask := fnd_currency.get_format_mask(
									p_elm_rec_tbl(p_iv_rec_tbl(l_index).element_type_id).input_currency_code,
									p_iv_rec_tbl(l_index).max_length);
			end if;
		end if;
		--
		-- Increment counter.
		--
		l_index := p_iv_rec_tbl.next(l_index);
	end loop;
End derive_format_mask;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_entry >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure checks checks entry can be created or not.
-- This procedure is interface for hr_entry.check_element_entry procedure.
--
Procedure chk_entry(
	p_element_entry_id	in     number,
	p_assignment_id		in     number,
	p_element_link_id	in     number,
	p_entry_type		in     varchar2,
	p_original_entry_id	in     number   default null,
	p_target_entry_id	in     number   default null,
	p_effective_date	in     date,
	p_validation_start_date	in     date,
	p_validation_end_date	in     date,
	p_effective_start_date	in out nocopy date,
	p_effective_end_date	in out nocopy date,
	p_usage			in     varchar2,
	p_dt_update_mode	in     varchar2,
	p_dt_delete_mode	in     varchar2)
Is
Begin
	hr_entry.chk_element_entry(
		p_element_entry_id	=> p_element_entry_id,
		p_original_entry_id	=> p_original_entry_id,
		p_session_date		=> p_effective_date,
		p_element_link_id	=> p_element_link_id,
		p_assignment_id		=> p_assignment_id,
		p_entry_type		=> p_entry_type,
		p_effective_start_date	=> p_effective_start_date,
		p_effective_end_date	=> p_effective_end_date,
		p_validation_start_date	=> p_validation_start_date,
		p_validation_end_date	=> p_validation_end_date,
		p_dt_update_mode	=> p_dt_update_mode,
		p_dt_delete_mode	=> p_dt_delete_mode,
		p_usage			=> p_usage,
		p_target_entry_id	=> p_target_entry_id);
End chk_entry;
--
-- ----------------------------------------------------------------------------
-- |---------------------< derive_default_values >----------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure derive default values for p_element_code input parameter.
--
Procedure derive_default_values(
	p_assignment_id		in     number,
	p_element_code		in     varchar2,
	p_business_group_id	in     varchar2,
	p_entry_type            in     varchar2,
	p_element_link_id	out nocopy    number,
	p_ev_rec_tbl		out nocopy    ev_rec_tbl,
	p_effective_date	in     date,
	p_effective_start_date	in out nocopy date,
	p_effective_end_date	in out nocopy date)
Is
	l_element_type_id	number;
	l_counter		number;
	Cursor csr_default_value is
		select	piv.input_value_id,
			piv.display_sequence,
			decode(piv.hot_default_flag,
					'Y',nvl(pliv.default_value,piv.default_value),
					pliv.default_value)	DEFAULT_VALUE,
			decode(piv.lookup_type,NULL,NULL,
				hr_general.decode_lookup(
						piv.lookup_type,
						decode(piv.hot_default_flag,
							'Y',nvl(pliv.default_value,piv.default_value),
							pliv.default_value)))	D_DEFAULT_VALUE
		from	pay_input_values_f	piv,
			pay_link_input_values_f	pliv
		where	pliv.element_link_id = p_element_link_id
		and	p_effective_date
			between pliv.effective_start_date and pliv.effective_end_date
		and	piv.input_value_id = pliv.input_value_id
		and	p_effective_date
			between piv.effective_start_date and piv.effective_end_date
		order by piv.display_sequence;
Begin
	--
	-- Fetch eligible element_link_id for the assignment.
	--
	l_element_type_id	:= hr_jp_id_pkg.element_type_id(element_name(p_element_code),p_business_group_id);
	p_element_link_id	:= hr_entry_api.get_link(
					p_assignment_id		=> p_assignment_id,
					p_element_type_id	=> l_element_type_id,
					p_session_date		=> p_effective_date);
	if p_element_link_id is NULL then
		hr_utility.set_message(801,'HR_7027_ELE_ENTRY_EL_NOT_EXST');
		hr_utility.set_message_token('DATE',fnd_date.date_to_displaydate(p_effective_date));
		hr_utility.raise_error;
	end if;
	--
	-- At first, checks whether the entry is available.
	--
	chk_entry(
		p_element_entry_id	=> NULL,
		p_assignment_id		=> p_assignment_id,
		p_element_link_id	=> p_element_link_id,
		p_entry_type		=> p_entry_type,
		p_effective_date	=> p_effective_date,
		p_validation_start_date	=> NULL,
		p_validation_end_date	=> NULL,
		p_effective_start_date	=> p_effective_start_date,
		p_effective_end_date	=> p_effective_end_date,
		p_usage			=> 'INSERT',
		p_dt_update_mode	=> NULL,
		p_dt_delete_mode	=> NULL);
	--
	-- If entry is available, fetch default values.
	-- Must initialize varray variables.
	--
	l_counter	:= 0;
--	p_ev_rec_tbl	:= ev_rec_tbl();
	for l_rec in csr_default_value loop
		l_counter := l_counter + 1;
--		p_ev_rec_tbl.extend;
		--
		-- Japanese element entry specific routine.
		-- These would be moved to PERSON datetrack DDF in R12.
		--
		if l_rec.default_value is not NULL then
			if (p_element_code = 'SI' and l_rec.display_sequence in (1,3,6))
			or (p_element_code = 'LI' and l_rec.display_sequence in (2,5))
			or (p_element_code = 'ITAX' and l_rec.display_sequence = 2) then
				l_rec.d_default_value := hr_jp_general_pkg.decode_org(to_number(l_rec.default_value));
			elsif (p_element_code = 'LTAX' and l_rec.display_sequence = 2)
			or    (p_element_code = 'SP_LTAX' and l_rec.display_sequence = 1) then
				l_rec.d_default_value := hr_jp_general_pkg.decode_district(substrb(l_rec.d_default_value,1,5));
			end if;
		end if;
		p_ev_rec_tbl(l_counter).input_value_id	:= l_rec.input_value_id;
		p_ev_rec_tbl(l_counter).entry_value	:= l_rec.default_value;
		p_ev_rec_tbl(l_counter).d_entry_value	:= l_rec.d_default_value;
	end loop;
End derive_default_values;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_formula >------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure execute formula validation for input value.
--
Procedure chk_formula(
	p_formula_id		in  number,
	p_entry_value		in  varchar2,
	p_business_group_id	in  number,
	p_assignment_id		in  number,
	p_date_earned		in  date,
	p_formula_status out nocopy varchar2,
	p_formula_message out nocopy varchar2)
Is
	l_counter	NUMBER := 0;
	l_inputs	ff_exec.inputs_t;
	l_outputs	ff_exec.outputs_t;
	Cursor csr_fdi is
		select	item_name						NAME,
			decode(data_type,'T','TEXT','N','NUMBER','D','DATE')	DATATYPE,
			decode(usage,'U','CONTEXT','INPUT')			CLASS
		from	ff_fdi_usages_f
		where	formula_id = p_formula_id
		and	p_date_earned
			between effective_start_date and effective_end_date;
BEGIN
	--
	-- Initialize formula informations.
	--
	ff_exec.init_formula(
			p_formula_id		=> p_formula_id,
			p_effective_date	=> p_date_earned,
			p_inputs		=> l_inputs,
			p_outputs		=> l_outputs);
	--
	-- Setup input variables.
	--
	l_counter := l_inputs.first;
	while l_counter is not NULL loop
		if l_inputs(l_counter).name = 'BUSINESS_GROUP_ID' then
			l_inputs(l_counter).value := fnd_number.number_to_canonical(p_business_group_id);
		elsif l_inputs(l_counter).name = 'ASSIGNMENT_ID' then
			l_inputs(l_counter).value := fnd_number.number_to_canonical(p_assignment_id);
		elsif l_inputs(l_counter).name = 'DATE_EARNED' then
			l_inputs(l_counter).value := fnd_date.date_to_canonical(p_date_earned);
		elsif l_inputs(l_counter).name = 'ENTRY_VALUE' then
			l_inputs(l_counter).value := p_entry_value;
		end if;
		l_counter := l_inputs.next(l_counter);
	end loop;
	--
	-- Execute formula. Formula unexpected error is raised by ffexec,
	-- so not necessary to handle error.
	--
	ff_exec.run_formula(
			p_inputs		=> l_inputs,
			p_outputs		=> l_outputs,
			p_use_dbi_cache		=> FALSE);
	--
	-- Setup output variables.
	--
	l_counter := l_outputs.first;
	while l_counter is not NULL loop
		if l_outputs(l_counter).name = 'FORMULA_STATUS' then
			p_formula_status := l_outputs(l_counter).value;
		elsif l_outputs(l_counter).name = 'FORMULA_MESSAGE' then
			p_formula_message := l_outputs(l_counter).value;
		end if;
		l_counter := l_outputs.next(l_counter);
	end loop;
End chk_formula;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_entry_value >----------------------------|
-- ----------------------------------------------------------------------------
--
-- This function can not validate "user enterable flag".
-- Never call this procedure when p_display_value is NULL on Forms
-- WHEN-VALIDATE-ITEM trigger which will raise unexpected error.
-- Remeber hot defaulted value is not validated.
--
Procedure chk_entry_value(
	p_element_link_id	in     number,
	p_input_value_id	in     number,
	p_effective_date	in     date,
	p_business_group_id     in     number,
	p_assignment_id         in     number,
	p_user_value		in out nocopy varchar2,
	p_canonical_value out nocopy    varchar2,
	p_hot_defaulted	 out nocopy    boolean,
	p_min_max_warning out nocopy    boolean,
	p_user_min_value out nocopy    varchar2,
	p_user_max_value out nocopy    varchar2,
	p_formula_warning out nocopy    boolean,
	p_formula_message out nocopy    varchar2)
Is
	l_min_max_status	varchar2(1);
	l_formula_status	varchar2(1);
	Cursor csr_iv is
		select	pivtl.name,
			piv.uom,
			piv.mandatory_flag,
			piv.hot_default_flag,
			piv.lookup_type,
			decode(piv.hot_default_flag,
					'Y',nvl(pliv.default_value,piv.default_value),
					pliv.default_value)	DEFAULT_VALUE,
--			decode(piv.lookup_type,NULL,NULL,
--				hr_general.decode_lookup(
--						piv.lookup_type,
--						decode(piv.hot_default_flag,
--							'Y',nvl(pliv.default_value,piv.default_value),
--							pliv.default_value)))	D_DEFAULT_VALUE,
			decode(piv.hot_default_flag,
					'Y',nvl(pliv.min_value,piv.min_value),
					pliv.min_value)		MIN_VALUE,
			decode(piv.hot_default_flag,
					'Y',nvl(pliv.max_value,piv.max_value),
					pliv.max_value)		MAX_VALUE,
			piv.formula_id,
			decode(piv.hot_default_flag,
					'Y',nvl(pliv.warning_or_error,piv.warning_or_error),
					pliv.warning_or_error)	WARNING_OR_ERROR,
			pet.input_currency_code
		from	pay_element_types_f	pet,
			pay_input_values_f_tl	pivtl,
			pay_input_values_f	piv,
			pay_link_input_values_f	pliv
		where	pliv.element_link_id = p_element_link_id
		and	pliv.input_value_id = p_input_value_id
		and	p_effective_date
			between pliv.effective_start_date and pliv.effective_end_date
		and	piv.input_value_id = pliv.input_value_id
		and	p_effective_date
			between piv.effective_start_date and piv.effective_end_date
		and	pivtl.input_value_id = piv.input_value_id
		and	pivtl.language = userenv('LANG')
		and	pet.element_type_id = piv.element_type_id
		and	p_effective_date
			between pet.effective_start_date and pet.effective_end_date;
	l_rec	csr_iv%ROWTYPE;
	l_d_uom	hr_lookups.meaning%TYPE;
Begin
	--
	-- Initialize output variables.
	--
	p_canonical_value	:= NULL;
	p_hot_defaulted		:= FALSE;
	p_min_max_warning	:= FALSE;
	p_user_min_value	:= NULL;
	p_user_max_value	:= NULL;
	p_formula_warning	:= FALSE;
	p_formula_message	:= NULL;
	--
	-- When p_input_value_id is not NULL then validate.
	--
	If p_input_value_id is not NULL then
		--
		-- Fetch input value attributes.
		--
		open csr_iv;
		fetch csr_iv into l_rec;
		If csr_iv%NOTFOUND then
			close csr_iv;
			hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
			hr_utility.set_message_token('PROCEDURE','hr_entry.check_format');
			hr_utility.set_message_token('STEP','1');
			hr_utility.raise_error;
		End If;
		close csr_iv;
		--
		-- When user entered value is NULL.
		--
		If p_user_value is NULL then
			--
			-- Mandatory Validation.
			--
			If l_rec.mandatory_flag = 'Y' then
				--
				-- When not hot defaulted.
				--
				If l_rec.hot_default_flag = 'N' then
					hr_utility.set_message(801,'HR_6127_ELE_ENTRY_VALUE_MAND');
					hr_utility.set_message_token('INPUT_VALUE_NAME',l_rec.name);
					hr_utility.raise_error;
				--
				-- When hot defaulted.
				--
				Else
					If l_rec.default_value is NULL then
						hr_utility.set_message(801,'HR_6128_ELE_ENTRY_MAND_HOT');
						hr_utility.set_message_token('INPUT_VALUE_NAME',l_rec.name);
						hr_utility.raise_error;
					Else
						p_canonical_value := l_rec.default_value;
						hr_chkfmt.changeformat(
							input		=> p_canonical_value,
							output		=> p_user_value,
							format		=> l_rec.uom,
							curcode		=> l_rec.input_currency_code);
					End If;
				End If;
			End If;
		End If;
		--
		-- When p_user_value is not NULL.
		-- Hot defaulted value is validated again in the following routine.
		--
		If p_user_value is not NULL then
			--
			-- Check format validation(format, min and max validations).
			-- Hot defaulted value is validated again for range validation.
			--
			Begin
				hr_chkfmt.checkformat(
					value		=> p_user_value,
					format		=> l_rec.uom,
					output		=> p_canonical_value,
					minimum		=> l_rec.min_value,
					maximum		=> l_rec.max_value,
					nullok		=> 'Y',
					rgeflg		=> l_min_max_status,
					curcode		=> l_rec.input_currency_code);
			Exception
				--
				-- In case the value input is incorrect format.
				--
				when others then
					l_d_uom := hr_general.decode_lookup('UNITS',l_rec.uom);
					hr_utility.set_message(801,'PAY_6306_INPUT_VALUE_FORMAT');
					hr_utility.set_message_token('UNIT_OF_MEASURE',l_d_uom);
					hr_utility.raise_error;
			End;
			--
			-- Format min_value and max_value for output parameters.
			-- These parameters should be used for message only.
			--
			If l_rec.min_value is not NULL then
				hr_chkfmt.changeformat(
					input		=> l_rec.min_value,
					output		=> p_user_min_value,
					format		=> l_rec.uom,
					curcode		=> l_rec.input_currency_code);
			End If;
			If l_rec.max_value is not NULL then
				hr_chkfmt.changeformat(
					input		=> l_rec.max_value,
					output		=> p_user_max_value,
					format		=> l_rec.uom,
					curcode		=> l_rec.input_currency_code);
			End If;
			--
			-- If warning_or_error = 'E'(Error) and l_min_max_status = 'F'(Fatal),
			-- then raise error. In case of 'W'(Warning), Forms should warn to user
			-- with fnd_message.warn procedure.
			--
			If l_min_max_status = 'F' and l_rec.warning_or_error = 'E' then
				hr_utility.set_message(801,'PAY_JP_INPUTV_OUT_OF_RANGE');
				hr_utility.set_message_token('MIN_VALUE',p_user_min_value);
				hr_utility.set_message_token('MAX_VALUE',p_user_max_value);
				hr_utility.raise_error;
			End If;
			--
			-- Execute formula validation.
			--
			If l_rec.formula_id is not NULL then
				chk_formula(
					p_formula_id		=> l_rec.formula_id,
					p_entry_value		=> p_canonical_value,
					p_business_group_id	=> p_business_group_id,
					p_assignment_id		=> p_assignment_id,
					p_date_earned		=> p_effective_date,
					p_formula_status	=> l_formula_status,
					p_formula_message	=> p_formula_message);
			End If;
			--
			-- If warning_or_error = 'E'(Error) and l_formula_status = 'E'(Error),
			-- then raise error. In case of 'W'(Warning), Forms should warn to user
			-- with fnd_message.warn procedure.
			--
			If l_formula_status = 'E' and l_rec.warning_or_error = 'E' then
				hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
				hr_utility.set_message_token('FORMULA_TEXT',p_formula_message);
				hr_utility.raise_error;
			End If;
			--
			-- In case lookup_type validation is applied.
			--
			If l_rec.lookup_type is not NULL then
				--
				-- Lookup_type validation with effective_date.
				--
				If hr_api.not_exists_in_hr_lookups(
						p_effective_date	=> p_effective_date,
						p_lookup_type		=> l_rec.lookup_type,
						p_lookup_code		=> p_canonical_value) then
					hr_utility.set_message(801,'HR_7033_ELE_ENTRY_LKUP_INVLD');
					hr_utility.set_message_token('LOOKUP_TYPE',l_rec.lookup_type);
					hr_utility.raise_error;
				End If;
			End If;
		End If;
		--
		-- Set output variables.
		--
		If l_min_max_status = 'F' then
			p_min_max_warning := TRUE;
		End If;
		If l_formula_status = 'E' then
			p_formula_warning := TRUE;
		End If;
		If l_rec.hot_default_flag = 'Y' and p_canonical_value = l_rec.default_value then
			p_hot_defaulted := TRUE;
		End If;
	--
	-- When p_input_value_id is NULL.
	--
	Else
		p_user_value := NULL;
	End If;
End chk_entry_value;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Mandatory procedure to use DTCSAPI.pll forms library. This procedure returns
-- which datetrack modes are available when updating.
--
Procedure find_dt_upd_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_correction	 out nocopy boolean,
	 p_update	 out nocopy boolean,
	 p_update_override out nocopy boolean,
	 p_update_change_insert out nocopy boolean)
Is
--
  l_proc 	varchar2(72) := g_package||'find_dt_upd_modes';
--
  l_entry_type		pay_element_entries_f.entry_type%TYPE;
  l_processing_type	pay_element_types_f.processing_type%TYPE;
--
  Cursor C_Sel1 Is
    select  pee.entry_type,
            pet.processing_type
    from    pay_element_types_f		pet,
            pay_element_links_f		pel,
            pay_element_entries_f	pee
    where   pee.element_entry_id = p_base_key_value
    and     p_effective_date
            between pee.effective_start_date and pee.effective_end_date
    and     pel.element_link_id = pee.element_link_id
    and     p_effective_date
            between pel.effective_start_date and pel.effective_end_date
    and     pet.element_type_id = pel.element_type_id
    and     p_effective_date
            between pet.effective_start_date and pet.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_entry_type,
		    l_processing_type;
  If C_Sel1%notfound then
    Close C_Sel1;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
--
  If l_processing_type = 'N' or
     l_entry_type <> 'E' then
    p_correction		:= true;
    p_update			:= false;
    p_update_override		:= false;
    p_update_change_insert	:= false;
  Else
    --
    -- Call the corresponding datetrack api
    --
    dt_api.find_dt_upd_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'pay_element_entries_f',
	 p_base_key_column	=> 'element_entry_id',
	 p_base_key_value	=> p_base_key_value,
	 p_correction		=> p_correction,
	 p_update		=> p_update,
	 p_update_override	=> p_update_override,
	 p_update_change_insert	=> p_update_change_insert);
  End If;
  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Mandatory procedure to use DTCSAPI.pll forms library. This procedure returns
-- which datetrack modes are available when deleting.
--
Procedure find_dt_del_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_zap		 out nocopy boolean,
	 p_delete	 out nocopy boolean,
	 p_future_change out nocopy boolean,
	 p_delete_next_change out nocopy boolean)
Is
--
  l_proc 		varchar2(72) 	:= g_package||'find_dt_del_modes';
--
  l_parent_key_value1	number;
  l_parent_key_value2	number;
  l_entry_type		pay_element_entries_f.entry_type%TYPE;
  l_processing_type	pay_element_types_f.processing_type%TYPE;
--
  Cursor C_Sel1 Is
    select  pee.assignment_id,
            pee.element_link_id,
            pee.entry_type,
            pet.processing_type
    from    pay_element_types_f		pet,
            pay_element_links_f		pel,
            pay_element_entries_f	pee
    where   pee.element_entry_id = p_base_key_value
    and     p_effective_date
            between pee.effective_start_date and pee.effective_end_date
    and     pel.element_link_id = pee.element_link_id
    and     p_effective_date
            between pel.effective_start_date and pel.effective_end_date
    and     pet.element_type_id = pel.element_type_id
    and     p_effective_date
            between pet.effective_start_date and pet.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1,
		    l_parent_key_value2,
		    l_entry_type,
		    l_processing_type;
  If C_Sel1%notfound then
    Close C_Sel1;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
--
  If l_processing_type = 'N' or
     l_entry_type <> 'E' then
    p_zap			:= true;
    p_delete			:= false;
    p_future_change		:= false;
    p_delete_next_change	:= false;
  Else
    --
    -- Call the corresponding datetrack api
    --
    dt_api.find_dt_del_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'pay_element_entries_f',
	 p_base_key_column	=> 'element_entry_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'per_all_assignments_f',
	 p_parent_key_column1	=> 'assignment_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_parent_table_name2	=> 'pay_element_links_f',
	 p_parent_key_column2	=> 'element_link_id',
	 p_parent_key_value2	=> l_parent_key_value2,
	 p_zap			=> p_zap,
	 p_delete		=> p_delete,
	 p_future_change	=> p_future_change,
	 p_delete_next_change	=> p_delete_next_change);
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Optional procedure to use DTCSAPI.pll forms library. This procedure is
-- used to lock parent tables when inserting not to violate locking ladder.
--
Procedure ins_lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_rec	 		 in  pay_element_entries_f%ROWTYPE,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date)
Is
--
  l_proc		  varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the datetrack mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
        (p_effective_date          => p_effective_date,
         p_datetrack_mode          => p_datetrack_mode,
         p_base_table_name         => 'pay_element_entries_f',
         p_base_key_column         => 'element_entry_id',
         p_base_key_value          => p_rec.element_entry_id,
         p_parent_table_name1      => 'per_all_assignments_f',
         p_parent_key_column1      => 'assignment_id',
         p_parent_key_value1       => p_rec.assignment_id,
         p_parent_table_name2      => 'pay_element_links_f',
         p_parent_key_column2      => 'element_link_id',
         p_parent_key_value2       => p_rec.element_link_id,
         p_enforce_foreign_locking => true,
         p_validation_start_date   => l_validation_start_date,
         p_validation_end_date     => l_validation_end_date);
  --
  --
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Mandatory procedure to use DTCSAPI.pll forms library. This procedure is
-- used to lock parent and child tables when updating or deleting not to violate
-- locking ladder.
--
Procedure lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_element_entry_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date)
Is
--
  l_proc		  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_object_invalid 	  exception;
  l_argument		  varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select  *
    from    pay_element_entries_f
    where   element_entry_id = p_element_entry_id
    and	    p_effective_date  between effective_start_date
                              and     effective_end_date
    for update nowait;
  --
  -- The following code is not supported in this package.
  --
  -- Cursor C_Sel3 select comment text
  --
  -- Cursor C_Sel3 is
  --   select hc.comment_text
  --   from   hr_comments hc
  --   where  hc.comment_id = g_old_rec.comment_id;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'element_entry_id',
                             p_argument_value => p_element_entry_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'object_version_number',
                             p_argument_value => p_object_version_number);
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> 'INSERT') then
    --
    -- We must select and lock the current row.
    --
    Open  C_Sel1;
    Fetch C_Sel1 Into g_old_rec;
    If C_Sel1%notfound then
      Close C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
    End If;
    Close C_Sel1;
    --
    -- Check if the set object version number is the same as the existing
    -- object version number
    --
    If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
    End If;
    hr_utility.set_location(l_proc, 15);
    --
    -- Providing we are doing an update and a comment_id exists then
    -- we select the comment text.
    --
    -- The following code is not supported in this package.
    --
    -- If ((g_old_rec.comment_id is not null)             and
    --     (p_datetrack_mode = 'UPDATE'                   or
    --      p_datetrack_mode = 'CORRECTION'               or
    --      p_datetrack_mode = 'UPDATE_OVERRIDE'          or
    --      p_datetrack_mode = 'UPDATE_CHANGE_INSERT')) then
    --   Open C_Sel3;
    --   Fetch C_Sel3 Into g_old_rec.comment_text;
    --   If C_Sel3%notfound then
    --     --
    --     -- The comment_text for the specified comment_id does not exist.
    --     -- We must error due to data integrity problems.
    --     --
    --     Close C_Sel3;
    --     hr_utility.set_message(801, 'HR_7202_COMMENT_TEXT_NOT_EXIST');
    --     hr_utility.raise_error;
    --   End If;
    --   Close C_Sel3;
    -- End If;
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    hr_utility.set_location('Entering validation_dt_mode', 15);
    dt_api.validate_dt_mode
        (p_effective_date          => p_effective_date,
         p_datetrack_mode          => p_datetrack_mode,
         p_base_table_name         => 'pay_element_entries_f',
         p_base_key_column         => 'element_entry_id',
         p_base_key_value          => p_element_entry_id,
         p_parent_table_name1      => 'per_all_assignments_f',
         p_parent_key_column1      => 'assignment_id',
         p_parent_key_value1       => g_old_rec.assignment_id,
         p_parent_table_name2      => 'pay_element_links_f',
         p_parent_key_column2      => 'element_link_id',
         p_parent_key_value2       => g_old_rec.element_link_id,
         p_enforce_foreign_locking => true,
         p_validation_start_date   => l_validation_start_date,
         p_validation_end_date     => l_validation_end_date);
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
    --
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'pay_element_entries_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'pay_element_entries_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< init_varray >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Currently not used because forms6 can not handle varray correctly.
--
Procedure init_varray(
	p_ev_rec_tbl		in out nocopy ev_rec_tbl)
Is
	l_counter	number;
Begin
	--
	-- Initialize if null.
	--
--	if p_ev_rec_tbl is NULL then
--		p_ev_rec_tbl := ev_rec_tbl();
--	end if;
	--
	-- Extend varray variable up to g_iv_max global variable.
	--
	l_counter := p_ev_rec_tbl.count;
	for i in l_counter + 1..g_iv_max loop
--		p_ev_rec_tbl.extend;
		p_ev_rec_tbl(i).input_value_id := NULL;
	end loop;
End init_varray;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins >------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Procedure which issues insert dml.
--
Procedure ins(
	p_validate		in  boolean,
	p_effective_date	in  date,
	p_assignment_id		in  number,
	p_element_link_id	in  number,
	p_ev_rec_tbl		in  ev_rec_tbl,
	p_attribute_tbl		in  attribute_tbl,
	p_business_group_id	in  number,
	p_element_entry_id out nocopy number,
	p_effective_start_date out nocopy date,
	p_effective_end_date out nocopy date,
	p_object_version_number out nocopy number)
Is
	l_warning		BOOLEAN;
	l_ev_rec_tbl		ev_rec_tbl := p_ev_rec_tbl;
Begin
	init_varray(l_ev_rec_tbl);
	py_element_entry_api.create_element_entry(
		P_VALIDATE			=> p_validate,
		P_EFFECTIVE_DATE		=> p_effective_date,
		P_BUSINESS_GROUP_ID		=> p_business_group_id,
/*		P_ORIGINAL_ENTRY_ID		=> NULL,*/
		P_ASSIGNMENT_ID			=> p_assignment_id,
		P_ELEMENT_LINK_ID		=> p_element_link_id,
		P_ENTRY_TYPE			=> 'E',
/*		P_COST_ALLOCATION_KEYFLEX_ID	=> NULL,
		P_UPDATING_ACTION_ID		=> NULL,
		P_COMMENT_ID			=> NULL,
		P_REASON			=> NULL,
		P_TARGET_ENTRY_ID		=> NULL,
		P_SUBPRIORITY			=> NULL,
		P_DATE_EARNED			=> NULL,
		P_PERSONAL_PAYMENT_METHOD_ID	=> NULL,*/
		P_ATTRIBUTE_CATEGORY		=> p_attribute_tbl.attribute_category,
		P_ATTRIBUTE1			=> p_attribute_tbl.attribute(1),
		P_ATTRIBUTE2			=> p_attribute_tbl.attribute(2),
		P_ATTRIBUTE3			=> p_attribute_tbl.attribute(3),
		P_ATTRIBUTE4			=> p_attribute_tbl.attribute(4),
		P_ATTRIBUTE5			=> p_attribute_tbl.attribute(5),
		P_ATTRIBUTE6			=> p_attribute_tbl.attribute(6),
		P_ATTRIBUTE7			=> p_attribute_tbl.attribute(7),
		P_ATTRIBUTE8			=> p_attribute_tbl.attribute(8),
		P_ATTRIBUTE9			=> p_attribute_tbl.attribute(9),
		P_ATTRIBUTE10			=> p_attribute_tbl.attribute(10),
		P_ATTRIBUTE11			=> p_attribute_tbl.attribute(11),
		P_ATTRIBUTE12			=> p_attribute_tbl.attribute(12),
		P_ATTRIBUTE13			=> p_attribute_tbl.attribute(13),
		P_ATTRIBUTE14			=> p_attribute_tbl.attribute(14),
		P_ATTRIBUTE15			=> p_attribute_tbl.attribute(15),
		P_ATTRIBUTE16			=> p_attribute_tbl.attribute(16),
		P_ATTRIBUTE17			=> p_attribute_tbl.attribute(17),
		P_ATTRIBUTE18			=> p_attribute_tbl.attribute(18),
		P_ATTRIBUTE19			=> p_attribute_tbl.attribute(19),
		P_ATTRIBUTE20			=> p_attribute_tbl.attribute(20),
		P_INPUT_VALUE_ID1		=> l_ev_rec_tbl(1).input_value_id,
		P_INPUT_VALUE_ID2		=> l_ev_rec_tbl(2).input_value_id,
		P_INPUT_VALUE_ID3		=> l_ev_rec_tbl(3).input_value_id,
		P_INPUT_VALUE_ID4		=> l_ev_rec_tbl(4).input_value_id,
		P_INPUT_VALUE_ID5		=> l_ev_rec_tbl(5).input_value_id,
		P_INPUT_VALUE_ID6		=> l_ev_rec_tbl(6).input_value_id,
		P_INPUT_VALUE_ID7		=> l_ev_rec_tbl(7).input_value_id,
		P_INPUT_VALUE_ID8		=> l_ev_rec_tbl(8).input_value_id,
		P_INPUT_VALUE_ID9		=> l_ev_rec_tbl(9).input_value_id,
		P_INPUT_VALUE_ID10		=> l_ev_rec_tbl(10).input_value_id,
		P_INPUT_VALUE_ID11		=> l_ev_rec_tbl(11).input_value_id,
		P_INPUT_VALUE_ID12		=> l_ev_rec_tbl(12).input_value_id,
		P_INPUT_VALUE_ID13		=> l_ev_rec_tbl(13).input_value_id,
		P_INPUT_VALUE_ID14		=> l_ev_rec_tbl(14).input_value_id,
		P_INPUT_VALUE_ID15		=> l_ev_rec_tbl(15).input_value_id,
		P_ENTRY_VALUE1			=> l_ev_rec_tbl(1).entry_value,
		P_ENTRY_VALUE2			=> l_ev_rec_tbl(2).entry_value,
		P_ENTRY_VALUE3			=> l_ev_rec_tbl(3).entry_value,
		P_ENTRY_VALUE4			=> l_ev_rec_tbl(4).entry_value,
		P_ENTRY_VALUE5			=> l_ev_rec_tbl(5).entry_value,
		P_ENTRY_VALUE6			=> l_ev_rec_tbl(6).entry_value,
		P_ENTRY_VALUE7			=> l_ev_rec_tbl(7).entry_value,
		P_ENTRY_VALUE8			=> l_ev_rec_tbl(8).entry_value,
		P_ENTRY_VALUE9			=> l_ev_rec_tbl(9).entry_value,
		P_ENTRY_VALUE10			=> l_ev_rec_tbl(10).entry_value,
		P_ENTRY_VALUE11			=> l_ev_rec_tbl(11).entry_value,
		P_ENTRY_VALUE12			=> l_ev_rec_tbl(12).entry_value,
		P_ENTRY_VALUE13			=> l_ev_rec_tbl(13).entry_value,
		P_ENTRY_VALUE14			=> l_ev_rec_tbl(14).entry_value,
		P_ENTRY_VALUE15			=> l_ev_rec_tbl(15).entry_value,
		P_EFFECTIVE_START_DATE		=> p_effective_start_date,
		P_EFFECTIVE_END_DATE		=> p_effective_end_date,
		P_ELEMENT_ENTRY_ID		=> p_element_entry_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		P_CREATE_WARNING		=> l_warning);
End ins;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< upd >------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Procedure which issues update dml.
--
Procedure upd(
	p_validate		in     boolean,
	p_effective_date	in     date,
	p_datetrack_update_mode	in     varchar2,
	p_element_entry_id	in     number,
	p_object_version_number	in out nocopy number,
	p_ev_rec_tbl		in     ev_rec_tbl,
	p_attribute_tbl		in     attribute_tbl,
	p_business_group_id	in     number,
	p_effective_start_date out nocopy    date,
	p_effective_end_date out nocopy    date)
Is
	l_warning		BOOLEAN;
	l_ev_rec_tbl		ev_rec_tbl := p_ev_rec_tbl;
Begin
	init_varray(l_ev_rec_tbl);
	py_element_entry_api.update_element_entry(
		P_VALIDATE			=> p_validate,
		P_DATETRACK_UPDATE_MODE		=> p_datetrack_update_mode,
		P_EFFECTIVE_DATE		=> p_effective_date,
		P_BUSINESS_GROUP_ID		=> p_business_group_id,
		P_ELEMENT_ENTRY_ID		=> p_element_entry_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		P_ATTRIBUTE_CATEGORY		=> p_attribute_tbl.attribute_category,
		P_ATTRIBUTE1			=> p_attribute_tbl.attribute(1),
		P_ATTRIBUTE2			=> p_attribute_tbl.attribute(2),
		P_ATTRIBUTE3			=> p_attribute_tbl.attribute(3),
		P_ATTRIBUTE4			=> p_attribute_tbl.attribute(4),
		P_ATTRIBUTE5			=> p_attribute_tbl.attribute(5),
		P_ATTRIBUTE6			=> p_attribute_tbl.attribute(6),
		P_ATTRIBUTE7			=> p_attribute_tbl.attribute(7),
		P_ATTRIBUTE8			=> p_attribute_tbl.attribute(8),
		P_ATTRIBUTE9			=> p_attribute_tbl.attribute(9),
		P_ATTRIBUTE10			=> p_attribute_tbl.attribute(10),
		P_ATTRIBUTE11			=> p_attribute_tbl.attribute(11),
		P_ATTRIBUTE12			=> p_attribute_tbl.attribute(12),
		P_ATTRIBUTE13			=> p_attribute_tbl.attribute(13),
		P_ATTRIBUTE14			=> p_attribute_tbl.attribute(14),
		P_ATTRIBUTE15			=> p_attribute_tbl.attribute(15),
		P_ATTRIBUTE16			=> p_attribute_tbl.attribute(16),
		P_ATTRIBUTE17			=> p_attribute_tbl.attribute(17),
		P_ATTRIBUTE18			=> p_attribute_tbl.attribute(18),
		P_ATTRIBUTE19			=> p_attribute_tbl.attribute(19),
		P_ATTRIBUTE20			=> p_attribute_tbl.attribute(20),
		P_INPUT_VALUE_ID1		=> l_ev_rec_tbl(1).input_value_id,
		P_INPUT_VALUE_ID2		=> l_ev_rec_tbl(2).input_value_id,
		P_INPUT_VALUE_ID3		=> l_ev_rec_tbl(3).input_value_id,
		P_INPUT_VALUE_ID4		=> l_ev_rec_tbl(4).input_value_id,
		P_INPUT_VALUE_ID5		=> l_ev_rec_tbl(5).input_value_id,
		P_INPUT_VALUE_ID6		=> l_ev_rec_tbl(6).input_value_id,
		P_INPUT_VALUE_ID7		=> l_ev_rec_tbl(7).input_value_id,
		P_INPUT_VALUE_ID8		=> l_ev_rec_tbl(8).input_value_id,
		P_INPUT_VALUE_ID9		=> l_ev_rec_tbl(9).input_value_id,
		P_INPUT_VALUE_ID10		=> l_ev_rec_tbl(10).input_value_id,
		P_INPUT_VALUE_ID11		=> l_ev_rec_tbl(11).input_value_id,
		P_INPUT_VALUE_ID12		=> l_ev_rec_tbl(12).input_value_id,
		P_INPUT_VALUE_ID13		=> l_ev_rec_tbl(13).input_value_id,
		P_INPUT_VALUE_ID14		=> l_ev_rec_tbl(14).input_value_id,
		P_INPUT_VALUE_ID15		=> l_ev_rec_tbl(15).input_value_id,
		P_ENTRY_VALUE1			=> l_ev_rec_tbl(1).entry_value,
		P_ENTRY_VALUE2			=> l_ev_rec_tbl(2).entry_value,
		P_ENTRY_VALUE3			=> l_ev_rec_tbl(3).entry_value,
		P_ENTRY_VALUE4			=> l_ev_rec_tbl(4).entry_value,
		P_ENTRY_VALUE5			=> l_ev_rec_tbl(5).entry_value,
		P_ENTRY_VALUE6			=> l_ev_rec_tbl(6).entry_value,
		P_ENTRY_VALUE7			=> l_ev_rec_tbl(7).entry_value,
		P_ENTRY_VALUE8			=> l_ev_rec_tbl(8).entry_value,
		P_ENTRY_VALUE9			=> l_ev_rec_tbl(9).entry_value,
		P_ENTRY_VALUE10			=> l_ev_rec_tbl(10).entry_value,
		P_ENTRY_VALUE11			=> l_ev_rec_tbl(11).entry_value,
		P_ENTRY_VALUE12			=> l_ev_rec_tbl(12).entry_value,
		P_ENTRY_VALUE13			=> l_ev_rec_tbl(13).entry_value,
		P_ENTRY_VALUE14			=> l_ev_rec_tbl(14).entry_value,
		P_ENTRY_VALUE15			=> l_ev_rec_tbl(15).entry_value,
		P_EFFECTIVE_START_DATE		=> p_effective_start_date,
		P_EFFECTIVE_END_DATE		=> p_effective_end_date,
		P_UPDATE_WARNING		=> l_warning);
End upd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< del >------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Procedure which issues delete dml.
--
Procedure del(
	p_validate		in     boolean,
	p_effective_date	in     date,
	p_datetrack_delete_mode	in     varchar2,
	p_element_entry_id	in     number,
	p_object_version_number	in out nocopy number,
	p_effective_start_date out nocopy    date,
	p_effective_end_date out nocopy    date)
Is
	l_warning		BOOLEAN;
Begin
	py_element_entry_api.delete_element_entry(
		P_VALIDATE			=> p_validate,
		P_DATETRACK_DELETE_MODE		=> p_datetrack_delete_mode,
		P_EFFECTIVE_DATE		=> p_effective_date,
		P_ELEMENT_ENTRY_ID		=> p_element_entry_id,
		P_OBJECT_VERSION_NUMBER		=> p_object_version_number,
		P_EFFECTIVE_START_DATE		=> p_effective_start_date,
		P_EFFECTIVE_END_DATE		=> p_effective_end_date,
		P_DELETE_WARNING		=> l_warning);
End del;
--
End pay_jp_entries_pkg;

/
