--------------------------------------------------------
--  DDL for Package PAY_IE_P35_MAGTAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_P35_MAGTAPE" AUTHID CURRENT_USER AS
/* $Header: pyiep35m.pkh 120.4.12010000.3 2009/05/26 05:23:19 knadhan ship $ */

l_arc_payroll_action_id		pay_payroll_actions.payroll_action_id%TYPE;
level_cnt NUMBER;

FUNCTION  get_parameter(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2) RETURN VARCHAR2;

FUNCTION get_start_date RETURN DATE;

FUNCTION get_end_date RETURN DATE;

CURSOR CSR_P35_HEADER_FOOTER IS
  SELECT ('P35_MODE=P'), trim(pay_ie_p35.get_parameter(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'),'MODE')),
         ('END_DATE=P'), pay_ie_p35.get_parameter(ppa.payroll_action_id,'END_DATE'),
         ('EFFECTIVE_DATE=P'),to_char(ppa.effective_date,'dd-mm-yyyy'),
         ('EMPLOYER_NUMBER=P'), pact.action_information1,
         ('EMPLOYER_NAME=P'),   pact.action_information26 ,
	   ('TRADE_NAME=P'),      pact.action_information9,
         ('EMPLOYER_ADDRESS1=P'),pact.action_information5 ,
         ('EMPLOYER_ADDRESS2=P'),pact.action_information6 ,
         ('EMPLOYER_ADDRESS3=P'),pact.action_information7 ,
         ('CONTACT_NAME=P'),     pact.action_information27 ,
         ('CONTACT_NUMBER=P'),   pact.action_information28 ,
	   ('FAX_NO=P'),           pact.action_information10,
         --('WEEKS_53=P') , decode(trim(pay_ie_p35.get_parameter(ppa.payroll_action_id,'WEEKS')),'Y','1','0'),
	   ('WEEKS_53=P') , decode(trim(pay_ie_p35.get_parameter(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'),'WEEKS')),'Y','1','0'),  --8233782
         ('REQUEST_ID=P'), to_char(ppa.request_id),
	   ('SUBMISSION_TYPE=P'),pay_ie_p35.get_parameter(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'),'SUB_TYPE') /*Added for bug fix 3815830*/
  FROM   pay_payroll_actions                ppa
        ,pay_action_information             pact

  WHERE  pact.action_context_id = ppa.payroll_action_id
  AND    pact.action_information_category  = 'ADDRESS DETAILS'
  AND    pact.action_context_type          = 'PA'
  AND ppa.payroll_action_id  =
		(select max(arc_paa.payroll_action_id) from
		pay_assignment_actions mag_paa,
		pay_assignment_actions arc_paa,
		pay_action_interlocks pai
		where mag_paa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
		and pai.locking_action_id = mag_paa.assignment_action_id
		and arc_paa.assignment_action_id= pai.locked_action_id);

/* Modified the cursor for BUG 2987230 */
CURSOR CSR_P35_DETAIL IS
SELECT  ('PPSN=P')
        ,nvl(SUBSTR(pact.action_information1,1,9),' '),
        ('WORKS_NUMBER=P')
        ,nvl(SUBSTR(pact.action_information2,1,12),' '), -- for bug 5301598
        ('TOTAL_WEEKS_INSURABLE_EMPLOYMENT=P')
        ,pact.action_information3,
        ('INITIAL_CLASS=P')
        ,pact.action_information4,
        ('SECOND_CLASS=P')
        ,pact.action_information5,
        ('WEEKS_AT_SECOND_CLASS=P')
        ,pact.action_information6,
        ('THIRD_CLASS=P')
        ,pact.action_information7,
        ('WEEKS_AT_THIRD_CLASS=P')
        ,pact.action_information8,
        ('FOURTH_CLASS=P')
        ,pact.action_information9,
        ('WEEKS_AT_FOURTH_CLASS=P')
        ,pact.action_information10,
        ('FIFTH_CLASS=P')
        ,pact.action_information11,
        ('NET_TAX=P')
        ,pact.action_information12,
        ('TAX_OR_REFUND=P')
        ,pact.action_information13,
        ('EMPLOYEES_PRSI_CONT=P')
        ,pact.action_information14,
        ('TOTAL_PRSI_CONT=P')
        ,pact.action_information15,
        ('PAY=P')
        ,pact.action_information16,
        ('TAX_DEDUCTION_BASIS=P')
        ,pact.action_information17,
        ('SURNAME=P')
        ,pact.action_information18,
        ('FIRST_NAME=P')
        ,pact.action_information19,
        ('DOB=P')
        ,pact.action_information20,
        ('ADDRESS_LINE1=P')
        ,pact.action_information21,
        ('ADDRESS_LINE2=P')
        ,pact.action_information22,
        ('ADDRESS_LINE3=P')
        ,pact.action_information23,
        ('HIRE_DATE=P')
        ,pact.action_information24,
        ('TERM_DATE=P')
        ,pact.action_information25,
        ('ANNUAL_TAX_CREDIT=P')
        ,pact.action_information26,
         ('MOTHERS_NAME=P')
        ,pact.action_information27,
	   ('MEDICAL_INSURANCE=P')       -- 5867343
        ,pact1.action_information17,    -- 5867343
	('GROSS_INCOME=P')
        ,pact1.action_information18, /* knadhan */
	('INCOME_LEVY=P')
        ,pact1.action_information19

  FROM
         pay_assignment_actions  paa
        ,pay_action_information pact
	  ,pay_action_information pact1
        ,pay_action_interlocks pai
  WHERE
        paa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
        and pai.locking_action_id = paa.assignment_action_id
	  and paa.source_action_id         is null
        and pact.action_context_id             = pai.locked_action_id
        and pact.action_information_category   = 'IE P35 DETAIL'
        and pact.action_context_type           = 'AAP'
	  and pact1.action_context_id             = pact.action_context_id
        and pact1.action_information_category   = 'IE P35 ADDITIONAL DETAILS'
        and pact1.action_context_type           = 'AAP'
ORDER BY 36,38;

/*Added for bug fix 3815830*/
--FUNCTION replace_xml_symbols(p_string IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE range_code(p_payroll_action_id     IN  NUMBER,
                     p_sqlstr                OUT NOCOPY VARCHAR2);
--
PROCEDURE action_creation(pactid    IN NUMBER,
                          stperson  IN NUMBER,
                          endperson IN NUMBER,
                          chunk     IN NUMBER);

/* Function for getting Pension Details */
FUNCTION get_pension_details(emp_rbs			IN OUT NOCOPY NUMBER,
				     emp_rbs_bal			IN OUT NOCOPY NUMBER,
				     empr_rbs			IN OUT NOCOPY NUMBER,
				     empr_rbs_bal			IN OUT NOCOPY NUMBER,
				     emp_prsa			IN OUT NOCOPY NUMBER,
				     emp_prsa_bal			IN OUT NOCOPY NUMBER,
				     empr_prsa			IN OUT NOCOPY NUMBER,
				     empr_prsa_bal		IN OUT NOCOPY NUMBER,
				     emp_rac			IN OUT NOCOPY NUMBER,
				     emp_rac_bal			IN OUT NOCOPY NUMBER,
				     p_payroll_action_id      NUMBER,
				     p_taxable_benefits		IN OUT NOCOPY NUMBER) RETURN NUMBER;
/* knadhan */
FUNCTION get_car_park_details(     emp_parking			IN OUT NOCOPY NUMBER,
				     emp_parking_bal		 IN OUT NOCOPY NUMBER,
				     p_payroll_action_id      NUMBER,
				     empr_income_band IN OUT NOCOPY NUMBER) RETURN NUMBER;


FUNCTION  raise_warning(l_flag	varchar2) return number;

-- for bug 6275544
FUNCTION test_XML(P_STRING VARCHAR2) RETURN VARCHAR2;

END pay_ie_p35_magtape;

/
