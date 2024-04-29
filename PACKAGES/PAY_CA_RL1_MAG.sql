--------------------------------------------------------
--  DDL for Package PAY_CA_RL1_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_RL1_MAG" AUTHID CURRENT_USER as
 /* $Header: pycarlmg.pkh 120.6.12010000.2 2009/09/02 16:44:01 sapalani ship $ */
 /*
  Name
    pay_ca_rl1_mag

  Purpose
    The purpose of this package is to support the generation of magnetic tape
    RL1 reports for CA legislative requirements incorporating magtape
    resilience and the new end-of-year design.

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
   04-Aug-2000  VPandya      115.0	 Date created.

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

CURSOR mag_rl1_transmitter IS
Select 'PAYROLL_ACTION_ID=P',ppa.payroll_action_id,
       'TRANSFER_CPP_MAX=P', pcli.information_value
FROM    hr_organization_information hoi,
        pay_payroll_actions PPA,
        pay_ca_legislation_info pcli
WHERE   to_char(hoi.organization_id) = pay_magtape_generic.get_parameter_value('TRANSMITTER_PRE')
and     hoi.org_information_context='Prov Reporting Est'
and     ppa.report_type = 'RL1'  -- RL1 Archiver Report Type
and     to_char(hoi.organization_id) = substr(ppa.legislative_parameters,instr(ppa.legislative_parameters,'PRE_ORGANIZATION_ID=')+LENGTH('PRE_ORGANIZATION_ID='))
and     to_char(ppa.effective_date,'YYYY')=pay_magtape_generic.get_parameter_value('REPORTING_YEAR')
and     to_char(ppa.effective_date,'DD-MM')= '31-12'
and     pcli.information_type = 'MAX_CPP_EARNINGS'
and     ppa.effective_date between pcli.start_date and pcli.end_date;

 --
 -- Used by Magnetic RL1 (RL1 format).
 --
 -- Sets up the tax unit context for each employer to be reported. sets
 -- up a parameter holding the tax unit identifier which can then be used by
 -- subsequent cursors to restrict to employees within the employer.
 --
 --
CURSOR mag_rl1_employer IS
select distinct 'PAYROLL_ACTION_ID=C',ppa.payroll_action_id,
                'PAYROLL_ACTION_ID=P',ppa.payroll_action_id
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
and  ppa.report_type = 'RL1';

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
   SELECT
    'TRANSFER_ACT_ID=P',      paa.assignment_action_id
  FROM
    per_all_people_f ppf,
    per_all_assignments_f paf,
    pay_action_interlocks pai,
    pay_assignment_actions paa,
    pay_payroll_actions ppa,
    pay_assignment_actions paa_arch
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
    paa_arch.payroll_action_id =
     to_number(pay_magtape_generic.get_parameter_value
                            ('PAYROLL_ACTION_ID')) AND
    paa_arch.assignment_action_id = pai.locked_action_id
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

  FUNCTION get_parameter(name in varchar2,
                       parameter_list varchar2)
  RETURN varchar2;

--
--
pragma restrict_references(get_parameter, WNDS, WNPS);



  FUNCTION validate_quebec_number(p_quebec_no IN VARCHAR2,
                                  p_qin_name varchar2)
  RETURN NUMBER;

--
--

  FUNCTION get_arch_val(p_context_id IN NUMBER,
                      p_user_name  IN VARCHAR2)
  RETURN VARCHAR2;

--
--

  FUNCTION convert_special_char(p_data IN VARCHAR2)
  RETURN VARCHAR2;

--
--
PROCEDURE xml_transmitter_record;

PROCEDURE end_of_file;

PROCEDURE xml_employee_record;

PROCEDURE xml_employer_start;

PROCEDURE XML_EMPLOYER_RECORD;

CURSOR rl1_asg_actions
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

END pay_ca_rl1_mag;

/
