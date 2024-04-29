--------------------------------------------------------
--  DDL for Package PAY_KR_MAGTAPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_MAGTAPE_PKG" AUTHID CURRENT_USER as
/* $Header: pykrmgtp.pkh 115.5 2003/05/30 07:38:17 nnaresh ship $ */
--
level_cnt number;
--
cursor csr_header(p_payroll_action_id number default to_number(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'))) is
	select
		'BUSINESS_GROUP_ID=C',		to_char(ppa2.business_group_id),
		'PAYROLL_ID=C',			to_char(ppa2.payroll_id),
		'DATE_EARNED=C',		fnd_date.date_to_canonical(ppa2.effective_date),
		'OVERRIDING_DD_DATE=P',		fnd_date.date_to_canonical(ppa2.overriding_dd_date),
		'START_DATE=P',			fnd_date.date_to_canonical(ppa2.start_date),
		'EFFECTIVE_DATE=P',		fnd_date.date_to_canonical(ppa2.effective_date),
		'ORG_PAYMENT_METHOD_NAME=P',	opmtl.org_payment_method_name,
		'GIRO_COMPANY_NAME=P',		opm.pmeth_information1,
		'GIRO_COMPANY_CODE=P',		opm.pmeth_information2,
		'SOURCE_BANK_CODE=P',		pea.segment1,
		'SOURCE_BANK_NAME=P',		hrl.meaning,
		'SOURCE_BANK_ACCOUNT_TYPE=P',	pea.segment2,
		'SOURCE_BANK_ACCOUNT_NAME=P',	pea.segment3,
		'SOURCE_BANK_ACCOUNT_NUMBER=P',	pea.segment4,
		'ORG_PAY_METHOD_ID=C',		to_char(opm.org_payment_method_id),
		'ORG_PAY_METHOD_ID=P',		to_char(opm.org_payment_method_id)
	from	hr_lookups			hrl,
		pay_external_accounts		pea,
		pay_org_payment_methods_f_tl	opmtl,
		pay_org_payment_methods_f	opm,
		pay_payroll_actions		ppa2,
		(
			select	ppp.org_payment_method_id
			from	pay_pre_payments		ppp,
				pay_assignment_actions		paa,
				pay_payroll_actions		ppa
			where	ppa.payroll_action_id = p_payroll_action_id
			and	paa.payroll_action_id = ppa.payroll_action_id
			and	ppp.pre_payment_id = paa.pre_payment_id
			group by ppp.org_payment_method_id
		)				v
	where	ppa2.payroll_action_id = p_payroll_action_id
	and	opm.org_payment_method_id = v.org_payment_method_id
	and	ppa2.effective_date
		between opm.effective_start_date and opm.effective_end_date
	and	pea.external_account_id = opm.external_account_id
	and	hrl.lookup_type = 'KR_BANK'
	and	hrl.lookup_code = pea.segment1
	and	opmtl.org_payment_method_id = opm.org_payment_method_id
	and	opmtl.language = userenv('LANG')
	order by
		hrl.meaning,
		opmtl.org_payment_method_name;
--
cursor csr_data(
	p_payroll_action_id	NUMBER DEFAULT to_number(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')),
	p_org_payment_method_id	NUMBER DEFAULT to_number(pay_magtape_generic.get_parameter_value('ORG_PAY_METHOD_ID')),
	p_effective_date	DATE   DEFAULT fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))) is
	select
		'LAST_NAME=P',			pp.last_name,
		'FIRST_NAME=P',			pp.first_name,
		'NATIONAL_IDENTIFIER=P',	nvl(pp.national_identifier, ' '),
		'EMPLOYEE_NUMBER=P',		pp.employee_number,
		'ASSIGNMENT_NUMBER=P',		pa.assignment_number,
		'BANK_CODE=P',			pea.segment1,
		'BANK_NAME=P',			hrl.meaning,
		'BANK_ACCOUNT_TYPE=P',		pea.segment2,
		'BANK_ACCOUNT_NUMBER=P',	pea.segment3,
		'BANK_ACCOUNT_NAME=P',		pea.segment4,
		'PAYMENT=P',			to_char(ppp.value),
		'ASSIGNMENT_ACTION_ID=C',	to_char(paa.assignment_action_id),
		'ASSIGNMENT_ACTION_ID=P',	to_char(paa.assignment_action_id),
		'ASSIGNMENT_ID=C',		to_char(pa.assignment_id),
		'PER_PAY_METHOD_ID=C',		to_char(ppm.personal_payment_method_id),
		'ORGANIZATION_ID=C',		to_char(pa.organization_id),
		'TAX_UNIT_ID=C',		to_char(pa.establishment_id)
	from	hr_lookups			hrl,
		per_people_f		        pp,
		per_assignments_f		pa,
		pay_external_accounts		pea,
		pay_personal_payment_methods_f	ppm,
		pay_payroll_actions		ppa2, -- PrePayment pact
		pay_assignment_actions		paa2, -- PrePayment assact
		pay_pre_payments		ppp,
		pay_assignment_actions		paa   -- Magtape assact
	where	paa.payroll_action_id = p_payroll_action_id
	and	ppp.pre_payment_id = paa.pre_payment_id
	and	ppp.org_payment_method_id + 0 = p_org_payment_method_id
	and	paa2.assignment_action_id = ppp.assignment_action_id
	and	ppa2.payroll_action_id = paa2.payroll_action_id
	and	ppm.personal_payment_method_id = ppp.personal_payment_method_id
	/* Must use effective_date of PrePayments for PPM */
	and	ppa2.effective_date
		between ppm.effective_start_date and ppm.effective_end_date
	and	pea.external_account_id = ppm.external_account_id
	and	pa.assignment_id = paa.assignment_id
	and	p_effective_date
		between pa.effective_start_date and pa.effective_end_date
	and	pp.person_id = pa.person_id
	and	p_effective_date
		between pp.effective_start_date and pp.effective_end_date
	/* Do not remove the following NVL function for performance purpose. */
	and	hrl.lookup_type = nvl('KR_BANK', pp.last_name)
	and	hrl.lookup_code = pea.segment1
	order by
		pp.last_name,
		pp.first_name,
		pp.person_id,
		ppa2.effective_date,
		ppa2.action_sequence,
		hrl.meaning;
--
end pay_kr_magtape_pkg;

 

/
