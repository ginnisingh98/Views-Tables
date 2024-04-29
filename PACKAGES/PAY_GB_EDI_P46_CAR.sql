--------------------------------------------------------
--  DDL for Package PAY_GB_EDI_P46_CAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_EDI_P46_CAR" AUTHID CURRENT_USER AS
/* $Header: pygbp46c.pkh 120.4.12010000.2 2009/11/09 11:27:41 namgoyal ship $ */

----------------------------
-- PROCEDURE range_cursor --
----------------------------
-- Procedure which returns a varchar2 defining a SQL Statement to select
-- all the people in the business group.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr out nocopy varchar2);

-- For bug 6652235
----------------------------
-- PROCEDURE range_code for V2 --
----------------------------
-- Procedure which returns a varchar2 defining a SQL Statement to select
-- all the people in the business group.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
PROCEDURE range_code (pactid IN NUMBER,
                        sqlstr out nocopy varchar2);

-- For bug 8986543
----------------------------
-- PROCEDURE range_code_v3 for V3 --
----------------------------
-- Procedure which returns a varchar2 defining a SQL Statement to select
-- all the people in the business group.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
PROCEDURE range_code_v3 (pactid IN NUMBER,
                        sqlstr out nocopy varchar2);


------------------------------
-- PROCEDURE create_asg_act --
------------------------------
PROCEDURE create_asg_act(pactid IN NUMBER,
                            stperson IN NUMBER,
                            endperson IN NUMBER,
                            chunk IN NUMBER);

-- For bug 6652235
------------------------------
-- PROCEDURE create_asg_act_v2 --
------------------------------
PROCEDURE create_asg_act_v2(pactid IN NUMBER,
                            stperson IN NUMBER,
                            endperson IN NUMBER,
                            chunk IN NUMBER);

-- For bug 8986543
------------------------------
-- PROCEDURE create_asg_act_v3 --
------------------------------
PROCEDURE create_asg_act_v3(pactid IN NUMBER,
                            stperson IN NUMBER,
                            endperson IN NUMBER,
                            chunk IN NUMBER);


------------------------------
-- PROCEDURE archive_code   --
------------------------------
PROCEDURE archive_code(p_assactid IN NUMBER, p_effective_date IN DATE);

-- For bug 6652235
------------------------------
-- PROCEDURE archive_code_v2   --
------------------------------
PROCEDURE archive_code_v2(p_assactid IN NUMBER, p_effective_date IN DATE);


-- For bug 8986543
------------------------------
-- PROCEDURE archive_code_v3   --
------------------------------
PROCEDURE archive_code_v3(p_assactid IN NUMBER, p_effective_date IN DATE);


-----------------------------
-- Employer Header Cursor  --
-----------------------------
CURSOR c_employer_header IS
SELECT 'SENDER_ID=P', upper(nvl(org_information11,' ')),
  'RECEIVER_ID=P', 'INLAND REVENUE',
  'TEST_INDICATOR=P', decode(pay_gb_eoy_archive.get_parameter
                        (legislative_parameters,
                         'TEST'),'Y','1',' '),
  'URGENT_MARKER=P',  decode(pay_gb_eoy_archive.get_parameter
                        (legislative_parameters,
                         'URGENT'),'Y','1',' '),
  'REQUEST_ID=P', fnd_number.number_to_canonical(pact.request_id),
  'FORM_TYPE=P', '11',
  'FORM_TYPE_MEANING=P', 'P46 Car EDI',
  'TAX_DIST_NO=P', substr(hoi.org_information1,1,3),
  'TAX_DIST_REF=P',
  upper(substr(ltrim(substr(hoi.org_information1,4,11),'/') ,1,10)),            /* Bug no 4086307  */
  'TAX_DISTRICT=P', upper(nvl(substr(hoi.org_information2 ,1,40),' ')),
  'EMPLOYERS_ADDRESS_LINE=P',
  upper(nvl(substr(hoi.org_information4,1,60),' ')),
  'EMPLOYERS_NAME=P', upper(nvl(substr(hoi.org_information3,1,36),' '))
FROM  pay_payroll_actions pact,
      hr_organization_information hoi
WHERE pact.payroll_action_id = pay_magtape_generic.get_parameter_value
                                     ('TRANSFER_PAYROLL_ACTION_ID')
  AND   hoi.org_information_context = 'Tax Details References'
  AND    substr(pact.legislative_parameters,
                instr(pact.legislative_parameters,'TAX_REF=') + 8,
                    instr(pact.legislative_parameters||' ',' ',
                          instr(pact.legislative_parameters,'TAX_REF=')+8)
                - instr(pact.legislative_parameters,'TAX_REF=') - 8)
           = hoi.org_information1
  AND hoi.organization_id = pact.business_group_id;


------------------------------
-- Employee Details Cursor  --
------------------------------
CURSOR c_emp_details IS
SELECT
  'PERSON_ID=P', pai.action_information1,
  'ADDRESS_LINE1=P', nvl(max(action_information6), ' '),
  'ADDRESS_LINE2=P', nvl(max(action_information7), ' '),
  'ADDRESS_LINE3=P', nvl(max(action_information8), ' '),
  'COUNTY=P', nvl(max(action_information10), ' '),
  'FIRST_NAME=P', nvl(max(action_information3), ' '),
  'LAST_NAME=P', max(action_information2),
  'NI_NO=P', max(action_information5),
  'POSTAL_CODE=P', ' ', -- bug 5169434 not to output post code
  'TITLE=P', nvl(max(action_information4), ' '),
  'TOWN_OR_CITY=P', nvl(max(action_information9), ' ')
FROM   pay_assignment_actions act_edi,
----------------------------------------------------------
-- Commented out following joins to fix performance issue
-- raised in bug 3374673.
--       pay_action_interlocks  pail,
--       pay_assignment_actions act,
----------------------------------------------------------
-- Bug 4059844 - SQL Repository Perf
--       pay_payroll_actions    pact,
       pay_action_information pai
WHERE  act_edi.payroll_action_id = pay_magtape_generic.get_parameter_value
                                         ('TRANSFER_PAYROLL_ACTION_ID')
  AND  act_edi.assignment_action_id = pai.action_context_id
  AND  pai.action_context_type            = 'AAP'
  AND  pai.action_information_category = 'GB P46 CAR EDI EMPLOYEE DETAIL'
GROUP  BY pai.action_information1
ORDER  BY 14, 12;

--------------------------------
-- Allocation Details Cursor  --
--------------------------------
CURSOR c_allocation_details IS
SELECT distinct
  'VEHICLE_ALLOCATION_ID=P', pai.action_information2,
  'ACTION_FLAG=P', pai.action_information1,
  'VEHICLE_ALLOCATION_EFF_START_DATE=P', pai.action_information3,
  'VEHICLE_ALLOCATION_EFF_END_DATE=P', pai.action_information4,
  'VEHICLE_REPOSITORY_ID=P', pai.action_information5,
  'P46_REPLACED_VEHICLE_ALLOCATION_ID=P', nvl(action_information20, ' '),
  'P46_REPLACED_VEHICLE_ALLOC_EFF_END_DATE=P', nvl(action_information21, ' '),
  'P46_SECOND_CAR_FLAG=P', nvl(action_information15, ' '),
  'CAR_LIST_PRICE=P', action_information6,
  'PRICE_OF_ACCESSORIES=P', action_information7,
  'EMPLOYEE_CAPITAL_CONTRIBUTIONS=P', action_information8,
  'EMPLOYEE_PRIVATE_CONTRIBUTIONS=P', action_information9,
  'REPLACED_CAR_MAKE_AND_MODEL=P', nvl(action_information18, ' '),
  'ENGINE_SIZE_OF_CAR_REPLACED=P', nvl(action_information19, ' '),
  'CAR_MAKE_AND_MODEL=P', action_information16,
  'ENGINE_SIZE_OF_CAR=P', action_information17,
  'FUEL_TYPE=P', action_information10,
  'CO2_EMISSIONS_FIGURE=P', action_information11,
  'FUEL_FOR_PRIVATE_USE_FLAG=P', action_information12,
  'DATE_CAR_FIRST_REGISTERED=P', action_information13,
  'DATE_CAR_FIRST_AVAILABLE=P', nvl(action_information14, ' ')
FROM   pay_assignment_actions act_edi,
       per_all_assignments_f asg,
       pay_action_information pai
WHERE  act_edi.payroll_action_id = pay_magtape_generic.get_parameter_value
                                         ('TRANSFER_PAYROLL_ACTION_ID')
  AND  asg.person_id = pay_magtape_generic.get_parameter_value(
                                'PERSON_ID')
  AND  act_edi.assignment_id = asg.assignment_id
  AND  act_edi.assignment_action_id = pai.action_context_id
  AND  pai.action_context_type             = 'AAP'
  AND  pai.action_information_category = 'GB P46 CAR EDI ALLOCATION'
ORDER BY 2, 6, 4;
--

-- For bug 6652235
-----------------------------
-- Employer Header Cursor V2  --
-----------------------------
CURSOR c_employer_header_v2 IS
SELECT 'SENDER_ID=P', upper(nvl(org_information11,' ')),
  'RECEIVER_ID=P', 'HMRC',
  'TEST_INDICATOR=P', decode(pay_gb_eoy_archive.get_parameter
                        (legislative_parameters,
                         'TEST'),'Y','1',' '),
  'URGENT_MARKER=P', ' ',/*2008*/
  'REQUEST_ID=P', fnd_number.number_to_canonical(pact.request_id),
  'FORM_TYPE=P', '11',
  'FORM_TYPE_MEANING=P', 'P46 Car EDI',
  'TAX_DIST_NO=P', substr(hoi.org_information1,1,3),
  'TAX_DIST_REF=P',
  upper(substr(ltrim(substr(hoi.org_information1,4,11),'/') ,1,10)),            /* Bug no 4086307  */
  'TAX_DISTRICT=P', upper(nvl(substr(hoi.org_information2 ,1,40),' ')),
  'EMPLOYERS_ADDRESS_LINE=P',
  upper(nvl(substr(hoi.org_information4,1,60),' ')),
  'EMPLOYERS_NAME=P', upper(nvl(substr(hoi.org_information3,1,36),' ')),
  'TAX_YEAR=P', to_char(to_char(to_date(substr(pact.legislative_parameters,
                 instr(pact.legislative_parameters,'END_DATE=')+9, 10),'YYYY/MM/DD'),'YYYY')
                 + decode(sign(to_date(substr(pact.legislative_parameters,
                   instr(pact.legislative_parameters,'END_DATE=')+9, 10),'YYYY/MM/DD')
                   -to_date('06-04-'|| to_char(to_date(substr(pact.legislative_parameters,
                    instr(pact.legislative_parameters,'END_DATE=')+9, 10),'YYYY/MM/DD'),
                    'YYYY'),'DD-MM-YYYY')), -1,0,1))
FROM  pay_payroll_actions pact,
      hr_organization_information hoi
WHERE pact.payroll_action_id = pay_magtape_generic.get_parameter_value
                                     ('TRANSFER_PAYROLL_ACTION_ID')
  AND   hoi.org_information_context = 'Tax Details References'
  AND    substr(pact.legislative_parameters,
                instr(pact.legislative_parameters,'TAX_REF=') + 8,
                    instr(pact.legislative_parameters||' ',' ',
                          instr(pact.legislative_parameters,'TAX_REF=')+8)
                - instr(pact.legislative_parameters,'TAX_REF=') - 8)
           = hoi.org_information1
  AND hoi.organization_id = pact.business_group_id;


------------------------------
-- Employee Details Cursor V2 --
------------------------------
CURSOR c_emp_details_v2 IS
SELECT
  'ASSIGNMENT_ACTION_ID=C',max(act_edi.assignment_action_id),
  'PERSON_ID=P', pai.action_information1,
  'ADDRESS_LINE1=P', nvl(max(action_information6), ' '),
  'ADDRESS_LINE2=P', nvl(max(action_information7), ' '),
  'ADDRESS_LINE3=P', nvl(max(action_information8), ' '),
  'COUNTY=P', nvl(max(action_information10), ' '),
  'FIRST_NAME=P', nvl(max(action_information3), ' '),
  'LAST_NAME=P', max(action_information2),
  'NI_NO=P', max(action_information5),
  'POSTAL_CODE=P', ' ', -- bug 5169434 not to output post code
  'TITLE=P', nvl(max(action_information4), ' '),
  'TOWN_OR_CITY=P', nvl(max(action_information9), ' '),
  'DOB=P', nvl(max(ACTION_INFORMATION12),' '),
  'GENDER=P',nvl(max(ACTION_INFORMATION13), ' ')
FROM   pay_assignment_actions act_edi,
----------------------------------------------------------
-- Commented out following joins to fix performance issue
-- raised in bug 3374673.
--       pay_action_interlocks  pail,
--       pay_assignment_actions act,
----------------------------------------------------------
-- Bug 4059844 - SQL Repository Perf
--       pay_payroll_actions    pact,
       pay_action_information pai
WHERE  act_edi.payroll_action_id = pay_magtape_generic.get_parameter_value
                                         ('TRANSFER_PAYROLL_ACTION_ID')
  AND  act_edi.assignment_action_id = pai.action_context_id
  AND  pai.action_context_type            = 'AAP'
  AND  pai.action_information_category = 'GB P46 CAR EDI EMPLOYEE DETAIL'
GROUP  BY pai.action_information1
ORDER  BY 14, 12;

--------------------------------
-- Allocation Details Cursor V2  --
--------------------------------
CURSOR c_allocation_details_v2 IS
SELECT distinct
  'VEHICLE_ALLOCATION_ID=P', pai.action_information2,
  'ACTION_FLAG=P', pai.action_information1,
  'VEHICLE_ALLOCATION_EFF_START_DATE=P', pai.action_information3,
  'VEHICLE_ALLOCATION_EFF_END_DATE=P', pai.action_information4,
  'VEHICLE_REPOSITORY_ID=P', pai.action_information5,
  'P46_REPLACED_VEHICLE_ALLOCATION_ID=P', nvl(action_information20, ' '),
  'P46_REPLACED_VEHICLE_ALLOC_EFF_END_DATE=P', nvl(action_information21, ' '),
  'P46_SECOND_CAR_FLAG=P', nvl(action_information15, ' '),
  'CAR_LIST_PRICE=P', action_information6,
  'PRICE_OF_ACCESSORIES=P', action_information7,
  'EMPLOYEE_CAPITAL_CONTRIBUTIONS=P', action_information8,
  'EMPLOYEE_PRIVATE_CONTRIBUTIONS=P', action_information9,
  'REPLACED_CAR_MAKE_AND_MODEL=P', nvl(action_information18, ' '),
  'ENGINE_SIZE_OF_CAR_REPLACED=P', nvl(action_information19, ' '),
  'CAR_MAKE_AND_MODEL=P', action_information16,
  'ENGINE_SIZE_OF_CAR=P', action_information17,
  'FUEL_TYPE=P', action_information10,
  'CO2_EMISSIONS_FIGURE=P', action_information11,
  'FUEL_FOR_PRIVATE_USE_FLAG=P', action_information12,
  'DATE_CAR_FIRST_REGISTERED=P', action_information13,
  'DATE_CAR_FIRST_AVAILABLE=P', nvl(action_information14, ' ')
FROM   pay_assignment_actions act_edi,
       per_all_assignments_f asg,
       pay_action_information pai
WHERE  act_edi.payroll_action_id = pay_magtape_generic.get_parameter_value
                                         ('TRANSFER_PAYROLL_ACTION_ID')
  AND  asg.person_id = pay_magtape_generic.get_parameter_value(
                                'PERSON_ID')
  AND  act_edi.assignment_id = asg.assignment_id
  AND  act_edi.assignment_action_id = pai.action_context_id
  AND  pai.action_context_type             = 'AAP'
  AND  pai.action_information_category = 'GB P46 CAR EDI ALLOCATION'
ORDER BY 2, 6, 4;


-- For bug 8986543
-----------------------------
-- Employer Header Cursor V3  --
-----------------------------
CURSOR c_employer_header_v3 IS
SELECT 'SENDER_ID=P', upper(nvl(org_information11,' ')),
  'RECEIVER_ID=P', 'HMRC',
  'TEST_INDICATOR=P', decode(pay_gb_eoy_archive.get_parameter
                        (legislative_parameters,
                         'TEST'),'Y','1',' '),
  'URGENT_MARKER=P', ' ',/*2008*/
  'REQUEST_ID=P', fnd_number.number_to_canonical(pact.request_id),
  'FORM_TYPE=P', '11',
  'FORM_TYPE_MEANING=P', 'P46 Car EDI',
  'TAX_DIST_NO=P', substr(hoi.org_information1,1,3),
  'TAX_DIST_REF=P',
  upper(substr(ltrim(substr(hoi.org_information1,4,11),'/') ,1,10)),            /* Bug no 4086307  */
  'TAX_DISTRICT=P', upper(nvl(substr(hoi.org_information2 ,1,40),' ')),
  'EMPLOYERS_ADDRESS_LINE=P',
  upper(nvl(substr(hoi.org_information4,1,60),' ')),
  'EMPLOYERS_NAME=P', upper(nvl(substr(hoi.org_information3,1,36),' ')),
  'TAX_YEAR=P', to_char(to_char(to_date(substr(pact.legislative_parameters,
                 instr(pact.legislative_parameters,'END_DATE=')+9, 10),'YYYY/MM/DD'),'YYYY')
                 + decode(sign(to_date(substr(pact.legislative_parameters,
                   instr(pact.legislative_parameters,'END_DATE=')+9, 10),'YYYY/MM/DD')
                   -to_date('06-04-'|| to_char(to_date(substr(pact.legislative_parameters,
                    instr(pact.legislative_parameters,'END_DATE=')+9, 10),'YYYY/MM/DD'),
                    'YYYY'),'DD-MM-YYYY')), -1,0,1))
FROM  pay_payroll_actions pact,
      hr_organization_information hoi
WHERE pact.payroll_action_id = pay_magtape_generic.get_parameter_value
                                     ('TRANSFER_PAYROLL_ACTION_ID')
  AND   hoi.org_information_context = 'Tax Details References'
  AND    substr(pact.legislative_parameters,
                instr(pact.legislative_parameters,'TAX_REF=') + 8,
                    instr(pact.legislative_parameters||' ',' ',
                          instr(pact.legislative_parameters,'TAX_REF=')+8)
                - instr(pact.legislative_parameters,'TAX_REF=') - 8)
           = hoi.org_information1
  AND hoi.organization_id = pact.business_group_id;


------------------------------
-- Employee Details Cursor V3 --
------------------------------
CURSOR c_emp_details_v3 IS
SELECT
  'ASSIGNMENT_ACTION_ID=C',max(act_edi.assignment_action_id),
  'PERSON_ID=P', pai.action_information1,
  'ADDRESS_LINE1=P', nvl(max(action_information6), ' '),
  'ADDRESS_LINE2=P', nvl(max(action_information7), ' '),
  'ADDRESS_LINE3=P', nvl(max(action_information8), ' '),
  'COUNTY=P', nvl(max(action_information10), ' '),
  'FIRST_NAME=P', nvl(max(action_information3), ' '),
  'LAST_NAME=P', max(action_information2),
  'NI_NO=P', max(action_information5),
  'POSTAL_CODE=P', ' ', -- bug 5169434 not to output post code
  'TITLE=P', nvl(max(action_information4), ' '),
  'TOWN_OR_CITY=P', nvl(max(action_information9), ' '),
  'DOB=P', nvl(max(ACTION_INFORMATION12),' '),
  'GENDER=P',nvl(max(ACTION_INFORMATION13), ' ')
FROM   pay_assignment_actions act_edi,
----------------------------------------------------------
-- Commented out following joins to fix performance issue
-- raised in bug 3374673.
--       pay_action_interlocks  pail,
--       pay_assignment_actions act,
----------------------------------------------------------
-- Bug 4059844 - SQL Repository Perf
--       pay_payroll_actions    pact,
       pay_action_information pai
WHERE  act_edi.payroll_action_id = pay_magtape_generic.get_parameter_value
                                         ('TRANSFER_PAYROLL_ACTION_ID')
  AND  act_edi.assignment_action_id = pai.action_context_id
  AND  pai.action_context_type            = 'AAP'
  AND  pai.action_information_category = 'GB P46 CAR EDI EMPLOYEE DETAIL'
GROUP  BY pai.action_information1
ORDER  BY 14, 12;

--------------------------------
-- Allocation Details Cursor V3  --
--------------------------------
CURSOR c_allocation_details_v3 IS
SELECT distinct
  'VEHICLE_ALLOCATION_ID=P', pai.action_information2,
  'ACTION_FLAG=P', pai.action_information1,
  'VEHICLE_ALLOCATION_EFF_START_DATE=P', pai.action_information3,
  'VEHICLE_ALLOCATION_EFF_END_DATE=P', pai.action_information4,
  'VEHICLE_REPOSITORY_ID=P', pai.action_information5,
  'P46_SECOND_CAR_FLAG=P', nvl(action_information15, ' '),
  'CAR_LIST_PRICE=P', action_information6,
  'PRICE_OF_ACCESSORIES=P', action_information7,
  'EMPLOYEE_CAPITAL_CONTRIBUTIONS=P', action_information8,
  'EMPLOYEE_PRIVATE_CONTRIBUTIONS=P', action_information9,
  'CAR_MAKE_AND_MODEL=P', action_information16,
  'ENGINE_SIZE_OF_CAR=P', action_information17,
  'FUEL_TYPE=P', action_information10,
  'CO2_EMISSIONS_FIGURE=P', action_information11,
  'FUEL_FOR_PRIVATE_USE_FLAG=P', action_information12,
  'DATE_CAR_FIRST_REGISTERED=P', action_information13,
  'DATE_CAR_FIRST_AVAILABLE=P', nvl(action_information14, ' ')
FROM   pay_assignment_actions act_edi,
       per_all_assignments_f asg,
       pay_action_information pai
WHERE  act_edi.payroll_action_id = pay_magtape_generic.get_parameter_value
                                         ('TRANSFER_PAYROLL_ACTION_ID')
  AND  asg.person_id = pay_magtape_generic.get_parameter_value(
                                'PERSON_ID')
  AND  act_edi.assignment_id = asg.assignment_id
  AND  act_edi.assignment_action_id = pai.action_context_id
  AND  pai.action_context_type             = 'AAP'
  AND  pai.action_information_category = 'GB P46 CAR EDI ALLOCATION'
ORDER BY 2,4;

--

level_cnt NUMBER;

END pay_gb_edi_p46_car;

/
