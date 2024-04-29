--------------------------------------------------------
--  DDL for Package Body PAY_KR_YEA_MAGTAPE_FUN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_YEA_MAGTAPE_FUN_PKG" as
/* $Header: pykryean.pkb 120.5.12010000.3 2010/01/27 14:23:09 vaisriva ship $ */
--
-- Constants
--
c_package constant varchar2(31) := '  pay_kr_yea_magtape_fun_pkg.';
--
------------------------------------------------------------------------
procedure invalid_argument(
        p_procedure     in varchar2,
        p_argument      in varchar2,
        p_value         in varchar2)
------------------------------------------------------------------------
is
begin
        fnd_message.set_name('FND', 'FORM_INVALID_ARGUMENT');
        fnd_message.set_token('PROCEDURE', p_procedure);
        fnd_message.set_token('ARGUMENT', p_argument);
        fnd_message.set_token('VALUE', p_value);
        fnd_message.raise_error;
end invalid_argument;
------------------------------------------------------------------------
procedure populate_b(p_bp_number in varchar2,p_tax_office_code in varchar2)
------------------------------------------------------------------------
is
        l_proc  varchar2(61) := c_package || 'populate_b';
        --
        cursor csr_b1 is
                select  count(*)
                from    pay_assignment_actions          paa,
                        pay_payroll_actions             ppa,
                        hr_organization_units           bp,
			hr_organization_information     hoi1,
			hr_organization_information     hoi2
                where   hoi1.org_information2         = p_bp_number          --Bug# 2822459
                and     hoi2.org_information9         = p_tax_office_code
                and     hoi1.organization_id          = hoi2.organization_id
                and     hoi1.organization_id          = bp.organization_id
                and     hoi2.org_information_context  = 'KR_INCOME_TAX_OFFICE'
                and     hoi1.org_information_context  = 'KR_BUSINESS_PLACE_REGISTRATION'
                and     ppa.report_type               = 'YEA'
                and     ppa.report_qualifier          = 'KR'
                -- Bug 3248513
                and     ( (ppa.report_category in (pay_kr_yea_magtape_pkg.g_normal_yea, pay_kr_yea_magtape_pkg.g_interim_yea, pay_kr_yea_magtape_pkg.g_re_yea)) or (ppa.payroll_action_id = pay_kr_yea_magtape_pkg.g_payroll_action_id) )
                and     to_number(to_char(ppa.effective_date, 'YYYY')) = pay_kr_yea_magtape_pkg.g_target_year
                --
                and     ppa.action_type in ('B','X')
                and     paa.payroll_action_id = ppa.payroll_action_id
		and     ppa.payroll_action_id         = ppa.payroll_action_id
		-- Bug 3248513
		and	((pay_kr_yea_magtape_pkg.g_assignment_set_id is null) or (hr_assignment_set.assignment_in_set(pay_kr_yea_magtape_pkg.g_assignment_set_id, paa.assignment_id) = 'Y'))
		and     ((pay_kr_yea_magtape_pkg.g_re_yea <> 'R') or (pay_kr_yea_magtape_fun_pkg.latest_yea_action(paa.assignment_action_id,  pay_kr_yea_magtape_pkg.g_payroll_action_id, pay_kr_yea_magtape_pkg.g_target_year) = 'Y'))
		--
                and     paa.tax_unit_id = bp.organization_id
                and     paa.action_status = 'C';

        cursor csr_b3 (p_user_entity_id in ff_user_entities.user_entity_id%type) is
                select  nvl(sum(greatest(to_number(i1.value), 0)), 0)
                from    ff_archive_items                i1,
                        pay_assignment_actions          paa,
                        pay_payroll_actions             ppa,
                        hr_organization_units           bp,
			hr_organization_information     hoi1,
			hr_organization_information     hoi2
                where   hoi1.org_information2         = p_bp_number          --Bug# 2822459
                and     hoi2.org_information9         = p_tax_office_code
                and     hoi1.organization_id          = hoi2.organization_id
                and     hoi1.organization_id          = bp.organization_id
                and     hoi2.org_information_context  = 'KR_INCOME_TAX_OFFICE'
                and     hoi1.org_information_context  = 'KR_BUSINESS_PLACE_REGISTRATION'
                and     ppa.report_type               = 'YEA'
                and     ppa.report_qualifier          = 'KR'
                -- Bug 3248513
                and     ( (ppa.report_category in (pay_kr_yea_magtape_pkg.g_normal_yea, pay_kr_yea_magtape_pkg.g_interim_yea, pay_kr_yea_magtape_pkg.g_re_yea)) or (ppa.payroll_action_id = pay_kr_yea_magtape_pkg.g_payroll_action_id) )
                and     to_number(to_char(ppa.effective_date, 'YYYY')) = pay_kr_yea_magtape_pkg.g_target_year
                --
                and     ppa.action_type in ('B','X')
                and     paa.payroll_action_id = ppa.payroll_action_id
		and     ppa.payroll_action_id         = ppa.payroll_action_id
		-- Bug 3248513
		and	((pay_kr_yea_magtape_pkg.g_assignment_set_id is null) or (hr_assignment_set.assignment_in_set(pay_kr_yea_magtape_pkg.g_assignment_set_id, paa.assignment_id) = 'Y'))
		and     ((pay_kr_yea_magtape_pkg.g_re_yea <> 'R') or (pay_kr_yea_magtape_fun_pkg.latest_yea_action(paa.assignment_action_id, pay_kr_yea_magtape_pkg.g_payroll_action_id, pay_kr_yea_magtape_pkg.g_target_year) = 'Y'))
		--
                and     paa.tax_unit_id = bp.organization_id
                and     paa.action_status = 'C'
                and     i1.context1(+) = paa.assignment_action_id
                and     i1.user_entity_id(+) = p_user_entity_id;

       cursor csr_b2 is
                select
                        count(*)
                from    per_assignment_extra_info       aei,
                        pay_assignment_actions          paa,
                        pay_payroll_actions             ppa,
                        hr_organization_units           bp,
			hr_organization_information     hoi1,
			hr_organization_information     hoi2
                where   hoi1.org_information2         = p_bp_number          --Bug# 2822459
                and     hoi2.org_information9         = p_tax_office_code
                and     hoi1.organization_id          = hoi2.organization_id
                and     hoi1.organization_id          = bp.organization_id
                and     hoi2.org_information_context  = 'KR_INCOME_TAX_OFFICE'
                and     hoi1.org_information_context  like 'KR_BUSINESS_PLACE_REGISTRATION'
                and     ppa.report_type = 'YEA'
                and     ppa.report_qualifier = 'KR'
                -- Bug 3248513
                and     ( (ppa.report_category in (pay_kr_yea_magtape_pkg.g_normal_yea, pay_kr_yea_magtape_pkg.g_interim_yea, pay_kr_yea_magtape_pkg.g_re_yea)) or (ppa.payroll_action_id = pay_kr_yea_magtape_pkg.g_payroll_action_id) )
                and     to_number(to_char(ppa.effective_date, 'YYYY')) = pay_kr_yea_magtape_pkg.g_target_year
                --
                and     ppa.action_type in ('B','X')
                and     paa.payroll_action_id = ppa.payroll_action_id
		and     ppa.payroll_action_id         = ppa.payroll_action_id
		-- Bug 3248513
		and	((pay_kr_yea_magtape_pkg.g_assignment_set_id is null) or (hr_assignment_set.assignment_in_set(pay_kr_yea_magtape_pkg.g_assignment_set_id, paa.assignment_id) = 'Y'))
		and     ((pay_kr_yea_magtape_pkg.g_re_yea <> 'R') or (pay_kr_yea_magtape_fun_pkg.latest_yea_action(paa.assignment_action_id, pay_kr_yea_magtape_pkg.g_payroll_action_id, pay_kr_yea_magtape_pkg.g_target_year) = 'Y'))
		--
                and     paa.tax_unit_id = bp.organization_id
                and     paa.action_status = 'C'
                and     aei.assignment_id = paa.assignment_id
                and     aei.information_type = 'KR_YEA_PREV_ER_INFO'
                and     to_number(to_char(fnd_date.canonical_to_date(aei.aei_information1), 'YYYY')) = pay_kr_yea_magtape_pkg.g_target_year;
begin
--            if g_b_record.tax_unit_id is null or g_b_record.tax_unit_id <> p_tax_unit_id then
--               g_b_record.tax_unit_id := p_tax_unit_id;
                --
                open csr_b1;
                fetch csr_b1 into g_b_record.c_records;
                close csr_b1;

                open csr_b3(pay_kr_yea_magtape_pkg.g_taxable_id);
                fetch csr_b3 into g_b_record.taxable;
                close csr_b3;

                open csr_b3(pay_kr_yea_magtape_pkg.g_annual_itax_id);
                fetch csr_b3 into g_b_record.annual_itax;
                close csr_b3;

                open csr_b3(pay_kr_yea_magtape_pkg.g_annual_rtax_id);
                fetch csr_b3 into g_b_record.annual_rtax;
                close csr_b3;

                open csr_b3(pay_kr_yea_magtape_pkg.g_annual_stax_id);
                fetch csr_b3 into g_b_record.annual_stax;
                close csr_b3;

                --
                open csr_b2;
                fetch csr_b2 into g_b_record.d_records;
                close csr_b2;
--        end if;
end populate_b;
------------------------------------------------------------------------
function b_data(
        p_bp_number        in varchar2,
        p_tax_office_code  in varchar2,
        p_item_name        in varchar2) return varchar2
------------------------------------------------------------------------
is
        l_proc  varchar2(61) := c_package || 'b_data';
begin
        populate_b(p_bp_number,p_tax_office_code);
        --
        if p_item_name = 'C_RECORDS' then
                return to_char(g_b_record.c_records);
        elsif p_item_name = 'TAXABLE' then
                return to_char(g_b_record.taxable);
        elsif p_item_name = 'ANNUAL_ITAX' then
                return to_char(g_b_record.annual_itax);
        elsif p_item_name = 'ANNUAL_RTAX' then
                return to_char(g_b_record.annual_rtax);
        elsif p_item_name = 'ANNUAL_STAX' then
                return to_char(g_b_record.annual_stax);
        elsif p_item_name = 'D_RECORDS' then
                return to_char(g_b_record.d_records);
        else
                invalid_argument(l_proc, 'P_ITEM_NAME', p_item_name);
        end if;
end b_data;
------------------------------------------------------------------------
procedure populate_c(p_assignment_id in number)
------------------------------------------------------------------------
is
        l_proc  varchar2(61) := c_package || 'populate_c';
        --
        cursor csr_c is
                select
                        count(*)
                from    per_assignment_extra_info       aei
                where   aei.assignment_id = p_assignment_id
                and     aei.information_type = 'KR_YEA_PREV_ER_INFO'
                and     to_number(to_char(fnd_date.canonical_to_date(aei.aei_information1), 'YYYY')) = pay_kr_yea_magtape_pkg.g_target_year;
begin
        if g_c_record.assignment_id is null or g_c_record.assignment_id <> p_assignment_id then
                g_c_record.assignment_id := p_assignment_id;
                --
                open csr_c;
                fetch csr_c into g_c_record.d_records_per_c;
                close csr_c;
        end if;
end populate_c;
------------------------------------------------------------------------
function c_data(
        p_assignment_id in number,
        p_item_name     in varchar2) return varchar2
------------------------------------------------------------------------
is
        l_proc  varchar2(61) := c_package || 'c_data';
begin
        populate_c(p_assignment_id);
        --
        if p_item_name = 'D_RECORDS_PER_C' then
                return to_char(g_c_record.d_records_per_c);
        else
                invalid_argument(l_proc, 'P_ITEM_NAME', p_item_name);
        end if;
end c_data;

------------------------------------------------------------------------
-- Bug 3248513 Function latest_yea_action created to get the latest
--             Re-YEA action if e-file is printed for re-yea
------------------------------------------------------------------------
function latest_yea_action(
------------------------------------------------------------------------
	p_asg_action_id  in  pay_assignment_actions.assignment_action_id%type,
        p_pact           in  number,
        p_target_year    in  number
)  return varchar2
------------------------------------------------------------------------
is

  l_is_latest   varchar2(1);

  Cursor is_latest is
	Select 'Y'
          from pay_assignment_actions paa,
               pay_payroll_actions    ppa
         where paa.assignment_action_id = p_asg_action_id
           and ppa.payroll_action_id    = paa.payroll_action_id
           and not exists
                      ( Select assignment_action_id
                          from pay_assignment_actions paa1,
                               pay_payroll_actions    ppa1
                         where paa1.assignment_id      = paa.assignment_id
                           and ppa1.payroll_action_id  = paa1.payroll_action_id
                           and ppa1.action_type        in ('B', 'X')
                           and paa1.action_status      = 'C'
                           and ppa1.report_type        = 'YEA'
                           and ppa1.report_qualifier   = 'KR'
                           and ppa1.report_category    = 'R'
                           and to_number(to_char(ppa1.effective_date, 'YYYY')) = p_target_year -- Bug 4726974
                           and paa1.action_sequence > paa.action_sequence);
begin
	if p_pact is not null then -- Bug 4726974
		return 'Y';
	else
		open is_latest;
		fetch is_latest into l_is_latest;
		close is_latest;

		return nvl(l_is_latest, 'N');
	end if;
end;
---------------------------------------------------------------------------
-- Bug : 4738717
-- This function returns the count of the dependents
-- who are elilgible for exemptions
function e_record_count( p_ass_id      in varchar2,
                         p_eff_date    in date ) return number
is
    cursor csr_e_count( p_assignment_id varchar2, p_effective_date date ) is
 -- Bug 5654127
 -- Bug 5872042
 -- Bug 7661820
 select count(*)
  from pay_kr_cont_details_v        pkc,
       per_contact_extra_info_f     cei     -- Bug 5879106
  where pkc.assignment_id              = p_assignment_id
   and p_effective_date between pkc.emp_start_date and pkc.emp_end_date
   and pay_kr_ff_functions_pkg.is_exempted_dependent(pkc.contact_type, pkc.cont_information11, pkc.national_identifier, pkc.cont_information2,
           pkc.cont_information3,
           pkc.cont_information4,
           pkc.cont_information7,
           pkc.cont_information8,
           p_effective_date,
           pkc.cont_information10,
           pkc.cont_information12,
           pkc.cont_information13,
           pkc.cont_information14,
	   cei.contact_extra_info_id) = 'Y'
   and to_char(cei.effective_start_date(+), 'yyyy') = to_char(p_effective_date,'yyyy')
   and cei.information_type(+) = 'KR_DPNT_EXPENSE_INFO'
   and cei.contact_relationship_id(+) = pkc.contact_relationship_id
   and p_effective_date between nvl(pkc.date_start, p_effective_date)
            and decode(pkc.cont_information9, 'D',trunc(add_months(nvl(pkc.date_end, p_effective_date),12),'YYYY')-1,
                nvl(pkc.date_end, p_effective_date) )
   and p_effective_date	between nvl(ADDRESS_START_DATE, p_effective_date) and nvl(ADDRESS_END_DATE, p_effective_date)
   and p_effective_date between pkc.CONT_START_DATE and pkc.CONT_END_DATE;
  -- End of Bug 5872042
  -- End of Bug 5654127
    l_count number;

begin

    open csr_e_count(p_ass_id,p_eff_date);
    fetch csr_e_count into l_count;
    close csr_e_count;

    return l_count+1;       -- Bug 5654127: Added 1 for the employee details record

end e_record_count;
---------------------------------------------------------------------------
-- Bug 9213683: Created a new function to fetch the non-taxable earnings
--              values for the Previous employer.
---------------------------------------------------------------------------
function prev_non_tax_values(
                             p_assignment_id 	in varchar2,
                             p_bp_number	in varchar2,
                             p_code		in varchar2,
                             p_effective_date   in date) return number
is
--
l_dummy number := 0;

cursor csr_aei is
SELECT nvl(aei_information5,   0) VALUE
FROM per_assignment_extra_info
WHERE assignment_id = p_assignment_id
 AND aei_information4 = p_bp_number
 AND aei_information2 = p_code
 AND information_type = 'KR_YEA_NON_TAXABLE_EARN_DETAIL'
 AND TRUNC(fnd_date.canonical_to_date(aei_information1),   'YYYY') = TRUNC(p_effective_date,   'YYYY');
--
begin
--
open csr_aei;
fetch csr_aei into l_dummy;
if csr_aei%NOTFOUND then
   l_dummy := 0;
end if;
close csr_aei;

return l_dummy;
--
end;
---------------------------------------------------------------------------
end pay_kr_yea_magtape_fun_pkg;

/
