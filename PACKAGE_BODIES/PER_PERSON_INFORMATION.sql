--------------------------------------------------------
--  DDL for Package Body PER_PERSON_INFORMATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERSON_INFORMATION" AS
/* $Header: peperinf.pkb 115.3 2003/05/01 10:57:39 pkakar noship $ */
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

    Name        : per_person_information

    Description : Package for the Person Reports. The package
                  generated the output file in the specified user
                  format. The current formats supported are
                      - HTML

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
    08-APR-03   pkakar     115.0             Version Created
    10-Apr-03   pkakar     115.1             updated the cursor csr_assignment,
					     changing the 'order by' claus
					     Also, changed the reference of
				             tables so that they use secure
					     views
    17-Apr-03   pkakar    115.2              removed csr_payroll and its usage, and
					     updated csr_assignment to include
					     payroll id and payroll name. Also made
					     some other minor changes in the titles.
   1-May-03    pkakar     115.3              updated csr_persondetails, so that
					     reference to per_person_usages_f
					     has been removed.
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
	     ,p_person_id 		  in  number) is

cursor csr_instance is
select instance_name
      ,host_name
      ,version
from v$instance;

cursor csr_language is
select upper(value) value
from v$parameter
where name = 'nls_language';

cursor csr_release is
select release_name
from fnd_product_groups;

cursor csr_application is
SELECT v.application_name||'('||v.application_short_name||')' application
      ,v.application_id id
      ,l.meaning installstatus
      ,nvl(substr(i.patch_level,1,12),' ') patchlevel
FROM fnd_application_all_view v
    ,fnd_product_installations i
    ,fnd_lookups l
WHERE v.application_id = i.application_id
AND v.application_id in (0, 800, 801, 802, 803, 805, 808, 809, 810, 8301, 8302, 178)
AND l.lookup_type = 'FND_PRODUCT_STATUS'
AND l.lookup_code = i.Status order by 1;

cursor csr_assignment is
SELECT paf.assignment_number asgno
      ,paf.assignment_id asgid
      ,paf.primary_flag prifl
      ,to_char(paf.effective_start_date,'MM/DD/YYYY') esd
      ,NVL(to_char(paf.effective_end_date,'MM/DD/YYYY'),'12/31/4712') eed
      ,SUBSTR(paf.PERIOD_OF_SERVICE_ID,1,9) posid
      ,paf.location_id loc_id
      ,past.per_system_status pss
       ,DECODE(paf.assignment_type
       ,'A','Applicant'
       ,'B','Benefits'
       ,'E','Employee') AsGType
       ,paf.payroll_id p_id
       ,papf.payroll_name Pay_Name
FROM per_assignments_f paf
    ,per_assignment_status_types past
    ,pay_payrolls_f papf
WHERE paf.person_id = p_person_id
AND past.assignment_status_type_id = paf.assignment_status_type_id
AND paf.payroll_id = papf.payroll_id (+)
AND paf.effective_start_date between papf.effective_start_date(+) and nvl(papf.effective_end_date,paf.effective_start_date)
ORDER BY paf.assignment_id ,paf.effective_start_date,paf.effective_end_date;

cursor csr_pp_service is
SELECT SUBSTR(period_of_service_id,1,11) pos_id
      ,to_char(date_start,'MM/DD/YYYY') d_s
      ,NVL(to_char(last_standard_process_date,'MM/DD/YYYY'),'12/31/4712') last
      ,NVL(to_char(actual_termination_date,'MM/DD/YYYY'), '12/31/4712') actual
      ,NVL(to_char(final_process_date,'MM/DD/YYYY'), '12/31/4712') final
      ,leaving_reason l_r
FROM per_periods_of_service
WHERE person_id = p_person_id
ORDER BY date_start;

cursor csr_persondetails is
SELECT  SUBSTR(ppf.person_id,1,10) per_id
       ,SUBSTR(ppf.full_name,1,25) f_n
       ,to_char(ppf.effective_start_date,'MM/DD/YYYY') e_s_d
       ,NVL(to_char(ppf.effective_end_date,'MM/DD/YYYY'),'12/31/4712') e_e_d
       ,substr(ppt.user_person_type,1,15) u_p_t
       ,substr(ppt.system_person_type,1,7) p_t_id
       ,ppf.party_id p_id
from     per_people_f ppf
        ,per_person_types ppt
where    ppf.person_id = p_person_id
and      ppf.person_type_id = ppt.person_type_id
order by ppf.effective_start_date
        ,ppf.effective_end_date;

cursor csr_address is
SELECT address_id add_id
      ,SUBSTR(primary_flag,1,8) p_f
      ,SUBSTR(town_or_city, 1,15) city
      ,SUBSTR(region_1,1,15) r_1
      ,SUBSTR(region_2, 1,6) r_2
      ,SUBSTR(postal_code,1,6) zip
      ,to_char(date_from,'MM/DD/YYYY') d_f
      ,NVL(to_char(date_to,'MM/DD/YYYY'), '12/31/4712') d_t
      ,party_id p_id
      ,nvl(address_type,null) a_d
FROM per_addresses
WHERE
person_id = p_person_id
ORDER BY date_from;

cursor csr_ptu is
SELECT SUBSTR(ptu.person_type_usage_id,1,10) ptu_id
      ,to_char(ptu.effective_start_date,'MM/DD/YYYY') e_s_d
      ,NVL(to_char(ptu.effective_end_date,'MM/DD/YYYY'),'12/31/4712') e_e_d
      ,SUBSTR(ppt.user_person_type,1,20) u_p_t
      ,SUBSTR(ppt.system_person_type,1,7) p_t_id
      ,ptu.person_type_id p_id
FROM per_person_type_usages_f ptu
    ,per_person_types ppt
WHERE ptu.person_id = p_person_id
AND ptu.person_type_id = ppt.person_type_id
ORDER BY ptu_id, e_s_d;


l_heading  varchar2(240);
l_header2  varchar2(240);
l_body  varchar2(20000);

begin

l_heading := '<HTML><HEAD> <CENTER> <H1> <B> ' ||
		'Person Data Integrity Report ' ||
	      '</B> </H1> </CENTER> </HEAD> ';

  fnd_file.put_line(fnd_file.output,l_heading);
	for i in csr_persondetails loop
  l_header2 := '<H2> Person: ' || p_person_id || ' , ' || i.f_n;
	end loop;

  fnd_file.put_line(fnd_file.output,l_header2);

  print_blank_lines(10);

-- system information
  l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=4 ALIGN="LEFT"> <B> System Information </B></TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD ><B>' || 'Machine' || '</TD></B>'
                || '<TD ><B>' || 'Date Run' || '</TD></B>'
                || '<TD ><B>' || 'DB Info' || '</TD></B>'
                || '<TD ><B>' || 'Version' || '</TD></B>'
                || '<TD ><B>' || 'DB Language' || '</TD></B>'
                || '<TD ><B>' || 'Apps Version' || '</TD></B>'
                || '</TR>';

  for i in csr_instance loop
        for a in csr_language loop
           for b in csr_release loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >' || i.host_name || '</TD></B>'
             || '<TD >' || to_char(sysdate, 'DD-MON-YYYY HH24:Mi:SS') || '</TD>'
                || '<TD >' || i.instance_name || '</TD>'
                || '<TD >' || i.version || '</TD>'
                || '<TD >' || a.value || '</TD>'
                || '<TD >' || b.release_name || '</TD>'
                || '</TR>';
            end loop;
       end loop;
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);

-- application information

 l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=4 ALIGN="LEFT"> <B> HRMS Products Install Status </B></TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD ><B>' || 'Application' || '</TD></B>'
                || '<TD ><B>' || 'ID' || '</TD></B>'
                || '<TD ><B>' || 'Install Status' || '</TD></B>'
                || '<TD ><B>' || 'Patch Level' || '</TD></B>'
                || '</TR>';

  for i in csr_application loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >' || i.application || '</TD>'
                || '<TD >' || i.id || '</TD>'
                || '<TD >' || i.installstatus || '</TD>'
                || '<TD >' || i.patchlevel || '</TD>'
                || '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);

-- assignment information
   l_body := '<TABLE BORDER=1>';


  l_body := l_body || '<TR> <TD COLSPAN=4 ALIGN="LEFT"> <B> Assignment Details - per_assignments_f </B></TD><TR>';


  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD ><B>'  || 'Asg No' || '</TD></B>'
                || '<TD ><B>' || 'Asg Id' || '</TD></B>'
                || '<TD ><B>' || 'Primary' || '</TD></B>'
                || '<TD ><B>' || 'Effective Start Date' || '</TD></B>'
                || '<TD ><B>' || 'Effective End Date' || '</TD></B>'
                || '<TD ><B>' || 'POS Id' || '</TD></B>'
                || '<TD ><B>' || 'Loc Id' || '</TD></B>'
                || '<TD ><B>' || 'Asg Status' || '</TD></B>'
                || '<TD ><B>' || 'Assignment Type' || '</TD></B>'
                || '<TD ><B>' || 'Payroll Id' || '</TD></B>'
                || '<TD ><B>' || 'Payroll Name' || '</TD></B>'
                || '</TR>';


  for i in csr_assignment loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >' || i.asgno || '</TD>'
                || '<TD >' || i.asgid || '</TD>'
                || '<TD >' || i.prifl || '</TD>'
                || '<TD >' || i.esd || '</TD>'
                || '<TD >' || i.eed || '</TD>'
                || '<TD >' || i.posid || '</TD>'
                || '<TD >' || i.loc_id || '</TD>'
                || '<TD >' || i.pss || '</TD>'
                || '<TD >' || i.asgtype || '</TD>'
                || '<TD >' || i.p_id || '</TD>'
                || '<TD >' || i.pay_name || '</TD>'
                || '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);

-- Period of service information


 l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=4 ALIGN="LEFT"> <B> Period of Service Details - per_periods_of_service </B></TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD ><B>'  || 'POS Id' || '</TD></B>'
                || '<TD ><B>' || 'Start Date' || '</TD></B>'
                || '<TD ><B>' || 'Last Standard Process Date' || '</TD></B>'
                || '<TD ><B>' || 'Actual Termination Date' || '</TD></B>'
                || '<TD ><B>' || 'Final Process Date' || '</TD></B>'
                || '<TD ><B>' || 'Leaving Reason' || '</TD></B>'
                || '</TR>';


  for i in csr_pp_service loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >' || i.pos_id || '</TD>'
                || '<TD >' || i.d_s || '</TD>'
                || '<TD >' || i.last || '</TD>'
                || '<TD >' || i.actual || '</TD>'
                || '<TD >' || i.final || '</TD>'
                || '<TD >' || i.l_r || '</TD>'
                || '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);

-- payroll details
/*
l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=4 ALIGN="LEFT"> <B> Payroll Details - pay_payrolls_f </B></TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >'  || 'Asg Id' || '</TD>'
                || '<TD >' || 'Effective Start Date' || '</TD>'
                || '<TD >' || 'Effective End Date' || '</TD>'
                || '<TD >' || 'Payroll Name' || '</TD>'
                || '<TD >' || 'Pay Basis Name' || '</TD>'
                || '<TD >' || 'Softcoding KeyFlex Field' || '</TD>'
                || '</TR>';


  for i in csr_payroll loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >' || i.asg_id || '</TD>'
                || '<TD >' || i.e_s_d || '</TD>'
                || '<TD >' || i.e_e_d || '</TD>'
                || '<TD >' || i.pay_name || '</TD>'
                || '<TD >' || i.basis_name || '</TD>'
                || '<TD >' || i.s_c_k_ff || '</TD>'
                || '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);

*/
-- person information

l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=4 ALIGN="LEFT"> <B> Person Details - per_people_f </B></TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT> '
                || '<TD ><B>' || 'Full Name' || '</TD></B>'
                || '<TD ><B>' || 'Effective Start Date' || '</TD></B>'
                || '<TD ><B>' || 'Effective End Date' || '</TD></B>'
                || '<TD ><B>' || 'User Per Type' || '</TD></B>'
                || '<TD ><B>' || 'Type Id' || '</TD></B>'
                || '<TD ><B>' || 'Party' || '</TD></B>'
                || '</TR>';


  for i in csr_persondetails loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >' || i.f_n|| '</TD>'
                || '<TD >' || i.e_s_d || '</TD>'
                || '<TD >' || i.e_e_d || '</TD>'
                || '<TD >' || i.u_p_t || '</TD>'
                || '<TD >' || i.p_t_id|| '</TD>'
                || '<TD >' || i.p_id || '</TD>'
                || '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);


-- person type information

l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=4 ALIGN="LEFT"> <B> Person Type Details - per_person_type_usages_f </B></TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD ><B>'  || 'PTU Id' || '</TD><B>'
                || '<TD ><B>' || 'Effective Start Date' || '</TD><B>'
                || '<TD ><B>' || 'Effective End Date' || '</TD><B>'
                || '<TD ><B>' || 'User Person Type' || '</TD><B>'
                || '<TD ><B>' || 'System Person Type' || '</TD><B>'
                || '<TD ><B>' || 'PType Id' || '</TD><B>'
                || '</TR>';


  for i in csr_ptu loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >' || i.ptu_id || '</TD>'
                || '<TD >' || i.e_s_d || '</TD>'
                || '<TD >' || i.e_e_d || '</TD>'
                || '<TD >' || i.u_p_t || '</TD>'
                || '<TD >' || i.p_t_id|| '</TD>'
                || '<TD >' || i.p_id|| '</TD>'
                || '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);


-- Address Details

l_body := '<TABLE BORDER=1>';

  l_body := l_body || '<TR> <TD COLSPAN=4 ALIGN="LEFT"> <B> Address Details - per_addresses </B></TD><TR>';

  l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD ><B>'  || 'Address Id' || '</TD></B>'
                || '<TD ><B>'  || 'Primary' || '</TD></B>'
                || '<TD ><B>' || 'City or Town' || '</TD></B>'
                || '<TD ><B>' || 'County' || '</TD></B>'
                || '<TD ><B>' || 'State' || '</TD></B>'
                || '<TD ><B>' || 'Code' || '</TD></B>'
                || '<TD ><B>' || 'Date From' || '</TD></B>'
                || '<TD ><B>' || 'Date To' || '</TD></B>'
                || '<TD ><B>' || 'Party' || '</TD></B>'
                || '<TD ><B>' || 'Address Type' || '</TD></B>'
                || '</TR>';


  for i in csr_address loop

    l_body := l_body || '<TR ALIGN=LEFT>'
                || '<TD >' || i.add_id || '</TD>'
                || '<TD >' || i.p_f || '</TD>'
                || '<TD >' || i.city || '</TD>'
                || '<TD >' || i.r_1 || '</TD>'
                || '<TD >' || i.r_2 || '</TD>'
                || '<TD >' || i.zip || '</TD>'
                || '<TD >' || i.d_f|| '</TD>'
                || '<TD >' || i.d_t|| '</TD>'
                || '<TD >' || i.p_id|| '</TD>'
                || '<TD >' || i.a_d || '</TD>'
                || '</TR>';
  end loop;

  l_body := l_body || '</TABLE>';

  fnd_file.put_line(fnd_file.output,l_body);

  print_blank_lines(10);

end; -- write_data

end per_person_information;

/
