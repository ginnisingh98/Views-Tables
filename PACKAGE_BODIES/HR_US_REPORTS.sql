--------------------------------------------------------
--  DDL for Package Body HR_US_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_US_REPORTS" AS
/* $Header: pyuslrep.pkb 120.3.12010000.2 2008/08/06 08:33:19 ubhat ship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ******************************************************************
 Name        : hr_us_reports (BODY)
 File        : pyuslrep.pkb
 Description : This package declares functions and procedures which are used
               to return values for the srw2 US Payroll r10 reports.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+-----------------------------------------------------------------
 40.0    13-SEP-93 AKelly               Date Created
 40.1    14-SEP-93 AKelly               Added dashes between components
                                        of run in get_payroll_action.
 40.2    26-OCT-93 AKelly               Added get_legislation_code
 40.3    22-NOV-93 AKelly               Added get_defined_balance_id
 40.4    09-DEC-93 AKelly               Added get_startup_defined_balance,
                                        which is intended for retrieving
                                        startup balances' defined_balance_id,
                                        as these generally have their reporting
                                        names' set similar to the elements'
                                        reporting names.
 40.5    11-DEC-93 MSwanson             Added 'get_payment_type_name'.
                                        Added select to 'get_payroll_action'
                                        for action_type 'P'.
                                        Added 'get_element_type_name'.
 40.5    17-FEB-94 GPayton-McDowall     added get_ben_class_name
 40.6    01-MAR-94 GPayton-McDowall     added get_cobra_qualifying_event
                                              get_cobra_status
 40.7    23-Mar-94 MSwanson             Added get_org_name, get_est_tax_unit and
                                        get_org_hierarchy_name for EEO reporting.
 40.8    25-Mar-94 MSwanson             Added get_county_address for eeo and tax reps.
                                        Added get_activity for eeo reps.
*********************************************************************************************************
 40.0    18-May-94 M Gilmore		Moved from US
 40.1    03-Jul-94 A D Roussel		Tidied up for 10G install.
 40.2    03-Jul-94 hrdev		Added Header
 40.3    04-Jul-94 A D Roussel          Fix symbol name message on load in sql+
 40.x    12-Oct-94 MSwanson             Add get_defined_balance_by_type.
                                        Add get_employee_address.
                                        Bug G1725 - remove use of index on
					business_group_id.
					Add get_person_name.
 40.7    20-apr-95 MSwanson		Add get_career_path_name.
 40.8    29-Aug-95 MSwanson		Tidy up balances for W2. Remove
					many calls as we use new Bal API.
 40.9    19-Oct-95 MSwanson             Add get_state_name.
 40.10   20-Oct-95 MSwanson		Add get_new_hire_contact.
 40.11   25-Oct-95 MSwanson		Add get_salary.
 40.12   01-Nov-95 Jthuring             Removed error checking from end of script
 40.13   29-Nov-95 mswanson		Get normal_hours and work_schedule
					in get_salary, so non-salaried emps
                                        get calculated.
 40.14   30-Apr-96 nbristow             Now Caching defined_balance_id in
                                        get_defined_balance_id to improve
                                        performance (ChequeWriter).
 40.15   21-May-96 nlee                 Bug 366087 Add new procedure
                                        get_address_31.
                                        Change 'Section 125' to
                                        'Dependent Care'.
                                        Add function get_location_code.
 40.16	 19-Aug-96 nlee			Add a primary_flag = 'Y' condition to
                                        get_employee_address procedure.
                                        Add a new balance id and name called
					'12' and 'W2 Fringe Benefit' respectively					 		in get_defined_balance_by_type
 40.17	06-Sep-96 ssdesai		upgrade script py364888.sql creates a balance
					called W2 Fringe Benefits (plural).
 40.18  04-NOV-1996 hekim               In get_person_name
                                         -- changed l_person_name to VARCHAR2(240)
                                                        from VARCHAR2(60)
          				In get_address_31
                                         -- take substr of line1,line2, line3 to
                                             handle fields which are greater than 31 chars
 40.19  05-NOV-1996 hekim               Add function get_address_3lines
 40.20  18-NOV-1996 hekim               Added effective_date to get_address_3lines
 40.21  04-DEC-1996 hekim               Move state code on same line as city in get_address_31
 40.22	09-JAN-1997 nlee		Add a condition in get_person_name so that when it will get
					the latest name in the effective_start_date and this will solve
					the problem of fetching more than one row.

 40.23 26-FEB-1997 hekim                In get_address_3lines, take substring of city name
 40.24 28-Jul-1997 nlee			Change pay_state_rules to pay_us_states in get_state_name.
					Change the selection of all rows from hr_locations and
					per_addresses in get_address and get_employee_address
					functions to selection of the specific rows that are
					needed to increase performance and avoid overflow problem.
					Change the sql statement to cursor statement in get_new_hire_contact
					and add the exception handlers to the function.
 40.25 08-DEC-1997 tlacey               Added effective_date to get_employee_address.
115.1  04-MAR-1999 jmoyano              MLS changes. Added references to _TL tables.

115.2  09-MAR-1999 sdoshi               BUG 844582 - Ensure that all functions return a value,
                                        whether it completes successfully or it fails via the
                                        exception handler - default return value is NULL.
115.3 25-MAY-1999 mmukherj              Added legislation code in the
                                        get_defined_balance_id procedure.
115.4 18-APR-2000 mcpham                Added function fnc_get_payee for report PAYRPTPP and bug 1063477
115.6 30-APR-2002 gperry                Fixed WWBUG 2331831.
115.7 25-FEB-2003 vbanner               Added function get_hr_est_tax_unit to
                                        fix bug 2722353. (the new function will
                                        return a tax id for the top org in a
                                        hierarchy).
115.8 17-OCT-2003 ynegoro   3141907     Updated get_hr_est_tax_unit
                                        Fixed GSCC warning, Added nocopy for out
                                        parameters
115.9 23-OCT-2003 ynegoro   3182433     Added get_top_org_id function
115.10 09-APR-04  ynegoro   3545006     Updated get_top_org_id function
                                        Added csr_get_max_child_id cursor;
115.11 14-JUL-04  saurgupt  3669973     Modified function get_salary. Modified the query to get freq.
                                        from per_assignments_f. Also, add this freq. in the call to fun.
                                        hr_us_ff_udfs.Convert_Period_Type.
         	                        Also, make the file GSCC compliant.
115.12 29-JUL-04  saurgupt  3624095     Modified cursor csr_tax_unit_flag to change the inpur parameter
                                        name from tax_unit_id to p_tax_unit_id.
115.13 05-MAY-05  ynegoro   4346783     Added verify_state function fro VETS-100
115.14 18-Aug-05  sackumar  4350592     Changed the get_est_tax_unit function,
					check_if_top_org cursor and csr_tax_unit_flag cursor.
115.15 10-OCT-2006 rpasumar 5577840  Modified verify_state function.
115.16 11-OCT-2006 rpasumar 5577840 Selected hierarchy_node_id instead of entity_id in c_est_entity cursor of the function verify_state.
115.17 12-MAR-2008 psugumar  6774707   Added get_employee_address40
Consolidate Report
========================================================================================================
*/
-- Global declarations
type char_array is table of varchar(81) index by binary_integer;
type num_array  is table of number(16) index by binary_integer;
--
g_defbal_tbl_id num_array;
g_defbal_tbl_name char_array;
g_nxt_free_defbal number;
--
--
FUNCTION fnc_get_payee
  ( IN_payee_id IN NUMBER,
    IN_payee_type IN VARCHAR2,
    IN_payment_date IN DATE,
    IN_business_group_id IN NUMBER)
  RETURN VARCHAR2 IS

CURSOR c_get_p_payee IS
   SELECT SUBSTR(INITCAP(RTRIM(ppf.title)||' '||RTRIM(ppf.first_name)||' '||RTRIM(ppf.last_name)),1,60)
     FROM per_addresses addr,
              per_people_f  ppf
    WHERE ppf.person_id         = IN_payee_id
      AND ppf.business_group_id+0       = IN_business_group_id
      AND IN_payment_date BETWEEN ppf.effective_start_date
                                AND ppf.effective_end_date
      AND addr.person_id(+)     = ppf.person_id
      AND addr.primary_flag(+)  = 'Y'
      AND IN_payment_date BETWEEN addr.date_from(+)
                                AND NVL(addr.date_to, IN_payment_date);

CURSOR c_get_o_payee IS
   SELECT SUBSTR(hou.name,1,240)
     FROM hr_locations  loc,
              hr_organization_units hou
    WHERE hou.organization_id = IN_payee_id
      AND hou.business_group_id = IN_business_group_id
      AND IN_payment_date BETWEEN hou.date_from
                                AND NVL(hou.date_to, IN_payment_date)
      AND loc.location_id(+)    = hou.location_id;

   L_return_val               VARCHAR2(240) := NULL;
   -- Declare program variables as shown above


BEGIN

    IF IN_payee_type = 'P' THEN
       OPEN c_get_p_payee;
      FETCH c_get_p_payee INTO L_return_val;
      CLOSE c_get_p_payee;
    ELSIF IN_payee_type = 'O' THEN
       OPEN c_get_o_payee;
      FETCH c_get_o_payee INTO L_return_val;
      CLOSE c_get_o_payee;
    END IF;

    RETURN L_return_val;

EXCEPTION
   WHEN OTHERS THEN
       RAISE;
END fnc_get_payee;



--
--
FUNCTION get_salary     (p_business_group_id	NUMBER,
			 p_assignment_id 	NUMBER,
			 p_report_date 		DATE
			) return NUMBER
--
AS
--
l_effective_start_date	date;
l_pay_basis		varchar2(60);
l_salary		number;
l_normal_hours		number;
l_work_schedule		varchar2(150);
l_annual_salary		number;
l_frequency		per_all_assignments_f.frequency%type;
--
Begin
--
   hr_utility.set_location('hr_us_reports.get_salary',5);
   hr_utility.trace('p_business_group_id	->'||to_char(p_business_group_id));
   hr_utility.trace('p_assignment_id		->'||to_char(p_assignment_id));
   hr_utility.trace('p_report_date		->'||p_report_date );
--
Begin
--
Select
	peev.effective_start_date,
	hl.meaning,
	asg.normal_hours,
	hscf.segment4,
	peev.screen_entry_value,
	decode(asg.frequency,'W','WEEK',   -- Bug 3669973
	                     'M','MONTH',
			     'Y','YEAR',
			     null) frequency

Into
	l_effective_start_date,
	l_pay_basis,
	l_normal_hours,
	l_work_schedule,
	l_salary,
	l_frequency
From
	pay_element_entry_values_f 	peev,
	pay_element_entries_f		pee,
	per_pay_bases  			ppb,
	hr_soft_coding_keyflex		hscf,
	per_assignments_f    		asg,
	hr_lookups			hl
Where
 	hl.application_id		= 800
And	hl.lookup_type			= 'PAY_BASIS'
And	hl.lookup_code			= ppb.pay_basis
And     peev.element_entry_id 		= pee.element_entry_id
And  	peev.effective_start_date 	= pee.effective_start_date
And  	peev.input_value_id+0 		= ppb.input_value_id
And  	asg.pay_basis_id 		= ppb.pay_basis_id
And  	pee.assignment_id		= asg.assignment_id
And	hscf.soft_coding_keyflex_id	= asg.soft_coding_keyflex_id
And  	asg.assignment_id 		= p_assignment_id
And  	asg.business_group_id		= p_business_group_id
And  	pee.effective_start_date 	between asg.effective_start_date
					and  asg.effective_end_date
And  	p_report_date 			between pee.effective_start_date
					and pee.effective_end_date;
--
   hr_utility.trace('l_effective_start_date	->'||l_effective_start_date);
   hr_utility.trace('l_pay_basis		->'||l_pay_basis);
   hr_utility.trace('l_normal_hours		->'||to_char(l_normal_hours));
   hr_utility.trace('l_work_schedule		->'||l_work_schedule);
   hr_utility.trace('l_salary			->'||to_char(l_salary));
--
	exception
		when NO_DATA_FOUND then RETURN NULL;
		when others then
			hr_utility.set_location('hr_us_reports.get_salary',10);
                        RETURN NULL;
--
end;
--
--
l_annual_salary := hr_us_ff_udfs.Convert_Period_Type
		(p_business_group_id,null,l_work_schedule,l_normal_hours,l_salary,l_pay_basis,'Year',
		 null,null,l_frequency);  -- Bug 3669973
--
   hr_utility.set_location('hr_us_reports.get_salary',15);
   hr_utility.trace('l_annual_salary 	->'||to_char(l_annual_salary));
--
return (l_annual_salary);
--
end get_salary;
--
--
procedure get_new_hire_contact(	p_person_id 		in number,
				p_business_group_id 	in number,
				p_report_date		in date,
				p_contact_name		out nocopy varchar2,
				p_contact_title		out nocopy varchar2,
				p_contact_phone		out nocopy varchar2
			      ) IS
--
v_contact_name		per_people_f.full_name%TYPE;
v_contact_title		per_jobs.name%TYPE;
v_contact_phone		per_people_f.work_telephone%TYPE;

CURSOR c_new_hire_record IS
	Select	ppf.full_name,
		job.name,
		ppf.work_telephone
	From
		per_people_f 		ppf,
		per_assignments_f	paf,
		per_jobs		job
	Where
		ppf.person_id 			= p_person_id
	And	ppf.business_group_id + 0 	= p_business_group_id
	And	p_report_date 	between paf.effective_start_date
				and 	paf.effective_end_date
	And	ppf.person_id			= paf.person_id
	And 	paf.assignment_type		= 'E'
	And 	paf.primary_flag 		= 'Y'
	And	p_report_date 	between paf.effective_start_date
				and 	paf.effective_end_date
	And	paf.job_id	= job.job_id(+);

--
begin
--
hr_utility.set_location('Entered hr_us_reports.get_new_hire_contact',5);
--
OPEN c_new_hire_record;

--LOOP
	FETCH c_new_hire_record INTO v_contact_name, v_contact_title, v_contact_phone;

	p_contact_name  := v_contact_name;
	p_contact_title := v_contact_title;
	p_contact_phone	:= v_contact_phone;

--	EXIT WHEN c_new_hire_record%NOTFOUND;
--END LOOP;

CLOSE c_new_hire_record;
--
hr_utility.trace('Contact name : '||v_contact_name);
hr_utility.trace('Contact title : '||v_contact_title);
hr_utility.set_location('Leaving hr_us_reports.get_new_hire_contact',10);
--
exception
	when no_data_found then
		hr_utility.set_location('Error found in hr_us_reports.get_new_hire.contact',20);
		NULL;
	when others then
		hr_utility.set_location('Error found in hr_us_reports.get_new_hire_contact',15);
--
end get_new_hire_contact;
--
--
procedure get_address(p_location_id in number, p_address out nocopy varchar2) IS
--
f_address varchar2(300) := NULL;
--
v_address_line_1	hr_locations.address_line_1%TYPE;
v_address_line_2	hr_locations.address_line_2%TYPE;
v_address_line_3	hr_locations.address_line_3%TYPE;
v_town_or_city		hr_locations.town_or_city%TYPE;
v_region_2		hr_locations.region_2%TYPE;
v_postal_code		hr_locations.postal_code%TYPE;
--
cursor get_location_record is
  select address_line_1, address_line_2, address_line_3,
	 town_or_city, region_2, postal_code
  from hr_locations
  where  location_id = p_location_id;
--
begin
--
hr_utility.set_location('Entered hr_us_reports.get_address', 5);
--
  open get_location_record;
--
  fetch get_location_record into v_address_line_1, v_address_line_2,
	v_address_line_3, v_town_or_city, v_region_2, v_postal_code;
--
hr_utility.set_location('hr_us_reports.get_address', 10);
--
  if get_location_record%found
  then
--
    if v_address_line_1 is not null
    then
      f_address := rpad(v_address_line_1,48,' ');
    end if;
--
    if v_address_line_2 is not null
    then
      f_address := f_address ||
                   rpad(v_address_line_2,48,' ');
    end if;
--
    if v_address_line_3 is not null
    then
       f_address := f_address ||
                    rpad(v_address_line_3,48,' ');
    end if;
--
    if v_town_or_city is not null
    then
       f_address:= f_address || rpad(v_town_or_city,48,' ');
    end if;
--
    if v_region_2 is not null
    then
      f_address := f_address ||v_region_2||' '||
                   v_postal_code;
    end if;
--
    close get_location_record;
--
hr_utility.set_location('hr_us_reports.get_address', 15);
--
   hr_utility.trace('location is '|| f_address);
    p_address := f_address;
--
  end if;
--
exception
	when others then
		hr_utility.trace('Error in hr_us_reports.get_address');
		hr_utility.set_location('hr_us_reports.get_address', 20);
--
end get_address;
--
--
procedure get_address_31(p_location_id in number, p_address out nocopy varchar2) IS
f_address varchar2(155) := NULL;
f_city_state varchar2(50) := NULL;
address_record  hr_locations%rowtype;
cursor get_location_record is
  select *
  from hr_locations
  where  location_id = p_location_id;
begin
  open get_location_record;
  fetch get_location_record into address_record;
  if get_location_record%found
  then
    if address_record.address_line_1 is not null
    then
      f_address := rpad(substr(address_record.address_line_1,1,30),31,' ');
    end if;
    if address_record.address_line_2 is not null
    then
      f_address := f_address ||
                   rpad(substr(address_record.address_line_2,1,30),31,' ');
    end if;
    --
    if address_record.address_line_3 is not null
    then
       f_address := f_address ||
                    rpad(substr(address_record.address_line_3,1,30),31,' ');
    end if;
    --
    if address_record.town_or_city is not null
    then
       f_city_state := substr(address_record.town_or_city,1,25);
    end if;
    --
    if address_record.region_2 is not null
    then
      f_city_state := f_city_state || ', ' || address_record.region_2;
    end if;
    if f_city_state is not null
    then
      f_address := f_address || rpad(substr(f_city_state,1,30),31,' ');
    end if;
    --
    if address_record.postal_code is not null
    then
      f_address := f_address ||
                   substr(address_record.postal_code,1,12);
    end if;
    --
    close get_location_record;
   hr_utility.trace('location is '|| f_address);
    p_address := f_address;
  end if;
end get_address_31;
--
--



procedure get_address_3lines(p_person_id in number,
                             p_effective_date  in date,
                             p_addr_line1 out nocopy varchar2,
                             p_addr_line2 out nocopy varchar2,
                             p_city_state_zip out nocopy varchar2 ) IS
--
f_addr_line1 varchar2(240) := NULL;
f_addr_line2 varchar2(240) := NULL;
f_city_state_zip varchar2(250) := NULL;
--
address_record  per_addresses%rowtype;
cursor get_address_record is
  select * from per_addresses
  where  person_id = p_person_id
  and    primary_flag='Y'
  and    nvl(date_to, p_effective_date) >= p_effective_date;
--
begin
  open get_address_record;
  fetch get_address_record into address_record;
  if get_address_record%found
  then
      f_addr_line1 := rpad(substr(address_record.address_line1,1,30),31,' ');

      f_addr_line2 := rpad(substr(address_record.address_line2,1,30),31,' ');

   f_city_state_zip := substr(address_record.town_or_city,1,17)  || ', ' ||
                          address_record.region_2     || ' ' ||
                          address_record.postal_code;
      close get_address_record;
    --
    p_addr_line1 := f_addr_line1;
    p_addr_line2 := f_addr_line2;
    p_city_state_zip := f_city_state_zip;
    hr_utility.trace('address is '|| f_addr_line1 );
    hr_utility.trace( f_addr_line2 );
    hr_utility.trace( f_city_state_zip );
  end if;
end get_address_3lines;
--

FUNCTION break_address_line
(p_addr_line  VARCHAR2) return VARCHAR2
--
AS
--
begin
	if length(p_addr_line)<=30 then
	  return rpad(substr(p_addr_line,1,30),31,' ');
	else
	  return rpad(substr(p_addr_line,1,30),31,' ') || rpad(substr(p_addr_line,31,40),31,' ');
	end if;

end break_address_line;

procedure get_employee_address(p_person_id in number,
                               p_address   out nocopy varchar2) IS
--
f_address varchar2(340) := NULL;

--
-- address_record per_addresses%rowtype;
--
v_address_line1 per_addresses.address_line1%TYPE;
v_address_line2 per_addresses.address_line2%TYPE;
v_address_line3 per_addresses.address_line3%TYPE;
v_town_or_city per_addresses.town_or_city%TYPE;
v_region_2 per_addresses.region_2%TYPE;
v_postal_code per_addresses.postal_code%TYPE;
--
cursor get_address_record is
select address_line1, address_line2, address_line3,
town_or_city, region_2, postal_code
from per_addresses
where person_id = p_person_id
and primary_flag = 'Y'
and nvl(date_to, sysdate) >= sysdate;
--
begin
--
hr_utility.set_location('Entered hr_us_reports.get_employee_address', 0);
--
open get_address_record;
--
fetch get_address_record into v_address_line1, v_address_line2,
v_address_line3, v_town_or_city, v_region_2, v_postal_code;
--
hr_utility.set_location('Entered hr_us_reports.get_employee_address', 5);
--
if get_address_record%found
then
--
if v_address_line1 is not null
then
f_address := break_address_line (v_address_line1) ;
end if;
--
if v_address_line2 is not null
then
f_address := f_address || break_address_line(v_address_line2) ;

end if;
--
if v_address_line3 is not null
then
f_address := f_address || break_address_line(v_address_line3) ;

end if;
--
if v_town_or_city is not null
then
f_address:= f_address || rpad(v_town_or_city,31,' ');
end if;
--
if v_region_2 is not null
then
f_address := f_address ||v_region_2||' '||
v_postal_code;
end if;
--
insert into pay_us_rpt_totals(ATTRIBUTE30,attribute1) values(f_address,'test1');
commit;
hr_utility.set_location('hr_us_reports.get_employee_address', 10);
close get_address_record;
--
hr_utility.trace('Person Address is '|| f_address);
--
p_address := f_address;
--
end if;
--
hr_utility.set_location('Leaving hr_us_reports.get_employee_address', 15);
--
exception when NO_DATA_FOUND then NULL;
--
end get_employee_address;

--
--
procedure get_county_address(p_location_id in number, p_address out nocopy varchar2) IS
f_address varchar2(300) := NULL;
address_record  hr_locations%rowtype;
cursor get_location_record is
  select * from hr_locations
  where  location_id = p_location_id;
begin
  open get_location_record;
  fetch get_location_record into address_record;
  if get_location_record%found
  then
    if address_record.address_line_1 is not null
    then
      f_address := rpad(address_record.address_line_1,40,' ');
    end if;
    if address_record.address_line_2 is not null
    then
      f_address := f_address ||
                   rpad(address_record.address_line_2,40,' ');
    end if;
    if address_record.address_line_3 is not null
    then
       f_address := f_address ||
                    rpad(address_record.address_line_3,40,' ');
    end if;
    if address_record.town_or_city is not null
    then
       f_address:= f_address || rpad(address_record.town_or_city,40,' ');
    end if;
    if address_record.region_1 is not null
    then
      f_address := f_address || rpad(address_record.region_1,40,' ');
    end if;
    if address_record.region_2 is not null
    then
      f_address := f_address ||address_record.region_2||' '||
                   address_record.postal_code;
    end if;
    close get_location_record;
   hr_utility.trace('location is '|| f_address);
    p_address := f_address;
  end if;
end get_county_address;
--
--
--
--
procedure get_activity(p_establishment_id in number, p_activity out nocopy varchar2) IS
f_activity varchar2(300) := NULL;
activity_record  hr_establishments_v%rowtype;
cursor get_establishment_record is
  select * from hr_establishments_v
  where  establishment_id = p_establishment_id;
begin
  open get_establishment_record;
  fetch get_establishment_record into activity_record;
  if get_establishment_record%found
  then
    if activity_record.activity_line1 is not null
    then
      f_activity := rpad(activity_record.activity_line1,40,' ');
    end if;
    if activity_record.activity_line2 is not null
    then
      f_activity := f_activity ||
                   rpad(activity_record.activity_line2,40,' ');
    end if;
    if activity_record.activity_line3 is not null
    then
       f_activity := f_activity ||
                    rpad(activity_record.activity_line3,40,' ');
    end if;
    if activity_record.activity_line4 is not null
    then
       f_activity := f_activity ||
                    rpad(activity_record.activity_line4,40,' ');
    end if;
    close get_establishment_record;
   hr_utility.trace('establishment activity is '|| f_activity);
    p_activity := f_activity;
  end if;
end get_activity;
--
FUNCTION get_consolidation_set
(p_consolidation_set_id NUMBER) return VARCHAR2
--
AS
l_consolidation_set_name VARCHAR2(60);
--
begin
--
 hr_utility.trace('Entered Get_consolidation_set');
 --
 begin
   hr_utility.set_location('hr_us_reports.get_consolidation_set',5);
   SELECT consolidation_set_name
   INTO   l_consolidation_set_name
   FROM   pay_consolidation_sets
   WHERE  consolidation_set_id = p_consolidation_set_id;
   --
   exception when NO_DATA_FOUND then RETURN NULL;
 end;
 --
 return l_consolidation_set_name;
--
end get_consolidation_set;
--
--
FUNCTION get_payment_type_name
(p_payment_type_id NUMBER) return VARCHAR2
--
AS
l_payment_type_name VARCHAR2(60);
--
begin
--
 hr_utility.trace('Entered Get_payment_type_name');
 --
 begin
   hr_utility.set_location('hr_us_reports.get_payment_type_name',5);
   SELECT ppt_tl.payment_type_name
   INTO   l_payment_type_name
   FROM   pay_payment_types_tl ppt_tl,
          pay_payment_types ppt
   WHERE  ppt_tl.payment_type_id = ppt.payment_type_id
   and    userenv('LANG') = ppt_tl.language
   and    ppt.payment_type_id = p_payment_type_id;
   --
   exception when NO_DATA_FOUND then RETURN NULL;
 end;
 --
 return l_payment_type_name;
--
end get_payment_type_name;
--
--
FUNCTION get_element_type_name
(p_element_type_id NUMBER) return VARCHAR2
--
AS
l_element_type_name VARCHAR2(60);
--
begin
--
 hr_utility.trace('Entered Get_element_type_name');
 --
 begin
   hr_utility.set_location('hr_us_reports.get_element_type_name',5);
   SELECT pet_tl.element_name
   INTO   l_element_type_name
   FROM   pay_element_classifications pec,
          pay_element_types_f_tl pet_tl,
          pay_element_types_f pet
   WHERE  pet_tl.element_type_id = pet.element_type_id
   and    userenv('LANG') = pet_tl.language
   and    pec.classification_id = pet.classification_id
   AND    pet.element_type_id = p_element_type_id;
   --
   exception when NO_DATA_FOUND then RETURN NULL;
 end;
 --
 return l_element_type_name;
--
end get_element_type_name;
--
--
FUNCTION get_tax_unit
(p_tax_unit_id NUMBER) return VARCHAR2
--
AS
l_tax_unit_name VARCHAR2(240);
--
begin
--
 hr_utility.trace('Entered Get_tax_unit');
 --
 begin
   hr_utility.set_location('hr_us_reports.get_tax_unit',5);
   SELECT name
   INTO   l_tax_unit_name
   FROM   hr_organization_units
   WHERE  organization_id = p_tax_unit_id;
   --
   exception when NO_DATA_FOUND then RETURN NULL;
 end;
 --
 return l_tax_unit_name;
--
end get_tax_unit;
--
--
FUNCTION get_person_name
(p_person_id NUMBER) return VARCHAR2
--
AS
l_person_name VARCHAR2(240);
--
begin
--
 hr_utility.trace('Entered get_person_name');
 --
 begin
   hr_utility.set_location('hr_us_reports.get_person_name',5);
   SELECT distinct full_name
   INTO   l_person_name
   FROM   per_people_f	ppf
   WHERE  person_id = p_person_id
   AND	  ppf.effective_start_date =
        	(select max(effective_start_date)
         	from   per_people_f    ppf1
         	where  ppf1.person_id  = ppf.person_id);
   --
   exception when NO_DATA_FOUND then RETURN NULL;
 end;
 --
 return l_person_name;
--
end get_person_name;
--
--
FUNCTION get_payroll_action
(p_payroll_action_id NUMBER) return VARCHAR2
--
AS
l_action_type CHAR(1);
l_payroll_action_name VARCHAR2(60);
--
begin
--
 hr_utility.trace('Entered Get_payroll_action');
 --
 begin
   hr_utility.set_location('hr_us_reports.get_payroll_action',5);
   SELECT action_type
   INTO   l_action_type
   FROM   pay_payroll_actions
   WHERE  payroll_action_id = p_payroll_action_id;
   --
   exception when NO_DATA_FOUND then RETURN NULL;
 end;
 if l_action_type = 'P' then
 begin
   hr_utility.set_location('hr_us_reports.get_payroll_action',10);
   SELECT ppa.display_run_number || '-' || pcs.consolidation_set_name
          || '-' || ppa.effective_date || '-' || ppa.payroll_action_id
   INTO   l_payroll_action_name
   FROM   pay_consolidation_sets pcs,
          pay_payroll_actions ppa
   WHERE  ppa.consolidation_set_id = pcs.consolidation_set_id
   AND    ppa.payroll_action_id = p_payroll_action_id;
 exception
   when no_data_found then RETURN NULL;
 end;
 elsif l_action_type = 'R' then
 begin
   hr_utility.set_location('hr_us_reports.get_payroll_action',15);
   SELECT ppa.display_run_number || '-' || has.assignment_set_name
          || '-' || pes.element_set_name
   INTO   l_payroll_action_name
   FROM   hr_assignment_sets has,
          pay_element_sets pes,
          pay_payroll_actions ppa
   WHERE  has.assignment_set_id(+) = ppa.assignment_set_id
   AND    pes.element_set_id(+) = ppa.element_set_id
   AND    ppa.payroll_action_id = p_payroll_action_id;
 exception
   when no_data_found then RETURN NULL;
 end;
 elsif l_action_type = 'Q' then
 begin
   SELECT ppa.display_run_number || '-' || ppe.full_name
   INTO   l_payroll_action_name
   FROM   per_people_f ppe,
          per_all_assignments_f pas,
          pay_assignment_actions paa,
          pay_payroll_actions ppa
   WHERE  ppe.person_id = pas.person_id
   AND    pas.assignment_id = paa.assignment_id
   AND    paa.payroll_action_id = ppa.payroll_action_id
   AND    ppa.payroll_action_id = p_payroll_action_id
   AND    ppa.effective_date between ppe.effective_start_date
                                 and ppe.effective_end_date
   AND    ppa.effective_date between pas.effective_start_date
                                 and pas.effective_end_date;
 exception
   when no_data_found then RETURN NULL;
 end;
 end if;
 --
 return l_payroll_action_name;
--
end get_payroll_action;
--
--
FUNCTION get_legislation_code
(p_business_group_id NUMBER) return VARCHAR2
--
AS
l_legislation_code VARCHAR2(30);
--
begin
--
 hr_utility.trace('Entered Get_legislation_code');
 --
 begin
   hr_utility.set_location('hr_us_reports.get_legislation_code',5);
   SELECT org_information9
   INTO   l_legislation_code
   FROM   hr_organization_information
   WHERE  organization_id = p_business_group_id
   AND    UPPER(org_information_context) = 'BUSINESS GROUP INFORMATION';
   --
   exception when NO_DATA_FOUND then RETURN NULL;
 end;
 --
 return l_legislation_code;
--
end get_legislation_code;
--
--
FUNCTION get_defined_balance_id
(p_balance_name VARCHAR2, p_dimension_suffix VARCHAR2,
 p_business_group_id NUMBER) return NUMBER
--
AS
l_defined_balance_id NUMBER;
l_defbal_name        CHAR(81);
l_count              NUMBER;
l_found              BOOLEAN;
--
begin
--
 hr_utility.trace('Entered Get_defined_balance_id');
 --
 -- Search for the defined balance in the Cache.
 --
 l_defbal_name := p_balance_name||p_dimension_suffix||p_business_group_id;
 l_count := 1;
 l_found := FALSE;
 while (l_count < g_nxt_free_defbal and l_found = FALSE) loop
    if (l_defbal_name = g_defbal_tbl_name(l_count)) then
       l_defined_balance_id := g_defbal_tbl_id(l_count);
       l_found := TRUE;
    end if;
    l_count := l_count + 1;
 end loop;
 --
 -- If the balance is not in the Cache get it from the database.
 --
 if (l_found = FALSE) then
    begin
      hr_utility.set_location('hr_us_reports.get_defined_balance_id',5);
/* Legislation code is added in this query so that it does not
fetch multiple values after Canadian Payroll is installed - mmukherj*/
      SELECT pdb.defined_balance_id
      INTO   l_defined_balance_id
      FROM   pay_defined_balances   pdb
      ,      pay_balance_dimensions pbd
      ,      pay_balance_types      pbt
      WHERE  pbt.balance_name = p_balance_name
      AND    ((pbt.business_group_id IS NULL
               AND pbt.legislation_code = 'US')
              OR pbt.business_group_id + 0 = p_business_group_id)
      AND    pbd.database_item_suffix = p_dimension_suffix
      AND    pdb.balance_type_id = pbt.balance_type_id
      AND    pdb.balance_dimension_id = pbd.balance_dimension_id
      AND    (pdb.business_group_id IS NULL
              OR pdb.business_group_id + 0 = p_business_group_id);
      --
      -- Place the defined balance in cache.
      --
      g_defbal_tbl_name(g_nxt_free_defbal) := l_defbal_name;
      g_defbal_tbl_id(g_nxt_free_defbal) := l_defined_balance_id;
      g_nxt_free_defbal := g_nxt_free_defbal + 1;
      --
      exception when NO_DATA_FOUND then RETURN NULL;
    end;
 end if;
 --
 return l_defined_balance_id;
--
end get_defined_balance_id;
--
--
FUNCTION get_startup_defined_balance
(p_reporting_name VARCHAR2, p_dimension_suffix VARCHAR2) return NUMBER
--
AS
l_defined_balance_id NUMBER;
--
begin
--
 hr_utility.trace('Entered Get_startup_defined_balance');
 --
 begin
   hr_utility.set_location('hr_us_reports.get_startup_defined_balance',5);
   SELECT pdb.defined_balance_id
   INTO   l_defined_balance_id
   FROM   pay_defined_balances   pdb
   ,      pay_balance_dimensions pbd
   ,      pay_balance_types      pbt
   WHERE  pbt.reporting_name    = p_reporting_name
   AND    pbd.database_item_suffix = p_dimension_suffix
   AND    pdb.balance_type_id      = pbt.balance_type_id
   AND    pdb.balance_dimension_id = pbd.balance_dimension_id;
   --
   exception when NO_DATA_FOUND then RETURN NULL;
 end;
 --
 return l_defined_balance_id;
--
end get_startup_defined_balance;
--
--
-- Gets defined balance id using balance type id for seeded balances
--
FUNCTION get_defined_balance_by_type
(p_box_num VARCHAR2, p_dimension_suffix VARCHAR2) return NUMBER
--
AS
l_defined_balance_id NUMBER;
l_balance_type_id    NUMBER;
l_balance_type_name  VARCHAR2(30);
--
begin
--
 hr_utility.trace('Entered Get_defined_balance_by_type');
 --
 -- **NOTE** We do not yet have the 'US_TAX DEDUCTIONS' category seeded yet.
 --
   hr_utility.set_location('hr_us_reports.get_defined_balance_by_type',5);
 --
   IF
      p_box_num = '10' THEN
	l_balance_type_name := 'Dependent Care'; 	-- *OK*
   ELSIF
      p_box_num = '15c' THEN
	l_balance_type_name := 'W2 Pension Plan';	-- *OK*
   ELSIF
      p_box_num = '15g' THEN
	l_balance_type_name := 'Def Comp 401K';         -- *OK*
   ELSIF
      p_box_num = '12' THEN
        l_balance_type_name := 'W2 Fringe Benefits';
   END IF;
 --
   begin
     SELECT pbt.balance_type_id
     INTO   l_balance_type_id
     FROM   pay_balance_types pbt
     WHERE  pbt.balance_name = l_balance_type_name
     AND    pbt.business_group_id is null
     AND    pbt.legislation_code = 'US';
   exception
     when NO_DATA_FOUND then RETURN NULL;
   end;
--
 begin
   hr_utility.set_location('hr_us_reports.get_defined_balance_by_type',10);
   --
   SELECT pdb.defined_balance_id
   INTO   l_defined_balance_id
   FROM   pay_defined_balances   pdb
   ,      pay_balance_dimensions pbd
   ,      pay_balance_types      pbt
   WHERE  pbt.balance_type_id      = l_balance_type_id
   AND    pbd.database_item_suffix = p_dimension_suffix
   AND    pdb.balance_type_id      = pbt.balance_type_id
   AND    pdb.balance_dimension_id = pbd.balance_dimension_id;
   --
   exception
     when NO_DATA_FOUND then RETURN NULL;
 end;
 --
 return l_defined_balance_id;
--
end get_defined_balance_by_type;
--
--
FUNCTION get_ben_class_name
(p_session_date DATE,
 p_benefit_classification_id NUMBER) return VARCHAR2 IS
--
v_benefit_class_name ben_benefit_classifications.benefit_classification_name%type;
--
begin
hr_utility.trace('Entered hr_reports.get_ben_class_name');
--
hr_utility.set_location('hr_reports.get_ben_class_name',5);
if p_benefit_classification_id is null then
     null;
  else
  begin
 hr_utility.set_location('hr_reports.get_ben_class_name',10);
select benefit_classification_name
into v_benefit_class_name
from ben_benefit_classifications
where benefit_classification_id = p_benefit_classification_id;
 exception
   when no_data_found then RETURN NULL;
 end;
 end if;
--
 hr_utility.trace('Leaving hr_reports.get_ben_class_name');
--
 return v_benefit_class_name;
--
end get_ben_class_name;
--
--
FUNCTION get_cobra_qualifying_event
( p_qualifying_event VARCHAR2 ) return VARCHAR2 IS
--
v_qualifying_event_meaning hr_lookups.meaning%type;
--
BEGIN
hr_utility.trace('Entered hr_reports.get_cobra_qualifying_event');
--
hr_utility.set_location('hr_reports.get_cobra_qualifying_event',5);
IF p_qualifying_event IS NULL
THEN
     NULL;
  ELSE
  BEGIN
 hr_utility.set_location('hr_reports.get_cobra_qualifying_event',10);
   SELECT  meaning
   INTO    v_qualifying_event_meaning
   FROM    hr_lookups
   WHERE   lookup_type = 'US_COBRA_EVENT'
   AND     lookup_code = p_qualifying_event;
 EXCEPTION
   WHEN no_data_found THEN RETURN NULL;
 END;
 END IF;
--
 hr_utility.trace('Leaving hr_reports.get_cobra_qualifying_event');
--
 return v_qualifying_event_meaning;
--
END get_cobra_qualifying_event;
--
--
FUNCTION get_cobra_status
( p_cobra_status VARCHAR2 ) return VARCHAR2 IS
--
v_cobra_status_meaning hr_lookups.meaning%type;
--
BEGIN
hr_utility.trace('Entered hr_reports.get_cobra_status');
--
hr_utility.set_location('hr_reports.get_cobra_status',5);
IF p_cobra_status IS NULL
THEN
     NULL;
  ELSE
  BEGIN
 hr_utility.set_location('hr_reports.get_cobra_status',10);
   SELECT  meaning
   INTO    v_cobra_status_meaning
   FROM    hr_lookups
   WHERE   lookup_type = 'US_COBRA_STATUS'
   AND     lookup_code = p_cobra_status;
 EXCEPTION
   WHEN no_data_found THEN RETURN NULL;
 END;
 END IF;
--
 hr_utility.trace('Leaving hr_reports.get_cobra_status');
--
 return v_cobra_status_meaning;
--
END get_cobra_status;
--
--
--
-- Finds Reporting Entity for an organization entered which is an establishment
-- Works up the organization hierarchy and returns the first reporting entity
-- encountered in the hierarchy.
--
FUNCTION get_est_tax_unit (p_starting_org_id number,
                           p_org_structure_version_id number
                          ) RETURN number
IS
--
-- WWBUG 2331831
-- Fixed connect by so connect by loop not raised.
--
CURSOR get_parent IS
    SELECT           ose.organization_id_parent
    FROM             per_org_structure_elements ose
    WHERE            ose.org_structure_version_id = p_org_structure_version_id
    START WITH       ose.organization_id_child = p_starting_org_id
    CONNECT BY PRIOR ose.organization_id_parent = ose.organization_id_child
    AND              ose.org_structure_version_id = p_org_structure_version_id;
--
-- WWBUG 2331831
--
    parent_tax_unit_id  number(15);
    tax_unit_flag    char(2);
--
BEGIN
    parent_tax_unit_id := null;
    tax_unit_flag     := 'N';
    OPEN get_parent;
    WHILE tax_unit_flag = 'N' LOOP
      FETCH get_parent INTO parent_tax_unit_id;
      hr_utility.trace('Parent tax unit >'||parent_tax_unit_id);
      EXIT WHEN get_parent%NOTFOUND;
      hr_utility.trace('Parent tax unit >'||parent_tax_unit_id);
/* sackumar */
        begin
            SELECT 'Y'
            INTO   tax_unit_flag
            FROM   hr_organization_information hoi
            WHERE  hoi.organization_id = parent_tax_unit_id
            AND    hoi.ORG_INFORMATION1 = 'HR_LEGAL'
            AND    hoi.ORG_INFORMATION2 = 'Y' ;
        exception
           when no_data_Found then
              tax_unit_flag := 'N';
        end;
/* previous */
/* Bug No 4350592
	SELECT decode(tax_unit_id,'','N','Y')
        INTO   tax_unit_flag
        FROM   hr_tax_units_v htuv,
               hr_organization_units hou
        WHERE  htuv.tax_unit_id(+) = hou.organization_id
        AND    hou.organization_id = parent_tax_unit_id;
*/
    END LOOP;
    CLOSE get_parent;
--
    hr_utility.trace('Est tax unit >'||parent_tax_unit_id);
    return (parent_tax_unit_id);
--
end get_est_tax_unit;
--
-- bug 2722353 - new function.
--
-- Finds Reporting Entity for an organization entered which is an establishment
-- Works up the organization hierarchy and returns the first reporting entity
-- encountered in the hierarchy.  This function differs from get_est_tax_unit
-- in that it will return the first reporting entity encountered in the
-- hierarchy if this top organization id is entered as the starting org.
-- In this situation the function above returns null.
--
FUNCTION get_hr_est_tax_unit (p_starting_org_id number,
                              p_org_structure_version_id number
                              ) RETURN number
IS
--
-- WWBUG 2331831
-- Fixed connect by so connect by loop not raised.
--
CURSOR get_hr_parent IS
    SELECT           ose.organization_id_parent
    FROM             per_org_structure_elements ose
    WHERE            ose.org_structure_version_id = p_org_structure_version_id
    START WITH       ose.organization_id_child = p_starting_org_id
    CONNECT BY PRIOR ose.organization_id_parent = ose.organization_id_child
    AND              ose.org_structure_version_id = p_org_structure_version_id;
--
-- WWBUG 2331831
--
/* sackumar */
CURSOR check_if_top_org IS
            SELECT hoi.organization_id
            FROM   hr_organization_information hoi
            WHERE  hoi.organization_id = p_starting_org_id
            AND    hoi.ORG_INFORMATION1 = 'HR_LEGAL'
            AND    hoi.ORG_INFORMATION2 = 'Y' ;

/* previous */
/* CURSOR check_if_top_org IS
   SELECT htuv.tax_unit_id
     FROM hr_tax_units_v htuv
    WHERE htuv.tax_unit_id = p_starting_org_id;
*/
--
-- BUG3141907
--
/* sackumar */
cursor csr_tax_unit_flag(p_tax_unit_id number) is   -- Bug 3624095
            SELECT hoi.organization_id
            FROM   hr_organization_information hoi
            WHERE  hoi.organization_id = p_tax_unit_id
            AND    hoi.ORG_INFORMATION1 = 'HR_LEGAL'
            AND    hoi.ORG_INFORMATION2 = 'Y' ;

/* previous */
/*cursor csr_tax_unit_flag(p_tax_unit_id number) is   -- Bug 3624095
   SELECT htuv.tax_unit_id
          FROM hr_tax_units_v htuv,
               hr_organization_units hou
          WHERE htuv.tax_unit_id(+) = hou.organization_id
          AND hou.organization_id = p_tax_unit_id;
*/--
--
    parent_hr_tax_unit_id  number(15);
    hr_tax_unit_id  number(15);
    hr_tax_unit_flag    char(2);
    l_tax_unit_id       number(15);
    l_proc varchar2(72);
--
BEGIN
    parent_hr_tax_unit_id := null;
    hr_tax_unit_id  := null;
    hr_tax_unit_flag := 'N';
    l_proc := 'get_hr_est_tax_unit';

--
   hr_utility.set_location('Entering...' || l_proc,10);
   OPEN check_if_top_org;
   LOOP
     BEGIN
        FETCH check_if_top_org INTO hr_tax_unit_id;
        EXIT WHEN check_if_top_org%NOTFOUND;
        EXCEPTION
        WHEN NO_DATA_FOUND
        THEN hr_tax_unit_id := -1;
     END;
   END LOOP;
   CLOSE check_if_top_org;
   --
   IF p_starting_org_id = hr_tax_unit_id
   THEN
      hr_utility.set_location(l_proc,20);
      parent_hr_tax_unit_id := p_starting_org_id;
      --
   ELSE
      --
      --
      OPEN get_hr_parent;
        WHILE hr_tax_unit_flag = 'N'
        LOOP
           FETCH get_hr_parent INTO parent_hr_tax_unit_id;
           --hr_utility.trace('Parent hr_tax unit >'||parent_hr_tax_unit_id);
           EXIT WHEN get_hr_parent%NOTFOUND;
           hr_utility.trace('Parent hr_tax unit >'||parent_hr_tax_unit_id);

          /* commented out for BUG3141907
           --
           SELECT decode(hr_tax_unit_id,'','N','Y')
             INTO hr_tax_unit_flag
             FROM hr_tax_units_v htuv,
                  hr_organization_units hou
            WHERE htuv.tax_unit_id(+) = hou.organization_id
              AND hou.organization_id = parent_hr_tax_unit_id;
          */
           --
           -- BUG3141907
           --
           hr_utility.set_location(l_proc,30);
           open csr_tax_unit_flag(parent_hr_tax_unit_id);
           hr_utility.set_location(l_proc,31);
           fetch csr_tax_unit_flag into l_tax_unit_id;
           if csr_tax_unit_flag%found then
              hr_utility.set_location(l_proc,40);
              hr_tax_unit_flag := 'Y';
           else
              hr_utility.set_location(l_proc,50);
              hr_tax_unit_flag := 'N';
           end if;
           close csr_tax_unit_flag;

           hr_utility.trace('hr_tax_unit_flag > '||hr_tax_unit_flag);
           hr_utility.set_location(l_proc,50);
        END LOOP;
      CLOSE get_hr_parent;
      --
      --
   END IF;
   --
   hr_utility.trace('Est hr_tax unit >'||parent_hr_tax_unit_id);
   hr_utility.set_location('Leaving...' || l_proc,100);
   return (parent_hr_tax_unit_id);
   --
end get_hr_est_tax_unit;
--
-- end bug fix 2722353
--
FUNCTION get_org_hierarchy_name (p_org_structure_version_id number
                                ) RETURN varchar2
IS
--
l_org_hierarchy_name VARCHAR2(30);
--
begin
  SELECT pos.name
  INTO   l_org_hierarchy_name
  FROM   per_organization_structures pos,
         per_org_structure_versions posv
  WHERE  pos.organization_structure_id = posv.organization_structure_id
  AND    posv.org_structure_version_id = p_org_structure_version_id;
--
return l_org_hierarchy_name;
--
  exception when NO_DATA_FOUND then RETURN NULL;
--
end get_org_hierarchy_name;
--
--
--
FUNCTION get_state_name(p_state_code varchar2
                      ) RETURN varchar2
IS
--
l_state_name VARCHAR2(60);
--
begin
--
hr_utility.set_location('Entered hr_us_reports.get_state_name',5);
--
  SELECT state_name
  INTO   l_state_name
  FROM   pay_us_states
  WHERE  state_abbrev = p_state_code;
--
hr_utility.set_location('Leaving hr_us_reports.get_state_name',10);
--
return l_state_name;
--
  exception when NO_DATA_FOUND then RETURN NULL;
--
end get_state_name;
--
--
FUNCTION get_org_name (p_organization_id number, p_business_group_id number
                      ) RETURN varchar2
IS
--
l_org_name VARCHAR2(240);
--
begin
--
hr_utility.set_location('Entered hr_us_reports.get_org_name',5);
--
  SELECT name
  INTO   l_org_name
  FROM   hr_organization_units
  WHERE  organization_id   = p_organization_id
  AND    business_group_id + 0 = p_business_group_id;
--
hr_utility.set_location('Leaving hr_us_reports.get_org_name',10);
return l_org_name;
--
  exception when NO_DATA_FOUND then RETURN NULL;
	    when others then
		hr_utility.set_location('Error found in hr_us_reports.get_org_name',15);
                RETURN NULL;
--
end get_org_name;
--
--
FUNCTION get_location_code (p_location_id number) RETURN varchar2
IS
--
l_location_code VARCHAR2(60);
--
begin
  SELECT location_code
  INTO   l_location_code
  FROM   hr_locations
  WHERE  location_id   = p_location_id;
--
return l_location_code;
--
  exception when NO_DATA_FOUND then RETURN NULL;
--
end get_location_code;
--
--
FUNCTION get_career_path_name (p_career_path_id number, p_business_group_id number
                      ) RETURN varchar2
IS
--
l_career_path_name VARCHAR2(60);
--
begin
  SELECT name
  INTO   l_career_path_name
  FROM   per_career_paths
  WHERE  career_path_id   = p_career_path_id
  AND    business_group_id + 0 = p_business_group_id;
--
return l_career_path_name;
--
  exception when NO_DATA_FOUND then RETURN NULL;
--
end get_career_path_name;
--
--
--
FUNCTION get_aap_org_id (p_aap_name VARCHAR2, p_business_group_id NUMBER
                      ) RETURN number
IS
--
l_aap_organization_id NUMBER(15):=null;
--
begin
  SELECT aap_organization_id
  INTO   l_aap_organization_id
  FROM   hr_aap_organizations_v
  WHERE  aap_name                  = p_aap_name
  AND    business_group_id + 0 = p_business_group_id;
--
return (l_aap_organization_id);
--
  exception when NO_DATA_FOUND then RETURN NULL;
--
end get_aap_org_id;
--

--
-- bug 3182433 - new function.
--
-- Search top organization id in the hierarchy
--
--
FUNCTION get_top_org_id
  (p_business_group_id          number
  ,p_org_structure_version_id   number
  ) RETURN number
IS
--
--
--
cursor csr_get_parent(l_organization_id_child number) is
  select organization_id_parent
  from  per_org_structure_elements
  where business_group_id = p_business_group_id
  and   org_structure_version_id = p_org_structure_version_id
  and   organization_id_child = l_organization_id_child;

cursor csr_get_element is
  select '1'
  from  per_org_structure_elements
  where business_group_id = p_business_group_id
  and   org_structure_version_id = p_org_structure_version_id;

cursor csr_get_max_child_id is
  select max(organization_id_child)
  from  per_org_structure_elements
  where business_group_id = p_business_group_id
  and   org_structure_version_id = p_org_structure_version_id;

--
-- declare local variables
--
  l_proc                   varchar2(72);
  l_organization_id_child  number(15);
  l_organization_id_parent number(15);
  l_exists                 varchar2(1);
--
BEGIN

  l_proc := 'hr_us_reports.get_top_org_id';

  hr_utility.set_location('Entering...' || l_proc,10);

  open csr_get_element;
  fetch csr_get_element into l_exists;
  if csr_get_element%NOTFOUND then
    close csr_get_element;
    hr_utility.set_location(l_proc,20);
    l_organization_id_child := p_business_group_id;
  else
    close csr_get_element;
    open csr_get_max_child_id;
    fetch csr_get_max_child_id into l_organization_id_child;
    close csr_get_max_child_id;
    hr_utility.trace('l_organization_id_child : ' || l_organization_id_child);
    hr_utility.set_location(l_proc,30);
    loop
      open csr_get_parent(l_organization_id_child);
      fetch csr_get_parent into l_organization_id_parent;
      exit when csr_get_parent%NOTFOUND;
      close csr_get_parent;
      hr_utility.trace('l_organization_id_patent : ' || l_organization_id_parent);
      l_organization_id_child := l_organization_id_parent;
     end loop;
     close csr_get_parent;
  end if;
  hr_utility.trace('top_org_id is ' || l_organization_id_child);
  hr_utility.set_location('Leaving...' || l_proc,40);
  return l_organization_id_child;
  --
  exception when NO_DATA_FOUND then RETURN p_business_group_id;
  --
end get_top_org_id;
--
-- end of get_top_org_id
--
--

--
-- BUG4346783 for VETS-100 Consolidted Report
-- This function is called from Q_2_STATE query
--
FUNCTION verify_state
  (p_date_start                 in date
  ,p_date_end                   in date
  ,p_business_group_id          in number
  ,p_hierarchy_version_id       in number
  ,p_state                      in varchar2
  ) return number is
  --
  --
  l_est_node_id          number := 0;
  l_no_est_emps         number := 0;
  l_report_yes		number := 0;
--
--
-- 1.   Get Establishment Entity
--
 cursor c_est_entity is
   select
      pghn1.hierarchy_node_id
   from
      per_gen_hierarchy_nodes    pghn1
     ,hr_location_extra_info     hlei1
     ,hr_location_extra_info     hlei2
     ,hr_locations_all           eloc
   where
       (pghn1.hierarchy_version_id = P_HIERARCHY_VERSION_ID
   and pghn1.node_type = 'EST'
   and eloc.location_id = pghn1.entity_id
   and hlei1.location_id = pghn1.entity_id
   and hlei1.location_id = hlei2.location_id
   and hlei1.information_type = 'VETS-100 Specific Information'
   and hlei1.lei_information_category= 'VETS-100 Specific Information'
   and hlei2.information_type = 'Establishment Information'
   and hlei2.lei_information_category= 'Establishment Information'
   and hlei2.lei_information10 = 'N'
   and eloc.region_2 = P_STATE);
--
-- 2. Count employees within the establishment
--
-- change to per_all_assignments_f (speedier)
  cursor c_tot_emps is
     select count('ass')
     from
       per_all_assignments_f               ass,
       per_gen_hierarchy_nodes pgn
     where
         ass.business_group_id  =  P_BUSINESS_GROUP_ID
     and ass.assignment_type = 'E'
     and ass.primary_flag = 'Y'
     -- Bug# 5577840
     and P_DATE_END between ass.effective_start_date and ass.effective_end_date
     -- Replaced the following conditions with the above query.
     /*
     and ass.effective_start_date <=  P_DATE_END
     and ass.effective_end_date >=  P_DATE_START
     */
     and ass.effective_start_date = (select max(paf2.effective_start_date)
                                     from   per_all_assignments_f paf2
                                     where  paf2.person_id = ass.person_id
                                     and    paf2.primary_flag = 'Y'
                                     and    paf2.assignment_type = 'E'
                                     and    paf2.effective_start_date
                                            <=  P_DATE_END)
     AND EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE  TO_CHAR(ASS.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND hoi1.org_information_context    = 'Reporting Statuses'
              AND    hoi1.organization_id            = P_BUSINESS_GROUP_ID
              AND    ass.employment_category        = hoi2.org_information1
              AND    hoi2.organization_id            = P_BUSINESS_GROUP_ID
              AND    hoi2.org_information_context    = 'Reporting Categories'
              AND    hoi1.organization_id  =  hoi2.organization_id
              )
     ---- Bug# 5577840
    AND ass.location_id = pgn.entity_id
    AND (pgn.hierarchy_node_id = l_est_node_id
              or pgn.parent_hierarchy_node_id = l_est_node_id)
    AND  pgn.node_type in ('EST','LOC');
    -- Replaced the following condition with the above conditions.
    -- and ass.location_id = l_est_entity;
--
begin
--
--
--srw.message('50','STATE -> ' || :STATE);
  open c_est_entity;
  loop
    fetch c_est_entity into l_est_node_id;
   --srw.message('56','ENTITY ID  '||to_char(l_est_entity));
    exit when c_est_entity%notfound;
      --
      open c_tot_emps;
         fetch c_tot_emps into l_no_est_emps;
         --srw.message('56','for existing vets query total at location is  '
         --||to_char(l_no_est_emps));
      close c_tot_emps;
      --

      if l_no_est_emps < 50 -- :P_MINIMUM_NO_OF_EMPLOYEES
      then
         l_report_yes := 1;
      end if;
    end loop;
    close c_est_entity;
    return l_report_yes;
end verify_state;
--
--
--
-- This procedure Added to increase the address length form 30 to 40 for Oregon for Bug#6774707
procedure get_employee_address40(p_person_id in number,
                               p_address   out nocopy varchar2) IS
--
f_address varchar2(300) := NULL;
--
-- address_record  per_addresses%rowtype;
--
v_address_line1		per_addresses.address_line1%TYPE;
v_address_line2		per_addresses.address_line2%TYPE;
v_address_line3		per_addresses.address_line3%TYPE;
v_town_or_city		per_addresses.town_or_city%TYPE;
v_region_2		per_addresses.region_2%TYPE;
v_postal_code		per_addresses.postal_code%TYPE;
--
cursor get_address_record is
  select address_line1, address_line2, address_line3,
	 town_or_city, region_2, postal_code
  from 	 per_addresses
  where  person_id = p_person_id
  and 	 primary_flag = 'Y'
  and    nvl(date_to, sysdate) >= sysdate;
--
begin
--

hr_utility.set_location('Entered hr_us_reports.get_employee_address40', 0);
--
  open get_address_record;
--
  fetch get_address_record into v_address_line1, v_address_line2,
	v_address_line3, v_town_or_city, v_region_2, v_postal_code;
--
hr_utility.set_location('Entered hr_us_reports.get_employee_address40', 5);
--
  if get_address_record%found
  then
--
    if v_address_line1 is not null
    then
      f_address := rpad(substr(v_address_line1,1,40),41,' ');
    end if;
--
    if v_address_line2 is not null
    then
      f_address := f_address ||
                   rpad(substr(v_address_line2,1,40),41,' ');
    end if;
--
    if v_address_line3 is not null
    then
       f_address := f_address ||
                    rpad(substr(v_address_line3,1,40),41,' ');
    end if;
--
    if v_town_or_city is not null
    then
       f_address:= f_address || rpad(v_town_or_city,41,' ');
    end if;
--
    if v_region_2 is not null
    then
      f_address := f_address ||v_region_2||' '||
                   v_postal_code;
    end if;
--
hr_utility.set_location('hr_us_reports.get_employee_address40', 10);
    close get_address_record;
--
   hr_utility.trace('Person Address is '|| f_address);
--
    p_address := f_address;
--
  end if;
--
hr_utility.set_location('Leaving hr_us_reports.get_employee_address40', 15);
--
exception when NO_DATA_FOUND then NULL;
--
end get_employee_address40;



begin
   g_nxt_free_defbal := 1;
--
-- end hr_us_reports
--
end hr_us_reports;
--/
--show errors package body hr_us_reports
--
--select to_date('SQLERROR')
--from   user_errors
--where  type = 'PACKAGE BODY'
--and    name = upper('hr_us_reports')

/
