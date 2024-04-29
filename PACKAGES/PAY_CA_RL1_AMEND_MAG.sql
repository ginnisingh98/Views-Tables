--------------------------------------------------------
--  DDL for Package PAY_CA_RL1_AMEND_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_RL1_AMEND_MAG" AUTHID CURRENT_USER as
 /* $Header: pycarlamd.pkh 120.0.12010000.3 2009/10/12 09:23:58 aneghosh noship $ */
 /*
  Name
    pay_ca_rl1_amend_mag

  Purpose
    The purpose of this package is to support the generation of
    amended magnetic tape RL1.

   ============================================================================*/


 -- 'level_cnt' will allow the cursors to select function results,
 -- whether it is a standard fuction such as to_char or a function
 -- defined in a package (with the correct pragma restriction).

 level_cnt	NUMBER;

 -- Used by Magnetic RL1 (RL1 format).
 --
 -- Sets up the tax unit context for the transmitter_GRE
 --
 --

CURSOR mag_rl1_amend_transmitter IS
Select 'PAYROLL_ACTION_ID=P',MAX(ppa.payroll_action_id),
       'TRANSFER_CPP_MAX=P', pcli.information_value
FROM    hr_organization_information hoi,
        pay_payroll_actions PPA,
        pay_ca_legislation_info pcli
WHERE   to_char(hoi.organization_id) = pay_magtape_generic.get_parameter_value('TRANSMITTER_PRE')
and     hoi.org_information_context='Prov Reporting Est'
and     ppa.report_type ='CAEOY_RL1_AMEND_PP'
and     to_char(hoi.organization_id) = pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',ppa.legislative_parameters)
and     to_char(ppa.effective_date,'YYYY')=pay_magtape_generic.get_parameter_value('REPORTING_YEAR')
and     to_char(ppa.effective_date,'DD-MM')= '31-12'
and     pcli.information_type = 'MAX_CPP_EARNINGS'
and     ppa.effective_date between pcli.start_date and pcli.end_date
GROUP BY
       'TRANSFER_CPP_MAX=P', pcli.information_value,
       'PAYROLL_ACTION_ID=P';



 --
 -- Used by Magnetic RL1 (RL1 format).
 --
 -- Sets up the tax unit context for each employer to be reported. sets
 -- up a parameter holding the tax unit identifier which can then be used by
 -- subsequent cursors to restrict to employees within the employer.
 --
 --
CURSOR mag_rl1_amend_employer IS
select distinct     'PAYROLL_ACTION_ID=C',MAX(ppa.payroll_action_id),
                    'PAYROLL_ACTION_ID=P',MAX(ppa.payroll_action_id)
from pay_payroll_actions ppa,
hr_organization_information hoi
WHERE   decode(hoi.org_information3,'Y',to_char(hoi.organization_id) ,hoi.org_information20) =
           pay_magtape_generic.get_parameter_value('TRANSMITTER_PRE')
and     hoi.org_information_context='Prov Reporting Est'
and     to_char(hoi.organization_id) =
           pay_ca_rl1_reg.get_parameter('PRE_ORGANIZATION_ID', ppa.legislative_parameters)
and ppa.action_status = 'C'
and  to_char(ppa.effective_date,'YYYY') = pay_magtape_generic.get_parameter_value('REPORTING_YEAR')
and  to_char(ppa.effective_date,'DD-MM') = '31-12'
and  ppa.report_type= 'CAEOY_RL1_AMEND_PP'
group by 'PAYROLL_ACTION_ID=C','PAYROLL_ACTION_ID=P';

 --
 -- Used by Magnetic RL1 (RL1 format).
 --
 -- Sets up the assignment_action_id, assignment_id, and date_earned contexts
 -- for an employee. The date_earned context is set to be the least of the
 -- end of the period being reported and the maximum end date of the
 -- assignment. This ensures that personal information ie. name etc... is
 -- current relative to the period being reported on.
 --

CURSOR mag_rl1_amend_employee IS
   SELECT
    'TRANSFER_ACT_ID=P',      paa.assignment_action_id
  FROM
    per_all_people_f ppf,
    per_all_assignments_f paf,
    pay_action_interlocks pai,
    pay_assignment_actions paa,
    pay_payroll_actions ppa,
    pay_assignment_actions paa_arch,
    pay_payroll_actions ppa_arch
  WHERE
     ppa.payroll_action_id =
      to_number(pay_magtape_generic.get_parameter_value
                        ('TRANSFER_PAYROLL_ACTION_ID')) AND
    paa.payroll_action_id = ppa.payroll_action_id AND
    pai.locking_action_id = paa.assignment_action_id AND
    paf.assignment_id = paa.assignment_id AND
    ppf.person_id = paf.person_id AND
    apps.pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id)
    between
        paf.effective_start_date and paf.effective_end_date AND
    pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id)
    between
        ppf.effective_start_date and ppf.effective_end_date AND
    paa_arch.assignment_action_id = pai.locked_action_id AND
    paa_arch.payroll_action_id=ppa_arch.payroll_action_id AND
    ppa_arch.report_type = 'CAEOY_RL1_AMEND_PP'
  ORDER BY
    ppf.last_name,ppf.first_name,ppf.middle_names;

PROCEDURE get_report_parameters
(
	p_pactid    	    IN	          NUMBER,
	p_year_start	    IN OUT NOCOPY DATE,
	p_year_end	    IN OUT NOCOPY DATE,
	p_report_type	    IN OUT NOCOPY VARCHAR2,
	p_business_group_id IN OUT NOCOPY NUMBER
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

--




--

  FUNCTION get_arch_val(p_context_id IN NUMBER,
                      p_user_name  IN VARCHAR2)
  RETURN VARCHAR2;

--
--

PROCEDURE xml_transmitter_record;

PROCEDURE end_of_file;

PROCEDURE xml_employee_record;

PROCEDURE xml_employer_start;

PROCEDURE xml_employer_record;

CURSOR rl1_amend_asg_actions
IS
    SELECT 'TRANSFER_ACT_ID=P',
           pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_ACT_ID')
      FROM DUAL;
/*************************************************/
CURSOR rl1xml_asg_actions
IS
    SELECT 'TRANSFER_ACT_ID=P',
           pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_ACT_ID')
      FROM DUAL;

cursor rl1xml_main_block is
select 'Version_Number=X' ,'Version 1.1'
from   sys.dual;

cursor rl1xml_transfer_block is
select 'TRANSFER_ACT_ID=P', assignment_action_id
from pay_assignment_actions
where payroll_action_id =
      pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');

PROCEDURE RL1XML_emplyer_data(p_assact_id IN NUMBER
                              ,p_emplyr_final1 OUT NOCOPY VARCHAR2
			      ,p_emplyr_final2 OUT NOCOPY VARCHAR2
			      ,p_emplyr_final3 OUT NOCOPY VARCHAR2
			      );

PROCEDURE xml_footnote_boxo(p_arch_assact_id IN  NUMBER
                          ,p_assgn_id       IN  NUMBER
		          ,p_footnote_boxo1 OUT NOCOPY VARCHAR2
			  ,p_footnote_boxo2 OUT NOCOPY VARCHAR2
			  ,p_footnote_boxo3 OUT NOCOPY VARCHAR2
			  ) ;

PROCEDURE xml_report_end;

PROCEDURE xml_rl1_report_start;

PROCEDURE archive_ca_deinit (p_pactid IN NUMBER);

/********************************************/

END pay_ca_rl1_amend_mag;

/
