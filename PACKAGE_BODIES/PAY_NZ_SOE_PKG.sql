--------------------------------------------------------
--  DDL for Package Body PAY_NZ_SOE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NZ_SOE_PKG" as
/* $Header: pynzsoe.pkb 120.0.12000000.4 2007/06/04 11:54:56 dduvvuri noship $ */

/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  NZ HRMS statement of earnings package
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  10 MAY 2000 JMHATRE  N/A       Creation
**  04 AUG 2000 NDOMA    N/A       Added two procedures which is required
**                                 for NZ SOE window(get_details and
**								   get_asg_latest_pay).
**  21 AUG 2000 NDOMA    N/A       Added new procedure(final_balance_totals)
**                                 Which is used to get the cumulative run
**                                 balances if the prepayments is run for
**                                 selected run or prepayments.
**
**  11 JUN 2001 SHOSKATT Bug : 1817816
**                                 get_tax_code function changed to retrieve Special
**                                 Tax Code along with Tax Code. Also the function
**                                 changed to check for date conditions
**  10 JAN 2002 SRRAJAGO 2177800   Included Action_type 'C' for Costing process
**  10 OCT 2002 PUCHIL   2595888   Changed the type of variable l_action_type
**                                 from  varchar2(1) to pay_payroll_actions.action_type%type
**  19 NOV 2002 SRRAJAGO 2636739   Removed the action_type 'C' only from cursor asg_latest_pay of the procedure get_asg_latest_pay
**  03 DEC 2002 SRRAJAGO 2689221   Included 'nocopy' option for the 'out' and 'in out' parameters of all the procedures.
**  17 NOV 2003 PUCHIL   3257888   Added language check to cursors c_get_work_address and c_get_home_address.
**  08 APR 2004 PUCHIL   3453503   Added logic to support Advanced Retropay.
**  04 JUN 2007 DDUVVURI 6083911   Removed the condition "legislation_code is null" in the cursor in procedure run_and_ytd_balances
*/

--
--  get_tax_code
--

function get_tax_code (p_run_assignment_action_id number) return varchar2 is

  l_tax_code pay_run_result_values.result_value%type;
  l_special_tax_code pay_run_result_values.result_value%type;

  --
  -- Fetch Special Tax Code along with Tax Code (Bug No : 1817816)
  --
  cursor c_tax_code (p_assignment_action_id number) is
    select rrv.result_value,rrv1.result_value
    from   pay_element_types_f et
    ,      pay_input_values_f iv
    ,      pay_run_result_values rrv
    ,      pay_run_results rr
    ,      pay_input_values_f iv1
    ,      pay_run_result_values rrv1
    ,      pay_payroll_actions ppa
    ,      pay_assignment_actions paa
    where  et.element_name = 'PAYE Information'
    and    et.legislation_code = 'NZ'
    and    iv.element_type_id = et.element_type_id
    and    iv.name = 'Tax Code'
    and    rr.element_type_id = et.element_type_id
    and    rr.assignment_action_id = p_assignment_action_id
    and    rrv.run_result_id = rr.run_result_id
    and    rrv.input_value_id = iv.input_value_id
    and    iv1.element_type_id = et.element_type_id
    and    iv1.name = 'Special Tax Code'
    and    rrv1.run_result_id = rr.run_result_id
    and    rrv1.input_value_id = iv1.input_value_id
    and    ppa.payroll_action_id = paa.payroll_action_id
    and    paa.assignment_action_id = rr.assignment_action_id
    and    ppa.effective_date between et.effective_start_date and et.effective_end_date
    and    ppa.effective_date between iv.effective_start_date and iv.effective_end_date
    and    ppa.effective_date between iv1.effective_start_date and iv1.effective_end_date;

begin

  hr_utility.set_location('pay_nz_soe_pkg.get_tax_code', 10) ;

  open c_tax_code (p_run_assignment_action_id) ;
  fetch c_tax_code into l_tax_code,l_special_tax_code ;
  if c_tax_code%notfound
  then
    l_tax_code := null ;
    l_special_tax_code := null ;
  end if ;
  --
  -- If record is found and Special tax Code is Yes, then return Tax Code as STC (Bug No 1817816)
  --
  if (c_tax_code%found and l_special_tax_code = 'Y') then
    l_tax_code := 'STC' ;
  end if;
  close c_tax_code ;

  hr_utility.set_location('pay_nz_soe_pkg.get_tax_code', 20) ;

  return l_tax_code ;

exception
  when others then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL') ;
    hr_utility.set_message_token('PROCEDURE', 'pay_nz_soe_pkg.get_tax_code') ;
    hr_utility.set_message_token('STEP','body') ;
    hr_utility.raise_error ;

end get_tax_code ;

--
--  get_home_address
--
Procedure get_home_address(p_person_id    IN     NUMBER,
                           p_addr_line1   OUT NOCOPY VARCHAR2,
                           p_addr_line2   OUT NOCOPY VARCHAR2,
                           p_addr_line3   OUT NOCOPY VARCHAR2,
                           p_town_city    OUT NOCOPY VARCHAR2,
                           p_postal_code  OUT NOCOPY VARCHAR2,
                           p_country_name OUT NOCOPY VARCHAR2) IS

 Cursor c_get_home_address (cp_person_id NUMBER) is
        select substr(pad.address_line1,1,27),
               substr(pad.address_line2,1,27),
               substr(pad.address_line3,1,27),
               substr(pad.town_or_city,1,27),
               pad.postal_code,
               substr(ftt.territory_short_name,1,27)
        from   per_addresses pad,
               fnd_territories_tl ftt
        where  pad.country = ftt.territory_code
	and    ftt.language = USERENV('LANG') -- Bug 3257888
        and    pad.person_id = cp_person_id
        and    sysdate between nvl(pad.date_from, sysdate) and nvl(pad.date_to, sysdate);

 Begin
    hr_utility.set_location('pay_nz_soe_pkg.get_home_address', 10) ;
    open  c_get_home_address(p_person_id);
    fetch c_get_home_address into p_addr_line1,
                                  p_addr_line2,
                                  p_addr_line3,
                                  p_town_city,
                                  p_postal_code,
                                  p_country_name;
    close c_get_home_address;
    hr_utility.set_location('pay_nz_soe_pkg.get_home_address', 20) ;

 Exception
  when others then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL') ;
    hr_utility.set_message_token('PROCEDURE', 'pay_nz_soe_pkg.get_home_address') ;
    hr_utility.set_message_token('STEP','body') ;
    hr_utility.raise_error ;

 End;

--
--  get_work_address
--

Procedure get_work_address(p_location_id  IN     NUMBER,
                           p_addr_line1   OUT NOCOPY VARCHAR2,
                           p_addr_line2   OUT NOCOPY VARCHAR2,
                           p_addr_line3   OUT NOCOPY VARCHAR2,
                           p_town_city    OUT NOCOPY VARCHAR2,
                           p_postal_code  OUT NOCOPY VARCHAR2,
                           p_country_name OUT NOCOPY VARCHAR2) IS

 Cursor c_get_work_address(cp_location_id NUMBER) is
        select substr(hrl.address_line_1,1,27),
               substr(hrl.address_line_2,1,27),
               substr(hrl.address_line_3,1,27),
               substr(hrl.town_or_city,1,27),
               hrl.postal_code,
               substr(ftt.territory_short_name,1,27)
        from   hr_locations hrl,
               fnd_territories_tl ftt
        where  hrl.country = ftt.territory_code
	and    ftt.language = USERENV('LANG') -- Bug 3257888
        and    hrl.location_id = cp_location_id;

 Begin
    hr_utility.set_location('pay_nz_soe_pkg.get_work_address', 10) ;
    open  c_get_work_address(p_location_id);
    fetch c_get_work_address into p_addr_line1,
                                  p_addr_line2,
                                  p_addr_line3,
                                  p_town_city,
                                  p_postal_code,
                                  p_country_name;
    close c_get_work_address;
    hr_utility.set_location('pay_nz_soe_pkg.get_work_address', 20) ;

 Exception
  when others then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL') ;
    hr_utility.set_message_token('PROCEDURE', 'pay_nz_soe_pkg.get_work_address') ;
    hr_utility.set_message_token('STEP','body') ;
    hr_utility.raise_error ;

 End;

--
--  get_salary
--

function GET_SALARY (
--
           p_pay_basis_id   number,
           p_assignment_id  number,
           p_effective_date date)   return varchar2  is
--
-- clone of hr_general.get_salary but fetcH At a given date
-- This cursor gets the screen_entry_value from pay_element_entry_values_f.
-- This is the salary amount
-- obtained when the pay basis isn't null. The pay basis and assignment_id
-- are passed in by the view. A check is made on the effective date of
-- pay_element_entry_values_f and pay_element_entries_f as they're datetracked.
--
cursor csr_lookup is
       select eev.screen_entry_value
       from   pay_element_entry_values_f eev,
              per_pay_bases              ppb,
              pay_element_entries_f       pe
       where  ppb.pay_basis_id  +0 = p_pay_basis_id
       and    pe.assignment_id     = p_assignment_id
       and    eev.input_value_id   = ppb.input_value_id
       and    eev.element_entry_id = pe.element_entry_id

       and    eev.input_value_id   = ppb.input_value_id
       and    eev.element_entry_id = pe.element_entry_id
       and    p_effECtive_date between
                        eev.effective_start_date and eev.effective_end_date
       and    p_EFfective_date between
                        pe.effective_start_date and pe.effective_end_date;
--
  v_meaning          varchar2(60);
begin
  --
  -- Only open the cursor if the parameter may retrieve anything
  -- In practice, p_assignment_id is always going to be non null;
  -- p_pay_basis_id may be null, though. If it is, don't bother trying
  -- to fetch a salary.
  --
  -- If we do have a pay basis, try and get a salary. There may not be one,
  -- in which case no problem: just return null.
  --
    if p_pay_basis_id is not null and p_assignment_id is not null then
      open csr_lookup;
      fetch csr_lookup into v_meaning;
      close csr_lookup;

    end if;
  --
  -- Return the salary value, if this does not exist, return a null value.
  --
  return v_meaning;
end get_salary;

------------------------------------------------------------------------
  -- Returns the Currency Code for the Business Group.
  ------------------------------------------------------------------------
  function business_currency_code
    (p_business_group_id  in hr_organization_units.business_group_id%type)
  return fnd_currencies.currency_code%type is

    v_currency_code  fnd_currencies.currency_code%type;

    cursor currency_code
      (c_business_group_id  hr_organization_units.business_group_id%type) is
    select fcu.currency_code
    from   hr_organization_information hoi,
           hr_organization_units hou,
           fnd_currencies fcu
    where  hou.business_group_id       = c_business_group_id
    and    hou.organization_id         = hoi.organization_id
    and    hoi.org_information_context = 'Business Group Information'
    and    fcu.issuing_territory_code  = hoi.org_information9;

begin
  open currency_code (p_business_group_id);
  fetch currency_code into v_currency_code;
  close currency_code;

  return v_currency_code;
end business_currency_code;

------------------------------------------------------------------------
  -- Procedure to merely pass all the balance results back in one hit,
  -- rather than 6 separate calls.
  ------------------------------------------------------------------------
  procedure balance_totals
    (p_assignment_id               in per_all_assignments_f.assignment_id%type,
     p_assignment_action_id        in pay_assignment_actions.assignment_action_id%type,
     p_effective_date              in date,
     p_gross_this_pay              out nocopy number,
     p_other_deductions_this_pay   out nocopy number,
     p_tax_deductions_this_pay     out nocopy number,
     p_gross_ytd                   out nocopy number,
     p_other_deductions_ytd        out nocopy number,
     p_tax_deductions_ytd          out nocopy number,
     p_non_tax_allow_this_pay      out nocopy number,
     p_non_tax_allow_ytd           out nocopy number,
     p_pre_tax_deductions_this_pay out nocopy number,
     p_pre_tax_deductions_ytd      out nocopy number)
  is
    v_Extra_Emolument_Tax_Ear_run  number;
    v_Extra_Emolument_Tax_Ear_ytd   number;
    v_Ordinary_Tax_Ear_run             number;
    v_Ordinary_Tax_Ear_ytd             number;
    v_Retro_Ordinary_Tax_Ear_run   number;
    v_Retro_Ordinary_Tax_Ear_ytd   number;
    v_Retiring_Redund_Tax_Ear_run  number;
    v_Retiring_Redund_Tax_Ear_ytd  number;
    v_Withholding_Payments_run                  number;
    v_Withholding_Payments_ytd                  number;
    v_pre_tax_deductions_run      number;
    v_pre_tax_deductions_ytd      number;
    v_voluntary_deductions_run    number;
    v_voluntary_deductions_ytd    number;
    v_leg_order_deductions_run    number;
    v_leg_order_deductions_ytd    number;
    v_tax_deductions_run          number;
    v_tax_deductions_ytd          number;
    v_retro_tax_deductions_run    number;
    v_retro_tax_deductions_ytd    number;
    v_Non_Tax_Reimbursements_run  number;
    v_Non_Tax_Reimbursements_ytd  number;


  begin
run_and_ytd_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Extra Emolument Taxable Earnings',
                          p_run_balance           => v_Extra_Emolument_Tax_Ear_run,
                          p_ytd_balance           => v_Extra_Emolument_Tax_Ear_ytd);

 run_and_ytd_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Ordinary Taxable Earnings',
                          p_run_balance           => v_Ordinary_Tax_Ear_run,
                          p_ytd_balance           => v_Ordinary_Tax_Ear_ytd);

-- Bug 3453503 - Added to support Advanced Retropay
 run_and_ytd_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Retro Ordinary Taxable Earnings',
                          p_run_balance           => v_retro_Ordinary_Tax_Ear_run,
                          p_ytd_balance           => v_retro_Ordinary_Tax_Ear_ytd);

 run_and_ytd_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Retiring and Redundancy Taxable Earnings',
                          p_run_balance           => v_Retiring_Redund_Tax_Ear_run,
                          p_ytd_balance           => v_Retiring_Redund_Tax_Ear_ytd);

 run_and_ytd_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Withholding Payments',
                          p_run_balance           => v_Withholding_Payments_run,
                          p_ytd_balance           => v_Withholding_Payments_ytd);

    run_and_ytd_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Pre Tax Deductions',
                          p_run_balance           => v_pre_tax_deductions_run,
                          p_ytd_balance           => v_pre_tax_deductions_ytd);

    run_and_ytd_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Voluntary Deductions',
                          p_run_balance           => v_voluntary_deductions_run,
                          p_ytd_balance           => v_voluntary_deductions_ytd);
run_and_ytd_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Tax Deductions',
                          p_run_balance           => v_tax_deductions_run,
                          p_ytd_balance           => v_tax_deductions_ytd);

-- Bug 3453503 - Added to support Advanced Retropay
run_and_ytd_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Retro Tax Deductions',
                          p_run_balance           => v_retro_tax_deductions_run,
                          p_ytd_balance           => v_retro_tax_deductions_ytd);

run_and_ytd_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Legislative Order Deductions',
                          p_run_balance           => v_leg_order_deductions_run,
                          p_ytd_balance           => v_leg_order_deductions_ytd);

run_and_ytd_balances (p_assignment_id         => p_assignment_id,
                          p_assignment_action_id  => p_assignment_action_id,
                          p_effective_date        => p_effective_date,
                          p_balance_name          => 'Non Taxable Reimbursements',
                          p_run_balance           => v_Non_Tax_Reimbursements_run,
                          p_ytd_balance           => v_Non_Tax_Reimbursements_ytd);

   p_gross_this_pay      := v_Extra_Emolument_Tax_Ear_run +
                            v_Ordinary_Tax_Ear_run     +
                            v_Retro_Ordinary_Tax_Ear_run     + -- Bug 3453503
                            v_Retiring_Redund_Tax_Ear_run +
                            v_Withholding_Payments_run ;


     p_gross_ytd          := v_Withholding_Payments_ytd +
                             v_Extra_Emolument_Tax_Ear_ytd  +
                             v_Retiring_Redund_Tax_Ear_ytd +
                             v_Retro_Ordinary_Tax_Ear_ytd + -- Bug 3453503
                             v_Ordinary_Tax_Ear_ytd;

   p_non_tax_allow_this_pay := v_Non_Tax_Reimbursements_run;

    p_non_tax_allow_ytd := v_Non_Tax_Reimbursements_ytd;

    p_other_deductions_this_pay :=  v_pre_tax_deductions_run    +
                                    v_voluntary_deductions_run   +
                                    v_leg_order_deductions_run ;

    p_other_deductions_ytd :=  v_leg_order_deductions_ytd  +
                               v_pre_tax_deductions_ytd    +
                               v_voluntary_deductions_ytd  ;

    p_tax_deductions_this_pay   := v_tax_deductions_run +
                                   v_retro_tax_deductions_run; -- Bug 3453503

    p_tax_deductions_ytd        := v_tax_deductions_ytd +
                                   v_retro_tax_deductions_ytd; --Bug 3453503

     p_pre_tax_deductions_this_pay := v_pre_tax_deductions_run;

     p_pre_tax_deductions_ytd := v_pre_tax_deductions_ytd;

  end balance_totals;
  ------------------------------------------------------------------------

 ------------------------------------------------------------------------
  -- Sums the Balances for This Pay and YTD, according to the parameters.
  ------------------------------------------------------------------------
  procedure run_and_ytd_balances
    (p_assignment_id         in per_all_assignments_f.assignment_id%type,
     p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_effective_date        in date,
     p_balance_name          in pay_balance_types.balance_name%type,
     p_run_balance           out nocopy number,
     p_ytd_balance           out nocopy number)
  is

    cursor run_and_ytd_value
      (c_assignment_id         pay_assignment_actions.assignment_id%type,
       c_assignment_action_id  pay_assignment_actions.assignment_action_id%type,
       c_effective_date        date,
       c_balance_name          pay_balance_types.balance_name%type) is
    select nvl(hr_nzbal.calc_asg_run(c_assignment_action_id,
                                     balance_type_id,
                                     c_effective_date,
                                     c_assignment_id),0),
           nvl(hr_nzbal.calc_asg_ytd(c_assignment_action_id,
                                     balance_type_id,
                                     c_effective_date,
                                     c_assignment_id),0)
    from   pay_balance_types
    where  balance_name = c_balance_name
    -- Modified the condition for bug 6083911
    and     legislation_code = 'NZ';

  begin
    open run_and_ytd_value (p_assignment_id,
                            p_assignment_action_id,
                            p_effective_date,
                            p_balance_name);
    fetch run_and_ytd_value into p_run_balance,
                                 p_ytd_balance;
    close run_and_ytd_value;
 end run_and_ytd_balances;

procedure get_asg_latest_pay(p_session_date in     date,
                 p_payroll_exists           in out nocopy varchar2,
                 p_assignment_action_id     in out nocopy number,
                 p_run_assignment_action_id in out nocopy number,
                 p_assignment_id            in     number,
                 p_payroll_id               out nocopy number,
                 p_payroll_action_id        in out nocopy number,
                 p_date_earned              in out nocopy varchar2,
                 p_time_period_id           out nocopy number,
                 p_period_name              out nocopy varchar2,
                 p_pay_advice_date          out nocopy date,
                 p_pay_advice_message       out nocopy varchar2)
is

-- get the latest prepayments action for this individual and get the
-- details of the last run that that action locked
cursor asg_latest_pay is
select
        rppa.date_earned,
        rpaa.payroll_action_id,
        rpaa.assignment_action_id,
        paa.assignment_action_id,
        ptp.time_period_id,
        ptp.period_name,
        rppa.payroll_id,
        nvl(rppa.pay_advice_date,ptp.pay_advice_date),
        rppa.pay_advice_message
from    pay_assignment_actions paa,
        pay_payroll_actions ppa,
        pay_assignment_actions rpaa,
        per_time_periods ptp,
        pay_payroll_actions rppa
where  paa.payroll_action_id = ppa.payroll_action_id
and    rppa.payroll_action_id = rpaa.payroll_action_id
and    rppa.time_period_id = ptp.time_period_id
and    paa.assignment_action_id =
        (select to_number(substr(max(to_char(pa.effective_date,'J')||lpad(aa.assignment_action_id,15,'0')),8))
          from   pay_payroll_actions pa,
                  pay_assignment_actions aa
          where  pa.action_type in ('U','P')
          and    aa.action_status = 'C'
          and   pa.payroll_action_id = aa.payroll_action_id
          and aa.assignment_id = p_assignment_id
          and pa.effective_date <= p_session_date)
and    ppa.action_type in ('P', 'U')
and    rpaa.assignment_id = p_assignment_id
and    rpaa.action_sequence =
        (select max(aa.action_sequence)
         from   pay_assignment_actions aa,
                pay_action_interlocks loc
         where loc.locked_action_id = aa.assignment_action_id
         and loc.locking_action_id = paa.assignment_action_id);
begin
  open asg_latest_pay;
  fetch asg_latest_pay into p_date_earned,
             p_payroll_action_id,
             p_run_assignment_action_id,
             p_assignment_action_id,
             p_time_period_id,
             p_period_name,
             p_payroll_id,
             p_pay_advice_date,
             p_pay_advice_message;
  if asg_latest_pay%FOUND then
     p_payroll_exists := 'TRUE';
  end if;
  close asg_latest_pay;
end get_asg_latest_pay;

------------------------------------------------------------------
procedure get_details (p_assignment_action_id    in out nocopy number,
                      p_run_assignment_action_id in out nocopy number,
                      p_assignment_id            in out nocopy  number,
                      p_payroll_id               out nocopy number,
                      p_payroll_action_id        in out nocopy number,
                      p_date_earned              in out nocopy date,
                      p_time_period_id           out nocopy number,
                      p_period_name              out nocopy varchar2,
                      p_pay_advice_date          out nocopy date,
                      p_pay_advice_message       out nocopy varchar2) is

-- if the assignment action is a run then return the run details
-- if the assignment action is a prepayment return the latest run
--locked by the prepayment

cursor get_action_type is
-- find type of action this is
               select pact.action_type , assact.assignment_id
                             from pay_assignment_actions assact,
                             pay_payroll_actions pact
            where   assact.assignment_action_id = p_assignment_action_id
                    and     pact.payroll_action_id =
assact.payroll_action_id
;
cursor get_run is
-- for prepayment action find the latest interlocked run
               select assact.assignment_action_id
                             from pay_assignment_actions assact,
                                  pay_action_interlocks loc
                      where loc.locking_action_id = p_assignment_action_id
                      and   assact.assignment_action_id = loc.locked_action_id
                      order by assact.action_sequence desc ;

cursor get_prepay is
-- for run action check if its been prepaid
               select assact.assignment_action_id
                             from pay_assignment_actions assact,
                                  pay_payroll_actions pact,
                                  pay_action_interlocks loc
                      where loc.locked_action_id = p_assignment_action_id
                      and   assact.assignment_action_id = loc.locking_action_id
                      and   pact.payroll_action_id = assact.payroll_action_id
                      and   pact.action_type in ('P','U','C') -- Bug No : 2177800
		      -- prepayments only
                      order by assact.action_sequence desc
;
cursor get_run_details is
-- now find the date earned and payroll action of the run action
               select pact.payroll_id,
                      pact.payroll_action_id,
                      pact.date_earned,
                      pact.time_period_id,
                      ptp.period_name,
                      nvl(pact.pay_advice_date,ptp.pay_advice_date),
                      pay_advice_message
                 from pay_assignment_actions assact,
                      pay_payroll_actions pact,
                      per_time_periods ptp
                where   assact.assignment_action_id = p_run_assignment_action_id
                   and     pact.payroll_action_id = assact.payroll_action_id
                   and    pact.time_period_id = ptp.time_period_id ;
--
-- Bug 2595888: changed the datatype from varchar2(1) to pay_payroll_actions.action_type%type
l_action_type pay_payroll_actions.action_type%type;
--
begin
--
  open get_action_type;
  fetch get_action_type into l_action_type, p_assignment_id;
  close get_action_type;
--
  if l_action_type in ('P', 'U','C') then   -- Bug No : 2177800
     open get_run;
     fetch get_run into p_run_assignment_action_id;
     close get_run;
     -- if its a run action it may or may not have been prepaid
  else
     p_run_assignment_action_id := p_assignment_action_id;
     begin
          open get_prepay;
          fetch get_prepay into p_assignment_action_id;
		  if get_prepay%NOTFOUND then
			p_assignment_action_id := p_run_assignment_action_id;
		  end if;
          close get_prepay;
     end;
  end if;
-- fetch payroll details
  open get_run_details;
  fetch get_run_details into p_payroll_id,
                             p_payroll_action_id,
                             p_date_earned,
                             p_time_period_id,
                             p_period_name,
                             p_pay_advice_date,
                             p_pay_advice_message;
  close get_run_details;
end get_details;

procedure final_balance_totals
    (p_assignment_id               in per_all_assignments_f.assignment_id%type,
     p_assignment_action_id        in pay_assignment_actions.assignment_action_id%type,
     p_effective_date              in date,
     p_gross_this_pay              out nocopy number,
     p_other_deductions_this_pay   out nocopy number,
     p_tax_deductions_this_pay     out nocopy number,
     p_gross_ytd                   out nocopy number,
     p_other_deductions_ytd        out nocopy number,
     p_tax_deductions_ytd          out nocopy number,
     p_non_tax_allow_this_pay      out nocopy number,
     p_non_tax_allow_ytd           out nocopy number,
     p_pre_tax_deductions_this_pay out nocopy number,
     p_pre_tax_deductions_ytd      out nocopy number)
  is

  cursor run_ids is
  select LOCKED_ACTION_ID
  from pay_action_interlocks
  where LOCKING_ACTION_ID = p_assignment_action_id
  order by locked_action_id asc;
    pre_pay number;
    cur_run_id number;
    l_ASSIGNMENT_ID number ;
    l_RUN_ASSIGNMENT_ACTION_ID number ;
    l_DATE_EARNED date ;
    l_GROSS_INCOME_TP number;
    l_DED_TP number;
    l_TAX_DED_TP number;
    l_GROSS_INCOME_YTD number;
    l_DED_YTD number;
    l_TAX_DED_YTD number;
    l_NON_TAX_TP number;
    l_NON_TAX_YTD number;
    l_PRE_TAX_DED_TP number;
    l_PRE_TAX_DED_YTD number;
begin
pre_pay := 1;
open run_ids;
    loop
    fetch run_ids into cur_run_id;
     exit when run_ids%NOTFOUND;
        l_RUN_ASSIGNMENT_ACTION_ID := cur_run_id;
        pre_pay:= 0;
     pay_nz_soe_pkg.balance_totals(
    p_assignment_id              ,
    l_RUN_ASSIGNMENT_ACTION_ID   ,
    p_effective_date             ,
    l_GROSS_INCOME_TP,
    l_DED_TP,
    l_TAX_DED_TP,
    l_GROSS_INCOME_YTD,
    l_DED_YTD,
    l_TAX_DED_YTD,
    l_NON_TAX_TP,
    l_NON_TAX_YTD,
    l_PRE_TAX_DED_TP,
    l_PRE_TAX_DED_YTD);

    p_gross_this_pay             := NVL(p_gross_this_pay,0) + l_GROSS_INCOME_TP;
    p_other_deductions_this_pay  := NVL(p_other_deductions_this_pay,0) + l_DED_TP;
    p_tax_deductions_this_pay    := NVL(p_tax_deductions_this_pay,0) + l_TAX_DED_TP;
    p_non_tax_allow_this_pay     := NVL(p_non_tax_allow_this_pay,0) + l_NON_TAX_TP;
    p_pre_tax_deductions_this_pay := NVL(p_pre_tax_deductions_this_pay,0) +
                                         l_PRE_TAX_DED_TP;
    end loop;
        p_gross_ytd                  := l_GROSS_INCOME_YTD;
        p_other_deductions_ytd       := l_DED_YTD;
        p_tax_deductions_ytd         := l_TAX_DED_YTD;
        p_non_tax_allow_ytd          := l_NON_TAX_YTD;
        p_pre_tax_deductions_ytd     := l_PRE_TAX_DED_YTD;
    close run_ids;
      if Pre_pay <> 0 then
        pay_nz_soe_pkg.balance_totals(
        p_assignment_id              ,
        p_assignment_action_id       ,
        p_effective_date             ,
        p_gross_this_pay             ,
        p_other_deductions_this_pay  ,
        p_tax_deductions_this_pay    ,
        p_gross_ytd                  ,
        p_other_deductions_ytd       ,
        p_tax_deductions_ytd         ,
        p_non_tax_allow_this_pay     ,
        p_non_tax_allow_ytd          ,
        p_pre_tax_deductions_this_pay ,
        p_pre_tax_deductions_ytd      );
      end if;
    end final_balance_totals;

END pay_nz_soe_pkg ;

/
