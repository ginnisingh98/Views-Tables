--------------------------------------------------------
--  DDL for Package Body PAY_IE_BIK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_BIK" as
/* $Header: pyiebik.pkb 120.2.12010000.3 2009/04/03 08:05:07 abraghun ship $ */

/* This function is used to fetch the specified interest rates for various type
of loans given, which are defined as globals.*/

function get_global_value(p_name in VARCHAR2,
                           p_effective_date in DATE)
return number is

  cursor c_global_value_cursor is
  select global_value
  from ff_globals_f
  Where global_name=p_name
  and legislation_code='IE'
  and p_effective_date between effective_start_date and effective_end_date;

  l_global_value ff_globals_f.global_value%type;
  l_effective_start_date DATE;
  l_effective_end_date date;
  l_proc  varchar2(72) := 'pay_ie_bik.get_global_value';

BEGIN
   hr_utility.set_location('Entering ' || l_proc, 20);
   open c_global_value_cursor;
   FETCH c_global_value_cursor into l_global_value;
   close c_global_value_cursor;

   hr_utility.set_location('Leaving ' || l_proc, 100);
   return to_number(l_global_value);
EXCEPTION
    when NO_DATA_FOUND then
    raise_application_error(-20001,l_proc||'- '||sqlerrm);
end get_global_value;

/* This function is used for fetching the Start Date of the First Period in the
Financial year.*/
FUNCTION get_max_start_date(p_payroll_action_id IN number,
                            p_max_start_date in DATE,
                            p_benefit_start_date IN DATE)
return DATE as

cursor c_first_period_start_date(l_payroll_action_id NUMBER) is
select min(TPERIOD.start_date)
 from  pay_payroll_actions                      PACTION
,       per_time_periods                         TPERIOD
,       per_time_period_types                    TPTYPE
where   PACTION.payroll_action_id              = l_payroll_action_id
and     TPERIOD.payroll_id                 = PACTION.payroll_id
and     TPTYPE.period_type                 = TPERIOD.period_type
and to_char(PACTION.DATE_EARNED,'YYYY')=to_char(TPERIOD.END_DATE,'YYYY');

l_max_start_date DATE;
l_first_period_start_date DATE;
l_proc  varchar2(72) := 'pay_ie_bik.get_max_start_date';

BEGIN

  hr_utility.set_location('Entering ' || l_proc, 20);

  l_max_start_date:=p_max_start_date;

  open c_first_period_start_date(p_payroll_action_id);
  fetch c_first_period_start_date into l_first_period_start_date;
  close c_first_period_start_date;

 IF l_first_period_start_date < p_max_start_date then
  l_max_start_date := l_first_period_start_date;
    if p_benefit_start_date between l_max_start_date and p_max_start_date then
      l_max_start_date := p_benefit_start_date;
    end if;
 end if;
 hr_utility.set_location('Leaving ' || l_proc, 100);
return l_max_start_date;
EXCEPTION
   when NO_DATA_FOUND then
     null;
end get_max_start_date;

-- Changed csr_least_date to select end_date of period (5070091)
FUNCTION get_least_date(
p_payroll_action_id  in number,
c_end_date in date)
return date is
	cursor csr_least_date is
	select ptp.end_date
	from pay_payroll_actions ppa
	    , per_time_periods ptp
	WHERE ppa.payroll_action_id=p_payroll_action_id
	AND   ptp.payroll_id=ppa.payroll_id
	AND   ppa.DATE_EARNED between ptp.start_date and ptp.end_date;

        l_least_date date;
	l_least date;
        l_proc  varchar2(72) := 'pay_ie_bik.get_least_date';
begin
	open  csr_least_date;
	fetch csr_least_date into l_least_date;
	close csr_least_date;
	l_least := least(l_least_date,c_end_date);
	return l_least;

Exception
  when others then
    raise_application_error(-20003,l_proc||'- '||sqlerrm);
end get_least_date;


/*This function is used for fetching the Number of Pay Periods required to
spread Total Taxable Value for the Benefit*/

 Function get_max_no_of_periods
(p_payroll_action_id  in number,
 p_maximum_start_date in date,
 p_minimum_end_date in date,
 p_formula_context in varchar2)
return Number is

-- Changed to select end_date of period (5070091)
cursor get_end_date(c_minimum_end_date in date) is
select ptp.end_date end_date
from
  pay_payroll_actions ppa
, per_time_periods ptp
, per_time_period_types tptype
WHERE ppa.payroll_action_id=p_payroll_action_id
AND   ptp.payroll_id=ppa.payroll_id
AND   ptp.period_type = tptype.period_type
AND   c_minimum_end_date between PTP.start_date and PTP.end_date;

-- Cursor now counts the periods whose end date fall between the dates (5070091)
cursor get_periods(c_maximum_start_date in date,
                   c_end_date in date) is
select count(ptp.period_num) pay_periods
from
  pay_payroll_actions ppa
, per_time_periods ptp
, per_time_period_types tptype
WHERE ppa.payroll_action_id=p_payroll_action_id
AND   ptp.payroll_id=ppa.payroll_id
AND   ptp.period_type = tptype.period_type
AND   ptp.end_date between
c_maximum_start_date  and c_end_date;

-- Cursor now counts the periods whose end date fall between the dates (5070091)
cursor get_cumulative_periods(c_maximum_start_date in date,c_end_date in date) is
select count(ptp.period_num) pay_periods
from
  pay_payroll_actions ppa
, per_time_periods ptp
, per_time_period_types tptype
WHERE ppa.payroll_action_id=p_payroll_action_id
AND   ptp.payroll_id=ppa.payroll_id
AND   ptp.period_type = tptype.period_type
AND   ptp.end_date between
c_maximum_start_date and pay_ie_bik.get_least_date(p_payroll_action_id,
c_end_date);


l_proc  varchar2(72) := 'pay_ie_bik.get_max_no_of_periods';
l_periods  get_periods%rowtype;
l_cumulative_periods get_cumulative_periods%rowtype;
--l_end_date get_end_date%rowtype;
l_end_date date;


begin
  hr_utility.set_location('Entering ' || l_proc, 20);
--  hr_utility.trace_on(null,'BIK');
  hr_utility.trace(' p_maximum_start_date' || to_char(p_maximum_start_date,'dd-mon-yyyy'));
  hr_utility.trace(' p_minimum_end_date' || to_char(p_minimum_end_date,'dd-mon-yyyy'));
  hr_utility.trace(' p_formula_context' || p_formula_context);

  open get_end_date(p_minimum_end_date);
  fetch get_end_date into l_end_date;
  if to_char(l_end_date,'YYYY') =
     to_char(p_minimum_end_date,'YYYY') then
    null;
  else
    l_end_date := p_minimum_end_date;
  end if;
  close get_end_date;
  hr_utility.trace('l_end_date ' || to_char(l_end_date,'dd-mon-yyyy'));

 if p_formula_context='f1' then
   open get_periods(p_maximum_start_date, l_end_date);
   fetch get_periods into l_periods;
   close get_periods;
   hr_utility.trace('l_periods ' || l_periods.pay_periods);
   hr_utility.set_location('Leaving ' || l_proc, 100);
   --hr_utility.trace_off;
   return l_periods.pay_periods;
 end if;

 if p_formula_context='f2' then
   open get_cumulative_periods(p_maximum_start_date, l_end_date);
   fetch get_cumulative_periods into l_cumulative_periods;
   close get_cumulative_periods;
   hr_utility.trace('l_cumulative_periods.pay_periods ' || l_cumulative_periods.pay_periods);
   hr_utility.set_location('Leaving ' || l_proc, 200);
--   hr_utility.trace_off;
   return l_cumulative_periods.pay_periods;
 end if;

Exception
  when others then
  hr_utility.trace('error ' ||sqlerrm);
--hr_utility.trace_off;
    raise_application_error(-20002,l_proc||'- '||sqlerrm);
end get_max_no_of_periods;


FUNCTION get_balance_values(p_assignment_action_id number,
                            p_source_id number,
                            p_date_earned date,
                            p_balance_name varchar2)
return number is

cursor csr_get_values is
select pay_balance_pkg.get_value(pdb.defined_balance_id, p_assignment_action_id,
null, null,null, null,null, p_source_id,p_date_earned) Cumulative_Taxable_Value
from
   pay_balance_dimensions pbd,
   pay_balance_types pbt,
   pay_defined_balances pdb
where
   pbt.balance_type_id = pdb.balance_type_id
   and pbd.balance_dimension_id = pdb.balance_dimension_id
   and pbd.legislation_code = pbt.legislation_code
   and pbt.balance_name= p_balance_name
   and pbd.dimension_name='_ELEMENT_YTD'
   and pbd.legislation_code='IE';

l_get_values csr_get_values%rowtype;
l_proc  varchar2(72) := 'pay_ie_bik.get_balance_values';

begin
    hr_utility.set_location('Entering ' || l_proc, 20);

    open  csr_get_values;
    fetch csr_get_values into l_get_values;
    close csr_get_values;

    hr_utility.set_location('Leaving ' || l_proc, 200);

    return l_get_values. Cumulative_Taxable_Value;

Exception
  when others then
  hr_utility.trace('error ' ||sqlerrm);
  raise_application_error(-20004,l_proc||'- '||sqlerrm);
end get_balance_values;


FUNCTION get_address(l_address_type varchar2,
                     l_address_id varchar2)
return varchar2 is

TYPE l_address_rec is record (info varchar2(240));
l_address l_address_rec;

type l_address_refcur_type is ref

cursor return l_address_rec;
l_address_refcur l_address_refcur_type;
l_proc  varchar2(72) := 'pay_ie_bik.get_address';
begin
    hr_utility.set_location('Entering ' || l_proc, 20);
    if l_address_type='address_line1' then
	open l_address_refcur for select address_line1
	from per_addresses
	where address_id=l_address_id;
    elsif l_address_type='address_line2' then
	open l_address_refcur for select address_line2
	from per_addresses
	where address_id=l_address_id;
    elsif  l_address_type='address_line3' then
	open l_address_refcur for select address_line3
	from per_addresses
	where address_id=l_address_id;
    elsif l_address_type= 'town_or_city' then
	open l_address_refcur for select town_or_city
	from per_addresses
	where address_id=l_address_id;
    elsif  l_address_type= 'region_1' then
	open l_address_refcur for select region_1
	from per_addresses
	where address_id=l_address_id;
    elsif  l_address_type= 'postal_code' then
	open l_address_refcur for select postal_code
	from per_addresses
	where address_id=l_address_id;
    elsif  l_address_type= 'country' then
	open l_address_refcur for select country
	from per_addresses
	where address_id=l_address_id;
     end if;

fetch l_address_refcur into l_address;
CLOSE l_address_refcur;
hr_utility.set_location('Leaving ' || l_proc, 200);

  return (l_address.info);

Exception
  when others then
  hr_utility.trace('error ' ||sqlerrm);
  raise_application_error(-20005,l_proc||'- '||sqlerrm);

end get_address;

FUNCTION get_landlord_address(l_address_type varchar2,
                               l_address_id varchar2)
return varchar2 is

type l_landlord_rec is record (info varchar2(240));
l_landlord l_landlord_rec;

type l_landlord_refcur_type is ref cursor return l_landlord_rec;
l_landlord_refcur l_landlord_refcur_type;

l_proc  varchar2(72) := 'pay_ie_bik.get_landlord_address';
begin

hr_utility.set_location('Entering ' || l_proc, 20);

 if l_address_type='address_line1' then

       open l_landlord_refcur for select hl.ADDRESS_LINE_1
       from hr_all_organization_units hou,
            hr_locations hl
       where hou.organization_id=l_address_id
       and hou.location_id=hl.location_id;

elsif l_address_type='address_line2' then

	open l_landlord_refcur for select hl.ADDRESS_LINE_2
        from hr_all_organization_units hou,
	     hr_locations hl
        where hou.organization_id=l_address_id
        and hou.location_id=hl.location_id;

elsif l_address_type='address_line3' then

        open l_landlord_refcur for select hl.ADDRESS_LINE_3
        from hr_all_organization_units hou,hr_locations hl
        where hou.organization_id=l_address_id
        and hou.location_id=hl.location_id;

elsif l_address_type= 'town_or_city' then

         open l_landlord_refcur for select hl.town_or_city
         from hr_all_organization_units hou,hr_locations hl
         where hou.organization_id=l_address_id
         and hou.location_id=hl.location_id;

elsif l_address_type= 'region_1' then

         open l_landlord_refcur for select hl.region_1
         from hr_all_organization_units hou,hr_locations hl
         where hou.organization_id=l_address_id
         and hou.location_id=hl.location_id;

elsif l_address_type= 'postal_code' then

         open l_landlord_refcur for select hl.postal_code
         from hr_all_organization_units hou,hr_locations hl
         where hou.organization_id=l_address_id
         and hou.location_id=hl.location_id;

elsif l_address_type= 'country' then

         open l_landlord_refcur for select hl.country
         from hr_all_organization_units hou,hr_locations hl
         where hou.organization_id=l_address_id
         and hou.location_id=hl.location_id;
end if;
fetch l_landlord_refcur into l_landlord;
CLOSE l_landlord_refcur;

hr_utility.set_location('Leaving ' || l_proc, 200);

return (l_landlord.info);

Exception
  when others then
  hr_utility.trace('error ' ||sqlerrm);
  raise_application_error(-20006,l_proc||'- '||sqlerrm);

end get_landlord_address;

-- cursor get_invalid_days is changed as it returns incorrect value for Offset Payrolls (5070091)
function GET_INV_UNA_DAYS(p_element_entry_id in number,
                                            p_vehicle_alloc_end_date in DATE,
					    p_curr_period_end_date in DATE) return number is
cursor get_invalid_days(p_element_entry_id in number,
                        p_vehicle_alloc_end_date in DATE,
			p_curr_period_start_date in DATE)  is
select nvl(sum(to_number(prrv.result_value)),0)
from pay_element_types_f pet,
       pay_input_values_f piv,
       pay_element_entries_f pee,
       pay_payroll_actions ppa,
       pay_assignment_actions paas,
       pay_run_results prr,
       pay_run_result_values prrv
where pee.element_entry_id=p_element_entry_id
      AND prr.source_id = pee.element_entry_id
      AND prr.element_type_id=pet.element_type_id
      AND (pet.element_name='IE BIK Company Vehicle Details'
      OR pet.element_name='IE BIK Company Vehicle 2009 Details') --8236523
      AND prr.run_result_id=prrv.run_result_id
      AND piv.name='Days Unavailable in Period'
      AND prrv.input_value_id = piv.input_value_id
      AND paas.assignment_action_id=prr.assignment_action_id
      AND paas.payroll_action_id=ppa.payroll_action_id
      AND paas.assignment_id=pee.assignment_id
      AND ppa.date_earned>( select min(ppa1.date_earned)   -- query is now based on date earned (5070091)
                                from pay_payroll_actions ppa1,
				     pay_assignment_actions paas1,
				     pay_run_results prr1,
                                     pay_element_entries_f pee1
				where ppa1.date_earned>=p_vehicle_alloc_end_date -- query is now based on date earned (5070091)
				  AND pee1.element_entry_id=p_element_entry_id
				  AND prr1.element_entry_id = pee1.element_entry_id
				  AND paas1.assignment_action_id=prr1.assignment_action_id
                          AND paas1.payroll_action_id=ppa1.payroll_action_id
				  AND prr1.source_id= pee1.element_entry_id) -- Added for bug 4771780
-- query is now based on date earned (5070091)
      AND ppa.date_earned<=p_curr_period_end_date
      AND ppa.date_earned between pee.effective_start_date and pee.effective_end_date
      AND ppa.effective_date between pet.effective_start_date and pet.effective_end_date
      AND ppa.effective_date between piv.effective_start_date and piv.effective_end_date;
inv_days number(10);

begin
OPEN get_invalid_days(p_element_entry_id,p_vehicle_alloc_end_date,p_curr_period_end_date);
FETCH  get_invalid_days into inv_days;
CLOSE get_invalid_days;

return inv_days;
end GET_INV_UNA_DAYS;

function GET_INV_TOT_MLGE(p_element_entry_id in number,
                                            p_vehicle_alloc_end_date in DATE,
					    p_curr_period_end_date in DATE) return number is
-- cursor invalid_total_mileage is changed as it returns incorrect value for Offset Payrolls (5070091)
cursor invalid_total_mileage(p_element_entry_id in number,
                        p_vehicle_alloc_end_date in DATE,
			p_curr_period_start_date in DATE)  is
select nvl(sum(to_number(prrv.result_value)),0)
from pay_element_types_f pet,
       pay_input_values_f piv,
       pay_element_entries_f pee,
       pay_payroll_actions ppa,
       pay_assignment_actions paas,
       pay_run_results prr,
       pay_run_result_values prrv
where pee.element_entry_id=p_element_entry_id
      AND prr.source_id = pee.element_entry_id
      AND prr.element_type_id=pet.element_type_id
      AND (pet.element_name='IE BIK Company Vehicle Details'
       OR pet.element_name='IE BIK Company Vehicle 2009 Details') --8236523
      AND prr.run_result_id=prrv.run_result_id
      AND piv.name='Total Mileage for Run'
      AND prrv.input_value_id = piv.input_value_id
      AND paas.assignment_action_id=prr.assignment_action_id
      AND paas.payroll_action_id=ppa.payroll_action_id
      AND paas.assignment_id=pee.assignment_id
      AND ppa.date_earned>( select min(ppa1.date_earned) -- query is now based on date earned (5070091)
                                from pay_payroll_actions ppa1,
						 pay_assignment_actions paas1,
						 pay_run_results prr1,
                                     pay_element_entries_f pee1
				where ppa1.date_earned>=p_vehicle_alloc_end_date -- query is now based on date earned (5070091)
				  AND pee1.element_entry_id=p_element_entry_id
				  AND prr1.element_entry_id = pee1.element_entry_id
				  AND paas1.assignment_action_id=prr1.assignment_action_id
                          AND paas1.payroll_action_id=ppa1.payroll_action_id
				  AND prr1.source_id= pee1.element_entry_id) -- Added for bug 4771780
      -- query is now based on date earned (5070091)
      AND ppa.date_earned<=p_curr_period_end_date
      AND ppa.date_earned between pee.effective_start_date and pee.effective_end_date
      AND ppa.effective_date between pet.effective_start_date and pet.effective_end_date
      AND ppa.effective_date between piv.effective_start_date and piv.effective_end_date;
inv_days number(10);

begin
OPEN   invalid_total_mileage(p_element_entry_id,p_vehicle_alloc_end_date,p_curr_period_end_date);
FETCH  invalid_total_mileage into inv_days;
CLOSE  invalid_total_mileage;

return inv_days;
end GET_INV_TOT_MLGE;

function GET_INV_BUS_MLGE(p_element_entry_id in number,
                                            p_vehicle_alloc_end_date in DATE,
					    p_curr_period_end_date in DATE) return number is
-- cursor invalid_bsg_mileage is changed as it returns incorrect value for Offset Payrolls (5070091)
cursor invalid_bsg_mileage(p_element_entry_id in number,
                        p_vehicle_alloc_end_date in DATE,
			p_curr_period_start_date in DATE)  is
select nvl(sum(to_number(prrv.result_value)),0)
from pay_element_types_f pet,
       pay_input_values_f piv,
       pay_element_entries_f pee,
       pay_payroll_actions ppa,
       pay_assignment_actions paas,
       pay_run_results prr,
       pay_run_result_values prrv
where pee.element_entry_id=p_element_entry_id
      AND prr.source_id = pee.element_entry_id
      AND prr.element_type_id=pet.element_type_id
      AND (pet.element_name='IE BIK Company Vehicle Details'
      OR pet.element_name='IE BIK Company Vehicle 2009 Details') --8236523
      AND prr.run_result_id=prrv.run_result_id
      AND piv.name='Business Mileage for Run'
      AND prrv.input_value_id = piv.input_value_id
      AND paas.assignment_action_id=prr.assignment_action_id
      AND paas.payroll_action_id=ppa.payroll_action_id
      AND paas.assignment_id=pee.assignment_id
      AND ppa.date_earned>( select min(ppa1.date_earned) -- query is now based on date earned (5070091)
                                from pay_payroll_actions ppa1,
						pay_assignment_actions paas1,
						pay_run_results prr1,
                                    pay_element_entries_f pee1
				where ppa1.date_earned>=p_vehicle_alloc_end_date -- query is now based on date earned (5070091)
				  AND pee1.element_entry_id=p_element_entry_id
				  AND prr1.element_entry_id = pee1.element_entry_id
				  AND paas1.assignment_action_id=prr1.assignment_action_id
                          AND paas1.payroll_action_id=ppa1.payroll_action_id
                          AND prr1.source_id= pee1.element_entry_id) -- Added for bug 4771780
      -- query is now based on date earned (5070091)
      AND ppa.date_earned<=p_curr_period_end_date
      AND ppa.date_earned between pee.effective_start_date and pee.effective_end_date
      AND ppa.effective_date between pet.effective_start_date and pet.effective_end_date
      AND ppa.effective_date between piv.effective_start_date and piv.effective_end_date;
inv_days number(10);

begin
OPEN   invalid_bsg_mileage(p_element_entry_id,p_vehicle_alloc_end_date,p_curr_period_end_date);
FETCH  invalid_bsg_mileage into inv_days;
CLOSE  invalid_bsg_mileage;

return inv_days;
end GET_INV_BUS_MLGE;


-- 8236523 -- 2009 Changes --

function get_fiscal_rating(p_allocation_id in number)
                        return number is
--to get the Emission Rating for computation of IE BIK Company Vehicle based on CO2 Emission
    cursor fiscal_rating(c_allocation_id in number)  is
        SELECT
          fiscal_ratings
        FROM
          pqp_vehicle_repository_f pvr,
          pqp_vehicle_allocations_f pva
        WHERE pvr.vehicle_repository_id = pva.vehicle_repository_id
          AND pva.vehicle_allocation_id = c_allocation_id
       --   AND to_char(pvr.EFFECTIVE_END_DATE,'DDMMYYYY')='31124712';
          AND pvr.EFFECTIVE_END_DATE =
       (SELECT
          MAX(pvr.EFFECTIVE_END_DATE)
        FROM
          pqp_vehicle_repository_f pvr,
          pqp_vehicle_allocations_f pva
        WHERE pvr.vehicle_repository_id = pva.vehicle_repository_id
          AND pva.vehicle_allocation_id = c_allocation_id);

    rating number;
begin
    OPEN   fiscal_rating(p_allocation_id);
    FETCH  fiscal_rating into rating;
    CLOSE  fiscal_rating;
    RETURN rating;
end get_fiscal_rating;


end pay_ie_bik;

/
