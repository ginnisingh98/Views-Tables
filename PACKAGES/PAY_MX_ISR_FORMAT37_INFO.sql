--------------------------------------------------------
--  DDL for Package PAY_MX_ISR_FORMAT37_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_ISR_FORMAT37_INFO" AUTHID CURRENT_USER as
/* $Header: paymxformat37dt.pkh 120.1.12000000.1 2007/01/17 14:14:50 appldev noship $ */

  FUNCTION create_xml_string (p_arch_payroll_action_id NUMBER,
                              p_arch_person_id         NUMBER,
                              p_legal_employer_id      NUMBER,
                              p_year                   NUMBER,
                              p_pai_eff_date           DATE  )
  RETURN CLOB;

  CURSOR main_block  IS
        SELECT 'Version_Number=X' ,'Version 1.1'
        FROM   sys.dual;

  CURSOR Transfer_Block  IS
    SELECT 'TRANSFER_ACT_ID=P', paa.assignment_action_id
    FROM   pay_assignment_actions paa
    WHERE  paa.payroll_action_id =
         pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');


  CURSOR c_get_asg_action IS
     SELECT 'TRANSFER_ACT_ID=P',
           pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_ACT_ID')
      FROM DUAL;

  PROCEDURE get_headers ;
  PROCEDURE get_footers;
  PROCEDURE fetch_format37_xml;

  level_cnt   NUMBER :=0;

END PAY_MX_ISR_FORMAT37_INFO;

 

/
