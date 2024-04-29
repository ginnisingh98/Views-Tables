--------------------------------------------------------
--  DDL for Package Body PQP_PENSION_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PENSION_FUNCTIONS" AS
/* $Header: pqppenff.pkb 120.8.12010000.3 2008/10/14 12:55:19 rsahai ship $ */

      g_ptp_formula_exists  BOOLEAN := TRUE;
      g_ptp_formula_cached  BOOLEAN := FALSE;
      g_ptp_formula_id      ff_formulas_f.formula_id%TYPE;
      g_ptp_formula_name    ff_formulas_f.formula_name%TYPE;

-- =============================================================================
-- Cursor to get the defined balance id for a given balance and dimension
-- =============================================================================
CURSOR csr_defined_bal (c_balance_name      IN Varchar2
                       ,c_dimension_name    IN Varchar2
                       ,c_business_group_id IN Number) IS
 SELECT db.defined_balance_id
   FROM pay_balance_types pbt
       ,pay_defined_balances db
       ,pay_balance_dimensions bd
  WHERE pbt.balance_name        = c_balance_name
    AND pbt.balance_type_id     = db.balance_type_id
    AND bd.balance_dimension_id = db.balance_dimension_id
    AND bd.dimension_name       = c_dimension_name
    AND (pbt.business_group_id  = c_business_group_id OR
         pbt.legislation_code   = 'NL')
    AND (db.business_group_id   = pbt.business_group_id OR
         db.legislation_code    = 'NL');

--
-- ----------------------------------------------------------------------------
-- |---------------------< get_pension_type_details >--------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_pension_type_details
  (p_business_group_id  IN  pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned        IN  DATE
  ,p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
  ,p_pension_type_id    IN  pqp_pension_types_f.pension_type_id%TYPE
  ,p_legislation_code   IN  pqp_pension_types_f.legislation_code%TYPE
  ,p_column_name        IN  VARCHAR2
  ,p_column_value       OUT NOCOPY VARCHAR2
  ,p_error_message      OUT NOCOPY VARCHAR2
  ) RETURN NUMBER IS

 CURSOR c_pty_cur (c_business_group_id IN NUMBER
                  ,c_pension_type_id   IN NUMBER
                  ,c_date_earned       IN DATE) IS
  SELECT *
    FROM pqp_pension_types_f
   WHERE c_date_earned BETWEEN effective_start_date
                           AND effective_end_date
     AND business_group_id = c_business_group_id
     AND pension_type_id   = c_pension_type_id;

 CURSOR c_get_subcat (c_sub_cat IN VARCHAR2) IS
   SELECT meaning
     FROM fnd_lookup_values
   WHERE  lookup_type = 'PQP_PENSION_SUB_CATEGORY'
     AND  lookup_code = c_sub_cat
     AND  language = 'US';

 CURSOR  c_get_person_age IS
    SELECT to_char(per.date_of_birth,'RRRR')
    FROM   per_all_people_f per,per_all_assignments_f paa
    WHERE  per.person_id = paa.person_id
    AND    p_date_earned between paa.effective_start_date and paa.effective_end_date
    AND    p_date_earned between per.effective_start_date and per.effective_end_date
    AND    paa.assignment_id = p_assignment_id;

 CURSOR c_get_ee_age_threshold(c_pension_type_id IN NUMBER) IS
  SELECT NVL(EE_AGE_THRESHOLD,'N')
  FROM   pqp_pension_types_f
  WHERE  pension_type_id = c_pension_type_id
  AND    p_date_earned between effective_start_date and effective_end_date;

 CURSOR c_get_er_age_threshold(c_pension_type_id IN NUMBER) IS
  SELECT NVL(ER_AGE_THRESHOLD,'N')
  FROM   pqp_pension_types_f
  WHERE  pension_type_id = c_pension_type_id
  AND    p_date_earned between effective_start_date and effective_end_date;



 l_proc_name    VARCHAR2(150) := g_proc_name || 'get_pension_type_details';
 l_pension_id   pqp_pension_types_f.pension_type_id%TYPE;
 l_subcat       VARCHAR2(80);
 l_pension_rec  c_pty_cur%ROWTYPE;
 l_ee_age_threshold pqp_pension_types_f.ee_age_threshold%TYPE;
 l_person_year_of_birth   VARCHAR2(10);
 l_er_age_threshold pqp_pension_types_f.er_age_threshold%TYPE;

BEGIN

  hr_utility.set_location('Entering : '||l_proc_name, 10);

  l_pension_id := p_pension_type_id;

  --
  -- Check if the pension_type_id is already in cache
  --
  IF NOT g_pension_rec.EXISTS(l_pension_id) THEN
     hr_utility.set_location('..Pension Id :'||l_pension_id
                              ||' does not exists',15);
     g_pension_rec.DELETE;
     OPEN  c_pty_cur (c_business_group_id => p_business_group_id
                     ,c_pension_type_id   => p_pension_type_id
                     ,c_date_earned       => p_date_earned);
     FETCH c_pty_cur INTO g_pension_rec(l_pension_id);
     CLOSE c_pty_cur;

  --
  -- Check if the pension id in the PL/SQL table is valid for
  -- the passed date-earned
  --
  ELSIF NOT(p_date_earned
                  BETWEEN g_pension_rec(l_pension_id).effective_start_date
                      AND g_pension_rec(l_pension_id).effective_end_date
        AND g_pension_rec(l_pension_id).pension_type_id   = l_pension_id
        AND g_pension_rec(l_pension_id).business_group_id = p_business_group_id
             ) THEN
     hr_utility.set_location('..Pension Id :'||l_pension_id
                             ||' does exists in pl/sql table',20);
     hr_utility.set_location('..Pension Id is not valid for given date'
                             ||p_date_earned,25);
     g_pension_rec.DELETE(l_pension_id);

     OPEN  c_pty_cur (c_business_group_id => p_business_group_id
                     ,c_pension_type_id   => p_pension_type_id
                     ,c_date_earned       => p_date_earned);
     FETCH c_pty_cur
      INTO g_pension_rec(l_pension_id);
     CLOSE c_pty_cur;
  END IF;

  --
  -- Get the column value from the PL/SQL table based
  -- on the column name provided
  --
   IF   p_column_name = 'SALARY_CALCULATION_METHOD' THEN
        p_column_value
              := g_pension_rec(l_pension_id).salary_calculation_method;
   IF     p_column_value IS NULL
      AND g_pension_rec(l_pension_id).pension_category = 'S' THEN
	   p_column_value := '2';
   END IF;

  ELSIF p_column_name = 'THRESHOLD_CONVERSION_RULE' THEN
        p_column_value
        := g_pension_rec(l_pension_id).threshold_conversion_rule;
  ELSIF p_column_name = 'CONTRIBUTION_CONVERSION_RULE' THEN
        p_column_value
        := g_pension_rec(l_pension_id).contribution_conversion_rule;
  ELSIF p_column_name = 'ER_ANNUAL_LIMIT' THEN
        p_column_value
        := NVL(fnd_number.number_to_canonical(g_pension_rec(l_pension_id).er_annual_limit),trim(to_char(0,'9')));
  ELSIF p_column_name = 'EE_ANNUAL_LIMIT' THEN
        p_column_value
        := NVL(fnd_number.number_to_canonical(g_pension_rec(l_pension_id).ee_annual_limit),trim(to_char(0,'9')));
  ELSIF p_column_name = 'MINIMUM_AGE' THEN
        p_column_value
        := NVL(to_char(g_pension_rec(l_pension_id).minimum_age),trim(to_char(0,'9')));
  ELSIF p_column_name = 'MAXIMUM_AGE' THEN
        p_column_value
        := NVL(to_char(g_pension_rec(l_pension_id).maximum_age),trim(to_char(999,'999')));
  ELSIF p_column_name = 'EE_ANNUAL_CONTRIBUTION' THEN
        p_column_value
        := NVL(fnd_number.number_to_canonical(g_pension_rec(l_pension_id).ee_annual_contribution)
              ,trim(to_char(0,'9')));
  ELSIF p_column_name = 'ER_ANNUAL_CONTRIBUTION' THEN
        p_column_value
        := NVL(fnd_number.number_to_canonical(g_pension_rec(l_pension_id).er_annual_contribution)
              ,trim(to_char(0,'9')));
  ELSIF p_column_name = 'EE_CONTRIBUTION_PERCENT' THEN
        p_column_value
        := NVL(fnd_number.number_to_canonical(g_pension_rec(l_pension_id).ee_contribution_percent)
              ,trim(to_char(0,'9')));
  ELSIF p_column_name = 'ER_CONTRIBUTION_PERCENT' THEN
        p_column_value
        := NVL(fnd_number.number_to_canonical(g_pension_rec(l_pension_id).er_contribution_percent)
              ,trim(to_char(0,'9')));
  ELSIF p_column_name = 'EE_ANNUAL_SALARY_THRESHOLD' THEN

        OPEN  c_get_ee_age_threshold(g_pension_rec(l_pension_id).pension_type_id);
        FETCH c_get_ee_age_threshold into l_ee_age_threshold;
          IF (c_get_ee_age_threshold%FOUND
              and l_ee_age_threshold = 'Y'
              ) THEN

              hr_utility.set_location(' l_ee_age_threshold is '||l_ee_age_threshold,30);

              OPEN  c_get_person_age;
              FETCH c_get_person_age into l_person_year_of_birth;
                 IF (c_get_person_age%FOUND and l_person_year_of_birth IS NOT NULL) THEN

                     hr_utility.set_location(' l_person_year_of_birth is '||l_person_year_of_birth,35);

                    OPEN c_get_subcat(NVL(g_pension_rec(l_pension_id).pension_sub_category,trim(to_char(0,'9'))));
                    FETCH c_get_subcat INTO l_subcat;
                    CLOSE c_get_subcat;

                    hr_utility.set_location(' l_subcat is '||l_subcat,40);

                    IF l_subcat IS NOT NULL THEN

                         BEGIN
                         p_column_value :=
                         hruserdt.get_table_value
                         (
                          p_bus_group_id    => p_business_group_id
                         ,p_table_name      => 'PQP_NL_ABP_EE_ANNUAL_SALARY_THRESHOLD'
                         ,p_col_name        => l_subcat
                         ,p_row_value       => l_person_year_of_birth
                         ,p_effective_date  => p_date_earned
                         );

                         p_column_value := NVL(p_column_value,trim(to_char(0,'9')));

                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                          hr_utility.set_location('NO_DATA_FOUND for UDT : ', 90);

                          p_column_value := trim(to_char(0,'9'));

                          p_error_message := 'Pension Type '
                             || g_pension_rec(l_pension_id).pension_type_name
                             ||' has age dependent thresholds. '
                             ||' Please verify that this data exists'
                             ||' in the UDT.';

                          RETURN 3;

                          WHEN OTHERS THEN

                             IF (SQLCODE = -1422) THEN
                                hr_utility.set_location('MORE THAN ONE ROW FETCHED for UDT :', 90);
                                p_column_value := trim(to_char(0,'9'));
                                p_error_message := 'The table PQP_NL_ABP_EE_ANNUAL_SALARY_THRESHOLD has '
                                ||'overlapping rows for the age of the employee.';

                            END IF;
                            RETURN 3;

                        END;

                        hr_utility.set_location(' p_column_value is '||p_column_value,40);

                    END IF;-- subcat check

                 END IF;--c_get_person_age%FOUND
                 CLOSE c_get_person_age;
            ELSE
                 p_column_value
                 := NVL(fnd_number.number_to_canonical(g_pension_rec(l_pension_id).ee_annual_salary_threshold)
                        ,trim(to_char(0,'9')));


           END IF; -- c_get_ee_age_threshold%FOUND

        CLOSE c_get_ee_age_threshold;

        hr_utility.set_location(' p_error_message is '||p_error_message,45);

  ELSIF p_column_name = 'ER_ANNUAL_SALARY_THRESHOLD' THEN
--        p_column_value
--        := NVL(fnd_number.number_to_canonical(g_pension_rec(l_pension_id).er_annual_salary_threshold)
--              ,trim(to_char(0,'9')));


        OPEN  c_get_er_age_threshold(g_pension_rec(l_pension_id).pension_type_id);
        FETCH c_get_er_age_threshold into l_er_age_threshold;
          IF (c_get_er_age_threshold%FOUND
              and l_er_age_threshold = 'Y'
              ) THEN

              hr_utility.set_location(' l_er_age_threshold is '||l_er_age_threshold,30);

              OPEN  c_get_person_age;
              FETCH c_get_person_age into l_person_year_of_birth;
                 IF (c_get_person_age%FOUND and l_person_year_of_birth IS NOT NULL) THEN

                     hr_utility.set_location(' l_person_year_of_birth is '||l_person_year_of_birth,35);

                    OPEN c_get_subcat(NVL(g_pension_rec(l_pension_id).pension_sub_category,trim(to_char(0,'9'))));
                    FETCH c_get_subcat INTO l_subcat;
                    CLOSE c_get_subcat;

                    hr_utility.set_location(' l_subcat is '||l_subcat,40);

                    IF l_subcat IS NOT NULL THEN

                         BEGIN
                         p_column_value :=
                         hruserdt.get_table_value
                         (
                          p_bus_group_id    => p_business_group_id
                         ,p_table_name      => 'PQP_NL_ABP_ER_ANNUAL_SALARY_THRESHOLD'
                         ,p_col_name        => l_subcat
                         ,p_row_value       => l_person_year_of_birth
                         ,p_effective_date  => p_date_earned
                         );

                        p_column_value := NVL(p_column_value,trim(to_char(0,'9')));

                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                          hr_utility.set_location('NO_DATA_FOUND for UDT : ', 90);

                          p_column_value := trim(to_char(0,'9'));

--                          fnd_message.set_name('PQP','PQP_230129_PEN_AGE_ANN_SAL_THR');
--                          fnd_message.set_token('PT Name',g_pension_rec(l_pension_id).pension_type_name);
--                          p_error_message := fnd_message.get();

                            p_error_message := 'Pension Type: '
                             || g_pension_rec(l_pension_id).pension_type_name
                             ||' has age dependent thresholds. '
                             ||' Please verify that this data exists '
                             ||' in the UDT.';


                          RETURN 3;

                          WHEN OTHERS THEN

                             IF (SQLCODE = -1422) THEN
                                hr_utility.set_location('MORE THAN ONE ROW FETCHED for UDT :', 90);
                                p_column_value := trim(to_char(0,'9'));
                                p_error_message := 'The table PQP_NL_ABP_ER_ANNUAL_SALARY_THRESHOLD has '
                                ||'overlapping rows for the age of the employee.';

                            END IF;
                            RETURN 3;

                        END;

                        hr_utility.set_location(' p_column_value is '||p_column_value,40);

                    END IF;-- subcat check

                 END IF;--c_get_person_age%FOUND
                 CLOSE c_get_person_age;
            ELSE
                 p_column_value
                 := NVL(fnd_number.number_to_canonical(g_pension_rec(l_pension_id).er_annual_salary_threshold)
                        ,trim(to_char(0,'9')));


           END IF; -- c_get_er_age_threshold%FOUND

        CLOSE c_get_er_age_threshold;

        hr_utility.set_location(' p_error_message is '||p_error_message,45);

  ELSIF p_column_name = 'ANNUAL_PREMIUM_AMOUNT' THEN
        p_column_value
        := NVL(fnd_number.number_to_canonical(g_pension_rec(l_pension_id).annual_premium_amount)
              ,trim(to_char(0,'9')));
  ELSIF p_column_name = 'SPECIAL_PENSION_TYPE_CODE' THEN
        p_column_value
        := NVL(g_pension_rec(l_pension_id).special_pension_type_code
              ,trim(to_char(0,'9')));
  ELSIF p_column_name = 'PENSION_SUB_CATEGORY' THEN
        p_column_value
        := NVL(g_pension_rec(l_pension_id).pension_sub_category,trim(to_char(0,'9')));
  ELSIF p_column_name = 'PENSION_SUB_CAT_MEANING' THEN
        OPEN c_get_subcat(NVL(g_pension_rec(l_pension_id).pension_sub_category,trim(to_char(0,'9'))));
        FETCH c_get_subcat INTO l_subcat;
        IF c_get_subcat%FOUND THEN
           CLOSE c_get_subcat;
           p_column_value := l_subcat;
        ELSE
           CLOSE c_get_subcat;
           p_column_value := trim(to_char(0,'9'));
        END IF;
  ELSIF p_column_name = 'PENSION_BASIS_CALC_MTHD' THEN
        p_column_value
        := NVL(g_pension_rec(l_pension_id).pension_basis_calc_method
              ,trim(to_char(0,'9')));
  ELSIF p_column_name = 'PENSION_SALARY_BALANCE' THEN
        p_column_value
        := NVL(to_char(g_pension_rec(l_pension_id).pension_salary_balance)
              ,trim(to_char(0,'9')));
  ELSIF p_column_name = 'RECURRING_BONUS_PERCENT' THEN
        p_column_value
        := NVL(fnd_number.number_to_canonical(g_pension_rec(l_pension_id).recurring_bonus_percent)
              ,trim(to_char(0,'9')));
  ELSIF p_column_name = 'NON_RECURRING_BONUS_PERCENT' THEN
        p_column_value
        := NVL(fnd_number.number_to_canonical(g_pension_rec(l_pension_id).non_recurring_bonus_percent)
              ,trim(to_char(0,'9')));
  ELSIF p_column_name = 'RECURRING_BONUS_BALANCE' THEN
        p_column_value
        := NVL(to_char(g_pension_rec(l_pension_id).recurring_bonus_balance)
              ,trim(to_char(0,'9')));
  ELSIF p_column_name = 'NON_RECURRING_BONUS_BALANCE' THEN
        p_column_value
        := NVL(to_char(g_pension_rec(l_pension_id).non_recurring_bonus_balance)
              ,trim(to_char(0,'9')));
  ELSIF p_column_name = 'PREV_YR_BONUS_INCLUDE' THEN
        p_column_value
        := NVL(g_pension_rec(l_pension_id).previous_year_bonus_included
              ,trim(to_char(0,'9')));
  ELSIF p_column_name = 'RECURRING_BONUS_PERIOD' THEN
        p_column_value
        := NVL(g_pension_rec(l_pension_id).recurring_bonus_period,trim(to_char(0,'9')));
  ELSIF p_column_name = 'NON_RECURRING_BONUS_PERIOD' THEN
        p_column_value
        := NVL(g_pension_rec(l_pension_id).non_recurring_bonus_period
              ,trim(to_char(0,'9')));
  ELSE
        p_error_message := 'Error occured while fetching values for '
                         ||'Pension Type : '||g_pension_rec(l_pension_id).pension_type_name
                         ||' Column : '||p_column_name||' is invalid.';
        RETURN 1;
  END IF;

  hr_utility.set_location('..Column Name  :'||p_column_name , 30);
  hr_utility.set_location('..Column Value :'||p_column_value, 35);
  hr_utility.set_location('..p_error_message :'||p_error_message, 40);
  hr_utility.set_location('Leaving : '||l_proc_name, 80);

  RETURN 0;

 EXCEPTION
    WHEN OTHERS THEN
  hr_utility.set_location('Error when others : '||l_proc_name, 90);
  hr_utility.set_location('Leaving : '||l_proc_name, 95);
  p_error_message := 'Error occured while fetching values for Pension Type';
  RETURN 1;

END get_pension_type_details;

-- ----------------------------------------------------------------------------
-- |-------------------------< prorate_amount >-------------------------------|
-- ----------------------------------------------------------------------------
--
function prorate_amount
  (p_business_group_id      in     pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned            in     date
  ,p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_amount                 in     number
  ,p_payroll_period         in     varchar2
  ,p_work_pattern           in     varchar2
  ,p_conversion_rule        in     varchar2
  ,p_prorated_amount        out nocopy number
  ,p_error_message          out nocopy varchar2
  ,p_payroll_period_prorate in varchar2
  ,p_override_pension_days  in number default -9999
  ) return NUMBER IS

-- In the first phase of Dutch pensions , only average working days
-- calculation will be supported. Once Actual working days ( equal to
-- SI days ) is enabled, the same function will be called here .

CURSOR c_get_global ( c_global_name IN VARCHAR2
                     ,c_effective_date IN DATE ) IS
SELECT fnd_number.canonical_to_number(global_value)
  FROM ff_globals_f
 WHERE global_name = c_global_name
   AND trunc(c_effective_date) BETWEEN effective_start_date AND effective_end_date
   AND legislation_code = 'NL';

CURSOR c_get_work_pattern(c_assignment_id
       IN  per_all_assignments_f.assignment_id%TYPE,
       c_effective_date IN DATE) IS
  SELECT work_pattern
  FROM   pqp_assignment_attributes_f
  WHERE  assignment_id = c_assignment_id
  AND trunc(c_effective_date) BETWEEN effective_start_date AND effective_end_date;

CURSOR c_get_start_end_date(c_assignment_id in NUMBER,
                            c_effective_date IN DATE
                            ) IS
SELECT ptp.start_date,ptp.end_date
FROM   per_all_assignments_f pasf,per_time_periods ptp
WHERE  pasf.payroll_id = ptp.payroll_id
AND    pasf.assignment_id = c_assignment_id
AND    trunc(c_effective_date)  BETWEEN ptp.start_date AND ptp.end_date;

--bug 3115132
CURSOR c_get_assign_start_date(c_assign_id in NUMBER,
                               c_period_start_dt IN DATE,
                               c_period_end_dt IN DATE
                               ) IS
SELECT min(asg.effective_start_date) , max(asg.effective_end_date)
FROM   per_assignments_f asg,per_assignment_status_types past
WHERE  asg.assignment_status_type_id = past.assignment_status_type_id
AND    past.per_system_status = 'ACTIVE_ASSIGN'
AND    asg.effective_start_date <= c_period_end_dt
AND    nvl(asg.effective_end_date, c_period_end_dt) >= c_period_start_dt
AND    asg.assignment_id = c_assign_id;

CURSOR c_get_asg_end_date(c_assign_id in NUMBER,
                          c_period_start_dt IN DATE
                          ) IS
SELECT
decode(asg.EFFECTIVE_END_DATE,to_date('31-12-4712','dd-mm-yyyy'),null,asg.EFFECTIVE_END_DATE)
FROM   per_assignments_f asg,per_assignment_status_types past
WHERE  asg.assignment_status_type_id = past.assignment_status_type_id
AND    past.per_system_status = 'ACTIVE_ASSIGN'
AND    trunc(c_period_start_dt) = asg.effective_start_date
AND    asg.assignment_id = c_assign_id;


CURSOR c_term_date_decode(c_term_date IN DATE) IS
SELECT decode(c_term_date,to_date('31-12-4712','dd-mm-yyyy'),null,c_term_date)
FROM DUAL;


CURSOR
c_no_of_days(c_end_date IN DATE, c_start_date IN DATE)
IS
SELECT (c_end_date - c_start_date + 1)
FROM   DUAL;

CURSOR
c_get_average_days_per_month(c_assignment_id IN NUMBER,
                             c_effective_date IN DATE
                             ) IS
SELECT hoi.org_information5
FROM  per_all_assignments_f paa,hr_organization_information hoi
WHERE paa.organization_id = hoi.organization_id
AND   hoi.org_information_context='NL_ORG_INFORMATION'
AND paa.assignment_id = c_assignment_id
AND trunc(c_effective_date) between effective_start_date and effective_end_date;

CURSOR
c_get_max_si_values(c_assignment_id IN NUMBER,c_effective_date IN DATE) IS
SELECT SEGMENT26,segment27
FROM   hr_soft_coding_keyflex hr_keyflex,per_assignments_f  ASSIGN
WHERE  ASSIGN.assignment_id                   =  c_assignment_id
AND    hr_keyflex.soft_coding_keyflex_id      = ASSIGN.soft_coding_keyflex_id
AND    hr_keyflex.enabled_flag                = 'Y'
AND    trunc(c_effective_date) BETWEEN ASSIGN.effective_start_date AND ASSIGN.effective_end_date;

CURSOR
c_get_avg_si_assignment(c_assignment_id IN NUMBER) IS
SELECT aei_information1,aei_information2
FROM  per_assignment_extra_info
WHERE information_type= 'NL_PAI'
AND  assignment_id = c_assignment_id;

Cursor c_get_periods_per_yr(c_period_type in VARCHAR2) IS
   Select number_per_fiscal_year
   from per_time_period_types
   where period_type = c_period_type;


l_average_days_divisor      NUMBER;
l_average_days_multiplier   NUMBER;
l_prorated_amount           NUMBER;
l_avg_days_in_year          NUMBER;
l_ret_val                   NUMBER;
l_payroll_period            per_time_periods.period_name%TYPE;
l_work_pattern              VARCHAR2(200);
l_pay_start_dt              DATE;
l_pay_end_dt                DATE;
l_term_date                 DATE;
l_average_si_days           NUMBER;
l_payroll_days               NUMBER; -- average days in a payroll run.
l_ass_start_dt              DATE;
l_si_factor                 NUMBER;
l_non_si_days               NUMBER;
l_average_ws_si_days        NUMBER;
l_working_work_pattern_days NUMBER;
l_total_days                NUMBER;  -- total days in a payroll run.
l_actual_work_days          NUMBER := -99;
l_total_work_pattern_days   NUMBER;
l_days                      NUMBER;
l_average_period_days       NUMBER;
l_debug                     BOOLEAN;
l_real_si_days              NUMBER;
l_max_si_days               NUMBER;
l_error_code                VARCHAR2(100);
l_error_message             VARCHAR2(500);
l_max_si_method             VARCHAR2(100);
l_overridden_realsi_assignment   NUMBER;
l_overridden_realsi_element   NUMBER;
bFlagAvgDays                  boolean;
l_override_method            VARCHAR2(100);
l_overridden_avgsi_assignment VARCHAR2(100);
l_pay_prorate_period          VARCHAR2(100);
l_pay_period                  VARCHAR2(100);
l_tmp_ret_val                 NUMBER := 0;
l_next_term_date              DATE;
l_periods_per_yr        NUMBER := 1;
l_prorate_periods_per_yr  NUMBER := 1;

BEGIN

OPEN c_get_global ('NL_SI_AVERAGE_DAYS_YEARLY'
                        ,p_date_earned);
 FETCH c_get_global INTO l_avg_days_in_year;

CLOSE c_get_global;

IF p_payroll_period = 'NOT ENTERED' THEN
   l_payroll_period := p_payroll_period_prorate;
ELSE
   l_payroll_period := p_payroll_period;
END IF;

   l_debug := hr_utility.debug_enabled;


IF l_debug THEN
   pqp_utilities.debug(' p_business_group_id     is ' || p_business_group_id     );
   pqp_utilities.debug(' p_date_earned           is ' || p_date_earned           );
   pqp_utilities.debug(' p_assignment_id         is ' || p_assignment_id         );
   pqp_utilities.debug(' p_amount                is ' || p_amount                );
   pqp_utilities.debug(' p_payroll_period        is ' || p_payroll_period        );
   pqp_utilities.debug(' l_payroll_period        is ' || l_payroll_period        );
   pqp_utilities.debug(' p_work_pattern          is ' || p_work_pattern          );
   pqp_utilities.debug(' p_conversion_rule       is ' || p_conversion_rule       );
   pqp_utilities.debug(' p_prorated_amount       is ' || p_prorated_amount       );
   pqp_utilities.debug(' p_error_message         is ' || p_error_message         );
   pqp_utilities.debug(' p_payroll_period_prorate is ' || p_payroll_period_prorate);
END IF;




   IF ( l_payroll_period LIKE '%Calendar Month'
      OR l_payroll_period = 'CM') THEN

	 OPEN c_get_global ('NL_SI_AVERAGE_DAYS_MONTHLY'
                        ,p_date_earned);

	 FETCH c_get_global INTO l_average_days_divisor;

	 CLOSE c_get_global;

         OPEN c_get_periods_per_yr('Calendar Month');

         FETCH c_get_periods_per_yr INTO l_periods_per_yr;

         CLOSE c_get_periods_per_yr;

	 l_ret_val := 0;

   ELSIF (l_payroll_period LIKE '%Lunar Month'
      OR l_payroll_period = 'LM') THEN

	  OPEN c_get_global ('NL_SI_AVERAGE_DAYS_4WEEKLY'
                        ,p_date_earned);

	  FETCH c_get_global INTO l_average_days_divisor;

	  CLOSE c_get_global;

          OPEN c_get_periods_per_yr('Lunar Month');

          FETCH c_get_periods_per_yr INTO l_periods_per_yr;

          CLOSE c_get_periods_per_yr;

	  l_ret_val := 0;

   ELSIF (l_payroll_period LIKE '%Quarter'
      OR l_payroll_period = 'Q') THEN

	  OPEN c_get_global ('NL_SI_AVERAGE_DAYS_QUARTERLY'
                        ,p_date_earned);

	  FETCH c_get_global INTO l_average_days_divisor;

	  CLOSE c_get_global;

          OPEN c_get_periods_per_yr('Quarter');

          FETCH c_get_periods_per_yr INTO l_periods_per_yr;

          CLOSE c_get_periods_per_yr;

	  l_ret_val := 0;

   ELSIF ( l_payroll_period LIKE '%Week'
      OR  l_payroll_period = 'W') THEN

	   OPEN c_get_global ('NL_SI_AVERAGE_DAYS_WEEKLY'
                        ,p_date_earned);

	   FETCH c_get_global INTO l_average_days_divisor;

	   CLOSE c_get_global;

           OPEN c_get_periods_per_yr('Week');

           FETCH c_get_periods_per_yr INTO l_periods_per_yr;

           CLOSE c_get_periods_per_yr;

	   l_ret_val := 0;

   ELSIF ( l_payroll_period LIKE '%Year'
      OR  l_payroll_period = 'Y') THEN

	   l_average_days_divisor := l_avg_days_in_year;

           OPEN c_get_periods_per_yr('Year');

           FETCH c_get_periods_per_yr INTO l_periods_per_yr;

           CLOSE c_get_periods_per_yr;

	   l_ret_val := 0;

   ELSE
	   l_ret_val := 1;
	   p_error_message := 'Error : Invalid value for Payroll Period';

   END IF;

   IF l_ret_val = 0 THEN
           IF (p_payroll_period_prorate LIKE '%Calendar Month'
              OR p_payroll_period_prorate = 'CM') THEN

                 OPEN c_get_global ('NL_SI_AVERAGE_DAYS_MONTHLY'
                        ,p_date_earned);

                 FETCH c_get_global INTO l_average_days_multiplier;

                 CLOSE c_get_global;

                 OPEN c_get_periods_per_yr('Calendar Month');

                 FETCH c_get_periods_per_yr INTO l_prorate_periods_per_yr;

                 CLOSE c_get_periods_per_yr;

                 l_ret_val := 0;

           ELSIF (p_payroll_period_prorate LIKE '%Lunar Month'
                 OR p_payroll_period_prorate = 'LM') THEN

                 OPEN c_get_global ('NL_SI_AVERAGE_DAYS_4WEEKLY'
                        ,p_date_earned);

                 FETCH c_get_global INTO l_average_days_multiplier;

                 CLOSE c_get_global;

                 OPEN c_get_periods_per_yr('Lunar Month');

                 FETCH c_get_periods_per_yr INTO l_prorate_periods_per_yr;

                 CLOSE c_get_periods_per_yr;

                 l_ret_val := 0;

           ELSIF (p_payroll_period_prorate LIKE '%Quarter'
                 OR p_payroll_period_prorate = 'Q') THEN

                 OPEN c_get_global ('NL_SI_AVERAGE_DAYS_QUARTERLY'
                        ,p_date_earned);

                 FETCH c_get_global INTO l_average_days_multiplier;

                 CLOSE c_get_global;

                 OPEN c_get_periods_per_yr('Quarter');

                 FETCH c_get_periods_per_yr INTO l_prorate_periods_per_yr;

                 CLOSE c_get_periods_per_yr;

                 l_ret_val := 0;

           ELSIF ( p_payroll_period_prorate LIKE '%Week'
                 OR  p_payroll_period_prorate = 'W') THEN

                 OPEN c_get_global ('NL_SI_AVERAGE_DAYS_WEEKLY'
                        ,p_date_earned);

                 FETCH c_get_global INTO l_average_days_multiplier;

                 CLOSE c_get_global;

                 OPEN c_get_periods_per_yr('Week');

                 FETCH c_get_periods_per_yr INTO l_prorate_periods_per_yr;

                 CLOSE c_get_periods_per_yr;

                 l_ret_val := 0;

           ELSIF ( p_payroll_period_prorate LIKE '%Year'
                 OR  p_payroll_period_prorate = 'Y') THEN

                 l_average_days_multiplier := l_avg_days_in_year;

                 OPEN c_get_periods_per_yr('Year');

                 FETCH c_get_periods_per_yr INTO l_prorate_periods_per_yr;

                 CLOSE c_get_periods_per_yr;

                 l_ret_val := 0;

           ELSE
                 l_ret_val := 1;
                 p_error_message := 'Error : Invalid value for Payroll Period Prorate';

           END IF;
    END IF;

   --check if the pension days values have been overriden at element entry level
   IF (p_override_pension_days <> -9999) THEN

       --real si days value should be a whole number
       IF p_conversion_rule = '2' THEN
          l_average_days_multiplier := ROUND(p_override_pension_days,0);

          IF (l_average_days_multiplier <> p_override_pension_days) THEN
             l_tmp_ret_val := 1;
          END IF;

       ELSIF p_conversion_rule <> '3' THEN
          l_average_days_multiplier := p_override_pension_days;
       ELSE
          l_average_days_multiplier  :=   l_periods_per_yr;
          l_average_days_divisor     :=   l_prorate_periods_per_yr;
       END IF;

   ELSE

    IF (l_payroll_period LIKE '%Calendar Month') THEN
       l_pay_period := 'CM' ;

    ELSIF (l_payroll_period LIKE '%Lunar Month') THEN
       l_pay_period := 'LM';

    ELSIF (l_payroll_period LIKE '%Quarter') THEN
       l_pay_period := 'Q';

    ELSIF (l_payroll_period LIKE '%Week') THEN
       l_pay_period := 'W';

    ELSIF (l_payroll_period LIKE '%Year') THEN
       l_pay_period := 'Y';

    ELSE
       l_pay_period := l_payroll_period;

    END IF;


    IF (p_payroll_period_prorate LIKE '%Calendar Month') THEN
       l_pay_prorate_period := 'CM';

    ELSIF (p_payroll_period_prorate LIKE '%Lunar Month') THEN
       l_pay_prorate_period := 'LM';

    ELSIF (p_payroll_period_prorate LIKE '%Quarter') THEN
       l_pay_prorate_period := 'Q';

    ELSIF (p_payroll_period_prorate LIKE '%Week') THEN
       l_pay_prorate_period := 'W';

    ELSIF (p_payroll_period_prorate LIKE '%Year') THEN
       l_pay_prorate_period := 'Y';

    ELSE
       l_pay_prorate_period := p_payroll_period_prorate;

    END IF;

    IF l_debug THEN
      pqp_utilities.debug(' l_pay_prorate_period '|| l_pay_prorate_period, 4);
      pqp_utilities.debug(' l_pay_period ' || l_pay_period, 5);
      pqp_utilities.debug(' l_ret_val ' || l_ret_val, 5);
    END IF;

    -- IF the pay period is not the same as the proration period
    -- then no calculation to be done.
--    IF ( l_pay_period <> l_pay_prorate_period) THEN


        -- get payroll start date and payroll end date.
        OPEN c_get_start_end_date(p_assignment_id,p_date_earned);
        FETCH c_get_start_end_date into l_pay_start_dt,l_pay_end_dt;
              IF (c_get_start_end_date%FOUND
                 AND l_pay_start_dt IS NOT NULL
                 AND l_pay_end_dt IS NOT NULL)THEN
                 CLOSE c_get_start_end_date;

                   IF l_debug THEN
                      pqp_utilities.debug(' l_pay_start_dt is '|| l_pay_start_dt , 60);
                      pqp_utilities.debug(' l_pay_end_dt is '|| l_pay_end_dt , 70);
                   END IF;
               END IF;
          -- bug 3122357
          -- get average days in the payroll
          OPEN c_no_of_days(l_pay_end_dt,l_pay_start_dt);
          FETCH c_no_of_days into l_days;
                IF (c_no_of_days%FOUND
                    AND l_days IS NOT NULL)THEN
                   CLOSE c_no_of_days;
                   l_payroll_days := l_days;
                ELSE
                    CLOSE c_no_of_days;
                END IF;

           IF l_debug THEN
              pqp_utilities.debug(' l_payroll_days is '|| l_payroll_days , 80);
           END IF;

     -- 0 corresponds to Average working days
     IF p_conversion_rule = '0' THEN

       IF (l_ret_val = 0) THEN

          -- check IF the assignment has started in this payroll period.
          OPEN c_get_assign_start_date(p_assignment_id,l_pay_start_dt,l_pay_end_dt);
          FETCH c_get_assign_start_date into l_ass_start_dt,l_term_date;
            IF (c_get_assign_start_date%FOUND
                AND l_ass_start_dt IS NOT NULL)THEN
               CLOSE c_get_assign_start_date;
               IF l_debug THEN
                  pqp_utilities.debug(' l_ass_start_dt is '|| l_ass_start_dt , 91);
                  pqp_utilities.debug(' l_term_date is '|| l_term_date , 91);
               END IF;
            ELSE
               CLOSE c_get_assign_start_date;
               p_prorated_amount := 0;
               RETURN 0;
               --p_error_message := 'Error: Unable to find the assignment start date for the person ';
            END IF; -- assignment start date found

            OPEN c_term_date_decode(l_term_date);
            FETCH c_term_date_decode into l_term_date;
            CLOSE c_term_date_decode;



           IF (l_term_date IS NOT NULL) THEN
               --        check if there is a date tracked row with active assignment from the start of the
               --        next pay run.

              OPEN c_get_asg_end_date(p_assignment_id,l_term_date+1);
              FETCH c_get_asg_end_date into l_next_term_date;
                IF (c_get_asg_end_date%FOUND)THEN
                   CLOSE c_get_asg_end_date;
                   l_term_date := l_next_term_date;
                   IF l_debug THEN
                      pqp_utilities.debug(' l_next_term_date is '|| l_next_term_date , 92);
                   END IF;
                ELSE
                   CLOSE c_get_asg_end_date;
                END IF; -- assignment end date found
           END IF;-- term date is not null

            IF l_debug THEN
               pqp_utilities.debug(' l_term_date is '|| l_term_date , 91);
            END IF;

/*         -- get termination date
           OPEN c_get_ass_term_date(p_assignment_id,l_pay_start_dt,l_pay_end_dt);
           FETCH c_get_ass_term_date into l_term_date;
               IF (c_get_ass_term_date%FOUND AND l_term_date IS NOT NULL)THEN
                  CLOSE c_get_ass_term_date;
                  IF l_debug THEN
                      pqp_utilities.debug(' l_term_date is '|| l_term_date , 101);
                   END IF;
                ELSE
                  CLOSE c_get_ass_term_date;
               END IF;-- get termination dt
*/

               IF(l_ass_start_dt is not null AND ((l_ass_start_dt > l_pay_start_dt) OR (l_ass_start_dt = l_pay_start_dt))) THEN
                   IF (l_term_date is not null AND ((l_term_date < l_pay_end_dt) OR (l_term_date = l_pay_start_dt)))THEN
                          OPEN c_no_of_days(l_term_date,l_ass_start_dt);
                          FETCH c_no_of_days into l_days;
                                IF (c_no_of_days%FOUND AND l_days IS NOT NULL)THEN
                                   CLOSE c_no_of_days;
                                   l_actual_work_days := l_days;
                                   pqp_utilities.debug(' l_actual_work_days  is '|| l_actual_work_days , 105);
                                 ELSE
                                   CLOSE c_no_of_days;
                                 END IF;
                   ELSE
                          OPEN c_no_of_days(l_pay_end_dt,l_ass_start_dt);
                          FETCH c_no_of_days into l_days;
                                IF (c_no_of_days%FOUND AND l_days IS NOT NULL)THEN
                                   CLOSE c_no_of_days;
                                   l_actual_work_days := l_days;
                                   pqp_utilities.debug(' l_actual_work_days  is '|| l_actual_work_days , 106);
                                   pqp_utilities.debug(' l_days  is '|| l_days , 107);
                                 ELSE
                                   CLOSE c_no_of_days;
                                END IF;
                   END IF;

                ELSE
                   IF (l_term_date is not null AND ((l_term_date < l_pay_end_dt) OR (l_term_date = l_pay_end_dt))) THEN
                             OPEN c_no_of_days(l_term_date,l_pay_start_dt);
                             FETCH c_no_of_days into l_days;
                                   IF (c_no_of_days%FOUND AND l_days IS NOT NULL)THEN
                                      CLOSE c_no_of_days;
                                      l_actual_work_days := l_days;
                                   ELSE
                                       CLOSE c_no_of_days;
                                   END IF;
                   END IF; --term date check

            END IF;-- assgn_start_dt check


              IF(l_ass_start_dt IS NOT NULL AND l_ass_start_dt > l_pay_start_dt) THEN
                 l_pay_start_dt := l_ass_start_dt;
              END IF;

              IF(l_term_date  IS NOT NULL AND l_term_date < l_pay_end_dt) THEN
                 l_pay_end_dt := l_term_date;
              END IF;

              IF l_debug THEN
                 pqp_utilities.debug(' l_average_days_divisor is '|| l_average_days_divisor , 151);
                 pqp_utilities.debug(' l_payroll_days is '|| l_payroll_days , 161);
                 pqp_utilities.debug(' l_actual_work_days is '|| l_actual_work_days , 171);
                 pqp_utilities.debug(' l_pay_start_dt is '|| l_pay_start_dt , 173);
                 pqp_utilities.debug(' l_pay_end_dt is '|| l_pay_end_dt , 176);
              END IF;

           -- assignment level overrides
          OPEN c_get_avg_si_assignment(p_assignment_id);
          FETCH c_get_avg_si_assignment into l_override_method,l_overridden_avgsi_assignment;
              IF (c_get_avg_si_assignment%FOUND
                 AND l_overridden_avgsi_assignment IS NOT NULL
                 AND l_override_method IS NOT NULL)THEN
                 CLOSE c_get_avg_si_assignment;

                 IF l_debug THEN
                    pqp_utilities.debug(' c_get_avg_si_assignment  found ', 4);
                    pqp_utilities.debug(' l_override_method ' || l_override_method, 5);
                    pqp_utilities.debug(' l_overridden_avgsi_assignment ' || l_overridden_avgsi_assignment ,6);
                 END IF;

                 IF (l_override_method = 0) THEN --'Manual Entry'
                     l_average_days_multiplier := l_overridden_avgsi_assignment;
                 ELSIF (l_override_method = 1 ) THEN --'Percentage of Average Days'
                       l_average_days_multiplier :=
                       l_average_days_multiplier * l_overridden_avgsi_assignment/100;
                       -- bug 3122357.
                       --prorate the average_si_days value for actual days worked
                       IF (l_payroll_days <> 0 and l_actual_work_days <> -99) THEN
                           l_average_days_multiplier := (l_average_days_multiplier/l_payroll_days * l_actual_work_days);
                       END IF;

                 ELSIF (l_override_method = 2 ) THEN -- 'Percentage of Maximum SI Days'

                      --bug 3115132
                      --get the method for maximum si days from social insurance tab
                      OPEN c_get_max_si_values(p_assignment_id,p_date_earned);
                      FETCH c_get_max_si_values into l_max_si_method,l_overridden_realsi_assignment;
                            IF (c_get_max_si_values%FOUND AND l_max_si_method IS NOT NULL )THEN
                                CLOSE c_get_max_si_values;

                                IF (l_max_si_method = 0 ) THEN -- 1 indicates 'Payroll Period' 0 indicates Weeks worked.
                                    --first check if a work pattern is attached to the ASG, if not
                                    -- return a warning condition and calculate the deduction amount to be 0
                                    OPEN c_get_work_pattern(p_assignment_id,p_date_earned);
                                    FETCH c_get_work_pattern INTO l_work_pattern;
                                    IF c_get_work_pattern%FOUND AND l_work_pattern IS NOT NULL THEN
                                       CLOSE c_get_work_pattern;
                                    ELSE
                                       CLOSE c_get_work_pattern;
                                       l_ret_val := 3;
                                    END IF;
                                    l_max_si_days :=
                                    pay_nl_si_pkg.Get_Max_SI_Days(p_assignment_id,l_pay_start_dt,l_pay_end_dt);
                                ELSE
                                    l_max_si_days :=
                                    pay_nl_si_pkg.Get_Week_Days(l_pay_start_dt,l_pay_end_dt);
                                END IF;
                                l_average_days_multiplier :=
                                l_max_si_days * l_overridden_avgsi_assignment/100;

                               IF l_debug THEN
                                  pqp_utilities.debug(' l_max_si_method ' || l_max_si_method, 5);
                                  pqp_utilities.debug(' l_max_si_days ' || l_max_si_days ,6);
                               END IF;
                            END IF;

                 END IF;

                 IF l_debug THEN
                    pqp_utilities.debug(' l_average_days_multiplier found '|| l_average_days_multiplier,7);
                 END IF;

              ELSIF (c_get_avg_si_assignment%FOUND
                    AND
                    (l_overridden_avgsi_assignment IS NULL AND l_override_method IS NOT NULL))
                    THEN

                    l_ret_val := 1;
                    p_error_message := 'Error : Overriding value has not been entered in Average Days Extra Information.';

              ELSIF (c_get_avg_si_assignment%FOUND
                    AND
                    (l_overridden_avgsi_assignment IS NOT NULL AND l_override_method IS NULL))
                    THEN

                    l_ret_val := 1;
                    p_error_message := 'Error : Overriding Method has not been entered in Average Days Extra Information.';
              ELSE
                  CLOSE c_get_avg_si_assignment;

                  -- bug 3122357.
                  --prorate average days to the days worked in the pay period.
                  IF (l_payroll_days <> 0 and l_actual_work_days <> -99) THEN
                     l_average_days_multiplier := (l_average_days_multiplier/l_payroll_days * l_actual_work_days);
                  END IF;

                  IF l_debug THEN
                    pqp_utilities.debug(' c_get_avg_si_assignment  not found ', 4);
                  END IF;
              END IF;-- check for override at assignment level.


      END IF;-- ret val

     ELSIF p_conversion_rule = '1' THEN

       IF (l_ret_val = 0) THEN

        -- get payroll start date and payroll end date.
        OPEN c_get_start_end_date(p_assignment_id,p_date_earned);
        FETCH c_get_start_end_date into l_pay_start_dt,l_pay_end_dt;
              IF (c_get_start_end_date%FOUND
                 AND l_pay_start_dt IS NOT NULL
                 AND l_pay_end_dt IS NOT NULL)THEN
                 CLOSE c_get_start_end_date;

                   IF l_debug THEN
                      pqp_utilities.debug(' l_pay_start_dt is '|| l_pay_start_dt , 60);
                      pqp_utilities.debug(' l_pay_end_dt is '|| l_pay_end_dt , 70);
                   END IF;


                  -- get average days in the payroll
                   OPEN c_no_of_days(l_pay_end_dt,l_pay_start_dt);
                   FETCH c_no_of_days into l_days;
                         IF (c_no_of_days%FOUND
                             AND l_days IS NOT NULL)THEN
                            CLOSE c_no_of_days;
                            l_payroll_days := l_days;
                         ELSE
                             CLOSE c_no_of_days;
                         END IF;

                    IF l_debug THEN
                       pqp_utilities.debug(' l_payroll_days is '|| l_payroll_days , 80);
                    END IF;

                -- check if the assignment has started in this payroll period.
                   OPEN c_get_assign_start_date(p_assignment_id,l_pay_start_dt,l_pay_end_dt);
                   FETCH c_get_assign_start_date into l_ass_start_dt,l_term_date;
                     IF (c_get_assign_start_date%FOUND
                         AND l_ass_start_dt IS NOT NULL)THEN
                        CLOSE c_get_assign_start_date;
                        IF l_debug THEN
                           pqp_utilities.debug(' l_ass_start_dt is '|| l_ass_start_dt , 92);
                        END IF;
                     ELSE
                        CLOSE c_get_assign_start_date;
                        p_prorated_amount := 0;
                        RETURN 0;
                        --p_error_message := 'Error: Unable to find the assignment start date for the person ';
                     END IF; -- assignment start date found

                    OPEN c_term_date_decode(l_term_date);
                    FETCH c_term_date_decode into l_term_date;
                    CLOSE c_term_date_decode;

                    IF (l_term_date IS NOT NULL) THEN
                       --        check if there is a date tracked row with active assignment from the start of the
                       --        next pay run.

                      OPEN c_get_asg_end_date(p_assignment_id,l_term_date+1);
                      FETCH c_get_asg_end_date into l_next_term_date;
                        IF (c_get_asg_end_date%FOUND)THEN
                           CLOSE c_get_asg_end_date;
                           l_term_date := l_next_term_date;
                           IF l_debug THEN
                              pqp_utilities.debug(' l_next_term_date is '|| l_next_term_date , 92);
                           END IF;
                        ELSE
                           CLOSE c_get_asg_end_date;
                        END IF; -- assignment end date found
                    END IF;-- term date is not null

                   IF l_debug THEN
                      pqp_utilities.debug(' l_term_date is '|| l_term_date , 91);
                   END IF;

/*                  -- get termination date
                    OPEN c_get_ass_term_date(p_assignment_id,l_pay_start_dt,l_pay_end_dt);
                    FETCH c_get_ass_term_date into l_term_date;
                        IF (c_get_ass_term_date%FOUND AND l_term_date IS NOT NULL)THEN
                           CLOSE c_get_ass_term_date;
                           IF l_debug THEN
                               pqp_utilities.debug(' l_term_date is '|| l_term_date , 102);
                            END IF;
                         ELSE
                           CLOSE c_get_ass_term_date;
                        END IF;-- get termination dt
*/




                    IF(l_ass_start_dt is not null AND ((l_ass_start_dt > l_pay_start_dt) OR (l_ass_start_dt = l_pay_start_dt))) THEN
                        IF (l_term_date is not null AND ((l_term_date < l_pay_end_dt) OR (l_term_date = l_pay_start_dt)))THEN
                               OPEN c_no_of_days(l_term_date,l_ass_start_dt);
                               FETCH c_no_of_days into l_days;
                                     IF (c_no_of_days%FOUND AND l_days IS NOT NULL)THEN
                                        CLOSE c_no_of_days;
                                        l_actual_work_days := l_days;
                                        pqp_utilities.debug(' l_actual_work_days 1 is '|| l_actual_work_days , 105);
                                      ELSE
                                        CLOSE c_no_of_days;
                                      END IF;
                        ELSE
                               OPEN c_no_of_days(l_pay_end_dt,l_ass_start_dt);
                               FETCH c_no_of_days into l_days;
                                     IF (c_no_of_days%FOUND AND l_days IS NOT NULL)THEN
                                        CLOSE c_no_of_days;
                                        l_actual_work_days := l_days;
                                        pqp_utilities.debug(' l_actual_work_days 0 is '|| l_actual_work_days , 105);
                                        pqp_utilities.debug(' l_days 0 is '|| l_days , 105);
                                      ELSE
                                        CLOSE c_no_of_days;
                                     END IF;
                        END IF;

                     ELSE
                        IF (l_term_date is not null AND ((l_term_date < l_pay_end_dt) OR (l_term_date = l_pay_end_dt))) THEN
                                  OPEN c_no_of_days(l_term_date,l_pay_start_dt);
                                  FETCH c_no_of_days into l_days;
                                        IF (c_no_of_days%FOUND AND l_days IS NOT NULL)THEN
                                           CLOSE c_no_of_days;
                                           l_actual_work_days := l_days;
                                        ELSE
                                            CLOSE c_no_of_days;
                                        END IF;
                        END IF; --term date check

                     END IF;-- assgn_start_dt check


                   IF(l_ass_start_dt IS NOT NULL AND l_ass_start_dt > l_pay_start_dt) THEN
                      l_pay_start_dt := l_ass_start_dt;
                   END IF;

                   IF(l_term_date  IS NOT NULL AND l_term_date < l_pay_end_dt) THEN
                      l_pay_end_dt := l_term_date;
                   END IF;

                    IF l_debug THEN
                       pqp_utilities.debug(' l_average_days_divisor is '|| l_average_days_divisor , 150);
                       pqp_utilities.debug(' l_payroll_days is '|| l_payroll_days , 160);
                       pqp_utilities.debug(' l_actual_work_days is '|| l_actual_work_days , 170);
                       pqp_utilities.debug(' l_pay_start_dt is '|| l_pay_start_dt , 172);
                       pqp_utilities.debug(' l_pay_end_dt is '|| l_pay_end_dt , 175);
                    END IF;

                   -- assignment level overrides
                  OPEN c_get_avg_si_assignment(p_assignment_id);
                  FETCH c_get_avg_si_assignment into l_override_method,l_overridden_avgsi_assignment;
                      IF (c_get_avg_si_assignment%FOUND
                         AND l_overridden_avgsi_assignment IS NOT NULL
                         AND l_override_method IS NOT NULL)THEN
                         CLOSE c_get_avg_si_assignment;

                         IF l_debug THEN
                            pqp_utilities.debug(' c_get_avg_si_assignment  found ', 4);
                            pqp_utilities.debug(' l_override_method ' || l_override_method, 5);
                            pqp_utilities.debug(' l_overridden_avgsi_assignment ' || l_overridden_avgsi_assignment ,6);
                         END IF;

                         IF (l_override_method = 0) THEN --'Manual Entry'
                             l_average_days_multiplier := l_overridden_avgsi_assignment;
                         ELSIF (l_override_method = 1 ) THEN --'Percentage of Average Days'
                             l_average_days_multiplier :=
                             l_average_days_multiplier * l_overridden_avgsi_assignment/100;
                             -- Bug 3122357
                             --prorate the average_si_days value for actual days worked
                             IF (l_payroll_days <> 0 and l_actual_work_days <> -99) THEN
                                 l_average_days_multiplier := (l_average_days_multiplier/l_payroll_days * l_actual_work_days);
                             END IF;

                         ELSIF (l_override_method = 2 ) THEN -- 'Percentage of Maximum Days'
--                               l_max_si_days := pay_nl_si_pkg.Get_Max_SI_Days(p_assignment_id,l_pay_start_dt,l_pay_end_dt);
--                               l_average_days_multiplier := l_max_si_days * l_overridden_avgsi_assignment /100;
                                  --bug 3115132
                                  --get the method for maximum si days from social insurance tab
                                  OPEN c_get_max_si_values(p_assignment_id,p_date_earned);
                                  FETCH c_get_max_si_values into l_max_si_method,l_overridden_realsi_assignment;
                                        IF (c_get_max_si_values%FOUND AND l_max_si_method IS NOT NULL )THEN
                                            CLOSE c_get_max_si_values;

                                            IF (l_max_si_method = 0 ) THEN -- 1 indicates 'Payroll Period' 0 indicates Weeks worked.
                                               --first check if a work pattern is attached to the ASG, if not
                                               -- return a warning condition and calculate the deduction amount to be 0
                                               OPEN c_get_work_pattern(p_assignment_id,p_date_earned);
                                               FETCH c_get_work_pattern INTO l_work_pattern;
                                               IF c_get_work_pattern%FOUND AND l_work_pattern IS NOT NULL THEN
                                                  CLOSE c_get_work_pattern;
                                               ELSE
                                                  CLOSE c_get_work_pattern;
                                                  l_ret_val := 3;
                                               END IF;
                                                l_max_si_days :=
                                                pay_nl_si_pkg.Get_Max_SI_Days(p_assignment_id,l_pay_start_dt,l_pay_end_dt);
                                            ELSE
                                                l_max_si_days :=
                                                pay_nl_si_pkg.Get_Week_Days(l_pay_start_dt,l_pay_end_dt);
                                            END IF;
                                            l_average_days_multiplier :=
                                            l_max_si_days * l_overridden_avgsi_assignment/100;


                                            IF l_debug THEN
                                               pqp_utilities.debug(' l_max_si_method ' || l_max_si_method, 5);
                                               pqp_utilities.debug(' l_max_si_days ' || l_max_si_days ,6);
                                            END IF;

                                         END IF;
                         END IF;

                         IF l_debug THEN
                            pqp_utilities.debug(' l_average_days_multiplier found '|| l_average_days_multiplier,7);
                         END IF;

                     ELSIF (c_get_avg_si_assignment%FOUND
                            AND
                           (l_overridden_avgsi_assignment IS NULL AND l_override_method IS NOT NULL))
                           THEN

                           l_ret_val := 1;
                           p_error_message := 'Error : Overriding value has not been entered in Average Days Extra Information';

                     ELSIF (c_get_avg_si_assignment%FOUND
                            AND
                           (l_overridden_avgsi_assignment IS NOT NULL AND l_override_method IS NULL))
                            THEN

                            l_ret_val := 1;
                            p_error_message := 'Error : Overriding Method has not been entered in Average Days Extra Information';

                      ELSE
                          bFlagAvgDays := true; -- to indicate that there is no override.
                          CLOSE c_get_avg_si_assignment;
                      END IF;-- check for override at assignment level.

                IF l_debug THEN
                   pqp_utilities.debug(' l_average_days_multiplier found '|| l_average_days_multiplier,7);
                 END IF;

               IF(bFlagAvgDays= true) THEN

                -- check if employee is attached to a work pattern.
                OPEN c_get_work_pattern(p_assignment_id,p_date_earned);
                FETCH c_get_work_pattern INTO l_work_pattern;
                  IF c_get_work_pattern%FOUND AND l_work_pattern IS NOT NULL THEN
                      CLOSE c_get_work_pattern;

                      IF l_debug THEN
                         pqp_utilities.debug(' l_work_pattern is '|| l_work_pattern , 190);
                      END IF;

                      l_working_work_pattern_days := pay_nl_si_pkg.Get_Working_Work_Pattern_days(p_assignment_id) ;
                      l_total_work_pattern_days := pay_nl_si_pkg.Get_Total_Work_Pattern_days(p_assignment_id) ;

                      IF l_debug THEN
                         pqp_utilities.debug(' l_working_work_pattern_days is '|| l_working_work_pattern_days , 200);
                         pqp_utilities.debug(' l_total_work_pattern_days is '|| l_total_work_pattern_days , 210);
                      END IF;

                      -- si factor = working pattern days/total work days * average period days.

                      -- get the average no. of days in the pay period
                      IF (p_payroll_period_prorate LIKE '%Calendar Month'
                          OR p_payroll_period_prorate = 'CM') THEN
                          -- use query for DBI : ORG_DF_NL_ORG_INFORMATION_AVERAGE_DAYS_PER_MONTH
                             l_average_period_days := HR_NL_ORG_INFO.Get_Avg_Days_Per_Month(p_assignment_id);



                      ELSIF (p_payroll_period_prorate LIKE '%Lunar Month'
                            OR p_payroll_period_prorate = 'LM') THEN
                            l_average_period_days := 28;

                      ELSIF (p_payroll_period_prorate LIKE '%Quarter'
                            OR p_payroll_period_prorate = 'Q') THEN
                          -- use query for DBI : ORG_DF_NL_ORG_INFORMATION_AVERAGE_DAYS_PER_MONTH * 3
                            l_average_period_days := HR_NL_ORG_INFO.Get_Avg_Days_Per_Month(p_assignment_id) * 3;

                      ELSIF ( p_payroll_period_prorate LIKE '%Week'
                            OR  p_payroll_period_prorate = 'W') THEN
                            l_average_period_days := 7;

                      ELSE
                            l_ret_val := 1;
                            p_error_message := 'Error : Invalid value for Payroll Period';

                      END IF;

                      IF l_debug THEN
                         pqp_utilities.debug(' p_error_message is '|| p_error_message , 230);
                      END IF;

                      IF (l_ret_val = 0 ) THEN
                          IF(l_total_work_pattern_days <> 0) THEN

                             IF l_debug THEN
                                pqp_utilities.debug(' l_average_period_days is '|| l_average_period_days , 215);
                             END IF;
                             l_average_ws_si_days := l_working_work_pattern_days/l_total_work_pattern_days * l_average_period_days;

                             IF l_debug THEN
                                pqp_utilities.debug(' l_average_ws_si_days is '|| l_average_ws_si_days , 220);
                             END IF;

                             --prorate the average_ws_si_days value for actual days worked
                             IF (l_payroll_days <> 0 and l_actual_work_days <> -99) THEN
                                 l_average_ws_si_days := (l_average_ws_si_days/l_payroll_days * l_actual_work_days);
                             END IF;

                             IF l_debug THEN
                                pqp_utilities.debug(' l_average_ws_si_days is '|| l_average_ws_si_days , 225);
                             END IF;

                            -- get non si days
                             l_non_si_days := pay_nl_si_pkg.Get_Non_SI_Days(p_assignment_id,l_pay_start_dt,l_pay_end_dt);

                             IF l_debug THEN
                                 pqp_utilities.debug(' l_non_si_days is '|| l_non_si_days , 230);
                             END IF;

  --                         avg. work schedule si days = avg. work schedule si days - non si days
                             l_average_ws_si_days := l_average_ws_si_days - l_non_si_days;


  --                         l_prorate_amount = p_amount * l_average_ws_si_days/l_average_si_days;
                             IF(l_average_ws_si_days > 0) THEN
                                l_average_days_multiplier := l_average_ws_si_days;
                             ELSE
                                l_average_days_multiplier := 0;
                             END IF;
                          ELSE
                              l_ret_val := 1;
                              p_error_message := 'Error : Total Work Pattern days is 0. ';
                              p_error_message := p_error_message||'Please verify that the workpattern';
                              p_error_message := p_error_message||' attached to the assignment is defined correctly. ';
                           END IF;
                      END IF;

                 ELSE
  --                 use average days
                     -- with respect to actual days worked,no proration is to be done.
--                     l_average_days_multiplier := l_average_si_days;
                     --prorate average days to the days worked in the pay period.
                     IF (l_payroll_days <> 0 and l_actual_work_days <> -99) THEN
                        l_average_days_multiplier := (l_average_days_multiplier/l_payroll_days * l_actual_work_days);
                     END IF;
                     l_tmp_ret_val := 2;
                     CLOSE c_get_work_pattern;
                 END IF; -- no w.p.
             END IF;-- check for bFlagAvgDays

      ELSE
          CLOSE   c_get_start_end_date;
          l_ret_val := 1;
          p_error_message := 'Payroll period start and end dates could not be ';
          p_error_message := 'determined for the current payroll run.';
      END IF; -- check for payroll id

    END IF;-- check for ret val
  -- Real Working Days

  ELSIF p_conversion_rule = '2' THEN

       IF (l_ret_val = 0) THEN

         --check if the real si values have been overriden at assignment level
            OPEN c_get_max_si_values(p_assignment_id,p_date_earned);
            FETCH c_get_max_si_values into l_max_si_method,l_overridden_realsi_assignment;
                IF (c_get_max_si_values%NOTFOUND OR
                   (c_get_max_si_values%FOUND AND l_overridden_realsi_assignment IS NULL ))THEN
                     CLOSE c_get_max_si_values;

                     IF l_debug THEN
                        pqp_utilities.debug(' c_get_max_si_values not found ', 4);
                     END IF;

                   OPEN c_get_start_end_date(p_assignment_id,p_date_earned);
                   FETCH c_get_start_end_date into l_pay_start_dt,l_pay_end_dt;
                         IF c_get_start_end_date%FOUND THEN
                            CLOSE c_get_start_end_date;

                            IF l_debug THEN
                               pqp_utilities.debug(' l_pay_start_dt is '|| l_pay_start_dt , 10);
                               pqp_utilities.debug(' l_pay_end_dt is '|| l_pay_end_dt , 15);
                            END IF;

                         -- check if the assignment has started in this payroll period.
                            OPEN c_get_assign_start_date(p_assignment_id,l_pay_start_dt,l_pay_end_dt);
                            FETCH c_get_assign_start_date into l_ass_start_dt,l_term_date;
                               IF (c_get_assign_start_date%FOUND AND l_ass_start_dt IS NOT NULL)THEN
                                   CLOSE c_get_assign_start_date;
                                   l_ret_val := 0;
                                   IF l_debug THEN
                                      pqp_utilities.debug(' l_ass_start_dt is '|| l_ass_start_dt , 20);
                                   END IF;
                               ELSE
                                  CLOSE c_get_assign_start_date;
                                  --p_error_message := 'Error: Unable to find the assignment start date for the person ';
                                  p_prorated_amount := 0;
	        RETURN 0;
                               END IF;-- assignment date check

                            OPEN c_term_date_decode(l_term_date);
                            FETCH c_term_date_decode into l_term_date;
                            CLOSE c_term_date_decode;

                            IF (l_term_date IS NOT NULL) THEN
                               --        check if there is a date tracked row with active assignment from the start of the
                               --        next pay run.

                              OPEN c_get_asg_end_date(p_assignment_id,l_term_date+1);
                              FETCH c_get_asg_end_date into l_next_term_date;
                                IF (c_get_asg_end_date%FOUND)THEN
                                   CLOSE c_get_asg_end_date;
                                   l_term_date := l_next_term_date;
                                   IF l_debug THEN
                                      pqp_utilities.debug(' l_next_term_date is '|| l_next_term_date , 92);
                                   END IF;
                                ELSE
                                   CLOSE c_get_asg_end_date;
                                END IF; -- assignment end date found
                            END IF;-- term date is not null

                            IF l_debug THEN
                               pqp_utilities.debug(' l_term_date is '|| l_term_date , 91);
                            END IF;
/*                              -- get termination date
                               OPEN c_get_ass_term_date(p_assignment_id,l_pay_start_dt,l_pay_end_dt);
                               FETCH c_get_ass_term_date into l_term_date;
                               IF (c_get_ass_term_date%FOUND AND l_term_date IS NOT NULL)THEN
                                   CLOSE c_get_ass_term_date;

                                   IF l_debug THEN
                                      pqp_utilities.debug(' l_term_date is '|| l_term_date , 30);
                                   END IF;
                               ELSE
                                   CLOSE c_get_ass_term_date;
                               END IF;-- term date check
*/



                               IF l_debug THEN
                                  pqp_utilities.debug(' l_ret_val is '|| l_ret_val , 31);
                               END IF;

                               IF (l_ret_val = 0 )THEN
                                  IF(l_ass_start_dt IS NOT NULL AND l_ass_start_dt > l_pay_start_dt) THEN
                                     l_pay_start_dt := l_ass_start_dt;
                                  END IF;

                                  IF(l_term_date  IS NOT NULL AND l_term_date < l_pay_end_dt) THEN
                                     l_pay_end_dt := l_term_date;
                                  END IF;

                                  IF l_debug THEN
                                      pqp_utilities.debug(' l_pay_start_dt is '|| l_pay_start_dt , 32);
                                      pqp_utilities.debug(' l_pay_end_dt is '|| l_pay_end_dt , 33);
                                  END IF;

                                  -- check if employee is attached to a work pattern.
                                  OPEN c_get_work_pattern(p_assignment_id,p_date_earned);
                                  FETCH c_get_work_pattern INTO l_work_pattern;
                                        IF (c_get_work_pattern%FOUND AND l_work_pattern IS NOT NULL)THEN
                                           CLOSE c_get_work_pattern;

                                           IF l_debug THEN
                                               pqp_utilities.debug(' l_work_pattern is '|| l_work_pattern , 40);
                                           END IF;

                                           l_working_work_pattern_days := pqp_schedule_calculation_pkg.get_days_worked
                                           ( p_assignment_id => p_assignment_id
                                           ,p_business_group_id   => p_business_group_id
                                           ,p_date_start => l_pay_start_dt
                                           ,p_date_end =>l_pay_end_dt
                                           ,p_error_code => l_error_code
                                           ,p_error_message => l_error_message
                                           ,p_override_wp    => l_work_pattern
                                           );

                                           IF l_debug THEN
                                               pqp_utilities.debug(' l_working_work_pattern_days is '|| l_working_work_pattern_days , 50);
                                           END IF;

                                           IF (l_max_si_method = 0 ) THEN          -- 1 indicates 'Payroll Period' 0 indicates Weeks worked.
                                               l_max_si_days := pay_nl_si_pkg.Get_Max_SI_Days(p_assignment_id,l_pay_start_dt,l_pay_end_dt);
                                           ELSE
                                               l_max_si_days := pay_nl_si_pkg.Get_Week_Days(l_pay_start_dt,l_pay_end_dt);
                                           END IF;

                                           IF l_debug THEN
                                               pqp_utilities.debug(' l_max_si_days is '|| l_max_si_days , 60);
                                           END IF;

                                           l_non_si_days := pay_nl_si_pkg.Get_Non_SI_Days(p_assignment_id,l_pay_start_dt,l_pay_end_dt);

                                           IF l_debug THEN
                                               pqp_utilities.debug(' l_non_si_days is '|| l_non_si_days , 70);
                                           END IF;

                                           IF (l_working_work_pattern_days > l_max_si_days ) THEN
                                               l_real_si_days := l_max_si_days;
                                           ELSE
                                               l_real_si_days := l_working_work_pattern_days;
                                           END IF;

                                           IF l_debug THEN
                                               pqp_utilities.debug(' l_real_si_days is '|| l_real_si_days , 80);
                                           END IF;

                                           l_real_si_days := l_real_si_days - l_non_si_days;

              --                             l_average_days_divisor := l_max_si_days ;

                                           IF(l_real_si_days > 0) THEN
                                              l_average_days_multiplier := l_real_si_days ;
                                           ELSE
                                              l_average_days_multiplier := 0;
                                           END IF;

                                        ELSE
                                            l_ret_val := 3;
                                            CLOSE c_get_work_pattern;
                                        END IF; -- check for w.p.
                               END IF; -- ret val is zero
                       ELSE
                           CLOSE c_get_start_end_date;
                           l_ret_val := 1;
                           p_error_message := 'Payroll period start and end dates could not ';
                           p_error_message := p_error_message||'be determined for the current payroll run.';
                       END IF;  --check for payroll id
                   ELSE
                       CLOSE c_get_max_si_values;
                       l_average_days_multiplier := l_overridden_realsi_assignment;
                       IF l_debug THEN
                          pqp_utilities.debug(' l_overridden_realsi_assignment ' || l_overridden_realsi_assignment, 90);
                       END IF;
                   END IF;-- check for max si days
      END IF; -- ret val is zero.

  -- if the conversion rule is Prorate to pay period, divide by the number
  -- of pay periods in a year
  ELSIF  p_conversion_rule = '3' then

     IF l_ret_val = 0 then

          -- check IF the assignment has started in this payroll period.
          OPEN c_get_assign_start_date(p_assignment_id,l_pay_start_dt,l_pay_end_dt);
          FETCH c_get_assign_start_date into l_ass_start_dt,l_term_date;
            IF (c_get_assign_start_date%FOUND
                AND l_ass_start_dt IS NOT NULL)THEN
               CLOSE c_get_assign_start_date;
               IF l_debug THEN
                  pqp_utilities.debug(' l_ass_start_dt is '|| l_ass_start_dt , 91);
                  pqp_utilities.debug(' l_term_date is '|| l_term_date , 91);
               END IF;
            ELSE
               CLOSE c_get_assign_start_date;
               p_prorated_amount := 0;
               RETURN 0;
               --p_error_message := 'Error: Unable to find the assignment start date for the person ';
            END IF; -- assignment start date found

            OPEN c_term_date_decode(l_term_date);
            FETCH c_term_date_decode into l_term_date;
            CLOSE c_term_date_decode;



           IF (l_term_date IS NOT NULL) THEN
               --        check if there is a date tracked row with active assignment from the start of the
               --        next pay run.

              OPEN c_get_asg_end_date(p_assignment_id,l_term_date+1);
              FETCH c_get_asg_end_date into l_next_term_date;
                IF (c_get_asg_end_date%FOUND)THEN
                   CLOSE c_get_asg_end_date;
                   l_term_date := l_next_term_date;
                   IF l_debug THEN
                      pqp_utilities.debug(' l_next_term_date is '|| l_next_term_date , 92);
                   END IF;
                ELSE
                   CLOSE c_get_asg_end_date;
                END IF; -- assignment end date found
           END IF;-- term date is not null

            IF l_debug THEN
               pqp_utilities.debug(' l_term_date is '|| l_term_date , 91);
            END IF;

/*         -- get termination date
           OPEN c_get_ass_term_date(p_assignment_id,l_pay_start_dt,l_pay_end_dt);
           FETCH c_get_ass_term_date into l_term_date;
               IF (c_get_ass_term_date%FOUND AND l_term_date IS NOT NULL)THEN
                  CLOSE c_get_ass_term_date;
                  IF l_debug THEN
                      pqp_utilities.debug(' l_term_date is '|| l_term_date , 101);
                   END IF;
                ELSE
                  CLOSE c_get_ass_term_date;
               END IF;-- get termination dt
*/

               IF(l_ass_start_dt is not null AND ((l_ass_start_dt > l_pay_start_dt) OR (l_ass_start_dt = l_pay_start_dt))) THEN
                   IF (l_term_date is not null AND ((l_term_date < l_pay_end_dt) OR (l_term_date = l_pay_start_dt)))THEN
                          OPEN c_no_of_days(l_term_date,l_ass_start_dt);
                          FETCH c_no_of_days into l_days;
                                IF (c_no_of_days%FOUND AND l_days IS NOT NULL)THEN
                                   CLOSE c_no_of_days;
                                   l_actual_work_days := l_days;
                                   pqp_utilities.debug(' l_actual_work_days  is '|| l_actual_work_days , 105);
                                 ELSE
                                   CLOSE c_no_of_days;
                                 END IF;
                   ELSE
                          OPEN c_no_of_days(l_pay_end_dt,l_ass_start_dt);
                          FETCH c_no_of_days into l_days;
                                IF (c_no_of_days%FOUND AND l_days IS NOT NULL)THEN
                                   CLOSE c_no_of_days;
                                   l_actual_work_days := l_days;
                                   pqp_utilities.debug(' l_actual_work_days  is '|| l_actual_work_days , 106);
                                   pqp_utilities.debug(' l_days  is '|| l_days , 107);
                                 ELSE
                                   CLOSE c_no_of_days;
                                END IF;
                   END IF;

                ELSE
                   IF (l_term_date is not null AND ((l_term_date < l_pay_end_dt) OR (l_term_date = l_pay_end_dt))) THEN
                             OPEN c_no_of_days(l_term_date,l_pay_start_dt);
                             FETCH c_no_of_days into l_days;
                                   IF (c_no_of_days%FOUND AND l_days IS NOT NULL)THEN
                                      CLOSE c_no_of_days;
                                      l_actual_work_days := l_days;
                                   ELSE
                                       CLOSE c_no_of_days;
                                   END IF;
                   END IF; --term date check

            END IF;-- assgn_start_dt check


              IF(l_ass_start_dt IS NOT NULL AND l_ass_start_dt > l_pay_start_dt) THEN
                 l_pay_start_dt := l_ass_start_dt;
              END IF;

              IF(l_term_date  IS NOT NULL AND l_term_date < l_pay_end_dt) THEN
                 l_pay_end_dt := l_term_date;
              END IF;

              IF l_debug THEN
                 pqp_utilities.debug(' l_average_days_divisor is '|| l_average_days_divisor , 151);
                 pqp_utilities.debug(' l_payroll_days is '|| l_payroll_days , 161);
                 pqp_utilities.debug(' l_actual_work_days is '|| l_actual_work_days , 171);
                 pqp_utilities.debug(' l_pay_start_dt is '|| l_pay_start_dt , 173);
                 pqp_utilities.debug(' l_pay_end_dt is '|| l_pay_end_dt , 176);
              END IF;

     l_average_days_multiplier  :=   l_periods_per_yr;

     IF(l_payroll_days <> 0 and l_actual_work_days <> -99) THEN
        l_average_days_multiplier := (l_average_days_multiplier/l_payroll_days * l_actual_work_days);
     END IF;
     l_average_days_divisor     :=   l_prorate_periods_per_yr;

     End If;

  ELSE

    l_ret_val := 1;
    p_error_message := 'Error : Invalid Conversion Rule for prorating amount';

  END IF; -- end of check for conversion rule.

--END IF;-- periods are different.

END IF;--an override of pension days has been entered


IF l_ret_val = 0 THEN

     IF l_debug THEN
       pqp_utilities.debug(' l_average_days_multiplier is '|| l_average_days_multiplier , 250);
       pqp_utilities.debug(' l_average_days_divisor is '|| l_average_days_divisor , 260);
     END IF;

   p_prorated_amount := (p_amount/l_average_days_divisor) * l_average_days_multiplier;
   p_prorated_amount := ROUND(p_prorated_amount,2);

   IF l_debug THEN
      pqp_utilities.debug(' p_prorated_amount is '|| p_prorated_amount , 300);
   END IF;

END IF;

IF (l_tmp_ret_val = 1 AND l_ret_val =0 )THEN
   RETURN 2;
ELSIF (l_tmp_ret_val = 2 AND l_ret_val =0) THEN
   RETURN 4;
ELSE
   RETURN l_ret_val;
END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN

  l_ret_val := 1;
  p_error_message := 'Error occured while prorating the annual amount. Global value ';
  p_error_message := p_error_message||'for Average Days could not be found';


END prorate_amount;

-- ----------------------------------------------------------------------------
-- |--------------------------< get_run_year >--------------------------------|
-- ----------------------------------------------------------------------------
--
function get_run_year
  (p_date_earned   IN     DATE
  ,p_error_message OUT NOCOPY VARCHAR2
  )
RETURN NUMBER IS

l_date_earned    DATE;

BEGIN

l_date_earned := TRUNC(p_date_earned);

RETURN TO_NUMBER(TO_CHAR(l_date_earned,'YYYY'));

END get_run_year;

-- ----------------------------------------------------------------------------
-- |---------------------------< get_bal_val_de >------------------------------|
-- ----------------------------------------------------------------------------
-- This function derives the value of a balance using the _ABP_ASG_YTD route.
-- This is used very sparingly and not for all EE assignments.
-- This is only used in the case of a late hire and when the late hire
-- crosses years for e.g. hired in Dec 2006 but the first payroll
-- is processed eff jan 2007. Do not use this function in any other
-- situation other than ABP late hires.
--
FUNCTION  get_bal_val_de
  (p_business_group_id    IN pqp_pension_types_f.business_group_id%TYPE
  ,p_assignment_id        IN per_all_assignments_f.assignment_id%TYPE
  ,p_date_earned          IN DATE
  ,p_start_date           IN DATE
  ,p_end_date             IN DATE
  ,p_payroll_id           IN NUMBER
  ,p_balance_name         IN VARCHAR2
  ,p_dimension_name       IN VARCHAR2)
RETURN NUMBER IS

l_defined_balance_id  NUMBER;
l_val                 NUMBER :=0;
l_ass_act_id          NUMBER;

CURSOR c_ass_act IS
SELECT max(paa.assignment_action_id)
  FROM pay_assignment_actions paa
      ,pay_payroll_actions    ppa
 WHERE paa.assignment_id        = p_assignment_id
   AND ppa.action_status        = 'C'
   AND ppa.action_type          IN ('Q','R')
   AND paa.action_status        = 'C'
   AND paa.payroll_action_id    = ppa.payroll_action_id
   AND ppa.payroll_id           = Nvl(p_payroll_id,ppa.payroll_id)
   AND ppa.consolidation_set_id = ppa.consolidation_set_id
   AND source_action_id IS NOT NULL
   AND ppa.date_earned BETWEEN p_start_date AND p_end_date
   AND ppa.effective_date <= p_date_earned;

BEGIN
--
-- Get the defined balance id
--
OPEN csr_defined_bal
     (c_balance_name      => p_balance_name
     ,c_dimension_name    => p_dimension_name
     ,c_business_group_id => p_business_group_id);

FETCH csr_defined_bal INTO l_defined_balance_id;

IF csr_defined_bal%NOTFOUND THEN

   l_val :=  0;

ELSE

   l_ass_act_id := NULL;

   OPEN c_ass_act;
   FETCH c_ass_act INTO l_ass_act_id;

   IF c_ass_act%FOUND THEN
      --
      -- Call get_balance_pkg
      --
      l_val := pay_balance_pkg.get_value
               (p_defined_balance_id   => l_defined_balance_id
               ,p_assignment_action_id => l_ass_act_id);
   ELSE
      l_val :=  0;
   END IF;

   CLOSE c_ass_act;

END IF;

CLOSE csr_defined_bal;

RETURN l_val;

EXCEPTION WHEN OTHERS THEN
   CLOSE csr_defined_bal;
   l_val :=0;
RETURN l_val;

END get_bal_val_de;

-- ----------------------------------------------------------------------------
-- |-----------------------------< get_bal_val >-------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION  get_bal_val
  (p_business_group_id    IN pqp_pension_types_f.business_group_id%TYPE
  ,p_assignment_id        IN per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date       IN DATE
  ,p_balance_name         IN VARCHAR2
  ,p_dimension_name       IN VARCHAR2)
RETURN NUMBER IS

l_defined_balance_id  NUMBER;
l_val                 NUMBER :=0;

BEGIN
--
-- Get the defined balance id
--
OPEN  csr_defined_bal
        (c_balance_name      => p_balance_name
        ,c_dimension_name    => p_dimension_name
        ,c_business_group_id => p_business_group_id);

FETCH csr_defined_bal INTO l_defined_balance_id;

IF csr_defined_bal%NOTFOUND THEN
   l_val :=  0;
ELSE
--
-- Call get_balance_pkg
--
l_val := pay_balance_pkg.get_value
    (p_defined_balance_id   => l_defined_balance_id
    ,p_assignment_id        => p_assignment_id
    ,p_virtual_date         => p_effective_date);
END IF;

CLOSE csr_defined_bal;

RETURN l_val;

EXCEPTION WHEN OTHERS THEN
   CLOSE csr_defined_bal;
   l_val :=0;
RETURN l_val;

END get_bal_val;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_abp_pension_salary >-----------------------------|
-- ----------------------------------------------------------------------------
function get_abp_pension_salary
  (p_business_group_id        in  pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned              in  date
  ,p_assignment_id            in  per_all_assignments_f.assignment_id%TYPE
  ,p_payroll_id               in  pay_payroll_actions.payroll_id%TYPE
  ,p_period_start_date        in  date
  ,p_period_end_date          in  date
  ,p_scale_salary             in  number
  ,p_scale_salary_h           in  number
  ,p_ft_rec_bonus             in  number
  ,p_ft_rec_bonus_h           in  number
  ,p_pt_rec_bonus             in  number
  ,p_pt_rec_bonus_h           in  number
  ,p_ft_eoy_bonus             in  number
  ,p_ft_eoy_bonus_h           in  number
  ,p_pt_eoy_bonus             in  number
  ,p_pt_eoy_bonus_h           in  number
  ,p_salary_balance_value     out nocopy number
  ,p_error_message            out nocopy varchar2
  ,p_oht_correction           out nocopy varchar2
  ,p_scale_salary_eoy_bonus   in  number
  ,p_ft_rec_bonus_eoy_bonus   in  number
  ,p_pt_rec_bonus_eoy_bonus   in  number
  ,p_error_message1           out nocopy varchar2
  ,p_error_message2           out nocopy varchar2
  ,p_late_hire_indicator      in number
  ) return number IS

-- Cursor to get the hire date of the person
CURSOR c_hire_dt_cur(c_asg_id IN NUMBER) IS
SELECT max(date_start)
 FROM  per_all_assignments_f asg
      ,per_periods_of_service pps
 WHERE pps.person_id     = asg.person_id
   AND asg.assignment_id = c_asg_id
   AND pps.business_group_id = p_business_group_id
   AND date_start <= p_date_earned;

CURSOR c_pt_cur (c_effective_date IN DATE) IS
SELECT fnd_number.canonical_to_number(NVL(target.SEGMENT29,'100')) pt_perc
 FROM  per_assignments_f asg
      ,hr_soft_coding_keyflex target
 WHERE asg.assignment_id = p_assignment_id
   AND target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
   AND trunc(c_effective_date) between asg.effective_start_date
                     AND asg.effective_end_date
   AND target.enabled_flag = 'Y';

--cursor to fetch the assignment start date
CURSOR c_get_asg_start IS
SELECT min(effective_start_date)
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id;

-- =============================================================================
-- Cursor to get the defined balance id for a given balance and dimension
-- =============================================================================
CURSOR csr_defined_bal (c_balance_name      IN Varchar2
                       ,c_dimension_name    IN Varchar2
                       ,c_business_group_id IN Number) IS
 SELECT db.defined_balance_id
   FROM pay_balance_types pbt
       ,pay_defined_balances db
       ,pay_balance_dimensions bd
  WHERE pbt.balance_name        = c_balance_name
    AND pbt.balance_type_id     = db.balance_type_id
    AND bd.balance_dimension_id = db.balance_dimension_id
    AND bd.dimension_name       = c_dimension_name
    AND (pbt.business_group_id  = c_business_group_id OR
         pbt.legislation_code   = 'NL')
    AND (db.business_group_id   = pbt.business_group_id OR
         db.legislation_code    = 'NL');

-- =======================================================================
-- Cursor to get the holiday allowance global
-- =======================================================================
CURSOR c_global_cur(c_global_name IN VARCHAR2) IS
SELECT fnd_number.canonical_to_number(global_value)
  FROM ff_globals_f
 WHERE global_name = c_global_name
   AND trunc (p_date_earned) BETWEEN effective_start_date
   AND effective_end_date;

-- =======================================================================
-- Cursor to get the collective agreement name as of 1 Jan/Hire Date
-- =======================================================================
CURSOR c_cag_name (c_asg_id    IN NUMBER
                  ,c_eff_date  IN DATE) IS
SELECT cola.name
  FROM per_collective_agreements cola
      ,per_all_assignments_f asg
 WHERE asg.assignment_id = c_asg_id
   AND asg.collective_agreement_id = cola.collective_agreement_id
   AND cola.status = 'A'
   AND c_eff_date BETWEEN asg.effective_start_date
   AND asg.effective_end_date
   AND c_eff_date BETWEEN cola.start_date
   AND NVL(cola.end_date,to_date('31/12/4712','DD/MM/YYYY'));

-- =======================================================================
-- Cursor to get the number of pay periods per year.
-- =======================================================================
CURSOR c_pp_cur IS
SELECT pety.number_per_fiscal_year
  FROM pay_payrolls_f ppaf
      ,per_time_period_types pety
WHERE  ppaf.payroll_id   = p_payroll_id
  AND  ppaf.period_type  = pety.period_type;

-- =======================================================================
-- Cursor to get the choice for average PTP calculation from ASG EIT
-- =======================================================================
CURSOR c_asg_ptp_choice(c_eff_date IN DATE) IS
SELECT aei_information10
  FROM per_assignment_extra_info
WHERE  aei_information_category = 'NL_ABP_PAR_INFO'
  AND  information_type = 'NL_ABP_PAR_INFO'
  AND  assignment_id    = p_assignment_id
  AND  aei_information10 IS NOT NULL
  AND  c_eff_date BETWEEN fnd_date.canonical_to_date(aei_information1)
  AND  fnd_date.canonical_to_date(nvl(aei_information2
      ,fnd_date.date_to_canonical(hr_api.g_eot)));

-- =======================================================================
-- Cursor to get the choice for average PTP calculation from ORG EIT
-- =======================================================================
CURSOR c_org_ptp_choice(c_org_id IN NUMBER) IS
SELECT hoi.org_information1
  FROM hr_organization_information hoi
WHERE  hoi.organization_id = c_org_id
  AND  hoi.org_information_context = 'PQP_NL_ABP_PTP_METHOD'
  AND  hoi.org_information1 IS NOT NULL;

-- =======================================================================
-- Cursor to get the choice for OHT Correction from ASG EIT
-- =======================================================================
CURSOR c_asg_oht_choice(c_eff_date IN DATE) IS
SELECT aei_information11
  FROM per_assignment_extra_info
WHERE  aei_information_category = 'NL_ABP_PAR_INFO'
  AND  information_type = 'NL_ABP_PAR_INFO'
  AND  assignment_id    = p_assignment_id
  AND  aei_information11 IS NOT NULL
  AND  c_eff_date BETWEEN fnd_date.canonical_to_date(aei_information1)
  AND  fnd_date.canonical_to_date(nvl(aei_information2
      ,fnd_date.date_to_canonical(hr_api.g_eot)));

-- =======================================================================
-- Cursor to get the choice for OHT from ORG EIT
-- =======================================================================
CURSOR c_org_oht_choice(c_org_id   IN NUMBER) IS
SELECT hoi.org_information2
  FROM hr_organization_information hoi
WHERE  hoi.organization_id = c_org_id
  AND  hoi.org_information_context = 'PQP_NL_ABP_PTP_METHOD'
  AND  hoi.org_information2 IS NOT NULL;

--Cursor to find the named hierarchy associated with the BG
CURSOR c_find_named_hierarchy Is
select org_information1
 from hr_organization_information
where organization_id = p_business_group_id
 and org_information_context = 'NL_BG_INFO';

--Cursor to find the valid version id for the particular named hierarchy
CURSOR c_find_ver_frm_hierarchy(c_hierarchy_id in Number
                               ,c_eff_date in Date) Is
select ORG_STRUCTURE_VERSION_ID
  from per_org_structure_versions_v
where organization_structure_id = c_hierarchy_id
  and c_eff_date between date_from
  and nvl(date_to,hr_api.g_eot);

--Cursor to find the valid version id for a particular business group
CURSOR c_find_ver_frm_bg(c_eff_date in date) Is
select ORG_STRUCTURE_VERSION_ID
  from per_org_structure_versions_v
where business_group_id = p_business_group_id
  and c_eff_date between date_from
  and nvl( date_to,hr_api.g_eot);

--cursor to fetch the org id for the organization
--attached to this assignment
CURSOR c_get_org_id(c_eff_date IN DATE) IS
SELECT organization_id
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id
  AND  c_eff_date BETWEEN effective_start_date
  AND  effective_end_date;

--Cursor to find the parent id from the org id
CURSOR c_find_parent_id(c_org_id in number
                       ,c_version_id in number) IS
select organization_id_parent
  from per_org_structure_elements
  where organization_id_child = c_org_id
    AND org_structure_version_id = c_version_id
    AND business_group_id = p_business_group_id;

--7344670
--Cursor to check if the assignment is terminated or not.
Cursor chk_term_asg IS
SELECT 1
FROM per_all_assignments_f asg
WHERE assignment_id = p_assignment_id
AND effective_start_date <= p_date_earned
AND assignment_status_type_id IN (SELECT assignment_status_type_id
					   FROM per_assignment_status_types
					  WHERE per_system_status = 'TERM_ASSIGN'
					    AND active_flag = 'Y');

l_asg_term_indicator     VARCHAR2(1);
--7344670

l_loop_again          NUMBER;
l_valid_pt            NUMBER;
l_named_hierarchy     NUMBER;
l_version_id          NUMBER  default null;
l_org_id              NUMBER;
l_run_year            number;
l_begin_of_year_date  date;
l_end_of_last_year    date;
l_beg_of_last_year    date;
l_effective_date      date;
l_hire_date           date;
l_asg_st_date         date;
l_jan_hire_ptp        number;
l_error_message       varchar2(1000);
l_defined_balance_id  NUMBER;
l_scale_salary        NUMBER;
l_scale_salary_h      NUMBER;
l_ft_rec_bonus        NUMBER;
l_ft_rec_bonus_h      NUMBER;
l_pt_rec_bonus        NUMBER;
l_pt_rec_bonus_h      NUMBER;
l_ft_non_rec_bonus    NUMBER;
l_ft_non_rec_bonus_h  NUMBER;
l_pt_non_rec_bonus    NUMBER;
l_pt_non_rec_bonus_h  NUMBER;
l_ft_eoy_bonus        NUMBER;
l_ft_eoy_bonus_h      NUMBER;
l_pt_eoy_bonus        NUMBER;
l_pt_eoy_bonus_h      NUMBER;
l_scale_eoy_bonus        number;
l_ft_rec_bonus_eoy_bonus number;
l_pt_rec_bonus_eoy_bonus number;
l_avg_prev_year_ptp   NUMBER;
l_holiday_allowance   NUMBER;
l_pension_sal_prev_yr NUMBER;
l_holiday_allow_per   NUMBER;
l_inflation_per       NUMBER;
l_per_age             NUMBER;
l_max_inflated_sal    NUMBER;
l_min_holiday_allow   NUMBER;
l_cag_name            per_collective_agreements.name%TYPE;
l_min_holiday_char    VARCHAR2(80);
l_max_periods         NUMBER;
l_ptp_choice          VARCHAR2(1);
l_max_ptp             NUMBER := 0;
l_prev_max_ptp        NUMBER := 0;
l_ret_val             NUMBER := 0;
l_error_status        CHAR;
l_eoy_bonus_org       NUMBER := 0;
l_eoy_bonus_perc      NUMBER := 0;
l_min_eoy_bonus_char  VARCHAR2(80):='';
l_min_eoy_bonus       NUMBER:=0;
l_eoy_bonus_ca        NUMBER:=0;
l_py_late_hire_ind    NUMBER;
l_message_flag        CHAR;
UDT_CONTAINS_NO_DATA  EXCEPTION;
l_retro_avg_ptp       NUMBER:=0;

BEGIN

l_scale_salary           := NVL(p_scale_salary,0);
l_scale_salary_h         := NVL(p_scale_salary_h,0);
l_ft_rec_bonus           := NVL(p_ft_rec_bonus,0);
l_ft_rec_bonus_h         := NVL(p_ft_rec_bonus_h,0);
l_pt_rec_bonus           := NVL(p_pt_rec_bonus,0);
l_pt_rec_bonus_h         := NVL(p_pt_rec_bonus_h,0);
l_ft_non_rec_bonus       := 0;
l_ft_non_rec_bonus_h     := 0;
l_pt_non_rec_bonus       := 0;
l_pt_non_rec_bonus_h     := 0;
l_ft_eoy_bonus           := NVL(p_ft_eoy_bonus,0);
l_ft_eoy_bonus_h         := NVL(p_ft_eoy_bonus_h,0);
l_pt_eoy_bonus           := NVL(p_pt_eoy_bonus,0);
l_pt_eoy_bonus_h         := NVL(p_pt_eoy_bonus_h,0);
l_holiday_allowance      := 0;
l_pension_sal_prev_yr    := 0;
l_holiday_allow_per      := 0;
l_inflation_per          := 0;
l_per_age                := 0;
l_loop_again             := 1;
p_oht_correction         :='N';
l_scale_eoy_bonus        := NVL(p_scale_salary_eoy_bonus,0);
l_ft_rec_bonus_eoy_bonus := NVL(p_ft_rec_bonus_eoy_bonus,0);
l_pt_rec_bonus_eoy_bonus := NVL(p_pt_rec_bonus_eoy_bonus,0);
l_eoy_bonus_org          := 0;
l_eoy_bonus_perc         := 0;
l_min_eoy_bonus          := 0;
l_eoy_bonus_ca           := 0;
l_py_late_hire_ind       := 0;
p_error_message          :='';
p_error_message1         :='';
p_error_message2         :='';
l_message_flag           :='';

l_run_year := get_run_year (p_date_earned
                           ,l_error_message );

--
-- Get the date for 1 JAN of the run year
--
l_begin_of_year_date := TO_DATE('01/01/'||to_char(l_run_year),'DD/MM/YYYY');
--
-- Get the date for 31 DEC of the prev  year
--
l_end_of_last_year := TO_DATE('31/12/'||to_char(l_run_year - 1),'DD/MM/YYYY');
--
-- Get the date for 1 JAN of the prev  year
--
l_beg_of_last_year := TO_DATE('01/01/'||to_char(l_run_year - 1),'DD/MM/YYYY');

--7344670
OPEN chk_term_asg;
FETCH chk_term_asg INTO l_asg_term_indicator;
IF chk_term_asg%FOUND THEN
 p_error_message := 'The pension salary is zero as the assignment is not active.';
 p_salary_balance_value := 0;
 CLOSE chk_term_asg;
 Return 2;
END IF;
CLOSE chk_term_asg;
--7344670

--
-- Get the latest start date of the assignment
--
OPEN c_get_asg_start;
FETCH c_get_asg_start INTO l_asg_st_date;
IF c_get_asg_start%FOUND THEN
   CLOSE c_get_asg_start;
ELSE
   CLOSE c_get_asg_start;
   p_error_message := 'Error: Unable to find the start date of the assignment';
   p_salary_balance_value := 0;
   RETURN 1;
END IF;

--
-- Get the hire date
--
OPEN c_hire_dt_cur (p_assignment_id);

FETCH c_hire_dt_cur INTO l_hire_date;
   IF c_hire_dt_cur%FOUND THEN
         -- The effective date is now the valid assignemnt
	 --start date for the assignment
         l_effective_date := PQP_NL_ABP_FUNCTIONS.GET_VALID_START_DATE(p_assignment_id,p_date_earned,l_error_status,l_error_message);
         IF(l_error_status = trim(to_char(1,'9'))) Then
           fnd_message.set_name('PQP',l_error_message);
           p_error_message :='Error : '|| fnd_message.get();
           p_salary_balance_value :=0;
           RETURN 1;
         End IF;
   ELSE
      p_error_message := 'Error: Unable to find the hire date for the person ';
      p_salary_balance_value :=0;
      RETURN 1;
   END IF; -- Hire date found

CLOSE c_hire_dt_cur;

--
-- Get the maximum number of periods in a year.
--
OPEN c_pp_cur;

   FETCH c_pp_cur INTO l_max_periods;
   IF c_pp_cur%NOTFOUND THEN
      p_error_message := 'Error: Unable to find the pay periods per year';
      p_salary_balance_value :=0;
      CLOSE c_pp_cur;
      RETURN 1;
   ELSE
      CLOSE c_pp_cur;
   END IF;

--
-- Calculate the ptp as of 1 jan or Hire Date
--
OPEN c_pt_cur (l_effective_date);

FETCH c_pt_cur INTO l_jan_hire_ptp;

IF c_pt_cur%NOTFOUND THEN
   CLOSE c_pt_cur;
   p_error_message := 'Error: Unable to find the part time percentage.';
   p_error_message := p_error_message || 'Please enter a value as of 1 January or Hire Date';
   p_salary_balance_value :=0;
   RETURN 1;
ELSE
    CLOSE c_pt_cur;
END IF;

IF l_jan_hire_ptp = 0 THEN
   l_jan_hire_ptp := 100;
END IF;

--restrict the part time percentage to a max of 125
IF l_jan_hire_ptp > 125 THEN
   l_max_ptp := 1;
END IF;

l_jan_hire_ptp := LEAST(l_jan_hire_ptp,125);

l_jan_hire_ptp := l_jan_hire_ptp/100;

-- Divide all the pt balances by this value

l_pt_rec_bonus           := l_pt_rec_bonus/l_jan_hire_ptp;
l_pt_rec_bonus_h         := l_pt_rec_bonus_h/l_jan_hire_ptp;
l_pt_eoy_bonus           := l_pt_eoy_bonus/l_jan_hire_ptp;
l_pt_eoy_bonus_h         := l_pt_eoy_bonus_h/l_jan_hire_ptp;
l_pt_rec_bonus_eoy_bonus := l_pt_rec_bonus_eoy_bonus/l_jan_hire_ptp;

--
-- Check if the EE asg was a late hire in the prev year
--
l_py_late_hire_ind := pqp_pension_functions.get_bal_val
  (p_business_group_id   => p_business_group_id
  ,p_assignment_id       => p_assignment_id
  ,p_effective_date      => l_end_of_last_year
  ,p_balance_name        => 'ABP Late Hire'
  ,p_dimension_name      => 'Assignment Year To Date' );

--
-- Get the average ptp of the prev year
--
IF ( NVL(p_late_hire_indicator,0) = 1 OR l_py_late_hire_ind > 0) THEN
l_avg_prev_year_ptp := get_bal_val_de
  (p_business_group_id    => p_business_group_id
  ,p_assignment_id        => p_assignment_id
  ,p_date_earned          => p_date_earned
  ,p_start_date           => l_beg_of_last_year
  ,p_end_date             => l_end_of_last_year
  ,p_payroll_id           => p_payroll_id
  ,p_balance_name         => 'ABP Average Part Time Percentage'
  ,p_dimension_name       => 'NL Assignment ABP Year To Date Dimension');
ELSE
l_avg_prev_year_ptp := pqp_pension_functions.get_bal_val
  (p_business_group_id   => p_business_group_id
  ,p_assignment_id       => p_assignment_id
  ,p_effective_date      => l_end_of_last_year
  ,p_balance_name        => 'ABP Average Part Time Percentage'
  ,p_dimension_name      => 'Assignment Year To Date' );
END IF;

--
-- Get the retro ptp of the prev year
--
IF ( NVL(p_late_hire_indicator,0) = 1 OR l_py_late_hire_ind > 0) THEN
l_retro_avg_ptp := get_bal_val_de
  (p_business_group_id    => p_business_group_id
  ,p_assignment_id        => p_assignment_id
  ,p_date_earned          => p_date_earned
  ,p_start_date           => l_beg_of_last_year
  ,p_end_date             => l_end_of_last_year
  ,p_payroll_id           => p_payroll_id
  ,p_balance_name         => 'Retro ABP Part Time Percentage'
  ,p_dimension_name       => 'NL Assignment ABP Year To Date Dimension');
ELSE
l_retro_avg_ptp := pqp_pension_functions.get_bal_val
  (p_business_group_id   => p_business_group_id
  ,p_assignment_id       => p_assignment_id
  ,p_effective_date      => l_end_of_last_year
  ,p_balance_name        => 'Retro ABP Part Time Percentage'
  ,p_dimension_name      => 'Assignment Year To Date' );
END IF;

l_avg_prev_year_ptp := l_avg_prev_year_ptp/l_max_periods;

l_avg_prev_year_ptp := l_avg_prev_year_ptp + NVL(l_retro_avg_ptp,0);

IF l_avg_prev_year_ptp > 125 THEN
   l_prev_max_ptp := 1;
END IF;

l_avg_prev_year_ptp := LEAST(l_avg_prev_year_ptp,125);

l_avg_prev_year_ptp := l_avg_prev_year_ptp/100;

--
--Find the valid org hierarchy version on a particular date
--

--first chk to see if a named hierarchy exists for the BG
OPEN c_find_named_hierarchy;
FETCH c_find_named_hierarchy INTO l_named_hierarchy;
   -- if a named hiearchy is found , find the valid version on that date
   IF c_find_named_hierarchy%FOUND THEN
      CLOSE c_find_named_hierarchy;
      -- now find the valid version on that date
      OPEN c_find_ver_frm_hierarchy(l_named_hierarchy
                                    ,l_effective_date);
      FETCH c_find_ver_frm_hierarchy INTO l_version_id;
        --if no valid version is found, try to get it frm the BG
        IF c_find_ver_frm_hierarchy%NOTFOUND THEN
           CLOSE c_find_ver_frm_hierarchy;
           -- find the valid version id from the BG
           OPEN c_find_ver_frm_bg(l_effective_date);
             FETCH c_find_ver_frm_bg INTO l_version_id;
           CLOSE c_find_ver_frm_bg;
         -- else a valid version has been found for the named hierarchy
         ELSE
            CLOSE c_find_ver_frm_hierarchy;
         END IF;
   -- else find the valid version from BG
   ELSE
      CLOSE c_find_named_hierarchy;
       --now find the version number from the BG
       OPEN c_find_ver_frm_bg(l_effective_date);
       FETCH c_find_ver_frm_bg INTO l_version_id;
       CLOSE c_find_ver_frm_bg;
   END IF;
--
-- Check if OHT is to be applied to pension salary.
-- Pass this flag back to the function.
--
OPEN c_asg_oht_choice(l_effective_date);
FETCH c_asg_oht_choice INTO p_oht_correction;
IF c_asg_oht_choice%FOUND THEN
   CLOSE c_asg_oht_choice;
ELSIF c_asg_oht_choice%NOTFOUND THEN
   -- Check the rule at the org level.
   CLOSE c_asg_oht_choice;
   OPEN c_get_org_id(l_effective_date);
   FETCH c_get_org_id INTO l_org_id;
   CLOSE c_get_org_id;
   WHILE (l_loop_again = 1)
   LOOP
      OPEN c_org_oht_choice(l_org_id);
      FETCH c_org_oht_choice INTO p_oht_correction;
      IF c_org_oht_choice%FOUND THEN
         CLOSE c_org_oht_choice;
         l_loop_again := 0;
      ELSE
         CLOSE c_org_oht_choice;
         IF l_version_id IS NOT NULL THEN
            OPEN c_find_parent_id(c_org_id => l_org_id
                                 ,c_version_id => l_version_id
                                 );
            FETCH c_find_parent_id INTO l_org_id;
            IF c_find_parent_id%FOUND THEN
               CLOSE c_find_parent_id;
            ELSE
               p_oht_correction := 'N';
               CLOSE c_find_parent_id;
               l_loop_again := 0;
            END IF;
         ELSE
            p_oht_correction := 'N';
            l_loop_again := 0;
         END IF;
      END IF;
    END LOOP;
END IF;
l_loop_again := 1;
--
-- Check the ptp method at the assignment level as of 1 Jan or Hire Date
--
OPEN c_asg_ptp_choice(l_effective_date);
FETCH c_asg_ptp_choice INTO l_ptp_choice;
IF c_asg_ptp_choice%FOUND THEN
   CLOSE c_asg_ptp_choice;
   IF l_ptp_choice = '0' THEN
      l_avg_prev_year_ptp := l_jan_hire_ptp;
      IF l_max_ptp = 1 THEN
         p_error_message := 'The part time percentage is restricted to a'
                          ||' maximum of 125.';
         l_ret_val := 2;
      END IF;
   ELSE
      IF l_prev_max_ptp = 1 THEN
         p_error_message := 'The part time percentage is restricted to a'
                          ||' maximum of 125.';
         l_ret_val := 2;
      END IF;
   END IF;
ELSE
   --
   -- Check the method defined at the HR Org
   --
   CLOSE c_asg_ptp_choice;
   OPEN c_get_org_id(l_effective_date);
   FETCH c_get_org_id INTO l_org_id;
   CLOSE c_get_org_id;
   WHILE (l_loop_again = 1)
   LOOP
      OPEN c_org_ptp_choice(l_org_id);
      FETCH c_org_ptp_choice INTO l_ptp_choice;
      IF c_org_ptp_choice%FOUND THEN
         CLOSE c_org_ptp_choice;
         l_loop_again := 0;
         IF l_ptp_choice = '0' THEN
            l_avg_prev_year_ptp := l_jan_hire_ptp;
            IF l_max_ptp = 1 THEN
               p_error_message := 'The part time percentage is restricted to a'
                                ||' maximum of 125.';
               l_ret_val := 2;
            END IF;
         ELSE
            IF l_prev_max_ptp = 1 THEN
               p_error_message := 'The part time percentage is restricted to a'
                                ||' maximum of 125.';
               l_ret_val := 2;
            END IF;
         END IF;
      ELSE
         CLOSE c_org_ptp_choice;
         IF l_version_id IS NOT NULL THEN
            OPEN c_find_parent_id(c_org_id => l_org_id
                                 ,c_version_id => l_version_id
                                 );
            FETCH c_find_parent_id INTO l_org_id;
            IF c_find_parent_id%FOUND THEN
               CLOSE c_find_parent_id;
            ELSE
               CLOSE c_find_parent_id;
               l_loop_again := 0;
               IF l_prev_max_ptp = 1 THEN
                  p_error_message := 'The part time percentage is restricted to a'
                                   ||' maximum of 125.';
                  l_ret_val := 2;
               END IF;
            END IF;
         ELSE
            l_loop_again := 0;
            IF l_prev_max_ptp = 1 THEN
               p_error_message := 'The part time percentage is restricted to a'
                                ||' maximum of 125.';
               l_ret_val := 2;
            END IF;
         END IF;
      END IF;
  END LOOP;
END IF;

-- If nothing has been defined at the org level or
-- at the assignment level, use average of the previous
-- year.

--
-- Get the FT Non Rec Bonus of the prev Year
--
IF ( NVL(p_late_hire_indicator,0) = 1 OR l_py_late_hire_ind > 0) THEN
l_ft_non_rec_bonus := get_bal_val_de
  (p_business_group_id    => p_business_group_id
  ,p_assignment_id        => p_assignment_id
  ,p_date_earned          => p_date_earned
  ,p_start_date           => l_beg_of_last_year
  ,p_end_date             => l_end_of_last_year
  ,p_payroll_id           => p_payroll_id
  ,p_balance_name         => 'ABP Full Time Non Recurring Bonus'
  ,p_dimension_name       => 'NL Assignment ABP Year To Date Dimension');
ELSE
l_ft_non_rec_bonus := pqp_pension_functions.get_bal_val
  (p_business_group_id   => p_business_group_id
  ,p_assignment_id       => p_assignment_id
  ,p_effective_date      => l_end_of_last_year
  ,p_balance_name        => 'ABP Full Time Non Recurring Bonus'
  ,p_dimension_name      => 'Assignment Year To Date' );
END IF;
--
-- Get the FT Non Rec Bonus of the prev Year for holiday allowance
--
IF ( NVL(p_late_hire_indicator,0) = 1 OR l_py_late_hire_ind > 0) THEN
l_ft_non_rec_bonus_h := get_bal_val_de
  (p_business_group_id    => p_business_group_id
  ,p_assignment_id        => p_assignment_id
  ,p_date_earned          => p_date_earned
  ,p_start_date           => l_beg_of_last_year
  ,p_end_date             => l_end_of_last_year
  ,p_payroll_id           => p_payroll_id
  ,p_balance_name         => 'ABP Full Time Non Recurring Bonus For Holiday Allowance'
  ,p_dimension_name       => 'NL Assignment ABP Year To Date Dimension');
ELSE
l_ft_non_rec_bonus_h := pqp_pension_functions.get_bal_val
  (p_business_group_id   => p_business_group_id
  ,p_assignment_id       => p_assignment_id
  ,p_effective_date      => l_end_of_last_year
  ,p_balance_name        => 'ABP Full Time Non Recurring Bonus For Holiday Allowance'
  ,p_dimension_name      => 'Assignment Year To Date' );
END IF;
--
-- Get the PT Non Rec Bonus of the prev Year
--
IF ( NVL(p_late_hire_indicator,0) = 1 OR l_py_late_hire_ind > 0) THEN
l_pt_non_rec_bonus := get_bal_val_de
  (p_business_group_id    => p_business_group_id
  ,p_assignment_id        => p_assignment_id
  ,p_date_earned          => p_date_earned
  ,p_start_date           => l_beg_of_last_year
  ,p_end_date             => l_end_of_last_year
  ,p_payroll_id           => p_payroll_id
  ,p_balance_name         => 'ABP Part Time Non Recurring Bonus'
  ,p_dimension_name       => 'NL Assignment ABP Year To Date Dimension');
ELSE
l_pt_non_rec_bonus := pqp_pension_functions.get_bal_val
  (p_business_group_id   => p_business_group_id
  ,p_assignment_id       => p_assignment_id
  ,p_effective_date      => l_end_of_last_year
  ,p_balance_name        => 'ABP Part Time Non Recurring Bonus'
  ,p_dimension_name      => 'Assignment Year To Date' );
END IF;

IF l_avg_prev_year_ptp = 0 THEN
   l_pt_non_rec_bonus := 0;
ELSE
   l_pt_non_rec_bonus := l_pt_non_rec_bonus/l_avg_prev_year_ptp;
END IF;

--
-- Get the PT Non Rec Bonus of the prev Year for holiday allowance
--
IF ( NVL(p_late_hire_indicator,0) = 1 OR l_py_late_hire_ind > 0) THEN
l_pt_non_rec_bonus_h := get_bal_val_de
  (p_business_group_id    => p_business_group_id
  ,p_assignment_id        => p_assignment_id
  ,p_date_earned          => p_date_earned
  ,p_start_date           => l_beg_of_last_year
  ,p_end_date             => l_end_of_last_year
  ,p_payroll_id           => p_payroll_id
  ,p_balance_name         => 'ABP Part Time Non Recurring Bonus For Holiday Allowance'
  ,p_dimension_name       => 'NL Assignment ABP Year To Date Dimension');
ELSE
l_pt_non_rec_bonus_h := pqp_pension_functions.get_bal_val
  (p_business_group_id   => p_business_group_id
  ,p_assignment_id       => p_assignment_id
  ,p_effective_date      => l_end_of_last_year
  ,p_balance_name        => 'ABP Part Time Non Recurring Bonus For Holiday Allowance'
  ,p_dimension_name      => 'Assignment Year To Date' );
END IF;

IF l_avg_prev_year_ptp = 0 THEN
   l_pt_non_rec_bonus_h := 0;
   p_error_message := p_error_message || 'The previous year non-recurring '
                     ||'bonus is 0'
                     ||' since the average part time percentage of the '
                     ||'previous year is 0.';
   l_ret_val := 2;
ELSE
   l_pt_non_rec_bonus_h := l_pt_non_rec_bonus_h/l_avg_prev_year_ptp;
END IF;

--
-- EOY Bonus Calculation
-- This section will calculate the end of year bonus
-- based on the EOY Bonus percentage specified at the
-- org level. These will be derived from the following
-- three balances.
--
-- ABP Scale Salary For End Of Year Bonus
-- ABP Full Time Recurring Bonus For End Of Year Bonus
-- ABP Part Time Recurring Bonus For End Of Year Bonus
--

--
-- Call the function to derive EOY Bonus
-- percentage from the org level
--

l_ret_val := pqp_nl_abp_functions.get_eoy_bonus_percentage
             (p_date_earned           => p_date_earned
             ,p_business_group_id     => p_business_group_id
             ,p_assignment_id         => p_assignment_id
             ,p_eoy_bonus_percentage  => l_eoy_bonus_perc
             );

IF l_ret_val <> 0 THEN
   l_eoy_bonus_perc := 0;
END IF;

--
-- Calculate the EOY Bonus that needs to be included for
-- ABP Pension Salary calculations
--
l_eoy_bonus_org := (l_scale_eoy_bonus
                  + l_ft_rec_bonus_eoy_bonus
                  + l_pt_rec_bonus_eoy_bonus)
                  * l_eoy_bonus_perc/100;

-- Check to make sure that the end of year bonus
-- calculated is at least the min of what is defined for
-- the collective agreement

-- Get the CAG Name
OPEN  c_cag_name (c_asg_id    => p_assignment_id
                 ,c_eff_date  => l_effective_date) ;

FETCH c_cag_name INTO l_cag_name;

IF c_cag_name%FOUND THEN

  -- We found a CAG at the asg level . Now get the Min End Of
  -- Year Bonus for this CAG from the UDT.
     Begin
     l_min_eoy_bonus_char := hruserdt.get_table_value
                         (
                          p_bus_group_id    => p_business_group_id
                         ,p_table_name      => 'PQP_NL_MIN_END_OF_YEAR_BONUS'
                         ,p_col_name        => 'Minimum End Of Year Bonus'
                         ,p_row_value       => l_cag_name
                         ,p_effective_date  => l_effective_date
                         );

     l_min_eoy_bonus   := fnd_number.canonical_to_number(NVL(l_min_eoy_bonus_char,'0'));

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             --l_message_flag :='e';
             l_min_eoy_bonus  :=0;
     End;

ELSE
  -- Collective agreement has not been defined at the ASG level
  -- set EOY bonus to 0 .
  l_min_eoy_bonus := 0;
END IF;

CLOSE c_cag_name;

-- Calculate total EOY Bonus
l_eoy_bonus_ca    := ( nvl(l_ft_eoy_bonus,0) + nvl(l_pt_eoy_bonus,0)  + l_eoy_bonus_org)*l_max_periods;

IF l_eoy_bonus_ca < l_min_eoy_bonus THEN
    p_error_message1 :=p_error_message1|| 'Min. end of year bonus for the collective agreement'
                     ||' was used for Pension Salary calculation ';
   l_ret_val := 2;
END IF;


l_eoy_bonus_ca    := GREATEST(l_eoy_bonus_ca,nvl(l_min_eoy_bonus,0));



--
-- Holiday Allowance Calculation
--
OPEN c_global_cur('PQP_NL_HOLIDAY_ALLOWANCE_PERCENT');

FETCH c_global_cur INTO l_holiday_allow_per;
IF c_global_cur%NOTFOUND THEN
   l_holiday_allow_per := 0;
END IF;

CLOSE c_global_cur;


l_holiday_allowance   := (nvl(l_scale_salary_h,0) +
                         nvl(l_ft_rec_bonus_h,0) +
                         nvl(l_pt_rec_bonus_h,0) +
                         nvl(l_ft_eoy_bonus_h,0) +
                         nvl(l_pt_eoy_bonus_h,0)) * l_max_periods * nvl(l_holiday_allow_per,0)/100 ;

-- Check to make sure that the holiday allowance
-- calculated is at least the min of what is defined for
-- the collective agreement

-- Get the CAG Name
OPEN  c_cag_name (c_asg_id    => p_assignment_id
                 ,c_eff_date  => l_effective_date) ;

FETCH c_cag_name INTO l_cag_name;

IF c_cag_name%FOUND THEN

  -- We found a CAG at the asg level . Now get the Min holiday
  -- allowance for this CAG from the UDT.
  Begin
     l_min_holiday_char := hruserdt.get_table_value
                         (
                          p_bus_group_id    => p_business_group_id
                         ,p_table_name      => 'PQP_NL_MIN_HOLIDAY_ALLOWANCE'
                         ,p_col_name        => 'Minimum Holiday Allowance'
                         ,p_row_value       => l_cag_name
                         ,p_effective_date  => l_effective_date
                         );

     l_min_holiday_allow := fnd_number.canonical_to_number(NVL(l_min_holiday_char,'0'));

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_min_holiday_allow := 0;

    /* If(l_message_flag = 'e') THEN
       l_message_flag :='b';
     ELSE
       l_message_flag :='h';
     END IF;
     RAISE UDT_CONTAINS_NO_DATA; */
     -- Code commented out by vjhanak
  END;

/*  IF(l_message_flag = 'e') THEN
     RAISE UDT_CONTAINS_NO_DATA;
  END IF;
*/

ELSE
  -- Collective agreement has not been defined at the ASG level
  -- set holiday allowance to 0
  l_min_holiday_allow := 0;
END IF;

CLOSE c_cag_name;

l_holiday_allowance := nvl(l_holiday_allowance,0) +
                       (nvl(l_ft_non_rec_bonus_h,0) +
                        nvl(l_pt_non_rec_bonus_h,0) )  * nvl(l_holiday_allow_per,0)/100;


IF l_holiday_allowance < l_min_holiday_allow THEN
   p_error_message2 :=p_error_message2||
                      'Min. holiday allowance for the collective agreement'
                      ||'was used for Pension Salary calculation.';
   l_ret_val := 2;
END IF;


l_holiday_allowance := GREATEST(l_holiday_allowance,nvl(l_min_holiday_allow,0));

p_salary_balance_value := (NVL(l_scale_salary,0) +
                           NVL(l_ft_rec_bonus,0) +
                           NVL(l_pt_rec_bonus,0)
                           )  * l_max_periods +
                           NVL(l_holiday_allowance,0) +
			   NVL(l_eoy_bonus_ca ,0)+
                           NVL(l_ft_non_rec_bonus,0) +
                           NVL(l_pt_non_rec_bonus,0);

--
-- Get the age of the EE
--
l_per_age := pay_nl_tax_pkg.get_age_system_date(p_assignment_id,l_begin_of_year_date);

-- Check the change in pension salary compared to the previous year.
-- a max change of 2% plus the inflation percentage should be
-- applied. This is for EE equal to or older than 58 as of
-- 1 January
/*
IF l_per_age >= 58 THEN

--
-- Get the Pension Salary of last year to compare it with this years
--
IF ( NVL(p_late_hire_indicator,0) = 1 OR l_py_late_hire_ind > 0) THEN
l_pension_sal_prev_yr := get_bal_val_de
  (p_business_group_id    => p_business_group_id
  ,p_assignment_id        => p_assignment_id
  ,p_date_earned          => p_date_earned
  ,p_start_date           => l_beg_of_last_year
  ,p_end_date             => l_end_of_last_year
  ,p_payroll_id           => p_payroll_id
  ,p_balance_name         => 'ABP Pension Salary'
  ,p_dimension_name       => 'NL Assignment ABP Year To Date Dimension');
ELSE
l_pension_sal_prev_yr := pqp_pension_functions.get_bal_val
  (p_business_group_id   => p_business_group_id
  ,p_assignment_id       => p_assignment_id
  ,p_effective_date      => l_end_of_last_year
  ,p_balance_name        => 'ABP Pension Salary'
  ,p_dimension_name      => 'Assignment Year To Date' );
END IF;
   --
   -- Get the inflation percentage
   --
   OPEN c_global_cur('PQP_NL_INFLATION_PERCENT');

   FETCH c_global_cur INTO l_inflation_per;
   IF c_global_cur%NOTFOUND THEN
      l_inflation_per := 0;
   END IF;

   l_inflation_per := nvl(l_inflation_per,0) + 2;

   --
   -- Add this percentage to the derived ABP Year income
   --
   IF nvl(l_pension_sal_prev_yr,0) <> 0 THEN
     l_max_inflated_sal := l_pension_sal_prev_yr  +
                           l_pension_sal_prev_yr * l_inflation_per/100;

     IF p_salary_balance_value > l_max_inflated_sal THEN
        p_error_message2 := p_error_message2
                          ||'The inflation percentage has been used to recalculate the'
                          ||' pension salary.';
        l_ret_val := 2;
        p_salary_balance_value := l_max_inflated_sal;
     END IF;
   END IF;

END IF;
*/
RETURN l_ret_val;

EXCEPTION

WHEN UDT_CONTAINS_NO_DATA THEN
   p_salary_balance_value := 0;

   IF(l_message_flag = 'h') THEN
      p_error_message := 'Min. holiday allowance has not been defined'
                       ||' for the collective agreement at the assignment';
   ELSIF (l_message_flag = 'e') THEN
      p_error_message := 'Min. end of year bonus has not been defined'
                       ||' for the collective agreement at the assignment';
   ELSIF (l_message_flag = 'b') THEN
      p_error_message := 'Min. holiday allowance and end of year bonus'
                       ||' have not been defined for the collective agreement at the assignment';
   END IF;

RETURN 1;

WHEN OTHERS THEN

p_salary_balance_value := 0;
p_error_message := 'Error occured while deriving the ABP Pension Salary'
                 ||' value : '||SQLERRM;
RETURN 1;

END get_abp_pension_salary;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_pension_salary >-----------------------------|
-- ----------------------------------------------------------------------------
--
function get_pension_salary
  (p_business_group_id    in     pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned          in     date
  ,p_assignment_id        in     per_all_assignments_f.assignment_id%TYPE
  ,p_payroll_action_id    in     pay_payroll_actions.payroll_action_id%TYPE
  ,p_salary_balance_name  in     varchar2
  ,p_payroll_period       in     varchar2
  ,p_salary_balance_value out nocopy number
  ,p_error_message        out nocopy varchar2
  ,p_pension_type_id      in     pqp_pension_types_f.pension_type_id%TYPE default -99
  ) return number is

l_proc_name           varchar2(150) := g_proc_name || 'get_pension_salary';
l_hire_date           date;
l_date_earned         date;
l_run_year            number;
l_begin_of_year_date  date;
l_effective_date      date;
l_error_message       varchar2(100);
l_defined_bal_id      number;
l_payroll_id          pay_payrolls_f.payroll_id%type;
l_ass_act_id          pay_assignment_actions.assignment_action_id%type := -1;
l_cur_payroll_id      pay_payrolls_f.payroll_id%type;
l_period_start_dt     per_time_periods.start_date%type;
l_period_end_dt       per_time_periods.end_date%type;
l_time_period_id      number;
l_is_abp_pt           number := 0;
l_participation_st_dt date;
l_ret_val             number;
l_dimension_name      pay_balance_dimensions.dimension_name%TYPE := 'Assignment Period To Date';
l_error_status        CHAR:='0';
-- Cursor to get the hire date of the person
CURSOR c_hire_dt_cur(c_asg_id IN NUMBER) IS
SELECT max(date_start)
 FROM  per_all_assignments_f asg
      ,per_periods_of_service pps
 WHERE pps.person_id     = asg.person_id
   AND asg.assignment_id = c_asg_id
   AND pps.business_group_id = p_business_group_id
   AND date_start <= p_date_earned;

-- Cursor to get the defined_balance_id
CURSOR c_def_bal_cur(c_dim_name IN pay_balance_dimensions.dimension_name%TYPE) IS
select pdb.defined_balance_id
  from pay_balance_types pbt
      ,pay_balance_dimensions pbd
      ,pay_defined_balances pdb
 where balance_name             = p_salary_balance_name
   and pbd.dimension_name       = c_dim_name
   and pdb.balance_type_id      = pbt.balance_type_id
   and pbd.balance_dimension_id = pdb.balance_dimension_id
   and pbd.legislation_code = 'NL';

-- Cursor to get the time_period
CURSOR c_per_time_cur (c_payroll_id     IN NUMBER
                      ,c_effective_date IN DATE) IS
SELECT time_period_id
      ,start_date
      ,end_date
  FROM per_time_periods
 WHERE payroll_id = c_payroll_id
   AND trunc(start_date) >= c_effective_date
 ORDER BY start_date;

-- Cursor to get the payroll_id as of a particular date
CURSOR c_payroll_cur (c_effective_date IN DATE ) IS
SELECT payroll_id
  FROM per_all_assignments_f
 WHERE assignment_id = p_assignment_id
   AND trunc(c_effective_date) BETWEEN effective_start_date
                                   AND effective_end_date;

-- Cursor to check if a payroll has already been run
CURSOR c_get_asg_act_cur (c_time_period_id IN NUMBER
                         --,c_payroll_id     IN NUMBER
                         ,c_period_start   IN DATE
                         ,c_period_end     IN DATE) IS
SELECT paa.assignment_action_id
  FROM pay_payroll_actions ppa
      ,pay_assignment_actions paa
 where ppa.payroll_action_id = paa.payroll_action_id
   and ppa.time_period_id = c_time_period_id
   --and payroll_id = c_payroll_id
   and paa.assignment_id = p_assignment_id
   and ppa.action_type in ('R','Q')
   and ppa.action_status = 'C'
   and paa.action_status = 'C'
   and ppa.date_earned between c_period_start and c_period_end
   and rownum = 1;

--Cursor to check if the pension type is an ABP Pension Type
CURSOR c_is_abp_pt IS
SELECT 1
  FROM pqp_pension_types_f
WHERE  pension_type_id           = p_pension_type_id
  AND  special_pension_type_code = 'ABP';

BEGIN

hr_utility.set_location('Entering : '||l_proc_name, 10);

l_date_earned :=  p_date_earned;

--check if the pension type is an ABP Pension Type
-- if so, find the participation start date
IF p_pension_type_id <> -99 THEN
  OPEN c_is_abp_pt;
  FETCH c_is_abp_pt INTO l_is_abp_pt;
  IF c_is_abp_pt%FOUND THEN
     CLOSE c_is_abp_pt;
  ELSE
     l_is_abp_pt := 0;
     CLOSE c_is_abp_pt;
  END IF;
END IF;
-- if an invalid PT ID has been passed down, error out
IF p_pension_type_id = -1 THEN
  p_error_message := p_error_message||'Error occurred while fetching the pension salary';
  p_error_message := p_error_message||'cannot find a value for the pension type id';
  RETURN 1;
END IF;

-- if the pension type is an ABP PT, find the participation start date
-- from the ASG/ORG EITs
IF l_is_abp_pt = 1 THEN
   l_dimension_name := 'Assignment Year To Date';
   l_ret_val := PQP_NL_ABP_FUNCTIONS.get_participation_date
                                    (p_assignment_id      => p_assignment_id
                                    ,p_date_earned        => p_date_earned
                                    ,p_business_group_id  => p_business_group_id
                                    ,p_pension_type_id    => p_pension_type_id
                                    ,p_start_date         => l_participation_st_dt
                                    );
   IF l_ret_val = 1 THEN
      p_error_message := p_error_message||'Error occurred while trying to find the participation';
      p_error_message := p_error_message||' start date for the assignment';
      RETURN 1;
   END IF;
END IF;

l_run_year := get_run_year (l_date_earned
                           ,l_error_message );

--
-- Get the date for 1 JAN of the run year
--
l_begin_of_year_date := TO_DATE('01/01/'||to_char(l_run_year),'DD/MM/YYYY');

--
-- Get the current payroll_id for the person
--
SELECT payroll_id
  INTO l_payroll_id
  FROM per_all_assignments_f
 WHERE assignment_id = p_assignment_id
   AND trunc(p_date_earned) BETWEEN effective_start_date
                                AND effective_end_date;

hr_utility.set_location('Fetched l_cur_payroll_id : '||to_char(l_cur_payroll_id),20);

--
-- Get the hire date
--
OPEN c_hire_dt_cur (p_assignment_id);
   FETCH c_hire_dt_cur INTO l_hire_date;
    IF c_hire_dt_cur%FOUND THEN
         CLOSE c_hire_dt_cur;

      IF l_is_abp_pt = 0 THEN
         -- NON-ABP Pension Types
         -- The effective date is now the valid assignment start date
         l_effective_date := PQP_NL_ABP_FUNCTIONS.GET_VALID_START_DATE(p_assignment_id,p_date_earned,l_error_status,l_error_message);
         IF (l_error_status = trim(to_char(1,'9'))) Then
          fnd_message.set_name('PQP',l_error_message);
          p_error_message :='Error' || fnd_message.get();
          RETURN 0;
         End IF;
      ELSE
         -- ABP Pension Types
         -- The effective date is now the greatest of 1 Jan of the year
         -- the hire date and the participation start date
         l_effective_date := GREATEST(l_begin_of_year_date,l_hire_date,l_participation_st_dt);
      END IF;

      hr_utility.set_location('Fetched l_effective_date : '
                              ||to_char(l_effective_date),30);

     -- For the payroll id derived from above, get the time_period_id,
     -- start and end dates for the period which has the start_date
     -- greater than or equal to l_effective_date
   ELSE
      CLOSE c_hire_dt_cur;
      p_error_message := 'Error: Unable to find the hire date for the person ';
      RETURN 0;
   END IF; -- Hire date found

FOR temp_rec IN c_per_time_cur (l_payroll_id,l_effective_date)
   LOOP
   hr_utility.set_location('Fetched l_time_period_id : '
                          ||to_char(l_time_period_id),50);

   -- Check if there is a completed payroll run for the time
   -- period, payroll and assignment combination.
   -- If a payroll run is complete then get the balance using that
   -- assignment_action_id
   OPEN c_get_asg_act_cur (temp_rec.time_period_id
                          ,temp_rec.start_date
                          ,temp_rec.end_date );
   FETCH c_get_asg_act_cur INTO l_ass_act_id;

   IF c_get_asg_act_cur%FOUND THEN
      CLOSE c_get_asg_act_cur;
      EXIT;
   END IF;

   CLOSE c_get_asg_act_cur;

   END LOOP;

--
-- If a valid assignment action id was found then call the get_balance_pkg
-- else return 2 so that the formula will get the current value of the
-- balance.
--
IF l_ass_act_id = -1 THEN
   RETURN 2;
ELSE
   OPEN c_def_bal_cur(l_dimension_name);
      FETCH c_def_bal_cur INTO l_defined_bal_id;
         IF c_def_bal_cur%FOUND THEN
            -- Get the value of the balance as of the date calculated above.
            p_salary_balance_value :=
            pay_balance_pkg.get_value(p_defined_balance_id  => l_defined_bal_id
                                     ,p_assignment_action_id => l_ass_act_id);
            CLOSE c_def_bal_cur;
            RETURN 0;
         ELSE
            p_error_message := 'Error: Unable to find the defined balance';
            p_error_message := p_error_message||' Balance Name: '||p_salary_balance_name ;
            p_error_message := p_error_message||' Dimension Name: Assignment Period To Date';
            p_error_message := p_error_message||' Please make sure that balance and dimension exist';
            CLOSE c_def_bal_cur;
            RETURN 1;
         END IF;
END IF;

END get_pension_salary;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_pension_type_eligibility >-------------------|
-- ----------------------------------------------------------------------------
--

function get_pension_type_eligibility
  (p_business_group_id     IN NUMBER
  ,p_date_earned           IN DATE
  ,p_assignment_id         IN NUMBER
  ,p_pension_type_id       IN NUMBER
  ,p_eligibility_flag      OUT NOCOPY VARCHAR2
  ,p_error_message         OUT NOCOPY VARCHAR2
  ) return NUMBER IS

--Cursor to find the org id from the assignment id
CURSOR c_find_org_id IS
SELECT organization_id
  FROM per_all_assignments_f
WHERE assignment_id = p_assignment_id
  AND trunc(p_date_earned) between effective_start_date and effective_end_date
  AND business_group_id = p_business_group_id;

--Cursor to chk if the organization has any overridden pension types attached
CURSOR c_is_any_pt_assigned(c_org_id in number) IS
select 1 from dual
where exists (select 1 from hr_organization_information
              where org_information_context = 'PQP_NL_ER_PENSION_TYPES'
              AND organization_id = c_org_id
              AND p_date_earned between fnd_date.canonical_to_date(org_information4)
                  and fnd_date.canonical_to_date(nvl(org_information5,
                                                  fnd_date.date_to_canonical(hr_api.g_eot)))
              );

--Cursor to find the parent id from the org id
CURSOR c_find_parent_id(c_org_id in number
                       ,c_version_id in number) IS
select organization_id_parent
  from per_org_structure_elements
  where organization_id_child = c_org_id
    AND org_structure_version_id = c_version_id
    AND business_group_id = p_business_group_id;

--Cursor to find if the pension type is assigned to this org
CURSOR  c_is_pen_type_assigned(c_org_id in number) Is
SELECT 1
  FROM hr_organization_information hoi,
       pqp_pension_types_f pty
 WHERE hoi.org_information_context = 'PQP_NL_ER_PENSION_TYPES'
   AND hoi.org_information2      = TO_CHAR(p_pension_type_id)
   AND hoi.organization_id       = c_org_id
   AND pty.pension_type_id       = p_pension_type_id
   AND p_date_earned between pty.effective_start_date
                         and pty.effective_end_date
   AND p_date_earned between fnd_date.canonical_to_date(hoi.org_information4)
                         and fnd_date.canonical_to_date(nvl(hoi.org_information5,
                                                           fnd_date.date_to_canonical(hr_api.g_eot))
                                                        );
--Cursor to find the pension type name from the pension type id
CURSOR c_find_pen_type_name Is
SELECT pension_type_name
  FROM pqp_pension_types_f
 WHERE pension_type_id = p_pension_type_id
  AND rownum = 1;

--Cursor to find if the pension type is valid as of the date earned
CURSOR c_find_pen_type_valid Is
SELECT 1
  FROM pqp_pension_types_f
 WHERE pension_type_id = p_pension_type_id
  AND trunc(p_date_earned) between effective_start_date and effective_end_date
  AND business_group_id = p_business_group_id;

--Cursor to find the named hierarchy associated with the BG
CURSOR c_find_named_hierarchy Is
select org_information1
 from hr_organization_information
where organization_id = p_business_group_id
 and org_information_context = 'NL_BG_INFO';

--Cursor to find the valid version id for the particular named hierarchy
CURSOR c_find_ver_frm_hierarchy(c_hierarchy_id in Number) Is
select ORG_STRUCTURE_VERSION_ID
  from per_org_structure_versions_v
where organization_structure_id = c_hierarchy_id
  and p_date_earned between date_from
  and nvl(date_to,hr_api.g_eot);

--Cursor to find the valid version id for a particular business group
CURSOR c_find_ver_frm_bg Is
select ORG_STRUCTURE_VERSION_ID
  from per_org_structure_versions_v
where business_group_id = p_business_group_id
  and p_date_earned between date_from
  and nvl( date_to,hr_api.g_eot);


l_org_id                NUMBER;
l_ret_value             NUMBER;
l_is_pen_type_assigned  NUMBER;
l_loop_again            NUMBER;
l_valid_pt              NUMBER;
l_named_hierarchy       NUMBER;
l_version_id            NUMBER  default null;
l_pen_type_name         VARCHAR2(240);

BEGIN
  --Find the pension type name from the pension type id
  OPEN c_find_pen_type_name;
  FETCH c_find_pen_type_name INTO l_pen_type_name;
     IF c_find_pen_type_name%NOTFOUND THEN
        p_error_message := 'Unable to find the details for the Pension Type';
        p_error_message := p_error_message||'. Pension Type Id = '||to_char(p_pension_type_id);
        CLOSE c_find_pen_type_name;
        return 1;
     END IF;
  CLOSE c_find_pen_type_name;

  --
  -- Make sure that the pension Type is valid as of the date earned
  --
  OPEN c_find_pen_type_valid;
  FETCH c_find_pen_type_valid INTO l_valid_pt;
     IF c_find_pen_type_valid%NOTFOUND THEN
        p_error_message := 'Pension Type : '||l_pen_type_name;
        p_error_message:= p_error_message||' is not valid as of '||to_char(p_date_earned);
        p_error_message := p_error_message||' Please check the validity of the Pension Type.';
        CLOSE c_find_pen_type_valid;
        return 1;
     END IF;
  CLOSE c_find_pen_type_valid;

  --
  --Find the valid org hierarchy version on a particular date
  --

  --first chk to see if a named hierarchy exists for the BG
  OPEN c_find_named_hierarchy;
  FETCH c_find_named_hierarchy INTO l_named_hierarchy;
     -- if a named hiearchy is found , find the valid version on that date
     IF c_find_named_hierarchy%FOUND THEN
        CLOSE c_find_named_hierarchy;
        -- now find the valid version on that date
        OPEN c_find_ver_frm_hierarchy(l_named_hierarchy);
        FETCH c_find_ver_frm_hierarchy INTO l_version_id;
          --if no valid version is found, try to get it frm the BG
          IF c_find_ver_frm_hierarchy%NOTFOUND THEN
             CLOSE c_find_ver_frm_hierarchy;
             -- find the valid version id from the BG
             OPEN c_find_ver_frm_bg;
             FETCH c_find_ver_frm_bg INTO l_version_id;
             CLOSE c_find_ver_frm_bg;
          -- else a valid version has been found for the named hierarchy
          ELSE
             CLOSE c_find_ver_frm_hierarchy;
          END IF;
     -- else find the valid version from BG
     ELSE
          CLOSE c_find_named_hierarchy;
          --now find the version number from the BG
          OPEN c_find_ver_frm_bg;
          FETCH c_find_ver_frm_bg INTO l_version_id;
          CLOSE c_find_ver_frm_bg;
     END IF;
  OPEN c_find_org_id;
  FETCH c_find_org_id INTO l_org_id;
  IF c_find_org_id%FOUND THEN -- if the org id to which this person is in is found

    CLOSE c_find_org_id;
    l_loop_again := 1;
    -- while the topmost org is not reached or while the pension type is not attached to any parent org
    while (l_loop_again = 1) loop

      -- first chk to see if there exist any overridden rows effective the date earned
      OPEN c_is_any_pt_assigned(l_org_id);
      FETCH c_is_any_pt_assigned INTO l_is_pen_type_assigned;
      -- if overridden rows exist
      IF c_is_any_pt_assigned%FOUND THEN

        CLOSE c_is_any_pt_assigned;
        -- chk to see if the pension type is attached to this org and the pension type is valid on this date
        OPEN c_is_pen_type_assigned(l_org_id);
        FETCH c_is_pen_type_assigned INTO l_is_pen_type_assigned;

        -- if the pension type is assigned to this org
        IF c_is_pen_type_assigned%FOUND THEN

          CLOSE c_is_pen_type_assigned;
          l_ret_value           :=    0;
          p_eligibility_flag    :=   'Y';
          l_loop_again          :=    0;

         ELSE -- The pension type entry is not found or not valid for thir org

          CLOSE c_is_pen_type_assigned;
          l_ret_value           :=    1;
          p_eligibility_flag    :=   'N';
          p_error_message       :=   'This person is not eligible for the pension type : '||l_pen_type_name;
          l_loop_again          :=    0;

         END IF;

     -- no overridden rows exist
     -- PTYPES havent been overridden so chk the parent org
     --this is done only if a valid org hierarchy version exists on this date
      ELSIF l_version_id IS NOT NULL THEN

         CLOSE c_is_any_pt_assigned;
         OPEN c_find_parent_id(l_org_id,l_version_id);
         FETCH c_find_parent_id INTO l_org_id;

         -- if the parent id is found
         IF c_find_parent_id%FOUND THEN

           CLOSE c_find_parent_id;

         -- if the org has no further parent
         ELSE
           CLOSE c_find_parent_id;
           l_ret_value           :=    1;
           p_eligibility_flag    :=   'N';
           p_error_message       :=   'This person is not eligible for this pension type : '||l_pen_type_name;
           l_loop_again          :=    0;

         END IF;

      ELSE
         -- no hierarchy has been found
         l_ret_value           :=    1;
         p_eligibility_flag    :=   'N';
         p_error_message       :=   'This person is not eligible for this pension type : '||l_pen_type_name;
         l_loop_again          :=    0;


       END IF;

   end loop;

  ELSE -- if the org is not found again raise an error
    CLOSE c_find_org_id;
    l_ret_value           :=    1;
    p_eligibility_flag    :=   'N';
    p_error_message       :=   'This person is not eligible for this pension type : '||l_pen_type_name;

  END IF;

--return the value of 1 or 0
RETURN l_ret_value;

END get_pension_type_eligibility;
--


-- ----------------------------------------------------------------------------
-- |-----------------------< get_pension_threshold_ratio >-------------------|
-- ----------------------------------------------------------------------------
--

function get_pension_threshold_ratio
  (p_date_earned           IN DATE
  ,p_assignment_id         IN NUMBER
  ,p_business_group_id     IN NUMBER
  ,p_assignment_action_id  IN NUMBER
  ) return NUMBER IS

--cursor to find the person id for the current assignment id
cursor c_get_person_id IS
select person_id from per_all_assignments_f
where assignment_id = p_assignment_id
and p_date_earned between effective_start_date and effective_end_date
and business_group_id = p_business_group_id;

--cursor to find all the assigment ids for a particular person id
cursor c_get_all_assignmentid(c_person_id in number) IS
select assignment_id
  from per_all_assignments_f asg
  where asg.person_id = c_person_id
  and asg.assignment_status_type_id in (select assignment_status_type_id from PER_ASS_STATUS_TYPE_AMENDS
   where business_group_id = p_business_group_id and pay_system_status = 'P' and active_flag = 'Y'
   union
   select assignment_status_type_id from per_assignment_status_types typ
   where  typ.pay_system_status = 'P'
  and typ.active_flag = 'Y'
  and (   (typ.legislation_code is null and typ.business_group_id is null)
       OR (typ.legislation_code is null and
          (typ.business_group_id is not null and typ.business_group_id = p_business_group_id))
       OR (typ.legislation_code ='NL')
      ))
  and p_date_earned between asg.effective_start_date and asg.effective_end_date;

  --Cursor to derive the part time percetage value
  CURSOR c_get_fte(c_assignment_id IN per_all_assignments_f.assignment_id%TYPE) IS
  SELECT fnd_number.canonical_to_number(NVL(target.SEGMENT29,'100'))
    FROM hr_soft_coding_keyflex target,
         per_all_assignments_f ASSIGN
  WHERE p_date_earned BETWEEN ASSIGN.effective_start_date AND
                              ASSIGN.effective_end_date
     AND ASSIGN.assignment_id = c_assignment_id
     AND target.soft_coding_keyflex_id = ASSIGN.soft_coding_keyflex_id
     AND target.enabled_flag = 'Y';

l_assignment_id NUMBER;
l_fte           NUMBER;
l_sum_fte       NUMBER := 0;
l_ratio         NUMBER := 1;
l_person_id     NUMBER;

begin

   hr_utility.set_location('Entering the function get_pension_threshold_ratio',10);
   open c_get_person_id;

   fetch c_get_person_id into l_person_id;

   hr_utility.set_location('got person id '||l_person_id,20);

   if c_get_person_id%NOTFOUND THEN

      close c_get_person_id;
      fnd_message.set_name('PQP','PQP_NO_PERSON');


      fnd_message.raise_error;

   else

   hr_utility.set_location('get all assignment ids ',30);

     close c_get_person_id;
     open c_get_all_assignmentid(c_person_id => l_person_id);

     -- loop through all the assignments of the person
      loop

         fetch c_get_all_assignmentid into l_assignment_id;
         exit when c_get_all_assignmentid%NOTFOUND;

         --
         -- Call function to check if the user has overridden the part
         -- time percentage . If a value is found , use this to derive the
         -- FTE
         --
         l_fte := pay_nl_si_pkg.get_part_time_perc( l_assignment_id
                                                   ,p_date_earned
                                                   ,p_business_group_id
                                                   ,p_assignment_action_id);

         IF l_fte IS NULL THEN
            -- Derive the value normally from the SCL Flex
            OPEN c_get_fte(c_assignment_id => l_assignment_id);
               FETCH c_get_fte INTO l_fte;
            CLOSE c_get_fte;
         END IF;

     hr_utility.set_location('got fte value '||l_fte||'for assignment'||l_assignment_id,40);

         -- sum the FTEs of each of the assignments
         l_sum_fte := l_sum_fte + nvl(l_fte,100);

      end loop;

      close c_get_all_assignmentid;

     hr_utility.set_location('got sum of ftes'||l_sum_fte,50);

     --
     -- Call function to check if the user has overridden the part
     -- time percentage . If a value is found , use this to derive the
     -- FTE
     --
     l_fte := pay_nl_si_pkg.get_part_time_perc( p_assignment_id
                                               ,p_date_earned
                                               ,p_business_group_id
                                               ,p_assignment_action_id);

     IF l_fte IS NULL THEN
        -- Derive the value normally from the SCL Flex
        OPEN c_get_fte(c_assignment_id => p_assignment_id);
          FETCH c_get_fte INTO l_fte;
        CLOSE c_get_fte;
     END IF;

     l_fte := nvl(l_fte,100);

      if not l_sum_fte = 0 THEN

         l_ratio := l_fte/l_sum_fte;

     hr_utility.set_location('got ratio'||l_ratio,60);

      end if;
   end if;

   hr_utility.set_location('leaving the function get_pension_threshold_ratio',70);

return l_ratio;

end get_pension_threshold_ratio;

-- ----------------------------------------------------------------------------
-- |---------------------------< sort_table >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE sort_table ( p_table_to_sort  IN OUT NOCOPY t_tax_si_tbl
                      ) IS

l_temp_tbl t_tax_si_tbl;
i          NUMBER ;
j          NUMBER ;
l_add_row  NUMBER;
l_counter  NUMBER := 0;

BEGIN

FOR i IN 1..p_table_to_sort.count - 1
 LOOP
  FOR j IN i+1..p_table_to_sort.count
   LOOP
     IF p_table_to_sort(i).reduction_order >=
        p_table_to_sort(j).reduction_order THEN
           l_temp_tbl(i)     := p_table_to_sort(i);
           p_table_to_sort(i):= p_table_to_sort(j);
           p_table_to_sort(j):= l_temp_tbl(i);
     END IF;
   END LOOP;
 END LOOP;

END sort_table;

-- ----------------------------------------------------------------------------
-- |----------------------< gen_dynamic_formula >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE gen_dynamic_formula ( p_pension_type_id  IN  NUMBER
                               ,p_effective_date   IN  DATE
                               ,p_formula_string   OUT NOCOPY varchar2
                             ) IS

l_tax_bal_tbl        t_tax_si_tbl;
l_si_incm_bal_tbl    t_tax_si_tbl;
l_si_gross_sal_tbl   t_tax_si_tbl;
l_formula_string     varchar2(32000) := ' ';
l_tax_si_red_str     varchar2(10);
l_counter            number := 1;
l_tax_tbl_indx       number := 1;
l_sig_tbl_indx       number := 1;
l_sii_tbl_indx       number := 1;

-- Single Balance
l_single_bal_string varchar2(1000) :=
'

IF dedn_amt <= l_bal_one THEN
    l_feed_one = dedn_amt
ELSE IF dedn_amt > l_bal_one THEN
  (
    l_feed_one = l_bal_one
  )

   ';

-- Two Balances
l_two_bal_string varchar2(1000) :=
'

IF dedn_amt <= l_bal_one THEN
    l_feed_one = dedn_amt
ELSE IF dedn_amt > l_bal_one THEN
  (
    l_feed_one = l_bal_one
    dedn_amt_temp = dedn_amt - l_feed_one
    l_feed_two = LEAST(dedn_amt_temp,l_bal_two)
  )

  ';

-- Three Balances
l_three_bal_string varchar2(1000) :=
'

IF dedn_amt <= l_bal_one  THEN
  (
    l_feed_one = dedn_amt
  )
ELSE IF dedn_amt > l_bal_one THEN
  (
    l_feed_one = l_bal_one
    dedn_amt_temp = dedn_amt - l_feed_one
    IF dedn_amt_temp <= l_bal_two THEN
      (
        l_feed_two = dedn_amt_temp
      )
    ELSE IF dedn_amt_temp > l_bal_two THEN
     (
       l_feed_two = l_bal_two
       dedn_amt_temp = dedn_amt_temp - l_feed_two
       l_feed_three = LEAST(dedn_amt_temp,l_bal_three)
     )
  )

  ';

CURSOR c_tax_si_cur IS
SELECT nvl(STD_TAX_REDUCTION,'0')||
       nvl(SPL_TAX_REDUCTION,'0')||
       nvl(SIG_SAL_SPL_TAX_REDUCTION,'0')||
       nvl(SIG_SAL_NON_TAX_REDUCTION,'0')||
       nvl(SIG_SAL_STD_TAX_REDUCTION,'0')||
       nvl(SII_STD_TAX_REDUCTION,'0')||
       nvl(SII_SPL_TAX_REDUCTION,'0')||
       nvl(SII_NON_TAX_REDUCTION,'0') redstr
  FROM pqp_pension_types_f
 WHERE pension_type_id = p_pension_type_id
   AND trunc(p_effective_date) BETWEEN
       trunc(effective_start_date)
       AND trunc(effective_end_date);

BEGIN
    hr_utility.set_location('Entering gen_dynamic_formula',10);
    FOR temp_rec IN c_tax_si_cur
       LOOP
          l_tax_si_red_str := temp_rec.redstr;
       END LOOP;
      IF substr(l_tax_si_red_str,1,1) <> '0' THEN
      l_tax_bal_tbl(l_tax_tbl_indx).tax_si_code := 'STD_TAX';
      l_tax_bal_tbl(l_tax_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,1,1));
      l_tax_tbl_indx := l_tax_tbl_indx+1;
   END IF;

   IF substr(l_tax_si_red_str,2,1) <> '0' THEN
      l_tax_bal_tbl(l_tax_tbl_indx).tax_si_code := 'SPL_TAX';
      l_tax_bal_tbl(l_tax_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,2,1));
      l_tax_tbl_indx := l_tax_tbl_indx+1;
   END IF;

   IF substr(l_tax_si_red_str,3,1) <> '0' THEN
      l_si_gross_sal_tbl(l_sig_tbl_indx).tax_si_code := 'SIG_SPL';
      l_si_gross_sal_tbl(l_sig_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,3,1));
      l_sig_tbl_indx := l_sig_tbl_indx+1;
   END IF;

   IF substr(l_tax_si_red_str,4,1) <> '0' THEN
      l_si_gross_sal_tbl(l_sig_tbl_indx).tax_si_code := 'SIG_NON';
      l_si_gross_sal_tbl(l_sig_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,4,1));
      l_sig_tbl_indx := l_sig_tbl_indx+1;
   END IF;

   IF substr(l_tax_si_red_str,5,1) <> '0' THEN
      l_si_gross_sal_tbl(l_sig_tbl_indx).tax_si_code := 'SIG_STD';
      l_si_gross_sal_tbl(l_sig_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,5,1));
      l_sig_tbl_indx := l_sig_tbl_indx+1;
   END IF;

   IF substr(l_tax_si_red_str,6,1) <> '0' THEN
      l_si_incm_bal_tbl(l_sii_tbl_indx).tax_si_code := 'SII_STD';
      l_si_incm_bal_tbl(l_sii_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,6,1));
      l_sii_tbl_indx := l_sii_tbl_indx+1;
   END IF;

   IF substr(l_tax_si_red_str,7,1) <> '0' THEN
      l_si_incm_bal_tbl(l_sii_tbl_indx).tax_si_code := 'SII_SPL';
      l_si_incm_bal_tbl(l_sii_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,7,1));
      l_sii_tbl_indx := l_sii_tbl_indx+1;
   END IF;

   IF substr(l_tax_si_red_str,8,1) <> '0' THEN
      l_si_incm_bal_tbl(l_sii_tbl_indx).tax_si_code := 'SII_NON';
      l_si_incm_bal_tbl(l_sii_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,8,1));
      l_sii_tbl_indx := l_sii_tbl_indx+1;
   END IF;

   hr_utility.set_location('Calling sort on all 3 tables',20);
   sort_table(l_tax_bal_tbl);
   sort_table(l_si_gross_sal_tbl);
   sort_table(l_si_incm_bal_tbl);


   IF l_tax_bal_tbl.count > 0 THEN

      hr_utility.set_location('Taxation balances exist in the reduction',30);
      IF l_tax_bal_tbl.count = 1 THEN
         l_formula_string := l_single_bal_string;
      ELSIF  l_tax_bal_tbl.count = 2 THEN
         l_formula_string := l_two_bal_string;
      END IF;
      WHILE l_counter <= 2
        LOOP
           IF l_tax_bal_tbl.EXISTS(l_counter) THEN
              IF l_tax_bal_tbl(l_counter).tax_si_code = 'STD_TAX' THEN
                 IF l_counter = 1 THEN
                    l_formula_string := replace(l_formula_string,'l_bal_one',
                                'l_std_tax_bal');
                    l_formula_string := replace(l_formula_string,'l_feed_one',
                                'feed_to_std_tax');
                 ELSIF l_counter = 2 THEN
                    l_formula_string := replace(l_formula_string,'l_bal_two',
                                'l_std_tax_bal');
                    l_formula_string := replace(l_formula_string,'l_feed_two',
                                'feed_to_std_tax');
                 END IF;

              ELSIF l_tax_bal_tbl(l_counter).tax_si_code = 'SPL_TAX' THEN
                 IF l_counter = 1 THEN
                    l_formula_string := replace(l_formula_string,'l_bal_one',
                                'l_spl_tax_bal');
                    l_formula_string := replace(l_formula_string,'l_feed_one',
                                'feed_to_spl_tax');
                 ELSIF l_counter = 2 THEN
                    l_formula_string := replace(l_formula_string,'l_bal_two',
                                'l_spl_tax_bal');
                    l_formula_string := replace(l_formula_string,'l_feed_two',
                                'feed_to_spl_tax');
                 END IF;

              END IF;
           END IF;
           l_counter := l_counter + 1;
        END LOOP;
     END IF;
   l_counter := 1;

   IF l_si_incm_bal_tbl.count > 0 THEN

      hr_utility.set_location('SI Income balances exist in the reduction',40);
      IF l_si_incm_bal_tbl.count = 1 THEN
         l_formula_string := l_formula_string||l_single_bal_string;
      ELSIF  l_si_incm_bal_tbl.count = 2 THEN
         l_formula_string := l_formula_string||l_two_bal_string;
      ELSIF  l_si_incm_bal_tbl.count = 3 THEN
         l_formula_string := l_formula_string||l_three_bal_string;
      END IF;

      WHILE l_counter <= 3
        LOOP
        IF l_si_incm_bal_tbl.EXISTS(l_counter) THEN
           IF l_si_incm_bal_tbl(l_counter).tax_si_code = 'SII_STD' THEN
              IF l_counter = 1 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_one',
                             'l_sii_std_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_one',
                             'feed_to_si_incm_std_tax');
              ELSIF l_counter = 2 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_two',
                             'l_sii_std_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_two',
                             'feed_to_si_incm_std_tax');
              ELSIF l_counter = 3 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_three',
                             'l_sii_std_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_three',
                             'feed_to_si_incm_std_tax');
              END IF;

           ELSIF l_si_incm_bal_tbl(l_counter).tax_si_code = 'SII_SPL' THEN
              IF l_counter = 1 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_one',
                             'l_sii_spl_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_one',
                             'feed_to_si_incm_spl_tax');
              ELSIF l_counter = 2 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_two',
                             'l_sii_spl_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_two',
                             'feed_to_si_incm_spl_tax');
              ELSIF l_counter = 3 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_three',
                             'l_sii_spl_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_three',
                             'feed_to_si_incm_spl_tax');
              END IF;
           ELSIF l_si_incm_bal_tbl(l_counter).tax_si_code = 'SII_NON' THEN
              IF l_counter = 1 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_one',
                             'l_sii_non_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_one',
                             'feed_to_si_incm_non_tax');
              ELSIF l_counter = 2 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_two',
                             'l_sii_non_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_two',
                             'feed_to_si_incm_non_tax');
              ELSIF l_counter = 3 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_three',
                             'l_sii_non_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_three',
                             'feed_to_si_incm_non_tax');
              END IF;

           END IF;
        END IF;
        l_counter := l_counter + 1;
     END LOOP;

   END IF;

   l_counter := 1;

   IF l_si_gross_sal_tbl.count > 0 THEN

      hr_utility.set_location('SI Gross Salary balances exist in the reduction',50);
      IF l_si_gross_sal_tbl.count = 1 THEN
         l_formula_string := l_formula_string||l_single_bal_string;
      ELSIF  l_si_gross_sal_tbl.count = 2 THEN
         l_formula_string := l_formula_string||l_two_bal_string;
      ELSIF  l_si_gross_sal_tbl.count = 3 THEN
         l_formula_string := l_formula_string||l_three_bal_string;
      END IF;

      WHILE l_counter <= 3
        LOOP
        IF l_si_gross_sal_tbl.EXISTS(l_counter) THEN
           IF l_si_gross_sal_tbl(l_counter).tax_si_code = 'SIG_STD' THEN
              IF l_counter = 1 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_one',
                             'l_sig_std_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_one',
                             'feed_to_si_gr_sal_std_tax');
              ELSIF l_counter = 2 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_two',
                             'l_sig_std_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_two',
                             'feed_to_si_gr_sal_std_tax');
              ELSIF l_counter = 3 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_three',
                             'l_sig_std_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_three',
                             'feed_to_si_gr_sal_std_tax');
              END IF;

           ELSIF l_si_gross_sal_tbl(l_counter).tax_si_code = 'SIG_SPL' THEN
              IF l_counter = 1 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_one',
                             'l_sig_spl_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_one',
                             'feed_to_si_gr_sal_spl_tax');
              ELSIF l_counter = 2 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_two',
                             'l_sig_spl_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_two',
                             'feed_to_si_gr_sal_spl_tax');
              ELSIF l_counter = 3 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_three',
                             'l_sig_spl_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_three',
                             'feed_to_si_gr_sal_spl_tax');
              END IF;
           ELSIF l_si_gross_sal_tbl(l_counter).tax_si_code = 'SIG_NON' THEN
              IF l_counter = 1 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_one',
                             'l_sig_non_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_one',
                             'feed_to_si_gr_sal_non_tax');
              ELSIF l_counter = 2 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_two',
                             'l_sig_non_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_two',
                             'feed_to_si_gr_sal_non_tax');
              ELSIF l_counter = 3 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_three',
                             'l_sig_non_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_three',
                             'feed_to_si_gr_sal_non_tax');
              END IF;

           END IF;
        END IF;
        l_counter := l_counter + 1;
     END LOOP;

   END IF;
   p_formula_string := l_formula_string;
   hr_utility.set_location('Leaving gen_dynamic_formula',50);

END gen_dynamic_formula;

-- ----------------------------------------------------------------------------
-- |--------------------< gen_dynamic_sav_formula >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE gen_dynamic_sav_formula ( p_pension_type_id  IN  NUMBER
                                   ,p_effective_date   IN  DATE
                                   ,p_formula_string   OUT NOCOPY varchar2
                                  ) IS

l_tax_bal_tbl        t_tax_si_tbl;
l_si_incm_bal_tbl    t_tax_si_tbl;
l_si_gross_sal_tbl   t_tax_si_tbl;
l_formula_string     varchar2(32000) := ' ';
l_tax_si_red_str     varchar2(10);
l_counter            number := 1;
l_tax_tbl_indx       number := 1;
l_sig_tbl_indx       number := 1;
l_sii_tbl_indx       number := 1;

-- Single Balance
l_single_bal_string varchar2(1000) :=
'

IF dedn_amt <= (l_bal_one - l_feed_one) THEN
    l_feed_one = l_feed_one + dedn_amt
ELSE IF dedn_amt > (l_bal_one - l_feed_one) THEN
  (
    l_feed_one = l_feed_one + (l_bal_one - l_feed_one)
  )

   ';

-- Two Balances
l_two_bal_string varchar2(1000) :=
'

IF dedn_amt <= (l_bal_one - l_feed_one) THEN
    l_feed_one = l_feed_one + dedn_amt
ELSE IF dedn_amt > (l_bal_one - l_feed_one) THEN
  (
    dedn_amt_temp = dedn_amt - (l_bal_one - l_feed_one)
    l_feed_one = l_feed_one + (l_bal_one - l_feed_one)
    l_feed_two = l_feed_two + LEAST(dedn_amt_temp,(l_bal_two - l_feed_two))
  )

  ';

-- Three Balances
l_three_bal_string varchar2(1000) :=
'

IF dedn_amt <= (l_bal_one - l_feed_one)  THEN
  (
    l_feed_one = l_feed_one + dedn_amt
  )
ELSE IF dedn_amt > (l_bal_one - l_feed_one) THEN
  (
    dedn_amt_temp = dedn_amt - (l_bal_one - l_feed_one)
    l_feed_one = l_feed_one + (l_bal_one - l_feed_one)
    IF dedn_amt_temp <= (l_bal_two - l_feed_two) THEN
      (
        l_feed_two = l_feed_two + dedn_amt_temp
      )
    ELSE IF dedn_amt_temp > (l_bal_two - l_feed_two) THEN
     (
       dedn_amt_temp = dedn_amt_temp - (l_bal_two - l_feed_two)
       l_feed_two = l_feed_two + (l_bal_two - l_feed_two)
       l_feed_three = l_feed_three + LEAST(dedn_amt_temp,(l_bal_three - l_feed_three))
     )
  )

  ';

CURSOR c_tax_si_cur IS
SELECT nvl(STD_TAX_REDUCTION,'0')||
       nvl(SPL_TAX_REDUCTION,'0')||
       nvl(SIG_SAL_SPL_TAX_REDUCTION,'0')||
       nvl(SIG_SAL_NON_TAX_REDUCTION,'0')||
       nvl(SIG_SAL_STD_TAX_REDUCTION,'0')||
       nvl(SII_STD_TAX_REDUCTION,'0')||
       nvl(SII_SPL_TAX_REDUCTION,'0')||
       nvl(SII_NON_TAX_REDUCTION,'0') redstr
  FROM pqp_pension_types_f
 WHERE pension_type_id = p_pension_type_id
   AND trunc(p_effective_date) BETWEEN
       trunc(effective_start_date)
       AND trunc(effective_end_date);

BEGIN
    hr_utility.set_location('Entering gen_dynamic_formula',10);
    FOR temp_rec IN c_tax_si_cur
       LOOP
          l_tax_si_red_str := temp_rec.redstr;
       END LOOP;
      IF substr(l_tax_si_red_str,1,1) <> '0' THEN
      l_tax_bal_tbl(l_tax_tbl_indx).tax_si_code := 'STD_TAX';
      l_tax_bal_tbl(l_tax_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,1,1));
      l_tax_tbl_indx := l_tax_tbl_indx+1;
   END IF;

   IF substr(l_tax_si_red_str,2,1) <> '0' THEN
      l_tax_bal_tbl(l_tax_tbl_indx).tax_si_code := 'SPL_TAX';
      l_tax_bal_tbl(l_tax_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,2,1));
      l_tax_tbl_indx := l_tax_tbl_indx+1;
   END IF;

   IF substr(l_tax_si_red_str,3,1) <> '0' THEN
      l_si_gross_sal_tbl(l_sig_tbl_indx).tax_si_code := 'SIG_SPL';
      l_si_gross_sal_tbl(l_sig_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,3,1));
      l_sig_tbl_indx := l_sig_tbl_indx+1;
   END IF;

   IF substr(l_tax_si_red_str,4,1) <> '0' THEN
      l_si_gross_sal_tbl(l_sig_tbl_indx).tax_si_code := 'SIG_NON';
      l_si_gross_sal_tbl(l_sig_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,4,1));
      l_sig_tbl_indx := l_sig_tbl_indx+1;
   END IF;

   IF substr(l_tax_si_red_str,5,1) <> '0' THEN
      l_si_gross_sal_tbl(l_sig_tbl_indx).tax_si_code := 'SIG_STD';
      l_si_gross_sal_tbl(l_sig_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,5,1));
      l_sig_tbl_indx := l_sig_tbl_indx+1;
   END IF;

   IF substr(l_tax_si_red_str,6,1) <> '0' THEN
      l_si_incm_bal_tbl(l_sii_tbl_indx).tax_si_code := 'SII_STD';
      l_si_incm_bal_tbl(l_sii_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,6,1));
      l_sii_tbl_indx := l_sii_tbl_indx+1;
   END IF;

   IF substr(l_tax_si_red_str,7,1) <> '0' THEN
      l_si_incm_bal_tbl(l_sii_tbl_indx).tax_si_code := 'SII_SPL';
      l_si_incm_bal_tbl(l_sii_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,7,1));
      l_sii_tbl_indx := l_sii_tbl_indx+1;
   END IF;

   IF substr(l_tax_si_red_str,8,1) <> '0' THEN
      l_si_incm_bal_tbl(l_sii_tbl_indx).tax_si_code := 'SII_NON';
      l_si_incm_bal_tbl(l_sii_tbl_indx).reduction_order :=
         to_number(substr(l_tax_si_red_str,8,1));
      l_sii_tbl_indx := l_sii_tbl_indx+1;
   END IF;

   hr_utility.set_location('Calling sort on all 3 tables',20);
   sort_table(l_tax_bal_tbl);
   sort_table(l_si_gross_sal_tbl);
   sort_table(l_si_incm_bal_tbl);


   IF l_tax_bal_tbl.count > 0 THEN

      hr_utility.set_location('Taxation balances exist in the reduction',30);
      IF l_tax_bal_tbl.count = 1 THEN
         l_formula_string := l_single_bal_string;
      ELSIF  l_tax_bal_tbl.count = 2 THEN
         l_formula_string := l_two_bal_string;
      END IF;
      WHILE l_counter <= 2
        LOOP
           IF l_tax_bal_tbl.EXISTS(l_counter) THEN
              IF l_tax_bal_tbl(l_counter).tax_si_code = 'STD_TAX' THEN
                 IF l_counter = 1 THEN
                    l_formula_string := replace(l_formula_string,'l_bal_one',
                                'l_std_tax_bal');
                    l_formula_string := replace(l_formula_string,'l_feed_one',
                                'feed_to_std_tax');
                 ELSIF l_counter = 2 THEN
                    l_formula_string := replace(l_formula_string,'l_bal_two',
                                'l_std_tax_bal');
                    l_formula_string := replace(l_formula_string,'l_feed_two',
                                'feed_to_std_tax');
                 END IF;

              ELSIF l_tax_bal_tbl(l_counter).tax_si_code = 'SPL_TAX' THEN
                 IF l_counter = 1 THEN
                    l_formula_string := replace(l_formula_string,'l_bal_one',
                                'l_spl_tax_bal');
                    l_formula_string := replace(l_formula_string,'l_feed_one',
                                'feed_to_spl_tax');
                 ELSIF l_counter = 2 THEN
                    l_formula_string := replace(l_formula_string,'l_bal_two',
                                'l_spl_tax_bal');
                    l_formula_string := replace(l_formula_string,'l_feed_two',
                                'feed_to_spl_tax');
                 END IF;

              END IF;
           END IF;
           l_counter := l_counter + 1;
        END LOOP;
     END IF;
   l_counter := 1;

   IF l_si_incm_bal_tbl.count > 0 THEN

      hr_utility.set_location('SI Income balances exist in the reduction',40);
      IF l_si_incm_bal_tbl.count = 1 THEN
         l_formula_string := l_formula_string||l_single_bal_string;
      ELSIF  l_si_incm_bal_tbl.count = 2 THEN
         l_formula_string := l_formula_string||l_two_bal_string;
      ELSIF  l_si_incm_bal_tbl.count = 3 THEN
         l_formula_string := l_formula_string||l_three_bal_string;
      END IF;

      WHILE l_counter <= 3
        LOOP
        IF l_si_incm_bal_tbl.EXISTS(l_counter) THEN
           IF l_si_incm_bal_tbl(l_counter).tax_si_code = 'SII_STD' THEN
              IF l_counter = 1 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_one',
                             'l_sii_std_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_one',
                             'feed_to_si_incm_std_tax');
              ELSIF l_counter = 2 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_two',
                             'l_sii_std_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_two',
                             'feed_to_si_incm_std_tax');
              ELSIF l_counter = 3 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_three',
                             'l_sii_std_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_three',
                             'feed_to_si_incm_std_tax');
              END IF;

           ELSIF l_si_incm_bal_tbl(l_counter).tax_si_code = 'SII_SPL' THEN
              IF l_counter = 1 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_one',
                             'l_sii_spl_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_one',
                             'feed_to_si_incm_spl_tax');
              ELSIF l_counter = 2 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_two',
                             'l_sii_spl_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_two',
                             'feed_to_si_incm_spl_tax');
              ELSIF l_counter = 3 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_three',
                             'l_sii_spl_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_three',
                             'feed_to_si_incm_spl_tax');
              END IF;
           ELSIF l_si_incm_bal_tbl(l_counter).tax_si_code = 'SII_NON' THEN
              IF l_counter = 1 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_one',
                             'l_sii_non_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_one',
                             'feed_to_si_incm_non_tax');
              ELSIF l_counter = 2 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_two',
                             'l_sii_non_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_two',
                             'feed_to_si_incm_non_tax');
              ELSIF l_counter = 3 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_three',
                             'l_sii_non_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_three',
                             'feed_to_si_incm_non_tax');
              END IF;

           END IF;
        END IF;
        l_counter := l_counter + 1;
     END LOOP;

   END IF;

   l_counter := 1;

   IF l_si_gross_sal_tbl.count > 0 THEN

      hr_utility.set_location('SI Gross Salary balances exist in the reduction',50);
      IF l_si_gross_sal_tbl.count = 1 THEN
         l_formula_string := l_formula_string||l_single_bal_string;
      ELSIF  l_si_gross_sal_tbl.count = 2 THEN
         l_formula_string := l_formula_string||l_two_bal_string;
      ELSIF  l_si_gross_sal_tbl.count = 3 THEN
         l_formula_string := l_formula_string||l_three_bal_string;
      END IF;

      WHILE l_counter <= 3
        LOOP
        IF l_si_gross_sal_tbl.EXISTS(l_counter) THEN
           IF l_si_gross_sal_tbl(l_counter).tax_si_code = 'SIG_STD' THEN
              IF l_counter = 1 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_one',
                             'l_sig_std_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_one',
                             'feed_to_si_gr_sal_std_tax');
              ELSIF l_counter = 2 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_two',
                             'l_sig_std_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_two',
                             'feed_to_si_gr_sal_std_tax');
              ELSIF l_counter = 3 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_three',
                             'l_sig_std_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_three',
                             'feed_to_si_gr_sal_std_tax');
              END IF;

           ELSIF l_si_gross_sal_tbl(l_counter).tax_si_code = 'SIG_SPL' THEN
              IF l_counter = 1 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_one',
                             'l_sig_spl_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_one',
                             'feed_to_si_gr_sal_spl_tax');
              ELSIF l_counter = 2 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_two',
                             'l_sig_spl_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_two',
                             'feed_to_si_gr_sal_spl_tax');
              ELSIF l_counter = 3 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_three',
                             'l_sig_spl_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_three',
                             'feed_to_si_gr_sal_spl_tax');
              END IF;
           ELSIF l_si_gross_sal_tbl(l_counter).tax_si_code = 'SIG_NON' THEN
              IF l_counter = 1 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_one',
                             'l_sig_non_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_one',
                             'feed_to_si_gr_sal_non_tax');
              ELSIF l_counter = 2 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_two',
                             'l_sig_non_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_two',
                             'feed_to_si_gr_sal_non_tax');
              ELSIF l_counter = 3 THEN
                 l_formula_string := replace(l_formula_string,'l_bal_three',
                             'l_sig_non_tax_bal');
                 l_formula_string := replace(l_formula_string,'l_feed_three',
                             'feed_to_si_gr_sal_non_tax');
              END IF;

           END IF;
        END IF;
        l_counter := l_counter + 1;
     END LOOP;

   END IF;
   p_formula_string := l_formula_string;
   hr_utility.set_location('Leaving gen_dynamic_formula',50);

END gen_dynamic_sav_formula;


-- ------------------------------------------------------------------
-- |----------------------< get_bonus >-----------------------------|
-- ------------------------------------------------------------------
FUNCTION get_bonus
         ( p_date_earned       in   date
          ,p_assignment_id     in   per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id in   pqp_pension_types_f.business_group_id%TYPE
          ,p_pension_type_id   in   pqp_pension_types_f.pension_type_id%TYPE
          ,p_pay_period_salary in   number
          ,p_pay_period        in   varchar2
          ,p_work_pattern      in   varchar2
          ,p_conversion_rule   in   varchar2
          ,p_bonus_amount      out  NOCOPY number
          ,p_error_message     out  NOCOPY varchar2
         )

RETURN number IS


l_pension_salary           NUMBER;
l_pension_salary_yr        NUMBER;
l_recur_bonus_percent      NUMBER;
l_non_recur_bonus_percent  NUMBER;
l_recur_bonus_balance      pay_balance_types.balance_type_id%type;
l_non_recur_bonus_balance  pay_balance_types.balance_type_id%type;
l_prev_bonus_include       varchar2(1);
l_recur_bonus              number := 0;
l_non_recur_bonus          number := 0;
l_prev_recur_bonus         number := 0;
l_prev_non_recur_bonus     number := 0;
l_recur_bonus_period       pqp_pension_types_f.recurring_bonus_period%type;
l_non_recur_bonus_period   pqp_pension_types_f.non_recurring_bonus_period%type;
l_end_of_prev_yr           date;
l_prev_run_year            number;
l_payroll_id               pay_payrolls_f.payroll_id%type;
l_asg_action_id            pay_assignment_actions.assignment_action_id%type;
l_time_period_id           per_time_periods.time_period_id%type;
l_defined_bal_id           pay_defined_balances.defined_balance_id%type;
l_start_date               per_time_periods.start_date%type;
l_end_date                 per_time_periods.end_date%type;
l_periods_per_yr           number := 1;
l_ret_val                  number := 0;

CURSOR c_get_pension_type_details IS
SELECT NVL(recurring_bonus_percent,0)
      ,NVL(non_recurring_bonus_percent,0)
      ,recurring_bonus_balance
      ,non_recurring_bonus_balance
      ,previous_year_bonus_included
      ,recurring_bonus_period
      ,non_recurring_bonus_period
  FROM pqp_pension_types_f
 WHERE pension_type_id = p_pension_type_id
   AND TRUNC(p_date_earned) BETWEEN
       effective_start_date AND effective_end_date
   AND business_group_id = p_business_group_id;

CURSOR c_get_defined_bal_id
          (c_balance_type_id IN pay_balance_types.balance_type_id%TYPE) IS
SELECT pdb.defined_balance_id
  FROM pay_balance_dimensions pbd
      ,pay_defined_balances pdb
 WHERE pbd.dimension_name       = 'Assignment Year To Date'
   AND pdb.balance_type_id      = c_balance_type_id
   AND pbd.balance_dimension_id = pdb.balance_dimension_id
   AND pbd.legislation_code = 'NL';

CURSOR c_get_prev_run_year(c_date_earned IN DATE) IS
SELECT TO_NUMBER(TO_CHAR(c_date_earned,'YYYY')) -1
  FROM dual;

CURSOR c_get_payroll_id(c_effective_date IN DATE) IS
SELECT payroll_id
  FROM per_all_assignments_f
 WHERE assignment_id = p_assignment_id
   AND trunc(c_effective_date) BETWEEN
       effective_start_date AND effective_end_date;

CURSOR c_get_time_period_id (c_payroll_id       IN NUMBER
                            ,c_effective_date   IN DATE) IS
SELECT time_period_id
       ,start_date
       ,end_date
  FROM per_time_periods
 WHERE payroll_id = c_payroll_id
   AND trunc(c_effective_date) BETWEEN start_date AND end_date;

CURSOR c_get_asg_act_id (c_time_period_id IN NUMBER
                        ,c_period_start   IN DATE
                        ,c_period_end     IN DATE) IS
SELECT paa.assignment_action_id
  FROM pay_payroll_actions ppa
      ,pay_assignment_actions paa
 WHERE ppa.payroll_action_id = paa.payroll_action_id
   AND ppa.time_period_id = c_time_period_id
   AND paa.assignment_id = p_assignment_id
   AND ppa.action_type in ('R','Q')
   AND ppa.action_status = 'C'
   AND paa.action_status = 'C'
   AND ppa.date_earned BETWEEN c_period_start AND c_period_end
   AND rownum = 1;

Cursor c_get_periods_per_yr(c_period_type in VARCHAR2) IS
   Select number_per_fiscal_year
   from per_time_period_types
   where period_type = c_period_type;

BEGIN

   IF ( p_pay_period LIKE '%Calendar Month'
      OR p_pay_period = 'CM') THEN

         OPEN c_get_periods_per_yr('Calendar Month');

         FETCH c_get_periods_per_yr INTO l_periods_per_yr;

         CLOSE c_get_periods_per_yr;

   ELSIF (p_pay_period LIKE '%Lunar Month'
      OR p_pay_period = 'LM') THEN

          OPEN c_get_periods_per_yr('Lunar Month');

          FETCH c_get_periods_per_yr INTO l_periods_per_yr;

          CLOSE c_get_periods_per_yr;

   ELSIF (p_pay_period LIKE '%Quarter'
      OR p_pay_period = 'Q') THEN

          OPEN c_get_periods_per_yr('Quarter');

          FETCH c_get_periods_per_yr INTO l_periods_per_yr;

          CLOSE c_get_periods_per_yr;

   ELSIF ( p_pay_period LIKE '%Week'
      OR  p_pay_period = 'W') THEN

           OPEN c_get_periods_per_yr('Week');

           FETCH c_get_periods_per_yr INTO l_periods_per_yr;

           CLOSE c_get_periods_per_yr;

   ELSIF ( p_pay_period LIKE '%Year'
      OR  p_pay_period = 'Y') THEN

           OPEN c_get_periods_per_yr('Year');

           FETCH c_get_periods_per_yr INTO l_periods_per_yr;

           CLOSE c_get_periods_per_yr;

   ELSE
	   p_error_message := 'Error : Invalid value for Payroll Period';
           l_ret_val := 1;

   END IF;

   IF l_ret_val  <>  0 THEN

      RETURN l_ret_val;

   END IF;

   -- Get details of the pension type.
   OPEN c_get_pension_type_details;

   FETCH c_get_pension_type_details INTO
               l_recur_bonus_percent
              ,l_non_recur_bonus_percent
              ,l_recur_bonus_balance
              ,l_non_recur_bonus_balance
              ,l_prev_bonus_include
              ,l_recur_bonus_period
              ,l_non_recur_bonus_period;

   CLOSE c_get_pension_type_details;

   l_pension_salary  :=  p_pay_period_salary;

   l_pension_salary_yr := l_pension_salary * l_periods_per_yr;

   OPEN c_get_prev_run_year(TRUNC(p_date_earned));
      FETCH c_get_prev_run_year INTO l_prev_run_year;
   CLOSE c_get_prev_run_year;

  -- Assuming that the last pay period of the previous year ended on 31 Dec
  l_end_of_prev_yr := TO_DATE('31/12/'||TO_CHAR(l_prev_run_year),'DD/MM/YYYY');

   -- If the % is not null, then multiply it with the
   -- salary value for the pay period
   IF (l_recur_bonus_period IS NOT NULL AND
       l_recur_bonus_percent > 0) THEN
          l_recur_bonus :=  l_recur_bonus +
                           (l_recur_bonus_percent/100) * l_pension_salary_yr;
   END IF;

   IF NVL(l_non_recur_bonus_period,'XX') = 'M' then
      l_non_recur_bonus := l_non_recur_bonus +
                          (l_non_recur_bonus_percent/100) * l_pension_salary;
   ELSIF NVL(l_non_recur_bonus_period,'XX') = 'Y' then
      l_non_recur_bonus := l_non_recur_bonus +
                          (l_non_recur_bonus_percent/100) * l_pension_salary_yr;
   END IF;

   IF NVL(l_prev_bonus_include,'XX') = 'Y' THEN

   -- Fetch the payroll id on the last day of
   -- the previous year for this asg

   -- RK what happens here if the person was on a
   -- different assignment in the previous year?.
   -- There is also a possibility that the person has
   -- had multiple jobs ( Multiple ASG's) during that time.
   -- We should fetch the PER_YTD Balance for previous years
   -- recurring and Non Recurring Balances.

   OPEN c_get_payroll_id(l_end_of_prev_yr);
      FETCH c_get_payroll_id INTO l_payroll_id;
         IF c_get_payroll_id%FOUND THEN
            Close c_get_payroll_id;
	        Open c_get_time_period_id
                    (c_payroll_id     => l_payroll_id
                    ,c_effective_date => l_end_of_prev_yr);
	 Fetch c_get_time_period_id into l_time_period_id,l_start_date,l_end_date;
	 If c_get_time_period_id%FOUND then
	    Close c_get_time_period_id;
	    Open c_get_asg_act_id(c_time_period_id => l_time_period_id
	                         ,c_period_start   => l_start_date
				 ,c_period_end     => l_end_date);
            Fetch c_get_asg_act_id into l_asg_action_id;
	    If c_get_asg_act_id%FOUND then
	       Close c_get_asg_act_id;
	       If l_recur_bonus_balance is not null then
	          Open c_get_defined_bal_id(c_balance_type_id => l_recur_bonus_balance);
		  Fetch c_get_defined_bal_id into l_defined_bal_id;
		  If c_get_defined_bal_id%FOUND then
		     Close c_get_defined_bal_id;
	             l_prev_recur_bonus :=
		     pay_balance_pkg.get_value(p_defined_balance_id  => l_defined_bal_id
                                              ,p_assignment_action_id => l_asg_action_id);
		     l_prev_recur_bonus := nvl(l_prev_recur_bonus,0);
		  Else
		     Close c_get_defined_bal_id;
		  End If;
	       End If;
	       If l_non_recur_bonus_balance is not null then
	          Open c_get_defined_bal_id(c_balance_type_id => l_non_recur_bonus_balance);
		  Fetch c_get_defined_bal_id into l_defined_bal_id;
		  If c_get_defined_bal_id%FOUND then
		     Close c_get_defined_bal_id;
	             l_prev_non_recur_bonus :=
		     pay_balance_pkg.get_value(p_defined_balance_id  => l_defined_bal_id
                                              ,p_assignment_action_id => l_asg_action_id);
		     l_prev_non_recur_bonus := nvl(l_prev_non_recur_bonus,0);
		  Else
		     Close c_get_defined_bal_id;
		  End If;
	       End If;
	    Else
               Close c_get_asg_act_id;
	    End if;
	 Else
	    Close c_get_time_period_id;
	 End If;
      Else
         Close c_get_payroll_id;
      End If;
   End If;

   p_bonus_amount := l_recur_bonus +
                     l_non_recur_bonus +
                     l_prev_recur_bonus +
                     l_prev_non_recur_bonus;

   /*find the bonus amount for the pay period*/
   p_bonus_amount := p_bonus_amount / l_periods_per_yr;

   RETURN l_ret_val;

END get_bonus;

-- ------------------------------------------------------------------
-- |----------------------< is_number >-----------------------------|
-- ------------------------------------------------------------------

FUNCTION is_number
         (p_data_value IN OUT NOCOPY varchar2)
RETURN NUMBER  IS
 l_data_value Number;
BEGIN
  l_data_value := Fnd_Number.Canonical_To_Number(Nvl(p_data_value,'0'));
  IF l_data_value >= 0 THEN
     RETURN 0;
  ELSE
     RETURN 1;
  END IF;

EXCEPTION
  WHEN Value_Error THEN
   RETURN 1;
END is_number;

-- ------------------------------------------------------------------
-- |-----------------< get_addnl_savings_amt >-----------------------|
-- ------------------------------------------------------------------

FUNCTION get_addnl_savings_amt
         (p_assignment_id         IN NUMBER
         ,p_date_earned           IN DATE
         ,p_business_group_id     IN NUMBER
         ,p_payroll_id            IN NUMBER
         ,p_pension_type_id       IN NUMBER
         ,p_payroll_period_number IN NUMBER
         ,p_additional_amount     OUT NOCOPY NUMBER
         ,p_error_message         OUT NOCOPY VARCHAR2
         )
RETURN NUMBER  IS

--cursor to fetch the amount from the assignment EIT
--if a row exists for this savings type and the same period number

CURSOR c_get_addnl_amt IS
SELECT fnd_number.canonical_to_number(aei_information3)
  FROM per_assignment_extra_info
WHERE  assignment_id = p_assignment_id
  AND  aei_information1 = to_char(p_pension_type_id)
  AND  aei_information2 = to_char(p_payroll_period_number)
  AND  p_date_earned BETWEEN fnd_date.canonical_to_date(nvl(aei_information4,fnd_date.date_to_canonical(to_date('01-01-1951','dd-mm-yyyy'))))
                     AND fnd_date.canonical_to_date(nvl(aei_information5,fnd_date.date_to_canonical(to_date('31-12-4712','dd-mm-yyyy'))))
  AND  aei_information_category = 'NL_SAV_INFO'
  AND  information_type = 'NL_SAV_INFO';

l_ret_val NUMBER;
l_addnl_amt NUMBER;

BEGIN

--fetch the additional amount from the ASG EIT
OPEN c_get_addnl_amt;
FETCH c_get_addnl_amt INTO l_addnl_amt;
IF c_get_addnl_amt%FOUND THEN
   CLOSE c_get_addnl_amt;
   p_additional_amount := l_addnl_amt;
   l_ret_val           := 0;
ELSE
   CLOSE c_get_addnl_amt;
   p_additional_amount := 0;
   l_ret_val           := 0;
END IF;

RETURN l_ret_val;

EXCEPTION

WHEN OTHERS THEN

p_error_message := 'Error occured while fetching the value for the additional'
                  ||' contribution amount.';
p_additional_amount := 0;
l_ret_val := 1;
RETURN l_ret_val;

END get_addnl_savings_amt;

-- -----------------------------------------------------------------------
-- |---------------------< get_abp_entry_value >--------------------------|
-- -----------------------------------------------------------------------
function get_abp_entry_value
  (p_business_group_id   in     pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned         in     date
  ,p_assignment_id       in     per_all_assignments_f.assignment_id%TYPE
  ,p_element_type_id     in     number
  ,p_input_value_name    in     varchar2
  ) return NUMBER IS

-- Cursor to get the hire date of the person
CURSOR c_hire_dt_cur(c_asg_id IN NUMBER) IS
SELECT max(date_start)
 FROM  per_all_assignments_f asg
      ,per_periods_of_service pps
 WHERE pps.person_id     = asg.person_id
   AND asg.assignment_id = c_asg_id
   AND pps.business_group_id = p_business_group_id
   AND date_start <= p_date_earned;

--cursor to get the start date for the assignment
CURSOR c_get_asg_start IS
SELECT min(effective_start_date)
  FROM per_all_assignments_f
WHERE  assignment_id = p_assignment_id;

-- Cursor to get the entry value for the input name
CURSOR c_entry_val_cur
       ( c_effective_date IN DATE
        ,c_ipv_id         IN NUMBER) IS

SELECT min (fffunc.cn(decode(decode(INPUTV.uom,'M','N','N','N','I','N',NULL),'N'
       ,decode(INPUTV.hot_default_flag,'Y',nvl(EEV.screen_entry_value
       ,nvl(LIV.default_value,INPUTV.default_value)),'N',EEV.screen_entry_value),NULL)))
FROM    pay_element_entry_values_f               EEV,
        pay_element_entries_f                    EE,
        pay_link_input_values_f                  LIV,
        pay_input_values_f                       INPUTV
WHERE   INPUTV.input_value_id                  = c_ipv_id
AND     c_effective_date BETWEEN INPUTV.effective_start_date
                 AND INPUTV.effective_end_date
AND     INPUTV.element_type_id + 0             = p_element_type_id
AND     LIV.input_value_id                     = INPUTV.input_value_id
AND     c_effective_date BETWEEN LIV.effective_start_date
                 AND LIV.effective_end_date
AND     EEV.input_value_id + 0                 = INPUTV.input_value_id
AND     EEV.element_entry_id                   = EE.element_entry_id
AND     EEV.effective_start_date               = EE.effective_start_date
AND     EEV.effective_end_date                 = EE.effective_end_date
AND     EE.element_link_id                     = LIV.element_link_id
AND     EE.assignment_id                       = p_assignment_id
AND     c_effective_date BETWEEN EE.effective_start_date
                 AND EE.effective_end_date
AND     nvl(EE.ENTRY_TYPE, 'E')              = 'E';

CURSOR c_iv_id_cur IS
select  iv.input_value_id
from    pay_input_values_f_tl iv_tl,
        pay_input_values_f iv
where   iv.element_type_id    = p_element_type_id
and     iv_tl.input_value_id  = iv.input_value_id
and     iv_tl.language        = userenv('LANG')
and     upper(iv_tl.name)     = upper(p_input_value_name)
AND     p_date_earned BETWEEN iv.effective_start_date
                 AND iv.effective_end_date;

---

l_run_year             NUMBER;
l_hire_date            DATE;
l_asg_st_date          DATE;
l_effective_date       DATE;
l_error_message        VARCHAR2(100);
l_input_value_id       NUMBER;
l_return_value         NUMBER;
l_error_status         CHAR :='0';
BEGIN

-- Determine the hire date
OPEN c_hire_dt_cur(p_assignment_id);
   FETCH c_hire_dt_cur INTO l_hire_date;
CLOSE c_hire_dt_cur;

--determine the start date of the assignment
OPEN c_get_asg_start;
FETCH c_get_asg_start INTO l_asg_st_date;
CLOSE c_get_asg_start;

-- Determine the year of payroll run
l_run_year := get_run_year (p_date_earned
                           ,l_error_message );

--
-- Get the date for 1 JAN of the run year
--
--l_effective_date := TO_DATE('01/01/'||to_char(l_run_year),'DD/MM/YYYY');
-- Get valid assignment start date

l_effective_date := PQP_NL_ABP_FUNCTIONS.GET_VALID_START_DATE(p_assignment_id,p_date_earned,l_error_status,l_error_message);
IF (l_error_status = trim(to_char(1,'9'))) Then
 RETURN 0;
End IF;

--
-- Get the input value id for the Input Value Name,
-- Element and Language combination.
--
OPEN c_iv_id_cur;
FETCH c_iv_id_cur INTO l_input_value_id;

   -- Get the id for the input
   IF c_iv_id_cur%NOTFOUND THEN
       -- Could not find the input value id .
       -- Return Control
       CLOSE c_iv_id_cur;
       RETURN 0;
   ELSE
      CLOSE c_iv_id_cur;
   END IF;

-- Get the input value as of the first Jan or Hire Date for the
-- input obtained above.

OPEN  c_entry_val_cur
       ( c_effective_date => l_effective_date
        ,c_ipv_id         => l_input_value_id);
FETCH c_entry_val_cur INTO l_return_value;

   IF c_entry_val_cur%NOTFOUND THEN
      l_return_value := 0;
   END IF ;

CLOSE c_entry_val_cur;

RETURN NVL(l_return_value,0);

END get_abp_entry_value;

--
-- Function to calculate the hook part time percentage
--

FUNCTION get_hook_part_time_perc (p_assignment_id IN NUMBER
                            ,p_date_earned IN DATE
                            ,p_business_group_id IN NUMBER
                            ,p_assignment_action_id IN NUMBER) RETURN number IS

--
CURSOR csr_get_pay_action_id(c_assignment_action_id NUMBER) IS
SELECT payroll_action_id
FROM   pay_assignment_actions
WHERE  assignment_action_id = c_assignment_action_id;
--
l_payroll_action_id number;
l_part_time_perc  varchar2(35);
l_inputs          ff_exec.inputs_t;
l_outputs         ff_exec.outputs_t;
l_formula_exists  BOOLEAN := TRUE;
l_formula_cached  BOOLEAN := FALSE;
l_formula_id      ff_formulas_f.formula_id%TYPE;

-- This is the exact replica of the SI Hook
-- The code has been replicated here

BEGIN

g_ptp_formula_name := 'NL_ABP_PART_TIME_PERCENTAGE';
OPEN  csr_get_pay_action_id(p_assignment_action_id);
FETCH csr_get_pay_action_id INTO l_payroll_action_id;
CLOSE csr_get_pay_action_id;

IF g_ptp_formula_exists = TRUE THEN
   IF g_ptp_formula_cached = FALSE THEN
      pay_nl_general.cache_formula('NL_ABP_PART_TIME_PERCENTAGE'
                                  ,p_business_group_id,p_date_earned
                                  ,l_formula_id,l_formula_exists
                                  ,l_formula_cached);
                   g_ptp_formula_exists:=l_formula_exists;
                   g_ptp_formula_cached:=l_formula_cached;
                   g_ptp_formula_id:=l_formula_id;
   END IF;

             --
               IF g_ptp_formula_exists = TRUE THEN
             --  hr_utility.trace('FORMULA EXISTS');
                  --
                   l_inputs(1).name  := 'ASSIGNMENT_ID';
                   l_inputs(1).value := p_assignment_id;
                   l_inputs(2).name  := 'DATE_EARNED';
                   l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
                   l_inputs(3).name  := 'BUSINESS_GROUP_ID';
                   l_inputs(3).value := p_business_group_id;
                   l_inputs(4).name := 'ASSIGNMENT_ACTION_ID';
                   l_inputs(4).value := p_assignment_action_id;
                   l_inputs(5).name := 'PAYROLL_ACTION_ID';
                   l_inputs(5).value := l_payroll_action_id;
                   l_inputs(6).name := 'BALANCE_DATE';
                   l_inputs(6).value := fnd_date.date_to_canonical(p_date_earned);
                  --
                   l_outputs(1).name := 'PART_TIME_PERCENTAGE';
                  --
                   pay_nl_general.run_formula(p_formula_id       => g_ptp_formula_id,
                                              p_effective_date   => p_date_earned,
                                              p_formula_name     => g_ptp_formula_name,
                                              p_inputs           => l_inputs,
                                              p_outputs          => l_outputs);
                  --
                   l_part_time_perc := l_outputs(1).value;

         --    hr_utility.trace('l_part_time_perc'||l_part_time_perc);
               ELSE
           --  hr_utility.trace('FORMULA DOESNT EXISTS');
                   l_part_time_perc := NULL;

           --  hr_utility.trace('l_part_time_perc'||l_part_time_perc);

               END IF;
           ELSIF g_ptp_formula_exists = FALSE THEN
               l_part_time_perc := NULL;
           END IF;

           RETURN fnd_number.canonical_to_number(l_part_time_perc);

END get_hook_part_time_perc;


FUNCTION get_reporting_part_time_perc (p_assignment_id IN NUMBER
                            ,p_date_earned IN DATE
                            ,p_business_group_id IN NUMBER
                            ,p_assignment_action_id IN NUMBER) RETURN number IS

--
CURSOR csr_get_pay_action_id(c_assignment_action_id NUMBER) IS
SELECT payroll_action_id
FROM   pay_assignment_actions
WHERE  assignment_action_id = c_assignment_action_id;
--
l_payroll_action_id number;
l_part_time_perc  varchar2(35);
l_inputs          ff_exec.inputs_t;
l_outputs         ff_exec.outputs_t;
l_formula_exists  BOOLEAN := TRUE;
l_formula_cached  BOOLEAN := FALSE;
l_formula_id      ff_formulas_f.formula_id%TYPE;

-- This is the exact replica of the SI Hook
-- The code has been replicated here

BEGIN

g_ptp_formula_name := 'NL_ABP_REPORTING_PART_TIME_PERCENTAGE';
--
OPEN  csr_get_pay_action_id(p_assignment_action_id);
FETCH csr_get_pay_action_id INTO l_payroll_action_id;
CLOSE csr_get_pay_action_id;
--

IF g_ptp_formula_exists = TRUE THEN
   IF g_ptp_formula_cached = FALSE THEN
      pay_nl_general.cache_formula('NL_ABP_REPORTING_PART_TIME_PERCENTAGE'
                                  ,p_business_group_id
                                  ,p_date_earned
                                  ,l_formula_id,l_formula_exists
                                  ,l_formula_cached);
                   g_ptp_formula_exists:=l_formula_exists;
                   g_ptp_formula_cached:=l_formula_cached;
                   g_ptp_formula_id:=l_formula_id;
   END IF;

             --
               IF g_ptp_formula_exists = TRUE THEN
             --  hr_utility.trace('FORMULA EXISTS');
                  --
                   l_inputs(1).name  := 'ASSIGNMENT_ID';
                   l_inputs(1).value := p_assignment_id;
                   l_inputs(2).name  := 'DATE_EARNED';
                   l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
                   l_inputs(3).name  := 'BUSINESS_GROUP_ID';
                   l_inputs(3).value := p_business_group_id;
                   l_inputs(4).name := 'ASSIGNMENT_ACTION_ID';
                   l_inputs(4).value := p_assignment_action_id;
                   l_inputs(5).name := 'PAYROLL_ACTION_ID';
                   l_inputs(5).value := l_payroll_action_id;
                   l_inputs(6).name := 'BALANCE_DATE';
                   l_inputs(6).value := fnd_date.date_to_canonical(p_date_earned);
                  --
                   l_outputs(1).name := 'PART_TIME_PERCENTAGE';
                  --
                   pay_nl_general.run_formula(p_formula_id       => g_ptp_formula_id,
                                              p_effective_date   => p_date_earned,
                                              p_formula_name     => g_ptp_formula_name,
                                              p_inputs           => l_inputs,
                                              p_outputs          => l_outputs);
                  --
                   l_part_time_perc := l_outputs(1).value;

         --    hr_utility.trace('l_part_time_perc'||l_part_time_perc);
               ELSE
           --  hr_utility.trace('FORMULA DOESNT EXISTS');
                   l_part_time_perc := NULL;

           --  hr_utility.trace('l_part_time_perc'||l_part_time_perc);

               END IF;
           ELSIF g_ptp_formula_exists = FALSE THEN
               l_part_time_perc := NULL;
           END IF;

           RETURN fnd_number.canonical_to_number(l_part_time_perc);

END get_reporting_part_time_perc;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_avg_part_time_perc >-------------------------|
-- ----------------------------------------------------------------------------
-- This function is to get the average part time percentage of the
-- employee for calculations in pension basis.

function get_avg_part_time_perc
  (p_business_group_id    in  pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned          in  date
  ,p_assignment_id        in  per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_action_id IN NUMBER
  ,p_period_start_date    in  DATE
  ,p_period_end_date      in  DATE
  ,p_avg_part_time_perc   out NOCOPY number
  ,p_error_message        out NOCOPY varchar2)

return NUMBER IS

--
-- Cursor to get the start date for the active asg
--
CURSOR c_get_assign_start_date IS
SELECT min(asg.effective_start_date)
  FROM per_assignments_f asg
      ,per_assignment_status_types past
 WHERE asg.assignment_status_type_id = past.assignment_status_type_id
   AND past.per_system_status = 'ACTIVE_ASSIGN'
   AND asg.effective_start_date <= trunc(p_period_end_date)
   AND nvl(asg.effective_end_date, trunc(p_period_end_date)) >= trunc(p_period_start_date)
   AND asg.assignment_id = p_assignment_id
   group by asg.assignment_id;

--
-- Cursor to get the effective start and end dates for various changes
-- that have been made to the part time percent.
--
CURSOR c_pt_cur (c_effective_date IN DATE) IS
SELECT asg.effective_start_date Start_Dt,
       decode(asg.effective_end_date,
       to_date ('31/12/4712','DD/MM/YYYY'),
       trunc(p_period_end_date),
       asg.effective_end_date) End_Dt
      ,fnd_number.canonical_to_number(NVL(target.SEGMENT29,'100')) pt_perc
 FROM  per_assignments_f asg
      ,per_assignment_status_types past
      ,hr_soft_coding_keyflex target
 WHERE asg.assignment_status_type_id = past.assignment_status_type_id
   AND past.per_system_status = 'ACTIVE_ASSIGN'
   AND asg.effective_end_date >= c_effective_date
   AND asg.assignment_id = p_assignment_id
   AND target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
   AND target.enabled_flag = 'Y';

l_effective_date   DATE;
l_completed        VARCHAR2(1);
l_days_in_pp       NUMBER;
l_pt_perc          NUMBER;
l_end_date         DATE;
l_start_date       DATE;
l_hook_ptp         NUMBER;
l_min_start_date   DATE;
l_max_end_date     DATE;
l_count            NUMBER := 0;
l_ret_val          NUMBER := 0;

BEGIN

--
-- Check if there is an override in the HOOK for the ABP Part time percent
--
l_hook_ptp := pqp_pension_functions.get_hook_part_time_perc (p_assignment_id
                        ,p_date_earned
                        ,p_business_group_id
                        ,p_assignment_action_id);

IF NVL(l_hook_ptp,0) <> 0 THEN

   --
   -- For ABP The max percent allowed is 125. Enforce that rule here
   --
   l_hook_ptp := LEAST(l_hook_ptp,125);
   p_error_message := 'The part time percentage has been overridden by a formula.'
                    ||' The maximum value used is 125.';

    p_avg_part_time_perc := round(l_hook_ptp,4);
    RETURN 2;

ELSE

-- Do regular calculation

OPEN c_get_assign_start_date;
   FETCH c_get_assign_start_date INTO l_effective_date;
CLOSE c_get_assign_start_date;

l_completed      := 'N';

l_pt_perc        := 0;

l_effective_date := GREATEST(l_effective_date,trunc(p_period_start_date));

l_days_in_pp     := (trunc(p_period_end_date)
                   - trunc(p_period_start_date)) + 1;

FOR temp_rec in c_pt_cur ( trunc(l_effective_date) )

LOOP

   IF l_completed = 'N' THEN

      IF temp_rec.End_Dt >= trunc(p_period_end_date) THEN
         l_end_date := trunc(p_period_end_date);
         l_completed      := 'Y';
      ELSE
         l_end_date := temp_rec.End_Dt;
      END IF;

      IF temp_rec.Start_Dt < trunc(p_period_start_date) THEN
         l_start_date := trunc(p_period_start_date);
      ELSE
         l_start_date := temp_rec.Start_Dt;
      END IF;

      IF l_count = 0 THEN
         l_min_start_date := l_start_date;
         l_max_end_date   := l_end_date;
      ELSE
         IF l_start_date < l_min_start_date THEN
            l_min_start_date := l_start_date;
         END IF;
         IF l_end_date > l_max_end_date THEN
            l_max_end_date := l_end_date;
         END IF;
      END IF;

      l_count := l_count + 1;

      l_pt_perc := l_pt_perc + temp_rec.pt_perc * ((trunc(l_end_date) -
                                 trunc(l_start_date)) + 1);

   END IF;

END LOOP;

--find the number of days the assignments has been effective in the
--current period
l_days_in_pp := nvl(l_max_end_date,trunc(p_period_end_date))
                - nvl(l_min_start_date,trunc(p_period_start_date))
                + 1;

--find the average part time percentage value
l_pt_perc := l_pt_perc/l_days_in_pp;

   --
   -- For ABP The max percent allowed is 125. Enforce that rule here
   --
   IF l_pt_perc > 125 THEN
      p_error_message := 'The part time percentage is restricted to a '
                       ||'maximum of 125.';
      l_ret_val := 2;
   END IF;
   l_pt_perc := LEAST(l_pt_perc,125);

p_avg_part_time_perc := round(l_pt_perc,4);
RETURN l_ret_val;

END IF;

EXCEPTION WHEN OTHERS THEN
   p_error_message := 'Error occured while deriving the part time '
                    ||'percentage : '||SQLERRM;
   p_avg_part_time_perc := 0;
   RETURN 1;

END get_avg_part_time_perc;

--Function to derive the version id of the current hierarchy
--defined for any given business group

FUNCTION get_version_id
         (p_business_group_id  IN NUMBER
         ,p_date_earned        IN DATE)

RETURN NUMBER IS

--Cursor to find the named hierarchy associated with the BG
CURSOR c_find_named_hierarchy Is
select org_information1
 from hr_organization_information
where organization_id = p_business_group_id
 and org_information_context = 'NL_BG_INFO';

--Cursor to find the valid version id for the particular named hierarchy
CURSOR c_find_ver_frm_hierarchy(c_hierarchy_id in Number) Is
select ORG_STRUCTURE_VERSION_ID
  from per_org_structure_versions_v
where organization_structure_id = c_hierarchy_id
  and p_date_earned between date_from
  and nvl(date_to,hr_api.g_eot);

--Cursor to find the valid version id for a particular business group
CURSOR c_find_ver_frm_bg Is
select ORG_STRUCTURE_VERSION_ID
  from per_org_structure_versions_v
where business_group_id = p_business_group_id
  and p_date_earned between date_from
  and nvl( date_to,hr_api.g_eot);

l_named_hierarchy       number;
l_version_id            per_org_structure_versions_v.org_structure_version_id%type
                        default -99;
l_proc_name             varchar2(30) := 'Get_Version_id';

BEGIN
hr_utility.set_location('Entering : '||l_proc_name,10);
--first chk to see if a named hierarchy exists for the BG
OPEN c_find_named_hierarchy;
FETCH c_find_named_hierarchy INTO l_named_hierarchy;
-- if a named hiearchy is found , find the valid version on that date

IF c_find_named_hierarchy%FOUND THEN

   CLOSE c_find_named_hierarchy;
   hr_utility.set_location('Found named hierarchy : '||l_named_hierarchy,20);
   -- now find the valid version on that date
   OPEN c_find_ver_frm_hierarchy(l_named_hierarchy);
   FETCH c_find_ver_frm_hierarchy INTO l_version_id;

   --if no valid version is found, try to get it frm the BG
   IF c_find_ver_frm_hierarchy%NOTFOUND THEN

      CLOSE c_find_ver_frm_hierarchy;
      hr_utility.set_location('No valid version was found for the named hierarchy',30);
      -- find the valid version id from the BG
      OPEN c_find_ver_frm_bg;
      FETCH c_find_ver_frm_bg INTO l_version_id;
      CLOSE c_find_ver_frm_bg;
      hr_utility.set_location('Found the version from the BG : '||l_version_id,40);

   -- else a valid version has been found for the named hierarchy
   ELSE

      CLOSE c_find_ver_frm_hierarchy;
      hr_utility.set_location('Found the version for named hierarchy : '||l_version_id,50);

   END IF; --end of if no valid version found

-- else find the valid version from BG
ELSE

   CLOSE c_find_named_hierarchy;
   hr_utility.set_location('No named hierarchy exists',60);
   --now find the version number from the BG
   OPEN c_find_ver_frm_bg;
   FETCH c_find_ver_frm_bg INTO l_version_id;
   CLOSE c_find_ver_frm_bg;
   hr_utility.set_location('Found the version from the BG : '||l_version_id,60);

END IF; -- end of if named hierarchy found

RETURN nvl(l_version_id,-99);

EXCEPTION
WHEN OTHERS THEN
   l_version_id := -99;
   RETURN l_version_id;

END get_version_id;

--
-- ----------------------------------------------------------------------------
-- |---------------------< get_pay_period_age >-------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_pay_period_age
  (p_business_group_id  IN  pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned        IN  DATE
  ,p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
  ,p_period_start_date  IN  DATE
  ) RETURN NUMBER IS

  --
  -- Local variables
  --
  l_dob         DATE;
  l_eff_dt      DATE;
  l_asg_st_dt   DATE;
  l_age         NUMBER;
  l_proc_name   VARCHAR2(150) := g_proc_name || 'get_pay_period_age';


  --
  -- Cursor to get the date of birth
  --
  CURSOR get_dob IS
  SELECT TRUNC(date_of_birth)
    FROM per_all_people_f per
        ,per_all_assignments_f paf
   WHERE per.person_id      = paf.person_id
     AND paf.assignment_id  = p_assignment_id
     AND p_date_earned BETWEEN per.effective_start_date AND per.effective_end_date
     AND p_date_earned BETWEEN paf.effective_start_date AND paf.effective_end_date;

   --
   -- Cursor to get the start date for the active asg
   --
   CURSOR c_get_assign_start_date IS
   SELECT min(asg.effective_start_date)
     FROM per_all_assignments_f asg
         ,per_assignment_status_types past
    WHERE asg.assignment_status_type_id = past.assignment_status_type_id
      AND past.per_system_status        = 'ACTIVE_ASSIGN'
      --AND asg.effective_start_date <= trunc(p_period_start_date)
      AND asg.assignment_id = p_assignment_id;

BEGIN

  hr_utility.set_location('Entering : '||l_proc_name, 10);

  --
  -- Derive the assignment start date
  --
  OPEN c_get_assign_start_date;
     FETCH c_get_assign_start_date INTO l_asg_st_dt;
  CLOSE c_get_assign_start_date;

  hr_utility.set_location('.....Assignment Id    : '||p_assignment_id, 13);
  hr_utility.set_location('.....Assignment Start : '||l_asg_st_dt, 15);

  --
  -- Derive the greater of effective start date and assignment start date
  --
  l_eff_dt := GREATEST(NVL(l_asg_st_dt,p_period_start_date),p_period_start_date);

  hr_utility.set_location('.....Pay Period Start : '||p_period_start_date, 20);
  hr_utility.set_location('.....Effective Date   : '||l_eff_dt, 25);

  OPEN get_dob;
     FETCH get_dob INTO l_dob;
  CLOSE get_dob;
  --

  --
  l_dob := NVL(l_dob,p_date_earned);

  hr_utility.set_location('.....Birth Date   : '||l_dob, 30);
  --
  l_age := TRUNC(MONTHS_BETWEEN(l_eff_dt,l_dob)/12,6);

  hr_utility.set_location('.....Age is : '||l_age, 35);

  hr_utility.set_location('Leaving : '||l_proc_name, 40);

  RETURN(l_age);
  --

EXCEPTION
WHEN OTHERS THEN

  hr_utility.set_location('Leaving with errors: '||l_proc_name, 50);
  RETURN 0;

END get_pay_period_age;

end pqp_pension_functions;

/
