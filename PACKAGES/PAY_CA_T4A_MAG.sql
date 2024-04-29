--------------------------------------------------------
--  DDL for Package PAY_CA_T4A_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_T4A_MAG" AUTHID CURRENT_USER as
 /* $Header: pycat4am.pkh 120.0 2005/05/29 03:45:46 appldev noship $ */
 /*===========================================================================+
 |               Copyright (c) 1999 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_ca_t4a_mag

  Purpose
    The purpose of this package is to support the generation of
    magnetic tape T4A

    reports for CA legilsative requirements incorporating magtape resilience
    and the new end-of-year design.


    Change List:
    ------------

    Name           Date       Version Bug     Text
    -------------- ---------- ------- ------- ------------------------------
    pganguly       07-AUG-00           Initial Version
    ssattini       07-NOV-02           Added dbdrv line
    SSattini       02-DEC-02   115.2   Added 'nocopy' for out and in out
                                       parameters, GSCC compliance.
    SSattini       30-DEC-02   115.3   Added out parameter
                                       'p_legislative_parameters' to
                                       get_report_parameters procedure.
    SSattini       30-OCT-03   115.4   Added new function
                                       GET_T4A_PP_REGNO and also added
                                       4 additional columns to
                                       mag_t4a_employer cursor.  Part of
                                       bug#2696309 fix.
    mmukherj       24-AUG-04   115.5   Added SBMT_REF_ID parameter in
                                       t4a_transmitter_record cursor.
                                       This parameter will be used to print
                                       sbmt_ref_id in T4A XML Magatpe.
    ssouresr       10-NOV-04   115.6   Modified to use tables instead of views
                                       to remove problems with security groups
    =======================================================================*/



 -- 'level_cnt' will allow the cursors to select function results,
 -- whether it is a standard fuction such as to_char or a function
 -- defined in a package (with the correct pragma restriction).

 level_cnt	NUMBER;

 -- Used by Magnetic T4A (T4A format).
 -- Sets up the tax unit context for the transmitter_GRE
 --

CURSOR t4a_transmitter_record IS
Select 'TAX_UNIT_ID=C', hoi.organization_id,
       'PAYROLL_ACTION_ID=C',ppa.payroll_action_id   ,
       'SBMT_REF_ID=P',to_char(ppa.payroll_action_id)
FROM    hr_organization_information hoi,
        pay_payroll_actions PPA
WHERE
	hoi.organization_id = pay_magtape_generic.get_parameter_value('TRANSMITTER_GRE')
and     hoi.org_information_context='Fed Magnetic Reporting'
and     ppa.report_type = 'T4A'  -- T4A Archiver Report Type
and     hoi.organization_id = substr(ppa.legislative_parameters,instr(ppa.legislative_parameters,'TRANSFER_GRE=')+LENGTH('TRANSFER_GRE='))
and     to_char(ppa.effective_date,'YYYY')=pay_magtape_generic.get_parameter_value('REPORTING_YEAR')
and     to_char(ppa.effective_date,'DD-MM')= '31-12';


 --
 -- Used by Magnetic T4A (T4A format).
 --
 -- Sets up the tax unit context for each employer to be reported. sets
 -- up a parameter holding the tax unit identifier which can then be used by
 -- subsequent cursors to restrict to employees within the employer.
 --
 --

CURSOR mag_t4a_employer IS
Select distinct 'PAYROLL_ACTION_ID=C', ppa.payroll_action_id,
        'TAX_UNIT_ID=C', AA.tax_unit_id,
        'TAX_UNIT_ID=P', AA.tax_unit_id,
        'TAX_UNIT_NAME=P', fai.value,
        'TRANSFER_PACT_ID=P',to_char(ppa.payroll_action_id),
        'TRANSFER_TAX_UNIT_ID=P', to_char(AA.tax_unit_id)
From    ff_archive_items fai,
        ff_database_items fdi,
        pay_payroll_actions ppa,
        pay_assignment_actions AA
WHERE   AA.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID') --Magtape Payroll Action id
and     ppa.report_type = 'T4A'
and     to_char(ppa.effective_date,'YYYY') = pay_magtape_generic.get_parameter_value('REPORTING_YEAR')
and     to_char(ppa.effective_date,'DD-MM') = '31-12'
and     AA.tax_unit_id = substr(ppa.legislative_parameters,instr(ppa.legislative_parameters,'TRANSFER_GRE=')+LENGTH('TRANSFER_GRE='))
and     fdi.user_name = 'CAEOY_EMPLOYER_NAME'
and     ppa.payroll_action_id = fai.context1
and     fdi.user_entity_id = fai.user_entity_id
order by fai.value;

 --
 -- Used by Magnetic T4A (T4A format).
 --
 -- Sets up the assignment_action_id, assignment_id, and date_earned contexts
 -- for an employee. The date_earned context is set to be the least of the
 -- end of the period being reported and the maximum end date of the
 -- assignment. This ensures that personal information ie. name etc... is
 -- current relative to the period being reported on.
 --

CURSOR mag_t4a_employee IS
Select 'ASSIGNMENT_ACTION_ID=C',pai.locked_action_id,  -- Archiver Assignment_Action_id
        'ASSIGNMENT_ID=C',paa.assignment_id,
        'DATE_EARNED=C',fnd_date.date_to_canonical(pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id))
From
        per_all_people_f ppf,
        per_all_assignments_f paf,
        pay_action_interlocks pai,
        pay_assignment_actions paa,
        pay_payroll_actions ppa
Where   ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
AND     paa.payroll_action_id = ppa.payroll_action_id
AND     paa.tax_unit_id  = pay_magtape_generic.get_parameter_value('TAX_UNIT_ID')
AND     pai.locking_action_id = paa.assignment_action_id
AND     paf.assignment_id = paa.assignment_id
AND     ppf.person_id = paf.person_id
AND     pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id) between
        paf.effective_start_date and paf.effective_end_date
AND     pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id)
        between ppf.effective_start_date and ppf.effective_end_date
ORDER BY ppf.last_name,ppf.first_name,ppf.middle_names;

PROCEDURE get_report_parameters
(
	p_pactid    		IN	NUMBER,
	p_year_start		IN OUT NOCOPY DATE,
	p_year_end		IN OUT NOCOPY DATE,
	p_report_type		IN OUT NOCOPY VARCHAR2,
	p_business_group_id	IN OUT NOCOPY NUMBER,
	p_legislative_parameters OUT NOCOPY VARCHAR2
);


PROCEDURE range_cursor (
	p_pactid	IN	NUMBER,
	p_sqlstr OUT NOCOPY VARCHAR2
);


PROCEDURE create_assignment_act(
	p_pactid 	IN NUMBER,
	p_stperson 	IN NUMBER,
	p_endperson 	IN NUMBER,
	p_chunk 	IN NUMBER );

function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;
pragma restrict_references(get_parameter, WNDS, WNPS);

FUNCTION get_t4a_pp_regno
(
	p_pactid    		IN  NUMBER,
	p_tax_unit_id		IN  NUMBER,
	p_pp_regno1             OUT NOCOPY VARCHAR2,
	p_pp_regno2             OUT NOCOPY VARCHAR2,
	p_pp_regno3             OUT NOCOPY VARCHAR2
) return varchar2;

FUNCTION get_t4a_footnote_amounts
(
        p_assignment_action_id in number,
	p_footnote_code    		IN  VARCHAR2
) return varchar2;


function validate_gre_data ( p_trans IN VARCHAR2,
                             p_year  IN VARCHAR2) return varchar2;

FUNCTION get_arch_val( p_context_id IN NUMBER,
			 p_user_name  IN VARCHAR2) return varchar2;

END pay_ca_t4a_mag;

 

/
