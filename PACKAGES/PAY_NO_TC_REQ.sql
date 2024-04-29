--------------------------------------------------------
--  DDL for Package PAY_NO_TC_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_TC_REQ" AUTHID CURRENT_USER as
/* $Header: pynotcrq.pkh 120.0 2005/05/29 07:02:31 appldev noship $ */
--
 level_cnt NUMBER;
 --

FUNCTION get_parameter(p_payroll_action_id   NUMBER,
                       p_token_name          VARCHAR2) RETURN VARCHAR2;

--
-- PROCEDURE range_cursor
-- Procedure which stamps the payroll action with the PAYROLL_ID (if
-- supplied), then returns a varchar2 defining a SQL Stateent to select
-- all the people in the business group.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
--
-- to return parameter values from legislative parameters in pay_payroll_actions
--

PROCEDURE range_cursor(
                p_payroll_action_id     IN  NUMBER,
                p_sqlstr                OUT NOCOPY VARCHAR2);


PROCEDURE assignment_action_code(
                p_payroll_action_id     IN NUMBER,
                p_start_person_id       IN NUMBER,
                p_end_person_id         IN NUMBER,
                p_chunk_number          IN NUMBER);





CURSOR CSR_NO_TC_REQ IS

select
       'NATIONAL_IDENTIFIER=P'
      ,pef.NATIONAL_IDENTIFIER
      ,'ORG_NUMBER=P'
      ,hoi1.org_information1

     from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	, hr_soft_coding_keyflex hsk
	, per_all_assignments_f paf
	, per_all_people_f pef
        , per_periods_of_service serv
	, pay_payroll_actions paa

     WHERE
       paa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
       and hoi1.organization_id = o1.organization_id
       and hoi1.ORG_INFORMATION_CONTEXT='NO_LEGAL_EMPLOYER_DETAILS'
       and hoi1.organization_id =  hoi2.organization_id
       and hoi2.ORG_INFORMATION_CONTEXT='CLASS'
       and hoi2.org_information1 = 'HR_LEGAL_EMPLOYER'
       and hoi3.organization_id = hoi2.organization_id
       and hoi3.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNITS'
       and hoi3.org_information1=hsk.segment2
       and hsk.SOFT_CODING_KEYFLEX_ID = paf.SOFT_CODING_KEYFLEX_ID
       and paf.PRIMARY_FLAG = 'Y'
       and paf.person_id=pef.person_id
       and pef.business_group_id = paa.business_group_id
       and     serv.person_id = pef.person_id
       and     serv.period_of_service_id = paf.period_of_service_id
       and     serv.date_start = (select max(s.date_start)
                           from   per_periods_of_service s
                                 where  s.person_id = pef.person_id
                                 and    paa.effective_date >= s.date_start)
       and    pef.current_employee_flag = 'Y'
       and    paa.effective_date between paf.effective_start_date and paf.effective_end_date
       and    paa.effective_date between pef.effective_start_date and pef.effective_end_date
       order by hoi1.org_information1;



end  PAY_NO_TC_REQ;

 

/
