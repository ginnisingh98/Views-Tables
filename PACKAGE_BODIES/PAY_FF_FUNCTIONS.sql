--------------------------------------------------------
--  DDL for Package Body PAY_FF_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FF_FUNCTIONS" as
/* $Header: pyfffunc.pkb 120.12.12010000.2 2009/05/08 10:29:58 sudedas ship $ */
------------------------------------------------------------------------------+
------------------------------------------
-- Function to Get the 403B Limit
------------------------------------------
Function Get_PQP_Limit(
    p_effective_date    IN DATE   DEFAULT NULL,
    p_payroll_action_id IN number DEFAULT NULL,
    p_limit             IN varchar) Return number is

l_fed_information1 number;
l_fed_information2 number;
l_fed_information3 number;
l_fed_information4 number;
l_fed_information5 number;
l_fed_information6 number;
l_fed_information7 number;
l_fed_information8 number;
l_fed_information9 number;

Cursor Cur_403b_limit (p_date date) is
    Select
        fed_information1,
        fed_information2,
        fed_information3,
        fed_information4,
        fed_information5,
        fed_information6,
        fed_information7,
        fed_information8,
        fed_information9
    from
        pay_us_federal_tax_info_f
    where
      fed_information_category = '403B LIMITS'
      and  p_date  between effective_start_date and nvl(effective_end_date, p_date);


l_403b_limit       number;
l_limit_name       varchar2(100);
l_effective_date   date;
begin
 IF p_payroll_action_id IS NULL THEN
  l_effective_date:=p_effective_date;
 ELSE
  l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
 END IF;

    hr_utility.set_location('Start of GET_PQP_LIMIT', 5);

    open Cur_403b_limit (l_effective_date);

    fetch Cur_403b_limit into
        l_fed_information1,
        l_fed_information2,
        l_fed_information3,
        l_fed_information4,
        l_fed_information5,
        l_fed_information6,
        l_fed_information7,
        l_fed_information8,
        l_fed_information9;


   if Cur_403b_limit%notfound then
     close Cur_403b_limit;
      -- Error : No limits defined for 403b
     hr_utility.set_message(801, 'PAY_PQP_LIMITS_NOT_DEFINED');
     hr_utility.raise_error;
     return 0;
   end if;

   hr_utility.set_location('GET_PQP_LIMIT', 10);

    l_limit_name := upper(p_limit);

    l_403b_limit := 0;

    if  l_limit_name    = 'OVERALL_ER_LIMIT' then
        l_403b_limit   := l_fed_information1;
    elsif  l_limit_name = 'ANY_YEAR_LIMIT' then
        l_403b_limit   := l_fed_information2;
    elsif  l_limit_name = 'ELECTIVE_DEFERRAL_LIMIT' then
        l_403b_limit   := l_fed_information3;
    elsif  l_limit_name = 'INCLUDABLE_ANNUAL_COMP_LIMIT' then
        l_403b_limit   := l_fed_information4;
    elsif  l_limit_name = 'ELE_DEF_ADDITIONAL_CATCHUP' then
        l_403b_limit   := l_fed_information5;
    elsif  l_limit_name = 'ELECTIVE_DEFERRAL_CATCHUP' then
        l_403b_limit   := l_fed_information6;
    elsif  l_limit_name = 'ADDITIONAL_ANY_YEAR_AMOUNT' then
        l_403b_limit   := l_fed_information7;
    elsif  l_limit_name = 'COMBINED_403B_457_LIMIT' then
        l_403b_limit   := l_fed_information8;
    elsif  l_limit_name = 'GENERAL_CATCHUP_LIMIT' then
        l_403b_limit   := l_fed_information9;
    end if;

    close Cur_403b_limit;

    hr_utility.set_location('GET_PQP_LIMIT',15);


    return NVL(l_403b_limit,0);

end;

----------------------------------------------------
-- Function to calculate Maximum Exclusion Allowance
----------------------------------------------------
function Calc_max_excl_allow (
    p_payroll_action_id             in number,
    p_ee_incld_annual_comp          in number,
    p_total_er_contr_prior_years    in number,
    p_years_of_service              in number
    )
 Return number is

 Max_excl_allow  number := 0;
 l_effective_date date;
 begin
l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
   hr_utility.set_location('Start of Calc_max_excl_allow ', 5);
   max_excl_allow := (0.20 * p_ee_incld_annual_comp * p_years_of_service) -
                        p_total_er_contr_prior_years;

   hr_utility.set_location('End of Calc_max_excl_allow ', 10);

   return max_excl_allow;
 end;
--------------------------------------
-- Function to calculate Overall Limit
--------------------------------------
-- Function calculates the Overall Limit
-- which is the samllest of the following
-- three :-
-- 1 - Greater of (Employee's Incld Annual Comp,
--                Includable annuall comp limit)
-- 2 - 25% of Employee's Incld Annual Comp.
-- 3 - Overall Employer Limit
-----------------------------------------
Function Calc_overall_limit (
    p_payroll_action_id in number,
    p_ee_incld_annual_comp      in number
    )
Return Number is

l_incld_annual_comp_limit  number := 0;
l_ee_incld_annual_comp     number := 0;
l_overall_er_limit         number := 0;
overall_limit              number := 0;
l_effective_date           date;

begin

l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
 hr_utility.set_location('Start of Calc_overall_limit ', 5);

 l_incld_annual_comp_limit := pay_ff_functions.get_pqp_limit(
                                p_payroll_action_id =>p_payroll_action_id,
                                p_limit             =>'includable_annual_comp_limit');
 l_overall_er_limit := pay_ff_functions.get_pqp_limit(
                               p_payroll_action_id=>p_payroll_action_id,
                               p_limit            =>'overall_er_limit');

-- Choose the lesser of the
-- Incld annual comp  Limit or the employee's annual comp. */

 if p_ee_incld_annual_comp >  l_incld_annual_comp_limit then
    l_ee_incld_annual_comp := l_incld_annual_comp_limit;
 else
    l_ee_incld_annual_comp := p_ee_incld_annual_comp;
 end if;

 overall_limit :=   (0.25 * l_ee_incld_annual_comp);

-- Choose lesser of the prv. computed figure or the Overall ER Limit

 if overall_limit > l_overall_er_limit then
    overall_limit := l_overall_er_limit;
 end if;

 hr_utility.set_location('End of Calc_overall_limit ',10);

 return overall_limit;

 end;
--
--
---------------------------------------
-- Function to calculate Any Year Limit
---------------------------------------
Function Calc_any_year_limit (
    p_payroll_action_id in number,
    p_ee_incld_annual_comp          in number,
    p_total_er_contr_prior_years    in number,
    p_years_of_service              in number
    )
Return number is

l_additional_any_year_amount number := 0;
l_any_year_limit             number := 0;
l_max_excl_allowance         number := 0;

this_limit                   number := 0;    -- Since the same name variable
                                             -- is also used for pqp_limit
l_effective_date             date;                                             -- of the same name
 begin
l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
 hr_utility.set_location('Start of Calc_any_year_limit ', 5);
 l_additional_any_year_amount := pay_ff_functions.get_pqp_limit(
                                     p_payroll_action_id=>p_payroll_action_id,
                                     p_limit            =>'additional_any_year_amount');

 this_limit := (0.25 * p_ee_incld_annual_comp)
                      + l_additional_any_year_amount;

 l_max_excl_allowance := pay_ff_functions.calc_max_excl_allow (
                                                p_payroll_action_id,
                                                p_ee_incld_annual_comp,
                                                p_total_er_contr_prior_years,
                                                p_years_of_service );

-- Choose the lesser of two

 if this_limit > l_max_excl_allowance then
    this_limit := l_max_excl_allowance;
 end if;

 l_any_year_limit :=
       pay_ff_functions.get_pqp_limit(
                   p_payroll_action_id=>p_payroll_action_id,
                   p_limit            =>'any_year_limit');

-- Choose the lesser of two

 if this_limit > l_any_year_limit then
    this_limit := l_any_year_limit;
 end if;

 hr_utility.set_location('End of Calc_any_year_limit ', 5);

 return this_limit;

 end;
--
--
-------------------------------------------------
-- Function to calculate year of separation Limit
-------------------------------------------------
Function Calc_year_of_sep_limit(
    p_payroll_action_id in number,
    p_assignment_id                     in number,
    p_ee_incld_annual_comp              in number,
    p_total_er_contr_prior_years        in number,
    p_years_of_service                  in number
    )
Return number is

l_overall_er_limit      number :=  0;
l_max_excl_allow_limit  number :=  0;
l_years_of_service      number :=  0;
l_prv_date              date;
l_calc_prv_contr        number :=  0;
l_defined_balance_id    number :=  0;
l_calc_bal              number :=  0;
l_start_date            date;
l_effective_date        date;
Cursor C1 is
   select
     db.defined_balance_id
   from
     pay_balance_types pbt,
     pay_defined_balances db,
     pay_balance_dimensions bd
   where
        pbt.balance_name        = 'Qualified EE ER Contribution'
    and pbt.balance_type_id     = db.balance_type_id
    and bd.dimension_name       = 'Person Lifetime to Date'
    and bd.balance_dimension_id = db.balance_dimension_id;

Cursor C2 is
   SELECT max(service.date_start) start_date
   FROM   per_periods_of_service service,
          per_all_assignments_f  ass
   WHERE  ass.assignment_id      = p_assignment_id
     AND  ass.person_id          = service.person_id
     AND  service.date_start    <= l_effective_date;


begin
l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
  l_overall_er_limit :=
         pay_ff_functions.get_pqp_limit (
                      p_payroll_action_id=>p_payroll_action_id,
                      p_limit            =>'overall_er_limit');

if p_years_of_service > 10 then

   l_years_of_service := 10;

   /* calculate the total employers contr. for last 10yrs */

   for c1_rec in C1
   loop
        l_defined_balance_id := c1_rec.defined_balance_id;
   end loop;

   for c2_rec in C2
   loop
       l_start_date := c2_rec.start_date;
   end loop;

    l_prv_date := '31-dec-'||
                  to_char(to_number(to_char(trunc(l_effective_date,'YEAR')-1,'YYYY'))-10);

    if l_prv_date >= l_start_date then
       l_calc_bal := pay_balance_pkg.get_value(l_defined_balance_id
                                              ,p_assignment_id
                                              ,l_prv_date);
    end if;

    l_calc_prv_contr := p_total_er_contr_prior_years - l_calc_bal;

else
   l_years_of_service := p_years_of_service;
   l_calc_prv_contr   := p_total_er_contr_prior_years;
end if;

l_max_excl_allow_limit := pay_ff_functions.calc_max_excl_allow(
                                               p_payroll_action_id,
                                               p_ee_incld_annual_comp,
                                               l_calc_prv_contr,
                                               l_years_of_service);
if l_overall_er_limit > l_max_excl_allow_limit then
  return l_max_excl_allow_limit ;
else
  return  l_overall_er_limit;
end if;

  exception
  when others then
     hr_utility.set_message(801, 'PAY_YEAR_OF_SEP_LIMIT_FAILURE');
     -- probable cause is that the payroll has not been assigned to
     -- the employee as of date of hire
     hr_utility.raise_error;
     return 0;
end;
--
--

-------------------------------------------------
-- Function to calculate effective deferral limit
-------------------------------------------------
Function Calc_elec_def_limit(
    p_payroll_action_id in number,
    p_catch_up              in varchar2,
    p_total_elec_def        in number,
    p_years_of_service      in number,
    p_catch_up_amt          in number
    )
Return number is

l_elec_def_limit                    number := 0;
l_elec_def_catchup_limit            number := 0;

amt1                                number := 0;
amt2                                number := 0;
amt3                                number := 0;
l_effective_date                    date;
begin

l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
l_elec_def_catchup_limit :=
    pay_ff_functions.get_pqp_limit (
              p_payroll_action_id=>p_payroll_action_id,
              p_limit            =>'elective_deferral_catchup');
l_elec_def_limit :=
    pay_ff_functions.get_pqp_limit (
             p_payroll_action_id=>p_payroll_action_id,
             p_limit            =>'elective_deferral_limit');

if p_catch_up = 'CATCHUP_YES' then

--
-- If Catch Up option is taken the the limit would be minimum
-- of the following three amounts :
-- Amt 1  = (Total years of service * 5000) -
--           previous years contribution(i.e. in our case p_total_elec_def)
-- Amt 2  = Elective Deferral Limit +
--          Elective Defferal Additional Catchup limit
-- Amt 3  = (Elective Deferral Catchup Limit -
--           any prior catchup contribution) + elective_deferral_limit
--

      amt1 := (5000 * p_years_of_service) - p_total_elec_def;
      amt2 := l_elec_def_limit +
              pay_ff_functions.get_pqp_limit (
                         p_payroll_action_id=>p_payroll_action_id,
                         p_limit            =>'ELE_DEF_ADDITIONAL_CATCHUP');
      amt3 := (l_elec_def_catchup_limit - p_catch_up_amt) + l_elec_def_limit;

      if amt1 > amt2 then
         l_elec_def_limit := amt2;
      else
         l_elec_def_limit := amt1;
      end if;

      if l_elec_def_limit > amt3 then
         l_elec_def_limit := amt3;
      end if;

end if;

return l_elec_def_limit;

end;
--
------------------------------------------
-- Function to calculate length of service
------------------------------------------
Function Calc_length_of_service(
    p_payroll_action_id in number,
    p_assignment_id     in number,
    p_dummy             in varchar)
Return number is

p_years_of_service      number := 0;
p_person_id             number;
p_start_date            date;
l_effective_date        date;
cursor c1 is
   SELECT max(service.date_start) start_date
   FROM   per_periods_of_service service,
          per_all_assignments_f  ass
   WHERE  ass.assignment_id = p_assignment_id
     AND  ass.person_id     = service.person_id
     AND  service.date_start <= l_effective_date;

begin
l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
  for c1_rec in c1
    loop
    p_start_date := c1_rec.start_date;
  end loop;
  if l_effective_date < p_start_date then
     p_years_of_service := 0;
  else
     p_years_of_service :=
              ceil(months_between(l_effective_date,(p_start_date - 1)) / 12);
  end if;
  return p_years_of_service;
end;
--
------------------------------------------
-- Function to check whether employee is
-- enrolled in both 403(b) and 457 plans
------------------------------------------
Function Check_if_emp_in_403b_457_plan(
                 p_payroll_action_id in number,
		 p_assignment_id in number,
                 p_dummy in VARCHAR)
return varchar is
  l_person_id   number := 0;
  l_both_plans  number;
  l_effective_date date;
  cursor c_person is
  select person_id
  from   per_assignments_f
  where  assignment_id = p_assignment_id;

  cursor c1 is
  select c.person_id
  from  ben_prtt_enrt_rslt_f  c,
        ben_pl_regn_f  b,
        ben_regn_f     a
  where c.person_id       = l_person_id
    and a.sttry_citn_name = 'IRC S457'
    and b.regn_id         = a.regn_id
    and c.pl_id           =  b.pl_id
    and l_effective_date between a.effective_start_date and
                          nvl(a.effective_end_date,l_effective_date)
    and l_effective_date between b.effective_start_date and
                          nvl(b.effective_end_date,l_effective_date)
    and l_effective_date between c.enrt_cvg_strt_dt and c.enrt_cvg_thru_dt
    and c.enrt_cvg_thru_dt <= c.effective_end_date
    and c.prtt_enrt_rslt_stat_cd is null;

begin

l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
 for c_person_rec in c_person
 loop
    l_person_id := c_person_rec.person_id;
 end loop;
 --
 for c1_rec in c1
 loop
   l_both_plans := c1_rec.person_id;
 end loop;
 --
 if l_both_plans is null then
    return 'FALSE';
 else
    return 'TRUE' ;
 end if;
end;
--
--

------------------------------------------
-- Function to get the annual salary
------------------------------------------
function get_annual_salary (
          p_payroll_action_id in number,
          p_assignment_id    in number,
          p_as_of_date       in date
          )
return number is

   l_current_annual_salary      number;
   p_effective_date             date;
   l_effective_date             date;

   CURSOR c1 (l_effective_date date ) is
   SELECT pro.proposed_salary_n Last_Apprv_Sal, pro.change_date,
          pro.proposed_salary_n *
              nvl(ppb.pay_annualization_factor,tpt.number_per_fiscal_year) last_anul_sal
   FROM   per_people_f per,
          per_time_period_types tpt,
          per_assignments_f     ass,
          per_pay_bases         ppb,
          per_pay_proposals     pro,
          pay_all_payrolls_f    prl
   WHERE  per.person_id       = ass.person_id
     AND  ass.pay_basis_id    = ppb.pay_basis_id
     AND  ass.assignment_type = 'E'
     AND  ass.payroll_id      = prl.payroll_id
     AND  ass.effective_start_date BETWEEN prl.effective_start_date AND
                       nvl(prl.effective_end_date, ass.effective_start_date)
     AND  prl.period_type     = tpt.period_type
     AND  ass.assignment_id   = pro.assignment_id(+)
     AND  pro.change_date     = (SELECT MAX(change_date)
                                 FROM   per_pay_proposals pro1
                                 WHERE  pro.assignment_id = pro1.assignment_id
                                   AND  pro1.approved         = 'Y'
                                   AND  pro1.change_date <= l_effective_date)
     AND  ass.business_group_ID + 0  = NVL(hr_general.get_business_group_id,
                                           ass.business_group_id)
     AND l_effective_date BETWEEN per.effective_start_date
                          AND nvl(per.effective_end_date, l_effective_date)
     AND l_effective_date  BETWEEN ass.effective_start_date
                          AND nvl(ass.effective_end_date, l_effective_date)
     AND ass.assignment_id = p_assignment_id;

BEGIN
p_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
   /*
    * make use of the day and month that the user has passed from the formula else
    * use the context date
    */
   if p_as_of_date = to_date('1951/01/01', 'yyyy/mm/dd') then
      l_effective_date := p_effective_date;
   else
      l_effective_date := to_date(to_char(p_effective_date,'yyyy')||
                          to_char(p_as_of_date,'mmdd'),'yyyymmdd');
   end if;
   --
   for c1_rec in c1(l_effective_date) loop
       l_current_annual_salary := c1_rec.last_anul_sal;
   end loop;
   --
   return nvl(l_current_annual_salary,0);
   --
END get_annual_salary;
--------------------------------------------------------------------------

------------------------------------------
-- Function to Get the 457 Limit
------------------------------------------
function get_457_annual_limit(
    p_effective_date    IN DATE  DEFAULT NULL,
    p_payroll_action_id IN NUMBER DEFAULT NULL,
    p_limit             IN VARCHAR) Return number is

  l_fed_information1 number;
  l_fed_information2 number;
  l_fed_information3 number;
  l_effective_date date;
  Cursor Cur_457_limit (p_date date) is
    Select
        fed_information1,
        fed_information2,
        fed_information3
    from
        pay_us_federal_tax_info_f
    where
      fed_information_category = '457 LIMITS'
      and  p_date between effective_start_date and
                          nvl(effective_end_date, p_date);

  l_457_limit       number;
  l_limit_name       varchar2(100);

begin
 IF p_payroll_action_id IS NULL THEN
   l_effective_date:=p_effective_date;
 ELSE
    l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
 END IF;
    hr_utility.set_location('Start of GET_457_LIMIT', 5);

    open Cur_457_limit (l_effective_date);

    fetch Cur_457_limit into
        l_fed_information1,
        l_fed_information2,
        l_fed_information3;

   if Cur_457_limit%notfound then
     close Cur_457_limit;
--   Error : No limits defined for 457
     hr_utility.set_message(801, 'PAY_PQP_LIMITS_NOT_DEFINED');
     hr_utility.raise_error;
     return 0;
   end if;

   hr_utility.set_location('GET_457_LIMIT', 10);

    l_limit_name := upper(p_limit);

    l_457_limit := 0;

    if  l_limit_name    = '457 LIMIT' then
        l_457_limit   := l_fed_information1;
    elsif  l_limit_name = '457 CATCHUP LIMIT' then
        l_457_limit   := l_fed_information2;
    elsif  l_limit_name = '457 ADDITIONAL CATCHUP' then
        l_457_limit   := l_fed_information3;
    end if;

    close Cur_457_limit;

    hr_utility.set_location('GET_457_LIMIT',15);


    return l_457_limit;

end;


----------------------------------------------------
-- Function to calculate catchup previously unused
----------------------------------------------------
function calc_prev_unused (p_assignment_id    in number,
                           p_payroll_action_id in number,
                           p_dummy            in varchar)
  return number is
  l_amt number := 0;
  l_effective_date date;
  cursor c1 is
  select
         sum(max(contr.max_contr_allowed) - sum(contr.amt_contr))  amt
  from
         pay_us_contribution_history contr,
         per_assignments_f paf
  where
        paf.assignment_id = p_assignment_id
    and l_effective_date between paf.effective_start_date and
                            nvl(paf.effective_end_date, l_effective_date)
    and contr.person_id   = paf.person_id
    and contr.contr_type  = 'G'
    and contr.date_to < l_effective_date
    and contr.legislation_code = 'US'
  group by contr.date_to;

begin

l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
  for c1_rec in c1
  loop
      l_amt := c1_rec.amt;
  end loop;

  return nvl(l_amt,0);

end;

----------------------------------------------------
-- Function to calculate 457 limit
----------------------------------------------------
function get_457_calc_limit (
    p_payroll_action_id in number,
    p_ee_incld_annual_comp          in number
    )
 Return number is

 l_calc_457_limit  number := 0;
 l_effective_date date;
 begin
l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
   hr_utility.set_location('Start of get_457_calc_limit ', 5);

   l_calc_457_limit := (p_ee_incld_annual_comp / 3) ;

   hr_utility.set_location('End of get_457_calc_limit', 10);

   return l_calc_457_limit;
 end;

----------------------------------------------------
-- Function to calculate 457 vested amount
----------------------------------------------------
function get_457_vested_amt (
			   p_assignment_id    in number,
                           p_payroll_action_id in number,
                           p_dummy            in varchar)
 return number is
l_effective_date date;
 begin
l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
   hr_utility.set_location('Start of get_457_vested_amt ', 5);

   return 0;

   hr_utility.set_location('End of get_457_vested_amt', 10);

 end;

--------------------------------------------------------------------------
--------------------------------------------------------------------------

----------------------------------------------
--- Function Run Year
----------------------------------------------
function Run_Year (
           p_payroll_action_id in number,
           p_dummy          in varchar)
return number is
l_effective_date date;
begin
l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
     hr_utility.set_location('Start of Run Year ', 5);
     return to_number(to_char(l_effective_date,'YYYY'));
     hr_utility.set_location('End of Run Year ', 10);

end;
--------------------------------------------------------------------------

----------------------------------------------
--- Function Get Template Earnings
----------------------------------------------
function get_template_earnings (
           p_ctx_original_entry_id  NUMBER,
           p_template_earnings      NUMBER,
           p_accrued_value          NUMBER,
           p_maximum_amount         NUMBER,
           p_prorate_start_date     DATE,
           p_prorate_end_date       DATE,
           p_payroll_start_date     DATE,
           p_payroll_end_date       DATE,
           p_stop_entry_flag     OUT NOCOPY VARCHAR2,
           p_clear_accrued_flag  OUT NOCOPY VARCHAR2)
return number is
ln_template_earnings    NUMBER;
ld_ele_entry_start_date DATE;
ld_ele_entry_end_date   DATE;

cursor c_get_ele_entry_dates is
select min(effective_start_date),
       max(effective_end_date)
  from pay_element_entries_f
 where element_entry_id = p_ctx_original_entry_id
 group by element_entry_id;

begin


  /*
   * Value of the Parameters passed
   */
  hr_utility.trace('Original Entry ID   = ' || p_ctx_original_entry_id);
  hr_utility.trace('Template Earnings   = ' || p_template_earnings);
  hr_utility.trace('Accrued Value       = ' || p_accrued_value);
  hr_utility.trace('Maximum Amount      = ' || p_maximum_amount);
  hr_utility.trace('Prorate Start Date  = ' || p_prorate_start_date);
  hr_utility.trace('Prorate End Date    = ' || p_prorate_end_date);
  hr_utility.trace('Payroll Start Date  = ' || p_payroll_start_date);
  hr_utility.trace('Payroll End Date    = ' || p_payroll_end_date);

  /*
   * Resetting the Global variables whenever a new element is getting processed
   */

  if GLB_ORIGINAL_ENTRY_ID is NULL then
     GLB_ORIGINAL_ENTRY_ID := -9999;
  end if;

  if GLB_ORIGINAL_ENTRY_ID <> p_ctx_original_entry_id then
     GLB_ORIGINAL_ENTRY_ID := p_ctx_original_entry_id;
     GLB_TEMPLATE_EARNINGS := 0;
     GLB_STOP_ENTRY_FLAG   := 'N';
  end if;

   /*
    * Get the element entry start dates and end dates
    * to correctly set the Global variables
    */
   open c_get_ele_entry_dates;
   fetch c_get_ele_entry_dates into ld_ele_entry_start_date
                                   ,ld_ele_entry_end_date;
   close c_get_ele_entry_dates;

   /*
    * If both Prorate Start date and Payroll start date are equal
    * then it is the first FLSA period in the Payroll run and we need to
    * set the Global variable properly.
    */
   if p_prorate_start_date = p_payroll_start_date then
      if (p_maximum_amount <= p_template_earnings + p_accrued_value) then
         GLB_TEMPLATE_EARNINGS := p_maximum_amount - p_accrued_value;
         GLB_STOP_ENTRY_FLAG := 'Y';
      else
         GLB_TEMPLATE_EARNINGS := p_template_earnings;
         GLB_STOP_ENTRY_FLAG := 'N';
      end if;
   else
      /*
       * In case Prorate Start date and Payroll start date are not equal
       * there are two cases
       *    1. Element Entry Started on a date later than Payroll Start date
       *       in which case we again need to set the Global variables as the
       *       First FLSA period for this element falls on a different date.
       *    2. This might be the next FLSA period
       */
      if ld_ele_entry_start_date > p_payroll_start_date then
         /*
          * To check for the First FLSA period as first FLSA period will start
          * from the Element Entry date if the same was more than Payroll start
          * date
          */
         if ld_ele_entry_start_date = p_prorate_start_date then
            if (p_maximum_amount <= p_template_earnings + p_accrued_value) then
               GLB_TEMPLATE_EARNINGS := p_maximum_amount - p_accrued_value;
               GLB_STOP_ENTRY_FLAG := 'Y';
            else
               GLB_TEMPLATE_EARNINGS := p_template_earnings;
               GLB_STOP_ENTRY_FLAG := 'N';
            end if;
         end if;
      end if;
   end if;

   ln_template_earnings := GLB_TEMPLATE_EARNINGS;
   p_stop_entry_flag    := 'N';
   /*
    * Setting of STOP_ENTRY_FLAG to 'Y' should be only on the last FLSA period
    * for the element
    * For element manulally end dated, we also need to set the flag to 'Y'
    * during the last FLSA period
    */
   if ld_ele_entry_end_date < p_payroll_end_date then
      if ld_ele_entry_end_date = p_prorate_end_date then
         p_clear_accrued_flag := 'Y';
      end if;
   else
      if (GLB_STOP_ENTRY_FLAG = 'Y'
          AND p_prorate_end_date = p_payroll_end_date) then
         p_stop_entry_flag := 'Y';
      end if;
   end if;

   hr_utility.trace('Calculated Earnings = ' || ln_template_earnings);
   hr_utility.trace('');
--   hr_utility.trace_off();

   return to_number(ln_template_earnings);
end;

----------------------------------------------
--- Function Check Authorization Date
----------------------------------------------
function check_authorization_date (
           p_ctx_original_entry_id  NUMBER,
           p_auth_end_date          DATE,
           p_prorate_end_date       DATE,
           p_payroll_end_date       DATE,
           p_clear_accrued_flag  OUT NOCOPY VARCHAR2)
return varchar2 is

lv_stop_entry_flag      VARCHAR2(10);
ld_ele_entry_start_date DATE;
ld_ele_entry_end_date   DATE;


cursor c_get_ele_entry_dates is
select min(effective_start_date),
       max(effective_end_date)
  from pay_element_entries_f
 where element_entry_id = p_ctx_original_entry_id
 group by element_entry_id;

begin


  /*
   * Value of the Parameters passed
   */
  hr_utility.trace('Original Entry ID   = ' || p_ctx_original_entry_id);
  hr_utility.trace('Auth End Date       = ' || p_auth_end_date);
  hr_utility.trace('Prorate Start Date  = ' || p_prorate_end_date);
  hr_utility.trace('Prorate End Date    = ' || p_prorate_end_date);

   /*
    * Get the element entry start dates and end dates
    * to correctly set the Global variables
    */
   open c_get_ele_entry_dates;
   fetch c_get_ele_entry_dates into ld_ele_entry_start_date
                                   ,ld_ele_entry_end_date;
   close c_get_ele_entry_dates;

   /*
    * Check if we need to end date the element becuase of
    * Authorization end date being reached
    */
   if p_auth_end_date < p_payroll_end_date then
      /*
       * Set only the Clear accrued flag if element has been end dated
       * manually and the end date lies in the current Payroll period
       */
      if ld_ele_entry_end_date < p_payroll_end_date then
         if p_prorate_end_date = ld_ele_entry_end_date then
            p_clear_accrued_flag := 'Y';
         end if;
      else
         if p_prorate_end_date = p_payroll_end_date then
            lv_stop_entry_flag := 'Y';
         end if;
      end if;
   else
      /*
       * Set Clear Accrued flag if element has been end dated manually
       */
      if (ld_ele_entry_end_date < p_payroll_end_date AND
          p_prorate_end_date = ld_ele_entry_end_date) then
            p_clear_accrued_flag := 'Y';
      end if;
   end if;
   return lv_stop_entry_flag;
end;

----------------------------------------------
--- Function Get Earnings Calculation
----------------------------------------------
function get_earnings_calculation (
           p_ctx_asg_action_id      NUMBER,
           p_ctx_original_entry_id  NUMBER,
           p_adjust_flag            VARCHAR2,
           p_max_adjust_amount      NUMBER,
           p_total_earnings         NUMBER,
           p_period_earnings        NUMBER,
           p_prorate_end_date       DATE,
           p_payroll_end_date       DATE
)
return number is

l_period_earnings number;
l_amt_difference  number;

begin

  hr_utility.trace('Entering GET_CORRECT_FLSA_EARNINGS');
  hr_utility.trace('ASSIGNMENT ACTION ID.....' || p_ctx_asg_action_id);
  hr_utility.trace('ORIGINAL ENTRY ID........' || p_ctx_original_entry_id);
  hr_utility.trace('ADJUST FLAG..............' || p_adjust_flag);
  hr_utility.trace('MAX ADJUST AMOUNT .......' || p_max_adjust_amount);
  hr_utility.trace('TOTAL EARNINGS...........' || p_total_earnings);
  hr_utility.trace('PERIOD EARNINGS..........' || p_period_earnings);
  hr_utility.trace('PRORATE END DATE.........' || p_prorate_end_date);
  hr_utility.trace('PAYROLL END DATE.........' || p_payroll_end_date);
  hr_utility.trace('GLB_ORIGINAL_ENTRY_ID_2..' || GLB_ORIGINAL_ENTRY_ID_2);
  hr_utility.trace('GLB_PERIOD_EARNINGS..' || GLB_PERIOD_EARNINGS);
  hr_utility.trace('GLB_ASSIGNMENT_ACTION_ID..' || GLB_ASSIGNMENT_ACTION_ID);

  l_period_earnings := 0;

  -- Resetting Global variables if required

  if GLB_ASSIGNMENT_ACTION_ID IS NULL then
     GLB_ASSIGNMENT_ACTION_ID := -9999;
  end if;

  -- Initializing Global variables
  if p_ctx_asg_action_id <> GLB_ASSIGNMENT_ACTION_ID then
     GLB_ASSIGNMENT_ACTION_ID := p_ctx_asg_action_id;
     GLB_ORIGINAL_ENTRY_ID_2 := NULL;
     GLB_PERIOD_EARNINGS := 0;
  end if;

  -- Initialize GLB_ORIGINAL_ENTRY_ID_2
  if GLB_ORIGINAL_ENTRY_ID_2 is NULL then
     GLB_ORIGINAL_ENTRY_ID_2 := -9999;
  end if;

  if GLB_ORIGINAL_ENTRY_ID_2 <> p_ctx_original_entry_id then
     hr_utility.trace('Initializing Variables');
     GLB_ORIGINAL_ENTRY_ID_2 := p_ctx_original_entry_id;
     GLB_PERIOD_EARNINGS     := 0;
  end if;

  -- Return the corrected earnings value in case of Allocation
  -- during the last FLSA Period
  if p_adjust_flag = 'Y' then
     if p_payroll_end_date = p_prorate_end_date then
        l_amt_difference    := p_total_earnings - GLB_PERIOD_EARNINGS - p_period_earnings;
        hr_utility.trace('Difference = ' || l_amt_difference);
        if l_amt_difference < p_max_adjust_amount then
           l_period_earnings   := p_total_earnings - GLB_PERIOD_EARNINGS;
           hr_utility.trace('l_period_earnings1 = ' || l_period_earnings);
        else
           l_period_earnings   := round(p_period_earnings,2);
           hr_utility.trace('l_period_earnings1 = ' || l_period_earnings);
        end if;
     else
        l_period_earnings   := round(p_period_earnings,2);
        GLB_PERIOD_EARNINGS := GLB_PERIOD_EARNINGS + l_period_earnings;
        hr_utility.trace('l_period_earnings2 = ' || l_period_earnings);
        hr_utility.trace('GLB_PERIOD_EARNINGS = ' || GLB_PERIOD_EARNINGS);
     end if; -- if p_payroll_end_date
  else
     l_period_earnings := p_period_earnings;
     hr_utility.trace('No Adjustment Done');
  end if; -- if p_adjust_flag = 'Y'

  return l_period_earnings;

end;
---------------------------------------------------
--- Function get_salbasis_detail
--- Returns values are
---    * 'Y'      ====>  Salary Basis
---    * 'REG'    ====>  Regular Element
---    * 'REDREG' ====>  Reduce Regular Element
---    * 'NONREG' ====>  Non-Regular Element
---------------------------------------------------
function GET_SALARY_BASIS_DETAIL(
           original_entry_id         NUMBER,
           template_earning          NUMBER,
           hours_passed              NUMBER,
           red_reg_earnings          NUMBER,
           red_reg_hours             NUMBER,
           prorate_start             DATE,
           prorate_end               DATE,
           payroll_start_date        DATE,
           payroll_end_date          DATE,
           flsa_time_definition      VARCHAR2,
           stop_run_flag             OUT NOCOPY VARCHAR2,
           reduced_template_earnings OUT NOCOPY NUMBER,
           reduced_hours_passed OUT  NOCOPY NUMBER,
           red_reg_adjust_amount     NUMBER default 0.05,
           red_reg_adjust_hours      NUMBER default 0.01,
           red_reg_raise_error       VARCHAR2 default 'Y'
           )
return varchar2 is

ln_reduced_template_earnings    NUMBER;
ln_reduced_hours_passed NUMBER;
lv_salary_basis_element VARCHAR2(1);
ld_ele_entry_start_date DATE;
ld_ele_entry_end_date   DATE;
lv_element_name         VARCHAR2(80);
ln_element_type_id      NUMBER;
ln_assignment_id        NUMBER;
ln_sal_element_type_id  NUMBER;
ln_diff_earn            NUMBER;
ln_diff_hours           NUMBER;
lv_sal_element_name     VARCHAR2(80);
lv_red_reg_ele          VARCHAR2(80);
lv_return_val           VARCHAR2(80);
lv_reg_elem             VARCHAR2(80);
lv_classification       VARCHAR2(80);

cursor c_get_ele_type_id (cp_original_entry_id number) is
select pet.element_type_id, pet.element_name, pee.assignment_id,
       nvl(pet.element_information13,'N'),
       nvl(pet.element_information1, 'NONREG'),
       pec.classification_name
  from pay_element_entries_f pee,
       pay_element_links_f pel,
       pay_element_types_f pet,
       pay_element_classifications pec
 where pee.element_entry_id = cp_original_entry_id
   and pel.element_link_id = pee.element_link_id
   and pel.element_type_id = pet.element_type_id
   and pec.classification_id = pet.classification_id
   and pec.legislation_code = 'US'
   and pee.effective_end_date between pel.effective_start_date
                                  and pel.effective_end_date
   and pee.effective_end_date between pet.effective_start_date
                                  and pet.effective_end_date;


cursor c_get_salary_basis_element(cp_assignment_id number,
                                  cp_date in date) is
select ETYPE.element_type_id, ETYPE.element_name
  from per_all_assignments_f ASSIGN
      ,per_pay_bases BASES
      ,pay_input_values_f INPUTV
      ,pay_element_types_f ETYPE
      ,pay_rates RATE
where cp_date BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
  and ASSIGN.assignment_id = cp_assignment_id
  and BASES.pay_basis_id (+)= ASSIGN.pay_basis_id
  and INPUTV.input_value_id (+)= BASES.input_value_id
  and cp_date between nvl (INPUTV.effective_start_date,cp_date)
                  and nvl (INPUTV.effective_end_date,cp_date)
  and ETYPE.element_type_id (+)= INPUTV.element_type_id
  and cp_date between nvl (ETYPE.effective_start_date,cp_date)
                  and nvl (ETYPE.effective_end_date,cp_date)
  and RATE.rate_id (+)= BASES.rate_id ;

begin

   -- Value of the Parameters passed
   hr_utility.trace('GLB_RR_ORIGINAL_ENTRY_ID  = ' || GLB_RR_ORIGINAL_ENTRY_ID);
   hr_utility.trace('GLB_RR_SAL_BASIS_ELEMENT  = ' || GLB_RR_SAL_BASIS_ELEMENT);
   hr_utility.trace('GLB_RED_REG_ELE  = ' || GLB_RED_REG_ELE);
   hr_utility.trace('stop_run_flag  = ' || stop_run_flag);

   hr_utility.trace('Original Entry ID   = ' || original_entry_id);
   hr_utility.trace('Template Earning    = ' || template_earning);
   hr_utility.trace('hours_passed     = ' || hours_passed);
   hr_utility.trace('red_reg_earnings     = ' || red_reg_earnings);
   hr_utility.trace('red_reg_hours     = ' || red_reg_hours);
   hr_utility.trace('Prorate Start Date  = ' || prorate_start);
   hr_utility.trace('Prorate End Date    = ' || prorate_end);
   hr_utility.trace('Prorate Start Date  = ' || prorate_start);
   hr_utility.trace('Prorate End Date    = ' || prorate_end);
   hr_utility.trace('Payroll Start Date  = ' || payroll_start_date);
   hr_utility.trace('Payroll End Date    = ' || payroll_end_date);
   hr_utility.trace('Flsa_time_definition    = ' || flsa_time_definition);
   hr_utility.trace('red_reg_adjust_amount = ' || red_reg_adjust_amount);
   hr_utility.trace('red_reg_adjust_hours = ' || red_reg_adjust_hours);
   hr_utility.trace('red_reg_raise_error = ' || red_reg_raise_error);

   ln_reduced_hours_passed := 0;
   ln_reduced_template_earnings := 0;

   if GLB_RR_ORIGINAL_ENTRY_ID is NULL then
      GLB_RR_ORIGINAL_ENTRY_ID := -9999;
      GLB_RR_SAL_BASIS_ELEMENT := 'N';
      GLB_RED_REG_ELE          := 'Y';
      GLB_REG_ELEM             := 'NONREG';
      stop_run_flag            := 'N' ;
      ln_reduced_hours_passed  := 0;
      ln_reduced_template_earnings := 0;

      hr_utility.trace('GLB_RR_ORIGINAL_ENTRY_ID  = '
                     || GLB_RR_ORIGINAL_ENTRY_ID);
      hr_utility.trace('GLB_RR_SAL_BASIS_ELEMENT  = '
                     || GLB_RR_SAL_BASIS_ELEMENT);
      hr_utility.trace('GLB_RED_REG_ELE  = ' || GLB_RED_REG_ELE);
      hr_utility.trace('stop_run_flag  = '|| stop_run_flag);
   end if; -- if GLB_RR_ORIGINAL_ENTRY_ID

   if GLB_RR_ORIGINAL_ENTRY_ID <> original_entry_id then
      GLB_RR_ORIGINAL_ENTRY_ID := original_entry_id ;
      GLB_RR_SAL_BASIS_ELEMENT := 'N';
      GLB_RED_REG_ELE          := 'Y';
      GLB_REG_ELEM             := 'NONREG';
      stop_run_flag            := 'N' ;
      ln_reduced_hours_passed  := 0;
      ln_reduced_template_earnings := 0;

      hr_utility.trace('GLB_RR_ORIGINAL_ENTRY_ID Reset  = '
                     || GLB_RR_ORIGINAL_ENTRY_ID);
      hr_utility.trace('GLB_RR_SAL_BASIS_ELEMENT Reset  = '
                     || GLB_RR_SAL_BASIS_ELEMENT);
      hr_utility.trace('GLB_RED_REG_ELE  Reset = ' || GLB_RED_REG_ELE);
      hr_utility.trace('stop_run_flag  Reset = ' || stop_run_flag);

      open c_get_ele_type_id(original_entry_id);
      fetch c_get_ele_type_id into ln_element_type_id
                                  ,lv_element_name
                                  ,ln_assignment_id
                                  ,lv_red_reg_ele
                                  ,lv_reg_elem
                                  ,lv_classification;
      close c_get_ele_type_id;

      GLB_RED_REG_ELE := lv_red_reg_ele;
      if lv_reg_elem = 'REG' and upper(lv_classification) = 'EARNINGS' then
         GLB_REG_ELEM := 'REG';
      else
         GLB_REG_ELEM := 'NONREG';
      end if; -- if lv_reg_elem = 'REG'


      hr_utility.trace(' ln_assignment_id = ' ||to_char(ln_assignment_id));
      hr_utility.trace('ln_element_type_id Curr = '
                     ||to_char(ln_element_type_id));
      hr_utility.trace('lv_element_name Curr = ' ||lv_element_name);
      hr_utility.trace('GLB_RED_REG_ELE = ' || GLB_RED_REG_ELE);

      open c_get_salary_basis_element(ln_assignment_id,prorate_end);
      fetch c_get_salary_basis_element into ln_sal_element_type_id
                                      ,lv_sal_element_name;
      close c_get_salary_basis_element;

      hr_utility.trace('ln_sal_element_type_id SB= '
                ||to_char(ln_sal_element_type_id));
      hr_utility.trace('lv_sal_element_name SB = '
                ||lv_sal_element_name);

      if ln_element_type_id = ln_sal_element_type_id then
         GLB_RR_SAL_BASIS_ELEMENT := 'Y';
         hr_utility.trace('GLB_RR_SAL_BASIS_ELEMENT Matches  = '
                        || GLB_RR_SAL_BASIS_ELEMENT);
      end if;
   end if; -- if GLB_RR_ORIGINAL_ENTRY_ID <>

   -- No checks required for Reduce Regular Element
   -- Only 'Regular' elements should be reduced.
   -- Regular elements are Elements with 'Earnings' classification
   -- and 'Regular' category
   if (GLB_RED_REG_ELE = 'N' and GLB_REG_ELEM = 'REG') then
      -- Add the adjust amount passed in and find the difference between
      -- Regular Earnings and Reduce Regular Earnings
      ln_diff_earn := template_earning - red_reg_earnings +
                      red_reg_adjust_amount;
      if (ln_diff_earn >= 0 or red_reg_raise_error = 'N') then
         hr_utility.trace('Earnigs greated than Reduce Regular');

         ln_reduced_template_earnings := template_earning - red_reg_earnings;
         if ln_reduced_template_earnings <= 0 then
            reduced_template_earnings :=  0;
         else
            reduced_template_earnings := ln_reduced_template_earnings;
         end if; -- if
         hr_utility.trace('Reduced Template Earnings = '
                         ||reduced_template_earnings);
      else
         hr_utility.trace('Else of earnings FLSA');
         reduced_template_earnings :=  0;
         stop_run_flag := 'Y';
         hr_utility.trace(' stop_run_flag = '||stop_run_flag);
      end if; -- if (template_earning >=

      -- Add the adjust hours passed in and find the difference between
      -- Regular Hours and Reduce Regular Hours
      ln_diff_hours := hours_passed - red_reg_hours +
                      red_reg_adjust_hours;
      if (ln_diff_hours >= 0 or red_reg_raise_error = 'N') then
         hr_utility.trace('Hours greater than Red Reg Hours');

         ln_reduced_hours_passed := hours_passed - red_reg_hours;
         if ln_reduced_hours_passed <=0 then
            reduced_hours_passed := 0;
         else
            reduced_hours_passed := ln_reduced_hours_passed;
         end if; -- if
         hr_utility.trace('Reduced Hours Passed = '  ||reduced_hours_passed);
      else
         hr_utility.trace('Else of hours FLSA');
         reduced_hours_passed := 0;
         stop_run_flag := 'Y';
         hr_utility.trace(' stop_run_flag = '||stop_run_flag);
       end if; -- if hours_passed >=
   end if; -- if GLB_RED_REG_ELE = 'N'

   -- Override stopr_run_flag to 'N' when no error is to be raised
   if red_reg_raise_error = 'N' then
      stop_run_flag := 'N';
      hr_utility.trace('Overriden Value of Stop Run Flag to N');
   end if; -- if red_reg_raise_error =

   hr_utility.trace('OUT stop_run_flag = ' || stop_run_flag);
   hr_utility.trace('OUT reduced_template_earnings = ' || reduced_template_earnings);
   hr_utility.trace('OUT reduced_hours_passed = ' || reduced_hours_passed);
   -- Return Values
   -- 'Y'       ==> Salary Element
   --               Old formulae should work as instead of sending 'N' for
   --               elements that are not Salary Basis we are passing other
   --               values
   -- 'REDREG'  ==> Reduce Regular Elements
   -- 'REG'     ==> Regular Elements that are not attached to Salary Basis
   if GLB_RED_REG_ELE = 'N' then
      if GLB_RR_SAL_BASIS_ELEMENT = 'N' then
         if GLB_REG_ELEM = 'REG' then
            lv_return_val := 'REG';
            hr_utility.trace('Returning Regular Element');
         else
               lv_return_val := 'NONREG';
               hr_utility.trace('Returning Regular Element');
         end if; -- if GLB_REG_ELEM = 'REG'
      else
         lv_return_val := 'Y';
         hr_utility.trace('Returning Salary Basis');
      end if; -- if GLB_RR_SAL_BASIS_ELEMENT =
   else
      lv_return_val := 'REDREG';
      hr_utility.trace('Returning Reduce Regular');
   end if; -- if GLB_RED_REG_ELE =

return lv_return_val;

end;


function get_time_definition(
           TIME_DEFINITION_ID  NUMBER)
RETURN VARCHAR2 is

cursor c_get_time_defn(cp_time_definition_id number) is
select definition_name
  from pay_time_definitions
where time_definition_id = cp_time_definition_id;

begin

     -- Initialize GLB_TIME_DEFINITION_ID
     if GLB_TIME_DEFINITION_ID is NULL then
        GLB_TIME_DEFINITION_ID := -9999;
     end if;

     hr_utility.trace(' GLB_TIME_DEFINITION_ID = '||
         to_char(GLB_TIME_DEFINITION_ID));

    if GLB_TIME_DEFINITION_ID <> TIME_DEFINITION_ID then

       open c_get_time_defn(TIME_DEFINITION_ID);
       fetch c_get_time_defn into GLB_TIME_DEFINITION_NAME;
       close c_get_time_defn ;

       hr_utility.trace(' GLB_TIME_DEFINITION_NAME = '||
            GLB_TIME_DEFINITION_NAME);

       if GLB_TIME_DEFINITION_NAME = 'Non Allocated Time Definition' then
          GLB_FLSA_TIME_DEFN := 'N';
       else
          GLB_FLSA_TIME_DEFN := 'Y';
       end if;
    end if;

     hr_utility.trace(' GLB_FLSA_TIME_DEFN = '||
          GLB_FLSA_TIME_DEFN);
     --hr_utility.trace_off;

return GLB_FLSA_TIME_DEFN;


end;


end pay_ff_functions;

/
