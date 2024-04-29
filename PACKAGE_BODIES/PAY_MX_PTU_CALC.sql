--------------------------------------------------------
--  DDL for Package Body PAY_MX_PTU_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_PTU_CALC" AS
/* $Header: paymxprofitshare.pkb 120.17.12010000.5 2009/11/18 06:29:47 jdevasah ship $ */

   TYPE number_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

/******************************************************************************
** Global Variables
******************************************************************************/
   gv_package   VARCHAR2(100);

-------------------------------------------------------------------------------
-- Name      : get_payroll_action_info
-- Purpose   : This returns the Payroll Action level
--             information for Profit Sharing process.
-- Arguments : p_payroll_action_id - Payroll_Action_id of the process
--             p_start_date        - Start of Profit Sharing Year
--             p_effective_date    - Date Earned for Profit Sharing Year
--             p_business_group_id - Business Group ID
--             p_legal_employer_id - Legal Employer ID when submitting PTU
--             p_asg_set_id        - Assignment Set ID when submitting PTU
--             p_batch_name        - Batch Name for the BEE batch header.
------------------------------------------------------------------------------
  PROCEDURE get_payroll_action_info(p_payroll_action_id     IN        NUMBER
                                   ,p_start_date           OUT NOCOPY DATE
                                   ,p_effective_date       OUT NOCOPY DATE
                                   ,p_business_group_id    OUT NOCOPY NUMBER
                                   ,p_legal_employer_id    OUT NOCOPY NUMBER
                                   ,p_asg_set_id           OUT NOCOPY NUMBER
                                   ,p_batch_name           OUT NOCOPY VARCHAR2
                                  )
  IS
    CURSOR c_payroll_Action_info
              (cp_payroll_action_id IN NUMBER) IS
      SELECT start_date,
             effective_date,
             business_group_id,
             pay_mx_utility.get_parameter( 'BATCH_NAME',
                            legislative_parameters) BATCH_NAME,
             pay_mx_utility.get_parameter('LEGAL_EMPLOYER',
                            legislative_parameters) LEGAL_EMPLOYER,
             pay_mx_utility.get_parameter('ASG_SET_ID',
                            legislative_parameters) ASG_SET_ID
        FROM pay_payroll_actions
       WHERE payroll_action_id = cp_payroll_action_id;

    ld_start_date        DATE;
    ld_effective_date    DATE;
    ln_business_group_id NUMBER;
    ln_asg_set_id        NUMBER;
    ln_legal_er_id       NUMBER;
    lv_incl_temp_EEs     VARCHAR2(1);
    ln_min_days          NUMBER;
    lv_procedure_name    VARCHAR2(100);

    lv_error_message     VARCHAR2(200);
    ln_step              NUMBER;
    lv_batch_name        pay_batch_headers.batch_name%TYPE;

   BEGIN
       lv_procedure_name  := '.get_payroll_action_info';

       hr_utility.trace('Entering ' ||gv_package || lv_procedure_name);
       ln_step := 1;
       OPEN c_payroll_action_info(p_payroll_action_id);
       FETCH c_payroll_action_info INTO ld_start_date,
                                        ld_effective_date,
                                        ln_business_group_id,
                                        lv_batch_name,
                                        ln_legal_er_id,
                                        ln_asg_set_id;
       CLOSE c_payroll_action_info;

       hr_utility.set_location(gv_package || lv_procedure_name, 10);

       p_start_date        := ld_start_date;
       p_effective_date    := ld_effective_date;
       p_business_group_id := ln_business_group_id;
       p_legal_employer_id := ln_legal_er_id;
--       p_incl_temp_EEs     := lv_incl_temp_EEs;
--       p_min_days_worked   := ln_min_days;
       p_asg_set_id        := ln_asg_set_id;
       p_batch_name        := lv_batch_name;

       hr_utility.trace('Leaving ' ||gv_package || lv_procedure_name);

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

-------------------------------------------------------------------------------
-- Name      : get_capped_average_earnings
-- Purpose   : This procedure returns the capped average earnings for an
--             an employee. The capped earnings are used for calculating
--             the wage component of the employees share in company's
--             profit. The capped earnings are calculated based on the
--             method set at the legal employer level. Users can choose to
--             use one of the following -
--             Daily Wages
--             Annual Earnings
--             Prorated Annual Earnings

-- Arguments : p_ptu_calc_method   - Calculation method for PTU
--             p_days_in_year      - Actual number of days in the year
--             p_business_group_id - Business Group ID
--             p_legal_employer_id - Legal Employer ID when submitting PTU
--             p_factor_B          - Factor B (Number of Days Worked)
--             p_factor_C          - Factor C (Annual Earnings)
--             p_factor_D          - Factor D (Daily Wage of the highest paid EE
--             p_factor_D_used     - Factor D Used in the calculation.
--             p_factor_E          - Factor E (Capped Earnings)
------------------------------------------------------------------------------
PROCEDURE get_capped_average_earnings (
                              p_ptu_calc_method   IN VARCHAR2,
                              p_days_in_year      IN NUMBER,
                              p_business_group_id IN NUMBER,
                              p_legal_employer_id IN NUMBER,
                              p_factor_B          IN NUMBER,
                              p_factor_C          IN NUMBER,
                              p_factor_D          IN NUMBER,
                              p_factor_D_used     OUT NOCOPY NUMBER,
                              p_factor_E          OUT NOCOPY NUMBER) IS

   lv_procedure_name    VARCHAR2(30);
   lv_ptu_calc_method   FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE;
   ln_days_in_year      NUMBER;
   ln_business_group_id HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE;
   ln_legal_employer_id HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE;
   ln_factor_B          NUMBER;
   ln_factor_C          NUMBER;
   ln_factor_D          NUMBER;
   ln_factor_E          NUMBER;
   ln_days_in_month_le  NUMBER;
   ln_days_in_year_le   NUMBER;

BEGIN
   lv_procedure_name  := '.get_capped_average_earnings';
   hr_utility.trace('Entering ' || gv_package || lv_procedure_name);

   lv_ptu_calc_method   := p_ptu_calc_method;
   ln_days_in_year      := p_days_in_year;
   ln_business_group_id := p_business_group_id;
   ln_legal_employer_id := p_legal_employer_id;
   ln_factor_B          := p_factor_B;
   ln_factor_C          := p_factor_C;
   ln_factor_D          := p_factor_D;
   ln_factor_E          := p_factor_E;

   IF (lv_ptu_calc_method = 'DAILY_WAGE') THEN
      /*
       * Use employee's daily wage to calculate the
       * portion of profit share based on wages.
       */
      IF (ln_factor_C / ln_factor_B) > ln_factor_D THEN

          hr_utility.set_location(gv_package || lv_procedure_name,10);
          ln_factor_E := ln_factor_D;

      ELSE

          hr_utility.set_location(gv_package || lv_procedure_name,20);
          ln_factor_E := ROUND( ln_factor_C / ln_factor_B, 4 );

      END IF;

   ELSIF (lv_ptu_calc_method = 'ANNUAL_EARN') THEN

      /* Use employee's annual earnings to calculate the
       * distribution of profit. The highest union worker
       * daily wage is converted into annual earnings for
       * comparision. This is achieved by multiplying with
       * number of days in the year specified at the
       * Legal Employer level
       */

       hr_utility.set_location(gv_package || lv_procedure_name,30);
       pay_mx_utility.get_no_of_days_for_org
                        (ln_business_group_id,
                         ln_legal_employer_id,
                         'LE',
                         ln_days_in_month_le,
                         ln_days_in_year_le) ;

       IF (ln_days_in_year_le IS NOT NULL) THEN /*bug 8461411 */
       hr_utility.set_location(gv_package || lv_procedure_name,40);
          ln_days_in_year := ln_days_in_year_le;
       END IF;

       ln_factor_D := ln_factor_D * ln_days_in_year;
       hr_utility.trace('ln_factor_D = ' || to_char(ln_factor_D));

       IF (ln_factor_C > ln_factor_D) THEN
          hr_utility.set_location(gv_package || lv_procedure_name,50);
          ln_factor_E := ln_factor_D;
       ELSE
          hr_utility.set_location(gv_package || lv_procedure_name,60);
          ln_factor_E := ln_factor_C;
       END IF;

   ELSIF (lv_ptu_calc_method = 'PRORATE') THEN

      /*
       * The maximum salary cap is a function of the
       * number of days the employee worked. The highest
       * union worker salary is considered to be the
       * limit for someone who has worked all year.
       * For an employee, who has worked part of the year
       * the limit should be adjusted to the amount that
       * the highest paid employee would have made if he
       * had worked the same number of days.
       */
       hr_utility.set_location(gv_package || lv_procedure_name,70);
      ln_factor_D := ln_factor_D * ln_factor_B;
      IF (ln_factor_C > ln_factor_D) THEN
         hr_utility.set_location(gv_package || lv_procedure_name,80);
         ln_factor_E := ln_factor_D;
      ELSE
         hr_utility.set_location(gv_package || lv_procedure_name,90);
         ln_factor_E := ln_factor_C;
      END IF;

   END IF;

   p_factor_D_used := ln_factor_D;
   p_factor_E      := ln_factor_E;
   hr_utility.trace('p_factor_D = ' || TO_CHAR(p_factor_D));
   hr_utility.trace('p_factor_E = ' || TO_CHAR(p_factor_E));
   hr_utility.trace('Entering ' || gv_package || lv_procedure_name);
END get_capped_average_earnings;
 /******************************************************************
   Name      : range_code
   Purpose   : This returns the select statement that is
               used to create the range rows for the Profit Sharing
               process.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ******************************************************************/
  PROCEDURE range_code(
                    p_payroll_action_id IN        NUMBER
                   ,p_sqlstr           OUT NOCOPY VARCHAR2)
  IS

    ld_end_date          DATE;
    ld_start_date        DATE;
    ld_date_earned       DATE;
    ln_business_group_id NUMBER;
    ln_asg_set_id        NUMBER;
    ln_legal_employer_id NUMBER;
--    lv_incl_temp_EEs     VARCHAR2(1);
--    ln_min_days_worked   NUMBER;
    lv_batch_name        pay_batch_headers.batch_name%TYPE;

    lv_sql_string        VARCHAR2(32000);
    lv_procedure_name    VARCHAR2(100);

    lv_error_message        VARCHAR2(200);
    ln_step                 NUMBER;


  BEGIN
     lv_procedure_name  := '.range_code';

     hr_utility.trace('Entering ' || gv_package || lv_procedure_name);
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     ln_step := 1;
     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_effective_date    => ld_date_earned
                            ,p_business_group_id => ln_business_group_id
                            ,p_legal_employer_id => ln_legal_employer_id
                            ,p_asg_set_id        => ln_asg_set_id
                            ,p_batch_name        => lv_batch_name);

--     IF ln_min_days_worked > 0 THEN
--        NULL;
--     ELSE
--        ln_min_days_worked := 0;
--     END IF;

     hr_utility.set_location(gv_package || lv_procedure_name, 20);

     ld_end_date := add_months(ld_start_date, 12) - 1;

     ln_step := 2;
     pay_mx_yrend_arch.load_gre (ln_business_group_id,
                                 ln_legal_employer_id,
                                 ld_end_date);

     ln_step := 3;

     IF ln_asg_set_id IS NULL THEN

        lv_sql_string :=
            'SELECT DISTINCT paf.person_id
               FROM pay_assignment_actions paa,
                    pay_payroll_actions    ppa,
                    per_assignments_f      paf
              WHERE ppa.business_group_id  = ' || ln_business_group_id || '
                AND ppa.effective_date BETWEEN fnd_date.canonical_to_date(''' ||
                fnd_date.date_to_canonical(ld_start_date) || ''')
                                           AND fnd_date.canonical_to_date(''' ||
                fnd_date.date_to_canonical(ld_end_date) || ''')
                AND ppa.action_type IN (''Q'',''R'',''B'',''V'',''I'')
                AND ppa.payroll_action_id = paa.payroll_action_id
                AND paa.source_action_id IS NULL
                AND paf.assignment_id = paa.assignment_id
                AND ppa.effective_date BETWEEN paf.effective_start_date
                                           AND paf.effective_end_date
                AND pay_mx_yrend_arch.gre_exists (paa.tax_unit_id) = 1
                AND :payroll_action_id > 0
           ORDER BY paf.person_id';
     ELSE
        lv_sql_string :=
            'SELECT DISTINCT paf.person_id
               FROM pay_assignment_actions paa,
                    pay_payroll_actions    ppa,
                    per_assignments_f      paf
              WHERE ppa.business_group_id  = ' || ln_business_group_id || '
                AND ppa.effective_date BETWEEN fnd_date.canonical_to_date(''' ||
                fnd_date.date_to_canonical(ld_start_date) || ''')
                                           AND fnd_date.canonical_to_date(''' ||
                fnd_date.date_to_canonical(ld_end_date) || ''')
                AND ppa.action_type IN (''Q'',''R'',''B'',''V'',''I'')
                AND ppa.payroll_action_id = paa.payroll_action_id
                AND paa.source_action_id IS NULL
                AND paf.assignment_id = paa.assignment_id
                AND ppa.effective_date BETWEEN paf.effective_start_date
                                           AND paf.effective_end_date
                AND pay_mx_yrend_arch.gre_exists (paa.tax_unit_id) = 1
                AND (NOT EXISTS
                      (SELECT ''x''
                         FROM hr_assignment_set_amendments hasa
                        WHERE hasa.assignment_set_id = ' || ln_asg_set_id || '
                          AND hasa.include_or_exclude = ''I'')
                     OR EXISTS
                      (SELECT ''x''
                         FROM hr_assignment_sets has,
                              hr_assignment_set_amendments hasa,
                              per_assignments_f  paf_all
                        WHERE has.assignment_set_id = ' || ln_asg_set_id || '
                        AND   has.assignment_set_id = hasa.assignment_set_id
                        AND   hasa.assignment_id = paf_all.assignment_id
                        AND   paf_all.person_id = paf.person_id
                        AND   hasa.include_or_exclude = ''I'')
                    )
                AND NOT EXISTS
                      (SELECT ''x''
                         FROM hr_assignment_sets has,
                              hr_assignment_set_amendments hasa,
                              per_assignments_f  paf_all
                        WHERE has.assignment_set_id = ' || ln_asg_set_id || '
                        AND   has.assignment_set_id = hasa.assignment_set_id
                        AND   hasa.assignment_id = paf_all.assignment_id
                        AND   paf_all.person_id = paf.person_id
                        AND   hasa.include_or_exclude = ''E'')
                AND :payroll_action_id > 0
           ORDER BY paf.person_id';

     END IF; -- ln_asg_set_id is null

     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     p_sqlstr := lv_sql_string;
     hr_utility.trace ('SQL string :' ||p_sqlstr);
     hr_utility.set_location(gv_package || lv_procedure_name, 50);
     hr_utility.trace('Leaving ' || gv_package || lv_procedure_name);

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


  END range_code;

/************************************************************
   Name      : assignment_action_code
   Purpose   : This creates the assignment actions for
               a specific chunk of people to be archived
               by the Profit Sharing (PTU) process.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ************************************************************/
  PROCEDURE assignment_action_code(
                 p_payroll_action_id IN NUMBER
                ,p_start_person_id   IN NUMBER
                ,p_end_person_id     IN NUMBER
                ,p_chunk             IN NUMBER)
  IS

    CURSOR c_chk_asg (cp_asg_set_id NUMBER,
                      cp_person_id  NUMBER) IS
        SELECT 'X'
          FROM dual
         WHERE (EXISTS(SELECT 'x'
                         FROM hr_assignment_set_amendments hasa
                        WHERE hasa.assignment_set_id = cp_asg_set_id
                          AND hasa.include_or_exclude = 'I')
                     AND NOT EXISTS
                      (SELECT 'x'
                         FROM hr_assignment_sets has,
                              hr_assignment_set_amendments hasa,
                              per_assignments_f  paf_all
                        WHERE has.assignment_set_id = cp_asg_set_id
                        AND   has.assignment_set_id = hasa.assignment_set_id
                        AND   hasa.assignment_id = paf_all.assignment_id
                        AND   paf_all.person_id = cp_person_id
                        AND   hasa.include_or_exclude = 'I')
               )
            OR EXISTS (SELECT 'x'
                         FROM hr_assignment_sets has,
                              hr_assignment_set_amendments hasa,
                              per_assignments_f  paf_all
                        WHERE has.assignment_set_id = cp_asg_set_id
                        AND   has.assignment_set_id = hasa.assignment_set_id
                        AND   hasa.assignment_id = paf_all.assignment_id
                        AND   paf_all.person_id = cp_person_id
                        AND   hasa.include_or_exclude = 'E');

    CURSOR c_get_emp_asg_range (cp_bg_id         NUMBER,
                                cp_incl_temp_EEs VARCHAR2,
                                cp_start_date    DATE,
                                cp_end_date      DATE) IS
        SELECT --DISTINCT
               paf_pri.assignment_id,
               paf_pri.person_id,
               NVL(paf.employment_category, 'MX1_PERM_WRK'),
               paa.tax_unit_id
          FROM per_assignments_f      paf,
               per_assignments_f      paf_pri,
               pay_assignment_actions paa,
               pay_payroll_actions    ppa,
               pay_population_ranges  ppr
         WHERE ppa.business_group_id         = cp_bg_id
           AND paf.assignment_id             = paa.assignment_id
           AND pay_mx_yrend_arch.gre_exists(paa.tax_unit_id) = 1
           AND ppr.payroll_action_id         = p_payroll_action_id
           AND ppr.chunk_number              = p_chunk
           AND ppr.person_id                 = paf.person_id
           AND paf.person_id                 = paf_pri.person_id
           AND paf_pri.primary_flag          = 'Y'
           AND paa.payroll_action_id         = ppa.payroll_action_id
           AND ppa.action_type              IN ('Q','R','B','V','I')
           AND ppa.effective_date      BETWEEN cp_start_date
                                           AND cp_end_date
           AND (paf.employment_category NOT IN ('MX2_TEMP_WRK',
                                                'MX3_TEMP_CONSTRCT_WRK')
                 OR
               cp_incl_temp_EEs              = 'Y')
           AND paf_pri.effective_start_date <= cp_end_date
           AND paf_pri.effective_end_date   >= cp_start_date
           AND ppa.effective_date      BETWEEN paf.effective_start_date
                                           AND paf.effective_end_date
        ORDER BY paf_pri.person_id,
                 NVL(paf.employment_category, 'MX1_PERM_WRK'),
                 paf_pri.effective_end_date DESC;

    CURSOR c_get_emp_asg (cp_bg_id         NUMBER,
                          cp_incl_temp_EEs VARCHAR2,
                          cp_start_date    DATE,
                          cp_end_date      DATE) IS
        SELECT --DISTINCT
               paf_pri.assignment_id,
               paf_pri.person_id,
               NVL(paf.employment_category, 'MX1_PERM_WRK'),
               paa.tax_unit_id
          FROM pay_assignment_actions paa,
               pay_payroll_actions    ppa,
               per_assignments_f      paf,
               per_assignments_f      paf_pri
         WHERE ppa.business_group_id         = cp_bg_id
           AND ppa.effective_date      BETWEEN cp_start_date
                                           AND cp_end_date
           AND ppa.action_type              IN ('Q','R','B','V','I')
           AND ppa.payroll_action_id         = paa.payroll_action_id
           AND paa.source_action_id         IS NULL
           AND paf.assignment_id             = paa.assignment_id
           AND paf_pri.person_id             = paf.person_id
           AND paf_pri.primary_flag          = 'Y'
           AND ppa.effective_date      BETWEEN paf.effective_start_date
                                           AND paf.effective_end_date
           AND paf_pri.effective_start_date <= cp_end_date
           AND paf_pri.effective_end_date   >= cp_start_date
           AND pay_mx_yrend_arch.gre_exists(paa.tax_unit_id) = 1
           AND paf.person_id           BETWEEN p_start_person_id
                                           AND p_end_person_id
           AND (paf.employment_category NOT IN ('MX2_TEMP_WRK',
                                                'MX3_TEMP_CONSTRCT_WRK')
                 OR
               cp_incl_temp_EEs              = 'Y')
        ORDER BY paf_pri.person_id,
                 NVL(paf.employment_category, 'MX1_PERM_WRK'),
                 paf_pri.effective_end_date DESC;

    -- Check if Batch Name already exists in PAY_BATCH_HEADERS
    CURSOR c_chk_batch_name_exists(cp_batch_name        VARCHAR2,
                                   cp_business_group_id NUMBER) IS
      SELECT 'Y'
        FROM pay_batch_headers
       WHERE business_group_id = cp_business_group_id
         AND UPPER(cp_batch_name) = UPPER(batch_name);

    -- Check if assignment exists as on the Date Paid for Profit Sharing
    CURSOR c_chk_asg_valid(cp_assignment_id  NUMBER,
                           cp_effective_date DATE
              ) IS
      SELECT 'X'
        FROM dual
       WHERE NOT EXISTS(SELECT 'Y'
                          FROM per_assignments_f
                         WHERE assignment_id = cp_assignment_id
                           AND cp_effective_date BETWEEN effective_start_date
                                                     AND effective_end_date);

    -- Get CURP for the person
    CURSOR c_get_EE_no(cp_person_id  NUMBER) IS
      SELECT employee_number
        FROM per_people_f
       WHERE person_id = cp_person_id
    ORDER BY effective_end_date DESC;

    ln_assignment_id         NUMBER;
    ln_tax_unit_id           NUMBER;

    ld_end_date              DATE;
    ld_start_date            DATE;
    ld_date_earned           DATE;
    ln_business_group_id     NUMBER;
    ln_legal_employer_id     NUMBER;
    ln_asg_set_id            NUMBER;
    lv_incl_temp_EEs         VARCHAR2(1);
    ln_min_days_worked       NUMBER;
    lv_batch_name            pay_batch_headers.batch_name%TYPE;

    ln_PTU_action_id         NUMBER;
    ln_employment_category   per_all_assignments_f.employment_category%TYPE;
    ln_ytd_aaid              NUMBER;
    lv_batch_name_exists     VARCHAR2(1);

    lv_procedure_name        VARCHAR2(100);
    lv_error_message         VARCHAR2(200);
    ln_step                  NUMBER;
    ln_ovn                   NUMBER;

    lb_range_person          BOOLEAN;
    ln_person_id             NUMBER;
    ln_prev_person_id        NUMBER;
    lv_excl_flag             VARCHAR2(2);
    lv_run_exists            VARCHAR2(2);

    lb_action_created        BOOLEAN;
    lb_valid_pri_asg_found   BOOLEAN;
    ln_skipped_person_id     NUMBER;
    BATCH_EXISTS             EXCEPTION;

    /* Variables for Factors Calculation */

    lv_legal_ER_name        hr_all_organization_units_tl.name%TYPE;

    ln_factor_A              NUMBER;
    ln_factor_B              NUMBER :=0;
    ln_factor_C              NUMBER :=0;
    ln_factor_D              NUMBER;
    ln_factor_D_used         NUMBER;
    ln_factor_E              NUMBER;
    ln_factor_F              NUMBER;
    ln_factor_G              NUMBER;
    ln_factor_H              NUMBER;
    ln_factor_I              NUMBER;

    ln_factor_F_found        BOOLEAN;
    ln_factor_G_found        BOOLEAN;
    ln_factor_F_total        NUMBER;
    ln_factor_G_total        NUMBER;

    ln_action_information_id NUMBER;
    ln_object_version_number NUMBER;

    lv_EE_no                 per_all_people_f.employee_number%TYPE;

  BEGIN
     lv_procedure_name  := '.assignment_action_code';
     hr_utility.trace('Entering ' || gv_package || lv_procedure_name);

     ln_person_id      := -1;
     ln_prev_person_id := -1;
     lv_excl_flag      := '-1';
     lb_action_created := FALSE;

     hr_utility.trace('p_payroll_action_id = '|| p_payroll_action_id);
     hr_utility.trace('p_start_person_id = '|| p_start_person_id);
     hr_utility.trace('p_end_person_id = '|| p_end_person_id);
     hr_utility.trace('p_chunk = '|| p_chunk);

     ln_step := 1;
--   pay_emp_action_arch.gv_error_message := NULL;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_effective_date    => ld_date_earned
                            ,p_business_group_id => ln_business_group_id
                            ,p_legal_employer_id => ln_legal_employer_id
                            ,p_asg_set_id        => ln_asg_set_id
                            ,p_batch_name        => lv_batch_name);

     lv_legal_ER_name := hr_general.decode_organization(ln_legal_employer_id);

     ld_end_date := ADD_MONTHS(ld_start_date, 12) - 1;

     BEGIN
       g_ptu_calc_method := NVL(hruserdt.get_table_value(ln_business_group_id,
                                                         'PTU Factors',
                                                         'Calculation Method',
                                                         lv_legal_ER_name,
                                                         ld_end_date),
                                                                  'DAILY_WAGE');
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
            g_ptu_calc_method := 'DAILY_WAGE';
     END;

     BEGIN
         lv_incl_temp_EEs := NVL(hruserdt.get_table_value(ln_business_group_id,
                                                          'PTU Factors',
                                             'Include Temporary Workers (Y/N)?',
                                                          lv_legal_ER_name,
                                                          ld_end_date), 'Y');
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            lv_incl_temp_EEs := 'Y';
     END;

     BEGIN
         ln_min_days_worked := NVL(TO_NUMBER(hruserdt.get_table_value(
                                                          ln_business_group_id,
                                                          'PTU Factors',
                                                          'Minimum Days Worked',
                                                          lv_legal_ER_name,
                                                          ld_end_date)), 0);
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ln_min_days_worked := 0;
     END;

     ln_step := 2;
     IF g_worked_days_def_bal_id IS NULL THEN

         g_worked_days_def_bal_id := pay_ac_utility.get_defined_balance_id(
                                     'Eligible Worked Days for Profit Sharing',
                                     '_PER_GRE_YTD',
                                     NULL,
                                     'MX');
     END IF;

     g_elig_comp_def_bal_id := pay_ac_utility.get_defined_balance_id(
                                     'Eligible Compensation for Profit Sharing',
                                     '_PER_GRE_YTD',
                                     NULL,
                                     'MX');


     IF ln_min_days_worked > 0 THEN
        hr_utility.set_location(gv_package || lv_procedure_name, 20);

     ELSE
        hr_utility.set_location(gv_package || lv_procedure_name, 30);
        ln_min_days_worked := 0;
     END IF;

     hr_utility.set_location(gv_package || lv_procedure_name, 40);

     ln_step := 3;
     IF pay_mx_yrend_arch.g_gre_tab.count() = 0 THEN

         hr_utility.set_location(gv_package || lv_procedure_name, 50);

         --------------------------------------------------------------
         -- Load the cache with the GREs under the given Legal Employer
         --------------------------------------------------------------
         pay_mx_yrend_arch.load_gre (ln_business_group_id,
                                     ln_legal_employer_id,
                                     ld_end_date);
     END IF;

     BEGIN
         ln_factor_F := hruserdt.get_table_value(ln_business_group_id,
                                                 'PTU Factors',
                                                 'Total Worked Days (Factor F)',
                                                 lv_legal_ER_name,
                                                 ld_end_date);
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ln_factor_F := NULL;
     END;

     BEGIN
         ln_factor_G := hruserdt.get_table_value(ln_business_group_id,
                                                 'PTU Factors',
                                       'Total Capped Average Salary (Factor G)',
                                                 lv_legal_ER_name,
                                                 ld_end_date);
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ln_factor_G := NULL;
     END;

     hr_utility.trace('Values from PTU Factors Table IN ACTION_CODE');
     hr_utility.trace('Factor F: ' || ln_factor_F);
     hr_utility.trace('Factor G: ' || ln_factor_G);

     IF NVL(ln_factor_F, 0) = 0 THEN
        ln_factor_F_found := FALSE;
     ELSE
        ln_factor_F_found := TRUE;
--        ln_factor_F_total := ROUND(ln_factor_F,4);
     END IF;

     IF NVL(ln_factor_G, 0) = 0 THEN
        ln_factor_G_found := FALSE;
     ELSE
        ln_factor_G_found := TRUE;
--        ln_factor_G_total := ROUND(ln_factor_G,4);
     END IF;

     ln_step := 4;
     lb_range_person := pay_ac_utility.range_person_on(
                           p_report_type      => 'MX_PTU_CALC'
                          ,p_report_format    => 'MX_PTU_CALC'
                          ,p_report_qualifier => 'MX'
                          ,p_report_category  => 'ARCHIVE');

--   FOR cntr_gre IN
--       pay_mx_yrend_arch.g_gre_tab.first()..pay_mx_yrend_arch.g_gre_tab.last()
--   LOOP

     IF lb_range_person THEN
         hr_utility.set_location(gv_package || lv_procedure_name, 60);

         OPEN c_get_emp_asg_range(ln_business_group_id,
                                  lv_incl_temp_EEs,
                                  ld_start_date,
                                  ld_end_date);
     ELSE
         hr_utility.set_location(gv_package || lv_procedure_name, 70);

         OPEN c_get_emp_asg (ln_business_group_id,
                             lv_incl_temp_EEs,
                             ld_start_date,
                             ld_end_date);
     END IF;

     LOOP
         IF lb_range_person THEN
             FETCH c_get_emp_asg_range INTO ln_assignment_id,
                                            ln_person_id,
                                            ln_employment_category,
                                            ln_tax_unit_id;
             EXIT WHEN c_get_emp_asg_range%NOTFOUND;
         ELSE
             FETCH c_get_emp_asg INTO ln_assignment_id,
                                      ln_person_id,
                                      ln_employment_category,
                                      ln_tax_unit_id;
             EXIT WHEN c_get_emp_asg%NOTFOUND;
         END IF;

         hr_utility.trace('Previous person ID = ' || ln_prev_person_id);
         hr_utility.trace('Current person ID = ' || ln_person_id);
         hr_utility.trace('Assignment ID= ' || ln_assignment_id);
         hr_utility.trace('Employment Category= ' || ln_employment_category);

         IF ln_person_id <> ln_prev_person_id THEN

             hr_utility.set_location(gv_package || lv_procedure_name,80);
             ln_step := 5;

             OPEN  c_get_ytd_aaid(ld_start_date,
                                  ld_end_date,
                                  ln_person_id);

             FETCH c_get_ytd_aaid INTO ln_ytd_aaid;
             CLOSE c_get_ytd_aaid;

             IF ln_employment_category IN ('MX2_TEMP_WRK',
                                           'MX3_TEMP_CONSTRCT_WRK') THEN

                 hr_utility.set_location(gv_package ||lv_procedure_name,90);

                 --------------------------------------------------------
                 -- Check if worked days exceed the minimum limit.
                 --------------------------------------------------------
		 /* bug 8437173 area 1*/
               FOR cntr_gre IN
                   pay_mx_yrend_arch.g_gre_tab.first()..pay_mx_yrend_arch.g_gre_tab.last()
                LOOP
                  pay_balance_pkg.set_context('TAX_UNIT_ID',  pay_mx_yrend_arch.g_gre_tab(cntr_gre));
                  ln_factor_B := ln_factor_B + NVL(pay_balance_pkg.get_value(
                                                    g_worked_days_def_bal_id,
                                                    ln_ytd_aaid), 0);
               END LOOP;

                 IF ln_min_days_worked > ln_factor_B THEN
                     ----------------------------------------------------
                     -- The temporary worker hasn't worked the stipulated
                     -- number of days during the Profit Sharing year
                     -- and is therefore ineligible for PTU.
                     ----------------------------------------------------
                     hr_utility.set_location(gv_package ||
                                             lv_procedure_name, 95);
                     lv_excl_flag := 'X';

                 END IF;

             END IF;

             IF lv_excl_flag <> 'X' THEN
                 /*Bug#9066172: Initialize factor_B and factor_C as we need
                   to have these factors accumulated only for the employee
                   being processed now */
                   ln_factor_B :=0;
                   ln_factor_C :=0;
                 ------------------------------------------------------------
                 -- The person is eligible for PTU. Include the factors B and
                 -- C into the factor F and G running totals for this chunk.
                 ------------------------------------------------------------

                 IF ln_factor_G_found = FALSE OR ln_factor_F_found = FALSE THEN

                     hr_utility.set_location(gv_package ||
                                             lv_procedure_name, 999);

                  /* bug 8437173 area 2*/
		              FOR cntr_gre IN
                      pay_mx_yrend_arch.g_gre_tab.first()..pay_mx_yrend_arch.g_gre_tab.last()
                  LOOP
                      pay_balance_pkg.set_context('TAX_UNIT_ID',  pay_mx_yrend_arch.g_gre_tab(cntr_gre));

                     ln_factor_B := ln_factor_B + NVL(pay_balance_pkg.get_value(
                                                   g_worked_days_def_bal_id,
                                                   ln_ytd_aaid), 0);
                  END LOOP;

                     hr_utility.set_location(gv_package ||
                                             lv_procedure_name, 998);

                     IF ( ln_factor_B <> 0 ) THEN

                    /*     ln_factor_B := ln_factor_B; */

                      /* bug 8437173 area 3*/
                      FOR cntr_gre IN
                          pay_mx_yrend_arch.g_gre_tab.first()..pay_mx_yrend_arch.g_gre_tab.last()
                      LOOP
                          pay_balance_pkg.set_context('TAX_UNIT_ID',  pay_mx_yrend_arch.g_gre_tab(cntr_gre));

                         ln_factor_C :=ln_factor_C + NVL(pay_balance_pkg.get_value(
                                                   g_elig_comp_def_bal_id,
                                                   ln_ytd_aaid), 0);

                      END LOOP;
                        /* ln_factor_C := ln_factor_C;*/

                         BEGIN

                             ln_factor_D := 1.2 *
                                            hruserdt.get_table_value(
                                                 ln_business_group_id,
                                                 'PTU Factors',
                                                 'Highest Average Daily Salary',
                                                 lv_legal_ER_name,
                                                 ld_end_date) ;

                         EXCEPTION
                             WHEN NO_DATA_FOUND THEN
                                hr_utility.set_message(801,
                                                   'PAY_MX_PTU_INPUTS_MISSING');
                                hr_utility.raise_error;
                         END;

                         IF NVL(ln_factor_D, 0) = 0 THEN

                             hr_utility.set_message(801,
                                                   'PAY_MX_PTU_INPUTS_MISSING');
                             hr_utility.raise_error;

                         END IF;

                         get_capped_average_earnings(
                              p_ptu_calc_method  =>g_ptu_calc_method,
                              p_days_in_year     =>ld_end_date - ld_start_date,
                              p_business_group_id=>ln_business_group_id,
                              p_legal_employer_id=>ln_legal_employer_id,
                              p_factor_B         =>ln_factor_B,
                              p_factor_C         =>ln_factor_C,
                              p_factor_D         =>ln_factor_D,
                              p_factor_D_used    =>ln_factor_D_used,
                              p_factor_E         =>ln_factor_E);

--                       ln_factor_G_total := ROUND( nvl(ln_factor_G_total,0) +
--                                                   ln_factor_E, 4);
                         ln_factor_G_total := NVL(ln_factor_G_total,0) +
                                              ln_factor_E;

                        --IF ln_factor_F_found = FALSE THEN

                         hr_utility.set_location(gv_package ||
                                                 lv_procedure_name, 888);
--                       ln_factor_F_total := ROUND( nvl(ln_factor_F_total,0) +
--                                                   ln_factor_B, 4);

                         ln_factor_F_total := NVL(ln_factor_F_total,0) +
                                              ln_factor_B;
                        --END IF;

                     END IF;

                 END IF;

                 IF ln_asg_set_id IS NOT NULL THEN

                     hr_utility.set_location(gv_package ||
                                             lv_procedure_name, 100);
                     ------------------------------------------------------
                     -- Check if the assignment set excludes this person
                     ------------------------------------------------------
                     OPEN c_chk_asg (ln_asg_set_id, ln_person_id);
                     FETCH c_chk_asg INTO lv_excl_flag;
                     CLOSE c_chk_asg;

                 END IF;

                 ln_step := 6;

                 IF lv_excl_flag <> 'X' THEN

                     -----------------------------------------------------------
                     -- No assignment set exclusions apply.
                     -----------------------------------------------------------

                     hr_utility.set_location(gv_package ||
                                             lv_procedure_name, 110);

                     OPEN  c_chk_asg_valid(ln_assignment_id,
                                           ld_date_earned);
                     FETCH c_chk_asg_valid INTO lv_excl_flag;
                     CLOSE c_chk_asg_valid;

                     IF lv_excl_flag <> 'X' THEN

                         hr_utility.set_location(gv_package ||lv_procedure_name,
                                                                           120);
                         ln_prev_person_id := ln_person_id;

                         IF NOT lb_valid_pri_asg_found AND
                                       ln_skipped_person_id <> ln_person_id THEN

                             ---------------------------------------------------
                             -- The Previous person doesn't have a single valid
                             -- primary assignment as on the Profit Sharing Date
                             -- Paid. Log a message for the same.
                             ---------------------------------------------------
                             hr_utility.set_location(gv_package ||
                                                     lv_procedure_name, 130);

                             OPEN  c_get_EE_no(ln_skipped_person_id);
                             FETCH c_get_EE_no INTO lv_EE_no;
                             CLOSE c_get_EE_no;

                             pay_core_utils.push_message(801,
                                                   'PAY_MX_MISSING_ASG_FOR_PTU',
                                                   'P');
                             pay_core_utils.push_token('DETAILS',
                                                       'EE: ' || lv_EE_no);

                         END IF;

                         lb_valid_pri_asg_found := TRUE;

                         SELECT pay_assignment_actions_s.NEXTVAL
                           INTO ln_PTU_action_id
                           FROM dual;

                         hr_nonrun_asact.insact(ln_PTU_action_id,
                                                ln_assignment_id,
                                                p_payroll_action_id,
                                                p_chunk,
                                                ln_tax_unit_id,
                                                NULL,
                                                'U',
                                                NULL,
                                                ln_assignment_id,
                                                'ASG');

                         lb_action_created := TRUE;
                         pay_mx_tax_functions.g_temp_object_actions := TRUE;

                         hr_utility.set_location(gv_package ||
                                                      lv_procedure_name, 140);

                         hr_utility.trace('PTU asg action ' ||
                                           ln_PTU_action_id || ' created.');

                     ELSE
                         -------------------------------------------------------
                         -- The primary assignment is not valid on the Profit
                         -- Sharing Date Paid. Set a flag to check if any other
                         -- primary assignment exists on that date for that
                         -- person.
                         -------------------------------------------------------
                         hr_utility.set_location(gv_package ||
                                                 lv_procedure_name, 150);
                         lb_valid_pri_asg_found := FALSE;
                         ln_skipped_person_id   := ln_person_id;
                         lv_excl_flag           := '-1';

                     END IF;

                 ELSE
                     hr_utility.trace('Assignment is excluded in asg set.');
                     ln_prev_person_id := ln_person_id;
                     lv_excl_flag := '-1';
                 END IF;
             ELSE
                 hr_utility.trace('Temporary worker criterion not satisfied');
                 lv_excl_flag := '-1';
             END IF;
         ELSE
             hr_utility.trace('The assignment action creation has been ' ||
                              'either already done or skipped for this ' ||
                              'person.');
         END IF;
     END LOOP;

     IF lb_range_person THEN
         CLOSE c_get_emp_asg_range;
     ELSE
         CLOSE c_get_emp_asg;
     END IF;

     IF NOT lb_valid_pri_asg_found THEN

         ---------------------------------------------------------
         -- The Last person didn't have a single valid
         -- primary assignment as on the Profit Sharing Date
         -- Paid. Log a message for the same.
         ---------------------------------------------------------
         hr_utility.set_location(gv_package || lv_procedure_name, 160);

         OPEN  c_get_EE_no(ln_skipped_person_id);
         FETCH c_get_EE_no INTO lv_EE_no;
         CLOSE c_get_EE_no;

         pay_core_utils.push_message(801, 'PAY_MX_MISSING_ASG_FOR_PTU', 'P');
         pay_core_utils.push_token('DETAILS', 'EE: ' || lv_EE_no);

     END IF;

     IF ln_factor_G_found = FALSE OR ln_factor_F_found = FALSE THEN


--        ln_factor_F_total := ROUND( ln_factor_F_total, 4 );
--        ln_factor_G_total := ROUND( ln_factor_G_total, 4 );

        pay_action_information_api.create_action_information(
                  p_action_information_id       => ln_action_information_id
                 ,p_object_version_number       => ln_object_version_number
                 ,p_action_information_category => 'MX PROFIT SHARING FACTORS'
                 ,p_action_context_id           => p_payroll_action_id
                 ,p_action_context_type         => 'PA'
                 ,p_jurisdiction_code           => NULL
                 ,p_tax_unit_id                 => ln_legal_employer_id
                 ,p_effective_date              => ld_date_earned
                 ,p_action_information1         => p_chunk
                 ,p_action_information2         =>
                                    SUBSTR(TO_CHAR(ln_factor_F_total), 1, 240)
                 ,p_action_information3         =>
                                    SUBSTR(TO_CHAR(ln_factor_G_total), 1, 240));

        ln_factor_F_total := 0;
        ln_factor_G_total := 0;

     END IF;

     ln_step := 7;
     lv_batch_name_exists := 'N';

     IF lb_action_created AND p_chunk = 1 THEN

         OPEN  c_chk_batch_name_exists(lv_batch_name,
                                       ln_business_group_id);
         FETCH c_chk_batch_name_exists INTO lv_batch_name_exists;
         CLOSE c_chk_batch_name_exists;

         IF lv_batch_name_exists = 'Y' THEN
             raise BATCH_EXISTS;
         END IF;

         pay_batch_element_entry_api.create_batch_header(
             p_session_date          => ld_date_earned,
             p_batch_name            => lv_batch_name,
             p_business_group_id     => ln_business_group_id,
             p_batch_id              => g_batch_id,
             p_object_version_number => ln_ovn);

     END IF;

     hr_utility.trace('Leaving ' || gv_package || lv_procedure_name);

  EXCEPTION
    WHEN BATCH_EXISTS THEN

      hr_utility.set_message(800, 'HR_BATCH_NAME_ALREADY_EXISTS');
      hr_utility.raise_error;

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
    Purpose   : This loads the values common to all assignments
                into a PL-SQL cache.
    Arguments :
    Notes     :
  ************************************************************/

  PROCEDURE initialization_code(p_payroll_action_id IN NUMBER) IS
  --
    lv_procedure_name       VARCHAR2(100);
    lv_error_message        VARCHAR2(200);
    ln_step                 NUMBER;

    ld_end_date             DATE;
    ld_start_date           DATE;
    ld_date_earned          DATE;
    ln_business_group_id    NUMBER;
    ln_legal_employer_id    NUMBER;
    ln_asg_set_id           NUMBER;
--    lv_incl_temp_EEs        VARCHAR2(1);
--    ln_min_days_worked      NUMBER;
    lv_batch_name           pay_batch_headers.batch_name%TYPE;

    lv_legal_ER_name        hr_all_organization_units_tl.name%TYPE;

    ln_tot_share_amt        NUMBER;
    ln_factor_A             NUMBER;
    ln_factor_B             NUMBER;
    ln_factor_C             NUMBER;
    ln_factor_D             NUMBER;
    ln_factor_E             NUMBER;
    ln_factor_F             NUMBER;
    ln_factor_G             NUMBER;
    ln_factor_H             NUMBER;
    ln_factor_I             NUMBER;

    -- Query to retrieve all the persons eligible for
    -- Profit Sharing  under the given Legal Employer
    --
    CURSOR c_get_elig_persons
    IS
    SELECT DISTINCT paf.person_id
      FROM pay_temp_object_actions ptoa,
           per_assignments_f       paf,
           pay_payroll_actions     ppa
     WHERE ptoa.payroll_action_id = p_payroll_action_id
       AND paf.assignment_id      = ptoa.object_id
       AND ptoa.object_type       = 'ASG'
       AND ppa.payroll_action_id  = ptoa.payroll_action_id
       AND ppa.effective_date BETWEEN paf.effective_start_date
                                  AND paf.effective_end_date
    ORDER BY paf.person_id;

    -- Get element details for PTU element
    CURSOR c_get_PTU_ele_details
    IS
    SELECT element_type_id
      FROM pay_element_types_f
     WHERE element_name = 'Profit Sharing'
       AND legislation_code = 'MX';

    -- Get Total of Factors F and G

    CURSOR c_get_factors (cp_payroll_action_id NUMBER)
    IS
    SELECT NVL (SUM( NVL(pai.action_information2,0) ), 0) Factor_F,
           NVL (SUM( NVL(pai.action_information3,0) ), 0) Factor_G
      FROM pay_action_information pai
     WHERE pai.action_context_id           = cp_payroll_action_id
       AND pai.action_context_type         = 'PA'
       AND pai.action_information_category = 'MX PROFIT SHARING FACTORS';

    -- Get Batch ID

    CURSOR c_get_batch_id(cp_batch_name        VARCHAR2,
                          cp_business_group_id NUMBER) IS

      SELECT batch_id
        FROM pay_batch_headers
       WHERE business_group_id = cp_business_group_id
         AND UPPER(cp_batch_name) = UPPER(batch_name);

  BEGIN
     lv_procedure_name  := '.initialization_code';

     ln_step := 1;

     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_effective_date    => ld_date_earned
                            ,p_business_group_id => ln_business_group_id
                            ,p_legal_employer_id => ln_legal_employer_id
                            ,p_asg_set_id        => ln_asg_set_id
                            ,p_batch_name        => lv_batch_name);

     ld_end_date         := ADD_MONTHS(ld_start_date, 12) - 1;
     gd_start_date       := ld_start_date;
     gd_end_date         := ld_end_date;
     gn_legal_employer_id:= ln_legal_employer_id;

     OPEN  c_get_batch_id( lv_batch_name
                          ,ln_business_group_id);
     FETCH c_get_batch_id into g_batch_id;
     CLOSE c_get_batch_id;

     IF pay_mx_yrend_arch.g_gre_tab.count() = 0 THEN

         hr_utility.set_location(gv_package || lv_procedure_name, 20);

         --------------------------------------------------------------
         -- Load the cache with the GREs under the given Legal Employer
         --------------------------------------------------------------
         pay_mx_yrend_arch.load_gre (ln_business_group_id,
                                     ln_legal_employer_id,
                                     ld_end_date);
     END IF;
       /*bug 8437173 area 4 */
     IF g_worked_days_def_bal_id IS NULL THEN

         hr_utility.set_location(gv_package || lv_procedure_name, 30);

         g_worked_days_def_bal_id := pay_ac_utility.get_defined_balance_id(
                                     'Eligible Worked Days for Profit Sharing',
                                     '_PER_GRE_YTD',
                                     NULL,
                                     'MX');
     END IF;

     g_elig_comp_def_bal_id := pay_ac_utility.get_defined_balance_id(
                                     'Eligible Compensation for Profit Sharing',
                                     '_PER_GRE_YTD',
                                     NULL,
                                     'MX');

     lv_legal_ER_name := hr_general.decode_organization(ln_legal_employer_id);

     hr_utility.set_location(gv_package || lv_procedure_name, 40);

     OPEN  c_get_PTU_ele_details;
     FETCH c_get_PTU_ele_details INTO g_PTU_ele_type_id;
     CLOSE c_get_PTU_ele_details;

--     IF ln_min_days_worked > 0 THEN
--        hr_utility.set_location(gv_package || lv_procedure_name, 50);

--     ELSE
--        hr_utility.set_location(gv_package || lv_procedure_name, 60);
--        ln_min_days_worked := 0;
--     END IF;

     ln_step := 2;

     BEGIN
         ln_tot_share_amt := hruserdt.get_table_value(ln_business_group_id,
                                                      'PTU Factors',
                                                      'Total Amount to Share',
                                                      lv_legal_ER_name,
                                                      ld_end_date);
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            hr_utility.set_message(801,'PAY_MX_PTU_INPUTS_MISSING');
            hr_utility.raise_error;
     END;

     ln_factor_A := ln_tot_share_amt / 2;

     BEGIN
         ln_factor_D :=  1.2 *
                        hruserdt.get_table_value(ln_business_group_id,
                                                 'PTU Factors',
                                                 'Highest Average Daily Salary',
                                                 lv_legal_ER_name,
                                                 ld_end_date);
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            hr_utility.set_message(801,'PAY_MX_PTU_INPUTS_MISSING');
            hr_utility.raise_error;
     END;

     BEGIN
         ln_factor_F := hruserdt.get_table_value(ln_business_group_id,
                                                 'PTU Factors',
                                                 'Total Worked Days (Factor F)',
                                                 lv_legal_ER_name,
                                                 ld_end_date);
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ln_factor_F := NULL;
     END;

     BEGIN
         ln_factor_G := hruserdt.get_table_value(ln_business_group_id,
                                       'PTU Factors',
                                       'Total Capped Average Salary (Factor G)',
                                       lv_legal_ER_name,
                                       ld_end_date);
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ln_factor_G := NULL;
     END;

     hr_utility.trace('Values from PTU Factors Table');
     hr_utility.trace('Factor A: ' || ln_factor_A);
     hr_utility.trace('Factor D: ' || ln_factor_D);
     hr_utility.trace('Factor F: ' || ln_factor_F);
     hr_utility.trace('Factor G: ' || ln_factor_G);
     ln_step := 3;

     hr_utility.set_location(gv_package || lv_procedure_name, 70);

     IF NVL(ln_factor_A, 0) = 0 OR NVL(ln_factor_D, 0) = 0 THEN
            hr_utility.set_message(801,'PAY_MX_PTU_INPUTS_MISSING');
            hr_utility.raise_error;
     END IF;

     --
     IF NVL(ln_factor_G, 0) = 0 OR NVL(ln_factor_F, 0) = 0 THEN

        OPEN  c_get_factors (p_payroll_action_id);
        FETCH c_get_factors INTO ln_factor_F, ln_factor_G;
        CLOSE c_get_factors;

        ln_factor_F := ln_factor_F;
        ln_factor_G := ln_factor_G;

     END IF;


     /** Below condition has been put to avoid divide by zero **/

     IF ln_factor_F <> 0 THEN

        ln_factor_H := ln_factor_A / ln_factor_F;

     ELSE

        ln_factor_H := 0;

     END IF;

     IF ln_factor_G <> 0 THEN

        ln_factor_I := ln_factor_A / ln_factor_G;

     ELSE

        ln_factor_I := 0;

     END IF;

     BEGIN
       g_ptu_calc_method := NVL(hruserdt.get_table_value(ln_business_group_id,
                                                         'PTU Factors',
                                                         'Calculation Method',
                                                         lv_legal_ER_name,
                                                         ld_end_date),
                                                                  'DAILY_WAGE');
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
            g_ptu_calc_method := 'DAILY_WAGE';
     END;

     g_factor_A := ln_tot_share_amt;
     g_factor_D := ln_factor_D;
     g_factor_F := ln_factor_F;
     g_factor_G := ln_factor_G;
     g_factor_H := ln_factor_H;
     g_factor_I := ln_factor_I;

     hr_utility.trace('Global Values for PTU Factors');
     hr_utility.trace('g_factor_A: ' || g_factor_A);
     hr_utility.trace('g_factor_D: ' || g_factor_D);
     hr_utility.trace('g_factor_F: ' || g_factor_F);
     hr_utility.trace('g_factor_G: ' || g_factor_G);
     hr_utility.trace('g_factor_H: ' || g_factor_H);
     hr_utility.trace('g_factor_I: ' || g_factor_I);

     hr_utility.trace('Leaving ' || gv_package || lv_procedure_name);

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

  END initialization_code;

  /************************************************************
   Name      : archive_code
   Purpose   : This procedure performs assignment specific
               profit share calculations for the Profit Sharing
               process in Mexico.
   Arguments : p_archive_action_id            IN NUMBER
               p_effective_date               IN DATE
   Notes     :
  ************************************************************/
  PROCEDURE archive_code(p_archive_action_id  IN NUMBER
                        ,p_effective_date     IN DATE)
  IS
  --
    lv_procedure_name   VARCHAR2(100);
    lv_error_message    VARCHAR2(200);
    ln_step             NUMBER;

    ln_batch_line_id     NUMBER;
    ln_ovn               NUMBER;
    ln_assignment_id     NUMBER;
    lv_assignment_number per_assignments_f.assignment_number%TYPE;
    ln_person_id         NUMBER;

    ln_factor_B          NUMBER:=0;
    ln_factor_C          NUMBER:=0;
    ln_factor_D          NUMBER;
    ln_factor_E          NUMBER;
    ln_factor_J          NUMBER;
    ln_factor_K          NUMBER;

    ln_isr_subject       NUMBER;
    ln_isr_exempt        NUMBER;
    ln_business_group_id NUMBER;

    ln_payroll_action_id NUMBER;
    ln_ytd_asg_act_id    NUMBER;

    lv_lkup_meaning      VARCHAR2(100);

    ld_end_date             DATE;
    ld_start_date           DATE;
    ld_date_earned          DATE;
    ln_legal_employer_id    NUMBER;
    ln_asg_set_id           NUMBER;
    lv_batch_name           pay_batch_headers.batch_name%TYPE;
    lv_legal_ER_name        hr_all_organization_units_tl.name%TYPE;

    -- Get the person and assignment IDs
    CURSOR c_get_person
    IS
      SELECT paf.assignment_id,
             paf.assignment_number,
             paf.person_id,
             paf.business_group_id,
             ptoa.payroll_action_id
        FROM pay_temp_object_actions ptoa,
             per_assignments_f       paf,
             pay_payroll_actions     ppa
       WHERE ptoa.object_action_id    = p_archive_action_id
         AND paf.assignment_id        = ptoa.object_id
         AND ptoa.object_type         = 'ASG'
         AND ppa.payroll_action_id    = ptoa.payroll_action_id
         AND ppa.effective_date BETWEEN paf.effective_start_date
                                    AND paf.effective_end_date;

    -- Get meaning for Yes as per language used
    -- This is used for input values Separate Payment
    -- and Process Separately

    CURSOR c_get_lkup_meaning IS
      SELECT meaning
        FROM hr_lookups
       WHERE lookup_type = 'YES_NO'
         AND lookup_code = 'Y';
  BEGIN
     lv_procedure_name  := '.archive_code';
     hr_utility.trace('Entering ' || gv_package || lv_procedure_name);

     OPEN  c_get_person;
     FETCH c_get_person INTO ln_assignment_id,
                             lv_assignment_number,
                             ln_person_id,
                             ln_business_group_id,
                             ln_payroll_action_id;
     CLOSE c_get_person;

     hr_utility.trace('Assignment ID: ' || ln_assignment_id);
     hr_utility.trace('Person ID: ' || ln_person_id);

     hr_utility.trace('gd_start_date: '||gd_start_date);
     hr_utility.trace('gd_end_date: '||gd_end_date);

     get_payroll_action_info(p_payroll_action_id => ln_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_effective_date    => ld_date_earned
                            ,p_business_group_id => ln_business_group_id
                            ,p_legal_employer_id => ln_legal_employer_id
                            ,p_asg_set_id        => ln_asg_set_id
                            ,p_batch_name        => lv_batch_name);

     ld_end_date      := ADD_MONTHS(ld_start_date, 12) - 1;

     lv_legal_ER_name := hr_general.decode_organization(ln_legal_employer_id);

     hr_utility.trace('ld_end_date: '||ld_end_date);
     hr_utility.trace('lv_legal_ER_name: '||lv_legal_ER_name);

     BEGIN
       g_ptu_calc_method := NVL(hruserdt.get_table_value(ln_business_group_id,
                                                         'PTU Factors',
                                                         'Calculation Method',
                                                         lv_legal_ER_name,
                                                         ld_end_date),
                                                                  'DAILY_WAGE');
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
            g_ptu_calc_method := 'DAILY_WAGE';
     END;

     hr_utility.trace('g_ptu_calc_method: '||g_ptu_calc_method);

     OPEN  c_get_ytd_aaid(gd_start_date,
                          gd_end_date,
                          ln_person_id);
     FETCH c_get_ytd_aaid INTO ln_ytd_asg_act_id;
     CLOSE c_get_ytd_aaid;

     hr_utility.trace('YTD AA ID: ' || ln_ytd_asg_act_id );

     ln_step := 1;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

      /*bug 8437173 area 5*/
      FOR cntr_gre IN
          pay_mx_yrend_arch.g_gre_tab.first()..pay_mx_yrend_arch.g_gre_tab.last()
      LOOP
          pay_balance_pkg.set_context('TAX_UNIT_ID', pay_mx_yrend_arch.g_gre_tab(cntr_gre));

          ln_factor_B := ln_factor_B + NVL(pay_balance_pkg.get_value(
                                             g_worked_days_def_bal_id,
                                             ln_ytd_asg_act_id), 0);
      END LOOP;


     IF ln_factor_B <> 0 THEN

         ln_factor_J := ROUND( ln_factor_B * g_factor_H, 2 );

         ln_step := 2;
       /*bug 8437173 area 6*/
       FOR cntr_gre IN
           pay_mx_yrend_arch.g_gre_tab.first()..pay_mx_yrend_arch.g_gre_tab.last()
       LOOP
           pay_balance_pkg.set_context('TAX_UNIT_ID',  pay_mx_yrend_arch.g_gre_tab(cntr_gre));

           ln_factor_C := ln_factor_C + NVL(pay_balance_pkg.get_value(
                                                 g_elig_comp_def_bal_id,
                                                 ln_ytd_asg_act_id), 0);
       END LOOP;

         get_capped_average_earnings(
              p_ptu_calc_method  =>g_ptu_calc_method,
              p_days_in_year     =>gd_end_date - gd_start_date,
              p_business_group_id=>ln_business_group_id,
              p_legal_employer_id=>gn_legal_employer_id,
              p_factor_B         =>ln_factor_B,
              p_factor_C         =>ln_factor_C,
              p_factor_D         =>g_factor_D,
              p_factor_D_used    =>ln_factor_D,
              p_factor_E         =>ln_factor_E);

         ln_factor_K := ROUND( ln_factor_E * g_factor_I, 2);

     ELSE
         ln_factor_J := 0;
         ln_factor_K := 0;
     END IF;

     IF (ln_factor_J + ln_factor_K) <> 0 THEN

         ln_isr_subject := pay_mx_tax_functions.get_partial_subj_earnings(
                       P_CTX_EFFECTIVE_DATE       => p_effective_date,
                       P_CTX_ASSIGNMENT_ACTION_ID => p_archive_action_id,
                       P_CTX_BUSINESS_GROUP_ID    => ln_business_group_id,
                       P_CTX_JURISDICTION_CODE    => 'XXX',
                       P_CTX_ELEMENT_TYPE_ID      => g_PTU_ele_type_id,
                       P_TAX_TYPE                 => 'ISR',
                       P_EARNINGS_AMT             => ln_factor_J + ln_factor_K,
                       P_YTD_EARNINGS_AMT         => ln_factor_J + ln_factor_K,
                       P_PTD_EARNINGS_AMT         => ln_factor_J + ln_factor_K,
                       P_GROSS_EARNINGS           => -999,
                       P_YTD_GROSS_EARNINGS       => -999,
                       P_DAILY_SALARY             => ln_factor_E, -- Ignored
                       P_CLASSIFICATION_NAME      => 'Profit Sharing');

         ln_isr_exempt := ln_factor_J + ln_factor_K - ln_isr_subject;


         OPEN  c_get_lkup_meaning;
         FETCH c_get_lkup_meaning INTO lv_lkup_meaning;
         CLOSE c_get_lkup_meaning;

         ln_step := 3;
         pay_batch_element_entry_api.create_batch_line (
                p_session_date          => p_effective_date,
                p_batch_id              => g_batch_id,
                p_assignment_id         => ln_assignment_id,
                p_assignment_number     => lv_assignment_number,
    --          p_batch_sequence        => p_batch_sequence,
                p_effective_date        => p_effective_date,
    --          p_element_name          => p_element_name,
                p_element_type_id       => g_PTU_ele_type_id,
                p_value_1               => ln_factor_J + ln_factor_K,
                p_value_2               => NULL,
                p_value_3               => lv_lkup_meaning,
                p_value_4               => lv_lkup_meaning,
                p_value_5               => g_factor_A,
                p_value_6               => ln_factor_B,
                p_value_7               => ln_factor_C,
                p_value_8               => g_factor_D,
                p_value_9               => ln_factor_E,
                p_value_10              => g_factor_F,
                p_value_11              => g_factor_G,
                p_value_12              => ln_factor_J,
                p_value_13              => ln_factor_K,
                p_value_14              => ln_isr_subject,
                p_value_15              => ln_isr_exempt,
                p_batch_line_id         => ln_batch_line_id,
                p_object_version_number => ln_ovn);

     END IF;

     hr_utility.trace('Leaving ' || gv_package || lv_procedure_name);

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

  /************************************************************
   Name      : deinit_code
   Purpose   : This procedure deletes the temporary records
               created in PAY_ACTION_INFORMATION for the Profit
               Sharing process in Mexico.
   Arguments : p_payroll_action_id            IN NUMBER
   Notes     :
  ************************************************************/
  PROCEDURE deinit_code(p_payroll_action_id  IN NUMBER)
  IS
  --
    lv_procedure_name   VARCHAR2(100);
    lv_error_message    VARCHAR2(200);
    ln_step             NUMBER;

  BEGIN
     lv_procedure_name  := '.deinit_code';
     hr_utility.trace('Entering ' || gv_package || lv_procedure_name);

     ln_step := 1;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     DELETE
       FROM pay_action_information
      WHERE action_information_category = 'MX PROFIT SHARING FACTORS'
        AND action_context_id           = p_payroll_action_id
        AND action_context_type         = 'PA';

     hr_utility.trace('Leaving ' || gv_package || lv_procedure_name);

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

  END deinit_code;

BEGIN
    --hr_utility.trace_on (NULL, 'MX_IDC');
    gv_package := 'pay_mx_PTU_calc';
END pay_mx_PTU_calc;

/
