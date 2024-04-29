--------------------------------------------------------
--  DDL for Package PAY_CA_RL2_AMEND_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_RL2_AMEND_MAG" AUTHID CURRENT_USER as
 /* $Header: pycarl2amd.pkh 120.0.12010000.3 2009/10/12 10:09:43 aneghosh noship $ */
 /*
  Name
    pay_ca_rl2_amend_mag

  Purpose
    The purpose of this package is to support the generation of
    amended magnetic tape RL2.

  History
   16-JAN-2007  ssmukher     115.1            	 Date created.
   16-Mar-2007  ssmukher     115.3     5934191   Modified the
                                                 employee cursor.
   14-Jul-2009  aneghosh     115.4     8316787   Removed function convert_special_char.
   08-Oct-2009  aneghosh     115.5     8932598   Modified CURSOR mag_amend_rl2_employee
                                                 to prevent duplicate employee records.
   ============================================================================*/


 -- 'level_cnt' will allow the cursors to select function results,
 -- whether it is a standard fuction such as to_char or a function
 -- defined in a package (with the correct pragma restriction).

 level_cnt	NUMBER;


CURSOR mag_amend_rl2_transmitter IS
SELECT 'BUSINESS_GROUP_ID=C',ppa.business_group_id,
       'PAYROLL_ACTION_ID=P',MAX(ppa.payroll_action_id)
FROM    hr_organization_information hoi,
        pay_payroll_actions ppa
WHERE   to_char(hoi.organization_id) = pay_magtape_generic.get_parameter_value('TRANSMITTER_PRE')
AND     hoi.org_information_context='Prov Reporting Est'
AND     ppa.report_type = 'CAEOY_RL2_AMEND_PP'  -- RL2 Amendment Archiver Report Type
AND     to_char(hoi.organization_id) = pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',ppa.legislative_parameters)
AND     to_char(ppa.effective_date,'YYYY')=pay_magtape_generic.get_parameter_value('REPORTING_YEAR')
AND     to_char(ppa.effective_date,'DD-MM')= '31-12'
GROUP BY
       'BUSINESS_GROUP_ID=C',ppa.business_group_id,
       'PAYROLL_ACTION_ID=P';

 --
 -- Used by Amended Magnetic RL2 (RL2 format).
 --
 -- Sets up the tax unit context for each employer to be reported. sets
 -- up a parameter holding the tax unit identifier which can then be used by
 -- subsequent cursors to restrict to employees within the employer.
 --
 --
CURSOR mag_amend_rl2_employer IS
SELECT DISTINCT
      'BUSINESS_GROUP_ID=C',ppa.business_group_id,
      'PAYROLL_ACTION_ID=C',MAX(ppa.payroll_action_id),
      'PAYROLL_ACTION_ID=P',MAX(ppa.payroll_action_id)
FROM pay_payroll_actions ppa,
     hr_organization_information hoi
WHERE decode(hoi.org_information3,'Y',to_char(hoi.organization_id) ,hoi.org_information20) =
           pay_magtape_generic.get_parameter_value('TRANSMITTER_PRE')
AND  hoi.org_information_context='Prov Reporting Est'
AND  to_char(hoi.organization_id) = pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',ppa.legislative_parameters)
AND  ppa.action_status = 'C'
AND  to_char(ppa.effective_date,'YYYY') = pay_magtape_generic.get_parameter_value('REPORTING_YEAR')
AND  to_char(ppa.effective_date,'DD-MM') = '31-12'
AND  ppa.report_type = 'CAEOY_RL2_AMEND_PP'
GROUP BY
      'BUSINESS_GROUP_ID=C',ppa.business_group_id,
      'PAYROLL_ACTION_ID=C',
      'PAYROLL_ACTION_ID=P';

 --
 -- Used by Amended Magnetic RL2 (RL2 format).
 --
 -- Sets up the assignment_action_id, assignment_id, and date_earned contexts
 -- for an employee. The date_earned context is set to be the least of the
 -- end of the period being reported and the maximum end date of the
 -- assignment. This ensures that personal information ie. name etc... is
 -- current relative to the period being reported on.
 --

CURSOR mag_amend_rl2_employee IS
SELECT
       'TRANSFER_ACT_ID=P',paa.assignment_action_id
FROM    pay_action_information pin,
        per_all_people_f ppf,
        per_all_assignments_f paf,
        pay_action_interlocks pai,
        pay_assignment_actions paa,
        pay_payroll_actions ppa,
        pay_assignment_actions paa_arch,
        pay_payroll_actions ppa_arch
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
AND     paa_arch.payroll_action_id=ppa_arch.payroll_action_id
AND     ppa_arch.report_type = 'CAEOY_RL2_AMEND_PP'
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


PROCEDURE end_of_file;

CURSOR rl2_amend_asg_actions
IS
    SELECT 'TRANSFER_ACT_ID=P',
           pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_ACT_ID')
      FROM DUAL;

PROCEDURE xml_employee_record;

PROCEDURE xml_employer_start;

PROCEDURE xml_employer_record;

PROCEDURE xml_transmitter_record;

END pay_ca_rl2_amend_mag;


/
