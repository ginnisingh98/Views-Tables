--------------------------------------------------------
--  DDL for Package Body PAY_MX_PAYROLL_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_PAYROLL_ARCH" AS
/* $Header: paymxpaysliparch.pkb 120.2 2006/08/21 20:58:51 vpandya noship $ */
--

  /******************************************************************************
  ** Package Local Variables
  ******************************************************************************/
   gv_package                VARCHAR2(100);
   gn_gross_earn_def_bal_id  NUMBER        := 0;
 --  gn_payments_def_bal_id    NUMBER        := 0;
   gv_dim_asg_gre_ytd        VARCHAR2(100);
   gv_dim_asg_jd_gre_ytd     VARCHAR2(100);
   gv_ytd_balance_dimension  VARCHAR2(80);

   dbt                       DEF_BAL_TBL;
   tax_calc_tbl              DEF_BAL_TBL;

  /******************************************************************************
   Name      : get_payroll_action_info
   Purpose   : This returns the Payroll Action level
               information for Payslip Archiver.
   Arguments : p_payroll_action_id - Payroll_Action_id of archiver
               p_start_date        - Start date of Archiver
               p_end_date          - End date of Archiver
               p_business_group_id - Business Group ID
               p_cons_set_id       - Consolidation Set when submitting Archiver
               p_payroll_id        - Payroll ID when submitting Archiver
  ******************************************************************************/
  PROCEDURE get_payroll_action_info(p_payroll_action_id     IN        NUMBER
                                   ,p_end_date             OUT NOCOPY DATE
                                   ,p_start_date           OUT NOCOPY DATE
                                   ,p_business_group_id    OUT NOCOPY NUMBER
                                   ,P_CONS_SET_ID          OUT NOCOPY NUMBER
                                   ,p_payroll_id           OUT NOCOPY NUMBER
                                   )
  IS
    CURSOR c_payroll_Action_info
              (cp_payroll_action_id IN NUMBER) IS
      SELECT effective_date,
             start_date,
             business_group_id,
             TO_NUMBER(SUBSTR(legislative_parameters,
                INSTR(legislative_parameters,
                         'TRANSFER_CONSOLIDATION_SET_ID=')
                + LENGTH('TRANSFER_CONSOLIDATION_SET_ID='))),
             TO_NUMBER(LTRIM(RTRIM(SUBSTR(legislative_parameters,
                INSTR(legislative_parameters,
                         'TRANSFER_PAYROLL_ID=')
                + LENGTH('TRANSFER_PAYROLL_ID='),
                (INSTR(legislative_parameters,
                         'TRANSFER_CONSOLIDATION_SET_ID=') - 1 )
              - (INSTR(legislative_parameters,
                         'TRANSFER_PAYROLL_ID=')
              + LENGTH('TRANSFER_PAYROLL_ID='))))))
        FROM pay_payroll_actions
       WHERE payroll_action_id = cp_payroll_action_id;

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_cons_set_id       NUMBER;
    ln_payroll_id        NUMBER;
    lv_procedure_name    VARCHAR2(100);

    lv_error_message     VARCHAR2(200);
    ln_step              NUMBER;

   BEGIN
       lv_procedure_name  := '.get_payroll_action_info';

       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       ln_step := 1;
       OPEN c_payroll_action_info(p_payroll_action_id);
       FETCH c_payroll_action_info INTO ld_end_date,
                                        ld_start_date,
                                        ln_business_group_id,
                                        ln_cons_set_id,
                                        ln_payroll_id;
       CLOSE c_payroll_action_info;

       hr_utility.set_location(gv_package || lv_procedure_name, 30);
       p_end_date          := ld_end_date;
       p_start_date        := ld_start_date;
       p_business_group_id := ln_business_group_id;
       p_cons_set_id       := ln_cons_set_id;
       p_payroll_id        := ln_payroll_id;
       hr_utility.set_location(gv_package || lv_procedure_name, 50);
       ln_step := 2;

  EXCEPTION
    WHEN OTHERS THEN
      lv_error_message := 'Error at step ' || ln_step || ' IN ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_payroll_action_info;

  /******************************************************************
   Name      : populate_elements
   Purpose   : This procedure archives details of a Primary Balance
   Arguments : p_xfr_action_id      - Assignment_Action_id of
                                      archiver
               p_pymt_assignment_
                          action_id - Assignment_Action_id used to
                                      retrieve Current value
               p_pymt_eff_date      - Effective date of the Payment
               p_primary_balance_id - Balance_type_ID of Pri Balance
               p_hours_balance_id   - Balance_type_ID of Hrs Balance
               p_days_balance_id    - Balance_type_ID of Days Balance
               p_reporting_name     - Reporting name of Pri Balance
               p_attribute_name     - Bal attribute of Pri Balance
               p_tax_unit_id        - Tax Unit ID context
               p_ytd_balcall_aaid   - Assignment_Action_id used to
                                      fetch the YTD value
               p_pymt_balcall_aaid  - Assignment_Action_id used to
                                      fetch the Current value
               p_jurisdiction_code  - Jurisdiction Code context
               p_legislation_code   - Legislation code
               p_sepchk_flag        - Separate Check flag
               p_action_type        - Action type of the action
                                      being archived

   Notes     :
  ******************************************************************/
  PROCEDURE populate_elements(p_xfr_action_id             IN NUMBER
                             ,p_pymt_assignment_action_id IN NUMBER
                             ,p_pymt_eff_date               IN DATE
 --                            ,p_element_type_id             IN NUMBER
                             ,p_primary_balance_id          IN NUMBER
                             ,p_hours_balance_id            IN NUMBER
                             ,p_days_balance_id             IN NUMBER
--                             ,p_processing_priority         IN NUMBER
--                             ,p_element_classification_name IN VARCHAR2
                             ,p_reporting_name              IN VARCHAR2
                             ,p_attribute_name              IN VARCHAR2
                             ,p_tax_unit_id                 IN NUMBER
                             ,p_ytd_balcall_aaid            IN NUMBER
                             ,p_pymt_balcall_aaid           IN NUMBER
                             ,p_jurisdiction_code           IN VARCHAR2
                                                            DEFAULT NULL
                             ,p_legislation_code            IN VARCHAR2
                             ,p_sepchk_flag                 IN VARCHAR2
                             ,p_action_type          IN VARCHAR2
                                                     DEFAULT NULL
                             )
  IS

    CURSOR c_non_sep_check(cp_pymt_assignment_action_id IN NUMBER) IS
      SELECT paa.assignment_action_id
        FROM pay_action_interlocks pai,
             pay_assignment_actions paa,
             pay_payroll_actions ppa
       WHERE pai.locking_action_id = cp_pymt_assignment_action_id
         AND paa.assignment_action_id = pai.locked_action_id
         AND paa.payroll_action_id = ppa.payroll_action_id
         AND ppa.action_type IN ('Q','R')
         AND ((NVL(paa.run_type_id, ppa.run_type_id) IS NULL AND
               source_action_id IS NULL) OR
              (NVL(paa.run_type_id, ppa.run_type_id) IS NOT NULL AND
               source_action_id IS NOT NULL AND
               paa.run_type_id NOT IN (gn_sepchk_run_type_id, gn_np_sepchk_run_type_id)));


    ln_current_hours           NUMBER(15,2);
    ln_current_days            NUMBER(15,2);
    ln_payments_amount         NUMBER(15,2);
    ln_ytd_hours               NUMBER(15,2);
    ln_ytd_days                NUMBER(15,2);
    ln_ytd_amount              NUMBER(17,2);

    ln_pymt_defined_balance_id NUMBER;
    ln_pymt_hours_balance_id   NUMBER;
    ln_pymt_days_balance_id    NUMBER;
    ln_ytd_defined_balance_id  NUMBER;
    ln_ytd_hours_balance_id    NUMBER;
    ln_ytd_days_balance_id     NUMBER;

    lv_rate_exists             VARCHAR2(1);
    ln_nonpayroll_balcall_aaid NUMBER;

    ln_index                   NUMBER ;
    lv_action_category         VARCHAR2(50);
    lv_procedure_name          VARCHAR2(100);
    lv_error_message           VARCHAR2(200);

    ln_step                    NUMBER;

  BEGIN
      lv_rate_exists      := 'N';
      lv_action_category  := 'AC DEDUCTIONS';
      lv_procedure_name   := '.populate_elements';

      ln_step := 1;
      hr_utility.set_location(gv_package || lv_procedure_name, 10);
      hr_utility.trace('p_pymt_assignment_action_id '
                     ||to_char(p_pymt_assignment_action_id));
      hr_utility.trace('p_pymt_eff_date '
                     ||to_char(p_pymt_eff_date));
      hr_utility.trace('p_primary_balance_id '
                     ||to_char(p_primary_balance_id));
      hr_utility.trace('p_reporting_name '
                     ||p_reporting_name);
      hr_utility.trace('p_ytd_balcall_aaid '
                     ||to_char(p_ytd_balcall_aaid));
      hr_utility.trace('p_pymt_balcall_aaid '
                     ||to_char(p_pymt_balcall_aaid));
      hr_utility.trace('p_legislation_code '
                     ||p_legislation_code);
      hr_utility.trace('p_hours_balance_id '
                     ||to_char(p_hours_balance_id));
      hr_utility.trace('p_days_balance_id '
                     ||to_char(p_days_balance_id));

      IF pay_emp_action_arch.gv_multi_leg_rule IS NULL THEN
         pay_emp_action_arch.gv_multi_leg_rule
               := pay_emp_action_arch.get_multi_legislative_rule(
                                                  p_legislation_code);
      END IF;

      ln_step := 2;
      IF p_jurisdiction_code IS NOT NULL THEN
         pay_balance_pkg.set_context('JURISDICTION_CODE', p_jurisdiction_code);
         gv_ytd_balance_dimension := gv_dim_asg_jd_gre_ytd;
      ELSE
         pay_balance_pkg.set_context('JURISDICTION_CODE', p_jurisdiction_code);
         gv_ytd_balance_dimension := gv_dim_asg_gre_ytd;
      END IF;


      ln_step := 3;
      /*********************************************************
      ** Get the defined balance_id for YTD call as it will be
      ** same for all classification types.
      *********************************************************/
      ln_ytd_defined_balance_id
                := pay_emp_action_arch.get_defined_balance_id(
                                             p_primary_balance_id,
                                             gv_ytd_balance_dimension,
                                             p_legislation_code);

      hr_utility.trace('ln_ytd_defined_balance_id = ' ||
                          ln_ytd_defined_balance_id);

      ln_step := 4;
      IF p_hours_balance_id IS NOT NULL THEN
         hr_utility.set_location(gv_package || lv_procedure_name, 20);
         ln_ytd_hours_balance_id
                := pay_emp_action_arch.get_defined_balance_id(
                                            p_hours_balance_id,
                                            gv_ytd_balance_dimension,
                                            p_legislation_code);

           hr_utility.trace('ln_ytd_hours_balance_id = ' ||
                             ln_ytd_hours_balance_id);

      END IF;

      IF p_days_balance_id IS NOT NULL THEN
         hr_utility.set_location(gv_package || lv_procedure_name, 20);
         ln_ytd_days_balance_id
                := pay_emp_action_arch.get_defined_balance_id(
                                            p_days_balance_id,
                                            gv_ytd_balance_dimension,
                                            p_legislation_code);

           hr_utility.trace('ln_ytd_days_balance_id = ' ||
                             ln_ytd_days_balance_id);

      END IF;

      ln_step := 5;
      hr_utility.set_location(gv_package || lv_procedure_name, 30);

      ln_step := 6;
      lv_rate_exists := 'N';

      IF pay_ac_action_arch.lrr_act_tab.count <> 0 THEN
         FOR i IN  pay_ac_action_arch.lrr_act_tab.first..
                   pay_ac_action_arch.lrr_act_tab.last
         LOOP
            IF ( ( pay_ac_action_arch.lrr_act_tab(i).action_context_id =
                   p_xfr_action_id ) AND
                 ( pay_ac_action_arch.lrr_act_tab(i).act_info6 =
                   p_primary_balance_id ) )
            THEN
               lv_rate_exists := 'Y';
               EXIT;
            END IF;
         END LOOP;
      END IF;

      hr_utility.trace('lv_rate_exists = ' || lv_rate_exists);

      IF lv_rate_exists = 'N' THEN
         ln_step := 7;
         hr_utility.set_location(gv_package || lv_procedure_name, 40);
         IF ln_ytd_defined_balance_id IS NOT NULL THEN
            ln_ytd_amount := NVL(pay_balance_pkg.get_value(
                                      ln_ytd_defined_balance_id,
                                      p_ytd_balcall_aaid),0);
         END IF;

         IF p_hours_balance_id IS NOT NULL THEN
            hr_utility.set_location(gv_package || lv_procedure_name, 50);
            IF ln_ytd_hours_balance_id IS NOT NULL THEN
               ln_ytd_hours := NVL(pay_balance_pkg.get_value(
                                      ln_ytd_hours_balance_id,
                                      p_ytd_balcall_aaid),0);
               hr_utility.set_location(gv_package || lv_procedure_name, 60);
            END IF;
         END IF; --Hours

         IF p_days_balance_id IS NOT NULL THEN
            hr_utility.set_location(gv_package || lv_procedure_name, 50);
            IF ln_ytd_days_balance_id IS NOT NULL THEN
               ln_ytd_days := NVL(pay_balance_pkg.get_value(
                                      ln_ytd_days_balance_id,
                                      p_ytd_balcall_aaid),0);
               hr_utility.set_location(gv_package || lv_procedure_name, 60);
            END IF;
         END IF; --Days

         ln_step := 8;
         IF p_pymt_balcall_aaid IS NOT NULL THEN
               ln_step := 10;
               IF p_action_type IN ('B','V') THEN
                  ln_pymt_defined_balance_id
                       := pay_emp_action_arch.get_defined_balance_id(
                                                 p_primary_balance_id,
                                                 '_ASG_GRE_RUN',
                                                 p_legislation_code);
               ELSE
                 IF pay_emp_action_arch.gv_multi_leg_rule = 'Y' THEN
                    ln_pymt_defined_balance_id
                       := pay_emp_action_arch.get_defined_balance_id(
                                                 p_primary_balance_id,
                                                 '_ASG_PAYMENTS',
                                                 p_legislation_code);
                 ELSE
                    ln_pymt_defined_balance_id
                       := pay_emp_action_arch.get_defined_balance_id(
                                                 p_primary_balance_id,
                                                 '_PAYMENTS',
                                                 p_legislation_code);
                 END IF;
               END IF; -- p_action_type IN ('B','V')
               /* END of addition FOR Reversals AND bal adjustments */
               hr_utility.trace('ln_pymt_defined_balance_id ' ||
                                 ln_pymt_defined_balance_id);
               IF ln_pymt_defined_balance_id IS NOT NULL THEN
                  ln_payments_amount := NVL(pay_balance_pkg.get_value(
                                               ln_pymt_defined_balance_id,
                                               p_pymt_balcall_aaid),0);
                  hr_utility.trace('ln_payments_amount = ' ||ln_payments_amount);
               END IF;

               IF p_hours_balance_id IS NOT NULL THEN
                 IF p_action_type IN ('B','V') THEN
                    ln_pymt_hours_balance_id
                          := pay_emp_action_arch.get_defined_balance_id(
                                                   p_hours_balance_id
                                                   ,'_ASG_GRE_RUN'
                                                   ,p_legislation_code);
                 ELSE
                    IF pay_emp_action_arch.gv_multi_leg_rule = 'Y' THEN
                       ln_pymt_hours_balance_id
                          := pay_emp_action_arch.get_defined_balance_id(
                                                   p_hours_balance_id
                                                   ,'_ASG_PAYMENTS'
                                                   ,p_legislation_code);
                    ELSE
                        ln_pymt_hours_balance_id
                          := pay_emp_action_arch.get_defined_balance_id(
                                                   p_hours_balance_id
                                                   ,'_PAYMENTS'
                                                   ,p_legislation_code);
                    END IF;
                 END IF; -- p_action_type IN ('B','V')

                  hr_utility.trace('ln_pymt_hours_balance_id ' ||
                                    ln_pymt_hours_balance_id);
                  IF ln_pymt_hours_balance_id IS NOT NULL THEN
                     ln_current_hours   := NVL(pay_balance_pkg.get_value(
                                                ln_pymt_hours_balance_id,
                                                p_pymt_balcall_aaid),0);
                  END IF;
                  hr_utility.set_location(gv_package || lv_procedure_name, 120);
               END IF; --Hours

               IF p_days_balance_id IS NOT NULL THEN
                 IF p_action_type IN ('B','V') THEN
                    ln_pymt_days_balance_id
                          := pay_emp_action_arch.get_defined_balance_id(
                                                   p_days_balance_id
                                                   ,'_ASG_GRE_RUN'
                                                   ,p_legislation_code);
                 ELSE
                    IF pay_emp_action_arch.gv_multi_leg_rule = 'Y' THEN
                       ln_pymt_days_balance_id
                          := pay_emp_action_arch.get_defined_balance_id(
                                                   p_days_balance_id
                                                   ,'_ASG_PAYMENTS'
                                                   ,p_legislation_code);
                    ELSE
                        ln_pymt_days_balance_id
                          := pay_emp_action_arch.get_defined_balance_id(
                                                   p_days_balance_id
                                                   ,'_PAYMENTS'
                                                   ,p_legislation_code);
                    END IF;
                 END IF; -- p_action_type in ('B','V')

                  hr_utility.trace('ln_pymt_days_balance_id ' ||
                                    ln_pymt_days_balance_id);
                  IF ln_pymt_days_balance_id IS NOT NULL THEN
                     ln_current_days   := NVL(pay_balance_pkg.get_value(
                                                ln_pymt_days_balance_id,
                                                p_pymt_balcall_aaid),0);
                  END IF;
                  hr_utility.set_location(gv_package || lv_procedure_name, 120);
               END IF; --Days

         END IF; -- p_pymt_balcall_aaid is not NULL

         ln_step := 15;
         IF NVL(ln_ytd_amount, 0) <> 0 OR NVL(ln_payments_amount, 0) <> 0 THEN
            ln_index := pay_ac_action_arch.lrr_act_tab.count;

            IF p_attribute_name IN ('Employee Earnings', 'Hourly Earnings',
                                     'Taxable Benefits') THEN

               hr_utility.set_location(gv_package || lv_procedure_name, 125);
               lv_action_category := 'AC EARNINGS';
               pay_ac_action_arch.lrr_act_tab(ln_index).act_info11
                         := fnd_number.number_to_canonical(ln_current_hours);
               pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                         := fnd_number.number_to_canonical(ln_ytd_hours);

               pay_ac_action_arch.lrr_act_tab(ln_index).act_info14
                         := fnd_number.number_to_canonical(ln_current_days);
               pay_ac_action_arch.lrr_act_tab(ln_index).act_info15
                         := fnd_number.number_to_canonical(ln_ytd_days);

            END IF;

            hr_utility.set_location(gv_package || lv_procedure_name, 130);
            /* Insert this into the plsql table if Current or YTD
               amount is not Zero */
             pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                    := lv_action_category;
             pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                   := p_jurisdiction_code;
             pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                   := p_xfr_action_id;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                   := p_primary_balance_id;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                   := fnd_number.number_to_canonical(ln_payments_amount);
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                   := fnd_number.number_to_canonical(ln_ytd_amount);
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                   := p_reporting_name;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info16
                   := p_attribute_name;

         END IF;
      END IF; -- lv_rate_exists = 'N'

      hr_utility.set_location(gv_package || lv_procedure_name, 150);
      ln_step := 20;

  EXCEPTION
     WHEN OTHERS THEN
      hr_utility.set_location(gv_package || lv_procedure_name, 200);
      lv_error_message := 'Error at step ' || ln_step ||
                          ' IN ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END populate_elements;


  /******************************************************************
   Name      : get_missing_xfr_info
   Purpose   : The procedure gets the elements which have been
               processed for a given Payment Action. This procedure
               is only called if the archiver has not been run for
               all pre-payment actions.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE get_missing_xfr_info(p_xfr_action_id        IN NUMBER
                                ,p_tax_unit_id          IN NUMBER
                                ,p_assignment_id        IN NUMBER
                                ,p_last_pymt_action_id  IN NUMBER
                                ,p_last_pymt_eff_date   IN DATE
                                ,p_last_xfr_eff_date    IN DATE
                                ,p_ytd_balcall_aaid     IN NUMBER
                                ,p_pymt_eff_date        IN DATE
                                ,p_legislation_code     IN VARCHAR2
                                )

   IS

     CURSOR c_prev_elements(cp_assignment_id      IN NUMBER
                           ,cp_last_pymt_eff_date IN DATE
                           ,cp_last_xfr_eff_date  IN DATE) IS
       SELECT DISTINCT
             NVL(pbtl.reporting_name, pbtl.balance_name),
             pbad.attribute_name,
             DECODE(pbad.attribute_name,
                       'Employee Taxes', prb.jurisdiction_code),
             pbt_pri.balance_type_id,          -- Primary Balance
             DECODE(pbad.attribute_name,
                   'Hourly Earnings', pbt_sec.balance_type_id,
                   NULL),                      -- Hours Balance
             DECODE(pbad.attribute_name,
                   'Employee Earnings', pbt_sec.balance_type_id,
                   NULL)                       -- Days Balance
         FROM pay_bal_attribute_definitions pbad,
              pay_balance_attributes        pba,
              pay_defined_balances          pdb,
              pay_run_balances              prb,
              pay_action_interlocks         pai,
              pay_assignment_actions        paa_pre,
              pay_payroll_actions           ppa_pre,
              pay_balance_types             pbt_pri,
              pay_balance_types             pbt_sec,
              pay_balance_types_tl          pbtl
        WHERE ppa_pre.action_type     IN ('U', 'P')
          AND ppa_pre.effective_date   > cp_last_xfr_eff_date
          AND ppa_pre.effective_date   <= cp_last_pymt_eff_date
          AND paa_pre.payroll_action_id = ppa_pre.payroll_action_id
          AND paa_pre.assignment_id    = cp_assignment_id
          AND pai.locking_action_id    = paa_pre.assignment_action_id
          AND prb.assignment_action_id = pai.locked_action_id
          AND pbad.attribute_name IN ('Employee Earnings',
                                     'Hourly Earnings',
                                     'Deductions',
                                     'Taxable Benefits'
--                                     'Employee Taxes',
--                                     'Tax Calculation Details'
                                     )
          AND pbad.legislation_code    = 'MX'
          AND pba.attribute_id         = pbad.attribute_id
          AND pdb.defined_balance_id   = pba.defined_balance_id
          AND prb.defined_balance_id   = pdb.defined_balance_id
          AND pbt_pri.balance_type_id  = pdb.balance_type_id
          AND pbt_pri.input_value_id   IS NOT NULL
          AND pbt_pri.balance_type_id  = pbt_sec.base_balance_type_id(+)
          AND pbtl.balance_type_id     = pbt_pri.balance_type_id
          AND pbtl.language            = USERENV('LANG')
       ORDER BY 1;

     CURSOR c_prev_elements_RR(cp_assignment_id      IN NUMBER
                              ,cp_last_pymt_eff_date IN DATE
                              ,cp_last_xfr_eff_date  IN DATE) IS
       SELECT DISTINCT
             NVL(pbtl.reporting_name, pbtl.balance_name),
             pbad.attribute_name,
             DECODE(pbad.attribute_name,
                       'Employee Taxes', prr.jurisdiction_code),
             pbt_pri.balance_type_id,          -- Primary Balance
             DECODE(pbad.attribute_name,
                   'Hourly Earnings', pbt_sec.balance_type_id,
                   NULL),                      -- Hours Balance
             DECODE(pbad.attribute_name,
                   'Employee Earnings', pbt_sec.balance_type_id,
                   NULL)                       -- Days Balance
         FROM pay_bal_attribute_definitions pbad,
              pay_balance_attributes        pba,
              pay_defined_balances          pdb,
              pay_run_results               prr,
              pay_input_values_f            piv,
              pay_action_interlocks         pai,
              pay_assignment_actions        paa_pre,
              pay_payroll_actions           ppa_pre,
              pay_balance_types             pbt_pri,
              pay_balance_types             pbt_sec,
              pay_balance_types_tl          pbtl
        WHERE ppa_pre.action_type     IN ('U', 'P')
          AND ppa_pre.effective_date   > cp_last_xfr_eff_date
          AND ppa_pre.effective_date   <= cp_last_pymt_eff_date
          AND paa_pre.payroll_action_id = ppa_pre.payroll_action_id
          AND paa_pre.assignment_id    = cp_assignment_id
          AND pai.locking_action_id    = paa_pre.assignment_action_id
          AND prr.assignment_action_id = pai.locked_action_id
          AND pbad.attribute_name IN ('Employee Earnings',
                                     'Hourly Earnings',
                                     'Deductions',
                                     'Taxable Benefits'
--                                     'Employee Taxes',
--                                     'Tax Calculation Details'
                                     )
          AND pbad.legislation_code    = 'MX'
          AND pba.attribute_id         = pbad.attribute_id
          AND pdb.defined_balance_id   = pba.defined_balance_id
          AND pbt_pri.balance_type_id  = pdb.balance_type_id
          AND pbt_pri.input_value_id   = piv.input_value_id
          AND piv.element_type_id      = prr.element_type_id
          AND ppa_pre.effective_date BETWEEN piv.effective_start_date
                                         AND piv.effective_end_date
          AND pbt_pri.balance_type_id  = pbt_sec.base_balance_type_id(+)
          AND pbtl.balance_type_id     = pbt_pri.balance_type_id
          AND pbtl.language            = USERENV('LANG')
       ORDER BY 1;

  CURSOR c_business_grp_id IS
    SELECT DISTINCT business_group_id
      FROM per_assignments_f
     WHERE assignment_id = p_assignment_id;


    ln_primary_balance_id           NUMBER;
    lv_reporting_name               VARCHAR2(80);
    lv_attribute_name               VARCHAR2(80);
    lv_jurisdiction_code            VARCHAR2(80);
    ln_hours_balance_id             NUMBER;
    ln_days_balance_id              NUMBER;

    ln_ytd_hours_balance_id         NUMBER;
    ln_ytd_days_balance_id          NUMBER;
    ln_ytd_defined_balance_id       NUMBER;
    ln_payments_amount              NUMBER;
    ln_ytd_hours                    NUMBER;
    ln_ytd_days                     NUMBER;
    ln_ytd_amount                   NUMBER(17,2);
    lv_action_info_category         VARCHAR2(30);

    ln_index                        NUMBER ;
    lv_element_archived             VARCHAR2(1);
    lv_procedure_name               VARCHAR2(100);
    lv_error_message                VARCHAR2(200);
    ln_step                         NUMBER;

    st_cnt                          NUMBER;
    end_cnt                         NUMBER;
    lv_business_grp_id              NUMBER;
    lv_run_bal_status               VARCHAR2(1);

  BEGIN
     lv_action_info_category       := 'AC DEDUCTIONS';
     lv_element_archived           := 'N';
     lv_procedure_name             := '.get_missing_xfr_info';

     ln_step := 1;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_xfr_action_id = '     || p_xfr_action_id);
     hr_utility.trace('p_tax_unit_id = '       || p_tax_unit_id);
     hr_utility.trace('p_last_pymt_action_id ='|| p_last_pymt_action_id );
     hr_utility.trace('p_last_pymt_eff_date='  || p_last_pymt_eff_date);

      lv_run_bal_status := NULL;

      IF run_bal_stat.COUNT >0 THEN
         st_cnt := run_bal_stat.FIRST;
         end_cnt := run_bal_stat.LAST;
         FOR i IN st_cnt..end_cnt LOOP
            IF run_bal_stat(i).valid_status = 'N' THEN
               lv_run_bal_status := 'N';
               EXIT;
            END IF;
         END LOOP;
      ELSE
         OPEN c_business_grp_id;
         FETCH c_business_grp_id INTO lv_business_grp_id;
         CLOSE c_business_grp_id;

         run_bal_stat(1).attribute_name := 'Employee Earnings';
         run_bal_stat(2).attribute_name := 'Hourly Earnings';
         run_bal_stat(3).attribute_name := 'Deductions';
         run_bal_stat(4).attribute_name := 'Employee Taxes';
         run_bal_stat(5).attribute_name := 'Tax Calculation Details';
         run_bal_stat(6).attribute_name := 'Taxable Benefits';

         st_cnt := run_bal_stat.FIRST;
         end_cnt := run_bal_stat.LAST;

         FOR i IN st_cnt..end_cnt LOOP
            run_bal_stat(i).valid_status := pay_us_payroll_utils.check_balance_status(
                                                     p_pymt_eff_date,
                                                     lv_business_grp_id,
                                                     run_bal_stat(i).attribute_name,
                                                     p_legislation_code);
            IF (lv_run_bal_status IS NULL AND run_bal_stat(i).valid_status = 'N') THEN
               lv_run_bal_status := 'N';
            END IF;
         END LOOP;
      END IF;

      IF lv_run_bal_status IS NULL THEN
         lv_run_bal_status := 'Y';
      END IF;

     IF lv_run_bal_status = 'N' THEN

          OPEN c_prev_elements_RR(p_assignment_id,
                                  p_last_pymt_eff_date,
                                  p_last_xfr_eff_date);

     ELSE
          OPEN c_prev_elements(p_assignment_id,
                               p_last_pymt_eff_date,
                               p_last_xfr_eff_date);

     END IF;

     LOOP

        IF lv_run_bal_status = 'N' THEN

            FETCH c_prev_elements_RR INTO lv_reporting_name,
                                          lv_attribute_name,
                                          lv_jurisdiction_code,
                                          ln_primary_balance_id,
                                          ln_hours_balance_id,
                                          ln_days_balance_id;
            IF c_prev_elements_RR%NOTFOUND THEN
               hr_utility.set_location(gv_package || lv_procedure_name, 15);
               EXIT;
            END IF;
            hr_utility.set_location(gv_package || lv_procedure_name, 20);

        ELSE

            FETCH c_prev_elements INTO lv_reporting_name,
                                       lv_attribute_name,
                                       lv_jurisdiction_code,
                                       ln_primary_balance_id,
                                       ln_hours_balance_id,
                                       ln_days_balance_id;
            IF c_prev_elements%NOTFOUND THEN
               hr_utility.set_location(gv_package || lv_procedure_name, 25);
               EXIT;
            END IF;
            hr_utility.set_location(gv_package || lv_procedure_name, 30);

        END IF;

        IF lv_attribute_name IN ('Deductions', 'Employee Taxes',
                                 'Tax Calculation Details') THEN
           ln_hours_balance_id := NULL;
           ln_days_balance_id  := NULL;
        END IF;

        ln_step := 5;
        IF pay_ac_action_arch.emp_elements_tab.count > 0 THEN
           FOR i IN pay_ac_action_arch.emp_elements_tab.first..
                    pay_ac_action_arch.emp_elements_tab.last LOOP
               IF pay_ac_action_arch.emp_elements_tab(i).element_primary_balance_id
                       = ln_primary_balance_id AND
                  NVL(pay_ac_action_arch.emp_elements_tab(i).jurisdiction_code,
                      -999)    =  NVL(lv_jurisdiction_code, -999) THEN
                  lv_element_archived := 'Y';
                  EXIT;
               END IF;
           END LOOP;
        END IF;

        IF lv_element_archived = 'N' THEN
           /* populate the extra element table */
           ln_step := 10;
           ln_index := pay_ac_action_arch.emp_elements_tab.count;
           pay_ac_action_arch.emp_elements_tab(ln_index).element_primary_balance_id
                := ln_primary_balance_id;
           pay_ac_action_arch.emp_elements_tab(ln_index).element_reporting_name
                := lv_reporting_name;
           pay_ac_action_arch.emp_elements_tab(ln_index).element_hours_balance_id
                := ln_hours_balance_id;
           pay_ac_action_arch.emp_elements_tab(ln_index).jurisdiction_code
                := lv_jurisdiction_code;

           IF lv_jurisdiction_code IS NOT NULL THEN
              pay_balance_pkg.set_context('JURISDICTION_CODE', lv_jurisdiction_code);
              gv_ytd_balance_dimension := gv_dim_asg_jd_gre_ytd;
           ELSE
              pay_balance_pkg.set_context('JURISDICTION_CODE', lv_jurisdiction_code);
              gv_ytd_balance_dimension := gv_dim_asg_gre_ytd;
           END IF;

           ln_step := 15;
           ln_ytd_defined_balance_id :=
                  pay_emp_action_arch.get_defined_balance_id
                                           (ln_primary_balance_id,
                                            gv_ytd_balance_dimension,
                                            p_legislation_code);
           hr_utility.set_location(gv_package || lv_procedure_name, 60);
           IF ln_ytd_defined_balance_id IS NOT NULL THEN
              ln_ytd_amount := NVL(pay_balance_pkg.get_value(
                                   ln_ytd_defined_balance_id,
                                   p_ytd_balcall_aaid),0);
              hr_utility.set_location(gv_package || lv_procedure_name, 70);
           END IF;
           IF ln_hours_balance_id IS NOT NULL THEN
              ln_ytd_hours_balance_id :=
                     pay_emp_action_arch.get_defined_balance_id
                                             (ln_hours_balance_id,
                                              gv_ytd_balance_dimension,
                                              p_legislation_code);
              hr_utility.set_location(gv_package || lv_procedure_name, 80);
              IF ln_ytd_hours_balance_id IS NOT NULL THEN
                 ln_ytd_hours := NVL(pay_balance_pkg.get_value(
                                         ln_ytd_hours_balance_id,
                                         p_ytd_balcall_aaid),0);
                 hr_utility.set_location(gv_package || lv_procedure_name, 90);
              END IF;
           END IF;  -- Hours

           IF ln_days_balance_id IS NOT NULL THEN
              ln_ytd_days_balance_id :=
                     pay_emp_action_arch.get_defined_balance_id
                                             (ln_days_balance_id,
                                              gv_ytd_balance_dimension,
                                              p_legislation_code);
              hr_utility.set_location(gv_package || lv_procedure_name, 80);
              IF ln_ytd_days_balance_id IS NOT NULL THEN
                 ln_ytd_days := NVL(pay_balance_pkg.get_value(
                                         ln_ytd_days_balance_id,
                                         p_ytd_balcall_aaid),0);
                 hr_utility.set_location(gv_package || lv_procedure_name, 90);
              END IF;
           END IF;  -- Days

           hr_utility.set_location(gv_package || lv_procedure_name, 100);

           IF NVL(ln_ytd_amount, 0) <> 0 OR NVL(ln_payments_amount, 0) <> 0 THEN

              ln_index := pay_ac_action_arch.lrr_act_tab.count;
              hr_utility.trace('ln_index = ' || ln_index);

              IF lv_attribute_name IN ('Employee Earnings',
                                       'Hourly Earnings',
                                       'Taxable Benefits') THEN

                 lv_action_info_category := 'AC EARNINGS';
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                      := fnd_number.number_to_canonical(ln_ytd_hours);
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info15
                      := fnd_number.number_to_canonical(ln_ytd_days);

              END IF;

              ln_step := 20;
              pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                      := lv_action_info_category;
              pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                      := lv_jurisdiction_code;
              pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                      := p_xfr_action_id ;
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                      := ln_primary_balance_id;
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                      := fnd_number.number_to_canonical(ln_payments_amount);
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                      := fnd_number.number_to_canonical(ln_ytd_amount);
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                      := lv_reporting_name;
               pay_ac_action_arch.lrr_act_tab(ln_index).act_info16
                         := lv_attribute_name;

           END IF;
        END IF;
        lv_element_archived     := 'N';
        lv_action_info_category := 'AC DEDUCTIONS';
        lv_jurisdiction_code    := NULL;
        ln_primary_balance_id   := NULL;
        lv_reporting_name       := NULL;
        ln_hours_balance_id     := NULL;
     END LOOP;

     IF lv_run_bal_status = 'N' THEN
          CLOSE c_prev_elements_RR;
     ELSE
          CLOSE c_prev_elements;
     END IF;

     hr_utility.set_location(gv_package || lv_procedure_name, 150);

     ln_step := 30;


  EXCEPTION
    WHEN OTHERS THEN

      lv_error_message := 'Error at step ' || ln_step ||
                          ' IN ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_missing_xfr_info;



  /******************************************************************
   Name      : get_xfr_elements
   Purpose   : Check the elements archived in the previous record with
               the given assignment and if the element is not archived
               in this current run, get YTD for the element found.
   Arguments : p_xfr_action_id      => Current xfr action id
               p_last_xfr_action_id => Previous xfr action id retrieved
                                       from get_last_xfr_info procedure
               p_ytd_balcall_aaid   => aaid for YTD balance call.
               p_pymt_eff_date      => Current pymt eff date.
               p_legislation_code   => Legislation code.
               p_sepchk_flag        => Separate Check flag.
               p_assignment_id      => Current assignment id that IS being
                                       processed.
   Notes     : If multi assignment is enabled and is a sepchk, then check
               the last xfr run for the given person not assignment.
  ******************************************************************/
  PROCEDURE get_xfr_elements(p_xfr_action_id       IN NUMBER
                            ,p_last_xfr_action_id  IN NUMBER
                            ,p_ytd_balcall_aaid    IN NUMBER
                            ,p_pymt_eff_date       IN DATE
                            ,p_legislation_code    IN VARCHAR2
                            ,p_sepchk_flag         IN VARCHAR2
                            ,p_assignment_id       IN NUMBER
                            )

  IS
    CURSOR c_last_xfr_elements(cp_xfr_action_id    IN NUMBER
                              ,cp_legislation_code IN VARCHAR2) IS
      SELECT assignment_id, action_information_category,
               jurisdiction_code,
             action_information6  primary_balance_id,
             action_information9  ytd_amount,
             action_information10 reporting_name,
             effective_date       effective_date,
             action_information12 ytd_hours,
             action_information15 ytd_days,
             action_information16 attribute_name
        FROM pay_action_information
       WHERE action_information_category IN ('AC EARNINGS', 'AC DEDUCTIONS')
         AND action_context_id = cp_xfr_action_id;


    CURSOR c_get_balance (cp_balance_name  IN VARCHAR2
                         ,cp_legislation_code IN VARCHAR2) IS
      SELECT balance_type_id
        FROM pay_balance_types
       WHERE legislation_code = cp_legislation_code
         AND balance_name = cp_balance_name;

    CURSOR c_last_per_xfr_run IS
      SELECT pai.action_context_id
        FROM per_assignments_f paf2,
             per_assignments_f paf,
             pay_action_information pai
       WHERE paf.assignment_id = p_assignment_id
         AND paf.effective_end_date >= trunc(p_pymt_eff_date, 'Y')
         AND paf.effective_start_date <= p_pymt_eff_date
         AND paf.person_id = paf2.person_id
         AND paf2.effective_end_date >= trunc(p_pymt_eff_date, 'Y')
         AND paf2.effective_start_date <= p_pymt_eff_date
         AND paf2.assignment_id = pai.assignment_id
         AND pai.effective_date >= trunc(p_pymt_eff_date, 'Y')
      ORDER BY pai.action_context_id DESC;

    CURSOR c_balance_info(cp_primary_balance_id IN NUMBER
                         ,cp_effective_date     IN DATE) IS
      SELECT DISTINCT
             pbad.attribute_name,
             pbt_pri.balance_type_id,          -- Primary Balance
             DECODE(pbad.attribute_name,
                   'Hourly Earnings', pbt_sec.balance_type_id,
                   NULL),                      -- Hours Balance
             DECODE(pbad.attribute_name,
                   'Employee Earnings', pbt_sec.balance_type_id,
                   NULL)                       -- Days Balance
        FROM pay_bal_attribute_definitions pbad,
             pay_balance_attributes        pba,
             pay_defined_balances          pdb,
             pay_balance_types             pbt_pri,
             pay_balance_types             pbt_sec,
             pay_input_values_f            piv,
             pay_element_types_f           pet
      WHERE  pbad.attribute_name IN ('Employee Earnings',
                                     'Hourly Earnings',
                                     'Deductions',
                                     'Taxable Benefits'
--                            ,'Employee Taxes',
--                             'Tax Calculation Details'
                              )
        AND  pbad.legislation_code   = 'MX'
        AND  pba.attribute_id        = pbad.attribute_id
        AND  pdb.defined_balance_id  = pba.defined_balance_id
        AND  pbt_pri.balance_type_id = pdb.balance_type_id
        AND  pbt_pri.balance_type_id = cp_primary_balance_id
        AND  pbt_pri.balance_type_id = pbt_sec.base_balance_type_id(+)
        AND  pbt_pri.input_value_id  = piv.input_value_id
        AND  piv.element_type_id     = pet.element_type_id
        AND  cp_effective_date    BETWEEN pet.effective_start_date
                                      AND pet.effective_end_date
        AND  cp_effective_date    BETWEEN piv.effective_start_date
                                      AND piv.effective_end_date
      ORDER BY 1;

    lv_jurisdiction_code           VARCHAR2(80);
    ln_primary_balance_id          NUMBER;
    lv_reporting_name              VARCHAR2(150);
    ld_effective_date              DATE;
    ln_hours_balance_id            NUMBER;
    ln_days_balance_id             NUMBER;

    ln_t_primary_balance_id        NUMBER;
    lv_t_reporting_name            VARCHAR2(150);
    lv_attribute_name              VARCHAR2(80);

    ln_ele_primary_balance_id      NUMBER;
    ln_ele_hours_balance_id        NUMBER;
    ln_ele_days_balance_id         NUMBER;

    ln_ytd_defined_balance_id NUMBER;
    ln_ytd_hours_balance_id   NUMBER;
    ln_ytd_days_balance_id    NUMBER;
    ln_payments_amount        NUMBER;
    ln_ytd_hours              NUMBER;
    ln_ytd_days               NUMBER;
    ln_ytd_amount             NUMBER;

    ln_index                  NUMBER := 0;
    lv_element_archived       VARCHAR2(1);
    lv_action_info_category   VARCHAR2(30);
    lv_procedure_name         VARCHAR2(100);
    lv_error_message          VARCHAR2(200);
    ln_step                   NUMBER;
    ln_assignment_id          NUMBER;
    lv_act_info_category      VARCHAR2(30);
    ln_last_per_xfr_action_id NUMBER;
    cn_last_xfr_action_id     NUMBER;

  BEGIN
     lv_element_archived       := 'N';
     lv_action_info_category   := 'AC DEDUCTIONS';
     lv_procedure_name         := '.get_xfr_elements';

     ln_step:= 1;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_xfr_action_id = '||p_xfr_action_id);
     hr_utility.trace('p_last_xfr_action_id = '|| p_last_xfr_action_id );
     hr_utility.trace('p_assignment_id = '|| p_assignment_id );
     hr_utility.trace('gv_multi_payroll_pymt = '||
                          pay_emp_action_arch.gv_multi_payroll_pymt);
     hr_utility.trace('p_sepchk_flag = '||p_sepchk_flag);

     cn_last_xfr_action_id := p_last_xfr_action_id;

     IF pay_emp_action_arch.gv_multi_payroll_pymt = 'Y'  AND
        p_sepchk_flag = 'Y' THEN

        OPEN c_last_per_xfr_run;
        FETCH c_last_per_xfr_run INTO ln_last_per_xfr_action_id;
          IF c_last_per_xfr_run%FOUND THEN
          hr_utility.trace('found ln_last_per_xfr_action_id = '||
                                 ln_last_per_xfr_action_id);
            cn_last_xfr_action_id := ln_last_per_xfr_action_id;
          END IF;
        CLOSE c_last_per_xfr_run;

        hr_utility.trace('New cn_last_xfr_action_id = '||cn_last_xfr_action_id);
     END IF;


     OPEN c_last_xfr_elements(cn_last_xfr_action_id, p_legislation_code);
     LOOP
        FETCH c_last_xfr_elements INTO ln_assignment_id,
                                       lv_act_info_category,
                                       lv_jurisdiction_code,
                                       ln_primary_balance_id,
                                       ln_ytd_amount,
                                       lv_reporting_name,
                                       ld_effective_date,
                                       ln_ytd_hours,
                                       ln_ytd_days,
                                       lv_attribute_name;

        hr_utility.set_location(gv_package || lv_procedure_name, 20);
        IF c_last_xfr_elements%NOTFOUND THEN
           hr_utility.set_location(gv_package || lv_procedure_name, 30);
           EXIT;
        END IF;

        ln_step := 5;
        IF ln_primary_balance_id IS NULL THEN
           OPEN c_get_balance(lv_t_reporting_name, p_legislation_code);
           FETCH c_get_balance INTO ln_t_primary_balance_id;
           CLOSE c_get_balance;
           ln_primary_balance_id := ln_t_primary_balance_id;
        END IF;

        hr_utility.trace('Reporting Name  =' || lv_reporting_name);
        hr_utility.trace('JD Code         =' || lv_jurisdiction_code);

        ln_step := 6;

        hr_utility.trace('p_assignment_id (current) = '||p_assignment_id);
        hr_utility.trace('ln_assignment_id (prev) = '||ln_assignment_id);

        IF ((pay_emp_action_arch.gv_multi_payroll_pymt = 'Y' ) AND
            (p_sepchk_flag = 'Y') AND
            (ln_assignment_id <> p_assignment_id)) THEN

           hr_utility.trace('action_info_category = ' ||lv_act_info_category);
           hr_utility.trace('ln_primary_balance_id = '||ln_primary_balance_id);
           hr_utility.trace('ln_ytd_amount = '        ||ln_ytd_amount);

           ln_index := pay_ac_action_arch.lrr_act_tab.count;

           pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                     := lv_act_info_category;
           pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                     := lv_jurisdiction_code;
           pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                     := p_xfr_action_id;
           pay_ac_action_arch.lrr_act_tab(ln_index).assignment_id
                     := ln_assignment_id;
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                     := ln_primary_balance_id;
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                     := fnd_number.number_to_canonical(ln_ytd_amount);
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                     := lv_reporting_name;
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info16
                     := lv_attribute_name;

           IF lv_act_info_category = 'AC EARNINGS' THEN
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                       := fnd_number.number_to_canonical(ln_ytd_hours);
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info15
                       := fnd_number.number_to_canonical(ln_ytd_days);
           END IF;
        END IF;

        IF ln_assignment_id = p_assignment_id THEN
           IF pay_ac_action_arch.emp_elements_tab.count > 0 THEN
              FOR i IN pay_ac_action_arch.emp_elements_tab.first..
                       pay_ac_action_arch.emp_elements_tab.last LOOP
                 IF pay_ac_action_arch.emp_elements_tab(i).element_primary_balance_id
                          = ln_primary_balance_id AND
                   NVL(pay_ac_action_arch.emp_elements_tab(i).jurisdiction_code,
                       -999)     =    NVL(lv_jurisdiction_code, -999) THEN
                     lv_element_archived := 'Y';
                     EXIT;
                  END IF;
              END LOOP;
           END IF;

           ln_step := 10;
           IF lv_element_archived = 'N' THEN
              hr_utility.set_location(gv_package || lv_procedure_name, 50);
              /**************************************************************
              ** Check to see if the element is still effective
              ** the primary balance IS there before archiving
              ** the value when picking elements which have
              ** already been archived.
              ** Note: This will take care of the issue when clients migrate
              **       to a new element and only want one entry to be archived
              **       and show up in checks, payslip and depsoit advice
              **************************************************************/
              OPEN c_balance_info(ln_primary_balance_id, ld_effective_date);
                 FETCH c_balance_info INTO lv_attribute_name,
                                           ln_ele_primary_balance_id,
                                           ln_ele_hours_balance_id,
                                           ln_ele_days_balance_id;
                 IF c_balance_info%NOTFOUND OR
                    ln_ele_primary_balance_id IS NULL THEN
                    lv_element_archived := 'Y';
                 END IF;

                 CLOSE c_balance_info;

                 IF lv_attribute_name <> 'Deductions' THEN
                    ln_hours_balance_id := ln_ele_hours_balance_id;
                    ln_days_balance_id  := ln_ele_days_balance_id;
                 END IF;
              END IF;
           END IF;


           IF lv_element_archived = 'N' THEN
              /* populate the extra element table */
              ln_index := pay_ac_action_arch.emp_elements_tab.count;
              pay_ac_action_arch.emp_elements_tab(ln_index).jurisdiction_code
                   := lv_jurisdiction_code;
              pay_ac_action_arch.emp_elements_tab(ln_index).element_primary_balance_id
                   := ln_primary_balance_id;
              pay_ac_action_arch.emp_elements_tab(ln_index).element_reporting_name
                   := lv_reporting_name;
              pay_ac_action_arch.emp_elements_tab(ln_index).element_hours_balance_id
                   := ln_hours_balance_id;

              IF lv_jurisdiction_code IS NOT NULL THEN
                 pay_balance_pkg.set_context('JURISDICTION_CODE', lv_jurisdiction_code);
                 gv_ytd_balance_dimension := gv_dim_asg_jd_gre_ytd;
              ELSE
                 pay_balance_pkg.set_context('JURISDICTION_CODE', lv_jurisdiction_code);
                 gv_ytd_balance_dimension := gv_dim_asg_gre_ytd;
              END IF;

              ln_step := 15;
              ln_ytd_defined_balance_id
                  := pay_emp_action_arch.get_defined_balance_id
                                          (ln_primary_balance_id,
                                           gv_ytd_balance_dimension,
                                           p_legislation_code);
              hr_utility.set_location(gv_package || lv_procedure_name, 60);
              IF ln_ytd_defined_balance_id IS NOT NULL THEN
                 ln_ytd_amount := NVL(pay_balance_pkg.get_value(
                                        ln_ytd_defined_balance_id,
                                        p_ytd_balcall_aaid),0);
              END IF;
              hr_utility.set_location(gv_package || lv_procedure_name, 70);
              IF ln_hours_balance_id IS NOT NULL THEN
                 ln_ytd_hours_balance_id
                    := pay_emp_action_arch.get_defined_balance_id
                                           (ln_hours_balance_id,
                                            gv_ytd_balance_dimension,
                                            p_legislation_code);
                 hr_utility.set_location(gv_package || lv_procedure_name, 80);
                 IF ln_ytd_hours_balance_id IS NOT NULL THEN
                    ln_ytd_hours := NVL(pay_balance_pkg.get_value(
                                         ln_ytd_hours_balance_id,
                                         p_ytd_balcall_aaid),0);
                    hr_utility.set_location(gv_package || lv_procedure_name, 90);
                 END IF;
              END IF;

              IF ln_days_balance_id IS NOT NULL THEN
                 ln_ytd_days_balance_id
                    := pay_emp_action_arch.get_defined_balance_id
                                           (ln_days_balance_id,
                                            gv_ytd_balance_dimension,
                                            p_legislation_code);
                 hr_utility.set_location(gv_package || lv_procedure_name, 93);
                 IF ln_ytd_days_balance_id IS NOT NULL THEN
                    ln_ytd_hours := NVL(pay_balance_pkg.get_value(
                                         ln_ytd_days_balance_id,
                                         p_ytd_balcall_aaid),0);
                    hr_utility.set_location(gv_package || lv_procedure_name, 96);
                 END IF;
              END IF;

              hr_utility.trace('ln_ytd_amount = '||ln_ytd_amount);
              hr_utility.trace('ln_ytd_hours  = '||ln_ytd_hours);
              hr_utility.trace('ln_ytd_days   = '||ln_ytd_days);

              IF (( NVL(ln_ytd_amount, 0) + NVL(ln_payments_amount, 0) <> 0 ) OR
                  ( pay_ac_action_arch.gv_multi_gre_payment = 'N' ) ) THEN

                 hr_utility.set_location(gv_package || lv_procedure_name, 100);
                 ln_index := pay_ac_action_arch.lrr_act_tab.count;
                 hr_utility.trace('ln_index = ' || ln_index);
                 ln_step := 20;
                 IF lv_attribute_name IN ('Employee Earnings',
                                          'Hourly Earnings',
                                          'Taxable Benefits') THEN
                    lv_action_info_category := 'AC EARNINGS';
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                         := fnd_number.number_to_canonical(ln_ytd_hours);
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info15
                         := fnd_number.number_to_canonical(ln_ytd_days);

                 END IF;

                 pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                         := lv_action_info_category;
                 pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                         := lv_jurisdiction_code;
                 pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                         := p_xfr_action_id;
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                         := ln_primary_balance_id;
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                         := fnd_number.number_to_canonical(ln_payments_amount);
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                         := fnd_number.number_to_canonical(ln_ytd_amount);
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                         := lv_reporting_name;
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info16
                         := lv_attribute_name;
              END IF;
           END IF;

           lv_element_archived := 'N';
           lv_action_info_category := 'AC DEDUCTIONS';
           lv_jurisdiction_code    := NULL;
           ln_primary_balance_id   := NULL;
           lv_reporting_name       := NULL;
           ln_hours_balance_id     := NULL;
           ln_ytd_amount           := NULL;
           ln_ytd_hours            := NULL;

     END LOOP;

     CLOSE c_last_xfr_elements;

     hr_utility.set_location(gv_package || lv_procedure_name, 50);
     ln_step := 25;



  EXCEPTION
   WHEN OTHERS THEN
      lv_error_message := 'Error at step ' || ln_step ||
                          ' IN ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_xfr_elements;



  PROCEDURE get_current_elements(p_xfr_action_id        IN NUMBER
                                ,p_curr_pymt_action_id  IN NUMBER
                                ,p_curr_pymt_eff_date   IN DATE
                                ,p_assignment_id        IN NUMBER
                                ,p_tax_unit_id          IN NUMBER
                                ,p_sepchk_flag          IN VARCHAR2
                                ,p_pymt_balcall_aaid    IN NUMBER
                                ,p_ytd_balcall_aaid     IN NUMBER
                                ,p_legislation_code     IN VARCHAR2
                                ,p_action_type     IN VARCHAR2 DEFAULT NULL
                                )
  IS

     CURSOR c_cur_sp_action_elements(cp_pymt_action_id   IN NUMBER
                                    ,cp_assignment_id    IN NUMBER
                                    ,cp_sepchk_flag      IN VARCHAR2
                               ) IS
      SELECT DISTINCT
             NVL(pbtl.reporting_name, pbtl.balance_name),
             pbad.attribute_name,
             pbt_pri.balance_type_id,          -- Primary Balance
             DECODE(pbad.attribute_name,
                   'Hourly Earnings', pbt_sec.balance_type_id,
                   NULL),                      -- Hours Balance
             DECODE(pbad.attribute_name,
                   'Employee Earnings', pbt_sec.balance_type_id,
                   NULL)                       -- Days Balance
        FROM pay_bal_attribute_definitions pbad,
             pay_balance_attributes        pba,
             pay_defined_balances          pdb,
             pay_balance_types             pbt_pri,
             pay_balance_types             pbt_sec,
             pay_balance_types_tl          pbtl,
             pay_run_balances              prb,
             pay_assignment_actions        paa,
             pay_payroll_actions           ppa
      WHERE  pbad.attribute_name IN ('Employee Earnings',
                                     'Hourly Earnings',
                                     'Deductions',
                                     'Taxable Benefits'
--                            ,'Employee Taxes',
--                             'Tax Calculation Details'
                              )
        AND  pbad.legislation_code  = 'MX'
        AND  pba.attribute_id       = pbad.attribute_id
        AND  pdb.defined_balance_id = pba.defined_balance_id
        AND  prb.defined_balance_id = pdb.defined_balance_id
        AND  pbt_pri.balance_type_id = pdb.balance_type_id
        AND  pbt_pri.input_value_id IS NOT NULL
        AND  pbtl.balance_type_id   = pbt_pri.balance_type_id
        AND  pbt_pri.balance_type_id = pbt_sec.base_balance_type_id(+)
        AND  pbtl.language          = USERENV('LANG')
        AND  prb.assignment_id      = cp_assignment_id
        AND  paa.assignment_id      = prb.assignment_id
        AND  cp_sepchk_flag = 'Y'
        AND  prb.assignment_action_id = cp_pymt_action_id
        AND  prb.assignment_action_id = paa.assignment_action_id
        AND  NVL(paa.run_type_id, gn_sepchk_run_type_id) IN
               (gn_sepchk_run_type_id, gn_np_sepchk_run_type_id)
        AND  ppa.payroll_action_id = paa.payroll_action_id
      ORDER BY 1;


     CURSOR c_cur_sp_action_elements_RR(cp_pymt_action_id   IN NUMBER
                                       ,cp_assignment_id    IN NUMBER
                                       ,cp_sepchk_flag      IN VARCHAR2
                                  ) IS
     SELECT  DISTINCT
             NVL(pbtl.reporting_name, pbtl.balance_name),
             pbad.attribute_name,
             pbt_pri.balance_type_id,          -- Primary Balance
             DECODE(pbad.attribute_name,
                   'Hourly Earnings', pbt_sec.balance_type_id,
                   NULL),                      -- Hours Balance
             DECODE(pbad.attribute_name,
                   'Employee Earnings', pbt_sec.balance_type_id,
                   NULL)                       -- Days Balance
       FROM  pay_bal_attribute_definitions pbad,
             pay_balance_attributes        pba,
             pay_defined_balances          pdb,
             pay_balance_types             pbt_pri,
             pay_balance_types             pbt_sec,
             pay_balance_types_tl          pbtl,
             pay_run_results               prr,
             pay_input_values_f            piv,
             pay_assignment_actions        paa,
             pay_payroll_actions           ppa
      WHERE  pbad.attribute_name IN ('Employee Earnings',
                                     'Hourly Earnings',
                                     'Deductions',
                                     'Taxable Benefits'
--                            ,'Employee Taxes',
--                             'Tax Calculation Details'
                              )
        AND  pbad.legislation_code  = 'MX'
        AND  pba.attribute_id       = pbad.attribute_id
        AND  pdb.defined_balance_id = pba.defined_balance_id
        AND  pbt_pri.balance_type_id = pdb.balance_type_id
        AND  pbt_pri.input_value_id = piv.input_value_id
        AND  piv.element_type_id    = prr.element_type_id
        AND  ppa.effective_date  BETWEEN piv.effective_start_date
                                     AND piv.effective_end_date
        AND  pbtl.balance_type_id   = pbt_pri.balance_type_id
        AND  pbt_pri.balance_type_id = pbt_sec.base_balance_type_id(+)
        AND  pbtl.language          = USERENV('LANG')
        AND  paa.assignment_id      = cp_assignment_id
        AND  cp_sepchk_flag = 'Y'
        AND  prr.assignment_action_id = cp_pymt_action_id
        AND  prr.assignment_action_id = paa.assignment_action_id
        AND  NVL(paa.run_type_id, gn_sepchk_run_type_id) IN
               (gn_sepchk_run_type_id, gn_np_sepchk_run_type_id)
        AND  ppa.payroll_action_id = paa.payroll_action_id
   ORDER BY 1;

    CURSOR c_cur_action_elements(cp_pymt_action_id   IN NUMBER
                                ,cp_assignment_id    IN NUMBER
                                ,cp_sepchk_flag      IN VARCHAR2
                                ,cp_ytd_act_sequence IN NUMBER
                                ) IS
      SELECT DISTINCT
             NVL(pbtl.reporting_name, pbtl.balance_name),
             pbad.attribute_name,
             pbt_pri.balance_type_id,          -- Primary Balance
             DECODE(pbad.attribute_name,
                   'Hourly Earnings', pbt_sec.balance_type_id,
                   NULL),                      -- Hours Balance
             DECODE(pbad.attribute_name,
                   'Employee Earnings', pbt_sec.balance_type_id,
                   NULL)                       -- Days Balance
        FROM pay_bal_attribute_definitions pbad,
             pay_balance_attributes        pba,
             pay_defined_balances          pdb,
             pay_balance_types             pbt_pri,
             pay_balance_types             pbt_sec,
             pay_balance_types_tl          pbtl,
             pay_run_balances              prb,
             pay_assignment_actions        paa,
             pay_action_interlocks         pai,
             pay_payroll_actions           ppa
      WHERE  pbad.attribute_name IN ('Employee Earnings',
                                     'Hourly Earnings',
                                     'Deductions',
                                     'Taxable Benefits'
--                            ,'Employee Taxes',
--                             'Tax Calculation Details'
                              )
        AND  pbad.legislation_code    = 'MX'
        AND  pba.attribute_id         = pbad.attribute_id
        AND  pdb.defined_balance_id   = pba.defined_balance_id
        AND  prb.defined_balance_id   = pdb.defined_balance_id
        AND  pbt_pri.balance_type_id  = pdb.balance_type_id
        AND  pbt_pri.input_value_id   IS NOT NULL
        AND  pbt_pri.balance_type_id  = pbtl.balance_type_id
        AND  pbtl.language            = USERENV('LANG')
        AND  pbt_pri.balance_type_id  = pbt_sec.base_balance_type_id(+)
        AND  prb.assignment_id        = cp_assignment_id
        AND  paa.assignment_id        = prb.assignment_id
        AND  cp_sepchk_flag = 'N'
        AND  pai.locking_action_id    = cp_pymt_action_id
        AND  prb.assignment_action_id = pai.locked_action_id
        AND  prb.assignment_action_id = paa.assignment_action_id
        AND  paa.action_sequence     <= cp_ytd_act_sequence
        AND  paa.action_sequence      = prb.action_sequence
        AND  ppa.payroll_action_id    = paa.payroll_action_id
      ORDER BY 1;

    CURSOR c_cur_action_elements_RR(cp_pymt_action_id   IN NUMBER
                                   ,cp_assignment_id    IN NUMBER
                                   ,cp_sepchk_flag      IN VARCHAR2
                                   ,cp_ytd_act_sequence IN NUMBER
                                   ) IS
      SELECT DISTINCT
             NVL(pbtl.reporting_name, pbtl.balance_name),
             pbad.attribute_name,
             pbt_pri.balance_type_id,          -- Primary Balance
             DECODE(pbad.attribute_name,
                   'Hourly Earnings', pbt_sec.balance_type_id,
                   NULL),                      -- Hours Balance
             DECODE(pbad.attribute_name,
                   'Employee Earnings', pbt_sec.balance_type_id,
                   NULL)                       -- Days Balance
        FROM pay_bal_attribute_definitions pbad,
             pay_balance_attributes        pba,
             pay_defined_balances          pdb,
             pay_balance_types             pbt_pri,
             pay_balance_types             pbt_sec,
             pay_balance_types_tl          pbtl,
             pay_run_results               prr,
             pay_input_values_f            piv,
             pay_assignment_actions        paa,
             pay_action_interlocks         pai,
             pay_payroll_actions           ppa
      WHERE  pbad.attribute_name IN ('Employee Earnings',
                                     'Hourly Earnings',
                                     'Deductions',
                                     'Taxable Benefits'
--                            ,'Employee Taxes',
--                             'Tax Calculation Details'
                              )
        AND  pbad.legislation_code    = 'MX'
        AND  pba.attribute_id         = pbad.attribute_id
        AND  pdb.defined_balance_id   = pba.defined_balance_id
        AND  pbt_pri.balance_type_id  = pdb.balance_type_id
--        AND  pbt_pri.input_value_id   IS NOT NULL
        AND  pbt_pri.input_value_id = piv.input_value_id
        AND  piv.element_type_id    = prr.element_type_id
        AND  ppa.effective_date  BETWEEN piv.effective_start_date
                                     AND piv.effective_end_date
        AND  pbt_pri.balance_type_id  = pbtl.balance_type_id
        AND  pbtl.language            = USERENV('LANG')
        AND  pbt_pri.balance_type_id  = pbt_sec.base_balance_type_id(+)
        AND  paa.assignment_id        = cp_assignment_id
        AND  cp_sepchk_flag = 'N'
        AND  pai.locking_action_id    = cp_pymt_action_id
        AND  paa.assignment_action_id = pai.locked_action_id
        AND  prr.assignment_action_id = paa.assignment_action_id
        AND  paa.action_sequence     <= cp_ytd_act_sequence
        AND  ppa.payroll_action_id    = paa.payroll_action_id
      ORDER BY 1;


  CURSOR c_ytd_action_seq(cp_asg_act_id IN NUMBER) IS
    SELECT  paa.action_sequence
    FROM    pay_assignment_actions paa
    WHERE   paa.assignment_action_id = cp_asg_act_id;

  CURSOR c_business_grp_id IS
    SELECT DISTINCT business_group_id
      FROM per_assignments_f
     WHERE assignment_id = p_assignment_id;

    ln_element_type_id             NUMBER;
    lv_element_classification_name VARCHAR2(80);
    lv_reporting_name              VARCHAR2(80);
    lv_attribute_name              VARCHAR2(80);
    ln_primary_balance_id          NUMBER;
    ln_hours_balance_id            NUMBER;
    ln_days_balance_id             NUMBER;
    ln_processing_priority         NUMBER;
    ln_ytd_action_sequence         NUMBER;

    ln_element_index               NUMBER ;
    lv_procedure_name              VARCHAR2(100);
    lv_error_message               VARCHAR2(200);
    ln_step                        NUMBER;

    st_cnt                         NUMBER;
    end_cnt                        NUMBER;
    lv_business_grp_id             NUMBER;
    lv_run_bal_status              VARCHAR2(1);

  BEGIN
      lv_procedure_name  := '.get_current_elements';

      ln_step := 1;
      hr_utility.set_location(gv_package || lv_procedure_name, 10);
      hr_utility.trace('p_xfr_action_id = ' || p_xfr_action_id);
      hr_utility.trace('p_assignment_id '   || p_assignment_id);
      hr_utility.trace('p_tax_unit_id '     || p_tax_unit_id);
      hr_utility.trace('p_sepchk_flag '     || p_sepchk_flag);
      hr_utility.trace('p_legislation_code '|| p_legislation_code);
      hr_utility.trace('p_curr_pymt_action_id  '
                     ||to_char(p_curr_pymt_action_id ));
      hr_utility.trace('p_ytd_balcall_aaid '  || p_ytd_balcall_aaid);
      hr_utility.trace('p_pymt_balcall_aaid ' ||p_pymt_balcall_aaid);
      hr_utility.set_location(gv_package || lv_procedure_name, 20);

      lv_run_bal_status := NULL;

      ln_step := 6;
      OPEN  c_ytd_action_seq(p_ytd_balcall_aaid);
      FETCH c_ytd_action_seq INTO ln_ytd_action_sequence;
      CLOSE c_ytd_action_seq;

      IF run_bal_stat.COUNT >0 THEN
         st_cnt := run_bal_stat.FIRST;
         end_cnt := run_bal_stat.LAST;
         FOR i IN st_cnt..end_cnt LOOP
            IF run_bal_stat(i).valid_status = 'N' THEN
               lv_run_bal_status := 'N';
               EXIT;
            END IF;
         END LOOP;
      ELSE
         ln_step := 7;
         OPEN c_business_grp_id;
         FETCH c_business_grp_id INTO lv_business_grp_id;
         CLOSE c_business_grp_id;

         run_bal_stat(1).attribute_name := 'Employee Earnings';
         run_bal_stat(2).attribute_name := 'Hourly Earnings';
         run_bal_stat(3).attribute_name := 'Deductions';
         run_bal_stat(4).attribute_name := 'Employee Taxes';
         run_bal_stat(5).attribute_name := 'Tax Calculation Details';
         run_bal_stat(6).attribute_name := 'Taxable Benefits';

         st_cnt := run_bal_stat.FIRST;
         end_cnt := run_bal_stat.LAST;

         FOR i IN st_cnt..end_cnt LOOP
            ln_step := 8;
            run_bal_stat(i).valid_status := pay_us_payroll_utils.check_balance_status(
                                                     p_curr_pymt_eff_date,
                                                     lv_business_grp_id,
                                                     run_bal_stat(i).attribute_name,
                                                     p_legislation_code);
            IF (lv_run_bal_status IS NULL AND run_bal_stat(i).valid_status = 'N') THEN
               lv_run_bal_status := 'N';
            END IF;
         END LOOP;
      END IF;

      IF lv_run_bal_status IS NULL THEN
         lv_run_bal_status := 'Y';
      END IF;

      ln_step := 10;
      IF p_sepchk_flag = 'Y' THEN

         IF lv_run_bal_status = 'N' THEN
             OPEN c_cur_sp_action_elements_RR(p_curr_pymt_action_id,
                                              p_assignment_id,
                                              p_sepchk_flag);

         ELSE
             OPEN c_cur_sp_action_elements(p_curr_pymt_action_id,
                                           p_assignment_id,
                                           p_sepchk_flag);
         END IF;

      ELSIF p_sepchk_flag = 'N' THEN

         IF lv_run_bal_status = 'N' THEN
             OPEN c_cur_action_elements_RR(p_curr_pymt_action_id,
                                           p_assignment_id,
                                           p_sepchk_flag,
                                           ln_ytd_action_sequence);

         ELSE

             OPEN c_cur_action_elements(p_curr_pymt_action_id,
                                        p_assignment_id,
                                        p_sepchk_flag,
                                        ln_ytd_action_sequence);
         END IF;

      END IF;

      LOOP
         IF p_sepchk_flag = 'Y' THEN
             IF lv_run_bal_status = 'N' THEN

                 FETCH c_cur_sp_action_elements_RR INTO
                                  lv_reporting_name,
                                  lv_attribute_name,
                                  ln_primary_balance_id,
                                  ln_hours_balance_id,
                                  ln_days_balance_id;

                 IF c_cur_sp_action_elements_RR%NOTFOUND THEN
                   hr_utility.set_location(gv_package || lv_procedure_name, 25);
                   EXIT;
                 END IF;

             ELSE

                 FETCH c_cur_sp_action_elements INTO
                                  lv_reporting_name,
                                  lv_attribute_name,
                                  ln_primary_balance_id,
                                  ln_hours_balance_id,
                                  ln_days_balance_id;

                 IF c_cur_sp_action_elements%NOTFOUND THEN
                   hr_utility.set_location(gv_package || lv_procedure_name, 30);
                   EXIT;
                 END IF;

             END IF;

         ELSIF p_sepchk_flag = 'N' THEN
             IF lv_run_bal_status = 'N' THEN

                 FETCH c_cur_action_elements_RR INTO
                                  lv_reporting_name,
                                  lv_attribute_name,
                                  ln_primary_balance_id,
                                  ln_hours_balance_id,
                                  ln_days_balance_id;

                IF c_cur_action_elements_RR%NOTFOUND THEN
                   hr_utility.set_location(gv_package || lv_procedure_name, 33);
                   EXIT;
                 END IF;

             ELSE

                 FETCH c_cur_action_elements INTO
                                  lv_reporting_name,
                                  lv_attribute_name,
                                  ln_primary_balance_id,
                                  ln_hours_balance_id,
                                  ln_days_balance_id;

                IF c_cur_action_elements%NOTFOUND THEN
                   hr_utility.set_location(gv_package || lv_procedure_name, 36);
                   EXIT;
                 END IF;

             END IF;

         END IF;

         hr_utility.set_location(gv_package  || lv_procedure_name, 40);
         hr_utility.trace('Primary Bal id = '|| ln_primary_balance_id);

         ln_step := 15;
         ln_element_index := pay_ac_action_arch.emp_elements_tab.count;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_primary_balance_id
                  := ln_primary_balance_id;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_reporting_name
                  := lv_reporting_name;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_hours_balance_id
                  := ln_hours_balance_id;

         hr_utility.set_location(gv_package  || lv_procedure_name, 50);
         ln_step := 20;

         populate_elements(p_xfr_action_id             => p_xfr_action_id
                          ,p_pymt_assignment_action_id => p_curr_pymt_action_id
                          ,p_pymt_eff_date             => p_curr_pymt_eff_date
                          ,p_primary_balance_id        => ln_primary_balance_id
                          ,p_hours_balance_id          => ln_hours_balance_id
                          ,p_days_balance_id           => ln_days_balance_id
                          ,p_attribute_name            => lv_attribute_name
                          ,p_reporting_name            => lv_reporting_name
                          ,p_tax_unit_id               => p_tax_unit_id
                          ,p_pymt_balcall_aaid         => p_pymt_balcall_aaid
                          ,p_ytd_balcall_aaid          => p_ytd_balcall_aaid
                          ,p_legislation_code          => p_legislation_code
                          ,p_sepchk_flag               => p_sepchk_flag
                          ,p_action_type               => p_action_type
                          );
      END LOOP;
      IF p_sepchk_flag = 'Y' THEN
         IF lv_run_bal_status = 'N' THEN
             CLOSE c_cur_sp_action_elements_RR;
         ELSE
             CLOSE c_cur_sp_action_elements;
         END IF;
      ELSIF p_sepchk_flag = 'N' THEN
         IF lv_run_bal_status = 'N' THEN
             CLOSE c_cur_action_elements_RR;
         ELSE
             CLOSE c_cur_action_elements;
         END IF;
      END IF;
      hr_utility.set_location(gv_package  || lv_procedure_name, 60);
      ln_step := 25;

  EXCEPTION
   WHEN OTHERS THEN
      lv_error_message := 'Error at step ' || ln_step ||
                          ' IN ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_current_elements;


  PROCEDURE first_time_process(p_assignment_id       IN NUMBER
                              ,p_xfr_action_id       IN NUMBER
                              ,p_curr_pymt_action_id IN NUMBER
                              ,p_curr_pymt_eff_date  IN DATE
                              ,p_curr_eff_date       IN DATE
                              ,p_tax_unit_id         IN NUMBER
                              ,p_ytd_balcall_aaid    IN NUMBER
                              ,p_pymt_balcall_aaid   IN NUMBER
                              ,p_sepchk_flag         IN VARCHAR2
                              ,p_legislation_code    IN VARCHAR2
                              )

  IS

   lv_element_classification_name VARCHAR2(80);
   ln_processing_priority         NUMBER;
   lv_reporting_name              VARCHAR2(80);
   lv_attribute_name              VARCHAR2(80);
   ln_element_type_id             NUMBER;
   lv_jurisdiction_code           VARCHAR2(80);
   ln_primary_balance_id          NUMBER;
   ln_hours_balance_id            NUMBER;
   ln_days_balance_id             NUMBER;

   ln_element_index               NUMBER ;
   lv_element_archived            VARCHAR2(1);
   lv_procedure_name              VARCHAR2(100);
   lv_error_message               VARCHAR2(200);
   ln_step                        NUMBER;

   i                              NUMBER;
   st_cnt                         NUMBER;
   end_cnt                        NUMBER;
   lv_business_grp_id             NUMBER;
   lv_run_bal_status              VARCHAR2(1);

   CURSOR c_business_grp_id IS
      SELECT DISTINCT business_group_id
        FROM per_assignments_f
       WHERE assignment_id = p_assignment_id;

   CURSOR c_prev_ytd_action_elem_rbr(cp_assignment_id IN NUMBER
                                    ,cp_curr_eff_date IN DATE
                                    ) IS
   SELECT DISTINCT
          pbad.attribute_name,
          NVL(pbtl.reporting_name, pbtl.balance_name),
          prb.jurisdiction_code,
          pbt_pri.balance_type_id,        -- Primary Balance
          DECODE(pbad.attribute_name,
                 'Hourly Earnings', pbt_sec.balance_type_id,
                 NULL),                   -- Hours Balance
          DECODE(pbad.attribute_name,
                 'Employee Earnings', pbt_sec.balance_type_id,
                 NULL)                    -- Days Balance
   FROM   pay_bal_attribute_definitions pbad,
          pay_balance_attributes        pba,
          pay_defined_balances          pdb,
          pay_balance_types             pbt_pri,
          pay_balance_types             pbt_sec,
          pay_balance_types_tl          pbtl,
          pay_run_balances              prb
   WHERE  pbad.attribute_name IN ('Employee Earnings',
                                  'Hourly Earnings',
                                  'Deductions',
                                  'Taxable Benefits'
--                               ,'Employee Taxes',
--                                'Tax Calculation Details'
                                 )
     AND  pbad.legislation_code  = 'MX'
     AND  pba.attribute_id       = pbad.attribute_id
     AND  pdb.defined_balance_id = pba.defined_balance_id
     AND  pbt_pri.balance_type_id = pdb.balance_type_id
     AND  pbt_pri.input_value_id IS NOT NULL
     AND  pbtl.balance_type_id   = pbt_pri.balance_type_id
     AND  pbtl.language          = USERENV('LANG')
     AND  pbt_pri.balance_type_id  = pbt_sec.base_balance_type_id(+)
     AND  prb.effective_date    >= trunc(cp_curr_eff_date,'Y')
     AND  prb.effective_date    <= cp_curr_eff_date
     AND  prb.assignment_id      = cp_assignment_id
     AND  pdb.defined_balance_id = prb.defined_balance_id
   ORDER BY 1;


  CURSOR c_prev_ytd_action_elements(cp_assignment_id IN NUMBER
                                   ,cp_curr_eff_date IN DATE
                                 ) IS
   SELECT DISTINCT
          pbad.attribute_name,
          NVL(pbtl.reporting_name, pbtl.balance_name),
          prr.jurisdiction_code,
          pbt_pri.balance_type_id,        -- Primary Balance
          DECODE(pbad.attribute_name,
                 'Hourly Earnings', pbt_sec.balance_type_id,
                 NULL),                   -- Hours Balance
          DECODE(pbad.attribute_name,
                 'Employee Earnings', pbt_sec.balance_type_id,
                 NULL)                    -- Days Balance
   FROM   pay_bal_attribute_definitions pbad,
          pay_balance_attributes        pba,
          pay_defined_balances          pdb,
          pay_balance_types             pbt_pri,
          pay_balance_types             pbt_sec,
          pay_balance_types_tl          pbtl,
          pay_assignment_actions        paa,
          pay_payroll_actions           ppa,
          pay_run_results               prr,
          pay_input_values_f            piv
   WHERE  pbad.attribute_name IN ('Employee Earnings',
                                  'Hourly Earnings',
                                  'Deductions',
                                  'Taxable Benefits'
--                               ,'Employee Taxes',
--                                'Tax Calculation Details'
                                 )
     AND  pbad.legislation_code  = 'MX'
     AND  pba.attribute_id       = pbad.attribute_id
     AND  pdb.defined_balance_id = pba.defined_balance_id
     AND  pbt_pri.balance_type_id = pdb.balance_type_id
     AND  pbt_pri.input_value_id = piv.input_value_id
     AND  piv.element_type_id = prr.element_type_id
     AND  ppa.effective_date BETWEEN piv.effective_start_date
                                 AND piv.effective_end_date
     AND  pbtl.balance_type_id   = pbt_pri.balance_type_id
     AND  pbtl.language          = USERENV('LANG')
     AND  pbt_pri.balance_type_id  = pbt_sec.base_balance_type_id(+)
     AND  prr.assignment_action_id = paa.assignment_action_id
     AND  paa.assignment_id       = cp_assignment_id
     AND  ppa.payroll_action_id   = paa.payroll_action_id
     AND  ppa.action_type in ('Q','R','B')
     AND  ppa.effective_date >= TRUNC(cp_curr_eff_date,'Y')
     AND  ppa.effective_date <= cp_curr_eff_date
ORDER BY 1;

  BEGIN
      ln_step := 1;
      lv_run_bal_status := NULL;
      lv_element_archived := 'N';
      lv_procedure_name := '.first_time_process';

      hr_utility.set_location(gv_package || lv_procedure_name, 10);
      hr_utility.trace('p_xfr_action_id' || p_xfr_action_id);
      hr_utility.trace('p_assignment_id '|| p_assignment_id);
      hr_utility.trace('p_curr_eff_date '|| p_curr_eff_date);
      hr_utility.trace('p_tax_unit_id '  || p_tax_unit_id);
      hr_utility.trace('p_sepchk_flag '  || p_sepchk_flag);
      hr_utility.trace('p_legislation_code '  || p_legislation_code);
      hr_utility.trace('p_ytd_balcall_aaid '  || p_ytd_balcall_aaid);
      hr_utility.trace('p_pymt_balcall_aaid ' || p_pymt_balcall_aaid);
      hr_utility.trace('p_curr_pymt_action_id  '
                     ||to_char(p_curr_pymt_action_id ));

      hr_utility.set_location(gv_package || lv_procedure_name, 20);
      get_current_elements(p_xfr_action_id        => p_xfr_action_id
                          ,p_curr_pymt_action_id  => p_curr_pymt_action_id
                          ,p_curr_pymt_eff_date   => p_curr_pymt_eff_date
                          ,p_assignment_id        => p_assignment_id
                          ,p_tax_unit_id          => p_tax_unit_id
                          ,p_sepchk_flag          => p_sepchk_flag
                          ,p_pymt_balcall_aaid    => p_pymt_balcall_aaid
                          ,p_ytd_balcall_aaid     => p_ytd_balcall_aaid
                          ,p_legislation_code     => p_legislation_code);
      hr_utility.set_location(gv_package  || lv_procedure_name, 30);

-- Populating the PL/SQL table run_bal_stat_tab with the validity status
-- of various attributes. If already populated, we use that to check the
-- validity

      IF run_bal_stat.COUNT >0 THEN
         st_cnt := run_bal_stat.FIRST;
         end_cnt := run_bal_stat.LAST;
         FOR i IN st_cnt..end_cnt LOOP
            IF run_bal_stat(i).valid_status = 'N' THEN
               lv_run_bal_status := 'N';
               EXIT;
            END IF;
         END LOOP;
      ELSE
         OPEN c_business_grp_id;
         FETCH c_business_grp_id INTO lv_business_grp_id;
         CLOSE c_business_grp_id;

         run_bal_stat(1).attribute_name := 'Employee Earnings';
         run_bal_stat(2).attribute_name := 'Hourly Earnings';
         run_bal_stat(3).attribute_name := 'Deductions';
         run_bal_stat(4).attribute_name := 'Employee Taxes';
         run_bal_stat(5).attribute_name := 'Tax Calculation Details';
         run_bal_stat(6).attribute_name := 'Taxable Benefits';

         st_cnt := run_bal_stat.FIRST;
         end_cnt := run_bal_stat.LAST;

         FOR i IN st_cnt..end_cnt LOOP
            run_bal_stat(i).valid_status := pay_us_payroll_utils.check_balance_status(
                                                     p_curr_pymt_eff_date,
                                                     lv_business_grp_id,
                                                     run_bal_stat(i).attribute_name,
                                                     p_legislation_code);
            IF (lv_run_bal_status IS NULL AND run_bal_stat(i).valid_status = 'N') THEN
               lv_run_bal_status := 'N';
            END IF;
         END LOOP;
      END IF;

      IF lv_run_bal_status IS NULL THEN
         lv_run_bal_status := 'Y';
      END IF;

      ln_step := 5;


      IF lv_run_bal_status = 'Y' THEN
         OPEN c_prev_ytd_action_elem_rbr(p_assignment_id,
                                         p_curr_pymt_eff_date);
      ELSE
         OPEN c_prev_ytd_action_elements(p_assignment_id,
                                         p_curr_pymt_eff_date);
      END IF;

     LOOP
         IF lv_run_bal_status = 'Y' THEN
            FETCH c_prev_ytd_action_elem_rbr INTO
                               lv_attribute_name,
                               lv_reporting_name,
                               lv_jurisdiction_code,
                               ln_primary_balance_id,
                               ln_hours_balance_id,
                               ln_days_balance_id;

            IF c_prev_ytd_action_elem_rbr%NOTFOUND THEN
               hr_utility.set_location(gv_package || lv_procedure_name, 40);
               EXIT;
            END IF;
         ELSE
            FETCH c_prev_ytd_action_elements INTO
                               lv_attribute_name,
                               lv_reporting_name,
                               lv_jurisdiction_code,
                               ln_primary_balance_id,
                               ln_hours_balance_id,
                               ln_days_balance_id;

            IF c_prev_ytd_action_elements%NOTFOUND THEN
               hr_utility.set_location(gv_package || lv_procedure_name, 45);
               EXIT;
            END IF;
         END IF;

         hr_utility.set_location(gv_package  || lv_procedure_name, 50);
         hr_utility.trace('Reporting Name = '|| lv_reporting_name);
         hr_utility.trace('Primary Bal id = '|| ln_primary_balance_id);
         hr_utility.trace('JD Code = '       || lv_jurisdiction_code);

         IF lv_attribute_name IN ('Deductions',
                                  'Employee Taxes',
                                  'Tax Calculation Details') THEN
            ln_step := 10;
            ln_hours_balance_id := NULL;
            ln_days_balance_id  := NULL;

         END IF;

         /**********************************************************
         ** check whether the element has already been archived
         ** when archiving the Current Action. If it has been archived
         ** skip the element
         **********************************************************/
         ln_step := 15;
         FOR i IN pay_ac_action_arch.emp_elements_tab.first ..
                  pay_ac_action_arch.emp_elements_tab.last LOOP

               IF pay_ac_action_arch.emp_elements_tab(i).element_primary_balance_id
                       = ln_primary_balance_id AND
                  NVL(pay_ac_action_arch.emp_elements_tab(i).jurisdiction_code,
                      -999)   =    NVL(lv_jurisdiction_code, -999) THEN

                  hr_utility.set_location(gv_package  || lv_procedure_name, 65);
                  lv_element_archived := 'Y';
                  EXIT;
               END IF;
         END LOOP;

         IF lv_element_archived = 'N' THEN
            ln_step := 20;
            hr_utility.set_location(gv_package  || lv_procedure_name, 70);
            ln_element_index := pay_ac_action_arch.emp_elements_tab.count;
            pay_ac_action_arch.emp_elements_tab(ln_element_index).element_reporting_name
                        := lv_reporting_name;
            pay_ac_action_arch.emp_elements_tab(ln_element_index).element_primary_balance_id
                        := ln_primary_balance_id;
            pay_ac_action_arch.emp_elements_tab(ln_element_index).element_hours_balance_id
                        := ln_hours_balance_id;
            pay_ac_action_arch.emp_elements_tab(ln_element_index).jurisdiction_code
                        := lv_jurisdiction_code;

            /*****************************************************************
            ** The Payment Assignemnt Action is not passed to this procedure
            ** as we do not want to call the Payment Balance.
            *****************************************************************/
            hr_utility.set_location(gv_package || lv_procedure_name, 80);

            ln_step := 25;
            populate_elements(p_xfr_action_id             => p_xfr_action_id
                             ,p_pymt_assignment_action_id => p_curr_pymt_action_id
                             ,p_pymt_eff_date             => p_curr_pymt_eff_date
                             ,p_primary_balance_id        => ln_primary_balance_id
                             ,p_hours_balance_id          => ln_hours_balance_id
                             ,p_days_balance_id           => ln_days_balance_id
                             ,p_attribute_name            => lv_attribute_name
                             ,p_reporting_name            => lv_reporting_name
                             ,p_tax_unit_id               => p_tax_unit_id
                             ,p_pymt_balcall_aaid         => NULL
                             ,p_ytd_balcall_aaid          => p_ytd_balcall_aaid
                             ,p_jurisdiction_code         => lv_jurisdiction_code
                             ,p_legislation_code          => p_legislation_code
                             ,p_sepchk_flag               => p_sepchk_flag
                             );
         END IF;
         lv_element_archived := 'N'; -- Initilializing the variable back
                                     -- to N FOR the next element
         lv_jurisdiction_code    := NULL;
         ln_primary_balance_id   := NULL;
         lv_reporting_name       := NULL;
         ln_hours_balance_id     := NULL;
      END LOOP;

      IF lv_run_bal_status = 'Y' THEN
         CLOSE c_prev_ytd_action_elem_rbr;
      ELSE
         CLOSE c_prev_ytd_action_elements;
      END IF;

      hr_utility.set_location(gv_package || lv_procedure_name, 90);


      ln_step := 30;
      IF pay_ac_action_arch.lrr_act_tab.count > 0 THEN
         FOR i IN pay_ac_action_arch.lrr_act_tab.first ..
                  pay_ac_action_arch.lrr_act_tab.last LOOP

             hr_utility.trace('after populate_elements ftp' ||
                 ' action_context_id IS '                   ||
                 to_char(pay_ac_action_arch.lrr_act_tab(i).action_context_id));
             hr_utility.trace('action_info_category '       ||
                  pay_ac_action_arch.lrr_act_tab(i).action_info_category);
              hr_utility.trace('act_info1 IS '              ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info1);
              hr_utility.trace('act_info10 '                 ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info10);
              hr_utility.trace('act_info3 '                 ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info3);
              hr_utility.trace('act_info4 '                 ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info4);
              hr_utility.trace('act_info5 '                 ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info5);
              hr_utility.trace('act_info6 '                 ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info6);
              hr_utility.trace('act_info7 '                 ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info7);
              hr_utility.trace('act_info8 '                 ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info8);

         END LOOP;
      END IF;

      hr_utility.set_location(gv_package  || lv_procedure_name, 110);


   EXCEPTION
    WHEN OTHERS THEN

      lv_error_message := 'Error at step ' || ln_step ||
                          ' IN ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END first_time_process;


  /******************************************************************
   Name      : range_code
   Purpose   : This returns the select statement that is
               used to created the range rows for the Payslip
               Archiver.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ******************************************************************/
  PROCEDURE range_code(
                    p_payroll_action_id IN        NUMBER
                   ,p_sqlstr           OUT NOCOPY VARCHAR2)
  IS

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_cons_set_id       NUMBER;
    ln_payroll_id        NUMBER;

    lv_sql_string        VARCHAR2(32000);
    lv_procedure_name    VARCHAR2(100);

  BEGIN
     lv_procedure_name  := '.range_code';

     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_cons_set_id       => ln_cons_set_id
                            ,p_payroll_id        => ln_payroll_id);
     hr_utility.set_location(gv_package || lv_procedure_name, 20);

     lv_sql_string :=
         'SELECT DISTINCT paf.person_id
            FROM pay_assignment_actions paa,
                 pay_payroll_actions ppa,
                 per_assignments_f paf
           WHERE ppa.business_group_id  = ''' || ln_business_group_id || '''
             AND  ppa.effective_date BETWEEN fnd_date.canonical_to_date(''' ||
             fnd_date.date_to_canonical(ld_start_date) || ''')
                                         AND fnd_date.canonical_to_date(''' ||
             fnd_date.date_to_canonical(ld_end_date) || ''')
             AND ppa.action_type IN (''U'',''P'',''B'',''V'')
             AND DECODE(ppa.action_type,
                 ''B'', NVL(ppa.future_process_mode, ''Y''),
                 ''N'') = ''N''
             AND ppa.consolidation_set_id = ''' || ln_cons_set_id || '''
             AND ppa.payroll_id  = ''' || ln_payroll_id || '''
             AND ppa.payroll_action_id = paa.payroll_action_id
             AND paa.action_status = ''C''
             AND paa.source_action_id IS NULL
             AND paf.assignment_id = paa.assignment_id
             AND ppa.effective_date BETWEEN paf.effective_start_date
                                        AND paf.effective_end_date
             AND NOT EXISTS
                 (SELECT ''x''
                    FROM pay_action_interlocks pai,
                         pay_assignment_actions paa1,
                         pay_payroll_actions ppa1
                   WHERE pai.locked_action_id = paa.assignment_action_id
                   AND paa1.assignment_action_id = pai.locking_action_id
                   AND ppa1.payroll_action_id = paa1.payroll_action_id
                   AND ppa1.action_type =''X''
                   AND ppa1.report_type = ''MX_PAYSLIP_ARCHIVE'')
            AND :payroll_action_id > 0 -- Bug 4202702
          ORDER BY paf.person_id';

     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     p_sqlstr := lv_sql_string;
     hr_utility.set_location(gv_package || lv_procedure_name, 50);

  END range_code;


  /************************************************************
   Name      : assignment_action_code
   Purpose   : This creates the assignment actions for
               a specific chunk of people to be archived
               by the Archiver process.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ************************************************************/
  PROCEDURE assignment_action_code(
                 p_payroll_action_id IN NUMBER
                ,p_start_person_id   IN NUMBER
                ,p_end_person_id     IN NUMBER
                ,p_chunk             IN NUMBER)
  IS

   CURSOR c_get_arch_emp( cp_start_person_id     IN NUMBER
                         ,cp_end_person_id       IN NUMBER
                         ,cp_cons_set_id         IN NUMBER
                         ,cp_payroll_id          IN NUMBER
                         ,cp_business_group_id   IN NUMBER
                         ,cp_start_date          IN DATE
                         ,cp_end_date            IN DATE
                         ) IS
     SELECT paa.assignment_id,
            paa.tax_unit_id,
            ppa.effective_date,
            ppa.date_earned,
            ppa.action_type,
            paa.assignment_action_id,
            paa.payroll_action_id
       FROM pay_payroll_actions ppa,
            pay_assignment_actions paa,
            per_assignments_f paf
     WHERE paf.person_id BETWEEN cp_start_person_id
                             AND cp_end_person_id
       AND paa.assignment_id = paf.assignment_id
       AND ppa.effective_date BETWEEN paf.effective_start_date
                                  AND paf.effective_end_date
       AND ppa.consolidation_set_id
              = NVL(cp_cons_set_id,ppa.consolidation_set_id)
       AND paa.action_status = 'C'
       AND ppa.payroll_id = cp_payroll_id
       AND ppa.payroll_action_id = paa.payroll_action_id
       AND ppa.business_group_id  = cp_business_group_id
       AND ppa.effective_date BETWEEN cp_start_date
                                  AND cp_end_date
       AND ppa.action_type IN ('U','P','B','V')
       AND DECODE(ppa.action_type,
                 'B', NVL(ppa.future_process_mode, 'Y'),
                 'N') = 'N'
       AND paa.source_action_id IS NULL
       AND NOT EXISTS
           (SELECT 'x'
              FROM pay_action_interlocks pai1,
                   pay_assignment_actions paa1,
                   pay_payroll_actions ppa1
             WHERE pai1.locked_action_id = paa.assignment_action_id
             AND paa1.assignment_action_id = pai1.locking_action_id
             AND ppa1.payroll_action_id = paa1.payroll_action_id
             AND ppa1.action_type ='X'
             AND ppa1.report_type = 'MX_PAYSLIP_ARCHIVE')
      ORDER BY 1,2,3,5,6;

   CURSOR c_get_arch_range_emp(
                          cp_payroll_action_id   IN NUMBER
                         ,cp_chunk_number        IN NUMBER
                         ,cp_cons_set_id         IN NUMBER
                         ,cp_payroll_id          IN NUMBER
                         ,cp_business_group_id   IN NUMBER
                         ,cp_start_date          IN DATE
                         ,cp_end_date            IN DATE
                         ) IS
     SELECT paa.assignment_id,
            paa.tax_unit_id,
            ppa.effective_date,
            ppa.date_earned,
            ppa.action_type,
            paa.assignment_action_id,
            paa.payroll_action_id
       FROM pay_payroll_actions ppa,
            pay_assignment_actions paa,
            per_assignments_f paf,
            pay_population_ranges ppr
      WHERE ppr.payroll_action_id = cp_payroll_action_id
        AND ppr.chunk_number = cp_chunk_number
        AND paf.person_id = ppr.person_id
        AND ppa.effective_date BETWEEN paf.effective_start_date
                                   AND paf.effective_end_date
        AND paa.assignment_id = paf.assignment_id
        AND ppa.consolidation_set_id
              = NVL(cp_cons_set_id,ppa.consolidation_set_id)
        AND paa.action_status = 'C'
        AND ppa.payroll_id = cp_payroll_id
        AND ppa.payroll_action_id = paa.payroll_action_id
        AND ppa.business_group_id  = cp_business_group_id
        AND ppa.effective_date BETWEEN cp_start_date
                                   AND cp_end_date
        AND ppa.action_type IN ('U','P','B','V')
        AND DECODE(ppa.action_type,
                  'B', NVL(ppa.future_process_mode, 'Y'),
                  'N') = 'N'
        AND paa.source_action_id IS NULL
        AND NOT EXISTS
            (SELECT 'x'
               FROM pay_action_interlocks pai1,
                    pay_assignment_actions paa1,
                    pay_payroll_actions ppa1
              WHERE pai1.locked_action_id = paa.assignment_action_id
              AND paa1.assignment_action_id = pai1.locking_action_id
              AND ppa1.payroll_action_id = paa1.payroll_action_id
              AND ppa1.action_type ='X'
              AND ppa1.report_type = 'MX_PAYSLIP_ARCHIVE')
      ORDER BY 1,2,3,5,6;

   CURSOR c_master_action(cp_prepayment_action_id NUMBER) IS
     SELECT MAX(paa.assignment_action_id)
       FROM pay_payroll_actions ppa,
            pay_assignment_actions paa,
            pay_action_interlocks pai
      WHERE pai.locking_action_Id =  cp_prepayment_action_id
        AND paa.assignment_action_id = pai.locked_action_id
        AND paa.source_action_id IS NULL
        AND ppa.payroll_action_id = paa.payroll_action_id
        AND ppa.action_type IN ('R', 'Q');

    ln_assignment_id        NUMBER := 0;
    ln_tax_unit_id          NUMBER := 0;
    ld_effective_date       DATE;
    ld_date_earned          DATE;
    lv_action_type          VARCHAR2(10);
    ln_asg_action_id        NUMBER := 0;
    ln_payroll_action_id    NUMBER := 0;

    ln_master_action_id     NUMBER := 0;

    ld_end_date             DATE;
    ld_start_date           DATE;
    ln_business_group_id    NUMBER;
    ln_cons_set_id          NUMBER;
    ln_payroll_id           NUMBER;

    ln_prev_asg_action_id   NUMBER := 0;
    ln_prev_assignment_id   NUMBER := 0;
    ln_prev_tax_unit_id     NUMBER := 0;
    ld_prev_effective_date  DATE;

    ln_xfr_action_id        NUMBER;

    lv_serial_number        VARCHAR2(30);
    lv_procedure_name       VARCHAR2(100);
    lv_error_message        VARCHAR2(200);
    ln_step                 NUMBER;

    lb_range_person         BOOLEAN;

  BEGIN
     ld_effective_date  := fnd_date.canonical_to_date('1900/12/31');
     lv_procedure_name  := '.assignment_action_code';

     ln_step := 1;
     pay_emp_action_arch.gv_error_message := NULL;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_cons_set_id       => ln_cons_set_id
                            ,p_payroll_id        => ln_payroll_id);
     hr_utility.set_location(gv_package || lv_procedure_name, 20);

     lb_range_person := pay_ac_utility.range_person_on(
                           p_report_type      => 'MX_PAYSLIP_ARCHIVE'
                          ,p_report_format    => 'MX_PAYSLIP_ARCHIVE'
                          ,p_report_qualifier => 'MX'
                          ,p_report_category  => 'ARCHIVE');

     ln_step := 2;
     IF lb_range_person THEN
        OPEN c_get_arch_range_emp(p_payroll_action_id
                                 ,p_chunk
                                 ,ln_cons_set_id
                                 ,ln_payroll_id
                                 ,ln_business_group_id
                                 ,ld_start_date
                                 ,ld_end_date);
     ELSE
        OPEN c_get_arch_emp( p_start_person_id
                            ,p_end_person_id
                            ,ln_cons_set_id
                            ,ln_payroll_id
                            ,ln_business_group_id
                            ,ld_start_date
                            ,ld_end_date);
     END IF;

     -- Loop for all rows returned for SQL statement.
     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     LOOP
        IF lb_range_person THEN
           FETCH c_get_arch_range_emp INTO ln_assignment_id,
                                           ln_tax_unit_id,
                                           ld_effective_date,
                                           ld_date_earned,
                                           lv_action_type,
                                           ln_asg_action_id,
                                           ln_payroll_action_id;
           EXIT WHEN c_get_arch_range_emp%NOTFOUND;
        ELSE

           FETCH c_get_arch_emp INTO ln_assignment_id,
                                     ln_tax_unit_id,
                                     ld_effective_date,
                                     ld_date_earned,
                                     lv_action_type,
                                     ln_asg_action_id,
                                     ln_payroll_action_id;

           EXIT WHEN c_get_arch_emp%NOTFOUND;
        END IF;

        hr_utility.set_location(gv_package || lv_procedure_name, 40);
        hr_utility.trace('ln_assignment_id = ' ||
                             TO_CHAR(ln_assignment_id));

        /********************************************************
        ** If Balance Adjustment, only create one assignment
        ** action record. As there could be multiple assignment
        ** actions for Balance Adjustment, we lock all the
        ** balance adj record.
        ** First time the ELSE portion will be executed which
        ** creates the assignment action. If the Assignment ID,
        ** Tax Unit ID and Effective Date is same and Action
        ** Type is Balance Adjm, only then lock the record
        ********************************************************/
        IF ln_assignment_id = ln_prev_assignment_id AND
           ln_tax_unit_id = ln_prev_tax_unit_id AND
           ld_effective_date = ld_prev_effective_date AND
           lv_action_type = 'B' AND
           ln_asg_action_id <> ln_prev_asg_action_id THEN

           hr_utility.set_location(gv_package || lv_procedure_name, 50);
           hr_utility.trace('Locking Action = ' || ln_xfr_action_id);
           hr_utility.trace('Locked Action = '  || ln_asg_action_id);
           hr_nonrun_asact.insint(ln_xfr_action_id
                                 ,ln_asg_action_id);
        ELSE
           hr_utility.set_location(gv_package || lv_procedure_name, 60);
           hr_utility.trace('Action_type = '||lv_action_type );

           SELECT pay_assignment_actions_s.NEXTVAL
             INTO ln_xfr_action_id
             FROM dual;

           -- insert into pay_assignment_actions.
           hr_nonrun_asact.insact(ln_xfr_action_id,
                                  ln_assignment_id,
                                  p_payroll_action_id,
                                  p_chunk,
                                  ln_tax_unit_id,
                                  NULL,
                                  'U',
                                  NULL);
           hr_utility.set_location(gv_package || lv_procedure_name, 70);
           hr_utility.trace('ln_asg_action_id = ' || ln_asg_action_id);
           hr_utility.trace('ln_xfr_action_id = ' || ln_xfr_action_id);
           hr_utility.trace('p_payroll_action_id = ' || p_payroll_action_id);
           hr_utility.trace('ln_tax_unit_id = '   || ln_tax_unit_id);
           hr_utility.set_location(gv_package || lv_procedure_name, 80);

           -- insert an interlock to this action
           hr_utility.trace('Locking Action = ' || ln_xfr_action_id);
           hr_utility.trace('Locked Action = '  || ln_asg_action_id);
           hr_nonrun_asact.insint(ln_xfr_action_id,
                                  ln_asg_action_id);

           hr_utility.set_location(gv_package || lv_procedure_name, 90);

           /********************************************************
           ** For Balance Adj we put only the first assignment action
           ********************************************************/
           lv_serial_number := lv_action_type || 'N' ||
                               ln_asg_action_id;

           UPdate pay_assignment_actions
              SET serial_number = lv_serial_number
            WHERE assignment_action_id = ln_xfr_action_id;

           hr_utility.set_location(gv_package || lv_procedure_name, 100);

        END IF ; --ln_assignment_id ...

        ln_prev_tax_unit_id    := ln_tax_unit_id;
        ld_prev_effective_date := ld_effective_date;
        ln_prev_assignment_id  := ln_assignment_id;
        ln_prev_asg_action_id  := ln_asg_action_id;

     END LOOP;
     IF lb_range_person THEN
        CLOSE c_get_arch_range_emp;
     ELSE
        CLOSE c_get_arch_emp;
     END IF;

     ln_step := 5;

  EXCEPTION
    WHEN OTHERS THEN
      lv_error_message := 'Error at step ' || ln_step || ' IN ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END assignment_action_code;


  /************************************************************
    Name      : initialization_code
    Purpose   : This performs the context initialization.
    Arguments :
    Notes     :
  ************************************************************/

  PROCEDURE initialization_code(p_payroll_action_id IN NUMBER) IS

  CURSOR cur_def_bal IS
  SELECT NVL(pbtl.reporting_name, pbtl.balance_name) reporting_name,
         pbtl.balance_type_id,
         pbad.attribute_name
    FROM pay_bal_attribute_definitions pbad,
         pay_balance_attributes        pba,
         pay_defined_balances          pdb,
         pay_balance_types_tl          pbtl
   WHERE pbad.attribute_name IN ('Employee Taxes',
                                 'Tax Calculation Details'
                                )
     AND pbad.legislation_code    = 'MX'
     AND pba.attribute_id         = pbad.attribute_id
     AND pdb.defined_balance_id   = pba.defined_balance_id
     AND pbtl.balance_type_id     = pdb.balance_type_id
     AND pbtl.language            = USERENV('LANG')
   UNION
  SELECT balance_name reporting_name,
         balance_type_id,
         'SUMMARY'
    FROM pay_balance_types
   WHERE balance_name IN ('Gross Earnings',
                          'Tax Deductions',
                          'Deductions',
                          'Net Pay')
     AND legislation_code = 'MX';


  CURSOR cur_sepchk_run_type IS
  SELECT prt.run_type_id,
         prt.shortname
    FROM pay_run_types_f prt
   WHERE prt.run_method = 'S'
     AND prt.legislation_code = 'MX';

  CURSOR cur_bal_type IS
    SELECT balance_name,
           balance_type_id
    FROM   pay_balance_types
    WHERE  legislation_code = 'MX'
    AND    balance_name = 'Gross Earnings';
    --IN ( 'Gross Earnings', 'Total Pay' );


  ln_pymt_def_bal_id     NUMBER;
  ln_gre_ytd_def_bal_id  NUMBER;
  lv_reporting_level     VARCHAR2(30);
  lv_pymt_dimension      VARCHAR2(100);
  ln_run_def_bal_id      NUMBER;

  lv_error_message       VARCHAR2(500);
  lv_procedure_name      VARCHAR2(100);
  ln_step                NUMBER;

  ln_run_bal_type_id     NUMBER;
  lv_balance_name        VARCHAR2(100);
  lv_bal_category        pay_balance_categories_f.category_name%TYPE;
  ln_sep_chk_run_type_id NUMBER;
  lv_shortname           pay_run_types_f.shortname%TYPE;

  i   NUMBER;
  j   NUMBER;

  BEGIN
    lv_procedure_name       := '.initialization_code';
    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    pay_emp_action_arch.gv_error_message := NULL;
    lv_reporting_level := Null;
    i := 0;
    j := 0;

    ln_step := 6;
    OPEN  cur_bal_type;
    LOOP
       FETCH cur_bal_type INTO lv_balance_name, ln_run_bal_type_id;
       EXIT WHEN cur_bal_type%NOTFOUND;
--       IF lv_balance_name = 'Total Pay' THEN
--          gn_payments_def_bal_id :=
--             NVL(pay_emp_action_arch.get_defined_balance_id(
--                                             ln_run_bal_type_id,
--                                             '_ASG_GRE_RUN',
--                                             'MX'),-1);
--       ELSE
          gn_gross_earn_def_bal_id :=
             NVL(pay_emp_action_arch.get_defined_balance_id(
                                             ln_run_bal_type_id,
                                             '_ASG_GRE_RUN',
                                             'MX'),-1);
--       END IF;
    END LOOP;
    CLOSE cur_bal_type;

    ln_step := 10;
    OPEN  cur_sepchk_run_type;
    LOOP
         FETCH cur_sepchk_run_type INTO ln_sep_chk_run_type_id, lv_shortname;
         EXIT WHEN cur_sepchk_run_type%NOTFOUND;

         IF lv_shortname = 'REG_SEPPAY' THEN
            gn_sepchk_run_type_id := ln_sep_chk_run_type_id;

         ELSIF lv_shortname = 'NP_SEPPAY' THEN
            gn_np_sepchk_run_type_id := ln_sep_chk_run_type_id;

         END IF;
    END LOOP;

    ln_step := 20;
    IF pay_emp_action_arch.gv_multi_leg_rule IS NULL THEN
       pay_emp_action_arch.gv_multi_leg_rule
             := pay_emp_action_arch.get_multi_legislative_rule('MX');
    END IF;

    hr_utility.trace('lv_reporting_level : '|| lv_reporting_level);
    hr_utility.trace('gv_multi_leg_rule : ' || pay_emp_action_arch.gv_multi_leg_rule);
    hr_utility.set_location(gv_package || lv_procedure_name, 20);

    ln_step := 30;
    IF pay_emp_action_arch.gv_multi_leg_rule = 'Y' THEN
       lv_pymt_dimension      := '_ASG_PAYMENTS';
--       lv_jd_pymt_dimension   := '_ASG_PAYMENTS_JD';
    ELSE
       lv_pymt_dimension      := '_PAYMENTS';
--       lv_jd_pymt_dimension   := '_PAYMENTS_JD';
    END IF;

    ln_step := 40;
    dbt.delete;
    i := 0;

    ln_step := 50;
    FOR c_dbt IN cur_def_bal LOOP

      ln_pymt_def_bal_id     := 0;
      ln_gre_ytd_def_bal_id  := 0;
      ln_run_def_bal_id      := 0;


      ln_step := 60;
      ln_pymt_def_bal_id :=
          pay_emp_action_arch.get_defined_balance_id(
                                             c_dbt.balance_type_id,
                                             lv_pymt_dimension,
                                             'MX');

      ln_step := 70;
      ln_gre_ytd_def_bal_id :=
          pay_emp_action_arch.get_defined_balance_id(
                                          c_dbt.balance_type_id,
                                          '_ASG_GRE_YTD',
                                          'MX');

      ln_step := 80;
      ln_run_def_bal_id :=
          pay_emp_action_arch.get_defined_balance_id(
                                          c_dbt.balance_type_id,
                                          '_ASG_GRE_RUN',
                                          'MX');

      ln_step := 140;

      IF c_dbt.attribute_name = 'Employee Taxes' THEN

           dbt(i).act_info_category := 'AC DEDUCTIONS';

      ELSIF c_dbt.attribute_name = 'Tax Calculation Details' THEN

           dbt(i).act_info_category := 'MX TAX CALCULATION DETAILS';

      ELSIF c_dbt.attribute_name = 'SUMMARY' THEN

           dbt(i).act_info_category := 'MX SUMMARY';

      END IF;

      dbt(i).bal_name           := c_dbt.reporting_name;
      dbt(i).bal_type_id        := c_dbt.balance_type_id;
      dbt(i).pymt_def_bal_id    := ln_pymt_def_bal_id;
      dbt(i).gre_ytd_def_bal_id := ln_gre_ytd_def_bal_id;
      dbt(i).run_def_bal_id     := ln_run_def_bal_id;

      dbt(i).jurisdiction_cd := NULL;
      i := i + 1;

    END LOOP;

    hr_utility.set_location(gv_package || lv_procedure_name, 30);
    i := 0;

    ln_step := 160;
    FOR i IN dbt.first..dbt.last LOOP
      hr_utility.trace(dbt(i).act_info_category);
      hr_utility.trace(dbt(i).bal_name);
      hr_utility.trace(dbt(i).bal_type_id);
      hr_utility.trace(dbt(i).pymt_def_bal_id);
      hr_utility.trace(dbt(i).gre_ytd_def_bal_id);
      hr_utility.trace(dbt(i).run_def_bal_id);
      hr_utility.trace(dbt(i).jurisdiction_cd);
    END LOOP;

    hr_utility.set_location(gv_package || lv_procedure_name, 40);

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location(gv_package || lv_procedure_name, 500);
      lv_error_message := 'Error at step ' || ln_step ||
                          ' IN ' || gv_package || lv_procedure_name;
      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END initialization_code;


  PROCEDURE populate_tax_and_summary( p_xfr_action_id        IN NUMBER
                                     ,p_assignment_id        IN NUMBER
                                     ,p_pymt_balcall_aaid    IN NUMBER
                                     ,p_tax_unit_id          IN NUMBER
                                     ,p_action_type          IN VARCHAR2
                                     ,p_pymt_eff_date        IN DATE
                                     ,p_start_date           IN DATE
                                     ,p_end_date             IN DATE
                                     ,p_ytd_balcall_aaid     IN NUMBER
                                     )
  IS

  ln_pymt_amount    NUMBER;
  ln_ytd_amount     NUMBER;
  lv_reporting_name VARCHAR2(150);
  lv_lookup_code    VARCHAR2(150);

  ln_gross_earnings NUMBER := 0;
  ln_tax_deductions NUMBER := 0;
  ln_deductions     NUMBER := 0;
  ln_net_pay        NUMBER := 0;

  ln_ytd_gross_earnings NUMBER := 0;
  ln_ytd_tax_deductions NUMBER := 0;
  ln_ytd_deductions     NUMBER := 0;
  ln_ytd_net_pay        NUMBER := 0;


  i NUMBER;
  j NUMBER;

  ln_index NUMBER;
  ln_element_index NUMBER;

  lv_error_message          VARCHAR2(500);
  lv_procedure_name         VARCHAR2(100);
  ln_step                   NUMBER;

  BEGIN
    ln_step := 1;
    lv_procedure_name       := '.populate_tax_and_summary';
    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    i := 0;
    j := 0;

    pay_balance_pkg.set_context('TAX_UNIT_ID', p_tax_unit_id);

    hr_utility.set_location(gv_package || lv_procedure_name, 20);
    ln_step := 2;
    FOR i IN dbt.first..dbt.last LOOP

      ln_pymt_amount := 0;
      ln_ytd_amount  := 0;

      IF p_pymt_balcall_aaid <> -999 THEN

         IF p_action_type IN ('V','B') THEN
             IF dbt(i).run_def_bal_id IS NOT NULL THEN
               ln_step := 5;
               ln_pymt_amount := NVL(pay_balance_pkg.get_value(
                                          dbt(i).run_def_bal_id,
                                          p_pymt_balcall_aaid),0);
             END IF;
         ELSE
             IF dbt(i).pymt_def_bal_id IS NOT NULL THEN
               ln_step := 5;
               ln_pymt_amount := NVL(pay_balance_pkg.get_value(
                                          dbt(i).pymt_def_bal_id,
                                          p_pymt_balcall_aaid),0);
             END IF;
         END IF; -- p_action_type = 'V'

      ELSE

         ln_pymt_amount := 0;

      END IF; -- p_pymt_balcall_aaid <> -999

      ln_step := 7;
      ln_ytd_amount := NVL(pay_balance_pkg.get_value(
                               dbt(i).gre_ytd_def_bal_id,
                               p_ytd_balcall_aaid),0);

      hr_utility.set_location(gv_package || lv_procedure_name, 30);
      ln_step := 8;

      IF dbt(i).act_info_category = 'MX SUMMARY' THEN

           IF dbt(i).bal_name = 'Gross Earnings' THEN

               ln_gross_earnings     := ln_pymt_amount;
               ln_ytd_gross_earnings := ln_ytd_amount;

           ELSIF dbt(i).bal_name = 'Tax Deductions' THEN

               ln_tax_deductions     := ln_pymt_amount;
               ln_ytd_tax_deductions := ln_ytd_amount;

           ELSIF dbt(i).bal_name = 'Deductions' THEN

               ln_deductions     := ln_pymt_amount;
               ln_ytd_deductions := ln_ytd_amount;

           ELSIF dbt(i).bal_name = 'Net Pay' THEN

               ln_net_pay     := ln_pymt_amount;
               ln_ytd_net_pay := ln_ytd_amount;

           END IF;

      ELSIF ( ln_pymt_amount + ln_ytd_amount <> 0 ) THEN

        hr_utility.trace('lv_lookup_code : '||lv_lookup_code);
        hr_utility.set_location(gv_package || lv_procedure_name, 40);


        lv_reporting_name := dbt(i).bal_name; -- MX specific

        /*Insert this into the plsql table */
--        hr_utility.trace('Tax Balance Name : '|| dbt(i).bal_name );
        hr_utility.trace('lv_reporting_name : '||lv_reporting_name);
        hr_utility.set_location(gv_package || lv_procedure_name, 50);

        ln_step := 10;
        ln_index := pay_ac_action_arch.lrr_act_tab.count;

        hr_utility.trace('ln_index IS '
           || pay_ac_action_arch.lrr_act_tab.count);

        pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
          := dbt(i).act_info_category;
        pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
          := dbt(i).jurisdiction_cd;
        pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
          := p_xfr_action_id;
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
        := dbt(i).bal_type_id;
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
          := fnd_number.number_to_canonical(ln_pymt_amount);
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
          := fnd_number.number_to_canonical(ln_ytd_amount);
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
          := lv_reporting_name;

        IF dbt(i).act_info_category = 'AC DEDUCTIONS' THEN
               pay_ac_action_arch.lrr_act_tab(ln_index).act_info16
                   := 'Employee Taxes';

        END IF;


        hr_utility.set_location(gv_package || lv_procedure_name, 60);

        ln_step := 11;
        ln_element_index := pay_ac_action_arch.emp_elements_tab.count;
        pay_ac_action_arch.emp_elements_tab(ln_element_index).jurisdiction_code
                 := dbt(i).jurisdiction_cd;
        pay_ac_action_arch.emp_elements_tab(ln_element_index).element_reporting_name
                 := dbt(i).bal_name;
        pay_ac_action_arch.emp_elements_tab(ln_element_index).element_primary_balance_id
                 := dbt(i).bal_type_id;

        hr_utility.set_location(gv_package || lv_procedure_name, 70);


      END IF;

    END LOOP;

    IF p_pymt_balcall_aaid <> -999 THEN

          ln_index := pay_ac_action_arch.lrr_act_tab.count;

          pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                := 'MX SUMMARY CURRENT';
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                := fnd_number.number_to_canonical(ln_gross_earnings);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info2
                := fnd_number.number_to_canonical(ln_tax_deductions);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info3
                := fnd_number.number_to_canonical(ln_deductions);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info5 -- Bug 4155512
                := fnd_number.number_to_canonical(ln_net_pay);

    END IF;

    hr_utility.set_location(gv_package || lv_procedure_name, 75);

    ln_index := pay_ac_action_arch.lrr_act_tab.count;

    pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
          := 'MX SUMMARY YTD';
    pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
          := fnd_number.number_to_canonical(ln_ytd_gross_earnings);
    pay_ac_action_arch.lrr_act_tab(ln_index).act_info2
          := fnd_number.number_to_canonical(ln_ytd_tax_deductions);
    pay_ac_action_arch.lrr_act_tab(ln_index).act_info3
          := fnd_number.number_to_canonical(ln_ytd_deductions);
    pay_ac_action_arch.lrr_act_tab(ln_index).act_info5 -- Bug 4155512
          := fnd_number.number_to_canonical(ln_ytd_net_pay);


    hr_utility.set_location(gv_package || lv_procedure_name, 80);

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location(gv_package || lv_procedure_name, 500);
      lv_error_message := 'Error at step ' || ln_step ||
                          ' IN ' || gv_package || lv_procedure_name;
      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END populate_tax_and_summary;



  /*********************************************************************
   Name      : update_employee_information
   Purpose   : This function updates the Employee Information, which is
               archived by the global archive procedure.
               The employee name and Legal Employer ID are updated. The
               Organization ID segment will be updated to hold the
               organization_id of the Legal Employer. The Global package
               archives the full name for the employee. This procedure
               will update the name to

                 Paternal Last Name[space]
                     Maternal Last Name[space]
                         First Name[space]
                             Second Name
   Arguments : IN
                 p_assignment_action_id   NUMBER;
                 p_action_context_id      NUMBER;
   Notes     :
  *********************************************************************/
  PROCEDURE update_employee_information(
                p_action_context_id IN NUMBER
               ,p_assignment_id     IN NUMBER)
  IS
   CURSOR c_get_archive_info(cp_action_context_id IN NUMBER
                            ,cp_assignment_id     IN NUMBER) IS
     SELECT action_information_id, effective_date,
            object_version_number,
            tax_unit_id
       FROM pay_action_information
      WHERE action_context_id = cp_action_context_id
        AND action_context_type = 'AAP'
        AND assignment_id = cp_assignment_id
        AND action_information_category = 'EMPLOYEE DETAILS';

   CURSOR c_get_employee_info(cp_assignment_id  IN NUMBER
                             ,cp_effective_date IN DATE) IS
     SELECT LTRIM(RTRIM(
                 DECODE(last_name, NULL, '', ' ' || last_name)
              || DECODE(per_information1, NULL,'',' ' || per_information1)
              || DECODE(first_name,NULL, '', ' ' || first_name)
              || DECODE(middle_names,NULL, '', ' ' || middle_names)
              ))
       FROM per_people_f ppf
      WHERE ppf.person_id =
                (SELECT person_id FROM per_assignments_f paf
                  WHERE assignment_id = cp_assignment_id
                    AND cp_effective_date BETWEEN paf.effective_start_date
                                              AND paf.effective_end_date)
        AND cp_effective_date BETWEEN ppf.effective_start_date
                                  AND ppf.effective_end_date;

    ln_action_information_id NUMBER;
    ld_effective_date        DATE;

    lv_employee_name         VARCHAR2(300);

    ln_ovn                   NUMBER;
    lv_procedure_name        VARCHAR2(200);
    lv_error_message         VARCHAR2(200);
    ln_tax_unit_id           NUMBER;
    ln_business_group_id     NUMBER;
    ln_legal_employer_id     NUMBER;

  BEGIN
    lv_procedure_name  := '.update_employee_information';

    hr_utility.trace('Action_Context_ID = ' || p_action_context_id);
    hr_utility.trace('Asg ID            = ' || p_assignment_id);
    OPEN c_get_archive_info(p_action_context_id, p_assignment_id);
    LOOP
       FETCH c_get_archive_info INTO ln_action_information_id,
                                     ld_effective_date,
                                     ln_ovn,
                                     ln_tax_unit_id;
       IF c_get_archive_info%NOTFOUND THEN
          EXIT;
       END IF;

       ln_business_group_id :=
                 hr_mx_utility.get_bg_from_assignment(p_assignment_id);

       ln_legal_employer_id :=
                 hr_mx_utility.get_legal_employer(ln_business_group_id,
                                                  ln_tax_unit_id);
       hr_utility.trace('ln_legal_employer_id = ' || ln_legal_employer_id);


       hr_utility.trace('Action_info_id = ' || ln_action_information_id);
       hr_utility.trace('ld_eff_date    = ' ||
                                fnd_date.date_to_canonical(ld_effective_date));

       OPEN c_get_employee_info(p_assignment_id, ld_effective_date);
       FETCH c_get_employee_info INTO lv_employee_name;
       CLOSE c_get_employee_info;

       hr_utility.trace('lv_employee_name = *' || lv_employee_name ||'*');

       pay_action_information_api.update_action_information
           (p_action_information_id     =>  ln_action_information_id
           ,p_object_version_number     =>  ln_ovn
           ,p_action_information1       =>  lv_employee_name
           ,p_action_information2       =>  ln_legal_employer_id
           );

    END LOOP;
    CLOSE c_get_archive_info;

  EXCEPTION
   WHEN OTHERS THEN
      lv_error_message := 'Error IN ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_employee_information;

  /**********************************************************************
  ** Procedure get_mx_personal_information populates
  ** pay_emp_action_arch.lrr_act_tab with the following
  ** action_information_contexts :
  **
  **  MX EMPLOYEE DETAILS
  **
  **  It expects the following in parameters:
  **
  **  #1 p_payroll_action_id    : payroll_action_id of the Archive process
  **  #2 p_assactid             : assignment action id of the Archive process
  **  #3 p_assignment_id        : assignment_id
  **  #4 p_curr_pymt_ass_act_id : 'P','U' action which is locked by the
  **                              Archive process.
  **  #5 p_curr_eff_date        : Effective Date of the Archive Process
  **  #6 p_date_earned          : This is the date_earned for the Run
  **                              Process.
  **  #7 p_curr_pymt_eff_date   : The effective date of prepayments.
  **  #8 p_tax_unit_id          : tax_unit_id from pay_assignment_actions
  **  #9 p_time_period_id       : Time Period Id of the Run.
  ** #10 p_ppp_source_action_id : This is the source_action_id of
  **                              pay_pre_payments for the 'P','U' action.
  ** #11 p_ytd_balcall_aaid     : This is the assignment action id to call
  **                              balances other than ASG_PAYMENTS for Employee
  **                              other information.
  **********************************************************************/

  PROCEDURE get_mx_personal_information(
                   p_payroll_action_id    IN NUMBER
                  ,p_assactid             IN NUMBER
                  ,p_assignment_id        IN NUMBER
                  ,p_curr_pymt_ass_act_id IN NUMBER
                  ,p_curr_eff_date        IN DATE
                  ,p_date_earned          IN DATE
                  ,p_curr_pymt_eff_date   IN DATE
                  ,p_tax_unit_id          IN NUMBER
                  ,p_time_period_id       IN NUMBER
                  ,p_ppp_source_action_id IN NUMBER
                  ,p_run_action_id        IN NUMBER
                  ,p_ytd_balcall_aaid     IN NUMBER DEFAULT NULL
                 )
  IS
    CURSOR c_employee_details(cp_assignment_id IN NUMBER
                            , cp_curr_eff_date IN DATE
                             ) IS
      SELECT ppf.per_information2 rfc_id,
             ppf.per_information3 ss_id
        FROM per_assignments_f paf,
             per_people_f ppf
       WHERE paf.person_id = ppf.person_id
         AND paf.assignment_id = cp_assignment_id
         AND cp_curr_eff_date BETWEEN paf.effective_start_date
                                  AND paf.effective_end_date
         AND cp_curr_eff_date BETWEEN ppf.effective_start_date
                                  AND ppf.effective_end_date;


    CURSOR c_get_legal_er_details(cp_legal_er_id NUMBER)
    IS
    SELECT org_information1 "Employer Name",
           org_information2 "Employer RFC ID"
    FROM   hr_organization_information
    WHERE  organization_id         = cp_legal_er_id
    AND    org_information_context = 'MX_TAX_REGISTRATION';

    CURSOR c_get_er_ss_id
    IS
    SELECT org_information1 "Employer Social Security ID"
    FROM   hr_organization_information
    WHERE  organization_id         = p_tax_unit_id
    AND    org_information_context = 'MX_SOC_SEC_DETAILS';

    ln_index                 NUMBER;
    lv_ee_rfc_id             per_all_people_f.per_information2%TYPE;
    lv_ee_ss_id              per_all_people_f.per_information3%TYPE;
    ln_business_group_id     NUMBER;
    ln_legal_employer_id     NUMBER;
    lv_er_rfc_id             hr_organization_information.org_information1%TYPE;
    lv_er_ss_id              hr_organization_information.org_information1%TYPE;
    lv_legal_employer_name   hr_all_organization_units.name%TYPE;
    lv_gre_name              hr_all_organization_units.name%TYPE;
    ld_date_start            DATE;

    lv_procedure_name        VARCHAR2(100);
    ln_step                  NUMBER;
    lv_error_message         VARCHAR2(200);
    lv_exists                VARCHAR2(1);
    ln_index1                NUMBER;

    ln_total_idw             NUMBER;
    ln_fixed_idw             NUMBER;
    ln_variable_idw          NUMBER;

  BEGIN
     lv_procedure_name := 'get_mx_personal_information';
     lv_exists         := 'N';

     hr_utility.trace('Entered get_mx_personal_information');
     ln_step := 1;
     pay_emp_action_arch.initialization_process;

     hr_utility.trace('p_assactid = '             || p_assactid);--
     hr_utility.trace('p_assignment_id = '        || p_assignment_id);--
     hr_utility.trace('p_curr_pymt_ass_act_id = ' || p_curr_pymt_ass_act_id);
     hr_utility.trace('p_curr_eff_date = '        || p_curr_eff_date);--
     hr_utility.trace('p_date_earned = '          || p_date_earned);
     hr_utility.trace('p_curr_pymt_eff_date = '   || p_curr_pymt_eff_date);--
     hr_utility.trace('p_tax_unit_id = '          || p_tax_unit_id);--
     hr_utility.trace('p_time_period_id = '       || p_time_period_id);
     hr_utility.trace('p_run_action_id = '        || p_run_action_id);

     OPEN c_employee_details(p_assignment_id,p_curr_eff_date);
     ln_step := 2;
     FETCH c_employee_details INTO lv_ee_rfc_id,
                                   lv_ee_ss_id;

     IF c_employee_details%NOTFOUND THEN
         hr_utility.raise_error;
     END IF;

     hr_utility.trace('lv_ee_rfc_id = ' || lv_ee_rfc_id);
     hr_utility.trace('lv_ee_ss_id = '  || lv_ee_ss_id);

     CLOSE c_employee_details;

     ln_step := 3;
     ln_total_idw := pay_mx_ff_udfs.get_idw(p_assignment_id,
                                            p_tax_unit_id,
                                            p_curr_pymt_eff_date,
                                            'REPORT',
                                            ln_fixed_idw,
                                            ln_variable_idw);

--
     ln_index := pay_emp_action_arch.lrr_act_tab.count;

     hr_utility.trace('ln_index IN get_mx_personal_information proc IS '
                || pay_emp_action_arch.lrr_act_tab.count);

     pay_emp_action_arch.lrr_act_tab(ln_index).action_info_category
               := 'MX EMPLOYEE DETAILS';
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info1
               := lv_ee_ss_id;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info2
               := lv_ee_rfc_id;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info3
               := ln_total_idw;


     IF pay_emp_action_arch.lrr_act_tab.count > 0 THEN
        ln_step := 4;
        pay_emp_action_arch.insert_rows_thro_api_process(
                  p_action_context_id   => p_assactid
                 ,p_action_context_type => 'AAP'
                 ,p_assignment_id       => p_assignment_id
                 ,p_tax_unit_id         => p_tax_unit_id
                 ,p_curr_pymt_eff_date  => p_curr_pymt_eff_date
                 ,p_tab_rec_data        => pay_emp_action_arch.lrr_act_tab
                 );
     END IF;

  EXCEPTION
   WHEN OTHERS THEN
      lv_error_message := 'Error IN step ' ||ln_step|| ' of '||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_mx_personal_information;

  /******************************************************************
   Name      : populate_summary
   Purpose   : This procedure adds the values for Gross Earnings,
               Taxes and Deductions; and inserts two rows for
               CURRENT and YTD Summary.
   Arguments :
   Notes     :
  ******************************************************************/
/*  PROCEDURE populate_summary(p_xfr_action_id IN NUMBER)
  IS
    lv_gross_earnings              VARCHAR2(80):= 0;
    lv_imputed_earnings            VARCHAR2(80):= 0;
    lv_deductions                  VARCHAR2(80):= 0;
    lv_tax_deductions              VARCHAR2(80):= 0;

    lv_ytd_gross_earnings          VARCHAR2(80):= 0;
    lv_ytd_deductions              VARCHAR2(80):= 0;
    lv_ytd_tax_deductions          VARCHAR2(80):= 0;
    lv_ytd_imputed_earnings        VARCHAR2(80):= 0;

    ln_index                       NUMBER;
    lv_procedure_name              VARCHAR2(100);
    lv_error_message               VARCHAR2(200);
    ln_step                        NUMBER;

    j                              NUMBER := 0;


  BEGIN
       lv_procedure_name    := '.populate_summary';
       ln_step := 1;
       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       IF pay_ac_action_arch.lrr_act_tab.count > 0 THEN
          hr_utility.set_location(gv_package || lv_procedure_name, 20);

          ln_step := 2;
          FOR i IN pay_ac_action_arch.lrr_act_tab.first ..
                   pay_ac_action_arch.lrr_act_tab.last LOOP

              IF pay_ac_action_arch.lrr_act_tab(i).action_context_id
                          = p_xfr_action_id THEN
                 IF pay_ac_action_arch.lrr_act_tab(i).action_info_category
                            IN ('AC EARNINGS', 'AC DEDUCTIONS') THEN

                    IF pay_ac_action_arch.lrr_act_tab(i).act_info16
                                 IN ('Employee Earnings',
                                     'Hourly Earnings',
                                     'Taxable Benefits') THEN

                        -- Bug 4168970 - Imputed Earnings summed up separately
                        --               to be used in calculating Net Pay.
                        --
                        IF pay_ac_action_arch.lrr_act_tab(i).act_info16
                                 = 'Taxable Benefits' THEN

                    hr_utility.set_location(gv_package || lv_procedure_name, 25);
                               lv_imputed_earnings :=
                               lv_imputed_earnings +
                            NVL(pay_ac_action_arch.lrr_act_tab(i).act_info8,0);

                               lv_ytd_imputed_earnings :=
                               lv_ytd_imputed_earnings +
                            NVL(pay_ac_action_arch.lrr_act_tab(i).act_info9,0);

                        END IF;

                    hr_utility.set_location(gv_package || lv_procedure_name, 30);
                       ln_step := 3;
                       lv_gross_earnings
                          := lv_gross_earnings +
                             NVL(pay_ac_action_arch.lrr_act_tab(i).act_info8,0);
                       lv_ytd_gross_earnings
                          := lv_ytd_gross_earnings +
                             NVL(pay_ac_action_arch.lrr_act_tab(i).act_info9,0);
                    ELSIF pay_ac_action_arch.lrr_act_tab(i).act_info16
                                                          = 'Employee Taxes' THEN
                   hr_utility.set_location(gv_package || lv_procedure_name, 40);
                       ln_step := 4;
                       lv_tax_deductions
                          := lv_tax_deductions +
                             NVL(pay_ac_action_arch.lrr_act_tab(i).act_info8,0);
                       lv_ytd_tax_deductions
                          := lv_ytd_tax_deductions +
                             NVL(pay_ac_action_arch.lrr_act_tab(i).act_info9,0);
                    ELSIF pay_ac_action_arch.lrr_act_tab(i).act_info16
                                                              = 'Deductions' THEN
                   hr_utility.set_location(gv_package || lv_procedure_name, 50);
                       ln_step := 5;
                       lv_deductions
                          := lv_deductions +
                             NVL(pay_ac_action_arch.lrr_act_tab(i).act_info8,0);
                       lv_ytd_deductions
                          := lv_ytd_deductions +
                             NVL(pay_ac_action_arch.lrr_act_tab(i).act_info9,0);
                    END IF;

                 END IF;
              END IF;
          END LOOP;
       END IF;

       hr_utility.set_location(gv_package || lv_procedure_name, 60);
       -- Insert one row for CURRENT and one for YTD
       IF pay_ac_action_arch.lrr_act_tab.count > 0 THEN
          ln_step := 6;
          -- CURRENT
          ln_index := pay_ac_action_arch.lrr_act_tab.count;
          hr_utility.trace('ln_index = ' || ln_index);
          pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                := 'MX SUMMARY CURRENT';
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                := fnd_number.number_to_canonical(lv_gross_earnings);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info2
                := fnd_number.number_to_canonical(lv_tax_deductions) ;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info3
                := fnd_number.number_to_canonical(lv_deductions);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info5 -- Bug 4155512
                := fnd_number.number_to_canonical(lv_gross_earnings -
                                                  -- Bug 4168970
                                                  lv_imputed_earnings -
                                                  lv_tax_deductions -
                                                  lv_deductions);


          hr_utility.set_location(gv_package || lv_procedure_name, 80);
          -- YTD
          ln_index := pay_ac_action_arch.lrr_act_tab.count;
          hr_utility.trace('ln_index = ' || ln_index);
          pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                := 'MX SUMMARY YTD';
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                := fnd_number.number_to_canonical(lv_ytd_gross_earnings);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info2
                := fnd_number.number_to_canonical(lv_ytd_tax_deductions) ;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info3
                := fnd_number.number_to_canonical(lv_ytd_deductions);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info5 -- Bug 4155512
                := fnd_number.number_to_canonical(lv_ytd_gross_earnings -
                                                  -- Bug 4168970
                                                  lv_ytd_imputed_earnings -
                                                  lv_ytd_tax_deductions -
                                                  lv_ytd_deductions);

       END IF;

       hr_utility.set_location(gv_package || lv_procedure_name, 100);
       ln_step := 10;

  EXCEPTION
    WHEN OTHERS THEN

      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END populate_summary;
*/

  /************************************************************
   Name      : process_actions
   Purpose   :
   Arguments : p_rqp_action_id - For Child actions we pass the
                                 Action ID of Run/Quick Pay
                               - For Master we pass the Action ID
                                 of Pre Payment Process.
   Notes     :
  ************************************************************/
  PROCEDURE process_actions( p_xfr_payroll_action_id IN NUMBER
                            ,p_xfr_action_id         IN NUMBER
                            ,p_pre_pay_action_id     IN NUMBER
                            ,p_payment_action_id     IN NUMBER
                            ,p_rqp_action_id         IN NUMBER
                            ,p_seperate_check_flag   IN VARCHAR2
                            ,p_action_type           IN VARCHAR2
                            ,p_legislation_code      IN VARCHAR2
                            ,p_assignment_id         IN NUMBER
                            ,p_tax_unit_id           IN NUMBER
                            ,p_curr_pymt_eff_date    IN DATE
                            ,p_xfr_start_date        IN DATE
                            ,p_xfr_end_date          IN DATE
                            ,p_ppp_source_action_id  IN NUMBER DEFAULT NULL
                            ,p_archive_balance_info  IN VARCHAR2
                            )
  IS

    CURSOR c_ytd_aaid(cp_prepayment_action_id IN NUMBER
                     ,cp_assignment_id        IN NUMBER) IS
      SELECT paa.assignment_action_id
        FROM pay_assignment_actions paa,
             pay_action_interlocks pai,
             pay_payroll_actions   ppa
        WHERE pai.locking_action_id =  cp_prepayment_action_id
          AND paa.assignment_action_id = pai.locked_action_id
          AND paa.assignment_id = cp_assignment_id
          AND ppa.payroll_action_id = paa.payroll_action_id
          AND NVL(paa.run_type_id,0) NOT IN (gn_sepchk_run_type_id,
                                             gn_np_sepchk_run_type_id)
      ORDER BY paa.assignment_action_id DESC;

    CURSOR c_time_period(cp_run_assignment_action IN NUMBER) IS
      SELECT ptp.time_period_id,
             ppa.date_earned,
             ppa.effective_date
       FROM pay_assignment_actions paa,
            pay_payroll_actions ppa,
            per_time_periods ptp
      WHERE paa.assignment_action_id = cp_run_assignment_action
        AND ppa.payroll_action_id = paa.payroll_action_id
        AND ptp.payroll_id = ppa.payroll_id
        AND ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date;

    CURSOR c_chk_act_type(cp_last_xfr_act_id NUMBER) IS
      SELECT SUBSTR(serial_number,1,1)
      FROM   pay_assignment_actions paa
      WHERE  paa.assignment_action_id = cp_last_xfr_act_id;

    lv_pre_xfr_act_type       VARCHAR2(80);

    ln_run_action_id          NUMBER;
    ln_ytd_balcall_aaid       NUMBER;
    ld_run_date_earned        DATE;
    ld_run_effective_date     DATE;

    ld_last_xfr_eff_date      DATE;
    ln_last_xfr_action_id     NUMBER;
    ld_last_pymt_eff_date     DATE;
    ln_last_pymt_action_id    NUMBER;

    ln_time_period_id         NUMBER;
    lv_resident_jurisdiction  VARCHAR2(15);

    lv_procedure_name         VARCHAR2(100);
    lv_error_message          VARCHAR2(200);
    ln_step                   NUMBER;

  BEGIN
     lv_procedure_name  := '.process_actions';

     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;
     /****************************************************************
     ** For Seperate Check we do the YTD balance calls with the Run
     ** Action ID. So, we do not need to get the MAX. action which IS
     ** not seperate Check.
     ** Also, p_ppp_source_action_id is set to NULL as we want to get
     ** all records from pay_pre_payments where source_action_id is
     ** NULL.
     ****************************************************************/
     ln_ytd_balcall_aaid := p_payment_action_id;
     IF p_seperate_check_flag = 'N' AND
        p_action_type IN ('U', 'P') THEN
        hr_utility.set_location(gv_package || lv_procedure_name, 40);
        ln_step := 2;
        OPEN c_ytd_aaid(p_rqp_action_id,
                        p_assignment_id);
        FETCH c_ytd_aaid INTO ln_ytd_balcall_aaid;
        IF c_ytd_aaid%NOTFOUND THEN
           hr_utility.set_location(gv_package || lv_procedure_name, 50);
           hr_utility.raise_error;
        END IF;
        CLOSE c_ytd_aaid;
     END IF;

     hr_utility.set_location(gv_package || lv_procedure_name, 60);
     ln_step := 3;

     OPEN c_time_period(p_payment_action_id);
     FETCH c_time_period INTO ln_time_period_id,
                              ld_run_date_earned,
                              ld_run_effective_date;
     CLOSE c_time_period;

     hr_utility.set_location(gv_package || lv_procedure_name, 70);
     ln_step := 4;
     pay_ac_action_arch.get_last_xfr_info(
                       p_assignment_id        => p_assignment_id
                      ,p_curr_effective_date  => p_xfr_end_date
                      ,p_action_info_category => 'EMPLOYEE DETAILS'
                      ,p_xfr_action_id        => p_xfr_action_id
                      ,p_sepchk_flag          => p_seperate_check_flag
                      ,p_last_xfr_eff_date    => ld_last_xfr_eff_date
                      ,p_last_xfr_action_id   => ln_last_xfr_action_id
                      );

     IF ld_last_xfr_eff_date IS NOT NULL THEN
        IF gv_act_param_val IS NOT NULL  THEN
           IF  gv_act_param_val = 'Y'
           THEN
              ld_last_xfr_eff_date := NULL;
           ELSIF fnd_date.canonical_to_date(gv_act_param_val) = p_xfr_end_date
           THEN
              ld_last_xfr_eff_date := NULL;
           END IF;
        END IF;
     END IF;

     IF ld_last_xfr_eff_date IS NOT NULL THEN
        ln_step := 5;
        OPEN c_chk_act_type(ln_last_xfr_action_id);
        FETCH c_chk_act_type INTO lv_pre_xfr_act_type;
        CLOSE c_chk_act_type;

        IF lv_pre_xfr_act_type = 'B' THEN
           ld_last_xfr_eff_date := NULL;
        END IF;
     END IF;

     hr_utility.trace('p_xfr_payroll_action_id= '|| p_xfr_payroll_action_id);
     hr_utility.trace('p_xfr_action_id       = ' || p_xfr_action_id);
     hr_utility.trace('p_seperate_check_flag = ' || p_seperate_check_flag);
     hr_utility.trace('p_action_type         = ' || p_action_type);
     hr_utility.trace('p_pre_pay_action_id   = ' || p_pre_pay_action_id);
     hr_utility.trace('p_payment_action_id   = ' || p_payment_action_id);
     hr_utility.trace('p_rqp_action_id       = ' || p_rqp_action_id);
     hr_utility.trace('p_assignment_id       = ' || p_assignment_id);
     hr_utility.trace('p_xfr_start_date      = ' || p_xfr_start_date );
     hr_utility.trace('p_xfr_end_date        = ' || p_xfr_end_date );
     hr_utility.trace('p_curr_pymt_eff_date  = ' || p_curr_pymt_eff_date);
     hr_utility.trace('ld_run_effective_date = ' || ld_run_effective_date);
     hr_utility.trace('ln_ytd_balcall_aaid   = ' || ln_ytd_balcall_aaid);
     hr_utility.trace('p_ppp_source_action_id = '|| p_ppp_source_action_id);
     hr_utility.trace('ld_run_date_earned    = ' || ld_run_date_earned);
     hr_utility.trace('ld_last_xfr_eff_date  = ' || ld_last_xfr_eff_date);
     hr_utility.trace('ln_last_xfr_action_id = ' || ln_last_xfr_action_id);

     ln_step := 6;
     pay_ac_action_arch.initialization_process;

     IF p_archive_balance_info = 'Y' THEN
        ln_step := 7;
        populate_tax_and_summary( p_xfr_action_id      => p_xfr_action_id
                                 ,p_assignment_id      => p_assignment_id
                                 ,p_pymt_balcall_aaid  => p_payment_action_id
                                 ,p_tax_unit_id        => p_tax_unit_id
                                 ,p_action_type        => p_action_type
                                 ,p_pymt_eff_date      => p_curr_pymt_eff_date
                                 ,p_start_date         => p_xfr_start_date
                                 ,p_end_date           => p_xfr_end_date
                                 ,p_ytd_balcall_aaid   => ln_ytd_balcall_aaid
                                 );


        hr_utility.set_location(gv_package || lv_procedure_name, 90);
        ln_step := 8;
        /******************************************************************
        ** For seperate check cases, the ld_last_xfr_eff_date is never NULL
        ** as the master is always processed before the child actions. The
        ** master data is already in the archive table and as it is in the
        ** same session the process will always go to the ELSE statement
        ******************************************************************/
        IF ld_last_xfr_eff_date IS NULL THEN
           hr_utility.set_location(gv_package || lv_procedure_name, 100);
           first_time_process(
                  p_xfr_action_id       => p_xfr_action_id
                 ,p_assignment_id       => p_assignment_id
                 ,p_curr_pymt_action_id => p_rqp_action_id
                 ,p_curr_pymt_eff_date  => p_curr_pymt_eff_date
                 ,p_curr_eff_date       => p_xfr_end_date
                 ,p_tax_unit_id         => p_tax_unit_id
                 ,p_pymt_balcall_aaid   => p_payment_action_id
                 ,p_ytd_balcall_aaid    => ln_ytd_balcall_aaid
                 ,p_sepchk_flag         => p_seperate_check_flag
                 ,p_legislation_code    => p_legislation_code
                 );

        ELSE
           ln_step := 9;
           pay_ac_action_arch.get_last_pymt_info(
                  p_assignment_id       => p_assignment_id
                 ,p_curr_pymt_eff_date  => p_curr_pymt_eff_date
                 ,p_last_pymt_eff_date  => ld_last_pymt_eff_date
                 ,p_last_pymt_action_id => ln_last_pymt_action_id);

           ln_step := 10;
           get_current_elements(
                  p_xfr_action_id       => p_xfr_action_id
                 ,p_curr_pymt_action_id => p_rqp_action_id
                 ,p_curr_pymt_eff_date  => p_curr_pymt_eff_date
                 ,p_assignment_id       => p_assignment_id
                 ,p_tax_unit_id         => p_tax_unit_id
                 ,p_pymt_balcall_aaid   => p_payment_action_id
                 ,p_ytd_balcall_aaid    => ln_ytd_balcall_aaid
                 ,p_sepchk_flag         => p_seperate_check_flag
                 ,p_legislation_code    => p_legislation_code);

           ln_step := 11;
           get_xfr_elements(
                  p_xfr_action_id      => p_xfr_action_id
                 ,p_last_xfr_action_id => ln_last_xfr_action_id
                 ,p_ytd_balcall_aaid   => ln_ytd_balcall_aaid
                 ,p_pymt_eff_date      => p_curr_pymt_eff_date
                 ,p_legislation_code   => p_legislation_code
                 ,p_sepchk_flag        => p_seperate_check_flag
                 ,p_assignment_id      => p_assignment_id);

           IF ld_last_pymt_eff_date <> p_curr_pymt_eff_date THEN
              ln_step := 12;
              get_missing_xfr_info(
                  p_xfr_action_id       => p_xfr_action_id
                 ,p_tax_unit_id         => p_tax_unit_id
                 ,p_assignment_id       => p_assignment_id
                 ,p_last_pymt_action_id => ln_last_pymt_action_id
                 ,p_last_pymt_eff_date  => ld_last_pymt_eff_date
                 ,p_last_xfr_eff_date   => ld_last_xfr_eff_date
                 ,p_ytd_balcall_aaid    => ln_ytd_balcall_aaid
                 ,p_pymt_eff_date       => p_curr_pymt_eff_date
                 ,p_legislation_code    => p_legislation_code);
           END IF;

        END IF;

--        hr_utility.set_location(gv_package || lv_procedure_name, 145);
--        ln_step := 13;
--        populate_summary(p_xfr_action_id => p_xfr_action_id);

     END IF; /* p_archive_balance_info = 'Y' */

     hr_utility.set_location(gv_package || lv_procedure_name, 150);
     ln_step := 14;
     pay_emp_action_arch.get_personal_information(
                  p_payroll_action_id    => p_xfr_payroll_action_id
                 ,p_assactid             => p_xfr_action_id
                 ,p_assignment_id        => p_assignment_id
                 ,p_curr_pymt_ass_act_id => p_pre_pay_action_id
                 ,p_curr_eff_date        => p_xfr_end_date
                 ,p_date_earned          => ld_run_date_earned
                 ,p_curr_pymt_eff_date   => p_curr_pymt_eff_date
                 ,p_tax_unit_id          => p_tax_unit_id
                 ,p_time_period_id       => ln_time_period_id
                 ,p_ppp_source_action_id => p_ppp_source_action_id
                 ,p_run_action_id        => p_payment_action_id
                 ,p_ytd_balcall_aaid     => ln_ytd_balcall_aaid
                  );

     ln_step := 15;
     get_mx_personal_information(
                  p_payroll_action_id    => p_xfr_payroll_action_id
                 ,p_assactid             => p_xfr_action_id
                 ,p_assignment_id        => p_assignment_id
                 ,p_curr_pymt_ass_act_id => p_pre_pay_action_id
                 ,p_curr_eff_date        => p_xfr_end_date
                 ,p_date_earned          => ld_run_date_earned
                 ,p_curr_pymt_eff_date   => p_curr_pymt_eff_date
                 ,p_tax_unit_id          => p_tax_unit_id
                 ,p_time_period_id       => ln_time_period_id
                 ,p_ppp_source_action_id => p_ppp_source_action_id
                 ,p_run_action_id        => p_payment_action_id
                 ,p_ytd_balcall_aaid     => ln_ytd_balcall_aaid
                  );

     hr_utility.set_location(gv_package || lv_procedure_name, 210);
     ln_step := 16;
     pay_emp_action_arch.insert_rows_thro_api_process(
                  p_action_context_id  => p_xfr_action_id
                 ,p_action_context_type=> 'AAP'
                 ,p_assignment_id      => p_assignment_id
                 ,p_tax_unit_id        => p_tax_unit_id
                 ,p_curr_pymt_eff_date => p_curr_pymt_eff_date
                 ,p_tab_rec_data       => pay_ac_action_arch.lrr_act_tab
                 );

     hr_utility.set_location(gv_package || lv_procedure_name, 220);
     ln_step := 17;
     update_employee_information(
                  p_action_context_id  => p_xfr_action_id
                 ,p_assignment_id      => p_assignment_id);

     hr_utility.set_location(gv_package || lv_procedure_name, 250);

  EXCEPTION
   WHEN OTHERS THEN
      lv_error_message := 'Error IN step ' ||ln_step|| ' of '||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END process_actions;

 /******************************************************************
   Name      : This procedure archives data at payroll action level.
               This would be called from the archive_data procedure
               (for the first chunk only). The
               action_infomration_categories archived by this are
               EMPLOYEE OTHER INFORMATION for MESG, MX EMPLOYER
               DETAILS and ADDRESS DETAILS for Legal Employer
               Address.
   Arguments : p_payroll_action_id  Archiver Payroll Action ID
               p_payroll_id         Payroll ID
               p_effective_date     End Date of Archiver
   Notes     :
  ******************************************************************/
  PROCEDURE arch_pay_action_level_data(p_payroll_action_id IN NUMBER
                                      ,p_payroll_id        IN NUMBER
                                      ,p_effective_date    IN DATE
                                      )
  IS

   ln_organization_id   NUMBER(15);
   ln_tax_unit_id       NUMBER(15);
   ln_business_group_id NUMBER(15);
   lv_procedure_name    VARCHAR2(100);


   CURSOR c_get_organization(cp_payroll_id        IN NUMBER
                            ,cp_effective_date    IN DATE
                            ) IS
      SELECT /*+ INDEX(paf PER_ASSIGNMENTS_F_N7)*/
             DISTINCT paf.organization_id,
                      paf.business_group_id
        FROM per_all_assignments_f paf
       WHERE paf.payroll_id = cp_payroll_id
         AND cp_effective_date BETWEEN paf.effective_start_date
                                   AND paf.effective_end_date;

   CURSOR c_get_legal_ER IS
      SELECT DISTINCT hr_mx_utility.get_legal_employer(paf.business_group_id,
                                                       paa.tax_unit_id)
        FROM per_all_assignments_f   paf,
             pay_assignment_actions  paa
       WHERE paa.payroll_action_id = p_payroll_action_id
         AND paa.assignment_id = paf.assignment_id
         AND paf.payroll_id = p_payroll_id
         AND p_effective_date BETWEEN paf.effective_start_date
                                  AND paf.effective_end_date;

   CURSOR c_get_gre IS
      SELECT DISTINCT paa.tax_unit_id
        FROM pay_assignment_actions  paa
       WHERE paa.payroll_action_id = p_payroll_action_id;


    PROCEDURE get_legal_er_details(p_legal_er_id NUMBER
                                  ) AS

    CURSOR c_get_legal_er_details
    IS
    SELECT nvl(hoi_LE.org_information1, -- Bug 4155512
               hr_general.decode_organization(p_legal_er_id)) "Employer Name",
           hoi_LE.org_information2  "Employer RFC ID",
           hoi_GRE.org_information1 "Employer Social Security ID"
    FROM   hr_organization_information hoi_LE,
           hr_organization_information hoi_GRE
    WHERE  hoi_LE.organization_id             = p_legal_er_id
    AND    hoi_LE.org_information_context     = 'MX_TAX_REGISTRATION'
    AND    hoi_GRE.organization_id(+)         = hoi_LE.organization_id
    AND    hoi_GRE.org_information_context(+) = 'MX_SOC_SEC_DETAILS';

    lv_legal_employer_name  hr_organization_information.org_information1%TYPE;
    lv_er_rfc_id            hr_organization_information.org_information2%TYPE;
    lv_er_ss_id             hr_organization_information.org_information1%TYPE;
    ln_index                NUMBER;

    BEGIN
          OPEN c_get_legal_er_details;
          FETCH c_get_legal_er_details INTO lv_legal_employer_name,
                                            lv_er_rfc_id,
                                            lv_er_ss_id;
          CLOSE c_get_legal_er_details;

         hr_utility.trace('lv_legal_employer_name: ' || lv_legal_employer_name);
         hr_utility.trace('lv_er_rfc_id '            || lv_er_rfc_id);
         hr_utility.trace('lv_er_ss_id '             || lv_er_ss_id);

          ln_index  := pay_emp_action_arch.ltr_ppa_arch.count;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).action_info_category
                  := 'MX EMPLOYER DETAILS';
          pay_emp_action_arch.ltr_ppa_arch(ln_index).jurisdiction_code
                  := NULL;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info1
                  := p_legal_er_id;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info2
                  := lv_legal_employer_name;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info3
                  := lv_er_ss_id;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info4
                  := lv_er_rfc_id ;

    END get_legal_er_details;


    PROCEDURE get_gre_details(p_gre_id NUMBER) AS
    --
    CURSOR c_get_gre_details
    IS
    SELECT org_information1 "Employer Social Security ID"
    FROM   hr_organization_information hoi
    WHERE  organization_id         = p_gre_id
    AND    org_information_context = 'MX_SOC_SEC_DETAILS'
    AND    organization_id NOT IN
                                  (SELECT organization_id
                                   FROM   hr_organization_information
                                   WHERE  org_information_context
                                                = 'MX_TAX_REGISTRATION'
                                  );

    lv_er_ss_id             hr_organization_information.org_information1%TYPE;
    ln_index                NUMBER;

    BEGIN
          OPEN c_get_gre_details;
          FETCH c_get_gre_details INTO lv_er_ss_id;
          CLOSE c_get_gre_details;

          hr_utility.trace('lv_er_ss_id ' || lv_er_ss_id);

          ln_index  := pay_emp_action_arch.ltr_ppa_arch.count;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).action_info_category
                  := 'MX EMPLOYER DETAILS';
          pay_emp_action_arch.ltr_ppa_arch(ln_index).jurisdiction_code
                  := NULL;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info1
                  := p_gre_id;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info3
                  := lv_er_ss_id;

    END get_gre_details;

    PROCEDURE get_org_other_info(p_organization_id   IN NUMBER
                                ,p_business_group_id IN NUMBER)
    IS
      CURSOR c_get_other_info(cp_organization_id         IN NUMBER
                             ,cp_org_information_context IN VARCHAR2) IS
         SELECT hri.org_information1,
                hri.org_information2, hri.org_information3,
                hri.org_information4, hri.org_information5,
                hri.org_information6, hri.org_information7
           FROM hr_organization_information hri
          WHERE hri.organization_id = cp_organization_id
            AND hri.org_information_context =  cp_org_information_context
            AND hri.org_information1 = 'MESG';

      lv_org_information1    hr_organization_information.org_information1%TYPE;
      lv_org_information2    hr_organization_information.org_information2%TYPE;
      lv_org_information3    hr_organization_information.org_information3%TYPE;
      lv_org_information4    hr_organization_information.org_information4%TYPE;
      lv_org_information5    hr_organization_information.org_information5%TYPE;
      lv_org_information6    hr_organization_information.org_information6%TYPE;
      lv_org_information7    hr_organization_information.org_information7%TYPE;

      ln_index               NUMBER;
      lv_procedure_name      VARCHAR2(100);

    BEGIN
       lv_procedure_name := '.arch_pay_action_level_data:get_org_other_info';

       OPEN c_get_other_info(p_organization_id
                            ,'Organization:Payslip Info') ;
       LOOP
          hr_utility.set_location(gv_package || lv_procedure_name, 20);
          FETCH c_get_other_info INTO lv_org_information1
                                     ,lv_org_information2
                                     ,lv_org_information3
                                     ,lv_org_information4
                                     ,lv_org_information5
                                     ,lv_org_information6
                                     ,lv_org_information7;
          IF  c_get_other_info%NOTFOUND THEN
              hr_utility.set_location(gv_package || lv_procedure_name, 30);
              EXIT;
          END IF;


          hr_utility.set_location(gv_package || lv_procedure_name, 40);

          ln_index  := pay_emp_action_arch.ltr_ppa_arch.count;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).action_info_category
                  := 'EMPLOYEE OTHER INFORMATION';
          pay_emp_action_arch.ltr_ppa_arch(ln_index).jurisdiction_code
                  := NULL;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info1
                  := p_organization_id;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info2
                  := 'MESG';
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info4
                  := NVL(lv_org_information7,lv_org_information4) ;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info5
                  := lv_org_information5 ;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info6
                  := lv_org_information6;
       END LOOP ;
       CLOSE c_get_other_info;

       hr_utility.set_location(gv_package || lv_procedure_name, 100);
       OPEN c_get_other_info(p_business_group_id
                            ,'Business Group:Payslip Info') ;
       LOOP
          hr_utility.set_location(gv_package || lv_procedure_name, 110);
          FETCH c_get_other_info INTO lv_org_information1
                                     ,lv_org_information2
                                     ,lv_org_information3
                                     ,lv_org_information4
                                     ,lv_org_information5
                                     ,lv_org_information6
                                     ,lv_org_information7;
          IF c_get_other_info%NOTFOUND THEN
             hr_utility.set_location(gv_package || lv_procedure_name, 120);
             EXIT;
          END IF;

          hr_utility.set_location(gv_package || lv_procedure_name, 130);
          ln_index  := pay_emp_action_arch.ltr_ppa_arch.count;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).action_info_category
                  := 'EMPLOYEE OTHER INFORMATION';
          pay_emp_action_arch.ltr_ppa_arch(ln_index).jurisdiction_code
                  := NULL;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info1
                  := p_business_group_id;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info2
                  := 'MESG';
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info4
                  := NVL(lv_org_information7,lv_org_information4) ;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info5
                  := lv_org_information5 ;
          pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info6
                  := lv_org_information6;
       END LOOP ;
       CLOSE c_get_other_info;
       hr_utility.set_location(gv_package || lv_procedure_name, 140);

    END get_org_other_info;


    PROCEDURE get_legal_ER_address(p_organization_id IN NUMBER)
    IS
      CURSOR c_addr_line(cp_organization_id IN NUMBER) IS
         SELECT address_line_1, address_line_2,
                address_line_3, town_or_city,
                region_1,       region_2,
                region_3,       postal_code,
                country,        telephone_number_1
           FROM hr_locations hl,
                hr_organization_units hou
          WHERE hou.organization_id = cp_organization_id
            AND hou.location_id     = hl.location_id;

       lv_ee_or_er            VARCHAR2(150);
       lv_er_address_line_1   VARCHAR2(240);
       lv_er_address_line_2   VARCHAR2(240);
       lv_er_address_line_3   VARCHAR2(240);
       lv_er_town_or_city     VARCHAR2(150);
       lv_er_region_1         VARCHAR2(240);
       lv_er_region_2         VARCHAR2(240);
       lv_er_region_3         VARCHAR2(240);
       lv_er_postal_code      VARCHAR2(150);
       lv_er_country          VARCHAR2(240);
       lv_er_telephone        VARCHAR2(150);

       lv_exists              VARCHAR2(1);
       ln_index               NUMBER;
       lv_procedure_name      VARCHAR2(100);

    BEGIN
       lv_ee_or_er        := 'Employer Address';
       lv_exists          := 'N';
       lv_procedure_name  := '.arch_pay_action_level_data:get_legal_ER_address';

       -- Get Employer address
       hr_utility.set_location(gv_package || lv_procedure_name, 210);
       OPEN c_addr_line(p_organization_id);
       FETCH c_addr_line INTO lv_er_address_line_1
                                ,lv_er_address_line_2
                                ,lv_er_address_line_3
                                ,lv_er_town_or_city
                                ,lv_er_region_1
                                ,lv_er_region_2
                                ,lv_er_region_3
                                ,lv_er_postal_code
                                ,lv_er_country
                                ,lv_er_telephone;
        CLOSE c_addr_line;
        hr_utility.set_location(gv_package || lv_procedure_name, 250);

        IF pay_emp_action_arch.ltr_ppa_arch_data.count > 0 THEN
           FOR i IN pay_emp_action_arch.ltr_ppa_arch_data.FIRST ..
                    pay_emp_action_arch.ltr_ppa_arch_data.LAST LOOP
               IF pay_emp_action_arch.ltr_ppa_arch_data(i).act_info1
                          = ln_organization_id AND
                  pay_emp_action_arch.ltr_ppa_arch_data(i).act_info14
                          = 'Employer Address' THEN
                  lv_exists := 'Y';
                  EXIT;
               END IF;
           END LOOP;
        END IF;

        IF lv_exists = 'N' THEN
           hr_utility.set_location(gv_package || lv_procedure_name, 260);
           ln_index := pay_emp_action_arch.ltr_ppa_arch.count;

           pay_emp_action_arch.ltr_ppa_arch(ln_index).action_info_category
                        := 'ADDRESS DETAILS';
           pay_emp_action_arch.ltr_ppa_arch(ln_index).jurisdiction_code
                       := NULL;
           pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info1
                       := ln_organization_id;
           pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info5
                       := lv_er_address_line_1 ;
           pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info6
                       := lv_er_address_line_2;
           pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info7
                       := lv_er_address_line_3;
           pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info8
                       := lv_er_town_or_city;
           pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info9
                    := lv_er_region_1;
           pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info10
                       := lv_er_region_2;
           pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info11
                       := lv_er_region_3 ;
           pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info12
                       := lv_er_postal_code;
           pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info13
                       := lv_er_country;
           pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info14
                       := lv_ee_or_er;
        END IF;

    END get_legal_ER_address;

   BEGIN
       lv_procedure_name := '.arch_pay_action_level_data';

       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       OPEN c_get_organization(p_payroll_id, p_effective_date);
       LOOP
          FETCH c_get_organization INTO ln_organization_id,
                                        ln_business_group_id;
          IF c_get_organization%NOTFOUND THEN
             EXIT;
          END IF;

          get_org_other_info(ln_organization_id, ln_business_group_id);
          hr_utility.set_location(gv_package || lv_procedure_name, 20);

       END LOOP;
       CLOSE c_get_organization;

  -- For each Legal Employer corresponding to the GREs processed in the
  -- Archiver, we archive the Employer Address, Employer Legal Name and
  -- Employer RFC ID. If it is also a GRE, then the Employer SS ID for it is
  -- also archived.
  --
       OPEN c_get_legal_ER;
       LOOP
          FETCH c_get_legal_ER INTO ln_organization_id;
          hr_utility.set_location(gv_package || lv_procedure_name, 30);

          IF c_get_legal_ER%NOTFOUND THEN
             EXIT;
          END IF;

          get_legal_ER_address(ln_organization_id);
          hr_utility.set_location(gv_package || lv_procedure_name, 40);

          get_legal_ER_details(ln_organization_id);
          hr_utility.set_location(gv_package || lv_procedure_name, 50);

       END LOOP;
       CLOSE c_get_legal_ER;

  -- For each GRE processed in the Archiver that is not a Legal Employer
  -- (because Legal Employer details are already archived), we archive the
  -- Employer SS ID for it.
  --
       OPEN c_get_gre;
       LOOP
          FETCH c_get_gre INTO ln_organization_id;
          hr_utility.set_location(gv_package || lv_procedure_name, 60);

          IF c_get_gre%NOTFOUND THEN
             EXIT;
          END IF;

          get_gre_details(ln_organization_id);
          hr_utility.set_location(gv_package || lv_procedure_name, 70);

       END LOOP;
       CLOSE c_get_gre;


       hr_utility.set_location(gv_package || lv_procedure_name, 80);

       -- insert rows in pay_action_information table
       IF pay_emp_action_arch.ltr_ppa_arch.count > 0 THEN
          pay_emp_action_arch.insert_rows_thro_api_process(
                     p_action_context_id   =>  p_payroll_action_id
                    ,p_action_context_type =>  'PA'
                    ,p_assignment_id       =>  NULL
                    ,p_tax_unit_id         =>  NULL
                    ,p_curr_pymt_eff_date  =>  p_effective_date
                    ,p_tab_rec_data        =>  pay_emp_action_arch.ltr_ppa_arch
                    );
       END IF;
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace('Error in ' || gv_package || '.'
                                   || lv_procedure_name || '-'
                                   || TO_CHAR(SQLCODE) || '-' || SQLERRM);
      hr_utility.set_location(gv_package || lv_procedure_name, 90);
      RAISE hr_utility.hr_error;

  END arch_pay_action_level_data;


/******************************************************************
   Name      : process_additional_elements
   Purpose   : Retrieves the balances corresponding to the elements
               processed in the given assignment and inserts YTD
               balance to pl/sql table.
   Arguments : p_assignment_id        => Terminated Assignment Id
               p_assignment_action_id => Max assignment action id
                                         of given assignment
               p_curr_eff_date        => Current effective date
               p_xfr_action_id        => Current XFR action id.
               p_legislation_code     => 'MX'
               p_tax_unit_id          => GRE of the assignment
               p_action_type          => Action type of the payment
                                         action
               p_start_date           => Start Date of the XFR action.
               p_end_date             => End Date of the XFR action.

   Notes     : This process is used to retrieve elements processed
               in terminated assignments which are not picked up by
               the archiver.
  ******************************************************************/
  PROCEDURE process_additional_elements(p_assignment_id   IN NUMBER
                                  ,p_assignment_action_id IN NUMBER
                                  ,p_curr_eff_date        IN DATE
                                  ,p_xfr_action_id        IN NUMBER
                                  ,p_legislation_code     IN VARCHAR2
                                  ,p_tax_unit_id          IN NUMBER
                                  ,p_action_type          IN VARCHAR2
                                  ,p_start_date           IN DATE
                                  ,p_end_date             IN DATE )
  IS

    lv_procedure_name              VARCHAR2(50);
    lv_reporting_name              VARCHAR2(80);
    lv_jurisdiction_code           VARCHAR2(80);
    ln_primary_balance_id          NUMBER;
    ln_hours_balance_id            NUMBER;
    ln_days_balance_id             NUMBER;
    ln_element_index               NUMBER;
    lv_action_category             VARCHAR2(50);
    ln_ytd_defined_balance_id      NUMBER;
    ln_ytd_amount                  NUMBER(15,2) := 0;
    ln_ytd_hours_balance_id        NUMBER;
    ln_ytd_hours                   NUMBER(15,2);
    ln_current_hours               NUMBER(15,2) := 0;
    ln_ytd_days_balance_id         NUMBER;
    ln_ytd_days                    NUMBER(15,2);
    ln_current_days                NUMBER(15,2) := 0;
    ln_payments_amount             NUMBER(15,2) := 0;
    ln_index                       NUMBER;
    ln_check_count                 NUMBER;
    ln_check_count2                NUMBER;
    ln_step                        NUMBER;
    lv_error_message               VARCHAR2(200);

    i                              NUMBER;
    st_cnt                         NUMBER;
    end_cnt                        NUMBER;
    lv_business_grp_id             NUMBER;
    lv_run_bal_status              VARCHAR2(1);
    lv_attribute_name              VARCHAR2(80);

    CURSOR c_business_grp_id IS
    SELECT DISTINCT business_group_id
      FROM per_assignments_f
     WHERE assignment_id = p_assignment_id;

   CURSOR c_prev_ytd_action_elem_rbr(cp_assignment_id IN NUMBER
                                    ,cp_curr_eff_date IN DATE
                                    ) IS
   SELECT DISTINCT
          pbad.attribute_name,
          NVL(pbtl.reporting_name, pbtl.balance_name),
          prb.jurisdiction_code,
          pbt_pri.balance_type_id,        -- Primary Balance
          DECODE(pbad.attribute_name,
                 'Hourly Earnings', pbt_sec.balance_type_id,
                 NULL),                   -- Hours Balance
          DECODE(pbad.attribute_name,
                 'Employee Earnings', pbt_sec.balance_type_id,
                 NULL)                    -- Days Balance
   FROM   pay_bal_attribute_definitions pbad,
          pay_balance_attributes        pba,
          pay_defined_balances          pdb,
          pay_balance_types             pbt_pri,
          pay_balance_types             pbt_sec,
          pay_balance_types_tl          pbtl,
          pay_run_balances              prb
   WHERE  pbad.attribute_name IN ('Employee Earnings',
                                  'Hourly Earnings',
                                  'Deductions',
                                  'Taxable Benefits'
--                               ,'Employee Taxes',
--                                'Tax Calculation Details'
                                 )
     AND  pbad.legislation_code  = 'MX'
     AND  pba.attribute_id       = pbad.attribute_id
     AND  pdb.defined_balance_id = pba.defined_balance_id
     AND  pbt_pri.balance_type_id = pdb.balance_type_id
     AND  pbt_pri.input_value_id IS NOT NULL
     AND  pbtl.balance_type_id   = pbt_pri.balance_type_id
     AND  pbtl.language          = USERENV('LANG')
     AND  pbt_pri.balance_type_id  = pbt_sec.base_balance_type_id(+)
     AND  prb.effective_date    >= TRUNC(cp_curr_eff_date,'Y')
     AND  prb.effective_date    <= cp_curr_eff_date
     AND  prb.assignment_id      = cp_assignment_id
     AND  pdb.defined_balance_id = prb.defined_balance_id
   ORDER BY 1;


  CURSOR c_prev_ytd_action_elements(cp_assignment_id IN NUMBER
                                   ,cp_curr_eff_date IN DATE
                                 ) IS
   SELECT DISTINCT
          pbad.attribute_name,
          NVL(pbtl.reporting_name, pbtl.balance_name),
          prr.jurisdiction_code,
          pbt_pri.balance_type_id,        -- Primary Balance
          DECODE(pbad.attribute_name,
                 'Hourly Earnings', pbt_sec.balance_type_id,
                 NULL),                   -- Hours Balance
          DECODE(pbad.attribute_name,
                 'Employee Earnings', pbt_sec.balance_type_id,
                 NULL)                    -- Days Balance
   FROM   pay_bal_attribute_definitions pbad,
          pay_balance_attributes        pba,
          pay_defined_balances          pdb,
          pay_balance_types             pbt_pri,
          pay_balance_types             pbt_sec,
          pay_balance_types_tl          pbtl,
          pay_assignment_actions        paa,
          pay_payroll_actions           ppa,
          pay_run_results               prr,
          pay_input_values_f            piv
   WHERE  pbad.attribute_name IN ('Employee Earnings',
                                  'Hourly Earnings',
                                  'Deductions',
                                  'Taxable Benefits'
--                               ,'Employee Taxes',
--                                'Tax Calculation Details'
                                 )
     AND  pbad.legislation_code  = 'MX'
     AND  pba.attribute_id       = pbad.attribute_id
     AND  pdb.defined_balance_id = pba.defined_balance_id
     AND  pbt_pri.balance_type_id = pdb.balance_type_id
     AND  pbt_pri.input_value_id = piv.input_value_id
     AND  piv.element_type_id = prr.element_type_id
     AND  ppa.effective_date BETWEEN piv.effective_start_date
                                 AND piv.effective_end_date
     AND  pbtl.balance_type_id   = pbt_pri.balance_type_id
     AND  pbtl.language          = USERENV('LANG')
     AND  pbt_pri.balance_type_id  = pbt_sec.base_balance_type_id(+)
     AND  prr.assignment_action_id = paa.assignment_action_id
     AND  paa.assignment_id       = cp_assignment_id
     AND  ppa.payroll_action_id   = paa.payroll_action_id
     AND  ppa.action_type in ('Q','R','B')
     AND  ppa.effective_date >= TRUNC(cp_curr_eff_date,'Y')
     AND  ppa.effective_date <= cp_curr_eff_date
ORDER BY 1;

  BEGIN
    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    lv_procedure_name      := '.process_additional_elements';
    lv_action_category     := 'AC DEDUCTIONS';


    ln_step := 10;
    pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);


-- Populating the PL/SQL table run_bal_stat_tab with the validity status
-- of various attributes. If already populated, we use that to check the
-- validity

      IF run_bal_stat.COUNT >0 THEN
         st_cnt := run_bal_stat.FIRST;
         end_cnt := run_bal_stat.LAST;
         FOR i IN st_cnt..end_cnt LOOP
            IF run_bal_stat(i).valid_status = 'N' THEN
               lv_run_bal_status := 'N';
               EXIT;
            END IF;
         END LOOP;
      ELSE
         OPEN c_business_grp_id;
         FETCH c_business_grp_id INTO lv_business_grp_id;
         CLOSE c_business_grp_id;

         run_bal_stat(1).attribute_name := 'Employee Earnings';
         run_bal_stat(2).attribute_name := 'Hourly Earnings';
         run_bal_stat(3).attribute_name := 'Deductions';
         run_bal_stat(4).attribute_name := 'Employee Taxes';
         run_bal_stat(5).attribute_name := 'Tax Calculation Details';

         st_cnt := run_bal_stat.FIRST;
         end_cnt := run_bal_stat.LAST;

         FOR i IN st_cnt..end_cnt LOOP
            run_bal_stat(i).valid_status :=
            pay_us_payroll_utils.check_balance_status(
                                                 p_curr_eff_date,
                                                 lv_business_grp_id,
                                                 run_bal_stat(i).attribute_name,
                                                 p_legislation_code);
            IF (lv_run_bal_status IS NULL AND
                run_bal_stat(i).valid_status = 'N') THEN
                          lv_run_bal_status := 'N';
            END IF;
         END LOOP;
      END IF;

      IF lv_run_bal_status IS NULL THEN
         lv_run_bal_status := 'Y';
      END IF;

      ln_step := 20;


      IF lv_run_bal_status = 'Y' THEN
         OPEN c_prev_ytd_action_elem_rbr(p_assignment_id,
                                         p_curr_eff_date);
      ELSE
         OPEN c_prev_ytd_action_elements(p_assignment_id,
                                         p_curr_eff_date);
      END IF;

     LOOP
         IF lv_run_bal_status = 'Y' THEN
            FETCH c_prev_ytd_action_elem_rbr INTO
                               lv_attribute_name,
                               lv_reporting_name,
                               lv_jurisdiction_code,
                               ln_primary_balance_id,
                               ln_hours_balance_id,
                               ln_days_balance_id;

            IF c_prev_ytd_action_elem_rbr%NOTFOUND THEN
               hr_utility.set_location(gv_package || lv_procedure_name, 40);
               EXIT;
            END IF;
         ELSE
            FETCH c_prev_ytd_action_elements INTO
                               lv_attribute_name,
                               lv_reporting_name,
                               lv_jurisdiction_code,
                               ln_primary_balance_id,
                               ln_hours_balance_id,
                               ln_days_balance_id;

            IF c_prev_ytd_action_elements%NOTFOUND THEN
               hr_utility.set_location(gv_package || lv_procedure_name, 45);
               EXIT;
            END IF;
         END IF;

         hr_utility.set_location(gv_package  || lv_procedure_name, 50);
         hr_utility.trace('Reporting Name = '|| lv_reporting_name);
         hr_utility.trace('Primary Bal id = '|| ln_primary_balance_id);
         hr_utility.trace('JD Code = '       || lv_jurisdiction_code);

         IF lv_attribute_name IN ('Deductions',
                                  'Employee Taxes',
                                  'Tax Calculation Details') THEN
            ln_step := 30;
            ln_hours_balance_id := NULL;
            ln_days_balance_id  := NULL;

         END IF;

        IF lv_jurisdiction_code IS NOT NULL THEN
            pay_balance_pkg.set_context('JURISDICTION_CODE', lv_jurisdiction_code);
            gv_ytd_balance_dimension := gv_dim_asg_jd_gre_ytd;
        ELSE
            pay_balance_pkg.set_context('JURISDICTION_CODE', lv_jurisdiction_code);
        END IF;


      IF ln_hours_balance_id IS NOT NULL THEN
         ln_step := 40;
         hr_utility.set_location(gv_package || lv_procedure_name, 60);
         ln_ytd_hours_balance_id
                := pay_emp_action_arch.get_defined_balance_id(
                                            ln_hours_balance_id,
                                            gv_ytd_balance_dimension,
                                            p_legislation_code);
          hr_utility.trace('ln_ytd_hours_balance_id = '||
                             ln_ytd_hours_balance_id);
          hr_utility.set_location(gv_package || lv_procedure_name, 70);

          ln_step := 50;
          IF ln_ytd_hours_balance_id IS NOT NULL THEN
               ln_ytd_hours := NVL(pay_balance_pkg.get_value(
                                      ln_ytd_hours_balance_id,
                                      p_assignment_action_id),0);
               hr_utility.trace('ln_ytd_hours = '||ln_ytd_hours);
               hr_utility.set_location(gv_package || lv_procedure_name, 80);
          END IF;
      END IF; --Hours



      IF ln_days_balance_id IS NOT NULL THEN
         ln_step := 60;
         hr_utility.set_location(gv_package || lv_procedure_name, 90);
         ln_ytd_days_balance_id
                := pay_emp_action_arch.get_defined_balance_id(
                                            ln_days_balance_id,
                                            gv_ytd_balance_dimension,
                                            p_legislation_code);
          hr_utility.trace('ln_ytd_days_balance_id = '||
                             ln_ytd_days_balance_id);
          hr_utility.set_location(gv_package || lv_procedure_name, 100);

          ln_step := 70;
          IF ln_ytd_days_balance_id IS NOT NULL THEN
               ln_ytd_days := NVL(pay_balance_pkg.get_value(
                                      ln_ytd_days_balance_id,
                                      p_assignment_action_id),0);
               hr_utility.trace('ln_ytd_days = '||ln_ytd_days);
               hr_utility.set_location(gv_package || lv_procedure_name, 110);
          END IF;
      END IF; --Days



      ln_step := 80;
      ln_ytd_defined_balance_id
                  := pay_emp_action_arch.get_defined_balance_id
                                          (ln_primary_balance_id,
                                           gv_ytd_balance_dimension,
                                           p_legislation_code);
      hr_utility.trace('ln_ytd_defined_balance_id = '||
                        ln_ytd_defined_balance_id);
      hr_utility.set_location(gv_package || lv_procedure_name, 120);
      IF ln_ytd_defined_balance_id IS NOT NULL THEN
         ln_step := 90;
         ln_ytd_amount := NVL(pay_balance_pkg.get_value(
                                     ln_ytd_defined_balance_id,
                                     p_assignment_action_id),0);
         hr_utility.trace('ln_ytd_amount = '||ln_ytd_amount);
      END IF;
      hr_utility.set_location(gv_package || lv_procedure_name, 130);


      IF NVL(ln_ytd_amount, 0) <> 0 THEN
         ln_step := 100;
         ln_element_index := pay_ac_action_arch.emp_elements_tab.count;

         hr_utility.trace('ln_element_index = '||ln_element_index);

         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_reporting_name
                        := lv_reporting_name;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_primary_balance_id
                        := ln_primary_balance_id;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_hours_balance_id
                        := ln_hours_balance_id;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).jurisdiction_code
                        := lv_jurisdiction_code;


        ln_index := pay_ac_action_arch.lrr_act_tab.count;
        hr_utility.trace('ln_index = '||ln_index);
        IF lv_attribute_name IN ('Employee Earnings', 'Hourly Earnings',
                                'Taxable Benefits') THEN
               hr_utility.set_location(gv_package || lv_procedure_name, 140);
               lv_action_category := 'AC EARNINGS';
               hr_utility.trace('ln_current_hours = '||ln_current_hours);
               hr_utility.trace('ln_ytd_hours = '    ||ln_ytd_hours);
               hr_utility.trace('ln_current_days = ' ||ln_current_days);
               hr_utility.trace('ln_ytd_days = '     ||ln_ytd_days);
               ln_step := 120;
               pay_ac_action_arch.lrr_act_tab(ln_index).act_info11
                         := fnd_number.number_to_canonical(ln_current_hours);
               pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                         := fnd_number.number_to_canonical(ln_ytd_hours);
               pay_ac_action_arch.lrr_act_tab(ln_index).act_info14
                         := fnd_number.number_to_canonical(ln_current_days);
               pay_ac_action_arch.lrr_act_tab(ln_index).act_info15
                         := fnd_number.number_to_canonical(ln_ytd_days);
        ELSE
              lv_action_category := 'AC DEDUCTIONS';
        END IF;
        hr_utility.set_location(gv_package || lv_procedure_name, 150);
        hr_utility.trace('lv_action_category = '||lv_action_category);
        hr_utility.trace('ln_ytd_amount = '||ln_ytd_amount);
        hr_utility.trace('lv_reporting_name = '||lv_reporting_name);
        hr_utility.trace('p_xfr_action_id = '||p_xfr_action_id);
        ln_step := 130;

             pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                    := lv_action_category;
             pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                   := lv_jurisdiction_code;
             pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                   := p_xfr_action_id;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                   := ln_primary_balance_id;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                   := fnd_number.number_to_canonical(ln_payments_amount);
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                   := fnd_number.number_to_canonical(ln_ytd_amount);
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                   := lv_reporting_name;

      END IF;
      hr_utility.set_location(gv_package || lv_procedure_name, 160);

    END LOOP;
    IF lv_run_bal_status = 'Y' THEN
       CLOSE c_prev_ytd_action_elem_rbr;
    ELSE
       CLOSE c_prev_ytd_action_elements;
    END IF;

   ln_step := 140;
--   populate_tax_and_summary(p_xfr_action_id);
   populate_tax_and_summary( p_xfr_action_id     => p_xfr_action_id
                            ,p_assignment_id     => p_assignment_id
                            ,p_pymt_balcall_aaid => -999
                            ,p_tax_unit_id       => p_tax_unit_id
                            ,p_action_type       => p_action_type
                            ,p_pymt_eff_date     => p_curr_eff_date
                            ,p_start_date        => p_start_date
                            ,p_end_date          => p_end_date
                            ,p_ytd_balcall_aaid  => p_assignment_action_id
                           );

   ln_step := 150;
   hr_utility.trace('------------Looping to see pl/sql table --------');
   ln_check_count := pay_ac_action_arch.emp_elements_tab.count;
   ln_check_count2 := pay_ac_action_arch.lrr_act_tab.count;

   hr_utility.trace('ln_check_count =  '||ln_check_count);
   hr_utility.trace('ln_check_count2 = '||ln_check_count2);
   hr_utility.trace('============= End of Processing '||p_assignment_id||
                    '=============');
   hr_utility.set_location(gv_package || lv_procedure_name,170);

  EXCEPTION
    WHEN OTHERS THEN

      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END process_additional_elements;


  /************************************************************
   Name      : archive_code
   Purpose   : This procedure Archives data which are used in
               Payslip, Check Writer, Deposit Advice modules.
   Arguments :
   Notes     :
  ************************************************************/
  PROCEDURE archive_code(p_xfr_action_id  IN NUMBER
                        ,p_effective_date IN DATE)
  IS

    CURSOR c_xfr_info (cp_assignment_action IN NUMBER) IS
      SELECT paa.payroll_action_id,
             paa.assignment_action_id,
             paa.assignment_id,
             paa.tax_unit_id,
             paa.serial_number,
             paa.chunk_number
        FROM pay_assignment_actions paa
       WHERE paa.assignment_action_id = cp_assignment_action;

    CURSOR c_legislation (cp_business_group IN NUMBER) IS
      SELECT org_information9
        FROM hr_organization_information
       WHERE org_information_context = 'Business Group Information'
         AND organization_id = cp_business_group;

    CURSOR c_assignment_run (cp_prepayment_action_id IN NUMBER) IS
      SELECT DISTINCT paa.assignment_id
        FROM pay_action_interlocks pai,
             pay_assignment_actions paa,
             pay_payroll_actions ppa
       WHERE pai.locking_action_id = cp_prepayment_action_id
         AND paa.assignment_action_id = pai.locked_action_id
         AND ppa.payroll_action_id = paa.payroll_action_id
         AND ppa.action_type IN ('R', 'Q', 'B')
         AND ((ppa.run_type_id IS NULL AND
               paa.source_action_id IS NULL) OR
              (ppa.run_type_id IS NOT NULL AND
               paa.source_action_id IS NOT NULL))
         AND paa.action_status = 'C';

    CURSOR c_master_run_action(
                      cp_prepayment_action_id IN NUMBER,
                      cp_assignment_id        IN NUMBER) IS
      SELECT paa.assignment_action_id, paa.payroll_action_id,
             ppa.action_type
        FROM pay_payroll_actions ppa,
             pay_assignment_actions paa,
             pay_action_interlocks pai
        WHERE pai.locking_action_id =  cp_prepayment_action_id
          AND pai.locked_action_id = paa.assignment_action_id
          AND paa.assignment_id = cp_assignment_id
          AND paa.source_action_id IS NULL
          AND ppa.payroll_action_id = paa.payroll_action_id
        ORDER BY paa.assignment_action_id DESC;

    CURSOR c_pymt_eff_date(cp_prepayment_action_id IN NUMBER) IS
      SELECT ppa.effective_date
        FROM pay_payroll_actions ppa,
             pay_assignment_actions paa
       WHERE ppa.payroll_action_id = paa.payroll_action_id
         AND paa.assignment_action_id = cp_prepayment_action_id;

    CURSOR c_check_pay_action( cp_payroll_action_id IN NUMBER) IS
      SELECT count(*)
        FROM pay_action_information
       WHERE action_context_id = cp_payroll_action_id
         AND action_context_type = 'PA';

  CURSOR c_payment_info(cp_prepay_action_id NUMBER) IS
    SELECT assignment_id
          ,tax_unit_id
          ,NVL(source_action_id,-999)
          ,assignment_action_id
    FROM  pay_payment_information_v
    WHERE assignment_action_id = cp_prepay_action_id
    ORDER BY 3,1,2;

  CURSOR c_run_aa_id(cp_pp_asg_act_id NUMBER
                    ,cp_assignment_id NUMBER
                    ,cp_tax_unit_id   NUMBER) IS
    SELECT paa.assignment_action_id
          ,paa.source_action_id
    FROM   pay_assignment_actions paa
          ,pay_action_interlocks pai
    where  pai.locking_action_id    = cp_pp_asg_act_id
    AND    paa.assignment_action_id = pai.locked_action_id
    AND    paa.assignment_id        = cp_assignment_id
    AND    paa.tax_unit_id          = cp_tax_unit_id
    AND    paa.source_action_id IS NOT NULL
    AND    NOT EXISTS ( SELECT 1
                        FROM   pay_run_types_f prt
                        WHERE  prt.legislation_code = 'MX'
                        AND    prt.run_type_id = paa.run_type_id
                        AND    prt.run_method IN ( 'C', 'S' ) )
    ORDER BY paa.action_sequence DESC;

   CURSOR c_get_prepay_aaid_for_sepchk( cp_asg_act_id NUMBER,
                                        cp_source_act_id NUMBER ) IS
     SELECT ppp.assignment_action_id
     FROM   pay_assignment_actions paa
           ,pay_pre_payments ppp
     WHERE  ( paa.assignment_action_id = cp_asg_act_id OR
              paa.source_action_id     = cp_asg_act_id )
     AND    ppp.assignment_action_id = paa.assignment_action_id
     AND    ppp.source_action_id     = cp_source_act_id;


  CURSOR c_run_aa_id_bal_adj(cp_pp_asg_act_id NUMBER
                    ,cp_assignment_id NUMBER
                    ,cp_tax_unit_id   NUMBER) IS
    SELECT paa.assignment_action_id
          ,paa.source_action_id
    FROM   pay_assignment_actions paa
          ,pay_action_interlocks pai
    WHERE  pai.locking_action_id    = cp_pp_asg_act_id
    AND    paa.assignment_action_id = pai.locked_action_id
    AND    paa.assignment_id        = cp_assignment_id
    AND    paa.tax_unit_id          = cp_tax_unit_id
    ORDER BY paa.action_sequence DESC;

  CURSOR c_all_runs(cp_pp_asg_act_id   IN NUMBER
                   ,cp_assignment_id   IN NUMBER
                   ,cp_tax_unit_id     IN NUMBER) IS
    SELECT paa.assignment_action_id
      FROM pay_assignment_actions paa,
           pay_action_interlocks pai
      WHERE pai.locking_action_id = cp_pp_asg_act_id
        AND paa.assignment_action_id = pai.locked_action_id
        AND paa.assignment_id = cp_assignment_id
        AND paa.tax_unit_id = cp_tax_unit_id
        AND NVL(paa.run_type_id,0) NOT IN (gn_sepchk_run_type_id,
                                           gn_np_sepchk_run_type_id)
        AND NOT EXISTS ( SELECT 1
                         FROM   pay_run_types_f prt
                         WHERE  prt.legislation_code = 'US'
                         AND    prt.run_type_id = NVL(paa.run_type_id,0)
                         AND    prt.run_method  = 'C' );

    CURSOR c_get_emp_adjbal(cp_xfr_action_id NUMBER) IS
      SELECT locked_action_id
        FROM pay_action_interlocks
       WHERE locking_action_id = cp_xfr_action_id;

    ld_curr_pymt_eff_date     DATE;
    ln_sepchk_run_type_id     NUMBER;
    lv_legislation_code       VARCHAR2(2);

    ln_xfr_master_action_id   NUMBER;

    ln_tax_unit_id            NUMBER;
    ln_xfr_payroll_action_id  NUMBER; /* of current xfr */
    ln_xfr_assignment_id      NUMBER;
    ln_assignment_id          NUMBER;
    ln_chunk_number           NUMBER;

    lv_xfr_master_serial_number  VARCHAR2(30);
    lv_master_action_type     VARCHAR2(1);
    lv_master_sepcheck_flag   VARCHAR2(1);
    ln_asg_action_id          NUMBER;

    ln_master_run_action_id   NUMBER;
    ln_master_run_pact_id     NUMBER;
    lv_master_run_action_type VARCHAR2(1);

    ln_pymt_balcall_aaid      NUMBER;
    ln_pay_action_count       NUMBER;

    ld_start_date            DATE;
    ld_end_date              DATE;
    ln_business_group_id     NUMBER;
    ln_cons_set_id           NUMBER;
    ln_payroll_id            NUMBER;

    lv_resident_jurisdiction VARCHAR2(30);

    lv_procedure_name        VARCHAR2(100);
    lv_error_message         VARCHAR2(200);
    ln_step                  NUMBER;
    ln_term_asg_id           NUMBER;
    ln_term_asg_act_id       NUMBER;
    ln_old_term_asg_id       NUMBER;


    ln_source_action_id      NUMBER;
    ln_child_xfr_action_id   NUMBER;
    ln_run_aa_id             NUMBER;
    ln_run_source_action_id  NUMBER;
    ln_rqp_action_id         NUMBER;
    ln_ppp_source_action_id  NUMBER;
    ln_master_run_aa_id      NUMBER;
    ln_earnings              NUMBER;
    lv_serial_number         VARCHAR2(30);

    ln_run_qp_found          NUMBER;
    ln_all_run_asg_act_id    NUMBER;

    lv_archive_balance_info  VARCHAR2(1);

  BEGIN
     lv_procedure_name       := '.archive_code';
     ln_old_term_asg_id      := '-1';
     lv_archive_balance_info := 'Y';


     pay_emp_action_arch.gv_error_message := NULL;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;
     OPEN c_xfr_info (p_xfr_action_id);
     FETCH c_xfr_info INTO ln_xfr_payroll_action_id,
                           ln_xfr_master_action_id,
                           ln_xfr_assignment_id,
                           ln_tax_unit_id,
                           lv_xfr_master_serial_number,
                           ln_chunk_number;
     CLOSE c_xfr_info;

     ln_step := 2;
     get_payroll_action_info(p_payroll_action_id => ln_xfr_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_cons_set_id       => ln_cons_set_id
                            ,p_payroll_id        => ln_payroll_id);

     hr_utility.set_location(gv_package || lv_procedure_name, 15);

     ln_step := 205;
     pay_emp_action_arch.gv_multi_payroll_pymt
          := pay_emp_action_arch.get_multi_assignment_flag(
                              p_payroll_id       => ln_payroll_id
                             ,p_effective_date   => ld_end_date);

     hr_utility.trace('pay_emp_action_arch.gv_multi_payroll_pymt = ' ||
                       pay_emp_action_arch.gv_multi_payroll_pymt);

     ln_step := 3;
     OPEN c_legislation (ln_business_group_id);
     FETCH c_legislation INTO lv_legislation_code ;
     IF c_legislation%NOTFOUND THEN
        hr_utility.trace('Business Group FOR Archiver Process Not Found');
        hr_utility.raise_error;
     END IF;
     CLOSE c_legislation;
     hr_utility.trace('lv_legislation_code '||lv_legislation_code);

     ln_step := 4;

     -- process the master_action
     lv_master_action_type   := SUBSTR(lv_xfr_master_serial_number,1,1);
     -- Always N FOR Master Assignment Action
     lv_master_sepcheck_flag := SUBSTR(lv_xfr_master_serial_number,2,1);
     -- Assignment Action of Quick Pay Pre Payment, Pre Payment, Reversal
     ln_asg_action_id := SUBSTR(lv_xfr_master_serial_number,3);

     ln_step := 5;
     OPEN c_pymt_eff_date(ln_asg_action_id);
     FETCH c_pymt_eff_date INTO ld_curr_pymt_eff_date;
     IF c_pymt_eff_date%NOTFOUND THEN
        hr_utility.trace('Payroll Action FOR Archiver Process Not Found');
        hr_utility.raise_error;
     END IF;
     CLOSE c_pymt_eff_date;

     hr_utility.trace('End Date=' || TO_CHAR(ld_end_date, 'dd-mon-yyyy'));
     hr_utility.trace('Start Date=' || TO_CHAR(ld_start_date, 'dd-mon-yyyy'));
     hr_utility.trace('Business Group Id=' || TO_CHAR(ln_business_group_id));
     hr_utility.trace('Serial Number=' || lv_xfr_master_serial_number);
     hr_utility.trace('ln_xfr_payroll_action_id =' ||
                                           TO_CHAR(ln_xfr_payroll_action_id));

     ln_step := 6;
     IF lv_master_action_type IN ( 'P','U') THEN
        /************************************************************
        ** For Master Pre Payment Action get the distinct
        ** Assignment_ID's and archive the data separately for
        ** all the assigments.
        *************************************************************/
        ln_step := 7;
        OPEN c_payment_info(ln_asg_action_id);
        LOOP

          FETCH c_payment_info INTO ln_assignment_id
                                   ,ln_tax_unit_id
                                   ,ln_source_action_id
                                   ,ln_asg_action_id;
          EXIT WHEN c_payment_info%NOTFOUND;

          hr_utility.trace('archive_code:payment_info: ln_asg_action_id' ||
                           ln_asg_action_id );
          hr_utility.trace('archive_code:payment_info: ln_assignment_id' ||
                           ln_assignment_id );
          hr_utility.trace('archive_code:payment_info: ln_tax_unit_id' ||
                           ln_tax_unit_id );
          hr_utility.trace('archive_code:payment_info: ln_source_action_id' ||
                           ln_source_action_id );

          ln_step := 8;

          IF ln_source_action_id = -999 THEN

             ln_step := 9;
             lv_master_sepcheck_flag := 'N';
             ln_master_run_aa_id     := NULL;
             ln_run_qp_found         := 0;

             /********************************************************
             ** Getting Run Assignment Action Id for normal cheque.
             ********************************************************/
-- This cursor fetches all aaids locked by the prepayment
-- that are non-cumulative and non-separate-check, but which have a source action.
-- So either Regular or Tax Separate.
--
             OPEN  c_run_aa_id(ln_asg_action_id
                              ,ln_assignment_id
                              ,ln_tax_unit_id);
             FETCH c_run_aa_id INTO ln_run_aa_id, ln_run_source_action_id;
             IF c_run_aa_id%found THEN
                ln_run_qp_found := 1;
             END IF;
             CLOSE c_run_aa_id;

             ln_step := 10;
             hr_utility.trace('GRE ln_run_aa_id = ' || ln_run_aa_id);

            IF ln_run_source_action_id IS NOT NULL THEN
               ln_master_run_aa_id   := ln_run_source_action_id; -- Normal Chk
            ELSE
               IF ln_run_qp_found = 0 THEN
                  /* Balance Adjustment or Reversal */
                  OPEN  c_run_aa_id_bal_adj(ln_asg_action_id
                                   ,ln_assignment_id
                                   ,ln_tax_unit_id);
                  FETCH c_run_aa_id_bal_adj INTO ln_run_aa_id,
                                                 ln_run_source_action_id;
                  CLOSE c_run_aa_id_bal_adj;
                  ln_master_run_aa_id   := ln_asg_action_id;
               ELSE
               --
               -- This will never be entered since the source_action_id is NULL
               -- IS already ruled out in the cursor c_run_aa_id
               --
                  ln_master_run_aa_id   := ln_run_aa_id; -- Normal Chk
               END IF;
            END IF;

            ln_rqp_action_id         := ln_asg_action_id;
            ln_ppp_source_action_id  := NULL;


          ELSE

             ln_step := 11;
            lv_master_sepcheck_flag  := 'Y';
            ln_master_run_aa_id      := ln_source_action_id; -- Sep Chk
            ln_rqp_action_id         := ln_source_action_id; -- Sep Chk
            ln_ppp_source_action_id  := ln_source_action_id; -- Sep Chk
            ln_run_aa_id             := ln_source_action_id; -- Sep Chk

          END IF;

          IF  ln_source_action_id <> -999 THEN

             OPEN  c_get_prepay_aaid_for_sepchk(ln_asg_action_id
                                               ,ln_source_action_id);
             FETCH c_get_prepay_aaid_for_sepchk INTO ln_asg_action_id;
             CLOSE c_get_prepay_aaid_for_sepchk;

             ln_step := 12;
             SELECT pay_assignment_actions_s.nextval
               INTO ln_child_xfr_action_id
               FROM dual;

             hr_utility.set_location(gv_package || lv_procedure_name, 30);

             -- insert into pay_assignment_actions.

             ln_step := 13;


             hr_nonrun_asact.insact(ln_child_xfr_action_id,
                                    ln_assignment_id,
                                    ln_xfr_payroll_action_id,
                                    ln_chunk_number,
                                    ln_tax_unit_id,
                                    NULL,
                                    'C',
                                    p_xfr_action_id);

             hr_utility.set_location(gv_package || lv_procedure_name, 40);

             hr_utility.trace('GRE Locking Action = ' ||ln_child_xfr_action_id);
             hr_utility.trace('GRE Locked Action = '  ||ln_asg_action_id);

             -- insert an interlock to this action

             ln_step := 14;

             hr_nonrun_asact.insint(ln_child_xfr_action_id,
                                    ln_asg_action_id);

             ln_step := 15;

             lv_serial_number := lv_master_action_type ||
                                 lv_master_sepcheck_flag || ln_source_action_id;

             ln_step := 16;

             update pay_assignment_actions
                set serial_number = lv_serial_number
              WHERE assignment_action_id = ln_child_xfr_action_id;

             hr_utility.trace('Processing Child action ' ||
                               p_xfr_action_id);

          ELSE
             ln_step := 17;
             ln_child_xfr_action_id := p_xfr_action_id;
          END IF;

          ln_earnings := 0;
          ln_step := 18;

--        IF gn_gross_earn_def_bal_id + gn_payments_def_bal_id  <> 0 THEN
          IF gn_gross_earn_def_bal_id  <> 0 THEN

             IF ln_source_action_id = -999 THEN

                ln_step := 19;

                OPEN  c_all_runs(ln_asg_action_id,
                                 ln_assignment_id,
                                 ln_tax_unit_id);
                LOOP
                   FETCH c_all_runs INTO ln_all_run_asg_act_id;
                   IF c_all_runs%NOTFOUND THEN
                      EXIT;
                   END IF;

                   pay_balance_pkg.set_context('TAX_UNIT_ID', ln_tax_unit_id);
                   ln_earnings := NVL(pay_balance_pkg.get_value(
                                      gn_gross_earn_def_bal_id,
                                      ln_all_run_asg_act_id),0);

                   /**************************************************
                   ** For Non-payroll Payments element is processed
                   ** alone, the gross earning balance returns zero.
                   ** In this case check payment.
                   **************************************************/

--                   IF ln_earnings = 0 THEN

--                      ln_step := 20;
--                      ln_earnings := NVL(pay_balance_pkg.get_value(
--                                         gn_payments_def_bal_id,
--                                         ln_all_run_asg_act_id),0);

--                   END IF;

                   IF ln_earnings <> 0 THEN
                      EXIT;
                   END IF;

                END LOOP;
                CLOSE c_all_runs;
              ELSE
                 ln_earnings := 1;  -- For Separate Check
              END IF;

          END IF;


          ln_step := 21;
          IF ln_earnings = 0 AND
             ln_xfr_assignment_id = ln_assignment_id AND
             pay_emp_action_arch.gv_multi_payroll_pymt = 'Y' THEN
             ln_earnings := 1;
             lv_archive_balance_info := 'N';
          ELSE
             lv_archive_balance_info := 'Y';
          END IF;

          IF ln_earnings <> 0 THEN

             process_actions(p_xfr_payroll_action_id => ln_xfr_payroll_action_id
                            ,p_xfr_action_id         => ln_child_xfr_action_id
                            ,p_pre_pay_action_id     => ln_asg_action_id
                            ,p_payment_action_id     => ln_master_run_aa_id
                            ,p_rqp_action_id         => ln_rqp_action_id
                            ,p_seperate_check_flag   => lv_master_sepcheck_flag
                            ,p_action_type           => lv_master_action_type
                            ,p_legislation_code      => lv_legislation_code
                            ,p_assignment_id         => ln_assignment_id
                            ,p_tax_unit_id           => ln_tax_unit_id
                            ,p_curr_pymt_eff_date    => ld_curr_pymt_eff_date
                            ,p_xfr_start_date        => ld_start_date
                            ,p_xfr_end_date          => ld_end_date
                            ,p_ppp_source_action_id  => ln_ppp_source_action_id
                            ,p_archive_balance_info  => lv_archive_balance_info
                             );
          END IF;

        END LOOP;  -- c_payment_info

        CLOSE c_payment_info;

       hr_utility.trace('pay_ac_action_arch.g_xfr_run_exists = '||
                         pay_ac_action_arch.g_xfr_run_exists );

       /***
       ** Removed cursor c_get_term_asg as it gets executed when
       ** Multiple Payment is enabled for the payroll and it is not
       ** enabled for Mexico for now. Please check version 115.8
       ***/

     END IF; /* P,U */


     ln_step := 24;

     IF lv_master_action_type  = 'V' THEN
        /* ln_asg_action_id is nothing but reversal run action id */
        ln_pymt_balcall_aaid := ln_asg_action_id ;
        hr_utility.trace('Reversal ln_pymt_balcall_aaid'
               ||to_char(ln_pymt_balcall_aaid));
         ln_step := 25;
         pay_ac_action_arch.initialization_process;

         hr_utility.trace('Populating Tax Balances FOR Reversals');
         hr_utility.trace('ln_tax_unit_id : '||to_char(ln_tax_unit_id));
         hr_utility.trace('ln_pymt_balcall_aaid :'||to_char(ln_pymt_balcall_aaid));
         hr_utility.trace('ld_curr_pymt_eff_date :'||to_char(ld_curr_pymt_eff_date,'DD-MON-YYYY'));
         hr_utility.trace('ln_assignment_id :'||to_char(ln_assignment_id));


         ln_step := 26;
         populate_tax_and_summary( p_xfr_action_id     => p_xfr_action_id
                                  ,p_assignment_id     => ln_assignment_id
                                  ,p_pymt_balcall_aaid => ln_pymt_balcall_aaid
                                  ,p_tax_unit_id       => ln_tax_unit_id
                                  ,p_action_type       => lv_master_action_type
                                  ,p_pymt_eff_date     => ld_curr_pymt_eff_date
                                  ,p_start_date        => ld_start_date
                                  ,p_end_date          => ld_end_date
                                  ,p_ytd_balcall_aaid  => ln_pymt_balcall_aaid
                                );

         ln_step := 27;
         hr_utility.trace('Populating Current Elements FOR Reversals');
         get_current_elements(
               p_xfr_action_id       => p_xfr_action_id
              ,p_curr_pymt_action_id => ln_pymt_balcall_aaid
              ,p_curr_pymt_eff_date  => ld_curr_pymt_eff_date
              ,p_assignment_id       => ln_assignment_id
              ,p_tax_unit_id         => ln_tax_unit_id
              ,p_pymt_balcall_aaid   => ln_pymt_balcall_aaid
              ,p_ytd_balcall_aaid    => ln_pymt_balcall_aaid
              ,p_sepchk_flag         => lv_master_sepcheck_flag
              ,p_legislation_code    => lv_legislation_code
              ,p_action_type         => lv_master_action_type);

         hr_utility.trace('Done Populating Tax Balances FOR Reversals');
         ln_step := 28;
         pay_emp_action_arch.insert_rows_thro_api_process(
                  p_action_context_id  => p_xfr_action_id
                 ,p_action_context_type=> 'AAP'
                 ,p_assignment_id      => ln_assignment_id
                 ,p_tax_unit_id        => ln_tax_unit_id
                 ,p_curr_pymt_eff_date => ld_curr_pymt_eff_date
                 ,p_tab_rec_data       => pay_ac_action_arch.lrr_act_tab
                 );

     END IF; -- lv_master_action_type = 'V'


     ln_step := 29;

     IF lv_master_action_type  = 'B' THEN
         hr_utility.trace('Populating Current Elements FOR Balance Adjustments');
        /* ln_asg_action_id is nothing but Balance Adjustment run action id */
        ln_asg_action_id := -1;
        pay_ac_action_arch.initialization_process;

        OPEN c_get_emp_adjbal(p_xfr_action_id);
        LOOP
          FETCH c_get_emp_adjbal INTO ln_asg_action_id;
          EXIT WHEN c_get_emp_adjbal%NOTFOUND;

          ln_pymt_balcall_aaid := ln_asg_action_id ;
          hr_utility.trace('Bal Adjustment ln_pymt_balcall_aaid'
               ||to_char(ln_pymt_balcall_aaid));

          ln_step := 30;

          hr_utility.trace('ln_tax_unit_id : '||to_char(ln_tax_unit_id));
          hr_utility.trace('ln_pymt_balcall_aaid :'||to_char(ln_pymt_balcall_aaid));
          hr_utility.trace('ld_curr_pymt_eff_date :'||to_char(ld_curr_pymt_eff_date,'DD-MON-YYYY'));
          hr_utility.trace('ln_assignment_id :'||to_char(ln_assignment_id));

          /* Need to pass Payslip Archiver Assignment_Action_id to
           p_curr_pymt_action_id because we have to archive Bal Adjustments
           that are not marked for 'Pre-Payment', Otherwise nothing
           will be archived. */

          IF ln_asg_action_id <> -1 AND ln_asg_action_id IS NOT NULL THEN
             ln_step := 31;
             get_current_elements(
               p_xfr_action_id       => p_xfr_action_id
              ,p_curr_pymt_action_id => p_xfr_action_id
              ,p_curr_pymt_eff_date  => ld_curr_pymt_eff_date
              ,p_assignment_id       => ln_assignment_id
              ,p_tax_unit_id         => ln_tax_unit_id
              ,p_pymt_balcall_aaid   => ln_pymt_balcall_aaid
              ,p_ytd_balcall_aaid    => ln_pymt_balcall_aaid
              ,p_sepchk_flag         => lv_master_sepcheck_flag
              ,p_legislation_code    => lv_legislation_code
              ,p_action_type         => lv_master_action_type);
          END IF;
         END LOOP;
         CLOSE c_get_emp_adjbal;

         ln_step := 32;
         pay_emp_action_arch.insert_rows_thro_api_process(
                  p_action_context_id  => p_xfr_action_id
                 ,p_action_context_type=> 'AAP'
                 ,p_assignment_id      => ln_assignment_id
                 ,p_tax_unit_id        => ln_tax_unit_id
                 ,p_curr_pymt_eff_date => ld_curr_pymt_eff_date
                 ,p_tab_rec_data       => pay_ac_action_arch.lrr_act_tab
                 );

     END IF; -- master_action_type = 'B'


     /****************************************************************
     ** Archive all the payroll action level data once only when
     ** chunk number is 1. Also check if this has not been archived
     ** earlier
     *****************************************************************/
     hr_utility.set_location(gv_package || lv_procedure_name,210);
     ln_step := 33;
     OPEN c_check_pay_action(ln_xfr_payroll_action_id);
     FETCH c_check_pay_action INTO ln_pay_action_count;
     CLOSE c_check_pay_action;
     IF ln_pay_action_count = 0 THEN
        hr_utility.set_location(gv_package || lv_procedure_name,210);
        IF ln_chunk_number = 1 THEN
           ln_step := 34;
           arch_pay_action_level_data(
                               p_payroll_action_id => ln_xfr_payroll_action_id
                              ,p_payroll_id        => ln_payroll_id
                              ,p_effective_Date    => ld_end_date
                              );
       END IF;

     END IF;

  EXCEPTION
   WHEN OTHERS THEN
      lv_error_message := 'Error at step ' || ln_step || ' IN ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END archive_code;


BEGIN
--hr_utility.trace_on (NULL, 'MX_PAYSLIP_ARCHIVE');
   gv_package                := 'pay_mx_payroll_arch';
   gv_dim_asg_gre_ytd        := '_ASG_GRE_YTD';
   gv_dim_asg_jd_gre_ytd     := '_ASG_JD_GRE_YTD';
   gv_ytd_balance_dimension  := '_ASG_GRE_YTD';


END pay_mx_payroll_arch;

/
