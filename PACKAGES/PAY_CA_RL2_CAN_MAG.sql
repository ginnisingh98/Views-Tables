--------------------------------------------------------
--  DDL for Package PAY_CA_RL2_CAN_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_RL2_CAN_MAG" AUTHID CURRENT_USER as
 /* $Header: pycarl2cmg.pkh 120.0.12010000.1 2009/08/06 14:52:02 sapalani noship $ */
 /*
  Name
    pay_ca_rl2_can_mag

  Purpose
    The purpose of this package is to support the generation of magnetic tape RL2
    cancellation for CA legislative requirements.
  */

 -- 'level_cnt' will allow the cursors to select function results,
 -- whether it is a standard fuction such as to_char or a function
 -- defined in a package (with the correct pragma restriction).

 level_cnt	NUMBER;

 -- Used by Magnetic RL2 (RL2 format).
 --
 --

CURSOR mag_rl2_transmitter IS
  SELECT 		distinct
						'PAYROLL_ACTION_ID=P',
            ppa1.payroll_action_id
  from
            pay_payroll_actions ppa,
            pay_payroll_actions ppa1,
            pay_assignment_actions paa,
            pay_assignment_actions paa1,
            pay_action_interlocks int
  where
            ppa.payroll_action_id = paa.payroll_action_id
            and ppa.payroll_action_id = to_number(pay_magtape_generic.get_parameter_value('PAY_ACT'))
            and int.locking_action_id = paa.assignment_action_id
            and paa1.assignment_action_id = int.locked_action_id
            and ppa1.payroll_action_id = paa1.payroll_action_id
						and ppa1.report_type in ('RL2','CAEOY_RL2_AMEND_PP')
            and ppa1.action_status = 'C';


CURSOR mag_rl2_employer IS
  select
			   'PAYROLL_ACTION_ID=C',to_number(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')),
         'PAYROLL_ACTION_ID=P',to_number(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'))
  from 	  dual;


CURSOR mag_rl2_employee IS
	SELECT	'TRANSFER_ACT_ID=P',
          paa.assignment_action_id
  FROM
					per_all_people_f ppf,
			    per_all_assignments_f paf,
			    pay_action_interlocks pai,
		 	    pay_assignment_actions paa,
			    pay_payroll_actions ppa,
			    pay_assignment_actions paa_mag
  WHERE
     			ppa.payroll_action_id = to_number(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'))
					AND paa.payroll_action_id = ppa.payroll_action_id
					AND	pai.locking_action_id = paa.assignment_action_id
					AND paf.assignment_id = paa.assignment_id
					AND ppf.person_id = paf.person_id
					AND pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id)
    					between paf.effective_start_date and paf.effective_end_date
					AND	pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id)
					    between ppf.effective_start_date and ppf.effective_end_date
					AND paa_mag.payroll_action_id = to_number(pay_magtape_generic.get_parameter_value('PAY_ACT'))
					AND paa_mag.assignment_action_id = pai.locked_action_id
  ORDER BY
				  ppf.last_name,ppf.first_name,ppf.middle_names;


PROCEDURE get_report_parameters
(
	p_pactid    	    IN	          NUMBER,
	p_year_start	    IN OUT NOCOPY DATE,
	p_year_end	    IN OUT NOCOPY DATE,
	p_report_type	    IN OUT NOCOPY VARCHAR2,
	p_business_group_id IN OUT NOCOPY NUMBER,
        p_legislative_param IN OUT NOCOPY VARCHAR2
);


PROCEDURE range_cursor (
	p_pactid	IN	   NUMBER,
	p_sqlstr	OUT NOCOPY VARCHAR2
);


PROCEDURE create_assignment_act(
	p_pactid 	IN NUMBER,
	p_stperson 	IN NUMBER,
	p_endperson     IN NUMBER,
	p_chunk 	IN NUMBER );


FUNCTION get_parameter(name IN VARCHAR2,
                       parameter_list VARCHAR2)
RETURN VARCHAR2;

pragma restrict_references(get_parameter, WNDS, WNPS);


FUNCTION get_transmitter_item(p_business_group_id IN NUMBER,
                              p_pact_id           IN NUMBER,
                              p_archived_item     IN VARCHAR2)
RETURN VARCHAR2;


FUNCTION get_employer_item(p_business_group_id IN NUMBER,
                           p_pact_id           IN NUMBER,
                           p_archived_item     IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE xml_transmitter_record;

PROCEDURE end_of_file;

PROCEDURE xml_employee_record;

PROCEDURE xml_employer_start;

PROCEDURE xml_employer_record;

FUNCTION validate_quebec_number (p_quebec_no IN VARCHAR2,p_qin_name varchar2)
RETURN NUMBER;

CURSOR rl2_asg_actions
IS
    SELECT 'TRANSFER_ACT_ID=P',
           pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
      FROM DUAL;

FUNCTION convert_special_char( p_data IN VARCHAR2)
RETURN VARCHAR2;

END pay_ca_rl2_can_mag;

/
