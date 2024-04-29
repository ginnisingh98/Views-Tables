--------------------------------------------------------
--  DDL for Package Body PAY_JP_YEA_BAL_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_YEA_BAL_ADJ_PKG" AS
/* $Header: pyjpyeba.pkb 120.0 2006/02/26 17:03 hikubo noship $ */
--
type number_t is table of number       index by binary_integer;
type text_t   is table of varchar2(60) index by binary_integer;
type date_t   is table of date         index by binary_integer;
--
g_number_value number_t;
g_text_value   text_t;
g_date_value   date_t;
--
FUNCTION get_formula_name
(
	p_business_group_id in varchar2,
	p_payroll_id        in varchar2,
	p_effective_date    in varchar2
) RETURN varchar2 IS
	--
	l_pay_formula_id    ff_formulas_f.formula_id%type;
	l_org_formula_id    ff_formulas_f.formula_id%type;
	--
	l_formula_name      ff_formulas_f_tl.formula_name%type;
	--
	cursor c_org_formula is
		select fnd_number.canonical_to_number(org_information5)
		from hr_organization_information
		where organization_id = fnd_number.canonical_to_number(p_business_group_id)
		and org_information_context = 'JP_BUSINESS_GROUP_INFO';
	--
	cursor c_pay_formula is
		select fnd_number.canonical_to_number(prl_information4)
		from pay_all_payrolls_f
		where payroll_id = fnd_number.canonical_to_number(p_payroll_id)
		and fnd_date.canonical_to_date(p_effective_date)
			between effective_start_date and effective_end_date;
	--
	cursor c_formula is
		select fft.formula_name
		from ff_formulas_f ff, ff_formulas_f_tl fft
		where ff.formula_id = nvl(l_pay_formula_id, l_org_formula_id)
		and fnd_date.canonical_to_date(p_effective_date)
			between ff.effective_start_date and ff.effective_end_date
		and fft.formula_id = ff.formula_id
		and fft.language = userenv('LANG');
	--
BEGIN
	--
	l_pay_formula_id := null;
	l_org_formula_id := null;
	l_formula_name   := null;
	--
	open c_org_formula;
	fetch c_org_formula into l_org_formula_id;
	close c_org_formula;
	--
	open c_pay_formula;
	fetch c_pay_formula into l_pay_formula_id;
	close c_pay_formula;
	--
	if l_org_formula_id is not null or l_pay_formula_id is not null then
		--
		open c_formula;
		fetch c_formula into l_formula_name;
		close c_formula;
		--
	end if;
	--
	return l_formula_name;
	--
END;

FUNCTION call_formula
(
	p_business_group_id    in number,
	p_payroll_id           in number,
	p_payroll_action_id    in number,
	p_assignment_id        in number,
	p_assignment_action_id in number,
	p_date_earned          in date,
	p_element_entry_id     in number,
	p_element_type_id      in number
) RETURN number IS
	--
	l_formula_id number;
	--
	l_inputs     ff_exec.inputs_t;
	l_outputs    ff_exec.outputs_t;
	--
BEGIN
	--
	select to_number(pay_core_utils.get_parameter('FORMULA_ID', legislative_parameters))
	into l_formula_id
	from pay_payroll_actions
	where payroll_action_id = p_payroll_action_id;
	--
	if l_formula_id is not null then
		--
		ff_exec.init_formula
		(
			p_formula_id     => l_formula_id,
			p_effective_date => p_date_earned,
			p_inputs         => l_inputs,
			p_outputs        => l_outputs
		);
		--
		for i in 1 .. l_inputs.count loop
			--
			if l_inputs(i).class = 'CONTEXT' then
				--
				if l_inputs(i).datatype = 'NUMBER' then
					--
					if    l_inputs(i).name = 'BUSINESS_GROUP_ID' then
						l_inputs(i).value := fnd_number.canonical_to_number(p_business_group_id);
					elsif l_inputs(i).name = 'PAYROLL_ID' then
						l_inputs(i).value := fnd_number.canonical_to_number(p_payroll_id);
					elsif l_inputs(i).name = 'PAYROLL_ACTION_ID' then
						l_inputs(i).value := fnd_number.canonical_to_number(p_payroll_action_id);
					elsif l_inputs(i).name = 'ASSIGNMENT_ID' then
						l_inputs(i).value := fnd_number.canonical_to_number(p_assignment_id);
					elsif l_inputs(i).name = 'ASSIGNMENT_ACTION_ID' then
						l_inputs(i).value := fnd_number.canonical_to_number(p_assignment_action_id);
					elsif l_inputs(i).name = 'ELEMENT_ENTRY_ID' then
						l_inputs(i).value := fnd_number.canonical_to_number(p_element_entry_id);
					elsif l_inputs(i).name = 'ELEMENT_TYPE_ID' then
						l_inputs(i).value := fnd_number.canonical_to_number(p_element_type_id);
					end if;
					--
				elsif l_inputs(i).datatype = 'DATE' and l_inputs(i).name = 'DATE_EARNED' then
					--
					l_inputs(i).value := fnd_date.date_to_canonical(p_date_earned);
					--
				end if;
				--
			end if;
			--
		end loop;
		--
		ff_exec.run_formula
		(
			p_inputs  => l_inputs,
			p_outputs => l_outputs
		);
		--
		for i in 1 .. l_outputs.count loop
			--
			if l_outputs(i).datatype = 'NUMBER' then
				--
				if    l_outputs(i).name = 'L_NUM1'  then
					g_number_value(1)  := fnd_number.canonical_to_number(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_NUM2'  then
					g_number_value(2)  := fnd_number.canonical_to_number(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_NUM3'  then
					g_number_value(3)  := fnd_number.canonical_to_number(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_NUM4'  then
					g_number_value(4)  := fnd_number.canonical_to_number(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_NUM5'  then
					g_number_value(5)  := fnd_number.canonical_to_number(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_NUM6'  then
					g_number_value(6)  := fnd_number.canonical_to_number(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_NUM7'  then
					g_number_value(7)  := fnd_number.canonical_to_number(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_NUM8'  then
					g_number_value(8)  := fnd_number.canonical_to_number(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_NUM9'  then
					g_number_value(9)  := fnd_number.canonical_to_number(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_NUM10' then
					g_number_value(10) := fnd_number.canonical_to_number(l_outputs(i).value);
				end if;
				--
			elsif l_outputs(i).datatype = 'TEXT' then
				--
				if    l_outputs(i).name = 'L_TEXT1'  then
					g_text_value(1)  := l_outputs(i).value;
				elsif l_outputs(i).name = 'L_TEXT2'  then
					g_text_value(2)  := l_outputs(i).value;
				elsif l_outputs(i).name = 'L_TEXT3'  then
					g_text_value(3)  := l_outputs(i).value;
				elsif l_outputs(i).name = 'L_TEXT4'  then
					g_text_value(4)  := l_outputs(i).value;
				elsif l_outputs(i).name = 'L_TEXT5'  then
					g_text_value(5)  := l_outputs(i).value;
				elsif l_outputs(i).name = 'L_TEXT6'  then
					g_text_value(6)  := l_outputs(i).value;
				elsif l_outputs(i).name = 'L_TEXT7'  then
					g_text_value(7)  := l_outputs(i).value;
				elsif l_outputs(i).name = 'L_TEXT8'  then
					g_text_value(8)  := l_outputs(i).value;
				elsif l_outputs(i).name = 'L_TEXT9'  then
					g_text_value(9)  := l_outputs(i).value;
				elsif l_outputs(i).name = 'L_TEXT10' then
					g_text_value(10) := l_outputs(i).value;
				end if;
				--
			elsif l_outputs(i).datatype = 'DATE' then
				--
				if    l_outputs(i).name = 'L_DATE1'  then
					g_date_value(1)  := fnd_date.canonical_to_date(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_DATE2'  then
					g_date_value(2)  := fnd_date.canonical_to_date(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_DATE3'  then
					g_date_value(3)  := fnd_date.canonical_to_date(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_DATE4'  then
					g_date_value(4)  := fnd_date.canonical_to_date(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_DATE5'  then
					g_date_value(5)  := fnd_date.canonical_to_date(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_DATE6'  then
					g_date_value(6)  := fnd_date.canonical_to_date(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_DATE7'  then
					g_date_value(7)  := fnd_date.canonical_to_date(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_DATE8'  then
					g_date_value(8)  := fnd_date.canonical_to_date(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_DATE9'  then
					g_date_value(9)  := fnd_date.canonical_to_date(l_outputs(i).value);
				elsif l_outputs(i).name = 'L_DATE10' then
					g_date_value(10) := fnd_date.canonical_to_date(l_outputs(i).value);
				end if;
				--
			end if;
			--
		end loop;
		--
	end if;
	--
	return 0;
	--
END;

FUNCTION get_number_value(p_number in number) RETURN number IS
BEGIN
	return g_number_value(p_number);
END;
--
FUNCTION get_text_value(p_number in number) RETURN varchar2 IS
BEGIN
	return g_text_value(p_number);
END;
--
FUNCTION get_date_value(p_number in number) RETURN date IS
BEGIN
	return g_date_value(p_number);
END;

BEGIN
	--
	for i in 1 .. 10 loop
		--
		g_number_value(i) := null;
		g_text_value(i)   := null;
		g_date_value(i)   := null;
		--
	end loop;
	--
END PAY_JP_YEA_BAL_ADJ_PKG;

/
