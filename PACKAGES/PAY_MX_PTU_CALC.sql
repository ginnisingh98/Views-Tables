--------------------------------------------------------
--  DDL for Package PAY_MX_PTU_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_PTU_CALC" AUTHID CURRENT_USER AS
/* $Header: paymxprofitshare.pkh 120.3.12010000.1 2008/07/27 21:51:01 appldev ship $ */
--
  PROCEDURE get_payroll_action_info(p_payroll_action_id     IN        NUMBER
                                   ,p_start_date           OUT NOCOPY DATE
                                   ,p_effective_date       OUT NOCOPY DATE
                                   ,p_business_group_id    OUT NOCOPY NUMBER
                                   ,p_legal_employer_id    OUT NOCOPY NUMBER
                                   ,p_asg_set_id           OUT NOCOPY NUMBER
--                                   ,p_incl_temp_EEs        OUT NOCOPY VARCHAR2
--                                   ,p_min_days_worked      OUT NOCOPY NUMBER
                                   ,p_batch_name           OUT NOCOPY VARCHAR2
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

  PROCEDURE deinit_code(p_payroll_action_id  IN NUMBER);

    -- Get latest YTD aaid for the person
    -- Date constraint relaxed since terminated assignments are also included.
    CURSOR c_get_ytd_aaid(cp_start_date    DATE,
                          cp_end_date      DATE,
                          cp_person_id     NUMBER)
    IS
    SELECT paa.assignment_action_id
    FROM   pay_assignment_actions     paa,
           pay_payroll_actions        ppa,
           per_assignments_f          paf,
           pay_action_classifications pac
    WHERE  paf.person_id            = cp_person_id
    AND    paa.assignment_id        = paf.assignment_id
    AND    paa.payroll_action_id    = ppa.payroll_action_id
    AND    ppa.action_type          = pac.action_type
    AND    pac.classification_name  = 'SEQUENCED'
    AND    paa.action_status        = 'C'
    AND    ppa.effective_date BETWEEN cp_start_date
                                  AND cp_end_date
  ORDER BY paa.action_sequence DESC;

  g_ptu_calc_method         FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE;
  g_worked_days_def_bal_id  NUMBER;
  g_elig_comp_def_bal_id    NUMBER;
  g_factor_A                NUMBER;
  g_factor_D                NUMBER;
  g_factor_F                NUMBER;
  g_factor_G                NUMBER;
  g_factor_H                NUMBER;
  g_factor_I                NUMBER;
  g_batch_id                NUMBER;
  g_PTU_ele_type_id         NUMBER;

  gd_start_date             DATE;
  gd_end_date               DATE;
  gn_legal_employer_id      HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE;

  TYPE number_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_ytd_aaid_tab            number_tab;


--
END pay_mx_PTU_calc;

/
