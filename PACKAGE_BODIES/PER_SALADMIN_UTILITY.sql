--------------------------------------------------------
--  DDL for Package Body PER_SALADMIN_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SALADMIN_UTILITY" AS
/* $Header: pesalutl.pkb 120.25.12010000.13 2010/04/23 05:48:49 vkodedal ship $ */

g_package  Varchar2(30) := 'per_saladmin_utility.';
g_debug boolean := hr_utility.debug_enabled;

function Check_GSP_Manual_Override (p_assignment_id in NUMBER, p_effective_date in DATE) RETURN VARCHAR2 is
 Cursor Grade_Ladder Is
   Select Nvl(Gsp_Allow_Override_Flag,'Y')
     From Ben_Pgm_f Pgm,
          Per_all_assignments_F paa
    Where paa.Assignment_Id = p_assignment_id
      and p_effective_date between paa.Effective_Start_Date and paa.Effective_End_Date
      and paa.GRADE_LADDER_PGM_ID     is Not NULL
      and pgm.pgm_id = paa.Grade_Ladder_Pgm_Id
      and p_effective_date between Pgm.Effective_Start_Date and Pgm.Effective_End_Date
      and Pgm_typ_Cd = 'GSP'
      and Pgm_stat_Cd = 'A'
      and Update_Salary_Cd = 'SALARY_BASIS';

 l_status  Varchar2(1) := 'Y';
  Begin
     Open  Grade_Ladder;
     Fetch Grade_Ladder into l_Status;
     Close Grade_Ladder;

   RETURN l_Status;
End;

FUNCTION get_query_only
return VARCHAR2 IS
l_query_only_profile_value VARCHAR2(240) := fnd_profile.VALUE('PER_QUERY_ONLY_MODE');
BEGIN

    RETURN l_query_only_profile_value;

END get_query_only;



function get_grd_min_pay(p_assignment_id in NUMBER
                        ,p_business_group_id in NUMBER
                        ,p_effective_date in date)
return number is
l_grd_min_val number := null;
l_conversion_rate number;
l_grd_annualization_factor number;
l_pay_basis varchar2(20);
l_rate_basis varchar2(20);
l_element_curr_code varchar2(20);
l_grade_curr_code varchar2(20);

cursor grd_min_rate is
select ppb.grade_annualization_factor
    ,ppb.pay_basis
    ,ppb.rate_basis
    ,pet.input_currency_code as element_currency_code
    ,PER_SALADMIN_UTILITY.get_grade_currency(paa.grade_id,ppb.rate_id,p_effective_date,paa.business_group_id) as grade_rate_currency_code
      ,ben_cwb_person_info_pkg.get_grd_min_val(paa.grade_id,ppb.rate_id,p_effective_date)
from per_all_assignments_f paa
  ,per_pay_bases ppb
  ,pay_input_values_f piv
  ,pay_element_types_f pet
where paa.assignment_id = p_assignment_id
and   paa.pay_basis_id = ppb.pay_basis_id
and   ppb.input_value_id = piv.input_value_id
and   piv.element_type_id = pet.element_type_id
and   p_effective_date between paa.effective_start_date and paa.effective_end_date;

BEGIN

open grd_min_rate;
fetch grd_min_rate into l_grd_annualization_factor,l_pay_basis,l_rate_basis,l_element_curr_code,l_grade_curr_code,l_grd_min_val;
close grd_min_rate;

l_conversion_rate := nvl(PER_SALADMIN_UTILITY.get_currency_rate(l_grade_curr_code,l_element_curr_code,p_effective_date,p_business_group_id),1);

if(l_element_curr_code = l_grade_curr_code) then
    if l_grd_annualization_factor is null then
        l_grd_min_val := null;
    elsif (l_grd_annualization_factor = 0 OR (l_pay_basis = 'HOURLY' AND l_rate_basis = 'HOURLY' )) then
        l_grd_min_val := l_grd_min_val;
    elsif (l_grd_annualization_factor <> 0) then
        l_grd_min_val := l_grd_min_val * l_grd_annualization_factor;
     end if;
else
    if l_grd_annualization_factor is null then
        l_grd_min_val := null;
    elsif (l_grd_annualization_factor = 0 OR (l_pay_basis = 'HOURLY' AND l_rate_basis = 'HOURLY' )) then
        l_grd_min_val := l_grd_min_val * l_conversion_rate;
    elsif (l_grd_annualization_factor <> 0) then
        l_grd_min_val := l_grd_min_val * l_grd_annualization_factor * l_conversion_rate;
     end if;
end if;
return l_grd_min_val;
END;


function get_grd_max_pay(p_assignment_id in NUMBER
                        ,p_business_group_id in NUMBER
                        ,p_effective_date in date)
return number is
l_grd_max_val number := null;
l_conversion_rate number;
l_grd_annualization_factor number;
l_pay_basis varchar2(20);
l_rate_basis varchar2(20);
l_element_curr_code varchar2(20);
l_grade_curr_code varchar2(20);

cursor grd_max_rate is
select ppb.grade_annualization_factor
    ,ppb.pay_basis
    ,ppb.rate_basis
    ,pet.input_currency_code as element_currency_code
    ,PER_SALADMIN_UTILITY.get_grade_currency(paa.grade_id,ppb.rate_id,p_effective_date,paa.business_group_id) as grade_rate_currency_code
      ,ben_cwb_person_info_pkg.get_grd_max_val(paa.grade_id,ppb.rate_id,p_effective_date)
from per_all_assignments_f paa
  ,per_pay_bases ppb
  ,pay_input_values_f piv
  ,pay_element_types_f pet
where paa.assignment_id = p_assignment_id
and   paa.pay_basis_id = ppb.pay_basis_id
and   ppb.input_value_id = piv.input_value_id
and   piv.element_type_id = pet.element_type_id
and   p_effective_date between paa.effective_start_date and paa.effective_end_date;

BEGIN

open grd_max_rate;
fetch grd_max_rate into l_grd_annualization_factor,l_pay_basis,l_rate_basis,l_element_curr_code,l_grade_curr_code,l_grd_max_val;
close grd_max_rate;

l_conversion_rate := nvl(PER_SALADMIN_UTILITY.get_currency_rate(l_grade_curr_code,l_element_curr_code,p_effective_date,p_business_group_id),1);

if(l_element_curr_code = l_grade_curr_code) then
    if l_grd_annualization_factor is null then
        l_grd_max_val := null;
    elsif (l_grd_annualization_factor = 0 OR (l_pay_basis = 'HOURLY' AND l_rate_basis = 'HOURLY' )) then
        l_grd_max_val := l_grd_max_val;
    elsif (l_grd_annualization_factor <> 0) then
        l_grd_max_val := l_grd_max_val * l_grd_annualization_factor;
     end if;
else
    if l_grd_annualization_factor is null then
        l_grd_max_val := null;
    elsif (l_grd_annualization_factor = 0 OR (l_pay_basis = 'HOURLY' AND l_rate_basis = 'HOURLY' )) then
        l_grd_max_val := l_grd_max_val * l_conversion_rate;
    elsif (l_grd_annualization_factor <> 0) then
        l_grd_max_val := l_grd_max_val * l_grd_annualization_factor * l_conversion_rate;
     end if;
end if;

return l_grd_max_val;
END;



function  derive_next_sal_perf_date
  (p_change_date  in  per_pay_proposals.change_date%TYPE
  ,p_period   in  per_all_assignments_f.sal_review_period%TYPE
  ,p_frequency    in  per_all_assignments_f.sal_review_period_frequency%TYPE
  )
  Return Date is
    l_derived_date         date;
    l_num_months           number(15) := 0;
    l_num_days       number(15) := 0;
  --
begin
  if (p_frequency = 'Y')then
      l_num_months := 12 * p_period;
  elsif
     (p_frequency = 'M') then
      l_num_months := p_period;
  elsif (p_frequency = 'W' ) then
      l_num_days := 7 * p_period;
  elsif
     (p_frequency = 'D') then
      l_num_days := p_period;
  else
     hr_utility.set_message(801,'HR_51258_PYP_INVAL_FREQ_PERIOD');
     hr_utility.raise_error;
  end if;
  --
  -- Now return the derived date
  --
  if (l_num_months <> 0) then
     l_derived_date := add_months(p_change_date,l_num_months);
  elsif (l_num_days <> 0 ) then
     l_derived_date := p_change_date + l_num_days;
  end if;

  return l_derived_date;
  --
end derive_next_sal_perf_date;

 FUNCTION get_next_sal_review_date(p_assignment_id IN NUMBER,p_change_date IN DATE,p_business_group_id IN NUMBER)
    RETURN DATE
    IS
   --
   l_sal_review_period                  number(15);
   l_sal_review_period_frequency  varchar2(30);
   l_next_sal_review_date         Date;
   --
     cursor csr_sal_review_details is
     select sal_review_period,
            sal_review_period_frequency
     from   per_all_assignments_f
     where  assignment_id = p_assignment_id
     and    business_group_id + 0 = p_business_group_id
     and    p_change_date between effective_start_date
                          and nvl(effective_end_date, hr_general.end_of_time);
   --
    BEGIN
         OPEN csr_sal_review_details;
         FETCH csr_sal_review_details into l_sal_review_period,l_sal_review_period_frequency;

         If csr_sal_review_details%found then
         If (l_sal_review_period is not null) then
               l_next_sal_review_date :=
               derive_next_sal_perf_date
                 (p_change_date  => p_change_date
                   ,p_period     => l_sal_review_period
                   ,p_frequency  => l_sal_review_period_frequency
                    );
         end If;
         end If;
         close csr_sal_review_details;

      return l_next_sal_review_date ;
  END get_next_sal_review_date;



 FUNCTION get_uom(p_pay_proposal_id IN NUMBER)
      RETURN VARCHAR2
    IS
        l_uom   pay_input_values_f.uom%TYPE;
         CURSOR get_uom_cur
      IS
         SELECT piv.uom
           FROM pay_element_types_f pet,
                per_all_assignments_f paaf,
                pay_input_values_f piv,
                per_pay_bases ppb,
                per_pay_proposals ppp
          WHERE ppp.pay_proposal_id = p_pay_proposal_id
          and   paaf.assignment_id = ppp.assignment_id
          and   ppp.change_date BETWEEN paaf.effective_start_date
                and paaf.effective_end_date
          and   ppb.pay_basis_id = paaf.pay_basis_id
          and   ppb.input_value_id = piv.input_value_id
          and   ppp.change_date BETWEEN piv.effective_start_date
                and piv.effective_end_date
          and   piv.element_type_id = pet.element_type_id
          and   ppp.change_date BETWEEN pet.effective_start_date
                and pet.effective_end_date;
    BEGIN
        OPEN get_uom_cur;
        FETCH get_uom_cur INTO l_uom;
        CLOSE get_uom_cur;
    return l_uom;
    END get_uom;

Function get_previous_proposal_dt(p_assignment_id IN NUMBER,p_change_date IN DATE)
        return date
is
l_prev_change_date date;
 CURSOR c_prev_pay_proposals is
      select max(change_date)
      from per_pay_proposals pro
      where pro.assignment_id = p_assignment_id
      and pro.change_date <  p_change_date ;
begin
    OPEN c_prev_pay_proposals;
    FETCH c_prev_pay_proposals into l_prev_change_date;
    IF c_prev_pay_proposals%FOUND then
      CLOSE c_prev_pay_proposals;
      return(l_prev_change_date);
    end if;
    CLOSE c_prev_pay_proposals;
    return (null);
end get_previous_proposal_dt;




function get_next_proposal_with_comp(p_assignment_id in number,
p_session_date in date)
return date
is
cursor c1(p_assignment_id in number,
p_session_date in date) is
select change_date
from per_pay_proposals
where assignment_id = p_assignment_id
and multiple_components = 'Y'
and change_date =
(select min(change_date)
from per_pay_proposals
where assignment_id = p_assignment_id
and change_date > p_session_date);
--
l_change_date per_pay_proposals.change_date%TYPE;
begin
  --
  open c1(p_assignment_id, p_session_date);
  fetch c1 into l_change_date;
  close c1;
  --
  return l_change_date;
  --
end get_next_proposal_with_comp;



procedure adjust_pay_proposals
(
 p_assignment_id   number
) is

l_next_change_date per_pay_proposals.change_date%TYPE;
l_approved per_pay_proposals.approved%TYPE;
l_element_entry_end_date pay_element_entries_f.effective_end_date%TYPE;

Cursor csr_pay_proposals
is
select pay_proposal_id, change_date,date_to
from per_pay_proposals
where assignment_id = p_assignment_id
and approved = 'Y';

Cursor csr_next_change_date(p_change_date in date)
IS
select min(change_date)
from per_pay_proposals
where change_date > p_change_date
and assignment_id = p_assignment_id;

Cursor csr_approved(p_change_date in date)
is
select approved
from per_pay_proposals
where change_date = p_change_date
and assignment_id = p_assignment_id;

Cursor element_entry_end_date(p_pay_proposal_id in number,p_change_date in date)
is
select effective_end_date
From pay_element_entries_f
where assignment_id = p_assignment_id
and creator_type = 'SP'
and creator_id = p_pay_proposal_id
and effective_start_date =p_change_date;

begin

if g_debug then
     hr_utility.trace('In per_saladmin_utility.adjust_pay_proposals');
  end if;
    for i in csr_pay_proposals loop
    ---vkodedal fix -5941519
    l_element_entry_end_date:=null;
     if g_debug then
        hr_utility.set_location('Proposal Id'||i.pay_proposal_id, 66);
        hr_utility.set_location('Change Date'||i.change_date, 66);
        hr_utility.set_location('Date to'||i.date_to, 67);
     end if;

        OPEN element_entry_end_date(i.pay_proposal_id,i.change_date);
        FETCH element_entry_end_date into l_element_entry_end_date;
        CLOSE element_entry_end_date;

     if g_debug then
        hr_utility.set_location('End Date'||l_element_entry_end_date, 70);
     end if;

      if  l_element_entry_end_date is not null and l_element_entry_end_date <> i.date_to then
            if g_debug then
                hr_utility.set_location('End Date and date_to are not matching', 70);
            end if;

       OPEN csr_next_change_date(i.change_date);
        FETCH csr_next_change_date into l_next_change_date;
        CLOSE csr_next_change_date;

        if l_next_change_date is not null then

        OPEN csr_approved(l_next_change_date);
        FETCH csr_approved into l_approved;
        CLOSE csr_approved;

        if l_approved = 'N' THEN

          if l_element_entry_end_date > l_next_change_date-1 THEN

         l_element_entry_end_date :=l_next_change_date-1;

          END IF;

        END IF;

        end if;

     if g_debug then
        hr_utility.set_location('About to update', 70);
     end if;

        update per_pay_proposals
        set date_to =l_element_entry_end_date
        where pay_proposal_id = i.pay_proposal_id;

     if g_debug then
        hr_utility.set_location('Updated successfully', 70);
     end if;


    END IF;


    end loop;

if g_debug then
     hr_utility.trace('OUT per_saladmin_utility.adjust_pay_proposals');
  end if;

end adjust_pay_proposals;

function get_last_payroll_dt(p_assignment_id  NUMBER) RETURN date IS
  l_asg_start_date date;
  l_last_payroll_dt date;

  cursor c1(p_assignment_id number) is
  select min(effective_start_date)
  from per_all_assignments_f
  where assignment_id = p_assignment_id;

cursor csr_last_dt is
---removed nvl from query, now returns null when no payroll run bug#9612944
 Select  max(ppa.date_earned)
     from pay_assignment_actions     paa,
          per_all_assignments_f      paf,
          pay_payroll_actions        ppa
     where paf.assignment_id = p_assignment_id
     and (paf.effective_end_date >= l_asg_start_date
           and paf.effective_start_date <= hr_general.end_of_time)
     and paa.assignment_id = paf.assignment_id
     and ppa.payroll_action_id = paa.payroll_action_id
     and ppa.effective_date +0 between
                 greatest(l_asg_start_date,paf.effective_start_date)
             and least(hr_general.end_of_time,paf.effective_end_date)
     and ((nvl(paa.run_type_id, ppa.run_type_id) is null and
           paa.source_action_id is null)
       or (nvl(paa.run_type_id, ppa.run_type_id) is not null and
           paa.source_action_id is not null ))
    and ppa.action_type in ('R','Q');

begin

l_last_payroll_dt :=null;

  open c1(p_assignment_id);
  fetch c1 into l_asg_start_date;
  close c1;
  --

  OPEN  csr_last_dt;
  FETCH csr_last_dt INTO l_last_payroll_dt;
  CLOSE csr_last_dt;
  --
 return l_last_payroll_dt;

end;

   Function get_previous_salary(p_assignment_id IN NUMBER,p_proposal_id in number)
   return number
   is
 l_previous_salary per_pay_proposals.proposed_salary_n%TYPE;
 CURSOR previous_pay is
      select pro.proposed_salary_n
      from per_pay_proposals pro
      where pro.assignment_id = p_assignment_id
      and pro.change_date =(select max(pro2.change_date)
                                  from per_pay_proposals pro2
                                  where pro2.assignment_id = p_assignment_id
                                  and pro2.change_date < (select change_date from per_pay_proposals
                            where pay_proposal_id =p_proposal_id));
   begin
    OPEN previous_pay;
    FETCH previous_pay into l_previous_salary;
    IF previous_pay%NOTFOUND then
     l_previous_salary := -1;
    end if;
    CLOSE previous_pay;
    return l_previous_salary;
   end get_previous_salary;




FUNCTION get_proposed_salary (p_assignment_id IN NUMBER,p_effective_date IN DATE )
RETURN NUMBER
is
l_salary per_pay_proposals.proposed_salary_n%TYPE;

cursor csr_sal is
    select proposed_salary_n
from per_pay_proposals
where assignment_id = p_assignment_id
and p_effective_date between nvl(change_date,hr_general.start_of_time) and nvl(date_to,hr_general.end_of_time);
begin
open csr_sal;
fetch csr_sal into l_salary;
close csr_sal;
RETURN l_salary;
END get_proposed_salary;


FUNCTION GET_ANNUALIZATION_FACTOR(p_assignment_id  NUMBER,p_effective_date DATE)
RETURN number
IS
l_dummy VARCHAR2(30);
l_pay_basis VARCHAR2(30);
l_pay_basis_id NUMBER;
l_pay_annualization_factor NUMBER;

  CURSOR c_pay_basis is
  SELECT PAF.PAY_BASIS_ID
  FROM PER_ALL_ASSIGNMENTS_F PAF
  WHERE PAF.ASSIGNMENT_ID=p_assignment_id
  AND p_effective_date  BETWEEN
  PAF.EFFECTIVE_START_DATE AND
  PAF.EFFECTIVE_END_DATE;

  CURSOR Currency IS
  SELECT HR_GENERAL.DECODE_LOOKUP('PAY_BASIS',PPB.PAY_BASIS)
  ,PPB.PAY_ANNUALIZATION_FACTOR
  FROM PAY_ELEMENT_TYPES_F PET
  ,PAY_INPUT_VALUES_F       PIV
  ,PER_PAY_BASES            PPB
  WHERE PPB.PAY_BASIS_ID=L_PAY_BASIS_ID
  AND PPB.INPUT_VALUE_ID=PIV.INPUT_VALUE_ID
  AND p_effective_date  BETWEEN
  PIV.EFFECTIVE_START_DATE AND
  PIV.EFFECTIVE_END_DATE
  AND PIV.ELEMENT_TYPE_ID=PET.ELEMENT_TYPE_ID
  AND p_effective_date  BETWEEN
  PET.EFFECTIVE_START_DATE AND
  PET.EFFECTIVE_END_DATE;

  CURSOR payroll is
  select tpt.number_per_fiscal_year
  from pay_all_payrolls_f prl
  ,    per_all_assignments_f paf
  ,    per_time_period_types tpt
  where paf.assignment_id=p_assignment_id
  and p_effective_date between paf.effective_start_date
      and paf.effective_end_date
  and paf.payroll_id=prl.payroll_id
  and p_effective_date between prl.effective_start_date
      and prl.effective_end_date
  and prl.period_type = tpt.period_type(+);


BEGIN

    open c_pay_basis;
    fetch c_pay_basis into l_pay_basis_id;
    close c_pay_basis;

    open Currency;
    fetch Currency
    into l_pay_basis
   ,l_pay_annualization_factor;
    close Currency;

    if(l_pay_basis ='Period Salary' and l_pay_annualization_factor is null) then
    open payroll;
    fetch payroll
    into l_pay_annualization_factor;
    close payroll;
    end if;

return l_pay_annualization_factor;
END GET_ANNUALIZATION_FACTOR;




FUNCTION get_grade (p_assignment_id IN NUMBER,p_effective_date IN DATE )
RETURN VARCHAR2
is
l_grade per_grades_vl.name%type :=null ;

cursor csr_grade is
    select HR_GENERAL.DECODE_GRADE(paa.grade_id) as grade
  from per_all_assignments_f paa
where paa.assignment_id = p_assignment_id
and p_effective_date between paa.effective_start_date and paa.effective_end_date;
begin
open csr_grade;
fetch csr_grade into l_grade;
close csr_grade;
RETURN l_grade;
END get_grade;


FUNCTION get_grade_currency (p_grade_id  in number,p_rate_id in number,p_effective_date in date,p_business_group_id in number )
RETURN VARCHAR2
is
l_grade_currency pay_grade_rules_f.currency_code%type :=null ;

cursor csr_grade_currency is
       select grdrule.currency_code
   from pay_grade_rules_f grdrule
   where grdrule.rate_id  = p_rate_id
   and   grdrule.grade_or_spinal_point_id = p_grade_id
   and   p_effective_date between grdrule.effective_start_date
                  and grdrule.effective_end_date;
begin
open csr_grade_currency;
fetch csr_grade_currency into l_grade_currency;
close csr_grade_currency;

if(l_grade_currency is null) then
l_grade_currency := hr_general.DEFAULT_CURRENCY_CODE(p_business_group_id);
end if;

RETURN l_grade_currency;
END get_grade_currency;




FUNCTION get_basis_currency_code (p_assignment_id IN NUMBER,p_effective_date IN DATE )
RETURN VARCHAR2
is
l_currency varchar2(100):=null ;
cursor csr_currency is
        select pet.input_currency_code as currency_code
    from per_pay_bases ppb
      ,pay_input_values_f piv
      ,pay_element_types_f pet
      ,per_all_assignments_f paa
    where paa.pay_basis_id = ppb.pay_basis_id
    and   ppb.input_value_id = piv.input_value_id
    and   piv.element_type_id = pet.element_type_id
    and   paa.assignment_id = p_assignment_id
    and   p_effective_date between nvl(paa.effective_start_date,hr_general.start_of_time) and nvl(paa.effective_end_date,hr_general.end_of_time)
    and  p_effective_date between nvl(pet.effective_start_date,hr_general.start_of_time) and nvl(pet.effective_end_date,hr_general.end_of_time)
    and  p_effective_date between nvl(piv.effective_start_date,hr_general.start_of_time) and nvl(piv.effective_end_date,hr_general.end_of_time);
begin
open csr_currency;
fetch csr_currency into l_currency;
close csr_currency;
RETURN l_currency;
END get_basis_currency_code;



FUNCTION get_pay_basis_frequency (p_assignment_id IN NUMBER,p_lookup_type IN varchar2,p_lookup_code IN varchar2,p_effective_date IN date )
RETURN VARCHAR2
is
l_pay_basis varchar2(100):=null;
cursor csr_lookup is
        select description
        from    hr_lookups
        where   lookup_type     = p_lookup_type
        and     lookup_code     = p_lookup_code;
cursor csr_table is
    select description
    from pay_all_payrolls_f pap
    ,per_all_assignments_f paa
    ,hr_lookups
    where pap.payroll_id = paa.payroll_id
    and paa.assignment_id =  p_assignment_id
        and p_effective_date between paa.effective_start_date and paa.effective_end_date
    and meaning = pap.period_type
    and lookup_type = 'PROC_PERIOD_TYPE';
cursor csr_period_table is
        select nvl(DESCRIPTION,ptt.period_type)
        from PER_TIME_PERIOD_TYPES ptt
        ,pay_all_payrolls_f pap
    ,per_all_assignments_f paa
    where pap.payroll_id = paa.payroll_id
    and paa.assignment_id =  p_assignment_id
        and p_effective_date between paa.effective_start_date and paa.effective_end_date
        and ptt.period_type = pap.period_type;
begin
if p_lookup_type is not null and p_lookup_code is not null and p_lookup_code = 'PERIOD' then
open csr_table;
fetch csr_table into l_pay_basis;
close csr_table;
    if l_pay_basis is null then
    open csr_period_table;
    fetch csr_period_table into l_pay_basis;
    close csr_period_table;
    end if;
else if p_lookup_type is not null and p_lookup_code is not null and p_lookup_code <> 'PERIOD' then
open csr_lookup;
fetch csr_lookup into l_pay_basis;
close csr_lookup;
end if;
end if;
RETURN l_pay_basis;
END get_pay_basis_frequency;

    FUNCTION get_pay_annualization_factor (p_assignment_id IN NUMBER, p_effective_date IN DATE, p_annualization_factor IN NUMBER, p_pay_basis IN VARCHAR2)
    return NUMBER
    is
    l_dummy pay_all_payrolls_f.payroll_name%type;
    l_annualization_factor NUMBER(20);
    Begin
    l_annualization_factor := p_annualization_factor;
    if(p_pay_basis ='PERIOD' and l_annualization_factor is null) then
     PER_PAY_PROPOSALS_POPULATE.GET_PAYROLL(p_assignment_id
                       ,p_effective_date
                       ,l_dummy
                       ,l_annualization_factor);
    end if;

    if(l_annualization_factor = 0) THEN
    l_annualization_factor := 1;
    end if;

    return l_annualization_factor;
    END get_pay_annualization_factor;


FUNCTION get_lookup_desc ( p_lookup_type   varchar2,p_lookup_code   varchar2)
return varchar2
is
cursor csr_lookup is
        select description
        from    hr_lookups
        where   lookup_type     = p_lookup_type
        and     lookup_code     = p_lookup_code;
v_description       varchar2(100) := null;
begin
if p_lookup_type is not null and p_lookup_code is not null then
open csr_lookup;
fetch csr_lookup into v_description;
close csr_lookup;
end if;
return v_description;
end get_lookup_desc;

   FUNCTION decode_grade_ladder (p_grade_ladder_id IN NUMBER, p_effective_date IN DATE)
   return varchar2
   is

    cursor csr_lookup is
         select    name
         from      ben_pgm_f pgm
         where     pgm_id      = p_grade_ladder_id
         and       p_effective_date between
                   pgm.effective_start_date and pgm.effective_end_date;

    v_meaning          varchar2(240) := null;

    begin

    if p_grade_ladder_id is not null then

  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;

    end if;
    return v_meaning;
    end decode_grade_ladder;


 FUNCTION get_fte (p_assignment_id IN NUMBER, p_effective_date IN DATE)
      RETURN NUMBER IS
l_fte number;
cursor c1(p_assignment_id number, p_effective_date date) is
select abv.value
from per_assignment_budget_values_f abv, per_all_assignments_f asg,
per_assignment_status_types ast
where asg.assignment_id = p_assignment_id
and abv.assignment_id = asg.assignment_id
and asg.assignment_type in ('E', 'C')
and abv.unit = 'FTE'
and p_effective_date between asg.effective_start_date and asg.effective_end_date
and p_effective_date between abv.effective_start_date and abv.effective_end_date
and asg.assignment_status_type_id = ast.assignment_status_type_id
and ast.per_system_status <> 'TERM_ASSIGN';
--
begin
  open c1(p_assignment_id, p_effective_date);
  fetch c1 into l_fte;
  close c1;
  return l_fte;
end;

   FUNCTION get_annual_salary (
      p_proposed_salary   IN   NUMBER,
      p_assignment_id     IN   NUMBER,
      p_change_date       IN   DATE
   )
      RETURN NUMBER
   IS
      l_annualization_factor   per_pay_bases.pay_annualization_factor%TYPE;

      CURSOR csr_annualization_factor
      IS
         SELECT ppb.pay_annualization_factor
           FROM per_all_assignments_f paaf, per_pay_bases ppb
          WHERE paaf.assignment_id = p_assignment_id
            AND p_change_date BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
            AND ppb.pay_basis_id = paaf.pay_basis_id;
   BEGIN
      OPEN csr_annualization_factor;

      FETCH csr_annualization_factor
       INTO l_annualization_factor;

      CLOSE csr_annualization_factor;

      RETURN p_proposed_salary * l_annualization_factor;
   END get_annual_salary;

   FUNCTION get_currency (p_assignment_id IN NUMBER, p_change_date IN DATE)
      RETURN VARCHAR2
   IS
      l_currency   pay_element_types_f.input_currency_code%TYPE;

      CURSOR currency
      IS
         SELECT pet.input_currency_code
           FROM pay_element_types_f pet,
                per_all_assignments_f paaf,
                pay_input_values_f piv,
                per_pay_bases ppb
          WHERE paaf.assignment_id = p_assignment_id
            AND p_change_date BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
            AND ppb.pay_basis_id = paaf.pay_basis_id
            AND ppb.input_value_id = piv.input_value_id
            AND p_change_date BETWEEN piv.effective_start_date
                                  AND piv.effective_end_date
            AND piv.element_type_id = pet.element_type_id
            AND p_change_date BETWEEN pet.effective_start_date
                                  AND pet.effective_end_date;

        Cursor decode_Currency is
        Select Name
        from Fnd_Currencies_Vl
         Where Currency_Code = l_currency;
         --  and Enabled_Flag = 'Y';  -- 5579090

        P_Currency_name Fnd_Currencies_Vl.Name%TYPE := NULL;


   BEGIN
      OPEN currency;

      FETCH currency
       INTO l_currency;

      CLOSE currency;

        If l_currency is Not Null then
           open decode_Currency;
           Fetch decode_Currency into P_Currency_name;
           Close decode_Currency;
        End If;

      RETURN P_Currency_name;
   END get_currency;

FUNCTION get_currency_format (p_assignment_id IN NUMBER, p_change_date IN DATE)
      RETURN VARCHAR2
   IS
      l_currency pay_element_types_f.input_currency_code%TYPE;
      l_uom varchar2(20);
      l_five_curr pay_element_types_f.input_currency_code%TYPE;

      CURSOR currency
      IS
         SELECT pet.input_currency_code,piv.uom
           FROM pay_element_types_f pet,
                per_all_assignments_f paaf,
                pay_input_values_f piv,
                per_pay_bases ppb
          WHERE paaf.assignment_id = p_assignment_id
            AND p_change_date BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
            AND ppb.pay_basis_id = paaf.pay_basis_id
            AND ppb.input_value_id = piv.input_value_id
            AND p_change_date BETWEEN piv.effective_start_date
                                  AND piv.effective_end_date
            AND piv.element_type_id = pet.element_type_id
            AND p_change_date BETWEEN pet.effective_start_date
                                  AND pet.effective_end_date;

        Cursor five_curr is
        Select CURRENCY_CODE
        from Fnd_Currencies_Vl
         Where PRECISION = 5
         and rownum = 1;

        P_Currency_name Fnd_Currencies_Vl.Name%TYPE := NULL;
   BEGIN
      OPEN currency;
      FETCH currency INTO l_currency,l_uom;
      CLOSE currency;

        If l_uom <> 'M' then
              OPEN five_curr;
              FETCH five_curr INTO l_five_curr;
              CLOSE five_curr;
                  l_currency := l_five_curr;
        End If;

      RETURN l_currency;
   END get_currency_format;




   FUNCTION get_pay_basis (p_assignment_id IN NUMBER, p_change_date IN DATE)
      RETURN VARCHAR2
   IS
      l_pay_basis   per_pay_bases.NAME%TYPE;

      CURSOR csr_pay_basis
      IS
         SELECT ppb.NAME
           FROM per_all_assignments_f paaf, per_pay_bases ppb
          WHERE paaf.assignment_id = p_assignment_id
            AND p_change_date BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
            AND ppb.pay_basis_id = paaf.pay_basis_id;
   BEGIN
      OPEN csr_pay_basis;

      FETCH csr_pay_basis
       INTO l_pay_basis;

      CLOSE csr_pay_basis;

      RETURN l_pay_basis;
   END get_pay_basis;

   FUNCTION get_change_amount (p_assignment_id IN NUMBER,
                                p_proposal_id IN NUMBER,
                                p_proposed_salary in number)
      RETURN NUMBER
   IS
   l_previous_salary per_pay_proposals.proposed_salary_n%TYPE;
   BEGIN
      l_previous_salary:= get_previous_salary(p_assignment_id,p_proposal_id);
      if l_previous_salary = -1 then
       return p_proposed_salary;
      else
      return p_proposed_salary - l_previous_salary;
      end if;
   END get_change_amount;

   FUNCTION get_change_percent (p_assignment_id IN NUMBER,
                                p_proposal_id IN NUMBER,
                                p_proposed_salary in number)
      RETURN NUMBER
      is
      l_change_amount number;
 l_previous_salary per_pay_proposals.proposed_salary_n%TYPE;

   BEGIN
         l_change_amount:= get_change_amount (p_assignment_id ,p_proposal_id ,p_proposed_salary);
         l_previous_salary :=get_previous_salary(p_assignment_id,p_proposal_id);
         if l_previous_salary = -1 then
            return null;
         else
          return round((l_change_amount*100/l_previous_salary),6);
         end if;
   END get_change_percent;

--
--
-- Procedure CHECK_LENGTH is used for rounding off the Salary according to currency format
-- This procedure calculate the new salary value for the changed pay basis.
--
--

  PROCEDURE CHECK_LENGTH(p_amount        IN OUT NOCOPY NUMBER
                        ,p_uom           IN     VARCHAR2
                        ,p_currcode      IN     VARCHAR2) IS

  L_PRECISION NUMBER;
  L_EXT_PRECISION NUMBER;
  L_MIN_ACCT_UNIT NUMBER;

  BEGIN
  if(p_uom='M') then
    fnd_currency.get_info(currency_code => p_currcode
                         ,precision     => L_PRECISION
                         ,EXT_PRECISION => L_EXT_PRECISION
                         ,MIN_ACCT_UNIT => L_MIN_ACCT_UNIT);
    p_amount:=round(p_amount,l_precision);
  else
    p_amount:=round(p_amount,5);
  end if;
  END CHECK_LENGTH;

------
----------called from core HR on Criteria change
-------
procedure handle_asg_crit_change
            (p_assignment_id     in number,
             p_effective_date    in date)
is

l_creator_id number;
l_proposal_rec per_pay_proposals%ROWTYPE;
l_date_to date;

  l_component_id            per_pay_proposal_components.component_id%TYPE;
  l_object_version_number   per_pay_proposal_components.object_version_number%TYPE;
  l_proposal_comp_rec       per_pay_proposal_components%ROWTYPE;

  l_pay_proposal_id            NUMBER;
  l_ovn                        NUMBER;
  l_inv_next_sal_date_warning  BOOLEAN;
  l_inv_next_perf_date_warning BOOLEAN;
  l_proposed_salary_warning    BOOLEAN;
  l_approved_warning           BOOLEAN;
  l_payroll_warning            BOOLEAN;
  l_element_entry_id           NUMBER;


Cursor csr_creator_id is
select CREATOR_ID,
        effective_end_date
from pay_element_entries_f
where ASSIGNMENT_ID=p_assignment_id
and effective_start_date=p_effective_date
and creator_type='SP';

cursor csr_pay_proposal(c_assignment_id in number,c_pay_proposal_id in number)  is
select * from per_pay_proposals
where ASSIGNMENT_ID=c_assignment_id
and pay_proposal_id=c_pay_proposal_id;

cursor csr_proposal_components(c_pay_proposal_id in number) is
select * from per_pay_proposal_components
where pay_proposal_id=c_pay_proposal_id;

begin

---
hr_utility.set_location('Entering PER_SALADMIN_UTILITY.handle_asg_crit_change ',1);
--
hr_utility.set_location('p_assignment_id ='||to_char(p_assignment_id),5);
hr_utility.set_location('p_effective_date ='||p_effective_date,5);
--get the element entry details that's created on p_effective_date
--because of change in element link
open csr_creator_id;
fetch csr_creator_id into l_creator_id,l_date_to;

IF csr_creator_id%FOUND then
hr_utility.set_location('l_creator_id ='||to_char(l_creator_id),10);
---get prev pay proposal details
open csr_pay_proposal(p_assignment_id,l_creator_id);
fetch csr_pay_proposal into l_proposal_rec;

---if the pay proposal exists and has a different change date then
---create a new pay proposal
if csr_pay_proposal%found and l_proposal_rec.change_date <> p_effective_date then

        ----insert a new proposal and update the creator id
        hr_utility.set_location('Insert a new proposal:p_effective_date:'||p_effective_date,15);

hr_maintain_proposal_api.insert_salary_proposal
                    (p_pay_proposal_id            => l_pay_proposal_id
                    ,p_assignment_id              => p_assignment_id
                    ,p_business_group_id          => l_proposal_rec.business_group_id
                    ,p_change_date                => p_effective_date
                    ,p_comments                   => l_proposal_rec.comments
                    ,p_next_sal_review_date       => l_proposal_rec.review_date
                    ,p_proposal_reason            => l_proposal_rec.proposal_reason
                    ,p_proposed_salary_n          => l_proposal_rec.proposed_salary_n
                    ,p_forced_ranking             => l_proposal_rec.forced_ranking
                    ,p_performance_review_id      => l_proposal_rec.performance_review_id
                    ,p_attribute_category         => l_proposal_rec.attribute_category
                    ,p_attribute1                 => l_proposal_rec.attribute1
                    ,p_attribute2                 => l_proposal_rec.attribute2
                    ,p_attribute3                 => l_proposal_rec.attribute3
                    ,p_attribute4                 => l_proposal_rec.attribute4
                    ,p_attribute5                 => l_proposal_rec.attribute5
                    ,p_attribute6                 => l_proposal_rec.attribute6
                    ,p_attribute7                 => l_proposal_rec.attribute7
                    ,p_attribute8                 => l_proposal_rec.attribute8
                    ,p_attribute9                 => l_proposal_rec.attribute9
                    ,p_attribute10                => l_proposal_rec.attribute10
                    ,p_attribute11                => l_proposal_rec.attribute11
                    ,p_attribute12                => l_proposal_rec.attribute12
                    ,p_attribute13                => l_proposal_rec.attribute13
                    ,p_attribute14                => l_proposal_rec.attribute14
                    ,p_attribute15                => l_proposal_rec.attribute15
                    ,p_attribute16                => l_proposal_rec.attribute16
                    ,p_attribute17                => l_proposal_rec.attribute17
                    ,p_attribute18                => l_proposal_rec.attribute18
                    ,p_attribute19                => l_proposal_rec.attribute19
                    ,p_attribute20                => l_proposal_rec.attribute20
                    ,p_object_version_number      => l_ovn
                    ,p_multiple_components        => l_proposal_rec.multiple_components
                    ,p_approved                   => 'Y'
                    ,p_validate                   => FALSE
                    ,p_element_entry_id           => l_element_entry_id
                    ,p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning
                    ,p_proposed_salary_warning    => l_proposed_salary_warning
                    ,p_approved_warning           => l_approved_warning
                    ,p_payroll_warning            => l_payroll_warning
                    ,p_date_to                    => l_date_to
                    );

---if the pay proposal is created then
---create components if they exit for prevous propsoal
if l_pay_proposal_id is not null and l_proposal_rec.multiple_components='Y' then

open csr_proposal_components(l_proposal_rec.pay_proposal_id);
loop
fetch csr_proposal_components into l_proposal_comp_rec;
exit when csr_proposal_components%notfound;
---------create components
hr_maintain_proposal_api.insert_proposal_component(
  p_component_id                => 	  l_component_id
  ,p_pay_proposal_id             =>    l_pay_proposal_id
  ,p_business_group_id           =>	  l_proposal_comp_rec.business_group_id
  ,p_approved                    =>	  l_proposal_comp_rec.approved
  ,p_component_reason            =>	  l_proposal_comp_rec.component_reason
  ,p_change_amount_n             =>	  l_proposal_comp_rec.change_amount_n
  ,p_change_percentage           =>	  l_proposal_comp_rec.change_percentage
  ,p_comments                    =>	  l_proposal_comp_rec.comments
  ,p_attribute_category          =>	  l_proposal_comp_rec.attribute_category
  ,p_attribute1                  =>	  l_proposal_comp_rec.attribute1
  ,p_attribute2                  =>	  l_proposal_comp_rec.attribute2
  ,p_attribute3                  =>	  l_proposal_comp_rec.attribute3
  ,p_attribute4                  =>	  l_proposal_comp_rec.attribute4
  ,p_attribute5                  =>	  l_proposal_comp_rec.attribute5
  ,p_attribute6                  =>	  l_proposal_comp_rec.attribute6
  ,p_attribute7                  =>	  l_proposal_comp_rec.attribute7
  ,p_attribute8                  =>	  l_proposal_comp_rec.attribute8
  ,p_attribute9                  =>	  l_proposal_comp_rec.attribute9
  ,p_attribute10                 =>	  l_proposal_comp_rec.attribute10
  ,p_attribute11                 =>	  l_proposal_comp_rec.attribute11
  ,p_attribute12                 =>	  l_proposal_comp_rec.attribute12
  ,p_attribute13                 =>	  l_proposal_comp_rec.attribute13
  ,p_attribute14                 =>	  l_proposal_comp_rec.attribute14
  ,p_attribute15                 =>	  l_proposal_comp_rec.attribute15
  ,p_attribute16                 =>	  l_proposal_comp_rec.attribute16
  ,p_attribute17                 =>	  l_proposal_comp_rec.attribute17
  ,p_attribute18                 =>	  l_proposal_comp_rec.attribute18
  ,p_attribute19                 =>	  l_proposal_comp_rec.attribute19
  ,p_attribute20                 =>	  l_proposal_comp_rec.attribute20
  ,p_validation_strength         =>	  null
  ,p_object_version_number       =>	  l_object_version_number
  ,p_validate                    =>	  false
  );
end loop;
close csr_proposal_components;

end if; ---components exist

end if;----proposal to be created

close csr_pay_proposal;  --bug#9222493

end if; ----element entry found


close csr_creator_id;

--
--
hr_utility.set_location('Leaving PER_SALADMIN_UTILITY.handle_asg_crit_change ',100);
--
hr_utility.trace_off;
EXCEPTION
  WHEN others THEN
  --
  hr_utility.set_location('Exception: PER_SALADMIN_UTILITY.handle_asg_crit_change',120);
  raise;
  --
end;


--
--
-- Procedure get_sal_on_basis_chg is called from the assignment form when the pay basis id is changed.
-- This procedure calculate the new salary value for the changed pay basis.
--
--
PROCEDURE get_sal_on_basis_chg
         (p_assignment_id     in number,
          p_new_pay_basis_id  in number,
          p_effective_date    in date,
          p_old_pay_basis_id  in number,
          p_curr_payroll_id   in number)
IS

  l_change number;
  l_new    number;
  l_percent number;
  l_comps  VARCHAR2(1);

  l_pay_basis VARCHAR2(30);
  l_old_currency VARCHAR2(15);
  l_salary_basis_name VARCHAR2(30);
  l_pay_basis_name VARCHAR2(80);
  l_old_pay_annualization_factor NUMBER;
  l_grade_annualization_factor NUMBER;
  l_grade VARCHAR2(240);
  l_prev_salary NUMBER;
  l_element_entry_id NUMBER;
  l_uom VARCHAR2(30);

  l_prev_change_date DATE;
  l_prev_annual_salary number;
  --
  l_currency_rate  NUMBER;
  l_cannual_amount NUMBER;
  l_new_pay_annual_factor NUMBER;
  l_new_currency VARCHAR2(15);
  l_new_annual_salary NUMBER;
  l_new_uom VARCHAR2(15);
  l_rec                       per_pay_proposals%ROWTYPE;
--
-- Cursor to get the pay proposal details
--
  cursor get_prop_det (c_assignment_id in number,c_pay_basis_id in number) is
   select * from per_pay_proposals pro
   where pro.assignment_id = c_assignment_id
    and  (p_effective_date - 1) between change_date and nvl(date_to,to_date('31/12/4712','dd/mm/yyyy'));
--   and pro.pay_proposal_id = c_pay_basis_id;
--
Cursor csr_new_pb_details(L_PAY_BASIS_ID in number) is
 SELECT PET.INPUT_CURRENCY_CODE
, PPB.PAY_BASIS
, PPB.PAY_ANNUALIZATION_FACTOR
,PIV.UOM
  FROM PAY_ELEMENT_TYPES_F PET
, PAY_INPUT_VALUES_F       PIV
, PER_PAY_BASES            PPB
  WHERE PPB.PAY_BASIS_ID=L_PAY_BASIS_ID
  AND PPB.INPUT_VALUE_ID=PIV.INPUT_VALUE_ID
  AND p_effective_date  BETWEEN PIV.EFFECTIVE_START_DATE AND PIV.EFFECTIVE_END_DATE
  AND PIV.ELEMENT_TYPE_ID=PET.ELEMENT_TYPE_ID
  AND p_effective_date  BETWEEN PET.EFFECTIVE_START_DATE AND PET.EFFECTIVE_END_DATE;
--
Cursor csr_payroll_freq is
  select tpt.number_per_fiscal_year
  from pay_all_payrolls_f prl ,
      per_time_period_types tpt
  where prl.payroll_id = p_curr_payroll_id
  and p_effective_date between prl.effective_start_date and prl.effective_end_date
  and prl.period_type = tpt.period_type(+);
--
begin
--
hr_utility.set_location('Entering PER_SALADMIN_UTILITY.get_sal_on_basis_chg',10);
--
l_change:=null;
l_new:=null;
l_comps:='N'; --:REVIEW.MULTIPLE_COMPONENTS;
l_percent:= 0;
--
-- Fetch the details of the old pay proposal
--
hr_utility.set_location('p_old_pay_basis_id ='||to_char(p_old_pay_basis_id),11);
hr_utility.set_location('p_new_pay_basis_id ='||to_char(p_new_pay_basis_id),11);
--
open get_prop_det(p_assignment_id,p_old_pay_basis_id);
fetch get_prop_det into l_rec;
close get_prop_det;
--
-- Execute foll code only if a valid pay proposal exists of validation date.
--
If l_rec.pay_proposal_id is not null then
--
-- Get the old proposal date and salary
--
l_prev_change_date := l_rec.change_date +1;
l_prev_salary := l_rec.proposed_salary_n;
--
hr_utility.set_location('Prev change date= '||to_char(l_prev_change_date,'dd/mm/yyyy'),12);
hr_utility.set_location('l_prev_salary = '||to_char(l_prev_salary),13);
--
--Calculate  the currency and pay_annualization_factor of the old salary basis
--
PER_PAY_PROPOSALS_POPULATE.GET_BASIS_DETAILS
                             (p_effective_date             => l_prev_change_date
                             ,p_assignment_id              => p_assignment_id
                             ,p_currency                   => l_old_currency
                             ,p_salary_basis_name          => l_salary_basis_name
                             ,p_pay_basis_name             => l_pay_basis_name
                             ,p_pay_basis                  => l_pay_basis
                             ,p_pay_annualization_factor   => l_old_pay_annualization_factor
                             ,p_grade_basis                => l_grade
                             ,p_grade_annualization_factor => l_grade_annualization_factor
                             ,p_element_type_id            => l_element_entry_id
                             ,p_uom                        => l_uom);
hr_utility.set_location('l_old_currency = '||l_old_currency,13);
hr_utility.set_location('l_salary_basis_name = '||l_salary_basis_name,13);
hr_utility.set_location('l_pay_basis_name = '||l_pay_basis_name,13);
hr_utility.set_location('l_pay_basis = '||l_pay_basis,13);
hr_utility.set_location('l_old_pay_annualization_factor = '||to_char(l_old_pay_annualization_factor),13);
hr_utility.set_location('l_grade = '||l_grade,13);
hr_utility.set_location('l_grade_annualization_factor = '||to_char(l_grade_annualization_factor),13);
hr_utility.set_location('l_element_entry_id = '||to_char(l_element_entry_id),13);
hr_utility.set_location('l_uom = '||l_uom,13);
--
--
--Calculate  the currency and pay_annualization_factor of the new salary basis
--
Open csr_new_pb_details(p_new_pay_basis_id);
Fetch csr_new_pb_details into l_new_currency,l_pay_basis,l_new_pay_annual_factor,l_new_uom;
Close csr_new_pb_details;
--
hr_utility.set_location('l_new_currency = '||l_new_currency,13);
hr_utility.set_location('l_pay_basis = '||l_pay_basis,13);
hr_utility.set_location('l_new_pay_annual_factor = '||to_char(l_new_pay_annual_factor),13);
--
if(l_pay_basis ='PERIOD' and l_new_pay_annual_factor is null) then
  --
  hr_utility.set_location('Fetching Payroll frequency',13);
  --
  l_new_pay_annual_factor := 1;
  --
  open csr_payroll_freq;
  Fetch csr_payroll_freq into l_new_pay_annual_factor;
  Close csr_payroll_freq;
end if;
--
hr_utility.set_location('l_new_pay_annual_factor = '||to_char(l_new_pay_annual_factor),13);
/**
PER_PAY_PROPOSALS_POPULATE.GET_BASIS_DETAILS
                             (p_effective_date             => p_effective_date
                             ,p_assignment_id              => p_assignment_id
                             ,p_currency                   => l_new_currency
                             ,p_salary_basis_name          => l_salary_basis_name
                             ,p_pay_basis_name             => l_pay_basis_name
                             ,p_pay_basis                  => l_pay_basis
                             ,p_pay_annualization_factor   => l_new_pay_annualization_factor
                             ,p_grade_basis                => l_grade
                             ,p_grade_annualization_factor => l_grade_annualization_factor
                             ,p_element_type_id            => l_element_entry_id
                             ,p_uom                        => l_uom);
hr_utility.set_location('l_new_currency = '||l_new_currency,13);
hr_utility.set_location('l_salary_basis_name = '||l_salary_basis_name,13);
hr_utility.set_location('l_pay_basis_name = '||l_pay_basis_name,13);
hr_utility.set_location('l_pay_basis = '||l_pay_basis,13);
hr_utility.set_location('l_new_pay_annualization_factor = '||to_char(l_new_pay_annualization_factor),13);
hr_utility.set_location('l_grade = '||l_grade,13);
hr_utility.set_location('l_grade_annualization_factor = '||to_char(l_grade_annualization_factor),13);
hr_utility.set_location('l_element_entry_id = '||to_char(l_element_entry_id),13);
hr_utility.set_location('l_uom = '||l_uom,13);
**/
--
--
-- Calculate Old Annual amt and New Salary
--
if l_old_pay_annualization_factor = 0 then
l_old_pay_annualization_factor := 1;
end if;

if l_new_pay_annual_factor = 0 then
l_new_pay_annual_factor := 1;
end if;



l_prev_annual_salary := l_prev_salary * l_old_pay_annualization_factor;
l_new := (l_prev_salary * l_old_pay_annualization_factor)/l_new_pay_annual_factor;
--
hr_utility.set_location('l_prev_annual_salary = '||to_char(l_prev_annual_salary),14);
hr_utility.set_location('l_new = '||to_char(l_new),15);
--
-- If there is a new salary value and currencies of the old and new salary basis do not match, do a
-- currency conversion of the new value.
--
l_currency_rate := 1;
IF l_new IS NOT NULL THEN
   --
   if l_old_currency <> l_new_currency AND l_old_currency IS NOT NULL AND l_new_currency IS NOT NULL THEN
   --
      l_currency_rate := get_currency_rate(
                p_from_currency   => l_old_currency,
                p_to_currency     => l_new_currency,
                p_conversion_date => p_effective_date,
                p_business_group_id => l_rec.business_group_id);
   --
   End if;
   --
End if;
--
hr_utility.set_location('Currency rate = '||to_char(l_currency_rate),16);
l_new  := l_currency_rate * l_new;
hr_utility.set_location('Converted rate = '||to_char(l_new),20);
--
--
if l_new_uom is null then
l_new_uom := 'M';
end if;

    CHECK_LENGTH(l_new
                ,l_new_uom
                ,l_new_currency);

----------------VKODEDAL 01-MAR-2007--------------------------------
--FIX 5857948 -DEFAULT NEW PROPOSAL REASON TO SALARY BASIS CHANGE ADJUSTMENT
 --
     -- check that the p_proposal_reason exists in hr_lookups.
     --
 --Fix 6417656 - if SALBASISCHG doens't exist set the default reason to null
     if hr_api.not_exists_in_hr_lookups
  (p_effective_date        => l_rec.change_date
   ,p_lookup_type           => 'PROPOSAL_REASON'
         ,p_lookup_code           => 'SALBASISCHG'
        ) then
        --   proposal_reason doesn't exist - set the reason to null
        hr_utility.set_location('proposal_reason set to null', 25);
        l_rec.proposal_reason :=null;
        else
        hr_utility.set_location('proposal_reason set to SALBASISCHG', 27);
        l_rec.proposal_reason := 'SALBASISCHG';

     end if;


------------------------------------------------
g_proposal_rec := l_rec;
g_new_sal_value := l_new;
--
End if;
--
hr_utility.set_location('Leaving PER_SALADMIN_UTILITY.get_sal_on_basis_chg ',100);
--
EXCEPTION
  WHEN others THEN
  --
  hr_utility.set_location('Exception: PER_SALADMIN_UTILITY.get_sal_on_basis_chg',100);
  g_proposal_rec := null;
  g_new_sal_value := null;
  raise;
  --
end;
--
/* This procedure is called from the assignment form to insert the new salary value after a pay basis change */
procedure insert_pay_proposal(p_assignment_id in number, p_validation_start_date in date) is

  l_pay_proposal_id            NUMBER;
  l_ovn                        NUMBER;
  l_inv_next_sal_date_warning  BOOLEAN;
  l_inv_next_perf_date_warning BOOLEAN;
  l_proposed_salary_warning    BOOLEAN;
  l_approved_warning           BOOLEAN;
  l_payroll_warning            BOOLEAN;
  l_approved                   VARCHAR2(1);
  l_element_entry_id           NUMBER;
  l_review_date                date;

begin
if g_new_sal_value is not null then

 hr_maintain_proposal_api.insert_salary_proposal
                    (p_pay_proposal_id            => l_pay_proposal_id
                    ,p_assignment_id              => p_assignment_id
                    ,p_business_group_id          => g_proposal_rec.business_group_id
                    ,p_change_date                => p_validation_start_date
                    ,p_comments                   => g_proposal_rec.comments
                    --,p_next_sal_review_date       => l_review_date
                    ,p_proposal_reason            => g_proposal_rec.proposal_reason
                    ,p_proposed_salary_n          => g_new_sal_value
                    ,p_forced_ranking             => g_proposal_rec.forced_ranking
                    ,p_performance_review_id      => g_proposal_rec.performance_review_id
                    ,p_attribute_category         => g_proposal_rec.attribute_category
                    ,p_attribute1                 => g_proposal_rec.attribute1
                    ,p_attribute2                 => g_proposal_rec.attribute2
                    ,p_attribute3                 => g_proposal_rec.attribute3
                    ,p_attribute4                 => g_proposal_rec.attribute4
                    ,p_attribute5                 => g_proposal_rec.attribute5
                    ,p_attribute6                 => g_proposal_rec.attribute6
                    ,p_attribute7                 => g_proposal_rec.attribute7
                    ,p_attribute8                 => g_proposal_rec.attribute8
                    ,p_attribute9                 => g_proposal_rec.attribute9
                    ,p_attribute10                => g_proposal_rec.attribute10
                    ,p_attribute11                => g_proposal_rec.attribute11
                    ,p_attribute12                => g_proposal_rec.attribute12
                    ,p_attribute13                => g_proposal_rec.attribute13
                    ,p_attribute14                => g_proposal_rec.attribute14
                    ,p_attribute15                => g_proposal_rec.attribute15
                    ,p_attribute16                => g_proposal_rec.attribute16
                    ,p_attribute17                => g_proposal_rec.attribute17
                    ,p_attribute18                => g_proposal_rec.attribute18
                    ,p_attribute19                => g_proposal_rec.attribute19
                    ,p_attribute20                => g_proposal_rec.attribute20
                    ,p_object_version_number      => l_ovn
                    ,p_multiple_components        => 'N' --g_proposal_rec.multiple_components  bug: 8939934
                    ,p_approved                   => 'Y'
                    ,p_validate                   => FALSE
                    ,p_element_entry_id           => l_element_entry_id
                    ,p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning
                    ,p_proposed_salary_warning    => l_proposed_salary_warning
                    ,p_approved_warning           => l_approved_warning
                    ,p_payroll_warning            => l_payroll_warning
                    ,p_date_to                    => g_proposal_rec.date_to  -- bug: 9288586
                    );
end if;

g_proposal_rec := null;
g_new_sal_value := null;

EXCEPTION
  WHEN others THEN
hr_utility.set_location('Exception: PER_SALADMIN_UTILITY.insert_pay_proposal',100);
g_proposal_rec := null;
g_new_sal_value := null;
raise;
end;

function get_currency_rate(
    p_from_currency   VARCHAR2,
    p_to_currency     VARCHAR2,
    p_conversion_date DATE,
        p_business_group_id number) return number is
l_conversion_date date;
l_conversion_type varchar2(80);
l_currency_rate number := 1;
begin
  if (p_conversion_date is not null) then
    l_conversion_date := p_conversion_date;
  else
    l_conversion_date := sysdate;
  end if;

  l_conversion_type := hr_currency_pkg.get_rate_type
                         (p_business_group_id,p_conversion_date,'P');
  if (l_conversion_type is not null) then
    l_currency_rate :=
       hr_currency_pkg.get_rate_sql
       (p_from_currency,
        p_to_currency ,
        l_conversion_date,
        l_conversion_type
       );
    If l_currency_rate < 0 then
       l_currency_rate := 1;
    End if;

  end if;
  --
  return l_currency_rate;
end;
-- --------------------------------------------------------------------------
-- |---------------------------< get_fte_factor >---------------------------|
-- --------------------------------------------------------------------------
FUNCTION get_fte_factor(p_assignment_id IN NUMBER
                       ,p_effective_date IN DATE)
return NUMBER IS

l_fte_profile_value VARCHAR2(240) := fnd_profile.VALUE('BEN_CWB_FTE_FACTOR');
l_fte_precision_value NUMBER;

CURSOR csr_fte_BFTE
IS
select nvl(value, 1) val
  from  per_assignment_budget_values_f
 where  assignment_id   = p_assignment_id
   and  unit = 'FTE'
   and  p_effective_date BETWEEN effective_start_date AND effective_end_date;
CURSOR csr_fte_BPFT
IS
select nvl(value, 1) val
 from  per_assignment_budget_values_f
where  assignment_id    = p_assignment_id
  and  unit = 'PFT'
  and p_effective_date BETWEEN effective_start_date AND effective_end_date;

l_fte_factor number := null;
l_norm_hours_per_year number;
l_hours_per_year number;
BEGIN
  --Bug 8226280 smadhuna FTE Factor Precision profile to be used for rounding
  BEGIN

    l_fte_precision_value := fnd_profile.VALUE('HR_FTE_PRECISION');

    IF l_fte_precision_value NOT IN ( 1,2,3,4,5,6,7,8,9 ) THEN
      l_fte_precision_value := NULL;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      l_fte_precision_value := NULL;
  END;
  --Bug 8226280
  if (l_fte_profile_value = 'NHBGWH') then

      PER_PAY_PROPOSALS_POPULATE.get_asg_hours(p_assignment_id
                    ,p_effective_date
                    ,l_hours_per_year);

      if(nvl(l_hours_per_year,0) <> 0) then
        PER_PAY_PROPOSALS_POPULATE.get_norm_hours(p_assignment_id
                    ,p_effective_date
                    ,l_norm_hours_per_year);
       if ( nvl(l_norm_hours_per_year,0) = 0) then
         l_fte_factor := 1;
       else
         l_fte_factor := l_hours_per_year/l_norm_hours_per_year;
       end if;
      else
        l_fte_factor := 1;
      end if;
  elsif (l_fte_profile_value = 'BFTE') then
    for r1 in csr_fte_BFTE loop
     l_fte_factor := r1.val;
    end loop;
  elsif (l_fte_profile_value = 'BPFT') then
    for r1 in csr_fte_BPFT loop
     l_fte_factor := r1.val;
    end loop;
  else
   l_fte_factor := 1;
  end if;
-- fte can be greater than 1 Bug#7497075 schowdhu
-- if (l_fte_factor is null or  l_fte_factor > 1) then
if (l_fte_factor is null) then
 l_fte_factor := 1;
end if;

--Bug 8226280
IF l_fte_precision_value IS NOT NULL THEN
  l_fte_factor := ROUND( l_fte_factor, l_fte_precision_value);
END IF;
--Bug 8226280

RETURN l_fte_factor;

END get_fte_factor;

Function asg_pay_proposal_starts_at(p_assignment_id IN NUMBER, p_date in date)
return varchar2 is
 l_dummy varchar2(10);
 CURSOR c_pay_proposals is
      select null
      from per_pay_proposals pro
      where pro.assignment_id = p_assignment_id
      and pro.change_date = p_date;
begin
    OPEN c_pay_proposals;
    FETCH c_pay_proposals into l_dummy;
    IF c_pay_proposals%FOUND then
      CLOSE c_pay_proposals;
      return('Y');
    end if;
    CLOSE c_pay_proposals;
    return ('N');
end asg_pay_proposal_starts_at;

Function get_initial_proposal_start(p_assignment_id IN NUMBER)
return date is
 l_min_change_date date;
 CURSOR c_pay_proposals is
      select min(change_date)
      from per_pay_proposals pro
      where pro.assignment_id = p_assignment_id;
begin
    OPEN c_pay_proposals;
    FETCH c_pay_proposals into l_min_change_date;
    IF c_pay_proposals%FOUND then
      CLOSE c_pay_proposals;
      return(l_min_change_date);
    end if;
    CLOSE c_pay_proposals;
    return (null);
end get_initial_proposal_start;

function get_assignment_fte(p_assignment_id number, p_effective_date date) return number is
l_fte number := 0;
cursor c1(p_assignment_id number, p_effective_date date) is
select nvl(abv.value,0)
from per_assignment_budget_values_f abv, per_all_assignments_f asg,
per_assignment_status_types ast
where asg.assignment_id = p_assignment_id
and abv.assignment_id = asg.assignment_id
and asg.assignment_type in ('E', 'C')
and abv.unit = 'FTE'
and p_effective_date between asg.effective_start_date and asg.effective_end_date
and p_effective_date between abv.effective_start_date and abv.effective_end_date
and asg.assignment_status_type_id = ast.assignment_status_type_id
and ast.per_system_status <> 'TERM_ASSIGN';
--
begin
  open c1(p_assignment_id, p_effective_date);
  fetch c1 into l_fte;
  close c1;
  return l_fte;
end;

   FUNCTION get_basis_lookup (p_assignment_id IN NUMBER, p_change_date IN DATE)
      RETURN VARCHAR2
   IS
      l_pay_basis   per_pay_bases.PAY_BASIS%TYPE;

      CURSOR csr_pay_basis
      IS
         SELECT ppb.Pay_basis
           FROM per_all_assignments_f paaf, per_pay_bases ppb
          WHERE paaf.assignment_id = p_assignment_id
            AND p_change_date BETWEEN paaf.effective_start_date
                                  AND paaf.effective_end_date
            AND ppb.pay_basis_id = paaf.pay_basis_id;
   BEGIN
      OPEN csr_pay_basis;

      FETCH csr_pay_basis
       INTO l_pay_basis;

      CLOSE csr_pay_basis;

      RETURN l_pay_basis;
   END get_basis_lookup;

Function get_next_sal_basis_chg_dt(p_assignment_id IN NUMBER, p_from_date IN DATE)
return date is
 l_next_sb_date date;
 CURSOR c_next_sb_date(p_assignment_id IN NUMBER, p_from_date IN DATE) is
  select min(effective_start_date)
  from per_all_assignments_f
  where assignment_id = p_assignment_id
  and effective_start_date > p_from_date
  and pay_basis_id not in
   (select pay_basis_id
    from per_all_assignments_f
    where assignment_id = p_assignment_id
    and p_from_date
     between effective_start_date and effective_end_date );
begin
    OPEN c_next_sb_date(p_assignment_id, p_from_date);
    FETCH c_next_sb_date into l_next_sb_date;
    IF c_next_sb_date%FOUND then
      CLOSE c_next_sb_date;
      return(l_next_sb_date);
    end if;
    CLOSE c_next_sb_date;
    return (null);
end get_next_sal_basis_chg_dt;

FUNCTION get_pay_basis_id(p_assignment_id IN NUMBER, p_from_date IN DATE)
  RETURN NUMBER
   IS
      l_pay_basis_id   number;

   CURSOR c_pay_basis_id is
   select pay_basis_id
   from per_all_assignments_f
   where assignment_id = p_assignment_id
   and p_from_date
     between effective_start_date and effective_end_date;
BEGIN
      OPEN c_pay_basis_id;
      FETCH c_pay_basis_id INTO l_pay_basis_id;
      CLOSE c_pay_basis_id;

      RETURN l_pay_basis_id;
END get_pay_basis_id;

Function get_asg_sal_basis_end_dt(p_assignment_id IN NUMBER, p_from_date IN DATE)
return date is
 l_asg_sb_end_date date;
 l_pay_basis_id number;

 CURSOR c_asg_sal_basis_end_dt(p_assignment_id IN NUMBER,
                               p_pay_basis_id IN NUMBER,
                               p_from_date IN DATE) is
  select min(effective_start_date) - 1
  from per_all_assignments_f
  where assignment_id = p_assignment_id
  and effective_start_date >= p_from_date
  and nvl(pay_basis_id,-1) <> p_pay_basis_id;
begin
    l_pay_basis_id := get_pay_basis_id(p_assignment_id, p_from_date);

    OPEN c_asg_sal_basis_end_dt(p_assignment_id, l_pay_basis_id, p_from_date);
    FETCH c_asg_sal_basis_end_dt into l_asg_sb_end_date;
    IF c_asg_sal_basis_end_dt%FOUND then
      CLOSE c_asg_sal_basis_end_dt;
      return(l_asg_sb_end_date);
    end if;
    CLOSE c_asg_sal_basis_end_dt;
    return (null);
end get_asg_sal_basis_end_dt;

END PER_SALADMIN_UTILITY;


/
