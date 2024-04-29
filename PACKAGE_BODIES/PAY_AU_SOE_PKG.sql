--------------------------------------------------------
--  DDL for Package Body PAY_AU_SOE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_SOE_PKG" as
/* $Header: pyausoe.pkb 120.17.12010000.3 2009/12/22 14:45:46 pmatamsr ship $ */


/* changes start here */
g_debug boolean;
p_balance_value_tab_run pay_balance_pkg.t_balance_value_tab;
p_balance_value_tab_ytd pay_balance_pkg.t_balance_value_tab;
p_balance_value_tab_le_ytd pay_balance_pkg.t_balance_value_tab;  /* Bug 4169557 */
p_context_table_run         pay_balance_pkg.t_context_tab;
p_result_table_run          pay_balance_pkg.t_detailed_bal_out_tab;



  ------------------------------------------------------------------------
  -- Selects the Home Address for the Person.
  ------------------------------------------------------------------------
  procedure get_home_address
    (p_person_id      in  per_addresses.person_id%type,
     p_address_line1  out NOCOPY per_addresses.address_line1%type,
     p_address_line2  out NOCOPY per_addresses.address_line2%type,
     p_address_line3  out NOCOPY per_addresses.address_line3%type,
     p_town_city      out NOCOPY per_addresses.town_or_city%type,
     p_postal_code    out NOCOPY per_addresses.postal_code%type,
     p_country_name   out NOCOPY fnd_territories_tl.territory_short_name%type) is

    cursor home_address
      (c_person_id  per_addresses.person_id%type) is
    select pad.address_line1,
           pad.address_line2,
           pad.address_line3,
           pad.town_or_city,
           pad.postal_code,
           ftt.territory_short_name
    from   per_addresses pad,
           fnd_territories_tl ftt
    where  pad.person_id      = c_person_id
    and    ftt.language       = userenv('LANG')
    and    ftt.territory_code = pad.country
    and    sysdate between nvl(pad.date_from, sysdate) and nvl(pad.date_to, sysdate);

  begin
    open home_address(p_person_id);
    fetch home_address into p_address_line1,
                            p_address_line2,
                            p_address_line3,
                            p_town_city,
                            p_postal_code,
                            p_country_name;
    close home_address;
  end;

  ------------------------------------------------------------------------
  -- Selects the Work Address for the Person.
  ------------------------------------------------------------------------
  procedure get_work_address
    (p_location_id    in  hr_locations.location_id%type,
     p_address_line1  out NOCOPY hr_locations.address_line_1%type,
     p_address_line2  out NOCOPY hr_locations.address_line_2%type,
     p_address_line3  out NOCOPY hr_locations.address_line_3%type,
     p_town_city      out NOCOPY hr_locations.town_or_city%type,
     p_postal_code    out NOCOPY hr_locations.postal_code%type,
     p_country_name   out NOCOPY fnd_territories_tl.territory_short_name%type) is

    cursor c_get_work_address
      (c_location_id  hr_locations.location_id%type) is
    select hrl.address_line_1,
           hrl.address_line_2,
           hrl.address_line_3,
           hrl.town_or_city,
           hrl.postal_code,
           ftt.territory_short_name
    from   hr_locations hrl,
           fnd_territories_tl ftt
    where  hrl.location_id    = c_location_id
    and    ftt.language       = userenv('LANG')
    and    ftt.territory_code = hrl.country;

 begin
    open  c_get_work_address(p_location_id);
    fetch c_get_work_address into p_address_line1,
                                  p_address_line2,
                                  p_address_line3,
                                  p_town_city,
                                  p_postal_code,
                                  p_country_name;
    close c_get_work_address;
 end;

  ------------------------------------------------------------------------
  -- Selects the Salary for the Person.
  --
  -- clone of hr_general.get_salary but fetch At a given date
  -- This cursor gets the screen_entry_value from pay_element_entry_values_f.
  -- This is the salary amount obtained when the pay basis isn't null.
  -- The pay basis and assignment_id are passed in by the view.
  -- A check is made on the effective date of pay_element_entry_values_f
  -- and pay_element_entries_f as they're datetracked.
  ------------------------------------------------------------------------
  function get_salary
    (p_pay_basis_id    in per_pay_bases.pay_basis_id%type,
     p_assignment_id   in pay_element_entries_f.assignment_id%type,
     p_effective_date  in date)
  return varchar2 is

    cursor salary
      (c_pay_basis_id    per_pay_bases.pay_basis_id%type,
       c_assignment_id   pay_element_entries_f.assignment_id%type,
       c_effective_date  date) is
    select pev.screen_entry_value
    from   per_pay_bases ppb,
           pay_element_entries_f pee,
           pay_element_entry_values_f pev
    where  pee.assignment_id    = c_assignment_id
    and    ppb.pay_basis_id     = c_pay_basis_id
    and    pee.element_entry_id = pev.element_entry_id
    and    ppb.input_value_id   = pev.input_value_id
    and    c_effective_date between pev.effective_start_date
                                and pev.effective_end_date
    and    c_effective_date between pee.effective_start_date
                                and pee.effective_end_date;

    v_salary  pay_element_entry_values_f.screen_entry_value%type := null;
  begin

    -- Only open the cursor if the parameter may retrieve anything
    -- In practice, p_assignment_id is always going to be non null;
    -- p_pay_basis_id may be null, though. If it is, don't bother trying
    -- to fetch a salary.
    -- If we do have a pay basis, try and get a salary. There may not be one,
    -- in which case no problem: just return null.

    if p_pay_basis_id is not null and p_assignment_id is not null then
      open salary (p_pay_basis_id,
                   p_assignment_id,
                   p_effective_date) ;
      fetch salary into v_salary;
      close salary;
    end if;

    return v_salary;
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
 -- Sums the Balances for This Pay and YTD, according to the parameters.
  ------------------------------------------------------------------------
/* --------------------------------------------------------------------------
Bug 4169557
Procedure : populate_defined_balances
This procedure populates 2 PL/SQL table with Defined Balance ID's of
10 Balances for LE Dimensions _ASG_LE_RUN and _ASG_LE_YTD
--------------------------------------------------------------------------
*/

procedure populate_defined_balances
  is
  CURSOR   c_get_defined_balance_id
(c_dimension_name        pay_balance_dimensions.dimension_name%type)
IS
SELECT   decode(pbt.balance_name, 'Earnings_Total',1
                                , 'Direct Payments',2
                                , 'Termination_Payments',3
                                , 'Involuntary Deductions',4
                                , 'Pre Tax Deductions',5
                                , 'Termination Deductions',6
                                , 'Voluntary Deductions',7
                                , 'Employer Superannuation Contribution',8
                                , 'Earnings_Non_Taxable',9
                                , 'Total_Tax_Deductions',10) sort_index,
         pdb.defined_balance_id defined_balance_id
  FROM   pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
 WHERE   pbt.balance_name  IN   ('Earnings_Total'
                                , 'Direct Payments'
                                , 'Termination_Payments'
                                , 'Involuntary Deductions'
                                , 'Pre Tax Deductions'
                                , 'Termination Deductions'
                                , 'Voluntary Deductions'
                                , 'Employer Superannuation Contribution'
                                , 'Earnings_Non_Taxable'
                                , 'Total_Tax_Deductions')

   AND   pbd.dimension_name = c_dimension_name
   AND   pbt.balance_type_id      = pdb.balance_type_id
   AND   pbd.balance_dimension_id = pdb.balance_dimension_id
   AND   pbt.legislation_code     = 'AU'
 ORDER BY sort_index;
  begin

/* populate a table for defined balance ids of LE run balances
   p_balance_value_tab_run */

  FOR csr_rec IN c_get_defined_balance_id('_ASG_LE_RUN')
  LOOP
       p_balance_value_tab_run(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id;

  END LOOP;

/* populate a table for defined balance ids of LE YTD balances
   p_balance_value_tab_le_ytd */

  FOR csr_rec IN c_get_defined_balance_id('_ASG_LE_YTD')
  LOOP
       p_balance_value_tab_le_ytd(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id;

  END LOOP;

end populate_defined_balances;

 ------------------------------------------------------------------------
  -- Procedure to merely pass all the balance results back in one hit,
  -- rather than 6 separate calls.
  ------------------------------------------------------------------------
  procedure balance_totals
    (p_assignment_id               in per_all_assignments_f.assignment_id%type,
     p_assignment_action_id        in pay_assignment_actions.assignment_action_id%type,
     p_effective_date              in date,
     p_gross_this_pay             out NOCOPY number,
     p_other_deductions_this_pay  out NOCOPY number,
     p_tax_deductions_this_pay    out NOCOPY number,
     p_gross_ytd                  out NOCOPY number,
     p_other_deductions_ytd       out NOCOPY number,
     p_tax_deductions_ytd         out NOCOPY number,
     p_non_tax_allowances_run     out NOCOPY number,
     p_non_tax_allowances_ytd     out NOCOPY number,
     p_pre_tax_deductions_run     out NOCOPY number,
     p_pre_tax_deductions_ytd     out NOCOPY number,
     p_super_run                  out NOCOPY number,
     p_super_ytd                  out NOCOPY number,
     p_taxable_income_this_pay    out NOCOPY number,
     p_taxable_income_ytd         out NOCOPY number,
     p_direct_payments_run        out NOCOPY number,
     p_direct_payments_ytd        out NOCOPY number,
     p_get_le_level_bal            in varchar2,                 --3935483
     p_fetch_only_ytd_value               in varchar2)                 --3935483

/* bug 3935483 2 new parameters introduced  p_get_le_level_bal  when  Y the le level balances,run and ytd, would be fetched
    p_fetch_only_ytd_value when  Y  ytd balances would be fetched and run balances would not be fetched*/

  is


  /* Bug 2610141 */
        CURSOR tax_unit_id IS
        SELECT tax_unit_id
        from pay_assignment_actions paa
        where paa.assignment_action_id = p_assignment_action_id;

/*Bug 3935483 Changes for BBR start here */

/* cursor to get the defined balance ids for the various balances */

CURSOR   c_get_defined_balance_id
(c_dimension_name        pay_balance_dimensions.dimension_name%type)
IS
SELECT   decode(pbt.balance_name, 'Earnings_Total',1
                                , 'Direct Payments',2
                                , 'Termination_Payments',3
                                , 'Involuntary Deductions',4
                                , 'Pre Tax Deductions',5
                                , 'Termination Deductions',6
                                , 'Voluntary Deductions',7
                                , 'Employer Superannuation Contribution',8
                                , 'Earnings_Non_Taxable',9
                                , 'Total_Tax_Deductions',10) sort_index,
         pdb.defined_balance_id defined_balance_id
  FROM   pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
 WHERE   pbt.balance_name  IN   ('Earnings_Total'
                                , 'Direct Payments'
                                , 'Termination_Payments'
                                , 'Involuntary Deductions'
                                , 'Pre Tax Deductions'
                                , 'Termination Deductions'
                                , 'Voluntary Deductions'
                                , 'Employer Superannuation Contribution'
                                , 'Earnings_Non_Taxable'
                                , 'Total_Tax_Deductions')

   AND   pbd.dimension_name = c_dimension_name
   AND   pbt.balance_type_id      = pdb.balance_type_id
   AND   pbd.balance_dimension_id = pdb.balance_dimension_id
   AND   pbt.legislation_code     = 'AU'
ORDER BY sort_index;


    v_tax_unit_id                 number;
    v_earnings_run                number;
    v_earnings_ytd                number;
    v_direct_payments_run         number;
    v_direct_payments_ytd         number;
    v_involuntary_deductions_run  number;
    v_involuntary_deductions_ytd  number;
    v_pre_tax_deductions_run      number;
    v_pre_tax_deductions_ytd      number;
    v_voluntary_deductions_run    number;
    v_voluntary_deductions_ytd    number;
    v_tax_deductions_run          number;
    v_tax_deductions_ytd          number;
    v_termination_payments_run    number;
    v_termination_payments_ytd    number;
    v_termination_deductions_run  number;
    v_termination_deductions_ytd  number;
    v_super_run                   number;
    v_super_ytd                   number;
    v_non_tax_allow_run           number;
    v_non_tax_allow_ytd           number;


    l_bal_dimen_ytd pay_balance_dimensions.dimension_name%type ;   --3935483
    l_bal_dimen_run pay_balance_dimensions.dimension_name%type ;   --3935483



  begin


  /*Bug 2610141 */


     /*Fetch the value of v_tax_unit_id if  the flag is Y else assign it null Bug 3935483*/

  if p_get_le_level_bal='Y' then
    open tax_unit_id;
    fetch tax_unit_id into v_tax_unit_id;
    close tax_unit_id;
 else
    v_tax_unit_id:=NULL;
  end if;

/* The  ytd balance dimension would be set according to the flag to get the value of balances*/

if (p_get_le_level_bal ='Y')then
      l_bal_dimen_ytd :='_ASG_LE_YTD';
else
      l_bal_dimen_ytd :='_ASG_YTD';

end if;

    p_context_table_run(1).tax_unit_id:=v_tax_unit_id;

  /*---------------for run values-------------------- */


/* if the flag p_fetch_only_ytd_value is Y then only the YTD balances would be fetched and the run balances would be set to null
   else the LE level run balances would be fetched This is done to ensure that
     the run balances are not fetched twice for le level and ytd balances in the SOE form */

 if p_fetch_only_ytd_value = 'Y' then

 p_gross_this_pay           := null;
 p_non_tax_allowances_run         := null;
 p_direct_payments_run          := null;
 p_taxable_income_this_pay         := null;
 p_other_deductions_this_pay        := null;
 p_tax_deductions_this_pay         := null;
 p_pre_tax_deductions_run          := null;
 p_super_run                      := null;

else

/* populate a table for defined balance ids of LE run balances  */
/* Bug 4169557 - Removed calls to populate _ASG_LE_RUN Defined balances
*/

/* get the balances using BBR */

  pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id,
                               p_defined_balance_lst=>p_balance_value_tab_run,
                               p_context_lst =>p_context_table_run,
                               p_output_table=>p_result_table_run);

/* assign the values of the balances to the variables and calculate other run balances */

v_earnings_run := p_result_table_run(1).balance_value;
v_direct_payments_run :=p_result_table_run(2).balance_value;
v_termination_payments_run := p_result_table_run(3).balance_value;
v_involuntary_deductions_run := p_result_table_run(4).balance_value;
v_pre_tax_deductions_run := p_result_table_run(5).balance_value;
v_termination_deductions_run := p_result_table_run(6).balance_value;
v_voluntary_deductions_run := p_result_table_run(7).balance_value;
v_super_run := p_result_table_run(8).balance_value;
v_non_tax_allow_run          := p_result_table_run(9).balance_value;
v_tax_deductions_run := p_result_table_run(10).balance_value;


 p_gross_this_pay           := v_earnings_run +
                                   v_termination_payments_run +
                                   v_pre_tax_deductions_run ;

 p_non_tax_allowances_run    := v_non_tax_allow_run;

 p_direct_payments_run    := v_direct_payments_run;

 p_taxable_income_this_pay   := p_gross_this_pay -
                                   v_non_tax_allow_run -
                                   v_pre_tax_deductions_run;

 p_other_deductions_this_pay :=  v_involuntary_deductions_run +
                                    v_voluntary_deductions_run;

 p_tax_deductions_this_pay   := v_tax_deductions_run      +
                                   v_termination_deductions_run;

 p_pre_tax_deductions_run    := v_pre_tax_deductions_run;

 p_super_run                 := v_super_run;



end if;

/*------------------------------------- for YTD values -----------------------*/

/* Bug 4169557 - Removed calls to populate defined balance ID's for _ASG_LE_YTD
   IF Dimension Level = LE (ASG_LE_YTD)
       fetch balance values
   else (_ASG_YTD)
       populate defined balance ID's for YTD
       fetch balance values
   END IF
*/
  IF ( p_get_le_level_bal ='Y')
  THEN
  pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id,
                               p_defined_balance_lst=> p_balance_value_tab_le_ytd,
                               p_context_lst =>p_context_table_run,
                               p_output_table=>p_result_table_run);

  ELSE
   p_balance_value_tab_ytd.delete;

     FOR csr_rec IN c_get_defined_balance_id(l_bal_dimen_ytd)
     LOOP
        p_balance_value_tab_ytd(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id;
     END LOOP;

  /* fetch the ytd balances */
  pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id,
                               p_defined_balance_lst=>p_balance_value_tab_ytd,
                               p_context_lst =>p_context_table_run,
                               p_output_table=>p_result_table_run);

  END IF;

v_earnings_ytd :=p_result_table_run(1).balance_value;
v_direct_payments_ytd := p_result_table_run(2).balance_value;
v_termination_payments_ytd := p_result_table_run(3).balance_value;
v_involuntary_deductions_ytd := p_result_table_run(4).balance_value;
v_pre_tax_deductions_ytd := p_result_table_run(5).balance_value;
v_termination_deductions_ytd := p_result_table_run(6).balance_value;
v_voluntary_deductions_ytd := p_result_table_run(7).balance_value;
v_super_ytd := p_result_table_run(8).balance_value;
v_non_tax_allow_ytd   := p_result_table_run(9).balance_value;
v_tax_deductions_ytd := p_result_table_run(10).balance_value;



/* Bug 3953706 - Modfied the calculatioon of earnings and deductions
p_gross_this_pay = Earnings Total + Termination Payments + Pre Tax Deductions
p_non_tax_allowances_run = Non Taxable Earnings
p_direct_payments_run = Direct Payments
p_pre_tax_deductions_run = Pre Tax Deductions
p_taxable_income_this_pay = p_gross_this_pay - p_pre_tax_deductions_run - p_non_tax_allowances_run
p_super_run = Employer charges
p_other_deductions_this_pay = Involuntary Deductions + Voluntary Deductions
p_tax_deductions_this_pay = Tax deductions + Termination deductions*/



 -- Gross Earnings


    p_gross_ytd                 := v_earnings_ytd +
                                   v_termination_payments_ytd +
                                   v_pre_tax_deductions_ytd ;
-- Earnings Non Taxable

    p_non_tax_allowances_ytd    := v_non_tax_allow_ytd;

-- Direct Payments

    p_direct_payments_ytd    := v_direct_payments_ytd;

-- Taxable Gross

    p_taxable_income_ytd        := p_gross_ytd -
                                   p_non_tax_allowances_ytd -
                                   v_pre_tax_deductions_ytd;

-- Post Tax Deduction


    p_other_deductions_ytd :=  v_involuntary_deductions_ytd +
                                v_voluntary_deductions_ytd;

-- Tax Deductions

    p_tax_deductions_ytd   := v_tax_deductions_ytd  +
                              v_termination_deductions_ytd;

-- Pre Tax Deductions

    p_pre_tax_deductions_ytd    := v_pre_tax_deductions_ytd;

    p_super_ytd                 := v_super_ytd;


  end balance_totals;
  ------------------------------------------------------------------------

procedure get_asg_latest_pay(p_session_date in     date,
                 p_payroll_exists           in out NOCOPY varchar2,
                 p_assignment_action_id     in out NOCOPY number,
                 p_run_assignment_action_id in out NOCOPY number,
                 p_assignment_id            in     number,
                 p_payroll_id              out NOCOPY number,
                 p_payroll_action_id        in out NOCOPY number,
                 p_date_earned              in out NOCOPY varchar2,
                 p_time_period_id          out NOCOPY number,
                 p_period_name             out NOCOPY varchar2,
                 p_pay_advice_date         out NOCOPY date,
                 p_pay_advice_message      out NOCOPY varchar2)
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
          where  pa.action_type in ('U','P') /* Bug No : 2674887 */
          and    aa.action_status = 'C'
          and   pa.payroll_action_id = aa.payroll_action_id
          and aa.assignment_id = p_assignment_id
          and pa.effective_date <= p_session_date)
and    ppa.action_type in ('P', 'U') /* Bug No : 2674887 */
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
procedure get_details (p_assignment_action_id in out NOCOPY number,
                      p_run_assignment_action_id in out NOCOPY number,
                      p_assignment_id        in out NOCOPY number,
                      p_payroll_id              out NOCOPY number,
                      p_payroll_action_id    in out NOCOPY number,
                      p_date_earned          in out NOCOPY date,
                      p_time_period_id          out NOCOPY number,
                      p_period_name             out NOCOPY varchar2,
                      p_pay_advice_date         out NOCOPY date,
                      p_pay_advice_message      out NOCOPY varchar2) is

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
                      and   pact.action_type in ('P','U') -- Removed check for costing (2846119)
 /* prepayments
only */
                      order by assact.action_sequence desc
;
cursor get_run_details is
-- now find the date earned and payroll action of the run action
               select pact.payroll_id,
                      pact.payroll_action_id,
                      pact.date_earned,
                      ptp.time_period_id,
                      ptp.period_name,
                      nvl(pact.pay_advice_date,ptp.pay_advice_date),
                      pay_advice_message
                 from pay_assignment_actions assact,
                      pay_payroll_actions pact,
                      per_time_periods ptp
                where      assact.assignment_action_id = p_run_assignment_action_id
                   and     pact.payroll_action_id = assact.payroll_action_id
                   and     pact.payroll_id = ptp.payroll_id
                   and     pact.date_earned between ptp.start_date and ptp.end_date ;
--
-- Bug-2595888: Changed the variable type from varchar2(1)
l_action_type pay_payroll_actions.action_type%type;
--
begin
--
  open get_action_type;
  fetch get_action_type into l_action_type, p_assignment_id;
  close get_action_type;
--
  if l_action_type in ('P', 'U') then -- Removed check for costing(2846119)
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

/* bug 3935483 2 new parameters added in balance_totals and final_balance_totals ,  p_get_le_level_bal to fetch le level balances when it is Y and
                                       p_fetch_only_ytd_value to fetch only ytd balances and not run balances */

procedure final_balance_totals
    (p_assignment_id               in per_all_assignments_f.assignment_id%type,
     p_assignment_action_id        in pay_assignment_actions.assignment_action_id%type,
     p_effective_date              in date,
     p_gross_this_pay             out NOCOPY number,
     p_other_deductions_this_pay  out NOCOPY number,
     p_tax_deductions_this_pay    out NOCOPY number,
     p_gross_ytd                  out NOCOPY number,
     p_other_deductions_ytd       out NOCOPY number,
     p_tax_deductions_ytd         out NOCOPY number,
     p_non_tax_allow_this_pay     out NOCOPY number,
     p_non_tax_allow_ytd          out NOCOPY number,
     p_pre_tax_deductions_this_pay out NOCOPY number,
     p_pre_tax_deductions_ytd      out NOCOPY number,
     p_super_this_pay              out NOCOPY number,
     p_super_ytd                   out NOCOPY number,
     p_taxable_income_this_pay     out NOCOPY number,
     p_taxable_income_ytd          out NOCOPY number,
     p_direct_payments_this_pay    out NOCOPY number,
     p_direct_payments_ytd        out NOCOPY number,
     p_get_le_level_bal            in varchar2,
     p_fetch_only_ytd_value       in varchar2)
  is

  CURSOR run_ids IS
  SELECT pai.locked_action_id
  FROM   pay_assignment_actions paa,
         pay_action_interlocks pai
  WHERE  pai.LOCKING_ACTION_ID    = p_assignment_action_id
  AND    pai.locked_action_id = paa.assignment_action_id
  AND    paa.assignment_action_id not in (select bpaa.source_action_id
                                          from pay_assignment_actions bpaa
                                          where bpaa.source_action_id =pai.locked_action_id)
  ORDER BY locked_action_id ASC;

  /*SELECT locked_action_id Bug 3245909 To fetch Master locked action_id only */
/*  FROM   pay_assignment_actions paa,
         pay_action_interlocks pai
  WHERE  LOCKING_ACTION_ID    = p_assignment_action_id
  AND    pai.locked_action_id = paa.assignment_action_id
  AND    paa.source_action_id IS NULL
  ORDER BY locked_action_id ASC;*/

    pre_pay number := 1;
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
    l_super_TP  number;
    l_super_YTD number;
    l_TAXABLE_INCOME_TP number;
    l_TAXABLE_INCOME_YTD number;
    l_direct_payments_tp  number;
    l_direct_payments_ytd  number;

begin
open run_ids;
    loop
    fetch run_ids into cur_run_id;
     exit when run_ids%NOTFOUND;
        l_RUN_ASSIGNMENT_ACTION_ID := cur_run_id;
        pre_pay:= 0;
     pay_au_soe_pkg.balance_totals(
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
    l_PRE_TAX_DED_YTD,
    l_super_TP,
    l_super_YTD,
    l_TAXABLE_INCOME_TP,
    l_TAXABLE_INCOME_YTD,
    l_direct_payments_tp,
    l_direct_payments_ytd,
     p_get_le_level_bal,
     p_fetch_only_ytd_value);         /*3935483*/

    p_gross_this_pay             := NVL(p_gross_this_pay,0) + l_GROSS_INCOME_TP;
    p_other_deductions_this_pay  := NVL(p_other_deductions_this_pay,0) + l_DED_TP;
    p_tax_deductions_this_pay    := NVL(p_tax_deductions_this_pay,0) + l_TAX_DED_TP;
    p_non_tax_allow_this_pay     := NVL(p_non_tax_allow_this_pay,0) + l_NON_TAX_TP;
    p_pre_tax_deductions_this_pay := NVL(p_pre_tax_deductions_this_pay,0) +
                                         l_PRE_TAX_DED_TP;
    p_super_this_pay             := NVL(p_super_this_pay,0) + l_super_TP;
    p_taxable_income_this_pay    := NVL(p_taxable_income_this_pay,0) + l_TAXABLE_INCOME_TP; /* Bug 3953706 */
    p_direct_payments_this_pay    := NVL(p_direct_payments_this_pay,0) + l_direct_payments_tp; /* Bug 3953706 */
  end loop;
        p_gross_ytd                  := l_GROSS_INCOME_YTD;
        p_other_deductions_ytd       := l_DED_YTD;
        p_tax_deductions_ytd         := l_TAX_DED_YTD;
        p_non_tax_allow_ytd          := l_NON_TAX_YTD;
        p_pre_tax_deductions_ytd     := l_PRE_TAX_DED_YTD;
        p_super_ytd                  := l_super_ytd;
        p_taxable_income_ytd         := l_TAXABLE_INCOME_YTD; /* Bug 3953706 */
        p_direct_payments_ytd        := l_direct_payments_ytd;/* Bug 3953706 */

    close run_ids;
      if Pre_pay <> 0 then
        pay_au_soe_pkg.balance_totals(
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
        p_non_tax_allow_ytd         ,
        p_pre_tax_deductions_this_pay ,
        p_pre_tax_deductions_ytd     ,
        p_super_this_pay,
        p_super_ytd,
        p_taxable_income_this_pay,
        p_taxable_income_ytd,
        p_direct_payments_this_pay,
        p_direct_payments_ytd,
        p_get_le_level_bal,            --3935483
        p_fetch_only_ytd_value);       --3935483
      end if;
    end final_balance_totals;

/* Bug 5461557 - Added function super_fund_name to get superannnuation fund name
   This function will return Superannuation Fund Name.
   If Superannuation Fund Name is null,then element reporting name will be returned*/

function super_fund_name
    (p_source_id in  number,
     p_element_reporting_name in pay_element_types_f.reporting_name%type,
     p_date_earned in pay_payroll_actions.date_earned%type,
     p_assignment_action_id in pay_assignment_actions.assignment_action_id%type,
     p_assignment_id in per_all_assignments_f.assignment_id%type,
     p_element_entry_id in pay_element_entries_f.PERSONAL_PAYMENT_METHOD_ID%TYPE,
     p_business_group_id per_all_assignments_f.business_group_id%TYPE)
     return varchar2

 is

cursor c_get_super_fund_name (p_assignment_action_id number,p_date_earned date,p_source_id number)
is
select distinct prrv.result_value ,prr.element_entry_id
from
         pay_run_results prr,
         pay_run_result_values prrv,
         pay_input_values_f piv,
         pay_element_types_f pet,
         pay_element_classifications pec
where    prr.source_id= p_source_id
         and piv.input_value_id=prrv.input_value_id
         and piv.name like '%Fund%Name%'
         and pet.element_type_id=piv.element_type_id
         and pet.classification_id=pec.classification_id
         and pec.classification_name='Information'
         and prr.element_type_id=pet.element_type_id
         and prrv.result_value is not null
         and prr.run_result_id=prrv.run_result_id
         and prr.assignment_action_id=p_assignment_action_id
         and p_date_earned between pet.effective_start_date and pet.effective_end_date
         and p_date_earned between piv.effective_start_date and piv.effective_end_date
        AND  (pec.legislation_code is null or pec.legislation_code = 'AU');


/*for bug 5983711  for advance entries */
cursor c_get_ae_super_fund_name (p_assignment_action_id number,p_date_earned date,p_source_id number)
is
select distinct prrv.result_value ,prr.element_entry_id
from
         pay_run_results prr,
         pay_run_result_values prrv,
         pay_input_values_f piv,
         pay_element_types_f pet,
         pay_element_classifications pec,
         pay_element_entries_f pee,
         pay_element_entries_f pee1
where    pee.element_entry_id=p_source_id
         and  pee.source_id=pee1.element_entry_id
         and   prr.element_entry_id=pee1.element_entry_id
         and piv.input_value_id=prrv.input_value_id
         and piv.name like '%Fund%Name%'
         and pet.element_type_id=piv.element_type_id
         and pet.classification_id=pec.classification_id
         and pec.classification_name='Information'
         and prr.element_type_id=pet.element_type_id
         and prrv.result_value is not null
         and prr.run_result_id=prrv.run_result_id
         and prr.assignment_action_id=p_assignment_action_id
         and p_date_earned between pet.effective_start_date and pet.effective_end_date
         and p_date_earned between piv.effective_start_date and piv.effective_end_date
         and p_date_earned between pee.effective_start_date and pee.effective_end_date
         and p_date_earned between pee1.effective_start_date and pee1.effective_end_date
        AND  (pec.legislation_code is null or pec.legislation_code = 'AU');


/* for bug 5983711 for retro entries */
cursor c_get_rr_super_fund_name(p_assignment_action_id number,p_date_earned date,p_source_id number)
is
select distinct prrv.result_value ,prr.element_entry_id
from pay_element_entries_f pee,
     pay_element_entries_f pee1,
     pay_run_results prr,
     pay_run_results prr1,
     pay_run_result_values prrv,
     pay_input_values_f piv,
     pay_element_types_f pet,
     pay_element_classifications pec
where pee.element_entry_id=p_source_id
and   pee.source_id =prr.run_result_id
and   prr.source_id= pee1.element_entry_id
and  prr1.element_entry_id=pee1.element_entry_id
and piv.input_value_id=prrv.input_value_id
and piv.name like '%Fund%Name%'
and pet.element_type_id=piv.element_type_id
and pet.classification_id=pec.classification_id
and pec.classification_name='Information'
and prr1.element_type_id=pet.element_type_id
and prrv.result_value is not null
and prr1.run_result_id=prrv.run_result_id
and prr1.assignment_action_id=p_assignment_action_id
and p_date_earned between pet.effective_start_date and pet.effective_end_date
and p_date_earned between piv.effective_start_date and piv.effective_end_date
and p_date_earned between pee.effective_start_date and pee.effective_end_date
and p_date_earned between pee1.effective_start_date and pee1.effective_end_date
AND  (pec.legislation_code is null or pec.legislation_code = 'AU');

        cursor c_get_third_party_payment_id(p_element_entry_id number,p_assignment_id number,p_date_earned date)
        is
        select PERSONAL_PAYMENT_METHOD_ID
        from  pay_element_entries_f pee
        where element_entry_id=p_element_entry_id
        and assignment_id=p_assignment_id
        and p_date_earned between pee.effective_start_date and pee.effective_end_date;



cursor c_get_third_party_fund_name(p_third_party_id number,p_date_earned date,p_assignment_id number
                                        ,p_business_group_id number)
        is
select  hoi.org_information2
from
        hr_organization_information hoi,
        hr_organization_units hou,
        pay_personal_payment_methods_f pppm
where
        hoi.org_information_context='AU_SUPER_FUND'
        and hoi.organization_id=hou.organization_id
        and pppm.payee_id=hoi.organization_id
        and p_date_earned between pppm.effective_start_date and last_day(pppm.effective_end_date)
      and (p_date_earned between to_date(hoi.org_information9,'yyyy/mm/dd hh24:mi:ss') and
                                    nvl(to_date(hoi.org_information10,'yyyy/mm/dd hh24:mi:ss'),
                                to_date('4712/12/31 00:00:00','yyyy/mm/dd hh24:mi:ss')))
        and hou.business_group_id=p_business_group_id
        and pppm.assignment_id=p_assignment_id
        and pppm.personal_payment_method_id=p_third_party_id
        order by 1 ;

/* for bug 5983711 */
cursor c_get_creator_type(p_source_id number)
is
select creator_type
from pay_element_entries_f
where element_entry_id=p_source_id;

l_fund_name varchar2(100);
l_element_entry_id number ;
l_payee_id number;
l_third_party_id number;
l_creator_type varchar2(20);

begin

 if g_debug then
                hr_utility.trace('Entering Function super_fund_name');
                hr_utility.trace('Value of p_source_id is '||p_source_id);
                hr_utility.trace('Value of p_element_reporting_name is '||p_element_reporting_name);
                hr_utility.trace('Value of p_date_earned is '||p_date_earned);
                hr_utility.trace('Value of p_assignment_action_id is '||p_assignment_action_id);
                hr_utility.trace('Value of p_assignment_id is '||p_assignment_id);
                hr_utility.trace('Value of p_element_entry_id is '||p_element_entry_id);
  end if;

/* Get value of payee id attached to the element */


            open c_get_third_party_payment_id(p_element_entry_id,p_assignment_id,p_date_earned);
            fetch c_get_third_party_payment_id into l_payee_id;
            close c_get_third_party_payment_id ;

 if g_debug then
            hr_utility.trace(' l_payee_id is  is  '||l_payee_id);
end if;

/* Get value of Superannuation Fund from Payee Organization Super Fund for the element
   This may either be the Seeded Superannuation Element or Employer Charge Element with
   third party Payments */

            if l_payee_id is not null  then

                      open c_get_third_party_fund_name(l_payee_id,p_date_earned,p_assignment_id,p_business_group_id);
                      fetch c_get_third_party_fund_name into l_fund_name ;
                      close c_get_third_party_fund_name ;

              if g_debug then
                      hr_utility.trace('Fund Name is '||l_fund_name);
              end if;

             end if;

             if l_fund_name is null then

    /* Get value of Superannuation Fund from Superannuation Information Element Attached to
       the employee */
                         /* Bug 5983711 for Retro entries call c_get_rr_super_fund_name else c_get_super_fund_name */
                       open c_get_creator_type(p_source_id);
                       fetch c_get_creator_type into l_creator_type ;
                       close c_get_creator_type;

                       If l_creator_type='RR' then
                          open c_get_rr_super_fund_name(p_assignment_action_id,p_date_earned,p_source_id);
                          fetch c_get_rr_super_fund_name into l_fund_name,l_element_entry_id;
                          close c_get_rr_super_fund_name;

                       elsif l_creator_type in ('AE','EE','AD') then

                          open c_get_ae_super_fund_name(p_assignment_action_id,p_date_earned,p_source_id);
                          fetch c_get_ae_super_fund_name into l_fund_name,l_element_entry_id;
                          close c_get_ae_super_fund_name;

                       else

                          open c_get_super_fund_name(p_assignment_action_id,p_date_earned,p_source_id);
                          fetch c_get_super_fund_name into l_fund_name,l_element_entry_id;
                          close c_get_super_fund_name;
                       end if;
                if g_debug then
                           hr_utility.trace('Fund Name is '||l_fund_name);
                end if;

                     if l_element_entry_id is not null then

                             open c_get_third_party_payment_id(l_element_entry_id,p_assignment_id,p_date_earned);
                            fetch c_get_third_party_payment_id into l_payee_id;
                            close c_get_third_party_payment_id ;

                if g_debug then
                            hr_utility.trace(' l_payee_id is  is  '||l_payee_id);
                end if;

/* Get value of Superannuation Fund from Payee Organization Super Fund
   for the Superannuation Information Element */

                             if l_payee_id is not null  then

                                      open c_get_third_party_fund_name(l_payee_id,p_date_earned,p_assignment_id,p_business_group_id);
                                      fetch c_get_third_party_fund_name into l_fund_name ;
                                      close c_get_third_party_fund_name ;

                                if g_debug then
                                      hr_utility.trace('Fund Name is '||l_fund_name);
                                end if;

                              end if;

                        end if;

                  end if;
/* Return element reporting name if superannuation Fund is not attached */

        if l_fund_name is null then

                 l_fund_name := p_element_reporting_name ;

        end if;
                if g_debug then
                        hr_utility.trace('Fund Name RETURNED is '||l_fund_name);
                end if;

        return l_fund_name;

end super_fund_name;


/* Bug 5591333 - Function is used to compute Hours for Elements.
    Function    : get_element_payment_hours
    Description : This function is to be used for getting the Hours component paid in run.
                  If Element is a salary basis element, hours will be fetched from
                  "Normal Hours" seeded element.
    Inputs      : p_assignment_action_id - Assignment Action ID
                  p_element_type_id      - Element Type ID
                  p_pay_bases_id         - Pay Basis ID
                  p_run_result_id        - Run Result ID
                  p_effective_date       - Effective Date of Run
*/

FUNCTION get_element_payment_hours
(
   p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE,
   p_element_type_id IN pay_element_entries_f.element_entry_id%TYPE,
   p_pay_bases_id    IN per_all_assignments_f.pay_basis_id%TYPE,
   p_run_result_id   IN pay_run_results.run_result_ID%TYPE,
   p_effective_date  IN pay_payroll_actions.effective_date%TYPE
)
RETURN NUMBER
IS

    l_element_type_id  pay_element_types_f.element_type_id%TYPE;
    l_input_value_id   pay_input_values_f.input_value_id%TYPE;

    l_result NUMBER := NULL;
    l_temp   NUMBER := NULL;

    CURSOR Cr_value IS (
        SELECT prv.result_value
        from   pay_run_results prr,
               pay_run_result_values prv,
               pay_element_types_f pet,
               pay_input_values_f piv
        where prr.assignment_action_id = p_assignment_action_id
        and   prv.run_result_id = prr.run_result_id
        and   prv.input_value_id = piv.input_value_id
        and   prr.element_type_id = pet.element_type_id
        and   piv.uom like 'H_%'
        and   piv.element_type_id= pet.element_type_id
        and   pet.element_name= 'Normal Hours');

    CURSOR Cr_element_type_id IS (
        SELECT pivf.element_type_id
        FROM   pay_input_values_f pivf, per_pay_bases ppb
        WHERE  pivf.input_value_id = ppb.input_value_id
        AND    ppb.pay_basis_id = p_pay_bases_id);

/* Bug 5967108 - Added Check for Input with Name - Hours */
    CURSOR get_hours_input_value
    (c_element_type_id pay_element_types_f.element_type_id%TYPE
    ,c_effective_date  date)
     IS
        SELECT pivf.input_value_id
              ,pivf.name
              ,decode(pivf.name,'Hours',1,2) sort_index
        FROM   pay_input_values_f pivf
        WHERE  pivf.element_type_id = c_element_type_id
        AND    substr(pivf.uom,1,1) = 'H'
        AND    c_effective_date between pivf.effective_start_date and pivf.effective_end_date
        ORDER BY sort_index;

    CURSOR  get_hours_result_value
    (c_run_result_id  pay_run_result_values.run_result_id%TYPE
    ,c_input_value_id pay_run_result_values.input_value_id%TYPE)
    IS
        SELECT prrv.result_value
        FROM   pay_run_result_values prrv
        WHERE  prrv.run_result_id  = c_run_result_id
        AND    prrv.input_value_id = c_input_value_id;


BEGIN

    g_debug := hr_utility.debug_enabled;

    /* Bug 5967108 - Added Check for Multiple Hours Input
       If Input Name = "Hours", return run result for it
       else sum the run results for all "H_" UOM type.
    */
    FOR csr_rec IN get_hours_input_value(p_element_type_id,p_effective_date)
    LOOP
            OPEN get_hours_result_value(p_run_result_id,csr_rec.input_value_id);
            FETCH get_hours_result_value INTO l_temp;
            CLOSE get_hours_result_value;
            IF csr_rec.sort_index = 1
            THEN
                l_result := l_temp;
                EXIT;
            ELSE
                l_result := NVL(l_result,0) + NVL(l_temp,0);
            END IF;
    END LOOP;

    IF ( l_result IS NULL OR l_result = 0)
    THEN
        OPEN Cr_element_type_id;
        FETCH Cr_element_type_id INTO l_element_type_id;
        CLOSE Cr_element_type_id;

        IF p_element_type_id = l_element_type_id THEN
            OPEN Cr_value;
            FETCH Cr_value INTO l_result;
            CLOSE Cr_value;
        END IF;
    END IF;

    /* Avoid Divide by Zero Errors when used for computing Rate, Report Hours and Rate as Null */
    IF l_result = 0
    THEN
        l_result := NULL;
    END IF;

 RETURN l_result;
END get_element_payment_hours;


/* Bug 5599310 - Function is used to get Rate for Elements.
    Function    : get_element_payment_rate
    Description : This function is to be used for getting the rate if entered for an Earnings element.
    Inputs      : p_assignment_action_id - Assignment Action ID
                  p_element_type_id      - Element Type ID
                  p_run_result_id        - Run Result ID
                  p_effective_date       - Effective Date of Run
*/

FUNCTION get_element_payment_rate
(
   p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE,
   p_element_type_id IN pay_element_entries_f.element_entry_id%TYPE,
   p_run_result_id   IN pay_run_results.run_result_ID%TYPE,
   p_effective_date  IN pay_payroll_actions.effective_date%TYPE
)
RETURN NUMBER
IS

    l_element_type_id  pay_element_types_f.element_type_id%TYPE;
    l_input_value_id   pay_input_values_f.input_value_id%TYPE;

    l_result number := NULL;

  CURSOR get_rate_input_value
    (c_element_type_id pay_element_types_f.element_type_id%TYPE
    ,c_effective_date  date)
     IS
        SELECT pivf.input_value_id
        FROM   pay_input_values_f pivf
        WHERE  pivf.element_type_id = c_element_type_id
        AND    upper(pivf.name) like  'RATE%'
        AND    pivf.uom in ('N','M','I') /*bug 6109668 */
        AND    c_effective_date between pivf.effective_start_date and pivf.effective_end_date;

    CURSOR  get_rate_result_value
    (c_run_result_id  pay_run_result_values.run_result_id%TYPE
    ,c_input_value_id pay_run_result_values.input_value_id%TYPE)
    IS
    SELECT prrv.result_value
        FROM   pay_run_result_values prrv
        WHERE  prrv.run_result_id  = c_run_result_id
        AND    prrv.input_value_id = c_input_value_id;

BEGIN

    g_debug := hr_utility.debug_enabled;

 if g_debug then
                hr_utility.trace('Entering get_element_payment_rate');
 end if;

    OPEN get_rate_input_value(p_element_type_id,p_effective_date);
    FETCH get_rate_input_value INTO l_input_value_id;
    CLOSE get_rate_input_value;

    IF l_input_value_id IS NOT NULL
    THEN
        OPEN get_rate_result_value(p_run_result_id,l_input_value_id);
        FETCH get_rate_result_value INTO l_result;
        CLOSE get_rate_result_value;
    END IF;

  /* Avoid Divide by Zero Errors when used for computing Rate, Report Rate as Null */
    IF l_result = 0
    THEN
        l_result := NULL;
    END IF;

if g_debug then
                hr_utility.trace('l_result is ' || l_result);
 end if;

if g_debug then
                hr_utility.trace('Leaving get_element_payment_rate');
 end if;

 RETURN l_result;
END get_element_payment_rate;

/* Bug 5597052 - Function is used to compute Hours for Leave Taken.
    Function    : get_leave_taken_hours
    Description : This function is to be used for getting the Hours component paid in run.
    Inputs      : p_assignment_action_id - Assignment Action ID
                  p_element_type_id      - Element Type ID
                  p_pay_bases_id         - Pay Basis ID
                  p_run_result_id        - Run Result ID
                  p_effective_date       - Effective Date of Run
*/


FUNCTION get_leave_taken_hours
(
   p_element_type_id IN pay_element_entries_f.element_entry_id%TYPE,
   p_run_result_id   IN pay_run_results.run_result_ID%TYPE,
   p_effective_date  IN pay_payroll_actions.effective_date%TYPE
)
RETURN NUMBER
IS

    l_element_type_id  pay_element_types_f.element_type_id%TYPE;
    l_input_value_id   pay_input_values_f.input_value_id%TYPE;

    l_result number := NULL;

       CURSOR get_hours_input_value
    (c_element_type_id pay_element_types_f.element_type_id%TYPE
    ,c_effective_date  date)
     IS
        SELECT pivf.input_value_id
        FROM   pay_input_values_f pivf
        WHERE  pivf.element_type_id = c_element_type_id
        and   pivf.name IN ('Hours','Days')
        AND    c_effective_date between pivf.effective_start_date and pivf.effective_end_date;

    CURSOR  get_hours_result_value
    (c_run_result_id  pay_run_result_values.run_result_id%TYPE
    ,c_input_value_id pay_run_result_values.input_value_id%TYPE)
    IS
        SELECT prrv.result_value
        FROM   pay_run_result_values prrv
        WHERE  prrv.run_result_id  = c_run_result_id
        AND    prrv.input_value_id = c_input_value_id;

BEGIN

    g_debug := hr_utility.debug_enabled;

    OPEN get_hours_input_value(p_element_type_id,p_effective_date);
    FETCH get_hours_input_value INTO l_input_value_id;
    CLOSE get_hours_input_value;

    IF l_input_value_id IS NOT NULL
    THEN
        OPEN get_hours_result_value(p_run_result_id,l_input_value_id);
        FETCH get_hours_result_value INTO l_result;
        CLOSE get_hours_result_value;
    END IF;

    /* Avoid Divide by Zero Errors when used for computing Rate, Report Hours and Rate as Null */
    IF l_result = 0
    THEN
        l_result := NULL;
    END IF;

 RETURN l_result;
END get_leave_taken_hours;


/* Bug 5689508  - Function is used to get currency code.
    Function    : get_currency_code
    Description : This function checks for payroll's
                  default currency code and Business Group Default Currency Code
    Inputs      : p_business_group_id    - Business Group Id
                  p_payroll_id           - Payroll Id
*/
FUNCTION get_currency_code
    (p_business_group_id  in hr_organization_units.business_group_id%type,
     p_payroll_id      in pay_payrolls_f.payroll_id%type,
      p_effective_date    in date)
  return fnd_currencies.currency_code%type is

  lv_currency_code fnd_currencies.currency_code%type;

 Cursor payroll_currency_code(c_payroll_id pay_payrolls_f.payroll_id%type) is
select popm.currency_code
from pay_payrolls_f ppf,
     pay_org_payment_methods_f popm
where   ppf.default_payment_method_id  = popm.org_payment_method_id
and     ppf.payroll_id                 = c_payroll_id
and     p_effective_date between ppf.effective_start_date and ppf.effective_end_date
and     p_effective_date between popm.effective_start_date and popm.effective_end_date;

Cursor org_currency_code(c_business_group_id  hr_organization_units.business_group_id%type) is
select     hoi.org_information10
    from   hr_organization_information hoi,
           hr_organization_units hou
    where  hou.business_group_id       = c_business_group_id
    and    hou.organization_id         = hoi.organization_id
    and    hoi.org_information_context = 'Business Group Information';

Begin

      open payroll_currency_code(p_payroll_id);
      fetch payroll_currency_code into lv_currency_code;

       if payroll_currency_code%NOTFOUND then
         open org_currency_code(p_business_group_id);
         fetch org_currency_code into lv_currency_code;
         close org_currency_code;
       end if;
     close payroll_currency_code;

 return lv_currency_code;

End get_currency_code;

/* Bug 9221420 - Added function to retrieve payments effective date if exists
                 else fetch the pre-payments effective date.
  c_get_payments_eff_date - Cursor fetches the effective date of payments
  c_get_prepay_eff_date   - Cursor fetches effective date of pre-payments   */

FUNCTION get_effective_date
    (p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE)
RETURN pay_payroll_actions.effective_date%TYPE
IS

CURSOR c_get_payments_eff_date(c_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE)
IS
SELECT max(ppa.effective_date)
FROM   pay_payroll_actions ppa ,
       pay_assignment_actions paa ,
       pay_action_interlocks pai
WHERE  pai.locked_action_id = c_assignment_action_id
AND    pai.locking_action_id = paa.assignment_action_id
AND    paa.pre_payment_id is not null
AND    ppa.action_type IN ('H','E','M','A')
AND    ppa.payroll_action_id = paa.payroll_action_id;

CURSOR c_get_prepay_eff_date(c_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE)
is
SELECT ppa.effective_date
FROM   pay_payroll_actions ppa ,
       pay_assignment_actions paa
WHERE  paa.assignment_action_id = c_assignment_action_id
AND    ppa.payroll_action_id = paa.payroll_action_id;

l_effective_date pay_payroll_actions.effective_date%TYPE;

BEGIN

OPEN c_get_payments_eff_date(p_assignment_action_id);
FETCH c_get_payments_eff_date INTO l_effective_date ;

IF l_effective_date IS NULL THEN

  OPEN c_get_prepay_eff_date(p_assignment_action_id);
  FETCH c_get_prepay_eff_date INTO l_effective_date ;
  CLOSE c_get_prepay_eff_date;

END IF;

CLOSE c_get_payments_eff_date;

return l_effective_date ;

END get_effective_date;

end pay_au_soe_pkg;

/
