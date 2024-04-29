--------------------------------------------------------
--  DDL for Package PER_ES_SS_REP_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ES_SS_REP_ARCHIVE_PKG" AUTHID CURRENT_USER AS
/* $Header: peesssar.pkh 115.6 2004/04/15 03:06:14 viviswan noship $ */

level_cnt NUMBER;
TYPE effective_report_date_list IS TABLE OF per_assignment_extra_info.aei_information2%TYPE;
TYPE event_list IS TABLE OF per_assignment_extra_info.aei_information3%TYPE;
TYPE value_list IS TABLE OF per_assignment_extra_info.aei_information4%TYPE;
TYPE action_type_list IS TABLE OF per_assignment_extra_info.aei_information6%TYPE;
TYPE first_changed_date_list IS TABLE OF per_assignment_extra_info.aei_information7%TYPE;
TYPE csr_event_values IS REF CURSOR;
--------------------------------------------------------------------------------
CURSOR CSR_SS_REP_HEADER_FOOTER IS
  SELECT ('AUTHORIZATION_KEY=P'),  LPAD(NVL(pact.action_information1,'0'), 8, '0'),
         ('SILCON_KEY=P'), RPAD(NVL(pact.action_information2,' '), 8,' '),
         ('SS_DATE=P'), to_char(fnd_date.canonical_to_date(pact.action_information3), 'YYYYMMDD'),
         ('SS_TIME=P'),  LPAD(NVL(pact.action_information4,'0'), 4, '0'),
         ('FILE_NAME=P'), to_char(fnd_date.canonical_to_date(pact.action_information5), 'YYYYMMDD'),
         ('FILE_EXTENSION=P'), RPAD(pact.action_information6, 3),
         ('TEST_FLAG=P'), pact.action_information8,
         ('CURRENT_PASSWORD=P'), RPAD(NVL(pact.action_information9,' '), 8),
         ('NEW_PASSWORD=P'),   RPAD(NVL(pact.action_information10,' '), 8)
  FROM   pay_payroll_actions                ppa
        ,pay_action_information             pact
  WHERE  ppa.payroll_action_id  = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
  AND    pact.action_context_id = ppa.payroll_action_id
  AND    pact.action_information_category  = 'ES_SS_REPORT_ETI'
  AND    pact.action_context_type          = 'PA'
  AND    ROWNUM < 2;
--------------------------------------------------------------------------------
CURSOR CSR_SS_REP_COMPANY IS
  SELECT ('SS_SCHEME=P'), LPAD(NVL(pact.action_information1,'0'), 4, '0'),
         ('PROVINCE=P'), LPAD(NVL(pact.action_information2,'0'), 2, '0'),
         ('SS_NUMBER=P'), LPAD(NVL(pact.action_information3,'0'), 9, '0'),
         ('ID_TYPE=P'), NVL(pact.action_information4,' '),
         ('COUNTRY=P'), RPAD(NVL(pact.action_information5,' '), 3),
	       ('EMPLOYER_ID=P'), RPAD(NVL(pact.action_information6,' '), 14),
         ('SS_OPEN=P'), RPAD(' ', 2, ' '),
         ('SS_SCHEME1=P'), LPAD(NVL(pact.action_information7,'0'), 4, '0'),
         ('PROVINCE1=P'), LPAD(NVL(pact.action_information8,'0'), 2, '0'),
         ('SS_NUMBER1=P'), LPAD(NVL(pact.action_information9,'0'), 9, '0'),
	       ('ACTION_EVENT=P'),    NVL(pact.action_information10,' '),
         ('COMP_REG_FLAG=P'), NVL(pact.action_information12,' '),
         ('EMPLOYER_TYPE=P'), NVL(pact.action_information11,' '),
	       ('REGISTERED_NAME=P'), RPAD(NVL(pact.action_information13,' '), 55),
         ('START_DATE=P'), LPAD(NVL(pact.action_information14,'0'),8,'0'),
         ('END_DATE=P'), LPAD(NVL(pact.action_information15,'0'),8,'0'),
         ('ORG_ID=P'),pact.action_information16
  FROM   pay_payroll_actions                ppa
        ,pay_action_information             pact
  WHERE  ppa.payroll_action_id  = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
  AND    pact.action_context_id = ppa.payroll_action_id
  AND    pact.action_information_category  = 'ES_SS_REPORT_EMP'
  AND    pact.action_context_type          = 'PA'
  AND    EXISTS ( SELECT 1
                  FROM   pay_payroll_actions      ppa1
                        ,pay_action_information   pact_tra
                        ,pay_assignment_actions   paa1
                  WHERE  ppa1.payroll_action_id                = ppa.payroll_action_id
                  AND    pact_tra.action_information_category  = 'ES_SS_REPORT_TRA'
                  AND    pact_tra.action_context_type          = 'AAP'
                  AND    ppa1.payroll_action_id                = paa1.payroll_action_id
                  AND    pact_tra.action_context_id            = paa1.assignment_action_id
                  AND    pact_tra.action_information11         = pact.action_information16);

--------------------------------------------------------------------------------
CURSOR CSR_SS_REP_EMPLOYEE IS
  SELECT ('PROVINCE=P'), LPAD(NVL(pact_tra.action_information1,'0'),2,'0'),
         ('SS_NUMBER_EMP=P'),LPAD(NVL(pact_tra.action_information2,'0'),10,'0'),
         ('ID_TYPE_EMP=P'), NVL(pact_tra.action_information3,' '),
         ('COUNTRY_EMP=P'), NVL(pact_tra.action_information4,' '),
	       ('EMPLOYER_ID_EMP=P'), RPAD(NVL(pact_tra.action_information5,' '),14,' '),
	       ('NATIONALITY=P'),  NVL(pact_tra.action_information6,' '),
         ('EMPLOYEE_FLAG=P'), ' ',
	       ('FIRST_LAST_NAME=P'), RPAD(pact_tra.action_information7, 20,' '),
	       ('SECOND_LAST_NAME=P'), RPAD(NVL(pact_tra.action_information8,' '), 20,' '),
	       ('SS_NAME=P'), RPAD(NVL(pact_tra.action_information9,' '), 15,' '),
	       ('ACTION=P'), pact_fab.action_information1,
	       ('STATUS_OF_REASON=P'), LPAD(NVL(pact_fab.action_information2,'0'), 2, '0'),
         ('ACTUAL_DATE=P'), to_char(fnd_date.canonical_to_date(pact_fab.action_information3), 'YYYYMMDD'),
         ('ASSIGNMENT_STATUS=P'), LPAD(NVL(pact_fab.action_information4,'0'), 2, '0'),
         ('EMPLOYMENT_CATEGORY=P'), LPAD(NVL(pact_fab.action_information5,'0'), 3, '0'),
         ('EPIGRAPH_CODE=P'), LPAD(NVL(pact_fab.action_information6,'0'), 3, '0'),
         ('UNEMPLOYED_FLAG=P'), NVL(pact_fab.action_information7,'0'),
         ('UNDER_REPRESENTED_FLAG=P'), DECODE(NVL(pact_fab.action_information8,' '),'Y','S','N','N',' '),
	       ('PART_TIME_PERCENT=P'), LPAD(NVL(pact_fab.action_information19,'0'), 3, '0'),
	       ('EMP_COLLECTIVE_AGREEMENT=P'), LPAD(NVL(pact_fab.action_information20,'0'), 3, '0'),
	       ('PRINT_FLAG=P'), ' ',
	       ('PROFESSIONAL_CATEGORY=P'), LPAD(NVL(pact_fab.action_information21,'0'), 7, '0'),
         ('BIRTH_DATE=P'), NVL(to_char(fnd_date.canonical_to_date(pact_fab.action_information9), 'YYYYMMDD'),'0'),
         ('SEX=P'), DECODE(NVL(pact_fab.action_information10,'0'),'M','1','F','2','0') ,
         ('RE_HIRED_DISABLED_FLAG=P'), DECODE(NVL(pact_fab.action_information11,' '),'Y','S','N','N',' '),
         ('INDEPENDENT_CONTRACTOR=P'), DECODE(NVL(pact_fab.action_information12,' '),'Y','S','N','N',' '),
	       ('DISABILITY_DEGREE=P'), RPAD(NVL(pact_fab.action_information13,' '), 2),
         ('CONTROL_DATE=P'), LPAD(NVL(pact_fab.action_information14,'0'),8,'0'),
         ('MINORITY_GROUP_EMP_FLAG=P'), DECODE(NVL(pact_fab.action_information15,' '),'Y','S','N','N',' '),
         ('EMP_ACTIVE_RENT_FLAG=P'), DECODE(NVL(pact_fab.action_information16,' '),'Y','S','N','N',' '),
         ('EMP_MATERNITY_LEAVE=P'), DECODE(NVL(pact_fab.action_information17,' '),'Y','S','N','N',' '),
         ('CONTRIBUTION_GROUP=P'), LPAD(NVL(pact_fab.action_information18,'0'),2,'0'),
         ('ASS_NUMBER=P'), pact_tra.action_information10,
         ('CONT_START_DATE=P'),LPAD(NVL(to_char(fnd_date.canonical_to_date(pact_tra.action_information12), 'YYYYMMDD'),'0'),8,'0'),
         ('CONT_START_FLAG=P'),DECODE(NVL(pact_tra.action_information13,'N'),'N','N','Y'),
         ('LABOR_RELATIONSHIP_TYPE=P'), LPAD(NVL(pact_tra.action_information14,'0'),4,'0'),
         ('REPLACED_EMP_SS_NO=P'),LPAD(NVL(pact_tra.action_information15,'0'),12,'0'),
         ('REPLACEMENT_REASON=P'),LPAD(NVL(pact_tra.action_information16,'0'),2,'0'),
         ('PERCENT_INTEGER=P'), NVL(pact_tra.action_information17,'0'),
         ('PERCENT_DECIMAL=P'),LPAD(NVL(pact_tra.action_information18,'0'),2,'0'),
         ('WORKING_DAYS=P'),LPAD(NVL(pact_tra.action_information19,'0'),3,'0'),
         ('DAYS_PERCENT_APPLIES=P'),LPAD(NVL(pact_tra.action_information20,'0'),3,'0'),
         ('RETIREMENT_REDUCTION_PERCENT=P'),LPAD(NVL(pact_tra.action_information21,'0'),2,'0'),
         ('TEST_FLAG=P'),pact_tra.action_information22 -- not used
  FROM   pay_payroll_actions                ppa
        ,pay_assignment_actions             paa
        ,pay_action_information             pact_tra
	      ,pay_action_information             pact_fab
  WHERE  ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
  AND    paa.payroll_action_id = ppa.payroll_action_id
  AND    pact_tra.action_context_id = paa.assignment_action_id
  AND    pact_fab.action_context_id = paa.assignment_action_id
  AND    pact_tra.action_context_id = pact_fab.action_context_id
  AND    pact_tra.action_information_category  = 'ES_SS_REPORT_TRA'
  AND    pact_fab.action_information_category  = 'ES_SS_REPORT_FAB'
  AND    pact_tra.action_context_type          = 'AAP'
  AND    pact_fab.action_context_type          = 'AAP'
  AND    pact_tra.action_information11         = pay_magtape_generic.get_parameter_value('ORG_ID')
  ORDER BY pact_fab.action_information1;
--------------------------------------------------------------------------------
FUNCTION get_parameter (
         p_parameter_string      IN VARCHAR2
        ,p_token                 IN VARCHAR2)  RETURN VARCHAR2;
--------------------------------------------------------------------------------
PROCEDURE get_all_parameters (
         p_payroll_action_id    IN  NUMBER
        ,p_effective_end_Date   OUT NOCOPY DATE
	      ,p_test_flag            OUT NOCOPY VARCHAR2
	      ,p_effective_date       OUT NOCOPY DATE
	      ,p_business_group_id    OUT NOCOPY NUMBER
        ,p_organization_id      OUT NOCOPY NUMBER
        ,p_assignment_set_id    OUT NOCOPY NUMBER);
--------------------------------------------------------------------------------
PROCEDURE range_cursor_archive(
         pactid                 IN  NUMBER
        ,sqlstr                 OUT NOCOPY VARCHAR);
--------------------------------------------------------------------------------
PROCEDURE action_creation_archive(
         pactid                 IN NUMBER
        ,stperson               IN NUMBER
        ,endperson              IN NUMBER
        ,chunk                  IN NUMBER);
--------------------------------------------------------------------------------
PROCEDURE get_ss_details (
         p_assignment_id        NUMBER
        ,p_reporting_date       DATE
        ,p_under_repres_women   OUT NOCOPY VARCHAR2
        ,p_rehired_disabled     OUT NOCOPY VARCHAR2
        ,p_unemployment_status  OUT NOCOPY VARCHAR2
        ,p_first_contractor     OUT NOCOPY VARCHAR2
        ,p_after_two_years      OUT NOCOPY VARCHAR2
        ,p_active_rent_flag     OUT NOCOPY VARCHAR2
        ,p_minority_group_flag  OUT NOCOPY VARCHAR2);
--------------------------------------------------------------------------------
PROCEDURE get_disability_degree (
         p_assignment_id        IN NUMBER
        ,p_reporting_date       IN DATE
        ,p_degree               OUT NOCOPY NUMBER);
--------------------------------------------------------------------------------
PROCEDURE archive_code(
         p_assignment_id        IN NUMBER
		    ,pactid                 IN NUMBER
		    ,p_assignment_action_id IN NUMBER
		    ,p_effective_end_date   IN DATE);
--------------------------------------------------------------------------------
PROCEDURE get_other_values(
         p_value                IN OUT NOCOPY VARCHAR2
        ,p_event                IN VARCHAR2
        ,p_assignment_id        IN NUMBER
	      ,pactid                 IN NUMBER
		    ,p_assignment_action_id IN NUMBER
		    ,p_effective_end_date   IN DATE
		    ,sql_str                IN VARCHAR2);
--------------------------------------------------------------------------------
PROCEDURE get_all_parameters_lock(
            p_payroll_action_id      IN NUMBER
           ,p_arch_payroll_action_id OUT NOCOPY NUMBER
	       ,p_effective_end_date     OUT NOCOPY DATE);
--------------------------------------------------------------------------------
PROCEDURE range_cursor_lock(
                            pactid                  IN NUMBER
                           ,sqlstr                  OUT NOCOPY VARCHAR);
--------------------------------------------------------------------------------
PROCEDURE action_creation_lock(
        pactid                  IN NUMBER
       ,stperson                IN NUMBER
       ,endperson               IN NUMBER
       ,chunk                   IN NUMBER);
-------------------------------------------------------------------------------
END PER_ES_SS_REP_ARCHIVE_PKG;

 

/
