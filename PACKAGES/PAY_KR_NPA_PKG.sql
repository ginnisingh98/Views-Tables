--------------------------------------------------------
--  DDL for Package PAY_KR_NPA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_NPA_PKG" AUTHID CURRENT_USER AS
/* $Header: pykrnpa.pkh 120.0 2005/05/29 02:09:14 appldev noship $ */
  level_cnt NUMBER;

  CURSOR csr_header
  IS
  SELECT 'REPORTED_DATE=P',
         fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('REPORTED_DATE')),
	 -- Bug 3506172
         'BUSINESS_PLACE_NAME=P',
	 pay_kr_npa_func_pkg.get_bp_list(fnd_profile.value('PER_BUSINESS_GROUP_ID'), pay_magtape_generic.get_parameter_value('BP_NP_NUMBER'))
    FROM dual ;
    -- End of 3506172


  CURSOR csr_data(p_payroll_action_id number default to_number(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')))
  IS
  SELECT 'ASSIGNMENT_ACTION_ID=C',
         to_char(paa.assignment_action_id),
         'REGISTRATION_NUMBER=P',
         pp.national_identifier
  FROM   pay_payroll_actions ppa
         ,pay_assignment_actions paa
         ,per_assignments_f ass
         ,per_people_f pp
         ,hr_organization_information hoi
         ,per_people_extra_info pei
  WHERE  ppa.payroll_action_id = p_payroll_action_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  paa.assignment_id = ass.assignment_id
    AND  ass.person_id = pp.person_id
    AND  ass.establishment_id = hoi.organization_id
    AND  hoi.org_information_context = 'KR_NP_INFORMATION'
    AND  pp.person_id = pei.person_id(+)
    AND  pei.information_type(+) = 'PER_KR_NATIONAL_PENSION_INFO'
    AND  ppa.effective_date BETWEEN ass.effective_start_date AND ass.effective_end_date
    AND  ppa.effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date
  ORDER BY hoi.org_information1,fnd_date.canonical_to_date(pei.pei_information3),pp.national_identifier;


PROCEDURE range_code(
                p_payroll_action_id     IN  NUMBER,
                p_sqlstr                OUT NOCOPY VARCHAR2);

PROCEDURE assignment_action_code(
                p_payroll_action_id     IN NUMBER,
                p_start_person_id       IN NUMBER,
                p_end_person_id         IN NUMBER,
                p_chunk_number          IN NUMBER);

PROCEDURE initialization_code(p_payroll_action_id IN NUMBER);

PROCEDURE archive_code(
                p_assignment_action_id  IN NUMBER,
                p_effective_date        IN DATE);

FUNCTION return_header(
                P_lookup_type IN VARCHAR2,
                p_lookup_code IN VARCHAR2 )
RETURN VARCHAR2;

END pay_kr_npa_pkg;


 

/
