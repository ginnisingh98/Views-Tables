--------------------------------------------------------
--  DDL for Package Body PAY_ASG_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ASG_DEBUG_PKG" AS
/* $Header: pyacdebg.pkb 120.1 2005/10/05 02:39:28 schauhan noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1999 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_asg_debug_pkg

    Description : Package for the Elements Reports. The package
                  generated the output file in the specified user
                  format. The current formats supported are
                      - HTML

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     15-MAR-2002 rsirigir  115.2   2254026   GSCC Compliance inclusions
     15-AUG-2002 ahanda    115.4             Perf. changes to cursor cur_vertex
     07-JAN-2005 mreid     115.6   4103182   Changed report title
     19-MAY-2005 schauhan  115.8   4371929   Coorected the spelling for "Assignment number"
*/

  procedure print_blank_lines(p_no_of_lines  number) is

  l_blank_lines		varchar2(1000);

  begin

    l_blank_lines := '<TABLE BORDER=0>';

    for i in 1..p_no_of_lines loop

      l_blank_lines := l_blank_lines || '<TR><TD> </TD></TR>';

    end loop;

    l_blank_lines := l_blank_lines || '</TABLE>';

    fnd_file.put_line(fnd_file.output,l_blank_lines);

  end;

procedure write_data
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
	     ,p_assignment_id		  in  number) is

  cursor cur_header2 is
    select ppf.full_name,
	   ppf.employee_number,
  	   paf.assignment_number
     from  per_assignments_f paf,
        per_people_f ppf
  where ppf.person_id = paf.person_id and
        sysdate between ppf.effective_start_date and
		        ppf.effective_end_date and
        sysdate between paf.effective_start_date and
		        paf.effective_end_date and
        paf.assignment_id = p_assignment_id;


  cursor cur_assignment is select
	paf.assignment_id,
	to_char(paf.effective_start_date,'MM/DD/YYYY') effective_start_date,
	decode(to_char(paf.effective_end_date,'MM/DD/YYYY'),'12/31/4712',NULL,to_char(paf.effective_end_date,'MM/DD/YYYY')) effective_end_date,
	paf.location_id location_id,
	hl.location_code location_code,
	ppf.payroll_id payroll_id,
	ppf.payroll_name payroll_name,
	paf.pay_basis_id pay_basis_id,
	ppb.name name,
	ltrim(rtrim(paf.soft_coding_keyflex_id)) sfckid
  from  per_assignments_f paf,
     	per_pay_bases ppb,
     	pay_payrolls_f ppf,
     	hr_locations hl
  where assignment_id = p_assignment_id
	and paf.location_id = hl.location_id
	and paf.pay_basis_id = ppb.pay_basis_id
	and paf.payroll_id = ppf.payroll_id
	and sysdate between
    	ppf.effective_start_date and ppf.effective_end_date;

  cursor cur_person is select
	person_id, full_name,
	to_char(effective_start_date,'MM/DD/YYYY') effective_start_date,
	decode(to_char(effective_end_date,'MM/DD/YYYY'),'12/31/4712',NULL,
	  to_char(effective_end_date,'MM/DD/YYYY')) effective_end_date
  from per_people_f
  where person_id in (select person_id
                   from per_assignments_f
                   where assignment_id = p_assignment_id);

  cursor cur_address is select
	ltrim(rtrim(primary_flag)) primary_flag,
	ltrim(rtrim(region_1)) region_1,
 	ltrim(rtrim(region_2)) region_2,
	ltrim(rtrim(town_or_city)) town_or_city
  from per_addresses
  where person_id in (select person_id
                    from per_assignments_f
                    where assignment_id = p_assignment_id);

  cursor cur_federal is select
	sui_jurisdiction_code,
	to_char(effective_start_date,'MM/DD/YYYY') effective_start_date,
	decode(to_char(effective_end_date,'MM/DD/YYYY'),'12/31/4712',NULL,
	  to_char(effective_end_date,'MM/DD/YYYY')) effective_end_date
  from pay_us_emp_fed_tax_rules_f
  where assignment_id = p_assignment_id;

  cursor cur_state is select
	jurisdiction_code,
	to_char(effective_start_date,'MM/DD/YYYY') effective_start_date,
	decode(to_char(effective_end_date,'MM/DD/YYYY'),'12/31/4712',NULL,
		to_char(effective_end_date,'MM/DD/YYYY')) effective_end_date
  from pay_us_emp_state_tax_rules_f
  where assignment_id = p_assignment_id;

  cursor cur_county is select
	jurisdiction_code,
	to_char(effective_start_date,'MM/DD/YYYY') effective_start_date,
	decode(to_char(effective_end_date,'MM/DD/YYYY'),'12/31/4712',NULL,
	to_char(effective_end_date,'MM/DD/YYYY')) effective_end_date
  from pay_us_emp_county_tax_rules_f
  where assignment_id = p_assignment_id;

  cursor cur_city is select
	jurisdiction_code,
	to_char(effective_start_date,'MM/DD/YYYY') effective_start_date,
	decode(to_char(effective_end_date,'MM/DD/YYYY'),'12/31/4712',NULL,
	to_char(effective_end_date,'MM/DD/YYYY')) effective_end_date
  from pay_us_emp_city_tax_rules_f
  where assignment_id = p_assignment_id;

  cursor cur_vertex is
    select
	pev.element_entry_id eeid,
	pev.screen_entry_value sevl,
	to_char(pev.effective_start_date,'MM/DD/YYYY') effective_start_date,
	decode(to_char(pev.effective_end_date,'MM/DD/YYYY'),'12/31/4712',
                           NULL, to_char(pev.effective_end_date,'MM/DD/YYYY')) effective_end_date
      from pay_element_types_f        pet,
           pay_element_links_f        pel,
           pay_element_entries_f      pef,
           pay_element_entry_values_f pev
     where pet.element_name in ('VERTEX', 'Workers Compensation')
       and pet.element_type_id = pel.element_type_id
       and pel.element_link_id = pef.element_link_id
       and pef.element_entry_id = pev.element_entry_id
       and pev.screen_entry_value is not null
       and pef.effective_start_date = pev.effective_start_date
       and pef.effective_end_date = pev.effective_end_date
       and pef.assignment_id = p_assignment_id
     order by pev.element_entry_id,
              pev.effective_start_date;

  l_heading 	varchar2(240);
  l_header2	varchar2(240);
  l_body	varchar2(32000);


  l_full_name		per_people_f.full_name%TYPE;
  l_employee_number	per_people_f.employee_number%TYPE;
  l_assignment_number	per_assignments_f.assignment_number%TYPE;
begin

  --hr_utility.trace_on(1,'pg');

  l_heading := '<HTML><HEAD> <CENTER> <H1> <B> ' ||
		'Assignment Data Integrity Report: ' ||
	      '</B> </H1> </CENTER> </HEAD> ';

  fnd_file.put_line(fnd_file.output,l_heading);

  open  cur_header2;
  fetch cur_header2
  into  l_full_name,
	l_employee_number,
	l_assignment_number;
  close cur_header2;

  hr_utility.trace('l_full_name = ' || l_full_name);
  hr_utility.trace('l_employee_number = ' || l_employee_number);
  hr_utility.trace('l_assignment_number = ' || l_assignment_number);

  l_header2 := '<H2> For Employee: ' || l_employee_number || ' ' || l_full_name || ' Assignment number ' || l_assignment_number || '</H2>';

  fnd_file.put_line(fnd_file.output,l_header2);

  l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=10 ALIGN="LEFT"> <B> Assignment Details </B> </TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD WIDTH=5%>' || 'Assignment ID' || '</TD>'
                || '<TD WIDTH=5%>'|| 'Effective Start Date' || '</TD>'
                || '<TD WIDTH=5%>'|| 'Effective End Date' || '</TD>'
                || '<TD WIDTH=5%>' || 'Location ID' || '</TD>'
                || '<TD WIDTH=5%>'|| 'Location Name' || '</TD>'
                || '<TD WIDTH=5%>' || 'Payroll ID' || '</TD>'
                || '<TD WIDTH=5%>'|| 'Payroll Name' || '</TD>'
                || '<TD WIDTH=5%>' || 'Pay Basis ID' || '</TD>'
                || '<TD WIDTH=5%>'|| 'Name' || '</TD>'
                || '<TD WIDTH=5%>' || 'sfckid'|| '</TD>'
                || '</TR>';


  for i in cur_assignment loop

    l_body := l_body || '<TR ALIGN=LEFT>'
		|| '<TD >' || p_assignment_id || '</TD>'
		|| '<TD >' || i.effective_start_date || '</TD>'
		|| '<TD >' || i.effective_end_date || '</TD>'
		|| '<TD >' || i.location_id || '</TD>'
		|| '<TD >' || i.location_code || '</TD>'
		|| '<TD >' || i.payroll_id || '</TD>'
		|| '<TD >' || i.payroll_name || '</TD>'
		|| '<TD >' || i.pay_basis_id || '</TD>'
		|| '<TD >' || i.name || '</TD>'
		|| '<TD >' || i.sfckid || '</TD>'
		|| '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);

  l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=4 ALIGN="LEFT"> <B> Person Details </B></TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >'  || 'Person ID' || '</TD>'
                || '<TD >' || 'Employee Name' || '</TD>'
                || '<TD >' || 'Effective Start Date' || '</TD>'
                || '<TD >' || 'Effective End Date' || '</TD>'
                || '</TR>';


  for i in cur_person loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >' || i.person_id || '</TD>'
                || '<TD >' || i.full_name || '</TD>'
                || '<TD >' || i.effective_start_date || '</TD>'
                || '<TD >' || i.effective_end_date || '</TD>'
                || '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);

  l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=4 ALIGN="LEFT"> <B> Address Details </B> </TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >' || 'Primary Address' || '</TD>'
                || '<TD >' || 'County' || '</TD>'
                || '<TD >' || 'State' || '</TD>'
                || '<TD >' || 'City' || '</TD>'
                || '</TR>';


  for i in cur_address loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >'  || i.primary_flag || '</TD>'
                || '<TD >' || i.region_1 || '</TD>'
                || '<TD >' || i.region_2 || '</TD>'
                || '<TD >' || i.town_or_city || '</TD>'
                || '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);

  l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=3 ALIGN="LEFT"> <B> Federal Details </B> </TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >'  || 'Jurisdiction' || '</TD>'
                || '<TD >' || 'Effective Start Date' || '</TD>'
                || '<TD >' || 'Effective End Date' || '</TD>'
                || '</TR>';


  for i in cur_federal loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >'  || i.sui_jurisdiction_code || '</TD>'
                || '<TD >' || i.effective_start_date || '</TD>'
                || '<TD >' || i.effective_end_date || '</TD>'
                || '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);

  l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=3 ALIGN="LEFT"> <B> State Details </B> </TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >'  || 'Jurisdiction' || '</TD>'
                || '<TD >' || 'Effective Start Date' || '</TD>'
                || '<TD >' || 'Effective End Date' || '</TD>'
                || '</TR>';


  for i in cur_state loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >'  || i.jurisdiction_code || '</TD>'
                || '<TD >' || i.effective_start_date || '</TD>'
                || '<TD >' || i.effective_end_date || '</TD>'
                || '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);

  l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=3 ALIGN="LEFT"> <B> County Details </B></TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >'  || 'Jurisdiction' || '</TD>'
                || '<TD >' || 'Effective Start Date' || '</TD>'
                || '<TD >' || 'Effective End Date' || '</TD>'
                || '</TR>';


  for i in cur_county loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >' || i.jurisdiction_code || '</TD>'
                || '<TD >' || i.effective_start_date || '</TD>'
                || '<TD >' || i.effective_end_date || '</TD>'
                || '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);

  l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=3 ALIGN="LEFT"><B>City Details </B></TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >'  || 'Jurisdiction' || '</TD>'
                || '<TD >' || 'Effective Start Date' || '</TD>'
                || '<TD >' || 'Effective End Date' || '</TD>'
                || '</TR>';


  for i in cur_city loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >'  || i.jurisdiction_code || '</TD>'
                || '<TD >' || i.effective_start_date || '</TD>'
                || '<TD >' || i.effective_end_date || '</TD>'
                || '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);

  l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=4 ALIGN="LEFT"><B>VERTEX and Workers Compensation Element Entries.</B></TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD>' || 'Element Entry ID' || '</TD>'
                || '<TD>' || 'Screen Entry Value' || '</TD>'
                || '<TD>' || 'Effective Start Date' || '</TD>'
                || '<TD>' || 'Effective End Date' || '</TD>'
                || '</TR>';


  for i in cur_vertex loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD>' || i.eeid || '</TD>'
                || '<TD>' || i.sevl || '</TD>'
                || '<TD>' || i.effective_start_date || '</TD>'
                || '<TD>' || i.effective_end_date || '</TD>'
                || '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);


end; -- end of write_data

end pay_asg_debug_pkg; -- end of package

/
