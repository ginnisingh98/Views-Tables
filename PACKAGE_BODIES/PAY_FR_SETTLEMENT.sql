--------------------------------------------------------
--  DDL for Package Body PAY_FR_SETTLEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_SETTLEMENT" AS
/* $Header: pyfrsett.pkb 115.6 2003/07/08 16:16:51 sfmorris noship $ */
--
-- Cursor To Retrieve Employee Payment Information
--
Cursor c_get_payment(p_assignment_id number
                    ,p_last_day_paid date) is

Select sum(actinfo.action_information12) total_pay
from   pay_action_information actinfo
,      pay_assignment_actions aa
,      pay_payroll_actions pa
where  actinfo.action_information_category = 'FR_SOE_EE_TOTALS'
and    actinfo.action_context_id = aa.assignment_action_id
and    aa.assignment_id = p_assignment_id
and    aa.payroll_action_id = pa.payroll_action_id
and    pa.effective_date
   between trunc(p_last_day_paid,'MM') and last_day(p_last_day_paid)
and    pa.payroll_action_id =
   (select max(pa1.payroll_action_id)
    from pay_payroll_actions pa1
    ,    pay_assignment_actions aa1
    ,    pay_action_information actinfo1
    where actinfo1.action_information_category = 'FR_SOE_EE_TOTALS'
    and   actinfo1.action_context_id = aa.assignment_action_id
    and   aa1.assignment_id = p_assignment_id
    and   aa1.payroll_action_id = pa1.payroll_action_id
    and   pa1.effective_date
   between trunc(p_last_day_paid,'MM') and last_day(p_last_day_paid)
  )
;
--
-- Function To Return Employee Payment
--
Function get_payment(p_assignment_id number
                    ,p_effective_date date) return number is
--
l_payment number;
--
begin
--
Open c_get_payment(p_assignment_id, p_effective_date);
Fetch c_get_payment into l_payment;
Close c_get_payment;
--
return l_payment;
--
end get_payment;
--
-- Procedure to Concatenate Addresses
--
procedure concat(p_concat1 IN OUT NOCOPY varchar2
                ,p_concat2 IN varchar2) is
--
begin
   if p_concat1 is not null and p_concat2 is not null then
      p_concat1:= p_concat1 || ' ' || p_concat2;
   else
      p_concat1:= p_concat1 || p_concat2;
   end if;
end concat;
--
-- Function To Return Formatted Address
--
Function format_address(p_complement varchar2
                       ,p_road varchar2
                       ,p_small_town varchar2
                       ,p_postal_code varchar2
                       ,p_town_or_city varchar2) return varchar2 is
--
l_address varchar2(2000);
--
begin
   concat(l_address, p_complement);
   concat(l_address, p_road);
   concat(l_address, p_small_town);
   concat(l_address, p_postal_code);
   concat(l_address, p_town_or_city);
   --
   return l_address;
--
end format_address;
--
-- Function To Return Formatted Full Name
--
Function format_full_name(p_title varchar2
                         ,p_first_name varchar2
                         ,p_last_name varchar2 ) return varchar2 is
--
l_full_name varchar2(2000);
--
begin
   l_full_name := p_title || ' ' || p_first_name || ' ' || p_last_name;
   --
   return l_full_name;
--
end format_full_name;
--
-- The procedure process has been commented out as it is no longer used
-- now that the report uses Web ADI and not a concurrent program.
--
/*
Procedure process(errbuf              OUT NOCOPY VARCHAR2,
                  retcode             OUT NOCOPY NUMBER,
              	  p_start_date	      IN DATE,
		  p_end_date 	      IN DATE,
		  p_set_or_asg        IN VARCHAR2,
                  p_dummy             IN VARCHAR2,
                  p_dummy1            IN VARCHAR2,
                  p_assignment_set_id IN NUMBER,
		  p_assignment_id     IN NUMBER,
                  p_separator         IN VARCHAR2) is

--
-- Cursor To Get Employee Details
--
cursor c_get_employee(l_assignment_id number) is
Select a.assignment_id			assignment_id
,      p.first_name 			first_name
,      p.last_name			last_name
,      estorg.name 			establishment_name
,      estinfo.org_information2	        SIRET
,      estinfo.org_information3	        NAF
,      comporg.name			company_name
--
-- Employee Address
--
,      addr.address_line1 		addr_road
,      addr.address_line2 		addr_complement
,      addr.region_3			addr_small_town
,      addr.postal_code			addr_postal_code
,      addr.town_or_city		addr_town_or_city
--
-- Company Address
--
,      comploc.address_line_1 		compaddr_road
,      comploc.address_line_2 		compaddr_complement
,      comploc.region_3			compaddr_small_town
,      comploc.postal_code		compaddr_postal_code
,      comploc.town_or_city		compaddr_town_or_city
--
-- Establishment Address
--
,      estloc.address_line_1 		estaddr_road
,      estloc.address_line_2 		estaddr_complement
,      estloc.region_3			estaddr_small_town
,      estloc.postal_code		estaddr_postal_code
,      estloc.town_or_city		estaddr_town_or_city
--
--
--
,      decode(pds.pds_information11,'LAST_DAY_WORKED'
                    , fnd_date.canonical_to_date(pds.pds_information10)
 	              , pds.actual_termination_date) last_day_paid
from   per_all_people_f p
,      per_all_assignments_f a
,      per_periods_of_service pds
,      hr_organization_information estinfo
,      hr_all_organization_units estorg
,      hr_all_organization_units comporg
,      per_addresses addr
,      hr_locations comploc
,      hr_locations estloc
where (l_assignment_id is not null and
        a.assignment_id = l_assignment_id)
--
-- Ensure that the last day paid is between the start and end dates
-- entered as parameters
-- N.B. Last Day Paid is taken as Last Day Worked if Final Payment Schedule
-- is LAST_DAY_WORKED, otherwise Actual Termination Date.
--
and    decode(pds.pds_information11,'LAST_DAY_WORKED'
                    , fnd_date.canonical_to_date(pds.pds_information10)
 	              , pds.actual_termination_date)
  between p_start_date and p_end_date
--
-- Use the Last Day Paid (Last Day Worked or ATD) to determine the date
-- effectivity of the Person and Assignment records
--
and    decode(pds.pds_information11,'LAST_DAY_WORKED'
                    , fnd_date.canonical_to_date(pds.pds_information10)
 	              , pds.actual_termination_date)
   between p.effective_start_date and p.effective_end_date
--
and    p.person_id = a.person_id
and    decode(pds.pds_information11,'LAST_DAY_WORKED'
                    , fnd_date.canonical_to_date(pds.pds_information10)
 	              , pds.actual_termination_date)
   between a.effective_start_date and a.effective_end_date
and    a.period_of_service_id = pds.period_of_service_id
--
-- Get Establishment Details
--
and    a.establishment_id = estorg.organization_id
and    estinfo.org_information_context = 'FR_ESTAB_INFO'
and    estorg.organization_id = estinfo.organization_id
--
-- Get Company Details
--
and    to_number(estinfo.org_information1) = comporg.organization_id
--
-- Get Person Address Details
--
and    p.person_id = addr.person_id(+)
and    addr.primary_flag(+) = 'Y'
--
-- Get Company Address Details
--
and    comporg.location_id = comploc.location_id(+)
--
-- Get Establishment Address Details
--
and    estorg.location_id = estloc.location_id(+)
order by p.last_name;
--
-- Cursor To Retrieve Employee Payment Information
--
cursor c_get_payment(l_assignment_id number
                    ,p_last_day_paid date) is
Select sum(actinfo.action_information12) total_pay
from   pay_action_information actinfo
,      pay_assignment_actions aa
,      pay_payroll_actions pa
where  actinfo.action_information_category = 'FR_SOE_EE_TOTALS'
and    actinfo.action_context_id = aa.assignment_action_id
and    aa.assignment_id = l_assignment_id
and    aa.payroll_action_id = pa.payroll_action_id
and    pa.effective_date
   between trunc(p_last_day_paid,'MM') and last_day(p_last_day_paid)
and    pa.effective_date =
   (select max(pa1.effective_date)
    from pay_payroll_actions pa1
    ,    pay_assignment_actions aa1
    where aa1.assignment_id = l_assignment_id
    and   aa1.payroll_action_id = pa1.payroll_action_id
    and   pa1.effective_date
   between trunc(p_last_day_paid,'MM') and last_day(p_last_day_paid)
   );
--
-- Cursor To Get All Employees In An Assignment Set
--
cursor c_get_assignment_set_employees(p_assignment_set_id number) is
select amend.assignment_id
from hr_assignment_set_amendments amend
where amend.assignment_set_id = p_assignment_set_id
and amend.include_or_exclude = 'I';
--
-- Declaration Of Local Variables Used In This Package
--
emp c_get_employee%ROWTYPE;
l_emp varchar2(1000);
payment number;
l_header varchar2(1000);
l_assignment_id per_all_assignments_f.assignment_id%TYPE;
--
-- Procedure to Concatenate Addresses
--
procedure concat(p_concat1 IN OUT NOCOPY varchar2
                ,p_concat2 IN varchar2) is
begin
   if p_concat1 is not null and p_concat2 is not null then
      p_concat1:= p_concat1 || ' ' || p_concat2;
   else
      p_concat1:= p_concat1 || p_concat2;
   end if;
end concat;
--
-- Function to Format Address Into Required Style For Report
--
Function format_address(p_complement varchar2
                       ,p_road varchar2
                       ,p_small_town varchar2
                       ,p_postal_code varchar2
                       ,p_town_or_city varchar2) return varchar2 is
l_address varchar2(2000);
--
begin
   concat(l_address, p_complement);
   concat(l_address, p_road);
   concat(l_address, p_small_town);
   concat(l_address, p_postal_code);
   concat(l_address, p_town_or_city);
   --
   return l_address;
end format_address;
--
-- Procedure To Get And Print Employee Details To The File
--
procedure print_employee_details(l_assignment_id number) is
begin
--
-- Get Employee Info
--
Open c_get_employee(l_assignment_id);
Fetch c_get_employee into emp;
Close c_get_employee;
--
-- Concatenate the values with the spearator
--
l_emp := emp.first_name||p_separator||
         emp.last_name||p_separator||
         format_address(emp.addr_complement
                       ,emp.addr_road
                       ,emp.addr_small_town
                       ,emp.addr_postal_code
                       ,emp.addr_town_or_city)||p_separator||
         emp.company_name||p_separator||
         format_address(emp.compaddr_complement
                       ,emp.compaddr_road
                       ,emp.compaddr_small_town
                       ,emp.compaddr_postal_code
                       ,emp.compaddr_town_or_city)||p_separator||
         emp.establishment_name||p_separator||
         format_address(emp.estaddr_complement
                       ,emp.estaddr_road
                       ,emp.estaddr_small_town
                       ,emp.estaddr_postal_code
                       ,emp.estaddr_town_or_city)||p_separator||
         emp.SIRET||p_separator||
         emp.NAF;
--
--
-- Retrieve Employee Payment Info
--
Open c_get_payment(l_assignment_id, emp.last_day_paid);
Fetch c_get_payment into payment;
Close c_get_payment;
--
-- Concatenate the values with the separator
--
l_emp := l_emp ||p_separator||
         payment||p_separator||
           pay_ca_amt_in_words.pay_amount_in_words(payment
                                                   ,userenv('LANG'));
--
-- Output Employee Record To The File
--
Fnd_file.put_line(FND_FILE.OUTPUT,l_emp);
end print_employee_details;

begin
--
-- Build Up Report Header Line
--
l_header :=
  hr_general.decode_lookup('NAME_TRANSLATIONS','FR_FIRST_NAME') ||
  p_separator ||
  hr_general.decode_lookup('NAME_TRANSLATIONS','FR_LAST_NAME') ||
  p_separator ||
  hr_general.decode_lookup('NAME_TRANSLATIONS','FR_EMPLOYEE_ADDRESS') ||
  p_separator ||
  hr_general.decode_lookup('NAME_TRANSLATIONS','FR_COMPANY_NAME') ||
  p_separator ||
  hr_general.decode_lookup('NAME_TRANSLATIONS','FR_COMPANY_ADDRESS') ||
  p_separator ||
  hr_general.decode_lookup('NAME_TRANSLATIONS','FR_ESTABLISHMENT_NAME') ||
  p_separator ||
  hr_general.decode_lookup('NAME_TRANSLATIONS','FR_ESTABLISHMENT_ADDRESS') ||
  p_separator ||
  'SIRET' ||
  p_separator ||
  'NAF' ||
  p_separator ||
  hr_general.decode_lookup('NAME_TRANSLATIONS','FR_PAYMENT') ||
  p_separator ||
  hr_general.decode_lookup('NAME_TRANSLATIONS','FR_PAYMENT_IN_WORDS');
--
-- Output Header To File
--
Fnd_file.put_line(FND_FILE.OUTPUT,l_header);
--
-- If an assignment id was passed in, then the details of that single employee
-- must be output to the file.  If an assignment set id was passed in, then a
-- loop is entered to print details for every employee in the assignment set.
-- If neither is entered then a message is output to the log.
--
IF p_assignment_id is not null THEN
   l_assignment_id := p_assignment_id;
   print_employee_details(l_assignment_id);
ELSIF p_assignment_set_id is not null THEN
   Open c_get_assignment_set_employees(p_assignment_set_id);
   LOOP
      fetch c_get_assignment_set_employees into l_assignment_id;
      exit when c_get_assignment_set_employees%NOTFOUND;
      print_employee_details(l_assignment_id);
   END LOOP;
   close c_get_assignment_set_employees;
ELSE fnd_file.put_line(FND_FILE.LOG, 'No assignment or assignment set was entered');
END IF;
end process;
*/
end PAY_FR_SETTLEMENT;

/
