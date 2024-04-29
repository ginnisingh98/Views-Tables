--------------------------------------------------------
--  DDL for Package PAY_IE_WNU_EDI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_WNU_EDI" AUTHID CURRENT_USER as
/* $Header: pyiewnue.pkh 120.1 2006/03/23 21:56:27 vikgupta noship $ */
--
 level_cnt NUMBER;
 --
 /* Procedure wnu_update_extra_info calls apis to insert/update records in
 PER_EXTRA_ASSIGNMENT_INFO */

Procedure wnu_update_extra_info
  (p_assignment_id               in    number,
   p_effective_date              in    date,
   p_include_in_wnu              in    varchar2 default null);
--

--
--
-- CURSORS
CURSOR CSR_WNU_HEADER_FOOTER IS
  SELECT
         ('TAX_YEAR=P')           , to_char(ppa.effective_date , 'RRRR'),
         ('EMPLOYER_NUMBER=P')    , nvl(trim(rpad(hoi.org_information1,30)),' '), --Bug 4069789 --Bug 4369280
       --('EMPLOYER_NAME=P')      , nvl(trim(rpad(hou.name,30)),' '),
       --Modified the source of Employer name for bug fix 3567562
         ('EMPLOYER_NAME=P')      , nvl(trim(rpad(hou.name,30)),' '),
         ('EFFECTIVE_DATE=P')     , to_char(ppa.effective_date, 'DDMMYY'),
         ('EMPLOYER_ADDRESS1=P')  , nvl(trim(rpad(hlo.address_line_1,30)),' '),
         ('EMPLOYER_ADDRESS2=P')  , nvl(trim(rpad(hlo.address_line_2,30)),' '),
         ('EMPLOYER_ADDRESS3=P')  , nvl(trim(rpad(hlo.address_line_3,30)),' '),
         ('CONTACT_NAME=P')       , nvl(trim(rpad(hoi.org_information4,20)),' '),
         ('CONTACT_NUMBER=P')     , nvl(trim(rpad(hlo.telephone_number_1,12)),' ')
  FROM   pay_payroll_actions                ppa
        ,hr_organization_units              hou
        ,hr_organization_information        hoi
        ,hr_locations_all                   hlo
  WHERE  ppa.payroll_action_id                =   pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
  AND    hou.business_group_id= ppa.business_group_id
  AND    hoi.organization_id=pay_ie_archive_detail_pkg.get_parameter(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'),'EMP_REF')
  AND    hou.organization_id =hoi.organization_id
  AND    hou.location_id = hlo.location_id(+)
  AND    hoi.org_information_context = 'IE_EMPLOYER_INFO';       --Bug 4369280
--  AND    hoi.organization_id =hou.organization_id
  --For bug Fix 3567562 added join to filter record based on Tax District and PAYE Reference specified as parameters.
  --AND    hoi.org_information1=pay_ie_archive_detail_pkg.get_parameter(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'),'TAX_REF')
  --AND    hoi.org_information2=pay_ie_archive_detail_pkg.get_parameter(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'),'PAYE_REF');
--
 CURSOR CSR_WNU_DETAIL IS
select
        upper('RSI_NUMBER=P'),
        nvl(SUBSTR(upper(people.national_identifier),1,9),' '),
        upper('WORKS_NUMBER=P'),
        upper(substr(assign.assignment_number,1,12)),
         upper('SURNAME=P'),
         upper(substr(people.last_name,1,20)),
         upper('FIRST_NAME=P'),
         nvl(upper(substr(people.first_name,1,20)),' '),
         upper('DATE_OF_BIRTH=P'),
         nvl(to_char(people.DATE_OF_BIRTH, 'DDMMYY'),' '),
         upper('ADDRESS_LINE1=P'),
         nvl(SUBSTR(trim(pad.ADDRESS_LINE1),1,30), ' '),
         upper('ADDRESS_LINE2=P'),
         nvl(SUBSTR(trim(pad.ADDRESS_LINE2),1,30), ' '),
         upper('ADDRESS_LINE3=P'),
         nvl(SUBSTR(trim(pad.ADDRESS_LINE3),1,30), ' '),
	 upper('PAYROLL_NAME=P'),
	 nvl(ppayf.payroll_name ,' ')
from
        pay_assignment_actions   act,
        pay_payroll_actions      ppa,
        per_all_assignments_f          assign,
        per_all_people_f             people,
        per_addresses            pad,
	pay_all_payrolls_f	 ppayf
where   act.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and	ppa.payroll_action_id = act.payroll_action_id
and     act.assignment_id = assign.assignment_id
and	ppayf.payroll_id = assign.payroll_id
and     assign.person_id = people.person_id
and     pad.person_id(+) = people.person_id
and     NVL(pad.PRIMARY_FLAG,'Y') = 'Y'
-- For bug 5114019, added a join with per_addresses date as a person can have
-- datetrack primary addresses.
and    ppa.effective_date between
                    nvl(pad.date_from,ppa.effective_date) and nvl(pad.date_to,to_date('31/12/4712','dd/mm/yyyy'))
-- End bug 5114019
and     ppa.effective_date    between
                     assign.effective_start_date and assign.effective_end_date
and    ppa.effective_date between
                    people.effective_start_date and people.effective_end_date
and     ppa.effective_date between
                    ppayf.effective_start_date and ppayf.effective_end_date
order by ppayf.payroll_name, people.last_name ;
--
--
-- PROCEDURE range_cursor
-- Procedure which stamps the payroll action with the PAYROLL_ID (if
-- supplied), then returns a varchar2 defining a SQL Stateent to select
-- all the people in the business group.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
-- This procedure is used for both the P45 Archive process and the P45 EDI
-- process.
--
-- to return parameter values from legislative parameters in pay_payroll_actions
--
 PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT NOCOPY VARCHAR2);
--
/* PROCEDURE wnu_full_action_creation:
This PROC creates assignment actions when running the process in FULL Mode  */

PROCEDURE wnu_full_action_creation(pactid IN NUMBER,
                                  stperson IN NUMBER,
                                  endperson IN NUMBER,
                                  chunk IN NUMBER);
--
/* PROCEDURE wnu_update_action_creation:
This PROC creates assignment actions when running the process in UPDATE Mode  */
--
PROCEDURE wnu_update_action_creation(pactid IN NUMBER,
                              stperson IN NUMBER,
                              endperson IN NUMBER,
                              chunk IN NUMBER);
--
end  PAY_IE_WNU_EDI;

 

/
