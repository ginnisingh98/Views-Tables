--------------------------------------------------------
--  DDL for Package Body PAY_NO_ADVANCE_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_ADVANCE_PAY" as
/* $Header: pynoapay.pkb 120.0.12000000.1 2007/07/13 11:35:33 nmuthusa noship $ */

   g_package  CONSTANT VARCHAR2(33) := 'pay_no_advance_pay.';
   --

   FUNCTION adv_payment_skip_rule(p_element_entry_id NUMBER,
                                  p_date_earned DATE,
                                  p_payroll_action_id NUMBER
                                  ) RETURN VARCHAR2
   IS
      --
      CURSOR csr_pact_effective_date IS
      SELECT effective_date
      FROM pay_payroll_actions
      WHERE payroll_action_id = p_payroll_action_id;
      --
      CURSOR csr_creator_type(p_effective_date DATE) IS
      SELECT creator_type
      FROM pay_element_entries_f peef
      WHERE peef.element_entry_id = p_element_entry_id
      AND   p_effective_date BETWEEN peef.effective_start_date
                             AND     peef.effective_end_date;
      --
      l_skip              VARCHAR2(10);
      l_creator_type      VARCHAR2(10);
      l_effective_date    DATE;
      --
   BEGIN
      l_skip := 'N';
      IF p_date_earned IS NULL THEN
         OPEN csr_pact_effective_date;
           FETCH csr_pact_effective_date INTO l_effective_date;
         CLOSE csr_pact_effective_date;
      ELSE
         l_effective_date := p_date_earned;
      END IF;
      OPEN csr_creator_type(l_effective_date);
         FETCH csr_creator_type INTO l_creator_type;
      CLOSE csr_creator_type;
      IF ( (pay_advance_pay_ele_pkg.g_adv_pay_process = 'W' AND
            l_creator_type = 'AD') OR
           ( (pay_advance_pay_ele_pkg.g_adv_pay_process <> 'W' OR
              pay_advance_pay_ele_pkg.g_adv_pay_process IS NULL) AND
             (l_creator_type NOT IN ('AD', 'AE') )
           )
         )
      THEN
         l_skip := 'Y';
      END IF;

      RETURN l_skip;

   END adv_payment_skip_rule;

END PAY_NO_ADVANCE_PAY;

/
