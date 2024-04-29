--------------------------------------------------------
--  DDL for Package PAY_CA_RL1_CAN_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_RL1_CAN_MAG" AUTHID CURRENT_USER as
 /* $Header: pycarlcmg.pkh 120.0.12010000.1 2009/08/06 14:51:20 sapalani noship $ */

 -- 'level_cnt' will allow the cursors to select function results,
 -- whether it is a standard fuction such as to_char or a function
 -- defined in a package (with the correct pragma restriction).

 level_cnt	NUMBER;

 -- Used by Magnetic RL1 (RL1 format).
 --
 -- Sets up the tax unit context for the transmitter_GRE
 --

 --g_pre_id number;

CURSOR mag_rl1_transmitter IS
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
						and ppa1.report_type in ('RL1','CAEOY_RL1_AMEND_PP')
            and ppa1.action_status = 'C';

 --
 -- Used by Magnetic RL1 (RL1 format).
 --
 -- Sets up the tax unit context for each employer to be reported. sets
 -- up a parameter holding the tax unit identifier which can then be used by
 -- subsequent cursors to restrict to employees within the employer.
 --

CURSOR mag_rl1_employer IS
  select
			   'PAYROLL_ACTION_ID=C',to_number(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')),
         'PAYROLL_ACTION_ID=P',to_number(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'))
  from 	  dual;


 --
 -- Used by Magnetic RL1 (RL1 format).
 --
 -- Sets up the assignment_action_id, assignment_id, and date_earned contexts
 -- for an employee. The date_earned context is set to be the least of the
 -- end of the period being reported and the maximum end date of the
 -- assignment. This ensures that personal information ie. name etc... is
 -- current relative to the period being reported on.
 --

CURSOR mag_rl1_employee IS
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
	p_pactid    	    IN NUMBER,
	p_year_start	    IN OUT NOCOPY DATE,
	p_year_end	      IN OUT NOCOPY DATE,
	p_report_type	    IN OUT NOCOPY VARCHAR2,
	p_business_group_id IN OUT NOCOPY NUMBER,
	p_legislative_parameters IN OUT NOCOPY VARCHAR2
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

FUNCTION get_parameter(name in varchar2,
                       parameter_list varchar2)
RETURN varchar2;

  pragma restrict_references(get_parameter, WNDS, WNPS);



  FUNCTION validate_quebec_number(p_quebec_no IN VARCHAR2,
                                  p_qin_name varchar2)
  RETURN NUMBER;


  FUNCTION get_arch_val(p_context_id IN NUMBER,
                      p_user_name  IN VARCHAR2)
  RETURN VARCHAR2;


PROCEDURE xml_transmitter_record;

PROCEDURE end_of_file;

PROCEDURE xml_employee_record;

PROCEDURE xml_employer_start;

PROCEDURE XML_EMPLOYER_RECORD;

CURSOR rl1_asg_actions
IS
    SELECT 'TRANSFER_ACT_ID=P',pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
    FROM DUAL;

END pay_ca_rl1_can_mag;

/
