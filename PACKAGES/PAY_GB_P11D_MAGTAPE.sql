--------------------------------------------------------
--  DDL for Package PAY_GB_P11D_MAGTAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_P11D_MAGTAPE" AUTHID CURRENT_USER As
/* $Header: pygbpdtp.pkh 120.3.12000000.1 2007/01/17 20:29:28 appldev noship $ */
   level_cnt                     NUMBER; -- required by the generic magtape procedure.

   FUNCTION round_and_pad(l_input_value VARCHAR2, l_cut_to_size NUMBER)
      RETURN VARCHAR2;

   FUNCTION format_edi_currency(l_input_value VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_description(
      l_lookup_code      VARCHAR2,
      l_lookup_type      VARCHAR2,
      l_effective_date   VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_parameters(
      p_payroll_action_id   IN   NUMBER,
      p_token_name          IN   VARCHAR2,
      p_tax_ref             IN   VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

-- CURSORS
   CURSOR csr_p11d_header
   IS
      SELECT 'TAX_YEAR=P',
             pay_gb_p11d_magtape.get_parameters(
                pay_magtape_generic.get_parameter_value(
                   'ARCH_PAYROLL_ACTION_ID'),
                'Rep_Run'),
             'SUBMITTER_REF_NO=P',
             UPPER(
                TRANSLATE(
                   pay_magtape_generic.get_parameter_value(
                      'SUBMITTER_REF_NO'),
                   fnd_global.local_chr(10),
                   ' ') ),
             'SUBMITTER_NAME=P',
             UPPER(
                TRANSLATE(
                   pay_magtape_generic.get_parameter_value('SUBMITTER_NAME'),
                   fnd_global.local_chr(10),
                   ' ') ),
             'SUB_RET_NO=P',
             pay_magtape_generic.get_parameter_value('SUB_RET_NO'),
             'TOT_SUB_RET=P',
             pay_magtape_generic.get_parameter_value('TOT_SUB_RET'),
             'VOL_NO=P', pay_magtape_generic.get_parameter_value('VOL_NO'),
             'SENDER_ID=P',pay_gb_p11d_magtape.get_parameters(
                                     pay_magtape_generic.get_parameter_value(
                                        'ARCH_PAYROLL_ACTION_ID'),
                                     'SENDER_ID'),
             'TEST_SUBMISSION=P',pay_magtape_generic.get_parameter_value('TEST_SUBMISSION'),
             'SUBMISSION_TYPE=P',pay_magtape_generic.get_parameter_value('SUBMISSION_TYPE'),
             'TRANSMISSION_DATE=P',to_char(sysdate,'YYYYMMDDHHMMSS'),
             'UNIQUE_REFERENCE=P',pay_gb_p11d_magtape.get_parameters(
                                     pay_magtape_generic.get_parameter_value(
                                        'ARCH_PAYROLL_ACTION_ID'),
                                     'REQUEST_ID')
        FROM DUAL;

   CURSOR csr_p11d_employer
   IS
      SELECT /*+ ordered use_nl(paa,pai)
                 use_index(pai,pay_action_information_n2) */
             DISTINCT 'TAX_OFFICE_NAME=P',
                      NVL(UPPER(action_information4), ' '),
                      'TAX_OFFICE_PHONE_NO=P',
                      NVL(UPPER(action_information5), ' '),
                      'EMPLOYERS_REF_NO=P',
                      NVL(UPPER(action_information6), ' '),
                      'EMPLOYERS_NAME=P',
                      NVL(UPPER(action_information7), ' '),
                      'EMPLOYERS_ADDRESS=P',
                      NVL(UPPER(action_information8), ' '),
                      'MESSAGE_DATE=P',
                      to_char(sysdate,'YYYYMMDD'),
                      'BENEFIT_TAX_YEAR=P',
                            SUBSTR(pay_gb_p11d_magtape.get_parameters(
                               pay_magtape_generic.get_parameter_value(
                                  'ARCH_PAYROLL_ACTION_ID'),
                               'BENEFIT_END_DATE'),1,4),
                      'PARTY_NAME=P',
                            pay_gb_p11d_magtape.get_parameters(
                               pay_magtape_generic.get_parameter_value(
                                  'ARCH_PAYROLL_ACTION_ID'),
                               'PARTY_NAME')
                FROM pay_assignment_actions paa, pay_action_information pai
                WHERE paa.payroll_action_id =
                            pay_magtape_generic.get_parameter_value(
                               'ARCH_PAYROLL_ACTION_ID')
                  AND pai.action_context_id = paa.assignment_action_id
                  AND pai.action_information_category = 'EMEA PAYROLL INFO';

   CURSOR csr_p11d_employee
   IS
      SELECT          /*+ ordered
         use_nl(paa, pai)
         use_nl(paa, pai_emp)
         use_nl(paa, pai_gb)
         use_nl(paa, pai_person)
         use_index(pai,pay_action_information_n2)
         use_index(pai_emp,pay_action_information_n2)
         use_index(pai_gb,pay_action_information_n2)
         use_index(pai_person,pay_action_information_n2)*/
             DISTINCT 'LAST_NAME=P',
                      NVL(
                         SUBSTR(UPPER(pai_gb.action_information8), 1, 36),
                         ' '),
                      'FIRST_NAME=P',
                      NVL(
                         SUBSTR(UPPER(pai_gb.action_information6), 1, 36),
                         ' '),
                      'MIDDLE_NAME=P',
                      NVL(
                         SUBSTR(UPPER(pai_gb.action_information7), 1, 36),
                         ' '),
                      'DIRECTOR_FLAG=P',
                      NVL(UPPER(pai_gb.action_information4), 'N'),
                      'EMPLOYEE_NUMBER=P',
                      NVL(UPPER(pai_emp.action_information10), ' '),
                      'NATIONAL_INS_NO=P',
                      NVL(UPPER(pai_emp.action_information4), 'NONE'),
                      'PERSON_ID=P', pai_person.action_information1,
                      'ADDRESS_LINE_1=P',
                      NVL(pai_person.action_information5, ' '),
                      'ADDRESS_LINE_2=P',
                      NVL(pai_person.action_information6, ' '),
                      'ADDRESS_LINE_3=P',
                      NVL(pai_person.action_information7, ' '),
                      'ADDRESS_LINE_4=P',
                      NVL(pai_person.action_information8, ' '),
                      'ADDRESS_LINE_5=P',
                      NVL(hl.meaning, ' ')
                 FROM pay_assignment_actions paa,
                      pay_action_information pai,
                      pay_action_information pai_emp,
                      pay_action_information pai_gb,
                      pay_action_information pai_person,
                      hr_lookups hl
                WHERE paa.payroll_action_id =
                            pay_magtape_generic.get_parameter_value(
                               'ARCH_PAYROLL_ACTION_ID')
                  AND pai.action_context_id = paa.assignment_action_id
                  AND pai.action_information_category = 'EMEA PAYROLL INFO'
                  AND pai.action_information6 =
                            pay_magtape_generic.get_parameter_value(
                               'EMPLOYERS_REF_NO')
                  AND pai_person.action_context_id = paa.assignment_action_id
                  AND pai_person.action_information_category =
                                                            'ADDRESS DETAILS'
                  AND pai_person.action_information14 = 'Employee Address'
                  AND pai_gb.action_context_id = paa.assignment_action_id
                  AND pai_gb.action_information_category =
                                                        'GB EMPLOYEE DETAILS'
                  AND pai_emp.action_context_id = paa.assignment_action_id
                  AND pai_emp.action_information_category =
                                                           'EMPLOYEE DETAILS'
                  AND hl.lookup_type(+) = 'GB_COUNTY'
                  AND hl.lookup_code(+) = pai_person.action_information9;

   CURSOR csr_p11d_emp_ben_catg
   IS
      SELECT          /*+ ordered
         use_nl(paa,pai)
         use_nl(paa,pai_comp)
         use_nl(paa,pai_person)
         use_index(pai,pay_action_information_n2)
         use_index(pai_comp,pay_action_information_n2)
         use_index(pai_person,pay_action_information_n2)*/
                     'ACTION_INFORMATION_CATG=P',
                      pai.action_information_category,
                      DECODE(
                         pai.action_information_category,
                         'FPCS_CAERS', 'U',
                         'MARORS', 'U',
                         'TAXABLE EXPENSE PAYMENTS', 'V',
                         'ASSETS TRANSFERRED', 'A',
                         'ASSETS AT EMP DISPOSAL', 'L',
                         'EXPENSES PAYMENTS', 'O',
                         'INT FREE AND LOW INT LOANS', 'H',
                         'LIVING ACCOMMODATION', 'D',
                         'MILEAGE ALLOWANCE', 'E',
                         'MILEAGE ALLOWANCE AND PPAYMENT', 'E',
                         'OTHER ITEMS', 'N',
                         'PAYMENTS MADE FOR EMP', 'B',
                         'PVT MED TREATMENT OR INSURANCE', 'I',
                         'RELOCATION EXPENSES', 'J',
                         'SERVICES SUPPLIED', 'K',
                         'VANS 2002_03', 'G',
                         'VOUCHERS OR CREDIT CARDS', 'C',
                         'CAERS', 'U',
                         'OTHER ITEMS NON 1A', 'N',
                         'CAR AND CAR FUEL 2003_04', 'F') cat_order
                 FROM pay_assignment_actions paa,
                      pay_action_information pai_person,
                      pay_action_information pai_comp,
                      pay_action_information pai
                WHERE paa.payroll_action_id =
                            pay_magtape_generic.get_parameter_value(
                               'ARCH_PAYROLL_ACTION_ID')
                  AND pai_comp.action_context_id = paa.assignment_action_id
                  AND pai_comp.action_information_category =  'EMEA PAYROLL INFO'
                  AND pai_comp.action_context_type = 'AAP'
                  AND pai_comp.action_information6 =
                            pay_magtape_generic.get_parameter_value('EMPLOYERS_REF_NO')
                  AND pai_person.action_context_id = paa.assignment_action_id
                  AND pai_person.action_information_category ='ADDRESS DETAILS'
                  AND pai_person.action_context_type = 'AAP'
                  AND pai_person.action_information14 = 'Employee Address'
                  AND pai_person.action_information1 =
                         pay_magtape_generic.get_parameter_value('PERSON_ID')
                  AND pai.action_context_id = paa.assignment_action_id
                  AND pai.action_context_type = 'AAP'
                  AND pai.action_information_category NOT IN
                            ('EMPLOYEE DETAILS',
                             'ADDRESS DETAILS',
                             'EMEA PAYROLL INFO',
                             'GB EMPLOYEE DETAILS',
                             'GB P11D ASSIGNMENT RESULTA',
                             'GB P11D ASSIGNMENT RESULTB',
                             'GB P11D ASSIGNMENT RESULTC')
                  AND ((    pai.action_information_category = 'OTHER ITEMS NON 1A'
                        AND not exists (select 1
                                        from   pay_action_information pai1
                                        where  pai1.action_context_id = paa.assignment_action_id
                                        and    pai1.action_context_type = 'AAP'
                                        and    pai1.action_information_category = 'OTHER ITEMS')
                       )
                       OR
                           pai.action_information_category <> 'OTHER ITEMS NON 1A'
                      )
             GROUP BY pai.action_information_category
             ORDER BY cat_order;

   CURSOR csr_p11d_emp_benefits
   IS
      SELECT   /*+ ordered
         use_nl(paa,pai)
         use_nl(paa,pai_comp)
         use_nl(paa,pai_person)
         use_index(pai,pay_action_information_n2)
         use_index(pai_comp,pay_action_information_n2)
         use_index(pai_person,pay_action_information_n2)*/
               'SCHEME_TYPE=P',
               DECODE(
                  pai.action_information_category,
                  'TAXABLE EXPENSE PAYMENTS', pai.action_information6,
                  ' '),
               'TYPE_OF_USER=P',
               DECODE(
                  pai.action_information_category,
                  'TAXABLE EXPENSE PAYMENTS', pai.action_information7,
                  ' '),
               'CLASS_OF_CAR=P',
               DECODE(
                  pai.action_information_category,
                  'TAXABLE EXPENSE PAYMENTS', pai.action_information8,
                  ' '),
               'REVENUE_RELIEF_RATE=P',
               DECODE(
                  pai.action_information_category,
                  'CAERS', pai.action_information6,
                  'FPCS_CAERS', pai.action_information6,
                  ' '),
               'MILEAGE_RATE=P',
               DECODE(
                  pai.action_information_category,
                  'CAERS', NVL(pai.action_information8, 0),
                  'FPCS_CAERS', NVL(pai.action_information9, 0),
                  ' '),
               'RECORD_IDENTIFIER=P',
               DECODE(
                  pai.action_information_category,
                  'INT FREE AND LOW INT LOANS', pai.action_information1,
                  'OTHER ITEMS', 'OTHER ITEMS',
                  'OTHER ITEMS NON 1A', 'OTHER ITEMS NON 1A',
                  ' '),
               'BENEFIT_START_DATE=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', pai.action_information3,
                  'CARS AND CAR FUEL 2001 2002', pai.action_information3,
                  'CAR AND CAR FUEL', pai.action_information3,
                  'CAR AND CAR FUEL 2003_04', pai.action_information3,
                  ' '),
               'BENEFIT_END_DATE=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', pai.action_information4,
                  'CARS AND CAR FUEL 2001 2002', pai.action_information4,
                  'CAR AND CAR FUEL', pai.action_information4,
                  'CAR AND CAR FUEL 2003_04', pai.action_information4,
                  ' '),
               'MAKE_OF_CAR=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', UPPER(pai.action_information6),
                  'CARS AND CAR FUEL 2001 2002', UPPER(
                                                    pai.action_information6),
                  'CAR AND CAR FUEL', UPPER(pai.action_information6),
                  'CAR AND CAR FUEL 2003_04', UPPER(pai.action_information6),
                  ' '),
               'MODEL=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', UPPER(pai.action_information7),
                  'CARS AND CAR FUEL 2001 2002', UPPER(
                                                    pai.action_information7),
                  'CAR AND CAR FUEL', UPPER(pai.action_information7),
                  'CAR AND CAR FUEL 2003_04', UPPER(pai.action_information7),
                  ' '),
               'DATE_FIRST_REGISTERED=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', pai.action_information8,
                  'CARS AND CAR FUEL 2001 2002', pai.action_information8,
                  'CAR AND CAR FUEL', pai.action_information8,
                  'CAR AND CAR FUEL 2003_04', nvl(pai.action_information8,0),
                  '0'),
               'LIST_PRICE=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', pai.action_information9,
                  'CARS AND CAR FUEL 2001 2002', pai.action_information9,
                  'CAR AND CAR FUEL', pai.action_information9,
                  'CAR AND CAR FUEL 2003_04', pai.action_information9,
                  ' '),
               'CASH_EQUIVALENT_FOR_CAR=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'CARS AND CAR FUEL', NVL(pai.action_information10, 0),
                     'CARS AND CAR FUEL 2001 2002', NVL(
                                                       pai.action_information10,
                                                       0),
                     'CAR AND CAR FUEL', NVL(pai.action_information10, 0),
                     'CAR AND CAR FUEL 2003_04', NVL(pai.action_information10, 0),
                     '0') ),
               'PRIMARY_INDICATOR=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(
                                          UPPER(pai.action_information11),
                                          'N'),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    UPPER(
                                                       pai.action_information11),
                                                    'N'),
                 'CAR AND CAR FUEL 2003_04', NVL(pai.action_information27, 'N'),
                 -- for car this hold the FREE_FUEL_REINSTATED value
                  ' '),
               'CASH_EQUIVALENT_OF_FUEL=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'CARS AND CAR FUEL', NVL(pai.action_information12, 0),
                     'CARS AND CAR FUEL 2001 2002', NVL(
                                                       pai.action_information12,
                                                       0),
                     'CAR AND CAR FUEL', NVL(pai.action_information11, 0),
                     'CAR AND CAR FUEL 2003_04', NVL(pai.action_information11, 0),
                     '0') ),
               'FUEL_TYPE=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(
                                          UPPER(pai.action_information13),
                                          'DIESEL'),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    UPPER(
                                                       pai.action_information13),
                                                    'DIESEL'),
                  'CAR AND CAR FUEL', NVL(
                                         UPPER(pai.action_information12),
                                         'DIESEL'),
                  'CAR AND CAR FUEL 2003_04', NVL(
                                         UPPER(pai.action_information12),
                                         'DIESEL'),
                  ' '),
               'OPTIONAL_ACCESSORIES_FITTED=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(pai.action_information17, 0),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    pai.action_information18,
                                                    0),
                  'CAR AND CAR FUEL', NVL(pai.action_information16, 0),
                  'CAR AND CAR FUEL 2003_04', NVL(pai.action_information15, 0),
                  ' '),
               'PRICE_OF_ACCESSORIES_ADDED_AFT=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(pai.action_information18, 0),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    pai.action_information19,
                                                    0),
                  'CAR AND CAR FUEL', NVL(pai.action_information17, 0),
                  'CAR AND CAR FUEL 2003_04', NVL(pai.action_information26,0),
                  -- for 03 04 this holds the DATE_FREE_FUEL_WITHDRWAN
                  ' '),
               'CAPITAL_CONTRIBUTIONS_MADE=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(pai.action_information19, 0),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    pai.action_information27,
                                                    0),
                  'CAR AND CAR FUEL', NVL(pai.action_information18, 0),
                  'CAR AND CAR FUEL 2003_04', NVL(pai.action_information16, 0),
                  ' '),
               'PRIVATE_USE_PAYMENTS=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(pai.action_information20, 0),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    pai.action_information20,
                                                    0),
                  'CAR AND CAR FUEL', NVL(pai.action_information19, 0),
                  'CAR AND CAR FUEL 2003_04', NVL(pai.action_information17, 0),
                  ' '),
               'ENGINE_CC_FOR_FUEL_CHARGE=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(pai.action_information21, '9999'),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    pai.action_information21,
                                                    '9999'),
                  'CAR AND CAR FUEL', NVL(pai.action_information20, '9999'),
                  'CAR AND CAR FUEL 2003_04', NVL(pai.action_information18, '9999'),
                  ' '),
               'MILEAGE_BAND=P', --CO2_EMISSIONS for CAR AND CAR FUEL element
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(
                                          UPPER(pai.action_information22),
                                          1),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    UPPER(
                                                       pai.action_information22),
                                                    1),
                  'CAR AND CAR FUEL', pai.action_information13, --CO2_EMISSIONS
                  'CAR AND CAR FUEL 2003_04', pai.action_information13, --CO2_EMISSIONS
                  ' '),
               'ASSET_TYPE=P',
               DECODE(
                  pai.action_information_category,
                  'ASSETS TRANSFERRED', pay_gb_p11d_magtape.get_description(
                                           pai.action_information6,
                                           'GB_ASSET_TYPE',
                                           pai.action_information4),
                  ' '),
               'ASSET_DESCRIPTION=P',
               DECODE(
                  pai.action_information_category,
                  'ASSETS TRANSFERRED', UPPER(pai.action_information5),
                  ' '),
               'ASSETS=P',
               DECODE(
                  pai.action_information_category,
                  'ASSETS AT EMP DISPOSAL', pay_gb_p11d_magtape.get_description(
                                               pai.action_information5,
                                               'GB_ASSETS',
                                               pai.action_information4),
                  ' '),
               'EXPENSE_TYPE=P',
               DECODE(
                  pai.action_information_category,
                  'EXPENSES PAYMENTS', pay_gb_p11d_magtape.get_description(
                                          pai.action_information5,
                                          'GB_EXPENSE_TYPE',
                                          pai.action_information4),
                  ' '),
               'OTHER_ITEMS=P',
               DECODE(
                  pai.action_information_category,
                  'OTHER ITEMS', pay_gb_p11d_magtape.get_description(
                                    pai.action_information5,
                                    'GB_OTHER_ITEMS',
                                    pai.action_information4),
                  'OTHER ITEMS NON 1A', pay_gb_p11d_magtape.get_description(
                                           pai.action_information5,
                                           'GB_OTHER_ITEMS_NON_1A',
                                           pai.action_information4),
                  ' '),
               'PAYMENTS_MADE=P',
               DECODE(
                  pai.action_information_category,
                  'PAYMENTS MADE FOR EMP', pay_gb_p11d_magtape.get_description(
                                              pai.action_information6,
                                              'GB_PAYMENTS_MADE',
                                              pai.action_information4),
                  ' '),
               'NUMBER_OF_JOINT_BORROWERS=P',
               DECODE(
                  pai.action_information_category,
                  'INT FREE AND LOW INT LOANS', NVL(
                                                   pai.action_information5,
                                                   1),
                  ' '),
               'SHARES_INDICATOR=P',
               DECODE(
                  pai.action_information_category,
                  'P11D SHARES', pai.action_information5,
                  ' '),
               'TRADING_ORGANISATION_INDICATOR=P',
               DECODE(
                  pai.action_information_category,
                  'EXPENSES PAYMENTS', NVL(
                                          UPPER(pai.action_information10),
                                          'N'),
                  ' '),
               'DATE_LOAN_MADE=P',
               DECODE(
                  pai.action_information_category,
                  'INT FREE AND LOW INT LOANS', NVL(
                                                   pai.action_information9,
                                                   ' '),
                  ' '),
               'DATE_LOAN_DISCHARGED=P',
               DECODE(
                  pai.action_information_category,
                  'INT FREE AND LOW INT LOANS', NVL(
                                                   pai.action_information10,
                                                   ' '),
                  ' '),

-- SUM FIELDS
               'CASH_EQUIVALENT=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'LIVING ACCOMMODATION', pai.action_information10,
                     'RELOCATION EXPENSES', pai.action_information5,
                     'PAYMENTS MADE FOR EMP', pai.action_information7,
                     'PVT MED TREATMENT OR INSURANCE', pai.action_information7,
                     'VOUCHERS OR CREDIT CARDS', pai.action_information11,
                     'ASSETS TRANSFERRED', pai.action_information9,
                     'ASSETS AT EMP DISPOSAL', pai.action_information9,
                     'EXPENSES PAYMENTS', pai.action_information8,
                     'OTHER ITEMS', pai.action_information9,
                     'OTHER ITEMS NON 1A', pai.action_information9,
                     'SERVICES SUPPLIED', pai.action_information7,
                     'VANS', pai.action_information5,
                     'VANS 2002_03', NVL(pai.action_information15, 0),
                     'INT FREE AND LOW INT LOANS', pai.action_information11,
                     '0') ),
               'GROSS_AMOUNT=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'MILEAGE ALLOWANCE', NVL(pai.action_information5, 0),
                     'VOUCHERS OR CREDIT CARDS', NVL(
                                                    pai.action_information6,
                                                    0),
                     '0') ),
               'COST_TO_YOU=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'PVT MED TREATMENT OR INSURANCE', round(decode(
                                                          pai.action_information5,
                                                          0,pai.ACTION_INFORMATION7,
                                                          pai.action_information5
                                                          ),2),
/*
                     'PVT MED TREATMENT OR INSURANCE', NVL(
                                                          pai.action_information5,
                                                          0), */
                     'EXPENSES PAYMENTS', NVL(pai.action_information6, 0),
                     'OTHER ITEMS', NVL(pai.action_information7, 0),
                     'OTHER ITEMS NON 1A', NVL(pai.action_information7, 0),
                     'SERVICES SUPPLIED', round(NVL(
                                                 pai.action_information5,
                                             nvl(pai.ACTION_INFORMATION7,
                                                 0)),2),
                          /*
                     'SERVICES SUPPLIED', NVL(pai.action_information5, 0), */
                     '0') ),
               'COST_OR_MARKET_VALUE=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'ASSETS TRANSFERRED', NVL(pai.action_information7, 0),
                     '0') ),
               'ANNUAL_VALUE=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'ASSETS AT EMP DISPOSAL', NVL(
                                                  pai.action_information7,
                                                  NVL(pai.ACTION_INFORMATION9,
                                                  '0')),
                   /*
                     'ASSETS AT EMP DISPOSAL', NVL(
                                                  pai.action_information7,
                                                  '0'),*/
                     '0') ),
               'AMOUNT_OUTSTANDING_AT_5TH_APRI=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'INT FREE AND LOW INT LOANS', NVL(
                                                      pai.action_information6,
                                                      0),
                     '0') ),
               'AMOUNT_MADE_GOOD=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'MILEAGE ALLOWANCE', NVL(pai.action_information6, 0),
                     'PVT MED TREATMENT OR INSURANCE', NVL(
                                                          pai.action_information6,
                                                          0),
                     'VOUCHERS OR CREDIT CARDS', NVL(
                                                    pai.action_information7,
                                                    0),
                     'ASSETS TRANSFERRED', NVL(pai.action_information8, 0),
                     'ASSETS AT EMP DISPOSAL', NVL(
                                                  pai.action_information8,
                                                  0),
                     'EXPENSES PAYMENTS', NVL(pai.action_information7, 0),
                     'OTHER ITEMS', NVL(pai.action_information8, 0),
                     'OTHER ITEMS NON 1A', NVL(pai.action_information8, 0),
                     'SERVICES SUPPLIED', NVL(pai.action_information6, 0),
                     '0') ),
               'MAXIMUM_AMOUNT_OUTSTANDING=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'INT FREE AND LOW INT LOANS', NVL(
                                                      pai.action_information7,
                                                      0),
                     '0') ),
               'TAXABLE_PAYMENT=P',
               MAX(
                  DECODE(
                     pai.action_information_category,
                     'MILEAGE ALLOWANCE', NVL(pai.action_information7, 0),

                     'MILEAGE ALLOWANCE AND PPAYMENT', NVL(pai_resultA.action_information12,
                                                             0),
                     '0') ),
               'TAX_ON_NOTIONAL_PAYMENTS=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'PAYMENTS MADE FOR EMP', NVL(pai.action_information8, 0),
                     '0') ),
               'TOTAL_AMOUNT_OF_INTEREST_PAID=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'INT FREE AND LOW INT LOANS', NVL(
                                                      pai.action_information8,
                                                      0),
                     '0') ),
               'AMOUNT_OUTSTANDING_AT_YEAR_END=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'INT FREE AND LOW INT LOANS', NVL(
                                                      pai.action_information16,
                                                      0),
                     '0') ),
               'MILEAGE=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'FPCS_CAERS', NVL(pai.action_information10, 0),
                     'CAERS', NVL(pai.action_information9, 0),
                     0) ),
               'CAR_OR_MILEAGE_ALLOWANCE=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'FPCS_CAERS', pai.action_information11,
                     'CAERS', pai.action_information10,
                     'MARORS', NVL(pai.action_information7, 0),
                     '0') ),
               'LUMP_SUM_PAYMENTS=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'FPCS_CAERS', pai.action_information12,
                     'CAERS', pai.action_information11,
                     '0') ),
               'TAXABLE_BENEFIT=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'FPCS_CAERS', pai.action_information13,
                     'CAERS', pai.action_information12,
                     'TAXABLE EXPENSE PAYMENTS', pai.action_information10,
                     '0') ),
               'BUSINESS_MILES=P',
               SUM(
                  DECODE(
                     pai.action_information_category,
                     'TAXABLE EXPENSE PAYMENTS', pai.action_information9,
                     '0') )
          FROM pay_assignment_actions paa,
               pay_action_information pai_person,
               pay_action_information pai_comp,
               pay_action_information pai_resultA,
               pay_action_information pai
         WHERE paa.payroll_action_id =
                     pay_magtape_generic.get_parameter_value(
                        'ARCH_PAYROLL_ACTION_ID')
           AND pai_comp.action_context_id = paa.assignment_action_id
           AND pai_comp.action_information_category = 'EMEA PAYROLL INFO'
           AND pai_comp.action_context_type = 'AAP'
           AND pai_comp.action_information6 =
                  pay_magtape_generic.get_parameter_value('EMPLOYERS_REF_NO')

           AND pai_resultA.action_context_id = paa.assignment_action_id
           AND pai_resultA.action_information_category = 'GB P11D ASSIGNMENT RESULTA'
           AND pai_resultA.action_context_type = 'AAP'

           AND pai_person.action_context_id = paa.assignment_action_id
           AND pai_person.action_information_category = 'ADDRESS DETAILS'
           AND pai_person.action_context_type = 'AAP'
           AND pai_person.action_information14 = 'Employee Address'
           AND pai_person.action_information1 =
                         pay_magtape_generic.get_parameter_value('PERSON_ID')
           AND pai.action_context_id = paa.assignment_action_id
           AND pai.action_context_type = 'AAP'
           AND pai.action_information_category LIKE
                     (   pay_magtape_generic.get_parameter_value(
                            'ACTION_INFORMATION_CATG')
                    || '%')
      GROUP BY 'SCHEME_TYPE=P',
               DECODE(
                  pai.action_information_category,
                  'TAXABLE EXPENSE PAYMENTS', pai.action_information6,
                  ' '),
               'TYPE_OF_USER=P',
               DECODE(
                  pai.action_information_category,
                  'TAXABLE EXPENSE PAYMENTS', pai.action_information7,
                  ' '),
               'CLASS_OF_CAR=P',
               DECODE(
                  pai.action_information_category,
                  'TAXABLE EXPENSE PAYMENTS', pai.action_information8,
                  ' '),
               'REVENUE_RELIEF_RATE=P',
               DECODE(
                  pai.action_information_category,
                  'CAERS', pai.action_information6,
                  'FPCS_CAERS', pai.action_information6,
                  ' '),
               'MILEAGE_RATE=P',
               DECODE(
                  pai.action_information_category,
                  'CAERS', NVL(pai.action_information8, 0),
                  'FPCS_CAERS', NVL(pai.action_information9, 0),
                  ' '),
               'RECORD_IDENTIFIER=P',
               DECODE(
                  pai.action_information_category,
                  'INT FREE AND LOW INT LOANS', pai.action_information1,
                  'OTHER ITEMS', 'OTHER ITEMS',
                  'OTHER ITEMS NON 1A', 'OTHER ITEMS NON 1A',
                  ' '),
               'BENEFIT_START_DATE=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', pai.action_information3,
                  'CARS AND CAR FUEL 2001 2002', pai.action_information3,
                  'CAR AND CAR FUEL', pai.action_information3,
                  'CAR AND CAR FUEL 2003_04', pai.action_information3,
                  ' '),
               'BENEFIT_END_DATE=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', pai.action_information4,
                  'CARS AND CAR FUEL 2001 2002', pai.action_information4,
                  'CAR AND CAR FUEL', pai.action_information4,
                  'CAR AND CAR FUEL 2003_04', pai.action_information4,
                  ' '),
               'MAKE_OF_CAR=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', UPPER(pai.action_information6),
                  'CARS AND CAR FUEL 2001 2002', UPPER(
                                                    pai.action_information6),
                  'CAR AND CAR FUEL', UPPER(pai.action_information6),
                  'CAR AND CAR FUEL 2003_04', UPPER(pai.action_information6),
                  ' '),
               'MODEL=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', UPPER(pai.action_information7),
                  'CARS AND CAR FUEL 2001 2002', UPPER(
                                                    pai.action_information7),
                  'CAR AND CAR FUEL', UPPER(pai.action_information7),
                  'CAR AND CAR FUEL 2003_04', UPPER(pai.action_information7),
                  ' '),
               'DATE_FIRST_REGISTERED=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', pai.action_information8,
                  'CARS AND CAR FUEL 2001 2002', pai.action_information8,
                  'CAR AND CAR FUEL', pai.action_information8,
                  'CAR AND CAR FUEL 2003_04', nvl(pai.action_information8,0),
                  '0'),
               'LIST_PRICE=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', pai.action_information9,
                  'CARS AND CAR FUEL 2001 2002', pai.action_information9,
                  'CAR AND CAR FUEL', pai.action_information9,
                  'CAR AND CAR FUEL 2003_04', pai.action_information9,
                  ' '),
               'PRIMARY_INDICATOR=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(
                                          UPPER(pai.action_information11),
                                          'N'),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    UPPER(
                                                       pai.action_information11),
                                                    'N'),
                 'CAR AND CAR FUEL 2003_04', NVL(pai.action_information27, 'N'),
                 -- for car this hold the FREE_FUEL_REINSTATED value
                  ' '),
               'FUEL_TYPE=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(
                                          UPPER(pai.action_information13),
                                          'DIESEL'),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    UPPER(
                                                       pai.action_information13),
                                                    'DIESEL'),
                  'CAR AND CAR FUEL', NVL(
                                         UPPER(pai.action_information12),
                                         'DIESEL'),
                  'CAR AND CAR FUEL 2003_04', NVL(
                                         UPPER(pai.action_information12),
                                         'DIESEL'),
                  ' '),
               'OPTIONAL_ACCESSORIES_FITTED=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(pai.action_information17, 0),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    pai.action_information18,
                                                    0),
                  'CAR AND CAR FUEL', NVL(pai.action_information16, 0),
                  'CAR AND CAR FUEL 2003_04', NVL(pai.action_information15, 0),
                  ' '),
               'PRICE_OF_ACCESSORIES_ADDED_AFT=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(pai.action_information18, 0),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    pai.action_information19,
                                                    0),
                  'CAR AND CAR FUEL', NVL(pai.action_information17, 0),
                  'CAR AND CAR FUEL 2003_04', NVL(pai.action_information26,0),
                  -- for 03 04 this holds the DATE_FREE_FUEL_WITHDRWAN
                  ' '),
               'CAPITAL_CONTRIBUTIONS_MADE=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(pai.action_information19, 0),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    pai.action_information27,
                                                    0),
                  'CAR AND CAR FUEL', NVL(pai.action_information18, 0),
                  'CAR AND CAR FUEL 2003_04', NVL(pai.action_information16, 0),
                  ' '),
               'PRIVATE_USE_PAYMENTS=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(pai.action_information20, 0),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    pai.action_information20,
                                                    0),
                  'CAR AND CAR FUEL', NVL(pai.action_information19, 0),
                  'CAR AND CAR FUEL 2003_04', NVL(pai.action_information17, 0),
                  ' '),
               'ENGINE_CC_FOR_FUEL_CHARGE=P',
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(pai.action_information21, '9999'),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    pai.action_information21,
                                                    '9999'),
                  'CAR AND CAR FUEL', NVL(pai.action_information20, '9999'),
                  'CAR AND CAR FUEL 2003_04', NVL(pai.action_information18, '9999'),
                  ' '),
               'MILEAGE_BAND=P', --CO2_EMISSIONS for CAR AND CAR FUEL element
               DECODE(
                  pai.action_information_category,
                  'CARS AND CAR FUEL', NVL(
                                          UPPER(pai.action_information22),
                                          1),
                  'CARS AND CAR FUEL 2001 2002', NVL(
                                                    UPPER(
                                                       pai.action_information22),
                                                    1),
                  'CAR AND CAR FUEL', pai.action_information13, --CO2_EMISSIONS
                  'CAR AND CAR FUEL 2003_04', pai.action_information13, --CO2_EMISSIONS
                  ' '),
               'ASSET_TYPE=P',
               DECODE(
                  pai.action_information_category,
                  'ASSETS TRANSFERRED', pay_gb_p11d_magtape.get_description(
                                           pai.action_information6,
                                           'GB_ASSET_TYPE',
                                           pai.action_information4),
                  ' '),
               'ASSET_DESCRIPTION=P',
               DECODE(
                  pai.action_information_category,
                  'ASSETS TRANSFERRED', UPPER(pai.action_information5),
                  ' '),
               'ASSETS=P',
               DECODE(
                  pai.action_information_category,
                  'ASSETS AT EMP DISPOSAL', pay_gb_p11d_magtape.get_description(
                                               pai.action_information5,
                                               'GB_ASSETS',
                                               pai.action_information4),
                  ' '),
               'EXPENSE_TYPE=P',
               DECODE(
                  pai.action_information_category,
                  'EXPENSES PAYMENTS', pay_gb_p11d_magtape.get_description(
                                          pai.action_information5,
                                          'GB_EXPENSE_TYPE',
                                          pai.action_information4),
                  ' '),
               'OTHER_ITEMS=P',
               DECODE(
                  pai.action_information_category,
                  'OTHER ITEMS', pay_gb_p11d_magtape.get_description(
                                    pai.action_information5,
                                    'GB_OTHER_ITEMS',
                                    pai.action_information4),
                  'OTHER ITEMS NON 1A', pay_gb_p11d_magtape.get_description(
                                           pai.action_information5,
                                           'GB_OTHER_ITEMS_NON_1A',
                                           pai.action_information4),
                  ' '),
               'PAYMENTS_MADE=P',
               DECODE(
                  pai.action_information_category,
                  'PAYMENTS MADE FOR EMP', pay_gb_p11d_magtape.get_description(
                                              pai.action_information6,
                                              'GB_PAYMENTS_MADE',
                                              pai.action_information4),
                  ' '),
               'NUMBER_OF_JOINT_BORROWERS=P',
               DECODE(
                  pai.action_information_category,
                  'INT FREE AND LOW INT LOANS', NVL(
                                                   pai.action_information5,
                                                   1),
                  ' '),
               'SHARES_INDICATOR=P',
               DECODE(
                  pai.action_information_category,
                  'P11D SHARES', pai.action_information5,
                  ' '),
               'TRADING_ORGANISATION_INDICATOR=P',
               DECODE(
                  pai.action_information_category,
                  'EXPENSES PAYMENTS', NVL(
                                          UPPER(pai.action_information10),
                                          'N'),
                  ' '),
               'DATE_LOAN_MADE=P',
               DECODE(
                  pai.action_information_category,
                  'INT FREE AND LOW INT LOANS', NVL(
                                                   pai.action_information9,
                                                   ' '),
                  ' '),
               'DATE_LOAN_DISCHARGED=P',
               DECODE(
                  pai.action_information_category,
                  'INT FREE AND LOW INT LOANS', NVL(
                                                   pai.action_information10,
                                                   ' '),
                  ' '),

-- SUM FIELDS
               'CASH_EQUIVALENT=P',
               'GROSS_AMOUNT=P',
               'COST_TO_YOU=P',
               'COST_OR_MARKET_VALUE=P',
               'ANNUAL_VALUE=P',
               'AMOUNT_OUTSTANDING_AT_5TH_APRI=P',
               'AMOUNT_MADE_GOOD=P',
               'MAXIMUM_AMOUNT_OUTSTANDING=P',
               'TAXABLE_PAYMENT=P',
               'TAX_ON_NOTIONAL_PAYMENTS=P',
               'TOTAL_AMOUNT_OF_INTEREST_PAID=P',
               'AMOUNT_OUTSTANDING_AT_YEAR_END=P',
               'MILEAGE=P',
               'CAR_OR_MILEAGE_ALLOWANCE=P',
               'LUMP_SUM_PAYMENTS=P',
               'TAXABLE_BENEFIT=P',
               'BUSINESS_MILES=P';


--
-- PROCEDURE range_cursor
-- Procedure which stamps the payroll action with the PAYROLL_ID (if
-- supplied), then returns a varchar2 defining a SQL Stateent to select
-- all the people in the business group.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
   PROCEDURE range_cursor(pactid IN NUMBER, sqlstr OUT NOCOPY VARCHAR2);


--
   PROCEDURE action_creation(
      pactid      IN   NUMBER,
      stperson    IN   NUMBER,
      endperson   IN   NUMBER,
      CHUNK       IN   NUMBER);
END pay_gb_p11d_magtape;

 

/
