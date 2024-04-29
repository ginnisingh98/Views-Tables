--------------------------------------------------------
--  DDL for Package PAY_CA_T4_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_T4_MAG" AUTHID CURRENT_USER AS
 /* $Header: pycat4mg.pkh 120.2.12010000.3 2009/02/18 13:22:48 sapalani ship $ */

 /* 'level_cnt' will allow the cursors to select function results,
     whether it is a standard fuction such as to_char or a function
     defined in a package (with the correct pragma restriction).
 */

 level_cnt	NUMBER;

 /* Used by T4 Magnetic Media

    Sets up the tax unit context and payroll action context for the
    transmitter_GRE
 */


CURSOR mag_t4_transmitter IS
Select 'TAX_UNIT_ID=C', hoi.organization_id,
       'PAYROLL_ACTION_ID=C',ppa.payroll_action_id,
       'TRANSFER_CPP_MAX=P', pcli.information_value,
       'TRANSFER_EI_MAX=P', pcli1.information_value,
       'TRANSFER_PPIP_MAX=P', pcli2.information_value,
       'SUBMISSION_REF_ID=P',ppa.payroll_action_id,
       'ORG_ID=P',hoi.organization_id,
       'T4_YEAR=P',to_char(ppa.effective_date,'YYYY')
FROM    hr_organization_information hoi,
        pay_payroll_actions PPA,
        pay_ca_legislation_info pcli,
        pay_ca_legislation_info pcli1,
        pay_ca_legislation_info pcli2
WHERE   hoi.organization_id = pay_magtape_generic.get_parameter_value('TRANSMITTER_GRE')
and     hoi.org_information_context='Fed Magnetic Reporting'
and     ppa.report_type = 'T4'  -- T4 Archiver Report Type
and     hoi.organization_id = substr(ppa.legislative_parameters,instr(ppa.legislative_parameters,'TRANSFER_GRE=')+LENGTH('TRANSFER_GRE='))
and     to_char(ppa.effective_date,'YYYY')=pay_magtape_generic.get_parameter_value('REPORTING_YEAR')
and     to_char(ppa.effective_date,'DD-MM')= '31-12'
and     pcli.information_type = 'MAX_CPP_EARNINGS'
and     ppa.effective_date between pcli.start_date and pcli.end_date
and     pcli.jurisdiction_code is null
and     pcli1.information_type = 'MAX_EI_EARNINGS'
and     pcli1.jurisdiction_code is null
and     ppa.effective_date between pcli1.start_date and pcli1.end_date
and     pcli2.information_type = 'MAX_PPIP_EARNINGS'
and     pcli2.jurisdiction_code is null
and     ppa.effective_date between pcli2.start_date and pcli2.end_date;




 /* Used by Magnetic T4 (T4 format).

    Sets up the tax unit context for each employer to be reported. sets
    up a parameter holding the tax unit identifier which can then be used by
    subsequent cursors to restrict to employees within the employer.
 */


CURSOR mag_t4_employer IS
Select distinct 'PAYROLL_ACTION_ID=C', ppa.payroll_action_id,
        'TAX_UNIT_ID=C', AA.tax_unit_id,
        'TAX_UNIT_ID=P', AA.tax_unit_id,
        'TAX_UNIT_NAME=P', fai.value,
        'TRANSFER_EI_ER_RATE=P', pcli2.information_value
From    ff_archive_items fai,
        ff_database_items fdi,
        pay_payroll_actions ppa,
        pay_assignment_actions AA,
        pay_ca_legislation_info pcli2
WHERE   AA.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID') --Magtape Payroll Action id
and     ppa.report_type = 'T4'
and     to_char(ppa.effective_date,'YYYY') = pay_magtape_generic.get_parameter_value('REPORTING_YEAR')
and     to_char(ppa.effective_date,'DD-MM') = '31-12'
and     AA.tax_unit_id = substr(ppa.legislative_parameters,instr(ppa.legislative_parameters,'TRANSFER_GRE=')+LENGTH('TRANSFER_GRE='))
and     fdi.user_name = 'CAEOY_EMPLOYER_NAME'
and     ppa.payroll_action_id = fai.context1
and     fdi.user_entity_id = fai.user_entity_id
and     pcli2.information_type = 'EI_ER_RATE'
and     pcli2.jurisdiction_code is null
and     ppa.effective_date between pcli2.start_date and pcli2.end_date
order by fai.value;


 /*  Used by Magnetic T4 (T4 format).

    Sets up the assignment_action_id, assignment_id, and date_earned contexts
    for an employee. The date_earned context is set to be the least of the
    end of the period being reported and the maximum end date of the
    assignment. This ensures that personal information ie. name etc... is
    current relative to the period being reported on.
 */

CURSOR mag_t4_employee IS
Select 'ASSIGNMENT_ACTION_ID=C',paa.assignment_action_id,  -- Archiver Assignment_Action_id
        'ASSIGNMENT_ID=C',paa.assignment_id,
        'DATE_EARNED=C',fnd_date.date_to_canonical(pay_magtape_generic.date_earned(ppa_mag.effective_date,paa.assignment_id)),
        'JURISDICTION_CODE=C', fai.value,
        'TRANSFER_JURISDICTION_CODE=P', fai.value
From    ff_archive_items fai,
        ff_database_items fdi,
        per_all_people_f ppf,
        pay_assignment_actions paa,
        pay_payroll_actions ppa,
        pay_payroll_actions ppa_mag
where   ppa_mag.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and     ppa.report_type = 'T4'
and     ppa.report_qualifier = 'CAEOY'
and     ppa.report_category = 'CAEOY'
and     ppa.effective_date = ppa_mag.effective_date
and     paa.payroll_action_id = ppa.payroll_action_id
and     paa.action_status = 'C'
AND     paa.tax_unit_id  = pay_magtape_generic.get_parameter_value('TAX_UNIT_ID')
AND     fai.context1 = paa.assignment_action_id
AND     fdi.user_entity_id = fai.user_entity_id
AND     fdi.user_name = 'CAEOY_PROVINCE_OF_EMPLOYMENT'
AND     ppf.person_id = to_number(paa.serial_number)
AND     pay_magtape_generic.date_earned(ppa_mag.effective_date,paa.assignment_id)
        between ppf.effective_start_date and ppf.effective_end_date
ORDER BY ppf.last_name,ppf.first_name,ppf.middle_names;


PROCEDURE get_report_parameters
(
	p_pactid    		IN	NUMBER,
	p_year_start		IN OUT NOCOPY  DATE,
	p_year_end		IN OUT NOCOPY  DATE,
	p_report_type		IN OUT NOCOPY  VARCHAR2,
	p_business_group_id	IN OUT NOCOPY  NUMBER,
        p_legislative_parameters   OUT NOCOPY VARCHAR2
);


PROCEDURE range_cursor (
	p_pactid	IN	NUMBER,
	p_sqlstr	OUT NOCOPY  VARCHAR2
);


PROCEDURE create_assignment_act(
	p_pactid 	IN NUMBER,
	p_stperson 	IN NUMBER,
	p_endperson IN NUMBER,
	p_chunk 	IN NUMBER );

FUNCTION get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;
pragma restrict_references(get_parameter, WNDS, WNPS);

FUNCTION get_dbitem_value(p_asg_act_id in number,
                          p_dbitem_name in varchar2,
                          p_jurisdiction varchar2 default null) return varchar2;

FUNCTION convert_2_xml(p_data          IN VARCHAR2,
                       p_tag           IN VARCHAR2,
                       p_datatype      IN CHAR DEFAULT 'T',
                       p_format        IN VARCHAR2 DEFAULT NULL,
                       p_null_allowed  IN VARCHAR2 DEFAULT 'N')
return VARCHAR2;


FUNCTION validate_gre_data( p_trans in varchar2,
                            p_year in varchar2)
return  varchar2;

FUNCTION get_arch_val( p_context_id IN NUMBER,
		       p_user_name  IN VARCHAR2)
return varchar2;

FUNCTION convert_t4_oth_info_amt(p_assignment_action_id IN Number,
                            p_payroll_action_id         IN Number,
                            p_jusrisdiction             IN varchar2,
                            p_tax_unit_id               IN Number,
                            p_fail                      IN char,
                            p_oth_rep1                  OUT nocopy varchar2,
                            p_oth_rep2                  OUT nocopy varchar2,
                            p_oth_rep3                  OUT nocopy varchar2,
                            p_write_f31                 OUT nocopy varchar2,
                            p_transfer_other_info1_str1 OUT nocopy varchar2,
                            p_transfer_other_info1_str2 OUT nocopy varchar2,
                            p_transfer_other_info1_str3 OUT nocopy varchar2,
                            p_transfer_other_info2_str1 OUT nocopy varchar2,
                            p_transfer_other_info2_str2 OUT nocopy varchar2,
                            p_transfer_other_info2_str3 OUT nocopy varchar2,
                            p_transfer_other_info3_str1 OUT nocopy varchar2,
                            p_transfer_other_info3_str2 OUT nocopy varchar2,
                            p_transfer_other_info3_str3 OUT nocopy varchar2,
                            p_transfer_other_info4_str1 OUT nocopy varchar2,
                            p_transfer_other_info4_str2 OUT nocopy varchar2,
                            p_transfer_other_info4_str3 OUT nocopy varchar2,
                            p_transfer_oth1_rep1        OUT nocopy varchar2,
                            p_transfer_oth1_rep2        OUT nocopy varchar2,
                            p_transfer_oth1_rep3        OUT nocopy varchar2,
                            p_transfer_oth2_rep2        OUT nocopy varchar2,
                            p_transfer_oth2_rep3        OUT nocopy varchar2,
                            p_transfer_oth3_rep2        OUT nocopy varchar2,
                            p_transfer_oth3_rep3        OUT nocopy varchar2,
                            p_transfer_oth4_rep3        OUT nocopy varchar2,
                            p_cnt                       OUT nocopy Number)
return varchar2;

END pay_ca_t4_mag;

/
