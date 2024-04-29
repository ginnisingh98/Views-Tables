--------------------------------------------------------
--  DDL for Package PAY_MX_YREND_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_YREND_ARCH" AUTHID CURRENT_USER AS
/* $Header: paymxyrendarch.pkh 120.3.12010000.1 2008/07/27 21:51:42 appldev ship $ */
--
  PROCEDURE get_payroll_action_info(p_payroll_action_id     IN        NUMBER
                                   ,p_end_date             OUT NOCOPY DATE
--                                   ,p_start_date           OUT NOCOPY DATE
                                   ,p_business_group_id    OUT NOCOPY NUMBER
                                   ,p_legal_employer_id    OUT NOCOPY NUMBER
                                   ,p_asg_set_id           OUT NOCOPY NUMBER
                                   );

  PROCEDURE range_code(p_payroll_action_id  IN        NUMBER
                      ,p_sqlstr            OUT NOCOPY VARCHAR2);

  PROCEDURE assignment_action_code(p_payroll_action_id IN NUMBER
                                  ,p_start_person_id   IN NUMBER
                                  ,p_end_person_id     IN NUMBER
                                  ,p_chunk             IN NUMBER);

  PROCEDURE initialization_code(p_payroll_action_id IN NUMBER);

  PROCEDURE archive_code(p_archive_action_id  IN NUMBER
                        ,p_effective_date     IN DATE);

  -- Bug 4625794
  FUNCTION gre_exists (p_gre_id   NUMBER) RETURN NUMBER;

  PROCEDURE load_gre(p_business_group_id NUMBER,
                     p_le_id             NUMBER,
                     p_effective_date    DATE);
--
--  FUNCTION get_arch_user_entity(p_archive_item  IN VARCHAR2)
--  RETURN NUMBER;

  TYPE number_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_gre_tab             number_tab;

  g_fiscal_year         VARCHAR2(4);
  g_ER_legal_name       hr_organization_information.org_information1%TYPE;
  g_ER_RFC              hr_organization_information.org_information1%TYPE;
  g_ER_legal_rep_name   hr_organization_information.org_information1%TYPE;
  g_ER_legal_rep_RFC    per_people_f.per_information1%TYPE;
  g_ER_legal_rep_CURP   per_people_f.national_identifier%TYPE;
  g_payroll_action_id   NUMBER;

  pai_tab               pay_emp_action_arch.action_info_table ;

--
END pay_mx_yrend_arch;

/
