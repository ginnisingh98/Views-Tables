--------------------------------------------------------
--  DDL for Package Body PER_JP_PEM_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JP_PEM_RULES" as
/* $Header: pejppemr.pkb 120.0 2005/05/31 10:55 appldev noship $ */
--
-- Constants
--
c_package	constant varchar2(31) := 'per_jp_pem_rules.';
--
procedure chk_ddf(
	p_pem_information1	in varchar2,
	p_pem_information2	in varchar2)
is
	c_proc			constant varchar2(61) := c_package || 'chk_ddf';
	--
/*
	l_employment_income	number;
	l_si_prems		number;
	l_mutual_aid_prem	number;
	l_withholding_tax	number;
	l_total_deductions	number;
*/
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	if p_pem_information1 is not null then
		if not hr_jp_standard_pkg.is_hankaku(p_pem_information1) then
			fnd_message.set_name('PER', 'HR_JP_IS_NOT_HANKAKU');
			fnd_message.set_token('NAME', 'HR_JP_EMPLOYER_NAME_KANA', true);
			fnd_message.set_token('VALUE', p_pem_information1);
			hr_multi_message.add(p_associated_column1 => 'PER_PREVIOUS_EMPLOYERS.PEM_INFORMATION1');
		end if;
	end if;
	--
	if p_pem_information2 is not null then
		if not hr_jp_standard_pkg.is_hankaku(p_pem_information2) then
			fnd_message.set_name('PER', 'HR_JP_IS_NOT_HANKAKU');
			fnd_message.set_token('NAME', 'HR_JP_EMPLOYER_ADDRESS_KANA', true);
			fnd_message.set_token('VALUE', p_pem_information2);
			hr_multi_message.add(p_associated_column1 => 'PER_PREVIOUS_EMPLOYERS.PEM_INFORMATION2');
		end if;
	end if;
	--
/*
	l_employment_income	:= nvl(fnd_number.canonical_to_number(p_pem_information3), 0);
	l_si_prems		:= nvl(fnd_number.canonical_to_number(p_pem_information4), 0);
	l_mutual_aid_prem	:= nvl(fnd_number.canonical_to_number(p_pem_information5), 0);
	l_withholding_tax	:= nvl(fnd_number.canonical_to_number(p_pem_information6), 0);
	l_total_deductions	:= l_si_prems + l_withholding_tax;
	--
	if l_employment_income < l_total_deductions then
		fnd_message.set_name('PER', 'HR_JP_A_LESS_THAN_B');
		fnd_message.set_token('HIGH_NAME', 'HR_JP_EMPLOYMENT_INCOME', true);
		fnd_message.set_token('HIGH_VALUE', to_char(l_employment_income, fnd_currency.get_format_mask('JPY', 38)));
		fnd_message.set_token('LOW_NAME', 'HR_JP_TOTAL_DEDUCTIONS', true);
		fnd_message.set_token('LOW_VALUE', to_char(l_total_deductions, fnd_currency.get_format_mask('JPY', 38)));
		hr_multi_message.add(p_associated_column1 => 'PER_PREVIOUS_EMPLOYERS.PEM_INFORMATION3');
	end if;
	--
	if l_si_prems < l_mutual_aid_prem then
		fnd_message.set_name('PER', 'HR_JP_A_LESS_THAN_B');
		fnd_message.set_token('HIGH_NAME', 'HR_JP_SI_PREMS', true);
		fnd_message.set_token('HIGH_VALUE', to_char(l_si_prems, fnd_currency.get_format_mask('JPY', 38)));
		fnd_message.set_token('LOW_NAME', 'HR_JP_MUTUAL_AID_PREM', true);
		fnd_message.set_token('LOW_VALUE', to_char(l_mutual_aid_prem, fnd_currency.get_format_mask('JPY', 38)));
		hr_multi_message.add(
			p_associated_column1	=> 'PER_PREVIOUS_EMPLOYERS.PEM_INFORMATION4',
			p_associated_column2	=> 'PER_PREVIOUS_EMPLOYERS.PEM_INFORMATION5');
	end if;
*/
	--
	hr_multi_message.end_validation_set;
	--
	hr_utility.set_location('Leaving: ' || c_proc, 20);
end chk_ddf;
--
end per_jp_pem_rules;

/
