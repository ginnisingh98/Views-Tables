--------------------------------------------------------
--  DDL for Package PAY_CA_RL2_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_RL2_MAG" AUTHID CURRENT_USER as
 /* $Header: pycarl2mg.pkh 120.8.12010000.2 2009/05/08 11:08:53 sapalani ship $ */
 /*
  Name
    pay_ca_rl2_mag

  Purpose
    The purpose of this package is to support the generation of magnetic tape RL2


    reports for CA legislative requirements incorporating magtape resilience
	and the new end-of-year design.

  Notes
    The generation of each magnetic tape report is a two stage process i.e.
    1. Check if the year end pre-processor has been run for all the GREs
	   and the assignments. If not, then error out without processing further.
   2. Create a payroll action for the report. Identify all the assignments
	   to be reported and record an assignment action against the payroll action
	   for each one of them.
    3. Run the generic magnetic tape process which will
       drive off the data created in stage two. This will result in the
       production of a structured ascii file which can be transferred to
       magnetic tape and sent to the relevant authority.

  History
   23-DEC-2003  SSouresr     115.0	 Date created.

   ============================================================================*/


 -- 'level_cnt' will allow the cursors to select function results,
 -- whether it is a standard fuction such as to_char or a function
 -- defined in a package (with the correct pragma restriction).

 level_cnt	NUMBER;

 -- Used by Magnetic RL2 (RL2 format).
 --
 --

CURSOR mag_rl2_transmitter IS
SELECT 'BUSINESS_GROUP_ID=C',ppa.business_group_id,
       'PAYROLL_ACTION_ID=P',ppa.payroll_action_id
FROM    hr_organization_information hoi,
        pay_payroll_actions ppa
WHERE   to_char(hoi.organization_id) = pay_magtape_generic.get_parameter_value('TRANSMITTER_PRE')
AND     hoi.org_information_context='Prov Reporting Est'
AND     ppa.report_type = 'RL2'  -- RL2 Archiver Report Type
AND     to_char(hoi.organization_id) =
        substr(ppa.legislative_parameters,
               instr(ppa.legislative_parameters,'PRE_ORGANIZATION_ID=')+LENGTH('PRE_ORGANIZATION_ID='))
AND     to_char(ppa.effective_date,'YYYY')=pay_magtape_generic.get_parameter_value('REPORTING_YEAR')
AND     to_char(ppa.effective_date,'DD-MM')= '31-12';

 --
 -- Used by Magnetic RL2 (RL2 format).
 --
 -- Sets up the tax unit context for each employer to be reported. sets
 -- up a parameter holding the tax unit identifier which can then be used by
 -- subsequent cursors to restrict to employees within the employer.
 --
 --
CURSOR mag_rl2_employer IS
SELECT DISTINCT
      'BUSINESS_GROUP_ID=C',ppa.business_group_id,
      'PAYROLL_ACTION_ID=C',ppa.payroll_action_id,
      'PAYROLL_ACTION_ID=P',ppa.payroll_action_id
FROM pay_payroll_actions ppa,
     hr_organization_information hoi
WHERE decode(hoi.org_information3,'Y',to_char(hoi.organization_id) ,hoi.org_information20) =
           pay_magtape_generic.get_parameter_value('TRANSMITTER_PRE')
AND  hoi.org_information_context='Prov Reporting Est'
AND  to_char(hoi.organization_id) =
          pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID', ppa.legislative_parameters)
AND  ppa.action_status = 'C'
AND  to_char(ppa.effective_date,'YYYY') = pay_magtape_generic.get_parameter_value('REPORTING_YEAR')
AND  to_char(ppa.effective_date,'DD-MM') = '31-12'
AND  ppa.report_type = 'RL2';

 --
 -- Used by Magnetic RL2 (RL2 format).
 --
 -- Sets up the assignment_action_id, assignment_id, and date_earned contexts
 -- for an employee. The date_earned context is set to be the least of the
 -- end of the period being reported and the maximum end date of the
 -- assignment. This ensures that personal information ie. name etc... is
 -- current relative to the period being reported on.
 --

CURSOR mag_rl2_employee IS
SELECT
       'TRANSFER_ACT_ID=P',paa.assignment_action_id
FROM    pay_action_information pin,
        per_all_people_f ppf,
        per_all_assignments_f paf,
        pay_action_interlocks pai,
        pay_assignment_actions paa,
        pay_payroll_actions ppa,
        pay_assignment_actions paa_arch
WHERE   ppa.payroll_action_id =
         to_number( pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'))
AND     paa.payroll_action_id = ppa.payroll_action_id
AND     pai.locking_action_id = paa.assignment_action_id
AND     paf.assignment_id = paa.assignment_id
AND     ppf.person_id = paf.person_id
AND     pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id) between
        paf.effective_start_date and paf.effective_end_date
AND     pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id) between
        ppf.effective_start_date and ppf.effective_end_date
AND     pin.action_context_id = pai.locked_action_id
AND     pin.action_context_type = 'AAP'
AND     pin.action_information_category = 'CAEOY RL2 EMPLOYEE INFO'
AND     paa_arch.assignment_action_id = pai.locked_action_id
AND     paa_arch.payroll_action_id =
            to_number(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'))
AND     to_char(pin.effective_date,'YYYY') = to_char(ppa.effective_date,'YYYY')
ORDER BY ppf.last_name,ppf.first_name,ppf.middle_names;

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

FUNCTION get_employee_item(p_asg_action_id     IN NUMBER,
                           p_assignment_id     IN NUMBER,
                           p_archived_item     IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE xml_transmitter_record;

PROCEDURE end_of_file;

PROCEDURE archive_ca_deinit(p_pactid IN NUMBER);

PROCEDURE xml_employee_record;

PROCEDURE xml_employer_start;

PROCEDURE xml_employer_record;

PROCEDURE xml_report_start;

PROCEDURE xml_report_end;

FUNCTION validate_quebec_number (p_quebec_no IN VARCHAR2,p_qin_name varchar2)
RETURN NUMBER;
CURSOR rl2_asg_actions
IS
    SELECT 'TRANSFER_ACT_ID=P',
           pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_ACT_ID')
      FROM DUAL;

cursor main_block is
select 'Version_Number=X' ,'Version 1.1'
from   sys.dual;

cursor transfer_block is
select 'TRANSFER_ACT_ID=P', assignment_action_id
from pay_assignment_actions
where payroll_action_id =
      pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');

FUNCTION convert_special_char( p_data IN VARCHAR2)
RETURN VARCHAR2;

/*FUNCTION getnext_seq_num(p_curr_seq IN NUMBER)
RETURN NUMBER; */

END pay_ca_rl2_mag;

/
