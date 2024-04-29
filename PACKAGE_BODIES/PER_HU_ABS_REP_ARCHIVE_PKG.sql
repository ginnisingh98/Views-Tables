--------------------------------------------------------
--  DDL for Package Body PER_HU_ABS_REP_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HU_ABS_REP_ARCHIVE_PKG" AS
/* $Header: pehuarep.pkb 120.1 2006/08/30 13:33:41 rbhardwa noship $ */
--
--globals
--
g_reporting_date     DATE;
g_effective_date     DATE;
g_business_group_id  NUMBER;
g_payroll_id         NUMBER;
g_assignment_set_id  NUMBER;
--
--------------------------------------------------------------------------------
-- GET_PARAMETER
--------------------------------------------------------------------------------
FUNCTION get_parameter(
         p_parameter_string IN VARCHAR2
        ,p_token            IN VARCHAR2
         ) RETURN VARCHAR2 IS
--
    l_parameter  pay_payroll_actions.legislative_parameters%TYPE;
    l_start_pos  NUMBER;
    l_delimiter  VARCHAR2(1);
--
BEGIN
    l_delimiter := ' ';
    l_parameter := NULL;
    l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
    IF l_start_pos = 0 THEN
        l_delimiter := '|';
        l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
    END IF;
    IF l_start_pos <> 0 THEN
        l_start_pos := l_start_pos + length(p_token||'=');
        l_parameter := substr(p_parameter_string,
                              l_start_pos,
                              instr(p_parameter_string||' ',
                              l_delimiter,l_start_pos)
                              - l_start_pos);

    END IF;
    RETURN l_parameter;
END get_parameter;
--------------------------------------------------------------------------------
-- GET_ALL_PARAMETERS
--------------------------------------------------------------------------------
PROCEDURE get_all_parameters(p_payroll_action_id  IN         NUMBER
                            ,p_business_group_id  OUT NOCOPY NUMBER
                            ,p_effective_date     OUT NOCOPY DATE
                            ,p_reporting_date     OUT NOCOPY DATE
                            ,p_payroll_id         OUT NOCOPY NUMBER
                            ,p_assignment_set_id  OUT NOCOPY NUMBER
                            ,p_employee_id        OUT NOCOPY NUMBER
                            ) IS
  --
  CURSOR csr_parameter_info (c_payroll_action_id NUMBER) IS
  SELECT effective_date
        ,fnd_date.canonical_to_date(per_hu_abs_rep_archive_pkg.get_parameter(legislative_parameters, 'DATE'))
        ,per_hu_abs_rep_archive_pkg.get_parameter(legislative_parameters, 'PAYROLL_ID')
        ,per_hu_abs_rep_archive_pkg.get_parameter(legislative_parameters, 'ASG_SET_ID')
        ,per_hu_abs_rep_archive_pkg.get_parameter(legislative_parameters, 'EMP_ID')
        ,business_group_id
  FROM   pay_payroll_actions
  WHERE  payroll_action_id = c_payroll_action_id;
  --
BEGIN
  --
  OPEN csr_parameter_info (p_payroll_action_id);
  FETCH csr_parameter_info INTO  p_effective_date
                                ,p_reporting_date
                                ,p_payroll_id
                                ,p_assignment_set_id
                                ,p_employee_id
                                ,p_business_group_id;
  CLOSE csr_parameter_info;
  --
END;
--
--------------------------------------------------------------------------------
-- FUNCTION GET_ABS_REP_PARAMETER
--------------------------------------------------------------------------------
FUNCTION get_abs_rep_parameter (p_actid  IN NUMBER) RETURN VARCHAR2 IS

    --
    CURSOR csr_get_payroll_name(cpayroll_id     NUMBER
                               ,ceffective_date DATE) IS
    SELECT payroll_name
    FROM   pay_all_payrolls_f
    WHERE  payroll_id = cpayroll_id
    AND    ceffective_date BETWEEN effective_start_date AND effective_end_date;
    --
    CURSOR csr_get_person_name(cperson_id      NUMBER
                              ,ceffective_date DATE) IS
    SELECT full_name
    FROM   per_All_people_f
    WHERE  person_id = cperson_id
    AND    ceffective_date BETWEEN effective_start_date AND effective_end_date;
    --
    leffective_date         DATE;
    lreporting_date         DATE;
    lpayroll_id             pay_all_payrolls_f.payroll_id%TYPE;
    lassignment_set_id      hr_assignment_sets.assignment_set_id%TYPE;
    lperson_id              per_all_people_f.person_id%TYPE;
    lpayroll_name           pay_all_payrolls_f.payroll_name%TYPE;
    lreturn_val             VARCHAR2(400);
    lfull_name              per_all_people_f.full_name%TYPE;
    lbusiness_group_id      per_all_people_f.business_group_id%TYPE;
BEGIN
  --
  per_hu_abs_rep_archive_pkg.get_all_parameters (
                           p_payroll_action_id   =>  p_actid
                          ,p_business_group_id   =>  lbusiness_group_id
                          ,p_effective_date      =>  leffective_date
                          ,p_reporting_date      =>  lreporting_date
                          ,p_payroll_id          =>  lpayroll_id
                          ,p_assignment_set_id   =>  lassignment_set_id
                          ,p_employee_id         =>  lperson_id
                          );

  OPEN csr_get_payroll_name(lpayroll_id,leffective_date );
  FETCH csr_get_payroll_name INTO lpayroll_name;
  CLOSE csr_get_payroll_name;

  OPEN csr_get_person_name(lperson_id ,leffective_date );
  FETCH csr_get_person_name INTO lfull_name;
  CLOSE csr_get_person_name;

  lreturn_val := fnd_date.date_to_displaydate(leffective_date)
		||' - '||fnd_date.date_to_displaydate(lreporting_date)
		||' - '||rpad(nvl(lpayroll_name,' '),40,' ')
		||' - '||rpad(nvl(to_char(lassignment_set_id),' '),10,' ')
		||' - '||rpad(nvl(lfull_name,' '),40,' ');

  RETURN lreturn_val;
END get_abs_rep_parameter;

--
--------------------------------------------------------------------------------
-- RANGE_CODE
--------------------------------------------------------------------------------
PROCEDURE range_code(p_actid IN  NUMBER
                    ,sqlstr  OUT NOCOPY VARCHAR2) IS

CURSOR csr_utv_check(c_business_group_id NUMBER
                    ,c_reporting_date    DATE) IS
SELECT 1
FROM   pay_user_column_instances_f   pui
      ,pay_user_columns              puc
      ,pay_user_tables               put
WHERE  pui.user_column_id    =  puc.user_column_id
AND    puc.user_column_name  = 'Holiday Type'
AND    puc.legislation_code  = 'HU'
AND    puc.user_table_id     =  put.user_table_id
AND    put.user_table_name   = 'HU_ABSENCE_REPORT_ACCRUAL_PLAN_MAPPINGS'
AND    pui.business_group_id =  c_business_group_id
AND    put.legislation_code  = 'HU'
AND    c_reporting_date BETWEEN pui.effective_start_date
                        AND     pui.effective_end_date
AND    pui.value LIKE 'HU%';

l_effective_date             DATE;
l_emp_id                     per_all_people_f.person_id%TYPE;
l_exsist                     NUMBER;
BEGIN
 --
   per_hu_abs_rep_archive_pkg.get_all_parameters (
                          p_payroll_action_id   =>  p_actid
                         ,p_business_group_id   =>  g_business_group_id
                         ,p_effective_date      =>  l_effective_date
                         ,p_reporting_date      =>  g_reporting_date
                         ,p_payroll_id          =>  g_payroll_id
                         ,p_assignment_set_id   =>  g_assignment_set_id
                         ,p_employee_id         =>  l_emp_id
                          );

   OPEN csr_utv_check(g_business_group_id, g_reporting_date);
   FETCH csr_utv_check INTO l_exsist;
   IF  csr_utv_check%NOTFOUND THEN
        --
        sqlstr := 'SELECT 1 FROM dual WHERE to_char(:payroll_action_id) = dummy';
        -- Message to written to log file.
        fnd_file.put_line(fnd_file.log,fnd_message.get_string('PER'
                                                   ,'HR_HU_ABS_REP_UDT_VALUE'));
        --
    ELSE
        --
        sqlstr := 'SELECT distinct person_id
                   FROM  per_people_f ppf
                        ,pay_payroll_actions ppa
                   WHERE ppa.payroll_action_id = :payroll_action_id
                   AND   ppa.business_group_id = ppf.business_group_id
                   ORDER BY ppf.person_id';
        --
    END IF;
    CLOSE csr_utv_check;

  EXCEPTION
  WHEN OTHERS THEN
      sqlstr := 'SELECT 1 FROM dual WHERE to_char(:payroll_action_id) = dummy';
END range_code;

--------------------------------------------------------------------------------
-- ACTION_CREATION_CODE
--------------------------------------------------------------------------------
 PROCEDURE action_creation_code (p_actid   IN NUMBER
                                ,stperson  IN NUMBER
                                ,endperson IN NUMBER
                                ,chunk     IN NUMBER) IS
 ----
    CURSOR csr_qualifying_assignments(c_pact_id           NUMBER
                                     ,c_stperson          NUMBER
                                     ,c_endperson         NUMBER
                                     ,c_reporting_date    DATE
                                     ,c_payroll_id        NUMBER
                                     ,c_emp_id            NUMBER) IS
    SELECT paa.assignment_id             assignment_id
          ,paa.people_group_id           people_group_id
          ,hoi.org_information1          company_name
          ,pap.full_name                 full_name
          ,pap.person_id                 person_id
          ,pap.employee_NUMBER           emp_no
          ,pap.date_of_birth             date_of_birth
          ,ppf.date_start                hire_date
          ,ppf.actual_termination_date   termination_date
          ,hou.name                      organization
          ,paa.location_id               location_id
          ,paa.payroll_id                payroll_id
          ,paa.job_id                    job_id
    FROM   pay_payroll_actions           ppa
          ,per_all_assignments_f         paa
          ,per_all_people_f              pap
          ,per_periods_of_service        ppf
          ,hr_organization_information   hoi
          ,hr_all_organization_units     hou
    WHERE  ppa.payroll_action_id         = c_pact_id
    AND    pap.person_id                 = paa.person_id
    AND    pap.person_id                 BETWEEN c_stperson
                                         AND     c_endperson
    AND    pap.person_id                 =  NVL(c_emp_id,pap.person_id)
    AND    paa.primary_flag              = 'Y'
    AND    paa.assignment_type           = 'E'
    AND    ppa.business_group_id         =  paa.business_group_id
    AND    pap.business_group_id         =  paa.business_group_id
    AND    paa.period_of_service_id      =  ppf.period_of_service_id
    AND    NVL(paa.payroll_id,0)         =  NVL(c_payroll_id,NVL(paa.payroll_id,0))
    AND    hoi.organization_id           =  paa.business_group_id
    AND    hoi.org_information_context   = 'HU_COMPANY_INFORMATION_DETAILS'
    AND    hou.organization_id           =  paa.organization_id
    AND    c_reporting_date              BETWEEN pap.effective_start_date
                                         AND     pap.effective_end_date
    AND    c_reporting_date              BETWEEN paa.effective_start_date
                                         AND     paa.effective_end_date
    AND    (ppf.actual_termination_date  IS NULL
            OR ppf.actual_termination_date > c_reporting_date)
    ORDER BY assignment_id;
    --
    CURSOR csr_get_utv(c_business_group_id NUMBER
                      ,c_reporting_date    DATE
                      ,c_holiday_type      VARCHAR2) IS
    SELECT pur.row_low_range_or_name     accrual_plan
    FROM   pay_user_column_instances_f   pui
          ,pay_user_columns              puc
          ,pay_user_tables               put
          ,pay_user_rows_f               pur
    WHERE  pui.user_column_id    =  puc.user_column_id
    AND    puc.user_column_name  = 'Holiday Type'
    AND    puc.legislation_code  = 'HU'
    AND    puc.user_table_id     =  put.user_table_id
    AND    put.user_table_name   = 'HU_ABSENCE_REPORT_ACCRUAL_PLAN_MAPPINGS'
    AND    pui.business_group_id =  c_business_group_id
    AND    pui.value             =  c_holiday_type
    AND    put.legislation_code  = 'HU'
    AND    pui.user_row_id       =  pur.user_row_id
    AND    c_reporting_date BETWEEN pui.effective_start_date
                            AND     pui.effective_end_date
    AND    c_reporting_date BETWEEN pur.effective_start_date
                            AND     pur.effective_end_date  ;
    --
    CURSOR csr_location_code(c_location_id NUMBER) IS
    SELECT hrl.location_code
    FROM   hr_locations          hrl
    WHERE  hrl.location_id   = c_location_id;
    --
    CURSOR csr_job_name(c_job_id NUMBER) IS
    SELECT jbt.name
    FROM   per_jobs_tl jbt
    WHERE  jbt.language = userenv('LANG')
    AND    jbt.job_id   = c_job_id;
    --
    CURSOR csr_incl_excl(c_assignment_id     NUMBER
                        ,c_assignment_set_id NUMBER) IS
    SELECT 1
    FROM   hr_assignment_sets    has
          ,per_all_assignments_f paa
    WHERE  has.assignment_set_id =  NVL(c_assignment_set_id, has.assignment_set_id)
    AND    paa.assignment_id     =  c_assignment_id
    AND    NVL(paa.payroll_id,0) =  NVL(has.payroll_id,NVL(paa.payroll_id,0))
    AND    NOT EXISTS
           (
            SELECT 1
            FROM   hr_assignment_set_amendments hasa
            WHERE  hasa.assignment_set_id =  c_assignment_set_id
            AND    hasa.assignment_id     =  c_assignment_id
            AND    hasa.include_or_exclude = 'E'
           )
    AND   NOT EXISTS
           (
            SELECT 1
            FROM   hr_assignment_set_amendments hasa
            WHERE  hasa.assignment_set_id  = c_assignment_set_id
            AND    hasa.assignment_id      <>  c_assignment_id
            AND    hasa.include_or_exclude = 'I'
            AND NOT EXISTS
                         (
                          SELECT 1
                          FROM   hr_assignment_set_amendments hasa
                          WHERE  hasa.assignment_set_id  =  c_assignment_set_id
                          AND    hasa.assignment_id      =  c_assignment_id
                          AND    hasa.include_or_exclude = 'I'
                          )
            );
    --
    CURSOR csr_accrual_details(c_accrual_plan VARCHAR2
                              ,c_business_group_id NUMBER) IS
    SELECT accrual_plan_id
          ,accrual_plan_element_type_id
          ,co_formula_id
    FROM   pay_accrual_plans
    WHERE  accrual_plan_name = c_accrual_plan
    AND    business_group_id = c_business_group_id;
    --
    CURSOR suspended_asg_end_dt(c_assignment_id  NUMBER
                               ,c_reporting_date DATE    ) IS
    SELECT MAX(paa.effective_end_date)
    FROM   per_all_assignments_f        paa
          ,per_assignment_status_types  pas
    WHERE  paa.assignment_id              =  c_assignment_id
    AND    pas.assignment_status_type_id  =  paa.assignment_status_type_id
    AND    pas.per_system_status          = 'SUSP_ASSIGN'
    AND    paa.effective_end_date
                BETWEEN to_date('01-JAN'||to_char(c_reporting_date,'YYYY'),'dd/mm/yyyy')
                AND     to_date('31-DEC'||to_char(c_reporting_date,'YYYY'),'dd/mm/yyyy');
    --

    l_actid                      NUMBER;
    l_action_info_id             pay_action_information.action_information_id%TYPE;
    l_ovn                        pay_action_information.object_version_NUMBER%TYPE;
    l_emp_id                     per_all_people_f.person_id%TYPE;
    l_sort_1                     VARCHAR2(30);
    l_sort_2                     VARCHAR2(30);
    l_incl_excl                  NUMBER;
    l_effective_date             DATE;

    l_Base_ele_type_id           pay_accrual_plans.accrual_plan_element_type_id%TYPE;
    l_childcare_ele_type_id      pay_accrual_plans.accrual_plan_element_type_id%TYPE;
    l_other_ele_type_id          pay_accrual_plans.accrual_plan_element_type_id%TYPE;
    l_sickness_ele_type_id       pay_accrual_plans.accrual_plan_element_type_id%TYPE;

    l_accrual_plan_id_1          pay_accrual_plans.accrual_plan_id%TYPE;
    l_accrual_plan_id_2          pay_accrual_plans.accrual_plan_id%TYPE;
    l_accrual_plan_id_3          pay_accrual_plans.accrual_plan_id%TYPE;
    l_accrual_plan_id_4          pay_accrual_plans.accrual_plan_id%TYPE;

    l_base_holiday               NUMBER;
    l_base_holiday_prev          NUMBER;
    l_child_care_holiday         NUMBER;
    l_child_care_holiday_prev    NUMBER;
    l_additional_holiday         NUMBER;
    l_additional_holiday_prev    NUMBER;
    l_normal_paid_holiday_prev   NUMBER;
    l_sickness_holiday           NUMBER;
    l_normal_holiday_total       NUMBER;

    l_base_holiday_sum           NUMBER;
    l_child_care_holiday_sum     NUMBER;
    l_additional_holiday_sum     NUMBER;
    l_sickness_holiday_sum       NUMBER;

    l_base_accrual_sum           NUMBER;
    l_child_care_accrual_sum     NUMBER;
    l_additional_accrual_sum     NUMBER;
    l_sickness_accrual_sum       NUMBER;

    --l_base_absence_sum           NUMBER;
    --l_child_care_absence_sum     NUMBER;
    --l_additional_absence_sum     NUMBER;

    l_base_holiday_carry_over    NUMBER;
    l_child_hol_carry_over       NUMBER;
    l_add_holiday_carry_over     NUMBER;

    l_base_hol_carry_over_sum    NUMBER;
    l_child_hol_carry_over_sum   NUMBER;
    l_add_hol_carry_over_sum     NUMBER;

    l_start_date                 DATE;
    l_end_date                   DATE;
    l_accrual_end_date           DATE;
    l_base_accrual               NUMBER;
    l_child_care_accrual         NUMBER;
    l_additional_accrual         NUMBER;
    l_sickness_accrual           NUMBER;

    l_base_exp_date              DATE;
    l_child_care_exp_date        DATE;
    l_additional_exp_date        DATE;

    --l_base_absence               NUMBER;
    --l_child_care_absence         NUMBER;
    --l_additional_absence         NUMBER;

    l_location_code              hr_locations.location_code%TYPE;
    l_job_name                   per_job_definitions.segment1%TYPE;

    l_calculation_date           DATE;
    l_term_end_date              DATE;
    l_co_formula_id_1            pay_accrual_plans.co_formula_id%TYPE;
    l_co_formula_id_2            pay_accrual_plans.co_formula_id%TYPE;
    l_co_formula_id_3            pay_accrual_plans.co_formula_id%TYPE;
    l_co_formula_id_4            pay_accrual_plans.co_formula_id%TYPE;
    l_max_co                     NUMBER;
    l_dummy                      DATE;
    l_sus_asg_end_dt             DATE;
    l_emp_enrolment              NUMBER;
    l_absence                    NUMBER;
    --
 BEGIN
  --
  l_base_holiday_sum           := 0;
  l_child_care_holiday_sum     := 0;
  l_additional_holiday_sum     := 0;
  l_sickness_holiday_sum       := 0;
  --
  l_base_accrual_sum           := 0;
  l_child_care_accrual_sum     := 0;
  l_additional_accrual_sum     := 0;
  l_sickness_accrual_sum       := 0;
  --
  --l_base_absence_sum           := 0;
  --l_child_care_absence_sum     := 0;
  --l_additional_absence_sum     := 0;
   --
  l_base_hol_carry_over_sum    := 0;
  l_child_hol_carry_over_sum   := 0;
  l_add_hol_carry_over_sum     := 0;
  --
  per_hu_abs_rep_archive_pkg.get_all_parameters (
                          p_payroll_action_id   =>  p_actid
                         ,p_business_group_id   =>  g_business_group_id
                         ,p_effective_date      =>  l_effective_date
                         ,p_reporting_date      =>  g_reporting_date
                         ,p_payroll_id          =>  g_payroll_id
                         ,p_assignment_set_id   =>  g_assignment_set_id
                         ,p_employee_id         =>  l_emp_id
                          );

   FOR csr_rec IN csr_qualifying_assignments(p_actid
                                            ,stperson
                                            ,endperson
                                            ,g_reporting_date
                                            ,g_payroll_id
                                            ,l_emp_id) LOOP
       l_emp_enrolment              := 0;
       --
       OPEN csr_location_code(csr_rec.location_id);
       FETCH csr_location_code INTO l_location_code;
       CLOSE  csr_location_code;
       --
       OPEN suspended_asg_end_dt(csr_rec.assignment_id,g_reporting_date);
       FETCH suspended_asg_end_dt INTO l_sus_asg_end_dt;
       CLOSE suspended_asg_end_dt;
       --
       OPEN csr_job_name(csr_rec.job_id);
       FETCH csr_job_name INTO l_job_name;
       CLOSE csr_job_name;
       --
       IF  g_assignment_set_id IS NOT NULL THEN
           OPEN csr_incl_excl(csr_rec.assignment_id
                             ,g_assignment_set_id);
           FETCH csr_incl_excl INTO l_incl_excl;
           CLOSE csr_incl_excl;
       END IF;

       IF l_incl_excl = 1 OR g_assignment_set_id  IS NULL THEN
           FOR csr_utv IN csr_get_utv(g_business_group_id
                                     ,g_reporting_date
                                     ,'HU1') LOOP
               IF csr_utv.accrual_plan IS NOT NULL THEN
                   OPEN csr_accrual_details(csr_utv.accrual_plan,g_business_group_id);
                   FETCH csr_accrual_details INTO l_accrual_plan_id_1
                                                 ,l_Base_ele_type_id
                                                 ,l_co_formula_id_1;
                   CLOSE csr_accrual_details;

                   IF l_accrual_plan_id_1 IS NOT NULL THEN
                   IF per_accrual_calc_functions.check_assignment_enrollment(
                           csr_rec.assignment_id
                          ,l_Base_ele_type_id
                          ,g_reporting_date) THEN

                       l_emp_enrolment              := 1;

                       per_accrual_calc_functions.get_carry_over_values
                         (p_co_formula_id     => l_co_formula_id_1
                         ,p_assignment_id     => csr_rec.assignment_id
                         ,p_calculation_date  => g_reporting_date
                         ,p_accrual_plan_id   => l_accrual_plan_id_1
                         ,p_business_group_id => g_business_group_id
                         ,p_payroll_id        => csr_rec.payroll_id
                         ,p_accrual_term      => 'CURRENT'
                         ,p_effective_date    => l_term_end_date
                         ,p_session_date      => g_reporting_date
                         ,p_max_carry_over    => l_max_co
                         ,p_expiry_date       => l_base_exp_date
                         );

                       l_calculation_date := LEAST(l_term_end_date
                                                 ,NVL(csr_rec.termination_date
                                                 ,TO_DATE('31-12-4712','DD-MM-YYYY')));

                       per_accrual_calc_functions.get_net_accrual
                       (p_assignment_id          => csr_rec.assignment_id
                       ,p_plan_id                => l_accrual_plan_id_1
                       ,p_payroll_id             => csr_rec.payroll_id
                       ,p_business_group_id      => g_business_group_id
                       ,p_assignment_action_id   => -1
                       ,p_calculation_date       => l_calculation_date
                       ,p_accrual_start_date     => NULL
                       ,p_accrual_latest_balance => NULL
                       ,p_calling_point          => 'FRM'
                       ,p_start_date             => l_start_date
                       ,p_end_date               => l_end_date
                       ,p_accrual_end_date       => l_accrual_end_date
                       ,p_accrual                => l_base_accrual
                       ,p_net_entitlement        => l_base_holiday);

                  /* ***********************************************************
                        l_base_holiday_prev :=
                                 per_accrual_calc_functions.get_carry_over
                                     (p_assignment_id      => csr_rec.assignment_id
                                     ,p_plan_id            => l_accrual_plan_id_1
                                     ,p_start_date         => l_start_date
                                     ,p_calculation_date   => l_end_date
                                     );


                       l_base_holiday_carry_over :=
                                 per_accrual_calc_functions.get_carry_over
                                     (p_assignment_id      => csr_rec.assignment_id
                                     ,p_plan_id            => l_accrual_plan_id_1
                                     ,p_start_date         => l_start_date
                                     ,p_calculation_date   => to_date('01-JAN'||to_char(g_reporting_date,'YYYY'),'dd/mm/yyyy')
                                     );


                       l_base_holiday  := nvl(l_base_holiday,0) - nvl(l_base_holiday_prev,0);

                         l_base_absence := per_accrual_calc_functions.get_absence(
                                  p_assignment_id    => csr_rec.assignment_id
                                 ,p_plan_id          => l_accrual_plan_id_1
                                 ,p_start_date       => l_start_date
                                 ,p_calculation_date =>g_reporting_date); --  to_date(to_char(l_base_exp_date,'dd/mm')||to_char(g_reporting_date,'YYYY'),'dd/mm/yyyy')
                      *********************************************************/

                     IF TO_NUMBER(TO_CHAR(g_reporting_date,'mmdd')) <= TO_NUMBER(TO_CHAR(l_base_exp_date,'mmdd')) THEN
                                 l_base_holiday_carry_over :=
                                 per_accrual_calc_functions.get_carry_over
                                     (p_assignment_id      => csr_rec.assignment_id
                                     ,p_plan_id            => l_accrual_plan_id_1
                                     ,p_start_date         => l_start_date
                                     ,p_calculation_date   => to_date('01/01/'||to_char(g_reporting_date,'YYYY'),'dd/mm/yyyy')
                                     );
                                   l_normal_holiday_total   :=  nvl(l_normal_holiday_total,0)
                                                                +nvl(l_base_accrual,0)
                                                                +nvl(l_base_holiday_carry_over,0) ;

                     ELSE
                                   l_base_holiday_carry_over := 0;
                                   l_normal_holiday_total :=  nvl(l_normal_holiday_total,0)
                                                              +nvl(l_base_accrual,0);
                     END IF;
                    ELSE
                       --l_base_absence   := 0;
                       l_base_accrual   :=0;
                       l_base_holiday   := 0;
                       l_base_holiday_carry_over := 0;
                    END IF;
                    END IF;
                    --l_base_absence_sum := l_base_absence_sum + nvl(l_base_absence,0);
                    --l_base_holiday_sum := l_base_holiday_sum + nvl(l_base_holiday,0);
                    l_base_accrual_sum := l_base_accrual_sum + nvl(l_base_accrual,0);
                    l_base_hol_carry_over_sum := l_base_hol_carry_over_sum + nvl(l_base_holiday_carry_over,0);
                END IF;
            END LOOP;

            FOR csr_utv IN csr_get_utv(g_business_group_id
                                      ,g_reporting_date
                                      ,'HU2') LOOP
                IF csr_utv.accrual_plan IS NOT NULL THEN
                    OPEN csr_accrual_details(csr_utv.accrual_plan,g_business_group_id);
                    FETCH csr_accrual_details INTO l_accrual_plan_id_2
                                                  ,l_childcare_ele_type_id
                                                  ,l_co_formula_id_2;
                    CLOSE csr_accrual_details;
                    IF l_accrual_plan_id_2 IS NOT NULL THEN
                    IF per_accrual_calc_functions.check_assignment_enrollment(
                                csr_rec.assignment_id
                               ,l_childcare_ele_type_id
                               ,g_reporting_date) THEN

                       l_emp_enrolment              := 1;

                       per_accrual_calc_functions.get_carry_over_values
                       (p_co_formula_id     => l_co_formula_id_2
                       ,p_assignment_id     => csr_rec.assignment_id
                       ,p_calculation_date  => g_reporting_date
                       ,p_accrual_plan_id   => l_accrual_plan_id_2
                       ,p_business_group_id => g_business_group_id
                       ,p_payroll_id        => csr_rec.payroll_id
                       ,p_accrual_term      => 'CURRENT'
                       ,p_effective_date    => l_term_end_date
                       ,p_session_date      => g_reporting_date
                       ,p_max_carry_over    => l_max_co
                       ,p_expiry_date       => l_child_care_exp_date
                       );

                       l_calculation_date := LEAST(l_term_end_date
                                                ,NVL(csr_rec.termination_date
                                                ,TO_DATE('31-12-4712','DD-MM-YYYY')));

                       per_accrual_calc_functions.get_net_accrual
                       (p_assignment_id          => csr_rec.assignment_id
                       ,p_plan_id                => l_accrual_plan_id_2
                       ,p_payroll_id             => csr_rec.payroll_id
                       ,p_business_group_id      => g_business_group_id
                       ,p_assignment_action_id   => -1
                       ,p_calculation_date       => l_calculation_date
                       ,p_accrual_start_date     => NULL
                       ,p_accrual_latest_balance => NULL
                       ,p_calling_point          => 'FRM'
                       ,p_start_date             => l_start_date
                       ,p_end_date               => l_end_date
                       ,p_accrual_end_date       => l_accrual_end_date
                       ,p_accrual                => l_child_care_accrual
                       ,p_net_entitlement        => l_child_care_holiday);

                  /*************************************************************
                        l_child_care_holiday_prev :=
                               per_accrual_calc_functions.get_carry_over
                                   (p_assignment_id      => csr_rec.assignment_id
                                   ,p_plan_id            => l_accrual_plan_id_2
                                   ,p_start_date         => l_start_date
                                   ,p_calculation_date   => l_end_date
                                );


                       l_child_hol_carry_over :=
                           per_accrual_calc_functions.get_carry_over
                                   (p_assignment_id      => csr_rec.assignment_id
                                   ,p_plan_id            => l_accrual_plan_id_2
                                   ,p_start_date         => l_start_date
                                   ,p_calculation_date   => to_date('01-JAN'||to_char(g_reporting_date,'YYYY'),'dd/mm/yyyy')
                                   );

                       l_child_care_holiday  := nvl(l_child_care_holiday,0) -
                                                nvl(l_child_care_holiday_prev,0);

                       l_child_care_absence :=  per_accrual_calc_functions.get_absence(
                                  p_assignment_id    => csr_rec.assignment_id
                                 ,p_plan_id          => l_accrual_plan_id_2
                                 ,p_start_date       => l_start_date
                                 ,p_calculation_date => g_reporting_date --  to_date(to_char(l_child_care_exp_date,'dd/mm')||to_char(g_reporting_date,'YYYY'),'dd/mm/yyyy')
                                 );
                       ********************************************************/

                      IF TO_NUMBER(TO_CHAR(g_reporting_date,'mmdd')) <= TO_NUMBER(TO_CHAR(l_child_care_exp_date,'mmdd')) THEN
                            l_child_hol_carry_over :=
                           per_accrual_calc_functions.get_carry_over
                                   (p_assignment_id      => csr_rec.assignment_id
                                   ,p_plan_id            => l_accrual_plan_id_2
                                   ,p_start_date         => l_start_date
                                   ,p_calculation_date   => to_date('01/01/'||to_char(g_reporting_date,'YYYY'),'dd/mm/yyyy')
                                   );
                            l_normal_holiday_total   :=  nvl(l_normal_holiday_total,0)
                                                        +nvl(l_child_care_accrual,0)
                                                        +nvl(l_child_hol_carry_over,0);
                      ELSE
                           l_child_hol_carry_over := 0;
                           l_normal_holiday_total := nvl(l_normal_holiday_total,0)+
                                                     nvl(l_child_care_accrual,0);
                      END IF;
                    ELSE
                       --l_child_care_absence := 0;
                       l_child_care_accrual  := 0;
                       l_child_care_holiday  := 0;
                       l_child_hol_carry_over := 0;
                    END IF;
                    END IF;
                    --l_child_care_absence_sum := l_child_care_absence_sum + nvl(l_child_care_absence,0);
                    l_child_care_accrual_sum := l_child_care_accrual_sum + nvl(l_child_care_accrual,0);
                    --l_child_care_holiday_sum := l_child_care_holiday_sum + nvl(l_child_care_holiday,0);
                    l_child_hol_carry_over_sum := l_child_hol_carry_over_sum + nvl(l_child_hol_carry_over,0);
                END IF;
            END LOOP;

         FOR csr_utv IN csr_get_utv(g_business_group_id
                                   ,g_reporting_date
                                   ,'HU3') LOOP
                IF csr_utv.accrual_plan IS NOT NULL THEN
                    OPEN csr_accrual_details(csr_utv.accrual_plan,g_business_group_id);
                    FETCH csr_accrual_details INTO l_accrual_plan_id_3
                                                  ,l_other_ele_type_id
                                                  ,l_co_formula_id_3;
                    CLOSE csr_accrual_details;

                    IF l_accrual_plan_id_3 IS NOT NULL THEN
                    IF per_accrual_calc_functions.check_assignment_enrollment(
                                  csr_rec.assignment_id
                                 ,l_other_ele_type_id
                                 ,g_reporting_date) THEN

                       l_emp_enrolment              := 1;

                       per_accrual_calc_functions.get_carry_over_values
                       (p_co_formula_id     => l_co_formula_id_3
                       ,p_assignment_id     => csr_rec.assignment_id
                       ,p_calculation_date  => g_reporting_date
                       ,p_accrual_plan_id   => l_accrual_plan_id_3
                       ,p_business_group_id => g_business_group_id
                       ,p_payroll_id        => csr_rec.payroll_id
                       ,p_accrual_term      => 'CURRENT'
                       ,p_effective_date    => l_term_end_date
                       ,p_session_date      => g_reporting_date
                       ,p_max_carry_over    => l_max_co
                       ,p_expiry_date       => l_additional_exp_date
                       );

                       l_calculation_date := LEAST(l_term_end_date
                                                ,NVL(csr_rec.termination_date
                                                ,TO_DATE('31-12-4712','DD-MM-YYYY')));

                       per_accrual_calc_functions.get_net_accrual
                       (p_assignment_id          => csr_rec.assignment_id
                       ,p_plan_id                => l_accrual_plan_id_3
                       ,p_payroll_id             => csr_rec.payroll_id
                       ,p_business_group_id      => g_business_group_id
                       ,p_assignment_action_id   => -1
                       ,p_calculation_date       => l_calculation_date
                       ,p_accrual_start_date     => NULL
                       ,p_accrual_latest_balance => NULL
                       ,p_calling_point          => 'FRM'
                       ,p_start_date             => l_start_date
                       ,p_end_date               => l_end_date
                       ,p_accrual_end_date       => l_accrual_end_date
                       ,p_accrual                => l_additional_accrual
                       ,p_net_entitlement        => l_additional_holiday);

                  /*************************************************************
                        l_additional_holiday_prev :=
                               per_accrual_calc_functions.get_carry_over
                                   (p_assignment_id      => csr_rec.assignment_id
                                   ,p_plan_id            => l_accrual_plan_id_3
                                   ,p_start_date         => l_start_date
                                   ,p_calculation_date   => l_end_date
                                );


                       l_add_holiday_carry_over  :=
                                per_accrual_calc_functions.get_carry_over
                                   (p_assignment_id      => csr_rec.assignment_id
                                   ,p_plan_id            => l_accrual_plan_id_3
                                   ,p_start_date         => l_start_date
                                   ,p_calculation_date   => to_date('01-JAN'||to_char(g_reporting_date,'YYYY'),'dd/mm/yyyy')
                                   );

                       l_additional_holiday  := nvl(l_additional_holiday,0) -
                                                nvl(l_additional_holiday_prev,0);

                      l_additional_absence := per_accrual_calc_functions.get_absence(
                                  p_assignment_id    => csr_rec.assignment_id
                                 ,p_plan_id          => l_accrual_plan_id_3
                                 ,p_start_date       => l_start_date
                                 ,p_calculation_date => g_reporting_date -- to_date(to_char(l_additional_exp_date,'dd/mm')||to_char(g_reporting_date,'YYYY'),'dd/mm/yyyy')
                                 );
                     **********************************************************/
                     IF TO_NUMBER(TO_CHAR(g_reporting_date,'mmdd')) <= TO_NUMBER(TO_CHAR(l_additional_exp_date,'mmdd')) THEN
                              l_add_holiday_carry_over  :=
                                per_accrual_calc_functions.get_carry_over
                                   (p_assignment_id      => csr_rec.assignment_id
                                   ,p_plan_id            => l_accrual_plan_id_3
                                   ,p_start_date         => l_start_date
                                   ,p_calculation_date   => to_date('01/01/'||to_char(g_reporting_date,'YYYY'),'dd/mm/yyyy')
                                   );
                              l_normal_holiday_total := nvl(l_normal_holiday_total,0)
                                                        +nvl(l_additional_accrual,0)
                                                        +nvl(l_add_holiday_carry_over,0);

                     ELSE
                               l_add_holiday_carry_over  := 0;
                               l_normal_holiday_total := nvl(l_normal_holiday_total,0)+
                                                         nvl(l_additional_accrual,0);
                     END IF;
                     ELSE
                       --l_additional_absence  := 0;
                       l_additional_accrual  := 0;
                       l_additional_holiday  := 0;
                       l_add_holiday_carry_over := 0;
                    END IF;
                    END IF;
                    --l_additional_absence_sum := l_additional_absence_sum + nvl(l_additional_absence,0);
                    l_additional_accrual_sum := l_additional_accrual_sum + nvl(l_additional_accrual,0);
                    --l_additional_holiday_sum := l_additional_holiday_sum + nvl(l_additional_holiday,0);
                    l_add_hol_carry_over_sum := l_add_hol_carry_over_sum + nvl(l_add_holiday_carry_over,0);
                END IF;
            END LOOP;

            FOR csr_utv IN csr_get_utv(g_business_group_id
                                      ,g_reporting_date
                                      ,'HU4') LOOP
                IF csr_utv.accrual_plan IS NOT NULL THEN
                    OPEN csr_accrual_details(csr_utv.accrual_plan,g_business_group_id);
                    FETCH csr_accrual_details INTO l_accrual_plan_id_4
                                                  ,l_sickness_ele_type_id
                                                  ,l_co_formula_id_4;
                    CLOSE csr_accrual_details;

                    IF l_accrual_plan_id_4 IS NOT NULL THEN
                    IF per_accrual_calc_functions.check_assignment_enrollment(
                               csr_rec.assignment_id
                              ,l_sickness_ele_type_id
                              ,g_reporting_date) THEN

                       l_emp_enrolment              := 1;

                       per_accrual_calc_functions.get_carry_over_values
                         (p_co_formula_id     => l_co_formula_id_4
                         ,p_assignment_id     => csr_rec.assignment_id
                         ,p_calculation_date  => g_reporting_date
                         ,p_accrual_plan_id   => l_accrual_plan_id_4
                         ,p_business_group_id => g_business_group_id
                         ,p_payroll_id        => csr_rec.payroll_id
                         ,p_accrual_term      => 'CURRENT'
                         ,p_effective_date    => l_term_end_date
                         ,p_session_date      => g_reporting_date
                         ,p_max_carry_over    => l_max_co
                         ,p_expiry_date       => l_dummy
                         );

                       l_calculation_date := LEAST(l_term_end_date
                                          ,NVL(csr_rec.termination_date
                                              ,TO_DATE('31-12-4712','DD-MM-YYYY')));

                       per_accrual_calc_functions.get_net_accrual
                       (p_assignment_id          => csr_rec.assignment_id
                       ,p_plan_id                => l_accrual_plan_id_4
                       ,p_payroll_id             => csr_rec.payroll_id
                       ,p_business_group_id      => g_business_group_id
                       ,p_assignment_action_id   => -1
                       ,p_calculation_date       => l_calculation_date
                       ,p_accrual_start_date     => NULL
                       ,p_accrual_latest_balance => NULL
                       ,p_calling_point          => 'FRM'
                       ,p_start_date             => l_start_date
                       ,p_end_date               => l_end_date
                       ,p_accrual_end_date       => l_accrual_end_date
                       ,p_accrual                => l_sickness_accrual
                       ,p_net_entitlement        => l_sickness_holiday);
                   ELSE
                      l_sickness_holiday := 0;
                      l_sickness_accrual := 0;
                   END IF;
                   END IF;
                 --l_sickness_holiday_sum := l_sickness_holiday_sum + nvl(l_sickness_holiday,0);
                   l_sickness_accrual_sum := l_sickness_accrual_sum + nvl(l_sickness_accrual,0);
               END IF;
           END LOOP;

        l_normal_paid_holiday_prev := nvl(l_base_hol_carry_over_sum,0) +
                                      nvl(l_child_hol_carry_over_sum,0) +
                                      nvl(l_add_hol_carry_over_sum,0);

          IF l_emp_enrolment = 1  THEN

          --
          SELECT pay_assignment_actions_s.NEXTVAL
          INTO   l_actid
          FROM   dual;
          --
          hr_nonrun_asact.insact(l_actid,csr_rec.assignment_id,p_actid,chunk,NULL);
          --
          pay_action_information_api.create_action_information (
                 p_action_information_id        =>  l_action_info_id
               , p_action_context_id            =>  l_actid
               , p_action_context_type          =>  'AAP'
               , p_object_version_NUMBER        =>  l_ovn
               , p_assignment_id                =>  csr_rec.assignment_id
               , p_effective_date               =>  l_effective_date
               , p_action_information_category  =>  'HU_ABSENCE_REPORT'
               , p_action_information4          =>  csr_rec.company_name
               , p_action_information5          =>  csr_rec.full_name
               , p_action_information6          =>  csr_rec.organization
               , p_action_information7          =>  l_location_code
               , p_action_information8          =>  csr_rec.emp_no
               , p_action_information9          =>  fnd_date.date_to_displaydate(csr_rec.date_of_birth)
               , p_action_information10         =>  l_job_name
               , p_action_information11         =>  fnd_date.date_to_displaydate(csr_rec.hire_date)
               , p_action_information12         =>  fnd_date.date_to_displaydate(l_sus_asg_end_dt)
               , p_action_information13         =>  to_char(g_reporting_date,'YYYY')
               , p_action_information14         =>  l_base_accrual_sum
               , p_action_information15         =>  l_child_care_accrual_sum
               , p_action_information16         =>  l_additional_accrual_sum
               , p_action_information17         =>  l_normal_paid_holiday_prev
               , p_action_information18         =>  l_sickness_accrual_sum
               , p_action_information19         =>  l_normal_holiday_total
               , p_action_information20         =>  fnd_date.date_to_displaydate(g_reporting_date)
               , p_action_information21         =>  csr_rec.people_group_id);
        ELSE
             fnd_file.put_line(fnd_file.log,substr(csr_rec.full_name,1,30)
                                        || ' ['
                                        || substr(csr_rec.emp_no,1,30) || '] : '
                                        || fnd_message.get_string('PER','HR_HU_ABS_REP_EXC_LIST'));
        END IF;
     END IF;
    END LOOP;
END action_creation_code;
--------------------------------------------------------------------------------
-- GET_CHILDREN_INFO
--------------------------------------------------------------------------------
FUNCTION get_children_info( p_assignment_id       IN  NUMBER
                            ,p_business_group_id  IN  NUMBER
                            ,p_start_date         IN  DATE
                            ,p_end_date           IN  DATE
                            ,p_no_child_less_16   OUT NOCOPY NUMBER
                            ,p_no_child_16        OUT NOCOPY NUMBER
                            ,p_child_dob1         OUT NOCOPY DATE
			                      ,p_child_dob2         OUT NOCOPY DATE
                  			    ,p_child_dob3         OUT NOCOPY DATE
                            ) RETURN NUMBER IS
  --
  CURSOR csr_child_less_then_16 is
  SELECT count(*)
  FROM PER_CONTACT_RELATIONSHIPS pcr
       ,per_all_people_f pap
       ,per_all_assignments_f paa
  WHERE pcr.person_id = paa.person_id
  AND   pap.business_group_id = p_business_group_id
  AND   pcr.business_group_id = p_business_group_id
  AND   pcr.cont_information3 = 'Y'
  AND   paa.assignment_id = p_assignment_id
  AND   pcr.contact_person_id = pap.person_id
  AND   pcr.contact_type IN ('C','A')
  AND   p_start_date BETWEEN decode(pcr.date_start,NULL,to_date('01010001','ddmmyyyy'),pcr.date_start)
                     AND     decode(pcr.date_end,NULL,to_date('01014712','ddmmyyyy'),pcr.date_end)
  AND   p_start_date BETWEEN pap.effective_start_date AND pap.effective_end_date
  AND   p_start_date BETWEEN paa.effective_start_date AND paa.effective_end_date
  AND   months_between(p_end_date,pap.date_of_birth)/12 < 16;
  --
  CURSOR csr_child_16 is
  SELECT count(*)
  FROM PER_CONTACT_RELATIONSHIPS pcr
       ,per_all_people_f pap
       ,per_all_assignments_f paa
  WHERE pcr.person_id = paa.person_id
  AND   pap.business_group_id = p_business_group_id
  AND   pcr.business_group_id = p_business_group_id
  AND   pcr.cont_information3 = 'Y'
  AND   paa.assignment_id = p_assignment_id
  AND   pcr.contact_person_id = pap.person_id
  AND   pcr.contact_type IN ('C','A')
  AND   p_start_date BETWEEN decode(pcr.date_start,NULL,to_date('01010001','ddmmyyyy'),pcr.date_start)
                     AND     decode(pcr.date_end,NULL,to_date('01014712','ddmmyyyy'),pcr.date_end)
  AND   p_start_date BETWEEN pap.effective_start_date AND pap.effective_end_date
  AND   p_start_date BETWEEN paa.effective_start_date AND paa.effective_end_date
  AND   to_char(pap.date_of_birth,'mmdd') BETWEEN to_char(p_start_date,'mmdd')
                                          AND     to_char(p_end_date,'mmdd')
  AND   to_char(p_end_date,'yyyy') - to_char(pap.date_of_birth,'yyyy') = 16;
  --
  CURSOR csr_child_16_dob is
  SELECT pap.date_of_birth dob
  FROM per_contact_relationships pcr
       ,per_all_people_f pap
       ,per_all_assignments_f paa
  WHERE pcr.person_id = paa.person_id
  AND   pap.business_group_id = p_business_group_id
  AND   pcr.business_group_id = p_business_group_id
  AND   pcr.cont_information3 = 'Y'
  AND   paa.assignment_id = p_assignment_id
  AND   pcr.contact_person_id = pap.person_id
  AND   pcr.contact_type IN ('C','A')
  AND   p_start_date between decode(pcr.date_start,NULL,to_date('01010001','ddmmyyyy'),pcr.date_start)
        AND decode(pcr.date_end,NULL,to_date('01014712','ddmmyyyy'),pcr.date_end)
  AND   p_start_date between pap.effective_start_date AND pap.effective_end_date
  AND   p_start_date between paa.effective_start_date AND paa.effective_end_date
  AND   to_char(pap.date_of_birth,'mmdd') between to_char(p_start_date,'mmdd') AND to_char(p_end_date,'mmdd')
  AND   to_char(p_end_date,'yyyy') - to_char(pap.date_of_birth,'yyyy') = 16
  ORDER BY pap.date_of_birth desc;
  --
  mcnt NUMBER;
  --
BEGIN
  OPEN csr_child_less_then_16;
  FETCH csr_child_less_then_16 INTO p_no_child_less_16;
  CLOSE csr_child_less_then_16;
  OPEN csr_child_16;
  FETCH csr_child_16 INTO p_no_child_16;
  CLOSE csr_child_16;

  mcnt := 1;

  FOR child_info IN csr_child_16_dob LOOP
    IF mcnt = 1 THEN
      p_child_dob1 := to_date(to_char(child_info.dob,'dd/mm/')||
                      to_char(p_start_date,'yyyy'),'dd/mm/yyyy');
    ELSIF mcnt = 2 THEN
      p_child_dob2 := to_date(to_char(child_info.dob,'dd/mm/')||
                      to_char(p_start_date,'yyyy'),'dd/mm/yyyy');
    ELSIF mcnt = 2 THEN
      p_child_dob3 := to_date(to_char(child_info.dob,'dd/mm/')||
                      to_char(p_start_date,'yyyy'),'dd/mm/yyyy');
    END IF;
    mcnt := mcnt+1;

  END LOOP;
  RETURN 0;
END get_children_info;
--------------------------------------------------------------------------------
-- GET_PAYROLL_PERIOD
--------------------------------------------------------------------------------
FUNCTION get_payroll_Period
(p_payroll_id                 IN  NUMBER
,p_calculation_date           IN  DATE
,p_accrual_frequency          OUT NOCOPY VARCHAR2
,p_accrual_multiplier         OUT NOCOPY NUMBER
 ) RETURN NUMBER IS
--
CURSOR csr_pay_period_count IS
SELECT ptp.number_per_fiscal_year
      ,ptp.period_type
FROM   pay_payrolls_f        ppf
      ,per_time_period_types ptp
WHERE payroll_id         = p_payroll_id
AND   ptp.period_type    = ppf.period_type
AND p_calculation_date
    BETWEEN  ppf.effective_start_date
    AND      ppf.effective_end_date ;
--
l_periods      NUMBER;
l_period_types VARCHAR2(30);
--
BEGIN
OPEN  csr_pay_period_count;
FETCH csr_pay_period_count INTO l_periods, l_period_types;
CLOSE csr_pay_period_count;

IF l_period_types IN ('Bi-Month','Calendar Month','Semi-Month'
                      ,'Year','Semi-Year','Quarter') THEN
   p_accrual_frequency  := 'M';
   p_accrual_multiplier :=  12/l_periods ;
ELSIF l_period_types IN ('Bi-Week','Week','Lunar Month') THEN
   p_accrual_frequency  := 'W';
   p_accrual_multiplier :=  52/l_periods ;
END IF;

RETURN l_periods;
END get_payroll_Period;
--------------------------------------------------------------------------------
-- WORKING_DAY_COUNT
--------------------------------------------------------------------------------
FUNCTION working_day_count
            (p_assignment_id     IN NUMBER
            ,p_business_group_id IN NUMBER
            ,p_start_date        IN DATE
            ,p_end_date          IN DATE) RETURN NUMBER IS
l_is_wrking_day    VARCHAR2(1);
l_error_code       NUMBER;
l_error_msg        VARCHAR2(2000);
l_date             DATE;
l_cnt              NUMBER := 0;
BEGIN
l_date := p_start_date;
LOOP
EXIT WHEN l_date > p_end_date;
l_is_wrking_day := PQP_SCHEDULE_CALCULATION_PKG.is_working_day
                   (p_assignment_id     => p_assignment_id
                   ,p_business_group_id => p_business_group_id
                   ,p_date              => l_date
                   ,p_error_code        => l_error_code
                   ,p_error_message     => l_error_msg
                   ,p_default_wp        => NULL
                   ,p_override_wp       => NULL
                   );

IF l_is_wrking_day = 'Y' THEN
   l_cnt := l_cnt + 1;
END IF;
l_date := l_date + 1;
END LOOP;
RETURN l_cnt;
END working_day_count;
--------------------------------------------------------------------------------
-- GET_PERSON_DOB
--------------------------------------------------------------------------------
FUNCTION get_person_dob
(p_assignment_id              IN  NUMBER
,p_calculation_date           IN  date ) RETURN Date is
CURSOR csr_person_dob IS
SELECT pap.date_of_birth
FROM   per_all_people_f       pap
      ,per_all_assignments_f  paa
WHERE  paa.assignment_id = p_assignment_id
AND    paa.person_id     = pap.person_id
AND    p_calculation_date
       BETWEEN  paa.effective_start_date
       AND      paa.effective_end_date
AND    p_calculation_date
       BETWEEN  pap.effective_start_date
       AND      pap.effective_end_date;
l_dob date;
BEGIN
OPEN  csr_person_dob;
FETCH csr_person_dob INTO l_dob;
CLOSE csr_person_dob;
RETURN l_dob;
END get_person_dob;
--------------------------------------------------------------------------------
-- GET_PREV_EMP_SICKNESS_LEAVE
--------------------------------------------------------------------------------
FUNCTION get_prev_emp_sickness_leave(p_assignment_id     IN   NUMBER
                                    ,p_business_group_id IN   NUMBER
                                    ,p_termination_year  IN   VARCHAR2
                                    ,p_prev_emp          OUT NOCOPY VARCHAR2)
RETURN NUMBER
IS
  CURSOR  csr_pre_emp_sickness_holiday(c_person_id NUMBER) IS
  SELECT  pem_information1
  FROM    per_previous_employers
  WHERE   business_group_id        = p_business_group_id
  AND     person_id                = c_person_id
  AND     to_char(end_date,'YYYY') = p_termination_year
  ORDER BY end_date DESC;

  CURSOR csr_get_person_id IS
  SELECT person_id FROM per_All_assignments_f
  WHERE assignment_id = p_assignment_id;

  l_sickness_leave NUMBER;
  l_person_id NUMBER;

BEGIN
  OPEN csr_get_person_id;
  FETCH csr_get_person_id into l_person_id;
  CLOSE csr_get_person_id;

  OPEN csr_pre_emp_sickness_holiday(l_person_id);
  FETCH csr_pre_emp_sickness_holiday into l_sickness_leave;
   IF NOT csr_pre_emp_sickness_holiday%Found THEN
     p_prev_emp := 'N';
   ELSE
     p_prev_emp := 'Y';
   END IF;
  CLOSE csr_pre_emp_sickness_holiday;
  return nvl(l_sickness_leave,0);

END get_prev_emp_sickness_leave;
--------------------------------------------------------------------------------
-- GET_DISABILITY
--------------------------------------------------------------------------------
FUNCTION get_disability(p_assignment_id     NUMBER
                       ,p_business_group_id NUMBER
                       ,p_period_start_date  DATE
                       ,p_period_end_date    DATE) RETURN NUMBER IS
CURSOR csr_disability is
    SELECT  pdf.effective_start_date,pdf.effective_end_date
    FROM    per_disabilities_f pdf ,per_all_people_f papf, per_all_assignments_f paaf
    WHERE   paaf.assignment_id=p_assignment_id
    AND     paaf.business_group_id=p_business_group_id
    AND     paaf.person_id=papf.person_id
    AND     papf.person_id=pdf.person_id
    AND     pdf.dis_information1='Y'
    AND     p_period_start_date between papf.effective_start_date and papf.effective_end_date
    AND     p_period_start_date between paaf.effective_start_date and paaf.effective_end_date
    AND     pdf.effective_start_date <= p_period_end_date
    AND     pdf.effective_end_date>=p_period_start_date;
l_blind_days            NUMBER:=0;
l_days                  NUMBER:=0;
p_disability_start_date DATE;
p_disability_end_date   DATE;
BEGIN

    OPEN csr_disability;
    LOOP
      FETCH csr_disability INTO p_disability_start_date,p_disability_end_date;
      EXIT WHEN csr_disability%NOTFOUND;
      IF p_disability_start_date>=p_period_start_date AND
         p_disability_start_date<=p_period_end_date   AND
         p_disability_end_date>=p_period_end_date     THEN
           l_blind_days := PER_HU_ABS_REP_ARCHIVE_PKG.working_day_count(p_assignment_id
                                                                       ,p_business_group_id
                                                                       ,p_disability_start_date
                                                                       ,p_period_end_date);
      ELSIF p_disability_start_date>=p_period_start_date AND
            p_disability_start_date<=p_period_end_date   AND
            p_disability_end_date<p_period_end_date      THEN
          l_blind_days := PER_HU_ABS_REP_ARCHIVE_PKG.working_day_count(p_assignment_id
                                                                      ,p_business_group_id
                                                                      ,p_disability_start_date
                                                                      ,p_disability_end_date);
      ELSIF p_disability_start_date<p_period_start_date AND
            p_disability_end_date<=p_period_end_date    THEN
          l_blind_days := PER_HU_ABS_REP_ARCHIVE_PKG.working_day_count(p_assignment_id
                                                                      ,p_business_group_id
                                                                      ,p_period_start_date
                                                                      ,p_disability_end_date);
      ELSIF p_disability_start_date<=p_period_start_date AND
            p_disability_end_date>=p_period_end_date     THEN
          l_blind_days := PER_HU_ABS_REP_ARCHIVE_PKG.working_day_count(p_assignment_id
                                                                      ,p_business_group_id
                                                                      ,p_period_start_date
                                                                      ,p_period_end_date);
      END IF;
      l_days := l_blind_days + l_days ;
    END LOOP;
    CLOSE csr_disability;
    RETURN l_days;
END get_disability;
--------------------------------------------------------------------------------
--GET_JOB_INFO
--------------------------------------------------------------------------------
FUNCTION get_job_info(p_assignment_id     NUMBER
                     ,p_business_group_id NUMBER
                     ,p_period_start_date  DATE
                     ,p_period_end_date    DATE) RETURN NUMBER is
CURSOR csr_job is
    SELECT  paaf.effective_start_date,paaf.effective_end_date,pj.date_to
    FROM    per_all_assignments_f paaf,per_jobs pj
    WHERE   paaf.assignment_id=p_assignment_id
    AND     paaf.business_group_id=p_business_group_id
    AND     paaf.job_id=pj.job_id
    AND     pj.job_information3='Y'
    AND     paaf.effective_start_date <= p_period_end_date
	AND     paaf.effective_end_date>= p_period_start_date
    AND     pj.date_FROM <= p_period_end_date
	AND     nvl(pj.date_to,to_date('31-12-4712','dd-mm-yyyy')) >= p_period_start_date;
l_job_days       NUMBER:=0;
l_days           NUMBER:=0;
p_job_start_date DATE;
p_job_end_date   DATE;
p_date_to        DATE;
BEGIN
    OPEN csr_job;
    LOOP
      FETCH csr_job into p_job_start_date,p_job_end_date,p_date_to;
      EXIT WHEN csr_job%NOTFOUND;
      IF p_job_start_date>=p_period_start_date AND p_job_start_date<=p_period_end_date
           AND p_job_end_date>=p_period_end_date THEN
           -- check for date_to
           IF p_date_to <= p_period_end_date THEN
              l_job_days := PER_HU_ABS_REP_ARCHIVE_PKG.working_day_count(p_assignment_id
                                                                        ,p_business_group_id
                                                                        ,p_job_start_date
                                                                        ,p_date_to);
           ELSE
              l_job_days := PER_HU_ABS_REP_ARCHIVE_PKG.working_day_count(p_assignment_id
                                                                        ,p_business_group_id
                                                                        ,p_job_start_date
                                                                        ,p_period_end_date);
           END IF;
      ELSIF p_job_start_date >= p_period_start_date AND
            p_job_start_date <= p_period_end_date   AND
            p_job_end_date < p_period_end_date      THEN
            -- check for date_to
           IF p_date_to <= p_job_end_date THEN
              l_job_days := PER_HU_ABS_REP_ARCHIVE_PKG.working_day_count(p_assignment_id
                                                                        ,p_business_group_id
                                                                        ,p_job_start_date
                                                                        ,p_date_to);
           ELSE
               l_job_days := PER_HU_ABS_REP_ARCHIVE_PKG.working_day_count(p_assignment_id
                                                                         ,p_business_group_id
                                                                         ,p_job_start_date
                                                                         ,p_job_end_date);
           END IF;
      ELSIF p_job_start_date < p_period_start_date AND
            p_job_end_date <= p_period_end_date    THEN
          -- check for date_to
          IF p_date_to <=p_job_end_date THEN
              l_job_days := PER_HU_ABS_REP_ARCHIVE_PKG.working_day_count(p_assignment_id
                                                                        ,p_business_group_id
                                                                        ,p_period_start_date
                                                                        ,p_date_to);
          ELSE
              l_job_days := PER_HU_ABS_REP_ARCHIVE_PKG.working_day_count(p_assignment_id
                                                                        ,p_business_group_id
                                                                        ,p_period_start_date
                                                                        ,p_job_end_date);
          END IF;
      ELSIF p_job_start_date <= p_period_start_date AND
            p_job_end_date >= p_period_end_date     THEN
          l_job_days := PER_HU_ABS_REP_ARCHIVE_PKG.working_day_count(p_assignment_id
                                                                    ,p_business_group_id
                                                                    ,p_period_start_date
                                                                    ,p_period_end_date);
      END IF;
      l_days := l_job_days + l_days ;
    END LOOP;
    CLOSE csr_job;
    RETURN l_days;
END get_job_info;
--------------------------------------------------------------------------------
-- CHK_ENTRY_IN_ACCRUAL_PLAN
--------------------------------------------------------------------------------
FUNCTION chk_entry_in_accrual_plan
                (p_entry_val      IN  VARCHAR2
                ,p_message        OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
    --
    l_found_value VARCHAR2(1);
    l_msg         VARCHAR2(255);
    --
BEGIN
    --
    l_msg := ' ';
    l_found_value := 'N';
    --
    IF p_entry_val IN ('HU1','HU2','HU3','HU4') THEN
            l_found_value := 'Y';
    ELSE
            l_msg := fnd_message.get_string('PER','HR_HU_UDT_VAL_CHECK');
            l_found_value := 'N';
    END IF;
    --
    p_message := l_msg;
    RETURN l_found_value;
    --
END chk_entry_in_accrual_plan;
--
END per_hu_abs_rep_archive_pkg;

/
