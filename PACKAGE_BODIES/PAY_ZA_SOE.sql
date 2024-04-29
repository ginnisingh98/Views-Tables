--------------------------------------------------------
--  DDL for Package Body PAY_ZA_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_SOE" as
/* $Header: pyzasoe.pkb 120.9.12010000.7 2009/11/18 09:47:41 rbabla ship $ */
--
g_debug boolean := hr_utility.debug_enabled;
g_max_action number;
g_min_action number;

--
--
/* ---------------------------------------------------------------------
Function : Get_Tax_Status

This funtion is used in the function Personal_Information to get the
Tax status for given assignment id and date earned.
------------------------------------------------------------------------ */
function Get_Tax_Status(p_assignment_id in number, p_date_earned in date) return varchar2 is
--
l_tax_status    varchar2(3);
l_tax_status_name varchar2(60);
--
begin
    --
    if g_debug then
        hr_utility.set_location('Entering pay_za_soe.Get_Tax_Status', 10);
    end if;
    --

    pay_balance_pkg.set_context('ASSIGNMENT_ID', to_char(p_assignment_id));
    pay_balance_pkg.set_context('DATE_EARNED', fnd_date.date_to_canonical(p_date_earned));

    l_tax_status := pay_balance_pkg.run_db_item('ZA_TAX_TAX_STATUS_ENTRY_VALUE', null, 'ZA');

    begin
        select meaning
        into   l_tax_status_name
        from   fnd_common_lookups
        where  lookup_type = 'ZA_TAX_STATUS'
        and    lookup_code = l_tax_status;

    exception
        when no_data_found then
            l_tax_status_name := '';
    end;

    --
    if g_debug then
        hr_utility.set_location('Leaving pay_za_soe.Get_Tax_Status', 20);
    end if;
    --
    return l_tax_status_name;
--
end Get_Tax_Status;
--
--
/* ---------------------------------------------------------------------
Function : getElements

This function returns a query which fetch all elements with runresult
value != 0 for given Assignment Action Id and Element Set Name
------------------------------------------------------------------------ */
function getElements(p_assignment_action_id number, p_element_set_name varchar2) return long is
--
l_sql long;
--
begin
--
    --
    if g_debug then
        hr_utility.set_location('Entering pay_soe_glb.getElements', 10);
    end if;
    --

    l_sql := 'Select nvl(ettl.reporting_name,et.element_type_id) COL01
                    ,nvl(ettl.reporting_name,ettl.element_name) COL02
                    ,to_char(sum(fnd_number.canonical_to_number(rrv.result_value)),fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
                    ,decode(count(*),1,''1'',''2'') COL17 -- destination indicator
                    ,decode(count(*),1,max(rr.run_result_id),max(et.element_type_id)) COL18
             From    pay_assignment_actions  aa
                    ,pay_run_results         rr
                    ,pay_run_result_values   rrv
                    ,pay_input_values_f      iv
                    ,pay_input_values_f_tl   ivtl
                    ,pay_element_types_f     et
                    ,pay_element_types_f_tl  ettl
                    ,pay_element_set_members esm
                    ,pay_element_sets        es
             Where   aa.assignment_action_id :action_clause
                     and aa.assignment_action_id = rr.assignment_action_id
                     and rr.status in (''P'',''PA'')
                     and rr.run_result_id = rrv.run_result_id
                     and rr.element_type_id = et.element_type_id
                     and :effective_date between et.effective_start_date and et.effective_end_date
                     and et.element_type_id = ettl.element_type_id
                     and rrv.input_value_id = iv.input_value_id
                     and iv.name = ''Pay Value''
                     and :effective_date between iv.effective_start_date and iv.effective_end_date
                     and iv.input_value_id = ivtl.input_value_id
                     and ettl.language = userenv(''LANG'')
                     and ivtl.language = userenv(''LANG'')
                     and et.element_type_id = esm.element_type_id
                     and esm.element_set_id = es.element_set_id
                     and ( es.BUSINESS_GROUP_ID is null
                      or es.BUSINESS_GROUP_ID = :business_group_id )
                     and ( es.LEGISLATION_CODE is null
                      or es.LEGISLATION_CODE = '':legislation_code'' )
                     and es.element_set_name = '''|| p_element_set_name ||'''
             group by nvl(ettl.reporting_name,ettl.element_name)
                     ,ettl.reporting_name
                     ,nvl(ettl.reporting_name,et.element_type_id)
             having  nvl(sum(fnd_number.canonical_to_number(rrv.result_value)),0) != 0
             order by nvl(ettl.reporting_name,ettl.element_name)';
    --
    if g_debug then
        hr_utility.set_location('Leaving pay_soe_glb.getElements', 20);
    end if;
    --
    return l_sql;
    --
end getElements;
--
--
/* ---------------------------------------------------------------------
Function : Personal_Information

This return returs SQL query which will be executed inoreder to fetch
data for Personal Information Region of ZA SOE.
------------------------------------------------------------------------ */
function Personal_Information(p_assignment_action_id in number) return long is
--
l_sql long;
l_date_earned varchar2(15);
l_run_assignment_action_id number;
l_assignment_id number;
l_payroll_action_id number;
l_assignment_action_id number;
--
begin
    --
    if g_debug then
        hr_utility.set_location('Entering pay_za_soe.Personal_Information', 10);
    end if;
    --
l_assignment_action_id := p_assignment_action_id;
    --5507715
          PAY_ZA_PAYROLL_ACTION_PKG.formula_inputs_hc (
                             p_assignment_action_id     =>  l_assignment_action_id
                            , p_run_assignment_action_id =>  l_run_assignment_action_id
                            , p_assignment_id            =>  l_assignment_id
                            , p_payroll_action_id        =>  l_payroll_action_id
                            , p_date_earned              =>  l_date_earned
                             );

    l_sql :=
       '
Select org.name  as COL01 -- Organisation Name
      ,org2.name as COL02 -- Legal Entity Name
      ,job.name  as COL03
      ,loc.location_code as COL04
      ,grd.name  as COL05
      ,pos.name  as COL06
      ,peo.national_identifier as COL07
      ,employee_number as COL08
      ,hl.meaning      as COL09 -- Nationality
      ,asg.assignment_number as COL10
      ,fnd_date.date_to_displaydate(pps.date_start) as COL11
      ,fnd_date.date_to_displaydate(pps.actual_termination_date) as COL12
      ,to_char(fnd_number.canonical_to_number(nvl(ppb1.salary,''0'')),fnd_currency.get_format_mask(:g_currency_code,40)) as  COL13
      ,peo.per_information1   as  COL14 -- Tax Reference Number
      ,pay_za_soe.get_tax_status(asg.assignment_id, :effective_date) as COL15
      ,ptp.period_num as  COL16
From   per_all_people_f          peo
      ,per_all_assignments_f     asg
      ,per_jobs_vl               job
      ,pay_assignment_actions    paa
      ,per_assignment_extra_info pae
      ,per_periods_of_service    pps
      ,pay_payroll_actions       ppa
      ,per_time_periods          ptp
      ,per_time_period_types     ptt
      ,hr_all_organization_units_vl org
      ,hr_all_organization_units_vl org2
      ,hr_locations       loc
      ,per_grades_vl      grd
      ,per_all_positions  pos
      ,pay_payrolls_f     pay
      ,pay_people_groups  pg
      ,hr_lookups         hl
      ,(select ppb2.pay_basis_id
              ,ppb2.business_group_id
              ,ee.assignment_id
              ,eev.screen_entry_value as salary
        from   per_pay_bases ppb2
              ,pay_element_entries_f ee
              ,pay_element_entry_values_f eev
        where  ppb2.input_value_id = eev.input_value_id
        and    ee.element_entry_id = eev.element_entry_id
        and    :effective_date between ee.effective_start_date and ee.effective_end_date
        and    :effective_date between eev.effective_start_date and eev.effective_end_date
        ) ppb1
Where asg.assignment_id = :assignment_id and
      :effective_date between asg.effective_start_date and asg.effective_end_date and
      asg.person_id = peo.person_id and
      :effective_date between peo.effective_start_date and peo.effective_end_date and
      asg.job_id = job.job_id(+) and
      asg.pay_basis_id  = ppb1.pay_basis_id(+) and
      asg.assignment_id = ppb1.assignment_id(+) and
      asg.business_group_id = ppb1.business_group_id(+) and
      paa.assignment_action_id = ''' || p_assignment_action_id || ''' and
      ppa.payroll_action_id = paa.payroll_action_id and
      ptp.payroll_id = ppa.payroll_id AND '
      || 'to_date(''' || l_date_earned ||''','|| '''YYYY/MM/DD''' ||')' || ' between ptp.start_date and ptp.end_date and
      ptp.period_type = ptt.period_type and
      pps.period_of_service_id = asg.period_of_service_id and
      asg.organization_id = org.organization_id and
      :effective_date between org.date_from and nvl(org.date_to, :effective_date) and
      pae.assignment_id(+) = asg.assignment_id and
      pae.aei_information_category(+) = ''ZA_SPECIFIC_INFO'' and
      org2.organization_id(+) = pae.aei_information7 and
      org2.date_from(+) <= :effective_date and
      nvl(org2.date_to(+), :effective_date) >= :effective_date and
      asg.location_id = loc.location_id(+) and
      asg.grade_id = grd.grade_id(+) and
      asg.people_group_id  = pg.people_group_id(+) and
      asg.position_id = pos.position_id(+) and
      asg.payroll_id = pay.payroll_id(+) and
      :effective_date between pay.effective_start_date(+) and pay.effective_end_date(+) and
      hl.application_id (+) = 800 and
      hl.lookup_type (+) = ''NATIONALITY'' and
      hl.lookup_code (+) = peo.nationality';
    --
    if g_debug then
        hr_utility.set_location('Leaving pay_za_soe.Personal_Information', 20);
    end if;
    --
    return l_sql;
--
end Personal_Information;
--
--
/* ---------------------------------------------------------------------
Function : Payroll_Processing_Information

This return returs SQL query which will be executed inoreder to fetch
data for Payroll Processing Information Region of ZA On line SOE.
------------------------------------------------------------------------ */
function Payroll_Processing_Information(p_assignment_action_id in number) return long is
--
l_sql long;
l_date_earned varchar2(15);
l_run_assignment_action_id number;
l_assignment_id number;
l_payroll_action_id number;
l_assignment_action_id number;
--
begin
    --
    if g_debug then
        hr_utility.set_location('Entering pay_za_soe.Payroll_Processing_Information', 10);
    end if;
    --
    l_assignment_action_id := p_assignment_action_id;
    --5507715
          PAY_ZA_PAYROLL_ACTION_PKG.formula_inputs_hc (
                             p_assignment_action_id     =>  l_assignment_action_id
                            , p_run_assignment_action_id =>  l_run_assignment_action_id
                            , p_assignment_id            =>  l_assignment_id
                            , p_payroll_action_id        =>  l_payroll_action_id
                            , p_date_earned              =>  l_date_earned
                             );
--
           l_sql :=
        'Select  ptp.period_name                                    as COL01    --  Period Name
                ,fnd_date.date_to_displaydate(ppa.effective_date)   as COL02    --  Pay Date
                ,ptp.period_type                                    as COL03    --  Period Type
                ,fnd_date.date_to_displaydate(ptp.start_date)       as COL04    --  Period Start Date
                ,fnd_date.date_to_displaydate(ptp.end_date)         as COL05    --  Period End Date
         From    per_time_periods        ptp
                ,pay_payroll_actions     ppa
                ,pay_assignment_actions  paa
                ,per_time_period_types   ptt
         Where   paa.assignment_action_id = ''' || p_assignment_action_id || ''' and
                 paa.payroll_action_id = ppa.payroll_action_id and
                 ptp.payroll_id        = ppa.payroll_id AND '
                 || 'to_date(''' || l_date_earned ||''','|| '''YYYY/MM/DD''' ||')' || ' between ptp.start_date and ptp.end_date and
                 ptp.period_type       = ptt.period_type';
    --
    if g_debug then
        hr_utility.set_location('Leaving pay_za_soe.Payroll_Processing_Information', 20);
    end if;
    --
    return l_sql;
--
end Payroll_Processing_Information;
--
--
/* ---------------------------------------------------------------------
Function : Elements1

This function returns a query which fetches all elements, which fells
under element set attached to element1 segment of SOE Information flexfeild,
with runresult value != 0 for given Assignment Action Id
------------------------------------------------------------------------ */
function Elements1(p_assignment_action_id in number) return long is
--
l_sql long;
--
begin
    --
    if g_debug then
        hr_utility.set_location('Entering pay_za_soe.Elements1', 10);
    end if;
    --

    l_sql := getElements(p_assignment_action_id, pay_soe_util.getConfig('ELEMENTS1'));

    --
    if g_debug then
        hr_utility.set_location('Leaving pay_za_soe.Elements1', 20);
    end if;
    --
    return l_sql;
--
end Elements1;
--
--
/* ---------------------------------------------------------------------
Function : Elements2

This function returns a query which fetches all elements, which fells
under element set attached to element2 segment of SOE Information flexfeild,
with runresult value != 0 for given Assignment Action Id
------------------------------------------------------------------------ */
function Elements2(p_assignment_action_id in number) return long is
--
l_sql long;
--
begin
    --
    if g_debug then
        hr_utility.set_location('Entering pay_za_soe.Elements2', 10);
    end if;
    --

    l_sql := getElements(p_assignment_action_id, pay_soe_util.getConfig('ELEMENTS2'));

    --
    if g_debug then
        hr_utility.set_location('Leaving pay_za_soe.Elements2', 20);
    end if;
    --
    return l_sql;
--
end Elements2;
--
--
/* ---------------------------------------------------------------------
Function : Elements3

This function returns a query which fetches all elements, which fells
under element set attached to element3 segment of SOE Information flexfeild,
with runresult value != 0 for given Assignment Action Id
------------------------------------------------------------------------ */
function Elements3(p_assignment_action_id in number) return long is
--
l_sql long;
--
begin
    --
    if g_debug then
        hr_utility.set_location('Entering pay_za_soe.Elements3', 10);
    end if;
    --

    l_sql := getElements(p_assignment_action_id, pay_soe_util.getConfig('ELEMENTS3'));

    --
    if g_debug then
        hr_utility.set_location('Leaving pay_za_soe.Elements3', 20);
    end if;
    --
    return l_sql;
--
end Elements3;
--
--
/* ---------------------------------------------------------------------
Function : Elements4

This function returns a query which fetches all elements, which fells
under element set attached to element4 segment of SOE Information flexfeild,
with runresult value != 0 for given Assignment Action Id
------------------------------------------------------------------------ */
function Elements4(p_assignment_action_id in number) return long is
--
l_sql long;
--
begin
    --
    if g_debug then
        hr_utility.set_location('Entering pay_za_soe.Elements4', 10);
    end if;
    --

    l_sql := getElements(p_assignment_action_id, pay_soe_util.getConfig('ELEMENTS4'));

    --
    if g_debug then
        hr_utility.set_location('Leaving pay_za_soe.Elements4', 20);
    end if;
    --
    return l_sql;
--
end Elements4;
--
--
/* ---------------------------------------------------------------------
Function : Elements5

This function returns a query which fetches all elements, which fells
under element set attached to element5 segment of SOE Information flexfeild,
with runresult value != 0 for given Assignment Action Id
------------------------------------------------------------------------ */
function Elements5(p_assignment_action_id in number) return long is
--
l_sql long;
--
begin
    --
    if g_debug then
        hr_utility.set_location('Entering pay_za_soe.Elements5', 10);
    end if;
    --

    l_sql := getElements(p_assignment_action_id, pay_soe_util.getConfig('ELEMENTS5'));

    --
    if g_debug then
        hr_utility.set_location('Leaving pay_za_soe.Elements5', 20);
    end if;
    --
    return l_sql;
--
end Elements5;
--
--
/* ---------------------------------------------------------------------
Function : Elements6

This function returns a query which fetches all elements, which fells
under element set attached to element6 segment of SOE Information flexfeild,
with runresult value != 0 for given Assignment Action Id
------------------------------------------------------------------------ */
function Elements6(p_assignment_action_id in number) return long is
--
l_sql long;
--
begin
    --
    if g_debug then
        hr_utility.set_location('Entering pay_za_soe.Elements6', 10);
    end if;
    --

    l_sql := getElements(p_assignment_action_id, pay_soe_util.getConfig('ELEMENTS6'));

    --
    if g_debug then
        hr_utility.set_location('Leaving pay_za_soe.Elements6', 20);
    end if;
    --
    return l_sql;
--
end Elements6;
--
--
/* ---------------------------------------------------------------------
Function : Balance_Details

This function is used to update balance details of Assignment Action Id.
There are 125 balances listed to include into balance region. Apart from
this wser can update 'SOE Detail Information' DFF to include those
balances to appear on Balances region of Online ZA SOE.
------------------------------------------------------------------------ */
function Balance_Details(p_assignment_action_id in number) return long is
--
l_sql long;
--
name_count                  number;
dim_id                      number;
balance_name                varchar2(80);
display_name                varchar2(80);
balance_suffix              varchar2(13);
balance_val                 varchar2(16);
bal_found_flag              varchar2(50);
l_date_earned varchar2(15);
l_run_assignment_action_id number;
l_assignment_id number;
l_payroll_action_id number;
l_assignment_action_id number;
--
type balance_rec is record
(
    balance_name            varchar2(80),
    display_name            varchar2(80),
    balance_suffix          varchar2(13)
);
--
type user_balance_table_type  is table of balance_rec   index by binary_integer;
--
l_max_user_balance_index    number := 0;
l_tab_index                 number := 0;
l_user_balance_table        user_balance_table_type;
--
cursor user_balances is
    Select  pbt.balance_name as balance_name
           ,nvl(org.org_information7,pbt.balance_name) as display_name
           ,pbd.dimension_name as balance_suffix
    From    pay_balance_types pbt
           ,pay_balance_dimensions pbd
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,per_all_assignments_f asg
           ,hr_organization_information org
    Where   paa.assignment_action_id = p_assignment_action_id and
            paa.assignment_id = asg.assignment_id and
            paa.payroll_action_id = ppa.payroll_action_id and
            ppa.effective_date between asg.effective_start_date and asg.effective_end_date and
            asg.organization_id = org.organization_id and
            org.org_information_context = 'Business Group:SOE Detail' and
            org.org_information1 = 'BALANCE' and
            pbt.balance_type_id = org.org_information4 and
            pbd.balance_dimension_id = org.org_information5;
--
begin
    --
    if g_debug then
        hr_utility.set_location('Entering pay_za_soe.Balance_Details', 10);
    end if;
    --

    --
    pay_soe_util.clear;
    --
l_assignment_action_id := p_assignment_action_id;

    --5507715
          PAY_ZA_PAYROLL_ACTION_PKG.formula_inputs_hc (
                             p_assignment_action_id     =>  l_assignment_action_id
                            , p_run_assignment_action_id =>  l_run_assignment_action_id
                            , p_assignment_id            =>  l_assignment_id
                            , p_payroll_action_id        =>  l_payroll_action_id
                            , p_date_earned              =>  l_date_earned
                             );

    -- Update user balance details
    for user_balances_rec in user_balances
    loop
        --
        balance_name    := user_balances_rec.balance_name;
        display_name    := user_balances_rec.display_name;
        balance_suffix  := user_balances_rec.balance_suffix;

        -- Update user balances info the local table
        l_max_user_balance_index := l_max_user_balance_index + 1;
        l_user_balance_table(l_max_user_balance_index).balance_name     := balance_name;
        l_user_balance_table(l_max_user_balance_index).display_name     := display_name;
        l_user_balance_table(l_max_user_balance_index).balance_suffix   := balance_suffix;

        -- This package is called to get the balance id which is needed in the get value package
        dim_id := pay_za_payroll_action_pkg.defined_balance_id(balance_name,balance_suffix);

        -- Use the get_value package to get value of balance
        balance_val := pay_balance_pkg.get_value(dim_id, l_run_assignment_action_id, false);

        if nvl(balance_val, 0) <> 0 then
            balance_val := to_char(fnd_number.canonical_to_number(balance_val),fnd_currency.get_format_mask('ZAR',40));
            pay_soe_util.setValue('01', balance_name, true, false);
            pay_soe_util.setValue('02', display_name, false, false);
            pay_soe_util.setValue('16', balance_val, false, true);
        end if;
        --
    end loop;
    --
    --

    -- Update standard balance details
    name_count := 1;
    loop
        --if name_count > 197 then
        --Added 2 new balances for 2008 Sars code
        if name_count > 215 then
            exit;
        end if;

         -- These balance names are hardcoded and should not be changed
         -- bug 3011568 added entries for the two new balances
         -- for 4346920 Balance feed enhancement Added PKG balances
         -- And Package Taxable Balances RFI and NRFI
         -- bug 6444483 added entries for the two new balances for 2008 Sars code
	 -- bug 6867418 added entries for the six more new balances for 2008 Sars code
         -- bug 8406456 added entries for the three new balances for TYS 2009 Sars code
         IF  name_count < 124 then
         select decode
                (
                    name_count,
                  1  , 'Taxable Income RFI',
                  2  , 'Taxable Income NRFI',
                  3  , 'Taxable Income PKG',
                  4  , 'Non Taxable Income',
                  5  , 'Taxable Pension RFI',
                  6  , 'Taxable Pension NRFI',
                  7  , 'Taxable Pension PKG',
                  8  , 'Non Taxable Pension',
                  9  , 'Taxable Annual Payment RFI',
                  10 , 'Taxable Annual Payment NRFI',
                  11 , 'Taxable Annual Payment PKG',
                  12 , 'Annual Bonus RFI',
                  13 , 'Annual Bonus NRFI',
                  14 , 'Annual Bonus PKG',
                  15 , 'Commission RFI',
                  16 , 'Commission NRFI',
                  17 , 'Commission PKG',
                  18 , 'Overtime RFI',
                  19 , 'Overtime NRFI',
                  20 , 'Overtime PKG',
                  21 , 'Taxable Arbitration Award RFI',
                  22 , 'Taxable Arbitration Award NRFI',
                  23 , 'Non Taxable Arbitration Award',
                  24 , 'Annuity from Retirement Fund RFI',
                  25 , 'Annuity from Retirement Fund NRFI',
                  26 , 'Annuity from Retirement Fund PKG',
                  27 , 'Purchased Annuity Taxable RFI',
                  28 , 'Purchased Annuity Taxable NRFI',
                  29 , 'Purchased Annuity Taxable PKG',
                  30 , 'Purchased Annuity Non Taxable',
                  31 , 'Travel Allowance RFI',
                  32 , 'Travel Allowance NRFI',
                  33 , 'Travel Allowance PKG',
                  34 , 'Taxable Reimbursive Travel RFI',
                  35 , 'Taxable Reimbursive Travel NRFI',
                  36 , 'Taxable Reimbursive Travel PKG',
                  37 , 'Non Taxable Reimbursive Travel',
                  38 , 'Taxable Subsistence RFI',
                  39 , 'Taxable Subsistence NRFI',
                  40 , 'Taxable Subsistence PKG',
                  41 , 'Non Taxable Subsistence',
                  42 , 'Entertainment Allowance RFI',
                  43 , 'Entertainment Allowance NRFI',
                  44 , 'Entertainment Allowance PKG',
                  45 , 'Share Options Exercised RFI',
                  46 , 'Share Options Exercised NRFI',
                  47 , 'Public Office Allowance RFI',
                  48 , 'Public Office Allowance NRFI',
                  49 , 'Public Office Allowance PKG',
                  50 , 'Uniform Allowance',
                  51 , 'Tool Allowance RFI',
                  52 , 'Tool Allowance NRFI',
                  53 , 'Tool Allowance PKG',
                  54 , 'Computer Allowance RFI',
                  55 , 'Computer Allowance NRFI',
                  56 , 'Computer Allowance PKG',
                  57 , 'Telephone Allowance RFI',
                  58 , 'Telephone Allowance NRFI',
                  59 , 'Telephone Allowance PKG',
                  60 , 'Other Taxable Allowance RFI',
                  61 , 'Other Taxable Allowance NRFI',
                  62 , 'Other Taxable Allowance PKG',
                  63 , 'Other Non Taxable Allowance',
                  64 , 'Asset Purchased at Reduced Value RFI',
                  65 , 'Asset Purchased at Reduced Value NRFI',
                  66 , 'Asset Purchased at Reduced Value PKG',
                  67 , 'Use of Motor Vehicle RFI',
                  68 , 'Use of Motor Vehicle NRFI',
                  69 , 'Use of Motor Vehicle PKG',
                  70 , 'Right of Use of Asset RFI',
                  71 , 'Right of Use of Asset NRFI',
                  72 , 'Right of Use of Asset PKG',
                  73 , 'Meals Refreshments and Vouchers RFI',
                  74 , 'Meals Refreshments and Vouchers NRFI',
                  75 , 'Meals Refreshments and Vouchers PKG',
                  76 , 'Free or Cheap Accommodation RFI',
                  77 , 'Free or Cheap Accommodation NRFI',
                  78 , 'Free or Cheap Accommodation PKG',
                  79 , 'Free or Cheap Services RFI',
                  80 , 'Free or Cheap Services NRFI',
                  81 , 'Free or Cheap Services PKG',
                  82 , 'Low or Interest Free Loans RFI',
                  83 , 'Low or Interest Free Loans NRFI',
                  84 , 'Low or Interest Free Loans PKG',
                  85 , 'Payment of Employee Debt RFI',
                  86 , 'Payment of Employee Debt NRFI',
                  87 , 'Payment of Employee Debt PKG',
                  88 , 'Bursaries and Scholarships RFI',
                  89 , 'Bursaries and Scholarships NRFI',
                  90 , 'Bursaries and Scholarships PKG',
                  91 , 'Medical Aid Paid on Behalf of Employee RFI',
                  92 , 'Medical Aid Paid on Behalf of Employee NRFI',
                  93 , 'Medical Aid Paid on Behalf of Employee PKG',
                  94 , 'Retirement or Retrenchment Gratuities',
                  95 , 'Resignation Pension and RAF Lump Sums',
                  96 , 'Retirement Pension and RAF Lump Sums',
                  97 , 'Resignation Provident Lump Sums',
                  98 , 'Retirement Provident Lump Sums',
                  99 , 'Special Remuneration',
                  100, 'Other Lump Sums',
                  101, 'Current Pension Fund',
                  102, 'Arrear Pension Fund',
                  103, 'Current Provident Fund',
                  104, 'Arrear Provident Fund',
                  105, 'Medical Aid Contribution',
                  106, 'Current Retirement Annuity',
                  107, 'Arrear Retirement Annuity',
                  108, 'Tax on Lump Sums',
                  109, 'Tax',
                  110, 'UIF Employee Contribution',
                  111, 'Voluntary Tax',
                  112, 'Bonus Provision',
                  113, 'SITE',
                  114, 'PAYE',
                  115, 'Annual Pension Fund',
                  116, 'Annual Commission RFI',
                  117, 'Annual Commission NRFI',
                  118, 'Annual Commission PKG',
                  119, 'Annual Provident Fund',
                  120, 'Restraint of Trade RFI',
                  121, 'Restraint of Trade NRFI',
                  122, 'Restraint of Trade PKG',
                  123, 'Annual Restraint of Trade RFI'
                )
         into   balance_name
         from   dual;
       else
         select decode
                (
                    name_count,
                  124, 'Annual Restraint of Trade NRFI',
                  125, 'Annual Restraint of Trade PKG',
                  126, 'Annual Asset Purchased at Reduced Value RFI',
                  127, 'Annual Asset Purchased at Reduced Value NRFI',
                  128, 'Annual Asset Purchased at Reduced Value PKG',
                  129, 'Annual Retirement Annuity',
                  130, 'Annual Arrear Pension Fund',
                  131, 'Annual Arrear Retirement Annuity',
                  132, 'Other Retirement Lump Sums',
                  133, 'Directors Deemed Remuneration',
                  134, 'Annual Bursaries and Scholarships RFI',
                  135, 'Annual Bursaries and Scholarships NRFI',
                  136, 'Annual Bursaries and Scholarships PKG',
                  137, 'Labour Broker Payments RFI',
                  138, 'Labour Broker Payments NRFI',
                  139, 'Labour Broker Payments PKG',
                  140, 'Annual Labour Broker Payments RFI',
                  141, 'Annual Labour Broker Payments NRFI',
                  142, 'Annual Labour Broker Payments PKG',
                  143, 'Independent Contractor Payments RFI',
                  144, 'Independent Contractor Payments NRFI',
                  145, 'Independent Contractor Payments PKG',
                  146, 'Annual Independent Contractor Payments RFI',
                  147, 'Annual Independent Contractor Payments NRFI',
                  148, 'Annual Independent Contractor Payments PKG',
                  149, 'Annual Payment of Employee Debt RFI',
                  150, 'Annual Payment of Employee Debt NRFI',
                  151, 'Annual Payment of Employee Debt PKG',
                  152, 'Annual Taxable Package Components RFI',
                  153, 'Taxable Package Components RFI',
                  154, 'Annual Taxable Package Components NRFI',
                  155, 'Taxable Package Components NRFI',
                  156, 'Taxable Subsistence Allowance Foreign Travel RFI',
                  157, 'Taxable Subsistence Allowance Foreign Travel NRFI',
                  158, 'Taxable Subsistence Allowance Foreign Travel PKG',
                  159, 'Non Taxable Subsistence Allowance Foreign Travel',
                  160, 'Executive Equity Shares RFI',
                  161, 'Executive Equity Shares NRFI',
                  162, 'EE Income Protection Policy Contributions',
                  163, 'Annual EE Income Protection Policy Contributions',
                  164, 'EE Broadbased Share Plan NRFI',
                  165, 'EE Broadbased Share Plan RFI',
                  166, 'EE Broadbased Share Plan PKG',
                  167, 'Other Lump Sum Taxed as Annual Payment NRFI',
                  168, 'Other Lump Sum Taxed as Annual Payment RFI',
                  169, 'Other Lump Sum Taxed as Annual Payment PKG',
                  -- Begin: New Balances for TYS 06-07
                  170, 'Med Costs Pd by ER IRO EE_Family RFI',
                  171, 'Med Costs Pd by ER IRO EE_Family NRFI',
                  172, 'Med Costs Pd by ER IRO EE_Family PKG',
                  173, 'Annual Med Costs Pd by ER IRO EE_Family RFI',
                  174, 'Annual Med Costs Pd by ER IRO EE_Family NRFI',
                  175, 'Annual Med Costs Pd by ER IRO EE_Family PKG',
                  176, 'Annual Med Costs Pd by ER IRO Other RFI',
                  177, 'Annual Med Costs Pd by ER IRO Other NRFI',
                  178, 'Annual Med Costs Pd by ER IRO Other PKG',
                  179, 'Med Costs Pd by ER IRO Other RFI',
                  180, 'Med Costs Pd by ER IRO Other NRFI',
                  181, 'Med Costs Pd by ER IRO Other PKG',
                  182, 'Medical Contributions Abatement',
                  183, 'Annual Medical Contributions Abatement',
                  184, 'Medical Fund Capping Amount',
                  185, 'Med Costs Dmd Pd by EE EE_Family RFI',
                  186, 'Med Costs Dmd Pd by EE EE_Family NRFI',
                  187, 'Med Costs Dmd Pd by EE EE_Family PKG',
                  188, 'Annual Med Costs Dmd Pd by EE EE_Family RFI',
                  189, 'Annual Med Costs Dmd Pd by EE EE_Family NRFI',
                  190, 'Annual Med Costs Dmd Pd by EE EE_Family PKG',
                  191, 'Med Costs Dmd Pd by EE Other RFI',
                  192, 'Med Costs Dmd Pd by EE Other NRFI',
                  193, 'Med Costs Dmd Pd by EE Other PKG',
                  194, 'Annual Med Costs Dmd Pd by EE Other RFI',
                  195, 'Annual Med Costs Dmd Pd by EE Other NRFI',
                  196, 'Annual Med Costs Dmd Pd by EE Other PKG',
                  197, 'Non Taxable Med Costs Pd by ER',
                  -- End: New Balances for TYS 06-07
                  -- Start for 2008 SARS codes
                  198, 'Employers Retirement Annuity Fund Contributions',
                  199, 'Employers Premium paid on Loss of Income Policies',
                  200, 'Medical Contr Pd by ER for Retired EE',
                  201, 'Surplus Apportionment',
                  202, 'Unclaimed Benefits',
                  203, 'Retire Pen RAF Prov Fund Ben on Ret or Death RFI',
                  204, 'Retire Pen RAF Prov Fund Ben on Ret or Death NRFI',
                  205, 'Tax on Retirement Fund Lump Sums',
                  --Added for Bug 7634596
                  206, 'Pension Employer Contribution',
                  207, 'Provident Employer Contribution',
                  208, 'Medical Aid Employer Contribution',
                  --Added for Bug 8406456-Mar2009 Sars codes
                  209, 'Retire Pen RAF and Prov Fund Lump Sum withdrawal benefits',
                  210, 'Donations made by EE and paid by ER',
                  211, 'Annual Donations made by EE and paid by ER',
                  --End for Bug 8406456
		  --Added for new balances for EE Debt for net to gross
		  212, 'Annual Payment of Employee Debt NRFI NTG',
		  213, 'Annual Payment of Employee Debt RFI NTG',
		  214, 'PAYE Employer Contribution for Tax Free Earnings',
                  215, 'Living Annuity and Surplus Apportionments Lump Sums'
                )
         into   balance_name
         from   dual;
       END if;

        balance_suffix := '_ASG_TAX_YTD';
        if balance_name = 'Directors Deemed Remuneration' then
            balance_suffix := '_ASG_ITD';
        end if;

        -- Check whether this balace already exists in user balances
        bal_found_flag := 'false';
        for l_tab_index in 1..l_max_user_balance_index loop
            if balance_name = l_user_balance_table(l_tab_index).balance_name and
                    balance_suffix = l_user_balance_table(l_tab_index).balance_suffix then
                bal_found_flag := 'true';
            end if;
        end loop;

        -- Update standard balance details if it is not already updated in user balance details
        if(bal_found_flag = 'false') then
             -- This package is called to get the balance id which is needed in the get value package
             dim_id := pay_za_payroll_action_pkg.defined_balance_id(balance_name,balance_suffix);

             -- Use the get_value package to get value of balance
             balance_val := pay_balance_pkg.get_value(dim_id, l_run_assignment_action_id, false);

             if nvl(balance_val, 0) <> 0 then
                balance_val := to_char(fnd_number.canonical_to_number(balance_val),fnd_currency.get_format_mask('ZAR',40));
                pay_soe_util.setValue('01', balance_name, true, false);
                pay_soe_util.setValue('02', balance_name, false, false);
                pay_soe_util.setValue('16', balance_val, false, true);
             end if;
        end if;
        name_count := name_count + 1;

    end loop;
    l_sql := pay_soe_util.genCursor || ' order by 2';
    pay_soe_util.clear;
    --
    --
    if g_debug then
        hr_utility.set_location('Leaving pay_za_soe.Balance_Details', 20);
    end if;
    --
    return l_sql;
--
end Balance_Details;
--
--
/* ---------------------------------------------------------------------
Function : Payment_Method_Details

Text
------------------------------------------------------------------------ */
function Payment_Method_Details(p_assignment_action_id in number) return long is
--
l_sql long;
l_date_earned varchar2(15);
l_run_assignment_action_id number;
l_assignment_id number;
l_payroll_action_id number;
l_assignment_action_id number;
--
begin

    if g_debug then
        hr_utility.set_location('Entering pay_za_soe.Payment_Method_Details', 10);
    end if;
l_assignment_action_id := p_assignment_action_id;
    --5507715
          PAY_ZA_PAYROLL_ACTION_PKG.formula_inputs_hc(
                             p_assignment_action_id     =>  l_assignment_action_id
                            , p_run_assignment_action_id =>  l_run_assignment_action_id
                            , p_assignment_id            =>  l_assignment_id
                            , p_payroll_action_id        =>  l_payroll_action_id
                            , p_date_earned              =>  l_date_earned
                             );
      --
            l_sql :=
       'Select  substr(popmf.org_payment_method_name, 1, 30)    as  COL01   -- Payment Method
               ,ppt.payment_type_name                           as  COL02   -- Payment Type
               ,cdv.bank_name                                   as  COL03   -- Bank
               ,pea.segment1                                    as  COL04   -- Branch Code
               ,pea.segment3                                    as  COL05   -- Account No
               ,to_char(ppp.value, fnd_currency.get_format_mask(:g_currency_code,40)) as  COL16   -- Payment Amount -- Bug 4392560
               ,fnd_date.date_to_displaydate( '
               || 'to_date(''' || l_date_earned ||''','|| '''YYYY/MM/DD''' ||')'
               ||')   as  COL06   -- Payment_date
        From    pay_pre_payments ppp
               ,pay_personal_payment_methods_f pppmf
               ,pay_org_payment_methods_f popmf
               ,pay_external_accounts pea
               ,pay_za_branch_cdv_details cdv
               ,pay_assignment_actions paa
               ,pay_payroll_actions ppa
               ,pay_payment_types_tl ppt
               ,pay_action_interlocks pai
        Where   (pai.locked_action_id = :assignment_action_id or pai.locking_action_id = :assignment_action_id) and
                paa.assignment_action_id = pai.locking_action_id and
                paa.payroll_action_id = ppa.payroll_action_id and
                ppa.action_type in (''P'' , ''U'') and
                ppp.assignment_action_id = paa.assignment_action_id and
                pppmf.personal_payment_method_id (+) = ppp.personal_payment_method_id and
                ppa.effective_date between nvl(pppmf.effective_start_date, ppa.effective_date) and
                nvl(pppmf.effective_end_date, ppa.effective_date) and
                ppa.effective_date between popmf.effective_start_date and
                popmf.effective_end_date and
                popmf.org_payment_method_id = ppp.org_payment_method_id and
                pea.external_account_id (+) = pppmf.external_account_id and
                cdv.branch_code (+) = pea.segment1 and
                popmf.payment_type_id = ppt.payment_type_id(+) and
                ppt.language(+) = userenv(''LANG'')';
    --
    if g_debug then
        hr_utility.set_location('Leaving pay_za_soe.Payment_Method_Details', 20);
    end if;
    --
    return l_sql;
--
end Payment_Method_Details;
--
--
end PAY_ZA_SOE;

/
