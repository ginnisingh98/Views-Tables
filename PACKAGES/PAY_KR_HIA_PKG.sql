--------------------------------------------------------
--  DDL for Package PAY_KR_HIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_HIA_PKG" AUTHID CURRENT_USER AS
/* $Header: pykrhia.pkh 120.0 2005/05/29 02:08:53 appldev noship $ */
  level_cnt NUMBER;
  CURSOR csr_header
  IS
  SELECT 'REPORTED_DATE=P',
         pay_magtape_generic.get_parameter_value('REPORTED_DATE'),
         'CONCATENATED_BP_NAMES=P',
         pay_kr_hia_func_pkg.get_concat_bp_names(
             pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'),
             pay_magtape_generic.get_parameter_value('BP_HI_NUMBER'),
             94)
    FROM dual;

  CURSOR csr_data(p_payroll_action_id number default to_number(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')))
  IS
  SELECT 'ASSIGNMENT_ACTION_ID=C',
         to_char(paa.assignment_action_id),
         'HI_NUMBER=P',
         pei.pei_information1
    FROM per_people_extra_info     pei,
         per_people_f              pp,
         per_assignments_f         pa,
         pay_assignment_actions    paa,
         pay_payroll_actions       ppa,
         per_periods_of_service    pds
   WHERE ppa.payroll_action_id   = p_payroll_action_id
     AND paa.payroll_action_id   = ppa.payroll_action_id
     AND pa.assignment_id        = paa.assignment_id
     AND pp.person_id            = pa.person_id
     AND pds.person_id           = pa.person_id
     AND NVL(pds.actual_termination_date,ppa.effective_date+1) > ppa.effective_date       -- Bug 3472653
     AND pds.date_start         <= ppa.effective_date                                     -- Bug 3472653
     AND ppa.effective_date BETWEEN pa.effective_start_date AND pa.effective_end_date     -- Bug 3472653
     AND ppa.effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date
     AND pei.person_id(+)        = pp.person_id
     AND pei.information_type(+) = 'PER_KR_HEALTH_INSURANCE_INFO'
     ORDER BY to_number(pei.pei_information1);
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
FUNCTION SUBMIT_REPORT
         RETURN NUMBER;
END pay_kr_hia_pkg;

 

/
