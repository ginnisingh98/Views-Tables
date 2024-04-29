--------------------------------------------------------
--  DDL for Package Body PAY_KR_PAYKRYTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_PAYKRYTS_PKG" as
/* $Header: paykryts.pkb 115.5 2003/08/26 02:32:58 viagarwa ship $ */
--
-- Global Variables
--
g_taxable_id		number;
g_non_taxable_id	number;
g_med_exp_tax_exem_id	number;
g_donation_tax_exem_id	number;
g_annual_itax_id	number;
g_prev_itax_id		number;
g_cur_itax_id		number;
g_itax_adj_id		number;
------------------------------------------------------------------------
procedure data(
	p_tax_unit_id			in number,
	p_target_year			in number,
	p_count				out nocopy number,
	p_earnings			out nocopy number,
	p_non_taxable_count		out nocopy number,
	p_non_taxable			out nocopy number,
	p_med_exp_tax_exem_count	out nocopy number,
	p_med_exp_tax_exem		out nocopy number,
	p_donation_tax_exem_count	out nocopy number,
	p_donation_tax_exem		out nocopy number,
	p_annual_itax			out nocopy number,
	p_prev_itax			out nocopy number,
	p_cur_itax			out nocopy number,
	p_itax_adj_pay			out nocopy number,
	p_itax_adj_refund		out nocopy number,
	p_itax_adj			out nocopy number)
------------------------------------------------------------------------
is
	cursor csr is
		select
			count(paa.assignment_action_id)								COUNT,
			nvl(sum(to_number(i1.value) + to_number(i2.value)), 0)					EARNINGS,
			count(decode(to_number(i2.value), 0, null, 1))						NON_TAXABLE_COUNT,
			nvl(sum(to_number(i2.value)), 0)							NON_TAXABLE,
			count(decode(to_number(i3.value), 0, null, 1))						MED_EXP_TAX_EXEM_COUNT,
			nvl(sum(to_number(i3.value)), 0)							MED_EXP_TAX_EXEM,
			count(decode(to_number(i4.value), 0, null, 1))						DONATION_TAX_EXEM_COUNT,
			nvl(sum(to_number(i4.value)), 0)							DONATION_TAX_EXEM,
			nvl(sum(to_number(i5.value)), 0)							ANNUAL_ITAX,
			nvl(sum(to_number(i6.value)), 0)							PREV_ITAX,
			nvl(sum(to_number(i7.value)), 0)							CUR_ITAX,
			nvl(sum(decode(sign(to_number(i8.value)), 1, to_number(i8.value),null)), 0)		ITAX_ADJ_PAY,
			abs(nvl(sum(decode(sign(to_number(i8.value)), -1, to_number(i8.value),null)), 0))	ITAX_ADJ_REFUND
		from	ff_archive_items		i8,	/* X_YEA_ITAX_ADJ          */
			ff_archive_items		i7,	/* X_YEA_CUR_ITAX          */
			ff_archive_items		i6,	/* X_YEA_PREV_ITAX         */
			ff_archive_items		i5,	/* X_YEA_ANNUAL_ITAX       */
			ff_archive_items		i4,	/* X_YEA_DONATION_TAX_EXEM */
			ff_archive_items		i3,	/* X_YEA_MED_EXP_TAX_EXEM  */
			ff_archive_items		i2,	/* X_YEA_NON_TAXABLE       */
			ff_archive_items		i1,	/* X_YEA_TAXABLE           */
			pay_assignment_actions		paa,
			pay_payroll_actions		ppa,
			hr_organization_units	        hou
		where	hou.organization_id = p_tax_unit_id
		and	ppa.report_type = 'YEA'
		and	ppa.report_qualifier = 'KR'
		and	ppa.report_category in ('N', 'I')
		and	ppa.business_group_id + 0 = hou.business_group_id
		and	to_number(to_char(ppa.effective_date, 'YYYY')) = p_target_year
		and	ppa.action_type in ('B','X')
		and	paa.payroll_action_id = ppa.payroll_action_id
		and	paa.tax_unit_id = hou.organization_id
		and	paa.action_status = 'C'
		and	i1.context1 = paa.assignment_action_id
		and	i1.user_entity_id = nvl(g_taxable_id, paa.assignment_action_id)
		and	i2.context1 = paa.assignment_action_id
		and	i2.user_entity_id = nvl(g_non_taxable_id, paa.assignment_action_id)
		and	i3.context1 = paa.assignment_action_id
		and	i3.user_entity_id = nvl(g_med_exp_tax_exem_id, paa.assignment_action_id)
		and	i4.context1 = paa.assignment_action_id
		and	i4.user_entity_id = nvl(g_donation_tax_exem_id, paa.assignment_action_id)
		and	i5.context1 = paa.assignment_action_id
		and	i5.user_entity_id = nvl(g_annual_itax_id, paa.assignment_action_id)
		and	i6.context1(+) = paa.assignment_action_id
		and	i6.user_entity_id(+) = nvl(g_prev_itax_id, paa.assignment_action_id)
		and	i7.context1 = paa.assignment_action_id
		and	i7.user_entity_id = nvl(g_cur_itax_id, paa.assignment_action_id)
		and	i8.context1 = paa.assignment_action_id
		and	i8.user_entity_id = nvl(g_itax_adj_id, paa.assignment_action_id);
begin
	open csr;
	fetch csr into
		p_count,
		p_earnings,
		p_non_taxable_count,
		p_non_taxable,
		p_med_exp_tax_exem_count,
		p_med_exp_tax_exem,
		p_donation_tax_exem_count,
		p_donation_tax_exem,
		p_annual_itax,
		p_prev_itax,
		p_cur_itax,
		p_itax_adj_pay,
		p_itax_adj_refund;
	close csr;
	--
	p_itax_adj := p_itax_adj_pay - p_itax_adj_refund;
end data;
------------------------------------------------------------------------
function user_entity_id(p_user_entity_name in varchar2) return number
------------------------------------------------------------------------
is
	l_user_entity_id	number;
begin
	select	user_entity_id
	into	l_user_entity_id
	from	ff_user_entities
	where	user_entity_name = p_user_entity_name
	and	legislation_code = 'KR'
	and	creator_type = 'X';
	--
	return l_user_entity_id;
end user_entity_id;
------------------------------------------------------------------------
------------------------------------------------------------------------
begin
	--
	-- Derive user_entity_id for YEA archive items.
	--
	g_taxable_id		:= user_entity_id('X_YEA_TAXABLE');
	g_non_taxable_id	:= user_entity_id('X_YEA_NON_TAXABLE');
	g_med_exp_tax_exem_id	:= user_entity_id('X_YEA_MED_EXP_TAX_EXEM');
	g_donation_tax_exem_id	:= user_entity_id('X_YEA_DONATION_TAX_EXEM');
	g_annual_itax_id	:= user_entity_id('X_YEA_ANNUAL_ITAX');
	g_prev_itax_id		:= user_entity_id('X_YEA_PREV_ITAX');
	g_cur_itax_id		:= user_entity_id('X_YEA_CUR_ITAX');
	g_itax_adj_id		:= user_entity_id('X_YEA_ITAX_ADJ');
end pay_kr_paykryts_pkg;

/
